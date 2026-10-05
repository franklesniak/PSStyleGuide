import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { createRequire } from 'node:module';
import { execFileSync } from 'node:child_process';

// 'yaml' is an installed dependency, so importing it executes third-party code.
// It is loaded on demand rather than at module load so that --preflight can
// check accepted policy and lock integrity using only Node built-ins,
// before anything is installed. Nothing here may import an installed package at
// module scope without reopening that ordering hole.
let isAlias;
let isMap;
let isScalar;
let isSeq;
let parseAllDocuments;

async function loadYamlBindings(contract = readContract()) {
  validateParserLock(contract);
  const parserRoot = path.join(SCRIPT_DIRECTORY, 'node_modules', 'yaml');
  verifyOrdinaryPathComponents(path.join(parserRoot, 'package.json'), 'parser-tree-path');
  assertReviewedParserTree(parserRoot, contract.parser.treeSha256);
  let entry;
  try { entry = createRequire(import.meta.url).resolve('yaml'); }
  catch { fail('parser-resolution'); }
  if (path.resolve(entry) !== path.join(parserRoot, 'dist', 'index.js')) fail('parser-resolution');
  verifyOrdinaryPathComponents(entry, 'parser-tree-path');
  ({
    isAlias,
    isMap,
    isScalar,
    isSeq,
    parseAllDocuments,
  } = await import(pathToFileURL(entry).href));
}

const PARSER_TREE_LIMITS = Object.freeze({ entries: 512, depth: 16, fileBytes: 262144, totalBytes: 2097152 });

// The optional reader is a trusted test seam. Catalog data never supplies code.
function foldParserTree(root, reader = {
  *names(directory) {
    const handle = fs.opendirSync(directory);
    try {
      for (let entry = handle.readSync(); entry !== null; entry = handle.readSync()) yield entry.name;
    } finally { handle.closeSync(); }
  },
  stat: target => fs.lstatSync(target),
  bytes(target, stat) {
    const descriptor = fs.openSync(target, fs.constants.O_RDONLY | (fs.constants.O_NOFOLLOW ?? 0));
    try {
      const opened = fs.fstatSync(descriptor);
      if (!opened.isFile() || opened.nlink !== 1 || opened.dev !== stat.dev || opened.ino !== stat.ino
        || opened.size !== stat.size) fail('parser-tree-file');
      const bytes = Buffer.alloc(stat.size + 1);
      let count = 0;
      while (count < bytes.length) {
        const read = fs.readSync(descriptor, bytes, count, bytes.length - count, null);
        if (read === 0) break;
        count += read;
      }
      if (count !== stat.size) fail('parser-tree-file');
      return bytes.subarray(0, count);
    } finally { fs.closeSync(descriptor); }
  },
}) {
  const hash = crypto.createHash('sha256');
  let entries = 0, total = 0;
  function walk(directory, prefix, depth) {
    if (depth > PARSER_TREE_LIMITS.depth) fail('parser-tree-limit');
    const stat = reader.stat(directory);
    if (stat.isSymbolicLink() || !stat.isDirectory()) fail('parser-tree-path');
    const names = [];
    const seen = new Set();
    for (const name of reader.names(directory)) {
      if (++entries > PARSER_TREE_LIMITS.entries) fail('parser-tree-limit');
      if (typeof name !== 'string' || !/^[A-Za-z0-9._-]{1,128}$/u.test(name)
        || name === '.' || name === '..' || seen.has(name)) fail('parser-tree-path');
      seen.add(name); names.push(name);
    }
    for (const name of names.sort()) {
      const target = path.join(directory, name), relative = prefix ? `${prefix}/${name}` : name;
      const child = reader.stat(target);
      if (child.isSymbolicLink()) fail('parser-tree-path');
      if (child.isDirectory()) { walk(target, relative, depth + 1); continue; }
      if (!child.isFile() || child.nlink !== 1 || !Number.isSafeInteger(child.size) || child.size < 0) fail('parser-tree-file');
      if (child.size > PARSER_TREE_LIMITS.fileBytes || total + child.size > PARSER_TREE_LIMITS.totalBytes) fail('parser-tree-limit');
      const bytes = reader.bytes(target, child);
      if (!Buffer.isBuffer(bytes) || bytes.length !== child.size) fail('parser-tree-file');
      total += bytes.length;
      hash.update(`${relative}:${bytes.length}\n`, 'utf8');
      hash.update(bytes);
    }
  }
  try { walk(root, '', 0); }
  catch (error) { if (error instanceof PolicyError) throw error; fail('parser-tree-file'); }
  return hash.digest('hex');
}

