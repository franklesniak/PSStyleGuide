<!-- markdownlint-disable MD013 -->
# FQ48 effective-UID decision proposal

Analysis only. The finding is valid. Recommend option F: query the live Linux effective UID through the admitted PowerShell runtime's exact `libSystem.Native.so` and reject UID 0. Root selected F before implementation. E, a direct `geteuid` lookup through the same runtime-library handle, is an equivalent F-family variant; the rubric does not charge it for the now-removed libc resolver. No product code, tests, Git, canonical planning, runtime, or remote state was changed.

## 1. Validate the finding and bound the problem

PR239 comment **4235536408**, thread **PRRT_kwDOQkjdhM6q-51z**, concerns published PS commit **03f1dbf72ce486c0fa1d2cdfb74aaf78143e4477**, tree **0e448484daf1b50c9b0f8924188c4aa90c4c0db5**. Root's inert export manifest SHA256 is **0165bd56b9a5fd76bf542373c934653f5fddd08692eb3e7ca720fa8fa143ff88**. Initializer SHA256 **a64a17876d6cb71d3a4cbb7d46bbd0edc193c24fa047efa45491f85752dbc0d5** matches the integration file at this observation.

Initializer lines 1165–1168 admit native Linux/Windows x64. At 1236, Linux refusal compares `[Environment]::UserName` with the literal `root`; it throws at 1237 only on a matching name. A passwd entry with effective UID 0 and a different name passes that predicate. Conversely, a nonzero UID whose account name is `root` fails it. This is a semantic validation from the actual predicate and primary runtime source, not a worker runtime reproduction.

