<!-- markdownlint-disable MD013 -->
# PR234 R6: report distinct scan experiments accurately

Current candidate: `07636c8633b8544eb30c71ce1b24d2bcdef4c74e`, tree `01e26ec47626495e76a29fe5cb407a02781d5d7a`. This decision concerns PR reporting only. Root owns publication, attribution, pending reviews and lifecycle. Product files and prior evidence remain unchanged.

## 1. Validate

The current local PR body has SHA256 `0143e8015a81e6eba20d9a3a76c0271b24f8f28006e7369012bb64e3e242b763`. Its R5 sentence says the controls reduce visits “from5851/21701 to208/408 for the measured100/200 inputs.” This suggests a matched-input comparison that the scripts did not execute.

| Evidence | Actual experiment | Observed result |
| --- | --- | --- |
| pre-edit-probes.ps1 / .json | Guide title, 100/200 repeated heading lines, one additional final heading; simple summary rationale; AppendStandalone=false. Instrumentation increments inside old Where-Object predicates. | 5851/21701 predicate visits. Separate ordinary-line cases have101/201. |
| post-edit-probes.ps1 / .json | Plain-guide prefix, 100/200 TOC-plus-heading pairs; additional Details Rationale and Extra content; AppendStandalone=true. Instrumentation increments the new cursor-advance statement. | 208/408 cursor visits. These are distinct input shapes and operations, not a matched reduction or runtime result. |
| Same post-edit script / JSON | Seven prefixes times two sizes. For each case, the old and new functions receive the same guide, rationale and descriptor. | All14 outputs compare equal; insertion-only flag mutant is killed. This behavioral evidence is unaffected. |

The canonical R5 decision already distinguishes repeated heading lines from TOC-plus-heading boundaries and disclaims wall-clock claims. The public-body shorthand loses that distinction. Repair has concrete reviewer value: prevent an unsupported numerical comparison without new instrumentation, duplicated tests or persistent product machinery. Validation here is inspection of exact scripts and saved JSON, not a rerun. No external-behavior claim needs additional web research.

## 2. Stakeholders

The owner and PS/TF maintainers need a truthful disposition of R5. Code and independent-quality reviewers need to separate semantic equivalence, operation counts and performance claims. New contributors and documentation readers need clear evidence units without reconstructing fixture details. QA and history custodians need original experiments preserved with traceable hashes. CI and schedule owners need to avoid new runs that do not resolve an outstanding product uncertainty. Artifact users retain the same product behavior. Security, privacy, cloud, dependency and recovery roles have no changed authority, data exposure or operational control in this reporting-only action.

## 3. Options before scoring

- A: Keep the body unchanged. Deferral has the same reporting defect and is scored as A.
- B: Replace the comparison with both count sets, explicit input shapes, descriptor differences, units and non-comparability.
- C: Remove numerical counts from the body. Keep the14 matched-output comparisons, the mutation result and scoped cursor-work explanation. Retain the canonical R5 record and raw experiments.
- D: Run a new matched-input operation-count experiment, then report its measured results with defined units and limits. Preserve existing experiments as history.
- E: Combine C with a separate body sentence that explicitly says the existing count experiments are incomparable.
- F: Combine B and D: retain detailed existing counts and add a matched experiment to the body.

Removing all R5 discussion would obscure the implemented review disposition and useful behavioral evidence; it fails the hard constraint below. Shared reporting machinery, product changes and a runtime benchmark do not repair this bounded wording defect more directly. B with an additional warning is already B; C with that warning is E. Native tools are reused for read-only inspection and hashing, not new execution.

## 4. Fresh rubric before scoring

Scores1–5 mean: 1 fails; 2 weak; 3 adequate with a material limitation; 4 strong; 5 fully meets this bounded reporting need. Weighted total=sum(weight times score)/5. Scores are judgments, not experimental measurements.

- Evidence fidelity,40%: accurately separate matched output equivalence, unlike input shapes, unlike operation units and runtime claims; remove the misleading comparison.
- Reviewer usability,25%: explain the implemented disposition and its support with minimal reconstruction and distraction; help a new reader avoid a false inference.
- Audit traceability,20%: preserve original scripts/results, provenance, valid controls and a clear path from the body to detailed limits.
- Proportional effort,10%: avoid unnecessary execution, repeated validation, maintenance, restart complexity and reporting churn. Convenience cannot override truth.
- Evidential completeness,5%: provide enough direct support for the scoped algorithm and behavioral claims; additional matched operation measurements can improve this criterion but are not required to correct wording.

Hard constraints: no false same-input or speedup claim; preserve valid behavioral evidence and historical raw results; no product changes or unauthorized publication. A is ineligible because it retains the known misleading inference.

## 5. Scores before selection

| Option | Fidelity40 | Usability25 | Traceability20 | Effort10 | Completeness5 | Total | Key limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 1 | 1 | 3 | 5 | 2 | 37 | Known misleading comparison remains; ineligible. |
| B | 5 | 3 | 5 | 5 | 4 | 89 | Accurate, but two incomparable counts and fixture details burden the review summary. |
| C | 5 | 5 | 5 | 5 | 4 | 99 | No new matched operation measurement; none is needed for the selected scoped claims. |
| D | 5 | 4 | 5 | 2 | 5 | 89 | New execution and unit design are needed; results cannot be assumed in advance. |
| E | 5 | 4 | 5 | 5 | 4 | 94 | Accurate warning repeats history after the numerical claim has been removed. |
| F | 5 | 2 | 5 | 1 | 5 | 77 | Most evidence detail and new work; least focused body. |

## 6. Selected controlled-English action

Select C. Replace only the R5 body bullet with the proposed bullet below. Remove the numerical comparison. Retain the14 matched output comparisons. Retain the mutation result. State the purpose of the cursor without a whole-generator runtime claim. Keep the R5 decision link. Preserve both original scripts and both result files. Do not run a new experiment for this correction. Root must apply the body change through its authorized publication process. Do not change product files or review counters. These instructions use short direct actions; formal ASD-STE100 dictionary compliance is not claimed.

## Proposed accurate body wording

- **R5: C96 selected.** Track newly emitted output with a cursor and summary-presence flags. Include marker, guide and rationale output, and adjust the cursor after trailing blank/separator removal. Fourteen same-input comparisons produce identical old and new outputs; the insertion-only flag mutant is rejected. The cursor avoids repeated full-prefix scans when checking summary presence. These checks do not establish a runtime speedup. [Options, rubric, scores and result](https://github.com/franklesniak/PSStyleGuide/blob/3fc49fd47b40879532b71c53560a86718779ad7d/docs/planning/action-items-2026-10-02/results/A06/PR234-round1/R5-summary-scans.md).

## 7. Preparation and verification

Read both exact scripts, both saved JSON files, the R5 decision and the body. Confirmed the14 Equal=true results and InsertionOnlyMutantKilled=true; confirmed the two count pairs and body preimage hash. Saved this decision, a replacement-bullet proposal and source hashes in R6-measurement-reporting-evidence.json. No tests were executed. No earlier evidence or PR-body file was modified. Actual body publication and verification remain with root; this record does not claim that the live PR is corrected.
