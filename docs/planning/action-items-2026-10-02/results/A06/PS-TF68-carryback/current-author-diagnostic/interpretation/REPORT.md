# Current author-case structural cost: finding and decision proposal

## 1. Validate the opportunity and its limits

The one released diagnostic passed. It used PS H `504cd7672ac9604ace765a4f451346f801f09ddd`, accepted B `98177628b7bc02c646724bfc8aa0fd73fed0cd24`, the same freshly constructed private author-case endpoints/clock/argv for both children, pinned offline Linux runtimes and unchanged 78-source/1,914-dependency guards. The raw pair, strict ownership receipts and root verification are hash-bound in `evidence.json`. Root's result is explicitly **one current case, not product or CI acceptance**. No run was repeated for this interpretation.

Both children observed 52 parser calls, 44 structural conversions, eight reuse returns and four generic conversions, with 52 zero native exits. Their raw stdout and nonmarker stderr matched. Control took 11.629019 seconds; timing took 11.974164 seconds. The observed difference was +0.345146 seconds, or +2.97%. That includes instrumentation effects, execution order and uncontrolled variation; it is not a stable instrumentation-overhead estimate.

| Timing-child region | Calls | Seconds | Interpretation |
| --- | ---: | ---: | --- |
| Entire structural caller | 52 | 8.013397 | Inclusive parent; do not add it again to its children. |
| Fresh native parser | 52 | 3.313063 | Availability, launch, parsing and transport within the existing boundary. |
| Prose schema | 44 | 1.914735 | Validation, ranges and construction inside this whole family. |
| List schema | 44 | 0.753773 | Whole family, not isolated element checks. |
| Table schema | 44 | 0.592413 | Includes row/cell work. |
| Native conversion, cold-inclusive | 44 | 0.468503 | First interval 0.314831; no identity/reflection-specific attribution. |
| Snapshot copies | 8 hits + 22 stores | 0.437302 | Mutation isolation and bounded accounting remain required. |
| Other schema/construction | 44 each | 0.245960 | Envelope, ranges, blocks, headings, level-two headings and construction. |
| Caller remainder | — | 0.287648 | Unsplit work and boundary overhead. |
| Outside the caller | — | 3.960767 | Script bootstrap and other validation; not attributed further. |

The prose/list/table families together consumed **3.260921 seconds**, 40.69% of the inclusive caller and 27.23% of the timing child. These are real, nontrivial measured regions. They are not 3.261 seconds of removable work. The diagnostic did not count empty `code`/`links` arrays or isolate pipeline initialization, property access, range checking or object construction within those families. It cannot predict their net speedup or any fraction of the hosted 1,021-second aggregate. The hosted run passed its full validation and final guard before later processing was cancelled; this experiment does not identify that processing cause, provider setup or a reliable 20-minute margin.

Current source nevertheless identifies a small, independently justified optimization candidate: six `Where-Object` element-filter predicates in `Get-MarkdownParseContext`, at lines 3832/3834 (prose), 3886/3888 (table cells) and 3954/3956 (list items). Each already has an earlier `-isnot [array]` rejection. A zero-element array has no nonstring elements. The existing filter therefore cannot reject such an array, yet the current expression still invokes the pipeline. Add an explicit **nonzero array count** condition around only that existing filter. Leave the filter byte-equivalent for nonempty arrays. This removes logically redundant work for a supported input shape without replacing schema validation.

The source-level equivalence argument is narrow: a nonarray still fails at its existing short-circuit type guard; a true zero-element array contributes no invalid element; every nonempty array still executes the original predicate. Keep parentheses because PowerShell `-and` and `-or` share precedence. Microsoft documents short-circuit evaluation and array counts in [about_Logical_Operators](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_logical_operators?view=powershell-7.6) and [about_Arrays](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_arrays?view=powershell-7.6). Neither reference establishes runtime savings.

**Materiality verdict:** measured schema-family cost and a logically redundant expression support a bounded implementation-and-evaluation proposal. There is no demonstrated admission defect or measured candidate speedup. Added count checks can make the candidate neutral or slower, especially on nonempty arrays. A private candidate can be constructed to test the opportunity; it must not be committed or published as a performance repair unless a fair bounded comparison establishes practical net benefit. Absent or inconclusive benefit means no change. It cannot be made merely to obtain another review input or described as demonstrated service recovery.

