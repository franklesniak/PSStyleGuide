import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { createRequire } from 'node:module';

// 'yaml' is an installed dependency, so importing it executes third-party code.
// It is loaded on demand rather than at module load so that --preflight can
// establish contract, validator, and package identity using only Node built-ins,
// before anything is installed. Nothing here may import an installed package at
// module scope without reopening that ordering hole.
let isAlias;
let isMap;
let isScalar;
let isSeq;
let parseAllDocuments;

async function loadYamlBindings() {
  const parserRoot = path.join(SCRIPT_DIRECTORY, 'node_modules', 'yaml');
  verifyOrdinaryPathComponents(path.join(parserRoot, 'package.json'), 'parser-tree-path');
  assertReviewedParserTree(parserRoot);
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
const REVIEWED_PARSER_TREE_SHA256 = 'ce50e3ffc11ca6ee6cbcde528ef7a0cca908241ee3394d8e01d9e7a813bdd53e';

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

function assertReviewedParserTree(root, reader) {
  if (foldParserTree(root, reader) !== REVIEWED_PARSER_TREE_SHA256) fail('parser-tree-identity');
}

const VALIDATOR_VERSION = '1.5.5';
const WORKFLOW_ISOLATION_POLICY_VERSION = 1;
const RESULT_SCHEMA = 'PSStyleGuide.WorkflowPolicyResult.v1';
const PREFLIGHT_SCHEMA = 'PSStyleGuide.WorkflowPreflightResult.v1';
const PREFLIGHT_ARGUMENTS = ['--preflight'];
const EXPECTED_CONTRACT_CANONICAL_SHA256 = 'fc06749b9f96e0083aa5e5c76affad08a2729cc5ff37e8a380867b6dcfe117fe';
const MINIMUM_CASE_COUNT = 99;
const REQUIRED_IDENTITY_CASE_COUNT = 42;
const CASE_CATALOG_FILE_NAME = 'workflow-policy-cases.json';
const VALIDATOR_FILE_NAME = 'Validate-WorkflowPolicy.mjs';
const GENERATOR_FILE_NAME = 'Generate-StyleGuideArtifacts.ps1';
const IDENTITY_WORKFLOW_FILE_NAME = 'pull-request-body-identity.yml';
// Mapping keys that alias JavaScript object internals. Plain assignment to
// '__proto__' mutates an object's prototype instead of creating an own property,
// so these are rejected at the parse boundary and in JSON pointers rather than
// being relied upon to fail incidentally in a later shape comparison.
const FORBIDDEN_OBJECT_KEYS = new Set(['__proto__', 'constructor', 'prototype']);
// The owner's advisory approval authorizes exactly these findings and states
// that a critical finding stops implementation and merge. Both are asserted
// below, so the approval's terms are enforced rather than merely recorded.
const AUTHORIZED_ADVISORY_FINDING_KEYS = [
  'brace-expansion',
  'js-yaml',
  'linkify-it',
  'markdown-it',
  'markdownlint-cli2',
  'minimatch',
  'picomatch',
];
const SCRIPT_DIRECTORY = path.dirname(fileURLToPath(import.meta.url));
// Entry-point parity includes root configuration and .github-owned tooling.
// The repository root is therefore the common containment boundary, while every
// accepted path remains an exact contract literal and every component must be
// an ordinary directory or file.
const POLICY_ROOT = path.resolve(SCRIPT_DIRECTORY, '../..');
const REQUIRED_ARGUMENTS = ['build.yml', 'markdownlint.yml'];
const WORKFLOW_FILE_NAMES = [...REQUIRED_ARGUMENTS, IDENTITY_WORKFLOW_FILE_NAME];
const REQUIRED_MARKDOWN_EXTENSIONS = ['md', 'mdc'];
const REQUIRED_IGNORED_MARKDOWN_DIRECTORIES = ['node_modules', '.git', '.venv'];
const REQUIRED_RETAINED_MARKDOWN_DOT_DIRECTORIES = ['.github', '.cursor'];
const REQUIRED_ROOT_LINT_SCRIPT = 'markdownlint-cli2 "**/*.md" "**/*.mdc" "#node_modules" "#.github/workflows/node_modules" --config .github/workflows/.markdownlint.jsonc';
const REQUIRED_WORKFLOW_LINT_SCRIPT = 'cd ../.. && markdownlint-cli2 "**/*.md" "**/*.mdc" "#node_modules" "#.github/workflows/node_modules" --config .github/workflows/.markdownlint.jsonc';
const REQUIRED_RECIPROCAL_ROWS = [
  'GF-PARAMETERS',
  'GF-DESTINATION',
  'GF-CONTENT',
  'GF-SERIALIZATION',
  'GF-WRITE',
  'GF-FAILURE',
  'GF-HOSTS',
  'GF-VERSION',
  'GF-NODE-LOCK',
  'GF-YAML',
  'GF-ACTION-PINS',
  'GF-ACTION-INPUTS',
  'GF-GIT',
  'GF-GRAPH',
  'GF-CREDENTIALS',
  'GF-EVIDENCE',
];
const REQUIRED_ACTION_IDENTITIES = {
  checkout: {
    repository: 'actions/checkout',
    sha: '3d3c42e5aac5ba805825da76410c181273ba90b1',
    release: 'v7.0.1',
    manifestSha256: 'd59219cb79590abdb877deaa14e3b65a00c05318bf5a6f3b989b9162b5d08c35',
  },
  setupNode: {
    repository: 'actions/setup-node',
    sha: '820762786026740c76f36085b0efc47a31fe5020',
    release: 'v7.0.0',
    manifestSha256: '5d765941ab5d8bef27f08e81b0b041cdb2df2050ea0261dc925d157a2bafbd2b',
  },
  uploadArtifact: {
    repository: 'actions/upload-artifact',
    sha: '043fb46d1a93c77aae656e7c1c64a875d1fc6a0a',
    release: 'v7.0.1',
    manifestSha256: 'c5979822866a72362e609844b6ebe77d4b7e759af68cc1c2c425dcf51481fab4',
  },
};

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

// Only the expanded external fixture catalog receives this larger node budget.
// Workflow, package and bootstrap parsing retain their independent 5000-node cap.
function caseCatalogLimits(contract) {
  if (contract.limits.maximumCaseNodes !== 16384) fail('case-node-limit');
  return { ...contract.limits, maximumNodes: contract.limits.maximumCaseNodes };
}

// The contract records this validator's digest in validatorIdentity, while this
// validator records the contract's canonical digest. Hashing the whole contract
// here would make those two values mutually dependent and unsatisfiable: updating
// either forces the other to change, with no fixed point. Excluding validatorIdentity
// from the identity view breaks that cycle, so validatorIdentity is deliberately not
// covered by contract-identity. It is covered instead by the independent Get-FileHash
// gate in the workflow and by the validator-identity check in main().
function contractIdentityView(contract) {
  const view = clone(contract);
  delete view.validatorIdentity;
  return view;
}

function validateContract(contract) {
  if (sha256(canonicalJson(contractIdentityView(contract))) !== EXPECTED_CONTRACT_CANONICAL_SHA256) {
    fail('contract-identity');
  }
  expectExactKeys(contract, [
    'schema',
    'contractVersion',
    'limits',
    'supplyFreeze',
    'scriptVersions',
    'caseCatalog',
    'validatorIdentity',
    'actions',
    'workflowPolicy',
    'markdownPolicy',
    'dependabot',
    'reciprocalFoundation',
  ], 'contract-shape');
  expectDeepEqual(contract.limits, {
    maximumWorkflowBytes: 131072, maximumJsonBytes: 524288,
    maximumNodes: 5000, maximumDepth: 32, maximumCaseNodes: 16384,
  }, 'contract-limits');
  validateMarkdownContract(contract.markdownPolicy);
  expectExactKeys(contract.caseCatalog, ['path', 'sha256'], 'contract-shape');
  if (
    contract.caseCatalog.path !== CASE_CATALOG_FILE_NAME
    || !/^[0-9a-f]{64}$/u.test(contract.caseCatalog.sha256)
  ) {
    fail('contract-shape');
  }
  expectExactKeys(contract.validatorIdentity, ['path', 'sha256'], 'contract-shape');
  if (
    contract.validatorIdentity.path !== VALIDATOR_FILE_NAME
    || !/^[0-9a-f]{64}$/u.test(contract.validatorIdentity.sha256)
  ) {
    fail('contract-shape');
  }
  if (contract.schema !== 'PSStyleGuide.WorkflowPolicyContract.v1' || contract.contractVersion !== 1) {
    fail('contract-version');
  }
  expectExactKeys(contract.actions, Object.keys(REQUIRED_ACTION_IDENTITIES), 'contract-actions');
  for (const [actionId, expected] of Object.entries(REQUIRED_ACTION_IDENTITIES)) {
    const observed = contract.actions[actionId];
    for (const [key, value] of Object.entries(expected)) {
      if (observed[key] !== value) {
        fail('action-identity');
      }
    }
    if (observed.runsUsing !== 'node24') {
      fail('action-runtime');
    }
    for (const input of Object.values(observed.inputs)) {
      expectExactKeys(input, ['default', 'required', 'disposition'], 'action-input-shape');
      if (!['Authored', 'ReviewedDefault', 'NotApplicable'].includes(input.disposition)) {
        fail('action-input-disposition');
      }
    }
  }
  if (
    contract.supplyFreeze.schema !== 'P1-SUPPLY-FREEZE-v1'
    || contract.supplyFreeze.yaml.version !== '2.9.0'
    || contract.supplyFreeze.advisoryDecision.producerAudit.vulnerabilities.high !== 5
    || contract.supplyFreeze.advisoryDecision.producerAudit.vulnerabilities.moderate !== 2
    || contract.supplyFreeze.advisoryDecision.producerAudit.vulnerabilities.critical !== 0
  ) {
    fail('supply-freeze');
  }
  validateProducerToolchain(contract.supplyFreeze.producer);
  // Counts alone would let the finding set change identity while staying at
  // 5 high and 2 moderate, so the authorized packages are pinned as well.
  expectDeepEqual(
    contract.supplyFreeze.advisoryDecision.producerAudit.findingKeys,
    AUTHORIZED_ADVISORY_FINDING_KEYS,
    'supply-freeze',
  );
  // Date.parse returns NaN for an unparsable value, and every comparison against
  // NaN is false, so comparing directly would silently skip the expiry gate rather
  // than trip it. Require a finite timestamp before the comparison is trusted.
  const intExpiresAt = typeof contract.supplyFreeze.advisoryDecision.expiresAtUtc === 'string'
    ? Date.parse(contract.supplyFreeze.advisoryDecision.expiresAtUtc)
    : Number.NaN;
  if (!Number.isFinite(intExpiresAt)) {
    fail('advisory-expiry-unparsable');
  }
  if (Date.now() > intExpiresAt) {
    fail('advisory-expired');
  }
  const rows = contract.reciprocalFoundation.rows;
  if (!Array.isArray(rows) || rows.length !== REQUIRED_RECIPROCAL_ROWS.length) {
    fail('reciprocal-matrix');
  }
  const rowIds = rows.map((row) => row.id);
  if (canonicalJson(rowIds) !== canonicalJson(REQUIRED_RECIPROCAL_ROWS)) {
    fail('reciprocal-matrix');
  }
  for (const row of rows) {
    expectExactKeys(row, ['id', 'status', 'observed', 'rationale'], 'reciprocal-matrix');
    if (!['same', 'intentional difference'].includes(row.status) || !row.observed || !row.rationale) {
      fail('reciprocal-matrix');
    }
  }
}

function validateMarkdownContract(policy) {
  expectExactKeys(policy, ['schema', 'extensions', 'entryPoints'], 'markdown-policy');
  if (policy.schema !== 'PSStyleGuide.MarkdownEntryPointPolicy.v1') {
    fail('markdown-policy');
  }
  expectDeepEqual(policy.extensions, REQUIRED_MARKDOWN_EXTENSIONS, 'markdown-policy');
  expectExactKeys(policy.entryPoints, [
    'rootPackageJson',
    'workflowPackageJson',
    'nestedLinter',
    'stagedSelector',
    'preCommit',
  ], 'markdown-policy');
  for (const entry of Object.values(policy.entryPoints)) {
    if (
      typeof entry.path !== 'string'
      || typeof entry.length !== 'number'
      || !Number.isInteger(entry.length)
      || entry.length < 1
      || !/^[0-9a-f]{64}$/u.test(entry.sha256)
    ) {
      fail('markdown-policy');
    }
  }
  const { entryPoints } = policy;
  expectExactKeys(entryPoints.rootPackageJson, ['path', 'length', 'sha256', 'lintScript'], 'markdown-policy');
  expectExactKeys(entryPoints.workflowPackageJson, ['path', 'length', 'sha256', 'lintScript'], 'markdown-policy');
  expectExactKeys(entryPoints.nestedLinter, [
    'path',
    'length',
    'sha256',
    'glob',
    'includeDotDirectories',
    'ignoredDirectoryNames',
    'retainedDotDirectoryNames',
  ], 'markdown-policy');
  expectExactKeys(entryPoints.stagedSelector, ['path', 'length', 'sha256', 'pathspecs'], 'markdown-policy');
  expectExactKeys(entryPoints.preCommit, ['path', 'length', 'sha256', 'extensions', 'linebreakArgument'], 'markdown-policy');
  if (
    entryPoints.rootPackageJson.path !== '../../package.json'
    || entryPoints.rootPackageJson.lintScript !== REQUIRED_ROOT_LINT_SCRIPT
    || entryPoints.workflowPackageJson.path !== 'package.json'
    || entryPoints.workflowPackageJson.lintScript !== REQUIRED_WORKFLOW_LINT_SCRIPT
    || entryPoints.nestedLinter.path !== 'lint-nested-markdown.js'
    || entryPoints.nestedLinter.glob !== '**/*.{md,mdc}'
    || entryPoints.nestedLinter.includeDotDirectories !== true
    || canonicalJson(entryPoints.nestedLinter.ignoredDirectoryNames)
      !== canonicalJson(REQUIRED_IGNORED_MARKDOWN_DIRECTORIES)
    || canonicalJson(entryPoints.nestedLinter.retainedDotDirectoryNames)
      !== canonicalJson(REQUIRED_RETAINED_MARKDOWN_DOT_DIRECTORIES)
    || entryPoints.stagedSelector.path !== 'lint-staged-markdown.mjs'
    || canonicalJson(entryPoints.stagedSelector.pathspecs) !== canonicalJson(['*.md', '*.mdc'])
    || entryPoints.preCommit.path !== '../../.pre-commit-config.yaml'
    || canonicalJson(entryPoints.preCommit.extensions) !== canonicalJson(REQUIRED_MARKDOWN_EXTENSIONS)
    || entryPoints.preCommit.linebreakArgument !== '--markdown-linebreak-ext=md,mdc'
  ) {
    fail('markdown-policy');
  }
}

function validateActionStep(step, expectedStep, contract, rawText) {
  const expectedKeys = ['name', 'id', 'uses', 'with'];
  if (expectedStep.if !== undefined) expectedKeys.push('if');
  if (expectedStep.continueOnError !== undefined) expectedKeys.push('continue-on-error');
  expectExactKeys(step, expectedKeys, 'action-step-shape');
  if (step.name !== expectedStep.name || step.id !== expectedStep.id) {
    fail('action-role');
  }
  if (step.if !== expectedStep.if || step['continue-on-error'] !== expectedStep.continueOnError) {
    fail('action-condition');
  }
  const action = contract.actions[expectedStep.action];
  const expectedUses = `${action.repository}@${action.sha}`;
  if (step.uses !== expectedUses) {
    fail('action-pin');
  }
  expectDeepEqual(step.with, contract.workflowPolicy.actionInputs[expectedStep.action], 'action-input');
  for (const [inputName, inputPolicy] of Object.entries(action.inputs)) {
    const isAuthored = Object.hasOwn(step.with, inputName);
    if ((inputPolicy.disposition === 'Authored') !== isAuthored) {
      fail('action-input-disposition');
    }
  }
  if (rawText !== null) {
    const escapedUses = expectedUses.replace(/[.*+?^${}()|[\]\\]/gu, '\\$&');
    const escapedRelease = action.release.replace(/[.*+?^${}()|[\]\\]/gu, '\\$&');
    const expression = new RegExp(`^[ \\t]+uses:[ \\t]+${escapedUses}[ \\t]+#[ \\t]+${escapedRelease}[ \\t]*$`, 'gmu');
    if ([...rawText.matchAll(expression)].length !== 1) {
      fail('action-release-annotation');
    }
  }
}

const GENERATOR_RESULT_PREDICATES = Object.freeze([
  ['NativeExit', '$intGeneratorExit -isnot [int] -or $intGeneratorExit -ne 0'],
  ['Schema', "$objResult.Schema -isnot [string] -or $objResult.Schema -cne 'PSStyleGuide.GeneratorResult.v2'"],
  ['GeneratorVersion', "$objResult.GeneratorVersion -isnot [string] -or $objResult.GeneratorVersion -cne '1.0.20260916.0'"],
  ['Overall', "$objResult.Overall -isnot [string] -or $objResult.Overall -notin @('Success', 'NoChange')"],
  ['Phase', "$objResult.Phase -isnot [string] -or $objResult.Phase -cne 'complete'"],
  ['Category', "$objResult.Category -isnot [string] -or $objResult.Category -cne 'none'"],
  ['NativeOutcome', "$objResult.NativeOutcome -isnot [string] -or $objResult.NativeOutcome -cne 'Success'"],
  ['ResultExitCode', '($objResult.ExitCode -isnot [int] -and $objResult.ExitCode -isnot [long]) -or $objResult.ExitCode -ne 0'],
]);
const GENERATOR_DIAGNOSTIC_PREFIX = 'Artifact generation failed result checks: ';

// This closed construction binds semantics before the run-byte digest. No
// caller value is used to form a name, separator or message. Exact tail shape
// also rejects interleaved early exits and additional output statements.
function validateGeneratorResultPolicy(source, contract) {
  if (typeof source !== 'string') fail('generator-result-source');
  const begin = '# BEGIN P1 GENERATOR RESULT\n';
  const end = '# END P1 GENERATOR RESULT\n';
  if (source.split(begin).length !== 2 || source.split(end).length !== 2) {
    fail('generator-result-region');
  }
  const beginOffset = source.indexOf(begin) + begin.length;
  const endOffset = source.indexOf(end);
  if (endOffset <= beginOffset || endOffset + end.length >= source.length) {
    fail('generator-result-region');
  }
  // Sample the marker's retained newline, not its comment token. The projection
  // deliberately blanks comments and rejects offsets inside a blanked token.
  if (powerShellBraceDepthAt(source, beginOffset - 1) !== 0 || powerShellBraceDepthAt(source, endOffset + end.length - 1) !== 0) {
    fail('generator-result-reachability');
  }
  source = source.slice(beginOffset, endOffset);
  const conversion = 'try {\n'
    + '    $objResult = $arrResult[0] | ConvertFrom-Json -NoEnumerate -ErrorAction Stop\n'
    + '} catch {\n'
    + "    throw 'The generator returned invalid JSON.'\n"
    + '}\n'
    + 'if ($null -eq $objResult -or $objResult.GetType() -ne [System.Management.Automation.PSCustomObject]) {\n'
    + "    throw 'The generator returned a non-object JSON result.'\n"
    + '}\n';
  if (source.split(conversion).length !== 2) fail('generator-result-json');
  source = source.replace(conversion, () => '$objResult = $arrResult[0] | ConvertFrom-Json\n');
  const blocks = GENERATOR_RESULT_PREDICATES.map(([label, predicate]) => (
    `if (${predicate}) {\n    [void]($listFailedChecks.Add('${label}'))\n}\n`
  ));
  const positions = blocks.map((block, index) => {
    if (source.split(block).length - 1 !== 1) {
      fail(`generator-result-predicate-${GENERATOR_RESULT_PREDICATES[index][0]}`);
    }
    return source.indexOf(block);
  });
  if (positions.some((position, index) => index > 0 && position <= positions[index - 1])) {
    fail('generator-result-order');
  }
  const accumulator = '$listFailedChecks = [System.Collections.Generic.List[string]]::new()\n';
  const guard = 'if ($listFailedChecks.Count -ne 0) {\n';
  const output = `    throw ('${GENERATOR_DIAGNOSTIC_PREFIX}{0}.' -f ($listFailedChecks -join ', '))\n`;
  for (const [fragment, category] of [
    [accumulator, 'accumulator'], [guard, 'guard'], [output, 'output'],
  ]) {
    if (source.split(fragment).length - 1 !== 1) fail(`generator-result-${category}`);
  }
  const start = '$objResult = $arrResult[0] | ConvertFrom-Json\n';
  const comment = '# Only fixed labels enter this list; result values must never reach the diagnostic.\n';
  const tail = start + comment + accumulator + blocks.join('') + guard + output + '}\n';
  if (source.split(start).length - 1 !== 1 || source.slice(source.indexOf(start)) !== tail) {
    fail('generator-result-flow');
  }
  const labels = GENERATOR_RESULT_PREDICATES.map(([label]) => label);
  const maximumMessage = GENERATOR_DIAGNOSTIC_PREFIX + labels.join(', ') + '.';
  expectDeepEqual(contract.workflowPolicy.generatorResultPolicy, {
    labels,
    prefix: GENERATOR_DIAGNOSTIC_PREFIX,
    separator: ', ',
    suffix: '.',
    maximumAsciiBytes: Buffer.byteLength(maximumMessage, 'ascii'),
    actualValues: false,
  }, 'generator-result-contract');
  if (!/^[\x20-\x7e]+$/u.test(maximumMessage)) fail('generator-result-vocabulary');
}

function validateRunStep(step, expectedStep, contract, requireRunIdentity = true) {
  const expectedKeys = ['name', 'shell', 'run'];
  if (expectedStep.id !== undefined) expectedKeys.push('id');
  if (expectedStep.workingDirectory !== undefined) expectedKeys.push('working-directory');
  if (expectedStep.if !== undefined) expectedKeys.push('if');
  if (expectedStep.continueOnError !== undefined) expectedKeys.push('continue-on-error');
  expectExactKeys(step, expectedKeys, 'run-step-shape');
  if (expectedStep.id === 'generate_style_guide_artifacts') {
    validateGeneratorResultPolicy(step.run, contract);
  }
  if (
    step.name !== expectedStep.name
    || step.id !== expectedStep.id
    || step.shell !== expectedStep.shell
    || step['working-directory'] !== expectedStep.workingDirectory
    || step.if !== expectedStep.if
    || step['continue-on-error'] !== expectedStep.continueOnError
    || typeof step.run !== 'string'
    || (requireRunIdentity && sha256(Buffer.from(step.run, 'utf8')) !== expectedStep.runSha256)
  ) {
    fail('run-role');
  }
  for (const pattern of contract.workflowPolicy.forbiddenRunPatterns) {
    if (new RegExp(pattern, 'iu').test(step.run)) {
      fail('forbidden-side-effect');
    }
  }
}

// P1 isolation checks adapted from TerraformStyleGuide e5064a672c10f4fad90f36e82af33ff8fc230b5f.
// Fixed positive command surfaces complement complete-step digest backstops.
function reject(category, reason) { throw new PolicyError(category, reason); }
function assertKeys(value, keys, label) {
  try { expectExactKeys(value, keys, 'schema'); }
  catch (error) { if (!(error instanceof PolicyError)) throw error; reject('schema', label + ' has missing or extra keys'); }
}

const REVIEWED_COMMAND_BINDINGS = Object.freeze({
  strGitPath: { source: 'strResolvedGit', paths: ['/usr/bin/git', '/bin/git'] },
  strCurlPath: { source: 'strResolvedCurl', paths: ['/usr/bin/curl', '/bin/curl'] },
  strTarPath: { source: 'strResolvedTar', paths: ['/usr/bin/tar', '/bin/tar'] },
});

const REVIEWED_ACQUIRE_CMDLETS = new Set([
  'get-filehash',
  'new-variable',
  'select-object',
  'test-path',
  'where-object',
  'write-host',
]);

const REVIEWED_ACQUIRE_COMMANDS = Object.freeze([
  'Get-FileHash', 'New-Variable', 'Select-Object', 'Test-Path', 'Where-Object',
  'Write-Host', 'if', 'throw',
]);

const REVIEWED_ACQUIRE_STATIC_CALLS = new Set([
  'system.io.directory::createdirectory',
  'system.io.directory::enumeratefilesystementries',
  'system.io.file::exists',
  'system.io.path::combine',
  'string::isnullorempty',
]);

const NETWORK_CLIENT =/\b(?:curl|wget|Invoke-WebRequest|Invoke-RestMethod|iwr|irm|Start-BitsTransfer|Net\.WebClient|WebClient|HttpClient|WebRequest|TcpClient|UdpClient|HttpListener|Socket)\b|System\.Net\./iu;

const MARKDOWN_PRELUDE_END = "if ($strGlobalConfigDirectory -cne '/etc') {\n" +
  "    throw 'supply: the neutralized global npm configuration is not under a root-owned directory'\n" +
  '}\n';

const REVIEWED_NODE_ARCHIVE_SHA256 = 'D6C664DF3F3F61458E8C277585571328522D705166723A7C7823A9253A4D15A0';

const BUILD_ACQUIRE = Object.freeze({
  name: 'Acquire triggering revision without an action',
  classifiedStatuses: 5,
  networkClients: 0,
  tail: '& $strGitPath -c core.hooksPath=/dev/null init --quiet .\nif ($LASTEXITCODE -ne 0) { throw "acquire: git init exited $LASTEXITCODE" }\n& $strGitPath remote add origin "$strServerUrl/$strRepository"\nif ($LASTEXITCODE -ne 0) { throw "acquire: git remote add exited $LASTEXITCODE" }\n# Fetching the commit itself, not a ref that names it. No credential\n# is supplied and none is configured, so nothing is persisted for the\n# next step to have to clean up.\n& $strGitPath -c credential.helper= -c http.extraheader= -c core.hooksPath=/dev/null fetch --depth 1 --no-tags --no-recurse-submodules origin $strSha\nif ($LASTEXITCODE -ne 0) { throw "acquire: git fetch exited $LASTEXITCODE" }\n& $strGitPath -c core.hooksPath=/dev/null checkout --quiet --detach FETCH_HEAD\nif ($LASTEXITCODE -ne 0) { throw "acquire: git checkout exited $LASTEXITCODE" }\n$strHead = (& $strGitPath rev-parse HEAD).Trim()\nif ($LASTEXITCODE -ne 0 -or $strHead -cne $strSha) {\n    throw \'acquire: the checked out revision is not the triggering revision\'\n}\nWrite-Host "acquire: anonymous shallow checkout of $strSha"',
  digest: '201af2ff2fad27dcb14f4c84867c853f3528ca48ff1aaf865c6c31039c82dd64',
});

const MARKDOWN_ACQUIRE = Object.freeze({
  name: 'Acquire triggering revision and pinned toolchain without an action',
  classifiedStatuses: 7,
  digest: 'ede69b239684d6a0bf393a331e7eceab1725fbcae94ed2ede287cea4d51fe832',
  networkClients: 1,
  extraSequences: Object.freeze([
    ['the exact reviewed Node archive',
      "$strNodeUrl = 'https://nodejs.org/dist/v24.18.1/node-v24.18.1-linux-x64.tar.xz'"],
    ['the reviewed Node archive digest',
      `$strReviewedNodeSha256 = '${REVIEWED_NODE_ARCHIVE_SHA256}'`],
    ['the download, its verification, and the extraction as one uninterrupted block',
      '$strNodeUrl = \'https://nodejs.org/dist/v24.18.1/node-v24.18.1-linux-x64.tar.xz\'\n$strReviewedNodeSha256 = \'D6C664DF3F3F61458E8C277585571328522D705166723A7C7823A9253A4D15A0\'\n$strNodeRoot = [System.IO.Path]::Combine($env:RUNNER_TEMP, \'node24\')\n$strArchivePath = [System.IO.Path]::Combine($env:RUNNER_TEMP, \'node24.tar.xz\')\n& $strCurlPath --silent --show-error --fail --location --proto \'=https\' --tlsv1.2 --output $strArchivePath $strNodeUrl\nif ($LASTEXITCODE -ne 0) { throw "acquire: node download exited $LASTEXITCODE" }\n$strObservedNodeSha256 = (Get-FileHash -LiteralPath $strArchivePath -Algorithm SHA256).Hash\nif ($strObservedNodeSha256 -cne $strReviewedNodeSha256) {\n    throw \'acquire: the Node archive does not match the reviewed digest\'\n}\n[void][System.IO.Directory]::CreateDirectory($strNodeRoot)\n& $strTarPath -xJf $strArchivePath -C $strNodeRoot --strip-components=1\nif ($LASTEXITCODE -ne 0) { throw "acquire: node extraction exited $LASTEXITCODE" }\nWrite-Host "acquire: revision $strSha and the reviewed Node distribution"'],
  ]),
  tail: '$strNodeUrl = \'https://nodejs.org/dist/v24.18.1/node-v24.18.1-linux-x64.tar.xz\'\n$strReviewedNodeSha256 = \'D6C664DF3F3F61458E8C277585571328522D705166723A7C7823A9253A4D15A0\'\n$strNodeRoot = [System.IO.Path]::Combine($env:RUNNER_TEMP, \'node24\')\n$strArchivePath = [System.IO.Path]::Combine($env:RUNNER_TEMP, \'node24.tar.xz\')\n& $strCurlPath --silent --show-error --fail --location --proto \'=https\' --tlsv1.2 --output $strArchivePath $strNodeUrl\nif ($LASTEXITCODE -ne 0) { throw "acquire: node download exited $LASTEXITCODE" }\n$strObservedNodeSha256 = (Get-FileHash -LiteralPath $strArchivePath -Algorithm SHA256).Hash\nif ($strObservedNodeSha256 -cne $strReviewedNodeSha256) {\n    throw \'acquire: the Node archive does not match the reviewed digest\'\n}\n[void][System.IO.Directory]::CreateDirectory($strNodeRoot)\n& $strTarPath -xJf $strArchivePath -C $strNodeRoot --strip-components=1\nif ($LASTEXITCODE -ne 0) { throw "acquire: node extraction exited $LASTEXITCODE" }\nWrite-Host "acquire: revision $strSha and the reviewed Node distribution"',
});

const REVIEWED_MARKDOWN_GATES = Object.freeze([
  ['if ($intNodeVersionExit -ne 0 -or $strNodeVersion -cne ', [0]],
  ['if ($intNpmVersionExit -ne 0 -or $strNpmVersion -cne ', [0]],
  ['if ($strPackageBefore -cne $strReviewedPackageHash -or $strLockBefore -cne $strReviewedLockHash) {', [0]],
  ['if ($strGlobalConfigDirectory -cne ', [0]],
  ['if ($strPackageAfterInstall -cne $strPackageBefore -or $strLockAfterInstall -cne $strLockBefore) {', [0]],
  ['if ($strPackageFinal -cne $strPackageBefore -or $strLockFinal -cne $strLockBefore) {', [0]],
]);

const REVIEWED_LINT_GATES = Object.freeze([
  ['if ($strLintConfigHash -cne $strReviewedLintConfigHash -or $strLintHelperHash -cne $strReviewedLintHelperHash) {', [0]],
  ['if ($strLintConfigAfterInstall -cne $strReviewedLintConfigHash -or $strLintHelperAfterInstall -cne $strReviewedLintHelperHash) {', [0]],
]);

const QUALIFIED_ASSIGNMENT = /\$(?:\{([A-Za-z_][A-Za-z0-9_]*:[A-Za-z_][A-Za-z0-9_]*)\}|([A-Za-z_][A-Za-z0-9_]*:[A-Za-z_][A-Za-z0-9_]*))[ \t]*(?:\+|-|\*|\/|%)?=(?!=)/gu;

const MARKDOWN_STEP_COMMANDS = Object.freeze([
  'Get-Content', 'ConvertFrom-Json',
  'Get-Content', 'Get-FileHash', 'Remove-Item', 'Test-Path', 'Write-Host',
]);

const MARKDOWN_STEP_KEYWORDS = Object.freeze([
  'catch',
  'if', 'elseif', 'else', 'foreach', 'for', 'while', 'do', 'switch',
  'try', 'finally', 'throw', 'break', 'continue',
]);

const MARKDOWN_COMMAND_POSITION = /(?:^[ \t]*|(?<!\$)\{[ \t]*|[;}|=(,][ \t]*|&&[ \t]*|\|\|[ \t]*)([A-Za-z_.\/\\][^\s;{}()]*)/gmu;

const MARKDOWN_ENV_WRITE = /\$\{?env:([A-Za-z_][A-Za-z0-9_]*)\}?[ \t]*(?:\+|-|\*|\/|%|\?\?)?=/giu;

const MARKDOWN_DYNAMIC_EXECUTION = /\b(?:Invoke-Expression|iex|Invoke-Command|icm|Start-Process|saps)\b|\[\s*(?:System\.)?Management\.Automation\.ScriptBlock\s*\]|\[\s*scriptblock\s*\]\s*::\s*Create|\$ExecutionContext\s*\.\s*InvokeCommand|(?:System\.)?Diagnostics\.Process/iu;

const PROCESS_TERMINATION = /\[\s*(?:System\.)?Environment\s*\]\s*::\s*(?:Exit|FailFast)|\bSetShouldExit\b/iu;

const DOT_SOURCE = /(?:^[ \t]*|[;{}|=(,][ \t]*|&&[ \t]*|\|\|[ \t]*)\.(?=[ \t])/gmu;

const STATIC_MEMBER_CALL =
  /\[\s*([A-Za-z_][A-Za-z0-9_.]*(?:\[[A-Za-z0-9_.,[\] \t]*\])?)\s*\]\s*::\s*([A-Za-z_][A-Za-z0-9_]*)/gu;

const REFLECTION_SURFACE =
  /\b(?:GetType|GetMethods?|InvokeMember|GetProperty|GetField|GetConstructor|GetMember|MakeGenericMethod|Activator|Reflection|Assembly|CreateInstance|TypeHandle)\b/iu;

const REVIEWED_PACKAGE_DIGESTS = {"package.json":"59e676d981cffa350cb72e7ea4b1aeec2c49d56621958a095aa0e76733ec2cd9","package-lock.json":"5efc1286025cdc3ad03796c5f4e44cc697e674a30e61de05e299b2a30abad1a2"};
const REVIEWED_LINT_DIGESTS = {".markdownlint.jsonc":"5eb07bf7f30829e0091e82f235a96fdba21be1ef1160ca1e22cdbe8d82da5300","lint-nested-markdown.js":"b20aaab172224da4377cda75fa6cad1a8eeb00f8bdd26737ffe0e6c2ad222492"};
const REVIEWED_POLICY_STEP_DIGEST = '';
const REVIEWED_LINT_STEP_DIGEST = '';
const MARKDOWN_JOBS = Object.freeze({
  policy: Object.freeze({
    stepId: 'validate',
    name: 'Install without executing packages and validate workflow policy',
    digest: REVIEWED_POLICY_STEP_DIGEST,
    envWrites: Object.freeze([
      'CI', 'PATH', 'GIT_CONFIG_NOSYSTEM', 'GIT_CONFIG_GLOBAL', 'GIT_TERMINAL_PROMPT', 'P1_EXPECTED_BUILD_DIGEST', 'P1_EXPECTED_MARKDOWN_DIGEST',
      'npm_config_globalconfig', 'npm_config_userconfig',
    ]),
    capturedStatuses: Object.freeze(['intNodeVersionExit', 'intNpmVersionExit', 'intInstallExit', 'intPreflightExit', 'intPolicyExit']),
    invocations: Object.freeze([
      '$strNodeVersion = (& $strNodePath --version).Trim()',
      '$strNpmVersion = (& $strNpmPath --version).Trim()',
      '& $strNpmPath ci --ignore-scripts --no-audit --no-fund',
      '$arrPreflight = @(& $strNodePath ./Validate-WorkflowPolicy.mjs --preflight)',
      '$arrPolicy = @(& $strNodePath ./Validate-WorkflowPolicy.mjs build.yml markdownlint.yml)',
    ]),
    fragments: Object.freeze([
      './Validate-WorkflowPolicy.mjs build.yml markdownlint.yml',
      '$env:P1_EXPECTED_BUILD_DIGEST = (Get-FileHash -LiteralPath ./build.yml -Algorithm SHA256).Hash',
      '$env:P1_EXPECTED_MARKDOWN_DIGEST = (Get-FileHash -LiteralPath ./markdownlint.yml -Algorithm SHA256).Hash',
      'validation: package metadata changed after installation',
      'validation: workflow policy validation failed',
      'if ($strPackageAfterInstall -cne $strPackageBefore -or $strLockAfterInstall -cne $strLockBefore) {',
      'if ($strPackageFinal -cne $strPackageBefore -or $strLockFinal -cne $strLockBefore) {',
    ]),
    phases: Object.freeze([
      'supply: package metadata does not match the reviewed supply digest',
      'supply: repository-controlled npm configuration is present',
      '$env:P1_EXPECTED_BUILD_DIGEST = (Get-FileHash -LiteralPath ./build.yml -Algorithm SHA256).Hash',
      '$env:P1_EXPECTED_MARKDOWN_DIGEST = (Get-FileHash -LiteralPath ./markdownlint.yml -Algorithm SHA256).Hash',
      'ci --ignore-scripts --no-audit --no-fund',
      'npm-ci: package metadata changed during frozen installation',
      './Validate-WorkflowPolicy.mjs build.yml markdownlint.yml',
      'validation: package metadata changed after installation',
      'validation: workflow policy validation failed',
    ]),
  }),
  markdownlint: Object.freeze({
    stepId: 'lint',
    name: 'Install and lint both Markdown surfaces',
    digest: REVIEWED_LINT_STEP_DIGEST,
    envWrites: Object.freeze([
      'CI', 'PATH', 'GIT_CONFIG_NOSYSTEM', 'GIT_CONFIG_GLOBAL', 'GIT_TERMINAL_PROMPT', 'npm_config_globalconfig', 'npm_config_userconfig',
    ]),
    capturedStatuses: Object.freeze(['intNodeVersionExit', 'intNpmVersionExit', 'intInstallExit', 'intOuterExit', 'intNestedExit']),
    invocations: Object.freeze([
      '$strNodeVersion = (& $strNodePath --version).Trim()',
      '$strNpmVersion = (& $strNpmPath --version).Trim()',
      '& $strNpmPath ci --ignore-scripts --no-audit --no-fund',
      '& $strNpmPath run lint:md',
      '& $strNpmPath run lint:md:nested',
    ]),
    fragments: Object.freeze([
      'run lint:md',
      'run lint:md:nested',
      REVIEWED_LINT_DIGESTS['.markdownlint.jsonc'].toUpperCase(),
      REVIEWED_LINT_DIGESTS['lint-nested-markdown.js'].toUpperCase(),
      'Get-FileHash -LiteralPath .markdownlint.jsonc -Algorithm SHA256',
      'Get-FileHash -LiteralPath lint-nested-markdown.js -Algorithm SHA256',
      'supply: lint configuration or helper does not match the reviewed digest',
      'supply: lint configuration or helper changed during installation',
      'validation: package metadata changed after installation or linting',
      'validation: one or more lint phases failed',
      'if ($strLintConfigHash -cne $strReviewedLintConfigHash -or $strLintHelperHash -cne $strReviewedLintHelperHash) {',
      'if ($strLintConfigAfterInstall -cne $strReviewedLintConfigHash -or $strLintHelperAfterInstall -cne $strReviewedLintHelperHash) {',
      'if ($strPackageAfterInstall -cne $strPackageBefore -or $strLockAfterInstall -cne $strLockBefore) {',
      'if ($strPackageFinal -cne $strPackageBefore -or $strLockFinal -cne $strLockBefore) {',
    ]),
    phases: Object.freeze([
      'supply: package metadata does not match the reviewed supply digest',
      'supply: repository-controlled npm configuration is present',
      'supply: lint configuration or helper does not match the reviewed digest',
      'ci --ignore-scripts --no-audit --no-fund',
      'npm-ci: package metadata changed during frozen installation',
      'supply: lint configuration or helper changed during installation',
      'run lint:md\n',
      'run lint:md:nested',
      'validation: package metadata changed after installation or linting',
      'validation: one or more lint phases failed',
    ]),
  }),
});

function assertReviewedGuards(strCode, arrGuards, strCategory, fnMessage) {
  for (const [strFragment, arrDepths] of arrGuards) {
    const arrObserved = [];
    for (let at = strCode.indexOf(strFragment); at >= 0; at = strCode.indexOf(strFragment, at + 1)) {
      arrObserved.push(powerShellBraceDepthAt(strCode, at));
    }
    if (arrObserved.length !== arrDepths.length) {
      reject(strCategory, fnMessage('missing', strFragment));
    }
    for (let index = 0; index < arrDepths.length; index += 1) {
      if (arrObserved[index] !== arrDepths[index]) {
        reject(strCategory, fnMessage('unreachable', strFragment));
      }
    }
  }
}

function normalizeLineContinuations(strText) {
  return strText.replace(/(?<!`)((?:``)*)`\r?\n[ \t]*/gu, '$1 ');
}

function variableWritePattern(strName) {
  return new RegExp(
    `\\$(?:\\{(?:[A-Za-z_][A-Za-z0-9_]*:)?${strName}\\}` +
    `|(?:[A-Za-z_][A-Za-z0-9_]*:)?${strName}(?![A-Za-z0-9_]))` +
    `[ \\t]*(?:(?:\\+\\+|--)(?![A-Za-z0-9_])|(?:\\+|-|\\*|\\/|%|\\?\\?)?=(?!=))`,
    'giu');
}

function assertLiteralStaticCalls(strCode, strCategory, strLabel) {
  assertTypeLiteralsAreNotValues(strCode, strCategory, strLabel);
  if (REFLECTION_SURFACE.test(strCode)) {
    reject(strCategory, `${strLabel} reaches a member through reflection`);
  }
  const arrCalls = [...strCode.matchAll(STATIC_MEMBER_CALL)];
  const setClaimed = new Set(arrCalls.map((objCall) => objCall.index + objCall[0].indexOf('::')));
  for (const objAt of strCode.matchAll(/::/gu)) {
    if (!setClaimed.has(objAt.index)) {
      const strContext = strCode.slice(Math.max(0, objAt.index - 40), objAt.index + 16).replace(/\s+/gu, ' ').trim();
      reject(strCategory, `${strLabel} reaches a static member other than by naming a literal type and a literal member: ${strContext}`);
    }
  }
  return arrCalls;
}

function assertTypeLiteralsAreNotValues(strCode, strCategory, strLabel) {
  const setTypeLiteralEnd = new Set();
  for (let intAt = 0; intAt < strCode.length; intAt += 1) {
    if (strCode[intAt] !== '[') continue;
    const strBefore = strCode.slice(0, intAt).replace(/[ \t]+$/u, '');
    const strPrev = strBefore.slice(-1);
    if (/[A-Za-z0-9_)$]/u.test(strPrev)) continue;
    if (strPrev === ']' && !setTypeLiteralEnd.has(strBefore.length - 1)) continue;
    let intDepth = 0;
    let intEnd = intAt;
    for (; intEnd < strCode.length; intEnd += 1) {
      if (strCode[intEnd] === '[') intDepth += 1;
      else if (strCode[intEnd] === ']') { intDepth -= 1; if (intDepth === 0) break; }
    }
    if (intDepth !== 0) continue;
    const strInner = strCode.slice(intAt + 1, intEnd).trim();
    if (!/^[A-Za-z_][A-Za-z0-9_.,[\] \t]*$/u.test(strInner)) continue;
    setTypeLiteralEnd.add(intEnd);
    if (!/^[:$@[]/u.test(strCode.slice(intEnd + 1).replace(/^[ \t]*/u, ''))) {
      reject(strCategory, `${strLabel} uses the type [${strInner}] as a value rather than as a static call or a cast`);
    }
  }
}

function powerShellCodeProjection(text, options) {
  const escapes = (options && options.escapes) || 'blank';
  const characters = [];
  const emit = (from, to, blankIt) => {
    for (let i = from; i < Math.min(to, text.length); i += 1) {
      characters.push(blankIt && text[i] !== '\n' ? ' ' : text[i]);
    }
  };
  let index = 0;
  let lastEscapedIndex = -1;
  while (index < text.length) {
    const character = text[index];
    if (character === '<' && text[index + 1] === '#') {
      const close = text.indexOf('#>', index + 2);
      const stop = close === -1 ? text.length : close + 2;
      emit(index, stop, true);
      index = stop;
      continue;
    }
    if (character === '`') {
      if (escapes === 'unescape') {
        if (index + 1 < text.length) characters.push(text[index + 1]);
      } else {
        emit(index, index + 2, true);
      }
      lastEscapedIndex = index + 1;
      index += 2;
      continue;
    }
    if (character === '#') {
      const previous = index === 0 ? '' : text[index - 1];
      const previousWasEscaped = index > 0 && index - 1 === lastEscapedIndex;
      if (!previousWasEscaped &&
          (previous === '' || previous === ' ' || previous === '\t' ||
           previous === '\n' || previous === '\r')) {
        const start = index;
        while (index < text.length && text[index] !== '\n') index += 1;
        emit(start, index, true);
        continue;
      }
      characters.push(character);
      index += 1;
      continue;
    }
    if (character === "'" || character === '"') {
      const quote = character;
      characters.push(quote);
      index += 1;
      while (index < text.length) {
        if (quote === '"' && text[index] === '$' && text[index + 1] === '(') {
          let depth = 0;
          const start = index;
          while (index < text.length) {
            if (text[index] === '(') depth += 1;
            else if (text[index] === ')') { depth -= 1; if (depth === 0) { index += 1; break; } }
            index += 1;
          }
          characters.push(powerShellCodeProjection(text.slice(start, index), options));
          continue;
        }
        if (quote === '"' && text[index] === '`') {
          if (escapes === 'unescape' && index + 1 < text.length) characters.push(text[index + 1]);
          else emit(index, index + 2, true);
          index += 2;
          continue;
        }
        if (text[index] === quote) {
          if (text[index + 1] === quote) { emit(index, index + 2, true); index += 2; continue; }
          characters.push(quote);
          index += 1;
          break;
        }
        emit(index, index + 1, true);
        index += 1;
      }
      continue;
    }
    characters.push(character);
    index += 1;
  }
  return characters.join('');
}

function powerShellTokenView(text) {
  return powerShellCodeProjection(text, { escapes: 'unescape' });
}

function powerShellBraceDepthAt(text, offset) {
  const code = powerShellCodeProjection(text);
  if (offset < 0 || offset > code.length) return null;
  if (offset < code.length && code[offset] !== text[offset]) return null;
  let depth = 0;
  for (let index = 0; index < offset; index += 1) {
    if (code[index] === '{') depth += 1;
    else if (code[index] === '}') depth -= 1;
  }
  return depth;
}

function invocationOperatorOffset(projectedLine) {
  const intCall = projectedLine.indexOf('&');
  DOT_SOURCE.lastIndex = 0;
  const objDot = DOT_SOURCE.exec(projectedLine);
  const intDot = objDot === null ? -1 : objDot.index + objDot[0].indexOf('.');
  if (intCall < 0) return intDot;
  if (intDot < 0) return intCall;
  return Math.min(intCall, intDot);
}

function validateAcquireStep(step, label, expected) {
  assertKeys(step, ['name', 'id', 'shell', 'run'], label);
  if (step.name !== expected.name || step.shell !== 'pwsh') {
    reject('acquire-policy', `${label} execution contract changed`);
  }
  const requiredSequences = [
    ['native-command error mapping is disabled',
      'if (Test-Path Variable:PSNativeCommandUseErrorActionPreference) {\n' +
      '    $PSNativeCommandUseErrorActionPreference = $false\n' +
      '}'],
    ['the server the runner named',
      "if ($strServerUrl -cne 'https://github.com') {"],
    ['a plain owner/name repository',
      "if ($strRepository -cne 'franklesniak/PSStyleGuide') {"],
    ['a full commit hash rather than a ref',
      "if ($strSha -cnotmatch '^[0-9a-f]{40}$') {"],
    ['an empty workspace before fetching',
      'if (@([System.IO.Directory]::EnumerateFileSystemEntries($PWD.Path)).Count -ne 0) {'],
    ['a fetch of the commit itself',
      '& $strGitPath -c credential.helper= -c http.extraheader= -c core.hooksPath=/dev/null fetch --depth 1 --no-tags --no-recurse-submodules origin $strSha'],
    ['that the checked out revision is the triggering revision',
      '$strHead = (& $strGitPath rev-parse HEAD).Trim()\n' +
      'if ($LASTEXITCODE -ne 0 -or $strHead -cne $strSha) {'],
  ];
  for (const [requirement, sequence] of [...requiredSequences, ...(expected.extraSequences ?? [])]) {
    if (!step.run.includes(sequence)) {
      reject('acquire-policy', `${label} no longer asserts ${requirement}`);
    }
  }
  const credentialGuard = "$env:GIT_CONFIG_NOSYSTEM = '1'\n$env:GIT_CONFIG_GLOBAL = '/dev/null'\n$env:GIT_TERMINAL_PROMPT = '0'\nif (-not [string]::IsNullOrEmpty($env:GITHUB_TOKEN) -or\n    -not [string]::IsNullOrEmpty($env:GH_TOKEN) -or\n    -not [string]::IsNullOrEmpty($env:ACTIONS_RUNTIME_TOKEN)) {\n    throw 'credential-policy: a token was projected into a code job'\n}\n";
  if (step.run.split(credentialGuard).length !== 2) reject('acquire-policy', `${label} lacks the fixed credential absence guard`);
  const credentialView = step.run.replace(credentialGuard, '').replace('-c credential.helper= -c http.extraheader= -c core.hooksPath=/dev/null fetch', 'fetch');
  if (/@github\.com|credential\.helper|extraheader|GIT_ASKPASS|GITHUB_TOKEN|GH_TOKEN|ACTIONS_RUNTIME_TOKEN/iu.test(credentialView)) {
    reject('acquire-policy', `${label} introduces a credential into an anonymous fetch`);
  }
  const classifiedStatuses = step.run.match(/^if \(\$LASTEXITCODE -ne 0/gmu)?.length ?? 0;
  if (classifiedStatuses !== expected.classifiedStatuses) {
    reject('acquire-policy', `${label} native-status classification count changed`);
  }
  if (/\b(?:exit|return|break|continue|trap)\b/iu.test(step.run) || PROCESS_TERMINATION.test(step.run)) {
    reject('acquire-policy', `${label} adds control flow that can bypass a required assertion`);
  }
  const stepCode = powerShellTokenView(step.run);
  const arrReviewedTargets = ['$strGitPath', '$strCurlPath', '$strTarPath'];
  for (const call of stepCode.matchAll(/&\s*(\S+)/gu)) {
    if (!arrReviewedTargets.includes(call[1])) {
      reject('acquire-policy', `${label} invokes something other than a reviewed literal command`);
    }
  }
  for (const call of stepCode.matchAll(/(?:^[ \t]*|[;{|=(,][ \t]*|&&[ \t]*|\|\|[ \t]*)\.[^\S\n]*([^\s]+)/gmu)) {
    if (!arrReviewedTargets.includes(call[1])) {
      reject('acquire-policy', `${label} dot-sources something other than a reviewed literal command`);
    }
  }
  if (/(?:^[ \t]*|[;{|=(][ \t]*|&&[ \t]*)(?:\/(?:usr\/)?bin\/)?(?:bash|sh|dash|ksh|zsh|csh|tcsh|python[0-9.]*|perl|ruby|node|pwsh|powershell|env|xargs|awk|eval|nohup|setsid|timeout)\b/imu.test(stepCode)) {
    reject('acquire-policy', `${label} invokes a native interpreter`);
  }
  if (/GITHUB_ENV|GITHUB_PATH|GITHUB_OUTPUT|GITHUB_STATE|GITHUB_STEP_SUMMARY/u.test(step.run)) {
    reject('acquire-policy', `${label} writes a runner step communication file`);
  }
  if (/GetEnvironmentVariable|SetEnvironmentVariable/iu.test(stepCode)) {
    reject('acquire-policy', `${label} resolves an environment variable through a computed name`);
  }
  if (/\b(?:AppendAllText|AppendAllLines|WriteAllText|WriteAllLines|AppendText|CreateText|Add-Content|Set-Content|Out-File|New-Item|Tee-Object)\b|>>?[^\S\n]*\$/iu.test(stepCode)) {
    reject('acquire-policy', `${label} writes a file outside the reviewed native tools`);
  }
  if (/\b(?:Invoke-Expression|iex|Invoke-Command|icm|Start-Process|saps)\b|\[\s*(?:System\.)?Management\.Automation\.ScriptBlock\s*\]|\[\s*scriptblock\s*\]\s*::\s*Create|\$ExecutionContext\s*\.\s*InvokeCommand|(?:System\.)?Diagnostics\.Process/iu.test(stepCode)) {
    reject('acquire-policy', `${label} adds a dynamic or indirect execution path`);
  }
  const networkCalls = (stepCode.match(/&\s*\$strCurlPath\b/gu) ?? []).length;
  if (networkCalls !== expected.networkClients) {
    reject('acquire-policy', `${label} network request count changed`);
  }
  if (expected.tail !== undefined && !step.run.trimEnd().endsWith(expected.tail)) {
    reject('acquire-policy', `${label} does not end at the verified extraction`);
  }
  if (/\S*\.(?:ps1|psm1|sh|bash|zsh|py|rb|pl|mjs|cjs|js)\b/iu.test(stepCode)) {
    reject('acquire-policy', `${label} references an executable script path`);
  }
  if (NETWORK_CLIENT.test(stepCode)) {
    reject('acquire-policy', `${label} adds a network client`);
  }
  if (/\bNew-Object\b/iu.test(stepCode)) {
    reject('acquire-policy', `${label} constructs an object through New-Object`);
  }
  for (const call of assertLiteralStaticCalls(stepCode, 'acquire-policy', label)) {
    if (!REVIEWED_ACQUIRE_STATIC_CALLS.has(`${call[1]}::${call[2]}`.toLowerCase())) {
      reject('acquire-policy', `${label} calls an unreviewed static member: ${call[1]}::${call[2]}`);
    }
  }
  for (const objCmdlet of stepCode.matchAll(/\b([A-Z][a-z]+-[A-Z][A-Za-z]+)\b/gu)) {
    if (!REVIEWED_ACQUIRE_CMDLETS.has(objCmdlet[1].toLowerCase())) {
      reject('acquire-policy', `${label} invokes an unreviewed cmdlet: ${objCmdlet[1]}`);
    }
  }
  const fixedGitCalls = ["& $strGitPath -c core.hooksPath=/dev/null init --quiet .","& $strGitPath -c credential.helper= -c http.extraheader= -c core.hooksPath=/dev/null fetch --depth 1 --no-tags --no-recurse-submodules origin $strSha","& $strGitPath -c core.hooksPath=/dev/null checkout --quiet --detach FETCH_HEAD"];
  const bareCode = stepCode.split('\n').map(line => fixedGitCalls.includes(line) ? '' : line).join('\n');
  for (const objToken of bareCode.matchAll(MARKDOWN_COMMAND_POSITION)) {
    if (!REVIEWED_ACQUIRE_COMMANDS.includes(objToken[1])) {
      reject('acquire-policy', `${label} runs an unreviewed bare command: ${objToken[1]}`);
    }
  }
  if (/[0-9]?>{1,2}(?!&)/u.test(stepCode)) {
    reject('acquire-policy', `${label} redirects output to a file`);
  }
  const countOf = (haystack, needle) => haystack.split(needle).length - 1;
  for (const [strTarget, objBinding] of Object.entries(REVIEWED_COMMAND_BINDINGS)) {
    if (!stepCode.includes(`$${strTarget}`)) continue;
    if (countOf(stepCode, `New-Variable -Name ${strTarget} -Value $${objBinding.source} -Option Constant`) !== 1) {
      reject('acquire-policy', `${label} does not bind $${strTarget} exactly once as a reviewed constant`);
    }
    if (new RegExp(`\\$${strTarget}\\s*=`, 'u').test(stepCode)) {
      reject('acquire-policy', `${label} assigns $${strTarget} outside its reviewed constant binding`);
    }
    if ((stepCode.match(new RegExp(`(?<!\\$)\\b${strTarget}\\b`, 'gu')) ?? []).length !== 1) {
      reject('acquire-policy', `${label} names ${strTarget} outside its reviewed constant binding`);
    }
    const strResolve = `$${objBinding.source} = @(${objBinding.paths.map((p) => `'${p}'`).join(', ')}) | Where-Object { [System.IO.File]::Exists($_) } | Select-Object -First 1`;
    if (countOf(step.run, strResolve) !== 1) {
      reject('acquire-policy', `${label} does not resolve $${objBinding.source} from its reviewed absolute paths`);
    }
    if (countOf(stepCode, `$${objBinding.source} =`) !== 1) {
      reject('acquire-policy', `${label} assigns $${objBinding.source} more than once`);
    }
  }
  if (/[^\t\n\x20-\x7e]/u.test(step.run)) {
    reject('acquire-policy', `${label} contains a character outside printable ASCII`);
  }
  if (/--%/u.test(step.run)) {
    reject('acquire-policy', `${label} uses the stop-parsing token`);
  }
  if (crypto.createHash('sha256').update(step.run, 'utf8').digest('hex') !== expected.digest) {
    reject('acquire-policy', `${label} script does not match its reviewed digest`);
  }
}

function validateCredentialCleanupStep(step, label, expectedDigest) {
  assertKeys(step, ['name', 'id', 'shell', 'run'], label);
  if (step.name !== 'Verify checkout credential cleanup' || step.shell !== 'pwsh') {
    reject('credential-policy', `${label} execution contract changed`);
  }
  const requiredSequences = [
    ['exactly one origin URL',
      '$arrRemoteUrls = @(& $strGitPath remote get-url --all origin)\n' +
      'if ($LASTEXITCODE -ne 0 -or $arrRemoteUrls.Count -ne 1) {'],
    ['a credential-free GitHub HTTPS origin',
      "if ($arrRemoteUrls[0] -cne 'https://github.com/franklesniak/PSStyleGuide') {"],
    ['native-command error mapping is disabled',
      'if (Test-Path Variable:PSNativeCommandUseErrorActionPreference) {\n' +
      '    $PSNativeCommandUseErrorActionPreference = $false\n' +
      '}'],
    ['no local credential helper',
      '$arrHelpers = @(& $strGitPath config --local --get-all credential.helper)\n' +
      '$intHelperExit = $LASTEXITCODE\n' +
      '$global:LASTEXITCODE = 0\n' +
      'if (($intHelperExit -ne 0 -and $intHelperExit -ne 1) -or $arrHelpers.Count -ne 0)'],
    ['no persisted HTTP authorization',
      "$arrAuthorizationKeys = @(& $strGitPath config --local --name-only --get-regexp '^http\\..*\\.extraheader$')\n" +
      '$intAuthorizationExit = $LASTEXITCODE\n' +
      '$global:LASTEXITCODE = 0\n' +
      'if (($intAuthorizationExit -ne 0 -and $intAuthorizationExit -ne 1) -or $arrAuthorizationKeys.Count -ne 0)'],
  ];
  for (const [requirement, sequence] of requiredSequences) {
    if (!step.run.includes(sequence)) {
      reject('credential-policy', `${label} no longer asserts ${requirement}`);
    }
  }
  const normalizationCount = step.run.match(/^\$global:LASTEXITCODE = 0$/gmu)?.length ?? 0;
  if (normalizationCount !== 2) {
    reject('credential-policy', `${label} native-status normalization count changed`);
  }
  if (/\b(?:exit|return|break|continue|trap)\b/iu.test(step.run) || PROCESS_TERMINATION.test(step.run)) {
    reject('credential-policy', `${label} adds control flow that can bypass a required assertion`);
  }
  if (crypto.createHash('sha256').update(step.run, 'utf8').digest('hex') !== expectedDigest) {
    reject('credential-policy', `${label} script does not match its reviewed digest`);
  }
}

function validateMarkdownGovernedStep(step, label, expected) {
  assertKeys(step, ['name', 'id', 'shell', 'working-directory', 'run'], label);
  if (step.name !== expected.name || step.shell !== 'pwsh' || step['working-directory'] !== '.github/workflows') {
    reject('policy', `${label} execution context changed`);
  }
  const requiredFragments = [
    "-cne 'v24.18.1'",
    "-cne '11.16.0'",
    'if (Test-Path Variable:PSNativeCommandUseErrorActionPreference) {',
    'ci --ignore-scripts --no-audit --no-fund',
    'Get-FileHash -LiteralPath package.json -Algorithm SHA256',
    'Get-FileHash -LiteralPath package-lock.json -Algorithm SHA256',
    REVIEWED_PACKAGE_DIGESTS['package.json'].toUpperCase(),
    REVIEWED_PACKAGE_DIGESTS['package-lock.json'].toUpperCase(),
    'if ($strPackageBefore -cne $strReviewedPackageHash -or $strLockBefore -cne $strReviewedLockHash)',
    'supply: package metadata does not match the reviewed supply digest',
    'npm-ci: package metadata changed during frozen installation',
    "@('.npmrc', '../.npmrc', '../../.npmrc')",
    'supply: repository-controlled npm configuration is present',
    '$env:npm_config_userconfig =',
    '$env:npm_config_globalconfig =',
    "$env:npm_config_userconfig = '/dev/null'",
    "$env:npm_config_globalconfig = '/etc/npmrc-absent-by-policy'",
    'supply: the neutralized global npm configuration is not under a root-owned directory',
    'supply: the neutralized npm configuration source is not empty',
  ];
  for (const fragment of [...requiredFragments, ...expected.fragments]) {
    if (!step.run.includes(fragment)) reject('markdown-policy', `${label} is missing a required phase: ${fragment}`);
  }
  if (/^[ \t]*(?:exit|return|break|continue)\b|[;{][ \t]*(?:exit|return|break|continue)\b/imu.test(step.run)) {
    reject('markdown-policy', `${label} adds control flow that can bypass a required phase`);
  }
  if (PROCESS_TERMINATION.test(step.run)) {
    reject('markdown-policy', `${label} adds a process-termination path that can bypass a required phase`);
  }
  let cursor = -1;
  for (const phase of expected.phases) {
    const at = step.run.indexOf(phase, cursor + 1);
    if (at <= cursor) reject('markdown-policy', `${label} runs a required phase out of order: ${phase}`);
    cursor = at;
  }
  if (NETWORK_CLIENT.test(powerShellTokenView(step.run))) {
    reject('markdown-policy', `${label} adds a network client`);
  }
  const absenceGuard = "$env:GIT_CONFIG_NOSYSTEM = '1'\n$env:GIT_CONFIG_GLOBAL = '/dev/null'\n$env:GIT_TERMINAL_PROMPT = '0'\nif (-not [string]::IsNullOrEmpty($env:GITHUB_TOKEN) -or\n    -not [string]::IsNullOrEmpty($env:GH_TOKEN) -or\n    -not [string]::IsNullOrEmpty($env:ACTIONS_RUNTIME_TOKEN)) {\n    throw 'credential-policy: a token was projected into a code job'\n}\n";
  if (step.run.split(absenceGuard).length !== 2) reject('markdown-policy', `${label} lacks the fixed credential absence guard`);
  const serialized = JSON.stringify({ ...step, run: step.run.replace(absenceGuard, '') });
  if (/secrets\./iu.test(serialized) ||
      /GITHUB_TOKEN/iu.test(serialized) ||
      /github\.token/iu.test(serialized)) {
    reject('markdown-policy', `${label} expands an unapproved credential`);
  }
  if (/\$\{\{/u.test(serialized)) {
    reject('markdown-policy', `${label} contains a workflow expression`);
  }
  if (/@['"]|<#/u.test(step.run)) {
    reject('markdown-policy', `${label} uses a here-string or block comment`);
  }
  let catchView = step.run;
  const fixedCatches = ["try { $objPreflight = $arrPreflight[0] | ConvertFrom-Json -NoEnumerate -ErrorAction Stop }\ncatch { throw 'workflow-policy: invalid preflight JSON' }","try { $objPolicy = $arrPolicy[0] | ConvertFrom-Json -NoEnumerate -ErrorAction Stop }\ncatch { throw 'workflow-policy: invalid policy JSON' }"];
  if (expected.stepId === 'validate') {
    for (const fixed of fixedCatches) {
      if (catchView.split(fixed).length !== 2) reject('markdown-policy', `${label} changes a fixed result conversion guard`);
      catchView = catchView.replace(fixed, '');
    }
  }
  if (/\b(?:catch|trap)\b/iu.test(powerShellCodeProjection(catchView))) {
    reject('markdown-policy', `${label} can suppress a phase failure`);
  }
  if (/[^\t\n\x20-\x7e]/u.test(step.run)) {
    reject('markdown-policy', `${label} contains a character outside printable ASCII`);
  }
  if (/--%/u.test(step.run)) {
    reject('markdown-policy', `${label} uses the stop-parsing token`);
  }
  for (const objMatch of powerShellCodeProjection(step.run).matchAll(QUALIFIED_ASSIGNMENT)) {
    const strTarget = objMatch[1] ?? objMatch[2];
    if (!strTarget.startsWith('env:')) {
      reject('markdown-policy', `${label} writes an unreviewed qualified variable: ${strTarget}`);
    }
  }
  for (const strName of expected.capturedStatuses) {
    const arrAssignments = normalizeLineContinuations(step.run).match(variableWritePattern(strName)) ?? [];
    if (arrAssignments.length !== 1) {
      reject('markdown-policy', `${label} captured phase status ${strName} is not assigned exactly once`);
    }
    if (!step.run.includes(`$${strName} = $LASTEXITCODE`)) {
      reject('markdown-policy', `${label} captured phase status ${strName} is not taken from $LASTEXITCODE`);
    }
  }
}

function assertMarkdownStepInvocations(step, label, expected) {
  const projected = powerShellCodeProjection(step.run).split('\n');
  const raw = step.run.split('\n');
  const observed = [];
  for (let index = 0; index < projected.length; index += 1) {
    if (invocationOperatorOffset(projected[index]) >= 0) observed.push(raw[index].trim());
  }
  const remaining = [...expected.invocations];
  for (const invocation of observed) {
    const at = remaining.indexOf(invocation);
    if (at < 0) {
      const known = expected.invocations.includes(invocation);
      reject('markdown-policy', known
        ? `${label} repeats a reviewed invocation: ${invocation}`
        : `${label} makes an unreviewed invocation: ${invocation}`);
    }
    remaining.splice(at, 1);
  }
  if (remaining.length !== 0) {
    reject('markdown-policy', `${label} no longer makes a reviewed invocation: ${remaining[0]}`);
  }
}

function assertMarkdownStepSurface(step, label, expected) {
  const stepCode = powerShellCodeProjection(step.run);
  for (const command of stepCode.matchAll(MARKDOWN_COMMAND_POSITION)) {
    const token = command[1];
    if (MARKDOWN_STEP_KEYWORDS.includes(token)) continue;
    if (MARKDOWN_STEP_COMMANDS.includes(token)) continue;
    reject('markdown-policy', `${label} runs an unreviewed bare command: ${token}`);
  }
  for (const write of stepCode.matchAll(MARKDOWN_ENV_WRITE)) {
    if (!expected.envWrites.includes(write[1])) {
      reject('markdown-policy', `${label} assigns an unreviewed environment variable: ${write[1]}`);
    }
  }
  const arrGates = expected.stepId === 'lint'
    ? [...REVIEWED_MARKDOWN_GATES, ...REVIEWED_LINT_GATES]
    : REVIEWED_MARKDOWN_GATES;
  assertReviewedGuards(stepCode, arrGates, 'markdown-policy', (kind, frag) => kind === 'missing'
    ? `${label} no longer performs a reviewed supply gate: ${frag}`
    : `${label} supply gate is no longer reachable where it was reviewed: ${frag}`);
  if (MARKDOWN_DYNAMIC_EXECUTION.test(stepCode)) {
    reject('markdown-policy', `${label} adds a dynamic or indirect execution path`);
  }
  if (/GetEnvironmentVariable|SetEnvironmentVariable/iu.test(stepCode)) {
    reject('markdown-policy', `${label} resolves an environment variable through a computed name`);
  }
  let staticCode = stepCode;
  const typeGuards = ["$objPreflight.GetType() -ne [System.Management.Automation.PSCustomObject]","$objPolicy.GetType() -ne [System.Management.Automation.PSCustomObject]"];
  if (expected.stepId === 'validate') {
    for (const guard of typeGuards) {
      if (staticCode.split(guard).length !== 2) reject('markdown-policy', `${label} changes a fixed result object-type guard`);
      staticCode = staticCode.replace(guard, '$false');
    }
  }
  assertLiteralStaticCalls(staticCode, 'markdown-policy', label);
}

function validateIsolationSemantics(fileName, workflow, contract) {
  if (fileName !== 'build.yml' && fileName !== 'markdownlint.yml') return;
  const policy = contract.workflowPolicy.workflows[fileName];
  const ids = fileName === 'build.yml' ? ['verify_generated_artifacts'] : ['policy', 'markdownlint'];
  for (const id of ids) {
    const job = workflow.jobs[id];
    const label = (fileName === 'build.yml' ? 'build.' : 'markdown.') + id;
    const expected = { ...(fileName === 'build.yml' ? BUILD_ACQUIRE : MARKDOWN_ACQUIRE), digest: policy.jobs[id].steps[0].runSha256 };
    validateAcquireStep(job.steps[0], label + '.acquire', expected);
    validateCredentialCleanupStep(job.steps[1], label + '.verify-checkout-credentials', policy.jobs[id].steps[1].runSha256);
  }
  if (fileName === 'build.yml') {
    validateBuildCodePolicy(workflow.jobs.verify_generated_artifacts.steps[2], contract);
    return;
  }
  const governed = Object.fromEntries(ids.map(id => [id, workflow.jobs[id].steps[2]]));
  for (const id of ids) validateMarkdownGovernedStep(governed[id], 'markdown.' + id + '.' + MARKDOWN_JOBS[id].stepId, MARKDOWN_JOBS[id]);
  const preludeOf = (step, label) => {
    const at = step.run.indexOf(MARKDOWN_PRELUDE_END);
    if (at < 0 || step.run.indexOf(MARKDOWN_PRELUDE_END, at + 1) >= 0) reject('markdown-policy', label + ' does not close its supply prelude exactly once');
    return step.run.slice(0, at + MARKDOWN_PRELUDE_END.length);
  };
  if (preludeOf(governed.policy, 'markdown.policy.validate') !== preludeOf(governed.markdownlint, 'markdown.markdownlint.lint')) reject('markdown-policy', 'the two governed steps do not share one byte-identical supply prelude');
  if (governed.markdownlint.run.includes('Validate-WorkflowPolicy.mjs')) reject('markdown-policy', 'markdown.markdownlint.lint invokes the policy validator');
  if (/run lint:md/u.test(governed.policy.run)) reject('markdown-policy', 'markdown.policy.validate runs a lint phase');
  for (const id of ids) assertMarkdownStepInvocations(governed[id], 'markdown.' + id + '.' + MARKDOWN_JOBS[id].stepId, MARKDOWN_JOBS[id]);
  for (const id of ids) assertMarkdownStepSurface(governed[id], 'markdown.' + id + '.' + MARKDOWN_JOBS[id].stepId, MARKDOWN_JOBS[id]);
}

// Build code-job invariants adapted from the pinned TF source; PS-specific surfaces are closed, not generally exempted.
const REVIEWED_VERIFY_GUARDS = Object.freeze([
  [
    "if ($arrOutside.Count -ne 0) {",
    [
      1
    ]
  ],
  [
    "$arrArtifacts -cnotcontains $_",
    [
      2
    ]
  ],
  [
    "Sort-Object -CaseSensitive",
    [
      1,
      2,
      1
    ]
  ],
  [
    "if ($objDiff.ExitCode -ne 0 -and $objDiff.ExitCode -ne 1) {",
    [
      0
    ]
  ],
  [
    "if ($listObservedPaths -ccontains $strPath) { throw ",
    [
      2
    ]
  ],
  [
    "if ($AllowedPaths -cnotcontains $strPath) { throw ",
    [
      2
    ]
  ],
  [
    "if ([Convert]::ToBase64String($arrRecord) -cne [Convert]::ToBase64String($arrRoundTrip)) {",
    [
      2
    ]
  ],
  [
    "if ((Get-GitControlSurfaceDigest) -cne $strControlSurfaceBefore) {",
    [
      0
    ]
  ],
  [
    "if ((-not $objWorktreeAfter.ContainsKey($strPath)) -or ($objWorktreeAfter[$strPath] -cne $objWorktreeBefore[$strPath])) {",
    [
      1
    ]
  ]
]);

const REVIEWED_VERIFY_SINGLE_ASSIGNMENT = Object.freeze([
  "arrArtifacts",
  "arrOutside",
  "arrRecord",
  "arrRoundTrip",
  "listChanged",
  "objDiff",
  "objWorktreeAfter",
  "objWorktreeBefore",
  "strControlSurfaceBefore",
  "listFailedChecks",
  "strVerifierCommand",
  "strEncodedVerifierCommand",
  "arrPathSetResult",
  "intPathSetExit",
  "objPathSetResult"
]);

const REVIEWED_VERIFY_MEMBER_ACCESS = Object.freeze({
  "arrArtifacts": {},
  "arrOutside": {
    ".Count": 2
  },
  "arrRecord": {
    ".Length": 1
  },
  "arrRoundTrip": {},
  "listChanged": {
    ".Add": 2,
    ".Count": 1
  },
  "objDiff": {
    ".ExitCode": 4
  },
  "objWorktreeAfter": {
    ".ContainsKey": 1,
    "[": 1,
    ".Keys": 1
  },
  "objWorktreeBefore": {
    ".Keys": 1,
    "[": 1,
    ".ContainsKey": 1
  },
  "strControlSurfaceBefore": {},
  "strPowerShellPath": {},
  "strVerifierCommand": {},
  "strEncodedVerifierCommand": {},
  "arrPathSetResult": {
    ".Count": 1,
    "[": 1
  },
  "intPathSetExit": {},
  "objPathSetResult": {
    ".GetType": 1,
    ".Schema": 2,
    ".VerifierVersion": 2,
    ".Success": 2
  },
  "arrResult": {
    ".Count": 1,
    "[": 1
  },
  "objResult": {
    ".GetType": 1,
    ".Schema": 2,
    ".GeneratorVersion": 2,
    ".Overall": 2,
    ".Phase": 2,
    ".Category": 2,
    ".NativeOutcome": 2,
    ".ExitCode": 3,
    ".Artifacts": 2
  },
  "intGeneratorExit": {},
  "listFailedChecks": {
    ".Add": 8,
    ".Count": 1
  }
});

const REVIEWED_VERIFY_OCCURRENCES = Object.freeze({
  "arrArtifacts": 4,
  "arrOutside": 3,
  "arrRecord": 7,
  "arrRoundTrip": 2,
  "listChanged": 5,
  "objDiff": 5,
  "objWorktreeAfter": 4,
  "objWorktreeBefore": 4,
  "strControlSurfaceBefore": 2,
  "strPowerShellPath": 6,
  "strVerifierCommand": 2,
  "strEncodedVerifierCommand": 2,
  "arrPathSetResult": 3,
  "intPathSetExit": 3,
  "objPathSetResult": 9,
  "arrResult": 3,
  "objResult": 20,
  "intGeneratorExit": 3,
  "listFailedChecks": 11
});

const REVIEWED_VERIFY_INVOCATIONS = Object.freeze([
  [
    "$arrResult = @(& $strPowerShellPath  -NoLogo  -NoProfile  -NonInteractive  -File './.github/workflows/Generate-StyleGuideArtifacts.ps1')",
    0
  ],
  [
    "$arrPathSetResult = @(& $strPowerShellPath -NoLogo -NoProfile -NonInteractive -EncodedCommand $strEncodedVerifierCommand)",
    0
  ]
]);

const REVIEWED_VERIFY_STATIC_CALLS = Object.freeze([
  "Convert::ToBase64String",
  "System.Array::Copy",
  "System.Array::Reverse",
  "System.BitConverter::GetBytes",
  "System.BitConverter::IsLittleEndian",
  "System.Collections.Generic.List[byte[]]::new",
  "System.Collections.Generic.List[string]::new",
  "System.Collections.Generic.SortedDictionary[string, string]::new",
  "System.Collections.Generic.Stack[string]::new",
  "System.Convert::ToBase64String",
  "System.Diagnostics.Process::GetCurrentProcess",
  "System.Diagnostics.Process::new",
  "System.Diagnostics.ProcessStartInfo::new",
  "System.IO.Directory::EnumerateFileSystemEntries",
  "System.IO.Directory::Exists",
  "System.IO.Directory::GetFiles",
  "System.IO.File::Exists",
  "System.IO.File::GetAttributes",
  "System.IO.File::OpenRead",
  "System.IO.File::ReadAllBytes",
  "System.IO.FileAttributes::Directory",
  "System.IO.FileAttributes::ReparsePoint",
  "System.IO.FileInfo::new",
  "System.IO.MemoryStream::new",
  "System.IO.Path::Combine",
  "System.IO.Path::DirectorySeparatorChar",
  "System.IO.Path::GetFileName",
  "System.Security.Cryptography.SHA256::Create",
  "System.StringComparer::Ordinal",
  "System.Text.Encoding::UTF8",
  "System.Text.Encoding::Unicode",
  "System.Text.UTF8Encoding::new",
  "byte[]::new",
  "string::IsNullOrEmpty"
]);

const REVIEWED_VERIFY_COMMANDS = Object.freeze([
  "Assert-AllowedPathSet",
  "Bytes",
  "ConvertFrom-Json",
  "ConvertFrom-NulPathRecordStream",
  "Error",
  "ExitCode",
  "Get-GitControlSurfaceDigest",
  "Get-WorktreeFileDigestMap",
  "Invoke-GitRaw",
  "New-Variable",
  "Select-Object",
  "Sort-Object",
  "Test-Path",
  "Where-Object",
  "Write-Information",
  "catch",
  "else",
  "finally",
  "for",
  "foreach",
  "function",
  "if",
  "param",
  "return",
  "string]]::new",
  "throw",
  "try",
  "while"
]);

const REVIEWED_VERIFY_NEW_VARIABLE = Object.freeze([
  "New-Variable -Name strGitPath -Value $strResolvedGit -Option Constant",
  "New-Variable -Name arrChannelPaths -Value @($env:GITHUB_ENV, $env:GITHUB_PATH, $env:GITHUB_OUTPUT, $env:GITHUB_STEP_SUMMARY) -Option Constant"
]);

const GENERATOR_COMMAND_POSITION = /(?:^[ \t]*|(?<!\$)\{[ \t]*|[;}|=(,][ \t]*|&&[ \t]*|\|\|[ \t]*)([A-Za-z_][^\s;{}()]*)/gmu;

const REVIEWED_VERIFY_HELP = Object.freeze({
  'Invoke-GitRaw': Object.freeze(['GitArguments']),
  'ConvertFrom-NulPathRecordStream': Object.freeze(['PathRecordBytes']),
  'Assert-AllowedPathSet': Object.freeze(['PathRecords', 'AllowedPaths', 'SurfaceName']),
  'Get-GitControlSurfaceDigest': Object.freeze([]),
  'Get-WorktreeFileDigestMap': Object.freeze([]),
});

function variableReferencePattern(strName) {
  return new RegExp(
    `\\$(?:\\{(?:[A-Za-z_][A-Za-z0-9_]*:)?${strName}\\}` +
    `|(?:[A-Za-z_][A-Za-z0-9_]*:)?${strName}(?![A-Za-z0-9_]))`,
    'giu');
}

function assertReviewedInvocations(strRaw, strCode, arrReviewed, strCategory, strLabel) {
  const arrProjected = strCode.split('\n');
  const arrRawLines = normalizeLineContinuations(strRaw).split('\n');
  const arrObserved = [];
  let intLineStart = 0;
  for (let intIndex = 0; intIndex < arrProjected.length; intIndex += 1) {
    const intAt = invocationOperatorOffset(arrProjected[intIndex]);
    if (intAt >= 0) {
      arrObserved.push([(arrRawLines[intIndex] ?? '').trim(), powerShellBraceDepthAt(strCode, intLineStart + intAt)]);
    }
    intLineStart += arrProjected[intIndex].length + 1;
  }
  if (arrObserved.length !== arrReviewed.length) {
    reject(strCategory, `${strLabel} does not invoke exactly where it was reviewed to`);
  }
  for (let intIndex = 0; intIndex < arrReviewed.length; intIndex += 1) {
    const [strReviewedLine, intReviewedDepth] = arrReviewed[intIndex];
    const [strObservedLine, intObservedDepth] = arrObserved[intIndex];
    if (strObservedLine !== strReviewedLine) {
      reject(strCategory, `${strLabel} makes an unreviewed invocation: ${strObservedLine}`);
    }
    if (intObservedDepth !== intReviewedDepth) {
      reject(strCategory, `a reviewed invocation is no longer reachable where it was reviewed: ${strReviewedLine}`);
    }
  }
}

function powerShellTopLevelFunctions(source) {
  const matches = [...source.matchAll(/^[ \t]*function[ \t]+([A-Za-z][A-Za-z0-9-]*)[ \t]*\{/gmu)];
  return matches.map((match, index) => Object.freeze({
    name: match[1],
    body: source.slice(match.index + match[0].length, matches[index + 1]?.index ?? source.length),
  }));
}

function assertPowerShellPrivateHelperHelp(source, reviewed, version, category, label) {
  const functions = powerShellTopLevelFunctions(source);
  const observedNames = functions.map((entry) => entry.name);
  const reviewedNames = Object.keys(reviewed);
  if (JSON.stringify(observedNames) !== JSON.stringify(reviewedNames)) {
    reject(category, `${label} helper names differ from the reviewed authoring contract`);
  }

  for (const entry of functions) {
    const helpMatch = entry.body.match(/^\n((?:(?:[ \t]*#[^\n]*|[ \t]*)\n)+)/u);
    if (helpMatch === null) {
      reject(category, `${label} helper ${entry.name} does not contain complete single-line comment-based help`);
    }
    const sections = [];
    let current = null;
    for (const line of helpMatch[1].split('\n')) {
      const keyword = line.match(/^[ \t]*# \.([A-Z]+)(?:[ \t]+([A-Za-z][A-Za-z0-9]*))?[ \t]*$/u);
      if (keyword !== null) {
        current = { keyword: keyword[1], name: keyword[2] ?? null, content: [] };
        sections.push(current);
        continue;
      }
      if (current !== null) {
        const content = line.match(/^[ \t]*#(?:[ \t](.*))?$/u);
        if (content !== null && (content[1] ?? '').trim() !== '') {
          current.content.push(content[1].trim());
        }
      }
    }

    const parameters = reviewed[entry.name];
    const reviewedKeywords = [
      'SYNOPSIS', 'DESCRIPTION',
      ...parameters.map(() => 'PARAMETER'),
      'EXAMPLE', 'EXAMPLE', 'INPUTS', 'OUTPUTS', 'NOTES',
    ];
    if (JSON.stringify(sections.map((section) => section.keyword)) !== JSON.stringify(reviewedKeywords) ||
        sections.some((section) => section.content.length === 0)) {
      reject(category, `${label} helper ${entry.name} does not contain complete single-line comment-based help`);
    }
    const observedParameters = sections
      .filter((section) => section.keyword === 'PARAMETER')
      .map((section) => section.name);
    if (JSON.stringify(observedParameters) !== JSON.stringify(parameters)) {
      reject(category, `${label} helper ${entry.name} parameter help differs from the reviewed contract`);
    }

    const notes = sections.find((section) => section.keyword === 'NOTES').content;
    const notesText = notes.join(' ');
    if (notes[0] !== 'PRIVATE/INTERNAL HELPER - This function is not part of the public API' ||
        !notesText.includes('Parameters, return shape, and positional contract may change without notice.') ||
        !notesText.includes(`Version: ${typeof version === 'string' ? version : version[entry.name]}`)) {
      reject(category, `${label} helper ${entry.name} private notes differ from the reviewed contract`);
    }
    if (parameters.length === 0) {
      if (!notesText.includes('This function declares no parameters.')) {
        reject(category, `${label} helper ${entry.name} positional notes differ from the reviewed contract`);
      }
    } else {
      for (let index = 0; index < parameters.length; index += 1) {
        if (!notesText.includes(`Position ${index}: ${parameters[index]}`)) {
          reject(category, `${label} helper ${entry.name} positional notes differ from the reviewed contract`);
        }
      }
    }

    const afterHelp = entry.body.slice(helpMatch[0].length);
    const singleLineAttribute = '[ \\t]*\\[[^\\n]+\\]\\n';
    const suppressionAttribute = (
      '[ \\t]*\\[System\\.Diagnostics\\.CodeAnalysis\\.SuppressMessageAttribute\\(\\n' +
      '(?:[^\\n]*\\n)*?[ \\t]*\\)\\]\\n'
    );
    const parameterBlock = new RegExp(
      `^(?:(?:${singleLineAttribute})|(?:${suppressionAttribute}))*[ \\t]*param[ \\t]*\\(`,
      'u',
    );
    if (!parameterBlock.test(afterHelp)) {
      reject(category, `${label} helper ${entry.name} help is not immediately above its parameter block`);
    }
  }
}


function validateBuildCodePolicy(generateStep, contract) {
  for (const { jobId, id, run, step } of [{ jobId: 'verify_generated_artifacts', id: generateStep.id, run: generateStep.run, step: generateStep }]) {
    if ('continue-on-error' in step) reject('failure-policy', `${jobId}.${id} sets continue-on-error`);
    if (NETWORK_CLIENT.test(powerShellTokenView(run))) {
      reject('network-policy', `${jobId}.${id} adds a network client`);
    }
    const absence = "$env:GIT_CONFIG_NOSYSTEM = '1'\n$env:GIT_CONFIG_GLOBAL = '/dev/null'\n$env:GIT_TERMINAL_PROMPT = '0'\nif (-not [string]::IsNullOrEmpty($env:GITHUB_TOKEN) -or\n    -not [string]::IsNullOrEmpty($env:GH_TOKEN) -or\n    -not [string]::IsNullOrEmpty($env:ACTIONS_RUNTIME_TOKEN)) {\n    throw 'credential-policy: a token was projected into a code job'\n}\n";
    if (run.split(absence).length !== 2) reject('credential-policy', 'build.verify lacks the fixed credential absence guard');
    const serialized = JSON.stringify({ ...step, run: run.replace(absence, '') });
    if (/secrets\./iu.test(serialized) || /GITHUB_TOKEN/iu.test(serialized) || /github\.token/iu.test(serialized)) {
      reject('credential-policy', `${jobId}.${id} expands an unapproved credential`);
    }
    if (/\$\{\{/u.test(serialized)) {
      reject('credential-policy', `${jobId}.${id} contains a workflow expression`);
    }
    if (/@['"]|<#/u.test(run)) {
      reject('side-effect-policy', `${jobId}.${id} uses a here-string or block comment`);
    }
    if (/\btrap\b/iu.test(run)) {
      reject('side-effect-policy', `${jobId}.${id} registers a script-wide error trap`);
    }
    if (/[^\t\n\x20-\x7e]/u.test(run)) {
      reject('side-effect-policy', `${jobId}.${id} contains a character outside printable ASCII`);
    }
    if (/--%/u.test(run)) {
      reject('side-effect-policy', `${jobId}.${id} uses the stop-parsing token`);
    }
    if (/ArgumentList\.Add\(['"]push['"]\)|\bgit\s+push\b/iu.test(run)) {
      reject('side-effect-policy', `${jobId}.${id} adds a push path to a read-only workflow`);
    }
    if (/\bgit\s+(?:add|commit)\b/iu.test(run)) {
      reject('side-effect-policy', `${jobId}.${id} adds a repository mutation to a read-only workflow`);
    }
  }

  if (/^\s*& \.\/\.github\/workflows\/Generate-StyleGuideArtifacts\.ps1\s*$/mu.test(generateStep.run)) {
    reject('side-effect-policy', 'the generator is invoked in-session');
  }
  const generatorStatement = new RegExp("^\\$arrResult = @\\(& \\$strPowerShellPath `\n    -NoLogo `\n    -NoProfile `\n    -NonInteractive `\n    -File '\\./\\.github/workflows/Generate-StyleGuideArtifacts\\.ps1'\\)$", 'gmu');
  if ((generateStep.run.match(generatorStatement) ?? []).length !== 1) {
    reject('side-effect-policy', 'the generator is not invoked exactly once as a statement');
  }
  const generatorIndex = generateStep.run.search(generatorStatement);
  const afterGenerator = generateStep.run.slice(generatorIndex);
  const verifierRegion = "$strVerifierCommand = '& ''./.github/workflows/Test-ExactGitPathSet.ps1'' -RepositoryRoot $env:GITHUB_WORKSPACE -GitExecutablePath ''/usr/bin/git'' -ExpectedPath @() -Mode Both -RequireCleanWorkingAgainstIndex'\n$strEncodedVerifierCommand = [System.Convert]::ToBase64String(\n    [System.Text.Encoding]::Unicode.GetBytes($strVerifierCommand)\n)\n$arrPathSetResult = @(& $strPowerShellPath -NoLogo -NoProfile -NonInteractive -EncodedCommand $strEncodedVerifierCommand)";
  if (generateStep.run.split(verifierRegion).length !== 2) reject('side-effect-policy', 'build.verify changes the fixed exact-path verifier process');
  const verifierResultContract = "$intPathSetExit = $LASTEXITCODE\nif ($arrPathSetResult.Count -ne 1) { throw 'Exact-path verification returned an invalid shape.' }\ntry { $objPathSetResult = $arrPathSetResult[0] | ConvertFrom-Json -NoEnumerate -ErrorAction Stop }\ncatch { throw 'Exact-path verification returned invalid JSON.' }\nif ($null -eq $objPathSetResult -or $objPathSetResult.GetType() -ne [System.Management.Automation.PSCustomObject] -or\n    $intPathSetExit -isnot [int] -or $intPathSetExit -ne 0 -or\n    $objPathSetResult.Schema -isnot [string] -or $objPathSetResult.Schema -cne 'PSStyleGuide.ExactGitPathSetResult.v2' -or\n    $objPathSetResult.VerifierVersion -isnot [string] -or $objPathSetResult.VerifierVersion -cne '1.0.20260818.6' -or\n    $objPathSetResult.Success -isnot [bool] -or -not $objPathSetResult.Success) {\n    throw 'Exact-path verification did not confirm a clean worktree and index.'\n}";
  if (!generateStep.run.includes(verifierRegion + '\n' + verifierResultContract)) reject('side-effect-policy', 'build.verify changes the exact-path verifier result contract');
  const verifierIndex = generateStep.run.indexOf(verifierRegion);
  if (verifierIndex < generatorIndex || powerShellBraceDepthAt(generateStep.run, verifierIndex) !== 0) reject('side-effect-policy', 'build.verify nests or reorders the exact-path verifier');
  for (const terminal of ['if ((Get-GitControlSurfaceDigest)', 'foreach ($strChannel in $arrChannelPaths)', '$objWorktreeAfter = Get-WorktreeFileDigestMap']) {
    if (generateStep.run.lastIndexOf(terminal) < verifierIndex) reject('side-effect-policy', 'build.verify performs a terminal check before the exact-path verifier');
  }
  if (powerShellBraceDepthAt(generateStep.run, generatorIndex) !== 0) {
    reject('side-effect-policy', 'the generator invocation is nested inside a block');
  }
  if (!generateStep.run.includes("@('/usr/bin/git', '/bin/git')") ||
      !generateStep.run.includes('New-Variable -Name strGitPath -Value $strResolvedGit -Option Constant') ||
      !generateStep.run.includes('$objStartInfo.FileName = $strGitPath')) {
    reject('git-policy', 'build.verify does not pin the Git executable before repository code runs');
  }
  if (/Get-Command/u.test(generateStep.run)) {
    reject('git-policy', 'build.verify resolves Git through a shadowable command lookup');
  }
  if (generateStep.run.indexOf('New-Variable -Name strGitPath') > generatorIndex) {
    reject('git-policy', 'build.verify resolves Git after the generator runs');
  }
  if (!generateStep.run.includes('function Get-GitControlSurfaceDigest') ||
      !generateStep.run.includes('$strControlSurfaceBefore = Get-GitControlSurfaceDigest') ||
      !generateStep.run.includes('git-state: the generator changed repository Git configuration or hooks') ||
      generateStep.run.indexOf('$strControlSurfaceBefore = Get-GitControlSurfaceDigest') > generatorIndex ||
      generateStep.run.indexOf('git-state: the generator changed repository Git configuration or hooks') < generatorIndex) {
    reject('git-policy', 'build.verify does not bracket the generator with a Git control-surface digest');
  }
  if (!generateStep.run.includes('function Get-WorktreeFileDigestMap') ||
      !generateStep.run.includes('$objWorktreeBefore = Get-WorktreeFileDigestMap') ||
      !generateStep.run.includes('$objWorktreeAfter = Get-WorktreeFileDigestMap') ||
      !generateStep.run.includes('generated-artifacts: committed artifacts do not match generator output') ||
      !generateStep.run.includes('outside the four generated artifacts') ||
      generateStep.run.indexOf('$objWorktreeBefore = Get-WorktreeFileDigestMap') > generatorIndex ||
      generateStep.run.indexOf('$objWorktreeAfter = Get-WorktreeFileDigestMap') < generatorIndex) {
    reject('side-effect-policy', 'build.verify does not bracket the generator with a worktree byte comparison');
  }
  if (!generateStep.run.includes('[System.IO.Directory]::EnumerateFileSystemEntries($objPending.Pop())') ||
      generateStep.run.includes('[System.IO.SearchOption]::AllDirectories') ||
      !generateStep.run.includes("throw 'worktree: the working tree contains a link'") ||
      !generateStep.run.includes('[System.IO.FileAttributes]::ReparsePoint') ||
      !generateStep.run.includes('$objSha.ComputeHash($objStream)') ||
      generateStep.run.includes('[System.IO.File]::ReadAllBytes($strEntry)')) {
    reject('side-effect-policy', 'build.verify worktree walk can follow a link or read a file whole');
  }
  if (!generateStep.run.includes('$objFile.Length -eq 0') ||
      !generateStep.run.includes('if ($strEntry -cne $strGitDirectory) { $objPending.Push($strEntry) }') ||
      generateStep.run.includes('$strGitPrefix')) {
    reject('side-effect-policy', 'build.verify worktree walk lost its FIFO guard or its exact .git exclusion');
  }
  if (!generateStep.run.includes('$listComponents = [System.Collections.Generic.List[byte[]]]::new()') ||
      !generateStep.run.includes('$arrLength = [System.BitConverter]::GetBytes([long]$arrComponent.Length)') ||
      !generateStep.run.includes('$arrCount = [System.BitConverter]::GetBytes([long]$listComponents.Count)')) {
    reject('git-policy', 'the Git control-surface digest does not frame its components unambiguously');
  }
  if (!generateStep.run.includes('New-Variable -Name arrChannelPaths -Value @($env:GITHUB_ENV, $env:GITHUB_PATH, $env:GITHUB_OUTPUT, $env:GITHUB_STEP_SUMMARY) -Option Constant') ||
      !generateStep.run.includes('runner-state: the generator wrote to a runner step communication file') ||
      generateStep.run.indexOf('New-Variable -Name arrChannelPaths') > generatorIndex ||
      generateStep.run.indexOf('runner-state: the generator wrote to a runner step communication file') < generatorIndex) {
    reject('side-effect-policy', 'build.verify does not assert the runner step communication files are empty');
  }
  if (!generateStep.run.includes("$objStartInfo.Environment['GIT_CONFIG_GLOBAL'] = '/dev/null'") ||
      !generateStep.run.includes("$objStartInfo.Environment['GIT_CONFIG_NOSYSTEM'] = '1'")) {
    reject('git-policy', 'build.verify probes inherit system or global Git configuration');
  }
  if (!generateStep.run.includes('if ($objDiff.ExitCode -eq 1) {') ||
      !generateStep.run.includes('generated-artifacts: committed artifacts do not match generator output')) {
    reject('side-effect-policy', 'build.verify tolerates generated-artifact drift');
  }
  const strVerifyCode = powerShellTokenView(normalizeLineContinuations(generateStep.run));
  const processResolution = "try {\n    $strPowerShellPath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName\n} catch {\n    # Any MainModule resolution failure falls through to the deterministic guard below.\n    $strPowerShellPath = $null\n}\nif ([string]::IsNullOrEmpty($strPowerShellPath) -or\n    -not [System.IO.File]::Exists($strPowerShellPath)) {\n    throw 'The current PowerShell executable could not be resolved.'\n}";
  const resolutionIndex = generateStep.run.indexOf(processResolution);
  if (generateStep.run.split(processResolution).length !== 2 || resolutionIndex >= generatorIndex || powerShellBraceDepthAt(generateStep.run, resolutionIndex) !== 0 || (strVerifyCode.match(variableWritePattern('strPowerShellPath')) ?? []).length !== 2) reject('side-effect-policy', 'build.verify changes the fixed current-process executable resolution');
  validateGeneratorResultPolicy(generateStep.run, contract);
  assertReviewedGuards(strVerifyCode, REVIEWED_VERIFY_GUARDS, 'side-effect-policy', (kind, frag) => kind === 'missing'
    ? `build.verify no longer performs a reviewed drift guard: ${frag}`
    : `a reviewed drift guard is no longer reachable where it was reviewed: ${frag}`);
  for (const strName of REVIEWED_VERIFY_SINGLE_ASSIGNMENT) {
    const arrWrites = strVerifyCode.match(variableWritePattern(strName)) ?? [];
    if (arrWrites.length !== 1) {
      reject('side-effect-policy', `build.verify does not assign $${strName} exactly once`);
    }
  }
  for (const [strName, objReviewed] of Object.entries(REVIEWED_VERIFY_MEMBER_ACCESS)) {
    const objObserved = new Map();
    const objPattern = new RegExp(`\\$(?:\\{(?:[A-Za-z_][A-Za-z0-9_]*:)?${strName}\\}|(?:[A-Za-z_][A-Za-z0-9_]*:)?${strName}(?![A-Za-z0-9_]))[ \\t]*(\\.[A-Za-z_][A-Za-z0-9_]*|\\[)`, 'giu');
    for (const objMatch of strVerifyCode.matchAll(objPattern)) {
      const strMember = objMatch[1] === '[' ? '[' : objMatch[1];
      objObserved.set(strMember, (objObserved.get(strMember) ?? 0) + 1);
    }
    for (const [strMember, intCount] of objObserved) {
      if (objReviewed[strMember] === undefined) {
        reject('side-effect-policy', `build.verify makes an unreviewed use of $${strName}: ${strMember}`);
      }
      if (objReviewed[strMember] !== intCount) {
        reject('side-effect-policy', `build.verify uses $${strName}${strMember} ${intCount} times rather than the reviewed ${objReviewed[strMember]}`);
      }
    }
    for (const [strMember, intCount] of Object.entries(objReviewed)) {
      if ((objObserved.get(strMember) ?? 0) !== intCount) {
        reject('side-effect-policy', `build.verify no longer uses $${strName}${strMember} as reviewed`);
      }
    }
  }
  if (/^[ \t]*(?:exit|break|continue)\b|[;{][ \t]*(?:exit|break|continue)\b/imu.test(generateStep.run)) {
    reject('side-effect-policy', 'build.verify adds control flow that can bypass a required probe');
  }
  if (PROCESS_TERMINATION.test(generateStep.run)) {
    reject('side-effect-policy', 'build.verify adds a process-termination path that can bypass a required probe');
  }
  let staticCode = strVerifyCode;
  for (const guard of [
  "$objResult.GetType() -ne [System.Management.Automation.PSCustomObject]",
  "$objPathSetResult.GetType() -ne [System.Management.Automation.PSCustomObject]"
]) {
    if (staticCode.split(guard).length !== 2) reject('side-effect-policy', 'build.verify changes a fixed result object-type guard');
    staticCode = staticCode.replace(guard, '$false');
  }
  staticCode = staticCode.replaceAll('[void]($listFailedChecks.Add(', '($listFailedChecks.Add(');
  for (const objCall of assertLiteralStaticCalls(staticCode, 'side-effect-policy', 'build.verify')) {
    if (!REVIEWED_VERIFY_STATIC_CALLS.includes(`${objCall[1]}::${objCall[2]}`)) {
      reject('side-effect-policy', `build.verify makes an unreviewed static call: ${objCall[1]}::${objCall[2]}`);
    }
  }
  for (const [strName, intReviewed] of Object.entries(REVIEWED_VERIFY_OCCURRENCES)) {
    const intObserved = (strVerifyCode.match(variableReferencePattern(strName)) ?? []).length;
    if (intObserved !== intReviewed) {
      reject('side-effect-policy', `build.verify refers to $${strName} ${intObserved} times rather than the reviewed ${intReviewed}`);
    }
  }
  assertReviewedInvocations(generateStep.run, strVerifyCode, REVIEWED_VERIFY_INVOCATIONS,
    'side-effect-policy', 'build.verify');
  for (const objToken of strVerifyCode.matchAll(GENERATOR_COMMAND_POSITION)) {
    if (!REVIEWED_VERIFY_COMMANDS.includes(objToken[1])) {
      reject('side-effect-policy', `build.verify runs an unreviewed command: ${objToken[1]}`);
    }
  }
  const fnCountOf = (strHaystack, strNeedle) => strHaystack.split(strNeedle).length - 1;
  for (const strStatement of REVIEWED_VERIFY_NEW_VARIABLE) {
    if (fnCountOf(strVerifyCode, strStatement) !== 1) {
      reject('side-effect-policy', `build.verify no longer binds its reviewed constant: ${strStatement}`);
    }
  }
  if (fnCountOf(strVerifyCode, 'New-Variable') !== REVIEWED_VERIFY_NEW_VARIABLE.length) {
    reject('side-effect-policy', 'build.verify uses New-Variable outside its reviewed constant bindings');
  }
  if (/\b(?:Set-Variable|Get-Variable|Clear-Variable|Remove-Variable|Set-Item)\b|Variable:|PSVariable/iu.test(strVerifyCode.replace('Test-Path Variable:PSNativeCommandUseErrorActionPreference', 'Test-Path'))) {
    reject('side-effect-policy', 'build.verify writes a variable through an indirect API');
  }
  for (const returnToken of generateStep.run.matchAll(/\breturn\b/giu)) {
    if (powerShellBraceDepthAt(generateStep.run, returnToken.index) === 0) {
      reject('side-effect-policy', 'build.verify returns from the script at top level');
    }
  }
  let catchView = afterGenerator;
  for (const fixed of [
  "try {\n    $objResult = $arrResult[0] | ConvertFrom-Json -NoEnumerate -ErrorAction Stop\n} catch {\n    throw 'The generator returned invalid JSON.'\n}",
  "try { $objPathSetResult = $arrPathSetResult[0] | ConvertFrom-Json -NoEnumerate -ErrorAction Stop }\ncatch { throw 'Exact-path verification returned invalid JSON.' }"
]) {
    if (catchView.split(fixed).length !== 2) reject('side-effect-policy', 'build.verify changes a fixed result conversion guard');
    catchView = catchView.replace(fixed, '');
  }
  if (/\bcatch\b/iu.test(powerShellCodeProjection(catchView))) {
    reject('side-effect-policy', 'build.verify can suppress a probe failure after the generator runs');
  }
  if (!generateStep.run.includes('$objProcess.StandardOutput.BaseStream.CopyToAsync($objOutput)') ||
      !generateStep.run.includes('$objProcess.StandardError.ReadToEndAsync()') ||
      !generateStep.run.includes('[void]$objCopyTask.GetAwaiter().GetResult()')) {
    reject('git-policy', 'build.verify no longer drains both Git streams concurrently');
  }
  assertPowerShellPrivateHelperHelp(
    generateStep.run,
    REVIEWED_VERIFY_HELP,
    '1.0.20260818.2',
    'side-effect-policy',
    'build.verify',
  );
}

function validateIsolationTopology(fileName, workflow) {
  if (fileName === IDENTITY_WORKFLOW_FILE_NAME) return;
  const build = fileName === 'build.yml';
  const codeJobs = build ? ['verify_generated_artifacts'] : ['policy', 'markdownlint'];
  expectExactKeys(workflow.jobs, build
    ? ['verify_generated_artifacts', 'publish_committed_artifacts']
    : codeJobs, 'isolation-jobs');
  for (const jobName of codeJobs) {
    const job = workflow.jobs[jobName];
    expectExactKeys(job, ['runs-on', 'timeout-minutes', 'permissions', 'steps'], 'isolation-code-job');
    expectDeepEqual(job.permissions, {}, 'isolation-code-permissions');
    if (!Array.isArray(job.steps)) fail('isolation-code-steps');
    if (Object.hasOwn(job, 'needs')) fail('isolation-independent-code-jobs');
    for (const step of job.steps) {
      if (step === null || typeof step !== 'object' || Array.isArray(step)) fail('isolation-code-step');
      if (Object.hasOwn(step, 'uses')) fail('isolation-code-action');
      if (Object.hasOwn(step, 'continue-on-error')) fail('isolation-failure-suppression');
    }
    const expectedIds = build
      ? ['acquire', 'verify-checkout-credentials', 'generate_style_guide_artifacts']
      : ['acquire', 'verify-checkout-credentials', jobName === 'policy' ? 'validate' : 'lint'];
    expectDeepEqual(job.steps.map(step => step.id), expectedIds, 'isolation-code-step-order');
  }
  if (build) {
    const publisher = workflow.jobs.publish_committed_artifacts;
    expectExactKeys(publisher, ['runs-on', 'timeout-minutes', 'permissions', 'needs', 'steps'], 'isolation-publisher-job');
    if (publisher.needs !== 'verify_generated_artifacts') fail('isolation-publisher-dependency');
    expectDeepEqual(publisher.permissions, { contents: 'read' }, 'isolation-publisher-permissions');
    if (!Array.isArray(publisher.steps) || publisher.steps.length !== 2) fail('isolation-publisher-steps');
    for (const step of publisher.steps) {
      if (step === null || typeof step !== 'object' || Array.isArray(step)
        || !Object.hasOwn(step, 'uses') || Object.hasOwn(step, 'run')
        || Object.hasOwn(step, 'shell') || Object.hasOwn(step, 'env')) {
        fail('isolation-publisher-code');
      }
    }
  }
}

function validateWorkflowObject(fileName, workflow, rawText, contract) {
  expectExactKeys(workflow, ['name', 'on', 'permissions', 'jobs'], 'workflow-shape');
  validateIsolationTopology(fileName, workflow);
  validateIsolationSemantics(fileName, workflow, contract);
  const expectedWorkflow = contract.workflowPolicy.workflows[fileName];
  if (workflow.name !== expectedWorkflow.name) {
    fail('workflow-name');
  }
  expectDeepEqual(
    workflow.on,
    expectedWorkflow.events ?? contract.workflowPolicy.events,
    'workflow-events',
  );
  expectDeepEqual(
    workflow.permissions,
    expectedWorkflow.workflowPermissions ?? contract.workflowPolicy.workflowPermissions,
    'workflow-permissions',
  );
  expectExactKeys(workflow.jobs, Object.keys(expectedWorkflow.jobs), 'workflow-jobs');

  let observedUses = 0;
  for (const [jobId, expectedJob] of Object.entries(expectedWorkflow.jobs)) {
    const job = workflow.jobs[jobId];
    const expectedJobKeys = ['runs-on', 'permissions', 'steps'];
    if (expectedJob.timeoutMinutes !== undefined) expectedJobKeys.push('timeout-minutes');
    if (expectedJob.needs !== undefined) expectedJobKeys.push('needs');
    expectExactKeys(job, expectedJobKeys, 'job-shape');
    if (job['runs-on'] !== expectedJob.runsOn) {
      fail('job-runner');
    }
    expectDeepEqual(job.permissions, expectedJob.permissions, 'job-permissions');
    if (job['timeout-minutes'] !== expectedJob.timeoutMinutes || job.needs !== expectedJob.needs) {
      fail('job-execution-policy');
    }
    if (!Array.isArray(job.steps) || job.steps.length !== expectedJob.steps.length) {
      fail('step-cardinality');
    }
    for (let index = 0; index < expectedJob.steps.length; index += 1) {
      const expectedStep = expectedJob.steps[index];
      const step = job.steps[index];
      if (expectedStep.kind === 'action') {
        observedUses += 1;
        validateActionStep(step, expectedStep, contract, rawText);
      } else if (expectedStep.kind === 'run') {
        validateRunStep(step, expectedStep, contract, fileName !== IDENTITY_WORKFLOW_FILE_NAME);
      } else {
        fail('unknown-role');
      }
    }
  }
  if (rawText !== null) {
    const usesLines = rawText.match(/^[ \\t]+uses:[^\r\n]+$/gmu) ?? [];
    if (usesLines.length !== observedUses) {
      fail('action-cardinality');
    }
  }
  if (fileName === IDENTITY_WORKFLOW_FILE_NAME) {
    validatePullRequestBodyIdentityPolicy(workflow, rawText);
    // Property-qualified identity tests must reach their semantic predicate.
    // Exact reviewed bytes remain mandatory after those predicates pass.
    for (const [jobId, expectedJob] of Object.entries(expectedWorkflow.jobs)) {
      for (let index = 0; index < expectedJob.steps.length; index += 1) {
        const expectedStep = expectedJob.steps[index];
        if (expectedStep.kind === 'run'
          && sha256(Buffer.from(workflow.jobs[jobId].steps[index].run, 'utf8')) !== expectedStep.runSha256) fail('run-role');
      }
    }
  }
}

function validateIdentityAcquisitionPolicy(workflow) {
  const steps = workflow.jobs.verify_identity.steps;
  const acquire = steps[0].run;
  const rules = [
  [
    "identity-acquire-policy",
    "trusted workflow revision equality changed",
    "$strBaseSha = [string]$objEvent.pull_request.base.sha\n$strHeadRepository = [string]$objEvent.pull_request.head.repo.full_name\n$strHeadSha = [string]$objEvent.pull_request.head.sha\nif ($strBaseSha -cnotmatch '^[0-9a-f]{40}$' -or\n    $strWorkflowSha -cne $strBaseSha) {\n    throw 'acquire: the trusted workflow revision is inconsistent'\n}",
    0
  ],
  [
    "identity-acquire-policy",
    "exact trusted-base fetch changed",
    "& $strGitPath --no-replace-objects -c core.fsmonitor=false fetch --depth 1 --no-tags --no-recurse-submodules trusted $strBaseSha\nif ($LASTEXITCODE -ne 0) { throw \"acquire: trusted fetch exited $LASTEXITCODE\" }",
    0
  ],
  [
    "identity-acquire-policy",
    "trusted worktree source changed",
    "& $strGitPath --no-replace-objects -c core.fsmonitor=false worktree add --quiet --detach $strTrustedRoot $strBaseSha\nif ($LASTEXITCODE -ne 0) { throw \"acquire: trusted worktree exited $LASTEXITCODE\" }\n$strObservedBase = (& $strGitPath -C $strTrustedRoot --no-replace-objects -c core.fsmonitor=false rev-parse --verify 'HEAD^{commit}').Trim()",
    0
  ],
  [
    "identity-acquire-policy",
    "exact bounded proposed-head fetch changed",
    "& $strGitPath --no-replace-objects -c core.fsmonitor=false fetch --filter=blob:none --depth 65 --no-tags --no-recurse-submodules proposed $strHeadSha\nif ($LASTEXITCODE -ne 0) { throw \"acquire: proposed fetch exited $LASTEXITCODE\" }",
    0
  ],
  [
    "identity-acquire-policy",
    "exact fetched-head identity changed",
    "$strFetchedHead = (& $strGitPath --no-replace-objects -c core.fsmonitor=false rev-parse --verify 'FETCH_HEAD^{commit}').Trim()\nif ($LASTEXITCODE -ne 0 -or $strFetchedHead -cne $strHeadSha) {\n    throw 'acquire: the fetched revision is not the exact pull request head'\n}",
    0
  ],
  [
    "identity-acquire-policy",
    "detached object HEAD changed",
    "& $strGitPath --no-replace-objects -c core.fsmonitor=false update-ref --no-deref HEAD $strFetchedHead\nif ($LASTEXITCODE -ne 0) { throw \"acquire: detached HEAD update exited $LASTEXITCODE\" }",
    0
  ],
  [
    "identity-authorization-policy",
    "changed verifier-input comparison changed",
    "$boolVerifierInputsChanged =\n    [string]::Join(\"`n\", $arrProposedEntries) -cne\n    [string]::Join(\"`n\", $arrTrustedEntries)",
    0
  ],
  [
    "identity-authorization-policy",
    "changed ordinary-input comparison changed",
    "$boolOrdinaryTupleChanged =\n    [string]::Join(\"`n\", $arrProposedOrdinaryEntries) -cne\n    [string]::Join(\"`n\", $arrTrustedOrdinaryEntries)",
    0
  ],
  [
    "identity-authorization-policy",
    "trusted authorizer path changed",
    "    $strTrustedAuthorizationPath = [System.IO.Path]::Combine(\n        $strTrustedRoot,\n        '.github',\n        'workflows',\n        'Test-TrustRootAuthorization.ps1'\n    )",
    1
  ],
  [
    "identity-authorization-policy",
    "trusted authorization invocation changed",
    "    $arrAuthorization = @(\n        & $strTrustedAuthorizationPath `\n            -RepositoryRootPath $strTrustedRoot `\n            -TrustedRevision $strBaseSha `\n            -BaseRevision $strBaseSha `\n            -HeadRevision $strHeadSha\n    )",
    1
  ],
  [
    "identity-authorization-policy",
    "trusted authorization Boolean result changed",
    "    if ($arrAuthorization.Count -ne 1 -or\n        $arrAuthorization[0] -isnot [bool] -or\n        -not $arrAuthorization[0]) {\n        throw 'acquire: the verifier change is not exactly authorized'\n    }",
    1
  ],
  [
    "identity-node-policy",
    "reviewed Node archive URL changed",
    "$strNodeUrl = 'https://nodejs.org/dist/v24.18.1/node-v24.18.1-linux-x64.tar.xz'",
    0
  ],
  [
    "identity-node-policy",
    "reviewed Node archive digest changed",
    "$strReviewedNodeSha256 = 'D6C664DF3F3F61458E8C277585571328522D705166723A7C7823A9253A4D15A0'",
    0
  ],
  [
    "identity-node-policy",
    "Node extraction precedes archive authentication",
    "$strObservedNodeSha256 = (Get-FileHash -LiteralPath $strArchivePath -Algorithm SHA256).Hash\nif ($strObservedNodeSha256 -cne $strReviewedNodeSha256) {\n    throw 'acquire: the Node archive does not match the reviewed digest'\n}\n[void][System.IO.Directory]::CreateDirectory($strNodeRoot)\n& $strTarPath -xJf $strArchivePath -C $strNodeRoot --strip-components=1",
    0
  ],
  [
    "identity-node-policy",
    "reviewed Node runtime assertion changed",
    "$strNodeVersion = (& $strNodePath --version).Trim()\nif ($LASTEXITCODE -ne 0 -or $strNodeVersion -cne 'v24.18.1') {\n    throw 'acquire: the reviewed Node executable has an unexpected version'\n}",
    0
  ]
];
  for (const [category, reason, fragment, depth] of rules) {
    const offset = acquire.indexOf(fragment);
    const firstToken = offset + fragment.length - fragment.trimStart().length;
    if (acquire.split(fragment).length !== 2 || powerShellBraceDepthAt(acquire, firstToken) !== depth) reject(category, reason);
  }
  const authorization = "if ($boolVerifierInputsChanged -or $boolOrdinaryTupleChanged) {\n    $arrAuthorization = @(\n        & $strTrustedAuthorizationPath `\n            -RepositoryRootPath $strTrustedRoot `\n            -TrustedRevision $strBaseSha `\n            -BaseRevision $strBaseSha `\n            -HeadRevision $strHeadSha\n    )\n    if ($arrAuthorization.Count -ne 1 -or\n        $arrAuthorization[0] -isnot [bool] -or\n        -not $arrAuthorization[0]) {\n        throw 'acquire: the verifier change is not exactly authorized'\n    }\n}";
  const condition = 'if ($boolVerifierInputsChanged -or $boolOrdinaryTupleChanged) {';
  if (acquire.split(authorization).length !== 2 || powerShellBraceDepthAt(acquire, acquire.indexOf(authorization)) !== 0
    || acquire.split(condition).length !== 3) reject('identity-authorization-policy', 'conditional trusted authorization flow changed');
  for (const match of acquire.matchAll(/if \(\$boolVerifierInputsChanged -or \$boolOrdinaryTupleChanged\) \{/gu)) {
    if (powerShellBraceDepthAt(acquire, match.index) !== 0) reject('identity-authorization-policy', 'conditional trusted authorization flow changed');
  }
  const code = powerShellCodeProjection(acquire);
  const returns = [...code.matchAll(/(?:^|[;{}])[ \t]*(exit|return|break|continue|trap)\b/gimu)].map(match => {
    const offset = match.index + match[0].lastIndexOf(match[1]);
    const newline = acquire.indexOf('\n', offset);
    return [acquire.slice(offset, newline < 0 ? acquire.length : newline).trim(), powerShellBraceDepthAt(acquire, offset)];
  });
  if (canonicalJson(returns) !== canonicalJson([['return 0', 2], ['return $longObservedBytes', 2]]) || PROCESS_TERMINATION.test(code)) reject('identity-acquire-policy', 'acquisition bypass control flow introduced');
  const commandPath = "$strTrustedCommandPath = [System.IO.Path]::Combine(\n    $env:RUNNER_TEMP,\n    'pr-body-identity-trusted',\n    '.github',\n    'workflows',\n    'Sync-PullRequestBodyIdentity.mjs'\n)";
  if (steps.slice(1).some(step => step.run.split(commandPath).length !== 2)) fail('identity-command-policy');
  if (steps[2].run.split('& $strNodePath $strTrustedCommandPath --check-event $env:GITHUB_EVENT_PATH --repository-root $PWD.Path').length !== 2) fail('identity-event-policy');
}

function validatePullRequestBodyIdentityPolicy(workflow, rawText) {
  const job = workflow.jobs.verify_identity;
  const source = rawText ?? job.steps.map((step) => step.run ?? '').join('\n');
  if (/\bGITHUB_TOKEN\b|\bACTIONS_RUNTIME_TOKEN\b|github\s*(?:\.|\[)\s*['"]?token|credential\.helper|extraheader|GIT_ASKPASS|\bAuthorization\b(?!\.ps1)|\bBearer\b/iu.test(source)) {
    fail('identity-credential-policy');
  }
  if (source.includes('${{')) {
    fail('identity-expression-policy');
  }
  if (/continue-on-error/iu.test(source)) {
    fail('identity-failure-policy');
  }
  if (/^[ \t]+uses:/gmu.test(source)) {
    fail('identity-isolation-policy');
  }
  if (/--(?:update|generate)\b/iu.test(source)) {
    fail('identity-mode-policy');
  }
  const runs = job.steps.map((step) => step.run ?? '').join('\n');
  if ((runs.match(/& \$strCurlPath\b/gu) ?? []).length !== 2) {
    fail('identity-node-policy');
  }
  if ((runs.match(/& \$strNodePath \$strTrustedCommandPath\b/gu) ?? []).length !== 2) {
    fail('identity-command-policy');
  }
  validateIdentityAcquisitionPolicy(workflow);
  const transferLiterals = [
    'fetch --filter=blob:none --depth 65 --no-tags --no-recurse-submodules proposed $strHeadSha',
    "$env:GIT_NO_LAZY_FETCH = '1'",
    'https://raw.githubusercontent.com/$strHeadRepository/$strHeadSha/$strEscapedPath',
    '--connect-timeout 15 --max-time 60',
    '--speed-limit 1024 --speed-time 15',
    '--max-filesize $longTransferLimit',
    '--range "0-$MaximumBytes"',
    '$MaximumBytes -gt 573440 -or',
    '$Sequence -lt 1 -or $Sequence -gt 24 -or',
    '$dictionaryProposedBlob.Count -gt 24 -or',
    '$longMaximumProposedBytes = 12599320\n',
    '$longObservedProposedBytes -gt $longMaximumProposedBytes',
    '$strObservedBlob.Trim() -cne $strTreeBlob',
    '$strWrittenBlob.Trim() -cne $strTreeBlob',
    'remote remove trusted',
    'remote remove proposed',
    "'^(remote\\..*|extensions\\.partialclone)$'",
    '$intOfflineSelectorExit -ne 1',
    '$arrOfflineSelector.Count -ne 0',
  ];
  if (
    transferLiterals.some((literal) => !runs.includes(literal))
    || (runs.match(/hash-object --no-filters/gu) ?? []).length !== 2
    // Count the two fixed executable lines, not the new help examples. Exact
    // run-byte identity remains mandatory after these semantic checks.
    || (runs.match(/^[ \t]*(?:function Add-ProposedBlob \{|\$longObservedProposedBytes \+= Add-ProposedBlob `)$/gmu) ?? []).length !== 2
    || /fetch --depth 65 --no-tags --no-recurse-submodules proposed/gu.test(runs)
  ) {
    fail('identity-transfer-policy');
  }
}

function validateDependabot(value, contract) {
  expectDeepEqual(value, contract.dependabot, 'dependabot-policy');
  expectExactKeys(value, ['version', 'updates'], 'dependabot-policy');
  expectExactKeys(value.updates[0], ['package-ecosystem', 'directory', 'schedule'], 'dependabot-policy');
  expectExactKeys(value.updates[0].schedule, ['interval'], 'dependabot-policy');
}

function readMarkdownEntryPoint(entry, contract) {
  const bytes = readOrdinaryFile(
    path.join(SCRIPT_DIRECTORY, entry.path),
    contract.limits.maximumJsonBytes,
    'markdown-entry-point',
  );
  if (bytes.length !== entry.length || sha256(bytes) !== entry.sha256) {
    fail('markdown-entry-point-identity');
  }
  return bytes;
}

function strictUtf8Text(bytes, category) {
  const text = bytes.toString('utf8');
  if (Buffer.from(text, 'utf8').compare(bytes) !== 0 || text.charCodeAt(0) === 0xfeff || text.includes('\r')) {
    fail(category);
  }
  return text;
}

function validateMarkdownEntryPoints(contract) {
  const { entryPoints } = contract.markdownPolicy;
  const rootPackage = parseStrictJson(
    readMarkdownEntryPoint(entryPoints.rootPackageJson, contract),
    contract.limits,
    'markdown-root-package',
  );
  const workflowPackage = parseStrictJson(
    readMarkdownEntryPoint(entryPoints.workflowPackageJson, contract),
    contract.limits,
    'markdown-workflow-package',
  );
  validateRootToolchain(rootPackage);
  validateLintAsset('lint-config', readOrdinaryFile(path.join(SCRIPT_DIRECTORY, '.markdownlint.jsonc'), 262144, 'lint-asset-file'));
  if (
    rootPackage.scripts?.['lint:md'] !== entryPoints.rootPackageJson.lintScript
    || workflowPackage.scripts?.['lint:md'] !== entryPoints.workflowPackageJson.lintScript
  ) {
    fail('markdown-all-files');
  }

  const nestedLinterBytes = readMarkdownEntryPoint(entryPoints.nestedLinter, contract);
  validateLintAsset('nested-linter', nestedLinterBytes);
  const nestedLinter = strictUtf8Text(
    nestedLinterBytes,
    'markdown-nested-linter',
  );
  const requiredIgnorePatterns = REQUIRED_IGNORED_MARKDOWN_DIRECTORIES.flatMap(
    (directoryName) => [`${directoryName}/**`, `**/${directoryName}/**`],
  );
  const expectedIgnoreSource = [
    'const markdownIgnore = [',
    ...requiredIgnorePatterns.map((pattern, index) => (
      `    '${pattern}'${index === requiredIgnorePatterns.length - 1 ? '' : ','}`
    )),
    '];',
  ].join('\n');
  if (
    !nestedLinter.includes(`glob('${entryPoints.nestedLinter.glob}'`)
    || !nestedLinter.includes('dot: true')
    || !nestedLinter.replaceAll('\r\n', '\n').includes(expectedIgnoreSource)
  ) {
    fail('markdown-nested-linter');
  }

  const stagedSelector = strictUtf8Text(
    readMarkdownEntryPoint(entryPoints.stagedSelector, contract),
    'markdown-staged-selector',
  );
  if (
    !stagedSelector.includes("Object.freeze(['*.md', '*.mdc'])")
    || !stagedSelector.includes('...stagedMarkdownPathspecs')
  ) {
    fail('markdown-staged-selector');
  }

  const preCommit = parseStrictYaml(
    readMarkdownEntryPoint(entryPoints.preCommit, contract),
    contract.limits,
  ).value;
  const firstRepositoryHooks = preCommit.repos?.[0]?.hooks;
  const endOfFile = Array.isArray(firstRepositoryHooks)
    ? firstRepositoryHooks.find((hook) => hook.id === 'end-of-file-fixer')
    : undefined;
  const trailingWhitespace = Array.isArray(firstRepositoryHooks)
    ? firstRepositoryHooks.find((hook) => hook.id === 'trailing-whitespace')
    : undefined;
  const extensionPattern = '.*\\.(md|mdc)';
  if (
    typeof endOfFile?.files !== 'string'
    || !endOfFile.files.includes(extensionPattern)
    || typeof trailingWhitespace?.files !== 'string'
    || !trailingWhitespace.files.includes(extensionPattern)
    || canonicalJson(trailingWhitespace.args) !== canonicalJson([
      entryPoints.preCommit.linebreakArgument,
    ])
  ) {
    fail('markdown-pre-commit');
  }
}

// Raw-byte comparison only, so this is safe to call before any dependency is
// installed. Deliberately free of parseStrictJson, which needs the yaml package.
//
// This reads supplyFreeze.reviewedWorkingBytes, not supplyFreeze.baseline. The
// baseline records what the two files looked like before the dependency change
// and has no consumer anywhere: it is provenance for a human auditor, not a
// gate. Verifying it would mean reading Git objects, which this validator
// deliberately cannot do, and which a fetch-depth-1 checkout may not even have.
// That gap is accepted, with the reasoning and a manual check recorded in
// docs/decisions/0002-accept-unverifiable-baseline-provenance.md.
function verifyPackageDigests(contract) {
  const packageJsonBytes = readOrdinaryFile(path.join(SCRIPT_DIRECTORY, 'package.json'), contract.limits.maximumJsonBytes, 'package-file');
  const packageLockBytes = readOrdinaryFile(path.join(SCRIPT_DIRECTORY, 'package-lock.json'), contract.limits.maximumJsonBytes, 'lock-file');
  validatePackageBytePair(packageJsonBytes, packageLockBytes, contract);
  return { packageJsonBytes, packageLockBytes };
}

function validatePackageBytePair(packageJsonBytes, packageLockBytes, contract) {
  if (
    sha256(packageJsonBytes) !== contract.supplyFreeze.reviewedWorkingBytes.packageJson.sha256
    || sha256(packageLockBytes) !== contract.supplyFreeze.reviewedWorkingBytes.packageLockJson.sha256
  ) {
    fail('package-graph');
  }
}

function verifyValidatorIdentity(contract) {
  const validatorBytes = readOrdinaryFile(
    path.join(SCRIPT_DIRECTORY, VALIDATOR_FILE_NAME),
    262144,
    'validator-file',
  );
  if (sha256(validatorBytes) !== contract.validatorIdentity.sha256) {
    fail('validator-identity');
  }
}

// Reads and authenticates the contract using only Node built-ins. JSON.parse
// replaces parseStrictJson here because the latter routes through the yaml
// package; the strict parse still runs later, once dependencies are trusted.
function readContractWithoutDependencies() {
  const bytes = readOrdinaryFile(
    path.join(SCRIPT_DIRECTORY, 'workflow-policy-contract.json'),
    524288,
    'contract-file',
  );
  // parseStrictYaml() applies this same byte gate before the full run parses the
  // contract, but preflight cannot call it: it routes through the yaml package,
  // which is precisely what has not been authenticated yet. Applying the gate
  // here keeps the install gate from being laxer than the validation it fronts.
  // JSON.parse happens to reject a leading BOM, and the identity digest happens
  // to reject the replacement characters that invalid UTF-8 decodes to, but both
  // are incidental properties of other checks; state the requirement instead.
  const text = strictUtf8Text(bytes, 'contract-encoding');
  let contract;
  try {
    contract = JSON.parse(text);
  } catch {
    fail('contract-json');
  }
  if (contract === null || typeof contract !== 'object' || Array.isArray(contract)) {
    fail('contract-json');
  }
  // validatorIdentity is excluded from the identity view, so a contract that
  // omits it entirely would still match the digest. Check its shape explicitly.
  // Identical to the check validateContract() applies. Preflight gates the
  // install, so it must not be laxer than the full run about the one field the
  // identity view cannot cover.
  expectExactKeys(contract.validatorIdentity, ['path', 'sha256'], 'contract-shape');
  if (
    contract.validatorIdentity.path !== VALIDATOR_FILE_NAME
    || !/^[0-9a-f]{64}$/u.test(contract.validatorIdentity.sha256)
  ) {
    fail('contract-shape');
  }
  if (sha256(canonicalJson(contractIdentityView(contract))) !== EXPECTED_CONTRACT_CANONICAL_SHA256) {
    fail('contract-identity');
  }
  return contract;
}

function preflight() {
  const contract = readContractWithoutDependencies();
  verifyValidatorIdentity(contract);
  verifyPackageDigests(contract);
  return {
    schema: PREFLIGHT_SCHEMA,
    validatorVersion: VALIDATOR_VERSION,
    success: true,
    contractCanonicalSha256: sha256(canonicalJson(contractIdentityView(contract))),
  };
}

function validatePackageTuple(contract) {
  const { packageJsonBytes, packageLockBytes } = verifyPackageDigests(contract);
  const packageJson = parseStrictJson(packageJsonBytes, contract.limits, 'package-json');
  const packageLock = parseStrictJson(packageLockBytes, contract.limits, 'package-lock-json');
  validatePackageObjects(packageJson, packageLock, contract);
  validateNpmConfigPresence(['.npmrc', '../.npmrc', '../../.npmrc'].map(relative => {
    try { fs.lstatSync(path.resolve(SCRIPT_DIRECTORY, relative)); return true; }
    catch (error) { if (error.code === 'ENOENT') return false; fail('npm-config'); }
  }));
}

function validatePackageObjects(packageJson, packageLock, contract) {
  const dependencies = {
    glob: '^10.3.10',
    husky: '^9.1.7',
    'markdown-it': '^14.0.0',
    markdownlint: '^0.40.0',
    'markdownlint-cli2': '^0.20.0',
    yaml: '2.9.0',
  };
  if (canonicalJson(packageJson.scripts) !== canonicalJson({
    'lint:md': REQUIRED_WORKFLOW_LINT_SCRIPT, 'lint:md:nested': 'node lint-nested-markdown.js', prepare: 'node install-husky.mjs',
  })) reject('package-graph', 'workflow scripts differ from the frozen graph');
  if (canonicalJson(packageJson.devDependencies) !== canonicalJson(dependencies)) reject('package-graph', 'manifest dependencies differ from the frozen graph');
  if (packageJson.private !== true || Object.hasOwn(packageJson, 'dependencies') || Object.hasOwn(packageJson, 'overrides')) reject('package-graph', 'manifest introduces an unreviewed dependency surface');
  if (packageLock.lockfileVersion !== 3 || canonicalJson(packageLock.packages?.['']?.devDependencies) !== canonicalJson(dependencies)) reject('package-graph', 'root lock dependencies differ from the frozen graph');
  const parser = packageLock.packages?.['node_modules/yaml'];
  if (parser?.version !== '2.9.0' || parser?.resolved !== contract.supplyFreeze.yaml.tarball
    || parser?.integrity !== contract.supplyFreeze.yaml.integrity) reject('package-graph', 'resolved parser tuple differs from the frozen graph');
  if (Object.keys(packageLock.packages).some(key => /(?:^|\/)node_modules\/smol-toml$/u.test(key))) reject('package-graph', 'the PS frozen graph contains an unreviewed smol-toml package');
  if (Object.hasOwn(packageLock.packages?.['node_modules/markdownlint-cli2']?.dependencies ?? {}, 'smol-toml')) reject('package-graph', 'the PS frozen graph contains an unreviewed smol-toml declaration');
}

function validateProducerToolchain(producer) {
  if (producer?.nodeVersion !== '24.18.1' || producer?.npmVersion !== '11.16.0') fail('supply-freeze');
}

function validateRootToolchain(rootPackage) {
  if (rootPackage?.engines?.node !== '24.18.0' || rootPackage?.engines?.npm !== '11.16.0'
    || rootPackage?.packageManager !== 'npm@11.16.0') fail('root-toolchain');
}

function validateLintAsset(label, bytes) {
  const expected = {
    'lint-config': '5eb07bf7f30829e0091e82f235a96fdba21be1ef1160ca1e22cdbe8d82da5300',
    'nested-linter': 'b20aaab172224da4377cda75fa6cad1a8eeb00f8bdd26737ffe0e6c2ad222492',
  };
  if (!Object.hasOwn(expected, label) || !Buffer.isBuffer(bytes) || bytes.length > 262144 || sha256(bytes) !== expected[label]) fail('lint-asset');
}

function validateNpmConfigPresence(presence) {
  if (!Array.isArray(presence) || presence.length !== 3 || presence.some(value => value !== false)) fail('npm-config');
}

function validateScriptVersionText(source, expectedVersion) {
  // .NET multiline anchors in the generator use LF, not JS's additional
  // Unicode line separators. Keep the port's boundary semantics identical.
  const firstFunction = /(?<![^\n])function[\x20\x09]+[A-Za-z0-9_-]+[\x20\x09]*\{/u.exec(source);
  if (firstFunction === null) fail('invalid-version');
  const blocks = source.slice(0, firstFunction.index).match(/<#(?:(?!#>)[\s\S])*\.NOTES(?:(?!#>)[\s\S])*#>/gu) ?? [];
  const globalMarkers = source.match(/(?<![^\n])Version:[^\r\n]*(?=\n|$)/gu) ?? [];
  if (blocks.length !== 1 || globalMarkers.length !== 1) fail('invalid-version');
  const markers = [...blocks[0].matchAll(/(?<![^\n])Version: ([0-9]+)\.([0-9]+)\.([0-9]{8})\.([0-9]+)(?=\n|$)/gu)];
  if (markers.length !== 1 || markers[0][0] !== globalMarkers[0]) fail('invalid-version');
  const parts = markers[0].slice(1);
  if (parts.some(value => (value.length > 1 && value.startsWith('0')) || !Number.isSafeInteger(Number(value)) || Number(value) > 2147483647)) fail('invalid-version');
  const date = parts[2], year = Number(date.slice(0, 4)), month = Number(date.slice(4, 6)), day = Number(date.slice(6));
  const parsed = new Date(`${date.slice(0, 4)}-${date.slice(4, 6)}-${date.slice(6)}T00:00:00Z`);
  if (year < 1 || !Number.isFinite(parsed.getTime()) || parsed.getUTCFullYear() !== year
    || parsed.getUTCMonth() + 1 !== month || parsed.getUTCDate() !== day) fail('invalid-version');
  if (parts.map(Number).join('.') !== parts.join('.')) fail('invalid-version');
  if (parts.join('.') !== expectedVersion) fail('unexpected-version');
}

function validateScriptVersions(contract) {
  for (const scriptPolicy of Object.values(contract.scriptVersions)) {
    const bytes = readOrdinaryFile(path.join(SCRIPT_DIRECTORY, scriptPolicy.path), 262144, 'script-file');
    if (sha256(bytes) !== scriptPolicy.sha256) {
      fail('script-identity');
    }
    validateScriptVersionText(strictUtf8Text(bytes, 'script-encoding'), scriptPolicy.version);
  }
}

function replaceGeneratorSourceOnce(source, from, to) {
  if (source.split(from).length - 1 !== 1) {
    fail('generator-mutation');
  }
  return source.replace(from, to);
}

// These distinct contexts bind each conversion to its own loop. A total call
// count alone cannot prove that both independently reached paths stay invariant.
const RATIONALE_ANCHOR_FRAGMENT = "            $strAnchor = $strHeadingText.ToLowerInvariant() -replace '[^a-z0-9 -]', '' -replace ' ', '-'";
const RATIONALE_INDEX_FRAGMENT = '                $hashtableSections[$strCurrentAnchor] = $listCurrentBody.ToArray()\n'
  + '            }\n' + RATIONALE_ANCHOR_FRAGMENT;
const GUIDE_HEADING_FRAGMENT = '            $strHeadingText = $Matches[2]\n' + RATIONALE_ANCHOR_FRAGMENT;

function validateGeneratorPolicy(source) {
  const requiredFragments = Object.freeze([
    ['Linux platform detection', '[System.Runtime.InteropServices.OSPlatform]::Linux', 1],
    ['macOS platform detection', '[System.Runtime.InteropServices.OSPlatform]::OSX', 1],
    ['FreeBSD platform detection', "[System.Runtime.InteropServices.OSPlatform]::Create('FREEBSD')", 1],
    ['BSD platform dispatch', '    if ($boolHostIsMacOS -or $boolHostIsFreeBsd) {', 1],
    ['BSD stat identity tuple', "        $arrStatOutput = @(& stat '-f' '%l:%d:%i' $LiteralPath)", 1],
    ['Linux platform dispatch', '    } elseif ($boolHostIsLinux) {', 1],
    ['GNU stat identity tuple', "        $arrStatOutput = @(& stat '-Lc' '%h:%d:%i' '--' $LiteralPath)", 1],
    ['unknown platform refusal', "        throw 'unsupported-platform'", 1],
    ['final candidate identity binding', '        if ($hashtableRecord.FinalOrdinaryIdentity -cne $strCandidateIdentity) {', 1],
    ['final candidate mismatch failure', "            throw 'final-candidate-identity-mismatch'", 1],
    ['invariant rationale index', RATIONALE_INDEX_FRAGMENT, 1],
    ['invariant guide heading', GUIDE_HEADING_FRAGMENT, 1],
  ]);
  for (const [label, fragment, expectedCount] of requiredFragments) {
    if (source.split(fragment).length - 1 !== expectedCount) {
      fail(`generator-source-${label.replaceAll(' ', '-')}`);
    }
  }
}

// PS generator source proof: fixed reviewed bytes and a fresh process; not a generic unqualified-lookup exemption.
const REVIEWED_GENERATOR_COMMANDS = Object.freeze([
  "Add-Type",
  "ArtifactId",
  "Artifacts",
  "Assert-OrdinaryAbsolutePath",
  "Assert-OrdinaryPathComponent",
  "Assert-TrackedFile",
  "BuildDate",
  "CandidateLength",
  "CandidateOrdinaryIdentity",
  "CandidateSha256",
  "Category",
  "CleanupResult",
  "ConvertFrom-StrictUtf8",
  "ConvertTo-Json",
  "ConvertTo-NormalizedUtf8",
  "ExitCode",
  "FinalLength",
  "FinalOrdinaryIdentity",
  "FinalSha256",
  "FinalState",
  "ForEach-Object",
  "GeneratorVersion",
  "Get-Command",
  "Get-FileSha256Hex",
  "Get-OrdinaryDestinationState",
  "Get-OrdinaryFileIdentity",
  "Get-ScriptVersionRecord",
  "Get-Sha256Hex",
  "Initialize-AtomicFileReplacementType",
  "Initialize-WindowsFileIdentityType",
  "Join-Path",
  "Justification",
  "Major",
  "Mandatory",
  "Minor",
  "NativeOutcome",
  "New-ArtifactRecord",
  "New-ChatPayload",
  "New-CopilotPayload",
  "New-FullPayload",
  "New-Object",
  "New-PowerShellInstructionsPayload",
  "New-StyleGuidePayloadMap",
  "OriginalLength",
  "OriginalOrdinaryIdentity",
  "OriginalSha256",
  "OriginalState",
  "Overall",
  "Path",
  "Phase",
  "PublicationMethod",
  "PublicationReturned",
  "Revision",
  "Schema",
  "Set-StrictMode",
  "Status",
  "TemporaryDisposition",
  "Test-FileSystemEntry",
  "Test-PathContainedByRoot",
  "Test-PathTextIsSafe",
  "Test-ScriptVersionParser",
  "Version",
  "Where-Object",
  "Write-GeneratorResult",
  "Write-StyleGuideArtifact",
  "break",
  "catch",
  "chat",
  "continue",
  "copilot",
  "else",
  "elseif",
  "exit",
  "finally",
  "for",
  "foreach",
  "full",
  "function",
  "guide",
  "if",
  "param",
  "rationale",
  "return",
  "throw",
  "try",
  "while"
]);

const REVIEWED_GENERATOR_QUALIFIED_ASSIGNMENTS = Object.freeze([
  "script:strGeneratorVersion",
  "script:strGeneratorResultSchema",
  "script:objUtf8Strict",
  "script:objUtf8NoBom",
  "script:boolHostIsWindows",
  "script:objPathComparison"
]);

const REVIEWED_GENERATOR_INVOCATIONS = Object.freeze([
  [
    "$arrStatOutput = @(& stat '-f' '%l:%d:%i' $LiteralPath)",
    2
  ],
  [
    "$arrStatOutput = @(& stat '-Lc' '%h:%d:%i' '--' $LiteralPath)",
    2
  ],
  [
    "$arrOutput = @(& $strGitPath -C $RepositoryRoot ls-files --error-unmatch -- $RepositoryPath 2>$null)",
    1
  ]
]);

const REVIEWED_GENERATOR_HELP = Object.freeze({
  "Get-ScriptVersionRecord": [
    "ScriptText",
    "ExpectedVersion"
  ],
  "Test-ScriptVersionParser": [],
  "ConvertTo-LowerHex": [
    "Bytes"
  ],
  "Get-Sha256Hex": [
    "Bytes"
  ],
  "Get-FileSha256Hex": [
    "LiteralPath"
  ],
  "Test-PathTextIsSafe": [
    "RawPath"
  ],
  "Assert-OrdinaryPathComponent": [
    "LiteralPath",
    "ExpectedType"
  ],
  "Get-OrdinaryDestinationState": [
    "LiteralPath"
  ],
  "Test-FileSystemEntry": [
    "LiteralPath"
  ],
  "Assert-OrdinaryAbsolutePath": [
    "LiteralPath",
    "ExpectedLeafType"
  ],
  "Test-PathContainedByRoot": [
    "Root",
    "Candidate"
  ],
  "Initialize-WindowsFileIdentityType": [],
  "Get-OrdinaryFileIdentity": [
    "LiteralPath"
  ],
  "Assert-TrackedFile": [
    "RepositoryRoot",
    "RepositoryPath"
  ],
  "ConvertFrom-StrictUtf8": [
    "Bytes"
  ],
  "ConvertTo-NormalizedUtf8": [
    "CompleteFinalPayload"
  ],
  "New-CopilotPayload": [
    "GuideContent"
  ],
  "New-PowerShellInstructionsPayload": [
    "GuideContent"
  ],
  "New-ChatPayload": [
    "GuideContent"
  ],
  "New-FullPayload": [
    "GuideContent",
    "RationaleContent"
  ],
  "New-StyleGuidePayloadMap": [
    "GuideBytes",
    "RationaleBytes"
  ],
  "New-ArtifactRecord": [
    "ArtifactId",
    "RepositoryPath"
  ],
  "Initialize-AtomicFileReplacementType": [],
  "Write-StyleGuideArtifact": [
    "ArtifactId",
    "RawDestinationPath",
    "CompletePayloadBytes",
    "RepositoryRoot",
    "DestinationMap"
  ],
  "Write-GeneratorResult": [
    "Result"
  ]
});

const REVIEWED_PS_GENERATOR_HELP_VERSIONS = Object.freeze({
  "Get-ScriptVersionRecord": "1.0.20260813.0",
  "Test-ScriptVersionParser": "1.0.20260813.0",
  "ConvertTo-LowerHex": "1.0.20260813.0",
  "Get-Sha256Hex": "1.0.20260813.0",
  "Get-FileSha256Hex": "1.0.20260813.0",
  "Test-PathTextIsSafe": "1.0.20260813.0",
  "Assert-OrdinaryPathComponent": "1.0.20260818.0",
  "Get-OrdinaryDestinationState": "1.0.20260818.0",
  "Test-FileSystemEntry": "1.0.20260814.0",
  "Assert-OrdinaryAbsolutePath": "1.0.20260813.0",
  "Test-PathContainedByRoot": "1.0.20260813.0",
  "Initialize-WindowsFileIdentityType": "1.0.20260818.0",
  "Get-OrdinaryFileIdentity": "1.0.20260915.0",
  "Assert-TrackedFile": "1.0.20260813.0",
  "ConvertFrom-StrictUtf8": "1.0.20260813.0",
  "ConvertTo-NormalizedUtf8": "1.0.20260813.0",
  "New-CopilotPayload": "1.0.20260813.0",
  "New-PowerShellInstructionsPayload": "1.0.20260813.0",
  "New-ChatPayload": "1.0.20260813.0",
  "New-FullPayload": "1.0.20260916.0",
  "New-StyleGuidePayloadMap": "1.0.20260813.0",
  "New-ArtifactRecord": "1.0.20260814.0",
  "Initialize-AtomicFileReplacementType": "1.0.20260813.0",
  "Write-StyleGuideArtifact": "1.0.20260915.0",
  "Write-GeneratorResult": "1.0.20260813.0"
});

function validateGeneratorIsolationPolicy(source) {
  if ((source.match(/^Version: [0-9]+\.[0-9]+\.[0-9]{8}\.[0-9]+$/gmu) ?? []).join('') !== 'Version: 1.0.20260916.0') reject('supply-policy', 'the generator version marker differs from the fixed PS source');
  const rawGeneratorCode = powerShellCodeProjection(source);
  const generatorCode = powerShellTokenView(normalizeLineContinuations(source));
  const staticCode = powerShellTokenView(normalizeLineContinuations(source.replaceAll("[char[]]'*?[]'", "'*?[]'").replace(/^    \$strNativeOutcome = \$_\.Exception\.GetType\(\)\.FullName$/gmu, '    $strNativeOutcome = $null'))).replaceAll('[void](Get-ScriptVersionRecord ', '(Get-ScriptVersionRecord ').replaceAll('[void](Assert-OrdinaryAbsolutePath ', '(Assert-OrdinaryAbsolutePath ');
  assertLiteralStaticCalls(staticCode, 'supply-policy', 'the generator');

  if (/[^\t\n\x20-\x7e]/u.test(source)) {
    reject('supply-policy', 'the generator contains a character outside printable ASCII');
  }
  const fixedLookup = '$arrGitCommands = @(Get-Command -Name git -CommandType Application -ErrorAction Stop)';
  if (source.split(fixedLookup).length !== 2 || (generatorCode.match(/Get-Command/giu) ?? []).length !== 1) reject('supply-policy', 'the generator changes its fixed reviewed Git lookup');
  const gitPathAssignments = generatorCode.match(variableWritePattern('strGitPath')) ?? [];
  if (gitPathAssignments.length !== 1) {
    reject('supply-policy', 'the generator does not assign its Git path exactly once');
  }
  if (!/\)\s*\$arrGitCommands = @\(Get-Command/u.test(generatorCode)) {
    reject('supply-policy', 'the generator can reach its Git lookup only after unreviewed statements');
  }
  if (/\$ExecutionContext\s*\.\s*InvokeCommand|\.\s*InvokeCommand\s*\.\s*GetCommand|\[\s*(?:System\.)?Management\.Automation\.CommandTypes\s*\]/iu.test(generatorCode)) {
    reject('supply-policy', 'the generator resolves a command through a session-state lookup API');
  }
  if (/\b(?:Set-Variable|New-Variable|Get-Variable|Clear-Variable|Remove-Variable|Set-Item|New-Item)\b|Variable:|PSVariable/iu.test(generatorCode)) {
    reject('supply-policy', 'the generator writes a variable through an indirect API');
  }

  const arrObservedQualified = [...generatorCode.matchAll(QUALIFIED_ASSIGNMENT)].map((match) => match[1] ?? match[2]);
  const arrRemainingQualified = [...REVIEWED_GENERATOR_QUALIFIED_ASSIGNMENTS];
  for (const target of arrObservedQualified) {
    const index = arrRemainingQualified.indexOf(target);
    if (index < 0) {
      reject('supply-policy', REVIEWED_GENERATOR_QUALIFIED_ASSIGNMENTS.includes(target)
        ? `the generator writes a reviewed qualified variable more than once: ${target}`
        : `the generator writes an unreviewed qualified variable: ${target}`);
    }
    arrRemainingQualified.splice(index, 1);
  }
  if (arrRemainingQualified.length > 0) {
    reject('supply-policy', `the generator no longer writes a reviewed qualified variable: ${arrRemainingQualified[0]}`);
  }

  for (const token of generatorCode.matchAll(GENERATOR_COMMAND_POSITION)) {
    if (!REVIEWED_GENERATOR_COMMANDS.includes(token[1])) {
      reject('supply-policy', `the generator runs an unreviewed command: ${token[1]}`);
    }
  }
  if (DOT_SOURCE.test(generatorCode)) {
    reject('supply-policy', 'the generator uses the dot-source invocation operator');
  }

  const projectedLines = generatorCode.split('\n');
  const rawLines = normalizeLineContinuations(source).split('\n');
  const observedInvocations = [];
  let lineStart = 0;
  for (let index = 0; index < projectedLines.length; index += 1) {
    const operatorAt = invocationOperatorOffset(projectedLines[index]);
    if (operatorAt >= 0) {
      observedInvocations.push([
        (rawLines[index] ?? '').trim(),
        powerShellBraceDepthAt(generatorCode, lineStart + operatorAt),
      ]);
    }
    lineStart += projectedLines[index].length + 1;
  }
  if (observedInvocations.length !== REVIEWED_GENERATOR_INVOCATIONS.length) {
    reject('supply-policy', 'the generator does not invoke through the call operator exactly where it was reviewed to');
  }
  for (let index = 0; index < REVIEWED_GENERATOR_INVOCATIONS.length; index += 1) {
    const [reviewedLine, reviewedDepth] = REVIEWED_GENERATOR_INVOCATIONS[index];
    const [observedLine, observedDepth] = observedInvocations[index];
    if (observedLine !== reviewedLine) {
      reject('supply-policy', `the generator makes an unreviewed invocation: ${observedLine}`);
    }
    if (observedDepth !== reviewedDepth) {
      reject('supply-policy', `a reviewed invocation is no longer reachable where it was reviewed: ${reviewedLine}`);
    }
  }

  for (const match of generatorCode.matchAll(/\breturn\b/gu)) {
    if (powerShellBraceDepthAt(generatorCode, match.index) === 0) {
      reject('supply-policy', 'the generator returns at the top level');
    }
  }

  const arrExitTokens = [...rawGeneratorCode.matchAll(/\bexit\b/gu)];
  if (arrExitTokens.length !== 1 ||
      powerShellBraceDepthAt(rawGeneratorCode, arrExitTokens[0].index) !== 0 ||
      source.slice(arrExitTokens[0].index, arrExitTokens[0].index + 'exit $intExitCode'.length) !== 'exit $intExitCode') {
    reject('supply-policy', 'the generator can terminate before the reviewed result');
  }

  const requiredFragments = Object.freeze([
    ['result schema', "$script:strGeneratorResultSchema = 'PSStyleGuide.GeneratorResult.v2'", 1],
    ['Git executable binding', '$strGitPath = [string]$arrGitCommands[0].Source', 1],
    ['tracked-destination authority', 'Assert-TrackedFile -RepositoryRoot $strRepositoryRoot -RepositoryPath $strRepositoryPath', 1],
    ['native Git status and exact path check', 'if ($intGitExit -ne 0 -or $arrOutput.Count -ne 1 -or $arrOutput[0] -cne $RepositoryPath) {', 1],
    ['fixed destination map', "    'powershell-instructions' = 'powershell.instructions.md'", 1],
    ['complete payload map', '$hashtablePayloads = New-StyleGuidePayloadMap', 1],
    ['ordered artifact records', '$listArtifactRecords.Add((New-ArtifactRecord', 1],
    ['existing-destination publication', '[PSStyleGuide.AtomicFileReplacement]::Replace($strTemporaryPath, $strDestinationPath)', 1],
    ['absent-destination publication', '[System.IO.File]::Move($strTemporaryPath, $strDestinationPath)', 1],
    ['unexpected-destination refusal', "throw 'unexpected-destination'", 3],
    ['candidate identity capture', '$strCandidateIdentity = Get-OrdinaryFileIdentity -LiteralPath $strCandidateFullPath', 1],
    ['culture-invariant rationale anchor', "$strAnchor = $strHeadingText.ToLowerInvariant() -replace '[^a-z0-9 -]', '' -replace ' ', '-'", 2],
    ['missing-rationale failure', 'throw "missing-rationale-anchor"', 1],
    ['BSD platform dispatch', 'if ($boolHostIsMacOS -or $boolHostIsFreeBsd) {', 1],
    ['bounded collision handling', "throw 'candidate-collision-limit'", 1],
    ['durable candidate flush', '$objCandidateStream.Flush($true)', 1],
    ['candidate byte verification', "throw 'candidate-byte-mismatch'", 1],
    ['pre-publication destination revalidation', "$strPhase = 'revalidate-publication'", 1],
    ['post-publication verification', "$strPhase = 'verify-publication'", 1],
    ['final candidate identity binding', 'if ($hashtableRecord.FinalOrdinaryIdentity -cne $strCandidateIdentity) {', 1],
    ['post-publication uncertainty', "$hashtableRecord.Status = 'ReplacementStateUncertain'", 3],
    ['identity-bound cleanup', 'if ((Get-OrdinaryFileIdentity -LiteralPath $strTemporaryPath) -cne $strCandidateIdentity) {', 1],
    ['candidate cleanup deletion', '[System.IO.File]::Delete($strTemporaryPath)', 1],
    ['failed pre-publication result', "$hashtableRecord.Status = 'Failed'", 1],
    ['truthful result serialization', 'Write-GeneratorResult -Result $hashtableResult', 2],
    ['in-memory helper state annotation', '[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(', 6],
  ]);
  for (const [label, fragment, expectedCount] of requiredFragments) {
    const count = source.split(fragment).length - 1;
    if (count !== expectedCount) {
      reject('supply-policy', `the generator does not preserve the reviewed ${label} assertion count`);
    }
  }

  const reviewedOrder = Object.freeze([
    ["$strResultPhase = 'validate-fixed-authority'", 1],
    ["$strResultPhase = 'compute-complete-payloads'", 1],
    ['$hashtablePayloads = New-StyleGuidePayloadMap', 1],
    ["$strResultPhase = 'replace-artifacts'", 1],
    ['foreach ($strArtifactId in $hashtableDestinationMap.Keys) {', 1],
    ['Write-GeneratorResult -Result $hashtableResult', 0],
    ['exit $intExitCode', 0],
  ]);
  let cursor = -1;
  for (const [fragment, expectedDepth] of reviewedOrder) {
    const index = source.indexOf(fragment, cursor + 1);
    if (index <= cursor || source.indexOf(fragment, index + 1) !== -1 ||
        powerShellBraceDepthAt(source, index) !== expectedDepth) {
      reject('supply-policy', `the generator does not preserve the reviewed transaction order: ${fragment}`);
    }
    cursor = index;
  }
  const reviewedTail = 'Write-GeneratorResult -Result $hashtableResult\nexit $intExitCode';
  if (source.trimEnd().slice(source.trimEnd().lastIndexOf('Write-GeneratorResult -Result $hashtableResult')) !== reviewedTail) {
    reject('supply-policy', 'the generator does not terminate immediately after the reviewed result');
  }

  assertPowerShellPrivateHelperHelp(
    source,
    REVIEWED_GENERATOR_HELP,
    REVIEWED_PS_GENERATOR_HELP_VERSIONS,
    'supply-policy',
    'the generator',
  );
  if (sha256(Buffer.from(source, 'utf8')) !== 'f3d5e8b68a516f048547aa17570d81501f7df53cde4c6a01212bc4e2d909bc1a') {
    reject('supply-policy', 'generator does not match its reviewed digest');
  }
}

function testGeneratorPolicyMutations(source) {
  const mutations = Object.freeze([
    [
      'PS-P1-GENERATOR-001',
      'BSD platform dispatch is disabled',
      '    if ($boolHostIsMacOS -or $boolHostIsFreeBsd) {',
      '    if ($boolHostIsLinux) {',
      'generator-source-BSD-platform-dispatch',
    ],
    [
      'PS-P1-GENERATOR-002',
      'published destination loses candidate identity binding',
      '        if ($hashtableRecord.FinalOrdinaryIdentity -cne $strCandidateIdentity) {',
      '        if ($false) {',
      'generator-source-final-candidate-identity-binding',
    ],
    [
      'PS-P1-GENERATOR-003',
      'rationale index returns to culture-sensitive casing',
      RATIONALE_INDEX_FRAGMENT,
      RATIONALE_INDEX_FRAGMENT.replace('.ToLowerInvariant()', '.ToLower()'),
      'generator-source-invariant-rationale-index',
    ],
    [
      'PS-P1-GENERATOR-004',
      'guide heading returns to culture-sensitive casing',
      GUIDE_HEADING_FRAGMENT,
      GUIDE_HEADING_FRAGMENT.replace('.ToLowerInvariant()', '.ToLower()'),
      'generator-source-invariant-guide-heading',
    ],
  ]);
  validateGeneratorPolicy(source);
  for (const [id, description, from, to, expectedCategory] of mutations) {
    const fixture = replaceGeneratorSourceOnce(source, from, to);
    let rejected = false;
    try {
      validateGeneratorPolicy(fixture);
    } catch (error) {
      if (error instanceof PolicyError && error.category === expectedCategory) {
        rejected = true;
      } else {
        throw error;
      }
    }
    if (!rejected) {
      fail(`generator-mutation-${id}-${description}`);
    }
  }
  return mutations.length;
}

function validateGeneratorSource() {
  const source = readOrdinaryFile(
    path.join(SCRIPT_DIRECTORY, GENERATOR_FILE_NAME),
    262144,
    'generator-file',
  ).toString('utf8');
  validateGeneratorIsolationPolicy(source);
  return testGeneratorPolicyMutations(source);
}

function pointerParts(pointer) {
  if (typeof pointer !== 'string' || !pointer.startsWith('/')) fail('case-operation');
  const parts = pointer.slice(1).split('/').map((part) => part.replaceAll('~1', '/').replaceAll('~0', '~'));
  for (const part of parts) {
    if (FORBIDDEN_OBJECT_KEYS.has(part)) {
      fail('case-operation');
    }
  }
  return parts;
}

function getPointer(root, pointer) {
  let value = root;
  for (const part of pointerParts(pointer)) {
    if (value === null || typeof value !== 'object' || !Object.hasOwn(value, part)) {
      fail('case-operation');
    }
    value = value[part];
  }
  return value;
}

function getArrayPointer(root, pointer) {
  const value = getPointer(root, pointer);
  if (!Array.isArray(value)) {
    fail('case-operation');
  }
  return value;
}

function getPointerParent(root, pointer) {
  const parts = pointerParts(pointer);
  const key = parts.pop();
  let parent = root;
  for (const part of parts) {
    if (parent === null || typeof parent !== 'object' || !Object.hasOwn(parent, part)) {
      fail('case-operation');
    }
    parent = parent[part];
  }
  if (parent === null || typeof parent !== 'object') fail('case-operation');
  return { parent, key };
}

function applyTextOperation(text, operation) {
  if (operation === null || typeof operation !== 'object' || Array.isArray(operation)) fail('case-operation');
  const counted = operation.type === 'replace-count';
  expectExactKeys(operation, counted ? ['type', 'from', 'to', 'count'] : ['type', 'from', 'to'], 'case-operation');
  const count = counted ? operation.count : 1;
  if ((!counted && operation.type !== 'replace') || !Number.isInteger(count) || count < 1 || count > 32
    || typeof text !== 'string' || typeof operation.from !== 'string' || operation.from.length === 0
    || typeof operation.to !== 'string' || operation.from === operation.to
    || text.split(operation.from).length - 1 !== count) fail('case-operation');
  return text.split(operation.from).join(operation.to);
}

function applyGeneratorSourceOperation(source, operation) {
  if (typeof source !== 'string' || Buffer.byteLength(source, 'utf8') > 262144
    || operation === null || typeof operation !== 'object' || Array.isArray(operation)) fail('case-operation');
  let result;
  if (operation.type === 'append-text') {
    expectExactKeys(operation, ['type', 'text'], 'case-operation');
    if (typeof operation.text !== 'string' || operation.text.length === 0
      || Buffer.byteLength(operation.text, 'utf8') > 262144) fail('case-operation');
    result = source + operation.text;
  } else if (operation.type === 'truncate') {
    expectExactKeys(operation, ['type', 'length'], 'case-operation');
    if (!Number.isInteger(operation.length) || operation.length < 0 || operation.length >= source.length) fail('case-operation');
    result = source.slice(0, operation.length);
  } else {
    result = applyTextOperation(source, operation);
  }
  if (result === source || Buffer.byteLength(result, 'utf8') > 262144) fail('case-operation');
  return result;
}

function applyOperation(root, operation) {
  const { parent, key } = getPointerParent(root, operation.path);
  if (operation.type === 'set') {
    parent[key] = clone(operation.value);
  } else if (operation.type === 'delete') {
    delete parent[key];
  } else if (operation.type === 'append') {
    getArrayPointer(root, operation.path).push(clone(operation.value));
  } else if (operation.type === 'append-copy') {
    getArrayPointer(root, operation.path).push(clone(getPointer(root, operation.source)));
  } else if (operation.type === 'swap') {
    const other = getPointerParent(root, operation.otherPath);
    const temporary = parent[key];
    parent[key] = other.parent[other.key];
    other.parent[other.key] = temporary;
  } else if (operation.type === 'replace-count') {
    const { path: ignoredPath, ...textOperation } = operation;
    parent[key] = applyTextOperation(parent[key], textOperation);
  } else if (operation.type === 'replace') {
    if (
      typeof parent[key] !== 'string'
      || typeof operation.from !== 'string'
      || operation.from.length === 0
      || typeof operation.to !== 'string'
      || parent[key].split(operation.from).length - 1 !== 1
    ) {
      fail('case-operation');
    }
    parent[key] = parent[key].replace(operation.from, () => operation.to);
  } else {
    fail('case-operation');
  }
}

const INPUT_CASE_DOMAINS = Object.freeze(['text-bytes', 'script-version', 'package-object', 'package-text',
  'root-package', 'producer-contract', 'cli', 'lint-asset', 'npm-config', 'parser-tree']);

function prepareInputCase(testCase, contract) {
  const payloadKeys = {
    'text-bytes': ['hex'], 'script-version': ['text'], 'package-object': ['target', 'operation'],
    'package-text': ['operation'], 'root-package': ['operation'], 'producer-contract': ['operation'],
    cli: ['args'], 'lint-asset': ['target', 'text'], 'npm-config': ['presence'], 'parser-tree': ['nodes'],
  };
  expectExactKeys(testCase, ['id', 'semanticKey', 'sourceCase', 'domain', 'expected', 'expectedCategory',
    ...(testCase.expectedReason === undefined ? [] : ['expectedReason']), ...payloadKeys[testCase.domain]], 'case-catalog');
  const checkText = text => {
    if (typeof text !== 'string' || Buffer.byteLength(text, 'utf8') > 262144) fail('case-operation');
    return text;
  };
  const mutate = baseline => {
    if (testCase.operation === null || typeof testCase.operation !== 'object' || Array.isArray(testCase.operation)) fail('case-operation');
    // These fixed-input families need only set/delete. Do not accept arbitrary
    // pointers, operation shapes or an unchanged fixture as rejection evidence.
    expectExactKeys(testCase.operation, testCase.operation.type === 'set' ? ['type', 'path', 'value'] : ['type', 'path'], 'case-operation');
    if (!['set', 'delete'].includes(testCase.operation.type) || typeof testCase.operation.path !== 'string'
      || testCase.operation.path.length > 512) fail('case-operation');
    const before = canonicalJson(baseline), fixture = clone(baseline);
    applyOperation(fixture, testCase.operation);
    const after = canonicalJson(fixture);
    if (before === after || Buffer.byteLength(after, 'utf8') > 524288) fail('case-operation');
    return fixture;
  };
  if (testCase.domain === 'text-bytes') {
    if (typeof testCase.hex !== 'string' || testCase.hex.length > 1048576 || !/^(?:[0-9a-f]{2})*$/u.test(testCase.hex)) fail('case-operation');
    return Buffer.from(testCase.hex, 'hex');
  }
  if (testCase.domain === 'script-version') return checkText(testCase.text);
  if (testCase.domain === 'package-object' || testCase.domain === 'package-text') {
    const manifestBytes = readOrdinaryFile(path.join(SCRIPT_DIRECTORY, 'package.json'), 524288, 'package-file');
    const lockBytes = readOrdinaryFile(path.join(SCRIPT_DIRECTORY, 'package-lock.json'), 524288, 'lock-file');
    if (testCase.domain === 'package-text') {
      return { manifestBytes: Buffer.from(applyGeneratorSourceOperation(strictUtf8Text(manifestBytes, 'package-encoding'), testCase.operation)), lockBytes };
    }
    if (!['manifest', 'lock'].includes(testCase.target)) fail('case-operation');
    const inputs = { manifest: parseStrictJson(manifestBytes, contract.limits, 'package-json'),
      lock: parseStrictJson(lockBytes, contract.limits, 'package-lock-json') };
    inputs[testCase.target] = mutate(inputs[testCase.target]);
    return inputs;
  }
  if (testCase.domain === 'root-package') {
    return mutate(parseStrictJson(readOrdinaryFile(path.join(POLICY_ROOT, 'package.json'), 524288, 'package-file'), contract.limits, 'package-json'));
  }
  if (testCase.domain === 'producer-contract') return mutate(contract.supplyFreeze.producer);
  if (testCase.domain === 'cli') {
    if (!Array.isArray(testCase.args) || testCase.args.length > 8
      || testCase.args.some(arg => typeof arg !== 'string' || arg.length > 128)) fail('case-operation');
    return testCase.args;
  }
  if (testCase.domain === 'lint-asset') {
    if (!['lint-config', 'nested-linter'].includes(testCase.target)) fail('case-operation');
    return Buffer.from(checkText(testCase.text), 'utf8');
  }
  if (testCase.domain === 'npm-config') {
    if (!Array.isArray(testCase.presence) || testCase.presence.length !== 3 || testCase.presence.some(value => typeof value !== 'boolean')) fail('case-operation');
    return testCase.presence;
  }
  if (!Array.isArray(testCase.nodes) || testCase.nodes.length > 2) fail('case-operation');
  const seen = new Set();
  for (const node of testCase.nodes) {
    if (node === null || typeof node !== 'object' || Array.isArray(node)) fail('case-operation');
    expectExactKeys(node, node.kind === 'file' ? ['path', 'kind', 'text'] : ['path', 'kind'], 'case-operation');
    if (!['dist', 'dist/index.js'].includes(node.path) || seen.has(node.path)
      || !['directory', 'file', 'link'].includes(node.kind)) fail('case-operation');
    seen.add(node.path);
    if (node.kind === 'file') checkText(node.text);
  }
  return testCase.nodes;
}

function validateParserTreeFixture(nodes) {
  const root = path.resolve(SCRIPT_DIRECTORY, '__inert_parser_fixture__');
  const entries = new Map([[root, { kind: 'directory' }], ...nodes.map(node => [path.join(root, node.path), node])]);
  const reader = {
    names: directory => [...entries.keys()].filter(name => name !== root && path.dirname(name) === directory).map(name => path.basename(name)),
    stat(target) {
      const node = entries.get(target);
      if (!node) fail('parser-tree-file');
      return { isDirectory: () => node.kind === 'directory', isFile: () => node.kind === 'file',
        isSymbolicLink: () => node.kind === 'link', nlink: 1, size: Buffer.byteLength(node.text ?? '', 'utf8') };
    },
    bytes: target => Buffer.from(entries.get(target).text, 'utf8'),
  };
  assertReviewedParserTree(root, reader);
}

function validateInputCase(testCase, prepared, contract) {
  switch (testCase.domain) {
    case 'text-bytes': strictUtf8Text(prepared, 'text-encoding'); break;
    case 'script-version': validateScriptVersionText(prepared, contract.scriptVersions.generator.version); break;
    case 'package-object': validatePackageObjects(prepared.manifest, prepared.lock, contract); break;
    case 'package-text':
      validatePackageObjects(parseStrictJson(prepared.manifestBytes, contract.limits, 'package-json'), parseStrictJson(prepared.lockBytes, contract.limits, 'package-lock-json'), contract);
      validatePackageBytePair(prepared.manifestBytes, prepared.lockBytes, contract); break;
    case 'root-package': validateRootToolchain(prepared); break;
    case 'producer-contract': validateProducerToolchain(prepared); break;
    case 'cli': validateArguments(prepared); break;
    case 'lint-asset': validateLintAsset(testCase.target, prepared); break;
    case 'npm-config': validateNpmConfigPresence(prepared); break;
    case 'parser-tree': validateParserTreeFixture(prepared); break;
    default: fail('case-catalog');
  }
}

function runCatalogCase(testCase, workflows, dependabot, contract) {
  if (testCase === null || typeof testCase !== 'object' || Array.isArray(testCase)) fail('case-catalog');
  // Category-qualified cases must prepare successfully. A bad pointer or
  // absent replacement needle cannot count as the intended policy rejection.
  let preparedWorkflow;
  let preparedWorkflowText;
  let preparedGenerator;
  let preparedDependabot;
  const isInputCase = INPUT_CASE_DOMAINS.includes(testCase.domain);
  if ((isInputCase || testCase.domain === 'generator-source')
    && (typeof testCase.sourceCase !== 'string' || !/^[A-Z][A-Z0-9-]{2,95}$/u.test(testCase.sourceCase))) fail('case-catalog');
  const preparedInput = isInputCase ? prepareInputCase(testCase, contract) : undefined;
  if (testCase.domain === 'dependabot' && testCase.expectedCategory !== undefined) {
    preparedDependabot = clone(dependabot);
    applyOperation(preparedDependabot, testCase.operation);
    if (canonicalJson(preparedDependabot) === canonicalJson(dependabot)) fail('case-operation');
  }
  if (testCase.domain === 'generator-source') {
    expectExactKeys(testCase, ['id', 'semanticKey', 'sourceCase', 'domain', 'operation', 'expected', 'expectedCategory',
      ...(testCase.expectedReason === undefined ? [] : ['expectedReason'])], 'case-catalog');
    const source = readOrdinaryFile(path.join(SCRIPT_DIRECTORY, GENERATOR_FILE_NAME), 262144, 'generator-file').toString('utf8');
    preparedGenerator = applyGeneratorSourceOperation(source, testCase.operation);
  }
  if (testCase.domain === 'workflow-text') {
    if (!['build.yml', 'markdownlint.yml', 'pull-request-body-identity.yml'].includes(testCase.workflow)
      || !Object.hasOwn(workflows, testCase.workflow)) fail('case-catalog');
    preparedWorkflowText = applyTextOperation(workflows[testCase.workflow].text, testCase.operation);
  }
  if (testCase.expectedCategory !== undefined) {
    if (
      !['workflow', 'workflow-text', 'generator-source', 'parser', 'dependabot', ...INPUT_CASE_DOMAINS].includes(testCase.domain)
      || testCase.expected !== false
      || typeof testCase.expectedCategory !== 'string'
      || !/^[A-Za-z0-9-]+$/u.test(testCase.expectedCategory)
    ) fail('case-category');
    if (testCase.domain === 'workflow') {
      preparedWorkflow = clone(workflows[testCase.workflow].value);
      applyOperation(preparedWorkflow, testCase.operation);
    }
  }
  let observed = true;
  let observedCategory;
  let observedReason;
  try {
    if (isInputCase) {
      validateInputCase(testCase, preparedInput, contract);
    } else if (testCase.domain === 'baseline') {
      for (const [fileName, workflow] of Object.entries(workflows)) {
        validateWorkflowObject(fileName, workflow.value, workflow.text, contract);
      }
      validateDependabot(dependabot, contract);
    } else if (testCase.domain === 'workflow') {
      const fixture = preparedWorkflow ?? clone(workflows[testCase.workflow].value);
      if (preparedWorkflow === undefined) applyOperation(fixture, testCase.operation);
      validateWorkflowObject(testCase.workflow, fixture, null, contract);
    } else if (testCase.domain === 'workflow-text') {
      const fixture = parseStrictYaml(Buffer.from(preparedWorkflowText, 'utf8'), contract.limits);
      validateWorkflowObject(testCase.workflow, fixture.value, preparedWorkflowText, contract);
    } else if (testCase.domain === 'generator-source') {
      validateGeneratorIsolationPolicy(preparedGenerator);
      validateGeneratorPolicy(preparedGenerator);
    } else if (testCase.domain === 'contract') {
      const fixture = clone(contract);
      applyOperation(fixture, testCase.operation);
      validateContract(fixture);
    } else if (testCase.domain === 'markdown-contract') {
      const fixture = clone(contract.markdownPolicy);
      applyOperation(fixture, testCase.operation);
      validateMarkdownContract(fixture);
    } else if (testCase.domain === 'dependabot') {
      const fixture = preparedDependabot ?? clone(dependabot);
      if (preparedDependabot === undefined) applyOperation(fixture, testCase.operation);
      validateDependabot(fixture, contract);
    } else if (testCase.domain === 'parser') {
      parseStrictYaml(Buffer.from(testCase.text, 'utf8'), contract.limits);
    } else {
      fail('case-catalog');
    }
  } catch (error) {
    if (!(error instanceof PolicyError)) throw error;
    observed = false;
    observedCategory = error.category;
    observedReason = error.reason;
  }
  if (observed !== testCase.expected) fail('case-result');
  if (testCase.expectedCategory !== undefined && observedCategory !== testCase.expectedCategory) {
    fail('case-category-result');
  }
  if (testCase.expectedReason !== undefined && (
    typeof testCase.expectedReason !== 'string' || testCase.expectedReason.length === 0
    || testCase.expectedReason.length > 2048 || testCase.expectedCategory === undefined
    || observedReason !== testCase.expectedReason
  )) fail('case-reason-result');
}

function runCaseCatalog(catalog, workflows, dependabot, contract) {
  expectExactKeys(catalog, ['schema', 'cases'], 'case-catalog');
  if (catalog.schema !== 'PSStyleGuide.WorkflowPolicyCases.v1' || !Array.isArray(catalog.cases)) {
    fail('case-catalog');
  }
  const ids = new Set();
  const semanticKeys = new Set();
  let identityCases = 0;
  let passed = 0;
  for (const testCase of catalog.cases) {
    if (testCase === null || typeof testCase !== 'object' || Array.isArray(testCase)) fail('case-catalog');
    if (
      typeof testCase.id !== 'string'
      || !/^PS-P1-(?:WFPOL|IDPOL)-[0-9]{3}$/u.test(testCase.id)
      || ids.has(testCase.id)
      || typeof testCase.semanticKey !== 'string'
      || !/^[a-z0-9-]+$/u.test(testCase.semanticKey)
      || semanticKeys.has(testCase.semanticKey)
      || typeof testCase.expected !== 'boolean'
    ) {
      fail('case-catalog');
    }
    ids.add(testCase.id);
    semanticKeys.add(testCase.semanticKey);
    if (testCase.id.startsWith('PS-P1-IDPOL-')) {
      identityCases += 1;
    }
    if (INPUT_CASE_DOMAINS.includes(testCase.domain)) {
      // Closed fields, types and fixed targets are checked before observation.
    } else if (testCase.domain === 'workflow' || testCase.domain === 'workflow-text') {
      if (
        typeof testCase.workflow !== 'string'
        || !Object.hasOwn(workflows, testCase.workflow)
        || testCase.operation === null
        || typeof testCase.operation !== 'object'
      ) {
        fail('case-catalog');
      }
    } else if (
      testCase.domain === 'contract'
      || testCase.domain === 'markdown-contract'
      || testCase.domain === 'dependabot'
      || testCase.domain === 'generator-source'
    ) {
      if (testCase.operation === null || typeof testCase.operation !== 'object') {
        fail('case-catalog');
      }
    } else if (testCase.domain === 'parser') {
      if (typeof testCase.text !== 'string') {
        fail('case-catalog');
      }
    } else if (testCase.domain !== 'baseline') {
      fail('case-catalog');
    }
    runCatalogCase(testCase, workflows, dependabot, contract);
    passed += 1;
  }
  if (passed < MINIMUM_CASE_COUNT || identityCases !== REQUIRED_IDENTITY_CASE_COUNT) {
    fail('case-catalog');
  }
  return passed;
}

// Only the digest-authenticated catalog may retain historical setup-error
// tests. New ordinary cases must finish mutation before policy rejection can
// count as their expected negative result. Do not infer that stage from an
// error category: categories can be shared or extended by future validators.
function validateOrdinaryCasePreparation(catalog, trustedCatalog, workflows) {
  expectExactKeys(catalog, ['schema', 'cases'], 'case-catalog');
  if (
    catalog.schema !== trustedCatalog.schema
    || !Array.isArray(catalog.cases)
    || catalog.cases.length < trustedCatalog.cases.length
  ) {
    fail('ordinary-case-prefix');
  }
  for (let index = 0; index < trustedCatalog.cases.length; index += 1) {
    if (canonicalJson(catalog.cases[index]) !== canonicalJson(trustedCatalog.cases[index])) {
      fail('ordinary-case-prefix');
    }
  }
  for (const testCase of catalog.cases.slice(trustedCatalog.cases.length)) {
    if (
      testCase === null
      || typeof testCase !== 'object'
      || Array.isArray(testCase)
      || testCase.domain !== 'workflow'
      || testCase.expected !== false
      || typeof testCase.workflow !== 'string'
      || !Object.hasOwn(workflows, testCase.workflow)
      || testCase.operation === null
      || typeof testCase.operation !== 'object'
      || Array.isArray(testCase.operation)
    ) {
      fail('ordinary-case-shape');
    }
    applyOperation(clone(workflows[testCase.workflow].value), testCase.operation);
  }
}

function testOrdinaryCasePreparation(catalog, workflows, dependabot, contract) {
  const nextNumber = Math.max(...catalog.cases
    .filter((testCase) => testCase.id.startsWith('PS-P1-WFPOL-'))
    .map((testCase) => Number(testCase.id.slice(-3)))) + 1;
  const existingKeys = new Set(catalog.cases.map((testCase) => testCase.semanticKey));
  let semanticKey = 'ordinary-preparation-self-test';
  for (let suffix = 0; existingKeys.has(semanticKey); suffix += 1) {
    semanticKey = `ordinary-preparation-self-test-${suffix}`;
  }
  const negative = {
    id: `PS-P1-WFPOL-${String(nextNumber).padStart(3, '0')}`,
    semanticKey,
    domain: 'workflow',
    workflow: 'build.yml',
    operation: { type: 'set', path: '/permissions', value: { contents: 'write' } },
    expected: false,
  };
  const append = (testCase) => ({ ...catalog, cases: [...catalog.cases, testCase] });
  const reject = (candidate, category, runOutcomes = false) => {
    try {
      validateOrdinaryCasePreparation(candidate, catalog, workflows);
      if (runOutcomes) runCatalogCase(candidate.cases.at(-1), workflows, dependabot, contract);
    } catch (error) {
      if (error instanceof PolicyError && error.category === category) return;
      throw error;
    }
    fail('ordinary-case-self-test');
  };
  validateOrdinaryCasePreparation(catalog, catalog, workflows);
  validateOrdinaryCasePreparation(append(negative), catalog, workflows);
  runCatalogCase(negative, workflows, dependabot, contract);
  for (const operation of [
    { type: 'replace', path: '/name', from: 'THIS_NEEDLE_IS_ABSENT', to: 'changed' },
    { type: 'replace', path: '/name', from: ' ', to: '-' },
    { type: 'append', path: '/name', value: 'extra' },
    { type: 'append', path: '/missing-array', value: 'extra' },
  ]) {
    reject(append({ ...negative, operation }), 'case-operation');
  }
  reject({ ...catalog, cases: catalog.cases.slice(1) }, 'ordinary-case-prefix');
  const changedPrefix = clone(catalog);
  changedPrefix.cases[0].expected = !changedPrefix.cases[0].expected;
  reject(changedPrefix, 'ordinary-case-prefix');
  const reorderedPrefix = clone(catalog);
  [reorderedPrefix.cases[0], reorderedPrefix.cases[1]] = [reorderedPrefix.cases[1], reorderedPrefix.cases[0]];
  reject(reorderedPrefix, 'ordinary-case-prefix');
  for (const domain of ['contract', 'markdown-contract', 'dependabot']) {
    reject(append({ ...negative, domain }), 'ordinary-case-shape');
  }
  reject(append({ ...negative, expected: true }), 'ordinary-case-shape');
  reject(append({ ...negative, operation: {
    type: 'set', path: '/name', value: workflows['build.yml'].value.name,
  } }), 'case-result', true);
}

function validateArguments(args = process.argv.slice(2)) {
  if (canonicalJson(args) !== canonicalJson(REQUIRED_ARGUMENTS)) {
    fail('arguments');
  }
}

async function main() {
  validateArguments();
  // Authenticate the contract and this validator before importing any installed
  // package, so third-party code never runs against an unverified tree.
  const bootstrapContract = readContractWithoutDependencies();
  verifyValidatorIdentity(bootstrapContract);
  // The package digests must be authenticated before the deferred import, not
  // merely before validatePackageTuple(). Importing yaml executes whatever is
  // installed, so checking the tuple afterwards would reject a substituted
  // graph only after its code had already run.
  verifyPackageDigests(bootstrapContract);
  await loadYamlBindings();
  const contractBytes = readOrdinaryFile(
    path.join(SCRIPT_DIRECTORY, 'workflow-policy-contract.json'),
    524288,
    'contract-file',
  );
  const bootstrapLimits = {
    maximumWorkflowBytes: 131072,
    maximumJsonBytes: 524288,
    maximumNodes: 5000,
    maximumDepth: 32,
  };
  const contract = parseStrictJson(contractBytes, bootstrapLimits, 'contract-json');
  validateContract(contract);
  verifyValidatorIdentity(contract);
  const caseCatalogBytes = readOrdinaryFile(
    path.join(SCRIPT_DIRECTORY, CASE_CATALOG_FILE_NAME),
    contract.limits.maximumJsonBytes,
    'case-file',
  );
  if (sha256(caseCatalogBytes) !== contract.caseCatalog.sha256) {
    fail('case-catalog-identity');
  }
  const catalog = parseStrictJson(caseCatalogBytes, caseCatalogLimits(contract), 'case-json');

  const workflows = {};
  for (const fileName of WORKFLOW_FILE_NAMES) {
    const filePath = path.resolve(process.cwd(), fileName);
    if (filePath !== path.join(SCRIPT_DIRECTORY, fileName)) {
      fail('workflow-path');
    }
    workflows[fileName] = parseStrictYaml(
      readOrdinaryFile(filePath, contract.limits.maximumWorkflowBytes, 'workflow-file'),
      contract.limits,
    );
    const sourceDigestVariable = {
      'build.yml': 'P1_EXPECTED_BUILD_DIGEST',
      'markdownlint.yml': 'P1_EXPECTED_MARKDOWN_DIGEST',
    }[fileName];
    if (sourceDigestVariable !== undefined && process.env[sourceDigestVariable] !== undefined) {
      const expectedDigest = process.env[sourceDigestVariable];
      if (!/^[0-9A-Fa-f]{64}$/u.test(expectedDigest)
        || sha256(Buffer.from(workflows[fileName].text, 'utf8')) !== expectedDigest.toLowerCase()) {
        fail('workflow-source-baseline');
      }
    }
    validateWorkflowObject(fileName, workflows[fileName].value, workflows[fileName].text, contract);
  }

  const dependabotPath = path.resolve(SCRIPT_DIRECTORY, '..', 'dependabot.yml');
  const dependabot = parseStrictYaml(
    readOrdinaryFile(dependabotPath, contract.limits.maximumWorkflowBytes, 'dependabot-file'),
    contract.limits,
  ).value;
  validateDependabot(dependabot, contract);
  validatePackageTuple(contract);
  validateMarkdownEntryPoints(contract);
  const generatorSourceMutationsPassed = validateGeneratorSource();
  validateScriptVersions(contract);
  testOrdinaryCasePreparation(catalog, workflows, dependabot, contract);
  const passedCases = runCaseCatalog(catalog, workflows, dependabot, contract);

  return {
    schema: RESULT_SCHEMA,
    validatorVersion: VALIDATOR_VERSION,
    success: true,
    contractCanonicalSha256: sha256(canonicalJson(contractIdentityView(contract))),
    casesPassed: passedCases,
    generatorSourceMutationsPassed,
    workflowSha256: Object.fromEntries(
      WORKFLOW_FILE_NAMES.map((fileName) => [fileName, sha256(Buffer.from(workflows[fileName].text, 'utf8'))]),
    ),
  };
}

// This mode is invoked only after the trusted authorizer binds the exact
// candidate catalog and fixed-rule tuple. stdin contains inert JSON, never a
// module path. It validates outcomes with this trusted revision's rules and
// workflow objects; success is not independent review or merge approval.
function readOrdinaryCaseInput(maximumBytes) {
  return new Promise((resolve, reject) => {
    const bytes = Buffer.alloc(maximumBytes);
    let length = 0;
    let settled = false;
    const finish = (error) => {
      if (settled) return;
      settled = true;
      clearTimeout(timer);
      process.stdin.removeListener('data', onData);
      process.stdin.removeListener('end', onEnd);
      process.stdin.removeListener('error', onError);
      process.stdin.pause();
      if (error) reject(error);
      else resolve(bytes.subarray(0, length));
    };
    const onData = (chunk) => {
      if (chunk.length > maximumBytes - length) {
        finish(new PolicyError('case-file'));
        return;
      }
      chunk.copy(bytes, length);
      length += chunk.length;
    };
    const onEnd = () => finish();
    const onError = () => finish(new PolicyError('case-input'));
    const timer = setTimeout(() => finish(new PolicyError('case-input-timeout')), 30000);
    process.stdin.on('data', onData);
    process.stdin.once('end', onEnd);
    process.stdin.once('error', onError);
  });
}

async function validateOrdinaryCaseData() {
  const contract = readContractWithoutDependencies();
  verifyValidatorIdentity(contract);
  verifyPackageDigests(contract);
  await loadYamlBindings();
  const bytes = await readOrdinaryCaseInput(contract.limits.maximumJsonBytes);
  const catalog = parseStrictJson(bytes, caseCatalogLimits(contract), 'case-json');
  const workflows = {};
  for (const fileName of WORKFLOW_FILE_NAMES) {
    const workflow = parseStrictYaml(readOrdinaryFile(
      path.join(SCRIPT_DIRECTORY, fileName),
      contract.limits.maximumWorkflowBytes,
      'workflow-file',
    ), contract.limits);
    validateWorkflowObject(fileName, workflow.value, workflow.text, contract);
    workflows[fileName] = workflow;
  }
  const dependabot = parseStrictYaml(readOrdinaryFile(
    path.join(SCRIPT_DIRECTORY, '..', 'dependabot.yml'),
    contract.limits.maximumWorkflowBytes,
    'dependabot-file',
  ), contract.limits).value;
  validateContract(contract);
  // New fixed-input catalog families read these trusted baseline bytes too.
  // Authenticate them in this consumer, not only in the full product command.
  validateScriptVersions(contract);
  readMarkdownEntryPoint(contract.markdownPolicy.entryPoints.rootPackageJson, contract);
  const trustedCaseBytes = readOrdinaryFile(
    path.join(SCRIPT_DIRECTORY, CASE_CATALOG_FILE_NAME),
    contract.limits.maximumJsonBytes,
    'case-file',
  );
  if (sha256(trustedCaseBytes) !== contract.caseCatalog.sha256) {
    fail('case-catalog-identity');
  }
  const trustedCatalog = parseStrictJson(trustedCaseBytes, caseCatalogLimits(contract), 'case-json');
  validateOrdinaryCasePreparation(catalog, trustedCatalog, workflows);
  const casesPassed = runCaseCatalog(catalog, workflows, dependabot, contract);
  return {
    schema: 'PSStyleGuide.OrdinaryCaseDataResult.v1',
    success: true,
    catalogSha256: sha256(bytes),
    casesPassed,
    mergeApproval: false,
  };
}

const isPreflight = canonicalJson(process.argv.slice(2)) === canonicalJson(PREFLIGHT_ARGUMENTS);
const isOrdinaryCaseData = canonicalJson(process.argv.slice(2))
  === canonicalJson(['--ordinary-case-catalog-data']);

try {
  const result = isPreflight ? preflight()
    : isOrdinaryCaseData ? await validateOrdinaryCaseData() : await main();
  process.stdout.write(`${JSON.stringify(result)}\n`);
} catch (error) {
  const category = error instanceof PolicyError ? error.category : 'tool-failure';
  process.stdout.write(`${JSON.stringify({
    schema: isPreflight ? PREFLIGHT_SCHEMA : RESULT_SCHEMA,
    validatorVersion: VALIDATOR_VERSION,
    success: false,
    category,
  })}\n`);
  process.exitCode = 1;
}
