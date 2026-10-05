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
  assert.equal(step.env.EXPECTED_PUSH_CREATED, '${{ toJSON(github.event.created) }}');
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
if ($args -contains '-SelfTest') {
  if ($env:FIXTURE_MODE -eq 'snapshot-failure') { throw 'Rejected snapshot.' }
  if ($env:FIXTURE_MODE -eq 'snapshot-exit') { exit 9 }
}
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
  if ($args -contains 'check-ref-format') { & git check-ref-format $args[-1] }
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
      { name: 'main publication push', event: 'push', pass: true, calls: 1, fetches: 1 },
      { name: 'draft branch update', ref: 'refs/heads/feature', mode: 'check-failure', pass: true, calls: 0, fetches: 1, snapshot: true },
      { name: 'near-match main branch', ref: 'refs/heads/main-fix', pass: true, calls: 0, fetches: 1, snapshot: true },
      { name: 'nested main branch', ref: 'refs/heads/team/main', pass: true, calls: 0, fetches: 1, snapshot: true },
      { name: 'case-distinct main branch', ref: 'refs/heads/Main', pass: true, calls: 0, fetches: 1, snapshot: true },
      { name: 'existing tag', ref: 'refs/tags/v1', pass: true, calls: 0, fetches: 1, snapshot: true },
      { name: 'tag named main', ref: 'refs/tags/main', pass: true, calls: 0, fetches: 1, snapshot: true },
      { name: 'missing ref', ref: '', pass: false, calls: 0, fetches: 0, diagnostic: /full push branch or tag ref/ },
      { name: 'short ref', ref: 'main', pass: false, calls: 0, fetches: 0, diagnostic: /full push branch or tag ref/ },
      { name: 'non-push ref', ref: 'refs/pull/1/merge', pass: false, calls: 0, fetches: 0, diagnostic: /full push branch or tag ref/ },
      { name: 'empty branch name', ref: 'refs/heads/', pass: false, calls: 0, fetches: 0, diagnostic: /full push branch or tag ref/ },
      { name: 'invalid branch name', ref: 'refs/heads/main..fix', pass: false, calls: 0, fetches: 0, diagnostic: /Invalid push ref/ },
      { name: 'invalid tag name', ref: 'refs/tags/bad tag', pass: false, calls: 0, fetches: 0, diagnostic: /Invalid push ref/ },
      { name: 'draft unavailable B', ref: 'refs/heads/feature', mode: 'fetch-failure', pass: false, calls: 0, fetches: 3 },
      { name: 'draft Node failure', ref: 'refs/heads/feature', mode: 'node-failure', pass: false, calls: 0, fetches: 1,
        node: true, diagnostic: /Workflow behavior tests failed/ },
      { name: 'new branch', ref: 'refs/heads/feature', created: 'true', before: '0'.repeat(40), pass: true, calls: 0, fetches: 0 },
      { name: 'new tag', ref: 'refs/tags/v1', created: 'true', before: '0'.repeat(40), pass: true, calls: 0, fetches: 0 },
      { name: 'new reference has B', created: 'true', pass: false },
      { name: 'missing created', created: '', pass: false },
      { name: 'null created', created: 'null', pass: false },
      { name: 'string created', created: '"true"', pass: false },
      { name: 'number created', created: '1', pass: false },
      { name: 'mixed-case created', created: 'True', pass: false },
      { name: 'new reference H mismatch', created: 'true', before: '0'.repeat(40), after: 'c'.repeat(40), pass: false },
      { name: 'new reference zero H', created: 'true', before: '0'.repeat(40), after: '0'.repeat(40), pass: false },
      { name: 'new reference snapshot failure', created: 'true', before: '0'.repeat(40), mode: 'snapshot-failure',
        pass: false, calls: 0, fetches: 0, diagnostic: /Rejected snapshot/ },
      { name: 'new reference snapshot exit', created: 'true', before: '0'.repeat(40), mode: 'snapshot-exit',
        pass: false, calls: 0, fetches: 0, diagnostic: /Proposed snapshot checks failed/ },
      { name: 'new reference Node failure', created: 'true', before: '0'.repeat(40), mode: 'node-failure',
        pass: false, calls: 0, fetches: 0, node: true, diagnostic: /Workflow behavior tests failed/ },
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
          GITHUB_EVENT_NAME: item.event ?? 'push', GITHUB_SHA: head, GITHUB_REF: item.ref ?? 'refs/heads/main',
          EXPECTED_PUSH_CREATED: item.created ?? 'false',
          EXPECTED_PUSH_BASE: item.before ?? base, EXPECTED_PUSH_HEAD: item.after ?? head },
      });
      assert.equal(result.status === 0, item.pass, `${item.name}: ${result.stderr}`);
      if (item.diagnostic) assert.match(result.stderr, item.diagnostic, item.name);
      if (item.snapshot) assert.match(result.stdout, /snapshot checks only; publication admission is not established/);
      const rows = fs.readFileSync(log, 'utf8').trim().split('\n').filter(Boolean).map(JSON.parse);
      const proposed = rows.filter(row => row.includes('-ProposedPolicy'));
      assert.equal(rows.filter(row => row.includes('-SelfTest')).length, 1, `${item.name}: snapshot reach`);
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

