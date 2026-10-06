<!-- markdownlint-disable MD013 -->
# TF68-R1: make synthetic metadata time deterministic

Status: coordinator displayed all options, the rubric and scores; selected C97 and released the one-file implementation on2026-10-06. Validation and delivery remain pending. This is one finding for both hosted failures. It belongs to A21 and affects both repositories. The original round1 deadline2026-10-13T23:47:31Z and A06/A03/A21 transfer counts1/3/5 remain unchanged.

## 1. Validate the failure

TF68 H`6c0c987799425b60c0e7b76650aa5ec7946811e2` contains the unchanged accepted-TF SelfTest blob `7275b050ca3067706d646412a7f751138073e5bb`. Accepted PS`98177628b7bc02c646724bfc8aa0fd73fed0cd24` has SelfTest blob `9918aaae6d0658c0e9ab4d8bf16de9716d52ac87`. The sole PS/TF SelfTest difference is the P1 versus T1 provenance fixture path. The actual validator is identical in PS, TF base and TF68: blob `7ee712e048ab512aa751cf77c530d985d458bf7f`. Both files have mode100644. Thus this is a common pre-existing self-test defect, not a generator-port defect.

Two real executions crossed UTC midnight:

- PR behavior run37390495694 attempt1 started the behavior step at2026-10-05T23:47:53Z. At2026-10-06T00:01:12Z it failed SelfTest1163: `Now=True Later=False Accept=True exit=1`, with `STYLE_GUIDE.md Last Updated must be 2026-10-06 after a rendered-content change.` The versioned current-date case at1643 is consistent with that diagnostic; the log does not record the individual call site or fixture capture timestamp.
- Copilot run37390664560 attempt1 failed its actual `agent-instruction-contract` hook at2026-10-06T00:02:39Z. The same dispatcher rejected `docs/café.md` because Last Updated must be2026-10-06 after the current event changes rendered content. The Unicode positive case at1604 selects the same current-clock route. This is duplicate evidence for the same defect. Copilot's separate actual Balanced review5422208600 reported no findings; that review does not turn its setup failure into a pass.

The source proves the cause. `Assert-AuthorFinalizationGitFixture` captures `[DateTimeOffset]::UtcNow` once at936. It derives current, prior, baseline and future fixture dates from that timestamp. `$scriptblockCheck` at1145–1165 pins the child clock only when `Later=True`. For `Later=False`, the real child validator captures a new UTC timestamp at62–64. If those reads fall on opposite sides of midnight, valid synthetic current-date documents become stale. The validator correctly rejects the synthetic input according to its own clock; the fixture's acceptance expectation is wrong. Retrying on another day can conceal the defect but cannot repair it.

### Complete relevant clock/caller inventory

| Boundary | Current behavior and required treatment |
| --- | --- |
| SelfTest936 | The sole direct wall-clock read in SelfTest. Keep one fixture anchor for its related scenario dates. |
| Validator62–64 | Captures timestamp, metadata date and timestamp bound. Every date-sensitive synthetic child must use the intended fixture anchor; later checks use anchor+1day. |
| Validator2110 | `Get-PublishedBaselineDocumentContext` independently reads real UTC for a changed local path. Startup clock pinning alone does not pin this local expected date. |
| SelfTest1145–1165 | Common finalization/current/delayed dispatcher; ordinary, stale, malformed, Unicode, promotion, optional-header, version and mutation cases use it. Current children are unpinned today. |
| SelfTest1333–1337 | Direct accepted-base worktree child using `-File`; bypasses the existing shim. Retain its actual B checkout and B/H/finalization semantics under the shared private clock dispatcher. |
| SelfTest1651–1653 | Direct local staged-input child; needs both captured metadata date and local expected-date pinning. Preserve current acceptance and stale rejection. |
| SelfTest1166–1181 | Proposed-policy child dispatcher; use the same private clock context so upper-bound/date behavior stays consistent. Preserve all forbidden-mode and unauthorized-transition cases. |
| SelfTest1661 | Invalid-mode direct child. Keep the actual invalid-mode failures. Route through the same private launcher where needed without weakening the flag checks. |
| SelfTest2343–2346 | An in-process capacity fixture compares the real local-parent expected date with the already passed `MaximumMetadataUtcDate`. Pin that one local date read for this fixture scope and remove the breakpoint afterward. Otherwise this independent boundary can also cross midnight. |