The [.NET 10.0.5 Unix implementation](https://raw.githubusercontent.com/dotnet/runtime/v10.0.5/src/libraries/System.Private.CoreLib/src/System/Environment.Unix.cs) obtains the username through the effective UID's passwd record, while its privileged-process implementation compares the effective UID numerically with zero. The distinction therefore applies to this actual API, not just an environment-variable imitation.

The replacement must remain before the credential helper (1239), channel opening/private staging (1253–1256), Linux curl capability probes (1285–1286), and acquisition (1288). Earlier path/declaration inspection can remain. Windows keeps its separate branch and reviewed curl capability probes. This repair does not change archive, digest, selector, ACL, cleanup, recovery, or publication controls.

## 2. Tailored stakeholder assessment

| Stakeholder | Concrete need and consequence |
| --- | --- |
| Linux runner operator | Reject privileged extraction regardless of NSS account spelling; explain recovery as use of a process with nonzero effective UID. Do not rename accounts or alter host settings. |
| Maintainer/security reviewer | Check the identity used for permission checks at invocation time, with a small auditable binding and an explicit runtime trust boundary. |
| Caller in a reused PowerShell host | A prior privilege observation must not decide a later call after a legitimate UID change. Existing examples use `&` and do not enforce a new process. |
| Windows CI owner | No Linux library load, new Windows privilege policy, or changed curl/credential ordering. |
| Test maintainer | Test actual source predicates and bindings, distinguish stubbed guard tests from real native UID evidence, and prove causal guard removal. |
| Terraform counterpart owner | Carry this repair with the existing initializer/driver/documentation transfer after PS landing; obtain TF-native evidence separately. No transfer credit now. |
| New developer | Understand that account spelling and USER/LOGNAME are irrelevant; diagnose refusal with one effective-UID check rather than try renaming an account. |
| Documentation author | Replace the account-name wording at README 142 with the effective-UID contract and safe recovery; preserve the host qualification and acquisition limits. |
| UX/operator support | Give one fixed actionable diagnostic: use a process with nonzero effective UID. Do not expose passwd/config values or offer automatic privilege changes. |
| Security executive | Close a concrete privileged-extraction admission gap with current-input evidence; do not present a UID check as containment against hostile same-process code. |
| Business/release owner | Keep the patch and validation finite; defer PR release until the selected repair passes. Avoid unrelated platform/install-policy work and unearned paired-transfer credit. |
| Incident responder | Identify which source/native-runtime hashes supplied the UID observation and whether work began before refusal; preserve failed evidence and the established retention limits. |

## 3. Options and combinations

**A — Retain the name test, with extra aliases or environment-name checks.** Smallest change, but an arbitrary passwd name defeats it. No finite list establishes UID authority. Reject.

**B — Use public `[Environment]::IsPrivilegedProcess` alone.** This is the shortest supported managed expression on the selected .NET 10 host. However, [.NET 10.0.5 `Environment.cs`](https://raw.githubusercontent.com/dotnet/runtime/v10.0.5/src/libraries/System.Private.CoreLib/src/System/Environment.cs) caches the first result in `s_privilegedProcess`. A cached false value can survive a later effective-UID change to zero; a cached true value can refuse a later nonzero UID. The [public API documentation](https://learn.microsoft.com/en-us/dotnet/api/system.environment.isprivilegedprocess?view=net-10.0) describes the property but does not supply a live-refresh contract. The inspected [.NET 7.0.0 Environment source](https://raw.githubusercontent.com/dotnet/runtime/v7.0.0/src/libraries/System.Private.CoreLib/src/System/Environment.cs) has no such property, relevant to the script's PowerShell 7.3 syntax floor. Reject as the sole gate under current caller contracts.

Fresh documented invocation reduces cache risk only if the UID cannot change between first observation and the guard. README line 140 recommends a reviewed executable with `-NoLogo -NoProfile -NonInteractive`; agent-instructions lines 68–72 and markdownlint lines 59–63 use separate workflow steps. These do not enforce the UID history of every direct `&` caller or library access during host startup. A new mandatory fresh-process/immutable-UID contract would be a broader compatibility decision. Do not silently adopt it.

**C — Execute qualified `/usr/bin/id -u`.** Obtain the child's effective UID through a fixed ordinary executable, strict native status and exactly one canonical unsigned decimal line. Avoid PATH and aliases. Correct under a qualified ordinary executable, but adds a child process, command admission, output parsing, and environment/native-loader considerations solely for this check.

**D — Parse `/proc/self/status`'s effective UID field.** Read the current process's proc record and select the second of four UID fields with bounded strict parsing; refuse unavailable or malformed proc data. Avoids a native binding, but adds Linux proc mount trust, special-file handling and a new parser for a primitive already in the runtime. It must never use the real-UID field instead.

**E — Bind live `geteuid` through the same exact runtime-library handle proposed for FQ46.** The [glibc persona documentation](https://sourceware.org/glibc/manual/2.44/html_node/Reading-Persona.html) distinguishes real and effective IDs. FQ46 now proposes exact `$PSHOME/libSystem.Native.so` plus dependency-tree export lookup, with no separate libc enumeration or distro path. Direct `geteuid` can use that same handle, qualified dependency closure and Cdecl uint32 binding on admitted Linux x64. It is an equivalent F-family variant, not a resolver-heavy competitor. Root's current capability probe resolved the dedicated UID shim and statx, but did not resolve direct `geteuid`; that export needs its own actual qualification before use. FQ46 remains unselected.

**F — Bind live `SystemNative_GetEUid` from exact `$PSHOME/libSystem.Native.so`.** The [.NET 10.0.5 interop declaration](https://raw.githubusercontent.com/dotnet/runtime/v10.0.5/src/libraries/Common/src/Interop/Unix/System.Native/Interop.GetEUid.cs) and [.NET 7.0.0 declaration](https://raw.githubusercontent.com/dotnet/runtime/v7.0.0/src/libraries/Common/src/Interop/Unix/System.Native/Interop.GetEUid.cs) specify a uint32 return from this export. The [.NET native implementation](https://raw.githubusercontent.com/dotnet/runtime/v10.0.5/src/native/libs/System.Native/pal_uid.c) calls `geteuid()` on each invocation; the [native header](https://raw.githubusercontent.com/dotnet/runtime/v10.0.5/src/native/libs/System.Native/pal_uid.h) declares it as always succeeding. This uses the admitted runtime closure, analogous to current exact `$PSHOME/libpsl-native.so` identity loading at 244–245. It needs no name lookup, proc parser, extra native child, or cached boolean. Recommend, subject to actual admitted Linux library/export qualification.

**G — F plus the cached public property as an additional refusal.** The live query closes the security gap, but a stale true cached value adds a false refusal after dropping privileges; the public API also adds an unnecessary version dependency. No benefit to the UID contract.

**H — F with E as automatic fallback on a missing dedicated export.** Both queries can use the same exact runtime-library handle. There is no added libc resolver. However, this adds a second export/admission branch and turns failure of the selected qualification into alternate admission. Qualify and select one fixed export; no fallback is justified.

## 4. Unique weighted rubric

Scores are decision estimates, not measured benchmarks. Each criterion is 0–5: 0 fails; 3 meets the requirement with extra qualification or restrictions; 5 meets it directly with a narrow auditable primitive. Weighted total is `sum(weight * score / 5)`.

| Criterion | Weight | FQ48-specific assessment |
| --- | ---: | --- |
| Live effective-UID correctness | 26 | Reject every current EUID 0; permit nonzero EUID independent of passwd names and cached earlier identity. |
| Binding trust | 20 | Anchor the query to the admitted runtime/system closure without PATH, bare sonames, mutable fallback, or NSS dependence. |
| Early phase fit | 14 | Run before credential Git, private staging, channel opening and acquisition without restructuring those controls. |
| Existing host compatibility | 12 | Preserve native Linux x64 and the stated 7.3 syntax floor; keep Windows behavior unchanged and account for reused hosts. |
| Added operational surface | 10 | Minimize child execution, parser/mount assumptions, reflection/private managed API dependence and native-layout requirements. |
| Causal evidence quality | 8 | Permit actual UID/native-binding proof plus guard-removal and wrong-ID mutants with precise refusal assertions. |
| Coupled scope discipline | 6 | Fit existing initializer/driver/docs and peer transfer; introduce no workflow, package, origin or policy changes. |
| Maintenance clarity | 4 | Explain UID, return type, library qualification and failure behavior in a short auditable contract. |

Mandatory eligibility gates override the total: live EUID rather than account spelling; no cached-result dependence; qualified binding; preserved pre-work ordering; no Windows regression; failure closed. A and B fail the first two gates. G adds an avoidable compatibility refusal. Root later supplied a successful exact-runtime F capability probe, described below; product behavior qualification remains future work.

| Option | Correct | Trust | Phase | Compat | Surface | Evidence | Scope | Clarity | /100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 0 | 5 | 4 | 5 | 5 | 2 | 5 | 1 | 63.2 |
| B | 3 | 5 | 5 | 2 | 5 | 3 | 5 | 3 | 77.6 |
| C | 5 | 3 | 3 | 4 | 3 | 4 | 4 | 4 | 76.4 |
| D | 5 | 3 | 3 | 4 | 3 | 4 | 4 | 3 | 75.6 |
| E | 5 | 5 | 5 | 4 | 4 | 5 | 5 | 4 | **94.8** |
| F | 5 | 5 | 5 | 4 | 4 | 5 | 5 | 4 | **94.8** |
| G | 5 | 5 | 5 | 2 | 3 | 4 | 5 | 2 | 84.8 |
| H | 5 | 5 | 5 | 4 | 3 | 4 | 5 | 3 | 90.4 |

F and E tie at 94.8 as equivalent live-query variants with the same runtime binding. Prefer F as a transparent tie-break: its explicit runtime PAL export has a documented uint32/always-successful contract and root has already observed that exact export returning UID1000. This is evidence and contract reuse, not an invented resolver advantage. Direct E remains a defensible alternative after its export/ABI is qualified. Raising the F-family qualification cost by one point in both compatibility and operational surface still yields 90.4. No score justifies A/B's mandatory-gate failures.

## 5. Proposed selected action in controlled English

Use the Linux process's current effective user ID. Load the UID function from the reviewed PowerShell runtime library. Check the library path and required export. Stop if the check or load fails. Stop if the effective user ID is zero. Complete this check before the credential helper and before staging. Keep the Windows checks. Tell the operator to use a process with a nonzero effective user ID.

This is an ASD-STE100-oriented action statement; no formal language/compliance certification is claimed. Root accepted the decision before releasing the shared writer.

## 6. Finite implementation and handoff proposal

Use an exact absolute path derived from the admitted `$PSHOME`, checked with existing `Assert-OrdinaryPath`. Use `NativeLibrary.Load(exactPath)`, `GetExport("SystemNative_GetEUid")`, and a no-argument Cdecl delegate returning `uint`. Release the explicit load reference in `finally`; do not cache the UID result or let a delegate outlive its module reference. No `SetLastError` inference is needed for this always-successful primitive. Throw on missing file/export, load, type, or invocation failure. No fallback to names, cached property, PATH, proc, or libc.

Place the Linux-only query at the current 1236 guard location. A small internal UID adapter can follow the existing native-adapter pattern; it must be callable before staging. Do not invoke `Get-OwnedPathIdentity` on a fictitious staging path merely to trigger its lazy type definition. The shared writer may put UID and FQ46 methods in one bounded adapter if both decisions are selected, but must keep their library/export qualification distinct. No general native-provider framework is needed. Existing `RuntimePathIdentity` and ownership/cleanup behavior must remain intact. FQ46 reader subsequently reported a narrower proposal that also loads exact `$PSHOME/libSystem.Native.so` and obtains `statx` through its dependency lookup. This can share the same bounded loader/lifetime pattern, subject to root qualification of that distinct export and dependency closure. It does not make FQ48 depend on the statx proposal or grant either proposal acceptance.

Suggested product scope: initializer, maintained driver, and README line 142. State "nonzero effective UID" in the public description/recovery text, rather than account spelling. No repository-origin literal or exception count change is needed. Existing 12-path PR scope and 16-path paired handoff contain these paths. Update the postlanding TF addendum for this selected repair; TF needs its own native qualification and tests. PS is not landed, no transfer increment or destination acceptance is due.

Root supplied fresh native capability evidence at `pr239-round5-native-capability`; this worker read and hashed its source, request, result and raw streams. Native **208f75/exit 0** ran an isolated network-none, read-only, cap-drop-ALL container as explicit UID1000, image **sha256:8bdc7722fc55e19fd3df48d8fddf4568a75d8792cfc4ee105c8a8173559362f4**. PowerShell **7.6.3/.NET 10.0.9** loaded exact **/opt/microsoft/powershell/7/libSystem.Native.so**, SHA256 **c19d793677718165b7affb35445b2a284100a27205cf5127a98fe0b92c8d0607**, resolved both exports, and returned actual EUID1000. Raw stderr is empty; result records the container absent. Result SHA256 **4bfcca89d04060335f884c43dc4a28a7e3039806851c8185ae791364317a4629**. This qualifies this exact runtime export/ABI path, not root refusal, live UID transitions, product guard ordering, the complete helper, or every runtime at the syntax floor. Root must execute the implemented proposal before local acceptance. Other unqualified deployments must fail closed. The gate samples current UID at its invocation; it does not isolate hostile same-process code that changes identity afterward, consistent with the existing trusted-host limit.

## 7. Meaningful regression, mutation and native test proposal

Proposed registration names below are recommendations, not tests written or run:

1. **`FQ48 Linux effective UID refuses zero before credential work`** — Materialize actual initializer definitions and the actual gate from current source with unique counted anchors. Stub only the UID acquisition boundary, not a copied condition. Cases return unsigned 0 and nonzero values; vary USER/LOGNAME and the synthetic name used by the old-name mutant. Require zero to throw the exact fixed UID diagnostic before a credential-helper sentinel, private Git/staging creation, channel opening/write, and curl/tar dispatch. Nonzero must reach a distinct deliberate credential sentinel, so unrelated preflight failures cannot masquerade as a positive. Use existing valid declaration/runner fixture setup; do not manufacture downloads.
2. **`FQ48 Linux UID guard removal is detected by the refusal oracle`** — Remove only the actual gate in a disposable source copy. With identical zero-UID fixture inputs, it must reach that sentinel; the original refusal oracle must fail on the mutant. A separate old-name mutant with a non-root alias and zero UID must also reach the sentinel and fail the oracle. Keep successful native completion distinct from intentional sentinel refusal; no broad nonzero-exit assertion alone.
3. **`FQ48 Linux effective UID binding fails closed`** — Run actual adapter/body with the production exact path on native nonzero-UID Linux. Compare its result with a separately qualified `/usr/bin/id -u` observer, used only by tests. Mutate only the required export to a nonexistent name; require pre-credential refusal with untouched channels/staging. Add a missing/linked library-path control by changing only the adapter's private fixture path. Assert fixed path/export anchors and no ambient-name fallback. Test the live call, not only source string presence.
4. **`FQ48 Linux native UID zero and renamed-account boundary`** — Root separately qualifies an isolated disposable Linux x64 process/container with EUID 0 whose actual NSS passwd name is not `root`, using a private container configuration only. Run the actual complete initializer on valid controlled inputs; require refusal before the credential sentinel, archive probes/download, staging, and publication. Record actual name/EUID and unmodified source hash. Run old-name/guard-removal mutants in the same isolated boundary and stop at the sentinel; require false admission there. Also record ordinary UID-0/name-root refusal and native nonzero positive. Never alter host passwd, users, permissions or root settings for this test. If a renamed-UID0 fixture is unavailable, retain this as pending; do not substitute environment strings and claim native renamed-account proof.
5. **`FQ48 Linux live UID query follows changes in one private host`** — Root qualifies a separate disposable native child able to change only its own EUID and restore it. Observe actual adapter results `0 -> nonzero -> 0` in the same host, checking each native setter status independently. Record public cached-property observations separately; the versioned source already establishes its cache. The final gate must refuse zero after the transition, and a cached-result or real-UID substitution mutant must fail the same oracle. Never change identity in the controller/test parent. Treat inability to establish the transition as missing evidence, not a passed skip.

For real-vs-effective discrimination, use that private child with real UID 0 and effective UID nonzero, then restore effective UID 0; compare the actual live query with both independent observers. A separately qualified live `getuid` substitution must false-refuse the nonzero-effective case, so the test proves the required field rather than generic root detection. No credential fill, network request or runtime archive execution is needed for these focused tests.

Generated PowerShell materializations must contain the real adapter and gate bodies, fixed library/export literals and the exact source mutations. Include them in root's source/syntax attribution and preserve raw diagnostics, including unrelated pre-existing warnings. Linux-native registrations must use the existing Linux gate. Windows can verify that the Linux query is not entered; retain actual Windows compatibility/curl/credential cases rather than pretending Linux UID queries run there.

Reuse `fixture`, valid declaration/runner setup, exact-anchor `foundationOnce`, native-completion assertions and existing sentinel/channel checks narrowly. `foundationFixture` builds archives and is appropriate only when retaining full successful acquisition evidence; do not expand it for simple early-refusal cases. Keep current F6 missing-inode-export behavior (3076–3087), R5 Windows compatibility refusal (3854–3864), FQ35/36/37, F10 controls (4379–4406), FQ40 actual archive-boundary tests and FQ45 askpass tests. A new early UID gate must not accidentally make retained positives refuse on ordinary Linux or change the F6 uncertain-staging assertion.

Static syntax, native focused boundaries, aggregate affected cases and required native hooks remain root-owned future gates. Prior Linux163, Windows822 and all11 evidence describe the old candidate and cannot certify new bytes. Keep the exact FQ32 retained-files limit and failed strict-controller result intact. Do not add A04 whole-initializer TLS/retry/channel or full recovery-loop completion claims.

## Outcome and limits

**Clear recommendation: F, 94.8/100, with E tied as an equivalent F-family variant.** No new material finding beyond FQ48 was identified in this bounded analysis. A secondary full canonical STYLE_GUIDE.md assessment of implementation bytes is unperformed because no implementation was authored; the shared writer and final reader retain that check. Exact current Linux runtime export/ABI qualification is root-observed; product refusal, live-transition and proposed regression tests remain unfinished. Root's decision, implementation, current-input validation, normal publication and exact-head review/CI gates remain required. No merge, landing, runtime or Terraform acceptance is granted here.

Root selection: F94.8, with E tied. Prefer the dedicated runtime export for its explicit contract and completed exact-runtime capability proof. Root read the complete report and sampled arithmetic. Removing the UID guard or deferring repair would abandon the required non-root boundary and is ineligible. No product or regression-test acceptance follows from selection. This file is the canonical finding record.

## Root native validation on the frozen initializer

The initializer was frozen at SHA25675bde4fbdc06f10b4b961dedb27751999af842ac887b82ed5116796af9ccfe3b. Independent source review found no actionable issue in the native adapter, UID gate, channel checks or retained staging cleanup. Root parser/C# check738106 exited0 on Windows PowerShell7.6.5/.NET10.0.11: both PowerShell files parsed and all three literal C# definitions compiled. This check did not invoke product functions.

Root then ran five isolated Linux container modes on the already qualified image8bdc7722, PowerShell7.6.3/.NET10.0.9. Each mode ran without network access, with a read-only root filesystem, a read-only synthetic passwd file and bounded private temporary storage. Only the two live-transition modes had CAP_SETUID. The initializer source was mounted read-only. The test credential helper threw a fixed sentinel, so these tests could not perform credential lookup, download or runtime staging.

| Mode | Actual observation | Result |
| --- | --- | --- |
| Renamed UID0 | Numeric UID0 with account name ci-uid-zero produced the exact UID refusal. | Original oracle passed. |
| Removed guard | The same UID0 reached the credential sentinel after only the gate predicate was removed. | Intended mutation control passed; original oracle failed. |
| Old name guard | The same UID0 reached the sentinel after only the old username predicate was restored. | Intended mutation control passed; original oracle failed. |
| Live effective UID | With real UID0, effective UID0/1000/0 produced getter0/1000/0 and refusal/sentinel/refusal. | All original oracles passed. |
| Real-UID getter | Changing only the export to getuid caused a false refusal at effective UID1000 and real UID0. | Intended mutation control passed; original oracle failed. |

Native sessions47277/6d0f89 and49294/d6fa4c exited0. All nine whole-initializer calls left the expected empty channel files unchanged and created no runtime staging. All five containers were absent at readback; no forced stop was needed. Host identity was unchanged. Root verified54 retained fixture files, including exact original/mutated source bytes and hashes. The private acceptance is recorded in execution state. This proves the frozen initializer's pre-credential UID boundary only. Actual credential behavior, acquisition, aggregate tests, hooks, final quality, public reviews, merge and paired delivery remain separate gates.
