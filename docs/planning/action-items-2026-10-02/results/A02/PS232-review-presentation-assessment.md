<!-- markdownlint-disable MD013 -->
# PR232 repeated table-report assessment

Root completed validation, public options, the distinct rubric, public scores and selection on2026-10-05 before implementing this disposition. Select **N84: retain the current table**. This assesses the operational cost of repeated false reports. It does not repeat or replace [R5 N100](PS232-R5-script-table.md), which established source/rendering correctness.

## Verified problem and scope

The same allegation appeared in rounds3–7 as R5/R8/R10/R12/R13: rows allegedly begin with `||`. Exact reviewed sources and rendered outputs disprove it. The repeated reports delay the owner's required clean review pair; they do not establish a malformed product table. GitHub's review preprocessing or model internals have not been inspected, so their specific failure mechanism remains unknown.

Current H is `86f35f47cfc744780c4c419912fcdae06fdd6f83`, B is `f168f83b89f64b6bca9d520ddec4b58969060fb6`, and body SHA256 is `7221c071ff008d322c0f066b17d43b9fc2f5f44eeb98295f3a74643404015e6c`. R13 is comment4183598019 in Copilot Lite review5413989631. Current README SHA256 remains `e782b1a213003ca19f4ece0ccb992f0343eaaec9f89dcc6255b376741dc20881`. All20 source table lines begin with one pipe and have three cells. Rehashed GitHub-rendered HTML `7efdcebf0369d4ee7c6b666ed07959baa836c285fecdf057140dca8acc748892` has19 rows, including the header and18 script entries, with exactly three populated cells each. These are the unchanged [R10 inputs](PS232-R10-table-repeat.md).

## Options and stakeholders

Maintainers, new contributors and documentation readers need complete script/command navigation. Accessibility and UX require useful semantic structure. Engineers and QA need exact-content preservation and meaningful evidence. DevOps and project owners need a review process that can complete without repeated speculative repairs. Security owners require retained checks and protection. Cross-repository owners require consistent shared content and narrow language exceptions.

| Option | Approach and tradeoff |
| --- | --- |
| N | Retain the table and reply with evidence. Proven readable output; repeated reviewer misreading may continue. |
| P | Omit optional outer pipes, keeping all cells. Valid GFM alternative that removes the disputed edge syntax, but its effect on Copilot is unproved. |
| T | Change spacing/alignment. Retains familiar syntax but leaves the disputed edge tokens present. |
| L | Use a structured list. Avoids table syntax but makes script/purpose/command comparison harder. |
| H | Use an explicit HTML table. Preserves a table, with greater editing and renderer/sanitizer complexity. |
| G | Add a syntax explanation. Adds reader-facing prose without a missing user instruction or evidence that it corrects the reviewer. |
| V | Add a general structural validator. Could detect future malformed tables; this table already passes meaningful checks and exact rendering proof. A literal snapshot test would only mirror implementation and is excluded. |
| S | Change the review environment or optimize setup. Could improve full-review availability, but no qualified implementation or performance remedy has been established. Removing required validation or using unapproved paid capacity is excluded. |

P+G, P+V and T+G are separately scored below. Combining lists and HTML changes the chosen representation without adding a demonstrated guarantee. Combining V with N/T/L/H adds maintenance without fixing this false allegation. Other note/spacing combinations are dominated by the corresponding representation or the scored note combinations. A format plus S still depends on an unqualified setup remedy; it cannot inherit verified review success. Splitting/replacing the PR, resetting its clock, omitting required reviews, or treating resolved findings as a clean review is outside the authorized solution set.

## Distinct rubric

Scale0–5:0 contradicted or absent;1 weak;2 limited;3 plausible with an explicit residual;4 strongly supported;5 directly supported for the criterion. Total is sum(weight*score/5). Retain every entry, command, link, usable structure and required check. No bypass is eligible. A formatting experiment cannot receive full review-effectiveness credit before a fresh review establishes that effect.

