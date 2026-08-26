<!-- markdownlint-disable-file MD013 -->

# Revised performance plan for the coding-agent loop

Date: 2026-08-25

Status: The Very High and High implementation, including the durable-receipt remediation and deterministic controller migration, is complete. The remaining performance proof is a representative live cycle; results below distinguish static proof from elapsed-time proof.

## Finding validation

The performance finding is valid and material.

The current loop has a four-hour-scale cycle even when the public mutations are small and succeed on the first attempt. The measured local inputs explain much of the delay:

| Input or behavior | Current evidence | Performance implication |
| --- | ---: | --- |
| Orchestration prompt | 67,879 bytes; 476 physical lines | The parent reloads a large control prompt after context recovery. |
| Action plan | 3,216,486 bytes; 392 task headings | The startup procedure reads and parses the complete plan on every startup, resume, and compaction. |
| Mutable tracker | 19,710,156 bytes | The tracker is larger than both control documents combined. |
| Recursive tracker content | 15 `tracker_snapshot` keys | Each snapshot can carry old state into a new LLM input and cause superlinear input growth. |
| Completed-task validation | Every completed task is revalidated before it is skipped | Resume cost grows with total completed history instead of current mutable scope. |
| Dispatch validation | Broad GitHub state is re-queried before each continuation | Unchanged remote state is repeatedly transferred and judged. |
| Publication control | Separate proposal, gate, mutation subgroup, readback, audit, and next gate | Safe serial writes acquire repeated LLM and parent round trips. |
| Claude check suite | Suite status `queued`; zero direct check runs; no evidence of Claude execution | The precise state is nonterminal zero-run. It is not passed, failed, completed, or proof of execution. |

The dominant bottleneck is orchestration amplification. The loop repeatedly exposes old state to the model, repeats deterministic work in model turns, and validates immutable history as if it were mutable. Local three-sample measurements showed cached plan reads of 1.5 through 2.0 ms after a 112.8 ms first sample, plan hashes of 3.7 through 24.0 ms, tracker reads of 39.9 through 86.6 ms, and tracker JSON parses of 654.8 through 692.6 ms. Raw file I/O and JSON parsing do not explain four hours. Model-context ingestion, repeated judgment, broad remote reads, and gate round trips are the material costs. The checkout also has 654 untracked files with 27,978,851 total bytes, so routine status reports must use counts and hashes instead of injecting the complete path inventory.

GitHub's API write guidance requires serial writes and recommends at least one second between many mutative requests. That guidance does not explain multi-hour elapsed time.

No current evidence supports a new CI timeout as a speed mechanism. GitHub defines `timeout-minutes` as the maximum runtime before GitHub kills a step or cancels a job. GitHub defines concurrency as a control for overlapping runs. Those controls can contain resource use or cancel obsolete work. They do not reduce the critical path inside one local Codex orchestration cycle.

## Complete option set

The design space has ten independent axes. The choices on each axis are exhaustive for this finding.

| Axis | Choices |
| --- | --- |
| Time policy | No target; non-blocking objective and diagnostic checkpoint; prompt hard abort; GitHub Actions hard timeout |
| Overlap policy | Allow all runs; serialize runs; cancel stale overlapping runs; queue overlapping runs |
| Tracker state | Full mutable history; compact mutable index; compact index plus immutable content-addressed receipts |
| Plan loading | Read and parse the full plan every time; compile once and load a hash-keyed task slice |
| Validation | Full-history validation; mutable-frontier validation; tiered validation with reusable receipts |
| External state | Unconditional polling; conditional reads; event-driven wake-up with conditional-read fallback |
| Publication | Gate every mutation subgroup; approve one ordered transaction and use targeted readbacks plus one postflight |
| Mechanical work | Use model turns; use deterministic controller code; use controller code with model adjudication only for judgment |
| Model execution | Fixed high-capability route; task-shaped routing; optional Fast mode; bounded read-only parallelism |
| Check-suite semantics | Binary success/non-success; explicit `SUCCESS`, `FAILURE`, `PENDING_WITH_RUNS`, `NONTERMINAL_ZERO_RUN`, `NOT_CONFIGURED`, and `NOT_APPLICABLE` states |

