import { createHash } from 'node:crypto';

export const MUTATION_CLASSES = Object.freeze([
  'CODE_OR_DIFF',
  'MATERIAL_SCOPE_BEHAVIOR_RISK',
  'NON_MATERIAL_FACT',
  'RESULT_OR_STATE',
  'COMMENT_ONLY',
]);

const SHA1_PATTERN = /^[0-9a-f]{40}$/u;
const SHA256_PATTERN = /^[0-9a-f]{64}$/u;
const DISALLOWED_CONTROL_PATTERN = /[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/u;

function canonicalize(value) {
  if (Array.isArray(value)) {
    return value.map(canonicalize);
  }

  if (value !== null && typeof value === 'object') {
    return Object.fromEntries(
      Object.keys(value)
        .sort()
        .map((key) => [key, canonicalize(value[key])]),
    );
  }

  return value;
}

function canonicalJson(value) {
  return JSON.stringify(canonicalize(value));
}

function assertHash(value, pattern, label) {
  if (typeof value !== 'string' || !pattern.test(value)) {
    throw new TypeError(`${label} has an invalid hash.`);
  }
}

function assertNonemptyText(value, label) {
  if (typeof value !== 'string' || value.length === 0) {
    throw new TypeError(`${label} must be non-empty text.`);
  }

  validateTransport(value);
}

export function normalizeCollection(value) {
  if (value === null || value === undefined) {
    return [];
  }

  if (Array.isArray(value)) {
    return [...value];
  }

  if (typeof value === 'object' && Object.hasOwn(value, 'nodes')) {
    return normalizeCollection(value.nodes);
  }

  if (typeof value === 'object' && Object.hasOwn(value, 'edges')) {
    return normalizeCollection(value.edges).map((edge) => edge?.node ?? edge);
  }

  return [value];
}

export function validateTransport(value) {
  if (typeof value !== 'string') {
    throw new TypeError('Transport input must be text.');
  }

  if (DISALLOWED_CONTROL_PATTERN.test(value)) {
    throw new TypeError('Transport input contains a disallowed control character.');
  }

  return value;
}

export function createReviewInput({
  head,
  tree,
  diffSha256,
  bodySha256,
  scope,
  behavior,
  risk,
}) {
  assertHash(head, SHA1_PATTERN, 'head');
  assertHash(tree, SHA1_PATTERN, 'tree');
  assertHash(diffSha256, SHA256_PATTERN, 'diffSha256');
  assertHash(bodySha256, SHA256_PATTERN, 'bodySha256');
  assertNonemptyText(scope, 'scope');
  assertNonemptyText(behavior, 'behavior');
  assertNonemptyText(risk, 'risk');

  return Object.freeze({
    head,
    tree,
    diffSha256,
    bodySha256,
    scope,
    behavior,
    risk,
  });
}

export function getReviewInputKey(reviewInput) {
  const semanticInput = {
    head: reviewInput.head,
    tree: reviewInput.tree,
    diffSha256: reviewInput.diffSha256,
    scope: reviewInput.scope,
    behavior: reviewInput.behavior,
    risk: reviewInput.risk,
  };

  return createHash('sha256').update(canonicalJson(semanticInput), 'utf8').digest('hex');
}

export function classifyMutation(previousState, currentState) {
  const previousInput = previousState.reviewInput;
  const currentInput = currentState.reviewInput;

  if (
    previousInput.head !== currentInput.head ||
    previousInput.tree !== currentInput.tree ||
    previousInput.diffSha256 !== currentInput.diffSha256
  ) {
    return 'CODE_OR_DIFF';
  }

  if (
    previousInput.scope !== currentInput.scope ||
    previousInput.behavior !== currentInput.behavior ||
    previousInput.risk !== currentInput.risk
  ) {
    return 'MATERIAL_SCOPE_BEHAVIOR_RISK';
  }

  if (previousInput.bodySha256 !== currentInput.bodySha256) {
    return 'NON_MATERIAL_FACT';
  }

  const resultOrStateFields = [
    'schemaVersion',
    'mutationClass',
    'materialReason',
    'reviewRequests',
    'codexResults',
    'publicMutation',
    'metrics',
  ];
  if (resultOrStateFields.some(
    (field) => canonicalJson(previousState[field]) !== canonicalJson(currentState[field]),
  )) {
    return 'RESULT_OR_STATE';
  }

  if (
    canonicalJson(previousState.commentPublications) !==
    canonicalJson(currentState.commentPublications)
  ) {
    return 'COMMENT_ONLY';
  }

  return null;
}

export function decideReviewRequest({
  previousReviewInput,
  currentReviewInput,
  mutationClass,
  materialReason = null,
  existingRequests = [],
}) {
  if (mutationClass !== null && !MUTATION_CLASSES.includes(mutationClass)) {
    throw new TypeError('Unknown mutation class.');
  }

  if (previousReviewInput !== null) {
    const codeChanged =
      previousReviewInput.head !== currentReviewInput.head ||
      previousReviewInput.tree !== currentReviewInput.tree ||
      previousReviewInput.diffSha256 !== currentReviewInput.diffSha256;
    const materialSemanticsChanged =
      previousReviewInput.scope !== currentReviewInput.scope ||
      previousReviewInput.behavior !== currentReviewInput.behavior ||
      previousReviewInput.risk !== currentReviewInput.risk;

    const derivedInvalidatingClass = codeChanged
      ? 'CODE_OR_DIFF'
      : materialSemanticsChanged
        ? 'MATERIAL_SCOPE_BEHAVIOR_RISK'
        : null;
    const suppliedInvalidatingClass = mutationClass === 'CODE_OR_DIFF' ||
      mutationClass === 'MATERIAL_SCOPE_BEHAVIOR_RISK'
      ? mutationClass
      : null;

    if (derivedInvalidatingClass !== suppliedInvalidatingClass) {
      throw new TypeError(
        `The supplied invalidating class ${String(suppliedInvalidatingClass)} does not match ` +
        `the derived transition ${String(derivedInvalidatingClass)}.`,
      );
    }

  }

  if (
    mutationClass === 'MATERIAL_SCOPE_BEHAVIOR_RISK' &&
    (typeof materialReason !== 'string' || materialReason.trim().length === 0)
  ) {
    throw new TypeError('A material scope, behavior, or risk change requires a reason.');
  }

  const currentKey = getReviewInputKey(currentReviewInput);
  const requests = normalizeCollection(existingRequests);
  const requestsForCurrentInput = requests.filter(
    (request) => request.reviewInputKey === currentKey,
  );
  if (requestsForCurrentInput.some(
    (request) => !isReviewRequestForInput(request, currentReviewInput),
  )) {
    throw new TypeError('A request for the reviewed input is malformed or mismatched.');
  }
  const requestedChannels = new Set(
    requestsForCurrentInput.map((request) => request.channel),
  );
  const missingChannels = ['copilot', 'codex'].filter(
    (channel) => !requestedChannels.has(channel),
  );
  for (const channel of ['copilot', 'codex']) {
    const count = requestsForCurrentInput.filter(
      (request) => request.channel === channel,
    ).length;
    if (count > 1) {
      throw new TypeError(`Duplicate ${channel} requests exist for the reviewed input.`);
    }
  }

  if (missingChannels.length === 0) {
    return Object.freeze({
      status: 'NO_REQUEST',
      reviewInputKey: currentKey,
      channels: [],
      reason: 'The required pair already exists for this reviewed input.',
    });
  }

  if (previousReviewInput === null || mutationClass === 'CODE_OR_DIFF') {
    return Object.freeze({
      status: 'REQUEST_REQUIRED',
      reviewInputKey: currentKey,
      channels: missingChannels,
      reason: previousReviewInput === null ? 'First review for this input.' : 'Code or diff changed.',
    });
  }

  if (mutationClass === 'MATERIAL_SCOPE_BEHAVIOR_RISK') {
    return Object.freeze({
      status: 'REQUEST_REQUIRED',
      reviewInputKey: currentKey,
      channels: missingChannels,
      reason: materialReason.trim(),
    });
  }

  const previousKey = getReviewInputKey(previousReviewInput);
  return Object.freeze({
    status: previousReviewInput.head === currentReviewInput.head
      ? 'REJECTED_SAME_HEAD'
      : 'NO_REQUEST',
    reviewInputKey: currentKey,
    channels: [],
    reason: previousKey === currentKey
      ? 'The reviewed input is unchanged.'
      : 'The change class does not invalidate code review.',
  });
}

function getActorLogin(item) {
  return item?.user?.login ?? item?.author?.login ?? item?.actor?.login ?? null;
}

function normalizeActorLogin(login) {
  return typeof login === 'string'
    ? login.toLowerCase().replace(/\[bot\]$/u, '')
    : null;
}

function getCommitOid(item) {
  return item?.commit_id ?? item?.commit?.oid ?? item?.commitOid ?? null;
}

function getItemId(item) {
  const id = item?.node_id ?? item?.nodeId ?? item?.id ?? item?.databaseId;
  return id === null || id === undefined ? null : String(id);
}

function getItemTime(item, fields) {
  for (const field of fields) {
    const value = item?.[field];
    if (typeof value === 'string' && Number.isFinite(Date.parse(value))) {
      return Date.parse(value);
    }
  }

  return null;
}

function isReviewRequestForInput(request, reviewInput, requiredChannel = null) {
  const reviewBaselinesAreValid = Array.isArray(request?.baselineReviewNodeIds) &&
    request.baselineReviewNodeIds.every((id) => typeof id === 'string' && id.length > 0) &&
    new Set(request.baselineReviewNodeIds).size === request.baselineReviewNodeIds.length;
  const commentBaselinesAreValid = Array.isArray(request?.baselineConversationComments) &&
    request.baselineConversationComments.every(
      (comment) => typeof comment?.nodeId === 'string' &&
        comment.nodeId.length > 0 &&
        getItemTime(comment, ['updatedAt']) !== null,
    ) &&
    new Set(request.baselineConversationComments.map((comment) => comment.nodeId)).size ===
      request.baselineConversationComments.length;
  const channelIsValid = request?.channel === 'copilot' || request?.channel === 'codex';

  return channelIsValid &&
    (requiredChannel === null || request.channel === requiredChannel) &&
    request.head === reviewInput?.head &&
    request.reviewInputKey === getReviewInputKey(reviewInput) &&
    getItemTime(request, ['requestedAt']) !== null &&
    reviewBaselinesAreValid &&
    commentBaselinesAreValid;
}

export function collectCodexResults({
  submittedReviews,
  conversationComments,
  reviewInput,
  actor = 'chatgpt-codex-connector',
  request = null,
}) {
  const head = reviewInput?.head;
  const reviewInputKey = reviewInput === null || reviewInput === undefined
    ? null
    : getReviewInputKey(reviewInput);
  const requestTime = getItemTime(request, ['requestedAt']);
  const expectedActor = normalizeActorLogin(actor);
  const requestMatches = reviewInputKey !== null &&
    isReviewRequestForInput(request, reviewInput, 'codex') &&
    expectedActor !== null &&
    requestTime !== null;
  if (!requestMatches) {
    return Object.freeze({
      submittedReviews: [],
      conversationComments: [],
      total: 0,
    });
  }

  const baselineReviewIds = new Set(request.baselineReviewNodeIds);
  const baselineComments = new Map(
    normalizeCollection(request.baselineConversationComments).map(
      (comment) => [comment.nodeId, Date.parse(comment.updatedAt)],
    ),
  );
  const reviews = normalizeCollection(submittedReviews).filter(
    (review) => {
      const id = getItemId(review);
      const submittedAt = getItemTime(review, ['submitted_at', 'submittedAt']);
      return normalizeActorLogin(getActorLogin(review)) === expectedActor &&
        getCommitOid(review) === head &&
        id !== null &&
        !baselineReviewIds.has(id) &&
        submittedAt !== null &&
        submittedAt >= requestTime;
    },
  );
  const comments = normalizeCollection(conversationComments).filter(
    (comment) => {
      if (
        normalizeActorLogin(getActorLogin(comment)) !== expectedActor ||
        comment.body?.trim() === '@codex review'
      ) {
        return false;
      }

      const explicitHead = comment.head ?? comment.headRefOid;
      if (explicitHead !== undefined && explicitHead !== head) {
        return false;
      }

      const id = getItemId(comment);
      const updatedAt = getItemTime(
        comment,
        ['updated_at', 'updatedAt', 'created_at', 'createdAt'],
      );
      if (id === null || updatedAt === null || updatedAt < requestTime) {
        return false;
      }

      const baselineTime = baselineComments.get(id);
      return baselineTime === undefined || updatedAt > baselineTime;
    },
  );

  return Object.freeze({
    submittedReviews: reviews,
    conversationComments: comments,
    total: reviews.length + comments.length,
  });
}

export function reconcilePublicMutation({
  response,
  readback,
  expected,
  localRecordSucceeded,
}) {
  const nativeResponseAccepted = response?.ok === true;
  const readbackMatched = expected !== undefined &&
    readback !== undefined &&
    canonicalJson(readback) === canonicalJson(expected);
  const recordSucceeded = Boolean(localRecordSucceeded);

  if (readbackMatched) {
    return Object.freeze({
      state: 'CONFIRMED',
      nativeResponseAccepted,
      readbackMatched,
      retryAllowed: false,
      localRecordSucceeded: recordSucceeded,
    });
  }

  if (response?.executed === false) {
    return Object.freeze({
      state: 'NOT_EXECUTED',
      nativeResponseAccepted,
      readbackMatched,
      retryAllowed: true,
      localRecordSucceeded: recordSucceeded,
    });
  }

  return Object.freeze({
    state: 'AMBIGUOUS',
    nativeResponseAccepted,
    readbackMatched,
    retryAllowed: false,
    localRecordSucceeded: recordSucceeded,
  });
}

export function evaluateFindingBudget({ elapsedMinutes, hasOutcome }) {
  if (!Number.isFinite(elapsedMinutes) || elapsedMinutes < 0) {
    throw new TypeError('elapsedMinutes must be a non-negative finite number.');
  }

  return Object.freeze({
    warningRequired: !hasOutcome && elapsedMinutes >= 10,
    exceptionRequired: !hasOutcome && elapsedMinutes >= 15,
  });
}

export function createMetrics({
  reviewRequests,
  bodyEditTimes,
  reviewBeganAt,
  sameHeadRerequestReasons,
  cleanReviewAt,
  recognizedAt,
  cleanPairAt,
  mergedAt,
}) {
  const requestsPerHead = {};
  for (const request of normalizeCollection(reviewRequests)) {
    requestsPerHead[request.head] = (requestsPerHead[request.head] ?? 0) + 1;
  }

  const reviewStart = Date.parse(reviewBeganAt);
  const bodyEditsAfterReviewBegan = normalizeCollection(bodyEditTimes).filter(
    (time) => Date.parse(time) > reviewStart,
  ).length;

  const elapsed = (start, end) => {
    if (start === null || end === null) {
      return null;
    }

    return Date.parse(end) - Date.parse(start);
  };

  return Object.freeze({
    reviewerRequestsPerHead: requestsPerHead,
    bodyEditsAfterReviewBegan,
    sameHeadRerequestReasons: normalizeCollection(sameHeadRerequestReasons),
    cleanReviewRecognitionMilliseconds: elapsed(cleanReviewAt, recognizedAt),
    cleanPairToMergeMilliseconds: elapsed(cleanPairAt, mergedAt),
  });
}
