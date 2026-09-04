import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';
import {
  MUTATION_CLASSES,
  classifyMutation,
  collectCodexResults,
  createMetrics,
  createReviewInput,
  decideReviewRequest,
  evaluateFindingBudget,
  getReviewInputKey,
  normalizeCollection,
  reconcilePublicMutation,
  validateTransport,
} from './review-loop-policy.mjs';

const HASHES = Object.freeze({
  head1: 'a'.repeat(40),
  head2: 'b'.repeat(40),
  tree1: 'c'.repeat(40),
  tree2: 'd'.repeat(40),
  diff1: 'e'.repeat(64),
  diff2: 'f'.repeat(64),
  body1: '1'.repeat(64),
  body2: '2'.repeat(64),
});

function reviewInput(overrides = {}) {
  return createReviewInput({
    head: HASHES.head1,
    tree: HASHES.tree1,
    diffSha256: HASHES.diff1,
    bodySha256: HASHES.body1,
    scope: 'Correct review orchestration.',
    behavior: 'Request one reviewer pair for each reviewed input.',
    risk: 'R1 reversible planning change.',
    ...overrides,
  });
}

function state(input, overrides = {}) {
  return {
    schemaVersion: 1,
    reviewInput: input,
    mutationClass: 'RESULT_OR_STATE',
    reviewRequests: [],
    codexResults: {
      submittedReviews: [],
      conversationComments: [],
    },
    publicMutation: {
      state: 'NOT_ATTEMPTED',
      nativeResponseAccepted: false,
      readbackMatched: false,
      retryAllowed: true,
      localRecordSucceeded: true,
    },
    metrics: {
      reviewerRequestsPerHead: {},
      bodyEditsAfterReviewBegan: 0,
      sameHeadRerequestReasons: [],
      cleanReviewRecognitionMilliseconds: null,
      cleanPairToMergeMilliseconds: null,
    },
    commentPublications: [],
    ...overrides,
  };
}

function requestFor(input, channel, overrides = {}) {
  return {
    channel,
    reviewInputKey: getReviewInputKey(input),
    head: input.head,
    requestedAt: '2026-09-04T10:00:00Z',
    baselineReviewNodeIds: [],
    baselineConversationComments: [],
    ...overrides,
  };
}

function pairFor(input) {
  return [
    requestFor(input, 'copilot'),
    requestFor(input, 'codex'),
  ];
}

test('scenario 1: compact-state update after a clean pair creates no request', () => {
  const input = reviewInput();
  const previous = state(input);
  const current = state(input, {
    metrics: {
      ...previous.metrics,
      cleanReviewRecognitionMilliseconds: 5_000,
    },
  });
  const mutationClass = classifyMutation(previous, current);
  const decision = decideReviewRequest({
    previousReviewInput: input,
    currentReviewInput: input,
    mutationClass,
    existingRequests: pairFor(input),
  });

  assert.equal(mutationClass, 'RESULT_OR_STATE');
  assert.equal(decision.status, 'NO_REQUEST');
  assert.deepEqual(decision.channels, []);
});

test('scenario 2: a non-material same-head correction creates no request', () => {
  const input = reviewInput();
  const correctedInput = reviewInput({ bodySha256: HASHES.body2 });
  const previous = state(input);
  const current = state(correctedInput);
  const mutationClass = classifyMutation(previous, current);
  const decision = decideReviewRequest({
    previousReviewInput: input,
    currentReviewInput: correctedInput,
    mutationClass,
    existingRequests: pairFor(input),
  });

  assert.equal(mutationClass, 'NON_MATERIAL_FACT');
  assert.equal(getReviewInputKey(correctedInput), getReviewInputKey(input));
  assert.equal(decision.status, 'NO_REQUEST');
});

