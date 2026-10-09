<!-- markdownlint-disable MD013 -->
# FQ41: Use a singular noun for the private curl helper

Date: 2026-10-09. Owner: root coordinator. Scope: PR239 round3 local repairs on published2b5514c, source-freeze-v3 and driver674df250. This decision changes only a private function identifier and its references. It grants no public-interface, protected-file, controller, retry, review-clock or transfer change.

## Validation and stakeholders

Native PowerShell7.6.5 and PSScriptAnalyzer1.24.0 checked70 exact shipping/generated forms in session70701, terminal b4d1a1, exit0. Parser errors:0. Six raw analyzer warnings comprise three copies of the unchanged New-ArchiveProcess constructor heuristic and three copies of a new PSUseSingularNouns warning at Assert-CurlCapabilities. The new naming warning is applicable: STYLE_GUIDE.md lines56 and546 require singular function nouns, including when a function works with multiple objects. AGENTS.md line48 requires zero applicable warnings. The function's internal status does not exempt it. The source has five references and the maintained driver has six references. Their exact preimages are42a9b115 and674df250 respectively.

The constructor warning is a separate, previously decided finding. FQ24 and FQ30 establish that the unchanged New-ArchiveProcess returns an unstarted Process. Its body must be proved unchanged before reusing that applicability result. No warning is suppressed and no raw-zero result is claimed.

Stakeholders are both repository maintainers, experienced and new PowerShell contributors, documentation/example readers, code and independent-quality reviewers, QA and platform/CI engineers, security owners, dependency maintainers and business stakeholders who need reliable delivery. Consistent names aid discovery and reduce contributor mistakes. Security stakeholders require preservation of every capability refusal and the fixed archive cap. QA requires exact caller coverage and fresh syntax evidence. DevOps needs no new module packaging or runtime requirement. Users and operators need unchanged behavior and no new setup. Accessibility/localization and privacy have no distinct changed input or output here; the identifier is private, and no data collection or message content changes. These perspectives favor a complete identifier correction over suppression or a new framework.

## Options

1. Keep the plural name and defer the warning. This retains behavior but violates the current rule.
2. Add an analyzer suppression or allow-list. This hides the diagnostic without meeting the guide.
3. Rename to Assert-CurlCapability and change every declaration, example, caller and test reference.
4. Rename to Assert-CurlDownloadCapability. This is compliant but adds a qualifier already supplied by the private acquisition context.
5. Inline duplicate checks in both platform branches. This removes the named helper but adds drift risk.
6. Extract a new module with compliant exported/private names. This adds packaging and qualification work without a new consumer need.
7. Remove the capability check. This loses the selected streaming-bound prerequisite and fails the safety constraint.
8. Change the protected guide to allow the plural name. This has no demonstrated product need or scoped authority.

A partial rename fails because current callers and test extraction anchors must resolve. An alias plus rename introduces an unused second name and preserves no supported external contract. Combining suppression with a valid rename adds no benefit. A guide exception plus suppression remains option8 and cannot bypass authority. Renaming plus module extraction is option6. No runtime replacement or host installation is needed for a naming defect.

## Finding-specific rubric

Scores range from0 to5:0 fails the criterion;1 provides weak support;2 leaves a substantial gap;3 is adequate with drawbacks;4 is strong with a small drawback;5 fully meets the criterion. Weighted total is the sum of weight times score divided by5. Scores compare expected tradeoffs; they are not empirical reliability measurements.

| Criterion | Weight | Meaning |
| --- | ---: | --- |
| Rule compliance | 35 | Meets the current singular-noun requirement without a suppression or invented exception. |
| Behavior preservation | 30 | Keeps every admission check, limit, platform distinction, error path and caller behavior. |
| Maintainer clarity | 20 | Gives contributors and reviewers one concise, consistent private identifier with no needless packaging or duplication. |
| Verification strength | 10 | Supports complete reference census, exact inverse proof and direct parser/analyzer/runtime checks. |
| Implementation effort | 5 | Avoids unnecessary edits and maintenance. This cannot outweigh compliance or correctness. |

Hard constraints: do not weaken capability admission; do not break callers; do not change protected instructions; retain all prior evidence and counters. An otherwise high score cannot waive a constraint.

## Scores

| Option | Compliance | Behavior | Clarity | Verification | Effort | Total /100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Defer | 0 | 5 | 2 | 1 | 5 | 45 |
| 2. Suppress | 0 | 5 | 2 | 1 | 4 | 44 |
| 3. Singular name | 5 | 5 | 5 | 5 | 4 | 99 |
| 4. Longer singular name | 5 | 5 | 4 | 5 | 4 | 95 |
| 5. Duplicate checks | 5 | 3 | 2 | 2 | 2 | 67 |
| 6. New module | 5 | 4 | 3 | 3 | 1 | 78 |
| 7. Remove check | 5 | 0 | 1 | 1 | 5 | 46 |
| 8. Change guide | 0 | 5 | 2 | 1 | 0 | 40 |

