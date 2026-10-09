import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawn, spawnSync } from 'node:child_process';
import { createServer } from 'node:http';
import { createServer as createConnectionServer } from 'node:net';
import { createRequire } from 'node:module';
import { createHash } from 'node:crypto';
import { stripVTControlCharacters } from 'node:util';
import test from 'node:test';
import { readContract } from './Validate-WorkflowPolicy.mjs';

// These tests execute the actual loader/helper bodies with fixed external-tool
// replacements. They test control flow; real locked installation is tested separately.
const directory = path.dirname(fileURLToPath(import.meta.url));
const { parse } = createRequire(import.meta.url)('yaml');
const linux = process.platform === 'linux';
const head = 'a'.repeat(40), base = 'b'.repeat(40);
const read = name => fs.readFileSync(path.join(directory, name), 'utf8');
const artifactVerifier = readContract().roles.artifactVerifier;
const quote = value => `'${value.replaceAll("'", "''")}'`;
const runtimePin = digest => ({ ...JSON.parse(read('ci-toolchain.json')), preferred: { ...JSON.parse(read('ci-toolchain.json')).preferred, linuxX64Sha256: digest } });


// Capability probes are not download dispatches; each transfer retains its old behavior.
const fq40CurlQueryStub = String.raw`{
const queryArgs=process.argv.slice(2);
if(JSON.stringify(queryArgs)===JSON.stringify(['--disable','--version'])) {
console.log('curl 8.5.0 (fixture) libcurl/8.5.0 OpenSSL/3.0.0\nProtocols: https\nFeatures: SSL');
process.exit(0);
}
if(JSON.stringify(queryArgs)===JSON.stringify(['--disable','--help','all'])) {
console.log(['disable','silent','show-error','fail','location','proto','proto-redir','tlsv1.2','connect-timeout','max-time','retry','retry-max-time','output','max-filesize'].map(flag=>' --'+flag+' fixture').join('\n'));
process.exit(0);
}
}`;

// Keep reader fixture declarations independent of the repository producer.
const copilotReaderPin = digest => ({ schemaVersion: 2,
  preferred: { linuxX64Sha256: digest,
    windowsX64Sha256: 'ec56b84a7551893ab2324ebdfdc4ab974a63b4781162600b68a1293cc3e53765' },
  recoveryCompatibility: { node: '22.23.3', npm: '10.9.9',
    linuxX64Sha256: 'df450af89261115ef9f9e3830c3eeb2cc9213b63c720b1af623cb5dcbe2e02de' } });

// A timeout, signal or launch error is not a completed product refusal.
function assertReaderCompleted(result, context) {
  const details = `${context}: error=${result.error?.stack ?? result.error ?? 'none'}; ` +
    `signal=${String(result.signal)}; status=${String(result.status)}\n${result.stdout ?? ''}${result.stderr ?? ''}`;
  assert.equal(result.error, undefined, details);
  assert.equal(result.signal, null, details);
  assert.equal(Number.isInteger(result.status), true, details);
  return result;
}

// Remove terminal styling and join the PowerShell margin; keep message tokens exact.
function assertCopilotDigestDeclaration(stderr, format) {
  const diagnostic = stripVTControlCharacters(stderr).replace(/\r?\n[ \t]*\|[ \t]*/gu, ' ');
  const field = format === 'schema2' ? 'preferred.linuxX64Sha256' : 'linuxX64Sha256';
  const declaration = `package.json engines.node and .github/workflows/ci-toolchain.json ${field}.`;
  assert.ok(diagnostic.includes(declaration), stderr);
}

// A nonzero status proves product refusal only after ordinary process completion.
function assertCompletedProcess(result, context) {
  const details = `${context}: error=${result.error?.stack ?? result.error ?? 'none'}; ` +
    `signal=${String(result.signal)}; status=${String(result.status)}\n${result.stdout ?? ''}${result.stderr ?? ''}`;
  assert.equal(result.error, undefined, details);
  assert.equal(result.signal, null, details);
  assert.equal(Number.isInteger(result.status), true, details);
  return result;
}

test('F7 ordinary process completion preserves native statuses and result identity', () => {
  for (const status of [0, 1, 37]) {
    const result = Object.freeze({ error: undefined, signal: null, status,
      stdout: 'fixture stdout', stderr: 'fixture stderr' });
    assert.equal(assertCompletedProcess(result, `completed ${status}`), result);
    assert.equal(result.status, status);
  }
});

test('F7 ordinary process completion rejects incomplete or invalid native results', () => {
  const cases = [
    ['launch error', { status: null, signal: null, error: new Error('fixture ENOENT') }],
    ['timeout error', { status: null, signal: 'SIGTERM', error: new Error('fixture ETIMEDOUT') }],
    ['signal only', { status: null, signal: 'SIGTERM' }],
    ['error with numeric status', { status: 1, signal: null, error: new Error('fixture ETIMEDOUT') }],
    ['missing status', { signal: null }],
    ['missing signal', { status: 1 }],
    ['null status', { status: null, signal: null }],
    ['NaN status', { status: NaN, signal: null }],
    ['string status', { status: '1', signal: null }],
    ['fractional status', { status: 1.5, signal: null }],
  ];
  for (const [name, shape] of cases) {
    const result = { stdout: 'fixture stdout', stderr: 'fixture stderr', ...shape };
    assert.throws(() => assertCompletedProcess(result, `F7 negative ${name}`), error => {
      assert.equal(error instanceof assert.AssertionError, true);
      for (const detail of [`F7 negative ${name}`, 'signal=', 'status=', 'fixture stdout', 'fixture stderr']) {
        assert.ok(error.message.includes(detail), error.message);
      }
      if (result.error) assert.ok(error.message.includes(result.error.message), error.message);
      return true;
    }, name);
  }
});

// The inner curl adapter must prove native completion before product refusal.
function assertCurlResultWitness(bytes, mode, context) {
  assert.equal(Buffer.isBuffer(bytes), true, `${context}: missing curl result witness`);
  assert.ok(bytes.length > 0 && bytes.length <= 4096, `${context}: curl result witness size is invalid`);
  const text = bytes.toString('utf8');
  let result;
  try { result = JSON.parse(text); }
  catch (error) { assert.fail(`${context}: malformed curl result witness: ${error.message}`); }
  assert.ok(result && typeof result === 'object' && !Array.isArray(result), `${context}: curl result witness must be an object`);
  // The adapter writes canonical JSON once. Equality also rejects duplicate keys.
  assert.equal(JSON.stringify(result), text, `${context}: noncanonical or duplicate curl result witness`);
  assert.deepEqual(Object.keys(result).sort(), ['command', 'mode', 'signal', 'status', ...(Object.hasOwn(result, 'error') ? ['error'] : [])].sort(),
    `${context}: curl result witness fields do not match`);
  assert.equal(result.mode, mode, `${context}: curl result witness mode does not match`);
  assert.equal(result.command, '/usr/bin/curl', `${context}: curl result witness command does not match`);
  assertCompletedProcess(result, context);
  const nativeCodes = { transient: 0, 'retry-after-number': 22, 'retry-after-date': 22,
    stall: 28, 'partial-stall': 28, exhaustion: 22, 'partial-eof': 18, 'wrong-digest': 0 };
  assert.equal(Object.hasOwn(nativeCodes, mode), true, `${context}: unknown curl mode`);
  assert.equal(result.status, nativeCodes[mode], `${context}: unexpected native curl code`);
  return result;
}

function readCurlResultWitness(file, mode, context) {
  const descriptor = fs.openSync(file, fs.constants.O_RDONLY | fs.constants.O_NOFOLLOW);
  try {
    const identity = fs.fstatSync(descriptor);
    assert.equal(identity.isFile(), true, `${context}: curl result witness must be an ordinary file`);
    assert.equal(identity.nlink, 1, `${context}: curl result witness must have one link`);
    assert.ok(identity.size > 0 && identity.size <= 4096, `${context}: curl result witness size is invalid`);
    const bytes = Buffer.alloc(4097);
    const count = fs.readSync(descriptor, bytes, 0, bytes.length, 0);
    assert.equal(count, identity.size, `${context}: curl result witness size changed`);
    assert.equal(fs.fstatSync(descriptor).size, identity.size, `${context}: curl result witness size changed`);
    return assertCurlResultWitness(bytes.subarray(0, count), mode, context);
  } finally { fs.closeSync(descriptor); }
}

test('F8 inner curl witness admits only the completed native code for each mode', () => {
  const nativeCodes = { transient: 0, 'retry-after-number': 22, 'retry-after-date': 22,
    stall: 28, 'partial-stall': 28, exhaustion: 22, 'partial-eof': 18, 'wrong-digest': 0 };
  for (const [mode, status] of Object.entries(nativeCodes)) {
    const bytes = Buffer.from(JSON.stringify({ mode, command: '/usr/bin/curl', status, signal: null }));
    const result = assertCurlResultWitness(bytes, mode, `F8 completed ${mode}`);
    assert.equal(result.status, status);
    assert.equal(result.signal, null);
    assert.equal(result.error, undefined);
    const unrelated = Buffer.from(JSON.stringify({ mode, command: '/usr/bin/curl', status: 37, signal: null }));
    assert.throws(() => assertCurlResultWitness(unrelated, mode, `F8 unrelated ${mode}`), /unexpected native curl code/);
  }
});

test('F8 inner curl witness rejects absent invalid mismatched and incomplete records', () => {
  const completed = { mode: 'stall', command: '/usr/bin/curl', status: 28, signal: null };
  const cases = [
    ['missing', undefined],
    ['empty', Buffer.alloc(0)],
    ['malformed', Buffer.from('{')],
    ['oversized', Buffer.alloc(4097, 32)],
    ['duplicate', Buffer.from('{"mode":"stall","command":"/usr/bin/curl","status":28,"signal":null,"status":28}')],
    ['wrong mode', Buffer.from(JSON.stringify({ ...completed, mode: 'partial-stall' }))],
    ['wrong command', Buffer.from(JSON.stringify({ ...completed, command: '/other/curl' }))],
    ['extra field', Buffer.from(JSON.stringify({ ...completed, expected: 28 }))],
    ['launch error', Buffer.from(JSON.stringify({ ...completed, status: null, error: { name: 'Error', message: 'fixture ENOENT', stack: 'fixture ENOENT', code: 'ENOENT' } }))],
    ['timeout error', Buffer.from(JSON.stringify({ ...completed, status: null, signal: 'SIGTERM', error: { name: 'Error', message: 'fixture ETIMEDOUT', stack: 'fixture ETIMEDOUT', code: 'ETIMEDOUT' } }))],
    ['error with native code', Buffer.from(JSON.stringify({ ...completed, error: { name: 'Error', message: 'fixture ETIMEDOUT', stack: 'fixture ETIMEDOUT', code: 'ETIMEDOUT' } }))],
    ['signal with native code', Buffer.from(JSON.stringify({ ...completed, signal: 'SIGTERM' }))],
    ['null status', Buffer.from(JSON.stringify({ ...completed, status: null }))],
    ['string status', Buffer.from(JSON.stringify({ ...completed, status: '28' }))],
    ['mapped watchdog code', Buffer.from(JSON.stringify({ ...completed, status: 98 }))],
  ];
  for (const [name, bytes] of cases) {
    const context = `F8 negative ${name}`;
    assert.throws(() => assertCurlResultWitness(bytes, 'stall', context), error => {
      assert.equal(error instanceof assert.AssertionError, true);
      assert.ok(error.message.includes(context), error.message);
      if (name.includes('error')) assert.match(error.message, /fixture (?:ENOENT|ETIMEDOUT)/);
      return true;
    }, name);
  }
});

// Private fixture discovery follows the contributor's required PowerShell7 PATH.
// Production acquisition keeps its fixed Git application paths unchanged.
function discoverFixtureGit({ env = process.env, run = spawnSync } = {}) {
  const result = run('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-Command',
    "$ErrorActionPreference = 'Stop'; if ($PSVersionTable.PSVersion.Major -lt 7) { throw 'PowerShell7 is required.' }; " +
    "(Get-Command git -CommandType Application -All -TotalCount 1 -ErrorAction Stop).Source | ConvertTo-Json -Compress"],
  { env, encoding: 'utf8', timeout: 30000, windowsHide: true });
  assert.equal(result.error, undefined, 'The fixture requires PowerShell7 on PATH.');
  assert.equal(result.status, 0, `Required Git application discovery failed: ${result.stderr}`);
  let application;
  try { application = JSON.parse(result.stdout); }
  catch (error) { assert.fail(`Git discovery did not return one JSON application path: ${error.message}`); }
  assert.equal(typeof application, 'string', 'Git discovery must return one application path.');
  assert.ok(path.isAbsolute(application), 'The fixture Git application path must be absolute.');
  assert.ok(fs.statSync(application).isFile(), 'The fixture Git application must be a file.');
  return application;
}

test('fixture Git discovery requires native success and one absolute application', () => {
  const application = discoverFixtureGit();
  for (const result of [{ error: new Error('missing pwsh') }, { status: 1, stdout: '', stderr: 'missing git' },
    { status: 0, stdout: '{' }, { status: 0, stdout: 'null' }, { status: 0, stdout: JSON.stringify([application]) },
    { status: 0, stdout: JSON.stringify('git') }, { status: 0, stdout: JSON.stringify(directory) }]) {
    assert.throws(() => discoverFixtureGit({ run: () => result }));
  }
  assert.equal(discoverFixtureGit({ run: () => ({ status: 0, stdout: JSON.stringify(application) }) }), application);
});

test('generator proof preserves each child exit before revision publication', t => {
  // Actual proof bodies launch a fixture harness in a real current-host process.
  // Only foreign fixed Git paths are adapted; this does not simulate hosted
  // Windows5.1 or native-ext4 generator execution.
  const jobs = parse(read('build.yml')).jobs;
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'generator-proof-exit-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const work = path.join(root, 'work'), scripts = path.join(work, '.github/workflows');
  fs.mkdirSync(scripts, { recursive: true });
  const git = discoverFixtureGit();
  const env = { ...process.env, GIT_CONFIG_NOSYSTEM: '1', GIT_CONFIG_GLOBAL: process.platform === 'win32' ? 'NUL' : '/dev/null',
    GIT_TERMINAL_PROMPT: '0', GIT_NO_REPLACE_OBJECTS: '1' };
  for (const name of Object.keys(env)) if (/^GIT_(?:CONFIG_(?:COUNT|KEY_|VALUE_|PARAMETERS)|DIR$|WORK_TREE$|INDEX_FILE$|OBJECT_DIRECTORY$|ALTERNATE_OBJECT_DIRECTORIES$)/u.test(name)) delete env[name];
  fs.writeFileSync(path.join(scripts, 'Test-StyleGuideGenerator.ps1'), `
param([string]$ExpectedHost)
$intPass = if ([IO.File]::Exists($env:GENERATOR_PROOF_LOG)) { [IO.File]::ReadAllLines($env:GENERATOR_PROOF_LOG).Count + 1 } else { 1 }
[IO.File]::AppendAllText($env:GENERATOR_PROOF_LOG, ($ExpectedHost + "\n"))
if ($env:GENERATOR_PROOF_MODE -eq ('pass' + $intPass)) { exit 7 }
if ($env:GENERATOR_PROOF_MODE -eq 'exception') { throw 'Fixture terminating exception.' }
exit 0
`);
  for (const args of [['init', '--quiet'], ['add', '--all'],
    ['-c', 'core.hooksPath=', '-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid', 'commit', '--quiet', '-m', 'Fixture']]) {
    const result = spawnSync(git, args, { cwd: work, env, encoding: 'utf8', timeout: 30000, windowsHide: true });
    assert.equal(result.status, 0, result.stderr);
  }
  const revision = spawnSync(git, ['rev-parse', 'HEAD'], { cwd: work, env, encoding: 'utf8', timeout: 30000, windowsHide: true });
  assert.equal(revision.status, 0, revision.stderr);
  const sha = revision.stdout.trim();
  for (const [id, host] of [['generator_windows_51', 'WindowsPowerShell51'], ['generator_windows_7', 'WindowsPowerShell7'],
    ['generator_linux_7', 'LinuxPowerShell7']]) {
    const source = jobs[id].steps.find(step => step.id === 'proof').run
      .replace("'C:\\Program Files\\Git\\bin\\git.exe'", quote(git)).replace("'/usr/bin/git'", quote(git));
    const script = path.join(root, `${id}.ps1`);
    fs.writeFileSync(script, "$ErrorActionPreference = 'Stop'\n" + source +
      "\nif (Test-Path -LiteralPath variable:\\LASTEXITCODE) { exit $LASTEXITCODE }\n");
    for (const mode of ['success', 'pass1', 'pass2', 'exception']) {
      const output = path.join(root, `${id}-${mode}.output`), log = path.join(root, `${id}-${mode}.calls`);
      const result = spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', script], {
        cwd: work, env: { ...env, GITHUB_SHA: sha, GITHUB_OUTPUT: output, GENERATOR_PROOF_MODE: mode, GENERATOR_PROOF_LOG: log },
        encoding: 'utf8', timeout: 30000, windowsHide: true,
      });
      assertCompletedProcess(result, `generator proof ${id}:${mode}`);
      assert.equal(result.error, undefined, `${id}:${mode}`);
      assert.equal(result.status === 0, mode === 'success', `${id}:${mode}: ${result.stderr}`);
      const calls = fs.readFileSync(log, 'utf8').trim().split('\n');
      assert.deepEqual(calls, Array(mode === 'success' || mode === 'pass2' ? 2 : 1).fill(host));
      if (mode === 'success') assert.equal(fs.readFileSync(output, 'utf8'), `revision=${sha}\n`);
      else {
        assert.equal(fs.existsSync(output), false, `${id}:${mode} must not publish revision`);
        assert.match(result.stderr, /Generator pass [12] failed\./u);
      }
    }
  }
});

test('generator platform admission rejects every incomplete or wrong-revision result', t => {
  const workflow = parse(read('build.yml'));
  const job = workflow.jobs[artifactVerifier];
  const ids = ['generator_windows_51', 'generator_windows_7', 'generator_linux_7'];
  assert.deepEqual(job.needs, ids);
  assert.equal(workflow.jobs.publish_committed_artifacts.needs, artifactVerifier);
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'generator-admission-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const script = path.join(root, 'admit.ps1');
  const admission = job.steps.find(step => step.id === 'admit-generator-platforms');
  assert.deepEqual(admission.env, { GENERATOR_RESULTS: '${{ toJSON(needs) }}' });
  fs.writeFileSync(script, admission.run);
  const valid = Object.fromEntries(ids.map(id => [id, { result: 'success', outputs: { revision: head } }]));
  const cases = [{ name: 'all cells same revision', results: valid, pass: true }];
  for (const id of ids) {
    for (const result of ['failure', 'skipped', 'cancelled', '', 'Success']) {
      const results = structuredClone(valid);
      results[id].result = result;
      cases.push({ name: `${id}:${result}`, results });
    }
    const missing = structuredClone(valid); delete missing[id];
    const wrong = structuredClone(valid); wrong[id].outputs.revision = base;
    const noOutput = structuredClone(valid); noOutput[id].outputs = {};
    cases.push({ name: `${id}:absent`, results: missing }, { name: `${id}:wrong head`, results: wrong },
      { name: `${id}:absent revision`, results: noOutput });
  }
  cases.push({ name: 'extra role', results: { ...valid, unexpected: valid[ids[0]] } },
    { name: 'malformed JSON', raw: '{' }, { name: 'invalid current revision', results: valid, sha: '' });
  for (const item of cases) {
    const result = spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', script], {
      cwd: root, env: { ...process.env, GENERATOR_RESULTS: item.raw ?? JSON.stringify(item.results), GITHUB_SHA: item.sha ?? head },
      encoding: 'utf8', timeout: 30000, windowsHide: true,
    });
    assertCompletedProcess(result, `generator result admission ${item.name}`);
    assert.equal(result.error, undefined, item.name);
    assert.equal(result.status === 0, item.pass === true, `${item.name}: ${result.stderr}`);
  }
});

test('Windows generator acquisition preserves post-checkout credential and native-status checks', t => {
  // This executes the actual inline body with only its fixed external Git path
  // replaced. It is a dispatch/control probe; hosted jobs prove the real Git path.
  const jobs = parse(read('build.yml')).jobs;
  const source = jobs.generator_windows_51.steps[0].run;
  assert.equal(source, jobs.generator_windows_7.steps[0].run);
  assert.ok(source.includes("$strGitPath = 'C:\\Program Files\\Git\\bin\\git.exe'"));
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'generator-windows-acquire-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const git = path.join(root, 'git.ps1'), script = path.join(root, 'acquire.ps1');
  fs.writeFileSync(git, `
[IO.File]::AppendAllText($env:GENERATOR_GIT_LOG, ((@($args) | ConvertTo-Json -Compress) + "\n"))
$global:LASTEXITCODE = 0
$strMode = $env:GENERATOR_GIT_MODE
if ($args -contains 'fetch' -and $strMode -eq 'fetch-failure') { $global:LASTEXITCODE = 9 }
if ($args -contains 'checkout') {
    if ($strMode -eq 'post-token') { $env:GH_TOKEN = 'fixture-secret' }
    if ($strMode -eq 'post-command-config') { $env:GIT_CONFIG_COUNT = '1' }
    if ($strMode -eq 'checkout-failure') { $global:LASTEXITCODE = 7 }
}
if ($args -contains 'rev-parse') {
    if ($strMode -eq 'identity-failure') { $global:LASTEXITCODE = 6 }
    if ($strMode -ne 'identity-empty') {
        if ($strMode -eq 'wrong-identity') { 'b' * 40 } else { $env:GITHUB_SHA }
    }
    if ($strMode -eq 'identity-multiple') { $env:GITHUB_SHA }
}
if ($args -contains 'get-url') {
    if ($strMode -eq 'origin-failure') { $global:LASTEXITCODE = 6 }
    if ($strMode -ne 'origin-empty') {
        if ($strMode -eq 'origin-credentials') { 'https://fixture-secret@github.com/franklesniak/PSStyleGuide' }
        elseif ($strMode -eq 'origin-wrong') { 'https://github.com/other/repository' }
        else { 'https://github.com/franklesniak/PSStyleGuide' }
    }
    if ($strMode -eq 'origin-multiple') { 'https://github.com/franklesniak/PSStyleGuide' }
}
if ($args -contains '--get-regexp') {
    $global:LASTEXITCODE = 1
    if ($strMode -eq 'config-failure') { $global:LASTEXITCODE = 7 }
    if ($strMode -eq 'config-zero-empty') { $global:LASTEXITCODE = 0 }
    if (($strMode -eq 'helper' -and $args[-1].Contains('credential')) -or
        ($strMode -eq 'authorization' -and $args[-1].Contains('extraheader')) -or
        ($strMode -eq 'include' -and $args[-1].Contains('include'))) {
        $global:LASTEXITCODE = 0
        'fixture.forbidden'
    }
    if ($strMode -eq 'config-one-output') { 'fixture.forbidden' }
}
if ($args -contains '--list') {
    if ($strMode -eq 'effective-failure') { $global:LASTEXITCODE = 9 }
    if ($strMode -ne 'effective-empty') {
        if ($strMode -eq 'global-source') { "global\tfile:hostile.config\tcredential.helper" }
        elseif ($strMode -eq 'included-source') { "local\tfile:included.config\thttp.extraheader" }
        elseif ($strMode -eq 'system-source') { "system\tfile:hostile.config\tcredential.helper" }
        else { "local\tfile:.git/config\tcore.repositoryformatversion" }
    }
}
`);
  const modes = ['', 'fetch-failure', 'checkout-failure', 'identity-failure', 'identity-empty', 'wrong-identity',
    'identity-multiple', 'post-token', 'post-command-config', 'origin-failure', 'origin-empty', 'origin-credentials',
    'origin-wrong', 'origin-multiple', 'config-failure', 'config-zero-empty', 'config-one-output', 'helper',
    'authorization', 'include', 'effective-failure', 'effective-empty', 'global-source', 'included-source', 'system-source',
    'fixed-missing', 'pre-token'];
  for (const [index, mode] of modes.entries()) {
    const workspace = path.join(root, `workspace-${index}`); fs.mkdirSync(workspace);
    const log = path.join(root, `calls-${index}.jsonl`);
    const env = { ...process.env, GENERATOR_GIT_MODE: mode, GENERATOR_GIT_LOG: log, RUNNER_TEMP: root,
      GITHUB_SERVER_URL: 'https://github.com', GITHUB_REPOSITORY: 'franklesniak/PSStyleGuide', GITHUB_SHA: head };
    for (const name of Object.keys(env)) if (/^(?:GH_TOKEN|GITHUB_TOKEN|ACTIONS_RUNTIME_TOKEN|GIT_CONFIG_|GIT_DIR$|GIT_WORK_TREE$|GIT_INDEX_FILE$|GIT_OBJECT_DIRECTORY$|GIT_ALTERNATE_OBJECT_DIRECTORIES$)/u.test(name)) delete env[name];
    if (mode === 'pre-token') env.GH_TOKEN = 'fixture-secret';
    fs.writeFileSync(script, source.replace("'C:\\Program Files\\Git\\bin\\git.exe'",
      quote(mode === 'fixed-missing' ? path.join(root, 'missing-git') : git))
      .replace('Start-Sleep -Seconds 2', "Write-Output 'fixture retry'"));
    const result = spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', script], {
      cwd: workspace, env, encoding: 'utf8', timeout: 30000, windowsHide: true,
    });
    assertCompletedProcess(result, `Windows generator acquisition ${mode}`);
    assert.equal(result.error, undefined, mode);
    assert.equal(result.status === 0, mode === '', `${mode}: ${result.stderr}`);
    assert.ok(!`${result.stdout}${result.stderr}`.includes('fixture-secret'), mode);
    if (['fixed-missing', 'pre-token'].includes(mode)) {
      assert.equal(fs.existsSync(log), false, 'No name-resolution fallback or native work before refusal.');
      continue;
    }
    const calls = fs.readFileSync(log, 'utf8').trim().split('\n').map(JSON.parse);
    if (mode === 'fetch-failure') assert.equal(calls.filter(args => args.includes('fetch')).length, 3);
    if (mode === '') {
      assert.equal(calls.filter(args => args.includes('--get-regexp')).length, 3);
      assert.ok(calls.at(-1).includes('--show-origin'));
      assert.ok(calls.at(-1).includes('--show-scope'));
      assert.ok(calls.at(-1).includes('--includes'));
    }
  }
});

test('Linux build acquisition rejects Git selectors before dispatch and checks byte configuration', t => {
  // Execute both actual Linux bodies with only fixed Git dispatch replaced.
  // This is portable control evidence, not hosted Linux acquisition proof.
  const jobs = parse(read('build.yml')).jobs;
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'generator-linux-acquire-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const git = path.join(root, 'git.ps1'), script = path.join(root, 'acquire.ps1');
  fs.writeFileSync(git, `
[IO.File]::AppendAllText($env:GENERATOR_GIT_LOG, ((@($args) | ConvertTo-Json -Compress) + "\n"))
$global:LASTEXITCODE = 0
if ($args -contains 'config' -and $env:GENERATOR_GIT_MODE -eq 'config-failure') { $global:LASTEXITCODE = 7 }
if ($args -contains 'rev-parse') { $env:GITHUB_SHA }
`);
  const selectors = ['GIT_DIR', 'GIT_WORK_TREE', 'GIT_INDEX_FILE', 'GIT_OBJECT_DIRECTORY',
    'GIT_ALTERNATE_OBJECT_DIRECTORIES', 'GIT_CONFIG_COUNT', 'GIT_CONFIG_PARAMETERS'];
  for (const id of ['generator_linux_7', artifactVerifier]) {
    const source = jobs[id].steps.find(step => step.id === 'acquire').run;
    fs.writeFileSync(script, source.replaceAll('/usr/bin/git', quote(git)));
    for (const [index, mode] of ['', ...selectors, 'config-failure'].entries()) {
      const workspace = path.join(root, `${id}-${index}`); fs.mkdirSync(workspace);
      const log = path.join(root, `${id}-${index}.jsonl`);
      const env = { ...process.env, GENERATOR_GIT_MODE: mode, GENERATOR_GIT_LOG: log,
        GITHUB_SERVER_URL: 'https://github.com', GITHUB_REPOSITORY: 'franklesniak/PSStyleGuide', GITHUB_SHA: head };
      for (const name of ['GITHUB_TOKEN', 'GH_TOKEN', 'ACTIONS_RUNTIME_TOKEN', ...selectors]) delete env[name];
      if (selectors.includes(mode)) env[mode] = 'fixture-external-selector';
      const result = spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', script], {
        cwd: workspace, env, encoding: 'utf8', timeout: 30000, windowsHide: true,
      });
      assertCompletedProcess(result, `Linux build acquisition ${id}:${mode}`);
      assert.equal(result.error, undefined, `${id}:${mode}`);
      assert.equal(result.status === 0, mode === '', `${id}:${mode}: ${result.stderr}`);
      if (selectors.includes(mode)) {
        assert.equal(fs.existsSync(log), false, 'Reject external selectors before the first Git call.');
        assert.match(result.stderr, /Unexpected credentials or external Git configuration\./u);
        continue;
      }
      const calls = fs.readFileSync(log, 'utf8').trim().split('\n').map(JSON.parse);
      const configuration = calls.findIndex(args => args.includes('config'));
      assert.deepEqual(calls[configuration], ['config', '--local', 'core.autocrlf', 'false']);
      assert.ok(configuration > calls.findIndex(args => args.includes('init')));
      if (mode === 'config-failure') {
        assert.equal(calls.some(args => args.includes('fetch') || args.includes('checkout') || args.includes('remote')), false);
        assert.match(result.stderr, /Git byte-preserving checkout configuration failed\./u);
      } else {
        assert.ok(configuration < calls.findIndex(args => args.includes('fetch')));
        assert.ok(configuration < calls.findIndex(args => args.includes('checkout')));
      }
    }
  }
});

test('actual workflows cover every live push and PR base with an isolated target-event policy', () => {
  const liveGuard = "github.event_name != 'push' || github.event.deleted != true";
  for (const file of ['build.yml', 'markdownlint.yml', 'agent-instructions.yml']) {
    const workflow = parse(read(file));
    assert.ok(Object.hasOwn(workflow.on, 'push'));
    assert.ok(Object.hasOwn(workflow.on, 'pull_request'));
    assert.equal(workflow.on.push, null, 'Branch, tag and path filters would remove live pushes.');
    assert.equal(workflow.on.pull_request, null, 'Branch filters would remove supported PR bases.');
    if (file === 'agent-instructions.yml') {
      assert.deepEqual(workflow.on.pull_request_target, { types: ['opened', 'reopened', 'synchronize', 'edited'] });
      assert.equal(workflow.jobs['accepted-policy'].if, "github.event_name == 'pull_request_target'");
      assert.equal(workflow.jobs['candidate-tests'].if, "github.event_name != 'pull_request_target' && (" + liveGuard + ')');
      assert.deepEqual(workflow.jobs['accepted-policy'].permissions, {});
      assert.deepEqual(workflow.jobs['candidate-tests'].permissions, {});
    } else {
      for (const id of file === 'build.yml' ? [artifactVerifier] : ['policy', 'markdownlint']) {
        assert.equal(workflow.jobs[id].if, file === 'build.yml' ? 'always() && (' + liveGuard + ')' : liveGuard);
      }
    }
  }
});

// Exercise the untouched launcher with a fixed interpreter discovery result.
// The probe runs as a real Node child. It tests dispatch/version/status controls;
// actual Python isolation and locked installation are separate integration checks.
function pythonHookFixture(t) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'styleguide-python-hook-test-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const log = path.join(root, 'calls.jsonl');
  const probe = path.join(root, 'interpreter.cjs');
  fs.writeFileSync(probe, `const fs = require('node:fs');
const args = process.argv.slice(2), mode = process.env.PYTHON_HOOK_TEST_MODE;
fs.appendFileSync(process.env.PYTHON_HOOK_TEST_LOG, JSON.stringify(args) + '\\n');
if (args[0] === '-3.12') args.shift();
if (args[0] !== '-E' || args[1] !== '-P') process.exit(97);
if (args[2] === '-c' && args[3].includes('version_info')) {
  if (mode === 'version-failure') process.exit(19);
  console.log(mode === 'wrong-minor' ? '3.11' : mode === 'patch-output' ? '3.12.1' : '3.12');
  if (mode === 'multiline-version') console.log('3.12');
} else if (args[2] === '-c') {
  process.exit(mode === 'missing-module' ? 1 : 0);
} else if (args[2] === '-m') {
  console.log('selected module');
  process.exit(mode === 'module-failure' ? 7 : 0);
} else process.exit(98);
`);
  const interpreter = path.join(root, 'interpreter.ps1');
  fs.writeFileSync(interpreter, `& ${quote(process.execPath)} ${quote(probe)} @args
`);
  const script = path.join(root, 'case.ps1');
  const launcher = path.join(directory, 'Invoke-LockedPythonHook.ps1');
  function run(mode = '', module = 'pre_commit_hooks.check_json', args = []) {
    fs.writeFileSync(script, `$ErrorActionPreference = 'Stop'
function Get-Command {
    param([string] $Name, [string] $CommandType, [string] $ErrorAction)
    if ($CommandType -cne 'Application') { throw 'Unexpected discovery type.' }
    if ($env:PYTHON_HOOK_TEST_MODE -cne 'missing-interpreter') {
        [pscustomobject]@{ Source = ${quote(interpreter)} }
    }
}
& ${quote(launcher)} -Module ${quote(module)} ${args.map(quote).join(' ')}
exit $LASTEXITCODE
`);
    const result = spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', script], {
      cwd: root, env: { ...process.env, PYTHON_HOOK_TEST_MODE: mode, PYTHON_HOOK_TEST_LOG: log },
      encoding: 'utf8', timeout: 30000,
    });
    assert.equal(result.error, undefined, result.error?.message);
    assert.equal(result.signal, null, result.stderr);
    return result;
  }
  const calls = () => fs.existsSync(log) ? fs.readFileSync(log, 'utf8').trim().split('\n').filter(Boolean).map(JSON.parse) : [];
  return { run, calls };
}

test('locked Python hook rejects an unapproved module before interpreter dispatch', t => {
  const f = pythonHookFixture(t), result = f.run('', 'json.tool');
  assert.notEqual(result.status, 0);
  assert.deepEqual(f.calls(), []);
});

test('locked Python hook reports missing interpreter and rejects non-exact version probes', t => {
  for (const mode of ['missing-interpreter', 'wrong-minor', 'patch-output', 'multiline-version', 'version-failure', 'missing-module']) {
    const f = pythonHookFixture(t), result = f.run(mode);
    assert.equal(result.status, 2, `${mode}: ${result.stderr}`);
    assert.match(result.stderr, /Python 3\.12 is required/u);
    assert.equal(f.calls().some(args => args.includes('-m')), false, mode);
    if (mode === 'missing-interpreter') assert.deepEqual(f.calls(), []);
  }
});

for (const [mode, status] of [['', 0], ['module-failure', 7]]) {
  test(`locked Python hook isolates every dispatch and preserves arguments/native status: ${mode || 'success'}`, t => {
    const arguments_ = ['--option-shaped', 'space name.json', 'literal;name.json'];
    const f = pythonHookFixture(t), result = f.run(mode, 'pre_commit_hooks.check_json', arguments_);
    assert.equal(result.status, status, result.stderr);
    assert.match(result.stdout, /selected module/u);
    const calls = f.calls();
    assert.equal(calls.length, 3);
    for (const original of calls) {
      const args = original[0] === '-3.12' ? original.slice(1) : original;
      assert.deepEqual(args.slice(0, 2), ['-E', '-P']);
    }
    const moduleCall = calls[2][0] === '-3.12' ? calls[2].slice(1) : calls[2];
    assert.deepEqual(moduleCall, ['-E', '-P', '-m', 'pre_commit_hooks.check_json', ...arguments_]);
  });
}

function fixture(t, workDirectoryName = 'work') {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'styleguide-ci-test-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const work = path.join(root, workDirectoryName); fs.mkdirSync(work);
  const log = path.join(root, 'calls');
  const git = path.join(root, 'git');
  fs.writeFileSync(git, `#!${process.execPath}
const fs = require('node:fs');
const args = process.argv.slice(2), mode = process.env.TEST_MODE;
fs.appendFileSync(process.env.TEST_LOG, JSON.stringify(args) + '\\n');
if (args.includes('init') && mode === 'init-failure') process.exit(17);
if (args.includes('fetch')) {
  const calls = fs.readFileSync(process.env.TEST_LOG,'utf8').trim().split('\\n').map(JSON.parse);
  const count = calls.filter(row => row.includes('fetch')).length;
  if (mode === 'fetch-failure' || (mode === 'retry-success' && count < 3)) process.exit(7);
}
if (args.includes('checkout') && mode === 'checkout-failure') process.exit(23);
if (args.includes('rev-parse')) {
  if (mode === 'empty-output') process.exit(0);
  if (mode === 'identity-native-failure') process.exit(31);
  if (mode === 'identity-multiline') console.log(process.env.TEST_REVISION);
  console.log(mode === 'wrong-head' || (mode === 'wrong-checkout' && args.includes('HEAD^{commit}')) ? 'c'.repeat(40) : process.env.TEST_REVISION);
}
if (args.includes('remote') && args.includes('get-url')) console.log('https://github.com/franklesniak/PSStyleGuide');
if (args.includes('config') && (args.includes('--get-all') || args.includes('--get-regexp'))) process.exit(1);
`, { mode: 0o700 });
  function run(source, env = {}) {
    const script = path.join(root, 'case.ps1');
    // Only the fixed Git executable changes; all argument and status handling stays.
    fs.writeFileSync(script, "$ErrorActionPreference = 'Stop'\n" + source.replaceAll('/usr/bin/git', git).replaceAll("'/bin/git'", quote(git)));
    const environment = { ...process.env, GITHUB_SERVER_URL: 'https://github.com',
      GITHUB_REPOSITORY: 'franklesniak/PSStyleGuide', GITHUB_SHA: head,
      TEST_REVISION: head, TEST_LOG: log, TEST_MODE: '', RUNNER_TEMP: root,
      GITHUB_PATH: path.join(root, 'path'), GITHUB_ENV: path.join(root, 'env'), ...env };
    // Explicit undefined overrides delete only named keys from this private child map.
    for (const [name, value] of Object.entries(env)) if (value === undefined) delete environment[name];
    for (const name of ['GITHUB_TOKEN', 'GH_TOKEN', 'ACTIONS_RUNTIME_TOKEN',
      'GIT_CONFIG_COUNT', 'GIT_CONFIG_PARAMETERS']) {
      if (!Object.hasOwn(env, name)) delete environment[name];
    }
    if (source.includes('Initialize-CiToolchain.ps1')) for (const name of ['GITHUB_PATH', 'GITHUB_ENV']) {
      if (environment[name]?.trim() && !fs.existsSync(environment[name])) fs.writeFileSync(environment[name], '');
    }
    return assertCompletedProcess(spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', script], {
      cwd: work, env: environment, encoding: 'utf8', timeout: 30000,
    }), `PowerShell fixture ${script}`);
  }
  const calls = () => fs.existsSync(log) ? fs.readFileSync(log, 'utf8').trim().split('\n').filter(Boolean).map(JSON.parse) : [];
  return { root, work, git, log, run, calls };
}

for (const [file, job] of [['build.yml', artifactVerifier],
  ['markdownlint.yml', 'policy'], ['markdownlint.yml', 'markdownlint'],
  ['agent-instructions.yml', 'accepted-policy'], ['agent-instructions.yml', 'candidate-tests']]) {
  const source = parse(read(file)).jobs[job].steps.find(step => step.id === 'acquire').run;
  test(`${file}/${job}: exact acquisition and bounded retries`, { skip: !linux }, t => {
    const f = fixture(t);
    const env = job === 'accepted-policy' ? { EXPECTED_BASE: base, TEST_REVISION: base } : {};
    const result = f.run(source, { ...env, TEST_MODE: 'retry-success' });
    assert.equal(result.status, 0, result.stderr);
    const requests = f.calls().filter(row => row.includes('fetch'));
    assert.equal(requests.length, 3);
    assert.ok(requests.every(row => row.at(-1) === (env.TEST_REVISION ?? head)));
    assert.ok(requests.every(row => !row.some(value => value.startsWith('+'))));
  });
  for (const mode of ['init-failure', 'fetch-failure', 'wrong-head', 'empty-output', 'checkout-failure', 'wrong-checkout']) {
    test(`${file}/${job}: ${mode} cannot pass`, { skip: !linux }, t => {
      const f = fixture(t), result = f.run(source, { TEST_MODE: mode });
      assert.notEqual(result.status, 0);
      assert.ok(f.calls().filter(row => row.includes('fetch')).length <= 3);
      assert.equal(f.calls().filter(row => row.includes('checkout')).length,
        ['checkout-failure', 'wrong-checkout'].includes(mode) ? 1 : 0);
    });
  }
}

// Harmless synthetic selectors replace ambient host inputs in private children only.
const selectorSeeds = {
  STYLEGUIDE_RECOVERY_NODE22: 'fq23-stale-recovery', NODE_OPTIONS: '--no-warnings', NODE_PATH: '/fq23-unused-node-path',
  npm_config_script_shell: 'fq23-unused-shell', NPM_CONFIG_SCRIPT_SHELL: 'fq23-unused-shell-upper',
  NpM_CoNfIg_FQ23: 'fq23-unused-mixed',
};
function selectorEnvironment(family = 'all', recovery = true) {
  const environment = { TEST_FQ23_UNRELATED: 'fq23-preserved' };
  for (const name of Object.keys(process.env)) {
    const fixed = process.platform === 'win32' ? name.toUpperCase() : name;
    if (['STYLEGUIDE_RECOVERY_NODE22', 'NODE_OPTIONS', 'NODE_PATH'].includes(fixed) || /^npm_config_/iu.test(name)) {
      environment[name] = undefined;
    }
  }
  for (const [name, value] of Object.entries(selectorSeeds)) {
    environment[name] = family === 'all' || (family === 'fixed' && !/^npm_config_/iu.test(name)) ||
      (family === 'npm' && /^npm_config_/iu.test(name)) ? value : undefined;
  }
  if (!recovery) environment.STYLEGUIDE_RECOVERY_NODE22 = undefined;
  if (family === 'all' || family === 'npm') {
    environment.npm_config_userconfig = '/dev/null';
    environment.npm_config_globalconfig = '/etc/npmrc-absent-by-policy';
  }
  return environment;
}

// The real credential helper still runs. Only synthetic Node inputs are removed
// before the Node-based fixed Git mock; product sanitation is observed separately.
function selectorGitLauncher(f) {
  const nodeGit = `${f.git}-node`;
  fs.renameSync(f.git, nodeGit);
  fs.writeFileSync(f.git, `#!/bin/sh
if [ "$NODE_OPTIONS" = '--no-warnings' ]; then unset NODE_OPTIONS; fi
if [ "$NODE_PATH" = '/fq23-unused-node-path' ]; then unset NODE_PATH; fi
exec '${process.execPath.replaceAll("'", "'\\''")}' '${nodeGit.replaceAll("'", "'\\''")}' "$@"
`, { mode: 0o700 });
}

const selectorObserver = `
fs.appendFileSync(process.env.TEST_LOG, JSON.stringify(['FQ23 sanitation observer']) + '\\n');
const targets = ${JSON.stringify(Object.keys(selectorSeeds))};
const owned = require('node:path').join(process.env.RUNNER_TEMP, 'styleguide-node');
const configs = ['npm_config_userconfig', 'npm_config_globalconfig'];
const ordinaryEmpty = configs.every(name => {
  const target = process.env[name], expected = require('node:path').join(owned, name === configs[0] ? 'npm-user.config' : 'npm-global.config');
  return target === expected && fs.lstatSync(target).isFile() && !fs.lstatSync(target).isSymbolicLink() && fs.readFileSync(target, 'utf8') === '';
});
if (targets.some(name => Object.hasOwn(process.env, name)) || !ordinaryEmpty || process.env.TEST_FQ23_UNRELATED !== 'fq23-preserved') {
  console.error('FQ23 sanitation observer rejected retained selector or invalid owned configuration'); process.exit(98);
}
`;

const lintInvalidVersions = { 'engine-lf': '24.18.1\n', 'engine-crlf': '24.18.1\r\n',
  'engine-prefix': '\n24.18.1', 'engine-suffix': '24.18.1x', 'engine-range': '^24.18.1', 'engine-number': 24 };
const lintPreferenceCases = [
  ...['', 'outer-failure', 'nested-failure', 'package-array', 'ready-array', ...Object.keys(lintInvalidVersions)]
    .map(mode => ({ mode, preference: '', family: 'all', suffix: mode || 'success' })),
  ...['default', 'Low', 'WhatIf', 'Low+WhatIf'].flatMap(preference => ['all', 'absent'].map(family => ({
    mode: '', preference: (preference.includes('Low') ? "$ConfirmPreference='Low'; " : '') +
      (preference.includes('WhatIf') ? '$WhatIfPreference=$true; ' : ''), family, suffix: `FQ23 ${preference} ${family}`,
  }))),
];
for (const { mode, preference, family, suffix } of lintPreferenceCases) {
  test(`lint records both native results: ${suffix}`, { skip: !linux }, t => {
    const f = fixture(t), workflows = path.join(f.work, '.github/workflows');
    selectorGitLauncher(f);
    fs.mkdirSync(workflows, { recursive: true });
    fs.writeFileSync(path.join(workflows, 'Test-CheckoutCredentials.ps1'),
      read('Test-CheckoutCredentials.ps1').replaceAll('/usr/bin/git', f.git).replaceAll("'/bin/git'", quote(f.git)));
    fs.copyFileSync(path.join(directory, 'Invoke-MarkdownLint.ps1'), path.join(workflows, 'Invoke-MarkdownLint.ps1'));
    fs.writeFileSync(path.join(f.work, 'package.json'), JSON.stringify({ engines: { node: '24.18.1', npm: '11.16.0' } }));
    const runtime = path.join(f.root, 'styleguide-node/preferred/node-v24.18.1-linux-x64');
    const bin = path.join(runtime, 'bin'); fs.mkdirSync(bin, { recursive: true });
    const cli = path.join(runtime, 'lib/node_modules/npm/bin'); fs.mkdirSync(cli, { recursive: true });
    fs.writeFileSync(path.join(cli, 'npm-cli.js'), 'fixture');
    for (const config of ['npm-user.config', 'npm-global.config']) fs.writeFileSync(path.join(f.root, 'styleguide-node', config), '');
    fs.writeFileSync(path.join(f.root, 'styleguide-node/ready.json'), JSON.stringify({ node: '24.18.1', npm: '11.16.0' }));
    fs.writeFileSync(path.join(bin, 'node'), `#!${process.execPath}
const fs = require('node:fs'), args = process.argv.slice(3);
${selectorObserver}
fs.appendFileSync(process.env.TEST_LOG, JSON.stringify(['npm', ...args])+'\\n');
if (process.env.TEST_MODE === 'outer-failure' && args.at(-1) === 'lint:md') process.exit(5);
if (process.env.TEST_MODE === 'nested-failure' && args.at(-1) === 'lint:md:nested') process.exit(6);
`, { mode: 0o700 });
    if (mode === 'package-array' || mode === 'ready-array') {
      const target = mode === 'package-array' ? path.join(f.work, 'package.json') : path.join(f.root, 'styleguide-node/ready.json');
      fs.writeFileSync(target, JSON.stringify([JSON.parse(fs.readFileSync(target, 'utf8'))]));
    }
    if (Object.hasOwn(lintInvalidVersions, mode)) {
      fs.writeFileSync(path.join(f.work, 'package.json'), JSON.stringify({ engines: { node: lintInvalidVersions[mode], npm: '11.16.0' } }));
    }
    const result = f.run(`${preference}& ${quote(path.join(workflows, 'Invoke-MarkdownLint.ps1'))}`, {
      ...selectorEnvironment(family, false), TEST_MODE: mode,
    });
    assert.equal(result.status === 0, mode === '', result.stderr);
    if (mode.endsWith('-array')) {
      assert.match(result.stderr, /JSON input must be an object/u);
      assert.deepEqual(f.calls().filter(row => row[0] === 'npm'), []);
      return;
    }
    if (Object.hasOwn(lintInvalidVersions, mode)) {
      assert.match(result.stderr, /The preferred runtime declaration is invalid/u);
      assert.deepEqual(f.calls().filter(row => row[0] === 'npm'), []);
      return;
    }
    assert.ok(result.stdout.includes(`Markdown exits: outer=${mode === 'outer-failure' ? 5 : 0} nested=${mode === 'nested-failure' ? 6 : 0}`), result.stdout);
    assert.deepEqual(f.calls().filter(row => row[0] === 'npm').map(row => row.at(-1)), ['lint:md', 'lint:md:nested']);
  });
}

// FQ34: exercise each real ordinary-path helper. Network-looking strings never
// reach a provider or filesystem call, including in the causal mutants below.
function fq34Once(source, anchor, replacement) {
  assert.equal(source.split(anchor).length, 2, 'Exactly one FQ34 source boundary is required.');
  return source.replace(anchor, replacement);
}

function fq34OrdinaryPath(helper) {
  const source = read(helper).replaceAll('\r\n', '\n');
  const start = source.indexOf('function Assert-OrdinaryPath {');
  const end = source.indexOf('\nfunction ', start + 1);
  assert.ok(start >= 0 && end > start, `${helper}: complete actual helper extraction`);
  return source.slice(start, end) + '\n';
}

function fq34LexicalBoundary(ordinary) {
  const anchor = '    [Management.Automation.ProviderInfo] $objPathProvider = $null';
  assert.equal(ordinary.split(anchor).length, 2);
  const prefix = ordinary.slice(0, ordinary.indexOf(anchor));
  assert.equal(prefix.includes('GetUnresolvedProviderPathFromPSPath'), false);
  assert.equal(prefix.includes('Get-Item -LiteralPath'), false);
  return prefix + "    return 'FQ34 lexical boundary reached'\n}\n";
}

const fq34Normalize = '    $strFullPath = [IO.Path]::GetFullPath($Path)';
const fq34RawGuard = String.raw` -or
        ($IsWindows -and $Path.Replace('/', '\').StartsWith('\\'))`;
const fq34NormalizedGuard = String.raw`    if ($IsWindows -and $strFullPath -cnotmatch '\A[A-Za-z]:\\') {
        throw 'toolchain: an absolute local single-line path is required'
    }
`;

function fq34Case(input, directory = false) { return { input, directory }; }

// Run all finite stages for one source helper in one private native child.
// Definitions change only in that child; the repository source is never written.
function fq34Run(t, helper, buildStages) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'styleguide-fq34-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const folder = path.join(root, 'space and Unicode Ω'); fs.mkdirSync(folder);
  const file = path.join(folder, 'ordinary file Ω.txt'); fs.writeFileSync(file, 'FQ34 unchanged');
  const ordinary = fq34OrdinaryPath(helper);
  const stages = buildStages({ ordinary, folder, file });
  assert.ok(stages.length > 0 && stages.length <= 6);
  assert.ok(stages.reduce((count, stage) => count + stage.cases.length, 0) <= 41);
  assert.ok(new Set(stages.flatMap(stage => stage.cases.map(item => item.input))).size <= 40);
  const calls = stages.map(stage => {
    assert.ok(stage.cases.length > 0 && stage.cases.length <= 40);
    assert.ok(stage.cases.every(item => typeof item.input === 'string' && item.input.length <= 256));
    return `${stage.source}\n$arrCases = ConvertFrom-Json -InputObject ${quote(JSON.stringify(stage.cases))}\n` +
      `$arrResults += @(Invoke-Fq34Cases -Cases $arrCases -Stage ${quote(stage.name)})\n`;
  }).join('\n');
  const script = path.join(root, 'fq34.ps1');
  const text = `$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
function Invoke-Fq34Cases {
    param([object[]] $Cases, [string] $Stage)
    foreach ($entry in $Cases) {
        try {
            $value = Assert-OrdinaryPath -Path $entry.input -Directory:([bool]$entry.directory)
            [ordered]@{ stage = $Stage; input = $entry.input; directory = $entry.directory; admitted = $true; value = $value }
        } catch {
            [ordered]@{ stage = $Stage; input = $entry.input; directory = $entry.directory; admitted = $false; message = $_.Exception.Message }
        }
    }
}
$arrResults = @()
${calls}
ConvertTo-Json -InputObject $arrResults -Depth 5 -Compress -EscapeHandling EscapeNonAscii
`;
  assert.ok(Buffer.byteLength(text) <= 128 * 1024, 'FQ34 script is finite.');
  fs.writeFileSync(script, text);
  const result = assertCompletedProcess(spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', script], {
    encoding: 'utf8', timeout: 15000, maxBuffer: 256 * 1024, windowsHide: true,
  }), `FQ34 ${helper}`);
  assert.equal(result.status, 0, result.stdout + result.stderr);
  const rows = JSON.parse(result.stdout);
  assert.equal(rows.length, stages.reduce((count, stage) => count + stage.cases.length, 0));
  const expected = stages.flatMap(stage => stage.cases.map(entry => ({ ...entry, stage: stage.name })));
  for (const [index, row] of rows.entries()) {
    assert.equal(row.stage, expected[index].stage);
    assert.equal(row.input, expected[index].input);
    assert.equal(row.directory, expected[index].directory);
  }
  assert.equal(fs.readFileSync(file, 'utf8'), 'FQ34 unchanged');
  assert.equal(fs.statSync(folder).isDirectory(), true);
  return { rows, folder, file };
}

for (const helper of ['Initialize-CiToolchain.ps1', 'Test-CheckoutCredentials.ps1', 'Invoke-MarkdownLint.ps1']) {
  test(`FQ34 Windows raw and normalized local path boundaries: ${helper}`, {
    skip: process.platform !== 'win32', timeout: 30000,
  }, t => {
    const { rows, folder, file } = fq34Run(t, helper, ({ ordinary, folder, file }) => {
      const lexical = fq34LexicalBoundary(ordinary);
      const spellings = value => [value, value.replaceAll('\\', '/'), value.replace(/\\/u, '/')];
      const prefixes = ['\\\\', '//', '/\\', '\\/'];
      const forbidden = prefixes.flatMap(prefix => [
        prefix + 'fq34.invalid/share/item', prefix + '?/C:/fixture/item',
        prefix + './C:/fixture/item', prefix + '?/UNC/fq34.invalid/share/item',
      ]);
      forbidden.push(String.raw`FileSystem::C:\fixture\item`,
        String.raw`Microsoft.PowerShell.Core\FileSystem::C:\fixture\item`, 'Env:TEMP',
        'C:fixture', String.raw`\fixture`, '/fixture', 'relative/item',
        "C:\\fixture\\item\n", "C:\\fixture\\item\r\n", String.raw`C:\fixture\item:stream`);
      assert.ok(forbidden.every(value => !value.includes('~')));
      const tilde = prefixes.map(prefix => prefix + 'fq34.invalid/share/SHORT~1/item');
      const normalizationSentinel = fq34Once(lexical, fq34Normalize, "    throw 'FQ34 normalization reached'");
      const rawMutation = fq34Once(normalizationSentinel, fq34RawGuard, '');
      // A deterministic substituted return tests the normalized invariant. It is
      // not evidence that a native local input normalizes to this remote root.
      const injected = fq34Once(lexical, fq34Normalize,
        String.raw`    $strFullPath = '\\fq34.invalid\share\item'`);
      return [
        { name: 'real-local', source: ordinary,
          cases: [...spellings(file).map(value => fq34Case(value)), ...spellings(folder).map(value => fq34Case(value, true))] },
        { name: 'lexical-refusal', source: lexical, cases: forbidden.map(value => fq34Case(value)) },
        { name: 'before-normalization', source: normalizationSentinel, cases: tilde.map(value => fq34Case(value)) },
        { name: 'raw-guard-mutant', source: rawMutation, cases: tilde.slice(1).map(value => fq34Case(value)) },
        { name: 'normalized-invariant', source: injected, cases: [fq34Case(file)] },
        { name: 'normalized-invariant-mutant', source: fq34Once(injected, fq34NormalizedGuard, ''), cases: [fq34Case(file)] },
      ];
    });
    for (const row of rows) {
      const context = `${helper} ${row.stage} ${JSON.stringify(row.input)}`;
      if (row.stage === 'real-local') {
        assert.equal(row.admitted, true, context + ': ' + row.message);
        assert.equal(row.value, path.resolve(row.directory ? folder : file), context);
      } else if (row.stage === 'normalized-invariant-mutant') {
        assert.equal(row.admitted, true, context);
        assert.equal(row.value, 'FQ34 lexical boundary reached', context);
      } else {
        assert.equal(row.admitted, false, context);
        assert.equal(row.message, row.stage === 'raw-guard-mutant' ? 'FQ34 normalization reached' :
          row.input.endsWith(':stream') ? 'toolchain: path aliases are not supported' :
            'toolchain: an absolute local single-line path is required', context);
      }
    }
  });

  test(`FQ34 Linux ordinary and double-slash paths remain local: ${helper}`, {
    skip: !linux, timeout: 30000,
  }, t => {
    const { rows, folder, file } = fq34Run(t, helper, ({ ordinary, folder, file }) => [{
      name: 'real-local', source: ordinary,
      cases: [fq34Case(file), fq34Case('/' + file), fq34Case(folder, true), fq34Case('/' + folder, true)],
    }]);
    for (const row of rows) {
      assert.equal(row.admitted, true, `${helper}: ${row.message}`);
      assert.equal(row.value, path.resolve(row.directory ? folder : file));
    }
  });
}

test('FQ33 lint engine admission requires the complete version value', () => {
  const source = read('Invoke-MarkdownLint.ps1');
  const start = 'if ($objPackage.engines.node -isnot [string]';
  const end = '$hashtableReadyRuntime = Read-BoundedJson';
  assert.equal(source.split(start).length, 2);
  assert.equal(source.split(end).length, 2);
  const admission = source.slice(source.indexOf(start), source.indexOf(end));
  const cases = [{ value: '24.18.1', accepted: true }, { value: '24.0.0', accepted: true },
    ...Object.values(lintInvalidVersions).map(value => ({ value, accepted: false })),
    ...['24.18.1\r', '24.18.1\t', '24.18.1 ', '22.18.1', null, ['24.18.1']].map(value => ({ value, accepted: false }))];
  const payload = Buffer.from(JSON.stringify(cases)).toString('base64');
  const script = `$ErrorActionPreference='Stop'; $admission={\n${admission}\n}
$cases=ConvertFrom-Json -InputObject ([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String('${payload}')))
$results=@(foreach($case in $cases) {
    $objPackage=@{engines=@{node=$case.value}}; $accepted=$false
    try { & $admission; $accepted=$true }
    catch { if($_.Exception.Message -cne 'The preferred runtime declaration is invalid.') { throw } }
    $accepted
})
ConvertTo-Json -InputObject $results -Compress
`;
  const result = assertCompletedProcess(spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-Command', script],
    { encoding: 'utf8', timeout: 15000, windowsHide: true }), 'FQ33 actual lint admission');
  assert.equal(result.status, 0, result.stdout + result.stderr);
  assert.deepEqual(JSON.parse(result.stdout), cases.map(item => item.accepted));
});

for (const [file, job, stepId] of [
  ['markdownlint.yml', 'policy', 'validate'], ['markdownlint.yml', 'markdownlint', 'audit'],
  ['agent-instructions.yml', 'accepted-policy', 'validate'], ['agent-instructions.yml', 'candidate-tests', 'test'],
]) {
  test(`FQ37 direct workflow Node caller clears inherited startup options: ${file}/${job}`, { skip: !linux, timeout: 90000 }, t => {
    const sanitation = 'Remove-Item Env:NODE_OPTIONS -ErrorAction SilentlyContinue -Confirm:$false -WhatIf:$false';
    const steps = parse(read(file)).jobs[job].steps;
    const step = steps.find(item => item.id === stepId);
    assert.ok(step, `${file}/${job}/${stepId}`);
    const lines = step.run.split('\n').map(line => line.trim());
    const nodeIndex = lines.findIndex(line => /& node /u.test(line));
    assert.ok(nodeIndex > 0);
    assert.equal(lines[nodeIndex - 1], sanitation);
    assert.match(lines[nodeIndex + 1], /^if \(\$LASTEXITCODE -ne 0\)/u);
    const command = lines.slice(nodeIndex - 1, nodeIndex + 2).join('\n');
    for (const preference of ['', "$ConfirmPreference='Low'; ", "$ConfirmPreference='Low'; $WhatIfPreference=$true; ", 'mutant']) {
      const f = fixture(t), executable = path.join(f.root, 'node');
      fs.writeFileSync(executable, `#!${process.execPath}
const fs=require('node:fs');
fs.appendFileSync(process.env.TEST_LOG,JSON.stringify(['FQ37 node',...process.argv.slice(2)])+'\\n');
if(Object.hasOwn(process.env,'NODE_OPTIONS')) { console.error('FQ37 retained startup selector'); process.exit(98); }
console.log('FQ37 clean startup');
`, { mode: 0o700 });
      const source = preference === 'mutant' ? command.replace(sanitation + '\n', '') : preference + command;
      const script = path.join(f.root, 'consumer.ps1');
      fs.writeFileSync(script, "$ErrorActionPreference='Stop'\n" + source);
      const result = assertCompletedProcess(spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', script], {
        cwd: f.work, encoding: 'utf8', timeout: 15000, maxBuffer: 256 * 1024, windowsHide: true,
        env: { HOME: f.root, TMPDIR: f.root,
          DOTNET_EnableDiagnostics: '0', POWERSHELL_DIAGNOSTICS_OPTOUT: '1',
          PATH: f.root + path.delimiter + process.env.PATH, TEST_LOG: f.log,
          NODE_OPTIONS: '--no-warnings', EXPECTED_BASE: base, EXPECTED_HEAD: head },
      }), `FQ37 ${file}/${job}/${preference}`);
      const calls = f.calls();
      assert.equal(calls.length, 1);
      assert.equal(calls[0][0], 'FQ37 node');
      const expected = job === 'policy' ? ['./.github/workflows/Validate-WorkflowPolicy.mjs', '.github/workflows/build.yml', '.github/workflows/markdownlint.yml']
        : job === 'markdownlint' ? ['./.github/workflows/Check-NpmAudit.mjs', '--ci']
          : job === 'accepted-policy' ? ['.github/workflows/Classify-InstructionMaintenance.mjs', f.work, base, head]
            : ['--test', ...['Classify-InstructionMaintenance.test.mjs', 'Validate-WorkflowPolicy.test.mjs', 'Test-CiHelpers.test.mjs',
              'NpmTools.test.mjs', 'Check-NpmAudit.test.mjs', 'Test-LocalValidation.test.mjs', 'lint-markdown.test.mjs'].map(name => '.github/workflows/' + name)];
      assert.deepEqual(calls[0].slice(1), expected);
      if (preference === 'mutant') {
        assert.notEqual(result.status, 0, result.stdout + result.stderr);
        assert.match(result.stderr, /FQ37 retained startup selector/);
      } else {
        assert.equal(result.status, 0, result.stdout + result.stderr);
        if (job !== 'accepted-policy') assert.match(result.stdout, /FQ37 clean startup/);
        assert.doesNotMatch(result.stderr, /FQ37 retained startup selector/);
      }
    }
  });
}

test('acquisition rejects credentials, wrong repository, refs and occupied workspaces', { skip: !linux }, t => {
  const source = parse(read('build.yml')).jobs[artifactVerifier].steps[0].run;
  for (const env of [{ GITHUB_TOKEN: 'fixture' }, { GIT_CONFIG_COUNT: '1' },
    { GITHUB_REPOSITORY: 'someone/else' }, { GITHUB_SHA: 'main' }]) {
    const f = fixture(t);
    assert.notEqual(f.run(source, env).status, 0);
    assert.equal(f.calls().length, 0);
  }
  const f = fixture(t); fs.writeFileSync(path.join(f.work, 'keep.txt'), 'do not remove');
  assert.notEqual(f.run(source).status, 0);
  assert.equal(fs.readFileSync(path.join(f.work, 'keep.txt'), 'utf8'), 'do not remove');
});

for (const mode of ['native-download-failure', 'wrong-download-bytes', 'unsafe-npm-config',
  'invalid-node', 'invalid-npm', 'invalid-digest', 'existing-staging', 'dangling-staging-link']) {
  test(`runtime setup rejects ${mode} before dependency code`, { skip: !linux }, t => {
    const f = fixture(t), workflows = path.join(f.work, '.github/workflows');
    fs.mkdirSync(workflows, { recursive: true });
    const curl = path.join(f.root, 'curl');
    fs.writeFileSync(curl, `#!${process.execPath}
const fs = require('node:fs'), args = process.argv.slice(2);
${fq40CurlQueryStub}
fs.appendFileSync(process.env.TEST_LOG, JSON.stringify(['curl'])+'\\n');
if (process.env.TEST_MODE === 'native-download-failure') process.exit(19);
fs.writeFileSync(args[args.indexOf('--output')+1], 'incorrect archive bytes');
`, { mode: 0o700 });
    fs.writeFileSync(path.join(workflows, 'Test-CheckoutCredentials.ps1'),
      read('Test-CheckoutCredentials.ps1').replaceAll('/usr/bin/git', f.git).replaceAll("'/bin/git'", quote(f.git)));
    fs.copyFileSync(path.join(directory, 'ci-toolchain.json'), path.join(workflows, 'ci-toolchain.json'));
    const manifest = JSON.parse(fs.readFileSync(path.resolve(directory, '../../package.json')));
    if (mode === 'invalid-node') manifest.engines.node = '^24';
    if (mode === 'invalid-npm') manifest.engines.npm = 'latest';
    fs.writeFileSync(path.join(f.work, 'package.json'), JSON.stringify(manifest));
    if (mode === 'invalid-digest') fs.writeFileSync(path.join(workflows, 'ci-toolchain.json'), '{"linuxX64Sha256":"bad"}');
    if (mode === 'existing-staging') fs.mkdirSync(path.join(f.root, 'styleguide-node'));
    if (mode === 'dangling-staging-link') fs.symlinkSync(path.join(f.root, 'missing-target'), path.join(f.root, 'styleguide-node'));
    const source = read('Initialize-CiToolchain.ps1').replaceAll('/usr/bin/curl', curl);
    fs.writeFileSync(path.join(workflows, 'Initialize-CiToolchain.ps1'), source);
    if (mode === 'unsafe-npm-config') fs.writeFileSync(path.join(f.work, '.npmrc'), 'script-shell=hostile\n');
    const result = f.run(`& ${quote(path.join(workflows, 'Initialize-CiToolchain.ps1'))} -WorkflowDependencies`, { TEST_MODE: mode });
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, mode === 'unsafe-npm-config' ? /npm configuration selector/ :
      mode.startsWith('invalid-') ? /runtime declaration is invalid/ :
      mode.includes('staging') ? /staging destination already exists/ :
      mode === 'native-download-failure' ? /Runtime download failed/ : /archive digest is incorrect/);
    assert.equal(fs.existsSync(path.join(f.root, 'styleguide-node')), mode === 'existing-staging');
    if (mode === 'unsafe-npm-config' || mode.startsWith('invalid-') || mode.includes('staging')) {
      assert.ok(f.calls().every(row => !row.includes('curl')));
    }
    if (mode === 'dangling-staging-link') assert.equal(fs.lstatSync(path.join(f.root, 'styleguide-node')).isSymbolicLink(), true);
    if (mode === 'wrong-download-bytes') {
      assert.match(result.stderr, /package\.json/);
      assert.match(result.stderr, /ci-toolchain\.json/);
      assert.ok(result.stderr.includes(`node-v${manifest.engines.node}-linux-x64.tar.xz`));
    }
  });
}

for (const [file, variables] of [
  ['Initialize-CiToolchain.ps1', ['RUNNER_TEMP', 'GITHUB_PATH', 'GITHUB_ENV']],
  ['Invoke-MarkdownLint.ps1', ['RUNNER_TEMP']],
]) {
  for (const variable of variables) for (const value of ['', '  ']) test(`${file}: ${JSON.stringify(value)} ${variable} fails before external work`, { skip: !linux }, t => {
    const f = fixture(t);
    const helper = path.join(f.root, file);
    fs.writeFileSync(helper, read(file));
    const result = f.run(`& ${quote(helper)}`, { [variable]: value });
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /requires (?:the )?runner environment/);
    assert.match(result.stderr, new RegExp(variable));
    assert.equal(f.calls().length, 0);
  });
}

for (const mode of ['current', 'updated-engines', 'wrong-node', 'wrong-npm']) {
test(`runtime setup uses root engines and safe npm inputs: ${mode}`, { skip: !linux }, t => {
  const f = fixture(t), workflows = path.join(f.work, '.github/workflows');
  fs.mkdirSync(workflows, { recursive: true });
  fs.writeFileSync(path.join(workflows, 'Test-CheckoutCredentials.ps1'),
    read('Test-CheckoutCredentials.ps1').replaceAll('/usr/bin/git', f.git).replaceAll("'/bin/git'", quote(f.git)));
  for (const directory of [f.work, workflows]) {
    fs.writeFileSync(path.join(directory, 'package.json'), '{}\n');
    fs.writeFileSync(path.join(directory, 'package-lock.json'), '{}\n');
  }
  const selectedNode = mode === 'updated-engines' ? '24.19.0' : '24.18.1';
  const selectedNpm = mode === 'updated-engines' ? '11.17.0' : '11.16.0';
  fs.writeFileSync(path.join(f.work, 'package.json'), JSON.stringify({ engines: { node: selectedNode, npm: selectedNpm } }));
  const archiveRoot = path.join(f.root, 'archive');
  const bin = path.join(archiveRoot, `node-v${selectedNode}-linux-x64/bin`); fs.mkdirSync(bin, { recursive: true });
  const cli = path.join(bin, '../lib/node_modules/npm/bin'); fs.mkdirSync(cli, { recursive: true });
  fs.writeFileSync(path.join(cli, 'npm-cli.js'), 'fixture');
  fs.writeFileSync(path.join(cli, 'npx-cli.js'), 'fixture');
  fs.writeFileSync(path.join(cli, '../package.json'), JSON.stringify({ version: selectedNpm }));
  for (const executable of ['node']) {
    fs.writeFileSync(path.join(bin, executable), `#!${process.execPath}
const fs = require('node:fs'), args = process.argv.slice(2);
const executable = args[0]?.endsWith('npm-cli.js') ? 'npm' : 'node';
if (executable === 'npm') args.shift();
fs.appendFileSync(process.env.TEST_LOG, JSON.stringify([executable, ...args])+'\\n');
if (executable === 'npm') {
  if (process.env.NPM_CONFIG_SCRIPT_SHELL || process.env.npm_config_script_shell ||
      fs.readFileSync(process.env.npm_config_userconfig, 'utf8') !== '' ||
      fs.readFileSync(process.env.npm_config_globalconfig, 'utf8') !== '' ||
      process.env.NODE_OPTIONS || process.env.NODE_PATH ||
      process.env.npm_config_ignore_scripts !== 'true') process.exit(97);
  if (args.includes('ci') && !args.includes('--ignore-scripts')) process.exit(98);
}
if (args.includes('--version')) console.log(executable === 'node' ? '${mode === 'wrong-node' ? 'v0.0.0' : 'v' + selectedNode}' : '${mode === 'wrong-npm' ? '0.0.0' : selectedNpm}');
`, { mode: 0o700 });
  }
  const archive = path.join(f.root, 'fixture.tar.xz');
  const tar = spawnSync('/usr/bin/tar', ['-cJf', archive, '-C', archiveRoot, fs.readdirSync(archiveRoot)[0]], { encoding: 'utf8' });
  assert.equal(tar.status, 0, tar.stderr);
  fs.writeFileSync(path.join(workflows, 'ci-toolchain.json'), JSON.stringify(runtimePin(createHash('sha256').update(fs.readFileSync(archive)).digest('hex'))));
  const curl = path.join(f.root, 'curl');
  fs.writeFileSync(curl, `#!${process.execPath}
const fs = require('node:fs'), args = process.argv.slice(2);
${fq40CurlQueryStub}
fs.appendFileSync(process.env.TEST_LOG, JSON.stringify(['curl', ...args])+'\\n');
fs.copyFileSync(${JSON.stringify(archive)}, args[args.indexOf('--output')+1]);
`, { mode: 0o700 });
  fs.writeFileSync(path.join(workflows, 'Initialize-CiToolchain.ps1'),
    read('Initialize-CiToolchain.ps1').replaceAll('/usr/bin/curl', curl));
  const result = f.run(`& ${quote(path.join(workflows, 'Initialize-CiToolchain.ps1'))} -WorkflowDependencies -InstructionDependencies`,
    { NPM_CONFIG_SCRIPT_SHELL: 'hostile', npm_config_ignore_scripts: 'false', npm_config_userconfig: '/hostile' });
  if (mode.startsWith('wrong-')) {
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /installed (Node|npm) version is incorrect/);
    assert.ok(f.calls().every(row => !row.includes('ci')));
    return;
  }
  assert.equal(result.status, 0, result.stderr);
  assert.equal(f.calls().find(row => row[0] === 'curl').at(-1),
    `https://nodejs.org/dist/v${selectedNode}/node-v${selectedNode}-linux-x64.tar.xz`);
  const calls = f.calls().filter(row => ['node', 'npm'].includes(row[0]));
  assert.deepEqual(calls.map(row => row.includes('ci') ? 'ci' : row.at(-1)),
    ['--version', '--version', '--preflight', 'ci', '--preflight', 'ci']);
});
}

test('runtime preflight uses one read grant for a spaced repository and denies writes and child processes', { skip: !linux }, t => {
  const f = fixture(t, 'repository with spaces'), workflows = path.join(f.work, '.github/workflows');
  fs.mkdirSync(workflows, { recursive: true });
  const repository = path.resolve(directory, '../..');
  const rootManifest = JSON.parse(fs.readFileSync(path.join(repository, 'package.json')));
  assert.equal(process.version, `v${rootManifest.engines.node}`);
  for (const name of ['package.json', 'package-lock.json']) {
    fs.copyFileSync(path.join(repository, name), path.join(f.work, name));
    fs.copyFileSync(path.join(directory, name), path.join(workflows, name));
  }
  for (const name of ['workflow-policy-contract.json', 'Validate-WorkflowPolicy.mjs']) {
    fs.copyFileSync(path.join(directory, name), path.join(workflows, name));
  }
  fs.writeFileSync(path.join(workflows, 'Test-CheckoutCredentials.ps1'),
    read('Test-CheckoutCredentials.ps1').replaceAll('/usr/bin/git', f.git).replaceAll("'/bin/git'", quote(f.git)));

  const archiveRoot = path.join(f.root, 'archive'), bin = path.join(archiveRoot, `node-v${rootManifest.engines.node}-linux-x64/bin`);
  fs.mkdirSync(bin, { recursive: true });
  fs.copyFileSync(process.execPath, path.join(bin, 'node')); fs.chmodSync(path.join(bin, 'node'), 0o755);
  const cli = path.join(bin, '../lib/node_modules/npm/bin'); fs.mkdirSync(cli, { recursive: true });
  fs.writeFileSync(path.join(cli, 'npx-cli.js'), 'fixture');
  fs.writeFileSync(path.join(cli, '../package.json'), JSON.stringify({ version: rootManifest.engines.npm }));
  fs.writeFileSync(path.join(cli, 'npm-cli.js'), `
const fs = require('node:fs'), args = process.argv.slice(2);
fs.appendFileSync(process.env.TEST_LOG, JSON.stringify(['npm', ...args])+'\\n');
if (args.includes('--version')) console.log('${rootManifest.engines.npm}');
`, { mode: 0o700 });
  const archive = path.join(f.root, 'runtime.tar.xz');
  const tar = spawnSync('/usr/bin/tar', ['-cJf', archive, '-C', archiveRoot, fs.readdirSync(archiveRoot)[0]], { encoding: 'utf8' });
  assert.equal(tar.status, 0, tar.stderr);
  fs.writeFileSync(path.join(workflows, 'ci-toolchain.json'), JSON.stringify(runtimePin(createHash('sha256').update(fs.readFileSync(archive)).digest('hex'))));
  const curl = path.join(f.root, 'curl');
  fs.writeFileSync(curl, `#!${process.execPath}
const fs = require('node:fs'), args = process.argv.slice(2);
${fq40CurlQueryStub}
fs.appendFileSync(process.env.TEST_LOG, JSON.stringify(['curl'])+'\\n');
fs.copyFileSync(${JSON.stringify(archive)}, args[args.indexOf('--output')+1]);
`, { mode: 0o700 });
  const initializer = path.join(workflows, 'Initialize-CiToolchain.ps1');
  fs.writeFileSync(initializer, read('Initialize-CiToolchain.ps1').replaceAll('/usr/bin/curl', curl));

  const positive = f.run(`& ${quote(initializer)} -WorkflowDependencies -InstructionDependencies`);
  assert.equal(positive.status, 0, positive.stderr);
  assert.deepEqual(f.calls().filter(row => row[0] === 'npm').map(row => row.includes('ci') ? 'ci' : row.at(-1)),
    ['--version', 'ci', 'ci']);

  fs.rmSync(path.join(f.root, 'styleguide-node'), { recursive: true });
  const validatorPath = path.join(workflows, 'Validate-WorkflowPolicy.mjs');
  const validator = fs.readFileSync(validatorPath, 'utf8');
  const marker = path.join(f.root, 'preflight-write');
  const probe = `import fsProbe from 'node:fs';
import { execFileSync as execFileSyncProbe } from 'node:child_process';
if (globalThis.process.argv.includes('--preflight')) {
    try { fsProbe.writeFileSync(${JSON.stringify(marker)}, 'unexpected'); process.stderr.write('WRITE_ALLOWED\\n'); }
    catch (error) { process.stderr.write('WRITE_' + error.code + '\\n'); }
    try { execFileSyncProbe('/bin/true'); process.stderr.write('CHILD_ALLOWED\\n'); }
    catch (error) { process.stderr.write('CHILD_' + error.code + '\\n'); }
    throw new Error('permission denial probes completed');
}
`;
  fs.writeFileSync(validatorPath, probe + validator);
  const denied = f.run(`& ${quote(initializer)} -WorkflowDependencies -InstructionDependencies`);
  assert.notEqual(denied.status, 0);
  assert.match(denied.stderr, /WRITE_ERR_ACCESS_DENIED/);
  assert.match(denied.stderr, /CHILD_ERR_ACCESS_DENIED/);
  assert.equal(fs.existsSync(marker), false);
  assert.equal(f.calls().filter(row => row[0] === 'npm' && row.includes('ci')).length, 2);
});

test('accepted PR-data loader rejects failed fetch and wrong or missing objects before classification', { skip: !linux }, t => {
  const source = parse(read('agent-instructions.yml')).jobs['accepted-policy'].steps.find(step => step.id === 'validate').run;
  for (const mode of ['fetch-failure', 'wrong-head', 'empty-output']) {
    const f = fixture(t), workflows = path.join(f.work, '.github/workflows');
    fs.mkdirSync(workflows, { recursive: true });
    fs.writeFileSync(path.join(workflows, 'Test-CheckoutCredentials.ps1'),
      read('Test-CheckoutCredentials.ps1').replaceAll('/usr/bin/git', f.git).replaceAll("'/bin/git'", quote(f.git)));
    const result = f.run(source, { EXPECTED_BASE: base, EXPECTED_HEAD: head, TEST_MODE: mode });
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, mode === 'fetch-failure' ? /PR data fetch failed after three attempts/ : /PR data commit mismatch/);
    assert.equal(f.calls().filter(row => row.includes('fetch')).length, mode === 'fetch-failure' ? 3 : 1);
  }
});

for (const layout of ['modern', 'pre-declaration', 'legacy']) {
  test(`Copilot digest failure identifies its ${layout} declaration before extraction`, { skip: !linux }, t => {
    const f = fixture(t), workflows = path.join(f.work, '.github/workflows');
    fs.mkdirSync(workflows, { recursive: true });
    const manifest = JSON.parse(fs.readFileSync(path.resolve(directory, '../../package.json')));
    if (layout === 'pre-declaration') manifest.engines.node = '24.18.0';
    fs.writeFileSync(path.join(f.work, 'package.json'), JSON.stringify(manifest));
    if (layout === 'modern') fs.copyFileSync(path.join(directory, 'ci-toolchain.json'), path.join(workflows, 'ci-toolchain.json'));
    const curl = path.join(f.root, 'curl'), tar = path.join(f.root, 'tar');
    fs.writeFileSync(curl, `#!${process.execPath}
const fs = require('node:fs'), args = process.argv.slice(2);
fs.appendFileSync(process.env.TEST_LOG, JSON.stringify(['curl'])+'\\n');
fs.writeFileSync(args[args.indexOf('--output')+1], 'wrong archive bytes');
`, { mode: 0o700 });
    fs.writeFileSync(tar, `#!/bin/sh
printf '%s\\n' '["tar"]' >> "$TEST_LOG"
exit 98
`, { mode: 0o700 });
    const step = parse(read('copilot-setup-steps.yml')).jobs['copilot-setup-steps'].steps.find(value => value.name === 'Set up verified official Node.js runtime');
    const source = step.run.replaceAll("'/usr/bin/curl'", quote(curl)).replaceAll("'/bin/curl'", quote(curl))
      .replaceAll("'/usr/bin/tar'", quote(tar)).replaceAll("'/bin/tar'", quote(tar));
    const result = f.run(source, { TOOLCHAIN_LAYOUT: layout === 'legacy' ? 'legacy' : 'modern' });
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /does not match the reviewed digest/);
    assert.ok(result.stderr.includes(layout === 'legacy' ? 'node-v20.20.2-linux-x64.tar.xz' : `node-v${manifest.engines.node}-linux-x64.tar.xz`));
    assert.match(result.stderr, layout === 'modern' ? /ci-toolchain\.json/ : /copilot-setup-steps\.yml/);
    assert.deepEqual(f.calls(), [['curl']]);
    assert.equal(fs.existsSync(path.join(f.root, 'agent-validation-node')), false);
  });
}

function artifactRoleSource(role) {
  const descriptors = {
    PowerShellExamples: `# BEGIN LANGUAGE DESCRIPTOR
$script:hashtableArtifactLanguage = @{
    ScopedId = 'powershell-instructions'
    ScopedPath = 'powershell.instructions.md'
    SemanticRole = 'PowerShellExamples'
}
# END LANGUAGE DESCRIPTOR`,
    TerraformRecovery: `# BEGIN LANGUAGE DESCRIPTOR
$script:hashtableArtifactLanguage = @{
    ScopedId = 'terraform-instructions'
    ScopedPath = 'terraform.instructions.md'
    SemanticRole = 'TerraformRecovery'
}
# END LANGUAGE DESCRIPTOR`,
  };
  assert.ok(Object.hasOwn(descriptors, role), 'The fixture requires a fixed semantic role.');
  const source = read('Test-StyleGuideArtifacts.ps1');
  const pattern = /# BEGIN LANGUAGE DESCRIPTOR[\s\S]*?# END LANGUAGE DESCRIPTOR/gu;
  const blocks = [...source.matchAll(pattern)];
  assert.equal(blocks.length, 1);
  return source.replace(pattern, descriptors[role]);
}

for (const mode of ['clean', 'stale', 'semantic-failure', 'semantic-side-effect',
  'verifier-channel', 'verifier-config', 'verifier-worktree', 'verifier-failure',
  'generator-native', 'generator-result', 'generator-schema', 'generator-hostile',
  'generator-json', 'generator-nonobject', 'generator-count', 'generator-order', 'generator-path',
  'verifier-json', 'verifier-nonobject', 'verifier-native', 'verifier-schema', 'semantic-artifact']) {
  test(`artifact gate includes verifier child effects: ${mode}`, { skip: !linux }, t => {
    const root = fs.mkdtempSync(path.join(os.tmpdir(), 'styleguide-artifact-child-'));
    t.after(() => fs.rmSync(root, { recursive: true, force: true }));
    const work = path.join(root, 'work'), scripts = path.join(work, '.github/workflows');
    fs.mkdirSync(scripts, { recursive: true });
    const records = [['copilot', 'copilot-instructions.md'], ['powershell-instructions', 'powershell.instructions.md'],
      ['chat', 'STYLE_GUIDE_CHAT.md'], ['full', 'STYLE_GUIDE_FULL.md']];
    for (const [, name] of records) fs.writeFileSync(path.join(work, name), 'committed fixture\n');
    fs.writeFileSync(path.join(scripts, 'Test-StyleGuideArtifacts.ps1'), artifactRoleSource('PowerShellExamples'));
    fs.writeFileSync(path.join(work, 'STYLE_GUIDE.md'), [
      '# PowerShell Writing Style', '',
      '### Examples', '',
      '**Compliant example:**', '',
      '```powershell', '{', '    Invoke-First', '', '    Invoke-Second', '}', '```', '',
      '**Non-Compliant example:**', '',
      'The `␠` glyph is an illustration marker and is not PowerShell syntax. Do not copy it.', '',
      '```powershell', '{', '    Invoke-First', '␠', '    Invoke-Second', '}', '```', '',
    ].join('\n'));
    // Isolate the wrapper interface; the real PS gate still checks guide semantics.
    fs.writeFileSync(path.join(scripts, 'Test-BlankLineExamples.ps1'),
      "Write-Output 'Blank-line example semantics passed, including focused mutation checks.'\n" +
      `exit ${mode === 'semantic-failure' ? 7 : 0}\n`);
    const generation = { Schema: 'StyleGuide.GeneratorResult.v2', Overall: 'NoChange', Phase: 'complete',
      Category: 'none', NativeOutcome: 'Success', ExitCode: 0,
      Artifacts: records.map(([ArtifactId, Path]) => ({ ArtifactId, Path, Status: 'NoChange' })) };
    if (mode === 'generator-result') generation.ExitCode = 4;
    if (mode === 'generator-schema') generation.Schema = 'wrong';
    if (mode === 'generator-count') generation.Artifacts.pop();
    if (mode === 'generator-order') generation.Artifacts.reverse();
    if (mode === 'generator-path') generation.Artifacts[0].Path = '../escape';
    if (mode === 'generator-hostile') for (const field of ['Schema', 'Overall', 'Phase', 'Category', 'NativeOutcome', 'ExitCode']) {
      generation[field] = 'UNTRUSTED-' + 'x'.repeat(2000);
    }
    const generatorJson = mode === 'generator-json' ? '{' : mode === 'generator-nonobject' ? '[]' : JSON.stringify(generation);
    fs.writeFileSync(path.join(scripts, 'Generate-StyleGuideArtifacts.ps1'),
      (mode === 'stale' ? "[IO.File]::WriteAllText('STYLE_GUIDE_CHAT.md', 'regenerated fixture')\n" : '') +
      quote(generatorJson) + `\nexit ${mode === 'generator-native' ? 7 : 0}\n`);
    const mutation = {
      'verifier-channel': "[IO.File]::AppendAllText($env:GITHUB_OUTPUT, 'fixture=changed')",
      'verifier-config': "[IO.File]::AppendAllText((Join-Path $env:GITHUB_WORKSPACE '.git/config'), \"`n# changed by verifier`n\")",
      'verifier-worktree': "[IO.File]::WriteAllText('unexpected.txt', 'changed by verifier')",
    }[mode] ?? '';
    if (['semantic-side-effect', 'semantic-artifact'].includes(mode)) {
      fs.writeFileSync(path.join(scripts, 'Test-BlankLineExamples.ps1'),
        `[IO.File]::WriteAllText('${mode === "semantic-artifact" ? "STYLE_GUIDE_CHAT.md" : "unexpected.txt"}', 'changed by semantic verifier')\n` +
        "Write-Output 'Blank-line example semantics passed, including focused mutation checks.'\nexit 0\n");
    }
    const verifierFails = ['stale', 'verifier-failure'].includes(mode);
    fs.writeFileSync(path.join(scripts, 'Test-ExactGitPathSet.ps1'), mutation + '\n' +
      quote(mode === 'verifier-json' ? '{' : mode === 'verifier-nonobject' ? '[]' : JSON.stringify({ Schema: mode === 'verifier-schema' ? 'wrong' : 'StyleGuide.ExactGitPathSetResult.v2', Success: !verifierFails })) +
      `\nexit ${verifierFails || mode === 'verifier-native' ? 1 : 0}\n`);
    const env = { ...process.env, GITHUB_WORKSPACE: work, GIT_CONFIG_NOSYSTEM: '1',
      GIT_CONFIG_GLOBAL: '/dev/null', GIT_TERMINAL_PROMPT: '0' };
    for (const key of ['GITHUB_TOKEN', 'GH_TOKEN', 'ACTIONS_RUNTIME_TOKEN', 'GIT_CONFIG_COUNT', 'GIT_CONFIG_PARAMETERS']) delete env[key];
    for (const key of ['GITHUB_ENV', 'GITHUB_PATH', 'GITHUB_OUTPUT', 'GITHUB_STEP_SUMMARY']) {
      env[key] = path.join(root, key); fs.writeFileSync(env[key], '');
    }
    for (const args of [['init', '-q'], ['add', '-A'],
      ['-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid', 'commit', '-qm', 'Artifact fixture']]) {
      const result = spawnSync('/usr/bin/git', args, { cwd: work, env, encoding: 'utf8', timeout: 30000 });
      assert.equal(result.status, 0, result.stdout + result.stderr);
    }
    const result = spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File',
      path.join(scripts, 'Test-StyleGuideArtifacts.ps1')], { cwd: work, env, encoding: 'utf8', timeout: 30000 });
    assert.equal(result.status, mode === 'clean' ? 0 : 1, result.stdout + result.stderr);
    const expected = { clean: /committed bytes match generator output/, stale: /Generate-StyleGuideArtifacts\.ps1/,
      'semantic-failure': /blank-line semantic check failed/i,
      'semantic-side-effect': /git-state: a child changed a path outside the four permitted generated artifacts/,
      'verifier-channel': /runner-state/, 'verifier-config': /configuration or hooks/,
      'verifier-worktree': /outside the four/, 'verifier-failure': /Exact-path verification did not confirm/,
      'generator-native': /NativeExit/, 'generator-result': /ResultExitCode/, 'generator-schema': /Schema/,
      'generator-hostile': /Artifact generation failed result checks: Schema, Overall, Phase, Category, NativeOutcome, ResultExitCode\./,
      'generator-json': /invalid JSON/, 'generator-nonobject': /non-object/, 'generator-count': /record count/,
      'generator-order': /invalid artifact record/, 'generator-path': /invalid artifact record/,
      'verifier-json': /invalid JSON/, 'verifier-nonobject': /did not confirm/,
      'verifier-native': /did not confirm/, 'verifier-schema': /did not confirm/,
      'semantic-artifact': /outside the four/ }[mode];
    const diagnostic = result.stdout + result.stderr;
    assert.equal(diagnostic.includes('UNTRUSTED-'), false, 'hostile result values must not enter diagnostics');
    // PowerShell may decorate and wrap the same diagnostic across renderer lines.
    // Normalize only presentation; retain the full message and ordered labels.
    const renderedDiagnostic = ['semantic-side-effect', 'generator-hostile'].includes(mode)
      ? diagnostic.replace(/\x1B\[[0-?]*[ -/]*[@-~]/gu, '')
        .replace(/^[ \t]*\|[ \t]?/gmu, '').replace(/\s+/gu, ' ')
      : diagnostic;
    assert.match(renderedDiagnostic, expected);
  });
}

for (const mode of ['clean', 'stale', 'verifier-channel', 'verifier-config', 'verifier-worktree', 'verifier-failure',
  'recovery-missing', 'recovery-failure', 'recovery-signal', 'recovery-timeout',
  'recovery-channel', 'recovery-config', 'recovery-source', 'recovery-self',
  'multiple-node-paths', 'first-node-failure']) {
  test(`artifact gate recovery role includes verifier child effects: ${mode}`, { skip: !linux }, t => {
    const root = fs.mkdtempSync(path.join(os.tmpdir(), 'styleguide-artifact-child-'));
    t.after(() => fs.rmSync(root, { recursive: true, force: true }));
    const work = path.join(root, 'work'), scripts = path.join(work, '.github/workflows');
    fs.mkdirSync(scripts, { recursive: true });
    const records = [['copilot', 'copilot-instructions.md'], ['terraform-instructions', 'terraform.instructions.md'],
      ['chat', 'STYLE_GUIDE_CHAT.md'], ['full', 'STYLE_GUIDE_FULL.md']];
    for (const [, name] of records) fs.writeFileSync(path.join(work, name), 'committed fixture\n');
    fs.writeFileSync(path.join(scripts, 'Test-StyleGuideArtifacts.ps1'), mode === 'recovery-timeout' ?
      artifactRoleSource('TerraformRecovery').replace('WaitForExit(300000)', 'WaitForExit(100)') : artifactRoleSource('TerraformRecovery'));
    fs.writeFileSync(path.join(work, 'STYLE_GUIDE.md'), 'source fixture\n');
    const recoveryCode = {
      'recovery-failure': 'process.exit(19);',
      'recovery-signal': "process.kill(process.pid, 'SIGTERM');",
      'recovery-timeout': 'setInterval(() => {}, 1000);',
      'recovery-channel': "fs.appendFileSync(process.env.GITHUB_OUTPUT, 'fixture=changed');",
      'recovery-config': "fs.appendFileSync('.git/config', '\\n# changed by recovery\\n');",
      'recovery-source': "fs.appendFileSync('STYLE_GUIDE.md', 'changed by recovery');",
      'recovery-self': "fs.appendFileSync(new URL(import.meta.url), '// changed by recovery');",
    }[mode] ?? '';
    if (mode !== 'recovery-missing') fs.writeFileSync(path.join(scripts, 'Test-StateRecoveryExamples.mjs'),
      "import fs from 'node:fs';\n" + recoveryCode + '\n');
    const generation = { Schema: 'StyleGuide.GeneratorResult.v2', Overall: 'NoChange', Phase: 'complete',
      Category: 'none', NativeOutcome: 'Success', ExitCode: 0,
      Artifacts: records.map(([ArtifactId, Path]) => ({ ArtifactId, Path, Status: 'NoChange' })) };
    fs.writeFileSync(path.join(scripts, 'Generate-StyleGuideArtifacts.ps1'),
      (mode === 'stale' ? "[IO.File]::WriteAllText('STYLE_GUIDE_CHAT.md', 'regenerated fixture')\n" : '') +
      quote(JSON.stringify(generation)) + '\nexit 0\n');
    const mutation = {
      'verifier-channel': "[IO.File]::AppendAllText($env:GITHUB_OUTPUT, 'fixture=changed')",
      'verifier-config': "[IO.File]::AppendAllText((Join-Path $env:GITHUB_WORKSPACE '.git/config'), \"`n# changed by verifier`n\")",
      'verifier-worktree': "[IO.File]::WriteAllText('unexpected.txt', 'changed by verifier')",
    }[mode] ?? '';
    const verifierFails = ['stale', 'verifier-failure'].includes(mode);
    fs.writeFileSync(path.join(scripts, 'Test-ExactGitPathSet.ps1'), mutation + '\n' +
      quote(JSON.stringify({ Schema: 'StyleGuide.ExactGitPathSetResult.v2', Success: !verifierFails })) +
      `\nexit ${verifierFails ? 1 : 0}\n`);
    const env = { ...process.env, GITHUB_WORKSPACE: work, GIT_CONFIG_NOSYSTEM: '1',
      GIT_CONFIG_GLOBAL: '/dev/null', GIT_TERMINAL_PROMPT: '0' };
    const runtimeLog = path.join(root, 'runtime-selection');
    if (['multiple-node-paths', 'first-node-failure'].includes(mode)) {
      const shellQuote = value => `'${value.replaceAll("'", "'\\''")}'`;
      const runtimeDirectories = ['first-runtime', 'second-runtime'].map(name => path.join(root, name));
      for (const [index, runtimeDirectory] of runtimeDirectories.entries()) {
        fs.mkdirSync(runtimeDirectory);
        const outcome = index === 0 && mode === 'multiple-node-paths' ?
          `exec ${shellQuote(process.execPath)} "$@"` : 'exit 23';
        fs.writeFileSync(path.join(runtimeDirectory, 'node'),
          `#!/bin/sh\nprintf '%s\\n' ${index} >> ${shellQuote(runtimeLog)}\n${outcome}\n`, { mode: 0o700 });
      }
      env.PATH = [...runtimeDirectories, env.PATH].join(path.delimiter);
    }
    for (const key of ['GITHUB_TOKEN', 'GH_TOKEN', 'ACTIONS_RUNTIME_TOKEN', 'GIT_CONFIG_COUNT', 'GIT_CONFIG_PARAMETERS']) delete env[key];
    for (const key of ['GITHUB_ENV', 'GITHUB_PATH', 'GITHUB_OUTPUT', 'GITHUB_STEP_SUMMARY']) {
      env[key] = path.join(root, key); fs.writeFileSync(env[key], '');
    }
    for (const args of [['init', '-q'], ['add', '-A'],
      ['-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid', 'commit', '-qm', 'Artifact fixture']]) {
      const result = spawnSync('/usr/bin/git', args, { cwd: work, env, encoding: 'utf8', timeout: 30000 });
      assert.equal(result.status, 0, result.stdout + result.stderr);
    }
    const result = spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File',
      path.join(scripts, 'Test-StyleGuideArtifacts.ps1')], { cwd: work, env, encoding: 'utf8', timeout: 30000 });
    assert.equal(result.status, ['clean', 'multiple-node-paths'].includes(mode) ? 0 : 1, result.stdout + result.stderr);
    const expected = { clean: /committed bytes match generator output/, stale: /Generate-StyleGuideArtifacts\.ps1/,
      'verifier-channel': /runner-state/, 'verifier-config': /configuration or hooks/,
      'verifier-worktree': /outside the four/, 'verifier-failure': /Exact-path verification did not confirm/,
      'recovery-missing': /state-recovery: published-example tests did not complete/,
      'recovery-failure': /state-recovery: published-example tests did not complete/,
      'recovery-signal': /state-recovery: published-example tests did not complete/,
      'recovery-timeout': /state-recovery: published-example tests did not complete/,
      'recovery-channel': /runner-state/, 'recovery-config': /configuration or hooks/,
      'recovery-source': /outside the four/, 'recovery-self': /outside the four/,
      'multiple-node-paths': /committed bytes match generator output/,
      'first-node-failure': /state-recovery: published-example tests did not complete/ }[mode];
    assert.match(result.stdout + result.stderr, expected);
    if (['multiple-node-paths', 'first-node-failure'].includes(mode)) {
      assert.equal(fs.readFileSync(runtimeLog, 'utf8'), '0\n', 'select the first application once; never fall back after failure');
    }
  });
}

for (const setupWorkflowName of ['copilot-setup-steps.yml', 'copilot-code-review.yml']) {
  for (const mode of ['fetch-failure', 'retry-success', 'checkout-failure']) {
    test(`${setupWorkflowName}: Copilot acquisition retry: ${mode}`, { skip: !linux }, t => {
      const source = parse(read(setupWorkflowName)).jobs['copilot-setup-steps'].steps.find(step => step.id === 'acquire').run;
      const f = fixture(t), result = f.run(source, { TEST_MODE: mode });
      assert.equal(result.status === 0, mode === 'retry-success', result.stderr);
      const fetches = f.calls().filter(row => row.includes('fetch'));
      assert.equal(fetches.length, mode === 'checkout-failure' ? 1 : 3);
      assert.ok(fetches.every(row => row.at(-1) === head && row.includes('--no-tags') && row.includes('--no-recurse-submodules')));
      assert.equal(f.calls().filter(row => row.includes('checkout')).length, mode === 'fetch-failure' ? 0 : 1);
      if (mode === 'fetch-failure') assert.match(result.stderr, /git fetch exited 7 after three attempts/);
      if (mode === 'checkout-failure') assert.match(result.stderr, /git checkout exited 23/);
    });
  }

  for (const mode of ['', 'identity-native-failure', 'identity-multiline', 'empty-output', 'wrong-head']) {
    test(`${setupWorkflowName}: Copilot Git identity failure: ${mode || 'success'}`, { skip: !linux }, t => {
      const source = parse(read(setupWorkflowName)).jobs['copilot-setup-steps'].steps.find(step => step.id === 'acquire').run;
      const f = fixture(t), result = f.run(source, { TEST_MODE: mode });
      assert.equal(result.status === 0, mode === '', result.stderr);
      assert.equal(f.calls().filter(row => row.includes('checkout')).length, 1);
      if (mode === 'identity-native-failure') assert.match(result.stderr, /git rev-parse exited 31/);
      if (['identity-multiline', 'empty-output'].includes(mode)) assert.match(result.stderr, /exactly one line/);
      if (mode === 'wrong-head') assert.match(result.stderr, /not the triggering revision/);
    });
  }

  for (const format of ['historical-flat', 'schema2']) for (const mode of ['', 'download-failure', 'wrong-digest', 'version-failure', 'version-empty', 'version-multiline', 'version-wrong']) {
    test(`${setupWorkflowName}: Copilot ${format} runtime failure: ${mode || 'success'}`, { skip: !linux }, t => {
      const f = fixture(t), workflows = path.join(f.work, '.github/workflows');
      fs.mkdirSync(workflows, { recursive: true });
      const manifest = JSON.parse(fs.readFileSync(path.resolve(directory, '../../package.json')));
      fs.writeFileSync(path.join(f.work, 'package.json'), JSON.stringify(manifest));
      const archiveRoot = path.join(f.root, 'archive'), bin = path.join(archiveRoot, 'runtime/bin');
      fs.mkdirSync(bin, { recursive: true });
      fs.writeFileSync(path.join(bin, 'node'), `#!${process.execPath}
  const mode = process.env.TEST_MODE;
  if (mode === 'version-failure') process.exit(29);
  if (mode === 'version-empty') process.exit(0);
  if (mode === 'version-multiline') console.log('v${manifest.engines.node}');
  console.log(mode === 'version-wrong' ? 'v0.0.0' : 'v${manifest.engines.node}');
  `, { mode: 0o700 });
      fs.writeFileSync(path.join(bin, 'npm'), '#!/bin/sh\nexit 0\n', { mode: 0o700 });
      const archive = path.join(f.root, 'runtime.tar.xz');
      const packed = spawnSync('/usr/bin/tar', ['-cJf', archive, '-C', archiveRoot, 'runtime'], { encoding: 'utf8' });
      assert.equal(packed.status, 0, packed.stderr);
      const digest = mode === 'wrong-digest' ? 'b'.repeat(64) : createHash('sha256').update(fs.readFileSync(archive)).digest('hex');
      fs.writeFileSync(path.join(workflows, 'ci-toolchain.json'), JSON.stringify(format === 'schema2' ? copilotReaderPin(digest) : { linuxX64Sha256: digest }));
      const curl = path.join(f.root, 'curl');
      fs.writeFileSync(curl, `#!${process.execPath}
  const fs = require('node:fs'), args = process.argv.slice(2);
  fs.appendFileSync(process.env.TEST_LOG, JSON.stringify(['curl', ...args])+'\\n');
  if (process.env.TEST_MODE === 'download-failure') process.exit(28);
  fs.copyFileSync(${JSON.stringify(archive)}, args[args.indexOf('--output') + 1]);
  `, { mode: 0o700 });
      const source = parse(read(setupWorkflowName)).jobs['copilot-setup-steps'].steps
        .find(step => step.name === 'Set up verified official Node.js runtime').run
        .replaceAll("'/usr/bin/curl'", quote(curl)).replaceAll("'/bin/curl'", quote(curl));
      const result = f.run(source, { TOOLCHAIN_LAYOUT: 'modern', TEST_MODE: mode });
      assertReaderCompleted(result, `${setupWorkflowName}/${format}/${mode || 'success'}`);
      assert.equal(result.status === 0, mode === '', result.stderr);
      const request = f.calls().find(row => row[0] === 'curl');
      assert.equal(request[1], '--disable');
      assert.ok(request.includes('--retry-all-errors'));
      assert.ok(request.includes('--tlsv1.2'));
      assert.equal(request.at(-1), `https://nodejs.org/dist/v${manifest.engines.node}/node-v${manifest.engines.node}-linux-x64.tar.xz`);
      for (const [flag, value] of [['--proto', '=https'], ['--proto-redir', '=https'], ['--retry', '3'], ['--connect-timeout', '20'], ['--max-time', '120'], ['--retry-max-time', '300']]) {
        assert.ok(request.includes(flag), `Missing curl option: ${flag}`);
        assert.equal(request[request.indexOf(flag) + 1], value);
      }
      if (mode === 'download-failure') assert.match(result.stderr, /download exited 28/);
      if (mode === 'wrong-digest') {
        assert.match(result.stderr, /official Node archive does not match the reviewed digest/);
        const declarationPath = '.github/workflows/ci-toolchain.json';
        const field = format === 'schema2' ? 'preferred.linuxX64Sha256' : 'linuxX64Sha256';
        const colored = result.stderr.split('\n').map(line => `\u001b[31m${line}\u001b[0m`).join('\n');
        for (const diagnosticText of [result.stderr, colored]) {
          assertCopilotDigestDeclaration(diagnosticText, format);
          const diagnosticMutations = [
            ['wrong-path', diagnosticText.replaceAll(declarationPath, '.github/workflows/other-toolchain.json')],
            ['missing-path', diagnosticText.replaceAll(declarationPath, '')],
            ['wrong-field', diagnosticText.replaceAll(field,
              format === 'schema2' ? 'recoveryCompatibility.linuxX64Sha256' : 'windowsX64Sha256')],
            ['missing-field', diagnosticText.replaceAll(field, '')],
            ['misordered-field', diagnosticText.replaceAll(field, '').replaceAll(declarationPath, `${field} ${declarationPath}`)],
          ];
          for (const [mutation, mutated] of diagnosticMutations) {
            const context = `${setupWorkflowName}/${format}/${mutation}`;
            assert.notEqual(mutated, diagnosticText, `${context}: control must change actual native stderr.`);
            assert.throws(() => assertCopilotDigestDeclaration(mutated, format),
              { name: 'AssertionError', code: 'ERR_ASSERTION' }, `${context}: incorrect declaration must be refused.`);
          }
        }
        assert.equal(fs.existsSync(path.join(f.root, 'agent-validation-node')), false, 'Digest failure must precede extraction.');
      }
      if (mode === 'version-failure') assert.match(result.stderr, /version command exited 29/);
      if (['version-empty', 'version-multiline'].includes(mode)) assert.match(result.stderr, /exactly one line/);
      if (mode === 'version-wrong') assert.match(result.stderr, /identity is wrong/);
      if (mode) assert.equal(fs.existsSync(path.join(f.root, 'path')), false);
      else assert.equal(fs.readFileSync(path.join(f.root, 'path'), 'utf8'), `${path.join(f.root, 'agent-validation-node/bin')}\n`);
    });
  }

  for (const [stepName, commands] of [
    ['Verify selected Node.js runtime', 1],
    ['Install locked Node.js validation tools', 3],
    ['Verify locked dependency trees and immutable manifests', 3],
  ]) {
    test(`${setupWorkflowName}: Copilot npm configuration in each process: ${stepName}`, { skip: !linux }, t => {
      const f = fixture(t), bin = path.join(f.root, 'bin'); fs.mkdirSync(bin);
      const log = path.join(f.root, 'npm-calls');
      for (const executable of ['node', 'npm', 'git']) {
        fs.writeFileSync(path.join(bin, executable), `#!${process.execPath}
  const fs = require('node:fs'), args = process.argv.slice(2);
  if ('${executable}' === 'npm') {
    if (Object.keys(process.env).some(key => /^npm_config_/i.test(key) &&
        !['npm_config_userconfig', 'npm_config_globalconfig'].includes(key)) ||
        process.env.npm_config_userconfig !== '/dev/null' ||
        process.env.npm_config_globalconfig !== '/etc/npmrc-absent-by-policy' ||
        process.env.UNRELATED_FIXTURE !== 'keep this value') process.exit(97);
    fs.appendFileSync(${JSON.stringify(log)}, JSON.stringify(args)+'\\n');
    if (args.includes('--version')) console.log('11.16.0');
  } else if ('${executable}' === 'node') console.log(args.includes('--version') ? 'v24.18.1' : args.join(' ').includes('engines.npm') ? '11.16.0' : '24.18.1');
  `, { mode: 0o700 });
      }
      const steps = parse(read(setupWorkflowName)).jobs['copilot-setup-steps'].steps;
      const env = { ...process.env, PATH: `${bin}:${process.env.PATH}`, TOOLCHAIN_LAYOUT: 'modern',
        GITHUB_ENV: path.join(f.root, 'step-env'), NPM_CONFIG_SCRIPT_SHELL: 'hostile',
        npm_Config_Registry: 'https://invalid.example', npm_config_ignore_scripts: 'false',
        npm_config_userconfig: '/hostile', UNRELATED_FIXTURE: 'keep this value',
        'npm_config_@audit:registry': 'https://example.invalid',
        'npm_config_//registry.npmjs.org/:_authToken': 'dummy-fixture-token',
        'NPM_CONFIG_unsafe-name': 'line one\nline two' };
      for (const name of ['GITHUB_TOKEN', 'GH_TOKEN', 'ACTIONS_RUNTIME_TOKEN', 'GIT_CONFIG_COUNT', 'GIT_CONFIG_PARAMETERS']) delete env[name];
      const run = (name, stepEnv) => spawnSync('bash', ['--noprofile', '--norc', '-c', steps.find(step => step.name === name).run],
        { cwd: f.work, env: stepEnv, encoding: 'utf8' });
      const first = run('Verify selected Node.js runtime', env);
      assert.equal(first.status, 0, first.stderr);
      const published = Object.fromEntries(fs.readFileSync(env.GITHUB_ENV, 'utf8').trim().split('\n').map(line => {
        const separator = line.indexOf('='); return [line.slice(0, separator), line.slice(separator + 1)];
      }));
      assert.deepEqual(published, { npm_config_userconfig: '/dev/null', npm_config_globalconfig: '/etc/npmrc-absent-by-policy' });
      if (stepName !== 'Verify selected Node.js runtime') {
        const next = run(stepName, { ...env, ...published });
        assert.equal(next.status, 0, `${stepName}: ${next.stderr}`);
      }
      assert.equal(fs.readFileSync(log, 'utf8').trim().split('\n').length, commands);
    });
  }

  test(`${setupWorkflowName}: Copilot npm rejects failed or partial environment enumeration before npm`, { skip: !linux }, t => {
    const steps = parse(read(setupWorkflowName)).jobs['copilot-setup-steps'].steps;
    for (const name of ['Verify selected Node.js runtime', 'Install locked Node.js validation tools', 'Verify locked dependency trees and immutable manifests']) {
      for (const partial of [false, true]) {
        const f = fixture(t), bin = path.join(f.root, 'bin'); fs.mkdirSync(bin);
        fs.writeFileSync(path.join(bin, 'npm'), `#!/bin/sh
  printf '%s\\n' 'unexpected npm invocation' >> "$TEST_LOG"
  exit 98
  `, { mode: 0o700 });
        const source = steps.find(step => step.name === name).run.replace('/usr/bin/env -0',
          (partial ? "printf 'npm_config_registry=fixture\\0'; " : '') + 'exit 71');
        const env = { ...process.env, PATH: `${bin}:${process.env.PATH}`, TEST_LOG: f.log,
          TOOLCHAIN_LAYOUT: 'modern', GITHUB_ENV: path.join(f.root, 'step-env') };
        for (const key of ['GITHUB_TOKEN', 'GH_TOKEN', 'ACTIONS_RUNTIME_TOKEN', 'GIT_CONFIG_COUNT', 'GIT_CONFIG_PARAMETERS']) delete env[key];
        const result = spawnSync('bash', ['--noprofile', '--norc', '-c', source], { cwd: f.work, env, encoding: 'utf8' });
        assertCompletedProcess(result, `${setupWorkflowName}: ${name}: partial=${partial}`);
        assert.notEqual(result.status, 0);
        assert.match(result.stdout + result.stderr, /Unable to read the package-manager environment/);
        assert.equal(fs.existsSync(f.log), false);
      }
    }
  });

}

function devcontainerWorkflow() {
  const workflow = parse(read('devcontainer-ci.yml'));
  const job = workflow.jobs['validate-no-devcontainer-contract'];
  return { workflow, job, source: job.steps[0].run };
}

test('devcontainer workflow preserves native snapshot and unprivileged job shape', () => {
  const { workflow, job, source } = devcontainerWorkflow();
  assert.deepEqual(workflow.permissions, {});
  assert.deepEqual(workflow.on, { workflow_dispatch: null, push: null, pull_request: null,
    merge_group: { types: ['checks_requested'] }, schedule: [{ cron: '23 06 * * 1' }] });
  assert.deepEqual(workflow.concurrency, {
    group: 'devcontainer-boundary-${{ github.workflow }}-${{ github.ref }}', 'cancel-in-progress': false,
  });
  assert.deepEqual(Object.keys(workflow.jobs), ['validate-no-devcontainer-contract']);
  assert.deepEqual(Object.keys(job).sort(), ['env', 'name', 'runs-on', 'steps', 'timeout-minutes']);
  assert.equal(job['runs-on'], 'ubuntu-24.04');
  assert.equal(job['timeout-minutes'], 10);
  assert.deepEqual(job.env, { EXPECTED_REPOSITORY: '${{ github.repository }}',
    EXPECTED_REVISION: '${{ github.sha }}', EXPECTED_SERVER_URL: '${{ github.server_url }}' });
  assert.equal(job.steps.length, 1);
  assert.deepEqual(Object.keys(job.steps[0]).sort(), ['name', 'run', 'shell']);
  assert.equal(job.steps[0].shell, 'bash');
  assert.doesNotMatch(source, /\$\{\{|GITHUB_TOKEN|github\.token|git\s+checkout|git\s+switch/u);
});

// The actual YAML body runs in Bash. Only its absolute Git executable is replaced:
// the adapter asserts the HTTPS remote and fetch arguments, then substitutes a
// private file remote. Init, fetch, object identity and tree enumeration stay real.
// Explicit error modes inject one failing result; nothing checks out candidate code.
function devcontainerFixture(t, entries = [], includeMarker = true) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'styleguide-devcontainer-test-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const remote = path.join(root, 'remote.git'), runRoot = path.join(root, 'run');
  const callsFile = path.join(root, 'calls.jsonl'), marker = path.join(root, 'candidate-executed');
  fs.mkdirSync(runRoot);
  const env = { ...process.env, GIT_CONFIG_NOSYSTEM: '1', GIT_CONFIG_GLOBAL: '/dev/null',
    GIT_TERMINAL_PROMPT: '0', GIT_AUTHOR_NAME: 'Fixture', GIT_AUTHOR_EMAIL: 'fixture@example.invalid',
    GIT_COMMITTER_NAME: 'Fixture', GIT_COMMITTER_EMAIL: 'fixture@example.invalid',
    GIT_AUTHOR_DATE: '2000-01-01T00:00:00Z', GIT_COMMITTER_DATE: '2000-01-01T00:00:00Z' };
  for (const key of Object.keys(env)) {
    if (/^GIT_CONFIG_(?:COUNT|KEY_\d+|VALUE_\d+|PARAMETERS)$/u.test(key) ||
      ['GITHUB_TOKEN', 'GH_TOKEN', 'ACTIONS_RUNTIME_TOKEN', 'GIT_DIR', 'GIT_WORK_TREE',
        'GIT_INDEX_FILE', 'GIT_OBJECT_DIRECTORY', 'GIT_ALTERNATE_OBJECT_DIRECTORIES'].includes(key)) delete env[key];
  }
  function git(args, input) {
    const result = spawnSync('/usr/bin/git', args, { env, input, encoding: 'utf8', timeout: 10000 });
    assert.equal(result.error, undefined, result.error?.message);
    assert.equal(result.status, 0, result.stderr);
    return result.stdout.trim();
  }
  git(['init', '--bare', '--quiet', remote]);
  const object = (args, input) => git(['-C', remote, ...args], input);
  const blob = object(['hash-object', '-w', '--stdin'], 'inert fixture\n');
  const empty = object(['mktree'], '');
  const gitlink = object(['commit-tree', empty], 'inert submodule commit\n');
  const markerBlob = object(['hash-object', '-w', '--stdin'], `#!/bin/sh\ntouch '${marker}'\n`);
  const node = new Map();
  if (includeMarker) node.set('candidate-must-not-run.sh', { mode: '100755', type: 'blob', oid: markerBlob });
  for (const [file, type = 'blob'] of entries) {
    const parts = file.split('/'); let current = node;
    for (const component of parts.slice(0, -1)) {
      if (!current.has(component)) current.set(component, new Map());
      current = current.get(component);
    }
    current.set(parts.at(-1), type === 'tree' ? { mode: '040000', type, oid: empty } :
      type === 'commit' ? { mode: '160000', type, oid: gitlink } : { mode: '100644', type, oid: blob });
  }
  function writeTree(children) {
    const records = [...children].map(([name, value]) => {
      const entry = value instanceof Map ? { mode: '040000', type: 'tree', oid: writeTree(value) } : value;
      return `${entry.mode} ${entry.type} ${entry.oid}\t${name}\0`;
    }).join('');
    return object(['mktree', '-z'], records);
  }
  const revision = object(['commit-tree', writeTree(node)], 'candidate snapshot\n');
  const otherRevision = object(['commit-tree', empty], 'wrong snapshot\n');
  object(['update-ref', 'refs/heads/event', revision]);
  const adapter = path.join(root, 'git-adapter');
  fs.writeFileSync(adapter, `#!${process.execPath}
const fs = require('node:fs'), assert = require('node:assert/strict');
const { spawnSync } = require('node:child_process');
const args = process.argv.slice(2), mode = process.env.DEVCONTAINER_TEST_MODE;
fs.appendFileSync(${JSON.stringify(callsFile)}, JSON.stringify(args)+'\\n');
if (args.includes('checkout') || args.includes('switch') || args.includes('clone')) process.exit(98);
const fetchIndex = args.indexOf('fetch');
if (fetchIndex !== -1) {
  assert.deepEqual(args.slice(2), ['-c', 'credential.helper=', '-c', 'core.askPass=',
    'fetch', '--no-tags', '--no-recurse-submodules', '--depth=1', 'origin',
    process.env.EXPECTED_REVISION+':refs/remotes/event/target']);
  if (mode === 'fetch-failure') { console.error('injected fetch failure'); process.exit(17); }
}
const remoteIndex = args.indexOf('remote');
if (remoteIndex !== -1) {
  assert.deepEqual(args.slice(remoteIndex, -1), ['remote', 'add', 'origin']);
  assert.equal(args.at(-1), process.env.DEVCONTAINER_EXPECTED_URL);
  if (mode !== 'invalid-port') args[args.length-1] = ${JSON.stringify('file://' + remote)};
}
if (args.includes('rev-parse') && mode === 'wrong-identity') {
  console.log(${JSON.stringify(otherRevision)}); process.exit(0);
}
if (args.includes('ls-tree') && mode === 'inventory-failure') {
  console.error('injected inventory failure'); process.exit(23);
}
if (args.includes('--get-regexp') && mode === 'credential-residue') {
  console.log('http.https://example.invalid/.extraheader dummy-fixture'); process.exit(0);
}
const result = spawnSync('/usr/bin/git', args, { env: process.env, timeout: 10000 });
if (result.error) { console.error(result.error.message); process.exit(97); }
process.stdout.write(result.stdout); process.stderr.write(result.stderr);
if (result.status === 0 && args.includes('ls-tree') && mode === 'malformed-inventory') process.stdout.write('unterminated');
process.exit(result.status ?? 96);
`, { mode: 0o700 });
  function run({ server = 'https://github.com', repository = 'owner/repository', expected = revision,
    mode = '', existing = false } = {}) {
    const destination = path.join(runRoot, 'styleguide-devcontainer-boundary');
    if (existing) fs.mkdirSync(destination);
    const source = devcontainerWorkflow().source.replaceAll('/usr/bin/git', `'${adapter}'`);
    const result = spawnSync('bash', ['--noprofile', '--norc', '-c', source], {
      cwd: runRoot, env: { ...env, RUNNER_TEMP: runRoot, EXPECTED_SERVER_URL: server,
        EXPECTED_REPOSITORY: repository, EXPECTED_REVISION: expected, DEVCONTAINER_TEST_MODE: mode,
        DEVCONTAINER_EXPECTED_URL: `${server.replace(/\/$/u, '')}/${repository}.git` },
      encoding: 'utf8', timeout: 30000,
    });
    assert.equal(result.error, undefined, result.error?.message);
    assert.equal(result.signal, null, result.stderr);
    assert.equal(fs.existsSync(marker), false, 'candidate code must remain inert');
    assert.equal(fs.existsSync(path.join(destination, 'candidate-must-not-run.sh')), false, 'no checkout');
    return result;
  }
  return { run, revision, calls: () => fs.existsSync(callsFile) ?
    fs.readFileSync(callsFile, 'utf8').trim().split('\n').map(JSON.parse) : [] };
}

for (const [name, entries, forbidden, includeMarker = true] of [
  ['empty tree', [], false, false],
  ['root file', [['.devcontainer.json']], true],
  ['root directory', [['.devcontainer/devcontainer.json']], true],
  ['nested file', [['module/.devcontainer.json']], true],
  ['nested directory', [['module/.devcontainer/devcontainer.json']], true],
  ['ASCII case folding', [['MODULE/.DEVCONTAINER/DEVCONTAINER.JSON']], true],
  ['UTF-8 parent', [['módulo/.devcontainer.json']], true],
  ['newline parent', [['module\nname/.devcontainer.json']], true],
  ['root empty forbidden tree', [['.devcontainer', 'tree']], true],
  ['root empty file-named tree', [['.devcontainer.json', 'tree']], true],
  ['nested empty forbidden tree', [['module/.devcontainer', 'tree']], true],
  ['forbidden gitlink', [['.devcontainer', 'commit']], true],
  ['near matches', [['.env'], ['module/.devcontainer-example/devcontainer.json'],
    ['module/.devcontainer.json.bak']], false],
]) {
  test(`devcontainer actual Git inventory: ${name}`, { skip: !linux }, t => {
    const f = devcontainerFixture(t, entries, includeMarker), result = f.run();
    assert.equal(result.status === 0, !forbidden, result.stdout + result.stderr);
    assert.match(result.stdout + result.stderr, forbidden ? /no authorized devcontainer contract/u : /preserves the devcontainer exclusion/u);
    const inventory = f.calls().find(args => args.includes('ls-tree'));
    assert.ok(inventory);
    assert.deepEqual(inventory.slice(2), ['ls-tree', '-r', '-t', '--full-tree', '--name-only', '-z', f.revision]);
  });
}

for (const [mode, entries, error] of [
  ['fetch-failure', [], /injected fetch failure/u],
  ['wrong-identity', [], /./u],
  ['inventory-failure', [], /injected inventory failure/u],
  ['malformed-inventory', [], /tracked-path inventory was malformed/u],
  ['malformed-inventory', [['.devcontainer.json']], /tracked-path inventory was malformed/u],
  ['credential-residue', [], /./u],
]) {
  test(`devcontainer actual caller fails closed: ${mode}${entries.length ? ' after match' : ''}`, { skip: !linux }, t => {
    const f = devcontainerFixture(t, entries), result = f.run({ mode });
    assert.notEqual(result.status, 0);
    assert.doesNotMatch(result.stdout, /preserves the devcontainer exclusion/u);
    assert.match(result.stdout + result.stderr, error);
    if (['fetch-failure', 'wrong-identity', 'credential-residue'].includes(mode)) {
      assert.equal(f.calls().some(args => args.includes('ls-tree')), false);
    }
  });
}

test('devcontainer caller does not reuse an existing destination', { skip: !linux }, t => {
  const f = devcontainerFixture(t), result = f.run({ existing: true });
  assert.notEqual(result.status, 0);
  assert.deepEqual(f.calls(), []);
});

for (const server of ['https://github.com', 'https://github.com/', 'https://company.ghe.com',
  'https://ghe.example:8443', 'https://[::1]:8443', 'https://127.0.0.1:8443']) {
  test(`devcontainer native HTTPS envelope only: ${server}`, { skip: !linux }, t => {
    const f = devcontainerFixture(t), result = f.run({ server });
    assert.equal(result.status, 0, result.stdout + result.stderr);
    // URL acceptance proves construction, not enterprise hosting or anonymous availability.
    assert.ok(f.calls().some(args => args.includes('fetch')));
  });
}

for (const server of ['http://github.com', 'https://user@github.com', 'https://user:pass@github.com',
  'https://', 'https://github.com/path', 'https://github.com?x', 'https://github.com#x',
  'https://github.com//', 'https://github.com\\path', 'https://git hub.com',
  'https://github.com\n', 'https://github.com\x01']) {
  test(`devcontainer rejects invalid server before acquisition: ${JSON.stringify(server)}`, { skip: !linux }, t => {
    const f = devcontainerFixture(t), result = f.run({ server });
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /Invalid native HTTPS repository URL/u);
    assert.deepEqual(f.calls(), []);
  });
}

for (const repository of ['', 'owner', 'owner/repository/extra', './repository', '../repository',
  'owner/.', 'owner/..', 'owner/repository?x', 'owner/repository\n', 'owner\\repository']) {
  test(`devcontainer rejects invalid repository before acquisition: ${JSON.stringify(repository)}`, { skip: !linux }, t => {
    const f = devcontainerFixture(t), result = f.run({ repository });
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /Invalid native HTTPS repository URL/u);
    assert.deepEqual(f.calls(), []);
  });
}

for (const expected of ['', '0'.repeat(40), 'a'.repeat(39), 'G'.repeat(40)]) {
  test(`devcontainer rejects invalid event identity: ${JSON.stringify(expected)}`, { skip: !linux }, t => {
    const f = devcontainerFixture(t), result = f.run({ expected });
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /Invalid event commit identity/u);
    assert.deepEqual(f.calls(), []);
  });
}

test('devcontainer delegates port validation to real Git and propagates its error', { skip: !linux }, t => {
  const f = devcontainerFixture(t), result = f.run({ server: 'https://github.com:65536', mode: 'invalid-port' });
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /port number|port was not a decimal|port.*65535/iu);
  assert.ok(f.calls().some(args => args.includes('fetch')));
  assert.equal(f.calls().some(args => args.includes('ls-tree')), false);
  assert.doesNotMatch(result.stdout, /preserves the devcontainer exclusion/u);
});

// Copilot convergence: execute the actual YAML bodies. Network/package transports
// are substituted only where named below; none of these cases runs the full suite.
const copilotJob = parse(read('copilot-setup-steps.yml')).jobs['copilot-setup-steps'];
const copilotStep = name => copilotJob.steps.find(step => step.name === name);

test('Copilot actual curl command rejects ambient headers and additional URLs only with first disable', { skip: !linux }, async t => {
  const f = copilotBodyFixture(t), hits = [];
  const server = createServer((request, response) => {
    hits.push({ path: request.url, header: request.headers['x-copilot-fixture'] });
    response.end('inert text; never an executable archive\n');
  });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  t.after(() => new Promise(resolve => server.close(resolve)));
  const url = `http://127.0.0.1:${server.address().port}`;
  fs.writeFileSync(path.join(f.root, '.curlrc'), `header = "X-Copilot-Fixture: ambient"\nurl = "${url}/extra"\n`);
  const line = copilotStep('Set up verified official Node.js runtime').run.split('\n').find(value => value.includes('& $strCurlPath '));
  assert.equal(typeof line, 'string');
  for (const mode of ['absent', 'misplaced', 'first']) {
    hits.length = 0;
    let command = line.replaceAll("'=https'", "'=http'");
    if (mode !== 'first') command = command.replace('--disable ', '');
    if (mode === 'misplaced') command = command.replace('--silent ', '--silent --disable ');
    const script = path.join(f.root, 'curl.ps1');
    fs.writeFileSync(script, `$strCurlPath='/usr/bin/curl'\n$strArchive=${quote(path.join(f.root, 'inert.txt'))}\n$strUrl=${quote(`${url}/archive`)}\n${command}\nexit $LASTEXITCODE\n`);
    const result = await new Promise((resolve, reject) => {
      const child = spawn('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', script],
        { cwd: f.work, env: { ...f.env, CURL_HOME: f.root, XDG_CONFIG_HOME: f.root }, timeout: 15000 });
      let stdout = '', stderr = ''; child.stdout.on('data', data => { stdout += data; }); child.stderr.on('data', data => { stderr += data; });
      child.on('error', reject); child.on('close', status => resolve({ status, stdout, stderr }));
    });
    assert.equal(result.status, 0, result.stderr);
    assert.equal(hits.some(hit => hit.header === 'ambient'), mode !== 'first', `${mode}: header oracle ${JSON.stringify(hits)}`);
    assert.equal(hits.some(hit => hit.path === '/extra'), mode !== 'first', `${mode}: additional-URL oracle ${JSON.stringify(hits)}`);
    assert.ok(hits.some(hit => hit.path === '/archive'));
    if (mode === 'first') assert.equal(hits.length, 1);
    assert.equal(fs.readFileSync(path.join(f.root, 'inert.txt'), 'utf8'), 'inert text; never an executable archive\n');
  }
});

test('Copilot setup declares its input closure, supported environment and finite phase limits', () => {
  const workflow = parse(read('copilot-setup-steps.yml'));
  assert.deepEqual(Object.keys(workflow.jobs), ['copilot-setup-steps']);
  assert.deepEqual(workflow.permissions, {});
  assert.deepEqual(copilotJob.permissions, {});
  assert.equal(copilotJob.env, undefined);
  assert.equal(copilotJob['runs-on'], 'ubuntu-24.04');
  assert.equal(copilotJob['timeout-minutes'], 59);
  assert.deepEqual(workflow.on.push.branches, ['**']);
  assert.equal(workflow.on.pull_request.branches, undefined);
  for (const event of ['push', 'pull_request']) {
    for (const input of ['.github/workflows/**', '.husky/**', 'requirements-dev.txt', '**/*.yml', '**/*.yaml',
      '.npmrc', 'npm-shrinkwrap.json', 'package.json', 'package-lock.json']) {
      assert.ok(workflow.on[event].paths.includes(input), `${event}: ${input}`);
    }
  }
  for (const step of copilotJob.steps) {
    assert.equal(step['continue-on-error'], undefined);
    const expected = step.name.startsWith('Acquire ') ? 5 : step.name === 'Set up verified official Node.js runtime' ? 8
      : step.name.startsWith('Install locked ') ? 10 : step.name === 'Run complete repository validation' ? 45 : 2;
    assert.equal(step['timeout-minutes'], expected, step.name);
    assert.match(step.run, /GIT_CONFIG_COUNT/);
    assert.match(step.run, /GIT_CONFIG_NOSYSTEM/);
    assert.match(step.run, /ACTIONS_RUNTIME_TOKEN/);
  }
  for (const name of ['Set up isolated Python 3.12', 'Install locked Python validation tools',
    'Activate repository hooks', 'Run complete repository validation']) {
    assert.equal(copilotStep(name).if, "steps.toolchain.outputs.validation == 'full'");
  }
  assert.equal(copilotStep('Verify final immutable setup inputs').if, "always() && steps.toolchain.outcome == 'success'");
  assert.match(copilotStep('Run complete repository validation').run, /-m pre_commit run --all-files/);
});

function copilotBodyFixture(t, workName = 'work', job = copilotJob) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'copilot-convergence-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const work = path.join(root, workName); fs.mkdirSync(work);
  const env = { ...process.env, RUNNER_TEMP: root, HOME: root, XDG_CONFIG_HOME: root,
    GITHUB_OUTPUT: path.join(root, 'output'), GITHUB_ENV: path.join(root, 'env'), GITHUB_PATH: path.join(root, 'path') };
  for (const key of ['GITHUB_TOKEN', 'GH_TOKEN', 'ACTIONS_RUNTIME_TOKEN', 'GIT_CONFIG_COUNT', 'GIT_CONFIG_PARAMETERS',
    'GIT_CONFIG_NOSYSTEM', 'GIT_CONFIG_GLOBAL', 'GIT_TERMINAL_PROMPT']) delete env[key];
  const put = (name, text = 'fixture\n') => { const p = path.join(work, name); fs.mkdirSync(path.dirname(p), { recursive: true }); fs.writeFileSync(p, text); };
  function run(name, extra = {}, transform = value => value) {
    const step = job.steps.find(item => item.name === name);
    assert.ok(step, `The selected setup workflow has no step: ${name}`);
    const file = path.join(root, step.shell === 'pwsh' ? 'body.ps1' : 'body.sh');
    // Observe successful-body isolation in the same process, with no job.env seed.
    const isolationProbe = step.shell === 'pwsh'
      ? '\nif ($env:GIT_CONFIG_NOSYSTEM -cne "1" -or $env:GIT_CONFIG_GLOBAL -cne "/dev/null" -or $env:GIT_TERMINAL_PROMPT -cne "0") { throw "Fixture: body depends on job.env isolation" }\n'
      : '\n[[ "${GIT_CONFIG_NOSYSTEM:-}" == 1 && "${GIT_CONFIG_GLOBAL:-}" == /dev/null && "${GIT_TERMINAL_PROMPT:-}" == 0 ]] || { echo "Fixture: body depends on job.env isolation"; exit 93; }\n';
    fs.writeFileSync(file, transform(step.run) + isolationProbe);
    return assertCompletedProcess(spawnSync(step.shell === 'pwsh' ? 'pwsh' : 'bash', step.shell === 'pwsh'
      ? ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', file] : ['--noprofile', '--norc', file],
    { cwd: work, env: { ...env, ...extra }, encoding: 'utf8', timeout: 45000 }), `${name}: ${step.shell}: ${file}`);
  }
  function git(...args) {
    const r = spawnSync('/usr/bin/git', args, { cwd: work,
      env: { ...env, GIT_CONFIG_NOSYSTEM: '1', GIT_CONFIG_GLOBAL: '/dev/null', GIT_TERMINAL_PROMPT: '0' }, encoding: 'utf8' });
    assert.equal(r.status, 0, r.stderr); return r.stdout.trim();
  }
  const commit = () => { git('add', '-A'); return git('-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid', 'commit', '-qm', 'fixture'); };
  return { root, work, env, put, run, git, commit };
}
const copilotFullInputs = ['requirements-dev.txt', '.github/workflows/Invoke-LockedPythonHook.ps1', '.pre-commit-config.yaml',
  '.github/workflows/install-husky.mjs', '.husky/pre-commit', '.github/workflows/lint-staged-markdown.mjs'];
function copilotInputs(f, kind = 'declared') {
  for (const name of ['.github/workflows/package.json', '.github/workflows/package-lock.json']) f.put(name, '{}');
  if (kind === 'legacy') return;
  f.put('package.json', JSON.stringify({ engines: { node: kind === 'historical' ? '24.18.0' : '24.18.1', npm: '11.16.0' } }));
  f.put('package-lock.json', '{}');
  if (kind === 'declared' || kind === 'declared-schema2') f.put('.github/workflows/ci-toolchain.json',
    JSON.stringify(kind === 'declared-schema2' ? runtimePin('a'.repeat(64)) : { linuxX64Sha256: 'a'.repeat(64) }));
  if (kind !== 'historical') for (const name of copilotFullInputs) f.put(name);
}
for (const kind of ['declared-schema2', 'declared', 'pre-declaration', 'historical', 'legacy', 'historical-full']) {
  test(`Copilot finite capability classification: ${kind}`, { skip: !linux }, t => {
    const f = copilotBodyFixture(t); copilotInputs(f, kind === 'historical-full' ? 'historical' : kind);
    if (kind === 'historical-full') for (const name of copilotFullInputs) f.put(name);
    const result = f.run('Detect locked validation-tool layout');
    assert.equal(result.status, 0, result.stdout + result.stderr);
    const subset = ['historical', 'legacy'].includes(kind);
    assert.match(fs.readFileSync(f.env.GITHUB_OUTPUT, 'utf8'), new RegExp(`validation=${subset ? 'node-only' : 'full'}`));
    if (subset) assert.match(result.stdout, /Python and full validation are unavailable/);
  });
}
for (const mode of ['partial-root', 'root-symlink', 'nested-directory', 'declaration-symlink', 'declaration-json',
  'current-deleted-tuple', 'historical-partial-python', 'historical-wrong-version', 'historical-wrong-npm', 'legacy-declaration',
  ...copilotFullInputs.map(name => `missing:${name}`), ...copilotFullInputs.map(name => `symlink:${name}`)]) {
  test(`Copilot capability rejects incomplete or unsupported inputs: ${mode}`, { skip: !linux }, t => {
    const f = copilotBodyFixture(t);
    const kind = mode.startsWith('historical') ? 'historical' : mode === 'legacy-declaration' ? 'legacy' : 'declared';
    copilotInputs(f, kind);
    const remove = name => fs.rmSync(path.join(f.work, name));
    if (mode === 'partial-root') remove('package-lock.json');
    if (mode === 'root-symlink') { remove('package.json'); fs.symlinkSync('package-lock.json', path.join(f.work, 'package.json')); }
    if (mode === 'nested-directory') { remove('.github/workflows/package.json'); fs.mkdirSync(path.join(f.work, '.github/workflows/package.json')); }
    if (mode === 'declaration-symlink') { remove('.github/workflows/ci-toolchain.json'); fs.symlinkSync('package.json', path.join(f.work, '.github/workflows/ci-toolchain.json')); }
    if (mode === 'declaration-json') f.put('.github/workflows/ci-toolchain.json', '{');
    if (mode === 'current-deleted-tuple') { remove('.github/workflows/ci-toolchain.json'); for (const name of copilotFullInputs) remove(name); }
    if (mode === 'historical-partial-python') f.put('requirements-dev.txt');
    if (mode === 'historical-wrong-version') f.put('package.json', '{"engines":{"node":"24.19.0","npm":"11.16.0"}}');
    if (mode === 'historical-wrong-npm') f.put('package.json', '{"engines":{"node":"24.18.0","npm":"11.17.0"}}');
    if (mode === 'legacy-declaration') f.put('.github/workflows/ci-toolchain.json', '{}');
    if (mode.startsWith('missing:')) remove(mode.slice(8));
    if (mode.startsWith('symlink:')) { const name = mode.slice(8); remove(name); fs.symlinkSync('/dev/null', path.join(f.work, name)); }
    const result = f.run('Detect locked validation-tool layout');
    assert.notEqual(result.status, 0, result.stdout + result.stderr);
    assert.ok(!fs.existsSync(f.env.GITHUB_OUTPUT) || !fs.readFileSync(f.env.GITHUB_OUTPUT, 'utf8').includes('validation='));
  });
}

for (const mode of ['clean', 'retry', 'failure', 'wrong-origin', 'wrong-type', 'wrong-head', 'multiline', 'zero']) {
  test(`Copilot separate real-Git event ancestry and main authority: ${mode}`, { skip: !linux }, t => {
    const f = copilotBodyFixture(t); f.git('init', '-q'); f.put('history'); f.commit();
    const common = f.git('rev-parse', 'HEAD'); f.git('branch', '-M', 'main'); f.put('main-only'); f.commit();
    const main = f.git('rev-parse', 'HEAD'); f.git('checkout', '-qb', 'topic', common); f.put('event-only'); f.commit();
    const event = f.git('rev-parse', 'HEAD'), remote = path.join(f.root, 'remote');
    fs.renameSync(f.work, remote); fs.mkdirSync(f.work);
    const adapter = path.join(f.root, 'git'), calls = path.join(f.root, 'git-calls');
    fs.writeFileSync(adapter, `#!${process.execPath}
const {spawnSync}=require('node:child_process'),fs=require('node:fs');
let a=process.argv.slice(2);fs.appendFileSync(${JSON.stringify(calls)},JSON.stringify(a)+'\\n');
const mainFetch=a.includes('refs/heads/main:refs/remotes/origin/main');
if(mainFetch&&['retry','failure'].includes(${JSON.stringify(mode)})) {
 const count=fs.readFileSync(${JSON.stringify(calls)},'utf8').split('\\n').filter(s=>s.includes('refs/heads/main:')).length;
 if(${JSON.stringify(mode)}==='failure'||count<3)process.exit(23);
}
if(a.includes('fetch'))a[a.indexOf('origin')]=${JSON.stringify(remote)};
if(${JSON.stringify(mode)}==='wrong-origin'&&a[0]==='remote'&&a[1]==='get-url'){console.log('https://invalid.example/repo');process.exit(0);}
if(${JSON.stringify(mode)}==='wrong-type'&&a[0]==='cat-file'){console.log('blob');process.exit(0);}
if(['multiline','zero'].includes(${JSON.stringify(mode)})&&a[0]==='rev-parse'&&a.includes('refs/remotes/origin/main')){
 console.log(${JSON.stringify(mode)}==='zero'?'0'.repeat(40):${JSON.stringify(main)}+'\\n'+${JSON.stringify(main)});process.exit(0);}
if(${JSON.stringify(mode)}==='wrong-head'&&a[0]==='rev-parse'&&a[1]==='HEAD'&&fs.existsSync('.git/refs/remotes/origin/main')){console.log(${JSON.stringify(main)});process.exit(0);}
const r=spawnSync('/usr/bin/git',a,{stdio:'inherit'});process.exit(r.status??99);
`, { mode: 0o700 });
    const replace = source => source.replaceAll("'/usr/bin/git'", quote(adapter)).replaceAll("'/bin/git'", quote(adapter));
    const env = { GITHUB_SHA: event, GITHUB_SERVER_URL: 'https://github.com', GITHUB_REPOSITORY: 'franklesniak/PSStyleGuide' };
    const acquired = f.run('Acquire triggering revision without an action', env, replace);
    assert.equal(acquired.status, 0, acquired.stderr);
    assert.equal(f.git('rev-list', '--count', 'HEAD'), '2', 'Event history must not be shallow.');
    const result = f.run('Acquire published main reference', env, replace);
    assert.equal(result.status === 0, ['clean', 'retry'].includes(mode), result.stderr);
    const log = fs.readFileSync(calls, 'utf8').trim().split('\n').map(JSON.parse);
    const fetches = log.filter(args => args.includes('refs/heads/main:refs/remotes/origin/main'));
    assert.equal(fetches.length, mode === 'wrong-origin' ? 0 : ['retry', 'failure'].includes(mode) ? 3 : 1);
    assert.ok(log.filter(args => args.includes('fetch')).every(args => !args.includes('--depth') && !args.some(arg => arg.startsWith('+'))));
    assert.equal(f.git('rev-parse', 'HEAD'), event);
    if (result.status === 0) { assert.equal(f.git('rev-parse', 'refs/remotes/origin/main'), main); assert.ok(result.stdout.includes(main)); }
  });
}

for (const mode of ['clean', 'missing-cache', 'cache-symlink', 'incomplete', 'escape', 'library-newline', 'existing-venv']) {
  test(`Copilot guarded real Python cache and fresh venv: ${mode}`, { skip: !linux }, t => {
    const f = copilotBodyFixture(t), cache = path.join(f.root, 'cache');
    const probe = spawnSync('python3.12', ['-I', '-S', '-c',
      'import json, os, sys, sysconfig; print(json.dumps({"executable": os.path.realpath(sys.executable), "version": ".".join(map(str, sys.version_info[:3])), "implementation": sys.implementation.name, "bits64": sys.maxsize > 2**32, "libdir": sysconfig.get_config_var("LIBDIR")}))'],
    { encoding: 'utf8' });
    assert.equal(probe.status, 0, probe.stderr);
    const runtime = JSON.parse(probe.stdout);
    assert.match(runtime.version, /^3\.12\.\d+$/); assert.equal(runtime.implementation, 'cpython'); assert.equal(runtime.bits64, true);
    const selected = path.join(cache, runtime.version, 'x64');
    fs.mkdirSync(path.join(selected, 'bin'), { recursive: true }); fs.mkdirSync(path.join(selected, 'lib'));
    fs.copyFileSync(runtime.executable, path.join(selected, 'bin/python3.12')); fs.chmodSync(path.join(selected, 'bin/python3.12'), 0o700);
    // Shared-library builds need their existing local libpython in the synthetic cache.
    if (runtime.libdir && fs.existsSync(runtime.libdir)) {
      for (const name of fs.readdirSync(runtime.libdir).filter(name => /^libpython3\.12\.so(?:\.|$)/.test(name))) {
        fs.copyFileSync(path.join(runtime.libdir, name), path.join(selected, 'lib', name));
      }
    }
    fs.symlinkSync('python3.12', path.join(selected, 'bin/python')); fs.writeFileSync(`${selected}.complete`, '');
    if (mode === 'missing-cache') fs.renameSync(cache, `${cache}-absent`);
    if (mode === 'cache-symlink') { fs.renameSync(cache, `${cache}-target`); fs.symlinkSync(`${cache}-target`, cache); }
    if (mode === 'incomplete') fs.rmSync(`${selected}.complete`);
    if (mode === 'escape') { fs.rmSync(path.join(selected, 'bin/python')); fs.symlinkSync(runtime.executable, path.join(selected, 'bin/python')); }
    if (mode === 'existing-venv') fs.mkdirSync(path.join(f.root, 'agent-validation-python'));
    const result = f.run('Set up isolated Python 3.12', mode === 'library-newline' ? { LD_LIBRARY_PATH: 'x\ny' } : {},
      source => source.replace("'/opt/hostedtoolcache/Python'", `'${cache}'`));
    assert.equal(result.status === 0, mode === 'clean', result.stdout + result.stderr);
    if (mode !== 'clean') { assert.equal(fs.existsSync(f.env.GITHUB_PATH), false); return; }
    const bin = fs.readFileSync(f.env.GITHUB_PATH, 'utf8').trim();
    assert.equal(bin, path.join(f.root, 'agent-validation-python/bin'));
    const py = spawnSync(path.join(bin, 'python3.12'), ['-I', '-c', 'import sys; print(sys.prefix); print(sys.version_info[:2])'], { encoding: 'utf8' });
    assert.equal(py.status, 0, py.stderr); assert.ok(py.stdout.includes(path.dirname(bin))); assert.match(py.stdout, /\(3, 12\)/);
    // Inert local approved module proves the unchanged launcher discovers the venv.
    const site = path.join(path.dirname(bin), 'lib/python3.12/site-packages/pre_commit_hooks'); fs.mkdirSync(site, { recursive: true });
    fs.writeFileSync(path.join(site, '__init__.py'), ''); fs.writeFileSync(path.join(site, 'check_json.py'), 'print("VENV_LAUNCHER_FIXTURE")\n');
    const launched = spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File',
      path.join(directory, 'Invoke-LockedPythonHook.ps1'), '-Module', 'pre_commit_hooks.check_json'],
    { env: { ...f.env, PATH: `${bin}:${process.env.PATH}` }, cwd: f.work, encoding: 'utf8', timeout: 30000 });
    assert.equal(launched.status, 0, launched.stderr); assert.match(launched.stdout, /VENV_LAUNCHER_FIXTURE/);
  });
}

for (const mode of ['clean', 'install-failure', 'wrong-version', 'check-failure']) {
  test(`Copilot locked Python command and status: ${mode}`, { skip: !linux }, t => {
    const f = copilotBodyFixture(t), interpreter = path.join(f.root, 'python'), log = path.join(f.root, 'python-calls');
    f.put('requirements-dev.txt', 'pre-commit==4.3.0 \\\n  --hash=sha256:fixture\n');
    fs.writeFileSync(interpreter, `#!${process.execPath}
const fs=require('node:fs'),a=process.argv.slice(2);fs.appendFileSync(${JSON.stringify(log)},JSON.stringify(a)+'\\n');
if(a[0]!=='-E'||a[1]!=='-P')process.exit(98);
if(a.includes('-c'))console.log('3.12');
else if(a.includes('install')&&${JSON.stringify(mode)}==='install-failure')process.exit(21);
else if(a.includes('--version'))console.log('pre-commit '+(${JSON.stringify(mode)}==='wrong-version'?'0.0.0':'4.3.0'));
else if(a.includes('check')&&${JSON.stringify(mode)}==='check-failure')process.exit(22);
`, { mode: 0o700 });
    const result = f.run('Install locked Python validation tools', { VALIDATION_PYTHON: interpreter, PIP_INDEX_URL: 'https://invalid.example' });
    assert.equal(result.status === 0, mode === 'clean', result.stderr);
    const calls = fs.readFileSync(log, 'utf8').trim().split('\n').map(JSON.parse);
    assert.deepEqual(calls.find(args => args.includes('install')), ['-E', '-P', '-m', 'pip', '--isolated', 'install',
      '--require-hashes', '--only-binary=:all:', '--index-url', 'https://pypi.org/simple', '-r', 'requirements-dev.txt']);
    assert.equal(calls.length, mode === 'install-failure' ? 2 : mode === 'wrong-version' ? 3 : 4);
  });
}

for (const reviewOnly of [false, true]) {
  const selectedJob = reviewOnly ? parse(read('copilot-code-review.yml')).jobs['copilot-setup-steps'] : copilotJob;
  for (const mode of (reviewOnly ? ['clean', 'npm-failure', 'hook-wrong'] : ['clean', 'npm-failure', 'hook-wrong', 'suite-failure'])) {
    test(`${reviewOnly ? 'Review' : 'Coding'} Copilot explicit hook and full-validation caller: ${mode}`, { skip: !linux }, t => {
      const f = copilotBodyFixture(t, 'work', selectedJob), bin = path.join(f.root, 'bin'), log = path.join(f.root, 'calls'); fs.mkdirSync(bin);
      f.git('init', '-q'); f.put('fixture'); f.commit();
      f.git('update-ref', 'refs/remotes/origin/main', 'HEAD');
      const fixturePython = copilotFixturePython();
      for (const name of ['npm', 'python']) fs.writeFileSync(path.join(bin, name), `#!${process.execPath}
  const fs=require('node:fs'),{spawnSync}=require('node:child_process'),a=process.argv.slice(2);
  if(${JSON.stringify(name)}==='python'&&a[2]==='-'){const r=spawnSync(${JSON.stringify(fixturePython)},a,{stdio:'inherit'});process.exit(r.status??99);}
  if(Object.keys(process.env).some(k=>/^npm_config_/i.test(k)&&!['npm_config_userconfig','npm_config_globalconfig'].includes(k)))process.exit(97);
  fs.appendFileSync(${JSON.stringify(log)},JSON.stringify([${JSON.stringify(name)},...a])+'\\n');
  if(${JSON.stringify(name)}==='npm') {
   if(${JSON.stringify(mode)}==='npm-failure')process.exit(31);
   spawnSync('/usr/bin/git',['config','core.hooksPath',${JSON.stringify(mode)}==='hook-wrong'?'.bad':'.husky/_']);
   fs.mkdirSync('.husky/_',{recursive:true});fs.writeFileSync('.husky/_/pre-commit','#!/bin/sh\\nexit 0\\n',{mode:0o700});
  } else if(${JSON.stringify(mode)}==='suite-failure')process.exit(37);
  `, { mode: 0o700 });
      const env = { PATH: `${bin}:${process.env.PATH}`, VALIDATION_PYTHON: path.join(bin, 'python'),
        GITHUB_SHA: f.git('rev-parse', 'HEAD'), GITHUB_WORKSPACE: f.work,
        NPM_CONFIG_SCRIPT_SHELL: 'hostile', 'npm_config_unsafe-name': 'dummy' };
      const hook = f.run('Activate repository hooks', env);
      assert.equal(hook.status === 0, !['npm-failure', 'hook-wrong'].includes(mode), hook.stderr);
      if (hook.status === 0 && !reviewOnly) {
        const suite = f.run('Run complete repository validation', env);
        assert.equal(suite.status, mode === 'suite-failure' ? 37 : 0, suite.stderr);
      }
      const calls = fs.readFileSync(log, 'utf8').trim().split('\n').map(JSON.parse);
      assert.deepEqual(calls[0], ['npm', '--prefix', '.github/workflows', 'run', 'prepare']);
      if (hook.status === 0 && !reviewOnly) assert.deepEqual(calls[1], ['python', '-E', '-P', '-m', 'pre_commit', 'run', '--all-files']);
      else assert.equal(calls.length, 1);
    });
  }

}

for (const mode of ['clean', 'worktree', 'index', 'index-masked', 'untracked', 'ignored-untracked']) {
  test(`Copilot immutable inputs compare acquired HEAD, index and worktree: ${mode}`, { skip: !linux }, t => {
    const f = copilotBodyFixture(t); f.git('init', '-q'); copilotInputs(f, 'historical'); f.commit();
    assert.equal(f.run('Verify acquired immutable setup inputs').status, 0);
    if (['worktree', 'index', 'index-masked'].includes(mode)) f.put('package.json', 'changed\n');
    if (mode === 'index' || mode === 'index-masked') f.git('add', 'package.json');
    if (mode === 'index-masked') f.put('package.json', f.git('show', 'HEAD:package.json'));
    if (mode.endsWith('untracked')) f.put('requirements-dev.txt');
    if (mode === 'ignored-untracked') f.put('.gitignore', 'requirements-dev.txt\n');
    const result = f.run('Verify final immutable setup inputs');
    assert.equal(result.status === 0, mode === 'clean', result.stdout + result.stderr);
  });
}

for (const mode of ['clean', 'wrong-script', 'array-script', 'object-script', 'declared-current', 'older-version',
  'installer-symlink', 'missing-python', 'missing-hook']) {
  test(`Copilot finite historical prepare branch: ${mode}`, { skip: !linux }, t => {
    const f = copilotBodyFixture(t); copilotInputs(f, 'pre-declaration');
    fs.rmSync(path.join(f.work, '.github/workflows/install-husky.mjs'));
    const prepare = mode === 'wrong-script' ? 'echo incomplete' : mode === 'array-script' ? ['cd ../.. && husky']
      : mode === 'object-script' ? { value: 'cd ../.. && husky' } : 'cd ../.. && husky';
    f.put('.github/workflows/package.json', JSON.stringify({ scripts: { prepare } }));
    if (mode === 'declared-current') f.put('.github/workflows/ci-toolchain.json', '{}');
    if (mode === 'older-version') f.put('package.json', '{"engines":{"node":"24.18.0","npm":"11.16.0"}}');
    if (mode === 'installer-symlink') fs.symlinkSync('/dev/null', path.join(f.work, '.github/workflows/install-husky.mjs'));
    if (mode === 'missing-python') fs.rmSync(path.join(f.work, 'requirements-dev.txt'));
    if (mode === 'missing-hook') fs.rmSync(path.join(f.work, '.husky/pre-commit'));
    const result = f.run('Detect locked validation-tool layout');
    assert.equal(result.status === 0, mode === 'clean', result.stdout + result.stderr);
    if (mode === 'clean') {
      assert.match(result.stdout, /Retained historical Husky prepare command selected/);
      assert.match(fs.readFileSync(f.env.GITHUB_OUTPUT, 'utf8'), /validation=full/);
    }
  });
}

for (const historical of [false, true]) {
  test(`Copilot real locked Husky activation: ${historical ? 'historical' : 'current'}`, { skip: !linux }, t => {
    const f = copilotBodyFixture(t); f.git('init', '-q');
    f.put('.github/workflows/package.json', JSON.stringify({ private: true, type: 'module', scripts: {
      prepare: historical ? 'cd ../.. && husky' : 'node install-husky.mjs' } }));
    if (!historical) f.put('.github/workflows/install-husky.mjs', read('install-husky.mjs'));
    f.put('.husky/pre-commit', '#!/bin/sh\nexit 0\n'); f.commit();
    const modules = path.join(f.work, '.github/workflows/node_modules'); fs.mkdirSync(modules, { recursive: true });
    fs.cpSync(path.join(directory, 'node_modules/husky'), path.join(modules, 'husky'), { recursive: true });
    fs.mkdirSync(path.join(modules, '.bin')); fs.symlinkSync('../husky/bin.js', path.join(modules, '.bin/husky'));
    const result = f.run('Activate repository hooks', { NPM_CONFIG_SCRIPT_SHELL: 'hostile' });
    assert.equal(result.status, 0, result.stdout + result.stderr);
    assert.equal(f.git('config', '--get', 'core.hooksPath'), '.husky/_');
    assert.ok(fs.statSync(path.join(f.work, '.husky/_/pre-commit')).mode & 0o111);
    assert.equal(f.git('diff', '--name-only', 'HEAD'), '');
  });
}

// Run the extracted install body with the real built-in-only policy helper and
// current source inputs. Only npm is replaced; it records installs without
// downloading packages. Fixtures intentionally have no installed YAML module.
function copilotPreinstallFixture(t, job = copilotJob) {
  const f = copilotBodyFixture(t, 'work', job);
  const inputs = ['package.json', 'package-lock.json', '.github/workflows/package.json',
    '.github/workflows/package-lock.json', '.github/workflows/ci-toolchain.json',
    '.github/workflows/workflow-policy-contract.json', '.github/workflows/Validate-WorkflowPolicy.mjs'];
  for (const name of inputs) {
    const target = path.join(f.work, name);
    fs.mkdirSync(path.dirname(target), { recursive: true });
    fs.copyFileSync(path.join(directory, '../..', name), target);
  }
  const bin = path.join(f.root, 'bin'), log = path.join(f.root, 'npm-calls');
  fs.mkdirSync(bin);
  fs.writeFileSync(path.join(bin, 'npm'), `#!${process.execPath}
const fs = require('node:fs'), args = process.argv.slice(2);
fs.appendFileSync(${JSON.stringify(log)}, JSON.stringify(args) + '\\n');
console.log(JSON.stringify({ npm: args }));
`, { mode: 0o700 });
  const calls = () => fs.existsSync(log) ? fs.readFileSync(log, 'utf8').trim().split('\n').filter(Boolean).map(JSON.parse) : [];
  const run = layout => {
    assert.equal(fs.existsSync(path.join(f.work, 'node_modules')), false);
    assert.equal(fs.existsSync(path.join(f.work, '.github/workflows/node_modules')), false);
    return f.run('Install locked Node.js validation tools', { TOOLCHAIN_LAYOUT: layout, PATH: `${bin}:${process.env.PATH}` });
  };
  return { ...f, calls, run };
}
const copilotCiArgs = ['ci', '--ignore-scripts', '--no-audit', '--fund=false', '--include=dev'];
test('Copilot preinstall real policy succeeds before both npm trees without installed YAML', { skip: !linux }, t => {
  const f = copilotPreinstallFixture(t), result = f.run('modern');
  assert.equal(result.status, 0, result.stdout + result.stderr);
  assert.deepEqual(f.calls(), [copilotCiArgs, [...copilotCiArgs, '--prefix', '.github/workflows']]);
  const output = result.stdout.trim().split('\n').map(JSON.parse);
  assert.equal(output.length, 3, 'Preflight must run before either npm install.');
  assert.equal(output[0].schema, 'StyleGuide.WorkflowPreflightResult.v1');
  assert.equal(output[0].success, true);
  assert.deepEqual(output.slice(1).map(row => row.npm), f.calls());
});
for (const mode of ['parser-contract-lock-mismatch', 'nonregistry-package-url']) {
  test(`Copilot preinstall real policy rejects before either npm tree: ${mode}`, { skip: !linux }, t => {
    const f = copilotPreinstallFixture(t);
    const name = mode === 'parser-contract-lock-mismatch'
      ? '.github/workflows/workflow-policy-contract.json' : 'package-lock.json';
    const target = path.join(f.work, name), input = JSON.parse(fs.readFileSync(target, 'utf8'));
    if (mode === 'parser-contract-lock-mismatch') input.parser.resolved = 'https://registry.npmjs.org/yaml/-/yaml-99.0.0.tgz';
    else Object.values(input.packages).find(entry => entry.resolved).resolved = 'https://example.invalid/package.tgz';
    fs.writeFileSync(target, JSON.stringify(input));
    const result = f.run('modern');
    assert.equal(result.status, 1, 'The real preflight native failure must propagate.');
    assert.deepEqual(f.calls(), [], 'Policy failure must prevent both npm installs.');
    const output = JSON.parse(result.stdout.trim());
    assert.equal(output.success, false);
    assert.equal(output.category, mode === 'parser-contract-lock-mismatch' ? 'parser-lock-identity' : 'lock-integrity');
  });
}
test('Copilot preinstall missing required current helper prevents both npm trees', { skip: !linux }, t => {
  const f = copilotPreinstallFixture(t);
  fs.unlinkSync(path.join(f.work, '.github/workflows/Validate-WorkflowPolicy.mjs'));
  const result = f.run('modern');
  assert.equal(result.status, 1);
  assert.deepEqual(f.calls(), []);
  assert.match(result.stderr, /MODULE_NOT_FOUND/u);
});
test('Copilot preinstall preserves native helper exit status', { skip: !linux }, t => {
  const f = copilotPreinstallFixture(t);
  // Separate dispatch probe: the two invalid-input cases above use real policy.
  f.put('.github/workflows/Validate-WorkflowPolicy.mjs', 'process.exit(37);\n');
  const result = f.run('modern');
  assert.equal(result.status, 37);
  assert.deepEqual(f.calls(), []);
});
for (const layout of ['modern', 'legacy']) {
  test(`Copilot preinstall declaration-absent history installs without newer helper: ${layout}`, { skip: !linux }, t => {
    const f = copilotPreinstallFixture(t);
    fs.unlinkSync(path.join(f.work, '.github/workflows/ci-toolchain.json'));
    fs.unlinkSync(path.join(f.work, '.github/workflows/Validate-WorkflowPolicy.mjs'));
    if (layout === 'legacy') for (const name of ['package.json', 'package-lock.json']) fs.unlinkSync(path.join(f.work, name));
    const result = f.run(layout);
    assert.equal(result.status, 0, result.stdout + result.stderr);
    assert.deepEqual(f.calls(), layout === 'modern' ? [copilotCiArgs, [...copilotCiArgs, '--prefix', '.github/workflows']]
      : [[...copilotCiArgs, '--prefix', '.github/workflows']]);
  });
}

function copilotFixturePython(executable = 'python3.12') {
  const result = spawnSync(executable, ['-I', '-S', '-c',
    'import json, sys; print(json.dumps({"executable": sys.executable, "implementation": sys.implementation.name, "version": list(sys.version_info[:2])}))'],
  { encoding: 'utf8' });
  assert.equal(result.status, 0, result.stderr);
  const observed = JSON.parse(result.stdout);
  assert.equal(observed.implementation, 'cpython');
  assert.deepEqual(observed.version, [3, 12]);
  assert.ok(path.isAbsolute(observed.executable));
  return observed.executable;
}

function copilotValidationFixture(t, alternatePython = false) {
  const f = copilotBodyFixture(t, 'prepared tree');
  let fixturePython = copilotFixturePython();
  if (alternatePython) {
    const alternate = path.join(f.root, 'alternate python');
    fs.symlinkSync(fixturePython, alternate);
    fixturePython = copilotFixturePython(alternate);
    assert.equal(fixturePython, alternate);
  }
  const temporary = path.join(f.root, 'runner temporary'); fs.mkdirSync(temporary);
  f.git('init', '-q');
  f.put('.gitignore', 'node_modules/\n.husky/_/\n');
  f.put('README.md', 'original\n'); f.commit();
  const event = f.git('rev-parse', 'HEAD');
  const main = f.git('-c', 'user.name=Fixture', '-c', 'user.email=fixture@example.invalid',
    'commit-tree', 'HEAD^{tree}', '-m', 'Independent main');
  f.git('update-ref', 'refs/remotes/origin/main', main);
  f.git('checkout', '--detach', '-q', event);
  f.git('config', 'core.hooksPath', '.husky/_');
  f.put('.husky/_/pre-commit', '#!/bin/sh\nexit 0\n');
  fs.chmodSync(path.join(f.work, '.husky/_/pre-commit'), 0o751);
  f.put('node_modules/package/index.js', 'prepared root dependency\n');
  f.put('.github/workflows/node_modules/package/index.js', 'prepared nested dependency\n');
  fs.mkdirSync(path.join(f.work, 'node_modules/.bin'));
  fs.symlinkSync('../package/index.js', path.join(f.work, 'node_modules/.bin/probe'));
  const probe = path.join(f.root, 'python'), log = path.join(f.root, 'validation.json');
  fs.writeFileSync(probe, `#!${process.execPath}
const fs=require('node:fs'),path=require('node:path'),{spawnSync}=require('node:child_process');
const args=process.argv.slice(2);
if(args[2]==='-') { const p=spawnSync(${JSON.stringify(fixturePython)},args,{stdio:'inherit'});process.exit(p.status??99); }
const git=(...a)=>{const r=spawnSync('/usr/bin/git',a,{encoding:'utf8'});if(r.status!==0)throw Error(r.stderr);return r.stdout.trim();};
const cwd=process.cwd();
fs.appendFileSync(${JSON.stringify(log)}+'.dispatch','called\\n');
if(cwd===${JSON.stringify(f.work)}||process.env.GITHUB_WORKSPACE!==cwd)process.exit(91);
if(git('rev-parse','HEAD')!==${JSON.stringify(event)}||git('rev-parse','refs/remotes/origin/main')!==${JSON.stringify(main)})process.exit(92);
if(git('rev-list','--all','--count')!=='2'||git('config','core.hooksPath')!=='.husky/_')process.exit(93);
if(fs.statSync('.husky/_/pre-commit').mode%512!==489||fs.readlinkSync('node_modules/.bin/probe')!=='../package/index.js')process.exit(94);
fs.writeFileSync(${JSON.stringify(log)},JSON.stringify({cwd,args,head:git('rev-parse','HEAD'),main:git('rev-parse','refs/remotes/origin/main')}));
if(process.env.VALIDATION_MODE!=='clean') {
 fs.writeFileSync('README.md','fixture hook edit\\n');
 fs.writeFileSync('node_modules/package/index.js','fixture dependency edit\\n');
 fs.writeFileSync('.github/workflows/node_modules/package/index.js','fixture nested edit\\n');
 git('add','README.md');
 git('config','fixture.validation','changed');
}
if(process.env.VALIDATION_MODE==='stop') {fs.writeFileSync(${JSON.stringify(log)}+'.ready','ready');setInterval(()=>{},1000);}
else process.exit(process.env.VALIDATION_MODE==='clean'?0:37);
`, { mode: 0o700 });
  const snapshot = () => Object.fromEntries(['README.md', '.git/index', '.git/config', '.git/HEAD',
    '.git/refs/remotes/origin/main', '.husky/_/pre-commit', 'node_modules/package/index.js',
    '.github/workflows/node_modules/package/index.js'].map(name => [name, fs.readFileSync(path.join(f.work, name)).toString('base64')]));
  const before = snapshot();
  return { ...f, event, main, probe, log, snapshot, before,
    validationEnv: { VALIDATION_PYTHON: probe, GITHUB_SHA: event, GITHUB_WORKSPACE: f.work, RUNNER_TEMP: temporary } };
}

for (const mode of ['clean', 'failure', 'alternate-python']) {
  test(`Copilot isolated complete validation preserves prepared source: ${mode}`, { skip: !linux }, t => {
    const f = copilotValidationFixture(t, mode === 'alternate-python');
    const result = f.run('Run complete repository validation', { ...f.validationEnv, VALIDATION_MODE: mode === 'failure' ? mode : 'clean' });
    assert.equal(result.status, mode === 'failure' ? 37 : 0, result.stdout + result.stderr);
    assert.deepEqual(f.snapshot(), f.before);
    const observed = JSON.parse(fs.readFileSync(f.log));
    assert.deepEqual(observed.args, ['-E', '-P', '-m', 'pre_commit', 'run', '--all-files']);
    assert.ok(!fs.existsSync(observed.cwd), 'Normal exit removes only the disposable copy.');
    if (mode === 'failure') assert.match(result.stdout, /failed with status 37; fixes remain only in the disposable copy/);
  });
}

for (const mode of ['git-dir', 'git-index', 'alternates', 'git-link', 'dependency-link', 'temporary-root', 'copy-failure', 'temporary-failure', 'missing-main', 'dirty-source', 'core-worktree']) {
  test(`Copilot isolated validation rejects unsafe preparation: ${mode}`, { skip: !linux }, t => {
    const f = copilotValidationFixture(t), extra = { ...f.validationEnv };
    let transform = value => value;
    if (mode === 'git-dir') extra.GIT_DIR = path.join(f.work, '.git');
    if (mode === 'git-index') extra.GIT_INDEX_FILE = path.join(f.work, '.git/index');
    if (mode === 'alternates') fs.writeFileSync(path.join(f.work, '.git/objects/info/alternates'), '\n');
    if (mode === 'git-link') {
      fs.renameSync(path.join(f.work, '.git'), path.join(f.root, 'external-git'));
      fs.writeFileSync(path.join(f.work, '.git'), `gitdir: ${path.join(f.root, 'external-git')}\n`);
    }
    if (mode === 'dependency-link') fs.symlinkSync(path.join(f.work, 'README.md'), path.join(f.work, 'node_modules/source-link'));
    if (mode === 'temporary-root') extra.RUNNER_TEMP = f.work;
    if (mode === 'copy-failure') transform = value => value.replace('cp -a --reflink=auto --', 'false # cp -a --reflink=auto --');
    if (mode === 'temporary-failure') transform = value => value.replace('mktemp -d -- "${temporary_root}/repository-validation.XXXXXXXX"', "bash -c 'exit 36'");
    if (mode === 'missing-main') f.git('update-ref', '-d', 'refs/remotes/origin/main');
    if (mode === 'dirty-source') f.put('README.md', 'existing agent edit\n');
    if (mode === 'core-worktree') f.git('config', 'core.worktree', f.work);

    const result = f.run('Run complete repository validation', extra, transform);
    assert.notEqual(result.status, 0, result.stdout + result.stderr);
    assert.ok(!fs.existsSync(f.log), 'Unsafe preparation must not invoke the suite.');
    if (mode === 'temporary-failure') assert.equal(result.status, 36, result.stderr);
    assert.equal(fs.readFileSync(path.join(f.work, 'README.md'), 'utf8'), mode === 'dirty-source' ? 'existing agent edit\n' : 'original\n');
  });
}

test('Copilot isolated validation survives forced stop without source restoration', { skip: !linux }, async t => {
  const f = copilotValidationFixture(t), script = path.join(f.root, 'stop.sh');
  fs.writeFileSync(script, copilotStep('Run complete repository validation').run);
  const child = spawn('bash', ['--noprofile', '--norc', script], { cwd: f.work,
    env: { ...f.env, ...f.validationEnv, VALIDATION_MODE: 'stop' }, detached: true, stdio: 'ignore' });
  const closed = new Promise(resolve => child.once('close', (code, signal) => resolve({ code, signal })));
  try {
    const deadline = Date.now() + 15000;
    while (!fs.existsSync(`${f.log}.ready`) && Date.now() < deadline) await new Promise(resolve => setTimeout(resolve, 25));
    assert.ok(fs.existsSync(`${f.log}.ready`), 'The sentinel must edit the copy before interruption.');
    process.kill(-child.pid, 'SIGKILL');
    assert.equal((await closed).signal, 'SIGKILL');
    assert.deepEqual(f.snapshot(), f.before);
    const observed = JSON.parse(fs.readFileSync(f.log));
    assert.equal(fs.readFileSync(path.join(observed.cwd, 'README.md'), 'utf8'), 'fixture hook edit\n');
    assert.ok(fs.existsSync(observed.cwd), 'SIGKILL did not run cleanup; source integrity cannot depend on it.');
  } finally {
    try { process.kill(-child.pid, 'SIGKILL'); } catch (error) { if (error.code !== 'ESRCH') throw error; }
    await closed;
  }
});

for (const mode of ['clean', 'failure']) {
  test(`Copilot isolated cleanup failure preserves validation status: ${mode}`, { skip: !linux }, t => {
    const f = copilotValidationFixture(t);
    const result = f.run('Run complete repository validation', { ...f.validationEnv, VALIDATION_MODE: mode },
      value => value.replace('rm -rf -- "${validation_root}"', 'false'));
    assert.equal(result.status, mode === 'clean' ? 1 : 37, result.stdout + result.stderr);
    assert.match(result.stdout, /Unable to remove the disposable validation copy/);
    assert.deepEqual(f.snapshot(), f.before);
  });
}

test('Copilot isolated validation stops on native directory-change failure', { skip: !linux }, t => {
  const f = copilotValidationFixture(t);
  const result = f.run('Run complete repository validation', { ...f.validationEnv, VALIDATION_MODE: 'clean' },
    value => 'cd() { return 36; }\n' + value);
  assert.equal(result.status, 36, result.stdout + result.stderr);
  assert.ok(!fs.existsSync(`${f.log}.dispatch`), 'A failed directory change must not dispatch validation.');
  assert.deepEqual(f.snapshot(), f.before);
});

// The dedicated service workflow prepares the same tools; ordinary CI and
// coding setup retain the complete suite. Compare every retained actual step.
const reviewSetup = parse(read('copilot-code-review.yml'));
const reviewJob = reviewSetup.jobs['copilot-setup-steps'];
test('dedicated review setup preserves every preparation guard and omits only the aggregate', () => {
  const coding = parse(read('copilot-setup-steps.yml'));
  assert.deepEqual(Object.keys(reviewSetup.jobs), ['copilot-setup-steps']);
  assert.deepEqual(reviewSetup.on, coding.on);
  assert.deepEqual(reviewSetup.permissions, {});
  assert.deepEqual(reviewJob.permissions, {});
  assert.equal(reviewJob.env, undefined);
  assert.equal(reviewJob['runs-on'], copilotJob['runs-on']);
  assert.equal(reviewJob['timeout-minutes'], copilotJob['timeout-minutes']);
  const complete = copilotStep('Run complete repository validation');
  assert.ok(complete);
  assert.match(complete.run, /-m pre_commit run --all-files/u);
  assert.deepEqual(reviewJob.steps, copilotJob.steps.filter(step => step !== complete));
  assert.equal(reviewJob.steps.some(step => step.run.includes('-m pre_commit run --all-files')), false);
  const readerGroup = run => {
    const source = run.replaceAll('\r\n', '\n');
    const starts = [...source.matchAll(/^([ \t]*)function Read-SetupJson \{$/gmu)];
    const runtimes = [...source.matchAll(/^([ \t]*)function Read-SetupRuntime \{$/gmu)];
    assert.equal(starts.length, 1, 'Exactly one JSON reader group is required.');
    assert.equal(runtimes.length, 1, 'Exactly one runtime reader is required.');
    const [start] = starts, [runtime] = runtimes, indent = start[1];
    assert.equal(runtime[1], indent);
    assert.ok(runtime.index > start.index);
    const end = new RegExp(`^${indent}\\}$`, 'mu').exec(source.slice(runtime.index));
    assert.ok(end, 'The runtime reader must have one closing group boundary.');
    const group = source.slice(start.index, runtime.index + end.index + end[0].length);
    for (const name of ['Read-SetupJson', 'Assert-UniqueJson', 'Assert-SetupShape', 'Read-SetupRuntime']) {
      assert.equal([...group.matchAll(new RegExp(`^[ \\t]*function ${name} \\{$`, 'gmu'))].length, 1, name);
    }
    return group.split('\n').map(line => {
      if (line === '') return line;
      assert.ok(line.startsWith(indent), 'Only embedding indentation may be removed.');
      return line.slice(indent.length);
    }).join('\n');
  };
  const compareReaders = runs => {
    assert.equal(runs.length, 4);
    const groups = runs.map(readerGroup);
    for (const [index, group] of groups.entries()) assert.equal(group, groups[0], `Reader group ${index} differs.`);
  };
  const runs = [coding.jobs['copilot-setup-steps'], reviewJob].flatMap(job =>
    ['Detect locked validation-tool layout', 'Set up verified official Node.js runtime'].map(name => {
      const steps = job.steps.filter(step => step.name === name);
      assert.equal(steps.length, 1, name);
      return steps[0].run;
    }));
  compareReaders(runs);
  const changedReader = run => {
    const from = '-AsHashtable -Depth 64 -ErrorAction Stop';
    assert.equal(run.split(from).length, 2, 'Mutation must change one actual JSON reader.');
    return run.replace(from, '-AsHashtable -Depth 63 -ErrorAction Stop');
  };
  assert.throws(() => compareReaders(runs.map((run, index) => index === 0 ? changedReader(run) : run)), { code: 'ERR_ASSERTION' });
  const pairedDrift = runs.map((run, index) => index % 2 === 0 ? changedReader(run) : run);
  assert.equal(pairedDrift[0], pairedDrift[2]);
  assert.equal(pairedDrift[1], pairedDrift[3]);
  assert.throws(() => compareReaders(pairedDrift), { code: 'ERR_ASSERTION' });
  for (const replacement of ['', 'function Read-SetupJson {\nfunction Read-SetupJson {']) {
    assert.throws(() => readerGroup(runs[0].replace('function Read-SetupJson {', replacement)), { code: 'ERR_ASSERTION' });
  }
});
for (const mode of ['declared', 'historical', 'missing-current-input']) {
  test(`dedicated review actual capability selection: ${mode}`, { skip: !linux }, t => {
    const f = copilotBodyFixture(t, 'work', reviewJob);
    copilotInputs(f, mode === 'historical' ? 'historical' : 'declared');
    if (mode === 'missing-current-input') fs.rmSync(path.join(f.work, 'requirements-dev.txt'));
    const result = f.run('Detect locked validation-tool layout');
    assert.equal(result.status === 0, mode !== 'missing-current-input', result.stdout + result.stderr);
    if (result.status === 0) assert.match(fs.readFileSync(f.env.GITHUB_OUTPUT, 'utf8'),
      new RegExp(`validation=${mode === 'historical' ? 'node-only' : 'full'}`));
  });
}
for (const mode of ['clean', 'bad-lock', 'native-failure']) {
  test(`dedicated review actual locked install admission: ${mode}`, { skip: !linux }, t => {
    const f = copilotPreinstallFixture(t, reviewJob);
    if (mode === 'bad-lock') {
      const lock = JSON.parse(fs.readFileSync(path.join(f.work, 'package-lock.json'), 'utf8'));
      Object.values(lock.packages).find(entry => entry.resolved).resolved = 'https://example.invalid/package.tgz';
      f.put('package-lock.json', JSON.stringify(lock));
    }
    if (mode === 'native-failure') f.put('.github/workflows/Validate-WorkflowPolicy.mjs', 'process.exit(37);\n');
    const result = f.run('modern');
    assert.equal(result.status, mode === 'clean' ? 0 : mode === 'native-failure' ? 37 : 1, result.stdout + result.stderr);
    assert.deepEqual(f.calls(), mode === 'clean' ? [copilotCiArgs, [...copilotCiArgs, '--prefix', '.github/workflows']] : []);
  });
}
for (const mode of ['clean', 'worktree', 'index-masked', 'untracked']) {
  test(`dedicated review actual final immutable guard: ${mode}`, { skip: !linux }, t => {
    const f = copilotBodyFixture(t, 'work', reviewJob); f.git('init', '-q'); copilotInputs(f, 'historical'); f.commit();
    assert.equal(f.run('Verify acquired immutable setup inputs').status, 0);
    if (mode === 'worktree' || mode === 'index-masked') f.put('package.json', 'changed\n');
    if (mode === 'index-masked') { f.git('add', 'package.json'); f.put('package.json', f.git('show', 'HEAD:package.json')); }
    if (mode === 'untracked') f.put('requirements-dev.txt');
    const result = f.run('Verify final immutable setup inputs');
    assert.equal(result.status === 0, mode === 'clean', result.stdout + result.stderr);
  });
}

// Strict whole declarations must fail at each actual workflow admission site.
const copilotMalformedRuntimeDeclarations = () => {
  const pin = copilotReaderPin('a'.repeat(64));
  const changed = edit => { const value = structuredClone(pin); edit(value); return JSON.stringify(value); };
  const spoof = object => ({ ...object, Count: Object.keys(object).length, Keys: Object.keys(object), PSBase: 'shadow', extra: true });
  const flat = { linuxX64Sha256: 'a'.repeat(64) };
  return [JSON.stringify(spoof(pin)), changed(p => p.preferred = spoof(p.preferred)),
    changed(p => p.recoveryCompatibility = spoof(p.recoveryCompatibility)), JSON.stringify(spoof(flat)),
    changed(p => Object.assign(p, { count: 3, keys: Object.keys(pin), extra: true })),
    ...[[], [pin], [flat], [pin, pin], [[pin]]].map(JSON.stringify),
    'null', '"declaration"', '{}', '{', '{"linuxX64Sha256":"' + 'a'.repeat(64) + '","linuxX64Sha256":"' + 'b'.repeat(64) + '"}',
    changed(p => p.schemaVersion = 1), changed(p => p.schemaVersion = '2'), changed(p => p.schemaVersion = 99),
    changed(p => p.linuxX64Sha256 = 'a'.repeat(64)), changed(p => delete p.preferred),
    changed(p => delete p.preferred.linuxX64Sha256), changed(p => delete p.preferred.windowsX64Sha256),
    changed(p => p.preferred.linuxX64Sha256 = 'A'.repeat(64)), changed(p => p.preferred.windowsX64Sha256 = []),
    ...[null, 1, []].flatMap(value => [changed(p => p.preferred = value), changed(p => p.recoveryCompatibility = value)]),
    ...[null, 1, [], 'A'.repeat(64), 'a'.repeat(63), 'a'.repeat(65)].map(linuxX64Sha256 => JSON.stringify({ linuxX64Sha256 })),
    changed(p => p.preferred.linuxX64Sha256 = null), changed(p => p.preferred.windowsX64Sha256 = 'b'.repeat(63)),
    changed(p => p.recoveryCompatibility.linuxX64Sha256 = 'C'.repeat(64)),
    changed(p => p.recoveryCompatibility.node = '22.x'), changed(p => p.recoveryCompatibility.npm = ['10.9.9']),
    changed(p => delete p.recoveryCompatibility.linuxX64Sha256), changed(p => p.recoveryCompatibility.url = 'https://example.invalid/'),
    JSON.stringify(pin).replace('"schemaVersion":2', '"schemaVersion":2,"schemaVersion":2'),
    JSON.stringify(pin).replace('"node":"22.23.3"', '"node":"22.23.3","n\\u006fde":"22.23.3"')];
};
const malformedRuntimeDeclarations = () => {
  const pin = runtimePin('a'.repeat(64));
  const changed = edit => { const value = structuredClone(pin); edit(value); return JSON.stringify(value); };
  const spoof = object => ({ ...object, Count: Object.keys(object).length, Keys: Object.keys(object), PSBase: 'shadow', extra: true });
  const flat = { linuxX64Sha256: 'a'.repeat(64) };
  return [JSON.stringify(spoof(pin)), changed(p => p.preferred = spoof(p.preferred)),
    changed(p => p.recoveryCompatibility = spoof(p.recoveryCompatibility)), JSON.stringify(spoof(flat)),
    changed(p => Object.assign(p, { count: 3, keys: Object.keys(pin), extra: true })),
    ...[[], [pin], [flat], [pin, pin], [[pin]]].map(JSON.stringify),
    'null', '"declaration"', '{}', '{', '{"linuxX64Sha256":"' + 'a'.repeat(64) + '","linuxX64Sha256":"' + 'b'.repeat(64) + '"}',
    changed(p => p.schemaVersion = 1), changed(p => p.schemaVersion = '2'), changed(p => p.schemaVersion = 99),
    changed(p => p.linuxX64Sha256 = 'a'.repeat(64)), changed(p => delete p.preferred),
    changed(p => delete p.preferred.linuxX64Sha256), changed(p => delete p.preferred.windowsX64Sha256),
    changed(p => p.preferred.linuxX64Sha256 = 'A'.repeat(64)), changed(p => p.preferred.windowsX64Sha256 = []),
    changed(p => p.recoveryCompatibility.node = '22.x'), changed(p => p.recoveryCompatibility.npm = ['10.9.9']),
    changed(p => delete p.recoveryCompatibility.linuxX64Sha256), changed(p => p.recoveryCompatibility.url = 'https://example.invalid/'),
    JSON.stringify(pin).replace('"schemaVersion":2', '"schemaVersion":2,"schemaVersion":2'),
    JSON.stringify(pin).replace('"node":"22.23.3"', '"node":"22.23.3","n\\u006fde":"22.23.3"')];
};
for (const workflow of ['copilot-setup-steps.yml', 'copilot-code-review.yml']) {
  test(`${workflow}: whole malformed declaration rejects before curl at both sites`, { skip: !linux }, t => {
    const job = parse(read(workflow)).jobs['copilot-setup-steps'];
    for (const raw of copilotMalformedRuntimeDeclarations()) {
      const f = copilotBodyFixture(t, 'work', job); copilotInputs(f);
      f.put('.github/workflows/ci-toolchain.json', raw);
      const curl = path.join(f.root, 'curl');
      fs.writeFileSync(curl, `#!/bin/sh\nprintf reached > '${f.root}/curl-marker'\nexit 19\n`, { mode: 0o700 });
      const admitted = f.run('Detect locked validation-tool layout');
      assertReaderCompleted(admitted, 'Reader detection malformed input');
      assert.notEqual(admitted.status, 0, raw);
      assert.ok(!fs.existsSync(f.env.GITHUB_OUTPUT) || !fs.readFileSync(f.env.GITHUB_OUTPUT, 'utf8').includes('validation='));
      const acquired = f.run('Set up verified official Node.js runtime', { TOOLCHAIN_LAYOUT: 'modern' },
        source => source.replaceAll("'/usr/bin/curl'", quote(curl)).replaceAll("'/bin/curl'", quote(curl)));
      assertReaderCompleted(acquired, 'Reader runtime malformed input');
      assert.notEqual(acquired.status, 0, raw);
      assert.equal(fs.existsSync(path.join(f.root, 'curl-marker')), false, raw);
      assert.equal(fs.existsSync(f.env.GITHUB_PATH), false, raw);
    }
  });
}

for (const workflow of ['copilot-setup-steps.yml', 'copilot-code-review.yml']) {
  test(`${workflow}: reader bridge rejects terminal newlines in declared tokens`, { skip: !linux }, t => {
    const job = parse(read(workflow)).jobs['copilot-setup-steps'];
    for (const format of ['historical-flat', 'schema2']) {
      const digestFields = format === 'schema2'
        ? ['preferred.linuxX64Sha256', 'preferred.windowsX64Sha256', 'recoveryCompatibility.linuxX64Sha256']
        : ['linuxX64Sha256'];
      for (const field of ['engines.node', 'engines.npm', ...digestFields]) for (const suffix of ['\n', '\r\n']) {
        const f = copilotBodyFixture(t, 'work', job); copilotInputs(f);
        const declaration = format === 'schema2' ? copilotReaderPin('a'.repeat(64)) : { linuxX64Sha256: 'a'.repeat(64) };
        const manifest = JSON.parse(fs.readFileSync(path.join(f.work, 'package.json'), 'utf8'));
        const keys = field.split('.'), leaf = keys.pop();
        const target = keys.reduce((value, key) => value[key], field.startsWith('engines.') ? manifest : declaration);
        target[leaf] += suffix;
        f.put('package.json', JSON.stringify(manifest));
        f.put('.github/workflows/ci-toolchain.json', JSON.stringify(declaration));
        const label = `${workflow}/${format}/${field}/${JSON.stringify(suffix)}`;
        const curl = path.join(f.root, 'curl'), marker = path.join(f.root, 'curl-marker');
        fs.writeFileSync(curl, `#!/bin/sh\nprintf reached > '${marker}'\nexit 19\n`, { mode: 0o700 });
        const detected = assertReaderCompleted(f.run('Detect locked validation-tool layout'), `${label}/detection`);
        assert.notEqual(detected.status, 0, label);
        assert.ok(!fs.existsSync(f.env.GITHUB_OUTPUT) || !fs.readFileSync(f.env.GITHUB_OUTPUT, 'utf8').includes('validation='), label);
        const acquired = assertReaderCompleted(f.run('Set up verified official Node.js runtime', { TOOLCHAIN_LAYOUT: 'modern' },
          source => source.replaceAll("'/usr/bin/curl'", quote(curl)).replaceAll("'/bin/curl'", quote(curl))), `${label}/runtime`);
        assert.notEqual(acquired.status, 0, label);
        const diagnostic = field.startsWith('engines.') ? /invalid declared runtime tuple/ : /invalid runtime digest/;
        assert.match(detected.stderr, diagnostic, label);
        assert.match(acquired.stderr, diagnostic, label);
        assert.equal(fs.existsSync(marker), false, label);
        assert.equal(fs.existsSync(f.env.GITHUB_PATH), false, label);
      }
    }
  });
}

for (const workflow of ['copilot-setup-steps.yml', 'copilot-code-review.yml']) {
  for (const kind of ['historical-flat', 'schema2', 'pre-declaration', 'historical', 'historical-full', 'legacy']) {
    test(`${workflow}: reader bridge capability: ${kind}`, { skip: !linux }, t => {
      const job = parse(read(workflow)).jobs['copilot-setup-steps'];
      const f = copilotBodyFixture(t, 'work', job);
      copilotInputs(f, ['historical-flat', 'schema2'].includes(kind) ? 'declared' : kind === 'historical-full' ? 'historical' : kind);
      if (kind === 'schema2') f.put('.github/workflows/ci-toolchain.json', JSON.stringify(copilotReaderPin('a'.repeat(64))));
      if (kind === 'historical-full') for (const name of copilotFullInputs) f.put(name);
      const result = assertReaderCompleted(f.run('Detect locked validation-tool layout'), `${workflow}/${kind}`);
      assert.equal(result.status, 0, result.stdout + result.stderr);
      const output = fs.readFileSync(f.env.GITHUB_OUTPUT, 'utf8');
      assert.match(output, new RegExp(`layout=${kind === 'legacy' ? 'legacy' : 'modern'}`));
      assert.match(output, new RegExp(`validation=${['historical', 'legacy'].includes(kind) ? 'node-only' : 'full'}`));
      if (['historical', 'legacy'].includes(kind)) assert.match(result.stdout, /Python and full validation are unavailable/);
      assert.equal(fs.existsSync(f.env.GITHUB_PATH), false, 'Detection cannot publish a runtime.');
    });
  }
}

for (const workflow of ['copilot-setup-steps.yml', 'copilot-code-review.yml']) {
  test(`${workflow}: reader bridge declaration exact and oversized byte bounds`, { skip: !linux }, t => {
    const job = parse(read(workflow)).jobs['copilot-setup-steps'];
    for (const length of [16384, 16385]) {
      const f = copilotBodyFixture(t, 'work', job); copilotInputs(f);
      const raw = JSON.stringify({ linuxX64Sha256: 'a'.repeat(64) }).padEnd(length, ' ');
      assert.equal(Buffer.byteLength(raw), length);
      f.put('.github/workflows/ci-toolchain.json', raw);
      const curl = path.join(f.root, 'curl'), marker = path.join(f.root, 'curl-marker');
      fs.writeFileSync(curl, `#!/bin/sh\nprintf reached > '${marker}'\nexit 19\n`, { mode: 0o700 });
      const detected = assertReaderCompleted(f.run('Detect locked validation-tool layout'), `${workflow}/bound detection/${length}`);
      assert.equal(detected.status === 0, length === 16384, detected.stdout + detected.stderr);
      const acquired = assertReaderCompleted(f.run('Set up verified official Node.js runtime', { TOOLCHAIN_LAYOUT: 'modern' },
        source => source.replaceAll("'/usr/bin/curl'", quote(curl)).replaceAll("'/bin/curl'", quote(curl))),
      `${workflow}/bound runtime/${length}`);
      assert.notEqual(acquired.status, 0);
      assert.equal(fs.existsSync(marker), length === 16384, acquired.stdout + acquired.stderr);
      assert.match(acquired.stderr, length === 16384 ? /download exited 19/ : /bounded regular JSON input required/);
      assert.equal(fs.existsSync(f.env.GITHUB_PATH), false);
      if (length === 16385) assert.ok(!fs.existsSync(f.env.GITHUB_OUTPUT) || !fs.readFileSync(f.env.GITHUB_OUTPUT, 'utf8').includes('validation='));
    }
  });
}

// The dispatch log is outside owned staging, so cleanup cannot erase evidence
// that a malformed declaration reached the replacement acquisition executable.
function ordinaryDeclarationFixture(t, raw, source = read('Initialize-CiToolchain.ps1'), curlAction = '', options = {}) {
  const f = fixture(t), workflows = path.join(f.work, '.github/workflows'); fs.mkdirSync(workflows, { recursive: true });
  if (options.selectors) selectorGitLauncher(f);
  fs.writeFileSync(path.join(f.work, 'package.json'), JSON.stringify(options.packageValue ?? { engines: { node: '24.18.1', npm: '11.16.0' } }));
  fs.writeFileSync(path.join(workflows, 'ci-toolchain.json'), raw);
  fs.writeFileSync(path.join(workflows, 'Test-CheckoutCredentials.ps1'), read('Test-CheckoutCredentials.ps1')
    .replaceAll('/usr/bin/git', f.git).replaceAll("'/bin/git'", quote(f.git)));
  const curl = path.join(f.root, 'curl'), dispatchLog = path.join(f.root, 'curl-dispatches');
  assert.equal(fs.existsSync(dispatchLog), false);
  fs.writeFileSync(curl, `#!${process.execPath}
${fq40CurlQueryStub}
${options.selectors ? `{ const fs = require('node:fs'); ${selectorObserver} }` : ''}
require('node:fs').appendFileSync(${JSON.stringify(dispatchLog)}, 'dispatch\\n');
${curlAction}
process.exit(99);
`, { mode: 0o700 });
  fs.writeFileSync(path.join(workflows, 'Initialize-CiToolchain.ps1'), source.replaceAll('/usr/bin/curl', curl));
  const result = f.run(`${options.preference ?? ''}& ${quote(path.join(workflows, 'Initialize-CiToolchain.ps1'))}`, options.selectors ? selectorEnvironment(options.selectors) : {});
  const dispatches = fs.existsSync(dispatchLog) ? fs.readFileSync(dispatchLog, 'utf8').trim().split('\n') : [];
  return { ...f, result, dispatches };
}

function assertOrdinaryFailureCleanup(f) {
  assert.equal(f.result.error, undefined);
  assert.notEqual(f.result.status, 0, f.result.stdout + f.result.stderr);
  assert.equal(fs.existsSync(path.join(f.root, 'styleguide-node')), false, f.result.stdout + f.result.stderr);
  assert.equal(fs.readFileSync(path.join(f.root, 'path'), 'utf8'), '');
  assert.equal(fs.readFileSync(path.join(f.root, 'env'), 'utf8'), '');
}

function assertNoOrdinaryDispatch(f) {
  assert.deepEqual(f.dispatches, [], 'Malformed declaration must not dispatch curl.');
}

test('ordinary schema2 rejects malformed and historical declarations before download', { skip: !linux }, t => {
  const nestedInvalidShapes = ['preferred', 'recoveryCompatibility'].flatMap(role =>
    [null, 1, []].map(value => { const pin = runtimePin('a'.repeat(64)); pin[role] = value; return JSON.stringify(pin); }));
  for (const raw of [...malformedRuntimeDeclarations(), JSON.stringify({ linuxX64Sha256: 'a'.repeat(64) }), ...nestedInvalidShapes]) {
    const f = ordinaryDeclarationFixture(t, raw);
    assertOrdinaryFailureCleanup(f);
    assertNoOrdinaryDispatch(f);
    let document;
    try { document = JSON.parse(raw); } catch { continue; }
    if (document === null || Array.isArray(document) || typeof document !== 'object') {
      assert.match(f.result.stderr, /JSON input must be an object/u);
    } else if (nestedInvalidShapes.includes(raw)) {
      assert.match(f.result.stderr, /unexpected object fields/u);
    }
  }
});

// These cases belong to the ordinary initializer, whose schema is always schema2.
function ordinaryExactTokenCases() {
  const pin = runtimePin('a'.repeat(64));
  const packageValue = { engines: { node: '24.18.1', npm: '11.16.0' } };
  const make = (name, edit, valid = false) => {
    const value = { pin: structuredClone(pin), package: structuredClone(packageValue) };
    edit(value);
    return { name, valid, pin: JSON.stringify(value.pin), package: JSON.stringify(value.package) };
  };
  const fields = ['package.engines.node', 'package.engines.npm',
    'pin.preferred.linuxX64Sha256', 'pin.preferred.windowsX64Sha256', 'pin.recoveryCompatibility.linuxX64Sha256',
    'pin.recoveryCompatibility.node', 'pin.recoveryCompatibility.npm'];
  const change = (value, field, text, prefix = false) => {
    const parts = field.split('.'), key = parts.pop();
    const owner = parts.reduce((object, part) => object[part], value);
    owner[key] = prefix ? text + owner[key] : owner[key] + text;
  };
  return [make('valid baseline', () => {}, true),
    make('valid variable patch', value => value.package.engines.node = '24.18.2', true),
    ...fields.flatMap(field => [['LF', '\n'], ['CRLF', '\r\n'], ['TAB', '\t'], ['extra', 'x']]
      .map(([label, text]) => make(`${field} ${label}`, value => change(value, field, text)))),
    ...fields.slice(0, 5).map(field => make(`${field} leadingLF`, value => change(value, field, '\n', true)))];
}

test('FQ30 ordinary exact token admission preserves valid values and refuses extra characters', t => {
  const original = read('Initialize-CiToolchain.ps1');
  const boundaries = ['function Assert-Shape {', 'function Assert-WindowsWriter {',
    "Assert-Shape $objPin @('schemaVersion', 'preferred', 'recoveryCompatibility')",
    '$strRunnerRoot = Assert-OrdinaryPath $env:RUNNER_TEMP -Directory'];
  const offsets = boundaries.map(anchor => {
    assert.equal(original.split(anchor).length, 2, 'Admission extraction boundary must occur exactly once.');
    return original.indexOf(anchor);
  });
  assert.ok(offsets.every((offset, index) => index === 0 || offset > offsets[index - 1]));
  const helper = original.slice(offsets[0], offsets[1]);
  const admission = original.slice(offsets[2], offsets[3]);
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'styleguide-admission-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const cases = ordinaryExactTokenCases(), casesPath = path.join(root, 'cases.json');
  fs.writeFileSync(casesPath, JSON.stringify(cases));
  const script = path.join(root, 'admission.ps1');
  // Execute the actual pure admission stage. Whole-script side effects are tested separately.
  fs.writeFileSync(script, `$ErrorActionPreference = 'Stop'\n${helper}\n$admission = {\n${admission}\n}
$cases = Get-Content -LiteralPath ${quote(casesPath)} -Raw | ConvertFrom-Json
$results = @(foreach ($case in $cases) {
    $objPin = ConvertFrom-Json -InputObject $case.pin -AsHashtable
    $objPackage = ConvertFrom-Json -InputObject $case.package -AsHashtable
    $accepted = $false
    try { & $admission; $accepted = $true }
    catch { if ($_.Exception.Message -cne 'The reviewed runtime declaration is invalid.') { throw } }
    [ordered]@{ name = $case.name; accepted = $accepted }
})
ConvertTo-Json -InputObject $results -Depth 3
`);
  const result = assertCompletedProcess(spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', script], {
    cwd: root, encoding: 'utf8', timeout: 30000, windowsHide: true,
  }), 'FQ30 actual ordinary admission stage');
  assert.equal(result.status, 0, result.stdout + result.stderr);
  assert.deepEqual(JSON.parse(result.stdout), cases.map(value => ({ name: value.name, accepted: value.valid })));
  assert.equal(read('Initialize-CiToolchain.ps1'), original);
});

test('FQ30 ordinary newline declarations refuse before download and runner publication', { skip: !linux }, t => {
  for (const value of ordinaryExactTokenCases().filter(row => / (?:LF|CRLF)$/u.test(row.name))) {
    const f = ordinaryDeclarationFixture(t, value.pin, read('Initialize-CiToolchain.ps1'), '', {
      packageValue: JSON.parse(value.package),
    });
    assertOrdinaryFailureCleanup(f);
    assertNoOrdinaryDispatch(f);
    assert.match(f.result.stderr, /The reviewed runtime declaration is invalid/u, value.name);
    assert.deepEqual(f.calls(), [], 'Malformed values must not reach credential setup.');
  }
});


// Whole WhatIf still refuses at the real directory gate. This exact copied-source
// anchor perturbs cleanup preferences only after successful real ownership.
function initializerCleanupStage(source, whatIf = false) {
  const anchor = '    $boolOwned = $true\n';
  assert.equal(source.split(anchor).length, 2, 'Cleanup ownership anchor must occur exactly once.');
  const marker = "    Write-Output 'FQ23 cleanup stage'\n";
  if (!whatIf) return source.replace(anchor, anchor + marker);
  const endAnchor = "    $env:npm_config_userconfig = Join-Path $strNodeRoot 'npm-user.config'\n";
  assert.equal(source.split(endAnchor).length, 2, 'Cleanup configuration anchor must occur exactly once.');
  assert.equal(source.includes('$boolFq24PriorWhatIf'), false, 'Fixture preference variable must not collide with actual source.');
  const start = source.indexOf(anchor) + anchor.length, end = source.indexOf(endAnchor);
  assert.ok(end > start, 'Actual cleanup must end before reviewed configuration and runtime acquisition.');
  const cleanup = source.slice(start, end);
  const scoped = marker + '    $boolFq24PriorWhatIf = $WhatIfPreference\n' +
    '    try {\n        $WhatIfPreference = $true\n' +
    cleanup.replace(/^/gmu, '    ').trimEnd() + '\n' +
    '    } finally {\n        $WhatIfPreference = $boolFq24PriorWhatIf\n    }\n' +
    '    if ($WhatIfPreference -ne $boolFq24PriorWhatIf) {\n' +
    "        throw 'FQ24 cleanup preference restoration failed'\n    }\n" +
    "    Write-Output 'FQ24 cleanup preference restored'\n";
  return source.slice(0, start) + scoped + source.slice(end);
}

for (const family of ['npm', 'absent']) {
  test(`FQ23 ordinary Low sanitation ${family}`, { skip: !linux }, t => {
    const f = ordinaryDeclarationFixture(t, JSON.stringify(runtimePin('a'.repeat(64))),
      initializerCleanupStage(read('Initialize-CiToolchain.ps1')), '', { selectors: family, preference: "$ConfirmPreference='Low'; " });
    assertOrdinaryFailureCleanup(f);
    assert.match(f.result.stdout, /FQ23 cleanup stage/u);
    assert.match(f.result.stderr, /Runtime download failed: 99/u);
    assert.deepEqual(f.dispatches, ['dispatch']);
    assert.equal(f.calls().filter(row => row[0] === 'FQ23 sanitation observer').length, 1);
  });
}

test('FQ23 initializer internal-stage WhatIf sanitation', { skip: !linux }, t => {
  const f = ordinaryDeclarationFixture(t, JSON.stringify(runtimePin('a'.repeat(64))),
    initializerCleanupStage(read('Initialize-CiToolchain.ps1'), true), '', { selectors: 'all' });
  assertOrdinaryFailureCleanup(f);
  assert.match(f.result.stdout, /FQ23 cleanup stage/u);
  assert.match(f.result.stdout, /FQ24 cleanup preference restored/u);
  assert.doesNotMatch(f.result.stderr, /Restricted staging directory creation was declined/u);
  assert.match(f.result.stderr, /Runtime download failed: 99/u);
  assert.deepEqual(f.dispatches, ['dispatch']);
  assert.equal(f.calls().filter(row => row[0] === 'FQ23 sanitation observer').length, 1);
});

for (const parameter of ['Confirm', 'WhatIf']) for (const family of ['fixed', 'npm']) {
  test(`FQ23 initializer sanitation mutation ${parameter} ${family}`, { skip: !linux }, t => {
    const original = read('Initialize-CiToolchain.ps1');
    const anchor = family === 'fixed'
      ? 'Remove-Item Env:STYLEGUIDE_RECOVERY_NODE22, Env:NODE_OPTIONS, Env:NODE_PATH -ErrorAction SilentlyContinue -Confirm:$false -WhatIf:$false'
      : 'Remove-Item -LiteralPath "Env:$($_.Name)" -Confirm:$false -WhatIf:$false';
    assert.equal(original.split(anchor).length, 2, 'Exactly one intended removal site must change.');
    const mutated = original.replace(anchor, anchor.replace(` -${parameter}:$false`, ''));
    assert.notEqual(mutated, original);
    const options = { selectors: family, preference: parameter === 'Confirm' ? "$ConfirmPreference='Low'; " : '' };
    const baseline = ordinaryDeclarationFixture(t, JSON.stringify(runtimePin('a'.repeat(64))),
      initializerCleanupStage(original, parameter === 'WhatIf'), '', options);
    assertOrdinaryFailureCleanup(baseline);
    assert.match(baseline.result.stdout, /FQ23 cleanup stage/u);
    if (parameter === 'WhatIf') assert.match(baseline.result.stdout, /FQ24 cleanup preference restored/u);
    assert.match(baseline.result.stderr, /Runtime download failed: 99/u);
    assert.deepEqual(baseline.dispatches, ['dispatch']);
    assert.equal(baseline.calls().filter(row => row[0] === 'FQ23 sanitation observer').length, 1);
    const witness = ordinaryDeclarationFixture(t, JSON.stringify(runtimePin('a'.repeat(64))),
      initializerCleanupStage(mutated, parameter === 'WhatIf'), '', options);
    assertOrdinaryFailureCleanup(witness);
    assert.match(witness.result.stdout, /FQ23 cleanup stage/u);
    assert.deepEqual(witness.dispatches, []);
    if (parameter === 'Confirm') {
      assert.match(witness.result.stderr, family === 'fixed' ? /Remove-Item Env:STYLEGUIDE_RECOVERY_NODE22/u : /Remove-Item -LiteralPath/u);
      assert.match(witness.result.stderr, /NonInteractive|non-interactive/iu);
      assert.doesNotMatch(witness.result.stderr, /FQ23 sanitation observer/u);
      assert.equal(witness.calls().filter(row => row[0] === 'FQ23 sanitation observer').length, 0);
    } else {
      assert.match(witness.result.stdout, /FQ24 cleanup preference restored/u);
      assert.doesNotMatch(witness.result.stderr, /Restricted staging directory creation was declined/u);
      assert.match(witness.result.stderr, /FQ23 sanitation observer rejected retained selector/u);
      assert.match(witness.result.stderr, /Runtime download failed: 98/u);
      assert.equal(witness.calls().filter(row => row[0] === 'FQ23 sanitation observer').length, 1);
    }
    assert.doesNotMatch(witness.result.stderr, /Runtime download failed: 99/u);
  });
}

test('F5 ordinary valid declaration proves curl dispatch observation', { skip: !linux }, t => {
  const source = initializerCleanupStage(read('Initialize-CiToolchain.ps1'));
  const f = ordinaryDeclarationFixture(t, JSON.stringify(runtimePin('a'.repeat(64))), source, '', { selectors: 'fixed' });
  assertOrdinaryFailureCleanup(f);
  assert.deepEqual(f.dispatches, ['dispatch']);
  assert.match(f.result.stderr, /Runtime download failed: 99/u);
  assert.match(f.result.stdout, /FQ23 cleanup stage/u);
  assert.equal(f.calls().filter(row => row[0] === 'FQ23 sanitation observer').length, 1);
  const initializer = path.join(f.work, '.github/workflows/Initialize-CiToolchain.ps1');
  const dispatchLog = path.join(f.root, 'curl-dispatches'), initialDispatches = fs.readFileSync(dispatchLog);
  const whatIf = f.run(`$WhatIfPreference=$true; $ConfirmPreference='Low'; & ${quote(initializer)}`, selectorEnvironment('fixed'));
  assertOrdinaryFailureCleanup({ ...f, result: whatIf });
  assert.match(whatIf.stderr, /Restricted staging directory creation was declined/u);
  assert.doesNotMatch(whatIf.stdout, /FQ23 cleanup stage/u);
  assert.equal(f.calls().filter(row => row[0] === 'FQ23 sanitation observer').length, 1);
  assert.deepEqual(fs.readFileSync(dispatchLog), initialDispatches, 'Inherited WhatIf must refuse before additional curl dispatch.');
  const lowConfirm = f.run(`$ConfirmPreference='Low'; & ${quote(initializer)}`, selectorEnvironment('fixed'));
  assertOrdinaryFailureCleanup({ ...f, result: lowConfirm });
  assert.match(lowConfirm.stderr, /Runtime download failed: 99/u);
  assert.match(lowConfirm.stdout, /FQ23 cleanup stage/u);
  assert.equal(f.calls().filter(row => row[0] === 'FQ23 sanitation observer').length, 2);
  assert.deepEqual(fs.readFileSync(dispatchLog, 'utf8').trim().split('\n'), ['dispatch', 'dispatch'],
    'Low confirmation preference must reach exactly one additional curl dispatch without prompting.');
  t.diagnostic(`Valid declaration control: child status ${f.result.status}, curl dispatches ${f.dispatches.length}; inherited WhatIf refused and low confirmation completed.`);
});

for (const mutation of ['dotted-shape-properties', 'enumerated-singleton-root']) {
  test(`F5 ordinary admission mutation witness: ${mutation}`, { skip: !linux }, t => {
    const original = read('Initialize-CiToolchain.ps1'), pin = runtimePin('a'.repeat(64));
    const shape = `    if ($Object -isnot [Collections.IDictionary] -or $Object.psbase.Count -ne $Keys.Count -or
        @($Object.psbase.Keys | Where-Object {
            $_ -cnotin $Keys
        }).Count) {
        throw 'The reviewed runtime declaration is invalid: unexpected object fields.'
    }
`;
    const rootGuard = `        if ($objJsonDocument.RootElement.ValueKind -ne [Text.Json.JsonValueKind]::Object) {
            throw 'toolchain: JSON input must be an object'
        }
`;
    const anchor = mutation === 'dotted-shape-properties' ? shape : rootGuard;
    assert.equal(original.split(anchor).length, 2, 'The exact mutation anchor must occur once.');
    const replacement = mutation === 'dotted-shape-properties'
      ? shape.replace('$Object.psbase.Count', '$Object.Count').replace('$Object.psbase.Keys', '$Object.Keys') : '';
    const mutated = original.replace(anchor, replacement);
    assert.notEqual(mutated, original);
    const raw = JSON.stringify(mutation === 'dotted-shape-properties'
      ? { ...pin, Count: Object.keys(pin).length, Keys: Object.keys(pin), PSBase: 'shadow', extra: true } : [pin]);
    const admitted = ordinaryDeclarationFixture(t, raw, original);
    assertOrdinaryFailureCleanup(admitted);
    assertNoOrdinaryDispatch(admitted);
    assert.match(admitted.result.stderr, mutation === 'dotted-shape-properties'
      ? /unexpected object fields/u : /JSON input must be an object/u);
    const witness = ordinaryDeclarationFixture(t, raw, mutated);
    // The former status/cleanup/channel oracle still passes for this regression.
    assertOrdinaryFailureCleanup(witness);
    assert.deepEqual(witness.dispatches, ['dispatch']);
    assert.match(witness.result.stderr, /download failed/u);
    assert.throws(() => assertNoOrdinaryDispatch(witness), /Malformed declaration must not dispatch curl/u);
    assert.equal(read('Initialize-CiToolchain.ps1'), original, 'Mutation must remain inside the disposable fixture.');
    t.diagnostic(`${mutation}: original dispatches 0; mutated dispatches 1; child status ${witness.result.status}; old cleanup oracle passes; new dispatch oracle rejects.`);
  });
}

function cleanupAction(mode) {
  return `
const fs = require('node:fs'), path = require('node:path');
const root = process.env.RUNNER_TEMP, stage = path.join(root, 'styleguide-node');
const marker = path.join(stage, '.owner'), mode = ${JSON.stringify(mode)};
const original = fs.lstatSync(stage, { bigint: true }), nonce = fs.readFileSync(marker, 'utf8');
const outside = path.join(root, 'outside'); fs.mkdirSync(outside);
fs.writeFileSync(path.join(outside, 'sentinel'), 'outside must survive');
if (mode === 'metadata-change') {
  fs.writeFileSync(path.join(stage, 'normal-work'), 'ordinary staged data');
  fs.utimesSync(stage, new Date('2001-01-01T00:00:00Z'), new Date('2001-01-01T00:00:00Z'));
} else if (mode === 'directory-replace' || mode === 'root-link') {
  fs.renameSync(stage, path.join(root, 'retained-original'));
  if (mode === 'root-link') fs.symlinkSync(outside, stage, 'dir');
  else {
    fs.mkdirSync(stage, { mode: 0o700 });
    fs.writeFileSync(path.join(stage, '.owner'), nonce);
    fs.writeFileSync(path.join(stage, 'replacement-sentinel'), 'replacement must survive');
  }
} else if (mode === 'marker-replace' || mode === 'marker-link') {
  fs.renameSync(marker, path.join(root, 'retained-marker'));
  if (mode === 'marker-link') {
    fs.writeFileSync(path.join(outside, 'marker'), nonce);
    fs.symlinkSync(path.join(outside, 'marker'), marker);
  } else fs.writeFileSync(marker, nonce);
} else if (mode === 'marker-content') fs.writeFileSync(marker, 'f'.repeat(32));
else throw new Error('Unexpected cleanup fixture mode');
const after = fs.lstatSync(stage, { bigint: true });
fs.writeFileSync(path.join(root, 'cleanup-action.json'), JSON.stringify({ mode,
  originalDevice: String(original.dev), originalInode: String(original.ino),
  afterDevice: String(after.dev), afterInode: String(after.ino),
  originalMtime: String(original.mtimeNs), afterMtime: String(after.mtimeNs) }));
`;
}

function assertRetainedCleanup(f, mode) {
  assert.equal(f.result.error, undefined);
  assert.equal(f.result.signal, null);
  assert.notEqual(f.result.status, 0, f.result.stdout + f.result.stderr);
  assert.deepEqual(f.dispatches, ['dispatch']);
  assert.match(f.result.stderr, /Runtime download failed: 99/u);
  assert.match(f.result.stdout, /Runtime cleanup could not prove completion/u);
  assert.equal(fs.existsSync(path.join(f.root, 'styleguide-node')), true);
  assert.equal(fs.readFileSync(path.join(f.root, 'path'), 'utf8'), '');
  assert.equal(fs.readFileSync(path.join(f.root, 'env'), 'utf8'), '');
  assert.equal(fs.readFileSync(path.join(f.root, 'outside/sentinel'), 'utf8'), 'outside must survive');
  if (mode === 'directory-replace') {
    assert.equal(fs.readFileSync(path.join(f.root, 'styleguide-node/replacement-sentinel'), 'utf8'), 'replacement must survive');
    assert.equal(fs.existsSync(path.join(f.root, 'retained-original/.owner')), true);
  }
  if (mode === 'marker-replace' || mode === 'marker-link') assert.equal(fs.existsSync(path.join(f.root, 'retained-marker')), true);
  if (mode === 'root-link') assert.equal(fs.lstatSync(path.join(f.root, 'styleguide-node')).isSymbolicLink(), true);
  if (mode === 'marker-link') assert.equal(fs.lstatSync(path.join(f.root, 'styleguide-node/.owner')).isSymbolicLink(), true);
}

for (const mode of ['metadata-change', 'directory-replace', 'marker-replace', 'marker-content', 'root-link', 'marker-link']) {
  test(`F6 ordinary failure cleanup: ${mode}`, { skip: !linux }, t => {
    const f = ordinaryDeclarationFixture(t, JSON.stringify(runtimePin('a'.repeat(64))),
      read('Initialize-CiToolchain.ps1'), cleanupAction(mode));
    if (mode === 'metadata-change') {
      assertOrdinaryFailureCleanup(f);
      assert.deepEqual(f.dispatches, ['dispatch']);
      assert.match(f.result.stderr, /Runtime download failed: 99/u);
      assert.doesNotMatch(f.result.stdout, /Runtime cleanup could not prove completion/u);
      assert.equal(fs.readFileSync(path.join(f.root, 'outside/sentinel'), 'utf8'), 'outside must survive');
      const action = JSON.parse(fs.readFileSync(path.join(f.root, 'cleanup-action.json')));
      assert.equal(action.originalDevice, action.afterDevice);
      assert.equal(action.originalInode, action.afterInode);
      assert.notEqual(action.originalMtime, action.afterMtime);
    } else assertRetainedCleanup(f, mode);
  });
}

for (const mutation of ['timestamp-identity', 'directory-and-marker-identity', 'marker-identity', 'marker-content']) {
  test(`F6 cleanup mutation witness: ${mutation}`, { skip: !linux }, t => {
    const original = read('Initialize-CiToolchain.ps1');
    let source = original;
    const once = (anchor, replacement) => {
      assert.equal(source.split(anchor).length, 2, 'Exact F6 mutation anchor must occur once.');
      source = source.replace(anchor, replacement);
    };
    const directoryCheck = '(Get-OwnedPathIdentity $strNodeRoot -Directory) -cne $strRootIdentity';
    const markerCheck = '(Get-OwnedPathIdentity $strMarker) -cne $strMarkerIdentity';
    let mode;
    if (mutation === 'timestamp-identity') {
      mode = 'metadata-change';
      once('$strRootIdentity = Get-OwnedPathIdentity $strNodeRoot -Directory',
        '$strRootIdentity = (Get-Item -LiteralPath $strNodeRoot).CreationTimeUtc.Ticks');
      once(directoryCheck, '(Get-Item -LiteralPath $strNodeRoot).CreationTimeUtc.Ticks -ne $strRootIdentity');
    } else if (mutation === 'directory-and-marker-identity') {
      mode = 'directory-replace'; once(directoryCheck, '$false'); once(markerCheck, '$false');
    } else if (mutation === 'marker-identity') {
      mode = 'marker-replace'; once(markerCheck, '$false');
    } else {
      mode = 'marker-content'; once('[IO.File]::ReadAllText($strMarker) -cne $strOwnership', '$false');
    }
    const good = ordinaryDeclarationFixture(t, JSON.stringify(runtimePin('a'.repeat(64))), original, cleanupAction(mode));
    if (mode === 'metadata-change') assertOrdinaryFailureCleanup(good);
    else assertRetainedCleanup(good, mode);
    const bad = ordinaryDeclarationFixture(t, JSON.stringify(runtimePin('a'.repeat(64))), source, cleanupAction(mode));
    assert.deepEqual(bad.dispatches, ['dispatch']);
    assert.match(bad.result.stderr, /Runtime download failed: 99/u);
    if (mode === 'metadata-change') {
      assert.equal(fs.existsSync(path.join(bad.root, 'styleguide-node')), true);
      assert.match(bad.result.stdout, /Runtime cleanup could not prove completion/u);
      assert.throws(() => assertOrdinaryFailureCleanup(bad));
    } else {
      assertOrdinaryFailureCleanup(bad);
      assert.throws(() => assertRetainedCleanup(bad, mode));
    }
    assert.equal(fs.readFileSync(path.join(bad.root, 'outside/sentinel'), 'utf8'), 'outside must survive');
    assert.equal(read('Initialize-CiToolchain.ps1'), original);
  });
}

test('F6 missing Linux identity export stops before curl and retains uncertain staging', { skip: !linux }, t => {
  const original = read('Initialize-CiToolchain.ps1'), anchor = 'NativeLibrary.GetExport(module, "GetInodeData")';
  assert.equal(original.split(anchor).length, 2);
  const f = ordinaryDeclarationFixture(t, JSON.stringify(runtimePin('a'.repeat(64))),
    original.replace(anchor, 'NativeLibrary.GetExport(module, "F6MissingExport")'));
  assert.equal(f.result.error, undefined);
  assert.notEqual(f.result.status, 0);
  assert.deepEqual(f.dispatches, []);
  assert.match(f.result.stderr, /F6MissingExport/u);
  assert.equal(fs.existsSync(path.join(f.root, 'styleguide-node')), true);
  assert.equal(fs.existsSync(path.join(f.root, 'styleguide-node/.owner')), false);
  assert.equal(fs.readFileSync(path.join(f.root, 'path'), 'utf8'), '');
  assert.equal(fs.readFileSync(path.join(f.root, 'env'), 'utf8'), '');
});

test('F6 native object identity survives writes and distinguishes copied replacements', {
  skip: !linux && process.platform !== 'win32',
}, t => {
  const f = fixture(t), original = read('Initialize-CiToolchain.ps1');
  const start = original.indexOf('function Assert-OrdinaryPath {'), end = original.indexOf('function Assert-JsonMember {');
  assert.ok(start >= 0 && end > start);
  const source = original.slice(start, end);
  const result = f.run(source + `
$directory = Join-Path $env:RUNNER_TEMP 'identity-directory'
[IO.Directory]::CreateDirectory($directory) | Out-Null
$marker = Join-Path $directory '.owner'
[IO.File]::WriteAllText($marker, 'same contents')
$firstDirectory = Get-OwnedPathIdentity $directory -Directory
$firstMarker = Get-OwnedPathIdentity $marker
[IO.File]::WriteAllText((Join-Path $directory 'normal-work'), 'data')
$requestedLastWriteTimeUtc = ([datetime]'2001-01-01T00:00:00Z').ToUniversalTime()
if ([IO.Directory]::GetLastWriteTimeUtc($directory) -eq $requestedLastWriteTimeUtc) {
    throw 'F6 timestamp witness requires a different initial directory last-write UTC time'
}
[IO.Directory]::SetLastWriteTimeUtc($directory, $requestedLastWriteTimeUtc)
if ([IO.Directory]::GetLastWriteTimeUtc($directory) -ne $requestedLastWriteTimeUtc) {
    throw 'F6 directory last-write UTC time did not match the requested timestamp'
}
$afterWrite = Get-OwnedPathIdentity $directory -Directory
[IO.File]::Move($marker, (Join-Path $env:RUNNER_TEMP 'original-marker'))
[IO.File]::WriteAllText($marker, 'same contents')
$replacementMarker = Get-OwnedPathIdentity $marker
[IO.Directory]::Move($directory, (Join-Path $env:RUNNER_TEMP 'original-directory'))
[IO.Directory]::CreateDirectory($directory) | Out-Null
$replacementDirectory = Get-OwnedPathIdentity $directory -Directory
@{ firstDirectory = $firstDirectory; afterWrite = $afterWrite; replacementDirectory = $replacementDirectory
   firstMarker = $firstMarker; replacementMarker = $replacementMarker } | ConvertTo-Json -Compress
`);
  assert.equal(result.error, undefined);
  assert.equal(result.status, 0, result.stdout + result.stderr);
  const identities = JSON.parse(result.stdout);
  assert.equal(identities.firstDirectory, identities.afterWrite);
  assert.notEqual(identities.firstDirectory, identities.replacementDirectory);
  assert.notEqual(identities.firstMarker, identities.replacementMarker);
  const pattern = linux ? /^unix:[0-9]+:[0-9]+$/u : /^windows:[a-f0-9]{16}:[a-f0-9]{32}$/u;
  for (const identity of Object.values(identities)) assert.match(identity, pattern);
  if (linux) {
    const value = fs.lstatSync(path.join(f.root, 'original-directory'), { bigint: true });
    assert.equal(identities.firstDirectory, `unix:${value.dev}:${value.ino}`);
  }
  const marker = path.join(f.root, 'original-marker');
  const retainedBytes = fs.readFileSync(marker);
  const helperSources = ['Initialize-CiToolchain.ps1', 'Test-CheckoutCredentials.ps1', 'Invoke-MarkdownLint.ps1']
    .map(helper => ({ helper, source: read(helper) }));
  for (const { helper, source: helperSource } of helperSources) {
    const start = helperSource.indexOf('function Assert-OrdinaryPath {');
    const end = helperSource.indexOf('\nfunction ', start + 1);
    assert.ok(start >= 0 && end > start, helper);
    const ordinaryPath = helperSource.slice(start, end);
    const admitted = `\n$strAdmittedPath = Assert-OrdinaryPath -Path ${quote(marker)}\nWrite-Output "FQ7 admitted: $strAdmittedPath"\n`;
    const good = f.run(ordinaryPath + admitted);
    assert.equal(good.status, 0, `${helper}: ${good.stderr}`);
    assert.equal(good.stdout.trim(), `FQ7 admitted: ${path.resolve(marker)}`);
    const anchor = '    $objPathComparison = ';
    assert.equal(ordinaryPath.split(anchor).length, 2, `${helper}: exact FQ7 boundary anchor`);
    // Injected boundary controls corrupt one operand after real provider resolution.
    // They prove the refusal checks, not a genuine PSDrive redirection.
    for (const replacement of [
      "    $objPathProvider = Get-PSProvider -PSProvider Environment\n" + anchor,
      "    $strProviderPath += '.provider-mismatch'\n" + anchor,
    ]) {
      const bad = f.run(ordinaryPath.replace(anchor, replacement) + admitted);
      assert.notEqual(bad.status, 0, `${helper}: ${bad.stdout}${bad.stderr}`);
      assert.match(bad.stderr.replace(/\x1B\[[0-?]*[ -/]*[@-~]/gu, '')
        .replace(/^[ \t]*\|[ \t]?/gmu, '').replace(/\s+/gu, ' '),
        /the FileSystem provider path must match the normalized native path/u);
      assert.doesNotMatch(bad.stdout, /FQ7 admitted:/u);
      assert.deepEqual(fs.readFileSync(marker), retainedBytes);
    }
    if (process.platform === 'win32' && helper === 'Initialize-CiToolchain.ps1') {
      const redirected = f.run(ordinaryPath + `
$arrOccupiedDriveNames = @((Get-PSDrive).Name) + @([IO.DriveInfo]::GetDrives() | ForEach-Object { $_.Name.Substring(0, 1) })
$strUnusedDriveName = [string](90..68 | ForEach-Object { [char]$_ } | Where-Object { [string]$_ -inotin $arrOccupiedDriveNames } | Select-Object -First 1)
if ([string]::IsNullOrEmpty($strUnusedDriveName)) { throw 'FQ7 fixture: no unused temporary drive letter' }
$null = New-PSDrive -Name $strUnusedDriveName -Scope Local -PSProvider FileSystem -Root $env:RUNNER_TEMP
try {
    $strDrivePath = $strUnusedDriveName + ':\\original-marker'
    if (-not [IO.Path]::IsPathFullyQualified($strDrivePath)) { throw 'FQ7 fixture: temporary drive path is not fully qualified' }
    $strNativeDrivePath = [IO.Path]::GetFullPath($strDrivePath)
    [Management.Automation.ProviderInfo] $objResolvedProvider = $null
    [Management.Automation.PSDriveInfo] $objResolvedDrive = $null
    $strResolvedProviderPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
        $strDrivePath, [ref]$objResolvedProvider, [ref]$objResolvedDrive)
    if ($null -eq $objResolvedProvider -or $objResolvedProvider.Name -cne 'FileSystem' -or
        -not [string]::Equals($strResolvedProviderPath, ${quote(marker)}, [StringComparison]::OrdinalIgnoreCase) -or
        [string]::Equals($strResolvedProviderPath, $strNativeDrivePath, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'FQ7 fixture: temporary drive did not create the expected real provider mismatch'
    }
    Write-Output 'FQ7 temporary PSDrive differs'
    $null = Assert-OrdinaryPath -Path $strDrivePath
    Write-Output 'FQ7 admitted: unexpected temporary drive'
} finally { Remove-PSDrive -Name $strUnusedDriveName -Scope Local -Force }
`);
      assert.notEqual(redirected.status, 0, redirected.stdout + redirected.stderr);
      assert.match(redirected.stdout, /FQ7 temporary PSDrive differs/u);
      assert.match(redirected.stderr.replace(/\x1B\[[0-?]*[ -/]*[@-~]/gu, '')
        .replace(/^[ \t]*\|[ \t]?/gmu, '').replace(/\s+/gu, ' '),
        /the FileSystem provider path must match the normalized native path/u);
      assert.doesNotMatch(redirected.stdout, /FQ7 admitted:/u);
      assert.deepEqual(fs.readFileSync(marker), retainedBytes);
    }
    assert.equal(read(helper), helperSource, `${helper}: source must remain unchanged`);
  }
  const channels = ['path', 'env'].map(channel => path.join(f.root, channel));
  for (const channel of channels) {
    assert.equal(fs.existsSync(channel), false, 'The helper controls begin with unpublished channels.');
    fs.writeFileSync(channel, '', { flag: 'wx' });
  }
  for (const { helper, source: helperSource } of helperSources.filter(item => item.helper !== 'Invoke-MarkdownLint.ps1')) {
    const start = helperSource.indexOf('function Assert-OrdinaryPath {');
    const end = helper === 'Initialize-CiToolchain.ps1' ? helperSource.indexOf('function Assert-ArchiveName {', start)
      : helperSource.indexOf('\n# Do not load user/system Git', start);
    assert.ok(start >= 0 && end > start, helper);
    const privateHelpers = helperSource.slice(start, end);
    for (const whatIf of [true, false]) {
      const destination = path.join(f.root, `shouldprocess-${helper}-${whatIf ? 'whatif' : 'confirm'}`);
      assert.equal(fs.existsSync(destination), false);
      const permissionWitness = linux ? `
if ([int][IO.File]::GetUnixFileMode(${quote(destination)}) -ne 448) { throw 'FQ8 fixture: private mode must be 0700' }
` : `
$objAcl = Get-Acl -LiteralPath ${quote(destination)}
$strOwner = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
$arrExpectedSids = @($strOwner, 'S-1-5-18', 'S-1-5-32-544')
$arrRules = @($objAcl.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier]))
if (-not $objAcl.AreAccessRulesProtected -or $objAcl.GetOwner([Security.Principal.SecurityIdentifier]).Value -cne $strOwner -or $arrRules.Count -ne 3) {
    throw 'FQ8 fixture: private DACL protection, owner, or rule count differs'
}
foreach ($objRule in $arrRules) {
    if ($objRule.IdentityReference.Value -cnotin $arrExpectedSids -or $objRule.IsInherited -or
        $objRule.AccessControlType -ne [Security.AccessControl.AccessControlType]::Allow -or
        $objRule.FileSystemRights -ne [Security.AccessControl.FileSystemRights]::FullControl -or
        $objRule.InheritanceFlags -ne ([Security.AccessControl.InheritanceFlags]::ContainerInherit -bor [Security.AccessControl.InheritanceFlags]::ObjectInherit) -or
        $objRule.PropagationFlags -ne [Security.AccessControl.PropagationFlags]::None) {
        throw 'FQ8 fixture: private DACL rule differs'
    }
}
if (@($arrRules.IdentityReference.Value | Sort-Object -Unique).Count -ne 3) { throw 'FQ8 fixture: private DACL SID set differs' }
`;
      const controlled = f.run(privateHelpers + `
$WhatIfPreference=$${whatIf ? 'true' : 'false'}
$ConfirmPreference='Low'
New-PrivateDirectory -Path ${quote(destination)} -Confirm:$false -WhatIf:$WhatIfPreference
${whatIf ? '' : permissionWitness}
Write-Output 'FQ8 created directory'
`);
      if (whatIf) {
        assert.notEqual(controlled.status, 0, `${helper}: ${controlled.stdout}${controlled.stderr}`);
        assert.match(controlled.stderr, /Restricted staging directory creation was declined/u);
        assert.doesNotMatch(controlled.stdout, /FQ8 created directory/u);
        assert.equal(fs.existsSync(destination), false, 'Declined creation must not mutate the destination.');
      } else {
        assert.equal(controlled.status, 0, `${helper}: ${controlled.stdout}${controlled.stderr}`);
        assert.equal(controlled.stdout.trim(), 'FQ8 created directory', 'Creation completes without a confirmation prompt or helper success output.');
        assert.equal(fs.statSync(destination).isDirectory(), true);
        if (linux) assert.equal(fs.statSync(destination).mode & 0o777, 0o700);
      }
      assert.deepEqual(fs.readFileSync(marker), retainedBytes);
      assert.equal(fs.existsSync(path.join(f.root, 'styleguide-node')), false);
      for (const channel of channels) {
        assert.equal(fs.existsSync(channel), true, 'Control must retain the prepared channel.');
        assert.deepEqual(fs.readFileSync(channel), Buffer.alloc(0), 'Control must not publish channel bytes.');
      }
    }
    assert.equal(read(helper), helperSource, `${helper}: source must remain unchanged`);
  }
});

// Actual whole-helper curl control flow, served asynchronously so the fixture
// cannot block its own server. Only endpoint/protocol/time values are adapted.
for (const mode of ['transient', 'retry-after-number', 'retry-after-date', 'stall', 'partial-stall', 'exhaustion', 'partial-eof', 'wrong-digest']) {
  test(`ordinary actual curl transport: ${mode}`, { skip: !linux, timeout: 25000 }, async t => {
    const f = fixture(t), workflows = path.join(f.work, '.github/workflows'); fs.mkdirSync(workflows, { recursive: true });
    const payload = Buffer.from('fixture validated bytes');
    const requests = []; let count = 0;
    const server = createServer((req, res) => {
      requests.push({ url: req.url, header: req.headers['x-fixture-ambient'] });
      count++;
      if (req.url === '/ambient') { res.end('ambient must not be reached'); return; }
      if (mode === 'stall') return;
      if (mode === 'partial-stall') { res.writeHead(200, { 'Content-Length': 100 }); res.write('short'); return; }
      if (mode === 'partial-eof') { res.writeHead(200, { 'Content-Length': 100, Connection: 'close' }); res.end('short'); return; }
      if (mode === 'retry-after-number' || mode === 'retry-after-date') {
        res.writeHead(503, { 'Retry-After': mode.endsWith('number') ? '600' : new Date(Date.now() + 600000).toUTCString() }); res.end('retry denied'); return;
      }
      if (mode === 'exhaustion' || (mode === 'transient' && count === 1)) { res.writeHead(503); res.end('reset this error body'); return; }
      res.end(mode === 'wrong-digest' ? 'wrong bytes' : payload);
    });
    await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
    t.after(() => { server.closeAllConnections(); server.close(); });
    const endpoint = `http://127.0.0.1:${server.address().port}`;
    fs.writeFileSync(path.join(f.root, '.curlrc'), `header = "X-Fixture-Ambient: dummy-only"\nurl = "${endpoint}/ambient"\n`);
    fs.writeFileSync(path.join(f.work, 'package.json'), JSON.stringify({ engines: { node: '24.18.1', npm: '11.16.0' } }));
    fs.writeFileSync(path.join(workflows, 'ci-toolchain.json'), JSON.stringify(runtimePin(createHash('sha256').update(payload).digest('hex'))));
    fs.writeFileSync(path.join(workflows, 'Test-CheckoutCredentials.ps1'), read('Test-CheckoutCredentials.ps1')
      .replaceAll('/usr/bin/git', f.git).replaceAll("'/bin/git'", quote(f.git)));
    const curl = path.join(f.root, 'curl'), curlResult = path.join(f.root, 'curl-result.json');
    assert.throws(() => fs.lstatSync(curlResult), { code: 'ENOENT' }, 'The curl result witness must start absent.');
    fs.writeFileSync(curl, `#!${process.execPath}
const assert = require('node:assert/strict'), fs = require('node:fs'), { spawnSync } = require('node:child_process');
const args = process.argv.slice(2);
if(JSON.stringify(args)===JSON.stringify(['--disable','--version']) || JSON.stringify(args)===JSON.stringify(['--disable','--help','all'])) {
const query=spawnSync('/usr/bin/curl',args,{stdio:'inherit',timeout:15000});
if(query.error || query.signal || !Number.isInteger(query.status)) process.exit(98);
process.exit(query.status);
}
assert.equal(args[0], '--disable'); assert.equal(args.includes('--retry-all-errors'), false);
assert.equal(args.filter(value => value === '--max-filesize').length, 1);
for (const [flag, value] of [['--connect-timeout','20'],['--max-time','180'],['--retry','2'],['--retry-max-time','300'],['--proto','=https'],['--proto-redir','=https'],['--max-filesize','67108864']]) assert.equal(args[args.indexOf(flag)+1], value);
args[args.indexOf('--connect-timeout')+1]='1'; args[args.indexOf('--max-time')+1]='1';
args[args.indexOf('--proto')+1]='=http'; args[args.indexOf('--proto-redir')+1]='=http'; args[args.length-1]=${JSON.stringify(endpoint + '/archive')};
const result=spawnSync('/usr/bin/curl', args, {stdio:'inherit',timeout:16000});
const witness = { mode: ${JSON.stringify(mode)}, command: '/usr/bin/curl', status: result.status, signal: result.signal };
if (result.error) witness.error = { name: result.error.name, message: result.error.message, code: result.error.code, errno: result.error.errno, syscall: result.error.syscall, stack: result.error.stack };
fs.writeFileSync(${JSON.stringify(curlResult)}, JSON.stringify(witness), { flag: 'wx', mode: 0o600 });
if(result.error) { console.error('fixture curl watchdog/error'); process.exit(98); }
process.exit(result.status ?? 97);
`, { mode: 0o700 });
    const tar = path.join(f.root, 'tar');
    fs.writeFileSync(tar, `#!/bin/sh\nprintf listed > '${f.root}/tar-marker'\nexit 23\n`, { mode: 0o700 });
    const initializer = path.join(workflows, 'Initialize-CiToolchain.ps1');
    fs.writeFileSync(initializer, read('Initialize-CiToolchain.ps1').replaceAll('/usr/bin/curl', curl).replaceAll('/usr/bin/tar', tar));
    for (const channel of ['path', 'env']) fs.writeFileSync(path.join(f.root, channel), '');
    const env = { ...process.env, RUNNER_TEMP: f.root, GITHUB_PATH: path.join(f.root, 'path'), GITHUB_ENV: path.join(f.root, 'env'),
      CURL_HOME: f.root, TEST_LOG: f.log, TEST_MODE: '' };
    for (const key of ['GITHUB_TOKEN', 'GH_TOKEN', 'ACTIONS_RUNTIME_TOKEN', 'GIT_CONFIG_COUNT', 'GIT_CONFIG_PARAMETERS']) delete env[key];
    const started = performance.now();
    const result = await new Promise((resolve, reject) => {
      const child = spawn('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', initializer], { cwd: f.work, env, windowsHide: true });
      let stdout = '', stderr = '', expired = false;
      const watchdog = setTimeout(() => { expired = true; child.kill('SIGKILL'); }, 20000);
      child.stdout.on('data', bytes => stdout += bytes); child.stderr.on('data', bytes => stderr += bytes);
      child.on('error', reject);
      child.on('close', (status, signal) => { clearTimeout(watchdog); resolve({ status, signal, stdout, stderr, expired }); });
    });
    assert.equal(result.expired, false, 'A watchdog is failure, never a timing pass.');
    assert.equal(result.signal, null);
    readCurlResultWitness(curlResult, mode, `actual curl ${mode}: ${result.stderr}`);
    assert.notEqual(result.status, 0);
    assert.ok(performance.now() - started < 20000);
    assert.equal(requests.some(row => row.url === '/ambient' || row.header), false, JSON.stringify(requests));
    assert.equal(fs.existsSync(path.join(f.root, 'tar-marker')), mode === 'transient', result.stderr);
    if (mode.startsWith('retry-after')) assert.equal(requests.length, 1, 'Retry-After600 must exceed unscaled retry-admission300.');
    if (mode === 'transient') { assert.equal(requests.length, 2); assert.match(result.stderr, /archive listing failed: 23/); }
    if (mode === 'exhaustion') assert.equal(requests.length, 3);
    if (mode === 'partial-eof') assert.equal(requests.length, 1, 'Partial EOF must not become retry-all-errors.');
    if (mode === 'wrong-digest') assert.match(result.stderr, /archive digest is incorrect/);
    assert.equal(fs.readFileSync(env.GITHUB_PATH, 'utf8'), '');
    assert.equal(fs.readFileSync(env.GITHUB_ENV, 'utf8'), '');
  });
}

// Synthetic archives run through the real initializer, with only fixed curl
// dispatch replaced. No production URL, version or timeout override exists.
for (const mode of ['success', 'compatibility-version', 'compatibility-digest', 'preflight', 'install', 'lock-mutation', 'escape-link', 'wrong-root', 'unsafe-mode']) {
  test(`R5 Linux compatibility and archive boundary: ${mode}`, { skip: !linux }, t => {
    const f = fixture(t, 'space and Unicode Ω'), workflows = path.join(f.work, '.github/workflows'); fs.mkdirSync(workflows, { recursive: true });
    for (const folder of [f.work, workflows]) {
      fs.writeFileSync(path.join(folder, 'package.json'), JSON.stringify({ engines: { node: '24.18.1', npm: '11.16.0' } }));
      fs.writeFileSync(path.join(folder, 'package-lock.json'), '{}');
    }
    fs.writeFileSync(path.join(workflows, 'Test-CheckoutCredentials.ps1'), read('Test-CheckoutCredentials.ps1')
      .replaceAll('/usr/bin/git', f.git).replaceAll("'/bin/git'", quote(f.git)));
    const archives = {}, pin = runtimePin('a'.repeat(64));
    for (const [role, version, npm] of [['preferred', '24.18.1', '11.16.0'], ['recoveryCompatibility', '22.23.3', '10.9.9']]) {
      const parent = path.join(f.root, `archive-${role}`);
      const release = mode === 'wrong-root' && role === 'preferred' ? 'wrong-root' : `node-v${version}-linux-x64`;
      const runtime = path.join(parent, release), bin = path.join(runtime, 'bin'), cli = path.join(runtime, 'lib/node_modules/npm/bin');
      fs.mkdirSync(bin, { recursive: true }); fs.mkdirSync(cli, { recursive: true });
      fs.writeFileSync(path.join(cli, 'npm-cli.js'), 'fixture');
      fs.writeFileSync(path.join(cli, 'npx-cli.js'), 'fixture');
      fs.writeFileSync(path.join(cli, '../package.json'), JSON.stringify({ version: npm }));
      fs.writeFileSync(path.join(bin, 'node'), `#!${process.execPath}
const fs=require('node:fs'), args=process.argv.slice(2), npm=args[0]?.endsWith('npm-cli.js');
fs.appendFileSync(process.env.TEST_LOG, JSON.stringify([${JSON.stringify(role)}, ...args])+'\\n');
if(process.env.NODE_OPTIONS || process.env.NODE_PATH || process.env.NPM_CONFIG_SCRIPT_SHELL) process.exit(91);
if(npm && args.includes('ci') && ${JSON.stringify(role)}==='recoveryCompatibility') process.exit(92);
if(args.includes('--version')) console.log(npm ? ${JSON.stringify(npm)} : ${JSON.stringify(mode === 'compatibility-version' && role === 'recoveryCompatibility' ? 'v0.0.0' : 'v' + version)});
if(args.includes('--preflight') && process.env.TEST_MODE==='preflight') process.exit(31);
if(args.includes('ci') && process.env.TEST_MODE==='install') process.exit(32);
if(args.includes('ci') && process.env.TEST_MODE==='lock-mutation') fs.appendFileSync(${JSON.stringify(path.join(f.work, 'package-lock.json'))}, ' ');
`, { mode: mode === 'unsafe-mode' && role === 'preferred' ? 0o777 : 0o755 });
      if (mode === 'unsafe-mode' && role === 'preferred') {
        const executable = path.join(bin, 'node');
        assert.equal(fs.lstatSync(executable).isFile(), true);
        fs.chmodSync(executable, 0o777);
        assert.equal(fs.lstatSync(executable).mode & 0o777, 0o777);
      }
      fs.symlinkSync(mode === 'escape-link' && role === 'preferred' ? '../../../../outside-sentinel' : '../lib/node_modules/npm/bin/npm-cli.js', path.join(bin, 'npm'));
      const archive = path.join(f.root, `${role}.tar.xz`);
      const packed = spawnSync('/usr/bin/tar', ['-cJf', archive, '-C', parent, release], { encoding: 'utf8' });
      assert.equal(packed.status, 0, packed.stderr); archives[role] = archive;
      const digest = createHash('sha256').update(fs.readFileSync(archive)).digest('hex');
      if (role === 'preferred') pin.preferred.linuxX64Sha256 = digest;
      else pin.recoveryCompatibility.linuxX64Sha256 = mode === 'compatibility-digest' ? 'a'.repeat(64) : digest;
    }
    fs.writeFileSync(path.join(f.root, 'outside-sentinel'), 'unchanged');
    fs.writeFileSync(path.join(workflows, 'ci-toolchain.json'), JSON.stringify(pin));
    const curl = path.join(f.root, 'curl');
    fs.writeFileSync(curl, `#!${process.execPath}
const fs=require('node:fs'), args=process.argv.slice(2), archives=${JSON.stringify(archives)};
${fq40CurlQueryStub}
const role=args.at(-1).includes('/v22.23.3/')?'recoveryCompatibility':'preferred';
fs.appendFileSync(process.env.TEST_LOG,JSON.stringify(['curl',role,...args])+'\\n');
fs.copyFileSync(archives[role],args[args.indexOf('--output')+1]);
`, { mode: 0o700 });
    const initializer = path.join(workflows, 'Initialize-CiToolchain.ps1');
    fs.writeFileSync(initializer, read('Initialize-CiToolchain.ps1').replaceAll('/usr/bin/curl', curl));
    const gitProgram = `${f.git}.cjs`; fs.renameSync(f.git, gitProgram);
    fs.writeFileSync(f.git, `#!/bin/sh\nunset NODE_OPTIONS NODE_PATH\nexec '${process.execPath}' '${gitProgram}' "$@"\n`, { mode: 0o700 });
    const result = f.run(`& ${quote(initializer)} -WorkflowDependencies -InstructionDependencies -IncludeRecoveryCompatibility`, {
      TEST_MODE: mode, NODE_OPTIONS: '--require=/missing/preload', NODE_PATH: '/hostile', NPM_CONFIG_SCRIPT_SHELL: 'hostile',
      TAR_OPTIONS: '--fixture-must-not-be-read', XZ_DEFAULTS: '--fixture-must-not-be-read', XZ_OPT: '--fixture-must-not-be-read',
    });
    assert.equal(result.error, undefined);
    assert.equal(result.status === 0, mode === 'success', result.stderr);
    if (mode === 'unsafe-mode') assert.match(result.stderr, /dangerous archive member permissions/);
    assert.equal(fs.readFileSync(path.join(f.root, 'outside-sentinel'), 'utf8'), 'unchanged');
    const calls = f.calls();
    assert.equal(calls.some(row => row[0] === 'recoveryCompatibility' && row.includes('ci')), false);
    const environment = fs.readFileSync(path.join(f.root, 'env'), 'utf8'), publishedPath = fs.readFileSync(path.join(f.root, 'path'), 'utf8');
    if (mode === 'success') {
      const compatibility = environment.split('\n').find(line => line.startsWith('STYLEGUIDE_RECOVERY_NODE22='));
      assert.equal(compatibility, `STYLEGUIDE_RECOVERY_NODE22=${path.join(f.root, 'styleguide-node/recoveryCompatibility/node-v22.23.3-linux-x64/bin/node')}`);
      assert.equal(publishedPath, path.join(f.root, 'styleguide-node/preferred/node-v24.18.1-linux-x64/bin') + '\n');
      assert.equal(calls.filter(row => row[0] === 'preferred' && row.includes('ci')).length, 2);
    } else {
      assert.equal(environment, ''); assert.equal(publishedPath, '');
      if (!['install', 'lock-mutation'].includes(mode)) assert.equal(calls.some(row => row.includes('ci')), false);
    }
  });
}

// R3 selector controls execute copied current helpers. Only fixed Git/curl paths
// are replaced in the refusal fixtures; the real-Git positives use neither mock.
const r3GitSelectors = ['GIT_DIR', 'GIT_WORK_TREE', 'GIT_COMMON_DIR'];
const r3SelectorDiagnostic = 'credential-policy: repository selector environment variables are not allowed';
const fq45AskpassNames = ['GIT_ASKPASS', 'SSH_ASKPASS'];
const fq45AskpassDiagnostic = 'credential-policy: askpass environment variables are not allowed';
const fq45CoreDiagnostic = 'credential-policy: effective core.askPass is not allowed';
function r3CredentialFixture(t, nativeGit = false) {
  const f = fixture(t), scripts = path.join(f.work, '.github/workflows');
  fs.mkdirSync(scripts, { recursive: true });
  const script = path.join(scripts, 'Test-CheckoutCredentials.ps1');
  const mock = path.join(f.root, 'r3-git.ps1');
  fs.writeFileSync(mock, `
[IO.File]::AppendAllText($env:TEST_LOG, ((ConvertTo-Json -InputObject @($args) -Compress) + [Environment]::NewLine))
$global:LASTEXITCODE = 0
if ($args -contains '--version') { 'git version 2.55.0.windows.5'; return }
if ($IsWindows) {
    $objConfig = Get-Item -LiteralPath $env:GIT_CONFIG_GLOBAL -Force -ErrorAction Stop
    $strParent = [IO.Path]::GetDirectoryName($env:GIT_CONFIG_GLOBAL)
    if ($objConfig -isnot [IO.FileInfo] -or $objConfig.Length -ne 0 -or
        ($objConfig.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0 -or
        [IO.Path]::GetFileName($env:GIT_CONFIG_GLOBAL) -cne 'global.config' -or
        [IO.Path]::GetFileName($strParent) -cnotmatch '^styleguide-git-[a-f0-9]{32}$' -or
        -not [IO.Path]::GetDirectoryName($strParent).Equals($env:RUNNER_TEMP, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'R3 fixture requires the ordinary private empty config after version'
    }
}
if ($args -contains 'get-url') { 'https://github.com/franklesniak/PSStyleGuide' }
elseif ($args -contains '--get-all' -or $args -contains '--get-regexp') { $global:LASTEXITCODE = 1 }
elseif ($args -notcontains '--list') { throw 'R3 unexpected Git dispatch' }
`);
  let source = read('Test-CheckoutCredentials.ps1');
  if (!nativeGit) {
    const fixed = "Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFiles)) 'Git/cmd/git.exe'";
    for (const anchor of [fixed, "'/usr/bin/git'", "'/bin/git'"]) {
      assert.equal(source.split(anchor).length, 2, 'R3 fixed Git anchor must occur once');
      source = source.replace(anchor, quote(mock));
    }
  }
  fs.writeFileSync(script, source);
  function run(overrides = {}, target = script, cwd = f.work) {
    const env = { ...process.env, RUNNER_TEMP: f.root, TEST_LOG: f.log,
      GITHUB_PATH: path.join(f.root, 'path'), GITHUB_ENV: path.join(f.root, 'env') };
    const removed = [...r3GitSelectors, ...fq45AskpassNames, 'GITHUB_TOKEN', 'GH_TOKEN', 'ACTIONS_RUNTIME_TOKEN',
      'GIT_CONFIG_COUNT', 'GIT_CONFIG_PARAMETERS', 'GIT_CONFIG_GLOBAL'];
    const canonical = name => process.platform === 'win32' ? name.toUpperCase() : name;
    for (const key of Object.keys(env)) if (removed.includes(canonical(key))) delete env[key];
    Object.assign(env, overrides);
    const expected = new Map(Object.entries(overrides).map(([name, value]) => [canonical(name), value]));
    const checks = [...new Set([...r3GitSelectors, ...fq45AskpassNames, ...Object.keys(overrides)])].map(name => {
      const present = expected.has(canonical(name));
      return `$arrNames = @([Environment]::GetEnvironmentVariables().Keys | Where-Object {
    [string]::Equals([string]$_, ${quote(name)}, ${process.platform === 'win32' ? '[StringComparison]::OrdinalIgnoreCase' : '[StringComparison]::Ordinal'})
})
if ($arrNames.Count -ne ${present ? 1 : 0}) { throw 'R3 fixture selector presence mismatch' }
${present ? `if ([Environment]::GetEnvironmentVariable(${quote(name)}) -cne ${quote(expected.get(canonical(name)))}) { throw 'R3 fixture selector value mismatch' }` : ''}`;
    }).join('\n');
    const wrapper = path.join(f.root, 'r3-wrapper.ps1');
    fs.writeFileSync(wrapper, `$ErrorActionPreference = 'Stop'\n${checks}\n& ${quote(target)}\nWrite-Output 'R3 helper completed'\n`);
    const result = assertCompletedProcess(spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', wrapper], {
      cwd, env, encoding: 'utf8', timeout: 15000, maxBuffer: 256 * 1024, windowsHide: true,
    }), 'R3 credential selector child');
    assert.ok(Buffer.byteLength(result.stdout) + Buffer.byteLength(result.stderr) <= 256 * 1024, 'R3 combined output cap');
    return result;
  }
  return { ...f, scripts, script, source, run };
}
function assertR3EarlyCredentialRefusal(f, result, expectedDiagnostic) {
  assert.notEqual(result.status, 0, result.stdout + result.stderr);
  const diagnostic = stripVTControlCharacters(result.stderr).replace(/\r?\n[ \t]*\|[ \t]*/gu, ' ').replace(/\s+/gu, ' ');
  assert.ok(diagnostic.includes(expectedDiagnostic), diagnostic);
  assert.doesNotMatch(result.stdout, /R3 helper completed/u);
  assert.deepEqual(f.calls(), [], 'An inherited credential selector must refuse before even the Git version probe');
  assert.equal(fs.readdirSync(f.root).some(name => name.startsWith('styleguide-git-')), false);
  assert.equal(fs.existsSync(path.join(f.root, 'styleguide-node')), false);
}
function assertR3SelectorRefusal(f, result) {
  assertR3EarlyCredentialRefusal(f, result, r3SelectorDiagnostic);
}
function assertFq45AskpassRefusal(f, result) {
  assertR3EarlyCredentialRefusal(f, result, fq45AskpassDiagnostic);
}

test('R3 credential selectors: subsets and present value boundaries', { skip: !linux && process.platform !== 'win32' }, t => {
  const cases = [];
  for (let mask = 1; mask < 8; mask++) {
    cases.push(Object.fromEntries(r3GitSelectors.filter((_, index) => mask & (1 << index)).map(name => [name, 'r3-selector-private-value'])));
  }
  for (const name of r3GitSelectors) for (const value of ['', '   ', './relative-selector']) cases.push({ [name]: value });
  // A combined relative-dot selection is still a present-selector case.
  cases.push(Object.fromEntries(r3GitSelectors.map(name => [name, '.'])));
  assert.equal(cases.length, 17);
  for (const env of cases) {
    const f = r3CredentialFixture(t), result = f.run(env);
    assertR3SelectorRefusal(f, result);
    assert.equal((result.stdout + result.stderr).includes('r3-selector-private-value'), false);
  }
});

test('R3 credential selectors: native platform name casing', { skip: !linux && process.platform !== 'win32' }, t => {
  for (const name of r3GitSelectors) {
    const f = r3CredentialFixture(t), result = f.run({ [name.toLowerCase()]: 'r3-selector-private-value' });
    if (process.platform === 'win32') assertR3SelectorRefusal(f, result);
    else {
      assert.equal(result.status, 0, result.stdout + result.stderr);
      assert.match(result.stdout, /R3 helper completed/u);
      assert.equal(f.calls().length, 4, 'Linux lowercase names are unrelated to the uppercase Git selectors');
    }
  }
});

test('R3 credential selectors: each guard-name removal reaches Git', { skip: !linux && process.platform !== 'win32' }, t => {
  const anchor = "@('GIT_DIR', 'GIT_WORK_TREE', 'GIT_COMMON_DIR')";
  for (const name of r3GitSelectors) {
    const f = r3CredentialFixture(t);
    assert.equal(f.source.split(anchor).length, 2, 'The selected guard list must occur exactly once');
    const replacement = `@(${r3GitSelectors.filter(item => item !== name).map(quote).join(', ')})`;
    const mutant = f.source.replace(anchor, replacement);
    assert.equal(mutant.replace(replacement, anchor), f.source, 'The mutant changes only one guard name');
    fs.writeFileSync(f.script, mutant);
    const result = f.run({ [name]: 'r3-selector-private-value' });
    assert.equal(result.status, 0, result.stdout + result.stderr);
    assert.match(result.stdout, /R3 helper completed/u);
    assert.equal(f.calls().length, process.platform === 'win32' ? 5 : 4);
    assert.equal(f.calls().some(args => args.includes('--show-scope')), true);
  }
});

function r3NativeCredentialRepository(t) {
  const f = r3CredentialFixture(t, true), metadata = path.join(f.work, '.git');
  // Authored ordinary Git metadata: no commits, hooks, network or Git setup command.
  for (const entry of ['objects', 'refs/heads']) fs.mkdirSync(path.join(metadata, entry), { recursive: true });
  fs.writeFileSync(path.join(metadata, 'HEAD'), 'ref: refs/heads/fixture\n');
  const baseConfig = '[core]\nrepositoryformatversion = 0\nbare = false\n[remote "origin"]\nurl = https://github.com/franklesniak/PSStyleGuide\n';
  fs.writeFileSync(path.join(metadata, 'config'), baseConfig);
  const linked = path.join(f.root, 'linked'), admin = path.join(metadata, 'worktrees/linked');
  fs.mkdirSync(linked); fs.mkdirSync(admin, { recursive: true });
  fs.writeFileSync(path.join(admin, 'HEAD'), 'ref: refs/heads/fixture\n');
  fs.writeFileSync(path.join(admin, 'commondir'), '../..\n');
  fs.writeFileSync(path.join(admin, 'gitdir'), path.join(linked, '.git') + '\n');
  fs.writeFileSync(path.join(linked, '.git'), 'gitdir: ' + admin + '\n');
  return { ...f, metadata, linked, admin, baseConfig };
}

test('R3 credential selectors: absent ordinary and linked-worktree real Git positives', { skip: !linux && process.platform !== 'win32' }, t => {
  const f = r3NativeCredentialRepository(t), linked = f.linked;
  for (const cwd of [f.work, linked]) {
    const result = f.run({}, f.script, cwd);
    assert.equal(result.status, 0, result.stdout + result.stderr);
    assert.match(result.stdout, /R3 helper completed/u);
    assert.deepEqual(f.calls(), [], 'The real-Git positive must not use the Git mock');
  }
});

test('FQ45 credential askpass: subsets and present value boundaries', { skip: !linux && process.platform !== 'win32' }, t => {
  const cases = [1, 2, 3].map(mask => Object.fromEntries(fq45AskpassNames.filter((_, index) => mask & (1 << index))
    .map(name => [name, 'fq45-private-askpass-value'])));
  for (const name of fq45AskpassNames) for (const value of ['', '   ', './fq45-relative-askpass']) cases.push({ [name]: value });
  assert.equal(cases.length, 9);
  for (const env of cases) {
    const f = r3CredentialFixture(t), result = f.run(env);
    assertFq45AskpassRefusal(f, result);
    for (const value of ['fq45-private-askpass-value', './fq45-relative-askpass']) {
      assert.equal((result.stdout + result.stderr).includes(value), false, 'Askpass diagnostic must not reveal its value');
    }
  }
});

test('FQ45 credential askpass: native platform name casing', { skip: !linux && process.platform !== 'win32' }, t => {
  for (const name of fq45AskpassNames) {
    const mixed = name === 'GIT_ASKPASS' ? 'gIt_AsKpAsS' : 'sSh_AsKpAsS';
    const f = r3CredentialFixture(t), result = f.run({ [mixed]: 'fq45-private-askpass-value' });
    if (process.platform === 'win32') assertFq45AskpassRefusal(f, result);
    else {
      assert.equal(result.status, 0, result.stdout + result.stderr);
      assert.match(result.stdout, /R3 helper completed/u);
      assert.equal(f.calls().length, 4, 'Linux mixed-case names are unrelated to Git askpass environment names');
    }
    assert.equal((result.stdout + result.stderr).includes('fq45-private-askpass-value'), false);
  }
});

test('FQ45 credential askpass: each guard-name removal defeats the refusal oracle', { skip: !linux && process.platform !== 'win32' }, t => {
  const anchor = "@('GIT_ASKPASS', 'SSH_ASKPASS')";
  for (const name of fq45AskpassNames) {
    const f = r3CredentialFixture(t);
    assert.equal(f.source.split(anchor).length, 2, 'The askpass guard list must occur exactly once');
    const replacement = `@(${fq45AskpassNames.filter(item => item !== name).map(quote).join(', ')})`;
    const mutant = f.source.replace(anchor, replacement);
    assert.equal(mutant.replace(replacement, anchor), f.source, 'The mutant removes only one askpass guard name');
    fs.writeFileSync(f.script, mutant);
    const result = f.run({ [name]: 'fq45-private-askpass-value' });
    assert.equal(result.status, 0, result.stdout + result.stderr);
    assert.match(result.stdout, /R3 helper completed/u);
    assert.equal(f.calls().length, process.platform === 'win32' ? 5 : 4);
    assert.equal(f.calls().some(args => args.includes('--show-scope')), true);
    assert.throws(() => assertFq45AskpassRefusal(f, result), assert.AssertionError,
      'The actual-helper refusal oracle must reject each weakened guard');
  }
});

test('FQ45 credential askpass: effective real Git config and guard-removal control', { skip: !linux && process.platform !== 'win32' }, t => {
  const guard = String.raw`    if (@($arrEffectiveConfig | Where-Object {
        $_ -match '\A\S+[ \t]+core\.askpass\z'
    }).Count -ne 0) {
        throw 'credential-policy: effective core.askPass is not allowed'
    }
`;
  // Similar keys are permitted; the guard matches the effective key, not a prefix.
  const positive = r3NativeCredentialRepository(t);
  fs.writeFileSync(path.join(positive.metadata, 'config'), positive.baseConfig + '[core]\naskPassExtra = unused\n[other]\naskPass = unused\n');
  const positiveResult = positive.run();
  assert.equal(positiveResult.status, 0, positiveResult.stdout + positiveResult.stderr);
  assert.match(positiveResult.stdout, /R3 helper completed/u);
  assert.deepEqual(positive.calls(), [], 'The config positive must resolve qualified real Git');
  const cases = [];
  for (const scope of ['local', 'included', 'worktree']) for (const key of ['askPass', 'aSkPaSs']) {
    for (const value of ['', './fq45-private-unused-program']) cases.push({ scope, key, value });
  }
  assert.equal(cases.length, 12);
  for (const { scope, key, value } of cases) {
    const f = r3NativeCredentialRepository(t), local = path.join(f.metadata, 'config');
    const setting = `[core]\n${key} = ${value}\n`;
    let configured;
    if (scope === 'local') {
      configured = local; fs.writeFileSync(local, f.baseConfig + setting);
    } else if (scope === 'included') {
      configured = path.join(f.metadata, 'askpass.config'); fs.writeFileSync(configured, setting);
      fs.writeFileSync(local, f.baseConfig + '[include]\npath = askpass.config\n');
    } else {
      configured = path.join(f.admin, 'config.worktree'); fs.writeFileSync(configured, setting);
      fs.writeFileSync(local, f.baseConfig.replace('repositoryformatversion = 0', 'repositoryformatversion = 1')
        + '[extensions]\nworktreeConfig = true\n');
    }
    const cwd = scope === 'worktree' ? f.linked : f.work;
    const snapshots = new Map([local, configured].map(file => [file, fs.readFileSync(file)]));
    const assertRefusal = result => {
      assert.notEqual(result.status, 0, result.stdout + result.stderr);
      const diagnostic = stripVTControlCharacters(result.stderr).replace(/\r?\n[ \t]*\|[ \t]*/gu, ' ').replace(/\s+/gu, ' ');
      assert.ok(diagnostic.includes(fq45CoreDiagnostic), diagnostic);
      assert.doesNotMatch(result.stdout, /R3 helper completed/u);
      assert.equal((result.stdout + result.stderr).includes('fq45-private-unused-program'), false);
      assert.equal(fs.readdirSync(f.root).some(name => name.startsWith('styleguide-git-')), false,
        'The current helper must complete its strict failure cleanup');
      assert.deepEqual(f.calls(), [], 'The config rejection must use qualified real Git, not the mock');
      for (const [file, bytes] of snapshots) assert.deepEqual(fs.readFileSync(file), bytes, 'Helper must not mutate supplied config');
    };
    assertRefusal(f.run({}, f.script, cwd));
    assert.equal(f.source.split(guard).length, 2, 'The effective-key guard must occur exactly once');
    const mutant = f.source.replace(guard, '');
    assert.equal(mutant.replace('    $boolCredentialSuccess = $true', guard + '    $boolCredentialSuccess = $true'), f.source,
      'The config mutant removes only the effective-key refusal');
    const mutantPath = path.join(f.scripts, 'fq45-core-mutant.ps1'); fs.writeFileSync(mutantPath, mutant);
    const result = f.run({}, mutantPath, cwd);
    assert.equal(result.status, 0, result.stdout + result.stderr);
    assert.match(result.stdout, /R3 helper completed/u);
    assert.throws(() => assertRefusal(result), assert.AssertionError,
      'Removing the actual effective-key guard must false-pass the same negative case');
  }
});

for (const caller of ['Initialize-CiToolchain.ps1', 'Invoke-MarkdownLint.ps1']) {
  for (const family of ['R3 credential selectors', 'FQ45 credential askpass']) {
    test(`${family}: real helper refuses through ${caller}`, { skip: !linux && process.platform !== 'win32' }, t => {
      const cases = family === 'R3 credential selectors' ? [{ GIT_COMMON_DIR: 'r3-selector-private-value' }]
        : [1, 2, 3].map(mask => Object.fromEntries(fq45AskpassNames.filter((_, index) => mask & (1 << index))
          .map(name => [name, 'fq45-private-askpass-value'])));
      for (const env of cases) {
        const f = r3CredentialFixture(t), curlLog = path.join(f.root, 'curl-calls'), curl = path.join(f.root, 'r3-curl.ps1');
        let source = read(caller);
        const helperCall = '& "$PSScriptRoot/Test-CheckoutCredentials.ps1"';
        assert.equal(source.split(helperCall).length, 2, 'The real credential helper call must remain exactly once');
        fs.writeFileSync(path.join(f.work, 'package.json'), fs.readFileSync(path.join(directory, '../../package.json')));
        fs.writeFileSync(path.join(f.scripts, 'ci-toolchain.json'), read('ci-toolchain.json'));
        for (const name of ['path', 'env']) fs.writeFileSync(path.join(f.root, name), '');
        fs.writeFileSync(curl, `
    [IO.File]::AppendAllText(${quote(curlLog)}, ((ConvertTo-Json -InputObject @($args) -Compress) + [Environment]::NewLine))
    $global:LASTEXITCODE = 0
    if ($args -contains '--version') {
        'curl 8.5.0 fixture libcurl/8.5.0'; 'Protocols: https'; 'Features: SSL'; return
    }
    if ($args -contains '--help') {
        ${['disable', 'silent', 'show-error', 'fail', 'location', 'proto', 'proto-redir', 'tlsv1.2', 'connect-timeout', 'max-time', 'max-filesize', 'retry', 'retry-max-time', 'output'].map(name => quote('--' + name + ' fixture')).join('; ')}
        return
    }
    throw 'R3 unexpected acquisition dispatch'
    `);
        if (caller === 'Initialize-CiToolchain.ps1') {
          for (const anchor of ["$strCurlPath = Join-Path ([Environment]::SystemDirectory) 'curl.exe'", "$strCurlPath = '/usr/bin/curl'"]) {
            assert.equal(source.split(anchor).length, 2, 'R3 fixed curl anchor must occur once');
            source = source.replace(anchor, `$strCurlPath = ${quote(curl)}`);
          }
        }
        const target = path.join(f.scripts, caller); fs.writeFileSync(target, source);
        const result = f.run(env, target);
        if (family === 'R3 credential selectors') assertR3SelectorRefusal(f, result);
        else assertFq45AskpassRefusal(f, result);
        assert.equal((result.stdout + result.stderr).includes('fq45-private-askpass-value'), false);
        const curlCalls = fs.existsSync(curlLog) ? fs.readFileSync(curlLog, 'utf8').trim().split('\n').map(JSON.parse) : [];
        assert.deepEqual(curlCalls, caller === 'Initialize-CiToolchain.ps1' && process.platform === 'win32'
          ? [['--disable', '--version'], ['--disable', '--help', 'all']] : []);
        for (const name of ['path', 'env']) assert.equal(fs.readFileSync(path.join(f.root, name), 'utf8'), '');
      }
    });
  }
}

// Windows fixtures must run with TEMP/TMP under the qualified private runner
// root. An untrusted parent DACL is a real prerequisite failure, not a skip-pass.
for (const mode of ['clean', 'inherited-config', 'missing-config', 'outside-config', 'directory-config', 'nonempty-config', 'wrong-version', 'missing-fixed', 'origin', 'helper', 'header', 'global-scope', 'native-failure', 'token']) {
  test(`B1 Windows credential helper: ${mode}`, { skip: process.platform !== 'win32' }, t => {
    const root = fs.mkdtempSync(path.join(os.tmpdir(), 'styleguide-b1-'));
    t.after(() => fs.rmSync(root, { recursive: true, force: true }));
    const work = path.join(root, 'work'), scripts = path.join(work, '.github/workflows'); fs.mkdirSync(scripts, { recursive: true });
    const git = path.join(root, 'git.ps1'), log = path.join(root, 'calls');
    fs.writeFileSync(git, `
[IO.File]::AppendAllText($env:B1_LOG, ((@($args) | ConvertTo-Json -Compress) + "\n"))
$global:LASTEXITCODE = 0
if ($args -contains '--version') {
    if ($env:B1_MODE -eq 'wrong-version') { 'git version 1.0.0.windows.1' } else { 'git version 2.55.0.windows.5' }
    return
}
# The version probe precedes private configuration. Operational calls require it.
if ([string]::IsNullOrEmpty($env:GIT_CONFIG_GLOBAL)) { throw 'private config missing' }
[string]$strConfigParent = [IO.Path]::GetDirectoryName($env:GIT_CONFIG_GLOBAL)
if ([IO.Path]::GetFileName($env:GIT_CONFIG_GLOBAL) -cne 'global.config' -or
    [IO.Path]::GetFileName($strConfigParent) -cnotmatch '^styleguide-git-[a-f0-9]{32}$' -or
    -not [IO.Path]::GetDirectoryName($strConfigParent).Equals($env:RUNNER_TEMP, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'private config outside owned staging'
}
$objConfig = Get-Item -LiteralPath $env:GIT_CONFIG_GLOBAL -Force -ErrorAction Stop
if ($objConfig -isnot [IO.FileInfo] -or ($objConfig.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0 -or
    $objConfig.Length -ne 0 -or [IO.File]::ReadAllText($env:GIT_CONFIG_GLOBAL) -cne '') {
    throw 'private config must be an ordinary empty file'
}
if ($args -contains 'get-url') {
    if ($env:B1_MODE -eq 'origin') { 'https://github.com/other/repository' } else { 'https://github.com/franklesniak/PSStyleGuide' }
} elseif ($args -contains '--get-all' -or $args -contains '--get-regexp') {
    $global:LASTEXITCODE = 1
    if (($env:B1_MODE -eq 'helper' -and $args -contains '--get-all') -or ($env:B1_MODE -eq 'header' -and $args -contains '--get-regexp')) { $global:LASTEXITCODE = 0; 'fixture-key' }
} elseif ($args -contains '--list') {
    if ($env:B1_MODE -eq 'global-scope') { "global\tfixture" }
    if ($env:B1_MODE -eq 'native-failure') { $global:LASTEXITCODE = 27 }
}
`);
    const selected = mode === 'missing-fixed' ? path.join(root, 'absent.ps1') : git;
    let source = read('Test-CheckoutCredentials.ps1').replace(
      "Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFiles)) 'Git/cmd/git.exe'", quote(selected));
    // These mutations prove the mock rejects a copied helper that loses its private configuration.
    const mutationMarker = path.join(root, 'configuration-mutated');
    const configMutations = {
      'missing-config': ["$env:GIT_CONFIG_GLOBAL = $null", 'private config missing'],
      'outside-config': [`$env:GIT_CONFIG_GLOBAL = ${quote(path.join(root, 'outside.config'))}\n[IO.File]::WriteAllText($env:GIT_CONFIG_GLOBAL, '')`, 'private config outside owned staging'],
      'directory-config': ['[IO.File]::Delete($env:GIT_CONFIG_GLOBAL)\n[void][IO.Directory]::CreateDirectory($env:GIT_CONFIG_GLOBAL)', 'private config must be an ordinary empty file'],
      'nonempty-config': ["[IO.File]::WriteAllText($env:GIT_CONFIG_GLOBAL, 'fixture')", 'private config must be an ordinary empty file'],
    };
    if (Object.hasOwn(configMutations, mode)) {
      const ready = '        Assert-WindowsWriter $env:GIT_CONFIG_GLOBAL';
      assert.equal(source.split(ready).length, 2, 'The mutation must follow actual configuration admission exactly once.');
      source = source.replace(ready, `${ready}\n${configMutations[mode][0]}\n[IO.File]::WriteAllText(${quote(mutationMarker)}, 'mutated')`);
    }
    const script = path.join(scripts, 'Test-CheckoutCredentials.ps1'); fs.writeFileSync(script, source);
    const env = { ...process.env, RUNNER_TEMP: root, B1_LOG: log, B1_MODE: mode };
    for (const key of Object.keys(env)) {
      if (['GITHUB_TOKEN', 'GH_TOKEN', 'ACTIONS_RUNTIME_TOKEN', 'GIT_CONFIG_COUNT', 'GIT_CONFIG_PARAMETERS', 'GIT_CONFIG_GLOBAL'].includes(key.toUpperCase())) delete env[key];
    }
    const inheritedConfig = path.join(root, 'inherited.config');
    const inheritedContents = '[fixture]\n    unexpected = inherited\n';
    if (mode === 'inherited-config') {
      fs.writeFileSync(inheritedConfig, inheritedContents);
      env.GIT_CONFIG_GLOBAL = inheritedConfig;
    }
    if (mode === 'token') env.GH_TOKEN = 'fixture-secret';
    const success = mode === 'clean' || mode === 'inherited-config';
    const result = spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', script], {
      cwd: work, env, encoding: 'utf8', timeout: 30000, windowsHide: true,
    });
    assertCompletedProcess(result, `Windows credential helper ${mode}`);
    assert.equal(result.error, undefined);
    assert.equal(result.status === 0, success, result.stderr);
    assert.equal((result.stdout + result.stderr).includes('fixture-secret'), false);
    const calls = fs.existsSync(log) ? fs.readFileSync(log, 'utf8').trim().split('\n').map(JSON.parse) : [];
    const expectedCalls = { clean: 5, 'inherited-config': 5,
      'missing-config': 2, 'outside-config': 2, 'directory-config': 2, 'nonempty-config': 2,
      'wrong-version': 1, 'missing-fixed': 0,
      origin: 2, helper: 3, header: 4, 'global-scope': 5, 'native-failure': 5, token: 0 };
    assert.equal(calls.length, expectedCalls[mode], `Git call sequence stopped at the wrong phase: ${mode}`);
    if (Object.hasOwn(configMutations, mode)) {
      assert.equal(fs.readFileSync(mutationMarker, 'utf8'), 'mutated');
      assert.ok(result.stderr.includes(configMutations[mode][1]), result.stderr);
    }
    if (success) {
      assert.ok(calls.some(args => args.includes('--show-scope')));
      const configs = fs.readdirSync(root).filter(name => name.startsWith('styleguide-git-'));
      assert.equal(configs.length, 1);
      const config = fs.readFileSync(path.join(root, configs[0], 'global.config'));
      assert.equal(config.length, 0); assert.equal(config.toString('utf8'), '');
      const wrapper = path.join(root, 'preference-control.ps1');
      const expectedInformation = `Git git version 2.55.0.windows.5 at ${git} SHA256 ${createHash('sha256').update(fs.readFileSync(git)).digest('hex').toUpperCase()}.\n`;
      for (const whatIf of [true, false]) {
        const informationFile = path.join(root, `preference-information-${whatIf ? 'whatif' : 'confirm'}.log`);
        assert.equal(fs.existsSync(informationFile), false);
        fs.writeFileSync(wrapper, `$ErrorActionPreference='Stop'\n$WhatIfPreference=$false\n$ConfirmPreference='None'\n& {\n    $WhatIfPreference=$${whatIf ? 'true' : 'false'}\n    $ConfirmPreference='Low'\n    & ${quote(script)}\n} 6> ${quote(informationFile)}\nWrite-Output 'FQ8 credential completed'\n`);
        const controlled = assertCompletedProcess(spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', wrapper], {
          cwd: work, env, encoding: 'utf8', timeout: 30000, windowsHide: true,
        }), `Windows credential preference ${whatIf ? 'WhatIf' : 'low confirmation'}`);
        assert.equal(fs.readFileSync(informationFile, 'utf8').replaceAll('\r\n', '\n'), expectedInformation,
          'Both preference controls must retain the exact Git version, executable path, and SHA256 information.');
        const currentConfigs = fs.readdirSync(root).filter(name => name.startsWith('styleguide-git-'));
        if (whatIf) {
          assert.notEqual(controlled.status, 0, controlled.stdout + controlled.stderr);
          assert.match(controlled.stderr, /Restricted staging directory creation was declined/u);
          assert.doesNotMatch(controlled.stdout, /FQ8 credential completed/u);
          assert.deepEqual(currentConfigs, configs, 'Inherited WhatIf must not create credential staging or publish a config.');
        } else {
          assert.equal(controlled.status, 0, controlled.stdout + controlled.stderr);
          assert.equal(controlled.stdout.trim(), 'FQ8 credential completed', 'Low confirmation completes without prompting.');
          assert.equal(currentConfigs.length, configs.length + 1);
        }
        for (const name of currentConfigs) assert.equal(fs.readFileSync(path.join(root, name, 'global.config')).length, 0);
      }
    }
    if (mode === 'inherited-config') assert.equal(fs.readFileSync(inheritedConfig, 'utf8'), inheritedContents);
  });
}

test('R5 refuses the compatibility switch on actual Windows before external work', { skip: process.platform !== 'win32' }, t => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'styleguide-r5-platform-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const script = path.join(root, 'Initialize-CiToolchain.ps1'); fs.writeFileSync(script, read('Initialize-CiToolchain.ps1'));
  const result = spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', script, '-IncludeRecoveryCompatibility'], {
    cwd: root, encoding: 'utf8', timeout: 30000, windowsHide: true,
  });
  assertCompletedProcess(result, 'Windows compatibility refusal');
  assert.equal(result.error, undefined); assert.notEqual(result.status, 0);
  assert.match(result.stderr, /supported only on Linux x64/);
  assert.deepEqual(fs.readdirSync(root), ['Initialize-CiToolchain.ps1']);
});

for (const mode of ['safe', 'traversal', 'ads', 'device', 'case-collision', 'file-directory', 'link', 'entry-cap', 'byte-cap']) {
  test(`R5 actual Windows ZIP member boundary: ${mode}`, { skip: process.platform !== 'win32' }, t => {
    const root = fs.mkdtempSync(path.join(os.tmpdir(), 'styleguide-r5-zip-'));
    t.after(() => fs.rmSync(root, { recursive: true, force: true }));
    const source = read('Initialize-CiToolchain.ps1');
    const start = source.indexOf('function Assert-OrdinaryPath'), end = source.indexOf('if ((-not $IsLinux -and -not $IsWindows)');
    assert.ok(start > 0 && end > start);
    let functions = source.slice(start, end);
    // Keep production bounds explicit, then scale only fixture data thresholds.
    assert.ok(functions.includes('$objArchiveMembers.Count -gt 50000 -or $intExpandedBytes -gt 1073741824'));
    functions = functions.replaceAll('$objArchiveMembers.Count -gt 50000 -or $intExpandedBytes -gt 1073741824', '$objArchiveMembers.Count -gt 16 -or $intExpandedBytes -gt 1024');
    const release = 'node-v24.18.1-win-x64';
    const names = mode === 'traversal' ? [`${release}/../outside`] : mode === 'ads' ? [`${release}/name:stream`]
      : mode === 'device' ? [`${release}/NUL.txt`] : mode === 'case-collision' ? [`${release}/Name`, `${release}/name`]
      : mode === 'file-directory' ? [`${release}/item`, `${release}/item/child`]
      : mode === 'entry-cap' ? Array.from({ length: 17 }, (_, i) => `${release}/${i}`) : [`${release}/safe`];
    names.unshift(`${release}/`);
    const script = path.join(root, 'zip.ps1');
    fs.writeFileSync(script, `$ErrorActionPreference = 'Stop'\nSet-StrictMode -Version Latest\n${functions}
$zipPath = ${quote(path.join(root, 'fixture.zip'))}
$zip = [IO.Compression.ZipFile]::Open($zipPath, [IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($name in @(${names.map(quote).join(',')})) {
        $entry = $zip.CreateEntry($name)
        ${mode === 'link' ? '$entry.ExternalAttributes = [int]0xA0000000' : ''}
        if ($name.EndsWith('/')) { continue }
        $writer = [IO.StreamWriter]::new($entry.Open())
        try { $writer.Write(('x' * ${mode === 'byte-cap' ? 2048 : 1})) } finally { $writer.Dispose() }
    }
} finally { $zip.Dispose() }
$destination = ${quote(path.join(root, 'extract'))}
[void][IO.Directory]::CreateDirectory($destination)
Expand-ReviewedArchive $zipPath $destination '${release}'
`);
    fs.writeFileSync(path.join(root, 'outside'), 'sentinel');
    const result = spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', script], {
      cwd: root, encoding: 'utf8', timeout: 30000, windowsHide: true,
    });
    assertCompletedProcess(result, `Windows ZIP boundary ${mode}`);
    assert.equal(result.error, undefined);
    assert.equal(result.status === 0, mode === 'safe', result.stderr);
    assert.equal(fs.readFileSync(path.join(root, 'outside'), 'utf8'), 'sentinel');
    if (mode === 'safe') assert.equal(fs.readFileSync(path.join(root, 'extract', release, 'safe'), 'utf8'), 'x');
    else assert.deepEqual(fs.readdirSync(path.join(root, 'extract')), [], 'Refuse the complete member list before extraction.');
  });
}


// These F3 tests use in-memory security descriptors; they never change host ACLs.
// Whole callers retain real ancestry checks and require the qualified Windows root.
const aclOverlay = (target, rights, trusted = false, inheritOnly = false, { inherited = false, trustedSid = null } = {}) => {
  const inheritedMask = { AppendData: '0x00000004', ReadData: '0x00000001' }[rights];
  const trustedSids = ['S-1-5-18', 'S-1-5-32-544', 'S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464'];
  if (inherited) assert.ok(inheritedMask && !trusted && !inheritOnly && trustedSid === null);
  if (trustedSid !== null) assert.ok(trustedSids.includes(trustedSid) && rights === 'AppendData' && !trusted && !inheritOnly && !inherited);
  return `
function Get-Acl {
    param([string] $LiteralPath)
    if ($LiteralPath -cne ${quote(target)}) { return Microsoft.PowerShell.Security\\Get-Acl -LiteralPath $LiteralPath }
    $acl = if ((Get-Item -LiteralPath $LiteralPath).PSIsContainer) {
        [Security.AccessControl.DirectorySecurity]::new()
    } else { [Security.AccessControl.FileSecurity]::new() }
    $owner = [Security.Principal.WindowsIdentity]::GetCurrent().User
    $acl.SetOwner($owner)
    ${inherited ? `
    if ((Get-Item -LiteralPath $LiteralPath).PSIsContainer) { throw 'fixture: inherited control requires a file' }
    $acl.SetSecurityDescriptorSddlForm('D:(A;ID;${inheritedMask};;;WD)', [Security.AccessControl.AccessControlSections]::Access)
    $rules = @($acl.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier]))
    $explicit = @($acl.GetAccessRules($true, $false, [Security.Principal.SecurityIdentifier]))
    $inheritedRules = @($acl.GetAccessRules($false, $true, [Security.Principal.SecurityIdentifier]))
    if ($rules.Count -ne 1 -or $explicit.Count -ne 0 -or $inheritedRules.Count -ne 1) {
        throw 'fixture: inherited ACE enumeration is invalid'
    }
    $rule = $rules[0]
    if (-not $rule.IsInherited -or $rule.IdentityReference.Value -cne 'S-1-1-0' -or
        $rule.AccessControlType -ne 'Allow' -or [int]$rule.FileSystemRights -ne ${inheritedMask} -or
        $rule.InheritanceFlags -ne 'None' -or $rule.PropagationFlags -ne 'None' -or
        $acl.GetOwner([Security.Principal.SecurityIdentifier]).Value -cne $owner.Value) {
        throw 'fixture: inherited ACE shape is invalid'
    }
    ` : `
    $sid = ${trustedSid !== null ? `[Security.Principal.SecurityIdentifier]::new(${quote(trustedSid)})` : trusted ? '$owner' : "[Security.Principal.SecurityIdentifier]::new('S-1-1-0')"}
    $rule = [Security.AccessControl.FileSystemAccessRule]::new($sid, '${rights}',
        '${inheritOnly ? 'ObjectInherit' : 'None'}', '${inheritOnly ? 'InheritOnly' : 'None'}', 'Allow')
    $acl.AddAccessRule($rule)
    ${trustedSid === null ? '' : `
    if ((Get-Item -LiteralPath $LiteralPath).PSIsContainer -or $owner.Value -ceq $sid.Value) {
        throw 'fixture: trusted SID control requires a file and distinct current-user owner'
    }
    $rules = @($acl.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier]))
    if ($rules.Count -ne 1) { throw 'fixture: trusted SID control requires one rule' }
    $rule = $rules[0]
    $append = [Security.AccessControl.FileSystemRights]::AppendData
    $allowed = $append -bor [Security.AccessControl.FileSystemRights]::Synchronize
    if ($rule.IsInherited -or $rule.IdentityReference.Value -cne $sid.Value -or
        $rule.AccessControlType -ne 'Allow' -or -not ($rule.FileSystemRights -band $append) -or
        ([int]$rule.FileSystemRights -band (-bnot [int]$allowed)) -ne 0 -or
        $rule.InheritanceFlags -ne 'None' -or $rule.PropagationFlags -ne 'None' -or
        $acl.GetOwner([Security.Principal.SecurityIdentifier]).Value -cne $owner.Value) {
        throw 'fixture: trusted SID append shape is invalid'
    }
    `}
    `}
    return $acl
}
`;
};

for (const helper of ['Initialize-CiToolchain.ps1', 'Test-CheckoutCredentials.ps1']) {
  test(`F3 ${helper}: file/directory writer properties`, { skip: process.platform !== 'win32' }, t => {
    const root = fs.mkdtempSync(path.join(os.tmpdir(), 'styleguide-writer-properties-'));
    t.after(() => fs.rmSync(root, { recursive: true, force: true }));
    const source = read(helper);
    const start = source.indexOf('function Assert-WindowsWriter {'), end = source.indexOf('function New-PrivateDirectory {', start);
    assert.ok(start > 0 && end > start);
    const file = path.join(root, 'file'); fs.writeFileSync(file, 'unchanged');
    const cases = [
      { name: 'untrusted append', target: file, rights: 'AppendData', pass: false },
      { name: 'untrusted write', target: file, rights: 'WriteData', pass: false },
      { name: 'untrusted read', target: file, rights: 'ReadData', pass: true },
      { name: 'trusted append', target: file, rights: 'AppendData', trusted: true, pass: true },
      { name: 'directory create directories', target: root, rights: 'CreateDirectories', pass: true },
      { name: 'directory create files', target: root, rights: 'CreateFiles', pass: false },
      { name: 'inherit only', target: root, rights: 'WriteData', inheritOnly: true, pass: true },
      { name: 'inherited untrusted append', target: file, rights: 'AppendData', inherited: true, pass: false },
      { name: 'SYSTEM append', target: file, rights: 'AppendData', trustedSid: 'S-1-5-18', pass: true },
      { name: 'Administrators append', target: file, rights: 'AppendData', trustedSid: 'S-1-5-32-544', pass: true },
      { name: 'TrustedInstaller append', target: file, rights: 'AppendData', trustedSid: 'S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464', pass: true },
    ];
    for (const item of cases) {
      const script = path.join(root, 'property.ps1');
      fs.writeFileSync(script, `$ErrorActionPreference = 'Stop'\n${aclOverlay(item.target, item.rights, item.trusted, item.inheritOnly, item)}\n` +
        `${item.inherited || item.trustedSid ? `[void](Get-Acl -LiteralPath ${quote(item.target)})\n` : ''}` +
        source.slice(start, end) + `\nAssert-WindowsWriter ${quote(item.target)}\n`);
      const result = spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', script], {
        encoding: 'utf8', timeout: 15000, windowsHide: true,
      });
      assertCompletedProcess(result, `${helper}: writer property ${item.name}`);
      assert.equal(result.error, undefined, item.name);
      assert.equal(result.status === 0, item.pass, `${item.name}: ${result.stderr}`);
      if (!item.pass) assert.match(result.stderr, /unreviewed Windows write authority/u);
      assert.equal(fs.readFileSync(file, 'utf8'), 'unchanged');
    }
  });
}

for (const inherited of [false, true]) for (const channel of ['GITHUB_ENV', 'GITHUB_PATH', 'credential-tool']) for (const rights of ['AppendData', 'ReadData']) {
  test(`F3 whole caller rejects append before dispatch: ${inherited ? 'inherited ' : ''}${channel}/${rights}`, { skip: process.platform !== 'win32' }, t => {
    const root = fs.mkdtempSync(path.join(os.tmpdir(), 'styleguide-writer-caller-'));
    t.after(() => fs.rmSync(root, { recursive: true, force: true }));
    const work = path.join(root, 'work'), scripts = path.join(work, '.github/workflows'); fs.mkdirSync(scripts, { recursive: true });
    const tool = path.join(root, 'fixed-tool.ps1'), marker = path.join(root, 'tool-marker');
    const toolSource = `[IO.File]::WriteAllText(${quote(marker)}, 'reached')\nthrow 'fixture dispatch reached'\n`;
    fs.writeFileSync(tool, toolSource);
    const env = { ...process.env, RUNNER_TEMP: root, GITHUB_ENV: path.join(root, 'env'), GITHUB_PATH: path.join(root, 'path') };
    for (const name of ['GITHUB_TOKEN', 'GH_TOKEN', 'ACTIONS_RUNTIME_TOKEN', 'GIT_CONFIG_COUNT', 'GIT_CONFIG_PARAMETERS']) delete env[name];
    for (const name of ['GITHUB_ENV', 'GITHUB_PATH']) fs.writeFileSync(env[name], '');
    const helper = channel === 'credential-tool' ? 'Test-CheckoutCredentials.ps1' : 'Initialize-CiToolchain.ps1';
    const source = read(helper).replace("Join-Path ([Environment]::SystemDirectory) 'curl.exe'", quote(tool))
      .replace("Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFiles)) 'Git/cmd/git.exe'", quote(tool));
    fs.writeFileSync(path.join(scripts, helper), source);
    fs.writeFileSync(path.join(scripts, 'ci-toolchain.json'), read('ci-toolchain.json'));
    fs.writeFileSync(path.join(work, 'package.json'), JSON.stringify({ engines: { node: '24.18.1', npm: '11.16.0' } }));
    const target = channel === 'credential-tool' ? tool : env[channel];
    const wrapper = path.join(root, 'caller.ps1');
    fs.writeFileSync(wrapper, `$ErrorActionPreference = 'Stop'\n${aclOverlay(target, rights, false, false, { inherited })}\n` +
      `${inherited ? `[void](Get-Acl -LiteralPath ${quote(target)})\n` : ''}` + `& ${quote(path.join(scripts, helper))}\n`);
    const result = spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', wrapper], {
      cwd: work, env, encoding: 'utf8', timeout: 15000, windowsHide: true,
    });
    assertCompletedProcess(result, `Windows whole caller ${inherited ? 'inherited ' : ''}${channel}/${rights}`);
    assert.equal(result.error, undefined); assert.notEqual(result.status, 0);
    assert.equal(fs.existsSync(marker), rights === 'ReadData', result.stderr);
    assert.match(result.stderr, rights === 'AppendData' ? /unreviewed Windows write authority/u : /fixture dispatch reached/u);
    assert.equal(fs.readFileSync(env.GITHUB_ENV, 'utf8'), '');
    assert.equal(fs.readFileSync(env.GITHUB_PATH, 'utf8'), '');
    assert.equal(fs.readFileSync(tool, 'utf8'), toolSource);
    assert.equal(fs.existsSync(path.join(root, 'styleguide-node')), false);
  });
}

test('F4 compatibility documentation matches actual parameter ownership', () => {
  const rows = read('scripts-README.md').split('\n').filter(line => line.startsWith('| `'));
  const owners = rows.filter(line => line.includes('IncludeRecoveryCompatibility'));
  assert.equal(owners.length, 1);
  assert.ok(owners[0].startsWith('| `Initialize-CiToolchain.ps1`'));
  assert.match(read('Initialize-CiToolchain.ps1'), /param\([\s\S]*?\[switch\] \$IncludeRecoveryCompatibility[\s\S]*?\n\)/u);
  assert.match(read('Test-StyleGuideArtifacts.ps1'), /\nparam\(\)/u);
  assert.equal(rows.find(line => line.startsWith('| `Test-StyleGuideArtifacts.ps1`')).includes('IncludeRecoveryCompatibility'), false);
});

// F10-F14 close the selected R5/R5E/A04 foundation controls. All source changes
// below are disposable fixture adaptations or one-guard mutation witnesses.
function foundationOnce(source, anchor, replacement) {
  assert.equal(source.split(anchor).length, 2, `One exact fixture anchor is required: ${anchor}`);
  return source.replace(anchor, replacement);
}

// A finite USTAR producer avoids creating a device/FIFO in the fixture namespace.
// GNU tar/xz and the actual initializer remain the archive consumers.
function foundationTar(entries) {
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

function foundationFixture(t, { source = read('Initialize-CiToolchain.ps1'), mode = '', compatibility = false,
  installs = false, dependencySwitches = installs ? ['WorkflowDependencies', 'InstructionDependencies'] : [],
  pinChange = pin => pin, extraEnv = {} } = {}) {
  const f = fixture(t, 'repository space and Unicode Ω'), scripts = path.join(f.work, '.github/workflows');
  fs.mkdirSync(scripts, { recursive: true });
  const runner = path.join(f.root, 'runner space and Unicode Ω'); fs.mkdirSync(runner, { mode: 0o700 });
  const sentinel = path.join(runner, 'outside-sentinel'); fs.writeFileSync(sentinel, 'unchanged');
  for (const folder of [f.work, scripts]) {
    fs.writeFileSync(path.join(folder, 'package.json'), JSON.stringify({ engines: { node: '24.18.1', npm: '11.16.0' } }));
    fs.writeFileSync(path.join(folder, 'package-lock.json'), '{}');
  }
  fs.writeFileSync(path.join(scripts, 'Test-CheckoutCredentials.ps1'), read('Test-CheckoutCredentials.ps1')
    .replaceAll('/usr/bin/git', f.git).replaceAll("'/bin/git'", quote(f.git)));
  const archives = {}, pin = runtimePin('a'.repeat(64));
  for (const [role, version, npm] of [['preferred', '24.18.1', '11.16.0'],
    ...(compatibility ? [['recoveryCompatibility', '22.23.3', '10.9.9']] : [])]) {
    const release = `node-v${version}-linux-x64`, archive = path.join(f.root, `${role}.tar.xz`);
    const node = `#!${process.execPath}
const fs=require('node:fs'), {spawnSync}=require('node:child_process'), args=process.argv.slice(2), role=${JSON.stringify(role)};
fs.appendFileSync(process.env.TEST_LOG,JSON.stringify([role,...args])+'\\n');
if(args.includes('--version') && process.env.TEST_MODE==='interrupted-child') {
const child=spawnSync('/bin/sh',['-c','kill -TERM $$'],{encoding:'utf8',timeout:2000});
const record={status:child.status,signal:child.signal}; if(child.error) record.error={code:child.error.code,message:child.error.message};
fs.writeFileSync(${JSON.stringify(path.join(f.root, 'interrupted-child.json'))},JSON.stringify(record),{flag:'wx'}); process.exit(143);
}
if(args.includes('--version')) console.log(args[0]?.endsWith('npm-cli.js')?${JSON.stringify(npm)}:${JSON.stringify('v' + version)});
if(process.env.TEST_MODE?.startsWith('fq36-') && (args.includes('--preflight') || args.includes('ci'))) {
console.log(args.includes('--preflight')?'FQ36 preflight record':'FQ36 install record');
console.error(args.includes('--preflight')?'FQ36 preflight stderr':'FQ36 install stderr');
if(process.env.TEST_MODE==='fq36-preflight-failure' && args.includes('--preflight')) process.exit(31);
if(process.env.TEST_MODE==='fq36-install-failure' && args.includes('ci')) process.exit(37);
}
if(args.includes('--preflight') && process.env.TEST_MODE==='preflight') process.exit(31);
if(args.includes('ci') && role==='recoveryCompatibility') process.exit(92);
`;
    const folders = ['', '/bin', '/lib', '/lib/node_modules', '/lib/node_modules/npm', '/lib/node_modules/npm/bin'];
    const entries = folders.map(suffix => ({ name: release + suffix + '/', type: '5' }));
    for (const [name, data, permissions] of [['bin/node', node, 0o755], ['lib/node_modules/npm/bin/npm-cli.js', 'fixture', 0o644],
      ['lib/node_modules/npm/bin/npx-cli.js', 'fixture', 0o644], ['lib/node_modules/npm/package.json', JSON.stringify({ version: npm }), 0o644]]) {
      entries.push({ name: `${release}/${name}`, data: Buffer.from(data), mode: permissions });
    }
    if (mode === 'device') entries.push({ name: `${release}/device`, type: '3' });
    if (mode === 'entry-cap') for (let i = 0; i < 7; i++) entries.push({ name: `${release}/extra${i}`, data: Buffer.from('x') });
    if (mode === 'byte-cap') entries.push({ name: `${release}/expansion`, data: Buffer.alloc(2048, 120), mode: 0o644 });
    if (mode === 'escape-admission') entries.push({ name: `${release}/bin/npm`, type: '2', target: '../../../../outside-sentinel' });
    const packed = assertCompletedProcess(spawnSync('/usr/bin/xz', ['-c', '-T1'],
      { input: foundationTar(entries), timeout: 15000, maxBuffer: 1048576 }), 'F10-F14 finite xz producer');
    assert.equal(packed.status, 0, packed.stderr?.toString()); fs.writeFileSync(archive, packed.stdout);
    archives[role] = archive;
    const digest = createHash('sha256').update(fs.readFileSync(archive)).digest('hex');
    if (role === 'preferred') pin.preferred.linuxX64Sha256 = ['digest-gate', 'extraction-order'].includes(mode) ? 'a'.repeat(64) : digest;
    else pin.recoveryCompatibility.linuxX64Sha256 = digest;
  }
  fs.writeFileSync(path.join(scripts, 'ci-toolchain.json'), JSON.stringify(pinChange(pin)));
  const curl = path.join(f.root, 'curl');
  fs.writeFileSync(curl, `#!${process.execPath}
const fs=require('node:fs'),path=require('node:path'),args=process.argv.slice(2),archives=${JSON.stringify(archives)};
${fq40CurlQueryStub}
const role=args.at(-1).includes('/v22.23.3/')?'recoveryCompatibility':'preferred';
fs.appendFileSync(process.env.TEST_LOG,JSON.stringify(['curl',role,...args])+'\\n');
if(process.env.TEST_MODE==='fq40-native63-'+role) process.exit(63);
fs.copyFileSync(archives[role],args[args.indexOf('--output')+1]);
if(process.env.TEST_MODE==='write-refusal') fs.chmodSync(path.join(process.env.RUNNER_TEMP,role==='preferred'?'styleguide-node/preferred':'styleguide-node/recoveryCompatibility'),0o500);
if(process.env.TEST_MODE==='native-status') process.exit(77);
`, { mode: 0o700 });
  const tar = path.join(f.root, 'tar');
  fs.writeFileSync(tar, `#!${process.execPath}
const fs=require('node:fs'),path=require('node:path'),{spawnSync}=require('node:child_process'),args=process.argv.slice(2);
const kind=args[0]==='-tvf'?'list':'extract',role=path.basename(args[1]).replace(/\\.tar\\.xz$/,'');
fs.appendFileSync(${JSON.stringify(f.log)},JSON.stringify(['tar',role,kind,...args])+'\\n');
if(kind==='extract' && ${JSON.stringify(mode)}==='native-extraction') process.exit(37);
const result=spawnSync('/usr/bin/tar',args,{stdio:'inherit',timeout:20000});
const record={status:result.status,signal:result.signal}; if(result.error) record.error={code:result.error.code,message:result.error.message};
fs.writeFileSync(path.join(${JSON.stringify(f.root)},'tar-'+role+'-'+kind+'.json'),JSON.stringify(record),{flag:'wx'});
if(result.error || result.signal || !Number.isInteger(result.status)) process.exit(98);
if(kind==='extract' && result.status===0 && ${JSON.stringify(mode)}==='truncated-extraction') fs.truncateSync(path.join(args[args.indexOf('-C')+1],'node-v24.18.1-linux-x64/bin/node'),1);
process.exit(result.status);
`, { mode: 0o700 });
  source = source.replaceAll('/usr/bin/curl', curl).replaceAll('/usr/bin/tar', tar);
  const script = path.join(scripts, 'Initialize-CiToolchain.ps1'); fs.writeFileSync(script, source);
  const env = { RUNNER_TEMP: runner, TEST_MODE: mode, ...extraEnv };
  for (const name of ['path', 'env']) fs.writeFileSync(path.join(f.root, name), '');
  const capturedOutput = path.join(f.root, 'captured-output.json');
  assert.ok(dependencySwitches.every(value => ['WorkflowDependencies', 'InstructionDependencies'].includes(value)));
  return { ...f, runner, sentinel, scripts, script, env, source, archives,
    capturedOutput,
    run({ captureOutput = false } = {}) {
      const command = `& ${quote(script)}${dependencySwitches.map(value => ` -${value}`).join('')}${compatibility ? ' -IncludeRecoveryCompatibility' : ''}`;
      this.result = f.run(captureOutput ? `$arrFq36Result = @(${command}); [IO.File]::WriteAllText(${quote(capturedOutput)}, (ConvertTo-Json -InputObject $arrFq36Result -Compress))` : command, env);
      return this.result;
    } };
}

test('FQ36 dependency logs stay outside the initializer success result', { skip: !linux, timeout: 180000 }, t => {
  for (const dependencySwitches of [[], ['WorkflowDependencies'], ['InstructionDependencies'], ['WorkflowDependencies', 'InstructionDependencies']]) {
    const f = foundationFixture(t, { dependencySwitches, mode: 'fq36-success' });
    assertCompletedProcess(f.run({ captureOutput: true }), 'FQ36 success');
    assert.equal(f.result.status, 0, f.result.stdout + f.result.stderr);
    assert.deepEqual(JSON.parse(fs.readFileSync(f.capturedOutput, 'utf8')), ['Reviewed runtime setup completed.']);
    assert.equal((f.result.stdout.match(/FQ36 preflight record/gu) ?? []).length, dependencySwitches.length);
    assert.equal((f.result.stdout.match(/FQ36 install record/gu) ?? []).length, dependencySwitches.length);
    assert.equal((f.result.stderr.match(/FQ36 preflight stderr/gu) ?? []).length, dependencySwitches.length);
    assert.equal((f.result.stderr.match(/FQ36 install stderr/gu) ?? []).length, dependencySwitches.length);
    assert.equal(f.calls().filter(row => row.includes('ci')).length, dependencySwitches.length);
  }
  for (const mode of ['fq36-preflight-failure', 'fq36-install-failure']) {
    const f = foundationFixture(t, { installs: true, mode });
    f.run({ captureOutput: true }); foundationNoPublication(f);
    assert.equal(fs.existsSync(f.capturedOutput), false);
    assert.match(f.result.stderr, mode === 'fq36-preflight-failure' ? /preflight failed before installation/ : /Locked installation failed: 37/);
    assert.equal(f.calls().filter(row => row.includes('ci')).length, mode === 'fq36-preflight-failure' ? 0 : 1);
  }
  const source = read('Initialize-CiToolchain.ps1');
  const route = ' |\n            ForEach-Object { Write-Information -MessageData $_ -InformationAction Continue }';
  assert.equal(source.split(route).length, 3, 'Both dependency commands must have a stdout route.');
  const mutant = foundationFixture(t, { source: source.replaceAll(route, ''), installs: true, mode: 'fq36-success' });
  assertCompletedProcess(mutant.run({ captureOutput: true }), 'FQ36 route-removal control');
  assert.equal(mutant.result.status, 0, mutant.result.stdout + mutant.result.stderr);
  assert.deepEqual(JSON.parse(fs.readFileSync(mutant.capturedOutput, 'utf8')),
    ['FQ36 preflight record', 'FQ36 install record', 'FQ36 preflight record', 'FQ36 install record', 'Reviewed runtime setup completed.']);
});

function applyRunnerEnvironment(records, environment) {
  for (const line of records.split('\n').filter(Boolean)) {
    const separator = line.indexOf('=');
    assert.ok(separator > 0, 'Expected one-line NAME=VALUE runner records.');
    environment[line.slice(0, separator)] = line.slice(separator + 1);
  }
  return environment;
}

// Extract the real publication checks, before either runner channel can be used.
// This proves record construction on both platforms, not complete Windows setup.
test('FQ35 actual recovery records reject line breaks before runner channel use', { timeout: 30000 }, () => {
  const source = read('Initialize-CiToolchain.ps1').replaceAll('\r\n', '\n');
  const start = '    $arrRunnerRecords = @(';
  const end = '    $null = Assert-OrdinaryPath $env:GITHUB_PATH';
  assert.equal(source.split(start).length, 2);
  assert.equal(source.split(end).length, 2);
  const boundary = source.slice(source.indexOf(start), source.indexOf(end));
  assert.equal(boundary.includes('.Write('), false);
  const cases = [{ name: 'off', node: null, accepted: true },
    { name: 'on', node: 'synthetic-verified-node', accepted: true },
    { name: 'LF', node: 'synthetic\nnode', accepted: false },
    { name: 'CRLF', node: 'synthetic\r\nnode', accepted: false }];
  const script = `$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$env:npm_config_userconfig='synthetic-user-config'
$env:npm_config_globalconfig='synthetic-global-config'
$hashtablePreferredRuntime=@{Bin='synthetic-preferred-bin'}
$cases=ConvertFrom-Json -InputObject ${quote(JSON.stringify(cases))}
$results=@(foreach($case in $cases) {
    $hashtableCompatibilityRuntime=if($null -eq $case.node) { $null } else { @{Node=$case.node} }
    $channelBoundaryReached=$false
    try {
${boundary}
        $channelBoundaryReached=$true
        [ordered]@{name=$case.name; accepted=$true; channelBoundaryReached=$channelBoundaryReached; records=@($arrRunnerRecords)}
    } catch {
        if($_.Exception.Message -cne 'toolchain: invalid runner record') { throw }
        [ordered]@{name=$case.name; accepted=$false; channelBoundaryReached=$channelBoundaryReached}
    }
})
ConvertTo-Json -InputObject $results -Depth 5 -Compress
`;
  const result = assertCompletedProcess(spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-Command', script],
    { encoding: 'utf8', timeout: 15000, maxBuffer: 256 * 1024, windowsHide: true }), 'FQ35 publication boundary');
  assert.equal(result.status, 0, result.stdout + result.stderr);
  const rows = JSON.parse(result.stdout);
  assert.equal(rows.length, cases.length);
  for (const [index, row] of rows.entries()) {
    const expected = cases[index];
    assert.equal(row.name, expected.name);
    assert.equal(row.accepted, expected.accepted);
    assert.equal(row.channelBoundaryReached, expected.accepted);
    if (expected.accepted) {
      assert.deepEqual(row.records.filter(line => line.startsWith('STYLEGUIDE_RECOVERY_NODE22=')),
        [`STYLEGUIDE_RECOVERY_NODE22=${expected.node ?? ''}`]);
      const environment = { STYLEGUIDE_RECOVERY_NODE22: 'stale-unverified', FQ35_UNRELATED: 'preserved' };
      applyRunnerEnvironment(row.records.join('\n'), environment);
      assert.equal(environment.STYLEGUIDE_RECOVERY_NODE22, expected.node ?? '');
      assert.equal(environment.FQ35_UNRELATED, 'preserved');
      assert.equal(row.records.some(line => /^NODE_OPTIONS=/iu.test(line)), false);
    }
  }
});

// Finite LF test model of SetEnvFileCommand and EnvFileKeyValuePairs in
// https://github.com/actions/runner/blob/main/src/Runner.Worker/FileCommandManager.cs
// This is not a native runner test or a complete parser/platform implementation.
function fq37RunnerModel(text, environment) {
  assert.ok(Buffer.byteLength(text) <= 16384);
  const lines = text.split('\n'), blocked = [];
  assert.ok(lines.length <= 64);
  for (let index = 0; index < lines.length; index++) {
    const line = lines[index];
    if (line === '') continue;
    const equal = line.indexOf('='), heredoc = line.indexOf('<<');
    let name, value;
    if (equal >= 0 && (heredoc < 0 || equal < heredoc)) {
      name = line.slice(0, equal); value = line.slice(equal + 1);
    } else {
      assert.ok(heredoc > 0, 'Expected a supported fixture record.');
      name = line.slice(0, heredoc);
      const delimiter = line.slice(heredoc + 2), body = [];
      assert.ok(delimiter.length > 0);
      while (++index < lines.length && lines[index] !== delimiter) body.push(lines[index]);
      assert.ok(index < lines.length, 'Expected the fixture delimiter.');
      value = body.join('\n');
    }
    assert.ok(name.length > 0);
    if (name.toUpperCase() === 'NODE_OPTIONS') blocked.push(name);
    else environment[name] = value;
  }
  return { environment, blocked };
}

test('FQ37 runner model refuses blocked keys before assignment and permits recovery clearing', () => {
  for (const record of ['NODE_OPTIONS=\n', 'NODE_OPTIONS=--no-warnings\n',
    'NoDe_OpTiOnS=\n', 'NODE_OPTIONS<<END\nEND\n',
    'nOdE_OpTiOnS<<END\n--no-warnings\nEND\n']) {
    const environment = { NODE_OPTIONS: 'inherited-selector', STYLEGUIDE_RECOVERY_NODE22: 'stale-unverified', UNRELATED: 'preserved' };
    const result = fq37RunnerModel(record + 'STYLEGUIDE_RECOVERY_NODE22=\n', environment);
    assert.equal(result.blocked.length, 1);
    assert.equal(result.blocked[0].toUpperCase(), 'NODE_OPTIONS');
    assert.deepEqual(result.environment, { NODE_OPTIONS: 'inherited-selector', STYLEGUIDE_RECOVERY_NODE22: '', UNRELATED: 'preserved' });
  }
});

test('FQ35 recovery selection follows successful off and on setup across fresh roots', { skip: !linux, timeout: 180000 }, t => {
  const job = { STYLEGUIDE_RECOVERY_NODE22: 'stale-unverified', FQ35_UNRELATED: 'preserved' };
  for (const compatibility of [false, false, true, false]) {
    const f = foundationFixture(t, { compatibility, extraEnv: { STYLEGUIDE_RECOVERY_NODE22: job.STYLEGUIDE_RECOVERY_NODE22 } });
    assertCompletedProcess(f.run(), 'FQ35 successful setup');
    assert.equal(f.result.status, 0, f.result.stdout + f.result.stderr);
    const records = fs.readFileSync(path.join(f.root, 'env'), 'utf8');
    const recovery = records.split('\n').filter(line => line.startsWith('STYLEGUIDE_RECOVERY_NODE22='));
    const expected = compatibility ? path.join(f.runner, 'styleguide-node/recoveryCompatibility/node-v22.23.3-linux-x64/bin/node') : '';
    assert.deepEqual(recovery, [`STYLEGUIDE_RECOVERY_NODE22=${expected}`]);
    assert.doesNotMatch(records, /^NODE_OPTIONS=/gimu, 'The runner blocks NODE_OPTIONS even when its value is empty.');
    assert.match(records, /^NODE_PATH=$/gmu);
    applyRunnerEnvironment(records, job);
    assert.equal(job.STYLEGUIDE_RECOVERY_NODE22, expected);
    assert.equal(job.FQ35_UNRELATED, 'preserved');
    assert.equal(fs.readFileSync(path.join(f.root, 'path'), 'utf8').includes('recoveryCompatibility'), false);
  }
});

test('FQ35 and FQ37 runner-record controls detect omissions and preserve failed handoffs', { skip: !linux, timeout: 180000 }, t => {
  const original = read('Initialize-CiToolchain.ps1');
  const clearRecovery = "    } else {\n        $arrRunnerRecords += 'STYLEGUIDE_RECOVERY_NODE22='\n    }";
  const stale = foundationFixture(t, { source: foundationOnce(original, clearRecovery, '    }'),
    extraEnv: { STYLEGUIDE_RECOVERY_NODE22: 'stale-unverified' } });
  assertCompletedProcess(stale.run(), 'FQ35 omitted recovery reset control');
  assert.equal(stale.result.status, 0, stale.result.stdout + stale.result.stderr);
  const staleRecords = fs.readFileSync(path.join(stale.root, 'env'), 'utf8');
  assert.doesNotMatch(staleRecords, /^STYLEGUIDE_RECOVERY_NODE22=/mu);
  assert.equal(applyRunnerEnvironment(staleRecords, { STYLEGUIDE_RECOVERY_NODE22: 'stale-unverified' }).STYLEGUIDE_RECOVERY_NODE22, 'stale-unverified');
  const blocked = foundationFixture(t, { source: foundationOnce(original, "        'NODE_PATH=')", "        'NODE_OPTIONS=', 'NODE_PATH=')") });
  assertCompletedProcess(blocked.run(), 'FQ37 restored blocked record control');
  assert.equal(blocked.result.status, 0, blocked.result.stdout + blocked.result.stderr);
  assert.match(fs.readFileSync(path.join(blocked.root, 'env'), 'utf8'), /^NODE_OPTIONS=$/mu);
  const failed = foundationFixture(t, { installs: true, mode: 'fq36-preflight-failure', extraEnv: { STYLEGUIDE_RECOVERY_NODE22: 'stale-unverified' } });
  const priorEnvironment = 'FQ35_UNRELATED=preserved\nSTYLEGUIDE_RECOVERY_NODE22=stale-unverified\n';
  fs.writeFileSync(path.join(failed.root, 'env'), priorEnvironment);
  assertCompletedProcess(failed.run(), 'FQ35 failed setup');
  assert.notEqual(failed.result.status, 0, failed.result.stdout + failed.result.stderr);
  assert.match(failed.result.stderr, /preflight failed before installation/);
  assert.doesNotMatch(failed.result.stdout, /Reviewed runtime setup completed/);
  assert.equal(fs.readFileSync(path.join(failed.root, 'env'), 'utf8'), priorEnvironment);
  assert.equal(fs.readFileSync(path.join(failed.root, 'path'), 'utf8'), '');
  assert.equal(fs.existsSync(path.join(failed.runner, 'styleguide-node')), false);
  assert.equal(fs.readFileSync(failed.sentinel, 'utf8'), 'unchanged');
});

function foundationNoPublication(f, { partial = false, retained = false } = {}) {
  assertCompletedProcess(f.result, 'F10-F14 ordinary initializer');
  assert.notEqual(f.result.status, 0, f.result.stdout + f.result.stderr);
  assert.doesNotMatch(f.result.stdout, /Reviewed runtime setup completed/);
  assert.equal(fs.readFileSync(path.join(f.root, 'path'), 'utf8'), '');
  if (!partial) assert.equal(fs.readFileSync(path.join(f.root, 'env'), 'utf8'), '');
  assert.equal(fs.existsSync(path.join(f.runner, 'styleguide-node')), retained);
  assert.equal(fs.readFileSync(f.sentinel, 'utf8'), 'unchanged');
}

function foundationTarNative(f, role, kind, status) {
  const record = JSON.parse(fs.readFileSync(path.join(f.root, `tar-${role}-${kind}.json`), 'utf8'));
  assertCompletedProcess(record, `Actual GNU tar ${role}/${kind}`); assert.equal(record.status, status);
}

for (const mode of ['occupied-file', 'linked-ancestor', 'hardlink-channels', 'native-extraction',
  'write-refusal', 'truncated-extraction', 'partial-channel', 'interrupted-child']) {
  test(`F10 ordinary filesystem control: ${mode}`, { skip: !linux, timeout: 90000 }, t => {
    const original = read('Initialize-CiToolchain.ps1'); let source = original;
    if (mode === 'partial-channel') source = foundationOnce(source,
      '$objEnvironmentChannel.Write($arrEnvironmentBytes, 0, $arrEnvironmentBytes.Length)',
      "$objEnvironmentChannel.Write($arrEnvironmentBytes, 0, 9); $objEnvironmentChannel.Flush($true); throw [IO.IOException]::new('F10 injected failure after actual partial channel write')");
    const f = foundationFixture(t, { source, mode, compatibility: mode === 'partial-channel' });
    if (mode === 'occupied-file') fs.writeFileSync(path.join(f.runner, 'styleguide-node'), 'occupied must survive');
    if (mode === 'linked-ancestor') { fs.symlinkSync('runner space and Unicode Ω', path.join(f.root, 'linked-ancestor'), 'dir'); f.env.RUNNER_TEMP = path.join(f.root, 'linked-ancestor'); }
    if (mode === 'hardlink-channels') {
      fs.unlinkSync(path.join(f.root, 'env')); fs.linkSync(path.join(f.root, 'path'), path.join(f.root, 'env'));
      const first = fs.lstatSync(path.join(f.root, 'path')), second = fs.lstatSync(path.join(f.root, 'env'));
      assert.equal(first.nlink, 2); assert.equal(second.nlink, 2); assert.equal(first.dev, second.dev); assert.equal(first.ino, second.ino);
    }
    f.run(); foundationNoPublication(f, { partial: mode === 'partial-channel', retained: mode === 'occupied-file' });
    if (mode === 'occupied-file') { assert.match(f.result.stderr, /staging destination already exists/); assert.equal(fs.readFileSync(path.join(f.runner, 'styleguide-node'), 'utf8'), 'occupied must survive'); }
    if (mode === 'linked-ancestor') assert.match(f.result.stderr, /linked path/);
    if (['occupied-file', 'linked-ancestor', 'hardlink-channels'].includes(mode)) assert.equal(f.calls().some(row => row[0] === 'curl'), false);
    if (mode === 'native-extraction') { foundationTarNative(f, 'preferred', 'list', 0); assert.match(f.result.stderr, /Runtime extraction failed: 37/); }
    if (mode === 'write-refusal') { foundationTarNative(f, 'preferred', 'list', 0); foundationTarNative(f, 'preferred', 'extract', 2); assert.match(f.result.stderr, /Runtime extraction failed: 2/); }
    if (mode === 'truncated-extraction') { foundationTarNative(f, 'preferred', 'extract', 0); assert.match(f.result.stderr, /extracted file size changed/); }
    if (mode === 'partial-channel') { assert.match(f.result.stderr, /F10 injected failure after actual partial channel write/); assert.equal(fs.readFileSync(path.join(f.root, 'env'), 'utf8'), 'npm_confi'); assert.equal(fs.existsSync(path.join(f.runner, 'styleguide-node/recoveryCompatibility')), false); }
    if (mode === 'interrupted-child') { const child = JSON.parse(fs.readFileSync(path.join(f.root, 'interrupted-child.json'), 'utf8')); assert.deepEqual(child, { status: null, signal: 'SIGTERM' }); assert.match(f.result.stderr, /installed Node version is incorrect/); }
    assert.equal(f.calls().some(row => row.includes('ci')), false);
    if (!['partial-channel', 'interrupted-child'].includes(mode)) assert.equal(f.calls().some(row => row[0] === 'preferred'), false);
    assert.equal(read('Initialize-CiToolchain.ps1'), original);
  });
}

for (const mode of ['junction-ancestor', 'hardlink-channels']) {
  test(`F10 Windows filesystem boundary: ${mode}`, { skip: process.platform !== 'win32', timeout: 60000 }, t => {
    const root = fs.mkdtempSync(path.join(os.tmpdir(), 'styleguide-f10-')); t.after(() => fs.rmSync(root, { recursive: true, force: true }));
    const source = read('Initialize-CiToolchain.ps1');
    const start = source.indexOf('function Assert-OrdinaryPath'), end = source.indexOf('function Get-OwnedPathIdentity');
    assert.ok(start > 0 && end > start);
    const opens = "$objPathChannel = [IO.File]::Open($env:GITHUB_PATH, [IO.FileMode]::Open, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)\n    $objEnvironmentChannel = [IO.File]::Open($env:GITHUB_ENV, [IO.FileMode]::Open, [IO.FileAccess]::ReadWrite, [IO.FileShare]::None)";
    assert.equal(source.split(opens).length, 2);
    const file = path.join(root, 'path'), environment = path.join(root, 'env'), target = path.join(root, 'target');
    fs.writeFileSync(file, ''); fs.writeFileSync(environment, ''); fs.mkdirSync(target); fs.writeFileSync(path.join(target, 'channel'), 'sentinel');
    const script = path.join(root, 'boundary.ps1'); fs.writeFileSync(script, `$ErrorActionPreference='Stop'\n${source.slice(start, end)}
$null=Assert-OrdinaryPath $env:GITHUB_PATH
$null=Assert-OrdinaryPath $env:GITHUB_ENV
$objPathChannel=$null; $objEnvironmentChannel=$null
try { ${opens}; Write-Output 'F10 boundary admitted' }
finally { foreach($objChannel in @($objPathChannel,$objEnvironmentChannel)) { if($null -ne $objChannel) { $objChannel.Dispose() } } }
`);
    const invoke = env => assertCompletedProcess(spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', script],
      { env: { ...process.env, ...env }, encoding: 'utf8', timeout: 15000, windowsHide: true }), `F10 Windows ${mode}`);
    const good = invoke({ GITHUB_PATH: file, GITHUB_ENV: environment }); assert.equal(good.status, 0, good.stderr); assert.match(good.stdout, /boundary admitted/);
    let selected = file;
    if (mode === 'junction-ancestor') { const link = path.join(root, 'junction'); fs.symlinkSync(target, link, 'junction'); selected = path.join(link, 'channel'); }
    else {
      fs.unlinkSync(environment); fs.linkSync(file, environment);
      const first = fs.lstatSync(file), second = fs.lstatSync(environment);
      assert.equal(first.nlink, 2); assert.equal(second.nlink, 2); assert.equal(first.dev, second.dev); assert.equal(first.ino, second.ino);
    }
    const bad = invoke({ GITHUB_PATH: selected, GITHUB_ENV: environment }); assert.notEqual(bad.status, 0, bad.stderr); assert.doesNotMatch(bad.stdout, /boundary admitted/);
    if (mode === 'junction-ancestor') assert.match(bad.stderr, /linked path/);
    assert.equal(fs.readFileSync(path.join(target, 'channel'), 'utf8'), 'sentinel'); assert.equal(fs.readFileSync(file, 'utf8'), '');
  });
}

// The maintained test uses a self-contained archive; fixed GNU tar/xz still
// exercise the real extraction boundary. Official downloads are verified separately.
for (const mode of ['device', 'entry-cap', 'byte-cap', 'hostile-selectors-and-path-xz']) {
  test(`F11 actual tar boundary: ${mode}`, { skip: !linux, timeout: mode.startsWith('hostile') ? 90000 : 60000 }, t => {
    let source = read('Initialize-CiToolchain.ps1');
    if (mode.endsWith('-cap')) {
      const cap = '$objArchiveMembers.Count -gt 50000 -or $intExpandedBytes -gt 1073741824'; assert.equal(source.split(cap).length, 3);
      source = source.replaceAll(cap, mode === 'entry-cap' ? '$objArchiveMembers.Count -gt 16 -or $intExpandedBytes -gt 1073741824' : '$objArchiveMembers.Count -gt 50000 -or $intExpandedBytes -gt 1024');
    }
    const hostile = mode.startsWith('hostile'), f = foundationFixture(t, { source, mode });
    if (hostile) {
      const fake = path.join(f.root, 'fake-bin'); fs.mkdirSync(fake);
      const marker = path.join(f.root, 'selector-marker'), xzMarker = path.join(f.root, 'xz-marker');
      const checkpoint = path.join(f.root, 'checkpoint'); fs.writeFileSync(checkpoint, `#!${process.execPath}\nrequire('node:fs').writeFileSync(${JSON.stringify(marker)},'unexpected');\n`, { mode: 0o700 });
      fs.writeFileSync(path.join(fake, 'xz'), `#!${process.execPath}\nrequire('node:fs').writeFileSync(${JSON.stringify(xzMarker)},'unexpected'); process.exit(37);\n`, { mode: 0o700 });
      Object.assign(f.env, { PATH: fake + path.delimiter + process.env.PATH,
        TAR_OPTIONS: `--checkpoint=1 --checkpoint-action=exec=${checkpoint}`, XZ_DEFAULTS: '--fixture-invalid', XZ_OPT: '--fixture-invalid' });
      f.run(); assert.equal(f.result.status, 0, f.result.stderr); foundationTarNative(f, 'preferred', 'list', 0); foundationTarNative(f, 'preferred', 'extract', 0);
      assert.match(f.result.stdout, /Verified preferred Node 24\.18\.1\/npm 11\.16\.0 linux-x64 SHA256/);
      const ownership = fs.readFileSync(path.join(f.runner, 'styleguide-node/.owner'));
      assert.equal(ownership.length, 32); assert.match(ownership.toString('utf8'), /^[0-9a-f]{32}$/u);
      for (const name of ['npm-user.config', 'npm-global.config']) {
        assert.equal(fs.readFileSync(path.join(f.runner, 'styleguide-node', name)).length, 0);
      }
      const readyBytes = fs.readFileSync(path.join(f.runner, 'styleguide-node/ready.json'));
      const ready = JSON.parse(readyBytes.toString('utf8'));
      assert.deepEqual(ready, { node: '24.18.1', npm: '11.16.0' });
      assert.deepEqual(readyBytes, Buffer.from(JSON.stringify(ready), 'utf8'));
      assert.equal(fs.existsSync(marker), false); assert.equal(fs.existsSync(xzMarker), false);
      assert.equal(fs.readFileSync(path.join(f.root, 'path'), 'utf8'), path.join(f.runner, 'styleguide-node/preferred/node-v24.18.1-linux-x64/bin') + '\n');
      assert.ok(f.runner.includes(' ') && f.runner.includes('Ω'));
      assert.equal(fs.readFileSync(f.sentinel, 'utf8'), 'unchanged');
    } else {
      f.run(); foundationNoPublication(f); assert.match(f.result.stderr, mode === 'device' ? /unsupported GNU tar member record/ : /archive extraction limit exceeded/);
      assert.equal(f.calls().some(row => row[0] === 'tar' && row[2] === 'extract'), false);
      assert.equal(f.calls().some(row => row[0] === 'preferred' || row.includes('ci')), false);
    }
  });
}

function foundationMutation(source, mode) {
  const digest = `    if ((Get-FileHash -LiteralPath $strArchive -Algorithm SHA256).Hash.ToLowerInvariant() -cne $Digest) {
        throw "The runtime archive digest is incorrect for $strDownloadAddress. Check package.json engines.node and .github/workflows/ci-toolchain.json $Role. Verify the official release checksum before changing the declaration."
    }
`;
  if (mode === 'digest-gate') return foundationOnce(source, digest, '');
  if (mode === 'extraction-order') return foundationOnce(source, digest + '    Expand-ReviewedArchive $strArchive $strDestinationPath $strReleaseRoot', '    Expand-ReviewedArchive $strArchive $strDestinationPath $strReleaseRoot\n' + digest.trimEnd());
  if (mode === 'role-admission') return foundationOnce(source, "$objPin.recoveryCompatibility.node -cne '22.23.3'", '$false');
  if (mode === 'platform-admission') return foundationOnce(source,
    '[Runtime.InteropServices.Architecture]::Arm64 -ne [Runtime.InteropServices.Architecture]::X64', '$false');
  if (mode === 'path-node') return foundationOnce(source, '$arrNodeVersionOutput = @(& $strNodePath --version)', '$arrNodeVersionOutput = @(& node --version)');
  if (mode === 'path-npm') return foundationOnce(source, '$arrNpmVersionOutput = @(& $strNodePath $strNpmScriptPath --version)', '$arrNpmVersionOutput = @(& npm --version)');
  if (mode === 'credential-bypass') return foundationOnce(source, '& "$PSScriptRoot/Test-CheckoutCredentials.ps1"', '');
  if (mode === 'node22-install') return foundationOnce(source, '& $hashtablePreferredRuntime.Node $hashtablePreferredRuntime.Npm --prefix $strInstallRoot ci', '& $hashtableCompatibilityRuntime.Node $hashtableCompatibilityRuntime.Npm --prefix $strInstallRoot ci');
  if (mode === 'escape-admission') return foundationOnce(source, '        Assert-MemberTree $objArchiveMembers $ReleaseRoot\n        $objExtractionProcess =', '        $objExtractionProcess =');
  if (mode === 'native-status') return foundationOnce(source,
    '    if ($LASTEXITCODE -ne 0) {\n        throw "Runtime download failed: $LASTEXITCODE ($Role/$strPlatform)"\n    }\n', '');
  assert.equal(mode, 'preflight-order');
  const preflight = `        & $hashtablePreferredRuntime.Node --permission "--allow-fs-read=$strRepositoryRoot" "$PSScriptRoot/Validate-WorkflowPolicy.mjs" --preflight |
            ForEach-Object { Write-Information -MessageData $_ -InformationAction Continue }
        if ($LASTEXITCODE -ne 0) {
            throw 'Package and workflow preflight failed before installation.'
        }
`;
  const install = `        & $hashtablePreferredRuntime.Node $hashtablePreferredRuntime.Npm --prefix $strInstallRoot ci --ignore-scripts --no-audit --fund=false --include=dev --package-lock=true |
            ForEach-Object { Write-Information -MessageData $_ -InformationAction Continue }
        if ($LASTEXITCODE -ne 0) {
            throw "Locked installation failed: $LASTEXITCODE"
        }
`;
  return foundationOnce(source, preflight + install, install + preflight);
}

async function foundationCurlCell(t, kind, mutation = '') {
  const f = fixture(t, 'transport repository space and Unicode Ω'), scripts = path.join(f.work, '.github/workflows');
  fs.mkdirSync(scripts, { recursive: true });
  const payload = Buffer.from('exact recovered fixture bytes'), requests = [], sockets = new Set();
  const server = kind === 'tls-stall' ? createConnectionServer(socket => {
    const record = { at: performance.now(), connection: true }; requests.push(record); sockets.add(socket);
    socket.on('error', error => { record.error = error.code; assert.ok(['ECONNRESET', 'EPIPE'].includes(error.code), error.message); });
    socket.on('close', () => sockets.delete(socket));
  }) : createServer((req, res) => {
    requests.push({ at: performance.now(), url: req.url, header: req.headers['x-fixture-ambient'] });
    if (kind === 'partial-recovery' && requests.length === 1) { res.writeHead(200, { 'Content-Length': 100 }); res.write('partial'); return; }
    if (kind === 'transfer-bound') return;
    if (kind === 'retry-start-bound') { res.writeHead(503, { 'Retry-After': '600' }); res.end('retry admission must refuse'); return; }
    if (kind === 'retry-count') { res.writeHead(503); res.end('retry class unchanged'); return; }
    res.end(payload);
  });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  t.after(() => { for (const socket of sockets) socket.destroy(); if (server.closeAllConnections) server.closeAllConnections(); server.close(); });
  const endpoint = `${kind === 'tls-stall' ? 'https' : 'http'}://127.0.0.1:${server.address().port}`;
  fs.writeFileSync(path.join(f.root, '.curlrc'), `header = "X-Fixture-Ambient: dummy"\nurl = "${endpoint}/ambient"\n`);
  fs.writeFileSync(path.join(f.work, 'package.json'), JSON.stringify({ engines: { node: '24.18.1', npm: '11.16.0' } }));
  fs.writeFileSync(path.join(scripts, 'ci-toolchain.json'), JSON.stringify(runtimePin(createHash('sha256').update(payload).digest('hex'))));
  fs.writeFileSync(path.join(scripts, 'Test-CheckoutCredentials.ps1'), read('Test-CheckoutCredentials.ps1')
    .replaceAll('/usr/bin/git', f.git).replaceAll("'/bin/git'", quote(f.git)));
  const witness = path.join(f.root, 'curl-result.json'), argumentsFile = path.join(f.root, 'curl-arguments.json'), curl = path.join(f.root, 'curl');
  const mode = kind === 'tls-stall' || kind === 'transfer-bound' ? 'stall'
    : kind === 'retry-start-bound' ? 'retry-after-number' : kind === 'retry-count' ? 'exhaustion' : 'transient';
  fs.writeFileSync(curl, `#!${process.execPath}
const fs=require('node:fs'),{spawnSync}=require('node:child_process'),args=process.argv.slice(2);
if(JSON.stringify(args)===JSON.stringify(['--disable','--version']) || JSON.stringify(args)===JSON.stringify(['--disable','--help','all'])) {
const query=spawnSync('/usr/bin/curl',args,{stdio:'inherit',timeout:15000});
if(query.error || query.signal || !Number.isInteger(query.status)) process.exit(98);
process.exit(query.status);
}
fs.writeFileSync(${JSON.stringify(argumentsFile)},JSON.stringify(args),{flag:'wx'});
const clock=(flag,value)=>{const index=args.indexOf(flag);if(index>=0)args[index+1]=value;};
clock('--connect-timeout','1');clock('--max-time',${JSON.stringify(kind === 'tls-stall' ? '3' : '1')});
${kind === 'tls-stall' ? '' : "clock('--proto','=http');clock('--proto-redir','=http');"}
args[args.length-1]=${JSON.stringify(endpoint + '/archive')};
const started=performance.now(),result=spawnSync('/usr/bin/curl',args,{stdio:'inherit',timeout:16000,env:{...process.env,NO_PROXY:'127.0.0.1',no_proxy:'127.0.0.1'}});
const record={mode:${JSON.stringify(mode)},command:'/usr/bin/curl',status:result.status,signal:result.signal};
if(result.error)record.error={name:result.error.name,message:result.error.message,code:result.error.code,syscall:result.error.syscall,stack:result.error.stack};
fs.writeFileSync(${JSON.stringify(witness)},JSON.stringify(record),{flag:'wx',mode:0o600});
fs.writeFileSync(${JSON.stringify(path.join(f.root, 'curl-elapsed.json'))},JSON.stringify(performance.now()-started),{flag:'wx'});
if(result.error)process.exit(98);process.exit(result.status??97);
`, { mode: 0o700 });
  const tar = path.join(f.root, 'tar'); fs.writeFileSync(tar, `#!/bin/sh\nprintf listed > '${f.root}/tar-marker'\nexit 23\n`, { mode: 0o700 });
  const original = read('Initialize-CiToolchain.ps1'); let source = original;
  const mutations = { 'connect-bound': ['--connect-timeout 20 ', ''], 'transfer-bound': ['--max-time 180 ', ''],
    'retry-start-bound': ['--retry-max-time 300 ', ''], 'retry-count': ['--retry 2 ', '--retry 3 '], 'first-disable': ['    & $strCurlPath --disable --silent ', '    & $strCurlPath --silent '] };
  if (mutation) { assert.ok(Object.hasOwn(mutations, mutation)); source = foundationOnce(source, ...mutations[mutation]); }
  const script = path.join(scripts, 'Initialize-CiToolchain.ps1'); fs.writeFileSync(script, source.replaceAll('/usr/bin/curl', curl).replaceAll('/usr/bin/tar', tar));
  for (const file of ['path', 'env']) fs.writeFileSync(path.join(f.root, file), '');
  const env = { ...process.env, RUNNER_TEMP: f.root, GITHUB_PATH: path.join(f.root, 'path'), GITHUB_ENV: path.join(f.root, 'env'), CURL_HOME: f.root, TEST_LOG: f.log, TEST_MODE: '' };
  for (const key of ['GITHUB_TOKEN', 'GH_TOKEN', 'ACTIONS_RUNTIME_TOKEN', 'GIT_CONFIG_COUNT', 'GIT_CONFIG_PARAMETERS']) delete env[key];
  const result = await new Promise((resolve, reject) => {
    const child = spawn('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', script], { cwd: f.work, env, windowsHide: true });
    let stdout = '', stderr = '', expired = false;
    const watchdog = setTimeout(() => { expired = true; child.kill('SIGKILL'); }, 25000);
    child.stdout.on('data', bytes => stdout += bytes); child.stderr.on('data', bytes => stderr += bytes);
    child.on('error', error => { clearTimeout(watchdog); reject(error); });
    child.on('close', (status, signal) => { clearTimeout(watchdog); resolve({ stdout, stderr, status, signal, expired }); });
  });
  assert.equal(result.expired, false, 'The outer watchdog is always failure.'); assertCompletedProcess(result, 'F12/F14 ordinary PowerShell'); assert.notEqual(result.status, 0);
  assert.equal(fs.readFileSync(env.GITHUB_PATH, 'utf8'), ''); assert.equal(fs.readFileSync(env.GITHUB_ENV, 'utf8'), '');
  assert.equal(fs.existsSync(path.join(f.root, 'styleguide-node')), false, result.stdout + result.stderr);
  assert.equal(read('Initialize-CiToolchain.ps1'), original);
  return { ...f, result, requests, witness, mode,
    arguments: JSON.parse(fs.readFileSync(argumentsFile, 'utf8')),
    elapsed: JSON.parse(fs.readFileSync(path.join(f.root, 'curl-elapsed.json'), 'utf8')),
    raw: JSON.parse(fs.readFileSync(witness, 'utf8')) };
}

function foundationCurlOracle(f, kind) {
  const expected = { '--connect-timeout': '20', '--max-time': '180', '--retry': '2', '--retry-max-time': '300', '--proto': '=https', '--proto-redir': '=https', '--max-filesize': '67108864' };
  assert.equal(f.arguments[0], '--disable');
  assert.equal(f.arguments.filter(value => value === '--max-filesize').length, 1);
  for (const [flag, value] of Object.entries(expected)) { const index = f.arguments.indexOf(flag); assert.ok(index >= 0); assert.equal(f.arguments[index + 1], value); }
  readCurlResultWitness(f.witness, f.mode, `F12/F14 ${kind}`);
  if (kind === 'tls-stall') { assert.ok(f.elapsed < 9000, 'Connect1 must bound TLS before the larger max3 attempt budget'); assert.equal(f.requests.length, 3); assert.equal(fs.existsSync(path.join(f.root, 'tar-marker')), false); }
  else if (kind === 'partial-recovery') { assert.equal(f.requests.length, 2); assert.equal(fs.existsSync(path.join(f.root, 'tar-marker')), true); assert.match(f.result.stderr, /archive listing failed: 23/); }
  else if (kind === 'retry-start-bound') assert.equal(f.requests.length, 1);
  else if (kind === 'retry-count') assert.equal(f.requests.length, 3);
  assert.equal(f.requests.some(row => row.url === '/ambient' || row.header), false, 'No curlrc header or extra URL');
}

for (const kind of ['tls-stall', 'partial-recovery']) {
  test(`F12 ordinary actual curl boundary: ${kind}`, { skip: !linux, timeout: 60000 }, async t => {
    foundationCurlOracle(await foundationCurlCell(t, kind), kind);
  });
}

for (const mutation of ['connect-bound', 'transfer-bound', 'retry-start-bound', 'retry-count', 'first-disable']) {
  test(`F14 selected curl mutation witness: ${mutation}`, { skip: !linux, timeout: 90000 }, async t => {
    const kind = mutation === 'connect-bound' ? 'tls-stall' : mutation;
    const good = await foundationCurlCell(t, kind); foundationCurlOracle(good, kind);
    const bad = await foundationCurlCell(t, kind, mutation);
    if (['transfer-bound', 'retry-start-bound'].includes(mutation)) {
      // These exact private mutants exceed the inner fixture watchdog. Preserve
      // its raw incomplete result; do not count mapped98 as product refusal.
      assert.equal(bad.raw.error?.code, 'ETIMEDOUT'); assert.equal(bad.raw.status, null);
      assert.equal(bad.raw.signal, 'SIGTERM'); assert.match(bad.result.stderr, /Runtime download failed: 98/);
      assert.throws(() => readCurlResultWitness(bad.witness, bad.mode, 'Known timer mutant watchdog'), assert.AssertionError);
    } else {
      readCurlResultWitness(bad.witness, bad.mode, `Completed curl mutant ${mutation}`);
      if (mutation === 'connect-bound') { assert.ok(bad.elapsed >= 9000); assert.equal(bad.requests.length, 3); }
      if (mutation === 'retry-count') assert.equal(bad.requests.length, 4);
      if (mutation === 'first-disable') assert.ok(bad.requests.some(row => row.url === '/ambient' || row.header));
    }
    assert.throws(() => foundationCurlOracle(bad, kind), assert.AssertionError);
    t.diagnostic(`${mutation}: observed actual-curl discriminator; unchanged admission oracle rejects the private mutant.`);
  });
}

for (const mode of ['digest-gate', 'extraction-order', 'role-admission', 'platform-admission', 'path-node',
  'path-npm', 'credential-bypass', 'preflight-order', 'node22-install', 'escape-admission', 'native-status']) {
  test(`F13 selected product mutation witness: ${mode}`, { skip: !linux, timeout: 180000 }, t => {
    const original = read('Initialize-CiToolchain.ps1');
    let baseline = original;
    // Fixture state makes an unsupported architecture reachable on this x64 host;
    // the selected mutation removes only the actual architecture refusal guard.
    if (mode === 'platform-admission') baseline = foundationOnce(baseline,
      '[Runtime.InteropServices.RuntimeInformation]::OSArchitecture', '[Runtime.InteropServices.Architecture]::Arm64');
    const mutated = foundationMutation(baseline, mode);
    const build = source => {
      const f = foundationFixture(t, { source, mode: mode === 'preflight-order' ? 'preflight' : mode,
        compatibility: mode === 'node22-install', installs: ['preflight-order', 'node22-install'].includes(mode),
        pinChange: pin => mode === 'role-admission' ? { ...pin, recoveryCompatibility: { ...pin.recoveryCompatibility, node: '22.23.4' } } : pin,
        extraEnv: mode === 'credential-bypass' ? { GH_TOKEN: 'dummy-never-publish' } : {} });
      if (mode.startsWith('path-')) {
        const bin = path.join(f.root, 'fake-bin'); fs.mkdirSync(bin);
        for (const executable of ['node', 'npm']) fs.writeFileSync(path.join(bin, executable), `#!${process.execPath}\nrequire('node:fs').appendFileSync(${JSON.stringify(f.log)},JSON.stringify(['PATH-${executable}'])+'\\n'); process.exit(37);\n`, { mode: 0o700 });
        f.env.PATH = bin + path.delimiter + process.env.PATH;
      }
      return f;
    };
    const good = build(baseline); good.run();
    const oracle = f => {
      if (['digest-gate', 'extraction-order'].includes(mode)) { assert.equal(f.calls().some(row => row[0] === 'tar'), false, 'Digest refusal must precede all archive dispatch'); foundationNoPublication(f); assert.match(f.result.stderr, /archive digest is incorrect/); }
      else if (['role-admission', 'platform-admission', 'credential-bypass'].includes(mode)) {
        assert.equal(f.calls().some(row => row[0] === 'curl'), false, 'Admission/credential refusal must precede curl'); foundationNoPublication(f);
        const cause = { 'role-admission': /reviewed runtime declaration is invalid/, 'platform-admission': /requires native Linux or Windows x64/,
          'credential-bypass': /a token was projected into a code job/ }; assert.match(f.result.stderr, cause[mode]);
      }
      else if (mode.startsWith('path-')) { assert.equal(f.calls().some(row => row[0].startsWith('PATH-')), false, 'Only absolute acquired tools may run'); assert.equal(f.result.status, 0, f.result.stderr); }
      else if (mode === 'preflight-order') { assert.equal(f.calls().some(row => row.includes('ci')), false, 'Failed preflight must precede all installs'); foundationNoPublication(f); assert.match(f.result.stderr, /preflight failed before installation/); }
      else if (mode === 'node22-install') { assert.equal(f.calls().some(row => row[0] === 'recoveryCompatibility' && row.includes('ci')), false, 'No ordinary Node22 install'); assert.equal(f.result.status, 0, f.result.stderr); }
      else if (mode === 'escape-admission') { assert.equal(f.calls().some(row => row[0] === 'tar' && row[2] === 'extract'), false, 'Escaping member must be refused before extraction'); foundationNoPublication(f); assert.match(f.result.stderr, /escaping archive link/); }
      else { foundationNoPublication(f); assert.match(f.result.stderr, /Runtime download failed: 77/); assert.equal(f.calls().some(row => row[0] === 'tar'), false); }
    };
    oracle(good);
    const bad = build(mutated); bad.run();
    const refusing = ['extraction-order', 'path-node', 'path-npm', 'preflight-order', 'node22-install'];
    assert.equal(bad.result.status, refusing.includes(mode) ? 1 : 0, bad.result.stdout + bad.result.stderr);
    const primary = { 'extraction-order': /archive digest is incorrect/, 'path-node': /installed Node version is incorrect/,
      'path-npm': /installed npm version is incorrect/, 'preflight-order': /preflight failed before installation/, 'node22-install': /Locked installation failed: 92/ };
    if (Object.hasOwn(primary, mode)) assert.match(bad.result.stderr, primary[mode]);
    // A fixture/setup error is not a successful mutation witness: prove its
    // selected changed phase before asking the original oracle to reject it.
    if (['digest-gate', 'extraction-order', 'native-status'].includes(mode)) assert.ok(bad.calls().some(row => row[0] === 'tar'));
    if (['role-admission', 'platform-admission', 'credential-bypass'].includes(mode)) assert.ok(bad.calls().some(row => row[0] === 'curl'));
    if (mode.startsWith('path-')) assert.ok(bad.calls().some(row => row[0] === `PATH-${mode.slice(5)}`));
    if (mode === 'preflight-order') assert.ok(bad.calls().some(row => row.includes('ci')));
    if (mode === 'node22-install') assert.ok(bad.calls().some(row => row[0] === 'recoveryCompatibility' && row.includes('ci')));
    if (mode === 'escape-admission') { assert.equal(bad.result.status, 0, bad.result.stderr); assert.equal(fs.readlinkSync(path.join(bad.runner, 'styleguide-node/preferred/node-v24.18.1-linux-x64/bin/npm')), '../../../../outside-sentinel'); }
    assert.throws(() => oracle(bad), assert.AssertionError);
    assert.equal(fs.readFileSync(bad.sentinel, 'utf8'), 'unchanged'); assert.equal(read('Initialize-CiToolchain.ps1'), original);
    assert.equal((good.result.stdout + good.result.stderr + bad.result.stdout + bad.result.stderr).includes('dummy-never-publish'), false);
    t.diagnostic(`${mode}: baseline oracle accepts; observed changed phase makes the same oracle reject the private mutant.`);
  });
}

// Selected FQ40 controls use the actual shared capability and acquisition bodies.
// Native boundary cells isolate download/digest/extraction ordering; they do not
// impersonate a whole Windows installer or native hosted runner.
function fq40Region(source, start, end) {
  assert.equal(source.split(start).length, 2, start);
  const at = source.indexOf(start), stop = source.indexOf(end, at);
  assert.ok(stop > at, end);
  return source.slice(at, stop);
}
function fq40Constant(source, value = 8192) {
  const declaration = source.match(/^New-Variable -Name intMaximumRuntimeArchiveBytes -Value 67108864 -Option Constant -WhatIf:\$false -Confirm:\$false$/mu)?.[0];
  assert.ok(declaration, 'The script-owned production cap must be exactly 67108864.');
  assert.equal(source.split(declaration).length, 2);
  return declaration.replace('-Value 67108864 ', `-Value ${value} `);
}
function fq40PostSizeOracle(f, role) {
  assertCompletedProcess(f.result, `FQ40 ordinary ${role} filesize refusal`);
  assert.notEqual(f.result.status, 0);
  assert.match(stripVTControlCharacters(f.result.stderr), /compressed runtime archive exceeds the fixed size limit/u);
  assert.equal(fs.existsSync(f.fq40HashMarker), false, 'Size refusal must precede hashing the completed archive.');
  assert.equal(f.calls().some(row => row[0] === 'tar' && row[1] === role), false, 'Size refusal must precede even archive listing.');
  foundationNoPublication(f);
}
test('FQ40 shared fixed archive cap and capability call ordering', () => {
  const source = read('Initialize-CiToolchain.ps1');
  fq40Constant(source);
  const installer = fq40Region(source, 'function Install-ReviewedRuntime {', 'if ((-not $IsLinux');
  assert.equal(installer.split('--max-filesize $intMaximumRuntimeArchiveBytes').length, 2);
  const ordinary = installer.indexOf('$null = Assert-OrdinaryPath $strArchive');
  const size = installer.indexOf('(Get-Item -LiteralPath $strArchive -Force -ErrorAction Stop).Length -gt $intMaximumRuntimeArchiveBytes');
  assert.ok(ordinary < size && size < installer.indexOf('(Get-FileHash -LiteralPath $strArchive'));
  const windows = source.indexOf('    Assert-CurlCapability -Path $strCurlPath -Windows');
  assert.ok(windows > 0 && windows < source.indexOf('& "$PSScriptRoot/Test-CheckoutCredentials.ps1"'));
  const linuxCall = source.indexOf('        Assert-CurlCapability -Path $strCurlPath');
  const ownedTry = source.indexOf('$objEnvironmentChannel = $null\ntry {');
  assert.ok(ownedTry >= 0 && linuxCall > ownedTry);
  const sanitation = source.indexOf("    Remove-Item Env:STYLEGUIDE_RECOVERY_NODE22, Env:NODE_OPTIONS, Env:NODE_PATH");
  assert.ok(sanitation >= 0 && linuxCall > sanitation);
  assert.ok(linuxCall < source.indexOf('$hashtablePreferredRuntime = Install-ReviewedRuntime'));
});
test('FQ40 capability matrix rejects unsupported queries and causal gate omissions', { timeout: 90000 }, t => {
  const source = read('Initialize-CiToolchain.ps1');
  const actual = fq40Region(source, 'function Assert-CurlCapability {', 'function Install-ReviewedRuntime {');
  const options = ['disable', 'silent', 'show-error', 'fail', 'location', 'proto', 'proto-redir',
    'tlsv1.2', 'connect-timeout', 'max-time', 'max-filesize', 'retry', 'retry-max-time', 'output'];
  const version = (curl = '8.5.0', lib = curl) => [`curl ${curl} (fixture) libcurl/${lib} OpenSSL/3.0.0`, 'Protocols: https', 'Features: SSL'];
  const help = options.map(flag => ` --${flag} fixture`);
  const item = (name, output, pass = false, extra = {}) => ({ name, version: output, help, pass, windows: false, versionExit: 0, helpExit: 0, ...extra });
  const cases = [
    item('minimum Linux', version(), true), item('newer Linux', version('8.21.0'), true),
    item('later Linux major', version('9.0.0'), true),
    item('minimum Windows policy', version(), true, { windows: true }),
    item('newer Windows policy', version('8.21.0'), true, { windows: true }),
    item('Windows major9', version('9.0.0'), false, { windows: true }),
    item('Windows old8.4', version('8.4.0'), false, { windows: true }),
    ...['7.88.1', '8.3.0', '8.4.0'].map(value => item(`old curl ${value}`, version(value, '8.5.0'))),
    item('old library', version('8.5.0', '8.4.0')),
    item('both old8.4', version('8.4.0')),
    item('missing library', ['curl 8.5.0 (fixture)', 'Protocols: https', 'Features: SSL']),
    item('malformed library', version().map((line, i) => i ? line : line.replace('libcurl/8.5.0', 'libcurl/8.5.bad'))),
    item('duplicate curl', version().map((line, i) => i ? line : line + ' curl 8.5.0')),
    item('duplicate library', version().map((line, i) => i ? line : line + ' libcurl/8.5.0')),
    item('wrong first line', ['fixture', ...version()]),
    item('no HTTPS', [version()[0], 'Protocols: http', 'Features: SSL']),
    item('no SSL', [version()[0], 'Protocols: https', 'Features: IPv6']),
    item('duplicate protocols', [...version(), 'Protocols: https']),
    item('duplicate features', [...version(), 'Features: SSL']),
    item('version query failure', version(), false, { versionExit: 17 }),
    item('help query failure', version(), false, { helpExit: 19 }),
    ...options.map(flag => item(`missing option ${flag}`, version(), false, { help: help.filter(line => !line.startsWith(` --${flag} `)) })),
  ];
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'styleguide-curl-capabilities-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const caseFile = path.join(root, 'case.json'), queryLog = path.join(root, 'queries.jsonl'), tool = path.join(root, 'curl.ps1');
  fs.writeFileSync(tool, `$Arguments=@($args)
$case=Get-Content -LiteralPath ${quote(caseFile)} -Raw | ConvertFrom-Json
[IO.File]::AppendAllText(${quote(queryLog)}, (ConvertTo-Json -InputObject @($Arguments) -Compress)+[Environment]::NewLine)
if(($Arguments -join '|') -ceq '--disable|--version') { $case.version; exit $case.versionExit }
if(($Arguments -join '|') -ceq '--disable|--help|all') { $case.help; exit $case.helpExit }
throw 'fixture: unreviewed capability query'
`);
  const run = body => {
    const script = `Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$PSNativeCommandUseErrorActionPreference=$false
${body}
$cases=ConvertFrom-Json -InputObject ${quote(JSON.stringify(cases))}
$rows=@(foreach($case in $cases) {
 [IO.File]::WriteAllText(${quote(caseFile)}, (ConvertTo-Json -InputObject $case -Depth 6 -Compress))
 try { Assert-CurlCapability -Path ${quote(tool)} -Windows:([bool]$case.windows) 6>$null; $accepted=$true }
 catch { $accepted=$false }
 [ordered]@{name=$case.name; accepted=$accepted}
})
ConvertTo-Json -InputObject $rows -Compress
`;
    const scriptFile = path.join(root, 'matrix.ps1'); fs.writeFileSync(scriptFile, script);
    const result = assertCompletedProcess(spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', scriptFile],
      { encoding: 'utf8', timeout: 15000, maxBuffer: 256 * 1024, windowsHide: true }), 'FQ40 actual capability matrix');
    assert.equal(result.status, 0, result.stdout + result.stderr);
    const rows = JSON.parse(result.stdout); assert.equal(rows.length, cases.length);
    return rows;
  };
  const oracle = rows => rows.forEach((row, index) => {
    assert.equal(row.name, cases[index].name); assert.equal(row.accepted, cases[index].pass, row.name);
  });
  oracle(run(actual));
  for (const [label, old, replacement] of [
    ['minimum curl', "$objCurlVersion -lt [version]'8.5.0'", '$false'],
    ['minimum library', "$objLibraryVersion -lt [version]'8.5.0'", '$false'],
    ['Windows major', '($Windows -and $objCurlVersion.Major -ne 8)', '$false'],
    ['max-filesize option', "'max-filesize', ", ''],
  ]) {
    const rows = run(foundationOnce(actual, old, replacement));
    assert.throws(() => oracle(rows), assert.AssertionError, label);
  }
  const queries = fs.readFileSync(queryLog, 'utf8').trim().split('\n').map(line => JSON.parse(line));
  assert.ok(queries.length > 0);
  assert.ok(queries.every(args => JSON.stringify(args) === '["--disable","--version"]' || JSON.stringify(args) === '["--disable","--help","all"]'));
});
for (const role of ['preferred', 'recoveryCompatibility']) {
  test(`FQ40 completed compressed-size guard precedes hash/listing: ${role}`, { skip: !linux, timeout: 90000 }, t => {
    const original = read('Initialize-CiToolchain.ps1');
    const declaration = fq40Constant(original, 8192);
    const source = foundationOnce(original, fq40Constant(original, 67108864), declaration);
    const guard = "    if ((Get-Item -LiteralPath $strArchive -Force -ErrorAction Stop).Length -gt $intMaximumRuntimeArchiveBytes) {\n" +
      "        throw 'toolchain: compressed runtime archive exceeds the fixed size limit'\n    }\n";
    const prepare = body => {
      const f = foundationFixture(t, { source: body, compatibility: true });
      const archive = f.archives[role], bytes = fs.readFileSync(archive);
      assert.ok(bytes.length < 8192);
      fs.appendFileSync(archive, Buffer.alloc(8193 - bytes.length, 120));
      const pin = JSON.parse(fs.readFileSync(path.join(f.scripts, 'ci-toolchain.json')));
      pin[role].linuxX64Sha256 = createHash('sha256').update(fs.readFileSync(archive)).digest('hex');
      fs.writeFileSync(path.join(f.scripts, 'ci-toolchain.json'), JSON.stringify(pin));
      f.fq40HashMarker = path.join(f.root, 'archive-hash-marker');
      const watched = path.join(f.runner, 'styleguide-node', role + '.tar.xz');
      const hashObserver = `function Get-FileHash {
[CmdletBinding()] param([string] $LiteralPath, [string] $Algorithm='SHA256')
if($LiteralPath -ceq ${quote(watched)}) { [IO.File]::WriteAllText(${quote(f.fq40HashMarker)},'reached') }
Microsoft.PowerShell.Utility\\Get-FileHash @PSBoundParameters
}
`;
      fs.writeFileSync(f.script, foundationOnce(fs.readFileSync(f.script, 'utf8'), 'function Install-ReviewedRuntime {', hashObserver + 'function Install-ReviewedRuntime {'));
      f.run(); return f;
    };
    fq40PostSizeOracle(prepare(source), role);
    const mutant = prepare(foundationOnce(source, guard, ''));
    assertCompletedProcess(mutant.result, 'FQ40 post-size omission');
    assert.equal(fs.existsSync(mutant.fq40HashMarker), true, 'Omission mutant must reach the real hash.');
    assert.equal(mutant.calls().some(row => row[0] === 'tar' && row[1] === role), true, 'Matching-digest mutant must reach listing.');
    assert.throws(() => fq40PostSizeOracle(mutant, role), assert.AssertionError);
  });
}
test('FQ40 valid preferred and recovery archives retain the production-size argv', { skip: !linux }, t => {
  const f = foundationFixture(t, { compatibility: true }); f.run();
  assertCompletedProcess(f.result, 'FQ40 valid two-role archive'); assert.equal(f.result.status, 0, f.result.stderr);
  const calls = f.calls().filter(row => row[0] === 'curl');
  assert.deepEqual(calls.map(row => row[1]), ['preferred', 'recoveryCompatibility']);
  for (const row of calls) { assert.equal(row.filter(value => value === '--max-filesize').length, 1); assert.equal(row[row.indexOf('--max-filesize') + 1], '67108864'); }
});


for (const role of ['preferred', 'recoveryCompatibility']) {
  test(`FQ40 download63 retains whole-initializer cleanup and publication refusal: ${role}`, { skip: !linux }, t => {
    const f = foundationFixture(t, { compatibility: true, mode: 'fq40-native63-' + role });
    f.run(); assertCompletedProcess(f.result, 'FQ40 injected process63 cleanup');
    assert.match(stripVTControlCharacters(f.result.stderr), new RegExp('Runtime download failed: 63 \\(' + role + '/linux-x64\\)', 'u'));
    assert.equal(f.calls().some(row => row.includes('ci')), false);
    assert.equal(f.calls().some(row => row[0] === 'tar' && row[1] === role), false);
    foundationNoPublication(f);
  });
}

// Actual curl native codes are not inferred from the PowerShell refusal status.
async function fq40NativeBoundary(t, framing, length, mutation = '', productionHeader = false, role = 'preferred') {
  const source = read('Initialize-CiToolchain.ps1'), cap = productionHeader ? 67108864 : 8192;
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'styleguide-curl-filesize-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const payload = Buffer.alloc(length, 120), requests = [], sockets = new Set();
  const server = createServer((req, res) => {
    requests.push(req.url); sockets.add(req.socket); req.socket.on('close', () => sockets.delete(req.socket));
    res.on('error', error => assert.ok(['ECONNRESET', 'EPIPE'].includes(error.code), error.message));
    if (framing === 'known' || framing === 'lying-high' || productionHeader) res.writeHead(200, { 'Content-Length': productionHeader ? cap + 1 : framing === 'lying-high' ? cap + 1 : length, Connection: 'close' });
    if (framing === 'lying-low') res.writeHead(200, { 'Content-Length': 4, Connection: 'close' });
    if (framing === 'partial') res.writeHead(200, { 'Content-Length': length + 20, Connection: 'close' });
    if (framing === 'close') { res.useChunkedEncodingByDefault = false; res.writeHead(200, { Connection: 'close' }); }
    if (framing === 'chunked') res.writeHead(200, { 'Transfer-Encoding': 'chunked' });
    if (framing === 'chunked-misleading-length') res.writeHead(200, { 'Transfer-Encoding': 'chunked', 'Content-Length': 4 });
    res.write(payload.subarray(0, Math.min(3, payload.length))); res.end(payload.subarray(3));
  });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  t.after(() => { for (const socket of sockets) socket.destroy(); server.closeAllConnections(); server.close(); });
  const endpoint = `http://127.0.0.1:${server.address().port}/archive`;
  let body = fq40Region(source, 'function Install-ReviewedRuntime {', 'if ((-not $IsLinux');
  body = foundationOnce(body, '$strDownloadAddress = "https://nodejs.org/dist/v$Version/$strReleaseRoot.$strArchiveSuffix"', `$strDownloadAddress = ${quote(endpoint)}`);
  body = foundationOnce(body, "--proto '=https'", "--proto '=http'");
  body = foundationOnce(body, "--proto-redir '=https'", "--proto-redir '=http'");
  const constant = fq40Constant(source, mutation === 'raised-cap' ? 16384 : cap);
  if (mutation === 'removed-flag') body = foundationOnce(body, '--max-filesize $intMaximumRuntimeArchiveBytes ', '');
  if (mutation === 'zero-flag') body = foundationOnce(body, '--max-filesize $intMaximumRuntimeArchiveBytes ', '--max-filesize 0 ');
  const resultFile = path.join(root, 'result.json'), marker = path.join(root, 'listing-marker'), scriptFile = path.join(root, 'boundary.ps1');
  const digest = createHash('sha256').update(payload).digest('hex');
  fs.writeFileSync(scriptFile, `Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$PSNativeCommandUseErrorActionPreference=$false
${constant}
${fq40Region(source, 'function Assert-CurlCapability {', 'function Install-ReviewedRuntime {')}
${body}
function New-PrivateDirectory { param($Path,[switch]$Confirm,[switch]$WhatIf) [void][IO.Directory]::CreateDirectory($Path) }
function Assert-OrdinaryPath { param($Path) if(-not [IO.File]::Exists($Path)){throw 'fixture: missing ordinary file'}; return $Path }
function Expand-ReviewedArchive { param($Archive,$Destination,$Release) [IO.File]::WriteAllText(${quote(marker)},'reached'); throw 'fixture: digest verified before listing' }
$strNodeRoot=${quote(root)}
$strCurlPath=if($IsWindows){Join-Path ([Environment]::SystemDirectory) 'curl.exe'}else{'/usr/bin/curl'}
Assert-CurlCapability -Path $strCurlPath -Windows:$IsWindows
$message=''
try { $null=Install-ReviewedRuntime -Role ${quote(role)} -Version ${quote(role === 'recoveryCompatibility' ? '22.23.3' : '24.18.1')} -NpmVersion ${quote(role === 'recoveryCompatibility' ? '10.9.9' : '11.16.0')} -Digest ${quote(digest)} }
catch { $message=$_.Exception.Message }
$archive=Join-Path $strNodeRoot (${quote(role)}+$(if($IsWindows){'.zip'}else{'.tar.xz'}))
[IO.File]::WriteAllText(${quote(resultFile)}, (ConvertTo-Json -InputObject ([ordered]@{command=$strCurlPath; status=$LASTEXITCODE; bytes=$(if([IO.File]::Exists($archive)){(Get-Item -LiteralPath $archive).Length}else{0}); message=$message; listing=[IO.File]::Exists(${quote(marker)})}) -Compress))
`);
  const env = { ...process.env, HOME: root, TMPDIR: root, TEMP: root, TMP: root, CURL_HOME: root,
    NO_PROXY: '127.0.0.1', no_proxy: '127.0.0.1', DOTNET_EnableDiagnostics: '0', POWERSHELL_DIAGNOSTICS_OPTOUT: '1' };
  for (const name of ['NODE_OPTIONS', 'NODE_PATH', 'GITHUB_TOKEN', 'GH_TOKEN', 'ACTIONS_RUNTIME_TOKEN', 'GIT_CONFIG_COUNT', 'GIT_CONFIG_PARAMETERS']) delete env[name];
  const result = await new Promise((resolve, reject) => {
    const child = spawn('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', scriptFile], { env, windowsHide: true });
    let stdout = '', stderr = '', failedBound = false;
    const timer = setTimeout(() => { failedBound = true; child.kill('SIGKILL'); }, 25000);
    child.stdout.on('data', bytes => { stdout += bytes; if(Buffer.byteLength(stdout) + Buffer.byteLength(stderr) > 1048576) { failedBound = true; child.kill('SIGKILL'); } });
    child.stderr.on('data', bytes => { stderr += bytes; if(Buffer.byteLength(stdout) + Buffer.byteLength(stderr) > 1048576) { failedBound = true; child.kill('SIGKILL'); } });
    child.on('error', error => { clearTimeout(timer); reject(error); });
    child.on('close', (status, signal) => { clearTimeout(timer); resolve({ stdout, stderr, status, signal, failedBound }); });
  });
  assert.equal(result.failedBound, false, 'FQ40 watchdog/output cap is always failure.');
  assertCompletedProcess(result, 'FQ40 actual download boundary'); assert.equal(result.status, 0, result.stdout + result.stderr);
  const raw = fs.readFileSync(resultFile); assert.ok(raw.length > 0 && raw.length <= 4096);
  const observed = JSON.parse(raw);
  assert.deepEqual(Object.keys(observed), ['command', 'status', 'bytes', 'message', 'listing']);
  const expectedCommand = process.platform === 'win32'
    ? path.join(process.env.SystemRoot, 'System32/curl.exe').replaceAll('/', '\\')
    : '/usr/bin/curl';
  if (process.platform === 'win32') {
    assert.equal(observed.command.toLowerCase(), expectedCommand.toLowerCase());
    const actualFile = fs.lstatSync(observed.command, { bigint: true });
    const expectedFile = fs.lstatSync(expectedCommand, { bigint: true });
    assert.equal(actualFile.isFile() && expectedFile.isFile(), true);
    assert.equal(actualFile.dev, expectedFile.dev);
    assert.ok(actualFile.ino > 0n);
    assert.equal(actualFile.ino, expectedFile.ino);
  } else assert.equal(observed.command, expectedCommand);
  assert.equal(Number.isInteger(observed.status), true); assert.equal(Number.isInteger(observed.bytes), true);
  assert.deepEqual(requests, ['/archive'], 'No default curlrc URL or automatic repeat is allowed.');
  return { observed, cap, length };
}
function fq40NativeOracle(cell, framing, exceeds) {
  const { observed, cap, length } = cell;
  const expected = exceeds ? 63 : framing === 'partial' ? 18 : 0;
  assert.equal(observed.status, expected, 'Actual curl native filesize/partial/success code must match.');
  assert.ok(observed.bytes <= cap, 'Actual output must never exceed the admitted compressed cap.');
  if (exceeds) { assert.match(observed.message, /Runtime download failed: 63/u); assert.equal(observed.listing, false); }
  else if (framing === 'partial') { assert.match(observed.message, /Runtime download failed: 18/u); assert.equal(observed.listing, false); }
  else if (framing === 'lying-low') { assert.equal(observed.bytes, 4); assert.match(observed.message, /archive digest is incorrect/u); assert.equal(observed.listing, false); }
  else { assert.equal(observed.bytes, length); assert.equal(observed.listing, true, 'Only complete matching bytes may reach the isolated listing boundary.'); }
}
for (const framing of ['known', 'close', 'chunked']) for (const delta of [-1, 0, 1]) {
  test(`FQ40 actual compressed-byte boundary: ${framing}/${delta}`, { skip: !linux && process.platform !== 'win32', timeout: 90000 }, async t => {
    for (const role of linux ? ['preferred', 'recoveryCompatibility'] : ['preferred']) {
      fq40NativeOracle(await fq40NativeBoundary(t, framing, 8192 + delta, '', false, role), framing, delta > 0);
    }
  });
}
for (const framing of ['lying-low', 'lying-high', 'partial']) {
  test(`FQ40 actual compressed-byte framing refusal: ${framing}`, { skip: !linux && process.platform !== 'win32', timeout: 90000 }, async t => {
    fq40NativeOracle(await fq40NativeBoundary(t, framing, framing === 'lying-low' ? 65536 : 16), framing, framing === 'lying-high');
  });
}
test('FQ40 chunked body with misleading Content-Length remains bounded', { skip: !linux && process.platform !== 'win32', timeout: 90000 }, async t => {
  const { observed, cap } = await fq40NativeBoundary(t, 'chunked-misleading-length', 8193);
  assert.ok([8, 63].includes(observed.status), 'Require a completed curl framing or filesize refusal, not a transport failure.');
  assert.ok(observed.bytes >= 0 && observed.bytes <= cap);
  assert.match(observed.message, /^Runtime download failed: (?:8|63) \(preferred\/(?:win|linux)-x64\)$/u);
  assert.equal(observed.listing, false, 'Mixed framing must not reach archive listing.');
});
test('FQ40 production compressed-byte cap refuses a declared oversized response', { skip: !linux && process.platform !== 'win32', timeout: 90000 }, async t => {
  fq40NativeOracle(await fq40NativeBoundary(t, 'known', 1, '', true), 'known', true);
});
for (const mutation of ['removed-flag', 'zero-flag', 'raised-cap']) {
  test(`FQ40 compressed-byte mutation witness: ${mutation}`, { skip: !linux && process.platform !== 'win32', timeout: 90000 }, async t => {
    const good = await fq40NativeBoundary(t, 'chunked', 8193); fq40NativeOracle(good, 'chunked', true);
    const bad = await fq40NativeBoundary(t, 'chunked', 8193, mutation);
    assert.equal(bad.observed.status, 0, 'Weak native bound must complete as actual curl0, not a watchdog/native63.');
    assert.equal(bad.observed.bytes, 8193);
    assert.throws(() => fq40NativeOracle(bad, 'chunked', true), assert.AssertionError);
  });
}
