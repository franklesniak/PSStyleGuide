#!/usr/bin/env node

import childProcess from 'node:child_process';
import crypto from 'node:crypto';
import fs from 'node:fs';
import https from 'node:https';
import os from 'node:os';
import path from 'node:path';
import { TextDecoder } from 'node:util';
import { fileURLToPath } from 'node:url';

const TOOL_VERSION = '1.0.20260912.2';
const RESULT_SCHEMA = 'PSStyleGuide.PullRequestBodyIdentityResult.v1';
const CASE_SCHEMA = 'PSStyleGuide.PullRequestBodyIdentityCases.v1';
const START_MARKER = '<!-- psstyleguide-pr-body-identity:start -->';
const END_MARKER = '<!-- psstyleguide-pr-body-identity:end -->';
const SCRIPT_DIRECTORY = path.dirname(fileURLToPath(import.meta.url));
const DEFAULT_REPOSITORY_ROOT = path.resolve(SCRIPT_DIRECTORY, '../..');
const CASE_CATALOG_PATH = path.join(
  SCRIPT_DIRECTORY,
  'pull-request-body-identity-cases.json',
);
const MAXIMUM_BODY_CHARACTERS = 65536;
const MAXIMUM_BODY_BYTES = 262144;
const MAXIMUM_EVENT_BYTES = 1048576;
const MAXIMUM_RESPONSE_BYTES = 1048576;
const MAXIMUM_CONTRACT_BYTES = 524288;
const MAXIMUM_GIT_OUTPUT_BYTES = 1048576;
const REQUEST_TIMEOUT_MILLISECONDS = 15000;
const API_VERSION = '2022-11-28';
const SHA1_PATTERN = /^[0-9a-f]{40}$/u;
const SHA256_PATTERN = /^[0-9a-f]{64}$/u;
const VERSION_PATTERN = /^[0-9]+\.[0-9]+\.[0-9]{8}\.[0-9]+$/u;
const REPOSITORY_PATTERN = /^(?!\.{1,2}\/)(?![A-Za-z0-9_.-]+\/\.{1,2}$)[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$/u;
const FORBIDDEN_KEYS = new Set(['__proto__', 'constructor', 'prototype']);
const SOURCE_PATHS = Object.freeze({
  generator: '.github/workflows/Generate-StyleGuideArtifacts.ps1',
  pathVerifier: '.github/workflows/Test-ExactGitPathSet.ps1',
  build: '.github/workflows/build.yml',
  contract: '.github/workflows/workflow-policy-contract.json',
  validator: '.github/workflows/Validate-WorkflowPolicy.mjs',
});
const SOURCE_LIMITS = Object.freeze({
  [SOURCE_PATHS.generator]: 262144,
  [SOURCE_PATHS.pathVerifier]: 524288,
  [SOURCE_PATHS.build]: 131072,
  [SOURCE_PATHS.contract]: MAXIMUM_CONTRACT_BYTES,
  [SOURCE_PATHS.validator]: 262144,
});

class IdentityError extends Error {
  constructor(category, disposition = 'failure') {
    super(category);
    this.name = 'IdentityError';
    this.category = category;
    this.disposition = disposition;
  }
}

function fail(category) {
  throw new IdentityError(category);
}

function uncertain(category) {
  throw new IdentityError(category, 'indeterminate');
}

function assert(condition, category) {
  if (!condition) fail(category);
}

function isRecord(value) {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

function hasExactKeys(value, expected) {
  return isRecord(value) && Object.keys(value).sort().join('\n') ===
    [...expected].sort().join('\n');
}

function sha256(value) {
  return crypto.createHash('sha256').update(value).digest('hex');
}

function gitBlobId(bytes) {
  return crypto.createHash('sha1')
    .update(`blob ${bytes.length}\0`, 'utf8')
    .update(bytes)
    .digest('hex');
}

function canonicalize(value) {
  if (Array.isArray(value)) return value.map(canonicalize);
  if (isRecord(value)) {
    return Object.fromEntries(
      Object.keys(value).sort().map((key) => [key, canonicalize(value[key])]),
    );
  }
  return value;
}

function canonicalJson(value) {
  return JSON.stringify(canonicalize(value));
}

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

function inspectJsonValue(root, category) {
  const pending = [{ depth: 0, value: root }];
  let nodes = 0;
  while (pending.length !== 0) {
    const { depth, value } = pending.pop();
    nodes += 1;
    assert(nodes <= 50000 && depth <= 64, category);
    if (Array.isArray(value)) {
      assert(value.length <= 10000, category);
      for (const item of value) pending.push({ depth: depth + 1, value: item });
    } else if (isRecord(value)) {
      const keys = Object.keys(value);
      assert(keys.length <= 10000, category);
      for (const key of keys) {
        assert(key.length <= 1024 && !FORBIDDEN_KEYS.has(key), category);
        pending.push({ depth: depth + 1, value: value[key] });
      }
    } else if (typeof value === 'string') {
      assert(value.length <= MAXIMUM_BODY_CHARACTERS, category);
    } else {
      assert(value === null || typeof value === 'boolean' ||
        (typeof value === 'number' && Number.isFinite(value)), category);
    }
  }
}

function decodeUtf8(bytes, maximumBytes, category, requireLfFile = false) {
  assert(Buffer.isBuffer(bytes) && bytes.length >= 1 &&
    bytes.length <= maximumBytes, category);
  assert(!(bytes.length >= 3 && bytes[0] === 0xef && bytes[1] === 0xbb &&
    bytes[2] === 0xbf), category);
  let text;
  try {
    text = new TextDecoder('utf-8', { fatal: true }).decode(bytes);
  } catch {
    fail(category);
  }
  assert(text.charCodeAt(0) !== 0xfeff && !text.includes('\0'), category);
  if (requireLfFile) {
    assert(!text.includes('\r') && text.endsWith('\n') &&
      !/[ \t]+$/mu.test(text), category);
  }
  return text;
}

function parseJsonBytes(bytes, maximumBytes, category, requireLfFile = true) {
  const text = decodeUtf8(bytes, maximumBytes, category, requireLfFile);
  let value;
  try {
    value = JSON.parse(text);
  } catch {
    fail(category);
  }
  inspectJsonValue(value, category);
  return value;
}

function withoutGitEnvironment(environment) {
  return Object.fromEntries(
    Object.entries(environment)
      .filter(([name]) => !name.toUpperCase().startsWith('GIT_')),
  );
}

function trustedGitEnvironment() {
  return {
    ...withoutGitEnvironment(process.env),
    GIT_NO_REPLACE_OBJECTS: '1',
    GIT_OPTIONAL_LOCKS: '0',
  };
}

function runGit(repositoryRoot, args, maximumBytes = MAXIMUM_GIT_OUTPUT_BYTES) {
  const result = childProcess.spawnSync(
    'git',
    ['--no-replace-objects', '-c', 'core.fsmonitor=false', ...args],
    {
      cwd: repositoryRoot,
      encoding: null,
      env: trustedGitEnvironment(),
      maxBuffer: maximumBytes + 65536,
      shell: false,
      windowsHide: true,
    },
  );
  assert(result.error === undefined && result.status === 0 &&
    Buffer.isBuffer(result.stdout) && result.stdout.length <= maximumBytes,
  'git-command');
  return result.stdout;
}

function runGitText(repositoryRoot, args, category) {
  const bytes = runGit(repositoryRoot, args, 65536);
  const text = decodeUtf8(bytes, 65536, category).trimEnd();
  assert(!text.includes('\n') && !text.includes('\r'), category);
  return text;
}

function normalizeRepositoryRoot(value) {
  assert(typeof value === 'string' && value.length >= 1 &&
    value.length <= 4096 && !value.includes('\0'), 'repository-root');
  let resolved;
  let real;
  try {
    resolved = path.resolve(value);
    real = fs.realpathSync.native(resolved);
  } catch {
    fail('repository-root');
  }
  assert(resolved.toLowerCase() === real.toLowerCase(), 'repository-root');
  return real;
}

function readGitEntry(repositoryRoot, commit, repositoryPath) {
  const maximumBytes = SOURCE_LIMITS[repositoryPath];
  assert(Number.isInteger(maximumBytes), 'source-path');
  const listingBytes = runGit(
    repositoryRoot,
    ['ls-tree', '-z', commit, '--', repositoryPath],
    8192,
  );
  let listing;
  try {
    listing = new TextDecoder('utf-8', { fatal: true }).decode(listingBytes);
  } catch {
    fail('git-entry');
  }
  const match = /^(100644) blob ([0-9a-f]{40})\t([^\0]+)\0$/u.exec(listing);
  assert(match !== null && match[3] === repositoryPath, 'git-entry');
  const bytes = runGit(
    repositoryRoot,
    ['cat-file', 'blob', match[2]],
    maximumBytes,
  );
  assert(bytes.length <= maximumBytes && gitBlobId(bytes) === match[2],
    'git-blob');
  return { path: repositoryPath, mode: match[1], blob: match[2], bytes };
}

function collectSnapshot(repositoryRootValue = DEFAULT_REPOSITORY_ROOT) {
  const repositoryRoot = normalizeRepositoryRoot(repositoryRootValue);
  const commit = runGitText(
    repositoryRoot,
    ['rev-parse', '--verify', 'HEAD^{commit}'],
    'git-commit',
  );
  const tree = runGitText(
    repositoryRoot,
    ['rev-parse', '--verify', `${commit}^{tree}`],
    'git-tree',
  );
  assert(SHA1_PATTERN.test(commit), 'git-commit');
  assert(SHA1_PATTERN.test(tree), 'git-tree');
  const files = Object.fromEntries(
    Object.values(SOURCE_PATHS).map((repositoryPath) => [
      repositoryPath,
      readGitEntry(repositoryRoot, commit, repositoryPath),
    ]),
  );
  const confirmedCommit = runGitText(
    repositoryRoot,
    ['rev-parse', '--verify', 'HEAD^{commit}'],
    'git-commit',
  );
  const confirmedTree = runGitText(
    repositoryRoot,
    ['rev-parse', '--verify', `${confirmedCommit}^{tree}`],
    'git-tree',
  );
  assert(confirmedCommit === commit && confirmedTree === tree,
    'git-state-changed');
  return {
    repositoryRoot,
    commit,
    tree,
    files,
  };
}

function singleCapture(text, expression, category) {
  const matches = [...text.matchAll(expression)];
  assert(matches.length === 1 && matches[0][1] !== undefined, category);
  return matches[0][1];
}

function validateSourceEntry(entry, expectedPath, category) {
  assert(isRecord(entry) && entry.path === expectedPath &&
    entry.mode === '100644' && SHA1_PATTERN.test(entry.blob) &&
    Buffer.isBuffer(entry.bytes) && entry.bytes.length >= 1 &&
    entry.bytes.length <= SOURCE_LIMITS[expectedPath] &&
    gitBlobId(entry.bytes) === entry.blob, category);
}

function deriveIdentity(snapshot) {
  assert(isRecord(snapshot) && SHA1_PATTERN.test(snapshot.commit) &&
    SHA1_PATTERN.test(snapshot.tree) && isRecord(snapshot.files),
  'snapshot-shape');
  for (const repositoryPath of Object.values(SOURCE_PATHS)) {
    validateSourceEntry(snapshot.files[repositoryPath], repositoryPath,
      'source-identity');
  }

  const generatorEntry = snapshot.files[SOURCE_PATHS.generator];
  const verifierEntry = snapshot.files[SOURCE_PATHS.pathVerifier];
  const buildEntry = snapshot.files[SOURCE_PATHS.build];
  const contractEntry = snapshot.files[SOURCE_PATHS.contract];
  const validatorEntry = snapshot.files[SOURCE_PATHS.validator];
  const generatorText = decodeUtf8(
    generatorEntry.bytes,
    SOURCE_LIMITS[SOURCE_PATHS.generator],
    'generator-encoding',
    true,
  );
  const verifierText = decodeUtf8(
    verifierEntry.bytes,
    SOURCE_LIMITS[SOURCE_PATHS.pathVerifier],
    'path-verifier-encoding',
    true,
  );
  const buildText = decodeUtf8(
    buildEntry.bytes,
    SOURCE_LIMITS[SOURCE_PATHS.build],
    'build-encoding',
    true,
  );
  const validatorText = decodeUtf8(
    validatorEntry.bytes,
    SOURCE_LIMITS[SOURCE_PATHS.validator],
    'validator-encoding',
    true,
  );
  const contract = parseJsonBytes(
    contractEntry.bytes,
    MAXIMUM_CONTRACT_BYTES,
    'contract-json',
  );
  assert(isRecord(contract) &&
    contract.schema === 'PSStyleGuide.WorkflowPolicyContract.v1' &&
    contract.contractVersion === 1 && isRecord(contract.scriptVersions) &&
    hasExactKeys(contract.scriptVersions, ['generator', 'pathVerifier']) &&
    isRecord(contract.validatorIdentity), 'contract-shape');

  const generatorPolicy = contract.scriptVersions.generator;
  const verifierPolicy = contract.scriptVersions.pathVerifier;
  assert(hasExactKeys(generatorPolicy, ['path', 'version', 'sha256']) &&
    generatorPolicy.path === path.basename(SOURCE_PATHS.generator) &&
    VERSION_PATTERN.test(generatorPolicy.version) &&
    SHA256_PATTERN.test(generatorPolicy.sha256), 'generator-policy');
  assert(hasExactKeys(verifierPolicy, ['path', 'version', 'sha256']) &&
    verifierPolicy.path === path.basename(SOURCE_PATHS.pathVerifier) &&
    VERSION_PATTERN.test(verifierPolicy.version) &&
    SHA256_PATTERN.test(verifierPolicy.sha256), 'path-verifier-policy');
  assert(hasExactKeys(contract.validatorIdentity, ['path', 'sha256']) &&
    contract.validatorIdentity.path === path.basename(SOURCE_PATHS.validator) &&
    SHA256_PATTERN.test(contract.validatorIdentity.sha256),
  'validator-policy');

  const generatorVersion = singleCapture(
    generatorText,
    /^\$script:strGeneratorVersion = '([^']+)'$/gmu,
    'generator-version',
  );
  const verifierVersion = singleCapture(
    verifierText,
    /^\$script:strVerifierVersion = '([^']+)'$/gmu,
    'path-verifier-version',
  );
  assert(generatorVersion === generatorPolicy.version &&
    sha256(generatorEntry.bytes) === generatorPolicy.sha256,
  'generator-identity');
  assert(verifierVersion === verifierPolicy.version &&
    sha256(verifierEntry.bytes) === verifierPolicy.sha256,
  'path-verifier-identity');

  const buildGeneratorVersion = singleCapture(
    buildText,
    /\$objResult\.GeneratorVersion -cne '([^']+)'/gu,
    'build-generator-version',
  );
  const buildVerifierVersion = singleCapture(
    buildText,
    /\$objPathSetResult\.VerifierVersion -cne '([^']+)'/gu,
    'build-path-verifier-version',
  );
  assert(buildGeneratorVersion === generatorVersion,
    'build-generator-version');
  assert(buildVerifierVersion === verifierVersion,
    'build-path-verifier-version');

  const validatorVersion = singleCapture(
    validatorText,
    /^const VALIDATOR_VERSION = '([^']+)';$/gmu,
    'validator-version',
  );
  const validatorContractDigest = singleCapture(
    validatorText,
    /^const EXPECTED_CONTRACT_CANONICAL_SHA256 = '([0-9a-f]{64})';$/gmu,
    'validator-contract-digest',
  );
  assert(/^[0-9]+\.[0-9]+\.[0-9]+$/u.test(validatorVersion),
    'validator-version');
  assert(sha256(validatorEntry.bytes) === contract.validatorIdentity.sha256,
    'validator-identity');
  const identityView = clone(contract);
  delete identityView.validatorIdentity;
  const contractCanonicalSha256 = sha256(canonicalJson(identityView));
  assert(contractCanonicalSha256 === validatorContractDigest,
    'contract-canonical-identity');

  const surfaces = [
    {
      path: SOURCE_PATHS.generator,
      version: generatorVersion,
      blob: generatorEntry.blob,
      sha256: sha256(generatorEntry.bytes),
    },
    {
      path: SOURCE_PATHS.pathVerifier,
      version: verifierVersion,
      blob: verifierEntry.blob,
      sha256: sha256(verifierEntry.bytes),
    },
    {
      path: SOURCE_PATHS.build,
      version: null,
      blob: buildEntry.blob,
      sha256: sha256(buildEntry.bytes),
    },
    {
      path: SOURCE_PATHS.contract,
      version: String(contract.contractVersion),
      blob: contractEntry.blob,
      sha256: sha256(contractEntry.bytes),
    },
    {
      path: SOURCE_PATHS.validator,
      version: validatorVersion,
      blob: validatorEntry.blob,
      sha256: sha256(validatorEntry.bytes),
    },
  ];
  return {
    schema: 'PSStyleGuide.PullRequestBodyIdentity.v1',
    commit: snapshot.commit,
    tree: snapshot.tree,
    contractCanonicalSha256,
    surfaces,
  };
}

