# TF68 internal runtime attribution and repair proposal

This is a proposed update to the existing canonical TF68 runtime finding. The completed B94.2 attribution decision remains history in the frozen parent report. This packet adds measured internal evidence and the next repair decision; it is not a new unrelated finding or a duplicate activation decision. Root owns canonical integration.

## 1. Validation and limits

The one released pair completed successfully. Tool session 42016 returned native exit 0. Host launcher PID 53364 used the exact approved image and manifest. The owned container completed and was removed. Host completion was 2026-10-06T08:56:04.076264Z. Both selected checker children returned 0: original 12.664242050 seconds; profile 12.583976794 seconds. Their exact argv, cwd, clock and arguments matched. Raw stdout matched, and stderr matched after removing only the profile's timestamp lines in a comparison view. The original native exit, finalization message and checked clock helper all remained required.

The reconstructed case used B `3a4ebd27a222b5c8ce11daba49cdc1691a75e44e`, H `7d355852d6ff5c23dfbf3c62ab2e0427600d22af` and clock `2026-10-06T08:55:15.3320190+00:00`. These are private new fixture identities, not native accepted revisions or the removed earlier fixture. The ordinary original-validator bootstrap was a separate 8.7548707-second parent phase. The original fixture setup and cleanup remained active.

All 80 source files, 1,914 dependency files, raw HEAD/index/config/config.worktree, complete refs and logical index remained equal in both private and host guards. There was no product, native or dependency change. The source is still published TF `5ec4bdc06431de05e93067b0e52f0dfbb1631392`, tree `441d84c13f46d94c6a032e828615a10fae8d4c7e`, accepted native B `e21b74fe0b56551008f78f9f2946cd2a0f9c19ce`.

The profile emitted 812 catalog-valid records: 406 complete intervals at 36 source labels, zero unmatched begins and zero orphan ends. Each event used the actual profile child PID and a consistent positive monotonic frequency. No unexpected stderr occurred. This is diagnostic evidence, not acceptance evidence or a speedup claim. One pair, profile overhead, second-run ordering and a separate bounded stream adapter prevent a stable performance claim. The service runner is different.

## 2. Measured target and actual caller applicability

| Original source boundary | Count | Inclusive seconds | Meaning |
| --- | ---: | ---: | --- |
| Test-AgentInstructions.ps1:6283 | 35 | 6.412808 | Metadata extraction calls Get-MarkdownParseContext |
| Test-AgentInstructions.ps1:6154 | 17 | 2.646960 | Header-intent checks call the same parser-context helper |
| Test-AgentInstructions.ps1:3927 | 7 | 1.336722 | Operative-content checks call that helper |
| Combined three disjoint call families | 59 | 10.396490 | About 82.6% of the profiled child |
| Test-AgentInstructions.ps1:3405 | 59 | 2.849129 | Nested actual parser-process invocation, already included above |

About 7.547361 seconds of the measured parse-context calls lies outside the parser-process interval. This includes surrounding PowerShell work and instrumentation; it does not prove that one conversion loop, JSON decoding, debugger, or Node startup alone caused that remainder. Do not add nested metadata/endpoint intervals to this table. The previous full diagnostic separately showed 41 real author caller invocations totaling 478.28 seconds, so the measured per-child work is a relevant optimization target.

The function at 3186 validates the entire parser result before returning structural objects. Keep all those checks. Current header-intent and metadata functions independently split CRLF/CR/LF, copy the line array, blank exact closed leading front matter, join using LF and pass the original line count. These normalizations are textually equivalent for the closed-front-matter branch; they are not equivalent policies for unclosed front matter. Header intent uses its existing marker test there, while metadata returns its existing failure. Preserve both.

The actual orchestration at 8116/8121 evaluates current/prior header intent, retains document/parent content in the local document record, and later endpoint checks call strict metadata readers. A prior content value discarded for initial metadata coverage must remain discarded. This establishes a concrete opportunity to pass already validated structural context along one document's existing data flow. It does not establish that all 59 calls have identical inputs or that all 17 intent parses can be removed. Operative-content parsing strips comments and is a different transformation; do not merge it merely because raw document content is equal. No runtime input-content census was collected, so cache-hit counts and prospective savings remain unmeasured.

The current cancelled service run remains a merge blocker. This proposal neither changes that rule nor claims that the measured local savings would fit the service limit. The earlier [activation decision](../../TF68-round5-activation/REPORT.md) remains separate.

## 3. Reasonable options before scoring

