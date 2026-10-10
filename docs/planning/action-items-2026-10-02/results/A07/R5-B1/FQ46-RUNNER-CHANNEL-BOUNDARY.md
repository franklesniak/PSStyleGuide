<!-- markdownlint-disable MD013 -->
# FQ46: Confine runner command files and reject hard-link aliases

Status: Selected by root before implementation. Date: 2026-10-10 UTC. Owner: root. Analyst: /root/fq45_source_review. Scope: PR239 round5, comment 4235536397, thread PRRT_kwDOQkjdhM6q-51r, reviewed commit 03f1dbf72ce486c0fa1d2cdfb74aaf78143e4477, source tree 0e448484daf1b50c9b0f8924188c4aa90c4c0db5.

FQ46 identifies a real admission gap. Recommend option E below: confine each channel to the exact runner command directory and verify one-link file identities before opening and through the existing held handles. Keep the current caller scope; do not add a Docker-action alias exception. No implementation or new native product test has run. This report is a proposal, not a resolved-finding or merge acceptance.

## Current behavior and classification

The authenticated local observation records Codex review 5476507805 on the exact published commit. The review requests containment and hard-link rejection. Its documentation premise needs one correction: scripts-README.md line142 expressly requires RUNNER_TEMP to be outside the checkout, but describes GITHUB_PATH and GITHUB_ENV only as distinct existing ordinary files. Thus this is a missing channel boundary, consistent with AGENTS.md lines50–53, rather than a literal violation of an already explicit channel-containment sentence.

Initialize-CiToolchain.ps1 lines50–135 validate absolute ordinary paths and ordinary ancestors. Lines1195–1203 reject a runner temporary root within the checkout. Lines1205–1207 admit the two channels by ordinary-path and unequal-string checks. Windows then checks admitted writers. No directory-membership or link-count condition ties the channels to the runner root. An independently writable ordinary checkout file can therefore satisfy channel admission. A single in-area hard link to an unrelated writable file also satisfies it.

The initializer already opens both channels with FileMode.Open, ReadWrite, FileShare.None at lines1254–1255. It retains those same streams until publication at lines1368–1373, then disposes them. The final ordinary-path checks at1362–1363 do not provide link counts or compare each pathname to the held file. There is no pathname reopen for the publication writes. Preserve this lifecycle.

The F10 cases at Test-CiHelpers.test.mjs lines4379–4439 link the two channels to each other. Their second exclusive open fails. They do not test one channel linked to an unrelated sentinel while the other channel remains independent. Consequently their success does not discharge this finding. Static reasoning establishes the absent predicate; it does not prove a complete native exploit or an actual damaged user file.

The initializer bytes are a64a17876d6cb71d3a4cbb7d46bbd0edc193c24fa047efa45491f85752dbc0d5, unchanged from the accepted earlier initializer. The flaw predates the round4 askpass change. It is newly identified, actionable hardening of this PR's channel boundary. It is distinct from FQ34's Windows locality check, F3's append-right ACL mask, and F6's owned staging identity. Those accepted decisions remain applicable to their own scopes. The earlier general-coverage overview and final-quality report cannot resolve this specific finding.

## Trust boundary and runner layouts

The proposed anchor is the already required and validated RUNNER_TEMP, supplied by the runner in supported workflows or deliberately supplied by a qualified offline caller. Do not infer the trusted root from either channel's parent. A process environment value is not cryptographic proof of runner origin. This proposal retains the existing trusted host, runner configuration, process account, and admitted native runtime assumptions. It does not promise protection from hostile concurrent code running with the same user token, administrator, or mount authority.

GitHub runner FileCommandManager creates each command file below its temporary directory's `_runner_file_commands` child, then translates the path for a container. It uses role prefixes and a per-step GUID. [Runner file commands](https://raw.githubusercontent.com/actions/runner/main/src/Runner.Worker/FileCommandManager.cs).

