<!-- markdownlint-disable MD013 -->

# B99 current-input readiness and aggregate applicability proposal

Read-only preparation on 2026-10-06. B99 remains selected, unimplemented work. After genuine PS235 acceptance and a fresh accepted-main bind, root can release one PS-first writer for the four paths below. TF dedicated-service S1 proof is an open acceptance obligation, not a prerequisite to this independent PS implementation. No new writer, test, transfer or request is released here.

## Current inputs and implementation boundary

PS input is H `504cd7672ac9604ace765a4f451346f801f09ddd`, tree `a716a1f8ff7e4f385e089b0f056adbcde9c973cb`, over native B `98177628b7bc02c646724bfc8aa0fd73fed0cd24`. TF accepted input is M `a840f21b03f0dcac0815e2f7f044928667402b42`, tree `e71b81232ba0f197acf5f126e4b14f1e90ee7da2`. Named raw Git trees contain no prohibited compiled/cache filenames and no B99 literals in the selected four paths. This proves missing admission capability, not an existing tracked-artifact incident.

| Selected path | PS H raw blob | TF M raw blob | Required bounded change |
| --- | --- | --- | --- |
| `.pre-commit-config.yaml` | `f0fcbb13bfdb25d7549cae7aea216ae9b81ee564` | `d6fa21489388686703c94ea33c39d0dd41b8bd16` | Add one `no-tracked-compiled-python` hook in an existing local group, using native `language: fail`, exact `(?i)(^\|/)__pycache__/\|\.py[cod]$`, and the selected corrective entry. Preserve all eleven hooks, pins, suppression semantics and default filename/stage activation. |
| `.gitignore` | `926d96e120f52d9e812ab4f07d6c835ab74941a6` | same | Add `__pycache__/` and `*.py[cod]`; preserve `.venv/`, `CLAUDE.local.md`, dependency/cache/log rules and current bytes outside the addition. |
| `.github/workflows/Test-AgentInstructions.ps1` | `67e0c1ce95ff6b99c76f1959b5c284e208b450dd` | same | Admit required root `.gitignore` into the finite setup data map at 65536 bytes; extend the finite hook/ignore contract. Preserve local/staged/immutable revision readers and accepted-B authority. |
| `.github/workflows/Test-AgentInstructions.SelfTest.ps1` | `43e08f56376b1b67b8e797b06649ab04fce12aed` | `07886736b000aeff5d5d431ed31098bcdc4add48` | Extend the existing setup positive/mutation and reader-closure tests; retain the current native/metadata/runtime controls. |

Every entry is a regular `100644` blob. Evidence supplies all twelve PS/TF/held raw SHA256 identities, bytes, modes and blobs. PS/TF validator bytes are identical. The pre-commit difference is only its repository-name first comment. SelfTest differs only at line2729 in the existing P1/T1 supply-provenance document path. Preserve those exact justified differences and synchronize touched shared-script metadata on the real future author date.

Held A07 HEAD `48f4d8a36c8faceee12afac78aaecea0d176125d` and staged tree `c68b5e1c6ae4a793df16c316c81c824164bc3be6` remain untouched. Its four stage-0 rows match that tree; before/after index hashes are equal. It has no B99 implementation, older validator/child bodies, and an older ignore file without `.venv/`. Do not apply that snapshot over the current source or use it as a ready patch.

## Exact coupled regions and authority

Current PS and TF share the following validator regions: `Get-AgentSetupInputSpec`464–511, `Read-AgentSetupInputContent`513 onward, and `Get-AgentSetupContractFailure`723 onward. The setup map currently omits `.gitignore`; its existing bounded main reader is at8616–8632 with `$intGitIgnoreMaximumInputBytes=65536` at45. Adding the required setup-map row reuses the same strict UTF-8, regular-file, byte-bound and staged equality machinery. Main setup content is read at8285 and contracted at8611. Keep the personal-memory ignore tests/checks at5069 onward and8635 onward intact.

Extend existing group/pin checks769–785 and hook-body extraction796–804 with one admitted B99 body. Require one definition, exact language/regex/message and default activation. Reject duplicate fields, extra `exclude`, restrictive `types`/`types_or`, stage overrides, `always_run`, disabled filenames and global selectors/stage overrides that bypass the filename ban. Check both required ignore lines as actual root data, independently of the rejection mechanism. Keep the finite shape readable; no new general YAML parser or scanner is needed.

The new ignore data does not choose a parser, executable, dependency or exemption authority. It is already push-governed at validator96, while maintenance classification has a different role. The B99 hook/validator changes are already maintenance selectors. Do not add a classifier edit solely for this data row. Ordinary later ignore-only changes must be checked by accepted code at B against exact H data; candidate SelfTest/ProposedPolicy is not accepted authority during first adoption. The former readiness statement that old accepted TF lacked an ignore consumer remains true historically; current landed TF now has this exact shared reader, so no old inline architecture must be restored.

