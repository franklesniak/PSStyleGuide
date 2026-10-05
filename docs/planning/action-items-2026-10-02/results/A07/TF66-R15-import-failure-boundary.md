<!-- markdownlint-disable MD013 -->
# R15 — imported loader error and actual CLI classification

## 1. Validate and inspect the actual consumers

Comment4179817873 correctly observes that an imported module rethrows the native loader error. Its proposed consequence does not occur in the named production caller. `lint-staged-markdown.mjs` imports inside try/catch at110–122, prints the native error plus `pre-commit: Markdown lint tooling failed to run.`, prints `node .github/workflows/NpmTools.mjs install` remediation, and exits2. Its later nested phase at131–151 also catches and classifies errors. The direct helper prints its tooling prefix and exits2; the outer wrapper preserves the child diagnostic and normalizes native2 to tooling2. An imported library leaves process status to the consumer.

Actual omission of each of glob, jsonc-parser, markdown-it and markdownlint produced status2 and the expected tooling context through all three actual CLI callers on Windows and Linux. The staged path included its concrete repair command every time. Four separate raw-import controls preserved `MODULE_NOT_FOUND`, the missing package name and `requireStack`, and allowed the harness to catch the error without module-owned process termination. This is16 R15 behavior controls per platform, not four mocked exceptions. The actual import throws; success of the harness means the expected error was caught and inspected.

