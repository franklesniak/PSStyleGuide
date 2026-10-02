<!-- markdownlint-disable MD013 -->
# D-A02-16 — private fixture APIs and intended Git modes

Design only; parent publication/release is pending. Requested gpt-6-astra/high; effective settings unavailable. This author contributed to D15 and supplies design assessment, not independent final acceptance. No tests or product/native/planning writes were performed.

## 1. Validity and bounded evidence

Read STATUS first and inspected D15's fixture hash/mode materialization, subsequent staging/commit callers, ambient package/pre-commit commands and the existing compatible hash idiom. Frozen SelfTest SHA256 is `ee5893b0c3c3ca0631dfb08b9859b34004fa0053e7f7bb5599c5ed2684ad4b44`; validator remains `ba8dc366bd8e5d28a90b43e3d275bb610b23da4457392e923de78264bb0ee29e`. Parent reports five D15 suites passing on 7.6.5; that evidence is unchanged and does not cover older APIs or Linux filesystem behavior.

The new private snapshot uses SHA1/SHA256.HashData and Convert.ToHexString, and its non-Windows writer uses UnixFileMode/File.SetUnixFileMode. [Microsoft's .NET7 announcement](https://devblogs.microsoft.com/dotnet/announcing-dotnet-7-preview-7/) explicitly introduces the Unix mode APIs. [Microsoft's PowerShell/runtime mapping](https://learn.microsoft.com/en-us/powershell/scripting/whats-new/differences-from-windows-powershell?view=powershell-7.5) maps 7.0 to Core3.1, 7.1 to .NET5, 7.2 to .NET6 and 7.3 to .NET7. The static hash/hex APIs have .NET5 floors; see [SHA1.HashData](https://learn.microsoft.com/en-us/dotnet/api/system.security.cryptography.sha1.hashdata), [SHA256.HashData](https://learn.microsoft.com/en-us/dotnet/api/system.security.cryptography.sha256.hashdata) and [Convert.ToHexString](https://learn.microsoft.com/en-us/dotnet/api/system.convert.tohexstring). Thus these operations introduce newer API dependencies than the local command states.

The actual npm script and pre-commit hook invoke ambient pwsh with -SelfTest. Neither the validator nor SelfTest declares a minor floor. Initialize-CiToolchain's separate #Requires7.3 is not invoked by those local callers. However absence of a guard does not prove that every historical minor was promised or that the entire earlier validator passed there. No older-host run or explicit validator7.0 support promise has been found. Current [Microsoft-supported PowerShell releases](https://learn.microsoft.com/en-us/powershell/scripting/install/powershell-support-lifecycle) contain these APIs. The substantiated finding is an unnecessary, undeclared local-call dependency and a useful bounded reduction; it is not a demonstrated regression on a currently Microsoft-supported host. The generator's separate Windows PowerShell5.1 promise does not apply here. Do not claim full 5.1 or historical7.x compatibility from this repair.

The required D15 mode identity is Git100644/100755 from the source index. The installed snapshot already sets that identity with update-index --chmod and compares path/blob/mode/raw hashes. Its identity does not compare source physical permissions with destination physical permissions. Current actual consumers execute pwsh -File, Node with a script argument, and external system Git; no fixture file is launched directly as an executable. The staged100755/raw nonexecutable Windows case already distinguishes intended Git mode from physical permissions. Available UnixMode is separately used to reject nonregular inputs and changes during reading; retain that guard.

Removing only SetUnixFileMode is insufficient on Linux: later git add can refresh intended executable mode from different physical permissions. [Git core.fileMode](https://git-scm.com/docs/git-config#Documentation/git-config.txt-corefileMode) controls whether executable-bit differences in the worktree are honored; [update-index --chmod](https://git-scm.com/docs/git-update-index) controls index executable identity. Preserve the latter explicitly and prevent the former from replacing it during private fixture staging. This is not suppression of the index-mode comparison.

## 2. Stakeholders and options

Local contributors need predictable caller requirements. Security reviewers need exact raw/blob/mode identity and unchanged regular-file refusal. Windows/Linux maintainers need one understandable fixture path without an unnecessary OS utility dependency. The owner and sole writer need no unrequested runtime-floor policy or production change. Cost/maintenance stakeholders need bounded reuse. No cloud, credentials, user data, actual document content, localization or accessibility behavior changes.

- N: no change. Current supported-host success remains; undeclared and unnecessary dependencies remain.
- B: reuse Create/ComputeHash/BitConverter hashing; remove physical-mode assignment because no actual consumer needs it; retain exact index-mode installation and checks through all private staging operations.
- F: explicitly raise/enforce the local runtime floor and document it. Broader support/caller policy change, without a necessary fixture capability gained.
- C: compatible hashing plus native chmod or the already required Python os.chmod for physical permissions. Could retain physical bits but introduces another program and failure boundary without a consumer.
- G: compatible hashing plus Git checkout-index for physical modes. Reuses Git, but may reapply filters/newlines and requires extra raw-byte restoration/proofs for an unneeded property.
- H: feature-detect the new APIs and maintain fallback branches. Adds two equivalent code paths and tests without useful behavior over B.
- W: remove hashes, intended-mode assertions or Unix regular-file checks. Violates hard controls and is inadmissible.

## 3. Fresh rubric and scores

Scores1–5 mean fails, weak, partial, adequate with limits, directly meets. Total=sum(weight × score)/5. Weights: required identity/refusal integrity35%; removal of unnecessary dependencies25%; preservation of caller scope20%; maintenance10%; verification clarity10%.

Hard constraints: keep raw SHA256 and Git-blob identity, exact intended index modes, source-stability/bounds/path/refusal controls; no public API, production runtime/config or actual-guide edits; no invented whole-runtime compatibility claim; no skipped failing tests.

| Option | Integrity35 | Dependencies25 | Caller20 | Maintenance10 | Verification10 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 5 | 2 | 3 | 5 | 4 | 75 |
| B | 5 | 5 | 5 | 4 | 4 | 96 |
| F | 5 | 3 | 2 | 3 | 4 | 72 |
| C | 5 | 4 | 5 | 3 | 3 | 87 |
| G | 5 | 4 | 5 | 2 | 3 | 85 |
| H | 5 | 3 | 5 | 2 | 3 | 80 |
| W | 1 | 5 | 5 | 5 | 1 | 64 |

Arithmetic checked. B preserves the actual consumed properties and removes operations with no consumer. This concrete distinction, not a claim that older hosts are guaranteed supported, selects B. No new owner runtime policy is inferred.

## 4. Selected bounded repair B

Edit only the D15 private fixture in Test-AgentInstructions.SelfTest.ps1. Use SHA1.Create()/SHA256.Create(), ComputeHash(byte[]) and BitConverter.ToString(...).Replace('-', ''). Preserve lowercase Git blob text and the existing raw SHA256 representation. Dispose both hash instances in finally. Retain the exact ASCII Git blob header with NUL and byte length. Reuse the idiom already present in Test-ExactGitPathSet.ps1; do not load that whole script or introduce a shared crypto library.

Remove only the physical UnixFileMode/SetUnixFileMode assignment. Keep source index modes, update-index --chmod and exact installed identity verification. Set core.fileMode=false only in the newly created disposable clone, before its materialization/staging. Check the git config native exit and verify local Boolean readback is false. The private linked policy worktree shares that clone configuration. This covers initial add --all, guide-normalization add --all, the shared meaningful-candidate commit helper, the local document add, and git diff --quiet HEAD used by the local published-baseline helper. Per-add overrides alone leave that dirty-context reader sensitive to physical-mode mismatch, so they are not the selected complete solution. Do not alter global, source-repository or product configuration. Verify intended modes again after normalization and in committed B/H trees. Do not merely rely on the earlier pre-normalization check. Newly generated test documents retain explicit ordinary100644 expectations. Preserve ordinary native exit failure handling.

Keep the optional UnixMode regular-file/type-stability checks, reparse/link refusal, bounded reads, source recheck and all raw/filter guards unchanged. Do not claim physical executable-bit parity. If a real direct-execution consumer is later demonstrated, reassess that requirement before adding a mode-setting API; do not quietly run such a consumer against this narrower fixture contract.

## 5. Targeted verification and limits

Prove old/new hashes match for empty, text and binary/NUL buffers, including Git blob header identity; use known results or Git hash-object --no-filters as an independent oracle. Confirm hash objects are disposed on failure. Preserve exact hex casing and byte treatment.

Reuse the affected D15 staged-mode scenario and run it with intended100755 for physically nonexecutable data and intended100644 control. Verify mode survives installation, guide normalization, B creation/reuse and subsequent H staging/commits. On a Unix host, test both intended modes with differing physical execute bits and unchanged available UnixMode regular-file refusal. Until that host test runs, report the Linux behavior as pending rather than inferred from Windows. Existing Windows evidence can establish index/byte behavior only.

Keep F2 actual-caller outcomes and D15 snapshot/refusal controls. Run targeted hash/mode/source-immutability checks and one actual full F2 scenario with a new staged100755 path, then the required two aggregate passes on final frozen bytes. Reuse unchanged D15 date, already-normalized baseline and source-shape evidence when the targeted API equivalence and identity checks support that reuse; do not repeat all three long source suites solely because the SelfTest file hash changed. Run the final-candidate executable-index-mode case on a Linux host. Required current-candidate CI remains separate; an all100644 CI run alone cannot substantiate executable-mode preservation. Do not install old runtimes or expand a compatibility matrix solely to claim historical support. If an older admitted runtime is exercised, state its exact version and tested scope. Current 7.6.5 success alone is not that claim. Parent owns publication/release; no edits are authorized by this record itself. Review clock/transfers and unresolved authority remain unchanged.
