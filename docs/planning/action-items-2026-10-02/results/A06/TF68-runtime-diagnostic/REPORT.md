# TF68 runtime diagnostic: measured result and next-step decision

**Measured bottleneck: repeated real checker dispatch inside the author-finalization fixture.** The complete instruction command passed in778.038s. Author-finalization used563.754s (72.5% of the command). Its common immutable-endpoint dispatcher completed41 invocations in478.280s (61.5% of the command; mean11.665s, range11.112ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Å“12.734s). This boundary includes fresh PowerShell startup, clock-wrapper setup, validator work, output capture and control checks. The diagnostic does **not** identify parsing, Node startup, debugger operation or any other internal mechanism as its cause.

## 1. Measurement, identity and limits

The one released run used published TF H5ec4bdc06431de05e93067b0e52f0dfbb1631392/tree441d84c13f46d94c6a032e828615a10fae8d4c7e, accepted B e21b74fe0b56551008f78f9f2946cd2a0f9c19ce, the existing offline image sha256:8bdc7722fc55e19fd3df48d8fddf4568a75d8792cfc4ee105c8a8173559362f4 and both qualified dependency roots (1914 files). Runtime receipts record PowerShell7.6.3, Node24.18.1, npm11.16.0 and Python3.12.3. No install or network operation ran.

Command: `pwsh -NoLogo -NoProfile -NonInteractive -File .github/workflows/Test-AgentInstructions.ps1 -SelfTest -RequireStagedInputMatch`. Tool session48338, launcher PID40720, instruction PID87. Instruction08:12:55.950582ÃƒÂ¢Ã¢â‚¬Â Ã¢â‚¬â„¢08:25:53.988503 UTC, native0. Container exit0; final host guard08:26:10.721195 UTC. The diagnostic private tree was598d1f6e88dc0506c8c077b16e0b8b63bb6ecaad, explicitly **not acceptance evidence**. Before/after equality covers diagnostic source, raw HEAD/index/config/config.worktree, complete refs, logical index, dependencies and origin. The host source/index/config/refs/dependencies also match. Source/config/index were changed only inside the disposable repository as released; the actual product stayed unchanged.

Instrumentation added timestamp statements to two private copies:374 main SelfTest statements and135 extracted statements/callers. It added no wrapper scope, catch, assertion deletion, clock override or native command. Stripping markers reconstructed both original files exactly. Ordinary checker child invocations did not execute main SelfTest markers. The real `$?` consumer pair stayed uninstrumented. Original assertions, native statuses, source installation proof, clock-anchor/readback/cleanup checks and refusal controls all completed. No full Node suite, generator or aggregate was repeated.

2428 timing events yielded no orphan end. Twelve unmatched begins are expected throws: eight malformed/native/bound/timeout inquiry controls at1405; one changed-identity control at1423; two delayed-clock regression mutants at1887; one missing-status-message mutant at1900 (native exit remains0; the expected limited-status message is replaced). Their surrounding tests and enclosing groups completed successfully. These incomplete local intervals are not treated as successful duration samples. Nested timings are inclusive and overlap; do not sum parent and child rows.

| Original call | Seconds |
| --- | ---: |
| Assert-AgentSetupSelfTest (3313) | 7.126 |
| Assert-StagedInputSelfTest (3315) | 0.061 |
| Assert-ApplicationRuntimeSelfTest (3316) | 0.506 |
| Assert-GitRevisionTextSelfTest (3317) | 11.896 |
| Assert-PublishedBaselineCapacitySelfTest (3318) | 0.383 |
| Assert-DocumentMetadataClassificationSelfTest (3319) | 0.677 |
| Assert-OptionalMetadataSelfTest (3320) | 7.339 |
| Assert-DocumentMetadataPlacementSelfTest (3321) | 3.445 |
| Assert-PublishedMetadataGitFixture (3322) | 0.220 |
| Assert-ClassificationAdmissionGitFixture (3323) | 11.579 |
| Assert-AuthorFinalizationGitFixture (3324) | 563.754 |

