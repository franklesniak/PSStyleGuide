<!-- markdownlint-disable MD013 -->

# PR232 R1 — unused classifier import

## Validated finding

Copilot4181349559 on H886f383 is correct: Classify-InstructionMaintenance.mjs imports path at3 but has no binding use. R11's accepted entry guard now uses fs.realpathSync/fileURLToPath, preferring native import.meta.main even when false. Other four R11 modules still have actual path operations. Proposed PS and accepted TF56 have identical classifier bytes. This is a small maintenance defect, not a security failure or broken classifier. Strings mentioning a repository path do not use the import.

## Stakeholders

Maintainers and future authors need imports to describe actual dependencies. Security/review owners need accepted-base classification, selector bounds and R11 import/CLI behavior preserved. Both repository owners need identical shared source. QA/release operators need proportionate proof without a new tool/framework for a reversible one-line correction. No user-facing runtime, cloud, credential, accessibility or language-guide behavior changes.

## Options before rubric

- **N: Retain the harmless import.** No runtime failure, but imports still imply a nonexistent use.
- **D: Delete only the unused import.** Direct bounded cleanup; accepted-source peer follow-up still required.
- **C: Keep import with explanation or suppression comment.** Explains avoidable dead code instead of removing it.
- **S: Use a side-effect-only node:path import.** No supported side-effect requirement; still misleading.
- **G: Add general unused-import lint/tooling and remove it.** Future detection benefit, but new configuration/tool maintenance for a one-line finding.
- **R: Refactor entry detection to use path again.** An additional correct canonical-path design is possible but unnecessarily changes a sensitive boundary. Lexical-only resolve would violate the link contract and is excluded.

Deletion plus an explanation/framework reduces to C/G's extra maintenance. Restoring an algorithm merely to use the import is R, not required cleanup. A historical-source exception is N. No meaningful missing combination changes these tradeoffs.

## Unique rubric

Import/dependency clarity35: truthful executable dependencies without dead declarations. Preserved behavior30: classifier authority, paths/status and native/import boundary unchanged. Common convergence15: one accepted change works identically in both repositories. Proportionate verifiability10: complete small diff establishes the result without duplicated fixtures. Maintained complexity7: ongoing tool/configuration/comment burden. Effort3: implementation/review cost.

Hard constraints: retain native-boolean false precedence, canonical fallback, imported nonexecution and CLI diagnostics/status; preserve accepted-base classification/bounds. Do not reintroduce lexical-only link detection or delete a used import. General lint tooling is a scored alternative, not disqualified solely by churn.

Scores0–5:0 absent/harmful,3 adequate with limits,5 complete scoped fit. Total=sum(weight × score)/5. Scores are judgments, not performance measurements. Correctness/usability/common behavior/verification weigh90%; complexity and effort10%. Root displayed the options, rubric and scores, then selected this fix before implementation.

| Option | Clarity35 | Behavior30 | Common15 | Verify10 | Complexity7 | Effort3 | Total/100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 2 | 5 | 5 | 4 | 3 | 5 | 74.2 |
| D | 5 | 5 | 5 | 5 | 5 | 5 | 100 |
| C | 3 | 5 | 5 | 4 | 2 | 4 | 79.2 |
| S | 2 | 5 | 5 | 4 | 3 | 4 | 73.6 |
| G | 5 | 5 | 4 | 4 | 2 | 1 | 88.4 |
| R | 2 | 2 | 4 | 2 | 2 | 1 | 45.4 |

## Selected solution — D100

Delete only the unused import. This resolves the precise stale declaration without changing a working boundary. General unused-import lint may serve a later independent need, but it supplies no necessary additional proof here.

1. Remove `import path from 'node:path';` from the classifier.
2. Preserve every other byte.
3. Inspect the exact diff and confirm the removed binding has no use.
4. Use a syntax check if needed during the combined repair. Reuse existing classifier and native/import controls at their real scope.
5. Add no test that mirrors the deleted import. Root runs required final-input validation and lifecycle.
6. After PS acceptance, carry this same deletion to TF and compare actual mains.

Exact proposed scope: `.github/workflows/Classify-InstructionMaintenance.mjs`, A21. No test/guide/metadata/dependency edit. Existing classifier tests cover accepted checkout/endpoints/data-only classification; NpmTools tests cover five-module direct/import/fallback behavior. Do not repeat those suites solely for this textual cleanup. Proposal validation used source inspection; executed repair checks are recorded below.

References: [actual comment](https://github.com/franklesniak/PSStyleGuide/pull/232#discussion_r4181349559); canonical `results/A07/TF66-R11-linked-cli-entry.md`; LOOP-POLICY exact-byte rules. Evidence.json pins the complete primary sources, counterpart identities and sibling census. No external claim requires web research.

## Implementation and verification

The selected one-line repair is applied in proposed tree `e5f2aee1fbe9eb4650af69c30aa94edc914e4dcf`, against prior PS head `886f3837cb729b73bffec78e966d9ceb7fa78592`. Independent review confirmed the exact two-path combined diff and unchanged surrounding behavior. No test was added.

Windows Node 24.18.1 ran `node --test .github/workflows/Classify-InstructionMaintenance.test.mjs .github/workflows/Test-LocalValidation.test.mjs`: 17 passed, zero failed, six Linux-only skips. Linux Node 24.18.1 ran those files plus `.github/workflows/NpmTools.test.mjs`: 43 passed, zero failed or skipped. This includes the existing native/import loader cases and all hook-order cases. The one final-byte aggregate passed all 11 hooks with no skips, and every source/index/configuration/dependency/ref guard stayed unchanged. Normal commit hooks passed in `aafa9a4a41318d0cf1b61d873b321567b31ac985`. Actual accepted-base/current-commit classification, metadata and proposed-policy checks passed. The fresh ordinary two-root audit returned CLEAN with no findings or exceptions. Current-input remote reviews, final quality, merge and peer acceptance remain pending.

The selected instructions use short direct sentences and one action per step. No formal ASD-STE100 dictionary certification is claimed.