SelfTest `Assert-AgentSetupSelfTest`3353–3652 supplies current positive input, cloned content mutations, immutable revision comparison and a dynamic per-input staged-mismatch loop3517–3545. Adding the map row includes `.gitignore` in that loop. Add specific missing-required-input and 65536/65537-byte controls alongside3547–3573. Add B99 missing/duplicate definition, wrong language, removed case flag/`d`/cache alternative, restrictive/global activation, and missing each ignore-line controls to3384–3450. Every mutation must change real input and assert its particular rejection; no success may be inferred merely from a duplicate regex in a test.

## Validated remaining applicability conflict

The exact current product full-setup caller, `copilot-setup-steps.yml`981, runs native `pre_commit run --all-files` in a disposable copy and handles its exit; it does not demand zero skips. The dedicated review setup prepares tools and retains its immutable guard; it does not run that full aggregate. The agent workflow likewise supplies no fixed aggregate count. No hosted workflow change follows from this finding.

The preserved private Linux final/aggregate runner is different: `inside.py`137–138 requires eleven `Passed` lines and zero `Skipped`; its manifest and launcher also pin eleven. That is valid for the completed current configuration. It cannot validate the future twelve-hook B99 configuration: with no forbidden tracked path, native fail language reports one no-files skip. Merely changing eleven to twelve still cannot pass. This is a concrete prospective profile incompatibility, already flagged by B99; it is not a new product failure or a reason to rerun unchanged evidence.