The [selected R96 hook boundary](review-TF-hook-prerequisite.md) already delegates missing-tool classification to the actual staged checker. [D90](review-braces-decision.md#current-d-reassessment-and-implementation-contract) and [E90](review-js-yaml-decision.md) preserve diagnostic/native-cause and0/1/2 semantics. Those prior decisions apply to the current caller. The new optional proposal to add a module-wide error wrapper is assessed here without inventing a missing end-to-end guard. Source census finds staged code as the production importing caller, the outer script as a child-process caller, and test imports; there is no inspected external public API consumer demanding an application-specific error class.

Input: TF `dde2b9abe761af69a7f561512df7d44d0dec6745`, tree `d59a740b7b1d88f7986075ac9328d9998629aa71`, accepted B `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`. The authenticated comment is saved in `review-comments.json`; raw blobs/modes/SHA256 are in `source-identities.json`. The current published CI/aggregate results belong to root; this decision claims only the focused private evidence below.

The Windows and Linux `result.json` files each contain 53 actual command records: 12 private Git fixture initialization/staging commands and 41 behavioral controls. The immutable production source was copied to private fixtures; it was not repaired or stubbed. Four dependency omission fixtures use real package resolution, with the chosen package absent and other packages linked to the unchanged installed graph. Config fixtures use actual glob and loaders. Only the R14 download phase is intentionally excluded: its actual selector prefix stops before download/extraction and emits the selected values. Synthetic future values establish selection behavior, not availability or installation of that future runtime. Each child has a 45-second/2-MiB diagnostic bound. No product suite, aggregate, npm install or GitHub mutation ran.

Windows uses Node24.18.1 and host PowerShell7.6.5/Git Bash. Linux uses existing image `sha256:455394ca075981fe23d0a7b84cbeaa63d5ca8a8f49bd045fcd2a2082b2fbb22d`, Node24.18.1/PowerShell7.6.3, network disabled, immutable dependency archive SHA256 `ca51b12b42f4d018498160a4c3fe3530eac72b2829328c5d8b2e985df9c55323` copied into container temp. Linux command/log are in `linux-run.json`/`linux-run.log`; terminal exit0 took14.609 seconds. Windows session4128 and Linux session98536 both terminated successfully. These are bounded diagnosis controls, not renewed full-suite acceptance.

## 2. Stakeholders

Contributors and GUI Git users need failures that name the tool and tell them how to repair it. Maintainers and CI operators need nonzero tooling classification with original loader details. Security reviewers need imports never to become false success. Library/API consumers need to catch errors without losing process ownership, original code or stack. QA and independent reviewers need real missing-dependency cases rather than prefix-only assertions. Accessibility/localization concerns favor readable context and stable programmatic codes over parsing English text. There are no new personal-data, deployed cloud, state-recovery or secret interfaces.

## 3. Options before the rubric

- N: Retain native import errors and existing CLI-boundary classification/remediation; reuse R96's selected responsibility.
- W: Wrap imported errors with a stable Markdown prefix, preserve the original `code`, and attach the original error as `cause`. A wrapper that discards code/cause is a strictly weaker variant, not a separate useful option.
- M: Prefix the original error's message in place while keeping its code/object identity. This changes native error presentation and needs careful compatibility handling.
- C: Add a shared application error class/code, native cause and corresponding caller mapping. It could support future API consumers, but current callers already catch the actual failure.
- L: Move dependency loading into exported functions and classify each API entry. This changes import timing, initialization and multiple entry contracts.
- P: Add a separate dependency preflight before import. Resolution success does not replace handling actual module initialization errors.
- X: Exit2 from the module on imported dependency failure. This prevents a consumer from recovering and fails import composability.
- D: Add product documentation explaining current CLI/error responsibility without code changes. The canonical decision can explain the same facts without a new maintained product paragraph.

W plus code/cause retention is the strongest practical wrapper variant and is scored fairly. C already includes that preservation. W/P plus caller guards cannot remove the need for those guards for other API exceptions. No variant may swallow the original failure.

## 4. Finding-specific rubric

Scores use0–5:0 violates the objective,1 very weak,2 materially limited,3 useful with significant tradeoffs,4 strong with a stated residual,5 meets this finding's objective on the available evidence. Total is sum(weight × score)/5. Scores are engineering judgments, not empirical probabilities or test results. Hard constraints override totals. Cost/churn have deliberately low weight.

Caller status35 measures correct0/1/2 behavior through actual supported entry points. Recovery25 measures clear actionable contributor guidance, not uniform decoration alone. Native cause20 measures preserved loader code, missing target and causal context. Import composability10 measures caller-owned catching/status and absence of module process exit. QA7 measures discrimination of genuine missing modules and caller outcomes. Maintenance3 measures how many error contracts need synchronized changes.

Hard constraints: no swallowed loader error; no imported-module process exit; preserve actual caller tooling2 and installation remedy; retain native cause/code when proposing a replacement error. A generic wrapper without preserved code is not W as scored.

## 5. Scores before selection

| Option | Caller status 35 | Recovery 25 | Native cause 20 | Import composability 10 | QA 7 | Maintenance 3 | Total | Basis / uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 5 | 5 | 5 | 5 | 5 | 5 | 100 | Actual callers classify errors and give recovery guidance; raw API retains native loader identity. |
| W | 5 | 5 | 5 | 5 | 4 | 4 | 98 | Preserve original code and cause while adding a producer prefix; valid but no observed end-user gap and a new wrapper shape to test. |
| M | 5 | 5 | 4 | 5 | 4 | 4 | 94 | Mutating original message retains object/code but changes native error presentation; no current recovery improvement. |
| C | 5 | 5 | 5 | 5 | 3 | 2 | 95.4 | Shared error type can be useful to future consumers; none currently needs another discriminator. |
| L | 5 | 4 | 5 | 5 | 3 | 2 | 90.4 | Lazy loading changes timing and each API initialization path without fixing current caller behavior. |
| P | 5 | 4 | 4 | 4 | 3 | 2 | 84.4 | Separate preflight duplicates resolution/dependency knowledge and still needs real import handling. |
| X | 4 | 3 | 2 | 0 | 3 | 4 | 57.6 | Ineligible: process exit inside an imported library prevents caller recovery. |
| D | 5 | 5 | 5 | 5 | 4 | 4 | 98 | Product documentation of existing responsibility adds maintenance; this decision already supplies the explanation. |

Recommend N. W can be implemented correctly, but actual users already receive the required context and remedy. Native error identity is already useful classification for API consumers. No inspected caller is forced to parse a bare English loader message. C/L/P add responsibilities without addressing a demonstrated missing behavior. N's100 reflects the bounded objective on inspected inputs, not a universal claim about every possible future importer.

## 6. Selected controlled-English disposition

Keep the native import error. Keep the CLI catch blocks. Keep tooling status2. Keep the locked-install remedy. Link the review response to the actual missing-dependency controls and R96. Reassess when a new supported importer needs a different error interface.

Product implementation scope is empty. No additional exact-message durable test is proposed. Existing meaningful missing-dependency/native-cause controls remain. No guide, metadata or protected instruction edit is required. Instructions follow controlled-English intent without formal dictionary certification.

## 7. Tests, sources and limits

All16 actual omission/import controls passed on each platform. Existing `lint-markdown.test.mjs`168–189 preserves native/API failure controls;235–239 exercises missing dependencies through staged/outer callers. This investigation did not rerun that whole test or a hook suite.

Primary Node24.18.1 [CommonJS module documentation](https://nodejs.org/download/release/v24.18.1/docs/api/modules.html#accessing-the-main-module) distinguishes direct execution from import. Its [resolution behavior](https://nodejs.org/download/release/v24.18.1/docs/api/modules.html#file-modules) throws MODULE_NOT_FOUND for unresolved inputs. [Error code](https://nodejs.org/download/release/v24.18.1/docs/api/errors.html#errorcode) is the stable native discriminator; [cause](https://nodejs.org/download/release/v24.18.1/docs/api/errors.html#errorcause) supports preserving an underlying error when a new wrapper is actually needed. Those APIs permit W; they do not require uniform CLI wording inside libraries. Root selected this disposition; native disposition remains separately recorded.

## Coordinator selection and evidence

At 2026-10-05T00:05:51.884809+00:00, root selected N (100/100) after displaying the options, separate rubric, full score table and selected steps to the owner in that order. No further owner decision is needed. Implementation scope is empty: retain the current product bytes and record the supported no-change disposition. The native review still contains three findings; resolution is not relabeled as a clean reviewer result. Fresh review-facing decisions, remote review and final independent quality remain in the normal lifecycle.

The 41 behavior controls on each platform comprise R14=11, R15=16 and R16=14; twelve fixture Git commands on each platform are not counted as behavior tests. Root read all three drafts, checked all22 option totals, sampled four raw source blobs and inspected actual current/future selection, negative historical selection, staged missing-module and Windows/Linux glob records. The final guard confirms unchanged HEAD/tree,78 tracked files, index and1910 dependency files. No full suite or aggregate was repeated.

From the round4 review-findings directory referenced by STATUS, the Windows command was `node probe.mjs <windows-output> <immutable-workflow-source> <unchanged-dependency-root>` using the pinned Node24.18.1 executable. Linux ran `py -3.12 -X utf8 run-linux.py`; its exact Docker command is saved in `linux-run.json`. The extra Windows command was `node posix-projection.mjs <windows-output> <immutable-workflow-source> <unchanged-dependency-root>`. Each result JSON contains actual argv, cwd, exit status, stdout and stderr. Parameters here name the recorded fixture roles; the actual paths remain in the private records referenced by STATUS.

| Evidence | SHA256 |
| --- | --- |
| `HANDOFF.md` | `5e9e3f7f1970ee3c2f774baa3b25622994dfbae277278c2ee946f81464f467e7` |
| `evidence-catalog.json` | `1c29fc563fe2f129e96d8163d35d5c14d5eb4053e676e78407d61c3b257980d3` |
| `final-source-guard.json` | `fa1a4328220b73d83a0566b5da833cb522b0861353cde0de9b509bb685457742` |
| `windows/result.json` | `c0413e4cf9964cb94d545d2dc3daac6937a3b552c0a2e7d663c61d90bf9cec70` |
| `linux/result.json` | `a13c519bef86173fbd0ea3d4aee351cc8f028b8351107af994bbb6d28a5f9bd8` |
| `windows/posix-projection.json` | `09ef5aeeea902f913f4af83e82c52c1b7647557350e5b0e83790c4ec0ce1a6b1` |

[Canonical peer lifecycle](../A02/coherent-peer-candidate.json) owns publication, native reply/resolution, counters and acceptance. [STATUS](../../STATUS.md) locates the private source, commands and complete logs.
