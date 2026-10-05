import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { checkInstallInputs, runBounded, safeNpmEnvironment, withNpmEnvironment } from './NpmTools.mjs';

test('every npm configuration spelling is removed before the first npm child', () => {
  const original = { PATH: 'existing', NPM_CONFIG_SCRIPT_SHELL: 'hostile', npm_config_omit: 'dev',
    NpM_CoNfIg_USERCONFIG: 'private', npm_config_registry: 'https://invalid.example/', HUSKY: '0' };
  const safe = safeNpmEnvironment(original, path.resolve('fixture'));
  assert.equal(safe.NPM_CONFIG_SCRIPT_SHELL, undefined);
  assert.equal(safe.npm_config_omit, undefined);
  assert.equal(safe.NpM_CoNfIg_USERCONFIG, undefined);
  assert.equal(safe.npm_config_registry, 'https://registry.npmjs.org/');
  assert.equal(safe.npm_config_ignore_scripts, 'true');
  assert.equal(safe.HUSKY, '0');
  assert.equal(original.NPM_CONFIG_SCRIPT_SHELL, 'hostile');
  assert.notEqual(safe.npm_config_userconfig, safe.npm_config_globalconfig);
});

test('bounded children preserve native nonzero status but reject launch, timeout and output failures', () => {
  assert.equal(runBounded(process.execPath, ['-e', 'process.exit(7)']).status, 7);
  assert.throws(() => runBounded(path.resolve('absent-node-command'), []), /Process failed/u);
  assert.throws(() => runBounded(process.execPath, ['-e', 'setInterval(()=>{},1000)'], { timeout: 100 }), /timed out after 0.1 seconds/u);
  assert.throws(() => runBounded(process.execPath, ['-e', "const fs=require('fs');fs.writeSync(2,'native timeout cause');fs.writeSync(1,'x'.repeat(10000));setInterval(()=>{},1000)"], { timeout: 1000 }), error => {
    assert.match(error.message, /timed out after 1 seconds/u);
    assert.match(error.message, /native timeout cause/u);
    assert.ok(error.message.length < 8300);
    assert.doesNotMatch(error.message, /x{4097}/u);
    return true;
  });
  assert.throws(() => runBounded(process.execPath, ['-e', "process.stdout.write('x'.repeat(50000))"], { maxBuffer: 1024 }), /Process failed/u);
});

function inputFixture() {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'npm-input-test-'));
  fs.mkdirSync(path.join(root, '.github/workflows'), { recursive: true });
  for (const relative of ['package.json', 'package-lock.json', '.github/workflows/package.json', '.github/workflows/package-lock.json']) {
    fs.writeFileSync(path.join(root, relative), JSON.stringify({ engines: { node: process.versions.node, npm: '11.16.0' } }));
  }
  return root;
}

function removeFixture(root) {
  assert.equal(fs.realpathSync(path.dirname(root)), fs.realpathSync(os.tmpdir()));
  assert.ok(path.basename(root).startsWith('npm-input-test-'));
  fs.rmSync(root, { recursive: true });
}

test('actual archive installer reports that no Git hook was installed', () => {
  const root = inputFixture();
  try {
    const script = path.join(root, '.github/workflows/install-husky.mjs');
    fs.copyFileSync(fileURLToPath(new URL('./install-husky.mjs', import.meta.url)), script);
    const env = { ...process.env }; delete env.CI; delete env.HUSKY; delete env.NODE_ENV;
    const result = runBounded(process.execPath, [script], { cwd: root, env });
    assert.equal(result.status, 0);
    assert.match(result.stdout.toString(), /no Git hook was installed/u);
    assert.equal(fs.existsSync(path.join(root, '.git')), false);
    assert.equal(fs.existsSync(path.join(root, '.husky')), false);
  } finally { removeFixture(root); }
});

test('configuration and alternate lock selectors are rejected before npm', () => {
  const root = inputFixture();
  try {
    assert.equal(checkInstallInputs(root).size, 4);
    for (const relative of ['.npmrc', '.github/.npmrc', '.github/workflows/.npmrc',
      'npm-shrinkwrap.json', '.github/workflows/npm-shrinkwrap.json']) {
      const file = path.join(root, relative);
      fs.writeFileSync(file, '');
      assert.throws(() => checkInstallInputs(root), /Unsupported npm input/u);
      fs.unlinkSync(file);
    }
  } finally { removeFixture(root); }
});

