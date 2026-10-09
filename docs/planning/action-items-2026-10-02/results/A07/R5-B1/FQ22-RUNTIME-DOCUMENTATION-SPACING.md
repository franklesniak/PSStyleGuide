<!-- markdownlint-disable MD013 -->
# FQ22: Readable runtime versions and limits

- **Status:** Accepted
- **Owner:** A07 coordinator
- **Last Updated:** 2026-10-09
- **Scope:** PR239 review comment 4225004631; numeric prose and the same pattern in scripts-README.md.
- **Related:** [Owner decision process](../../../DECISION-PROCESS.md), [review finding](https://github.com/franklesniak/PSStyleGuide/pull/239#discussion_r4225004631)

## Context and validation

At commit `4eabb04bc8fa2f12c327ea6be8f7450ab0aa3032`, the runtime section joins names, numbers and units: curl8.5+, major8, Windows2.39+, schema2, Linux22.23.3/npm10.9.9, 1GiB, connect20, is483, a300-second, a966-second, Node22 and GateA/B. The helper table also says Node22. The missing spaces are visible in the source and rendered prose. Linux22.23.3 additionally obscures that 22.23.3 is a Node version, not a Linux distribution version.

Documentation authors, new contributors, non-native-English readers, accessibility users and UX reviewers need readable boundaries and named units. Operators and security reviewers must distinguish a retry-admission limit from a process deadline. QA needs every affected occurrence checked while preserving all values. Maintainers, project managers and business stakeholders need an accurate correction without unrelated document redesign. No runtime, settings, private data or generated artifact changes follow from this finding.

## Alternatives considered

1. Keep the current text. The values are recoverable but need unnecessary interpretation.
2. Fix only Copilot's quoted examples. This leaves the same defect in unquoted text and the helper table.
3. Correct all instances in the affected file. Use readable prose and preserve exact numeric values and identifiers.
4. Rewrite the whole document. This can improve unrelated text but expands semantic review and creates avoidable drift risk.
5. Apply automatic spacing replacements across the repository. This could corrupt identifiers, versions, paths and historical evidence.
6. Convert the runtime section to tables and audit remaining prose. This is viable but splits connected explanations and adds structural work for a spacing defect.

A full-file inspection accompanies options 3 and 6. Combining a table conversion and wholesale rewrite retains option 4's extra semantic risk. A linter rule for arbitrary word-digit adjacency cannot reliably distinguish legitimate identifiers from prose and is a variant of option 5. Removing the operational explanation loses useful safety guidance. Deferral retains option 1's known usability defect.

## Rubric

Scores range from 1 (poor) through 3 (adequate with limitations) to 5 (strong). Total is the sum of weight multiplied by score divided by five. Weights are specific to this documentation finding.

| Criterion | Weight | What a strong score means |
| --- | ---: | --- |
| Reading clarity | 35 | Names, versions, units and retry behavior can be understood without decoding compressed tokens. |
| Behavior fidelity | 25 | Numeric values, limits, supported platforms and distinctions between retry admission and process deadlines remain correct. |
| Pattern completeness | 20 | All affected occurrences in the file, including its helper table, are corrected. |
| Accessibility | 10 | New and non-native-English readers can distinguish concepts using ordinary spacing and wording. |
| Verification | 7 | Review can establish the bounded semantic change with source comparison and existing Markdown tooling. |
| Editing cost | 3 | The repair avoids unrelated churn or new tooling. |

Hard constraints: retain command flags, paths and identifiers verbatim; preserve every numeric value and security/runtime condition; preserve the two different curl policies and future recovery acceptance boundary.

## Scores

| Option | Clarity | Fidelity | Complete | Accessible | Verifiable | Cost | Total /100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. No change | 1 | 5 | 1 | 1 | 5 | 5 | 48.0 |
| 2. Quoted examples only | 3 | 5 | 2 | 3 | 4 | 5 | 68.6 |
| 3. Full pattern correction | 5 | 5 | 5 | 5 | 5 | 4 | 99.4 |
| 4. Whole-document rewrite | 4 | 3 | 5 | 4 | 3 | 1 | 75.8 |
| 5. Repository-wide replacement | 3 | 2 | 4 | 3 | 2 | 4 | 58.2 |
| 6. Tables plus audit | 5 | 4 | 5 | 4 | 4 | 3 | 90.4 |

Option 3 wins through complete, directly reviewable clarification. Option 6 is reasonable but adds structural changes without fixing a different material problem. The scores describe expected tradeoffs, not empirical usability measurements.

## Decision and controlled implementation instructions

Date: 2026-10-08. Select option 3. The options, rubric, scores and selection were displayed before the product edit.

1. Add spaces between product names, versions and units.
2. Identify 22.23.3 as the Node version on Linux.
3. State each timeout in seconds.
4. Keep the retry count separate from the timeout values.
5. Keep all command identifiers and numeric values.
6. Check the complete file for the same pattern.
7. Compare the limits with the implementation.
8. Run the existing Markdown checks.

These instructions use short direct actions and consistent technical names. No formal ASD-STE100 dictionary certification is claimed. The FQ21 minimum-version explanation shares this file but remains attributed to its own decision. Current documentation guidance already requires clarity, complete consistency fixes and fidelity; no protected guide edit is proposed.

## Consequences and verification

The text becomes easier to read without changing runtime behavior. Some compact prose becomes longer. No new runtime test is needed for spacing alone. At the decision date, the file's Last Updated was 2026-10-08. Recheck the UTC date at final publication. The implementation results below describe the later repair.

## References

- [Reviewed scripts documentation](https://github.com/franklesniak/PSStyleGuide/blob/4eabb04bc8fa2f12c327ea6be8f7450ab0aa3032/.github/workflows/scripts-README.md).
- [Reviewed initializer and actual limits](https://github.com/franklesniak/PSStyleGuide/blob/4eabb04bc8fa2f12c327ea6be8f7450ab0aa3032/.github/workflows/Initialize-CiToolchain.ps1).
- [Applicable documentation instructions](https://github.com/franklesniak/PSStyleGuide/blob/4eabb04bc8fa2f12c327ea6be8f7450ab0aa3032/.github/instructions/docs.instructions.md).

Implementation and validation 2026-10-08T23:20:34.961278+00:00: Applied locally: complete-file pattern audit corrected the affected table/section without changing identifiers or numeric limits. Node 24.18.1 outer and nested Markdown checks both ended 0 over 24 files and 23 nested blocks. The existing F4 parameter-ownership assertion also passed. Independent review and later final publication gates remain. [Markdown result](current-main-validation/fq22-markdown.json).

Final date check, 2026-10-09: the instruction validator required Last Updated to match the publication date. The date was changed to 2026-10-09. Independent comparison verified this single-line change and confirmed that all other captured source files were unchanged. The required full hook run on these final bytes remains a separate gate.

Final integration, 2026-10-09: the repair is published in [commit c1ef946](https://github.com/franklesniak/PSStyleGuide/commit/c1ef946fe4585836f27a0a4480bd986899d7c316). Independent final local review passed. All eleven configured hooks passed on the final staged files, and the normal Git commit hooks passed. The outer controller retained a failure for two 69-byte temporary files compatible with PowerShell policy probes. A separate exact-run verification accepted the genuine hook results and preserved those files and the original controller failure. Current public reviews, passing CI and landed acceptance remain required.

Round3 applicability, 2026-10-09: [comment 4231950276](https://github.com/franklesniak/PSStyleGuide/pull/239#discussion_r4231950276) identifies the same numeric-prose spacing defect in `docs/dependency-maintenance.md` at published `2b5514c`. The complete file inspection found exactly one `Node22` and one `schema2` occurrence, both on line 72. Existing stakeholders, hard constraints, six options and rubric apply unchanged: full pattern correction remains 99.4/100. Options, rubric and table were displayed again before editing. Add exactly two spaces. Keep all identifiers, values, commands, links and behavior. This is the same FQ22 decision. Validation and final publication remain pending.

Round3 local result, 2026-10-09: the two spacing corrections and the current Last Updated date are saved in the integration worktree. The complete-file diff changes only those three lines. Native Node 24.18.1 Markdown checks f40ff4 passed for the product document and this decision, with zero outer errors and zero nested blocks. All11 final hooks passed with zero skips, native6608/81cd16 and strict acceptordee39e. The [normal commit](current-main-validation/pr239-round3-v5-normal-commit.json) is11224a2f58e2cb1e2ffb3ab443ccc83dd0822950, with staged, repository and nested Markdown hooks passed at native0/c6b968. Publication and new-head reviews/CI remain pending.
