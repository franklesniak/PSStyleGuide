<!-- markdownlint-disable-file MD013 -->

# Coding-agent orchestration prompt for the convergence plan

Run this prompt from `C:\Users\flesniak\GitHub\PSStyleGuide` while the local PSStyleGuide checkout is on branch `planning-CRT-PR-852`.

When the workflow will reach an initial coding-task dispatch or a permitted reroute, start or resume it from a user message that explicitly selects the private `model-routing-advisor` skill through the current host. In Codex CLI or the IDE extension, select `$model-routing-advisor` from the `$` picker or `/skills`; in the ChatGPT desktop app, select it with `@`. Put the structured skill selection in the same user message that starts or resumes `/goal`, and retain the skill mention in the durable goal objective when the host supports that shape. For example: `/goal Use $model-routing-advisor and work on the prompt in docs/planning/coding-agent-loop.md`. A literal skill name copied into prose, this file, a tracker, or an executor prompt is not proof of host-level selection.

You are the parent orchestration agent for the cross-repository action plan in `docs/planning/action-items-2026-08-21.md`. Process the plan in numbered order, one atomic task at a time. Continue until every task is complete or the next action requires human or operator intervention. Do not perform a human decision, supply an authorization, weaken a gate, or skip an incomplete task.

The plan file exists only on PSStyleGuide branch `planning-CRT-PR-852`. It is a control input and is not intended to merge to `main`. Never add the plan, this orchestration prompt, or orchestration-state files to an implementation PR. Do not copy them to `main`, cherry-pick them into an implementation branch, or treat their absence from `main` as a defect. When work occurs in TerraformStyleGuide, pass the exact task text to the executor from the PSStyleGuide planning checkout.

The local repositories are:

- PSStyleGuide: `C:\Users\flesniak\GitHub\PSStyleGuide`
- TerraformStyleGuide: `C:\Users\flesniak\GitHub\TerraformStyleGuide`

Preserve unrelated user changes in both repositories. Before acting in either repository, read its `AGENTS.md`, `CLAUDE.md`, `.github/copilot-instructions.md`, and applicable `.github/instructions/**` files when they exist. Obey the most specific repository instruction. Do not use destructive Git recovery commands. Do not expose credentials, tokens, cookies, or private state.

## Required advisor activation

Treat skill discovery, initial-list inclusion, explicit selection, instruction loading, and successful advisor invocation as distinct facts.

- A skill selector or autocomplete result proves discovery only. A local directory or `SKILL.md` file proves neither discovery by the current host nor activation in the current turn.
- The initial skill list is context-budgeted and may omit a discovered skill. Absence from that initial list is not proof that the skill is unavailable and must not by itself block the workflow.
- A fixed local directory is not an availability gate. Codex surfaces and versions may resolve user skills from different compatible or legacy roots. Use the current host's selector and resolved skill identity; do not require, copy, move, or modify a private skill merely to satisfy a hard-coded path.
- Explicit activation is verified only when the current host accepts the structured skill selection and the parent loads the selected skill's complete instructions through the host-provided resource or filesystem path. For a filesystem-backed skill, record its resolved `SKILL.md` path, byte count, and SHA-256. For an opaque host resource, record its stable host identifier and the strongest content identity the host exposes.
- `policy.allow_implicit_invocation: false` does not make a skill unavailable; it requires explicit selection. Do not change that policy as part of this workflow.
- If the advisor is needed and is not activated in the current turn, inspect the skill metadata exposed to the parent by the current host. If the parent cannot inspect the interactive selector, do not infer its contents; ask the operator to open `$` or `/skills` in Codex, or `@` in ChatGPT, and select the advisor in one resumption message. Do not classify a discovered-but-unselected skill as unavailable, invoke a substitute, create a test executor, or consume repeated no-progress retries. Only after a direct host or operator read shows that the selector does not expose it following one host restart may the parent record a discovery failure and the minimum operator action.

Record one current-turn `advisor_activation` receipt before every initial advisor invocation or permitted reroute. It must distinguish `discovered`, `explicit_selection_accepted`, `full_instructions_loaded`, and `activation_verified`; name the host surface and resolved skill identity; include the resource path or identifier and content hash when available; and state any limitation. Selector presence alone cannot set `activation_verified: true`.

## Required executor routing

Run at most one task executor at a time. Never parallelize plan tasks, implementation work, review gates, or reciprocal comparisons.

`/goal` is the sole durable parent orchestrator for the complete plan. A task router or task executor is never a second parent, may not assume durable workflow control, and may not create descendants. Use a fresh executor for each numbered coding task and each replacement after an invalid or no-progress invocation. A validated continuation can reuse the same Codex thread only under the continuation rules below.

- A review-loop executor is the local implementation and task-level orchestration executor. The GitHub account `chatgpt-codex-connector` is a separate remote reviewer. An exact `@codex review` PR comment triggers that remote reviewer; it is not a finding and does not instruct the local executor.
- Launch an executor from the target worktree so Codex loads the applicable `AGENTS.md` chain. If the target repository has no `AGENTS.md`, explicitly tell the executor to read the repository's root `CLAUDE.md` as compatibility workflow instructions. A compatibility filename does not change the executor: Codex still performs the task.
- For `Human execution required`, do not invoke the routing advisor or a coding agent to make the decision or perform the restricted action. First re-query the required state. If the human action is already complete and independently verifiable, record that evidence and continue. Otherwise stop at that task and report the exact decision, authorization, credential, setting change, or operator action required.
- For `Not executable; tracking/control only`, validate the specified state and record it. Do not invoke the routing advisor or treat the task as authority for an implementation action.

At startup, perform one workflow-level capability preflight for skill selection and loading and for per-subagent exact model and reasoning-effort requests. Inspect the actual runtime interfaces and record whether the advisor is discovered, whether explicit selection was accepted for the current turn, whether its full instructions were loaded, whether native delegation and exact overrides are supported, whether post-spawn effective-setting inspection is available, and whether an allowed headless fallback exists. Documentation, a static model list, an initial skill list, autocomplete, or a local skill file is not proof that a particular route is available or that the advisor is activated. Do not create a test executor merely to perform this preflight. Refresh the preflight if the runtime, host turn, or interface changes.

### Model-routing boundary

For each numbered task, enforce this lifecycle:

`classify task → finalize and hash manifest → select and freeze route → create one executor → validate → complete, retry, reroute, or block`

The `/goal` parent retains responsibility for task sequencing; tracker and state management; task classification; manifest creation, approval, and hashing; repository, branch, worktree, and baseline checks; authorization and policy gates; inspection of artifacts and diffs; independent validation; continuation, retry, reroute, blocking, and completion decisions; and final reporting. The parent does not delegate those responsibilities to the routing advisor or task executor.

