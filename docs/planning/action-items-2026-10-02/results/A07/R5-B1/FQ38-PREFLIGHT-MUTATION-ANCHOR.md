<!-- markdownlint-disable MD013 -->
# FQ38: restore the preflight-order mutation constructor

## Validation

The syntax-preparation worker found that `foundationMutation(source, 'preflight-order')` still builds the preflight and installation blocks without the two FQ36 stdout routes. Root confirmed the defect with a text-only check, receipt `c25a20`. The old combined anchor occurs zero times in the current initializer; the corrected combined anchor occurs exactly once. The existing `foundationOnce` assertion would stop the selected F13 test before it could run the baseline and deliberate mutation. This is a real test defect, not evidence of a product runtime failure.

The initializer hash is `f79c560723233a22ce45a23602dcd1232fcd0fea949d8bae5d566592df43f57e`. The affected test driver before repair is `19ae06c0acd5f65c52be37f498aae71adc6a877b43ae8e427538c4c0343da815`. [Root anchor evidence](current-main-validation/fq38-anchor-validation.json) has SHA256 `ded441db97b939234af33242bd037d3461fb9a00267bfacc546c5c092f8ed60c`. The evidence contains the exact old and current strings. No target evaluation, native fixture or product test ran during this check.

Maintainers and security engineers need a mutation that changes only execution order. QA needs evidence that the baseline rejects installation after a failed preflight and that the deliberate mutation starts installation. New developers and reviewers need a clear, inspectable recipe. DevOps and incident operators need the logging repair to remain in place. Documentation, UX and business stakeholders need truthful validation status and a stable output contract. No customer-facing interface or privilege changes are required.

## Options

1. Update the two exact command strings and retain the strict single-match check.
2. Replace the duplicated strings with PowerShell syntax-tree extraction.
3. Add markers to the initializer and extract marked blocks.
4. Use a broader regular expression that tolerates command changes.
5. Replace the source mutation with simulated fixture behavior.
6. Remove or skip this test.
7. Revert the FQ36 logging repair.
8. Defer both changes.

An early constructor check complements options1-3 and already exists in the current preparation. Combining broad matching with exact strings reduces the strict refusal of source drift. Adding both markers and syntax-tree extraction adds two mechanisms without improving this two-block mutation. A general mutation framework is a larger version of option2; it is not required to preserve the current proof. Removing the test, reverting the product repair or replacing actual source behavior with a simulation fails a required condition.

## Finding-specific rubric

Scores0-5 mean unsuitable, weak, partial, adequate with uncertainty, strong, and fully suitable. Total equals the sum of each weight multiplied by its score, divided by5. These scores are engineering judgments, not measured runtime results.

- Mutation accuracy30%: change only the order of the selected operations and preserve each operation's command, output routing and exit checks.
- Fault detection25%: retain the baseline refusal and the observed installation in the deliberate mutation; a constructor failure cannot count as a successful witness.
- Preservation of logging20%: retain visible diagnostics, the single completion result and native failure handling.
- Repeatability and maintenance10%: create a deterministic mutation and reject ambiguous source changes before fixture execution.
- Review clarity10%: make the change understandable to maintainers, new developers, reviewers and incident operators.
- Implementation effort5%: account for new dependencies and work while keeping effort below correctness and usability.

Hard constraints require the actual source mutation, unchanged baseline and mutant assertions, and preservation of FQ36. Options5-8 fail one or more constraints regardless of their totals.

| Option | Accuracy30 | Detection25 | Logging20 | Repeatability10 | Clarity10 | Effort5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 Update exact strings | 5 | 5 | 5 | 4 | 5 | 5 | 98 |
| 2 Syntax-tree extraction | 5 | 5 | 5 | 4 | 3 | 1 | 90 |
| 3 Marked blocks | 5 | 5 | 5 | 3 | 4 | 2 | 91 |
| 4 Broad expression | 2 | 2 | 5 | 2 | 2 | 4 | 54 |
| 5 Simulated behavior | 2 | 2 | 5 | 3 | 3 | 3 | 57 |
| 6 Remove or skip | 0 | 0 | 5 | 5 | 4 | 5 | 43 |
| 7 Revert logging fix | 5 | 5 | 0 | 4 | 4 | 5 | 76 |
| 8 Defer | 0 | 0 | 2 | 2 | 2 | 5 | 21 |

## Selected action

Option1 wins. The owner-facing options, rubric, scores and selection preceded the edit. The owner's standing instruction permits implementation of the clear winner.

1. Update the preflight command string in the test.
2. Update the installation command string in the test.
3. Include the existing stdout route in each string.
4. Keep the single-match check.
5. Keep all baseline and mutation assertions.
6. Confirm that the corrected blocks occur once in the initializer.
7. Confirm that the mutation changes only their order.
8. Refresh the affected source records and syntax evidence.
9. Run the selected test under the existing limits.
10. Record the actual result before acceptance.

The initializer does not require another edit. The test count, child count, limits and selected assertions do not change. Historical source reviews and sealed preparations remain evidence for their original inputs. They cannot authorize the revised driver until the changed source and dependent pins are reconciled. Review round2, the original deadline and transfer9/12 remain unchanged.

## References and verification

The primary evidence is the repository's actual `foundationMutation` constructor, its `foundationOnce` single-match check, its F13 baseline/mutation assertions, and the initializer's two current dependency commands. Internet research is not required to establish this exact local text mismatch. The root check ran with Python3.12.10 on Windows using UTF-8 text and no target evaluation. Runtime validation and fresh generated-form syntax remain pending. The selected instructions use short active sentences and consistent terms; no formal ASD-STE100 dictionary certification is claimed.

## Current verification

All eleven Linux mutation registrations passed, including the real preflight-order baseline and mutation. Current generated-form syntax is accepted with explicit unchanged-body attribution and fresh checks for changed bodies. [Current candidate and validation](current-main-validation/pr239-round2-validation.md) supersedes the pending-test statements above and identifies the actual input attribution and remaining gates.