The following options include every atomic approach and the useful cross-axis permutations. Arbitrary combinations that add a hard termination control without changing state, validation, or publication are represented by O19. Other combinations are component-wise subsets of O18 or O20 and cannot exceed those bundles unless an omitted component has negative value.

| ID | Option |
| --- | --- |
| O0 | Keep the current process. |
| O1 | Use a faster model mode or a cheaper/faster model only. |
| O2 | Add a hard 15-minute or 30-minute GitHub Actions timeout. |
| O3 | Add a hard prompt-level wall-clock abort. |
| O4 | Add GitHub Actions concurrency cancellation only. |
| O5 | Add non-blocking 15-minute and 30-minute objectives plus overrun telemetry. |
| O6 | Replace recursive tracker state with a compact index and immutable receipts. |
| O7 | Compile and cache a plan index keyed by the plan hash. |
| O8 | Validate only the mutable frontier and evidence with changed invalidation keys. |
| O9 | Use one approved publication transaction with serial writes, targeted readbacks, and one aggregate postflight. |
| O10 | Move hashing, extraction, schema checks, comparisons, and state transitions to deterministic code. |
| O11 | Remove duplicate instructions and large illustrative schemas from the hot prompt. |
| O12 | Permit bounded parallel execution for independent read-only work. Keep one writer. |
| O13 | Use event-driven external waits with conditional-read fallback. |
| O14 | Select the minimum capable model and reasoning effort for each task shape. |
| O15 | Use explicit terminal states for optional or absent check suites. |
| O16 | Combine O6, O7, O8, and O10 as a state fast path. |
| O17 | Combine O9, O13, and O15 as a publication and wait fast path. |
| O18 | Use the integrated fast path: O5 through O11 and O13 through O15. Stage implementation by priority. |
| O19 | Add hard CI timeouts to O18. |
| O20 | Add bounded read-only parallelism and optional Fast mode to O18. |

## Finding-specific evaluation rubric

Score each criterion from 0 through 5. A score of 0 is harmful or provides no benefit. A score of 5 is excellent. Multiply each score by its weight, divide the sum by 5, and report a result from 0 through 100.

This rubric applies only to the long-cycle finding. It gives low weight to churn and implementation effort. It gives high weight to correctness and measured critical-path reduction.

| Code | Criterion | Weight | Detailed test |
| --- | --- | ---: | --- |
| S | Safety and correctness preservation | 24 | Preserve authorization, one-writer control, exact identities, failure truth, review coverage, and security boundaries. |
| L | Critical-path latency reduction | 24 | Remove work from the measured serial path. Do not only hide, defer, or terminate the work. |
| R | Retry-amplification resistance | 12 | Avoid restart loops, duplicated writes, repeated context reconstruction, and retry thrash. |
| D | Deterministic resume and auditability | 12 | Permit exact reconstruction from hashes, input identities, and durable evidence. |
| A | Applicability to measured costs | 10 | Address the large plan, recursive tracker, broad revalidation, or fragmented publication shown in this run. |
| E | Primary-source support and evidence confidence | 8 | Align with official OpenAI or GitHub guidance and local measurements. |
| I | Implementability and reversibility | 5 | Permit staged rollout, rollback, and focused verification. |
| M | Maintenance burden | 3 | Avoid a new service, workflow, or policy that needs continuing care. |
| O | Original-scope fit | 2 | Improve the coding-agent loop without changing unrelated repository behavior. |

## Option scoring

The criterion-score column is `S/L/R/D/A/E/I/M/O`. Each component is from 0 through 5.

