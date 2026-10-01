import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { visit } from 'jsonc-parser';
import { repositoryRoot, runBounded, withNpmEnvironment } from './NpmTools.mjs';

const exceptionPath = '.github/workflows/npm-risk-exceptions.json';
const severities = ['info', 'low', 'moderate', 'high', 'critical'];
const roots = ['.', '.github/workflows'];
const advisoryPattern = /^GHSA-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}$/u;
const packagePattern = /^(?:@[a-z0-9._-]+\/)?[a-z0-9._-]+$/iu;
const fail = message => { throw new Error(message); };
const object = value => value !== null && typeof value === 'object' && !Array.isArray(value);
const text = value => typeof value === 'string' && value.length > 0 && value.length <= 4096 && !/[\x00-\x1f\x7f]/u.test(value);
const exactKeys = (value, keys) => object(value) && Object.keys(value).sort().join(',') === [...keys].sort().join(',');
const uniqueStrings = value => Array.isArray(value) && value.length > 0 && value.length <= 1000 &&
  value.every(text) && new Set(value).size === value.length;

function readInput(file, limit) {
  const metadata = fs.lstatSync(file);
  if (!metadata.isFile() || metadata.isSymbolicLink() || metadata.size > limit) fail('Expected a bounded regular JSON input.');
  return fs.readFileSync(file);
}

export function parseJson(bytes, limit = 2 * 1024 * 1024) {
  if (bytes.length > limit) fail('JSON output exceeds the size limit.');
  const source = new TextDecoder('utf-8', { fatal: true, ignoreBOM: true }).decode(bytes);
  if (source.charCodeAt(0) === 0xfeff) fail('JSON BOM is not supported.');
  const stack = [];
  let depth = 0;
  const enter = keys => { if (++depth > 32) fail('JSON nesting exceeds the limit.'); stack.push(keys); };
  const leave = () => { stack.pop(); depth--; };
  visit(source, {
    onObjectBegin: () => enter(new Set()), onObjectEnd: leave,
    onArrayBegin: () => enter(null), onArrayEnd: leave,
    onObjectProperty: key => {
      if (['__proto__', 'constructor', 'prototype'].includes(key) || stack.at(-1).has(key)) fail('Duplicate or unsafe JSON key.');
      stack.at(-1).add(key);
    },
    onError: () => fail('Invalid strict JSON.'),
  }, { allowTrailingComma: false, disallowComments: true, allowEmptyContent: false });
  return JSON.parse(source);
}

function nodePair(value) {
  return exactKeys(value, ['path', 'version']) && text(value.path) && text(value.version) &&
    /^(?:node_modules\/(?:@[a-z0-9._-]+\/)?[a-z0-9._-]+)(?:\/node_modules\/(?:@[a-z0-9._-]+\/)?[a-z0-9._-]+)*$/iu.test(value.path);
}

export function parseExceptions(bytes) {
  const value = parseJson(bytes, 65536);
  if (!exactKeys(value, ['exceptions']) || !Array.isArray(value.exceptions) || value.exceptions.length > 100) fail('Invalid exception record.');
  const identities = new Set();
  for (const item of value.exceptions) {
    if (!exactKeys(item, ['root', 'package', 'advisories', 'nodes', 'owner', 'reason', 'controls', 'expires']) ||
        !roots.includes(item.root) || !text(item.package) || !packagePattern.test(item.package) || !uniqueStrings(item.advisories) ||
        !item.advisories.every(id => advisoryPattern.test(id)) || !Array.isArray(item.nodes) ||
        item.nodes.length === 0 || item.nodes.length > 1000 || !item.nodes.every(nodePair) ||
        new Set(item.nodes.map(n => n.path)).size !== item.nodes.length ||
        !text(item.owner) || !text(item.reason) || !uniqueStrings(item.controls) ||
        typeof item.expires !== 'string' || !/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$/u.test(item.expires) ||
        !Number.isFinite(Date.parse(item.expires)) || new Date(item.expires).toISOString().replace('.000Z', 'Z') !== item.expires) {
      fail('Invalid exception scope, owner, controls or expiry.');
    }
    const identity = `${item.root}:${item.package}`;
    if (identities.has(identity)) fail('Duplicate package exception.');
    identities.add(identity);
  }
  return value.exceptions.map(item => ({ root: item.root, package: item.package,
    advisories: [...item.advisories].sort(), nodes: item.nodes.map(n => ({ path: n.path, version: n.version }))
      .sort((a, b) => a.path.localeCompare(b.path)), owner: item.owner, reason: item.reason,
    controls: [...item.controls].sort(), expires: item.expires }))
    .sort((a, b) => `${a.root}:${a.package}`.localeCompare(`${b.root}:${b.package}`));
}