The entire extracted script took608.332s. The remaining main-file work, startup and unmarked overhead account for about169.706s. Outside the extracted script, the largest complete main mutation loops were26.341s at10897,20.512s at11593 and17.215s at9664. Completed authoritative FileInquiry calls at1179/1185 were321+321, totaling11.541s; four whole snapshots were14.804s. The snapshots include those calls and must not be added to them. This measurement does not support choosing file-inquiry batching as the primary remedy. Additional author dispatch routes were proposed12calls/26.831s, accepted documented-worktree1call/11.460s, local2calls/24.300s and invalid-mode3calls/1.164s. All these are actual completed boundary times, not estimates of one internal helper.

Existing comparison: the earlier same-tree final aggregate took1351.098s for11 hooks, and its separate600-test Node suite took219.470s. That aggregate is not a paired uninstrumented instruction-only control. Different load/cache conditions and added timing code preclude deriving a speedup or hosted completion guarantee from the difference. One run does not characterize variability or establish margin below a hosted20-minute limit.

Hosted dynamic37430212759 was cancelled for its native20m0s job ceiling. Its log proves the executed checkout was exact H5ec4bdc (07:32:09.2627531), with main setup authority e21 and event checkout H (07:32:13.0866943). The selection source of its old coding YAML remains uncertain; do not confuse that uncertainty with the proven executed source. Ten earlier hooks passed. Its failed setup remains a merge blocker. The local diagnostic does not convert it into a pass, activate the dedicated review workflow or authorize retry.

## 2. Stakeholders and hard constraints

Maintainers and contributors need predictable completion without learning private fixture details. CI/release and remote-agent operators need bounded work, terminal results and actionable failures. Security and policy owners need real accepted-base/candidate authority, unchanged metadata dates, actual native exits and every negative control. QA and independent reviewers need measured causal evidence and mutants that still defeat unsafe behavior. Incident/recovery operators need cleanup that preserves primary failure and does not leave processes or altered Git state. Cost/platform owners need honest runner and billing claims. Both repositories need a common implementation with only genuine language/provenance differences. Documentation readers and accessibility/localization users are not directly affected by this test-runtime decision; public guidance must not be changed to conceal a timeout.

Hard constraints: no skipped tests, suppressed failures, no-failing-CI waiver, shared mutable checkout concurrency, production clock bypass, weakened input bounds, invented source acceptance, new dependency without a separate decision, or reset deadline/counters. Valid future concurrency must preserve case identity, exact arguments, source bytes, native status, clock anchors and cleanup. A high score cannot waive a constraint.

## 3. Options before scoring

The table covers retention/deferral, targeted measurement, two distinct parallel designs, identity-bound reuse, persistent/batched runtimes, private clock alternatives, runspace reuse, lower-value snapshot optimization, hourly retry, larger runners, bootstrap and normal green activation sequences, budgets, coverage removal and speculative production optimization. Combinations must retain their prerequisites: profiling then a measured queue/cache/algorithm repair is B; caching plus batching adds both lifecycle obligations; bootstrap or larger hardware does not excuse current failing CI. Static small-loop micro-optimizations belong to Q until their cost is measured. There is no supported known setting that simply overrides the actual service20-minute ceiling.

