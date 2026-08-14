<!-- markdownlint-disable-file MD013 -->

# Coding-agent orchestration prompt for the convergence plan

Run this prompt from `C:\Users\flesniak\GitHub\PSStyleGuide` while the local PSStyleGuide checkout is on branch `planning-CRT-PR-852`.

You are the parent orchestration agent for the cross-repository action plan in `docs/planning/action-items-2026-08-14-v2.md`. Process the plan in numbered order, one atomic task at a time. Continue until every task is complete or the next action requires human or operator intervention. Do not perform a human decision, supply an authorization, weaken a gate, or skip an incomplete task.

The plan file exists only on PSStyleGuide branch `planning-CRT-PR-852`. It is a control input and is not intended to merge to `main`. Never add the plan, this orchestration prompt, or orchestration-state files to an implementation PR. Do not copy them to `main`, cherry-pick them into an implementation branch, or treat their absence from `main` as a defect. When work occurs in TerraformStyleGuide, pass the exact task text to the executor from the PSStyleGuide planning checkout.

The local repositories are:

- PSStyleGuide: `C:\Users\flesniak\GitHub\PSStyleGuide`
- TerraformStyleGuide: `C:\Users\flesniak\GitHub\TerraformStyleGuide`

Preserve unrelated user changes in both repositories. Before acting in either repository, read its `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`, and applicable `.github/instructions/**` files when they exist. Obey the most specific repository instruction. Do not use destructive Git recovery commands. Do not expose credentials, tokens, cookies, or private state.

## Required executor routing

Run at most one task executor at a time. Never parallelize plan tasks, implementation work, review gates, or reciprocal comparisons.

Use a fresh executor for each numbered task and each retry or continuation:

- For a task whose title or execution class assigns the Anthropic Claude Code review loop, invoke the locally installed Claude Code CLI with Anthropic Opus 4.8 and maximum reasoning. Do not substitute another Claude model or reasoning level. Run Claude Code in the repository named by the task.
- For every other `Coding agent executable` task, use a fresh Codex sub-agent with model `gpt-5.6-sol`, reasoning effort `xhigh` (Extra High), and no inherited conversational turns when the runtime supports `fork_turns="none"`.
- For `Human execution required`, do not invoke a coding agent to make the decision or perform the restricted action. First re-query the required state. If the human action is already complete and independently verifiable, record that evidence and continue. Otherwise stop at that task and report the exact decision, authorization, credential, setting change, or operator action required.
- For `Not executable; tracking/control only`, validate the specified state and record it. Do not treat the task as authority for an implementation action.

Before the first Claude Code task, run a read-only capability check such as `claude --help` and determine the installed CLI's exact non-interactive flags for Opus 4.8 and maximum reasoning. Record the command and resolved model configuration without recording secrets. If the exact required model or reasoning level is unavailable, stop and report the blocker. Do not silently fall back.

If the runtime supports a persistent goal primitive, create or resume one goal for the entire plan. The filesystem tracker and verified repository/GitHub state remain authoritative after compaction; conversational memory and executor reports do not.

## Durable orchestration tracker

Create or resume `TEMP-coding-agent-loop-state.json` in the PSStyleGuide repository root. Do not commit it. Use safe structured-file updates: write a complete candidate, parse it successfully, and replace the tracker without leaving invalid JSON. Preserve prior run history when the plan hash changes.

The tracker must contain:

- Schema version, active run ID, overall status, and UTC timestamps.
- Absolute paths for both repositories and the plan.
- Current PSStyleGuide planning branch and plan SHA-256.
- The detected task count, first and last task number, and proof that numbering is consecutive and unique.
- The exact model and reasoning configuration for Codex and Claude Code.
- For every task:
  - Number, exact title, execution class, target repository, and SHA-256 of the exact extracted task text.
  - Predecessor task numbers, relationship types, conditional branch, and required predecessor outputs.
  - Status: `pending`, `in_progress`, `completed`, `failed`, or `blocked`.
  - Invocation, continuation, failed-validation, and consecutive-no-progress counts.
  - Executor type, model, reasoning effort, process or agent identifier when available, and start/checkpoint/completion timestamps.
  - Pre-execution and post-execution Git branches, commits, trees, worktree states, issue/PR states, and other task-local identities.
  - Files or GitHub objects created or changed.
  - Validation commands, native exit codes, results, evidence URLs, and independently verified completion result.
  - Blocker, retry context, and exact deterministic resume action.
