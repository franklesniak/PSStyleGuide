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

function fixture(t) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'styleguide-ci-test-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const work = path.join(root, 'work'); fs.mkdirSync(work);
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
