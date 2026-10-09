<!-- markdownlint-disable MD013 -->
# FQ30: exact ordinary initializer declaration values

## Validation and scope

Root native982728 executed the actual Assert-Shape helper and declaration-admission statements from Initialize-CiToolchain.ps1 SHA20fd176523d46168642b812f3ed28449bbf10f4503003d1b695981ce0b8e7740. Windows PowerShell7.6.5/.NET10.0.11 admitted two valid grammar controls, incorrectly admitted five terminal-line-feed values, and refused28other malformed controls. Evidence: C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-R5-B1-implementation-20261007/fq30-ordinary-admission/result.json, SHA540e94963b202d555f0d58af1c37c06e86dbce3402915c503ddeaf30f3200660. Exact native argv is recorded there; parent deadline30seconds. This was an in-memory admission-stage test, not an installer, download, platform, or checksum-bypass demonstration. One valid grammar control uses24.18.2; it does not establish release availability.

The three predicates use ^/$ for preferred Node, npm, and all three digests. The fixed recovery versions already use exact equality. .NET permits $ before a final LF. This violates the existing whole-declaration preflight contract before staging/downloads. FQ27 fixes the same regex property in privileged workflow readers; this record addresses the separate ordinary initializer consumer in PR239. No new supported declaration format is selected.

## Stakeholders

Maintainers and senior engineers need complete, consistent validation. New developers and documentation readers need a direct rule they can explain. Windows/Linux users and recovery operators need valid declarations to continue working. DevOps and platform engineers need refusal before setup or network activity. Security engineers and accountable security leaders need every digest checked, including an inactive role. QA and auditors need actual-source tests, malformed controls and honest proof limits. User-experience and business owners need actionable failure instead of later download errors. Project managers prefer a finite repair. Accessibility, privacy, localization, and cloud administrators have no changed interface or data flow in this predicate repair; no separate tradeoff changes selection.

## Options (displayed before the rubric)

1. Replace the three regex boundary pairs with absolute string anchors. Preserve each existing grammar and fixed recovery equality.
2. Keep the regex and additionally require a successful match to cover the complete input value.
3. Replace the predicates with explicit non-regex version and hex parsers.
4. Add an explicit newline/control-character prefilter before existing predicates.
5. Factor a trusted shared validator and load it from each consumer.
6. Validate only the current platform and selected role.
7. Trim whitespace or newlines before validation.
8. Leave current behavior or defer the repair.

Every implementing option includes malformed and valid controls. Adding tests to options1-5 is part of those options, not a competing strategy. Combining2and4duplicates boundary checks without stronger admission. Factoring can include1-4 but introduces a trusted-loading change. Options6-8cannot meet the current complete-value, whole-declaration requirement. No owner decision is missing that would justify deferral.

## New rubric (displayed before scoring)

Score0means unsatisfied,1weak,2partial,3adequate with material uncertainty,4strong with a limited disadvantage,5fully suitable. Total=sum(weight*score)/5. Scores are comparative engineering judgments, not measured probabilities.

| Criterion | Weight | Meaning and perspective |
| --- | ---: | --- |
| Whole-declaration correctness | 35 | All declared versions/digests retain exact grammar; no platform blind spot. Maintainer, QA, technical security. |
| Early refusal | 25 | Refuse invalid input before environment publication, staging or download. DevOps, operations, security accountability. |
| Valid-input compatibility | 15 | Preserve ordinary Windows/Linux and fixed Linux recovery declarations. Users, recovery, UX, business. |
| Verification strength | 15 | Actual source, positive/negative controls and proof of meaningful regression. QA, audit, engineering. |
| Clarity and maintenance | 7 | One obvious boundary rule with low drift risk. New developer, documentation, maintainers. |
| Implementation effort | 3 | Finite work and delivery disruption. Project management; lower priority than correctness and usability. |

Hard constraints: retain whole-declaration checks, exact values without trimming, trusted code boundaries, early refusal and existing valid behavior. Scores cannot waive them.

## Scores (displayed before selection)

