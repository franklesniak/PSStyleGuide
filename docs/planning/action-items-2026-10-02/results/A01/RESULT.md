<!-- markdownlint-disable MD013 -->
# A01 current issue and native tree inventory

## Current refresh after PR227: 2026-10-03

Current native inventory at PS `c13abc4623e2593d7dac703685da6c608451211a` and TF `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`: **83 paths:13 equal,54 different,8 PS-only,8 TF-only**; 75 tracked files per repository. The worker verified all150 raw entries and complete pagination; root independently sampled both repositories' requirements, Python launcher and .gitignore blobs/modes/lengths/SHA256. Five issues and seven comments are unchanged; neither repository has an open PR at this census. All402 original obligations,81 historical paths and26 absent-both references remain intact.

See the [dated post227 report](post227/CURRENT-REFRESH-POST227.md), [complete raw matrix](post227/native-tree-union-post227.json), [delta](post227/comparison-post227.json), [final native readback](post227/final-native-recheck-post227.json) and [source evidence identities](post227/evidence-hashes.json). The report's pending landed-CI observation is retained as dated evidence; the coordinator subsequently confirmed all five exact-c13 push workflows passed and recorded [source acceptance](https://github.com/franklesniak/PSStyleGuide/pull/227#issuecomment-5969203731). Inventory acceptance is not paired convergence. A14's scoped inputs and A12/A03 workflow YAML remain unchanged; changed helper coverage now names c13. No settings/protected authority is inferred.

## Previous refresh after PR224: 2026-10-03

Accepted inventory at PS main `3ba0f4d9686af41ae0e77c65ea374fff9d1cef53`, TF main `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`: **83 paths:10 equal,55 different,8 PS-only,10 TF-only**. All148 raw entries and all83 current owners are accounted for. Five issue bodies and seven comments are unchanged; neither repository has an open PR. Landed source CI remains separately pending.

See the [post224 refresh and coordinator verification](CURRENT-REFRESH-POST224.md), [complete current tree](native-tree-union-post224.json), [comparison](comparison-post224.json) and [final native readback](final-native-recheck-post224.json). The bounded A12 caller change and unchanged A14 scoped contract are recorded; no settings/protected authority or final convergence is inferred.

## Previous accepted refresh after PR225: 2026-10-03

Accepted after PR225 merged: PS main `a71f16a8d76beeca1ba8fdc3b1c95e1958e0973c`, TF main `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`. The complete union is **83 paths: 9 equal, 55 different, 8 PS-only and 11 TF-only**. All paths have current owners; the two new lint helpers belong to A07. Five open issue bodies remain unchanged, with seven comments and no new requirement. PR224 is the only open PR; PR225 is merged.

See the [dated refresh and coordinator acceptance](CURRENT-REFRESH-20261003.md), [complete raw tree and ownership](native-tree-union-20261003.json), [bounded comparison](comparison-20261003.json) and [final native readback](final-native-recheck-20261003.json). This refresh preserves the 26 absent-both dispositions and all 402 original contracts. It grants no protected/settings authority and is not final convergence acceptance.

## Historical accepted snapshot: 2026-10-02

The following 81-path snapshot and its original owner labels are retained as dated evidence; current ownership follows the refresh above and PATH-INVENTORY.

Captured 2026-10-02 at 05:35:52 UTC from authenticated GitHub REST (`gh api --paginate --slurp`) and fetched `origin/main` Git objects. Full issue bodies and paginated issue comments are in [live-issues-and-open-prs.json](../A01/live-issues-and-open-prs.json). Complete tree entries with path, mode, type, blob ID and one primary owner are in [native-tree-union.json](native-tree-union.json). Comprehensive references to paths absent from both pinned product trees are in [absent-path-coverage.json](absent-path-coverage.json). Blob equality was checked against raw bytes and modes.

## Pinned product inputs

| Repository | Native main commit | Tree | Tracked entries |
| --- | --- | --- | ---: |
| `franklesniak/PSStyleGuide` | `48f4d8a36c8faceee12afac78aaecea0d176125d` | `640ee4c0974fb604b2ebf0a1e1e1a328bd213ddc` | 70 |
| `franklesniak/TerraformStyleGuide` | `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c` | `dc8f6b82588b8f874d34cd5d0155791aea5793f1` | 75 |

