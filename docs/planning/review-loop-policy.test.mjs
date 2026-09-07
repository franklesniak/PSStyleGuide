import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';
import {
  MUTATION_CLASSES,
  PLAN_TASK_COUNT,
  REVIEW_MAX_CHANNEL_ATTEMPTS,
  REVIEW_LOOP_TASK_NUMBERS,
  REVIEW_TERMINAL_FAILURE_RETRY_MILLISECONDS,
  REVIEW_TERMINAL_FAILURE_STATUSES,
  classifyMutation,
  collectCodexRequestEvidence,
  collectCopilotRequestEvidence,
  collectCodexResults,
  createReviewRequestSpec,
  createMetrics,
  createReviewInput,
  decideReviewRequest,
  evaluateReviewMergeReadiness,
  evaluateFindingBudget,
  getReviewInputKey,
  normalizeCollection,
  parseCompactStateJson,
  prunePredecessorOutputs,
  reconcilePublicMutation,
  reconcileReviewRequestMutation,
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
  const value = {
    schemaVersion: 1,
    reviewInput: input,
    mutationClass: 'RESULT_OR_STATE',
    reviewRequests: [],
    supersededReviewInputs: {},
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
      reviewedHeadEvidence: {},
      bodyEditsAfterReviewBegan: 0,
      sameHeadRerequestReasons: [],
      cleanReviewRecognitionMilliseconds: null,
      cleanPairToMergeMilliseconds: null,
    },
    commentPublications: [],
    ...overrides,
  };
  if (!Object.hasOwn(overrides, 'metrics')) {
    const requestsPerHead = {};
    for (const request of value.reviewRequests) {
      requestsPerHead[request.head] =
        (requestsPerHead[request.head] ?? 0) + (request.attemptCount ?? 1);
    }
    requestsPerHead[input.head] ??= 0;
    value.metrics = {
      ...value.metrics,
      reviewerRequestsPerHead: requestsPerHead,
      reviewedHeadEvidence: Object.fromEntries(
        Object.entries(requestsPerHead)
          .filter(([, count]) => count === 0)
          .map(([head]) => [
            head,
            {
              source: 'authenticated-pr-readback',
              tree: head === input.head ? input.tree : HASHES.tree1,
              observedAt: '2026-09-04T09:00:00Z',
            },
          ]),
      ),
    };
  }
  for (const channel of ['copilot', 'codex']) {
    const field = `${channel}Results`;
    if (!Object.hasOwn(overrides, field)) {
      const results = value.reviewRequests
        .filter((request) => request.channel === channel && (
          request.terminalResultRef || request.terminalFailureRef
        ))
        .map((request) => resultForRequest(request));
      value[field] = {
        submittedReviews: results.filter((result) => result.kind === 'submitted-review')
          .map((result) => result.value),
        conversationComments: results
          .filter((result) => result.kind === 'conversation-comment')
          .map((result) => result.value),
      };
    }
  }
  return value;
}

function compactState(input, reviewOverrides = {}, taskOverrides = {}, rootOverrides = {}) {
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
    predecessor_outputs: {},
    completed: [1, 2, 3],
    updated_utc: '2026-09-04T10:00:00Z',
    ...rootOverrides,
  };
}

function requestFor(input, channel, overrides = {}) {
  const request = {
    channel,
    channelAttempt: 1,
    reviewInputKey: getReviewInputKey(input),
    head: input.head,
    requestedAt: '2026-09-04T10:00:00Z',
    confirmed: false,
    terminal: false,
    baselineRequestEventIds: [],
    baselineReviewNodeIds: [],
    baselineReviewRunIds: [],
    baselineConversationComments: {},
    ...overrides,
  };
  if (request.channel === 'copilot' && !Object.hasOwn(request, 'readyAt')) {
    if (request.confirmed === true) {
      request.readyAt = request.requestedAt;
    } else if (
      request.terminal === true &&
      Object.hasOwn(request, 'terminalDisposition')
    ) {
      request.readyAt = request.terminalDisposition.recordedAt;
    }
  }
  if (
    request.confirmed === true &&
    request.terminal === true &&
    !Object.hasOwn(request, 'terminalResultRef') &&
    !Object.hasOwn(request, 'terminalFailureRef')
  ) {
    request.terminalResultRef = {
      kind: 'submitted-review',
      id: `RESULT_${channel}_${input.head}`,
      observedAt: '2026-09-04T10:01:00Z',
    };
  }
  return request;
}

function resultForRequest(request) {
  const actor = request.channel === 'copilot'
    ? 'copilot-pull-request-reviewer[bot]'
    : 'chatgpt-codex-connector[bot]';
  if (Object.hasOwn(request, 'terminalFailureRef')) {
    return {
      kind: 'conversation-comment',
      value: {
        nodeId: request.terminalFailureRef.id,
        actor,
        updatedAt: request.terminalFailureRef.observedAt,
        status: request.terminalFailureRef.status,
        commitPrefix: request.head.slice(0, 7),
        terminalSummaryId: request.terminalFailureRef.summaryId,
        terminalSummaryUpdatedAt: request.terminalFailureRef.summaryObservedAt,
      },
    };
  }
  if (request.terminalResultRef.kind === 'submitted-review') {
    return {
      kind: 'submitted-review',
      value: {
        nodeId: request.terminalResultRef.id,
        actor,
        commit: request.head,
        submittedAt: request.terminalResultRef.observedAt,
      },
    };
  }
  return {
    kind: 'conversation-comment',
    value: {
      nodeId: request.terminalResultRef.id,
      actor,
      updatedAt: request.terminalResultRef.observedAt,
      status: 'completed',
      commitPrefix: request.head.slice(0, 7),
    },
  };
}

function nonfunctionalDisposition(overrides = {}) {
  return {
    state: 'REPOSITORY_AUTHORIZED_NON_FUNCTIONAL',
    recordedAt: '2026-09-04T10:01:00Z',
    authority: 'Repository reviewer-unavailability instructions.',
    reason: 'Two accepted requests produced complete negative evidence.',
    ...overrides,
  };
}

function terminalFailureRef(overrides = {}) {
  return {
    kind: 'conversation-comment',
    id: 'CODEX_FAILURE_ONE',
    observedAt: '2026-09-04T10:02:00Z',
    summaryId: 'CODEX_SUMMARY',
    summaryObservedAt: '2026-09-04T10:02:01Z',
    status: 'failed',
    ...overrides,
  };
}

function failedCodexRequest(input, overrides = {}) {
  return requestFor(input, 'codex', {
    requestedAt: '2026-09-04T10:01:00Z',
    confirmed: true,
    terminal: true,
    terminalFailureRef: terminalFailureRef(),
    ...overrides,
  });
}

function reviewerExhaustionAuthority(input, overrides = {}) {
  return {
    state: 'OPERATOR_AUTHORIZED_EXHAUSTED_NOT_CLEAN',
    repository: 'franklesniak/PSStyleGuide',
    pullRequest: 182,
    reviewInputKey: getReviewInputKey(input),
    head: input.head,
    channel: 'codex',
    maximumChannelAttempts: 3,
    completedReviewRounds: 21,
    authorizedAt: '2026-09-04T10:06:01Z',
    authority: 'Explicit operator direction in the durable F152 addendum.',
    reason: 'PR 182 completed more than 20 review rounds.',
    ...overrides,
  };
}

function supersessionFor(input, successorInput, overrides = {}) {
  return {
    [getReviewInputKey(input)]: {
      state: 'SUPERSEDED',
      head: input.head,
      successorHead: successorInput.head,
      supersededAt: '2026-09-04T10:02:00Z',
      reason: 'Authenticated PR readback shows that the old head is no longer current.',
      ...overrides,
    },
  };
}

function pairFor(input, overrides = {}) {
  return [
    requestFor(input, 'copilot', { confirmed: true, terminal: true, ...overrides }),
    requestFor(input, 'codex', { confirmed: true, terminal: true, ...overrides }),
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

test('review-input construction and key derivation require the exact closed contract', () => {
  const input = structuredClone(reviewInput());
  assert.deepEqual(createReviewInput(input), input);
  assert.match(getReviewInputKey(input), /^[0-9a-f]{64}$/u);

  const invalidInputs = [null, undefined, true, []];
  for (const field of [
    'head',
    'tree',
    'diffSha256',
    'bodySha256',
    'scope',
    'behavior',
    'risk',
  ]) {
    const missing = structuredClone(input);
    delete missing[field];
    invalidInputs.push(missing);
  }
  invalidInputs.push({ ...input, unexpected: true });
  invalidInputs.push({ ...input, tree: null });

  for (const invalidInput of invalidInputs) {
    assert.throws(
      () => createReviewInput(invalidInput),
      /required fields|must be|invalid hash/u,
    );
    assert.throws(
      () => getReviewInputKey(invalidInput),
      /required fields|must be|invalid hash/u,
    );

    const persisted = compactState(input);
    persisted.current_task.review.reviewInput = invalidInput;
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(persisted)),
      /required fields|must be|invalid hash/u,
    );
  }
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
  assert.deepEqual(decision.channels, ['copilot']);
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
    reviewRequests: pendingRequests,
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

test('scenario 3b: authenticated head drift supersedes an impossible missing H1 request', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({
    head: HASHES.head2,
    tree: HASHES.tree2,
    diffSha256: HASHES.diff2,
    bodySha256: HASHES.body2,
  });
  const mutationClass = classifyMutation(state(input1), state(input2));
  const oldRequest = requestFor(input1, 'copilot', {
    confirmed: true,
    terminal: true,
  });
  const requiresDisposition = decideReviewRequest({
    previousReviewInput: input1,
    currentReviewInput: input2,
    mutationClass,
    existingRequests: [oldRequest],
  });
  const supersession = supersessionFor(input1, input2);
  const recovered = decideReviewRequest({
    previousReviewInput: input1,
    currentReviewInput: input2,
    mutationClass,
    existingRequests: [oldRequest],
    supersededInputs: supersession,
  });
  assert.equal(requiresDisposition.status, 'SUPERSESSION_REQUIRED');
  assert.deepEqual(
    requiresDisposition.supersedeReviewInputKeys,
    [getReviewInputKey(input1)],
  );
  assert.equal(recovered.status, 'REQUEST_REQUIRED');
  assert.deepEqual(recovered.channels, ['copilot']);
  assert.deepEqual(collectCodexResults({
    reviewInput: input2,
    request: oldRequest,
    reviewRequests: [oldRequest],
    submittedReviews: [],
    conversationComments: [{
      id: 'LATE_H1_RESULT',
      user: { login: 'chatgpt-codex-connector[bot]' },
      created_at: '2026-09-04T10:03:00Z',
      body: 'Late result for H1.',
    }],
  }), { submittedReviews: [], conversationComments: [] });
});

test('scenario 3c: authenticated same-head input drift supersedes an impossible missing request', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({ risk: 'R2 sensitive planning change.' });
  const mutationClass = classifyMutation(state(input1), state(input2));
  const oldRequest = requestFor(input1, 'copilot', {
    confirmed: true,
    terminal: true,
  });
  const requiresDisposition = decideReviewRequest({
    previousReviewInput: input1,
    currentReviewInput: input2,
    mutationClass,
    materialReason: 'The risk changed.',
    existingRequests: [oldRequest],
  });
  const recovered = decideReviewRequest({
    previousReviewInput: input1,
    currentReviewInput: input2,
    mutationClass,
    materialReason: 'The risk changed.',
    existingRequests: [oldRequest],
    supersededInputs: supersessionFor(input1, input2, {
      reason: 'Authenticated reviewed-input drift made the missing old request impossible.',
    }),
  });

  assert.equal(requiresDisposition.status, 'SUPERSESSION_REQUIRED');
  assert.deepEqual(
    requiresDisposition.supersedeReviewInputKeys,
    [getReviewInputKey(input1)],
  );
  assert.equal(recovered.status, 'REQUEST_REQUIRED');
  assert.deepEqual(recovered.channels, ['copilot']);
});

test('old-head supersession rejects forged, current-input, and complete-pair records', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({
    head: HASHES.head2,
    tree: HASHES.tree2,
    diffSha256: HASHES.diff2,
    bodySha256: HASHES.body2,
  });
  const mutationClass = classifyMutation(state(input1), state(input2));
  const oldRequest = requestFor(input1, 'copilot', {
    confirmed: true,
    terminal: true,
  });
  const decide = (supersededInputs, existingRequests = [oldRequest]) => decideReviewRequest({
    previousReviewInput: input1,
    currentReviewInput: input2,
    mutationClass,
    existingRequests,
    supersededInputs,
  });

  assert.throws(
    () => decide(supersessionFor(input1, input2, { successorHead: HASHES.tree1 })),
    /does not describe/u,
  );
  assert.throws(
    () => decide(supersessionFor(input2, input1)),
    /malformed|does not describe/u,
  );
  assert.throws(
    () => decide(supersessionFor(input1, input2), pairFor(input1, { terminal: false })),
    /does not describe/u,
  );
  assert.throws(
    () => decide([supersessionFor(input1, input2)]),
    /keyed map/u,
  );
});

test('decision gating rejects transport-invalid supersession reasons', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({
    head: HASHES.head2,
    tree: HASHES.tree2,
    diffSha256: HASHES.diff2,
    bodySha256: HASHES.body2,
  });
  const oldRequest = requestFor(input1, 'copilot', {
    confirmed: true,
    terminal: true,
  });

  assert.throws(
    () => decideReviewRequest({
      previousReviewInput: input1,
      currentReviewInput: input2,
      mutationClass: 'CODE_OR_DIFF',
      existingRequests: [oldRequest],
      supersededInputs: supersessionFor(input1, input2, {
        reason: 'Authenticated drift\u0001hidden',
      }),
    }),
    /malformed/u,
  );
});

test('a reactivated superseded input resumes its original incomplete pair', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({ risk: 'R2 sensitive planning change.' });
  const oldRequest = requestFor(input1, 'copilot', {
    confirmed: true,
    terminal: true,
  });
  const successorPair = [
    requestFor(input2, 'copilot', {
      confirmed: true,
      terminal: true,
      requestedAt: '2026-09-04T10:02:00Z',
      terminalResultRef: {
        kind: 'submitted-review',
        id: 'REACTIVATION_SUCCESSOR_COPILOT',
        observedAt: '2026-09-04T10:03:00Z',
      },
    }),
    requestFor(input2, 'codex', {
      confirmed: true,
      terminal: true,
      requestedAt: '2026-09-04T10:03:00Z',
      terminalResultRef: {
        kind: 'submitted-review',
        id: 'REACTIVATION_SUCCESSOR_CODEX',
        observedAt: '2026-09-04T10:04:00Z',
      },
    }),
  ];
  const decision = decideReviewRequest({
    previousReviewInput: input2,
    currentReviewInput: input1,
    mutationClass: classifyMutation(state(input2), state(input1)),
    materialReason: 'The prior risk change was reverted.',
    existingRequests: [oldRequest, ...successorPair],
    supersededInputs: supersessionFor(input1, input2),
  });

  assert.equal(decision.status, 'REQUEST_REQUIRED');
  assert.deepEqual(decision.channels, ['codex']);
  assert.match(decision.reason, /already started/u);
});

test('a reactivated request retains the completed successor boundary', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({ risk: 'R2 sensitive planning change.' });
  const oldRequest = requestFor(input1, 'copilot', {
    confirmed: true,
    terminal: true,
  });
  const successorPair = [
    requestFor(input2, 'copilot', {
      confirmed: true,
      terminal: true,
      requestedAt: '2026-09-04T10:03:00Z',
      terminalResultRef: {
        kind: 'submitted-review',
        id: 'REACTIVATION_BOUNDARY_COPILOT',
        observedAt: '2026-09-04T10:04:00Z',
      },
    }),
    requestFor(input2, 'codex', {
      confirmed: true,
      terminal: true,
      requestedAt: '2026-09-04T10:04:00Z',
      terminalResultRef: {
        kind: 'submitted-review',
        id: 'REACTIVATION_BOUNDARY_CODEX',
        observedAt: '2026-09-04T10:05:00Z',
      },
    }),
  ];
  const reactivatedRequest = requestFor(input1, 'codex', {
    requestedAt: '2026-09-04T10:06:00Z',
  });
  const persisted = compactState(input1, {
    mutationClass: 'MATERIAL_SCOPE_BEHAVIOR_RISK',
    materialReason: 'The prior risk change was reverted.',
    reviewRequests: [oldRequest, ...successorPair, reactivatedRequest],
    supersededReviewInputs: supersessionFor(input1, input2),
  });

  assert.deepEqual(parseCompactStateJson(JSON.stringify(persisted)), persisted);
});

test('a reactivated input still validates its retained supersession boundary', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({ risk: 'R2 sensitive planning change.' });
  const oldRequest = requestFor(input1, 'copilot', {
    confirmed: true,
    terminal: true,
    terminalResultRef: {
      kind: 'submitted-review',
      id: 'REACTIVATED_OLD_COPILOT',
      observedAt: '2026-09-04T10:00:30Z',
    },
  });
  const successorPair = [
    requestFor(input2, 'copilot', {
      confirmed: true,
      terminal: true,
      requestedAt: '2026-09-04T10:01:00Z',
      terminalResultRef: {
        kind: 'submitted-review',
        id: 'RETROACTIVE_SUCCESSOR_COPILOT',
        observedAt: '2026-09-04T10:01:15Z',
      },
    }),
    requestFor(input2, 'codex', {
      confirmed: true,
      terminal: true,
      requestedAt: '2026-09-04T10:01:30Z',
      terminalResultRef: {
        kind: 'submitted-review',
        id: 'RETROACTIVE_SUCCESSOR_CODEX',
        observedAt: '2026-09-04T10:01:45Z',
      },
    }),
  ];
  const reactivated = compactState(input1, {
    mutationClass: 'MATERIAL_SCOPE_BEHAVIOR_RISK',
    materialReason: 'The prior risk change was reverted.',
    reviewRequests: [oldRequest, ...successorPair],
    supersededReviewInputs: supersessionFor(input1, input2, {
      supersededAt: '2026-09-04T10:02:00Z',
    }),
  });

  assert.throws(
    () => parseCompactStateJson(JSON.stringify(reactivated)),
    /terminal incomplete prior-input pair/u,
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
  assert.deepEqual(decision.channels, ['copilot']);
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

test('the non-invalidating final decision path has one exact result', () => {
  const previousInput = reviewInput();
  const currentInput = reviewInput({ bodySha256: HASHES.body2 });
  const expected = {
    status: 'REJECTED_SAME_HEAD',
    reviewInputKey: getReviewInputKey(currentInput),
    channels: [],
    reason: 'The reviewed input is unchanged.',
  };

  assert.equal(getReviewInputKey(previousInput), getReviewInputKey(currentInput));
  for (const mutationClass of [
    null,
    'NON_MATERIAL_FACT',
    'RESULT_OR_STATE',
    'COMMENT_ONLY',
  ]) {
    const decision = decideReviewRequest({
      previousReviewInput: previousInput,
      currentReviewInput: currentInput,
      mutationClass,
      existingRequests: [],
    });

    assert.deepEqual(decision, expected);
    assert.notEqual(decision.status, 'NO_REQUEST');
    assert.notEqual(decision.reason, 'The change class does not invalidate code review.');
  }
});

test('scenario 5a: a same-head pair releases Codex after Copilot confirmation or terminal disposition', () => {
  const input = reviewInput();
  const pending = decideReviewRequest({
    previousReviewInput: input,
    currentReviewInput: input,
    mutationClass: 'RESULT_OR_STATE',
    existingRequests: [requestFor(input, 'copilot')],
  });
  const confirmed = decideReviewRequest({
    previousReviewInput: input,
    currentReviewInput: input,
    mutationClass: 'RESULT_OR_STATE',
    existingRequests: [requestFor(input, 'copilot', { confirmed: true })],
  });
  const terminal = decideReviewRequest({
    previousReviewInput: input,
    currentReviewInput: input,
    mutationClass: 'RESULT_OR_STATE',
    existingRequests: [requestFor(input, 'copilot', {
      terminal: true,
      terminalDisposition: nonfunctionalDisposition(),
    })],
  });

  assert.equal(pending.status, 'WAIT_FOR_CURRENT_CHANNEL');
  assert.deepEqual(pending.channels, []);
  assert.match(pending.reason, /confirmed or terminally proved non-functional/u);
  assert.equal(confirmed.status, 'REQUEST_REQUIRED');
  assert.deepEqual(confirmed.channels, ['codex']);
  assert.equal(terminal.status, 'REQUEST_REQUIRED');
  assert.deepEqual(terminal.channels, ['codex']);
  assert.match(terminal.reason, /already started/u);
});

test('decision gating rejects transport-invalid terminal disposition text', () => {
  const input = reviewInput();
  const decide = (terminalDisposition) => decideReviewRequest({
    previousReviewInput: input,
    currentReviewInput: input,
    mutationClass: 'RESULT_OR_STATE',
    existingRequests: [requestFor(input, 'copilot', {
      terminal: true,
      terminalDisposition,
    })],
  });

  for (const terminalDisposition of [
    nonfunctionalDisposition({ authority: 'Repository policy\u0001hidden' }),
    nonfunctionalDisposition({ reason: 'Reviewer unavailable\u0001hidden' }),
  ]) {
    assert.throws(() => decide(terminalDisposition), /malformed/u);
  }
  assert.equal(decide(nonfunctionalDisposition()).status, 'REQUEST_REQUIRED');
});

test('Codex requests require an eligible earlier Copilot predecessor', () => {
  const input = reviewInput();
  const codexRequest = requestFor(input, 'codex', {
    requestedAt: '2026-09-04T10:01:00Z',
  });
  const orphan = [codexRequest];
  const premature = [
    requestFor(input, 'copilot'),
    codexRequest,
  ];
  const reversed = [
    requestFor(input, 'copilot', {
      confirmed: true,
      requestedAt: '2026-09-04T10:02:00Z',
    }),
    codexRequest,
  ];
  const validConfirmed = [
    requestFor(input, 'copilot', {
      confirmed: true,
      requestedAt: '2026-09-04T10:00:00Z',
    }),
    codexRequest,
  ];
  const validTerminal = [
    requestFor(input, 'copilot', {
      terminal: true,
      requestedAt: '2026-09-04T10:00:00Z',
      terminalDisposition: nonfunctionalDisposition(),
    }),
    codexRequest,
  ];
  const decide = (reviewRequests) => decideReviewRequest({
    previousReviewInput: input,
    currentReviewInput: input,
    mutationClass: 'RESULT_OR_STATE',
    existingRequests: reviewRequests,
  });

  assert.throws(() => decide(orphan), /eligible Copilot predecessor/u);
  assert.throws(() => decide(premature), /eligible Copilot predecessor/u);
  assert.throws(() => decide(reversed), /must not precede/u);
  for (const [reviewRequests, expectedError] of [
    [orphan, /eligible Copilot predecessor/u],
    [premature, /eligible Copilot predecessor/u],
    [reversed, /must not precede/u],
  ]) {
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(compactState(input, {
        reviewRequests,
      }))),
      expectedError,
    );
  }
  assert.equal(decide(validConfirmed).status, 'NO_REQUEST');
  assert.equal(decide(validTerminal).status, 'NO_REQUEST');

  const conversationComments = [{
    id: 'HEADLESS',
    user: { login: 'chatgpt-codex-connector[bot]' },
    created_at: '2026-09-04T10:02:00Z',
    body: 'Review complete with no findings.',
  }];
  for (const reviewRequests of [orphan, premature, reversed]) {
    assert.deepEqual(collectCodexResults({
      reviewInput: input,
      request: codexRequest,
      reviewRequests,
      submittedReviews: [],
      conversationComments,
    }), { submittedReviews: [], conversationComments: [] });
  }
  assert.deepEqual(collectCodexResults({
    reviewInput: input,
    request: codexRequest,
    reviewRequests: validConfirmed,
    submittedReviews: [],
    conversationComments,
  }).conversationComments.map((comment) => comment.id), ['HEADLESS']);
});

test('current-input records cannot bypass different-input pair serialization', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({
    head: HASHES.head2,
    tree: HASHES.tree2,
    diffSha256: HASHES.diff2,
    bodySha256: HASHES.body2,
  });
  const mutationClass = classifyMutation(state(input1), state(input2));
  const pendingOldPair = pairFor(input1, { terminal: false });
  const partialCurrentPair = [requestFor(input2, 'copilot', {
    requestedAt: '2026-09-04T10:03:00Z',
  })];
  const completeCurrentPair = pairFor(input2, { terminal: false });
  const pendingPartial = () => decideReviewRequest({
    previousReviewInput: input1,
    currentReviewInput: input2,
    mutationClass,
    existingRequests: [...pendingOldPair, ...partialCurrentPair],
  });
  const pendingComplete = () => decideReviewRequest({
    previousReviewInput: input1,
    currentReviewInput: input2,
    mutationClass,
    existingRequests: [...pendingOldPair, ...completeCurrentPair],
  });
  const terminalOld = decideReviewRequest({
    previousReviewInput: input1,
    currentReviewInput: input2,
    mutationClass,
    existingRequests: [...pairFor(input1), ...partialCurrentPair],
  });
  const supersededOld = decideReviewRequest({
    previousReviewInput: input1,
    currentReviewInput: input2,
    mutationClass,
    existingRequests: [requestFor(input1, 'copilot', {
      confirmed: true,
      terminal: true,
    }), ...partialCurrentPair],
    supersededInputs: supersessionFor(input1, input2),
  });

  assert.throws(pendingPartial, /earlier-input request to be terminal first/u);
  assert.throws(pendingComplete, /earlier-input request to be terminal first/u);
  assert.equal(terminalOld.status, 'WAIT_FOR_CURRENT_CHANNEL');
  assert.deepEqual(terminalOld.channels, []);
  assert.equal(supersededOld.status, 'WAIT_FOR_CURRENT_CHANNEL');
  assert.deepEqual(supersededOld.channels, []);
});

