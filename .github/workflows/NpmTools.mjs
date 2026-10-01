import { spawnSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

export const repositoryRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
export const processLimits = Object.freeze({ timeout: 120000, maxBuffer: 2 * 1024 * 1024 });

export function runBounded(executable, args, options = {}) {
  const result = spawnSync(executable, args, {
    cwd: repositoryRoot, windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'],
    ...processLimits, killSignal: 'SIGKILL', ...options,
  });
  if (result.error || result.signal || !Number.isInteger(result.status)) {
    const cause = result.error?.code === 'ETIMEDOUT'
      ? `Process timed out after ${(options.timeout ?? processLimits.timeout) / 1000} seconds.`
      : `Process failed (${result.error?.code || result.signal || 'missing status'}).`;
    const details = [result.stderr, result.stdout]
      .map(output => output?.toString('utf8').slice(0, 4096).trim()).filter(Boolean).join('\n');
    throw new Error(`${cause}${details ? `\n${details}` : ''}`);
  }
  return result;
}

export function safeNpmEnvironment(environment, directory) {
  const safe = Object.fromEntries(Object.entries(environment).filter(([key]) => !/^npm_config_/iu.test(key)));
  Object.assign(safe, {
    npm_config_userconfig: path.join(directory, 'user.npmrc'),
    npm_config_globalconfig: path.join(directory, 'global.npmrc'),
    npm_config_registry: 'https://registry.npmjs.org/',
    npm_config_ignore_scripts: 'true', npm_config_audit: 'false', npm_config_fund: 'false',
    npm_config_fetch_retries: '1', npm_config_fetch_timeout: '30000',
  });
  const pathKey = Object.keys(safe).find(key => key.toLowerCase() === 'path') || 'PATH';
  safe[pathKey] = path.dirname(process.execPath) + path.delimiter + (safe[pathKey] || '');
  return safe;
}

function ordinaryFile(file, limit = 1024 * 1024) {
  const metadata = fs.lstatSync(file);
  if (!metadata.isFile() || metadata.isSymbolicLink() || metadata.size > limit) {
    throw new Error(`Expected a bounded regular file: ${path.basename(file)}`);
  }
  return fs.readFileSync(file);
}

export function checkInstallInputs(root) {
  for (const name of ['.github', '.github/workflows']) {
    const metadata = fs.lstatSync(path.join(root, name));
    if (!metadata.isDirectory() || metadata.isSymbolicLink()) throw new Error('Package directories must be ordinary directories.');
  }
  for (const name of ['.npmrc', '.github/.npmrc', '.github/workflows/.npmrc',
    'npm-shrinkwrap.json', '.github/workflows/npm-shrinkwrap.json']) {
    try { fs.lstatSync(path.join(root, name)); }
    catch (error) { if (error.code === 'ENOENT') continue; throw error; }
    throw new Error(`Unsupported npm input: ${name}`);
  }
  return new Map(['package.json', 'package-lock.json', '.github/workflows/package.json',
    '.github/workflows/package-lock.json'].map(name => [name, ordinaryFile(path.join(root, name))]));
}

export function withNpmEnvironment(callback, { root = repositoryRoot, environment = process.env } = {}) {
  const inputs = checkInstallInputs(root);
  const engines = JSON.parse(inputs.get('package.json')).engines;
  if (!engines || !/^\d+\.\d+\.\d+$/u.test(engines.node) || !/^\d+\.\d+\.\d+$/u.test(engines.npm)) {
    throw new Error('Root package.json must declare exact Node and npm versions in engines.');
  }
  if (process.versions.node !== engines.node) {
    throw new Error(`Node ${engines.node} is required; observed ${process.versions.node}.`);
  }
  const executableDirectory = path.dirname(process.execPath);
  const npm = path.resolve(executableDirectory, process.platform === 'win32'
    ? 'node_modules/npm/bin/npm-cli.js' : '../lib/node_modules/npm/bin/npm-cli.js');
  ordinaryFile(npm);
  const temporary = fs.mkdtempSync(path.join(os.tmpdir(), 'styleguide-npm-'));
  // Only these two files belong to this invocation. Do not recursively remove other data.
  try {
    for (const name of ['user.npmrc', 'global.npmrc']) fs.writeFileSync(path.join(temporary, name), '', { flag: 'wx', mode: 0o600 });
    const env = safeNpmEnvironment(environment, temporary);
    const runNpm = (args, directory = root) => {
      const childEnv = { ...env };
      if (args[0] === 'ci') {
        // Allow npm's normal download retries within the bounded install deadline.
        delete childEnv.npm_config_fetch_retries;
        delete childEnv.npm_config_fetch_timeout;
      }
      return runBounded(process.execPath, [npm, ...args], {
        cwd: directory, env: childEnv, timeout: args[0] === 'ci' ? 600000 : processLimits.timeout,
      });
    };
    const version = runNpm(['--version']);
    if (version.status !== 0) {
      if (version.stdout.length) process.stdout.write(version.stdout);
      if (version.stderr.length) process.stderr.write(version.stderr);
      throw new Error(`Could not read the bundled npm version (exit ${version.status}); npm ${engines.npm} is required.`);
    }
    const observed = version.stdout.toString('utf8').trim();
    if (observed !== engines.npm) {
      throw new Error(`Bundled npm ${engines.npm} is required; observed ${JSON.stringify(observed)}.`);
    }
    const value = callback({ runNpm, env, root });
    for (const [name, before] of inputs) {
      if (!before.equals(ordinaryFile(path.join(root, name)))) throw new Error(`npm changed a locked input: ${name}`);
    }
    return value;
  } finally {
    for (const name of ['user.npmrc', 'global.npmrc']) {
      try { fs.unlinkSync(path.join(temporary, name)); }
      catch (error) { if (error.code !== 'ENOENT') throw error; }
    }
    fs.rmdirSync(temporary);
  }
}

export function bootstrap(options) {
  return withNpmEnvironment(({ runNpm, env, root }) => {
    for (const directory of [root, path.join(root, '.github/workflows')]) {
      try {
        const result = runNpm(['ci', '--ignore-scripts', '--no-audit', '--fund=false', '--include=dev', '--package-lock=true'], directory);
        if (result.status !== 0) {
          if (result.stdout.length) process.stdout.write(result.stdout);
          if (result.stderr.length) process.stderr.write(result.stderr);
          throw new Error(`Locked installation failed (exit ${result.status}).`);
        }
      } catch (error) {
        throw new Error(`${path.relative(root, directory) || 'root'}: ${error.message} Setup is incomplete. Correct the reported cause, then run the bootstrap again to rebuild the locked installed trees.`);
      }
    }
    const hook = runBounded(process.execPath, [path.join(root, '.github/workflows/install-husky.mjs')], { cwd: root, env });
    if (hook.stdout.length) process.stdout.write(hook.stdout);
    if (hook.stderr.length) process.stderr.write(hook.stderr);
    if (hook.status !== 0) throw new Error(`Hook installation failed (exit ${hook.status}).`);
    console.log('Locked tools installed. The Husky installer completed or reported an applicable skip.');
  }, options);
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try {
    if (process.argv.length !== 3 || process.argv[2] !== 'install') throw new Error('Usage: node .github/workflows/NpmTools.mjs install');
    bootstrap();
  } catch (error) {
    console.error(`npm setup: ${error.message}`);
    process.exitCode = 2;
  }
}
