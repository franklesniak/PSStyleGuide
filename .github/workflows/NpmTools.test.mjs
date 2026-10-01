import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
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
  assert.throws(() => runBounded(process.execPath, ['-e', 'setInterval(()=>{},1000)'], { timeout: 100 }), /Process failed/u);
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
  assert.equal(path.dirname(root), fs.realpathSync(os.tmpdir()));
  assert.ok(path.basename(root).startsWith('npm-input-test-'));
  fs.rmSync(root, { recursive: true });
}

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