export function interpretAudit(result, root, lock) {
  if (!Number.isInteger(result.status) || result.error || result.signal || ![0, 1].includes(result.status)) fail('Audit process did not complete normally.');
  const value = parseJson(result.stdout);
  if (!object(value) || value.auditReportVersion !== 2 || 'error' in value || !object(value.vulnerabilities) ||
      !object(value.metadata?.vulnerabilities) || !object(lock.packages)) fail('Unsupported audit report.');
  const entries = Object.entries(value.vulnerabilities);
  if (entries.length > 1000) fail('Too many affected package summaries.');
  const actualCounts = Object.fromEntries(severities.map(name => [name, 0]));
  const facts = new Map();
  for (const [name, item] of entries) {
    if (!packagePattern.test(name) || !object(item) || item.name !== name || !severities.includes(item.severity) ||
        !Array.isArray(item.via) || item.via.length === 0 || item.via.length > 1000 ||
        !uniqueStrings(item.nodes)) fail('Invalid affected package summary.');
    actualCounts[item.severity]++;
    const nodes = item.nodes.map(node => {
      const entry = lock.packages[node];
      const pair = { path: node, version: entry?.version };
      if (!nodePair(pair) || !object(entry) || entry.link === true ||
          (entry.name ?? node.split('node_modules/').at(-1)) !== name) fail('Affected node is absent or invalid in the current lockfile.');
      return pair;
    }).sort((a, b) => a.path.localeCompare(b.path));
    const direct = [], viaPackages = [];
    for (const via of item.via) {
      if (typeof via === 'string') { viaPackages.push(via); continue; }
      const id = typeof via?.url === 'string' ? via.url.replace('https://github.com/advisories/', '') : '';
      if (!object(via) || !Number.isSafeInteger(via.source) || via.source < 1 || via.name !== name ||
          !severities.includes(via.severity) || !text(via.range) || !advisoryPattern.test(id) ||
          via.url !== `https://github.com/advisories/${id}`) fail('Unsupported advisory identity.');
      direct.push({ id, source: via.source, severity: via.severity, range: via.range });
    }
    facts.set(name, { root, package: name, severity: item.severity, nodes, directAdvisories: direct, viaPackages });
  }
  for (const severity of severities) {
    if (value.metadata.vulnerabilities[severity] !== actualCounts[severity]) fail('Audit severity totals disagree with package summaries.');
  }
  if (value.metadata.vulnerabilities.total !== entries.length || result.status !== (entries.length ? 1 : 0)) fail('Audit native exit or total disagrees with its report.');
  const scopes = new Map();
  function advisoryScope(name, visiting = new Set()) {
    if (!facts.has(name)) fail('Audit contains a dangling package reference.');
    if (visiting.has(name)) fail('Audit contains a cyclic package reference.');
    if (visiting.size >= 32) fail('Audit package references exceed the depth limit.');
    if (scopes.has(name)) return scopes.get(name);
    const next = new Set(visiting).add(name), item = facts.get(name);
    const scope = new Set([...item.directAdvisories.map(a => a.id), ...item.viaPackages.flatMap(v => [...advisoryScope(v, next)])]);
    scopes.set(name, scope);
    return scope;
  }
  return [...facts.values()].map(item => ({ ...item, advisories: [...advisoryScope(item.package)].sort() }))
    .sort((a, b) => a.package.localeCompare(b.package));
}

