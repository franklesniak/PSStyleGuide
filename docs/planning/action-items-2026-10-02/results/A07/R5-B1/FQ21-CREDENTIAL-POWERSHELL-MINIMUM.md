<!-- markdownlint-disable MD013 -->
# FQ21: Credential helper PowerShell minimum

- **Status:** Accepted
- **Owner:** A07 coordinator
- **Last Updated:** 2026-10-09
- **Scope:** PR239 review comment 4225004581; declared API minimum and its documentation. No permission, credential or platform-control redesign.
- **Related:** [Owner decision process](../../../DECISION-PROCESS.md), [review finding](https://github.com/franklesniak/PSStyleGuide/pull/239#discussion_r4225004581)

## Context and validation

At commit `4eabb04bc8fa2f12c327ea6be8f7450ab0aa3032`, Test-CheckoutCredentials.ps1 declares PowerShell 7.0. Its New-PrivateDirectory function contains UnixFileMode, File.GetUnixFileMode and the mode-taking Directory.CreateDirectory overload. Microsoft identifies these as .NET 7 APIs; PowerShell 7.3 uses .NET 7. The initializer and lint helper already declare 7.3.

This is a material declaration and maintenance improvement, not a reproduced Linux checkout failure. The only production call to New-PrivateDirectory in this credential script is inside the Windows branch, after an exact 7.6.5 check. Its Linux permission branch is currently dormant. No PowerShell 7.0-7.2 runtime was executed in this investigation. Do not claim those callers crashed, or that raising the floor repairs the independent FQ20 service-schema failure.

Maintainers and security reviewers need the declared minimum to cover the retained helper implementation. New contributors and documentation readers need a single understandable floor. Linux users bear the compatibility cost of refusing 7.0-7.2; the existing complete runtime setup already requires 7.3. Windows operators retain exact 7.6.5 admission. QA needs observed tests distinguished from API documentation. DevOps, business and project stakeholders benefit from avoiding a separate legacy permission implementation and associated support. No settings, credentials, cloud costs or user-data changes are involved.

## Alternatives considered

1. Retain 7.0 and explain the dormant branch. This preserves potential standalone Linux compatibility but keeps the retained helper's API floor different from the script declaration.
2. Require 7.3 and document it. Retain the shared helper and exact Windows 7.6.5 guard.
3. Remove the dormant Linux helper branch and retain 7.0. This narrows the helper and creates a different implementation from its two siblings; retaining old-version support would still need actual qualification.
4. Implement older-runtime permission handling using an external command or native interop. This adds a security-sensitive implementation with no required active caller.
5. Add capability checks, split definitions or platform-specific minimum requirements. These preserve mixed support but add conditions and still need old-runtime qualification.
6. Require exact 7.6.5 on both platforms. This exceeds the API floor and unnecessarily narrows Linux runtime admission.

Documentation accompanies each viable repair and does not create an additional option. Factoring a shared helper still requires one of these runtime policies and adds loader/trust-boundary work. Deferral or a targeted exception retains option 1's discrepancy. Removing the credential check violates the task's security contract and is inadmissible.

## Rubric

Score each criterion from 1 (poor) through 3 (adequate with limitations) to 5 (strong). Total is the sum of weight multiplied by score divided by five. These are comparative judgments, not measured probabilities.

| Criterion | Weight | What a strong score means |
| --- | ---: | --- |
| Declaration/API correctness | 30 | The declared script minimum supports all retained API definitions without a hidden platform caveat. |
| Security preservation | 25 | Existing credential isolation, private permissions, native status and refusal behavior remain intact without a new permission mechanism. |
| Contributor usability | 20 | Runtime requirements are clear, consistent with supported setup, and no more restrictive than needed. |
| Verification confidence | 15 | The change has inspectable primary support and meaningful existing validation; unexecuted old-runtime compatibility is not asserted. |
| Future maintenance | 7 | Sibling helpers and platform requirements remain understandable without separate legacy branches. |
| Implementation cost | 3 | The change introduces little unrelated churn and few new failure modes. |

Hard constraints: preserve credential, ACL, path, platform and native-exit controls; retain exact Windows 7.6.5; do not label a version number alone as runner qualification; do not claim a runtime failure that was not observed.

## Scores

| Option | Correctness | Security | Usability | Verification | Maintenance | Cost | Total /100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Keep and explain | 3 | 4 | 2 | 2 | 3 | 5 | 59.2 |
| 2. Require 7.3 | 5 | 5 | 4 | 4 | 5 | 5 | 93.0 |
| 3. Remove Linux branch | 4 | 4 | 4 | 3 | 3 | 4 | 75.6 |
| 4. Older-runtime handling | 3 | 2 | 4 | 2 | 1 | 1 | 52.0 |
| 5. Conditional requirements | 4 | 4 | 3 | 3 | 2 | 3 | 69.6 |
| 6. Exact 7.6.5 everywhere | 5 | 5 | 2 | 4 | 4 | 4 | 83.0 |

Option 2 wins because it makes the retained API contract explicit without changing security code. Its usability score reflects the deliberate refusal of older standalone Linux runtimes. Its verification score retains the limit that 7.3 itself has not been executed here. Option 3 avoids that compatibility restriction but changes security helper code and preserves an unqualified older-runtime claim. Option 6 restricts Linux beyond this finding's need.

## Decision and controlled implementation instructions

Date: 2026-10-08. Select option 2. The options, rubric, scores and selection were displayed before the product edit.

1. Set `#Requires -Version 7.3` in Test-CheckoutCredentials.ps1.
2. State the minimum in the script description and helper table.
3. Keep the Windows version check at exactly 7.6.5.
4. Keep all credential and permission checks.
5. Parse the changed script with the qualified PowerShell runtime.
6. Run the configured PSScriptAnalyzer checks.
7. Run the existing Windows B1 behavior tests.
8. Record the actual runtime and results.
9. Keep the PR open until its required checks and reviews pass.

These instructions use short direct actions and consistent technical names. No formal ASD-STE100 dictionary certification is claimed. Raising an API minimum does not qualify every runner with that version. Hosted Linux/current-input gates and final quality remain required before delivery. Unchanged function bodies retain their prior conformance evidence. This decision changes no guide or instruction text; no new guide policy is proposed for this isolated declaration mismatch.

## Consequences and verification

Positive: the retained helper's APIs, sibling declarations and documented minimum agree. No permission algorithm or caller changes. Negative: PowerShell 7.0-7.2 can no longer invoke this script, including its standalone Linux path. That cost is accepted because the supported complete setup already has a 7.3 floor; this is not an assertion that the old standalone path failed.

Before this repair, the exact candidate passed all 11 hooks and the Windows aggregate (344 passed, zero failed, 382 Linux-only skips), including 14 Windows B1 cases. Those results belong to the old declaration. The implementation results below describe the later repair.

## References

- [Microsoft: .NET 7 Unix file mode APIs](https://devblogs.microsoft.com/dotnet/announcing-dotnet-7-preview-7/).
- [Microsoft: PowerShell 7.3 uses .NET 7](https://learn.microsoft.com/en-us/powershell/scripting/whats-new/what-s-new-in-powershell-73?view=powershell-7.6).
- [Reviewed credential helper](https://github.com/franklesniak/PSStyleGuide/blob/4eabb04bc8fa2f12c327ea6be8f7450ab0aa3032/.github/workflows/Test-CheckoutCredentials.ps1).

Implementation and validation 2026-10-08T23:20:34.961278+00:00: Applied locally: only the Requires directive and description changed; all bytes from CmdletBinding onward equal the reviewed head. Qualified Windows PowerShell 7.6.5 and PSScriptAnalyzer 1.24.0 reported zero parser errors and zero warning/error diagnostics. The existing targeted Node 24.18.1 suite passed 15/15: 14 Windows B1 cases plus the F4 documentation ownership case, zero skips/failures/cancellations. Source stayed unchanged and private scratch was empty. Native process 27397 and static 52940 ended 0. No actual 7.3 or Linux execution is claimed. Independent review and final integration gates remain. [Targeted result](current-main-validation/fq21-targeted-windows.json), [static result](current-main-validation/fq21-static.json).

Final integration, 2026-10-09: the repair is published in [commit c1ef946](https://github.com/franklesniak/PSStyleGuide/commit/c1ef946fe4585836f27a0a4480bd986899d7c316). Independent final local review passed. All eleven configured hooks passed on the final staged files, and the normal Git commit hooks passed. The outer controller retained a failure for two 69-byte temporary files compatible with PowerShell policy probes. A separate exact-run verification accepted the genuine hook results and preserved those files and the original controller failure. Current public reviews, passing CI and landed acceptance remain required.