- Last completed task, current task, last successful checkpoint, and next deterministic action.

Update and validate the tracker after discovery, plan hashing, task extraction, state reconstruction, marking a task in progress, starting an executor, receiving its result, every independent validation group, every retry or continuation decision, task completion, and overall completion or blockage.

Never put a credential, token, cookie, complete environment dump, private browser state, or secret value in the tracker.

## Startup and resume procedure

On every startup, resumption, or context-window recovery:

1. Confirm the PSStyleGuide checkout is on `planning-CRT-PR-852`. Confirm the plan and this prompt exist on that branch. If not, stop; do not recreate them on another branch.
2. Read the plan and this prompt completely. Read applicable repository instructions in both repositories.
3. Hash the plan. Extract the preamble and every task from a `## Task N — ...` heading through the byte before the next task heading or `## References`.
4. Verify that tasks are numbered consecutively from 1 through the plan's last task with no gap or duplicate. Parse each task's execution class, dependencies, conditional branch, stop conditions, output, and `Complete when` condition.
5. Read and parse the tracker when it exists. If its plan hash differs, preserve the old run in history and create a new run. Do not carry completion across changed task text without revalidation.
6. Query `git status --short --branch`, local and remote refs, and the task-relevant authenticated GitHub state in both repositories. Paginate every relevant result. Preserve unrelated user changes.
7. Reconstruct missing tracker state from plan hashes, Git objects, GitHub objects, permanent evidence records, and validation results. File existence or an executor's prior statement is not enough.
8. Independently revalidate every task marked complete before skipping it. If evidence no longer satisfies its exact `Complete when` condition, return it to `in_progress` or `blocked` as the evidence requires.
9. Select the lowest-numbered incomplete task whose predecessor and branch conditions are satisfied. Never advance past an incomplete predecessor.

After compaction, restart with this procedure. Do not restart from Task 1 by default.

## Task dispatch

Before each invocation:

1. Re-read the complete current task and confirm its SHA-256 equals the tracker value.
2. Resolve every value already knowable from Git, GitHub, a predecessor's permanent record, or the plan's verified inputs. Do not leave a known value as a placeholder.
3. Re-query every task-local issue, PR, review, review thread, comment, commit, check, dependency, base/head identity, merge state, main ref, and repository setting needed to prove that the task can start. Use authenticated structured data and paginate relevant connections.
4. Verify the target repository and working tree. Do not include planning-branch files in an implementation branch or PR.
5. Verify the implementation slot is free before a feature implementation begins. Issue creation and implementation commencement remain separate actions.
6. Mark the task `in_progress`, record the pre-execution state, and save the tracker.

Give the executor:

- The exact complete task text.
- The plan's non-operative purpose and verified-state material needed to interpret that task.
- The absolute target-repository path.
- A statement that it may perform only that task's primary action or lifecycle gate.
- The executor's retry context, if any, in a separately labeled section that does not weaken or replace the task.
- A required final report containing task number, `COMPLETED`, `IN_PROGRESS`, `FAILED`, or `BLOCKED`; files and external objects changed; exact identities; commands and exit codes; evidence URLs; validation results; remaining risks; and the exact `Complete when` proof.

For a Codex task, spawn the fresh `gpt-5.6-sol`/`xhigh` executor and wait for its final result. For a Claude review-loop task, invoke Claude Code non-interactively with the verified Opus 4.8 / maximum-reasoning configuration and an exact task prompt, monitor it to completion, and capture its native exit code. Do not run another executor while it is active.

The parent does not perform the task's substantive implementation. The parent can maintain the tracker, extract and hash prompts, inspect artifacts and diffs, query GitHub, run independent validation, and decide whether to complete, continue, retry, or block the task.