test('shared callable closure covers helper-only paths and aliases without absorbing lookalikes', () => {
  const helpers = ['requirements-dev.txt',
    '.github/workflows/lint-markdown.mjs', '.github/workflows/lint-markdown.test.mjs',
    '.github/workflows/Invoke-LockedPythonHook.ps1', '.github/workflows/Test-LocalValidation.test.mjs',
    '.github/workflows/Test-AgentInstructions.SelfTest.ps1',
    '.github/workflows/Test-BlankLineExamples.ps1', '.github/workflows/Test-StateRecoveryExamples.mjs'];
  for (const helper of helpers) {
    for (const name of [helper, helper.toUpperCase()]) {
      assert.deepEqual(classify([name]), {
        base, head, policy: base, classification: 'maintenance_required', maintenancePaths: [name],
      }, name);
    }
    for (const name of [`${helper}.bak`, `examples/${helper}`]) {
      assert.equal(classify([name]).classification, 'ordinary', name);
    }
  }
  assert.equal(classify(['.github/workflows/unreferenced-example.mjs']).classification, 'ordinary');
  assert.equal(classify(['.github/workflows/samples/Test-StateRecoveryExamples.mjs']).classification, 'ordinary');
});

test('real helper-only Git changes, removals and ambient redirection retain accepted-base classification', () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'instruction-shared-closure-'));
  const git = (...args) => execFileSync('git', ['-c', 'core.hooksPath=/dev/null', '-C', root, ...args], {
    encoding: 'utf8', timeout: 30000, windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'],
    env: { ...process.env, GIT_CONFIG_NOSYSTEM: '1',
      GIT_CONFIG_GLOBAL: process.platform === 'win32' ? 'NUL' : '/dev/null' },
  }).trim();
  try {
    git('init', '--quiet');
    git('config', 'user.name', 'Shared Closure Test');
    git('config', 'user.email', 'test@example.invalid');
    git('config', 'commit.gpgsign', 'false');
    const wrapper = '.github/workflows/lint-markdown.mjs';
    fs.mkdirSync(path.join(root, '.github/workflows'), { recursive: true });
    fs.writeFileSync(path.join(root, 'README.md'), 'accepted documentation\n');
    fs.writeFileSync(path.join(root, wrapper), 'accepted wrapper fixture\n');
    git('add', '.'); git('commit', '--quiet', '-m', 'accepted fixture');
    const accepted = git('rev-parse', 'HEAD');
    const marker = path.join(root, 'candidate-executed');
    for (const helper of [wrapper, '.github/workflows/lint-markdown.test.mjs',
      'requirements-dev.txt', '.github/workflows/Invoke-LockedPythonHook.ps1',
      '.github/workflows/Test-LocalValidation.test.mjs', '.github/workflows/Test-AgentInstructions.SelfTest.ps1',
      '.github/workflows/Test-BlankLineExamples.ps1', '.github/workflows/Test-StateRecoveryExamples.mjs',
      '.github/workflows/Classify-InstructionMaintenance.mjs']) {
      fs.writeFileSync(path.join(root, helper),
        `import fs from 'node:fs'; fs.writeFileSync(${JSON.stringify(marker)}, 'executed'); throw new Error('Untrusted candidate');\n`);
      git('add', '--', helper); git('commit', '--quiet', '-m', 'candidate helper');
      const candidate = git('rev-parse', 'HEAD');
      git('checkout', '--quiet', '--detach', accepted);
      const expected = { base: accepted, head: candidate, policy: accepted,
        classification: 'maintenance_required', maintenancePaths: [helper] };
      assert.deepEqual(readInstructionMaintenance(root, accepted, candidate), expected, helper);
      assert.equal(fs.existsSync(marker), false, `${helper}: candidate code executed`);
      const overrides = { GIT_DIR: path.join(root, 'missing-git-dir'),
        GIT_WORK_TREE: path.join(root, 'missing-worktree'), GIT_INDEX_FILE: path.join(root, 'missing-index'),
        GIT_OBJECT_DIRECTORY: path.join(root, 'missing-objects'),
        GIT_ALTERNATE_OBJECT_DIRECTORIES: path.join(root, 'missing-alternates'),
        GIT_CONFIG_COUNT: '1', GIT_CONFIG_KEY_0: 'core.bare', GIT_CONFIG_VALUE_0: 'true',
        GIT_CONFIG_PARAMETERS: "'invalid external configuration" };
      const saved = Object.fromEntries(Object.keys(overrides).map(name => [name, process.env[name]]));
      try {
        Object.assign(process.env, overrides);
        assert.deepEqual(readInstructionMaintenance(root, accepted, candidate), expected,
          `${helper}: external Git configuration changed the result`);
      } finally {
        for (const [name, value] of Object.entries(saved)) {
          if (value === undefined) delete process.env[name]; else process.env[name] = value;
        }
      }
    }
    git('mv', '--', wrapper, 'renamed-wrapper.txt');
    git('commit', '--quiet', '-m', 'rename helper outside selector');
    const removed = git('rev-parse', 'HEAD');
    git('checkout', '--quiet', '--detach', accepted);
    assert.deepEqual(readInstructionMaintenance(root, accepted, removed), {
      base: accepted, head: removed, policy: accepted,
      classification: 'maintenance_required', maintenancePaths: [wrapper],
    });
  } finally {
    assert.equal(path.dirname(root), os.tmpdir());
    assert.ok(path.basename(root).startsWith('instruction-shared-closure-'));
    fs.rmSync(root, { recursive: true, force: true });
  }
});

