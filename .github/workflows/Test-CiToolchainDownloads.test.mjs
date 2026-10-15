// Hermetic contracts only. Official archives/native installer cases require the explicit CLI.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';
import { EventEmitter } from 'node:events';
import { adaptedArguments, archiveInput, complete, declarations, digest, foundationTar,
  linuxCases, once, options, ordinary, ordinaryNativeTool, originalArguments, readBounded, readNativeToolBounded, verifySuite, windowsCases,
  assertCurlWitness, assertRetryAfterRefusal, cancelOwnedChild, observeNativeChild, readCurlWitness } from './CiToolchainDownloadFixtures.mjs';
import { endpoint, instrument, withDownloadEndpoint } from './Test-CiToolchainDownloads.mjs';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const pins = declarations(root);

const changedStat = (value, changes) => Object.assign(Object.create(Object.getPrototypeOf(value)), value, changes);

test('native tool reader: actual hardlinks are accepted only through the native role', () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'a04-native-reader-')), file = path.join(directory, 'tool');
  const alias = path.join(directory, 'tool-hardlink'), bytes = Buffer.from('private native tool fixture\0');
  try {
    fs.writeFileSync(file, bytes); fs.linkSync(file, alias);
    assert.equal(fs.lstatSync(file).nlink, 2);
    for (const name of [file, alias]) {
      assert.equal(ordinaryNativeTool(name).nlink, 2n);
      assert.deepEqual(readNativeToolBounded(name, bytes.length), bytes);
      assert.throws(() => ordinary(name), /single-link/u);
      assert.throws(() => readBounded(name, bytes.length), /single-link/u);
      assert.throws(() => readBounded(name, bytes.length, true), /single-link/u);
    }
    fs.linkSync(file, path.join(directory, 'tool-third-link'));
    assert.equal(ordinaryNativeTool(file).nlink, 3n);
    assert.deepEqual(readNativeToolBounded(file, bytes.length), bytes);
  } finally { fs.rmSync(directory, { recursive: true }); }
});

test('native tool reader: bounds, truncation and rejected file types remain fail-closed', t => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'a04-native-reader-')), file = path.join(directory, 'tool');
  try {
    fs.writeFileSync(file, 'fixture');
    for (const read of [readBounded, readNativeToolBounded]) {
      assert.deepEqual(read(file, 7), Buffer.from('fixture'));
      assert.throws(() => read(file, 6), /exceeds 6 bytes/u);
      for (const maximum of [-1, 0.5, NaN, Infinity]) assert.throws(() => read(file, maximum), /byte bound/u);
      assert.throws(() => read(directory), /required/u);
      assert.throws(() => read('relative-tool'), /absolute path/u);
      assert.throws(() => read(path.join(directory, 'missing')), /ENOENT/u);
      const truncated = t.mock.method(fs, 'readSync', () => 0);
      assert.throws(() => read(file), /Truncated input/u); truncated.mock.restore();
    }
    const lstat = fs.lstatSync;
    for (const changes of [{ nlink: 0n }, { nlink: -1n }, { nlink: 0.5 }, { isFile: () => false }]) {
      const invalid = t.mock.method(fs, 'lstatSync', (...args) => args[0] === file
        ? changedStat(lstat(...args), changes) : lstat(...args));
      assert.throws(() => ordinaryNativeTool(file), /native tool required/u);
      assert.throws(() => readNativeToolBounded(file), /native tool required/u); invalid.mock.restore();
    }
  } finally { t.mock.restoreAll(); fs.rmSync(directory, { recursive: true }); }
});

test('native tool reader: leaf and ancestor aliases and resolved-path changes are rejected', t => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'a04-native-reader-')), file = path.join(directory, 'tool');
  try {
    fs.writeFileSync(file, 'fixture');
    const lstat = fs.lstatSync;
    for (const target of [file, directory, path.dirname(directory)]) {
      const alias = t.mock.method(fs, 'lstatSync', (...args) => args[0] === target
        ? changedStat(lstat(...args), { isSymbolicLink: () => true }) : lstat(...args));
      for (const read of [readBounded, readNativeToolBounded]) assert.throws(() => read(file), /Aliased input/u);
      alias.mock.restore();
    }
    const ancestor = t.mock.method(fs, 'lstatSync', (...args) => args[0] === directory
      ? changedStat(lstat(...args), { isDirectory: () => false }) : lstat(...args));
    assert.throws(() => readNativeToolBounded(file), /directory required/u); ancestor.mock.restore();
    const realpath = t.mock.method(fs.realpathSync, 'native', () => path.join(directory, 'other-tool'));
    for (const read of [readBounded, readNativeToolBounded]) assert.throws(() => read(file), /Input path alias/u);
    realpath.mock.restore();
  } finally { t.mock.restoreAll(); fs.rmSync(directory, { recursive: true }); }
});