export function evaluateFindings(findings, exceptions, now = Date.now()) {
  if (!Number.isFinite(now)) fail('Invalid evaluation time.');
  const used = new Set(), unresolved = [];
  for (const finding of findings) {
    const index = exceptions.findIndex(item => item.root === finding.root && item.package === finding.package &&
      Date.parse(item.expires) > now && finding.advisories.every(id => item.advisories.includes(id)) &&
      finding.nodes.every(node => item.nodes.some(allowed => allowed.path === node.path && allowed.version === node.version)));
    if (index < 0) unresolved.push(finding);
    else used.add(index);
  }
  return { status: unresolved.length ? 'FINDINGS' : findings.length ? 'ACCEPTED_RISK' : 'CLEAN',
    unresolved, acceptedPackages: used.size,
    unusedExceptions: exceptions.filter((_, index) => !used.has(index)).map(item => `${item.root}:${item.package}`) };
}

export function validateGraph(result, manifest) {
  if (result.status !== 0 || result.error || result.signal) fail('Installed graph command failed.');
  const graph = parseJson(result.stdout);
  if (!object(graph) || graph.name !== manifest.name || graph.version !== manifest.version || 'error' in graph ||
      ('problems' in graph && (!Array.isArray(graph.problems) || graph.problems.length !== 0))) {
    fail('Installed graph has problems or an unexpected root; run the locked bootstrap.');
  }
  return graph;
}

function gitEnvironment() {
  return { ...Object.fromEntries(Object.entries(process.env).filter(([name]) => !/^GIT_/iu.test(name))),
    GIT_CONFIG_NOSYSTEM: '1', GIT_CONFIG_GLOBAL: process.platform === 'win32' ? 'NUL' : '/dev/null',
    GIT_NO_REPLACE_OBJECTS: '1', GIT_TERMINAL_PROMPT: '0' };
}

function git(args, env, root) {
  return runBounded('git', ['-c', 'core.hooksPath=/dev/null', '-c', 'core.fsmonitor=false',
    '-c', 'credential.helper=', '-c', 'http.extraheader=', ...args], { cwd: root, env, timeout: 30000 });
}

export function hostedAuthorityReference(environment, event) {
  if (environment.GITHUB_REPOSITORY !== 'franklesniak/PSStyleGuide') fail('Unexpected audit repository.');
  let reference;
  if (environment.GITHUB_EVENT_NAME === 'pull_request') {
    if (event?.pull_request?.base?.ref !== 'main' || event?.pull_request?.base?.repo?.full_name !== environment.GITHUB_REPOSITORY) fail('Unexpected PR authority repository or branch.');
    reference = event.pull_request.base.sha;
  } else if (['push', 'schedule', 'workflow_dispatch'].includes(environment.GITHUB_EVENT_NAME)) {
    reference = environment.GITHUB_SHA;
    if (environment.GITHUB_REF !== 'refs/heads/main') fail('Hosted audit authority must be the main branch.');
  } else fail('Unsupported hosted audit event.');
  if (typeof reference !== 'string' || !/^[a-f0-9]{40}$/u.test(reference)) fail('A full trusted event base is required.');
  return reference;
}

