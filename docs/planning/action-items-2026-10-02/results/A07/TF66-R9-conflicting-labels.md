<!-- markdownlint-disable MD013 -->
# R9: Reject conflicting repeated Markdown input labels

Status: C99 selected after the ordered validation, options, rubric and score display. Root read the complete proposal and released the private two-path implementation, combined with the separately selected R8 test-fixture correction. Product integration and validation remain pending. This is the canonical R9 decision.

## Validated finding and scope limits

Authenticated Copilot Lite review5407690955, comment4178895938 on PR66 H4375f2e3c98a6aeb0dd916d26620ed63a42abafe, tree099bb0f83403b6b61cfa2dafa73916b315c791d3, actual B06ad4f7c9b6847028cafdacf1ae55128d0f2d56c. Root's exact native snapshot is round2-observation-08.json.

The exported lintOuterMarkdownContents API accepts an array of string filePath/content records. It builds a null-prototype strings object using each filePath as the key. A later record silently replaces earlier content with the same exact key before markdownlint sees it. Root's actual pinned Node24.18.1 API probe proves: a single invalid document returns1; a single clean document returns0; invalid then clean under the same label returns0; reversing those two records returns1. The allegation is therefore valid at this API boundary. Root's results.json and hashes.json under round2-copilot-validation are reused without rerunning the witness.

**No current production caller bypass has been demonstrated.** The staged checker creates one record per Git name-only staged path; outer discovery obtains glob results. Source inspection of installed glob13.0.6 shows its walker maintains a seen Set and its result collection is a matches Set. Current callers therefore appear to supply unique exact labels. This evidence limits demonstrated reach; it does not justify an API silently losing a submitted document. The API's current JSDoc calls these safe inputs but gives no explicit unique-label contract. FilePath is an in-memory diagnostic label here, not an instruction to open or canonicalize a filesystem path.

The nested in-memory helper already processes entries individually and is not the faulty map assignment. Its behavior is not part of this change. Configuration loading, rule selection, string/type validation, output diagnostics for unique inputs and0/1/throw return semantics must remain. Current wrapper catches already convert thrown tooling errors into the existing failure exit; no new failure framework is needed.

Stakeholders: contributors need every submitted document checked and usable diagnostics; API callers need predictable input semantics with benign repeated data preserved where safe; security reviewers need no silent invalid-content loss; CI/maintainers need existing single-label behavior and supported caller semantics; test reviewers need order-sensitive witnesses that prove the actual bug rather than assertions of implementation syntax. Maintenance cost is secondary.

## Options, before rubric and scoring

| Option | Behavior and relevant tradeoff |
| --- | --- |
| N/T | Document a unique-label precondition and keep current last-write-wins, or explicitly deduplicate to the last entry. These share the same runtime behavior and are one scored family. They do not protect this boundary when the precondition is violated. |
| R | Reject every repeated exact label. Simple, deterministic and no data loss, but also rejects benign identical repeats. |
| C | Reject a repeated exact label only when its content differs. Identical repeats remain accepted and receive the same lint result as their one distinct byte sequence. |
| L | Lint each array occurrence individually and combine failures. Preserves every occurrence; repeated-label diagnostics need care and repeated identical content incurs duplicate work. |
| I | Give each occurrence an internal unique ID, batch lint, then map diagnostics back to labels/occurrences. Preserves all data with clear occurrence tracking, but adds another identity mapping and output contract. |
| U | Validate uniqueness only at current caller boundaries. Can protect those callers, but leaves the exported helper's lossy behavior available to another caller. |
| A | Replace the array API with a unique-key mapping API and migrate callers. Makes cardinality explicit at the new boundary, but input construction can still silently discard earlier content before the call unless separately validated; it also breaks current API shape. |
| F | Explicitly deduplicate to the first occurrence. Merely reverses which ordering hides invalid content. |

R plus caller checks duplicates the same protection. C plus caller checks likewise adds no demonstrated necessity. L and I are distinct ways to preserve all occurrences, not independent optional fixes. Combining mapping-API replacement with validation in each conversion site is A with U's extra caller responsibility. Normalizing case, slashes, realpaths or filesystem aliases is a different contract and unnecessary here: two distinct string labels can legitimately describe distinct in-memory inputs. No option is excluded solely because it requires more edits. First and last retention receive symmetric content-loss scores.

## Finding-specific rubric

Scores0–5, weighted sum(score times weight)/5. Root displayed this rubric before the score table.

| Criterion | Weight | High-score meaning |
| --- | ---: | --- |
| Content preservation | 35 | No invalid distinct content disappears before validation; benign input still receives the correct lint result. |
| Actionable diagnosis | 20 | Clearly identifies conflicting labels without unnecessary errors for unambiguous identical data; distinguishes input/tooling failures from lint findings. |
| Order independence | 15 | Reversing repeated entries cannot turn failure into success. |
| Caller/API compatibility | 15 | Preserves unique in-memory labels, existing caller shape and0/1/throw semantics without filesystem requirements. |
| Discriminating evidence | 10 | Both conflicting orders, identical repeats and distinct labels can be proved through direct meaningful controls. |
| Continuing complexity | 5 | Keeps validation understandable without parallel identity/diagnostic machinery. |