test('native tool reader: sampled path and descriptor changes reject every identity field and close the descriptor', t => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'a04-native-reader-')), file = path.join(directory, 'tool');
  try {
    fs.writeFileSync(file, 'fixture'); fs.linkSync(file, path.join(directory, 'tool-hardlink'));
    const numeric = fs.lstatSync(file), precise = fs.lstatSync(file, { bigint: true });
    t.diagnostic(JSON.stringify({ numberIno: numeric.ino, bigintIno: String(precise.ino),
      numberAsBigInt: String(BigInt(numeric.ino)), numberIsSafeInteger: Number.isSafeInteger(numeric.ino) }));
    const lstat = fs.lstatSync, fstat = fs.fstatSync, open = fs.openSync;
    for (const phase of ['opened', 'path-after', 'settled']) for (const key of ['ino', 'dev', 'size', 'mtimeNs', 'nlink']) {
      let samples = 0, descriptor;
      const capture = t.mock.method(fs, 'openSync', (...args) => { descriptor = open(...args); return descriptor; });
      const changed = phase === 'path-after'
        ? t.mock.method(fs, 'lstatSync', (...args) => {
          const value = lstat(...args);
          return args[0] === file && ++samples === 2
            ? changedStat(value, { [key]: value[key] + 1n }) : value;
        })
        : t.mock.method(fs, 'fstatSync', (...args) => {
          const value = fstat(...args);
          return ++samples === (phase === 'opened' ? 1 : 2)
            ? changedStat(value, { [key]: value[key] + 1n }) : value;
        });
      assert.throws(() => readNativeToolBounded(file), /Changed (?:opened |open )?input/u, `${phase}: ${key}`);
      changed.mock.restore(); capture.mock.restore();
      assert.throws(() => fstat(descriptor), /EBADF/u, `${phase}: ${key} must close`);
    }
    for (const sample of [1, 2]) {
      let calls = 0;
      const type = t.mock.method(fs, 'fstatSync', (...args) => {
        const value = fstat(...args); return ++calls === sample ? changedStat(value, { isFile: () => false }) : value;
      });
      assert.throws(() => readNativeToolBounded(file), /Regular (?:open|settled) input required/u); type.mock.restore();
    }
  } finally { t.mock.restoreAll(); fs.rmSync(directory, { recursive: true }); }
});

test('exact reader identity: adjacent large inode and device values fail at each sample for both roles', t => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'a04-exact-reader-')), file = path.join(directory, 'tool');
  try {
    fs.writeFileSync(file, 'fixture');
    const base = 9007199254740992n;
    assert.equal(Number(base), Number(base + 1n), 'The negative control must collide as Numbers.');
    const lstat = fs.lstatSync, fstat = fs.fstatSync, open = fs.openSync;
    for (const read of [readBounded, readNativeToolBounded]) for (const phase of ['unchanged', 'before', 'opened', 'path-after', 'settled']) {
      for (const key of ['ino', 'dev']) {
        let paths = 0, descriptors = 0, descriptor;
        const capture = t.mock.method(fs, 'openSync', (...args) => { descriptor = open(...args); return descriptor; });
        const pathSample = t.mock.method(fs, 'lstatSync', (...args) => {
          assert.deepEqual(args[1], { bigint: true });
          const value = lstat(...args);
          if (args[0] !== file) return value;
          paths++;
          const changed = phase === 'before' && paths === 1 || phase === 'path-after' && paths === 2;
          return changedStat(value, { ino: base, dev: base, ...(changed ? { [key]: base + 1n } : {}) });
        });
        const descriptorSample = t.mock.method(fs, 'fstatSync', (...args) => {
          assert.deepEqual(args[1], { bigint: true });
          const value = fstat(...args);
          descriptors++;
          const changed = phase === 'opened' && descriptors === 1 || phase === 'settled' && descriptors === 2;
          return changedStat(value, { ino: base, dev: base, ...(changed ? { [key]: base + 1n } : {}) });
        });
        if (phase === 'unchanged') assert.deepEqual(read(file), Buffer.from('fixture'), `${read.name}: stable large identity`);
        else assert.throws(() => read(file), /Changed (?:opened |open )?input/u, `${read.name}: ${phase}: ${key}`);
        descriptorSample.mock.restore(); pathSample.mock.restore(); capture.mock.restore();
        assert.throws(() => fstat(descriptor), /EBADF/u, `${read.name}: ${phase}: ${key} must close`);
      }
    }
  } finally { t.mock.restoreAll(); fs.rmSync(directory, { recursive: true }); }
});

test('exact reader identity: directory metadata stays BigInt and oversized files reject before allocation', t => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'a04-exact-reader-')), file = path.join(directory, 'tool');
  try {
    fs.writeFileSync(file, 'fixture');
    const identity = ordinary(directory, true), actual = fs.lstatSync(directory, { bigint: true });
    for (const key of ['ino', 'dev', 'size', 'mtimeNs', 'nlink']) {
      assert.equal(typeof identity[key], 'bigint'); assert.equal(identity[key], actual[key]);
    }
    assert.deepEqual(readBounded(file, 7), Buffer.from('fixture'));
    assert.deepEqual(readNativeToolBounded(file, 7), Buffer.from('fixture'));
    const lstat = fs.lstatSync;
    const tooLarge = t.mock.method(fs, 'lstatSync', (...args) => args[0] === file
      ? changedStat(lstat(...args), { size: BigInt(Number.MAX_SAFE_INTEGER) + 1n }) : lstat(...args));
    const open = t.mock.method(fs, 'openSync', () => { throw Error('An oversized file must not be opened.'); });
    for (const read of [readBounded, readNativeToolBounded]) assert.throws(() => read(file, Number.MAX_SAFE_INTEGER), /Input exceeds/u);
    assert.equal(open.mock.calls.length, 0); open.mock.restore(); tooLarge.mock.restore();
  } finally { t.mock.restoreAll(); fs.rmSync(directory, { recursive: true }); }
});