export function acceptedBase({ environment = process.env, root = repositoryRoot } = {}) {
  const env = gitEnvironment();
  let reference = 'refs/remotes/origin/main';
  const hosted = environment.GITHUB_ACTIONS === 'true';
  if (hosted) {
    const event = environment.GITHUB_EVENT_NAME === 'pull_request'
      ? parseJson(readInput(environment.GITHUB_EVENT_PATH, 2 * 1024 * 1024)) : undefined;
    reference = hostedAuthorityReference(environment, event);
    const available = git(['cat-file', '-e', `${reference}^{commit}`], env, root);
    if (available.status !== 0) {
      const fetched = git(['fetch', '--quiet', '--depth=1', '--no-tags', '--no-recurse-submodules',
        'https://github.com/franklesniak/PSStyleGuide', reference], env, root);
      if (fetched.status !== 0) fail('Cannot acquire the event authority commit.');
    }
  }
  const resolved = git(['rev-parse', '--verify', `${reference}^{commit}`], env, root);
  const sha = resolved.stdout.toString('utf8').trim();
  if (resolved.status !== 0 || !/^[a-f0-9]{40}$/u.test(sha)) fail('Accepted main/base commit is unavailable. Fetch origin/main before a local audit.');
  if (hosted && sha !== reference) fail('Event authority commit mismatch.');
  const listing = git(['ls-tree', '-z', sha, '--', exceptionPath], env, root);
  if (listing.status !== 0) fail('Cannot inspect accepted exception state.');
  let bytes = Buffer.from('{"exceptions":[]}');
  if (listing.stdout.length !== 0) {
    if (!/^100644 blob [a-f0-9]{40}\t\.github\/workflows\/npm-risk-exceptions\.json\0$/u.test(listing.stdout.toString('utf8'))) fail('Accepted exception state is not a regular Git blob.');
    const content = git(['show', `${sha}:${exceptionPath}`], env, root);
    if (content.status !== 0) fail('Cannot read accepted exception state.');
    bytes = content.stdout;
  }
  return { sha, exceptions: parseExceptions(bytes),
    limitation: hosted ? 'Owner/executor must check known revocations before acceptance.' :
      'Offline authority uses the locally fetched origin/main commit; external revocation and ref freshness are not discovered.' };
}

export function readCandidateExceptions(root) {
  try { return parseExceptions(readInput(path.join(root, exceptionPath), 65536)); }
  catch (error) { if (error.code === 'ENOENT') return []; throw error; }
}

export function runAuditCommand(runNpm, directory, wait = () => Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, 2000)) {
  const args = ['audit', '--json', '--audit-level=info', '--include=dev', '--package-lock=true'];
  let result = runNpm(args, directory);
  if (result.status === 1 && !result.error && !result.signal) {
    const value = parseJson(result.stdout);
    if (object(value.error) && !('auditReportVersion' in value) && !('vulnerabilities' in value) &&
        value.method === 'POST' && value.uri === 'https://registry.npmjs.org/-/npm/v1/security/advisories/bulk' &&
        [408, 429, 500, 502, 503, 504].includes(value.statusCode)) {
      console.error(`npm audit returned HTTP ${value.statusCode}; retrying once.`);
      wait();
      result = runNpm(args, directory);
    }
  }
  return result;
}

export function audit({ root = repositoryRoot, authority = acceptedBase({ root }), installedRoots = roots } = {}) {
  const candidate = readCandidateExceptions(root);
  const findings = withNpmEnvironment(({ runNpm }) => roots.flatMap(scope => {
    const directory = path.resolve(root, scope);
    const lock = parseJson(readInput(path.join(directory, 'package-lock.json'), 2 * 1024 * 1024));
    const manifest = parseJson(readInput(path.join(directory, 'package.json'), 65536));
    if (installedRoots.includes(scope)) validateGraph(runNpm(['ls', '--all', '--json', '--include=dev'], directory), manifest);
    const result = runAuditCommand(runNpm, directory);
    return interpretAudit(result, scope, lock);
  }), { root });
  return { ...evaluateProposal(findings, authority.exceptions, candidate), authority: authority.sha,
    limitation: authority.limitation, installedGraphRoots: installedRoots, findings };
}

