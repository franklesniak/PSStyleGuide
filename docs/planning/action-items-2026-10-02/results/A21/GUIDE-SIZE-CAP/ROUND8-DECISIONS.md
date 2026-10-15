# PR248 round8: separate finding decisions proposed to root

These are recommendations, not implementation or execution grants. H remains95088f1c381ddcd4b00d568e990af90ae78c4e79. B remainsb20029e5bee8a60169014feb3a2e71af85f5be09. No source changes or target tests occurred. Scores below are engineering judgments on proposed designs, not measured performance or probabilities.

## Finding1: remaining PowerShell semantic-checker guide cap

### 1. Validate

Codex4282813350/review5532910593 and the out-of-diff consideration in Balanced Copilot5532924232 report the same issue. Both reviewed exact H. They are one finding, not two repairs.

The static cause is confirmed. PS build.yml430 runs Test-StyleGuideArtifacts.ps1. Its fixed PowerShellExamples role invokes Test-BlankLineExamples.ps1 at606 and requires native exit0 plus its one exact success line. The semantic checker at265–266 refuses a stable STYLE_GUIDE.md larger than262144 bytes, before semantic evaluation. Thus a guide of262145–524288 bytes admitted by the new instruction-validator role still fails this supported build path. This author ran no native reproduction. Root separately reproduced the defect with the exact H checker under PowerShell7.6.5: the published148759-byte PS guide passed all semantic mutations; the same guide padded with an inert HTML comment to262145 bytes failed with the exact262144-byte refusal. Its retained RESULT.json and raw streams are joined in EVIDENCE.json. That reproduction proves the checker bug, not the full supported Linux artifact chain. It does not show that current small-guide CI failed for this cause.

The immutable source census covered all51 tracked executable/config source files in each repository. It searched direct guide references, semantic/artifact callers and both limit values, then inspected the actual relevant readers. Current TF93520aa9 has a152868-byte guide and no Test-BlankLineExamples.ps1. Its TerraformRecovery role calls Test-StateRecoveryExamples.mjs, which reads the complete guide and extracts uniquely marked Bash examples. Do not add/run the PS checker against TF's guide. The earlier458620-byte A16 guide is TF data; it is not a valid PS blank-line semantic fixture merely because its size matches a regression boundary.

| Reader/caller family | Current source and limit consequence |
| --- | --- |
| Instruction validator and its stream/local/staged/revision readers | PS exact guide role524288; current TF still262144 pending selected foundation transfer. Other roles have distinct unchanged limits. |
| PS blank-line semantic checker | Independent262144 pre-read FileInfo admission, then existing strict-encoding ReadAllText; this is the missing PS caller. It is not a hard streaming or race-exclusion ceiling. |
| TF recovery semantic checker | Complete readFileSync of its guide; no262144/524288 admission check. Requires its real Linux/Bash semantics. |
| Artifact gate | Selects the language role, checks native/result contracts and child integrity; no separate256KiB guide ceiling found. |
| Generator | Complete source ReadAllBytes with its existing ordinary-path/identity/publication guards; no256KiB guide admission check found. Do not silently redesign its reader. |
| Exact-path verifier and artifact worktree digests | Inventory/identity/stream hashing roles; no guide-specific256KiB refusal found. These are not substitutes for semantic validation. |
| Generator test harness | Exercises complete payloads/encoding/identity; no lower guide admission ceiling found. Existing small fixtures do not prove the larger semantic-child route. |
| Markdown/nested/staged lint | Existing file discovery/delegation and complete file reads; no256KiB guide-specific check found. Their normal checks remain applicable. |
| Other numeric hits | Workflow parser dependency-file262144, workflow/JSON budgets, initializer5MiB manifests and parser-cache character budgets govern other inputs. They are not guide caps to raise. |

The existing Test-CiHelpers artifact-wrapper matrix substitutes Test-BlankLineExamples.ps1 with a fixed success/failure script. That is useful interface/integrity proof, but it cannot catch this real semantic-reader ceiling. The previous final-quality completeness conclusion missed this out-of-diff caller; its raw passed evidence remains historical and scoped. It is not whole-path512KiB acceptance.

### 2. Stakeholders and constraints

