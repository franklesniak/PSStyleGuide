<!-- markdownlint-disable MD013 -->

# PS232 R4 — JSONC visitor callback applicability

Selected by root after public options, rubric, scores and selection on2026-10-05: **N100, no product change.** H `f77a58dede8f6f68b45e0d62e5b96e2fed477c58`, B `f168f83b89f64b6bca9d520ddec4b58969060fb6`. Copilot comment4182292113, review5412179344, alleges that onError receives only three arguments and therefore yields NaN coordinates. This is a distinct review allegation about the API used by accepted TF66 R13 V98, not a new demonstrated diagnostic defect.

## Validation and prior decision applicability

The locked installed package is jsonc-parser3.3.1. Its shipped main.d.ts:235 declares five error-callback arguments, including line and character. The shipped parser.js visitor wraps the callback through toOneArgVisit, which supplies the scanner's native coordinates. Some internal consumers declare only three parameters because they use only the first three; that does not reduce the arguments the visitor supplies. The official tagged [Microsoft API source](https://github.com/microsoft/node-jsonc-parser/blob/v3.3.1/src/main.ts) independently confirms the five-argument contract. getLocation reports a JSON structural path/context, not a ready-made line/column pair; replacing the callback with that API would still require coordinate conversion.

Pinned Node24.18.1 executed probe.cjs against the real current helper and installed parser. LF, CRLF, lone CR, preceding surrogate pair, and multiple-error input each yielded five callback arguments. The first one-based positions were2:12,3:1,3:1,1:26,1:7; the last input yielded three errors. Actual loadMarkdownlintConfig rejected all five with the corresponding finite positions and count; no NaN occurred. probe.log and command.json preserve exact command, output and exit0. This is a small Windows probe, not a full suite or new Linux claim.

The current helper is raw-identical to accepted TF56cb041's helper. Canonical [TF66 R13 V98](TF66-R13-jsonc-diagnostic.md) already selected this installed native visitor after LF/CRLF/CR/Unicode/count comparison. Its accepted prior Windows/Linux results, bounded-output controls and outer/staged/nested CLI evidence remain reusable at their unchanged scope. Current lint-markdown.test.mjs:305–325 durably checks the same positions/count, followed by bounded/no-source-disclosure and retained-semantic controls. No duplicate test is needed. The parser remains admission authority; the visitor only reports diagnostics after rejection. The one-MiB input cap and status behavior remain intact. Dependency upgrades must revalidate the API/tests; an unsupported future version is not evidence of a present failure.

## Stakeholders and options

Contributors need accurate editor locations. CI/agent operators need stable rejection and useful bounded diagnostics. Security reviewers need unchanged parser authority and no source disclosure. Maintainers need the existing dependency contract and meaningful retained regression coverage. Peer reviewers need common bytes and a source-grounded response rather than an invented runtime defect.

| ID | Material option | Tradeoff |
| --- | --- | --- |
| N | Retain implementation; document exact API and existing decision in review disposition | Preserves proven native positions and correct behavior. |
| D | Add an inline version/API comment | Improves local discovery of the dependency contract; duplicates evidence without changing behavior. |
| O | Compute coordinates locally from the first parse offset | Feasible but requires independently correct CR/LF/UTF-16 scanning. |
| G | Use getLocation/offset plus coordinate conversion | Structural location API does not remove the need for character-to-line calculation. |
| F | Add finite-coordinate checking with a bounded fallback | Defends against an unobserved API mismatch; adds a second diagnostic path needing distinct proof. |
| U | Change parser version or introduce another parser boundary | Could support a different verified contract; requires new dependency and semantic evidence absent here. |

D can accompany F/O/G, but adds only the same comment discoverability to their existing tradeoff. F can accompany a new converter, but there is no observed invalid-coordinate condition to justify two new mechanisms. No-change plus future dependency revalidation is N. Removing location detail is not a valid fix for this disproved claim and conflicts with the selected useful R13 diagnostic requirement. No package change is authorized by this proposal.

## Finding-specific rubric and scores

Scale0–5:0 absent/contradicted,3 adequate with a stated residual,5 fully supported; intermediate scores reflect degree. Sum(weight*score/5). Mandatory: keep rejection/status, parser/config authority, native coordinate meaning, input/output bounds and no source disclosure. These cannot be traded for convenience.

| Criterion | Weight | Assessment |
| --- | ---: | --- |
| Native-coordinate correctness | 35 | Accurate newline/UTF-16 positions for the installed contract. |
| Contributor diagnostic usefulness | 25 | Preserve actionable code/location/count. |
| Admission/privacy/bounds preservation | 20 | No changed acceptance or expanded disclosure. |
| Evidence strength | 10 | Actual current-runtime results and supported API, not hypothetical compatibility. |
| Maintenance | 7 | Avoid unnecessary duplicate coordinate/fallback logic. |
| Effort | 3 | Proportionate implementation and validation. |

| Option | Correctness35 | Usefulness25 | Preservation20 | Evidence10 | Maintenance7 | Effort3 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 5 | 5 | 5 | 5 | 5 | 5 | 100 |
| D | 5 | 5 | 5 | 5 | 4 | 4 | 98 |
| O | 4 | 5 | 5 | 3 | 3 | 3 | 85 |
| G | 4 | 5 | 5 | 3 | 2 | 2 | 83 |
| F | 5 | 5 | 5 | 4 | 4 | 3 | 95.4 |
| U | 3 | 4 | 4 | 2 | 2 | 1 | 64.4 |

Recommend N100. This wins on established correctness and complete usefulness, not merely churn. D is valid but adds no missing user outcome. O/G are feasible alternatives, not intrinsically incorrect; their lower correctness/evidence scores reflect unimplemented replacement logic versus the demonstrated native positions, and G's structural-location API supplies no added coordinate benefit. F could be useful if a supported runtime actually lacked coordinates; no such runtime is present. U is scored as a potentially compatible replacement, not presumed unsafe, but lacks supporting implementation/admission evidence.

## Controlled-English recommendation and scope

1. Keep the current five-argument callback.
2. Keep the installed parser and existing bounds.
3. Retain the existing position and bounded-output tests.
4. Link the tagged API and actual probe in the review reply.
5. Recheck the contract when the parser dependency changes.

No product write set, metadata update, new test or peer transfer follows from this no-change recommendation. Root selects/disposes after the displayed options, rubric and scores; this file does not post or resolve a thread. All76 tracked files equal H, and HEAD/raw index hashes match before/after. Relevant dependency files are identity-pinned; no install or dependency write occurred. evidence.json records the exact source identities and artifact hashes.

The review itself is valid current-head Lite. The separate agentic run37285407379 subsequently hit the authenticated20-minute cap after setup validation/final guard succeeded; Processing Request Linux was canceled. Root's round3 terminal receipts preserve that failure. Do not relabel the run successful or the observed effort Balanced, and do not retry merely for effort.

## Implementation of the selected disposition

The product files remain unchanged at Hf77a58d. Root verified the source evidence and score arithmetic and selected N100 after displaying the complete process. No repeated aggregate or new product test is required for this no-change result. Native thread replies and the review-facing PR summary follow this published decision; they do not relabel the earlier Copilot review as findings-free. The full paired lifecycle remains open.