test('request decisions reject a current-input start before prior-input terminal evidence', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({
    head: HASHES.head2,
    tree: HASHES.tree2,
    diffSha256: HASHES.diff2,
    bodySha256: HASHES.body2,
  });
  const oldCopilot = requestFor(input1, 'copilot', {
    confirmed: true,
    terminal: true,
  });
  const oldCodex = requestFor(input1, 'codex', {
    confirmed: true,
    terminal: true,
    requestedAt: '2026-09-04T10:01:00Z',
    terminalResultRef: {
      kind: 'submitted-review',
      id: 'LATE_OLD_CODEX',
      observedAt: '2026-09-04T10:04:00Z',
    },
  });
  const newCopilot = requestFor(input2, 'copilot', {
    confirmed: true,
    requestedAt: '2026-09-04T10:03:00Z',
  });

  assert.throws(
    () => decideReviewRequest({
      previousReviewInput: input1,
      currentReviewInput: input2,
      mutationClass: 'CODE_OR_DIFF',
      existingRequests: [oldCopilot, oldCodex, newCopilot],
    }),
    /earlier-input request to be terminal first/u,
  );
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
  assert.deepEqual(terminal.channels, ['copilot']);
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
  const request = requestFor(input, 'codex');
  const reviewRequests = [
    requestFor(input, 'copilot', { confirmed: true }),
    request,
  ];
  const results = collectCodexResults({
    reviewInput: input,
    request,
    reviewRequests,
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

test('submitted reviews require all supplied commit identities to agree', () => {
  const input = reviewInput();
  const copilotRequest = requestFor(input, 'copilot', { confirmed: true });
  const codexRequest = requestFor(input, 'codex', {
    requestedAt: '2026-09-04T10:01:00Z',
  });
  const commonReview = {
    user: { login: 'chatgpt-codex-connector[bot]' },
    commit_id: HASHES.head1,
    submitted_at: '2026-09-04T10:02:00Z',
  };
  const codexResults = collectCodexResults({
    reviewInput: input,
    request: codexRequest,
    reviewRequests: [copilotRequest, codexRequest],
    submittedReviews: [
      {
        ...commonReview,
        id: 'CONFLICTING_CODEX_COMMIT',
        commit: { oid: HASHES.head2 },
      },
      {
        ...commonReview,
        id: 'AGREEING_CODEX_COMMIT',
        commit: { oid: HASHES.head1 },
        commitOid: HASHES.head1,
      },
    ],
    conversationComments: [],
  });
  assert.deepEqual(
    codexResults.submittedReviews.map((review) => review.id),
    ['AGREEING_CODEX_COMMIT'],
  );

  const copilotEvidence = collectCopilotRequestEvidence({
    baselineRequestEventIds: [],
    baselineReviewNodeIds: [],
    baselineReviewRunIds: [],
    responseReviewers: [],
    requestEvents: [],
    requestedReviewers: [],
    submittedReviews: [{
      id: 'CONFLICTING_COPILOT_COMMIT',
      user: {
        login: 'copilot-pull-request-reviewer[bot]',
        type: 'Bot',
        id: 175728472,
        node_id: 'BOT_kgDOCnlnWA',
      },
      commit_id: HASHES.head1,
      commit: { oid: HASHES.head2 },
      submitted_at: '2026-09-04T10:02:00Z',
    }],
    reviewRuns: [],
    expectedHead: HASHES.head1,
    requestedAt: '2026-09-04T10:00:00Z',
    readbackCompleteness: {
      requestEvents: true,
      requestedReviewers: true,
      submittedReviews: true,
      reviewRuns: true,
    },
  });
  assert.equal(copilotEvidence.submittedReviewMatched, false);
});

test('conversation results require all supplied head identities to agree', () => {
  const input = reviewInput();
  const copilotRequest = requestFor(input, 'copilot', { confirmed: true });
  const codexRequest = requestFor(input, 'codex', {
    requestedAt: '2026-09-04T10:01:00Z',
  });
  const commonComment = {
    user: { login: 'chatgpt-codex-connector[bot]' },
    created_at: '2026-09-04T10:02:00Z',
    body: 'Review completed.',
  };
  const results = collectCodexResults({
    reviewInput: input,
    request: codexRequest,
    reviewRequests: [copilotRequest, codexRequest],
    submittedReviews: [],
    conversationComments: [
      {
        ...commonComment,
        id: 'CONFLICTING_CODEX_HEAD',
        head: HASHES.head1,
        headRefOid: HASHES.head2,
      },
      {
        ...commonComment,
        id: 'AGREEING_CODEX_HEAD',
        head: HASHES.head1,
        headRefOid: HASHES.head1,
      },
      {
        ...commonComment,
        id: 'SINGLE_CODEX_HEAD',
        headRefOid: HASHES.head1,
      },
    ],
  });

  assert.deepEqual(
    results.conversationComments.map((comment) => comment.id),
    ['AGREEING_CODEX_HEAD', 'SINGLE_CODEX_HEAD'],
  );
});

test('native completed Codex summaries become typed terminal conversation results', () => {
  const input = reviewInput();
  const copilotRequest = requestFor(input, 'copilot', { confirmed: true });
  const codexRequest = requestFor(input, 'codex', {
    confirmed: true,
    terminal: true,
    requestedAt: '2026-09-04T10:01:00Z',
    terminalResultRef: {
      kind: 'conversation-comment',
      id: 'COMMENT_NATIVE',
      observedAt: '2026-09-04T10:02:00Z',
    },
  });
  const requestHistory = [copilotRequest, codexRequest];
  const nativeSummary = {
    node_id: 'COMMENT_NATIVE',
    user: { login: 'chatgpt-codex-connector[bot]' },
    created_at: '2026-09-04T09:00:00Z',
    updated_at: '2026-09-04T10:02:00Z',
    body: '| 📝 **Code Review** | ✅ **Completed** <relative-time>now</relative-time> | `aaaaaaa` | Manual request |',
  };
  const collected = collectCodexResults({
    reviewInput: input,
    request: codexRequest,
    reviewRequests: requestHistory,
    submittedReviews: [],
    conversationComments: nativeSummary,
  });
  assert.equal(collected.conversationComments[0].status, 'completed');
  assert.equal(collected.conversationComments[0].commitPrefix, 'aaaaaaa');

  const uppercase = collectCodexResults({
    reviewInput: input,
    request: codexRequest,
    reviewRequests: requestHistory,
    submittedReviews: [],
    conversationComments: {
      ...nativeSummary,
      node_id: 'COMMENT_UPPERCASE',
      body: '| 📝 **Code Review** | ✅ **Completed** <relative-time>now</relative-time> | `AAAAAAA` | Manual request |',
    },
  });
  assert.equal(uppercase.conversationComments[0].status, 'completed');
  assert.equal(uppercase.conversationComments[0].commitPrefix, 'aaaaaaa');

  const preclassifiedUppercase = collectCodexResults({
    reviewInput: input,
    request: codexRequest,
    reviewRequests: requestHistory,
    submittedReviews: [],
    conversationComments: {
      ...nativeSummary,
      node_id: 'COMMENT_PRECLASSIFIED_UPPERCASE',
      status: 'completed',
      commitPrefix: 'AAAAAAA',
    },
  });
  assert.equal(preclassifiedUppercase.conversationComments[0].status, 'completed');
  assert.equal(preclassifiedUppercase.conversationComments[0].commitPrefix, 'aaaaaaa');

  const preclassifiedWrongHead = collectCodexResults({
    reviewInput: input,
    request: codexRequest,
    reviewRequests: requestHistory,
    submittedReviews: [],
    conversationComments: {
      ...nativeSummary,
      node_id: 'COMMENT_PRECLASSIFIED_WRONG_HEAD',
      status: 'completed',
      commitPrefix: 'BBBBBBB',
    },
  });
  assert.equal(preclassifiedWrongHead.conversationComments.length, 0);

  const persisted = compactState(input, {
    reviewRequests: requestHistory,
    codexResults: collected,
  });
  assert.deepEqual(parseCompactStateJson(JSON.stringify(persisted)), persisted);

  for (const body of [
    '| 📝 **Code Review** | 🔄 **Running** | `aaaaaaa` | Manual request |',
    '| 📝 **Code Review** | ✅ **Completed** | `bbbbbbb` | Manual request |',
  ]) {
    const nonterminal = collectCodexResults({
      reviewInput: input,
      request: codexRequest,
      reviewRequests: requestHistory,
      submittedReviews: [],
      conversationComments: { ...nativeSummary, body },
    });
    assert.equal(nonterminal.conversationComments[0].status, undefined);
  }
});

test('Codex requests require durable Copilot readiness ordering', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const input = reviewInput();
  const codexRequest = requestFor(input, 'codex', {
    requestedAt: '2026-09-04T10:01:00Z',
  });
  const confirmed = requestFor(input, 'copilot', {
    confirmed: true,
    readyAt: '2026-09-04T10:00:30Z',
  });
  const decide = (copilotRequest) => decideReviewRequest({
    previousReviewInput: input,
    currentReviewInput: input,
    mutationClass: 'RESULT_OR_STATE',
    existingRequests: [copilotRequest, codexRequest],
  });

  assert.equal(decide(confirmed).status, 'NO_REQUEST');
  const missing = structuredClone(confirmed);
  delete missing.readyAt;
  assert.throws(() => decide(missing), /review request is malformed/u);
  assert.throws(
    () => decide({ ...confirmed, readyAt: '2026-09-04T10:01:01Z' }),
    /must not precede Copilot readiness/u,
  );
  assert.throws(
    () => decide({ ...confirmed, readyAt: '2026-09-04T09:59:59Z' }),
    /review request is malformed/u,
  );
  const terminal = requestFor(input, 'copilot', {
    terminal: true,
    terminalDisposition: nonfunctionalDisposition(),
  });
  assert.equal(decide(terminal).status, 'NO_REQUEST');
  assert.throws(
    () => decide({ ...terminal, readyAt: '2026-09-04T10:00:30Z' }),
    /review request is malformed/u,
  );
  assert.throws(
    () => assertSchemaValid(
      { ...codexRequest, readyAt: '2026-09-04T10:00:30Z' },
      schema.$defs.reviewRequest,
      schema,
    ),
    /does not match any allowed schema/u,
  );
});

test('a Copilot request without readyAt is malformed and cannot release Codex', () => {
  const input = reviewInput();
  const copilotRequest = requestFor(input, 'copilot', {
    confirmed: true,
    terminal: false,
  });
  delete copilotRequest.readyAt;
  assert.throws(
    () => decideReviewRequest({
      previousReviewInput: input,
      currentReviewInput: input,
      mutationClass: 'RESULT_OR_STATE',
      existingRequests: [copilotRequest],
    }),
    /review request is malformed/u,
  );

  copilotRequest.readyAt = copilotRequest.requestedAt;
  const released = decideReviewRequest({
    previousReviewInput: input,
    currentReviewInput: input,
    mutationClass: 'RESULT_OR_STATE',
    existingRequests: [copilotRequest],
  });
  assert.equal(released.status, 'REQUEST_REQUIRED');
  assert.deepEqual(released.channels, ['codex']);

  const terminalRequest = requestFor(input, 'copilot', {
    terminal: true,
    terminalDisposition: nonfunctionalDisposition(),
  });
  delete terminalRequest.readyAt;
  assert.throws(
    () => decideReviewRequest({
      previousReviewInput: input,
      currentReviewInput: input,
      mutationClass: 'RESULT_OR_STATE',
      existingRequests: [terminalRequest],
    }),
    /review request is malformed/u,
  );

  terminalRequest.readyAt = terminalRequest.terminalDisposition.recordedAt;
  const terminalReleased = decideReviewRequest({
    previousReviewInput: input,
    currentReviewInput: input,
    mutationClass: 'RESULT_OR_STATE',
    existingRequests: [terminalRequest],
  });
  assert.equal(terminalReleased.status, 'REQUEST_REQUIRED');
  assert.deepEqual(terminalReleased.channels, ['codex']);
});

test('persisted and collection request histories enforce global pair serialization', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({
    head: HASHES.head2,
    tree: HASHES.tree2,
    diffSha256: HASHES.diff2,
    bodySha256: HASHES.body2,
  });
  const oldCopilot = requestFor(input1, 'copilot', {
    confirmed: true,
    terminal: true,
  });
  const oldCodex = requestFor(input1, 'codex', {
    confirmed: true,
    terminal: false,
    requestedAt: '2026-09-04T10:01:00Z',
  });
  const newCopilot = requestFor(input2, 'copilot', {
    confirmed: true,
    requestedAt: '2026-09-04T10:02:00Z',
  });
  const newCodex = requestFor(input2, 'codex', {
    requestedAt: '2026-09-04T10:03:00Z',
  });
  const bypass = compactState(input2, {
    mutationClass: 'CODE_OR_DIFF',
    reviewRequests: [oldCopilot, oldCodex, newCopilot, newCodex],
  });
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(bypass)),
    /earlier-input request to be terminal first/u,
  );
  assert.deepEqual(collectCodexResults({
    reviewInput: input2,
    request: newCodex,
    reviewRequests: bypass.current_task.review.reviewRequests,
    submittedReviews: [],
    conversationComments: [{
      id: 'MISATTRIBUTED',
      user: { login: 'chatgpt-codex-connector[bot]' },
      updated_at: '2026-09-04T10:04:00Z',
      body: '| **Code Review** | **Completed** | `bbbbbbb` | Manual request |',
    }],
  }), { submittedReviews: [], conversationComments: [] });

  const reversed = compactState(input2, {
    mutationClass: 'CODE_OR_DIFF',
    reviewRequests: [
      requestFor(input1, 'copilot', {
        confirmed: true,
        terminal: true,
        requestedAt: '2026-09-04T10:02:00Z',
      }),
      requestFor(input2, 'copilot', { requestedAt: '2026-09-04T10:01:00Z' }),
    ],
  });
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(reversed)),
    /not time ordered/u,
  );
});

test('whole-second Codex evidence matches a fractional request boundary', () => {
  const input = reviewInput();
  const request = requestFor(input, 'codex', {
    requestedAt: '2026-09-04T10:00:00.094Z',
  });
  const results = collectCodexResults({
    reviewInput: input,
    request,
    reviewRequests: [
      requestFor(input, 'copilot', {
        confirmed: true,
        requestedAt: '2026-09-04T10:00:00Z',
      }),
      request,
    ],
    submittedReviews: [
      {
        id: 'REVIEW_SAME_SECOND',
        user: { login: 'chatgpt-codex-connector[bot]' },
        commit_id: HASHES.head1,
        submitted_at: '2026-09-04T10:00:00Z',
      },
      {
        id: 'REVIEW_EARLY',
        user: { login: 'chatgpt-codex-connector[bot]' },
        commit_id: HASHES.head1,
        submitted_at: '2026-09-04T09:59:59.999Z',
      },
    ],
    conversationComments: [
      {
        id: 'COMMENT_SAME_SECOND',
        user: { login: 'chatgpt-codex-connector[bot]' },
        created_at: '2026-09-04T10:00:00Z',
        body: 'Review complete with no findings.',
      },
      {
        id: 'COMMENT_EARLY',
        user: { login: 'chatgpt-codex-connector[bot]' },
        created_at: '2026-09-04T09:59:59.999Z',
        body: 'Earlier result.',
      },
    ],
  });

  assert.deepEqual(
    results.submittedReviews.map((review) => review.id),
    ['REVIEW_SAME_SECOND'],
  );
  assert.deepEqual(
    results.conversationComments.map((comment) => comment.id),
    ['COMMENT_SAME_SECOND'],
  );
});

test('scenario 7: empty, singleton, and multiple collections normalize', () => {
  assert.deepEqual(normalizeCollection(null), []);
  assert.deepEqual(normalizeCollection({ id: 1 }), [{ id: 1 }]);
  assert.deepEqual(normalizeCollection([{ id: 1 }, { id: 2 }]), [{ id: 1 }, { id: 2 }]);
  assert.deepEqual(normalizeCollection({ nodes: [] }), []);
  assert.deepEqual(normalizeCollection({ nodes: [{ id: 1 }] }), [{ id: 1 }]);
  assert.deepEqual(normalizeCollection({ edges: [{ node: { id: 1 } }, { node: { id: 2 } }] }), [{ id: 1 }, { id: 2 }]);
  assert.deepEqual(normalizeCollection({ total_count: 0, check_runs: [] }), []);
  assert.deepEqual(normalizeCollection({ total_count: 1, check_runs: [{ id: 1 }] }), [{ id: 1 }]);
  assert.deepEqual(
    normalizeCollection({ total_count: 2, check_runs: [{ id: 1 }, { id: 2 }] }),
    [{ id: 1 }, { id: 2 }],
  );
  assert.deepEqual(normalizeCollection({ total_count: 0, workflow_runs: [] }), []);
  assert.deepEqual(normalizeCollection({ total_count: 1, workflow_runs: [{ id: 1 }] }), [{ id: 1 }]);
  assert.deepEqual(
    normalizeCollection({ total_count: 2, workflow_runs: [{ id: 1 }, { id: 2 }] }),
    [{ id: 1 }, { id: 2 }],
  );
});

test('Copilot REST requests use the exact documented reviewer identity', () => {
  const spec = createReviewRequestSpec('copilot');
  assert.deepEqual(spec, {
    channel: 'copilot',
    method: 'POST',
    transport: 'rest-review-request',
    reviewerLogin: 'copilot-pull-request-reviewer[bot]',
    payload: {
      reviewers: ['copilot-pull-request-reviewer[bot]'],
    },
  });
  assert.ok(Object.isFrozen(spec));
  assert.ok(Object.isFrozen(spec.payload));
  assert.ok(Object.isFrozen(spec.payload.reviewers));
  assert.throws(() => createReviewRequestSpec('Copilot'), /copilot or codex/u);
  assert.throws(() => createReviewRequestSpec('copilot-pull-request-reviewer[bot]'), /copilot or codex/u);
});

test('Copilot request evidence normalizes cardinality and verifies GitHub bot aliases', () => {
  const common = {
    baselineRequestEventIds: ['old-event'],
    baselineReviewNodeIds: ['old-review'],
    baselineReviewRunIds: ['old-run'],
    expectedHead: HASHES.head1,
    requestedAt: '2026-09-04T10:00:00Z',
    readbackCompleteness: {
      requestEvents: true,
      requestedReviewers: true,
      submittedReviews: true,
      reviewRuns: true,
    },
  };
  const empty = collectCopilotRequestEvidence({
    ...common,
    responseReviewers: { requested_reviewers: [] },
    requestEvents: [],
    requestedReviewers: { users: [] },
    submittedReviews: { nodes: [] },
    reviewRuns: [],
  });
  assert.deepEqual(empty, {
    responseReviewerMatched: false,
    requestEventMatched: false,
    requestedReviewerMatched: false,
    submittedReviewMatched: false,
    reviewRunMatched: false,
    triggerCommentMatched: false,
    readbackComplete: true,
  });

  const populated = collectCopilotRequestEvidence({
    ...common,
    responseReviewers: { requested_reviewers: [{ login: 'Copilot' }] },
    requestEvents: [
      {
        id: 'old-event',
        event: 'review_requested',
        created_at: '2026-09-04T10:01:00Z',
        requested_reviewer: { login: 'Copilot' },
      },
      {
        id: 'new-event',
        event: 'review_requested',
        created_at: '2026-09-04T10:01:00Z',
        requested_reviewer: {
          login: 'Copilot',
          type: 'Bot',
          id: 175728472,
          node_id: 'BOT_kgDOCnlnWA',
        },
      },
    ],
    requestedReviewers: { users: [{ login: 'copilot-pull-request-reviewer[bot]' }] },
    submittedReviews: {
      nodes: [
        {
          nodeId: 'new-review',
          author: { login: 'copilot-pull-request-reviewer' },
          commitOid: HASHES.head1,
          submittedAt: '2026-09-04T10:01:00Z',
        },
      ],
    },
    reviewRuns: {
      total_count: 1,
      workflow_runs: [{
        id: 'new-run',
        actor: {
          login: 'Copilot',
          type: 'Bot',
          id: 175728472,
          node_id: 'BOT_kgDOCnlnWA',
        },
        head_sha: HASHES.head1,
        created_at: '2026-09-04T10:01:00Z',
      }],
    },
  });
  assert.deepEqual(populated, {
    responseReviewerMatched: false,
    requestEventMatched: true,
    requestedReviewerMatched: true,
    submittedReviewMatched: true,
    reviewRunMatched: true,
    triggerCommentMatched: false,
    readbackComplete: true,
  });
  assert.equal(
    collectCopilotRequestEvidence({
      ...common,
      responseReviewers: [],
      requestEvents: [],
      requestedReviewers: [],
      submittedReviews: [],
      reviewRuns: {
        total_count: 1,
        check_runs: [{
          id: 'new-check-run',
          name: 'copilot-pull-request-reviewer',
          actor: {
            login: 'Copilot',
            type: 'Bot',
            id: 175728472,
            node_id: 'BOT_kgDOCnlnWA',
          },
          app: {
            id: 175728472,
            node_id: 'BOT_kgDOCnlnWA',
            slug: 'copilot-pull-request-reviewer',
            name: 'Copilot',
            owner: { login: 'github-copilot' },
          },
          head_sha: HASHES.head1,
          created_at: '2026-09-04T10:01:00Z',
        }],
      },
    }).reviewRunMatched,
    false,
  );
  assert.equal(
    collectCopilotRequestEvidence({
      ...common,
      responseReviewers: {
        requested_reviewers: [{ login: 'copilot-pull-request-reviewer[bot]' }],
      },
      requestEvents: [],
      requestedReviewers: [],
      submittedReviews: [],
      reviewRuns: [],
    }).responseReviewerMatched,
    true,
  );
  assert.equal(
    collectCopilotRequestEvidence({
      ...common,
      responseReviewers: [],
      requestEvents: [],
      requestedReviewers: [{
        login: 'copilot-pull-request-reviewer[bot]',
        type: 'Bot',
        id: 175728472,
        node_id: 'BOT_kgDOCnlnWA',
      }],
      submittedReviews: [],
      reviewRuns: [],
    }).requestedReviewerMatched,
    true,
  );
  for (const requestedReviewer of [
    {
      login: 'copilot-pull-request-reviewer[bot]',
      type: 'Bot',
      id: 199175422,
      node_id: 'BOT_kgDOC98s_g',
    },
    {
      login: 'copilot-pull-request-reviewer[bot]',
      type: 'Bot',
      id: 175728472,
      node_id: 'BOT_kgDOC98s_g',
    },
  ]) {
    assert.equal(
      collectCopilotRequestEvidence({
        ...common,
        responseReviewers: [],
        requestEvents: [],
        requestedReviewers: [requestedReviewer],
        submittedReviews: [],
        reviewRuns: [],
      }).requestedReviewerMatched,
      false,
    );
  }
  assert.throws(
    () => collectCopilotRequestEvidence({
      ...common,
      baselineReviewRunIds: undefined,
      responseReviewers: [],
      requestEvents: [],
      requestedReviewers: [],
      submittedReviews: [],
      reviewRuns: [],
    }),
    /review run baseline/u,
  );
  const unverifiedAliases = collectCopilotRequestEvidence({
    ...common,
    responseReviewers: [{ login: 'Copilot' }],
    requestEvents: [{
      id: 'unverified-event',
      event: 'review_requested',
      created_at: '2026-09-04T10:01:00Z',
      requested_reviewer: { login: 'Copilot', type: 'User', id: 12 },
    }],
    requestedReviewers: [{ login: 'Copilot' }],
    submittedReviews: [{
      id: 'unverified-review',
      user: { login: 'Copilot', type: 'Bot', id: 12 },
      commit_id: HASHES.head1,
      submitted_at: '2026-09-04T10:01:00Z',
    }],
    reviewRuns: [{
      id: 'unverified-run',
      name: 'Running Copilot Code Review',
      head_sha: HASHES.head1,
      created_at: '2026-09-04T10:01:00Z',
      actor: { login: 'Copilot', type: 'Bot', id: 12 },
    }],
  });
  assert.deepEqual(unverifiedAliases, {
    responseReviewerMatched: false,
    requestEventMatched: false,
    requestedReviewerMatched: false,
    submittedReviewMatched: false,
    reviewRunMatched: false,
    triggerCommentMatched: false,
    readbackComplete: true,
  });
  assert.equal(
    collectCopilotRequestEvidence({
      ...common,
      responseReviewers: [],
      requestEvents: null,
      requestedReviewers: [],
      submittedReviews: [],
      reviewRuns: [],
    }).readbackComplete,
    false,
  );
  for (const [field, collection] of [
    ['requestEvents', {}],
    ['requestEvents', { message: 'rate limited' }],
    ['requestEvents', { data: null, errors: [{ message: 'partial response' }] }],
    ['requestEvents', { nodes: null }],
    ['requestEvents', { pageInfo: { hasNextPage: false } }],
    ['requestedReviewers', { requested_reviewers: undefined }],
    ['requestedReviewers', { users: null }],
    ['submittedReviews', { nodes: null }],
    ['submittedReviews', { edges: null }],
    ['reviewRuns', { workflow_runs: null }],
    ['reviewRuns', { check_runs: null }],
    ['reviewRuns', { total_count: 0 }],
    ['reviewRuns', 'not-a-collection'],
  ]) {
    assert.equal(
      collectCopilotRequestEvidence({
        ...common,
        responseReviewers: [],
        requestEvents: [],
        requestedReviewers: [],
        submittedReviews: [],
        reviewRuns: [],
        [field]: collection,
      }).readbackComplete,
      false,
      `${field} rejects an unavailable nested collection`,
    );
  }
});

test('Copilot request events require all supplied reviewer aliases to agree', () => {
  const copilotRest = {
    login: 'copilot-pull-request-reviewer[bot]',
    type: 'Bot',
    id: 175728472,
    node_id: 'BOT_kgDOCnlnWA',
  };
  const copilotGraphql = {
    login: 'copilot-pull-request-reviewer',
    __typename: 'Bot',
    databaseId: 175728472,
    id: 'BOT_kgDOCnlnWA',
  };
  const common = {
    responseReviewers: [],
    requestedReviewers: [],
    submittedReviews: [],
    reviewRuns: [],
    baselineRequestEventIds: [],
    baselineReviewNodeIds: [],
    baselineReviewRunIds: [],
    expectedHead: HASHES.head1,
    requestedAt: '2026-09-04T10:00:00Z',
    readbackCompleteness: {
      requestEvents: true,
      requestedReviewers: true,
      submittedReviews: true,
      reviewRuns: true,
    },
  };
  const event = (aliases) => ({
    id: 'EVENT_NEW',
    event: 'review_requested',
    created_at: '2026-09-04T10:01:00Z',
    ...aliases,
  });
  const matches = (aliases) => collectCopilotRequestEvidence({
    ...common,
    requestEvents: [event(aliases)],
  }).requestEventMatched;

  assert.equal(matches({ requested_reviewer: copilotRest }), true);
  assert.equal(matches({ requestedReviewer: copilotGraphql }), true);
  assert.equal(matches({
    requested_reviewer: copilotRest,
    requestedReviewer: copilotGraphql,
  }), true);
  assert.equal(matches({
    requested_reviewer: copilotRest,
    requestedReviewer: {
      login: 'dependabot[bot]',
      type: 'Bot',
      id: 49699333,
      node_id: 'MDM6Qm90NDk2OTkzMzM=',
    },
  }), false);
  assert.equal(matches({
    requested_reviewer: { ...copilotRest, id: 49699333 },
    requestedReviewer: copilotGraphql,
  }), false);
});

test('Copilot workflow-run authentication preserves recursive collection provenance', () => {
  const run = {
    id: 'RUN_NEW',
    actor: {
      login: 'copilot-pull-request-reviewer[bot]',
      type: 'Bot',
      id: 175728472,
      node_id: 'BOT_kgDOCnlnWA',
    },
    head_sha: HASHES.head1,
    created_at: '2026-09-04T10:01:00Z',
  };
  const common = {
    responseReviewers: [],
    requestEvents: [],
    requestedReviewers: [],
    submittedReviews: [],
    baselineRequestEventIds: [],
    baselineReviewNodeIds: [],
    baselineReviewRunIds: [],
    expectedHead: HASHES.head1,
    requestedAt: '2026-09-04T10:00:00Z',
    readbackCompleteness: {
      requestEvents: true,
      requestedReviewers: true,
      submittedReviews: true,
      reviewRuns: true,
    },
  };
  const matchFor = (reviewRuns) => collectCopilotRequestEvidence({
    ...common,
    reviewRuns,
  }).reviewRunMatched;

  assert.equal(matchFor([run]), true);
  assert.equal(matchFor({ workflow_runs: [run] }), true);
  assert.equal(matchFor({ nodes: { workflow_runs: [run] } }), true);
  assert.equal(matchFor({ check_runs: [run] }), false);
  assert.equal(matchFor({ nodes: { check_runs: [run] } }), false);
  assert.equal(matchFor({ edges: { check_runs: [run] } }), false);
});

test('Copilot request evidence excludes a baseline match through any supplied identity', () => {
  const expectedHead = HASHES.head1;
  const copilot = {
    login: 'Copilot',
    type: 'Bot',
    id: 175728472,
    node_id: 'BOT_kgDOCnlnWA',
  };
  const common = {
    responseReviewers: [],
    requestedReviewers: [],
    expectedHead,
    requestedAt: '2026-09-04T10:00:00Z',
    readbackCompleteness: {
      requestEvents: true,
      requestedReviewers: true,
      submittedReviews: true,
      reviewRuns: true,
    },
  };
  const evidence = collectCopilotRequestEvidence({
    ...common,
    baselineRequestEventIds: ['101'],
    baselineReviewNodeIds: ['404'],
    baselineReviewRunIds: ['303'],
    requestEvents: [{
      id: 101,
      node_id: 'RRE_preferred',
      event: 'review_requested',
      created_at: '2026-09-04T10:01:00Z',
      requested_reviewer: copilot,
    }],
    submittedReviews: [{
      id: 202,
      database_id: 404,
      node_id: 'PRR_preferred',
      submitted_at: '2026-09-04T10:01:00Z',
      commit_id: expectedHead,
      user: {
        login: 'copilot-pull-request-reviewer[bot]',
        type: 'Bot',
        id: 175728472,
        node_id: 'BOT_kgDOCnlnWA',
      },
    }],
    reviewRuns: [{
      id: 303,
      node_id: 'WFR_preferred',
      created_at: '2026-09-04T10:01:00Z',
      head_sha: expectedHead,
      actor: copilot,
    }],
  });

  assert.deepEqual(evidence, {
    responseReviewerMatched: false,
    requestEventMatched: false,
    requestedReviewerMatched: false,
    submittedReviewMatched: false,
    reviewRunMatched: false,
    triggerCommentMatched: false,
    readbackComplete: true,
  });
});

test('Codex request evidence requires exact authenticated trigger-comment readback', () => {
  const common = {
    baselineConversationComments: {
      BASELINE: '2026-09-04T09:59:00Z',
    },
    expectedActorLogin: 'franklesniak',
    requestedAt: '2026-09-04T10:00:00.500Z',
    readbackComplete: true,
  };
  const positive = collectCodexRequestEvidence({
    ...common,
    triggerComments: [{
      id: 'NEW_TRIGGER',
      user: { login: 'franklesniak' },
      created_at: '2026-09-04T10:00:00Z',
      body: '@codex review',
    }],
  });
  assert.equal(positive.triggerCommentMatched, true);
  assert.equal(positive.readbackComplete, true);

  for (const triggerComments of [
    [{
      id: 'BASELINE',
      user: { login: 'franklesniak' },
      created_at: '2026-09-04T10:00:01Z',
      body: '@codex review',
    }],
    [{
      id: 'WRONG_ACTOR',
      user: { login: 'another-user' },
      created_at: '2026-09-04T10:00:01Z',
      body: '@codex review',
    }],
    [{
      id: 'WRONG_BODY',
      user: { login: 'franklesniak' },
      created_at: '2026-09-04T10:00:01Z',
      body: '@codex review ',
    }],
    [{
      id: 'EARLY',
      user: { login: 'franklesniak' },
      created_at: '2026-09-04T09:59:59Z',
      body: '@codex review',
    }],
  ]) {
    assert.equal(collectCodexRequestEvidence({
      ...common,
      triggerComments,
    }).triggerCommentMatched, false);
  }
  assert.equal(collectCodexRequestEvidence({
    ...common,
    triggerComments: null,
  }).readbackComplete, false);
  for (const triggerComments of [
    {},
    { message: 'rate limited' },
    { data: null, errors: [{ message: 'partial response' }] },
    { nodes: null },
    { edges: null },
    { total_count: 0 },
    { pageInfo: { hasNextPage: false } },
    'not-a-collection',
  ]) {
    const evidence = collectCodexRequestEvidence({
      ...common,
      triggerComments,
    });
    assert.equal(
      evidence.readbackComplete,
      false,
      'Codex rejects an unavailable nested comment collection',
    );
    assert.equal(
      reconcileReviewRequestMutation({
        response: { ok: true, executed: true },
        evidence,
        reviewInputKey: HASHES.diff1,
        channel: 'codex',
        attemptedAt: common.requestedAt,
        observedAt: '2026-09-04T10:02:01Z',
        attemptCount: 1,
        localRecordSucceeded: true,
      }).state,
      'RECONCILING',
      'incomplete negative Codex readback cannot authorize a retry',
    );
  }
});