function collectIdentity(repositoryRoot = DEFAULT_REPOSITORY_ROOT) {
  return deriveIdentity(collectSnapshot(repositoryRoot));
}

function identityDigest(identity) {
  return sha256(canonicalJson(identity));
}

function validateIdentity(identity) {
  assert(hasExactKeys(identity, [
    'schema', 'commit', 'tree', 'contractCanonicalSha256', 'surfaces',
  ]) && identity.schema === 'PSStyleGuide.PullRequestBodyIdentity.v1' &&
    SHA1_PATTERN.test(identity.commit) && SHA1_PATTERN.test(identity.tree) &&
    SHA256_PATTERN.test(identity.contractCanonicalSha256) &&
    Array.isArray(identity.surfaces) && identity.surfaces.length === 5,
  'identity-shape');
  const seen = new Set();
  for (const surface of identity.surfaces) {
    assert(hasExactKeys(surface, ['path', 'version', 'blob', 'sha256']) &&
      Object.values(SOURCE_PATHS).includes(surface.path) &&
      !seen.has(surface.path) &&
      (surface.version === null || typeof surface.version === 'string') &&
      SHA1_PATTERN.test(surface.blob) && SHA256_PATTERN.test(surface.sha256),
    'identity-shape');
    seen.add(surface.path);
  }
}