| Option | Concrete next action | Main uncertainty or exclusion |
| --- | --- | --- |
| A | Keep code and wait without another diagnostic | Preserves controls but leaves a repeat service failure unexplained. |
| B | Profile one reconstructed immutable author case with an original/timed pair; then select a repair | Best next decision; provides no immediate product-speed guarantee. |
| C | Bounded queue of two independent immutable-case checkouts; mutable cases stay serial | Targets the measured boundary; equivalence and actual CPU/host gain remain unproved. |
| D | Parallelize the existing shared fixture dispatcher | Ineligible: checkout, baseline and checker mutations would race. |
| E | Partition complete author scenarios into independent full fixtures/jobs | Can preserve cases but duplicates costly initialization and complicates coordinated failure handling. |
| F | Add per-invocation exact-identity parser/static-context reuse | Potential benefit; neither repeated internal work nor safe invalidation key is measured yet. |
| G | Use a persistent or batched parser/runtime process | Could amortize startup but creates a protocol, lifecycle and per-input isolation contract. |
| H | Change private clock mechanism to checked source instrumentation | No measured clock bottleneck; revisits C97 exact-source and scope/readback protections. |
| I | Reuse one PowerShell runspace across full checker cases | May leak runtime caches/global/breakpoint/native status; requires proof of fresh-case equivalence. |
| J | Batch file-identity inquiries while retaining every check | Legitimate batching may preserve safety, but only11.54s of completed inquiries was measured; low-value primary target. |
| K | Retry existing hosted setup no more than hourly | Could pass but is not a causal repair or reliable completion claim; current run remains cancelled. |
| L | Configure a larger supported runner | Capacity, cost and actual gain are unqualified; requires the appropriate owner/platform setting authority. |
| M | Bootstrap the dedicated review workflow through a separate normally accepted PR | Its own legacy setup must pass; no failing-CI exception or deadline reset. |
| N | Land normally only after all current CI/reviews are green, then prove dedicated activation | Conditional prior B93.5 sequence; unavailable while current dynamic CI is cancelled. |
| O | Increase repository YAML timeouts again | Does not establish control over the observed service20-minute ceiling; already59/45 coding budgets. |
| P | Skip cases or snapshot checks, accept failed setup, or cache whole pass results across distinct inputs | Ineligible: removes coverage, invents acceptance or bypasses actual changed input validation. |
| Q | Optimize an internal validator algorithm now without attribution | No specific internal algorithm was measured; choose B before such a repair. |

## 4. Unique rubric

Each criterion is scored0ÃƒÂ¢Ã¢â€šÂ¬Ã¢â‚¬Å“10, where0 is unusable/contradictory,5 is plausible with unresolved evidence, and10 is fully supported for the **next action**, not guaranteed final performance. Security/test fidelity30 measures preservation of all actual callers, clock/mutant controls and trust boundaries. Measured-target confidence25 measures how directly an option follows the observed boundary and resolves unknown cause. Reliable completion progress20 measures credible progress toward bounded completion without assuming host capacity or a future green run. Maintainer/operator usability15 measures understandable implementation, failure diagnosis and recovery. Verification precision7 measures ability to isolate correctness/performance and bind exact inputs. Change cost3 measures unnecessary coupled maintenance. Scores are judgments; measured durations above are evidence.

## 5. Scores and selection

| Option | Security and test fidelity 30 | Measured-target confidence 25 | Reliable completion progress 20 | Maintainer/operator usability 15 | Verification precision 7 | Change cost 3 | Total | Key limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A Keep code and wait without another diagnostic | 10 | 3 | 2 | 4 | 5 | 10 | 54.0 | Preserves controls but leaves a repeat service failure unexplained. |
| B Profile one reconstructed immutable author case with an original/timed pair; then select a repair | 10 | 10 | 8 | 9 | 10 | 9 | 94.2 | Best next decision; provides no immediate product-speed guarantee. |
| C Bounded queue of two independent immutable-case checkouts; mutable cases stay serial | 9 | 7 | 7 | 7 | 7 | 5 | 75.4 | Targets the measured boundary; equivalence and actual CPU/host gain remain unproved. |
| D Parallelize the existing shared fixture dispatcher | 1 | 7 | 3 | 2 | 2 | 8 | 33.3 | Ineligible: checkout, baseline and checker mutations would race. |
| E Partition complete author scenarios into independent full fixtures/jobs | 9 | 7 | 6 | 5 | 6 | 3 | 69.1 | Can preserve cases but duplicates costly initialization and complicates coordinated failure handling. |
| F Add per-invocation exact-identity parser/static-context reuse | 8 | 5 | 7 | 7 | 6 | 5 | 66.7 | Potential benefit; neither repeated internal work nor safe invalidation key is measured yet. |
| G Use a persistent or batched parser/runtime process | 7 | 4 | 7 | 5 | 5 | 3 | 56.9 | Could amortize startup but creates a protocol, lifecycle and per-input isolation contract. |
| H Change private clock mechanism to checked source instrumentation | 7 | 3 | 6 | 6 | 5 | 5 | 54.5 | No measured clock bottleneck; revisits C97 exact-source and scope/readback protections. |
| I Reuse one PowerShell runspace across full checker cases | 5 | 5 | 6 | 4 | 4 | 4 | 49.5 | May leak runtime caches/global/breakpoint/native status; requires proof of fresh-case equivalence. |
| J Batch file-identity inquiries while retaining every check | 9 | 2 | 2 | 5 | 5 | 5 | 48.5 | Legitimate batching may preserve safety, but only11.54s of completed inquiries was measured; low-value primary target. |
| K Retry existing hosted setup no more than hourly | 10 | 2 | 3 | 5 | 3 | 9 | 53.3 | Could pass but is not a causal repair or reliable completion claim; current run remains cancelled. |
| L Configure a larger supported runner | 9 | 3 | 5 | 5 | 4 | 3 | 55.7 | Capacity, cost and actual gain are unqualified; requires the appropriate owner/platform setting authority. |
| M Bootstrap the dedicated review workflow through a separate normally accepted PR | 10 | 4 | 4 | 4 | 5 | 3 | 58.4 | Its own legacy setup must pass; no failing-CI exception or deadline reset. |
| N Land normally only after all current CI/reviews are green, then prove dedicated activation | 10 | 6 | 4 | 7 | 7 | 9 | 71.1 | Conditional prior B93.5 sequence; unavailable while current dynamic CI is cancelled. |
| O Increase repository YAML timeouts again | 10 | 1 | 1 | 3 | 2 | 8 | 42.8 | Does not establish control over the observed service20-minute ceiling; already59/45 coding budgets. |
| P Skip cases or snapshot checks, accept failed setup, or cache whole pass results across distinct inputs | 0 | 2 | 0 | 1 | 1 | 8 | 9.6 | Ineligible: removes coverage, invents acceptance or bypasses actual changed input validation. |
| Q Optimize an internal validator algorithm now without attribution | 7 | 2 | 5 | 5 | 3 | 3 | 46.5 | No specific internal algorithm was measured; choose B before such a repair. |

