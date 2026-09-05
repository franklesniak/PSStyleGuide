<!-- markdownlint-disable MD013 -->

# Parent orchestration loop for the cross-repository action plan

Run this prompt from `C:\Users\flesniak\GitHub\PSStyleGuide` while the PSStyleGuide checkout is on `planning-CRT-PR-852`.

Execute `docs/planning/action-items-2026-08-30.md` in numbered order. Continue until all tasks are complete or the next action genuinely requires a human. Do not stop for routine approval, evidence, routing, or identity paperwork.

Use the user-selected `model-routing-advisor` for a coding task when it is available. The parent owns sequence, scope, state, validation, publication, and completion decisions.

## Repository map

- PSStyleGuide: `C:\Users\flesniak\GitHub\PSStyleGuide`
- TerraformStyleGuide: `C:\Users\flesniak\GitHub\TerraformStyleGuide`
- research-misc: `C:\Users\flesniak\GitHub\research-misc`

The plan, this prompt, and orchestration state belong only to the PSStyleGuide planning branch. Do not add them to an implementation branch or PR. When a task runs in another repository, pass the task objective, scope, risk tier, and completion conditions to its executor.

Preserve user work and unrelated dirty files. Use an isolated worktree when the current checkout is not a safe implementation surface. Do not expose credentials, tokens, cookies, or private state.

Do not use a Git command that discards work, including `git reset --hard`, `git clean`, or an overwriting checkout or restore. Use inspection, an isolated worktree, or another non-destructive method. Permit destructive Git recovery only when the current task expressly requires it as R3 work; identify and verify the exact repository and target, preserve unrelated work, and run the final R3 readiness check before the command.

## Standing authority

The operator's instruction to execute the numbered plan authorizes in-scope R0 and R1 work. It also authorizes an R2 action when the current numbered task expressly requires that action and all R2 controls pass. This authority includes local edits, append-only commits, non-force pushes, PR creation and updates, issue or review comments, review requests, and other reversible publication steps that the current task requires.

Do not request approval for a new commit SHA, tree, parent, content hash, branch name, or routine command when the work remains in scope. Record exact identities as execution checks and results, not as permission receipts.

The instruction to execute the numbered plan is also standing authority for an on-plan merge. A merge is on-plan only when the current numbered task expressly names it; the repository, PR, target branch, head commit, tree, and scope match that task; required review and checks pass for the same immutable head; no material change or unresolved feedback remains; the PR is mergeable; and the selected repository-permitted method does not bypass a control. Do not request separate operator approval for that merge.

Ask the operator when a merge is not on-plan, the task assigns a material decision to a human, or the work expands scope. Never infer permission for a force push, deletion, settings change, credential or permission change, protection change, administrator override, or gate bypass. These exceptional R3 actions require separate explicit authority even when a task names them.

Notify the operator as soon as a future exceptional action and its readiness conditions are known. The notification is not a stop condition. While authority is pending, continue every safe in-scope action that does not cross that boundary, including implementation, local validation, non-force topic publication, PR correction, CI diagnosis, review requests, finding repair, and final readiness work. Enter `waiting_human` only when the next concrete action requires the operator and no independent safe in-scope work remains. If the exceptional action is itself necessary to clear one final gate, complete every independent gate, identify the exact residual gate and cause, and do not weaken or bypass it.

## Risk tiers

Use the highest tier that applies to any action in the task.

| Tier | Scope | Required control |
| --- | --- | --- |
| R0 | Read-only inspection, planning, or local analysis | Targeted reads and a truthful result |
| R1 | Reversible routine work, commits, non-force topic pushes, PR or issue updates, comments, and review requests | Relevant validation, exact precondition, native result, and targeted readback |
| R2 | Trust roots, workflows, security policy, required checks, default-branch non-force bootstrap updates, or sensitive cross-repository convergence | Full applicable validation, exact identities, clean state, independent review when reviewable bytes change, and targeted readback |
| R3 | Merge, force, deletion, settings, credentials, permissions, branch protection, or gate changes | Standing plan authority for an on-plan merge; separate explicit authority for other R3 actions; all R2 controls, current green gates, required review, and an explicit final readiness check |

Risk controls are cumulative. Churn and implementation effort do not justify a weaker tier. A task can move to a higher tier if its action changes. It cannot move to a lower tier only to avoid a failed gate.

## Compact state machine

Use these states:

```text
pending -> active -> validating -> ready -> complete
                         |           |
                         |           +-> waiting_external -> ready
                         +-> active
no-safe-work human boundary -> waiting_human
any nonterminal state -> blocked
```

