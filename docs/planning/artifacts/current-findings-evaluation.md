# PSStyleGuide open-finding evaluations

## F01 — Bound exact filesystem enumeration

### Options

- **A:** Keep the current result-only contract.
- **B:** Require complete array materialization for classification certainty.
- **C:** Stream exact counts through `N + 1`, stream absence to completion
  without accumulation, and add one closed implementation-property proof.
- **D:** Use only `File.Exists` and `Directory.Exists` for leaf absence.
- **E:** Add a fixed maximum directory-entry count before materialization.

### Rubric

| Criterion | Weight | Purpose |
| --- | ---: | --- |
| Memory-bound correctness | 30 | Entry count must not select process memory. |
| Hidden/link/error safety | 25 | The scan must still detect uncertain entries. |
| Verification strength | 20 | Tests must reject eager behavior, not just output drift. |
| Reciprocal contract clarity | 15 | P1A and T1A need an explicit comparison surface. |
| Implementation churn | 10 | Secondary to correctness and evidence. |

### Scores

| Option | Memory | Safety | Verification | Reciprocal | Churn | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 3 | 1 | 1 | 5 | 42 |
| B | 1 | 5 | 4 | 2 | 3 | 65 |
| C | 5 | 5 | 5 | 5 | 4 | **98** |
| D | 5 | 1 | 3 | 2 | 4 | 63 |
| E | 4 | 4 | 3 | 3 | 2 | 69 |

### Selected resolution

Select **C**. Every exact-cardinality scan will stop after `N + 1` results and
retain no more than those results. Every absence scan will consume one stream
to completion without collecting it. A matching, unreadable, or unclassifiable
entry will stop the scan and retain uncertain state where cleanup or ownership
is involved.

Add `PS-P1A-HARNESS-PROOFS-v1` with the single row `PS-P1A-H-01`. Apply the
row to Windows PowerShell 5.1 on Windows, PowerShell 7 on Windows, and
PowerShell 7 on Ubuntu. Require three results. Bind the proof to the exact
supplied scripts with syntax-tree inspection, a traced temporary copy, an eager
mutant, and a positive control. Reject missing, duplicate, unknown, skipped,
or multiply emitted proof results.

## Integration trace

| Finding | Issue integration |
| --- | --- |
| F01 | P1A paths/order, harness evidence, reciprocal matrix, validation, acceptance, and handoff |

The selected resolution does not add, delete, rename, or reorder an issue
draft.
