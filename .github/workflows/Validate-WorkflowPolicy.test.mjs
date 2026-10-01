import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync, spawnSync } from 'node:child_process';
import test from 'node:test';
import {
  LIMITS, readContract, validatePackagePair, foldParserTree, assertReviewedParserTree,
  loadYamlBindings, parseStrictYaml, validateWorkflowObject, main,
} from './Validate-WorkflowPolicy.mjs';

const directory = path.dirname(fileURLToPath(import.meta.url));
const root = path.resolve(directory, '../..');
const contract = readContract();
await loadYamlBindings(contract);
const clone = value => structuredClone(value);
const step = (id, run) => ({ id, shell: 'pwsh', run });
const codeJob = final => ({
  'runs-on': 'ubuntu-24.04', 'timeout-minutes': 30, permissions: {},
  steps: [step('acquire', "Write-Output 'bootstrap fixture'"),
    step('verify-checkout-credentials', './.github/workflows/Test-CheckoutCredentials.ps1'),
    ...(final.id === 'generate_style_guide_artifacts' ? [] : [step('initialize-toolchain', './.github/workflows/Initialize-CiToolchain.ps1 -WorkflowDependencies' +
      (final.id === 'lint' ? ' -InstructionDependencies' : ''))]), final,
    ...(final.id === 'lint' ? [step('audit', "& node ./.github/workflows/Check-NpmAudit.mjs\nif ($LASTEXITCODE -ne 0) { throw 'Dependency audit did not pass.' }")] : [])],
});
const common = { name: 'Fixture', on: { push: { branches: ['main'] }, pull_request: { branches: ['main'] } }, permissions: {} };
const fixtures = {
  'build.yml': { ...clone(common), jobs: {
    verify_generated_artifacts: codeJob(step('generate_style_guide_artifacts', './.github/workflows/Test-StyleGuideArtifacts.ps1')),
    publish_committed_artifacts: {
      'runs-on': 'ubuntu-24.04', 'timeout-minutes': 10, permissions: { contents: 'read' }, needs: 'verify_generated_artifacts',
      steps: ['checkout', 'uploadArtifact'].map((name, index) => ({
        id: index === 0 ? 'checkout_repository' : 'publish_committed_style_guide_artifacts',
        uses: contract.actions[name].uses, with: clone(contract.actions[name].inputs),
      })),
    },
  } },
  'markdownlint.yml': { ...clone(common), on: { ...clone(common.on), schedule: [{ cron: '17 6 * * 1' }] }, jobs: {
    policy: codeJob(step('validate', "& node ./.github/workflows/Validate-WorkflowPolicy.mjs .github/workflows/build.yml .github/workflows/markdownlint.yml\nif ($LASTEXITCODE -ne 0) { throw 'Workflow policy validation failed.' }")),
    markdownlint: codeJob(step('lint', './.github/workflows/Invoke-MarkdownLint.ps1')),
  } },
};

test('valid small workflow interfaces; build requires no Node installation', () => {
  for (const [file, value] of Object.entries(fixtures)) validateWorkflowObject(file, value, contract);
  assert.equal(fixtures['build.yml'].jobs.verify_generated_artifacts.steps.length, 3);
});

test('labels, comments, CRLF, whitespace and literal call quoting are harmless', () => {
  const value = clone(fixtures['markdownlint.yml']);
  value.name = 'New descriptive name';
  const credential = value.jobs.policy.steps[1];
  credential.name = 'Changed label';
  credential.run = "# A harmless comment\r\n  & './.github/workflows/Test-CheckoutCredentials.ps1'  \r\n";
  value.jobs.policy.steps[2].run = '& "./.github/workflows/Initialize-CiToolchain.ps1"   -WorkflowDependencies';
  validateWorkflowObject('markdownlint.yml', value, contract);
});

const cases = JSON.parse(fs.readFileSync(path.join(directory, 'workflow-policy-cases.json'), 'utf8'));
assert.equal(cases.schema, 'PSStyleGuide.WorkflowPolicyCases.v2');
assert.ok(Array.isArray(cases.cases) && cases.cases.length > 0, 'Workflow mutation catalog must contain cases.');
for (const item of cases.cases) {
  test(item.name, () => {
    const value = clone(fixtures[item.workflow]);
    let target = value;
    for (const key of item.path.slice(0, -1)) target = target[key];
    const leaf = item.path.at(-1);
    if (item.operation === 'delete') delete target[leaf];
    else if (item.operation === 'set') target[leaf] = clone(item.value);
    else assert.fail('Unknown test operation');
    assert.throws(() => validateWorkflowObject(item.workflow, value, contract), error => error.category === item.category);
  });
}

