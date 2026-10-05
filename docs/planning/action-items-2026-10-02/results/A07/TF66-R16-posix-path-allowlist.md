<!-- markdownlint-disable MD013 -->
# R16 — POSIX glob paths already match the allowlist

## 1. Validate the exact comparison

Comment4179817891's alleged failure is disproved. On Windows, splitting a path that already uses `/` on `path.sep` (`\`) returns the original string; joining that single element preserves the allowed POSIX literal. The no-op is correct. Backslash-delimited native Windows paths are converted to `/`. On Linux, splitting/joining on `/` also preserves the same string.

Actual glob13.0.6 on Windows emitted the allowed paths with native backslashes; the current expression converted them to the exact POSIX allowlist literals. Linux emitted POSIX paths directly. Each actual API loader and all three CLI callers accepted the corresponding allowed configuration. The same cases passed on Linux. Adding `docs/.markdownlint.json` caused all three callers to reject with tooling2 on both platforms. This is14 R16 behavior controls per platform: two actual discovery/API checks, six allowed CLI controls and six unsupported-selector negatives. The original 14 controls use unmodified default discovery. A separate Windows projection then executed the exact extracted assertion body with the real glob package forced to its supported posix:true output mode: both allowed files passed, and each unsupported docs config was rejected (two cases/four assertions). Only that glob option is projected; it is not a claim that current default Windows discovery returns POSIX paths.