- **A — Keep the current implementation.** Preserve all checks and wait for a permitted hourly retry. A green result is possible, but the repeated timeout remains unaddressed.
- **B — Measure smaller internal spans first.** One new bounded diagnostic could split JSON/schema/construction work. It provides finer evidence but does not remove the demonstrated repeated parsing.
- **C — Pass validated structural context along one document's existing validation flow.** Reuse only exact normalized parser text and line count, within one invocation and one owned current/prior document record. Keep independent policy/date checks and fresh parsing for ordinary direct helper calls. Do not introduce a global lookup cache.
- **D — Add a global or script-level validated-context cache.** This may reuse more calls, but adds cross-case mutation, runtime/parser freshness, aliasing and memory hazards.
- **E — Cache only raw parser JSON, then repeat validation.** This retains repeated schema validation and targets only the measured 2.849-second subprocess portion; it still needs freshness and memory controls.
- **F — Change the internal JSON/schema loops without reuse.** It might reduce the larger remainder, but the individual loop costs have not been measured. It affects adversarial parser-output validation more broadly.
- **G — Use a persistent or batched Node parser.** Preserve every check but add framing, lifetime, cancellation and per-request failure isolation. It targets only part of the measured work and changes process isolation.
- **H — Run immutable author cases in a small independent-process queue.** Each case must have an independent checkout, exact checker bytes, B/H, clock and native-result assertions. Shared mutable fixture execution is excluded. It can improve wall time but leaves repeated work and adds scheduling/resource variance.
- **I — Partition whole fixtures across independent workers.** Preserve all scenarios and combine truthful results. It duplicates setup, complicates failure collection and has not been measured on the service runner.
- **J — Change the private clock mechanism or reuse PowerShell runspaces.** Neither is established as the internal cause; both affect isolation and clock/error controls.
- **K — Change deployment sequence, runner size or timeout settings.** Reuse the existing activation analysis. No available YAML timeout override has been shown to change the service's actual 20-minute limit; more CPU or bootstrap is not a guaranteed fix.
- **L — Remove cases, skip parsing/schema/snapshot checks, reuse successful verdicts or waive failed CI.** Ineligible. These change required correctness or owner policy.

## 4. Unique weighted rubric

Scores are 0–10. Weighted total is the sum of score times weight divided by ten. Correctness and security take precedence over churn.

| Criterion | Weight | Detailed assessment |
| --- | ---: | --- |
| Security and failure freshness | 30 | Retains bounded readers, full parser-output validation, exact input/runtime trust, native failures and no stale successful verdicts; avoids shared mutable state |
| Semantic and fixture equivalence | 25 | Preserves metadata-intent versus strict-validation distinctions, B/H/current/proposed/local/date behavior, output ordering and all negative controls |
| Measured-target fit | 20 | Acts on the demonstrated 59 parse-context calls or a measured cost; penalizes unmeasured service guarantees and speculation about individual loops |
| Contributor completion and maintenance | 15 | Reduces avoidable work while keeping clear failures, maintainable ownership and an understandable validation path |
| Verification precision | 7 | Supports differential outputs, counted parser calls, mutation/freshness controls, identity guards and bounded comparable measurements |
| Scope and implementation cost | 3 | Rewards bounded reviewable changes after the higher priorities; does not justify a weaker contract |

## 5. Complete score table

| Option | Security 30 | Semantics 25 | Target 20 | Usability 15 | Verification 7 | Cost 3 | Total /100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 10 | 10 | 2 | 2 | 9 | 10 | 71.3 |
| B | 10 | 10 | 6.5 | 5 | 10 | 8 | 84.9 |
| C | 9.5 | 9.5 | 8.5 | 9 | 9 | 7 | 91.15 |
| D | 5 | 6 | 8 | 6 | 5 | 7 | 60.6 |
| E | 8 | 8 | 5 | 6 | 7 | 7 | 70 |
| F | 8 | 8 | 6 | 7 | 7 | 6 | 73.2 |
| G | 6 | 7 | 5 | 5 | 6 | 4 | 58.4 |
| H | 8 | 8 | 7 | 7 | 7 | 5 | 74.9 |
| I | 8 | 8 | 6 | 6 | 7 | 4 | 71.1 |
| J | 6 | 6 | 3 | 5 | 6 | 5 | 52.2 |
| K | 8 | 9 | 2 | 3 | 5 | 7 | 60.6 |
| L | 0 | 0 | 1 | 1 | 0 | 9 | 6.2 (ineligible) |

