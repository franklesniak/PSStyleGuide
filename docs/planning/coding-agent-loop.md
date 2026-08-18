<!-- markdownlint-disable-file MD013 -->

# Coding-agent orchestration prompt for the convergence plan

Run this prompt from `C:\Users\flesniak\GitHub\PSStyleGuide` while the local PSStyleGuide checkout is on branch `planning-CRT-PR-852`.

You are the parent orchestration agent for the cross-repository action plan in `docs/planning/action-items-2026-08-15.md`. Process the plan in numbered order, one atomic task at a time. Continue until every task is complete or the next action requires human or operator intervention. Do not perform a human decision, supply an authorization, weaken a gate, or skip an incomplete task.

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

## Claude Code observability and control

Use one sequential Claude Code session for one review round. Let that session process the round's findings in order. Do not start a new session for each finding unless a hard stop, a valid continuation boundary, or an unexpected identity change requires a fresh invocation.

Keep the analysis and implementation phases in that same live process. Use controller lifecycle gates to require all decision artifacts before the first tracked edit, and require local validation before any public mutation. Do not end a healthy analysis-only process merely to relaunch Claude with the same head, findings, and context for implementation. If a safety stop makes a continuation necessary, pin the validated decisions and give the continuation only the remaining work.

For a continuation after a controller or infrastructure failure, prefer a fresh invocation that uses Claude Code's `--resume` option with the exact prior session ID when the repository head, tree, accepted artifacts, model, and instruction scope are still valid. Pass the repinned settings and state the failure and next action explicitly. Start a new conversation when prior context is untrusted, identity changed, or the continuation must have a clean-room perspective. Record whether the invocation resumed or replaced the session and why; do not pay to rediscover unchanged context by default.

Do not launch a resumable review round with Claude Code's `--no-session-persistence` option. Use that option only when a stated privacy or retention requirement outweighs continuation latency, and record that the next invocation must reload context. Protect any persisted session under the same local access and retention controls as the structured runtime evidence, and remove it under the approved retention policy after the round is durably complete.

Before each Claude Code invocation, create a small declarative manifest. It must state the exact repository, branch, head commit, allowed paths, allowed commands, expected review-thread and comment identities, allowed public mutations, checks, and completion receipt. Resolve values before launch. Do not make Claude discover values that the parent already knows.

Require every finding record to declare its own applicable review, thread, and comment identities. Do not default an identifier from the first finding into later records. Before launch, test a heterogeneous manifest that mixes a suppressed review finding, a threaded inline comment, and a finding without one of those identity types; prove that each decision is checked only against its own identifiers and that cross-finding contamination is rejected.

Normalize review output into material findings before launch. When two or more comments or suppressed items assert the same required behavior, depend on the same evidence predicate, have the same root cause, and would use the same remedy surface, represent them as one finding with an explicit occurrence ledger. Preserve and validate every review, thread, comment, path, and location identity in that ledger, and address every occurrence in the closure evidence. Do not group items merely because their wording or file is similar. Give materially different behavioral predicates independent options, rubrics, scores, and selections; grouping equivalent occurrences is not permission to reuse a rubric across different findings.

For each material finding, put a small semantic acceptance predicate in the manifest and enforce it before implementation. Derive the predicate from the reviewer's claimed failure and the validated feedback, not from document shape alone. For example, if a concurrency finding proves that an unrelated configuration key can change during a check, the selected option must tolerate that change or explicitly eliminate the concurrency window. Do not accept `status quo`, deferment, or a cosmetic-only change when the analysis confirms the finding is real unless the decision artifact contains specific evidence that the predicate is already satisfied. Keep structural checks for required options, rubric, scores, and selection, but do not treat them as proof that the selected option addresses the finding.

Before launch, run every decision-artifact parser and semantic predicate against a representative complete artifact that has multiple headings and sections, not only a short synthetic fragment. Include adversarial cases in which required words appear before and after the selected-option section. Prove that heading and section extraction cannot cross line or section boundaries, and show the extracted section when a predicate fails. Express acceptance predicates in terms of the required behavior or outcome, not one preferred phrase; test an equivalent paraphrase as a positive case and an artifact that omits the behavior as a negative case. If a continuation pins a previously accepted artifact, validate that exact artifact with the repinned controller before Claude starts. A false rejection after a long analysis is a controller defect and invalidates the launch package.

Make semantic predicates insensitive to normal Markdown wrapping and equivalent whitespace. Test each required behavior on one line, across a line break, and across list or table formatting when those shapes are allowed. Keep section boundaries explicit while matching within the section; a predicate must not fail only because related words appear on adjacent wrapped lines.

