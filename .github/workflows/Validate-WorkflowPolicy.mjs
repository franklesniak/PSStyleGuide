import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';
import {
  isAlias,
  isMap,
  isScalar,
  isSeq,
  parseAllDocuments,
} from 'yaml';

const VALIDATOR_VERSION = '1.0.0';
const RESULT_SCHEMA = 'PSStyleGuide.WorkflowPolicyResult.v1';
const EXPECTED_CONTRACT_CANONICAL_SHA256 = 'fb886ede5a22c52e5e3b7d690fbb0fc6f02f26ba56bb22890dfd848081ad37e0';
const MINIMUM_CASE_COUNT = 46;
const SCRIPT_DIRECTORY = path.dirname(fileURLToPath(import.meta.url));
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

function readOrdinaryFile(filePath, maximumBytes, category) {
  const resolved = path.resolve(filePath);
  const stat = fs.lstatSync(resolved);
  if (!stat.isFile() || stat.isSymbolicLink() || stat.size > maximumBytes) {
    fail(category);
  }
  return fs.readFileSync(resolved);
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
      if (!isScalar(pair.key) || typeof pair.key.value !== 'string' || pair.key.value === '<<') {
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

function validateContract(contract) {
  if (sha256(canonicalJson(contract)) !== EXPECTED_CONTRACT_CANONICAL_SHA256) {
    fail('contract-identity');
  }
  expectExactKeys(contract, [
    'schema',
    'contractVersion',
    'limits',
    'supplyFreeze',
    'scriptVersions',
    'actions',
    'workflowPolicy',
    'dependabot',
    'reciprocalFoundation',
  ], 'contract-shape');
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
  ) {
    fail('supply-freeze');
  }
  if (new Date() > new Date(contract.supplyFreeze.advisoryDecision.expiresAtUtc)) {
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

function validatePackageTuple(contract) {
  const packageJsonBytes = readOrdinaryFile(path.join(SCRIPT_DIRECTORY, 'package.json'), contract.limits.maximumJsonBytes, 'package-file');
  const packageLockBytes = readOrdinaryFile(path.join(SCRIPT_DIRECTORY, 'package-lock.json'), contract.limits.maximumJsonBytes, 'lock-file');
  if (
    sha256(packageJsonBytes) !== contract.supplyFreeze.reviewedWorkingBytes.packageJson.sha256
    || sha256(packageLockBytes) !== contract.supplyFreeze.reviewedWorkingBytes.packageLockJson.sha256
  ) {
    fail('package-graph');
  }
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
    || packageLock.packages[''].devDependencies.yaml !== '2.9.0'
    || packageLock.packages['node_modules/yaml'].version !== '2.9.0'
    || packageLock.packages['node_modules/yaml'].resolved !== contract.supplyFreeze.yaml.tarball
    || packageLock.packages['node_modules/yaml'].integrity !== contract.supplyFreeze.yaml.integrity
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
  return pointer.slice(1).split('/').map((part) => part.replaceAll('~1', '/').replaceAll('~0', '~'));
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

function main() {
  validateArguments();
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
  const catalog = parseStrictJson(
    readOrdinaryFile(
      path.join(SCRIPT_DIRECTORY, 'workflow-policy-cases.json'),
      contract.limits.maximumJsonBytes,
      'case-file',
    ),
    contract.limits,
    'case-json',
  );

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
    contractCanonicalSha256: sha256(canonicalJson(contract)),
    casesPassed: passedCases,
    workflowSha256: Object.fromEntries(
      REQUIRED_ARGUMENTS.map((fileName) => [fileName, sha256(Buffer.from(workflows[fileName].text, 'utf8'))]),
    ),
  };
}

try {
  process.stdout.write(`${JSON.stringify(main())}\n`);
} catch (error) {
  const category = error instanceof PolicyError ? error.category : 'tool-failure';
  process.stdout.write(`${JSON.stringify({
    schema: RESULT_SCHEMA,
    validatorVersion: VALIDATOR_VERSION,
    success: false,
    category,
  })}\n`);
  process.exitCode = 1;
}
