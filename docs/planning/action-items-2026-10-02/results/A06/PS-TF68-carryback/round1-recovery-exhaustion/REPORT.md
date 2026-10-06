<!-- markdownlint-disable MD013 -->
# PS235: exhausted recovery decision

**Select P95.0: complete the provider inquiry and conditional measurement specification, retain the CI hold, and let the existing R2/R3 owner finish the genuine finding decisions.** This is a proposal for root selection. It does not release a request, diagnostic or product edit. The selected preparation is complete in this directory; no additional owner approval is needed to prepare it or to continue already-authorized finding work.

## 1. Validate the present problem

Current input is PS235 H `504cd7672ac9604ace765a4f451346f801f09ddd`, tree `a716a1f8ff7e4f385e089b0f056adbcde9c973cb`, accepted B `98177628b7bc02c646724bfc8aa0fd73fed0cd24`, body SHA256 `ccfa3c9a42f3989afcc59c13f4ea8d15844c54a45b162dd0b73b389ff148a641`. Saved authenticated terminal records, raw job/annotation/log files and the fourteen ordinary successful runs were cross-checked. Relevant current source hashes match the recorded committed postimages. This was a local evidence read, not a fresh native-state query or repeated product-quality review.

| Channel | Actual outcome |
| --- | --- |
| Original Balanced UI request, dynamic run 37524396256 attempt 1 | Cancelled at the 20-minute service limit. |
| Documented Actions rerun at 21:10:39.477709Z | HTTP 403: the run cannot be retried. Native attempt remained 1. This was a spent channel attempt, not a third executed job. |
| Balanced UI re-request, authenticated event 32641329434 at 22:10:58Z; dynamic run 37538942393 attempt 1 | Terminal cancelled at 22:31:33Z. Full validation and final guard succeeded; review processing was cancelled. |

The last job, 112526912328, ran 22:11:14–22:31:32Z. Complete validation ran 22:12:12–22:29:13Z: **1,021 seconds**, all eleven hooks passed. Final immutable-input verification passed at 22:29:14Z. Processing ran 22:29:19–22:31:29Z and was cancelled. The annotation explicitly states a 20-minute maximum. The ordinary current-head inventory contains fourteen successes. Those facts do not change the dynamic conclusion.

At processing start, 1,085 seconds had elapsed since job start, leaving approximately 115 seconds under the stated 1,200-second limit. Cancellation/cleanup timestamps extend beyond that nominal limit; they do not prove a longer useful budget. The instruction SelfTest remains the dominant visible hook, but its printed completion gap is not an internal profile. There is no measured full-review duration from this failed run, so no exact speedup target guarantees service success. No billing rejection or general GitHub outage is established.

Authenticated Copilot review 5435249947 reports observed **Lite** and a start-timeout warning. It contains two new product suggestions, comments 4201048162 and 4201048196. They remain with the separate R2/R3 author. This decision does not refute, accept or score them. A valid Lite result is separate from cancelled CI, and an earlier clean review cannot settle newly raised material findings.

The selected S1 C95.9 dedicated workflow exists at H and omits the full aggregate while retaining acquisition, prerequisites, hooks and the final guard. The service ran the coding-only aggregate. H's coding job and dedicated job both already declare 59 minutes. Coding full-validation declares 45 minutes. Raising these again has no demonstrated control over the dynamic 20-minute limit. Observed step choice does not identify which commit supplied setup. Default-branch selection is the leading inference, not a proved source revision.

GitHub documents dedicated-file precedence and the supported re-review UI. It does not state the dedicated workflow's lookup revision in the inspected page. Its head-branch rule is for instructions and skills. [Code-review documentation](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-code-review). The cloud-agent setup page documents default-branch activation and a customizable job timeout up to 59 minutes; this does not prove a code-review service budget override. [Setup documentation](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/customize-the-agent-environment).

Reuse B93.5: normal source landing may precede separate dedicated activation **only after current CI and reviews pass**. It cannot unlock this cancelled PR. S1, A06 and affected paired acceptance still require a legitimate service input selecting dedicated setup, retaining the guard and completing successfully. No dummy PR, closed-PR request or historical TF67/PS224 exception applies.

Reuse TF68 profiling and C88.5. H already contains bounded structural reuse and native conversion. The old broad profile identified author finalization and immutable endpoint dispatch as dominant; the later decoder split led to the implementation already present here. The historical cold pair was 11.407920466 versus 8.074512943 seconds with equal output, 59 fresh parser calls, 51 conversions and 8 hits; its complete packet failed parent cleanup and remains failed. Neither that single timing pair nor prior successful ordinary CI establishes current hosted margin. Repeating the old converter experiment would measure completed work.