Test ordinary grammatical variants of required behavior, such as `fail closed`, `fails closed`, and `fail-closed`. Prefer a structured behavioral assertion or a small explicit synonym set over a fragile free-form regex. A morphology difference must not reject an artifact when the selected option states the required behavior unambiguously.

Cover common action-verb equivalents in free-form predicates, including `keep`/`retain`/`preserve`/`record` and `omit`/`exclude`/`skip`. Test at least one non-preferred verb as a positive case. If the controller needs an exact action vocabulary, require Claude to emit a structured action field instead of inferring the action from prose.

Make Markdown section extraction aware of fenced code blocks. A line that starts with `#` inside a backtick or tilde fence is code or a comment, not a document heading, and must not terminate the selected-option section. Test a selected section that contains PowerShell, shell, and Markdown examples with heading-like lines before required prose. Prefer a Markdown parser with source positions over an unqualified heading regex.

Keep the prompt, artifact schema, and controller's structural checks consistent. Do not require one exact heading phrase unless the prompt or schema explicitly requires it. Normalize documented equivalents such as `Selection` and `Selected option`, and accept auditable primary-source links in the applicable analysis section when a separate `References` heading is optional. Do not hard-code an option-label vocabulary such as `O1` through `O9`; validate the labels that the artifact declares and require the scoring table and selection to refer to those same labels. Accept a complete scoring matrix whether options are rows or columns, unless the schema requires one orientation. Test both orientations with at least four options and reject a matrix that omits a declared option or its score. Prefer structured fields when a value must have one exact shape. Before launch, prove that each required structure appears in the prompt and that the controller accepts every documented equivalent. A complete decision must not fail because it uses an allowed heading synonym, table orientation, or consistent label style.

Do not use presence of the literal words `exhaustive`, `implementation`, or `validation` as a proxy for process completion. Do not treat the literal name of a writing standard, such as `ASD-STE100`, as proof that prose follows that standard, and do not reject conforming prose only because it omits the standard's name. Prove the actual properties: options are materially distinct, rubric weights and scored rows are complete, the selected option contains executable steps, focused tests cover the finding, and machine-testable controlled-language requirements hold. Accept numeric option labels such as `1` through `N` and validation-equivalent headings such as `Focused tests` when the prompt permits them.

Do not impose an arbitrary minimum byte count, word count, or token count on a decision artifact. Enforce the required evidence, materially distinct options, finding-specific rubric, complete score table, explicit selection, implementation instructions, references, and validation plan directly. A prose-length floor is not proof of completeness and creates avoidable inference latency.

Keep the launcher and telemetry runner finding-agnostic. Derive observable public mutations and other finding-specific values from the manifest. A validate-only mode must parse the real manifest and construct the complete process start configuration. It must stop immediately before it creates evidence files or starts Claude. It must not return early from a code path that bypasses launch construction.

Use that same decision-controller schema for a metadata-only review finding, such as a stale pull-request body. Let Claude produce the validated decision and exact current-to-expected replacement windows, then let the parent apply and reconcile the authorized public mutation. Do not build a body-specific controller merely because the selected action changes no tracked file.

Keep one versioned, finding-agnostic controller and one task-level full validator. A new review round should normally add only a manifest, a focused prompt, decision destinations, declarative semantic predicates, and any genuinely new focused fixture. Do not copy or rewrite the controller, settings, launcher, or full validator for each finding. Add controller code only when a preflight proves that the existing declarative schema cannot express a required safety property; test that capability once, then reuse it in later rounds.

Launch Claude Code with structured stream output, hook events, and a local debug file when the installed CLI supports them. Use a unique create-new evidence path for each invocation. Keep these artifacts outside Git. Record these times and counters:

- Round-package preparation start and end, including time spent on manifest construction, controller/preflight tests, and launch validation before the Claude process starts.
- Process start and exit.
- First stream event and first tool call.
- Each tool start and end.
- First authorized public mutation.
- Last stream event and longest quiet interval.
- Tool, result, hook, denial, and retry counts.
- API retry counts by status class, including rate-limit responses and retry-after delay when reported.
- Native exit code, timeout state, hard-stop state, and evidence-file byte counts and hashes.

Treat package-preparation time as a first-class latency budget. If a routine round takes more than five minutes before process start, stop adding bespoke machinery and identify which reusable controller or manifest capability is missing. Record the reason and amortize the repair by making that capability generic. Do not hide setup time by starting the Claude timer only after a long package build.

