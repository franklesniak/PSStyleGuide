import assert from 'node:assert/strict';
import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { acceptedBase, evaluateFindings, evaluateProposal, hostedAuthorityReference, interpretAudit, parseExceptions, parseJson, validateGraph } from './Check-NpmAudit.mjs';

const id = 'GHSA-abcd-2345-cdef';
const bytes = value => Buffer.from(JSON.stringify(value));
const lock = { packages: { 'node_modules/example': { version: '1.0.0' }, 'node_modules/parent': { version: '2.0.0' } } };
function report(severity) {
  const counts = { info: 0, low: 0, moderate: 0, high: 0, critical: 0, total: severity ? 1 : 0 };
  if (severity) counts[severity] = 1;
  return { auditReportVersion: 2, vulnerabilities: severity ? { example: { name: 'example', severity,
    nodes: ['node_modules/example'], via: [{ source: 1, name: 'example', severity,
      url: `https://github.com/advisories/${id}`, range: '<1.1.0' }] } } : {}, metadata: { vulnerabilities: counts } };
}
function result(value, status = Object.keys(value.vulnerabilities).length ? 1 : 0) {
  return { status, stdout: bytes(value) };
}
const findings = interpretAudit(result(report('high')), '.', lock);
const grant = { root: '.', package: 'example', advisories: [id], nodes: [{ path: 'node_modules/example', version: '1.0.0' }],
  owner: 'maintainer', reason: 'Temporary fixture', controls: ['Bound input'], expires: '2030-01-01T00:00:00Z' };
const now = Date.parse('2026-10-01T00:00:00Z');

test('clean and every severity have the actual info-threshold exit semantics', () => {
  assert.deepEqual(interpretAudit(result(report()), '.', lock), []);
  for (const severity of ['info', 'low', 'moderate', 'high', 'critical']) {
    assert.equal(interpretAudit(result(report(severity)), '.', lock)[0].severity, severity);
    assert.throws(() => interpretAudit(result(report(severity), 0), '.', lock), /native exit/u);
  }
  assert.throws(() => interpretAudit(result(report(), 1), '.', lock), /native exit/u);
});

test('tool, transport, schema and inconsistent-count failures cannot become findings or clean', () => {
  for (const failed of [{ status: 2, stdout: bytes(report()) }, { status: null, signal: 'SIGTERM', stdout: bytes(report()) },
    { status: 1, stdout: bytes({ error: { code: 'ENETUNREACH' } }) },
    result({ ...report(), error: {} }), result({ ...report(), auditReportVersion: 3 })]) {
    assert.throws(() => interpretAudit(failed, '.', lock));
  }
  const inconsistent = report('high'); inconsistent.metadata.vulnerabilities.total = 0;
  assert.throws(() => interpretAudit(result(inconsistent), '.', lock), /total/u);
  assert.throws(() => interpretAudit(result(report('high')), '.', { packages: {} }), /node/u);
});

test('strict bounded JSON rejects truncation, comments, trailing commas, bad UTF8 and duplicate authority keys', () => {
  for (const source of ['{"exceptions":[]', '{"exceptions":[],"exceptions":[]}', '{"exceptions":[],}',
    '{/*comment*/"exceptions":[]}', '{"__proto__":{}}']) assert.throws(() => parseJson(Buffer.from(source)));
  assert.throws(() => parseJson(Buffer.from([0xff])));
  assert.throws(() => parseJson(Buffer.alloc(65537), 65536), /size/u);
  assert.throws(() => parseJson(Buffer.from('['.repeat(33) + '0' + ']'.repeat(33))), /nesting/u);
});

