import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { classifyInstructionMaintenance, readInstructionMaintenance } from './Classify-InstructionMaintenance.mjs';

const base = 'a'.repeat(40), head = 'b'.repeat(40);
const classify = changedPaths => classifyInstructionMaintenance({ base, head, changedPaths });

test('ordinary documentation needs no maintenance authorization', () => {
  assert.deepEqual(classify(['STYLE_GUIDE.md', 'docs/example.md', 'AGENTS.md',
    '.github/workflows/scripts-README.md', '.github/workflows/review-notes.txt',
    '.github/workflows/unreferenced-example.ps1', '.github/actions/unused/example.txt']), {
    base, head, policy: base, classification: 'ordinary', maintenancePaths: [],
  });
});

test('new platform-discovered workflows require maintenance; sample YAML and notes do not', () => {
  for (const name of ['.github/workflows/new-workflow.yml', '.github/workflows/new-workflow.yaml',
    '.GITHUB/WORKFLOWS/NEW-WORKFLOW.YML']) {
    assert.equal(classify([name]).classification, 'maintenance_required');
  }
  for (const name of ['.github/workflows/samples/example.yml', '.github/workflows/notes.yml.txt',
    'samples/workflow.yml']) {
    assert.equal(classify([name]).classification, 'ordinary');
  }
});

test('checker, helper, workflow and dependency-only changes require maintenance', () => {
  for (const name of ['.github/workflows/Test-AgentInstructions.ps1',
    '.github/workflows/Classify-InstructionMaintenance.mjs', '.github/workflows/agent-instructions.yml',
    '.github/workflows/package-lock.json', '.github/workflows/.npmrc',
    '.github/workflows/Test-CheckoutCredentials.ps1',
    '.github/workflows/Initialize-CiToolchain.ps1',
    '.github/workflows/Invoke-MarkdownLint.ps1', '.github/workflows/ci-toolchain.json',
    '.github/workflows/Validate-WorkflowPolicy.test.mjs',
    '.husky/pre-commit', '.github/workflows/NpmTools.mjs', '.github/workflows/NpmTools.test.mjs',
    '.github/workflows/Check-NpmAudit.mjs', '.github/workflows/Check-NpmAudit.test.mjs',
    '.github/workflows/npm-risk-exceptions.json', '.github/workflows/install-husky.mjs',
    '.github/workflows/lint-staged-markdown.mjs',
    '.github/workflows/.gitattributes', '.github/workflows/node_modules/yaml/dist/index.js',
    'node_modules/markdown-it/lib/index.mjs', '.github/.npmrc',
    'package.json', 'package-lock.json', 'npm-shrinkwrap.json', '.npmrc',
    '.gitattributes', '.github/.gitattributes', '.pre-commit-config.yaml',
    '.GITHUB/WORKFLOWS/TEST-AGENTINSTRUCTIONS.PS1']) {
    assert.equal(classify([name]).classification, 'maintenance_required', name);
  }
});

test('candidate authority data cannot change classification', () => {
  const result = classifyInstructionMaintenance({ base, head,
    changedPaths: ['.github/workflows/Classify-InstructionMaintenance.mjs'], authorized: true,
    classification: 'ordinary', ownerApproval: 'approved' });
  assert.equal(result.classification, 'maintenance_required');
  assert.equal(Object.hasOwn(result, 'authorized'), false);
});

test('missing, invalid or ambiguous paths and revisions fail closed', () => {
  for (const name of ['', '../package.json', '/package.json',
    '.github\\workflows\\helper.mjs', 'a\nb', 'a//b', 'a/./b']) {
    assert.throws(() => classify([name]));
  }
  assert.throws(() => classify(null));
  assert.throws(() => classify(Array(10001).fill('a')));
  assert.throws(() => classifyInstructionMaintenance({ base: 'main', head, changedPaths: [] }));
  assert.throws(() => classifyInstructionMaintenance({ base, head: '', changedPaths: [] }));
});

test('classification stays bound to its base, head and accepted policy', () => {
  const nextBase = 'c'.repeat(40), nextHead = 'd'.repeat(40);
  const result = classifyInstructionMaintenance({ base: nextBase, head: nextHead,
    changedPaths: ['package.json', 'package.json'] });
  assert.equal(result.base, nextBase);
  assert.equal(result.policy, nextBase);
  assert.equal(result.head, nextHead);
  assert.deepEqual(result.maintenancePaths, ['package.json']);
});

test('Git endpoints detect maintenance without executing proposed files', () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'instruction-maintenance-'));
  const git = (...args) => execFileSync('git', ['-C', root, ...args], {
    encoding: 'utf8', windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'],
    env: { ...process.env, GIT_CONFIG_NOSYSTEM: '1',
      GIT_CONFIG_GLOBAL: process.platform === 'win32' ? 'NUL' : '/dev/null' },
  }).trim();
  try {
    git('init', '--quiet');
    git('config', 'user.name', 'Maintenance Test');
    git('config', 'user.email', 'test@example.invalid');
    git('config', 'commit.gpgsign', 'false');
    fs.writeFileSync(path.join(root, 'README.md'), 'base\n');
    git('add', '.'); git('commit', '--quiet', '-m', 'base');
    const first = git('rev-parse', 'HEAD');
    fs.writeFileSync(path.join(root, 'README.md'), 'ordinary\n');
    git('add', '.'); git('commit', '--quiet', '-m', 'ordinary');
    const ordinary = git('rev-parse', 'HEAD');
    fs.mkdirSync(path.join(root, '.github', 'workflows'), { recursive: true });
    fs.writeFileSync(path.join(root, '.github', 'workflows', 'Test-AgentInstructions.ps1'),
      'throw new Error("Candidate code must never execute");\n');
    git('add', '.'); git('commit', '--quiet', '-m', 'maintenance');
    const maintenance = git('rev-parse', 'HEAD');
    assert.throws(() => readInstructionMaintenance(root, first, maintenance), /accepted base/);
    git('checkout', '--quiet', '--detach', first);
    assert.equal(readInstructionMaintenance(root, first, ordinary).classification, 'ordinary');
    assert.equal(readInstructionMaintenance(root, first, maintenance).classification, 'maintenance_required');
    assert.throws(() => readInstructionMaintenance(root, first, 'f'.repeat(40)));
  } finally {
    // mkdtemp created this exact child; never derive deletion from candidate data.
    assert.equal(path.dirname(root), os.tmpdir());
    assert.ok(path.basename(root).startsWith('instruction-maintenance-'));
    fs.rmSync(root, { recursive: true, force: true });
  }
});