for (const [name, source] of [
  ['duplicate mapping keys', 'a: 1\na: 2\n'],
  ['aliases and anchors', 'a: &shared 1\nb: *shared\n'],
  ['explicit tags', 'a: !!str 1\n'],
  ['prototype keys', 'constructor: x\n'],
  ['merge keys', 'a:\n  <<: {x: 1}\n'],
  ['multiple documents', 'a: 1\n---\nb: 2\n'],
  ['non-string keys', '1: x\n'],
  ['invalid UTF8', Buffer.from([0xff])],
]) test('bounded YAML rejects ' + name, () => {
  assert.throws(() => parseStrictYaml(Buffer.isBuffer(source) ? source : Buffer.from(source), LIMITS));
});
test('bounded YAML rejects excessive size and depth', () => {
  assert.throws(() => parseStrictYaml(Buffer.alloc(LIMITS.maximumWorkflowBytes + 1), LIMITS), error => error.category === 'yaml-limit');
  assert.throws(() => parseStrictYaml(Buffer.from('['.repeat(40) + '0' + ']'.repeat(40)), LIMITS), error => error.category === 'yaml-limit');
});

const manifest = JSON.parse(fs.readFileSync(path.join(directory, 'package.json')));
const lock = JSON.parse(fs.readFileSync(path.join(directory, 'package-lock.json')));
test('reviewed locked dependency updates do not need historical hashes or waiver fields', () => {
  const nextManifest = clone(manifest), nextLock = clone(lock);
  nextManifest.devDependencies.glob = '11.0.0';
  nextLock.packages[''].devDependencies.glob = '11.0.0';
  Object.assign(nextLock.packages['node_modules/glob'], {
    version: '11.0.0', resolved: 'https://registry.npmjs.org/glob/-/glob-11.0.0.tgz',
  });
  validatePackagePair(nextManifest, nextLock);
});
for (const [name, change, category] of [
  ['manifest mismatch', value => { value.packages[''].devDependencies.yaml = '0.0.0'; }, 'lock-manifest'],
  ['unlocked direct dependency', value => { delete value.packages['node_modules/yaml']; }, 'lock-direct-dependency'],
  ['missing integrity', value => { delete value.packages['node_modules/yaml'].integrity; }, 'lock-integrity'],
  ['arbitrary archive origin', value => { value.packages['node_modules/yaml'].resolved = 'https://example.test/yaml.tgz'; }, 'lock-integrity'],
  ['linked dependency', value => { value.packages['node_modules/yaml'].link = true; }, 'lock-integrity'],
  ['escaping package path', value => { value.packages['../escape'] = value.packages['node_modules/yaml']; }, 'lock-path'],
]) test('lock rejects ' + name, () => {
  const value = clone(lock); change(value);
  assert.throws(() => validatePackagePair(manifest, value), error => error.category === category);
});

