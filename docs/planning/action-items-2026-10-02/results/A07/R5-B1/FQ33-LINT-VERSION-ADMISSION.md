<!-- markdownlint-disable MD013 -->
# FQ33: complete version admission in the Markdown launcher

## Validation and stakeholders

Copilot comment4228849048, review5468500637, targets Invoke-MarkdownLint.ps1 at published c1ef946fe4585836f27a0a4480bd986899d7c316. Root pure-source probe731586 on Windows PowerShell7.6.5/.NET10.0.11 confirmed that the exact current predicate accepts `24.18.1` with a final LF. The valid value passes; CRLF, CR, leading LF, suffix text and the wrong major are refused. This is admission-stage evidence, not proof of remote code execution. Later handoff equality or path errors do not repair the invalid early admission.

Evidence: [pure probe evidence](current-main-validation/pr239-round2-pure-probes.json). The first probe34e8d5 failed because its explicit Node path was wrong; no native child or product ran. Root read the qualified manifest and used its existing Node24.18.1 path in731586. No runtime installation occurred.

This is the same .NET boundary behavior addressed by [FQ30](FQ30-ORDINARY-EXACT-TOKENS.md), now found in a separate consumer. Maintainers and security reviewers need a complete input rule. New developers and documentation readers need an understandable check. CI operators, users and UX owners need early errors. QA needs actual-source regression evidence. Project managers value a finite repair. No new privacy, localization, cloud or accessibility interface is introduced.

## Options

1. Use absolute anchors in the existing predicate.
2. Keep the regex and require the match length to equal the input length.
3. Reject newline characters before the existing regex.
4. Replace the regex with an explicit version parser.
5. Introduce a trusted shared validator.
6. Trim the value before admission.
7. Rely only on the runtime handoff file.
8. Make no change or defer.

All implementing options include positive and negative controls. Combining2and3 duplicates checks. Factoring can contain options1-4 but changes the loader boundary. Options6-8 fail the existing complete-value requirement; they are not authorized scope reductions.

## Rubric

Scores0-5 mean fails, weak, partial, adequate with uncertainty, strong, and fully suitable. Weighted total is sum(weight*score)/5. These are comparative judgments, not measured probabilities. Exact-value correctness35% protects the grammar. Early refusal20% protects ordering. Valid-input compatibility20% protects supported usage. Regression evidence15% values actual source and causal controls. Clarity5% values one understandable rule. Implementation effort5% is deliberately below correctness and usability.

Hard constraints: preserve valid version grammar, reject complete malformed values before runtime use, and retain the trusted loading boundary.

| Option | Correct35 | Early20 | Compatible20 | Evidence15 | Clear5 | Effort5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 Absolute anchors | 5 | 5 | 5 | 5 | 4 | 5 | 99 |
| 2 Match length | 5 | 5 | 5 | 4 | 3 | 4 | 94 |
| 3 Newline filter | 5 | 5 | 5 | 4 | 3 | 5 | 95 |
| 4 Explicit parser | 5 | 5 | 4 | 4 | 3 | 2 | 88 |
| 5 Shared validator | 4 | 4 | 4 | 4 | 4 | 1 | 77 |
| 6 Trim | 1 | 2 | 2 | 3 | 3 | 5 | 40 |
| 7 Handoff only | 0 | 1 | 4 | 2 | 2 | 5 | 33 |
| 8 No change/defer | 0 | 0 | 4 | 1 | 3 | 5 | 27 |

Option1 wins. Its limitation is that a reader must know the .NET absolute-anchor syntax. Options2and3 split the rule. Option4 adds parser behavior. Option5 adds loading and trust decisions.

## Selected action

1. Replace `^` and `$` with `\A` and `\z` in the launcher predicate.
2. Keep the permitted version format.
3. Test valid versions.
4. Test extra characters at both ends.
5. Confirm that malformed input cannot start the lint commands.
6. Run the affected integrated checks before publication.

The selected instructions use short active sentences, one action per instruction and consistent technical names. No formal ASD-STE100 dictionary certification is claimed.

## References and verification

[Microsoft .NET anchors](https://learn.microsoft.com/en-us/dotnet/standard/base-types/anchors-in-regular-expressions), checked2026-10-09, distinguishes final-LF acceptance by `$` from absolute `\z`. Do not substitute `\Z`.

The owner-facing options, rubric and table preceded implementation. Actual integrated validation is pending. PR239 retains round2/80, its original2026-10-16T22:53:27.970214Z deadline and A07transfer9/12. No new public request or merge has occurred.

## Local implementation at source freeze

The selected absolute anchors are implemented. The real predicate registration checks14 values and passed1/0/0 in root receiptca0e3d. Its source is unchanged in the frozen repair set. Six malformed-version modes are also added to the real Linux lint-launcher fixture; those whole-launcher cases remain unexecuted. Do not use the predicate test as their acceptance.

The [frozen source record](current-main-validation/pr239-round2-source-freeze.json) identifies that historical repair input. Root syntax and whitespace checks passeda48f78.

## Current verification

The complete-value predicate and real-launcher malformed-version cases passed in the20-test Linux lint group. The predicate also passed in the fresh Windows aggregate. [Current candidate and validation](current-main-validation/pr239-round2-validation.md) supersedes the pending-test statements above and identifies the unchanged-scope evidence, actual final bytes and remaining gates.
