<!-- markdownlint-disable-file MD013 -->

# PSStyleGuide and TerraformStyleGuide close-out and tooling-reuse plan

## Purpose

Complete the open PSStyleGuide P1A work, land the related TerraformStyleGuide tooling standard, reuse each repository's finished work in the other repository, correct the P1B dependency model, and prepare the remaining work in an enforceable order.

Keep both repositories self-contained. Do not create a shared runtime module or load governance instructions from a moving branch in another repository.

## Verified starting state

State in this section was verified at `2026-08-12T04:56:49Z`.

Use this section as the initial gate. Re-query GitHub immediately before each write or merge. If a listed head, tree, base, changed-path set, check result, review state, or branch state has changed, stop and repeat the affected review and validation.

### TerraformStyleGuide

- [PR #27](https://github.com/franklesniak/TerraformStyleGuide/pull/27) is merged at `aae05282b57f093cec8b63e59138db72c982f10e`.
- [PR #29](https://github.com/franklesniak/TerraformStyleGuide/pull/29) is merged at `fbdecbae787055a2117d4ada83ae294a7decfe62`.
- [PR #30](https://github.com/franklesniak/TerraformStyleGuide/pull/30) is an open draft. Its reviewed head is `1783c8a6ecb113226dab567a7da194c5fc057a7b`, its head tree is `3c6e54be9d722b8f61aa225b1414f228f7531268`, its base is `fbdecbae787055a2117d4ada83ae294a7decfe62`, and its base tree is `09d875e2bc48f4d3a7584d06dfbb5084ff2bbebb`. GitHub reports `MERGEABLE` and `CLEAN`. The `verify`, `policy`, `publish`, and `markdownlint` checks pass. Its one review thread is resolved. Codex and Copilot reported no actionable finding at this head; Copilot reviewed all five changed paths.
- [Issue #21](https://github.com/franklesniak/TerraformStyleGuide/issues/21) is open. It does not yet identify PSStyleGuide PR #153 as its implementation source, and it does not include the external case-catalog path in its affected-file contract.
- Native dependencies already make closed issues #20 and #28 block #21, and make #21 block #22. Do not change those relationships for this plan.

### PSStyleGuide

- [PR #153](https://github.com/franklesniak/PSStyleGuide/pull/153) is an open draft. Its reviewed head is `8444730a8ad560b33700877a3d447ad632134e0d`, its head tree is `46f5f4e8627eb341ddc4ef0c8d52483dc4006b50`, its base and current `main` are `3b611fd47a8eb9b24248715be7df97b0f3115e6b`, and its base tree is `47d2b5ad8c41b477c1aad602ce81e3879b5ae90d`. GitHub reports `MERGEABLE` and `CLEAN`. The `verify_generated_artifacts` and `markdownlint` checks pass. All 220 review threads are resolved. Codex posted two clean verdicts at this exact head. Copilot reviewed only `CLAUDE.md` at this head and raised no actionable finding.
- PR #153 has no formal approving review. PSStyleGuide does not require one.
- PR #153 changes exactly the four candidate-validator paths allocated by [issue #146](https://github.com/franklesniak/PSStyleGuide/issues/146), plus owner-directed `CLAUDE.md`.
- [Issue #152](https://github.com/franklesniak/PSStyleGuide/issues/152) has owner approval for its original exact request digests. No PSStyleGuide ruleset exists, and classic protection for `main` is absent. The issue does not yet contain TerraformStyleGuide PR #29's bypass-eligibility finding.
- Native dependencies currently make closed #145 block #146, make #146 and #152 block #147, and make #147 block #148. The required #146-to-#152 edge is missing.
- [Issues #155](https://github.com/franklesniak/PSStyleGuide/issues/155) and [#156](https://github.com/franklesniak/PSStyleGuide/issues/156) have no native dependency edges. This is correct.
- Remote branch `claude/psstyleguide-infra-style-conformance` is at `904df87c24abb4abcb44d2a71859c0589b82c167`. It changes exactly `.github/workflows/Generate-StyleGuideArtifacts.ps1`, `.github/workflows/Test-ExactGitPathSet.ps1`, and `.github/workflows/build.yml`. No pull request exists for this branch.
- PSStyleGuide has no supply-freeze recorder or reproducibility document and has no focused issue to add them.
- PSStyleGuide has no `.claude/commands/review-loop.md` on `main` or PR #153.

## Dependency and execution model

Use native dependencies to express issue completion prerequisites. Use the ordered phases below to coordinate cross-repository work.

| Issue | Blocked by | Blocks | Meaning |
| --- | --- | --- | --- |
| PSStyleGuide #146 | #145, already closed | #152 and #147 | P1A must land before either successor can complete. |
| PSStyleGuide #152 | #146 | #147 | The protection proof and activation cannot complete before P1A lands. |
| PSStyleGuide #147 | #146 and #152 | #148 | P1B can be implemented after #146, but it cannot merge before #152 completes. |
| PSStyleGuide #155 | none | none | Trigger-based TOCTOU and handle-identity residual tracker. |
| PSStyleGuide #156 | none | none | Trigger-based hardening and runner-coverage tracker. |

The issue-level completion order is:

```text
PS #145 complete -> PS #146 complete -> PS #152 complete -> PS #147 complete -> PS #148 complete
```

The interleaved P1B execution order is:

```text
PS #146 merges -> PS #147 writer reaches a reviewed head -> PS #152 temporary proof and persistent activation -> PS #152 closes -> PS #147 merges
```

Issue #152 blocks completion of #147. It does not block implementation work on #147.

## Phase 0 — correct dependency metadata and protect the deadline

### 0.1 Add #146 as a blocker of #152

Add the missing native relationship now. Keep the existing direct #146-to-#147 edge because #147 consumes P1A's landed contract directly.

The installed GitHub CLI does not expose the new dependency flags. Use the REST endpoint or the GitHub issue UI. The REST database ID of #146 is `5026315108`:

```powershell
gh api `
    --method POST `
    -H 'Accept: application/vnd.github+json' `
    -H 'X-GitHub-Api-Version: 2026-03-10' `
    repos/franklesniak/PSStyleGuide/issues/152/dependencies/blocked_by `
    -F issue_id=5026315108
```

Verify both directions:

```powershell
gh api repos/franklesniak/PSStyleGuide/issues/152/dependencies/blocked_by `
    --jq '.[] | [.number, .state, .title] | @tsv'
gh api repos/franklesniak/PSStyleGuide/issues/146/dependencies/blocking `
    --jq '.[] | [.number, .state, .title] | @tsv'
```

Require #152 to list #146 under `blocked by`, and require #146 to list both #152 and #147 under `blocking`.

### 0.2 Correct the #147 dependency comment

Post a superseding comment on #147 that links the 2026-08-09 dependency comment and states:

- #155 and #156 are independent, trigger-based follow-up trackers;
- neither issue is blocked by #147;
- neither issue blocks #147;
- #147 may address an item opportunistically, but it does not have to close either tracker; and
- if one item becomes mandatory for P1B, create or identify a focused actionable issue and make only that issue block #147.

Do not add a native edge to #155 or #156.

### 0.3 Run issue #149 on a parallel deadline track

[Issue #149](https://github.com/franklesniak/PSStyleGuide/issues/149) is independent of this merge sequence, but its advisory decision expires at `2026-08-30T23:59:59Z`. Complete #149 before that time, or land a separately approved superseding decision and all required digest updates. Otherwise, the workflow-policy validator begins failing with `advisory-expired`.

Do not place #149 behind #147 or #148.

## Phase 1 — close TerraformStyleGuide PR #30

Complete this phase before PSStyleGuide PR #153 so later PSStyleGuide infrastructure work can pin a landed Terraform source.

### 1.1 Mark PR #30 ready

Run:

```powershell
gh pr ready 30 --repo franklesniak/TerraformStyleGuide
```

A draft pull request cannot merge. Wait for reviews triggered by the ready-state transition. Process any new actionable finding through the repository's review protocol. Do not repeat the completed deferral sweep unless the ready transition, head, base, body, or review record adds new material.

### 1.2 Reconfirm the immutable merge gate

Immediately before merge, require all of the following:

- head `1783c8a6ecb113226dab567a7da194c5fc057a7b`;
- head tree `3c6e54be9d722b8f61aa225b1414f228f7531268`;
- base `fbdecbae787055a2117d4ada83ae294a7decfe62`;
- base tree `09d875e2bc48f4d3a7584d06dfbb5084ff2bbebb`;
- the four checks still pass;
- all review threads are resolved; if the ready transition adds no thread, the count remains one;
- the ready-state reviews contain no actionable finding; and
- the changed-path set remains the following five paths.

| Path | Reviewed-head blob |
| --- | --- |
| `.github/workflows/Generate-StyleGuideArtifacts.ps1` | `e5bdd8f64569541eb3c724387dfdff1847c18793` |
| `.github/workflows/Validate-WorkflowPolicy.mjs` | `fb17e06f2f456a0d7df510b0bb34c52d88b7893b` |
| `.github/workflows/build.yml` | `f68dfe2da4842d2086b079e09328e3298856123e` |
| `CLAUDE.md` | `c4100bfa36526643d04f6a5571d1ea2dd807b2d3` |
| `docs/decisions/0003-accept-required-check-workflow-edit-residual.md` | `cd37e7714da3c3471964e94ae1203f798f0c2e97` |

If any item differs, stop and repeat the affected validation and review.

### 1.3 Merge and verify

Use a merge commit. This preserves the three logical commits and matches the method used for TerraformStyleGuide PRs #27 and #29.

After merge:

1. Record the landed merge commit and tree as `TF_PR30_LANDED_COMMIT` and `TF_PR30_LANDED_TREE`.
2. Confirm PR #30 reports `MERGED`.
3. Confirm the five landed blobs match the reviewed-head table.
4. Confirm TerraformStyleGuide `main` points to `TF_PR30_LANDED_COMMIT`.
5. Use `TF_PR30_LANDED_COMMIT`, not the reviewed head or GitHub's test-merge ref, as the source pin in later work.

## Phase 2 — close PSStyleGuide PR #153 and hand P1A to P1B

No further code change is required at the verified starting head. The remaining merge blocker is the draft state.

### 2.1 Mark PR #153 ready

Run:

```powershell
gh pr ready 153 --repo franklesniak/PSStyleGuide
```

Wait for the ready-state automated review. Process any new actionable finding before merge.

### 2.2 Reconfirm the immutable merge gate

Immediately before merge, require all of the following:

- head `8444730a8ad560b33700877a3d447ad632134e0d`;
- head tree `46f5f4e8627eb341ddc4ef0c8d52483dc4006b50`;
- base and PSStyleGuide `main` `3b611fd47a8eb9b24248715be7df97b0f3115e6b`;
- base tree `47d2b5ad8c41b477c1aad602ce81e3879b5ae90d`;
- `markdownlint` and `verify_generated_artifacts` still pass;
- all review threads are resolved; if the ready transition adds no thread, the count remains 220;
- the ready-state review has no actionable finding; and
- the changed-path set remains the four candidate-validator files plus `CLAUDE.md`.

If the head or base changes, stop. Repeat every validation and review affected by the changed bytes or merge base.

### 2.3 Squash and merge

Use squash merge. Replace the generated list of review-loop commits with this message:

```text
P1A: Add a fail-closed cross-platform style-guide candidate validator (#153)

Closes #146.

Reviewed head: 8444730a8ad560b33700877a3d447ad632134e0d
Reviewed tree: 46f5f4e8627eb341ddc4ef0c8d52483dc4006b50
Validation: Windows PowerShell 5.1, PowerShell 7 on Windows, and PowerShell 7 on Ubuntu passed with zero failures.
```

Record the merge method as `squash`.

### 2.4 Verify the landed result

After merge:

1. Fetch PSStyleGuide `main`.
2. Record the landed commit and tree as `PS_PR153_LANDED_COMMIT` and `PS_PR153_LANDED_TREE`.
3. Confirm PR #153 reports `MERGED`.
4. Confirm issue #146 closed through `Closes #146`.
5. Confirm the five landed blobs match the reviewed head.
6. Do not record GitHub's pre-merge test-merge SHA as the landed commit.

| Path | Version or schema | SHA-256 | Reviewed-head blob |
| --- | --- | --- | --- |
| `.github/workflows/Expand-StyleGuideCandidateArtifact.ps1` | `1.0.20260811.0` | `afdb3173b5de0aa76d1a83012e028d96b09d797864a12e5af83974132425e7ae` | `7706559958972ae76cc080142ca4b8fb3ab50548` |
| `.github/workflows/Manage-StyleGuideCandidateInvocationContext.ps1` | `1.0.20260811.0` | `823ff614bf6dcacded1b88941c99884c343de4a52a866e28d00c664f27fe134d` | `bd6cb2a6d1f3d59293b43be5c999de3e306a9b0d` |
| `.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1` | `1.0.20260811.0` | `2a4a8d4708f5979f37cc6a6e2666d7342ac22bf4bfd08d167a67d1319ba40a4b` | `1bdd44aa3f6f596fd771bc6e216a531a92f9aa9f` |
| `.github/workflows/style-guide-candidate-cases.json` | schema `1`; version `1.0.20260805.1` | `5373c14916ed6d696ca3f0f1e5d10011cf33d3036b90b2415a535f2a629f6bbc` | `0e81b9a8f57f6369eec5a47e2ea3310b06e00fd1` |
| `CLAUDE.md` | `1.0.20260811.1` | `e65e9d737770bfce82b37b0c3d4e31e3e4d1896b4b18a86139b25572185e7503` | `6bc9e1a92e47b129418420f4ad0e79965f0d7622` |

The catalog allocation digest is `1670cdfcfdd2c7c22ca21b4ace19f59cd7bdb104d2503d8791b8639a28918c0e`. The catalog contains 115 physical cases.

Retain this supplemental local read-only evidence from the same reviewed head:

| Command or runtime | Recorded result |
| --- | --- |
| `npm run lint:md` | 18 files, 0 errors, exit 0 |
| `npm run lint:md:nested` | 15 files and 18 nested blocks, 0 errors, exit 0 |
| `node Validate-WorkflowPolicy.mjs build.yml markdownlint.yml` | `success: true`, 46 fixtures, exit 0 |
| Windows PowerShell 5.1 harness, non-elevated, process-scoped `-ExecutionPolicy Bypass` | 115 verdicts: 110 pass, 0 fail, 5 authorized environment skips, exit 0 |
| PowerShell 7.6.4 harness on Windows | 115 verdicts: 114 pass, 0 fail, 1 authorized skip, exit 0 |

The non-elevated Windows PowerShell run exercised fewer link primitives than the owner's elevated run. The working tree stayed clean.

### 2.5 Post the permanent P1A-to-P1B handoff on issue #147

Post one permanent comment on #147 after the merge. Use the existing [P1A-to-P1B handoff comment](https://github.com/franklesniak/PSStyleGuide/pull/153#issuecomment-5171850290) only as a structural template because its identities predate the final reviewed head. Replace every provisional identity with the final reviewed and landed values.

The comment must contain:

- permanent URLs for issues #146 and #147 and PR #153;
- reviewed head, reviewed tree, base commit, base tree, merge method, landed commit, and landed tree;
- all three script versions, SHA-256 values, and Git blobs;
- catalog schema, version, SHA-256, allocation digest, Git blob, and 115-row count;
- the public expansion entry parameters: required `Context`, `CheckoutRoot`, `TrustedTemporaryRoot`, `DownloadDirectory`, `CandidateDirectory`, and `ExpectedDigest`; optional `ArtifactId`, `RunId`, and `RunAttempt`;
- public function `New-StyleGuideCandidateInvocationContext`, with required `TrustedTemporaryRoot` and optional `DiagnosticLabel`;
- public functions `Remove-StyleGuideCandidateInvocationContext` and `Remove-StyleGuideCandidateInvocationState`, each with required `Context` only;
- the harness interface with required `HelperPath` and `ContextManagerPath` and its separately trusted expected-version metadata;
- context type `PSStyleGuide.CandidateInvocationContext.v1` and its ordered properties: `SchemaVersion`, `ContextScriptVersion`, `InvocationId`, `DiagnosticLabel`, `TrustedParentPath`, `InvocationRootPath`, `DownloadDirectoryPath`, `CandidatePath`, `LifecycleState`, `NextSequence`, and `OwnershipJournal`;
- ownership-record type `PSStyleGuide.CandidateOwnershipRecord.v1` and its ordered properties: `SchemaVersion`, `Sequence`, `Kind`, `Path`, `ParentPath`, `LeafName`, `ExpectedEntryType`, `CreationPhase`, `EntryState`, `ContentLength`, and `ContentSha256`;
- lifecycle states `Active`, `CleanupFailed`, and `Disposed`;
- cleanup-result type `PSStyleGuide.CandidateCleanupResult.v1` and its ordered properties: `SchemaVersion`, `ContextScriptVersion`, `InvocationId`, `PreviousState`, `FinalState`, `Success`, `DiagnosticCode`, `FilesystemCallCount`, and `RetainedRecordSequences`;
- the final closed diagnostic, subreason, phase, applicability, skip, and oracle sets extracted from the landed catalog and harness;
- the trusted-script proof for HEAD, stage-0 index, no-filter working blob, mode, path, version, and fixed absolute Git identity;
- the primitive-probe, cleanup, zero-call terminal-repeat, and retained-uncertainty evidence;
- the final five-path proof, with the four issue-allocated paths separated from owner-directed `CLAUDE.md`;
- links to residual trackers #155 and #156 and an explicit statement that neither blocks P1B;
- the final P1A-to-T1A matrix, its corrected source pin, and the fact that it has no unexplained blocker; use the [matrix](https://github.com/franklesniak/PSStyleGuide/pull/153#issuecomment-5156046279), [final refresh](https://github.com/franklesniak/PSStyleGuide/pull/153#issuecomment-5171839009), and [pinning correction](https://github.com/franklesniak/PSStyleGuide/pull/153#issuecomment-5172392252) as evidence, not as substitutes for the final landed pin; and
- an explicit statement that TerraformStyleGuide issue #21 must consume `PS_PR153_LANDED_COMMIT`.

Include the final runtime table:

| Runtime | Pass | Fail | Skip |
| --- | ---: | ---: | ---: |
| Windows PowerShell 5.1 / Windows, elevated | 113 | 0 | 2 |
| PowerShell 7.6.4 / Windows, elevated | 114 | 0 | 1 |
| PowerShell 7.6.4 / Ubuntu | 113 | 0 | 2 |

State that every skip was authorized by the catalog's applicability contract. Map each unchecked acceptance criterion in #146 to a specific PR #153 section, harness result, runtime row, or landed identity. Do not duplicate the full record by rewriting the #146 body.

## Phase 3 — revise TerraformStyleGuide issue #21 to reuse landed P1A

Do not start this phase until PSStyleGuide PR #153 is merged and `PS_PR153_LANDED_COMMIT` is known.

### 3.1 Add the reuse starting point

Insert a `## Starting point — reuse the landed PSStyleGuide P1A implementation` section after `## Summary` and before `## Dependency`.

The section must state all of the following:

1. T1A starts from PSStyleGuide `PS_PR153_LANDED_COMMIT`. It must not rebuild the validator, invocation-context manager, or adversarial harness from the beginning.
2. The T1A pull request must record `PS_PR153_LANDED_COMMIT` and the four source blob IDs read from that landed commit. It must not follow a moving branch.
3. Copy and adapt these four files:
   - `.github/workflows/Expand-StyleGuideCandidateArtifact.ps1`;
   - `.github/workflows/Manage-StyleGuideCandidateInvocationContext.ps1`;
   - `.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1`; and
   - `.github/workflows/style-guide-candidate-cases.json`.
4. Preserve the source security intent: raw parameter boundaries; path, component, and link checks; one-read digest binding; bounded ZIP parsing; manifest and resource ceilings; fresh-file extraction; nonrecursive cleanup; and HEAD/index/no-filter Git-blob script identity through fixed absolute native-command locations.
5. Keep the issue's existing requirement for one archive read into a private buffer and fixed absolute native-command locations.
6. Change each case ID prefix from `PS-P1A-` to `T1A-`.
7. Rebuild objects to the exact `TerraformStyleGuide.StyleGuideCandidate…` schemas and lifecycle states required by issue #21. Do not copy `PSStyleGuide.Candidate…` type names. Preserve fail-closed behavior.
8. Change manifest name `powershell.instructions.md` to `terraform.instructions.md`. Keep the other three manifest names.
9. Keep all implementation paths and the case catalog under `.github/workflows/`.
10. Keep `style-guide-candidate-cases.json` as the machine-readable catalog. The harness validates its schema and allocation and pins its SHA-256.
11. Preserve all 115 source rows. Add the Terraform-only rows needed to satisfy issue #21's 141-row physical allocation. Do not repurpose a source row.
12. Refresh the preliminary P1A-to-T1A matrix at implementation start and again before merge. Record every kept, changed, and blocked behavior and the reason for each change. An unexplained security or error-handling difference blocks merge.
13. Do not copy `CLAUDE.md`. TerraformStyleGuide owns its file through landed PR #30.
14. Keep the two repositories independent. Do not create a shared cross-repository runtime package.

Read the blobs again from `PS_PR153_LANDED_COMMIT`. The expected values are:

| Source file | Expected Git blob |
| --- | --- |
| `Expand-StyleGuideCandidateArtifact.ps1` | `7706559958972ae76cc080142ca4b8fb3ab50548` |
| `Manage-StyleGuideCandidateInvocationContext.ps1` | `bd6cb2a6d1f3d59293b43be5c999de3e306a9b0d` |
| `Test-Expand-StyleGuideCandidateArtifact.ps1` | `1bdd44aa3f6f596fd771bc6e216a531a92f9aa9f` |
| `style-guide-candidate-cases.json` | `0e81b9a8f57f6369eec5a47e2ea3310b06e00fd1` |

If a blob differs, review the source change before copying it. Record the actual landed blob, not the expected value, after that review.

### 3.2 Strengthen the reciprocal-comparison section

Add this requirement first under `## Reciprocal PSStyleGuide comparison`:

> This section also records the reuse result. The Starting point section requires reuse of landed PSStyleGuide PR #153. Record each behavior that the copy keeps, changes, or blocks. Give a reason for every changed behavior. An unexplained security or error-handling difference blocks merge. Refresh the preliminary matrix at implementation start and before merge.

### 3.3 Correct the affected-file and catalog contracts

Make all of these edits in issue #21:

1. Change the affected-file count from three to four and add `.github/workflows/style-guide-candidate-cases.json`.
2. Change `only the three affected files changed/staged` to `only the four affected files changed/staged` in Validation.
3. Change `exactly the three affected files` to `exactly the four affected files` in Acceptance criteria.
4. In sections 10 and 13, name `.github/workflows/style-guide-candidate-cases.json` as the machine-readable source. Keep the harness responsible for schema validation, allocation checks, and the recorded SHA-256 pin.

After editing, re-read the issue body and require one internally consistent four-path contract, one 141-row requirement, no provisional PR #153 head pin, and no instruction to copy PSStyleGuide `CLAUDE.md`.

## Phase 4 — amend PSStyleGuide issue #152 and finalize its decision gates

Complete this phase before any #152 execution window and before #147 gains `contents: write`.

### 4.1 Add the live bypass-eligibility finding

Pin these immutable sources in the issue:

- TerraformStyleGuide PR #29 merge commit `fbdecbae787055a2117d4ada83ae294a7decfe62`; and
- its original decision-record blob `af73aa23d094fa455680797554d38a70d363c7cb`.

Add a section that states:

1. `GET /apps/github-actions` proves the public application's owner, slug, and ID. It does not prove that the application is an eligible bypass actor for PSStyleGuide.
2. TerraformStyleGuide's live ruleset UI did not offer the built-in GitHub Actions application as a bypass actor.
3. Before the temporary proof window, use the PSStyleGuide ruleset UI to perform a non-mutating eligibility check. If GitHub Actions is not offered in the bypass suggestions, stop. Do not force integration ID `15368` through an undocumented or API-only request.
4. If the actor is offered, the temporary proof must still demonstrate effective bypass by the exact reviewed writer. Selection is not proof of effective behavior.
5. If eligibility or effective bypass fails, do not create the persistent ruleset. Run a new owner decision that evaluates at least:
   - a supported installed GitHub App with bounded credentials and explicit bypass;
   - a write-enabled deploy key with an approved credential lifecycle;
   - a pull-request-based promotion design that needs no direct-push bypass; and
   - an interim no-bypass ruleset that delays the writer.
   List all material options, build a fresh weighted rubric, show the scoring table, and state the selected design before implementation. Re-evaluate the #147/#152 scopes and native dependencies if the selection changes their completion contract.
6. Do not add the owner, administrators, a repository role, or another human bypass without a separately approved decision.
7. Retain PSStyleGuide's own ruleset IDs, normalized JSON, digests, effective-rule evidence, and rollback evidence. Do not copy TerraformStyleGuide's ruleset ID or effective-rule digest.
8. Reopen or supersede PSStyleGuide decision 0001 during #147. GitHub reports a skipped job as successful, so required checks do not prevent a pull request from editing a workflow to make the required job skip.

### 4.2 Make the original approval scope explicit

Update the stale approval-state text in the issue body. State that the owner approved the original exact request digests on 2026-08-01 and link the approval comment. State that this approval does not authorize a redesigned writer, a different bypass actor, or different request bytes. Any redesign requires new canonical requests, new digests, a new decision record, and new owner approval.

Preserve the original request objects and digests as historical evidence. Do not present them as executable if the eligibility gate fails.

## Phase 5 — open a focused PSStyleGuide supply-freeze reproducibility issue

Open one focused issue titled `Port the reproducible supply-freeze recorder and method from TerraformStyleGuide`.

Pin TerraformStyleGuide PR #27 merge commit `aae05282b57f093cec8b63e59138db72c982f10e` and these source blobs:

| Source | Git blob |
| --- | --- |
| `.github/workflows/Get-SupplyFreezeDigest.mjs` | `05778c0eda0273a9217f7dc953795c2240473a14` |
| `docs/T1-SUPPLY-FREEZE-v1.md` | `36010d2dac98631845d8e880689f7c315ccbcdb7` |

The issue must require the implementer to:

1. Compare TerraformStyleGuide's supply-freeze record with PSStyleGuide's existing `P1-SUPPLY-FREEZE-v1` object in `.github/workflows/workflow-policy-contract.json`.
2. Adapt the recorder to PSStyleGuide's existing field names and schema. Do not rename the PSStyleGuide contract to the TerraformStyleGuide schema.
3. Adapt the reproducibility document. Identify fields the script derives and fields that require Git or another external command. Do not claim that the script derives all fields.
4. Keep the recorder read-only. Do not add it to a workflow unless a later issue explicitly authorizes that change.
5. Re-evaluate `docs/decisions/0002-accept-unverifiable-baseline-provenance.md`. Do not retire it merely because the recorder exists. The historical `baseline` values still require Git-object access. Amend or retire decision 0002 only if the change supplies a real verification procedure for those fields.
6. Record tool identity, input identities, output schema, refusal modes, and reproducibility commands.
7. Prove that the recorder does not change the manifest, lockfile, installed tree, contract, generated output, or repository working tree.

This issue schedules a focused port. It does not block PR #153, issue #152, or P1B.

## Phase 6 — open a separate Claude command-parity issue

After PR #153 lands, open a small PSStyleGuide issue to add `.claude/commands/review-loop.md` as a local command wrapper.

Pin TerraformStyleGuide commit `fbdecbae787055a2117d4ada83ae294a7decfe62` and blob `7b0e41361a8ab7259245ad5f0d86d9300008347d` as design input. Do not copy the blob unchanged: it says `all six steps`, while PSStyleGuide's landed `CLAUDE.md` defines nine review-comment handling steps.

The issue must require:

- explicit owner authorization before adding the command because it is an agent entry point;
- a thin wrapper that accepts the pull request URL, requires a URL when none is supplied, and delegates the authoritative process to the repository-local root `CLAUDE.md`;
- no fetch from a moving external branch and no shared runtime dependency;
- both Codex and Copilot as co-equal reviewers, as defined by local `CLAUDE.md`;
- no duplicated step count, gate count, round limit, or other volatile protocol detail that can drift from `CLAUDE.md`;
- Markdown lint validation; and
- a documented comparison with the Terraform command that records every intentional difference.

Keep this issue separate from the supply-freeze port and from the infrastructure-conformance pull request.

## Phase 7 — land the PSStyleGuide infrastructure-conformance branch

Do not start this phase until both PR #30 and PR #153 are merged. Use `TF_PR30_LANDED_COMMIT` and `PS_PR153_LANDED_COMMIT` as immutable sources.

### 7.1 Rebase without losing the existing patch

1. Fetch `origin`.
2. Check out `claude/psstyleguide-infra-style-conformance`.
3. Confirm its pre-rebase head is `904df87c24abb4abcb44d2a71859c0589b82c167` and its patch changes only the three recorded paths.
4. Rebase onto PSStyleGuide `main` at `PS_PR153_LANDED_COMMIT`.
5. Preserve the complete three-file patch introduced by `904df87c24abb4abcb44d2a71859c0589b82c167`. A rebase rewrites commit IDs; record the original ID and the rebased ID. Do not claim the old commit ID survived.
6. Resolve conflicts without editing `CLAUDE.md` or the four landed candidate-validator files.

### 7.2 Reconcile with landed TerraformStyleGuide PR #30

Read the PowerShell-conformance changes at `TF_PR30_LANDED_COMMIT`. Compare them with all three PSStyleGuide branch files. Apply the same applicable idioms:

- descriptive type-prefixed local names;
- `List[T]` instead of array `+=` accumulation;
- `[void]` for intentional output suppression;
- complete comment-based help;
- approved singular function names; and
- descriptive loop variables.

Keep behavior unchanged. Record each repository-specific difference.

Do not copy TerraformStyleGuide issue #28 closure text, TerraformStyleGuide decision identifiers, ruleset identifiers, or repository-specific evidence. Reuse only the applicable PowerShell-authoring reasoning.

Do not edit protected instruction files. PR #153 owns the PSStyleGuide `CLAUDE.md` addition.

If a PowerShell script receives a material edit on a later UTC date, update its `.NOTES` version and every trusted version pin according to `STYLE_GUIDE.md`. Refresh every affected workflow-policy digest, version, fixture, and name pin after the final bytes settle.

Regenerate generated output when required. Require zero generated drift.

### 7.3 Validate the rebased work

For every touched PowerShell or workflow file, require:

- zero PowerShell parser errors;
- zero PSScriptAnalyzer warnings or errors;
- zero applicable `STYLE_GUIDE.md` `MUST` or `MUST NOT` violations;
- no tabs or trailing whitespace;
- Markdown lint and nested-Markdown lint success;
- workflow-policy validation success;
- generator drift verification success; and
- exact-path verification success.

Run the repository commands from the repository root:

```powershell
$arrPowerShellPath = @(
    '.github/workflows/Generate-StyleGuideArtifacts.ps1',
    '.github/workflows/Test-ExactGitPathSet.ps1'
)
foreach ($strPowerShellPath in $arrPowerShellPath) {
    $arrToken = $null
    $arrParseError = $null
    [void][System.Management.Automation.Language.Parser]::ParseFile(
        $strPowerShellPath,
        [ref]$arrToken,
        [ref]$arrParseError
    )
    if (@($arrParseError).Count -ne 0) {
        throw "Parser errors were found in $strPowerShellPath."
    }

    $arrAnalyzerFinding = @(
        Invoke-ScriptAnalyzer `
            -Path $strPowerShellPath `
            -Severity Warning, Error
    )
    if ($arrAnalyzerFinding.Count -ne 0) {
        throw "PSScriptAnalyzer findings were found in $strPowerShellPath."
    }
}

npm --prefix .github/workflows run lint:md
npm --prefix .github/workflows run lint:md:nested

Push-Location '.github/workflows'
try {
    node Validate-WorkflowPolicy.mjs build.yml markdownlint.yml
}
finally {
    Pop-Location
}

pwsh -NoLogo -NoProfile -NonInteractive `
    -File './.github/workflows/Generate-StyleGuideArtifacts.ps1'
git diff --exit-code -- `
    copilot-instructions.md `
    powershell.instructions.md `
    STYLE_GUIDE_CHAT.md `
    STYLE_GUIDE_FULL.md
```

Run the parser and analyzer block under Windows PowerShell 5.1 and PowerShell 7 when both runtimes are available. Record the runtime and PSScriptAnalyzer version with each result.

Commit before the identity-gated clean-tree verification. Then run:

```powershell
pwsh -NoLogo -NoProfile -NonInteractive `
    -File './.github/workflows/Test-ExactGitPathSet.ps1' `
    -RepositoryRoot (Get-Location).Path `
    -ExpectedPath @() `
    -Mode Working
```

Run the candidate harness only if the rebase or reconciliation changes a candidate script, its catalog, its contract, or another trusted input. If all trusted inputs are unchanged, record that the harness was not applicable and do not run it.

### 7.4 Push and open a separate pull request

Push the existing branch after validation. Open a separate pull request. Do not fold this work into PR #153.

The pull request must list:

- the three changed paths;
- the original branch head and the rebased commit;
- `TF_PR30_LANDED_COMMIT` and `PS_PR153_LANDED_COMMIT`;
- each conformance idiom applied;
- every version, digest, fixture, and name pin changed;
- every intentional repository difference;
- every validation command and exact result; and
- whether the candidate harness was applicable.

Do not add `.claude/commands/review-loop.md` in this pull request. That file belongs to the separate parity issue in Phase 6.

## Phase 8 — execute the P1B and protection interlock

After PR #153 lands and issue #152 contains the eligibility amendment:

1. Implement #147's writer and `Build Style Guide Artifacts / approve_candidate` terminal check.
2. Reopen or supersede `docs/decisions/0001-accept-in-repository-trust-root.md` before the writer gains `contents: write`.
3. Take the #147 pull request to a reviewed head. Record its exact head, tree, workflow identity, permissions, required-check name, unique evidence ref, and rollback inputs.
4. Start #152's bounded temporary proof window. Re-export current repository rules, classic protection, `main`, application identity, and writer permissions.
5. Perform the non-mutating bypass-eligibility check. If integration ID `15368` is unavailable, stop and run the new writer-design decision. Do not create a substitute rule.
6. If eligible, create the temporary field-equivalent rule, run the effective-bypass and rejection drills, retain the evidence, delete the temporary rule and evidence ref, and prove exact restoration in the same bounded session.
7. Immediately before #147 merges, revalidate the reviewed head and create the approved persistent ruleset.
8. Retain the create response, ruleset ID, normalized JSON and digest, effective rules, exact required check and integration, `main` before and after, and rollback proof.
9. Close #152 only after the persistent rule is active and its evidence is complete.
10. Merge and close #147 only after #152 closes.
11. Proceed to #148 after #147 completes.

Do not copy TerraformStyleGuide's rule ID, digests, or effective-rule JSON. Do not add a human bypass without a separate owner-approved decision.

## Independent follow-up policy for #155 and #156

Leave #155 and #156 open and independent.

Issue #155 owns these accepted residual gaps:

- the extraction race;
- the directory-creation race;
- Windows alias-to-descendant detection; and
- the regular-file-proof-to-open windows.

Issue #156 owns these recommended or unmeasured items:

- positional regular-file-proof wiring;
- direct journal-record-cap coverage;
- the Windows ACL refusal branch;
- a domain-joined Windows host with inherited access-control entries;
- non-GNU coreutils;
- non-Linux pattern matching; and
- the `PS-P1A-E-05` provider-check observation limit.

- Revisit #155 only if #146 admits a competing writer, Windows PowerShell 5.1 support ends and a portable API becomes available, or #147 or a later phase adopts a suitable native helper.
- Pick up #156 opportunistically during #147, when the candidate files next change, or when a suitable external runner becomes available.
- If one item becomes mandatory, split it into a focused actionable issue. Give that issue the real dependency. Do not use the broad tracker as a false blocker.

Neither issue blocks PR #153, #152, or #147 under the current contracts.

## Completion checks

This coordination plan is complete when all of the following are true:

- TerraformStyleGuide PR #30 is merged and its landed commit and tree are recorded.
- PSStyleGuide PR #153 is squash-merged; issue #146 is closed; the five landed blobs match the reviewed head; and the full landed P1A-to-P1B handoff is posted on #147.
- TerraformStyleGuide issue #21 names the landed PSStyleGuide source, contains a consistent four-file contract, and requires a 141-row adapted catalog.
- PSStyleGuide #152 is blocked by #146, still blocks #147, and contains the bypass-eligibility and approval-scope amendment.
- The misleading #147 statement about #155 and #156 is superseded, and those trackers still have no false dependency edges.
- The focused PSStyleGuide supply-freeze issue exists with PR #27's immutable source pins.
- The separate Claude command-parity issue exists with a local-protocol, no-drift design.
- The infrastructure-conformance branch is rebased, reconciled to landed PR #30, validated, pushed, and proposed as a separate pull request.
- #149 is completed before its deadline or a separately approved superseding decision and digest update has landed.
- The #147/#152 execution follows the interleaved sequence and retains PSStyleGuide-specific proof.

## References

- [GitHub issue dependencies](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/creating-issue-dependencies)
- [REST API endpoints for issue dependencies](https://docs.github.com/en/rest/issues/issue-dependencies?apiVersion=2026-03-10)
- [GitHub pull requests and draft state](https://docs.github.com/en/pull-requests/reference/pull-requests)
- [GitHub status-check behavior for skipped jobs](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/about-status-checks)
- [Creating rulesets for a repository](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/creating-rulesets-for-a-repository)
- [GitHub Actions `GITHUB_TOKEN`](https://docs.github.com/en/actions/concepts/security/github_token)
