<!-- markdownlint-disable MD013 -->

# Update an action plan without regressing the existing task slate

## Run-specific inputs

Update only this section before each run.

- **Source plan:** `docs/planning/action-items-2026-08-12-v2.md`
- **Completed source tasks:** Tasks 1–3
- **New GitHub work items to incorporate:**
  - [PSStyleGuide PR #165](https://github.com/franklesniak/PSStyleGuide/pull/165)
  - [PSStyleGuide issue #166](https://github.com/franklesniak/PSStyleGuide/issues/166)
- **Preferred insertion point:** Before the work identified as Task 4 in the source plan
- **Output plan:** `docs/planning/action-items-2026-08-13.md`
- **Temporary preservation ledger:** `TEMP-action-items-2026-08-13-preservation-ledger.md`

Treat all paths, task ranges, work-item links, and task numbers outside this section as derived values. Do not require the user to update them elsewhere in this prompt.

## Objective

Review the source plan in full. Treat the completed source tasks as completed history. Preserve any results, state, evidence, dependencies, or downstream inputs from those tasks that remain relevant, but do not include the completed work as executable tasks in the output plan.

Review the complete current GitHub state of every new GitHub work item listed in the run-specific inputs. Use authenticated, structured GitHub data when available, and paginate all relevant results. Review each work item’s body, edits, comments, reviews, review threads, commits, checks, linked issues, closing references, dependencies, base and head identities, merge state, and any deferred or follow-up work.

Verify the relationships among the new GitHub work items. Do not assume that one item closes, blocks, implements, supersedes, or fully addresses another unless GitHub or repository evidence supports that conclusion.

Create the output plan specified in the run-specific inputs. Do not modify the source plan.

This is a planning-document task. Do not implement work from the new GitHub work items, merge a PR, close an issue, change issue dependencies, post GitHub comments, modify repository settings, or make unrelated repository changes.

## Required planning analysis

Before editing the output plan:

1. Re-query the GitHub state needed to validate all current-state, completion, dependency, and sequencing claims affected by the completed source tasks, the new GitHub work items, and the remaining task slate. Do not carry forward a dated status claim as current without verification.
2. Determine every action required to bring each new GitHub work item to its correct terminal state. Include implementation, review, validation, metadata, dependency, merge, closure, reciprocal comparison, or follow-up actions when the verified evidence requires them.
3. Determine the dependencies among those actions and between those actions and the preferred insertion point.
4. Place the required closeout work for the new GitHub work items before the preferred insertion point. If verified evidence proves that part of the closeout work cannot occur there, do not invent a false dependency or misleading order. Document the conflict in a `TEMP-*` analysis file, select the technically correct order through the decision process below, and explain the deviation in the final response.
5. Map dependencies across the entire remaining task slate using appropriate finish-to-start, finish-to-finish, start-to-start, or start-to-finish relationships. Convert a finish-to-finish condition into a separate leaf task when doing so produces a clearer chronological sequence.
6. Determine the most straightforward execution order that minimizes task switching and preserves the existing one-at-a-time implementation and reciprocal fixed-point requirements.

## Anti-regression preservation ledger

Before materially rewriting or renumbering tasks, create the temporary preservation ledger specified in the run-specific inputs.

The ledger must account for:

- every numbered source task;
- every source-task dependency and cross-reference;
- every conditional branch, calendar constraint, trigger, stop condition, completion condition, and fixed-point gate;
- every execution-class designation;
- every copy-paste-ready prompt;
- every PR lifecycle requirement;
- every cross-repository comparison, sync-back, and closure requirement;
- every issue-creation versus implementation-commencement boundary;
- every operative requirement in a shared source section; and
- every immutable input, evidence requirement, validation requirement, authorization gate, and required output.

For each completed source task, record that its executable work was removed because the run-specific inputs identify it as complete. Map any state or output still needed downstream to the location where it is preserved in the output plan.

For every incomplete source task, identify its destination task or tasks in the output plan. If content is split, list every destination. If any content is intentionally removed or materially changed, record the exact reason and supporting evidence. Do not remove content merely because it is repetitive, lengthy, inconvenient, or appears implicit.

Use the ledger to perform a final semantic coverage check. Every operative source requirement must be one of the following:

1. preserved in each applicable destination task;
2. updated because verified current evidence made it stale;
3. retained as completed-state evidence from a completed source task; or
4. intentionally removed with a documented, defensible reason.

Do not put the preservation ledger or other analysis artifacts in the output plan.

## Task construction requirements

Every numbered item in the output plan must be an atomic leaf task. An atomic task has one executor, one primary outcome, one risk tier, and one objectively testable completion result. It can combine routine preparation, commit, non-force push, PR publication, targeted readback, handoff, or closure steps when they use the same executor, authority, risk tier, and validation boundary. Do not create a leaf only to record commencement, a new identity, or an intermediate receipt.

Separate the following only when a different executor, risk tier, external wait, independent gate, or human decision makes the boundary necessary:

- creating or updating an issue when it is a required durable product or coordination object;
- implementing, validating, and publishing the candidate;
- running the Codex review loop in a fresh subagent;
- running an independent final quality check in a fresh coding-agent session;
- making a human or administrator decision;
- changing repository settings after exact authorization;
- merging the PR;
- publishing the landed handoff and performing the next comparison when one executor and validation boundary can do both;
- implementing any required reciprocal sync-back;
- repeating review and quality gates after reviewable bytes change;
- performing the final reciprocal comparison and closing the fixed point when the comparison proves closure; and
- closing a tracker or umbrella issue when closure is not already part of the same proved final state.

Do not combine implementation with an independent review, an independent final quality check, a human or administrator decision, or merge. Do not split routine work into issue, commencement, branch, commit, push, PR, handoff, and closure leaves only to create a paper trail.

For each task or independently executable conditional task, include:

- a precise title;
- an execution classification: `Coding agent executable`, `Human execution required`, or `Not executable; tracking/control only`;
- the exact predecessor relationships and prerequisites;
- an objective;
- all task-specific execution controls;
- verified inputs and identities, or narrowly defined placeholders for values that cannot exist until a predecessor finishes;
- an ordered procedure;
- required validation and evidence;
- explicit stop or escalation conditions;
- the exact output or state transition; and
- an objective `Complete when` condition.

A task must be copy-paste-ready for its designated executor. Include its objective, risk tier, task-specific scope, variables, dependencies, procedure, validation, stop conditions, output, and completion test. A compact shared state, risk, remote-write, and review-input policy can define common mechanics once. Do not duplicate that policy in every task. Include the complete task-local review or quality prompt where an independent executor needs it.

Replace all values that are already knowable. Use placeholders only for values that genuinely cannot be known until a predecessor completes. Name each placeholder precisely and state where the operator obtains its value.

Apply ASD-STE100 principles to all human-executed and non-executable tracking or control tasks. Improve clarity without reducing necessary detail.

## Compact shared policy and task-local boundaries

Create one compact shared section for state transitions, risk tiers, standing authority, remote-write preconditions, result separation, review-input classification, validation reuse, failure handling, and on-plan merge readiness. Do not create shared sections that hide task-specific product scope, security conditions, decision inputs, or completion predicates.

The compact resume state must retain only immutable predecessor outputs that a later task still needs. Key each value by producing task and exact output name, record its final consumer, and prune it after that consumer completes. During ingestion, require the producer to be complete and require the final consumer to remain incomplete. Before JSON parsing can change a value, reject non-finite numbers or numbers whose absolute value exceeds 9007199254740991 and require larger exact identifiers to use strings. When review state exists, require the current task head to equal the review-input head. Use closed bounded maps and reject duplicate JSON members during ingestion.

Keep these items task-local:

- issue or product requirements;
- repository and path scope;
- predecessor outputs and live identities;
- security and failure conditions;
- material intentional differences;
- independent review and quality prompts; and
- objective completion predicates.

Include complete task-local review-loop and quality-check prompts at each applicable point. Do not replace those independent-executor prompts with “follow the process above,” “repeat Task N,” or “use the standard process.” Common compact mechanics can remain in the shared section and do not need verbatim duplication.

Remove receipt catalogs, per-command approval records, prompt hashes, routing activation records, repeated completion records, and shared text copied into every leaf. Preserve product requirements, security behavior, failure truth, necessary independent gates, and all completion conditions.

## PR lifecycle and reciprocal-cycle safeguards

For every existing or future implementation PR covered by the plan, preserve these gates. Routine candidate preparation and publication can be one task. A landed handoff and immediately dependent comparison can be one task when no external wait or risk-tier change intervenes.

1. candidate implementation, applicable validation, non-force publication, accurate reviewer-facing body, and targeted readback;
2. one Codex and one Copilot review for the frozen reviewed input;
3. an independent final quality check on that same input;
4. a new review and quality pair only after code/diff change or a recorded material scope, behavior, or risk change;
5. merge only after both gates apply to the same final head, tree, and frozen semantics;
6. landed-commit handoff and cross-repository comparison or proved non-applicability; and
7. any required reciprocal implementation and the final fixed-point closure.

Serialize pairs for different reviewed inputs. If authenticated reviewed-input drift makes an unrequested old-input channel impossible, store one typed `SUPERSEDED` disposition only after every recorded request for the old input is terminal. Cross-validate that disposition against request existence, an incomplete channel set, one matching head, a known successor head, and a time not earlier than any described request; do not create synthetic evidence. Require a submitted review's commit to match the reviewed head. Attribute a headless Codex PR-conversation result only through authenticated author, request time, baseline exclusion, reviewed-input key, and serialized predecessor-pair order. Store conversation baselines as a node-ID-to-timestamp map.

Each applicable review-loop and quality task must retain current-head reviewer evidence, complete relevant pagination, unfinished-work and deferral audits, issue-requirement verification, PR-description verification, dependency verification, validation, and prohibition on premature merge.

Each review-loop task must identify the local Codex executor, GitHub Copilot, and `chatgpt-codex-connector` as distinct actors. It must apply the repository's applicable instructions, request remote Codex with an exact `@codex review` PR comment, and treat that trigger as neither a finding nor a local instruction. Preserve both submitted-review objects and attributable Codex PR-conversation comments. Use the native Codex interface. Permit headless `codex exec --json` only as an explicit fallback with equivalent scope, monitoring, mutation, timeout, and result controls.

Before review, generate and semantically verify the reviewer-facing body, then freeze its scope, behavior, and risk meaning. Keep task state, polling state, reviewer requests, review IDs, review results, quality results, metrics, audit records, and terminal results outside it. Classify a later change as `CODE_OR_DIFF`, `MATERIAL_SCOPE_BEHAVIOR_RISK`, `NON_MATERIAL_FACT`, `RESULT_OR_STATE`, or `COMMENT_ONLY`. Only the first two classes invalidate review. Raw PR-body byte inequality is not the classifier.

Default to one reviewer pair for each reviewed input. Reject a same-head request unless a recorded material scope, behavior, or risk reason changes that input. When a previously superseded reviewed-input key becomes current again, retain its disposition as history and resume its original incomplete pair without creating a duplicate request identity. Require every same-head re-request metric reason to contain only a nonempty reason string and Boolean material value. Generate a Copilot REST request from the typed reviewer specification with exact login `copilot-pull-request-reviewer[bot]`; reject the display name `Copilot`. Normalize empty, singleton, and multiple review API collections through the tested policy helper, and never treat an empty collection as a match. Persist unique request-event, review-run, submitted-review, and conversation-comment baselines with the in-flight attempt. Preserve Markdown backticks and Unicode and reject disallowed control characters. Treat a successful API response plus matching authenticated readback as the public-mutation boundary. A later local serialization failure cannot repeat the request. For an accepted request with no match, record `RECONCILING`; after at least 120 seconds, require complete negative request-event, requested-reviewer, submitted-review, and review-run readback before `NO_EFFECT`. Permit one retry for the reviewed input and channel; a second proved no-effect attempt is `EXHAUSTED`. Continue other safe work while reconciling. Do not send the Codex trigger until the Copilot request is confirmed or is terminally proved non-functional through a persisted `terminalDisposition` whose state is `REPOSITORY_AUTHORIZED_NON_FUNCTIONAL`, whose authority and reason are nonempty, and whose recorded time is not earlier than the Copilot request.

Do not allow an unreviewed material repair, stale review, or head change to bypass a required gate. A verified non-material factual correction, result, task-state update, audit record, or comment-only publication on the unchanged reviewed input does not require another code review.

## Renumbering and cross-reference requirements

After inserting the tasks for the new GitHub work items, renumber the entire remaining executable slate consecutively, beginning with `Task 1`.

The new Task 1 must be the first incomplete action in the verified execution order. Completed source tasks must not remain as executable tasks.

Update every affected reference, including:

- headings;
- prose references;
- dependency tables;
- predecessor and successor references;
- task ranges;
- execution-order statements;
- conditional branches;
- calendar overrides;
- trigger instructions;
- completion audits;
- `Complete when` clauses;
- prompts embedded in tasks; and
- references to repeated or future task instances.

Do not use broad search-and-replace without checking semantic meaning. Verify that each updated reference points to the intended task after renumbering. Confirm that task numbers are consecutive, unique, and ordered, with no gaps or duplicates.

Preserve every calendar constraint from the source plan. Update only its associated task number and any state that verified evidence shows has changed.

## Decision process

If a non-mechanical adjustment requires judgment, use this process before editing the output plan:

1. Validate the finding or proposed change. Determine whether it represents a material improvement or a real defect.
2. List the reasonable options before selecting one. Be exhaustive and consider permutations when applicable. Evaluate the options from relevant perspectives, including software engineering, new-developer usability, DevOps, documentation, project management, cybersecurity leadership, cybersecurity implementation, and business stakeholders.
3. Use primary-source research when it is needed to establish correctness.
4. Create a finding-specific weighted evaluation rubric. Do not reuse a rubric from another finding. Give technical correctness, security, failure behavior, usability, clarity, and plan integrity more weight than churn, implementation difficulty, or adherence to an outdated scope.
5. Describe the rubric before applying it.
6. Score every option in a table.
7. Select the highest-quality option supported by the evidence. State it in detailed ASD-STE100-compliant language that a person coming in cold can follow.
8. Apply the selected option.

Keep the options, rubric, scores, research, and decision analysis in `TEMP-*` files or report them separately. Do not put the decision-making process in the output plan.

Mechanical renumbering and direct preservation of unchanged source content do not require separate decision analysis.

## Document and validation requirements

The output plan must:

- stand alone without requiring the reader to consult the source plan;
- contain the full detail needed to execute every task;
- list tasks in chronological execution order;
- contain only numbered leaf tasks;
- preserve the one-at-a-time implementation rule and all reciprocal fixed-point behavior;
- contain no contradictions among task order, dependencies, conditions, and completion criteria;
- distinguish verified current state, immutable historical evidence, and future placeholders;
- avoid fabricated commits, trees, blobs, URLs, issue numbers, PR numbers, checks, reviews, or outcomes;
- avoid calling itself a revision or drawing attention to the editing history; and
- be markdownlint-compliant except for MD013.

Place a Markdown comment or frontmatter in the output plan that disables MD013. Do not insert unnecessary line breaks.

Write the document to disk incrementally. You may create temporary analysis files prefixed with `TEMP`, but do not mix analysis artifacts into the output plan.

Run one focused structural pass and one final semantic pass. Repeat only a failed or invalidated check. Across those passes, cover:

1. live-state and factual correctness;
2. preservation-ledger coverage;
3. dependency and chronological-order correctness;
4. task atomicity;
5. self-containment and copy-paste readiness;
6. PR lifecycle and reciprocal fixed-point preservation;
7. numbering and cross-reference integrity;
8. placeholders, identities, and completion conditions;
9. internal consistency and ASD-STE100 clarity; and
10. Markdown structure and markdownlint compliance.

Use the repository’s existing Markdown validation tooling when available. Do not add or update project dependencies solely to run this validation.

Before finishing, compare the output plan semantically with the source plan and the preservation ledger. Confirm that no remaining task, requirement, dependency, lifecycle gate, conditional path, calendar rule, evidence requirement, or completion condition was silently lost.

In the final response:

- identify the output plan;
- summarize where the new GitHub work items were inserted;
- state the resulting task-number range;
- report the validation performed and its results;
- disclose any intentional semantic change or unresolved uncertainty; and
- confirm that only the run-specific inputs must be changed to reuse this prompt in a future planning cycle.

Do not claim completion if the preservation audit or numbering audit fails.
