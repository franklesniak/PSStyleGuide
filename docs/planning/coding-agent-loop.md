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

Before initial routing, create and approve a small declarative manifest. It must state the exact repository, branch, head commit, allowed and forbidden paths, allowed commands, expected review-thread and comment identities, allowed public mutations, checks, completion receipt, and any exact route requirement from the task or approved plan. When the task can make public mutations, the manifest must also define one complete ordered publication unit. The publication unit must name every target, operation, precondition, exact preimage when available, intended postimage or semantic postcondition, idempotency key when supported, and required targeted readback. A publication unit is one approval unit; multiple GitHub API calls are not atomic. Resolve values, finalize the manifest, and record its SHA-256 before invoking the advisor. Before every continuation or replacement, prove that the pinned manifest hash still identifies the applicable approved manifest. A material manifest change requires a new hash and explicit reroute. Do not make the executor discover values that the parent already knows.

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

Declare validation prerequisites and enforce their order in the controller. When a deterministic identity calculator, generator refresh, syntax check, or focused precheck must precede a more expensive validator, deny the early request without executing it and state the missing prerequisite label. Use four validation tiers: structural state checks after a state change; focused changed-surface checks after an executor result; publication checks at the public-mutation boundary; and task-closure or overall-completion checks at their respective final boundaries. Do not run a broader tier when a cheaper prerequisite has not passed.

Write an immutable validation receipt after a tier passes. The receipt must identify the validator by path and SHA-256 or stable runtime identity; the exact command and native exit code; covered paths, objects, predicates, and task clauses; relevant plan, prompt, task, manifest, commit, tree, PR-head, check, review, and external-object identities; input fingerprints or ETags when exposed; result; and UTC timestamp. Reuse the receipt only while every invalidation key is unchanged and the requirement does not explicitly demand a fresh live observation. A later edit invalidates only receipts whose covered paths, objects, predicates, or dependency identities intersect that edit. Do not spend a full validation attempt to discover a deterministic identity update that the manifest already declares.

Make every validation wrapper preserve the native exit code and bounded, separate standard output and standard error for each child command. On failure, return the validator's structured category and the applicable output before throwing or stopping the session. Redact secrets and cap verbose output, but do not replace a machine-readable failure with only `command failed`; the Codex subagent must be able to act on the first result without re-reading validator source to recover the hidden reason.

In the final timing summary, separate model time, tool time, controller time, validation time, and the interval after the last required validation passed. When the Codex interface reports usage, record the documented input, cached-input, output, and reasoning-output token counts. Record service tier or cost only when the interface reports it; do not infer unavailable fields. These metrics can identify inference latency, repeated context processing, and post-gate narration as distinct bottlenecks without recording prompt or response content.

Record the advisor recommendation; selected and frozen route; requested overrides; request acceptance or rejection; resolved settings when the interface reports them; effective settings only when independently visible; verification source and limitation; and service tier when reported. Do not conflate these fields or mark `effective_override_verified` true merely because the request was accepted. Never change the selected model or reasoning effort to improve latency without an authorized, recorded reroute, and never substitute permission bypass or broader sandbox access for an inference-speed setting.

For a headless fallback, write a small status sidecar after each event and at least every 15 seconds while the process is active. The status must show the process ID, thread ID when available, phase, current tool, elapsed time, last-event time, quiet time, counters, and a content-minimized blocked reason. A validation stop must name the exact failed check, the finding key, and the applicable section or field without copying sensitive content; do not reduce every validation failure to a generic invalid-artifact message. Write a final timing summary even after a timeout or hard stop. Put only summarized metrics and hashes in the orchestration tracker. Do not put complete prompts, tool results, debug logs, credentials, tokens, cookies, or private state in the tracker.

When a headless structured stream reports a retry event, set the status phase to `api-retry`. Record the event's documented status class, attempt, maximum retries, and retry delay when present; use standard error only as a compatibility fallback. Distinguish the measured delay between a failed response and the next request from the latency of the later successful request. Do not attribute the full successful-response latency to rate-limit backoff. A live rate-limit backoff is not a model-thinking phase and is not a hung process. Clear the retry phase when a later request is dispatched, then classify that request as model or server response latency until a response or tool event proves progress.

