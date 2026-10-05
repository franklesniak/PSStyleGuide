<!-- markdownlint-disable MD013 -->

# PR232 R2 — accurate common fixture prefix

## Validated finding

Copilot4181349596 correctly identifies terraform-local-validation- at fixture14 in the PS copy. It also exists in accepted TF56; both files are raw equal. This one literal is solely an mkdtemp prefix. Children, Git commands and cleanup use the generated root, not a reconstructed name. No assertion or discovery depends on the prefix. Siblings use purpose names npm-input-test-, markdown-tool-test- and npm-audit-scope-. A Terraform label can mislead PS failure-path inspection, but no collision, unsafe deletion or failed behavioral oracle is demonstrated. The useful repair can remain common to both products.

## Stakeholders

Maintainers, contributors and test operators need temporary paths to identify the actual task. Security reviewers need unique allocation and exact returned-root cleanup. Both repository owners need identical shared fixtures. QA needs all five staged-status/six Linux order cases and staged-byte assertions intact. Release operators need no new package/Git/name discovery or fixture inputs. No runtime, cloud, secret, language-guide or user-data contract changes.

## Options before rubric

- **N: Keep the historical Terraform prefix.** Behavior remains safe; PS failure paths still imply the wrong product.
- **P: Use a PS-specific prefix in PS only.** Locally accurate but introduces needless common-test divergence.
- **C: Use shared styleguide-local-validation-.** Accurate common task name without discovery or parameter input.
- **D: Derive repository name dynamically.** Adds identity discovery, sanitization and failure dependencies for optional extra product labelling.
- **M: Parameterize prefix through fixture callers.** Distributes a constant across callers and expands fixture input review.
- **T: Use empty or opaque prefix.** Retains unique allocation but discards useful task identity.
- **H: Keep prefix plus historical-explanation comment.** Helps source readers, not the misleading emitted/retained path.

Neutral naming plus source-history comment adds no diagnostic value beyond C. Dynamic discovery passed through a parameter combines D/M costs without a new benefit. Every viable option retains unique temporary allocation; fixed reused directories violate that constraint. Renaming all siblings is unrelated scope, not necessary consistency.

## Unique rubric

Accurate diagnostic/task identification35: a path names the current work without a false product claim. Allocation/cleanup safety25: unique roots and returned-root ownership stay clear. Common portability20: one literal works in PS and TF. Environment independence10: no new repository/package/Git discovery dependency. Maintenance7: simple fixture contract. Effort3: concrete change/review cost.

Hard constraints: retain mkdtemp uniqueness, exact returned-root cleanup, all staged-byte assertions, five status outcomes and six native command-order cases. Do not derive deletion targets from untrusted input. Existing history does not require a permanent common-byte exception.

Scores0–5:0 absent/harmful,3 adequate with limits,5 complete scoped fit. Total=sum(weight × score)/5. Scores are judgments, not performance measurements. Correctness/usability/common behavior/verification weigh90%; complexity and effort10%. Root displayed the options, rubric and scores, then selected this fix before implementation.

| Option | Diagnostic35 | Safety25 | Common20 | Environment10 | Maintenance7 | Effort3 | Total/100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 2 | 5 | 5 | 5 | 5 | 5 | 79 |
| P | 5 | 5 | 1 | 5 | 4 | 5 | 82.6 |
| C | 5 | 5 | 5 | 5 | 5 | 5 | 100 |
| D | 5 | 4 | 5 | 3 | 2 | 2 | 85 |
| M | 5 | 4 | 5 | 5 | 3 | 3 | 91 |
| T | 1 | 5 | 5 | 5 | 5 | 5 | 72 |
| H | 3 | 5 | 5 | 5 | 4 | 4 | 84 |

## Selected solution — C100

Use `styleguide-local-validation-`. It names the shared task without claiming a product identity. Dynamic/parameterized variants add setup inputs and failure surfaces for product labelling this fixture does not require. Retaining the current name is safe but preserves misleading diagnostics.

1. Replace the single terraform-local-validation- literal with styleguide-local-validation-.
2. Keep fixture allocation, cleanup, child commands and all assertions unchanged.
3. Confirm the exact diff changes only this literal and no caller depends on it.
4. Add no literal-mirroring test. Reuse existing behavioral coverage and normal combined final validation at its recorded platform scope.
5. After PS acceptance, apply the same literal to TF and compare the accepted bytes.

Exact proposed scope: `.github/workflows/Test-LocalValidation.test.mjs`, A07. No production module, test count, metadata or guide change. Current five status/six Linux native-order cases remain meaningful; source inspection is not a new pass. Proposal validation used source inspection; executed repair checks are recorded below. Root owns the final aggregate and all native acceptance gates.

References: [actual comment](https://github.com/franklesniak/PSStyleGuide/pull/232#discussion_r4181349596), LOOP-POLICY common-byte rules and existing D07 local-validation convergence; `results/A07/recurring-lint-suite-decision.md` records recurring lint coverage. Evidence.json contains complete raw source and sibling purpose-prefix evidence.

## Implementation and verification

The selected one-line repair is applied in proposed tree `e5f2aee1fbe9eb4650af69c30aa94edc914e4dcf`, against prior PS head `886f3837cb729b73bffec78e966d9ceb7fa78592`. Independent review confirmed the exact two-path combined diff and unchanged surrounding behavior. No test was added.

Windows Node 24.18.1 ran `node --test .github/workflows/Classify-InstructionMaintenance.test.mjs .github/workflows/Test-LocalValidation.test.mjs`: 17 passed, zero failed, six Linux-only skips. Linux Node 24.18.1 ran those files plus `.github/workflows/NpmTools.test.mjs`: 43 passed, zero failed or skipped. This includes the existing native/import loader cases and all hook-order cases. The one final-byte aggregate passed all 11 hooks with no skips, and every source/index/configuration/dependency/ref guard stayed unchanged. Normal commit hooks passed in `aafa9a4a41318d0cf1b61d873b321567b31ac985`. Actual accepted-base/current-commit classification, metadata and proposed-policy checks passed. The fresh ordinary two-root audit returned CLEAN with no findings or exceptions. Current-input remote reviews, final quality, merge and peer acceptance remain pending.

The selected instructions use short direct sentences and one action per step. No formal ASD-STE100 dictionary certification is claimed.