test('accepted data admission precedes shared-helper classification and ordinary validation', () => {
  const { parse } = createRequire(import.meta.url)('yaml');
  const workflow = parse(fs.readFileSync(new URL('./agent-instructions.yml', import.meta.url), 'utf8'));
  const step = workflow.jobs['accepted-policy'].steps.find(value => value.id === 'validate');
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'instruction-admission-caller-'));
  try {
    const directory = path.join(root, '.github/workflows');
    fs.mkdirSync(directory, { recursive: true });
    const log = path.join(root, 'calls.jsonl'), script = path.join(root, 'accepted.ps1');
    fs.writeFileSync(path.join(directory, 'Test-CheckoutCredentials.ps1'),
      `[IO.File]::AppendAllText($env:FIXTURE_LOG, '["credentials"]' + "\n")\n`);
    fs.writeFileSync(path.join(directory, 'Test-AgentInstructions.ps1'), `
$phase = if ($args -contains '-MetadataClassificationOnly') { 'data' } else { 'ordinary' }
[IO.File]::AppendAllText($env:FIXTURE_LOG, (@($phase) + @($args) | ConvertTo-Json -Compress -AsArray) + "\n")
if ($phase -eq 'data' -and $env:FIXTURE_MODE -eq 'reject-data') { throw 'Rejected candidate classification data.' }
& pwsh -NoProfile -NonInteractive -Command 'exit 0'
`);
    fs.writeFileSync(script, `
function Invoke-FixtureGit {
  $global:LASTEXITCODE = 0
  if ($args -contains 'rev-parse') { $env:EXPECTED_HEAD }
}
function Invoke-FixtureNode {
  $phase = if ($args[0] -eq '.github/workflows/Classify-InstructionMaintenance.mjs') { 'classify' } else { 'workflow' }
  [IO.File]::AppendAllText($env:FIXTURE_LOG, (@($phase) + @($args) | ConvertTo-Json -Compress -AsArray) + "\n")
  $global:LASTEXITCODE = 0
  if ($phase -eq 'classify') { $env:FIXTURE_CLASSIFICATION }
}
` + step.run.replaceAll('/usr/bin/git', 'Invoke-FixtureGit').replaceAll('& node ', '& Invoke-FixtureNode '));
    for (const item of [
      { name: 'wrapper-only', paths: ['.github/workflows/lint-markdown.mjs'], phases: ['credentials', 'data', 'classify'] },
      { name: 'ordinary documentation', paths: ['docs/example.md'], phases: ['credentials', 'data', 'classify', 'ordinary', 'workflow'] },
      { name: 'invalid helper data', paths: ['.github/workflows/lint-markdown.mjs'], reject: true, phases: ['credentials', 'data'] },
    ]) {
      fs.writeFileSync(log, '');
      const result = spawnSync('pwsh', ['-NoProfile', '-NonInteractive', '-File', script], {
        cwd: root, encoding: 'utf8', timeout: 30000, windowsHide: true,
        env: { ...process.env, FIXTURE_LOG: log, FIXTURE_MODE: item.reject ? 'reject-data' : '',
          FIXTURE_CLASSIFICATION: JSON.stringify(classify(item.paths)), EXPECTED_BASE: base, EXPECTED_HEAD: head,
          GITHUB_STEP_SUMMARY: path.join(root, 'summary.txt') },
      });
      assert.equal(result.status === 0, !item.reject, `${item.name}: ${result.stderr}`);
      const rows = fs.readFileSync(log, 'utf8').trim().split('\n').filter(Boolean).map(JSON.parse);
      assert.deepEqual(rows.map(row => row[0]), item.phases, item.name);
      assert.deepEqual(rows.find(row => row[0] === 'data'),
        ['data', '-MetadataClassificationOnly', '-InputRevision', head, '-PublishedBaselineRevision', base]);
      if (item.reject) assert.match(result.stderr, /Rejected candidate classification data/);
      else {
        assert.deepEqual(rows.find(row => row[0] === 'classify'),
          ['classify', '.github/workflows/Classify-InstructionMaintenance.mjs', root, base, head]);
        if (item.paths[0].includes('lint-markdown')) assert.match(result.stdout, /This is not ordinary policy admission/);
      }
    }
  } finally {
    assert.equal(path.dirname(root), os.tmpdir());
    assert.ok(path.basename(root).startsWith('instruction-admission-caller-'));
    fs.rmSync(root, { recursive: true, force: true });
  }
});

test('generator harness classifier selector is exact', () => {
  const exact = '.github/workflows/Test-StyleGuideGenerator.ps1';
  for (const alias of [exact, exact.toLowerCase(), exact.toUpperCase()]) {
    assert.equal(classify([alias]).classification, 'maintenance_required', alias);
  }
  assert.deepEqual(classify(['README.md', exact, 'new-example.ps1']).maintenancePaths, [exact]);
  for (const near of [exact + '.bak', 'other/' + exact,
    '.github/workflows/Test-StyleGuideGenerator2.ps1', '.github/workflows/nested/Test-StyleGuideGenerator.ps1']) {
    assert.equal(classify([near]).classification, 'ordinary', near);
  }
});
