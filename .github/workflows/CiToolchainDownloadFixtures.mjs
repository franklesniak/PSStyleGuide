// Test-only fixtures. No import-time process, network, or filesystem mutation.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { createHash } from 'node:crypto';
import { spawn, spawnSync } from 'node:child_process';
import { readJsonBytes } from './Validate-WorkflowPolicy.mjs';

export const windowsCases = Object.freeze(['tls-stall', 'transient', 'retry-after-number',
  'retry-after-date', 'stall', 'partial-stall', 'partial-recovery', 'exhaustion', 'short-eof', 'wrong-digest']);
export const linuxCases = Object.freeze(['partial-recovery', 'exhaustion', 'short-eof', 'wrong-digest', 'wrong-version']);
export const digest = bytes => createHash('sha256').update(bytes).digest('hex');
export const quote = value => `'${value.replaceAll("'", "''")}'`;

export function once(source, anchor, replacement) {
  assert.equal(source.split(anchor).length, 2, `One exact fixture anchor is required: ${anchor}`);
  return source.replace(anchor, replacement);
}

function ordinaryPath(file, directory, nativeTool) {
  assert.ok(path.isAbsolute(file), 'An absolute path is required.');
  const resolved = path.resolve(file);
  let current = resolved, leaf;
  for (;;) {
    const s = fs.lstatSync(current, { bigint: true });
    assert.ok(!s.isSymbolicLink(), `Aliased input: ${current}`);
    if (current === resolved && !directory) {
      assert.ok(s.isFile() && (nativeTool ? typeof s.nlink === 'bigint' && s.nlink > 0n : s.nlink === 1n),
        `${nativeTool ? 'Ordinary positive-link native tool' : 'Ordinary single-link file/directory'} required: ${current}`);
    } else assert.ok(s.isDirectory(), `Ordinary directory required: ${current}`);
    if (current === resolved) leaf = s;
    const parent = path.dirname(current);
    if (parent === current) break;
    current = parent;
  }
  const fold = value => process.platform === 'win32' ? value.toLowerCase() : value;
  assert.equal(fold(fs.realpathSync.native(file)), fold(path.resolve(file)), 'Input path alias.');
  return leaf;
}

export function ordinary(file, directory = false) {
  return ordinaryPath(file, directory, false);
}

// Native tools may have multiple hard links. Private inputs retain single-link checks.
export function ordinaryNativeTool(file) {
  return ordinaryPath(file, false, true);
}

function readFileBounded(file, maximum, inspect) {
  assert.ok(Number.isSafeInteger(maximum) && maximum >= 0, 'A nonnegative safe byte bound is required.');
  const before = inspect(file);
  assert.ok(typeof before.size === 'bigint' && before.size >= 0n && before.size <= BigInt(maximum), `Input exceeds ${maximum} bytes.`);
  const fd = fs.openSync(file, fs.constants.O_RDONLY | (fs.constants.O_NOFOLLOW ?? 0));
  try {
    const opened = fs.fstatSync(fd, { bigint: true });
    assert.ok(opened.isFile(), 'Regular open input required.');
    for (const key of ['ino', 'dev', 'size', 'mtimeNs', 'nlink']) assert.equal(opened[key], before[key], 'Changed opened input.');
    const bytes = Buffer.alloc(Number(opened.size));
    let offset = 0;
    while (offset < bytes.length) {
      const n = fs.readSync(fd, bytes, offset, bytes.length - offset, offset);
      assert.ok(n > 0, 'Truncated input.'); offset += n;
    }
    const after = inspect(file);
    for (const key of ['ino', 'dev', 'size', 'mtimeNs', 'nlink']) assert.equal(after[key], before[key], 'Changed input.');
    const settled = fs.fstatSync(fd, { bigint: true });
    assert.ok(settled.isFile(), 'Regular settled input required.');
    for (const key of ['ino', 'dev', 'size', 'mtimeNs', 'nlink']) assert.equal(settled[key], opened[key], 'Changed open input.');
    return bytes;
  } finally { fs.closeSync(fd); }
}

export function readBounded(file, maximum = 1048576) {
  return readFileBounded(file, maximum, ordinary);
}