## 2. Stakeholders and authority

The owner and both maintainers need progress without an endless retry loop or a failed-CI merge. New contributors and recovery operators need one clear next action, an attributable request, and a stop condition. Windows/Linux tool users and QA need all real coverage, parser freshness and actual exit propagation preserved. Security and supply-chain owners need verified acquisition, strict identity/schema checks, unchanged immutable inputs and safe runner isolation. Independent reviewers and history custodians need cancellations and failed experiments retained separately from successful assertions. Provider engineers need public native identifiers and precise questions, not unsupported diagnoses. Platform and cost owners control paid capacity and infrastructure. Artifact consumers and the peer repository need genuine accepted inputs before integration. Guide readers, accessibility and localization users have no proposed content/interface change in this packet; removing guidance or checks cannot solve it.

LOOP-POLICY reviewer step 5 limits terminal-service recovery to three channel attempts for one input; step 6 requires normal new-input review after a genuine material change. The latest direct owner wording relayed by root is: “You may try once an hour to relaunch the CI, but do not merge the PR while CI is failing.” It positively permits retries at that cadence; it does not specify an attempt-count extension. The hourly condition and finite cap can both be satisfied. Therefore this report does not infer unlimited retries, and it does not claim a fresh owner grant is needed for every ordinary permitted retry. Here the three channels have actually been spent.

There is no need to ask the owner to approve the selected preparation or R2/R3 merits work again. If a necessary material repair is selected on its own merits, root follows step 6 for the actual changed input, records the old spent attempts and retains the original deadline. That is ordinary authorized review handling, not a cosmetic fourth try. A no-change disposition, factual body correction, rebase without changed reviewed behavior, dummy delta or new PR name cannot manufacture this exception.

Only if root selects a **fourth same-input request** is a missing authority concrete: one explicit extension from three to four channel attempts for PS235 H504/bodyccfa, with the same deadline, hourly spacing and failed-CI prohibition. The earliest cadence boundary from the last accepted request is 23:10:58Z; that timestamp itself grants nothing. Do not request a broader waiver. Separately, sending the attached provider inquiry needs explicit message authorization. Account, paid-runner, network or security-setting changes require their own actual scoped authority. A high score supplies none of these grants.

Hard constraints: preserve all tests and negative controls, parser/runtime freshness, identity/security guards, current-input attribution, cleanup, deadlines and transfers. No current failed/cancelled-CI merge, direct-main/bootstrap admission trick, administrator override, disabled review capability to avoid a check, ignored failure, unbounded retries or false successful service disposition.

## 3. Options before scoring

| ID | Concrete option |
| --- | --- |
| A | Retain hold and wait without further preparation. |
| B | Make a fourth unchanged UI request at the next hourly boundary. |
| C | Retry the rejected Actions rerun endpoint again. |
| D | Land PS235 now, then prove dedicated activation. |
| E | Create a separately reviewed minimal dedicated-setup bootstrap. |
| F | Change timeout YAML, filename, trigger or dispatch in hope of activation. |
| G | Prepare the precise provider inquiry and preserve the hold. |
| H | Run one current-source author-case timing pair after a scoped release. |
| I | Repeat the full SelfTest/aggregate profile now. |
| J | Implement speculative caching, converter or parallel fixture changes now. |
| K | Qualify a supported larger hosted runner. |
| L | Qualify ARC Ubuntu x64 infrastructure. |
| M | Use dependency caches, snapshot or prebuilt tools to shorten setup. |
| N | Continue genuine R2/R3 merits and any selected necessary repair. |
| O | Disable review capabilities, remove checks, waive failure, or change main directly. |
| P | Prepare G and the exact H fallback; retain hold; use N without duplicate work. |
| Q | Defer PS235 and continue an independent on-plan outcome. |
| R | Close or abandon PS235 now. |

E is a real dependency option only if independently justified; a smaller PR still runs the old all-files caller. It cannot be assumed faster or used to launder the same unresolved admission problem. J includes persistent parser/cache shortcuts and in-place parallel fixture mutation; these require new freshness/isolation evidence and cannot be justified by a timeout alone. R2's specific identity/reflection suggestion is intentionally left to its owner.

Larger runners and ARC are documented alternatives; code review requires Ubuntu x64, and larger runners incur charges. Neither account eligibility nor this run's selection of a new runner is established. Changing a file the service does not select may have no effect. [Runner documentation](https://docs.github.com/en/copilot/how-tos/copilot-on-github/set-up-copilot/configure-runners). Cache/prebuilt setup could save some preparation but does not address the known 1,021-second aggregate or establish a safe review budget. An owner-authorized alternative review cannot alone make the cancelled workflow pass.

