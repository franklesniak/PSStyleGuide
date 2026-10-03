<!-- markdownlint-disable MD013 -->

# A01 current native refresh after PR227

Read-only native inventory; source acceptance remains the coordinator's separate gate. Initial and final complete native reads agree. No product, planning, index, branch, reference, GitHub state, test environment or descendant was changed/started. Prior post226 evidence is preserved; only this new scratch directory was written.

| Repository | Native main | Native tree | Tracked files |
| --- | --- | --- | ---: |
| PSStyleGuide | `c13abc4623e2593d7dac703685da6c608451211a` | `427efd5ccf51bd55ac0874b53bf10f0e885d70dc` | 75 |
| TerraformStyleGuide | `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c` | `dc8f6b82588b8f874d34cd5d0155791aea5793f1` | 75 |

PS merge parents are accepted post226 `2a2d14a9969226b0c55d02d4f0c20f2451ed40b6` and reviewed candidate `c9e0b24cd3b4ea8aef87a954f5f67e7b6ce0a6f8`. Its tree is exactly the reviewed candidate tree. TF is unchanged. Product comparison excludes planning branches and worktree candidates.

## Complete raw inventory and delta

The complete union remains **83 paths:13 equal,54 different,8 PS-only,8 TF-only**, versus post226's10 equal/55 different/8 PS-only/10 TF-only. Both recursive native trees are nontruncated. All150 native file entries are100644/blob and were checked against immutable local NUL-delimited ls-tree records; raw cat-file batches supplied exact bytes. Recomputed blob SHA1, size and SHA256 agree with native entries. Equality is direct raw bytes plus mode/type, without normalization. The complete matrix retains a primary integration owner for every path.

**Twenty PS paths changed since post226; TF has no delta.** Newly present on PS are `requirements-dev.txt` and `.github/workflows/Invoke-LockedPythonHook.ps1`; neither is a new union path because both already exist on TF. No path was removed. The shared launcher, requirements file, Invoke-MarkdownLint and Husky installer now exactly equal TF. Four newly equal shared paths, offset by the formerly equal .gitignore becoming different, account for the increase from10 to13 equal paths; other shared files retain their recorded comparison status. No equality-by-exception is inferred.

The changed inputs comprise the classifier pair; npm audit implementation/tests; Python launcher/requirements; Markdown helper, implementation guide and wrapper tests; NpmTools and CI-helper tests; Husky installer/hook/pre-commit configuration; workflow package manifest; root package manifest/lock; script index, dependency guide and .gitignore. Full20-path before/after blob/mode/type/size/SHA256/owner rows are in `comparison-post227.json`. The workflow lock and both core lint algorithms remain unchanged from post226. A21's validator, SelfTest and manifest remain prior native bytes; unmerged A21 implementation is excluded.

The native classifier pair now matches A21's frozen common pair. `.gitignore` gains the selected common .venv exclusion; A02 retains its full four-path paired obligation. Test-CiHelpers remains an A03 integration surface with the narrowly released A07 launcher-test repair; this census does not broaden writer ownership. The recorded TF integration sequence and c9 addendum retain their actual A21/A20/A03 gates.

## Live census and historical preservation

Both complete open-issue/PR collections and each issue-comment collection used per_page100 with native pagination to the terminal short page. **Five issues remain:** PS213/A04,PS175/A05,PS155/A14,PS152/A12 and TF25/A15. All five title/body/state/count/update fields and all seven complete comment payloads exactly match post226; final readback is also identical. **Neither repository has an open PR.** No new issue, discussion requirement or competing PR ownership is observed. Additional live A14 read confirms PS156 remains closed/not_planned with its one historical comment; PS155 remains open.

The original81-path matrix,402 original obligations and26 absent-both references are retained without mutation, with source hashes in `refresh-inspection.json`. All26 references are still absent from this native union. Their existing owners, merits retirements and live missing-capability dispositions remain unchanged; absent paths are not dropped or silently certified.

## Conditional input refresh and limits

**A14:** all five scoped generation/caller inputs (generator, exact-path verifier, artifact verifier, CONTRIBUTING and build workflow) are byte-identical from post226 in both repositories. Declared Node/npm engines, CI toolchain and initializer are unchanged. Changed A07 inputs add selected locked Python/lint/hook setup and tests; none introduces a retired archive-promotion consumer/new writer reference or adopted filesystem primitive. Build authority and generator supported callers remain unchanged. Together with unchanged PS155 discussion/PS156 retirement, this supports retaining D92/D93's bounded conditional result. No race, alias, domain-runner, adversarial filesystem or runtime test was rerun; a future concrete failure, consumer/threat/authority change still reopens it.

**A12/A03:** all five workflow YAML paths are raw-identical from post226 in both repositories. Required-check context names, job names, workflow triggers and permissions have no source delta. Underlying validation/classification/helper/setup coverage does change through A07, so the earlier coverage inputs must now name actual c13. This is not settings enumeration or immutable enforcement proof. A13 still needs exact owner authority and refreshed settings/current-check facts immediately before any mutation; A03 admission/workflow authority remains separate. No settings or collaborator query was made.

**A21:** final assembled gates must use the actual landed A07 caller source and this common classifier pair. The merge/tree match does not turn an unmerged A21 candidate into accepted source or clear protected holds. Complete source/peer integration, A20 protected capacity/protocol/bootstrap and A03 workflow activation/admission obligations remain open.

At final readback **landed Agent instruction validation run37122047604 is in_progress, conclusion null, on exact c13**. The other four returned PS push workflows succeeded. This inventory is complete and stable; landed acceptance is pending and belongs to the coordinator. No transfer, review counter, conditional completion or convergence claim changes here.

`native-census.json` and `final-native-recheck-post227.json` preserve authenticated inputs and complete pagination. `native-tree-union-post227.json` and `comparison-post227.json` preserve the matrix/delta. `conditional-inputs.json` and `refresh-inspection.json` retain bounded checks. `refresh-inventory.py` reuses the post226 implementation with refreshed baseline/output names and current conditional limits. Frozen lengths/SHA256 values are in `evidence-hashes.json`.