test('actual installer activates in CI and production unless explicitly disabled', () => {
  for (const context of [{}, { CI: 'true' }, { NODE_ENV: 'production' },
    { CI: 'true', NODE_ENV: 'production' }, { CI: 'true', NODE_ENV: 'production', HUSKY: '0' }]) {
    const root = inputFixture();
    try {
      const workflows = path.join(root, '.github/workflows');
      fs.copyFileSync(fileURLToPath(new URL('./install-husky.mjs', import.meta.url)), path.join(workflows, 'install-husky.mjs'));
      fs.cpSync(fileURLToPath(new URL('./node_modules/husky', import.meta.url)), path.join(workflows, 'node_modules/husky'), { recursive: true });
      const env = { ...process.env };
      for (const key of Object.keys(env)) {
        if (/^(?:CI|NODE_ENV|HUSKY)$/iu.test(key) || /^GIT_/iu.test(key)) delete env[key];
      }
      Object.assign(env, context);
      const initialized = runBounded('git', ['init', '--quiet', root], { env });
      assert.equal(initialized.status, 0, initialized.stderr.toString());
      const result = runBounded(process.execPath, [path.join(workflows, 'install-husky.mjs')], { cwd: root, env });
      assert.equal(result.status, 0, result.stderr.toString());
      const setting = runBounded('git', ['config', '--local', '--get', 'core.hooksPath'], { cwd: root, env });
      const suppressed = context.HUSKY === '0';
      assert.equal(setting.status, suppressed ? 1 : 0, JSON.stringify(context));
      assert.equal(setting.stdout.toString().trim(), suppressed ? '' : '.husky/_', JSON.stringify(context));
      assert.equal(fs.existsSync(path.join(root, '.husky/_/pre-commit')), !suppressed, JSON.stringify(context));
    } finally { removeFixture(root); }
  }
});

test('real bundled npm version runs with isolated configuration and temporary files are cleaned', () => {
  const root = inputFixture();
  let directory;
  try {
    const value = withNpmEnvironment(({ env, runNpm }) => {
      directory = path.dirname(env.npm_config_userconfig);
      assert.equal(fs.readFileSync(env.npm_config_userconfig).length, 0);
      const result = runNpm(['config', 'get', 'ignore-scripts']);
      assert.equal(result.status, 0);
      assert.equal(result.stdout.toString().trim(), 'true');
      return 17;
    }, { root, environment: { ...process.env, NPM_CONFIG_SCRIPT_SHELL: 'hostile', npm_config_registry: 'https://invalid.example/' } });
    assert.equal(value, 17);
    assert.equal(fs.existsSync(directory), false);
    assert.throws(() => withNpmEnvironment(() => { throw new Error('test callback failure'); }, { root }), /test callback failure/u);
  } finally { removeFixture(root); }
});

test('runtime errors distinguish invalid declarations and required versus observed versions', () => {
  const root = inputFixture();
  const manifest = path.join(root, 'package.json');
  try {
    fs.writeFileSync(manifest, '{}');
    assert.throws(() => withNpmEnvironment(() => {}, { root }), /must declare exact Node and npm/u);
    fs.writeFileSync(manifest, JSON.stringify({ engines: { node: '0.0.0', npm: '11.16.0' } }));
    assert.throws(() => withNpmEnvironment(() => {}, { root }), error =>
      error.message === `Node 0.0.0 is required; observed ${process.versions.node}.`);
    fs.writeFileSync(manifest, JSON.stringify({ engines: { node: process.versions.node, npm: '0.0.0' } }));
    assert.throws(() => withNpmEnvironment(() => {}, { root }), /Bundled npm 0\.0\.0 is required; observed "11\.16\.0"/u);
  } finally { removeFixture(root); }
});

function emptyInstallFixture() {
  const root = inputFixture();
  for (const directory of [root, path.join(root, '.github/workflows')]) {
    const manifest = { name: 'setup-diagnostic-fixture', version: '1.0.0',
      engines: { node: process.versions.node, npm: '11.16.0' } };
    fs.writeFileSync(path.join(directory, 'package.json'), JSON.stringify(manifest));
    fs.writeFileSync(path.join(directory, 'package-lock.json'), JSON.stringify({ ...manifest,
      lockfileVersion: 3, requires: true, packages: { '': manifest } }));
  }
  return root;
}

function runBootstrap(root) {
  const source = `import { bootstrap } from ${JSON.stringify(new URL('./NpmTools.mjs', import.meta.url).href)};
    try { bootstrap({ root: ${JSON.stringify(root)} }); }
    catch (error) { console.error(error.message); process.exitCode = 2; }`;
  return runBounded(process.execPath, ['--input-type=module', '-e', source], { cwd: root });
}

test('actual install child uses npm download defaults while other children retain audit limits', () => {
  const root = emptyInstallFixture();
  try {
    // Observe only the two task-owned settings in actual child processes.
    const probe = path.join(root, 'network-environment.cjs');
    fs.writeFileSync(probe, `if (process.argv[2] !== '--version') console.log('NETWORK_ENV=' + JSON.stringify({
      timeout: process.env.npm_config_fetch_timeout ?? null,
      retries: process.env.npm_config_fetch_retries ?? null
    }));`);
    withNpmEnvironment(({ runNpm }) => {
      const inspect = args => {
        const result = runNpm(args);
        assert.equal(result.status, 0, result.stderr.toString());
        const line = result.stdout.toString().split(/\r?\n/u).find(value => value.startsWith('NETWORK_ENV='));
        return JSON.parse(line.slice('NETWORK_ENV='.length));
      };
      assert.deepEqual(inspect(['ci', '--dry-run']), { timeout: null, retries: null });
      assert.deepEqual(inspect(['config', 'get', 'fetch-timeout']), { timeout: '30000', retries: '1' });
    }, { root, environment: { ...process.env, NODE_OPTIONS: `--require ${JSON.stringify(probe)}` } });
  } finally { removeFixture(root); }
});

