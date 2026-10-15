<!-- markdownlint-disable MD013 -->
# Round 8 expected-refusal output retention

The independent delta reader found that the new durable cases retain native output in memory and assertions, but expected refusals appear only as pass summaries. Fixture cleanup removes their files. This is a real evidence gap against F1 selected step11 in [ROUND8-DECISIONS.md](ROUND8-DECISIONS.md), not a defect in the semantic checker or expected refusal. Root displayed the options, fresh rubric, scores and selection before this edit on 2026-10-15.

Options: A keep summaries; B add separate manual captures; C emit captured nonzero child results through the test context diagnostic; D print them directly to the console; E retain private fixture directories; F add CI artifact persistence; G combine C and F. These cover no-change, separate execution, existing test channels, local storage, remote storage and the useful combination. Weak combinations add duplicate storage without improving the selected contract. A fails the evidence requirement regardless of its score.

Unique rubric, scores1(poor) through5(strong): evidence completeness32% covers exact observed status and separate captured stdout/stderr; unchanged test behavior26% covers assertions, supported-platform execution and failure propagation; safe cleanup/data handling20% covers private fixtures and no credentials; readable results12% covers test attribution and diagnosis; operational reliability6% covers normal CI retention without a new upload service; effort4% is deliberately lowest. The rubric considers engineering, QA, security, DevOps, documentation, UX and owner audit needs. Total is sum(weight*score/5).

| Option | Evidence | Behavior | Safety | Readability | Reliability | Effort | Total |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A | 1 | 5 | 5 | 1 | 5 | 5 | 64.8 |
| B | 4 | 4 | 5 | 3 | 2 | 3 | 78.4 |
| C | 5 | 5 | 5 | 4 | 5 | 5 | 97.6 |
| D | 5 | 4 | 5 | 3 | 4 | 5 | 88.8 |
| E | 5 | 4 | 3 | 3 | 2 | 2 | 76.0 |
| F | 5 | 4 | 4 | 5 | 2 | 2 | 84.8 |
| G | 5 | 4 | 4 | 5 | 2 | 1 | 84.0 |

Selected C/97.6. Add one diagnostic after each real semantic-child or gate result. Emit it before the status assertion when status is nonzero. Include the mode, status, stdout and stderr as JSON. Keep existing assertions, timeouts, fixture contents and cleanup unchanged. Use normal test logs to preserve the captured text. Do not call this raw binary stream capture or retain the whole temporary repository. Existing assertions retain unexpected Git/generator failure output. No workflow or public interface changes.

Primary reference: [Node TestContext.diagnostic](https://nodejs.org/api/test.html#contextdiagnosticmessage). This API has existed since Node18/16.17. The current documentation says diagnostics appear with the test result; local Node24.18.1 verification will confirm the actual runner used here. The selected change does not require newer context.log.

Validation: run the focused actual capacity tests with the existing qualified Node/PowerShell PATH and preserve complete stdout/stderr. Require seven Windows semantic-child passes, four truthful Linux skips and diagnostic entries for all three expected direct-child refusals. The four real Linux cases still require actual supported CI. Independent reader checks this supplement and the earlier three-path repair; normal final-byte hooks and current-head PR gates remain required. Preserve old author packet and failed diagnostic-oracle output unchanged.