test('scenario 3: H1 to H2 requires one new pair for H2', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({
    head: HASHES.head2,
    tree: HASHES.tree2,
    diffSha256: HASHES.diff2,
    bodySha256: HASHES.body2,
  });
  const mutationClass = classifyMutation(state(input1), state(input2));
  const decision = decideReviewRequest({
    previousReviewInput: input1,
    currentReviewInput: input2,
    mutationClass,
    existingRequests: pairFor(input1),
  });

  assert.equal(mutationClass, 'CODE_OR_DIFF');
  assert.equal(decision.status, 'REQUEST_REQUIRED');
  assert.deepEqual(decision.channels, ['copilot', 'codex']);
});

test('scenario 4: a material same-head change records a reason and requires review', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({ risk: 'R2 sensitive planning change.' });
  const mutationClass = classifyMutation(state(input1), state(input2));
  const decision = decideReviewRequest({
    previousReviewInput: input1,
    currentReviewInput: input2,
    mutationClass,
    materialReason: 'The change now controls a security-sensitive workflow.',
    existingRequests: pairFor(input1),
  });

  assert.equal(mutationClass, 'MATERIAL_SCOPE_BEHAVIOR_RISK');
  assert.equal(decision.status, 'REQUEST_REQUIRED');
  assert.match(decision.reason, /security-sensitive/u);
  assert.throws(
    () => decideReviewRequest({
      previousReviewInput: input1,
      currentReviewInput: input2,
      mutationClass,
      existingRequests: pairFor(input1),
    }),
    /requires a reason/u,
  );
});

test('scenario 5: an unjustified same-head request is rejected', () => {
  const input = reviewInput();
  const decision = decideReviewRequest({
    previousReviewInput: input,
    currentReviewInput: input,
    mutationClass: 'RESULT_OR_STATE',
    existingRequests: [],
  });

  assert.equal(decision.status, 'REJECTED_SAME_HEAD');
  assert.deepEqual(decision.channels, []);
});

test('scenario 6: both attributable Codex result channels are recognized', () => {
  const input = reviewInput();
  const results = collectCodexResults({
    reviewInput: input,
    request: requestFor(input, 'codex'),
    submittedReviews: {
      id: 1,
      user: { login: 'chatgpt-codex-connector' },
      commit_id: HASHES.head1,
      submitted_at: '2026-09-04T10:01:00Z',
      body: 'No major issue found.',
    },
    conversationComments: [
      {
        id: 2,
        user: { login: 'chatgpt-codex-connector' },
        created_at: '2026-09-04T10:00:00Z',
        body: '@codex review',
      },
      {
        id: 3,
        user: { login: 'chatgpt-codex-connector[bot]' },
        created_at: '2026-09-04T10:01:00Z',
        body: 'Review complete: no major issue found.',
      },
    ],
  });

  assert.equal(results.submittedReviews.length, 1);
  assert.equal(results.conversationComments.length, 1);
  assert.equal(results.total, 2);
});

test('scenario 7: empty, singleton, and multiple collections normalize', () => {
  assert.deepEqual(normalizeCollection(null), []);
  assert.deepEqual(normalizeCollection({ id: 1 }), [{ id: 1 }]);
  assert.deepEqual(normalizeCollection([{ id: 1 }, { id: 2 }]), [{ id: 1 }, { id: 2 }]);
  assert.deepEqual(normalizeCollection({ nodes: [] }), []);
  assert.deepEqual(normalizeCollection({ nodes: [{ id: 1 }] }), [{ id: 1 }]);
  assert.deepEqual(normalizeCollection({ edges: [{ node: { id: 1 } }, { node: { id: 2 } }] }), [{ id: 1 }, { id: 2 }]);
});

test('scenario 8: Markdown backticks and Unicode survive and controls fail', () => {
  const payload = 'Use `git diff --check` for café and 雪.';
  assert.equal(validateTransport(payload), payload);
  assert.throws(() => validateTransport(`bad${String.fromCharCode(1)}value`), /control character/u);
});