All other SelfTest date arithmetic uses explicit captured/passed dates. No additional direct `UtcNow`, `Now`, `Today` or `Get-Date` read exists there. No broad clock, guide or workflow redesign follows from this inventory. The validator's production local-path clock behavior is unchanged by the proposed test repair. This finding does not establish a production false acceptance.

Materiality: this defect is private test infrastructure, so the ordinary decision policy permits a five-line fixture note when production behavior and guide text do not change. The coordinator explicitly requested the full process for the tracked A21 self-test; this record follows that instruction. The useful improvement is reliable meaningful admission around midnight, not paperwork or a green-only retry.

## 2. Stakeholders

- Both maintainers and contributors need valid changes to pass regardless of run start time. A new contributor must not repair a synthetic date by editing real guide metadata.
- CI operators and remote/local agent operators need bounded, attributable failures rather than a scheduling restriction or repeated expensive runs.
- Security reviewers and policy maintainers need the production clock, strict current/future-date rules, exact-source installation proof, forbidden-mode checks and negative tests preserved.
- Test authors, independent quality reviewers and future maintainers need one visible fixture clock, uniquely checked instrumentation anchors and meaningful regression mutants.
- Artifact and documentation consumers need no change to guide content, generated bytes or publication admission. PS and TF users need the common repair with the existing provenance-path exception retained.
- Cost/schedule owners need to avoid repeating a full suite to get lucky. History/audit readers need both failed executions retained and separate from the clean review.

No cloud operator, privacy owner or end-user accessibility workflow changes are proposed: the repair processes only local synthetic metadata and existing validator code, with no new runtime, external data, permissions or UI. Their relevant safety and clarity interests are represented above.

## 3. Options before scoring

| Option | Mechanism and principal trade-off |
| --- | --- |
| N | No change; retry the failed job. Preserves code but leaves a proved timing defect and repeated CI cost. |
| R | Remove/skip strict current-date positives or loosen their expected failures. Avoids the symptom by losing the contract oracle. |
| W | Run only in a chosen UTC time window or wait until midnight passes. Keeps assertions but creates operational coupling and still cannot bound a long run. |
| D | Detect an actual date rollover and reconstruct the entire related fixture once with fresh dates; fail after the finite retry. Preserves production bytes but repeats many mutations, complicates cleanup/error attribution and remains timing-dependent. A retry without rebuilding fixtures collapses into N. |
| P | Add a production clock parameter or environment override, then pass a fixed test time. Easy to test but adds a policy bypass/interface to the shipping validator. |
| I | Rewrite the two clock expressions in a copied fixture validator before testing. Deterministic and keeps literal `-File` launch, but the installed test code is no longer the exact validator under review; every mutant/restoration must preserve the instrumentation. |
| S | Extend only the existing `Later` shim to current `$scriptblockCheck` calls. Small but leaves the documented, local, in-process capacity and proposed callers inconsistent. |
| C | Reuse debugger instrumentation only inside the self-test. Pin both relevant date boundaries, consolidate date-sensitive private child dispatch, check anchors and firing, and scope the one in-process local-context probe. Preserve exact installed validator bytes and all current/delayed/refusal cases. More fixture code than S, but no public clock surface or runtime dependency. |

Factoring a generic production clock framework collapses into P and exceeds the supported need. Combining a repaired deterministic fixture with ordinary CI execution is C; adding routine retries or time windows supplies no extra correctness. Deferral is N with an issue and leaves the actual failed gate unresolved. A test-only debugger mechanism already exists for delayed cases, so C reuses a present capability.

## 4. Finding-specific rubric

Scores0–5:0 absent/harmful;1 major unresolved weakness;2 incomplete;3 adequate with a material limitation;4 strong with a bounded drawback;5 fully meets the criterion on current evidence. Total is `sum(weight × score) / 5`. Scores compare engineering judgment, not empirical reliability percentages.

