<!-- markdownlint-disable MD013 -->
# FQ40: Bound compressed runtime downloads

- **Status:** Accepted
- **Owner:** A07 coordinator
- **Last Updated:** 2026-10-09
- **Scope:** PR239 finding 4232001891; ordinary preferred Linux/Windows and Linux recovery downloads.
- **Related:** [Decision process](../../../DECISION-PROCESS.md), [review finding](https://github.com/franklesniak/PSStyleGuide/pull/239#discussion_r4232001891)

The finding is valid. Published2b5514c7a0c35b55d002935dcd771a72be1b1dcf uses one `Install-ReviewedRuntime` download body for preferred Linux, preferred Windows and optional Linux recovery. It limits time/retries but not compressed bytes before digest/extraction. Recommend option G: a fixed64MiB native download ceiling, curl/libcurl8.5+ admission on Linux, preservation of Windows's existing curl8.5+ major8 policy, and an independent completed-file length check before hashing. This is a proposed selection for root validation/display/decision, not an implementation or release.

## Source validation and scope

`Initialize-CiToolchain.ps1` SHA256f79c560723233a22ce45a23602dcd1232fcd0fea949d8bae5d566592df43f57e and current driver2636b614af82374e5ca0c9836cf5037afcfb9a3ce25650f1fc6bee41793e3c08 match the published exports. Source1036–1052 creates the role directory, writes `preferred.zip`, `preferred.tar.xz` or `recoveryCompatibility.tar.xz` with curl, checks native status, checks ordinary path, hashes, then extracts. A bad endpoint can fill storage before its eventual digest refusal. This is an availability/resource gap; digest integrity still prevents executing different archive bytes. No exploit or disk-exhaustion run is claimed.

The later50000-entry/1GiB-expanded gates at812 and912 do not bound the compressed file. Private staging, fixed tool paths, anonymous credentials, TLS/HTTPS-only flags, first `--disable`, native exit checks and owned failure cleanup are useful separate controls. Windows already queries system curl version/help and admits major8/curl8.5+, HTTPS and SSL; Linux resolves `/usr/bin/curl` and refuses root extraction but does not query curl version/capability. Installed Node cannot supply the missing guard: downloading precedes its verification.

The only ordinary workflow callers are two `markdownlint.yml` calls with `-WorkflowDependencies` and two `agent-instructions.yml` calls also requesting `-InstructionDependencies`. All acquire preferred Linux through this body. Compatibility is Linux-only and opt-in; two role downloads are sequential. Windows acquires only preferred ZIP. Retain ordinary connect20/attempt180/retry2/retry-admission300/default transient selection. Do not copy Copilot's attempt120/retry3/all-errors policy or change its independent bodies under this finding. No schema, digest, dependency engine, workflow selector or direct Node caller change is needed.

## Primary evidence and capability distinction

The [curl8.4 option documentation](https://raw.githubusercontent.com/curl/curl/curl-8_4_0/docs/cmdline-opts/max-filesize.d) records a running-transfer cutoff for unknown sizes beginning8.4. The [current manual](https://curl.se/docs/manpage.html#--max-filesize) gives native code63 for excess size; zero disables the limit and the last repeated value wins. Current documentation also distinguishes later automatic HTTP decompression changes. This command does not use `--compressed`; archive decompression stays behind digest and the existing extraction gates.

There is a relevant implementation distinction beyond the review's suggested8.4 floor. The [8.4 transfer loop](https://raw.githubusercontent.com/curl/curl/curl-8_4_0/lib/transfer.c) de-chunks/writes before updating the running counter, and [8.4 progress code](https://raw.githubusercontent.com/curl/curl/curl-8_4_0/lib/progress.c) refuses when the count exceeds the maximum. Thus8.4's documented stopping threshold should not be advertised as an exact no-extra-byte file ceiling for chunked transfers; this is source-derived inference, not a new native result. In [8.5 `cw_download_write`](https://raw.githubusercontent.com/curl/curl/curl-8_5_0/lib/sendf.c), body output is clamped to remaining maximum before client writes, and excess reports filesize failure. That supports choosing8.5 for both implementations rather than building a new binary-streaming process framework. Require the executable and reported libcurl implementation versions, not only an advertised help option from an older library.

The [Ubuntu24.04 official package](https://packages.ubuntu.com/noble/curl) is based on8.5.0. This matches the ordinary hosted runner family; it is compatibility context, not proof of the actual future image/binary. Linux may admit later compatible numeric major versions; preserve Windows's already selected major8 restriction. Root must bind and exercise the actual supported Linux/system Windows binaries. No installation or fallback is proposed.

Root supplied an independent finite capability experiment, `pr239-round3-validation/curl-streaming-proof/result.json` SHA256c7a2c8d8ec76754f6111b5bce36bc82b48b677a42bfdeeb2735b396146e0b62c. System Windows curl8.21.0 tested known length, close-delimited and chunked8191/8192/8193 against8192: below/exact completed; excess returned63, writing0 for known length and8192 for unknown sizes. No-limit close65536 wrote65536. A lying `Content-Length:4` with65536 sent bytes returned0 and wrote4. This demonstrates why the digest must remain mandatory. Eleven cases closed naturally. It proves that binary's narrow HTTP capability only, not this product, TLS flags, Linux or the minimum8.5 version.

## Cap choice

Existing raw archive facts come from the immutable `PSStyleGuide-R5-real-archive-readiness-20261005/archive-catalog.json`; they remain historical digest-matched observations, not fresh downloads. Current official [24.18.1 checksum list](https://r2.nodejs.org/dist/v24.18.1/SHASUMS256.txt) and [22.23.3 checksum list](https://r2.nodejs.org/dist/v22.23.3/SHASUMS256.txt) match all three current pins. Official directory listings show approximately32MB Linux24,37MB Windows24 and31MB Linux22; the exact values below use the preserved raw catalog, not rounded listing labels.

| Current archive | Exact compressed bytes | Headroom under67108864 |
| --- | ---: | ---: |
| Preferred Node24.18.1 Linux/x64 tar.xz | 31525884 | 35582980 |
| Preferred Node24.18.1 Windows/x64 ZIP | 37177316 | 29931548 |
| Recovery Node22.23.3 Linux/x64 tar.xz | 31001304 | 36107560 |

32MiB would reject the current Windows archive.40MiB leaves only4765724 bytes over that archive;48MiB leaves13154332.64MiB supplies about80.5% headroom over the largest current selected file while keeping each untrusted body small relative to the1GiB expanded gate.128MiB doubles exposure without a current need. A shared fixed64MiB avoids per-platform metadata drift and a schema transition. Future reviewed archive updates must still fit the cap or obtain a separately reviewed bound change; server length must never raise it. At most two ordinary archive files can be retained, so the compressed-file allowance is128MiB, separate from expanded trees, npm installs, headers/process buffers and private transport namespace caps. This is not a claim that the whole job uses only128MiB.

## Options listed before evaluation

A: retain time/retry/digest only. B: check length after download. C: trust HEAD or Content-Length. D: rate limit with existing timeouts. E: use operating-system quotas or watchers. F: require curl/libcurl 8.4 with native cap and post-check. G: require curl/libcurl 8.5 with native cap and post-check. H: own a bounded binary writer around curl. I: replace curl with HttpClient. J: add exact sizes to the declaration plus streaming enforcement. K: use range requests. L: require preinstalled or offline archives. The rubric and full table below evaluate these options; permutations are discussed after the table.

## Stakeholders, constraints and rubric

CI operators need predictable storage use and prompt native refusal. Maintainers need readable, stable acquisition semantics and useful diagnostics. Contributors need supported Windows/Linux setup without new installs or hidden configuration. Security owners need a bound independent of server declarations before integrity parsing. QA needs actual unknown-length and causal mutation witnesses without disk stress. Recovery owners need a separately verified Node22 and no partial publication. Peer maintainers need one shared algorithm with unchanged repository exceptions. Audit custodians need truthful minimum-version, digest and old-result attribution.

Hard constraints: enforce a running bound without trusting Content-Length; cover all three current role/platform paths; retain HTTPS/default-config/native status/digest/extraction/cleanup/publication gates and ordinary retry semantics; keep the fixed cap outside caller-controlled declarations; use no PATH fallback or installed Node bootstrap; obtain permanent causal/native controls. An option failing a hard constraint cannot win by its arithmetic score.

This finding's distinct weighted rubric is established before scoring: correctness28%, resource safety27%, supported-platform usability18%, reviewability/causal verification15%, operational reliability7%, implementation effort5%. Each dimension uses1(poor)–5(strong). Total is the sum of weight×score/5. Correctness, safety and usability total73%; effort cannot override them. Effort includes ongoing fixture/metadata upkeep.

| Option | Correct | Safety | Usability | Review/QA | Reliable | Effort | /100 | Constraint/result |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A Keep time/retry/digest only | 1 | 1 | 5 | 2 | 2 | 5 | 42.8 | No compressed running bound |
| B Add only a post-download length check | 2 | 2 | 5 | 4 | 3 | 5 | 61.2 | Too late to prevent storage consumption |
| C Require HEAD/Content-Length before download | 2 | 2 | 3 | 3 | 2 | 4 | 48.6 | Missing/lying/changed response length defeats it |
| D Rate limit plus existing timeout | 3 | 3 | 3 | 3 | 2 | 4 | 59.6 | Indirect throughput budget; unnecessary slowdown and retry accounting |
| E OS file/volume quota, watcher or shell ulimit | 3 | 4 | 2 | 2 | 3 | 2 | 57.8 | Cross-platform/sibling effects and polling overshoot; no adequate portable per-file interface |
| F curl/libcurl8.4+ fixed native ceiling plus post-check | 4 | 4 | 5 | 5 | 4 | 5 | 87.6 | Addresses finding; chunked file-write boundary less exact at minimum |
| G curl/libcurl8.5+ fixed native ceiling plus post-check | 5 | 5 | 4 | 5 | 5 | 4 | 95.4 | Recommended; existing Windows floor, supported Linux family |
| H Curl stdout through owned bounded binary-stream writer | 5 | 5 | 3 | 3 | 3 | 1 | 80.0 | Viable; new process/pipe/cancellation/retry machinery, must avoid PowerShell text conversion |
| I Replace curl with HttpClient bounded stream | 4 | 4 | 3 | 2 | 3 | 1 | 66.0 | Viable after redesign; new TLS/proxy/redirect/retry/bootstrap contract |
| J Trusted exact archive sizes in schema plus native/stream bound | 5 | 5 | 3 | 4 | 4 | 2 | 85.4 | Viable; extra schema/reader/update coupling adds no necessary bound benefit here |
| K Range request/first-N bytes then digest | 2 | 2 | 2 | 2 | 2 | 4 | 42.0 | Server may ignore Range; truncation alone breaks valid digest and is not local enforcement |
| L Verified preinstalled cache/offline-only provision | 5 | 5 | 1 | 3 | 2 | 1 | 71.4 | Changes independently usable acquisition; moves rather than repairs this path |

Options exhaust the relevant enforcement sites: no-change, after-write, remote size/range, throughput, operating-system, existing native transfer, local stream ownership, replacement transport, trusted declaration and elimination/offline provisioning. Trusted size declarations alone inherit C's failure; J includes actual running enforcement. Native bound alone lacks the independent accepted-file postcondition retained in F/G.

## Proposed selected instructions in controlled English

1. Define one script-owned maximum of67108864 compressed bytes. Do not expose an override or derive it from JSON, environment or HTTP headers.
2. Add `--max-filesize 67108864` exactly once to the shared download argv. Keep first `--disable`, every existing TLS/time/retry/output argument, one fixed URL and the immediate native status check.
3. Preserve Windows system-path, writer/DACL, PowerShell7.6.5, major8/curl8.5+, HTTPS/SSL and existing option gates. Add the filesize option to required capabilities and require reported libcurl8.5+ for this streaming contract.
4. On Linux, query the exact `/usr/bin/curl` with first `--disable`. Require successful version/help queries, unambiguous numeric curl and libcurl versions of at least8.5.0, HTTPS/SSL and all selected options including max-filesize. Accept later compatible numeric versions on Linux. Refuse missing, malformed, ambiguous, old or unsuccessful capability results before any transfer.
5. Place Linux queries after the existing mandatory child-environment sanitation in the owned try, before the first runtime install. Keep credential verification before downloads and root refusal intact. This preserves occupied-stage, identity and inherited WhatIf refusal before queries, and avoids starting synthetic Node query adapters with inherited startup selectors. Do not move or weaken existing sanitation to accommodate tests.
6. After native success and the ordinary-file check, reject file length greater than67108864 before `Get-FileHash`. Retain exact digest verification and all extraction checks. Code63 follows the ordinary native failure path; no recovery install, ready.json, channel append, dependency execution or success result may follow it.
7. Keep the existing ownership-checked cleanup. Preserve any uncertainty warning and failed staging evidence. Do not swallow native failures or add retries for filesize errors.
8. Update runtime documentation and the focused permanent controls below. Root validates/displays/selects this proposal before any source edit. New source-bound review/catalog/syntax/native evidence follows the final freeze; old whole-initializer results do not authorize new bytes.

## Permanent controls and exact fixture closure

Use small finite loopback bodies, not disk-exhaustion stress. Assert the production flag/value from actual source before any one-match test-local scaling. For unknown-size behavior, scale only its numeric ceiling to8192, retaining the actual shared argv and native implementation. Also exercise the exact production67108864 value against an oversized declared header without sending a large body. This proves fixed production binding plus native small-threshold behavior; do not label it a64MiB native body transfer.

| Required control | Permanent discriminator |
| --- | --- |
| Known-length8191/8192/8193 | Below/exact native0 and exact bytes; excess native63 before digest/extraction, zero body output on qualified binaries. |
| Close-delimited8191/8192/8193, no Content-Length | Below/exact native0; excess native63 and file≤8192. Removing the native flag must write the complete finite excess body and fail the unchanged oracle. |
| Chunked8191/8192/8193, fragmented writes across boundary | Same limit/code/file oracle; no dependence on header length. Include one chunk crossing the boundary. |
| Production header67108865, no payload | Actual argv67108864; native63, no digest/archive dispatch/publication. No large allocation required. |
| Lying high length | Header above ceiling but short body refuses with63; do not trust short actual delivery to override declared refusal. |
| Lying low length | Header4 with larger sent body may produce native0/file4. Require digest refusal and no extraction/publication; do not incorrectly require63 for bytes outside HTTP message framing. |
| Truncated response within cap | Preserve native partial-file failure18, no digest/extraction; retain existing EOF tests. |
| Chunked body with misleading Content-Length | Bound actual de-chunked body or reject framing. Require bounded output/nonzero refusal; do not force63 for a parser-level rejection. Never weaken to header-only checking. |
| Preferred then oversized recovery | First role may complete locally; second refuses and leaves both runner channels byte-exact prior content, no ready/success or dependent code. Reuse existing failed-stage ownership/cleanup assertions. |
| All three role/platform dispatches | Exact fixed filesize argument for Linux preferred/recovery and Windows preferred; no unsupported Windows recovery. Positive tiny digest-matched archive remains accepted through existing fixtures. |
| Fake curl ignores limit and returns0 | A test-local small-ceiling file with matching digest but length+1 must hit the postcondition before hash/list/extract. Removing that check must fail its unchanged phase oracle. This is product postcondition proof, not native curl capability. |
| Capability boundaries | Linux8.5 and later compatible positives;7.x/8.3/8.4 negatives; missing/duplicate/malformed curl or libcurl version, libcurl8.4 behind curl8.5, failed query, absent max-filesize, missing HTTPS/SSL. Windows8.4 and major9 retain refusal. Unsupported capability must not count as a download. |
| Causal native mutations | Delete filesize, set0, raise scaled ceiling beyond body, or remove minimum capability gate; each has a distinct unchanged small-body/admission oracle. Preserve default curlrc denial, endpoint/argv assertions and true completed-native witness. Watchdog98/signal/null status is never filesize acceptance. |

Exercise actual native boundaries on qualified Linux and system Windows under existing transports. Extend the fixed native witness mode map only for named filesize-refusal cases with expected63; keep exact native command identity, integer status, null signal, absent error and ordinary bounded canonical record checks. Keep successful/truncated/lying-length outcomes in their own exact modes. A Windows witness must bind the actual system curl path rather than falsely naming `/usr/bin/curl`. Whole preferred/recovery product refusal and cleanup execute on Linux; extracted exact shared Windows download/admission boundary must be labeled narrowly if a whole Windows fixture is unavailable. Keep platform skips truthful. No new network authority or controller framework is implied.

Eight ordinary Linux curl constructors in current driver need explicit query handling: runtime rejection995–1000; runtime authentication1090–1094; permission-preflight1146–1150; `ordinaryDeclarationFixture`2677–2682; actual curl transport3275–3288; compatibility/archive3370–3375; `foundationFixture`3812–3819; `foundationCurlCell`4208–4221. Six synthetic adapters must return exact honest fixture version/help only for exact query argv before download log, output path, role or injected-action handling. Two actual-curl adapters must forward query argv unchanged to the real fixed curl and return its real result; they must not apply URL/time/protocol transforms or emit transfer witnesses for queries. Query-native failure tests remain distinct. Preserve selector observers, inherited preference tests and all original bad-mode outcomes. No production gate is replaced by a fixture bypass.

Affected consumers include F5 schema/dispatch/selector/WhatIf controls, F6 identity/cleanup, F8 actual transport/witness, compatibility/archive, F10 foundation/storage/ownership, F11 actual archive, F12/F14 native retry/causal controls, F13 mutations, FQ23 restoration, FQ30 declarations and FQ35–37 foundation record/output cases. Retain causal oracle bodies; refresh generated forms embedding changed initializer or adapters. FQ38's current dependency-command anchors remain exact because this proposal changes download/admission only. Windows writer-caller sentinel fixture3686–3695 already stops at the existing tool/capability boundary; add filesize capability negatives without moving its writer gate. Copilot wrappers/readers and four later direct Node consumer bodies do not require edits or routine reruns solely for this ordinary download change. Root derives the final affected-name census from authored bytes, then runs affected Linux coverage, full maintained Windows aggregate and all eleven configured hooks under accepted controls.

The likely product change is bounded to initializer, CI-helper tests and runtime README. A schema-size alternative would instead enlarge the paired reader/validator closure and is not selected. Root retains source edits, capability/native qualification, final staged-input binding, decisions, counters, public replies and review/CI/merge authority. This worker only read source/data and primary web research. No product/native/Git/controller/public operation or new authority occurred.

## Root selection and implementation

Root read the complete proposal (030ee3), verified both sealed assets, inspected curl 8.5 cw_download_write, and displayed the twelve options before the distinct rubric and full score table. Root selected G (95.4/100) on 2026-10-09 before changing product source. The root selection supersedes the proposed-selection language in the source analysis. Implementation 199d76/48f3ef adds one script-owned constant, intMaximumRuntimeArchiveBytes = 67108864. The shared argv emits that value through --max-filesize; the completed-file check uses the same constant before hashing. Assert-CurlCapabilities is shared by both platforms. The Windows call retains its original phase; the Linux call follows mandatory environment sanitation. No retry, TLS, digest, extraction, cleanup or publication control was removed. The runtime README states the bounds and limits. Initializer SHA256 42a9b1155e0c78e1c2703784f924cea94a46b4c5a1e8bbc02204a2b77d4154f4. Native PowerShell 7.6.5 parsing passed with zero errors (48f3ef). Maintained adapter updates, causal tests, actual affected runtime validation and independent final quality remain pending; no runtime acceptance is claimed for these new bytes.

Native mechanism evidence, 2026-10-09: root ran eleven finite loopback controls with Windows system curl/libcurl 8.21.0 and an 8192-byte test limit. Known-length, connection-close and chunked bodies at 8191 and 8192 bytes succeeded. The corresponding 8193-byte bodies refused with native code 63; unknown-length output stayed at 8192 bytes. An uncapped 65536-byte control succeeded. A lying Content-Length of 4 caused native success with only 4 bytes, which confirms why exact digest verification remains necessary. The server closed normally and command 257a7f exited 0. Result SHA256 c7a2c8d8ec76754f6111b5bce36bc82b48b677a42bfdeeb2735b396146e0b62c is bound in execution-state.json. This mechanism check does not prove the production helper, HTTPS, Linux, minimum curl 8.5 or a full-size 64 MiB transfer. Those affected maintained checks remain separate gates.

Maintained regression integration, 2026-10-09: root read the full frozen FQ40 patch, report and evidence, then verified all three sealed assets. Eleven exact hunks produce isolated driver edbe2b202968c0fc8be9d02d662e8b96ca9c8caf5eb02765c848494108da6d56 from baseline2636. Root preserved the exact FQ39 insertion and produced composed driver d416421a4504532b53a31119ff9b0e840498abd0f2bc5688a0bc71576b310fc4 (f66df3). Node syntax e95b22 and diff check c58010 passed. The packet adds 23 registrations and updates eight curl adapters; the following independent-review correction adds one more. These are implemented tests, not executed acceptance results.

Fixture review note: the proposed native63 error pattern was over-escaped, and a capability-mutant assertion could count a child failure as an oracle rejection.
Cause: JavaScript/RegExp escape layers and an assertion wrapped both execution and evaluation.
Fix: correct the literal escapes and complete the native child plus valid result rows before the oracle assertion; also enforce the declared combined output cap.
Test: static data checks and whole-module syntax passed; final native execution remains pending.
Evidence: frozen patch369ee43d, report e3dea2e5 and root source integration f66df3 preserve the correction.

Selected-control note: independent reviewer fq18 found that separate chunked and lying-length tests did not cover their selected combination.
Cause: the server fixture had no response with both Transfer-Encoding and Content-Length.
Fix: add one 8193-byte chunked response with a false length of 4; require bounded output, no listing and completed curl refusal 8 or 63, as defined by the [curl error reference](https://curl.se/libcurl/c/libcurl-errors.html).
Test: whole-module Node syntax bff893 and diff check c5884c passed; actual native execution remains pending. Transport failures and timeouts cannot satisfy this oracle.
Evidence: source-freeze-v2.json preserves the exact inverse to d416; helper bytes and FQ39 tests are unchanged. New driver29573f2449641d5f80e494ee416fa12c87552f91205c59a72c8a7b3440f0d301 adds 30 total registrations over the published driver; final aggregate projection is 816 (Windows377 pass/439 platform skips), not an executed result.

## Current maintained Linux results

All24 new download registrations passed on 2026-10-09 against initializer a64a1787 and driver7b360206 at staged index27cdfb38. The immutable Linux image used curl/libcurl8.5.0. Each root acceptance verified its exact selected names, native0, zero skips, unchanged inputs and strict process/scratch cleanup.

| Group | Tests passed | Native session and terminal | Accepted receipt |
| --- | ---: | --- | --- |
| Capability | 2 | 61539;932313 | [90ed280b](current-main-validation/pr239-round3-download-capability-runtime.json) |
| Complete initializer | 5 | 44414;dc1114 | [2bec42a7](current-main-validation/pr239-round3-download-whole-runtime.json) |
| Actual download boundary | 17 | 32262;644ee6 | [42cc8f2f](current-main-validation/pr239-round3-download-boundary-runtime.json) |

Boundary tests passed for known-length, connection-close and chunked bodies below, at and above the test limit. Misleading lengths, partial responses and combined chunked/Content-Length framing refused as required. The production constant rejected a declared oversized response. The tests that remove the filesize flag, set it to zero or raise the cap detected the weakened control. Finite byte-boundary bodies use an8192-byte test cap; this is not a claim that every framing case transferred64MiB, or a new internet/TLS qualification. Existing digest, TLS, retry, archive and cleanup controls remain required.

The selected singular helper name is now Assert-CurlCapability, as recorded in [FQ41](FQ41-CURL-HELPER-SINGULAR-NOUN.md). Current syntax and independent source review are accepted. Earlier mechanism and driver records above retain their original input scope.

For the final driver c57e2447/index cacf070b, the24 Linux download results remain valid under the separately accepted current-input reuse record. The changed FQ40 assertion is Windows-only; the Linux child scripts, native calls and exact command comparison remain unchanged. All156 affected Linux registrations are accepted and independently reconciled.

Fresh Windows native65052 ended0/53982f. The [strict aggregate receipt6557808f](current-main-validation/pr239-round3-v5-windows-aggregate-runtime.json) accepts816 registrations:377pass,439 explicit platform skips, zero failures/cancellations/TODO, unchanged guards, empty unforced Jobs and removed private TEMP. All17 download-boundary/framing/cap/mutation assertions pass with Windows curl/libcurl8.21.0. [FQ43](FQ43-WINDOWS-CURL-FIXTURE-IDENTITY.md) records the Windows path-identity fixture correction; it changes no production download rule. Independent review confirmed all17 current passes against the earlier failed names. The [final hook acceptance](current-main-validation/pr239-round3-v5-windows-precommit-runtime.json) confirms11 passes, zero skips, unchanged inputs, empty unforced Jobs and removed private TEMP. The [normal commit](current-main-validation/pr239-round3-v5-normal-commit.json) is11224a2f58e2cb1e2ffb3ab443ccc83dd0822950; staged, repository and nested Markdown hooks passed at native0/c6b968. The public lifecycle remains pending.