test('scenario 9: confirmed mutation plus local recording failure does not retry', () => {
  const expected = { id: 42, body: '@codex review' };
  const confirmed = reconcilePublicMutation({
    response: { ok: true, status: 201 },
    readback: { body: '@codex review', id: 42 },
    expected,
    localRecordSucceeded: false,
  });
  const ambiguous = reconcilePublicMutation({
    response: { ok: true, status: 201 },
    readback: { id: 42, body: 'different' },
    expected,
    localRecordSucceeded: false,
  });
  const notExecuted = reconcilePublicMutation({
    response: { executed: false },
    readback: { id: 42, body: 'different' },
    expected,
    localRecordSucceeded: true,
  });
  const reconciled = reconcilePublicMutation({
    response: { executed: false },
    readback: expected,
    expected,
    localRecordSucceeded: false,
  });

  assert.deepEqual(confirmed, {
    state: 'CONFIRMED',
    nativeResponseAccepted: true,
    readbackMatched: true,
    retryAllowed: false,
    localRecordSucceeded: false,
  });
  assert.deepEqual(ambiguous, {
    state: 'AMBIGUOUS',
    nativeResponseAccepted: true,
    readbackMatched: false,
    retryAllowed: false,
    localRecordSucceeded: false,
  });
  assert.deepEqual(notExecuted, {
    state: 'NOT_EXECUTED',
    nativeResponseAccepted: false,
    readbackMatched: false,
    retryAllowed: true,
    localRecordSucceeded: true,
  });
  assert.deepEqual(reconciled, {
    state: 'CONFIRMED',
    nativeResponseAccepted: false,
    readbackMatched: true,
    retryAllowed: false,
    localRecordSucceeded: false,
  });
});