## 2. Stakeholders and constraints

The owner and both PS/TF maintainers need a useful current-input change with honest benefit and minimal review burden. Experienced contributors and new documentation authors need predictable validation, unchanged errors and no new switches or setup steps. Generated-artifact consumers and documentation readers rely on the same parsed ranges, exact array types and metadata admission. Faster validation must not silently accept malformed parser data.

Windows/Linux PowerShell users, Node/dependency maintainers and CI/platform engineers need the existing qualified runtimes, process exit handling, clock behavior and bounded parser transport. This proposal changes no Node version, package graph, Bash step or workflow. Security executives, application/infrastructure/supply-chain engineers, privacy owners and incident operators need fail-closed schema checks, fresh parser execution, unchanged native conversion checks and no document logging or expanded trust. The parser result must remain data, even when empty.

Code reviewers, independent quality readers, QA and release operators need meaningful edge controls and a finite delta, not a new framework or a second validator. Auditors and history custodians need the successful scoped result, failed CI history and prior no-change decisions kept distinct. Cost/schedule stakeholders need a small opportunity that does not claim an unmeasured large recovery. Support/cloud administrators still need the separately prepared provider inquiry if its authorization arrives. Accessibility/localization concerns do not require a new interface: existing message text and output forms must remain unchanged.

Hard constraints: preserve every fresh parser call, runtime/source identity check, strict decoder/schema check, range/order rule, generic conversion behavior, snapshot bounds/deep copies/definition invalidation and primary-error cleanup. No new parser skip, trusted-input exception, cache lifetime, install or runtime profile is allowed. Keep PS235's failed-CI hold, round 1, spent 3/3 allowance, deadline `2026-10-14T20:09:39.767792Z`, B99 freeze, R2 A92.7 and R3 A96.1 unchanged. Inquiry authorization remains pending; no message is sent here. A score cannot waive these limits or authorize an operation.

## 3. Relevant options, before scoring

| Option | Concrete scope and tradeoff |
| --- | --- |
| A | Retain current code and scoped timing evidence. No new product risk; no improvement work or provider explanation. |
| B | A plus the existing provider-inquiry route, only when separately authorized. Addresses the unresolved service behavior without claiming local code caused it. |
| C | Construct only six empty-array short circuits, add meaningful SelfTest coverage, and require the bounded final-candidate benefit gate below before commit. Keeps all nonempty predicates; no change if benefit is absent/inconclusive. |
| D | C plus the independent B inquiry route. A limited implementation-and-evaluation trial and service investigation remain separate; neither guarantees benefit or substitutes for acceptance. |
| E | Replace all six element pipelines with inline `foreach` type scans, including nonempty arrays. Potentially broader savings, but changes enumeration/early-exit behavior and needs a larger parity proof. |
| F | Factor one PowerShell string-array checker and call it from all three families. Centralizes validation; parameter binding, scope and added function dispatch may offset savings. |
| G | Use a narrowly bounded native string-array check through the existing native infrastructure. Avoids pipelines but adds native/PowerShell crossing, type/fallback/reload obligations and a new check boundary. |
| H | Move complete schema validation/construction into native code. Addresses more measured work; a large port must reproduce coercion, ordering, types, errors, culture and lifecycle behavior. |
| I | Keep fresh parsing but redesign Node as a persistent worker. Targets the 3.313-second parser region while substantially changing isolation, transport, retries and ownership. |
| J | Reduce snapshot copies or enlarge retention/reuse. Targets 0.437 seconds, but mutation isolation, payload accounting and definition freshness are contractual. No current evidence supports changing their limits. |
| K | Perform another broad/per-property profile or the unselected R2 128-call microdiagnostic before acting. Not released, disproportionate to this finite shortcut and does not itself repair anything. |
| L | Remove/relax schema checks or add a trusted-parser exception. Easier speed path, incompatible with the security contract. |
| M | Combine the larger loop/native/transport/copy changes in one optimization. Coupled attribution and proof become difficult; the current evidence does not justify the bundle. |
| N | Retain code now and defer optimization to a later legitimate consumer need/current foundation boundary. Valid scheduling choice, with retained evidence; no inferred prerequisite is invented. |
| O | Cache prior parser output and skip fresh execution. Potential speedup violates the current fresh-parser and failure-freshness contract. |
| P | Reopen R2 metadata caching from the conversion-family timing. This family measurement does not isolate the cache target; the selected no-change decision remains applicable. |