Option3 wins and satisfies the hard constraints. Option4 is also viable, but its extra qualifier conveys no additional distinction in this private file. Options1,2,7 and8 fail hard constraints. The remaining options add avoidable behavior or packaging uncertainty.

## Selected action

Root displayed validation, all options, this distinct rubric and the complete table before editing.

1. Rename the private function to Assert-CurlCapability.
2. Update its examples and callers.
3. Update each test reference to the function.
4. Keep all checks and limits.
5. Verify that the old name has no live reference.
6. Reverse the name change in memory.
7. Compare the result with the previous source bytes.
8. Run the parser and analyzer on current forms.
9. Run the required affected tests and final hooks.

These instructions use short direct actions and consistent technical names. No formal ASD-STE100 dictionary certification is claimed. The change does not alter guide text or a public contract. No owner input is needed.

## Verification and limits

Before implementation, parser result cc594d2207ab372efe4897a670fad04fa77e981b2bd74b6d6d824845d06a3f9a proves the warning on the named v3 inputs. It does not prove a corrected candidate. The prior11 Git and11 curl mechanism controls keep their original inputs and narrow limits. Current generated syntax, independent finite source review, affected Linux, full Windows, all11 hooks and the normal PR lifecycle remain required. Append actual implementation and validation results here.

## References

- [Repository singular-noun rule](https://github.com/franklesniak/PSStyleGuide/blob/2b5514c7a0c35b55d002935dcd771a72be1b1dcf/STYLE_GUIDE.md#script-and-function-naming-nouns).
- [Microsoft PSUseSingularNouns rule](https://learn.microsoft.com/en-us/powershell/utility-modules/psscriptanalyzer/rules/usesingularnouns?view=ps-modules): use a singular noun when the warning is valid; suppression mechanisms do not override this repository's requirement.
- [FQ40 download-bound decision](FQ40-COMPRESSED-DOWNLOAD-LIMIT.md).
- [FQ24 retained constructor applicability](FQ24-FIXTURE-PREFERENCE-SCOPE.md).

## Implementation and current verification

Root applied option 3 before current validation. The private helper and its callers/fixture anchors now use Assert-CurlCapability. Exact inverse verification89bcb0 confirmed the identifier-only change. The resulting initializer is a64a17876d6cb71d3a4cbb7d46bbd0edc193c24fa047efa45491f85752dbc0d5; the test driver is7b3602065b859fc89d7e3a1eb32ce3f41d44e916569ccef27bb320c88c55cd2a. Independent finite source review accepted the change; the [source acceptance](current-main-validation/pr239-round3-source-quality-acceptance.json) records its evidence.

At v4, syntax coverage was complete:157 current labels and110 unchanged retained labels, representing249 distinct bodies. Current Node and PowerShell parsing passed. Analyzer observations remain recorded with specific applicability dispositions; the unrelated New-ArchiveProcess constructor body is unchanged and has no executed mutating operation. No blanket suppression was added. The later [v5 syntax acceptance](current-main-validation/pr239-round3-v5-syntax-acceptance.json) records the complete current attribution and preserves the earlier parser/analyzer evidence.

All30 new maintained Linux registrations for FQ39/FQ40 passed on the corrected source. The final fixture driver is now c57e2447/index cacf070b; the initializer and singular helper name remain unchanged. Two changed generated PowerShell mock forms passed fresh parser/analyzer checks with zero findings;265 exact retained labels keep their original evidence. This accounts for267 labels/249 unique bodies, with the complete current Node driver also passing syntax.

All156 affected Linux registrations are accepted and independently reconciled, combining6 fresh selector results and150 unchanged effective-input results. The fresh [Windows aggregate](current-main-validation/pr239-round3-v5-windows-aggregate-runtime.json) also passed816 registrations (377pass/439 explicit skips/zero failures) and strict process/cleanup acceptance. Independent review confirmed the Windows result. The [final hook acceptance](current-main-validation/pr239-round3-v5-windows-precommit-runtime.json) confirms11 passes with zero skips and strict source, process and cleanup acceptance. The [normal commit](current-main-validation/pr239-round3-v5-normal-commit.json) is11224a2f58e2cb1e2ffb3ab443ccc83dd0822950; staged, repository and nested Markdown hooks passed at native0/c6b968. The public lifecycle remains pending.