Define a manifest-specific terminal result schema. After the last required validation and identity check pass, instruct the Codex subagent to emit that small structured result immediately and end the turn. The result must name the validated head, changed paths, validation labels, and remaining public actions. Do not request a polished narrative after the terminal gate. Treat any post-gate tool call or prolonged post-gate reasoning as observable overhead that needs an explicit task reason; do not silently accept it as required work.

For a headless fallback, parse each stream line as structured data before applying a stop rule. Treat a controller marker as a hard stop only when a failed tool result or controller response carries that marker. Never terminate Codex because an ordinary successful tool result contains the marker text. Terminate the exact fallback process immediately after a real controller hard stop or timeout, and record the event that caused the stop. For a native subagent, interrupt only that canonical agent after the same condition is proved.

Separate a denied tool request from a hard stop. A default-deny controller can return a recoverable denial when it blocks an unexecuted inspection request or an unallowlisted command, so the Codex subagent can use an approved tool instead. Reserve the hard-stop marker for execution-identity failures, scope or integrity violations, unauthorized write or public-mutation attempts, ambiguous mutation outcomes, and invalid success evidence. A recoverable denial must never weaken the allowlist or execute the rejected request.

When a headless fallback has an enforcing controller, treat an out-of-repository read request as a recoverable denial when the controller proves that it blocked the request before execution. Keep an out-of-scope write, an unproved inspection outcome, or an execution-identity mismatch as a hard stop. Do not discard a long-running subagent merely because an enforcing boundary safely refused to expose a user-memory or tool-state file.

For an authorized GitHub publication unit, the parent validates all current preconditions and approves the complete ordered unit once. The single authorized writer then executes each API mutation serially. Keep at least one second between mutative requests when the GitHub REST guidance applies. Validate each native API response against the exact expected object, write a create-new immutable receipt, and perform the declared targeted authenticated readback before the next mutation. Treat the response, receipt, and targeted readback as the immediate idempotency boundary. Stop on preimage drift, a failed mutation, a readback mismatch, or an ambiguous response. Do not repeat an ambiguous non-idempotent mutation. Record a safe partial-completion receipt and reconcile before any continuation.

After the last mutation passes its targeted readback, run one aggregate postflight for the complete publication unit. Do not insert another parent gate between mutation subgroups when the approved manifest, preconditions, ordered operations, executor identity, and target identities remain unchanged. A changed precondition or target invalidates the remaining unit and requires a new parent decision.

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

Use the native Codex subagent interface when the task dispatch rule requires a Codex executor. Record the routing-decision identifier, canonical agent ID or task name, frozen selected route, requested overrides, request-acceptance status, resolved and effective settings only when the interface reports them, effective-verification status and source or limitation, start time, completion time, and terminal status. Require checkpoints after analysis, the first tracked edit, validation, and any public mutation. Inspect the available agent-status or thread interface at least every 60 seconds while work is active. This inspection is a lightweight status probe. It is not authority to reload the full tracker, reparse the plan, enumerate the complete worktree, or perform a full GitHub reconciliation. Record the current phase, elapsed time, last checkpoint, quiet interval, and any blocked reason. A live subagent with no new checkpoint during model reasoning is not a hung process by itself. Interrupt it only for an explicit stop condition, an unauthorized mutation, an identity change, a repeated defect that meets the task's kill rule, or evidence that the executor cannot make progress.

If the native subagent interface is unavailable and the task explicitly permits a headless Codex CLI fallback, first inspect `codex --help` and `codex exec --help` and construct the invocation from the installed interface. Use JSON Lines event output, such as `codex exec --json`, when supported. Keep standard output and standard error separate, preserve the native exit code, and capture the final agent message separately when the installed CLI supports that option. Record thread and turn starts and completions, command executions, file changes, tool calls, web searches, plan updates, errors, token usage, first and last event times, the longest quiet interval, and retry or failure state. Write a content-minimized status sidecar after each event and at least every 15 seconds while the process is active.

