<!-- markdownlint-disable MD013 -->
# R14 — finite historical tuples and current runtime maintenance

## 1. Validate and check existing authority

Comment4179817842 proposes a maintainability refactor, not a current runtime failure. The literals are deliberate historical compatibility data. [A03 D9 A-C98 and F97](copilot-setup-decisions.md) already select these exact finite cases, fixed version-to-digest selection, and the historical24.18.1 prepare exception. This proposal reuses that compatibility decision; it does not reopen its historical eligibility or create another compatibility policy. The narrower new question is whether centralizing those facts materially improves current maintenance.

Current declared setup reads Node from root `package.json.engines.node` and the archive digest from `ci-toolchain.json.linuxX64Sha256`. Only declaration-absent setup uses the historical literals. Actual classification passes24.18.0/npm11.16.0 as Node-only with Python absent, and24.18.1/npm11.16.0 with complete inputs as full. Unknown historical24.19.0 and wrong historical npm11.17.0 fail. Missing required24.18.1 inputs fail. A declared synthetic24.19.0/npm11.17.0 full tuple passes classification and its actual selector prefix returns24.19.0 and the declared digest. Thus future current version bumps do not require updating the immutable historical tuples. The selected runtime is still subject to later real version/digest/install checks, which this diagnostic does not execute.

Each platform runs11 R14 controls: seven actual classifier cases and four actual selector-prefix cases. The workflow has real duplication across two languages/phases, but no demonstrated current high-churn update obligation. An eventual intentional expansion or retirement of historical support would warrant a new compatibility assessment.

Input: TF `dde2b9abe761af69a7f561512df7d44d0dec6745`, tree `d59a740b7b1d88f7986075ac9328d9998629aa71`, accepted B `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`. The authenticated comment is saved in `review-comments.json`; raw blobs/modes/SHA256 are in `source-identities.json`. The current published CI/aggregate results belong to root; this decision claims only the focused private evidence below.

The Windows and Linux `result.json` files each contain 53 actual command records: 12 private Git fixture initialization/staging commands and 41 behavioral controls. The immutable production source was copied to private fixtures; it was not repaired or stubbed. Four dependency omission fixtures use real package resolution, with the chosen package absent and other packages linked to the unchanged installed graph. Config fixtures use actual glob and loaders. Only the R14 download phase is intentionally excluded: its actual selector prefix stops before download/extraction and emits the selected values. Synthetic future values establish selection behavior, not availability or installation of that future runtime. Each child has a 45-second/2-MiB diagnostic bound. No product suite, aggregate, npm install or GitHub mutation ran.

Windows uses Node24.18.1 and host PowerShell7.6.5/Git Bash. Linux uses existing image `sha256:455394ca075981fe23d0a7b84cbeaa63d5ca8a8f49bd045fcd2a2082b2fbb22d`, Node24.18.1/PowerShell7.6.3, network disabled, immutable dependency archive SHA256 `ca51b12b42f4d018498160a4c3fe3530eac72b2829328c5d8b2e985df9c55323` copied into container temp. Linux command/log are in `linux-run.json`/`linux-run.log`; terminal exit0 took14.609 seconds. Windows session4128 and Linux session98536 both terminated successfully. These are bounded diagnosis controls, not renewed full-suite acceptance.

## 2. Stakeholders

Historical PR authors and both maintainers need old supported trees to stay reviewable. Current contributors and automation operators need current declared versions to be independent of history. Supply-chain/security reviewers need exact reviewed archives and honest full/subset results. QA and CI engineers need cross-phase consistency without inventing a new configuration distribution dependency. History custodians need historical facts to remain fixed when current pins change. New maintainers benefit from clear names; cost stakeholders want evidence-driven maintenance. There is no changed deployment, recovery, personal-data or access-control interface; those operators have no separate requirement here.

## 3. Options before the rubric

- N: Keep the selected finite literals and existing current-declaration authority. Link this report to D9/F97 and the new applicability proof.
- B: Put all historical tuples/digests in one well-named in-workflow data block shared across phases. A short explanatory comment is included where useful. This preserves semantics but requires an explicit Bash/PowerShell handoff or repeated decoding.
- F: Put finite historical tuples in a separate authoritative profile file. Unlike current declarations, this file would need a compatible delivery/read strategy for old trees that lack it.
- C: Derive historical compatibility values from the current package/declaration. This conflates distinct current and historical roles and fails the retained-history constraint.
- D: Clarify each existing phase with named local constants/comments or existing documentation. It preserves executable duplication; adding B's shared block instead is already B.
- R: Retire declaration-absent historical setup. This needs an explicit change to the retained support contract; it is not a maintenance-only repair.
- T: Leave the code now and schedule a refactor for a future demonstrated additional historical case. N already permits reconsideration when inputs change, so an unconditional future task adds little.

