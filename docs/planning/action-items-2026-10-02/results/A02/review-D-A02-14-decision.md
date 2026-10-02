<!-- markdownlint-disable MD013 -->
# D-A02-14: Match metadata placement policy and remove unsupported migration behavior

**Decision prepared before implementation:** source mismatch, all 13 placement characterizations and the complete native consumer census are inspected. This is the single canonical D-A02-14 record. The completed evidence supports the selection below. Parent verification/publication and writer release remain required; no implementation acceptance is claimed. Requested route: gpt-6-astra/high; effective settings unavailable. No product/planning/native changes, tests or descendants were performed by this decision author.

## 1. Validate the coupled finding

Native PS docs.instructions.md blob `0b0c1ddc83938cfa9706418d45f619b1bfa03ffd` at `48f4d8a36c8faceee12afac78aaecea0d176125d` and TF blob `4a8f2addc02af857928205199b66cf3918ae9a82` at `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c` have identical placement clauses 102–107. [PS policy](https://github.com/franklesniak/PSStyleGuide/blob/48f4d8a36c8faceee12afac78aaecea0d176125d/.github/instructions/docs.instructions.md#L100-L107) and [TF policy](https://github.com/franklesniak/TerraformStyleGuide/blob/06ad4f7c9b6847028cafdacf1ae55128d0f2d56c/.github/instructions/docs.instructions.md#L100-L107) require document-level metadata. They permit a direct bullet list and impose conditional section placement on documents that already use a Metadata section. They do not universally require that heading.

PS Get-DocumentMetadataContext unconditionally requires exactly one early H1 and a Metadata H2 immediately after the H1/required Version. Its function text is unchanged from native 48f4 through PR fe3d673 and frozen validator SHA256 `da64afc90f005280f218569fd37a7a8eeb6097db0ee9738e25162671f9699f73`. The mismatch predates A02, whose discovered-document consumer expands the affected scope. Exact source/caller/history evidence is in the coordinator-integrated [heading-policy-compatibility.md](heading-policy-compatibility.md) (scratch source A02-[heading-policy-compatibility.md](heading-policy-compatibility.md)).

A02's heading-mismatch-reproduction.ps1/.json/.log uses that frozen actual helper and locked parser. Both headed fixtures pass. Otherwise identical direct-list fixtures, with required Version and without Version, fail. Invalid placement and duplicate headed/direct controls also fail, currently through early heading rejection. Those negatives do not prove that a future direct-list branch retains duplicate detection; implementation must test that separately. Environment: PowerShell 7.6.5, Node 24.18.1, markdown-it 14.3.2. This decision author read the evidence and did not rerun it. The coordinator-integrated [heading-policy-reproduction.json](heading-policy-reproduction.json) records these outcomes; [D-A02-14-evidence-summary.json](D-A02-14-evidence-summary.json) identifies the worker source JSONs and exact native inputs for integration without machine-local input-path authority.

### Complete placement boundary

The repair must implement the actual placement contract, not only delete one H2 test:

- Exclude leading YAML front matter from body-line counting. Retain strict delimiter and parser bounds.
- An H1 within body lines 1–30 selects the after-H1 branch. One optional Version paragraph can intervene, including for a document whose caller does not require Version. Keep document-specific mandatory Version requirements distinct from this optional-placement rule.
- When no H1 is within that window, metadata belongs at body start or immediately after the leading markdownlint-disable directive. A later H1 must not retroactively change that anchor.
- The first 30 test selects the H1 branch. It is not a separate policy mandate that every metadata field after an H1 at line 30 fit before that same cutoff. Preserve byte/process bounds; do not substitute an unsupported field-line limit.
- A Metadata section, when used, must meet its conditional H1/Version/first-H2 rules. Direct metadata must be a real document-level bullet list. Fenced, quoted, nested or example text cannot supply fields. Placement rules must not silently accept prose between the anchor and metadata.

Both native helpers also reject absence of an early H1; TF is therefore evidence for its useful direct-list branch, not a complete placement oracle. PS's false RequiresVersion branch additionally skips optional-Version handling. The extended actual-PS-helper characterization confirms rejection of optional Version when not required, both frontmatter-title no-H1 fallback variants, late-H1 fallback, and H1-at-body-line 30 followed by adjacent direct or headed metadata. Of 13 cases, two intended-valid headed cases pass; eight policy-valid forms fail; three invalid-placement/duplicate controls fail through the current early guard. Generic title/lint obligations are separate: the native markdownlint config enables default rules, while official [MD041 documentation](https://github.com/DavidAnson/markdownlint/blob/main/doc/md041.md) permits a YAML frontmatter title without H1. Metadata fallback therefore has a concrete title-compatible use. Do not disable lint rules or historical-artifact-specific H1 requirements to implement metadata placement.

### Reconcile D10, current consumers, and independent controls

D10 says the native dependency document's direct list lacks the “correct heading” and admits its first governed state through a known-prior-validator exception. That describes current parser behavior, not a normative requirement. Adding an optional heading is legal; calling its absence policy-invalid is not supported by the placement clauses. D14 supersedes that premise explicitly.

The exact Git inventory in [D-A02-14-native-coverage.json](D-A02-14-native-coverage.json) covers all 24 native Markdown/MDC paths: 11 already covered (nine exact paths plus two ADRs), nine active exemptions, one newly explicit versioned STYLE_GUIDE.md, and exactly three newly discovered nonversioned paths eligible for the D10 caller:

| Native path | Blob | Header form seen in exact source | Policy-conformant parser result |
| --- | --- | --- | --- |
| .claude/commands/review-loop.md | 8f361e184eef8b292370d1d6e5b00425ab8226c2 | Front matter, H1, Metadata section | Current PS and unchanged TF helpers pass; date 2026-09-22 |
| docs/P1-SUPPLY-FREEZE-v1.md | fc3fb7b657c62702f8b77b196735ff6a458c89e5 | H1, Metadata section | Current PS passes, date 2026-09-30; TF algorithm passes only after separately labeled typed-decoder boundary adaptation |
| docs/dependency-maintenance.md | 34c9dec3cd9f640fd3a8346583fe8b1569056fb8 | H1, direct field list | Current PS fails heading guard; unchanged TF helper passes, date 2026-10-01 |

STYLE_GUIDE.md blob `21bbb515429eb5fdac47f14128a95d5fd55122aa` is versioned and outside D10's nonversioned invalid-parent branch; both unchanged native TF and current PS helper characterizations pass its actual 2.23.20261001.0 header; it is not a D10 consumer. An H-only new path has no B content and never needs D10's invalid-existing-parent accommodation. The three-path census, not one convenient file, bounds the removal question.

TF's unchanged helper fails P1-SUPPLY at its existing timestamp-coercion/malformed-prose parser boundary. A separately labeled characterization changes only its two parser-output decoder sites to the already-selected PS bounded string-preserving decoder; all four exact native documents then pass. Current PS already has that decoder and passes P1 without adaptation. These distinctions are recorded in [D-A02-14-evidence-summary.json](D-A02-14-evidence-summary.json), with worker JSON hashes and input identities. All four source hashes were independently matched to native Git objects. This is not a whole TF runtime pass or a complete fallback oracle.

The evidence identifies no remaining real D10 invalid-parent consumer at this exact native B once the unsupported direct-list rejection is repaired. That conclusion uses the whole three-document census and actual parser outcomes, not a generic claim that historical migration guards are unnecessary. The selected implementation must still prove those same parents pass ordinary comparisons after repair.

Keep three controls separate:

1. D10 nulls an invalid metadata parent when no baseline manifest exists, using a known prior validator/catalog assumption. Remove it only if the complete actual consumer evidence shows no remaining need after policy-conformant parsing.
2. F1 permits genuine promotion from an existing validated baseline exemption. It still needs trusted prior exemption data and the known-governed/ADR exclusion. A malformed previously governed parent must remain a failure.
3. F3 initializes the classification table only for the exact reviewed PS B/validator/category mapping. Its separate initializer, hash input and native controls remain required even if D10's use of that hash disappears.

Current docs/dependency-maintenance.md differs from native B only by adding Metadata plus changing Last Updated from 2026-10-01 to 2026-10-02. After a conforming parser, that candidate-only formatting has no identified A02 correctness purpose. Decide its retention/reversion explicitly; do not describe an optional section as a required repair or rewrite published history.

## 2. Stakeholders

- Authors, newcomers and documentation consumers need both permitted forms and reliable placement/duplicate diagnostics. They should not reformat policy-conformant documents to satisfy an accidental consumer restriction.
- Both maintainers and the owner need the governing policy preserved, the mistaken D10 premise corrected openly, and the remaining guards distinguished. Protected-policy authority is ungranted and is not needed for a policy-conformant code repair.
- Reviewers, independent-quality engineers and auditors need a complete native coverage census, truthful historical evidence and negative controls that reach the new branches rather than failing earlier for unrelated reasons.
- Security and supply-chain owners need the parser to remain bounded, typed, document-level and inert. Broad invalid-parent suppression or confused classification authorization would remove useful enforcement.
- Windows/Linux PowerShell and CI/platform maintainers need the existing parser/process interfaces and versioned/unversioned callers preserved. A whole TF validator transplant would overwrite unrelated runtime, staged-input and toolchain behavior.
- Agent operators and generated-guide users need consistent metadata recognition, with actual version/date synchronization and no extra policy, receipt or approval system.
- Project/cost/schedule owners need removal based on actual lack of a consumer, not line count. A needless compatibility branch and unnecessary document diff add review and regression work without a demonstrated benefit.

No cloud/state/credential operation, personal-data collection, localization change or new UI is involved. Accessibility benefits from preserved real title checks and document structure; metadata fallback does not waive those separate checks. Historical-artifact labeling remains outside this parser repair.

## 3. Options before scoring

| ID | Coupled option | Consequence |
| --- | --- | --- |
| N | No change | Retains the demonstrated policy contradiction and D10's mistaken premise. |
| P | Change protected policy to mandate current PS heading/H1 restrictions | Would change author obligations and require currently ungranted authority. Does not preserve the present contract. |
| A | Repair all placement branches; retain D10 absent-manifest exception and candidate dependency formatting | Fixes valid-form rejection but retains an exception and formatting whose useful consumer must be shown. |
| B | Repair placement and remove unsupported D10 branch; keep optional dependency heading/date | Removes the unused accommodation if the census confirms it, while retaining a permissible but unnecessary formatting change. |
| C | Repair placement; remove D10 branch if unsupported by complete native evidence; revert only the candidate dependency heading/date change | Preserves the shared policy and normal valid-parent comparison with the smallest useful final change. F1/F3 remain. |
| D | Repair placement and revert dependency formatting; retain D10 branch | Same valid-form behavior but still retains an unneeded allowance if no actual parent needs it. |
| E | Add a dependency-path or legacy-direct-list exception | Can repair one observed document but leaves other normative forms/paths rejected and grows special-case authority. |
| F | Accept raw/fallback fields on parser failure or broadly ignore invalid parents | Hides malformed placement/duplicates/invalid prior content and weakens the trust boundary. |
| T | Replace PS's whole parser/validator with TF's implementation | Reuses some valid direct-list behavior but retains TF's early-H1 restriction and overwrites unrelated interfaces. |
| S | Extract a new shared configurable metadata package/helper architecture | Could implement the same contract, but no new loader/configuration consumer is needed for this bounded local fix. |

Reuse the existing bounded AST and typed contexts within A–D; adapt the useful native TF direct-list placement pattern narrowly. That reuse is not a distinct alternate public API. F1 promotion and F3 initialization are retained in every admissible repair. The combination of C with those existing controls is the intended full scope, not a broad removal of bootstrap code.

## 4. Fresh rubric before scoring

Scores 1–5: 1 fails, 2 has major limitations, 3 offers partial benefit, 4 meets the criterion with a bounded limitation, 5 directly meets it. Total=sum(weight*score)/5. Scores are judgments, not measurements or substitutes for the empirical evidence above.

- **Normative placement correctness35%:** accepts the stated branches and rejects misplaced/fake/duplicate metadata without inventing a heading requirement.
- **Validation/authority integrity25%:** preserves bounded typed parsing, genuine prior-parent checks, F1 promotion and F3 closed authorization; removes allowances only with complete evidence.
- **Actual migration usefulness15%:** supports every actual newly governed native document and useful current callers rather than speculative compatibility.
- **History and legitimate author behavior15%:** preserves real authored content/metadata semantics and corrects the D10 premise without forcing unnecessary rewrites or retroactive policy claims.
- **Maintenance surface10%:** minimizes duplicate parsing, new configuration, unsupported exceptions and needless candidate-only edits.

Hard constraints: preserve governing policy unless separately authorized; no broad parser-failure/parent suppression; no loss of F1 or F3; no candidate-supplied prior authority; no wholesale toolchain/validator replacement; no false native full-runtime pass; no D10 removal claim based only on dependency-maintenance. The three-document evidence above now supplies the discriminator. If implementation finds a real counterexample, revise this same decision on its facts before further edits; do not automatically retain or expand a generic bypass.

## 5. Scores before selection

| Option | Correctness35 | Integrity25 | Migration15 | History15 | Maintenance10 | Total /100 | Concrete limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 1 | 3 | 1 | 1 | 4 | 36 | Confirmed shared-policy contradiction remains |
| P | 1 | 2 | 2 | 1 | 2 | 30 | Changes the contract; protected authority absent |
| A | 5 | 5 | 5 | 5 | 2 | 94 | Unused D10 branch plus unnecessary formatting remain |
| B | 5 | 5 | 5 | 5 | 4 | 98 | Same required result, extra optional document edit |
| C | 5 | 5 | 5 | 5 | 5 | 100 | New implementation/negative controls still must pass |
| D | 5 | 5 | 5 | 5 | 3 | 96 | Unsupported compatibility branch/tests retained |
| E | 2 | 3 | 2 | 2 | 3 | 47 | Path exception leaves other policy branches wrong |
| F | 3 | 1 | 3 | 2 | 3 | 47 | Broad suppression violates hard constraints |
| T | 3 | 2 | 3 | 3 | 1 | 51 | TF also rejects fallback; unrelated interface loss |
| S | 5 | 4 | 5 | 4 | 1 | 84 | New loader/configuration surface without a consumer |

All ten totals are checked from the displayed table. Scores for A–D intentionally do not pretend that retaining a legal optional heading or an inapplicable closed exception changes valid-document behavior; their required behavioral benefit is the same after the complete repair. C has less maintenance because the exact native census removes the premise for D10, and reverting the two-line dependency formatting delta also restores the currently shared direct-list form. B's extra heading/date has no remaining A02 purpose; D's exception has no real native consumer. These are concrete differences, not a preference inferred from a two-point margin. The native escalation rule for scores too close to differentiate objectively therefore does not apply. If a distinct current benefit is demonstrated for the retained branch or formatting, reassess rather than adjust weights to force a winner.

Select C. It preserves the same actual valid-document behavior with no unsupported migration branch or unnecessary candidate-only document edit. No protected-policy change or new owner permission is needed for this selection within the authorized repair scope. Parent publication and writer release still precede implementation.

## 6. Selected solution C — controlled implementation instructions

Repair Get-DocumentMetadataContext through its existing typed Markdown context. Reuse the native TF direct-list placement pattern narrowly where useful; do not copy its whole helper or its early-H1 limitation. Select a placement anchor from the actual policy. Parse the required metadata from one actual top-level list or the correctly placed section. Preserve required fields, allowed statuses, unique values, Version/date validation and meaningful rendered comparison. Keep present byte/process limits and refusal behavior. When optional Version is present, parse and enforce its existing format, date synchronization and applicable published revision semantics through the existing transition capability; do not accept the paragraph and then ignore it because the catalog does not require Version. Keep title/lint and document-specific required-Version obligations separate from the placement anchor.
Handle optional-Version transitions explicitly. When both actual parent and current document carry Version, use the existing versioned transition semantics. When current content introduces an optional Version and the actual parent has no Version, validate the new tuple/revision-zero condition without pretending that the whole parent is absent. Keep the real parent for Last Updated validity, nonfuture/backward and rendered-change comparisons. An invalid governed parent must not become valid through that introduction. When the catalog does not require Version, removal of an optional Version does not justify rejecting otherwise valid metadata solely for its absence; preserve the real parent validation and applicable date/content checks. A required Version must still be present. Do not turn Version introduction/removal into a second D10-style parent-null exception or a new public API.

Remove only D10's manifest-absent invalid-parent/nulling allowance and its exclusively dependent tests/parameters. The complete native consumer evidence supports this removal; verify those parents through the repaired implementation before acceptance. Preserve known-governed/ADR protections used by F1. Preserve original ParentContent for comparison. Preserve any prior-validator hash acquisition still needed by F3; do not delete a shared input by name. The coordinator must mark D10's premise/absent-manifest allowance superseded in its planning/native finding record. Correct F1's statement that the D10 branch remains necessary, while retaining F1's independently justified existing-exemption behavior. Do not edit protected policy to preserve a mistaken consumer requirement.

Restore docs/dependency-maintenance.md to its native pre-change bytes in the candidate: remove the added optional Metadata heading and restore the prior 2026-10-01 date. Its only candidate changes were that heading and date, with no independent authored purpose. Do not alter immutable history or its substantive A07-owned toolchain instructions. The source diff proves the two changes are isolated. Record the reversion as removal of an unnecessary candidate edit, not a new substantive update or a rewrite of published history.

Product scope is the existing validator, dedicated SelfTest/required same-file placement tests, and the isolated dependency-document reversion. No docs.instructions.md edit, workflow redesign, new public parser API or remote framework is proposed. Parent publication and writer release precede implementation.

## 7. Required validation after selection

- Actual production helper/caller acceptance for direct and headed forms; required and optional Version; front matter/body counting; leading directive and no-directive fallback; no/late H1; H1 at the 30-line boundary with adjacent later fields.
- Optional-Version introduction from a valid unversioned parent enforces new tuple/revision zero and real-parent date checks; mismatched date, nonzero initial revision, backward date or invalid governed parent fails. Existing versioned transitions retain their arithmetic. Optional removal preserves real-parent/date checks; required-Version removal fails.
- Real invalid placement, duplicate direct/section fields, mixed fake blocks, nested/fenced/quoted fields, invalid Version/calendar/status, malformed front matter and oversized input must fail for the intended reason. Do not count early-H1 failures as proof of downstream duplicate controls.
- All three immutable native parents parse and undergo ordinary baseline comparisons after D10 removal. Invalid genuinely governed parents continue to fail. New null-base documents still use normal new-document behavior.
- F1's exact trusted exemption promotion passes; candidate-only/nonexempt/known-governed/ADR suppression fails. F3's closed classification initialization and endpoint/mode/caller controls remain unchanged and pass their focused regressions.
- The reverted dependency file matches the actual native B blob. Final version/date checks and the selected FinalizeMetadataNow/no-context behavior remain intact.
- Then run the required current-candidate repository validation and paired review lifecycle. Previous frozen pre-commit evidence predates this repair and cannot accept the new bytes.

This author contributed to the design. Later independent quality must inspect the implementation and its negative controls with the parent's supplemental independent review. This decision supplies neither current-head acceptance nor transfer credit.

## Final validation placement

The [validation-placement addendum](review-D-A02-14-validation-addendum.md) preserves this product selection and defines the exact-native-B final-tree fixture needed for aggregate validation. It also repairs two test-input assumptions exposed by that context and the supported shallow CI checkout. No production baseline change or control waiver is selected.
