<!-- markdownlint-disable MD013 -->
# Dedicated review setup: corrected security scope decision

Status: READ-ONLY PROPOSAL, pending root display/selection/release. Input TF68 H3b12700eb636da67f5861637e5b139a18fa82140/treea4e7ce67d14cb4d5b4e0b677ff995ff4adbd2d29; accepted B e21b74fe0b56551008f78f9f2946cd2a0f9c19ce. Original REPORT.md99da02aff7f7437554fbd37f929884b2446abba74945515600c0d8f75c9333a0 and evidence.json87a4ec975f93f1260ae1dd919c1271698be5f3a5e03de3f54069d7d2428359c1 are preserved byte-for-byte. Root already selected original design C95.9. This record supersedes only its two-path/no-validator scope and supplies the missing contract decision. It does not release implementation or erase the current cancelled service result.

## 1. Material validation

Independent quality found a concrete omission. Test-AgentInstructions.ps1 lists only copilot-setup-steps.yml in Get-AgentSetupInputSpec327–367, its exact governed paths94 and no-action/no-credential checks681–697. Read-AgentSetupInputContent413–423 uses that finite catalog for staged equality and immutable regular-file revision reads. SelfTest's Assert-AgentSetupSelfTest covers the old file's security mutations and existing catalog staged/revision checks. A dedicated file added only with working-tree fixture assertions would be outside these production protections. Benign working-tree review YAML could hide unsafe staged review YAML from this contract. This is source-derived material evidence; no exploit or test was executed in this proposal pass.

Get-GitRegularFileBlobId already reads literal NUL Git metadata with Read-BoundedProcessData, a path-sized output bound and10-second timeout, native-success check, exact ordinal path and single100644 blob/revision or stage0/index entry. Empty output currently fails. Read-RepositoryInputData checks path components, links/types, bounded bytes and staged text identity. Read-GitRevisionText uses the regular-file proof. Extend these narrowly; do not replace them with File.Exists/Test-Path or catch-all missing handling.

Maintainers need equivalent current/local/staged/revision protection. Contributors need supported historical trees without a dedicated review file to work. Security owners need absent inputs separated from unreadable/malformed/mismatched inputs. Review users need a usable dedicated setup. QA needs actual-reader negative controls. Existing required setup files remain required. The classifier already covers top-level workflow YAML; triggers and general workflow-policy admission need no new filename exception. Adding the file alone is not evidence of a separate immutable payload-guard defect.

## 2. Options before scoring

A retain the original two-file proposal and rely on CI fixtures. B require the new file in every tree. C add only this filename as an optional-presence finite catalog member with bounded absence proof and full present-input controls. D enumerate and validate all workflows generically. E create an independent special-case reader/security mechanism. F permit absence using a date/version/branch cutoff. G introduce a new capability manifest that declares the optional service workflow. H defer the dedicated file and retain existing shared full setup.

C may use an explicit opt-in missing result in the existing metadata helper or a narrow adjacent helper; duplicating the whole reader is E. C+G adds a declaration without current need; C+D adds unrelated discovery. Making all inputs optional, treating read errors as absence, or checking only worktree bytes are A-class security gaps and ineligible. H with provider support is possible but does not resolve the demonstrated timeout. All alternatives preserve the owner no-failing-CI rule; none permits a merge waiver.

## 3. Unique weighted rubric

Scores0–10, total=sum(weight*score)/10. Security/input fidelity35: exact source and bounded regular-file reads, staged equality, native failures and action/credential refusal. Compatibility20: true absence versus errors, old required-input protection and valid historical snapshots. Review usability20: deliver the supported preparation without new contributor configuration. Regression strength20: actual local/staged/revision positive/negative oracles. Maintenance5: finite understandable scope. Security bypass or catch-all missing conversion disqualifies an option; churn cannot outweigh correctness.

## 4. Scores before selection

| Option | Security35 | Compatibility20 | Review20 | Regression20 | Maintenance5 | Total | Basis |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 2 | 8 | 10 | 2 | 10 | 52.0 | Keep original two-file scope; fixtures alone cannot guard staged/revision input; ineligible. |
| B | 10 | 2 | 8 | 8 | 9 | 75.5 | Require new file everywhere; breaks supported historical absence. |
| C | 10 | 10 | 10 | 10 | 7 | 98.5 | Finite optional-presence member with strict existing present-input protections. |
| D | 8 | 6 | 8 | 7 | 3 | 71.5 | Discover every workflow; unnecessary wider admission and bounds. |
| E | 8 | 8 | 9 | 7 | 4 | 78.0 | Independent special reader/security checks duplicate existing mechanisms. |
| F | 7 | 5 | 8 | 6 | 6 | 65.5 | Date/version/branch cutoff does not establish actual absence or identity. |
| G | 9 | 8 | 7 | 8 | 4 | 79.5 | New capability manifest can work but creates extra coupled declaration. |
| H | 10 | 10 | 0 | 7 | 10 | 74.0 | Defer dedicated setup; safe current contract but retains service blocker. |

