<!-- markdownlint-disable MD013 -->
# Runtime repair: restore effective date-policy mutation controls

## Validated finding

The final mandatory aggregate failed with exit1 after684.233seconds. Ten hooks and13classifier tests passed. The instruction hook rejected stale STYLE_GUIDE.md metadata in an author fixture that expected its deliberately faulty checker to accept it. All four private post/terminal identity guards and the host guard match:80source files,1914dependencies, Git indexes, refs and configuration. The product is uncommitted. No merge, CI retry or full-suite retry occurred.

The new reuse arguments moved two finalization-flag values away from closing parentheses. Both existing checker-code mutations replace the old literal `$objDocumentContext.RequireFinalizationDate))`. Root and writer independently counted two matches in published H5ec and zero in candidate9ca8. Both resulting mutants are byte-identical to the candidate. The require-date mutant therefore leaves the date check enabled. The initial-coverage mutant also becomes ineffective. Other author checker-code mutation anchors still match. The fixture and clock helper bodies are unchanged.

This proves a coupled test defect. The late require-date caller is the supported explanation for the observed stale-guide error. The shared log formatter omits the outer callsite and fixture B/H, so direct per-case tracing is not claimed. The first current-date original/changed comparison already passed. There is no evidence requiring weaker production date checks or altered clocks. Static evidence is sufficient to select the repair; do not run a redundant negative-only reproduction.

## Stakeholders and options

QA and security maintainers need mutants that exercise the real date-policy boundary. CI operators need a missing mutation target to fail promptly. New contributors and reviewers need understandable failures and a narrow implementation. Both repository maintainers need common tests and unchanged production contracts. Business/runtime concerns favor one focused proof followed by one required final pass. There is no user-interface, privacy, localization or deployment-setting change.

1. Update literal replacement targets and require exact match counts. This is small but still depends on textual structure.
2. Parse the source, identify the two actual named date-check arguments, and replace their exact source spans with checked cardinality and parser validation.
3. Rearrange production argument ordering to preserve the old test strings. This couples production layout to a fragile test.
4. Add a production switch that disables the date check for tests. This adds an unnecessary bypass.
5. Replace actual mutation callers with simulations. This loses real boundary evidence.
6. Remove the affected controls. This loses meaningful negative coverage.
7. Leave the failure unresolved. This preserves the failed gate without delivering the repair.
8. Build a suite-wide mutation framework. This addresses unrelated tests and increases the surface to understand.

Option2 includes exact-count, changed-output and parsing safeguards. Combining1and2 therefore reduces to2. Combining3with1 adds production churn without stronger coverage. Broader removals or simulated replacements fail the protection constraint.

## Finding-specific rubric

Use0–10 per criterion;10means strongest support,5means material limitations and0means the criterion is not met. Weighted totals divide each score by10 and multiply by its percentage. Scores are judgments, not experimental measurements.

- Correct fault injection,30%: alter only the intended argument in each real endpoint call; preserve every other byte.
- Preserved protection,25%: keep production behavior, real callers, clock controls and original accept/refuse expectations.
- Early clear failure,15%: reject missing, duplicate or unexpected targets before a long fixture run.
- Resistance to harmless changes,15%: tolerate formatting and added arguments while refusing semantic target changes.
- Maintainability,10%: make intended faults and failures clear to contributors and reviewers; avoid a broad new abstraction.
- Implementation cost,5%: consider added code, dependencies and review effort after correctness and usable failure behavior.

Hard constraints prohibit a production bypass, dropped meaningful negative controls and replacement of actual policy callers with simulations. No score waives CI, final validation or source identity guards.

| Option | Fault30 | Protection25 | Early15 | Resilience15 | Maintain10 | Cost5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 Checked text | 9 | 10 | 9 | 6 | 9 | 10 | 88.5 |
| 2 Parsed arguments | 10 | 10 | 10 | 9 | 8 | 6 | 94.5 |
| 3 Production reorder | 9 | 8 | 4 | 3 | 7 | 8 | 68.5 |
| 4 Production switch | 7 | 2 | 8 | 8 | 6 | 4 | 58; disqualified |
| 5 Simulation | 4 | 3 | 8 | 8 | 8 | 8 | 55.5; disqualified |
| 6 Remove tests | 0 | 0 | 1 | 10 | 5 | 10 | 26.5; disqualified |
| 7 Unchanged failure | 0 | 10 | 2 | 0 | 2 | 10 | 35; unresolved |
| 8 Broad framework | 9 | 10 | 10 | 10 | 5 | 2 | 88 |

## Selected procedure: option2,94.5

Change the SelfTest only. Keep the main validator unchanged.

1. Parse the checker source before the expensive fixture work.
2. Find one `RequireExpectedUtcDateForRenderedChange` argument in the actual `Get-PublishedEndpointMetadataFailure` call.
3. Find one `RequireCurrentMaximumDateForRenderedChange` argument in the actual `Get-PublishedEndpointLastUpdatedFailure` call.
4. Verify that each argument reads `objDocumentContext.RequireFinalizationDate`. Reject missing, duplicate or unexpected targets.
5. Replace only the two argument spans. Apply replacements from the end of the source to the start.
6. Verify that each mutant differs from the original. Parse each mutant and reject errors.
7. Keep the original caller expectations and clock controls. Run the six bounded real promotion/versioned-date cases with corrected mutants. Record the actual case identity and result.
8. Verify missing/duplicate/unexpected targets and harmless formatting or added arguments. Do not add a general mutation framework.
9. Run one full mandatory validation after the focused proof passes. The failed run remains failed history.

The short instructions follow the requested controlled-writing approach; formal ASD-STE100 dictionary certification is not claimed. The complete options, rubric, scores and selection were displayed before release. No owner decision is needed because the process has a clear winner.

## Evidence and limits

The full run used qualified offline Linux PowerShell7.6.3, Node24.18.1 and Python3.12.3. Preflight exited0; classifier13/13passed; aggregate exited1. The exact aggregate log SHA256 is `eeefa5e5919d8f31a60d3ac9e94930b22bed582a53d75f5ebe89d2f182e5dd5e`. [Failure](final-validation-failed/FAILURE.json) and [log](final-validation-failed/aggregate.log) are retained. The source investigation is at `C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A06-TF-peer-20261005/writer/TF68-runtime-diagnostic/implementation/final-validation/investigation`; its report SHA256 is `00fdb913c6d0096e1c009cce68fb804aa049e95e381f0c7889bfcbb284a37ec0` and evidence SHA256 is `a7d4614c75c436261b9c06aacd215c26207a27565e6be0c5f65f18f871118b87`.

PowerShell provides command elements and source extents for syntax-directed changes. See [CommandAst](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.language.commandast?view=powershellsdk-7.6.0) and Microsoft's [AST source-offset example](https://devblogs.microsoft.com/scripting/learn-how-it-pros-can-use-the-powershell-ast/). These APIs support the mechanism; actual local parsing and caller tests must establish this implementation's behavior.

Round5/80, deadline2026-10-13T23:47:31Z and transfers1/3/5/5of12 remain unchanged. No failed-CI merge or PS carryback is permitted. New SelfTest bytes invalidate the old full-validation candidate identity. The unchanged main checker can retain its measured same-case evidence. Rebind new file/tree hashes, final validation, normal commit, actual accepted-base/new-commit checks, independent final quality and current remote acceptance before landing.