C combined with E collapses into E's changed nonempty checking mechanism; it adds no independent proof. C with H is subsumed by the native port. B combines safely with any otherwise eligible option because the inquiry is independent. Combining J/I with C requires their additional lifecycle decision and is M for this finding. Native reuse does not automatically make G/H safer than the existing predicate. No wrapper, workflow change, dummy edit, service timeout increase or waiver follows from this local measurement.

## 4. New weighted rubric

Ratings are prospective design judgments, not observed speed percentages. All scores use 0–10, with 10 strongest. Total = sum(weight × rating) / 10.

| Criterion | Weight | Finding-specific meaning |
| --- | ---: | --- |
| C — admission equivalence and technical correctness | 36 | Preserve exact current outputs, refusals, typing, ranges, generic behavior and fresh parser execution. 10: narrow logical equivalence; 5: significant unproved port; 0: deliberate weakened admission. Final tests remain mandatory even at 10. |
| U — contributor usefulness and predictable operation | 23 | Remove real unnecessary work without new user steps, cache surprises, process lifetime or environment setup. Benefit must be stated honestly. 10: focused useful work with unchanged routine operation; 5: uncertain benefit plus added workflow; 0: user-facing unreliability. |
| S — security, ownership and recovery | 22 | Retain data/type trust, bounds, mutation isolation, helper freshness, primary failures and strict cleanup. 10: boundaries unchanged; 5: new lifecycle requiring extensive proof; 0: skips a boundary. |
| E — fit to the actual evidence and calibrated claims | 11 | Match the measured region, avoid attributing unmeasured subcost or hosted cancellation, and use proportionate validation. 10: fully calibrated no new hypothesis; 8: finite source-supported candidate with declared benefit uncertainty; 5: largely unmeasured mechanism. |
| M — maintenance and review clarity | 5 | Finite code, preserved checks, useful edge tests, no duplicate checker or new framework. 10: six transparent predicates/retained evidence; 5: cross-language/lifecycle complexity. |
| T — implementation/validation cost and churn | 3 | Reuse existing qualified inputs and tests; respect serialization and schedule. Include the mandatory four-child comparison and possible discarded candidate. 10: no product work; 5: new boundaries; 0: unjustified costly redesign. Cost cannot override correctness. |

## 5. Complete scores

| Option | C36 | U23 | S22 | E11 | M5 | T3 | Total | Key uncertainty / eligibility |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 10 | 6 | 10 | 10 | 10 | 10 | 90.8 | Fully honest retention; no usefulness beyond the saved observation. |
| B | 10 | 7 | 10 | 10 | 10 | 10 | 93.1 | Valid no-change choice; inquiry still needs authorization and may not resolve service behavior. |
| C | 10 | 8 | 10 | 8 | 9 | 7 | 91.8 | Finite equivalence; compulsory parity/benefit gate adds cost and may return no change. |
| D | 10 | 9 | 10 | 8 | 9 | 7 | 94.1 | Recommended trial plus inquiry; no commit without net benefit, no promised service recovery. |
| E | 9 | 9 | 9 | 8 | 8 | 6 | 87.5 | Nonempty enumeration/parity unproved; also needs the benefit gate. |
| F | 9 | 8 | 9 | 8 | 9 | 6 | 85.7 | Binding/dispatch and helper-replacement proof plus benefit gate. |
| G | 8 | 8 | 8 | 7 | 6 | 4 | 76.7 | Native crossing/lifecycle may cost more; larger proof and benefit cost. |
| H | 7 | 9 | 7 | 6 | 5 | 3 | 71.3 | Whole-schema port risks/cold-load cost; unsupported broad change. |
| I | 6 | 8 | 6 | 5 | 5 | 3 | 62.1 | Persistent freshness/retry/cleanup changes need a different lifecycle decision. |
| J | 6 | 7 | 6 | 5 | 6 | 4 | 60.6 | Copy bounds/isolation are contractual; no new limits supported. |
| K | 10 | 4 | 9 | 5 | 7 | 5 | 75.5 | Ineligible now: no repeat or new profile release. |
| L | 1 | 7 | 0 | 4 | 7 | 10 | 30.6 | Ineligible: weakens schema/data admission. |
| M | 7 | 9 | 7 | 6 | 4 | 2 | 70.5 | Bundled uncertainty; no scope or evidence for aggregate redesign. |
| N | 10 | 6 | 10 | 8 | 9 | 8 | 87.5 | Legitimate deferral; does not establish a new hard ordering gate. |
| O | 2 | 8 | 1 | 4 | 6 | 7 | 37.3 | Ineligible: skips required fresh parser execution. |
| P | 8 | 7 | 7 | 4 | 6 | 5 | 69.2 | No new R2-specific evidence; prior selected no-change remains. |