- `pending`: A predecessor is not complete or the task has not started.
- `active`: Analysis or implementation is in progress.
- `validating`: The final applicable gate set is running.
- `ready`: Validation passed and the next planned mutation can run.
- `waiting_external`: A CI, review, or other external result is pending.
- `waiting_human`: The next concrete action needs one exact human decision or exceptional authority, and no independent safe in-scope work remains.
- `complete`: The task's `Complete when` condition is true.
- `blocked`: The same genuine blocker has persisted after the required retry or decision process, and no safe work remains.

A validation failure returns the task to `active` for diagnosis and repair. A new review finding also returns the task to `active`. Do not call these states blocked while useful work remains.

## Compact state record

Use one untracked `TEMP-coding-agent-loop-state.json` file. It is a resume aid, not an evidence archive. Keep only:

```json
{
  "schema": 1,
  "plan": "docs/planning/action-items-2026-08-30.md",
  "current_task": {
    "number": 4,
    "state": "active",
    "risk": "R2",
    "repository": "franklesniak/PSStyleGuide",
    "branch": "agent/example",
    "base": null,
    "head": null,
    "last_gate": "<short-result-or-null>",
    "next_action": "<one-action>",
    "blocker": null
  },
  "predecessor_outputs": {},
  "completed": [1, 2, 3],
  "updated_utc": "2026-09-04T10:00:00Z"
}
```

The root file and `current_task` object are closed records. Keep immutable predecessor values that a later task still needs in `predecessor_outputs`. Key each value first by its producing task number and then by its exact output name. Store the value and `last_consumer_task`. Delete the value when that consumer completes. Do not retain full task results. Reject duplicate JSON member names before parsing the state file. Before JSON parsing can change a number, reject a non-finite token or a token whose absolute value exceeds 9007199254740991; store a larger exact identifier as a string. During ingestion, require every output producer to be a completed task, reject an output whose final consumer is not later than its producing task, and reject an output whose final consumer has already completed. When review state exists, require `current_task.head` to equal the review-input head. Also reject a reversed reconciliation interval, a terminal no-effect interval shorter than 120 seconds, and a Codex request without one eligible same-input Copilot predecessor whose request time is not later than the Codex request time.

When the current task uses the review loop, add only one `review` member under `current_task`; its closed shape contains the reviewed input, mutation class, request records, typed superseded-input dispositions, separate reviewer results, public-mutation reconciliation attempts, metrics, and comment publications. The actual resume file must validate against `docs/planning/review-loop-policy.json`. Do not place review-loop fields beside the six root fields.

Write the state at task start, after a meaningful implementation or validation boundary, after a remote mutation readback, before a real wait, and at task completion. Do not write it for unchanged status probes.

Do not create activation, capability, routing, bypass, manifest, prompt-change, continuation, retry, validation-tier, or per-mutation receipt catalogs. Do not hash the prompt or reconcile state because prompt text changed. If the active task text changes materially, re-read that task, retain valid product work, and repeat only the affected analysis or validation.

Git commits, GitHub objects, CI runs, review state, and the one final task validation record are the primary evidence. Historical `TEMP-*` receipts can remain as incident evidence, but they are not prerequisites for continuation.

## Task loop

For each numbered task:

1. Read the exact task and its active dependencies. Do not load all completed task bodies.
2. Confirm each predecessor's actual completion condition. Use live state only when the condition is mutable.
3. Locate and obey the applicable `AGENTS.md`. If no `AGENTS.md` applies, read the repository root `CLAUDE.md` as compatibility workflow instructions; the filename does not change the executor.
4. Classify the task as R0, R1, R2, or R3. Record the tier in compact state.
5. Inspect only the repositories, refs, issues, PRs, checks, reviews, settings, and paths that can affect this task.
6. Select the executor. Use `model-routing-advisor` once for a new coding task or a genuine capability-driven reroute. Do not create an activation receipt.
7. Give one executor the task objective, repository, branch, base, allowed scope, risk tier, known findings, required validation, and completion test.
8. Keep analysis and implementation in that executor while it remains healthy. Reuse it after an ordinary recoverable failure.
9. For each non-mechanical finding, validate the feedback, list reasonable options, create a finding-specific weighted rubric, score the options in a table, state the selected option in ASD-STE100 language, and then implement.
10. Inspect the diff and run applicable validation. Run cheap deterministic checks first and the full gate set once on the final unchanged bytes.
11. Perform authorized publication in the order required by the task. Check the exact preimage immediately before each write and read back only the affected object after it.
12. Verify the task's `Complete when` condition. Record one final validation result and mark the task complete.
13. Advance immediately to the next satisfied task.

Do not split one useful action into separate issue, commencement, branch, commit, push, and PR paperwork tasks when the active plan permits them in one task. Do not invent work when the plan is complete.

## Routing

