import { createHash } from 'node:crypto';

export const MUTATION_CLASSES = Object.freeze([
  'CODE_OR_DIFF',
  'MATERIAL_SCOPE_BEHAVIOR_RISK',
  'NON_MATERIAL_FACT',
  'RESULT_OR_STATE',
  'COMMENT_ONLY',
]);

export const REVIEW_REQUEST_SPECS = Object.freeze({
  copilot: Object.freeze({
    channel: 'copilot',
    method: 'POST',
    transport: 'rest-review-request',
    reviewerLogin: 'copilot-pull-request-reviewer[bot]',
    payload: Object.freeze({
      reviewers: Object.freeze(['copilot-pull-request-reviewer[bot]']),
    }),
  }),
  codex: Object.freeze({
    body: '@codex review',
    channel: 'codex',
    method: 'POST',
    transport: 'rest-issue-comment',
  }),
});

export const REVIEW_REQUEST_RECONCILIATION_MILLISECONDS = 120_000;
export const PLAN_TASK_COUNT = 402;
export const REVIEW_LOOP_TASK_NUMBERS = Object.freeze([
  6, 15, 25, 34, 45, 54, 63, 74, 83, 92, 101, 110, 119, 130,
  139, 148, 158, 167, 176, 186, 195, 204, 216, 227, 237, 246,
  255, 264, 273, 282, 291, 300, 309, 317, 328, 337, 346, 355,
  364, 373, 385, 396,
]);

const SHA1_PATTERN = /^[0-9a-f]{40}$/u;
const SHA256_PATTERN = /^[0-9a-f]{64}$/u;
const PREDECESSOR_TASK_PATTERN = /^[1-9]\d{0,2}$/u;
const PREDECESSOR_OUTPUT_PATTERN = /^[A-Z][A-Z0-9_]{0,127}$/u;
const DISALLOWED_CONTROL_PATTERN = /[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]/u;
const RFC3339_PATTERN = /^(?<year>\d{4})-(?<month>0[1-9]|1[0-2])-(?<day>0[1-9]|[12]\d|3[01])[Tt](?<hour>[01]\d|2[0-3]):(?<minute>[0-5]\d):(?<second>[0-5]\d)(?:\.\d+)?(?<zone>[Zz]|(?<offsetSign>[+-])(?<offsetHour>0\d|1[0-4]):(?<offsetMinute>[0-5]\d))$/u;
const REVIEW_LOOP_TASK_NUMBER_SET = new Set(REVIEW_LOOP_TASK_NUMBERS);
const PUBLIC_MUTATION_STATES = new Set([
  'NOT_ATTEMPTED',
  'NOT_EXECUTED',
  'RECONCILING',
  'NO_EFFECT',
  'EXHAUSTED',
  'AMBIGUOUS',
  'CONFIRMED',
]);
const PUBLIC_MUTATION_REQUIRED_FIELDS = new Set([
  'state',
  'nativeResponseAccepted',
  'readbackMatched',
  'retryAllowed',
  'localRecordSucceeded',
]);
const PUBLIC_MUTATION_ALLOWED_FIELDS = new Set([
  ...PUBLIC_MUTATION_REQUIRED_FIELDS,
  'reviewInputKey',
  'channel',
  'attemptCount',
  'attemptedAt',
  'reconciledAt',
  'evidence',
]);
const PUBLIC_MUTATION_BOOLEAN_FIELDS = Object.freeze([
  'nativeResponseAccepted',
  'readbackMatched',
  'retryAllowed',
  'localRecordSucceeded',
]);

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
  if (typeof value !== 'string' || value.trim().length === 0) {
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

  if (typeof value === 'object' && Object.hasOwn(value, 'check_runs')) {
    return normalizeCollection(value.check_runs);
  }

  if (typeof value === 'object' && Object.hasOwn(value, 'workflow_runs')) {
    return normalizeCollection(value.workflow_runs);
  }

  return [value];
}

export function createReviewRequestSpec(channel) {
  const spec = REVIEW_REQUEST_SPECS[channel];
  if (spec === undefined) {
    throw new TypeError('Review channel must be copilot or codex.');
  }

  if (channel === 'copilot') {
    return Object.freeze({
      ...spec,
      payload: Object.freeze({
        reviewers: Object.freeze([...spec.payload.reviewers]),
      }),
    });
  }

  return Object.freeze({ ...spec });
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
        const decoded = JSON.parse(text.slice(start, cursor));
        validateTransport(decoded);
        return decoded;
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
      const numericValue = Number(number[0]);
      if (
        !Number.isFinite(numericValue) ||
        Math.abs(numericValue) > Number.MAX_SAFE_INTEGER
      ) {
        throw new TypeError(
          'JSON numbers must be finite and within the portable safe-integer magnitude; ' +
          'encode larger exact values as strings.',
        );
      }
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
  const parsed = JSON.parse(text);

  if (
    parsed !== null &&
    typeof parsed === 'object' &&
    !Array.isArray(parsed) &&
    Object.hasOwn(parsed, 'predecessor_outputs') &&
    Object.hasOwn(parsed, 'current_task')
  ) {
    const completedTaskNumber = validatePersistedProgress(
      parsed.current_task,
      parsed.completed,
    );
    validatePredecessorOutputs(parsed.predecessor_outputs, completedTaskNumber);
    if (
      REVIEW_LOOP_TASK_NUMBER_SET.has(parsed.current_task?.number) &&
      parsed.current_task?.state !== 'pending' &&
      parsed.current_task?.review === undefined
    ) {
      throw new TypeError(
        'An active fixed-plan review-loop task must contain persisted review state.',
      );
    }
    if (parsed.current_task?.review !== undefined) {
      const reviewState = parsed.current_task.review;
      if (
        typeof parsed.current_task.head !== 'string' ||
        parsed.current_task.head !== reviewState.reviewInput?.head
      ) {
        throw new TypeError('The persisted review input must match the current task head.');
      }
      const requests = validatePersistedReviewRequests(
        reviewState.reviewRequests,
        reviewState,
      );
      validatePersistedPublicMutation(reviewState.publicMutation, requests);
      const supersessions = validatePersistedSupersededReviewInputs(
        reviewState.supersededReviewInputs,
      );
      const reviewedHeads = validatePersistedRequestMetrics(
        reviewState.metrics,
        requests,
        reviewState.reviewInput.head,
      );
      validateSupersessionsAgainstRequests({
        requests,
        supersessions,
        knownHeads: new Set([
          reviewState.reviewInput.head,
          ...requests.map((request) => request.head),
          ...reviewedHeads,
        ]),
        currentKey: getReviewInputKey(reviewState.reviewInput),
      });
    }
  }

  return parsed;
}