B is the clear next-step winner at94.2. It preserves current product behavior and buys the missing attribution with a bounded short fixture, rather than rerunning the778-second diagnostic. C is a concrete potential fixture-only repair, but is not yet proven equivalent or faster on the target service. F/G/Q may address repeated work inside each checker but lack internal timing. K/M/N retain the conditions of the [existing activation proposal](../TF68-round5-activation/REPORT.md); they are compared only as next actions, not re-decided here. Current CI failure makes green landing unavailable. D/P fail hard constraints, and O does not control the observed service limit. No performance number in this table is a promise of improvement.

## 6. Selected next step and bounded proposal

Select B94.2. Keep the current product bytes. Keep the completed diagnostic evidence. Prepare one original/timed pair for the first successful immutable author case. Limit the new diagnostic to300 seconds. Stop if the control fails or any protected input changes. Send the concrete driver and input catalog to root. Wait for root release before execution. Use the result to select a specific repair. Do not rerun the complete SelfTest.

### Diagnostic specification (not yet released)

1. Keep the completed run and all original bytes. Do not run the full SelfTest again for attribution.
2. Use a fresh disposable offline checkout from the same pinned H/B and dependency catalog. Use the same exact image. Record new source/index/config/ref/dependency baselines and separate diagnostic hashes.
3. Reconstruct the **first successful current-date immutable B/H author-finalization case** from the actual current Assert-AuthorFinalizationGitFixture body through its first call at original1522. Retain its actual installed-source snapshots, modes, dependencies, baseline/candidate construction, current-date clock anchor, native child arguments and output checks. Extract the real functions using checked AST definitions as in the prior focused drivers. Load the real validator functions with the normal no-SelfTest path. This bootstrap ordinary-validator load is a separate measured phase, not one of the maximum two selected-case child invocations. Its time remains inside the total300-second bound. In the private truncated fixture, return immediately after this selected case; retain its existing finally cleanup. This deliberately runs one diagnostic case, not the full acceptance fixture.
4. Capture the reconstructed case's exact B, H, installed checker bytes, arguments, fixture clock, expected exit and expected diagnostic before either measured child. The prior full-run container was removed. Its ephemeral Git objects were not exported as a reusable fixture. This reconstructs the same semantic case; it is not replay of the prior ephemeral commit IDs. Record all new identities and never substitute the production PR H for the fixture H.
5. Run that one case once with exact original checker bytes as a control. Require its original acceptance predicate, actual native0, expected author-finalization message, and successful clock-anchor/readback/cleanup checks. Stop immediately if any control fails.
6. Run the identical captured case once with a separate diagnostic copy of the checker. Add insertion-only monotonic markers at complete real call statements for Markdown parsing/context construction, TOML parsing/runtime resolution, bounded Git/input reads, metadata-context construction and final instruction-contract checks. Use exact AST boundaries and prove marker removal reconstructs the original bytes. Do not put markers between native calls and their status capture or the sole `$?` pair. Do not change parser programs, error handling, return values, input text, metadata or clock anchors. Record whole-child time and unaccounted residual separately; caller intervals remain inclusive. Do not attribute residual to startup or clock registration without direct evidence.
7. Preserve raw control/profile outputs and native exits. Diagnostic stderr markers may be removed only in a separate comparison view, not from raw evidence or the production result. Require the same non-diagnostic success/failure contract and active fixture-clock checks. Guard the diagnostic file differences explicitly; do not call the timed copy exact production source or accepted policy.
8. Limit this new container to300 seconds total, with at most two selected real child invocations. Limit each child to90 seconds. Use process-group cleanup, a unique owned container label and exact image/ID verification. Stop on any identity change, missing anchor/readback, output mismatch, unexpected marker shape, native failure, or timeout. Save both guards even on failure. No install, new dependency, network, CI/review request or product edit is part of this plan.
9. Use the result to select a **specific** repair. If an internal operation dominates, evaluate its smallest correctness-preserving reuse/batching/algorithm change with required failure and freshness controls. If costs are diffuse and independent immutable cases remain the useful target, evaluate C with measured serial/parallel prototypes and complete case-equivalence oracles. Do not start either implementation from this report. If the short measurement does not distinguish causes, report the limit and return to root rather than running another broad experiment.

