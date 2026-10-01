import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import { createRequire } from 'node:module';
import { createHash } from 'node:crypto';
import test from 'node:test';

// These tests execute the actual loader/helper bodies with fixed external-tool
// replacements. They test control flow; real locked installation is tested separately.
const directory = path.dirname(fileURLToPath(import.meta.url));
const { parse } = createRequire(import.meta.url)('yaml');
const linux = process.platform === 'linux';
const head = 'a'.repeat(40), base = 'b'.repeat(40);
const read = name => fs.readFileSync(path.join(directory, name), 'utf8');
const quote = value => `'${value.replaceAll("'", "''")}'`;

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

for (const [file, job] of [['build.yml', 'verify_generated_artifacts'],
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
  const source = parse(read('build.yml')).jobs.verify_generated_artifacts.steps[0].run;
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
  for (const variable of variables) test(`${file}: missing ${variable} fails before external work`, { skip: !linux }, t => {
    const f = fixture(t);
    const helper = path.join(f.root, file);
    fs.writeFileSync(helper, read(file));
    const result = f.run(`& ${quote(helper)}`, { [variable]: '' });
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, new RegExp('requires the runner environment variable ' + variable));
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

for (const mode of ['clean', 'stale', 'semantic-failure', 'semantic-side-effect',
  'verifier-channel', 'verifier-config', 'verifier-worktree', 'verifier-failure']) {
  test(`artifact gate includes verifier child effects: ${mode}`, { skip: !linux }, t => {
    const root = fs.mkdtempSync(path.join(os.tmpdir(), 'styleguide-artifact-child-'));
    t.after(() => fs.rmSync(root, { recursive: true, force: true }));
    const work = path.join(root, 'work'), scripts = path.join(work, '.github/workflows');
    fs.mkdirSync(scripts, { recursive: true });
    const records = [['copilot', 'copilot-instructions.md'], ['powershell-instructions', 'powershell.instructions.md'],
      ['chat', 'STYLE_GUIDE_CHAT.md'], ['full', 'STYLE_GUIDE_FULL.md']];
    for (const [, name] of records) fs.writeFileSync(path.join(work, name), 'committed fixture\n');
    fs.writeFileSync(path.join(scripts, 'Test-StyleGuideArtifacts.ps1'), read('Test-StyleGuideArtifacts.ps1'));
    fs.writeFileSync(path.join(work, 'STYLE_GUIDE.md'), [
      '# PowerShell Writing Style', '',
      '### Examples', '',
      '**Compliant example:**', '',
      '```powershell', '{', '    Invoke-First', '', '    Invoke-Second', '}', '```', '',
      '**Non-Compliant example:**', '',
      'The `␠` glyph is an illustration marker and is not PowerShell syntax. Do not copy it.', '',
      '```powershell', '{', '    Invoke-First', '␠', '    Invoke-Second', '}', '```', '',
    ].join('\n'));
    fs.copyFileSync(path.join(directory, 'Test-BlankLineExamples.ps1'),
      path.join(scripts, 'Test-BlankLineExamples.ps1'));
    const generation = { Schema: 'PSStyleGuide.GeneratorResult.v2', Overall: 'NoChange', Phase: 'complete',
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
    if (mode === 'semantic-side-effect') {
      fs.writeFileSync(path.join(scripts, 'Test-BlankLineExamples.ps1'),
        "[IO.File]::WriteAllText('unexpected.txt', 'changed by semantic verifier')\n" +
        "Write-Output 'Blank-line example semantics passed, including focused mutation checks.'\nexit 0\n");
    }
    if (mode === 'semantic-failure') {
      fs.writeFileSync(path.join(work, 'STYLE_GUIDE.md'),
        fs.readFileSync(path.join(work, 'STYLE_GUIDE.md'), 'utf8').replace('\n␠\n', '\n\n'));
    }
    const verifierFails = ['stale', 'verifier-failure'].includes(mode);
    fs.writeFileSync(path.join(scripts, 'Test-ExactGitPathSet.ps1'), mutation + '\n' +
      quote(JSON.stringify({ Schema: 'PSStyleGuide.ExactGitPathSetResult.v2', Success: !verifierFails })) +
      `\nexit ${verifierFails ? 1 : 0}\n`);
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
      'semantic-side-effect': /outside the four[\s\S]{0,100}generated artifacts/,
      'verifier-channel': /runner-state/, 'verifier-config': /configuration or hooks/,
      'verifier-worktree': /outside the four/, 'verifier-failure': /Exact-path verification did not confirm/ }[mode];
    const diagnostic = result.stdout + result.stderr;
    assert.match(mode === 'semantic-side-effect'
      ? diagnostic.replace(/\x1B\[[0-?]*[ -/]*[@-~]/g, '')
      : diagnostic, expected);
  });
}

for (const mode of ['fetch-failure', 'retry-success', 'checkout-failure']) {
  test(`Copilot acquisition retry: ${mode}`, { skip: !linux }, t => {
    const source = parse(read('copilot-setup-steps.yml')).jobs['copilot-setup-steps'].steps.find(step => step.id === 'acquire').run;
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
  test(`Copilot Git identity failure: ${mode || 'success'}`, { skip: !linux }, t => {
    const source = parse(read('copilot-setup-steps.yml')).jobs['copilot-setup-steps'].steps.find(step => step.id === 'acquire').run;
    const f = fixture(t), result = f.run(source, { TEST_MODE: mode });
    assert.equal(result.status === 0, mode === '', result.stderr);
    assert.equal(f.calls().filter(row => row.includes('checkout')).length, 1);
    if (mode === 'identity-native-failure') assert.match(result.stderr, /git rev-parse exited 31/);
    if (['identity-multiline', 'empty-output'].includes(mode)) assert.match(result.stderr, /exactly one line/);
    if (mode === 'wrong-head') assert.match(result.stderr, /not the triggering revision/);
  });
}

for (const mode of ['', 'download-failure', 'version-failure', 'version-empty', 'version-multiline', 'version-wrong']) {
  test(`Copilot runtime failure: ${mode || 'success'}`, { skip: !linux }, t => {
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
    fs.writeFileSync(path.join(workflows, 'ci-toolchain.json'), JSON.stringify({
      linuxX64Sha256: createHash('sha256').update(fs.readFileSync(archive)).digest('hex') }));
    const curl = path.join(f.root, 'curl');
    fs.writeFileSync(curl, `#!${process.execPath}
const fs = require('node:fs'), args = process.argv.slice(2);
fs.appendFileSync(process.env.TEST_LOG, JSON.stringify(['curl', ...args])+'\\n');
if (process.env.TEST_MODE === 'download-failure') process.exit(28);
fs.copyFileSync(${JSON.stringify(archive)}, args[args.indexOf('--output') + 1]);
`, { mode: 0o700 });
    const source = parse(read('copilot-setup-steps.yml')).jobs['copilot-setup-steps'].steps
      .find(step => step.name === 'Set up verified official Node.js runtime').run
      .replaceAll("'/usr/bin/curl'", quote(curl)).replaceAll("'/bin/curl'", quote(curl));
    const result = f.run(source, { TOOLCHAIN_LAYOUT: 'modern', TEST_MODE: mode });
    assert.equal(result.status === 0, mode === '', result.stderr);
    const request = f.calls().find(row => row[0] === 'curl');
    assert.ok(request.includes('--retry-all-errors'));
    assert.ok(request.includes('--tlsv1.2'));
    assert.equal(request.at(-1), `https://nodejs.org/dist/v${manifest.engines.node}/node-v${manifest.engines.node}-linux-x64.tar.xz`);
    for (const [flag, value] of [['--proto', '=https'], ['--proto-redir', '=https'], ['--retry', '3'], ['--connect-timeout', '20'], ['--max-time', '120'], ['--retry-max-time', '300']]) {
      assert.ok(request.includes(flag), `Missing curl option: ${flag}`);
      assert.equal(request[request.indexOf(flag) + 1], value);
    }
    if (mode === 'download-failure') assert.match(result.stderr, /download exited 28/);
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
  test(`Copilot npm configuration in each process: ${stepName}`, { skip: !linux }, t => {
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
    const steps = parse(read('copilot-setup-steps.yml')).jobs['copilot-setup-steps'].steps;
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

test('Copilot npm rejects failed or partial environment enumeration before npm', { skip: !linux }, t => {
  const steps = parse(read('copilot-setup-steps.yml')).jobs['copilot-setup-steps'].steps;
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
