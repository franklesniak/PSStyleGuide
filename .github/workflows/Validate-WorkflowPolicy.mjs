import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';

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
  ({
    isAlias,
    isMap,
    isScalar,
    isSeq,
    parseAllDocuments,
  } = await import('yaml'));
}

const VALIDATOR_VERSION = '1.0.0';
const RESULT_SCHEMA = 'PSStyleGuide.WorkflowPolicyResult.v1';
const PREFLIGHT_SCHEMA = 'PSStyleGuide.WorkflowPreflightResult.v1';
const PREFLIGHT_ARGUMENTS = ['--preflight'];
const EXPECTED_CONTRACT_CANONICAL_SHA256 = '6a246f0a9fbefc39ab86e37fa64a78577255d703fcee60ebac439ad80e131b0e';
const MINIMUM_CASE_COUNT = 46;
const CASE_CATALOG_FILE_NAME = 'workflow-policy-cases.json';
const VALIDATOR_FILE_NAME = 'Validate-WorkflowPolicy.mjs';
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
// Every input the validator reads lives under .github/, so that directory is the
// containment boundary for readOrdinaryFile().
const POLICY_ROOT = path.resolve(SCRIPT_DIRECTORY, '..');
const REQUIRED_ARGUMENTS = ['build.yml', 'markdownlint.yml'];
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
  constructor(category) {
    super(category);
    this.name = 'PolicyError';
    this.category = category;
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
  const text = bytes.toString('utf8');
  if (Buffer.from(text, 'utf8').compare(bytes) !== 0 || text.charCodeAt(0) === 0xfeff) {
    fail('yaml-encoding');
  }
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
    'dependabot',
    'reciprocalFoundation',
  ], 'contract-shape');
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
    || contract.supplyFreeze.producer.nodeVersion !== '24.18.1'
    || contract.supplyFreeze.producer.npmVersion !== '11.16.0'
    || contract.supplyFreeze.yaml.version !== '2.9.0'
    || contract.supplyFreeze.advisoryDecision.producerAudit.vulnerabilities.high !== 5
    || contract.supplyFreeze.advisoryDecision.producerAudit.vulnerabilities.moderate !== 2
    || contract.supplyFreeze.advisoryDecision.producerAudit.vulnerabilities.critical !== 0
  ) {
    fail('supply-freeze');
  }
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

function validateRunStep(step, expectedStep, contract) {
  const expectedKeys = ['name', 'shell', 'run'];
  if (expectedStep.id !== undefined) expectedKeys.push('id');
  if (expectedStep.workingDirectory !== undefined) expectedKeys.push('working-directory');
  if (expectedStep.if !== undefined) expectedKeys.push('if');
  if (expectedStep.continueOnError !== undefined) expectedKeys.push('continue-on-error');
  expectExactKeys(step, expectedKeys, 'run-step-shape');
  if (
    step.name !== expectedStep.name
    || step.id !== expectedStep.id
    || step.shell !== expectedStep.shell
    || step['working-directory'] !== expectedStep.workingDirectory
    || step.if !== expectedStep.if
    || step['continue-on-error'] !== expectedStep.continueOnError
    || sha256(Buffer.from(step.run, 'utf8')) !== expectedStep.runSha256
  ) {
    fail('run-role');
  }
  for (const pattern of contract.workflowPolicy.forbiddenRunPatterns) {
    if (new RegExp(pattern, 'iu').test(step.run)) {
      fail('forbidden-side-effect');
    }
  }
}

function validateWorkflowObject(fileName, workflow, rawText, contract) {
  expectExactKeys(workflow, ['name', 'on', 'permissions', 'jobs'], 'workflow-shape');
  const expectedWorkflow = contract.workflowPolicy.workflows[fileName];
  if (workflow.name !== expectedWorkflow.name) {
    fail('workflow-name');
  }
  expectDeepEqual(workflow.on, contract.workflowPolicy.events, 'workflow-events');
  expectDeepEqual(workflow.permissions, contract.workflowPolicy.workflowPermissions, 'workflow-permissions');
  expectExactKeys(workflow.jobs, Object.keys(expectedWorkflow.jobs), 'workflow-jobs');

  let observedUses = 0;
  for (const [jobId, expectedJob] of Object.entries(expectedWorkflow.jobs)) {
    const job = workflow.jobs[jobId];
    expectExactKeys(job, ['runs-on', 'permissions', 'steps'], 'job-shape');
    if (job['runs-on'] !== expectedJob.runsOn) {
      fail('job-runner');
    }
    expectDeepEqual(job.permissions, expectedJob.permissions, 'job-permissions');
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
        validateRunStep(step, expectedStep, contract);
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
}

function validateDependabot(value, contract) {
  expectDeepEqual(value, contract.dependabot, 'dependabot-policy');
  expectExactKeys(value, ['version', 'updates'], 'dependabot-policy');
  expectExactKeys(value.updates[0], ['package-ecosystem', 'directory', 'schedule'], 'dependabot-policy');
  expectExactKeys(value.updates[0].schedule, ['interval'], 'dependabot-policy');
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
  if (
    sha256(packageJsonBytes) !== contract.supplyFreeze.reviewedWorkingBytes.packageJson.sha256
    || sha256(packageLockBytes) !== contract.supplyFreeze.reviewedWorkingBytes.packageLockJson.sha256
  ) {
    fail('package-graph');
  }
  return { packageJsonBytes, packageLockBytes };
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
  const text = bytes.toString('utf8');
  if (Buffer.from(text, 'utf8').compare(bytes) !== 0 || text.charCodeAt(0) === 0xfeff) {
    fail('contract-encoding');
  }
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
  expectDeepEqual(packageJson.devDependencies, {
    glob: '^10.3.10',
    husky: '^9.1.7',
    'markdown-it': '^14.0.0',
    markdownlint: '^0.40.0',
    'markdownlint-cli2': '^0.20.0',
    yaml: '2.9.0',
  }, 'package-graph');
  if (
    packageLock.lockfileVersion !== 3
    || packageLock.packages?.['']?.devDependencies?.yaml !== '2.9.0'
    || packageLock.packages?.['node_modules/yaml']?.version !== '2.9.0'
    || packageLock.packages?.['node_modules/yaml']?.resolved !== contract.supplyFreeze.yaml.tarball
    || packageLock.packages?.['node_modules/yaml']?.integrity !== contract.supplyFreeze.yaml.integrity
  ) {
    fail('package-graph');
  }
}

function validateScriptVersions(contract) {
  for (const scriptPolicy of Object.values(contract.scriptVersions)) {
    const bytes = readOrdinaryFile(path.join(SCRIPT_DIRECTORY, scriptPolicy.path), 262144, 'script-file');
    if (sha256(bytes) !== scriptPolicy.sha256) {
      fail('script-identity');
    }
    const markers = bytes.toString('utf8').match(/^Version: ([0-9]+\.[0-9]+\.[0-9]{8}\.[0-9]+)$/gmu) ?? [];
    if (markers.length !== 1 || markers[0] !== `Version: ${scriptPolicy.version}`) {
      fail('script-version');
    }
  }
}

function pointerParts(pointer) {
  if (!pointer.startsWith('/')) fail('case-operation');
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
  return { parent, key };
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
  } else {
    fail('case-operation');
  }
}