| ID | Criterion scores | Weighted score | Result |
| --- | --- | ---: | --- |
| O0 | 5/0/1/4/0/0/5/4/5 | 45.4 | Reject. It preserves correctness but preserves the bottleneck. |
| O1 | 4/2/2/4/2/4/5/4/4 | 62.6 | Defer as an optional accelerator. It cannot remove orchestration amplification. |
| O2 | 2/1/0/2/0/2/4/3/2 | 29.0 | Reject. It cancels work and can increase retry cost. |
| O3 | 2/1/0/3/1/1/4/3/3 | 32.2 | Reject. It creates partial-cycle restarts. |
| O4 | 3/1/2/3/1/3/4/3/2 | 44.6 | Use only if stale overlapping CI runs are measured. |
| O5 | 5/2/4/4/2/4/5/4/5 | 72.6 | Keep as a measurement policy, not a hard gate. |
| O6 | 4/5/5/4/5/4/4/4/5 | 89.6 | Adopt. |
| O7 | 4/5/5/4/5/4/3/4/5 | 88.6 | Adopt. |
| O8 | 4/5/5/4/5/4/3/3/5 | 88.0 | Adopt with explicit invalidation keys. |
| O9 | 4/5/4/4/5/5/3/4/5 | 87.8 | Adopt with stop-on-drift behavior. |
| O10 | 5/4/5/5/5/5/4/4/5 | 93.6 | Adopt. This is the best atomic option. |
| O11 | 4/3/4/4/3/5/3/4/5 | 74.2 | Stage after the state fast path. |
| O12 | 3/3/3/3/2/5/3/3/4 | 61.6 | Defer until serial-path measurements remain high. |
| O13 | 5/4/5/4/4/5/3/4/5 | 88.2 | Adopt. |
| O14 | 4/3/4/4/3/5/4/4/5 | 75.2 | Adopt where routing is not fixed by higher-priority requirements. |
| O15 | 5/2/5/5/3/4/5/5/5 | 80.0 | Adopt to prevent false waits and false success. |
| O16 | 5/5/5/5/5/4/3/3/5 | 95.2 | Strong bundle. It does not optimize publication or external waits. |
| O17 | 5/4/5/5/3/5/3/4/5 | 88.6 | Strong bundle for publication-heavy tasks. |
| O18 | 5/5/5/5/5/5/2/3/5 | **95.8** | **Select. It covers the complete measured critical path.** |
| O19 | 3/4/2/4/5/3/2/2/3 | 67.2 | Reject the CI addition. O18 supplies the useful work. |
| O20 | 4/5/4/4/5/5/2/2/4 | 85.2 | Defer the parallel and Fast-mode additions until O18 is measured. |

## Selected option

Select O18. Implement O18 in priority order.

Use these controlled instructions:

1. Create one compact tracker. Keep only current mutable state and a durable metadata-only receipt catalog in the tracker.
2. Store detailed evidence in immutable receipt files. Address every task root, predecessor, and supersession edge through the durable catalog by ID, path, byte count, and SHA-256.
3. Do not embed a tracker snapshot, prompt, task body, tool output, or receipt body in the tracker.
4. Compile the plan when the plan hash changes. Store the task offsets, task hashes, dependency data, and required task fields in a deterministic index.
5. On an unchanged resume, read the compact tracker and the indexed current-task slice. Do not load all completed task text into the model context.
6. Define invalidation keys for each validation receipt. Reuse the receipt only when every key is unchanged. At startup, mechanically validate catalog closure from every routing/bypass and completion root; invalidate missing, mismatched, malformed, or broken links and their dependents.
7. Validate the mutable frontier. The mutable frontier contains the current task, its active dependencies, affected Git or GitHub objects, and completed tasks with changed invalidation keys.
8. Use deterministic code for hashes, parsing, schema checks, pagination shaping, comparisons, counters, and state transitions. Use model judgment only for ambiguous findings, design choices, and evidence adjudication.
9. Use tiered validation. Run cheap structural checks after each state change. Run task-scope checks at a task boundary. Run publication checks at the publication boundary. Run the full audit at final completion or after a control-input change.
10. Create one complete publication proposal. Include the ordered mutations, exact targets, preimages, postimages, and hashes.
11. Approve the complete publication proposal once. Execute GitHub mutations in serial order. Read back only the changed target after each mutation. Stop on drift or mismatch. Run one aggregate postflight after the final mutation.
12. Enter `WAITING_EXTERNAL` when a required external event is pending. Save compact state and end the active cycle. Resume on the relevant event or an explicit continuation. Use a conditional read when event delivery is unavailable.
13. Distinguish `SUCCESS`, `FAILURE`, `PENDING_WITH_RUNS`, `NONTERMINAL_ZERO_RUN`, `NOT_CONFIGURED`, and `NOT_APPLICABLE`. A queued suite with zero runs is `NONTERMINAL_ZERO_RUN`. Set `passed=false`, `failed=false`, and `execution_count=0`. Do not infer execution from suite existence. Do not infer `NOT_CONFIGURED` or `NOT_APPLICABLE` from zero runs alone.
14. Select the minimum capable model and reasoning effort when no higher-priority exact route exists. Keep high-reasoning adjudication when risk requires it. Use deterministic code for the approved mechanical publication phase instead of changing the frozen route mid-task.
15. Keep 15 minutes as the normal active-work objective and 30 minutes as the exceptional active-work objective. Exclude external and human wait time. At a budget breach, finish the current safe receipt boundary, write `PERFORMANCE_BUDGET_EXCEEDED` with one deterministic resume action, and stop the active cycle. A budget breach is not a task failure. Never interrupt a public mutation.