function validateMarkdownBlock(block) {
  assert(typeof block === 'string' && block.length <= 16384 &&
    !block.includes('\r') && !block.includes('\0') && !block.includes('\t') &&
    !/[ \t]+$/mu.test(block) && block.startsWith(`${START_MARKER}\n`) &&
    block.endsWith(END_MARKER), 'markdown-block');
  const lines = block.split('\n');
  assert(lines.filter((line) => line === START_MARKER).length === 1 &&
    lines.filter((line) => line === END_MARKER).length === 1 &&
    lines.filter((line) => line.startsWith('| `')).length === 5,
  'markdown-block');
  const tableLines = lines.filter((line) => line.startsWith('|'));
  assert(tableLines.length === 7 &&
    tableLines.every((line) => line.split('|').length === 6),
  'markdown-block');
}

function renderBlock(identity) {
  validateIdentity(identity);
  const lines = [
    START_MARKER,
    '## Pull request body identity',
    '',
    `- Commit: \`${identity.commit}\``,
    `- Tree: \`${identity.tree}\``,
    `- Canonical contract SHA-256: \`${identity.contractCanonicalSha256}\``,
    '',
    '| Contract surface | Version | Git blob | SHA-256 |',
    '| --- | --- | --- | --- |',
  ];
  for (const surface of identity.surfaces) {
    lines.push(`| \`${surface.path}\` | ${surface.version === null ?
      'Not applicable' : `\`${surface.version}\``} | \`${surface.blob}\` | ` +
      `\`${surface.sha256}\` |`);
  }
  lines.push('', END_MARKER);
  const block = lines.join('\n');
  validateMarkdownBlock(block);
  return block;
}

function validateBodyText(body) {
  assert(typeof body === 'string' && body.length <= MAXIMUM_BODY_CHARACTERS &&
    Buffer.byteLength(body, 'utf8') <= MAXIMUM_BODY_BYTES &&
    !body.includes('\0') && Buffer.from(body, 'utf8').toString('utf8') === body,
  'body-invalid');
}

function occurrences(value, needle) {
  let count = 0;
  let offset = 0;
  while (true) {
    const index = value.indexOf(needle, offset);
    if (index === -1) return count;
    count += 1;
    offset = index + needle.length;
  }
}

function inspectBlock(body) {
  validateBodyText(body);
  const starts = occurrences(body, START_MARKER);
  const ends = occurrences(body, END_MARKER);
  if (starts === 0 && ends === 0) return { disposition: 'absent' };
  assert(starts === 1 && ends === 1, 'identity-block-malformed');
  const start = body.indexOf(START_MARKER);
  const endMarkerStart = body.indexOf(END_MARKER);
  const end = endMarkerStart + END_MARKER.length;
  assert(start < endMarkerStart &&
    (start === 0 || body[start - 1] === '\n') &&
    (end === body.length || body[end] === '\n'),
  'identity-block-malformed');
  return { disposition: 'present', start, end, block: body.slice(start, end) };
}

function checkBody(body, expectedBlock) {
  validateMarkdownBlock(expectedBlock);
  const inspection = inspectBlock(body);
  if (inspection.disposition === 'absent') fail('identity-block-absent');
  assert(inspection.block === expectedBlock, 'identity-block-stale');
  return { current: true };
}

function buildUpdatedBody(body, expectedBlock) {
  validateMarkdownBlock(expectedBlock);
  const inspection = inspectBlock(body);
  if (inspection.disposition === 'present' && inspection.block === expectedBlock) {
    return { body, changed: false };
  }
  let updated;
  if (inspection.disposition === 'absent') {
    const separator = body.length === 0 ? '' :
      body.endsWith('\n\n') ? '' : body.endsWith('\n') ? '\n' : '\n\n';
    updated = `${body}${separator}${expectedBlock}`;
  } else {
    updated = `${body.slice(0, inspection.start)}${expectedBlock}` +
      body.slice(inspection.end);
  }
  validateBodyText(updated);
  checkBody(updated, expectedBlock);
  return { body: updated, changed: true };
}

function readBoundedFile(filePath, maximumBytes, category) {
  let stat;
  let bytes;
  try {
    stat = fs.lstatSync(filePath);
    assert(stat.isFile() && !stat.isSymbolicLink() && stat.size >= 1 &&
      stat.size <= maximumBytes, category);
    bytes = fs.readFileSync(filePath);
  } catch (error) {
    if (error instanceof IdentityError) throw error;
    fail(category);
  }
  assert(bytes.length === stat.size, category);
  return bytes;
}