| Option | Correctness35 | Early25 | Compatibility15 | Verification15 | Clarity7 | Effort3 | Total | Main uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| 1 Absolute anchors | 5 | 5 | 5 | 5 | 4 | 5 | 98.6 | Requires knowledge of .NET absolute anchors |
| 2 Full match length | 5 | 5 | 5 | 4 | 3 | 4 | 93.6 | Separate match-object/length logic can drift |
| 3 Explicit parser | 5 | 5 | 4 | 4 | 2 | 2 | 88.0 | New parsing details and compatibility surface |
| 4 Newline prefilter | 5 | 5 | 5 | 4 | 3 | 5 | 94.2 | Split checks and field lists can drift |
| 5 Shared validator | 4 | 4 | 3 | 4 | 4 | 1 | 75.2 | Trusted loader and historical boundary design |
| 6 Selected platform | 2 | 2 | 4 | 3 | 5 | 5 | 55.0 | Ineligible: leaves declared fields unchecked |
| 7 Trim values | 1 | 1 | 2 | 3 | 4 | 5 | 35.6 | Ineligible: admits malformed values |
| 8 No change/defer | 0 | 0 | 5 | 1 | 4 | 5 | 26.6 | Ineligible: confirmed defect persists |

## Selected solution

Option1wins. It enforces the complete value in each existing predicate. Options2and4split one validation rule across multiple checks. Option3requires a new parser. Option5requires changes to the trusted loading boundary.

1. Open `.github/workflows/Initialize-CiToolchain.ps1` in the PR239 worktree.
2. Replace the three regex boundary pairs with `\A` and `\z`.
3. Keep the permitted version and digest formats.
4. Keep the fixed recovery versions.
5. Add dedicated tests in `.github/workflows/Test-CiHelpers.test.mjs`.
6. Test valid declarations.
7. Test every affected field with a final line-feed character.
8. Test carriage-return and line-feed suffixes.
9. Verify refusal before staging, download, or runner-file changes.
10. Keep these cases separate from the shared malformed-reader cases.
11. Run the applicable Windows and Linux checks.
12. Complete the final integrated tests before publication.

No valid declaration, security requirement, or supported platform is removed. The instructions use the local ASD-STE100 subset: short active sentences, one instruction each, consistent terms. No formal dictionary certification is claimed.

## References

[Microsoft .NET regex anchors](https://learn.microsoft.com/en-us/dotnet/standard/base-types/anchors-in-regular-expressions) establishes that $ can match before final LF, while \A and \z bind the actual string boundaries. Rechecked2026-10-09. Use \z, not \Z.

## Implementation and validation

Selected after the displayed option/rubric/table sequence. Implementation and final validation pending. Original PR239 review clock, round1/80 and A07transfers9/12 remain unchanged. No new public request or merge is authorized by this local result alone.

Implementation 2026-10-09T04:46:03.323130+00:00: three predicate edits plus two dedicated test registrations; only the two existing dirty product files changed. Actual Windows Node24.18.1/PowerShell7.6.5 test nativea60fa7: tests1/pass1/fail0/skip0, 35cases (2valid/33malformed); Node syntax passed. Exact new assertion against preserved old initializer nativeeee153/690b0c: tests1/pass0/fail1/ERR_ASSERTION, expected causal failure. Whole Linux14 malformed preflight cases remain unexecuted. Frozen postimages and exact argv are in fq30-ordinary-admission/implementation.json and targeted-result.json under the existing W directory.

Raw PSSA1.24.0 scan: zero parser errors, two warnings (modern UTF8-no-BOM source; pure unstarted Process constructor). Applicability is under independent source review; no global exclusion or product suppression applied. Automated approval review rejected the proposed isolated constructor check, giving only blocked-by-policy; that command did not execute and is not evidence. No retry/bypass.

New complete five-path backup is pr239-local-repairs-after-fq30.patch plus .zip in W; verified ZIP bytes match current worktree. Preserve these newer images through later reader integration; old backup is historical. Current source-quality review is scoped, not whole PR acceptance.

Independent source review accepted 2026-10-09T04:54:55Z. Root read the full fq30-source-quality/REPORT.md (SHA256 d4998642d8a48d27b5281c9a70b31d55f3330f046bca16e8f87b9888ff848047) and evidence21632de0. Both raw analyzer warnings are inapplicable to these exact sources: STYLE_GUIDE.md:326 requires UTF8 without BOM for this PowerShell7.3+ script; New-ArchiveProcess only returns an unstarted Process and does not perform a state change. No suppression or rule waiver was added. Parser errors0, raw warnings2, applicable warnings/errors0. The constructor probe was not executed. This source review does not replace Linux14, integrated runtime, aggregate, all11 hooks, current public reviews or passing CI. Full decision sequence and implementation are complete; final validation remains open.
