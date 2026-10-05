<!-- markdownlint-disable MD013 -->

# PS232 R6 — accurate workflow script discovery

Selected O97.4 by root after displaying the complete options, unique rubric and scores. The one-document repair and focused checks are complete locally; combined validation and native acceptance remain pending. PS proposed H `f77a58dede8f6f68b45e0d62e5b96e2fed477c58`, base `f168f83b89f64b6bca9d520ddec4b58969060fb6`; accepted TF `56cb0418dcdcf71be94acc78d8963ea580b8a9e9`. Codex comment4182490671, authenticated bot199175422 review5412443745 at09:25:24Z, reports an incomplete inventory heading. The paired Copilot request remains independently tracked by root. No premature new-input review is proposed.

## 1. Validation and existing obligations

The finding is valid as a documentation usability defect. Both immutable trees contain27 top-level executable script files under `.github/workflows`:18 operational tools/helpers, eight `*.test.mjs` suites and the loaded `Test-AgentInstructions.SelfTest.ps1` module. Each README table lists13 operational tools/helpers. The five omitted operational files are exactly those identified by the reviewer: Classify-InstructionMaintenance.mjs, Initialize-CiToolchain.ps1, Invoke-MarkdownLint.ps1, Test-CheckoutCredentials.ps1 and Test-ExactGitPathSet.ps1. The unqualified heading `Script inventory` does not tell a reader its selection boundary.

Existing paragraphs mention the Linux helpers, several test commands, classifier tests and the SelfTest loader. This reduces the severity but does not make the table complete or identify all omitted tools clearly. It is not an executable, security or admission failure. Prior R5's three-column rendering finding was disproved; the current table renders correctly. This new issue concerns coverage and labeling, so the R5 no-change decision does not dispose of it.

[A07 post224 reconciliation](post224-reconciliation.md):24 requires retaining the current complete API/script index and existing config/error/bounds documentation. That historical phrase did not enumerate or prove a27-row table. Its genuine no-loss/completion intent should be preserved: do not delete useful descriptions or relabel omitted behavior out of scope merely to silence review. The selected proposal below completes the real operational catalog and explicitly navigates the remaining test files. A07 owns this shared maintainer document; no runtime or guide-policy redesign is needed.

The five files' actual bodies and callers were inspected. The classifier explicitly requires accepted-base execution and denies that its result grants permission; agent-instructions.yml:96 passes root/B/H. Initialize-CiToolchain requires Linux, runner variables, credential checks and selected dependency switches. Invoke-MarkdownLint requires the reviewed runner runtime and captures both native exits. Test-CheckoutCredentials checks anonymous origin/config/token properties with fixed Linux Git. Test-ExactGitPathSet requires explicit root, expected paths and mode; Test-StyleGuideArtifacts.ps1 supplies them at634. None should be advertised as an unrestricted argument-free public entry point.

## 2. Stakeholders

New contributors need to find the right tool without mistaking internal helpers for setup commands. Maintainers need a complete operational map and a clear route to test sources. Documentation/UX owners need truthful headings, short supported-call descriptions and a scannable table. Security and authority reviewers need accepted-base versus proposed-code roles and Linux runner prerequisites kept explicit. QA owners need durable meaningful behavioral tests retained without a new test for a simple prose correction. Peer owners need identical useful shared discovery text while preserving each actual language-specific child, supply link and native check name.

## 3. Options and useful combinations

| ID | Option | Material consequence |
| --- | --- | --- |
| N | Keep the table or defer | Retains correct entries but leaves the ambiguous coverage boundary. Deferral has the same current outcome. |
| S | Label the13 rows as selected scripts | Truthful scope but limited help finding omitted operational tools. |
| SL | Selected label plus actual directory navigation | Honest compact overview with complete filename discovery one navigation away. |
| O | Complete all18 operational tool/helper rows; explicitly exclude and link test files | Complete operational purpose/caller discovery while keeping test-module navigation separate. |
| C | Complete all27 script entries, grouped to distinguish tools, suites and loaded module | Maximum one-document detail, including descriptions/commands already covered elsewhere. |
| D | Separate complete inventory plus selected summary here | Can serve two audiences but splits the current directory documentation and duplicates navigation/maintenance. |
| G | Generate a complete filename inventory with curated purpose/caller mapping | Can detect additions, but filenames alone cannot establish supported invocation or authority; a mapping/generator becomes another maintained contract. |
| A | Hand-maintained complete inventory plus general drift automation | Can enforce future coverage, at the cost of new machinery and exclusions without a demonstrated recurring drift pattern. |