| Criterion | Weight | Meaning for this finding |
| --- | ---: | --- |
| Correctness across all actual callers | 30 | Repairs the demonstrated current-date defect and both relevant clock reads without hiding a different failure. |
| Exact-source and trust preservation | 25 | Keeps production validator bytes/API and security semantics unchanged; preserves installed-source, B/H and ownership evidence. |
| Midnight determinism | 20 | Results do not depend on host day rollover, scheduling luck or retries. Instrumentation failure must be visible. |
| Existing negative-oracle fidelity | 15 | Retains stale, future, calendar, local, proposed, delayed and mutation refusals with meaningful expected results. |
| Contributor/operator usability | 5 | No scheduling rule, manual metadata adjustment or repeated full job to obtain a result. |
| Maintenance and implementation cost | 5 | Bounded fixture code, clear diagnostics, no new framework or dependency. |

Hard constraints: no production clock parameter/environment bypass; no weakened production date policy; no test skip relabeled pass; no global host clock change; preserve exact installed validator/source identity; preserve the stated negative consumers and native failure checks; stop before product edits until the coordinator selects/releases scope. A score cannot waive these constraints.

## 5. Scores and uncertainty

| Option | Correctness30 | Trust25 | Determinism20 | Oracles15 | Usability5 | Maintenance5 | Total | Eligibility/uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 2 | 5 | 0 | 3 | 1 | 5 | 52 | Leaves the genuine failure unresolved. |
| R | 1 | 4 | 5 | 0 | 2 | 4 | 52 | Fails negative-oracle constraint. |
| W | 2 | 5 | 1 | 4 | 1 | 2 | 56 | Cannot guarantee a run stays in its window. |
| D | 4 | 5 | 3 | 5 | 2 | 2 | 80 | Viable bounded fallback, but timing and fixture reconstruction remain. |
| P | 5 | 1 | 5 | 5 | 4 | 3 | 77 | Fails production clock/API constraint. |
| I | 4 | 2 | 5 | 4 | 4 | 3 | 73 | Fails exact installed-source constraint. |
| S | 3 | 5 | 2 | 4 | 3 | 4 | 70 | Does not cover the actual caller inventory. |
| C | 5 | 5 | 5 | 5 | 4 | 3 | **97** | Unique winner; scoped breakpoint behavior and fail-closed anchors require the focused tests below. |

C: `(150+125+100+75+20+15)/5=97`. D is the credible fallback if C cannot preserve the real caller contract or fails platform proof. Do not silently fall back to a partial shim or retry-only success.

## 6. Selected proposal: C97

1. Change only the A21-owned `Test-AgentInstructions.SelfTest.ps1` after release. Use the actual Oct6 date in metadata for the code that changes. Do not edit a guide or production validator.
2. Keep one UTC fixture anchor. Derive all related current, prior, future and delayed dates from that anchor.
3. Add one private fixture clock mechanism. Reuse the existing debugger approach. Locate the captured-clock initialization and the local expected-date assignment in the exact checker being executed. Require one supported match for each applicable anchor. Fail if a required anchor is missing, duplicated or moved to an unsupported construct.
4. Set the intended captured timestamp/date/bound immediately after initialization. Use the anchor for current scenarios. Use anchor+1day for delayed scenarios. Pin the changed-local-path expected date to the same selected calendar date after its real calculation. Preserve the empty expected date when the path has no worktree change.
5. For the local variable, update the caller's variable scope explicitly. A plain assignment in a breakpoint action does not update the function local. Require a firing/readback check so ineffective instrumentation cannot produce a misleading result.
6. Route the date-sensitive child cases through the private mechanism. Preserve the actual checker file, accepted worktree location, B/H arguments, mode parameters, output and native exit. The documented worktree case must still execute the real accepted-B checker against H; it must not become a stub. A `-Command` wrapper may establish breakpoints before invoking the real `.ps1`; record this launch-level distinction from the original literal `-File` invocation.
7. Pin only the local expected-date read around the in-process capacity fixture call using its passed `MaximumMetadataUtcDate`. Remove its breakpoint in `finally`. Restore all scoped test state after success or failure. Do not affect a later ordinary validator invocation.
8. Keep the exact installed-validator snapshot, source guard and existing mutation payloads. Do not rewrite copied checker code to freeze time. Preserve all semantic negative cases and the one PS/TF provenance-path difference.
9. Add bounded regression controls for the missing clock paths and drifted anchors. Run the focused checks below before a new aggregate. Stop on a new material finding and update this decision.

