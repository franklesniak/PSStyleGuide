import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

// Run this accepted-base helper before any candidate parser or executable.
// This result classifies work. It neither authenticates nor grants permission.
const selectorPaths = new Set([
  '.gitattributes', '.github/.gitattributes', '.github/actionlint.yaml',
  '.npmrc', 'npm-shrinkwrap.json', 'package.json', 'package-lock.json',
  '.pre-commit-config.yaml', '.github/.npmrc', '.husky/pre-commit',
  'requirements-dev.txt', '.github/document-metadata-classification.json',
  ...[
    '.gitattributes', '.npmrc', 'npm-shrinkwrap.json', 'package.json', 'package-lock.json',
    'Classify-InstructionMaintenance.mjs', 'Classify-InstructionMaintenance.test.mjs',
    'Test-AgentInstructions.ps1', 'Test-AgentInstructions.SelfTest.ps1',
    'Validate-WorkflowPolicy.mjs',
    'workflow-policy-contract.json', 'workflow-policy-cases.json',
    'agent-instructions.yml',
    'copilot-setup-steps.yml',
    'build.yml', 'markdownlint.yml', '.markdownlint.jsonc', 'lint-nested-markdown.js',
    'lint-markdown.mjs', 'lint-markdown.test.mjs',
    'Generate-StyleGuideArtifacts.ps1', 'Test-ExactGitPathSet.ps1',
    'Test-BlankLineExamples.ps1', 'Test-StateRecoveryExamples.mjs', 'Test-StyleGuideArtifacts.ps1',
    'Test-CheckoutCredentials.ps1', 'Initialize-CiToolchain.ps1',
    'Invoke-MarkdownLint.ps1', 'ci-toolchain.json',
    'NpmTools.mjs', 'NpmTools.test.mjs', 'Check-NpmAudit.mjs', 'Check-NpmAudit.test.mjs',
    'npm-risk-exceptions.json', 'install-husky.mjs', 'lint-staged-markdown.mjs',
    'Validate-WorkflowPolicy.test.mjs',
    'Test-CiHelpers.test.mjs', 'Test-LocalValidation.test.mjs', 'Invoke-LockedPythonHook.ps1',
  ].map(name => `.github/workflows/${name}`.toLowerCase()),
]);
// Keep this accepted-code list aligned with actual loader changes. Adding a
// dependency changes an already listed caller and requires closure review.
// Installed package locations include transitive runtime files and shadowing.
const packageDirectories = ['node_modules/', '.github/workflows/node_modules/'];

function requireCommit(value, label) {
  if (typeof value !== 'string' || !/^[a-f0-9]{40}$/.test(value)) {
    throw new Error(`${label} must be a complete lowercase Git commit ID.`);
  }
}

function requirePath(value) {
  if (typeof value !== 'string' || value.length === 0 ||
      /[\\\x00-\x1f\x7f]/u.test(value) || value.startsWith('/') ||
      value.split('/').some(part => part === '' || part === '.' || part === '..')) {
    throw new Error('The changed-path list contains an invalid repository path.');
  }
}

export function classifyInstructionMaintenance({ base, head, changedPaths }) {
  requireCommit(base, 'Base');
  requireCommit(head, 'Head');
  if (!Array.isArray(changedPaths) || changedPaths.length > 10000) {
    throw new Error('A bounded, complete changed-path list is required.');
  }
  const maintenancePaths = [];
  for (const value of new Set(changedPaths)) {
    requirePath(value);
    // Case folding also covers aliases on supported Windows filesystems.
    const name = value.toLowerCase();
    // GitHub discovers a new workflow without a listed caller changing.
    const workflowEntry = /^\.github\/workflows\/[^/]+\.ya?ml$/u.test(name);
    if (workflowEntry || selectorPaths.has(name) || packageDirectories.some(prefix => name.startsWith(prefix))) {
      maintenancePaths.push(value);
    }
  }
  return {
    base, head, policy: base,
    classification: maintenancePaths.length ? 'maintenance_required' : 'ordinary',
    maintenancePaths: maintenancePaths.sort(),
  };
}

export function readInstructionMaintenance(repositoryRoot, base, head) {
  requireCommit(base, 'Base');
  requireCommit(head, 'Head');
  const environment = { ...process.env, GIT_CONFIG_NOSYSTEM: '1',
    GIT_CONFIG_GLOBAL: process.platform === 'win32' ? 'NUL' : '/dev/null',
    GIT_TERMINAL_PROMPT: '0', GIT_NO_REPLACE_OBJECTS: '1' };
  for (const name of Object.keys(environment)) {
    if (/^GIT_(?:CONFIG_(?:COUNT|KEY_|VALUE_|PARAMETERS)|DIR$|WORK_TREE$|INDEX_FILE$|OBJECT_DIRECTORY$|ALTERNATE_OBJECT_DIRECTORIES$)/.test(name)) {
      delete environment[name];
    }
  }
  const git = (...args) => execFileSync('git', ['-c', 'core.hooksPath=/dev/null',
    '-c', 'core.fsmonitor=false', '-C', repositoryRoot, ...args], {
    env: environment, maxBuffer: 1024 * 1024, timeout: 30000,
    windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'],
  });
  const decode = bytes => new TextDecoder('utf-8', { fatal: true }).decode(bytes);
  const checkedOut = decode(git('rev-parse', '--verify', 'HEAD^{commit}')).trim();
  if (checkedOut !== base) throw new Error('The checker must run from the accepted base checkout.');
  for (const commit of [base, head]) {
    if (decode(git('cat-file', '-t', commit)).trim() !== 'commit') {
      throw new Error('Both endpoints must be available commit objects.');
    }
  }
  const names = decode(git('diff', '--name-only', '--no-renames', '--no-ext-diff',
    '--no-textconv', '-z', base, head, '--'));
  if (names !== '' && !names.endsWith('\0')) throw new Error('The Git path list is incomplete.');
  return classifyInstructionMaintenance({ base, head,
    changedPaths: names === '' ? [] : names.slice(0, -1).split('\0') });
}

// Prefer loader identity; retain direct-call detection on runtimes without this property.
const isMain = typeof import.meta.main === 'boolean' ? import.meta.main : (() => {
  if (!process.argv[1]) return false;
  try {
    return fs.realpathSync(process.argv[1]) === fs.realpathSync(fileURLToPath(import.meta.url));
  } catch {
    return false;
  }
})();

if (isMain) {
  try {
    if (process.argv.length !== 5) throw new Error('Usage: node Classify-InstructionMaintenance.mjs REPOSITORY BASE HEAD');
    process.stdout.write(`${JSON.stringify(readInstructionMaintenance(...process.argv.slice(2)))}\n`);
  } catch (error) {
    process.stderr.write(`Instruction maintenance classification failed: ${error.message}\n`);
    process.exitCode = 1;
  }
}