This option preserves one writer and serial public mutations. This option reduces repeated input, repeated requests, and repeated validation. This option does not add a CI workflow.

## Prioritization rubric

Score each recommendation from 0 through 5 for each criterion. Multiply by the weight, divide the sum by 5, and report a result from 0 through 100.

| Code | Criterion | Weight | Detailed test |
| --- | --- | ---: | --- |
| C | Expected critical-path impact | 28 | Estimate direct removal of serial elapsed time in the measured workflow. |
| S | Correctness and security | 22 | Preserve or improve correctness, authorization, evidence integrity, and failure truth. |
| F | Frequency and breadth | 14 | Benefit common tasks and repeated resumes, not only a rare path. |
| E | Evidence confidence | 12 | Use direct local measurement and primary-source support. |
| N | Enabling value | 8 | Enable later optimizations or prevent state growth. |
| T | Time to value | 6 | Deliver useful improvement quickly. |
| R | Reversibility | 4 | Permit safe rollback or fallback. |
| M | Maintenance simplicity | 4 | Minimize operational components and special cases. |
| O | Scope fit | 2 | Stay inside the orchestration-prompt performance objective. |

Use selective category thresholds. The thresholds make the top categories difficult to reach.

| Category | Weighted score |
| --- | ---: |
| Very High | 92.0 through 100 |
| High | 82.0 through 91.9 |
| Medium-High | 70.0 through 81.9 |
| Medium | 58.0 through 69.9 |
| Medium-Low | 46.0 through 57.9 |
| Low | 32.0 through 45.9 |
| Very Low | 0 through 31.9 |

## Prioritization scoring

The criterion-score column is `C/S/F/E/N/T/R/M/O`. Each component is from 0 through 5.

| ID | Recommendation | Criterion scores | Score | Priority |
| --- | --- | --- | ---: | --- |
| R1 | Compact tracker plus immutable receipts | 5/5/5/5/5/4/5/4/5 | 98.0 | Very High |
| R2 | Plan index keyed by the plan hash | 5/5/5/5/5/3/5/4/5 | 96.8 | Very High |
| R3 | Deterministic mechanics | 4/5/5/5/5/4/5/5/5 | 93.2 | Very High |
| R4 | Mutable-frontier invalidation | 5/4/5/4/5/3/4/3/5 | 88.4 | High |
| R5 | Tiered validation receipts | 5/4/5/4/4/3/4/3/5 | 86.8 | High |
| R6 | Consolidated publication transaction | 5/4/4/5/4/4/4/4/5 | 88.4 | High |
| R7 | Event-driven external waits | 4/5/4/5/3/3/5/4/5 | 85.2 | High |
| R8 | Soft 15-minute and 30-minute active-work budgets plus safe pause receipts | 3/5/5/4/3/5/5/5/5 | 83.2 | High |
| R9 | Explicit check-suite states, including nonterminal zero-run | 4/5/4/4/2/5/5/5/5 | 84.4 | High |
| R10 | Phase-aware model use and reasoning effort | 3/4/5/5/3/4/5/4/5 | 79.2 | Medium-High |
| R11 | Lean and deduplicated prompt | 3/4/5/5/3/4/5/4/5 | 79.2 | Medium-High |
| R12 | Bounded read-only parallelism | 3/3/3/5/2/2/4/3/4 | 63.2 | Medium |
| R13 | Optional Fast mode | 1/4/5/5/1/5/5/5/5 | 66.8 | Medium |
| R14 | Cancel stale overlapping CI runs | 1/4/1/5/1/4/5/4/2 | 52.4 | Medium-Low |
| R15 | Prompt-level hard abort | 0/1/3/1/0/5/5/4/2 | 29.2 | Very Low |
| R16 | Hard 15-minute or 30-minute CI timeout | 0/2/2/2/0/4/4/3/1 | 30.0 | Very Low |