test('package references preserve aggregate scope without inventing direct advisory-to-node pairs', () => {
  const value = report('high');
  value.vulnerabilities.parent = { name: 'parent', severity: 'high', nodes: ['node_modules/parent'], via: ['example'] };
  value.metadata.vulnerabilities.high++; value.metadata.vulnerabilities.total++;
  const interpreted = interpretAudit(result(value), '.', lock);
  const parent = interpreted.find(item => item.package === 'parent');
  assert.deepEqual(parent.directAdvisories, []);
  assert.deepEqual(parent.viaPackages, ['example']);
  assert.deepEqual(parent.advisories, [id]);
  value.vulnerabilities.parent.via = ['missing'];
  assert.throws(() => interpretAudit(result(value), '.', lock), /dangling/u);
  value.vulnerabilities.parent.via = ['example']; value.vulnerabilities.example.via = ['parent'];
  assert.throws(() => interpretAudit(result(value), '.', lock), /cyclic/u);
});

test('valid exception structure is canonical; malformed or duplicate scopes fail', () => {
  const parsed = parseExceptions(bytes({ exceptions: [grant] }));
  assert.equal(parsed[0].package, 'example');
  for (const change of [g => { delete g.owner; }, g => { g.approved = true; }, g => { g.expires = '2026-02-30T00:00:00Z'; },
    g => { g.nodes[0].path = '../escape'; }, g => { g.advisories.push(id); }]) {
    const changed = structuredClone(grant); change(changed);
    assert.throws(() => parseExceptions(bytes({ exceptions: [changed] })));
  }
  assert.throws(() => parseExceptions(bytes({ exceptions: [grant, grant] })), /Duplicate/u);
});

test('accepted risk is separate from clean and does not admit expiry or scope expansion', () => {
  assert.equal(evaluateFindings(findings, [grant], now).status, 'ACCEPTED_RISK');
  assert.equal(evaluateFindings(findings, [], now).status, 'FINDINGS');
  for (const change of [g => { g.root = '.github/workflows'; }, g => { g.package = 'other'; },
    g => { g.expires = '2026-10-01T00:00:00Z'; }, g => { g.nodes[0].version = '0.9.0'; },
    g => { g.advisories = ['GHSA-aaaa-bbbb-cccc']; }]) {
    const changed = structuredClone(grant); change(changed);
    assert.equal(evaluateFindings(findings, [changed], now).status, 'FINDINGS');
  }
  const expanded = structuredClone(findings); expanded[0].advisories.push('GHSA-aaaa-bbbb-cccc');
  assert.equal(evaluateFindings(expanded, [grant], now).status, 'FINDINGS');
  expanded[0].advisories.pop(); expanded[0].nodes.push({ path: 'node_modules/parent/node_modules/example', version: '1.0.0' });
  assert.equal(evaluateFindings(expanded, [grant], now).status, 'FINDINGS');
});

test('risk reduction and unused expired history require no new approval', () => {
  const broad = structuredClone(grant);
  broad.advisories.push('GHSA-aaaa-bbbb-cccc');
  broad.nodes.push({ path: 'node_modules/parent/node_modules/example', version: '1.0.0' });
  assert.equal(evaluateFindings(findings, [broad], now).status, 'ACCEPTED_RISK');
  broad.expires = '2020-01-01T00:00:00Z';
  const clean = evaluateFindings([], [broad], now);
  assert.equal(clean.status, 'CLEAN');
  assert.deepEqual(clean.unusedExceptions, ['.:example']);
});

test('candidate approval fields do not admit risk and equivalent formatting does not create a proposal', () => {
  const accepted = parseExceptions(bytes({ exceptions: [grant] }));
  const reordered = Object.fromEntries(Object.entries(grant).reverse());
  const candidate = parseExceptions(bytes({ exceptions: [reordered] }));
  assert.equal(evaluateProposal(findings, accepted, candidate, now).status, 'ACCEPTED_RISK');
  const proposed = evaluateProposal(findings, [], candidate, now);
  assert.equal(proposed.status, 'PROPOSAL');
  assert.equal(proposed.unresolved.length, 1);
  assert.equal(proposed.acceptedPackages, 0);
  assert.equal(evaluateProposal([], [], [], now).status, 'CLEAN');
});