function assertReviewedParserTree(root, expected, reader) {
  if (foldParserTree(root, reader) !== expected) fail('parser-tree-identity');
}

class PolicyError extends Error {
  constructor(category, reason) {
    super(category);
    this.name = 'PolicyError';
    this.category = category;
    this.reason = reason;
  }
}

function fail(category) {
  throw new PolicyError(category);
}

function canonicalize(value) {
  if (Array.isArray(value)) {
    return value.map(canonicalize);
  }
  if (value !== null && typeof value === 'object') {
    return Object.fromEntries(
      Object.keys(value).sort().map((key) => [key, canonicalize(value[key])]),
    );
  }
  return value;
}

function canonicalJson(value) {
  return JSON.stringify(canonicalize(value));
}

function sha256(value) {
  return crypto.createHash('sha256').update(value).digest('hex');
}

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

function expectExactKeys(value, expectedKeys, category) {
  if (value === null || typeof value !== 'object' || Array.isArray(value)) {
    fail(category);
  }
  const actual = Object.keys(value).sort();
  const expected = [...expectedKeys].sort();
  if (canonicalJson(actual) !== canonicalJson(expected)) {
    fail(category);
  }
}

function expectDeepEqual(actual, expected, category) {
  if (canonicalJson(actual) !== canonicalJson(expected)) {
    fail(category);
  }
}

// path.resolve() collapses '..' lexically and never follows symlinks, so testing
// only the leaf would let a symlinked directory component carry a read outside the
// intended tree while the leaf still looked ordinary. Every component below the
// boundary is walked instead. SCRIPT_DIRECTORY is already symlink-free, because
// Node resolves module paths before setting import.meta.url, but that is a
// non-local invariant of how the validator happens to be launched (and
// --preserve-symlinks would void it); state the requirement here rather than
// inherit it.
function verifyOrdinaryPathComponents(resolved, category) {
  const relative = path.relative(POLICY_ROOT, resolved);
  if (relative === '' || relative.startsWith('..') || path.isAbsolute(relative)) {
    fail(category);
  }
  let current = POLICY_ROOT;
  for (const component of relative.split(path.sep).slice(0, -1)) {
    current = path.join(current, component);
    let stat;
    try {
      stat = fs.lstatSync(current);
    } catch {
      fail(category);
    }
    if (stat.isSymbolicLink() || !stat.isDirectory()) {
      fail(category);
    }
  }
}

// A missing or unreadable file is a policy outcome, not a tool defect. Letting
// the native error escape would surface it as an unclassified tool-failure and
// lose which input was at fault, so both syscalls report the caller's category.
function readOrdinaryFile(filePath, maximumBytes, category) {
  const resolved = path.resolve(filePath);
  verifyOrdinaryPathComponents(resolved, category);
  let stat;
  try {
    stat = fs.lstatSync(resolved);
  } catch {
    fail(category);
  }
  if (!stat.isFile() || stat.isSymbolicLink() || stat.size > maximumBytes) {
    fail(category);
  }
  try {
    return fs.readFileSync(resolved);
  } catch {
    fail(category);
  }
  return undefined;
}