Guide authors and contributors need one honest supported size range and clear refusals. PS users need the blank-line copy-safety examples to remain checked. TF users need their distinct recovery/Bash semantics, not a false common-language substitution. CI/platform and QA engineers need a real Linux artifact-chain test and durable cap negatives. Reviewers, security engineers and the owner need the exact cap/trust model, unchanged side-effect/channel/Git protections and no false Windows artifact claim. Paired maintainers and history custodians need the final transfer reserved for common convergence plus necessary language exceptions. Cost/schedule stakeholders benefit from reusing existing tests and avoiding a new loader/controller. Privacy/backend/cloud roles receive no new data or access; existing no-credential fixture controls still apply.

Hard constraints: keep the complete canonical guide at least through524288 bytes; refuse above the selected cap; preserve semantic mutations and language dispatch; do not weaken unrelated readers, metadata, integrity, credentials or finalization; do not edit a product guide just to test size; do not label Linux artifact validation as Windows execution. Do not spend transfer12 or reset review clocks here.

### 3. Options listed before rubric/scoring

1. Leave the code unchanged because today's PS guide is small. Fails the promised supported size range.
2. Revert the instruction-validator cap to256KiB. Contradicts selected B95 and the actual larger-guide need.
3. Match the PS semantic checker's exact cap/diagnostic to524288; add durable boundary cases and a real supported Linux artifact-chain large-guide check. Preserve its current reader/encoding and trusted stable-file model. No new source path or module.
4. Also replace the semantic checker's stat/ReadAllText path with a bounded raw-byte reader and equivalent decoder. Adds a stronger actual-read limit, but introduces stream/encoding/BOM/exception compatibility work beyond the demonstrated admission mismatch. Needs its own parity controls within this decision if selected; not a one-constant patch.
5. Factor a shared cap/reader module used by validator and semantic checker. Adds a loader, selector obligation and maintenance surface without a current need for general configuration.
6. Run or import the whole instruction validator from the blank-line checker. Couples semantic checking to unrelated parser/bootstrap/catalog work and does not replace blank-line semantics.
7. Read only the selected example section or firstN bytes. Loses complete-source/EOF and later-marker ambiguity evidence.
8. Add a caller/env-configurable limit. Creates a new interface and user-error/security surface where one fixed role is selected.
9. Raise all reader/default limits. Weakens unrelated role boundaries and changes unselected contracts.
10. Remove/skip the semantic checker above256KiB. Drops the safety property precisely for the larger guide.
11. Apply the PS semantic role/checker to TF too. Wrong language semantics; current TF lacks that helper.
12. Add only a failing test or document the mismatch. Useful diagnosis, incomplete delivery.
13. Defer until a later product guide grows. Preserves today's CI but leaves the accepted capability incomplete and risks the final transfer slot. A genuine deferral would need the existing issue/scope process; it is not selected here.
14. Prune/split the normative guide to remain below256KiB. Reopens the rejected content/architecture choice and does not preserve the selected complete-guide target.

Option3 includes meaningful tests and caller census; those are not separate score bonuses or new architectures. Adding optional factoring/parameters to3 becomes5/8. Option4 includes3's end-to-end verification. Combinations that bypass semantics or reduce the supported complete guide violate the hard constraints regardless of effort.

### 4. Fresh finding-specific rubric

Scores0–5:0 absent/contradictory,1 poor,2 substantial gaps,3 workable with material limitations,4 strong with a stated limitation,5 meets the proposed source-level criterion. Total=sum(weight × score/5).

- End-to-end capacity correctness30%: all relevant supported callers admit the selected complete range and refuse excess.
- Semantic/security preservation24%: retain the language role, safety mutations, integrity and honest reader-bound claims. Additional hardening can improve this score, but cannot excuse semantic loss.
- Verification and regression detection20%: test the real path and distinguish constant, truncation, bypass and child-result defects.
- Compatibility and contributor usability14%: no new flags/setup or unintended input/encoding behavior; clear stable diagnostics.
- Scope and paired delivery8%: keep the finite coherent foundation and exact existing exceptions; avoid new loader/transfer coupling.
- Implementation effort4%: less work matters after correctness, safety and useful verification.

### 5. Scores before recommendation