## Prioritized recommendations

### Very High — R1: Compact tracker plus immutable receipts

Replace recursive mutable history with a small current-state index. Store detailed evidence once. Reference evidence by identity. Reject recursive `tracker_snapshot` content.

### Very High — R2: Plan index keyed by the plan hash

Parse the 3.2 MB plan only when its hash changes. On resume, load the current task slice and the active dependency closure from the index.

### Very High — R3: Deterministic mechanics

Use controller code for hashes, byte counts, task extraction, schema validation, invalidation checks, state transitions, and comparison tables. Do not use a new model turn for deterministic transformations.

### High — R4: Mutable-frontier invalidation

Attach explicit invalidation keys to reusable evidence. Revalidate changed or mutable objects. Do not revalidate unchanged completed history on each resume.

### High — R5: Tiered validation receipts

Separate structural, task-boundary, publication-boundary, and final-completion validation. Reuse a receipt only when its inputs and validator identity are unchanged.

### High — R6: Consolidated publication transaction

Approve one complete ordered proposal. Keep writes serial. Use immediate targeted readbacks and one final aggregate postflight. Stop on drift.

### High — R7: Event-driven external waits

End the active cycle as `WAITING_EXTERNAL`. Resume for a relevant event or explicit continuation. Use conditional reads instead of repeated full polling when event delivery is unavailable.

### High — R8: Soft active-work budgets and safe pause receipts

Measure active work against the 15-minute normal budget and 30-minute exceptional budget. Exclude external and human wait time. At a breach, finish the current safe receipt boundary, write one deterministic resume action, and stop without marking the task failed. Never interrupt a public mutation.

### High — R9: Explicit check-suite states

Classify a queued suite with zero runs as `NONTERMINAL_ZERO_RUN`. Record `passed=false`, `failed=false`, and `execution_count=0`. Classify an optional absent integration as `NOT_CONFIGURED` or `NOT_APPLICABLE` only when separate configuration evidence proves that state. Do not run Claude unless the plan explicitly requires and authorizes a Claude run.

### Medium-High — R10: Phase-aware model use and reasoning effort

Keep high-reasoning analysis where risk and ambiguity justify it. Use deterministic code for approved publication mechanics. Do not downgrade an entire security-sensitive task only because its final phase is mechanical.

### Medium-High — R11: Lean and deduplicated prompt

Remove redundant explanations and illustrative payloads after the new tracker schema is stable. Preserve all normative safety rules.

### Medium — R12: Bounded read-only parallelism

Consider parallel read-only analysis after the serial fast path is measured. Keep one writer and one task executor. Do not parallelize dependent decisions or public mutations.

### Medium — R13: Optional Fast mode

Let an operator enable Fast mode when lower latency is worth the higher credit use. Do not treat Fast mode as the primary fix.

### Medium-Low — R14: Cancel stale overlapping CI runs

Use concurrency cancellation only if measurements show obsolete overlapping CI runs. This control does not optimize one active local Codex cycle.

### Very Low — R15: Prompt-level hard abort

Do not implement. A hard abort can leave incomplete safe work and force context reconstruction.

### Very Low — R16: Hard CI timeout

Do not implement. The GitHub control cancels a job after a maximum runtime. No primary source or local measurement shows that a new timeout will shorten the internal orchestration path.

## Implementation scope

Implement R1 through R9 in `docs/planning/coding-agent-loop.md`.

Do not add a GitHub Actions workflow. Do not add `timeout-minutes`. Do not add a 15-minute or 30-minute hard abort. Do not resume the separate Task 5 sequence 3 publication while this prompt change is in progress.