function inspectYamlNode(node, depth, state, limits) {
  if (depth > limits.maximumDepth || state.nodes >= limits.maximumNodes) {
    fail('yaml-limit');
  }
  state.nodes += 1;
  if (isAlias(node) || node?.anchor !== undefined || node?.tag !== undefined) {
    fail('yaml-feature');
  }
  if (isMap(node)) {
    for (const pair of node.items) {
      if (
        !isScalar(pair.key)
        || typeof pair.key.value !== 'string'
        || pair.key.value === '<<'
        || FORBIDDEN_OBJECT_KEYS.has(pair.key.value)
      ) {
        fail('yaml-key');
      }
      inspectYamlNode(pair.key, depth + 1, state, limits);
      inspectYamlNode(pair.value, depth + 1, state, limits);
    }
    return;
  }
  if (isSeq(node)) {
    for (const item of node.items) {
      inspectYamlNode(item, depth + 1, state, limits);
    }
    return;
  }
  if (!isScalar(node)) {
    fail('yaml-shape');
  }
  const value = node.value;
  if (
    value !== null
    && typeof value !== 'string'
    && typeof value !== 'boolean'
    && (typeof value !== 'number' || !Number.isFinite(value))
  ) {
    fail('yaml-value');
  }
}

function parseStrictYaml(bytes, limits) {
  if (bytes.length > limits.maximumWorkflowBytes) {
    fail('yaml-limit');
  }
  const text = strictUtf8Text(bytes, 'yaml-encoding');
  if (/^(?:%|---\s*$|\.\.\.\s*$)/mu.test(text)) {
    fail('yaml-document');
  }
  const documents = parseAllDocuments(text, {
    schema: 'core',
    merge: false,
    strict: true,
    uniqueKeys: true,
    maxAliasCount: 0,
    prettyErrors: false,
  });
  if (documents.length !== 1) {
    fail('yaml-document');
  }
  const document = documents[0];
  if (document.errors.length !== 0 || document.warnings.length !== 0 || document.contents === null) {
    fail('yaml-parse');
  }
  inspectYamlNode(document.contents, 0, { nodes: 0 }, limits);
  const value = document.toJS({ mapAsMap: false, maxAliasCount: 0 });
  canonicalJson(value);
  return { value, text };
}

function parseStrictJson(bytes, limits, category) {
  if (bytes.length > limits.maximumJsonBytes) {
    fail(category);
  }
  const parsedYaml = parseStrictYaml(bytes, {
    ...limits,
    maximumWorkflowBytes: limits.maximumJsonBytes,
  });
  try {
    return JSON.parse(parsedYaml.text);
  } catch {
    fail(category);
  }
}


// This module and its co-located contract must be loaded from the accepted checkout.
// Candidate Git blobs are data only. A successful result is validation, not owner
// maintenance authorization, live-base authentication, or merge approval.
const SCRIPT_DIRECTORY = path.dirname(fileURLToPath(import.meta.url));
const POLICY_ROOT = path.resolve(SCRIPT_DIRECTORY, '../..');
const VALIDATOR_VERSION = '3.0.0'; // Diagnostic only; consumers check schema/success.
const RESULT_SCHEMA = 'StyleGuide.WorkflowPolicyResult.v1';
const PREFLIGHT_SCHEMA = 'StyleGuide.WorkflowPreflightResult.v1';
const LIMITS = Object.freeze({ maximumWorkflowBytes: 131072, maximumJsonBytes: 524288, maximumNodes: 5000, maximumDepth: 32 });
const FORBIDDEN_OBJECT_KEYS = new Set(['__proto__', 'constructor', 'prototype']);
const WORKFLOWS = ['build.yml', 'markdownlint.yml'];

function strictUtf8Text(bytes, category) {
  const text = bytes.toString('utf8');
  if (Buffer.from(text, 'utf8').compare(bytes) !== 0 || text.charCodeAt(0) === 0xfeff) fail(category);
  return text;
}

// Built-in-only parsing is deliberate: installation/preflight must not execute YAML.
function readJsonBytes(bytes, category) {
  if (bytes.length > LIMITS.maximumJsonBytes) fail(category);
  try {
    const text = strictUtf8Text(bytes, category);
    const value = JSON.parse(text, (key, item) => {
      if (FORBIDDEN_OBJECT_KEYS.has(key)) fail(category);
      return item;
    });
    if (hasDuplicateJsonMember(text)) fail(category);
    return value;
  } catch (error) { if (error instanceof PolicyError) throw error; fail(category); }
}