The parent must not invoke `model-routing-advisor` for the overall `/goal`; tracker or state-control work; parent-reserved validation; `Human execution required` tasks; `Not executable; tracking/control only` tasks; GitHub reconciliation or authorization decisions; or any work this policy prohibits delegating. Record an explicit routing bypass for every numbered task in those classes.

For every numbered task classified as `Coding agent executable`:

1. Complete all existing pre-dispatch repository, worktree, identity, authorization, policy, and implementation-slot checks.
2. Finalize the exact task text and approved manifest, compute their SHA-256 hashes, and record both hashes. Do not route a draft or placeholder-bearing manifest.
3. Verify the current-turn `advisor_activation` receipt, then invoke the explicitly selected private, user-scoped `model-routing-advisor` for that task only. Supply the exact numbered task text; task-text hash; repository, worktree, branch, and baseline commit; allowed and forbidden paths; required commands and validation; risk and uncertainty signals; retry history, if any; any exact model or reasoning requirement from the task or approved plan; and the requirement for one executor with no descendants. Do not copy the advisor or its private instructions into either repository or tracker. Do not infer activation from the skill name appearing in these instructions.
4. Apply the selection precedence below and freeze the selected route before dispatch.
5. Check the selected route's actual availability through the dispatching runtime. A documented or statically listed route is not sufficient proof of runtime availability.
6. When automatic delegation is supported, let the advisor create exactly one fresh subagent with no inherited conversational turns when the runtime supports `fork_turns="none"`. The advisor-created subagent is that dispatch's only executor.
7. Record the executor identifier and routing evidence in the tracker. Do not have the parent create a second executor for the same dispatch.
8. Do not permit the executor to create descendants. Preserve the one-executor-at-a-time rule.

The task executor must receive all existing task-package instructions, target-worktree restrictions, manifest restrictions, validation requirements, retry context, terminal-result schema, and final-response requirements.

Apply route selection precedence in this order:

1. An exact model or reasoning-effort requirement in the numbered task, or a higher-priority exact requirement in the approved plan, wins.
2. The manifest records that exact requirement but must not invent, weaken, or conflict with it.
3. When no exact requirement exists, use the advisor's recommendation.
4. Never silently substitute, downgrade, upgrade, or reduce the selected route.

If a higher-priority requirement overrides the advisor recommendation, record both the recommendation and the source of the selected requirement.

Freeze the selected route for the numbered task. A continuation reuses the same executor and frozen route. A normal replacement retry uses a fresh sequential executor with the same frozen route. Do not invoke the advisor again merely because a continuation or ordinary retry occurs, and never run the old and replacement executors concurrently.

Rerouting is permitted only when the exact task or approved manifest changes materially and produces a new hash, or independent validation records concrete evidence that the selected capability is insufficient. Invoke the advisor once for that reroute. A reroute must retain the previous routing record; append the trigger and supporting evidence; create a new routing-decision identifier; record the prior and new task and manifest hashes; freeze the new route; use a fresh sequential executor; and preserve the one-executor-at-a-time rule. A model or reasoning change without that explicit reroute record is invalid.

Handle exact-override support and verification as follows:

1. **Exact override unsupported:** If the native runtime cannot request the selected exact model or reasoning effort, do not claim routed delegation succeeded. Use the existing headless `codex exec` fallback only when the numbered task explicitly permits that interface and it can request the identical route under all controls below. Otherwise block.
2. **Override request rejected:** If the runtime exposes the override but rejects the selected value, record the rejection and block unless an already-authorized interface can request the identical route.
3. **Override accepted, effective setting visible:** Record the requested and effective model and reasoning settings, the verification source, and `effective_override_verified: true`.
4. **Override accepted, effective setting not visible:** Continue when otherwise permitted, but record the requested settings, that the request was accepted, `effective_override_verified: false`, and the runtime limitation preventing verification.

Requested, accepted, resolved, and effectively verified settings are distinct concepts. Never infer the effective model or reasoning effort from the request, prompt text, agent name, advisor recommendation, or an executor assertion. Lack of post-spawn inspection alone is not a blocker when the exact override request was accepted; inability to request the exact frozen route is a blocker.

## Codex review-loop execution controls

Use one sequential advisor-created Codex subagent for one numbered review-loop task. Let that executor process the task's rounds and findings in order under the task's frozen route. Do not start a new subagent for each finding unless a hard stop or invalid continuation requires a fresh sequential replacement or an explicit reroute.

Keep the analysis and implementation phases in that same live subagent. Use lifecycle gates to require all decision artifacts before the first tracked edit, and require local validation before any public mutation. Do not end a healthy analysis-only subagent merely to relaunch Codex with the same head, findings, and context for implementation. If a safety stop makes a continuation necessary, pin the validated decisions and give the continuation only the remaining work.

For a continuation after a controller or infrastructure failure, send a follow-up task to the same Codex subagent only when its thread remains available and the repository head, tree, accepted artifacts, executor identity, exact task-text hash, approved manifest hash, frozen route, and instruction scope still match. Pass the repinned settings and state the failure and next action explicitly. Use a fresh sequential replacement when prior context is untrusted, an identity or hash changed incompatibly, the previous thread is unavailable, or the continuation must have a clean-room perspective. A normal replacement retains the frozen route and does not invoke the advisor again. Record whether the invocation continued or replaced the executor and why; do not pay to rediscover unchanged context by default.

Do not close a healthy Codex subagent thread before the review-loop task is durably complete. Protect any persisted thread and local evidence under the approved access and retention controls. Close completed agents and remove retained runtime evidence under the approved retention policy after the task is durably complete.

Before initial routing, create and approve a small declarative manifest. It must state the exact repository, branch, head commit, allowed and forbidden paths, allowed commands, expected review-thread and comment identities, allowed public mutations, checks, completion receipt, and any exact route requirement from the task or approved plan. Resolve values, finalize the manifest, and record its SHA-256 before invoking the advisor. Before every continuation or replacement, prove that the pinned manifest hash still identifies the applicable approved manifest. A material manifest change requires a new hash and explicit reroute. Do not make the executor discover values that the parent already knows.

Require every finding record to declare its own applicable review, thread, and comment identities. Do not default an identifier from the first finding into later records. Before launch, test a heterogeneous manifest that mixes a suppressed review finding, a threaded inline comment, and a finding without one of those identity types; prove that each decision is checked only against its own identifiers and that cross-finding contamination is rejected.