function parseEvent(filePath, identity) {
  assert(typeof filePath === 'string' && filePath.length >= 1 &&
    filePath.length <= 4096, 'event-path');
  const event = parseJsonBytes(
    readBoundedFile(path.resolve(filePath), MAXIMUM_EVENT_BYTES, 'event-file'),
    MAXIMUM_EVENT_BYTES,
    'event-json',
    false,
  );
  assert(isRecord(event) && isRecord(event.repository) &&
    REPOSITORY_PATTERN.test(event.repository.full_name) &&
    isRecord(event.pull_request) &&
    Number.isSafeInteger(event.pull_request.number) &&
    event.pull_request.number >= 1 && event.pull_request.number <= 2147483647 &&
    isRecord(event.pull_request.base) &&
    isRecord(event.pull_request.base.repo) &&
    event.pull_request.base.repo.full_name === event.repository.full_name &&
    isRecord(event.pull_request.head) &&
    event.pull_request.head.sha === identity.commit &&
    isRecord(event.pull_request.head.repo) &&
    REPOSITORY_PATTERN.test(event.pull_request.head.repo.full_name) &&
    (event.pull_request.body === null ||
      typeof event.pull_request.body === 'string'), 'event-identity');
  return {
    repository: event.repository.full_name,
    pullNumber: event.pull_request.number,
    headRepository: event.pull_request.head.repo.full_name,
    body: event.pull_request.body ?? '',
  };
}

function normalizeApiRoot(value) {
  let url;
  try {
    url = new URL(value);
  } catch {
    fail('api-root');
  }
  assert(url.protocol === 'https:' && url.username === '' &&
    url.password === '' && url.search === '' && url.hash === '', 'api-root');
  url.pathname = `${url.pathname.replace(/\/+$/u, '')}/`;
  return url;
}

