<!-- markdownlint-disable MD013 -->
# Independent A21 shared-closure review

**Bounded approval: no actionable findings.** The two shared-file changes faithfully complete the selector portion of D-A21-01 and preserve the accepted PR226 caller regressions. This approves the reviewed source and focused evidence; full SelfTest, final aggregate, assembled caller/setup integration, peer convergence and native acceptance remain pending. I did not author this implementation, change product/index/planning/native state, rerun suites or spawn descendants.

## Exact reviewed inputs

Read STATUS, A21 task/result, canonical D-A21-01 and its actual-caller/selector dispositions, the complete shared diff and classifier, appended tests, accepted workflow block, manifest and evidence. Product HEAD is accepted `2a2d14a9969226b0c55d02d4f0c20f2451ed40b6`, tree/index `f5a83173a667d0d08225ec0cd391cedb4e659a77`; staged delta is empty. Exactly four unstaged files remain, including the previously approved frozen core pair. No worktree input was treated as accepted main.

| Input | Bytes | SHA256 | Git blob |
| --- | ---: | --- | --- |
| Classifier | 5786 | `99327c4c73610ba42057b6cfa94c5d2178d991b1741e194733ccfcbac8524fb7` | `c36ffc6bf2f845f2ff297e2045799331365634e0` |
| Classifier test | 21583 | `980257c408ee4dee430d7fb6e144ff7cb9d8c1dc90565071d99054479304d311` | `98a19faa7ae2da75e8a09d146508c34aa70b3a64` |
| Validator, unchanged reviewed core | 452848 | `1c222f5baf94c3758247a41b028b4ff4d1a40cf7bc961fd3d6a25f573229936c` | `0b5789dbfc42fc05dfc4b99cd492aa578adb208a` |
| SelfTest, unchanged reviewed core | 203280 | `a6e1faa5e039a72f978a6d7f2d4d6cd1f69a6dc749b69adb55283fe172c0d754` | `92db79a8d552e8c9adade97818f92851b365373d` |
| Manifest, unchanged | 388 | `dde7762b2588b583c47bb342f0a34c938c593b9391abbcecfca0d2ab5012d89c` | `2e714fcc8ba113da7265eeec50ffe8094aa3a2a0` |

Independently recomputed the four current raw lengths/SHA256/Git blob identities, verified RESULT SHA256 `1d98f3507066c8fb96ab2f7c96908ba2156a40f27d872bfe399326c9010d2b63`, evidence manifest SHA256 `9404bf2c3445575d2429c49125890473c3e6be50aadf9185395ccea12019b5da`, and all21 listed evidence lengths/hashes. Existing core approval and original loader-failure preservation remain applicable to the unchanged pair.

## Decision fidelity, closure and byte preservation

The classifier changes only its accepted selector table: requirements-dev.txt, bounded outer wrapper/test, locked Python launcher/local validation test, and Terraform state-recovery example test. Existing SelfTest and PowerShell example-test paths remain. Exact case-folded selectors conservatively cover aliases and future introduction of absent supported paths; suffix/nested lookalikes remain ordinary. No parallel classifier, arbitrary candidate-derived selector, schema change, executable evaluation or owner grant is introduced.

Actual immutable source supports these roles: PS2a workflow package invokes node lint-markdown.mjs; that wrapper imports NpmTools and selects lint-nested-markdown.js, while its test imports wrapper/child/helper. TF06ad hooks invoke Invoke-LockedPythonHook.ps1 with requirements-dev.txt closure, its candidate job lists Test-LocalValidation.test.mjs, and its artifact checker invokes Test-StateRecoveryExamples.mjs. TF's absent SelfTest remains a counterpart-installation obligation. Conservative selectors do not claim current PS setup files exist or activate enforcement before eligible A07 delivery.

Independently compared raw Git objects: the complete12599-byte accepted PR226 test file is an unchanged prefix (SHA256 `44080988676f921d472569bdde743edc25c2b66acd50565f9ff51f3edeb28acc`), and the complete3970-byte classifier suffix following the selector set is unchanged (SHA256 `23377eccd14f83ac50779c156e154a120f9d0ad07e411018b977f3a3648f8ca2`). Accepted-checkout B, available endpoints, policy=B, strict UTF-8/path checks, NUL diff/no-renames, bounds, native failures, ambient Git sanitization, workflow discovery, package-directory handling and no-authority output retain their existing behavior.

The manifest needs no edit. Independently read immutable TF06ad and verified exact raw equality after the single approved powershell.instructions.md → terraform.instructions.md filename substitution. Schema2, empty authorized grants, ordered five Tier2/four generated paths and all other bytes remain equal. This is a narrow language-data comparison, not a waiver of protected expectations or bootstrap authority.

## Meaningful focused evidence and its limits

Windows and Linux saved logs each run all12 tests with pass12/fail0/skipped0/cancelled0. The original nine tests run unchanged, including PR226's real script-completion caller controls. Three additions cover exact helper/uppercase classification, ordinary lookalikes, real independent candidate commits for initially absent helpers, removal via rename, inert poisoned candidate files, ambient Git redirect/config variables, and accepted workflow admission order.

The workflow test parses the actual accepted-policy block and keeps its direct checker-script calls. Declared Git acquisition and Node classification/workflow calls are substituted; the checker fixture records exact B/H arguments and throws on rejected data. Required phases distinguish wrapper maintenance (credentials/data/classify), ordinary input (adds ordinary/workflow), and rejected data (stops before classification). Maintenance's diagnostic expressly denies ordinary policy admission. This proves routing/order and error propagation; the substitute checker is not evidence of actual schema semantics, hosted acquisition, owner permission or an immutable producer. Existing unchanged core and separate workflow lifecycle evidence retain those responsibilities.

Inspected all six full mutant logs, not only their exit statuses: removing the wrapper selector produces ordinary instead of maintenance and wrongly enters ordinary/workflow phases; removing no-renames hides the selected wrapper's removal and produces the same incorrect classification; removing Git environment deletion causes the intended read to resolve missing-git-dir. Each mutant exits1 on both platforms for its targeted assertion/read, while unrelated controls remain useful. The driver mutates private copies and redirects only YAML/workflow fixture resolution. Positive candidates leave no execution marker and environment changes are restored.

Linux identities show exact five copied input hashes, Node24.18.1/PowerShell7.5.0, locked bootstrap and empty mounts. Windows uses Node24.18.1/PowerShell7.6.5. Author-reported container removal and syntax/diff checks are retained; I did not recreate the container or rerun these checks. Focused classifier/caller evidence is not a full validator/SelfTest or aggregate result.

## Remaining gates

Keep A21's complete validator/SelfTest/classifier/test/manifest ownership and A03 coordination. Integrate actual eligible A07 callers and complete setup/hook/staged activation atomically; the selectors alone do not supply that enforcement. Preserve A20 protected capacity/protocol/bootstrap authority and A03's unselected workflow/maintenance-owner choices. Do not treat maintenance classification as permission, accepted policy admission or merge authority.

Root must assemble and freeze current final inputs, complete full SelfTest through the one normal aggregate, affected final Windows/Linux/current B/H checks, actual commit and review/native CI/normal merge/landing gates. Future TF whole-implementation delivery, actual SelfTest installation and common raw algorithm/test equality remain required after PS acceptance. No new base selection, transfer, clock, setting or convergence completion is supported by this bounded review.
