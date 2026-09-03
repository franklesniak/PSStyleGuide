#!/usr/bin/env node

import https from 'node:https';
import { TextDecoder } from 'node:util';

const maximumPages = 10;
const pullRequestPageSize = 100;
const maximumPullRequests = maximumPages * pullRequestPageSize;
const maximumResponseBytes = 1048576;
const maximumRequestPathCharacters = 4096;
const shaPattern = /^[0-9a-f]{40}$/;
const repositoryPattern = /^[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$/;
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
  $cursor: String
  $pageSize: Int!
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

function statusContext(pullNumber) {
  return `Agent instruction current base/PR-${pullNumber}`;
}

function requiresInvalidation(latest, currentBaseSha) {
  return !(latest && latest.state === 'success' &&
    latest.description === `Validated base ${currentBaseSha}.`);
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
    run.path === '.github/workflows/agent-instructions.yml' &&
    run.head_branch === expected.branch && run.head_sha === expected.signalSha &&
    workflowRunStatuses.has(run.status))) return false;
  return expected.activity === 'requested' || run.status === 'completed';
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

function parsePullRequestPage(result, expected, seenPulls, expectedTotalCount) {
  assert(isRecord(result) && !Object.hasOwn(result, 'errors') &&
    isRecord(result.data) && isRecord(result.data.repository) &&
    isRecord(result.data.repository.pullRequests),
  'GraphQL pull request response is invalid.');
  const connection = result.data.repository.pullRequests;
  assert(Number.isInteger(connection.totalCount) &&
    connection.totalCount >= 0 &&
    connection.totalCount <= maximumPullRequests &&
    (expectedTotalCount === null ||
      connection.totalCount === expectedTotalCount) &&
    Array.isArray(connection.nodes) &&
    connection.nodes.length <= pullRequestPageSize &&
    isRecord(connection.pageInfo) &&
    typeof connection.pageInfo.hasNextPage === 'boolean' &&
    (connection.pageInfo.endCursor === null ||
      (typeof connection.pageInfo.endCursor === 'string' &&
        connection.pageInfo.endCursor.length >= 1 &&
        connection.pageInfo.endCursor.length <= 1024)),
  'GraphQL pull request connection is invalid.');
  const pulls = [];
  for (const pull of connection.nodes) {
    assert(isRecord(pull) && Number.isInteger(pull.number) &&
      pull.number >= 1 && !seenPulls.has(pull.number) &&
      pull.state === 'OPEN' && pull.baseRefName === expected.branch &&
      isRecord(pull.baseRepository) &&
      pull.baseRepository.nameWithOwner === expected.repository &&
      shaPattern.test(pull.headRefOid),
    'GraphQL pull request response entry is invalid.');
    seenPulls.add(pull.number);
    pulls.push({ number: pull.number, head: { sha: pull.headRefOid } });
  }
  return {
    pulls,
    totalCount: connection.totalCount,
    hasNextPage: connection.pageInfo.hasNextPage,
    endCursor: connection.pageInfo.endCursor,
  };
}