The implementation must preserve these invariants:

- One task executor at a time.
- One writer for tracked files and external state.
- Serial GitHub mutations.
- Exact authorization and identity checks before a public mutation.
- Immediate stop on preimage drift, failed mutation, or failed targeted readback.
- Full audit at final completion or after a control-input change.
- Honest distinction between requested and effective model settings.
- No credentials, private state, complete prompts, tool logs, or receipt bodies in the tracker.

## Verification plan

After the prompt edit:

1. Confirm that every Very High and High recommendation has a normative instruction in the prompt.
2. Confirm that no new CI workflow, hard timeout, or hard wall-clock abort exists.
3. Confirm that startup on an unchanged plan uses the index and current-task slice.
4. Confirm that a changed plan hash forces a complete deterministic recompile.
5. Confirm that a changed invalidation key expands the mutable frontier.
6. Confirm that an unchanged immutable receipt is reused without loading its body into model context.
7. Confirm that recursive `tracker_snapshot` content is prohibited and that every completion root and predecessor edge resolves through the durable catalog.
8. Confirm that one publication proposal permits ordered serial writes but stops on the first drift or readback mismatch.
9. Confirm that a queued zero-run Claude suite becomes `NONTERMINAL_ZERO_RUN` with `passed=false`, `failed=false`, and `execution_count=0`. Confirm that suite existence is not reported as Claude execution. Require separate configuration evidence for `NOT_CONFIGURED` or `NOT_APPLICABLE`.
10. Confirm that `WAITING_EXTERNAL` ends the active cycle without repeated polling.
11. Confirm that deterministic mechanical work does not silently change the frozen route or override an exact higher-priority route.
12. Validate the schema-2 controller in an isolated state directory. Confirm that it rejects schema-1 recursive state, uses actual UTF-8 byte bounds in its index, rejects unbounded patch fields, and marks a completed task invalid when an immutable receipt is tampered with.
13. Recompute prompt bytes, lines, and SHA-256. Compare them with the baseline.

## Implementation results

Implemented R1 through R9 in `docs/planning/coding-agent-loop.md` and migrated `TEMP-coding-agent-loop-manager.ps1` to schema 2 without changing `.github`. Schema 1 is not resumable: its 19.7 MB recursive tracker remains preserved as legacy evidence while schema 2 uses an isolated state directory.

| Check | Result |
| --- | --- |
| Required R1-R9 semantics | PASS |
| Preserved executor, authorization, mutation, secret, routing, and final-audit invariants | PASS |
| Removed legacy full-plan/full-history resume requirements | PASS |
| Decision-section order | PASS |
| Priority-prefixed recommendations | 16 of 16 |
| Current plan task numbering | 392 consecutive tasks |
| Representative compact 392-task tracker fixture | 702,735 bytes; JSON round trip PASS; 1,183 durable catalog entries spanning routing, bypass, validation, completion, supersession, mixed status, wait, and retry states; no recursive snapshot |
| Tracker byte-budget headroom | PASS; 345,841 bytes, or 32.98%, remain below the measured 1 MiB budget |
| Existing tracker comparison | 19,710,156 bytes; fixture is 96.43% smaller |
| Isolated schema-2 initialization | PASS; 392 tasks; byte-accurate index with dependency, branch, stop, output, and completion fields; legacy schema-1 tracker unchanged |
| Durable receipt closure | PASS; valid routing-to-validation-to-completion chain accepted; tampered deep validation predecessor invalidated the completion root, Task 1, and dependent frontier on resume |
| Patch and preservation controls | PASS; unknown nested fields rejected; forced schema-1 initialization rejected without changing evidence; forced schema-2 initialization preserved the prior projection by hash |
| Three isolated controller lifecycle samples | PASS; 6.50 through 6.85 seconds total per sample |
| Cold 392-task initialization | 1.41 through 1.58 seconds |
| Unchanged schema-2 resume | 0.856 through 0.921 seconds; cached index bytes and timestamp unchanged |
| Invalid-index deterministic rebuild | 1.516 through 1.539 seconds |
| PowerShell parser and PSScriptAnalyzer | PASS; 0 errors across controller and validation harness |
| Markdown lint | PASS; 0 errors |
| `git diff --check` | PASS |
| `.github` changes | 0 |