// JSON.parse validates the document but discards earlier occurrences of a key.
// Scan only accepted JSON text, comparing decoded names within each object.
function hasDuplicateJsonMember(text) {
  const scopes = [];
  let index = 0;
  while (index < text.length) {
    const character = text[index];
    if (character === '{') { scopes.push(new Set()); index += 1; continue; }
    if (character === '[') { scopes.push(null); index += 1; continue; }
    if (character === '}' || character === ']') { scopes.pop(); index += 1; continue; }
    if (character !== '"') { index += 1; continue; }
    let end = index + 1;
    while (end < text.length && text[end] !== '"') {
      end += text[end] === '\\' ? 2 : 1;
    }
    const literal = text.slice(index, end + 1);
    index = end + 1;
    let probe = index;
    while (probe < text.length && ' \t\n\r'.includes(text[probe])) probe += 1;
    if (text[probe] !== ':') continue;
    const keys = scopes.at(-1);
    if (!(keys instanceof Set)) continue;
    const key = JSON.parse(literal);
    if (keys.has(key)) return true;
    keys.add(key);
  }
  return false;
}

function readContract() {
  const contract = readJsonBytes(readOrdinaryFile(path.join(SCRIPT_DIRECTORY, 'workflow-policy-contract.json'), LIMITS.maximumJsonBytes, 'contract-file'), 'contract-json');
  expectExactKeys(contract, ['schema', 'roles', 'parser', 'actions'], 'contract-shape');
  if (contract.schema !== 'StyleGuide.WorkflowPolicyContract.v3') fail('contract-schema');
  expectExactKeys(contract.roles, ['artifactVerifier'], 'contract-roles');
  if (!['verify_generated_artifacts', 'verify'].includes(contract.roles.artifactVerifier)) fail('contract-roles');
  expectExactKeys(contract.parser, ['version', 'resolved', 'integrity', 'treeSha256'], 'contract-parser');
  if (!/^[0-9a-f]{64}$/u.test(contract.parser.treeSha256)) fail('contract-parser');
  validateRegistryPackage(contract.parser, 'contract-parser');
  expectExactKeys(contract.actions, ['checkout', 'uploadArtifact'], 'contract-actions');
  for (const [name, action] of Object.entries(contract.actions)) {
    expectExactKeys(action, ['uses', 'inputs'], 'contract-action');
    const repository = name === 'checkout' ? 'actions/checkout' : 'actions/upload-artifact';
    if (!new RegExp('^' + repository + '@[0-9a-f]{40}$', 'u').test(action.uses)) fail('contract-action');
    if (!action.inputs || typeof action.inputs !== 'object' || Array.isArray(action.inputs)) fail('contract-action');
  }
  return contract;
}

function validateRegistryPackage(entry, category = 'lock-integrity') {
  if (!entry || typeof entry !== 'object' || entry.link === true ||
      typeof entry.version !== 'string' || !/^\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$/u.test(entry.version) ||
      typeof entry.resolved !== 'string' || !/^https:\/\/registry\.npmjs\.org\/(?:@[a-z0-9._-]+\/)?[a-z0-9._-]+\/-\/[a-z0-9._-]+\.tgz$/u.test(entry.resolved) ||
      typeof entry.integrity !== 'string' || !/^sha512-[A-Za-z0-9+/]{86}==$/u.test(entry.integrity)) fail(category);
}

function validatePackagePair(manifest, lock) {
  if (!manifest || !lock || lock.lockfileVersion !== 3 || !lock.packages || !lock.packages['']) fail('lock-shape');
  if (lock.name !== manifest.name || lock.version !== manifest.version) fail('lock-manifest');
  for (const field of ['dependencies', 'devDependencies', 'optionalDependencies', 'engines']) {
    expectDeepEqual(lock.packages[''][field] ?? {}, manifest[field] ?? {}, 'lock-manifest');
  }
  if (manifest.workspaces || manifest.bundleDependencies || manifest.bundledDependencies) fail('lock-shape');
  for (const [location, entry] of Object.entries(lock.packages)) {
    if (location === '') continue;
    if (!/^(?:node_modules\/(?:@[a-z0-9._-]+\/)?[a-z0-9._-]+)(?:\/node_modules\/(?:@[a-z0-9._-]+\/)?[a-z0-9._-]+)*$/u.test(location)) fail('lock-path');
    validateRegistryPackage(entry);
  }
  for (const field of ['dependencies', 'devDependencies', 'optionalDependencies']) {
    for (const name of Object.keys(manifest[field] ?? {})) {
      if (!Object.hasOwn(lock.packages, 'node_modules/' + name)) fail('lock-direct-dependency');
    }
  }
}