These are short controlled-English implementation instructions. No formal ASD-STE100 dictionary certification is claimed. The proposal creates no operational permission or authority to bypass failed CI.

## 7. Evidence, meaningful verification and implementation boundary

Executed evidence is the two actual hosted failures plus immutable code/caller inspection. A small private PowerShell7.6.5 mechanism probe used the same startup clock expressions and local-date calculation. Pinning script values worked. Plain assignment inside the local-date breakpoint left the function's real date unchanged; `Set-Variable -Scope 1` updated the function local to the fixture date. This proves the scope hazard and a feasible mechanism in that bounded probe; it is not a full checker, Linux or end-to-end passing repair. The probe is saved beside the evidence; no product bytes changed.

Five-line fixture-probe note: the first local-action prototype left Local=2026-10-06 while Captured=2026-10-05; a debugger action has its own assignment scope. The scratch-only correction used explicit caller scope. The next probe returned both dates2026-10-05. No production implementation or acceptance is inferred.

After release, require these targeted results:

- Reproduce the original caller failure deterministically by forcing fixture dayD and an unpinned real child dayD+1 through private instrumentation; do not wait for midnight or change the host clock. Confirm the genuine metadata-date diagnostic and nonzero native exit on original bytes.
- Execute the repaired actual finalization fixture with the same day boundary. Current-date B/H, versioned-guide and Unicode cases must pass. Stale current-finalization, future/calendar and invalid-mode controls must still fail for their intended reasons. Delayed ordinary checks must still accept valid earlier metadata and reject the existing delayed-policy mutants.
- Exercise the accepted-base worktree caller, actual local staged current/stale cases and the in-process local-parent capacity case. Prove both real clock reads are controlled. Include an unchanged local path to prove the empty-date branch remains empty.
- Mutation-test omission of the current child pin, omission/incorrect scope of the local-date pin, and bypass of the documented-worktree dispatcher. Each must be detected by its independent boundary control. Missing/duplicate clock anchors must fail before a child result is accepted.
- Keep proposed-policy mode/authority negatives and the existing exact installed-source/mode/identity guards. Verify breakpoint cleanup after both success and exception, then run an ordinary uninstrumented validator invocation and confirm it still uses actual current UTC.
- Parse/analyze the changed SelfTest; run the affected actual fixture on qualified Windows7 and Linux7. Run the current full self-test and normal aggregate on final bytes once. Use fresh exact-head CI and review under the existing clock/round after old requests are terminal. Hosted failure history remains intact.

The original25-row A06 comparison remains correct for its original input. This newly confirmed A21 finding adds SelfTest to future scope and creates a real reverse PS repair obligation after the TF fix is accepted. Preserve the P1/T1 provenance exception during that transfer. Root owns the exact scope release, counters, index/ref/config/native operations, planning, aggregate, reviews and final paired binding. No retry or new reviewer request was issued by this worker.

## Current metadata and private-driver qualification

Actual accepted-B/whole-PR author finalization on2026-10-06 rejects only the existing scripts-README Last Updated date; logSHA77d6e04e records that result. Apply the existing current-date/D07 policy with one date-field refresh after the active Windows source guard; retain the selected C97 code and README body.
The earlier unexecuted proposal to finalize only against the prior topic head is withdrawn. Finalization must use acceptedB and the new whole-PR head. The final aggregate must include both changed paths.
The private Windows AST driver retains a mixed-slash filename that its capacity breakpoint cannot match; the same capacity plus cleanup passes with a native path. Real production -File canonicalizes the filename. Preserve each native exit and use explicitly composed focused coverage only after the actual author fixture finishes.
Focused Linux/Windows code evidence precedes the README refresh and keeps that scope. Do not relabel it as a final79-file aggregate result. Final committed, hosted and independent binding remain required.
