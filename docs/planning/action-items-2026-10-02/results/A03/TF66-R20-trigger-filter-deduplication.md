<!-- markdownlint-disable MD013 -->
# R20 — remove semantically redundant trigger literals

## 1. Validated improvement

Comment4179947053 identifies harmless but real duplication. Both push and pull_request path lists contain `.github/workflows/**` plus six literal descendants: ci-toolchain.json, .npmrc, copilot-setup-steps.yml, npm-shrinkwrap.json, package.json and package-lock.json. Each is already in the broad positive pattern. In addition, `.pre-commit-config.yaml` is covered by the retained `**/*.yaml` pattern. There are no negative patterns or order-dependent exclusions. Removing those seven literals per event preserves the exact trigger set, including future workflow files.

The setup-shape test at `Test-CiHelpers.test.mjs`979–1003 already requires `.github/workflows/**`, `**/*.yml`, `**/*.yaml` and the distinct root/nonworkflow inputs. It also redundantly requires `.pre-commit-config.yaml` as a literal. Complete semantic deduplication therefore needs removal of that one redundant expectation; its YAML-wide coverage oracle remains. None of the six workflow literal entries is separately required by that test. No new test or changed trigger authority is needed.

Input: TF H `dde2b9abe761af69a7f561512df7d44d0dec6745`, tree `d59a740b7b1d88f7986075ac9328d9998629aa71`, B `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`. Full authenticated comments are in `review-comments.json`; ten immutable raw source blobs/modes/hashes are in `source-identities.json`. Windows/Linux probe code, commands and observations are in `probe.mjs`, `windows/result.json`, `linux/result.json` and `linux-run.json`. No product edit, dependency installation, full suite or aggregate was performed. Scores are judgments, not measured reliability.

## 2. Stakeholders

Maintainers and code reviewers need path filters to show their real breadth without misleading enumerations. Contributors and CI operators need every existing intended input and future workflow helper change to keep triggering setup. QA needs meaningful trigger coverage retained rather than false failure from a redundant representation assertion. Security reviewers need no accidental omission of toolchain/config inputs. Cost stakeholders need unchanged scheduling, not a wider all-change trigger. No deployment, secret, privacy or recovery behavior changes; only the representation of the same trigger language changes.

## 3. Options and permutations

N leaves current filters. W removes only the six workflow descendants. A removes all seven covered literals per event and the one coupled redundant test expectation. E replaces broad patterns with current explicit filenames. C comments or groups the existing redundant entries. G uses anchors or generation to share whole arrays. U removes path filtering entirely. A plus a short comment is possible if useful, but the remaining patterns already state their scope; no extra explanatory product prose is necessary. G addresses push/PR array duplication, a different representation issue, and is unnecessary for this smaller cleanup.

## 4. Unique rubric

Scores0–5 mean:0 fails the objective;1 very weak;2 substantial limitations;3 useful but limited;4 strong with a stated residual;5 satisfies the criterion on the inspected design/evidence. Total=sum(weight×score)/5. Hard constraints override totals. Churn/effort are not reasons to reject a correct useful change.

Trigger equivalence45 preserves exactly which changed paths can select this workflow. Readability25 makes broad versus enumerated intent clear. Future coverage15 retains new workflow/config/helper files under existing globs. Test fidelity10 retains actual closure requirements without redundant literal assertions. Maintenance5 limits extra generators, anchors or duplicate representations.

Hard constraints: preserve branch/event/permission policy; keep both broad workflow and YAML globs; keep .husky, requirements-dev and distinct root npm inputs; no new path exclusions, all-change broadening or future-file coverage loss. This is a representation cleanup, not permission to shrink the selected setup closure.

## 5. Scores before selection

