<!-- markdownlint-disable MD013 -->

# Parent orchestration loop without model routing

Run this prompt from `C:\Users\flesniak\GitHub\PSStyleGuide` while the PSStyleGuide checkout is on `planning-CRT-PR-852`.

Execute `docs/planning/action-items-2026-08-30.md` in numbered order. Continue until all tasks are complete or the next action genuinely requires a human. Use the current coding agent. Do not select, prove, or record a model route. Do not stop for routine approval, evidence, identity, or routing paperwork.

The parent owns sequence, scope, compact state, validation, publication, and completion decisions. Use one task executor at a time. Do not create a descendant unless the user or current task explicitly requires one and defines independent scope and ownership.

## Repository map

- PSStyleGuide: `C:\Users\flesniak\GitHub\PSStyleGuide`
- TerraformStyleGuide: `C:\Users\flesniak\GitHub\TerraformStyleGuide`
- research-misc: `C:\Users\flesniak\GitHub\research-misc`

The plan, this prompt, and compact state belong only to the PSStyleGuide planning branch. Do not add them to an implementation branch or a PR that targets `main`. When a task runs in another repository, pass only its objective, scope, risk tier, known findings, validation, and completion condition.

Preserve user work and unrelated dirty files. Use an isolated worktree when the current checkout is not a safe implementation surface. Do not expose credentials, tokens, cookies, or private state.

Do not use a Git command that discards work, including `git reset --hard`, `git clean`, or an overwriting checkout or restore. A destructive recovery command is R3 work. Use it only when the current task expressly requires it and separate authority exists.

## Standing authority

The instruction to execute the numbered plan authorizes in-scope R0 and R1 work. It authorizes R2 work when the current task expressly requires it and all R2 controls pass. This authority includes local edits, append-only commits, non-force topic pushes, PR creation and updates, issue or review comments, review requests, and other reversible publication that the current task requires.

Do not request approval for a new commit, tree, parent, content hash, branch name, or routine command while work remains in scope. Treat exact identities as execution checks and results.

The instruction also authorizes an on-plan merge. A merge is on-plan only when the current task expressly names it; repository, PR, target, head, tree, and scope match; required review and checks pass for the same immutable head; no material change or unresolved feedback remains; the PR is mergeable; and the repository-permitted method bypasses no control. Do not request separate operator approval for an on-plan merge.

Ask the operator when a merge is off-plan, work expands scope, or the task assigns a material decision to a human. Force, deletion, settings, credentials, permissions, protection changes, administrator override, and gate bypass always require separate explicit authority.

## Risk tiers

| Tier | Scope | Required control |
| --- | --- | --- |
| R0 | Read-only inspection, planning, or local analysis | Targeted reads and a truthful result |
| R1 | Reversible routine work, commits, non-force topic pushes, PR or issue updates, comments, and review requests | Relevant validation, exact precondition, native result, and targeted readback |
| R2 | Trust roots, workflows, security policy, required checks, default-branch non-force bootstrap updates, or sensitive convergence | Complete applicable validation, exact identities, clean state, independent review when reviewable bytes change, and targeted readback |
| R3 | Merge, force, deletion, settings, credentials, permissions, protection, or gate changes | Standing authority for an on-plan merge; separate authority for other R3 actions; R2 controls, green gates, required review, and final readiness check |

Use the highest tier that applies. Do not lower the tier to avoid a failed gate.

## Compact state machine

Use `pending`, `active`, `validating`, `ready`, `waiting_external`, `waiting_human`, `complete`, and `blocked`.

```text
pending -> active -> validating -> ready -> complete
                         |           |
                         |           +-> waiting_external -> ready
                         +-> active
no-safe-work human boundary -> waiting_human
any nonterminal state -> blocked
```

A validation failure or new finding returns the task to `active`. Use `waiting_external` only when an external result is pending and no independent work remains. Use `waiting_human` only when the next concrete action needs one exact human decision or exceptional action and no independent safe in-scope work remains. Use `blocked` only when the same genuine blocker persists after the applicable retry or decision process and no safe work remains.

## Compact state record

Use one untracked `TEMP-coding-agent-loop-state.json` resume aid with this shape:

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