Apply the least privilege that permits the task. A bypass-approvals or danger-full-access option may be used only when the user authorized it and the host environment supplies the required external isolation. Permission bypass is not a speed or inference-tier setting. Do not record complete prompts, hidden reasoning, credentials, tokens, cookies, unrelated tool output, or private state in telemetry. Store raw JSONL, standard error, and final-message evidence outside Git; put only summarized metrics, hashes, and paths in the orchestration tracker.

For either Codex interface, use the task manifest and terminal result schema already required by this prompt. After the final validation passes, require the executor to return the small terminal result and stop. Attribute preparation, model, tool, validation, retry, quiet, and post-gate time separately so that a slow run can be diagnosed without guessing.

## Cycle performance and external waits

Use a 15-minute active-work objective. Use 30 minutes only after the parent records why the task is extremely complex. Active work includes preparation, model, controller, tool, and validation time; measure external and human wait separately.

At the objective, finish the current safe receipt boundary and start no new phase or broad audit. Never interrupt a public mutation. Write `PERFORMANCE_BUDGET_EXCEEDED` with elapsed active time, completed boundaries, first unfinished gate, preserved evidence, and one deterministic resume action; save state and end. This is a diagnostic pause, not task failure or CI. Do not add a workflow, required check, `timeout-minutes`, or CI abort for this objective.

For a pending external or human event, write `WAITING_EXTERNAL` or `WAITING_HUMAN` with the wake condition, object identities, last status, ETag or conditional token, and one resume action; then end. Prefer an existing event. Otherwise, make one stable, specific conditional read on explicit continuation. If unchanged, refresh the wait receipt and end without full plan, tracker-history, worktree, or GitHub reads. Do not build webhook infrastructure for this prompt.

Use these check states:

- `SUCCESS`: applicable check completed on the required head with an allowed successful conclusion.
- `FAILURE`: applicable check completed with a failure-type conclusion.
- `PENDING_WITH_RUNS`: applicable nonterminal runs exist.
- `NONTERMINAL_ZERO_RUN`: suite is nonterminal and has zero direct runs; record `passed=false`, `failed=false`, and `execution_count=0`. Suite existence is not provider execution.
- `NOT_CONFIGURED` or `NOT_APPLICABLE`: separate plan, protection, setting, or integration evidence proves the state. Never infer either state from zero runs alone.

A required zero-run suite can block its gate, but it is not failed and has zero provider execution time. Do not trigger Claude or another optional provider unless the task requires and authorizes that run.

## Durable orchestration tracker

`TEMP-coding-agent-loop-state.json` is an uncommitted compact mutable projection, not the evidence store. Update it atomically: write, parse, validate, and replace. Put detailed create-new receipts outside the implementation worktree when possible; otherwise use one untracked `TEMP-coding-agent-loop-evidence/<run-id>/` directory. Never edit an accepted receipt; supersede it by identity. A legacy schema-1 tracker that contains recursive history is evidence, not resumable state: preserve it without reading it into the model or overwriting it. The schema-2 controller uses an explicit isolated state directory for its tracker, index, and evidence root.

The tracker contains only:

- Schema/run/timestamps and overall state: `active`, `waiting_external`, `waiting_human`, `performance_paused`, `blocked`, or `complete`.
- Control paths and branch plus plan, prompt, index, controller, task-count, and numbering-proof identities.
- Progress: last/current task, active dependencies, frontier summary, checkpoint, active-work budget/time, wait, and one next action.
- Per task: number; `pending`, `in_progress`, `completed`, `failed`, or `blocked`; task hash; routing/bypass and completion receipt IDs; invalid flag; retry counters. Keep title, body, dependencies, and completion text in the index.
- Active executor: routing ID, frozen route, executor ID, ordinal, times, and status.
- One durable receipt catalog, never an active-only map: each compact entry has ID, type, task, path, UTF-8 bytes, SHA-256, time, validity or supersession state, predecessor IDs, and superseded ID. It contains every receipt reachable from any task root for the active run, even after the task leaves the mutable frontier. The catalog is metadata only; receipt bodies remain in the evidence directory.
- A completed task has one completion-root receipt. Its routing or bypass root, completion root, every predecessor edge, and every superseded edge MUST resolve through the durable catalog to a byte- and hash-matched immutable receipt. An ID by itself is never a valid edge.
- Invalid edges and reasons.