function parseOriginRepository(remote, apiRootValue) {
  assert(typeof remote === 'string' && remote.length >= 1 &&
    remote.length <= 4096 && !remote.includes('\0'), 'origin-remote');
  const apiRoot = normalizeApiRoot(apiRootValue);
  const expectedHostname = apiRoot.hostname.toLowerCase() ===
    'api.github.com' ? 'github.com' : apiRoot.hostname;
  const scpMatch = /^git@([^/:?#\s]+):([^?#\s]+)$/u.exec(remote);
  let hostname;
  let repositoryPath;
  if (scpMatch !== null) {
    [, hostname, repositoryPath] = scpMatch;
  } else {
    let url;
    try {
      url = new URL(remote);
    } catch {
      fail('origin-remote');
    }
    assert(url.search === '' && url.hash === '', 'origin-remote');
    if (url.protocol === 'https:') {
      assert(url.username === '' && url.password === '', 'origin-remote');
    } else {
      assert(url.protocol === 'ssh:' && url.username === 'git' &&
        url.password === '', 'origin-remote');
    }
    hostname = url.hostname;
    repositoryPath = url.pathname.replace(/^\//u, '');
  }
  const repository = repositoryPath.endsWith('.git') ?
    repositoryPath.slice(0, -4) : repositoryPath;
  assert(hostname.toLowerCase() === expectedHostname.toLowerCase() &&
    REPOSITORY_PATTERN.test(repository), 'origin-remote');
  return repository;
}

function verifyOriginRepository(
  repositoryRoot,
  expectedRepository,
  apiRootValue,
) {
  const remote = runGitText(
    normalizeRepositoryRoot(repositoryRoot),
    ['remote', 'get-url', 'origin'],
    'origin-remote',
  );
  const repository = parseOriginRepository(remote, apiRootValue);
  assert(repository.toLowerCase() === expectedRepository.toLowerCase(),
    'origin-remote');
}

function validateApiToken(token) {
  assert(typeof token === 'string' && token.length >= 1 &&
    token.length <= 4096 && token.trim() === token &&
    !/[\u0000-\u001f\u007f]/u.test(token), 'api-token');
}

function apiRequest(apiRoot, token, method, relativePath, requestBody) {
  validateApiToken(token);
  assert(['GET', 'PATCH'].includes(method) &&
    typeof relativePath === 'string' && relativePath.length >= 1 &&
    relativePath.length <= 4096 && !relativePath.startsWith('/') &&
    !relativePath.includes('\\') && !relativePath.includes('\0'), 'api-path');
  const url = new URL(relativePath, apiRoot);
  assert(url.origin === apiRoot.origin &&
    url.pathname.startsWith(apiRoot.pathname), 'api-path');
  const bodyBytes = requestBody === undefined ? Buffer.alloc(0) :
    Buffer.from(JSON.stringify(requestBody), 'utf8');
  assert(bodyBytes.length <= MAXIMUM_BODY_BYTES + 4096, 'api-request');
  return new Promise((resolve, reject) => {
    const request = https.request(url, {
      method,
      headers: {
        Accept: 'application/vnd.github+json',
        Authorization: `Bearer ${token}`,
        'Content-Length': String(bodyBytes.length),
        'Content-Type': 'application/json',
        'User-Agent': `PSStyleGuide-PR-Body-Identity/${TOOL_VERSION}`,
        'X-GitHub-Api-Version': API_VERSION,
      },
      timeout: REQUEST_TIMEOUT_MILLISECONDS,
    }, (response) => {
      const chunks = [];
      let length = 0;
      response.on('data', (chunk) => {
        length += chunk.length;
        if (length > MAXIMUM_RESPONSE_BYTES) {
          request.destroy(new Error('api-response-oversized'));
          return;
        }
        chunks.push(chunk);
      });
      response.on('end', () => resolve({
        statusCode: response.statusCode,
        bytes: Buffer.concat(chunks),
      }));
    });
    request.on('timeout', () => request.destroy(new Error('api-timeout')));
    request.on('error', reject);
    if (bodyBytes.length !== 0) request.write(bodyBytes);
    request.end();
  });
}

function decodeApiJson(response, category) {
  assert(isRecord(response) && Number.isInteger(response.statusCode) &&
    Buffer.isBuffer(response.bytes) && response.bytes.length >= 1 &&
    response.bytes.length <= MAXIMUM_RESPONSE_BYTES, category);
  let value;
  try {
    value = JSON.parse(new TextDecoder('utf-8', { fatal: true })
      .decode(response.bytes));
  } catch {
    fail(category);
  }
  inspectJsonValue(value, category);
  return value;
}

function createGitHubApi(apiRootValue, token) {
  const apiRoot = normalizeApiRoot(apiRootValue);
  return {
    async getPull(repository, pullNumber) {
      let response;
      try {
        response = await apiRequest(
          apiRoot,
          token,
          'GET',
          `repos/${repository}/pulls/${pullNumber}`,
        );
      } catch {
        fail('api-read');
      }
      assert(response.statusCode === 200, 'api-read');
      return decodeApiJson(response, 'api-read');
    },
    async patchPull(repository, pullNumber, body) {
      let response;
      try {
        response = await apiRequest(
          apiRoot,
          token,
          'PATCH',
          `repos/${repository}/pulls/${pullNumber}`,
          { body },
        );
      } catch {
        uncertain('api-write-indeterminate');
      }
      if ([401, 403, 404, 422].includes(response.statusCode)) {
        fail('api-write-rejected');
      }
      if (response.statusCode !== 200) uncertain('api-write-indeterminate');
      try {
        return decodeApiJson(response, 'api-write-response');
      } catch {
        uncertain('api-write-response');
      }
    },
  };
}

function validatePull(pull, expected) {
  assert(isRecord(pull) && pull.number === expected.pullNumber &&
    pull.state === 'open' && (pull.body === null || typeof pull.body === 'string') &&
    isRecord(pull.base) && isRecord(pull.base.repo) &&
    REPOSITORY_PATTERN.test(pull.base.repo.full_name) &&
    pull.base.repo.full_name.toLowerCase() === expected.repository.toLowerCase() &&
    isRecord(pull.head) && pull.head.sha === expected.commit &&
    isRecord(pull.head.repo) &&
    REPOSITORY_PATTERN.test(pull.head.repo.full_name), 'remote-identity');
  validateBodyText(pull.body ?? '');
  return { body: pull.body ?? '', headRepository: pull.head.repo.full_name };
}

async function synchronizePullRequest(identity, repository, pullNumber, api) {
  validateIdentity(identity);
  assert(REPOSITORY_PATTERN.test(repository) &&
    Number.isSafeInteger(pullNumber) && pullNumber >= 1 &&
    pullNumber <= 2147483647 && isRecord(api), 'update-arguments');
  const expected = { repository, pullNumber, commit: identity.commit };
  let initialPull;
  try {
    initialPull = await api.getPull(repository, pullNumber);
  } catch (error) {
    if (error instanceof IdentityError) throw error;
    fail('api-read');
  }
  const initial = validatePull(initialPull, expected);
  const block = renderBlock(identity);
  const replacement = buildUpdatedBody(initial.body, block);
  if (!replacement.changed) {
    return { changed: false, headRepository: initial.headRepository };
  }

  let guardPull;
  try {
    guardPull = await api.getPull(repository, pullNumber);
  } catch (error) {
    if (error instanceof IdentityError) throw error;
    fail('api-read');
  }
  let guard;
  try {
    guard = validatePull(guardPull, expected);
  } catch {
    fail('remote-changed-before-write');
  }
  assert(guard.body === initial.body &&
    guard.headRepository === initial.headRepository,
  'remote-changed-before-write');

  let patchedPull;
  try {
    patchedPull = await api.patchPull(repository, pullNumber, replacement.body);
  } catch (error) {
    if (error instanceof IdentityError) throw error;
    uncertain('api-write-indeterminate');
  }
  try {
    const patched = validatePull(patchedPull, expected);
    if (patched.body !== replacement.body ||
      patched.headRepository !== initial.headRepository) {
      uncertain('api-write-response');
    }
  } catch (error) {
    if (error instanceof IdentityError && error.disposition === 'indeterminate') {
      throw error;
    }
    uncertain('api-write-response');
  }

  let readbackPull;
  try {
    readbackPull = await api.getPull(repository, pullNumber);
  } catch {
    uncertain('api-readback');
  }
  try {
    const readback = validatePull(readbackPull, expected);
    if (readback.body !== replacement.body ||
      readback.headRepository !== initial.headRepository) {
      uncertain('api-readback');
    }
  } catch (error) {
    if (error instanceof IdentityError && error.disposition === 'indeterminate') {
      throw error;
    }
    uncertain('api-readback');
  }
  return { changed: true, headRepository: initial.headRepository };
}

function fixtureIdentity() {
  return {
    schema: 'PSStyleGuide.PullRequestBodyIdentity.v1',
    commit: '1'.repeat(40),
    tree: '2'.repeat(40),
    contractCanonicalSha256: '3'.repeat(64),
    surfaces: Object.values(SOURCE_PATHS).map((repositoryPath, index) => ({
      path: repositoryPath,
      version: index === 2 ? null : index === 3 ? '1' :
        index === 4 ? '1.2.2' : `1.0.20260912.${index}`,
      blob: String(index + 4).repeat(40),
      sha256: String(index + 4).repeat(64),
    })),
  };
}

function fixtureBody(name, identity) {
  const block = renderBlock(identity);
  const staleHead = block.replace(identity.commit, '9'.repeat(40));
  const staleTree = block.replace(identity.tree, '8'.repeat(40));
  const staleDigest = block.replace(identity.surfaces[0].sha256, '7'.repeat(64));
  const fixtures = {
    current: block,
    absent: '# Summary\n\nUnrelated text.\n',
    'stale-head': staleHead,
    'stale-tree': staleTree,
    'stale-digest': staleDigest,
    'partial-start': `${START_MARKER}\npartial`,
    'partial-end': `partial\n${END_MARKER}`,
    duplicate: `${block}\n\n${block}`,
    reversed: `${END_MARKER}\n${START_MARKER}`,
    'inline-marker': `prefix ${START_MARKER}\ntext\n${END_MARKER}`,
    'null-character': 'prefix\0suffix',
    'surrounded-stale': `prefix stays\n\n${staleHead}\n\nsuffix stays`,
  };
  assert(Object.hasOwn(fixtures, name), 'case-fixture');
  return fixtures[name];
}

function copySnapshot(snapshot) {
  return {
    repositoryRoot: snapshot.repositoryRoot,
    commit: snapshot.commit,
    tree: snapshot.tree,
    files: Object.fromEntries(Object.entries(snapshot.files).map(
      ([repositoryPath, entry]) => [repositoryPath, {
        path: entry.path,
        mode: entry.mode,
        blob: entry.blob,
        bytes: Buffer.from(entry.bytes),
      }],
    )),
  };
}

function setSnapshotBytes(snapshot, repositoryPath, bytes) {
  assert(Buffer.isBuffer(bytes) && bytes.length >= 1 &&
    bytes.length <= SOURCE_LIMITS[repositoryPath], 'source-mutation');
  const entry = snapshot.files[repositoryPath];
  entry.bytes = bytes;
  entry.blob = gitBlobId(bytes);
}

function mutateText(snapshot, repositoryPath, operation) {
  const original = snapshot.files[repositoryPath].bytes.toString('utf8');
  const updated = operation(original);
  assert(typeof updated === 'string' && updated !== original,
    'source-mutation');
  setSnapshotBytes(snapshot, repositoryPath, Buffer.from(updated, 'utf8'));
}

function mutateContract(snapshot, operation) {
  const contract = JSON.parse(
    snapshot.files[SOURCE_PATHS.contract].bytes.toString('utf8'),
  );
  operation(contract);
  setSnapshotBytes(
    snapshot,
    SOURCE_PATHS.contract,
    Buffer.from(`${JSON.stringify(contract, null, 2)}\n`, 'utf8'),
  );
}

function mutatedSnapshot(baseline, mutation) {
  const snapshot = copySnapshot(baseline);
  if (mutation === 'none') return snapshot;
  if (mutation === 'contract-malformed-json') {
    setSnapshotBytes(snapshot, SOURCE_PATHS.contract, Buffer.from('{\n'));
  } else if (mutation === 'contract-forbidden-key') {
    mutateText(snapshot, SOURCE_PATHS.contract, (text) =>
      text.replace('{\n', '{\n  "__proto__": {},\n'));
  } else if (mutation === 'generator-policy-version-malformed') {
    mutateContract(snapshot, (contract) => {
      contract.scriptVersions.generator.version = 'not-a-version';
    });
  } else if (mutation === 'generator-policy-digest-malformed') {
    mutateContract(snapshot, (contract) => {
      contract.scriptVersions.generator.sha256 = 'not-a-digest';
    });
  } else if (mutation === 'generator-version-drift') {
    mutateText(snapshot, SOURCE_PATHS.generator, (text) => text.replace(
      /^\$script:strGeneratorVersion = '[^']+'$/mu,
      "$script:strGeneratorVersion = '1.0.20260912.9'",
    ));
  } else if (mutation === 'generator-duplicate-version') {
    mutateText(snapshot, SOURCE_PATHS.generator, (text) =>
      `${text}$script:strGeneratorVersion = '1.0.20260912.9'\n`);
  } else if (mutation === 'generator-bom') {
    const bytes = snapshot.files[SOURCE_PATHS.generator].bytes;
    setSnapshotBytes(snapshot, SOURCE_PATHS.generator,
      Buffer.concat([Buffer.from([0xef, 0xbb, 0xbf]), bytes]));
  } else if (mutation === 'path-verifier-crlf') {
    mutateText(snapshot, SOURCE_PATHS.pathVerifier, (text) =>
      text.replace('\n', '\r\n'));
  } else if (mutation === 'build-generator-drift') {
    mutateText(snapshot, SOURCE_PATHS.build, (text) => text.replace(
      /\$objResult\.GeneratorVersion -cne '[^']+'/u,
      "$objResult.GeneratorVersion -cne '1.0.20000101.0'",
    ));
  } else if (mutation === 'build-path-verifier-drift') {
    mutateText(snapshot, SOURCE_PATHS.build, (text) => text.replace(
      /\$objPathSetResult\.VerifierVersion -cne '[^']+'/u,
      "$objPathSetResult.VerifierVersion -cne '1.0.20000101.0'",
    ));
  } else if (mutation === 'validator-identity-drift') {
    mutateText(snapshot, SOURCE_PATHS.validator, (text) =>
      `${text}// identity drift\n`);
  } else if (mutation === 'validator-contract-digest-drift') {
    mutateText(snapshot, SOURCE_PATHS.validator, (text) => text.replace(
      /^const EXPECTED_CONTRACT_CANONICAL_SHA256 = '[0-9a-f]{64}';$/mu,
      `const EXPECTED_CONTRACT_CANONICAL_SHA256 = '${'f'.repeat(64)}';`,
    ));
    const validatorSha256 = sha256(
      snapshot.files[SOURCE_PATHS.validator].bytes,
    );
    mutateContract(snapshot, (contract) => {
      contract.validatorIdentity.sha256 = validatorSha256;
    });
  } else if (mutation === 'contract-canonical-drift') {
    mutateContract(snapshot, (contract) => {
      contract.limits.maximumJsonBytes += 1;
    });
  } else if (mutation === 'source-wrong-mode') {
    snapshot.files[SOURCE_PATHS.build].mode = '100755';
  } else if (mutation === 'source-wrong-blob') {
    snapshot.files[SOURCE_PATHS.build].blob = '0'.repeat(40);
  } else {
    fail('source-mutation');
  }
  return snapshot;
}