test('whole-second Copilot evidence matches a fractional request boundary', () => {
  const common = {
    responseReviewers: { requested_reviewers: [] },
    requestedReviewers: { users: [] },
    baselineRequestEventIds: [],
    baselineReviewNodeIds: [],
    baselineReviewRunIds: [],
    expectedHead: HASHES.head1,
    requestedAt: '2026-09-04T10:00:00.094Z',
    readbackCompleteness: {
      requestEvents: true,
      requestedReviewers: true,
      submittedReviews: true,
      reviewRuns: true,
    },
  };
  const evidence = collectCopilotRequestEvidence({
    ...common,
    requestEvents: [{
      id: 'EVENT_SAME_SECOND',
      event: 'review_requested',
      created_at: '2026-09-04T10:00:00Z',
      requested_reviewer: {
        login: 'Copilot',
        type: 'Bot',
        id: 175728472,
        node_id: 'BOT_kgDOCnlnWA',
      },
    }],
    submittedReviews: [{
      id: 'REVIEW_SAME_SECOND',
      user: { login: 'copilot-pull-request-reviewer[bot]' },
      commit_id: HASHES.head1,
      submitted_at: '2026-09-04T10:00:00Z',
    }],
    reviewRuns: [{
      id: 'RUN_SAME_SECOND',
      name: 'Running Copilot Code Review',
      head_sha: HASHES.head1,
      created_at: '2026-09-04T10:00:00Z',
      actor: {
        login: 'Copilot',
        type: 'Bot',
        id: 175728472,
        node_id: 'BOT_kgDOCnlnWA',
      },
    }],
  });
  const early = collectCopilotRequestEvidence({
    ...common,
    requestEvents: [{
      id: 'EVENT_EARLY',
      event: 'review_requested',
      created_at: '2026-09-04T09:59:59.999Z',
      requested_reviewer: {
        login: 'Copilot',
        type: 'Bot',
        id: 175728472,
        node_id: 'BOT_kgDOCnlnWA',
      },
    }],
    submittedReviews: [],
    reviewRuns: [],
  });

  assert.deepEqual(evidence, {
    responseReviewerMatched: false,
    requestEventMatched: true,
    requestedReviewerMatched: false,
    submittedReviewMatched: true,
    reviewRunMatched: true,
    triggerCommentMatched: false,
    readbackComplete: true,
  });
  assert.equal(early.requestEventMatched, false);
});

test('scenario 8: Markdown backticks and Unicode survive and controls fail', () => {
  const payload = 'Use `git diff --check` for café and 雪.';
  assert.equal(validateTransport(payload), payload);
  assert.throws(() => validateTransport(`bad${String.fromCharCode(1)}value`), /control character/u);
  assert.throws(
    () => parseCompactStateJson('{"value":"bad\\u0007payload"}'),
    /control character/u,
  );
  assert.throws(
    () => parseCompactStateJson('{"bad\\u007fkey":true}'),
    /control character/u,
  );
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

test('accepted review requests reconcile, prove no effect, retry once, and exhaust', () => {
  const input = reviewInput();
  const mutationIdentity = {
    reviewInputKey: getReviewInputKey(input),
    channel: 'copilot',
  };
  const emptyEvidence = {
    responseReviewerMatched: false,
    requestEventMatched: false,
    requestedReviewerMatched: false,
    submittedReviewMatched: false,
    reviewRunMatched: false,
    triggerCommentMatched: false,
    readbackComplete: true,
  };
  const attemptedAt = '2026-09-04T10:00:00Z';
  const reconciling = reconcileReviewRequestMutation({
    ...mutationIdentity,
    response: { ok: true },
    evidence: emptyEvidence,
    attemptedAt,
    observedAt: '2026-09-04T10:01:59Z',
    attemptCount: 1,
    localRecordSucceeded: true,
  });
  const noEffect = reconcileReviewRequestMutation({
    ...mutationIdentity,
    response: { ok: true },
    evidence: emptyEvidence,
    attemptedAt,
    observedAt: '2026-09-04T10:02:00Z',
    attemptCount: 1,
    localRecordSucceeded: true,
  });
  const exhausted = reconcileReviewRequestMutation({
    ...mutationIdentity,
    response: { ok: true },
    evidence: emptyEvidence,
    attemptedAt,
    observedAt: '2026-09-04T10:02:00Z',
    attemptCount: 2,
    localRecordSucceeded: true,
  });
  const confirmed = reconcileReviewRequestMutation({
    ...mutationIdentity,
    response: { ok: true },
    evidence: { ...emptyEvidence, requestEventMatched: true },
    attemptedAt,
    observedAt: '2026-09-04T10:00:01Z',
    attemptCount: 1,
    localRecordSucceeded: false,
  });
  const contradictory = reconcileReviewRequestMutation({
    ...mutationIdentity,
    response: { ok: true, executed: false },
    evidence: { ...emptyEvidence, requestEventMatched: true },
    attemptedAt,
    observedAt: '2026-09-04T10:00:01Z',
    attemptCount: 1,
    localRecordSucceeded: true,
  });
  const codexConfirmed = reconcileReviewRequestMutation({
    ...mutationIdentity,
    channel: 'codex',
    response: { ok: true },
    evidence: { ...emptyEvidence, triggerCommentMatched: true },
    attemptedAt,
    observedAt: '2026-09-04T10:00:01Z',
    attemptCount: 1,
    localRecordSucceeded: true,
  });

  assert.equal(reconciling.state, 'RECONCILING');
  assert.equal(reconciling.retryAllowed, false);
  assert.equal(reconciling.reconciledAt, null);
  assert.equal(noEffect.state, 'NO_EFFECT');
  assert.equal(noEffect.retryAllowed, true);
  assert.equal(noEffect.attemptCount, 1);
  assert.equal(exhausted.state, 'EXHAUSTED');
  assert.equal(exhausted.retryAllowed, false);
  assert.equal(exhausted.attemptCount, 2);
  assert.equal(confirmed.state, 'CONFIRMED');
  assert.equal(confirmed.readbackMatched, true);
  assert.equal(confirmed.retryAllowed, false);
  assert.equal(confirmed.localRecordSucceeded, false);
  assert.equal(contradictory.state, 'AMBIGUOUS');
  assert.equal(contradictory.retryAllowed, false);
  assert.equal(codexConfirmed.state, 'CONFIRMED');
  assert.equal(codexConfirmed.readbackMatched, true);
  const missingTriggerField = { ...emptyEvidence };
  delete missingTriggerField.triggerCommentMatched;
  assert.throws(
    () => reconcileReviewRequestMutation({
      ...mutationIdentity,
      response: { ok: true },
      evidence: missingTriggerField,
      attemptedAt,
      observedAt: '2026-09-04T10:00:01Z',
      attemptCount: 1,
      localRecordSucceeded: true,
    }),
    /evidence is malformed/u,
  );
  assert.throws(
    () => reconcileReviewRequestMutation({
      ...mutationIdentity,
      response: { ok: true },
      evidence: emptyEvidence,
      attemptedAt,
      observedAt: '2026-09-04T10:02:00Z',
      attemptCount: 3,
      localRecordSucceeded: true,
    }),
    /one or two/u,
  );
});

test('review-request reconciliation binds durable evidence to its channel', async () => {
  const input = reviewInput();
  const reviewInputKey = getReviewInputKey(input);
  const emptyEvidence = {
    responseReviewerMatched: false,
    requestEventMatched: false,
    requestedReviewerMatched: false,
    submittedReviewMatched: false,
    reviewRunMatched: false,
    triggerCommentMatched: false,
    readbackComplete: true,
  };
  const common = {
    response: { ok: true },
    reviewInputKey,
    attemptedAt: '2026-09-04T10:00:00Z',
    observedAt: '2026-09-04T10:00:01Z',
    attemptCount: 1,
    localRecordSucceeded: true,
  };
  const copilotFields = [
    'responseReviewerMatched',
    'requestEventMatched',
    'requestedReviewerMatched',
    'submittedReviewMatched',
    'reviewRunMatched',
  ];

  for (const field of copilotFields) {
    const mutation = reconcileReviewRequestMutation({
      ...common,
      channel: 'copilot',
      evidence: { ...emptyEvidence, [field]: true },
    });
    if (['responseReviewerMatched', 'requestedReviewerMatched'].includes(field)) {
      assert.equal(mutation.state, 'RECONCILING', field);
      assert.equal(mutation.readbackMatched, false, field);
      assert.equal(mutation.retryAllowed, false, field);
    } else {
      assert.equal(mutation.state, 'CONFIRMED', field);
      assert.equal(mutation.readbackMatched, true, field);
    }
    assert.throws(
      () => reconcileReviewRequestMutation({
        ...common,
        channel: 'codex',
        evidence: { ...emptyEvidence, [field]: true },
      }),
      /does not match its channel/u,
      field,
    );
  }
  assert.equal(reconcileReviewRequestMutation({
    ...common,
    channel: 'codex',
    evidence: { ...emptyEvidence, triggerCommentMatched: true },
  }).state, 'CONFIRMED');
  assert.throws(
    () => reconcileReviewRequestMutation({
      ...common,
      channel: 'copilot',
      evidence: { ...emptyEvidence, triggerCommentMatched: true },
    }),
    /does not match its channel/u,
  );

  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const copilotRequest = requestFor(input, 'copilot', { confirmed: true });
  const crossChannelMutation = {
    state: 'CONFIRMED',
    nativeResponseAccepted: true,
    readbackMatched: true,
    retryAllowed: false,
    localRecordSucceeded: true,
    reviewInputKey,
    channel: 'copilot',
    attemptCount: 1,
    attemptedAt: '2026-09-04T10:00:00Z',
    reconciledAt: '2026-09-04T10:00:01Z',
    evidence: { ...emptyEvidence, triggerCommentMatched: true },
  };
  assert.throws(
    () => assertSchemaValid(crossChannelMutation, schema.$defs.publicMutation, schema),
  );
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(compactState(input, {
      reviewRequests: [copilotRequest],
      publicMutation: crossChannelMutation,
    }))),
    /does not match its channel/u,
  );
});

test('mutation reconciliation rejects non-Boolean local record results', () => {
  const emptyEvidence = {
    responseReviewerMatched: false,
    requestEventMatched: false,
    requestedReviewerMatched: false,
    submittedReviewMatched: false,
    reviewRunMatched: false,
    triggerCommentMatched: true,
    readbackComplete: true,
  };
  const reviewArguments = {
    response: { ok: true },
    evidence: emptyEvidence,
    reviewInputKey: 'a'.repeat(64),
    channel: 'codex',
    attemptedAt: '2026-09-04T10:00:00Z',
    observedAt: '2026-09-04T10:00:01Z',
    attemptCount: 1,
  };
  const publicArguments = {
    response: { ok: true },
    readback: { id: 1 },
    expected: { id: 1 },
  };

  assert.equal(reconcileReviewRequestMutation({
    ...reviewArguments,
    localRecordSucceeded: false,
  }).localRecordSucceeded, false);
  assert.equal(reconcilePublicMutation({
    ...publicArguments,
    localRecordSucceeded: true,
  }).localRecordSucceeded, true);
  for (const value of ['false', 0, null, {}, []]) {
    assert.throws(
      () => reconcileReviewRequestMutation({
        ...reviewArguments,
        localRecordSucceeded: value,
      }),
      /must be a Boolean/u,
      JSON.stringify(value),
    );
    assert.throws(
      () => reconcilePublicMutation({
        ...publicArguments,
        localRecordSucceeded: value,
      }),
      /must be a Boolean/u,
      JSON.stringify(value),
    );
  }
});

test('all permanent active task-template and controller surfaces use the compact contract', async () => {
  const planningRoot = new URL('./', import.meta.url);
  const plan = await readFile(new URL('action-items-2026-08-30.md', planningRoot), 'utf8');
  const parent = await readFile(new URL('coding-agent-loop.md', planningRoot), 'utf8');
  const alternate = await readFile(new URL('coding-agent-loop-without-model-routing.md', planningRoot), 'utf8');
  const generator = await readFile(new URL('prompt-action-items-update.md', planningRoot), 'utf8');
  const crossRepository = await readFile(new URL('prompt-loop-cross-repo.md', planningRoot), 'utf8');
  const performance = await readFile(
    new URL('coding-agent-loop-performance-plan-2026-08-25.md', planningRoot),
    'utf8',
  );
  const schema = JSON.parse(
    await readFile(new URL('review-loop-policy.json', planningRoot), 'utf8'),
  );
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
  const plannedReviewTaskNumbers = reviewTasks.map((task) => task.number);
  const schemaReviewTaskNumbers =
    schema.$defs.taskState.allOf[0].if.properties.number.enum;
  assert.deepEqual(REVIEW_LOOP_TASK_NUMBERS, plannedReviewTaskNumbers);
  assert.deepEqual(schemaReviewTaskNumbers, plannedReviewTaskNumbers);

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
    assert.match(task.body, /Reject (?:a |any other )?same-head request/u);
    assert.match(task.body, /submitted-review/u);
    assert.match(task.body, /PR-conversation-comment/u);
    assert.match(task.body, /local serialization fails/u);
    assert.match(task.body, /copilot-pull-request-reviewer\[bot\]/u);
    assert.match(task.body, /display name `Copilot`/u);
    assert.match(
      task.body,
      /(?:Generate the Copilot REST request|Generate the GitHub Copilot(?: review)? request) from the typed policy specification/u,
    );
    assert.match(task.body, /`RECONCILING`/u);
    assert.match(task.body, /`NO_EFFECT`/u);
    assert.match(task.body, /`EXHAUSTED`/u);
    assert.match(task.body, /at least 120 seconds/u);
    assert.match(task.body, /permit at most three (?:remote )?Codex channel attempts/iu);
    assert.match(task.body, /fresh cumulative baseline/u);
    assert.match(task.body, /at least 60 seconds/u);
    assert.match(task.body, /Never permit attempt 4/u);
    assert.match(task.body, /`EXHAUSTED_NOT_CLEAN`/u);
    assert.match(task.body, /closed (?:exact typed operator|F152) authority/u);
    assert.match(task.body, /only `completed` as clean/u);
    assert.match(
      task.body,
      /Treat current requested-reviewer membership as diagnostic only; it cannot confirm the current attempt\./u,
    );
    assert.doesNotMatch(
      task.body,
      /Confirm the request through matching authenticated request-event, current-requested-reviewer/u,
    );
    assert.doesNotMatch(
      task.body,
      /no matching request event, current requested reviewer, submitted review/u,
    );
    assert.doesNotMatch(task.body, /require matching authenticated readback/u);
    assert.match(task.body, /Do not (?:send|post)[^\n]*(?:Codex trigger|@codex review)/u);
    assert.match(
      task.body,
      /terminally proved non-functional through a persisted `terminalDisposition` whose state is `REPOSITORY_AUTHORIZED_NON_FUNCTIONAL`/u,
    );
    assert.match(
      task.body,
      /Persist Copilot `readyAt` as the authenticated release boundary before a Codex request/u,
    );
    assert.doesNotMatch(
      task.body,
      /result for the round only when it is newer than the applicable baseline and is explicitly anchored to the recorded PR head SHA/u,
    );
  }

  assert.equal(
    [...plan.matchAll(/Count a submitted-review result for the round only when every supplied commit identity matches the recorded PR head SHA, every valid timestamp alias agrees, and it is newer than every applicable supplied-identity baseline\./gu)].length,
    38,
  );
  assert.match(
    plan,
    /Persist the unique request-event, review-run, submitted-review, and conversation-comment baselines with the in-flight attempt\./u,
  );
  assert.equal(
    [...plan.matchAll(/Count a headless Codex PR-conversation result only when the authenticated author, request time, exclusion of every supplied identity from the baseline, agreement of every valid timestamp alias, explicit matching normalized head evidence for a terminal result, reviewed-input key, and serialized predecessor-pair order attribute it to this round\./gu)].length,
    38,
  );
  assert.match(plan, /closed `terminalResultRef`/u);
  assert.match(plan, /closed `terminalFailureRef`/u);
  assert.match(plan, /next same-channel and different-input request boundaries/u);
  assert.match(plan, /including a head that received zero requests/u);

  for (const task of qualityTasks) {
    assert.match(task.body, /### Post-review materiality controls/u);
    assert.match(task.body, /NON_MATERIAL_FACT/u);
    assert.match(task.body, /Raw body-byte inequality is not the classifier/u);
    assert.match(task.body, /submitted-review objects/u);
    assert.match(task.body, /Codex PR-conversation comments/u);
    assert.match(task.body, /`EXHAUSTED_NOT_CLEAN`/u);
    assert.match(task.body, /every other gate remains mandatory/iu);
  }

  for (const task of mergeTasks) {
    assert.match(task.body, /`EXHAUSTED_NOT_CLEAN`/u);
    assert.match(task.body, /every other gate remains mandatory/iu);
  }

  const unsafeResultBodyLines = plan
    .split('\n')
    .filter((line) => /append.{0,80}(terminal|review) result.{0,80}(PR body|reviewer-facing body)/iu.test(line))
    .filter((line) => !/(do not|never|cannot)/iu.test(line));
  assert.deepEqual(unsafeResultBodyLines, []);
  assert.match(parent, /Compact state machine/u);
  assert.match(parent, /MATERIAL_SCOPE_BEHAVIOR_RISK/u);
  assert.match(parent, /no-safe-work human boundary -> waiting_human/u);
  assert.match(parent, /copilot-pull-request-reviewer\[bot\]/u);
  assert.match(parent, /A second proved no-effect (?:delivery )?attempt is `EXHAUSTED`/u);
  assert.match(parent, /including drift on an unchanged head/u);
  assert.match(
    parent,
    /unique request-event, review-run, submitted-review, and node-ID-to-timestamp conversation-comment baselines/u,
  );
  assert.match(
    parent,
    /confirmed or is terminally proved non-functional through a persisted `terminalDisposition`/u,
  );
  assert.match(parent, /persist its head, reviewed-input key, request time, `confirmed: true`, nonterminal state, and Copilot `readyAt` time/u);
  assert.match(parent, /whose `readyAt` time is not later than the Codex request time/u);
  assert.doesNotMatch(parent, /whose request time is not later than the Codex request time/u);
  assert.match(parent, /closed `terminalResultRef`/u);
  assert.match(parent, /closed `terminalFailureRef`/u);
  assert.match(parent, /at most three channel attempts/u);
  assert.match(parent, /Never permit channel attempt 4/u);
  assert.match(parent, /`OPERATOR_AUTHORIZED_EXHAUSTED_NOT_CLEAN`/u);
  assert.match(parent, /each count to equal the persisted request history/u);
  assert.match(parent, /Locate and obey the applicable `AGENTS\.md`/u);
  assert.match(
    parent,
    /If no `AGENTS\.md` applies, read the repository root `CLAUDE\.md` as compatibility workflow instructions; the filename does not change the executor/u,
  );
  assert.doesNotMatch(parent, /any nonterminal state -> waiting_human/u);
  assert.match(alternate, /without model routing/u);
  assert.match(alternate, /Do not create manifest/u);
  assert.match(alternate, /no-safe-work human boundary -> waiting_human/u);
  assert.match(
    alternate,
    /Use `waiting_human` only when the next concrete action needs one exact human decision or exceptional action and no independent safe in-scope work remains\./u,
  );
  assert.doesNotMatch(alternate, /any nonterminal state -> waiting_human/u);
  assert.match(alternate, /copilot-pull-request-reviewer\[bot\]/u);
  assert.match(alternate, /A second proved no-effect (?:delivery )?attempt is `EXHAUSTED`/u);
  assert.match(alternate, /including drift on an unchanged head/u);
  assert.match(
    alternate,
    /reject a numeric token if it is non-finite, its absolute value exceeds 9007199254740991, it is negative zero, or conversion to an ECMAScript `Number` changes its exact decimal value/u,
  );
  assert.match(
    alternate,
    /Store an exact value as a string if its numeric token fails any condition/u,
  );
  assert.match(
    alternate,
    /unique request-event, review-run, submitted-review, and node-ID-to-timestamp conversation-comment baselines/u,
  );
  assert.match(
    alternate,
    /confirmed or is terminally proved non-functional through a persisted `terminalDisposition`/u,
  );
  assert.match(alternate, /persist its head, reviewed-input key, request time, `confirmed: true`, nonterminal state, and Copilot `readyAt` time/u);
  assert.match(alternate, /whose `readyAt` time is not later than the Codex request time/u);
  assert.doesNotMatch(alternate, /whose request time is not later than the Codex request time/u);
  assert.match(alternate, /closed `terminalResultRef`/u);
  assert.match(alternate, /closed `terminalFailureRef`/u);
  assert.match(alternate, /at most three channel attempts/u);
  assert.match(alternate, /Never permit channel attempt 4/u);
  assert.match(alternate, /`OPERATOR_AUTHORIZED_EXHAUSTED_NOT_CLEAN`/u);
  for (const surface of [plan, parent, alternate, generator, crossRepository]) {
    assert.match(surface, /chronological discovery order/u);
    assert.match(surface, /immediate successor/u);
  }
  const nestedReadbackRule =
    'a present outer wrapper with a null or missing selected `nodes`, `edges`, ' +
    '`requested_reviewers`, `users`, `check_runs`, or `workflow_runs` collection is incomplete';
  const primitiveIdentityRule =
    'Accept each supplied native evidence identity only as a nonempty string or positive safe integer';
  const originalPairRule =
    'Validate a retained disposition against the original request segment ending at the first later different-input request';
  const successorFallbackRule =
    'When the first later different-input request uses the recorded same head or next distinct retained head, require that exact head; otherwise treat the immediate successor as unrequested and accept either eligible head';
  assert.equal(plan.split(nestedReadbackRule).length - 1, 82);
  assert.equal(plan.split(primitiveIdentityRule).length - 1, 82);
  assert.equal(plan.split(originalPairRule).length - 1, 82);
  assert.equal(plan.split(successorFallbackRule).length - 1, 82);
  for (const surface of [parent, alternate, generator, crossRepository]) {
    assert.match(surface, new RegExp(nestedReadbackRule, 'u'));
    assert.match(surface, new RegExp(primitiveIdentityRule, 'u'));
    assert.match(surface, new RegExp(originalPairRule, 'u'));
    assert.match(surface, new RegExp(successorFallbackRule, 'u'));
  }
  assert.match(alternate, /Locate and obey the applicable `AGENTS\.md`/u);
  assert.match(
    alternate,
    /If no `AGENTS\.md` applies, read the repository root `CLAUDE\.md` as compatibility workflow instructions; the filename does not change the executor/u,
  );
  assert.match(generator, /Do not split routine work/u);
  assert.match(generator, /Default to one reviewer pair/u);
  assert.match(generator, /immutable predecessor outputs/u);
  assert.match(generator, /typed `SUPERSEDED` disposition/u);
  assert.match(
    generator,
    /reject a numeric token if it is non-finite, its absolute value exceeds 9007199254740991, it is negative zero, or conversion to an ECMAScript `Number` changes its exact decimal value/u,
  );
  assert.match(
    generator,
    /Store an exact value as a string if its numeric token fails any condition/u,
  );
  assert.match(generator, /current task head to equal the review-input head/u);
  assert.match(generator, /only after every recorded request for the old input is terminal/u);
  assert.match(generator, /headless Codex PR-conversation result/u);
  assert.match(generator, /closed `terminalResultRef`/u);
  assert.match(generator, /closed `terminalFailureRef`/u);
  assert.match(generator, /at most three Codex channel attempts/u);
  assert.match(generator, /`OPERATOR_AUTHORIZED_EXHAUSTED_NOT_CLEAN`/u);
  assert.match(generator, /including a head that received zero requests/u);
  assert.match(generator, /copilot-pull-request-reviewer\[bot\]/u);
  assert.match(generator, /a second proved no-effect (?:delivery )?attempt is `EXHAUSTED`|a second proved no-effect delivery attempt is `EXHAUSTED`/iu);
  assert.match(generator, /Persist Copilot `readyAt` as the authenticated release boundary/u);
  assert.match(crossRepository, /Reject non-finite or out-of-portable-range JSON numbers/u);
  assert.match(crossRepository, /task head and review-input head differ/u);
  assert.match(crossRepository, /closed `terminalResultRef`/u);
  assert.match(crossRepository, /closed `terminalFailureRef`/u);
  assert.match(crossRepository, /at most three Codex channel attempts/u);
  assert.match(crossRepository, /`OPERATOR_AUTHORIZED_EXHAUSTED_NOT_CLEAN`/u);
  assert.match(crossRepository, /each count to equal the persisted request history/u);
  const task15 = tasks.find((task) => task.number === 15);
  assert.notEqual(task15, undefined);
  assert.match(task15.body, /Continue implementation, CI repair, review, and readiness work/u);
  assert.match(crossRepository, /one compact state record/u);
  assert.match(crossRepository, /applicable `AGENTS\.md`/u);
  assert.match(crossRepository, /root `CLAUDE\.md` as compatibility workflow instructions/u);
  assert.match(crossRepository, /Preserve both submitted-review objects/u);
  assert.match(crossRepository, /copilot-pull-request-reviewer\[bot\]/u);
  assert.match(crossRepository, /`RECONCILING` → `NO_EFFECT` → one-retry → `EXHAUSTED`/u);
  assert.match(crossRepository, /Persist Copilot `readyAt` as the authenticated release boundary/u);
  assert.equal(
    [...plan.matchAll(/Persist Copilot `readyAt` as the authenticated release boundary before a Codex request\./gu)].length,
    82,
  );
  for (const surface of [plan, parent, alternate, generator, crossRepository, performance]) {
    assert.match(surface, /three (?:downstream )?(?:Codex )?channel attempts/iu);
    assert.match(surface, /`EXHAUSTED_NOT_CLEAN`/u);
  }
  assert.match(performance, /60(?:-second| seconds)/u);
  assert.match(performance, /attempt 4/u);
  assert.match(performance, /exact typed operator authority/u);
  assert.doesNotMatch(plan, /except a reviewer proved non-functional under `AGENTS\.md`/u);
  const confirmedMutationMetadataRule =
    'At matching `CONFIRMED` review-request public-mutation ingestion, require the attempt ' +
    'count and both attempt and reconciliation timestamps, then require `readyAt` to equal ' +
    'that reconciliation time with lossless RFC 3339 comparison.';
  assert.equal(plan.split(confirmedMutationMetadataRule).length - 1, 82);
  for (const surface of [parent, alternate, generator, crossRepository]) {
    assert.match(surface, new RegExp(confirmedMutationMetadataRule, 'u'));
  }
  const baselineOverlapRule =
    'Treat a request event, submitted review, review run, or conversation comment as baseline evidence when any ' +
    'supplied node, numeric, or database identity overlaps its persisted baseline';
  assert.equal(plan.split(baselineOverlapRule).length - 1, 82);
  for (const surface of [parent, alternate, generator, crossRepository]) {
    assert.match(surface, new RegExp(baselineOverlapRule, 'u'));
    assert.match(surface, /every supplied review-run head identity must match the reviewed head/u);
    assert.match(surface, /all valid timestamp aliases for one event time must agree/u);
    assert.match(surface, /Causal RFC 3339 ordering must preserve every supplied fractional digit/u);
    assert.match(surface, /matching normalized head evidence/u);
  }
  for (const surface of [plan, parent, alternate, generator, crossRepository]) {
    assert.match(
      surface,
      /not earlier than every (?:described )?request terminal-result or terminal-disposition boundary/u,
    );
    assert.match(surface, /before (?:a|the) different-input successor request/u);
  }
  const checkRunAuthenticationRule =
    'do not authenticate Copilot from a mutable check-run name plus the generic ' +
    'GitHub Actions App identity';
  for (const surface of [plan, parent, alternate, generator, crossRepository]) {
    assert.match(surface, new RegExp(checkRunAuthenticationRule, 'u'));
    assert.match(
      surface,
      /Treat current requested-reviewer membership as diagnostic only; it cannot confirm the current attempt\./u,
    );
    assert.doesNotMatch(
      surface,
      /Require a matching authenticated request event, requested-reviewer record, submitted review, or workflow-run bot actor\./u,
    );
  }
});

test('active fixed-plan review-loop tasks require persisted review state', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const completedThrough = (taskNumber) => Array.from(
    { length: taskNumber - 1 },
    (_, index) => index + 1,
  );
  const activeReviewTask = compactState(
    reviewInput(),
    {},
    { number: 15, state: 'active' },
    { completed: completedThrough(15) },
  );
  delete activeReviewTask.current_task.review;
  assert.throws(
    () => assertSchemaValid(activeReviewTask, schema, schema),
    /review is required/u,
  );
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(activeReviewTask)),
    /must contain persisted review state/u,
  );

  const pendingReviewTask = structuredClone(activeReviewTask);
  pendingReviewTask.current_task.state = 'pending';
  assertSchemaValid(pendingReviewTask, schema, schema);
  assert.deepEqual(
    parseCompactStateJson(JSON.stringify(pendingReviewTask)),
    pendingReviewTask,
  );

  const nonReviewTask = structuredClone(activeReviewTask);
  nonReviewTask.current_task.number = 16;
  nonReviewTask.completed = completedThrough(16);
  assertSchemaValid(nonReviewTask, schema, schema);
  assert.deepEqual(parseCompactStateJson(JSON.stringify(nonReviewTask)), nonReviewTask);
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

test('copied review prompts preserve both Copilot release paths', async () => {
  const plan = await readFile(
    new URL('./action-items-2026-08-30.md', import.meta.url),
    'utf8',
  );
  assert.equal(
    [...plan.matchAll(/Only after the Copilot request is confirmed,/gu)].length,
    0,
  );
  assert.equal(
    [...plan.matchAll(/Only after the Copilot request is confirmed or is terminally proved non-functional through a persisted `terminalDisposition` whose state is `REPOSITORY_AUTHORIZED_NON_FUNCTIONAL`, whose authority and reason are nonempty, and whose recorded time is not earlier than the Copilot request,/gu)].length,
    2,
  );
});