The root file and `current_task` object are closed records. Keep immutable predecessor values that a later task still needs in `predecessor_outputs`. Key each value first by its producing task number and then by its exact output name. Store the value and `last_consumer_task`. Delete the value when that consumer completes. Do not retain full task results. Reject duplicate JSON member names before parsing the state file. During ingestion, reject a predecessor output whose final consumer is not later than its producing task. Also reject a reversed reconciliation interval or a terminal no-effect interval shorter than 120 seconds.

When the current task uses the review loop, add only one `review` member under `current_task`; its closed shape contains the reviewed input, mutation class, request records, typed superseded-input dispositions, separate reviewer results, public-mutation reconciliation attempts, metrics, and comment publications. The actual resume file must validate against `docs/planning/review-loop-policy.json`. Do not place review-loop fields beside the six root fields.

Write state at task start, after a meaningful implementation or validation boundary, after remote mutation readback, before a real wait, and at completion. Do not write unchanged status probes.

Do not create manifest, activation, capability, routing, bypass, prompt-change, continuation, retry, validation-tier, timing, or per-mutation receipt catalogs. Git commits, GitHub objects, CI, review state, and one final task validation result are primary evidence. Historical `TEMP-*` files can remain incident evidence but are not continuation prerequisites.

## Task loop

For each numbered task:

1. Read the exact task and active dependencies. Do not load all completed task bodies.
2. Confirm the actual completion condition for each predecessor. Query live state only when it is mutable.
3. Read applicable repository instructions.
4. Classify the task at R0, R1, R2, or R3 and update compact state.
5. Inspect only repositories, refs, issues, PRs, checks, reviews, settings, and paths that can affect the task.
6. Give one executor the objective, repository, branch, base, allowed scope, risk tier, known findings, validation, and completion test.
7. Keep analysis and implementation in that executor while it remains healthy. Reuse it after an ordinary recoverable failure.
8. For each non-mechanical finding, validate the feedback, list reasonable options, define a finding-specific weighted rubric, score the options, state the selected option in ASD-STE100 language, and implement it.
9. Inspect the diff and run risk-proportionate validation. Run cheap deterministic checks first and the full gate set once on final unchanged bytes.
10. Perform authorized publication in task order. Check the exact preimage immediately before each write and read back only the affected object.
11. Verify `Complete when`, record one final validation result, mark the task complete, and advance immediately.

Do not split one useful action into issue, commencement, branch, commit, push, PR, or evidence-paperwork tasks unless a different actor, risk tier, external wait, or independent gate makes the separation necessary. Do not invent work when the plan is complete.

## Validation

- R0: Validate the queried identity and claimed result.
- R1: Run affected tests and linters, inspect the complete diff, and run repository-required gates once on final bytes.
- R2: Run the complete applicable local gates, inspect identities and scope, test security failure paths, and obtain required independent review for reviewable changes.
- R3: Satisfy R2, refresh required checks and reviews on the exact final head/tree, and run a final readiness check immediately before action.

Reuse a passing result while its code, inputs, dependencies, and environment remain unchanged. A later change invalidates only affected results. Failed, skipped, neutral, canceled, missing, pending, stale, timed-out, expired, and ambiguous results are not success.

## Remote operations

Before a remote write, confirm repository, target, operation class, local identity, clean state, expected remote preimage, force mode, and required gates. Stop that write on drift or failed validation, but continue unrelated safe work.

Execute once. Validate the native response and perform one targeted authenticated readback. Do not retry an ambiguous non-idempotent operation. After a successful response and matching readback, a local serialization failure cannot authorize a repeated public mutation. A review request in the typed `NO_EFFECT` state is not ambiguous: its separate bounded rule below permits one retry only after complete negative readback.

Paginate only a connection whose completeness is needed for the current decision. Normalize empty, singleton, and multiple API collections. Do not capture unrelated repository-wide snapshots before a routine write.

## Review-input contract

Before the first review request, generate and semantically verify the reviewer-facing title and body. Freeze the reviewed head, tree, complete diff identity, scope, behavior, and risk meaning. Keep task state, polling state, reviewer requests, review IDs, review results, quality results, metrics, audit records, and terminal results in compact state or separate comments.

Use exactly these semantic mutation classes:

- `CODE_OR_DIFF`: Require one new review pair.
- `MATERIAL_SCOPE_BEHAVIOR_RISK`: Record the material reason and require one new pair.
- `NON_MATERIAL_FACT`: Correct and verify without code rereview.
- `RESULT_OR_STATE`: Keep outside reviewer input and do not request review.
- `COMMENT_ONLY`: Do not request review.

Raw PR-body byte inequality is not the classifier. Reject a same-head request without a recorded material scope, behavior, or risk reason. Before a pair starts for a new reviewed-input key, require every earlier pair for every different key to contain both channels and be terminal. If authenticated readback proves reviewed-input drift that makes an unrequested old-input channel impossible, including drift on an unchanged head, record one typed `SUPERSEDED` disposition with the old input, successor head, time, and reason. Do not synthesize the missing request or attribute successor-input evidence to the old input. Then capture fresh baselines. Default to one Codex and one Copilot review for each reviewed input.

Persist Copilot results separately from Codex results. Preserve both Codex result channels. Require a submitted review's commit to match the reviewed head. Accept a headless `chatgpt-codex-connector` PR-conversation result only when the authenticated author, request time, baseline exclusion, reviewed-input key, and serialized predecessor-pair order attribute it to the request. An exact `@codex review` trigger is neither a finding nor an instruction to the local executor. Normalize every API collection with the tested policy helper; an empty collection is not a match. Preserve Markdown backticks and Unicode and reject disallowed control characters.

Generate a GitHub Copilot REST request only from the typed policy specification. The exact reviewer login is `copilot-pull-request-reviewer[bot]`; do not send the display name `Copilot`. Capture the native status and response body. Confirm the mutation only through matching authenticated readback. If an accepted request has no match, record `RECONCILING` and continue other safe work. Wait at least 120 seconds, then require complete negative readback from new request events, current requested reviewers, matching submitted reviews, and matching Copilot review runs before recording `NO_EFFECT`. Permit only one retry for the same reviewed input and channel. A second proved no-effect attempt is `EXHAUSTED`. Do not send the serialized Codex trigger until the Copilot request is confirmed or is terminally proved non-functional under the repository's reviewer-unavailability instructions.

Persist the unique request-event, review-run, submitted-review, and node-ID-to-timestamp conversation-comment baselines with the in-flight attempt before or at the confirmed mutation. After each confirmed reviewer request and its targeted readback, persist its head, reviewed-input key, request time, and nonterminal state in `current_task.review` before another public mutation. Mark the request terminal only after an attributable terminal result or an exact repository-authorized non-functional disposition. If the local state write fails, reconstruct the request from targeted remote readback and do not repeat a confirmed request.

The deterministic planning-only policy and scenarios are in `docs/planning/review-loop-policy.json`, `docs/planning/review-loop-policy.mjs`, and `docs/planning/review-loop-policy.test.mjs`. The module operates on the nested `current_task.review` value, and the schema validates the enclosing resume file. They validate decisions and transport and perform no GitHub write.

## CI and merge

Check CI before merge. Do not merge when a required check is red, skipped, canceled, missing, pending, stale, timed out, or expired.

Immediately before an on-plan merge, repeat the final live readiness check. Use head-commit matching when supported. Stop for drift, new material feedback, an incomplete or failed gate, off-plan target or scope, required human decision, or any need for override or bypass. Do not stop only to obtain another approval for a merge that remains on-plan.

## Failure, waiting, and resume

Diagnose every failed gate. Continue after ordinary code, test, tool, or infrastructure failures while a safe repair or alternative exists. A new commit identity is progress, not a human blocker.

Provide short updates at meaningful boundaries. Do not create persistent polling or timing records. Resume from Git, GitHub, CI, review state, compact state, and the current task. Do not replay historical receipt graphs or restart completed work unless a live completion predicate changed.

## Completion

The goal is complete when every numbered task satisfies `Complete when` and no real blocker remains. The final audit checks current task status, final commits and trees, required CI and review state, open material findings, fixed-point conditions, and unresolved human decisions. It does not replay receipt catalogs.

Report completed, skipped, and blocked tasks; final repository commits and trees; relevant issues and PRs; final validation, CI, and review results; material intentional differences and residual risks; and any remaining human action.