function validatePersistedProgress(currentTask, completed) {
  const currentTaskNumber = currentTask?.number;
  if (
    !Number.isInteger(currentTaskNumber) ||
    currentTaskNumber < 1 ||
    currentTaskNumber > PLAN_TASK_COUNT ||
    !Array.isArray(completed)
  ) {
    throw new TypeError('The persisted task progress is malformed or outside the plan.');
  }

  const lastCompletedTask = currentTask?.state === 'complete'
    ? currentTaskNumber
    : currentTaskNumber - 1;
  if (
    completed.length !== lastCompletedTask ||
    completed.some((taskNumber, index) => taskNumber !== index + 1)
  ) {
    throw new TypeError('Completed tasks must be the contiguous predecessors of the current task.');
  }

  return lastCompletedTask;
}

function validatePersistedReviewRequests(reviewRequests, reviewState) {
  if (!Array.isArray(reviewRequests)) {
    throw new TypeError('The persisted review-request collection is malformed.');
  }

  const seenRequests = new Set();
  for (const request of reviewRequests) {
    if (!isReviewRequestRecord(request)) {
      throw new TypeError('A persisted review request is malformed.');
    }
    const requestIdentity = `${request.reviewInputKey}:${request.channel}`;
    if (seenRequests.has(requestIdentity)) {
      throw new TypeError('A duplicate reviewed-input and channel request is persisted.');
    }
    seenRequests.add(requestIdentity);
  }

  validateReviewRequestOrdering(reviewRequests, { enforceGlobalSerialization: true });
  validateTerminalResultReferences(reviewRequests, reviewState);
  return reviewRequests;
}

function validatePersistedRequestMetrics(metrics, requests, currentHead) {
  const requestsPerHead = metrics?.reviewerRequestsPerHead;
  if (
    requestsPerHead === null ||
    typeof requestsPerHead !== 'object' ||
    Array.isArray(requestsPerHead)
  ) {
    throw new TypeError('The persisted request-per-head metric is malformed.');
  }

  const actualCounts = new Map();
  for (const request of requests) {
    actualCounts.set(request.head, (actualCounts.get(request.head) ?? 0) + 1);
  }
  const entries = Object.entries(requestsPerHead);
  if (entries.some(
    ([head, count]) => !SHA1_PATTERN.test(head) || !Number.isInteger(count) || count < 0,
  )) {
    throw new TypeError('The persisted request-per-head metric is malformed.');
  }
  if (!Object.hasOwn(requestsPerHead, currentHead)) {
    throw new TypeError('The current reviewed head is missing from the request metric.');
  }
  for (const [head, count] of entries) {
    if (count !== (actualCounts.get(head) ?? 0)) {
      throw new TypeError('A persisted request count does not match the request history.');
    }
  }
  for (const head of actualCounts.keys()) {
    if (!Object.hasOwn(requestsPerHead, head)) {
      throw new TypeError('A request head is missing from the request metric.');
    }
  }

  return entries.map(([head]) => head);
}

function validatePersistedSupersededReviewInputs(supersededReviewInputs) {
  if (
    supersededReviewInputs === null ||
    typeof supersededReviewInputs !== 'object' ||
    Array.isArray(supersededReviewInputs) ||
    Object.keys(supersededReviewInputs).length > 64
  ) {
    throw new TypeError('The persisted superseded review-input collection is malformed.');
  }

  const dispositions = Object.entries(supersededReviewInputs).map(
    ([reviewInputKey, disposition]) => ({ ...disposition, reviewInputKey }),
  );
  if (dispositions.some((disposition) => !isSupersededReviewInputRecord(disposition))) {
    throw new TypeError('A persisted superseded review-input disposition is malformed.');
  }
  return dispositions;
}