export function readNativeToolBounded(file, maximum = 1048576) {
  return readFileBounded(file, maximum, ordinaryNativeTool);
}

export function declarations(root) {
  const packageBytes = readBounded(path.join(root, 'package.json'));
  const pinBytes = readBounded(path.join(root, '.github/workflows/ci-toolchain.json'), 16384);
  const pkg = readJsonBytes(packageBytes, 'native-package'), pin = readJsonBytes(pinBytes, 'native-pin');
  assert.equal(pin.schemaVersion, 2);
  assert.deepEqual(Object.keys(pin).sort(), ['preferred', 'recoveryCompatibility', 'schemaVersion']);
  assert.deepEqual(Object.keys(pin.preferred).sort(), ['linuxX64Sha256', 'windowsX64Sha256']);
  assert.deepEqual(Object.keys(pin.recoveryCompatibility).sort(), ['linuxX64Sha256', 'node', 'npm']);
  assert.match(pkg.engines.node, /^24\.\d+\.\d+$/u); assert.match(pkg.engines.npm, /^\d+\.\d+\.\d+$/u);
  assert.equal(pin.recoveryCompatibility.node, '22.23.3'); assert.equal(pin.recoveryCompatibility.npm, '10.9.9');
  for (const hash of [pin.preferred.linuxX64Sha256, pin.preferred.windowsX64Sha256, pin.recoveryCompatibility.linuxX64Sha256]) {
    assert.match(hash, /^[a-f0-9]{64}$/u);
  }
  return { pkg, pin, identities: { package: digest(packageBytes), pin: digest(pinBytes) } };
}

export function archiveInput(directory, declaration, platform) {
  ordinary(directory, true);
  assert.ok(['linux', 'win32'].includes(platform), 'Native Linux/Windows only.');
  const version = platform === 'win32' ? declaration.pkg.engines.node : declaration.pin.recoveryCompatibility.node;
  const suffix = platform === 'win32' ? 'win-x64.zip' : 'linux-x64.tar.xz';
  const filename = `node-v${version}-${suffix}`;
  const hash = platform === 'win32' ? declaration.pin.preferred.windowsX64Sha256 : declaration.pin.recoveryCompatibility.linuxX64Sha256;
  const file = path.join(directory, filename), bytes = readBounded(file, 67108864);
  assert.equal(digest(bytes), hash, `Wrong official archive: ${filename}`);
  return { file, filename, sha256: hash, bytes };
}

export function options(args) {
  assert.equal(args.length, 4, 'Use --archive-directory ABSOLUTE_PATH --powershell ABSOLUTE_EXECUTABLE.');
  const result = {};
  for (let i = 0; i < args.length; i += 2) {
    assert.ok(['--archive-directory', '--powershell'].includes(args[i]), 'Unknown argument.');
    assert.ok(!Object.hasOwn(result, args[i]), 'Repeated argument.');
    assert.ok(path.isAbsolute(args[i + 1]) && !/[\r\n\0]/u.test(args[i + 1]), 'Absolute ordinary path required.');
    result[args[i]] = args[i + 1];
  }
  assert.equal(Object.keys(result).length, 2);
  return { archiveDirectory: result['--archive-directory'], powershell: result['--powershell'] };
}

export function complete(result, label) {
  assert.equal(result.error, undefined, `${label}: launch/watchdog failure`);
  assert.equal(result.signal, null, `${label}: interrupted child`);
  assert.equal(result.expired ?? false, false, `${label}: watchdog expired`);
  assert.equal(result.overflow ?? false, false, `${label}: output bound exceeded`);
  assert.ok(Number.isInteger(result.status), `${label}: missing native exit`);
  return result;
}

