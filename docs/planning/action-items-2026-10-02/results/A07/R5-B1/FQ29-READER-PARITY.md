<!-- markdownlint-disable MD013 -->
# FQ29: Preserve equality of embedded reader helpers

Copilot optional drift comment4226363769

The four helper groups are actually identical today, after removing only their embedding indentation and canonicalizing the trailing newline:13559B/SHA1f2af9bb5e5c2946c7b1019927fe011709960ed92d8da85a662dd2a27a7ab0c8 on immutable32c. Ranges: setup391-692 and777-1078; dedicated393-694 and779-1080. Each group includes Read-SetupJson, nested Assert-UniqueJson, Assert-SetupShape and Read-SetupRuntime.

“Nothing enforces that” and “one copy can silently drift” overstate the gap. Test-CiHelpers.test.mjs:1957-1969 already deep-compares both workflows' complete retained step objects, omitting only the coding aggregate. A one-copy edit in either workflow therefore fails that pure maintained test. New actual-body malformed/positive/runtime/bound cases also exercise both sites and both files. The uncovered comparison is **detection versus runtime within the same workflow**. A coordinated edit to both detection copies can retain cross-workflow equality while differing from both runtime copies; behavioral coverage need not expose every such future textual change. This is a valid optional finite maintenance improvement, not a demonstrated current functional divergence or a replacement for the LF repair.

The owner process covers reviewer comments on product code, so the limited valid improvement receives the following distinct options/rubric/proposal. It remains optional and does not manufacture a second material correctness HOLD.

Stakeholders: maintainers and contributors need safe synchronized edits and easy failures; independent quality/QA need an assertion with meaningful mutants; security/agent/CI operators need no candidate-script execution in privileged setup; PS/TF owners need the same small common test without loader/trust-root expansion; audit/recovery users need unchanged admission/native behavior and truthful coverage. Documentation/UI/localization, cloud service settings and human operational approvals are unchanged, so they do not require separate controls. Existing guide rules already cover input trust/private contracts; no secondary protected-guide edit is warranted.

## Options, before rubric and selection

A. Add a pure four-group equality assertion inside the existing maintained dedicated-preparation parity registration. Extract finite group text from the four parsed run strings, remove only embedding indentation/line-ending framing and compare. Preserve all native behavior tests. No new registration/native call.
B. Keep current cross-workflow equality and behavioral coverage; explain its scope accurately in the response. Correct current behavior, but leaves the narrow cross-site invariant unguarded.
C. Extract a reviewed shared script acquired from a separately authenticated accepted/default revision, with complete authority/hash/path closure and historical fallback handling. Potentially safe but adds acquisition ordering/trust roots and breaks ordinary old checkout assumptions unless fully redesigned.
D. Write a shared helper from trusted inline workflow text into private staging, then load only that qualified file. No untrusted sourcing, but adds a writer/loader phase, ownership/literal-path/cleanup and PowerShell MUST obligations.
E. Generate both workflows offline from a checked-in canonical helper during normal development/build; maintain zero-drift generation controls. Avoids runtime sourcing but adds durable generator/template/artifact scope for four fixed copies.
F. Dot-source the helper from the untrusted PR checkout. Removes copies but crosses the privileged workflow trust boundary; ineligible regardless of score.
G. Add more runtime/property behavior cases without textual equality. Helps semantic proof, but cannot ensure exact four-copy identity and adds child/runtime cost. CombiningA withC/D/E collapses into a larger refactor;A already retains existing behavior tests.

Hard constraints: never execute/dot-source untrusted head helpers; retain existing admission/credential/native/capability/publication behavior and all behavior tests; no guide/settings/trust-root expansion under the small test option; use finite exact extraction that fails on missing/duplicate/ambiguous boundaries; no native calls or registrations added byA. All scores are design judgment, not executed proof.

Unique drift rubric, scale0-5:0 fails,1 substantial unresolved gap,2 broad redesign/proof burden,3 partial invariant or added surface,4 complete with minor integration cost,5 complete in existing scope. Weighted total=sum(weight*score/5).

- I, identity regression detection40: catches coordinated stage drift, missing groups and exact reader changes.
- T, trusted bootstrap preservation30: no new privileged executable path/authority or historical loader dependence.
- M, sustainable maintenance15: bounded implementation, failure diagnostics and low new lifecycle burden.
- U, contributor clarity10: a new editor can understand and repair an equality failure.
- C, change/execution cost5: minimal source scope and no extra native activity. It cannot outweigh safety.

