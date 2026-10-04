<!-- markdownlint-disable MD013 -->
# TF66 R5: correct the unsupported-configuration remedy

Status: selected C100 before implementation. One error-string edit is released. Existing behavioral tests remain unchanged for this finding.

## 1. Validation

[Copilot comment4178540651](https://github.com/franklesniak/TerraformStyleGuide/pull/66#discussion_r4178540651), review5407265563 on He2f0652654ef0954e17fc3a255b87375908d0521, correctly identifies incomplete advice in lint-nested-markdown.js193. The allowlist admits the workflow JSONC and JSON paths, but the unsupported-selector error names only JSONC. The parser and rejection remain correct. This is a bounded usability improvement.

An actual unchanged-module probe on Windows/Node24.18.1 passed three assertions: JSON-only accepted, JSONC preferred when both files exist, and an unsupported root selector emits the incomplete remedy. Exit0, log SHA256 `3e7ea5d0faf277e80753c101f6e8c73ae73840ca878fb49c9bb7e543fde14826`. The [command receipt](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/implementation/round1-review-findings/configuration-diagnostic.json) and [results](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/implementation/round1-review-findings/configuration-diagnostic-results.json) preserve the actual observations.

## 2. Stakeholders and constraints

Contributors and new users need both complete recovery paths. UX and documentation reviewers need a clear preferred option and the offending path. CI and security owners need the existing rejection, precedence and status2 behavior retained. Maintainers and QA need useful behavioral tests preserved without adding tests that mirror a reversible wording edit. No recovery, privilege, dependency, deployment or external data interface changes.

Hard constraints: preserve configuration admission, JSONC preference, JSON fallback, regular-file checks, containment, native statuses and all current tests. Add no implementation-matching tests for this low-impact wording change, in accordance with the active developer instruction. Root reviewed the private proposal before selection and removed its proposed exact-message test additions; the original proposal remains historical evidence, not the selected design.

## 3. Options

| Option | Approach | Tradeoff |
| --- | --- | --- |
| N | Retain current error | Leaves incomplete directions. |
| C | Correct the remedy sentence only | Direct correction; existing behavioral tests remain. |
| E | Correct the sentence and add exact-text assertions | Duplicates implementation wording in tests for a reversible low-impact change; violates the testing constraint. |
| D | Generate the remedy from the allowlist | Adds formatting logic and needs further wording to express preference. |
| G | Use generic advice without exact paths | Forces readers to discover the accepted filenames. |
| R | Remove JSON fallback | Breaks supported behavior to fit the error. |
| A | Accept alternate selectors | Changes configuration policy instead of correcting advice. |

C plus a direct observed-message check is C's validation. Existing fallback and nine selector/caller tests already cover behavior. E/D represent the useful combinations with additional assertions or generation; broader parser redesign addresses no demonstrated defect.

## 4. Finding-specific rubric

Scores0–5 mean unacceptable, weak, incomplete, adequate with drawbacks, strong, or fully supported. Total is sum(weight times score/5). These are judgments, not measured probabilities. Hard constraints cannot be waived by a total.

| Criterion | Weight | Meaning of5 |
| --- | ---: | --- |
| Diagnostic accuracy | 35 | Names both accepted files without implying other selectors are allowed. |
| Recovery clarity | 30 | Names complete paths, preserves the rejected path and identifies the preferred choice. |
| Behavior preservation | 25 | Preserves allowlist, parser, precedence, path checks and exit semantics. |
| Maintenance | 7 | Avoids unnecessary runtime formatting and wording-mirroring tests. |
| Implementation effort | 3 | Easy to inspect; convenience stays subordinate to correctness and usability. |

## 5. Scores

| Option | Accuracy35 | Clarity30 | Behavior25 | Maintenance7 | Effort3 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 1 | 2 | 5 | 5 | 5 | 54 |
| C | 5 | 5 | 5 | 5 | 5 | 100 |
| E | 5 | 5 | 5 | 3 | 3 | 96; ineligible |
| D | 5 | 4 | 5 | 4 | 3 | 91.4 |
| G | 2 | 1 | 5 | 4 | 4 | 53 |
| R | 2 | 3 | 0 | 2 | 1 | 35.4; ineligible |
| A | 1 | 3 | 0 | 1 | 1 | 27; ineligible |

Root calculated every total after displaying this rubric. C is the clear winner. This supersedes the private E98.6 recommendation before any edit. The tests for R2's real execution boundary are a separate material requirement and remain necessary.

## 6. Selected instructions

1. Keep the error prefix and offending path.
2. Replace the remedy with: `Use .github/workflows/.markdownlint.jsonc (preferred) or .github/workflows/.markdownlint.json.`
3. Keep all configuration behavior unchanged.
4. Keep the existing fallback and rejection tests.
5. Check the actual new message directly.
6. Run the retained suite with the R2 security repair.

Use short, consistent instructions as above; no formal ASD-STE100 dictionary certification is claimed. The only product edit for this finding is the error string in `.github/workflows/lint-nested-markdown.js`. The shared test file changes only for R2's distinct security regressions.

## 7. Implementation and verification

Root displayed validation/options, the unique rubric, all scores and these selected instructions before releasing the combined private repair. No repair test pass or product acceptance is claimed yet. The exact local implementation is the primary source for this diagnostic; no external API behavior is needed to establish it. Preserve actual local tests, subsequent hosted execution, current-input reviews and final paired acceptance as separate gates.
