<!-- markdownlint-disable MD013 -->
# A09 readiness after accepted C98 and proposed A06

Retain D1 C92, D2 B99 and D3 F96. The six-path PS-first proposal remains valid. This is read-only preparation, not implementation or acceptance. A09 stays transfer **0/8**, review clock **unstarted**. No new material finding changes the existing options, rubric or selection; selected totals were recomputed as 92/99/96. No new decision is needed for unchanged inputs.

## Exact sources and comparison

| Source | Commit | Tree | Status |
| --- | --- | --- | --- |
| PS | `d7b206adbce4f54edd6dd3d86d3dc2fa8e344b48` | `d0025e28eaaef57f4466bc83e9154cd9e7115fb3` | Accepted PS233/C98 |
| TF | `e21b74fe0b56551008f78f9f2946cd2a0f9c19ce` | `89f470ceb6b3e6e9d4ae757e38997f1c6e7bd631` | Accepted TF67/C98 |
| A06 PS | `dec18a6303bd6ad5fe9a43b383a62daa70527aca` | `fd66ed6c5b94d8c012a0aa06c8d30f2ae16746c6` | Proposed PR234 round3; no accepted A06/peer boundary |

Both remote native main refs matched the accepted pins before and after the read at `2026-10-05T22:38:29.610833+00:00`. No fetch or ref mutation occurred. The catalog contains **115 raw observations** (PS38/TF39/A06PS38): **112 present blobs**, three explicit absences and **6,737,860 bytes**. Each present observation includes Git mode/type/blob, byte count and SHA256. Exact changed line intervals retain raw line terminators and region hashes; no checkout-normalized comparison is used. No existing mode/type changed. The three absences are the new generator test in accepted PS/TF and the PS language guide path in TF; they are recorded scope facts, not new A09 findings.

All57 retained A09 paths were refreshed. Versus prior accepted PSf168f83/TF56cb041, **PS11/28** and **TF2/29** changed. The expanded A06 interface union adds two further changed PS paths and one TF path. Proposed A06 changes13 paths relative to accepted PS; four belong to the prior PS28-path catalog (workflow validator/test, build workflow, scripts README). The full changed-path union and each exact delta are in `identity-change-catalog.json`.

Unchanged core at accepted PS/TF and proposed A06: recorder, recorder tests, both historical profiles, PS P1, TF CURRENT-PROVENANCE and TF T1 archive. PS baseline-provenance ADR also remains unchanged. Core blobs remain PS recorder `009f29663399b9f9c0b669a214859a3b52dbb5a6`, test `19240ed44a8811d0a98bb0c67e4a732b5a749f58`, profile `224f6fba1aa90174dad8eec57dc6012697d8be33`, P1 `fc3fb7b657c62702f8b77b196735ff6a458c89e5`; TF recorder `33771aa438f441bd96a0fcaa4c103a379fc8b302`, test `25abdcb61aca8a1c0df9e3643aa7b68781ab6052`, profile `471fe6dd03676739c2c8a031f2d42010169b8dea`, current method `b567f286e9a00add2ef345ef11481efe19516ca8`, archive `9e04225a355997850e4817f9163868089a773332` (all mode100644).

## Selection and changed interfaces

D1 C92: unchanged fixtures still copy current workflow package/lock/tree and demand strict success before later negative controls. At all three sources, current package/lock hashes differ from the unchanged historical pins. Current manifest bytes themselves remain equal to the prior refresh. Retain current native4/empty-output and diagnostic-incompleteness expectations, a named historical-byte guard control, and reachable independent negative cases. A source-bound guard control cannot prove complete installed-tree success.

D2 B99: unchanged helper guidance still says a changed manifest needs a new reviewed freeze. Retain the selected fixed text explaining the historical profile and current locked-install/parser checks. Keep native4 and empty stdout. The active methods require a short current-package clarification; archived T1 remains factual history.

D3 F96: raw helper/test comparisons still contain **23/39 differing intervals**, matching the retained region map. Shared algorithms remain unchanged. Preserve narrow historical pins, tuple authority, schemas, output semantics, attribution and TF three-commit/five-blob groups. Align unnecessary common diagnostics/tests without a loader, descriptor or framework.

