import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';
import test from 'node:test';

const directory = path.dirname(fileURLToPath(import.meta.url));
const repository = path.resolve(directory, '../..');
const linux = process.platform === 'linux';

function fixture(t) {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'styleguide-local-validation-'));
  t.after(() => fs.rmSync(root, { recursive: true, force: true }));
  const workflows = path.join(root, '.github/workflows');
  fs.mkdirSync(workflows, { recursive: true });
  const git = (...args) => {
    const result = spawnSync('git', ['-c', 'core.hooksPath=/dev/null', '-C', root, ...args], { encoding: 'utf8', windowsHide: true });
    assert.equal(result.status, 0, result.stderr);
    return result.stdout.trim();
  };
  git('init', '--quiet');
  return { root, workflows, git };
}

for (const [status, expected] of [[0, 0], [1, 1], [2, 2], [17, 2], ['undefined', 2]]) {
  test(`staged Markdown uses index bytes and normalizes dependency status ${status}`, t => {
    const f = fixture(t);
    fs.writeFileSync(path.join(f.root, 'package.json'), JSON.stringify({ engines: { node: process.versions.node } }));
    fs.copyFileSync(path.join(directory, 'lint-staged-markdown.mjs'), path.join(f.workflows, 'lint-staged-markdown.mjs'));
    fs.writeFileSync(path.join(f.root, 'example.md'), '# Staged content\n');
    f.git('add', 'example.md');
    fs.writeFileSync(path.join(f.root, 'example.md'), 'Unstaged content must not replace index bytes.\n');
    fs.writeFileSync(path.join(f.workflows, 'lint-nested-markdown.js'), `exports.loadMarkdownlintConfig = () => ({});
    exports.lintOuterMarkdownContents = async (root, inputs) => {
      if (inputs.length !== 1 || inputs[0].filePath !== 'example.md' || inputs[0].content !== '# Staged content\\n') throw new Error('Wrong staged bytes');
      console.log('fixture: outer status reached');
      return ${status};
    }; exports.lintNestedMarkdownContents = inputs => {
      if (inputs[0].content !== '# Staged content\\n') throw new Error('Wrong nested staged bytes');
      return { totalBlocks: 0, allResults: [] };
    }; exports.displayResults = () => false;`);
    const result = spawnSync(process.execPath, [path.join(f.workflows, 'lint-staged-markdown.mjs')], { encoding: 'utf8', windowsHide: true });
    assert.equal(result.status, expected, result.stderr);
    assert.match(result.stdout, /fixture: outer status reached/u);
    assert.equal(fs.readFileSync(path.join(f.root, 'example.md'), 'utf8'), 'Unstaged content must not replace index bytes.\n');
  });
}

for (const [stage, outer, nested, expected, commands] of [
  [0, 0, 0, 0, ['staged', 'lint:md', 'lint:md:nested']],
  [1, 0, 0, 1, ['staged']],
  [2, 0, 0, 1, ['staged']],
  [17, 0, 0, 1, ['staged']],
  [0, 1, 0, 1, ['staged', 'lint:md']],
  [0, 0, 2, 1, ['staged', 'lint:md', 'lint:md:nested']],
]) {
  test(`retained Husky hook preserves native failure and order ${stage}/${outer}/${nested}`, { skip: !linux }, t => {
    const f = fixture(t);
    fs.writeFileSync(path.join(f.root, 'example.md'), '# Staged\n'); f.git('add', 'example.md');
    const bin = path.join(f.root, 'bin'); fs.mkdirSync(bin);
    const log = path.join(f.root, 'calls');
    fs.writeFileSync(path.join(bin, 'node'), `#!/bin/sh\nprintf '%s\\n' staged >> '${log}'\nexit ${stage}\n`, { mode: 0o700 });
    fs.writeFileSync(path.join(bin, 'npm'), `#!/bin/sh\nprintf '%s\\n' "$4" >> '${log}'\nif [ "$4" = 'lint:md' ]; then exit ${outer}; fi\nexit ${nested}\n`, { mode: 0o700 });
    const result = spawnSync('sh', ['-e', path.join(repository, '.husky/pre-commit')], {
      cwd: f.root, encoding: 'utf8', env: { ...process.env, PATH: `${bin}:${process.env.PATH}` },
    });
    assert.equal(result.status, expected, result.stderr);
    assert.deepEqual(fs.readFileSync(log, 'utf8').trim().split('\n'), commands);
  });
}
