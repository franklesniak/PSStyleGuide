import assert from 'node:assert/strict';
import { execFileSync, spawnSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import test from 'node:test';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';
import { expectedRepository, acceptedBase, ciAudit, ciScope, documentationOnlyDiff, evaluateFindings, evaluateProposal, hostedAuthorityReference, interpretAudit, parseExceptions, parseJson, readCandidateExceptions, runAuditCommand, validateGraph } from './Check-NpmAudit.mjs';

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
const directory = path.dirname(fileURLToPath(import.meta.url));
const { parse: parseYaml } = createRequire(import.meta.url)('yaml');

test('CI skips only a complete ordinary-document change, including modes and both rename endpoints', () => {
  const raw = (name, before = '100644', after = '100644', kind = 'M') =>
    `:${before} ${after} ${'a'.repeat(40)} ${'b'.repeat(40)} ${kind}\0${name}\0`;
  const docs = raw('README.md') + raw('docs/new.md', '000000', '100644', 'A') + raw('docs/old.md', '100644', '000000', 'D');
  assert.equal(documentationOnlyDiff(Buffer.from(docs)), true);
  assert.equal(documentationOnlyDiff(Buffer.alloc(0)), true);
  assert.equal(documentationOnlyDiff(Buffer.from(Array.from({ length: 400 }, (_, i) => raw(`docs/${i}.md`)).join(''))), true);
  for (const name of ['package.json', 'package-lock.json', '.github/workflows/package-lock.json',
    '.github/workflows/npm-risk-exceptions.json', '.github/workflows/Check-NpmAudit.mjs', '.github/workflows/markdownlint.yml',
    '.github/workflows/ci-toolchain.json', '.npmrc', '.markdownlint.json', '.pre-commit-config.yaml', '.husky/pre-commit',
    'AGENTS.md', 'tools/AGENTS.override.md', 'AGENTS.override.md', 'docs/GEMINI.md', 'GEMINI.md',
    'docs/CLAUDE.md', 'CLAUDE.local.md', 'docs/SKILL.md', 'copilot-instructions.md', 'powershell.instructions.md',
    'docs/terraform.instructions.md', '.github/notes.md', 'docs/.hidden/note.md', 'tool.js']) {
    assert.equal(documentationOnlyDiff(Buffer.from(docs + raw(name))), false, name);
  }
  for (const mode of ['100755', '120000', '160000']) {
    assert.equal(documentationOnlyDiff(Buffer.from(raw('docs/changed.md', mode))), false);
    assert.equal(documentationOnlyDiff(Buffer.from(raw('docs/changed.md', '100644', mode))), false);
  }
  assert.equal(documentationOnlyDiff(Buffer.from(raw('tool.js', '100644', '000000', 'D') + raw('docs/tool.md', '000000', '100644', 'A'))), false);
  for (const invalid of [docs.slice(0, -1), docs + 'partial\0', raw('../escape.md'), raw('docs/line\nbreak.md'),
    raw('docs/name.md', '100644', '100644', 'R100')]) assert.throws(() => documentationOnlyDiff(Buffer.from(invalid)));
  assert.throws(() => documentationOnlyDiff(Buffer.alloc(2 * 1024 * 1024 + 1)), /size/u);
  assert.throws(() => documentationOnlyDiff(Buffer.from([0xff])));
});

test('CI scope uses real complete Git endpoints; mismatches and unavailable objects cannot skip', () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'npm-audit-scope-'));
  const git = (...args) => execFileSync('git', ['-c', 'core.hooksPath=/dev/null', ...args], {
    cwd: root, encoding: 'utf8', windowsHide: true, timeout: 10000,
    env: { ...process.env, GIT_CONFIG_NOSYSTEM: '1', GIT_CONFIG_GLOBAL: process.platform === 'win32' ? 'NUL' : '/dev/null' },
  }).trim();
  try {
    git('init', '--quiet');
    const commit = message => {
      git('add', '--all');
      git('-c', 'user.name=Audit fixture', '-c', 'user.email=audit@example.invalid', 'commit', '--quiet', '-m', message);
      return git('rev-parse', 'HEAD');
    };
    fs.writeFileSync(path.join(root, 'README.md'), '# Before\n');
    fs.writeFileSync(path.join(root, 'tool.js'), 'export const value = 1;\n');
    const base = commit('base');
    fs.writeFileSync(path.join(root, 'README.md'), '# After\n');
    const docs = commit('docs');
    const eventPath = path.join(root, 'event.json');
    fs.writeFileSync(eventPath, bytes({ pull_request: { base: { sha: base, ref: 'topic', repo: { full_name: expectedRepository } } } }));
    const environment = { GITHUB_ACTIONS: 'true', GITHUB_EVENT_NAME: 'pull_request', GITHUB_SHA: docs,
      GITHUB_REPOSITORY: expectedRepository, GITHUB_EVENT_PATH: eventPath };
    const scope = () => ciScope({ root, environment });
    assert.equal(scope().applicable, false);
    assert.throws(() => ciScope({ root, environment: { ...environment, GITHUB_SHA: base } }), /checkout mismatch/u);
    git('mv', 'tool.js', 'tool.md');
    environment.GITHUB_SHA = commit('rename executable source to prose');
    assert.equal(scope().applicable, true);
    for (const event of ['push', 'schedule', 'workflow_dispatch']) {
      assert.equal(ciScope({ root, environment: { ...environment, GITHUB_EVENT_NAME: event, GITHUB_REF: 'refs/heads/main' } }).applicable, true);
    }
    assert.throws(() => ciScope({ root, environment: {}, authority: { sha: base } }), /hosted event/u);
  } finally {
    assert.equal(fs.realpathSync(path.dirname(root)), fs.realpathSync(os.tmpdir()));
    assert.ok(path.basename(root).startsWith('npm-audit-scope-'));
    fs.rmSync(root, { recursive: true });
  }
});

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
  for (const native of [
    { status: 1, stdout: bytes({ error: { code: 'ENOTFOUND' } }), stderr: Buffer.from('Registry DNS failure') },
    { status: 1, stdout: bytes({ error: { code: 'E403' }, statusCode: 403 }), stderr: Buffer.from('Access denied') },
    { status: 2, stdout: Buffer.alloc(0), stderr: Buffer.from('Native audit failure') },
    { status: 1, stdout: Buffer.from('{'), stderr: Buffer.from('Connection reset') },
    { status: 0, stdout: Buffer.from('{'), stderr: Buffer.from('Invalid output') },
  ]) {
    let calls = 0;
    assert.throws(() => interpretAudit(runAuditCommand(() => { calls++; return native; }, '.github/workflows',
      () => assert.fail('Unexpected retry')), '.github/workflows', lock), error => {
      assert.ok(error.message.includes('.github/workflows'));
      assert.ok(error.message.includes(`exit ${native.status}`));
      assert.ok(error.message.includes(native.stderr.toString()));
      if (native.stdout.includes('ENOTFOUND')) assert.match(error.message, /ENOTFOUND/u);
      if (native.stdout.includes('E403')) assert.match(error.message, /E403; HTTP 403/u);
      return true;
    });
    assert.equal(calls, 1);
  }
  assert.throws(() => interpretAudit({ status: 1,
    stdout: bytes({ error: { code: 'E'.repeat(1000) }, statusCode: 503 }),
    stderr: Buffer.from('x'.repeat(10000)) }, '.', lock), error => {
    assert.ok(error.message.length < 4400);
    assert.ok(error.message.includes('E'.repeat(128)));
    assert.ok(!error.message.includes('E'.repeat(129)));
    assert.ok(error.message.includes('x'.repeat(4096)));
    assert.ok(!error.message.includes('x'.repeat(4097)));
    return true;
  });
});