const clock = { set: (callback, delay) => setTimeout(callback, delay), clear: timer => clearTimeout(timer), now: () => performance.now() };
const shortError = error => ({ code: String(error?.code ?? 'UNKNOWN').slice(0, 64), message: String(error?.message ?? error).slice(0, 512) });
export function resourceFailure(message, resourceEvidence) {
  const error = new Error(message); error.resourceEvidence = resourceEvidence; return error;
}
function detachHandles(child) {
  // This only releases this Node process's handles. It is NEVER settlement proof.
  const errors = [];
  child.on('error', () => {});
  // Attach to every stream before destroying any: destruction may synchronously
  // emit an error, and an already queued error may arrive after detachment.
  for (const stream of [child.stdin, child.stdout, child.stderr]) stream?.on('error', () => {});
  for (const stream of [child.stdin, child.stdout, child.stderr]) {
    try { stream?.destroy(); } catch (error) { errors.push(shortError(error)); }
  }
  try { child.unref(); } catch (error) { errors.push(shortError(error)); }
  return errors;
}

// One finite termination helper, not a recursive invocation of native(). The
// optional primitives are only used by hermetic tests, never selected by the CLI.
export async function cancelOwnedChild(child, { platform = process.platform, start = spawn,
  systemRoot = process.env.SystemRoot, killGroup = pid => process.kill(-pid, 'SIGKILL'), timers = clock } = {}) {
  if (!child.pid || child.exitCode !== null || child.signalCode !== null) {
    return { method: 'not-targeted', reason: 'no-live-owned-direct-child', success: false };
  }
  if (platform !== 'win32') {
    try { killGroup(child.pid); return { method: 'owned-process-group', signal: 'SIGKILL', success: true }; }
    catch (error) { return { method: 'owned-process-group', error: shortError(error), success: false }; }
  }
  return await new Promise(resolve => {
    let helper, finished = false, timer, exit = null, error, overflow = false, size = 0;
    const records = [], listeners = [];
    const on = (target, event, handler) => { target?.on(event, handler); if (target) listeners.push([target, event, handler]); };
    const finish = (closed, expired) => {
      if (finished) return; finished = true; timers.clear(timer);
      for (const [target, event, handler] of listeners) target.removeListener(event, handler);
      let stopRequested = null, detachErrors = [];
      if (!closed && helper) {
        if (helper.pid && !exit && helper.exitCode === null && helper.signalCode === null) {
          try { stopRequested = helper.kill('SIGKILL'); } catch (failure) { error ??= shortError(failure); }
        }
        detachErrors = detachHandles(helper);
      }
      resolve({ method: 'taskkill', pid: helper?.pid ?? null, exit, closed, expired, overflow,
        error: error ?? null, output: Buffer.concat(records).toString('utf8'), detachedHandles: !closed,
        stopRequested, detachErrors, success: closed && !expired && !overflow && !error && exit?.status === 0 && exit.signal === null });
    };
    timer = timers.set(() => finish(false, true), 5000);
    try {
      helper = start(path.join(systemRoot, 'System32/taskkill.exe'), ['/PID', String(child.pid), '/T', '/F'],
        { windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'] });
      const collect = bytes => {
        size += bytes.length;
        if (size > 16384) { overflow = true; finish(false, false); } else records.push(Buffer.from(bytes));
      };
      on(helper.stdout, 'data', collect); on(helper.stderr, 'data', collect);
      for (const name of ['stdout', 'stderr']) on(helper[name], 'error', failure => {
        error = { ...shortError(failure), stream: name }; finish(false, false);
      });
      on(helper, 'error', failure => { error = shortError(failure); finish(false, false); });
      on(helper, 'exit', (status, signal) => { exit = { status, signal }; });
      on(helper, 'close', () => finish(true, false));
    } catch (failure) { error = shortError(failure); finish(false, false); }
  });
}

// Observe the already-created owned child. Injected clocks/cancellation below
// let pure tests cover missing events; they are not runtime switches.
export function observeNativeChild(child, { command, milliseconds = 180000, binary = false, input,
  cancel = () => cancelOwnedChild(child), timers = clock } = {}) {
  const started = timers.now();
  return new Promise((resolve, reject) => {
    const listeners = [], activeTimers = new Set(), output = [], errors = [];
    const streams = { stdin: false, stdout: false, stderr: false };
    let outputSize = 0, errorSize = 0, launched = false, exit = null, close = null, failure = null;
    let expired = false, overflow = false, error, termination = null, terminationComplete = false, finished = false;
    let executionTimer, drainTimer;
    const on = (target, event, handler) => { target?.on(event, handler); if (target) listeners.push([target, event, handler]); };
    const later = (callback, delay) => {
      const timer = timers.set(() => { activeTimers.delete(timer); callback(); }, delay); activeTimers.add(timer); return timer;
    };
    const clear = timer => { if (timer !== undefined) { timers.clear(timer); activeTimers.delete(timer); } };
    const finish = forced => {
      if (finished) return; finished = true;
      for (const timer of activeTimers) timers.clear(timer); activeTimers.clear();
      for (const [target, event, handler] of listeners) target.removeListener(event, handler);
      const detachedHandles = Boolean(forced && !close);
      const detachErrors = detachedHandles ? detachHandles(child) : [];
      const lifetime = { pid: child.pid ?? null, launched, exit, close, streams, termination,
        detachedHandles, detachErrors, settlementExpired: Boolean(forced), cleanup: failure ? 'unproved' : 'natural-direct-child-and-stdio' };
      if (failure) {
        reject(resourceFailure(`${command}: ${failure}; fixture retained, no next case`, { ...lifetime, error: error ?? null, expired, overflow }));
      } else {
        const result = { status: exit.status, signal: exit.signal, stdout: binary ? Buffer.concat(output) : Buffer.concat(output).toString('utf8'),
          stderr: Buffer.concat(errors).toString('utf8'), expired, overflow, elapsedMs: timers.now() - started, lifetime };
        resolve(complete(result, command));
      }
    };
    const check = () => {
      if (finished || !close) return;
      if (failure) { if (terminationComplete) finish(false); }
      else if (exit) finish(false);
    };
    const fail = reason => {
      if (failure || finished) return;
      failure = reason; clear(executionTimer); clear(drainTimer);
      // This timer is armed before invoking termination; it bounds even a
      // cancellation callback that never produces its own terminal event.
      later(() => finish(true), 10000);
      Promise.resolve().then(cancel).then(value => {
        termination = value; terminationComplete = true; check();
      }, value => {
        termination = { success: false, error: shortError(value) }; terminationComplete = true; check();
      });
    };
    const collect = (bytes, stderr) => {
      if (finished || overflow) return;
      if (stderr) errorSize += bytes.length; else outputSize += bytes.length;
      if (Math.max(outputSize, errorSize) > 1048576) { overflow = true; fail('output-bound'); }
      else (stderr ? errors : output).push(Buffer.from(bytes));
    };
    on(child, 'spawn', () => { launched = true; });
    on(child, 'error', value => { error ??= shortError(value); fail('launch-or-process-error'); });
    on(child, 'exit', (status, signal) => {
      exit = { status, signal }; clear(executionTimer);
      if (signal !== null || !Number.isInteger(status)) fail('interrupted-or-missing-native-exit');
      else if (!failure && !close) drainTimer = later(() => fail('stdio-drain-timeout'), 5000);
      check();
    });
    on(child, 'close', (status, signal) => {
      close = { status, signal }; clear(drainTimer);
      if (!launched || !exit || exit.status !== status || exit.signal !== signal) fail('missing-or-inconsistent-launch-or-exit');
      check();
    });
    on(child.stdout, 'data', bytes => collect(bytes, false)); on(child.stderr, 'data', bytes => collect(bytes, true));
    for (const name of Object.keys(streams)) on(child[name], 'close', () => { streams[name] = true; });
    for (const name of Object.keys(streams)) on(child[name], 'error', value => {
      error ??= { ...shortError(value), stream: name }; fail(`${name}-error`);
    });
    executionTimer = later(() => { expired = true; fail('execution-timeout'); }, milliseconds);
    try { child.stdin?.end(input); } catch (value) { error ??= { ...shortError(value), stream: 'stdin' }; fail('stdin-error'); }
  });
}

// The caller remains asynchronous so its own loopback server can make progress.
export async function native(command, args, { cwd, env, milliseconds = 180000, input, binary = false } = {}) {
  let child;
  try { child = spawn(command, args, { cwd, env, windowsHide: true, detached: process.platform !== 'win32', stdio: ['pipe', 'pipe', 'pipe'] }); }
  catch (error) { throw resourceFailure(`${command}: launch failed`, { error: shortError(error), pid: null, cleanup: 'unproved' }); }
  return await observeNativeChild(child, { command, milliseconds, input, binary });
}

export function verifySuite(result, platform) {
  const cases = platform === 'win32' ? windowsCases : platform === 'linux' ? linuxCases : [];
  assert.ok(cases.length, 'Unsupported native platform.');
  assert.equal(result.schema, 'StyleGuide.NativeDownloadResult.v1');
  assert.equal(result.platform, platform); assert.equal(result.failed, 0); assert.equal(result.skipped, 0);
  assert.equal(result.passed, cases.length); assert.deepEqual(result.cases.map(row => row.name), cases);
  for (const row of result.cases) {
    assert.equal(row.passed, true); assert.equal(row.cleanup, true);
    complete(row.caller, row.name); assert.ok(row.witnesses.length > 0);
    for (const witness of row.witnesses) complete(witness, row.name);
  }
  return result;
}

export function originalArguments(role, declaration, platform, runner) {
  const version = role === 'preferred' ? declaration.pkg.engines.node : declaration.pin.recoveryCompatibility.node;
  const target = platform === 'win32' ? 'win-x64' : 'linux-x64';
  const suffix = platform === 'win32' ? 'zip' : 'tar.xz';
  return ['--disable', '--silent', '--show-error', '--fail', '--location', '--proto', '=https',
    '--proto-redir', '=https', '--tlsv1.2', '--connect-timeout', '20', '--max-time', '180',
    '--retry', '2', '--retry-max-time', '300', '--max-filesize', '67108864', '--output',
    path.join(runner, 'styleguide-node', `${role}.${suffix}`),
    `https://nodejs.org/dist/v${version}/node-v${version}-${target}.${suffix}`];
}

export function adaptedArguments(original, endpoint, mode) {
  const args = [...original];
  args[args.indexOf('--connect-timeout') + 1] = '1';
  args[args.indexOf('--max-time') + 1] = mode === 'tls-stall' ? '3'
    : ['transient', 'partial-recovery', 'wrong-version'].includes(mode) ? '60' : '1';
  if (mode !== 'tls-stall') {
    args[args.indexOf('--proto') + 1] = '=http'; args[args.indexOf('--proto-redir') + 1] = '=http';
  }
  args[args.length - 1] = endpoint + '/archive';
  return args;
}

export const windowsRetryAfter = (platform, mode) => platform === 'win32'
  && ['retry-after-number', 'retry-after-date'].includes(mode);

// curl 8.21.0 returns zero when Retry-After exceeds --retry-max-time.
// A native zero is an observation, never evidence that the caller succeeded.
export function assertRetryAfterRefusal({ platform, mode, caller, witness, requests, phases,
  pathBytes, envBytes, runtimeExists }) {
  assert.ok(windowsRetryAfter(platform, mode), 'Only Windows long Retry-After cases qualify.');
  complete(caller, mode); complete(witness, mode);
  assert.notEqual(caller.status, 0, 'The complete initializer must refuse the failed acquisition.');
  assert.equal(witness.controlled, false);
  assert.ok([0, 22].includes(witness.status), 'Unexpected Retry-After native status.');
  assert.ok(Number.isFinite(witness.elapsedMs) && witness.elapsedMs >= 0 && witness.elapsedMs < 10000,
    'Long Retry-After must not consume the retry delay.');
  assert.equal(requests.length, 1);
  const response = requests[0];
  assert.equal(response.url, '/archive'); assert.equal(response.ambient, null);
  assert.equal(response.responseStatus, 503);
  assert.ok(Number.isFinite(response.respondedAt));
  if (mode === 'retry-after-number') assert.equal(response.retryAfter, '600');
  else {
    const delay = Date.parse(response.retryAfter) - response.respondedAt;
    assert.ok(Number.isFinite(delay) && delay > 599000 && delay <= 600000, 'Expected the six-hundred-second HTTP date.');
  }
  assert.ok(phases.includes('channels-held'));
  if (witness.status === 0) assert.ok(phases.includes('archive-admission:preferred'),
    'A zero native status must reach the unchanged archive guard.');
  assert.equal(phases.some(phase => /^(?:expand:|node:|npm:|publication$)/u.test(phase)), false);
  for (const bytes of [pathBytes, envBytes]) assert.ok(Buffer.isBuffer(bytes) && bytes.length === 0);
  assert.equal(runtimeExists, false, 'Owned runtime cleanup must finish.');
}

// Retained single-write canonical witness admission, extended only for the
// complete-caller role, argv and held-channel fields. Producer checks are not
// authority: all expected identities come from the parent case/host context.
export function assertCurlWitness(bytes, expected) {
  assert.ok(Buffer.isBuffer(bytes) && bytes.length > 0 && bytes.length <= 4096, 'Bounded curl witness required.');
  const text = bytes.toString('utf8');
  assert.ok(Buffer.from(text, 'utf8').equals(bytes), 'Invalid witness UTF-8.');
  const result = JSON.parse(text);
  assert.ok(result && typeof result === 'object' && !Array.isArray(result), 'Witness must be an object.');
  assert.equal(JSON.stringify(result), text, 'Noncanonical or duplicate witness field.');
  assert.ok(['linux', 'win32'].includes(expected.platform));
  assert.ok((expected.platform === 'win32' ? windowsCases : linuxCases).includes(expected.mode));
  assert.ok(['preferred', 'recoveryCompatibility'].includes(expected.role));
  if (expected.platform === 'win32') assert.equal(expected.role, 'preferred');
  const controlled = expected.platform === 'linux' && expected.role === 'preferred';
  assert.deepEqual(Object.keys(result).sort(), ['status', 'signal', 'controlled', 'role', 'mode', 'command', 'commandSha256',
    'channels', 'original', 'adapted', ...(controlled ? [] : ['elapsedMs']), ...(Object.hasOwn(result, 'error') ? ['error'] : [])].sort(), 'Unexpected witness fields.');
  for (const name of ['mode', 'role', 'command', 'commandSha256']) assert.equal(result[name], expected[name], `Wrong witness ${name}.`);
  assert.match(result.commandSha256, /^[0-9a-f]{64}$/u);
  assert.equal(result.controlled, controlled, 'Controlled/native witness confusion.');
  assert.deepEqual(result.original, expected.original, 'Wrong original curl arguments.');
  assert.deepEqual(result.adapted, controlled ? null : expected.adapted, 'Wrong adapted curl arguments.');
  if (controlled) assert.equal(expected.adapted, null);
  else assert.ok(Number.isFinite(result.elapsedMs) && result.elapsedMs >= 0, 'Missing finite native elapsed observation.');
  assert.ok(Array.isArray(result.channels)); assert.equal(result.channels.length, 2);
  for (const [index, channel] of result.channels.entries()) {
    assert.ok(channel && typeof channel === 'object' && !Array.isArray(channel));
    assert.deepEqual(Object.keys(channel).sort(), (expected.platform === 'win32' ? ['name', 'held', 'code'] : ['name', 'empty']).sort());
    assert.equal(channel.name, ['path', 'env'][index]);
    if (expected.platform === 'win32') {
      assert.equal(channel.held, true); assert.ok(['EBUSY', 'EACCES', 'EPERM'].includes(channel.code));
    } else assert.equal(channel.empty, true);
  }
  if (Object.hasOwn(result, 'error')) {
    assert.deepEqual(Object.keys(result.error).sort(), ['code', 'message']);
    assert.equal(typeof result.error.code, 'string'); assert.equal(typeof result.error.message, 'string');
  }
  complete(result, 'curl witness');
  const retryAfterZero = !controlled && windowsRetryAfter(expected.platform, expected.mode)
    && expected.status === 22 && result.status === 0;
  assert.ok(retryAfterZero || result.status === (controlled ? 0 : expected.status), 'Unexpected native curl status.');
  return result;
}

export function readCurlWitness(file, expected) {
  return assertCurlWitness(readBounded(file, 4096), expected);
}

// Called only by the small generated private dispatch file, never on module import.
export function adapterMain(configPath, role, command, original) {
  const config = JSON.parse(readBounded(configPath));
  assert.ok(['preferred', 'recoveryCompatibility'].includes(role));
  assert.deepEqual(original, originalArguments(role, config.declaration, config.platform, config.runner));
  assert.equal(command, config.curl);
  const commandSha256 = digest(readNativeToolBounded(command, 16777216));
  assert.equal(commandSha256, config.curlSha256);
  const witness = path.join(config.root, `curl-${role}.json`);
  assert.equal(fs.existsSync(witness), false);
  const channels = ['path', 'env'].map(name => {
    const file = path.join(config.runner, '_runner_file_commands', name);
    if (config.platform !== 'win32') {
      assert.equal(readBounded(file).length, 0, 'Channels must remain unpublished during acquisition.');
      return { name, empty: true };
    }
    let fd;
    try { fd = fs.openSync(file, 'r'); }
    catch (error) {
      assert.ok(['EBUSY', 'EACCES', 'EPERM'].includes(error.code), 'Unexpected channel read failure.');
      return { name, held: true, code: error.code };
    }
    finally { if (fd !== undefined) fs.closeSync(fd); }
    assert.fail('Windows channel was not held exclusively during acquisition.');
  });
  let result, args;
  if (config.platform === 'linux' && role === 'preferred') {
    const bytes = readBounded(config.preferredArchive, 65536);
    fs.writeFileSync(original.at(-2), bytes, { flag: 'wx', mode: 0o600 });
    result = { status: 0, signal: null, controlled: true };
  } else {
    args = adaptedArguments(original, config.endpoint, config.mode);
    const started = performance.now();
    const observed = spawnSync(command, args, { stdio: 'inherit', windowsHide: true, timeout: 190000,
      env: { ...process.env, NO_PROXY: '127.0.0.1', no_proxy: '127.0.0.1' } });
    result = { status: observed.status, signal: observed.signal, controlled: false, elapsedMs: performance.now() - started };
    if (observed.error) result.error = { code: observed.error.code, message: observed.error.message };
  }
  const witnessBytes = JSON.stringify({ ...result, role, mode: config.mode, command, commandSha256, channels, original, adapted: args ?? null });
  assert.ok(Buffer.byteLength(witnessBytes) <= 4096, 'Curl witness exceeds its retained bound.');
  fs.writeFileSync(witness, witnessBytes,
    { flag: 'wx', mode: 0o600 });
  complete(result, 'native curl');
  assert.equal(digest(readNativeToolBounded(command, 16777216)), commandSha256, 'Native curl changed.');
  return result.status;
}

// Shared unchanged bounded USTAR producer from the maintained foundation fixtures.
export function foundationTar(entries) {
  const blocks = [];
  for (const { name, data = Buffer.alloc(0), type = '0', target = '', mode = 0o755 } of entries) {
    assert.ok(Buffer.byteLength(name) < 100 && Buffer.byteLength(target) < 100);
    assert.ok(data.length <= 32768);
    const header = Buffer.alloc(512);
    const text = (offset, value, length) => { assert.ok(Buffer.byteLength(value) <= length); header.write(value, offset, length, 'ascii'); };
    const octal = (offset, value, length) => text(offset, value.toString(8).padStart(length - 1, '0') + '\0', length);
    text(0, name, 100); octal(100, mode, 8); octal(108, 1000, 8); octal(116, 1000, 8);
    octal(124, data.length, 12); octal(136, 0, 12); header.fill(32, 148, 156);
    text(156, type, 1); text(157, target, 100); text(257, 'ustar\0', 6); text(263, '00', 2);
    octal(329, type === '3' ? 1 : 0, 8); octal(337, type === '3' ? 3 : 0, 8);
    const checksum = header.reduce((total, value) => total + value, 0);
    text(148, checksum.toString(8).padStart(6, '0') + '\0 ', 8);
    blocks.push(header, data, Buffer.alloc((512 - data.length % 512) % 512));
  }
  blocks.push(Buffer.alloc(1024));
  const bytes = Buffer.concat(blocks);
  assert.ok(bytes.length <= 65536, 'Synthetic archives are finite, not stress data.');
  return bytes;
}