Arithmetic is recomputed in `evidence.json` for every row. D94.1 is a recommendation for a limited private implementation-and-evaluation trial, not a publishable optimization yet. The mandatory comparison reduced its maintenance/cost ratings; it is only one point above B93.1. B remains a sound no-change choice if the owner declines that bounded trial cost. D's usefulness is conditional on the benefit gate and its no-change fallback; the score assumes neither a speed gain nor removal of the entire 3.261 seconds.

## 6. Controlled-English recommendation: D94.1

1. Keep the completed pair and all failed-CI history.
2. Keep the current review cap, deadline and B99 freeze.
3. Give root this decision before any source edit.
4. If root selects D, appoint one source writer.
5. Bind the current PS H and accepted B again.
6. Change only the six string-element predicates in `Get-MarkdownParseContext`.
7. Keep each existing array-type guard before the new condition.
8. Use an explicit parenthesized nonzero-count condition around the original filter.
9. Skip that filter only when the validated array count is zero.
10. Keep the exact original filter for every nonempty array.
11. Keep all ranges, ordering, construction, messages, parser calls and native conversion unchanged.
12. Keep all snapshot bounds, copies and definition checks unchanged.
13. Add meaningful current SelfTest controls in the existing SelfTest script.
14. Use the actual edit date and existing metadata rules.
15. Stop if construction reveals a different admission or lifecycle problem.
16. Obtain root's final-input test release before running anything.
17. Pass focused correctness parity before the bounded benefit comparison.
18. Do not claim a measured speed gain from this proposal.
19. Request root's separate release for the exact four-child comparison below.
20. Do not replay this completed pair or its private endpoints.
21. Keep no change if benefit is absent, inconclusive or outside the declared gate.
22. Keep the provider inquiry independent of the local code change.
23. Send the inquiry only after its existing authorization arrives.
24. Do not treat a changed head as a service cap reset or acceptance.
25. Require practical net benefit and all normal final-input quality/endpoint gates before commit or a new review.

These short instructions use consistent controlled English. No formal ASD-STE100 dictionary certification is claimed. This report is a proposal; it releases neither a source writer nor any test, measurement, request or message.

## 7. Exact implementation and final validation obligations

Prospective product scope is only `.github/workflows/Test-AgentInstructions.ps1` and `.github/workflows/Test-AgentInstructions.SelfTest.ps1` in the actual current PS input. No helper, native C# class, parser program, schema family extraction, workflow, dependency, guide or B99 file is added. The guard form is conceptually `($array.Count -ne 0 -and <the original invalid-element predicate>)`; preserve the existing surrounding `-or` parentheses and evaluation order. Do not replace the original predicate, cast before checking or turn a missing/null/nonarray into an empty accepted input.

Meaningful prospective controls must exercise all six fields, through the actual existing parser/decoder/context path: zero-element `code`/`links` arrays; singleton and multi-string arrays including empty/Unicode/date-like strings; missing/null/scalar/object fields; nonempty mixed numeric/Boolean/nested-array/object values; first/last invalid elements; and null elements. Compare baseline and candidate admission, failure category/message and exact result types/values. Do not claim an unexecuted null-edge rejection: characterize baseline parity instead of silently tightening or weakening another case. Positive fixtures must prove `[string[]]` zero-element outputs remain zero-element arrays, including table cells and list items. Real plain prose/table/list parser fixtures cover naturally empty arrays; synthetic raw-output controls isolate malformed shapes.