For a job container, the runner mounts its work/temp areas and translates environment values into the container namespace. Thus the translated RUNNER_TEMP remains a usable anchor for the translated command directory. [Container mounts](https://raw.githubusercontent.com/actions/runner/main/src/Runner.Worker/ContainerOperationProvider.cs), [step environment translation](https://raw.githubusercontent.com/actions/runner/main/src/Runner.Worker/Handlers/StepHost.cs).

A Docker container action additionally mounts the same command directory at `/github/file_commands`, while the temporary root is available at `/github/runner_temp`. The textual channel path need not begin with RUNNER_TEMP. That layout is not a current supported consumer of this initializer. It is evidence against a universal textual-path claim, not a reason to add an exception. A literal `/github` allowlist is insufficient. [Container-action mounts](https://raw.githubusercontent.com/actions/runner/main/src/Runner.Worker/Handlers/ContainerActionHandler.cs).

The actual product has four initializer calls: markdownlint.yml lines63/125 and agent-instructions.yml lines72/163. All are ubuntu-24.04 pwsh shell steps, with no container job/action declaration. README lines24/140–142 describe direct Linux/Windows x64 callers and a private runner environment; no Docker-action alias contract is stated. Direct callers must provide the supported command-directory layout. A normal job-container mapping can satisfy that same rule, but this proposal grants no new container qualification.

GitHub defines RUNNER_TEMP as the job temporary directory and describes command paths as step-specific. These are layout facts, not an authentication mechanism. Custom container hooks or filesystems which cannot establish the selected directory and file identities must fail closed with a clear prerequisite error. [GitHub variables](https://docs.github.com/en/actions/reference/workflows-and-actions/variables).

## Stakeholder perspectives

| Perspective | Required outcome |
| --- | --- |
| Security reviewer | No outside ordinary file or hard-linked alias is admitted for channel writes. |
| Workflow author | Standard native and job-container execution continues without a new secret or input. |
| Container author | Preserve actual supported caller scope; document that the separate Docker-action alias requires a future decision and qualification. |
| Windows operator | Keep owner/SYSTEM/administrator/servicing ACL checks and full file IDs. |
| Linux operator | Use descriptor identity; do not treat advisory sharing as mandatory exclusion. |
| Repository maintainer | Keep the existing held-stream lifecycle, private staging and cleanup. |
| Test maintainer | Real native metadata and causal controls prove refusal for the intended reason. |
| Documentation reader | State supported paths, single-link requirement and fail-closed prerequisites. |
| Paired-repository integrator | Carry the small contract/test change through the existing paired plan; do not infer destination validation. |
| Release/operator owner | Keep deadlines, finite run budgets and truthful outstanding whole-caller limits. |

## Alternatives and permutations

The relevant choices are independent: anchor (none, checkout denylist, broad temporary root, exact command root, caller-configured root); alias treatment (none, literal alias, identity-bound alias); hard-link check (none, pathname only, held file); timing (admission only, admission plus publication); publication (existing streams or a new architecture). The table covers the distinct useful combinations. Broader roots cannot improve containment over the exact runner root. A literal container alias without identity proof is dominated by an identity-bound alias. Replacing held streams with pathname appends is dominated by keeping them. Filename-prefix or same-GUID enforcement adds a separate role/step contract; it is not needed to prevent this finding and is not selected. Arbitrary descendants of the command root are also unnecessary because the runner creates direct children.

| Option | Concrete choice and tradeoff |
| --- | --- |
| A | Keep behavior; clarify that callers select arbitrary files. Preserves compatibility but leaves the wrong-file write boundary open. |
| B | Reject checkout paths only. Protects one location but still permits profiles and other outside files or hard links. |
| C | Require containment anywhere under RUNNER_TEMP plus pathname link count at admission. Allows unrelated files in that broader area and lacks held-file revalidation. |
| D | Require exact command root, pathname link checks once, and existing streams. Stops static aliases, but does not verify the object actually opened or later changes. |
| E | Require exact command root and pre-open/held-file checks before staging and publication; reject Docker alias. Strong finite boundary; preserves current supported consumers without adding a new alias contract. |
| F | E plus a new identity-bound Docker-action alias. Technically feasible but adds an unsupported caller contract, mount-identity tests and extra policy for no current consumer. |
| G | Let the caller supply additional allowed roots, with held-file checks. Flexible but shifts the core allowlist back to the input source and enlarges configuration/review burden. |
| H | Rebuild all channel/staging filesystem access around native directory handles, relative opens and an expanded adversarial concurrency model. Stronger race design but much larger platform and qualification surface. |
| I | Stop channel publication; return data for another caller to append. Moves the same boundary into each workflow/caller and breaks the current interface. |
| J | Defer the finding until after landing. Leaves the current security boundary uncorrected. |

## Finding-specific rubric and scores

The rubric measures this failure mode and the actual supported caller contract. An initial broader compatibility assumption was corrected after the full caller readback: the existence of a runner Docker-action layout does not make it a supported initializer consumer. The final scores below use the corrected scope before any implementation. Score each dimension from0 (absent) to5 (fully meets the stated objective); weighted total is sum(weight * score / 5). Security and actual behavior dominate implementation effort. Hard admission gates are: reject outside files and hard links on both supported OSes; retain truthful trust limits; preserve mandatory existing guards; provide causal tests. Options that fail these gates cannot win even with a convenient total.

| Dimension | Weight | Meaning |
| --- | ---: | --- |
| S | 30 | Correct confinement of both channels to the intended physical runner area. |
| I | 20 | Link-count and actual-file identity checks at the relevant lifecycle points. |
| C | 20 | Usable existing workflow and direct-caller layouts within the current contract; no unrequested consumer expansion. |
| T | 15 | Finite, causal, native-verifiable tests and failure diagnosis. |
| O | 10 | Clear operational contract, fail-closed behavior and retained cleanup. |
| B | 5 | Bounded change and maintainability; this cannot outweigh security. |

| Option | S | I | C | T | O | B | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 0 | 0 | 5 | 2 | 2 | 5 | 35 |
| B | 1 | 0 | 5 | 3 | 3 | 5 | 46 |
| C | 3 | 2 | 5 | 4 | 4 | 4 | 70 |
| D | 5 | 2 | 5 | 5 | 4 | 4 | 85 |
| E | 5 | 5 | 5 | 4 | 5 | 4 | 96 |
| F | 5 | 5 | 4 | 3 | 3 | 2 | 83 |
| G | 3 | 5 | 5 | 3 | 2 | 3 | 74 |
| H | 5 | 5 | 3 | 3 | 2 | 1 | 76 |
| I | 2 | 1 | 1 | 2 | 1 | 1 | 29 |
| J | 0 | 0 | 5 | 1 | 1 | 5 | 30 |

E wins because it checks the actual admitted files and preserves supported callers without rebuilding staging. D lacks two important identity checks. F adds an unneeded Docker-action interface and qualification surface. H's extra concurrency ambitions do not justify replacing the foundation for this bounded defect. E's score is a design assessment, not runtime evidence.

## Selected instructions (controlled, direct style)

1. Keep the existing RUNNER_TEMP admission. Form its `_runner_file_commands` child with a literal path operation. Require that directory to exist. Do not create it. Reject a command directory within the checkout. Record its native identity.
2. Admit a channel only if its normalized parent equals that directory. Use the existing OS-specific path comparer. Reject sibling-prefix paths, traversal escapes and nested directories. Do not admit `/github/file_commands` or another root merely because it is a runner convention elsewhere. Direct callers must supply the selected anchored layout.
3. Check both channel paths as ordinary files and keep all existing ACL checks. Read each file's native identity and link count without write access. Require a link count of exactly one. Require two different file identities. Complete these checks before opening either channel for writing, creating staging, or acquiring tools.
4. Open both files with the existing FileMode.Open, ReadWrite and FileShare.None settings. Query metadata from each stream's actual SafeFileHandle. Require the same identity as the admission sample, a regular file, and one link. Fail before staging if either check fails.
5. Keep both streams open. Before the first publication write, check the root and both paths again. Require the recorded directory identity. Require each pathname to identify its held file. Query both held handles again. Require one link and the same file identities. Complete all checks for both channels before either write.
6. Append through the existing streams. Keep UTF-8 encoding, record validation, Flush(true), disposal, partial-write failure behavior and owned-staging cleanup. Do not delete, replace, truncate or change permissions on runner command files.
7. Fail if a metadata query or identity proof is unavailable. Report the channel role and failed prerequisite without printing channel contents, tokens or environment dumps. Keep diagnostic text bounded.
8. Update helper help and scripts-README.md. State the exact directory rule, unsupported alternate layout, one-link rule, native-query prerequisites and existing concurrency limit. Keep arbitrary offline fixtures inside the same supported directory layout.

No GUID or basename-version rule is proposed. Directory membership, ordinary-file checks, distinct identity and one link address the write boundary. The runner's role prefixes may be used in fixtures for fidelity, but are not a new product prerequisite.

## Native mechanisms and limits

Windows: extend a channel-specific metadata adapter with GetFileInformationByHandleEx FileStandardInfo (class1) for NumberOfLinks, Directory and DeletePending. Keep FileAttributeTagInfo (class9) and full FileIdInfo (class18: volume plus128-bit file ID). Use a zero-data-access no-follow temporary handle for the pre-open sample; use each existing FileStream.SafeFileHandle for the authoritative sample. Preserve handle lifetimes and reject native failure. Do not substitute the classic64-bit file ID for the existing full ID. [FILE_STANDARD_INFO](https://learn.microsoft.com/en-us/windows/win32/api/winbase/ns-winbase-file_standard_info), [file information API](https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getfileinformationbyhandleex).

Linux: use statx with AT_SYMLINK_NOFOLLOW for pathname samples and AT_EMPTY_PATH with an empty string for actual held descriptors. Require returned TYPE, NLINK and INO bits; require a regular file and nlink1. Compare device major/minor plus64-bit inode between samples. Keep the SafeFileHandle alive across conversion and native call with the corresponding safe-handle lifetime discipline. No external stat executable, parsed shell output or timestamp identity. [statx semantics](https://man7.org/linux/man-pages/man2/statx.2.html).

The explicit Linux structure is256bytes. Relevant offsets are mask0, nlink16, mode28, inode32, device major136 and minor140. TYPE=1, NLINK=4, INO=256; required result mask is261. Preserve the complete buffer size; do not marshal a truncated structure. The shipping initializer already requires native Linux/Windows x64. Fresh qualification must check the ABI and normal/linked/renamed-file observations on the actual supported runtime. [Linux UAPI structure](https://raw.githubusercontent.com/torvalds/linux/master/include/uapi/linux/stat.h).

For Linux library binding, use the exact admitted `$PSHOME/libSystem.Native.so` path, with the existing ordinary-path/native-runtime trust requirements and stable source qualification. Load that path and resolve `statx` from its dependency closure using NativeLibrary.GetExport. Keep the library handle alive for its delegates. The .NET implementation routes GetExport to dlsym on Unix, and dlsym searches the specified handle's dependency tree. This is not a claim that statx is a direct System.Native export. [Runtime export lookup](https://raw.githubusercontent.com/dotnet/runtime/v10.0.0/src/coreclr/vm/nativelibrary.cpp), [Unix PAL lookup](https://raw.githubusercontent.com/dotnet/runtime/v10.0.0/src/coreclr/pal/src/loader/module.cpp), [dlsym contract](https://man7.org/linux/man-pages/man3/dlsym.3.html).

The native-binding alternatives are also bounded: (N1) PSHOME libpsl GetInodeData and (N2) System.Native FStat alone fail the required link-count contract; (N3) external stat/fsutil or PowerShell display properties lack authoritative held-handle data and add discovery/parsing; (N4) unqualified libc imports or distro paths add avoidable resolution/platform assumptions; (N5) unique loaded-libc module discovery is feasible but adds enumeration and identity policy; (N6, selected) resolve statx through the exact admitted PSHOME native-library dependency handle and qualify it; (N7) add a compiled native shim or full native opener, which expands distribution and review scope. N6 satisfies the same S/I requirements as N5 with less new platform-discovery machinery. None bypasses native qualification.

Actual availability in the admitted PowerShell build is a mandatory fresh capability gate. Record the library/dependency closure and prove statx results against owned files and held descriptors. Reject missing exports, native errors and incomplete masks. There is no unqualified libc-name search, hardcoded distro path, process-module discovery, shell fallback or automatic alternative after failure. If qualification disproves this binding, stop and revise this native-binding choice before product execution. Coordinate the exact-path loader/lifetime pattern with FQ48's proposed SystemNative_GetEUid binding; FQ46 does not change the UID policy.

Root supplied a fresh finite capability result before this proposal was sealed: native208f75/0, image8bdc7722fc55e19fd3df48d8fddf4568a75d8792cfc4ee105c8a8173559362f4, PowerShell7.6.3/.NET10.0.9, library SHA256c19d793677718165b7affb35445b2a284100a27205cf5127a98fe0b92c8d0607. Independent readback of Probe.ps1, request, stdout/stderr and result confirms successful dependency-export lookup and AT_EMPTY_PATH query of an open descriptor: mask6143, nlink1, regular mode33188, inode825839. The read-only, network-none, UID1000, cap-dropALL container was absent afterward. This satisfies the finite binding-availability question on that runtime; do not repeat it only for this proposal. It supplies no product, negative-case, Windows ACL or whole-caller acceptance.

Precision: that probe requested/checked0x103 (TYPE|MODE|INO), while its actual returned mask6143 also contains NLINK. Product code must request and require the selected0x105 (TYPE|NLINK|INO), and the maintained tests must exercise missing NLINK and nlink2. That remains a product-validation obligation, not a reason to discard the successful binding observation.

This proposal deliberately leaves the existing staging Get-OwnedPathIdentity API unchanged. Its libpsl-native GetInodeData does not supply link count. The reviewed .NET System.Native FileStatus also has no link-count field, so its FStat wrapper is not a complete substitute. [Runtime native structure](https://raw.githubusercontent.com/dotnet/runtime/v10.0.0/src/native/libs/System.Native/pal_io.h).

On Linux, FileShare.None uses advisory/best-effort flock behavior. The selected identity checks do not turn this into mandatory exclusion. Sampled checks still cannot stop an adversarial same-user link or mount operation in the last interval before a write. Windows sharing and current ACL controls remain stronger in some cases; neither platform gains a blanket concurrency claim. [Runtime Unix file handles](https://raw.githubusercontent.com/dotnet/runtime/v10.0.0/src/libraries/System.Private.CoreLib/src/Microsoft/Win32/SafeHandles/SafeFileHandle.Unix.cs).

## Offline reproduction and exact test proposal

The supporting test-plan.json is inert. Root must release any execution separately. Use only owned private fixture files: a simulated checkout sentinel, simulated profile sentinel, runner temporary directory, and two command files. No actual checkout/user profile, network, real runner file or security-setting change is permitted. Record native identities/link counts, sentinel hashes, exit status, dispatch marker and cleanup observations; never infer a hard link merely from a fixture name.

The minimum old-source demonstration uses the actual extracted path admission, current two-open statements and publication statements with fixed non-secret records. Give one channel an outside ordinary sentinel and keep the other independent; repeat with one in-area channel hard-linked to a sentinel. The old boundary should reach the append while the new boundary refuses before write. This demonstrates the channel boundary only. It does not claim whole-initializer success. Keep a valid-layout positive control and the existing two-channels-linked refusal control under identical prerequisites.

The focused matrix has24 logical rows:19 on each OS plus5 Linux-only rows. Rows with a chosen channel run once for each role. The expanded matrix has70 platform/role cases before causal-mutant counterparts. That count is a test proposal, not a runtime count or new total-suite expectation. The inert matrix gives exact IDs, mutations and expected observations. Keep fixtures at most1MiB each, each child at most30s and the focused group at most600s; use the existing stricter limits where lower. Root must reconcile this with the actual registration/child structure before release rather than hardcode a historical aggregate.

For containment and hard-link negatives, require native fixture proof, unchanged hashes of both channels and sentinels, no acquisition marker, no owned staging, and closed handles. For publication-time mutations, acquisition may already have occurred: require no new channel bytes and owned-staging cleanup, with no false early-refusal claim. A valid sibling case must reach the intended dispatch/publication checkpoint. Run exact causal mutants that remove only the relevant containment, link-count, held-identity or final revalidation predicate; require the intended boundary to become observable. A generic nonzero exit is insufficient.

Preserve the existing partial-channel-write test and failure semantics. In particular, do not introduce a rollback that can overwrite an externally changed file. Exercise error on the second channel after opening the first and prove the first handle is released. Keep the current ordinary-path, ACL, UNC, credential, selector, archive, output and cleanup assertions.

Update shared fixture constructors to create `_runner_file_commands` below their RUNNER_TEMP. This affects more than the new test names. Reconcile complete registrations and constructor closures, especially F10, F6 identity, FQ35 record extraction anchors, whole initializer tests, and FQ45 caller refusal. A previously invalid unrelated fixture must not pass only because the new earlier check stops it. Rebuild affected generated syntax forms from exact current source; reuse only unchanged effective-input closures. Parser/analyzer success alone is not behavioral or full-style acceptance.

Add a controlled Linux payload whole-initializer success and failure where the existing qualified harness can do so. Use actual Win32 metadata tests on Windows. The accepted A04 limitations remain: extracted Windows installer coverage is not a complete Windows whole-initializer TLS/retry/channel or preferred-success-recovery loopback test. Do not close A04 from these focused channel tests.

## Bounded scope, prior acceptance and remaining gates

Expected product edits are Initialize-CiToolchain.ps1, Test-CiHelpers.test.mjs and scripts-README.md, with interface/fixture changes coordinated with FQ47 and FQ48. No workflow policy, digest pin, trust-root list, staging identity model or protected instruction file requires a change for FQ46. Existing full guide review is reusable: canonical STYLE_GUIDE.md hash331a401e3f26dbd4c497e156784c8f3e41f17bc295ec9f6a734639f2d6bb62fd and generated PowerShell body remain unchanged. Existing external-input/allowlist rules and literal-path guidance are sufficient. No secondary guide change is proposed; assess actual new code against all applicable clauses after implementation.

Root displayed and accepted option E96 before implementation. It may now authorize bounded implementation, source review, the remaining native metadata/negative qualification, focused causal tests, affected runtime/syntax closure and normal repository gates. Reuse the exact finite Linux binding capability above; do not grant it broader credit. This report authorizes none of those actions by itself. No source or runtime acceptance for a changed candidate is claimed.

Prior FQ32 truth is unchanged: the original outer controller failed with exit1 for retained residue; the actual11 native hooks passed and received separate exact-run retention acceptance. The residue is neither a channel exception nor a blanket strict-controller pass. No human review, complete current review pair, merge, landing, or destination convergence is claimed. FQ47 and FQ48 remain separate findings owned elsewhere. Preserve the active round/deadline/transfer accounting.

Root selection: E96. The source proposal is frozen at SHA256992ece226f0ff484be6a037b7b51fc9d689658ceb9e8458121609eea0b50e9d4. Root read the complete report and sampled score arithmetic. Implementation and product validation remain pending. This file is the canonical finding record.