SL combines S with meaningful navigation. O combines completion with a precise boundary and navigation; C is evaluated with useful grouping, not a deliberately unwieldy flat list. D can use generated enumeration; that retains both D's split-navigation cost and G's mapping obligation, without a current need warranting another row. A can enforce O or C, but does not improve current content beyond those options. A literal table snapshot or test that mirrors the edit is prohibited by developer instructions; A means genuinely general drift validation. A public-entry-points label is not eligible for the existing mixture of direct tools and internal callers. Adding only the five files while continuing to claim an exhaustive27-file inventory is also invalid.

## 4. Finding-specific rubric

Scores0–5:0 absent/contradicted,3 adequate with a stated residual,5 fully supported; weighted total is sum(weight*score/5). Hard gates retain all existing meaningful entries/prose, supported links/commands, actual runtime and accepted-base authority boundaries, and language-specific descriptions. No new invocation guarantee may be invented. Correctness/usability/authority carry90% of the weight; upkeep/effort carry10%.

| Criterion | Weight | Meaning |
| --- | ---: | --- |
| Coverage truth | 30 | The stated catalog boundary accurately matches its contents. |
| Maintainer/contributor discovery | 25 | Readers can find actual operational tools and their supported callers. |
| Authority/safety accuracy | 20 | Distinguish accepted-base, CI-only and direct-use contexts. |
| Reading/navigation usability | 15 | Concise, scannable information with clear routes to other files. |
| Upkeep | 7 | Avoid duplicated descriptions and unnecessary synchronization mechanisms. |
| Delivery effort | 3 | Proportionate authoring and verification. |

## 5. Scores and recommendation

| Option | Truth30 | Discovery25 | Authority20 | Usability15 | Upkeep7 | Effort3 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 2 | 2 | 5 | 3 | 5 | 5 | 61 |
| S | 5 | 3 | 5 | 4 | 5 | 5 | 87 |
| SL | 5 | 4 | 5 | 5 | 5 | 5 | 95 |
| O | 5 | 5 | 5 | 5 | 4 | 3 | 97.4 |
| C | 5 | 5 | 5 | 5 | 3 | 2 | 95.4 |
| D | 5 | 5 | 5 | 4 | 3 | 2 | 92.4 |
| G | 5 | 5 | 4 | 5 | 3 | 1 | 90.8 |
| A | 5 | 5 | 5 | 5 | 2 | 1 | 93.4 |

Recommend O97.4. SL95 is a sound minimal alternative and fully truthful; its residual is that omitted operational purposes/caller restrictions still require opening individual source files. O fixes that discovery issue directly. C95.4 meets the four primary criteria equally and is not rejected for length alone; O avoids duplicating nine test-source descriptions and commands already navigable from the README. The modest final tie-break is upkeep, not a fabricated correctness defect. D retains complete information but imposes another navigation layer. G's authority score reflects the ongoing curated mapping needed to keep generated names from implying unsupported invocations, not an assertion that generators cannot be safe. A could prevent future drift, but a new coverage framework has no demonstrated need for this bounded documentation repair.

## 6. Concrete suggested postimage (proposal, not implemented)

Replace the heading and its following blank line with:

```markdown
## Workflow tools and helpers

This table lists the workflow tools and helpers in this directory. It excludes `*.test.mjs` suites and `Test-AgentInstructions.SelfTest.ps1`; see [the directory listing](.) for those files. Selected test commands appear below.
```

Retain the existing13 rows unchanged. Add these five rows in the existing table, adjacent to the corresponding classifier/setup/checking entries without reordering existing rows:

```markdown
| `Classify-InstructionMaintenance.mjs` | Classifies whether a change requires instruction maintenance. | Called from the accepted-base checkout by `agent-instructions.yml` with the checkout root and exact base/head revisions. It does not grant maintenance authority. |
| `Initialize-CiToolchain.ps1` | Installs the reviewed Linux Node/npm runtime and selected locked dependency trees. | Called by CI with `-WorkflowDependencies` and, for instruction jobs, `-InstructionDependencies`; requires its Linux runner environment. |
| `Invoke-MarkdownLint.ps1` | Runs outer and nested Markdown checks and preserves both native results. | Called by `markdownlint.yml` after runtime setup; requires the reviewed Linux runner runtime. |
| `Test-CheckoutCredentials.ps1` | Verifies the anonymous checkout's origin and credential policy. | Called by CI and shared helpers after anonymous acquisition; requires the expected origin and credential-free Linux runner context. |
| `Test-ExactGitPathSet.ps1` | Verifies an exact raw Git path set and optional worktree/index equality. | `Test-StyleGuideArtifacts.ps1` supplies the repository root, expected paths and mode; no argument-free invocation is supported. |
```