test('review-task terminal gates and later quality loops preserve their exact release paths', async () => {
  const plan = await readFile(
    new URL('./action-items-2026-08-30.md', import.meta.url),
    'utf8',
  );
  const taskBody = (number) => {
    const start = plan.indexOf(`## Task ${number} —`);
    const end = plan.indexOf(`## Task ${number + 1} —`, start);
    assert.notEqual(start, -1);
    return plan.slice(start, end === -1 ? plan.length : end);
  };
  const task6 = taskBody(6);
  const task15 = taskBody(15);
  const task25 = taskBody(25);
  const task8 = taskBody(8);
  const task26 = taskBody(26);
  const task27 = taskBody(27);
  const task34 = taskBody(34);
  const task35 = taskBody(35);
  const task36 = taskBody(36);

  for (const task of [task6, task15, task25, task34]) {
    assert.match(
      task,
      /GitHub Copilot has either one clean review on that input or an exact persisted `REPOSITORY_AUTHORIZED_NON_FUNCTIONAL` terminal disposition/u,
    );
    assert.match(
      task,
      /either one clean Copilot review or an exact persisted `REPOSITORY_AUTHORIZED_NON_FUNCTIONAL` terminal disposition/u,
    );
    assert.equal(
      [...task.matchAll(/one Copilot result or exact persisted `REPOSITORY_AUTHORIZED_NON_FUNCTIONAL` terminal disposition/gu)].length,
      1,
    );
    assert.match(
      task,
      /Copilot has either one clean review on that input or an exact persisted `REPOSITORY_AUTHORIZED_NON_FUNCTIONAL` terminal disposition/u,
    );
  }
  for (const task of [task25, task34]) {
    assert.match(
      task,
      /Wait for a new Codex review that explicitly applies to the current head\. If Copilot is confirmed, also wait for its new current-head review; otherwise verify the exact persisted `REPOSITORY_AUTHORIZED_NON_FUNCTIONAL` terminal disposition/u,
    );
    assert.doesNotMatch(task, /Wait for a new review from each reviewer/u);
  }
  assert.match(
    task8,
    /Copilot has either a clean result or an exact persisted `REPOSITORY_AUTHORIZED_NON_FUNCTIONAL` terminal disposition/u,
  );

  assert.match(task26, /new Tasks 25 and 26 instances/u);
  assert.doesNotMatch(task26, /new Tasks 25 and 16 instances/u);
  assert.match(task27, /Tasks 25 and 26/u);
  assert.doesNotMatch(task27, /Tasks 25 and 16/u);

  assert.match(task35, /new Tasks 34 and 35 instances/u);
  assert.match(task35, /returns to Task 32 or Task 33 and then new Tasks 34 and 35 instances/u);
  assert.doesNotMatch(task35, /Tasks 34 and 25|Task 32 or 23/u);
  assert.match(task36, /Tasks 34 and 35/u);
  assert.doesNotMatch(task36, /Tasks 34 and 25/u);
});

test('schema-defined nested review-state fields classify deterministically', () => {
  const input = reviewInput();
  const original = state(input);
  const resultChanges = [
    { reviewRequests: [requestFor(input, 'codex')] },
    {
      supersededReviewInputs: {
        [HASHES.diff2]: {
          state: 'SUPERSEDED',
          head: HASHES.head1,
          successorHead: HASHES.head2,
          supersededAt: '2026-09-04T10:02:00Z',
          reason: 'Authenticated head drift.',
        },
      },
    },
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
    baselineConversationComments: {
      COMMENT_STABLE: '2026-09-04T09:59:00Z',
      COMMENT_OLD: '2026-09-04T09:59:00Z',
    },
  });
  const results = collectCodexResults({
    reviewInput: input,
    request,
    reviewRequests: [
      requestFor(input, 'copilot', { confirmed: true }),
      request,
    ],
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

test('Codex result timestamp aliases continue after an invalid candidate', () => {
  const input = reviewInput();
  const copilotRequest = requestFor(input, 'copilot', {
    confirmed: true,
    terminal: true,
  });
  const codexRequest = requestFor(input, 'codex', {
    requestedAt: '2026-09-04T10:02:00Z',
    confirmed: true,
  });
  const result = collectCodexResults({
    submittedReviews: [],
    conversationComments: [
      {
        node_id: 'COMMENT_VALID_FALLBACK',
        user: { login: 'chatgpt-codex-connector[bot]' },
        updated_at: 'not-a-timestamp',
        createdAt: '2026-09-04T10:03:00Z',
        status: 'completed',
        head: HASHES.head1,
        body: 'Completed review result.',
      },
      {
        node_id: 'COMMENT_ALL_INVALID',
        user: { login: 'chatgpt-codex-connector[bot]' },
        updated_at: 'still-not-a-timestamp',
        createdAt: 42,
        status: 'completed',
        body: 'Invalid timestamp evidence.',
      },
    ],
    reviewInput: input,
    request: codexRequest,
    reviewRequests: [copilotRequest, codexRequest],
  });

  assert.deepEqual(
    result.conversationComments.map((comment) => comment.node_id),
    ['COMMENT_VALID_FALLBACK'],
  );
});

test('terminal Codex conversations require matching head evidence', () => {
  const input = reviewInput();
  const copilotRequest = requestFor(input, 'copilot', {
    confirmed: true,
    terminal: true,
  });
  const codexRequest = requestFor(input, 'codex', {
    requestedAt: '2026-09-04T10:02:00Z',
    confirmed: true,
    terminal: true,
    terminalResultRef: {
      kind: 'conversation-comment',
      id: 'COMMENT_MISSING_HEAD',
      observedAt: '2026-09-04T10:03:00Z',
    },
  });
  const persisted = compactState(input, {
    reviewRequests: [copilotRequest, codexRequest],
    codexResults: {
      submittedReviews: [],
      conversationComments: [{
        nodeId: 'COMMENT_MISSING_HEAD',
        actor: 'chatgpt-codex-connector[bot]',
        updatedAt: '2026-09-04T10:03:00Z',
        status: 'completed',
      }],
    },
  });

  assert.deepEqual(collectCodexResults({
    submittedReviews: [],
    conversationComments: persisted.current_task.review.codexResults.conversationComments,
    reviewInput: input,
    request: codexRequest,
    reviewRequests: [copilotRequest, codexRequest],
  }), { submittedReviews: [], conversationComments: [] });
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(persisted)),
    /one attributable terminal result/u,
  );
});

test('successor histories require an earlier incomplete-pair supersession', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({
    head: HASHES.head2,
    tree: HASHES.tree2,
    diffSha256: HASHES.diff2,
    bodySha256: HASHES.body2,
  });
  const prior = requestFor(input1, 'copilot', { confirmed: true, terminal: true });
  const successor = requestFor(input2, 'copilot', {
    requestedAt: '2026-09-04T10:02:00Z',
  });
  const missing = compactState(input2, { reviewRequests: [prior, successor] }, {
    head: input2.head,
  });

  assert.throws(
    () => parseCompactStateJson(JSON.stringify(missing)),
    /requires a superseded disposition/u,
  );
  missing.current_task.review.supersededReviewInputs = supersessionFor(input1, input2, {
    supersededAt: '2026-09-04T10:01:00Z',
  });
  assert.deepEqual(parseCompactStateJson(JSON.stringify(missing)), missing);
});

test('conversation baselines compare every supplied native identity', () => {
  const input = reviewInput();
  const request = requestFor(input, 'codex', {
    confirmed: true,
    requestedAt: '2026-09-04T09:59:00Z',
    baselineConversationComments: {
      '12345': '2026-09-04T10:00:00Z',
    },
  });
  const aliasObject = {
    id: 12345,
    node_id: 'COMMENT_NODE_ALIAS',
    user: { login: 'chatgpt-codex-connector[bot]' },
    head: HASHES.head1,
    status: 'completed',
    updated_at: '2026-09-04T10:00:00Z',
    body: 'Completed result.',
  };
  const trigger = collectCodexRequestEvidence({
    triggerComments: [{
      ...aliasObject,
      user: { login: 'franklesniak' },
      body: '@codex review',
      created_at: '2026-09-04T10:02:00Z',
    }],
    baselineConversationComments: request.baselineConversationComments,
    expectedActorLogin: 'franklesniak',
    requestedAt: request.requestedAt,
    readbackComplete: true,
  });
  const results = collectCodexResults({
    submittedReviews: [],
    conversationComments: [aliasObject],
    reviewInput: input,
    request,
    reviewRequests: [
      requestFor(input, 'copilot', { confirmed: true }),
      request,
    ],
  });

  assert.equal(trigger.triggerCommentMatched, false);
  assert.deepEqual(results, { submittedReviews: [], conversationComments: [] });
});

test('Copilot run evidence rejects conflicting head aliases', () => {
  const evidence = collectCopilotRequestEvidence({
    responseReviewers: [],
    requestEvents: [],
    requestedReviewers: [],
    submittedReviews: [],
    reviewRuns: [{
      node_id: 'RUN_CONFLICTING_HEADS',
      created_at: '2026-09-04T10:01:00Z',
      head_sha: HASHES.head1,
      headSha: HASHES.head2,
      headCommit: { oid: HASHES.head2 },
      app: {
        login: 'copilot-pull-request-reviewer[bot]',
        type: 'Bot',
        id: 175728472,
        node_id: 'BOT_kgDOCnlnWA',
      },
    }],
    baselineRequestEventIds: [],
    baselineReviewNodeIds: [],
    baselineReviewRunIds: [],
    expectedHead: HASHES.head1,
    requestedAt: '2026-09-04T10:00:00Z',
    readbackCompleteness: {
      requestEvents: true,
      requestedReviewers: true,
      submittedReviews: true,
      reviewRuns: true,
    },
  });

  assert.equal(evidence.reviewRunMatched, false);
});

test('review decisions preserve sub-millisecond timestamp ordering', () => {
  const input = reviewInput();
  const copilotRequest = requestFor(input, 'copilot', {
    requestedAt: '2026-09-04T10:00:00.0009Z',
    readyAt: '2026-09-04T10:00:00.0001Z',
    confirmed: true,
    terminal: true,
  });

  assert.throws(
    () => decideReviewRequest({
      previousReviewInput: null,
      currentReviewInput: input,
      mutationClass: null,
      existingRequests: [copilotRequest],
    }),
    /review request is malformed/u,
  );

  const orderedCopilotRequest = requestFor(input, 'copilot', {
    requestedAt: '2026-09-04T10:00:00.0001Z',
    readyAt: '2026-09-04T10:00:00.0009Z',
    confirmed: true,
    terminal: true,
  });
  assert.doesNotThrow(() => decideReviewRequest({
    previousReviewInput: null,
    currentReviewInput: input,
    mutationClass: null,
    existingRequests: [orderedCopilotRequest],
  }));
});

test('review evidence rejects conflicting valid timestamp aliases', () => {
  const input = reviewInput();
  const copilotRequest = requestFor(input, 'copilot', { confirmed: true });
  const codexRequest = requestFor(input, 'codex', {
    requestedAt: '2026-09-04T10:01:00Z',
    confirmed: true,
  });
  const conflicting = {
    node_id: 'REVIEW_CONFLICTING_TIMES',
    user: { login: 'chatgpt-codex-connector[bot]' },
    commit_id: HASHES.head1,
    submitted_at: '2026-09-04T10:02:00Z',
    submittedAt: '2026-09-04T09:59:00Z',
  };

  assert.deepEqual(collectCodexResults({
    submittedReviews: [conflicting],
    conversationComments: [],
    reviewInput: input,
    request: codexRequest,
    reviewRequests: [copilotRequest, codexRequest],
  }), { submittedReviews: [], conversationComments: [] });
});

test('supersession time follows every old request terminal boundary', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({
    head: HASHES.head2,
    tree: HASHES.tree2,
    diffSha256: HASHES.diff2,
    bodySha256: HASHES.body2,
  });
  const prior = requestFor(input1, 'copilot', { confirmed: true, terminal: true });
  const successor = requestFor(input2, 'copilot', {
    requestedAt: '2026-09-04T10:02:00Z',
  });
  const persisted = compactState(input2, {
    reviewRequests: [prior, successor],
    supersededReviewInputs: supersessionFor(input1, input2, {
      supersededAt: '2026-09-04T10:00:30Z',
    }),
  }, { head: input2.head });

  assert.throws(
    () => parseCompactStateJson(JSON.stringify(persisted)),
    /terminal incomplete prior-input pair/u,
  );
  persisted.current_task.review.supersededReviewInputs[
    getReviewInputKey(input1)
  ].supersededAt = prior.terminalResultRef.observedAt;
  assert.deepEqual(parseCompactStateJson(JSON.stringify(persisted)), persisted);
});

test('Codex results exclude a baseline match through any supplied review identity', () => {
  const input = reviewInput();
  const request = requestFor(input, 'codex', {
    baselineReviewNodeIds: ['202'],
  });
  const results = collectCodexResults({
    reviewInput: input,
    request,
    reviewRequests: [
      requestFor(input, 'copilot', { confirmed: true }),
      request,
    ],
    submittedReviews: [{
      database_id: 202,
      node_id: 'PRR_preferred',
      user: { login: 'chatgpt-codex-connector[bot]' },
      commit_id: HASHES.head1,
      submitted_at: '2026-09-04T10:02:00Z',
    }],
    conversationComments: [],
  });

  assert.deepEqual(results, { submittedReviews: [], conversationComments: [] });
});

test('result identities must be nonempty strings or positive safe integers', () => {
  const input = reviewInput();
  const request = requestFor(input, 'codex');
  const reviewRequests = [
    requestFor(input, 'copilot', { confirmed: true }),
    request,
  ];
  const result = (identities) => collectCodexResults({
    reviewInput: input,
    request,
    reviewRequests,
    submittedReviews: [{
      ...identities,
      user: { login: 'chatgpt-codex-connector[bot]' },
      commit_id: HASHES.head1,
      submitted_at: '2026-09-04T10:02:00Z',
    }],
    conversationComments: [],
  });

  for (const identities of [
    { id: {} },
    { id: true },
    { id: Number.MAX_SAFE_INTEGER + 1 },
    { id: 0 },
    { id: '' },
    { node_id: 'VALID_NODE', id: {} },
  ]) {
    assert.deepEqual(
      result(identities),
      { submittedReviews: [], conversationComments: [] },
      JSON.stringify(identities),
    );
  }
  assert.deepEqual(
    result({ id: 202 }).submittedReviews.map((review) => review.id),
    [202],
  );
});

test('Codex request correlation rejects a different reviewed input', () => {
  const input = reviewInput();
  const changedInput = reviewInput({ risk: 'R2 sensitive planning change.' });
  const request = requestFor(input, 'codex');
  const results = collectCodexResults({
    reviewInput: changedInput,
    request,
    reviewRequests: [
      requestFor(input, 'copilot', { confirmed: true }),
      request,
    ],
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
    reviewRequests: [
      requestFor(input, 'copilot', { confirmed: true }),
      request,
    ],
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

test('compact-state JSON ingestion rejects duplicate baseline member identities', () => {
  const duplicateLiteral = '{"baselineConversationComments":{"COMMENT_OLD":"2026-09-04T09:58:00Z","COMMENT_OLD":"2026-09-04T09:59:00Z"}}';
  const duplicateEscaped = '{"baselineConversationComments":{"COMMENT_OLD":"2026-09-04T09:58:00Z","\\u0043OMMENT_OLD":"2026-09-04T09:59:00Z"}}';
  const unique = '{"baselineConversationComments":{"COMMENT_OLD":"2026-09-04T09:59:00Z"}}';

  assert.throws(() => parseCompactStateJson(duplicateLiteral), /duplicate member "COMMENT_OLD"/u);
  assert.throws(() => parseCompactStateJson(duplicateEscaped), /duplicate member "COMMENT_OLD"/u);
  assert.throws(
    () => parseCompactStateJson(unique),
    /must contain exactly the required root fields/u,
  );
});

test('compact-state JSON ingestion rejects unrelated or incomplete root values', () => {
  const valid = compactState(reviewInput());
  const requiredRootFields = [
    'schema',
    'plan',
    'current_task',
    'predecessor_outputs',
    'completed',
    'updated_utc',
  ];

  for (const unrelated of [null, [], {}, { safe: 1 }]) {
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(unrelated)),
      /must contain exactly the required root fields/u,
    );
  }
  for (const field of requiredRootFields) {
    const incomplete = structuredClone(valid);
    delete incomplete[field];
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(incomplete)),
      /must contain exactly the required root fields/u,
    );
  }
  const undeclared = structuredClone(valid);
  undeclared.unexpected_root = 'must be rejected';
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(undeclared)),
    /must contain exactly the required root fields/u,
  );
  assert.deepEqual(parseCompactStateJson(JSON.stringify(valid)), valid);
});

test('compact-state JSON ingestion validates semantic root metadata', () => {
  const valid = compactState(reviewInput());

  for (const schema of [0, 2, '1', null]) {
    const unsupported = structuredClone(valid);
    unsupported.schema = schema;
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(unsupported)),
      /schema version is unsupported/u,
    );
  }

  for (const plan of ['', 'docs/planning/other.md', null]) {
    const unsupported = structuredClone(valid);
    unsupported.plan = plan;
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(unsupported)),
      /compact-state plan is unsupported/u,
    );
  }

  for (const updatedUtc of [
    null,
    'not-a-timestamp',
    '2026-02-31T00:00:00Z',
    '2026-09-04T10:00:00+14:01',
  ]) {
    const malformed = structuredClone(valid);
    malformed.updated_utc = updatedUtc;
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(malformed)),
      /Compact-state updated_utc must be a valid timestamp in RFC 3339 format/u,
    );
  }

  const fractional = structuredClone(valid);
  fractional.updated_utc = '2026-09-04T10:00:00.123Z';
  assert.deepEqual(parseCompactStateJson(JSON.stringify(fractional)), fractional);
});

test('compact-state JSON ingestion enforces the closed current-task contract', () => {
  const valid = compactState(reviewInput());
  const requiredFields = [
    'number',
    'state',
    'risk',
    'repository',
    'branch',
    'base',
    'head',
    'last_gate',
    'next_action',
    'blocker',
  ];

  for (const field of requiredFields) {
    const candidate = structuredClone(valid);
    delete candidate.current_task[field];
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(candidate)),
      /persisted task progress is malformed/u,
      `${field} is required`,
    );
  }

  const undeclared = structuredClone(valid);
  undeclared.current_task.unexpected = true;
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(undeclared)),
    /closed current-task contract/u,
  );

  const invalidValues = [
    ['number', 0],
    ['number', 403],
    ['state', 'unknown'],
    ['risk', 'R4'],
    ['repository', ''],
    ['repository', null],
    ['branch', ''],
    ['branch', null],
    ['base', 'not-a-sha'],
    ['base', ['a'.repeat(40)]],
    ['head', 'not-a-sha'],
    ['head', ['a'.repeat(40)]],
    ['last_gate', []],
    ['next_action', ''],
    ['next_action', null],
    ['blocker', {}],
  ];
  for (const [field, value] of invalidValues) {
    const candidate = structuredClone(valid);
    candidate.current_task[field] = value;
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(candidate)),
      /persisted task progress is malformed/u,
      `${field} rejects ${JSON.stringify(value)}`,
    );
  }

  assert.deepEqual(parseCompactStateJson(JSON.stringify(valid)), valid);
});

test('compact-state JSON ingestion enforces the closed review-state contract', () => {
  const valid = compactState(reviewInput());
  const requiredFields = [
    'schemaVersion',
    'reviewInput',
    'mutationClass',
    'reviewRequests',
    'supersededReviewInputs',
    'copilotResults',
    'codexResults',
    'publicMutation',
    'metrics',
    'commentPublications',
  ];

  for (const field of requiredFields) {
    const candidate = structuredClone(valid);
    delete candidate.current_task.review[field];
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(candidate)),
      /closed review-state contract/u,
      `${field} is required`,
    );
  }

  const undeclared = structuredClone(valid);
  undeclared.current_task.review.unexpected = true;
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(undeclared)),
    /closed review-state contract/u,
  );

  for (const schemaVersion of [0, 2, '1', null]) {
    const candidate = structuredClone(valid);
    candidate.current_task.review.schemaVersion = schemaVersion;
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(candidate)),
      /review state is malformed or unsupported/u,
    );
  }
  for (const mutationClass of [null, '', 'UNKNOWN']) {
    const candidate = structuredClone(valid);
    candidate.current_task.review.mutationClass = mutationClass;
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(candidate)),
      /review state is malformed or unsupported/u,
    );
  }

  const invalidContainers = [
    ['reviewInput', []],
    ['reviewRequests', {}],
    ['supersededReviewInputs', []],
    ['copilotResults', []],
    ['codexResults', null],
    ['publicMutation', []],
    ['metrics', null],
    ['commentPublications', {}],
    ['commentPublications', [null]],
    ['commentPublications', [[]]],
  ];
  for (const [field, value] of invalidContainers) {
    const candidate = structuredClone(valid);
    candidate.current_task.review[field] = value;
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(candidate)),
      /review state is malformed or unsupported/u,
      `${field} rejects ${JSON.stringify(value)}`,
    );
  }

  for (const materialReason of [undefined, null, '', ' ', '\t\r\n']) {
    const candidate = compactState(reviewInput(), {
      mutationClass: 'MATERIAL_SCOPE_BEHAVIOR_RISK',
      materialReason,
    });
    if (materialReason === undefined) {
      delete candidate.current_task.review.materialReason;
    }
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(candidate)),
      /review state is malformed or unsupported/u,
    );
  }

  const nonmaterialNullReason = structuredClone(valid);
  nonmaterialNullReason.current_task.review.materialReason = null;
  assert.deepEqual(
    parseCompactStateJson(JSON.stringify(nonmaterialNullReason)),
    nonmaterialNullReason,
  );
  const material = compactState(reviewInput(), {
    mutationClass: 'MATERIAL_SCOPE_BEHAVIOR_RISK',
    materialReason: 'The reviewed risk changed.',
  });
  assert.deepEqual(parseCompactStateJson(JSON.stringify(material)), material);
});

test('compact-state JSON ingestion validates the task-state schema enum', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const allowedStates = schema.$defs.taskState.properties.state.enum;

  for (const taskState of allowedStates) {
    const candidate = compactState(
      reviewInput(),
      {},
      { state: taskState },
      taskState === 'complete' ? { completed: [1, 2, 3, 4] } : {},
    );
    assert.deepEqual(parseCompactStateJson(JSON.stringify(candidate)), candidate);
  }

  for (const taskState of [undefined, null, '', 'bogus']) {
    const candidate = compactState(reviewInput());
    if (taskState === undefined) {
      delete candidate.current_task.state;
    } else {
      candidate.current_task.state = taskState;
    }
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(candidate)),
      /persisted task progress is malformed/u,
    );
  }
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
  if (resolved.anyOf !== undefined) {
    const matches = resolved.anyOf.some((candidate) => {
      try {
        assertSchemaValid(value, candidate, root, location);
        return true;
      } catch {
        return false;
      }
    });
    assert.ok(matches, `${location} does not match any allowed schema.`);
  }
  if (resolved.not !== undefined) {
    let excludedSchemaMatches = true;
    try {
      assertSchemaValid(value, resolved.not, root, location);
    } catch {
      excludedSchemaMatches = false;
    }
    assert.equal(excludedSchemaMatches, false, `${location} matches an excluded schema.`);
  }
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
    if (resolved.maxLength !== undefined) {
      assert.ok(value.length <= resolved.maxLength, `${location} is too long.`);
    }
    if (resolved.pattern !== undefined) {
      assert.match(value, new RegExp(resolved.pattern, 'u'), `${location} does not match pattern.`);
    }
  }
  if (typeof value === 'number' && resolved.minimum !== undefined) {
    assert.ok(value >= resolved.minimum, `${location} is below minimum.`);
  }
  if (typeof value === 'number' && resolved.maximum !== undefined) {
    assert.ok(value <= resolved.maximum, `${location} is above maximum.`);
  }
  if (Array.isArray(value)) {
    if (resolved.maxItems !== undefined) {
      assert.ok(value.length <= resolved.maxItems, `${location} has too many items.`);
    }
    if (resolved.uniqueItems === true) {
      assert.equal(new Set(value.map((item) => JSON.stringify(item))).size, value.length);
    }
    if (resolved.items !== undefined) {
      value.forEach((item, index) => assertSchemaValid(item, resolved.items, root, `${location}[${index}]`));
    }
  }
  if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
    if (resolved.maxProperties !== undefined) {
      assert.ok(
        Object.keys(value).length <= resolved.maxProperties,
        `${location} has too many properties.`,
      );
    }
    for (const required of resolved.required ?? []) {
      assert.ok(Object.hasOwn(value, required), `${location}.${required} is required.`);
    }
    for (const [key, item] of Object.entries(value)) {
      if (resolved.propertyNames !== undefined) {
        assertSchemaValid(key, resolved.propertyNames, root, `${location} property name`);
      }
      if (Object.hasOwn(resolved.properties ?? {}, key)) {
        assertSchemaValid(item, resolved.properties[key], root, `${location}.${key}`);
      } else {
        const matchingPatterns = Object.entries(resolved.patternProperties ?? {})
          .filter(([pattern]) => new RegExp(pattern, 'u').test(key));
        if (matchingPatterns.length > 0) {
          for (const [, patternDefinition] of matchingPatterns) {
            assertSchemaValid(item, patternDefinition, root, `${location}.${key}`);
          }
        } else if (resolved.additionalProperties === false) {
          assert.fail(`${location}.${key} is not allowed.`);
        } else if (typeof resolved.additionalProperties === 'object') {
          assertSchemaValid(item, resolved.additionalProperties, root, `${location}.${key}`);
        }
      }
    }
  }
  for (const condition of resolved.allOf ?? []) {
    if (condition.if === undefined) {
      assertSchemaValid(value, condition, root, location);
      continue;
    }
    let conditionMatches = true;
    try {
      assertSchemaValid(value, condition.if, root, location);
    } catch {
      conditionMatches = false;
    }
    if (conditionMatches && condition.then !== undefined) {
      assertSchemaValid(value, condition.then, root, location);
    }
    if (!conditionMatches && condition.else !== undefined) {
      assertSchemaValid(value, condition.else, root, location);
    }
  }
}

test('materialReason rejects whitespace whenever a string is present', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const valid = compactState(reviewInput());

  assertSchemaValid(valid, schema, schema);
  assert.deepEqual(parseCompactStateJson(JSON.stringify(valid)), valid);

  for (const materialReason of ['', ' ', '\t\r\n']) {
    const invalid = structuredClone(valid);
    invalid.current_task.review.materialReason = materialReason;
    assert.throws(
      () => assertSchemaValid(invalid, schema, schema),
      /too short|does not match pattern/u,
    );
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(invalid)),
      /review state is malformed or unsupported/u,
    );
  }

  for (const materialReason of [null, 'Nonmaterial audit context.']) {
    const allowed = structuredClone(valid);
    allowed.current_task.review.materialReason = materialReason;
    assertSchemaValid(allowed, schema, schema);
    assert.deepEqual(parseCompactStateJson(JSON.stringify(allowed)), allowed);
  }
});

test('task identity and action text reject whitespace in schema and runtime', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const valid = compactState(reviewInput());

  assertSchemaValid(valid, schema, schema);
  assert.deepEqual(parseCompactStateJson(JSON.stringify(valid)), valid);

  for (const field of ['repository', 'branch', 'next_action']) {
    for (const value of [' ', '\t\r\n']) {
      const invalid = structuredClone(valid);
      invalid.current_task[field] = value;
      assert.throws(
        () => assertSchemaValid(invalid, schema, schema),
        /does not match pattern/u,
        `${field} rejects whitespace in the schema`,
      );
      assert.throws(
        () => parseCompactStateJson(JSON.stringify(invalid)),
        /persisted task progress is malformed/u,
        `${field} rejects whitespace during semantic ingestion`,
      );
    }
  }
});

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
  const persistedWithoutReview = structuredClone(persisted);
  delete persistedWithoutReview.current_task.review;
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
  assertSchemaValid(persistedWithoutReview, schema, schema);
  assert.deepEqual(
    parseCompactStateJson(JSON.stringify(persistedWithoutReview)),
    persistedWithoutReview,
  );
  assertSchemaValid(readControllerExample(parent), schema, schema);
  assertSchemaValid(readControllerExample(alternate), schema, schema);
});

test('material reasons require non-whitespace text in both schema and runtime', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const previousInput = reviewInput({ risk: 'R1 reversible planning change.' });
  const currentInput = reviewInput({ risk: 'R2 sensitive planning change.' });
  const valid = compactState(currentInput, {
    mutationClass: 'MATERIAL_SCOPE_BEHAVIOR_RISK',
    materialReason: 'The risk changed.',
  });

  assertSchemaValid(valid, schema, schema);
  for (const materialReason of ['', ' ', '\t\r\n']) {
    const invalid = structuredClone(valid);
    invalid.current_task.review.materialReason = materialReason;
    assert.throws(
      () => assertSchemaValid(invalid, schema, schema),
      /too short|does not match pattern/u,
    );
    assert.throws(
      () => decideReviewRequest({
        previousReviewInput: previousInput,
        currentReviewInput: currentInput,
        mutationClass: 'MATERIAL_SCOPE_BEHAVIOR_RISK',
        materialReason,
      }),
      /requires a reason/u,
    );
  }
});

test('material review reasons reject control characters without changing valid text', () => {
  const previousInput = reviewInput({ risk: 'R1 reversible planning change.' });
  const currentInput = reviewInput({ risk: 'R2 sensitive planning change.' });
  const common = {
    previousReviewInput: previousInput,
    currentReviewInput: currentInput,
    mutationClass: 'MATERIAL_SCOPE_BEHAVIOR_RISK',
  };

  for (const materialReason of ['unsafe\u0001reason', ' \u0001 ']) {
    assert.throws(
      () => decideReviewRequest({ ...common, materialReason }),
      /control character/u,
    );
  }
  const safeReason = '  Preserve `backticks` and Unicode ✓.  ';
  assert.equal(
    decideReviewRequest({ ...common, materialReason: safeReason }).reason,
    safeReason.trim(),
  );
});

test('review-input meaning fields require non-whitespace text in schema and runtime', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const valid = reviewInput();
  for (const field of ['scope', 'behavior', 'risk']) {
    for (const whitespace of [' ', '\t\r\n']) {
      assert.throws(
        () => reviewInput({ [field]: whitespace }),
        new RegExp(`${field} must be non-empty text`, 'u'),
      );
      assert.throws(
        () => assertSchemaValid(
          { ...valid, [field]: whitespace },
          schema.$defs.reviewInput,
          schema,
        ),
        /does not match pattern/u,
      );
    }
  }
});

test('supersession reasons require non-whitespace text in schema and ingestion', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const input1 = reviewInput();
  const input2 = reviewInput({
    head: HASHES.head2,
    tree: HASHES.tree2,
    diffSha256: HASHES.diff2,
    bodySha256: HASHES.body2,
  });
  const valid = compactState(input2, {
    mutationClass: 'CODE_OR_DIFF',
    reviewRequests: [requestFor(input1, 'copilot', {
      confirmed: true,
      terminal: true,
    })],
    supersededReviewInputs: supersessionFor(input1, input2),
  });

  assertSchemaValid(valid, schema, schema);
  assert.deepEqual(parseCompactStateJson(JSON.stringify(valid)), valid);
  for (const reason of ['', ' ', '\t\r\n']) {
    const invalid = structuredClone(valid);
    invalid.current_task.review.supersededReviewInputs[getReviewInputKey(input1)].reason = reason;
    assert.throws(
      () => assertSchemaValid(invalid, schema, schema),
      /too short|does not match pattern/u,
    );
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(invalid)),
      /persisted superseded review-input disposition is malformed/u,
    );
  }
});

