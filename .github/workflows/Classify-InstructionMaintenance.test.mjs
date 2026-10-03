import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import { createRequire } from 'node:module';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { classifyInstructionMaintenance, readInstructionMaintenance } from './Classify-InstructionMaintenance.mjs';

const base = 'a'.repeat(40), head = 'b'.repeat(40);
const classify = changedPaths => classifyInstructionMaintenance({ base, head, changedPaths });

test('push transition caller binds event endpoints and preserves proposed-code provenance', () => {
  const { parse } = createRequire(import.meta.url)('yaml');
  const workflow = parse(fs.readFileSync(new URL('./agent-instructions.yml', import.meta.url), 'utf8'));
  const step = workflow.jobs['candidate-tests'].steps.find(value => value.id === 'test');
  assert.equal(step.env.EXPECTED_PUSH_BASE, '${{ github.event.before }}');
  assert.equal(step.env.EXPECTED_PUSH_HEAD, '${{ github.event.after }}');
  assert.equal(workflow.jobs['accepted-policy'].if, "github.event_name == 'pull_request_target'");
  assert.ok(!JSON.stringify(workflow.jobs['accepted-policy']).includes('-ProposedPolicy'));
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'instruction-push-caller-'));
  try {
    const script = path.join(root, 'caller.ps1'), log = path.join(root, 'calls.jsonl');
    // Keep direct checker calls intact so PowerShell script completion is real.
    const checker = path.join(root, '.github/workflows/Test-AgentInstructions.ps1');
    fs.mkdirSync(path.dirname(checker), { recursive: true });
    fs.writeFileSync(checker, `
if ($args -contains '-ProposedPolicy' -and $env:GIT_NO_REPLACE_OBJECTS -ne '1') { throw 'Replacement objects were not disabled.' }
[IO.File]::AppendAllText($env:FIXTURE_LOG, (@('checker') + @($args) | ConvertTo-Json -Compress -AsArray) + "\n")
if ($args -contains '-ProposedPolicy') {
  if ($env:FIXTURE_MODE -eq 'check-failure') { throw 'Rejected transition.' }
  if ($env:FIXTURE_MODE -eq 'check-exit') { exit 9 }
  & pwsh -NoProfile -NonInteractive -Command 'exit 37'
  Write-Output 'Transition passed despite an internal native nonzero status.'
}
`);
    const prefix = `
function Invoke-FixtureGit {
  [IO.File]::AppendAllText($env:FIXTURE_LOG, (@($args) | ConvertTo-Json -Compress -AsArray) + "\n")
  $global:LASTEXITCODE = 0
  if ($args -contains 'fetch' -and $env:FIXTURE_MODE -eq 'fetch-failure') { $global:LASTEXITCODE = 7 }
  if ($args -contains 'rev-parse') {
    if ($env:FIXTURE_MODE -eq 'identity-failure') { $global:LASTEXITCODE = 8 }
    if ($env:FIXTURE_MODE -eq 'wrong-identity') { 'c' * 40 } else { $env:EXPECTED_PUSH_BASE }
  }
}
function Invoke-FixtureTests {
  [IO.File]::AppendAllText($env:FIXTURE_LOG, (@('node') + @($args) | ConvertTo-Json -Compress -AsArray) + "\n")
  if ($env:FIXTURE_MODE -eq 'node-failure') { & pwsh -NoProfile -NonInteractive -Command 'exit 7' }
  else { & pwsh -NoProfile -NonInteractive -Command 'exit 0' }
}
function Start-Sleep {}
`;
    fs.writeFileSync(script, prefix + step.run
      .replaceAll('/usr/bin/git', 'Invoke-FixtureGit')
      .replaceAll('& node --test', '& Invoke-FixtureTests --test'));
    for (const item of [
      { name: 'push', event: 'push', pass: true, calls: 1 },
      { name: 'manual snapshot', event: 'workflow_dispatch', pass: true, calls: 0 },
      { name: 'PR snapshot', event: 'pull_request', pass: true, calls: 0 },
      { name: 'missing B', before: '', pass: false },
      { name: 'zero B', before: '0'.repeat(40), pass: false },
      { name: 'zero H', after: '0'.repeat(40), pass: false },
      { name: 'H/H', before: head, pass: false },
      { name: 'event H mismatch', after: 'c'.repeat(40), pass: false },
      { name: 'unavailable B', mode: 'fetch-failure', pass: false, fetches: 3 },
      { name: 'wrong fetched B', mode: 'wrong-identity', pass: false },
      { name: 'native identity failure', mode: 'identity-failure', pass: false },
      { name: 'rejected transition', mode: 'check-failure', pass: false, diagnostic: /Rejected transition/ },
      { name: 'explicit checker exit', mode: 'check-exit', pass: false, diagnostic: /Proposed push transition checks failed/ },
      { name: 'subsequent Node failure', mode: 'node-failure', pass: false, node: true,
        diagnostic: /Workflow behavior tests failed/ },
    ]) {
      fs.writeFileSync(log, '');
      const result = spawnSync('pwsh', ['-NoProfile', '-NonInteractive', '-File', script], {
        cwd: root, encoding: 'utf8', timeout: 30000, windowsHide: true,
        env: { ...process.env, FIXTURE_LOG: log, FIXTURE_MODE: item.mode ?? '',
          GITHUB_EVENT_NAME: item.event ?? 'push', GITHUB_SHA: head,
          EXPECTED_PUSH_BASE: item.before ?? base, EXPECTED_PUSH_HEAD: item.after ?? head },
      });
      assert.equal(result.status === 0, item.pass, `${item.name}: ${result.stderr}`);
      if (item.diagnostic) assert.match(result.stderr, item.diagnostic, item.name);
      const rows = fs.readFileSync(log, 'utf8').trim().split('\n').filter(Boolean).map(JSON.parse);
      const proposed = rows.filter(row => row.includes('-ProposedPolicy'));
      assert.equal(rows.filter(row => row[0] === 'node').length, item.pass || item.node ? 1 : 0,
        `${item.name}: subsequent Node reach`);
      if (item.calls !== undefined) assert.equal(proposed.length, item.calls, item.name);
      if (proposed.length && (item.pass || item.node)) {
        assert.match(result.stdout, /Transition passed despite an internal native nonzero status/);
      }
      for (const row of proposed) {
        assert.deepEqual(row, ['checker', '-ProposedPolicy', '-InputRevision', head,
          '-PublishedBaselineRevision', base]);
      }
      const fetches = rows.filter(row => row.includes('fetch'));
      if (item.fetches !== undefined) assert.equal(fetches.length, item.fetches);
      assert.ok(fetches.length <= 3);
      assert.ok(fetches.every(row => row.at(-1) === base && !row.includes('--force') &&
        row.includes('credential.helper=') && row.includes('http.extraheader=')));
    }
  } finally {
    assert.equal(path.dirname(root), os.tmpdir());
    assert.ok(path.basename(root).startsWith('instruction-push-caller-'));
    fs.rmSync(root, { recursive: true, force: true });
  }
});

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
    '.github/workflows/Test-BlankLineExamples.ps1',
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

test('metadata classification table-only changes require maintenance', () => {
  for (const name of ['.github/document-metadata-classification.json',
    '.GITHUB/DOCUMENT-METADATA-CLASSIFICATION.JSON']) {
    const result = classify([name]);
    assert.equal(result.classification, 'maintenance_required');
    assert.deepEqual(result.maintenancePaths, [name]);
    assert.equal(result.policy, base);
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