test('native downloads: exact independent 10/5 cases without implicit skip', () => {
  assert.deepEqual(windowsCases, ['tls-stall', 'transient', 'retry-after-number', 'retry-after-date',
    'stall', 'partial-stall', 'partial-recovery', 'exhaustion', 'short-eof', 'wrong-digest']);
  assert.deepEqual(linuxCases, ['partial-recovery', 'exhaustion', 'short-eof', 'wrong-digest', 'wrong-version']);
  for (const platform of ['win32', 'linux']) {
    const names = platform === 'win32' ? windowsCases : linuxCases;
    const result = { schema: 'StyleGuide.NativeDownloadResult.v1', platform, passed: names.length, failed: 0, skipped: 0,
      cases: names.map(name => ({ name, passed: true, cleanup: true, caller: { status: 0, signal: null }, witnesses: [{ status: 0, signal: null }] })) };
    verifySuite(result, platform);
    for (const mutate of [r => r.skipped++, r => r.failed++, r => r.cases.pop(), r => r.cases[0].cleanup = false,
      r => r.cases[0].caller.signal = 'SIGTERM', r => r.cases[0].witnesses = [], r => r.cases[0].witnesses[0].status = null]) {
      const changed = structuredClone(result); mutate(changed); assert.throws(() => verifySuite(changed, platform));
    }
  }
  assert.throws(() => verifySuite({}, 'darwin'));
});

test('native downloads: explicit arguments reject absent, duplicate, relative and extra inputs', () => {
  const args = ['--archive-directory', root, '--powershell', process.execPath];
  assert.deepEqual(options(args), { archiveDirectory: root, powershell: process.execPath });
  for (const invalid of [[], args.slice(0, 2), [...args, '--skip'], ['--archive-directory', '.', '--powershell', process.execPath],
    ['--powershell', root, '--powershell', process.execPath], ['--archive-directory', root, '--unknown', process.execPath]]) assert.throws(() => options(invalid));
});

test('native downloads: missing and wrong archives fail without fallback or acquisition', () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'a04-input-test-'));
  try {
    for (const platform of ['win32', 'linux']) {
      assert.throws(() => archiveInput(directory, pins, platform));
      const name = platform === 'win32' ? `node-v${pins.pkg.engines.node}-win-x64.zip`
        : `node-v${pins.pin.recoveryCompatibility.node}-linux-x64.tar.xz`;
      fs.writeFileSync(path.join(directory, name), 'incorrect archive', { flag: 'wx' });
      assert.throws(() => archiveInput(directory, pins, platform), /Wrong official archive/u);
    }
    const file = path.join(directory, 'bounded'); fs.writeFileSync(file, '12345');
    assert.throws(() => readBounded(file, 4)); assert.equal(readBounded(file, 5).toString(), '12345');
    fs.linkSync(file, path.join(directory, 'alias')); assert.throws(() => readBounded(file, 5));
  } finally { fs.rmSync(directory, { recursive: true }); }
});

