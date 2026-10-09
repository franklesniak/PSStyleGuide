import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawn, spawnSync } from 'node:child_process';
import { createServer } from 'node:http';
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

// The bridge keeps its flat producer. Future schema2 is inert fixture input only.
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
    for (const name of ['GITHUB_TOKEN', 'GH_TOKEN', 'ACTIONS_RUNTIME_TOKEN',
      'GIT_CONFIG_COUNT', 'GIT_CONFIG_PARAMETERS']) {
      if (!Object.hasOwn(env, name)) delete environment[name];
    }
    return spawnSync('pwsh', ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', script], {
      cwd: work, env: environment, encoding: 'utf8', timeout: 30000,
    });
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

for (const mode of ['', 'outer-failure', 'nested-failure']) {
  test(`lint records both native results: ${mode || 'success'}`, { skip: !linux }, t => {
    const f = fixture(t), workflows = path.join(f.work, '.github/workflows');
    fs.mkdirSync(workflows, { recursive: true });
    fs.writeFileSync(path.join(workflows, 'Test-CheckoutCredentials.ps1'),
      read('Test-CheckoutCredentials.ps1').replaceAll('/usr/bin/git', f.git).replaceAll("'/bin/git'", quote(f.git)));
    fs.copyFileSync(path.join(directory, 'Invoke-MarkdownLint.ps1'), path.join(workflows, 'Invoke-MarkdownLint.ps1'));
    const bin = path.join(f.root, 'styleguide-node/bin'); fs.mkdirSync(bin, { recursive: true });
    fs.writeFileSync(path.join(bin, 'npm'), `#!${process.execPath}
const fs = require('node:fs'), args = process.argv.slice(2);
fs.appendFileSync(process.env.TEST_LOG, JSON.stringify(['npm', ...args])+'\\n');
if (process.env.npm_config_script_shell || process.env.NPM_CONFIG_SCRIPT_SHELL ||
  process.env.npm_config_userconfig !== '/dev/null' ||
  process.env.npm_config_globalconfig !== '/etc/npmrc-absent-by-policy') process.exit(97);
if (process.env.TEST_MODE === 'outer-failure' && args.at(-1) === 'lint:md') process.exit(5);
if (process.env.TEST_MODE === 'nested-failure' && args.at(-1) === 'lint:md:nested') process.exit(6);
`, { mode: 0o700 });
    const result = f.run(`& ${quote(path.join(workflows, 'Invoke-MarkdownLint.ps1'))}`, {
      TEST_MODE: mode, npm_config_userconfig: '/dev/null',
      npm_config_globalconfig: '/etc/npmrc-absent-by-policy', NPM_CONFIG_SCRIPT_SHELL: 'hostile',
    });
    assert.equal(result.status === 0, mode === '', result.stderr);
    assert.ok(result.stdout.includes(`Markdown exits: outer=${mode === 'outer-failure' ? 5 : 0} nested=${mode === 'nested-failure' ? 6 : 0}`), result.stdout);
    assert.deepEqual(f.calls().filter(row => row[0] === 'npm').map(row => row.at(-1)), ['lint:md', 'lint:md:nested']);
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
  const bin = path.join(archiveRoot, 'runtime/bin'); fs.mkdirSync(bin, { recursive: true });
  for (const executable of ['node', 'npm']) {
    fs.writeFileSync(path.join(bin, executable), `#!${process.execPath}
const fs = require('node:fs'), args = process.argv.slice(2);
fs.appendFileSync(process.env.TEST_LOG, JSON.stringify(['${executable}', ...args])+'\\n');
if ('${executable}' === 'npm') {
  if (process.env.NPM_CONFIG_SCRIPT_SHELL || process.env.npm_config_script_shell ||
      process.env.npm_config_userconfig !== '/dev/null' ||
      process.env.npm_config_globalconfig !== '/etc/npmrc-absent-by-policy' ||
      process.env.npm_config_ignore_scripts !== 'true') process.exit(97);
  if (args.includes('ci') && !args.includes('--ignore-scripts')) process.exit(98);
}
if (args.includes('--version')) console.log('${executable === 'node' ? (mode === 'wrong-node' ? 'v0.0.0' : 'v' + selectedNode) : (mode === 'wrong-npm' ? '0.0.0' : selectedNpm)}');
`, { mode: 0o700 });
  }
  const archive = path.join(f.root, 'fixture.tar.xz');
  const tar = spawnSync('/usr/bin/tar', ['-cJf', archive, '-C', archiveRoot, 'runtime'], { encoding: 'utf8' });
  assert.equal(tar.status, 0, tar.stderr);
  fs.writeFileSync(path.join(workflows, 'ci-toolchain.json'), JSON.stringify({
    linuxX64Sha256: createHash('sha256').update(fs.readFileSync(archive)).digest('hex') }));
  const curl = path.join(f.root, 'curl');
  fs.writeFileSync(curl, `#!${process.execPath}
const fs = require('node:fs'), args = process.argv.slice(2);
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
    ['--version', '--version', '--preflight', 'ci', 'ci']);
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

  const archiveRoot = path.join(f.root, 'archive'), bin = path.join(archiveRoot, 'runtime/bin');
  fs.mkdirSync(bin, { recursive: true });
  fs.symlinkSync(process.execPath, path.join(bin, 'node'));
  fs.writeFileSync(path.join(bin, 'npm'), `#!${process.execPath}
const fs = require('node:fs'), args = process.argv.slice(2);
fs.appendFileSync(process.env.TEST_LOG, JSON.stringify(['npm', ...args])+'\\n');
if (args.includes('--version')) console.log('${rootManifest.engines.npm}');
`, { mode: 0o700 });
  const archive = path.join(f.root, 'runtime.tar.xz');
  const tar = spawnSync('/usr/bin/tar', ['-cJf', archive, '-C', archiveRoot, 'runtime'], { encoding: 'utf8' });
  assert.equal(tar.status, 0, tar.stderr);
  fs.writeFileSync(path.join(workflows, 'ci-toolchain.json'), JSON.stringify({
    linuxX64Sha256: createHash('sha256').update(fs.readFileSync(archive)).digest('hex') }));
  const curl = path.join(f.root, 'curl');
  fs.writeFileSync(curl, `#!${process.execPath}
const fs = require('node:fs'), args = process.argv.slice(2);
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
  fs.rmSync(path.join(f.root, 'styleguide-node.tar.xz'), { force: true });
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
    return spawnSync(step.shell === 'pwsh' ? 'pwsh' : 'bash', step.shell === 'pwsh'
      ? ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', file] : ['--noprofile', '--norc', file],
    { cwd: work, env: { ...env, ...extra }, encoding: 'utf8', timeout: 45000 });
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
  if (kind === 'declared') f.put('.github/workflows/ci-toolchain.json', JSON.stringify({ linuxX64Sha256: 'a'.repeat(64) }));
  if (kind !== 'historical') for (const name of copilotFullInputs) f.put(name);
}
for (const kind of ['declared', 'pre-declaration', 'historical', 'legacy', 'historical-full']) {
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
const malformedRuntimeDeclarations = () => {
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
for (const workflow of ['copilot-setup-steps.yml', 'copilot-code-review.yml']) {
  test(`${workflow}: whole malformed declaration rejects before curl at both sites`, { skip: !linux }, t => {
    const job = parse(read(workflow)).jobs['copilot-setup-steps'];
    for (const raw of malformedRuntimeDeclarations()) {
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
