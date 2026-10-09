<!-- markdownlint-disable MD013 -->
# FQ39: Reject inherited Git repository selectors

- **Status:** Accepted
- **Owner:** A07 coordinator
- **Last Updated:** 2026-10-09
- **Scope:** PR239 credential-helper selector finding 4232001882; source and tests, with earlier acquisition boundaries stated below.
- **Related:** [Decision process](../../../DECISION-PROCESS.md), [review finding](https://github.com/franklesniak/PSStyleGuide/pull/239#discussion_r4232001882)

Finding **4232001882**; review thread **PRRT_kwDOQkjdhM6q2cC8**; reviewed published head **2b5514c7a0c35b55d002935dcd771a72be1b1dcf**.

Status: analysis and recommended decision only. Root selects, implements, executes and accepts. No product, Git, canonical state, counter or remote changes were made by this worker. Root subsequently edited dependency-document spacing/date; the helper bytes reviewed here remain unchanged. This report does not assert that the whole checkout is still clean.

## 1. Validation and boundaries

The finding is valid. In `.github/workflows/Test-CheckoutCredentials.ps1`, lines251–263 refuse command configuration and tokens, then set system/global/prompt restrictions. They neither reject nor remove `GIT_DIR`, `GIT_WORK_TREE` or `GIT_COMMON_DIR`. The native Git invocations at330,337,343,350 inherit those variables. Consequently, a fixed, trusted Git executable can inspect a different repository from the current checkout. An expected origin in the decoy satisfies the remote check; absence of helper/header keys in that decoy satisfies the two local checks.

Root reproduced that exact Git-command behavior with Git2.56.0.windows.2, native result a63842. The actual scratch repository had the expected origin, a dummy credential helper and a dummy HTTP extraheader. With `GIT_DIR=decoy/.git`, the remote command returned the expected origin, while both local queries returned exit1 and no keys. Evidence: `W/pr239-round3-validation/git-selector-reproduction/result.json`, SHA256 `a12b81d528e94bf82d20c83593cd0a4b92b80dfb495b177f2a3635c98f18d873`. The worker read and hashed this evidence. It is **not a whole-helper execution**, does not include the final scope query, and does not prove a hosted workflow accepted a poisoned environment. Only root-owned local scratch repositories were configured; no network, credential helper or credential operation ran. Root reported git.exe identity prefix54bda91c; no full executable digest is invented here.

Git documents that `GIT_DIR` selects repository metadata and disables discovery; `GIT_WORK_TREE` selects the working-tree root. Changing the current directory with `-C` does not cancel those explicit selectors. This supports the source-level conclusion, not a claim that `GIT_WORK_TREE` alone conceals local configuration. [Git command/environment documentation](https://git-scm.com/docs/git)

`GIT_COMMON_DIR` is independently relevant: Git documents that the repository's local config is ignored and `GIT_COMMON_DIR/config` is used when this variable is set. Thus a DIR-only refusal is incomplete. Root should reproduce this variant with the qualified executable before describing it as an executed bypass. Ordinary linked worktrees use a commondir file; refusing inherited selectors does not prohibit that on-disk arrangement. [Git repository layout](https://git-scm.com/docs/gitrepository-layout)

The immediate impact is a false clean-checkout result. This analysis does not establish who can set these environment variables in a particular hosted event, credential disclosure, malicious helper execution, or a general defense against a process owner who can alter the helper. Existing service success does not test the inherited-selector case.

Relevant prior decisions: FQ19 preserves phase-aware Windows mock behavior and exact native call counts; FQ21 preserves the helper's PowerShell minimum; FQ23 distinguishes explicit sanitation from user preference handling; FQ30 establishes precise input refusal. None supplies this missing repository-selector refusal. The existing build acquisition guard already rejects DIR/WORK_TREE, but omits COMMON_DIR. The Copilot setup guard includes all three. These are precedents and scope boundaries, not proof that the standalone helper is protected.

## 2. Stakeholders and actual coupled flow

- The repository owner, PowerShell and Terraform maintainers, security reviewers and CI operators need the credential result to describe the checkout being used. A silently redirected query breaks that assertion even when Git itself is trusted.
- Experienced contributors may export Git selectors intentionally. New contributors and agent operators need one stable diagnostic and a clear recovery: remove those three variables from the invoking environment and run from the intended checkout. Ordinary linked worktrees must remain usable. No path or variable value should be printed.
- Windows and Linux users need the same logical refusal. Environment names are case-insensitive on Windows and case-sensitive on Linux. PowerShell7.5+ can retain empty values, so absence and empty text are distinct. [PowerShell environment documentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables?view=powershell-7.6)
- QA, independent reviewers, incident/recovery operators and history custodians need an actual-source regression, a causal old-source/mutant witness and separate source, syntax and runtime attribution. Prior accepted runs remain historical.
- Privacy owners benefit from a fixed diagnostic. Documentation readers need the helper's supported-environment contract stated accurately. Accessibility/localization has no new UI surface beyond readable text; no translation framework is needed.
- Dependency maintainers, cloud/backend administrators and generated-artifact consumers are affected indirectly through CI reliability. No package, cloud permission, generated artifact or Terraform runtime interface changes are required. Cost/schedule owners favor a central, testable correction over duplicated environment machinery.

Concrete callers are `Initialize-CiToolchain.ps1:1182` and `Invoke-MarkdownLint.ps1:243`, plus direct workflow invocations in build.yml:319/425, markdownlint.yml:58/120 and agent-instructions.yml:67/84/158. The initializer calls the credential helper before Node acquisition/staging; some Windows curl capability probes occur earlier. Promise no credential Git dispatch after a selector refusal, not zero native work in the entire initializer.

Build acquisition itself uses Git before the helper and contains broader selector checks at28/156/282/388. The markdownlint/agent acquisition code also uses Git earlier and checks command configuration/tokens. A helper repair does not retroactively validate that earlier acquisition. The selected recommendation below covers the reported helper assertion and its existing consumers. A claim of safe acquisition under arbitrary Git environment injection would require the larger option L; do not claim it from this fix. No caller removes the three variables to evade the new refusal.

## 3. Relevant options, before scoring

| ID | Option | Consequence / relevant permutation |
| --- | --- | --- |
| A | No change, or defer until CI demonstrates a failure | Retains the reproduced false result; fresh CI environments are an assumption, not the helper contract. |
| B | Remove the credential gate and make callers responsible | Removes a security assertion required by the current callers. Documentation alone cannot replace detection. |
| C | Reject only GIT_DIR | Smallest reviewer-example fix; COMMON_DIR still selects config. Other proper subsets have the same incomplete-contract problem. |
| D | Reject the three variables only when nonempty | Fits current CONFIG_COUNT style and blocks the demonstrated values. Empty entries remain delegated to platform/Git semantics rather than one explicit contract. |
| E | Reject the presence of each of the three variables | One early query-only refusal, including empty/whitespace values. Requires users with selectors to remove them. Retains normal Git discovery and linked worktrees. |
| F | Clear all three in the current process | Can inspect the current directory, but silently changes the caller's repository context and may change later Git behavior. Adds mutation/preference/recovery obligations. |
| G | Supply a clean child-only environment for each Git query | Avoids modifying the parent, but later caller Git remains poisoned; replaces the current native invocation contract with process/environment plumbing. |
| H | Derive an independent expected repository identity and bind every Git query to it | Potentially correct, including common-dir handling, but needs an explicit checkout-root contract, linked-worktree handling and a trusted source for that root. `-C` alone is insufficient. |
| I | Permit selectors only when they resolve to the expected repository | Preserves specialized users but adds aliases, relative paths, common directories and physical-identity validation. No current supported consumer requires the exception. |
| J | Add `-C` only, query `rev-parse` identity only, or force empty credential config | Selectors still affect discovery/config, or credentials are hidden instead of detected. A sound independently bound query becomes H. |
| K | Put refusals only in acquisition callers | Helps earlier acquisition, but leaves standalone helper and unmodified/future callers able to return a false result. Duplicates the contract. |
| L | E plus a coordinated shared acquisition guard across all caller families | Covers earlier acquisition too, but adds shared-file acquisition/copy dependencies or multiple guard copies and broader workflow regressions. This is a larger interface/control change. |

All seven nonempty subsets of the three variables must be considered: DIR; WORK_TREE; COMMON_DIR; DIR+WORK_TREE; DIR+COMMON_DIR; WORK_TREE+COMMON_DIR; all three. E handles them uniformly. C's subset variants are not seven separate designs. Same-target, relative, whitespace and empty values are boundary cases of D/E/I, not new mechanisms. E plus selective silent clearing contradicts its contract; E plus H adds unsupported complexity without evidence that callers require selectors. Clearing every `GIT_*` variable is not a bounded repair: it alters unrelated legitimate behavior.

Do not casually add `GIT_CONFIG` to this triplet. Its documented effect is specific to git-config; in inspected Git2.56 source, a configured file conflicts with `--local` and errors rather than silently replacing that local query. The installed-version behavior remains a possible negative control, not a demonstrated fourth bypass. Other object/index/shallow selectors do not become credential-config bypasses merely because they start with GIT_. [git-config environment](https://git-scm.com/docs/git-config), [Git2.56 configuration option validation](https://raw.githubusercontent.com/git/git/v2.56.0/builtin/config.c)

## 4. Finding-specific rubric

Scores are ordinal judgments, not measured probabilities: 0 contradicts the requirement; 1 leaves a major failure; 2 gives partial coverage; 3 works with significant conditions; 4 has a bounded documented limitation; 5 directly satisfies the criterion. Total = sum(weight × score /5). Weights sum100.

| Criterion | Weight | Meaning here |
| --- | ---: | --- |
| R: repository correctness | 31 | The helper cannot report clean by querying a selector-chosen decoy. |
| S: security and failure behavior | 27 | Refuses unsupported context before credential Git/staging, preserves credential detection and avoids silent context mutation or value disclosure. |
| U: supported usability | 18 | Ordinary local/CI/linked-worktree use stays simple; unsupported context has a clear recovery. |
| V: verification and recovery | 18 | Actual-source causal controls, deterministic empty/presence behavior and restart attribution are straightforward. |
| M: maintenance cost | 6 | Small reviewable change, no unnecessary process/fixture/framework coupling. |

Hard constraints: retain the credential gate and native exit checks; address both DIR and COMMON_DIR; specify WORK_TREE semantics; retain fixed Git, global/system isolation and Windows ACL/private-file cleanup; do not hide persisted credential configuration; do not leak selector values; do not replace actual-source tests with a copied standalone guard. A high total cannot waive these constraints. Prior passing CI and inferred absence of selectors cannot satisfy them.

## 5. Scores, before recommendation

| ID | R | S | U | V | M | Total /100 | Main uncertainty or constraint |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 1 | 1 | 3 | 1 | 5 | 32.0 | Reproduced defect remains; fails hard constraints. |
| B | 0 | 0 | 2 | 1 | 5 | 16.8 | Removes required gate. |
| C | 2 | 2 | 4 | 4 | 5 | 58.0 | COMMON_DIR hole remains. |
| D | 5 | 4 | 4 | 4 | 5 | 87.4 | Empty-value semantics require qualification; no empty-value exploit is claimed. |
| E | 5 | 5 | 4 | 5 | 5 | 96.4 | Exact presence behavior needs maintained Windows/Linux tests. |
| F | 4 | 3 | 4 | 4 | 4 | 74.6 | Silent parent mutation and later-command context. |
| G | 4 | 4 | 4 | 3 | 2 | 74.0 | Child-only guarantee does not cover later caller context. |
| H | 5 | 5 | 4 | 3 | 2 | 85.6 | New root/linked-worktree identity contract must be correct. |
| I | 4 | 3 | 5 | 2 | 2 | 68.6 | Exception path/alias proof is more difficult than refusal. |
| J | 2 | 2 | 4 | 3 | 4 | 53.2 | Incomplete or masks the evidence; fails hard constraints. |
| K | 3 | 3 | 4 | 3 | 3 | 63.6 | Standalone contract still false. |
| L | 5 | 5 | 3 | 4 | 1 | 84.4 | Useful broader boundary; higher caller/workflow migration risk. |

Arithmetic was calculated independently from the listed weights/scores and is recorded in evidence.json. E wins because it addresses the complete reported selector contract with explicit failure semantics. This is a worker recommendation; it is not root selection or acceptance.

## 6. Recommended controlled-English implementation instructions

These short instructions use consistent terms and explicit conditions. No formal ASD-STE100 dictionary certification is claimed.

1. Add one selector check to Test-CheckoutCredentials.ps1.
2. Place the check before the existing environment assignments and before any native Git call or Windows private-file creation.
3. Check exactly GIT_DIR, GIT_WORK_TREE and GIT_COMMON_DIR.
4. Use an exact Environment-provider presence query for each name. For example, use `Test-Path -LiteralPath ("Env:" + $strName)`. Do not use a truth test on the value.
5. If any name is present, throw one fixed credential-policy error. Do not print the name's value. State that repository selector environment variables are not allowed.
6. Do not clear the variables. Do not change the current directory.
7. Keep all existing remote, local-credential, effective-scope, native-status and cleanup checks.
8. State in the helper description that callers must omit these three variables.
9. Extend actual-source fixtures in Test-CiHelpers.test.mjs. Keep the existing phase-aware Windows Git mock.
10. Keep unrelated process environment entries in each fixture child. Remove the three selectors from the fixture's private baseline map before adding a deliberate test value.
11. On Windows, remove case-equivalent keys from that private map. Do not change the parent process environment.
12. Ask root to verify the proposed native controls and review the final source delta before acceptance.

This preserves existing filesystem preference behavior: the new query does not require ShouldProcess or environment mutation. Keep PowerShell7.3 minimum and Windows7.6.5 qualification. A claimed explicit empty value must actually be present in the child; use qualified7.6.5/provider setup to establish it where a launcher may omit empty strings.

## 7. Verification plan and complete coupled scope

All rows below are **proposed, not executed by this worker**. Reuse the maintained fixture transports and private writable namespace. Do not run network operations or real credential helpers.

| Control | Required evidence |
| --- | --- |
| Actual-source absent-selector positive | Full helper succeeds for an ordinary clean repository; fixed Git and private config behavior retain existing exact call counts. Include a normal linked worktree with selectors absent. |
| Seven nonempty combinations | Each rejects with the exact new diagnostic, zero credential Git dispatch and no Windows private staging. Use safe fixture strings; there is no reason to resolve their paths. |
| Boundary values | Test each singleton with empty, whitespace and relative values; test all-three same-repository values. All present values refuse. Verify actual child presence for empty cases. |
| Platform names | On Windows, mixed-case spellings must refuse. On Linux, test exact uppercase names; a lowercase unrelated variable alone must not produce the selector diagnostic. |
| Causal guard witnesses | In a copied actual helper, remove one name at a time from the new triplet. The matching singleton must reach the controlled Git mock. It must not accidentally pass because of a timeout, parser error or missing runtime. Restore the source between mutants. |
| Native decoy witness | Extend root's retained scratch setup. Compare old and corrected complete helpers with DIR and COMMON_DIR separately. Old helper acceptance is an expected-failure witness only if every stage really completes; corrected helper must refuse before Git. Native clean/bad-actual controls must distinguish helper and header detection. |
| WORK_TREE limit | Record its native effect separately if needed. Its required maintained assertion is early unsupported-selector refusal; do not label a mock witness as native config redirection. |
| Coupled callers | One initializer control and one lint control must execute the real copied credential helper, refuse a selector and leave their acquisition/npm invocation log empty. Retain any earlier authorized capability probes in the expected initializer trace. |
| Existing controls | Retain token/config refusal, Windows version-before-private-file ordering, global/system isolation, inherited-global handling, preferences, wrong-origin/helper/header/native-error and cleanup controls. |

Cap new targeted helper/caller controls at48 child invocations per platform, each at most15seconds and256KiB captured output; existing tighter limits take precedence. Retain ordinary completion assertions: no spawn error, no signal, expected exit status, expected diagnostic/call count, owned cleanup and no unrelated output. Native scratch preparation must have its own finite command list and run only under root's existing transport caps. Do not raise controller, Job, scanner, storage or cleanup limits to fit a failing test.

Minimal product scope is Test-CheckoutCredentials.ps1 plus its maintained tests and its own descriptive comment. No shared execution framework, YAML guide, new configuration file or package change is required. Actual-source copies at test lines698/1001/1053/1127/1187/2673/3271/3332/3768/4203 and the Windows fixture at3405–3518 consume this helper; their applicable runtime groups need fresh root scope classification. Private child environment baseline handling also occurs in several specialized fixtures. Update only the affected baseline maps or existing shared fixture convention; preserve HOME/TMPDIR, DOTNET_EnableDiagnostics, POWERSHELL_DIAGNOSTICS_OPTOUT, locale and other qualified private-runtime inputs. Do not recreate the stripped-environment regressions from round2.

New source requires a fresh whole-driver Node syntax check and helper PowerShell parsing. Regenerate any generated form whose helper bytes or fixture constructor changed; preserve byte-equal forms' original attribution. The FQ34 extracted Assert-OrdinaryPath body is not changed by this recommendation. Do not automatically claim that all generated bodies remain equal, or that historical Linux111/Windows aggregate/all11 receipts executed the new helper. Root should calculate the final registration census and affected runtime groups from the implementation, then run the applicable maintained Windows/Linux aggregate and final hooks under the existing policy. No new result, counter increment, acceptance or retry has occurred here.

Remaining root questions are concrete runtime observations: complete old/new helper behavior with DIR and COMMON_DIR, explicit empty presence on qualified Windows/Linux, linked-worktree positive behavior, and final affected-test census. They do not block source validation of the reproduced DIR defect. Earlier acquisition under selector injection remains the explicit larger-scope boundary in option L.

## Root selection and current implementation

Root fully read the sealed proposal (d8c8a7), verified its two sealed assets and displayed all twelve options, distinct rubric and complete scoring table before the edit. On 2026-10-09, root selected E (96.4/100). Source correction bdbef7 adds the exact three-name presence guard before environment assignments, Git dispatch and private staging. The fixed diagnostic contains no values. The helper description states the contract and its main Version date is current. Current helper SHA256 is dc8b92d3bc2d849fc6c304168213ad06cd3da036a4e2d88057cbf2b38397d791. This selection supersedes the worker-proposal-only status above; it does not claim runtime acceptance. Maintained tests are being prepared. The complete old/new helper, COMMON_DIR and supported linked-worktree controls remain pending. No caller/acquisition, config isolation, exit, ACL or cleanup control was removed.

Root native result, 2026-10-09: complete-helper proof a2 finished with native exit 0 (session83927, b8aec1). All eleven controls passed on PowerShell 7.6.5 and Git 2.56.0.windows.2. The old complete helper accepted a clean decoy selected by GIT_DIR or GIT_COMMON_DIR while the dirty baseline refused. The corrected helper rejected those selectors, GIT_WORK_TREE and an inherited empty GIT_DIR. Clean ordinary and Git-created linked worktrees passed. Actual credential-helper and HTTP-header configurations refused. The proof result SHA256 is 8485c7590ab2e49307e1192f99e3b6d19086e65785279158ed69c3733ea41ed5; its exact location is bound in execution-state.json. This resolves the listed native proof questions for Windows only. Scratch is retained; no aggregate or strict-cleanup acceptance is claimed.

Fixture note: the first native attempt failed the private-directory ACL gate before it reached Git.
Cause: the fixture was placed under generic TEMP.
Fix: use the already qualified private runner parent without changing host permissions.
Test: all eleven controls then passed in a fresh namespace; the original attempt remains uncredited.
Evidence: the complete-helper proof a2 above records the original failure and the corrected environment.

Maintained regression integration, 2026-10-09: root read the full inert test report and insertion, verified all sealed assets and the exact inverse, and integrated the six registrations (27 bounded children per supported platform). The driver became c11bcb87013e7a0405657c2c28b5f850059b016dd5fbe3b0dbe5c49891e52a9f at f7ce84. Whole-module Node syntax bee663 and git diff --check f7d145 passed. Generated PowerShell checks and native maintained-suite execution remain pending. The final initializer description-only delta from 9a8b1ddc to 42a9b115 does not change this test patch's capability mock or helper-call assertions.

Formatting note: Markdown check befbd1 found repeated blank lines in the copied proposal boundaries. Removed only excess blank lines from the two current decision documents. Product bytes and decision text are unchanged; the repeated check records the result.

Fixture syntax note: materialization 2ef699 refused the nonunique bare curl-path anchor before native parsing; partial output remains uncredited.
Cause: the new capability helper's example repeats the Linux curl path.
Fix: match the two complete curl assignments in the caller fixture and its data-only materializer; preserve the example and all production bytes.
Test: exact 50-byte inverse to driver29573 was verified; a fresh namespace produced all70 forms at467404, manifest3586baa3. PowerShell parsing is the next gate.
Evidence: source-freeze-v3.json binds driver674df250 and the unchanged helper; the four materializer replacements invert to frozen ed2d5a exactly.

## Current maintained Linux result

The six maintained selector registrations passed on 2026-10-09 against helper dc8b92d3 and driver7b360206 at staged index27cdfb38. Native session72736 ended with exit0 (eff7b6). Root acceptance5b09a5 checked the exact six names, zero skips, unchanged source/dependencies, empty process ownership and strict cleanup. [Accepted runtime receipt](current-main-validation/pr239-round3-selectors-runtime.json) has SHA256 f7d149bee79d148ae7274502b7ad74b3769f702f2e281b1c251ea3526183b876.

The group covered selector subsets and present-value boundaries, native name casing, removal of each guard name, real ordinary and linked-worktree positives, and calls through both the initializer and Markdown launcher. This resolves the maintained Linux questions for the selected guard. Complete current generated syntax and independent source review are also accepted. The earlier eleven Windows proof controls retain their narrower attribution.

The final fixture candidate uses driver c57e2447 and staged index cacf070b. Its six selector registrations passed again on Linux in session53679, native0/721db6, with strict root acceptance b0fdaf and [receipt c1d3501f](current-main-validation/pr239-round3-v5-selectors-runtime.json). All156 affected Linux registrations are accepted:6 fresh and150 unchanged effective inputs with original receipts preserved. Independent review accepted the current156 attribution.

The fresh Windows aggregate also passed:816 registrations,377 passes,439 explicit platform skips and zero failures, cancellations or TODOs; native65052/53982f and [strict acceptance6557808f](current-main-validation/pr239-round3-v5-windows-aggregate-runtime.json). All six selector registrations passed, including the real initializer caller. [FQ42](FQ42-WINDOWS-CURL-FIXTURE-HELP.md) records the fixture-only CRLF help correction that was needed for the Windows test to reach the intended guard. Independent review confirmed the new results, unchanged inputs and normal cleanup. The [final hook acceptance](current-main-validation/pr239-round3-v5-windows-precommit-runtime.json) confirms11 passes, zero skips, unchanged inputs, empty unforced Jobs and removed private TEMP. The [normal commit](current-main-validation/pr239-round3-v5-normal-commit.json) is11224a2f58e2cb1e2ffb3ab443ccc83dd0822950; staged, repository and nested Markdown hooks passed at native0/c6b968. The public lifecycle remains pending.
