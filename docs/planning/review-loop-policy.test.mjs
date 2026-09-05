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
    copilotResults: {
      submittedReviews: [],
      conversationComments: [],
    },
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

function compactState(input, reviewOverrides = {}, taskOverrides = {}) {
  return {
    schema: 1,
    plan: 'docs/planning/action-items-2026-08-30.md',
    current_task: {
      number: 4,
      state: 'active',
      risk: 'R2',
      repository: 'franklesniak/PSStyleGuide',
      branch: 'agent/example',
      base: HASHES.head1,
      head: input.head,
      last_gate: null,
      next_action: 'Continue the review loop.',
      blocker: null,
      review: state(input, reviewOverrides),
      ...taskOverrides,
    },
    completed: [1, 2, 3],
    updated_utc: '2026-09-04T10:00:00Z',
  };
}

function requestFor(input, channel, overrides = {}) {
  return {
    channel,
    reviewInputKey: getReviewInputKey(input),
    head: input.head,
    requestedAt: '2026-09-04T10:00:00Z',
    terminal: false,
    baselineReviewNodeIds: [],
    baselineConversationComments: [],
    ...overrides,
  };
}

function pairFor(input, overrides = {}) {
  return [
    requestFor(input, 'copilot', { terminal: true, ...overrides }),
    requestFor(input, 'codex', { terminal: true, ...overrides }),
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

test('scenario 3a: H2 waits for a pending H1 pair before accepting a headless result', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({
    head: HASHES.head2,
    tree: HASHES.tree2,
    diffSha256: HASHES.diff2,
    bodySha256: HASHES.body2,
  });
  const mutationClass = classifyMutation(state(input1), state(input2));
  const pendingRequests = pairFor(input1, { terminal: false });
  const decision = decideReviewRequest({
    previousReviewInput: input1,
    currentReviewInput: input2,
    mutationClass,
    existingRequests: pendingRequests,
  });
  const recoveredWithoutPreviousInput = decideReviewRequest({
    previousReviewInput: null,
    currentReviewInput: input2,
    mutationClass: 'CODE_OR_DIFF',
    existingRequests: pendingRequests,
  });
  const lateH1Result = collectCodexResults({
    reviewInput: input1,
    request: pendingRequests.find((request) => request.channel === 'codex'),
    submittedReviews: [],
    conversationComments: [{
      id: 'H1_HEADLESS_RESULT',
      user: { login: 'chatgpt-codex-connector[bot]' },
      created_at: '2026-09-04T10:01:00Z',
      body: 'Review complete for the earlier request.',
    }],
  });

  assert.equal(decision.status, 'WAIT_FOR_PRIOR_PAIR');
  assert.equal(recoveredWithoutPreviousInput.status, 'WAIT_FOR_PRIOR_PAIR');
  assert.deepEqual(decision.channels, []);
  assert.match(decision.reason, /every prior review pair/iu);
  assert.deepEqual(
    lateH1Result.conversationComments.map((comment) => comment.id),
    ['H1_HEADLESS_RESULT'],
  );
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

test('scenario 5a: an interrupted same-head pair requests only its missing channel', () => {
  const input = reviewInput();
  const decision = decideReviewRequest({
    previousReviewInput: input,
    currentReviewInput: input,
    mutationClass: 'RESULT_OR_STATE',
    existingRequests: [requestFor(input, 'copilot')],
  });

  assert.equal(decision.status, 'REQUEST_REQUIRED');
  assert.deepEqual(decision.channels, ['codex']);
  assert.match(decision.reason, /already started/u);
});

test('scenario 5b: a material same-head request waits for the prior pair to finish', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({ risk: 'R2 sensitive planning change.' });
  const mutationClass = classifyMutation(state(input1), state(input2));
  const pending = decideReviewRequest({
    previousReviewInput: input1,
    currentReviewInput: input2,
    mutationClass,
    materialReason: 'The risk changed.',
    existingRequests: pairFor(input1, { terminal: false }),
  });
  const terminal = decideReviewRequest({
    previousReviewInput: input1,
    currentReviewInput: input2,
    mutationClass,
    materialReason: 'The risk changed.',
    existingRequests: pairFor(input1),
  });

  assert.equal(pending.status, 'WAIT_FOR_PRIOR_PAIR');
  assert.deepEqual(pending.channels, []);
  assert.match(pending.reason, /must become terminal/u);
  assert.deepEqual(collectCodexResults({
    reviewInput: input2,
    request: null,
    submittedReviews: [{
      id: 'OLD_PENDING_FINISHED_LATE',
      user: { login: 'chatgpt-codex-connector' },
      commit_id: HASHES.head1,
      submitted_at: '2026-09-04T10:02:00Z',
    }],
    conversationComments: [],
  }), { submittedReviews: [], conversationComments: [] });
  assert.equal(terminal.status, 'REQUEST_REQUIRED');
  assert.deepEqual(terminal.channels, ['copilot', 'codex']);
});

test('scenario 5c: a same-head diff change waits for the prior pair to finish', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({ diffSha256: HASHES.diff2 });
  const mutationClass = classifyMutation(state(input1), state(input2));
  const decision = decideReviewRequest({
    previousReviewInput: input1,
    currentReviewInput: input2,
    mutationClass,
    existingRequests: pairFor(input1, { terminal: false }),
  });

  assert.equal(mutationClass, 'CODE_OR_DIFF');
  assert.equal(decision.status, 'WAIT_FOR_PRIOR_PAIR');
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
  assert.equal(results.submittedReviews.length + results.conversationComments.length, 2);
  assert.deepEqual(Object.keys(results).sort(), ['conversationComments', 'submittedReviews']);
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
  const rejectedWithMatchingReadback = reconcilePublicMutation({
    response: { executed: false },
    readback: expected,
    expected,
    localRecordSucceeded: false,
  });
  const contradictoryResponse = reconcilePublicMutation({
    response: { ok: true, executed: false },
    readback: expected,
    expected,
    localRecordSucceeded: true,
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
  assert.deepEqual(rejectedWithMatchingReadback, {
    state: 'NOT_EXECUTED',
    nativeResponseAccepted: false,
    readbackMatched: true,
    retryAllowed: false,
    localRecordSucceeded: false,
  });
  assert.deepEqual(contradictoryResponse, {
    state: 'AMBIGUOUS',
    nativeResponseAccepted: true,
    readbackMatched: true,
    retryAllowed: false,
    localRecordSucceeded: true,
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
  assert.match(parent, /no-safe-work human boundary -> waiting_human/u);
  assert.doesNotMatch(parent, /any nonterminal state -> waiting_human/u);
  assert.match(alternate, /without model routing/u);
  assert.match(alternate, /Do not create manifest/u);
  assert.match(alternate, /no-safe-work human boundary -> waiting_human/u);
  assert.match(
    alternate,
    /Use `waiting_human` only when the next concrete action needs one exact human decision or exceptional action and no independent safe in-scope work remains\./u,
  );
  assert.doesNotMatch(alternate, /any nonterminal state -> waiting_human/u);
  assert.match(generator, /Do not split routine work/u);
  assert.match(generator, /Default to one reviewer pair/u);
  assert.match(crossRepository, /one compact state record/u);
  assert.match(crossRepository, /applicable `AGENTS\.md`/u);
  assert.match(crossRepository, /root `CLAUDE\.md` as compatibility workflow instructions/u);
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
  assert.deepEqual(results, { submittedReviews: [], conversationComments: [] });
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

test('schema-defined nested review-state fields classify deterministically', () => {
  const input = reviewInput();
  const original = state(input);
  const resultChanges = [
    { reviewRequests: [requestFor(input, 'codex')] },
    { copilotResults: { submittedReviews: [{ id: 1 }], conversationComments: [] } },
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

test('compact state preserves empty, singleton, and multiple Copilot results', () => {
  const input = reviewInput();
  const empty = state(input).copilotResults;
  const singleton = state(input, {
    copilotResults: { submittedReviews: [{ id: 1 }], conversationComments: [] },
  }).copilotResults;
  const multiple = state(input, {
    copilotResults: {
      submittedReviews: [{ id: 1 }, { id: 2 }],
      conversationComments: [{ id: 3 }, { id: 4 }],
    },
  }).copilotResults;

  assert.deepEqual(empty, { submittedReviews: [], conversationComments: [] });
  assert.deepEqual(singleton.submittedReviews.map((review) => review.id), [1]);
  assert.deepEqual(multiple.submittedReviews.map((review) => review.id), [1, 2]);
  assert.deepEqual(multiple.conversationComments.map((comment) => comment.id), [3, 4]);
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
  assert.equal(results.submittedReviews.length + results.conversationComments.length, 2);
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

  assert.deepEqual(results, { submittedReviews: [], conversationComments: [] });
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

  assert.deepEqual(results, { submittedReviews: [], conversationComments: [] });
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

  assert.deepEqual(results, { submittedReviews: [], conversationComments: [] });
});

function resolveSchemaReference(definition, root) {
  if (typeof definition?.$ref !== 'string') {
    return definition;
  }

  return definition.$ref
    .slice(2)
    .split('/')
    .map((part) => part.replaceAll('~1', '/').replaceAll('~0', '~'))
    .reduce((value, part) => value[part], root);
}

function assertSchemaValid(value, definition, root, location = '$') {
  const resolved = resolveSchemaReference(definition, root);
  const allowedTypes = Array.isArray(resolved.type) ? resolved.type : [resolved.type];
  const matchesType = (type) => {
    if (type === undefined) return true;
    if (type === 'null') return value === null;
    if (type === 'array') return Array.isArray(value);
    if (type === 'object') return value !== null && typeof value === 'object' && !Array.isArray(value);
    if (type === 'integer') return Number.isInteger(value);
    return typeof value === type;
  };

  if (!allowedTypes.some(matchesType)) {
    assert.fail(`${location} has the wrong type.`);
  }
  if (Object.hasOwn(resolved, 'const')) {
    assert.deepEqual(value, resolved.const, `${location} does not match const.`);
  }
  if (resolved.enum !== undefined) {
    assert.ok(resolved.enum.includes(value), `${location} is not in the enum.`);
  }
  if (typeof value === 'string') {
    if (resolved.minLength !== undefined) {
      assert.ok(value.length >= resolved.minLength, `${location} is too short.`);
    }
    if (resolved.pattern !== undefined) {
      assert.match(value, new RegExp(resolved.pattern, 'u'), `${location} does not match pattern.`);
    }
  }
  if (typeof value === 'number' && resolved.minimum !== undefined) {
    assert.ok(value >= resolved.minimum, `${location} is below minimum.`);
  }
  if (Array.isArray(value)) {
    if (resolved.uniqueItems === true) {
      assert.equal(new Set(value.map((item) => JSON.stringify(item))).size, value.length);
    }
    if (resolved.items !== undefined) {
      value.forEach((item, index) => assertSchemaValid(item, resolved.items, root, `${location}[${index}]`));
    }
  }
  if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
    for (const required of resolved.required ?? []) {
      assert.ok(Object.hasOwn(value, required), `${location}.${required} is required.`);
    }
    for (const [key, item] of Object.entries(value)) {
      if (Object.hasOwn(resolved.properties ?? {}, key)) {
        assertSchemaValid(item, resolved.properties[key], root, `${location}.${key}`);
      } else if (resolved.additionalProperties === false) {
        assert.fail(`${location}.${key} is not allowed.`);
      } else if (typeof resolved.additionalProperties === 'object') {
        assertSchemaValid(item, resolved.additionalProperties, root, `${location}.${key}`);
      }
    }
  }
  for (const condition of resolved.allOf ?? []) {
    let conditionMatches = true;
    try {
      assertSchemaValid(value, condition.if, root, location);
    } catch {
      conditionMatches = false;
    }
    if (conditionMatches && condition.then !== undefined) {
      assertSchemaValid(value, condition.then, root, location);
    }
  }
}

test('the actual compact resume record and review state match their closed schema', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const assertClosedShape = (value, definition) => {
    for (const required of definition.required) {
      assert.ok(Object.hasOwn(value, required), `${required} is required.`);
    }
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
  const persisted = compactState(input);
  const parent = await readFile(new URL('./coding-agent-loop.md', import.meta.url), 'utf8');
  const alternate = await readFile(
    new URL('./coding-agent-loop-without-model-routing.md', import.meta.url),
    'utf8',
  );
  const readControllerExample = (controller) => {
    const match = /## Compact state record[\s\S]*?```json\r?\n(?<json>[\s\S]*?)\r?\n```/u.exec(controller);
    assert.notEqual(match, null);
    return JSON.parse(match.groups.json);
  };

  assertClosedShape(requestFor(input, 'codex'), schema.$defs.reviewRequest);
  assertClosedShape(mutation, schema.$defs.publicMutation);
  assertClosedShape(persisted, schema);
  assertClosedShape(persisted.current_task, schema.$defs.taskState);
  assertClosedShape(persisted.current_task.review, schema.$defs.reviewState);
  assertClosedShape(state(input).copilotResults, schema.$defs.reviewerResults);
  assertClosedShape(state(input).codexResults, schema.$defs.reviewerResults);
  assertSchemaValid(persisted, schema, schema);
  assertSchemaValid(readControllerExample(parent), schema, schema);
  assertSchemaValid(readControllerExample(alternate), schema, schema);
});

test('a confirmed request survives local state-write failure without a duplicate', () => {
  const input = reviewInput();
  const requests = pairFor(input, { terminal: false });
  const mutation = reconcilePublicMutation({
    response: { ok: true, status: 201 },
    readback: requests[1],
    expected: requests[1],
    localRecordSucceeded: false,
  });
  const decision = decideReviewRequest({
    previousReviewInput: input,
    currentReviewInput: input,
    mutationClass: 'RESULT_OR_STATE',
    existingRequests: requests,
  });

  assert.equal(mutation.state, 'CONFIRMED');
  assert.equal(mutation.retryAllowed, false);
  assert.equal(decision.status, 'NO_REQUEST');
  assert.deepEqual(decision.channels, []);
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

test('metrics reject invalid, incomplete, and reversed timestamps', () => {
  const valid = {
    reviewRequests: [],
    bodyEditTimes: [],
    reviewBeganAt: '2026-09-04T10:00:00Z',
    sameHeadRerequestReasons: [],
    cleanReviewAt: null,
    recognizedAt: null,
    cleanPairAt: null,
    mergedAt: null,
  };

  assert.deepEqual(createMetrics(valid), {
    reviewerRequestsPerHead: {},
    bodyEditsAfterReviewBegan: 0,
    sameHeadRerequestReasons: [],
    cleanReviewRecognitionMilliseconds: null,
    cleanPairToMergeMilliseconds: null,
  });
  assert.throws(
    () => createMetrics({ ...valid, reviewBeganAt: 'not-a-date' }),
    /reviewBeganAt must be a valid timestamp/u,
  );
  for (const timestamp of [
    '2026-09-04',
    '2026-09-04T10:00:00',
    'September 4, 2026 10:00:00 UTC',
    '2026-02-30T10:00:00Z',
    '2025-02-29T10:00:00Z',
    '2026-04-31T10:00:00Z',
    '2026-09-04T24:00:00Z',
    '2026-09-04T10:00:00+14:01',
    '2026-09-04T10:00:00+15:00',
  ]) {
    assert.throws(
      () => createMetrics({ ...valid, reviewBeganAt: timestamp }),
      /reviewBeganAt must be a valid timestamp/u,
      timestamp,
    );
  }
  for (const timestamp of [
    '2024-02-29T23:59:59Z',
    '2026-09-04t10:00:00.123456z',
    '2026-09-04T10:00:00+05:30',
    '2026-09-04T10:00:00-14:00',
  ]) {
    assert.doesNotThrow(
      () => createMetrics({ ...valid, reviewBeganAt: timestamp }),
      timestamp,
    );
  }
  assert.throws(
    () => createMetrics({ ...valid, bodyEditTimes: ['not-a-date'] }),
    /bodyEditTimes\[0\] must be a valid timestamp/u,
  );
  assert.throws(
    () => createMetrics({ ...valid, cleanReviewAt: '2026-09-04T10:00:00Z' }),
    /cleanReviewAt and recognizedAt must both be null or valid timestamps/u,
  );
  assert.throws(
    () => createMetrics({
      ...valid,
      cleanReviewAt: '2026-09-04T10:01:00Z',
      recognizedAt: '2026-09-04T10:00:00Z',
    }),
    /recognizedAt must not be earlier than cleanReviewAt/u,
  );
});

test('review requests and schema use the same RFC 3339 grammar', async () => {
  const input = reviewInput();
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const grammar = new RegExp(schema.$defs.rfc3339.pattern, 'u');

  for (const timestamp of [
    '2026-09-04T10:00:00Z',
    '2026-09-04t10:00:00.123z',
    '2026-09-04T10:00:00+05:30',
  ]) {
    assert.match(timestamp, grammar);
    assert.doesNotThrow(() => decideReviewRequest({
      previousReviewInput: input,
      currentReviewInput: input,
      mutationClass: 'RESULT_OR_STATE',
      existingRequests: [requestFor(input, 'copilot', { requestedAt: timestamp })],
    }));
  }

  for (const timestamp of [
    '2026-09-04',
    '2026-09-04T10:00:00',
    '09/04/2026 10:00:00',
    '2026-09-04T10:00:00+14:01',
  ]) {
    assert.doesNotMatch(timestamp, grammar);
    assert.throws(
      () => decideReviewRequest({
        previousReviewInput: input,
        currentReviewInput: input,
        mutationClass: 'RESULT_OR_STATE',
        existingRequests: [requestFor(input, 'copilot', { requestedAt: timestamp })],
      }),
      /malformed or mismatched/u,
    );
  }
});