test('native downloads: original curl argv and private adaptation remain distinct', () => {
  for (const platform of ['win32', 'linux']) {
    const role = platform === 'win32' ? 'preferred' : 'recoveryCompatibility';
    const original = originalArguments(role, pins, platform, root);
    assert.deepEqual(original.slice(0, 20), ['--disable', '--silent', '--show-error', '--fail', '--location', '--proto', '=https',
      '--proto-redir', '=https', '--tlsv1.2', '--connect-timeout', '20', '--max-time', '180', '--retry', '2', '--retry-max-time', '300', '--max-filesize', '67108864']);
    assert.match(original.at(-1), /^https:\/\/nodejs\.org\/dist\//u);
    const saved = [...original], tls = adaptedArguments(original, 'https://127.0.0.1:12345', 'tls-stall');
    assert.equal(tls[11], '1'); assert.equal(tls[13], '3'); assert.equal(tls[6], '=https');
    assert.equal(tls.at(-1), 'https://127.0.0.1:12345/archive');
    const stalled = adaptedArguments(original, 'http://127.0.0.1:12345', 'stall');
    assert.equal(stalled[13], '1'); assert.equal(stalled[6], '=http'); assert.deepEqual(original, saved);
  }
});

test('native downloads: watchdog, output, signal and missing native exit cannot pass', () => {
  for (const partial of [{ error: { code: 'ETIMEDOUT' } }, { signal: 'SIGTERM' }, { status: null }, { expired: true }, { overflow: true }]) {
    assert.throws(() => complete({ status: 0, signal: null, ...partial }, 'test'));
  }
  assert.equal(complete({ status: 28, signal: null }, 'expected curl failure').status, 28);
});

test('native downloads: complete caller instrumentation is exact and private', () => {
  const file = path.join(root, '.github/workflows/Initialize-CiToolchain.ps1'), original = readBounded(file);
  const changed = instrument(original.toString(), process.execPath, path.join(root, 'private-dispatch.mjs'), path.join(root, 'private-phases'));
  assert.match(changed, /Assert-CurlCapability -Path \$strCurlPath/u);
  assert.match(changed, /Test-CheckoutCredentials\.ps1/u);
  assert.equal(changed.split("'channels-held'").length, 2);
  assert.equal(changed.split('"archive-admission:$Role"').length, 2);
  const phaseWrites = changed.match(/^[ \t]*\[IO\.File\]::AppendAllText\('[^\n]*private-phases', [^\n]*\n"[^\n]*$/gmu) ?? [];
  assert.equal(phaseWrites.length, 7, 'Every original phase has exactly one private record write.');
  for (const line of phaseWrites) {
    assert.match(line, /, \[Text\.UTF8Encoding\]::new\(\$false\)\)$/u, 'Every phase record specifies UTF-8 without BOM.');
  }
  assert.equal(changed.split("'publication'").length, 2);
  assert.equal(digest(readBounded(file)), digest(original));
  assert.throws(() => once('missing', 'anchor', 'replacement'));
  assert.throws(() => once('anchor anchor', 'anchor', 'replacement'));
});

test('native downloads: shared USTAR producer preserves finite bounds and checksum', () => {
  const bytes = foundationTar([{ name: 'root/', type: '5' }, { name: 'root/node', data: Buffer.from('fixed') }]);
  assert.equal(bytes.length % 512, 0); assert.equal(bytes.subarray(257, 263).toString(), 'ustar\0');
  const header = Buffer.from(bytes.subarray(0, 512)), checksum = parseInt(header.subarray(148, 154).toString(), 8);
  header.fill(32, 148, 156); assert.equal(header.reduce((sum, value) => sum + value, 0), checksum);
  assert.throws(() => foundationTar([{ name: 'x'.repeat(100) }]));
  assert.throws(() => foundationTar([{ name: 'large', data: Buffer.alloc(32769) }]));
});

// Event and clock models exercise the repaired lifecycle without spawning a
// process, using taskkill, opening a socket or asserting native qualification.
function fakeClock() {
  let now = 0, serial = 0;
  const pending = new Map();
  return { pending, now: () => now, set: (fn, ms) => { const id = ++serial; pending.set(id, { fn, at: now + ms }); return id; },
    clear: id => pending.delete(id), tick(ms) {
      const end = now + ms;
      for (;;) {
        const first = [...pending].sort((a, b) => a[1].at - b[1].at)[0];
        if (!first || first[1].at > end) break;
        now = first[1].at; pending.delete(first[0]); first[1].fn();
      }
      now = end;
    } };
}
const microtasks = async () => { for (let i = 0; i < 5; i++) await Promise.resolve(); };
function fakeChild() {
  const child = new EventEmitter();
  Object.assign(child, { pid: 12345, exitCode: null, signalCode: null, unreferenced: false, kills: [],
    unref() { this.unreferenced = true; }, kill(signal) { this.kills.push(signal); return true; } });
  for (const name of ['stdin', 'stdout', 'stderr']) {
    const stream = new EventEmitter(); stream.end = () => {}; stream.destroy = () => { stream.destroyed = true; stream.emit('close'); };
    child[name] = stream;
  }
  child.exit = (status, signal = null) => { child.exitCode = status; child.signalCode = signal; child.emit('exit', status, signal); };
  child.close = (status = child.exitCode, signal = child.signalCode) => {
    for (const name of ['stdin', 'stdout', 'stderr']) child[name].emit('close');
    child.emit('close', status, signal);
  };
  return child;
}

test('native downloads repair: natural exit and stdio closure remain separate observations', async () => {
  const child = fakeChild(), timers = fakeClock(); let cancelled = 0, settled = false;
  const pending = observeNativeChild(child, { command: 'fixture', milliseconds: 100, timers, cancel: () => { cancelled++; } });
  pending.then(() => { settled = true; });
  child.emit('spawn'); child.stdout.emit('data', Buffer.from('output')); child.exit(18);
  await microtasks(); assert.equal(settled, false); assert.equal(timers.pending.size, 1);
  child.close(); const result = await pending;
  assert.equal(result.status, 18); assert.equal(result.stdout, 'output'); assert.equal(cancelled, 0);
  assert.deepEqual(result.lifetime.exit, { status: 18, signal: null });
  assert.deepEqual(result.lifetime.close, result.lifetime.exit);
  assert.equal(result.lifetime.detachedHandles, false); assert.equal(timers.pending.size, 0);
  child.emit('close', 18, null); timers.tick(20000); assert.equal(cancelled, 0);
});

test('native downloads repair: launch and output errors cannot become native refusals', async () => {
  for (const kind of ['launch', 'overflow', 'signal']) {
    const child = fakeChild(), timers = fakeClock();
    const pending = observeNativeChild(child, { command: 'fixture', timers, cancel: async () => ({ success: false, method: 'modeled' }) });
    const rejected = assert.rejects(pending, error => error.resourceEvidence.cleanup === 'unproved');
    if (kind === 'launch') { child.pid = undefined; child.emit('error', Object.assign(new Error('missing'), { code: 'ENOENT' })); child.close(-2, null); }
    else {
      child.emit('spawn');
      if (kind === 'overflow') child.stdout.emit('data', Buffer.alloc(1048577));
      child.exit(kind === 'signal' ? null : 0, kind === 'signal' ? 'SIGTERM' : null); child.close();
    }
    await rejected; assert.equal(timers.pending.size, 0);
  }
});

test('native downloads repair: unresolved cancellation returns bounded failure without cleanup credit', async () => {
  const child = fakeChild(), timers = fakeClock(); let nextCase = false;
  const pending = observeNativeChild(child, { command: 'fixture', milliseconds: 100, timers, cancel: () => new Promise(() => {}) });
  const rejected = assert.rejects(pending.then(() => { nextCase = true; }), error => {
    assert.equal(error.resourceEvidence.pid, 12345); assert.equal(error.resourceEvidence.exit, null);
    assert.equal(error.resourceEvidence.termination, null); assert.equal(error.resourceEvidence.detachedHandles, true);
    assert.equal(error.resourceEvidence.cleanup, 'unproved'); assert.equal(error.resourceEvidence.expired, true); return true;
  });
  child.emit('spawn'); timers.tick(100); await microtasks(); timers.tick(9999); assert.equal(child.unreferenced, false);
  timers.tick(1); await rejected;
  assert.equal(child.unreferenced, true); assert.equal(nextCase, false); assert.equal(timers.pending.size, 0);
});

test('native downloads repair: post-exit pipe expiry never targets the old direct PID', async () => {
  const child = fakeChild(), timers = fakeClock(); let starts = 0;
  const pending = observeNativeChild(child, { command: 'fixture', timers,
    cancel: () => cancelOwnedChild(child, { platform: 'win32', timers, start: () => { starts++; throw Error('must not launch'); } }) });
  const rejected = assert.rejects(pending, error => {
    assert.match(error.message, /stdio-drain-timeout/u); assert.equal(error.resourceEvidence.termination.method, 'not-targeted');
    assert.equal(error.resourceEvidence.cleanup, 'unproved'); return true;
  });
  child.emit('spawn'); child.exit(0); timers.tick(5000); await microtasks(); timers.tick(10000); await rejected;
  assert.equal(starts, 0); assert.equal(timers.pending.size, 0);
});

test('native downloads repair: timeout remains failed when exit races with failed termination', async () => {
  const child = fakeChild(), timers = fakeClock(); let cancel;
  const pending = observeNativeChild(child, { command: 'fixture', milliseconds: 100, timers,
    cancel: () => new Promise(resolve => { cancel = resolve; }) });
  const rejected = assert.rejects(pending, error => {
    assert.equal(error.resourceEvidence.expired, true);
    assert.equal(error.resourceEvidence.termination.success, false);
    assert.deepEqual(error.resourceEvidence.exit, { status: 0, signal: null });
    assert.equal(error.resourceEvidence.cleanup, 'unproved'); return true;
  });
  child.emit('spawn'); timers.tick(100); await microtasks(); child.exit(0); child.close();
  cancel({ success: false, method: 'modeled-denial' }); await rejected;
  assert.equal(timers.pending.size, 0); timers.tick(20000);
});

test('native downloads repair: Windows termination records completion, failure, hang and late pipe closure', async () => {
  for (const kind of ['success', 'failure', 'launch-error', 'hang', 'exited-with-open-pipe']) {
    const target = fakeChild(), helper = fakeChild(), timers = fakeClock(); let invocation;
    const pending = cancelOwnedChild(target, { platform: 'win32', systemRoot: path.parse(root).root, timers,
      start(command, args, settings) { invocation = { command, args, settings }; return helper; } });
    assert.deepEqual(invocation.args, ['/PID', '12345', '/T', '/F']);
    assert.ok(invocation.command.endsWith(path.join('System32', 'taskkill.exe')));
    if (kind === 'success' || kind === 'failure') { helper.exit(kind === 'success' ? 0 : 1); helper.close(); }
    else if (kind === 'launch-error') helper.emit('error', Object.assign(new Error('helper missing'), { code: 'ENOENT' }));
    else { if (kind === 'exited-with-open-pipe') helper.exit(0); timers.tick(5000); }
    const result = await pending;
    assert.equal(result.success, kind === 'success'); assert.equal(result.method, 'taskkill');
    assert.equal(result.detachedHandles, !['success', 'failure'].includes(kind));
    if (kind === 'exited-with-open-pipe') assert.deepEqual(helper.kills, []);
    if (kind === 'hang') { assert.deepEqual(helper.kills, ['SIGKILL']); assert.equal(result.expired, true); }
    assert.equal(timers.pending.size, 0);
  }
});

test('native downloads repair: Linux cancellation stays in the current owned group', async () => {
  const child = fakeChild(), targeted = [];
  const result = await cancelOwnedChild(child, { platform: 'linux', killGroup: pid => targeted.push(pid) });
  assert.deepEqual(targeted, [12345]); assert.equal(result.success, true);
  child.exit(0); await cancelOwnedChild(child, { platform: 'linux', killGroup: pid => targeted.push(pid) });
  assert.deepEqual(targeted, [12345]);
  const failed = await cancelOwnedChild(fakeChild(), { platform: 'linux', killGroup: () => { throw Error('denied'); } });
  assert.equal(failed.success, false);
});

test('native downloads stream repair: every native pipe error reaches bounded failure and preserves first attribution', async () => {
  for (const name of ['stdin', 'stdout', 'stderr']) for (const alreadyExited of [false, true]) {
    const child = fakeChild(), timers = fakeClock(); let cancellations = 0, nextCase = false;
    const pending = observeNativeChild(child, { command: 'fixture', timers,
      cancel: async () => { cancellations++; return { success: false, method: 'modeled' }; } });
    const rejected = assert.rejects(pending.then(() => { nextCase = true; }), error => {
      assert.match(error.message, new RegExp(`${name}-error`, 'u'));
      assert.deepEqual(error.resourceEvidence.error, { code: 'EIO', message: 'pipe failed', stream: name });
      assert.equal(error.resourceEvidence.cleanup, 'unproved'); return true;
    });
    child.emit('spawn'); if (alreadyExited) child.exit(0);
    child[name].emit('error', Object.assign(new Error('pipe failed'), { code: 'EIO' }));
    child.stderr.emit('error', Error('later competing pipe error'));
    child.emit('error', Error('later competing child error'));
    if (!alreadyExited) child.exit(0);
    child.close(); await rejected;
    assert.equal(cancellations, 1); assert.equal(nextCase, false); assert.equal(timers.pending.size, 0);
  }
});

test('native downloads stream repair: synchronous stdin failure retains its stream identity', async () => {
  const child = fakeChild(), timers = fakeClock();
  child.stdin.end = () => { throw Object.assign(new Error('write failed'), { code: 'EPIPE' }); };
  const pending = observeNativeChild(child, { command: 'fixture', timers, cancel: async () => ({ success: false }) });
  const rejected = assert.rejects(pending, error => error.resourceEvidence.error.stream === 'stdin'
    && error.resourceEvidence.error.code === 'EPIPE' && error.resourceEvidence.cleanup === 'unproved');
  child.close(-1, null); await rejected; assert.equal(timers.pending.size, 0);
});

test('native downloads stream repair: taskkill output errors return typed failure and tolerate detach races', async () => {
  for (const name of ['stdout', 'stderr']) for (const alreadyExited of [false, true]) {
    const target = fakeChild(), helper = fakeChild(), timers = fakeClock();
    for (const stream of [helper.stdin, helper.stdout, helper.stderr]) stream.destroy = () => {
      helper.stdin.emit('error', Error('destroy input race'));
      helper.stdout.emit('error', Error('destroy output race'));
      helper.stderr.emit('error', Error('destroy error race'));
    };
    const pending = cancelOwnedChild(target, { platform: 'win32', timers, systemRoot: path.parse(root).root, start: () => helper });
    if (alreadyExited) helper.exit(0); // A stream error after direct exit cannot target its old PID.
    assert.doesNotThrow(() => helper[name].emit('error', Object.assign(new Error('helper pipe failed'), { code: 'EIO' })));
    const result = await pending;
    assert.equal(result.success, false); assert.equal(result.detachedHandles, true); assert.equal(result.closed, false);
    assert.deepEqual(result.error, { code: 'EIO', message: 'helper pipe failed', stream: name });
    assert.deepEqual(helper.kills, alreadyExited ? [] : ['SIGKILL']); assert.equal(timers.pending.size, 0);
    for (const stream of [helper.stdin, helper.stdout, helper.stderr]) assert.doesNotThrow(() => stream.emit('error', Error('late helper error')));
    helper.close(); assert.equal(result.closed, false); assert.equal(result.success, false);
  }
});

test('native downloads stream repair: forced native detach consumes all stream errors without settlement credit', async () => {
  const child = fakeChild(), timers = fakeClock(); let result;
  for (const stream of [child.stdin, child.stdout, child.stderr]) stream.destroy = () => {
    for (const other of [child.stdin, child.stdout, child.stderr]) other.emit('error', Error('during destroy'));
  };
  const pending = observeNativeChild(child, { command: 'fixture', milliseconds: 100, timers, cancel: async () => ({ success: false }) });
  const rejected = assert.rejects(pending, error => { result = error.resourceEvidence;
    return result.cleanup === 'unproved' && result.detachedHandles && result.settlementExpired; });
  child.emit('spawn'); child.stdout.emit('error', Object.assign(new Error('initial'), { code: 'EIO' }));
  await microtasks(); assert.doesNotThrow(() => timers.tick(10000)); await rejected;
  const frozen = structuredClone(result);
  for (const stream of [child.stdin, child.stdout, child.stderr]) assert.doesNotThrow(() => stream.emit('error', Error('late detached error')));
  assert.doesNotThrow(() => child.emit('error', Error('late process error')));
  child.exit(0); child.close(); timers.tick(20000);
  assert.deepEqual(result, frozen); assert.equal(result.cleanup, 'unproved'); assert.equal(timers.pending.size, 0);
});

function fakeServer(options = {}) {
  const server = new EventEmitter(); server.listening = false; server.unreferenced = false;
  server.address = () => ({ port: 32100 }); server.unref = () => { server.unreferenced = true; };
  server.listen = (port, address, callback) => {
    assert.equal(port, 0); assert.equal(address, '127.0.0.1');
    if (options.startError) throw Error('listen refused');
    if (!options.startHang) { server.listening = true; callback(); }
  };
  server.close = callback => {
    server.closeCalls = (server.closeCalls ?? 0) + 1;
    if (!options.closeHang) { server.listening = false; server.emit('close'); callback(); }
  };
  return server;
}

test('native downloads repair: post-listen setup failure closes the owned endpoint', async () => {
  const server = fakeServer(), timers = fakeClock(); let actionCalls = 0;
  await assert.rejects(withDownloadEndpoint(() => endpoint('stall', Buffer.from('x'), 'unused', {
    httpFactory: () => server, timers }), () => { actionCalls++; throw Error('missing instrumentation anchor'); }), /missing instrumentation anchor/u);
  assert.equal(actionCalls, 1); assert.equal(server.listening, false); assert.equal(server.closeCalls, 1); assert.equal(timers.pending.size, 0);
});

test('native downloads repair: loopback teardown clears delayed responses and owned sockets', async () => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'a04-phase-test-'));
  try {
    const phases = path.join(directory, 'phases'); fs.writeFileSync(phases, 'preferred-complete\n');
    const server = fakeServer(), timers = fakeClock(); let handler;
    const owned = await endpoint('partial-recovery', Buffer.from('official-shaped-test'), phases, {
      platform: 'linux', timers, httpFactory: value => { handler = value; return server; } });
    const socket = new EventEmitter(); socket.destroy = () => socket.emit('close'); socket.unref = () => {};
    server.emit('connection', socket);
    const response = () => { const r = new EventEmitter(); r.writes = 0; r.writeHead = () => r.writes++;
      r.write = () => {}; r.end = () => {}; r.destroy = () => {}; return r; };
    handler({ url: '/archive', headers: {} }, response());
    const second = response(); handler({ url: '/archive', headers: {} }, second);
    assert.equal(timers.pending.size, 1); assert.equal(second.writes, 0);
    const result = await owned.close(); timers.tick(150);
    assert.equal(second.writes, 0); assert.equal(result.socketsPending, 0); assert.equal(result.responseTimersPending, 0);
    assert.equal(timers.pending.size, 0);
  } finally { fs.rmSync(directory, { recursive: true }); }
});