The union has **81 paths: 9 byte-and-mode equal, 55 different, 6 PS-only, and 11 TF-only**. Each path has one primary integration owner; collaborators are recorded separately. Every entry is a regular `100644` blob; no type or mode-only difference was found. The recomputation matches the pinned refs and counts in [PATH-INVENTORY](../../PATH-INVENTORY.md). Raw differing paths have no approved exception in the dated baseline.

PS-only paths:

- `.github/workflows/Test-AgentInstructions.SelfTest.ps1` — A06
- `.github/workflows/Test-BlankLineExamples.ps1` — A10
- `docs/P1-SUPPLY-FREEZE-v1.md` — A09
- `docs/decisions/0001-accept-in-repository-trust-root.md` — A09
- `docs/decisions/0002-accept-unverifiable-baseline-provenance.md` — A09
- `powershell.instructions.md` — A10

TF-only paths:

- `.github/document-metadata-classification.json` — A02
- `.github/workflows/Invoke-LockedPythonHook.ps1` — A07
- `.github/workflows/Test-LocalValidation.test.mjs` — A07
- `.github/workflows/Test-StateRecoveryExamples.mjs` — A11
- `docs/T1-SUPPLY-FREEZE-CURRENT-PROVENANCE-v1.md` — A09
- `docs/T1-SUPPLY-FREEZE-v1.md` — A09
- `docs/decisions/0001-accept-generated-artifact-lint-lag.md` — A09
- `docs/decisions/0002-accept-repository-code-in-the-write-enabled-job.md` — A09
- `docs/decisions/0003-accept-required-check-workflow-edit-residual.md` — A09
- `requirements-dev.txt` — A07
- `terraform.instructions.md` — A11

`powershell.instructions.md` and `terraform.instructions.md` are the known language-guide counterparts. Their bytes remain unclassified. P1 and T1 supply records describe separate repository inputs. No broad exception is implied. A00's 28-path PR78 matrix is additional history; its one absent-both entry, `Test-AgentInstructionParserManifest.mjs`, is included below.

## Live issue coverage