function parseCaseCatalog() {
  const catalog = parseJsonBytes(
    readBoundedFile(CASE_CATALOG_PATH, 262144, 'case-file'),
    262144,
    'case-json',
  );
  assert(hasExactKeys(catalog, [
    'schema', 'sourceCases', 'bodyCases', 'remoteCases',
  ]) && catalog.schema === CASE_SCHEMA && Array.isArray(catalog.sourceCases) &&
    catalog.sourceCases.length >= 16 && Array.isArray(catalog.bodyCases) &&
    Array.isArray(catalog.remoteCases) && catalog.bodyCases.length >= 16 &&
    catalog.remoteCases.length >= 12, 'case-shape');
  const ids = new Set();
  for (const testCase of catalog.sourceCases) {
    assert(hasExactKeys(testCase, ['id', 'mutation', 'expected']) &&
      /^[a-z0-9][a-z0-9-]{0,127}$/u.test(testCase.id) &&
      !ids.has(testCase.id) && typeof testCase.mutation === 'string' &&
      typeof testCase.expected === 'string', 'case-shape');
    ids.add(testCase.id);
  }
  for (const testCase of catalog.bodyCases) {
    assert(hasExactKeys(testCase, ['id', 'operation', 'fixture', 'expected']) &&
      /^[a-z0-9][a-z0-9-]{0,127}$/u.test(testCase.id) &&
      !ids.has(testCase.id) && ['check', 'update'].includes(testCase.operation) &&
      typeof testCase.fixture === 'string' &&
      typeof testCase.expected === 'string', 'case-shape');
    ids.add(testCase.id);
  }
  for (const testCase of catalog.remoteCases) {
    assert(hasExactKeys(testCase, [
      'id', 'scenario', 'expected', 'expectedPatchCount',
    ]) && /^[a-z0-9][a-z0-9-]{0,127}$/u.test(testCase.id) &&
      !ids.has(testCase.id) && typeof testCase.scenario === 'string' &&
      typeof testCase.expected === 'string' &&
      Number.isInteger(testCase.expectedPatchCount) &&
      testCase.expectedPatchCount >= 0 && testCase.expectedPatchCount <= 1,
    'case-shape');
    ids.add(testCase.id);
  }
  return catalog;
}

function makePull(identity, body, overrides = {}) {
  return {
    number: 7,
    state: 'open',
    body,
    base: { repo: { full_name: 'example/repository' } },
    head: {
      sha: identity.commit,
      repo: { full_name: 'example/repository' },
    },
    ...overrides,
  };
}

function createMockApi(scenario, identity) {
  const block = renderBlock(identity);
  const absent = fixtureBody('absent', identity);
  const preserved = fixtureBody('surrounded-stale', identity);
  const initialBody = scenario === 'current' ? block :
    scenario === 'update-preserves-text' ? preserved : absent;
  const state = { getCount: 0, patchCount: 0, patchedBody: null };
  const baseRepositoryName = scenario === 'repository-name-case' ?
    'Example/Repository' : 'example/repository';
  const makeScenarioPull = (body, overrides = {}) => makePull(
    identity,
    body,
    { base: { repo: { full_name: baseRepositoryName } }, ...overrides },
  );
  return {
    state,
    async getPull() {
      state.getCount += 1;
      if (['initial-read-failure', 'authentication-failure',
        'rate-limit-failure', 'transport-read-failure'].includes(scenario) &&
        state.getCount === 1) {
        throw new IdentityError('api-read');
      }
      if (scenario === 'head-before-write' && state.getCount === 2) {
        return makeScenarioPull(initialBody, {
          head: { sha: '9'.repeat(40), repo: { full_name: 'example/repository' } },
        });
      }
      if (scenario === 'body-before-write' && state.getCount === 2) {
        return makeScenarioPull(`${initialBody}\nconcurrent edit`);
      }
      if (scenario === 'readback-failure' && state.getCount === 3) {
        throw new Error('simulated transport failure');
      }
      if (state.getCount === 1 || state.getCount === 2) {
        return makeScenarioPull(initialBody);
      }
      if (scenario === 'readback-head-changed') {
        return makeScenarioPull(state.patchedBody, {
          head: { sha: '9'.repeat(40), repo: { full_name: 'example/repository' } },
        });
      }
      if (scenario === 'readback-body-mismatch') {
        return makeScenarioPull(`${state.patchedBody}\nconcurrent edit`);
      }
      return makeScenarioPull(state.patchedBody);
    },
    async patchPull(_repository, _pullNumber, body) {
      state.patchCount += 1;
      state.patchedBody = body;
      if (['write-rejected', 'authorization-failure'].includes(scenario)) {
        throw new IdentityError('api-write-rejected');
      }
      if (scenario === 'write-indeterminate') {
        throw new IdentityError('api-write-indeterminate', 'indeterminate');
      }
      if (scenario === 'patch-response-invalid') return {};
      return makeScenarioPull(body);
    },
  };
}

