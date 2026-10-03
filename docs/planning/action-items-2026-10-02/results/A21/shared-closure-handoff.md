<!-- markdownlint-disable MD013 -->
# A21 shared classifier closure

State: focused-ready continuation of the selected complete PS implementation. The three-path writer is released. Only the classifier and its test changed in this slice; the owned manifest required no edit. The frozen validator/SelfTest core remains byte-identical. This is progress within A21, not complete paired convergence or source acceptance of these new bytes.

Worktree: `C:/Users/flesniak/.codex/worktrees/ps-shared-governance/PSStyleGuide`, branch `codex/instruction-validator-convergence`. HEAD is accepted PS `2a2d14a9969226b0c55d02d4f0c20f2451ed40b6`, index tree `f5a83173a667d0d08225ec0cd391cedb4e659a77`; no staging/ref/commit/native/planning/GitHub operation occurred. Root supplied PR226's terminal source acceptance before release. Current scope remains transfers0/12 with no A21 PR clock.

## Decision and exact behavior

This mechanically completes the independent selector portion of [D-A21-01](selection-20261003/DECISION.md), including its “Concrete selector closure gap,” actual-caller table and retained classifier/loader matrix. It introduces no new material design finding or base choice. [D-A21-02](core-loader-decision.md)'s independently reviewed core is frozen and unchanged. No region-selected engine or second classifier was introduced.

Add six exact maintenance selectors: `requirements-dev.txt`, `lint-markdown.mjs`, `lint-markdown.test.mjs`, `Invoke-LockedPythonHook.ps1`, `Test-LocalValidation.test.mjs`, and `Test-StateRecoveryExamples.mjs` (the last five beneath `.github/workflows/`). Retain actual SelfTest and PS `Test-BlankLineExamples.ps1` selectors. One common table now covers both language example-test surfaces and the supported wrapper/runtime/hook test closure. Case aliases receive the same conservative classification; ordinary lookalikes do not.

The immutable PS2a package actually runs `node lint-markdown.mjs`; that wrapper loads the bounded NpmTools helper and outer lint child, and its test imports the wrapper. Native TF06ad hooks run the locked Python launcher and its requirements lock, candidate CI invokes Test-LocalValidation.test.mjs, and Test-StyleGuideArtifacts.ps1 invokes Test-StateRecoveryExamples.mjs at line490. These are actual caller evidence. The current TF SelfTest absence remains an eventual counterpart-installation obligation; listing its future common path does not assert it is already installed. A07's absent current PS setup files are classified conservatively if introduced, with no setup enforcement or hook activation claimed here.

Optional historical supply-diagnostic scripts/profile remain outside this routine validator/CI loader closure. Their native documentation expressly describes manual diagnostics, and no routine workflow/package/hook loader was found for them. This slice does not resurrect retired supply acceptance requirements.

Every byte after the selector set in the classifier remains unchanged: exact accepted checkout B, available commit endpoints, policy=B, full NUL diff with rename suppression, strict UTF-8/path validation, 10000-path/1MiB/30-second bounds, native failure handling, Git environment sanitization, package directories, platform-discovered workflows and no-authority output. The entire preexisting PR226 test file is an unchanged raw-byte prefix of the final test file, including all nine tests and the real PowerShell caller's native37 success, throw, explicit exit9 and later Node7 scenarios. Three new meaningful tests are appended.

## Manifest disposition

No manifest change is needed. `manifest-proof.json` verifies exact byte equality with immutable TF06ad after only substituting the already-approved generated filename `powershell.instructions.md` → `terraform.instructions.md`. Schema2, empty authorized exemptions, five Tier2 paths, four generated paths and their exact order remain unchanged. No normalization, grant or schema widening is hidden in this comparison.

## Final identities