[Pre-commit's native contract](https://pre-commit.com/#fail) distinguishes filename applicability. Its [pinned 4.6.2 implementation](https://github.com/pre-commit/pre-commit/blob/v4.6.2/pre_commit/languages/fail.py) always returns failure when called; the documented `always_run` option forces a call with no matching file. Thus `always_run: true` would reject a clean source tree. Completed Windows/Linux probes independently establish the normal no-match behavior. Git ignores reduce accidental staging and cannot replace rejection of a force-added file.

This is a bounded revision to the existing B99 applicability decision, not a second guard design. The following options and scores are a proposal for root's review/display before the corresponding future profile edit. Historical runners and results stay unchanged.

## Options and finding-specific rubric

Maintainers and security reviewers need no weakened artifact admission or lost existing hook. New contributors need a clean tree to validate without suppression. Windows/Linux tooling owners need native semantics and exact runtime reuse. CI/QA and auditors need identified outcomes, independent applicability and negative controls. Agents/operators need a simple restart boundary; schedule owners need no redundant suites. Guide consumers, cloud/recovery operators, localization and accessibility users acquire no changed interface; their unrelated approval gates remain intact.

Options are exhaustive within this bounded caller problem: A retains eleven/zero; B accepts native exit0 alone; C allows arbitrary skipped hooks/counts; D permits only independently proved B99 non-applicability while retaining eleven passes; E reselects admission into an always-running existing validator; F adds a dedicated always-running system scanner; G runs twelve separately identified hook invocations and combines receipts; H forces native fail with always_run; I defers B99 until a later trigger; J uses ignores only; K grants a permanent/manual absence exemption. Factoring/configuring F remains F; combining D with separate intentional-rejection fixtures is D, not another scanner. Combining E/F with the fail hook duplicates enforcement. Disabling a stage, SKIP-suppressing B99, or staging a dummy compiled file to change aggregate accounting cannot supply a truthful clean-product pass.

Scores0–5 mean absent, deficient, partial, workable, strong, complete. Weights are unique to this applicability judgment: **Integrity32** preserves real filename rejection and every existing applicable check; **Truth24** binds exact hook identity, native state and independent applicability without false passes; **Usability21** lets a new contributor validate a clean tree without flags or suppression; **Closure13** fits the actual current callers and meaningful failure controls; **Maintenance7** limits new contracts/helpers; **Cost3** avoids redundant execution. Total is `sum(weight × score)/5`; scores are engineering judgments. Hard constraints: no lost existing applicable check, false Passed/N/A label, broad skip allowance, absent-root authority, dummy source, changed old receipts or automatic exception waiver. E/F require a genuine re-selection and new product validation; their scores do not release that scope.

| Option | Integrity32 | Truth24 | Usability21 | Closure13 | Maintenance7 | Cost3 | Total | Limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A Keep11/0 | 1 | 1 | 1 | 2 | 5 | 5 | 30.6 | Future legitimate guard cannot validate |
| B Exit0 only | 3 | 2 | 5 | 2 | 5 | 5 | 65.0 | Does not retain independent eleven-pass assurance |
| C Any skips | 1 | 2 | 5 | 1 | 5 | 5 | 49.6 | Ineligible: can conceal applicable check suppression |
| D Exact B99 N/A | 5 | 5 | 5 | 5 | 4 | 4 | **98.0** | New finite profile and controls must be verified |
| E Existing validator scanner | 5 | 5 | 4 | 4 | 2 | 3 | 87.8 | Changes selected product mechanism/authority coupling |
| F Dedicated scanner | 5 | 5 | 4 | 3 | 1 | 2 | 83.2 | New helper/runtime closure and broader write set |
| G Separate12 receipts | 4 | 5 | 3 | 4 | 3 | 2 | 78.0 | More process boundaries; departs from one aggregate |
| H Always-run native fail | 2 | 2 | 0 | 2 | 5 | 5 | 37.6 | Ineligible: rejects clean tree |
| I Defer | 3 | 5 | 2 | 2 | 5 | 5 | 66.8 | Honest fallback; selected foundation work remains missing |
| J Ignores only | 1 | 2 | 4 | 1 | 5 | 5 | 45.4 | Ineligible force-add bypass |
| K Absence/manual exemption | 1 | 1 | 4 | 1 | 5 | 5 | 40.6 | Ineligible permanent missing capability |

## Proposed controlled choice D98 and future local profile

Recommend D98. It retains selected B99 native behavior and unchanged hosted callers. Root must review this same-decision refinement before implementation. No formal ASD-STE100 dictionary certification is claimed.

1. Complete genuine PS235 acceptance. Bind the actual landed PS and TF main commits.
2. Release one PS writer for the four selected paths. Preserve the held A07 tree.
3. Keep the existing eleven hook IDs, bodies, runtime pins and suppression policy.
4. Add the selected fail hook and ignore lines. Add the bounded data contract and its useful mutations.
5. Prepare a new local validation packet for the final source. Preserve every old packet.
6. Run the ordinary configured all-files aggregate once. Preserve its exit and raw output.
7. Require exit0 and exactly twelve identified hook rows. Bind each row to the verified finite configuration, with unique hook names/IDs and no ambiguous, unknown, missing, duplicate or failed row.
8. Require Passed for all eleven existing hooks. Reject every skip among those hooks.
9. For B99 only, require native `(no files to check)Skipped` and an independently complete tracked-filename inventory with zero exact-pattern matches. Verify the same source/config/indices before and after. Record this as N/A, never Passed.
10. Reject SKIP or other suppression, changed selectors/stages/global filters, hidden files, read errors and incomplete inventory. Preserve primary failures and owned cleanup rules.
11. Keep actual matching-file rejection controls separate from the clean-tree aggregate. A B99 Passed row is not a valid native clean-tree outcome.
12. Verify the finite outcome profile with pure failures for skipped old hook, wrong B99 status/reason, nonempty/unknown inventory, suppression, failed native exit, duplicate/missing/unknown rows and source drift.
13. Complete normal current-input validation, review and source acceptance. Transfer only the useful accepted shared delta to TF through its normal lifecycle.

D98 yields eleven applicable passes plus one demonstrated N/A. It neither waives a failed hook nor broadens general skip acceptance. If future inputs make an old hook non-applicable, stop and reconcile that different case; this proposal does not authorize it.

## Minimal meaningful validation and remaining gates

The frozen native results each contain29 cases:18 expected rejections and11 expected no-match skips, including mixed case, source/near matches, ignored force-staging and three weakened selectors. Exact result SHAs are Windows `72b2d621c091f79805229d229642200e658be3e183e65e8c5a4b4f44b00d7c1f` and Linux `93bab638182fbb986cc87e897bd7dde22c6b9846f26123b38b3d2fb4e0a12e77`. They were verified and not rerun. They prove unchanged matching/native semantics; they do not prove the future assembled configuration, finite validator contract or twelve-row aggregate. Windows evidence has process-level Python socket refusal, not an OS network sandbox; no package-byte attestation is claimed.

Reuse that matrix, current bounded-reader controls and unchanged caller/runtime evidence. Fresh work should cover the new setup/ignore mutations, missing/oversized/partially staged and immutable-revision ignore data, actual assembled-hook force-added artifact plus valid near-match integration on both platforms, and the proposed finite profile controls. Do not repeat29 probes. One fresh final Linux all-files aggregate includes the full current SelfTest and all eleven applicable checks; do not run the entire SelfTest again solely to count hooks. Run focused Windows changed-contract/reader integration under its qualified owner. Reuse unchanged Node/classifier evidence only for exact unchanged regions; normal CI remains the final exact-input gate. Standard actual B/H modes, genuine metadata date, current ordinary audit, independent final quality and reviews remain root-owned; no new cold/full-setup timing investigation is justified here.

C98 allows this independent A07 outcome after its A00/A01 prerequisites and serialized current-source acceptance. B93.5 and the reconciled postlanding sequence distinguish source landing from S1/task/affected paired acceptance. After PS235 acceptance, root may implement B99 on PS without waiting for broad A06 completion or inventing a TF S1 permission gate. Only after the B99 PS source is accepted may its real delta be transferred to a genuine current TF PR. That PR can provide a legitimate dedicated-service input; root must observe actual dedicated selection, immutable guard and terminal service success. Closed TF68, source merge, generic setup success and no-op/duplicate reviews cannot supply it. A06/S1/affected paired acceptance and A16's accepted foundations remain gated; R5/B1 and later recovery integration remain separate selected work.

Current transfer counters stay A06/A03/A21/A07=2/4/6/6 of12. Evidence binds the exact sources, held index, callers, decisions and reused controls. No product/Git/native/planning/state/counter edit, install, test, process control, review polling or descendant occurred. Only this REPORT and evidence were written.