test('native downloads repair: listener start/teardown uncertainty has finite failure and no cleanup claim', async () => {
  const bad = fakeServer({ closeHang: true }), timers = fakeClock();
  const owned = await endpoint('stall', Buffer.from('x'), 'unused', { timers, httpFactory: () => bad });
  const rejected = assert.rejects(owned.close(), error => error.resourceEvidence.cleanup === 'unproved' && error.resourceEvidence.expired);
  timers.tick(5000); await rejected; assert.equal(bad.unreferenced, true); assert.equal(timers.pending.size, 0);
  const failedStart = fakeServer({ startError: true }), startTimers = fakeClock();
  await assert.rejects(endpoint('stall', Buffer.from('x'), 'unused', { timers: startTimers, httpFactory: () => failedStart }), /listen refused/u);
  assert.equal(startTimers.pending.size, 0); assert.equal(failedStart.closeCalls, 1);
  const hungStart = fakeServer({ startHang: true }), hungTimers = fakeClock();
  const startRejected = assert.rejects(endpoint('stall', Buffer.from('x'), 'unused', {
    timers: hungTimers, httpFactory: () => hungStart }), error => error.resourceEvidence.cleanup === 'unproved');
  hungTimers.tick(5000); await microtasks(); hungTimers.tick(5000); await startRejected;
  assert.equal(hungStart.unreferenced, true); assert.equal(hungTimers.pending.size, 0);
});