async function listOpenPullRequests(client, branch) {
  const [owner, name] = client.repository.split('/');
  const pulls = [];
  const seenPulls = new Set();
  const seenCursors = new Set();
  let cursor = null;
  let expectedTotalCount = null;
  for (let page = 1; page <= maximumPages; page += 1) {
    const result = await client.graphql({
      query: openPullRequestsQuery,
      variables: {
        owner,
        name,
        baseRefName: branch,
        cursor,
        pageSize: pullRequestPageSize,
      },
    });
    const parsed = parsePullRequestPage(result,
      { repository: client.repository, branch }, seenPulls,
      expectedTotalCount);
    expectedTotalCount ??= parsed.totalCount;
    pulls.push(...parsed.pulls);
    assert(pulls.length <= expectedTotalCount,
      'GraphQL pull request cardinality is invalid.');
    if (!parsed.hasNextPage) {
      assert(pulls.length === expectedTotalCount,
        'GraphQL pull request cardinality is invalid.');
      return pulls;
    }
    assert(page < maximumPages && pulls.length < expectedTotalCount &&
      parsed.endCursor !== null && !seenCursors.has(parsed.endCursor),
    'GraphQL pull request pagination exceeded its bound.');
    seenCursors.add(parsed.endCursor);
    cursor = parsed.endCursor;
  }
  throw new Error('GraphQL pull request pagination exceeded its bound.');
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

async function runSelfTest() {
  const baselineSha = '1'.repeat(40);
  const advancedSha = '2'.repeat(40);
  const staleStatus = {
    state: 'success',
    description: `Validated base ${baselineSha}.`,
  };
  const currentStatus = {
    state: 'success',
    description: `Validated base ${advancedSha}.`,
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
    path: '.github/workflows/agent-instructions.yml',
    head_branch: 'main',
    head_sha: advancedSha,
    status: 'requested',
  };
  const workflowSignal = {
    activity: 'requested',
    runId: '501',
    branch: 'main',
    signalSha: advancedSha,
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
  assert(!isAuthenticWorkflowRun(workflowRun,
    { ...workflowSignal, activity: 'in_progress' }),
  'An unsupported workflow-run activity must fail authentication.');

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
    openPullRequestsQuery.includes('pageInfo') &&
    !/\bbody(?:HTML|Text)?\b/.test(openPullRequestsQuery),
  'The open-pull-request query must project only bounded helper fields.');

  const firstPull = {
    number: 101,
    state: 'OPEN',
    baseRefName: 'main',
    baseRepository: { nameWithOwner: 'owner/repository' },
    headRefOid: '3'.repeat(40),
  };
  const secondPull = {
    number: 102,
    state: 'OPEN',
    baseRefName: 'main',
    baseRepository: { nameWithOwner: 'owner/repository' },
    headRefOid: '4'.repeat(40),
  };
  const pullPage = (nodes, totalCount, hasNextPage = false,
    endCursor = null) => ({
    data: { repository: { pullRequests: {
      totalCount,
      nodes,
      pageInfo: { hasNextPage, endCursor },
    } } },
  });
  const graphqlRequests = [];
  const graphqlPages = [
    pullPage([firstPull], 2, true, 'cursor-1'),
    pullPage([secondPull], 2),
  ];
  const projectedPulls = await listOpenPullRequests({
    repository: 'owner/repository',
    graphql: async (payload) => {
      graphqlRequests.push(payload);
      return graphqlPages.shift();
    },
  }, 'main');
  assert(projectedPulls.length === 2 &&
    projectedPulls[0].head.sha === firstPull.headRefOid &&
    projectedPulls[1].head.sha === secondPull.headRefOid &&
    graphqlRequests.length === 2 &&
    graphqlRequests.every((entry) =>
      entry.query === openPullRequestsQuery &&
      entry.variables.owner === 'owner' &&
      entry.variables.name === 'repository' &&
      entry.variables.baseRefName === 'main' &&
      entry.variables.pageSize === pullRequestPageSize) &&
    graphqlRequests[0].variables.cursor === null &&
    graphqlRequests[1].variables.cursor === 'cursor-1',
  'GraphQL query variables and cursor pagination must remain exact.');

  await expectRejected(async () => listOpenPullRequests({
    repository: 'owner/repository',
    graphql: async () => ({ errors: [{ message: 'denied' }], data: null }),
  }, 'main'), 'GraphQL pull request response is invalid.',
  'A GraphQL error response must fail closed.');
  await expectRejected(async () => listOpenPullRequests({
    repository: 'owner/repository',
    graphql: async () => ({ data: { repository: { pullRequests: {
      totalCount: 1,
      nodes: 'not-an-array',
      pageInfo: { hasNextPage: false, endCursor: null },
    } } } }),
  }, 'main'), 'GraphQL pull request connection is invalid.',
  'A malformed GraphQL connection must fail closed.');
  await expectRejected(async () => listOpenPullRequests({
    repository: 'owner/repository',
    graphql: async () => pullPage([firstPull, firstPull], 2),
  }, 'main'), 'GraphQL pull request response entry is invalid.',
  'A duplicate GraphQL pull request must fail closed.');
  await expectRejected(async () => listOpenPullRequests({
    repository: 'owner/repository',
    graphql: async () => pullPage([], maximumPullRequests + 1),
  }, 'main'), 'GraphQL pull request connection is invalid.',
  'An excessive GraphQL pull request cardinality must fail closed.');
  let boundPage = 0;
  await expectRejected(async () => listOpenPullRequests({
    repository: 'owner/repository',
    graphql: async () => {
      boundPage += 1;
      return pullPage([{ ...firstPull, number: 200 + boundPage,
        headRefOid: boundPage.toString(16).padStart(40, '0') }],
      maximumPages + 1, true, `bound-cursor-${boundPage}`);
    },
  }, 'main'), 'GraphQL pull request pagination exceeded its bound.',
  'GraphQL pagination beyond the maximum page count must fail closed.');

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
      if (path.endsWith('/pulls/101')) return pull;
      return { object: { type: 'commit', sha: advancedSha } };
    },
    postStatus: async (...arguments_) => pendingWrites.push(arguments_),
    repository: 'owner/repository',
  };
  await publishPending(exactLiveClient, expected, 'https://example.invalid/run');
  assert(pendingWrites.length === 1 &&
    pendingWrites[0][0] === expected.headSha &&
    pendingWrites[0][2] === 'pending' &&
    pendingWrites[0][3] === `Validating base ${expected.baseSha}.`,
  'The prerequisite writer must publish one pending exact-base status.');
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
      if (path.endsWith('/pulls/101')) return pull;
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
}