The representative 392-task projection, including its durable catalog, MUST remain at or below 1 MiB serialized UTF-8. Measure it before use and record the byte total and field-level headroom; externalize new detail instead of expanding the tracker.

Reject any prior tracker, `tracker_snapshot`, task or receipt body, manifest, prompt, tool output, debug log, full worktree inventory, environment dump, private state, or secret in the tracker. Before use, serialize a representative all-task fixture, test all task/routing/wait/retry states, and derive a documented byte budget with field-level headroom. On excess, externalize detail and rebuild before a model read; never discard evidence.

Every receipt records schema/type/ID, run/task, time, exact inputs, result, evidence references, predecessor IDs when applicable, and controller/validator identity. After readback, its durable catalog entry records path, UTF-8 bytes, and SHA-256. Use distinct types for compilation/reconstruction, activation/capability/routing/bypass/reroute, manifest/dispatch/continuation/replacement, validation, publication/mutation/readback/postflight, wait/budget pause, and task/run termination.

Activation and capability receipts retain all facts required in Required advisor activation and Required executor routing. A routing receipt retains task/manifest hashes, recommendation and metadata source, cost-verification status, precedence, exact requirements, frozen route, dispatch-time availability, requested/accepted/resolved/effective settings, effective-verification source or limitation, executor/parent IDs, ordinal, no-descendants rule, and append-only reroutes. Never infer effective settings from acceptance; never claim cheapest when `cost_verified: false`. Bypass reasons are only `human_execution_required`, `tracking_control_only`, or `parent_reserved`. A reroute retains trigger/evidence, prior receipt/decision, old/new task and manifest hashes, and old/new routes.

Write the tracker only at durable boundaries: control reconciliation, capability, route/bypass, dispatch, accepted result, validation tier, mutation readback, publication postflight, wait/budget pause, task termination, and run termination. Coalesce linked transitions; do not write for an unchanged probe/read. Completion requires the applicable current routing or bypass receipt plus independent validation.

## Deterministic plan index and invalidation

Use one versioned deterministic controller for hashes, task extraction/offsets/fields, numbering, schemas, receipt indexing, invalidation, counts, comparisons, and state transitions. Record its path/hash. Do not use a model turn for deterministic transformations.

Cache the uncommitted derived index at `TEMP-coding-agent-loop-plan-index.json`. Record schema/parser/controller identities; plan path/bytes/hash; preamble bounds/hash; numbering proof; and each task's number, title, class, target, byte bounds, text hash, dependencies/branches, stops, output, and `Complete when`. Accept only valid, nonoverlapping bounds, consecutive unique numbers, and matching slice hashes. Reuse only when schema/parser/controller and plan identity remain valid; otherwise recompile. On an unchanged resume, give the model only needed preamble, current task, and active dependency slices.

Each reusable receipt declares only applicable invalidation keys: plan, prompt, task, manifest, controller/validator, commit/tree/branch, PR base/head, review/thread/comment, check suite/run, repository setting, external object/ETag, and dependency receipts. The frontier is the current task, active dependencies, affected paths/Git/GitHub objects, waits, and completed tasks with changed keys. Expand through affected dependency edges; exclude unchanged completed tasks.

Invalidate by exact intersection:

- Plan change: recompile, compare task/dependency hashes, and invalidate affected tasks/downstream only.
- Prompt change: reconcile affected lifecycle/receipt rules only; it does not invalidate the plan index.
- Controller/parser/validator/schema change: invalidate dependent receipts only.
- Local or external identity change: invalidate receipts that name the identity or cover its predicate.
- Missing receipt, bytes/hash/schema mismatch, malformed catalog entry, unresolved task root, broken predecessor, or broken supersession edge: invalidate it and dependents.