| Option | Correct30 | Preserve24 | Verify20 | Usable14 | Scope8 | Effort4 | Total | Eligibility/uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 1. No change | 1 | 5 | 1 | 2 | 5 | 5 | 51.6 | Ineligible: incomplete range |
| 2. Revert256 | 0 | 4 | 2 | 2 | 3 | 5 | 41.6 | Ineligible: violates selected target |
| 3. Exact cap + real path | 5 | 4 | 5 | 5 | 5 | 4 | 94.4 | Existing pre-read model; actual tests pending |
| 4. Also bounded reader | 5 | 5 | 4 | 4 | 4 | 2 | 89.2 | Decoder/stream parity not yet demonstrated |
| 5. Shared new module | 5 | 4 | 4 | 3 | 2 | 1 | 77.6 | Extra loader/coupling |
| 6. Whole validator import | 3 | 3 | 3 | 2 | 2 | 2 | 54.8 | Still needs semantic contract |
| 7. Section/firstN read | 2 | 1 | 2 | 3 | 3 | 3 | 40.4 | Ineligible: incomplete source |
| 8. Configurable cap | 4 | 3 | 3 | 2 | 2 | 2 | 60.8 | New unnecessary interface |
| 9. All limits | 5 | 1 | 2 | 3 | 1 | 4 | 56.0 | Ineligible: unrelated weakening |
| 10. Skip semantics | 4 | 0 | 0 | 3 | 2 | 4 | 38.8 | Ineligible: loses safety checks |
| 11. PS role in TF | 1 | 1 | 1 | 0 | 1 | 2 | 18.0 | Ineligible: wrong language |
| 12. Tests/docs only | 1 | 5 | 4 | 2 | 4 | 4 | 61.2 | Ineligible as complete repair |
| 13. Defer | 1 | 4 | 1 | 1 | 2 | 5 | 39.2 | Capability and cap-slot debt |
| 14. Prune/split guide | 1 | 2 | 2 | 1 | 1 | 1 | 28.8 | Ineligible: end-state reduction |

Recommendation: option3/94.4. It corrects the demonstrated reachable mismatch and supplies the missing real-path evidence with the smallest compatible source change. Option4 is viable stronger reader work, not a necessary inference from a cap mismatch. Its extra stream/decoder semantics do not justify expanding this repair without evidence. Scores do not establish a native pass. If a real bounded-read/trust-model defect is later established, apply the full process to that concrete finding; do not claim option3 supplies a hard streaming ceiling.

### 6. Recommended implementation instructions

1. Keep the current exact H/B fixed until root selects a repair.
2. In the PS-only Test-BlankLineExamples.ps1, set the canonical-guide size check to524288 bytes.
3. Make its fixed refusal text report524288 bytes. Keep the existing complete text read and semantic/mutation logic unchanged.
4. Keep other limits and the artifact language descriptor unchanged. Do not add the PS checker to TF.
5. Add meaningful boundary/integration cases in the existing Test-CiHelpers.test.mjs. Include durable Linux-only cases that exercise the real artifact chain, not just an ad hoc manual qualification. Use the real PS semantic child for the new capacity cases. Do not reuse the success-script substitute as proof of that child.
6. Build private fixtures from the actual PS guide with its real compliant/non-compliant pair. Add inert UTF8 padding outside the pair to reach262144,262145,458620 and524288 bytes. Preserve the complete ending marker and exact byte count. Do not copy the TF guide into this PS semantic test.
7. Require each admitted size to pass the real PS checker and existing semantic mutations. Require524289 bytes to refuse with the exact cap diagnostic and no success line. Test a missing guide too.
8. Add an admitted large malformed-semantic fixture. Require the semantic failure to remain visible. This detects bypassing the checker for large inputs.
9. In those durable Linux-only artifact cases, prepare a fresh private repository with the real current artifact gate, generator, exact-path verifier and real PS semantic checker. Keep all four generated artifacts tracked. Use no credentials or network. The supported Linux CI route must execute these cases; a Windows-only run or permanent skip does not qualify them.
10. Regenerate and commit only that private fixture's expected artifacts before verification. Then run Test-StyleGuideArtifacts.ps1 on an admitted458620-byte PS guide and at the524288-byte boundary. Require native success, the actual generator result contract, committed artifact equality, unchanged sources/Git controls/channels and the existing final verifier.
11. Run the oversized and malformed large-guide refusals through the same artifact gate. Require failure before accepted publication. Preserve all failed fixture outputs. Do not enlarge existing time/output limits to make a case pass.
12. Keep full-chain and interface-fixture evidence distinct. The existing matrix with child substitutes remains useful for hostile-result/side-effect controls. It is not the new real-chain proof.
13. For the eventual TF foundation, keep its TerraformRecovery semantic route. Validate its large TF guide through its real supported Linux artifact path after the separate transfer release. Do not label Windows parsing or a PS fixture as that result.
14. Advance NOTES metadata only for the modified PowerShell script/helper scopes on the actual UTC finalization date. A suitable changed script version on2026-10-15 is1.1.20261015.0 from1.0.20261001.0; preserve historical fixture versions. Do not add metadata to JS files that have no such convention.
15. Run parser/PSScriptAnalyzer checks on modified PowerShell source and verify all applicable MUST/MUST NOT rules. Keep zero applicable Warning/Error diagnostics. Run affected durable tests and the normal complete hooks on final bytes. Do not repeat accepted unchanged tests without a new reason.