function getEnvironment(name) {
  const value = process.env[name];
  assert(typeof value === 'string' && value.length > 0,
    `Required environment input is missing: ${name}`);
  return value;
}

function validRef(value) {
  return value.length >= 1 && value.length <= 255 &&
    !/[\u0000\r\n]/.test(value);
}

function encodeRef(ref) {
  return ref.split('/').map(encodeURIComponent).join('/');
}

function createClient() {
  const repository = getEnvironment('EXPECTED_REPOSITORY');
  const token = getEnvironment('GITHUB_TOKEN');
  const apiRoot = normalizeApiRoot(getEnvironment('GITHUB_API_URL'));
  const graphqlApiRoot = normalizeGraphqlApiRoot(
    getEnvironment('GITHUB_GRAPHQL_URL'));
  assert(repositoryPattern.test(repository),
    'GitHub API identity is invalid.');

  async function requestAtRoot(root, method, path, body,
    allowNotFound = false) {
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
      operation.setTimeout(30000, () =>
        operation.destroy(new Error('GitHub API request timed out.')));
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

  async function postStatus(headSha, pullNumber, state, description, targetUrl) {
    await request('POST', `repos/${repository}/statuses/${headSha}`, {
      state,
      context: statusContext(pullNumber),
      description,
      target_url: targetUrl,
    });
  }

  return { repository, request, graphql, postStatus };
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

async function readLiveState(client, expected) {
  const pull = await client.request('GET',
    `repos/${client.repository}/pulls/${expected.pullNumber}`);
  const ref = await client.request('GET',
    `repos/${client.repository}/git/ref/heads/${encodeRef(expected.baseRef)}`);
  return isCurrentPull(pull, ref, expected);
}

async function publishPending(client, expected, targetUrl) {
  assert(targetUrl.startsWith('https://'),
    'Prerequisite status input is invalid.');
  assert(await readLiveState(client, expected),
    'The pull request no longer has the expected base and head.');
  await client.postStatus(expected.headSha, expected.pullNumber, 'pending',
    `Validating base ${expected.baseSha}.`, targetUrl);
}

async function start() {
  await publishPending(createClient(), getExpectedPullRequest(),
    getEnvironment('STATUS_TARGET_URL'));
}

async function finalizeStatus(client, expected, validationResult, targetUrl) {
  assert(['success', 'failure', 'cancelled', 'skipped'].includes(
    validationResult) && targetUrl.startsWith('https://'),
  'Finalization input is invalid.');

  if (validationResult !== 'success') {
    await client.postStatus(expected.headSha, expected.pullNumber, 'error',
      `Validation result is ${validationResult}; revalidate PR ` +
        `#${expected.pullNumber}.`, targetUrl);
    throw new Error('Agent-instruction validation did not succeed.');
  }
  if (!await readLiveState(client, expected)) {
    await client.postStatus(expected.headSha, expected.pullNumber, 'error',
      `Base or head changed; revalidate PR #${expected.pullNumber}.`, targetUrl);
    throw new Error('The pull request no longer has the validated base and head.');
  }
  await client.postStatus(expected.headSha, expected.pullNumber, 'success',
    `Validated base ${expected.baseSha}.`, targetUrl);
  if (!await readLiveState(client, expected)) {
    await client.postStatus(expected.headSha, expected.pullNumber, 'error',
      `Base or head changed; revalidate PR #${expected.pullNumber}.`, targetUrl);
    throw new Error('The pull request changed while status was published.');
  }
}

async function finalize() {
  await finalizeStatus(createClient(), getExpectedPullRequest(),
    getEnvironment('VALIDATION_RESULT'), getEnvironment('STATUS_TARGET_URL'));
}

async function invalidate() {
  const client = createClient();
  const activity = getEnvironment('SIGNAL_ACTIVITY');
  const runId = getEnvironment('SIGNAL_RUN_ID');
  const branch = getEnvironment('SIGNAL_HEAD_BRANCH');
  const signalSha = getEnvironment('SIGNAL_HEAD_SHA');
  const targetUrl = getEnvironment('STATUS_TARGET_URL');
  assert(['requested', 'completed'].includes(activity) &&
    /^[1-9][0-9]{0,19}$/.test(runId) && validRef(branch) &&
    shaPattern.test(signalSha) && targetUrl.startsWith('https://'),
  'Invalidation input is invalid.');
  const run = await client.request('GET',
    `repos/${client.repository}/actions/runs/${runId}`);
  assert(isAuthenticWorkflowRun(run,
    { activity, runId, branch, signalSha }),
  'Workflow-run signal does not match its live record.');
  const ref = await client.request('GET',
    `repos/${client.repository}/git/ref/heads/${encodeRef(branch)}`,
    undefined, true);
  if (ref === null) return;
  assert(ref.object && ref.object.type === 'commit' &&
    shaPattern.test(ref.object.sha), 'Live base ref response is invalid.');
  const currentBaseSha = ref.object.sha;

  const pulls = await listOpenPullRequests(client, branch);

  for (const pull of pulls) {
    let latest = null;
    const context = statusContext(pull.number);
    for (let page = 1; page <= maximumPages; page += 1) {
      const statuses = await client.request('GET',
        `repos/${client.repository}/commits/${pull.head.sha}/statuses` +
        `?per_page=100&page=${page}`);
      assert(Array.isArray(statuses) && statuses.length <= 100,
        'Commit status response is invalid.');
      latest = statuses.find((status) =>
        status && status.context === context) ?? null;
      if (latest || statuses.length < 100) break;
      assert(page < maximumPages,
        'Commit status pagination exceeded its bound.');
    }
    if (!requiresInvalidation(latest, currentBaseSha)) continue;
    await client.postStatus(pull.head.sha, pull.number, 'error',
      `Base advanced to ${currentBaseSha}; revalidate PR #${pull.number}.`,
      targetUrl);
  }
}

async function main() {
  await runSelfTest();
  const mode = process.argv[2];
  if (mode === 'self-test') return;
  const operation = mode === 'start' ? start :
    mode === 'finalize' ? finalize :
      mode === 'invalidate' ? invalidate : null;
  assert(operation !== null, 'Expected start, finalize, or invalidate mode.');
  await operation();
}

main().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
