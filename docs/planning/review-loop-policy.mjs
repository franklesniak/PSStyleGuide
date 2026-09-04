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

  if (canonicalJson(previousState.facts) !== canonicalJson(currentState.facts)) {
    return 'NON_MATERIAL_FACT';
  }

  if (canonicalJson(previousState.state) !== canonicalJson(currentState.state)) {
    return 'RESULT_OR_STATE';
  }

  if (canonicalJson(previousState.comments) !== canonicalJson(currentState.comments)) {
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

    if (codeChanged && mutationClass !== 'CODE_OR_DIFF') {
      throw new TypeError('Code or diff identity changed without the CODE_OR_DIFF class.');
    }

    if (!codeChanged && materialSemanticsChanged && mutationClass !== 'MATERIAL_SCOPE_BEHAVIOR_RISK') {
      throw new TypeError('Reviewed semantics changed without the material class.');
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
  const requestedChannels = new Set(
    requests
      .filter((request) => request.reviewInputKey === currentKey)
      .map((request) => request.channel),
  );
  const missingChannels = ['copilot', 'codex'].filter(
    (channel) => !requestedChannels.has(channel),
  );
  for (const channel of ['copilot', 'codex']) {
    const count = requests.filter(
      (request) => request.reviewInputKey === currentKey && request.channel === channel,
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

export function collectCodexResults({
  submittedReviews,
  conversationComments,
  head,
  actor = 'chatgpt-codex-connector',
  request = null,
}) {
  const reviews = normalizeCollection(submittedReviews).filter(
    (review) => getActorLogin(review) === actor && review.commit_id === head,
  );
  const comments = normalizeCollection(conversationComments).filter(
    (comment) => {
      if (getActorLogin(comment) !== actor || comment.body?.trim() === '@codex review') {
        return false;
      }

      if (comment.head !== undefined) {
        return comment.head === head;
      }

      if (request === null || request.head !== head) {
        return false;
      }

      const afterRequestId = request.commentId === undefined || comment.id > request.commentId;
      const afterRequestTime =
        request.createdAt === undefined || Date.parse(comment.created_at) >= Date.parse(request.createdAt);
      return afterRequestId && afterRequestTime;
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
  if (response?.executed === false) {
    return Object.freeze({
      state: 'NOT_EXECUTED',
      retryAllowed: true,
      localRecordSucceeded: Boolean(localRecordSucceeded),
    });
  }

  if (response?.ok === true && canonicalJson(readback) === canonicalJson(expected)) {
    return Object.freeze({
      state: 'CONFIRMED',
      retryAllowed: false,
      localRecordSucceeded: Boolean(localRecordSucceeded),
    });
  }

  return Object.freeze({
    state: 'AMBIGUOUS',
    retryAllowed: false,
    localRecordSucceeded: Boolean(localRecordSucceeded),
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
