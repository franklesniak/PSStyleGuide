<!-- markdownlint-disable MD013 -->
# R22 selected repair: use validated metadata coordinates for ADR lifecycle checks

Status: selected by root on 2026-10-05 after the full ordered process; private implementation released. Product integration and acceptance remain pending. Owner A21. Source H `db54d687b105e548117c1e8a60ba155fab1a376f`, tree `5fbf0601b7da43ae6872fa23a89e60cc5cd01197`; actual accepted B `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`. `source-identities.json` records raw blobs and SHA256. The observations below precede solution edits; the author now owns the released private repair.

## Validated failure and finite coupled boundary

[Codex comment4180361508](https://github.com/franklesniak/TerraformStyleGuide/pull/66#discussion_r4180361508) identifies a real supported-form failure. `Get-DocumentMetadataContext` explicitly accepts direct or headed metadata, with or without a required Version. `Get-DecisionRecordLifecycleFailure` nevertheless indexes the first exact Metadata heading at line5443. The actual first error under StrictMode is **IndexOutOfRangeException**, not merely the later missing `.Start` property described by the review. New/changed direct-form records cannot complete validation. The unchanged-baseline early return still works.

The actual unchanged validator CLI ran in a private Git checkout at real H, with all original files/dependency bytes and one staged harmless new ADR. `pwsh -NoLogo -NoProfile -NonInteractive -File <private>/.github/workflows/Test-AgentInstructions.ps1 -RequireStagedInputMatch` passed the headed form, exit0 in45.5s. Removing only `## Metadata` and its following blank line, then staging the same private ADR, produced exit1 in38.3s. `validator-windows.json` contains exact commands, timestamps and fixture hashes. Direct failure log SHA256 is `30226cb3a0d727643b585baec29e16894b790c0d9e8cc99da8949bbae526be74`; the call fails at production caller8181. This is ordinary proposed local validation at H, not accepted-B classification or a full SelfTest/aggregate.

The independent focused probe loads all70 unmodified top-level function definitions from the exact validator AST and invokes its actual locked Markdown parser. It does not replace parsing or lifecycle functions with stubs. Eighteen cases agree on Windows PowerShell7.6.5 and Linux7.6.3, both with Node24.18.1. `lifecycle-{windows,linux}.json` and command/log receipts retain each result. Linux used the existing exact image8bdc, network disabled, source/dependencies read-only; no install occurred.

| Case in each form | Headed current behavior | Direct current behavior |
| --- | --- | --- |
| New valid; changed valid | Metadata parses; no diagnostics | Metadata parses; array-index exception |
| Identical baseline | No diagnostics | No diagnostics; retained early return |
| Active rather than ADR lifecycle status | Specific lifecycle diagnostic | Array-index exception prevents useful result |
| Separate Status heading, body field, two-cell table | Specific lifecycle diagnostic | Array-index exception |
| Quoted Status example | No false positive | Array-index exception |
| Separate Status paragraph after metadata list, before next H2 | Incorrectly admitted | Array-index exception |

One additional bounded Windows probe, `lifecycle-extra-field-windows.json`, shows that `- **Decision Status:** Accepted` inside an otherwise valid headed metadata list is also admitted. It is a second lifecycle field, not an ordinary extra metadata field. Current docs.instructions.md310 requires the single Tier1 Status field and forbids a separate narrative status field or section; line318 retains only unchanged published legacy representations. The broad headed-section exemption causes both admissions. Exempting the entire list would fix the first admission but retain the second. They belong to this same exclusion mechanism; no unrelated parser redesign is proposed.

There is an important coordinate constraint. `Get-DocumentMetadataContext` parses source with front matter blanked while retaining source-line positions. `Get-OperativeMarkdownContext` removes comments before parsing and can shift positions. Raw metadata-list bounds must not be compared with that different coordinate space. The selected candidate should reuse the metadata parser's existing context and bounds, including the exact canonical Status record. Existing Markdown parser operative-text treatment already excludes code/quote/nested examples through its filtered token collections. The retained lifecycle controls must prove those exclusions survive this particular consumer change.

[A21 selected common-contract decision](selection-20261003/DECISION.md) requires lifecycle, operative-text exclusions and meaningful positive near misses. It establishes the retained contract, but did not resolve this absent-heading/overbroad-exclusion defect. This is a distinct repair decision, not a duplicate policy choice. No guide or lifecycle-state change is required.

## Stakeholders and options

ADR authors, new contributors and documentation agents need every allowed form to remain usable without unexplained crashes. Maintainers and history custodians need the published legacy fast path and deliberate migration boundary. Policy/security auditors need exactly one lifecycle authority, so a second visible Status cannot hide in a section or list exemption. PowerShell/Markdown maintainers need one parser authority and consistent coordinates. Windows/Linux operators need the same semantic result despite runtime patch differences. UX reviewers need useful diagnostics rather than a terminating index error; QA needs distinct acceptance and rejection oracles, including quoted/fenced examples and ordinary metadata fields. Business/CI owners need finite focused repair rather than a global parsing refactor. No cloud/state/credential/publication interface or accessibility markup requirement changes.

| ID | Option and material tradeoff |
| --- | --- |
| N | Keep current consumer and document that ADRs need headings; leaves a contradiction with supported syntax. |
| M | Make headings mandatory in policy/parser; changes legitimate author behavior and governing instructions. |
| G | Return early when no heading exists; removes the crash but bypasses lifecycle checks. |
| L | Retain the headed-section exclusion; use validated list bounds only for direct form. Fixes direct-form failure but retains demonstrated headed extra-field admissions. |
| P | Reuse the metadata parser context, validated list bounds and exact canonical Status record. Exempt only that record in both forms; evaluate other operative lifecycle fields/sections normally. |
| C | Independently rediscover the list and canonical field in the lifecycle parser; can implement the same policy, with duplicated selection and coordinate obligations. |
| S | Synthesize a Metadata heading before lifecycle checks; changes the analyzed document and requires mapping while retaining broad exclusion unless combined with P. |
| F | Unify all metadata and operative parsing into a larger shared context interface; potentially coherent, but exposes unrelated consumers to migration/regression work. |

P includes the explicitly reported pre-H2 and within-list refinements. P+C would duplicate its authority rather than add a distinct guarantee. S+P has P's guarantee plus unnecessary source transformation. F can implement P's finite boundary but is scored for its broader interface change. Rejecting the direct form, silently skipping lifecycle validation or relaxing StrictMode violates the governing constraints.

## Rubric, checked scores and recommendation

Each criterion uses0–5:0 defeats the objective;3 gives partial or conditional support with a material limitation;5 fully addresses the scoped criterion with clear limits. Scores are engineering judgments, not measured probabilities. Weights intentionally place parser/policy correctness and author usability above churn.

| Criterion | Weight | Finding-specific assessment |
| --- | ---: | --- |
| C | 32 | Parser-authoritative list/field bounds and consistent source coordinates without invented heading assumptions. |
| E | 24 | Complete single-Status enforcement, including before-next-H2 and within-list extra fields. |
| U | 18 | Support all existing valid headed/direct forms and normal extra metadata fields. |
| L | 12 | Preserve unchanged legacy migration, useful failures and operative-example exclusions. |
| V | 9 | Discriminating acceptance/rejection coverage with actual parser and CLI evidence. |
| M | 5 | Maintenance and implementation burden. |

Hard constraints: preserve allowed document forms, actual parser authority, valid metadata/Version/date behavior, four ADR states, unchanged published legacy fast path and nonoperative-example exclusions. Do not turn invalid metadata into acceptance or replace policy errors with silent returns. No higher score can waive these constraints.

| Option | C | E | U | L | V | M | Weighted /100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 0 | 3 | 1 | 1 | 2 | 5 | 29 |
| M | 4 | 5 | 0 | 2 | 3 | 2 | 61.8 |
| G | 0.5 | 0 | 3 | 1 | 1 | 5 | 23.2 |
| L | 5 | 3.5 | 5 | 5 | 4 | 4.5 | 90.5 |
| P | 5 | 5 | 5 | 5 | 4.5 | 4.5 | 98.6 |
| C | 4.5 | 5 | 5 | 5 | 4 | 3.5 | 93.5 |
| S | 3.5 | 3.5 | 4.5 | 4 | 3 | 3 | 73.4 |
| F | 5 | 5 | 5 | 4.5 | 3.5 | 2.5 | 93.6 |

`scores.json` checks `sum(score * weight / 5)` for every row. Root selects **P98.6**. L remains attractive as a smaller crash repair but fails the demonstrated existing single-Status requirement. C risks divergent selection logic; F spreads the same repair into consumers without a demonstrated need. P's assurance score acknowledges that its operative-example equivalence still needs the focused implementation checks below; it is not an assertion that unimplemented code already passed.

Selected controlled-English steps (plain short instructions, not a formal ASD-STE100 dictionary certification):

1. Keep the unchanged-baseline return.
2. Validate metadata with the existing parser.
3. Keep the existing invalid-metadata return to its upstream validator.
4. Return the validated metadata-list bounds and canonical Status location in the private context.
5. Return the same parser context for lifecycle inspection.
6. Use those coordinates for both headed and direct metadata.
7. Exempt only the canonical Status record within the validated list.
8. Reject each other operative lifecycle field or section.
9. Keep ordinary extra metadata fields valid.
10. Keep code, comment, quote and other supported example exclusions.
11. Keep the existing lifecycle diagnostic categories and four allowed states.
12. Report a separate field as `must not contain a separate operative Status field.`
13. Update the existing affected diagnostic expectations. Do not add literal-mirroring tests.

## Exact proposed surface, output and verification

Proposed product path: **`.github/workflows/Test-AgentInstructions.ps1` only**, including `Get-DocumentMetadataContext`, `Get-DecisionRecordLifecycleFailure` and the existing lifecycle SelfTest body in that same file. The separate SelfTest loader file does not need an edit. The field diagnostic drops the inaccurate `outside Metadata` qualification because a second field also fails within the list or before the next H2. This is a necessary diagnostic correction within P, not a new policy choice. The added context properties are private/internal and additive. They do not change a public CLI output schema, metadata file format, classifier output, parser subprocess protocol, date/baseline role or external API. Return bounds/context only after successful metadata validation; existing callers still consume the same prior properties. No global parser/operative helper rewrite is proposed.

After selection, add meaningful durable controls for all four lifecycle states in headed/direct new/changed records; invalid state and separate section/field/table rejection; pre-H2 paragraph and within-list second lifecycle field rejection; ordinary extra metadata; unchanged legacy fast path; body-start/directive/frontmatter variants; multiline comments before metadata; and existing fenced, comment, quote, nested-list, inline-code/raw-HTML and unrelated-label examples. The purpose is to discriminate bounds and policy behavior, not mirror property names. Reuse and run the existing extracted lifecycle section alongside the new cases, not the full SelfTest. Actual original-versus-repair CLI controls must show the former direct-form crash becomes acceptance while meaningful negatives still fail with lifecycle diagnostics. Run the affected helper/parser controls on both supported platforms.

No new guide/protected metadata is needed. The source has `.NOTES` versions: implementation must apply the existing source-version convention for touched function/script sections against actual B and actual author date, without mechanical changes to unrelated document metadata. Root owns final integration and finalization checks. After actual TF acceptance, carry this common helper/test repair to PS through the existing reverse transfer; this proposal does not increment that counter or authorize concurrent PS implementation.

Primary references: [Microsoft Set-StrictMode](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/set-strictmode?view=powershell-7.5) documents invalid array indexing and missing-property errors under strict modes; actual7.6.5/7.6.3 observations establish this instance. [markdown-it source mapping](https://github.com/markdown-it/markdown-it/blob/14.3.2/lib/token.mjs) defines token source-line maps. The actual locked parser and validated PowerShell context remain authoritative for this repair. No full suite, aggregate, install, native mutation or solution edit ran.

## Root selection and evidence boundary

Root read the complete proposal and current production consumers, checked all17 score totals, sampled source and failure-log hashes, and checked the linked primary documentation. The ordered validation, options, distinct rubric, complete score table and controlled-English selection were displayed before implementation release. Private proposal SHA256 aa63b781225318f7bd32f616497335324ec4aa9be23a5368b3d35c061615e8f7. Evidence remains in `PSStyleGuide-TF-coherent-20261004/implementation/round6-review-findings` under the STATUS scratch prefix. The author may change only the selected three-file union in a new private repair. Product, index, dependencies, native state and counters stay unchanged until root integration. Focused tests, independent repair quality, one final-byte aggregate, actual endpoint checks and a fresh native review round remain required. No additional user permission is needed for this scoped repair.

## Implemented private repair and focused verification

The selected three-file union is frozen against Hdb54. Source catalog95ff2043d5fd9a8d6b4be85f5eb29200710d772d6432ec7236c9410f8dfa42c9 and patch03bb7cb408d830b90f78c30b6894dbc0bf508fea811b0f838238ecd5378c0c95 bind the exact postimages. Both platforms pass23 selected native Node tests with zero skips; original code fails the three new link/size refusal controls. The complete affected lifecycle body passes on repaired helpers on both platforms and rejects original helpers at the demonstrated extra-field gap. Actual Windows validator CLI accepts headed/direct forms and rejects a second lifecycle field with the intended error. One private negative-case collector assertion failed on wrapped presentation; its log is retained and only that negative reran after normalization. Both changed helpers have zero analyzer Error/Warning diagnostics. No full aggregate ran.

Independent bounded repair quality passed at2026-10-05T03:33:18Z; report SHA256eb6004f9106fbdb67988fea0d9f4c8b2b4ddb621ab6a3c6ebdab0ca7d7164d3d, evidenceab6247b156d1bfc1673737574eb805f3ec533a7e751c3467926cf9c254f1dba8. Root read the complete final report and source diff and sampled actual result hashes. All78 published product files and1910 dependencies remain unchanged. Whole-candidate aggregate, actual commit/endpoints, fresh native reviews and paired acceptance remain required; the [canonical peer record](../A02/coherent-peer-candidate.json) owns their subsequent state.