File existence and executor assertions are not validity proof.

## Startup and resume procedure

On every startup, resumption, or context-window recovery:

1. Confirm the PSStyleGuide checkout is on `planning-CRT-PR-852`. Confirm the plan and this prompt exist on that branch. If not, stop; do not recreate them on another branch.
2. Read this prompt completely once for the current parent context. Read applicable repository instructions for the active target repository. Read the other repository's instructions only before that repository enters the mutable frontier.
3. Use the deterministic controller to stream-hash the plan and prompt without placing the complete plan in model context. Validate the compact tracker and durable receipt-catalog closure from every routing/bypass and completion root. Mechanically verify each catalog path, UTF-8 byte count, SHA-256, schema, predecessor edge, and supersession edge. If any link is missing, malformed, or mismatched, mark its task roots invalid and expand the frontier through dependents before any task can be skipped.
4. Validate the plan index against the current plan, schema, parser, and controller identities. If the index is missing or invalid, parse the complete plan deterministically, verify consecutive unique tasks, build the index, validate every slice hash and required field, and write one compilation receipt. Do not ask the model to parse all tasks. A prompt-only change does not invalidate a plan index whose plan and parser inputs are unchanged.
5. If the plan hash changed, finalize the prior run by receipt, compile the new index, compare task hashes and dependencies, and apply the invalidation rules. Create a new run only when the plan semantics require it; do not copy prior tracker bodies into the new tracker. If only the prompt hash changed, write one prompt-change reconciliation receipt, evaluate affected policies and receipt types, and retain unchanged task evidence when its invalidation keys still satisfy the new controls. Do not invent a reroute unless the exact task or manifest changes or verified capability-insufficiency evidence meets the reroute rule.
6. Load the indexed preamble material needed for interpretation, the exact current task slice, its active dependency closure, and the immutable receipts referenced by the mutable frontier. Do not load every completed task or receipt body.
7. Inspect live host-provided skill metadata when the next action can reach an initial advisor invocation or permitted reroute, or when the host turn changed. Record or refresh the advisor-activation receipt without treating autocomplete, an initial-list entry, or a local file as activation. If the parent cannot inspect the interactive selector, record that limitation rather than guessing. If explicit selection is required and not accepted in the current turn, follow the one-resumption procedure in Required advisor activation before declaring the skill unavailable.
8. Inspect the live runtime and refresh the routing-capability receipt when the runtime, host turn, interface, or selected route changed, or before a dispatch whose exact support is not already current. Do not treat documentation, a static model catalog, a prior task's success, or requested settings as proof that a future task-specific route is available.
9. Query a structured, path-scoped Git status and the local or remote refs in the mutable frontier. Summarize unrelated untracked state by count and byte total; do not inject its complete path inventory. Query only task-relevant authenticated GitHub objects in the frontier. Use stable, specific conditional reads when supported. Paginate a complete connection only on a cache miss, relevant identity change, final task closure, or an explicit completeness predicate.
10. Reconstruct missing state from validated plan-index entries, Git objects, targeted GitHub objects, and immutable receipts reached through the durable catalog. File existence or an executor statement is not enough. Invalidate a missing or mismatched receipt, an unresolved root, or a broken predecessor/supersession edge and expand the frontier through its dependency edges.
11. For a task marked complete, validate its routing/bypass and completion-root closure plus invalidation keys before skipping it. Re-run completion validation only when an invalidation key changed or the exact `Complete when` condition requires a fresh observation. Do not revalidate all completed tasks on every resume.
12. Select the lowest-numbered incomplete task whose predecessor and branch conditions are satisfied. Never advance past an incomplete predecessor.

After compaction, restart with this procedure. Reuse the compact projection, validated plan index, and unchanged immutable receipts. Do not restart from Task 1 by default.

## Task dispatch

