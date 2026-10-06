<!-- markdownlint-disable MD013 -->
# TF68 round 6: next timeout-remedy proposal

**Select Q93.7 as the next bounded action: prepare one current-head per-context timing pair and a provider clarification packet.** Do not repeat the full-suite profile. Do not implement a decoder, schema or concurrency change until the new evidence supports its exact scope. This updates the existing runtime/activation finding; root owns canonical integration and release. No test, product edit, CI retry, message or settings change is authorized by this proposal.

## 1. Validated problem and retained evidence

Current TF68 is `ed9eea201cfd70a88a6b982b29904e2f6206a692`, tree `414509ef0a5f6db3cceab5e6b720fbcbcb3cb4ad`, against accepted base `e21b74fe0b56551008f78f9f2946cd2a0f9c19ce`. Immutable source reads and saved native records bind these inputs.

| Current run | Native result | Complete-validation step |
| --- | --- | --- |
| Dynamic37456500523/job112245306404 | Cancelled; job11:27:20–11:47:37Z | 11:28:12–11:47:34Z; cancelled after1162s |
| Ordinary PR37456293051/job112244615714 | Success11:50:48Z | 11:25:53–11:50:46Z;1493s |
| Ordinary push37456283745/job112244584623 | Success11:52:44Z | 11:25:45–11:52:42Z;1617s |

The dynamic annotation explicitly reports its20m maximum execution time. It ran the coding-only complete-validation step. Its final immutable-input step succeeded, but that does not make the cancelled aggregate successful. Both ordinary logs show the instruction contract/mutation hook passing at the end. All three saved log hashes match their collection summaries. This is a runtime-limit failure; the records do not establish a billing failure.

Even with zero setup/review overhead,1493/1617s would need approximately19.6%/25.8% less time to fit1200s. Actual required margin is larger. These are arithmetic workload comparisons, not cross-runner performance forecasts. The current C repair was insufficient on this service attempt. Its measured8.03% single-case improvement never established hosted margin.

Reuse the prior work:

- The broad diagnostic at source5ec4bdc measured778.038s for the full instruction command. Author finalization took563.754s. Its41 immutable endpoint dispatches took478.280s. It already identifies the dominant caller family. File inquiries/snapshots were much smaller. Repeating this full sweep has low information value.
- The812-event inner pair measured59 parse-context calls totaling10.396490s, with2.849129s inside the nested native parser. The7.547361s remainder did not distinguish JSON decoding, schema construction or other PowerShell work. Nested totals must not be added.
- C's later original/changed case measured13.564239/12.475015s,59/59 fresh parser calls and59/51 decoder calls: eight reuse hits. Changed decoder time was5.169265s; parser time2.739442s;33 copies took0.496878s. Decoder timing omitted later schema checks. This is one instrumented original-then-changed case, not stable performance evidence.
- Current validator raw SHA256 `9ca8f6ab530f4e1f30a9745d38a4f70d94d48016565e568d15b4a02b4b85b011` equals C's measured validator. The SelfTest subsequently received the parsed-argument mutation repair. Preserve that repair and the actual fixture clock; do not replay obsolete fixture source wholesale.

Source inspection narrows the remaining question. `ConvertFrom-ParserJsonContext`269–325 bounds UTF-8 bytes, uses native `System.Text.Json.JsonDocument.Parse`, then recursively calls a PowerShell scriptblock for each object/array/value and constructs PSCustomObjects. `Get-MarkdownParseContext`3644–3918 subsequently validates schema/ranges and builds seven structural arrays. The5.169s decoder interval does not reveal how much belongs to native parsing versus recursive conversion. This is the missing measurement, not a reason to repeat the entire author fixture.

The generic decoder also serves package content, runtime identity and another parser context at487,2697 and2898. A generic native replacement has a larger contract than the structural Markdown caller. Preserve duplicate/case-ambiguous property refusal, empty-name refusal, object-root requirement, no date coercion, array/null/bool/numeric types, finite-number checks, depth64, comments/trailing-comma rejection, byte bounds and disposal. A convenient generic JSON conversion is not proven equivalent.

