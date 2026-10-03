<!-- markdownlint-disable MD013 -->
# A04 read-only download preparation

Current continuation,2026-10-03: D08 has resolved the A03 owner choice as P; PS A02/A07 sources are accepted. [RESULT.md](RESULT.md) records the current425795b/06ad4f7 input refresh. The download findings and selections below still apply to unchanged helper bytes. Implementation follows accepted A03/A07 interfaces; no new owner choice is pending. The original prerequisite and authority descriptions below are dated preparation history, not current blockers.

This is a bounded proposal, not A04 acceptance. No product, planning, native object or host setting changed. Requested route: `gpt-6-astra/high`; effective metadata is unavailable. Transfers remain 0/8. No PR clock exists. A01 is accepted; A02, A03 and A07 implementation prerequisites remain incomplete. The A03 maintenance-enforcement disposition and all separate protected/settings authority remain pending.

## Current native inputs and caller census

[native-evidence.json](native-evidence.json) records authenticated main refs, trees, 30 raw Git source identities/modes, and current PS213 body/all comment pages. PS is `48f4d8a36c8faceee12afac78aaecea0d176125d`; TF is `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`. Both match the delegated pins. PS213 is open with zero comments; its current body already distinguishes the retired three inline sites from the active helper. Its historical intentionally stopped curl8.5 probe remains an interrupted characterization, not a pass.

Each repository has one ordinary archive command in `.github/workflows/Initialize-CiToolchain.ps1`. Each has four callers: `markdownlint.yml` jobs `policy` and `markdownlint`, plus `agent-instructions.yml` jobs `accepted-policy` and `candidate-tests`. The lint jobs request workflow dependencies; both instruction jobs request workflow and instruction dependencies. Accepted-policy uses accepted-base source; candidate jobs have empty permissions. The Linux helper invokes fixed `/usr/bin/curl`, then verifies SHA-256 before fixed `/usr/bin/tar`, runtime execution, permission-limited preflight or npm installation. Build has no current ordinary Node download. Do not restore the retired body-identity workflow.

The separate Copilot installer has `connect20 / max120 / retry3 / retry-max300 / retry-all-errors`. It is comparison evidence, not another ordinary caller or permission to copy its retry class. Current ordinary flags are `connect20 / max180 / retry2`, with no retry-start budget. Both pin Node24.18.1/npm11.16.0 and Linux archive SHA-256 `d6c664df3f3f61458e8c277585571328522d705166723a7c7823a9253a4d15a0`. No runtime, origin, digest or npm policy change is selected.

Read inputs: STATUS first; README; LOOP-POLICY; ROUTING-AND-PARALLELISM; A04; DECISION-PROCESS; originals352–378; accepted A00/A01 dispositions/inventory; A03 design and R01/R02/R03/R07; A07 preparation; current PS213; full paired initializer/credential helper and relevant workflow, classifier, helper-test, validator/contract/case sources. A02's mutable candidate was not used as an accepted input.