No new source file is proposed. Test-BlankLineExamples.ps1 and Test-CiHelpers.test.mjs are already exact maintenance selectors. Therefore this selection needs no classifier addition. A new standalone SelfTest/module would not be auto-selected merely by being a .ps1 under workflows; if the implementation later needs one, stop and assess its exact selector/caller scope first.

## Finding2: unnecessary object collection in the overflow refusal test

### 1. Validate

Codex4282813364/review5532910593 identifies SelfTest4473. Current source declares List[object], appends each success-stream item from Read-BoundedStreamData in the overflow branch, then checks only Count. STYLE_GUIDE163 summarizes specific generic types;2057 requires a specific T when known. AGENTS requires modified PowerShell to conform. The production reader declares OutputType(byte) and currently returns a byte array only after its complete limit check.

The negative test's required property is stronger than that normal output contract: any success-stream item before overflow refusal is a defect, including an incorrect type emitted by a future mutation. [Microsoft's OutputType documentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_outputtypeattribute?view=powershell-7.6) explains that the attribute is descriptive and is not checked against actual output. It is not runtime type authentication.

This is a confirmed avoidable collection/style ambiguity and an opportunity to state the negative assertion directly. It is not a demonstrated production read failure or a failed native hook. List[byte] would normally still detect output by nonzero Count, and an unconvertible value would fail conversion. Do not falsely claim that changing this one list necessarily permits a current false pass. However, typed Add can coerce values or replace the intended diagnostic with a binder error; it does not preserve a raw-type oracle. No captured values are actually needed.

### 2. Stakeholders and constraints

QA, code reviewers and security engineers need a negative test that catches byte and arbitrary-type success output without assuming the contract under test. Maintainers and new contributors need literal readable conformance, not an undocumented generic-type exception or needless accumulator. CI/platform engineers need the same exception/cleanup behavior on qualified PowerShell7.6.5. The owner and paired maintainers need a tiny common SelfTest correction with durable mutants and no new loader/transfer. Privacy/cloud/backend roles are not newly affected: no payload, credential, recovery operation or public interface is added.

Hard constraints: keep exact overflow exception validation; preserve finally Dispose; fail on any success-stream item; retain normal successful whole-byte tests and existing size boundaries; do not weaken errors or filter outputs by type. Do not change the production stream reader for this finding.

### 3. Options listed before rubric/scoring

1. Keep List[object] and explain the heterogeneous fault oracle. Preserves the present gate but leaves avoidable style ambiguity and unused values.
2. Change only to List[byte]. Minimal nominal type fix; adds conversion that the presence assertion does not need.
3. Check each item's exact raw byte type, then add to List[byte]. Preserves a raw type check but retains unused accumulation.
4. Remove the collection and throw a fixed test failure immediately for any success-stream item in the overflow branch. Keep the exact InvalidDataException catch and Dispose.
5. Replace the list with a Boolean presence flag set by the pipeline callback. Needs state/scope binding proof, but can preserve all item types without coercion.
6. Replace the list with an integer counter. Also preserves presence without retaining values, but needs more state than a zero-output contract requires.
7. Collect once with @(...), then check Length. Avoids a generic list but must prove that partial output is retained across the terminating expected exception; do not assume that assignment behavior.
8. Wrap items in PSObject/PSCustomObject records and use a specific collection. Unnecessary wrapping changes the fault observer and adds code.
9. Discard output with Out-Null and check only the overflow exception. Loses the no-partial-output discriminator.
10. Throw only when an emitted item is byte. Misses wrong-type success output.
11. Remove the overflow test. Loses a meaningful security regression control.
12. Change/waive the guide's generic-type policy or create a custom collector/framework. Unnecessary protected-policy or mechanism scope for this local test.

