#!/usr/bin/env node

import https from 'node:https';
import { TextDecoder } from 'node:util';

// One invalidation run supports one complete page of at most 20 open pull
// requests. In the all-write case it makes 25 API requests: one run read, one
// base-ref read, one PR-page read, two 10-context reads, and 20 status writes.
const maximumPullRequests = 20;
const pullRequestPageSize = maximumPullRequests;
const statusContextBatchSize = 10;
const maximumApiRequests = 25;
const maximumOperationMilliseconds = 240000;
const requestTimeoutMilliseconds = 8000;
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
  $pageSize: Int!
) {
  repository(owner: $owner, name: $name) {
    pullRequests(
      first: $pageSize
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

function parsePullRequestPage(result, expected) {
  assert(isRecord(result) && !Object.hasOwn(result, 'errors') &&
    isRecord(result.data) && isRecord(result.data.repository) &&
    isRecord(result.data.repository.pullRequests),
  'GraphQL pull request response is invalid.');
  const connection = result.data.repository.pullRequests;
  assert(Number.isInteger(connection.totalCount) &&
    connection.totalCount >= 0,
  'GraphQL pull request connection is invalid.');
  assert(connection.totalCount <= maximumPullRequests,
    `Open pull request count exceeds the supported limit of ` +
      `${maximumPullRequests}.`);
  assert(Array.isArray(connection.nodes) &&
    connection.nodes.length === connection.totalCount &&
    connection.nodes.length <= pullRequestPageSize &&
    isRecord(connection.pageInfo) &&
    connection.pageInfo.hasNextPage === false,
  'GraphQL pull request connection is invalid.');
  const pulls = [];
  const seenPulls = new Set();
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
  return pulls;
}

async function listOpenPullRequests(client, branch) {
  const [owner, name] = client.repository.split('/');
  const result = await client.graphql({
    query: openPullRequestsQuery,
    variables: {
      owner,
      name,
      baseRefName: branch,
      pageSize: pullRequestPageSize,
    },
  });
  return parsePullRequestPage(result,
    { repository: client.repository, branch });
}

function createStatusContextRequest(repository, pulls) {
  assert(repositoryPattern.test(repository) && Array.isArray(pulls) &&
    pulls.length >= 1 && pulls.length <= statusContextBatchSize,
  'Status-context batch is invalid.');
  const [owner, name] = repository.split('/');
  const declarations = ['$owner: String!', '$name: String!'];
  const selections = [];
  const variables = { owner, name };
  for (let index = 0; index < pulls.length; index += 1) {
    const pull = pulls[index];
    assert(isRecord(pull) && Number.isInteger(pull.number) &&
      pull.number >= 1 && isRecord(pull.head) &&
      shaPattern.test(pull.head.sha), 'Status-context batch is invalid.');
    declarations.push(`$oid${index}: GitObjectID!`);
    declarations.push(`$context${index}: String!`);
    variables[`oid${index}`] = pull.head.sha;
    variables[`context${index}`] = statusContext(pull.number);
    selections.push(`status${index}: object(oid: $oid${index}) {
      __typename
      ... on Commit {
        oid
        status {
          latest: context(name: $context${index}) {
            context
            state
            description
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

function parseStatusContextResponse(result, pulls) {
  assert(isRecord(result) && !Object.hasOwn(result, 'errors') &&
    isRecord(result.data) && isRecord(result.data.repository),
  'GraphQL status-context response is invalid.');
  const statuses = [];
  for (let index = 0; index < pulls.length; index += 1) {
    const item = result.data.repository[`status${index}`];
    assert(isRecord(item) && item.__typename === 'Commit' &&
      item.oid === pulls[index].head.sha &&
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
    assert(latest.context === statusContext(pulls[index].number) &&
      ['ERROR', 'EXPECTED', 'FAILURE', 'PENDING', 'SUCCESS'].includes(
        latest.state) &&
      (latest.description === null || typeof latest.description === 'string'),
    'GraphQL status-context response entry is invalid.');
    statuses.push({
      state: latest.state.toLowerCase(),
      description: latest.description,
    });
  }
  return statuses;
}

async function readLatestStatuses(client, pulls) {
  const statuses = [];
  for (let offset = 0; offset < pulls.length;
    offset += statusContextBatchSize) {
    const batch = pulls.slice(offset, offset + statusContextBatchSize);
    const result = await client.graphql(
      createStatusContextRequest(client.repository, batch));
    statuses.push(...parseStatusContextResponse(result, batch));
  }
  return statuses;
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
    !openPullRequestsQuery.includes('$cursor') &&
    !openPullRequestsQuery.includes('endCursor') &&
    !/\bbody(?:HTML|Text)?\b/.test(openPullRequestsQuery),
  'The one-page pull-request query must project only bounded helper fields.');

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
  const pullPage = (nodes, totalCount, hasNextPage = false) => ({
    data: { repository: { pullRequests: {
      totalCount,
      nodes,
      pageInfo: { hasNextPage },
    } } },
  });
  const statusPage = (request, getLatest = () => null) => {
    const repository = {};
    for (let index = 0;
      Object.hasOwn(request.variables, `oid${index}`); index += 1) {
      const context = request.variables[`context${index}`];
      const pullNumber = Number(context.split('/PR-')[1]);
      const latest = getLatest(pullNumber);
      repository[`status${index}`] = {
        __typename: 'Commit',
        oid: request.variables[`oid${index}`],
        status: latest === null ? null : {
          latest: {
            context,
            state: latest.state.toUpperCase(),
            description: latest.description,
          },
        },
      };
    }
    return { data: { repository } };
  };
  const graphqlRequests = [];
  const projectedPulls = await listOpenPullRequests({
    repository: 'owner/repository',
    graphql: async (payload) => {
      graphqlRequests.push(payload);
      return pullPage([firstPull, secondPull], 2);
    },
  }, 'main');
  assert(projectedPulls.length === 2 &&
    projectedPulls[0].head.sha === firstPull.headRefOid &&
    projectedPulls[1].head.sha === secondPull.headRefOid &&
    graphqlRequests.length === 1 &&
    graphqlRequests[0].query === openPullRequestsQuery &&
    graphqlRequests[0].variables.owner === 'owner' &&
    graphqlRequests[0].variables.name === 'repository' &&
    graphqlRequests[0].variables.baseRefName === 'main' &&
    graphqlRequests[0].variables.pageSize === pullRequestPageSize &&
    !Object.hasOwn(graphqlRequests[0].variables, 'cursor'),
  'The complete one-page GraphQL query variables must remain exact.');

  let simulatedChurnRequests = 0;
  const churnResult = await listOpenPullRequests({
    repository: 'owner/repository',
    graphql: async () => {
      simulatedChurnRequests += 1;
      return simulatedChurnRequests === 1 ?
        pullPage([firstPull, secondPull], 2) :
        pullPage([firstPull], 1);
    },
  }, 'main');
  assert(churnResult.length === 2 && simulatedChurnRequests === 1,
    'A complete one-page read must have no cross-page churn dependency.');

  const cappedPulls = Array.from({ length: maximumPullRequests },
    (_, index) => ({
      ...firstPull,
      number: index + 1,
      headRefOid: (index + 1).toString(16).padStart(40, '0'),
    }));
  assert((await listOpenPullRequests({
    repository: 'owner/repository',
    graphql: async () => pullPage(cappedPulls, maximumPullRequests),
  }, 'main')).length === maximumPullRequests,
  'The disclosed one-page pull-request limit must be accepted.');

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
    graphql: async () => pullPage(cappedPulls,
      maximumPullRequests + 1, true),
  }, 'main'), `Open pull request count exceeds the supported limit of ` +
    `${maximumPullRequests}.`,
  'The one-page pull-request limit plus one must fail closed.');
  await expectRejected(async () => listOpenPullRequests({
    repository: 'owner/repository',
    graphql: async () => pullPage([firstPull], 1, true),
  }, 'main'), 'GraphQL pull request connection is invalid.',
  'A partial or paginated pull-request page must fail closed.');

  const exactStatusRequest = createStatusContextRequest(
    'owner/repository', sameBaselinePulls);
  assert(exactStatusRequest.query.startsWith(
    'query ExactStatusContexts(') &&
    exactStatusRequest.query.includes('latest: context(name: $context0)') &&
    exactStatusRequest.query.includes('latest: context(name: $context1)') &&
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
      if (path.endsWith('/pulls/101')) return pull;
      return { object: { type: 'commit', sha: advancedSha } };
    },
    graphql: async (request) => statusPage(request),
    postStatus: async (...arguments_) => pendingWrites.push(arguments_),
    assertCanMutate: () => {},
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

  const oldExpected = { ...expected, baseSha: baselineSha };
  const newerSuccessClient = {
    ...exactLiveClient,
    request: async (method, path) => {
      assert(method === 'GET', 'Freshness reads must use GET.');
      if (path.endsWith('/pulls/101')) return pull;
      return { object: { type: 'commit', sha: advancedSha } };
    },
    graphql: async (request) => statusPage(request, () => currentStatus),
  };
  const oldFailureWrites = [];
  await expectRejected(async () => finalizeStatus({
    ...newerSuccessClient,
    postStatus: async (...arguments_) => oldFailureWrites.push(arguments_),
  }, oldExpected, 'failure', 'https://example.invalid/run'),
  'Agent-instruction validation did not succeed.',
  'An old failure finalizer must still terminate as failed.');
  assert(oldFailureWrites.length === 0,
    'An old failure finalizer must preserve newer exact-base success.');

  const oldMismatchWrites = [];
  await expectRejected(async () => finalizeStatus({
    ...newerSuccessClient,
    postStatus: async (...arguments_) => oldMismatchWrites.push(arguments_),
  }, oldExpected, 'success', 'https://example.invalid/run'),
  'The pull request no longer has the validated base and head.',
  'An old success-path mismatch must terminate as stale.');
  assert(oldMismatchWrites.length === 0,
    'An old success-path mismatch must preserve newer exact-base success.');

  const freshnessApiFailureWrites = [];
  await expectRejected(async () => finalizeStatus({
    ...exactLiveClient,
    request: async () => { throw new Error('simulated API failure'); },
    postStatus: async (...arguments_) =>
      freshnessApiFailureWrites.push(arguments_),
  }, oldExpected, 'failure', 'https://example.invalid/run'),
  'Agent-instruction validation did not succeed.',
  'A freshness API failure must keep the finalizer failed.');
  assert(freshnessApiFailureWrites.length === 1 &&
    freshnessApiFailureWrites[0][2] === 'error',
  'An indeterminate freshness read must fail closed with an error status.');

  const noNewerSuccessWrites = [];
  await expectRejected(async () => finalizeStatus({
    ...newerSuccessClient,
    graphql: async (request) => statusPage(request, () => staleStatus),
    postStatus: async (...arguments_) =>
      noNewerSuccessWrites.push(arguments_),
  }, oldExpected, 'failure', 'https://example.invalid/run'),
  'Agent-instruction validation did not succeed.',
  'A finalizer without newer success must terminate as failed.');
  assert(noNewerSuccessWrites.length === 1 &&
    noNewerSuccessWrites[0][2] === 'error',
  'A stale status must not suppress a finalizer error.');

  let invalidationRequestCount = 0;
  let invalidationReservation = null;
  const invalidationWrites = [];
  await invalidateStatuses({
    repository: 'owner/repository',
    request: async (method, path) => {
      invalidationRequestCount += 1;
      assert(method === 'GET', 'Invalidation REST reads must use GET.');
      if (path.includes('/actions/runs/501')) return workflowRun;
      return { object: { type: 'commit', sha: advancedSha } };
    },
    graphql: async (request) => {
      invalidationRequestCount += 1;
      return request.query === openPullRequestsQuery ?
        pullPage(cappedPulls, maximumPullRequests) :
        statusPage(request, () => staleStatus);
    },
    assertCanMutate: (count) => {
      invalidationReservation = {
        count,
        requestCount: invalidationRequestCount,
      };
      assert(invalidationRequestCount + count <= maximumApiRequests,
        'The invalidation fixture exceeded the global request budget.');
    },
    postStatus: async (...arguments_) => {
      invalidationRequestCount += 1;
      invalidationWrites.push(arguments_);
    },
  }, {
    activity: 'requested',
    runId: '501',
    branch: 'main',
    signalSha: advancedSha,
    targetUrl: 'https://example.invalid/run',
  });
  assert(invalidationReservation !== null &&
    invalidationReservation.count === maximumPullRequests &&
    invalidationReservation.requestCount === 5 &&
    invalidationWrites.length === maximumPullRequests &&
    invalidationRequestCount === maximumApiRequests,
  'The all-write one-page workload must fit its disclosed 25-request bound.');

  let excessiveWrites = 0;
  await expectRejected(async () => invalidateStatuses({
    repository: 'owner/repository',
    request: async (method, path) => {
      assert(method === 'GET', 'Invalidation REST reads must use GET.');
      if (path.includes('/actions/runs/501')) return workflowRun;
      return { object: { type: 'commit', sha: advancedSha } };
    },
    graphql: async () => pullPage(cappedPulls,
      maximumPullRequests + 1, true),
    assertCanMutate: () => {
      throw new Error('Mutation budget must not be reached.');
    },
    postStatus: async () => { excessiveWrites += 1; },
  }, {
    activity: 'requested',
    runId: '501',
    branch: 'main',
    signalSha: advancedSha,
    targetUrl: 'https://example.invalid/run',
  }), `Open pull request count exceeds the supported limit of ` +
    `${maximumPullRequests}.`,
  'The supported PR limit plus one must abort invalidation.');
  assert(excessiveWrites === 0,
    'A PR count above the supported limit must fail before any write.');
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

  async function postStatus(headSha, pullNumber, state, description, targetUrl) {
    await request('POST', `repos/${repository}/statuses/${headSha}`, {
      state,
      context: statusContext(pullNumber),
      description,
      target_url: targetUrl,
    });
  }

  return {
    repository,
    request,
    graphql,
    postStatus,
    assertCanMutate: requestBudget.assertCanComplete,
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

function assertCanMutate(client, count) {
  assert(typeof client.assertCanMutate === 'function',
    'GitHub API mutation budget is unavailable.');
  client.assertCanMutate(count);
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

async function publishFinalizerError(client, expected, description, targetUrl) {
  let preserveNewerSuccess = false;
  try {
    const live = await readLivePullState(client, expected.pullNumber);
    const latest = (await readLatestStatuses(client, [{
      number: live.pullNumber,
      head: { sha: live.headSha },
    }]))[0];
    preserveNewerSuccess = live.headSha === expected.headSha &&
      live.baseSha !== expected.baseSha &&
      !requiresInvalidation(latest, live.baseSha);
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

async function invalidateStatuses(client, {
  activity, runId, branch, signalSha, targetUrl,
}) {
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
  const latestStatuses = await readLatestStatuses(client, pulls);
  const invalidations = pulls.filter((pull, index) =>
    requiresInvalidation(latestStatuses[index], currentBaseSha));
  assertCanMutate(client, invalidations.length);
  for (const pull of invalidations) {
    await client.postStatus(pull.head.sha, pull.number, 'error',
      `Base advanced to ${currentBaseSha}; revalidate PR #${pull.number}.`,
      targetUrl);
  }
}

async function invalidate() {
  await invalidateStatuses(createClient(), {
    activity: getEnvironment('SIGNAL_ACTIVITY'),
    runId: getEnvironment('SIGNAL_RUN_ID'),
    branch: getEnvironment('SIGNAL_HEAD_BRANCH'),
    signalSha: getEnvironment('SIGNAL_HEAD_SHA'),
    targetUrl: getEnvironment('STATUS_TARGET_URL'),
  });
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