Normalize review output into material findings before launch. When two or more comments or suppressed items assert the same required behavior, depend on the same evidence predicate, have the same root cause, and would use the same remedy surface, represent them as one finding with an explicit occurrence ledger. Preserve and validate every review, thread, comment, path, and location identity in that ledger, and address every occurrence in the closure evidence. Do not group items merely because their wording or file is similar. Give materially different behavioral predicates independent options, rubrics, scores, and selections; grouping equivalent occurrences is not permission to reuse a rubric across different findings.

For each material finding, put a small semantic acceptance predicate in the manifest and enforce it before implementation. Derive the predicate from the reviewer's claimed failure and the validated feedback, not from document shape alone. For example, if a concurrency finding proves that an unrelated configuration key can change during a check, the selected option must tolerate that change or explicitly eliminate the concurrency window. Do not accept `status quo`, deferment, or a cosmetic-only change when the analysis confirms the finding is real unless the decision artifact contains specific evidence that the predicate is already satisfied. Keep structural checks for required options, rubric, scores, and selection, but do not treat them as proof that the selected option addresses the finding.

Before launch, run every decision-artifact parser and semantic predicate against a representative complete artifact that has multiple headings and sections, not only a short synthetic fragment. Include adversarial cases in which required words appear before and after the selected-option section. Prove that heading and section extraction cannot cross line or section boundaries, and show the extracted section when a predicate fails. Express acceptance predicates in terms of the required behavior or outcome, not one preferred phrase; test an equivalent paraphrase as a positive case and an artifact that omits the behavior as a negative case. If a continuation pins a previously accepted artifact, validate that exact artifact with the repinned controller before the Codex subagent starts. A false rejection after a long analysis is a controller defect and invalidates the launch package.

Make semantic predicates insensitive to normal Markdown wrapping and equivalent whitespace. Test each required behavior on one line, across a line break, and across list or table formatting when those shapes are allowed. Keep section boundaries explicit while matching within the section; a predicate must not fail only because related words appear on adjacent wrapped lines.

Test ordinary grammatical variants of required behavior, such as `fail closed`, `fails closed`, and `fail-closed`. Prefer a structured behavioral assertion or a small explicit synonym set over a fragile free-form regex. A morphology difference must not reject an artifact when the selected option states the required behavior unambiguously.

Cover common action-verb equivalents in free-form predicates, including `keep`/`retain`/`preserve`/`record` and `omit`/`exclude`/`skip`. Test at least one non-preferred verb as a positive case. If the controller needs an exact action vocabulary, require the Codex subagent to emit a structured action field instead of inferring the action from prose.

Make Markdown section extraction aware of fenced code blocks. A line that starts with `#` inside a backtick or tilde fence is code or a comment, not a document heading, and must not terminate the selected-option section. Test a selected section that contains PowerShell, shell, and Markdown examples with heading-like lines before required prose. Prefer a Markdown parser with source positions over an unqualified heading regex.

Keep the prompt, artifact schema, and controller's structural checks consistent. Do not require one exact heading phrase unless the prompt or schema explicitly requires it. Normalize documented equivalents such as `Selection` and `Selected option`, and accept auditable primary-source links in the applicable analysis section when a separate `References` heading is optional. Do not hard-code an option-label vocabulary such as `O1` through `O9`; validate the labels that the artifact declares and require the scoring table and selection to refer to those same labels. Accept a complete scoring matrix whether options are rows or columns, unless the schema requires one orientation. Test both orientations with at least four options and reject a matrix that omits a declared option or its score. Prefer structured fields when a value must have one exact shape. Before launch, prove that each required structure appears in the prompt and that the controller accepts every documented equivalent. A complete decision must not fail because it uses an allowed heading synonym, table orientation, or consistent label style.

Do not use presence of the literal words `exhaustive`, `implementation`, or `validation` as a proxy for process completion. Do not treat the literal name of a writing standard, such as `ASD-STE100`, as proof that prose follows that standard, and do not reject conforming prose only because it omits the standard's name. Prove the actual properties: options are materially distinct, rubric weights and scored rows are complete, the selected option contains executable steps, focused tests cover the finding, and machine-testable controlled-language requirements hold. Accept numeric option labels such as `1` through `N` and validation-equivalent headings such as `Focused tests` when the prompt permits them.

Do not impose an arbitrary minimum byte count, word count, or token count on a decision artifact. Enforce the required evidence, materially distinct options, finding-specific rubric, complete score table, explicit selection, implementation instructions, references, and validation plan directly. A prose-length floor is not proof of completeness and creates avoidable inference latency.

Keep any headless launcher and telemetry runner finding-agnostic. Derive observable public mutations and other finding-specific values from the manifest. A validate-only mode must parse the real manifest and construct the complete process start configuration. It must stop immediately before it creates evidence files or starts Codex. It must not return early from a code path that bypasses launch construction.

Use that same decision-controller schema for a metadata-only review finding, such as a stale pull-request body. Let the Codex subagent produce the validated decision and exact current-to-expected replacement windows, then let the authorized writer apply and reconcile the public mutation. Do not build a body-specific controller merely because the selected action changes no tracked file.

Keep one versioned, finding-agnostic controller and one task-level full validator. A new review round should normally add only a manifest, a focused prompt, decision destinations, declarative semantic predicates, and any genuinely new focused fixture. Do not copy or rewrite the controller, settings, launcher, or full validator for each finding. Add controller code only when a preflight proves that the existing declarative schema cannot express a required safety property; test that capability once, then reuse it in later rounds.

When a task explicitly permits the headless fallback, launch `codex exec` with JSON Lines output and a separate standard-error log when the installed CLI supports them. Use a unique create-new evidence path for each invocation. Keep these artifacts outside Git. Record these times and counters:

- Round-package preparation start and end, including time spent on manifest construction, controller/preflight tests, and launch validation before the Codex process starts.
- Process start and exit.
- First stream event and first tool call.
- Each tool start and end.
- First authorized public mutation.
- Last stream event and longest quiet interval.
- Tool, result, controller-denial, and retry counts.
- API retry counts by status class, including rate-limit responses and retry-after delay when reported.
- Native exit code, timeout state, hard-stop state, and evidence-file byte counts and hashes.

Treat package-preparation time as a first-class latency budget. If a routine round takes more than five minutes before executor start, stop adding bespoke machinery and identify which reusable controller or manifest capability is missing. Record the reason and amortize the repair by making that capability generic. Do not hide setup time by starting the Codex timer only after a long package build.