Before every initial dispatch, continuation, replacement retry, or reroute, complete the applicable checks below. Invoke the advisor only for the initial dispatch of a `Coding agent executable` task or for a reroute permitted by the frozen-route rules:

1. Read the exact current-task slice from the validated plan index, compute its SHA-256, confirm that it equals the index and tracker values, classify the task, and write or validate the classification receipt.
2. Resolve every value already knowable from Git, GitHub, a predecessor's permanent record, or the plan's verified inputs. Do not leave a known value as a placeholder.
3. Derive the dispatch mutable frontier from the task's start predicate and receipt invalidation keys. Re-query only affected task-local issues, PRs, reviews, review threads, comments, commits, checks, dependencies, base or head identities, merge state, refs, and repository settings. Use authenticated structured data. Prefer stable, specific conditional reads. Paginate a full connection only on a cache miss, relevant identity change, or explicit completeness predicate. Reuse a valid receipt for an unchanged object.
4. Verify the target repository, branch, baseline commit, and working tree. Do not include planning-branch files in an implementation branch or PR.
5. Verify the implementation slot is free before a feature implementation begins. Issue creation and implementation commencement remain separate actions.
6. Finalize and approve the exact task manifest, ensure it contains no unresolved known value, compute its SHA-256, and record the task-text and manifest hashes.
7. For an initial `Coding agent executable` dispatch or permitted reroute, require `advisor_activation.activation_verified: true`, invoke that exact selected advisor only now, apply precedence, freeze the route, and check the selected route's actual dispatch-time availability and exact-override support. If activation is not verified, use the one-resumption procedure instead of treating initial-list absence as unavailability. For a continuation or ordinary replacement retry, do not invoke the advisor; validate the existing frozen routing record and selected route. For any non-coding or parent-reserved task, do not invoke the advisor; record or validate the applicable routing bypass.
8. Confirm the task-text and manifest hashes still match the routing or bypass receipt. Mark the task `in_progress`, record the compact pre-execution projection, and save the tracker once at this durable boundary.
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

Do not accept an executor's verbal completion claim as proof. Validate the executor result against the current mutable frontier and the applicable validation tier:

1. Parse the manifest-specific terminal result. Identify every claimed local and external change, every unchanged claimed dependency, and the requested lifecycle transition.
2. Recompute the current-task slice and manifest hashes. Prove that they match the active routing or bypass receipt.
3. For coding work, validate the applicable advisor-activation receipt, expected executor identity, task identity, routing-decision ID, frozen route, dispatch ordinal, no-descendants requirement, and absence of an overlapping executor. Validate selection precedence, dispatch-time availability, exact-override request support, request acceptance or rejection, separately exposed resolved settings, effective-verification source or limitation, and the append-only reroute chain. For bypassed work, validate the classification and normalized bypass reason and prove that no prohibited executor was used.
4. Use deterministic code to inspect the target worktree, branch, commit, tree, path-scoped status, and diff. Inspect the other repository only when the task or a changed dependency puts it in the frontier. Preserve unrelated changes. Prove that changed paths are inside the authorized mutation closure.
5. Compute receipt invalidation by exact intersection with changed paths, Git identities, GitHub object versions, external-state identities, task outputs, and dependency edges. Retain receipts whose inputs and covered predicates are unchanged. Record every invalidation reason.
6. Run structural validation for the compact tracker, durable receipt catalog, plan index, hashes, schemas, root/predecessor/supersession closure, counters, state transition, and applicable routing or bypass receipt. This tier must not perform a broad repository or GitHub audit.
7. Run focused changed-surface commands and predicates. Record the exact command, working directory, controller or runtime identity, native exit code, bounded output identity, covered paths and objects, and result. Do not rerun code validation for a metadata-only phase when no covered code or input changed.
8. Re-query affected GitHub state with authenticated stable and specific reads. Use conditional requests when supported. Paginate only connections required by a changed identity or explicit completeness predicate. Confirm recorded object identities and classify check suites with the explicit check-state taxonomy. Do not count a zero-run suite as provider execution.
9. For a public mutation, apply the approved publication-unit procedure. Validate each mutation receipt and targeted readback. Run one aggregate postflight after the final mutation. Do not repeat an ambiguous non-idempotent request.
10. At task closure, read the indexed `Complete when` data and verify every clause. Run the full task-local validator once after all cheaper prerequisites pass. Reuse unchanged prerequisite receipts. For review and quality gates, prove that both apply to the same final head SHA and tree; a reviewable-byte change invalidates those gate receipts and returns execution to the task-local repeat path.
11. For a merge, prove the reviewed parent, merge method, landed commit, tree, blobs, post-merge checks, issue state, and retained handoff requirements. Do not infer landed identity from a branch name.
12. For a cross-repository comparison, read both sides only from recorded landed commits and Git blobs. Require byte identity for role-equivalent CI workflows and common materials after only proved repository-specific substitutions. Treat history, separate authorship, convenience, or lower effort as invalid reasons for a difference.
13. If a binary or behavior differs and the repository-specific justification is uncertain, stop and escalate to the human operator. Do not classify the difference as intentional only to continue.
14. Confirm that no unfinished reviewer finding, stale review, invalid deferral, false dependency, fabricated value, unauthorized repository-setting change, unsupported routing assertion, or invalid receipt remains in the task frontier.