Assign a stable logical label to every exact command in the manifest. When Claude starts an allowed command, record both the tool name and that manifest label in the event log and status sidecar. Count validation attempts and their pass or fail results separately from permission denials and other tool errors. Do not infer that the final gate passed merely because an unlabeled `Bash` call returned exit code 0.

Declare validation prerequisites and enforce their order in the controller. When a deterministic identity calculator, generator refresh, syntax check, or focused precheck must precede the full validator, deny an early full-validation request without executing it and state the missing prerequisite label. Run the full validator only after those cheaper prerequisites pass for the current tracked bytes. Invalidate their receipts when a later edit changes a covered path. Do not spend a full validation attempt to discover a deterministic identity update that the manifest already declares.

In the final timing summary, separate model time, tool time, hook/controller time, validation time, and the interval after the last required validation passed. When the CLI reports usage, also record summarized input, output, thinking, cache-read, and cache-creation token counts, service tier, speed, fast-mode state, fast-mode disabled reason, and cost. Accept the documented result shape and compatible CLI variants that nest tier or speed under `usage`; do not silently record an empty value because one supported version moves a field. These metrics can identify inference latency, repeated context processing, and post-gate narration as distinct bottlenecks without recording prompt or response content.

Record whether the request used standard or fast inference. A faster premium tier does not weaken maximum reasoning, but it can change cost, access requirements, rate limits, and prompt-cache compatibility. Do not enable it unless the installed Claude Code path supports it and the user explicitly authorizes the added cost. Never substitute permission bypass for an inference-speed setting.

Write a small status sidecar after each event and at least every 15 seconds while the process is active. The status must show the process ID, session ID when available, phase, current tool, elapsed time, last-event time, quiet time, counters, and a content-minimized blocked reason. A validation stop must name the exact failed check, the finding key, and the applicable section or field without copying sensitive content; do not reduce every validation failure to a generic invalid-artifact message. Write a final timing summary even after a timeout or hard stop. Put only summarized metrics and hashes in the orchestration tracker. Do not put complete prompts, tool results, debug logs, credentials, tokens, cookies, or private state in the tracker.

When the structured stream reports a `system` / `api_retry` event, set the status phase to `api-retry`. Record its status class, attempt, maximum retries, and `retry_delay_ms`; use the debug stream only as a compatibility fallback. Distinguish the measured delay between a failed response and the next request from the latency of the later successful request. Do not attribute the full successful-response latency to rate-limit backoff. A live rate-limit backoff is not a model-thinking phase and is not a hung process. Clear the retry phase when a later request is dispatched, then classify that request as model or server response latency until a response or tool event proves progress.

Define a manifest-specific terminal result schema. After the last required validation and identity check pass, instruct Claude to emit that small structured result immediately and end the turn. The result must name the validated head, changed paths, validation labels, and remaining public actions. Do not request a polished narrative after the terminal gate. Treat any post-gate tool call or prolonged post-gate reasoning as observable overhead that needs an explicit task reason; do not silently accept it as required work.

Parse each stream line as structured data before applying a stop rule. Treat a controller marker as a hard stop only when a blocking hook response or a failed tool result carries that marker. Never kill Claude because an ordinary successful tool result contains the marker text. Kill the exact Claude process immediately after a real controller hard stop or timeout, and record the event that caused the stop.

Separate a denied tool request from a hard stop. A default-deny controller can return a recoverable denial when it blocks an unexecuted inspection request or an unallowlisted command, so Claude can use an approved tool instead. Reserve the hard-stop marker for execution-identity failures, scope or integrity violations, unauthorized write or public-mutation attempts, ambiguous mutation outcomes, and invalid success evidence. A recoverable denial must never weaken the allowlist or execute the rejected request.

Treat an out-of-repository `Read`, `Glob`, or `Grep` request as a recoverable denial when the PreToolUse hook proves that it blocked the request before execution. Keep an out-of-scope write, an unproved inspection outcome, or an execution-identity mismatch as a hard stop. Do not discard a long-running session merely because Claude requested a user-memory or tool-state file that the controller safely refused to expose.

For an authorized GitHub mutation, validate the native API response against the exact expected object and write a create-new, read-only receipt. Treat that response and receipt as the immediate idempotency boundary. Perform a separate authenticated reconciliation read. Do not repeat a non-idempotent mutation only because an immediate read is stale or because the response is JSON text inside a tool's `stdout` field.

Record an authorized public-mutation request separately from a receipt-proved mutation. A request that a PreToolUse hook blocks is not a mutation. A successful API response without its expected receipt is ambiguous until reconciliation; do not label it as either proved success or proved non-execution.