test('strict bounded JSON rejects truncation, comments, trailing commas, bad UTF8 and duplicate authority keys', () => {
  for (const source of ['{"exceptions":[]', '{"exceptions":[],"exceptions":[]}', '{"exceptions":[],}',
    '{/*comment*/"exceptions":[]}', '{"__proto__":{}}']) assert.throws(() => parseJson(Buffer.from(source)));
  assert.throws(() => parseJson(Buffer.from([0xff])));
  assert.throws(() => parseJson(Buffer.concat([Buffer.from([0xef, 0xbb, 0xbf]), bytes(report())])), /BOM/u);
  assert.throws(() => parseExceptions(Buffer.concat([Buffer.from([0xef, 0xbb, 0xbf]), bytes({ exceptions: [] })])), /BOM/u);
  assert.throws(() => parseJson(Buffer.alloc(65537), 65536), /size/u);
  assert.throws(() => parseJson(Buffer.from('['.repeat(33) + '0' + ']'.repeat(33))), /nesting/u);
});

test('only a recognized transient audit POST failure gets one bounded retry', () => {
  const temporary = { statusCode: 503, method: 'POST', uri: 'https://registry.npmjs.org/-/npm/v1/security/advisories/bulk', error: {} };
  const transport = value => ({ status: 1, stdout: bytes(value) });
  let calls = 0, waits = 0;
  const recovered = runAuditCommand(() => ++calls === 1 ? transport(temporary) : result(report()), '.', () => waits++);
  assert.deepEqual(interpretAudit(recovered, '.', lock), []);
  assert.equal(calls, 2); assert.equal(waits, 1);
  calls = 0;
  const failed = runAuditCommand(() => { calls++; return transport(temporary); }, '.', () => {});
  assert.equal(calls, 2);
  assert.throws(() => interpretAudit(failed, '.', lock), /Unsupported/u);
  for (const native of [result(report()), result(report('high')), transport({ ...temporary, statusCode: 401 }),
    transport({ ...temporary, uri: 'https://unexpected.example/' }), transport({ ...temporary, method: 'GET' }),
    transport({ ...temporary, auditReportVersion: 2 }), transport({ ...temporary, statusCode: undefined }),
    { status: 2, stdout: bytes(temporary) }, { status: null, signal: 'SIGTERM', stdout: bytes(temporary) }]) {
    calls = 0;
    assert.equal(runAuditCommand(() => { calls++; return native; }, '.', () => assert.fail('Unexpected wait')), native);
    assert.equal(calls, 1);
  }
  assert.throws(() => runAuditCommand(() => ({ status: 1, stdout: Buffer.from('{') }), '.', () => assert.fail('Unexpected wait')), /JSON/u);
  assert.throws(() => runAuditCommand(() => { throw new Error('launch failed'); }, '.', () => assert.fail('Unexpected wait')), /launch failed/u);
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
  assert.throws(() => interpretAudit(result(value), '.', lock), /no reachable direct advisory/u);
});