test('graph problems cannot pass merely because npm returned zero', () => {
  const manifest = { name: 'fixture', version: '1.0.0' };
  const graph = { ...manifest, dependencies: {} };
  assert.equal(validateGraph({ status: 0, stdout: bytes(graph) }, manifest).name, 'fixture');
  for (const mutation of [value => { value.problems = ['extraneous: unwanted@1.0.0']; },
    value => { value.problems = ['missing: dev-tool@1.0.0']; }, value => { value.problems = {}; },
    value => { value.error = {}; }, value => { value.name = 'unrelated'; }, value => { value.version = '2.0.0'; }]) {
    const changed = structuredClone(graph); mutation(changed);
    assert.throws(() => validateGraph({ status: 0, stdout: bytes(changed) }, manifest), /graph/u);
  }
  assert.throws(() => validateGraph({ status: 1, stdout: bytes(graph) }, manifest), /command failed/u);
});

test('hosted authority is the native event base, not candidate or merge identity', () => {
  const base = 'a'.repeat(40), candidate = 'b'.repeat(40), merge = 'c'.repeat(40);
  const environment = { GITHUB_REPOSITORY: 'franklesniak/PSStyleGuide', GITHUB_EVENT_NAME: 'pull_request', GITHUB_SHA: merge };
  const event = { pull_request: { base: { sha: base, ref: 'main', repo: { full_name: environment.GITHUB_REPOSITORY } },
    head: { sha: candidate }, merge_commit_sha: merge } };
  assert.equal(hostedAuthorityReference(environment, event), base);
  const invalid = structuredClone(event); delete invalid.pull_request.base.sha;
  assert.throws(() => hostedAuthorityReference(environment, invalid), /full trusted event base/u);
  invalid.pull_request.base.sha = base; invalid.pull_request.base.ref = 'topic';
  assert.throws(() => hostedAuthorityReference(environment, invalid), /Unexpected PR authority/u);
  assert.equal(hostedAuthorityReference({ ...environment, GITHUB_EVENT_NAME: 'schedule', GITHUB_REF: 'refs/heads/main' }), merge);
  assert.throws(() => hostedAuthorityReference({ ...environment, GITHUB_EVENT_NAME: 'pull_request_target' }), /Unsupported/u);
});

test('a missing accepted record is empty authority; a failed Git read is an error', () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'npm-authority-test-'));
  const git = (args, input) => execFileSync('git', args, { cwd: root, input, encoding: 'utf8', windowsHide: true,
    timeout: 10000, env: { ...process.env, GIT_CONFIG_NOSYSTEM: '1', GIT_CONFIG_GLOBAL: process.platform === 'win32' ? 'NUL' : '/dev/null' } }).trim();
  try {
    assert.throws(() => acceptedBase({ root, environment: {} }), /unavailable/u);
    git(['init', '--quiet']);
    const tree = git(['mktree'], '');
    const commit = git(['-c', 'user.name=Audit fixture', '-c', 'user.email=audit@example.invalid', 'commit-tree', tree], 'fixture\n');
    git(['update-ref', 'refs/remotes/origin/main', commit]);
    fs.mkdirSync(path.join(root, '.github/workflows'), { recursive: true });
    fs.writeFileSync(path.join(root, '.github/workflows/npm-risk-exceptions.json'), bytes({ exceptions: [grant] }));
    const authority = acceptedBase({ root, environment: {} });
    assert.equal(authority.sha, commit);
    assert.deepEqual(authority.exceptions, []);
    assert.match(authority.limitation, /Offline/u);
    // The file in the candidate worktree above cannot supply authority.
    git(['update-ref', '-d', 'refs/remotes/origin/main']);
    assert.throws(() => acceptedBase({ root, environment: {} }), /unavailable/u);
  } finally {
    assert.equal(path.dirname(root), fs.realpathSync(os.tmpdir()));
    assert.ok(path.basename(root).startsWith('npm-authority-test-'));
    fs.rmSync(root, { recursive: true });
  }
});