function makeRepository(t, withParser = false) {
  const temporary = fs.mkdtempSync(path.join(os.tmpdir(), 'ps-workflow-policy-'));
  t.after(() => {
    assert.equal(path.dirname(path.resolve(temporary)), path.resolve(os.tmpdir()));
    assert.ok(path.basename(temporary).startsWith('ps-workflow-policy-'));
    fs.rmSync(temporary, { recursive: true, force: true });
  });
  const destination = path.join(temporary, '.github/workflows');
  fs.mkdirSync(destination, { recursive: true });
  for (const file of ['Validate-WorkflowPolicy.mjs', 'workflow-policy-contract.json', 'package.json', 'package-lock.json']) {
    fs.copyFileSync(path.join(directory, file), path.join(destination, file));
  }
  for (const file of ['package.json', 'package-lock.json']) fs.copyFileSync(path.join(root, file), path.join(temporary, file));
  for (const [file, value] of Object.entries(fixtures)) fs.writeFileSync(path.join(destination, file), JSON.stringify(value));
  if (withParser) fs.cpSync(path.join(directory, 'node_modules/yaml'), path.join(destination, 'node_modules/yaml'), { recursive: true });
  const run = (...args) => {
    const result = spawnSync(process.execPath, ['.github/workflows/Validate-WorkflowPolicy.mjs', ...args], { cwd: temporary, encoding: 'utf8', timeout: 30000, windowsHide: true });
    assert.equal(result.error, undefined);
    assert.equal(result.stderr, '');
    return { status: result.status, result: JSON.parse(result.stdout) };
  };
  return { temporary, destination, run };
}
const args = ['.github/workflows/build.yml', '.github/workflows/markdownlint.yml'];
test('built-in preflight works before parser installation; full validation fails closed', t => {
  const fixture = makeRepository(t);
  assert.equal(fixture.run('--preflight').result.success, true);
  assert.equal(fixture.run(...args).status, 1);
});
test('tampered installed parser never executes', t => {
  const fixture = makeRepository(t, true);
  const marker = path.join(fixture.temporary, 'parser-executed');
  fs.appendFileSync(path.join(fixture.destination, 'node_modules/yaml/dist/index.js'), '\nrequire("node:fs").writeFileSync(' + JSON.stringify(marker) + ', "bad");\n');
  const result = fixture.run(...args);
  assert.equal(result.status, 1);
  assert.equal(result.result.category, 'parser-tree-identity');
  assert.equal(fs.existsSync(marker), false);
});
test('accepted parser lock tuple is verified before import', t => {
  const fixture = makeRepository(t, true);
  const value = clone(lock);
  value.packages['node_modules/yaml'].integrity = 'sha512-' + 'A'.repeat(86) + '==';
  fs.writeFileSync(path.join(fixture.destination, 'package-lock.json'), JSON.stringify(value));
  assert.equal(fixture.run(...args).result.category, 'parser-lock-identity');
});
test('parser tree refuses link aliases and bounded traversal overflow', t => {
  const fixture = makeRepository(t);
  const parserDirectory = path.join(fixture.temporary, 'parser');
  fs.mkdirSync(parserDirectory);
  fs.writeFileSync(path.join(parserDirectory, 'one'), 'x');
  const digest = foldParserTree(parserDirectory);
  assertReviewedParserTree(parserDirectory, digest);
  fs.linkSync(path.join(parserDirectory, 'one'), path.join(parserDirectory, 'two'));
  assert.throws(() => foldParserTree(parserDirectory), error => error.category === 'parser-tree-file');
  assert.throws(() => foldParserTree('unused', {
    stat: () => ({ isSymbolicLink: () => false, isDirectory: () => true }),
    *names() { for (let i = 0; i < 513; i++) yield 'entry' + i; },
  }), error => error.category === 'parser-tree-limit');
});
test('candidate revision cannot replace accepted contract or execute candidate validator', t => {
  const fixture = makeRepository(t, true);
  const git = (...parameters) => execFileSync('git', parameters, { cwd: fixture.temporary, encoding: 'utf8', timeout: 10000, windowsHide: true, stdio: ['ignore', 'pipe', 'pipe'] }).trim();
  git('init');
  git('config', 'user.name', 'Fixture'); git('config', 'user.email', 'fixture@example.invalid');
  git('config', 'core.hooksPath', path.join(fixture.temporary, 'no-hooks'));
  git('add', 'package.json', 'package-lock.json', '.github/workflows/package.json', '.github/workflows/package-lock.json', '.github/workflows/build.yml', '.github/workflows/markdownlint.yml');
  git('commit', '-m', 'Fixture');
  const marker = path.join(fixture.temporary, 'candidate-executed');
  const acceptedModule = fs.readFileSync(path.join(fixture.destination, 'Validate-WorkflowPolicy.mjs'));
  const acceptedContract = fs.readFileSync(path.join(fixture.destination, 'workflow-policy-contract.json'));
  fs.writeFileSync(path.join(fixture.destination, 'Validate-WorkflowPolicy.mjs'), 'throw new Error(' + JSON.stringify(marker) + ');');
  fs.writeFileSync(path.join(fixture.destination, 'workflow-policy-contract.json'), '{}');
  git('add', '.github/workflows/Validate-WorkflowPolicy.mjs', '.github/workflows/workflow-policy-contract.json');
  git('commit', '-m', 'Candidate policy is inert');
  const head = git('rev-parse', 'HEAD');
  fs.writeFileSync(path.join(fixture.destination, 'Validate-WorkflowPolicy.mjs'), acceptedModule);
  fs.writeFileSync(path.join(fixture.destination, 'workflow-policy-contract.json'), acceptedContract);
  const candidateResult = fixture.run(...args, '--input-revision', head);
  assert.equal(candidateResult.result.success, true, JSON.stringify(candidateResult));
  const dangerous = clone(fixtures['build.yml']); dangerous.permissions = { contents: 'write' };
  fs.writeFileSync(path.join(fixture.destination, 'build.yml'), JSON.stringify(dangerous));
  git('add', '.github/workflows/build.yml'); git('commit', '-m', 'Dangerous workflow');
  assert.equal(fixture.run(...args, '--input-revision', git('rev-parse', 'HEAD')).result.category, 'workflow-permissions');
});
test('obsolete catalog execution mode is rejected instead of silently claiming coverage', async () => {
  await assert.rejects(main(['--ordinary-case-catalog-data']), error => error.category === 'arguments');
});
