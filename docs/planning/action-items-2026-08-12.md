<!-- markdownlint-disable-file MD013 -->

# PSStyleGuide-first cross-repository convergence and execution plan

## Purpose

Bring the already implemented PSStyleGuide P1 and TerraformStyleGuide T1 foundations into behavioral parity without a shared runtime module. First, complete the PSStyleGuide issues that import TerraformStyleGuide behavior. Second, complete the TerraformStyleGuide issues that import already landed PSStyleGuide behavior. Close each issue through a reciprocal comparison and any required sync-back work before the next implementation issue starts. Then run one repository-wide consistency sweep and use PSStyleGuide-first paired cycles for new work.

Keep each repository self-contained. A common behavior may differ only when a repository-specific name, file, schema prefix, check name, platform requirement, or historical decision requires it. Every other difference needs an explicit, reviewed reason and equal security and failure strength.

Issue creation, contract maintenance, dependency maintenance, and read-only comparison are setup activities. They do not commence implementation. Implementation starts only at an explicit commencement gate in the applicable execution step.

## Verified baseline

This state was verified at `2026-08-12T19:39:25Z`. Re-query GitHub and fetch both `origin/main` refs immediately before every issue edit, branch rewrite, merge, or settings change. If an identity or dependency has changed, stop and refresh the affected comparison.

### Completed coordination work

The following work is complete and is not part of the remaining work queue:

- PS issue #152 is blocked by closed #146 and still blocks #147.
- The superseding dependency clarification is on [PS issue #147](https://github.com/franklesniak/PSStyleGuide/issues/147#issuecomment-5262751210). PS issues #155 and #156 remain independent.
- [Terraform PR #30](https://github.com/franklesniak/TerraformStyleGuide/pull/30) merged at `fbfc3aca874e235cace92f506377f5c9e0704160`, tree `3c6e54be9d722b8f61aa225b1414f228f7531268`.
- [PS PR #153](https://github.com/franklesniak/PSStyleGuide/pull/153) squash-merged at `2d56357d9f52c76734027174bf62278e6f3d4cd6`, tree `46f5f4e8627eb341ddc4ef0c8d52483dc4006b50`, and closed issue #146.
- The permanent P1A-to-P1B handoff is on [PS issue #147](https://github.com/franklesniak/PSStyleGuide/issues/147#issuecomment-5262865571).
- [Terraform issue #21](https://github.com/franklesniak/TerraformStyleGuide/issues/21) pins PS PR #153's landed commit and four source blobs, names exactly four affected paths, preserves the 115 PS rows and 141-row Terraform allocation, prohibits copying `CLAUDE.md`, and requires reciprocal comparison.
- [PS issue #152](https://github.com/franklesniak/PSStyleGuide/issues/152) contains the Terraform PR #29 bypass-eligibility finding and the limited 2026-08-01 approval scope.
- [PS issue #158](https://github.com/franklesniak/PSStyleGuide/issues/158) exists with Terraform PR #27's immutable supply-freeze source pins.
- The verified native dependency chain is [PS #147](https://github.com/franklesniak/PSStyleGuide/issues/147) -> [#148](https://github.com/franklesniak/PSStyleGuide/issues/148) -> [#149](https://github.com/franklesniak/PSStyleGuide/issues/149) -> [#151](https://github.com/franklesniak/PSStyleGuide/issues/151). Both GitHub dependency views contain the #148-to-#149 relationship.
- [PS #159](https://github.com/franklesniak/PSStyleGuide/issues/159) is the foundation-convergence umbrella. Its ordered native sub-issues are [#160](https://github.com/franklesniak/PSStyleGuide/issues/160), [#161](https://github.com/franklesniak/PSStyleGuide/issues/161), [#162](https://github.com/franklesniak/PSStyleGuide/issues/162), and [#158](https://github.com/franklesniak/PSStyleGuide/issues/158).
- PS #160 blocks PS #161. PS #161 blocks PS #162.
- [PS #163](https://github.com/franklesniak/PSStyleGuide/issues/163) owns the separate Claude command-parity cycle.
- [Terraform #31](https://github.com/franklesniak/TerraformStyleGuide/issues/31) is the non-implementing tracker for all five initial reciprocal cycles.
- The deferred Terraform #22 and #24 update prompts and the PS #151 applicability path remain in Step 6.

### Current active work

[PS PR #164](https://github.com/franklesniak/PSStyleGuide/pull/164) is the only active feature implementation PR. It is configured to close PS #160 when it merges. It rebases the infrastructure-conformance patch onto PS `main` commit `2d56357d9f52c76734027174bf62278e6f3d4cd6`. The current head is `1e35e9b50045cca8946c97070109e3c9fc38c804`, and the current tree is `33937c64d45b20769cf80d1036fa9ffbf4077ebe`. The PR is open, draft, mergeable, and clean. Its `verify_generated_artifacts` and `markdownlint` checks pass. It is not a landed baseline.

### Immutable implementation baselines

| Role | Commit | Tree or relevant identity |
| --- | --- | --- |
| PS P1 implementation, PR #150 | `3b611fd47a8eb9b24248715be7df97b0f3115e6b` | Landed PS issue #145 implementation |
| Current PS `main` | `2d56357d9f52c76734027174bf62278e6f3d4cd6` | `46f5f4e8627eb341ddc4ef0c8d52483dc4006b50` |
| Terraform T1 implementation, PR #26 | `143f54e52075a1ae1e999a6e242073e3d8d4a46b` | Landed Terraform issue #20 implementation |
| Terraform supply-freeze method, PR #27 | `aae05282b57f093cec8b63e59138db72c982f10e` | `.github/workflows/Get-SupplyFreezeDigest.mjs` blob `05778c0eda0273a9217f7dc953795c2240473a14`; `docs/T1-SUPPLY-FREEZE-v1.md` blob `36010d2dac98631845d8e880689f7c315ccbcdb7` |
| Current Terraform `main`, PR #30 | `fbfc3aca874e235cace92f506377f5c9e0704160` | `3c6e54be9d722b8f61aa225b1414f228f7531268` |
| PS infrastructure-conformance source | `904df87c24abb4abcb44d2a71859c0589b82c167` | Original three-path patch based on PS PR #150 |
| PS infrastructure-conformance candidate, PR #164 | `1e35e9b50045cca8946c97070109e3c9fc38c804` | Draft tree `33937c64d45b20769cf80d1036fa9ffbf4077ebe`; five-path rebased candidate, not landed |

### Current convergence inventory

These current `main` files already have identical Git blobs in both repositories:

- `.gitattributes`;
- `.github/dependabot.yml`;
- `.github/workflows/.markdownlint.jsonc`;
- `.github/workflows/lint-nested-markdown.js`;
- `.github/workflows/MARKDOWN-LINTING-IMPLEMENTATION.md`; and
- `.github/workflows/scripts-README.md`.

Do not rewrite these files merely to prove parity.

The material common-foundation differences are:

| Area | PS source identity | Terraform source identity | Required disposition |
| --- | --- | --- | --- |
| Generator | `.github/workflows/Generate-StyleGuideArtifacts.ps1`, blob `c54012e549aedef827ae3ccb669b512a1f14c644` | Same path, blob `e5bdd8f64569541eb3c724387dfdff1847c18793` | Build one best-of-both PS contract, then sync Terraform in the same issue cycle. |
| Exact Git/worktree checks | Reusable `.github/workflows/Test-ExactGitPathSet.ps1`, blob `dc786aed1bd8c9d3bdcb25c6ea79207fc1d63c1b` | Checks are embedded in `build.yml` and the policy validator | Keep the reusable PS tool and add every stronger applicable Terraform check. |
| Build topology | `.github/workflows/build.yml`, blob `208a8b492c1f32e02c0731449db95890b256fc51` | Same path, blob `f68dfe2da4842d2086b079e09328e3298856123e` | Adopt action-free repository-code jobs and an action-only publish boundary. |
| Markdown topology | `.github/workflows/markdownlint.yml`, blob `4afa4f3aba03ffe3796ca72223cb0ebe26c8f34a` | Same path, blob `6a64b2a3b5b737bb7f69dc971b1b21b298013ab0` | Adopt separate action-free policy and lint jobs with verified Node acquisition. |
| Workflow policy | Validator blob `00263451aa8287a36ad0694143d96741c4cdd1f9`, contract blob `36374dbf88cb280126f780052e5d860ec96af9a7`, case-catalog blob `252423934501a1a5ffa7a9d33ea0f001b4068d11` | Validator blob `fb17e06f2f456a0d7df510b0bb34c52d88b7893b`; Terraform embeds its contract and cases | Preserve PS machine-readable authority and add every applicable Terraform invariant and negative case. |
| Supply-freeze reproducibility | No recorder or method | PR #27 recorder and method | Complete PS issue #158 after the PS policy contract stabilizes. |
| PowerShell conformance | Draft PR #164 at head `1e35e9b50045cca8946c97070109e3c9fc38c804` | PR #30 landed conformance | Review and land PR #164, then complete the reciprocal comparison before behavior-changing convergence. |
| Husky preparation | `install-husky.mjs` and a PS-specific `prepare` command | Direct `husky` command with accepted failure | Reconcile through PS issue #149 and later Terraform issue #24; do not change it in the foundation issues. |
| Decision records | PS-specific trust-root and baseline-provenance records | Terraform-specific historical writer and required-check records | Preserve history. Compare active residuals; do not copy records by filename. |

## Step 1 — protect the advisory deadline

The current PS P1 advisory decision expires at `2026-08-30T23:59:59Z`. PS issue #149 requires P1, P1A, P1B, and P2 handoffs before implementation, so it is not safe to treat #149 as immediately executable.

This step manages the deadline and any separately authorized repository-settings work. It does not authorize implementation of PS #149 or another feature issue. Do not change repository settings unless PS #152 or another applicable administrator issue authorizes the exact change.

Use `2026-08-21T23:59:59Z` as the internal go/no-go checkpoint.

- If #149 is at a reviewed, merge-ready head by the checkpoint, continue its approved merge path.
- If it is not, start a separate owner-approved superseding-decision task on 2026-08-22.
- The fallback must contain the current audit, exact accepted findings, reason, compensating controls, canonical approval and expiry, exact replacement contract bytes, validator and case updates, every dependent version/digest/name pin, validation, and rollback.
- Land the complete approved fallback before `2026-08-30T23:59:59Z`.
- Do not silently extend a date, reuse old approval, or allow the validator to enter `advisory-expired`.
- Do not add a false #149 dependency to the convergence issues. The date is a coordination gate, not an issue-graph claim.

Run Step 1 in parallel with Steps 2–6. A deadline check, read-only status check, dependency edit, or separately authorized repository-settings operation does not count as the active implementation issue. None of these operations permits a second feature implementation branch or PR.

## Step 2 — prepare and maintain convergence issues

Step 2 creates or updates issue records, dependencies, trackers, and implementation contracts. It does not commence implementation. Do not create a feature branch, edit implementation files, or open an implementation PR merely because an issue is ready. Implementation commences only at the explicit start gate in Step 3, Step 4, or Step 6. Keep native dependencies limited to real completion prerequisites. A tracking umbrella may list children without blocking unrelated work.

Before posting any issue body or comment, replace every placeholder with a verified identity. If an identity does not exist, keep the text in this plan and wait. Never post a fabricated SHA, URL, PR number, tree, or blob.

### 2.1 PS foundation-convergence umbrella

[PS issue #159](https://github.com/franklesniak/PSStyleGuide/issues/159) is open. Its creation and native child links are complete. This umbrella is a tracker and never counts as the active implementation issue. Use the retained contract below to maintain scope and closure evidence. Re-query the live issue before each write.

```markdown
## Objective

Reconcile the already implemented PSStyleGuide P1 and TerraformStyleGuide T1 foundations. Land the strongest applicable behavior in PSStyleGuide first. This issue is the tracking umbrella; focused child issues own implementation.

Keep PSStyleGuide and TerraformStyleGuide self-contained. Do not create a shared module, reusable cross-repository workflow, submodule, package, runtime download from the other repository, or third source of truth.

## Immutable baselines

- PS P1: PR #150 merge `3b611fd47a8eb9b24248715be7df97b0f3115e6b`.
- PS current baseline: `2d56357d9f52c76734027174bf62278e6f3d4cd6`, tree `46f5f4e8627eb341ddc4ef0c8d52483dc4006b50`.
- Terraform T1: PR #26 merge `143f54e52075a1ae1e999a6e242073e3d8d4a46b`.
- Terraform supply-freeze method: PR #27 merge `aae05282b57f093cec8b63e59138db72c982f10e`.
- Terraform current baseline: PR #30 merge `fbfc3aca874e235cace92f506377f5c9e0704160`, tree `3c6e54be9d722b8f61aa225b1414f228f7531268`.
- Existing PS conformance branch: `904df87c24abb4abcb44d2a71859c0589b82c167`.

## Children

- [ ] [PS issue #160](https://github.com/franklesniak/PSStyleGuide/issues/160) — land the existing PowerShell-conformance branch.
- [ ] [PS issue #161](https://github.com/franklesniak/PSStyleGuide/issues/161) — reconcile generator and reusable Git/path behavior.
- [ ] [PS issue #162](https://github.com/franklesniak/PSStyleGuide/issues/162) — reconcile workflow isolation, Node acquisition, and policy coverage.
- [ ] [PS issue #158](https://github.com/franklesniak/PSStyleGuide/issues/158) — port the supply-freeze recorder and method after the policy contract stabilizes.

The live umbrella contains these four native sub-issues in this order.

## Common-behavior gate

For each child, compare immutable PS and Terraform sources in a closed matrix. Classify every row as `same`, `intentional difference`, or `blocker`. A weaker or unexplained security, credential, path, serialization, atomicity, cleanup, native-status, or failure-truth behavior blocks merge. After the PS PR lands, complete the Terraform comparison, any focused Terraform sync PR, and the reverse PS comparison before the next child starts.

Intentional differences are limited to repository identity, source and generated filenames, artifact IDs, schema/type prefixes, required check names, proved platform applicability, documentation wording, and repository-specific historical decisions.

## Completion

After the infrastructure, generator/path, and workflow-policy children reach their fixed points, post an interim core-foundation handoff for PS P1B. State that issue #158 remains nonblocking.

Close this umbrella only after all four children and their reciprocal cycles close. Post one permanent final handoff with every child issue/PR URL, both repositories' final landed identities, source/destination blob maps, final reciprocal matrices, validation evidence, and all intentional differences. Do not create a later aggregate Terraform foundation implementation issue.
```

### 2.2 PS infrastructure-conformance contract

[PS issue #160](https://github.com/franklesniak/PSStyleGuide/issues/160) is open. [Draft PR #164](https://github.com/franklesniak/PSStyleGuide/pull/164) shows that implementation has already commenced for Step 3 cycle 1. The issue creation, rebase, and current-head validation are complete. Review, landing, reciprocal comparison, and fixed-point closure remain. Re-run validation if the candidate bytes change. Use this contract for the remaining work:

```markdown
## Objective

Rebase and land the existing PSStyleGuide infrastructure-conformance patch without behavior change.

## Immutable inputs

- Branch pre-rebase head: `904df87c24abb4abcb44d2a71859c0589b82c167`.
- Branch base: `3b611fd47a8eb9b24248715be7df97b0f3115e6b`.
- Rebase target: PS `main` at `2d56357d9f52c76734027174bf62278e6f3d4cd6`.
- Terraform conformance input: PR #30 merge `fbfc3aca874e235cace92f506377f5c9e0704160`.

The original patch changes exactly:

- `.github/workflows/Generate-StyleGuideArtifacts.ps1`;
- `.github/workflows/Test-ExactGitPathSet.ps1`; and
- `.github/workflows/build.yml`.

The draft candidate also changes `.github/workflows/workflow-policy-contract.json` and `.github/workflows/Validate-WorkflowPolicy.mjs` only for the coupled identity refresh required by the final script bytes.

## Implementation and preservation requirements

- Preserve the completed rebase onto the pinned PS baseline.
- Preserve the complete original patch unless a line is superseded by a proved equivalent landed change.
- Apply every applicable Terraform PR #30 authoring idiom: descriptive type-prefixed names, `List[T]` instead of array `+=`, `[void]` output suppression, complete comment-based help, approved function naming, and descriptive loop variables.
- Preserve the timeless four-component script-version grammar and the corresponding trusted expected-version pins.
- Keep runtime behavior unchanged.
- Do not edit `CLAUDE.md` or the four P1A files.
- Preserve the current script versions and trusted pins. Update them only if the final material bytes change.
- Preserve the old and rebased commit record. Do not claim that the old commit survived the rebase.

## Validation

If the candidate bytes change, rerun both Markdown lint surfaces, PowerShell parsing, PSScriptAnalyzer under Windows PowerShell 5.1 and PowerShell 7 where available, workflow-policy validation, generator drift verification, and exact-path verification. Retain the exact commands, runtime versions, exit codes, and results.

## Handoff

The PR must give the umbrella issue its reviewed head/tree, landed commit/tree, all five landed blobs, version/digest changes, validation evidence, and every intentional repository-specific difference. After merge, run the Terraform comparison and sync prompt. Do not start the generator/path issue until the reverse comparison closes this cycle.
```

### 2.3 PS generator and path-contract

[PS issue #161](https://github.com/franklesniak/PSStyleGuide/issues/161) is open, and PS #160 is its verified native blocker. Issue setup is complete. Do not commence implementation until Step 3 closes the PS #160 reciprocal cycle and reaches the cycle 2 start gate. Use this contract for implementation and closure:

```markdown
## Objective

Create the canonical best-of-both PS generator and reusable exact Git/worktree contract. Preserve PS's structured evidence and reusable verifier. Add every applicable Terraform T1 safety and recovery behavior. Do not change workflow topology in this issue.

## Immutable sources

Read these blobs again before implementation:

- PS generator at current baseline: `c54012e549aedef827ae3ccb669b512a1f14c644`.
- PS path verifier at current baseline: `dc786aed1bd8c9d3bdcb25c6ea79207fc1d63c1b`.
- Terraform generator at `fbfc3aca874e235cace92f506377f5c9e0704160`: `e5bdd8f64569541eb3c724387dfdff1847c18793`.
- Terraform build workflow containing embedded Git/worktree checks: `f68dfe2da4842d2086b079e09328e3298856123e`.
- Terraform policy validator containing related fixtures: `fb17e06f2f456a0d7df510b0bb34c52d88b7893b`.
- Landed infrastructure-conformance commit: `<PS_INFRA_LANDED_COMMIT>`.

Replace this placeholder in the plan and update the live issue before implementation.

Use the landed infrastructure-conformance commit as the editing baseline. The older PS blobs above identify the original P1 behavior for comparison only. Do not restore them over the landed conformance bytes.

## Canonical generated-destination behavior

- The fixed repository map is the only path authority.
- The exact destination must be index-tracked.
- Filesystem state may be either absent or one ordinary non-link file under the validated repository root.
- Precompute and validate all complete payload bytes before any destination mutation.
- Create a fresh, unpredictable, same-directory ordinary candidate with bounded real-collision retries.
- Write all bytes, call durable flush, close, reopen, and verify length, digest, BOM, CR, and final-newline rules.
- Revalidate parent, destination state, and candidate identity immediately before publication.
- If the destination exists, call `File.Replace(candidate, destination, null)` once.
- If the destination is absent, call non-overwriting same-directory `File.Move(candidate, destination)` once.
- Before publication returns, failure preserves the old destination or proven absence and removes only the proved candidate.
- After publication returns, do not attempt rollback and do not claim cross-file atomicity.
- Keep a closed generator/per-artifact result. Return success only when bounded final evidence proves the destination bytes and state. Otherwise return `ReplacementStateUncertain` with bounded recovery evidence.
- Preserve fixed order and truthful partial-success records if a later artifact fails.

## Reusable Git/path contract

Keep `Test-ExactGitPathSet.ps1` as the reusable implementation. Add every applicable Terraform invariant for fixed executable identity, built child environment, disabled ambient Git controls, raw NUL framing, hostile byte handling, duplicate/cardinality rejection, exact status classification, staged/working/untracked surfaces, hooks/config control-surface detection, and bounded ordinary worktree inspection.

Do not duplicate the same normative algorithm in workflow YAML. Thin workflow callers may add job-specific orchestration only.

## Scope and comparison

Freeze the exact affected-path set before coding. If `build.yml` or the policy files need only pin/fixture updates, assign those bytes to the later workflow-policy issue instead of editing them here.

Use this closed foundation catalog. Each row occurs exactly once:

| Stable row | Required comparison |
| --- | --- |
| `GF-PARAMETERS` | Public names, types, defaults, and omission, null, empty, and raw-value rules |
| `GF-DESTINATION` | Trusted root, fixed destinations, provider, wildcard, rooted-path, normalization, comparison, and failure rules |
| `GF-CONTENT` | Source order, wrappers, frontmatter, repository-specific names, and complete payload |
| `GF-SERIALIZATION` | CRLF and lone-CR normalization, LF and final-newline rules, BOM-less UTF-8, and byte checks |
| `GF-WRITE` | Complete-payload candidate creation, durable flush, verification, single-call publication, and prohibited fallbacks |
| `GF-FAILURE` | Phase postconditions, cleanup and uncertainty, bounded diagnostics, and fault cases |
| `GF-HOSTS` | Supported editions and hosts, executable identity, cross-cell equality, and idempotence |
| `GF-VERSION` | Timeless marker grammar, trusted expected version, authoring progression, and independent fixtures |
| `GF-NODE-LOCK` | Exact Node/npm producer and provenance, distribution verification, cache and side effects, dependency graph, and frozen consumers |
| `GF-YAML` | Parser package and API, document and schema strictness, diagnostics, and forbidden features |
| `GF-ACTION-PINS` | Closed action roles, full commit pins, provenance, runtime, and atomic pin updates |
| `GF-ACTION-INPUTS` | Authored security inputs and separately reviewed manifest defaults |
| `GF-GIT` | NUL records, byte allowlists, native statuses, cardinality, refs, ancestry, lease, and refspec |
| `GF-GRAPH` | Production and evidence triggers, permissions, needs, conditions, outputs, side effects, and sole writer |
| `GF-CREDENTIALS` | Job-token availability, authentication projection, cleanup, push-only materialization, and absence proofs |
| `GF-EVIDENCE` | Temporary workflow/ref structural equality, drills, retained identities, cleanup, and final absence |

For every row, record both repository URLs and commits, normative and implementation locators, evidence paths and SHA-256 values, observed values or fixture IDs, one status (`same`, `intentional difference`, or `blocker`), and a reason. Missing, duplicate, unknown, renamed, empty, or unexplained rows block merge.

Complete the 16-row `GF-*` reciprocal matrix and a file-operation matrix for existing destination, absent tracked destination, unexpected destination, link/reparse substitution, create collision, write/flush/verify failure, publish failure, post-publish uncertainty, cleanup failure, and multi-artifact partial success. No unexplained blocker may remain.

Expected intentional differences are limited to repository identity, source and artifact filenames, artifact IDs, schema/type prefixes, stable check names required by successor issues, documentation text, platform applicability proved by tests, and genuinely repository-specific historical decisions. For each intentional difference, name both literals or behaviors, explain the repository need, prove equal security and failure strength, name the owner, and state any review or expiry condition.

## Version and scope boundary

- Use the same script-version grammar and PowerShell authoring rules in both repositories.
- Keep this issue read-only with respect to workflow publication. P1B/T1B owns the first workflow writer.

## Validation

Run fault injection without touching the real repository. Run Windows PowerShell 5.1, PowerShell 7 on Windows, and PowerShell 7 on Ubuntu. Prove byte-identical and idempotent output, exact result schemas, honest failure states, no generated drift, hostile-path behavior, script-version progression, and clean working/staged path sets.

## Handoff

Record base, reviewed head/tree, landed commit/tree, source and landed blobs, script versions, SHA-256 values, result schema, fixture identities, runtime matrix, and every intentional difference. Run the Terraform comparison and any reverse PS sync-back to a fixed point. The workflow-policy issue must consume the final PS landed commit from that cycle, never an earlier branch head.
```

### 2.4 PS workflow-isolation and policy

[PS issue #162](https://github.com/franklesniak/PSStyleGuide/issues/162) is open, and PS #161 is its verified native blocker. Issue setup is complete. Do not commence implementation until Step 3 closes the PS #161 reciprocal cycle and reaches the cycle 3 start gate. Use this contract for implementation and closure:

```markdown
## Objective

Make PSStyleGuide's P1 workflows use the strongest applicable PS and Terraform controls. No job that runs repository-controlled code may declare a JavaScript action or retain repository-token scopes. Keep the PS machine-readable policy contract and case catalog. Add every applicable Terraform invariant and negative case.

## Immutable sources

- PS build blob: `208a8b492c1f32e02c0731449db95890b256fc51`.
- PS Markdown blob: `4afa4f3aba03ffe3796ca72223cb0ebe26c8f34a`.
- PS validator blob: `00263451aa8287a36ad0694143d96741c4cdd1f9`.
- PS contract blob: `36374dbf88cb280126f780052e5d860ec96af9a7`.
- PS cases blob: `252423934501a1a5ffa7a9d33ea0f001b4068d11`.
- Terraform build blob: `f68dfe2da4842d2086b079e09328e3298856123e`.
- Terraform Markdown blob: `6a64b2a3b5b737bb7f69dc971b1b21b298013ab0`.
- Terraform validator blob: `fb17e06f2f456a0d7df510b0bb34c52d88b7893b`.
- Canonical PS generator/path commit: `<PS_GENERATOR_LANDED_COMMIT>`.

Replace this placeholder in the plan and update the live issue before implementation.

Use the canonical landed generator/path commit as the editing baseline. The older PS workflow and policy blobs above identify the pre-convergence behavior for comparison only. Re-read every overlapping path from the landed commit before editing.

## Required topology

- Repository-code jobs declare `permissions: {}` and contain no `uses:` key.
- Acquire the exact triggering commit anonymously through a fixed absolute Git executable. Fail loudly if the public anonymous model is not available.
- Verify a credential-free remote/config state before repository code runs.
- In Node jobs, download the exact official Node distribution from a reviewed URL, verify its reviewed digest before extraction, and assert exact Node/npm identities.
- Separate policy validation and Markdown lint into different jobs and runners.
- Separate generator verification and artifact publication into different jobs and runners.
- Any publication job runs no repository code and uses only reviewed full-SHA actions with a closed input/default contract.
- Do not publish failure diagnostics from the repository-code job. If bounded diagnostics are still required, pass only commit-derived or otherwise independently produced evidence through a separate safe design.
- Preserve unfiltered pull-request and push coverage.
- Keep all jobs read-only. P1B owns the first writer.

## Policy convergence

Keep `workflow-policy-contract.json` as machine-readable authority and `workflow-policy-cases.json` as the external case catalog. Port every applicable Terraform PR #26/#30 policy invariant and negative fixture, including job isolation, action-role multiset, immutable acquire, runner communication channels, credential absence, fixed tools, control-surface integrity, worktree containment, Node supply verification, strict YAML/JSON shapes, native statuses, terminal graph behavior, and publish-job restrictions.

Run policy parsing and all policy fixtures strictly offline. Keep machine-readable authority for job roles, authored inputs, reviewed defaults, supply identities, and exact case allocation.

Do not reduce Terraform's current coverage merely to keep PS's smaller case count. Do not copy Terraform repository literals or historical decision text.

PS issue #151 remains a later P4 task after #149. Do not silently claim that this issue completes Node permission-model confinement or duplicate-key preflight work unless #151 is explicitly amended and all of its acceptance evidence is satisfied.

## Required comparison

Use this closed foundation catalog. Each row occurs exactly once:

| Stable row | Required comparison |
| --- | --- |
| `GF-PARAMETERS` | Public names, types, defaults, and omission, null, empty, and raw-value rules |
| `GF-DESTINATION` | Trusted root, fixed destinations, provider, wildcard, rooted-path, normalization, comparison, and failure rules |
| `GF-CONTENT` | Source order, wrappers, frontmatter, repository-specific names, and complete payload |
| `GF-SERIALIZATION` | CRLF and lone-CR normalization, LF and final-newline rules, BOM-less UTF-8, and byte checks |
| `GF-WRITE` | Complete-payload candidate creation, durable flush, verification, single-call publication, and prohibited fallbacks |
| `GF-FAILURE` | Phase postconditions, cleanup and uncertainty, bounded diagnostics, and fault cases |
| `GF-HOSTS` | Supported editions and hosts, executable identity, cross-cell equality, and idempotence |
| `GF-VERSION` | Timeless marker grammar, trusted expected version, authoring progression, and independent fixtures |
| `GF-NODE-LOCK` | Exact Node/npm producer and provenance, distribution verification, cache and side effects, dependency graph, and frozen consumers |
| `GF-YAML` | Parser package and API, document and schema strictness, diagnostics, and forbidden features |
| `GF-ACTION-PINS` | Closed action roles, full commit pins, provenance, runtime, and atomic pin updates |
| `GF-ACTION-INPUTS` | Authored security inputs and separately reviewed manifest defaults |
| `GF-GIT` | NUL records, byte allowlists, native statuses, cardinality, refs, ancestry, lease, and refspec |
| `GF-GRAPH` | Production and evidence triggers, permissions, needs, conditions, outputs, side effects, and sole writer |
| `GF-CREDENTIALS` | Job-token availability, authentication projection, cleanup, push-only materialization, and absence proofs |
| `GF-EVIDENCE` | Temporary workflow/ref structural equality, drills, retained identities, cleanup, and final absence |

For every row, record both repository URLs and commits, normative and implementation locators, evidence paths and SHA-256 values, observed values or fixture IDs, one status (`same`, `intentional difference`, or `blocker`), and a reason. Missing, duplicate, unknown, renamed, empty, or unexplained rows block merge.

Expected intentional differences are limited to repository identity, source and artifact filenames, artifact IDs, schema/type prefixes, stable check names required by successor issues, documentation text, platform applicability proved by tests, and genuinely repository-specific historical decisions. For each intentional difference, name both literals or behaviors, explain the repository need, prove equal security and failure strength, name the owner, and state any review or expiry condition.

Complete this matrix against the landed canonical generator/path commit and Terraform current `main`. Add a workflow-topology table containing every workflow, job, step, permission, condition, action, authored input, reviewed default, credential, repository-code execution point, produced bytes, consumed bytes, and side effect.

An action in a repository-code job, a repository token scope on such a job, an unverified Node distribution, an unexplained missing Terraform negative case, or a weaker failure postcondition blocks merge.

## Validation

Run all offline fixtures, both Markdown surfaces, generator drift, exact-path checks, clean installs, policy preflight/full validation, action/default provenance checks, and PR/push graph tests. Record the final case count and prove every case executes exactly once. Require all checks to pass at the reviewed head.

## Handoff

Record every source and landed blob, contract and catalog version/digest, Node/npm/archive identities, action pins/manifests/defaults, final topology, case allocation, runtime results, reviewed head/tree, landed commit/tree, and intentional difference. Run the Terraform comparison and any reverse PS sync-back to a fixed point. PS issue #158 must consume the final landed PS contract from this cycle.
```

### 2.5 PS issue #158 linkage and implementation contract

PS #158 is already a native child of PS #159. After the PS #162 PR lands, add one short planning comment to #158. This issue update does not commence implementation. Do not replace its body.

```markdown
This issue is a child of [PS issue #159](https://github.com/franklesniak/PSStyleGuide/issues/159) and starts after `<PS_WORKFLOW_POLICY_PR_URL>` lands. Re-read the final landed `workflow-policy-contract.json` from `<PS_WORKFLOW_POLICY_LANDED_COMMIT>` before adapting the recorder. Preserve this issue's existing nonblocking scope and immutable Terraform PR #27 source pins.
```

Replace the two remaining placeholders before posting. Commence PS #158 implementation only at the Step 3 cycle 4 start gate. Its PR must keep the recorder read-only, capture output outside the repository, and prove no manifest, lockfile, installed-tree, contract, generated-output, or worktree mutation. After merge, run the Terraform comparison and any reverse PS sync-back to a fixed point before the Claude command cycle starts.

### 2.6 PS Claude command

[PS issue #163](https://github.com/franklesniak/PSStyleGuide/issues/163) is open and remains unimplemented. Issue creation and owner authorization are complete. It is Step 3 cycle 5 and remains independent of the foundation issue graph. Do not commence implementation until Step 3 closes cycle 4 and reaches the cycle 5 start gate. Use this contract for implementation and closure:

```markdown
## Objective

Add a thin repository-local Claude command wrapper for the PSStyleGuide review loop.

## Immutable design input

Read TerraformStyleGuide `.claude/commands/review-loop.md` from commit `fbdecbae787055a2117d4ada83ae294a7decfe62`, blob `7b0e41361a8ab7259245ad5f0d86d9300008347d`.

Do not copy it unchanged. It says `all six steps`, while PSStyleGuide's landed `CLAUDE.md` defines nine review-comment handling steps.

## Requirements

- Obtain explicit owner authorization because this file is an agent entry point.
- Accept a pull-request URL and require one when it is not supplied.
- Delegate the authoritative process to the repository-local root `CLAUDE.md`.
- Treat Codex and Copilot as co-equal reviewers as local `CLAUDE.md` requires.
- Do not duplicate a step count, gate count, round limit, or another volatile protocol detail.
- Do not fetch instructions from a moving external branch or add a shared runtime dependency.
- Record a line-by-line comparison with the pinned Terraform input and explain every intentional difference.
- Run Markdown lint and the applicable local agent-instruction checks.

Keep this issue and PR separate from the foundation, supply-freeze, and infrastructure-conformance work. After it lands, run the Terraform comparison and sync prompt. If Terraform changes, run the reverse PS comparison before closing the cycle.
```

### 2.7 Terraform convergence tracker

[Terraform issue #31](https://github.com/franklesniak/TerraformStyleGuide/issues/31) is open. Tracker creation is complete, but all five reciprocal cycle records remain open. Updating this tracker does not commence implementation and does not count as the active implementation issue. Use this contract to maintain and close the tracker:

```markdown
## Objective

Retain the reciprocal evidence for the initial PSStyleGuide import pass. This issue tracks comparisons and focused repair issues. It does not authorize one aggregate implementation PR.

## Cycles

- [ ] PS infrastructure conformance from Terraform PR #30.
- [ ] PS generator and path convergence from Terraform PRs #26 and #30.
- [ ] PS workflow and policy convergence from Terraform PRs #26 and #30.
- [ ] PS issue #158 supply-freeze method from Terraform PR #27.
- [ ] PS Claude command parity from Terraform commit `fbdecbae787055a2117d4ada83ae294a7decfe62`.

Complete the cycles in order. For each cycle, record the PS issue and landed PR, source and destination commits and blobs, the 16-row matrix or a documented reduced matrix for a narrow non-foundation file, any focused Terraform sync issue and PR, the reverse PS comparison, validation, intentional differences, and the permanent fixed-point closure record.

If a comparison finds no common difference, post a pinned no-change record. If it finds work, create one focused Terraform issue. Creating the issue does not commence implementation. Commence it only after the issue record is complete, the preceding cycle has closed, and the implementation slot is free. Do not combine unrelated cycles in one PR.
```

## Step 3 — import Terraform behavior into PSStyleGuide

### 3.1 Complete the source cycles in order

Run these source issues as separate fixed-point cycles in this order:

| Order | PS source issue | Immutable Terraform design input | Required Terraform-side closure |
| ---: | --- | --- | --- |
| 1 | [PS #160](https://github.com/franklesniak/PSStyleGuide/issues/160), draft [PR #164](https://github.com/franklesniak/PSStyleGuide/pull/164) | PR #30 merge `fbfc3aca874e235cace92f506377f5c9e0704160` | Review and land PR #164. Compare the generator, path verifier, and build workflow. Implement one focused sync only if PS adds common behavior. |
| 2 | [PS #161](https://github.com/franklesniak/PSStyleGuide/issues/161), blocked by #160 | PR #26 merge `143f54e52075a1ae1e999a6e242073e3d8d4a46b` and PR #30 merge above | Compare the generator, reusable verifier, embedded Terraform checks, and fixtures; sync every common contract. |
| 3 | [PS #162](https://github.com/franklesniak/PSStyleGuide/issues/162), blocked by #161 | PR #26 and PR #30 merges above | Compare workflow topology, Node acquisition, permissions, policy authority, and negative cases; sync every common contract. |
| 4 | [PS issue #158](https://github.com/franklesniak/PSStyleGuide/issues/158) | PR #27 merge `aae05282b57f093cec8b63e59138db72c982f10e` | Compare the adapted recorder and method with Terraform; sync any generally useful correction. |
| 5 | [PS #163](https://github.com/franklesniak/PSStyleGuide/issues/163) | Commit `fbdecbae787055a2117d4ada83ae294a7decfe62`, blob `7b0e41361a8ab7259245ad5f0d86d9300008347d` | Remove any avoidable protocol drift in Terraform, then compare the result back in PS. |

After each PS PR lands, use the complete cycle sequence in section 3.2. Run the Terraform comparison prompt in section 3.3. If a Terraform PR lands, run the reverse PS comparison prompt in section 3.4. Repeat until the cycle reaches the fixed point. Only then commence the next numbered PS issue.

The current identical support blobs do not need implementation issues: `.gitattributes`, `.github/dependabot.yml`, `.github/workflows/.markdownlint.jsonc`, `.github/workflows/lint-nested-markdown.js`, `.github/workflows/MARKDOWN-LINTING-IMPLEMENTATION.md`, and `.github/workflows/scripts-README.md`. Preserve repository-specific historical decision records. Defer the Husky preparation difference to the paired PS #149 and Terraform #24 cycle. Recheck these dispositions in the Step 5 global sweep.

The first three cycles may post the interim core-foundation handoff for PS P1B after cycle 3 closes. Issue #158 still has no native blocking edge to PS #147 or #152. The Step 3 barrier is an execution rule for backlog cleanup, not a fabricated issue dependency.

Close the PS foundation umbrella after cycle 4 closes. Post final identities from both repositories. Do not open one aggregate Terraform foundation implementation issue. Cycle 5 remains separate from the foundation umbrella.

### 3.2 Commence implementation and close one PS import cycle

Issue setup in Step 2 and implementation commencement in Step 3 are separate actions. Cycle 1 implementation has already commenced through draft PS PR #164. For cycles 2–5, do not create a branch, edit implementation files, or open an implementation PR until the preceding cycle has its permanent fixed-point closure record.

Complete this sequence for one cycle before the next cycle starts:

1. Verify that no other feature implementation issue or PR is active. A tracker update, read-only comparison, dependency edit, or separately authorized settings operation does not count as the active implementation issue, but it does not permit a second feature branch or PR.
2. Classify the PS source issue as `common capability`, `repository-specific capability`, or `administrative only`. Name the mapped Terraform issue when one exists.
3. Record the PS issue URL, immutable landed input commits and Git blobs, intended affected paths, and expected repository-specific differences. Never copy from a moving branch.
4. Commence implementation for only that PS issue. Keep both repositories self-contained. Do not add a shared module, cross-repository runtime fetch, reusable cross-repository workflow, submodule, package, or third source of truth.
5. Run the PS repository review protocol. Re-run it after every change because an earlier clean review does not cover changed bytes. Land the PS PR and record its base, reviewed head and tree, merge method, landed commit and tree, affected-path set, landed blobs, validation commands, runtime identities, and review outcome.
6. Run the Terraform comparison prompt in section 3.3 against the landed PS commit and a newly fetched Terraform `main` commit. Complete every applicable foundation row and exact file/blob mapping.
7. If no common difference exists, make no implementation change. Post a pinned no-change or non-applicability record. Do not open an implementation issue only for symmetry.
8. If a common difference exists, create or update one focused Terraform issue and pin the landed PS commit and blobs. Issue creation does not commence implementation. After the issue record is complete and no other implementation is active, explicitly commence the Terraform adaptation. Run the Terraform review protocol and re-run it after every byte change. Land one PR only after review covers the final bytes, and record the same identities and validation evidence.
9. Run the reverse PS comparison prompt in section 3.4 against both landed commits.
10. If the Terraform adaptation added or corrected common behavior, create or update one focused PS sync-back issue. Issue creation does not commence implementation. After the issue record is complete and no other implementation is active, explicitly commence the sync-back. Run the PS review protocol and re-run it after every byte change. Land one PS PR only after review covers the final bytes, and rerun the Terraform comparison.
11. End the cycle only when every common row is `same`, every intentional difference has complete evidence, and no row is a `blocker`.
12. Post one permanent closure record with both repositories' final issue and PR URLs, bases, reviewed heads and trees, merge methods, landed commits and trees, affected paths, source and destination blobs, matrix digest, validation commands, runtime identities, review outcomes, intentional differences, and explicit non-applicability results.

Do not change repository settings unless the applicable administrator issue authorizes the exact request.

Allowed intentional differences are limited to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain-specific examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence. For each intentional difference, name both literals or behaviors, explain the repository need, prove equal security and failure strength, name the owner, and state the review or expiry condition. Convenience, implementation history, separate authorship, and lower effort are not repository-specific reasons.

If the same matrix row changes direction twice, stop. Revalidate the requirement and run a new decision process that evaluates both repository implementations. Do not alternate implementations indefinitely and do not select the last edit merely because it is newer.

### 3.3 Terraform comparison and sync prompt

Run this prompt in a clean TerraformStyleGuide checkout after each Step 3 PS PR lands. Replace every placeholder with a verified identity before use.

```markdown
Compare one landed PSStyleGuide capability with TerraformStyleGuide and close all common differences.

Source cycle: `<CYCLE_NAME>`.
PS issue and PR: `<PS_ISSUE_URL>`, `<PS_PR_URL>`.
PS landed commit and tree: `<PS_LANDED_COMMIT>`, `<PS_LANDED_TREE>`.
PS handoff: `<PS_HANDOFF_URL>`.
Cycle record: `<CYCLE_TRACKER_OR_ISSUE_URL>`.

Fetch both repositories. Read PS source files only from `<PS_LANDED_COMMIT>`. Record every PS source blob. Record the current fetched Terraform `main` commit, tree, and corresponding destination blobs before analysis. Do not compare moving branch names.

Map files by role, not only by filename. Complete all applicable `GF-*` rows. For a narrow file, use a reduced matrix only when the omitted rows are proved inapplicable. Compare semantics, negative cases, validation, documentation, and operational evidence. Treat only repository identity, PowerShell-versus-Terraform filenames or payloads, domain examples, prefixes, local names, proved platform conditions, historical decisions, and live settings evidence as candidate intentional differences.

For each intentional difference, name both literals or behaviors, explain the repository need, prove equal security and failure strength, name the owner, and state the review or expiry condition. Convenience, implementation history, separate authorship, and lower effort are not repository-specific reasons.

Use this closed catalog for each foundation comparison:

| Stable row | Required comparison |
| --- | --- |
| `GF-PARAMETERS` | Public names, types, defaults, and omission, null, empty, and raw-value rules |
| `GF-DESTINATION` | Trusted root, fixed destinations, provider, wildcard, rooted-path, normalization, comparison, and failure rules |
| `GF-CONTENT` | Source order, wrappers, frontmatter, repository-specific names, and complete payload |
| `GF-SERIALIZATION` | CRLF and lone-CR normalization, LF and final-newline rules, BOM-less UTF-8, and byte checks |
| `GF-WRITE` | Complete-payload candidate creation, durable flush, verification, single-call publication, and prohibited fallbacks |
| `GF-FAILURE` | Phase postconditions, cleanup and uncertainty, bounded diagnostics, and fault cases |
| `GF-HOSTS` | Supported editions and hosts, executable identity, cross-cell equality, and idempotence |
| `GF-VERSION` | Timeless marker grammar, trusted expected version, authoring progression, and independent fixtures |
| `GF-NODE-LOCK` | Exact Node/npm producer and provenance, distribution verification, cache and side effects, dependency graph, and frozen consumers |
| `GF-YAML` | Parser package and API, document and schema strictness, diagnostics, and forbidden features |
| `GF-ACTION-PINS` | Closed action roles, full commit pins, provenance, runtime, and atomic pin updates |
| `GF-ACTION-INPUTS` | Authored security inputs and separately reviewed manifest defaults |
| `GF-GIT` | NUL records, byte allowlists, native statuses, cardinality, refs, ancestry, lease, and refspec |
| `GF-GRAPH` | Production and evidence triggers, permissions, needs, conditions, outputs, side effects, and sole writer |
| `GF-CREDENTIALS` | Job-token availability, authentication projection, cleanup, push-only materialization, and absence proofs |
| `GF-EVIDENCE` | Temporary workflow/ref structural equality, drills, retained identities, cleanup, and final absence |

Each row occurs exactly once. Record both repository URLs and commits, normative and implementation locators, evidence paths and SHA-256 values, observed values or fixture IDs, one status (`same`, `intentional difference`, or `blocker`), and a reason. Missing, duplicate, unknown, renamed, empty, or unexplained rows block closure.

Before editing, validate every finding. List the options, create a finding-specific weighted rubric, score the options in a table, select the best option, and state the selected work in ASD-STE100-compliant language. Save analysis only in `TEMP-*` files. Do not put analysis artifacts in permanent planning or implementation documents.

If no common difference remains, make no implementation change. Post a pinned no-change record to the cycle record with both commits, blobs, matrix digest, validation, and intentional differences.

If a common difference remains, create or update one focused Terraform issue and pin the PS commit and source blobs. Issue creation is a planning action and does not commence implementation. Stop if another feature implementation is active. After the issue record is complete and the implementation slot is free, explicitly commence the Terraform adaptation. Adapt the landed PS behavior; do not redesign it independently. Keep the repository self-contained and do not create a shared dependency. Do not change repository settings unless the applicable administrator issue authorizes the exact request. Run the Terraform review protocol and re-run it after every byte change. Land one PR only after review covers the final bytes, and record its base, reviewed head/tree, merge method, landed commit/tree, affected paths, destination blobs, validation commands, runtimes, and review outcome. Then run the reverse PS comparison prompt before closing the cycle.
```

### 3.4 Reverse PS comparison and sync-back prompt

Run this prompt in a clean PSStyleGuide checkout after any Terraform PR in the cycle lands. Replace every placeholder with a verified identity before use.

```markdown
Compare the landed TerraformStyleGuide adaptation back against its landed PSStyleGuide source and close any common improvement that exists only in TerraformStyleGuide.

Cycle: `<CYCLE_NAME>`.
PS source issue, PR, commit, and tree: `<PS_ISSUE_URL>`, `<PS_PR_URL>`, `<PS_LANDED_COMMIT>`, `<PS_LANDED_TREE>`.
Terraform issue, PR, commit, and tree: `<TF_ISSUE_URL>`, `<TF_PR_URL>`, `<TF_LANDED_COMMIT>`, `<TF_LANDED_TREE>`.

Fetch both repositories. Read files only from the two landed commits and record all compared blobs. Re-run the same file-role map and reciprocal matrix. Do not assume that an adaptation-only edit is repository-specific. Require an exact reason and equal security and failure strength.

For each intentional difference, name both literals or behaviors, explain the repository need, prove equal security and failure strength, name the owner, and state the review or expiry condition. Convenience, implementation history, separate authorship, and lower effort are not repository-specific reasons.

Use this closed catalog for each foundation comparison:

| Stable row | Required comparison |
| --- | --- |
| `GF-PARAMETERS` | Public names, types, defaults, and omission, null, empty, and raw-value rules |
| `GF-DESTINATION` | Trusted root, fixed destinations, provider, wildcard, rooted-path, normalization, comparison, and failure rules |
| `GF-CONTENT` | Source order, wrappers, frontmatter, repository-specific names, and complete payload |
| `GF-SERIALIZATION` | CRLF and lone-CR normalization, LF and final-newline rules, BOM-less UTF-8, and byte checks |
| `GF-WRITE` | Complete-payload candidate creation, durable flush, verification, single-call publication, and prohibited fallbacks |
| `GF-FAILURE` | Phase postconditions, cleanup and uncertainty, bounded diagnostics, and fault cases |
| `GF-HOSTS` | Supported editions and hosts, executable identity, cross-cell equality, and idempotence |
| `GF-VERSION` | Timeless marker grammar, trusted expected version, authoring progression, and independent fixtures |
| `GF-NODE-LOCK` | Exact Node/npm producer and provenance, distribution verification, cache and side effects, dependency graph, and frozen consumers |
| `GF-YAML` | Parser package and API, document and schema strictness, diagnostics, and forbidden features |
| `GF-ACTION-PINS` | Closed action roles, full commit pins, provenance, runtime, and atomic pin updates |
| `GF-ACTION-INPUTS` | Authored security inputs and separately reviewed manifest defaults |
| `GF-GIT` | NUL records, byte allowlists, native statuses, cardinality, refs, ancestry, lease, and refspec |
| `GF-GRAPH` | Production and evidence triggers, permissions, needs, conditions, outputs, side effects, and sole writer |
| `GF-CREDENTIALS` | Job-token availability, authentication projection, cleanup, push-only materialization, and absence proofs |
| `GF-EVIDENCE` | Temporary workflow/ref structural equality, drills, retained identities, cleanup, and final absence |

Each row occurs exactly once. Record both repository URLs and commits, normative and implementation locators, evidence paths and SHA-256 values, observed values or fixture IDs, one status (`same`, `intentional difference`, or `blocker`), and a reason. Missing, duplicate, unknown, renamed, empty, or unexplained rows block closure.

Before editing, validate every finding. List the options, create a finding-specific weighted rubric, score the options in a table, select the best option, and state the selected work in ASD-STE100-compliant language. Save analysis only in `TEMP-*` files.

If Terraform added or corrected common behavior, create or update one focused PS sync-back issue. Issue creation is a planning action and does not commence implementation. Stop if another feature implementation is active. After the issue record is complete and the implementation slot is free, explicitly commence the PS sync-back. Keep the repository self-contained. Do not change repository settings unless the applicable administrator issue authorizes the exact request. Run the PS review protocol and re-run it after every byte change. Land one PS PR only after review covers the final bytes, record the complete landed identity and validation evidence, and rerun the Terraform comparison against the new PS commit. If no common difference remains, make no implementation change and post the pinned reverse-comparison record.

Close the cycle only when every common row is `same`, every intentional difference is fully justified, no blocker remains, and the permanent closure record identifies both repositories' final landed commits and blobs.
```

## Step 4 — catch TerraformStyleGuide up from landed PS work

### 4.1 Commence Terraform issue #21 and close the reciprocal cycle

Start Step 4 only after all five Step 3 cycles close. [Terraform issue #21](https://github.com/franklesniak/TerraformStyleGuide/issues/21) already exists, but issue creation did not commence implementation. Terraform #22 requires a future landed PS #147 handoff. Terraform #24 requires a future landed PS #149 handoff and Terraform #23. Do not commence either issue in Step 4.

Complete Step 4 in this order:

1. Verify that Step 3 has five permanent fixed-point closure records and that no feature implementation issue or PR is active.
2. Fetch Terraform #21. Verify that it still pins PS PR #153 landed commit `2d56357d9f52c76734027174bf62278e6f3d4cd6` and its four source blobs. Rebase only its destination assumptions on the final Terraform commit from Step 3. Do not change its immutable PS source pin.
3. Classify the capability as common and record both issue URLs, immutable source and destination commits and blobs, intended affected paths, and expected repository-specific differences.
4. Explicitly commence only Terraform #21. Keep both repositories self-contained. Do not add a shared module, runtime fetch, reusable cross-repository workflow, submodule, package, or third source of truth. Do not copy `CLAUDE.md`.
5. Adapt the landed PS implementation instead of redesigning the capability independently. Run the Terraform review protocol. Re-run review after every byte change.
6. Land one Terraform PR. Record its base, reviewed head and tree, merge method, landed commit and tree, affected paths, destination blobs, validation commands, runtime identities, and review outcome.
7. Run the copy-paste prompt in section 4.2 from a clean PS checkout. Complete every applicable foundation row and exact file/blob mapping.
8. If no common difference remains, make no PS implementation change and post a pinned reverse-comparison record.
9. If the Terraform adaptation added or corrected common behavior, create or update one focused PS sync-back issue and pin both landed commits and blobs. Issue creation does not commence implementation. After the issue record is complete and the implementation slot is free, explicitly commence the PS sync-back. Run the PS review protocol and re-run it after every byte change. Land one PS PR only after review covers the final bytes.
10. If a PS sync-back PR lands, run the Terraform comparison included in section 4.2 against the new PS landed commit. If Terraform then needs another repair, create the focused issue first and commence it only after the issue record is complete and the implementation slot is free. Run the Terraform review protocol against the final repair bytes before landing.
11. End the cycle only when every common row is `same`, every intentional difference has complete evidence, and no row is a `blocker`. If the same row changes direction twice, stop and run a new decision process that evaluates both implementations.
12. Post one permanent closure record on Terraform #21 and the PS P1A handoff. Include both repositories' final issue and PR URLs, bases, reviewed heads and trees, merge methods, landed commits and trees, affected paths, source and destination blobs, final matrix digest, validation commands, runtime identities, review outcomes, intentional differences, and explicit non-applicability results.

Do not commence Terraform #22 in Step 4 because its PS source implementation does not exist yet.

Do not change repository settings unless the applicable administrator issue authorizes the exact request.

### 4.2 Terraform #21 reciprocal-closure prompt

Replace every placeholder with a verified identity. If an identity does not exist, do not run the prompt.

```markdown
Close the Terraform #21 reciprocal cycle against the landed PS P1A source.

PS source issue and PR: [PS issue #146](https://github.com/franklesniak/PSStyleGuide/issues/146) and [PS PR #153](https://github.com/franklesniak/PSStyleGuide/pull/153).
PS landed commit and tree: `2d56357d9f52c76734027174bf62278e6f3d4cd6`, `46f5f4e8627eb341ddc4ef0c8d52483dc4006b50`.
Terraform issue and landed PR: [Terraform issue #21](https://github.com/franklesniak/TerraformStyleGuide/issues/21) and `<TF_PR_URL>`.
Terraform landed commit and tree: `<TF_LANDED_COMMIT>`, `<TF_LANDED_TREE>`.
Permanent cycle record: `<CYCLE_RECORD_URL>`.

Fetch both repositories. Read files only from the two landed commits. Record every compared Git blob and map files by role. Do not compare moving branches. Keep both repositories self-contained. Do not add a shared module, runtime fetch, reusable cross-repository workflow, submodule, package, or third source of truth. Do not copy `CLAUDE.md`.

Use this closed catalog:

| Stable row | Required comparison |
| --- | --- |
| `GF-PARAMETERS` | Public names, types, defaults, and omission, null, empty, and raw-value rules |
| `GF-DESTINATION` | Trusted root, fixed destinations, provider, wildcard, rooted-path, normalization, comparison, and failure rules |
| `GF-CONTENT` | Source order, wrappers, frontmatter, repository-specific names, and complete payload |
| `GF-SERIALIZATION` | CRLF and lone-CR normalization, LF and final-newline rules, BOM-less UTF-8, and byte checks |
| `GF-WRITE` | Complete-payload candidate creation, durable flush, verification, single-call publication, and prohibited fallbacks |
| `GF-FAILURE` | Phase postconditions, cleanup and uncertainty, bounded diagnostics, and fault cases |
| `GF-HOSTS` | Supported editions and hosts, executable identity, cross-cell equality, and idempotence |
| `GF-VERSION` | Timeless marker grammar, trusted expected version, authoring progression, and independent fixtures |
| `GF-NODE-LOCK` | Exact Node/npm producer and provenance, distribution verification, cache and side effects, dependency graph, and frozen consumers |
| `GF-YAML` | Parser package and API, document and schema strictness, diagnostics, and forbidden features |
| `GF-ACTION-PINS` | Closed action roles, full commit pins, provenance, runtime, and atomic pin updates |
| `GF-ACTION-INPUTS` | Authored security inputs and separately reviewed manifest defaults |
| `GF-GIT` | NUL records, byte allowlists, native statuses, cardinality, refs, ancestry, lease, and refspec |
| `GF-GRAPH` | Production and evidence triggers, permissions, needs, conditions, outputs, side effects, and sole writer |
| `GF-CREDENTIALS` | Job-token availability, authentication projection, cleanup, push-only materialization, and absence proofs |
| `GF-EVIDENCE` | Temporary workflow/ref structural equality, drills, retained identities, cleanup, and final absence |

Each row occurs exactly once. Record both repository URLs and commits, normative and implementation locators, evidence paths and SHA-256 values, observed values or fixture IDs, one status (`same`, `intentional difference`, or `blocker`), and a reason. Prove omitted rows inapplicable. Missing, duplicate, unknown, renamed, empty, or unexplained rows block closure.

Allowed intentional differences are limited to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence. For each intentional difference, name both literals or behaviors, explain the repository need, prove equal security and failure strength, name the owner, and state the review or expiry condition.

Before editing, validate every finding. List the options, create a finding-specific weighted rubric, score the options in a table, select the best option, and state the selected work in ASD-STE100-compliant language. Save analysis only in `TEMP-*` files.

If no common difference remains, make no implementation change. Post a pinned reverse-comparison record with both commits, blobs, the matrix digest, validation, and intentional differences.

If Terraform added or corrected common behavior, create or update one focused PS sync-back issue and pin both landed commits and blobs. Issue creation does not commence implementation. Stop if another feature implementation is active. After the issue record is complete and the implementation slot is free, explicitly commence the PS sync-back. Do not change repository settings unless the applicable administrator issue authorizes the exact request. Run the PS review protocol and re-run it after every byte change. Land one PR only after review covers the final bytes, and record its base, reviewed head/tree, merge method, landed commit/tree, affected paths, blobs, validation commands, runtime identities, and review outcome.

After a PS sync-back lands, compare its landed commit with Terraform again. If Terraform needs another repair, create or update the focused Terraform issue first. Issue creation does not commence implementation. Explicitly commence the repair only after the issue record is complete and the implementation slot is free. Run the Terraform review protocol and re-run it after every byte change. Land one PR only after review covers the final bytes.

If the same matrix row changes direction twice, stop and run a new decision process that evaluates both implementations. Close the cycle only when every common row is `same`, every intentional difference has complete evidence, no blocker remains, and the permanent closure record contains both repositories' final landed identities and validation evidence.
```

## Step 5 — run the global consistency sweep

### 5.1 Find and close untracked differences

Start the sweep only after Step 4 reaches a fixed point. Run it in a clean checkout with both fetched `main` commits. The inventory and comparison are read-only and do not commence implementation. This sweep finds configuration and process differences that no planned issue currently tracks. It is not permission to combine unrelated fixes.

Replace all four placeholders with the fetched commits and trees. Then use this prompt:

```markdown
Audit PSStyleGuide and TerraformStyleGuide for untracked cross-repository inconsistency after the two backlog-convergence passes.

PS baseline commit and tree: `<PS_BASELINE_COMMIT>`, `<PS_BASELINE_TREE>`.
Terraform baseline commit and tree: `<TF_BASELINE_COMMIT>`, `<TF_BASELINE_TREE>`.

Read both repositories only from these fetched commits. Inventory every path that controls generation, validation, workflow policy, Actions permissions and pins, Node/npm acquisition, Markdown lint, Git/path checks, supply-freeze evidence, Dependabot, agent review commands, issue handoffs, and contributor instructions. Map files by role. Do not assume that equal filenames have equal roles or that different filenames have different roles.

For every common role, compare bytes and semantics, including success and negative cases, failure classification, cleanup, credentials, permissions, native statuses, platform coverage, evidence retention, documentation, and validation commands. Re-run the full 16-row `GF-*` catalog for the foundation. Use a documented reduced matrix only for narrow non-foundation roles.

Use this closed catalog for the foundation:

| Stable row | Required comparison |
| --- | --- |
| `GF-PARAMETERS` | Public names, types, defaults, and omission, null, empty, and raw-value rules |
| `GF-DESTINATION` | Trusted root, fixed destinations, provider, wildcard, rooted-path, normalization, comparison, and failure rules |
| `GF-CONTENT` | Source order, wrappers, frontmatter, repository-specific names, and complete payload |
| `GF-SERIALIZATION` | CRLF and lone-CR normalization, LF and final-newline rules, BOM-less UTF-8, and byte checks |
| `GF-WRITE` | Complete-payload candidate creation, durable flush, verification, single-call publication, and prohibited fallbacks |
| `GF-FAILURE` | Phase postconditions, cleanup and uncertainty, bounded diagnostics, and fault cases |
| `GF-HOSTS` | Supported editions and hosts, executable identity, cross-cell equality, and idempotence |
| `GF-VERSION` | Timeless marker grammar, trusted expected version, authoring progression, and independent fixtures |
| `GF-NODE-LOCK` | Exact Node/npm producer and provenance, distribution verification, cache and side effects, dependency graph, and frozen consumers |
| `GF-YAML` | Parser package and API, document and schema strictness, diagnostics, and forbidden features |
| `GF-ACTION-PINS` | Closed action roles, full commit pins, provenance, runtime, and atomic pin updates |
| `GF-ACTION-INPUTS` | Authored security inputs and separately reviewed manifest defaults |
| `GF-GIT` | NUL records, byte allowlists, native statuses, cardinality, refs, ancestry, lease, and refspec |
| `GF-GRAPH` | Production and evidence triggers, permissions, needs, conditions, outputs, side effects, and sole writer |
| `GF-CREDENTIALS` | Job-token availability, authentication projection, cleanup, push-only materialization, and absence proofs |
| `GF-EVIDENCE` | Temporary workflow/ref structural equality, drills, retained identities, cleanup, and final absence |

Each row occurs exactly once. Record both repository URLs and commits, normative and implementation locators, evidence paths and SHA-256 values, observed values or fixture IDs, one status (`same`, `intentional difference`, `tracked work`, or `untracked blocker`), and a reason. Prove omitted rows inapplicable. Missing, duplicate, unknown, renamed, empty, or unexplained rows are untracked blockers.

Classify each difference as `same`, `intentional difference`, `tracked work`, or `untracked blocker`. Accept an intentional difference only for a proved repository-specific reason with equal security and failure strength. Name both literals or behaviors, explain the repository need, name the owner, state the review or expiry condition, and link the evidence. Convenience, implementation history, separate authorship, and lower effort are not repository-specific reasons. Link the issue that owns every `tracked work` row.

Before changing anything, validate each untracked finding. For each finding, list all practical options, create a unique weighted rubric, score the options in a table, and state the selected action in ASD-STE100-compliant language. Save analysis only in `TEMP-*` files.

For each untracked blocker, identify which repository is behind. Create or update one focused issue in that repository and pin the other repository's landed commit and source blobs. Issue creation does not commence implementation. Stop if another feature implementation is active. After the issue record is complete and the implementation slot is free, explicitly commence only that repair. Keep both repositories self-contained; do not create a shared module, runtime fetch, reusable cross-repository workflow, submodule, package, third source of truth, or one bulk cleanup PR. Do not change repository settings unless the applicable administrator issue authorizes the exact request. Run the repository review protocol and re-run it after every byte change. Land one PR only after review covers the final bytes, and record its base, reviewed head/tree, merge method, landed commit/tree, affected paths, blobs, validation commands, runtime identities, and review outcome.

After the repair lands, compare it in the other repository. If no common difference remains, post a pinned no-change record. If a focused reciprocal repair is required, create its issue first and commence it only after the issue record is complete and the implementation slot is free. Run the applicable repository review protocol and re-run it after every byte change. Land only after review covers the final bytes, and then run the reverse comparison. If the same matrix row changes direction twice, stop and run a new decision process that evaluates both implementations.

Close one repair cycle before commencing the next. Require every common row to be `same`, every intentional difference to have complete evidence, and no row to be a `blocker`. Post a permanent closure record with both repositories' final issue and PR URLs, bases, reviewed heads and trees, merge methods, landed commits and trees, affected paths, blobs, final matrix digest, validation commands, runtime identities, review outcomes, intentional differences, and explicit non-applicability results.

Finish only when every inventoried role has an owner and disposition, all repair cycles reach a fixed point, and the final record contains both repositories' final commits and trees, file/blob map, matrices and digests, tests, runtimes, intentional differences, and zero untracked blockers.
```

## Step 6 — use PSStyleGuide-first paired cycles

After the global sweep closes, use one paired cycle for each common capability: implement PSStyleGuide, update or open the Terraform issue from the landed PS handoff, implement TerraformStyleGuide, compare the Terraform result back in PSStyleGuide, and sync back any common improvement. If a capability is repository-specific, record the exact non-applicability reason and do not open a fake counterpart.

### 6.1 Run one PSStyleGuide-first paired cycle

Issue setup and implementation commencement are separate actions. Complete this sequence for one capability before the next PS implementation starts:

1. Create or update the PS issue and classify it as `common capability`, `repository-specific capability`, or `administrative only`. Name the mapped Terraform issue when one exists. Issue creation does not commence implementation.
2. Record the PS issue URL, immutable landed input commits and blobs, intended affected paths, expected repository-specific differences, and every real native dependency.
3. Verify that the preceding paired cycle has a permanent fixed-point closure record and that no feature implementation issue or PR is active. Then explicitly commence only the PS implementation.
4. Keep both repositories self-contained. Do not add a shared module, runtime fetch, reusable cross-repository workflow, submodule, package, or third source of truth. Run the PS review protocol and re-run it after every byte change. Land one PR only after review covers the final bytes, and record its base, reviewed head/tree, merge method, landed commit/tree, affected paths, blobs, validation commands, runtime identities, and review outcome.
5. Create or update the mapped Terraform issue only from the landed PS handoff and source blobs. Issue creation does not commence implementation. Do not develop an equivalent implementation independently.
6. After the Terraform issue record is complete and the implementation slot is free, explicitly commence only the Terraform adaptation. Preserve common behavior and change only proved repository-specific literals or behavior. Run the Terraform review protocol and re-run it after every byte change. Land one PR only after review covers the final bytes, and record the complete landed identity and validation evidence.
7. Compare the landed Terraform adaptation back against the landed PS source with the catalog below.
8. If no common difference remains, make no PS implementation change and post a pinned reverse-comparison record. Do not open an issue only for symmetry.
9. If Terraform added or corrected common behavior, create or update one focused PS sync-back issue. Issue creation does not commence implementation. After the record is complete and the implementation slot is free, explicitly commence the sync-back. Run the PS review protocol and re-run it after every byte change. Land one PS PR only after review covers the final bytes, and rerun the Terraform comparison.
10. If Terraform then requires another repair, create or update its focused issue first and commence implementation only after the issue record is complete and the implementation slot is free. Run the Terraform review protocol and re-run it after every byte change. Land only after review covers the final bytes.
11. End the cycle only when every common row is `same`, every intentional difference has complete evidence, and no row is a `blocker`. If the same row changes direction twice, stop and run a new decision process that evaluates both implementations.
12. Post one permanent closure record with both repositories' final issue and PR URLs, bases, reviewed heads and trees, merge methods, landed commits and trees, affected paths, source and destination blobs, final matrix digest, validation commands, runtime identities, review outcomes, intentional differences, and explicit non-applicability results.

A tracker update, read-only comparison, dependency edit, or separately authorized settings operation does not count as the active implementation issue, but it does not permit a second feature branch or PR. Do not change repository settings unless the applicable administrator issue authorizes the exact request.

Allowed intentional differences are limited to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence. For each intentional difference, name both literals or behaviors, explain the repository need, prove equal security and failure strength, name the owner, and state the review or expiry condition. Convenience, implementation history, separate authorship, and lower effort are not repository-specific reasons.

Use this closed catalog for every common capability. Prove omitted rows inapplicable for a narrow repository-specific capability.

| Stable row | Required comparison |
| --- | --- |
| `GF-PARAMETERS` | Public names, types, defaults, and omission, null, empty, and raw-value rules |
| `GF-DESTINATION` | Trusted root, fixed destinations, provider, wildcard, rooted-path, normalization, comparison, and failure rules |
| `GF-CONTENT` | Source order, wrappers, frontmatter, repository-specific names, and complete payload |
| `GF-SERIALIZATION` | CRLF and lone-CR normalization, LF and final-newline rules, BOM-less UTF-8, and byte checks |
| `GF-WRITE` | Complete-payload candidate creation, durable flush, verification, single-call publication, and prohibited fallbacks |
| `GF-FAILURE` | Phase postconditions, cleanup and uncertainty, bounded diagnostics, and fault cases |
| `GF-HOSTS` | Supported editions and hosts, executable identity, cross-cell equality, and idempotence |
| `GF-VERSION` | Timeless marker grammar, trusted expected version, authoring progression, and independent fixtures |
| `GF-NODE-LOCK` | Exact Node/npm producer and provenance, distribution verification, cache and side effects, dependency graph, and frozen consumers |
| `GF-YAML` | Parser package and API, document and schema strictness, diagnostics, and forbidden features |
| `GF-ACTION-PINS` | Closed action roles, full commit pins, provenance, runtime, and atomic pin updates |
| `GF-ACTION-INPUTS` | Authored security inputs and separately reviewed manifest defaults |
| `GF-GIT` | NUL records, byte allowlists, native statuses, cardinality, refs, ancestry, lease, and refspec |
| `GF-GRAPH` | Production and evidence triggers, permissions, needs, conditions, outputs, side effects, and sole writer |
| `GF-CREDENTIALS` | Job-token availability, authentication projection, cleanup, push-only materialization, and absence proofs |
| `GF-EVIDENCE` | Temporary workflow/ref structural equality, drills, retained identities, cleanup, and final absence |

Each row occurs exactly once. Record both repository URLs and commits, normative and implementation locators, evidence paths and SHA-256 values, observed values or fixture IDs, one status (`same`, `intentional difference`, or `blocker`), and a reason. Missing, duplicate, unknown, renamed, empty, or unexplained rows block closure.

### 6.2 Complete PS P1B and the protection interlock

The first Step 6 capability is PS P1B. Steps 3–5 must already be complete. Execute PS issues #147 and #152 as one interlocked capability cycle. Issue #152 is separately authorized settings work; it may overlap read-only preparation for #147, but it does not authorize a second feature implementation PR:

1. Re-read the PS foundation handoff and compare #147's assumptions with every landed contract.
2. Verify that no feature implementation issue or PR is active. Then explicitly commence #147 and implement its writer and terminal check `Build Style Guide Artifacts / approve_candidate`.
3. Reopen or supersede `docs/decisions/0001-accept-in-repository-trust-root.md` before the writer gains `contents: write`.
4. Reach one reviewed PR head. Record its exact head/tree, workflow identity, permissions, required-check name, unique evidence ref, source pins, and rollback inputs.
5. Start #152's bounded temporary proof. Re-export rules, classic protection, `main`, application identity, and writer permissions.
6. Perform the non-mutating bypass-eligibility check. If GitHub Actions integration ID `15368` is unavailable, stop and run the required writer-design decision. Do not create a substitute rule.
7. If eligible, create the temporary field-equivalent rule, run effective-bypass and rejection drills, retain evidence, delete the temporary rule and evidence ref, and prove exact restoration.
8. Revalidate the reviewed head. Create the approved persistent ruleset immediately before merge.
9. Retain the create response, ruleset ID, normalized JSON and digest, effective rules, exact required check and integration, `main` before and after, and rollback proof.
10. Close #152 only after the persistent rule is active and its evidence is complete.
11. Merge and close #147 only after #152 closes.
12. Post one permanent PS P1B handoff for Terraform issue #22.

Do not copy Terraform ruleset IDs, digests, or effective-rule JSON. Do not add a human bypass without a separate owner-approved decision.

### 6.3 Adapt landed P1B in Terraform issue #22

Terraform issue #22 is blocked by #21. Updating #22 is issue setup and does not commence implementation. Do not commence #22 until #21 lands, PS #147 has a permanent landed handoff, the P1B issue update is complete, and the implementation slot is free.

#### 6.3.1 Terraform #22 update prompt

Replace the placeholders, then add or amend a `Starting point — reuse landed PSStyleGuide P1B` section in #22:

```markdown
PSStyleGuide P1B landed through `<PS_P1B_PR_URL>` at `<PS_P1B_LANDED_COMMIT>`, tree `<PS_P1B_LANDED_TREE>`. Use that landed implementation and the permanent handoff `<PS_P1B_HANDOFF_URL>` as the T1B implementation source. Do not rebuild the writer, evidence protocol, lease/refspec checks, credential boundary, terminal result, or rollback design from the beginning.

This issue update records the starting point. It does not commence implementation. Do not create a feature branch or edit implementation files until this record is complete, the preceding cycle has a permanent closure record, and no feature implementation issue or PR is active.

Record every PS source blob read from the landed commit and every adapted Terraform destination blob. Change repository names, generated filenames, schema/type prefixes, check names, ruleset names, and local evidence identifiers. Preserve common permissions, job isolation, credential materialization, candidate consumption, ancestry/lease/refspec checks, native statuses, failure postconditions, cleanup, and audit truth.

Use Terraform's own administrator issue and live settings evidence. Never copy PS ruleset IDs, request digests, application/rule responses, main-ref values, or audit records.

Refresh the reciprocal matrix at implementation start and before merge. An unexplained weaker behavior blocks merge. Keep both repositories self-contained.

At explicit implementation start, do not change repository settings without exact administrator-issue authorization. Run the Terraform review protocol and re-run it after every byte change. Merge only after review covers the final bytes.
```

Terraform #21 is complete before Step 6 starts. After the issue update is complete and the start gate in section 6.1 is satisfied, explicitly commence #22 from the landed PS P1B commit and the final Terraform baseline from Steps 3–5. After #22 lands, run the reverse PS comparison and sync-back sequence in section 6.1. If a PS PR lands, run the Terraform comparison again. Do not commence PS #148 until the P1B/T1B cycle reaches a fixed point.

### 6.4 Complete the remaining known issues in order

After the P1B/T1B cycle closes:

1. Verify the PS #148 issue record and the section 6.1 start gate. Then explicitly commence and land PS #148. Compare its affected role with TerraformStyleGuide. If the behavior is common and absent or weaker in Terraform, create one focused Terraform issue. Issue creation does not commence implementation. Explicitly commence its implementation only after the issue record is complete and the implementation slot is free, then close the reciprocal cycle. If Terraform is already equivalent, post a pinned no-change record. If the blank-line example is PowerShell-specific, post a pinned non-applicability record.
2. Verify the Terraform #23 issue record and the section 6.1 start gate. Then explicitly commence and land Terraform #23, which is Terraform-specific but is a native prerequisite of #24. Run a PS applicability check. If PS has a common affected role, create the focused PS issue first and commence it only after the issue record is complete and the implementation slot is free. If PS is already equivalent, post a pinned no-change record. If the state-version recovery content has no PS role, post a pinned non-applicability record. Do not invent a PS issue only for symmetry.
3. Verify all four predecessor handoffs and resolve the Step 1 advisory gate. Then explicitly commence and land PS #149. Update Terraform #24 from the landed PS handoff; this issue update does not commence implementation. After the update is complete and the implementation slot is free, explicitly commence #24, land it, and run the reverse PS comparison and any required sync-back cycle.
4. Verify that #149 and the section 6.1 start gate are complete. Then explicitly commence PS #151. Compare the landed result with the Terraform validator. If an applicable control is absent or weaker in Terraform, create one focused Terraform issue from the landed PS #151 commit and blobs. Issue creation does not commence implementation. Explicitly commence the Terraform work only after the issue record is complete and the implementation slot is free. If the control is already equivalent, post a pinned no-change record. If the control is structurally inapplicable, post a pinned non-applicability record.
5. Do not commence the next numbered item until the current item and every applicable reciprocal repair reaches a fixed point.

PS #149 owns the PS Husky preparation mechanism and dependency/update-governance convergence. It must explicitly compare Terraform issue #24's current contract and the direct Terraform `prepare` command. Select one common mechanism unless a proved repository-specific need requires a difference.

#### 6.4.1 Terraform #24 update prompt

After PS #149 lands, replace the placeholders and update Terraform issue #24:

```markdown
PSStyleGuide dependency and npm governance landed through `<PS_P3_PR_URL>` at `<PS_P3_LANDED_COMMIT>`, tree `<PS_P3_LANDED_TREE>`. Use the permanent handoff `<PS_P3_HANDOFF_URL>` as the implementation source.

This issue update records the starting point. It does not commence implementation. Do not create a feature branch or edit implementation files until this record is complete, the preceding cycle has a permanent closure record, and no feature implementation issue or PR is active.

Read every relevant PS source blob from that commit. Do not independently select a package-manager policy, audit parser, process runner, exception schema, Husky installer, workflow topology, or evidence format. Adapt repository identity, issue URLs, package findings, generated filenames, check names, and any Terraform-specific dependency graph.

Preserve common isolation, exact toolchain selection, install/audit vectors, config neutralization, bounded process I/O, termination states, JSON validation, exception governance, live issue verification, schedule/manual read-only behavior, and failure truth. Refresh the reciprocal matrix at start and before merge. An unexplained weaker behavior blocks merge.

At explicit implementation start, keep the repository self-contained and do not change repository settings without exact administrator-issue authorization. Run the Terraform review protocol and re-run it after every byte change. Merge only after review covers the final bytes.
```

After any Terraform #151-equivalent PR lands, run the reverse PS comparison and any required sync-back cycle. Do not create a placeholder issue merely for symmetry.

### 6.5 Use the reusable paired-cycle prompt for future work

For each future capability that can apply to both repositories:

1. Create or update the PS issue. Issue creation does not commence implementation.
2. Satisfy the section 6.1 start gate, then explicitly commence the PS implementation.
3. Review and land the PS PR. Post a permanent handoff with exact identities and common or intentional-difference rows.
4. Create or update the Terraform issue only from that landed handoff. Issue creation does not commence implementation.
5. After the issue record is complete and the implementation slot is free, explicitly commence the Terraform adaptation without a shared module.
6. Review and land the Terraform PR.
7. Run the reverse PS comparison. Create a focused PS sync-back issue before any correction, then commence it only after the issue record is complete and the implementation slot is free.
8. Repeat the reciprocal comparison until the cycle reaches a fixed point. Do not commence the next PS capability before the permanent closure record exists.

Use this placeholder text in the Terraform issue:

```markdown
## Starting point — adapt the landed PSStyleGuide implementation

PSStyleGuide issue `<PS_ISSUE_URL>` landed through PR `<PS_PR_URL>` at commit `<PS_LANDED_COMMIT>`, tree `<PS_LANDED_TREE>`. The permanent implementation handoff is `<PS_HANDOFF_URL>`.

This issue update records the starting point. It does not commence implementation. Do not create a feature branch or edit implementation files until the issue record is complete, the preceding cycle has a permanent closure record, and no feature implementation issue or PR is active.

Read the source files only from `<PS_LANDED_COMMIT>` and record their Git blobs before copying. Do not follow a branch and do not rebuild the capability independently.

Adapt only repository identity, domain-specific filenames and payloads, schema/type prefixes, check or ruleset names, platform applicability, and repository-specific evidence. Preserve all common security, serialization, path, credential, native-status, atomicity, cleanup, error-handling, and failure-truth behavior.

Create no shared runtime dependency. At implementation start and before merge, complete the closed reciprocal matrix. Classify each row as `same`, `intentional difference`, or `blocker`. An unexplained or weaker behavior blocks merge.

Use this closed reciprocal catalog:

| Stable row | Required comparison |
| --- | --- |
| `GF-PARAMETERS` | Public names, types, defaults, and omission, null, empty, and raw-value rules |
| `GF-DESTINATION` | Trusted root, fixed destinations, provider, wildcard, rooted-path, normalization, comparison, and failure rules |
| `GF-CONTENT` | Source order, wrappers, frontmatter, repository-specific names, and complete payload |
| `GF-SERIALIZATION` | CRLF and lone-CR normalization, LF and final-newline rules, BOM-less UTF-8, and byte checks |
| `GF-WRITE` | Complete-payload candidate creation, durable flush, verification, single-call publication, and prohibited fallbacks |
| `GF-FAILURE` | Phase postconditions, cleanup and uncertainty, bounded diagnostics, and fault cases |
| `GF-HOSTS` | Supported editions and hosts, executable identity, cross-cell equality, and idempotence |
| `GF-VERSION` | Timeless marker grammar, trusted expected version, authoring progression, and independent fixtures |
| `GF-NODE-LOCK` | Exact Node/npm producer and provenance, distribution verification, cache and side effects, dependency graph, and frozen consumers |
| `GF-YAML` | Parser package and API, document and schema strictness, diagnostics, and forbidden features |
| `GF-ACTION-PINS` | Closed action roles, full commit pins, provenance, runtime, and atomic pin updates |
| `GF-ACTION-INPUTS` | Authored security inputs and separately reviewed manifest defaults |
| `GF-GIT` | NUL records, byte allowlists, native statuses, cardinality, refs, ancestry, lease, and refspec |
| `GF-GRAPH` | Production and evidence triggers, permissions, needs, conditions, outputs, side effects, and sole writer |
| `GF-CREDENTIALS` | Job-token availability, authentication projection, cleanup, push-only materialization, and absence proofs |
| `GF-EVIDENCE` | Temporary workflow/ref structural equality, drills, retained identities, cleanup, and final absence |

Each row occurs exactly once. Record both repository URLs and commits, normative and implementation locators, evidence paths and SHA-256 values, observed values or fixture IDs, one status (`same`, `intentional difference`, or `blocker`), and a reason. Prove omitted rows inapplicable. Missing, duplicate, unknown, renamed, empty, or unexplained rows block closure.

For each intentional difference, name both literals or behaviors, explain the repository need, prove equal security and failure strength, name the owner, and state the review or expiry condition. Convenience, implementation history, separate authorship, and lower effort are not repository-specific reasons.

Do not change repository settings unless the applicable administrator issue authorizes the exact request. Run the Terraform review protocol and re-run it after every byte change. Merge only after review covers the final bytes. Record source and destination blobs, tests, runtime identities, reviewed head/tree, merge method, landed commit/tree, and the next handoff.

After the Terraform PR lands, use a clean PS checkout. Fetch both repositories, read only the landed PS and Terraform commits, record all compared blobs, and run the same catalog in reverse. If no common difference remains, make no PS implementation change and post a pinned reverse-comparison record.

If Terraform added or corrected common behavior, create or update one focused PS sync-back issue and pin both landed commits and blobs. Issue creation does not commence implementation. After the issue record is complete and the implementation slot is free, explicitly commence the PS sync-back. Run the PS review protocol and re-run it after every byte change. Land one PR only after review covers the final bytes. Then compare the new PS landed commit back in Terraform. Create any focused Terraform repair issue before implementation and commence it only after the record is complete and the implementation slot is free. Run the Terraform review protocol against the final repair bytes before landing.

If the same matrix row changes direction twice, stop and run a new decision process that evaluates both implementations. Repeat until every common row is `same`, every intentional difference has complete evidence, and no blocker remains. Post the permanent fixed-point closure record before the next PS implementation starts.
```

Do not replace placeholders until the PS PR has landed. Never use a reviewed head, test-merge ref, branch name, or anticipated squash SHA as `<PS_LANDED_COMMIT>`.

## Step 7 — retain the independent residual policy

Leave PS issues #155 and #156 open and independent.

- Revisit #155 only if the candidate validator admits a competing writer, Windows PowerShell 5.1 support ends and a portable API becomes available, or a later step adopts a suitable native helper.
- Pick up #156 opportunistically when the candidate files change or a suitable external runner becomes available.
- If an item becomes mandatory, validate and record the trigger. Create a focused actionable issue and give that issue only its real dependencies. Issue creation does not commence implementation.
- Explicitly commence the residual implementation only after its issue record is complete, the preceding fixed-point cycle is closed, and no feature implementation issue or PR is active. Run the repository review protocol and re-run it after every byte change. Land only after review covers the final bytes, and record the complete landed identity and validation evidence.
- Do not change repository settings unless the applicable administrator issue authorizes the exact request.
- If the residual changes a role that exists in both repositories, compare the landed result in the other repository. Create any reciprocal issue before implementation and commence it only when the implementation slot is free. Run the applicable review protocol and re-run it after every byte change. Land only after review covers the final bytes, run the reverse comparison, and close the cycle only when every common behavior is the same or has a proved intentional difference with equal security and failure strength.
- Do not add #155 or #156 as blockers of the foundation umbrella, #152, #147, Terraform #21, or Terraform #22 without a new material trigger.

## Step 8 — verify completion

This plan is complete only when all of the following are true:

- Every implementation has a pre-existing focused issue record and a separate, explicit commencement record. No two feature implementation issues or PRs were active at the same time.
- Every cross-repository input is pinned to a landed commit and Git blob. No implementation copied from a moving branch or introduced a shared runtime dependency, reusable cross-repository workflow, submodule, package, or third source of truth.
- Every PR ran its repository review protocol against the final bytes. Every cycle records both repositories' issue and PR URLs, bases, reviewed heads and trees, merge methods, landed commits and trees, affected paths, blobs, validation commands, runtime identities, and review outcomes.
- Every required reciprocal matrix contains each applicable row exactly once. Every common row is `same`; every intentional difference names both behaviors, repository need, equal security and failure strength, owner, and review or expiry condition; and no blocker remains.
- Every posted issue body and comment contains verified identities. No placeholder or fabricated SHA, URL, PR number, tree, or blob was posted.
- Every native dependency represents a real completion prerequisite. No tracker relationship falsely blocks implementation, and no repository setting changed without exact authorization from the applicable administrator issue.
- Step 3's five PS import cycles close in order, each with a Terraform comparison, any required Terraform repair, a reverse PS comparison, and a permanent fixed-point record.
- The PS foundation umbrella and its four children are closed with a permanent landed handoff that identifies both repositories' final commits and blobs.
- The separate Claude command cycle closes without duplicating volatile protocol text.
- The Terraform convergence tracker contains all five Step 3 cycle records and no aggregate foundation implementation PR exists.
- Draft PS PR #164 is reviewed and landed through PS #160, and its reciprocal cycle reaches a fixed point.
- PS and Terraform generators share the canonical tracked-present/tracked-absent publication and structured-result behavior.
- Both generators use fixed root and destination authority, complete BOM-less UTF-8/LF payloads, same-directory durable candidate verification, one `File.Replace` or non-overwriting `File.Move` publication call, truthful `ReplacementStateUncertain` reporting, no post-publication rollback claim, and reusable raw NUL-delimited Git validation with exact native-status handling.
- Repository-code jobs in both repositories contain no actions and have no repository-token scopes.
- Both repositories use separate action-only publication jobs, verified official Node distributions in action-free Node jobs, strict offline workflow-policy parsing and fixtures, machine-readable authority for roles, inputs, defaults, supply identities, and case allocation, and the same script-version grammar and PowerShell authoring rules.
- Both repositories use the same common workflow-policy behaviors and case coverage, with only recorded repository-specific literals. No workflow writer exists before its P1B/T1B introduction and proof.
- PS issue #158 is implemented and both repositories have a read-only reproducible supply-freeze method.
- Step 4 closes Terraform issue #21 from landed PS PR #153 and completes the reciprocal PS comparison and any sync-back work.
- Step 5 inventories all common roles, resolves every untracked blocker through focused fixed-point cycles, and retains the final two-repository evidence.
- The Step 6 P1B/T1B cycle closes: PS #147/#152 is complete, Terraform #22 consumes the landed PS P1B handoff, and the reciprocal comparison has no blocker.
- PS #148 and Terraform #23 each have an implemented result and the required cross-repository applicability record.
- The P3/T3 cycle closes: PS #149 lands first, Terraform #24 consumes its landed handoff after #23, and reciprocal comparison and sync-back work reach a fixed point.
- PS #151 has an applicable Terraform follow-up cycle or a pinned structural non-applicability record.
- The advisory decision never expires without either completed #149 or a separately approved, fully pinned superseding decision.
- PS #155 and #156 remain independent unless a documented trigger creates a focused blocker.
- Every later common capability uses a landed PS handoff, a Terraform adaptation, a reverse PS comparison, and fixed-point closure before the next PS issue starts.
- No shared cross-repository runtime dependency exists.

## References

- [PS issue #145](https://github.com/franklesniak/PSStyleGuide/issues/145) and [PS PR #150](https://github.com/franklesniak/PSStyleGuide/pull/150)
- [PS PR #153](https://github.com/franklesniak/PSStyleGuide/pull/153) and PS issues [#147](https://github.com/franklesniak/PSStyleGuide/issues/147), [#148](https://github.com/franklesniak/PSStyleGuide/issues/148), [#149](https://github.com/franklesniak/PSStyleGuide/issues/149), [#151](https://github.com/franklesniak/PSStyleGuide/issues/151), [#152](https://github.com/franklesniak/PSStyleGuide/issues/152), and [#158](https://github.com/franklesniak/PSStyleGuide/issues/158)
- [PS foundation umbrella #159](https://github.com/franklesniak/PSStyleGuide/issues/159), child issues [#160](https://github.com/franklesniak/PSStyleGuide/issues/160), [#161](https://github.com/franklesniak/PSStyleGuide/issues/161), and [#162](https://github.com/franklesniak/PSStyleGuide/issues/162), and [draft PR #164](https://github.com/franklesniak/PSStyleGuide/pull/164)
- [PS Claude command-parity issue #163](https://github.com/franklesniak/PSStyleGuide/issues/163)
- [Terraform issue #20](https://github.com/franklesniak/TerraformStyleGuide/issues/20) and [Terraform PR #26](https://github.com/franklesniak/TerraformStyleGuide/pull/26)
- [Terraform PR #27](https://github.com/franklesniak/TerraformStyleGuide/pull/27) and [Terraform PR #30](https://github.com/franklesniak/TerraformStyleGuide/pull/30)
- Terraform issues [#21](https://github.com/franklesniak/TerraformStyleGuide/issues/21), [#22](https://github.com/franklesniak/TerraformStyleGuide/issues/22), [#23](https://github.com/franklesniak/TerraformStyleGuide/issues/23), [#24](https://github.com/franklesniak/TerraformStyleGuide/issues/24), and [convergence tracker #31](https://github.com/franklesniak/TerraformStyleGuide/issues/31)
- [GitHub secure-use guidance for Actions](https://docs.github.com/en/actions/reference/security/secure-use)
- [GitHub Actions runner authentication design](https://github.com/actions/runner/blob/main/docs/design/auth.md)
- [GitHub Actions `GITHUB_TOKEN`](https://docs.github.com/en/actions/concepts/security/github_token)
- [GitHub workflow permissions](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#permissions)
- [Node.js permission model](https://nodejs.org/api/permissions.html)
- [.NET `File.Replace`](https://learn.microsoft.com/en-us/dotnet/api/system.io.file.replace)
- [.NET `File.Move`](https://learn.microsoft.com/en-us/dotnet/api/system.io.file.move)
- [Git pathname format and `-z`](https://git-scm.com/docs/git-status#_pathname_format_notes_and_z)
- [GitHub issue dependencies](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/creating-issue-dependencies)