Use the advisor recommendation unless an explicit task requirement overrides it. Record the selected model and reasoning effort only in compact state or the final task result. The runtime's accepted route is enough; do not create proof of selector activation, model catalog availability, service tier, or effective override unless the task is specifically about routing behavior.

If the numbered task specifies an exact model or reasoning effort, request that exact route and do not substitute another model or effort. If the runtime rejects the request and no already-permitted interface can request the same route, use `waiting_human` and state the exact limitation. If the runtime accepts the request but does not expose the effective setting, continue and record that limitation only in compact state or the final task result.

Run numbered tasks in order. Use one executor at a time. The task executor must not create descendants. A descendant is permitted only when the user or current numbered task explicitly requests subagents and the parent defines independent scope and ownership before dispatch; this serial plan does not activate that exception. For a `Coding agent executable` task, the assigned executor performs the substantive implementation. The parent can maintain compact state, inspect the work, run independent validation, reconcile remote state, and make completion or retry decisions. Do not reroute merely because a test failed. Reroute only when the task changes materially or concrete evidence shows that the selected executor cannot perform it.

## Validation

Use risk-proportionate validation:

- R0: validate the queried identity and the claimed result.
- R1: run tests and linters affected by the diff, inspect the complete diff, and run repository-required gates once on final bytes.
- R2: run the complete applicable local gate set, inspect identities and scope, test security failure paths, and obtain required independent review for reviewable changes.
- R3: satisfy R2, refresh all required checks and reviews on the exact final head and tree, and perform a final readiness check immediately before action.

Do not rerun an expensive passing gate when its code, inputs, dependencies, and environment are unchanged. A later change invalidates only affected results. Do not duplicate a successful executor gate solely to create parent evidence; the parent may validate high-risk or uncertain predicates that need an independent check.

Preserve native exit codes and useful bounded output. Failed, skipped, neutral, canceled, missing, pending, stale, timed-out, expired, and ambiguous results are not success. Do not weaken a gate to make it pass.

## Remote operations

Before a remote write:

1. Confirm repository, target, operation class, local identity, clean state, expected remote preimage, force mode, and required gates.
2. Stop that write on drift or failed validation. Continue unrelated safe work.
3. Execute once. Do not retry an ambiguous non-idempotent operation.
4. Validate the native response.
5. Perform one targeted authenticated readback of the changed ref or object.
6. Record the exact postimage in compact state or the final task result.

Paginate only the connection whose completeness is required for the current decision. Do not capture unrelated repository-wide snapshots before a routine write. Respect service rate limits without creating timing receipts.

## CI, review, and merge

Check CI before merge. Do not merge when any required check is red, skipped, canceled, missing, pending, stale, timed out, or expired.

Use repository-required review for R1. Use an independent review for R2 when reviewable bytes change. R3 merge requires the exact reviewed head and tree, resolved material findings, a truthful PR body, current green required checks, and a mergeable state. A code or material risk-description change invalidates review of the old bytes. A status record or comment does not.

For a planned dual-review task, generate and semantically verify the reviewer-facing body before the first request. Freeze its scope, behavior, and risk meaning. Keep task state, polling state, reviewer requests, review IDs, review results, quality results, metrics, audit records, and terminal results in compact state or separate comments. Never append them to the frozen reviewer-facing body.

Classify a later change as `CODE_OR_DIFF`, `MATERIAL_SCOPE_BEHAVIOR_RISK`, `NON_MATERIAL_FACT`, `RESULT_OR_STATE`, or `COMMENT_ONLY`. The first two classes invalidate review. The other classes do not. Raw PR-body byte inequality is not the classifier. Reject a same-head request unless a recorded material scope, behavior, or risk reason changes the reviewed input. Before a pair starts for a new reviewed-input key, require every earlier pair for every different key to contain both channels and be terminal. If authenticated readback proves reviewed-input drift that makes an unrequested old-input channel impossible, including drift on an unchanged head, record one typed `SUPERSEDED` disposition with the old input, successor head, time, and reason only after every recorded old-input request is terminal. Cross-validate the disposition against request existence, an incomplete channel set, one matching head, a known successor head, and a time that is not earlier than any described request. If that superseded key later becomes current again, validate and retain its disposition as history, ignore it only for current-input gating, and resume the original incomplete pair without creating a duplicate request identity. Do not synthesize the missing request or attribute successor-input evidence to the old input. Then capture fresh baselines. Before persisting metrics, require each same-head re-request reason record to contain only a nonempty `reason` string and Boolean `material` value.