test('terminal request state requires typed repository-authorized evidence', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const input = reviewInput();
  const unsupported = compactState(input, {
    reviewRequests: [requestFor(input, 'copilot', { terminal: true })],
  });
  const supportedRequest = requestFor(input, 'copilot', {
    terminal: true,
    terminalDisposition: nonfunctionalDisposition(),
  });
  const supported = compactState(input, { reviewRequests: [supportedRequest] });
  const mistimed = structuredClone(supported);
  mistimed.current_task.review.reviewRequests[0].terminalDisposition.recordedAt =
    '2026-09-04T09:59:59Z';
  const premature = compactState(input, {
    reviewRequests: [requestFor(input, 'copilot', {
      readyAt: '2026-09-04T10:01:00Z',
      terminalDisposition: nonfunctionalDisposition(),
    })],
  });
  const codexTerminalRequest = requestFor(input, 'codex', {
    requestedAt: '2026-09-04T10:02:00Z',
    terminal: true,
    readyAt: '2026-09-04T10:03:00Z',
    terminalDisposition: nonfunctionalDisposition({
      recordedAt: '2026-09-04T10:03:00Z',
    }),
  });
  const codexTerminal = compactState(input, {
    reviewRequests: [
      requestFor(input, 'copilot', { confirmed: true, terminal: true }),
      codexTerminalRequest,
    ],
  });

  assert.throws(
    () => assertSchemaValid(unsupported, schema, schema),
    /terminalDisposition is required/u,
  );
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(unsupported)),
    /persisted review request is malformed/u,
  );
  assertSchemaValid(supported, schema, schema);
  assert.deepEqual(parseCompactStateJson(JSON.stringify(supported)), supported);
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(mistimed)),
    /persisted review request is malformed/u,
  );
  assert.throws(
    () => assertSchemaValid(premature, schema, schema),
    /does not match const/u,
  );
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(premature)),
    /persisted review request is malformed/u,
  );
  assert.throws(
    () => assertSchemaValid(codexTerminalRequest, schema.$defs.reviewRequest, schema),
    /does not match const/u,
  );
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(codexTerminal)),
    /persisted review request is malformed/u,
  );
});

test('confirmed terminal requests require one attributable persisted result', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const input = reviewInput();
  const copilotRequest = requestFor(input, 'copilot', {
    confirmed: true,
    terminal: true,
  });
  const validCopilot = compactState(input, {
    reviewRequests: [copilotRequest],
  });

  assertSchemaValid(validCopilot, schema, schema);
  assert.deepEqual(parseCompactStateJson(JSON.stringify(validCopilot)), validCopilot);

  const missingReference = structuredClone(validCopilot);
  delete missingReference.current_task.review.reviewRequests[0].terminalResultRef;
  assert.throws(
    () => assertSchemaValid(missingReference, schema, schema),
    /does not match any allowed schema/u,
  );
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(missingReference)),
    /persisted review request is malformed/u,
  );

  const missingResult = structuredClone(validCopilot);
  missingResult.current_task.review.copilotResults.submittedReviews = [];
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(missingResult)),
    /one attributable terminal result/u,
  );

  for (const invalidIdentities of [
    { id: {} },
    { id: true },
    { id: Number.MAX_SAFE_INTEGER + 1 },
    { nodeId: copilotRequest.terminalResultRef.id, id: {} },
  ]) {
    const invalid = structuredClone(validCopilot);
    Object.assign(
      invalid.current_task.review.copilotResults.submittedReviews[0],
      invalidIdentities,
    );
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(invalid)),
      /one attributable terminal result|portable safe-integer/u,
      JSON.stringify(invalidIdentities),
    );
  }

  const authenticatedCopilot = structuredClone(validCopilot);
  Object.assign(
    authenticatedCopilot.current_task.review.copilotResults.submittedReviews[0],
    {
      actorDatabaseId: 175728472,
      actorNodeId: 'BOT_kgDOCnlnWA',
      actorType: 'Bot',
    },
  );
  assert.deepEqual(
    parseCompactStateJson(JSON.stringify(authenticatedCopilot)),
    authenticatedCopilot,
  );

  const agreeingCommitIdentities = structuredClone(validCopilot);
  agreeingCommitIdentities.current_task.review.copilotResults
    .submittedReviews[0].commitOid = HASHES.head1;
  assert.deepEqual(
    parseCompactStateJson(JSON.stringify(agreeingCommitIdentities)),
    agreeingCommitIdentities,
  );

  for (const conflictingIdentity of [
    {
      actorDatabaseId: 199175422,
      actorNodeId: 'BOT_kgDOC98s_g',
      actorType: 'Bot',
    },
    {
      actorDatabaseId: 175728472,
      actorNodeId: 'BOT_kgDOC98s_g',
      actorType: 'Bot',
    },
  ]) {
    const invalid = structuredClone(validCopilot);
    Object.assign(
      invalid.current_task.review.copilotResults.submittedReviews[0],
      conflictingIdentity,
    );
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(invalid)),
      /one attributable terminal result/u,
    );
  }

  for (const mutate of [
    (candidate) => {
      candidate.current_task.review.copilotResults.submittedReviews[0].actor =
        'untrusted-reviewer[bot]';
    },
    (candidate) => {
      candidate.current_task.review.copilotResults.submittedReviews[0].commit = HASHES.head2;
    },
    (candidate) => {
      candidate.current_task.review.copilotResults.submittedReviews[0].commitOid = HASHES.head2;
    },
    (candidate) => {
      candidate.current_task.review.copilotResults.submittedReviews[0].submittedAt =
        '2026-09-04T09:59:59Z';
    },
    (candidate) => {
      candidate.current_task.review.reviewRequests[0].baselineReviewNodeIds = [
        copilotRequest.terminalResultRef.id,
      ];
    },
    (candidate) => {
      candidate.current_task.review.copilotResults.submittedReviews.push(
        structuredClone(candidate.current_task.review.copilotResults.submittedReviews[0]),
      );
    },
  ]) {
    const invalid = structuredClone(validCopilot);
    mutate(invalid);
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(invalid)),
      /one attributable terminal result/u,
    );
  }

  const codexRequest = requestFor(input, 'codex', {
    confirmed: true,
    terminal: true,
    requestedAt: '2026-09-04T10:01:00Z',
    baselineConversationComments: {
      COMMENT_CODEX: '2026-09-04T10:00:30Z',
    },
    terminalResultRef: {
      kind: 'conversation-comment',
      id: 'COMMENT_CODEX',
      observedAt: '2026-09-04T10:02:00Z',
    },
  });
  const validHeadlessCodex = compactState(input, {
    reviewRequests: [copilotRequest, codexRequest],
  });
  assertSchemaValid(validHeadlessCodex, schema, schema);
  assert.deepEqual(
    parseCompactStateJson(JSON.stringify(validHeadlessCodex)),
    validHeadlessCodex,
  );

  const observedAfterPublication = structuredClone(validHeadlessCodex);
  observedAfterPublication.current_task.review.reviewRequests[1]
    .terminalResultRef.observedAt = '2026-09-04T10:02:01Z';
  assert.deepEqual(
    parseCompactStateJson(JSON.stringify(observedAfterPublication)),
    observedAfterPublication,
  );

  const observedBeforePublication = structuredClone(validHeadlessCodex);
  observedBeforePublication.current_task.review.reviewRequests[1]
    .terminalResultRef.observedAt = '2026-09-04T10:01:59Z';
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(observedBeforePublication)),
    /one attributable terminal result/u,
  );

  const agreeingHeadIdentities = structuredClone(validHeadlessCodex);
  const agreeingComment = agreeingHeadIdentities.current_task.review
    .codexResults.conversationComments[0];
  agreeingComment.head = HASHES.head1;
  agreeingComment.headRefOid = HASHES.head1;
  assert.deepEqual(
    parseCompactStateJson(JSON.stringify(agreeingHeadIdentities)),
    agreeingHeadIdentities,
  );

  const conflictingHeadIdentities = structuredClone(agreeingHeadIdentities);
  conflictingHeadIdentities.current_task.review.codexResults
    .conversationComments[0].headRefOid = HASHES.head2;
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(conflictingHeadIdentities)),
    /one attributable terminal result/u,
  );

  for (const mutate of [
    (candidate) => {
      delete candidate.current_task.review.codexResults.conversationComments[0].status;
    },
    (candidate) => {
      candidate.current_task.review.codexResults.conversationComments[0].status = 'in-progress';
    },
    (candidate) => {
      candidate.current_task.review.codexResults.conversationComments[0].status =
        'completed-pending';
    },
    (candidate) => {
      candidate.current_task.review.codexResults.conversationComments[0].commitPrefix =
        HASHES.head2.slice(0, 7);
    },
    (candidate) => {
      candidate.current_task.review.reviewRequests[1]
        .baselineConversationComments.COMMENT_CODEX = '2026-09-04T10:02:00Z';
    },
  ]) {
    const invalid = structuredClone(validHeadlessCodex);
    mutate(invalid);
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(invalid)),
      /one attributable terminal result/u,
    );
  }

  const input2 = reviewInput({
    head: HASHES.head2,
    tree: HASHES.tree2,
    diffSha256: HASHES.diff2,
    bodySha256: HASHES.body2,
  });
  const afterDifferentInputBoundary = compactState(input2, {
    mutationClass: 'CODE_OR_DIFF',
    reviewRequests: [
      copilotRequest,
      codexRequest,
      requestFor(input2, 'copilot', {
        requestedAt: '2026-09-04T10:02:00Z',
      }),
    ],
  });
  assert.deepEqual(
    parseCompactStateJson(JSON.stringify(afterDifferentInputBoundary)),
    afterDifferentInputBoundary,
  );
  const successorBeforeTerminalEvidence = structuredClone(afterDifferentInputBoundary);
  successorBeforeTerminalEvidence.current_task.review.reviewRequests[2].requestedAt =
    '2026-09-04T10:01:59Z';
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(successorBeforeTerminalEvidence)),
    /earlier-input request to be terminal first/u,
  );

  const duplicatedReference = compactState(input2, {
    mutationClass: 'CODE_OR_DIFF',
    reviewRequests: [
      copilotRequest,
      requestFor(input2, 'copilot', {
        confirmed: true,
        terminal: true,
        requestedAt: '2026-09-04T10:01:00Z',
        terminalResultRef: structuredClone(copilotRequest.terminalResultRef),
      }),
    ],
  });
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(duplicatedReference)),
    /assigned to multiple requests/u,
  );

  const sameHeadInput = reviewInput({ risk: 'R2 sensitive planning change.' });
  const sharedResult = {
    id: 71,
    nodeId: 'SHARED_RESULT_NODE',
    actor: 'copilot-pull-request-reviewer[bot]',
    commit: input.head,
    submittedAt: '2026-09-04T10:01:00Z',
  };
  const alternateIdentityReuse = compactState(sameHeadInput, {
    mutationClass: 'MATERIAL_SCOPE_BEHAVIOR_RISK',
    materialReason: 'The reviewed risk changed.',
    reviewRequests: [
      requestFor(input, 'copilot', {
        confirmed: true,
        terminal: true,
        terminalResultRef: {
          kind: 'submitted-review',
          id: '71',
          observedAt: '2026-09-04T10:01:00Z',
        },
      }),
      requestFor(sameHeadInput, 'copilot', {
        confirmed: true,
        terminal: true,
        requestedAt: '2026-09-04T10:01:00Z',
        terminalResultRef: {
          kind: 'submitted-review',
          id: 'SHARED_RESULT_NODE',
          observedAt: '2026-09-04T10:01:00Z',
        },
      }),
    ],
    supersededReviewInputs: supersessionFor(input, sameHeadInput, {
      supersededAt: '2026-09-04T10:01:00Z',
    }),
    copilotResults: {
      submittedReviews: [sharedResult],
      conversationComments: [],
    },
  });
  assertSchemaValid(alternateIdentityReuse, schema, schema);
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(alternateIdentityReuse)),
    /terminal result is assigned to multiple requests/u,
  );

  const copilotConversation = structuredClone(validCopilot);
  copilotConversation.current_task.review.reviewRequests[0].terminalResultRef.kind =
    'conversation-comment';
  assert.throws(
    () => assertSchemaValid(copilotConversation, schema, schema),
    /does not match const/u,
  );
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(copilotConversation)),
    /persisted review request is malformed/u,
  );
});

test('compact-state ingestion cross-validates supersessions and causal ordering', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({
    head: HASHES.head2,
    tree: HASHES.tree2,
    diffSha256: HASHES.diff2,
    bodySha256: HASHES.body2,
  });
  const oldRequest = requestFor(input1, 'copilot', {
    confirmed: true,
    terminal: true,
  });
  const valid = compactState(input2, {
    mutationClass: 'CODE_OR_DIFF',
    reviewRequests: [oldRequest],
    supersededReviewInputs: supersessionFor(input1, input2),
  });
  const noRequest = structuredClone(valid);
  noRequest.current_task.review.reviewRequests = [];
  const completePair = compactState(input2, {
    mutationClass: 'CODE_OR_DIFF',
    reviewRequests: pairFor(input1),
    supersededReviewInputs: supersessionFor(input1, input2),
  });
  const wrongHead = structuredClone(valid);
  wrongHead.current_task.review.supersededReviewInputs[getReviewInputKey(input1)].head =
    HASHES.tree1;
  const predatesRequest = structuredClone(valid);
  predatesRequest.current_task.review.supersededReviewInputs[
    getReviewInputKey(input1)
  ].supersededAt = '2026-09-04T09:59:59Z';
  const successorStartedBeforeSupersession = compactState(input2, {
    mutationClass: 'CODE_OR_DIFF',
    reviewRequests: [
      oldRequest,
      requestFor(input2, 'copilot', { requestedAt: '2026-09-04T10:01:30Z' }),
    ],
    supersededReviewInputs: supersessionFor(input1, input2),
  });
  const supersededBeforeSuccessor = structuredClone(successorStartedBeforeSupersession);
  supersededBeforeSuccessor.current_task.review.supersededReviewInputs[
    getReviewInputKey(input1)
  ].supersededAt = '2026-09-04T10:01:15Z';
  const retroactiveWrongSuccessor = structuredClone(successorStartedBeforeSupersession);
  retroactiveWrongSuccessor.current_task.review.supersededReviewInputs[
    getReviewInputKey(input1)
  ].successorHead = input1.head;
  retroactiveWrongSuccessor.current_task.review.supersededReviewInputs[
    getReviewInputKey(input1)
  ].supersededAt = '2026-09-04T10:01:45Z';

  assert.deepEqual(parseCompactStateJson(JSON.stringify(valid)), valid);
  assert.deepEqual(
    parseCompactStateJson(JSON.stringify(supersededBeforeSuccessor)),
    supersededBeforeSuccessor,
  );
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(noRequest)),
    /request count does not match/u,
  );
  for (const candidate of [completePair, wrongHead, predatesRequest]) {
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(candidate)),
      /terminal incomplete prior-input pair/u,
    );
  }
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(successorStartedBeforeSupersession)),
    /terminal incomplete prior-input pair/u,
  );
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(retroactiveWrongSuccessor)),
    /terminal incomplete prior-input pair/u,
  );
});

test('supersession timing ignores earlier reviewed inputs on the same successor head', () => {
  const inputX = reviewInput();
  const inputY = reviewInput({ risk: 'R2 material risk Y.' });
  const inputZ = reviewInput({ risk: 'R3 material risk Z.' });
  const xPair = pairFor(inputX);
  const yRequest = requestFor(inputY, 'copilot', {
    requestedAt: '2026-09-04T10:02:00Z',
    confirmed: true,
    terminal: true,
    terminalResultRef: {
      kind: 'submitted-review',
      id: 'RESULT_Y_COPILOT',
      observedAt: '2026-09-04T10:03:00Z',
    },
  });
  const zRequest = requestFor(inputZ, 'copilot', {
    requestedAt: '2026-09-04T10:04:00Z',
  });
  const valid = compactState(inputZ, {
    mutationClass: 'MATERIAL_SCOPE_BEHAVIOR_RISK',
    materialReason: 'Input Z materially changes the reviewed risk.',
    reviewRequests: [...xPair, yRequest, zRequest],
    supersededReviewInputs: supersessionFor(inputY, inputZ, {
      supersededAt: '2026-09-04T10:03:30Z',
    }),
  });

  assert.deepEqual(parseCompactStateJson(JSON.stringify(valid)), valid);

  const late = structuredClone(valid);
  late.current_task.review.supersededReviewInputs[
    getReviewInputKey(inputY)
  ].supersededAt = '2026-09-04T10:04:01Z';
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(late)),
    /terminal incomplete prior-input pair/u,
  );
});

test('request metrics retain an unrequested successor across a second head drift', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const input1 = reviewInput();
  const input2 = reviewInput({
    head: HASHES.head2,
    tree: HASHES.tree2,
    diffSha256: HASHES.diff2,
    bodySha256: HASHES.body2,
  });
  const input3 = reviewInput({
    head: '3'.repeat(40),
    tree: '4'.repeat(40),
    diffSha256: '3'.repeat(64),
    bodySha256: '4'.repeat(64),
  });
  const oldRequest = requestFor(input1, 'copilot', {
    confirmed: true,
    terminal: true,
  });
  const firstDrift = compactState(input2, {
    mutationClass: 'CODE_OR_DIFF',
    reviewRequests: [oldRequest],
    supersededReviewInputs: supersessionFor(input1, input2),
  });
  const secondDrift = compactState(input3, {
    mutationClass: 'CODE_OR_DIFF',
    reviewRequests: [oldRequest],
    supersededReviewInputs: supersessionFor(input1, input2),
    metrics: {
      ...firstDrift.current_task.review.metrics,
      reviewerRequestsPerHead: {
        ...firstDrift.current_task.review.metrics.reviewerRequestsPerHead,
        [input3.head]: 0,
      },
      reviewedHeadEvidence: {
        ...firstDrift.current_task.review.metrics.reviewedHeadEvidence,
        [input3.head]: {
          source: 'authenticated-pr-readback',
          tree: input3.tree,
          observedAt: '2026-09-04T10:02:30Z',
        },
      },
    },
  });

  assertSchemaValid(secondDrift, schema, schema);
  assert.deepEqual(parseCompactStateJson(JSON.stringify(secondDrift)), secondDrift);

  const resumedDecision = decideReviewRequest({
    previousReviewInput: input2,
    currentReviewInput: input3,
    mutationClass: 'CODE_OR_DIFF',
    existingRequests: secondDrift.current_task.review.reviewRequests,
    supersededInputs: secondDrift.current_task.review.supersededReviewInputs,
    reviewMetrics: secondDrift.current_task.review.metrics,
  });
  assert.equal(resumedDecision.status, 'REQUEST_REQUIRED');
  assert.deepEqual(resumedDecision.channels, ['copilot']);
  assert.throws(
    () => decideReviewRequest({
      previousReviewInput: input2,
      currentReviewInput: input3,
      mutationClass: 'CODE_OR_DIFF',
      existingRequests: secondDrift.current_task.review.reviewRequests,
      supersededInputs: secondDrift.current_task.review.supersededReviewInputs,
    }),
    /terminal incomplete prior-input pair/u,
  );

  const wrongDecisionMetrics = structuredClone(secondDrift.current_task.review.metrics);
  wrongDecisionMetrics.reviewerRequestsPerHead[input1.head] = 2;
  assert.throws(
    () => decideReviewRequest({
      previousReviewInput: input2,
      currentReviewInput: input3,
      mutationClass: 'CODE_OR_DIFF',
      existingRequests: secondDrift.current_task.review.reviewRequests,
      supersededInputs: secondDrift.current_task.review.supersededReviewInputs,
      reviewMetrics: wrongDecisionMetrics,
    }),
    /request count does not match/u,
  );

  const missingIntermediate = structuredClone(secondDrift);
  delete missingIntermediate.current_task.review.metrics
    .reviewerRequestsPerHead[input2.head];
  delete missingIntermediate.current_task.review.metrics
    .reviewedHeadEvidence[input2.head];
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(missingIntermediate)),
    /terminal incomplete prior-input pair/u,
  );

  const reorderedHistory = structuredClone(secondDrift);
  reorderedHistory.current_task.review.metrics.reviewerRequestsPerHead = {
    [input2.head]: 0,
    [input1.head]: 1,
    [input3.head]: 0,
  };
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(reorderedHistory)),
    /terminal incomplete prior-input pair/u,
  );

  const missingCurrent = structuredClone(secondDrift);
  delete missingCurrent.current_task.review.metrics
    .reviewerRequestsPerHead[input3.head];
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(missingCurrent)),
    /current reviewed head is missing/u,
  );

  const missingRequestHead = structuredClone(secondDrift);
  delete missingRequestHead.current_task.review.metrics
    .reviewerRequestsPerHead[input1.head];
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(missingRequestHead)),
    /request head is missing/u,
  );

  const wrongCount = structuredClone(secondDrift);
  wrongCount.current_task.review.metrics.reviewerRequestsPerHead[input1.head] = 2;
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(wrongCount)),
    /request count does not match/u,
  );

  const malformedHead = structuredClone(secondDrift);
  malformedHead.current_task.review.metrics.reviewerRequestsPerHead.invalid = 0;
  assert.throws(
    () => assertSchemaValid(malformedHead, schema, schema),
    /property name does not match pattern/u,
  );
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(malformedHead)),
    /request-per-head metric is malformed/u,
  );
});

test('request metrics reject forged reviewed-head chronology', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({
    head: HASHES.head2,
    tree: HASHES.tree2,
    diffSha256: HASHES.diff2,
    bodySha256: HASHES.body2,
  });
  const input3 = reviewInput({
    head: '3'.repeat(40),
    tree: '4'.repeat(40),
    diffSha256: '3'.repeat(64),
    bodySha256: '4'.repeat(64),
  });
  const input1Request = requestFor(input1, 'copilot', {
    requestedAt: '2026-09-04T10:00:00Z',
    confirmed: true,
    terminal: true,
    terminalResultRef: {
      kind: 'submitted-review',
      id: 'RESULT_INPUT_1',
      observedAt: '2026-09-04T10:01:00Z',
    },
  });
  const input2Requests = [
    requestFor(input2, 'copilot', {
      requestedAt: '2026-09-04T10:03:00Z',
      confirmed: true,
      terminal: true,
      terminalResultRef: {
        kind: 'submitted-review',
        id: 'RESULT_INPUT_2_COPILOT',
        observedAt: '2026-09-04T10:04:00Z',
      },
    }),
    requestFor(input2, 'codex', {
      requestedAt: '2026-09-04T10:05:00Z',
      confirmed: true,
      terminal: true,
      terminalResultRef: {
        kind: 'submitted-review',
        id: 'RESULT_INPUT_2_CODEX',
        observedAt: '2026-09-04T10:06:00Z',
      },
    }),
  ];
  const forged = compactState(input3, {
    mutationClass: 'CODE_OR_DIFF',
    reviewRequests: [input1Request, ...input2Requests],
    supersededReviewInputs: supersessionFor(input1, input3, {
      supersededAt: '2026-09-04T10:02:00Z',
    }),
    metrics: {
      ...state(input3).metrics,
      reviewerRequestsPerHead: {
        [input1.head]: 1,
        [input3.head]: 0,
        [input2.head]: 2,
      },
    },
  });

  assert.throws(
    () => parseCompactStateJson(JSON.stringify(forged)),
    /does not preserve reviewed-head chronology/u,
  );
  assert.throws(
    () => decideReviewRequest({
      previousReviewInput: input2,
      currentReviewInput: input3,
      mutationClass: 'CODE_OR_DIFF',
      existingRequests: forged.current_task.review.reviewRequests,
      supersededInputs: forged.current_task.review.supersededReviewInputs,
      reviewMetrics: forged.current_task.review.metrics,
    }),
    /does not preserve reviewed-head chronology/u,
  );
});

test('same-head unrequested successors survive a later distinct-head drift', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({ risk: 'R2 same-head successor.' });
  const input3 = reviewInput({
    head: HASHES.head2,
    tree: HASHES.tree2,
    diffSha256: HASHES.diff2,
    bodySha256: HASHES.body2,
  });
  const oldRequest = requestFor(input1, 'copilot', {
    confirmed: true,
    terminal: true,
  });
  const retained = compactState(input3, {
    mutationClass: 'CODE_OR_DIFF',
    reviewRequests: [oldRequest],
    supersededReviewInputs: supersessionFor(input1, input2),
    metrics: {
      ...state(input2, { reviewRequests: [oldRequest] }).metrics,
      reviewerRequestsPerHead: {
        [input1.head]: 1,
        [input3.head]: 0,
      },
      reviewedHeadEvidence: {
        [input3.head]: {
          source: 'authenticated-pr-readback',
          tree: input3.tree,
          observedAt: '2026-09-04T10:02:30Z',
        },
      },
    },
  });
  assert.deepEqual(parseCompactStateJson(JSON.stringify(retained)), retained);

  const requestedSuccessor = structuredClone(retained);
  requestedSuccessor.current_task.review.reviewRequests.push(
    requestFor(input3, 'copilot', { requestedAt: '2026-09-04T10:03:00Z' }),
  );
  requestedSuccessor.current_task.review.metrics
    .reviewerRequestsPerHead[input3.head] = 1;
  delete requestedSuccessor.current_task.review.metrics
    .reviewedHeadEvidence[input3.head];
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(requestedSuccessor)),
    /terminal incomplete prior-input pair/u,
  );
  requestedSuccessor.current_task.review.supersededReviewInputs[
    getReviewInputKey(input1)
  ].successorHead = input3.head;
  assert.deepEqual(
    parseCompactStateJson(JSON.stringify(requestedSuccessor)),
    requestedSuccessor,
  );
});

test('compact-state ingestion binds the review input to the current task head', () => {
  const input = reviewInput();
  const mismatched = compactState(input, {}, { head: HASHES.head2 });

  assert.throws(
    () => parseCompactStateJson(JSON.stringify(mismatched)),
    /review input must match the current task head/u,
  );

  const mismatchedRequest = compactState(input, {
    reviewRequests: [requestFor(input, 'copilot', { head: HASHES.head2 })],
  });
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(mismatchedRequest)),
    /current-input request must match the reviewed head/u,
  );
});

test('compact-state ingestion rejects nonportable JSON numbers without rounding', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const input = reviewInput();
  const portable = compactState(input, {}, {}, {
    predecessor_outputs: {
      3: {
        PORTABLE_VALUES: {
          value: {
            maximum: Number.MAX_SAFE_INTEGER,
            fraction: 0.125,
            nested: [null, true, 'exact'],
          },
          last_consumer_task: 4,
        },
      },
    },
  });
  const unsafeSchemaValue = structuredClone(portable);
  unsafeSchemaValue.predecessor_outputs[3].PORTABLE_VALUES.value =
    Number.MAX_SAFE_INTEGER + 1;
  const nonfiniteSchemaValue = structuredClone(portable);
  nonfiniteSchemaValue.predecessor_outputs[3].PORTABLE_VALUES.value = Infinity;
  const progress = Array.from({ length: 14 }, (_, index) => index + 1).join(',');
  const rawState = (numericToken) =>
    `{"current_task":{"number":15,"state":"active"},` +
    `"completed":[${progress}],"predecessor_outputs":{"14":{"REMOTE_ID":{` +
    `"value":${numericToken},"last_consumer_task":15}}}}`;

  assertSchemaValid(portable, schema, schema);
  assert.deepEqual(parseCompactStateJson(JSON.stringify(portable)), portable);
  for (const candidate of [unsafeSchemaValue, nonfiniteSchemaValue]) {
    assert.throws(
      () => assertSchemaValid(candidate, schema, schema),
      /does not match any allowed schema/u,
    );
  }
  for (const numericToken of [
    '9007199254740993',
    '9007199254740991.1',
    '-9007199254740991.1',
    '1e400',
    '-1e400',
    '-0',
  ]) {
    assert.throws(
      () => parseCompactStateJson(rawState(numericToken)),
      /finite, lossless, and within the portable safe-integer magnitude/u,
    );
  }
  for (const [numericToken, expected] of [
    ['1.0', 1],
    ['1e0', 1],
    ['0.1250', 0.125],
  ]) {
    const exactText = JSON.stringify(portable).replace('0.125', numericToken);
    assert.equal(
      parseCompactStateJson(exactText).predecessor_outputs[3]
        .PORTABLE_VALUES.value.fraction,
      expected,
    );
  }
});

test('a live prior channel cannot be closed by same-head supersession', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({ risk: 'R2 sensitive planning change.' });
  const liveRequest = requestFor(input1, 'copilot', {
    confirmed: true,
    terminal: false,
  });
  const decision = (request, supersededInputs = {}) => decideReviewRequest({
    previousReviewInput: input1,
    currentReviewInput: input2,
    mutationClass: 'MATERIAL_SCOPE_BEHAVIOR_RISK',
    materialReason: 'The risk changed.',
    existingRequests: [request],
    supersededInputs,
  });

  assert.equal(decision(liveRequest).status, 'WAIT_FOR_PRIOR_PAIR');
  assert.throws(
    () => decision(liveRequest, supersessionFor(input1, input2)),
    /terminal incomplete prior-input pair/u,
  );

  const terminalRequest = requestFor(input1, 'copilot', {
    confirmed: true,
    terminal: true,
  });
  assert.equal(decision(terminalRequest).status, 'SUPERSESSION_REQUIRED');
  assert.equal(
    decision(terminalRequest, supersessionFor(input1, input2)).status,
    'REQUEST_REQUIRED',
  );
});