| File | Bytes | Git blob | SHA256 |
| --- | ---: | --- | --- |
| `.github/document-metadata-classification.json` (unchanged) | 388 | `2e714fcc8ba113da7265eeec50ffe8094aa3a2a0` | `dde7762b2588b583c47bb342f0a34c938c593b9391abbcecfca0d2ab5012d89c` |
| Classifier | 5786 | `c36ffc6bf2f845f2ff297e2045799331365634e0` | `99327c4c73610ba42057b6cfa94c5d2178d991b1741e194733ccfcbac8524fb7` |
| Classifier test | 21583 | `98a19faa7ae2da75e8a09d146508c34aa70b3a64` | `980257c408ee4dee430d7fb6e144ff7cb9d8c1dc90565071d99054479304d311` |
| Frozen validator | 452848 | `0b5789dbfc42fc05dfc4b99cd492aa578adb208a` | `1c222f5baf94c3758247a41b028b4ff4d1a40cf7bc961fd3d6a25f573229936c` |
| Frozen SelfTest | 203280 | `92db79a8d552e8c9adade97818f92851b365373d` | `a6e1faa5e039a72f978a6d7f2d4d6cd1f69a6dc749b69adb55283fe172c0d754` |

Exact preimages are in `preimages.json`; final inputs and byte-preservation proofs are in `final-inputs.json` and `preservation-proof.json`. All five copied Linux inputs match these raw identities. No TF product file was written.

## Focused verification

`node --test .github/workflows/Classify-InstructionMaintenance.test.mjs` passes all12 tests with zero failed/skipped/cancelled on Windows7.6.5 and Linux7.5.0, both with Node24.18.1. Both JavaScript syntax checks and `git diff --check` pass. Logs: `windows.log`, `linux/linux.log`. Original nine tests are retained and run, rather than substituted by an isolated new-test-only claim.

New coverage proves each shared helper and uppercase alias independently requires maintenance while suffix/nested lookalikes remain ordinary. Real private Git candidates cover wrapper/test, requirements, launcher/local test, SelfTest, both language example tests and a poisoned candidate classifier; candidate files are never executed. External Git directory/worktree/index/object/config injection cannot redirect the read. A selector file renamed outside the table still classifies as maintenance because its removal remains visible.

The actual accepted-policy workflow block is exercised with declared acquisition/Node substitutions and a real script fixture at the validator path. It proves data-only admission occurs before classification, wrapper-only maintenance avoids ordinary validation, ordinary documents reach the ordinary checker/workflow phase, and rejected candidate data prevents classification. It verifies exact B/H arguments and no-authority maintenance diagnostics. This is a caller-order test, not a claim that the substitute validator proves schema semantics or that acquisition was hosted; existing unchanged core evidence retains those responsibilities.

Three scratch mutations fail for their intended assertions on both platforms: remove the wrapper selector, remove `--no-renames` so a deletion can be hidden by rename detection, and stop deleting ambient Git redirect/config variables. `mutations.mjs` changes only scratch copies and redirects YAML/workflow fixture resolution to the actual source. All expected nonzero results are recorded in `windows-mutations/results.json` and `linux/mutations/results.json`, with full logs. No product mutation is left behind.

Linux ran in cached image `sha256:2540dd9d184baa1f2bae22b0572200342a54d1d0bd7ab0dbdb326c36cee5bcdb`, using copied tracked inputs and the actual locked bootstrap. There were no host mounts; `linux/mounts.json` records `[]`. The owned container `psstyleguide-a21-shared-closure-20261003` was removed normally. No full SelfTest or aggregate ran.

## Remaining work and authority

Root owns final independent review, accepted A07 caller integration, remaining setup/hook/staged activation, final aggregate, actual commit/BH, current-input reviews, native CI and normal merge/landing. The A07 full outcome is not a blanket dependency on this completed independent slice. TF whole-implementation transfer and common algorithm/test equality remain future A21 work. A20 capacity/protocol/protected expectations and A03 unselected owner-label/workflow authority remain unchanged. No classifier result is owner permission, policy admission or merge authority.
