<!-- markdownlint-disable MD013 -->
# A03-D12 selected decision: conform the new inline PowerShell blocks

Status: B99 selected after root review and the required user-facing display. Private implementation is active; no product repair is integrated yet. D12/D13 were unused before this allocation.

## 1. Validate the finding

Authenticated automatic Codex review5405665141, bot199175422, comment4177245991, threadPRRT_kwDOQkjdhM6oxlO_, created2026-10-04T11:18:11Z, reviews PS head69e1b0d1b0715bfc4025372c7282fe04c38178dc, treeecae3f224ffa53e007ea7f14614f3c8596671648, basefb3288934215dfa9a25114cf79ad86e60b5fb107. Its retained source is round1-auto-codex-terminal.json in the parent's setup lifecycle directory. It is a product-code review finding and therefore needs the full decision process even though the repair is formatting.

The current AGENTS.md45–48 explicitly applies guide conformance to inline pwsh workflow steps. STYLE_GUIDE.md195 requires opening braces at statement ends and closing braces on new aligned lines. The immediately following exception concerns catch/finally/else/elseif placement; it does not exempt one-line if blocks or switch clauses. The eight newly added control blocks are four main-acquisition if blocks at246/255/256/258, the historical npm-version if at494, and three switch clauses496–498. They are concrete normative violations. The newly authored Where-Object block at245 also has its closing brace inline; expand it as the same local conformance repair. The phrase 'most script blocks' is less categorical than the conditionals rule, but no applicable exception for this new block was found.

The four extracted pwsh bodies parse with zero errors under local PowerShell. The guide issue is not a demonstrated execution failure, nor proof of P1 operational severity. Existing tests exercise acquisition retries, native failures, independent main identity and historical versions, but they do not enforce OTBS. Parser success and an aggregate pass do not waive a normative MUST. Prior accepted compact Where-Object blocks also exist; this scoped remedy does not turn their unrelated rewriting into part of the finding or claim a new complete guide audit.

Exact sampled Git blobs and raw checkout/Git hashes are in inputs.json. The unmodified input files and four extracted scripts are in this private directory. otbs-parse.json records the parser result. No guide/protected instruction change is needed.

## 2. Stakeholders

The owner and both maintainers need authored PowerShell to follow their current rule without altering accepted setup behavior. New contributors and readers benefit from visible branch boundaries and consistent indentation. Experienced PowerShell users need unchanged pipeline, switch, exception and retry semantics. Agent authors and reviewers need a small diff that can be checked against the guide. QA needs parser/token and existing behavior evidence rather than a new broad formatter test. CI operators need no new runtime or suite. Documentation owners need the normative guide left coherent. The UX director's relevant concern is code readability and predictable contribution requirements. Security, privacy, cloud operators and business stakeholders have no new permission/data/deployment interface here; semantic stability and bounded review cost capture their relevant concerns. No generated-artifact or localization contract changes.

## 3. Distinct options

- N: leave the compact code because it executes successfully.
- F: expand only the eight explicitly reported control/switch blocks.
- B: expand those eight blocks and the newly authored adjacent Where-Object block. Keep executable tokens and values unchanged.
- A: reformat every inline PowerShell body in the workflow, including previously accepted unrelated constructs.
- E: add a guide/instruction exception for one-line workflow blocks.
- R: remove the new main/history or historical runtime branches to remove the compact blocks.
- X: extract the new PowerShell into helper files and format it there.
- D: defer the conformance repair to a later PR.

B combines the narrow control repair with its directly adjacent new script block. A is the broader normalization variant. A formatter is only a means to F/B/A, not a distinct outcome. X still requires the formatting fix and adds a new executable acquisition/caller interface. E would need separate protected-file authority and guide merits; it is not a smaller implementation of compliance.

## 4. Unique rubric and constraints

Scores1–5, larger is better. Normative conformance40 measures whether the newly authored constructs satisfy the existing applicable rule. Semantic stability25 measures preservation of the selected D6/D8/D9/D11 runtime contracts. Reader comprehension20 measures clear branch boundaries for contributors. Verification precision10 measures whether correctness can be demonstrated without broad unrelated testing. Change burden5 measures continuing maintenance and review cost. Total=sum(weight×score)/5. These judgments are not empirical reliability measurements.

Hard constraints: retain selected setup behavior, no protected guide/instruction change in this remedy, no new runtime/helper acquisition, no fabricated parser or analyzer pass, and do not silently leave the reported MUST violations. High scores cannot waive these constraints.

## 5. Scores before selection