test('compact progress stays within the fixed plan and names contiguous predecessors', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  assert.equal(PLAN_TASK_COUNT, 402);
  const activeFinalTask = compactState(reviewInput(), {}, {
    number: PLAN_TASK_COUNT,
  }, {
    completed: Array.from({ length: PLAN_TASK_COUNT - 1 }, (_, index) => index + 1),
  });
  const completeFinalTask = structuredClone(activeFinalTask);
  completeFinalTask.current_task.state = 'complete';
  completeFinalTask.completed.push(PLAN_TASK_COUNT);

  assertSchemaValid(activeFinalTask, schema, schema);
  assert.deepEqual(parseCompactStateJson(JSON.stringify(activeFinalTask)), activeFinalTask);
  assertSchemaValid(completeFinalTask, schema, schema);
  assert.deepEqual(parseCompactStateJson(JSON.stringify(completeFinalTask)), completeFinalTask);

  const outsidePlan = compactState(reviewInput(), {}, { number: PLAN_TASK_COUNT + 1 }, {
    completed: [1, 2, 3],
  });
  const nonexistentCompletedTask = compactState(reviewInput(), {}, {}, {
    completed: [1, 2, PLAN_TASK_COUNT + 1],
  });
  assert.throws(() => assertSchemaValid(outsidePlan, schema, schema), /above maximum/u);
  assert.throws(
    () => assertSchemaValid(nonexistentCompletedTask, schema, schema),
    /above maximum/u,
  );

  for (const completed of [
    [1, 3],
    [2, 1, 3],
    [1, 2, 3, 4],
    [1, 2],
  ]) {
    const invalid = compactState(reviewInput(), {}, {}, { completed });
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(invalid)),
      /contiguous predecessors/u,
    );
  }

  const incompleteCompleteTask = compactState(reviewInput(), {}, { state: 'complete' });
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(incompleteCompleteTask)),
    /contiguous predecessors/u,
  );
});

test('compact-state ingestion rejects duplicate reviewed-input channel requests', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const input1 = reviewInput();
  const input2 = reviewInput({
    head: HASHES.head2,
    tree: HASHES.tree2,
    diffSha256: HASHES.diff2,
    bodySha256: HASHES.body2,
  });
  const first = requestFor(input1, 'copilot');
  const differentTimestamp = requestFor(input1, 'copilot', {
    requestedAt: '2026-09-04T10:01:00Z',
  });
  const duplicate = compactState(input1, {
    reviewRequests: [first, differentTimestamp],
  });

  assertSchemaValid(duplicate, schema, schema);
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(duplicate)),
    /duplicate reviewed-input and channel/u,
  );

  const identical = compactState(input1, {
    reviewRequests: [first, structuredClone(first)],
  });
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(identical)),
    /duplicate reviewed-input and channel/u,
  );

  const distinctChannels = compactState(input1, {
    reviewRequests: [
      requestFor(input1, 'copilot', { confirmed: true }),
      requestFor(input1, 'codex'),
    ],
  });
  assert.deepEqual(parseCompactStateJson(JSON.stringify(distinctChannels)), distinctChannels);

  const distinctInputs = compactState(input1, {
    reviewRequests: [first, requestFor(input2, 'copilot')],
  });
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(distinctInputs)),
    /earlier-input request to be terminal first/u,
  );
  const serializedDistinctInputs = compactState(input1, {
    reviewRequests: [
      requestFor(input1, 'copilot', { confirmed: true, terminal: true }),
      requestFor(input2, 'copilot', { requestedAt: '2026-09-04T10:01:00Z' }),
    ],
  });
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(serializedDistinctInputs)),
    /requires a superseded disposition/u,
  );
  serializedDistinctInputs.current_task.review.supersededReviewInputs =
    supersessionFor(input1, input2, { supersededAt: '2026-09-04T10:01:00Z' });
  assert.deepEqual(
    parseCompactStateJson(JSON.stringify(serializedDistinctInputs)),
    serializedDistinctInputs,
  );
});

test('compact task commit identities are SHA-1 values or null', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const persisted = compactState(reviewInput());
  const withoutCommitIdentities = structuredClone(persisted);
  withoutCommitIdentities.current_task.base = null;
  withoutCommitIdentities.current_task.head = null;

  assertSchemaValid(persisted, schema, schema);
  assertSchemaValid(withoutCommitIdentities, schema, schema);

  for (const field of ['base', 'head']) {
    for (const malformed of [
      'refs/heads/not-a-commit',
      'deadbeef',
      'A'.repeat(40),
      'a'.repeat(39),
      'a'.repeat(41),
    ]) {
      const candidate = structuredClone(persisted);
      candidate.current_task[field] = malformed;
      assert.throws(
        () => assertSchemaValid(candidate, schema, schema),
        /does not match any allowed schema/u,
      );
    }
  }
});

test('predecessor outputs survive required restart boundaries and prune after final use', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const input = reviewInput();
  const outputs = {
    12: {
      TASK_012_REVIEWED_HEAD: {
        value: HASHES.head1,
        last_consumer_task: 15,
      },
      TASK_012_TASK_13_ONLY: {
        value: 'repair input',
        last_consumer_task: 13,
      },
    },
  };
  const after12 = prunePredecessorOutputs(outputs, 12);
  const after13 = prunePredecessorOutputs(outputs, 13);
  const after14 = prunePredecessorOutputs(outputs, 14);
  const after15 = prunePredecessorOutputs(outputs, 15);

  assert.deepEqual(Object.keys(after12[12]).sort(), [
    'TASK_012_REVIEWED_HEAD',
    'TASK_012_TASK_13_ONLY',
  ]);
  assert.deepEqual(Object.keys(after13[12]), ['TASK_012_REVIEWED_HEAD']);
  assert.deepEqual(after14, after13);
  assert.deepEqual(after15, {});

  for (const [taskNumber, predecessorOutputs] of [
    [13, after12],
    [14, after13],
    [15, after14],
  ]) {
    const resumed = compactState(
      input,
      {},
      { number: taskNumber },
      {
        predecessor_outputs: predecessorOutputs,
        completed: Array.from({ length: taskNumber - 1 }, (_, index) => index + 1),
      },
    );
    assertSchemaValid(resumed, schema, schema);
  }

  assert.throws(
    () => prunePredecessorOutputs({
      12: {
        TASK_012_BAD: { value: 'bad', last_consumer_task: 12 },
      },
    }, 12),
    /malformed/u,
  );
});

test('predecessor output values must be lossless portable JSON trees', () => {
  const outputsFor = (value) => ({
    1: {
      VALUE: {
        value,
        last_consumer_task: 2,
      },
    },
  });
  const invalidPrimitiveValues = [
    undefined,
    NaN,
    Infinity,
    -Infinity,
    -0,
    Number.MAX_SAFE_INTEGER + 1,
    () => true,
    Symbol('value'),
    1n,
  ];
  for (const value of invalidPrimitiveValues) {
    assert.throws(
      () => prunePredecessorOutputs(outputsFor(value), 1),
      /not portable JSON/u,
    );
  }

  for (const value of [
    { kept: true, lost: undefined },
    { kept: true, lost: () => true },
    { kept: true, lost: Symbol('value') },
    [true, undefined],
    [true, () => true],
    [true, Symbol('value')],
  ]) {
    assert.throws(
      () => prunePredecessorOutputs(outputsFor(value), 1),
      /not portable JSON/u,
    );
  }

  const cycle = {};
  cycle.self = cycle;
  const sparse = [];
  sparse.length = 1;
  const shared = { safe: true };
  const symbolObject = { safe: true };
  symbolObject[Symbol('hidden')] = false;
  const symbolArray = [true];
  symbolArray[Symbol('hidden')] = false;
  const hiddenObject = { safe: true };
  Object.defineProperty(hiddenObject, 'hidden', { value: false });
  const hiddenArray = [true];
  Object.defineProperty(hiddenArray, 'hidden', { value: false });
  const customArray = [true];
  customArray.extra = false;
  let getterCalls = 0;
  const accessorObject = {};
  Object.defineProperty(accessorObject, 'unsafe', {
    enumerable: true,
    get() {
      getterCalls += 1;
      return true;
    },
  });
  const accessorArray = [true];
  Object.defineProperty(accessorArray, '0', {
    enumerable: true,
    get() {
      getterCalls += 1;
      return true;
    },
  });
  class CustomArray extends Array {}
  const inheritedToJsonArray = [true];
  Object.setPrototypeOf(
    inheritedToJsonArray,
    Object.create(Array.prototype, {
      toJSON: {
        get() {
          getterCalls += 1;
          return () => null;
        },
      },
    }),
  );
  const ownToJson = {
    safe: true,
    toJSON() {
      return { changed: true };
    },
  };
  class CustomValue {
    constructor() {
      this.safe = true;
    }
  }

  for (const value of [
    cycle,
    sparse,
    symbolObject,
    symbolArray,
    hiddenObject,
    hiddenArray,
    customArray,
    accessorObject,
    accessorArray,
    new CustomArray(true),
    inheritedToJsonArray,
    ownToJson,
    new Date('2026-09-06T00:00:00Z'),
    new Map([['safe', true]]),
    new Set([true]),
    new Uint8Array([1]),
    new CustomValue(),
  ]) {
    assert.throws(
      () => prunePredecessorOutputs(outputsFor(value), 1),
      /not portable JSON/u,
    );
  }
  assert.equal(getterCalls, 0);
  assert.throws(
    () => prunePredecessorOutputs(outputsFor([shared, shared]), 1),
    /not portable JSON/u,
    'Shared non-cyclic references are graphs, not portable JSON trees.',
  );
  for (const value of [
    'bad\u0007value',
    { safe: 'bad\u0007value' },
    { 'bad\u0007key': 'safe' },
  ]) {
    assert.throws(
      () => prunePredecessorOutputs(outputsFor(value), 1),
      /disallowed control character/u,
    );
  }

  const nullPrototype = Object.create(null);
  nullPrototype.safe = '✓';
  const valid = {
    nil: null,
    yes: true,
    no: false,
    text: '`Markdown` and Unicode ✓',
    integer: Number.MAX_SAFE_INTEGER,
    decimal: 0.125,
    array: [null, false, { nested: 'value' }],
    nullPrototype,
  };
  assert.deepEqual(
    prunePredecessorOutputs(outputsFor(valid), 1),
    outputsFor({
      array: [null, false, { nested: 'value' }],
      decimal: 0.125,
      integer: Number.MAX_SAFE_INTEGER,
      nil: null,
      no: false,
      nullPrototype: { safe: '✓' },
      text: '`Markdown` and Unicode ✓',
      yes: true,
    }),
  );
});

test('pruning rejects future producers and out-of-plan progress after valid expiry', () => {
  const expiring = {
    2: {
      CURRENT_DATA: { value: 'valid', last_consumer_task: 3 },
    },
  };
  const retained = {
    2: {
      FUTURE_DATA: { value: 'needed', last_consumer_task: 4 },
    },
  };

  assert.deepEqual(prunePredecessorOutputs({}, 0), {});
  assert.throws(
    () => prunePredecessorOutputs({
      1: {
        FUTURE_DATA: { value: 'invalid', last_consumer_task: 2 },
      },
    }, 0),
    /predecessor task must contain a bounded output map/u,
  );
  assert.deepEqual(prunePredecessorOutputs(expiring, 3), {});
  assert.deepEqual(prunePredecessorOutputs(retained, 3), retained);
  assert.throws(
    () => prunePredecessorOutputs({
      10: {
        FABRICATED_DATA: { value: 'invalid', last_consumer_task: 11 },
      },
    }, 3),
    /predecessor task must contain a bounded output map/u,
  );
  assert.throws(
    () => prunePredecessorOutputs({}, PLAN_TASK_COUNT + 1),
    /completed plan prefix/u,
  );
  for (const invalidProgress of [-1, 0.5]) {
    assert.throws(
      () => prunePredecessorOutputs({}, invalidProgress),
      /completed plan prefix/u,
    );
  }
});

test('predecessor outputs stay within the fixed plan in both ingestion layers', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const input = reviewInput();
  const atPlanBoundary = compactState(input, {}, {
    number: PLAN_TASK_COUNT,
  }, {
    predecessor_outputs: {
      [PLAN_TASK_COUNT - 1]: {
        FINAL_HANDOFF: { value: 'valid', last_consumer_task: PLAN_TASK_COUNT },
      },
    },
    completed: Array.from({ length: PLAN_TASK_COUNT - 1 }, (_, index) => index + 1),
  });
  const outsideProducerBoundary = compactState(input, {}, {}, {
    predecessor_outputs: {
      [PLAN_TASK_COUNT + 1]: {
        OUTSIDE_PRODUCER: { value: 'invalid', last_consumer_task: 999 },
      },
    },
  });
  const outsideConsumerBoundary = compactState(input, {}, {}, {
    predecessor_outputs: {
      2: {
        OUTSIDE_CONSUMER: {
          value: 'invalid',
          last_consumer_task: PLAN_TASK_COUNT + 1,
        },
      },
    },
  });

  assertSchemaValid(atPlanBoundary, schema, schema);
  assert.deepEqual(
    parseCompactStateJson(JSON.stringify(atPlanBoundary)),
    atPlanBoundary,
  );
  assert.throws(
    () => assertSchemaValid(outsideProducerBoundary, schema, schema),
    /property name does not match pattern/u,
  );
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(outsideProducerBoundary)),
    /bounded output map/u,
  );
  assert.throws(
    () => assertSchemaValid(outsideConsumerBoundary, schema, schema),
    /above maximum/u,
  );
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(outsideConsumerBoundary)),
    /predecessor output record is malformed/u,
  );
});

test('compact-state ingestion rejects future and expired predecessor outputs', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const input = reviewInput();
  const futureProducer = compactState(input, {}, {}, {
    predecessor_outputs: {
      10: {
        FUTURE_DATA: { value: 'fabricated', last_consumer_task: 11 },
      },
    },
  });
  const expiredOutput = compactState(input, {}, {}, {
    predecessor_outputs: {
      2: {
        EXPIRED_DATA: { value: 'stale', last_consumer_task: 3 },
      },
    },
  });
  const validBoundary = compactState(input, {}, {}, {
    predecessor_outputs: {
      3: {
        CURRENT_DATA: { value: 'valid', last_consumer_task: 4 },
      },
    },
  });

  assertSchemaValid(futureProducer, schema, schema);
  assertSchemaValid(expiredOutput, schema, schema);
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(futureProducer)),
    /predecessor task must contain a bounded output map/u,
  );
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(expiredOutput)),
    /predecessor output record is malformed/u,
  );
  assert.deepEqual(
    parseCompactStateJson(JSON.stringify(validBoundary)),
    validBoundary,
  );
});

test('compact-state ingestion rejects invalid predecessor and reconciliation ordering', () => {
  const input = reviewInput();
  const reviewRequest = requestFor(input, 'copilot');
  const negativeEvidence = {
    responseReviewerMatched: false,
    requestEventMatched: false,
    requestedReviewerMatched: false,
    submittedReviewMatched: false,
    reviewRunMatched: false,
    triggerCommentMatched: false,
    readbackComplete: true,
  };
  const invalidInterval = compactState(input, {
    publicMutation: {
      state: 'NO_EFFECT',
      nativeResponseAccepted: true,
      readbackMatched: false,
      retryAllowed: true,
      localRecordSucceeded: true,
      reviewInputKey: getReviewInputKey(input),
      channel: 'copilot',
      attemptCount: 1,
      attemptedAt: '2026-09-04T10:02:00Z',
      reconciledAt: '2026-09-04T10:02:00Z',
      evidence: negativeEvidence,
    },
  });
  invalidInterval.current_task.review.reviewRequests = [reviewRequest];
  invalidInterval.current_task.review.metrics.reviewerRequestsPerHead[input.head] = 1;
  const reversedInterval = structuredClone(invalidInterval);
  reversedInterval.current_task.review.publicMutation.reconciledAt =
    '2026-09-04T10:01:59Z';
  const invalidPredecessor = compactState(input, {}, {}, {
    predecessor_outputs: {
      2: {
        INVALID_ORDER: { value: 'bad', last_consumer_task: 2 },
      },
    },
  });

  assert.throws(
    () => parseCompactStateJson(JSON.stringify(invalidInterval)),
    /interval is too short/u,
  );
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(reversedInterval)),
    /precedes its attempt/u,
  );
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(invalidPredecessor)),
    /predecessor output record is malformed/u,
  );
});

test('compact-state ingestion requires state-dependent reconciliation timestamps', () => {
  const input = reviewInput();
  const reviewRequest = requestFor(input, 'copilot');
  const mutationIdentity = {
    reviewInputKey: getReviewInputKey(input),
    channel: 'copilot',
  };
  const evidence = {
    responseReviewerMatched: false,
    requestEventMatched: false,
    requestedReviewerMatched: false,
    submittedReviewMatched: false,
    reviewRunMatched: false,
    triggerCommentMatched: false,
    readbackComplete: true,
  };
  const attemptedAt = '2026-09-04T10:00:00Z';
  const mutations = [
    reconcileReviewRequestMutation({
      ...mutationIdentity,
      response: { ok: true },
      evidence,
      attemptedAt,
      observedAt: '2026-09-04T10:01:59Z',
      attemptCount: 1,
      localRecordSucceeded: true,
    }),
    reconcileReviewRequestMutation({
      ...mutationIdentity,
      response: { ok: true },
      evidence,
      attemptedAt,
      observedAt: '2026-09-04T10:02:00Z',
      attemptCount: 1,
      localRecordSucceeded: true,
    }),
    reconcileReviewRequestMutation({
      ...mutationIdentity,
      response: { ok: true },
      evidence,
      attemptedAt,
      observedAt: '2026-09-04T10:02:00Z',
      attemptCount: 2,
      localRecordSucceeded: true,
    }),
  ];

  for (const mutation of mutations) {
    const missingAttempt = structuredClone(mutation);
    delete missingAttempt.attemptedAt;
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(compactState(input, {
        reviewRequests: [requestFor(input, 'copilot', {
          attemptCount: mutation.attemptCount,
        })],
        publicMutation: missingAttempt,
      }))),
      /must contain attemptedAt/u,
      mutation.state,
    );

    const missingReconciliation = structuredClone(mutation);
    delete missingReconciliation.reconciledAt;
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(compactState(input, {
        reviewRequests: [requestFor(input, 'copilot', {
          attemptCount: mutation.attemptCount,
        })],
        publicMutation: missingReconciliation,
      }))),
      /must contain (?:a null )?reconciledAt/u,
      mutation.state,
    );
  }

  const completedReconciliation = structuredClone(mutations[0]);
  completedReconciliation.reconciledAt = '2026-09-04T10:01:59Z';
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(compactState(input, {
      reviewRequests: [reviewRequest],
      publicMutation: completedReconciliation,
    }))),
    /must contain a null reconciledAt/u,
  );
});

test('compact-state ingestion enforces the public mutation base schema contract', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const input = reviewInput();
  const valid = compactState(input);

  assertSchemaValid(valid, schema, schema);
  assert.deepEqual(parseCompactStateJson(JSON.stringify(valid)), valid);

  const unknownStateOnly = structuredClone(valid);
  unknownStateOnly.current_task.review.publicMutation = { state: 'ALIEN' };

  const missingBooleans = structuredClone(valid);
  for (const field of [
    'nativeResponseAccepted',
    'readbackMatched',
    'retryAllowed',
    'localRecordSucceeded',
  ]) {
    delete missingBooleans.current_task.review.publicMutation[field];
  }

  const wrongBooleanTypes = structuredClone(valid);
  Object.assign(wrongBooleanTypes.current_task.review.publicMutation, {
    nativeResponseAccepted: 'false',
    readbackMatched: 0,
    retryAllowed: null,
    localRecordSucceeded: {},
  });

  const undeclaredMember = structuredClone(valid);
  undeclaredMember.current_task.review.publicMutation.unexpected = true;

  for (const [label, malformed] of [
    ['unknown state without required members', unknownStateOnly],
    ['missing required Boolean members', missingBooleans],
    ['wrong Boolean member types', wrongBooleanTypes],
    ['undeclared member', undeclaredMember],
  ]) {
    assert.throws(
      () => assertSchemaValid(malformed, schema, schema),
      undefined,
      label,
    );
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(malformed)),
      /public mutation base record is malformed/u,
      label,
    );
  }
});

test('review-request mutation state is bound to one persisted request identity', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const input = reviewInput();
  const request = requestFor(input, 'copilot');
  const noEffect = reconcileReviewRequestMutation({
    reviewInputKey: getReviewInputKey(input),
    channel: 'copilot',
    response: { ok: true },
    evidence: {
      responseReviewerMatched: false,
      requestEventMatched: false,
      requestedReviewerMatched: false,
      submittedReviewMatched: false,
      reviewRunMatched: false,
      triggerCommentMatched: false,
      readbackComplete: true,
    },
    attemptedAt: request.requestedAt,
    observedAt: '2026-09-04T10:02:00Z',
    attemptCount: 1,
    localRecordSucceeded: true,
  });
  const valid = compactState(input, {
    reviewRequests: [request],
    publicMutation: noEffect,
  });
  assertSchemaValid(valid, schema, schema);
  assert.deepEqual(parseCompactStateJson(JSON.stringify(valid)), valid);

  const missingIdentity = structuredClone(valid);
  delete missingIdentity.current_task.review.publicMutation.reviewInputKey;
  assert.throws(
    () => assertSchemaValid(missingIdentity, schema, schema),
    /reviewInputKey is required/u,
  );
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(missingIdentity)),
    /must contain its reviewed-input key and channel/u,
  );

  const noRequest = structuredClone(valid);
  noRequest.current_task.review.reviewRequests = [];
  noRequest.current_task.review.metrics.reviewerRequestsPerHead[input.head] = 0;
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(noRequest)),
    /identify exactly one persisted request/u,
  );

  const wrongChannel = structuredClone(valid);
  wrongChannel.current_task.review.publicMutation.channel = 'codex';
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(wrongChannel)),
    /identify exactly one persisted request/u,
  );

  const confirmedRequest = structuredClone(valid);
  confirmedRequest.current_task.review.reviewRequests[0].confirmed = true;
  confirmedRequest.current_task.review.reviewRequests[0].readyAt =
    confirmedRequest.current_task.review.reviewRequests[0].requestedAt;
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(confirmedRequest)),
    /unconfirmed nonterminal request/u,
  );
});

test('a no-attempt mutation rejects every attempt-only property', async () => {
  const input = reviewInput();
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const valid = state(input).publicMutation;
  const attemptMetadata = {
    attemptCount: 1,
    attemptedAt: '2026-09-04T10:00:00Z',
    reconciledAt: '2026-09-04T10:00:01Z',
    evidence: {
      responseReviewerMatched: false,
      requestEventMatched: false,
      requestedReviewerMatched: false,
      submittedReviewMatched: false,
      reviewRunMatched: false,
      triggerCommentMatched: false,
      readbackComplete: true,
    },
    reviewInputKey: getReviewInputKey(input),
    channel: 'copilot',
  };

  assertSchemaValid(valid, schema.$defs.publicMutation, schema);
  assert.doesNotThrow(
    () => parseCompactStateJson(JSON.stringify(compactState(input))),
  );

  for (const [field, value] of Object.entries(attemptMetadata)) {
    const invalid = { ...valid, [field]: value };
    assert.throws(
      () => assertSchemaValid(invalid, schema.$defs.publicMutation, schema),
      undefined,
      field,
    );
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(compactState(input, {
        publicMutation: invalid,
      }))),
      /must not contain attempt metadata/u,
      field,
    );
  }

  const combined = { ...valid, ...attemptMetadata };
  assert.throws(
    () => assertSchemaValid(combined, schema.$defs.publicMutation, schema),
  );
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(compactState(input, {
      publicMutation: combined,
    }))),
    /must not contain attempt metadata/u,
  );
});

test('public-mutation schema rejects every contradictory persisted state', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const negativeEvidence = {
    responseReviewerMatched: false,
    requestEventMatched: false,
    requestedReviewerMatched: false,
    submittedReviewMatched: false,
    reviewRunMatched: false,
    triggerCommentMatched: false,
    readbackComplete: true,
  };
  const reviewMutationBase = {
    response: { ok: true },
    evidence: negativeEvidence,
    attemptedAt: '2026-09-04T10:00:00Z',
    localRecordSucceeded: true,
    reviewInputKey: getReviewInputKey(reviewInput()),
    channel: 'copilot',
  };
  const reviewMutations = [
    reconcileReviewRequestMutation({
      ...reviewMutationBase,
      observedAt: '2026-09-04T10:01:00Z',
      attemptCount: 1,
    }),
    reconcileReviewRequestMutation({
      ...reviewMutationBase,
      observedAt: '2026-09-04T10:02:00Z',
      attemptCount: 1,
    }),
    reconcileReviewRequestMutation({
      ...reviewMutationBase,
      observedAt: '2026-09-04T10:02:00Z',
      attemptCount: 2,
    }),
    reconcileReviewRequestMutation({
      ...reviewMutationBase,
      evidence: { ...negativeEvidence, submittedReviewMatched: true },
      observedAt: '2026-09-04T10:00:01Z',
      attemptCount: 1,
    }),
  ];
  const valid = [
    state(reviewInput()).publicMutation,
    reconcilePublicMutation({
      response: { ok: true },
      readback: { id: 1 },
      expected: { id: 1 },
      localRecordSucceeded: false,
    }),
    reconcilePublicMutation({
      response: { executed: false },
      readback: { id: 2 },
      expected: { id: 1 },
      localRecordSucceeded: true,
    }),
    ...reviewMutations,
    reconcilePublicMutation({
      response: { executed: false },
      readback: { id: 1 },
      expected: { id: 1 },
      localRecordSucceeded: false,
    }),
    reconcilePublicMutation({
      response: { ok: true },
      readback: { id: 2 },
      expected: { id: 1 },
      localRecordSucceeded: true,
    }),
  ];
  for (const mutation of valid) {
    assertSchemaValid(mutation, schema.$defs.publicMutation, schema);
  }

  const contradictory = [
    { ...valid[0], nativeResponseAccepted: true },
    { ...valid[0], readbackMatched: true },
    { ...valid[0], retryAllowed: false },
    { ...valid[1], nativeResponseAccepted: false },
    { ...valid[1], readbackMatched: false },
    { ...valid[1], retryAllowed: true },
    { ...valid[2], nativeResponseAccepted: true },
    { ...valid[2], retryAllowed: false },
    { ...valid[7], retryAllowed: true },
    { ...valid[8], retryAllowed: true },
    { ...reviewMutations[0], reconciledAt: '2026-09-04T10:01:00Z' },
    {
      ...reviewMutations[0],
      evidence: { ...reviewMutations[0].evidence, requestEventMatched: true },
    },
    { ...reviewMutations[1], attemptCount: 2 },
    { ...reviewMutations[1], readbackMatched: true },
    {
      ...reviewMutations[1],
      evidence: { ...reviewMutations[1].evidence, requestEventMatched: true },
    },
    { ...reviewMutations[2], attemptCount: 1 },
    { ...reviewMutations[2], retryAllowed: true },
    { ...reviewMutations[2], evidence: undefined },
  ];
  for (const mutation of contradictory) {
    assert.throws(
      () => assertSchemaValid(mutation, schema.$defs.publicMutation, schema),
      undefined,
      JSON.stringify(mutation),
    );

    const input = reviewInput();
    const reviewRequests = mutation.evidence === undefined
      ? []
      : [requestFor(input, mutation.channel, {
        attemptCount: mutation.attemptCount,
      })];
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(compactState(input, {
        reviewRequests,
        publicMutation: mutation,
      }))),
      undefined,
      JSON.stringify(mutation),
    );
  }

  const input = reviewInput();
  const request = requestFor(input, 'copilot');
  for (const mutation of reviewMutations.slice(0, 3)) {
    const triggerMatched = {
      ...mutation,
      evidence: { ...mutation.evidence, triggerCommentMatched: true },
    };
    const persisted = compactState(input, {
      reviewRequests: [request],
      publicMutation: triggerMatched,
    });
    assert.throws(
      () => assertSchemaValid(persisted, schema, schema),
      undefined,
      triggerMatched.state,
    );
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(persisted)),
      /mutation evidence is malformed/u,
      triggerMatched.state,
    );
  }
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
    reviewedHeadObservations: [
      {
        head: HASHES.head1,
        tree: HASHES.tree1,
        observedAt: '2026-09-04T09:00:00Z',
        source: 'authenticated-pr-readback',
      },
      {
        head: HASHES.head2,
        tree: HASHES.tree2,
        observedAt: '2026-09-04T09:01:00Z',
        source: 'authenticated-pr-readback',
      },
      {
        head: '3'.repeat(40),
        tree: '4'.repeat(40),
        observedAt: '2026-09-04T09:02:00Z',
        source: 'authenticated-pr-readback',
      },
    ],
    reviewRequests: [
      { head: HASHES.head1, attemptCount: 2 },
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
  assert.equal(metrics.reviewerRequestsPerHead[HASHES.head1], 3);
  assert.equal(metrics.reviewerRequestsPerHead[HASHES.head2], 1);
  assert.equal(metrics.reviewerRequestsPerHead['3'.repeat(40)], 0);
  assert.deepEqual(metrics.reviewedHeadEvidence, {
    ['3'.repeat(40)]: {
      source: 'authenticated-pr-readback',
      tree: '4'.repeat(40),
      observedAt: '2026-09-04T09:02:00Z',
    },
  });
  assert.equal(metrics.bodyEditsAfterReviewBegan, 1);
  assert.equal(metrics.cleanReviewRecognitionMilliseconds, 5_000);
  assert.equal(metrics.cleanPairToMergeMilliseconds, 120_000);
  const invalidPersistedMetric = compactState(reviewInput());
  invalidPersistedMetric.current_task.review.metrics.reviewerRequestsPerHead = {
    undefined: 1,
  };
  assert.throws(
    () => assertSchemaValid(invalidPersistedMetric, schema, schema),
    /does not match/u,
  );
  for (const reason of [' ', '\t\r\n']) {
    const invalidReason = compactState(reviewInput());
    invalidReason.current_task.review.metrics.sameHeadRerequestReasons = [{
      reason,
      material: true,
    }];
    assert.throws(
      () => assertSchemaValid(invalidReason, schema, schema),
      /does not match pattern/u,
    );
  }
  assert.deepEqual(evaluateFindingBudget({ elapsedMinutes: 10, hasOutcome: false }), {
    warningRequired: true,
    exceptionRequired: false,
  });
  assert.deepEqual(evaluateFindingBudget({ elapsedMinutes: 15, hasOutcome: false }), {
    warningRequired: true,
    exceptionRequired: true,
  });
  assert.deepEqual(evaluateFindingBudget({ elapsedMinutes: 15, hasOutcome: true }), {
    warningRequired: false,
    exceptionRequired: false,
  });
  for (const hasOutcome of ['false', 0, null, undefined]) {
    assert.throws(
      () => evaluateFindingBudget({ elapsedMinutes: 15, hasOutcome }),
      /hasOutcome must be a Boolean/u,
    );
  }
});