This proposal defines intent and bounds; the concrete two-case driver, insertion catalog and launcher must be checked by root before execution. No request for a new human permission flow is implied. Root can display/select and release the bounded diagnostic under existing owner authority.

## Conditional queue requirements

The current dispatcher performs checkout on a shared fixture and reads mutable closure variables. The fixture reassigns baseline16 times. Required-date, delayed-clock regression and missing-status-message controls deliberately write different live checker bytes. Local/staged, accepted-base worktree, proposed H/wrong-checkout and invalid-mode scenarios depend on current mutable state. Therefore blindly parallelizing scriptblockCheck or storing only B/H loses controls.

A viable C prototype must build fixtures/commits serially; capture each case's exact B/H, original checker identity, clock, arguments and expected result; use independent writable checkouts for at most two eligible immutable children; keep all mutable/worktree/staged/proposed/checker-mutant cases serial; retain current exact-source installation and path/mode/refusal checks; bound output, time and cleanup for each child; surface every failure with its case identity; and preserve evidence for all cases when a sibling fails. Dependencies may be shared only under an explicit immutable-byte guard, with no writable shared cache introduced. Measure real wall time and resource contention; halving478s is an unproved upper-bound intuition, not a supported prediction.

## 7. Evidence, remaining gates and paired scope

EVIDENCE.json binds the release, authorized manifest, prepared scripts, original/instrumented identities, source/dependency catalogs, continuous log, complete timing table, commands, terminal native results and both final guards. No source, index, ref, configuration, dependency, planning, native review or counter was changed by this worker. The selected next action is a scratch diagnostic, so no peer transfer starts. A later common SelfTest/runtime repair may affect A21 and A03; root must determine exact paired scope and increment applicable counters before destination implementation. Original deadline and counters remain unchanged.

The service cancellation, ordinary CI status, both current-input reviews, dedicated setup activation, A06/A03/A21/A07 completion and final source/peer acceptance remain root-owned gates. This local timing result closes none of those gates. The exact-source repository and saved hosted logs are primary evidence; no undocumented hosted ceiling override or new billing claim is used.

Terminology correction before packet freeze: line1900 is a missing-status-message control, not a child-exit mutation. The original static caller audit is retained separately; its concrete source lines were correct. This correction changes no timing, status, guard, score or selection.