function readInput(relative, revision, maximum = LIMITS.maximumJsonBytes) {
  if (!revision) return readOrdinaryFile(path.join(POLICY_ROOT, relative), maximum, 'input-file');
  if (!/^[0-9a-f]{40}$/u.test(revision)) fail('input-revision');
  try {
    const options = { cwd: POLICY_ROOT, encoding: 'utf8', timeout: 10000, maxBuffer: maximum + 1024, windowsHide: true };
    const type = execFileSync('git', ['cat-file', '-t', revision], options).trim();
    if (type !== 'commit') fail('input-revision');
    const row = execFileSync('git', ['ls-tree', '-z', revision, '--', relative], options);
    const match = /^(100644|100755) blob ([0-9a-f]{40})\t([^\0]+)\0$/u.exec(row);
    if (!match || match[3] !== relative) fail('input-file');
    const bytes = execFileSync('git', ['cat-file', 'blob', match[2]], { ...options, encoding: undefined });
    if (bytes.length > maximum) fail('input-file');
    return bytes;
  } catch (error) { if (error instanceof PolicyError) throw error; fail('input-file'); }
}

function validatePackages(revision) {
  for (const directory of ['', '.github/workflows/']) {
    const manifest = readJsonBytes(readInput(directory + 'package.json', revision), 'package-json');
    const lock = readJsonBytes(readInput(directory + 'package-lock.json', revision), 'lock-json');
    validatePackagePair(manifest, lock);
  }
}

function validateParserLock(contract) {
  // Always read accepted files beside this module, never the candidate revision.
  const manifest = readJsonBytes(readInput('.github/workflows/package.json'), 'package-json');
  const lock = readJsonBytes(readInput('.github/workflows/package-lock.json'), 'lock-json');
  validatePackagePair(manifest, lock);
  const parser = lock.packages['node_modules/yaml'];
  for (const field of ['version', 'resolved', 'integrity']) {
    if (parser?.[field] !== contract.parser[field]) fail('parser-lock-identity');
  }
  if ((manifest.dependencies?.yaml ?? manifest.devDependencies?.yaml) !== parser.version) fail('parser-lock-identity');
}

function visibleLines(run) {
  if (typeof run !== 'string' || run.length > LIMITS.maximumWorkflowBytes || run.includes('\0')) fail('helper-call');
  return run.split(/\r?\n/u).map(line => line.trim()).filter(line => line && !line.startsWith('#'));
}

function helperCall(line) {
  // Only a command and literal words: no PowerShell expressions, expansion,
  // interpolation, escaping, pipelines, redirects, or second statement.
  const tokens = line.replace(/^&\s+/u, '').match(/'[^']*'|"[^"]*"|[^\s]+/gu) ?? [];
  return tokens.map(token => {
    if ((token.startsWith("'") && token.endsWith("'")) || (token.startsWith('"') && token.endsWith('"'))) token = token.slice(1, -1);
    if (!/^[A-Za-z0-9_./-]+$/u.test(token)) fail('helper-call');
    return token;
  });
}