Persist Copilot results separately from Codex results. Preserve both Codex result channels. Require a submitted review's commit to match the reviewed head. Pass the complete persisted request collection to Codex result collection. Accept a headless `chatgpt-codex-connector` PR-conversation result only when the authenticated author, request time, baseline exclusion, reviewed-input key, and one eligible same-input Copilot predecessor whose request time is not later than the Codex request time attribute it to the request. Reject an orphan, premature, or reverse-ordered Codex request during compact-state ingestion and every request decision. Normalize empty, singleton, and multiple API collections with the tested policy helper; an empty collection is not a match. Preserve Markdown backticks and Unicode and reject disallowed control characters.

Generate a GitHub Copilot REST request only from the typed policy specification. The exact reviewer login is `copilot-pull-request-reviewer[bot]`; do not send the display name `Copilot`. Capture the native status and response body. A successful public API response plus matching authenticated readback confirms the mutation; later local serialization failure cannot repeat it. If an accepted request has no matching readback, record `RECONCILING` and continue other safe work. Wait at least 120 seconds, then require complete negative readback from new request events, current requested reviewers, matching submitted reviews, and matching Copilot review runs before recording `NO_EFFECT`. Permit only one retry for the same reviewed input and channel. A second proved no-effect attempt is `EXHAUSTED`. Do not send the serialized Codex trigger until the Copilot request is confirmed or is terminally proved non-functional through a persisted `terminalDisposition` whose state is `REPOSITORY_AUTHORIZED_NON_FUNCTIONAL`, whose authority and reason are nonempty, and whose recorded time is not earlier than the Copilot request.

Persist the unique request-event, review-run, submitted-review, and node-ID-to-timestamp conversation-comment baselines with the in-flight attempt before or at the confirmed mutation. After each confirmed reviewer request and its targeted readback, persist its head, reviewed-input key, request time, `confirmed: true`, and nonterminal state in `current_task.review` before another public mutation. Use `confirmed` only for authenticated request readback. Mark the request terminal only after an attributable terminal result or an exact repository-authorized non-functional disposition. If the local state write fails, reconstruct the request from targeted remote readback and do not repeat a confirmed request.

The deterministic planning-only policy and scenarios are in `docs/planning/review-loop-policy.json`, `docs/planning/review-loop-policy.mjs`, and `docs/planning/review-loop-policy.test.mjs`. The module operates on the nested `current_task.review` value, and the schema validates the enclosing resume file. They validate decisions and transport. They do not perform GitHub writes.

An anticipated approval boundary does not defer CI or review work that can run safely before that boundary. Request the approval early, continue toward a clean reviewed head, and stop only at the exact action that needs the approval. When that action is required before one final check can become green, finish all other checks and reviews and report that single dependency precisely.

Immediately before an on-plan merge, repeat the final readiness check against the live PR and target ref. Use head-commit matching when the merge tool supports it. Stop for drift, new material feedback, an incomplete or failed required gate, an off-plan target or scope, a required human decision, or any need for an administrator override or bypass. Do not stop only to obtain another approval for a merge that still satisfies the on-plan definition.

Do not request duplicate AI reviews on an unchanged head without a material reason. Do not require two named AI reviewers and a separate fresh-agent pass for routine low-risk work unless repository policy or the task names that gate.

## Failure, retry, and waiting

Diagnose every failed gate. Apply the finding decision process before a non-mechanical repair. Preserve failed public evidence; do not rewrite it as success.

Continue after ordinary code, test, tool, or infrastructure failures while a safe repair or alternative exists. A new commit identity is progress, not a human blocker.

Use `waiting_external` only when an external result is genuinely pending and no independent work remains. Use `waiting_human` only when the next concrete action needs one exact human decision or exceptional authority and no independent safe in-scope work remains. Notify the operator early, state the minimum requested decision in plain English, and continue safe preparation until that exact boundary. Use `blocked` only after the same blocker has persisted through the applicable retry or decision process and no safe progress remains.

Provide short user updates at meaningful boundaries. Do not create persistent 15-second or 60-second monitoring records. A quiet, live test is not stalled.

## Resume and migration

Resume from Git, GitHub, CI, review state, the compact state file, and the current task. Do not revalidate historical receipt graphs. Do not restart a completed task unless a live completion predicate changed.

Adopt this compact policy for the current Task 4. Preserve its existing C6 and B6 commits, failed CI evidence, validated finding decisions, and active executor. Do not restart Task 4 because the orchestration policy changed.

## Completion

The goal is complete when every numbered task satisfies its `Complete when` condition and no real blocker remains. The final audit checks current task status, final repository commits and trees, required CI and review state, open material findings, planned fixed-point conditions, and any unresolved human decisions. It does not replay receipt catalogs or hash every historical control artifact.

The final report includes:

- completed, skipped, and blocked tasks;
- final PSStyleGuide and TerraformStyleGuide commits and trees;
- relevant issues and PRs;
- final validation, CI, and review results;
- material intentional differences and residual risks; and
- any action that still requires a human.