Assign a stable logical label to every exact command in the manifest. When the Codex subagent starts an allowed command, record both the tool name and that manifest label in the event log or checkpoint. Count validation attempts and their pass or fail results separately from permission denials and other tool errors. Do not infer that the final gate passed merely because an unlabeled shell call returned exit code 0.

Declare validation prerequisites and enforce their order in the controller. When a deterministic identity calculator, generator refresh, syntax check, or focused precheck must precede the full validator, deny an early full-validation request without executing it and state the missing prerequisite label. Run the full validator only after those cheaper prerequisites pass for the current tracked bytes. Invalidate their receipts when a later edit changes a covered path. Do not spend a full validation attempt to discover a deterministic identity update that the manifest already declares.

Make every validation wrapper preserve the native exit code and bounded, separate standard output and standard error for each child command. On failure, return the validator's structured category and the applicable output before throwing or stopping the session. Redact secrets and cap verbose output, but do not replace a machine-readable failure with only `command failed`; the Codex subagent must be able to act on the first result without re-reading validator source to recover the hidden reason.

In the final timing summary, separate model time, tool time, controller time, validation time, and the interval after the last required validation passed. When the Codex interface reports usage, record the documented input, cached-input, output, and reasoning-output token counts. Record service tier or cost only when the interface reports it; do not infer unavailable fields. These metrics can identify inference latency, repeated context processing, and post-gate narration as distinct bottlenecks without recording prompt or response content.

Record the advisor recommendation; selected and frozen route; requested overrides; request acceptance or rejection; resolved settings when the interface reports them; effective settings only when independently visible; verification source and limitation; and service tier when reported. Do not conflate these fields or mark `effective_override_verified` true merely because the request was accepted. Never change the selected model or reasoning effort to improve latency without an authorized, recorded reroute, and never substitute permission bypass or broader sandbox access for an inference-speed setting.

For a headless fallback, write a small status sidecar after each event and at least every 15 seconds while the process is active. The status must show the process ID, thread ID when available, phase, current tool, elapsed time, last-event time, quiet time, counters, and a content-minimized blocked reason. A validation stop must name the exact failed check, the finding key, and the applicable section or field without copying sensitive content; do not reduce every validation failure to a generic invalid-artifact message. Write a final timing summary even after a timeout or hard stop. Put only summarized metrics and hashes in the orchestration tracker. Do not put complete prompts, tool results, debug logs, credentials, tokens, cookies, or private state in the tracker.

When a headless structured stream reports a retry event, set the status phase to `api-retry`. Record the event's documented status class, attempt, maximum retries, and retry delay when present; use standard error only as a compatibility fallback. Distinguish the measured delay between a failed response and the next request from the latency of the later successful request. Do not attribute the full successful-response latency to rate-limit backoff. A live rate-limit backoff is not a model-thinking phase and is not a hung process. Clear the retry phase when a later request is dispatched, then classify that request as model or server response latency until a response or tool event proves progress.

Define a manifest-specific terminal result schema. After the last required validation and identity check pass, instruct the Codex subagent to emit that small structured result immediately and end the turn. The result must name the validated head, changed paths, validation labels, and remaining public actions. Do not request a polished narrative after the terminal gate. Treat any post-gate tool call or prolonged post-gate reasoning as observable overhead that needs an explicit task reason; do not silently accept it as required work.

For a headless fallback, parse each stream line as structured data before applying a stop rule. Treat a controller marker as a hard stop only when a failed tool result or controller response carries that marker. Never terminate Codex because an ordinary successful tool result contains the marker text. Terminate the exact fallback process immediately after a real controller hard stop or timeout, and record the event that caused the stop. For a native subagent, interrupt only that canonical agent after the same condition is proved.

Separate a denied tool request from a hard stop. A default-deny controller can return a recoverable denial when it blocks an unexecuted inspection request or an unallowlisted command, so the Codex subagent can use an approved tool instead. Reserve the hard-stop marker for execution-identity failures, scope or integrity violations, unauthorized write or public-mutation attempts, ambiguous mutation outcomes, and invalid success evidence. A recoverable denial must never weaken the allowlist or execute the rejected request.

When a headless fallback has an enforcing controller, treat an out-of-repository read request as a recoverable denial when the controller proves that it blocked the request before execution. Keep an out-of-scope write, an unproved inspection outcome, or an execution-identity mismatch as a hard stop. Do not discard a long-running subagent merely because an enforcing boundary safely refused to expose a user-memory or tool-state file.

For an authorized GitHub mutation, validate the native API response against the exact expected object and write a create-new, read-only receipt. Treat that response and receipt as the immediate idempotency boundary. Perform a separate authenticated reconciliation read. Do not repeat a non-idempotent mutation only because an immediate read is stale or because the response is JSON text inside a tool's `stdout` field.

Record an authorized public-mutation request separately from a receipt-proved mutation. A request that an enforcing controller blocks before execution is not a mutation. A successful API response without its expected receipt is ambiguous until reconciliation; do not label it as either proved success or proved non-execution.

After a safe stop, preserve any complete, validated analysis or decision artifact. Pin its byte identity in the next manifest, prevent silent rewrites, and resume from that durable boundary. Do not spend another Codex invocation repeating analysis whose exact output is already validated and applicable to the unchanged review comment and head.

Keep prompts small. Put the complete applicable execution rules in the manifest, tell the Codex subagent explicitly not to read controller or runner source unless controller debugging is the assigned task, and enforce that boundary when the interface permits it. Do not require an explicit read of an instruction file that the Codex runtime already supplied. Give the subagent the manifest path, the exact finding context, the required decision process, and the allowed next action. Use focused validation during analysis and a full task-local validation only after reviewable bytes change or before the gate closes.

Keep controller, telemetry, review-export, and decision evidence outside the implementation worktree when possible. Before launch, count and measure any inherited untracked files without sending their complete inventory to the Codex subagent. Give the subagent exact evidence paths or a bounded summary, and use a tracked-only or path-scoped status for routine checks. If an untracked-file invariant is material to the finding, let a focused helper evaluate the full set and return only its structured result; do not repeatedly inject thousands of unrelated paths into the model context.

When a finding spans a large file, add small, line-anchored context windows to the manifest or continuation prompt. Pin them to the expected head and identify the symbols or commands that make each window relevant. Include the exact test entry points and generated-contract locations that the change can affect. Require the Codex subagent to verify the live anchors before editing, but do not make it rediscover every relevant region by reading the full file in chunks.