If every applicable clause passes, write an immutable task-completion receipt, update the compact tracker once, and advance only to the next satisfied task. If the task remains incomplete but made valid progress, write a continuation receipt without rerunning unchanged analysis or validation.

## Continuations, retries, and blockers

If an invocation makes measurable valid progress but the task honestly remains incomplete, record a continuation. Continue the same Codex thread only while the executor identity, task-text hash, approved manifest hash, frozen route, pinned repository identities, and accepted artifacts all remain valid. A continuation reuses the same route and does not invoke the advisor. If those continuation conditions fail without a material task or manifest change or verified capability insufficiency, use a fresh sequential replacement executor with the same frozen route. Do not count valid progress as failed validation.

If validation fails:

1. Record exact defects, paths, object identities, commands, and exit codes.
2. Preserve partial work and unrelated user changes.
3. Increment the failed-validation and consecutive-no-progress counts as applicable.
4. Stop or close the old executor before replacement. Never overlap the old and replacement executors.
5. For an ordinary retry, invoke a fresh sequential executor with the unchanged task text, approved manifest hash, routing-decision identifier, and frozen route. Do not invoke the advisor again. Put the defects in a separate `ORCHESTRATOR RETRY CONTEXT` section that does not alter the task or manifest.
6. Revalidate the new executor identity, task and manifest hashes, routing evidence, failed predicates, and all receipts invalidated by the retry. Reuse unchanged receipts. Run the full task-closure tier only when the retry again claims completion or changes an input covered by that tier.

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

The orchestration run is complete only when every numbered task passes its exact `Complete when` condition and has a valid applicable routing receipt or bypass receipt; every advisor invocation has a valid activation receipt; task-text and approved manifest hashes match; the expected executor identity, or expected absence of an executor for bypassed work, is proved; no-overlap evidence matches the routing receipt; override support and acceptance status are recorded for coding work; effective-verification status is honest; and every reroute chain is complete and append-only.

Run one comprehensive overall-completion audit. Stream-hash the current plan and prompt, validate the complete plan index and numbering proof, and audit every task-status entry, completion receipt, routing or bypass receipt, durable-catalog root/predecessor/supersession closure, dependency edge, receipt hash, and invalidation key. Reuse an immutable validation result when its complete input identity is unchanged; the audit verifies that reuse and does not rerun every historical command only to reproduce the same receipt. Perform fresh live reads for final conditions that are mutable or explicitly require freshness, including applicable repository refs, fixed-point identities, open findings, required checks, reviews, review threads, merge or issue state, and repository settings. Expand the frontier and rerun the affected tier if a live identity changed. Completion requires both repositories at the recorded fixed point, all task hashes matched to the active plan, no invalid or missing receipt or broken catalog link, no blocker or placeholder, and a valid compact tracker marked complete.

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