Correctness and usability dominate cost. Required boundaries: retain config/type checks and native failure propagation; do not silently lose distinct invalid input or claim a demonstrated current-call-site exploit. Identical-content repeats are not ambiguous in bytes and need not be rejected.

## Scores and selected decision

| Option | Content35 | Diagnosis20 | Order15 | Compatibility15 | Evidence10 | Complexity5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| N/T | 2 | 1 | 1 | 5 | 2 | 5 | 45 |
| R | 5 | 4 | 5 | 4 | 5 | 5 | 93 |
| C | 5 | 5 | 5 | 5 | 5 | 4 | 99 |
| L | 5 | 4 | 5 | 5 | 5 | 4 | 95 |
| I | 5 | 4 | 5 | 5 | 5 | 3 | 94 |
| U | 3 | 2 | 2 | 5 | 3 | 3 | 59 |
| A | 3 | 3 | 3 | 2 | 3 | 2 | 56 |
| F | 2 | 1 | 1 | 4 | 2 | 4 | 41 |

R9-scores.json records weights/vectors and reproducible totals. C=35+20+15+15+10+4=99. R=35+16+15+12+10+5=93. L=35+16+15+15+10+4=95. N/T and F both receive2 for content preservation because both discard an invalid occurrence for one ordering; F loses compatibility because it changes which existing entry survives.

Select C99, as root has displayed. C prevents conflicting byte sequences from being conflated while retaining identical repeats. Identical invalid content must still return lint1; identical clean content returns0. R supplies no additional content protection for identical repeats and introduces an unnecessary input error. L and I remain valid complete alternatives; their repeated-label lint output needs occurrence handling, whereas C can identify an inconsistent caller input directly. U does not fully guard the exported API. A shifts validation responsibility rather than automatically solving lost data.

## Selected controlled-English steps

1. Keep the existing null-prototype strings object and each record's type checks.
2. Before assignment, check whether that object already has the exact filePath as its own key.
3. If the key exists and its stored content is not exactly equal to the new content, throw a clear conflicting-input error. Include the input label. Do this before calling markdownlint.
4. If the existing content is identical, retain that content. Continue to accept unique inputs.
5. Keep existing configuration, lint diagnostics,0/1 results and thrown-tooling-error propagation. Do not resolve paths, fold case or change the nested API.
6. Add direct API controls for both conflicting orders, identical clean repeats, identical invalid repeats and distinct labels. Prove the original implementation fails the new conflict controls. Use the existing test file and real lint engine.
7. Run the affected existing suite with pinned runtimes and private scratch. Combine its postimage with the separately authorized R8 fixture correction without losing either change. Give root exact diff/hashes/evidence for integration.

## Proposed paths and focused validation

Only .github/workflows/lint-nested-markdown.js (the outer API admission guard and a concise input-contract JSDoc clarification if needed) and .github/workflows/lint-markdown.test.mjs (meaningful API regressions). No dependency, workflow, hook, package/config behavior, protected document, filesystem policy or initializer change. The latter test file also belongs to R8's separately selected six-site fixture correction; produce one final combined private postimage there, with region attribution.

Proposed controls use actual current config and Markdown engine: invalid→clean and clean→invalid under same.md must throw a conflict diagnostic rather than return0/1; identical clean repeats return0; identical invalid repeats return1 with their lint evidence; distinct labels with invalid/clean content retain1 and identify the invalid label, while distinct clean inputs retain0. Existing type/config and outer/nested/staged hook controls remain. No duplicate-framework or exact-message-only assertion is needed. Mutation proof should remove the conflict guard and recover the current unexpected-return result, with the intended assertion failing. Existing suites can supply unchanged normal caller/native-status evidence; do not label direct helper tests as hosted CI.

This is a JavaScript implementation-specific input contract. The R6 full PowerShell guide review does not create a PowerShell guide amendment for it; no applicable standalone JavaScript guide change has been identified. No user approval question, new authority source or policy cap is needed. The same accepted PS common helper has the lossy assignment and should receive the selected correction during reverse transfer after TF acceptance; no PS edit or transfer increment now.

## Source/evidence references

[Actual API](https://github.com/franklesniak/TerraformStyleGuide/blob/4375f2e3c98a6aeb0dd916d26620ed63a42abafe/.github/workflows/lint-nested-markdown.js#L369), [staged caller](https://github.com/franklesniak/TerraformStyleGuide/blob/4375f2e3c98a6aeb0dd916d26620ed63a42abafe/.github/workflows/lint-staged-markdown.mjs#L94), [outer caller](https://github.com/franklesniak/TerraformStyleGuide/blob/4375f2e3c98a6aeb0dd916d26620ed63a42abafe/.github/workflows/lint-markdown.mjs). Sources read from immutable local H blobs; installed glob13.0.6 dist/commonjs/walker.js lines23/310/315 corroborate result-set uniqueness for the current discovery implementation. No external caller inventory or universal uniqueness claim is made.

Root's round2-copilot-validation/results.json records the exact current API outcomes at2026-10-04T19:09:58.678Z on Windows Node24.18.1. Reuse its original harness/log hashes; no redundant probe was run here. Root owns public review responses and native lifecycle. This artifact contains no implementation or repair postimage.

Generated with Codex
