#!/usr/bin/env node

import https from 'node:https';
import { createHash } from 'node:crypto';
import { TextDecoder } from 'node:util';

// Each invalidation run handles one page of at most 10 pull requests and then
// dispatches an authenticated continuation. Even a continuation that replaces
// all 10 statuses, claims its guard, and dispatches its successor stays within
// the 25-request and four-minute operation budgets. A sweep accepts at most 100
// pull requests, two passes, and two complete restarts: at most 60 page runs,
// 1,500 API requests, and 240 minutes at the per-run deadline.
const pullRequestPageSize = 10;
const statusContextBatchSize = 10;
const maximumPullRequestsPerSweep = 100;
const maximumApiRequests = 25;
const maximumOperationMilliseconds = 240000;
const requestTimeoutMilliseconds = 8000;
const maximumResponseBytes = 1048576;
const maximumRequestPathCharacters = 4096;
const maximumCursorCharacters = 1024;
const maximumDispatchPayloadBytes = 4096;
const maximumSweepRestarts = 2;
const dispatchProtocol = 'agent-instruction-current-base/v1';
const continuationEventType =
  'agent-instruction-current-base-continuation-v1';
const bootstrapEventType = 'agent-instruction-current-base-bootstrap-v1';
const currentBaseWorkflowPath =
  '.github/workflows/agent-instruction-current-base.yml';
const validationWorkflowPath = '.github/workflows/agent-instructions.yml';
const initialSnapshotDigest = createHash('sha256')
  .update('PSStyleGuide current-base sweep snapshot v1\n', 'utf8')
  .digest('hex');
