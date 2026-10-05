<!-- markdownlint-disable MD013 -->

# PS232 R5 — script inventory table delimiters

Selected by root after public options, rubric, scores and selection on2026-10-05: **N100, no product change.** H `f77a58dede8f6f68b45e0d62e5b96e2fed477c58`, B `f168f83b89f64b6bca9d520ddec4b58969060fb6`. Copilot comment4182292172, review5412179344, alleges that the inventory rows begin with double pipes and render an empty first column.

## Validation

Raw Git blob `.github/workflows/scripts-README.md:16–30` has15 source lines: header, delimiter and13 script rows. Every line starts one pipe followed by a space; every row contains four delimiters for three cells. No line begins `||`. The comment's own authenticated diff also shows one leading pipe per row. Its claim does not describe the reviewed bytes.

Pinned Node24.18.1 and existing markdown-it14.3.2 parsed the exact raw published source into14 rendered rows, each containing exactly three cells. The saved HTML has the expected Script/Purpose/Supported command header and no empty leading column. A corrected synthetic four-column control produces four header cells, demonstrating that the probe distinguishes the claimed shape. This is a local parser check, not a claim to have reproduced GitHub's entire renderer.

Root independently opened the actual [GitHub published preview](https://github.com/franklesniak/PSStyleGuide/blob/f77a58dede8f6f68b45e0d62e5b96e2fed477c58/.github/workflows/scripts-README.md) in CUA Edge3 tab75572469. Preview AX286 contained14 rows with three cells each, including the flagged Validate-WorkflowPolicy row. This is explicitly root's observation, not this author's browser test. It corroborates the raw and local-parser results.

Official [GFM table specification](https://github.github.com/gfm/#tables-extension-) describes pipe-separated cells, with optional leading/trailing pipes, and a header/delimiter pair. The published source follows that grammar. No hidden fourth column or missing inventory item was demonstrated. This is a new false source/rendering allegation; earlier script-inventory convergence decisions remain applicable and need no redesign.

Fixture note (D07): the first private negative prepended a pipe to the delimiter without adding a hyphen cell. The parser correctly stopped recognizing it as a table; the assertion expecting four cells failed. Preserve probe.cjs/probe.log/command.json. The corrected private negative adds a real delimiter cell; probe-corrected.cjs exits0 and proves four cells. No product or durable test was changed.

## Stakeholders and options

Maintainers and contributors need a readable mapping from script to purpose and supported command. Keyboard/screen-reader users need a coherent table rather than an accidental empty column. Documentation authors need portable source syntax and intact links/code spans. Reviewers need a truthful disposition tied to exact bytes. Paired-repository owners need shared useful descriptions and the existing necessary language-specific entries retained.

| ID | Material option | Tradeoff |
| --- | --- | --- |
| N | Keep the valid table and explain raw/rendered evidence | Preserves the complete readable inventory. |
| R | Remove the alleged extra leading delimiters | No matching bytes exist; applying this intent yields no edit and is equivalent to N. Removing real delimiters would target different source. |
| T | Reformat padding/alignment while preserving the table | Could improve source alignment; no rendering defect is repaired. |
| L | Replace the inventory with a list | Portable and readable, but weakens side-by-side script/purpose/command comparison. |
| H | Replace Markdown table with explicit HTML | Can preserve cells but adds renderer/sanitizer and source-readability considerations. |
| A | Add general reusable table-shape validation | Could detect future malformed tables, but introduces machinery without a present gap. |

A literal snapshot of this exact table would merely mirror low-impact implementation and is prohibited by the developer test instruction; A is scored only as a genuinely general validator. T+A combines cosmetic source alignment with A's machinery and supplies no additional current correctness outcome. H+A changes the validation surface without adding a demonstrated user benefit. R is not scored as an independent repair because it has no applicable edit. Existing Markdown validation and this bounded evidence suffice for N.

## Finding-specific rubric and scores

Root selected the distinct40/20/20/12/5/3 weighting before scoring. Scale0–5:0 absent/contradicted,3 adequate with a concrete residual,5 fully supported. Sum(weight*score/5). Hard gates: retain every inventory entry, correct command/link and necessary language-specific description; retain accessible usable content. Do not delete content to simplify validation.

| Criterion | Weight | Assessment |
| --- | ---: | --- |
| Rendered structure | 40 | Correct three-column table with no false empty column. |
| Reader command navigation | 20 | Easy script/purpose/command comparison and working references. |
| Markdown portability/accessibility | 20 | Clear structure in source and supported renderers. |
| Evidence strength | 12 | Raw bytes, actual preview and discriminating parser proof. |
| Maintenance | 5 | Avoid unnecessary formatting or validation machinery. |
| Effort | 3 | Proportionate work for the actual finding. |

| Option | Structure40 | Navigation20 | Portability20 | Evidence12 | Maintenance5 | Effort3 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 5 | 5 | 5 | 5 | 5 | 5 | 100 |
| T | 5 | 5 | 5 | 5 | 4 | 4 | 98.4 |
| L | 4 | 3 | 5 | 3 | 4 | 3 | 77 |
| H | 5 | 4 | 3 | 3 | 2 | 2 | 78.4 |
| A | 5 | 5 | 5 | 4 | 3 | 2 | 93.8 |

Recommend N100. Actual source and GitHub preview already meet the primary correctness/usability criteria. T is equally sound for rendering but offers no demonstrated improvement here. L can remain accessible; its reduction is comparative navigation rather than an assertion that lists are inherently wrong. H can render correctly but requires additional portability/sanitization proof. A is not dismissed merely for churn: there is no observed undetected malformed source to justify a new enforcement surface, and its new-general-validator evidence is not yet available. The developer rule independently excludes literal-mirroring tests.

## Controlled-English recommendation and scope

1. Keep the inventory table unchanged.
2. Retain all13 script rows and three columns.
3. Cite the raw published lines and actual GitHub preview.
4. Record the comment as a disproved source claim.
5. Preserve the existing meaningful Markdown checks.

No product path, metadata update, new durable test or peer transfer is proposed. Root selects the disposition after the ordered process and owns native replies/resolution. evidence.json pins source/mode, exact commands/logs and the root-attributed browser observation. All76 tracked files still match H; raw index and HEAD are unchanged. No suite, install, dependency mutation or native action occurred. The original failed private negative is retained and does not imply a product failure.

The valid current-head review was observed Lite. Root separately retains the authenticated20-minute agentic-service timeout and canceled Processing Request after successful setup/final guard; this does not make the two factual allegations true or change the effort record.

## Implementation of the selected disposition

The product files remain unchanged at Hf77a58d. Root verified the source evidence and score arithmetic and selected N100 after displaying the complete process. No repeated aggregate or new product test is required for this no-change result. Native thread replies and the review-facing PR summary follow this published decision; they do not relabel the earlier Copilot review as findings-free. The full paired lifecycle remains open.