G can accompany H or N. P is that bounded combination with preparation now and execution gates explicit. Q can accompany P under existing dependency rules; it does not release frozen B99 integration. D becomes eligible only after an actual all-green current input. B becomes eligible only after the narrow cap extension, and remains a low-evidence remedy. A provider-confirmed supported correction would need a scope-specific follow-up decision, not automatic implementation of F, K or L.

## 4. New rubric

Scores are judgments from 0 (contradicts the goal) to 5 (plausible, substantially unproved) to 10 (strong support for the stated next action). They are not probabilities or measured performance. Total = sum(weight × score) / 10. Hard eligibility overrides ranking.

| Criterion | Weight | Specific assessment |
| --- | ---: | --- |
| Admission and recovery correctness | 31 | Keeps cancelled CI blocked, applies actual input/round/cap rules, and distinguishes setup, review and activation evidence. |
| Security and validation preservation | 23 | Retains acquisition, fresh parsing, strict conversion, full coverage, immutable guards and isolated cleanup; avoids speculative cache or runner trust. |
| Contributor/operator usability | 19 | Gives a concrete bounded next action, minimal repeated work, intelligible failures and no redundant approval or hidden reset. |
| Causal evidence and falsifiability | 17 | Addresses an unresolved current unknown; allows observation to disprove the hypothesis; separates provider selection from local runtime. |
| Credible delivery progress | 7 | Advances a necessary current decision without betting acceptance on runtime variance or an unavailable capability. |
| Churn and resource burden | 3 | Avoids needless new infrastructure, repeated long profiling and coupled maintenance after the higher priorities. |

| ID | Correct31 | Security23 | Usability19 | Evidence17 | Progress7 | Cost3 | Total | Boundary |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 10 | 10 | 3 | 4 | 1 | 10 | 70.2 | Eligible; preserves gates but leaves the unknowns unresolved. |
| B | 7 | 10 | 5 | 2 | 3 | 8 | 62.1 | Unavailable under the present same-input cap; variance is not a remedy. |
| C | 5 | 10 | 2 | 1 | 1 | 8 | 47.1 | Unavailable under cap and contradicted by authenticated 403; no new transport evidence. |
| D | 0 | 2 | 4 | 2 | 5 | 9 | 21.8 | Ineligible while current CI is cancelled; B93.5 is conditional on green gates. |
| E | 9 | 9 | 4 | 4 | 4 | 3 | 66.7 | Conditional genuine dependency repair; at least seven coupled paths previously identified; its own old setup can time out. |
| F | 6 | 8 | 3 | 1 | 2 | 5 | 47.3 | Unsupported as a current remedy; both job declarations already say 59 minutes. |
| G | 10 | 10 | 8 | 9 | 5 | 10 | 91.0 | Preparation eligible now; sending needs explicit external-message authority. |
| H | 9 | 10 | 8 | 8 | 6 | 7 | 86.0 | Conditional, not run here; must follow R2 disposition to avoid duplicate measurements. |
| I | 8 | 10 | 3 | 4 | 3 | 2 | 63.0 | Low information value; repeats known outer hotspot and does not measure provider selection. |
| J | 5 | 5 | 4 | 2 | 5 | 3 | 42.4 | Unproved semantics and payoff; existing native conversion/reuse already applied; R2 belongs to its owner. |
| K | 8 | 8 | 5 | 5 | 5 | 2 | 65.3 | Conditional on supported account/configuration, actual cost authority and selection; no purchased capacity here. |
| L | 7 | 6 | 2 | 4 | 4 | 1 | 49.2 | Conditional security/network/platform work; disproportionate before selection is understood. |
| M | 7 | 7 | 5 | 4 | 4 | 3 | 57.8 | Conditional provenance and invalidation design; preparation outside aggregate is only about one minute here. |
| N | 10 | 10 | 8 | 9 | 7 | 8 | 91.8 | Already scoped to separate author; real changed input gets normal new-input review, no manufactured cap reset. |
| O | 0 | 0 | 2 | 0 | 3 | 7 | 8.0 | Ineligible; removes actual gates or bypasses normal admission. |
| P | 10 | 10 | 9 | 10 | 6 | 9 | 95.0 | Selected preparation and coordination; no execution, retry or message released by the score. |
| Q | 10 | 10 | 6 | 5 | 4 | 8 | 79.1 | Eligible only under its actual dependencies and ownership; does not clear this PR or B99 integration hold. |
| R | 9 | 10 | 2 | 5 | 0 | 9 | 65.9 | No evidence requires abandoning valid work; destructive scheduling choice is not selected. |