B plus comments/docs is B; F plus inline fallback recreates two authorities unless the fallback is the same explicit finite policy. No combination permits current pins to silently redefine history.

## 4. Finding-specific rubric

Scores use0–5:0 violates the objective,1 very weak,2 materially limited,3 useful with significant tradeoffs,4 strong with a stated residual,5 meets this finding's objective on the available evidence. Total is sum(weight × score)/5. Scores are engineering judgments, not empirical probabilities or test results. Hard constraints override totals. Cost/churn have deliberately low weight.

History35 measures exact retained old capabilities and digests. Current authority25 measures independent declared-version selection and no implicit downgrade. Clarity15 measures truthful operation and maintainers' understanding of fixed history. Cross-phase proof15 measures falsifiable agreement between classifier and selector. Maintenance8 measures fewer independent facts without new required old-tree inputs. Effort2 measures implementation and meaningful revalidation cost.

Hard constraints: preserve evidenced historical cases and fixed digests; preserve current declarations; reject unsupported/partial tuples; report Node-only honestly; keep exact runtime verification, permissions and policy authority unchanged. Neither retirement nor deriving historical values from current pins can pass these constraints as a scoped refactor.

## 5. Scores before selection

| Option | History 35 | Current authority 25 | Clarity 15 | Cross-phase proof 15 | Maintenance 8 | Effort 2 | Total | Basis / uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 5 | 5 | 4 | 5 | 4 | 5 | 95.4 | Existing finite behavior is demonstrated; repetition remains but future current bumps do not change it. |
| B | 5 | 5 | 5 | 4 | 3 | 3 | 93 | A shared historical block can improve naming, but needs a Bash/PowerShell cross-step representation and fresh propagation checks. |
| F | 5 | 5 | 4 | 4 | 2 | 2 | 88 | Separate historical profile adds required-file availability and compatibility work for old checked-out trees. |
| C | 1 | 2 | 3 | 2 | 4 | 4 | 40 | Ineligible: current declarations cannot replace independent fixed historical authority. |
| D | 5 | 5 | 5 | 4 | 3 | 4 | 93.4 | Comment/naming clarification can help; duplicated executable facts remain and no actual confusion in runtime behavior was found. |
| R | 0 | 5 | 2 | 5 | 5 | 4 | 55.6 | Ineligible in this scope: removes explicitly retained historical capability. |
| T | 5 | 5 | 4 | 4 | 3 | 4 | 90.4 | Keeps behavior while tracking a speculative later refactor; an evidence-triggered reconsideration already suffices. |

N is recommended on the actual role distinction and executed behavior. The score does not claim that factoring is technically wrong. B improves naming but introduces cross-phase data handling without an actual future-current-bump obligation; D is a reasonable explanatory alternative, but existing comments/canonical documentation already state the boundary. Reconsider if a real historical expansion creates inconsistent facts.

## 6. Selected controlled-English disposition

Retain the current workflow. Keep the historical tuples fixed. Read current versions from the current declarations. Link the review disposition to D9 A-C98 and F97. Include the declared-future selection proof. Reassess this decision if supported historical cases change.

These short instructions follow the owner's controlled-English intent; no formal dictionary certification is claimed. Product implementation scope is empty. No guide text, metadata or protected instruction changes are needed.

## 7. Verification and remaining limits

All11 focused controls passed on both platforms. Existing `Test-CiHelpers.test.mjs`1050–1083 retains current/historical/unknown/missing capability tests;1238–1257 retains the finite prepare cases. No new durable mirrored test is proposed. Reuse existing accepted full validation. Root selected this disposition after displaying the options, unique rubric and checked score table. Native thread resolution is recorded separately in the canonical peer state. No separate future runtime release or download was tested.

## Coordinator selection and evidence

At 2026-10-05T00:05:51.884809+00:00, root selected N (95.4/100) after displaying the options, separate rubric, full score table and selected steps to the owner in that order. No further owner decision is needed. Implementation scope is empty: retain the current product bytes and record the supported no-change disposition. The native review still contains three findings; resolution is not relabeled as a clean reviewer result. Fresh review-facing decisions, remote review and final independent quality remain in the normal lifecycle.

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
