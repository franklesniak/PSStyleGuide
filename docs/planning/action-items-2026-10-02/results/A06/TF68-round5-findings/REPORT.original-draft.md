<!-- markdownlint-disable MD013 -->
# TF68 round5 review findings: read-only validation

Both allegations are refuted on current published H `5ec4bdc06431de05e93067b0e52f0dfbb1631392` (tree `441d84c13f46d94c6a032e828615a10fae8d4c7e`). Recommend no product change for R14 or R15. This does not accept or merge TF68. Copilot review5425350909 is observed Lite; its warning and the separately pending dynamic setup remain distinct from these code findings. Root owns current CI status and the absolute no-failing-CI merge rule.

## Input, prior decisions and scope

The complete saved observation supplies comments4192817999 and4192818069. Immutable replacement-disabled/no-optional-locks Git reads bind all three relevant TF files and their PS981 counterparts in evidence.json. Current tracked bytes equal H, and the worktree is clean before and after this investigation. No tests, installs, product edits, index/ref/config changes or native actions were performed.

The prior A06 PR234 round1/round2 records and TF round3 records were searched before disposition. No identical previous adjudication for these two claims was found. R8's exact output-metadata decision concerns **ConvertFrom-NulPathRecordStream**, which emits byte-array record objects, not **Assert-AllowedPathSet**, which emits strings. Reuse the existing verified caller/contract evidence without conflating these functions. R1's clock repair is also unrelated to a separate native process exit. The existing process and validation decisions are retained. The complete options below make the product-review disposition explicit; they do not invent a demonstrated failure.

## R14 — exception fixture allegedly bypasses controlled pass failure