| Option | Trigger equivalence 45 | Readability 25 | Future coverage 15 | Test fidelity 10 | Maintenance 5 | Total | Evidence/tradeoff |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 5 | 3 | 5 | 5 | 4 | 89 | Correct current triggers; redundant specificity makes intended breadth less clear. |
| W | 5 | 4 | 5 | 5 | 5 | 95 | Removes six directory-covered literals but leaves the covered root YAML literal. |
| A | 5 | 5 | 5 | 5 | 5 | 100 | Remove all seven redundant literals/event and the now-redundant test expectation; exact positive trigger set is unchanged. |
| E | 2 | 4 | 1 | 3 | 3 | 50 | Ineligible for semantic cleanup: enumerating only current files loses future workflow/helper coverage. |
| C | 5 | 4 | 5 | 5 | 3 | 93 | Comments/grouping explain duplication but retain two representations of the same trigger intent. |
| G | 5 | 3 | 5 | 4 | 2 | 85 | Shared YAML anchors/generation can deduplicate event arrays but add representation/tool coupling. |
| U | 2 | 4 | 5 | 3 | 4 | 63 | All-change triggers broaden cost/behavior rather than simplify the existing set. |

Recommend A100. The score reflects a complete semantics-preserving cleanup on a finite exact list, not a claim of operational defect or runtime gain. W is also correct but incomplete for the same demonstrated redundancy. G would solve a broader code-generation problem without improving the required trigger set.

## 6. Selected controlled-English steps

Remove the six workflow-directory literals from each event path list. Remove `.pre-commit-config.yaml` from each list. Keep the covering globs. Keep all other filter and workflow fields. Remove only the redundant root-YAML literal from the existing test's required-entry list. Keep its required YAML glob assertion. Do not add mirrored tests or change setup execution.

Exact scope: `.github/workflows/copilot-setup-steps.yml` and `.github/workflows/Test-CiHelpers.test.mjs`. No governed metadata or instruction text changes. Controlled-English intent is followed; no formal dictionary certification is claimed.

## 7. Validation and primary authority

The private probe parsed actual YAML on Windows/Linux and records the before list, each removed literal and its surviving covering pattern, and the proposed remaining list in memory only. The diagnostic phase did not create a product postimage. This is a positive-set containment proof, not a claim to have invoked GitHub's remote event matcher. [GitHub's filter documentation](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#filter-pattern-cheat-sheet) defines recursive `**` matching and illustrates YAML matching at any depth. No negative entries complicate the union.

After selection, compare parsed YAML excluding only the14 removed literals; assert every other field/token body is identical. Check the existing setup-shape test on the final private bytes without adding a new framework or exact-string tests. Inspect the one expectation deletion and preserved covering-glob assertions. Reuse unchanged setup/runtime evidence; root owns any later required combined aggregate/native lifecycle. Implementation has not begun.

## Coordinator selection and evidence

Root selected A (100/100) at 2026-10-05T00:50:37.233582+00:00, after displaying the alternatives, finding-specific rubric, complete score table and controlled-English steps in that order. The authorized author is implementing only the selected private repair. No product integration, new remote request or acceptance has occurred. No additional owner decision is needed.

Root read all four proposals, checked all23 new weighted totals, sampled four raw source blobs against native H, and read the complete Windows/Linux probe results and probe code. The frozen diagnostic guard covers the unchanged78 tracked files, index and1910 dependency files. The nine selector controls passed on both platforms. Actual staged execution recorded two scans before the selected repair; these are synthetic timing samples, not production benchmarks.

Private commands and full outputs are located by [STATUS](../../STATUS.md), under `TF-coherent-20261004/implementation/round5-review-findings`. Windows used pinned Node24.18.1 with `probe.mjs`; Linux used `run-linux.py` with its exact recorded Docker image, arguments and network-disabled run. No full aggregate was repeated for the diagnosis.

| Diagnostic evidence | SHA256 |
| --- | --- |
| `HANDOFF.md` | `0bf764e89a1b02aa93fc41172df3221a41de572226e51c9a1f78daafbc29e701` |
| `evidence-catalog.json` | `f08f72e90776f16ab015e628d987aec219f264364b6c0b0bea7ced21a3c8b2e5` |
| `final-source-guard.json` | `6e695acbb4820fb7e661972869b79aa8019e8cf015252f2e4d020d6cb884f5ef` |
| `windows/result.json` | `1a0477bc77a6fbd664794cfcda7ac0e36a2ccf08dbe5bb7c245fb459da27b55b` |
| `linux/result.json` | `23cc455b29f420d268b775e8e268fc7474b896b03858898d4cf4ff6ab9f6c87b` |

[Canonical peer lifecycle](../A02/coherent-peer-candidate.json) records implementation, tests, native dispositions, review rounds and acceptance separately.
