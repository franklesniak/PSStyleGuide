import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';
import {
  MUTATION_CLASSES,
  PLAN_TASK_COUNT,
  classifyMutation,
  collectCopilotRequestEvidence,
  collectCodexResults,
  createReviewRequestSpec,
  createMetrics,
  createReviewInput,
  decideReviewRequest,
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
      bodyEditsAfterReviewBegan: 0,
      sameHeadRerequestReasons: [],
      cleanReviewRecognitionMilliseconds: null,
      cleanPairToMergeMilliseconds: null,
    },
    commentPublications: [],
    ...overrides,
  };
  if (!Object.hasOwn(overrides, 'metrics')) {
    const requestsPerHead = { [input.head]: 0 };
    for (const request of value.reviewRequests) {
      requestsPerHead[request.head] = (requestsPerHead[request.head] ?? 0) + 1;
    }
    value.metrics = {
      ...value.metrics,
      reviewerRequestsPerHead: requestsPerHead,
    };
  }
  for (const channel of ['copilot', 'codex']) {
    const field = `${channel}Results`;
    if (!Object.hasOwn(overrides, field)) {
      const results = value.reviewRequests
        .filter((request) => request.channel === channel && request.terminalResultRef)
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
  if (
    request.confirmed === true &&
    request.terminal === true &&
    !Object.hasOwn(request, 'terminalResultRef')
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

test('a reactivated superseded input resumes its original incomplete pair', () => {
  const input1 = reviewInput();
  const input2 = reviewInput({ risk: 'R2 sensitive planning change.' });
  const oldRequest = requestFor(input1, 'copilot', {
    confirmed: true,
    terminal: true,
  });
  const decision = decideReviewRequest({
    previousReviewInput: input2,
    currentReviewInput: input1,
    mutationClass: classifyMutation(state(input2), state(input1)),
    materialReason: 'The prior risk change was reverted.',
    existingRequests: [oldRequest, ...pairFor(input2)],
    supersededInputs: supersessionFor(input1, input2),
  });

  assert.equal(decision.status, 'REQUEST_REQUIRED');
  assert.deepEqual(decision.channels, ['codex']);
  assert.match(decision.reason, /already started/u);
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
  const partialCurrentPair = [requestFor(input2, 'copilot')];
  const completeCurrentPair = pairFor(input2, { terminal: false });
  const pendingPartial = decideReviewRequest({
    previousReviewInput: input1,
    currentReviewInput: input2,
    mutationClass,
    existingRequests: [...pendingOldPair, ...partialCurrentPair],
  });
  const pendingComplete = decideReviewRequest({
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

  assert.equal(pendingPartial.status, 'WAIT_FOR_PRIOR_PAIR');
  assert.deepEqual(pendingPartial.channels, []);
  assert.equal(pendingComplete.status, 'WAIT_FOR_PRIOR_PAIR');
  assert.deepEqual(pendingComplete.channels, []);
  assert.equal(terminalOld.status, 'WAIT_FOR_CURRENT_CHANNEL');
  assert.deepEqual(terminalOld.channels, []);
  assert.equal(supersededOld.status, 'WAIT_FOR_CURRENT_CHANNEL');
  assert.deepEqual(supersededOld.channels, []);
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
          app: { slug: 'copilot-pull-request-reviewer' },
          head_sha: HASHES.head1,
          created_at: '2026-09-04T10:01:00Z',
        }],
      },
    }).reviewRunMatched,
    true,
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
  const emptyEvidence = {
    responseReviewerMatched: false,
    requestEventMatched: false,
    requestedReviewerMatched: false,
    submittedReviewMatched: false,
    reviewRunMatched: false,
    readbackComplete: true,
  };
  const attemptedAt = '2026-09-04T10:00:00Z';
  const reconciling = reconcileReviewRequestMutation({
    response: { ok: true },
    evidence: emptyEvidence,
    attemptedAt,
    observedAt: '2026-09-04T10:01:59Z',
    attemptCount: 1,
    localRecordSucceeded: true,
  });
  const noEffect = reconcileReviewRequestMutation({
    response: { ok: true },
    evidence: emptyEvidence,
    attemptedAt,
    observedAt: '2026-09-04T10:02:00Z',
    attemptCount: 1,
    localRecordSucceeded: true,
  });
  const exhausted = reconcileReviewRequestMutation({
    response: { ok: true },
    evidence: emptyEvidence,
    attemptedAt,
    observedAt: '2026-09-04T10:02:00Z',
    attemptCount: 2,
    localRecordSucceeded: true,
  });
  const confirmed = reconcileReviewRequestMutation({
    response: { ok: true },
    evidence: { ...emptyEvidence, requestEventMatched: true },
    attemptedAt,
    observedAt: '2026-09-04T10:00:01Z',
    attemptCount: 1,
    localRecordSucceeded: false,
  });
  const contradictory = reconcileReviewRequestMutation({
    response: { ok: true, executed: false },
    evidence: { ...emptyEvidence, requestEventMatched: true },
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
  assert.throws(
    () => reconcileReviewRequestMutation({
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
    assert.match(task.body, /Do not (?:send|post)[^\n]*(?:Codex trigger|@codex review)/u);
    assert.match(
      task.body,
      /terminally proved non-functional through a persisted `terminalDisposition` whose state is `REPOSITORY_AUTHORIZED_NON_FUNCTIONAL`/u,
    );
    assert.doesNotMatch(
      task.body,
      /result for the round only when it is newer than the applicable baseline and is explicitly anchored to the recorded PR head SHA/u,
    );
  }

  assert.equal(
    [...plan.matchAll(/Count a submitted-review result for the round only when its commit matches the recorded PR head SHA and it is newer than the applicable baseline\./gu)].length,
    38,
  );
  assert.match(
    plan,
    /Persist the unique request-event, review-run, submitted-review, and conversation-comment baselines with the in-flight attempt\./u,
  );
  assert.equal(
    [...plan.matchAll(/Count a headless Codex PR-conversation result only when the authenticated author, request time, baseline exclusion, reviewed-input key, and serialized predecessor-pair order attribute it to this round\./gu)].length,
    38,
  );
  assert.match(plan, /closed `terminalResultRef`/u);
  assert.match(plan, /next different-input request boundary/u);
  assert.match(plan, /including a head that received zero requests/u);

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
  assert.match(parent, /copilot-pull-request-reviewer\[bot\]/u);
  assert.match(parent, /A second proved no-effect attempt is `EXHAUSTED`/u);
  assert.match(parent, /including drift on an unchanged head/u);
  assert.match(
    parent,
    /unique request-event, review-run, submitted-review, and node-ID-to-timestamp conversation-comment baselines/u,
  );
  assert.match(
    parent,
    /confirmed or is terminally proved non-functional through a persisted `terminalDisposition`/u,
  );
  assert.match(parent, /persist its head, reviewed-input key, request time, `confirmed: true`, and nonterminal state/u);
  assert.match(parent, /closed `terminalResultRef`/u);
  assert.match(parent, /wrong-channel, or wrong-time reference/u);
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
  assert.match(alternate, /A second proved no-effect attempt is `EXHAUSTED`/u);
  assert.match(alternate, /including drift on an unchanged head/u);
  assert.match(
    alternate,
    /unique request-event, review-run, submitted-review, and node-ID-to-timestamp conversation-comment baselines/u,
  );
  assert.match(
    alternate,
    /confirmed or is terminally proved non-functional through a persisted `terminalDisposition`/u,
  );
  assert.match(alternate, /persist its head, reviewed-input key, request time, `confirmed: true`, and nonterminal state/u);
  assert.match(alternate, /closed `terminalResultRef`/u);
  assert.match(alternate, /next different-input request boundary/u);
  assert.match(alternate, /known successor identities for retained supersessions/u);
  assert.match(alternate, /Locate and obey the applicable `AGENTS\.md`/u);
  assert.match(
    alternate,
    /If no `AGENTS\.md` applies, read the repository root `CLAUDE\.md` as compatibility workflow instructions; the filename does not change the executor/u,
  );
  assert.match(generator, /Do not split routine work/u);
  assert.match(generator, /Default to one reviewer pair/u);
  assert.match(generator, /immutable predecessor outputs/u);
  assert.match(generator, /typed `SUPERSEDED` disposition/u);
  assert.match(generator, /absolute value exceeds 9007199254740991/u);
  assert.match(generator, /current task head to equal the review-input head/u);
  assert.match(generator, /only after every recorded request for the old input is terminal/u);
  assert.match(generator, /headless Codex PR-conversation result/u);
  assert.match(generator, /closed `terminalResultRef`/u);
  assert.match(generator, /including a head that received zero requests/u);
  assert.match(generator, /copilot-pull-request-reviewer\[bot\]/u);
  assert.match(generator, /a second proved no-effect attempt is `EXHAUSTED`/iu);
  assert.match(crossRepository, /Reject non-finite or out-of-portable-range JSON numbers/u);
  assert.match(crossRepository, /task head and review-input head differ/u);
  assert.match(crossRepository, /closed `terminalResultRef`/u);
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
  assert.deepEqual(parseCompactStateJson(unique), {
    baselineConversationComments: {
      COMMENT_OLD: '2026-09-04T09:59:00Z',
    },
  });
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
      terminalDisposition: nonfunctionalDisposition(),
    })],
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
    /terminalResultRef is required/u,
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

  for (const mutate of [
    (candidate) => {
      candidate.current_task.review.copilotResults.submittedReviews[0].actor =
        'untrusted-reviewer[bot]';
    },
    (candidate) => {
      candidate.current_task.review.copilotResults.submittedReviews[0].commit = HASHES.head2;
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

  for (const mutate of [
    (candidate) => {
      delete candidate.current_task.review.codexResults.conversationComments[0].status;
    },
    (candidate) => {
      candidate.current_task.review.codexResults.conversationComments[0].status = 'in-progress';
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
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(afterDifferentInputBoundary)),
    /one attributable terminal result/u,
  );

  const duplicatedReference = compactState(input2, {
    mutationClass: 'CODE_OR_DIFF',
    reviewRequests: [
      copilotRequest,
      requestFor(input2, 'copilot', {
        confirmed: true,
        terminal: true,
        terminalResultRef: structuredClone(copilotRequest.terminalResultRef),
      }),
    ],
  });
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(duplicatedReference)),
    /assigned to multiple requests/u,
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

  assert.deepEqual(parseCompactStateJson(JSON.stringify(valid)), valid);
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
    },
  });

  assertSchemaValid(secondDrift, schema, schema);
  assert.deepEqual(parseCompactStateJson(JSON.stringify(secondDrift)), secondDrift);

  const missingIntermediate = structuredClone(secondDrift);
  delete missingIntermediate.current_task.review.metrics
    .reviewerRequestsPerHead[input2.head];
  assert.throws(
    () => parseCompactStateJson(JSON.stringify(missingIntermediate)),
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

test('compact-state ingestion binds the review input to the current task head', () => {
  const input = reviewInput();
  const mismatched = compactState(input, {}, { head: HASHES.head2 });

  assert.throws(
    () => parseCompactStateJson(JSON.stringify(mismatched)),
    /review input must match the current task head/u,
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
  for (const numericToken of ['9007199254740993', '1e400', '-1e400']) {
    assert.throws(
      () => parseCompactStateJson(rawState(numericToken)),
      /portable safe-integer magnitude/u,
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
  assert.deepEqual(parseCompactStateJson(JSON.stringify(distinctInputs)), distinctInputs);
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
  const negativeEvidence = {
    responseReviewerMatched: false,
    requestEventMatched: false,
    requestedReviewerMatched: false,
    submittedReviewMatched: false,
    reviewRunMatched: false,
    readbackComplete: true,
  };
  const invalidInterval = compactState(input, {
    publicMutation: {
      state: 'NO_EFFECT',
      nativeResponseAccepted: true,
      readbackMatched: false,
      retryAllowed: true,
      localRecordSucceeded: true,
      attemptCount: 1,
      attemptedAt: '2026-09-04T10:02:00Z',
      reconciledAt: '2026-09-04T10:02:00Z',
      evidence: negativeEvidence,
    },
  });
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
  const evidence = {
    responseReviewerMatched: false,
    requestEventMatched: false,
    requestedReviewerMatched: false,
    submittedReviewMatched: false,
    reviewRunMatched: false,
    readbackComplete: true,
  };
  const attemptedAt = '2026-09-04T10:00:00Z';
  const mutations = [
    reconcileReviewRequestMutation({
      response: { ok: true },
      evidence,
      attemptedAt,
      observedAt: '2026-09-04T10:01:59Z',
      attemptCount: 1,
      localRecordSucceeded: true,
    }),
    reconcileReviewRequestMutation({
      response: { ok: true },
      evidence,
      attemptedAt,
      observedAt: '2026-09-04T10:02:00Z',
      attemptCount: 1,
      localRecordSucceeded: true,
    }),
    reconcileReviewRequestMutation({
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
        publicMutation: missingAttempt,
      }))),
      /must contain attemptedAt/u,
      mutation.state,
    );

    const missingReconciliation = structuredClone(mutation);
    delete missingReconciliation.reconciledAt;
    assert.throws(
      () => parseCompactStateJson(JSON.stringify(compactState(input, {
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
      publicMutation: completedReconciliation,
    }))),
    /must contain a null reconciledAt/u,
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
      readbackComplete: true,
    },
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
    readbackComplete: true,
  };
  const reviewMutationBase = {
    response: { ok: true },
    evidence: negativeEvidence,
    attemptedAt: '2026-09-04T10:00:00Z',
    localRecordSucceeded: true,
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
    reviewedHeads: [HASHES.head1, HASHES.head2, '3'.repeat(40)],
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
  assert.equal(metrics.reviewerRequestsPerHead['3'.repeat(40)], 0);
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