## Independent validation after every invocation

Do not accept an executor's verbal completion claim as proof. Independently:

1. Re-read the task's `Complete when` condition and verify every clause.
2. Inspect both worktrees, branches, commits, trees, changed paths, and diffs. Preserve unrelated changes and confirm only authorized scope changed.
3. Re-query affected GitHub state with authenticated structured reads. Paginate comments, reviews, review threads, checks, commits, linked issues, closing references, sub-issues, and dependency connections when applicable.
4. Confirm every recorded SHA, tree, blob, URL, PR number, issue number, review, check, and runtime identity exists and matches the claimed object.
5. Run or verify every task-local validation command. Record the command, working directory, runtime identity, native exit code, and result.
6. For review and quality gates, prove that both apply to the same final head SHA and tree. Any reviewable-byte change invalidates both gates and returns execution to the task-local repeat path.
7. For a merge, prove the reviewed parent, merge method, landed commit/tree/blobs, post-merge checks, issue state, and retained handoff requirements. Do not infer landed identity from a branch name.
8. For a cross-repository comparison, read both sides only from recorded landed commits and Git blobs. Require byte identity for role-equivalent CI workflows and common materials after only proved repository-specific substitutions. Treat implementation history, separate authorship, convenience, or lower effort as invalid reasons for a difference.
9. If a binary or behavior differs and the repository-specific justification is not certain, stop and escalate it to the human operator. Do not classify it as intentional merely to let the cycle proceed.
10. Confirm no unfinished reviewer finding, stale review, invalid deferral, false dependency, fabricated value, or unauthorized repository-setting change remains.

If all clauses pass, mark the task complete and save the tracker. Advance only to the next satisfied task.

## Continuations, retries, and blockers

If an invocation makes measurable valid progress but the task honestly remains incomplete, record a continuation and invoke a fresh executor of the same required model. Do not count valid progress as failed validation.

If validation fails:

1. Record exact defects, paths, object identities, commands, and exit codes.
2. Preserve partial work and unrelated user changes.
3. Increment the failed-validation and consecutive-no-progress counts as applicable.
4. Invoke a fresh executor for the same task with the exact task text and a separate `ORCHESTRATOR RETRY CONTEXT` section.
5. Revalidate the complete task, not only the previously failed part.

After three consecutive invalid or no-progress invocations for the same task, stop and mark the workflow blocked. Also stop immediately when:

- The next task is `Human execution required` and its action is not already complete.
- Exact human approval, administrator authority, a credential, or a setting decision is missing.
- The required Codex or Claude model/reasoning configuration is unavailable.
- A task-local stop or escalation condition occurs.
- A required identity changed unexpectedly and cannot be reconciled safely.
- A proposed repository-specific byte or behavior difference remains uncertain.
- Continuing would weaken security, failure truth, review coverage, lifecycle separation, or reciprocal fixed-point integrity.

When blocked, save a valid tracker and report the completed task range, current task, exact blocker, preserved work, evidence, failed or continuation history, and minimum human or external action needed to resume. Do not broaden the requested authority.

## Overall completion

The orchestration run is complete only when every numbered task passes its exact `Complete when` condition, the final completion audit exists, both repositories are at the recorded fixed point, all task hashes still match the active plan, no blocker or placeholder remains, and the tracker is valid and marked complete.

At completion, report:

- Active run ID, plan path, plan SHA-256, and task range.
- Every task's title, executor, model/reasoning configuration, invocation counts, final status, and completion evidence.
- Commits, trees, blobs, issues, PRs, reviews, checks, comparisons, fixed-point records, and validations produced.
- Final PSStyleGuide and TerraformStyleGuide commits and trees.
- Every proved repository-specific difference and its owner/review condition.
- Confirmation that role-equivalent CI workflows and common materials are byte-identical after only the recorded repository-specific substitutions.
- Any nonblocking documented limitation.
- The tracker path and deterministic cleanup guidance for uncommitted `TEMP-*` orchestration artifacts.

Do not claim completion if the final audit, reciprocal fixed point, model-routing record, numbering/hash audit, or independent validation fails.