test('actual stale-lock installation exposes npm cause and does not claim setup success', () => {
  const root = emptyInstallFixture();
  try {
    const file = path.join(root, 'package.json');
    const manifest = JSON.parse(fs.readFileSync(file, 'utf8'));
    manifest.dependencies = { 'local-diagnostic-fixture': 'file:./local-package' };
    fs.mkdirSync(path.join(root, 'local-package'));
    fs.writeFileSync(path.join(root, 'local-package/package.json'), JSON.stringify({ name: 'local-diagnostic-fixture', version: '1.0.0' }));
    fs.writeFileSync(file, JSON.stringify(manifest));
    const result = runBootstrap(root);
    assert.equal(result.status, 2);
    const stderr = result.stderr.toString();
    assert.match(stderr, /EUSAGE/u);
    assert.match(stderr, /Missing: local-diagnostic-fixture/u);
    assert.match(stderr, /Correct the reported cause/u);
    assert.doesNotMatch(result.stdout.toString(), /Locked tools installed/u);
  } finally { removeFixture(root); }
});

test('actual hook child failure exposes stderr and cannot claim setup success', () => {
  const root = emptyInstallFixture();
  try {
    // Both empty locked installs succeed; the deliberately absent hook entry fails in Node.
    const result = runBootstrap(root);
    assert.equal(result.status, 2);
    assert.match(result.stderr.toString(), /MODULE_NOT_FOUND/u);
    assert.match(result.stderr.toString(), /install-husky\.mjs/u);
    assert.match(result.stderr.toString(), /Hook installation failed/u);
    assert.doesNotMatch(result.stdout.toString(), /Locked tools installed/u);
  } finally { removeFixture(root); }
});

const entryModules = [
  ['lint-markdown.mjs', 2, /Usage: node .*lint-markdown\.mjs/u],
  ['NpmTools.mjs', 2, /Usage: node .*NpmTools\.mjs install/u],
  ['Check-NpmAudit.mjs', 2, /Usage: node .*Check-NpmAudit\.mjs/u],
  ['Classify-InstructionMaintenance.mjs', 1, /Usage: node Classify-InstructionMaintenance\.mjs/u],
  ['Validate-WorkflowPolicy.mjs', 1, /"category":"arguments"/u],
];

function entryFixture() {
  const root = inputFixture(), alias = `${root}-alias`;
  for (const [name] of entryModules) {
    fs.copyFileSync(fileURLToPath(new URL(name, import.meta.url)), path.join(root, '.github/workflows', name));
  }
  fs.symlinkSync(root, alias, process.platform === 'win32' ? 'junction' : 'dir');
  return { root, alias };
}

for (const [name, status, diagnostic] of entryModules) {
  test(`linked command entry preserves argument errors: ${name}`, () => {
    const { root, alias } = entryFixture();
    try {
      for (const directory of [root, alias]) {
        const result = runBounded(process.execPath, [path.join(directory, '.github/workflows', name), '--invalid-entry-test'], { cwd: directory });
        assert.equal(result.status, status, result.stdout.toString() + result.stderr.toString());
        assert.match(result.stdout.toString() + result.stderr.toString(), diagnostic);
      }
    } finally { fs.unlinkSync(alias); removeFixture(root); }
  });

  test(`module imports remain inert with absent or misleading argv: ${name}`, () => {
    const { root, alias } = entryFixture();
    try {
      const script = path.join(root, '.github/workflows', name);
      const linkedScript = path.join(alias, '.github/workflows', name);
      for (const argv of [undefined, '', path.join(root, 'absent.mjs'), script, linkedScript]) {
        const setArgv = argv === undefined ? 'delete process.argv[1];' : `process.argv[1] = ${JSON.stringify(argv)};`;
        const copiedSource = `${setArgv} await import(${JSON.stringify(pathToFileURL(script).href)}); console.log('ENTRY_IMPORT_ONLY');`;
        const result = runBounded(process.execPath, ['--input-type=module', '-e', copiedSource], { cwd: root });
        assert.equal(result.status, 0, result.stderr.toString());
        assert.equal(result.stdout.toString(), 'ENTRY_IMPORT_ONLY\n');
        assert.equal(result.stderr.toString(), '');
      }
    } finally { fs.unlinkSync(alias); removeFixture(root); }
  });
}