function independentWitness(platform, controlled = false) {
  const command = platform === 'win32' ? 'C:\\Windows\\System32\\curl.exe' : '/usr/bin/curl';
  const expected = { platform, mode: 'wrong-digest', role: controlled || platform === 'win32' ? 'preferred' : 'recoveryCompatibility',
    command, commandSha256: 'a'.repeat(64), original: ['--disable', '--output', '/fixture/archive', 'https://nodejs.org/declared'],
    adapted: controlled ? null : ['--disable', '--output', '/fixture/archive', 'http://127.0.0.1:32100/archive'], status: 0 };
  const record = { status: 0, signal: null, controlled, role: expected.role, mode: expected.mode, command, commandSha256: expected.commandSha256,
    channels: platform === 'win32' ? [{ name: 'path', held: true, code: 'EBUSY' }, { name: 'env', held: true, code: 'EACCES' }]
      : [{ name: 'path', empty: true }, { name: 'env', empty: true }], original: [...expected.original],
    adapted: expected.adapted && [...expected.adapted], ...(controlled ? {} : { elapsedMs: 12 }) };
  return { expected, record, bytes: Buffer.from(JSON.stringify(record)) };
}

test('native downloads repair: closed canonical witnesses bind every current role and command', () => {
  for (const [platform, controlled] of [['win32', false], ['linux', false], ['linux', true]]) {
    const { expected, record, bytes } = independentWitness(platform, controlled);
    assert.deepEqual(assertCurlWitness(bytes, expected), record);
    for (const mutate of [r => r.extra = true, r => r.mode = 'exhaustion', r => r.role = 'wrong', r => r.command += '.other',
      r => r.commandSha256 = 'b'.repeat(64), r => r.original.push('--insecure'), r => r.adapted = ['wrong'],
      r => r.controlled = !controlled, r => r.status = 1, r => r.signal = 'SIGTERM', r => delete r.status,
      r => r.error = { code: 'ETIMEDOUT', message: 'not a native refusal' }, r => r.channels[0].extra = true,
      r => r.channels[0].name = 'wrong', r => r.channels.pop(), r => r.elapsedMs = -1]) {
      const changed = structuredClone(record); mutate(changed);
      assert.throws(() => assertCurlWitness(Buffer.from(JSON.stringify(changed)), expected));
    }
  }
});

