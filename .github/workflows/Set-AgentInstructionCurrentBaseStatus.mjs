#!/usr/bin/env node

import https from 'node:https';

const maximumPages = 10;
const maximumResponseBytes = 1048576;
const shaPattern = /^[0-9a-f]{40}$/;
const repositoryPattern = /^[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+$/;

function assert(condition, message) {
  if (!condition) throw new Error(message);
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

function runSelfTest() {
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
  const apiUrl = new URL(getEnvironment('GITHUB_API_URL'));
  assert(repositoryPattern.test(repository) && apiUrl.protocol === 'https:',
    'GitHub API identity is invalid.');

  async function request(method, path, body, allowNotFound = false) {
    const payload = body === undefined ? undefined :
      Buffer.from(JSON.stringify(body), 'utf8');
    return await new Promise((resolve, reject) => {
      const operation = https.request(new URL(path, apiUrl), {
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
          if (allowNotFound && response.statusCode === 404) {
            resolve(null);
            return;
          }
          if (response.statusCode < 200 || response.statusCode >= 300) {
            reject(new Error(`GitHub API returned ${response.statusCode}.`));
            return;
          }
          const text = Buffer.concat(chunks).toString('utf8');
          try {
            resolve(text.length === 0 ? null : JSON.parse(text));
          } catch {
            reject(new Error('GitHub API returned malformed JSON.'));
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

  async function postStatus(headSha, pullNumber, state, description, targetUrl) {
    await request('POST', `/repos/${repository}/statuses/${headSha}`, {
      state,
      context: statusContext(pullNumber),
      description,
      target_url: targetUrl,
    });
  }

  return { repository, request, postStatus };
}

async function finalize() {
  const client = createClient();
  const pullNumberText = getEnvironment('EXPECTED_PULL_NUMBER');
  const baseRef = getEnvironment('EXPECTED_BASE_REF');
  const baseSha = getEnvironment('EXPECTED_BASE_SHA');
  const headSha = getEnvironment('EXPECTED_HEAD_SHA');
  const validationResult = getEnvironment('VALIDATION_RESULT');
  const targetUrl = getEnvironment('STATUS_TARGET_URL');
  assert(/^[1-9][0-9]{0,9}$/.test(pullNumberText) && validRef(baseRef) &&
    shaPattern.test(baseSha) && shaPattern.test(headSha) &&
    ['success', 'failure', 'cancelled', 'skipped'].includes(validationResult) &&
    targetUrl.startsWith('https://'), 'Finalization input is invalid.');
  const pullNumber = Number(pullNumberText);
  const expected = { pullNumber, baseRef, baseSha, headSha };

  async function readLiveState() {
    const pull = await client.request('GET',
      `/repos/${client.repository}/pulls/${pullNumber}`);
    const ref = await client.request('GET',
      `/repos/${client.repository}/git/ref/heads/${encodeRef(baseRef)}`);
    return isCurrentPull(pull, ref, expected);
  }

  if (validationResult !== 'success') {
    await client.postStatus(headSha, pullNumber, 'error',
      `Validation result is ${validationResult}; revalidate PR #${pullNumber}.`,
      targetUrl);
    throw new Error('Agent-instruction validation did not succeed.');
  }
  if (!await readLiveState()) {
    await client.postStatus(headSha, pullNumber, 'error',
      `Base or head changed; revalidate PR #${pullNumber}.`, targetUrl);
    throw new Error('The pull request no longer has the validated base and head.');
  }
  await client.postStatus(headSha, pullNumber, 'success',
    `Validated base ${baseSha}.`, targetUrl);
  if (!await readLiveState()) {
    await client.postStatus(headSha, pullNumber, 'error',
      `Base or head changed; revalidate PR #${pullNumber}.`, targetUrl);
    throw new Error('The pull request changed while status was published.');
  }
}

async function invalidate() {
  const client = createClient();
  const runId = getEnvironment('SIGNAL_RUN_ID');
  const branch = getEnvironment('SIGNAL_HEAD_BRANCH');
  const signalSha = getEnvironment('SIGNAL_HEAD_SHA');
  const targetUrl = getEnvironment('STATUS_TARGET_URL');
  assert(/^[1-9][0-9]{0,19}$/.test(runId) && validRef(branch) &&
    shaPattern.test(signalSha) && targetUrl.startsWith('https://'),
  'Invalidation input is invalid.');
  const run = await client.request('GET',
    `/repos/${client.repository}/actions/runs/${runId}`);
  assert(run && String(run.id) === runId && run.event === 'push' &&
    run.path === '.github/workflows/agent-instructions.yml' &&
    run.head_branch === branch && run.head_sha === signalSha &&
    run.status === 'completed',
  'Workflow-run signal does not match its live record.');
  const ref = await client.request('GET',
    `/repos/${client.repository}/git/ref/heads/${encodeRef(branch)}`,
    undefined, true);
  if (ref === null) return;
  assert(ref.object && ref.object.type === 'commit' &&
    shaPattern.test(ref.object.sha), 'Live base ref response is invalid.');
  const currentBaseSha = ref.object.sha;

  const pulls = [];
  const seenPulls = new Set();
  for (let page = 1; page <= maximumPages; page += 1) {
    const result = await client.request('GET',
      `/repos/${client.repository}/pulls?state=open&base=` +
      `${encodeURIComponent(branch)}&per_page=100&page=${page}`);
    assert(Array.isArray(result) && result.length <= 100,
      'Pull request response is invalid.');
    for (const pull of result) {
      assert(pull && Number.isInteger(pull.number) && pull.number >= 1 &&
        !seenPulls.has(pull.number) && pull.state === 'open' &&
        pull.base && pull.base.ref === branch && pull.base.repo &&
        pull.base.repo.full_name === client.repository && pull.head &&
        shaPattern.test(pull.head.sha),
      'Pull request response entry is invalid.');
      seenPulls.add(pull.number);
      pulls.push(pull);
    }
    if (result.length < 100) break;
    assert(page < maximumPages,
      'Pull request pagination exceeded its bound.');
  }

  for (const pull of pulls) {
    let latest = null;
    const context = statusContext(pull.number);
    for (let page = 1; page <= maximumPages; page += 1) {
      const statuses = await client.request('GET',
        `/repos/${client.repository}/commits/${pull.head.sha}/statuses` +
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

runSelfTest();
const mode = process.argv[2];
if (mode === 'self-test') process.exit(0);
const operation = mode === 'finalize' ? finalize :
  mode === 'invalidate' ? invalidate : null;
assert(operation !== null, 'Expected finalize or invalidate mode.');
operation().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