function validateRunStep(step, id, expected) {
  const keys = ['id', 'shell', 'run'];
  if (Object.hasOwn(step, 'name')) keys.push('name');
  expectExactKeys(step, keys, 'code-step-shape');
  if (step.id !== id || step.shell !== 'pwsh' || (step.name !== undefined && typeof step.name !== 'string')) fail('code-step-interface');
  const lines = visibleLines(step.run);
  if (id === 'acquire') {
    // This bootstrap necessarily runs before repo helpers exist. Source safety is
    // covered by accepted-loader behavior tests and maintenance review; this is
    // deliberately not a shell interpreter or a source-spelling proof.
    if (lines.length === 0) fail('acquisition-empty');
    return;
  }
  if (id === 'validate') {
    if (lines.length !== 2) fail('helper-call');
    expectDeepEqual(helperCall(lines[0].replace(/;$/u, '')), ['node', './.github/workflows/Validate-WorkflowPolicy.mjs', '.github/workflows/build.yml', '.github/workflows/markdownlint.yml'], 'helper-call');
    if (!/^if\s*\(\s*\$LASTEXITCODE\s+-ne\s+0\s*\)\s*\{\s*throw\s+(['"])Workflow policy validation failed\.\1\s*;?\s*\}$/u.test(lines[1])) fail('native-failure-check');
    return;
  }
  if (id === 'audit') {
    if (lines.length !== 2) fail('helper-call');
    expectDeepEqual(helperCall(lines[0].replace(/;$/u, '')), ['node', './.github/workflows/Check-NpmAudit.mjs', '--ci'], 'helper-call');
    if (!/^if\s*\(\s*\$LASTEXITCODE\s+-ne\s+0\s*\)\s*\{\s*throw\s+(['"])[A-Za-z0-9 .:-]+\1\s*;?\s*\}$/u.test(lines[1])) fail('native-failure-check');
    return;
  }
  if (lines.length !== 1) fail('helper-call');
  expectDeepEqual(helperCall(lines[0]), expected, 'helper-call');
}

function validateWorkflowObject(fileName, workflow, contract) {
  if (!WORKFLOWS.includes(fileName)) fail('workflow-name');
  expectExactKeys(workflow, ['name', 'on', 'permissions', 'jobs'], 'workflow-shape');
  if (typeof workflow.name !== 'string' || !workflow.name.trim()) fail('workflow-name');
  const build = fileName === 'build.yml';
  const events = { push: null, pull_request: null };
  if (!build) {
    const schedule = workflow.on?.schedule;
    if (!Array.isArray(schedule) || schedule.length !== 1) fail('workflow-events');
    expectExactKeys(schedule[0], ['cron'], 'workflow-events');
    const weekly = typeof schedule[0].cron === 'string' && /^(\d{1,2}) +(\d{1,2}) +\* +\* +([0-6])$/u.exec(schedule[0].cron);
    if (!weekly || Number(weekly[1]) > 59 || Number(weekly[2]) > 23) fail('workflow-events');
    events.schedule = schedule;
  }
  expectDeepEqual(workflow.on, events, 'workflow-events');
  expectDeepEqual(workflow.permissions, {}, 'workflow-permissions');
  const codeJobs = build ? [contract.roles.artifactVerifier] : ['policy', 'markdownlint'];
  expectExactKeys(workflow.jobs, build ? [...codeJobs, 'publish_committed_artifacts'] : codeJobs, 'isolation-jobs');
  for (const id of codeJobs) {
    const job = workflow.jobs[id];
    expectExactKeys(job, ['if', 'runs-on', 'timeout-minutes', 'permissions', 'steps'], 'code-job-shape');
    if (job.if !== "github.event_name != 'push' || github.event.deleted != true") fail('code-job-event');
    expectDeepEqual(job.permissions, {}, 'code-job-permissions');
    if (job['runs-on'] !== 'ubuntu-24.04' || job['timeout-minutes'] !== 30) fail('code-job-execution');
    const roles = [
      ['acquire', null],
      ['verify-checkout-credentials', ['./.github/workflows/Test-CheckoutCredentials.ps1']],
      ...(build ? [] : [['initialize-toolchain', ['./.github/workflows/Initialize-CiToolchain.ps1', '-WorkflowDependencies']]]),
      build ? ['generate_style_guide_artifacts', ['./.github/workflows/Test-StyleGuideArtifacts.ps1']]
        : id === 'policy' ? ['validate', null] : ['lint', ['./.github/workflows/Invoke-MarkdownLint.ps1']],
      ...(id === 'markdownlint' ? [['audit', null]] : []),
    ];
    if (!Array.isArray(job.steps) || job.steps.length !== roles.length) fail('code-step-cardinality');
    roles.forEach(([role, call], index) => validateRunStep(job.steps[index], role, call));
  }
  if (!build) return;
  const publisher = workflow.jobs.publish_committed_artifacts;
  expectExactKeys(publisher, ['runs-on', 'timeout-minutes', 'permissions', 'needs', 'steps'], 'publisher-shape');
  expectDeepEqual(publisher.permissions, { contents: 'read' }, 'publisher-permissions');
  if (publisher.needs !== contract.roles.artifactVerifier || publisher['runs-on'] !== 'ubuntu-24.04' || publisher['timeout-minutes'] !== 10) fail('publisher-execution');
  if (!Array.isArray(publisher.steps) || publisher.steps.length !== 2) fail('publisher-steps');
  for (const [index, actionName] of ['checkout', 'uploadArtifact'].entries()) {
    const step = publisher.steps[index];
    const keys = ['id', 'uses', 'with'];
    if (Object.hasOwn(step, 'name')) keys.push('name');
    expectExactKeys(step, keys, 'publisher-step-shape');
    if (step.id !== (index === 0 ? 'checkout_repository' : 'publish_committed_style_guide_artifacts') || step.uses !== contract.actions[actionName].uses) fail('action-identity');
    expectDeepEqual(step.with, contract.actions[actionName].inputs, 'action-inputs');
  }
}

function parseArguments(args) {
  let revision;
  const remaining = [...args];
  const index = remaining.indexOf('--input-revision');
  if (index >= 0) {
    revision = remaining[index + 1];
    if (!/^[0-9a-f]{40}$/u.test(revision ?? '')) fail('input-revision');
    remaining.splice(index, 2);
  }
  const preflight = remaining.length === 1 && remaining[0] === '--preflight';
  if (!preflight) {
    const rootArgs = WORKFLOWS.map(file => '.github/workflows/' + file);
    if (!(canonicalJson(remaining) === canonicalJson(WORKFLOWS) && path.resolve(process.cwd()) === SCRIPT_DIRECTORY) &&
        !(canonicalJson(remaining) === canonicalJson(rootArgs) && path.resolve(process.cwd()) === POLICY_ROOT)) fail('arguments');
  }
  return { revision, preflight };
}

async function main(args = process.argv.slice(2)) {
  const { revision, preflight } = parseArguments(args);
  const contract = readContract();
  validateParserLock(contract);
  validatePackages(revision);
  const common = { validatorVersion: VALIDATOR_VERSION, success: true, contractCanonicalSha256: sha256(canonicalJson(contract)) };
  if (preflight) return { schema: PREFLIGHT_SCHEMA, ...common };
  await loadYamlBindings(contract);
  const workflowSha256 = {};
  for (const file of WORKFLOWS) {
    const bytes = readInput('.github/workflows/' + file, revision, LIMITS.maximumWorkflowBytes);
    validateWorkflowObject(file, parseStrictYaml(bytes, LIMITS).value, contract);
    workflowSha256[file] = sha256(bytes);
  }
  // This CLI validates inputs; the separate Node test suite executes mutation cases.
  return { schema: RESULT_SCHEMA, ...common, casesPassed: 0, workflowSha256 };
}

export { PolicyError, LIMITS, readContract, readJsonBytes, validatePackagePair, validateParserLock, foldParserTree, assertReviewedParserTree, loadYamlBindings, parseStrictYaml, validateWorkflowObject, readInput, main };

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
  try { process.stdout.write(JSON.stringify(await main()) + '\n'); }
  catch (error) {
    process.stdout.write(JSON.stringify({ schema: process.argv.includes('--preflight') ? PREFLIGHT_SCHEMA : RESULT_SCHEMA, validatorVersion: VALIDATOR_VERSION, success: false, category: error instanceof PolicyError ? error.category : 'tool-failure' }) + '\n');
    process.exitCode = 1;
  }
}