[D90](review-braces-decision.md#current-d-reassessment-and-implementation-contract) and [E90](review-js-yaml-decision.md) require explicit supported JSONC/JSON and unsupported-selector refusal; [R5](TF66-R5-config-diagnostic.md) clarifies the two accepted filenames. The proposed separator change is a distinct alleged defect, not a new selected requirement in those decisions. Current code meets their contract.

Input: TF `dde2b9abe761af69a7f561512df7d44d0dec6745`, tree `d59a740b7b1d88f7986075ac9328d9998629aa71`, accepted B `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`. The authenticated comment is saved in `review-comments.json`; raw blobs/modes/SHA256 are in `source-identities.json`. The current published CI/aggregate results belong to root; this decision claims only the focused private evidence below.

The Windows and Linux `result.json` files each contain 53 actual command records: 12 private Git fixture initialization/staging commands and 41 behavioral controls. The immutable production source was copied to private fixtures; it was not repaired or stubbed. Four dependency omission fixtures use real package resolution, with the chosen package absent and other packages linked to the unchanged installed graph. Config fixtures use actual glob and loaders. Only the R14 download phase is intentionally excluded: its actual selector prefix stops before download/extraction and emits the selected values. Synthetic future values establish selection behavior, not availability or installation of that future runtime. Each child has a 45-second/2-MiB diagnostic bound. No product suite, aggregate, npm install or GitHub mutation ran.

Windows uses Node24.18.1 and host PowerShell7.6.5/Git Bash. Linux uses existing image `sha256:455394ca075981fe23d0a7b84cbeaa63d5ca8a8f49bd045fcd2a2082b2fbb22d`, Node24.18.1/PowerShell7.6.3, network disabled, immutable dependency archive SHA256 `ca51b12b42f4d018498160a4c3fe3530eac72b2829328c5d8b2e985df9c55323` copied into container temp. Linux command/log are in `linux-run.json`/`linux-run.log`; terminal exit0 took14.609 seconds. Windows session4128 and Linux session98536 both terminated successfully. These are bounded diagnosis controls, not renewed full-suite acceptance.

## 2. Stakeholders

Windows/Linux contributors need supported configurations to work identically and unsupported configurations to be rejected visibly. Maintainers and supply-chain/application security reviewers need the exact allowlist to remain narrow. CI and QA engineers need real-platform discovery/caller evidence. New contributors benefit from correct JSONC/JSON recovery guidance. Library maintainers need platform path semantics respected rather than assuming every backslash is a separator on every filesystem. There is no changed cloud, recovery, credential, personal-data or deployment contract; those roles do not add separate requirements.

## 3. Options before the rubric

- N: Keep the correct existing normalization and allowlist; record the disproving Windows/Linux evidence.
- B: Replace backslashes globally and retain the allowlist, with focused real-platform coverage. This is equivalent for the actual allowed strings; it must not broaden unrelated POSIX filename semantics.
- P: Request explicit `posix` glob results and consistently use `path.posix` for selector comparisons. This can work but changes the discovery interface without a demonstrated need.
- S: Factor a shared normalization helper used by this comparison and future consumers. No second applicable consumer is currently demonstrated.
- A: Store both native and POSIX variants in the allowlist. This repeats path facts instead of normalizing the observed form once.
- R: Remove selector refusal and trust config loading alone. This loses intentional rejection of ignored unsupported selectors.
- T: Keep code but add another durable normalization-only regression. Existing real JSONC/JSON and all-caller selector controls already exercise the useful behavior; a literal-mirroring assertion is not warranted.

B plus meaningful coverage is already B. P includes consistent comparisons; merely replacing basename calls without defining glob output would be an incomplete variant. Combining B/S/A adds machinery without another behavior. No option gets to remove selector refusal because allowed cases already work.

## 4. Finding-specific rubric

Scores use0–5:0 violates the objective,1 very weak,2 materially limited,3 useful with significant tradeoffs,4 strong with a stated residual,5 meets this finding's objective on the available evidence. Total is sum(weight × score)/5. Scores are engineering judgments, not empirical probabilities or test results. Hard constraints override totals. Cost/churn have deliberately low weight.

Platform correctness40 measures real Windows/Linux path forms and literal filesystem semantics. Selector refusal25 measures exact supported-file admission and continued rejection of unsupported selectors. Usability15 measures successful supported setup and truthful diagnostic recovery. Caller proof15 measures actual discovery/API/CLI positive and negative controls. Maintenance5 measures single-source path policy and avoidance of redundant helpers/variants.

Hard constraints: preserve both accepted filenames; reject unsupported selectors; preserve platform filesystem meaning; do not add test-only implementation mirroring or drop meaningful caller tests. No source mutation is justified by the mistaken claim that an unchanged allowed literal cannot match itself.

## 5. Scores before selection

| Option | Platform correctness 40 | Selector refusal 25 | Usability 15 | Caller proof 15 | Maintenance 5 | Total | Basis / uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 5 | 5 | 5 | 5 | 5 | 100 | Real Windows/Linux glob paths pass both allowed forms and all callers; disallowed config still rejects. |
| B | 5 | 5 | 5 | 4 | 4 | 96 | Global backslash replacement with focused coverage can be equivalent for these inputs; no failure requires it, and POSIX backslashes are not separators. |
| P | 5 | 5 | 5 | 4 | 3 | 95 | Explicit glob posix plus path.posix comparisons is coherent but adds an unnecessary discovery option/interface change. |
| S | 5 | 5 | 5 | 4 | 2 | 94 | Reusable normalizer has no demonstrated additional consumer; factoring adds another contract. |
| A | 4 | 5 | 5 | 4 | 3 | 87 | Accepting native and POSIX variants repeats allowlist facts and complicates mixed-path reasoning. |
| R | 5 | 0 | 2 | 2 | 5 | 57 | Ineligible: removing the allowlist admits unsupported configuration. |
| T | 5 | 5 | 5 | 4 | 3 | 95 | Adds a durable duplicate of already exercised JSONC/JSON/all-caller behavior; diagnosis evidence is sufficient. |

Recommend N. B/P can be technically sound, but no correctness gain was found and neither is required to handle POSIX glob output on Windows. No-change wins on executed behavior and unchanged caller contract, not an assertion that every refactor is forbidden. The proof score4 for alternatives indicates the new bytes were not implemented or tested; it is not a prediction that they would fail.

## 6. Selected controlled-English disposition

Retain the current comparison. Keep both accepted configuration paths. Keep unsupported-selector rejection. Cite the actual Windows glob output. Include the Linux controls. Reassess only if the dependency or discovery contract changes.

Product implementation scope is empty. No guide, metadata or protected instruction changes are needed. The instructions follow controlled-English intent; no formal dictionary certification is claimed.

## 7. Verification and primary reference

All14 default-discovery controls passed on each platform; the separate Windows posix:true projection passed both cases/four assertions. Existing `lint-markdown.test.mjs`106–124 exercises JSONC/JSON fallback through child/API;139–150 exercises alternate selectors through all three callers. No duplicate durable tests or suite replay is proposed. The pinned [Node24.18.1 path.sep documentation](https://nodejs.org/download/release/v24.18.1/docs/api/path.html#pathsep) defines native separators and Windows acceptance of both slash forms. The installed glob13.0.6 README's `posix` option documents an alternative explicit output choice; actual returned values are saved in each platform's `R16-*-actual-glob-api.log`. This is no-change evidence, not a claim that every possible filesystem race or malformed dependency is covered. Root selected this disposition; native disposition remains separately recorded.

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
