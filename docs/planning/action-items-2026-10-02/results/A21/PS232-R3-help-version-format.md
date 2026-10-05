# PR232 R3 — unambiguous PowerShell help versions

Selected A97.2 by the coordinator after public options, rubric and scores on 2026-10-05. Three identical Copilot comments4181830632/4181830689/4181830739 form one finding on Haafa9a4a41318d0cf1b61d873b321567b31ac985, basef168f83b89f64b6bca9d520ddec4b58969060fb6. The selection preceded the bounded implementation release. Validation and native acceptance remain separate.

## Validation and actual impact

All three flagged Version lines end in a period. Immutable B/H comparison proves these are the COMPLETE set of dotted annotations whose tuple this PR changed: Get-PublishedBaselineDocumentContext, Get-DecisionRecordLifecycleFailure and Get-DocumentMetadataContext. Their punctuation already exists in accepted PSB. The main file has48 dotted annotations among71; SelfTest has1 among13. Thus the same bounded formatting issue exists in49 actual helper values, not just the review samples.

Actual PowerShell7.6.5 Parser/GetHelpContent reads the two existing source files without executing their function bodies. Parsing has zero errors. All49 help Version values retain the terminal period. The documented System.Version.TryParse rejects49/49 complete values and accepts49/49 after removing the final period. The initial three-value probe and complete census probe are both retained with commands/hashes. This proves direct numeric-value copyability, not a runtime malfunction of the validator.

No current executable consumer of PowerShell Notes Version was found in the complete tracked code census. Get-DocumentMetadataContext at6304–6326 parses strict Markdown `**Version:**` paragraphs; its own help comment is not that input. Related SelfTest regexes and root-guide mutations likewise consume Markdown. Native help exposes Notes text without interpreting these as a numeric version. There is no demonstrated currently failing build, unsafe classification, strict version-extraction script or admission bypass. Do not invent one to justify this correction.

## Governing instructions and applicability

Accepted and current STYLE_GUIDE bytes are identical. Quick reference86 requires a Notes version in the four-part format. Help-quality850 requires internal version information. Private-helper864 says the banner supplements the other comment-help requirements; it does not exempt version metadata. The specific versioning paragraph1023 names distributable functions/scripts and requires System.Version-compatible format, while1053 shows a bare four-part Version value. The private functions are explicitly not public APIs, so do not claim their private status creates a public interface guarantee. Read these requirements together: private documentation still needs an unambiguous version, and the existing four-part representation supplies it. Removing terminal punctuation aligns the copied field with the documented type without redefining API status. Historical acceptance establishes provenance, not a permanent formatting exemption.