const shaPattern = /^[0-9a-f]{40}$/;
const digestPattern = /^[0-9a-f]{64}$/;
const repositoryPattern = /^[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$/;
const actionsCreatorLogins = new Set(['github-actions',
  'github-actions[bot]']);
const workflowRunStatuses = new Set([
  'completed',
  'in_progress',
  'pending',
  'queued',
  'requested',
  'waiting',
]);
const openPullRequestsQuery = `query OpenPullRequests(
  $owner: String!
  $name: String!
  $baseRefName: String!
  $pageSize: Int!
  $cursor: String
) {
  repository(owner: $owner, name: $name) {
    pullRequests(
      first: $pageSize
      after: $cursor
      states: OPEN
      baseRefName: $baseRefName
      orderBy: {field: CREATED_AT, direction: ASC}
    ) {
      totalCount
      nodes {
        number
        state
        baseRefName
        baseRepository {
          nameWithOwner
        }
        headRefOid
        createdAt
      }
      pageInfo {
        hasNextPage
        endCursor
      }
    }
  }
}`;

function assert(condition, message) {
  if (!condition) throw new Error(message);
}

function isRecord(value) {
  return value !== null && typeof value === 'object' &&
    !Array.isArray(value);
}

function hasExactProperties(value, properties) {
  return isRecord(value) && Object.keys(value).sort().join('\n') ===
    [...properties].sort().join('\n');
}

function statusContext(pullNumber) {
  return `Agent instruction current base/PR-${pullNumber}`;
}

function sweepGuardContext(branch) {
  const branchDigest = createHash('sha256').update(branch, 'utf8')
    .digest('hex').slice(0, 16);
  return `Agent instruction current base sweep/${branchDigest}`;
}

function pendingGuardDescription(baseSha, token) {
  return `Sweep pending base ${baseSha}; state ${token}.`;
}

function successfulGuardDescription(baseSha, token) {
  return `Sweep complete base ${baseSha}; state ${token}.`;
}

function bootstrapRunTitle(branch, defaultSha) {
  return `Agent current-base bootstrap: branch=${branch}; code=${defaultSha}`;
}

function continuationRunTitle(branch, baseSha, token, defaultSha) {
  return `Agent current-base continuation: branch=${branch}; base=${baseSha}; ` +
    `state=${token}; code=${defaultSha}`;
}

function statusHasActionsCreator(latest) {
  return latest && actionsCreatorLogins.has(latest.creatorLogin);
}

function statusMatchesBase(latest, currentBaseSha) {
  return latest && latest.state === 'success' &&
    latest.description === `Validated base ${currentBaseSha}.` &&
    statusHasActionsCreator(latest);
}

function successfulGuardToken(latest, currentBaseSha) {
  if (!(latest && latest.state === 'success' &&
    statusHasActionsCreator(latest))) return null;
  const match = /^Sweep complete base ([0-9a-f]{40}); state ([0-9a-f]{64})\.$/
    .exec(latest.description);
  return match && match[1] === currentBaseSha ? match[2] : null;
}

function guardMatchesBase(latest, currentBaseSha) {
  return successfulGuardToken(latest, currentBaseSha) !== null;
}

function guardAllowsMergeControl(guard, currentBaseSha, runAuthenticated) {
  return runAuthenticated === true && guardMatchesBase(guard, currentBaseSha);
}

function mergeControlAccepts(latest, guard, currentBaseSha,
  pullRunAuthenticated, guardRunAuthenticated) {
  return pullRunAuthenticated === true &&
    statusMatchesBase(latest, currentBaseSha) &&
    guardAllowsMergeControl(guard, currentBaseSha, guardRunAuthenticated);
}

function requiresInvalidation(latest, currentBaseSha) {
  return !statusMatchesBase(latest, currentBaseSha);
}

function invalidationDescription(currentBaseSha, pullNumber) {
  return `Base advanced to ${currentBaseSha}; revalidate PR #${pullNumber}.`;
}

function requiresSweepInvalidation(latest, currentBaseSha, pullNumber) {
  return !statusMatchesBase(latest, currentBaseSha) && !(latest &&
    latest.state === 'error' &&
    latest.description === invalidationDescription(currentBaseSha, pullNumber));
}

function createRequestBudget(now = Date.now) {
  assert(typeof now === 'function', 'GitHub API budget clock is invalid.');
  const startedAt = now();
  assert(Number.isFinite(startedAt), 'GitHub API budget clock is invalid.');
  const deadline = startedAt + maximumOperationMilliseconds;
  let requestCount = 0;

  function assertCanComplete(additionalRequests) {
    assert(Number.isInteger(additionalRequests) && additionalRequests >= 0,
      'GitHub API request reservation is invalid.');
    assert(requestCount + additionalRequests <= maximumApiRequests,
      'GitHub API request budget would be exceeded.');
    const currentTime = now();
    assert(Number.isFinite(currentTime) &&
      currentTime + additionalRequests * requestTimeoutMilliseconds <= deadline,
    'GitHub API deadline cannot accommodate the remaining requests.');
  }

  function beginRequest() {
    assertCanComplete(1);
    requestCount += 1;
  }

  return {
    assertCanComplete,
    beginRequest,
    get requestCount() { return requestCount; },
  };
}

function isCurrentPull(pull, ref, expected) {
  return pull && pull.number === expected.pullNumber && pull.state === 'open' &&
    pull.base && pull.base.ref === expected.baseRef &&
    pull.base.sha === expected.baseSha &&
    pull.head && pull.head.sha === expected.headSha &&
    ref && ref.object && ref.object.type === 'commit' &&
    ref.object.sha === expected.baseSha;
}

function isAuthenticWorkflowRun(run, expected) {
  if (!['requested', 'completed'].includes(expected.activity)) return false;
  if (!(run && String(run.id) === expected.runId && run.event === 'push' &&
    run.path === validationWorkflowPath &&
    run.head_branch === expected.branch && run.head_sha === expected.signalSha &&
    isRecord(run.repository) &&
    run.repository.full_name === expected.repository &&
    workflowRunStatuses.has(run.status))) return false;
  return expected.activity === 'requested' || run.status === 'completed';
}

function isAuthenticCurrentBaseRun(run, expected) {
  if (!(isRecord(run) && String(run.id) === expected.runId &&
    run.event === expected.eventName && run.path === currentBaseWorkflowPath &&
    run.head_branch === expected.defaultBranch &&
    run.head_sha === expected.defaultSha &&
    isRecord(run.repository) &&
    run.repository.full_name === expected.repository &&
    workflowRunStatuses.has(run.status))) return false;
  if (expected.displayTitle !== undefined &&
    run.display_title !== expected.displayTitle) return false;
  return !expected.requireSuccess ||
    (run.status === 'completed' && run.conclusion === 'success');
}

function normalizeApiRoot(value) {
  let url;
  try {
    url = new URL(value);
  } catch {
    throw new Error('GitHub API identity is invalid.');
  }
  assert(url.protocol === 'https:' && url.username === '' &&
    url.password === '' && url.search === '' && url.hash === '',
  'GitHub API identity is invalid.');
  url.pathname = `${url.pathname.replace(/\/+$/, '')}/`;
  const basePathname = url.pathname;
  return { url, origin: url.origin, basePathname };
}

function resolveApiRequestUrl(apiRoot, relativePath) {
  assert(typeof relativePath === 'string' && relativePath.length >= 1 &&
    relativePath.length <= maximumRequestPathCharacters &&
    !relativePath.startsWith('/') && !relativePath.startsWith('?') &&
    !/^[A-Za-z][A-Za-z0-9+.-]*:/.test(relativePath) &&
    !/[\\\u0000-\u001f\u007f#]/.test(relativePath),
  'GitHub API request path is invalid.');
  const pathOnly = relativePath.split('?', 1)[0];
  for (const segment of pathOnly.split('/')) {
    let decoded;
    try {
      decoded = decodeURIComponent(segment);
    } catch {
      throw new Error('GitHub API request path is invalid.');
    }
    assert(decoded !== '.' && decoded !== '..' &&
      !decoded.includes('/') && !decoded.includes('\\'),
    'GitHub API request path is invalid.');
  }
  let resolved;
  try {
    resolved = new URL(relativePath, apiRoot.url);
  } catch {
    throw new Error('GitHub API request path is invalid.');
  }
  assert(resolved.origin === apiRoot.origin &&
    resolved.username === '' && resolved.password === '' &&
    resolved.pathname.startsWith(apiRoot.basePathname),
  'GitHub API request path escaped its API root.');
  return resolved;
}

function normalizeGraphqlApiRoot(value) {
  let endpoint;
  try {
    endpoint = new URL(value);
  } catch {
    throw new Error('GitHub GraphQL API identity is invalid.');
  }
  assert(endpoint.protocol === 'https:' && endpoint.username === '' &&
    endpoint.password === '' && endpoint.search === '' &&
    endpoint.hash === '' && endpoint.pathname.endsWith('/graphql'),
  'GitHub GraphQL API identity is invalid.');
  const root = normalizeApiRoot(new URL('.', endpoint).href);
  assert(resolveApiRequestUrl(root, 'graphql').href === endpoint.href,
    'GitHub GraphQL API identity is invalid.');
  return root;
}

function decodeApiResponse(statusCode, body, allowNotFound = false) {
  assert(Buffer.isBuffer(body) && body.length <= maximumResponseBytes,
    'GitHub API response is oversized.');
  if (allowNotFound && statusCode === 404) return null;
  assert(Number.isInteger(statusCode) && statusCode >= 200 && statusCode < 300,
    `GitHub API returned ${statusCode}.`);
  if (body.length === 0) return null;
  try {
    return JSON.parse(new TextDecoder('utf-8', { fatal: true }).decode(body));
  } catch {
    throw new Error('GitHub API returned malformed JSON.');
  }
}

function validCursor(value) {
  return typeof value === 'string' && value.length >= 1 &&
    value.length <= maximumCursorCharacters && /^[\x21-\x7e]+$/.test(value);
}

function parsePullRequestPage(result, expected) {
  assert(isRecord(result) && !Object.hasOwn(result, 'errors') &&
    isRecord(result.data) && isRecord(result.data.repository) &&
    isRecord(result.data.repository.pullRequests),
  'GraphQL pull request response is invalid.');
  const connection = result.data.repository.pullRequests;
  assert(Number.isInteger(connection.totalCount) &&
    connection.totalCount >= 0 &&
    connection.totalCount <= maximumPullRequestsPerSweep,
  'GraphQL pull request connection is invalid.');
  assert(Array.isArray(connection.nodes) &&
    connection.nodes.length <= pullRequestPageSize &&
    connection.nodes.length <= connection.totalCount &&
    isRecord(connection.pageInfo) &&
    typeof connection.pageInfo.hasNextPage === 'boolean' &&
    ((connection.nodes.length === 0 &&
      connection.pageInfo.hasNextPage === false &&
      connection.pageInfo.endCursor === null) ||
      (connection.nodes.length >= 1 &&
        validCursor(connection.pageInfo.endCursor))) &&
    (!connection.pageInfo.hasNextPage ||
      connection.nodes.length === pullRequestPageSize),
  'GraphQL pull request connection is invalid.');
  const pulls = [];
  const seenPulls = new Set();
  for (const pull of connection.nodes) {
    assert(isRecord(pull) && Number.isInteger(pull.number) &&
      pull.number >= 1 && !seenPulls.has(pull.number) &&
      pull.state === 'OPEN' && pull.baseRefName === expected.branch &&
      isRecord(pull.baseRepository) &&
      pull.baseRepository.nameWithOwner === expected.repository &&
      shaPattern.test(pull.headRefOid) &&
      typeof pull.createdAt === 'string' &&
      /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?Z$/.test(
        pull.createdAt) && Number.isFinite(Date.parse(pull.createdAt)),
    'GraphQL pull request response entry is invalid.');
    seenPulls.add(pull.number);
    pulls.push({
      number: pull.number,
      head: { sha: pull.headRefOid },
      createdAt: pull.createdAt,
    });
  }
  return {
    totalCount: connection.totalCount,
    pulls,
    hasNextPage: connection.pageInfo.hasNextPage,
    endCursor: connection.pageInfo.endCursor,
  };
}

async function listOpenPullRequestPage(client, branch, cursor) {
  assert(cursor === null || validCursor(cursor),
    'Pull request page cursor is invalid.');
  const [owner, name] = client.repository.split('/');
  const result = await client.graphql({
    query: openPullRequestsQuery,
    variables: {
      owner,
      name,
      baseRefName: branch,
      pageSize: pullRequestPageSize,
      cursor,
    },
  });
  return parsePullRequestPage(result,
    { repository: client.repository, branch });
}

function createExactStatusContextRequest(repository, entries) {
  assert(repositoryPattern.test(repository) && Array.isArray(entries) &&
    entries.length >= 1 && entries.length <= statusContextBatchSize,
  'Status-context batch is invalid.');
  const [owner, name] = repository.split('/');
  const declarations = ['$owner: String!', '$name: String!'];
  const selections = [];
  const variables = { owner, name };
  for (let index = 0; index < entries.length; index += 1) {
    const entry = entries[index];
    assert(isRecord(entry) && shaPattern.test(entry.sha) &&
      typeof entry.context === 'string' && entry.context.length >= 1 &&
      entry.context.length <= 255 && !/[\u0000\r\n]/.test(entry.context),
    'Status-context batch is invalid.');
    declarations.push(`$oid${index}: GitObjectID!`);
    declarations.push(`$context${index}: String!`);
    variables[`oid${index}`] = entry.sha;
    variables[`context${index}`] = entry.context;
    selections.push(`status${index}: object(oid: $oid${index}) {
      __typename
      ... on Commit {
        oid
        status {
          latest: context(name: $context${index}) {
            context
            state
            description
            targetUrl
            creator {
              login
            }
          }
        }
      }
    }`);
  }
  return {
    query: `query ExactStatusContexts(
  ${declarations.join('\n  ')}
) {
  repository(owner: $owner, name: $name) {
    ${selections.join('\n    ')}
  }
}`,
    variables,
  };
}

function createStatusContextRequest(repository, pulls) {
  assert(Array.isArray(pulls), 'Status-context batch is invalid.');
  return createExactStatusContextRequest(repository, pulls.map((pull) => {
    assert(isRecord(pull) && Number.isInteger(pull.number) &&
      pull.number >= 1 && isRecord(pull.head) &&
      shaPattern.test(pull.head.sha), 'Status-context batch is invalid.');
    return {
      sha: pull.head.sha,
      context: statusContext(pull.number),
    };
  }));
}

function parseExactStatusContextResponse(result, entries) {
  assert(isRecord(result) && !Object.hasOwn(result, 'errors') &&
    isRecord(result.data) && isRecord(result.data.repository),
  'GraphQL status-context response is invalid.');
  const statuses = [];
  for (let index = 0; index < entries.length; index += 1) {
    const item = result.data.repository[`status${index}`];
    assert(isRecord(item) && item.__typename === 'Commit' &&
      item.oid === entries[index].sha &&
      (item.status === null || isRecord(item.status)),
    'GraphQL status-context response entry is invalid.');
    if (item.status === null) {
      statuses.push(null);
      continue;
    }
    assert(Object.hasOwn(item.status, 'latest') &&
      (item.status.latest === null || isRecord(item.status.latest)),
    'GraphQL status-context response entry is invalid.');
    const latest = item.status.latest;
    if (latest === null) {
      statuses.push(null);
      continue;
    }
    assert(latest.context === entries[index].context &&
      ['ERROR', 'EXPECTED', 'FAILURE', 'PENDING', 'SUCCESS'].includes(
        latest.state) &&
      (latest.description === null || typeof latest.description === 'string') &&
      (latest.targetUrl === null || typeof latest.targetUrl === 'string') &&
      (latest.creator === null || (isRecord(latest.creator) &&
        typeof latest.creator.login === 'string')),
    'GraphQL status-context response entry is invalid.');
    statuses.push({
      state: latest.state.toLowerCase(),
      description: latest.description,
      targetUrl: latest.targetUrl,
      creatorLogin: latest.creator === null ? null : latest.creator.login,
    });
  }
  return statuses;
}

function parseStatusContextResponse(result, pulls) {
  return parseExactStatusContextResponse(result, pulls.map((pull) => ({
    sha: pull.head.sha,
    context: statusContext(pull.number),
  })));
}

async function readExactStatuses(client, entries) {
  const statuses = [];
  for (let offset = 0; offset < entries.length;
    offset += statusContextBatchSize) {
    const batch = entries.slice(offset, offset + statusContextBatchSize);
    const result = await client.graphql(
      createExactStatusContextRequest(client.repository, batch));
    statuses.push(...parseExactStatusContextResponse(result, batch));
  }
  return statuses;
}

async function readLatestStatuses(client, pulls) {
  return await readExactStatuses(client, pulls.map((pull) => ({
    sha: pull.head.sha,
    context: statusContext(pull.number),
  })));
}

async function expectRejected(operation, expectedMessage, failureMessage) {
  let rejected = false;
  try {
    await operation();
  } catch (error) {
    rejected = error.message === expectedMessage;
  }
  assert(rejected, failureMessage);
}

function createInitialProgress(phase = 'invalidate', restartCount = 0,
  expectedTotalCount = null, expectedDigest = null) {
  return {
    phase,
    cursor: null,
    totalCount: null,
    seenCount: 0,
    digest: initialSnapshotDigest,
    expectedTotalCount,
    expectedDigest,
    restartCount,
    repaired: false,
  };
}

function assertSweepSession(session) {
  assert(hasExactProperties(session,
    ['repository', 'branch', 'baseSha', 'defaultBranch']) &&
    typeof session.repository === 'string' &&
    repositoryPattern.test(session.repository) && validRef(session.branch) &&
    typeof session.baseSha === 'string' &&
    shaPattern.test(session.baseSha) && validRef(session.defaultBranch),
  'Sweep session is invalid.');
}

function assertSweepProgress(progress) {
  assert(hasExactProperties(progress, ['phase', 'cursor', 'totalCount',
    'seenCount', 'digest', 'expectedTotalCount', 'expectedDigest',
    'restartCount', 'repaired']) &&
    ['invalidate', 'verify'].includes(progress.phase) &&
    (progress.cursor === null || validCursor(progress.cursor)) &&
    (progress.totalCount === null ||
      (Number.isInteger(progress.totalCount) && progress.totalCount >= 0 &&
        progress.totalCount <= maximumPullRequestsPerSweep)) &&
    Number.isInteger(progress.seenCount) && progress.seenCount >= 0 &&
    progress.seenCount <= maximumPullRequestsPerSweep &&
    typeof progress.digest === 'string' &&
    digestPattern.test(progress.digest) &&
    Number.isInteger(progress.restartCount) && progress.restartCount >= 0 &&
    progress.restartCount <= maximumSweepRestarts &&
    typeof progress.repaired === 'boolean', 'Sweep progress is invalid.');
  assert((progress.cursor === null && progress.totalCount === null &&
    progress.seenCount === 0 && progress.digest === initialSnapshotDigest) ||
    (progress.cursor !== null && Number.isInteger(progress.totalCount) &&
      progress.seenCount >= 1), 'Sweep cursor state is invalid.');
  if (progress.phase === 'invalidate') {
    assert(progress.expectedTotalCount === null &&
      progress.expectedDigest === null && progress.repaired === false,
    'Sweep invalidation state is invalid.');
  } else {
    assert(Number.isInteger(progress.expectedTotalCount) &&
      progress.expectedTotalCount >= 0 &&
      progress.expectedTotalCount <= maximumPullRequestsPerSweep &&
      typeof progress.expectedDigest === 'string' &&
      digestPattern.test(progress.expectedDigest),
    'Sweep verification state is invalid.');
  }
}

function sweepStateToken(session, progress, parentRunId, parentRunSha,
  parentStateToken) {
  assertSweepSession(session);
  assertSweepProgress(progress);
  assert(typeof parentRunId === 'string' &&
    /^[1-9][0-9]{0,19}$/.test(parentRunId) &&
    typeof parentRunSha === 'string' && shaPattern.test(parentRunSha) &&
    (parentStateToken === null ||
      (typeof parentStateToken === 'string' &&
        digestPattern.test(parentStateToken))),
  'Sweep parent identity is invalid.');
  return createHash('sha256').update(JSON.stringify({
    session,
    progress,
    parent: {
      runId: parentRunId,
      runSha: parentRunSha,
      stateToken: parentStateToken,
    },
  }), 'utf8').digest('hex');
}

function extendSnapshotDigest(digest, pulls) {
  assert(digestPattern.test(digest) && Array.isArray(pulls),
    'Sweep snapshot input is invalid.');
  const rows = pulls.map((pull) => ({
    number: pull.number,
    headSha: pull.head.sha,
    createdAt: pull.createdAt,
  }));
  return createHash('sha256').update(`${digest}\n${JSON.stringify(rows)}\n`,
    'utf8').digest('hex');
}

function continuationPayload(session, progress, parentRunId, parentRunSha,
  parentStateToken) {
  assertSweepSession(session);
  assertSweepProgress(progress);
  const stateToken = sweepStateToken(session, progress, parentRunId,
    parentRunSha, parentStateToken);
  return {
    protocol: dispatchProtocol,
    session: {
      branch: session.branch,
      base_sha: session.baseSha,
      default_branch: session.defaultBranch,
    },
    progress: {
      phase: progress.phase,
      cursor: progress.cursor,
      total_count: progress.totalCount,
      seen_count: progress.seenCount,
      digest: progress.digest,
      expected_total_count: progress.expectedTotalCount,
      expected_digest: progress.expectedDigest,
      restart_count: progress.restartCount,
      repaired: progress.repaired,
    },
    parent: {
      run_id: parentRunId,
      run_sha: parentRunSha,
      state_token: parentStateToken,
    },
    state_token: stateToken,
  };
}

async function runSelfTest() {
  const baselineSha = '1'.repeat(40);
  const advancedSha = '2'.repeat(40);
  const sourceRunUrl =
    'https://example.invalid/owner/repository/actions/runs/600';
  const newerRunUrl =
    'https://example.invalid/owner/repository/actions/runs/601';
  const guardRunUrl =
    'https://example.invalid/owner/repository/actions/runs/700';
  const guardToken = 'a'.repeat(64);
  const staleStatus = {
    state: 'success',
    description: `Validated base ${baselineSha}.`,
    targetUrl: sourceRunUrl,
    creatorLogin: 'github-actions',
  };
  const currentStatus = {
    state: 'success',
    description: `Validated base ${advancedSha}.`,
    targetUrl: newerRunUrl,
    creatorLogin: 'github-actions',
  };
  const sameBaselinePulls = [
    { number: 101, head: { sha: '3'.repeat(40) } },
    { number: 102, head: { sha: '4'.repeat(40) } },
  ];
  assert(sameBaselinePulls.filter(() =>
    requiresInvalidation(staleStatus, advancedSha)).length === 2,
  'Both same-baseline pull requests must be invalidated.');
  assert(!requiresInvalidation(currentStatus, advancedSha),
    'An older workflow-run signal must preserve a newer current success.');
  const pendingGuard = {
    state: 'pending',
    description: pendingGuardDescription(advancedSha, guardToken),
    targetUrl: guardRunUrl,
    creatorLogin: 'github-actions',
  };
  const successfulGuard = {
    state: 'success',
    description: successfulGuardDescription(advancedSha, guardToken),
    targetUrl: guardRunUrl,
    creatorLogin: 'github-actions',
  };
  assert(!mergeControlAccepts(staleStatus, pendingGuard, advancedSha,
    true, true) &&
    !mergeControlAccepts(currentStatus, pendingGuard, advancedSha,
      true, true) &&
    !mergeControlAccepts(currentStatus, {
      ...successfulGuard,
      description: successfulGuardDescription(baselineSha, guardToken),
    }, advancedSha, true, true) &&
    !mergeControlAccepts(currentStatus, successfulGuard, advancedSha,
      false, true) &&
    !mergeControlAccepts(currentStatus, successfulGuard, advancedSha,
      true, false) &&
    mergeControlAccepts(currentStatus, successfulGuard, advancedSha,
      true, true),
  'Merge control must reject old success while the live-base guard is pending, ' +
    'stale, or unauthenticated.');
  assert(statusContext(101) !== statusContext(102) &&
    statusContext(101) === 'Agent instruction current base/PR-101',
  'Status contexts must be stable and pull-request-specific.');
  const expected = {
    pullNumber: 101,
    baseRef: 'main',
    baseSha: advancedSha,
    headSha: sameBaselinePulls[0].head.sha,
  };
  const pull = {
    number: 101,
    state: 'open',
    base: { ref: 'main', sha: advancedSha },
    head: { sha: sameBaselinePulls[0].head.sha },
  };
  assert(isCurrentPull(pull,
    { object: { type: 'commit', sha: advancedSha } }, expected),
  'An exact live pull request must be current.');
  assert(!isCurrentPull(pull,
    { object: { type: 'commit', sha: baselineSha } }, expected),
  'A stale live base must fail finalization.');
  const workflowRun = {
    id: 501,
    event: 'push',
    path: validationWorkflowPath,
    head_branch: 'main',
    head_sha: advancedSha,
    status: 'requested',
    repository: { full_name: 'owner/repository' },
  };
  const workflowSignal = {
    activity: 'requested',
    runId: '501',
    branch: 'main',
    signalSha: advancedSha,
    repository: 'owner/repository',
  };
  assert(isAuthenticWorkflowRun(workflowRun, workflowSignal),
    'A requested signal must authenticate its initial live state.');
  assert(isAuthenticWorkflowRun({ ...workflowRun, status: 'completed' },
    workflowSignal),
  'A requested signal must accept an advanced live state.');
  assert(isAuthenticWorkflowRun({ ...workflowRun, status: 'completed' },
    { ...workflowSignal, activity: 'completed' }),
  'A completed signal must reconcile completed live state.');
  assert(!isAuthenticWorkflowRun({ ...workflowRun, status: 'in_progress' },
    { ...workflowSignal, activity: 'completed' }),
  'A completed signal must reject nonterminal live state.');
  assert(!isAuthenticWorkflowRun({ ...workflowRun, head_sha: baselineSha },
    workflowSignal),
  'A forged workflow-run signal must fail authentication.');
  assert(!isAuthenticWorkflowRun({
    ...workflowRun,
    repository: { full_name: 'other/repository' },
  }, workflowSignal),
  'A cross-repository workflow-run signal must fail authentication.');
  assert(!isAuthenticWorkflowRun(workflowRun,
    { ...workflowSignal, activity: 'in_progress' }),
  'An unsupported workflow-run activity must fail authentication.');
  const currentBaseRun = {
    id: 700,
    event: 'repository_dispatch',
    path: currentBaseWorkflowPath,
    head_branch: 'main',
    head_sha: advancedSha,
    display_title: continuationRunTitle('main', advancedSha, guardToken,
      advancedSha),
    status: 'completed',
    conclusion: 'success',
    repository: { full_name: 'owner/repository' },
  };
  assert(isAuthenticCurrentBaseRun(currentBaseRun, {
    runId: '700',
    eventName: 'repository_dispatch',
    defaultBranch: 'main',
    defaultSha: advancedSha,
    displayTitle: continuationRunTitle('main', advancedSha, guardToken,
      advancedSha),
    repository: 'owner/repository',
    requireSuccess: true,
  }), 'A successful continuation run must authenticate.');
  assert(!isAuthenticCurrentBaseRun({
    ...currentBaseRun,
    conclusion: 'failure',
  }, {
    runId: '700',
    eventName: 'repository_dispatch',
    defaultBranch: 'main',
    defaultSha: advancedSha,
    displayTitle: continuationRunTitle('main', advancedSha, guardToken,
      advancedSha),
    repository: 'owner/repository',
    requireSuccess: true,
  }), 'A failed continuation parent must not authenticate.');

  const githubRoot = normalizeApiRoot('https://api.github.com');
  const githubRequest = resolveApiRequestUrl(githubRoot,
    'repos/owner/repository/pulls?state=open&base=feature%2Fencoded');
  assert(githubRequest.origin === 'https://api.github.com' &&
    githubRequest.pathname === '/repos/owner/repository/pulls' &&
    githubRequest.search === '?state=open&base=feature%2Fencoded',
  'A GitHub.com API request must preserve its encoded query.');
  const enterpriseRoot = normalizeApiRoot('https://github.example/api/v3');
  const enterpriseRequest = resolveApiRequestUrl(enterpriseRoot,
    `repos/owner/repository/git/ref/heads/${encodeRef('feature/encoded branch')}`);
  assert(enterpriseRequest.origin === 'https://github.example' &&
    enterpriseRequest.pathname ===
      '/api/v3/repos/owner/repository/git/ref/heads/feature/encoded%20branch',
  'A GHES API request must preserve its API base and encoded branch path.');
  let rejectedPath = false;
  try {
    resolveApiRequestUrl(enterpriseRoot, '../outside');
  } catch (error) {
    rejectedPath = error.message === 'GitHub API request path is invalid.';
  }
  assert(rejectedPath, 'A relative traversal must fail API request validation.');
  let rejectedAbsolute = false;
  try {
    resolveApiRequestUrl(githubRoot,
      'https://api.github.com/repos/owner/repository');
  } catch (error) {
    rejectedAbsolute = error.message === 'GitHub API request path is invalid.';
  }
  assert(rejectedAbsolute, 'An absolute URL must fail API request validation.');

  const githubGraphqlRoot = normalizeGraphqlApiRoot(
    'https://api.github.com/graphql');
  assert(resolveApiRequestUrl(githubGraphqlRoot, 'graphql').href ===
    'https://api.github.com/graphql',
  'A GitHub.com GraphQL request must resolve relative to its API root.');
  const enterpriseGraphqlRoot = normalizeGraphqlApiRoot(
    'https://github.example/api/graphql');
  assert(resolveApiRequestUrl(enterpriseGraphqlRoot, 'graphql').href ===
    'https://github.example/api/graphql',
  'A GHES GraphQL request must resolve relative to its API root.');
  assert(openPullRequestsQuery.includes('pullRequests(') &&
    openPullRequestsQuery.includes('baseRefName: $baseRefName') &&
    openPullRequestsQuery.includes('states: OPEN') &&
    openPullRequestsQuery.includes('number') &&
    openPullRequestsQuery.includes('state') &&
    openPullRequestsQuery.includes('baseRepository') &&
    openPullRequestsQuery.includes('nameWithOwner') &&
    openPullRequestsQuery.includes('headRefOid') &&
    openPullRequestsQuery.includes('createdAt') &&
    openPullRequestsQuery.includes('pageInfo') &&
    openPullRequestsQuery.includes('$cursor: String') &&
    openPullRequestsQuery.includes('after: $cursor') &&
    openPullRequestsQuery.includes('endCursor') &&
    !/\bbody(?:HTML|Text)?\b/.test(openPullRequestsQuery),
  'The paginated pull-request query must project only bounded helper fields.');

  const firstPull = {
    number: 101,
    state: 'OPEN',
    baseRefName: 'main',
    baseRepository: { nameWithOwner: 'owner/repository' },
    headRefOid: '3'.repeat(40),
    createdAt: '2026-09-01T00:00:00Z',
  };
  const secondPull = {
    number: 102,
    state: 'OPEN',
    baseRefName: 'main',
    baseRepository: { nameWithOwner: 'owner/repository' },
    headRefOid: '4'.repeat(40),
    createdAt: '2026-09-02T00:00:00Z',
  };
  const pullPage = (nodes, totalCount, hasNextPage = false,
    endCursor = nodes.length === 0 ? null : `cursor-${nodes.at(-1).number}`) => ({
    data: { repository: { pullRequests: {
      totalCount,
      nodes,
      pageInfo: { hasNextPage, endCursor },
    } } },
  });
  const statusPage = (request, getLatest = () => null) => {
    const repository = {};
    for (let index = 0;
      Object.hasOwn(request.variables, `oid${index}`); index += 1) {
      const context = request.variables[`context${index}`];
      const pullNumber = Number(context.split('/PR-')[1]);
      const latest = getLatest(pullNumber, context);
      repository[`status${index}`] = {
        __typename: 'Commit',
        oid: request.variables[`oid${index}`],
        status: latest === null ? null : {
          latest: {
            context,
            state: latest.state.toUpperCase(),
            description: latest.description,
            targetUrl: latest.targetUrl,
            creator: latest.creatorLogin === null ? null : {
              login: latest.creatorLogin ?? 'github-actions',
            },
          },
        },
      };
    }
    return { data: { repository } };
  };
  const graphqlRequests = [];
  const projectedPage = await listOpenPullRequestPage({
    repository: 'owner/repository',
    graphql: async (payload) => {
      graphqlRequests.push(payload);
      return pullPage([firstPull, secondPull], 2);
    },
  }, 'main', null);
  assert(projectedPage.totalCount === 2 &&
    projectedPage.pulls.length === 2 &&
    projectedPage.pulls[0].head.sha === firstPull.headRefOid &&
    projectedPage.pulls[1].head.sha === secondPull.headRefOid &&
    graphqlRequests.length === 1 &&
    graphqlRequests[0].query === openPullRequestsQuery &&
    graphqlRequests[0].variables.owner === 'owner' &&
    graphqlRequests[0].variables.name === 'repository' &&
    graphqlRequests[0].variables.baseRefName === 'main' &&
    graphqlRequests[0].variables.pageSize === pullRequestPageSize &&
    graphqlRequests[0].variables.cursor === null,
  'The first paginated GraphQL query variables must remain exact.');

  const cappedPulls = Array.from({ length: pullRequestPageSize },
    (_, index) => ({
      ...firstPull,
      number: index + 1,
      headRefOid: (index + 1).toString(16).padStart(40, '0'),
      createdAt: `2026-09-01T00:00:${String(index).padStart(2, '0')}Z`,
    }));
  const boundedPage = await listOpenPullRequestPage({
    repository: 'owner/repository',
    graphql: async () => pullPage(cappedPulls, 21, true),
  }, 'main', null);
  assert(boundedPage.pulls.length === pullRequestPageSize &&
    boundedPage.totalCount === 21 && boundedPage.hasNextPage,
  'A 21-plus inventory must return one bounded continuation page.');
  await expectRejected(async () => listOpenPullRequestPage({
    repository: 'owner/repository',
    graphql: async () => pullPage(cappedPulls,
      maximumPullRequestsPerSweep + 1, true),
  }, 'main', null), 'GraphQL pull request connection is invalid.',
  'An inventory above the explicit whole-sweep bound must fail closed.');

  await expectRejected(async () => listOpenPullRequestPage({
    repository: 'owner/repository',
    graphql: async () => ({ errors: [{ message: 'denied' }], data: null }),
  }, 'main', null), 'GraphQL pull request response is invalid.',
  'A GraphQL error response must fail closed.');
  await expectRejected(async () => listOpenPullRequestPage({
    repository: 'owner/repository',
    graphql: async () => ({ data: { repository: { pullRequests: {
      totalCount: 1,
      nodes: 'not-an-array',
      pageInfo: { hasNextPage: false, endCursor: null },
    } } } }),
  }, 'main', null), 'GraphQL pull request connection is invalid.',
  'A malformed GraphQL connection must fail closed.');
  await expectRejected(async () => listOpenPullRequestPage({
    repository: 'owner/repository',
    graphql: async () => pullPage([firstPull, firstPull], 2),
  }, 'main', null), 'GraphQL pull request response entry is invalid.',
  'A duplicate GraphQL pull request must fail closed.');
  await expectRejected(async () => listOpenPullRequestPage({
    repository: 'owner/repository',
    graphql: async () => pullPage([firstPull], 21, true),
  }, 'main', null), 'GraphQL pull request connection is invalid.',
  'A non-full continuation page must fail closed.');

  const exactStatusRequest = createStatusContextRequest(
    'owner/repository', sameBaselinePulls);
  assert(exactStatusRequest.query.startsWith(
    'query ExactStatusContexts(') &&
    exactStatusRequest.query.includes('latest: context(name: $context0)') &&
    exactStatusRequest.query.includes('latest: context(name: $context1)') &&
    exactStatusRequest.query.includes('targetUrl') &&
    exactStatusRequest.variables.oid0 === sameBaselinePulls[0].head.sha &&
    exactStatusRequest.variables.context0 === statusContext(101) &&
    exactStatusRequest.variables.oid1 === sameBaselinePulls[1].head.sha &&
    exactStatusRequest.variables.context1 === statusContext(102),
  'Status reads must batch only exact PR-specific contexts.');
  const exactStatusResult = {
    data: { repository: {
      status0: {
        __typename: 'Commit',
        oid: sameBaselinePulls[0].head.sha,
        status: { latest: {
          context: statusContext(101),
          state: 'SUCCESS',
          description: `Validated base ${advancedSha}.`,
          targetUrl: newerRunUrl,
          creator: { login: 'github-actions' },
        } },
      },
      status1: {
        __typename: 'Commit',
        oid: sameBaselinePulls[1].head.sha,
        status: null,
      },
    } },
  };
  const exactStatuses = parseStatusContextResponse(
    exactStatusResult, sameBaselinePulls);
  assert(!requiresInvalidation(exactStatuses[0], advancedSha) &&
    exactStatuses[1] === null,
  'Exact status-context responses must preserve only current success.');
  await expectRejected(async () => parseStatusContextResponse({
    ...exactStatusResult,
    errors: [{ message: 'denied' }],
  }, sameBaselinePulls), 'GraphQL status-context response is invalid.',
  'A GraphQL status-context error must fail closed.');

  const exhaustedBudget = createRequestBudget(() => 0);
  for (let request = 0; request < maximumApiRequests; request += 1) {
    exhaustedBudget.beginRequest();
  }
  await expectRejected(async () => exhaustedBudget.beginRequest(),
    'GitHub API request budget would be exceeded.',
    'An exhausted global request budget must fail closed.');
  let virtualTime = 0;
  const slowBudget = createRequestBudget(() => virtualTime);
  slowBudget.beginRequest();
  virtualTime = maximumOperationMilliseconds - requestTimeoutMilliseconds + 1;
  await expectRejected(async () => slowBudget.beginRequest(),
    'GitHub API deadline cannot accommodate the remaining requests.',
    'A slow request sequence must fail before its deadline is exhausted.');

  assert(decodeApiResponse(200, Buffer.from('{"ok":true}')).ok === true,
    'A bounded JSON API response must parse.');
  await expectRejected(async () => decodeApiResponse(200,
    Buffer.from('{')), 'GitHub API returned malformed JSON.',
  'Malformed API JSON must fail closed.');
  await expectRejected(async () => decodeApiResponse(503,
    Buffer.from('{}')), 'GitHub API returned 503.',
  'An API error response must fail closed.');
  await expectRejected(async () => decodeApiResponse(200,
    Buffer.alloc(maximumResponseBytes + 1)),
  'GitHub API response is oversized.',
  'An oversized API response must fail closed.');

  const pendingWrites = [];
  const exactLiveClient = {
    request: async (method, path) => {
      assert(method === 'GET', 'Live-state reads must use GET.');
      if (path === 'repos/owner/repository') {
        return { full_name: 'owner/repository', default_branch: 'main' };
      }
      if (path.endsWith('/pulls/101')) return pull;
      if (path.includes('/actions/runs/700')) return currentBaseRun;
      return { object: { type: 'commit', sha: advancedSha } };
    },
    graphql: async (request) => statusPage(request, (_pullNumber, context) =>
      context === sweepGuardContext('main') ? successfulGuard : null),
    postStatus: async (...arguments_) => pendingWrites.push(arguments_),
    assertCanMutate: () => {},
    repository: 'owner/repository',
    serverOrigin: 'https://example.invalid',
  };
  await publishPending(exactLiveClient, expected, 'https://example.invalid/run');
  assert(pendingWrites.length === 1 &&
    pendingWrites[0][0] === expected.headSha &&
    pendingWrites[0][2] === 'pending' &&
    pendingWrites[0][3] === `Validating base ${expected.baseSha}.`,
  'The prerequisite writer must publish one pending exact-base status.');
  const incompleteGuardStartWrites = [];
  await publishPending({
    ...exactLiveClient,
    graphql: async (request) => statusPage(request, () => pendingGuard),
    postStatus: async (...arguments_) =>
      incompleteGuardStartWrites.push(arguments_),
  }, expected, 'https://example.invalid/run');
  assert(incompleteGuardStartWrites.length === 1 &&
    incompleteGuardStartWrites[0][2] === 'pending',
  'A pending or missing guard must not block validation from starting.');
  let mismatchWrites = 0;
  await expectRejected(async () => publishPending({
    ...exactLiveClient,
    request: async (method, path) => {
      assert(method === 'GET', 'Live-state reads must use GET.');
      if (path.endsWith('/pulls/101')) {
        return { ...pull, base: { ref: 'release', sha: advancedSha } };
      }
      return { object: { type: 'commit', sha: advancedSha } };
    },
    postStatus: async () => { mismatchWrites += 1; },
  }, expected, 'https://example.invalid/run'),
  'The pull request no longer has the expected base and head.',
  'A base edit before prerequisite publication must fail closed.');
  assert(mismatchWrites === 0,
    'A live prerequisite mismatch must not write a status.');
  let refReadCount = 0;
  const raceWrites = [];
  await expectRejected(async () => finalizeStatus({
    ...exactLiveClient,
    request: async (method, path) => {
      assert(method === 'GET', 'Live-state reads must use GET.');
      if (path === 'repos/owner/repository') {
        return { full_name: 'owner/repository', default_branch: 'main' };
      }
      if (path.endsWith('/pulls/101')) return pull;
      if (path.includes('/actions/runs/700')) return currentBaseRun;
      refReadCount += 1;
      return { object: { type: 'commit', sha:
        refReadCount === 1 ? advancedSha : baselineSha } };
    },
    postStatus: async (...arguments_) => raceWrites.push(arguments_),
  }, expected, 'success', 'https://example.invalid/run'),
  'The pull request changed while status was published.',
  'A base advance after success publication must fail closed.');
  assert(raceWrites.length === 2 && raceWrites[0][2] === 'success' &&
    raceWrites[1][2] === 'error',
  'A finalization race must replace transient success with an error.');

  const incompleteGuardFinalWrites = [];
  await expectRejected(async () => finalizeStatus({
    ...exactLiveClient,
    graphql: async (request) => statusPage(request, (_pullNumber, context) =>
      context === sweepGuardContext('main') ? pendingGuard : currentStatus),
    postStatus: async (...arguments_) =>
      incompleteGuardFinalWrites.push(arguments_),
  }, expected, 'success', newerRunUrl),
  'The live-base sweep guard is not successful.',
  'Validation must not publish success before the guard succeeds.');
  assert(!incompleteGuardFinalWrites.some((write) => write[2] === 'success'),
    'An incomplete guard must prevent per-PR success publication.');

  const completedGuardFinalWrites = [];
  await finalizeStatus({
    ...exactLiveClient,
    postStatus: async (...arguments_) =>
      completedGuardFinalWrites.push(arguments_),
  }, expected, 'success', newerRunUrl);
  assert(completedGuardFinalWrites.length === 1 &&
    completedGuardFinalWrites[0][2] === 'success',
  'A validation rerun may publish success after the guard succeeds.');

  const oldExpected = { ...expected, baseSha: baselineSha };
  const pullRequestRun = (id, runNumber, runAttempt, endpoints,
    status = 'completed') => ({
    id,
    run_number: runNumber,
    run_attempt: runAttempt,
    event: 'pull_request_target',
    path: '.github/workflows/agent-instructions.yml',
    status,
    head_sha: endpoints.headSha,
    repository: { full_name: 'owner/repository' },
    pull_requests: [{
      number: endpoints.pullNumber,
      base: {
        ref: endpoints.baseRef,
        sha: endpoints.baseSha,
        repo: { full_name: 'owner/repository' },
      },
      head: {
        sha: endpoints.headSha,
        repo: { full_name: 'owner/repository' },
      },
    }],
  });
  const sourceOldRun = pullRequestRun(600, 50, 1, oldExpected);
  const sourceCurrentRun = pullRequestRun(600, 50, 1, expected);
  const newerCurrentRun = pullRequestRun(601, 51, 1, expected);
  const createFreshnessClient = ({
    sourceRun = sourceOldRun,
    candidateRun = newerCurrentRun,
    latest = currentStatus,
    reservation = () => {},
    failCandidateRead = false,
  } = {}) => ({
    ...exactLiveClient,
    request: async (method, path) => {
      assert(method === 'GET', 'Freshness reads must use GET.');
      if (path === 'repos/owner/repository') {
        return { full_name: 'owner/repository', default_branch: 'main' };
      }
      if (path.endsWith('/pulls/101')) return pull;
      if (path.includes('/actions/runs/600')) return sourceRun;
      if (path.includes('/actions/runs/601')) {
        if (failCandidateRead) throw new Error('simulated API failure');
        return candidateRun;
      }
      if (path.includes('/actions/runs/700')) return currentBaseRun;
      return { object: { type: 'commit', sha: advancedSha } };
    },
    graphql: async (request) => statusPage(request, (_pullNumber, context) =>
      context === sweepGuardContext('main') ? successfulGuard : latest),
    assertCanMutate: reservation,
  });

  const sameEndpointWrites = [];
  await expectRejected(async () => finalizeStatus({
    ...createFreshnessClient({ sourceRun: sourceCurrentRun }),
    postStatus: async (...arguments_) => sameEndpointWrites.push(arguments_),
  }, expected, 'failure', sourceRunUrl),
  'Agent-instruction validation did not succeed.',
  'A failed older run on the same endpoint must remain failed.');
  assert(sameEndpointWrites.length === 0,
    'A strictly newer authenticated same-endpoint success must be preserved.');

  const newerSuccessClient = createFreshnessClient();
  assert(parseActionsRunTarget(sourceRunUrl, 'owner/repository').runId ===
    '600' && isAuthenticPullRequestWorkflowRun(sourceOldRun,
    { ...oldExpected, repository: 'owner/repository' }, '600') &&
    isStrictlyLaterWorkflowRun(newerCurrentRun, sourceOldRun),
  'Actions-run provenance must authenticate before freshness comparison.');
  await expectRejected(async () => parseActionsRunTarget(
    'https://evil.invalid/owner/repository/actions/runs/601',
    'owner/repository', 'https://example.invalid'),
  'Status target does not identify an Actions run.',
  'A cross-origin Actions-run target must fail closed.');

  const oldFailureWrites = [];
  const oldFailureReservations = [];
  await expectRejected(async () => finalizeStatus({
    ...createFreshnessClient({
      reservation: (count) => oldFailureReservations.push(count),
    }),
    postStatus: async (...arguments_) => oldFailureWrites.push(arguments_),
  }, oldExpected, 'failure', sourceRunUrl),
  'Agent-instruction validation did not succeed.',
  'An old failure finalizer must still terminate as failed.');
  assert(oldFailureWrites.length === 0 &&
    oldFailureReservations.length === 1 && oldFailureReservations[0] === 6,
  'An old finalizer must reserve guard and run reads and preserve newer success.');

  const oldMismatchWrites = [];
  await expectRejected(async () => finalizeStatus({
    ...newerSuccessClient,
    postStatus: async (...arguments_) => oldMismatchWrites.push(arguments_),
  }, oldExpected, 'success', sourceRunUrl),
  'The pull request no longer has the validated base and head.',
  'An old success-path mismatch must terminate as stale.');
  assert(oldMismatchWrites.length === 0,
  'An old success-path mismatch must preserve newer authenticated success.');

  const olderSuccessWrites = [];
  await expectRejected(async () => finalizeStatus({
    ...createFreshnessClient({
      candidateRun: pullRequestRun(601, 49, 3, expected),
    }),
    postStatus: async (...arguments_) => olderSuccessWrites.push(arguments_),
  }, oldExpected, 'failure', sourceRunUrl),
  'Agent-instruction validation did not succeed.',
  'An older claimed success must not preserve status.');
  assert(olderSuccessWrites.length === 1 &&
    olderSuccessWrites[0][2] === 'error',
  'An older authenticated run must fail closed with an error status.');

  const newerFailureWrites = [];
  await expectRejected(async () => finalizeStatus({
    ...createFreshnessClient({
      latest: { ...currentStatus, state: 'failure' },
    }),
    postStatus: async (...arguments_) => newerFailureWrites.push(arguments_),
  }, oldExpected, 'failure', sourceRunUrl),
  'Agent-instruction validation did not succeed.',
  'A newer failure must not preserve an earlier success.');
  assert(newerFailureWrites.length === 1 &&
    newerFailureWrites[0][2] === 'error',
  'A newer failure must publish a fail-closed error.');

  const malformedProvenanceWrites = [];
  await expectRejected(async () => finalizeStatus({
    ...createFreshnessClient({
      latest: { ...currentStatus, targetUrl: 'https://example.invalid/run' },
    }),
    postStatus: async (...arguments_) =>
      malformedProvenanceWrites.push(arguments_),
  }, oldExpected, 'failure', sourceRunUrl),
  'Agent-instruction validation did not succeed.',
  'Malformed status provenance must not preserve success.');
  assert(malformedProvenanceWrites.length === 1 &&
    malformedProvenanceWrites[0][2] === 'error',
  'Malformed status provenance must fail closed with an error status.');

  const changedBaseRunWrites = [];
  await expectRejected(async () => finalizeStatus({
    ...createFreshnessClient({
      candidateRun: pullRequestRun(601, 51, 1,
        { ...expected, baseSha: baselineSha }),
    }),
    postStatus: async (...arguments_) => changedBaseRunWrites.push(arguments_),
  }, oldExpected, 'failure', sourceRunUrl),
  'Agent-instruction validation did not succeed.',
  'A candidate run for a different base must not preserve status.');
  assert(changedBaseRunWrites.length === 1 &&
    changedBaseRunWrites[0][2] === 'error',
  'A run whose base provenance changed must fail closed.');

  const freshnessApiFailureWrites = [];
  await expectRejected(async () => finalizeStatus({
    ...createFreshnessClient({ failCandidateRead: true }),
    postStatus: async (...arguments_) =>
      freshnessApiFailureWrites.push(arguments_),
  }, oldExpected, 'failure', sourceRunUrl),
  'Agent-instruction validation did not succeed.',
  'A freshness API failure must keep the finalizer failed.');
  assert(freshnessApiFailureWrites.length === 1 &&
    freshnessApiFailureWrites[0][2] === 'error',
  'An indeterminate run read must fail closed with an error status.');

  for (const exhaustedMessage of [
    'GitHub API request budget would be exceeded.',
    'GitHub API deadline cannot accommodate the remaining requests.',
  ]) {
    const exhaustedWrites = [];
    await expectRejected(async () => finalizeStatus({
      ...createFreshnessClient({
        reservation: (count) => {
          if (count === 6) throw new Error(exhaustedMessage);
        },
      }),
      postStatus: async (...arguments_) => exhaustedWrites.push(arguments_),
    }, oldExpected, 'failure', sourceRunUrl),
    'Agent-instruction validation did not succeed.',
    'A failed freshness reservation must keep the finalizer failed.');
    assert(exhaustedWrites.length === 1 && exhaustedWrites[0][2] === 'error',
      'Request or deadline exhaustion must fail closed with an error status.');
  };

  const noNewerSuccessWrites = [];
  await expectRejected(async () => finalizeStatus({
    ...newerSuccessClient,
    graphql: async (request) => statusPage(request, () => staleStatus),
    postStatus: async (...arguments_) =>
      noNewerSuccessWrites.push(arguments_),
  }, oldExpected, 'failure', sourceRunUrl),
  'Agent-instruction validation did not succeed.',
  'A finalizer without newer success must terminate as failed.');
  assert(noNewerSuccessWrites.length === 1 &&
    noNewerSuccessWrites[0][2] === 'error',
  'A stale status must not suppress a finalizer error.');

  const successfulPullRun = {
    ...newerCurrentRun,
    status: 'completed',
    conclusion: 'success',
  };
  const createMergeClient = ({
    pullStatus = currentStatus,
    guard = successfulGuard,
    pullRun = successfulPullRun,
    guardRun = currentBaseRun,
    liveRace = false,
    baseRace = false,
    statusRace = false,
  } = {}) => {
    let pullReadCount = 0;
    let statusReadCount = 0;
    return {
      repository: 'owner/repository',
      serverOrigin: 'https://example.invalid',
      assertCanRequest: (count) => assert(count === 10,
        'Merge verification must reserve its exact read-only request bound.'),
      request: async (method, path) => {
        assert(method === 'GET', 'Merge verification must use only GET.');
        if (path === 'repos/owner/repository') {
          return { full_name: 'owner/repository', default_branch: 'main' };
        }
        if (path.endsWith('/pulls/101')) {
          pullReadCount += 1;
          if (liveRace && pullReadCount > 1) {
            return { ...pull, head: { sha: '9'.repeat(40) } };
          }
          if (baseRace && pullReadCount > 1) {
            return { ...pull, base: { ref: 'main', sha: baselineSha } };
          }
          return pull;
        }
        if (path.includes('/git/ref/heads/main')) {
          return { object: { type: 'commit', sha:
            baseRace && pullReadCount > 1 ? baselineSha : advancedSha } };
        }
        if (path.endsWith('/actions/runs/601')) return pullRun;
        if (path.endsWith('/actions/runs/700')) return guardRun;
        throw new Error('Merge verification requested an unexpected resource.');
      },
      graphql: async (request) => {
        statusReadCount += 1;
        const observedPullStatus = statusRace && statusReadCount > 1 ? {
          ...pullStatus,
          state: 'pending',
        } : pullStatus;
        return statusPage(request, (_pullNumber, context) =>
          context === sweepGuardContext('main') ? guard :
            observedPullStatus);
      },
    };
  };

  await verifyMergeEvidence(createMergeClient(), 101);
  const mergeEvidenceFailures = [{
    name: 'pending guard',
    client: createMergeClient({ guard: pendingGuard }),
    message: 'Merge evidence is incomplete or unauthenticated.',
  }, {
    name: 'stale guard',
    client: createMergeClient({ guard: {
      ...successfulGuard,
      description: successfulGuardDescription(baselineSha, guardToken),
    } }),
    message: 'Merge evidence is incomplete or unauthenticated.',
  }, {
    name: 'missing guard',
    client: createMergeClient({ guard: null }),
    message: 'Merge evidence is incomplete or unauthenticated.',
  }, {
    name: 'stale PR status',
    client: createMergeClient({ pullStatus: staleStatus }),
    message: 'Merge evidence is incomplete or unauthenticated.',
  }, {
    name: 'missing PR status',
    client: createMergeClient({ pullStatus: null }),
    message: 'Merge evidence is incomplete or unauthenticated.',
  }, {
    name: 'non-Actions status creator',
    client: createMergeClient({ pullStatus: {
      ...currentStatus,
      creatorLogin: 'octocat',
    } }),
    message: 'Merge evidence is incomplete or unauthenticated.',
  }, {
    name: 'failed validation run',
    client: createMergeClient({ pullRun: {
      ...successfulPullRun,
      conclusion: 'failure',
    } }),
    message: 'Merge evidence is incomplete or unauthenticated.',
  }, {
    name: 'wrong validation workflow',
    client: createMergeClient({ pullRun: {
      ...successfulPullRun,
      path: '.github/workflows/other.yml',
    } }),
    message: 'Merge evidence is incomplete or unauthenticated.',
  }, {
    name: 'cross-repository validation run',
    client: createMergeClient({ pullRun: {
      ...successfulPullRun,
      repository: { full_name: 'other/repository' },
    } }),
    message: 'Merge evidence is incomplete or unauthenticated.',
  }, {
    name: 'failed guard run',
    client: createMergeClient({ guardRun: {
      ...currentBaseRun,
      conclusion: 'failure',
    } }),
    message: 'Merge evidence is incomplete or unauthenticated.',
  }, {
    name: 'wrong guard workflow',
    client: createMergeClient({ guardRun: {
      ...currentBaseRun,
      path: '.github/workflows/other.yml',
    } }),
    message: 'Merge evidence is incomplete or unauthenticated.',
  }, {
    name: 'cross-repository guard run',
    client: createMergeClient({ guardRun: {
      ...currentBaseRun,
      repository: { full_name: 'other/repository' },
    } }),
    message: 'Merge evidence is incomplete or unauthenticated.',
  }, {
    name: 'wrong guard event',
    client: createMergeClient({ guardRun: {
      ...currentBaseRun,
      event: 'workflow_dispatch',
    } }),
    message: 'Merge evidence is incomplete or unauthenticated.',
  }, {
    name: 'wrong guard default branch',
    client: createMergeClient({ guardRun: {
      ...currentBaseRun,
      head_branch: 'release',
    } }),
    message: 'Merge evidence is incomplete or unauthenticated.',
  }, {
    name: 'substituted guard target',
    client: createMergeClient({ guard: {
      ...successfulGuard,
      targetUrl: newerRunUrl,
    } }),
    message: 'Merge evidence is incomplete or unauthenticated.',
  }, {
    name: 'cross-origin PR target',
    client: createMergeClient({ pullStatus: {
      ...currentStatus,
      targetUrl: 'https://evil.invalid/owner/repository/actions/runs/601',
    } }),
    message: 'Status target does not identify an Actions run.',
  }, {
    name: 'live-state race',
    client: createMergeClient({ liveRace: true }),
    message: 'Live merge evidence changed during verification.',
  }, {
    name: 'live-base race',
    client: createMergeClient({ baseRace: true }),
    message: 'Live merge evidence changed during verification.',
  }, {
    name: 'status race',
    client: createMergeClient({ statusRace: true }),
    message: 'Live merge evidence changed during verification.',
  }];
  for (const failure of mergeEvidenceFailures) {
    await expectRejected(async () => verifyMergeEvidence(failure.client, 101),
      failure.message,
      `Merge verification must reject ${failure.name}.`);
  }

  const sweepPulls = Array.from({ length: 21 }, (_, index) => ({
    ...firstPull,
    number: index + 1,
    headRefOid: (index + 1).toString(16).padStart(40, '0'),
    createdAt: `2026-09-01T00:00:${String(index).padStart(2, '0')}Z`,
  }));
  const createSweepHarness = ({ pulls = sweepPulls,
    dispatchFailureAt = null, openQueryFailure = false,
    statusFailureAt = null, deletedBranch = false } = {}) => {
    const state = {
      pulls: [...pulls],
      baseSha: advancedSha,
      defaultBranch: 'main',
      defaultSha: advancedSha,
      guard: null,
      runs: new Map(),
      dispatches: [],
      dispatchAttempts: 0,
      events: [],
      guardWrites: [],
      statusWrites: [],
      statuses: new Map(pulls.map((item) => [item.number, staleStatus])),
    };
    state.runs.set('501', { ...workflowRun });

    const currentBaseRunFor = (id, eventName, displayTitle,
      status = 'requested', conclusion = null) => ({
      id: Number(id),
      event: eventName,
      path: currentBaseWorkflowPath,
      head_branch: state.defaultBranch,
      head_sha: state.defaultSha,
      ...(displayTitle === undefined ? {} : { display_title: displayTitle }),
      status,
      conclusion,
      repository: { full_name: 'owner/repository' },
    });
    const addRun = (id, eventName, displayTitle) => {
      state.runs.set(id, currentBaseRunFor(id, eventName, displayTitle));
    };
    const completeRun = (id) => {
      const run = state.runs.get(id);
      state.runs.set(id, { ...run, status: 'completed', conclusion: 'success' });
    };
    const createInvocationClient = () => {
      let requestCount = 0;
      const beginRequest = () => {
        requestCount += 1;
        assert(requestCount <= maximumApiRequests,
          'A sweep invocation exceeded its request bound.');
      };
      return {
        repository: 'owner/repository',
        serverOrigin: 'https://example.invalid',
        get requestCount() { return requestCount; },
        assertCanMutate: (count) => {
          assert(requestCount + count <= maximumApiRequests,
            'A sweep reservation exceeded its request bound.');
        },
        assertCanRequest: (count) => {
          assert(requestCount + count <= maximumApiRequests,
            'A sweep reservation exceeded its request bound.');
        },
        request: async (method, path) => {
          beginRequest();
          assert(method === 'GET', 'Sweep REST reads must use GET.');
          if (path === 'repos/owner/repository') {
            return {
              full_name: 'owner/repository',
              default_branch: state.defaultBranch,
            };
          }
          if (path.includes('/actions/runs/')) {
            const runId = path.split('/').at(-1);
            assert(state.runs.has(runId), 'The sweep requested an unknown run.');
            return state.runs.get(runId);
          }
          if (path.includes('/git/ref/heads/')) {
            if (deletedBranch) return null;
            return { object: { type: 'commit', sha: state.baseSha } };
          }
          throw new Error('The sweep requested an unexpected REST resource.');
        },
        graphql: async (request) => {
          beginRequest();
          if (request.query === openPullRequestsQuery) {
            state.events.push('enumerate');
            if (openQueryFailure) throw new Error('GitHub API request timed out.');
            const cursor = request.variables.cursor;
            const offset = cursor === null ? 0 : Number(cursor.split('-')[1]);
            const nodes = state.pulls.slice(offset, offset + pullRequestPageSize);
            const nextOffset = offset + nodes.length;
            return pullPage(nodes, state.pulls.length,
              nextOffset < state.pulls.length,
              nodes.length === 0 ? null : `cursor-${nextOffset}`);
          }
          return statusPage(request, (pullNumber, context) =>
            context === sweepGuardContext('main') ? state.guard :
              state.statuses.get(pullNumber) ?? null);
        },
        postStatus: async (headSha, pullNumber, status, description,
          targetUrl) => {
          beginRequest();
          if (statusFailureAt !== null &&
            state.statusWrites.length + 1 === statusFailureAt) {
            throw new Error('simulated partial batch failure');
          }
          const latest = {
            state: status,
            description,
            targetUrl,
            creatorLogin: 'github-actions',
          };
          state.statuses.set(pullNumber, latest);
          state.statusWrites.push({ headSha, pullNumber, ...latest });
          state.events.push(`status:${pullNumber}:${status}`);
        },
        postStatusAtContext: async (sha, context, status, description,
          targetUrl) => {
          beginRequest();
          const latest = {
            state: status,
            description,
            targetUrl,
            creatorLogin: 'github-actions',
          };
          assert(sha === advancedSha && context === sweepGuardContext('main'),
            'The sweep guard write must use the live base and branch context.');
          state.guard = latest;
          state.guardWrites.push(latest);
          state.events.push(`guard:${status}`);
        },
        dispatchRepository: async (eventType, payload) => {
          beginRequest();
          state.dispatchAttempts += 1;
          if (dispatchFailureAt === state.dispatchAttempts) {
            throw new Error('simulated dispatch failure');
          }
          state.dispatches.push({ eventType, payload });
        },
      };
    };
    const rootSignal = (runId) => {
      addRun(runId, 'workflow_run');
      return {
        eventName: 'workflow_run',
        currentRunId: runId,
        currentRunRef: 'main',
        currentRunSha: advancedSha,
        eventType: null,
        clientPayloadText: null,
        sourceActivity: 'requested',
        sourceRunId: '501',
        branch: 'main',
        signalSha: advancedSha,
        targetUrl: `https://example.invalid/owner/repository/actions/runs/${runId}`,
      };
    };
    const signalFromDispatch = (dispatch, runId) => {
      const { eventType, payload } = dispatch;
      const displayTitle = eventType === bootstrapEventType ?
        bootstrapRunTitle(payload.branch, state.defaultSha) :
        continuationRunTitle(payload.session.branch,
          payload.session.base_sha, payload.state_token, state.defaultSha);
      addRun(runId, 'repository_dispatch', displayTitle);
      return {
        eventName: 'repository_dispatch',
        currentRunId: runId,
        currentRunRef: state.defaultBranch,
        currentRunSha: state.defaultSha,
        eventType,
        clientPayloadText: JSON.stringify(payload),
        sourceActivity: null,
        sourceRunId: null,
        branch: null,
        signalSha: null,
        targetUrl: `https://example.invalid/owner/repository/actions/runs/${runId}`,
      };
    };
    return {
      state,
      completeRun,
      createInvocationClient,
      rootSignal,
      signalFromDispatch,
    };
  };

  const completeHarness = createSweepHarness();
  let nextSignal = completeHarness.rootSignal('800');
  let dispatchIndex = 0;
  const invocationRequestCounts = [];
  while (nextSignal !== null) {
    const client = completeHarness.createInvocationClient();
    await invalidateStatuses(client, nextSignal);
    invocationRequestCounts.push(client.requestCount);
    completeHarness.completeRun(nextSignal.currentRunId);
    if (dispatchIndex < completeHarness.state.dispatches.length) {
      const dispatch = completeHarness.state.dispatches[dispatchIndex];
      dispatchIndex += 1;
      nextSignal = completeHarness.signalFromDispatch(dispatch,
        String(800 + dispatchIndex));
    } else {
      nextSignal = null;
    }
  }
  assert(completeHarness.state.statusWrites.length === 21 &&
    completeHarness.state.dispatches.length === 6 &&
    invocationRequestCounts.length === 7 &&
    invocationRequestCounts.every((count) => count <= maximumApiRequests) &&
    completeHarness.state.events.indexOf('guard:pending') <
      completeHarness.state.events.indexOf('enumerate') &&
    completeHarness.state.events.at(-1) === 'guard:success' &&
    completeHarness.state.guard.state === 'success' &&
    guardMatchesBase(completeHarness.state.guard, advancedSha) &&
    [...completeHarness.state.statuses.values()].every((latest) =>
      latest.state === 'error'),
  'A 21-PR sweep must invalidate every stale status in bounded continuations.');
  const completedGuardToken = successfulGuardToken(
    completeHarness.state.guard, advancedSha);
  const completedGuardTarget = parseActionsRunTarget(
    completeHarness.state.guard.targetUrl, 'owner/repository',
    'https://example.invalid');
  const completedGuardRun = completeHarness.state.runs.get(
    completedGuardTarget.runId);
  assert(digestPattern.test(completedGuardToken) &&
    isSuccessfulSweepRun(completedGuardRun, completedGuardTarget.runId,
      'owner/repository', 'main', advancedSha, completedGuardToken, 'main'),
  'Guard success must bind the exact final repository-dispatch run and state.');

  const bootstrapHarness = createSweepHarness();
  const bootstrapRequest = {
    eventType: bootstrapEventType,
    payload: { protocol: dispatchProtocol, branch: 'main' },
  };
  let bootstrapSignal = bootstrapHarness.signalFromDispatch(bootstrapRequest,
    '850');
  let bootstrapDispatchIndex = 0;
  while (bootstrapSignal !== null) {
    await invalidateStatuses(bootstrapHarness.createInvocationClient(),
      bootstrapSignal);
    bootstrapHarness.completeRun(bootstrapSignal.currentRunId);
    if (bootstrapDispatchIndex < bootstrapHarness.state.dispatches.length) {
      const dispatch = bootstrapHarness.state.dispatches[
        bootstrapDispatchIndex];
      bootstrapDispatchIndex += 1;
      bootstrapSignal = bootstrapHarness.signalFromDispatch(dispatch,
        String(850 + bootstrapDispatchIndex));
    } else {
      bootstrapSignal = null;
    }
  }
  assert(bootstrapHarness.state.statusWrites.length === 21 &&
    guardMatchesBase(bootstrapHarness.state.guard, advancedSha),
  'A bootstrap must sweep an existing 21-plus PR base without a prior guard.');
  const repeatedGuardWriteCount = bootstrapHarness.state.guardWrites.length;
  const repeatedDispatchCount = bootstrapHarness.state.dispatches.length;
  const repeatedBootstrap = bootstrapHarness.signalFromDispatch(
    bootstrapRequest, '860');
  await invalidateStatuses(bootstrapHarness.createInvocationClient(),
    repeatedBootstrap);
  assert(bootstrapHarness.state.guardWrites.length === repeatedGuardWriteCount &&
    bootstrapHarness.state.dispatches.length === repeatedDispatchCount,
  'A repeated bootstrap must preserve an authenticated completed guard.');

  const deletedBranchHarness = createSweepHarness({ deletedBranch: true });
  const deletedBootstrap = deletedBranchHarness.signalFromDispatch(
    bootstrapRequest, '870');
  await expectRejected(async () => invalidateStatuses(
    deletedBranchHarness.createInvocationClient(), deletedBootstrap),
  'The bootstrap branch does not exist.',
  'A bootstrap for a deleted branch must fail closed.');
  assert(deletedBranchHarness.state.guardWrites.length === 0,
    'A deleted bootstrap branch must not publish guard success.');

  const malformedBootstrapHarness = createSweepHarness();
  const malformedBootstrap = malformedBootstrapHarness.signalFromDispatch({
    eventType: bootstrapEventType,
    payload: { protocol: dispatchProtocol, branch: 'main', extra: true },
  }, '880');
  await expectRejected(async () => invalidateStatuses(
    malformedBootstrapHarness.createInvocationClient(), malformedBootstrap),
  'Repository dispatch payload is invalid.',
  'A bootstrap with extra payload state must fail closed.');
  const crossRepositoryBootstrapHarness = createSweepHarness();
  const crossRepositoryBootstrap =
    crossRepositoryBootstrapHarness.signalFromDispatch(bootstrapRequest,
      '890');
  crossRepositoryBootstrapHarness.state.runs.get('890').repository = {
    full_name: 'other/repository',
  };
  await expectRejected(async () => invalidateStatuses(
    crossRepositoryBootstrapHarness.createInvocationClient(),
    crossRepositoryBootstrap),
  'Current-base workflow run does not match its live record.',
  'A cross-repository bootstrap run must fail authentication.');

  const validContinuationPayload = continuationPayload({
    repository: 'owner/repository',
    branch: 'main',
    baseSha: advancedSha,
    defaultBranch: 'main',
  }, createInitialProgress(), '700', advancedSha, null);
  for (const malformedPayloadText of [
    JSON.stringify({ ...validContinuationPayload, extra: true }),
    JSON.stringify({
      ...validContinuationPayload,
      progress: { ...validContinuationPayload.progress, digest: undefined },
    }),
    JSON.stringify({
      ...validContinuationPayload,
      progress: { ...validContinuationPayload.progress, repaired: 'false' },
    }),
    JSON.stringify({
      ...validContinuationPayload,
      parent: { ...validContinuationPayload.parent, run_id: 700 },
    }),
    'x'.repeat(maximumDispatchPayloadBytes + 1),
  ]) {
    await expectRejected(async () => parseDispatchPayloadText(
      malformedPayloadText, continuationEventType, 'owner/repository'),
    'Repository dispatch payload is invalid.',
    'Malformed, extra, missing, or oversized continuation state must fail.');
  }

  const dispatchFailureHarness = createSweepHarness({
    pulls: sweepPulls.slice(0, 11),
    dispatchFailureAt: 2,
  });
  const dispatchFailureRoot = dispatchFailureHarness.rootSignal('900');
  await invalidateStatuses(dispatchFailureHarness.createInvocationClient(),
    dispatchFailureRoot);
  dispatchFailureHarness.completeRun('900');
  const dispatchFailureBootstrap = dispatchFailureHarness.signalFromDispatch(
    dispatchFailureHarness.state.dispatches[0], '901');
  await expectRejected(async () => invalidateStatuses(
    dispatchFailureHarness.createInvocationClient(),
    dispatchFailureBootstrap),
  'simulated dispatch failure',
  'A continuation dispatch failure must fail the active sweep.');
  assert(dispatchFailureHarness.state.guard.state === 'pending' &&
    !dispatchFailureHarness.state.guardWrites.some((write) =>
      write.state === 'success'),
  'A dispatch failure must leave the live-base guard incomplete.');

  const timeoutHarness = createSweepHarness({ openQueryFailure: true });
  const timeoutRoot = timeoutHarness.rootSignal('910');
  await invalidateStatuses(timeoutHarness.createInvocationClient(), timeoutRoot);
  timeoutHarness.completeRun('910');
  const timeoutBootstrap = timeoutHarness.signalFromDispatch(
    timeoutHarness.state.dispatches[0], '911');
  await expectRejected(async () => invalidateStatuses(
    timeoutHarness.createInvocationClient(), timeoutBootstrap),
  'GitHub API request timed out.',
  'An API timeout must fail the active sweep.');
  assert(timeoutHarness.state.guard.state === 'pending' &&
    timeoutHarness.state.statusWrites.length === 0,
  'An API timeout must not publish invalidation or guard success.');

  const partialHarness = createSweepHarness({
    pulls: sweepPulls.slice(0, 2),
    statusFailureAt: 2,
  });
  const partialRoot = partialHarness.rootSignal('920');
  await invalidateStatuses(partialHarness.createInvocationClient(), partialRoot);
  partialHarness.completeRun('920');
  const partialBootstrap = partialHarness.signalFromDispatch(
    partialHarness.state.dispatches[0], '921');
  await expectRejected(async () => invalidateStatuses(
    partialHarness.createInvocationClient(), partialBootstrap),
  'simulated partial batch failure',
  'A partial batch failure must fail the active sweep.');
  assert(partialHarness.state.statusWrites.length === 1 &&
    partialHarness.state.guard.state === 'pending',
  'A partial batch failure must never publish guard success.');

  const staleBaseHarness = createSweepHarness({
    pulls: sweepPulls.slice(0, 11),
  });
  const staleRoot = staleBaseHarness.rootSignal('930');
  await invalidateStatuses(staleBaseHarness.createInvocationClient(), staleRoot);
  staleBaseHarness.completeRun('930');
  const staleBootstrap = staleBaseHarness.signalFromDispatch(
    staleBaseHarness.state.dispatches[0], '931');
  await invalidateStatuses(staleBaseHarness.createInvocationClient(),
    staleBootstrap);
  staleBaseHarness.completeRun('931');
  const staleContinuation = staleBaseHarness.signalFromDispatch(
    staleBaseHarness.state.dispatches[1], '932');
  staleBaseHarness.state.baseSha = baselineSha;
  await expectRejected(async () => invalidateStatuses(
    staleBaseHarness.createInvocationClient(), staleContinuation),
  'The continuation base is stale.',
  'A continuation for a stale live base must fail authentication.');
  assert(staleBaseHarness.state.guard.state === 'pending' &&
    !staleBaseHarness.state.guardWrites.some((write) =>
      write.state === 'success'),
  'A stale-base continuation must not publish guard success.');

  const replayHarness = createSweepHarness({ pulls: sweepPulls.slice(0, 11) });
  const replayRoot = replayHarness.rootSignal('940');
  await invalidateStatuses(replayHarness.createInvocationClient(), replayRoot);
  replayHarness.completeRun('940');
  const replayBootstrap = replayHarness.signalFromDispatch(
    replayHarness.state.dispatches[0], '941');
  await invalidateStatuses(replayHarness.createInvocationClient(),
    replayBootstrap);
  replayHarness.completeRun('941');
  const replayContinuation = replayHarness.signalFromDispatch(
    replayHarness.state.dispatches[1], '942');
  replayHarness.state.guard = {
    ...replayHarness.state.guard,
    targetUrl: 'https://example.invalid/owner/repository/actions/runs/999',
  };
  await expectRejected(async () => invalidateStatuses(
    replayHarness.createInvocationClient(), replayContinuation),
  'Continuation state is stale or replayed.',
  'A replayed continuation must fail its exact guard claim.');
  assert(!replayHarness.state.guardWrites.some((write) =>
    write.state === 'success'),
  'A replayed continuation must not publish guard success.');

  const churnHarness = createSweepHarness({ pulls: sweepPulls.slice(0, 11) });
  const churnRoot = churnHarness.rootSignal('950');
  await invalidateStatuses(churnHarness.createInvocationClient(), churnRoot);
  churnHarness.completeRun('950');
  const churnBootstrap = churnHarness.signalFromDispatch(
    churnHarness.state.dispatches[0], '951');
  await invalidateStatuses(churnHarness.createInvocationClient(),
    churnBootstrap);
  churnHarness.completeRun('951');
  const churnContinuationDispatch = churnHarness.state.dispatches[1];
  const churnContinuation = churnHarness.signalFromDispatch(
    churnContinuationDispatch, '952');
  churnHarness.state.pulls.push(sweepPulls[11]);
  await invalidateStatuses(churnHarness.createInvocationClient(),
    churnContinuation);
  const restartDispatch = churnHarness.state.dispatches.at(-1);
  assert(restartDispatch.payload.progress.restart_count === 1 &&
    restartDispatch.payload.progress.phase === 'invalidate' &&
    restartDispatch.payload.progress.cursor === null,
  'Pagination churn must trigger a bounded sweep restart.');
  const maximumRestartProgress = {
    ...createInitialProgress('invalidate', maximumSweepRestarts),
    cursor: 'cursor-10',
    totalCount: 11,
    seenCount: 10,
    digest: extendSnapshotDigest(initialSnapshotDigest,
      sweepPulls.slice(0, 10).map((item) => ({
        number: item.number,
        head: { sha: item.headRefOid },
        createdAt: item.createdAt,
      }))),
  };
  const parsedChurnContinuation = parseDispatchPayloadText(
    JSON.stringify(churnContinuationDispatch.payload),
    continuationEventType, 'owner/repository');
  await expectRejected(async () => restartSweep(
    churnHarness.createInvocationClient(),
    parsedChurnContinuation.session, maximumRestartProgress, {
      runId: '952',
      runSha: advancedSha,
      stateToken: parsedChurnContinuation.stateToken,
    }, churnContinuation.targetUrl),
  'Pull request inventory did not stabilize within the restart limit.',
  'Repeated pagination churn must stop at the restart bound.');
}

function getEnvironment(name) {
  const value = process.env[name];
  assert(typeof value === 'string' && value.length > 0,
    `Required environment input is missing: ${name}`);
  return value;
}

function validRef(value) {
  return typeof value === 'string' && value.length >= 1 &&
    value.length <= 255 &&
    !/[\u0000\r\n]/.test(value);
}

function encodeRef(ref) {
  return ref.split('/').map(encodeURIComponent).join('/');
}

function parseDispatchPayloadText(value, eventType, repository) {
  assert(typeof value === 'string' &&
    Buffer.byteLength(value, 'utf8') <= maximumDispatchPayloadBytes,
  'Repository dispatch payload is invalid.');
  let payload;
  try {
    payload = JSON.parse(value);
  } catch {
    throw new Error('Repository dispatch payload is invalid.');
  }
  assert(repositoryPattern.test(repository),
    'Repository dispatch payload is invalid.');
  if (eventType === bootstrapEventType) {
    assert(hasExactProperties(payload, ['protocol', 'branch']) &&
      payload.protocol === dispatchProtocol && validRef(payload.branch),
    'Repository dispatch payload is invalid.');
    return { kind: 'bootstrap', branch: payload.branch };
  }
  assert(eventType === continuationEventType &&
    hasExactProperties(payload,
      ['protocol', 'session', 'progress', 'parent', 'state_token']) &&
    payload.protocol === dispatchProtocol &&
    hasExactProperties(payload.session,
      ['branch', 'base_sha', 'default_branch']) &&
    hasExactProperties(payload.progress, ['phase', 'cursor', 'total_count',
      'seen_count', 'digest', 'expected_total_count', 'expected_digest',
      'restart_count', 'repaired']) &&
    hasExactProperties(payload.parent,
      ['run_id', 'run_sha', 'state_token']) &&
    digestPattern.test(payload.state_token),
  'Repository dispatch payload is invalid.');
  const session = {
    repository,
    branch: payload.session.branch,
    baseSha: payload.session.base_sha,
    defaultBranch: payload.session.default_branch,
  };
  const progress = {
    phase: payload.progress.phase,
    cursor: payload.progress.cursor,
    totalCount: payload.progress.total_count,
    seenCount: payload.progress.seen_count,
    digest: payload.progress.digest,
    expectedTotalCount: payload.progress.expected_total_count,
    expectedDigest: payload.progress.expected_digest,
    restartCount: payload.progress.restart_count,
    repaired: payload.progress.repaired,
  };
  const parent = {
    runId: payload.parent.run_id,
    runSha: payload.parent.run_sha,
    stateToken: payload.parent.state_token,
  };
  try {
    assertSweepSession(session);
    assertSweepProgress(progress);
    assert(typeof parent.runId === 'string' &&
      /^[1-9][0-9]{0,19}$/.test(parent.runId) &&
      typeof parent.runSha === 'string' && shaPattern.test(parent.runSha) &&
      (parent.stateToken === null ||
        (typeof parent.stateToken === 'string' &&
          digestPattern.test(parent.stateToken))) &&
      payload.state_token === sweepStateToken(session, progress, parent.runId,
        parent.runSha, parent.stateToken),
    'Repository dispatch payload is invalid.');
  } catch {
    throw new Error('Repository dispatch payload is invalid.');
  }
  return {
    kind: 'continuation',
    session,
    progress,
    parent,
    stateToken: payload.state_token,
  };
}

function createClient() {
  const repository = getEnvironment('EXPECTED_REPOSITORY');
  const token = getEnvironment('GITHUB_TOKEN');
  const apiRoot = normalizeApiRoot(getEnvironment('GITHUB_API_URL'));
  const graphqlApiRoot = normalizeGraphqlApiRoot(
    getEnvironment('GITHUB_GRAPHQL_URL'));
  const serverUrl = new URL(getEnvironment('GITHUB_SERVER_URL'));
  assert(repositoryPattern.test(repository),
    'GitHub API identity is invalid.');
  assert(serverUrl.protocol === 'https:' && serverUrl.username === '' &&
    serverUrl.password === '' && serverUrl.search === '' &&
    serverUrl.hash === '', 'GitHub server identity is invalid.');
  const requestBudget = createRequestBudget();

  async function requestAtRoot(root, method, path, body,
    allowNotFound = false) {
    requestBudget.beginRequest();
    const payload = body === undefined ? undefined :
      Buffer.from(JSON.stringify(body), 'utf8');
    return await new Promise((resolve, reject) => {
      const operation = https.request(resolveApiRequestUrl(root, path), {
        method,
        headers: {
          Accept: 'application/vnd.github+json',
          Authorization: `Bearer ${token}`,
          'User-Agent': 'PSStyleGuide-current-base-status',
          'X-GitHub-Api-Version': '2022-11-28',
          ...(payload === undefined ? {} : {
            'Content-Type': 'application/json',
            'Content-Length': String(payload.length),
          }),
        },
      }, (response) => {
        const chunks = [];
        let length = 0;
        response.on('error', reject);
        response.on('data', (chunk) => {
          length += chunk.length;
          if (length > maximumResponseBytes) {
            response.destroy(new Error('GitHub API response is oversized.'));
          } else {
            chunks.push(chunk);
          }
        });
        response.on('end', () => {
          try {
            resolve(decodeApiResponse(response.statusCode,
              Buffer.concat(chunks), allowNotFound));
          } catch (error) {
            reject(error);
          }
        });
      });
      const timeout = setTimeout(() =>
        operation.destroy(new Error('GitHub API request timed out.')),
      requestTimeoutMilliseconds);
      operation.on('close', () => clearTimeout(timeout));
      operation.on('error', reject);
      if (payload !== undefined) operation.write(payload);
      operation.end();
    });
  }

  async function request(method, path, body, allowNotFound = false) {
    return await requestAtRoot(apiRoot, method, path, body, allowNotFound);
  }

  async function graphql(body) {
    return await requestAtRoot(graphqlApiRoot, 'POST', 'graphql', body);
  }

  async function postStatusAtContext(headSha, context, state, description,
    targetUrl) {
    await request('POST', `repos/${repository}/statuses/${headSha}`, {
      state,
      context,
      description,
      target_url: targetUrl,
    });
  }

  async function postStatus(headSha, pullNumber, state, description, targetUrl) {
    await postStatusAtContext(headSha, statusContext(pullNumber), state,
      description, targetUrl);
  }

  async function dispatchRepository(eventType, clientPayload) {
    assert([bootstrapEventType, continuationEventType].includes(eventType),
      'Repository dispatch type is invalid.');
    const payloadText = JSON.stringify(clientPayload);
    parseDispatchPayloadText(payloadText, eventType, repository);
    await request('POST', `repos/${repository}/dispatches`, {
      event_type: eventType,
      client_payload: clientPayload,
    });
  }

  return {
    repository,
    serverOrigin: serverUrl.origin,
    request,
    graphql,
    postStatus,
    postStatusAtContext,
    dispatchRepository,
    assertCanMutate: requestBudget.assertCanComplete,
    assertCanRequest: requestBudget.assertCanComplete,
  };
}

function getExpectedPullRequest() {
  const pullNumberText = getEnvironment('EXPECTED_PULL_NUMBER');
  const baseRef = getEnvironment('EXPECTED_BASE_REF');
  const baseSha = getEnvironment('EXPECTED_BASE_SHA');
  const headSha = getEnvironment('EXPECTED_HEAD_SHA');
  assert(/^[1-9][0-9]{0,9}$/.test(pullNumberText) && validRef(baseRef) &&
    shaPattern.test(baseSha) && shaPattern.test(headSha),
  'Pull request status input is invalid.');
  return {
    pullNumber: Number(pullNumberText),
    baseRef,
    baseSha,
    headSha,
  };
}

async function readLivePullState(client, pullNumber) {
  const pull = await client.request('GET',
    `repos/${client.repository}/pulls/${pullNumber}`);
  assert(isRecord(pull) && pull.number === pullNumber && pull.state === 'open' &&
    isRecord(pull.base) && validRef(pull.base.ref) &&
    shaPattern.test(pull.base.sha) && isRecord(pull.head) &&
    shaPattern.test(pull.head.sha),
  'Live pull request response is invalid.');
  const ref = await client.request('GET',
    `repos/${client.repository}/git/ref/heads/${encodeRef(pull.base.ref)}`);
  assert(isRecord(ref) && isRecord(ref.object) &&
    ref.object.type === 'commit' && ref.object.sha === pull.base.sha,
  'Live pull request base response is invalid.');
  return {
    pullNumber,
    baseRef: pull.base.ref,
    baseSha: pull.base.sha,
    headSha: pull.head.sha,
  };
}

async function readLiveState(client, expected) {
  const pull = await client.request('GET',
    `repos/${client.repository}/pulls/${expected.pullNumber}`);
  const ref = await client.request('GET',
    `repos/${client.repository}/git/ref/heads/${encodeRef(expected.baseRef)}`);
  return isCurrentPull(pull, ref, expected);
}

async function readLiveBaseSha(client, branch, allowNotFound = false) {
  const ref = await client.request('GET',
    `repos/${client.repository}/git/ref/heads/${encodeRef(branch)}`,
    undefined, allowNotFound);
  if (ref === null) return null;
  assert(isRecord(ref) && isRecord(ref.object) &&
    ref.object.type === 'commit' && shaPattern.test(ref.object.sha),
  'Live base ref response is invalid.');
  return ref.object.sha;
}

async function readRepositoryDefaultBranch(client) {
  const repository = await client.request('GET',
    `repos/${client.repository}`);
  assert(isRecord(repository) &&
    repository.full_name === client.repository &&
    validRef(repository.default_branch),
  'Live repository response is invalid.');
  return repository.default_branch;
}

async function readSweepGuard(client, branch, baseSha) {
  const entries = [{ sha: baseSha, context: sweepGuardContext(branch) }];
  return (await readExactStatuses(client, entries))[0];
}

function isSuccessfulSweepRun(run, runId, repository, branch, baseSha,
  token, defaultBranch) {
  return isRecord(run) && shaPattern.test(run.head_sha) &&
    isAuthenticCurrentBaseRun(run, {
      runId,
      eventName: 'repository_dispatch',
      defaultBranch,
      defaultSha: run.head_sha,
      displayTitle: continuationRunTitle(branch, baseSha, token,
        run.head_sha),
      repository,
      requireSuccess: true,
    });
}

async function hasAuthenticatedSweepGuard(client, branch, baseSha,
  defaultBranch) {
  const guard = await readSweepGuard(client, branch, baseSha);
  const token = successfulGuardToken(guard, baseSha);
  if (token === null) return false;
  const target = parseActionsRunTarget(guard.targetUrl, client.repository,
    client.serverOrigin);
  const run = await client.request('GET',
    `repos/${client.repository}/actions/runs/${target.runId}`);
  return guardAllowsMergeControl(guard, baseSha,
    isSuccessfulSweepRun(run, target.runId, client.repository, branch,
      baseSha, token, defaultBranch));
}

function assertCanMutate(client, count) {
  assert(typeof client.assertCanMutate === 'function',
    'GitHub API mutation budget is unavailable.');
  client.assertCanMutate(count);
}

function assertCanRequest(client, count) {
  assert(typeof client.assertCanRequest === 'function',
    'GitHub API request budget is unavailable.');
  client.assertCanRequest(count);
}

async function publishPending(client, expected, targetUrl) {
  assert(targetUrl.startsWith('https://'),
    'Prerequisite status input is invalid.');
  assert(await readLiveState(client, expected),
    'The pull request no longer has the expected base and head.');
  assertCanMutate(client, 1);
  await client.postStatus(expected.headSha, expected.pullNumber, 'pending',
    `Validating base ${expected.baseSha}.`, targetUrl);
}

async function start() {
  await publishPending(createClient(), getExpectedPullRequest(),
    getEnvironment('STATUS_TARGET_URL'));
}

function parseActionsRunTarget(value, repository, expectedOrigin) {
  let target;
  try {
    target = new URL(value);
  } catch {
    throw new Error('Status target does not identify an Actions run.');
  }
  assert(repositoryPattern.test(repository) && target.protocol === 'https:' &&
    target.username === '' && target.password === '' && target.search === '' &&
    target.hash === '' &&
    (expectedOrigin === undefined || target.origin === expectedOrigin),
  'Status target does not identify an Actions run.');
  const prefix = `/${repository}/actions/runs/`;
  assert(target.pathname.startsWith(prefix),
    'Status target does not identify an Actions run.');
  const runId = target.pathname.slice(prefix.length);
  assert(/^[1-9][0-9]{0,19}$/.test(runId),
    'Status target does not identify an Actions run.');
  return { origin: target.origin, runId };
}

function isAuthenticPullRequestWorkflowRun(run, expected, runId) {
  if (!(isRecord(run) && String(run.id) === runId &&
    Number.isInteger(run.run_number) && run.run_number >= 1 &&
    Number.isInteger(run.run_attempt) && run.run_attempt >= 1 &&
    run.event === 'pull_request_target' &&
    run.path === '.github/workflows/agent-instructions.yml' &&
    workflowRunStatuses.has(run.status) &&
    isRecord(run.repository) &&
    run.repository.full_name === expected.repository &&
    run.head_sha === expected.headSha &&
    Array.isArray(run.pull_requests) && run.pull_requests.length === 1)) {
    return false;
  }
  const pull = run.pull_requests[0];
  return isRecord(pull) && pull.number === expected.pullNumber &&
    isRecord(pull.base) && pull.base.ref === expected.baseRef &&
    pull.base.sha === expected.baseSha && isRecord(pull.base.repo) &&
    pull.base.repo.full_name === expected.repository &&
    isRecord(pull.head) && pull.head.sha === expected.headSha &&
    isRecord(pull.head.repo) &&
    repositoryPattern.test(pull.head.repo.full_name);
}

function isSuccessfulPullRequestWorkflowRun(run, expected, runId) {
  return isAuthenticPullRequestWorkflowRun(run, expected, runId) &&
    run.status === 'completed' && run.conclusion === 'success';
}

function isStrictlyLaterWorkflowRun(candidate, source) {
  return candidate.run_number > source.run_number ||
    (candidate.run_number === source.run_number &&
      candidate.run_attempt > source.run_attempt);
}

async function hasAuthenticatedNewerSuccess(client, expected, live, latest,
  sourceTargetUrl) {
  if (live.headSha !== expected.headSha ||
    requiresInvalidation(latest, live.baseSha)) return false;
  // Reserve the repository identity, guard status/run reads, both validation-
  // run reads, and the fail-closed error write before accepting evidence.
  assertCanMutate(client, 6);
  const defaultBranch = await readRepositoryDefaultBranch(client);
  if (!await hasAuthenticatedSweepGuard(client,
    live.baseRef, live.baseSha, defaultBranch)) return false;
  const sourceTarget = parseActionsRunTarget(sourceTargetUrl,
    client.repository, client.serverOrigin);
  const candidateTarget = parseActionsRunTarget(latest.targetUrl,
    client.repository, client.serverOrigin);
  if (sourceTarget.runId === candidateTarget.runId) return false;

  const sourceRun = await client.request('GET',
    `repos/${client.repository}/actions/runs/${sourceTarget.runId}`);
  const candidateRun = await client.request('GET',
    `repos/${client.repository}/actions/runs/${candidateTarget.runId}`);
  const sourceExpected = { ...expected, repository: client.repository };
  const candidateExpected = { ...live, repository: client.repository };
  return isAuthenticPullRequestWorkflowRun(sourceRun, sourceExpected,
    sourceTarget.runId) &&
    isAuthenticPullRequestWorkflowRun(candidateRun, candidateExpected,
      candidateTarget.runId) &&
    isStrictlyLaterWorkflowRun(candidateRun, sourceRun);
}

async function publishFinalizerError(client, expected, description, targetUrl) {
  let preserveNewerSuccess = false;
  try {
    const live = await readLivePullState(client, expected.pullNumber);
    const latest = (await readLatestStatuses(client, [{
      number: live.pullNumber,
      head: { sha: live.headSha },
    }]))[0];
    preserveNewerSuccess = await hasAuthenticatedNewerSuccess(client,
      expected, live, latest, targetUrl);
  } catch {
    // An indeterminate freshness read cannot prove a newer current-base success.
  }
  if (preserveNewerSuccess) return false;
  assertCanMutate(client, 1);
  await client.postStatus(expected.headSha, expected.pullNumber, 'error',
    description, targetUrl);
  return true;
}

async function finalizeStatus(client, expected, validationResult, targetUrl) {
  assert(['success', 'failure', 'cancelled', 'skipped'].includes(
    validationResult) && targetUrl.startsWith('https://'),
  'Finalization input is invalid.');

  if (validationResult !== 'success') {
    await publishFinalizerError(client, expected,
      `Validation result is ${validationResult}; revalidate PR ` +
        `#${expected.pullNumber}.`, targetUrl);
    throw new Error('Agent-instruction validation did not succeed.');
  }
  if (!await readLiveState(client, expected)) {
    await publishFinalizerError(client, expected,
      `Base or head changed; revalidate PR #${expected.pullNumber}.`, targetUrl);
    throw new Error('The pull request no longer has the validated base and head.');
  }
  let guardAccepted = false;
  try {
    const defaultBranch = await readRepositoryDefaultBranch(client);
    guardAccepted = await hasAuthenticatedSweepGuard(client,
      expected.baseRef, expected.baseSha, defaultBranch);
  } catch {
    // An unavailable or malformed guard cannot authorize success publication.
  }
  if (!guardAccepted) {
    await publishFinalizerError(client, expected,
      `Base sweep incomplete; revalidate PR #${expected.pullNumber}.`, targetUrl);
    throw new Error('The live-base sweep guard is not successful.');
  }
  assertCanMutate(client, 1);
  await client.postStatus(expected.headSha, expected.pullNumber, 'success',
    `Validated base ${expected.baseSha}.`, targetUrl);
  if (!await readLiveState(client, expected)) {
    await publishFinalizerError(client, expected,
      `Base or head changed; revalidate PR #${expected.pullNumber}.`, targetUrl);
    throw new Error('The pull request changed while status was published.');
  }
}

async function finalize() {
  await finalizeStatus(createClient(), getExpectedPullRequest(),
    getEnvironment('VALIDATION_RESULT'), getEnvironment('STATUS_TARGET_URL'));
}

async function readMergeSnapshot(client, pullNumber) {
  const defaultBranch = await readRepositoryDefaultBranch(client);
  const live = await readLivePullState(client, pullNumber);
  const statuses = await readExactStatuses(client, [{
    sha: live.headSha,
    context: statusContext(live.pullNumber),
  }, {
    sha: live.baseSha,
    context: sweepGuardContext(live.baseRef),
  }]);
  return {
    defaultBranch,
    live,
    pullStatus: statuses[0],
    guard: statuses[1],
  };
}

function mergeSnapshotsMatch(first, second) {
  return JSON.stringify(first) === JSON.stringify(second);
}

async function authenticateMergeSnapshot(client, snapshot) {
  const { defaultBranch, live, pullStatus, guard } = snapshot;
  const guardToken = successfulGuardToken(guard, live.baseSha);
  if (!(statusMatchesBase(pullStatus, live.baseSha) &&
    guardToken !== null)) return false;
  const pullTarget = parseActionsRunTarget(pullStatus.targetUrl,
    client.repository, client.serverOrigin);
  const guardTarget = parseActionsRunTarget(guard.targetUrl,
    client.repository, client.serverOrigin);
  if (pullTarget.origin !== guardTarget.origin) return false;
  const pullRun = await client.request('GET',
    `repos/${client.repository}/actions/runs/${pullTarget.runId}`);
  const guardRun = await client.request('GET',
    `repos/${client.repository}/actions/runs/${guardTarget.runId}`);
  const pullRunAuthenticated = isSuccessfulPullRequestWorkflowRun(pullRun, {
    ...live,
    repository: client.repository,
  }, pullTarget.runId);
  const guardRunAuthenticated = isSuccessfulSweepRun(guardRun,
    guardTarget.runId, client.repository, live.baseRef, live.baseSha,
    guardToken, defaultBranch);
  return mergeControlAccepts(pullStatus, guard, live.baseSha,
    pullRunAuthenticated, guardRunAuthenticated);
}

async function verifyMergeEvidence(client, pullNumber) {
  assert(Number.isInteger(pullNumber) && pullNumber >= 1,
    'Merge verification input is invalid.');
  assertCanRequest(client, 10);
  const first = await readMergeSnapshot(client, pullNumber);
  assert(await authenticateMergeSnapshot(client, first),
    'Merge evidence is incomplete or unauthenticated.');
  const second = await readMergeSnapshot(client, pullNumber);
  assert(mergeSnapshotsMatch(first, second),
    'Live merge evidence changed during verification.');
}

async function verifyMerge() {
  const pullNumberText = getEnvironment('EXPECTED_PULL_NUMBER');
  assert(/^[1-9][0-9]{0,9}$/.test(pullNumberText),
    'Merge verification input is invalid.');
  await verifyMergeEvidence(createClient(), Number(pullNumberText));
}

function expectedRunUrl(client, runId) {
  assert(/^[1-9][0-9]{0,19}$/.test(runId),
    'Actions run identity is invalid.');
  return `${client.serverOrigin}/${client.repository}/actions/runs/${runId}`;
}

function guardIsExpectedPending(guard, baseSha, token, targetUrl) {
  return guard && guard.state === 'pending' &&
    guard.description === pendingGuardDescription(baseSha, token) &&
    guard.targetUrl === targetUrl && statusHasActionsCreator(guard);
}

async function postPendingGuard(client, session, token, targetUrl) {
  assert(digestPattern.test(token), 'Sweep guard token is invalid.');
  assertCanMutate(client, 1);
  await client.postStatusAtContext(session.baseSha,
    sweepGuardContext(session.branch), 'pending',
    pendingGuardDescription(session.baseSha, token), targetUrl);
}

async function dispatchBootstrap(client, branch) {
  const payload = { protocol: dispatchProtocol, branch };
  parseDispatchPayloadText(JSON.stringify(payload), bootstrapEventType,
    client.repository);
  assertCanMutate(client, 1);
  await client.dispatchRepository(bootstrapEventType, payload);
}

async function dispatchContinuation(client, session, progress, currentRun,
  targetUrl) {
  const payload = continuationPayload(session, progress, currentRun.runId,
    currentRun.runSha, currentRun.stateToken);
  assertCanMutate(client, 2);
  await client.postStatusAtContext(session.baseSha,
    sweepGuardContext(session.branch), 'pending',
    pendingGuardDescription(session.baseSha, payload.state_token), targetUrl);
  await client.dispatchRepository(continuationEventType, payload);
}

async function restartSweep(client, session, progress, currentRun,
  targetUrl) {
  assert(progress.restartCount < maximumSweepRestarts,
    'Pull request inventory did not stabilize within the restart limit.');
  await dispatchContinuation(client, session,
    createInitialProgress('invalidate', progress.restartCount + 1),
    currentRun, targetUrl);
}

async function processSweepBatch(client, session, progress, currentRun,
  targetUrl) {
  assertSweepSession(session);
  assertSweepProgress(progress);
  const page = await listOpenPullRequestPage(client, session.branch,
    progress.cursor);
  if (progress.totalCount !== null &&
    page.totalCount !== progress.totalCount) {
    await restartSweep(client, session, progress, currentRun, targetUrl);
    return;
  }
  const totalCount = progress.totalCount ?? page.totalCount;
  const seenCount = progress.seenCount + page.pulls.length;
  if (seenCount > totalCount ||
    (page.hasNextPage && seenCount >= totalCount) ||
    (!page.hasNextPage && seenCount !== totalCount) ||
    (page.hasNextPage && page.endCursor === progress.cursor)) {
    await restartSweep(client, session, progress, currentRun, targetUrl);
    return;
  }
  const digest = extendSnapshotDigest(progress.digest, page.pulls);
  const latestStatuses = page.pulls.length === 0 ? [] :
    await readLatestStatuses(client, page.pulls);
  const invalidations = page.pulls.filter((pull, index) =>
    requiresSweepInvalidation(latestStatuses[index], session.baseSha,
      pull.number));
  const liveBaseSha = await readLiveBaseSha(client, session.branch);
  assert(liveBaseSha === session.baseSha,
    'The live base changed during the sweep.');

  const repaired = progress.phase === 'verify' &&
    (progress.repaired || invalidations.length > 0);
  const verificationChanged = progress.phase === 'verify' &&
    !page.hasNextPage && (repaired ||
      totalCount !== progress.expectedTotalCount ||
      digest !== progress.expectedDigest);
  const followupRequests = page.hasNextPage ||
    progress.phase === 'invalidate' || verificationChanged ? 2 : 3;
  assertCanMutate(client, invalidations.length + followupRequests);
  for (const pull of invalidations) {
    await client.postStatus(pull.head.sha, pull.number, 'error',
      invalidationDescription(session.baseSha, pull.number), targetUrl);
  }

  if (page.hasNextPage) {
    await dispatchContinuation(client, session, {
      ...progress,
      cursor: page.endCursor,
      totalCount,
      seenCount,
      digest,
      repaired,
    }, currentRun, targetUrl);
    return;
  }
  if (progress.phase === 'invalidate') {
    await dispatchContinuation(client, session,
      createInitialProgress('verify', progress.restartCount,
        totalCount, digest), currentRun, targetUrl);
    return;
  }
  if (verificationChanged) {
    await restartSweep(client, session, progress, currentRun, targetUrl);
    return;
  }

  const finalBaseSha = await readLiveBaseSha(client, session.branch);
  assert(finalBaseSha === session.baseSha,
    'The live base changed before sweep completion.');
  const guard = await readSweepGuard(client, session.branch, session.baseSha);
  assert(digestPattern.test(currentRun.stateToken) &&
    guardIsExpectedPending(guard, session.baseSha, currentRun.stateToken,
      targetUrl),
    'The sweep guard changed before completion.');
  await client.postStatusAtContext(session.baseSha,
    sweepGuardContext(session.branch), 'success',
    successfulGuardDescription(session.baseSha, currentRun.stateToken),
    targetUrl);
}

async function invalidateStatuses(client, signal) {
  assert(isRecord(signal) &&
    ['workflow_run', 'repository_dispatch'].includes(signal.eventName) &&
    /^[1-9][0-9]{0,19}$/.test(signal.currentRunId) &&
    validRef(signal.currentRunRef) && shaPattern.test(signal.currentRunSha) &&
    signal.targetUrl === expectedRunUrl(client, signal.currentRunId),
  'Invalidation input is invalid.');
  const defaultBranch = await readRepositoryDefaultBranch(client);
  assert(signal.currentRunRef === defaultBranch,
    'Current-base workflow did not run from the default branch.');
  const dispatch = signal.eventName === 'repository_dispatch' ?
    parseDispatchPayloadText(signal.clientPayloadText, signal.eventType,
      client.repository) : null;
  const displayTitle = dispatch === null ? undefined :
    dispatch.kind === 'bootstrap' ?
      bootstrapRunTitle(dispatch.branch, signal.currentRunSha) :
      continuationRunTitle(dispatch.session.branch, dispatch.session.baseSha,
        dispatch.stateToken, signal.currentRunSha);
  const currentRun = await client.request('GET',
    `repos/${client.repository}/actions/runs/${signal.currentRunId}`);
  assert(isAuthenticCurrentBaseRun(currentRun, {
    runId: signal.currentRunId,
    eventName: signal.eventName,
    defaultBranch,
    defaultSha: signal.currentRunSha,
    ...(displayTitle === undefined ? {} : { displayTitle }),
    repository: client.repository,
    requireSuccess: false,
  }), 'Current-base workflow run does not match its live record.');

  if (signal.eventName === 'workflow_run') {
    assert(signal.eventType === null && signal.clientPayloadText === null &&
      ['requested', 'completed'].includes(signal.sourceActivity) &&
      /^[1-9][0-9]{0,19}$/.test(signal.sourceRunId) &&
      validRef(signal.branch) && shaPattern.test(signal.signalSha),
    'Workflow-run invalidation input is invalid.');
    const sourceRun = await client.request('GET',
      `repos/${client.repository}/actions/runs/${signal.sourceRunId}`);
    assert(isAuthenticWorkflowRun(sourceRun, {
      activity: signal.sourceActivity,
      runId: signal.sourceRunId,
      branch: signal.branch,
      signalSha: signal.signalSha,
      repository: client.repository,
    }), 'Workflow-run signal does not match its live record.');
    const baseSha = await readLiveBaseSha(client, signal.branch, true);
    if (baseSha === null) return;
    const session = {
      repository: client.repository,
      branch: signal.branch,
      baseSha,
      defaultBranch,
    };
    const progress = createInitialProgress();
    const token = sweepStateToken(session, progress, signal.currentRunId,
      signal.currentRunSha, null);
    assertCanMutate(client, 2);
    await postPendingGuard(client, session, token, signal.targetUrl);
    await dispatchBootstrap(client, signal.branch);
    return;
  }

  assert(dispatch !== null, 'Repository dispatch state is unavailable.');
  if (dispatch.kind === 'bootstrap') {
    const baseSha = await readLiveBaseSha(client, dispatch.branch, true);
    assert(baseSha !== null, 'The bootstrap branch does not exist.');
    let alreadyComplete = false;
    try {
      alreadyComplete = await hasAuthenticatedSweepGuard(client,
        dispatch.branch, baseSha, defaultBranch);
    } catch {
      // Unauthenticated old evidence is replaced by a new bootstrap sweep.
    }
    if (alreadyComplete) return;
    const session = {
      repository: client.repository,
      branch: dispatch.branch,
      baseSha,
      defaultBranch,
    };
    const progress = createInitialProgress();
    const token = sweepStateToken(session, progress, signal.currentRunId,
      signal.currentRunSha, null);
    await postPendingGuard(client, session, token, signal.targetUrl);
    await processSweepBatch(client, session, progress, {
      runId: signal.currentRunId,
      runSha: signal.currentRunSha,
      stateToken: null,
    }, signal.targetUrl);
    return;
  }

  const { session, progress, parent, stateToken } = dispatch;
  assert(session.defaultBranch === defaultBranch,
    'Continuation default-branch identity is stale.');
  const parentRun = await client.request('GET',
    `repos/${client.repository}/actions/runs/${parent.runId}`);
  const parentDisplayTitle = parent.stateToken === null ?
    bootstrapRunTitle(session.branch, parent.runSha) :
    continuationRunTitle(session.branch, session.baseSha,
      parent.stateToken, parent.runSha);
  assert(isAuthenticCurrentBaseRun(parentRun, {
    runId: parent.runId,
    eventName: 'repository_dispatch',
    defaultBranch: session.defaultBranch,
    defaultSha: parent.runSha,
    displayTitle: parentDisplayTitle,
    repository: client.repository,
    requireSuccess: true,
  }), 'Continuation parent run does not match its live record.');
  const baseSha = await readLiveBaseSha(client, session.branch);
  assert(baseSha === session.baseSha,
    'The continuation base is stale.');
  const guard = await readSweepGuard(client, session.branch, session.baseSha);
  assert(guardIsExpectedPending(guard, session.baseSha, stateToken,
    expectedRunUrl(client, parent.runId)),
    'Continuation state is stale or replayed.');
  await postPendingGuard(client, session, stateToken, signal.targetUrl);
  await processSweepBatch(client, session, progress, {
    runId: signal.currentRunId,
    runSha: signal.currentRunSha,
    stateToken,
  }, signal.targetUrl);
}

async function invalidate() {
  const client = createClient();
  const eventName = getEnvironment('SWEEP_EVENT_NAME');
  await invalidateStatuses(client, {
    eventName,
    currentRunId: getEnvironment('SWEEP_RUN_ID'),
    currentRunRef: getEnvironment('SWEEP_RUN_REF'),
    currentRunSha: getEnvironment('SWEEP_RUN_SHA'),
    eventType: eventName === 'repository_dispatch' ?
      getEnvironment('SWEEP_EVENT_TYPE') : null,
    clientPayloadText: eventName === 'repository_dispatch' ?
      getEnvironment('SWEEP_CLIENT_PAYLOAD') : null,
    sourceActivity: eventName === 'workflow_run' ?
      getEnvironment('SIGNAL_ACTIVITY') : null,
    sourceRunId: eventName === 'workflow_run' ?
      getEnvironment('SIGNAL_RUN_ID') : null,
    branch: eventName === 'workflow_run' ?
      getEnvironment('SIGNAL_HEAD_BRANCH') : null,
    signalSha: eventName === 'workflow_run' ?
      getEnvironment('SIGNAL_HEAD_SHA') : null,
    targetUrl: getEnvironment('STATUS_TARGET_URL'),
  });
}

async function main() {
  await runSelfTest();
  const mode = process.argv[2];
  if (mode === 'self-test') return;
  const operation = mode === 'start' ? start :
    mode === 'finalize' ? finalize :
      mode === 'invalidate' ? invalidate :
        mode === 'verify-merge' ? verifyMerge : null;
  assert(operation !== null,
    'Expected start, finalize, invalidate, or verify-merge mode.');
  await operation();
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