test('native Retry-After: zero is admitted only for the two Windows HTTP-error cases', () => {
  for (const mode of windowsCases) {
    const { expected, record } = independentWitness('win32');
    expected.mode = record.mode = mode; expected.status = 22;
    if (['retry-after-number', 'retry-after-date'].includes(mode)) {
      for (const status of [0, 22]) {
        record.status = status;
        assert.equal(assertCurlWitness(Buffer.from(JSON.stringify(record)), expected).status, status);
      }
      for (const status of [1, 18, 28, null, '0']) {
        record.status = status;
        assert.throws(() => assertCurlWitness(Buffer.from(JSON.stringify(record)), expected));
      }
      expected.status = 28; record.status = 0;
      assert.throws(() => assertCurlWitness(Buffer.from(JSON.stringify(record)), expected));
    } else assert.throws(() => assertCurlWitness(Buffer.from(JSON.stringify(record)), expected));
  }
  const { expected, record } = independentWitness('linux');
  expected.mode = record.mode = 'exhaustion'; expected.status = 22;
  assert.throws(() => assertCurlWitness(Buffer.from(JSON.stringify(record)), expected));
});

function retryAfterRefusal(mode, status) {
  const respondedAt = Date.UTC(2026, 9, 13, 23, 0, 0, 123);
  return { platform: 'win32', mode, caller: { status: 1, signal: null },
    witness: { status, signal: null, controlled: false, elapsedMs: 25 },
    requests: [{ url: '/archive', ambient: null, responseStatus: 503, respondedAt,
      retryAfter: mode === 'retry-after-number' ? '600' : new Date(respondedAt + 600000).toUTCString() }],
    phases: ['channels-held', ...(status === 0 ? ['archive-admission:preferred'] : [])],
    pathBytes: Buffer.alloc(0), envBytes: Buffer.alloc(0), runtimeExists: false };
}

