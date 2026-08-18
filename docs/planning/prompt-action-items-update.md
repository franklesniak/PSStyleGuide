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

Every numbered item in the output plan must be an atomic leaf task. An atomic task has one executor, one primary action or lifecycle gate, and one objectively testable completion result. Do not use numbered parent tasks that contain independently executable child tasks.

Separate the following into discrete tasks whenever they apply:

- creating or updating an issue;
- explicitly commencing implementation of that issue;
- implementing the change;
- creating or updating the PR;
- running the Codex review loop in a fresh subagent;
- running an independent final quality check in a fresh coding-agent session;
- making a human or administrator decision;
- changing repository settings after exact authorization;
- merging the PR;
- publishing the landed handoff;
- performing the cross-repository comparison;
- implementing any required reciprocal sync-back;
- repeating review and quality gates after reviewable bytes change;
- performing the final reciprocal comparison;
- closing a fixed point; and
- closing a tracker or umbrella issue.

Do not combine issue creation with implementation commencement. Do not combine implementation, review, final quality checking, and merge. Do not treat a tracker, comparison, evidence-publication action, or closure action as implementation merely because it is part of the same issue cycle.

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

A task must be fully self-contained and copy-paste-ready for its designated executor. A person or coding agent coming in cold must not need instructions from another task, a shared execution contract, an earlier template, or an implied convention to execute it correctly. A dependency may identify a predecessor’s required output, but it must not outsource the current task’s procedure to that predecessor.

Replace all values that are already knowable. Use placeholders only for values that genuinely cannot be known until a predecessor completes. Name each placeholder precisely and state where the operator obtains its value.

Apply ASD-STE100 principles to all human-executed and non-executable tracking or control tasks. Improve clarity without reducing necessary detail.

## Prohibition on shared operative sections

Do not create or retain shared or generalized operative sections that apply instructions to multiple tasks. This prohibition includes sections equivalent to:

- a global execution contract;
- general execution rules;
- a mandatory PR lifecycle;
- a reciprocal fixed-point contract;
- a target common foundation;
- a shared quality-check procedure;
- a shared review-loop procedure; or
- a common task template that individual tasks merely reference.

Fold every applicable requirement from such source sections into every task that needs it. Include complete task-local review-loop and quality-check prompts at each applicable point. Do not replace them with “follow the process above,” “repeat Task N,” “use the standard process,” or similar references.

After folding the requirements into the relevant tasks, remove the shared operative sections from the output plan. Non-operative title, purpose, verified-state, phase-heading, and reference material may remain only when no task depends on those sections for execution instructions.

Do not shorten, summarize, or generalize existing task content merely to control the document’s length. Preserve the semantic detail of the source task slate.

## PR lifecycle and reciprocal-cycle safeguards

For every existing or future implementation PR covered by the plan, preserve the discrete lifecycle:

1. candidate implementation;
2. Codex review loop in a fresh `gpt-5.6-sol` subagent with `xhigh` reasoning;
3. independent final quality check by a fresh coding agent;
4. rerun of the review loop and quality check if reviewable repository bytes change;
5. merge only after both gates apply to the same final head and tree;
6. landed-commit handoff;
7. cross-repository comparison or proved non-applicability;
8. any required reciprocal implementation, review, quality check, and merge;
9. reverse comparison and sync-back when required; and
10. fixed-point closure.

Each applicable review-loop and quality-check task must retain all existing safeguards concerning current-head reviewer evidence, review-thread and comment pagination, unfinished-work and deferral audits, issue-requirement verification, PR-description verification, dependency verification, validation, and prohibition on merge.

Each review-loop task must identify the local Codex subagent as the executor and `chatgpt-codex-connector` as a separate remote reviewer. It must instruct the subagent to use the repository's applicable `AGENTS.md`. If the target repository has no `AGENTS.md`, it must explicitly tell Codex to read the root `CLAUDE.md` as compatibility workflow instructions and state that the filename does not change the executor. It must request the remote reviewer with an exact `@codex review` PR comment and treat that trigger comment as neither a finding nor an instruction to the local executor. Use the native Codex subagent interface. Permit headless `codex exec --json` only as an explicit fallback when native subagents are unavailable and the task defines equivalent monitoring and safety controls.

Do not allow an unreviewed repair, metadata correction that invalidates evidence, stale review, or head change to bypass a required gate.

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

Run as many review passes as necessary, up to 10. Include dedicated passes for:

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
