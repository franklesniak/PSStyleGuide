<!-- markdownlint-disable MD013 -->
# PR234 R5: incremental summary presence checks

Reviewed head: `24b18795e5f6e260b095310ddd116cb0f1b19f6b`; PS base `d7b206adbce4f54edd6dd3d86d3dc2fa8e344b48`; accepted TF `e21b74fe0b56551008f78f9f2946cd2a0f9c19ce`. This is the canonical writer decision; root owns public replies, counters, integration and lifecycle. No protected guide change is selected.

**Validation.** Comment4188451256, threadPRRT_kwDOQkjdhM6pM-Ig. The every-guide-line allegation is false: PowerShell -and stops before the output scan unless the source line matches a summary insertion boundary, and PS has no inferred SummaryBefore boundary. A supported repeated-boundary guide does reveal quadratic predicate work in TF-style composition:100/200 repeated heading lines cause5851/21701 visits; ordinary lines cause101/201 (pre-edit-probes.json). Track observed output incrementally without changing which earlier emitted lines suppress summary insertion.

**Stakeholders.** TF authors and consumers need exact executive-summary placement and suppression behavior, including explicit markers and rationale text. PS users need unchanged goldens. Maintainers and new contributors need a small understandable state machine. CI/cost owners benefit from bounded work without timing-dependent tests. Reviewers need negative controls that distinguish insertion flags from actual output presence. No cloud or privacy authority changes.

**Options, before scoring.**

- A: Retain short-circuited scans; document the bounded current guides.
- B: Use flags set only when this function inserts the summary TOC/section.
- C: Keep two presence flags plus a cursor; inspect each accumulated output line at most once when a boundary needs the facts.
- D: Pre-scan guide/rationale separately and infer final output presence.
- E: Route every output Add through a new general emission helper with summary state.
- F: Remove summary inference. Deferral retains A and has no separate behavior.

**Fresh rubric, fixed before scoring.** Scores1–5: 1 fails the criterion, 2 weak, 3 adequate with a material limitation, 4 strong, 5 fully satisfies the bounded need. Weighted total is sum(weight × score)/5; scores are engineering judgments, not measurements.

- Semantics (40%): Preserve suppression from all previously emitted guide/marker/rationale lines and exact bytes.
- WorkBound (25%): Bound repeated presence checks by emitted lines rather than repeated full-prefix scans.
- Clarity (15%): Keep explicit state and the existing single composition engine understandable.
- Verification (15%): Prove repeated-boundary and pre-existing-content behavior without a flaky time threshold.
- Cost (5%): Limit machinery and touch points.

| Option | Semantics | WorkBound | Clarity | Verification | Cost | Total | Key limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 5 | 1 | 4 | 3 | 5 | 71 | Normal guides are linear, repeated matching boundaries remain quadratic. |
| B | 2 | 5 | 5 | 3 | 5 | 70 | Misses pre-existing or marker-emitted summary text; violates hard constraint. |
| C | 5 | 5 | 4 | 5 | 4 | 96 | Cursor must account for trailing blank/separator removal. |
| D | 2 | 5 | 2 | 2 | 3 | 56 | Unemitted rationale and ordering make raw pre-scan semantically wrong. |
| E | 5 | 5 | 2 | 4 | 1 | 84 | Every emission site changes and gains a special-purpose helper contract. |
| F | 1 | 3 | 2 | 1 | 2 | 34 | Removal loses required TF content; ineligible. |

**Selected solution.** Use C. Before the guide loop, set the output cursor to zero and both presence flags to false. At a matching insertion boundary, inspect only output lines at or after the cursor. Record the same summary-text and summary-heading matches used today. Move the cursor past each inspected line. Use those flags in the insertion conditions. After removing trailing blank/separator lines, clamp the cursor to the new count. Set the matching flags when inserting a summary TOC or section. Keep marker handling, order, matching semantics and publication unchanged.

**Verification and limits.** Add cases for repeated insertion boundaries, existing summary prose, explicit TOC markers and rationale-emitted summary headings. Compare actual PS and immutable TF four-output goldens. Use a private instrumented cursor count to show linear work, and kill an insertion-only flag mutant. Run the affected real focused generator harness; root retains full aggregate and hosted cells. No wall-clock speedup claim follows from predicate counts alone.

**Primary references and existing decisions.** [PowerShell logical operators](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_logical_operators) describes stopping when the first operand determines the result. A06-D1 preserves marker/heading/summary semantics and one shared engine; D2 preserves useful oracles.

Hard constraints: preserve both language goldens, all marker meanings, ordering and fixed publication roles; no protected source change. Completion: actual Windows7.6.5 harness117 assertions passed;14 differential cases match the preimage exactly; insertion-only flags mutant killed.100/200 repeated TOC-plus-heading boundaries visit208/408 cursor positions in the plain guide case (predicate instrumentation, no wall-clock claim). Two private actual TF-descriptor generator runs returned NoChange with all four immutable e21 golden byte sequences equal. Changed PS parser/analyzer0. The final .0 WIP metadata correction follows STYLE_GUIDE publication rules; behavior logs precede only that documented correction.
