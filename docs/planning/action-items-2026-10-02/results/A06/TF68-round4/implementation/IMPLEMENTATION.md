# TF68 S1 / R11 / R13 implementation

This packet implements the four selected decisions: S1 C95.9, corrected setup security C98.5, R11 B95, and R13 C97.9. The candidate is frozen over published TF head `3b12700eb636da67f5861637e5b139a18fa82140`. It is not an accepted landing or a hosted-CI result. Root owns final validation, publication, native reviews, and acceptance.

## Exact scope

Only these five product paths changed. The full raw 80-file catalog is `source-final.json` (SHA256 `045da9f92d5189a462a00f960f0e59d024fdc776f715cd427ace608fa6c7db5d`). The other 75 tracked files, all generated outputs, production fixed Git paths, dependency manifests and all 1,914 installed dependency files are unchanged.

| Path under `.github/workflows/` | SHA256 |
| --- | --- |
| `copilot-code-review.yml` (new) | `e998905e4883d456cb0c1f62e95e434c7aafb4bc1a51370dbd37ab3e17b6464a` |
| `Test-CiHelpers.test.mjs` | `c5da4af5bb2da1d642b7acf7d308ca5f848527b6366a5eee934364723493145d` |
| `Test-AgentInstructions.ps1` | `d6faafa20cd6af4057c59208a98e023f58f23167131ba9c650e7c9bd7cde2f9e` |
| `Test-AgentInstructions.SelfTest.ps1` | `40e7c631aa266cc8d0f2f64e9f91c55ec28c3636e870c75854237083cf81e681` |
| `agent-instructions.yml` | `4db16a194d432c241f464e501dfdd19e9a9aa1c01d193a1408bc7fe2163a05f8` |

Applicable repository/YAML instructions and the PowerShell source style guide were read. Changed PowerShell script/function NOTES versions use the genuine UTC edit date, 2026-10-06. The existing guide-impact assessment remains valid; no protected guide, generated instruction, README, or runtime setting needed an edit.

## Resulting behavior

The dedicated review setup retains each actual acquisition, no-credential, pinned runtime, locked dependency, hook installation, and final immutable-input step from coding setup. It omits only the complete repository validation step. Its comments and names describe preparation; they do not claim acceptance. The old coding setup, ordinary CI, and mandatory pre-commit validation remain intact.

The setup reader now treats the new review YAML as one explicit optional input with a 65,536-byte bound. Every old input remains required by default. An empty successful literal Git metadata query can represent historical absence only when the caller explicitly permits it. Nonzero native status, malformed/multiple/wrong-path/nonregular entries, read failures, access errors, indexed missing local files, missing staged entries, untracked residual files, invalid UTF-8, and partial staging still fail. The new path is governed and receives the same present-input no-action/no-credential checks. Existing staged, local, and immutable revision reader mechanisms are reused.

Persistent setup regressions exercise both workflows, current and revision content, staged equality, bounded reads, genuine historical absence, strict default admission, residual/directory/missing files, invalid UTF-8 and nonregular index/tree entries. Historical absence does not suppress the private present-review security mutations.

The generator proof fixture discovers one absolute Git application through the required PowerShell 7 process. Discovery and native command failures are mandatory failures; no missing-runtime skip or system-Git fallback was added. Only private fixture substitutions use the selected executable. Persistent tests retain native/shape/path rejection controls and run the actual retained review setup bodies alongside coding setup bodies.

The ordinary candidate behavior job budget is 59 minutes and its existing behavior-test step budget is 45 minutes. Raw comparison proves those are the only two changes in `agent-instructions.yml`. Acquisition, permissions, event authority, publication conditions, and every test command remain byte-identical.

## Focused verification

Exact commands, source and driver hashes, native exits, log hashes, and retained failures are in `evidence.json`. All checks run in disposable fixtures. Shared product/index/refs/dependencies stayed frozen.