| Option | I40 | T30 | M15 | U10 | C5 | Total100 | Limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A bounded pure four-group assertion | 5 | 5 | 5 | 5 | 4 | 99 | Extractor and meaningful controls still require implementation review. |
| B retain existing tests | 3 | 5 | 5 | 4 | 5 | 82 | No explicit detection/runtime identity invariant. |
| C trusted shared-script acquisition | 4 | 4 | 2 | 3 | 1 | 69 | New trusted-revision bootstrap/history/path lifecycle. |
| D inline staged shared helper | 4 | 4 | 2 | 2 | 1 | 67 | New writer/loader phase and cleanup obligations. |
| E offline generation | 4 | 5 | 2 | 3 | 1 | 75 | Durable template/generator/artifact scope. |
| F untrusted head sourcing | 5 | 0 | 3 | 4 | 1 | 58 | Ineligible trust-boundary violation. |
| G behavior expansion only | 4 | 5 | 3 | 4 | 2 | 81 | No exact identity guarantee; extra native cost. |

**Selected proposal A99 for root review.** Keep production helpers embedded. Add the small assertion in the existing parity test; no new framework or production file. Root may adopt the optional improvement through the existing selected-source process; no repair is executed here.

Controlled implementation and meaningful tests:

1. Read the same two parsed workflow jobs already used by the parity test.
2. Select exactly one detection step and one runtime step per job by existing fixed names.
3. Extract exactly one complete helper group per selected run string. Bound it from the line declaring Read-SetupJson to the actual caller line after Read-SetupRuntime; require exactly one start/end and all four function declarations. Missing/duplicated/ambiguous text must throw.
4. Remove only the common embedding indentation and normalize line endings/trailing delimiter newline. Preserve literals, comments, internal indentation, help, parameter/output contracts and order. Do not normalize arbitrary whitespace, parse/evaluate PowerShell or trim message values.
5. Compare all four extracted groups against the first. Include workflow/site in mismatch diagnostics. Keep existing full-step parity and actual-body tests.
6. Add pure copied-string controls inside the same registration. A single-copy substantive literal change must fail. A paired detection change in both workflows must also fail while detection-pair/runtime-pair equality still holds. For example, replace the exact literal "-AsHashtable -Depth 64 -ErrorAction Stop" with "-AsHashtable -Depth 63 -ErrorAction Stop" in only the two copied detection strings, requiring exactly one replacement per string. This proves the new cross-site assertion adds value beyond existing cross-workflow equality. A missing/duplicate boundary must fail closed.
7. Root must syntax-check the changed complete JS and run the maintained pure parity registration/aggregate as part of its already required final validation. Existing case/native-dispatch counts stay unchanged. Tests/mutations above are proposed, not executed by this reviewer.

No runtime dot-source/shared head import is proposed. Safe common-file alternatives need a separate full trust-root/order/history design before implementation; they are not prerequisites for closing optional feedback.

Root accepted the bounded A99 proposal after reading the existing whole-step parity assertion. All options, detailed rubric, scores and selected instructions were displayed before editing. Sole writer root may change only Test-CiHelpers.test.mjs in B. Native/aggregate/current-head CI remain pending. This is an exact-copy invariant test with paired-stage drift controls, not a substitute for behavioral validation.

Implemented in the existing registration. Root1a3d04 ran the exact maintained parity test with qualifiedNode24.18.1, test-isolation none:1pass/0fail/0skip, including single-copy, paired-stage, missing and duplicate boundary controls. WholeJS syntax passed. [Raw TAP](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-R5-B1-implementation-20261007/fq27-root-validation/fq29-parity.stdout.tap). Driver SHAd1145d0a38966f66d15f1f3667f7fb38951df7bbb54f1d67e27d89f4e6734e06. Full aggregate/required gates remain pending.

Final implementation and validation checkpoint, 2026-10-09: commit cba3ef736167d402a3b12a764669d51034494df0 includes the tested driver blob5c5403264b0475dd2245dbf410c0bfff7a999292 with the SHA256 above. The complete current-reader Linux selection passed90 tests; the Windows aggregate passed298 tests, skipped337 Linux-only tests and failed0. All11 configured hooks passed through Python3.12.10 `pre_commit run --all-files --show-diff-on-failure`; the normal Husky commit also passed. Windows used Node24.18.1 and PowerShell7.6.5; the qualified Linux image used Node24.18.1 and PowerShell7.6.3. Independent final local quality passed on the committed bytes. Current-head Copilot review5466544660 used Balanced and generated no new finding; it still lists the original thread pending its reply and resolution. Hosted CI now reports24 successful check jobs and4 conditional skips. The PR body carries this decision summary. Thread closure, final merge readiness and paired delivery remain separate gates.