If an approved change affects generated or self-referential identity metadata, put the required calculator or refresh operation in the manifest as an exact command with a pinned helper identity. Prefer a read-only calculator that emits structured evidence. Prove that it does not change tracked bytes, then let the Codex subagent use the reported values through approved edits. Do not force the subagent to guess a digest, search for an unallowlisted helper, or restart only because the fixed-point calculation was absent from the initial allowlist.

Distinguish identity projection from final identity validation. The first read-only projection after source edits can validly report `success:false` while it returns the target hashes that have not yet been applied. Allow that result only in the projection phase, require the expected schema and complete target values, and record it as an incomplete prerequisite rather than a hard stop or validation failure. Require `success:true` from a later identity pass after the Codex subagent applies the coupled values and before the full validator can run. Preflight both the expected projection result and the final-success result through the real controller entry point when one is present.

Before the implementation launch, derive the smallest complete mutation closure from the selected option and the validation contract. Include the direct target plus each generated file, policy contract, digest, or synchronized identity that must change with it. Run a disposable representative edit through the focused and full validators to prove that every required path and prerequisite command is allowed. Reject the package before launch if a valid implementation cannot reach a passing state inside that closure; do not discover a known coordinated surface by failing the full validator after the Codex subagent edits the direct target.

Search all tracked runtime consumers for an identity, schema, or version value that the approved change updates. Add a focused cross-file assertion for each coupled producer and consumer, even when the full validator does not cover that relationship. A green validator is insufficient when a workflow, script, or generated artifact still checks the previous literal; include that consumer and its own identity closure before implementation begins.

Treat any enforcing controller as reusable production code. Before launch, exercise its real decision entry point with table-driven payloads for each lifecycle boundary: before any reply, after each receipt, after all receipts but before the first tracked edit, after the first tracked edit, and before validation. Assert the exact allow, recoverable-deny, or hard-stop outcome and prove that a probe did not execute its requested mutation. Include language-specific namespace and case-collision checks when the controller language can alias names that look distinct.

Exercise each new focused precheck through its exact command line before launch, not only through parser or controller tests. Give the helper a harness self-test that proves zero-, one-, and many-item cases can reach their semantic assertions; in PowerShell, test parameter binding for an intentionally empty collection explicitly. A precheck command that cannot represent every expected result cardinality invalidates the launch package even if its source parses and its nonempty fixture passes.

Inventory each hard byte, node, depth, argument, and fixture-count limit that the full validator applies to an allowed path. Record the current headroom and compare it with the representative implementation during launch preflight. Reject or compact the package before the Codex subagent starts when the direct change or its test fixture crosses a limit. Recheck each cheap hard limit after a covered edit and before an identity refresh or full validation; block the expensive command and report the exact current value, maximum, and remaining headroom when the check fails. Do not spend a full Codex validation cycle to discover a deterministic size ceiling after the implementation is complete.

Execute every reused validation wrapper against the current pinned branch and head before launch, and assert that its structured result reports those exact identities. A matching helper hash is insufficient when the helper embeds a head, tree, branch, path, or receipt schema from an earlier round. Prefer parameterized reusable wrappers over task-specific embedded identities; reject a package whose validation command can only prove a prior head.

Compare a reused validator's allowed tracked paths with the manifest's complete mutation closure before launch. Exercise the validator with a disposable changed-path set that contains every allowed path, not only a clean worktree, and prove that it accepts the full set and rejects one extra path. A clean-boundary execution cannot prove that an expanded implementation scope is valid.

If the runtime supports a persistent goal primitive, create or resume exactly one `/goal` for the entire plan. That `/goal` remains the sole durable parent; never create a per-task goal or route the overall goal through the advisor. The filesystem tracker and verified repository/GitHub state remain authoritative after compaction; conversational memory, routing recommendations, and executor reports do not.

## Codex observability and control

Use the native Codex subagent interface when the task dispatch rule requires a Codex executor. Record the routing-decision identifier, canonical agent ID or task name, frozen selected route, requested overrides, request-acceptance status, resolved and effective settings only when the interface reports them, effective-verification status and source or limitation, start time, completion time, and terminal status. Require checkpoints after analysis, the first tracked edit, validation, and any public mutation. Inspect the available agent-status or thread interface at least every 60 seconds while work is active. Record the current phase, elapsed time, last checkpoint, quiet interval, and any blocked reason. A live subagent with no new checkpoint during model reasoning is not a hung process by itself. Interrupt it only for an explicit stop condition, an unauthorized mutation, an identity change, a repeated defect that meets the task's kill rule, or evidence that the executor cannot make progress.

If the native subagent interface is unavailable and the task explicitly permits a headless Codex CLI fallback, first inspect `codex --help` and `codex exec --help` and construct the invocation from the installed interface. Use JSON Lines event output, such as `codex exec --json`, when supported. Keep standard output and standard error separate, preserve the native exit code, and capture the final agent message separately when the installed CLI supports that option. Record thread and turn starts and completions, command executions, file changes, tool calls, web searches, plan updates, errors, token usage, first and last event times, the longest quiet interval, and retry or failure state. Write a content-minimized status sidecar after each event and at least every 15 seconds while the process is active.

Apply the least privilege that permits the task. A bypass-approvals or danger-full-access option may be used only when the user authorized it and the host environment supplies the required external isolation. Permission bypass is not a speed or inference-tier setting. Do not record complete prompts, hidden reasoning, credentials, tokens, cookies, unrelated tool output, or private state in telemetry. Store raw JSONL, standard error, and final-message evidence outside Git; put only summarized metrics, hashes, and paths in the orchestration tracker.

For either Codex interface, use the task manifest and terminal result schema already required by this prompt. After the final validation passes, require the executor to return the small terminal result and stop. Attribute preparation, model, tool, validation, retry, quiet, and post-gate time separately so that a slow run can be diagnosed without guessing.

## Durable orchestration tracker

Create or resume `TEMP-coding-agent-loop-state.json` in the PSStyleGuide repository root. Do not commit it. Use safe structured-file updates: write a complete candidate, parse it successfully, and replace the tracker without leaving invalid JSON. Preserve prior run history when the plan hash changes.

The tracker must contain:

- Schema version, active run ID, overall status, and UTC timestamps.
- Absolute paths for both repositories, the plan, and this orchestration prompt.
- Current PSStyleGuide planning branch plus the plan and orchestration-prompt SHA-256 values.
- The detected task count, first and last task number, and proof that numbering is consecutive and unique.
- One current-turn `advisor_activation` receipt that separates discovery, explicit-selection acceptance, complete instruction loading, and verified activation, plus one workflow-level `routing_capability_preflight` that describes the inspected interfaces and their exact-override and post-spawn inspection capabilities without asserting that any task-specific route is currently available.
- For every task:
  - Number, exact title, execution class, target repository, and SHA-256 of the exact extracted task text.
  - Predecessor task numbers, relationship types, conditional branch, and required predecessor outputs.
  - Status: `pending`, `in_progress`, `completed`, `failed`, or `blocked`.
  - Invocation, continuation, failed-validation, and consecutive-no-progress counts.
  - Approved manifest SHA-256 and one applicable `model_routing` record or explicit routing-bypass record.
  - Executor type, routing-decision identifier, frozen route, process or agent identifier when available, and start/checkpoint/completion timestamps.
  - Pre-execution and post-execution Git branches, commits, trees, worktree states, issue/PR states, and other task-local identities.
  - Files or GitHub objects created or changed.
  - Validation commands, native exit codes, results, evidence URLs, and independently verified completion result.
  - Blocker, retry context, and exact deterministic resume action.
- Last completed task, current task, last successful checkpoint, and next deterministic action.

A coding task's tracker data must be equivalent in meaning to this normative shape; additional fields are permitted:

```json
{
  "advisor_activation": {
    "checked_at_utc": "<timestamp>",
    "host_surface": "<codex_ide|codex_cli|chatgpt_desktop|other>",
    "requested_skill": "model-routing-advisor",
    "discovered": true,
    "discovery_source": "<structured_selector|skills_command|host_resource>",
    "explicit_selection_accepted": true,
    "full_instructions_loaded": true,
    "resolved_skill_identity": "<host identity>",
    "resolved_resource": "<filesystem path or opaque host resource>",
    "content_utf8_bytes": "<integer or null>",
    "content_sha256": "<hash or null>",
    "activation_verified": true,
    "verification_source": "<host evidence>",
    "limitation": null
  },
  "routing_capability_preflight": {
    "checked_at_utc": "<timestamp>",
    "native_subagent_interface_available": true,
    "exact_model_override_request_supported": true,
    "exact_reasoning_override_request_supported": true,
    "post_spawn_effective_model_visible": false,
    "post_spawn_effective_reasoning_visible": false,
    "headless_fallback_available": false,
    "evidence_source": "<runtime inspection or command>",
    "limitations": [
      "<limitation>"
    ]
  },
  "model_routing": {
    "applicable": true,
    "bypass_reason": null,
    "routing_skill": "model-routing-advisor",
    "routing_decision_id": "<unique identifier>",
    "routing_invoked_at_utc": "<timestamp>",
    "task_text_sha256": "<hash>",
    "manifest_sha256": "<hash>",
    "recommendation": {
      "recommended_model": "<value or null>",
      "reasoning_effort": "<value or null>",
      "mode": "<automatic_delegation|manual_switch_required|advisory>",
      "confidence": "<value or null>",
      "signals": [
        "<non-secret routing signal>"
      ],
      "escalation_trigger": "<value or null>",
      "metadata_source": "<runtime_catalog|official_documentation|unavailable>",
      "cost_verified": false
    },
    "selection": {
      "source": "<task_requirement|approved_plan_requirement|advisor_recommendation>",
      "exact_model_requirement": "<value or null>",
      "exact_reasoning_requirement": "<value or null>",
      "selected_model": "<value or null>",
      "selected_reasoning_effort": "<value or null>",
      "frozen_at_utc": "<timestamp>"
    },
    "override": {
      "exact_override_supported": true,
      "requested_model": "<value or null>",
      "requested_reasoning_effort": "<value or null>",
      "request_accepted": "<true|false|unknown>",
      "resolved_model": "<value or null>",
      "resolved_reasoning_effort": "<value or null>",
      "effective_model": "<value or null>",
      "effective_reasoning_effort": "<value or null>",
      "effective_override_verified": false,
      "verification_source": "<value or null>",
      "verification_limitation": "<value or null>"
    },
    "executor": {
      "agent_or_task_id": "<value or null>",
      "parent_agent_or_goal_id": "<value or null>",
      "dispatch_ordinal": 1,
      "no_descendants_required": true
    },
    "reroutes": []
  }
}
```

For a `Human execution required`, `Not executable; tracking/control only`, or parent-reserved numbered task, do not invoke the advisor. Record the applicable normalized bypass reason in this shape:

```json
{
  "model_routing": {
    "applicable": false,
    "bypass_reason": "<human_execution_required|tracking_control_only|parent_reserved>"
  }
}
```

Append each reroute to `reroutes`; never overwrite or discard the previous routing decision or earlier reroutes:

```json
{
  "rerouting_decision_id": "<unique identifier>",
  "rerouted_at_utc": "<timestamp>",
  "trigger": "<material_task_change|verified_capability_insufficiency>",
  "supporting_evidence": "<reference>",
  "prior_routing_decision_id": "<identifier>",
  "prior_task_text_sha256": "<hash>",
  "prior_manifest_sha256": "<hash>",
  "new_task_text_sha256": "<hash>",
  "new_manifest_sha256": "<hash>",
  "prior_model": "<value>",
  "prior_reasoning_effort": "<value>",
  "new_model": "<value>",
  "new_reasoning_effort": "<value>"
}
```

Update and validate the tracker after discovery, plan hashing, task extraction, state reconstruction, and at every routing lifecycle point: capability preflight; task classification; manifest finalization and hashing; route recommendation; precedence resolution and route freeze; actual route-availability check; executor creation; override acceptance or rejection; post-spawn verification when available; continuation; replacement retry; reroute; receiving an executor result; every independent validation group; task completion or blockage; and overall completion or blockage.

Keep requested, accepted, resolved, and effective settings separate. `effective_override_verified` cannot become `true` solely because the override request was accepted. Populate resolved or effective fields only from a runtime source that exposes the corresponding fact, and record the source or limitation. `cost_verified: false` prohibits claiming the selection is proven to be the cheapest. At dispatch, independently confirm that the task-text and manifest hashes still match the frozen routing record.

A coding task cannot complete without a valid applicable routing record. A non-coding numbered task cannot complete without an explicit valid routing-bypass record. Tracker evidence and independent validation, not an executor's unsupported assertion, control completion.

Never put a credential, token, cookie, complete environment dump, private browser state, or secret value in the tracker.

## Startup and resume procedure

On every startup, resumption, or context-window recovery:

1. Confirm the PSStyleGuide checkout is on `planning-CRT-PR-852`. Confirm the plan and this prompt exist on that branch. If not, stop; do not recreate them on another branch.
2. Read the plan and this prompt completely. Read applicable repository instructions in both repositories.
3. Hash the plan and this orchestration prompt. Extract the preamble and every task from a `## Task N — ...` heading through the byte before the next task heading or `## References`.
4. Verify that tasks are numbered consecutively from 1 through the plan's last task with no gap or duplicate. Parse each task's execution class, dependencies, conditional branch, stop conditions, output, and `Complete when` condition.
5. Read and parse the tracker when it exists. If its plan hash differs, preserve the old run in history and create a new run. If only the orchestration-prompt hash differs, append a prompt-change reconciliation record, revalidate the current lifecycle and routing gates under the new prompt, and retain task completion only where its unchanged task text and evidence still satisfy the new controls. A parent-only activation-rule change does not by itself change a numbered task or approved task manifest; do not invent a reroute unless the exact task or manifest actually changes or capability-insufficiency evidence independently meets the reroute rule. Do not carry completion across changed task text without revalidation.
6. Inspect the live host-provided skill metadata. Record or refresh `advisor_activation` without treating autocomplete, an initial-list entry, or a local file as activation. If the parent cannot inspect the interactive selector, record that limitation rather than guessing. If the next action requires an initial advisor invocation or reroute and explicit selection is not accepted in the current turn, follow the one-resumption procedure in Required advisor activation before declaring the skill unavailable.
7. Inspect the live runtime and record or refresh the workflow-level routing capability preflight for per-subagent exact model and reasoning-effort requests, native delegation, post-spawn visibility, and any permitted headless fallback. Do not treat documentation, a static model catalog, a prior task's success, or requested settings as proof that a future task-specific route is available.
8. Query `git status --short --branch`, local and remote refs, and the task-relevant authenticated GitHub state in both repositories. Paginate every relevant result. Preserve unrelated user changes.
9. Reconstruct missing tracker state from plan hashes, Git objects, GitHub objects, permanent evidence records, routing evidence, and validation results. File existence or an executor's prior statement is not enough.
10. Independently revalidate every task marked complete before skipping it. If evidence no longer satisfies its exact `Complete when` condition or routing-record requirements, return it to `in_progress` or `blocked` as the evidence requires.
11. Select the lowest-numbered incomplete task whose predecessor and branch conditions are satisfied. Never advance past an incomplete predecessor.

After compaction, restart with this procedure. Do not restart from Task 1 by default.

## Task dispatch

Before every initial dispatch, continuation, replacement retry, or reroute, complete the applicable checks below. Invoke the advisor only for the initial dispatch of a `Coding agent executable` task or for a reroute permitted by the frozen-route rules:

1. Re-read the complete current task, compute its SHA-256, confirm it equals the tracker value, classify the task, and record that classification.
2. Resolve every value already knowable from Git, GitHub, a predecessor's permanent record, or the plan's verified inputs. Do not leave a known value as a placeholder.
3. Re-query every task-local issue, PR, review, review thread, comment, commit, check, dependency, base/head identity, merge state, main ref, and repository setting needed to prove that the task can start. Use authenticated structured data and paginate relevant connections.
4. Verify the target repository, branch, baseline commit, and working tree. Do not include planning-branch files in an implementation branch or PR.
5. Verify the implementation slot is free before a feature implementation begins. Issue creation and implementation commencement remain separate actions.
6. Finalize and approve the exact task manifest, ensure it contains no unresolved known value, compute its SHA-256, and record the task-text and manifest hashes.
7. For an initial `Coding agent executable` dispatch or permitted reroute, require `advisor_activation.activation_verified: true`, invoke that exact selected advisor only now, apply precedence, freeze the route, and check the selected route's actual dispatch-time availability and exact-override support. If activation is not verified, use the one-resumption procedure instead of treating initial-list absence as unavailability. For a continuation or ordinary replacement retry, do not invoke the advisor; validate the existing frozen routing record and selected route. For any non-coding or parent-reserved task, do not invoke the advisor; record or validate the applicable routing bypass.
8. Confirm the task-text and manifest hashes still match the routing or bypass record. Mark the task `in_progress`, record the pre-execution state, and save the tracker.
9. For an initial coding-task dispatch or reroute, let the advisor create exactly one fresh executor when automatic delegation is supported. For a valid continuation, reuse the same executor. For an ordinary replacement retry, create one fresh sequential executor through the existing dispatch mechanism with the same frozen route and without a new advisor invocation. Increment the dispatch ordinal and record the active executor's identity and override acceptance or rejection before permitting substantive work. Do not create another executor for the same dispatch ordinal. If only the explicitly permitted headless fallback can request the identical frozen route, start one fallback process as the sole executor; otherwise block.

Give the executor:

- The exact complete task text.
- The plan's non-operative purpose and verified-state material needed to interpret that task.
- The absolute target-repository path.
- A statement that it may perform only that task's primary action or lifecycle gate.
- The approved manifest and its hash, frozen routing-decision identifier, selected route, task-text hash, and a prohibition on descendants.
- The executor's retry context, if any, in a separately labeled section that does not weaken or replace the task.
- A required final report containing task number, `COMPLETED`, `IN_PROGRESS`, `FAILED`, or `BLOCKED`; files and external objects changed; exact identities; commands and exit codes; evidence URLs; validation results; remaining risks; and the exact `Complete when` proof.

For every coding-agent task, use the one executor created at the routing boundary, apply the Codex observability controls above, and wait for its terminal result. Do not run another executor while it is active. The parent must not perform a second spawn for the same dispatch.

The parent does not perform the task's substantive implementation. The parent can maintain the tracker, extract and hash prompts, inspect artifacts and diffs, query GitHub, run independent validation, and decide whether to complete, continue, retry, or block the task.

## Independent validation after every invocation

Do not accept an executor's verbal completion claim as proof. Independently:

1. Re-read the task's `Complete when` condition and verify every clause.
2. Recompute the exact task-text and approved manifest hashes and prove that they match the active routing or bypass record.
3. For a coding task, validate the applicable `advisor_activation` receipt, expected executor identity, task identity, routing-decision identifier, frozen route, dispatch ordinal, no-descendants requirement, and absence of any overlapping executor. For a non-coding task, validate its classification and bypass reason and prove no advisor or executor was used for the reserved work.
4. Validate selection precedence, actual route-availability evidence, exact-override support, request acceptance or rejection, and any separately reported resolved settings. Verify effective settings only from the recorded runtime source; otherwise require `effective_override_verified: false` and an honest limitation. Validate the complete append-only reroute history, if any.
5. Inspect both worktrees, branches, commits, trees, changed paths, and diffs. Preserve unrelated changes and confirm only authorized scope changed.
6. Re-query affected GitHub state with authenticated structured reads. Paginate comments, reviews, review threads, checks, commits, linked issues, closing references, sub-issues, and dependency connections when applicable.
7. Confirm every recorded SHA, tree, blob, URL, PR number, issue number, review, check, and runtime identity exists and matches the claimed object.
8. Run or verify every task-local validation command. Record the command, working directory, runtime identity, native exit code, and result.
9. For review and quality gates, prove that both apply to the same final head SHA and tree. Any reviewable-byte change invalidates both gates and returns execution to the task-local repeat path.
10. For a merge, prove the reviewed parent, merge method, landed commit/tree/blobs, post-merge checks, issue state, and retained handoff requirements. Do not infer landed identity from a branch name.
11. For a cross-repository comparison, read both sides only from recorded landed commits and Git blobs. Require byte identity for role-equivalent CI workflows and common materials after only proved repository-specific substitutions. Treat implementation history, separate authorship, convenience, or lower effort as invalid reasons for a difference.
12. If a binary or behavior differs and the repository-specific justification is not certain, stop and escalate it to the human operator. Do not classify it as intentional merely to let the cycle proceed.
13. Confirm no unfinished reviewer finding, stale review, invalid deferral, false dependency, fabricated value, unauthorized repository-setting change, or unsupported routing assertion remains.

If all clauses pass, and the task has a valid applicable routing record or valid routing-bypass record, mark the task complete and save the tracker. Advance only to the next satisfied task.

## Continuations, retries, and blockers

If an invocation makes measurable valid progress but the task honestly remains incomplete, record a continuation. Continue the same Codex thread only while the executor identity, task-text hash, approved manifest hash, frozen route, pinned repository identities, and accepted artifacts all remain valid. A continuation reuses the same route and does not invoke the advisor. If those continuation conditions fail without a material task or manifest change or verified capability insufficiency, use a fresh sequential replacement executor with the same frozen route. Do not count valid progress as failed validation.

If validation fails:

1. Record exact defects, paths, object identities, commands, and exit codes.
2. Preserve partial work and unrelated user changes.
3. Increment the failed-validation and consecutive-no-progress counts as applicable.
4. Stop or close the old executor before replacement. Never overlap the old and replacement executors.
5. For an ordinary retry, invoke a fresh sequential executor with the unchanged task text, approved manifest hash, routing-decision identifier, and frozen route. Do not invoke the advisor again. Put the defects in a separate `ORCHESTRATOR RETRY CONTEXT` section that does not alter the task or manifest.
6. Revalidate the complete task, executor identity, hashes, and routing evidence, not only the previously failed part.

Reroute only after a material change to the exact task or approved manifest produces a new hash, or after independent validation proves with concrete evidence that the frozen route's capability is insufficient. Invoke the advisor once for the reroute; append the reroute record and supporting evidence; retain all prior routing history; create a new routing-decision identifier; apply selection precedence again; freeze the new route; and use one fresh sequential executor. Do not reroute merely because an invocation failed, made no progress, was interrupted, or is being continued. If an exact task or approved-plan requirement prevents selecting a different route, block instead of overriding it.

After three consecutive invalid or no-progress invocations for the same task, stop and mark the workflow blocked. Also stop immediately when:

- The next task is `Human execution required` and its action is not already complete.
- Exact human approval, administrator authority, a credential, or a setting decision is missing.
- The selected exact model or reasoning effort cannot be requested through the native interface or an explicitly task-authorized fallback that supports the identical frozen route.
- An exposed exact override rejects the selected value and no already-authorized interface can request the identical route.
- The advisor is required, a direct host or operator selector read after one restart proves that it is not discoverable, and no already-activated advisor instance is valid for the current routing boundary. A discovered-but-unselected advisor requires the one-resumption procedure and is not this terminal blocker.
- A task-local stop or escalation condition occurs.
- A required identity changed unexpectedly and cannot be reconciled safely.
- A proposed repository-specific byte or behavior difference remains uncertain.
- Continuing would weaken security, failure truth, review coverage, lifecycle separation, or reciprocal fixed-point integrity.

When blocked, save a valid tracker and report the completed task range, current task, exact blocker, preserved work, evidence, failed or continuation history, and minimum human or external action needed to resume. Do not broaden the requested authority.

## Codex interface references

- [OpenAI Build skills: activation, discovery locations, list budgeting, and invocation policy](https://learn.chatgpt.com/docs/build-skills)
- [OpenAI Codex configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference)
- [OpenAI Codex subagents](https://learn.chatgpt.com/docs/agent-configuration/subagents)
- [OpenAI Codex non-interactive mode](https://learn.chatgpt.com/docs/non-interactive-mode)
- [OpenAI Codex `AGENTS.md` instructions](https://learn.chatgpt.com/docs/agent-configuration/agents-md)

## Overall completion

The orchestration run is complete only when every numbered task passes its exact `Complete when` condition and has a valid applicable routing record or valid bypass record; every advisor invocation has a valid activation receipt; its task-text and approved manifest hashes match; its expected executor identity, or the expected absence of an executor for bypassed work, is proved; its no-overlap evidence matches its routing record; override support and acceptance status are recorded for coding work; effective-verification status is honest; and its reroute history, if any, is complete and append-only. The final completion audit must exist, both repositories must be at the recorded fixed point, all task hashes must still match the active plan, all existing task evidence and independent validation must pass, no blocker or placeholder may remain, and the tracker must be valid and marked complete.

At completion, report:

- Active run ID, plan and orchestration-prompt paths and SHA-256 values, and task range.
- Every task's title, execution class, routing applicability or bypass reason, invocation counts, final status, and completion evidence.
- For each coding task, the selected model, selected reasoning effort, selection source, routing-decision identifier, executor identifier, override-request acceptance status, effective-route verification status, verification limitation when applicable, and continuation, replacement-retry, and reroute history.
- Commits, trees, blobs, issues, PRs, reviews, checks, comparisons, fixed-point records, and validations produced.
- Final PSStyleGuide and TerraformStyleGuide commits and trees.
- Every proved repository-specific difference and its owner/review condition.
- Confirmation that role-equivalent CI workflows and common materials are byte-identical after only the recorded repository-specific substitutions.
- Any nonblocking documented limitation.
- The tracker path and deterministic cleanup guidance for uncommitted `TEMP-*` orchestration artifacts.

Report routing per task; do not summarize the workflow with one global model or reasoning setting. Do not claim completion if the final audit, reciprocal fixed point, any applicable model-routing record or required bypass record, task or manifest hash audit, executor-identity or no-overlap audit, override evidence, numbering/hash audit, or independent validation fails.
