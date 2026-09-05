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
const PREDECESSOR_TASK_PATTERN = /^[1-9]\d{0,2}$/u;
const PREDECESSOR_OUTPUT_PATTERN = /^[A-Z][A-Z0-9_]{0,127}$/u;
const DISALLOWED_CONTROL_PATTERN = /[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/u;
const RFC3339_PATTERN = /^(?<year>\d{4})-(?<month>0[1-9]|1[0-2])-(?<day>0[1-9]|[12]\d|3[01])[Tt](?<hour>[01]\d|2[0-3]):(?<minute>[0-5]\d):(?<second>[0-5]\d)(?:\.\d+)?(?<zone>[Zz]|(?<offsetSign>[+-])(?<offsetHour>0\d|1[0-4]):(?<offsetMinute>[0-5]\d))$/u;

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

function parseRfc3339Timestamp(value, label) {
  const match = typeof value === 'string' ? RFC3339_PATTERN.exec(value) : null;
  if (match === null) {
    throw new TypeError(`${label} must be a valid timestamp in RFC 3339 format.`);
  }

  const year = Number.parseInt(match.groups.year, 10);
  const month = Number.parseInt(match.groups.month, 10);
  const day = Number.parseInt(match.groups.day, 10);
  const daysInMonth = [
    31,
    year % 4 === 0 && (year % 100 !== 0 || year % 400 === 0) ? 29 : 28,
    31,
    30,
    31,
    30,
    31,
    31,
    30,
    31,
    30,
    31,
  ];
  const offsetHour = match.groups.offsetHour === undefined
    ? 0
    : Number.parseInt(match.groups.offsetHour, 10);
  const offsetMinute = match.groups.offsetMinute === undefined
    ? 0
    : Number.parseInt(match.groups.offsetMinute, 10);
  const timestamp = Date.parse(value);

  if (
    day > daysInMonth[month - 1] ||
    (offsetHour === 14 && offsetMinute !== 0) ||
    !Number.isFinite(timestamp)
  ) {
    throw new TypeError(`${label} must be a valid timestamp in RFC 3339 format.`);
  }

  return timestamp;
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

function scanJsonWithoutDuplicateMembers(text) {
  let cursor = 0;
  const whitespace = /\s/u;
  const numberPattern = /-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?/uy;

  const skipWhitespace = () => {
    while (cursor < text.length && whitespace.test(text[cursor])) {
      cursor += 1;
    }
  };

  const readString = () => {
    const start = cursor;
    cursor += 1;
    while (cursor < text.length) {
      const character = text[cursor];
      if (character === '"') {
        cursor += 1;
        return JSON.parse(text.slice(start, cursor));
      }
      if (character === '\\') {
        cursor += 1;
        if (text[cursor] === 'u') {
          cursor += 5;
        } else {
          cursor += 1;
        }
        continue;
      }
      if (character.charCodeAt(0) < 0x20) {
        throw new SyntaxError('JSON string contains an unescaped control character.');
      }
      cursor += 1;
    }
    throw new SyntaxError('JSON string is not terminated.');
  };

  const readValue = () => {
    skipWhitespace();
    const character = text[cursor];
    if (character === '{') {
      cursor += 1;
      skipWhitespace();
      const keys = new Set();
      if (text[cursor] === '}') {
        cursor += 1;
        return;
      }
      while (cursor < text.length) {
        if (text[cursor] !== '"') {
          throw new SyntaxError('JSON object member name must be a string.');
        }
        const key = readString();
        if (keys.has(key)) {
          throw new SyntaxError(`JSON object contains duplicate member ${JSON.stringify(key)}.`);
        }
        keys.add(key);
        skipWhitespace();
        if (text[cursor] !== ':') {
          throw new SyntaxError('JSON object member is missing a colon.');
        }
        cursor += 1;
        readValue();
        skipWhitespace();
        if (text[cursor] === '}') {
          cursor += 1;
          return;
        }
        if (text[cursor] !== ',') {
          throw new SyntaxError('JSON object members must be comma separated.');
        }
        cursor += 1;
        skipWhitespace();
      }
      throw new SyntaxError('JSON object is not terminated.');
    }
    if (character === '[') {
      cursor += 1;
      skipWhitespace();
      if (text[cursor] === ']') {
        cursor += 1;
        return;
      }
      while (cursor < text.length) {
        readValue();
        skipWhitespace();
        if (text[cursor] === ']') {
          cursor += 1;
          return;
        }
        if (text[cursor] !== ',') {
          throw new SyntaxError('JSON array items must be comma separated.');
        }
        cursor += 1;
      }
      throw new SyntaxError('JSON array is not terminated.');
    }
    if (character === '"') {
      readString();
      return;
    }
    for (const literal of ['true', 'false', 'null']) {
      if (text.startsWith(literal, cursor)) {
        cursor += literal.length;
        return;
      }
    }
    numberPattern.lastIndex = cursor;
    const number = numberPattern.exec(text);
    if (number !== null) {
      cursor = numberPattern.lastIndex;
      return;
    }
    throw new SyntaxError('JSON contains an invalid value.');
  };

  readValue();
  skipWhitespace();
  if (cursor !== text.length) {
    throw new SyntaxError('JSON contains trailing content.');
  }
}

export function parseCompactStateJson(text) {
  validateTransport(text);
  scanJsonWithoutDuplicateMembers(text);
  return JSON.parse(text);
}

function validatePredecessorOutputs(predecessorOutputs) {
  if (
    predecessorOutputs === null ||
    typeof predecessorOutputs !== 'object' ||
    Array.isArray(predecessorOutputs) ||
    Object.keys(predecessorOutputs).length > 64
  ) {
    throw new TypeError('predecessorOutputs must be a bounded task-output map.');
  }

  for (const [task, outputs] of Object.entries(predecessorOutputs)) {
    const taskNumber = Number.parseInt(task, 10);
    if (
      !PREDECESSOR_TASK_PATTERN.test(task) ||
      outputs === null ||
      typeof outputs !== 'object' ||
      Array.isArray(outputs) ||
      Object.keys(outputs).length > 64
    ) {
      throw new TypeError('Each predecessor task must contain a bounded output map.');
    }
    for (const [name, record] of Object.entries(outputs)) {
      if (
        !PREDECESSOR_OUTPUT_PATTERN.test(name) ||
        record === null ||
        typeof record !== 'object' ||
        Array.isArray(record) ||
        Object.keys(record).length !== 2 ||
        !Object.hasOwn(record, 'value') ||
        !Number.isInteger(record.last_consumer_task) ||
        record.last_consumer_task <= taskNumber ||
        record.last_consumer_task > 999
      ) {
        throw new TypeError('A predecessor output record is malformed.');
      }
      const serialized = JSON.stringify(record.value);
      if (serialized === undefined || serialized.length > 65_536) {
        throw new TypeError('A predecessor output value is not bounded JSON.');
      }
    }
  }
}

export function prunePredecessorOutputs(predecessorOutputs, completedTaskNumber) {
  if (!Number.isInteger(completedTaskNumber) || completedTaskNumber < 1) {
    throw new TypeError('completedTaskNumber must be a positive integer.');
  }
  validatePredecessorOutputs(predecessorOutputs);

  const retained = {};
  for (const [task, outputs] of Object.entries(predecessorOutputs)) {
    const retainedOutputs = Object.fromEntries(
      Object.entries(outputs).filter(
        ([, record]) => record.last_consumer_task > completedTaskNumber,
      ),
    );
    if (Object.keys(retainedOutputs).length > 0) {
      retained[task] = retainedOutputs;
    }
  }
  return canonicalize(retained);
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
    'supersededReviewInputs',
    'copilotResults',
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
  supersededInputs = {},
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
  if (
    supersededInputs === null ||
    typeof supersededInputs !== 'object' ||
    Array.isArray(supersededInputs)
  ) {
    throw new TypeError('Superseded review-input dispositions must be a keyed map.');
  }
  const supersessions = Object.entries(supersededInputs).map(
    ([reviewInputKey, disposition]) => ({ ...disposition, reviewInputKey }),
  );
  if (requests.some((request) => !isReviewRequestRecord(request))) {
    throw new TypeError('A review request is malformed or mismatched.');
  }
  if (supersessions.some((disposition) => !isSupersededReviewInputRecord(disposition))) {
    throw new TypeError('A superseded review-input disposition is malformed.');
  }
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
  for (const key of new Set(requests.map((request) => request.reviewInputKey))) {
    const pair = requests.filter((request) => request.reviewInputKey === key);
    for (const channel of ['copilot', 'codex']) {
      const count = pair.filter((request) => request.channel === channel).length;
      if (count > 1) {
        throw new TypeError(`Duplicate ${channel} requests exist for the reviewed input.`);
      }
    }
  }
  const supersessionByKey = new Map();
  const knownHeads = new Set([
    currentReviewInput.head,
    ...requests.map((request) => request.head),
  ]);
  for (const disposition of supersessions) {
    const pair = requests.filter(
      (request) => request.reviewInputKey === disposition.reviewInputKey,
    );
    const channels = new Set(pair.map((request) => request.channel));
    const heads = new Set(pair.map((request) => request.head));
    if (
      pair.length === 0 ||
      channels.size === 2 ||
      heads.size !== 1 ||
      !heads.has(disposition.head) ||
      disposition.successorHead === disposition.head ||
      !knownHeads.has(disposition.successorHead) ||
      disposition.reviewInputKey === currentKey
    ) {
      throw new TypeError('A superseded disposition does not describe an incomplete old-head pair.');
    }
    supersessionByKey.set(disposition.reviewInputKey, disposition);
  }

  if (missingChannels.length === 0) {
    return Object.freeze({
      status: 'NO_REQUEST',
      reviewInputKey: currentKey,
      channels: [],
      reason: 'The required pair already exists for this reviewed input.',
    });
  }

  if (requestsForCurrentInput.length > 0) {
    return Object.freeze({
      status: 'REQUEST_REQUIRED',
      reviewInputKey: currentKey,
      channels: missingChannels,
      reason: 'Complete the review pair that already started for this reviewed input.',
    });
  }

  const priorRequests = requests.filter(
    (request) => request.reviewInputKey !== currentKey,
  );
  const priorKeys = new Set(priorRequests.map((request) => request.reviewInputKey));
  const priorPairStates = [...priorKeys].map((key) => {
    const pair = priorRequests.filter((request) => request.reviewInputKey === key);
    const channels = new Set(pair.map((request) => request.channel));
    const heads = new Set(pair.map((request) => request.head));
    const supersession = supersessionByKey.get(key);
    const missingChannel = channels.size !== 2;
    const canSupersede = missingChannel &&
      heads.size === 1 &&
      !heads.has(currentReviewInput.head);
    return {
      key,
      needsSupersession: canSupersede && supersession === undefined,
      pending: supersession === undefined &&
        (missingChannel || pair.some((request) => request.terminal !== true)),
    };
  });

  const supersessionRequired = priorPairStates
    .filter((state) => state.needsSupersession)
    .map((state) => state.key);
  if (supersessionRequired.length > 0) {
    return Object.freeze({
      status: 'SUPERSESSION_REQUIRED',
      reviewInputKey: currentKey,
      channels: [],
      supersedeReviewInputKeys: Object.freeze(supersessionRequired),
      reason: 'After authenticated head-drift readback, mark each incomplete old-head pair SUPERSEDED before requesting the new pair.',
    });
  }

  const hasPendingPriorPair = priorPairStates.some((state) => state.pending);

  if (hasPendingPriorPair) {
    return Object.freeze({
      status: 'WAIT_FOR_PRIOR_PAIR',
      reviewInputKey: currentKey,
      channels: [],
      reason: 'Every prior review pair for a different input must become terminal before another pair starts.',
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
    if (value === undefined || value === null) {
      continue;
    }

    try {
      return parseRfc3339Timestamp(value, field);
    } catch {
      return null;
    }
  }

  return null;
}

function isReviewRequestRecord(request) {
  const reviewBaselinesAreValid = Array.isArray(request?.baselineReviewNodeIds) &&
    request.baselineReviewNodeIds.every((id) => typeof id === 'string' && id.length > 0) &&
    new Set(request.baselineReviewNodeIds).size === request.baselineReviewNodeIds.length;
  const commentBaselines = request?.baselineConversationComments;
  const commentBaselinesAreValid = commentBaselines !== null &&
    typeof commentBaselines === 'object' &&
    !Array.isArray(commentBaselines) &&
    Object.keys(commentBaselines).length <= 10_000 &&
    Object.entries(commentBaselines).every(
      ([nodeId, updatedAt]) => nodeId.length > 0 &&
        nodeId.length <= 256 &&
        getItemTime({ updatedAt }, ['updatedAt']) !== null,
    );
  const channelIsValid = request?.channel === 'copilot' || request?.channel === 'codex';

  return channelIsValid &&
    typeof request.terminal === 'boolean' &&
    typeof request.head === 'string' &&
    SHA1_PATTERN.test(request.head) &&
    typeof request.reviewInputKey === 'string' &&
    SHA256_PATTERN.test(request.reviewInputKey) &&
    getItemTime(request, ['requestedAt']) !== null &&
    reviewBaselinesAreValid &&
    commentBaselinesAreValid;
}

function isSupersededReviewInputRecord(disposition) {
  return disposition !== null &&
    typeof disposition === 'object' &&
    !Array.isArray(disposition) &&
    Object.keys(disposition).length === 6 &&
    disposition.state === 'SUPERSEDED' &&
    typeof disposition.reviewInputKey === 'string' &&
    SHA256_PATTERN.test(disposition.reviewInputKey) &&
    typeof disposition.head === 'string' &&
    SHA1_PATTERN.test(disposition.head) &&
    typeof disposition.successorHead === 'string' &&
    SHA1_PATTERN.test(disposition.successorHead) &&
    getItemTime(disposition, ['supersededAt']) !== null &&
    typeof disposition.reason === 'string' &&
    disposition.reason.trim().length > 0;
}

function isReviewRequestForInput(request, reviewInput, requiredChannel = null) {
  return isReviewRequestRecord(request) &&
    (requiredChannel === null || request.channel === requiredChannel) &&
    request.head === reviewInput?.head &&
    request.reviewInputKey === getReviewInputKey(reviewInput);
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
    });
  }

  const baselineReviewIds = new Set(request.baselineReviewNodeIds);
  const baselineComments = new Map(
    Object.entries(request.baselineConversationComments).map(
      ([nodeId, updatedAt]) => [nodeId, getItemTime({ updatedAt }, ['updatedAt'])],
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

  if (response?.executed === false && nativeResponseAccepted) {
    return Object.freeze({
      state: 'AMBIGUOUS',
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
      retryAllowed: !readbackMatched,
      localRecordSucceeded: recordSucceeded,
    });
  }

  if (nativeResponseAccepted && readbackMatched) {
    return Object.freeze({
      state: 'CONFIRMED',
      nativeResponseAccepted,
      readbackMatched,
      retryAllowed: false,
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

  const reviewStart = parseRfc3339Timestamp(reviewBeganAt, 'reviewBeganAt');
  const parsedBodyEditTimes = normalizeCollection(bodyEditTimes).map(
    (time, index) => parseRfc3339Timestamp(time, `bodyEditTimes[${index}]`),
  );
  const bodyEditsAfterReviewBegan = parsedBodyEditTimes.filter(
    (time) => time > reviewStart,
  ).length;

  const elapsed = (start, end, startLabel, endLabel) => {
    if (start === null && end === null) {
      return null;
    }

    if (start === null || end === null) {
      throw new TypeError(`${startLabel} and ${endLabel} must both be null or valid timestamps.`);
    }

    const milliseconds = parseRfc3339Timestamp(end, endLabel) -
      parseRfc3339Timestamp(start, startLabel);
    if (milliseconds < 0) {
      throw new TypeError(`${endLabel} must not be earlier than ${startLabel}.`);
    }

    return milliseconds;
  };

  return Object.freeze({
    reviewerRequestsPerHead: requestsPerHead,
    bodyEditsAfterReviewBegan,
    sameHeadRerequestReasons: normalizeCollection(sameHeadRerequestReasons),
    cleanReviewRecognitionMilliseconds: elapsed(
      cleanReviewAt,
      recognizedAt,
      'cleanReviewAt',
      'recognizedAt',
    ),
    cleanPairToMergeMilliseconds: elapsed(cleanPairAt, mergedAt, 'cleanPairAt', 'mergedAt'),
  });
}