async function runCaseCatalog(catalog, repositoryRoot) {
  const identity = fixtureIdentity();
  validateIdentity(identity);
  const block = renderBlock(identity);
  let passed = 0;
  validateApiToken('test-token_value');
  passed += 1;
  for (const invalidToken of [undefined, '', ' token', 'token\n']) {
    let rejected = false;
    try {
      validateApiToken(invalidToken);
    } catch (error) {
      rejected = error instanceof IdentityError && error.category === 'api-token';
    }
    assert(rejected, 'token-self-test');
    passed += 1;
  }
  const baselineSnapshot = collectSnapshot(repositoryRoot);
  const originalGitDirectory = process.env.GIT_DIR;
  try {
    process.env.GIT_DIR = path.join(repositoryRoot, 'invalid-git-directory');
    const protectedSnapshot = collectSnapshot(repositoryRoot);
    assert(protectedSnapshot.commit === baselineSnapshot.commit &&
      protectedSnapshot.tree === baselineSnapshot.tree, 'git-environment-self-test');
    passed += 1;
  } finally {
    if (originalGitDirectory === undefined) {
      delete process.env.GIT_DIR;
    } else {
      process.env.GIT_DIR = originalGitDirectory;
    }
  }

  const temporaryRoot = fs.realpathSync.native(os.tmpdir());
  const replacementDirectory = fs.mkdtempSync(path.join(
    temporaryRoot,
    'psstyleguide-pr-body-git-',
  ));
  assert(path.dirname(replacementDirectory).toLowerCase() ===
    temporaryRoot.toLowerCase(), 'git-replace-self-test');
  const testGit = (args) => {
    const result = childProcess.spawnSync('git', args, {
      encoding: 'utf8',
      env: withoutGitEnvironment(process.env),
      maxBuffer: 1048576,
      shell: false,
      windowsHide: true,
    });
    assert(result.error === undefined && result.status === 0 &&
      typeof result.stdout === 'string', 'git-replace-self-test');
    return result.stdout.trim();
  };
  try {
    testGit(['init', '--quiet', replacementDirectory]);
    const replacementFixture = path.join(replacementDirectory, 'fixture.txt');
    fs.writeFileSync(replacementFixture, 'parent\n', {
      encoding: 'utf8', flag: 'wx', mode: 0o600,
    });
    testGit(['-C', replacementDirectory, 'add', '--', 'fixture.txt']);
    const commitFixture = (message) => testGit([
      '-C', replacementDirectory,
      '-c', 'user.name=PSStyleGuide self-test',
      '-c', 'user.email=psstyleguide-self-test@example.invalid',
      '-c', 'commit.gpgSign=false',
      '-c', 'core.hooksPath=.git/no-hooks',
      'commit', '--quiet', '-m', message,
    ]);
    commitFixture('parent');
    const replacementParent = testGit([
      '-C', replacementDirectory, 'rev-parse', '--verify', 'HEAD^{commit}',
    ]);
    fs.writeFileSync(replacementFixture, 'child\n', {
      encoding: 'utf8', flag: 'w', mode: 0o600,
    });
    testGit(['-C', replacementDirectory, 'add', '--', 'fixture.txt']);
    commitFixture('child');
    const replacementCommit = testGit([
      '-C', replacementDirectory, 'rev-parse', '--verify', 'HEAD^{commit}',
    ]);
    const originalTree = testGit([
      '-C', replacementDirectory, 'rev-parse', '--verify', 'HEAD^{tree}',
    ]);
    testGit([
      '-C', replacementDirectory, 'replace', replacementCommit, replacementParent,
    ]);
    const replacedTree = testGit([
      '-C', replacementDirectory, 'rev-parse', '--verify',
      `${replacementCommit}^{tree}`,
    ]);
    assert(replacedTree !== originalTree, 'git-replace-self-test');
    const protectedCommit = runGitText(
      replacementDirectory,
      ['rev-parse', '--verify', 'HEAD^{commit}'],
      'git-replace-self-test',
    );
    const protectedTree = runGitText(
      replacementDirectory,
      ['rev-parse', '--verify', 'HEAD^{tree}'],
      'git-replace-self-test',
    );
    assert(protectedCommit === replacementCommit && protectedTree === originalTree,
      'git-replace-self-test');
    passed += 1;
    testGit([
      '-C', replacementDirectory, 'remote', 'add', 'origin',
      'https://github.com/example/repository.git',
    ]);

    const originCases = [
      {
        remote: 'https://github.com/Example/Repository.git',
        apiRoot: 'https://api.github.com/',
        expected: 'current',
      },
      {
        remote: 'git@github.com:Example/Repository.git',
        apiRoot: 'https://api.github.com/',
        expected: 'current',
      },
      {
        remote: 'https://github.company.test/Example/Repository.git',
        apiRoot: 'https://github.company.test/api/v3',
        expected: 'current',
      },
      {
        remote: 'git@github.company.test:Example/Repository.git',
        apiRoot: 'https://github.company.test/api/v3',
        expected: 'current',
      },
      {
        remote: 'ssh://git@github.company.test/Example/Repository.git',
        apiRoot: 'https://github.company.test/api/v3',
        expected: 'current',
      },
      {
        remote: 'https://unrelated.test/example/repository.git',
        apiRoot: 'https://github.company.test/api/v3',
        expected: 'origin-remote',
      },
      {
        remote: 'https://user@github.company.test/example/repository.git',
        apiRoot: 'https://github.company.test/api/v3',
        expected: 'origin-remote',
      },
      {
        remote: 'ssh://owner@github.company.test/example/repository.git',
        apiRoot: 'https://github.company.test/api/v3',
        expected: 'origin-remote',
      },
      {
        remote: 'https://github.company.test/example/repository/extra.git',
        apiRoot: 'https://github.company.test/api/v3',
        expected: 'origin-remote',
      },
      {
        remote: 'https://github.company.test/example/repository.git?ref=main',
        apiRoot: 'https://github.company.test/api/v3',
        expected: 'origin-remote',
      },
    ];
    for (const originCase of originCases) {
      testGit([
        '-C', replacementDirectory, 'remote', 'set-url', 'origin',
        originCase.remote,
      ]);
      let observed = 'current';
      try {
        verifyOriginRepository(
          replacementDirectory,
          'example/repository',
          originCase.apiRoot,
        );
      } catch (error) {
        if (!(error instanceof IdentityError)) throw error;
        observed = error.category;
      }
      assert(observed === originCase.expected, 'origin-self-test');
      passed += 1;
    }
  } finally {
    const resolved = path.resolve(replacementDirectory);
    assert(path.dirname(resolved).toLowerCase() === temporaryRoot.toLowerCase(),
      'git-replace-self-test');
    fs.rmSync(resolved, { recursive: true, force: false });
  }

  for (const testCase of catalog.sourceCases) {
    let observed;
    try {
      deriveIdentity(mutatedSnapshot(baselineSnapshot, testCase.mutation));
      observed = 'current';
    } catch (error) {
      if (!(error instanceof IdentityError)) throw error;
      observed = error.category;
    }
    assert(observed === testCase.expected, `case-result-${testCase.id}`);
    passed += 1;
  }
  for (const testCase of catalog.bodyCases) {
    const body = fixtureBody(testCase.fixture, identity);
    let observed;
    try {
      if (testCase.operation === 'check') {
        checkBody(body, block);
        observed = 'current';
      } else {
        const result = buildUpdatedBody(body, block);
        observed = result.changed ? 'changed' : 'no-change';
        if (testCase.expected === 'changed-preserved') {
          assert(result.body.startsWith('prefix stays\n\n') &&
            result.body.endsWith('\n\nsuffix stays'), 'case-preservation');
          observed = 'changed-preserved';
        }
      }
    } catch (error) {
      if (!(error instanceof IdentityError)) throw error;
      observed = error.category;
    }
    assert(observed === testCase.expected, `case-result-${testCase.id}`);
    passed += 1;
  }

  for (const testCase of catalog.remoteCases) {
    const api = createMockApi(testCase.scenario, identity);
    let observed;
    try {
      const result = await synchronizePullRequest(
        identity,
        'example/repository',
        7,
        api,
      );
      observed = result.changed ? 'success-changed' : 'success-no-change';
      if (testCase.expected === 'success-changed-preserved') {
        assert(api.state.patchedBody.startsWith('prefix stays\n\n') &&
          api.state.patchedBody.endsWith('\n\nsuffix stays'),
        'case-preservation');
        observed = 'success-changed-preserved';
      }
    } catch (error) {
      if (!(error instanceof IdentityError)) throw error;
      observed = error.disposition === 'indeterminate' ?
        'indeterminate' : error.category;
    }
    assert(observed === testCase.expected &&
      api.state.patchCount === testCase.expectedPatchCount,
    `case-result-${testCase.id}`);
    passed += 1;
  }

  const temporaryDirectory = fs.mkdtempSync(path.join(
    temporaryRoot,
    'psstyleguide-pr-body-identity-',
  ));
  assert(path.dirname(temporaryDirectory).toLowerCase() ===
    temporaryRoot.toLowerCase(), 'event-self-test');
  const eventPath = path.join(temporaryDirectory, 'event.json');
  try {
    const event = {
      repository: { full_name: 'example/repository' },
      pull_request: {
        number: 7,
        body: block,
        base: { repo: { full_name: 'example/repository' } },
        head: {
          sha: identity.commit,
          repo: { full_name: 'example/repository' },
        },
      },
    };
    fs.writeFileSync(eventPath, `${JSON.stringify(event)}\n`, {
      encoding: 'utf8',
      flag: 'wx',
      mode: 0o600,
    });
    const parsed = parseEvent(eventPath, identity);
    assert(parsed.repository === 'example/repository' &&
      parsed.pullNumber === 7 && parsed.body === block, 'event-self-test');
    checkBody(parsed.body, block);
    passed += 2;
    fs.writeFileSync(eventPath, JSON.stringify(event), {
      encoding: 'utf8',
      flag: 'w',
      mode: 0o600,
    });
    assert(parseEvent(eventPath, identity).body === block, 'event-self-test');
    passed += 1;
    event.pull_request.head.sha = '9'.repeat(40);
    fs.writeFileSync(eventPath, `${JSON.stringify(event)}\n`, {
      encoding: 'utf8',
      flag: 'w',
      mode: 0o600,
    });
    let rejected = false;
    try {
      parseEvent(eventPath, identity);
    } catch (error) {
      rejected = error instanceof IdentityError &&
        error.category === 'event-identity';
    }
    assert(rejected, 'event-self-test');
    passed += 1;
  } finally {
    const resolved = path.resolve(temporaryDirectory);
    assert(path.dirname(resolved).toLowerCase() === temporaryRoot.toLowerCase(),
      'event-self-test');
    fs.rmSync(resolved, { recursive: true, force: false });
  }
  return passed;
}