test('all permanent active task-template and controller surfaces use the compact contract', async () => {
  const planningRoot = new URL('./', import.meta.url);
  const plan = await readFile(new URL('action-items-2026-08-30.md', planningRoot), 'utf8');
  const parent = await readFile(new URL('coding-agent-loop.md', planningRoot), 'utf8');
  const alternate = await readFile(new URL('coding-agent-loop-without-model-routing.md', planningRoot), 'utf8');
  const generator = await readFile(new URL('prompt-action-items-update.md', planningRoot), 'utf8');
  const crossRepository = await readFile(new URL('prompt-loop-cross-repo.md', planningRoot), 'utf8');
  const headingPattern = /^## Task (\d+) — (.+)$/gmu;
  const headings = [...plan.matchAll(headingPattern)];
  const tasks = headings.map((match, index) => ({
    number: Number.parseInt(match[1], 10),
    title: match[2],
    body: plan.slice(match.index, headings[index + 1]?.index ?? plan.length),
  }));
  const publicationTasks = tasks.filter(
    (task) => /^create or update /iu.test(task.title) && /\bPR\b/u.test(task.title) && !/issue/iu.test(task.title),
  );
  const reviewTasks = tasks.filter((task) => /Copilot-and-Codex review loop/iu.test(task.title));
  const qualityTasks = tasks.filter((task) => /independent final quality check/iu.test(task.title));
  const mergeTasks = tasks.filter((task) => /^merge /iu.test(task.title));
  const handoffTasks = tasks.filter((task) => /handoff/iu.test(task.title));

  assert.equal(tasks.length, 402);
  assert.equal(publicationTasks.length, 42);
  assert.equal(reviewTasks.length, 42);
  assert.equal(qualityTasks.length, 42);
  assert.equal(mergeTasks.length, 42);
  assert.equal(handoffTasks.length, 46);

  for (const task of publicationTasks) {
    assert.match(task.body, /### Reviewer-facing body freeze gate/u);
    assert.match(task.body, /RESULT_OR_STATE/u);
    assert.match(task.body, /authenticated readback/u);
    assert.match(task.body, /empty, singleton, and multiple/u);
    assert.match(task.body, /Markdown backticks and Unicode/u);
  }

  for (const task of reviewTasks) {
    assert.match(task.body, /### Reviewer-input and mutation-materiality controls/u);
    assert.match(task.body, /MATERIAL_SCOPE_BEHAVIOR_RISK/u);
    assert.match(task.body, /Reject a same-head request/u);
    assert.match(task.body, /submitted-review/u);
    assert.match(task.body, /PR-conversation-comment/u);
    assert.match(task.body, /local serialization fails/u);
  }

  for (const task of qualityTasks) {
    assert.match(task.body, /### Post-review materiality controls/u);
    assert.match(task.body, /NON_MATERIAL_FACT/u);
    assert.match(task.body, /Raw body-byte inequality is not the classifier/u);
    assert.match(task.body, /submitted-review objects/u);
    assert.match(task.body, /Codex PR-conversation comments/u);
  }

  const unsafeResultBodyLines = plan
    .split('\n')
    .filter((line) => /append.{0,80}(terminal|review) result.{0,80}(PR body|reviewer-facing body)/iu.test(line))
    .filter((line) => !/(do not|never|cannot)/iu.test(line));
  assert.deepEqual(unsafeResultBodyLines, []);
  assert.match(parent, /Compact state machine/u);
  assert.match(parent, /MATERIAL_SCOPE_BEHAVIOR_RISK/u);
  assert.match(alternate, /without model routing/u);
  assert.match(alternate, /Do not create manifest/u);
  assert.match(generator, /Do not split routine work/u);
  assert.match(generator, /Default to one reviewer pair/u);
  assert.match(crossRepository, /one compact state record/u);
  assert.match(crossRepository, /Preserve both submitted-review objects/u);
});

test('safety failures reject false classes, duplicate requests, and unattributable comments', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({
    head: HASHES.head2,
    tree: HASHES.tree2,
    diffSha256: HASHES.diff2,
  });
  assert.throws(
    () => decideReviewRequest({
      previousReviewInput: input1,
      currentReviewInput: input2,
      mutationClass: 'NON_MATERIAL_FACT',
      existingRequests: [],
    }),
    /derived transition CODE_OR_DIFF/u,
  );
  assert.throws(
    () => decideReviewRequest({
      previousReviewInput: input1,
      currentReviewInput: input1,
      mutationClass: 'RESULT_OR_STATE',
      existingRequests: [
        requestFor(input1, 'codex'),
        requestFor(input1, 'codex', { requestedAt: '2026-09-04T10:01:00Z' }),
      ],
    }),
    /Duplicate codex requests/u,
  );
  assert.throws(
    () => decideReviewRequest({
      previousReviewInput: input1,
      currentReviewInput: input1,
      mutationClass: 'RESULT_OR_STATE',
      existingRequests: [{
        channel: 'codex',
        reviewInputKey: getReviewInputKey(input1),
        head: input1.head,
      }],
    }),
    /malformed or mismatched/u,
  );

  const results = collectCodexResults({
    reviewInput: input1,
    submittedReviews: [],
    conversationComments: {
      id: 5,
      user: { login: 'chatgpt-codex-connector' },
      created_at: '2026-09-04T10:01:00Z',
      body: 'No major issue found.',
    },
  });
  assert.equal(results.total, 0);
});

test('invalidating mutation claims are rejected in both directions', () => {
  const input = reviewInput();
  const materialInput = reviewInput({ risk: 'R2 sensitive planning change.' });

  assert.throws(
    () => decideReviewRequest({
      previousReviewInput: input,
      currentReviewInput: input,
      mutationClass: 'CODE_OR_DIFF',
      existingRequests: [],
    }),
    /supplied invalidating class CODE_OR_DIFF.*derived transition null/u,
  );
  assert.throws(
    () => decideReviewRequest({
      previousReviewInput: input,
      currentReviewInput: input,
      mutationClass: 'MATERIAL_SCOPE_BEHAVIOR_RISK',
      materialReason: 'Unsupported claim.',
      existingRequests: [],
    }),
    /supplied invalidating class MATERIAL_SCOPE_BEHAVIOR_RISK.*derived transition null/u,
  );
  assert.throws(
    () => decideReviewRequest({
      previousReviewInput: input,
      currentReviewInput: materialInput,
      mutationClass: 'RESULT_OR_STATE',
      existingRequests: [],
    }),
    /derived transition MATERIAL_SCOPE_BEHAVIOR_RISK/u,
  );
});

test('schema-defined compact-state fields classify deterministically', () => {
  const input = reviewInput();
  const original = state(input);
  const resultChanges = [
    { reviewRequests: [requestFor(input, 'codex')] },
    { codexResults: { submittedReviews: [{ id: 1 }], conversationComments: [] } },
    {
      publicMutation: {
        state: 'CONFIRMED',
        nativeResponseAccepted: true,
        readbackMatched: true,
        retryAllowed: false,
        localRecordSucceeded: true,
      },
    },
    { metrics: { ...original.metrics, bodyEditsAfterReviewBegan: 1 } },
  ];

  for (const change of resultChanges) {
    assert.equal(classifyMutation(original, state(input, change)), 'RESULT_OR_STATE');
  }
  assert.equal(
    classifyMutation(original, state(input, { commentPublications: [{ id: 'status-1' }] })),
    'COMMENT_ONLY',
  );
});

test('Codex results normalize REST and GraphQL identities and reject stale evidence', () => {
  const input = reviewInput();
  const request = requestFor(input, 'codex', {
    baselineReviewNodeIds: ['REVIEW_OLD'],
    baselineConversationComments: [
      { nodeId: 'COMMENT_STABLE', updatedAt: '2026-09-04T09:59:00Z' },
      { nodeId: 'COMMENT_OLD', updatedAt: '2026-09-04T09:59:00Z' },
    ],
  });
  const results = collectCodexResults({
    reviewInput: input,
    request,
    submittedReviews: {
      nodes: [
        {
          id: 'REVIEW_OLD',
          author: { login: 'chatgpt-codex-connector' },
          commit: { oid: HASHES.head1 },
          submittedAt: '2026-09-04T10:02:00Z',
        },
        {
          id: 'REVIEW_TOO_EARLY',
          author: { login: 'chatgpt-codex-connector' },
          commit: { oid: HASHES.head1 },
          submittedAt: '2026-09-04T09:58:00Z',
        },
        {
          id: 'REVIEW_NEW',
          author: { login: 'chatgpt-codex-connector' },
          commit: { oid: HASHES.head1 },
          submittedAt: '2026-09-04T10:02:00Z',
        },
      ],
    },
    conversationComments: [
      {
        node_id: 'COMMENT_STABLE',
        user: { login: 'chatgpt-codex-connector[bot]' },
        updated_at: '2026-09-04T10:02:00Z',
        body: 'Updated persistent review summary.',
      },
      {
        node_id: 'COMMENT_OLD',
        user: { login: 'chatgpt-codex-connector[bot]' },
        updated_at: '2026-09-04T09:59:00Z',
        body: 'Unchanged stale summary.',
      },
    ],
  });

  assert.deepEqual(results.submittedReviews.map((review) => review.id), ['REVIEW_NEW']);
  assert.deepEqual(
    results.conversationComments.map((comment) => comment.node_id),
    ['COMMENT_STABLE'],
  );
  assert.equal(results.total, 2);
});

test('Codex request correlation rejects a different reviewed input', () => {
  const input = reviewInput();
  const changedInput = reviewInput({ risk: 'R2 sensitive planning change.' });
  const results = collectCodexResults({
    reviewInput: changedInput,
    request: requestFor(input, 'codex'),
    submittedReviews: [{
      id: 'REVIEW_NEW',
      user: { login: 'chatgpt-codex-connector[bot]' },
      commit_id: HASHES.head1,
      submitted_at: '2026-09-04T10:02:00Z',
    }],
    conversationComments: [],
  });

  assert.equal(results.total, 0);
});

test('Codex request correlation fails closed when baseline evidence is missing', () => {
  const input = reviewInput();
  const request = requestFor(input, 'codex');
  delete request.baselineReviewNodeIds;
  const results = collectCodexResults({
    reviewInput: input,
    request,
    submittedReviews: [{
      id: 'REVIEW_NEW',
      user: { login: 'chatgpt-codex-connector[bot]' },
      commit_id: HASHES.head1,
      submitted_at: '2026-09-04T10:02:00Z',
    }],
    conversationComments: [],
  });

  assert.equal(results.total, 0);
});

test('Codex request correlation fails closed on duplicate baseline identities', () => {
  const input = reviewInput();
  const request = requestFor(input, 'codex', {
    baselineConversationComments: [
      { nodeId: 'COMMENT_OLD', updatedAt: '2026-09-04T09:58:00Z' },
      { nodeId: 'COMMENT_OLD', updatedAt: '2026-09-04T09:59:00Z' },
    ],
  });
  const results = collectCodexResults({
    reviewInput: input,
    request,
    submittedReviews: [],
    conversationComments: [{
      node_id: 'COMMENT_NEW',
      user: { login: 'chatgpt-codex-connector[bot]' },
      updated_at: '2026-09-04T10:02:00Z',
      body: 'New review result.',
    }],
  });

  assert.equal(results.total, 0);
});

test('public-mutation and review-request outputs match their closed schema definitions', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const assertClosedShape = (value, definition) => {
    assert.deepEqual(Object.keys(value).sort(), [...definition.required].sort());
    assert.deepEqual(
      Object.keys(value).filter((key) => !Object.hasOwn(definition.properties, key)),
      [],
    );
  };
  const input = reviewInput();
  const mutation = reconcilePublicMutation({
    response: { ok: true },
    readback: { id: 42 },
    expected: { id: 42 },
    localRecordSucceeded: false,
  });

  assertClosedShape(requestFor(input, 'codex'), schema.$defs.reviewRequest);
  assertClosedShape(mutation, schema.$defs.publicMutation);
  assertClosedShape(state(input), schema);
});

test('typed schema, metrics, and 10/15-minute controls remain complete', async () => {
  const schemaUrl = new URL('./review-loop-policy.json', import.meta.url);
  const schema = JSON.parse(await readFile(schemaUrl, 'utf8'));
  const mutationClasses = schema.$defs.mutationClass.enum;
  const metrics = createMetrics({
    reviewRequests: [
      { head: HASHES.head1 },
      { head: HASHES.head1 },
      { head: HASHES.head2 },
    ],
    bodyEditTimes: ['2026-09-04T10:00:00Z', '2026-09-04T10:02:00Z'],
    reviewBeganAt: '2026-09-04T10:01:00Z',
    sameHeadRerequestReasons: [{ reason: 'Material risk changed.', material: true }],
    cleanReviewAt: '2026-09-04T10:03:00Z',
    recognizedAt: '2026-09-04T10:03:05Z',
    cleanPairAt: '2026-09-04T10:04:00Z',
    mergedAt: '2026-09-04T10:06:00Z',
  });

  assert.deepEqual(mutationClasses, MUTATION_CLASSES);
  assert.equal(metrics.reviewerRequestsPerHead[HASHES.head1], 2);
  assert.equal(metrics.bodyEditsAfterReviewBegan, 1);
  assert.equal(metrics.cleanReviewRecognitionMilliseconds, 5_000);
  assert.equal(metrics.cleanPairToMergeMilliseconds, 120_000);
  assert.deepEqual(evaluateFindingBudget({ elapsedMinutes: 10, hasOutcome: false }), {
    warningRequired: true,
    exceptionRequired: false,
  });
  assert.deepEqual(evaluateFindingBudget({ elapsedMinutes: 15, hasOutcome: false }), {
    warningRequired: true,
    exceptionRequired: true,
  });
});