GitHub documents dedicated-file precedence, but the inspected page does not state the setup lookup revision. Head-branch instructions/skills guidance is not that rule. B and H have identical coding setup bytes, so observing that setup cannot identify its source revision. [Code-review environment documentation](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-code-review). The documented runner alternatives are larger hosted runners and ARC Ubuntu x64; account availability, cost authority and activation remain unverified. [Runner documentation](https://docs.github.com/en/copilot/how-tos/copilot-on-github/set-up-copilot/configure-runners).

## 2. Stakeholders and non-negotiable limits

Both maintainers, new and experienced contributors need bounded local and hosted validation with understandable failures. Security/policy owners and artifact consumers need fresh parser/runtime failures, exact accepted/candidate authority and every negative control. QA and independent reviewers need comparable outputs and attribution that can be disproved. Agent, CI and recovery operators need isolated fixtures, complete process cleanup and intact source/Git state. Platform/cost owners need real runner capability and cost evidence before purchases or network access changes. The provider owns the undocumented selection behavior. Public guide readers, localization and accessibility users have no changed content/interface in this diagnostic; do not change guidance to hide the failure.

Hard limits override every score: no skipped/full-test reduction, cached success verdicts, shared-checkout concurrent mutation, weakened schema/clock/input checks, failed-CI merge, default-branch tricks, deleted failing checks, fictitious service pass, duplicate pending request, retry faster than hourly, or reset of clocks/transfers. Raising the YAML ceiling does not prove control over the external20m cap. No blanket claims about Windows5.1 apply to this PowerShell7 checker optimization.

## 3. Options before scoring

| ID | Concrete option | Main consequence |
| --- | --- | --- |
| A | Keep code and wait. | Preserves behavior; leaves repeat failure unresolved. |
| B | Run one unchanged/timed current-head author-case pair with per-context JSON/conversion/schema timing. | Resolves the missing internal split without another whole fixture or aggregate. |
| C | Replace the generic recursive converter with an available native helper now. | Targets measured decoder cost, but changes all its callers and has unmeasured startup/semantic costs. |
| D | Decode and validate the structural schema in one native/helper pass now. | Can avoid repeated objects; broader schema rewrite before its separate cost is known. |
| E | Queue at most two independent immutable author-case checkouts. | Targets41 expensive calls; first derive exact case descriptors and prove each independent source/B/H/clock/output contract. |
| F | Shard complete fixtures into independent workers. | Preserves every test if correctly partitioned, but duplicates initialization and increases scheduling/cleanup work. |
| G | Ask the provider about lookup/registration and a supported correction. | Can resolve activation uncertainty; prepare the exact packet now, send only with authority. |
| H | Create the separately reviewed dedicated-setup bootstrap. | The prior seven-path lower bound is not a validated patch; its own legacy aggregate can exceed20m. |
| I | Use a supported larger hosted runner. | Requires account/configuration/cost authority and a measured benefit; changing an unselected file may have no effect. |
| J | Use supported ARC Ubuntu x64 infrastructure. | Adds runner/network/security operations; not justified as the first response to an internal decoder cost. |
| K | Make one reconciled unchanged retry, no faster than hourly. | Variance may yield success; it neither repairs runtime nor proves dedicated selection. No automatic loop. |
| L | Normal all-green landing followed by dedicated activation proof. | Retains the prior conditional activation sequence, currently unavailable because dynamic CI is cancelled. |
| M | Repeat the broad instruction/full aggregate profile. | Repeats known outer attribution and consumes minutes without the needed inner split. |
| N | Use a persistent parser, shared runspace or global cache. | Requires a new lifetime/freshness/isolation contract; startup alone was not the dominant measured cost. |
| O | Raise YAML timeouts or use an assumed lookup setting. | No evidence that either controls the observed service behavior. |
| P | Remove cases, skip checks, merge failing CI or manipulate default-branch admission. | Ineligible. |
| Q | Combine B with G's prepared packet; select an exact repair only after attribution. | Independent progress on runtime and selection, with one bounded experiment and no premature implementation. |

The current dispatcher checks out the shared fixture at1820; later scenarios write files, change refs and install mutant checkers. E cannot parallelize those existing calls in place. It must first construct the immutable case graph, freeze separate checkouts and run only independent descriptors. Mutable/local/proposed/clock-refusal scenarios stay serial. Require union-of-cases and case/result identity, wait for all started children and preserve every failure. A queue of two on two CPUs need not double throughput. F and E are distinct; adding F to E adds duplicated setup rather than free coverage.

B then C or D is Q's conditional repair branch. B then E remains a fallback if decoder/schema repair has insufficient payoff or excessive risk. G can accompany any safe option; its answer cannot waive CI. H plus I still needs both bootstrap admission and qualified runner authority. K is a bounded service action under the existing retry policy, not a performance strategy. Native file-inquiry batching is subsumed under a later measured helper repair; historical11.54s inquiry cost gives it low primary value.

## 4. New rubric and all scores

Scores0–10 assess the next action:0 contradicts the requirement,5 is plausible but substantially unproved,10 is strongly supported for its stated scope. They are engineering judgments, not success probabilities.

| Criterion | Weight | Assessment |
| --- | ---: | --- |
| Failure/security fidelity | 28 | Preserve all tests, fresh runtime/parser failures, schema bounds, authority and cleanup. |
| Attribution/current-input fit | 24 | Use current bytes and existing causal evidence; resolve an actual unknown rather than repeat measurements. |
| Credible completion progress | 20 | Advance toward a green bounded service path without claiming an unmeasured margin or selection rule. |
| Contributor/operator usability | 15 | Give a simple bounded next action, actionable failures and reproducible recovery. |
| Verification/falsifiability | 9 | Permit exact outputs/counts/identities and explicit stop criteria; separate evidence from hypotheses. |
| Scope/cost | 4 | Minimize coupled edits, repeated long tests, infrastructure and maintenance after correctness. |

Total=sum(weight×score)/10. Eligibility overrides total.

| ID | Fidelity28 | Fit24 | Progress20 | Usability15 | Verify9 | Cost4 | Total | Boundary |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 10 | 3 | 1 | 3 | 4 | 10 | 49.3 | eligible but no remedy |
| B | 10 | 10 | 7 | 9 | 10 | 9 | 92.1 | proposed diagnostic; no product release |
| C | 8 | 8 | 8 | 7 | 7 | 5 | 76.4 | conditional; affects other decoder callers; semantics unproved |
| D | 7 | 7 | 8 | 5 | 6 | 3 | 66.5 | conditional; broader security boundary |
| E | 9 | 7 | 7 | 7 | 8 | 5 | 75.7 | conditional; mapping/isolation/CPU benefit unproved |
| F | 9 | 6 | 6 | 5 | 7 | 3 | 66.6 | conditional; duplicates fixture setup |
| G | 10 | 7 | 5 | 7 | 7 | 9 | 75.2 | draft now; sending requires authority; answer unavailable |
| H | 10 | 4 | 4 | 4 | 6 | 3 | 58.2 | conditional; legacy bootstrap may also time out |
| I | 8 | 5 | 6 | 5 | 6 | 2 | 60.1 | conditional on actual availability/cost/activation authority |
| J | 7 | 4 | 5 | 2 | 5 | 1 | 47.1 | conditional; infrastructure and security qualification |
| K | 10 | 2 | 2 | 5 | 3 | 9 | 50.6 | eligible only under root retry rules; no causal fix |
| L | 10 | 6 | 3 | 8 | 8 | 8 | 70.8 | unavailable while current CI cancelled |
| M | 10 | 4 | 3 | 3 | 6 | 4 | 55.1 | not selected; repeats known boundary |
| N | 6 | 4 | 6 | 4 | 5 | 3 | 50.1 | conditional; freshness/protocol/isolation redesign |
| O | 10 | 1 | 1 | 2 | 2 | 9 | 40.8 | unsupported as remedy |
| P | 0 | 1 | 0 | 1 | 0 | 8 | 7.1 | ineligible |
| Q | 10 | 10 | 8 | 9 | 10 | 8 | 93.7 | selected proposal; no run/edit/message released |

Q wins because it targets the now-measured decoder boundary and prepares a separate route to resolve selection uncertainty. Its extra progress score reflects two independent questions, not a promise of a provider response. C and E remain plausible repairs; neither currently has the equivalence or performance evidence needed for immediate product changes.

## 5. Selected plain-English procedure and stop limits

1. Keep TF68 unmerged. Keep the cancelled run and both ordinary successes in the record.
2. Display this proposal to the coordinator. Obtain its selection and exact diagnostic release before execution.
3. Rebind the current head and the two checker files. If repairs changed an affected caller/helper, inspect that delta and update the case binding before proceeding. Do not reuse obsolete test source.
4. Prepare one disposable offline experiment from the current immutable source. Reuse the qualified image, dependency snapshot, actual author-case constructor and checked clock adapter. Keep its original bootstrap separate. Do not install tools or fetch content.
5. Select the existing successful immutable author-finalization case. Reconstruct one fresh private B/H and clock. Give the unchanged control and timed checker exactly the same arguments, working directory, fixture revisions and expected result. Do not claim the removed old fixture was replayed.
6. Add timing only to private copies. Record one process-local context identifier. Record normalized input/output lengths, line count and hit/miss counts; do not log document bodies. Keep59 fresh parser calls for the equivalent case unless an independently explained current-input difference changes that count.
7. Split the existing decoder measurement into UTF-8/options preparation, native JsonDocument parsing and recursive PowerShell conversion. Split the subsequent seven schema/construction families and snapshot copying. Measure recursive conversion once at its outer entry; do not instrument every recursive property. Scope attribution to the structural caller so runtime-identity/package decoding is not mislabeled.
8. Use existing statement boundaries and exception paths. Do not add wrapper scope, replace return semantics, suppress errors or disturb a native-status consumer. Prove that marker removal reconstructs the exact source bytes. If a safe internal boundary cannot be instrumented, keep the unsplit interval and state that limit.
9. Run only the unchanged control and timed child for this one case after release. Cap each child at120s and the entire container at600s, including fixture setup and cleanup. Allow at most2000 timing events and2MiB of diagnostic output. Do not run SelfTest's full sweep, the Node suite or the aggregate. Allow no automatic repeat.
10. Require equal stdout, equal non-marker stderr, equal native exit and expected assertion text. Check complete host/private source, dependency, index, refs and configuration guards. Require matched timing records for this successful case and actual child identity. Stop on any mismatch, orphan process, breached cap or guard failure. Preserve the failed evidence. Do not call a failed diagnostic a speed result.
11. Attribute inclusive and exclusive intervals without adding nested totals. Report the uninstrumented control, timed overhead, counts and unmeasured remainder. One pair gives location evidence; it does not prove reliable hosted margin.
12. Stop before product implementation. Prepare one revised decision for the dominant measured stage. Prefer a narrow conversion helper if recursive conversion dominates. Include native-helper load/compile startup and all generic callers if the generic decoder changes. Prefer a structural-only path when that avoids changing unrelated callers without duplicating unsafe semantics. Keep every existing schema rejection and fresh parser call. If schema construction dominates, propose only the measured families. If neither is substantial, assess E's independent-case queue rather than enlarging caches.
13. For any later released repair, compare the same case against the original and exercise meaningful malformed/duplicate/depth/type/range/alias/freshness controls on supported checker runtimes. Include a cold-start cost. Run the mandatory aggregate once on final integrated bytes; use normal current-input reviews/hosted CI afterward. Do not claim delivery until actual service completion and all gates pass.

The experiment is a location test, not a benchmark campaign. This proposal permits no product patch and contains no permission to keep profiling indefinitely. If the single pair is inconclusive or an instrumentation condition fails, return that result to root with the remaining unknown. A second diagnostic requires a concrete revised scope. Likewise, do not implement a speculative helper simply because its option scored well.

### Prepared provider clarification, unsent

For TF68 at H ed9eea2, `.github/workflows/copilot-code-review.yml` is present and its14 preparation steps omit the aggregate. Dynamic run37456500523/job112245306404 used the coding-only aggregate and hit20m. B e21 lacks the dedicated file; its coding setup is byte-identical to H. Ordinary setup runs37456293051 and37456283745 passed after1493/1617s aggregate steps. The documentation states dedicated-file precedence but does not identify the lookup revision.

Request these three facts: (1) Which configuration commit/blob or registered workflow supplied this run, and what determines that selection? (2) What supported registration/feature setting makes the dedicated workflow selectable for an unmerged PR without bypassing normal admission? (3) What supported runner/job-budget controls apply to this20m service limit for this account, and do they depend on the same configuration lookup? Ask for an observable verification method. Include no credentials or captured browser internals. Root must obtain message authority before sending.

## 6. Remaining gates and handoff

The latest Copilot findings remain with their separate owner. This report does not resolve or re-score them. Current cancelled CI blocks the prior all-green landing option. Bootstrap, larger runners and hourly retry remain conditional alternatives, not released actions. Before any permitted retry root must reconcile all operations and the last-launch time; a new head/review-facing change needs the normal new-input review handling. No retry was launched here.

Preserve round6, original deadline `2026-10-13T23:47:31Z`, and A06/A03/A21/A07 transfers1/3/5/5of12. No candidate or paired acceptance is claimed. Only REPORT.md/evidence.json in this assigned directory were written; no tests, source/Git/config/native writes or descendants occurred. Existing routing remains unchanged; no verified effective model override is asserted.

**One next action:** root displays/selects Q and prepares the exact current-head two-child diagnostic manifest for release, using the boundaries and limits above.

Evidence SHA256: `a5827ea43709d3462d34893fd5df68fce8cf93554d389e2f90a8ede0a86ef82e`. The JSON binds source modes/blobs, all saved log hashes, exact relevant job steps, prior evidence hashes, current code regions and every recomputed score.