- Windows PowerShell 7.6.5: both full changed PowerShell files parsed and passed PSScriptAnalyzer 1.24.0 with zero warnings/errors. The actual extracted setup regression function passed with its original function bytes and native file-bound `PSScriptRoot`. Four selected actual CI helper tests passed with zero fail/cancel/skip/todo, including the three proof bodies and their success/child-failure controls.
- Windows actual discovery used the installed spaced `cmd/git.exe` application rather than the previous fixed `bin/git.exe`. Actual missing PowerShell and actual missing Git were rejected. Ten bounded metadata/native/shape/default controls and three missing/access/I/O controls passed. Actual required coding-workflow deletion and both private omission mutants passed their rejection/discrimination oracles.
- The qualified offline Linux image retained Node 24.18.1, npm 11.16.0, PowerShell 7.6.3 and Python 3.12.3. All eight focused command groups passed. The affected CI helper selection reported 150 passed, zero failed/cancelled/skipped/todo. YAML parse/style/actionlint, the actual setup regression, metadata/error controls, required coding-workflow deletion, real worktree/index symbolic links, security/reader omission mutants, Git selection controls and affected Copilot body tests are recorded separately. The only dependency adaptation is the already qualified Linux executable mode on the unchanged Husky entry point.
- The actual Linux generator proof succeeded through a nonstandard Git application in a path with spaces, with seven selected-application receipts. Making that selected application exit 73 failed the proof even though healthy system Git remained available. A private original fixed-selector mutant passed its normal proof but produced no selected-application receipt, so the new discriminator rejected it. Product bytes were restored before every source guard.
- A private security-loop omission mutant accepted an injected action in the review YAML and was killed by the actual action-refusal oracle. A private catalog omission mutant dropped the present review input and was killed by the actual present-file oracle. Original functions were restored explicitly in `finally`.

The host/source guards compare all 80 source files, all 1,914 dependency files, HEAD, index bytes, and refs against the captured input. Native Git changes made by the tests are confined to disposable fixture repositories.

## Retained unsuccessful scratch attempts

Two early Windows AST drivers lost file-bound `PSScriptRoot`; both failed before the intended setup controls. Hosting unchanged extracted functions in a private workflow-directory file corrected the driver. The logs remain `setup-reader-windows-initial-driver.log` and `setup-reader-windows-driver-scope.log`.

The first extra-reader driver expected a later metadata error when the actual reader correctly refused a missing required worktree file earlier. The next private mutant driver did not restore a function changed through the function provider. Those failures remain in `extra-reader-windows-initial-expectation.log` and `extra-reader-windows-mutant-scope.log`; the final private driver accepts the actual refusal and restores exact functions in `finally`.

Linux attempt 1 passed both YAML checks, then failed because `actionlint` was outside the scratch driver's PATH. The qualified executable was found in the existing image; no tool was installed. `linux-input/` and `linux-output/` remain intact. Attempt 2 uses distinct directories and container name, a payload ownership label, bounded exact-ID/image/label cleanup, and a final host guard on success or failure. No product changes were made for any scratch correction.

## Remaining gates and limits

The focused packet does not establish actual hosted Copilot scheduling, service-selected workflow behavior, network acquisition, or completion time. The increased ordinary budget and dedicated review setup still require new exact-head hosted evidence. No cancelled/failing current CI is waived.

Windows symbolic links were not created or enabled; actual native Linux symlink controls supply that focused evidence. Windows 5.1 was not run under restricted local policy. Unchanged clock/author/capacity and generator platform matrices were not repeated.

Root must complete the required final all-files pre-commit pass and its prepared final seven-suite validation, then record the actual increased complete test count with zero fail/cancel/skip. No final count of 567 is assumed. Root owns current audit, staging, commit, whole-PR endpoints, review loop and acceptance. Any PS carryback must bind the actual accepted TF landing/current PS source and increment applicable transfer accounting before destination implementation. This packet neither starts that transfer nor authorizes merge.