PS151 was also refreshed, including all three comments. Its historical D90/D91/D94 decisions remain applicable to the current preflight: duplicate decoded JSON-member rejection in five existing inputs, accidental-operation permission checks only, and actual-caller fixtures without internal-return-line matching. Its [closure5943329047](https://github.com/franklesniak/PSStyleGuide/issues/151#issuecomment-5943329047) expressly excludes issue213. Keep that historical evidence separate from the27 original contracts' current acceptance and from any present reviewer-substitute authority.

## D04-1: add a useful finite retry-start budget

**Validation.** The surviving command already limits each connection to20 seconds and each attempt to180 seconds, with at most two retries. It does not cap server-directed waiting across attempts. A local HTTPS503/Retry-After4 followed by valid bytes completed after4.61 seconds PS and4.59 seconds TF. Scaled max-time1 stalled transfers took6.50/6.47 seconds across three attempts, which demonstrates that the per-transfer clock restarts. No production endpoint failed or was modified.

The curl manual distinguishes connection, per-transfer and retry-start timers. An admitted transfer may outlive the retry timer. Default curl configuration must be disabled separately. [curl options](https://curl.se/docs/manpage.html#--retry-max-time). Curl's own retry guide describes transient retry classes and backoff. Keep those classes; a partial EOF is not made retryable merely by setting `--retry 2`. [curl retry guide](https://everything.curl.dev/usingcurl/downloads/retry.html).

**Stakeholders.** Maintainers and contributors need transient recovery without long opaque waits. CI operators and the cost owner need a bounded failed download that leaves time for diagnostics. Network/platform operators need native TLS/network causes preserved. Dependency and supply-chain security engineers, independent reviewers and downstream guide users need the existing digest-before-execution boundary. Incident operators need partial downloads to fail truthfully. Windows contributors need honest Linux-only test limits. This does not change Terraform recovery authority, application/customer data, localization or accessibility behavior.

**Options before scoring.** N: keep existing flags and job timeout only. Z: disable retries, retain20/180. R: retain20/180/retry2 and add retry-max300. T: tighten to10/60/retry2/retry-max120. L: retain20/180/retry2 and add retry-max600. W: R plus a new outer480-second process watchdog and termination implementation. Copying Copilot's extra retry and all-error policy is an additional unproved behavior change, so it is not a smaller R. Removal of official verified download in favor of ambient Node fails the fixed-runtime hard constraint. A separate service/framework is unnecessary; deferral preserves N until prerequisites clear.

**New rubric.** Scores1–5, higher is better. Finite and accurately described failure35%; legitimate transient recovery25%; preserved supply/failure semantics20%; simple maintenance15%; low churn5%. Total=`sum(weight*score)/5`. Hard constraints: official pinned supply, digest before extraction/execution, fixed tools, no swallowed native failure, no candidate authority expansion. A score cannot claim a strict wall-clock kill from a retry timer.

| Option | Failure35 | Recovery25 | Semantics20 | Maintenance15 | Churn5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 1 | 4 | 4 | 5 | 5 | 63 |
| Z | 3 | 1 | 5 | 5 | 4 | 65 |
| R | 4 | 5 | 5 | 5 | 5 | 93 |
| T | 5 | 2 | 5 | 4 | 3 | 80 |
| L | 3 | 5 | 5 | 5 | 4 | 85 |
| W | 5 | 5 | 4 | 2 | 2 | 84 |

**Selection.** Use R. Keep the20-second connection cap. Keep the180-second attempt cap. Permit at most two retries. Add `--retry-max-time 300`. Keep native transient retry selection. Do not add `--retry-all-errors`. Keep the current native exit diagnostic and digest check. Do not retry a digest mismatch.

The300-second value is an engineering budget, not a measured availability optimum. It preserves the existing attempt allowance, accepts short transient waits, shares the existing Copilot retry-start scale and leaves substantial room in the shortest current20-minute job for later work. It is not a300-second command deadline. For inspected curl8.5 and8.21 algorithms, a conservative planning envelope is300+180+2+1=483 seconds: retry admission, one final transfer, the maximum default backoff with two retries, and older whole-second Retry-After arithmetic margin. This is a nominal algorithm envelope plus process/scheduling overhead, not an OS termination guarantee. The connection cap is inside the transfer cap; do not add20 again. A strict outer deadline would require W and its own kill/cleanup tests; no supported caller currently requires that extra mechanism. [curl8.5 implementation](https://github.com/curl/curl/blob/curl-8_5_0/src/tool_operate.c#L443-L565), [curl8.21 implementation](https://github.com/curl/curl/blob/curl-8_21_0/src/tool_operate.c#L347-L407).

**Option experiments and limits.** The extracted PS command with only retry-max300 added refused Retry-After600 with native22 in0.625 seconds. A scaled retry-max2/max3 case took4.50 seconds, correctly exceeding the retry timer while a transfer was active. Retry-max3/max1 exhausted after two stalled attempts in3.52 seconds. These experiments support the selection but do not accept a proposed product candidate or Ubuntu curl version. Rerun actual whole-helper fixtures on its actual Ubuntu runner and record curl version before claiming the envelope there.

## D04-2: exclude default curl configuration

**Validation.** Both ordinary commands omit curl's first-argument `--disable`. The credential helper excludes Git configuration and tokens; initializer normalization excludes npm configuration. Neither disables curl's default file. A process-local `CURL_HOME/.curlrc` containing only a dummy header made both native extracted segments send that header. Both still passed the digest gate. Adding first-argument `--disable` removed the header in both. Thus fixed executable and digest checks do not establish curl option isolation. No live credential leak or hostile CI home writer was demonstrated. The consequence is ambient command behavior outside the reviewed command, including possible additional curl options; this is a concrete configuration boundary, not evidence of compromise. [curl configuration rules](https://curl.se/docs/manpage.html#--disable).

**Stakeholders.** CI/platform maintainers and contributors with local curl preferences need deterministic installation. Supply-chain security and credential owners need options from an unrelated default file excluded. Reviewers and incident operators need a small visible boundary that can be tested. The sole maintainer must not maintain platform-specific file-search replicas. No new external account, permission, private data store or human recovery gate is involved.

**Options before scoring.** N: retain loading and document the assumption. Q: put `--disable` first. H: search and reject known curlrc paths. E: build a replacement home/environment sandbox. F: write a new curl wrapper/config schema. H duplicates curl's evolving platform search rules. E alone must cover every selector and fallback; it is not a smaller Q. Removing curl also requires a new transport/digest/error implementation and is outside the useful finding.

**New rubric.** Reviewed-option determinism45%; credential/config boundary20%; stable timing semantics15%; legitimate operation15%; low churn5%. Scores1–5 and the same arithmetic formula. Hard constraints: do not edit/delete user configuration or host trust; do not weaken TLS/digest; use the documented first-argument semantics. Environment-based proxy/CA settings remain a separate trusted-runner assumption; Q is not total environment isolation.

| Option | Determinism45 | Boundary20 | Timing15 | Operation15 | Churn5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 1 | 2 | 2 | 5 | 5 | 43 |
| Q | 5 | 5 | 5 | 5 | 4 | 99 |
| H | 3 | 4 | 3 | 2 | 2 | 60 |
| E | 4 | 4 | 4 | 2 | 2 | 72 |
| F | 5 | 5 | 5 | 2 | 1 | 87 |

**Selection.** Use Q. Make `--disable` the first argument after the fixed curl executable. Do not clear or alter host configuration files. Retain all explicit supply/TLS/output arguments. Add one actual configuration-contamination fixture. Assert that no dummy header or additional fixture URL from the default file is used. An argument-order assertion supports that behavioral fixture; it does not replace it. The separate Copilot source has the same absence; refer that independently to A03/A07 before changing its platform contract. This assessment does not silently expand A04 to Copilot.

## D04-3: test the current caller and converge its shared code

**Validation.** Existing `Test-CiHelpers.test.mjs` has useful Linux-only actual-helper tests for native failure19, wrong bytes, runtime/schema/staging rejection, valid digest extraction, versions, restricted preflight and npm normalization. Ordinary tests do not verify retry flags or real Retry-After/stall/exhaustion behavior; the detailed flag assertions apply to Copilot. `Validate-WorkflowPolicy.mjs` checks exact initializer call shape and native failure handling in its supported workflows. It does not interpret the initializer's curl source. The classifier routes the initializer and tests into maintenance; success there is not approval. R02/R07 remain applicable. R01's retired body writer has no active download consumer. R03's enforcement loss remains A03's unresolved boundary.

The initializers differ only in equivalent environment-variable naming/message and package-engine object access. There is no supported language-specific difference. Their download/exit/digest segment is identical. Keep no generic repository exception for this helper.

**Stakeholders.** CI/security test authors, both maintainers, contributors, independent reviewers and incident responders need tests that detect the real failure without flaky external outages. CI cost owners need short deterministic fixtures. A03/A07 integrators need one common helper and narrow serialized edits. Platform maintainers need actual Linux evidence, not Windows skip counts. No new customer-facing or privileged API is introduced.

**Options before scoring.** N: existing tests only. S: add source-string/flag assertions only. C: extend existing actual-helper fixtures with captured argument checks, bounded loopback curl cases and targeted negative mutations; use one common initializer. R: restore old inline/reference/body-identity fixture machinery. A new general network-test framework is not needed for C. One unbounded real-outage test is ineligible.

**New rubric.** Observable regression detection40%; actual-caller coverage30%; deterministic runtime15%; maintenance burden10%; low churn5%. Scores1–5. Hard constraints: preserve native failure and digest ordering; test real caller transitions; no live outage; timeout/skip/interruption is not success; keep runtime pins and supported platform explicit.

| Option | Detection40 | Caller30 | Runtime15 | Burden10 | Churn5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 2 | 3 | 5 | 5 | 5 | 64 |
| S | 2 | 2 | 5 | 4 | 5 | 56 |
| C | 5 | 5 | 4 | 4 | 3 | 93 |
| R | 3 | 2 | 2 | 1 | 1 | 45 |

**Selection.** Use C. Extend the existing helper harness. Keep its fixed-tool replacements and actual control flow. Use one local server and targeted cases from [threat-map.md](threat-map.md). Keep production constants fixed. Let a fixture wrapper validate original arguments before shortening only time values and substituting its loopback endpoint. Never expose a production timeout override or arbitrary URL parameter for testing. Test the unchanged production retry-max300 value against Retry-After600, which fails promptly. Keep a watchdog outside each test and fail if it fires.

Use the accepted PS initializer as the common implementation after A03/A07 prerequisites. Carry forward all accepted predecessor changes. Port only needed equivalent TF differences when the paired lifecycle reaches TF. Use existing A03 common tests/finite role configuration; do not copy whole test or instruction-validator files. Preserve accepted TF required-check name `verify`.

## Concrete proposed edit and integration boundary

The ordinary command becomes this in both repositories:

```powershell
& /usr/bin/curl --disable --silent --show-error --fail --location --proto '=https' `
    --proto-redir '=https' --tlsv1.2 --connect-timeout 20 --max-time 180 `
    --retry 2 --retry-max-time 300 --output $strArchive $strUrl
```

Primary path: `.github/workflows/Initialize-CiToolchain.ps1`. Coupled tests: the ordinary runtime portions of `.github/workflows/Test-CiHelpers.test.mjs`, after A03 assigns integration ownership. Add a short comment explaining that the retry timer admits retries rather than killing an active transfer. No sidecar policy/config file is needed. Existing workflow-helper call contracts and pins remain valid; update a validator/catalog only if accepted predecessor changes make it genuinely coupled. Do not add exact full-source/reference hashes to policy. Run the affected full policy/classifier/helper suites and PowerShell analysis/hooks. Check that removing each bound, changing retry count, dropping first-argument config exclusion, suppressing the native exit guard or moving extraction before the digest fails its intended oracle.

A02's metadata and string-preserving JSON decoder changes are unrelated and must survive rebasing. A07 owns dependency/hook installation, npm intent and its toolchain-validator regions. Its future Windows installer must receive a separate applicable download assessment; do not make this Linux helper cross-platform merely for A04. A03 owns workflow/classifier/test integration and the pending maintenance authority decision. No settings or protected prose mutation is included. Existing ordinary scoped implementation authority is sufficient once prerequisites and ownership permit it; no additional per-change human approval is invented here.

[probe-results.json](probe-results.json) contains27 completed local cases and two explicit full-helper Linux-platform rejections. [original-dispositions.json](../A00/dispositions.json) preserves all27 A00 dispositions and owners. [validation.json](validation.json) records arithmetic and evidence checks. No generated runtime archive was executed by these probes. Full Linux helper positive/digest/extraction/permission behavior is inspected existing coverage, not newly run acceptance. Windows PowerShell5.1 is outside this helper's `#Requires7.3`/Linux contract; no execution-policy change or bypass occurred.

Next action: parent reviews these decisions, records the Copilot configuration referral, and retains A04 pending implementation until A03/A07 (and their A02 prerequisite) are accepted. Then assign one PS writer, refresh native input identities, implement the two flags and current-caller tests, complete actual Linux validation and the normal PS→TF→reverse comparison lifecycle. Do not close PS213 or the original PS151 cycle from this preparation.