Accepted foundation deltas primarily affect main-entry detection (`import.meta.main` with realpath fallback), audit-reference documentation, whole instruction validator/SelfTest, classifier binding, selected CI-helper tests and ordinary setup navigation. TF's two retained-path changes are the instruction validator and scripts README. Root runtime remains Node24.18.1/npm11.16.0; current risk-exception objects are empty at all three inputs. Historical risk records, prior failed/cancelled services and platform limits are not renewed or relabeled.

A06 changes generator composition/identity tests, exact Git path verification, instruction classification, artifact verification, and build admission. Build now adds Windows5.1/Windows7/Linux7 generator jobs with two actual suite passes and same-revision admission; policy validates that finite graph. These are proposed generator controls, not optional supply-recorder proof. The validator's raw region before `function helperCall` (package/lock and parser-integrity implementation) is identical across accepted PS, accepted TF and proposed A06. A06 adds one generator row to scripts README; the recorder's manual optional row remains unchanged. The two manifests and all five tracked ordinary YAML workflows at each source contain **no recorder/profile reference** (21 caller files). The full tracked reference census is retained in the catalog. No new routine historical-reproduction dependency is present in this checked scope.

## Reusable evidence and remaining gates

Reuse the unchanged historical PS205/TF55 proof within its named bytes, platform and threat limits; the characterized filename-only delta remains applicable. Retain the original six source-guard probes and eight selected Windows tests from A09 validation as scoped evidence, not new execution. Unchanged guard/refusal logic and historical input identities preserve scoped algorithm evidence. The original current-input probe outcomes remain bound to their original package bytes; this refresh proves current mismatch by raw identity comparison, without executing the guard. These results do not establish a current full Linux recorder pass. Old current-tooling/caller results do not apply to changed main-entry, validator, generator or workflow bytes. Reuse accepted PS233/TF67 landed evidence for its exact foundation scope (507/515 Node tests, zero failures/skips and11 hooks), without calling those suites optional-recorder acceptance.

1. Preserve accepted C98 identities and open A03 R5/D2 and A07 B99/R5 obligations. Finish the coordinator's serialized A06 source/peer acceptance boundary and re-pin actual affected native inputs before writer release. Resolve actual A09 dependency scope from accepted predecessor results; this preparation grants no acceptance.
2. Implement the existing PS helper/test/P1 repair first; then transfer the paired helper/test/TF CURRENT-PROVENANCE repair through the existing finite review/merge/compare-back loop. Keep profiles and TF archive byte-identical to their preimages.
3. Run affected supported Linux fixture roles on the eventual candidate with verified Node/npm, startup hygiene and private external-cache topology. Assert current refusal4/empty output and incomplete diagnostics. Keep cache/process/mutation/privacy/acquisition/offline/TF final-group controls reachable. Label synthetic, source-bound and actual historical installed-tree proof separately; historical installation is separately optional.
4. Run meaningful Windows supported/refusal roles separately. Compare modes/raw shared regions and exact necessary historical regions, unchanged profiles/archive, and ordinary-caller absence. Obtain fresh independent candidate quality and native lifecycle acceptance; recheck both actual mains. A18/A19 retain final whole-tree and issue closure.

## Evidence and limits

Canonical reused evidence is under `C:/Users/flesniak/GitHub/PSStyleGuide/docs/planning/action-items-2026-10-02/results/A09/`: RESULT, decisions, surface map, native evidence and validation. The catalog records their SHA256 values, plus C98/A07 accepted-release/landed evidence and A06 source-validation identities. Source-validation is a captured planning record; no live PR request, CI query or acceptance was performed here. The exact proposed Git source remains independently pinned above.

Catalog SHA256: `752660478a5bee12b65b3ec54c3683c2c3debf9d6205adc1203498e3e4807a0b`. Only the new `REPORT.md` and `identity-change-catalog.json` were written in this designated scratch directory. No production/planning edits, tests/probes, installation, historical audit, PR/review request, native mutation, risk renewal, original-contract credit or completion was performed. This bounded refresh is not a new full line-by-line audit of the two large recorders or archived T1. Return idle after delivery.