The scores assess the stated constrained options, not a claim that an unimplemented optimization has already passed. C receives less than ten for measured fit because actual reusable-call count and service benefit remain unmeasured. B is a sound fallback if the explicit ownership proof fails; it is not required merely to identify a particular internal loop before eliminating an already unnecessary duplicate parse. D loses points for its cross-case hazards even though it may have a larger hit rate. F is penalized for changing validation internals before their costs are isolated.

## 6. Selected proposal — C, explicit per-document context handoff

1. Keep all current acceptance and failure rules.
2. Add one private representation for the exact metadata parser input. Store the normalized parser text, line count, original line data and validated structural context.
3. Let the document owner create that representation once. Use it only for that document value in the current validator invocation.
4. Pass the representation from the existing intent check to the later strict metadata check only when the normalized text and line count match exactly.
5. Keep current and prior document representations separate. Drop the prior representation when initial metadata coverage drops its content.
6. Keep all date, version, rendered-content and transition checks. Reuse structural data, never a policy verdict.
7. Keep direct helper calls fresh. Keep unclosed-front-matter behavior and operative-content transformations unchanged.
8. Test output equivalence and parser-call reduction. Stop if the ownership or input identity proof fails. Do not add a global cache as a fallback.
9. Measure the actual changed caller with the same bounded case before claiming a speedup. Require ordinary final acceptance and actual service success before delivery.

### Implementation constraints for root review

Prospective product scope is `Test-AgentInstructions.ps1` plus focused persistent regressions in its existing SelfTest owner. No workflow timeout, fixture-clock, runtime, dependency, generator or protected-guide edit is implied. Genuine touched-function/script metadata is required. The source/peer common validator obligation remains paired; actual implementation and later accepted TF landing must be rebound before any PS carryback. Root owns applicable counters and release.

Use explicit local ownership rather than a dictionary shared by scripts, documents, fixtures or child processes. A context may not come from an arbitrary external caller, stale object, different content or different line count. Consumers must not mutate the owned structural snapshot; do not reuse the public mutable `MarkdownParseContext` returned by an earlier metadata call after another caller can modify it. A practical implementation can keep an unexposed owned context in the orchestration and expose only isolated read data to consumers. Audit the actual object graph and aliases before choosing its representation.

Consolidate only the existing identical normalization steps. Do not change newline equivalence or front-matter policy. Preserve all safe input acquisition, runtime availability and parser failure behavior on fresh context creation. Direct helpers and test overrides continue to create fresh contexts; a changed parser/runtime on a subsequent independent call must still fail. No context survives an invocation, checker reload, fixture or script override. If a hook deliberately changes parser/runtime between the two supposed consumers, the handoff must be invalidated or disabled; do not infer freshness from raw document equality alone.

Memory must be bounded. Prefer releasing each owned context as soon as its last consumer completes. If the current two-pass document orchestration retains contexts, impose a bounded retention budget and fall back to the existing fresh parse when that budget is exhausted; do not reject an otherwise valid document or skip validation to meet the budget. The exact representation/budget must be reviewed before execution. This is a performance fallback, not a new content-admission limit.

### Meaningful validation after implementation release

- Prove actual parser text and LineCount identity for empty input, LF/CRLF/CR, closed front matter, unclosed front matter, comment/fence/quote/list/nested metadata, optional-to-required coverage and current/prior content differences.
- Compare exact outputs and failures against original helpers. Retain every schema rejection, duplicate/overlap/range/type check and malformed/oversized parser-output control.
- Use a real call-count discriminator: matching owned context removes a redundant parser invocation; changed text, changed line count, separate document ownership or a fresh direct call must not reuse it. Test discarded initial-coverage parent state.
- Mutate returned context data and prove another consumer cannot inherit that mutation. Prove no context crosses fixture/child/script boundaries. Prove parser/runtime missing or failing on a new call is not hidden. Preserve override-based tests.
- Exercise retention exhaustion and normal parsing afterward; failures must remain truthful and bounded. No policy verdict may be cached.
- Run the same actual original/changed immutable author case with checked clocks and exact stdout/native exits, followed by the affected metadata/placement/classification tests on Windows and Linux. Keep necessary full-file parser/analyzer and one root-coordinated required final gate; avoid redundant aggregates.
- Report measured call reduction and complete elapsed times without extrapolating a guaranteed hosted margin. Run required hosted CI/reviews normally; the present cancelled service result still prohibits merge.

If these constraints make explicit handoff larger or less reliable than stated, return a revised decision before broadening scope. No implementation has been made or automatically authorized by this diagnostic packet.