P95.0 wins for the scope actually proposed: a ready inquiry, a bounded conditional experiment and use of already-authorized finding work. Its progress score is only 6 because none guarantees successful service activation. This selection spends no further native attempt and cannot accept the PR.

## 5. Selected procedure

1. Keep PS235 unmerged.
2. Retain both cancelled runs and the rejected rerun record.
3. Give root this report, the evidence file and the unsent inquiry.
4. Let the assigned author finish R2 and R3 decisions.
5. Do not add a change only to obtain another request.
6. If a genuine material repair is selected, use the normal current-input review procedure after its required validation.
7. Keep the original PR deadline and all spent-attempt history.
8. If no material repair is selected, keep the same-input service cap in force.
9. Use the prepared inquiry if the owner authorizes sending it.
10. Ask for a one-attempt cap extension only if root selects another same-input request as the next action.
11. Before any authorized request, reconcile native inputs, terminal results and elapsed limits once.
12. Use the supported Balanced UI request once.
13. Confirm its request event or exact-head run.
14. Do not repeat an ambiguous accepted request.
15. Record the observed effort and terminal CI result separately.
16. Stop at any new failure, exhausted allowance or expired deadline.
17. Require normal final quality and all current CI gates before merge.
18. Require separate dedicated service proof and reverse comparison before paired acceptance.

These instructions use short, consistent controlled-English sentences. No formal ASD-STE100 dictionary certification is claimed. Root must display/select the proposal before any follow-on operation. The report itself releases no test, edit or native request.

## 6. Exact conditional experiment; not executed

A further measurement is justified only if R2/R3 disposition leaves an unresolved runtime question and root selects H. The useful question is the distribution of **remaining current** author-case time after native conversion, not whether the retired PowerShell recursive conversion was slow. Do not duplicate any measurement already produced by the R2 owner. If that evidence answers the question, omit this experiment.

Use one unchanged control and one timing-only private copy of the same current immutable author-finalization case. Rebind H, B, checker, SelfTest, helper, dependency catalog, qualified offline runtime and actual clock. If a selected repair changes these, bind its final bytes and explain the changed case before release. Reuse the existing actual fixture constructor and success oracle; do not replay historical fixture revisions or patch a success verdict. Use isolated disposable directories and the already-qualified owned process/container boundary. Do not install, fetch, alter product files or run in either product worktree.

Measure one whole child and, inside the existing structural caller, these non-overlapping or explicitly nested intervals: native parser invocation; native conversion including cold initialization; the existing schema/construction families; snapshot-copy work; remaining caller time. Record invocation counts, reuse hits, byte/line lengths and exit status without document bodies. Leave R2 identity/reflection-specific attribution with its author. Do not instrument every recursive value or alter exception, scope, return or native-status semantics. Marker removal must recover exact current bytes. A boundary that cannot safely be measured stays unsplit and is reported.

Use two fresh child processes, serially. Cap each at 120 seconds and the complete fixture/setup/cleanup at 600 seconds. Limit timing output to 2 MiB and 2,000 events. No full SelfTest, aggregate, Node suite, repeated sample, modified implementation or hosted request is part of this experiment. Require exact stdout, non-marker stderr, exit and success-oracle equivalence; matching fresh-parser/conversion/hit counts between the pair; unchanged complete source/dependency/Git guards; and owned children empty with container absent. Historical 59/51/8 counts are comparison context, not a fabricated current oracle. Preserve any cap, mismatch or cleanup failure and stop.

Report raw timing and instrumentation overhead, separate inclusive/exclusive intervals, and identify unmeasured remainder. One pair can locate a remaining cost; it cannot establish a stable benchmark, provider setup revision or reliable 20-minute review margin. Do not implement an optimization from this specification alone. A measured meaningful cost needs its own repair decision or an update to the applicable existing decision, with security equivalence and normal final-input validation. If no useful cost is isolated, return that result without a larger automatic profile.

## 7. Verification and handoff

Only the three files in this private directory were written. No product code, tests, parsers, imports, hooks, installers, Git operations, native requests, settings or external messages were executed. Standard-library evidence parsing, hashing and score arithmetic checked the packet. Primary GitHub documentation was read; no authenticated network mutation occurred.

Current round remains 1; deadline remains 2026-10-14T20:09:39.767792Z. A06/A03/A21/A07 remain 2/4/6/6 of 12. No pending native action is recorded in the bound state. The saved snapshot is not a guarantee of future state; root must refresh actual native inputs before any later action. B99 and held A07 are unchanged. Product/local quality evidence can remain useful while CI is on hold; this report claims neither merge readiness, all-CI success, nor S1/paired acceptance.

References and SHA256 bindings are in evidence.json. The provider inquiry contains public PR/run/source links and no private logs, credentials or browser internals. It remains unsent.