## 5. Selected detailed proposal

Select C98.5. Keep the previously selected dedicated-review design; correct its product scope to four paths: .github/workflows/copilot-code-review.yml, .github/workflows/Test-CiHelpers.test.mjs, .github/workflows/Test-AgentInstructions.ps1 and .github/workflows/Test-AgentInstructions.SelfTest.ps1. Apply genuine edit-date script/function metadata where required. Do not alter package locks, classifier, protected instructions or generic workflow policy merely to introduce the filename. R11's selected private Git discovery can share the CI-helper file under one writer after root release.

Add exactly copilot-code-review.yml to Get-AgentSetupInputSpec with the existing setup bound65536 and an explicit optional-presence property. All existing members remain required by default. Add the exact name to governed paths. Apply every existing no-action/no-credential pattern to each present setup file. Keep the old coding file required and its full-validation contract unchanged.

In an immutable revision, allow absence only when a successful bounded literal Git tree lookup returns zero records for this exact optional path. If present, require the existing exact regular100644 entry and bounded strict UTF-8 content read. A native failure, malformed/multiple record, nonregular mode or unreadable content fails. Add an opt-in missing result to the existing metadata helper; every existing caller retains its strict default. Do not infer absence from cat-file failure or an exception.

For local inputs, inspect exact index metadata with the same bounded rule. An indexed entry must pass the content reader even when the worktree file is missing. A staged ACMR-set member missing from the index is an error. An existing filesystem item without an index entry must follow existing metadata admission and cannot be omitted as absent. Permit omission only after a successful empty index query and a terminating literal filesystem lookup that establishes the exact item is missing. Access failure, links/nonregular items and read errors must not become absence. Keep existing parent-component safety checks for content reads. Specify and test the missing-item exception narrowly. This retains existing reader safeguards; it is not a claim of race-free filesystem access.

A supported historical tree without this member remains valid. Deliberately removing the optional member from a future committed tree selects documented shared setup fallback and leaves the required coding setup intact. A staged deletion with a remaining local item must not masquerade as absence. Document these semantics. No date/branch or broad optional profile is required.

## 6. Meaningful validation after release

Use actual helpers and private Git fixtures for current local/staged/revision positives and historical absence of only the new optional member. Retain required-old-file deletion negatives. Extend action and each credential mutation to the new file. Cover unsafe staged/benign worktree mismatch, indexed-but-worktree-missing, staged-set path missing from index, present untracked item, genuine absence, deletion with residual worktree item, directory/link/nonregular mode, malformed/extra Git records, oversized bytes, invalid UTF-8 and native-read failure. Verify strict default behavior of existing metadata-helper callers. The changed branch must fail if optional presence is wrongly inferred or a security loop omits the new file.

Run focused Windows/Linux reader/security tests, full-file parser/analyzer and affected CI helper tests. Retain original proposal's actual-body dedicated/coding prerequisite, acquisition, declaration, locked install, hook activation, aggregate dispatch/omission and final-guard controls. Root coordinates one final all-files precommit plus accepted-B/new-H endpoints/current audit and fresh reviews/CI appropriate to this production-reader change. This is not an annotation-only exemption. No new test was run for this read-only proposal.

## 7. Primary support, limits and accounting

GitHub documents the dedicated file and fallback; the local current source defines repository-specific guards. [Dedicated review runners](https://docs.github.com/en/copilot/how-tos/copilot-on-github/set-up-copilot/configure-runners). Retain original proposal's default-branch activation uncertainty: ordinary success or PR file presence does not prove the service selected it. [Environment setup](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/customize-the-agent-environment). Independent quality report d561552c7b8988f269d6425765b311cb444c2c7d520d44bec9e5077bce64040f and JSON ba431285ef46da7d4b85d4b49cc0f8de995f42bba126b27db9d26924165b3fae are bound in evidence.

The original C95.9 score was a design estimate conditional on retaining trust/testability, not a passed security proof. C98.5 is the distinct missing-contract decision; do not call the original two-file scope sufficient. Root can select and release these unprivileged corrections under existing authority. This worker has no release. No extra paid infrastructure, setting or support-message permission is inherently needed. The current cancelled service run remains an acceptance blocker. Default-branch activation cannot justify merging through failed CI; stop at any actual activation constraint for root direction.

The new file and validator extend A03/A21 paired scope beyond the historical six-path R8 packet. SelfTest/CI-helper changes must converge with genuine existing repository exceptions. Root alone increments applicable transfers before actual destination work. Counters1/3/5/5 and original deadline remain unchanged. R13 ordinary behavior timeout is distinct and also requires resolution. Product/index/refs/config/dependencies remain unchanged; this packet is a proposal, not acceptance.