The prompt is 75,037 bytes and 397 physical lines. Its SHA-256 is `2b0ab754991c5946fbc16c446b12d61f3cf33c3643faf2aea8d0d7a05d7c148c`. It is 7,158 bytes (10.54%) larger than the 67,879-byte baseline because the durable-catalog closure and explicit byte-budget contract are normative. The representative tracker is still 97.32% smaller than the legacy recursive tracker. R11 retains later prompt deduplication as a Medium-High follow-up.

The schema-2 controller is 42,568 bytes and 771 physical lines with SHA-256 `09b5cc7e505714dbf2f63e4f6cd1a25fe989c02e97f0095074eea50c0288abf3`. The reproducible isolated validation harness is `TEMP-Test-CodingAgentLoopManager.ps1`, 12,173 bytes and 222 physical lines with SHA-256 `b2fa723d8a9665d22d215b7240b5f8af8ba6cd8ec65880138110fc2305a63639`.

The validation used PowerShell in `C:\Users\flesniak\GitHub\PSStyleGuide`. The checks used `markdownlint-cli2`, `git diff --check`, PowerShell parsing and PSScriptAnalyzer, deterministic text assertions, current-plan task-heading parsing, a richer 392-task compact fixture, three isolated schema-2 lifecycle samples, index cache reuse and rebuild, deep receipt-tamper propagation, strict patch rejection, and schema-1/schema-2 preservation tests. No GitHub mutation, workflow run, Claude run, PR-body update, or Task 5 sequence 3 action occurred. The 6.50-through-6.85-second measurement covers the deterministic local controller lifecycle only; it does not measure or prove a full model, GitHub, review, or external-wait orchestration cycle within either active-work budget.

## References

- [OpenAI model guidance](https://developers.openai.com/api/docs/guides/latest-model): use lower reasoning for latency-sensitive work; use high or extra-high when measurement shows a quality gain; use programmatic tool calling for bounded tool-heavy work; compare quality, tokens, latency, and cost.
- [OpenAI latency optimization](https://developers.openai.com/api/docs/guides/latency-optimization): reduce input tokens, reduce requests, parallelize independent work, and do not default to a model when a classical method is sufficient.
- [OpenAI Codex subagents](https://developers.openai.com/codex/subagents): parallel work can help independent read-heavy tasks, but parallel writers create conflict risk.
- [OpenAI Codex speed](https://developers.openai.com/codex/speed): Fast mode is an optional model-speed control and has a credit tradeoff.
- [GitHub REST API best practices](https://docs.github.com/en/rest/using-the-rest-api/best-practices-for-using-the-rest-api): use webhooks, conditional requests, focused responses, serial requests, and spacing for mutative requests.
- [GitHub webhooks](https://docs.github.com/en/webhooks/about-webhooks): webhooks deliver events near real time and avoid repeated API polling.
- [GitHub Actions workflow syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax): `timeout-minutes` kills a step or cancels a job after the configured maximum.
- [GitHub Actions concurrency](https://docs.github.com/en/actions/concepts/workflows-and-actions/concurrency): concurrency controls overlapping pending and in-progress workflow runs.
- [GitHub Actions job execution time](https://docs.github.com/en/actions/how-tos/monitor-workflows/view-job-execution-time): GitHub reports billable execution time for jobs on eligible GitHub-hosted runners.
- [GitHub Actions organization metrics](https://docs.github.com/en/enterprise-cloud@latest/organizations/collaborating-with-groups-in-organizations/viewing-github-actions-metrics-for-your-organization): GitHub reports run time and queue time as separate performance measures.
- [GitHub Checks API guide](https://docs.github.com/en/rest/guides/using-the-rest-api-to-interact-with-checks): a check suite is a collection of check runs; only a completed check has a conclusion; automatic suite creation does not prove that a check run executed.
- [GitHub status checks](https://docs.github.com/en/pull-requests/reference/status-checks): a queued check is nonterminal, and required checks must pass before merge.