function runCaseCatalog(catalog, workflows, dependabot, contract) {
  expectExactKeys(catalog, ['schema', 'cases'], 'case-catalog');
  if (catalog.schema !== 'PSStyleGuide.WorkflowPolicyCases.v1' || !Array.isArray(catalog.cases)) {
    fail('case-catalog');
  }
  const ids = new Set();
  const semanticKeys = new Set();
  let passed = 0;
  for (const testCase of catalog.cases) {
    if (
      typeof testCase.id !== 'string'
      || !/^PS-P1-WFPOL-[0-9]{3}$/u.test(testCase.id)
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
    if (testCase.domain === 'workflow') {
      if (
        typeof testCase.workflow !== 'string'
        || !Object.hasOwn(workflows, testCase.workflow)
        || testCase.operation === null
        || typeof testCase.operation !== 'object'
      ) {
        fail('case-catalog');
      }
    } else if (testCase.domain === 'contract' || testCase.domain === 'dependabot') {
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
    let observed = true;
    try {
      if (testCase.domain === 'baseline') {
        for (const [fileName, workflow] of Object.entries(workflows)) {
          validateWorkflowObject(fileName, workflow.value, workflow.text, contract);
        }
        validateDependabot(dependabot, contract);
      } else if (testCase.domain === 'workflow') {
        const fixture = clone(workflows[testCase.workflow].value);
        applyOperation(fixture, testCase.operation);
        validateWorkflowObject(testCase.workflow, fixture, null, contract);
      } else if (testCase.domain === 'contract') {
        const fixture = clone(contract);
        applyOperation(fixture, testCase.operation);
        validateContract(fixture);
      } else if (testCase.domain === 'dependabot') {
        const fixture = clone(dependabot);
        applyOperation(fixture, testCase.operation);
        validateDependabot(fixture, contract);
      } else {
        parseStrictYaml(Buffer.from(testCase.text, 'utf8'), contract.limits);
      }
    } catch (error) {
      if (!(error instanceof PolicyError)) throw error;
      observed = false;
    }
    if (observed !== testCase.expected) {
      fail('case-result');
    }
    passed += 1;
  }
  if (passed < MINIMUM_CASE_COUNT) {
    fail('case-catalog');
  }
  return passed;
}

function validateArguments() {
  const args = process.argv.slice(2);
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
  const catalog = parseStrictJson(caseCatalogBytes, contract.limits, 'case-json');

  const workflows = {};
  for (const fileName of REQUIRED_ARGUMENTS) {
    const filePath = path.resolve(process.cwd(), fileName);
    if (filePath !== path.join(SCRIPT_DIRECTORY, fileName)) {
      fail('workflow-path');
    }
    workflows[fileName] = parseStrictYaml(
      readOrdinaryFile(filePath, contract.limits.maximumWorkflowBytes, 'workflow-file'),
      contract.limits,
    );
    validateWorkflowObject(fileName, workflows[fileName].value, workflows[fileName].text, contract);
  }

  const dependabotPath = path.resolve(SCRIPT_DIRECTORY, '..', 'dependabot.yml');
  const dependabot = parseStrictYaml(
    readOrdinaryFile(dependabotPath, contract.limits.maximumWorkflowBytes, 'dependabot-file'),
    contract.limits,
  ).value;
  validateDependabot(dependabot, contract);
  validatePackageTuple(contract);
  validateScriptVersions(contract);
  const passedCases = runCaseCatalog(catalog, workflows, dependabot, contract);

  return {
    schema: RESULT_SCHEMA,
    validatorVersion: VALIDATOR_VERSION,
    success: true,
    contractCanonicalSha256: sha256(canonicalJson(contractIdentityView(contract))),
    casesPassed: passedCases,
    workflowSha256: Object.fromEntries(
      REQUIRED_ARGUMENTS.map((fileName) => [fileName, sha256(Buffer.from(workflows[fileName].text, 'utf8'))]),
    ),
  };
}

const isPreflight = canonicalJson(process.argv.slice(2)) === canonicalJson(PREFLIGHT_ARGUMENTS);

try {
  process.stdout.write(`${JSON.stringify(isPreflight ? preflight() : await main())}\n`);
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