Combining3 with4 makes the raw type branch redundant:4 refuses every item. Combining4 with a list/counter adds unused state. A Boolean/counter could work, but supplies no result needed by this test. Options that filter or discard output violate the hard property.

### 4. Fresh finding-specific rubric

Use the same0–5 scale, with new criteria and weights:

- Any-output refusal34%: detect byte, null, numeric, Boolean, string and object output without depending on the advertised type.
- Raw observation and failure fidelity26%: avoid coercion, partial-output loss and misleading expected-error acceptance.
- Style/contract clarity18%: express the zero-output contract directly and comply without a generic waiver.
- Error and cleanup compatibility12%: retain the exact overflow catch and stream disposal, without changing production behavior.
- Focused verification strength7%: discriminate the actual defect with small deterministic controls.
- Implementation effort3%: prefer less change after all substantive criteria.

### 5. Scores before recommendation

| Option | Refuse34 | Fidelity26 | Clarity18 | Cleanup12 | Verify7 | Effort3 | Total | Uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 1. Object list/comment | 5 | 5 | 2 | 5 | 5 | 5 | 89.2 | Avoidable style ambiguity |
| 2. Byte list only | 5 | 2 | 5 | 4 | 4 | 5 | 80.6 | Coercion/binder diagnostics |
| 3. Type-check + byte list | 5 | 5 | 5 | 4 | 4 | 2 | 94.4 | Unused state/type branch |
| 4. Immediate failure | 5 | 5 | 5 | 5 | 4 | 4 | 98.0 | Native focused controls pending |
| 5. Boolean flag | 5 | 5 | 5 | 4 | 4 | 4 | 95.6 | Callback state/scope proof |
| 6. Counter | 5 | 5 | 5 | 4 | 4 | 3 | 95.0 | Extra state without useful count |
| 7. Array assignment | 2 | 2 | 4 | 3 | 2 | 5 | 51.4 | Partial-output/exception assignment unproved |
| 8. Wrapped records | 5 | 4 | 3 | 4 | 3 | 3 | 81.2 | Observer wrapping/unused data |
| 9. Discard output | 0 | 0 | 3 | 5 | 2 | 5 | 28.6 | Ineligible: no output oracle |
| 10. Byte-only filter | 2 | 2 | 5 | 5 | 3 | 4 | 60.6 | Ineligible: misses arbitrary types |
| 11. Remove test | 0 | 0 | 3 | 5 | 1 | 5 | 27.2 | Ineligible: loses negative control |
| 12. Policy/framework | 4 | 4 | 1 | 3 | 2 | 0 | 61.6 | Unnecessary larger scope |

Recommendation: option4/98.0. It observes any event before coercion and immediately fails the exact forbidden behavior. It removes unused state and the generic-type concern without a style-guide edit. The recommendation is not formal ASD-STE100 dictionary certification; the following instructions use short direct sentences and explicit conditions.

### 6. Recommended implementation instructions

1. Remove the List[object] declaration from Assert-StyleGuideCapacitySelfTest.
2. In its overflow pipeline callback, throw one fixed test diagnostic for any received item. Do not inspect or convert that item.
3. Remove the final Count condition. Keep the expected-overflow Boolean condition.
4. Keep the exact InvalidDataException type and exact overflow-message check unchanged. The new output failure must not be accepted as that exception.
5. Keep finally Dispose and all successful full-byte comparisons unchanged.
6. Advance only the changed script/function NOTES metadata under the existing current-UTC convention. On2026-10-15,1.17.20261015.0 for the script and1.1.20261015.0 for this function are suitable minor updates; use the actual finalization date if it differs.
7. Run the exact affected capacity test against the correct reader. Require success at all admitted sizes and the expected no-output overflow refusal.
8. In private fixed mutants, emit byte0, Int32zero, string0, Booleanfalse, null and a PSCustomObject before throwing the otherwise exact expected overflow exception. Require the new fixed output diagnostic for each actually delivered item. Verify callback entry, including the null fixture. A construct that delivers no item is an invalid output-mutant fixture, not a passing output test. No mutation with delivered output may be accepted as the expected cap-only refusal.
9. Add a nonzero output byte and a no-throw overflow mutant. Both must fail. Keep the existing old-cap, truncation and excess-byte controls.
10. Verify that the stream closes on successful, expected-overflow and emitted-output failure paths. Keep raw item types in the synthetic inputs; do not pre-cast every mutant to byte.
11. Run parser/PSScriptAnalyzer and mandatory conformance checks for the changed PowerShell source. Run the normal complete hooks once on the final combined bytes. Do not change Read-BoundedStreamData or create a new public test framework for this finding.