function parseArguments(argv) {
  assert(Array.isArray(argv) && argv.length >= 1 && argv.length <= 11,
    'arguments');
  const mode = argv[0];
  assert(['--help', '--self-test', '--generate', '--check-event', '--update']
    .includes(mode), 'arguments');
  const options = { mode };
  let index = 1;
  if (mode === '--check-event') {
    assert(index < argv.length, 'arguments');
    options.eventPath = argv[index];
    index += 1;
  }
  while (index < argv.length) {
    const name = argv[index];
    const value = argv[index + 1];
    assert(typeof value === 'string' && !value.startsWith('--'), 'arguments');
    const properties = {
      '--repository-root': 'repositoryRoot',
      '--repository': 'repository',
      '--pull-request': 'pullRequest',
      '--api-root': 'apiRoot',
    };
    const property = properties[name];
    assert(property !== undefined && !Object.hasOwn(options, property),
      'arguments');
    options[property] = value;
    index += 2;
  }
  const allowedByMode = {
    '--help': [],
    '--self-test': ['repositoryRoot'],
    '--generate': ['repositoryRoot'],
    '--check-event': ['eventPath', 'repositoryRoot'],
    '--update': ['repositoryRoot', 'repository', 'pullRequest', 'apiRoot'],
  };
  assert(Object.keys(options).filter((key) => key !== 'mode')
    .every((key) => allowedByMode[mode].includes(key)), 'arguments');
  if (mode === '--update') {
    assert(REPOSITORY_PATTERN.test(options.repository ?? '') &&
      /^[1-9][0-9]{0,9}$/u.test(options.pullRequest ?? ''), 'arguments');
  }
  return options;
}

function helpText() {
  return `Sync-PullRequestBodyIdentity.mjs ${TOOL_VERSION}

Usage:
  node .github/workflows/Sync-PullRequestBodyIdentity.mjs --self-test
  node .github/workflows/Sync-PullRequestBodyIdentity.mjs --generate
  node .github/workflows/Sync-PullRequestBodyIdentity.mjs --check-event EVENT_PATH
  node .github/workflows/Sync-PullRequestBodyIdentity.mjs --update --repository OWNER/REPO --pull-request NUMBER

Options:
  --repository-root PATH  Read committed identities from PATH (default: repository root).
  --api-root URL          GitHub REST root (default: GITHUB_API_URL or https://api.github.com/).

Update mode reads GITHUB_TOKEN from the environment. It never accepts a token argument.
It reports indeterminate, not success, when a write or readback cannot be authenticated.
`;
}

function resultBase(identity) {
  return {
    schema: RESULT_SCHEMA,
    toolVersion: TOOL_VERSION,
    success: true,
    disposition: 'success',
    commit: identity.commit,
    tree: identity.tree,
    identitySha256: identityDigest(identity),
  };
}

async function main() {
  const options = parseArguments(process.argv.slice(2));
  if (options.mode === '--help') {
    process.stdout.write(helpText());
    return;
  }
  const repositoryRoot = options.repositoryRoot ?? DEFAULT_REPOSITORY_ROOT;
  const identity = collectIdentity(repositoryRoot);
  if (options.mode === '--self-test') {
    const casesPassed = await runCaseCatalog(
      parseCaseCatalog(),
      repositoryRoot,
    );
    process.stdout.write(`${JSON.stringify({
      ...resultBase(identity),
      mode: 'self-test',
      casesPassed,
    })}\n`);
    return;
  }
  const block = renderBlock(identity);
  if (options.mode === '--generate') {
    process.stdout.write(`${JSON.stringify({
      ...resultBase(identity),
      mode: 'generate',
      block,
    })}\n`);
    return;
  }
  if (options.mode === '--check-event') {
    const event = parseEvent(options.eventPath, identity);
    checkBody(event.body, block);
    process.stdout.write(`${JSON.stringify({
      ...resultBase(identity),
      mode: 'check-event',
      repository: event.repository,
      pullNumber: event.pullNumber,
      headRepository: event.headRepository,
    })}\n`);
    return;
  }
  const token = process.env.GITHUB_TOKEN;
  validateApiToken(token);
  const pullNumber = Number(options.pullRequest);
  const apiRoot = normalizeApiRoot(
    options.apiRoot ?? process.env.GITHUB_API_URL ?? 'https://api.github.com/',
  );
  verifyOriginRepository(repositoryRoot, options.repository, apiRoot);
  const update = await synchronizePullRequest(
    identity,
    options.repository,
    pullNumber,
    createGitHubApi(apiRoot, token),
  );
  process.stdout.write(`${JSON.stringify({
    ...resultBase(identity),
    mode: 'update',
    repository: options.repository,
    pullNumber,
    headRepository: update.headRepository,
    changed: update.changed,
  })}\n`);
}

try {
  await main();
} catch (error) {
  const category = error instanceof IdentityError ? error.category :
    'tool-failure';
  const disposition = error instanceof IdentityError ? error.disposition :
    'failure';
  process.stdout.write(`${JSON.stringify({
    schema: RESULT_SCHEMA,
    toolVersion: TOOL_VERSION,
    success: false,
    disposition,
    category,
  })}\n`);
  process.exitCode = disposition === 'indeterminate' ? 2 : 1;
}