The numbers themselves identify valid four-part tuples; ambiguity is whether sentence punctuation belongs to the field value. The help probe shows it remains in the displayed field. The useful improvement is accurate structured documentation and direct copyability, not protection from a hypothetical tool. Official [.NET documentation](https://learn.microsoft.com/en-us/dotnet/api/system.version.tryparse?view=net-10.0) requires numeric components and illustrates rejection of a trailing period. [PowerShell comment-help documentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help?view=powershell-7.5) describes Notes as supplemental text, not an enforced semantic-version parser.

## Stakeholders

Maintainers, contributors and review operators need truthful easy-to-copy version values in real help output. Both repository owners need one common implementation and lawful destination metadata. Security reviewers need unchanged parser/authority/status behavior and no fabricated failure claim. QA needs a bounded real-format discriminator instead of a new literal-mirroring suite. Historical/audit owners need current modification dates without rewriting old evidence; workflow operators need old service failure retained separately. No runtime dependency, cloud/customer-data/credential, permissions, accessibility, language-guide or generated-output change is proposed. Difficulty/churn is a small criterion, not a substitute for conformance.

## Options before rubric

- **N — retain all punctuation.** Record no current version consumer. Avoids changes but leaves displayed values incompatible with direct use in the documented type.
- **T — normalize the three actually updated dotted annotations.** Solves every review sample/currently changed tuple. Leaves46 demonstrated instances of the same documentation problem.
- **F — normalize all48 dotted main-validator annotations.** Resolves the main file consistently; the same existing SelfTest instance remains.
- **A — normalize all49 in the two files.** Resolves the complete bounded source census. Apply genuine modification-date and published-baseline revision rules to affected helper comments.
- **G — add universal Notes parsing/lint enforcement plus normalization.** Prevents future recurrence, but introduces a new policy consumer/scope and possible comment-help format/interface rules; existing code has no such consumer.
- **D — amend the guide to allow punctuation or define trimming.** Makes the human format explicit but changes normative/generated guidance to preserve less directly usable values. Requires separate language-guide authority.
- **P — retain punctuation and add trimming to a consumer.** A real consumer could reasonably tolerate punctuation, but none currently exists here; this creates an unnecessary mechanism and leaves displayed fields unchanged.

T/F/A plus a lint rule reduce to G. A clarification-only comment without normalization is N/D with more prose and does not change the returned Notes value. Removing whole Version annotations or private banners violates retained help requirements. Global rewriting of unrelated scripts, .NET version fields or Markdown metadata is not the bounded49-value finding. F/A remain viable alternatives, not excluded for churn or PR-loop cost.

## Distinct weighted rubric

Compatibility30 measures the complete49-value observed set against existing help/version guidance and the documented type. Human clarity/copyability25 measures actual Notes output and consistent field interpretation. Preservation20 protects executable APIs/authority and lawful source/destination metadata, not immutable spelling. Common convergence15 requires a supported identical common outcome after actual peer lifecycle. Verification5 rewards meaningful bounded source/help evidence. Maintained complexity3 and implementation effort2 measure new machinery/ongoing cost. Scores0 absent or harmful,3 partial with stated limits,5 complete scoped fit; total=sum(weight × score)/5. Judgments are not measured runtime reliability.

Hard constraints: no invented consumer/runtime failure or private-helper blanket exemption; preserve banners, operative code and tests; no fictitious clock, semantic bump or publication history; no ignored true peer delta. A guide rewrite cannot be implemented under this source-only scope.

| Option | Compatibility30 | Clarity25 | Preservation20 | Convergence15 | Verification5 | Complexity3 | Effort2 | Total/100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 2 | 2 | 5 | 5 | 4 | 5 | 5 | 66 |
| T | 3 | 3 | 5 | 5 | 5 | 5 | 5 | 78 |
| F | 4 | 4 | 5 | 5 | 4 | 4 | 3 | 86.6 |
| A | 5 | 5 | 5 | 5 | 4 | 4 | 2 | 97.2 |
| G | 5 | 5 | 4 | 5 | 5 | 2 | 1 | 92.6 |
| D | 2 | 3 | 3 | 4 | 3 | 2 | 2 | 56 |
| P | 3 | 3 | 3 | 4 | 3 | 2 | 2 | 62 |

T/F earn partial compatibility and clarity because other actual same-format values remain. A/F earn full preservation/convergence: broader work is not inherently unsafe. Their slightly lower verification/maintenance/effort values reflect more baseline tuples and paired proof, not a hard scope exclusion. G gains prevention/verification but adds a new parsing contract and policy-enforcement boundary. N honestly preserves working behavior yet leaves the demonstrated format ambiguity. A wins on completeness and usability even after its greater effort is counted. The earlier provisional T100 table evaluated only three samples and is superseded before selection by this full49-value assessment.

## Selected controlled-English solution — A97.2

1. Keep this as one finding. Link all three duplicate comments to it.
2. Remove the final period from each of the49 listed helper Version values in Test-AgentInstructions.ps1 and Test-AgentInstructions.SelfTest.ps1.
3. Preserve every Major and Minor component. Preserve private banners and executable code.
4. Use the actual modification date for each changed helper. Compare its tuple with that helper's actual published PS baseline.
5. For genuine October5 finalization, use Build20261005 and revision0 for every listed helper. All49 published PS Builds are older. Keep the selected Get-DocumentMetadataContext1.7 line.
6. Keep the already-current enclosing script versions1.18.20261005.0 and1.8.20261005.0. Do not assign them again merely to create an in-progress increment.
7. Recalculate if date or published inputs change. Do not backdate to preserve equality.
8. Compare the exact source diff against the49-row catalog. Prove that executable tokens, nonselected help and tests remain unchanged.
9. Repeat only the bounded actual-help/type-format check on repaired values as needed. Add no literal-mirroring test or universal linter for this correction. Root owns required final-input validation and the normal native lifecycle.
10. After PS acceptance, compare against fresh TF. Carry useful common changes with lawful TF destination arithmetic. Do not assume current TF same-day tuples permit blind copying or invent a period-only exception. Root owns transfer counting and release.

Exact proposed edit surface is TWO existing PowerShell files only. Of49 helper lines,3 already have October5 tuples;46 require genuine current-date synchronization along with period removal if edited today. This is not49 algorithm changes. The existing six-note carry-back and newly selected comment normalization must be reconciled as one actual A21 delta rather than double-counted. No parser change, guide/protected text, test fixture, package, dependency or new file is needed. Root released this exact two-file repair after selection.

The six-note readiness report remains historical conditional evidence; broader normalization changes that future exact set. Final TF tuple choices are NOT established by this PS proposal, especially where TF already has the same day's accepted numeric version. Apply the existing rule to actual finalization and raise a concrete conflict only if one occurs. No hypothetical conflict blocks this source proposal.

## Evidence, service status and limits

`evidence.json` pins current H/B/TF raw blobs/modes, unchanged guide identities, all49 helper rows, complete changed-dotted subset, consumer census, actual comments and both bounded probes. `probe.ps1`/`census-probe.ps1` were executed with `pwsh -NoLogo -NoProfile -File ...`, PowerShell7.6.5, exit0. No product body, suite, aggregate, installation, index/ref/planning/native mutation or descendant ran. These probe results describe the pre-repair candidate at the named H. No Linux parity is claimed from the Windows help/.NET probe.

Balanced-attempt service run37278842804 reached its authenticated20-minute timeout; that remains a failure. GitHub subsequently issued valid current-head review5411547544 explicitly atLite with these three duplicate findings. Lite completes the review request under the active preference/fallback rule. It is not Balanced success and is no reason for another request. Root alone handles replies, resolution, final selection and native lifecycle.

## Execution checkpoint

The coordinator independently opened both primary references, checked the complete proposal and evidence hashes, sampled the baseline catalog, and recalculated all seven totals. The existing PR owner has the two-file repair. No new review has been requested. Round2 remains terminal with findings; rounds2/80, fixed deadline2026-10-13T06:26:07Z and directional transfers are unchanged. No owner decision is needed.

## Implemented source and bounded verification

The selected49-line repair is implemented on staged tree `95d5e8a1f46040c2044717e156e81638f1764bb3`, based on Haafa/Bf168. All76 tracked paths were checked; only the two selected files changed. Reversing the49 catalogued lines reproduces both exact original files. Major/Minor values, private banners, enclosing script notes and all executable bytes are preserved. Root independently read the full diff and checked actual published-baseline arithmetic.

Windows PowerShell7.6.5 and PSScriptAnalyzer1.24.0 checks passed. Both complete pre/post files parse with zero errors. All49,541 main and27,350 SelfTest non-comment tokens retain identical Kind, TokenFlags and Text. All49 actual help values pass System.Version.TryParse. Default analyzer rules at Error/Warning severity report zero diagnostics. This does not establish execution or Linux equivalence. Verification log SHA256 `df484f58be956ce105f3f2251085204013e9fc86826efc69039b69d04e693403`; source handoff evidence SHA256 `d8f83937e11da79372c7e1e9d96ac315ce686d41282b88f84e5493935bbbe1d8`.

One required full Linux aggregate is running on the frozen final bytes with1910 unchanged dependency files. Independent source quality is also in progress. Full aggregate, commit-time hooks, actual committed endpoints, new-input native review and paired acceptance remain unaccepted. No new review request or merge has occurred.

## Local final-input acceptance

The one final-byte aggregate passed all11 hooks with zero skips. The outer process exited0 and verified unchanged source, index, configuration,1910 dependencies and shared refs. Normal commit hooks passed for `f77a58dede8f6f68b45e0d62e5b96e2fed477c58` with the reviewed tree. Actual accepted-B/current-H classification, FinalizeMetadataNow, MetadataClassificationOnly and ProposedPolicy checks passed at the genuine UTC date. The fresh ordinary two-root dependency audit returned CLEAN with no findings or exceptions. [Independent bounded source quality](../A02/ps232-round3-source-quality.md) passed. Native review, merge, landed behavior and paired convergence are still required.

Planning-only correction: the first publication check stopped before staging on MD012 because the inserted status paragraph had one extra blank line. That line was removed. The publication command reruns planning validation and Markdown lint before committing. Product validation is unchanged.