Require the inherited strict JSON/schema/range controls, generic/native conversion equality and special-name fallback, fresh-parser failure/output-change controls, function replacement invalidation, returned-graph mutation isolation, eight-owner/byte/record/element retention boundaries and primary-error cleanup. Existing `Assert-MarkdownParseReuseSelfTest` already exercises the actual parser, decoder replacements, definition replacement and mutable graph copies; reuse its design and evidence only at their stated scope. It does not presently demonstrate candidate parity for all six proposed empty predicates. Add that missing coverage without a new generic harness or cache.

Root chooses qualified Windows/Linux focused and normal final-byte suites under the established quality gate; preserve the current full seven-file Node command if required, eleven applicable aggregate hooks/full SelfTest, immutable source/dependency/index/ref guards and all required accepted/proposed endpoint modes/current audit. Existing H receipts remain valid only for H. A changed validator needs its actual final-input evidence. No aggregate, full SelfTest or unchanged broad qualification is repeated here.

**Mandatory, separately released benefit comparison:** freeze the uncommitted final two-script candidate and the exact unchanged H preimage before publication. Reuse the qualified offline fixture, clock, identity/cleanup infrastructure and one real author-case oracle, with freshly reconstructed private B/H and one captured actual UTC. Both checker variants validate the same target data, argv, cwd, clock, dependencies and native runtime. Use four serial fresh children in predeclared **baseline, candidate, candidate, baseline** order. This yields two opposite-order matched comparisons, mitigating simple order/page-cache bias without a new profile. Both variants get only the identical lightweight count/exit observers; no schema phase, per-property or R2-cache markers are added. Measure whole-child wall time through direct completion, including cold compilation/bootstrap. Record cleanup separately. No warm in-process cache or timing-data selection is allowed.

Retain the established 120-second maximum per child, 600-second complete envelope, 2 MiB/2,000-event bounds, offline pinned image and exact source/index/ref/config/dependency/owned-child/container-absence guards. Outer budgets are shared ceilings, not additive allowances: if setup or earlier children consume the work window, stop with an incomplete/failing comparison. Do not shorten a remaining child into a successful partial result or extend the envelope. Prepare/review the exact new packet before any release. Root can decline this trial; it does not authorize a repeat of the completed diagnostic.

All four must have identical raw stdout, nonmarker stderr, native exits, parser/conversion/reuse/generic counts and the real success oracle, plus clean strict ownership receipts and immutable guards. Meaningful functional controls must separately prove exact context types/values and refusal parity. Before looking at results, set the practical retention threshold to **both matched comparisons faster for the candidate, and a reduction in median whole-child time of at least 5% and at least 0.5 seconds**. With two observations per variant, the median is their arithmetic mean. These are declared local usability thresholds, not measured variance or a hosted timeout target. A wide discrepancy between pairs, environmental interference, failed parity, a bound failure or other reason that makes the result inconclusive means no change even if a numerical average crosses the band.

Two opposite-order observations still cannot establish a stable benchmark or production-wide savings. A passing comparison supports only defensible practical benefit in this case. If it is absent/inconclusive, root preserves the evidence and restores only the owned uncommitted proposal from the frozen preimage after confirming ownership; no blanket reset or unrelated restoration is proposed. Do not commit, seek a review, enlarge the profile or automatically repeat until a favorable sample appears. If merit passes, finish the normal final-byte quality/endpoint gates before commit/new review. Any later input change invalidates this comparison's candidate binding. No isolated R2-cache benchmark, provider setup inference or larger automatic profile is proposed.

## 8. Handoff and frozen boundaries

Only this new private `interpretation/REPORT.md` and `evidence.json` are written. Inspection used immutable receipts, actual current source, read-only local Git, primary Microsoft language documentation and host arithmetic/hash checks. No product/test/parser/probe/payload execution, packet imports, container operations, dependency execution or Git/native mutation occurred. Product remains clean H504/B981; prior R2/R3 records, the successful scoped pair and old failed cold receipts are unchanged. Root owns selection, all implementation/execution, acceptance and any native disposition. No transfer counter or clock is changed.