export function evaluateProposal(findings, accepted, candidate, now = Date.now()) {
  const result = evaluateFindings(findings, accepted, now);
  const proposal = JSON.stringify(candidate) !== JSON.stringify(accepted);
  return { ...result, status: proposal ? 'PROPOSAL' : result.status, proposedState: proposal };
}

export function documentationOnlyDiff(bytes) {
  if (bytes.length > 2 * 1024 * 1024) fail('Git change exceeds the size limit.');
  const source = new TextDecoder('utf-8', { fatal: true }).decode(bytes);
  if (source === '') return true;
  if (!source.endsWith('\0')) fail('Incomplete Git change.');
  const fields = source.slice(0, -1).split('\0');
  if (fields.length % 2 || fields.length > 20000) fail('Invalid or oversized Git change.');
  let documents = true;
  for (let index = 0; index < fields.length; index += 2) {
    const entry = /^:([0-7]{6}) ([0-7]{6}) [a-f0-9]{40} [a-f0-9]{40} ([AMDT])$/u.exec(fields[index]);
    const name = fields[index + 1];
    if (!entry || !text(name) || name.includes('\\') || name.startsWith('/') ||
        name.split('/').some(part => !part || part === '.' || part === '..')) fail('Invalid Git change entry.');
    const parts = name.toLowerCase().split('/');
    documents &&= [entry[1], entry[2]].every(mode => ['000000', '100644'].includes(mode)) &&
      parts.every(part => !part.startsWith('.')) && parts.at(-1).endsWith('.md') &&
      !parts.at(-1).endsWith('.instructions.md') &&
      !['agents.md', 'agents.override.md', 'claude.md', 'claude.local.md', 'gemini.md', 'skill.md', 'copilot-instructions.md'].includes(parts.at(-1));
  }
  return documents;
}

export function ciScope({ root = repositoryRoot, environment = process.env, authority } = {}) {
  if (environment.GITHUB_ACTIONS !== 'true') fail('CI audit mode requires a hosted event.');
  if (environment.GITHUB_EVENT_NAME !== 'pull_request') return { applicable: true };
  const env = gitEnvironment(), head = environment.GITHUB_SHA;
  if (!/^[a-f0-9]{40}$/u.test(head ?? '') || !/^[a-f0-9]{40}$/u.test(authority?.sha ?? '')) fail('Invalid CI audit endpoints.');
  const current = git(['rev-parse', '--verify', 'HEAD^{commit}'], env, root);
  if (current.status !== 0 || current.stdout.toString('utf8').trim() !== head) fail('CI audit checkout mismatch.');
  const changed = git(['diff', '--raw', '--no-abbrev', '--no-renames', '--no-ext-diff', '--no-textconv',
    '-z', authority.sha, head, '--'], env, root);
  if (changed.status !== 0) fail('Cannot read the complete Git change.');
  return { applicable: !documentationOnlyDiff(changed.stdout), base: authority.sha, head };
}

export function ciAudit({ root = repositoryRoot, environment = process.env } = {}) {
  const authority = acceptedBase({ root, environment });
  const scope = ciScope({ root, environment, authority });
  return scope.applicable ? audit({ root, authority, installedRoots: ['.github/workflows'] }) : {
    status: 'NOT_APPLICABLE', ...scope,
    reason: 'Only ordinary Markdown changed; no live audit ran. Main and scheduled audits remain applicable.',
  };
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try {
    if (process.argv.length > 3 || (process.argv.length === 3 && process.argv[2] !== '--ci')) fail('Usage: node .github/workflows/Check-NpmAudit.mjs [--ci]');
    const result = process.argv[2] === '--ci' ? ciAudit() : audit();
    console.log(JSON.stringify(result, null, 2));
    process.exitCode = { CLEAN: 0, ACCEPTED_RISK: 0, NOT_APPLICABLE: 0, FINDINGS: 1, PROPOSAL: 3 }[result.status];
  } catch (error) {
    console.error(JSON.stringify({ status: 'ERROR', message: error.message }));
    process.exitCode = 2;
  }
}
