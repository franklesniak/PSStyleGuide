<!-- markdownlint-disable MD013 -->
# WQ1: Windows host placement and remaining qualification

Selected P94 on2026-10-05. The coordinator displayed the options, fresh rubric, scores and selected steps before execution. R5 95/100, B1 94/100 and A03 C98 remain selected. This decision supplies a suitable local location for subsequent independent acquisition tests. It does not accept product acquisition or either recovery gate.

## Validated finding and affected users

The old Temp namespace has an unresolved principal with applicable Modify and DELETE_CHILD authority. Bounded account translation, local account queries and current-token inspection did not establish its identity or trust. AppData/Local also has an unresolved capability with applicable FullControl. Moving up only one directory cannot settle these facts. An unresolved identity is neither proof of hostile access nor permission to assume trust.

The existing direct user-profile chain and twenty unique fixed-tool/ancestor paths have ordinary types and no unexpected applicable mutation authority in the recorded snapshot. Their expected writers are the current owner, SYSTEM, Administrators and the OS servicing identity where applicable. Inherit-only rights on an ancestor are distinct from applicable replacement rights on the protected child. This analysis uses [Microsoft's file access rights](https://learn.microsoft.com/en-us/windows/win32/fileio/file-access-rights-constants) and [file security rules](https://learn.microsoft.com/en-us/windows/win32/fileio/file-security-and-access-rights).

Maintainers and new contributors need a concrete admissible place to run the selected tests. DevOps and platform engineers need actual filesystem and executable evidence. Security engineers need a full ancestor check without a trust waiver. Security owners need existing authority boundaries preserved. QA needs real PowerShell7 execution and separate later5.1 evidence. Documentation and user-experience owners need clear remaining steps. Business and project owners need progress without unnecessary downloads or repeated qualification. No cloud resource, customer data, localization or accessibility interface changes arise from this host-only choice.

## Options

- T: retain Temp after identifying every applicable unknown authority. The currently missing identity evidence remains a prerequisite.
- P: create a fresh protected runner root directly under the user profile. Reuse the already reviewed tools and archive evidence.
- H: qualify an actual supported hosted Windows runner. Treat its tools, storage and policy as unverified until observed.
- L: move only to AppData/Local. This retains the unresolved capability authority.
- M: change parent ACLs or execution policy, or waive unknown authority. This exceeds the selected scope.
- D: wait for the later A16 harness before doing independent acquisition work. This introduces an unnecessary dependency.

P with H as a fallback retains the same acquisition design. T plus identity research remains T. Changing only the scratch name within the same unresolved ancestry is L or T. Replacing the acquisition architecture is unnecessary for this host-placement finding.

## Rubric and hard constraints

Use0–5 per criterion: absent, serious gap, substantial gap, workable, strong, fully covered. Total=sum(weight*score)/5. These are decision judgments, not measured test results.

- N30: strength of namespace evidence, including applicable ancestor replacement/delete/ACL authority and reparse status. This is the security and technical-correctness priority.
- A25: preservation of approved contracts, current authority and truthful acceptance boundaries. No high score can authorize a bypass.
- B20: verified current bootstrap readiness and reuse of fixed executable/archive evidence. A future environment label earns no observed readiness credit.
- V15: ability to obtain the missing real execution evidence promptly and reproducibly, with distinct platform results. This includes QA and contributor usability.
- E10: implementation and operational cost, changes to existing state and future maintenance. Convenience has the lowest weight.

Hard constraints: preserve R5/B1/C98; keep reviewed tool identities; do not modify existing ACLs, accounts or policy; reject occupied/reparse/checkout destinations; do not infer a missing script-cell pass; retain the trusted-owner/administrator threat-model limit. Scores cannot waive these constraints.

| Option | N30 | A25 | B20 | V15 | E10 | Total | Key limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| T | 1 | 5 | 5 | 2 | 5 | 67 | Unknown authority unresolved |
| P | 5 | 5 | 5 | 4 | 3 | **94** | Actual creation and execution proof required |
| H | 3 | 5 | 3 | 3 | 4 | 72 | Actual hosted image not qualified |
| L | 1 | 5 | 5 | 2 | 4 | 65 | Capability authority unresolved |
| M | 2 | 0 | 5 | 3 | 1 | 43 | Ineligible authority change |
| D | 2 | 2 | 5 | 0 | 5 | 52 | Ineligible dependency coupling |

## Selected steps

1. Use a new direct child of the user-profile directory. Get the profile directory from the operating system.
2. Check the full parent chain and the fixed tool files. Stop if a path, descriptor or binary hash has changed.
3. Check that the new path is absent. Supply the protected owner, SYSTEM and Administrators descriptor when you create the directory. Do not change the parent.
4. Check the new directory and its ordinary child files. Prove owner writes, inherited permissions and communication-file handling.
5. Run the reviewed PowerShell7 executable with a real script file in that directory. Use no execution-policy override.
6. Preserve the prior process environment. Restore absent and empty values as distinct states.
7. Run the selected product acquisition tests when their implementation is available. Recheck changed host inputs before that run.
8. Keep Windows5.1 recovery script tests open. Use an actually admissible supported environment when the real harness is available.

## Executed result and limits

The coordinator created the protected direct-profile root and eight ordinary child files. On Windows10.0.26200 x64, local fixed NTFS, PowerShell7.6.5 and .NET10.0.11, the actual `-NoLogo -NoProfile -NonInteractive -File` storage probe exited0 under RemoteSigned. The marker, nonce, runtime identity and fixture communication bytes matched. All twenty pre-existing descriptors and four executable hashes were unchanged. No existing ACL, policy or user/machine environment was changed.

The original whole run remains **failed**: process cleanup restored an absent value as present-empty. Its previous raw state was not recorded, so the exact original absence is an inference from the reproduced mechanism. Three separate actual process controls reproduced the binding behavior and verified the corrected helper for absent, empty and nonempty values, including Unicode and trailing whitespace. The parent environment stayed unchanged. `[NullString]::Value` supplies a true null to a .NET string parameter; .NET9+ preserves a process empty string separately. See [Microsoft NullString](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.language.nullstring) and [Environment.SetEnvironmentVariable](https://learn.microsoft.com/en-us/dotnet/api/system.environment.setenvironmentvariable?view=net-10.0).

At17:34:44Z the coordinator checked all thirty current tool/ancestor/private-object descriptors, four binary hashes, directory membership and retained file content. All matched. The host-placement and PowerShell7 storage-execution components are accepted together with the independently verified restoration helper. The original failed receipt is unchanged. No provisioning or storage-probe replay was needed.

This result does not prove hostile same-user race containment. The creation API's existing-directory/no-op limitation remains recorded. It does not identify the old Temp principals, qualify Windows5.1 script execution, implement acquisition, or accept credential/extraction/failure/platform tests. It does not close A07, A14, A16 or a human gate. No user decision is needed at this boundary.

## Evidence

Private locations are in STATUS's local configuration. Frozen artifact identities:

| Artifact | SHA256 |
| --- | --- |
| WQ1 read-only report | aef5f2c7b1c779bfb11380973e7288f6e33e8689256513cf8a7a655b0ead4db3 |
| WQ1 baseline evidence | 4c12aed6cf0ff7310c985f1a25fb37753f6ba47468930f06f6e709ef5b854092 |
| Original qualification source | 3e8dc9339e28c3a0b97159388f5683040896cfaea1e721da3f659da360192a59 |
| Original failed receipt | 272ead067544ade264e2875173c0a2dd740fae04d71143db24d07b11dba7f527 |
| Corrected restoration helper | 272cde586f38e46b3047f91d9217185f74b31bcfe78b371d50f134780e278a02 |
| Three-control source | 6244549fef605b8480a7d9ece5b6b07981ca457b2b167c53263d7dbaf1a857d6 |
| Exact ASCII-escaped control receipt | ec57a7156467a0f56b14f4707c3442eb8a271168c18b8a6dd70f1e574bf28eb5 |
| Current component acceptance | b14a30d0ca642e3cf6c8ddfae7be3429c294118b43ab65069aab5f2a47a13bbb |