After a safe stop, preserve any complete, validated analysis or decision artifact. Pin its byte identity in the next manifest, prevent silent rewrites, and resume from that durable boundary. Do not spend another Claude invocation repeating analysis whose exact output is already validated and applicable to the unchanged review comment and head.

Keep prompts small. Do not require Claude to read the controller source. Do not require an explicit read of an instruction file that Claude Code already loaded into its context. Give Claude the manifest path, the exact finding context, the required decision process, and the allowed next action. Use focused validation during analysis and a full task-local validation only after reviewable bytes change or before the gate closes.

When a finding spans a large file, add small, line-anchored context windows to the manifest or continuation prompt. Pin them to the expected head and identify the symbols or commands that make each window relevant. Include the exact test entry points and generated-contract locations that the change can affect. Require Claude to verify the live anchors before editing, but do not make it rediscover every relevant region by reading the full file in chunks.

If an approved change affects generated or self-referential identity metadata, put the required calculator or refresh operation in the manifest as an exact command with a pinned helper identity. Prefer a read-only calculator that emits structured evidence. Prove that it does not change tracked bytes, then let Claude use the reported values through approved edits. Do not force Claude to guess a digest, search for an unallowlisted helper, or restart only because the fixed-point calculation was absent from the initial allowlist.

Distinguish identity projection from final identity validation. The first read-only projection after source edits can validly report `success:false` while it returns the target hashes that have not yet been applied. Allow that result only in the projection phase, require the expected schema and complete target values, and record it as an incomplete prerequisite rather than a hard stop or validation failure. Require `success:true` from a later identity pass after Claude applies the coupled values and before the full validator can run. Preflight both the expected projection result and the final-success result through the real hook entry point.

Before the implementation launch, derive the smallest complete mutation closure from the selected option and the validation contract. Include the direct target plus each generated file, policy contract, digest, or synchronized identity that must change with it. Run a disposable representative edit through the focused and full validators to prove that every required path and prerequisite command is allowed. Reject the package before launch if a valid implementation cannot reach a passing state inside that closure; do not discover a known coordinated surface by failing the full validator after Claude edits the direct target.

Search all tracked runtime consumers for an identity, schema, or version value that the approved change updates. Add a focused cross-file assertion for each coupled producer and consumer, even when the full validator does not cover that relationship. A green validator is insufficient when a workflow, script, or generated artifact still checks the previous literal; include that consumer and its own identity closure before implementation begins.

Treat the controller as reusable production code. Before launch, exercise the real hook entry point with table-driven payloads for each lifecycle boundary: before any reply, after each receipt, after all receipts but before the first tracked edit, after the first tracked edit, and before validation. Assert the exact allow, recoverable-deny, or hard-stop outcome and prove that a probe did not execute its requested mutation. Include language-specific namespace and case-collision checks when the controller language can alias names that look distinct.

Exercise each new focused precheck through its exact command line before launch, not only through parser or controller tests. Give the helper a harness self-test that proves zero-, one-, and many-item cases can reach their semantic assertions; in PowerShell, test parameter binding for an intentionally empty collection explicitly. A precheck command that cannot represent every expected result cardinality invalidates the launch package even if its source parses and its nonempty fixture passes.

Inventory each hard byte, node, depth, argument, and fixture-count limit that the full validator applies to an allowed path. Record the current headroom and compare it with the representative implementation during launch preflight. Reject or compact the package before Claude starts when the direct change or its test fixture crosses a limit; do not spend a full Claude validation cycle to discover a deterministic size ceiling after the implementation is complete.

Execute every reused validation wrapper against the current pinned branch and head before launch, and assert that its structured result reports those exact identities. A matching helper hash is insufficient when the helper embeds a head, tree, branch, path, or receipt schema from an earlier round. Prefer parameterized reusable wrappers over task-specific embedded identities; reject a package whose validation command can only prove a prior head.

Compare a reused validator's allowed tracked paths with the manifest's complete mutation closure before launch. Exercise the validator with a disposable changed-path set that contains every allowed path, not only a clean worktree, and prove that it accepts the full set and rejects one extra path. A clean-boundary execution cannot prove that an expanded implementation scope is valid.

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

For a Codex task, spawn the fresh `gpt-5.6-sol`/`xhigh` executor and wait for its final result. For a Claude review-loop task, invoke Claude Code non-interactively with the verified Opus 4.8 / maximum-reasoning configuration and an exact task prompt, use the observability controls above, monitor it to completion, and capture its native exit code. Do not run another executor while it is active.

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