The existing SelfTest path is already selected by accepted maintenance classification. No new source path or classifier addition is proposed. The current output controls can be exercised through the existing exact-function synthetic fixture/mutation route; record native results honestly after root release. No such controls ran in this proposal task.

## Combined delivery and fixed limits

The recommended PS repair adds only two product paths to the existing four-file PR: Test-BlankLineExamples.ps1 and Test-CiHelpers.test.mjs; SelfTest is already in scope. The whole PR would have six changed paths if implementation follows these recommendations. Keep the19 classifier registrations and other validator bytes unchanged. No product guide/generated artifact edit is part of these test repairs.

Root must read/select before implementation. The eventual repair needs affected raw controls, actual supported Linux artifact-path evidence, parser/PSSA/MUST conformance, one normal complete final-byte hook pass, normal commit, exact accepted-B/candidate-H modes and current input remote/CI review. Existing unrelated passes remain reusable within their original scope. Both round8 review results are terminal, but changed input needs a fresh ninth pair after publication, with the original deadline2026-10-16T22:53:27.970214Z. No reviewer request occurs here. Same-PS repair adds no repository transfer; A07/A21 stay11/12 and reserve12 remains held for the coherent TF foundation. Do not broaden/waive that cap or claim recovery/catalog/human acceptance.

## Root selection and scoped implementation release

Root selected F1 option3/94.4 and F2 option4/98.0 at 2026-10-15T12:36:33.523352+00:00 after displaying each finding's full option list, distinct weighted rubric and complete score table to the owner. Root read the complete proposal/report, independently recalculated all26 totals and verified all29 seal rows. Root's actual two-case checker reproduction is at C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A16-gate-a-20261013/a21-round8-root-cap-reproduction1/RESULT.json (3771B/06a66d83945f6fc2a1820a54f01bfa7c6ad426ae13cef5577d5ddc897ec75386):148759B passes,262145B fails at old cap. No owner input is needed.

Release one product writer, /root/a09_ps_carryback_author, on C:/Users/flesniak/.codex/worktrees/a04-whole-caller-downloads/PSStyleGuide, branch codex/a21-guide-document-cap, exactH 95088f1c381ddcd4b00d568e990af90ae78c4e79/B b20029e5bee8a60169014feb3a2e71af85f5be09. The checkout was clean immediately before this release. Allowed new edits: .github/workflows/Test-BlankLineExamples.ps1, .github/workflows/Test-CiHelpers.test.mjs and .github/workflows/Test-AgentInstructions.SelfTest.ps1. Preserve the existing other three PR files byte-exact; six total PR paths are expected. Preserve applicable metadata, exact selectors, language dispatch and all existing limits except the selected PS guide admission cap. No product guide/generated-output changes.

The author may implement the selected repairs and run meaningful local affected controls/parser/PSSA on final source with the existing qualified runtimes. Durable Linux-only real artifact-chain cases are mandatory; Windows results cannot substitute. Use only existing test mechanisms/timeouts; do not widen limits, start reviews or make public/Git commit/push/staging changes. Provide raw outputs, complete source diff/identities and clear Linux pending status if no local supported Linux host exists. Root owns normal full-hook run, commit, five committed modes, publication, fresh round9 and hosted/Linux evidence. No merge before all current gates pass.

Private implementation evidence directory: C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A16-gate-a-20261013/a21-round8-repair1. Preserve current round8, inherited deadline2026-10-16T22:53:27.970214Z and transfers11/12. The same-PS repair spends no transfer. Any new material finding requires its own full decision before edit. Preserve the first final-quality packet as historical evidence; its completeness conclusion does not clear these two later findings.