| Option | Conformance40 | Semantics25 | Readers20 | Verification10 | Burden5 | Total | Assessment |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 1 | 5 | 2 | 2 | 5 | 50 | Leaves violation |
| F | 4 | 5 | 4 | 5 | 5 | 88 | Leaves directly adjacent new script block unresolved |
| B | 5 | 5 | 5 | 5 | 4 | 99 | Recommended bounded conformance repair |
| A | 5 | 4 | 4 | 4 | 2 | 86 | Unnecessary accepted-source churn |
| E | 1 | 5 | 3 | 3 | 2 | 53 | Changes rule and needs different authority |
| R | 2 | 1 | 2 | 3 | 3 | 38 | Loses selected behavior |
| X | 5 | 4 | 4 | 4 | 1 | 85 | New executable interface without need |
| D | 1 | 5 | 1 | 1 | 4 | 43 | Finding remains open |

## 6. Proposed winner and direct steps

Select B99 after root displays this table. It applies the existing rule without changing behavior. The instructions use short direct sentences and consistent names in the requested ASD-STE100 style. No formal controlled-dictionary certification is claimed.

1. Expand the four new main-acquisition if blocks.
2. Expand the new historical npm-version if block.
3. Expand each of the three historical switch clauses.
4. Expand the new adjacent Where-Object script block.
5. Place each closing brace on a new aligned line.
6. Use four spaces for the statements inside each block.
7. Preserve every executable token, string, digest, comparison and command argument.
8. Preserve pipeline continuation at the closing brace and pipe.
9. Keep unrelated accepted source unchanged.
10. Compare the old and new PowerShell token streams without newline/comment tokens. Investigate any other difference before continuing.
11. Parse every extracted pwsh body. Run the available applicable analyzer and current required conformance checks. Report unavailable checks explicitly.
12. Run the existing affected acquisition/main/history/runtime tests. Run YAML/actionlint checks for the edited workflow.

Primary repository references: [current AGENTS.md](https://github.com/franklesniak/PSStyleGuide/blob/69e1b0d1b0715bfc4025372c7282fe04c38178dc/AGENTS.md#L45-L48), [current guide](https://github.com/franklesniak/PSStyleGuide/blob/69e1b0d1b0715bfc4025372c7282fe04c38178dc/STYLE_GUIDE.md#L191-L211), and [finding](https://github.com/franklesniak/PSStyleGuide/pull/231#discussion_r4177245991).

## 7. Verification boundary

Completed: static guide/instruction/diff/test inspection; exact input capture; extraction with installed PyYAML; ParseFile on all four current pwsh bodies, zero parser errors. inspect-otbs.py and otbs-parse.json are reproducible private evidence. No production repair, PSScriptAnalyzer acceptance, focused behavioral rerun, full aggregate, native review, hosted acceptance or peer acceptance is claimed. Root must release implementation after displaying options/rubric/table. The later writer should preserve this record and append actual results.

## Root selection and implementation release

At 2026-10-04T11:31:43.208238+00:00, root had read both complete proposals, independently matched all seven sampled Git and raw worktree identities, checked the reproduction and parser evidence, rechecked primary GitHub/Git documentation, and recalculated all19 score totals. Two draft D13 arithmetic totals were corrected to Z74/O81 without changing criterion scores or the P96 winner; the original failure and short note remain in private evidence. Root displayed validation, all options, distinct rubrics, corrected tables and selected direct actions before releasing either remedy.

The existing bounded worker a03_pr231_findings now owns only the private implementation directory under C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A03-PR231-findings-20261004. Its exact source is69e1b0d/treeecae3f2. The allowed repair is copilot-setup-steps.yml plus Test-CiHelpers.test.mjs; all73 other tracked files stay exact. Root retains product integration, planning and native operations. No new owner input is required. Focused behavior/mutation checks precede one final source aggregate and the ordinary review/quality/hosted gates. No source or paired acceptance is claimed.

Frozen private proposal SHA256: b406c6744932f6b47bfb1ddcedee3de3f0f28cc383c769ed2e5ee8c04b7a4ca7.

## Implemented and independently checked

The frozen private repair expands the nine approved newly authored blocks. All four extracted PowerShell bodies parse without errors, retain their executable token streams, and return zero applicable PSScriptAnalyzer1.24.0 findings on PowerShell7.6.5. Root independently read the diff and evidence and reproduced final treec82fa2e in a separate Git checkout. The integration changes only the approved workflow and coupled test file; all73 other tracked paths are preserved. D13 shares the workflow/test repair and has its own evidence below its decision. Final strict YAML/actionlint checks pass. The real staged-input preflight passed11:56:40Z; the sole full aggregate78543 is running. Native review and source/peer acceptance remain pending. No formal controlled-dictionary certification is claimed.