Comment [4192817999](https://github.com/franklesniak/TerraformStyleGuide/pull/68#discussion_r4192817999) overlooks a process boundary. The test writes a fixture harness that throws. Each actual build proof body invokes that harness using the current PowerShell executable with `-File`, in a new native process. The outer proof then captures `$LASTEXITCODE` immediately and throws its fixed pass1/pass2 diagnostic for a nonzero result. The proof bodies disable `$PSNativeCommandUseErrorActionPreference` where supported. The fixture error does not terminate the parent script before its status check. Native stderr can include both the fixture message and the parent message; the assertion requires the latter, not its exclusive presence.

The actual test exercises success/pass1/pass2/exception for all three current proof bodies. It checks native status, invocation count, no revision publication on every failed mode, and the controlled diagnostic. Current-byte Windows focus passed4/4 and Linux affected suite150/150. The final full suite passed600/600 with0failed/cancelled/skipped/todo and includes this named test. The three relevant raw files match the frozen tested catalog exactly. These fixtures use the current host even for the Windows5.1 proof body: they are not a local Windows5.1 execution claim. Current hosted156-assertion twice-per-platform proof is complementary real-host generator evidence; it is not falsely attributed as this fixture test.

Primary references: [PowerShell -File](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_pwsh?view=powershell-7.5) explains the new session and nonzero exit for a terminating script error; [native error preference](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-7.5) explains the opt-in native-exit error conversion. Actual matching executable behavior is established by existing successful Windows/Linux tests, not documentation alone.

Stakeholders: maintainers and reviewers need a correct process model; CI/release and security owners need failures to prevent revision publication; contributors need a stable error; QA needs an independent terminating-error mode. End-user guide content, localization, dependency policy and billing are unchanged. No relevant owner benefits from weakening a passing refusal oracle.

Options A–E below cover retention, added diagnostic checking, narrower special-case assertion, removal and production transport redesign. A retry/deferral cannot alter this deterministic source finding. Changing to an in-process fixture would test a different production boundary; it collapses into E. There is no runtime waiver to grant.

Rubric: runtime correctness35 measures fidelity to the actual native process boundary; regression sensitivity30 measures detection of swallowed failures and premature publication; diagnostic usability20 favors stable actionable output rather than host-formatted text; cross-platform evidence10 measures actual supported-host evidence; maintenance cost5 measures extra coupled assumptions. Scores0–10 mean unusable through fully supported. Hard constraints: keep all mandatory refusal modes, preserve publication gating, and do not claim unexecuted platform coverage.

| Option | Runtime correctness | Regression sensitivity | Diagnostic usability | Cross-platform evidence | Maintenance cost | Total /100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A Retain current assertion and reply with actual evidence | 10 | 10 | 10 | 9 | 10 | 99.0 |
| B Also require fixture exception text | 9 | 9 | 7 | 7 | 7 | 83.0 |
| C Special-case exception; remove controlled-message assertion | 7 | 5 | 6 | 8 | 7 | 63.0 |
| D Remove exception mode | 6 | 2 | 5 | 8 | 9 | 49.5 |
| E Change production proof error transport | 5 | 5 | 5 | 4 | 2 | 47.5 |

A wins at99.0. B adds an assertion on host error formatting without a missing failure oracle. C and D reduce existing coverage. E changes correct production behavior without a demonstrated need. Scores are comparative judgments, not test measurements.

Selected procedure: Keep the fixture and all four modes. Keep the controlled-message assertion. Explain the native child boundary in the review reply. Link the current-byte passing test evidence. Do not rerun a full suite for this refuted allegation. Reopen the finding only if an exact supported-host counterexample defeats the current oracle.

## R15 — path stream allegedly breaks Count

Comment [4192818069](https://github.com/franklesniak/TerraformStyleGuide/pull/68#discussion_r4192818069) assumes a caller contract that the actual source does not have. Assert-AllowedPathSet documents `System.String` output, one validated path per object, and no output for an empty set. It validates every path before the final sorted output. All current production calls are at lines790–792: working output goes to `$null`; staged and untracked calls each use `@(Assert-AllowedPathSet ...)`. The only relevant Count checks therefore operate on caller-created arrays. Both latter allowlists are empty and reject any path before output; their actual successful shape is an empty collected array. The examples likewise show caller-side collection. No scalar-string Count access occurs.

The suggested `return @(...)` creates a collection internally but does not force that collection to remain one object at the function boundary. [Microsoft about_Return](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_return?view=powershell-7.5) documents automatic enumeration and the separate unary-comma/NoEnumerate mechanisms. The latter mechanisms would change this string-stream contract, not repair it. Do not depend on incidental string.Count behavior to justify safety; the actual collection sites establish it.

The full600 suite contains actual artifact-wrapper clean, stale, staged/untracked/verifier/recovery refusal coverage. That supports the unchanged wrapper behavior. No claim is made that this log alone is a dedicated exhaustive arbitrary-call output-shape probe. Exact callers and the documented PowerShell enumeration rule settle the allegation, so no redundant scratch test was needed.

Stakeholders: generator/artifact users need the exact allowlist to remain enforced; maintainers, new contributors and reviewers need output prose and examples to match caller behavior; Windows/Linux engineers need PowerShell stream compatibility; incident operators need dirty-checkout refusal preserved. Public APIs, guide authors, dependencies and settings are unaffected by this private helper disposition.

Options A–E include retention, the suggested inner collection, actual non-enumerated array transport, output removal and extra explanatory/regression material. Moving collection to callers is already implemented. Deferral or exception adds no solution. A common helper abstraction would add another contract for three adjacent correct calls without changing the issue.

Rubric: caller/stream correctness35 measures consistency with the documented per-string pipeline and actual collection sites; refusal/security preservation25 measures exact allowlist and dirty-checkout rejection; clarity20 measures whether a reader can infer the real API; evidence/compatibility15 measures supported PowerShell semantics and existing executed wrapper controls; cost5 measures unnecessary maintenance. Scores0–10 mean unsupported through fully supported. Hard constraints: do not weaken allowlists or introduce a nested array whose Count masquerades as path count; do not change a private contract without adapting and verifying its real consumers.

| Option | Caller and stream correctness | Refusal/security preservation | Reader/contributor clarity | Evidence and compatibility | Maintenance cost | Total /100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A Retain documented stream and existing caller collection | 10 | 10 | 9 | 10 | 10 | 98.0 |
| B Add redundant inner @() to return | 10 | 10 | 6 | 9 | 7 | 89.0 |
| C Return one array object with unary comma/NoEnumerate | 4 | 6 | 4 | 3 | 3 | 43.0 |
| D Remove return output | 4 | 8 | 4 | 3 | 5 | 49.0 |
| E Add comment or redundant shape-only regression | 10 | 10 | 8 | 8 | 5 | 90.5 |

A wins at98.0. B is runtime-redundant and encourages the false forced-array explanation. C changes the output object contract and can make an empty array count as one collected object. D removes the documented output. E can add prose but addresses no missing reader example or demonstrated regression. No new material implementation is selected.

Selected procedure: Keep the string-stream return. Keep both caller-side array expressions. Explain the exact Count consumers in the review reply. Keep the existing byte-array metadata decision unchanged. Reopen only for a new actual caller that relies on a different contract.

## Evidence and remaining authority

The JSON binds raw commit/blob/mode/SHA256 identities, full original comments, prior decision inputs, exact previously executed commands/native exits and retained logs. It preserves full historical evidence rather than claiming a new run. The root's saved current platform proof is bound separately. No peer edit or transfer increment follows either no-change selection. Root must review these dispositions before posting replies/resolving comments. The pending setup and ordinary workflow state must be judged separately; this packet does not authorize merge, retry, service acceptance or a new review. No new permission is required for these read-only conclusions.