| Repository | Open issue | Current owner | Comments |
| --- | --- | --- | ---: |
| PSStyleGuide | [#213](https://github.com/franklesniak/PSStyleGuide/issues/213) | A04 | 0 |
| PSStyleGuide | [#175](https://github.com/franklesniak/PSStyleGuide/issues/175) | A05 | 0 |
| PSStyleGuide | [#155](https://github.com/franklesniak/PSStyleGuide/issues/155) | A14 | 4 |
| PSStyleGuide | [#152](https://github.com/franklesniak/PSStyleGuide/issues/152) | A12 | 2 |
| TerraformStyleGuide | [#25](https://github.com/franklesniak/TerraformStyleGuide/issues/25) | A15 | 0 |

All five issue bodies and all six comments were fetched. Both repositories have zero open PRs. PS #155 remains routed to A14 for the live filesystem residual assessment; the removed helper family is also owned by A06 through R06. TF #25's current missing helpers route to A16/A17. The original-task owner ledger is [A00/dispositions.json](../A00/dispositions.json); A00 has handed each original ID to a named current product outcome.

## Absent-both product paths and references

The list below covers path-shaped product references in all 402 original contracts, all currently open issue bodies/comments, the A00 retirement PR file lists and the A00 28-path matrix. It also includes the concrete absent helper paths in the TF #25/A15 design. The table separates retired historical paths from current live requirements and one stale locator. A path deletion alone does not prove a missing capability.

| Absent path | Original task ID / live source | Primary current owner | Decision/evidence | Classification |
| --- | --- | --- | --- | --- |
| `.github/actionlint.yaml` | No direct original task path ID | A07 | [R07](../../RETIREMENT-REVIEW.md#r07-removed-and-relocated-runtime-tests) | retired-product-path |
| `.github/workflows/Confirm-StateMutation.mjs` | live TerraformStyleGuide#25 | A16 | A15 design / A16–A17 outcome; not retired | current-live-requirement-absent-at-baseline |
| `.github/workflows/Expand-StyleGuideCandidateArtifact.ps1` | IDs 223–225, 227–228, 231–260, 379–390; live PS#155 | A06 | [R06](../../RETIREMENT-REVIEW.md#r06-dormant-archive-promotion-and-automatic-writer), [R07](../../RETIREMENT-REVIEW.md#r07-removed-and-relocated-runtime-tests) | retired-product-path |
| `.github/workflows/Inspect-TerraformState.mjs` | live TerraformStyleGuide#25 | A16 | A15 design / A16–A17 outcome; not retired | current-live-requirement-absent-at-baseline |
| `.github/workflows/Manage-StyleGuideCandidateInvocationContext.ps1` | IDs 223–225, 227–228, 231–260, 379–390; live PS#155 | A06 | [R06](../../RETIREMENT-REVIEW.md#r06-dormant-archive-promotion-and-automatic-writer), [R07](../../RETIREMENT-REVIEW.md#r07-removed-and-relocated-runtime-tests) | retired-product-path |
| `.github/workflows/Prepare-TerraformStateRecovery.mjs` | live TerraformStyleGuide#25 | A17 | A15 design / A16–A17 outcome; not retired | current-live-requirement-absent-at-baseline |
| `.github/workflows/Resolve-TerraformStateAddress.mjs` | live TerraformStyleGuide#25 | A16 | A15 design / A16–A17 outcome; not retired | current-live-requirement-absent-at-baseline |
| `.github/workflows/Review-TerraformStateDifference.mjs` | live TerraformStyleGuide#25 | A16 | A15 design / A16–A17 outcome; not retired | current-live-requirement-absent-at-baseline |
| `.github/workflows/Set-AgentInstructionCurrentBaseStatus.mjs` | IDs 10–18 | A03 | [R04](../../RETIREMENT-REVIEW.md#r04-global-current-base-status-sweeps) | retired-product-path |
| `.github/workflows/StateRecoveryCaseCatalog.json` | live TerraformStyleGuide#25 | A16 | A15 design / A16–A17 outcome; not retired | current-live-requirement-absent-at-baseline |
| `.github/workflows/Sync-PullRequestBodyIdentity.mjs` | IDs 41–68 | A03 | [R01](../../RETIREMENT-REVIEW.md#r01-mandatory-pr-body-identity-duplication) | retired-product-path |
| `.github/workflows/Test-AgentInstructionParserManifest.mjs` | IDs 4, 19–40 | A03 | [R02](../../RETIREMENT-REVIEW.md#r02-exact-semantic-source-and-release-label-profiles), [R07](../../RETIREMENT-REVIEW.md#r07-removed-and-relocated-runtime-tests) | retired-product-path |
| `.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1` | IDs 223–225, 227–228, 231–260, 379–390; live PS#155 | A06 | [R06](../../RETIREMENT-REVIEW.md#r06-dormant-archive-promotion-and-automatic-writer), [R07](../../RETIREMENT-REVIEW.md#r07-removed-and-relocated-runtime-tests) | retired-product-path |
| `.github/workflows/Test-StateRecoveryExamples.sh` | live TerraformStyleGuide#25 | A15 | [A15 D1](../A15/read-only-design.md) | stale-live-issue-locator-not-a-restoration-requirement |
| `.github/workflows/Test-StateRecoveryPowerShell.ps1` | live TerraformStyleGuide#25 | A16 | A15 design / A16–A17 outcome; not retired | current-live-requirement-absent-at-baseline |
| `.github/workflows/Test-TrustRootAuthorization.ps1` | IDs 72–73, 82 | A03 | [R03](../../RETIREMENT-REVIEW.md#r03-exact-byte-maintenance-admission) | retired-product-path |
| `.github/workflows/agent-instruction-current-base.yml` | IDs 10–18 | A03 | [R04](../../RETIREMENT-REVIEW.md#r04-global-current-base-status-sweeps) | retired-product-path |
| `.github/workflows/pull-request-body-identity-cases.json` | IDs 41–68 | A03 | [R01](../../RETIREMENT-REVIEW.md#r01-mandatory-pr-body-identity-duplication) | retired-product-path |
| `.github/workflows/pull-request-body-identity.yml` | IDs 41–68; live PS#213 | A03 | [R01](../../RETIREMENT-REVIEW.md#r01-mandatory-pr-body-identity-duplication) | retired-product-path |
| `.github/workflows/style-guide-candidate-cases.json` | IDs 223–225, 227–228, 231–260, 379–390; live PS#155 | A06 | [R06](../../RETIREMENT-REVIEW.md#r06-dormant-archive-promotion-and-automatic-writer), [R07](../../RETIREMENT-REVIEW.md#r07-removed-and-relocated-runtime-tests) | retired-product-path |
| `.github/workflows/trust-root-authorization.json` | IDs 72–73, 82 | A03 | [R03](../../RETIREMENT-REVIEW.md#r03-exact-byte-maintenance-admission) | retired-product-path |
| `.github/workflows/workflow-common-reference.json` | IDs 19–40 | A03 | [R02](../../RETIREMENT-REVIEW.md#r02-exact-semantic-source-and-release-label-profiles), [R07](../../RETIREMENT-REVIEW.md#r07-removed-and-relocated-runtime-tests) | retired-product-path |
| `.github/workflows/workflow-common-validator.reference.txt` | IDs 19–40 | A03 | [R02](../../RETIREMENT-REVIEW.md#r02-exact-semantic-source-and-release-label-profiles), [R07](../../RETIREMENT-REVIEW.md#r07-removed-and-relocated-runtime-tests) | retired-product-path |
| `.github/workflows/workflow-isolation-reference.json` | IDs 19–40 | A03 | [R02](../../RETIREMENT-REVIEW.md#r02-exact-semantic-source-and-release-label-profiles), [R07](../../RETIREMENT-REVIEW.md#r07-removed-and-relocated-runtime-tests) | retired-product-path |
| `.github/workflows/workflow-isolation-validator.reference.txt` | IDs 19–40 | A03 | [R02](../../RETIREMENT-REVIEW.md#r02-exact-semantic-source-and-release-label-profiles), [R07](../../RETIREMENT-REVIEW.md#r07-removed-and-relocated-runtime-tests) | retired-product-path |
| `.github/workflows/workflow-ordinary-selftest-reference.json` | IDs 19–40 | A03 | [R02](../../RETIREMENT-REVIEW.md#r02-exact-semantic-source-and-release-label-profiles), [R07](../../RETIREMENT-REVIEW.md#r07-removed-and-relocated-runtime-tests) | retired-product-path |

R01 deliberately retired duplicate body-identity storage; exact native review-head/material-scope attribution remains with A03/A08. R02 removed brittle profile fixtures, while R07 says full old-to-new test equivalence remains unproved; A03/A07 must map useful threats to current callers. R03 retired the exact-byte authorizer but retains a material enforcement assessment for A03/A12/A13. R04 removed the global current-base sweep while keeping targeted freshness mandatory. R06's paired archive/context helpers are retired for the current no-promotion-consumer architecture; A06 validates current caller behavior, and A14 owns live filesystem residuals. These are current-owner dispositions, not authorization to restore old code.

TF #25's absent Gate A helper, catalog and PowerShell harness paths are current requirements assigned to A16; the recovery preparer belongs to A17. The A15 document specifies their intended interfaces and limits. `Test-StateRecoveryExamples.sh` is a stale issue locator: A15 identifies the real native harness as `Test-StateRecoveryExamples.mjs` (TF-only in the current union) and recommends retaining it. That recommendation remains subject to A15 acceptance; no `.sh` wrapper is inferred.

Four original ID 12 references point to `docs/planning/...` files. They are classified separately in the coverage JSON as planning-only sources outside the PS/TF product main trees. Keep `planning-CRT-PR-852` unmerged into either product main.

Requested route: `gpt-6-luna/medium`; effective model/effort metadata was not exposed in this subagent session. No native product mutation was performed.

## Coordinator acceptance

Accepted after independent raw Git tree/mode comparison for all 81 paths, current native-main readback, all 26 absent product-path checks and primary-owner validation. The A02 metadata-classification consumer and dedicated SelfTest portions are assigned to A02; A06 retains all unrelated validator/test surfaces. Final issue and tree census must still refresh in A18/A19.

[Post226 refresh](CURRENT-REFRESH-POST226.md) pins PS2a2d14a/treef5a and unchanged TF06ad4f7/treedc8. Complete raw union remains83 paths (10equal,55different,8PS-only,10TF-only); only workflow caller and classifier test changed. All148 raw entries were verified by the worker, all148 tree entries and six raw samples by root. Five issues/seven comments remain unchanged, zero open PRs; historical81/402 and26 absent-both references remain intact. Actual landed source acceptance remains separately owned by A02.