test('native Retry-After: endpoint records the actual long-delay response fields', async () => {
  for (const mode of ['retry-after-number', 'retry-after-date']) {
    let handler;
    const server = fakeServer(), timers = fakeClock();
    const owned = await endpoint(mode, Buffer.from('unused'), 'unused', {
      timers, httpFactory: value => { handler = value; return server; } });
    const response = new EventEmitter();
    response.writeHead = (status, headers) => { response.statusCode = status; response.headers = headers; };
    response.end = () => { response.ended = true; }; response.destroy = () => assert.fail('Unexpected response error');
    try {
      handler({ url: '/archive', headers: {} }, response);
      assert.equal(response.statusCode, 503); assert.equal(response.headers['Content-Length'], '0');
      assert.equal(response.ended, true);
      assert.equal(owned.requests[0].responseStatus, response.statusCode);
      assert.equal(owned.requests[0].retryAfter, response.headers['Retry-After']);
      const observation = retryAfterRefusal(mode, 0); observation.requests = owned.requests;
      assertRetryAfterRefusal(observation);
    } finally { await owned.close(); }
    assert.equal(timers.pending.size, 0);
  }
});

test('native Retry-After: independent caller, response, time, publication and cleanup observations are mandatory', () => {
  const clone = value => ({ ...structuredClone(value), pathBytes: Buffer.from(value.pathBytes), envBytes: Buffer.from(value.envBytes) });
  for (const mode of ['retry-after-number', 'retry-after-date']) for (const status of [0, 22]) {
    const original = retryAfterRefusal(mode, status);
    assertRetryAfterRefusal(original);
    const mutations = [r => r.platform = 'linux', r => r.mode = 'exhaustion', r => r.caller.status = 0,
      r => r.caller.signal = 'SIGTERM', r => r.caller.error = { code: 'ETIMEDOUT' }, r => r.witness.status = 28,
      r => r.witness.signal = 'SIGTERM', r => r.witness.controlled = true,
      r => r.witness.elapsedMs = 10000, r => r.witness.elapsedMs = -1, r => r.witness.elapsedMs = NaN,
      r => r.requests = [], r => r.requests.push({ ...r.requests[0] }), r => r.requests[0].url = '/ambient',
      r => r.requests[0].ambient = 'dummy-only', r => r.requests[0].responseStatus = 200,
      r => r.requests[0].respondedAt = NaN, r => r.requests[0].retryAfter = '1',
      r => r.phases = [], r => r.phases.push('expand:preferred'), r => r.phases.push('node:preferred'),
      r => r.phases.push('npm:preferred'), r => r.phases.push('publication'),
      r => r.pathBytes = Buffer.from('published'), r => r.envBytes = Buffer.from('published'),
      r => r.pathBytes = '', r => r.runtimeExists = true];
    if (status === 0) mutations.push(r => r.phases = ['channels-held']);
    if (mode === 'retry-after-date') mutations.push(
      r => r.requests[0].retryAfter = 'invalid date',
      r => r.requests[0].retryAfter = new Date(r.requests[0].respondedAt + 300000).toUTCString(),
      r => r.requests[0].retryAfter = new Date(r.requests[0].respondedAt + 900000).toUTCString());
    for (const mutate of mutations) {
      const changed = clone(original); mutate(changed);
      assert.throws(() => assertRetryAfterRefusal(changed), mutate.toString());
    }
  }
});

test('native downloads repair: malformed, duplicate, noncanonical and oversized witness bytes fail', () => {
  const { bytes, expected } = independentWitness('win32'); const text = bytes.toString();
  for (const invalid of [Buffer.alloc(0), Buffer.alloc(4097), Buffer.from('{'), Buffer.from(text + '\n'),
    Buffer.from(text.replace('"status":0', '"status":1,"status":0')),
    Buffer.from(text.replace('"status":0', '"status":0.0')), Buffer.concat([Buffer.from([0xef, 0xbb, 0xbf]), bytes]),
    Buffer.concat([bytes.subarray(0, 30), Buffer.from([0xff]), bytes.subarray(31)])]) assert.throws(() => assertCurlWitness(invalid, expected));
});

test('native downloads repair: witness descriptor rejects links, truncation and changed identity', t => {
  const directory = fs.mkdtempSync(path.join(os.tmpdir(), 'a04-witness-test-')), file = path.join(directory, 'curl-preferred.json');
  const { bytes, expected } = independentWitness('win32');
  try {
    fs.writeFileSync(file, bytes); assert.equal(readCurlWitness(file, expected).command, expected.command);
    const read = t.mock.method(fs, 'readSync', () => 0); assert.throws(() => readCurlWitness(file, expected), /Truncated/u); read.mock.restore();
    const fstat = fs.fstatSync; let calls = 0;
    const changed = t.mock.method(fs, 'fstatSync', (...args) => { const value = fstat(...args); return ++calls === 2 ? changedStat(value, { size: value.size + 1n }) : value; });
    assert.throws(() => readCurlWitness(file, expected), /Changed open input/u); changed.mock.restore();
    const lstat = fs.lstatSync;
    const alias = t.mock.method(fs, 'lstatSync', (...args) => args[0] === file ? { isSymbolicLink: () => true } : lstat(...args));
    assert.throws(() => readCurlWitness(file, expected), /Aliased input/u); alias.mock.restore();
    fs.linkSync(file, path.join(directory, 'hardlink')); assert.throws(() => readCurlWitness(file, expected), /single-link/u);
  } finally { t.mock.restoreAll(); fs.rmSync(directory, { recursive: true }); }
});