test('physical request attempts drive persisted per-head metrics consistently', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const input = reviewInput();
  const request = requestFor(input, 'copilot', { attemptCount: 2 });
  const evidence = {
    responseReviewerMatched: false,
    requestEventMatched: true,
    requestedReviewerMatched: false,
    submittedReviewMatched: false,
    reviewRunMatched: false,
    triggerCommentMatched: false,
    readbackComplete: true,
  };
  const publicMutation = reconcileReviewRequestMutation({
    response: { ok: true },
    evidence,
    reviewInputKey: getReviewInputKey(input),
    channel: 'copilot',
    attemptedAt: request.requestedAt,
    observedAt: '2026-09-04T10:02:00Z',
    attemptCount: 2,
    localRecordSucceeded: true,
  });
  const valid = compactState(input, {
    reviewRequests: [request],
    publicMutation,
  });

  assert.equal(valid.current_task.review.metrics.reviewerRequestsPerHead[input.head], 2);
  assertSchemaValid(valid, schema, schema);
  assert.deepEqual(parseCompactStateJson(JSON.stringify(valid)), valid);

  const contradictory = structuredClone(valid);
  delete contradictory.current_task.review.reviewRequests[0].attemptCount;
  contradictory.current_task.review.metrics.reviewerRequestsPerHead[input.head] = 1;
  assertSchemaValid(contradictory, schema, schema);
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(contradictory)),
    /attempt count must match its persisted request/u,
  );

  for (const attemptCount of [0, 3, 1.5, '2']) {
    const invalid = compactState(input, {
      reviewRequests: [requestFor(input, 'copilot', { attemptCount })],
    });
    assert.throws(() => assertSchemaValid(invalid, schema, schema));
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(invalid)),
      /persisted review request is malformed/u,
    );
  }
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
    reviewedHeadEvidence: {},
    bodyEditsAfterReviewBegan: 0,
    sameHeadRerequestReasons: [],
    cleanReviewRecognitionMilliseconds: null,
    cleanPairToMergeMilliseconds: null,
  });
  for (const malformedRequest of [
    null,
    {},
    'unexpected',
    { head: null },
    { head: 'deadbeef' },
    { head: 'A'.repeat(40) },
    { head: 'a'.repeat(39) },
    { head: 'a'.repeat(41) },
  ]) {
    assert.throws(
      () => createMetrics({
        ...valid,
        reviewRequests: [malformedRequest],
      }),
      /reviewRequests\[0\]\.head has an invalid hash/u,
    );
  }
  for (const malformedReason of [
    'unexpected',
    {},
    { reason: '', material: true },
    { reason: ' ', material: true },
    { reason: '\t\r\n', material: true },
    { reason: 'Material risk changed.', material: 'true' },
    { reason: 'Material risk changed.', material: true, extra: true },
  ]) {
    assert.throws(
      () => createMetrics({
        ...valid,
        sameHeadRerequestReasons: [malformedReason],
      }),
      /sameHeadRerequestReasons\[0\]/u,
    );
  }
  assert.deepEqual(
    createMetrics({
      ...valid,
      sameHeadRerequestReasons: {
        reason: 'Material risk changed.',
        material: true,
      },
    }).sameHeadRerequestReasons,
    [{ reason: 'Material risk changed.', material: true }],
  );
  for (const reviewedHeadObservations of [
    [null],
    [{
      head: HASHES.head1,
      tree: HASHES.tree1,
      observedAt: '2026-09-04T09:00:00Z',
      source: 'operator-assertion',
    }],
    [{
      head: HASHES.head1,
      tree: 'invalid',
      observedAt: '2026-09-04T09:00:00Z',
      source: 'authenticated-pr-readback',
    }],
    [{
      head: HASHES.head1,
      tree: HASHES.tree1,
      observedAt: 'not-a-date',
      source: 'authenticated-pr-readback',
    }],
  ]) {
    assert.throws(
      () => createMetrics({ ...valid, reviewedHeadObservations }),
      /reviewedHeadObservations\[0\]/u,
    );
  }
  const duplicateObservation = {
    head: HASHES.head1,
    tree: HASHES.tree1,
    observedAt: '2026-09-04T09:00:00Z',
    source: 'authenticated-pr-readback',
  };
  assert.throws(
    () => createMetrics({
      ...valid,
      reviewedHeadObservations: [duplicateObservation, duplicateObservation],
    }),
    /contains a duplicate head/u,
  );
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
    '2026-09-04t10:00:00.123z',
    '2026-09-04T10:00:00.123456789Z',
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

test('an incomplete successor can be superseded by a reactivated current head', () => {
  const inputA = reviewInput();
  const inputB = reviewInput({
    head: HASHES.head2,
    tree: HASHES.tree2,
    diffSha256: HASHES.diff2,
    bodySha256: HASHES.body2,
  });
  const requestA = requestFor(inputA, 'copilot', {
    confirmed: true,
    terminal: true,
  });
  const requestB = requestFor(inputB, 'copilot', {
    requestedAt: '2026-09-04T10:02:00Z',
    confirmed: true,
    terminal: true,
    terminalResultRef: {
      kind: 'submitted-review',
      id: 'REACTIVATED_INCOMPLETE_SUCCESSOR',
      observedAt: '2026-09-04T10:03:00Z',
    },
  });
  const reactivated = compactState(inputA, {
    reviewRequests: [requestA, requestB],
    supersededReviewInputs: {
      ...supersessionFor(inputA, inputB),
      ...supersessionFor(inputB, inputA, {
        supersededAt: '2026-09-04T10:03:00Z',
      }),
    },
  });

  assert.deepEqual(parseCompactStateJson(JSON.stringify(reactivated)), reactivated);

  const unrelated = structuredClone(reactivated);
  unrelated.current_task.review.supersededReviewInputs[
    getReviewInputKey(inputB)
  ].successorHead = '3'.repeat(40);
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(unrelated)),
    /terminal incomplete prior-input pair/u,
  );

  const inputC = reviewInput({
    head: '3'.repeat(40),
    tree: '4'.repeat(40),
    diffSha256: '5'.repeat(64),
    bodySha256: '6'.repeat(64),
  });
  const driftedAfterReactivation = compactState(inputC, {
    reviewRequests: [requestA, requestB],
    supersededReviewInputs: reactivated.current_task.review.supersededReviewInputs,
  });
  assert.deepEqual(
    parseCompactStateJson(JSON.stringify(driftedAfterReactivation)),
    driftedAfterReactivation,
  );

  const unrelatedKnownHead = structuredClone(driftedAfterReactivation);
  unrelatedKnownHead.current_task.review.metrics.reviewerRequestsPerHead[
    '7'.repeat(40)
  ] = 0;
  unrelatedKnownHead.current_task.review.metrics.reviewedHeadEvidence[
    '7'.repeat(40)
  ] = {
    source: 'authenticated-pr-readback',
    tree: '8'.repeat(40),
    observedAt: '2026-09-04T10:03:30Z',
  };
  unrelatedKnownHead.current_task.review.supersededReviewInputs[
    getReviewInputKey(inputB)
  ].successorHead = '7'.repeat(40);
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(unrelatedKnownHead)),
    /terminal incomplete prior-input pair/u,
  );

  const requestedAfterReactivation = compactState(inputC, {
    reviewRequests: [
      requestA,
      requestB,
      requestFor(inputC, 'copilot', { requestedAt: '2026-09-04T10:04:00Z' }),
    ],
    supersededReviewInputs: reactivated.current_task.review.supersededReviewInputs,
  });
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(requestedAfterReactivation)),
    /terminal incomplete prior-input pair/u,
  );
});

test('RECONCILING ingestion requires its complete request and attempt identity', () => {
  const input = reviewInput();
  const request = requestFor(input, 'copilot');
  const evidence = {
    responseReviewerMatched: false,
    requestEventMatched: false,
    requestedReviewerMatched: false,
    submittedReviewMatched: false,
    reviewRunMatched: false,
    triggerCommentMatched: false,
    readbackComplete: true,
  };
  const validMutation = reconcileReviewRequestMutation({
    response: { ok: true },
    evidence,
    reviewInputKey: getReviewInputKey(input),
    channel: 'copilot',
    attemptedAt: '2026-09-04T10:00:00Z',
    observedAt: '2026-09-04T10:00:01Z',
    attemptCount: 1,
    localRecordSucceeded: true,
  });
  const valid = compactState(input, {
    reviewRequests: [request],
    publicMutation: validMutation,
  });
  assert.deepEqual(parseCompactStateJson(JSON.stringify(valid)), valid);

  const missingIdentity = structuredClone(valid);
  for (const field of ['evidence', 'reviewInputKey', 'channel', 'attemptCount']) {
    delete missingIdentity.current_task.review.publicMutation[field];
  }
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(missingIdentity)),
    /required attempt metadata/u,
  );
});

test('review attribution rejects conflicting actor aliases', () => {
  const input = reviewInput();
  const copilotRequest = requestFor(input, 'copilot', { confirmed: true });
  const codexRequest = requestFor(input, 'codex', {
    requestedAt: '2026-09-04T10:01:00Z',
  });
  const conflictingCodex = {
    node_id: 'CONFLICTING_CODEX_ACTORS',
    user: { login: 'chatgpt-codex-connector[bot]' },
    author: { login: 'attacker' },
    commit_id: input.head,
    submitted_at: '2026-09-04T10:02:00Z',
  };
  assert.deepEqual(collectCodexResults({
    submittedReviews: [conflictingCodex],
    conversationComments: [],
    reviewInput: input,
    request: codexRequest,
    reviewRequests: [copilotRequest, codexRequest],
  }), { submittedReviews: [], conversationComments: [] });

  const copilotEvidence = collectCopilotRequestEvidence({
    responseReviewers: [],
    requestEvents: [],
    requestedReviewers: [],
    submittedReviews: [{
      node_id: 'CONFLICTING_COPILOT_ACTORS',
      user: {
        login: 'copilot-pull-request-reviewer[bot]',
        slug: 'copilot-pull-request-reviewer',
      },
      author: { login: 'attacker' },
      commit_id: input.head,
      submitted_at: '2026-09-04T10:01:00Z',
    }],
    reviewRuns: [],
    baselineRequestEventIds: [],
    baselineReviewNodeIds: [],
    baselineReviewRunIds: [],
    expectedHead: input.head,
    requestedAt: '2026-09-04T10:00:00Z',
    readbackCompleteness: {
      requestEvents: true,
      requestedReviewers: true,
      submittedReviews: true,
      reviewRuns: true,
    },
  });
  assert.equal(copilotEvidence.submittedReviewMatched, false);

  const copilotMatchFor = (actorAliases) => collectCopilotRequestEvidence({
    responseReviewers: [],
    requestEvents: [],
    requestedReviewers: [],
    submittedReviews: [{
      node_id: 'AUTHENTICATED_COPILOT_ACTORS',
      user: {
        login: 'copilot-pull-request-reviewer[bot]',
        type: 'Bot',
        id: 175728472,
        node_id: 'BOT_kgDOCnlnWA',
      },
      commit_id: input.head,
      submitted_at: '2026-09-04T10:01:00Z',
      ...actorAliases,
    }],
    reviewRuns: [],
    baselineRequestEventIds: [],
    baselineReviewNodeIds: [],
    baselineReviewRunIds: [],
    expectedHead: input.head,
    requestedAt: '2026-09-04T10:00:00Z',
    readbackCompleteness: {
      requestEvents: true,
      requestedReviewers: true,
      submittedReviews: true,
      reviewRuns: true,
    },
  }).submittedReviewMatched;
  assert.equal(copilotMatchFor({
    author: {
      login: 'copilot-pull-request-reviewer',
      __typename: 'Bot',
      databaseId: 175728472,
      id: 'BOT_kgDOCnlnWA',
    },
  }), true);
  for (const actorAliases of [
    {
      author: {
        login: 'copilot-pull-request-reviewer',
        __typename: 'User',
        databaseId: 175728472,
        id: 'BOT_kgDOCnlnWA',
      },
    },
    {
      author: {
        login: 'copilot-pull-request-reviewer',
        type: 'Bot',
        __typename: 'User',
        databaseId: 175728472,
        id: 'BOT_kgDOCnlnWA',
      },
    },
    {
      actor: {
        login: 'copilot-pull-request-reviewer[bot]',
        type: 'Bot',
        database_id: 1,
        node_id: 'BOT_kgDOCnlnWA',
      },
    },
    {
      author: {
        login: 'copilot-pull-request-reviewer',
        __typename: 'Bot',
        databaseId: 175728472,
        id: 'BOT_conflicting',
      },
    },
  ]) {
    assert.equal(copilotMatchFor(actorAliases), false, JSON.stringify(actorAliases));
  }
});

test('equal-time reviewer requests preserve Copilot-before-Codex array order', () => {
  const input = reviewInput();
  const copilot = requestFor(input, 'copilot', {
    confirmed: true,
    requestedAt: '2026-09-04T10:00:00Z',
    readyAt: '2026-09-04T10:00:00Z',
  });
  const codex = requestFor(input, 'codex', {
    requestedAt: '2026-09-04T10:00:00Z',
  });
  const ordered = compactState(input, { reviewRequests: [copilot, codex] });
  assert.deepEqual(parseCompactStateJson(JSON.stringify(ordered)), ordered);

  const reversed = compactState(input, { reviewRequests: [codex, copilot] });
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(reversed)),
    /must follow its Copilot predecessor/u,
  );
  assert.deepEqual(collectCodexResults({
    submittedReviews: [],
    conversationComments: [],
    reviewInput: input,
    request: codex,
    reviewRequests: reversed.current_task.review.reviewRequests,
  }), { submittedReviews: [], conversationComments: [] });
});

test('elapsed metrics preserve exact fractions and return complete integer milliseconds', () => {
  const metrics = createMetrics({
    reviewRequests: [],
    bodyEditTimes: [],
    reviewBeganAt: '2026-09-04T04:30:00Z',
    sameHeadRerequestReasons: [],
    cleanReviewAt: '2026-09-04T10:00:00.0000000000000001+05:30',
    recognizedAt: '2026-09-04T04:30:00.0010000000000002Z',
    cleanPairAt: '2026-09-04T10:00:00.9999Z',
    mergedAt: '2026-09-04T10:00:01.0001Z',
  });

  assert.equal(metrics.cleanReviewRecognitionMilliseconds, 1);
  assert.equal(metrics.cleanPairToMergeMilliseconds, 0);
  assert.equal(Number.isInteger(metrics.cleanReviewRecognitionMilliseconds), true);
  assert.equal(Number.isInteger(metrics.cleanPairToMergeMilliseconds), true);
});

test('metrics correlate whole-second body edits at their available precision', () => {
  const metrics = createMetrics({
    reviewRequests: [],
    bodyEditTimes: [
      '2026-09-04T09:59:59Z',
      '2026-09-04T10:00:00Z',
      '2026-09-04T10:00:00.093Z',
      '2026-09-04T10:00:00.095Z',
    ],
    reviewBeganAt: '2026-09-04T10:00:00.094Z',
    sameHeadRerequestReasons: [],
    cleanReviewAt: null,
    recognizedAt: null,
    cleanPairAt: null,
    mergedAt: null,
  });

  assert.equal(metrics.bodyEditsAfterReviewBegan, 2);
});

test('reciprocal reactivation remains valid after the resumed request is appended', () => {
  const inputA = reviewInput();
  const inputB = reviewInput({
    head: HASHES.head2,
    tree: HASHES.tree2,
    diffSha256: HASHES.diff2,
    bodySha256: HASHES.body2,
  });
  const requestA = requestFor(inputA, 'copilot', {
    confirmed: true,
    terminal: true,
    terminalResultRef: {
      kind: 'submitted-review',
      id: 'RECIPROCAL_A_COPILOT',
      observedAt: '2026-09-04T10:01:00Z',
    },
  });
  const requestB = requestFor(inputB, 'copilot', {
    requestedAt: '2026-09-04T10:02:00Z',
    confirmed: true,
    terminal: true,
    terminalResultRef: {
      kind: 'submitted-review',
      id: 'RECIPROCAL_B_COPILOT',
      observedAt: '2026-09-04T10:03:00Z',
    },
  });
  const resumedA = requestFor(inputA, 'codex', {
    requestedAt: '2026-09-04T10:04:00Z',
  });
  const persisted = compactState(inputA, {
    reviewRequests: [requestA, requestB, resumedA],
    supersededReviewInputs: {
      ...supersessionFor(inputA, inputB, {
        supersededAt: '2026-09-04T10:01:30Z',
      }),
      ...supersessionFor(inputB, inputA, {
        supersededAt: '2026-09-04T10:03:30Z',
      }),
    },
  });

  assert.deepEqual(parseCompactStateJson(JSON.stringify(persisted)), persisted);
});

test('zero-request reviewed heads require authenticated retained evidence', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const inputA = reviewInput();
  const inputC = reviewInput({
    head: '3'.repeat(40),
    tree: '4'.repeat(40),
    diffSha256: '5'.repeat(64),
    bodySha256: '6'.repeat(64),
  });
  const forgedHead = 'f'.repeat(40);
  const requestA = requestFor(inputA, 'copilot', {
    confirmed: true,
    terminal: true,
  });
  const requestC = requestFor(inputC, 'copilot', {
    requestedAt: '2026-09-04T10:02:00Z',
  });
  const forged = compactState(inputC, {
    reviewRequests: [requestA, requestC],
    supersededReviewInputs: supersessionFor(inputA, inputC, {
      successorHead: forgedHead,
      supersededAt: '2026-09-04T10:01:30Z',
    }),
    metrics: {
      ...state(inputC, { reviewRequests: [requestA, requestC] }).metrics,
      reviewerRequestsPerHead: {
        [inputA.head]: 1,
        [forgedHead]: 0,
        [inputC.head]: 1,
      },
      reviewedHeadEvidence: {},
    },
  });

  assertSchemaValid(forged, schema, schema);
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(forged)),
    /requires exact authenticated retained evidence/u,
  );

  const authenticated = structuredClone(forged);
  authenticated.current_task.review.metrics.reviewedHeadEvidence[forgedHead] = {
    source: 'authenticated-pr-readback',
    tree: '7'.repeat(40),
    observedAt: '2026-09-04T10:01:15Z',
  };
  assert.deepEqual(
    parseCompactStateJson(JSON.stringify(authenticated)),
    authenticated,
  );

  const wrongSource = structuredClone(authenticated);
  wrongSource.current_task.review.metrics.reviewedHeadEvidence[forgedHead].source =
    'operator-assertion';
  assert.throws(() => assertSchemaValid(wrongSource, schema, schema));
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(wrongSource)),
    /requires exact authenticated retained evidence/u,
  );

  const wrongCurrentTree = compactState(inputC);
  wrongCurrentTree.current_task.review.metrics
    .reviewedHeadEvidence[inputC.head].tree = '8'.repeat(40);
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(wrongCurrentTree)),
    /requires exact authenticated retained evidence/u,
  );
});

test('confirmed Copilot readiness equals its authenticated reconciliation time', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const input = reviewInput();
  const request = requestFor(input, 'copilot', {
    requestedAt: '2026-09-04T10:00:00.0001Z',
    readyAt: '2026-09-04T10:00:00.0009Z',
    confirmed: true,
  });
  const publicMutation = {
    state: 'CONFIRMED',
    nativeResponseAccepted: true,
    readbackMatched: true,
    retryAllowed: false,
    localRecordSucceeded: true,
    reviewInputKey: getReviewInputKey(input),
    channel: 'copilot',
    attemptCount: 1,
    attemptedAt: '2026-09-04T10:00:00.0001Z',
    reconciledAt: '2026-09-04T10:00:00.0009Z',
    evidence: {
      responseReviewerMatched: false,
      requestEventMatched: true,
      requestedReviewerMatched: false,
      submittedReviewMatched: false,
      reviewRunMatched: false,
      triggerCommentMatched: false,
      readbackComplete: true,
    },
  };
  const valid = compactState(input, {
    reviewRequests: [request],
    publicMutation,
  });

  assertSchemaValid(valid, schema, schema);
  assert.deepEqual(parseCompactStateJson(JSON.stringify(valid)), valid);

  const missingAttemptCount = structuredClone(valid);
  delete missingAttemptCount.current_task.review.publicMutation.attemptCount;
  assert.throws(
    () => assertSchemaValid(missingAttemptCount, schema, schema),
    /is required/u,
  );
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(missingAttemptCount)),
    /attempt count must match its persisted request/u,
  );

  for (const field of ['attemptedAt', 'reconciledAt']) {
    const missingTimestamp = structuredClone(valid);
    delete missingTimestamp.current_task.review.publicMutation[field];
    assert.throws(
      () => assertSchemaValid(missingTimestamp, schema, schema),
      /is required/u,
    );
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(missingTimestamp)),
      /must contain (?:attemptedAt|reconciledAt)/u,
    );
  }

  const mismatched = structuredClone(valid);
  mismatched.current_task.review.reviewRequests[0].readyAt =
    '2026-09-04T10:00:00.0008Z';
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(mismatched)),
    /readyAt must equal its authenticated reconciliation time/u,
  );

  const incompleteReadback = structuredClone(valid);
  incompleteReadback.current_task.review.publicMutation.evidence
    .readbackComplete = false;
  assert.throws(
    () => assertSchemaValid(incompleteReadback, schema, schema),
    /does not match const/u,
  );
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(incompleteReadback)),
    /confirmed review-request mutation requires complete readback/u,
  );

  const genericConfirmedMutation = compactState(input, {
    publicMutation: {
      state: 'CONFIRMED',
      nativeResponseAccepted: true,
      readbackMatched: true,
      retryAllowed: false,
      localRecordSucceeded: true,
    },
  });
  assertSchemaValid(genericConfirmedMutation, schema, schema);
  assert.deepEqual(
    parseCompactStateJson(JSON.stringify(genericConfirmedMutation)),
    genericConfirmedMutation,
  );
});

test('confirmed Copilot and terminal dispositions require a readiness boundary', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const input = reviewInput();
  const confirmed = compactState(input, {
    reviewRequests: [requestFor(input, 'copilot', { confirmed: true })],
  });
  const nonfunctional = compactState(input, {
    reviewRequests: [requestFor(input, 'copilot', {
      terminal: true,
      terminalDisposition: nonfunctionalDisposition(),
    })],
  });
  const codex = compactState(input, {
    reviewRequests: [
      requestFor(input, 'copilot', { confirmed: true }),
      requestFor(input, 'codex', { requestedAt: '2026-09-04T10:01:00Z' }),
    ],
  });

  for (const valid of [confirmed, nonfunctional, codex]) {
    assertSchemaValid(valid, schema, schema);
    assert.deepEqual(parseCompactStateJson(JSON.stringify(valid)), valid);
  }
  assert.equal(
    Object.hasOwn(codex.current_task.review.reviewRequests[1], 'readyAt'),
    false,
  );

  for (const valid of [confirmed, nonfunctional]) {
    const missingReadyAt = structuredClone(valid);
    delete missingReadyAt.current_task.review.reviewRequests[0].readyAt;
    assert.throws(
      () => assertSchemaValid(missingReadyAt, schema, schema),
      /readyAt is required/u,
    );
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(missingReadyAt)),
      /persisted review request is malformed/u,
    );
  }

  const prematureReadyAt = compactState(input, {
    reviewRequests: [requestFor(input, 'copilot', {
      readyAt: '2026-09-04T10:00:00Z',
    })],
  });
  assert.throws(
    () => assertSchemaValid(prematureReadyAt, schema, schema),
    /does not match any allowed schema/u,
  );
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(prematureReadyAt)),
    /persisted review request is malformed/u,
  );
});

test('terminal result identities cannot be reused across reviewer channels', () => {
  const input = reviewInput();
  for (const identity of [
    { field: 'nodeId', value: 'SHARED_CROSS_CHANNEL_RESULT' },
    { field: 'id', value: 71 },
    { field: 'databaseId', value: 72 },
  ]) {
    const referenceId = String(identity.value);
    const copilot = requestFor(input, 'copilot', {
      confirmed: true,
      terminal: true,
      terminalResultRef: {
        kind: 'submitted-review',
        id: referenceId,
        observedAt: '2026-09-04T10:01:00Z',
      },
    });
    const codex = requestFor(input, 'codex', {
      requestedAt: '2026-09-04T10:02:00Z',
      confirmed: true,
      terminal: true,
      terminalResultRef: {
        kind: 'submitted-review',
        id: referenceId,
        observedAt: '2026-09-04T10:03:00Z',
      },
    });
    const result = (actor, submittedAt) => ({
      [identity.field]: identity.value,
      actor,
      commit: input.head,
      submittedAt,
    });
    const reused = compactState(input, {
      reviewRequests: [copilot, codex],
      copilotResults: {
        submittedReviews: [result(
          'copilot-pull-request-reviewer[bot]',
          '2026-09-04T10:01:00Z',
        )],
        conversationComments: [],
      },
      codexResults: {
        submittedReviews: [result(
          'chatgpt-codex-connector[bot]',
          '2026-09-04T10:03:00Z',
        )],
        conversationComments: [],
      },
    });

    assert.throws(
      () => parseCompactStateJson(JSON.stringify(reused)),
      /terminal result is assigned to multiple requests/u,
      identity.field,
    );
  }
});

test('semantic ingestion enforces the closed review-request field set', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const input = reviewInput();
  const valid = compactState(input, {
    reviewRequests: [requestFor(input, 'copilot')],
  });

  assertSchemaValid(valid, schema, schema);
  assert.deepEqual(parseCompactStateJson(JSON.stringify(valid)), valid);

  const extra = structuredClone(valid);
  extra.current_task.review.reviewRequests[0].retryAllowed = true;
  assert.throws(() => assertSchemaValid(extra, schema, schema));
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(extra)),
    /persisted review request is malformed/u,
  );

  const missing = structuredClone(valid);
  delete missing.current_task.review.reviewRequests[0].baselineReviewRunIds;
  assert.throws(() => assertSchemaValid(missing, schema, schema));
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(missing)),
    /persisted review request is malformed/u,
  );
});

test('requested-reviewer membership is diagnostic and blocks terminal negative reconciliation', async () => {
  const input = reviewInput();
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const evidence = {
    responseReviewerMatched: false,
    requestEventMatched: false,
    requestedReviewerMatched: true,
    submittedReviewMatched: false,
    reviewRunMatched: false,
    triggerCommentMatched: false,
    readbackComplete: true,
  };
  const mutationArguments = {
    response: { ok: true },
    evidence,
    reviewInputKey: getReviewInputKey(input),
    channel: 'copilot',
    attemptedAt: '2026-09-04T10:00:00Z',
    observedAt: '2026-09-04T10:00:01Z',
    attemptCount: 1,
    localRecordSucceeded: true,
  };
  const mutation = reconcileReviewRequestMutation(mutationArguments);

  assert.equal(mutation.state, 'RECONCILING');
  assert.equal(mutation.readbackMatched, false);
  assert.equal(mutation.retryAllowed, false);

  const earlyState = compactState(input, {
    reviewRequests: [requestFor(input, 'copilot')],
    publicMutation: mutation,
  });
  assertSchemaValid(earlyState, schema, schema);
  assert.deepEqual(parseCompactStateJson(JSON.stringify(earlyState)), earlyState);

  const lateMutation = reconcileReviewRequestMutation({
    ...mutationArguments,
    observedAt: '2026-09-04T10:02:01Z',
  });
  assert.equal(lateMutation.state, 'RECONCILING');
  assert.equal(lateMutation.reconciledAt, null);
  assert.equal(lateMutation.retryAllowed, false);

  const lateState = compactState(input, {
    reviewRequests: [requestFor(input, 'copilot')],
    publicMutation: lateMutation,
  });
  assertSchemaValid(lateState, schema, schema);
  assert.deepEqual(parseCompactStateJson(JSON.stringify(lateState)), lateState);

  const completeNegativeMutation = reconcileReviewRequestMutation({
    ...mutationArguments,
    evidence: { ...evidence, requestedReviewerMatched: false },
    observedAt: '2026-09-04T10:02:01Z',
  });
  assert.equal(completeNegativeMutation.state, 'NO_EFFECT');
  const completeNegativeState = compactState(input, {
    reviewRequests: [requestFor(input, 'copilot')],
    publicMutation: completeNegativeMutation,
  });
  assertSchemaValid(completeNegativeState, schema, schema);
  assert.deepEqual(
    parseCompactStateJson(JSON.stringify(completeNegativeState)),
    completeNegativeState,
  );

  const exhaustedMutation = reconcileReviewRequestMutation({
    ...mutationArguments,
    evidence: { ...evidence, requestedReviewerMatched: false },
    observedAt: '2026-09-04T10:02:01Z',
    attemptCount: 2,
  });
  assert.equal(exhaustedMutation.state, 'EXHAUSTED');

  for (const [terminalMutation, request] of [
    [completeNegativeMutation, requestFor(input, 'copilot')],
    [exhaustedMutation, requestFor(input, 'copilot', { attemptCount: 2 })],
  ]) {
    const forgedTerminalMutation = { ...terminalMutation, evidence };
    assert.throws(
      () => assertSchemaValid(
        forgedTerminalMutation,
        schema.$defs.publicMutation,
        schema,
      ),
    );
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(compactState(input, {
        reviewRequests: [request],
        publicMutation: forgedTerminalMutation,
      }))),
      /complete negative readback/u,
    );
  }
});