| Criterion | Weight | High-score requirements |
| --- | ---: | --- |
| Content/rendering correctness | 30 | Complete entries and identical useful cell content, commands, links and behavior. |
| Reader usability/accessibility | 22 | Clear source and rendered comparison, portable semantic structure and useful navigation. |
| Avoiding repeated misreading | 20 | A credible direct mechanism that addresses the disputed presentation; no instruction to ignore real defects. |
| Verification strength | 16 | Direct actual-source/rendering evidence, with unknown effects stated. |
| Maintenance/convergence | 8 | Fits current tools and shared peer content without new policy or machinery. |
| Cost/churn | 4 | Proportionate implementation and required revalidation. |

| Option | Correct30 | Reader22 | Review20 | Proof16 | Maintain8 | Cost4 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 5 | 5 | 1 | 5 | 5 | 5 | **84.0** |
| P | 5 | 4 | 3 | 4 | 4 | 2 | 80.4 |
| T | 5 | 5 | 1 | 4 | 4 | 3 | 77.6 |
| L | 5 | 3 | 4 | 3 | 3 | 2 | 75.2 |
| H | 5 | 3 | 4 | 3 | 2 | 2 | 73.6 |
| G | 5 | 4 | 2 | 4 | 3 | 4 | 76.4 |
| V | 5 | 5 | 1 | 4 | 2 | 1 | 72.8 |
| S | 3 | 5 | 3 | 2 | 3 | 1 | 64.0 |
| P+G | 5 | 3 | 3 | 4 | 3 | 2 | 74.4 |
| P+V | 5 | 4 | 3 | 4 | 2 | 1 | 76.4 |
| T+G | 5 | 4 | 2 | 4 | 3 | 2 | 74.8 |

Root recalculated all eleven totals. N's low review-effectiveness score explicitly recognizes the real delay. P receives partial credit because it removes the particular source tokens, not because Copilot success has been demonstrated. Its reader score reflects source clarity: the official GFM specification recommends outer pipes for readability, while allowing their omission. L/H may avoid this allegation but sacrifice convenient authoring or comparison. S has unresolved correctness/performance evidence; the current full ordinary validation remains successful. Cost carries only4%, and is not the deciding criterion. The product AGENTS also prohibits separate formatting-only commits; this assessment requires no exception to that rule.

## Selected action and implementation

1. Keep the current table.
2. Retain all18 script entries and three columns.
3. Retain the current commands, links and meaningful checks.
4. Reply to R13 with the current source and rendering evidence.
5. Resolve the discussion after its reply is verified.
6. Record the actual service result separately from the Lite review.
7. Continue the required review loop within its original limits.

The current raw Git file and saved HTML were rehashed and their row/cell structure rechecked on Windows with Python3.12. No new product test, server rendering call, install, product edit, aggregate or transfer was necessary. Existing Node24.18.1/markdown-it rendering and actual GitHub rendering evidence remain applicable. Installed markdownlint0.40.0 MD055 defaults to consistent pipe style; this was read directly, with no rule change.

One authenticated owner reply4183672861 targets parent4183598019. Thread `PRRT_kwDOQkjdhM6pBEQO` was resolved and read back at2026-10-05T11:54:30Z. Round7 Codex5993624480 is clean. Copilot5413989631 remains Lite with a finding, even after resolution.

Service37303115319/job111740331393 reached the authenticated20-minute limit. All11 hook Passed lines printed; the last appeared at11:48:27.258Z, followed by cancellation at11:48:27.465Z. The complete-validation step therefore has no successful native completion. Its final immutable-input guard succeeded; Processing Request was skipped. Log SHA256 is `442b091837e54723751db3d20d81a8884bdbc295dfb189ae8553dc53caa3df8a`. Preserve this distinction from round6, which printed only ten passes, and round5, whose validation step succeeded before request processing was cancelled.

## References and limits

- [GFM tables](https://github.github.com/gfm/#tables-extension-), section4.10 and examples198–199: cell separators, optional outer pipes and their readability recommendation. Read2026-10-05.
- [Current source/rendering proof](PS232-R10-table-repeat.md) and [original correctness decision](PS232-R5-script-table.md).
- [Owner review-loop policy](../../LOOP-POLICY.md): duplicate applicability, genuine clean-pair requirement, original80-round/eight-day limit and unchanged transfer accounting.

This decision preserves a valid presentation; it does not claim to fix the review service or guarantee that its next report will be correct. Reopen the assessment only for new evidence or an actual limit. No required outcome is retired, deferred, merged or accepted by this record.
