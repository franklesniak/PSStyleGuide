<!-- markdownlint-disable MD013 -->
# A03-D6: Copilot installer default curl configuration

Selected decision, 2026-10-04. This is the A04 D04-2 referral to A03/A07, not an extension of the ordinary helper's implementation or test claims. A04 explicitly excludes the separate Copilot installer from its selected change. No existing decision inspected fully disposes of this installer-specific edit and validation scope. The coordinator inspected the independent proposal and characterization, verified their hashes, recomputed all nine totals and displayed the options, rubric and table before selection or product implementation. Ordinary scoped authority suffices; no additional owner grant is needed.

## Validated issue and exact scope

Accepted PS `3e068afa36fbc963c4d716df9efb245468791fe8` and TF `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c` both invoke the same curl argument sequence in `.github/workflows/copilot-setup-steps.yml` (PS line346; TF line449). The selected fixed `/usr/bin/curl` or `/bin/curl` receives `--silent` first, not `--disable`. Native failure is checked immediately, and SHA-256 is checked before extraction and runtime execution. Those controls do not exclude options loaded from curl's default configuration.

The [official curl manual](https://curl.se/docs/manpage.html#--disable) says disabling default configuration requires the option in the first argument position. Its [configuration documentation](https://curl.se/docs/manpage.html#--config) identifies the default search paths, including CURL_HOME, XDG_CONFIG_HOME and home fallbacks, and says an explicit config file alone does not suppress the default file. Thus a caller-selected executable and verified archive digest do not establish reviewed-option isolation. An inherited default may add headers or URLs and alter request behavior before a valid digest is checked. No live leak, malicious runner home, compromised archive or service incident is claimed.

The existing `Test-CiHelpers.test.mjs` has actual installer-body fixtures for native failure, digest ordering, runtime/version failures and detailed retained retry/TLS arguments. Its curl replacements copy fixture bytes; they neither read a real default config nor assert first-argument disable. The PS modern/legacy compatibility branches and TF's retained service/runtime behavior are outside this repair's removal scope.

A safe characterization used Windows curl8.21.0, one loopback HTTP server and a process-local CURL_HOME containing only a dummy header. Default invocation sent that header; first-argument `--disable` did not; placing it after `--silent` still sent it. All three returned0, one request each, and identical inert text SHA-256 `e6d6a55732ed4fe0b26e844ed2cbeb558da6a0b512468b348b342d81a8f69ce2`. See [fixture results](copilot-curl-fixture.json), SHA256 4248c3292ab3f93dc69d952d4df9c79838be3f2646eb96e500e6096def664e31. No runtime archive was downloaded or executed. This establishes current curl behavior on Windows, not Linux installer acceptance or the ordinary helper's previous evidence.

## Stakeholders and supported options

Contributors and the UX owner need setup that does not silently depend on personal curl preferences and gives the existing precise failure messages. Maintainers need one obvious, supported boundary across both installer branches without a new configuration schema. Security and supply-chain reviewers need to exclude unreviewed request options while preserving origin, TLS, digest ordering and credential checks. QA needs tests that fail if the option is absent or moved, with short isolated fixtures instead of production outages. CI/service operators need unchanged retry behavior, runtime selection, output paths and service compatibility. No new permission, customer-data store, localization flow or recovery service is involved.

Options are listed before the rubric and scoring:

- N: keep the command and document a clean-default-file assumption; deferral has the same behavior.
- Q: add first-argument `--disable` and assert that position in the existing captured-argument installer test only.
- B: Q plus a bounded real-curl configuration-contamination fixture tied to the actual installer command. Test removal and movement of the option.
- H: enumerate known config locations and fail when any exists. This duplicates curl's search rules and blocks harmless local preferences.
- E: redirect all relevant home/config environment selectors into a disposable empty directory, with behavioral tests. This adds cleanup and search/fallback obligations without directly using the native disable boundary.
- F: introduce a wrapper and configuration allowlist around curl, with behavioral tests. The installer needs no user-configurable curl surface.
- T: replace curl with another download API and reimplement its explicit TLS, redirects, retry, output and error behavior.
- BH: B plus config-file detection/refusal. This is stricter but rejects harmless files that B already ignores.
- BE: B plus an environment/home sandbox. This may isolate more ambient state, but that broader boundary is not demonstrated as necessary by this finding.

Q combined with behavioral tests is B. Wrapper, sandbox or detection combinations retain their stated extra cost; none removes the need to prove the actual installer boundary. Disabling TLS, accepting an unverified runtime, editing/deleting user configuration, or using ambient Node are ineligible. Copying A04's different retry policy or merging both installers is a separate change, not a remedy for this finding.

## Installer-specific rubric

Score each criterion1-5, higher is better. Total is the weighted sum divided by5. Reviewed request-option determinism30%; preservation of actual installer failure/supply semantics25%; contributor/operator usability20%; observable regression detection15%; maintenance cost10%. Correctness and usability therefore precede cost. Hard constraints: preserve fixed tool selection, all explicit TLS/origin/digest/output/exit checks and runtime compatibility branches; do not modify host configuration or grant new authority. A high score cannot turn a clean-home assumption into isolation or a fixture into native service acceptance.

| Option | Determinism30 | Semantics25 | Usability20 | Detection15 | Cost10 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 1 | 4 | 3 | 1 | 5 | 51 |
| Q | 5 | 5 | 5 | 2 | 5 | 91 |
| B | 5 | 5 | 5 | 5 | 4 | 98 |
| H | 3 | 3 | 2 | 4 | 2 | 57 |
| E | 4 | 3 | 2 | 4 | 1 | 61 |
| F | 5 | 3 | 2 | 4 | 1 | 67 |
| T | 4 | 2 | 2 | 3 | 1 | 53 |
| BH | 5 | 5 | 3 | 5 | 2 | 86 |
| BE | 5 | 4 | 2 | 5 | 1 | 75 |

N leaves the validated issue. Q is a small viable edit but its stub assertion cannot show that real curl ignores configuration. B adds the needed behavior proof at modest cost. H/E/F/T impose unnecessary rejection, configuration, cleanup or transport obligations. BH/BE add those obligations after B has already closed the demonstrated default-file boundary. Scores are engineering judgments, not measured availability rates.

## Selected proposal and direct implementation instructions

Select B98. This is a clear technical winner. Coordinator inspection and display are complete. No product patch is made here. Implement after the current A03 source validation/lifecycle boundary under one workflow/test writer; coordinate with A07 and the separately selected A04 ordinary download repair. Do not mix their different retry contracts. Short direct instructions below follow the requested writing approach; no formal controlled-dictionary certification is claimed.

1. In the one download invocation, put `--disable` immediately after `$strCurlPath`. Keep every remaining argument and the existing native-exit/digest-before-extraction code unchanged. Apply PS first and reconcile the accepted equivalent TF change under the existing source-first sequence.
2. Extend the existing installer test to require the first captured curl argument to be `--disable`. Retain the existing exact TLS/retry/origin assertions and all native/digest/runtime negatives. Keep connect20, max120, retry3, retry-max300 and retry-all-errors. Do not import A04's ordinary-helper retry change.
3. Add a short Linux actual-command fixture using real fixed curl and temporary default configuration. Use only inert local data and a disposable local endpoint. Bind the extracted installer command and validate its production argument structure before any documented fixture URL/protocol substitution. Prove that a dummy header and an additional configured loopback URL are both ignored. Also prove the fixture detects the old command and a misplaced disable option. Bound process/server lifetime and cleanup. Do not download, extract or run a runtime for this contamination check.
4. Keep existing whole-installer stubs for failure propagation and digest ordering. They complement the real-curl boundary fixture. Record actual Linux curl version and explicit fixture substitutions. A Windows characterization or Linux skip is not a Linux pass.
5. Freeze the scoped workflow and test changes, run affected checks and the required normal lifecycle, then recheck native service behavior before acceptance. Do not alter the active A03 nine-file candidate or restart its aggregate to include this later referral.

The minimal product paths are `.github/workflows/copilot-setup-steps.yml` and its existing `.github/workflows/Test-CiHelpers.test.mjs` surface. A03 owns workflow/service integration and A07 owns coupled tool/runtime-test reconciliation; allocate one writer. There is no demonstrated need for a helper rewrite, protected instruction edit, settings change or new review gate.

Limits: `--disable` suppresses default curl files; it does not remove trusted-runner proxy/CA environment behavior or prove isolation from a hostile process. It does not provide a strict wall-clock process kill or change retry classes. Existing archive verification remains necessary. Real Linux command tests, complete candidate checks, native service execution and paired acceptance are future gates. The independent proposal and inert characterization changed no product/index/state/native object, transfer counter or runtime installation. The coordinator integrated this decision into planning. The original private proposal SHA256 is e0db214be7e88de409ac26247691a8f9509b7f30001eeec1d2bc3f4f6bdd93b1.