function validatePersistedPublicMutation(publicMutation, requests) {
  if (
    publicMutation === null ||
    typeof publicMutation !== 'object' ||
    Array.isArray(publicMutation)
  ) {
    throw new TypeError('The persisted public mutation is malformed.');
  }

  const publicMutationFields = Object.keys(publicMutation);
  if (
    [...PUBLIC_MUTATION_REQUIRED_FIELDS]
      .some((field) => !Object.hasOwn(publicMutation, field)) ||
    publicMutationFields.some((field) => !PUBLIC_MUTATION_ALLOWED_FIELDS.has(field)) ||
    !PUBLIC_MUTATION_STATES.has(publicMutation.state) ||
    PUBLIC_MUTATION_BOOLEAN_FIELDS
      .some((field) => typeof publicMutation[field] !== 'boolean')
  ) {
    throw new TypeError('The persisted public mutation base record is malformed.');
  }

  const attemptMetadataFields = [
    'attemptCount',
    'attemptedAt',
    'reconciledAt',
    'evidence',
    'reviewInputKey',
    'channel',
  ];
  if (
    publicMutation.state === 'NOT_ATTEMPTED' &&
    attemptMetadataFields.some((field) => Object.hasOwn(publicMutation, field))
  ) {
    throw new TypeError('A NOT_ATTEMPTED mutation must not contain attempt metadata.');
  }

  const hasEvidence = Object.hasOwn(publicMutation, 'evidence');
  const hasReviewInputKey = Object.hasOwn(publicMutation, 'reviewInputKey');
  const hasChannel = Object.hasOwn(publicMutation, 'channel');
  if (
    hasEvidence !== (hasReviewInputKey && hasChannel) ||
    (!hasEvidence && (hasReviewInputKey || hasChannel))
  ) {
    throw new TypeError(
      'A review-request mutation must contain its reviewed-input key and channel.',
    );
  }

  let matchingRequest = null;
  if (hasEvidence) {
    if (
      typeof publicMutation.reviewInputKey !== 'string' ||
      !SHA256_PATTERN.test(publicMutation.reviewInputKey) ||
      !['copilot', 'codex'].includes(publicMutation.channel)
    ) {
      throw new TypeError('A review-request mutation identity is malformed.');
    }
    const matches = requests.filter(
      (request) => request.reviewInputKey === publicMutation.reviewInputKey &&
        request.channel === publicMutation.channel,
    );
    if (matches.length !== 1) {
      throw new TypeError(
        'A review-request mutation must identify exactly one persisted request.',
      );
    }
    [matchingRequest] = matches;
    if (
      publicMutation.state === 'NO_EFFECT' &&
      (matchingRequest.confirmed === true || matchingRequest.terminal === true)
    ) {
      throw new TypeError(
        'A retry-eligible no-effect mutation must identify one unconfirmed nonterminal request.',
      );
    }
  }

  const attemptedAt = publicMutation.attemptedAt;
  const reconciledAt = publicMutation.reconciledAt;
  const requiresAttemptedAt = [
    'RECONCILING',
    'NO_EFFECT',
    'EXHAUSTED',
  ].includes(publicMutation.state);
  if (requiresAttemptedAt && (attemptedAt === undefined || attemptedAt === null)) {
    throw new TypeError(`A persisted ${publicMutation.state} mutation must contain attemptedAt.`);
  }
  if (publicMutation.state === 'RECONCILING' && reconciledAt !== null) {
    throw new TypeError('A persisted RECONCILING mutation must contain a null reconciledAt.');
  }
  if (
    (publicMutation.state === 'NO_EFFECT' || publicMutation.state === 'EXHAUSTED') &&
    (reconciledAt === undefined || reconciledAt === null)
  ) {
    throw new TypeError(`A persisted ${publicMutation.state} mutation must contain reconciledAt.`);
  }
  if (attemptedAt === undefined || attemptedAt === null) {
    return;
  }

  const attemptedTime = parseRfc3339Timestamp(attemptedAt, 'attemptedAt');
  if (
    matchingRequest !== null &&
    attemptedTime < parseRfc3339Timestamp(matchingRequest.requestedAt, 'requestedAt')
  ) {
    throw new TypeError('A review-request mutation attempt precedes its request record.');
  }
  if (reconciledAt === undefined || reconciledAt === null) {
    return;
  }

  const reconciledTime = parseRfc3339Timestamp(reconciledAt, 'reconciledAt');
  if (reconciledTime < attemptedTime) {
    throw new TypeError('The persisted reconciliation precedes its attempt.');
  }
  if (
    (publicMutation.state === 'NO_EFFECT' || publicMutation.state === 'EXHAUSTED') &&
    reconciledTime - attemptedTime < REVIEW_REQUEST_RECONCILIATION_MILLISECONDS
  ) {
    throw new TypeError('The persisted no-effect reconciliation interval is too short.');
  }
}