test('compact-state ingestion validates the complete closed metrics record', () => {
  const input = reviewInput();
  const valid = compactState(input);
  const invalidCases = [
    (metrics) => { delete metrics.bodyEditsAfterReviewBegan; },
    (metrics) => { delete metrics.reviewedHeadEvidence; },
    (metrics) => { metrics.extra = true; },
    (metrics) => { metrics.bodyEditsAfterReviewBegan = -1; },
    (metrics) => { metrics.bodyEditsAfterReviewBegan = 0.5; },
    (metrics) => { metrics.sameHeadRerequestReasons = {}; },
    (metrics) => { metrics.sameHeadRerequestReasons = [null]; },
    (metrics) => {
      metrics.sameHeadRerequestReasons = [{ reason: ' ', material: true }];
    },
    (metrics) => {
      metrics.sameHeadRerequestReasons = [{ reason: 'Material change.', material: 1 }];
    },
    (metrics) => {
      metrics.sameHeadRerequestReasons = [{
        reason: 'Material change.',
        material: true,
        extra: true,
      }];
    },
    (metrics) => { metrics.cleanReviewRecognitionMilliseconds = -1; },
    (metrics) => { metrics.cleanReviewRecognitionMilliseconds = 0.5; },
    (metrics) => { metrics.cleanPairToMergeMilliseconds = '0'; },
  ];

  for (const mutate of invalidCases) {
    const invalid = structuredClone(valid);
    mutate(invalid.current_task.review.metrics);
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(invalid)),
      /persisted .*metric|persisted same-head|reviewed-head evidence/u,
    );
  }

  const boundary = structuredClone(valid);
  boundary.current_task.review.metrics = {
    reviewerRequestsPerHead: { [input.head]: 0 },
    reviewedHeadEvidence: {
      [input.head]: {
        source: 'authenticated-pr-readback',
        tree: input.tree,
        observedAt: '2026-09-04T09:00:00Z',
      },
    },
    bodyEditsAfterReviewBegan: 0,
    sameHeadRerequestReasons: [{ reason: 'Material change.', material: false }],
    cleanReviewRecognitionMilliseconds: 0,
    cleanPairToMergeMilliseconds: 0,
  };
  assert.deepEqual(parseCompactStateJson(JSON.stringify(boundary)), boundary);
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

test('baseline identities require non-whitespace text in schema and runtime', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const input = reviewInput();
  const request = requestFor(input, 'copilot');
  const valid = compactState(input, { reviewRequests: [request] });

  assertSchemaValid(valid, schema, schema);
  assert.deepEqual(parseCompactStateJson(JSON.stringify(valid)), valid);

  for (const field of [
    'baselineRequestEventIds',
    'baselineReviewNodeIds',
    'baselineReviewRunIds',
  ]) {
    const invalid = structuredClone(valid);
    invalid.current_task.review.reviewRequests[0][field] = ['   '];
    assert.throws(
      () => assertSchemaValid(invalid, schema, schema),
      /does not match pattern/u,
    );
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(invalid)),
      /persisted review request is malformed/u,
    );
  }

  const invalidMap = structuredClone(valid);
  invalidMap.current_task.review.reviewRequests[0].baselineConversationComments = {
    '   ': '2026-09-04T09:59:00Z',
  };
  assert.throws(
    () => assertSchemaValid(invalidMap, schema, schema),
    /does not match pattern/u,
  );
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(invalidMap)),
    /persisted review request is malformed/u,
  );

  const copilotArguments = {
    responseReviewers: [],
    requestEvents: [],
    requestedReviewers: [],
    submittedReviews: [],
    reviewRuns: [],
    baselineRequestEventIds: [],
    baselineReviewNodeIds: [],
    baselineReviewRunIds: [],
    expectedHead: input.head,
    requestedAt: '2026-09-04T10:00:00Z',
    readbackCompleteness: {
      requestEvents: true,
      requestedReviewers: true,
      submittedReviews: true,
      reviewRuns: true,
    },
  };
  for (const field of [
    'baselineRequestEventIds',
    'baselineReviewNodeIds',
    'baselineReviewRunIds',
  ]) {
    assert.throws(
      () => collectCopilotRequestEvidence({
        ...copilotArguments,
        [field]: ['   '],
      }),
      /baseline must contain unique identities/u,
    );
  }
  assert.throws(
    () => collectCodexRequestEvidence({
      triggerComments: [],
      baselineConversationComments: {
        '   ': '2026-09-04T09:59:00Z',
      },
      expectedActorLogin: 'franklesniak',
      requestedAt: '2026-09-04T10:00:00Z',
      readbackComplete: true,
    }),
    /conversation-comment baseline is malformed/u,
  );
});

test('an exact first terminal failure authorizes only channel attempt two after backoff', () => {
  const input = reviewInput();
  const copilot = requestFor(input, 'copilot', {
    confirmed: true,
    terminal: true,
    requestedAt: '2026-09-04T10:00:00Z',
  });
  const failedCodex = failedCodexRequest(input);
  const persisted = state(input, {
    reviewRequests: [copilot, failedCodex],
  });
  const decide = (decisionAt, codexResults = persisted.codexResults) =>
    decideReviewRequest({
      previousReviewInput: input,
      currentReviewInput: input,
      mutationClass: 'RESULT_OR_STATE',
      existingRequests: persisted.reviewRequests,
      codexResults,
      decisionAt,
    });

  assert.equal(REVIEW_TERMINAL_FAILURE_RETRY_MILLISECONDS, 60_000);
  assert.deepEqual(REVIEW_TERMINAL_FAILURE_STATUSES, [
    'failed',
    'canceled',
    'skipped',
    'timed_out',
    'expired',
  ]);
  assert.equal(REVIEW_MAX_CHANNEL_ATTEMPTS, 3);
  assert.equal(decide('2026-09-04T10:03:00.999Z').status, 'WAIT_FOR_RETRY_BACKOFF');
  assert.deepEqual(decide('2026-09-04T10:03:01Z'), {
    status: 'REQUEST_REQUIRED',
    reviewInputKey: getReviewInputKey(input),
    channels: ['codex'],
    channelAttempt: 2,
    reason: 'Retry only the channel whose attempt 1 has one exact attributable terminal failure.',
  });
  assert.throws(
    () => decide('2026-09-04T10:03:01Z', null),
    /complete Codex result collection/u,
  );
});

test('missing, ambiguous, nonterminal, and completed evidence never authorizes a failure retry', () => {
  const input = reviewInput();
  const copilot = requestFor(input, 'copilot', { confirmed: true, terminal: true });
  const pendingCodex = requestFor(input, 'codex', {
    requestedAt: '2026-09-04T10:01:00Z',
    confirmed: true,
  });
  const pendingDecision = decideReviewRequest({
    previousReviewInput: input,
    currentReviewInput: input,
    mutationClass: 'RESULT_OR_STATE',
    existingRequests: [copilot, pendingCodex],
    decisionAt: '2026-09-04T10:10:00Z',
  });
  const completedDecision = decideReviewRequest({
    previousReviewInput: input,
    currentReviewInput: input,
    mutationClass: 'RESULT_OR_STATE',
    existingRequests: pairFor(input),
    decisionAt: '2026-09-04T10:10:00Z',
  });
  const malformedFailure = failedCodexRequest(input, {
    terminalFailureRef: terminalFailureRef({ status: 'pending' }),
  });

  assert.equal(pendingDecision.status, 'NO_REQUEST');
  assert.equal(completedDecision.status, 'NO_REQUEST');
  assert.throws(
    () => decideReviewRequest({
      previousReviewInput: input,
      currentReviewInput: input,
      mutationClass: 'RESULT_OR_STATE',
      existingRequests: [copilot, malformedFailure],
      codexResults: { submittedReviews: [], conversationComments: [] },
      decisionAt: '2026-09-04T10:10:00Z',
    }),
    /malformed or mismatched/u,
  );
});

test('attempt two preserves attempt one and requires exact fresh post-failure baselines', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const input = reviewInput();
  const copilot = requestFor(input, 'copilot', { confirmed: true, terminal: true });
  const first = failedCodexRequest(input, {
    baselineRequestEventIds: ['REQUEST_BASELINE_ONE'],
    baselineReviewNodeIds: ['REVIEW_BASELINE_ONE'],
    baselineReviewRunIds: ['RUN_BASELINE_ONE'],
    baselineConversationComments: {
      OLD_COMMENT: '2026-09-04T09:59:00Z',
    },
  });
  const second = requestFor(input, 'codex', {
    channelAttempt: 2,
    requestedAt: '2026-09-04T10:03:01Z',
    baselineCapturedAt: '2026-09-04T10:02:30Z',
    baselineRequestEventIds: ['REQUEST_BASELINE_ONE'],
    baselineReviewNodeIds: ['REVIEW_BASELINE_ONE'],
    baselineReviewRunIds: ['RUN_BASELINE_ONE'],
    baselineConversationComments: {
      OLD_COMMENT: '2026-09-04T09:59:00Z',
      CODEX_FAILURE_ONE: '2026-09-04T10:02:00Z',
      CODEX_SUMMARY: '2026-09-04T10:02:01Z',
    },
  });
  const valid = compactState(input, {
    reviewRequests: [copilot, first, second],
  });

  assertSchemaValid(valid, schema, schema);
  assert.deepEqual(parseCompactStateJson(JSON.stringify(valid)), valid);
  assert.equal(valid.current_task.review.reviewRequests[1].terminalFailureRef.status, 'failed');
  assert.equal(valid.current_task.review.reviewRequests[2].channelAttempt, 2);

  for (const mutate of [
    (candidate) => {
      delete candidate.current_task.review.reviewRequests[2]
        .baselineConversationComments.CODEX_FAILURE_ONE;
    },
    (candidate) => {
      delete candidate.current_task.review.reviewRequests[2]
        .baselineConversationComments.CODEX_SUMMARY;
    },
    (candidate) => {
      candidate.current_task.review.reviewRequests[2].baselineCapturedAt =
        '2026-09-04T10:01:59Z';
    },
    (candidate) => {
      candidate.current_task.review.reviewRequests[2].requestedAt =
        '2026-09-04T10:03:00.999Z';
    },
    (candidate) => {
      candidate.current_task.review.reviewRequests[2].baselineRequestEventIds = [];
    },
  ]) {
    const invalid = structuredClone(valid);
    mutate(invalid);
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(invalid)),
      /attempt 2|preserve every prior identity baseline/u,
    );
  }
});

test('duplicate failure evidence cannot authorize more than one retry', () => {
  const input = reviewInput();
  const requests = [
    requestFor(input, 'copilot', { confirmed: true, terminal: true }),
    failedCodexRequest(input),
  ];
  const persisted = state(input, { reviewRequests: requests });
  persisted.codexResults.conversationComments.push(
    structuredClone(persisted.codexResults.conversationComments[0]),
  );

  assert.throws(
    () => decideReviewRequest({
      previousReviewInput: input,
      currentReviewInput: input,
      mutationClass: 'RESULT_OR_STATE',
      existingRequests: requests,
      codexResults: persisted.codexResults,
      decisionAt: '2026-09-04T10:03:00Z',
    }),
    /one unique attributable terminal failure/u,
  );
});

test('a second exact terminal failure authorizes attempt three and attempt four fails closed', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const input = reviewInput();
  const copilot = requestFor(input, 'copilot', { confirmed: true, terminal: true });
  const first = failedCodexRequest(input);
  const second = failedCodexRequest(input, {
    channelAttempt: 2,
    requestedAt: '2026-09-04T10:03:01Z',
    baselineCapturedAt: '2026-09-04T10:02:30Z',
    baselineConversationComments: {
      CODEX_FAILURE_ONE: '2026-09-04T10:02:00Z',
      CODEX_SUMMARY: '2026-09-04T10:02:01Z',
    },
    terminalFailureRef: terminalFailureRef({
      id: 'CODEX_FAILURE_TWO',
      observedAt: '2026-09-04T10:04:00Z',
      summaryObservedAt: '2026-09-04T10:04:01Z',
    }),
  });
  const persisted = state(input, {
    reviewRequests: [copilot, first, second],
  });
  const decision = decideReviewRequest({
    previousReviewInput: input,
    currentReviewInput: input,
    mutationClass: 'RESULT_OR_STATE',
    existingRequests: persisted.reviewRequests,
    codexResults: persisted.codexResults,
    decisionAt: '2026-09-04T10:05:01Z',
  });

  assert.deepEqual(decision, {
    status: 'REQUEST_REQUIRED',
    reviewInputKey: getReviewInputKey(input),
    channels: ['codex'],
    channelAttempt: 3,
    reason: 'Retry only the channel whose attempt 2 has one exact attributable terminal failure.',
  });

  const third = failedCodexRequest(input, {
    channelAttempt: 3,
    requestedAt: '2026-09-04T10:05:01Z',
    baselineCapturedAt: '2026-09-04T10:04:30Z',
    baselineConversationComments: {
      CODEX_FAILURE_ONE: '2026-09-04T10:02:00Z',
      CODEX_FAILURE_TWO: '2026-09-04T10:04:00Z',
      CODEX_SUMMARY: '2026-09-04T10:04:01Z',
    },
    terminalFailureRef: terminalFailureRef({
      id: 'CODEX_FAILURE_THREE',
      observedAt: '2026-09-04T10:06:00Z',
      summaryObservedAt: '2026-09-04T10:06:01Z',
    }),
  });
  const exhausted = state(input, {
    reviewRequests: [...persisted.reviewRequests, third],
  });
  assert.equal(decideReviewRequest({
    previousReviewInput: input,
    currentReviewInput: input,
    mutationClass: 'RESULT_OR_STATE',
    existingRequests: exhausted.reviewRequests,
    codexResults: exhausted.codexResults,
    decisionAt: '2026-09-04T10:07:01Z',
  }).status, 'REVIEW_BLOCKED');

  const authorized = decideReviewRequest({
    previousReviewInput: input,
    currentReviewInput: input,
    mutationClass: 'RESULT_OR_STATE',
    existingRequests: exhausted.reviewRequests,
    codexResults: exhausted.codexResults,
    decisionAt: '2026-09-04T10:07:01Z',
    repository: 'franklesniak/PSStyleGuide',
    pullRequest: 182,
    reviewerExhaustionAuthority: reviewerExhaustionAuthority(input),
  });
  assert.equal(authorized.status, 'EXHAUSTED_NOT_CLEAN');
  assert.equal(authorized.clean, false);
  assert.equal(authorized.mayProceedToIndependentQuality, true);

  const fourth = requestFor(input, 'codex', {
    channelAttempt: 4,
    requestedAt: '2026-09-04T10:07:01Z',
  });
  const invalid = compactState(input, {
    reviewRequests: [...exhausted.reviewRequests, fourth],
    codexResults: exhausted.codexResults,
  });
  assert.throws(() => assertSchemaValid(invalid, schema, schema));
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(invalid)),
    /persisted review request is malformed/u,
  );
});

test('only the exact typed PR 182 authority makes exhausted-not-clean review merge-ready', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const input = reviewInput();
  const copilot = requestFor(input, 'copilot', { confirmed: true, terminal: true });
  const first = failedCodexRequest(input);
  const second = failedCodexRequest(input, {
    channelAttempt: 2,
    requestedAt: '2026-09-04T10:03:01Z',
    baselineCapturedAt: '2026-09-04T10:02:30Z',
    baselineConversationComments: {
      CODEX_FAILURE_ONE: '2026-09-04T10:02:00Z',
      CODEX_SUMMARY: '2026-09-04T10:02:01Z',
    },
    terminalFailureRef: terminalFailureRef({
      id: 'CODEX_FAILURE_TWO',
      observedAt: '2026-09-04T10:04:00Z',
      summaryObservedAt: '2026-09-04T10:04:01Z',
    }),
  });
  const third = failedCodexRequest(input, {
    channelAttempt: 3,
    requestedAt: '2026-09-04T10:05:01Z',
    baselineCapturedAt: '2026-09-04T10:04:30Z',
    baselineConversationComments: {
      CODEX_FAILURE_ONE: '2026-09-04T10:02:00Z',
      CODEX_FAILURE_TWO: '2026-09-04T10:04:00Z',
      CODEX_SUMMARY: '2026-09-04T10:04:01Z',
    },
    terminalFailureRef: terminalFailureRef({
      id: 'CODEX_FAILURE_THREE',
      observedAt: '2026-09-04T10:06:00Z',
      summaryObservedAt: '2026-09-04T10:06:01Z',
    }),
  });
  const authority = reviewerExhaustionAuthority(input);
  const requests = [copilot, first, second, third];
  const persisted = compactState(input, {
    reviewRequests: requests,
    reviewerExhaustionAuthority: authority,
  });
  assertSchemaValid(persisted, schema, schema);
  assert.deepEqual(parseCompactStateJson(JSON.stringify(persisted)), persisted);

  const allGates = {
    exactHeadCiClean: true,
    copilotOutcomeCleanOrAuthorized: true,
    noUnresolvedActionableFindings: true,
    independentQualityAuditPassed: true,
    exactHeadFinalValidationPassed: true,
    frozenInputAccurate: true,
    mergeable: true,
    otherRequiredGatesPassed: true,
  };
  const evaluate = (reviewState, gates = allGates, pullRequest = 182) =>
    evaluateReviewMergeReadiness({
      repository: 'franklesniak/PSStyleGuide',
      pullRequest,
      currentHead: input.head,
      currentTree: input.tree,
      reviewState,
      gates,
    });

  const ready = evaluate(persisted.current_task.review);
  assert.deepEqual(ready, {
    reviewerState: 'exhausted-not-clean',
    clean: false,
    authorizedExhaustion: true,
    mayProceedToIndependentQuality: true,
    mergeReady: true,
  });

  for (const gate of Object.keys(allGates)) {
    const result = evaluate(persisted.current_task.review, {
      ...allGates,
      [gate]: false,
    });
    assert.equal(result.reviewerState, 'exhausted-not-clean');
    assert.equal(result.clean, false);
    assert.equal(
      result.mayProceedToIndependentQuality,
      gate === 'independentQualityAuditPassed',
      `${gate} must have the correct independent-quality phase behavior`,
    );
    assert.equal(result.mergeReady, false, `${gate} must remain a merge gate`);
  }

  const unapproved = state(input, { reviewRequests: requests });
  assert.deepEqual(evaluate(unapproved), {
    reviewerState: 'exhausted-blocked',
    clean: false,
    authorizedExhaustion: false,
    mayProceedToIndependentQuality: false,
    mergeReady: false,
  });
  assert.throws(
    () => evaluate(persisted.current_task.review, allGates, 183),
    /exact, typed, input-bound, and operator-authenticated/u,
  );

  const forged = structuredClone(persisted);
  forged.current_task.review.reviewerExhaustionAuthority.reviewInputKey = 'f'.repeat(64);
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(forged)),
    /exact, typed, input-bound, and operator-authenticated/u,
  );
  const untyped = structuredClone(persisted);
  untyped.current_task.review.reviewerExhaustionAuthority.bypass = true;
  assert.throws(() => assertSchemaValid(untyped, schema, schema));
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(untyped)),
    /closed review-state contract|exact, typed/u,
  );
});

test('exhaustion authority follows the exact attempt-three failure boundary', async () => {
  const schema = JSON.parse(
    await readFile(new URL('./review-loop-policy.json', import.meta.url), 'utf8'),
  );
  const input = reviewInput();
  const copilot = requestFor(input, 'copilot', { confirmed: true, terminal: true });
  const first = failedCodexRequest(input);
  const second = failedCodexRequest(input, {
    channelAttempt: 2,
    requestedAt: '2026-09-04T10:03:01Z',
    baselineCapturedAt: '2026-09-04T10:02:30Z',
    baselineConversationComments: {
      CODEX_FAILURE_ONE: '2026-09-04T10:02:00Z',
      CODEX_SUMMARY: '2026-09-04T10:02:01Z',
    },
    terminalFailureRef: terminalFailureRef({
      id: 'CODEX_FAILURE_TWO',
      observedAt: '2026-09-04T10:04:00Z',
      summaryObservedAt: '2026-09-04T10:04:01Z',
    }),
  });
  const thirdBoundary = '2026-09-04T10:06:01.123456789Z';
  const third = failedCodexRequest(input, {
    channelAttempt: 3,
    requestedAt: '2026-09-04T10:05:01Z',
    baselineCapturedAt: '2026-09-04T10:04:30Z',
    baselineConversationComments: {
      CODEX_FAILURE_ONE: '2026-09-04T10:02:00Z',
      CODEX_FAILURE_TWO: '2026-09-04T10:04:00Z',
      CODEX_SUMMARY: '2026-09-04T10:04:01Z',
    },
    terminalFailureRef: terminalFailureRef({
      id: 'CODEX_FAILURE_THREE',
      observedAt: '2026-09-04T10:06:01.123456788Z',
      summaryObservedAt: thirdBoundary,
    }),
  });
  const requests = [copilot, first, second, third];
  const allGates = Object.fromEntries(
    [
      'exactHeadCiClean',
      'copilotOutcomeCleanOrAuthorized',
      'noUnresolvedActionableFindings',
      'independentQualityAuditPassed',
      'exactHeadFinalValidationPassed',
      'frozenInputAccurate',
      'mergeable',
      'otherRequiredGatesPassed',
    ].map((field) => [field, true]),
  );
  const evaluate = (reviewState) => evaluateReviewMergeReadiness({
    repository: 'franklesniak/PSStyleGuide',
    pullRequest: 182,
    currentHead: input.head,
    currentTree: input.tree,
    reviewState,
    gates: allGates,
  });
  const decide = (authority, requestHistory = requests) => {
    const reviewState = state(input, { reviewRequests: requestHistory });
    return decideReviewRequest({
      previousReviewInput: input,
      currentReviewInput: input,
      mutationClass: 'RESULT_OR_STATE',
      existingRequests: requestHistory,
      codexResults: reviewState.codexResults,
      decisionAt: '2026-09-04T10:07:01Z',
      repository: 'franklesniak/PSStyleGuide',
      pullRequest: 182,
      reviewerExhaustionAuthority: authority,
    });
  };

  for (const authorizedAt of [thirdBoundary, '2026-09-04T10:06:01.123456790Z']) {
    const authority = reviewerExhaustionAuthority(input, { authorizedAt });
    const persisted = compactState(input, {
      reviewRequests: requests,
      reviewerExhaustionAuthority: authority,
    });
    assertSchemaValid(persisted, schema, schema);
    assert.deepEqual(parseCompactStateJson(JSON.stringify(persisted)), persisted);
    assert.equal(decide(authority).status, 'EXHAUSTED_NOT_CLEAN');
    assert.equal(evaluate(persisted.current_task.review).authorizedExhaustion, true);
  }

  for (const authorizedAt of [
    '2026-09-04T10:00:00Z',
    '2026-09-04T10:06:01.123456788Z',
  ]) {
    const authority = reviewerExhaustionAuthority(input, { authorizedAt });
    const persisted = compactState(input, {
      reviewRequests: requests,
      reviewerExhaustionAuthority: authority,
    });
    assertSchemaValid(persisted, schema, schema);
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(persisted)),
      /must follow the exact attempt-3 terminal failure/u,
    );
    assert.throws(
      () => decide(authority),
      /must follow the exact attempt-3 terminal failure/u,
    );
    assert.throws(
      () => evaluate(persisted.current_task.review),
      /must follow the exact attempt-3 terminal failure/u,
    );
  }

  const incompleteRequests = requests.slice(0, -1);
  const authority = reviewerExhaustionAuthority(input, { authorizedAt: thirdBoundary });
  const incomplete = compactState(input, {
    reviewRequests: incompleteRequests,
    reviewerExhaustionAuthority: authority,
  });
  assertSchemaValid(incomplete, schema, schema);
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(incomplete)),
    /must follow the exact attempt-3 terminal failure/u,
  );
  assert.throws(
    () => decide(authority, incompleteRequests),
    /must follow the exact attempt-3 terminal failure/u,
  );
  assert.throws(
    () => evaluate(incomplete.current_task.review),
    /must follow the exact attempt-3 terminal failure/u,
  );
});

test('non-Codex gates control independent-quality progression after a clean reviewer pair', () => {
  const input = reviewInput();
  const copilot = requestFor(input, 'copilot', {
    confirmed: true,
    terminal: true,
  });
  const codex = requestFor(input, 'codex', {
    requestedAt: '2026-09-04T10:01:00Z',
    confirmed: true,
    terminal: true,
  });
  const reviewState = state(input, { reviewRequests: [copilot, codex] });
  const allGates = {
    exactHeadCiClean: true,
    copilotOutcomeCleanOrAuthorized: true,
    noUnresolvedActionableFindings: true,
    independentQualityAuditPassed: true,
    exactHeadFinalValidationPassed: true,
    frozenInputAccurate: true,
    mergeable: true,
    otherRequiredGatesPassed: true,
  };
  const evaluate = (gates) => evaluateReviewMergeReadiness({
    repository: 'franklesniak/PSStyleGuide',
    pullRequest: 182,
    currentHead: input.head,
    currentTree: input.tree,
    reviewState,
    gates,
  });

  assert.deepEqual(evaluate(allGates), {
    reviewerState: 'clean',
    clean: true,
    authorizedExhaustion: false,
    mayProceedToIndependentQuality: true,
    mergeReady: true,
  });
  for (const gate of Object.keys(allGates)) {
    const result = evaluate({
      ...allGates,
      [gate]: false,
    });
    assert.equal(
      result.mayProceedToIndependentQuality,
      gate === 'independentQualityAuditPassed',
      `${gate} must have the correct independent-quality phase behavior`,
    );
    assert.equal(result.mergeReady, false, `${gate} must remain a merge gate`);
  }
});

test('Codex failure ingestion requires one summary and one unique attributable detail', () => {
  const input = reviewInput();
  const copilot = requestFor(input, 'copilot', { confirmed: true, terminal: true });
  const codex = requestFor(input, 'codex', {
    requestedAt: '2026-09-04T10:01:00Z',
    confirmed: true,
    baselineConversationComments: {
      SUMMARY: '2026-09-04T10:00:00Z',
    },
  });
  const summary = {
    nodeId: 'SUMMARY',
    actor: 'chatgpt-codex-connector[bot]',
    updatedAt: '2026-09-04T10:02:01Z',
    body: '| Review | Status | Commit | Review trigger |\n' +
      '| --- | --- | --- | --- |\n' +
      `| **Code Review** | **Failed** | \`${input.head.slice(0, 7)}\` | Manual request |`,
  };
  const detail = {
    nodeId: 'CODEX_FAILURE_ONE',
    actor: 'chatgpt-codex-connector[bot]',
    createdAt: '2026-09-04T10:02:00Z',
    body: 'Codex Review: Something went wrong. Try again later.\n\nAn unknown error occurred',
  };
  const collected = collectCodexResults({
    submittedReviews: [],
    conversationComments: [summary, detail],
    reviewInput: input,
    request: codex,
    reviewRequests: [copilot, codex],
  });

  assert.deepEqual(collected.conversationComments, [{
    nodeId: 'CODEX_FAILURE_ONE',
    actor: 'chatgpt-codex-connector[bot]',
    updatedAt: '2026-09-04T10:02:00Z',
    status: 'failed',
    commitPrefix: input.head.slice(0, 7),
    terminalSummaryId: 'SUMMARY',
    terminalSummaryUpdatedAt: '2026-09-04T10:02:01Z',
  }]);
  const ambiguous = collectCodexResults({
    submittedReviews: [],
    conversationComments: [summary, detail, { ...detail, nodeId: 'SECOND_DETAIL' }],
    reviewInput: input,
    request: codex,
    reviewRequests: [copilot, codex],
  });
  assert.deepEqual(ambiguous.conversationComments, []);
});

test('terminal-failure detail and summary identities are distinct and bound before input drift', () => {
  const input = reviewInput();
  const copilot = requestFor(input, 'copilot', { confirmed: true, terminal: true });
  const sameIdentity = compactState(input, {
    reviewRequests: [
      copilot,
      failedCodexRequest(input, {
        terminalFailureRef: terminalFailureRef({ summaryId: 'CODEX_FAILURE_ONE' }),
      }),
    ],
  });
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(sameIdentity)),
    /persisted review request is malformed/u,
  );

  const successor = reviewInput({
    head: HASHES.head2,
    tree: HASHES.tree2,
    diffSha256: HASHES.diff2,
    bodySha256: HASHES.body2,
  });
  const lateSummaryFailure = failedCodexRequest(input, {
    terminalFailureRef: terminalFailureRef({
      summaryObservedAt: '2026-09-04T10:03:01Z',
    }),
  });
  const persisted = state(input, {
    reviewRequests: [
      copilot,
      lateSummaryFailure,
      requestFor(successor, 'copilot', {
        requestedAt: '2026-09-04T10:03:00Z',
      }),
    ],
  });
  assert.throws(
    () => decideReviewRequest({
      previousReviewInput: input,
      currentReviewInput: input,
      mutationClass: 'RESULT_OR_STATE',
      existingRequests: persisted.reviewRequests,
      codexResults: persisted.codexResults,
      decisionAt: '2026-09-04T10:04:30Z',
    }),
    /different-input request requires every earlier-input request to be terminal first|one unique attributable terminal failure/u,
  );
});

test('a clean Codex result cannot make an incomplete Copilot pair clean', () => {
  const input = reviewInput();
  const copilotPending = requestFor(input, 'copilot', {
    confirmed: true,
    terminal: false,
  });
  const codexClean = requestFor(input, 'codex', {
    requestedAt: '2026-09-04T10:01:00Z',
    confirmed: true,
    terminal: true,
  });
  const reviewState = state(input, {
    reviewRequests: [copilotPending, codexClean],
  });
  const result = evaluateReviewMergeReadiness({
    repository: 'franklesniak/PSStyleGuide',
    pullRequest: 182,
    currentHead: input.head,
    currentTree: input.tree,
    reviewState,
    gates: {
      exactHeadCiClean: true,
      copilotOutcomeCleanOrAuthorized: true,
      noUnresolvedActionableFindings: true,
      independentQualityAuditPassed: true,
      exactHeadFinalValidationPassed: true,
      frozenInputAccurate: true,
      mergeable: true,
      otherRequiredGatesPassed: true,
    },
  });

  assert.deepEqual(result, {
    reviewerState: 'incomplete',
    clean: false,
    authorizedExhaustion: false,
    mayProceedToIndependentQuality: false,
    mergeReady: false,
  });
});