test('native npm cycle shape preserves every reachable advisory and excludes unrelated scope', () => {
  const yamlId = 'GHSA-r3ph-w7gj-g6xm', markdownId = 'GHSA-253c-mchw-3w2r';
  const direct = (name, advisory) => ({ source: 1, name, severity: 'high', range: '<2.0.0',
    url: `https://github.com/advisories/${advisory}` });
  // The actual npm CLI/formatter cycle; irrelevant report fields are omitted.
  const references = {
    'js-yaml': [direct('js-yaml', yamlId)],
    'markdown-it': [direct('markdown-it', markdownId)],
    'markdownlint-cli2': ['markdownlint-cli2-formatter-default', 'js-yaml', 'markdown-it'],
    'markdownlint-cli2-formatter-default': ['markdownlint-cli2'],
    unrelated: [direct('unrelated', id)],
  };
  const graphLock = { packages: {} }, vulnerabilities = {};
  for (const [name, via] of Object.entries(references)) {
    graphLock.packages[`node_modules/${name}`] = { version: '1.0.0' };
    vulnerabilities[name] = { name, severity: 'high', via, nodes: [`node_modules/${name}`] };
  }
  const value = { auditReportVersion: 2, vulnerabilities,
    metadata: { vulnerabilities: { info: 0, low: 0, moderate: 0, high: 5, critical: 0, total: 5 } } };
  for (const entries of [Object.entries(vulnerabilities), Object.entries(vulnerabilities).reverse()]) {
    value.vulnerabilities = Object.fromEntries(entries);
    const interpreted = interpretAudit(result(value), '.', graphLock);
    for (const name of ['markdownlint-cli2', 'markdownlint-cli2-formatter-default']) {
      const finding = interpreted.find(item => item.package === name);
      assert.deepEqual(finding.advisories, [markdownId, yamlId]);
      assert.deepEqual(finding.directAdvisories, []);
      const exception = { ...grant, package: name, advisories: [markdownId, yamlId], nodes: finding.nodes };
      assert.equal(evaluateFindings([finding], [exception], now).status, 'ACCEPTED_RISK');
      assert.equal(evaluateFindings([finding], [{ ...exception, advisories: [yamlId] }], now).status, 'FINDINGS');
    }
    assert.deepEqual(interpreted.find(item => item.package === 'unrelated').advisories, [id]);
  }
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

test('graph failures name the root and retain short native causes without dumping the graph', () => {
  const manifest = { name: 'fixture', version: '1.0.0' };
  const graph = { ...manifest, problems: ['missing: useful-tool@1.0.0', 'extraneous: old-tool@0.1.0'] };
  for (const status of [0, 1]) {
    assert.throws(() => validateGraph({ status, stdout: bytes(graph), stderr: Buffer.from('native graph diagnostic') }, manifest, '.github/workflows'), error => {
      assert.match(error.message, /^\.github\/workflows: Installed graph/u);
      assert.match(error.message, /missing: useful-tool@1\.0\.0/u);
      assert.match(error.message, /extraneous: old-tool@0\.1\.0/u);
      assert.match(error.message, /native graph diagnostic/u);
      return true;
    });
  }
  graph.problems = Array.from({ length: 20 }, (_, index) => `${index}:` + 'x'.repeat(5000));
  assert.throws(() => validateGraph({ status: 1, stdout: bytes(graph), stderr: Buffer.from('y'.repeat(10000)) }, manifest), error => {
    assert.ok(error.message.length < 25000);
    assert.doesNotMatch(error.message, /5:xxxx/u);
    return true;
  });
  assert.throws(() => validateGraph({ status: 17, stdout: Buffer.from('truncated'), stderr: Buffer.from('native failure') }, manifest, '.'), error => {
    assert.match(error.message, /exit 17/u);
    assert.match(error.message, /native failure/u);
    return true;
  });
});

test('ordinary CLI keeps local authority under agent variables and reports parser failures', () => {
  const root = fs.mkdtempSync(path.join(os.tmpdir(), 'npm-audit-missing-parser-'));
  const directory = path.join(root, '.github/workflows');
  const env = Object.fromEntries(Object.entries(process.env).filter(([key]) => !/^(?:GIT_|NODE_PATH$)/iu.test(key)));
  Object.assign(env, { GIT_CONFIG_NOSYSTEM: '1', GIT_CONFIG_GLOBAL: process.platform === 'win32' ? 'NUL' : '/dev/null' });
  Object.assign(env, { GITHUB_ACTIONS: 'true', GITHUB_EVENT_NAME: 'dynamic',
    GITHUB_REPOSITORY: expectedRepository, GITHUB_REF: 'refs/heads/copilot/proposal', GITHUB_SHA: 'a'.repeat(40) });
  const git = (...args) => execFileSync('git', args, { cwd: root, env, encoding: 'utf8', windowsHide: true, timeout: 10000 }).trim();
  try {
    fs.mkdirSync(directory, { recursive: true });
    for (const name of ['Check-NpmAudit.mjs', 'NpmTools.mjs']) {
      fs.copyFileSync(fileURLToPath(new URL(name, import.meta.url)), path.join(directory, name));
    }
    git('init', '--quiet');
    git('add', '--all');
    git('-c', 'core.hooksPath=/dev/null', '-c', 'user.name=Audit fixture', '-c', 'user.email=audit@example.invalid', 'commit', '--quiet', '-m', 'Fixture');
    git('update-ref', 'refs/remotes/origin/main', git('rev-parse', 'HEAD'));
    const parser = path.join(directory, 'node_modules/jsonc-parser');
    fs.mkdirSync(parser, { recursive: true });
    // A local broken entry prevents an unrelated ancestor package satisfying this fixture.
    fs.writeFileSync(path.join(parser, 'package.json'), JSON.stringify({ main: 'index.cjs' }));
    const result = spawnSync(process.execPath, [path.join(directory, 'Check-NpmAudit.mjs')], {
      cwd: root, env, encoding: 'utf8', windowsHide: true, timeout: 15000,
    });
    assert.equal(result.error, undefined);
    assert.equal(result.status, 2);
    const failure = JSON.parse(result.stderr);
    assert.equal(failure.status, 'ERROR');
    assert.match(failure.message, /Cannot load the audit parser/u);
    assert.match(failure.message, /MODULE_NOT_FOUND/u);
    assert.match(failure.message, /node \.github\/workflows\/NpmTools\.mjs install/u);
    assert.equal(result.stdout, '');
    fs.writeFileSync(path.join(parser, 'index.cjs'), 'module.exports = ;');
    const malformed = spawnSync(process.execPath, [path.join(directory, 'Check-NpmAudit.mjs')], {
      cwd: root, env, encoding: 'utf8', windowsHide: true, timeout: 15000,
    });
    assert.equal(malformed.status, 2);
    const malformedFailure = JSON.parse(malformed.stderr);
    assert.equal(malformedFailure.status, 'ERROR');
    assert.match(malformedFailure.message, /SyntaxError/u);
    assert.match(malformedFailure.message, /Correct the reported cause/u);
  } finally {
    assert.equal(fs.realpathSync(path.dirname(root)), fs.realpathSync(os.tmpdir()));
    assert.ok(path.basename(root).startsWith('npm-audit-missing-parser-'));
    fs.rmSync(root, { recursive: true });
  }
});

test('hosted authority is the native event base, not candidate or merge identity', () => {
  const base = 'a'.repeat(40), candidate = 'b'.repeat(40), merge = 'c'.repeat(40);
  const environment = { GITHUB_REPOSITORY: expectedRepository, GITHUB_EVENT_NAME: 'pull_request', GITHUB_SHA: merge };
  const event = { pull_request: { base: { sha: base, ref: 'main', repo: { full_name: environment.GITHUB_REPOSITORY } },
    head: { sha: candidate }, merge_commit_sha: merge } };
  assert.equal(hostedAuthorityReference(environment, event), base);
  const invalid = structuredClone(event); delete invalid.pull_request.base.sha;
  assert.throws(() => hostedAuthorityReference(environment, invalid), /full trusted event base/u);
  invalid.pull_request.base.sha = base; invalid.pull_request.base.ref = 'topic';
  assert.equal(hostedAuthorityReference(environment, invalid), 'refs/heads/main');
  assert.equal(hostedAuthorityReference({ ...environment, GITHUB_EVENT_NAME: 'schedule', GITHUB_REF: 'refs/heads/main' }), merge);
  assert.throws(() => hostedAuthorityReference({ ...environment, GITHUB_EVENT_NAME: 'schedule', GITHUB_REF: 'refs/heads/main', GITHUB_REPOSITORY: 'franklesniak/Other' }), /Unexpected audit repository/u);
  assert.throws(() => hostedAuthorityReference({ ...environment, GITHUB_EVENT_NAME: 'schedule', GITHUB_REF: 'refs/heads/copilot/proposal' }), /must be the main branch/u);
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
    const agentEnvironment = { GITHUB_ACTIONS: 'true', GITHUB_EVENT_NAME: 'dynamic',
      GITHUB_REPOSITORY: expectedRepository, GITHUB_REF: 'refs/heads/copilot/proposal', GITHUB_SHA: 'a'.repeat(40) };
    const agentAuthority = acceptedBase({ root, environment: agentEnvironment });
    assert.equal(agentAuthority.sha, commit);
    assert.deepEqual(agentAuthority.exceptions, []);
    assert.match(agentAuthority.limitation, /Offline/u);
    assert.throws(() => ciAudit({ root, environment: agentEnvironment }), /Unsupported hosted audit event/u);
    assert.throws(() => ciAudit({ root, environment: {} }), /requires a hosted event/u);
    // An available exact main commit needs no remote or extra network fetch.
    const hosted = acceptedBase({ root, hosted: true, environment: { GITHUB_ACTIONS: 'true', GITHUB_REPOSITORY: expectedRepository,
      GITHUB_EVENT_NAME: 'schedule', GITHUB_REF: 'refs/heads/main', GITHUB_SHA: commit } });
    assert.equal(hosted.sha, commit);
    assert.deepEqual(hosted.exceptions, []);
    const candidateFile = path.join(root, '.github/workflows/npm-risk-exceptions.json');
    fs.unlinkSync(candidateFile);
    assert.deepEqual(readCandidateExceptions(root), []);
    assert.equal(evaluateProposal([], [grant], readCandidateExceptions(root), now).status, 'PROPOSAL');
    fs.writeFileSync(candidateFile, '{');
    assert.throws(() => readCandidateExceptions(root), /JSON/u);
    fs.unlinkSync(candidateFile); fs.mkdirSync(candidateFile);
    assert.throws(() => readCandidateExceptions(root), /regular JSON input/u);
    // The file in the candidate worktree above cannot supply authority.
    git(['update-ref', '-d', 'refs/remotes/origin/main']);
    assert.throws(() => acceptedBase({ root, environment: {} }), /unavailable/u);
    assert.throws(() => acceptedBase({ root, environment: agentEnvironment }), /unavailable/u);
  } finally {
    assert.equal(fs.realpathSync(path.dirname(root)), fs.realpathSync(os.tmpdir()));
    assert.ok(path.basename(root).startsWith('npm-authority-test-'));
    fs.rmSync(root, { recursive: true });
  }
});

// Execute the unchanged audit entry point with real Git objects. Only the fixed
// HTTPS fetch destination and npm process boundary are substituted. No registry
// or remote GitHub service is contacted by these fixtures.
function hostedFixture(t) {
  const temporary = fs.mkdtempSync(path.join(os.tmpdir(), 'npm-hosted-authority-'));
  t.after(() => {
    assert.equal(fs.realpathSync(path.dirname(temporary)), fs.realpathSync(os.tmpdir()));
    assert.ok(path.basename(temporary).startsWith('npm-hosted-authority-'));
    fs.rmSync(temporary, { recursive: true, force: true });
  });
  const root = path.join(temporary, 'work'), destination = path.join(root, '.github/workflows');
  fs.mkdirSync(destination, { recursive: true });
  const env = { ...process.env, GIT_CONFIG_NOSYSTEM: '1',
    GIT_CONFIG_GLOBAL: process.platform === 'win32' ? 'NUL' : '/dev/null' };
  const git = (...args) => execFileSync('git', ['-c', 'core.hooksPath=/dev/null', ...args], {
    cwd: root, env, encoding: 'utf8', windowsHide: true, timeout: 10000,
  }).trim();
  git('init', '--quiet');
  fs.copyFileSync(path.join(directory, 'Check-NpmAudit.mjs'), path.join(destination, 'Check-NpmAudit.mjs'));
  fs.copyFileSync(path.join(directory, 'NpmTools.mjs'), path.join(destination, 'NpmTools.real.mjs'));
  fs.cpSync(path.join(directory, 'node_modules/jsonc-parser'), path.join(destination, 'node_modules/jsonc-parser'), { recursive: true });
  fs.writeFileSync(path.join(destination, 'NpmTools.mjs'), `
import fs from 'node:fs';
import assert from 'node:assert/strict';
import { pathToFileURL } from 'node:url';
import { runBounded as realRun, repositoryRoot } from './NpmTools.real.mjs';
export { repositoryRoot };
const log = value => fs.appendFileSync(process.env.FIXTURE_LOG, JSON.stringify(value)+'\\n');
export function runBounded(executable, args, options) {
  log(['git', ...args]);
  const mode = process.env.FIXTURE_MODE;
  if (args.includes('cat-file') && args.at(-1) === process.env.FIXTURE_FORCE_BASE+'^{commit}')
    return {status:1,stdout:Buffer.alloc(0)};
  if (args.includes('fetch')) {
    assert.equal(executable, 'git');
    assert.equal(options.timeout, 30000);
    for (const flag of ['core.hooksPath=/dev/null','core.fsmonitor=false','credential.helper=','http.extraheader=',
      '--depth=1','--no-tags','--no-recurse-submodules']) assert.ok(args.includes(flag), flag);
    assert.equal(options.env.GIT_NO_REPLACE_OBJECTS, '1');
    assert.equal(options.env.GIT_CONFIG_NOSYSTEM, '1');
    assert.equal(options.env.GIT_TERMINAL_PROMPT, '0');
    assert.equal(args.at(-2), ${JSON.stringify(`https://github.com/${expectedRepository}`)});
    assert.ok(args.at(-1) === 'refs/heads/main' || /^[a-f0-9]{40}$/.test(args.at(-1)));
    if (mode === 'fetch-failure') return {status:7,stdout:Buffer.alloc(0)};
    if (mode === 'fetch-timeout') throw new Error('Fixture bounded fetch timeout');
    args = [...args]; args[args.length-2] = pathToFileURL(process.env.FIXTURE_REMOTE).href;
  }
  if (args.includes('rev-parse') && args.at(-1) === 'FETCH_HEAD^{commit}') {
    if (mode === 'bad-fetch-output') return {status:0,stdout:Buffer.from('a'.repeat(40)+'\\n'+'b'.repeat(40))};
    if (mode === 'zero-fetch-output') return {status:0,stdout:Buffer.from('0'.repeat(40))};
  }
  if (args.includes('rev-parse') && mode === 'base-mismatch' && args.at(-1) === process.env.FIXTURE_BASE+'^{commit}')
    return {status:0,stdout:Buffer.from('f'.repeat(40))};
  if (args.includes('show') && mode === 'blob-failure') return {status:9,stdout:Buffer.alloc(0)};
  if (args.includes('diff') && mode === 'incomplete-diff') return {status:0,stdout:Buffer.from('incomplete')};
  return realRun(executable, args, options);
}
export function withNpmEnvironment(callback) {
  return callback({runNpm(args, scope) {
    log(['npm',scope,...args]);
    if (args[0] === 'ls') return {status:0,stdout:Buffer.from(JSON.stringify({name:'fixture',version:'1.0.0'}))};
    return {status:process.env.FIXTURE_FINDING === 'yes' ? 1 : 0,
      stdout:Buffer.from(process.env.FIXTURE_FINDING === 'yes' ? ${JSON.stringify(JSON.stringify(report('high')))} : ${JSON.stringify(JSON.stringify(report()))})};
  }});
}
`);
  for (const scope of [root, destination]) {
    fs.writeFileSync(path.join(scope, 'package.json'), bytes({ name: 'fixture', version: '1.0.0' }));
    fs.writeFileSync(path.join(scope, 'package-lock.json'), bytes(lock));
  }
  const exceptions = records => fs.writeFileSync(path.join(destination, 'npm-risk-exceptions.json'), bytes({ exceptions: records }));
  exceptions([]);
  fs.writeFileSync(path.join(root, 'README.md'), '# Initial\n');
  fs.writeFileSync(path.join(root, 'tool.js'), 'original\n');
  const commit = message => {
    git('add', '--all');
    git('-c', 'user.name=Audit fixture', '-c', 'user.email=audit@example.invalid', 'commit', '--quiet', '-m', message);
    return git('rev-parse', 'HEAD');
  };
  const main = commit('accepted main');
  fs.writeFileSync(path.join(root, 'tool.js'), 'target change\n');
  const base = commit('non-main target');
  fs.writeFileSync(path.join(root, 'README.md'), '# Proposal\n');
  const docs = commit('prose on target');
  fs.writeFileSync(path.join(root, 'tool.js'), 'original\n');
  const head = commit('revert target tool change');
  const remote = path.join(temporary, 'accepted.git');
  git('clone', '--quiet', '--bare', root, remote);
  git('--git-dir', remote, 'update-ref', 'refs/heads/main', main);
  // Poisoned local tracking state must not authorize the current candidate.
  git('update-ref', 'refs/remotes/origin/main', head);
  const eventPath = path.join(temporary, 'event.json'), log = path.join(temporary, 'calls.jsonl');
  const event = (sha = base, ref = 'topic', repository = expectedRepository) => fs.writeFileSync(eventPath,
    bytes({ pull_request: { base: { sha, ref, repo: { full_name: repository } } } }));
  const pushEvent = created => fs.writeFileSync(eventPath, bytes({ created,
    before: created ? '0'.repeat(40) : base, after: head, deleted: false }));
  event();
  const run = (overrides = {}, command) => {
    fs.writeFileSync(log, '');
    const result = spawnSync(command ? 'pwsh' : process.execPath,
      command ? ['-NoProfile', '-NonInteractive', '-Command', command] : [path.join(destination, 'Check-NpmAudit.mjs'), '--ci'], {
        cwd: root, encoding: 'utf8', timeout: 30000, windowsHide: true,
        env: { ...env, GITHUB_ACTIONS: 'true', GITHUB_EVENT_NAME: 'push', GITHUB_REF: 'refs/heads/topic',
          GITHUB_REPOSITORY: expectedRepository, GITHUB_SHA: git('rev-parse', 'HEAD'), GITHUB_EVENT_PATH: eventPath,
          FIXTURE_REMOTE: remote, FIXTURE_LOG: log, FIXTURE_BASE: base, ...overrides },
      });
    assert.equal(result.error, undefined, result.stderr);
    assert.equal(result.signal, null, result.stderr);
    return { ...result, calls: fs.readFileSync(log, 'utf8').trim().split('\n').filter(Boolean).map(JSON.parse),
      value: command ? undefined : JSON.parse(result.status === 2 ? result.stderr : result.stdout) };
  };
  return { root, destination, git, main, base, docs, head, remote, event, pushEvent, exceptions, commit, run };
}

test('hosted live branches and tags use fetched main; exact main events keep their snapshot', t => {
  const f = hostedFixture(t);
  for (const ref of ['refs/heads/topic', 'refs/heads/main-fix', 'refs/heads/Main', 'refs/tags/v1', 'refs/tags/main']) {
    for (const created of [true, false]) {
      f.pushEvent(created);
      const result = f.run({ GITHUB_REF: ref });
      assert.equal(result.status, 0, result.stderr);
      assert.equal(result.value.status, 'CLEAN');
      assert.equal(result.value.authority, f.main);
      assert.equal(result.value.authoritySource, 'remote-main');
      assert.equal(result.calls.filter(row => row.includes('fetch')).length, 1);
      assert.equal(result.calls.filter(row => row[0] === 'npm' && row.includes('audit')).length, 2);
    }
  }
  for (const event of ['push', 'schedule', 'workflow_dispatch']) {
    const result = f.run({ GITHUB_EVENT_NAME: event, GITHUB_REF: 'refs/heads/main', GITHUB_SHA: f.main });
    assert.equal(result.status, 0, result.stderr);
    assert.equal(result.value.authority, f.main);
    assert.equal(result.value.authoritySource, 'event-main');
    assert.equal(result.calls.filter(row => row.includes('fetch')).length, 0);
  }
  for (const overrides of [
    { GITHUB_REF: 'refs/heads/bad..name' }, { GITHUB_REF: 'refs/tags/bad tag' },
    { GITHUB_REF: 'main' }, { GITHUB_REF: 'refs/pull/1/merge' }, { GITHUB_REF: '' },
    { GITHUB_SHA: '0'.repeat(40) }, { GITHUB_SHA: 'short' },
    { GITHUB_REPOSITORY: 'other/repository' }, { GITHUB_EVENT_NAME: 'dynamic' },
    { GITHUB_EVENT_NAME: 'schedule' }, { GITHUB_EVENT_NAME: 'workflow_dispatch' },
    { GITHUB_EVENT_NAME: 'pull_request_target' },
  ]) {
    const result = f.run(overrides);
    assert.equal(result.status, 2, JSON.stringify(overrides));
    assert.equal(result.calls.some(row => row.includes('fetch') || row[0] === 'npm'), false);
  }
});

test('PR applicability uses actual target B, independently of accepted main A', t => {
  const f = hostedFixture(t);
  f.git('checkout', '--quiet', '--detach', f.docs);
  const docs = f.run({ GITHUB_EVENT_NAME: 'pull_request', FIXTURE_FORCE_BASE: f.base });
  assert.equal(docs.status, 0, docs.stderr);
  assert.equal(docs.value.status, 'NOT_APPLICABLE');
  assert.equal(docs.value.base, f.base);
  assert.equal(docs.value.head, f.docs);
  assert.equal(docs.value.authority, f.main);
  assert.equal(docs.value.authoritySource, 'remote-main');
  assert.deepEqual(docs.calls.filter(row => row.includes('fetch')).map(row => row.at(-1)), ['refs/heads/main', f.base]);
  assert.equal(docs.calls.some(row => row[0] === 'npm'), false);
  f.git('checkout', '--quiet', '--detach', f.head);
  const code = f.run({ GITHUB_EVENT_NAME: 'pull_request' });
  assert.equal(code.status, 0, code.stderr);
  assert.equal(code.value.applicable, true); // A->H is prose; B->H changes tool.js.
  assert.equal(code.value.base, f.base);
  assert.equal(code.calls.filter(row => row[0] === 'npm' && row.includes('audit')).length, 2);
  f.event(f.main, 'main');
  const mainPR = f.run({ GITHUB_EVENT_NAME: 'pull_request' });
  assert.equal(mainPR.value.status, 'NOT_APPLICABLE');
  assert.equal(mainPR.value.authority, f.main);
  assert.equal(mainPR.value.authoritySource, 'event-main');
  assert.equal(mainPR.calls.some(row => row.includes('fetch')), false);
  f.event();
  for (const overrides of [{ GITHUB_SHA: f.main }, { FIXTURE_MODE: 'incomplete-diff' }, { FIXTURE_MODE: 'base-mismatch' }]) {
    assert.equal(f.run({ GITHUB_EVENT_NAME: 'pull_request', ...overrides }).status, 2);
  }
  f.event('f'.repeat(40));
  assert.equal(f.run({ GITHUB_EVENT_NAME: 'pull_request' }).status, 2);
  f.event(f.base, 'bad..branch');
  assert.equal(f.run({ GITHUB_EVENT_NAME: 'pull_request' }).status, 2);
  f.event(f.base, 'topic', 'other/repository');
  const foreign = f.run({ GITHUB_EVENT_NAME: 'pull_request' });
  assert.equal(foreign.status, 2);
  assert.match(foreign.value.message, /Unexpected PR authority repository/);
  assert.equal(foreign.calls.some(row => row.includes('fetch') || row[0] === 'npm'), false);
});

test('candidate grants and unavailable main cannot become accepted hosted authority', t => {
  const f = hostedFixture(t);
  f.exceptions([grant]);
  const proposed = f.commit('candidate grant');
  f.git('update-ref', 'refs/remotes/origin/main', proposed);
  const candidate = f.run({ FIXTURE_FINDING: 'yes' });
  assert.equal(candidate.status, 3, candidate.stderr);
  assert.equal(candidate.value.status, 'PROPOSAL');
  assert.equal(candidate.value.acceptedPackages, 0);
  assert.equal(candidate.value.authority, f.main);
  f.event(proposed);
  fs.writeFileSync(path.join(f.root, 'tool.js'), 'new candidate change\n');
  f.commit('change above target grant');
  const target = f.run({ GITHUB_EVENT_NAME: 'pull_request', FIXTURE_FINDING: 'yes' });
  assert.equal(target.value.status, 'PROPOSAL');
  assert.equal(target.value.authority, f.main);
  assert.equal(target.value.acceptedPackages, 0);
  for (const mode of ['fetch-failure', 'fetch-timeout', 'bad-fetch-output', 'zero-fetch-output', 'blob-failure']) {
    const result = f.run({ FIXTURE_MODE: mode });
    assert.equal(result.status, 2, mode);
    assert.equal(result.value.status, 'ERROR');
    assert.equal(result.calls.some(row => row[0] === 'npm'), false);
  }
  f.exceptions([]);
  assert.equal(f.run({ FIXTURE_FINDING: 'yes' }).value.status, 'FINDINGS');
});

test('fetched main preserves legitimate, expired and malformed exception semantics', t => {
  const f = hostedFixture(t);
  const publish = records => {
    f.exceptions(records);
    const sha = f.commit('fixture accepted state');
    f.git('--git-dir', f.remote, 'fetch', '--quiet', f.root, sha);
    f.git('--git-dir', f.remote, 'update-ref', 'refs/heads/main', sha);
    return sha;
  };
  const grants = [grant, { ...grant, root: '.github/workflows' }];
  const accepted = publish(grants);
  const result = f.run({ FIXTURE_FINDING: 'yes' });
  assert.equal(result.status, 0, result.stderr);
  assert.equal(result.value.status, 'ACCEPTED_RISK');
  assert.equal(result.value.authority, accepted);
  assert.equal(result.value.acceptedPackages, 2);
  publish(grants.map(value => ({ ...value, expires: '2000-01-01T00:00:00Z' })));
  assert.equal(f.run({ FIXTURE_FINDING: 'yes' }).value.status, 'FINDINGS');
  publish([grant, grant]);
  const invalid = f.run();
  assert.equal(invalid.status, 2);
  assert.match(invalid.value.message, /Duplicate package exception/);
  assert.equal(invalid.calls.some(row => row[0] === 'npm'), false);
});

test('the actual YAML audit step preserves hosted success and native failure', t => {
  const f = hostedFixture(t);
  const workflow = parseYaml(fs.readFileSync(path.join(directory, 'markdownlint.yml'), 'utf8'));
  const command = workflow.jobs.markdownlint.steps.find(step => step.id === 'audit').run;
  const clean = f.run({}, command);
  assert.equal(clean.status, 0, clean.stderr);
  assert.equal(JSON.parse(clean.stdout).authority, f.main);
  for (const overrides of [{ FIXTURE_FINDING: 'yes' }, { FIXTURE_MODE: 'fetch-failure' }]) {
    const result = f.run(overrides, command);
    assert.notEqual(result.status, 0);
    assert.match(result.stderr, /Dependency audit did not pass/);
  }
});