These descriptions state actual callers, not newly supported standalone commands. No executable change is implied. The inspected counts are not embedded in product prose: the census is27 total and18 operational; avoiding a hardcoded count does not exempt future additions from the table's stated scope.

## 7. Controlled-English implementation recommendation

1. Rename the section to `Workflow tools and helpers`.
2. State which test files the table excludes.
3. Link the directory listing for those files.
4. Add the five missing operational helpers.
5. Describe their actual callers and prerequisites.
6. Preserve every existing row and the detailed sections below.
7. Finalize Last Updated using genuine UTC and the actual published baseline.
8. Run the existing focused Markdown lint and link checks.
9. Compare the same common changes with the accepted peer after PS acceptance.

Exact proposed product scope is only `.github/workflows/scripts-README.md`. It has a Last Updated field but no Version field. On genuine October5 finalization, the existing2026-10-05 value remains correct against actual PSB; do not invent a Version header or treat a topic commit as a published transition. If finalization date changes, use the genuine date. Source/body instructions and dependencies remain unchanged.

## 8. Validation and paired consequences

After selection/release, validate the one-document diff, the18 operational file matches and three-column rendering; resolve the added relative directory link and preserve existing links. Use the existing pinned Node24.18.1 and installed Markdown lint API for this document, without installs or new repository tests. Existing test suites/aggregate are not rerun for proposal preparation; root owns the required single final-input aggregate/lifecycle. A read-only census of all tracked H content found no `#script-inventory` fragment references, so the changed heading breaks no tracked inbound fragment. Unknown external anchors are not claimed exhaustively checked.

The same five operational omissions exist in accepted TF56. Future selected carry-back adds scripts-README.md to the prior four-path conditional repair, under A07; A21 remains owner of the engine/SelfTest/classifier deltas. Root owns affected transfer3 counters and release after actual PS landing. Do not blindly copy this entire document to TF: retain TF's actual `Test-StateRecoveryExamples.mjs` row and recovery-child description, T1 provenance link, and native `verify` check name. PS retains Test-BlankLineExamples, P1 and verify_generated_artifacts. The name `Test-StateVersionRecovery.ps1` is absent from the inspected accepted TF tree and must not be introduced. The coupled source/caller differences remain with their existing owners.

Evidence.json pins both27-file censuses, source modes/blobs/hashes, table membership, omitted-file categories, current callers, metadata instructions and before/after raw index/HEAD guards. It is a bounded source/caller inspection, not a full semantic audit or acceptance. Product, index, dependencies, native services and planning are unchanged. No proposal is posted or thread resolved here; root must display/select before release.

## Local implementation checkpoint

Selected O97.4 applied only to `.github/workflows/scripts-README.md` at H `f77a58dede8f6f68b45e0d62e5b96e2fed477c58` / Bf168. Genuine finalization `2026-10-05T09:38:20.326774+00:00`; Last Updated remains2026-10-05, no Version header added.

The section now names workflow tools/helpers, explicitly excludes test suites/loaded SelfTest and links the directory. Five rows complete the18 operational entries with actual caller/authority/runtime limits. All13 old rows, existing links and complete detailed tail remain unchanged. Exact reversal of the selected heading/paragraph/five rows reconstructs the original bytes.

Postimage SHA256 `e782b1a213003ca19f4ece0ccb992f0343eaaec9f89dcc6255b376741dc20881`, 13157 bytes, mode100644. Patch SHA256 `fd1a91158c9cc0cbd490f07ce7441bc80eaf2773c613d9066b92fff52a0ac7b0`. All76 tracked files checked; exactly this file differs. HEAD and raw index hashes are unchanged. No dependency, native, ref, planning or staging operation occurred.

Pinned Node24.18.1 focused verify.cjs exited0. Actual existing lintOuterMarkdownContents API linted this document with the repository config. Rendering has19 rows (header plus18 tools), each3cells; catalog coverage matches exactly. Every relative link target exists and the new directory target is a directory. Old links are unchanged; existing anchor targets were not separately revalidated. No new repository test, install, suite or aggregate. Log SHA256 `e81564d8a27b3c557f4e118e5101777b9c8915ae889bd28176d25266edc7dbcb`; exact command/timestamps are in verification-command.json.

Future accepted-source TF carry-back gains this fifth path under A07; preserve TF's actual recovery child, T1 link and verify check name. No TF write or counter change is released. Root owns combined staging, one final aggregate, normal lifecycle and review. Author will not change this frozen file without a new release.

Final evidence SHA256 `e3d1f661c423167d495543845911eb15930a753680b3b28b225cf540bc6c74f0`.