function validatePredecessorOutputs(predecessorOutputs, completedTaskNumber = null) {
  if (
    predecessorOutputs === null ||
    typeof predecessorOutputs !== 'object' ||
    Array.isArray(predecessorOutputs) ||
    Object.keys(predecessorOutputs).length > 64 ||
    (
      completedTaskNumber !== null &&
      (
        !Number.isInteger(completedTaskNumber) ||
        completedTaskNumber < 0 ||
        completedTaskNumber > PLAN_TASK_COUNT
      )
    )
  ) {
    throw new TypeError('predecessorOutputs must be a bounded task-output map.');
  }

  for (const [task, outputs] of Object.entries(predecessorOutputs)) {
    const taskNumber = Number.parseInt(task, 10);
    if (
      !PREDECESSOR_TASK_PATTERN.test(task) ||
      taskNumber > PLAN_TASK_COUNT ||
      outputs === null ||
      typeof outputs !== 'object' ||
      Array.isArray(outputs) ||
      Object.keys(outputs).length > 64 ||
      (completedTaskNumber !== null && taskNumber > completedTaskNumber)
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
        record.last_consumer_task > PLAN_TASK_COUNT ||
        (
          completedTaskNumber !== null &&
          record.last_consumer_task <= completedTaskNumber
        )
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
  if (
    !Number.isInteger(completedTaskNumber) ||
    completedTaskNumber < 0 ||
    completedTaskNumber > PLAN_TASK_COUNT
  ) {
    throw new TypeError(
      'completedTaskNumber must be a completed plan prefix within the fixed plan.',
    );
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
  const canonicalRetained = canonicalize(retained);
  validatePredecessorOutputs(canonicalRetained, completedTaskNumber);
  return canonicalRetained;
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
  reviewMetrics = null,
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
  validateReviewRequestOrdering(requests);
  const reviewedHeads = reviewMetrics === null
    ? []
    : validatePersistedRequestMetrics(
      reviewMetrics,
      requests,
      currentReviewInput.head,
    );
  const knownHeads = new Set([
    currentReviewInput.head,
    ...requests.map((request) => request.head),
    ...reviewedHeads,
  ]);
  const supersessionByKey = validateSupersessionsAgainstRequests({
    requests,
    supersessions,
    knownHeads,
    currentKey,
  });

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
      pair.every((request) => request.terminal === true);
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
      reason: 'After authenticated reviewed-input drift, mark each incomplete prior-input pair SUPERSEDED before requesting the new pair.',
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

  if (missingChannels.length === 0) {
    return Object.freeze({
      status: 'NO_REQUEST',
      reviewInputKey: currentKey,
      channels: [],
      reason: 'The required pair already exists for this reviewed input.',
    });
  }

  if (requestsForCurrentInput.length > 0) {
    const copilotRequest = requestsForCurrentInput.find(
      (request) => request.channel === 'copilot',
    );
    const codexRequest = requestsForCurrentInput.find(
      (request) => request.channel === 'codex',
    );
    if (
      copilotRequest !== undefined &&
      !isCopilotReadyForCodex(copilotRequest) &&
      codexRequest === undefined
    ) {
      return Object.freeze({
        status: 'WAIT_FOR_CURRENT_CHANNEL',
        reviewInputKey: currentKey,
        channels: [],
        reason: 'Copilot must be confirmed or terminally proved non-functional before Codex starts.',
      });
    }

    return Object.freeze({
      status: 'REQUEST_REQUIRED',
      reviewInputKey: currentKey,
      channels: missingChannels.slice(0, 1),
      reason: 'Complete the review pair that already started for this reviewed input.',
    });
  }

  if (previousReviewInput === null || mutationClass === 'CODE_OR_DIFF') {
    return Object.freeze({
      status: 'REQUEST_REQUIRED',
      reviewInputKey: currentKey,
      channels: ['copilot'],
      reason: previousReviewInput === null ? 'First review for this input.' : 'Code or diff changed.',
    });
  }

  if (mutationClass === 'MATERIAL_SCOPE_BEHAVIOR_RISK') {
    return Object.freeze({
      status: 'REQUEST_REQUIRED',
      reviewInputKey: currentKey,
      channels: ['copilot'],
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
  return item?.user?.login ?? item?.author?.login ?? item?.actor?.login ??
    (typeof item?.actor === 'string' ? item.actor : null);
}

function normalizeActorLogin(login) {
  return typeof login === 'string'
    ? login.toLowerCase().replace(/\[bot\]$/u, '')
    : null;
}

function getCommitOid(item) {
  return item?.commit_id ?? item?.commit?.oid ??
    (typeof item?.commit === 'string' ? item.commit : null) ??
    item?.commitOid ?? null;
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

function isItemAtOrAfterRequest(item, fields, requestTime) {
  for (const field of fields) {
    const value = item?.[field];
    if (value === undefined || value === null) {
      continue;
    }

    try {
      const itemTime = parseRfc3339Timestamp(value, field);
      const requestBoundary = /:\d{2}\.\d+/u.test(value)
        ? requestTime
        : Math.floor(requestTime / 1_000) * 1_000;
      return itemTime >= requestBoundary;
    } catch {
      continue;
    }
  }

  return false;
}

const COPILOT_REVIEWER_DATABASE_ID = 175728472;
const COPILOT_REVIEWER_NODE_ID = 'BOT_kgDOCnlnWA';

function isCopilotIdentity(item) {
  const actor = item?.user ?? item?.author ?? item?.actor ?? item;
  const login = actor?.login ?? actor?.slug ??
    (typeof actor === 'string' ? actor : null);
  const normalized = normalizeActorLogin(login);
  if (normalized === 'copilot-pull-request-reviewer') {
    return true;
  }
  if (normalized !== 'copilot' || actor === null || typeof actor !== 'object') {
    return false;
  }

  const actorType = actor.type ?? actor.__typename;
  const hasDatabaseId = [actor.id, actor.databaseId, actor.database_id].some(
    (value) => Number(value) === COPILOT_REVIEWER_DATABASE_ID,
  );
  const hasNodeId = [actor.id, actor.nodeId, actor.node_id].some(
    (value) => value === COPILOT_REVIEWER_NODE_ID,
  );
  return typeof actorType === 'string' &&
    actorType.toLowerCase() === 'bot' &&
    (hasDatabaseId || hasNodeId);
}

function getReviewerCollection(value) {
  if (value !== null && typeof value === 'object' && !Array.isArray(value)) {
    if (Object.hasOwn(value, 'requested_reviewers')) {
      return normalizeCollection(value.requested_reviewers);
    }
    if (Object.hasOwn(value, 'users')) {
      return normalizeCollection(value.users);
    }
  }

  return normalizeCollection(value);
}

export function collectCopilotRequestEvidence({
  responseReviewers,
  requestEvents,
  requestedReviewers,
  submittedReviews,
  reviewRuns,
  baselineRequestEventIds,
  baselineReviewNodeIds,
  baselineReviewRunIds,
  expectedHead,
  requestedAt,
  readbackCompleteness,
}) {
  if (typeof expectedHead !== 'string' || !SHA1_PATTERN.test(expectedHead)) {
    throw new TypeError('The expected review-request head is invalid.');
  }
  const requestTime = parseRfc3339Timestamp(requestedAt, 'requestedAt');
  const baselineSets = [
    ['request event', baselineRequestEventIds],
    ['review', baselineReviewNodeIds],
    ['review run', baselineReviewRunIds],
  ];
  for (const [label, values] of baselineSets) {
    if (
      !Array.isArray(values) ||
      values.some((value) => typeof value !== 'string' || value.length === 0) ||
      new Set(values).size !== values.length
    ) {
      throw new TypeError(`The ${label} baseline must contain unique identities.`);
    }
  }
  const completenessKeys = [
    'requestEvents',
    'requestedReviewers',
    'submittedReviews',
    'reviewRuns',
  ];
  if (
    readbackCompleteness === null ||
    typeof readbackCompleteness !== 'object' ||
    Array.isArray(readbackCompleteness) ||
    Object.keys(readbackCompleteness).length !== completenessKeys.length ||
    completenessKeys.some((key) => typeof readbackCompleteness[key] !== 'boolean')
  ) {
    throw new TypeError('Review-request readback completeness is malformed.');
  }
  const readbackCollections = {
    requestEvents,
    requestedReviewers,
    submittedReviews,
    reviewRuns,
  };
  const readbackComplete = completenessKeys.every(
    (key) => readbackCompleteness[key] &&
      readbackCollections[key] !== undefined &&
      readbackCollections[key] !== null,
  );
  const eventBaselines = new Set(baselineRequestEventIds);
  const reviewBaselines = new Set(baselineReviewNodeIds);
  const runBaselines = new Set(baselineReviewRunIds);

  const responseReviewerMatched = getReviewerCollection(responseReviewers).some(
    (reviewer) => isCopilotIdentity(reviewer),
  );
  const requestEventMatched = normalizeCollection(requestEvents).some((event) => {
    const id = getItemId(event);
    const reviewer = event?.requested_reviewer ?? event?.requestedReviewer;
    return event?.event === 'review_requested' &&
      id !== null &&
      !eventBaselines.has(id) &&
      isItemAtOrAfterRequest(event, ['created_at', 'createdAt'], requestTime) &&
      isCopilotIdentity(reviewer);
  });
  const requestedReviewerMatched = getReviewerCollection(requestedReviewers).some(
    (reviewer) => isCopilotIdentity(reviewer),
  );
  const submittedReviewMatched = normalizeCollection(submittedReviews).some((review) => {
    const id = getItemId(review);
    return id !== null &&
      !reviewBaselines.has(id) &&
      isItemAtOrAfterRequest(review, ['submitted_at', 'submittedAt'], requestTime) &&
      getCommitOid(review) === expectedHead &&
      isCopilotIdentity(review);
  });
  const reviewRunMatched = normalizeCollection(reviewRuns).some((run) => {
    const id = getItemId(run);
    const head = run?.head_sha ?? run?.headSha ?? run?.headCommit?.oid;
    return id !== null &&
      !runBaselines.has(id) &&
      isItemAtOrAfterRequest(
        run,
        ['created_at', 'createdAt', 'run_started_at', 'runStartedAt'],
        requestTime,
      ) &&
      head === expectedHead &&
      (isCopilotIdentity(run?.app) || isCopilotIdentity(run?.actor));
  });

  return Object.freeze({
    responseReviewerMatched,
    requestEventMatched,
    requestedReviewerMatched,
    submittedReviewMatched,
    reviewRunMatched,
    triggerCommentMatched: false,
    readbackComplete,
  });
}

export function collectCodexRequestEvidence({
  triggerComments,
  baselineConversationComments,
  expectedActorLogin,
  requestedAt,
  readbackComplete,
}) {
  const requestTime = parseRfc3339Timestamp(requestedAt, 'requestedAt');
  if (
    baselineConversationComments === null ||
    typeof baselineConversationComments !== 'object' ||
    Array.isArray(baselineConversationComments) ||
    Object.entries(baselineConversationComments).some(
      ([id, updatedAt]) => id.length === 0 ||
        getItemTime({ updatedAt }, ['updatedAt']) === null,
    )
  ) {
    throw new TypeError('The conversation-comment baseline is malformed.');
  }
  if (
    typeof expectedActorLogin !== 'string' ||
    expectedActorLogin.trim().length === 0 ||
    typeof readbackComplete !== 'boolean'
  ) {
    throw new TypeError('Codex trigger-comment evidence identity is malformed.');
  }
  const commentsAvailable = triggerComments !== undefined && triggerComments !== null;
  const expectedActor = normalizeActorLogin(expectedActorLogin);
  const triggerCommentMatched = commentsAvailable && normalizeCollection(triggerComments).some(
    (comment) => {
      const id = getItemId(comment);
      return id !== null &&
        !Object.hasOwn(baselineConversationComments, id) &&
        normalizeActorLogin(getActorLogin(comment)) === expectedActor &&
        comment?.body === REVIEW_REQUEST_SPECS.codex.body &&
        isItemAtOrAfterRequest(comment, ['created_at', 'createdAt'], requestTime);
    },
  );

  return Object.freeze({
    responseReviewerMatched: false,
    requestEventMatched: false,
    requestedReviewerMatched: false,
    submittedReviewMatched: false,
    reviewRunMatched: false,
    triggerCommentMatched,
    readbackComplete: readbackComplete && commentsAvailable,
  });
}

function isReviewRequestRecord(request) {
  const identityBaselineFields = [
    'baselineRequestEventIds',
    'baselineReviewNodeIds',
    'baselineReviewRunIds',
  ];
  const identityBaselinesAreValid = identityBaselineFields.every((field) => {
    const values = request?.[field];
    return Array.isArray(values) &&
      values.every((id) => typeof id === 'string' && id.length > 0) &&
      new Set(values).size === values.length;
  });
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
  const requestedTime = getItemTime(request, ['requestedAt']);
  const hasReadyAt = Object.hasOwn(request ?? {}, 'readyAt');
  const hasTerminalDisposition = Object.hasOwn(request ?? {}, 'terminalDisposition');
  const hasTerminalResultRef = Object.hasOwn(request ?? {}, 'terminalResultRef');
  const terminalDispositionIsValid = hasTerminalDisposition
    ? request.terminal === true &&
      request.confirmed === false &&
      isRepositoryAuthorizedNonfunctionalDisposition(request.terminalDisposition, request)
    : !(request?.terminal === true && request?.confirmed === false);
  const terminalResultRefIsValid = hasTerminalResultRef
    ? request.terminal === true &&
      request.confirmed === true &&
      isTerminalResultRef(request.terminalResultRef) &&
      !(request.channel === 'copilot' &&
        request.terminalResultRef.kind !== 'submitted-review')
    : !(request?.terminal === true && request?.confirmed === true);
  const readyAtIsValid = !hasReadyAt ||
    (
      request.channel === 'copilot' &&
      isCopilotReadyForCodex(request) &&
      getItemTime(request, ['readyAt']) !== null &&
      requestedTime !== null &&
      getItemTime(request, ['readyAt']) >= requestedTime &&
      (
        request.confirmed === true ||
        request.readyAt === request.terminalDisposition.recordedAt
      )
    );

  return channelIsValid &&
    typeof request.confirmed === 'boolean' &&
    typeof request.terminal === 'boolean' &&
    typeof request.head === 'string' &&
    SHA1_PATTERN.test(request.head) &&
    typeof request.reviewInputKey === 'string' &&
    SHA256_PATTERN.test(request.reviewInputKey) &&
    requestedTime !== null &&
    identityBaselinesAreValid &&
    commentBaselinesAreValid &&
    terminalDispositionIsValid &&
    terminalResultRefIsValid &&
    readyAtIsValid;
}

function isTerminalResultRef(reference) {
  if (
    reference === null ||
    typeof reference !== 'object' ||
    Array.isArray(reference) ||
    Object.keys(reference).length !== 3 ||
    !['submitted-review', 'conversation-comment'].includes(reference.kind) ||
    typeof reference.id !== 'string' ||
    reference.id.length === 0 ||
    reference.id.length > 256
  ) {
    return false;
  }

  return getItemTime(reference, ['observedAt']) !== null;
}

function isRepositoryAuthorizedNonfunctionalDisposition(disposition, request) {
  if (
    disposition === null ||
    typeof disposition !== 'object' ||
    Array.isArray(disposition) ||
    Object.keys(disposition).length !== 4 ||
    disposition.state !== 'REPOSITORY_AUTHORIZED_NON_FUNCTIONAL' ||
    typeof disposition.authority !== 'string' ||
    disposition.authority.trim().length === 0 ||
    typeof disposition.reason !== 'string' ||
    disposition.reason.trim().length === 0
  ) {
    return false;
  }

  const recordedTime = getItemTime(disposition, ['recordedAt']);
  const requestTime = getItemTime(request, ['requestedAt']);
  return recordedTime !== null && requestTime !== null && recordedTime >= requestTime;
}

function getItemIdentities(item) {
  return [...new Set([
    item?.node_id,
    item?.nodeId,
    item?.id,
    item?.databaseId,
  ].filter((value) => value !== null && value !== undefined).map(String))];
}

function isResultActorForChannel(result, channel) {
  return channel === 'copilot'
    ? isCopilotIdentity(result)
    : normalizeActorLogin(getActorLogin(result)) === 'chatgpt-codex-connector';
}

function getNextDifferentInputRequestTime(request, requests) {
  const requestIndex = requests.indexOf(request);
  const resolvedIndex = requestIndex >= 0
    ? requestIndex
    : requests.findIndex((candidate) => canonicalJson(candidate) === canonicalJson(request));
  if (resolvedIndex < 0) {
    return null;
  }
  const successor = requests.slice(resolvedIndex + 1).find(
    (candidate) => candidate.reviewInputKey !== request.reviewInputKey,
  );
  return successor === undefined ? null : getItemTime(successor, ['requestedAt']);
}

function isReferencedTerminalResult(result, request, reference, requests) {
  const timeFields = reference.kind === 'submitted-review'
    ? ['submitted_at', 'submittedAt']
    : ['updated_at', 'updatedAt', 'created_at', 'createdAt'];
  const requestTime = getItemTime(request, ['requestedAt']);
  const resultTime = getItemTime(result, timeFields);
  const referenceTime = getItemTime(reference, ['observedAt']);
  const identities = getItemIdentities(result);
  const nextDifferentInputTime = getNextDifferentInputRequestTime(request, requests);

  if (
    requestTime === null ||
    resultTime === null ||
    resultTime !== referenceTime ||
    !identities.includes(reference.id) ||
    !isItemAtOrAfterRequest(result, timeFields, requestTime) ||
    (nextDifferentInputTime !== null && resultTime > nextDifferentInputTime) ||
    !isResultActorForChannel(result, request.channel)
  ) {
    return false;
  }

  if (reference.kind === 'submitted-review') {
    const baselines = new Set(request.baselineReviewNodeIds);
    return getCommitOid(result) === request.head &&
      identities.every((identity) => !baselines.has(identity));
  }

  if (
    request.channel !== 'codex' ||
    result.body?.trim() === '@codex review' ||
    typeof result.status !== 'string' ||
    !result.status.startsWith('completed')
  ) {
    return false;
  }

  const explicitHead = result.head ?? result.headRefOid;
  if (explicitHead !== undefined && explicitHead !== request.head) {
    return false;
  }
  if (
    result.commitPrefix !== undefined &&
    (
      typeof result.commitPrefix !== 'string' ||
      !/^[0-9a-f]{7,40}$/u.test(result.commitPrefix) ||
      !request.head.startsWith(result.commitPrefix)
    )
  ) {
    return false;
  }

  const baselineTimes = identities
    .filter((identity) => Object.hasOwn(request.baselineConversationComments, identity))
    .map((identity) => getItemTime(
      { updatedAt: request.baselineConversationComments[identity] },
      ['updatedAt'],
    ));
  return baselineTimes.every(
    (baselineTime) => baselineTime !== null && resultTime > baselineTime,
  );
}

function validateTerminalResultReferences(requests, reviewState) {
  const resultCollections = {
    copilot: reviewState?.copilotResults,
    codex: reviewState?.codexResults,
  };
  for (const [channel, results] of Object.entries(resultCollections)) {
    if (
      results === null ||
      typeof results !== 'object' ||
      Array.isArray(results) ||
      !Array.isArray(results.submittedReviews) ||
      !Array.isArray(results.conversationComments)
    ) {
      throw new TypeError(`The persisted ${channel} result collection is malformed.`);
    }
  }

  const seenReferences = new Set();
  for (const request of requests.filter(
    (candidate) => candidate.confirmed === true && candidate.terminal === true,
  )) {
    const reference = request.terminalResultRef;
    const referenceIdentity = canonicalJson({
      channel: request.channel,
      ...reference,
    });
    if (seenReferences.has(referenceIdentity)) {
      throw new TypeError('A terminal result reference is assigned to multiple requests.');
    }
    seenReferences.add(referenceIdentity);

    const collection = reference.kind === 'submitted-review'
      ? resultCollections[request.channel].submittedReviews
      : resultCollections[request.channel].conversationComments;
    const matches = collection.filter(
      (result) => isReferencedTerminalResult(result, request, reference, requests),
    );
    if (matches.length !== 1) {
      throw new TypeError(
        'A confirmed terminal request must reference one attributable terminal result.',
      );
    }
  }
}

function isCopilotReadyForCodex(request) {
  return request?.confirmed === true ||
    (
      request?.terminal === true &&
      request?.confirmed === false &&
      isRepositoryAuthorizedNonfunctionalDisposition(request.terminalDisposition, request)
    );
}

function getRequestTerminalTime(request) {
  if (request?.terminal !== true) {
    return null;
  }
  return request.confirmed === true
    ? getItemTime(request.terminalResultRef, ['observedAt'])
    : getItemTime(request.terminalDisposition, ['recordedAt']);
}

function validateReviewRequestOrdering(
  reviewRequests,
  { enforceGlobalSerialization = false } = {},
) {
  for (const codexRequest of reviewRequests.filter(
    (request) => request.channel === 'codex',
  )) {
    const copilotRequests = reviewRequests.filter(
      (request) => request.channel === 'copilot' &&
        request.reviewInputKey === codexRequest.reviewInputKey,
    );
    const copilotRequest = copilotRequests[0];
    const copilotReady = copilotRequests.length === 1 &&
      copilotRequest.head === codexRequest.head &&
      isCopilotReadyForCodex(copilotRequest);
    if (!copilotReady) {
      throw new TypeError(
        'A Codex request requires one eligible Copilot predecessor for the same reviewed input.',
      );
    }

    if (!Object.hasOwn(copilotRequest, 'readyAt')) {
      throw new TypeError('A Codex request requires its Copilot predecessor readiness time.');
    }
    const copilotTime = parseRfc3339Timestamp(copilotRequest.readyAt, 'Copilot readyAt');
    const codexTime = parseRfc3339Timestamp(codexRequest.requestedAt, 'Codex requestedAt');
    if (copilotTime > codexTime) {
      throw new TypeError('A Codex request must not precede Copilot readiness.');
    }
  }

  if (!enforceGlobalSerialization) {
    return;
  }
  const requestTimes = reviewRequests.map(
    (request) => getItemTime(request, ['requestedAt']),
  );
  for (let index = 1; index < reviewRequests.length; index += 1) {
    if (requestTimes[index] < requestTimes[index - 1]) {
      throw new TypeError('The persisted review-request history is not time ordered.');
    }
  }
  for (let index = 0; index < reviewRequests.length; index += 1) {
    const request = reviewRequests[index];
    for (let priorIndex = 0; priorIndex < index; priorIndex += 1) {
      const prior = reviewRequests[priorIndex];
      if (prior.reviewInputKey === request.reviewInputKey) {
        continue;
      }
      const terminalTime = getRequestTerminalTime(prior);
      if (terminalTime === null || terminalTime > requestTimes[index]) {
        throw new TypeError(
          'A different-input request requires every earlier-input request to be terminal first.',
        );
      }
    }
  }
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

function validateSupersessionsAgainstRequests({
  requests,
  supersessions,
  knownHeads,
  currentKey = null,
}) {
  const supersessionByKey = new Map();
  for (const disposition of supersessions) {
    const pair = requests.filter(
      (request) => request.reviewInputKey === disposition.reviewInputKey,
    );
    const channels = new Set(pair.map((request) => request.channel));
    const heads = new Set(pair.map((request) => request.head));
    const supersededTime = getItemTime(disposition, ['supersededAt']);
    const requestTimes = pair.map(
      (request) => getItemTime(request, ['requestedAt']),
    );
    if (
      pair.length === 0 ||
      channels.size === 2 ||
      heads.size !== 1 ||
      !heads.has(disposition.head) ||
      !knownHeads.has(disposition.successorHead) ||
      pair.some((request) => request.terminal !== true) ||
      supersededTime === null ||
      requestTimes.some((requestTime) => requestTime === null || supersededTime < requestTime)
    ) {
      throw new TypeError(
        'A superseded disposition does not describe a terminal incomplete prior-input pair.',
      );
    }
    if (disposition.reviewInputKey !== currentKey) {
      supersessionByKey.set(disposition.reviewInputKey, disposition);
    }
  }
  return supersessionByKey;
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
  reviewRequests = [],
}) {
  const head = reviewInput?.head;
  const reviewInputKey = reviewInput === null || reviewInput === undefined
    ? null
    : getReviewInputKey(reviewInput);
  const requestTime = getItemTime(request, ['requestedAt']);
  const expectedActor = normalizeActorLogin(actor);
  const requests = normalizeCollection(reviewRequests);
  let requestHistoryIsValid = false;
  try {
    const seenRequests = new Set();
    if (requests.some((candidate) => !isReviewRequestRecord(candidate))) {
      throw new TypeError('A Codex result request history is malformed.');
    }
    for (const candidate of requests) {
      const identity = `${candidate.reviewInputKey}:${candidate.channel}`;
      if (seenRequests.has(identity)) {
        throw new TypeError('A Codex result request history contains a duplicate channel.');
      }
      seenRequests.add(identity);
    }
    validateReviewRequestOrdering(requests, { enforceGlobalSerialization: true });
    requestHistoryIsValid = requests.some(
      (candidate) => canonicalJson(candidate) === canonicalJson(request),
    );
  } catch {
    requestHistoryIsValid = false;
  }
  const requestMatches = reviewInputKey !== null &&
    isReviewRequestForInput(request, reviewInput, 'codex') &&
    requestHistoryIsValid &&
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
      return normalizeActorLogin(getActorLogin(review)) === expectedActor &&
        getCommitOid(review) === head &&
        id !== null &&
        !baselineReviewIds.has(id) &&
        isItemAtOrAfterRequest(review, ['submitted_at', 'submittedAt'], requestTime);
    },
  );
  const comments = normalizeCollection(conversationComments)
    .map((comment) => normalizeCodexConversationResult(comment, head))
    .filter(
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
      if (
        id === null ||
        updatedAt === null ||
        !isItemAtOrAfterRequest(
          comment,
          ['updated_at', 'updatedAt', 'created_at', 'createdAt'],
          requestTime,
        )
      ) {
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

function normalizeCodexConversationResult(comment, head) {
  if (
    typeof comment?.status === 'string' &&
    comment.status.startsWith('completed')
  ) {
    return comment;
  }
  const body = typeof comment?.body === 'string' ? comment.body : '';
  const completedRow = /\|\s*[^|\r\n]*\*\*Code Review\*\*\s*\|\s*[^|\r\n]*\*\*Completed\*\*[^|\r\n]*\|\s*`(?<commitPrefix>[0-9a-f]{7,40})`\s*\|/iu.exec(body);
  if (completedRow === null || !head.startsWith(completedRow.groups.commitPrefix)) {
    return comment;
  }
  return {
    ...comment,
    status: 'completed',
    commitPrefix: completedRow.groups.commitPrefix,
  };
}

export function reconcileReviewRequestMutation({
  response,
  evidence,
  reviewInputKey,
  channel,
  attemptedAt,
  observedAt,
  attemptCount,
  localRecordSucceeded,
  minimumWaitMilliseconds = REVIEW_REQUEST_RECONCILIATION_MILLISECONDS,
}) {
  if (
    typeof reviewInputKey !== 'string' ||
    !SHA256_PATTERN.test(reviewInputKey) ||
    !['copilot', 'codex'].includes(channel)
  ) {
    throw new TypeError('Review-request mutation identity is malformed.');
  }
  const evidenceKeys = [
    'responseReviewerMatched',
    'requestEventMatched',
    'requestedReviewerMatched',
    'submittedReviewMatched',
    'reviewRunMatched',
    'triggerCommentMatched',
    'readbackComplete',
  ];
  if (
    evidence === null ||
    typeof evidence !== 'object' ||
    Array.isArray(evidence) ||
    Object.keys(evidence).length !== evidenceKeys.length ||
    evidenceKeys.some((key) => typeof evidence[key] !== 'boolean')
  ) {
    throw new TypeError('Review-request evidence is malformed.');
  }
  if (!Number.isInteger(attemptCount) || attemptCount < 1 || attemptCount > 2) {
    throw new TypeError('Review-request attempt count must be one or two.');
  }
  if (
    !Number.isInteger(minimumWaitMilliseconds) ||
    minimumWaitMilliseconds < REVIEW_REQUEST_RECONCILIATION_MILLISECONDS
  ) {
    throw new TypeError('The review-request reconciliation wait is too short.');
  }
  const attemptedTime = parseRfc3339Timestamp(attemptedAt, 'attemptedAt');
  const observedTime = parseRfc3339Timestamp(observedAt, 'observedAt');
  if (observedTime < attemptedTime) {
    throw new TypeError('Review-request observation precedes the attempt.');
  }

  const nativeResponseAccepted = response?.ok === true;
  const durableMatch = evidence.requestEventMatched ||
    evidence.requestedReviewerMatched ||
    evidence.submittedReviewMatched ||
    evidence.reviewRunMatched ||
    evidence.triggerCommentMatched;
  const baseRecord = {
    nativeResponseAccepted,
    readbackMatched: durableMatch,
    localRecordSucceeded: Boolean(localRecordSucceeded),
    attemptCount,
    attemptedAt,
    reconciledAt: null,
    evidence: Object.freeze({ ...evidence }),
    reviewInputKey,
    channel,
  };

  if (response?.executed === false && nativeResponseAccepted) {
    return Object.freeze({
      ...baseRecord,
      state: 'AMBIGUOUS',
      retryAllowed: false,
      reconciledAt: observedAt,
    });
  }

  if (durableMatch) {
    return Object.freeze({
      ...baseRecord,
      state: nativeResponseAccepted ? 'CONFIRMED' : 'AMBIGUOUS',
      retryAllowed: false,
      reconciledAt: observedAt,
    });
  }

  if (response?.executed === false && !nativeResponseAccepted) {
    return Object.freeze({
      ...baseRecord,
      state: 'NOT_EXECUTED',
      retryAllowed: true,
      reconciledAt: observedAt,
    });
  }

  if (!nativeResponseAccepted) {
    return Object.freeze({
      ...baseRecord,
      state: 'AMBIGUOUS',
      retryAllowed: false,
      reconciledAt: observedAt,
    });
  }

  const waitSatisfied = observedTime - attemptedTime >= minimumWaitMilliseconds;
  if (!evidence.readbackComplete || !waitSatisfied) {
    return Object.freeze({
      ...baseRecord,
      state: 'RECONCILING',
      retryAllowed: false,
    });
  }

  return Object.freeze({
    ...baseRecord,
    state: attemptCount === 1 ? 'NO_EFFECT' : 'EXHAUSTED',
    retryAllowed: attemptCount === 1,
    reconciledAt: observedAt,
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
  reviewedHeads = [],
  bodyEditTimes,
  reviewBeganAt,
  sameHeadRerequestReasons,
  cleanReviewAt,
  recognizedAt,
  cleanPairAt,
  mergedAt,
}) {
  const requestsPerHead = {};
  for (const [index, head] of normalizeCollection(reviewedHeads).entries()) {
    assertHash(head, SHA1_PATTERN, `reviewedHeads[${index}]`);
    requestsPerHead[head] = 0;
  }
  for (const [index, request] of normalizeCollection(reviewRequests).entries()) {
    assertHash(request?.head, SHA1_PATTERN, `reviewRequests[${index}].head`);
    requestsPerHead[request.head] = (requestsPerHead[request.head] ?? 0) + 1;
  }

  const reviewStart = parseRfc3339Timestamp(reviewBeganAt, 'reviewBeganAt');
  const parsedBodyEditTimes = normalizeCollection(bodyEditTimes).map(
    (value, index) => ({
      value,
      timestamp: parseRfc3339Timestamp(value, `bodyEditTimes[${index}]`),
    }),
  );
  const bodyEditsAfterReviewBegan = parsedBodyEditTimes.filter(
    ({ value, timestamp }) => /:\d{2}\.\d+/u.test(value)
      ? timestamp > reviewStart
      : timestamp >= Math.floor(reviewStart / 1_000) * 1_000,
  ).length;
  const rerequestReasons = normalizeCollection(sameHeadRerequestReasons).map(
    (record, index) => {
      if (
        record === null ||
        typeof record !== 'object' ||
        Array.isArray(record) ||
        Object.keys(record).length !== 2 ||
        !Object.hasOwn(record, 'reason') ||
        !Object.hasOwn(record, 'material') ||
        typeof record.material !== 'boolean'
      ) {
        throw new TypeError(`sameHeadRerequestReasons[${index}] is malformed.`);
      }
      assertNonemptyText(record.reason, `sameHeadRerequestReasons[${index}].reason`);
      if (record.reason.trim().length === 0) {
        throw new TypeError(
          `sameHeadRerequestReasons[${index}].reason must contain non-whitespace text.`,
        );
      }
      return Object.freeze({
        reason: record.reason,
        material: record.material,
      });
    },
  );

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
    sameHeadRerequestReasons: rerequestReasons,
    cleanReviewRecognitionMilliseconds: elapsed(
      cleanReviewAt,
      recognizedAt,
      'cleanReviewAt',
      'recognizedAt',
    ),
    cleanPairToMergeMilliseconds: elapsed(cleanPairAt, mergedAt, 'cleanPairAt', 'mergedAt'),
  });
}
