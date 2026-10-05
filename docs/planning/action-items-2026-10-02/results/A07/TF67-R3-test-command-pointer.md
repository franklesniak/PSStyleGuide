<!-- markdownlint-disable MD013 -->
# TF67 R3: Retain the accurate test-command pointer

Coordinator-accepted decision. The complete options, rubric, scores and selection were displayed before public disposition. No product edit is selected.

Input: TerraformStyleGuide PR67, H `443b2fe3cbeda18402f0432e5c95379d09096d6a`, tree `89f470ceb6b3e6e9d4ae757e38997f1c6e7bd631`, B `56cb0418dcdcf71be94acc78d8963ea580b8a9e9`. Copilot review5417485797, comment4186175643, thread `PRRT_kwDOSAZRhc6pHce7`, `.github/workflows/scripts-README.md`:16. The finding questions “Selected test commands appear below” on the conditional premise that the file ends at the shown excerpt.

## 1. Validate the claim and material benefit

The premise is false for the full current file. The table ends at line37. Line43 gives `node --test .github/workflows/Test-CiHelpers.test.mjs .github/workflows/Test-LocalValidation.test.mjs` and `node --test .github/workflows/Classify-InstructionMaintenance.test.mjs`. It states the Linux prerequisite for loader, runtime and shell-hook cases. Line45 gives `node --test .github/workflows/NpmTools.test.mjs .github/workflows/Check-NpmAudit.test.mjs`. Lines55–59 introduce a fenced command, `node --test .github/workflows/lint-markdown.test.mjs`, for focused caller/configuration/path/hook controls. These are actual commands below line16, including commands in explanatory paragraphs.

All six named test files exist as regular tracked files at current H. The recurring candidate command in agent-instructions.yml:210 contains those same six files plus Validate-WorkflowPolicy.test.mjs. The table's Validate-WorkflowPolicy purpose cell also names that suite. The README says selected, so it does not promise an exhaustive list or that commands occur only in the table. The table explicitly excludes test suites and the loaded SelfTest, links their directory listing, and describes operational tools/helpers. Its supported-command column mainly gives operational invocations or internal callers; directing readers there as the exclusive test location would be incorrect.

[The full README](https://github.com/franklesniak/TerraformStyleGuide/blob/443b2fe3cbeda18402f0432e5c95379d09096d6a/.github/workflows/scripts-README.md) and [recurring CI caller](https://github.com/franklesniak/TerraformStyleGuide/blob/443b2fe3cbeda18402f0432e5c95379d09096d6a/.github/workflows/agent-instructions.yml) are the primary evidence. [PS232 R6](https://github.com/franklesniak/PSStyleGuide/blob/818cf71224054ce04c81e7dd79eb4751d8bbd6b6/docs/planning/action-items-2026-10-02/results/A07/PS232-R6-script-inventory.md) selected the operational inventory, explicit test exclusions and retained detailed tail. That choice has been correctly adapted to TF's recovery child, T1 link and native verify name. The new R3 claim does not expose missing commands or invalidate the catalog boundary. R7 and R9 do not change this documentary location question.

No source truncation is present. The reviewer accurately qualifies the claim with “If the file ends here”; actual full-file inspection resolves that condition. No user failure, wrong command, missing prerequisite or material navigation defect is demonstrated. Removing the pointer would reduce a useful navigation signal. A direct subsection link can be useful on a more structured test catalog, but the present commands live in nearby introductory paragraphs as well as the Outer and staged Markdown section. A new tests section/page, duplicate listing or general drift automation would have maintenance and reviewer costs with no current missing information. Existing filenames and caller inspection are sufficient; no network research is required.

## 2. Identify affected stakeholders

- New contributors and documentation readers need a truthful route from the operational table to applicable test commands. Selected signals that the commands are partial; the directory link provides complete filename discovery.
- Experienced maintainers in both repositories need tool/caller authority boundaries and language-specific recovery facts preserved. They also maintain the command descriptions when interfaces change.
- Windows/Linux contributors, Bash/PowerShell users and local/remote agent operators need the exact Node setup and explicit Linux limits already attached to the relevant suites. Moving snippets can separate those prerequisites from their commands.
- CI/platform engineers, QA and independent-quality reviewers need retained suites tied to real callers, not tests that assert an exact sentence or repeat a manually curated table.
- Security and supply-chain reviewers need no invented standalone invocation for accepted-base or Linux-only tools. Privacy/data owners and cloud administrators have no new output/data/permission surface.
- The owner, history custodians and schedule/cost stakeholders need disproved feedback closed with full-file evidence and no invented deferred issue.

Accessibility and localization readers share the need for plain headings and nearby commands, but no UI or localized content changes. Terraform end users and generated-artifact consumers have no altered normative rule, runtime output or artifact. Security executives and recovery operators have no separate new risk decision; their concerns are covered by preserving the existing operational caller/prerequisite descriptions. No affected authority is omitted.

## 3. List applicable options before scoring

| ID | Option | Consequence |
| --- | --- | --- |
| N | Retain the accurate sentence and reply with the full-file command locations | Keeps truthful selected-test navigation and actual prerequisites. |
| R | Remove the sentence | Correct remaining prose, but removes the explicit signal that test commands follow. |
| T | Say test commands appear in the Supported command column | Mislocates most selected suites; contradicts actual content. |
| L | Add a tests section and replace below with a subsection link | Gives a precise target after moving/restructuring the existing scattered commands and their context. |
| M | Move all selected commands above the table | Gives immediate visibility; separates or repeats helper explanations and disrupts operational-first reading. |
| D | Create a separate test-command page and link it | A possible larger catalog; adds a navigation layer and a maintained location without a present need. |
| G | Generate the test catalog or add general documentation drift automation | Filenames are discoverable, but tooling cannot infer supported platforms/callers; needs curated mappings. |
| F | Leave the sentence and defer a navigation rewrite | Same present content as N; no genuine defect or future requirement to defer. |

Equivalent phrasing such as selected commands follow the table states the same current fact as N and does not repair a defect. Appending the existing fenced command again duplicates the tail. A link only to Outer and staged Markdown omits the paragraph suites; L must be assessed as a real section reorganization, not a knowingly incomplete link. Combining D/G retains both mapping and navigation costs. Removal of the table or tests is disproportionate and breaks retained discovery obligations. A native directory link already exists; no dependency or exception is needed.

## 4. Define the R3 rubric

Scores0–5:0 absent or contradicted;1 major deficit;2 substantial residual;3 usable with a material residual;4 meets with a limited residual;5 fully supported for current readers. Total = sum(weight × score /5). Scores are reasoned comparisons, not empirical user-error probabilities.

| Criterion | Weight | Finding-specific meaning |
| --- | ---: | --- |
| Full-document factual accuracy | 32 | Match the real locations and selected scope of the retained commands. |
| Contributor discovery | 28 | Help readers find actual tests after the operational tool inventory. |
| Prerequisite/caller preservation | 22 | Keep commands with their Linux/setup/authority context and avoid unsupported guarantees. |
| Reading continuity | 10 | Fit the existing headings and nearby explanatory paragraphs without needless navigation. |
| Information upkeep | 6 | Avoid duplicate command mappings or split documentation ownership. |
| Delivery/verification cost | 2 | Use proportional checks without sentence snapshots or repeated aggregates. |

Hard constraints: preserve the operational table boundary, meaningful existing entries and language-specific facts; describe actual commands and prerequisites; do not claim the file ends at the excerpt; do not invent new supported invocations. T fails factual accuracy. F fails the genuine-deferral constraint because no current unresolved task exists.

## 5. Score every option before selection

| Option | Accuracy32 | Discovery28 | Context22 | Continuity10 | Upkeep6 | Cost2 | Total | Key uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 5 | 5 | 5 | 5 | 5 | 5 | 100 | Reopen if retained commands move away or are removed. |
| R | 5 | 3 | 4 | 5 | 5 | 5 | 84.4 | Readers still see commands, but lose the explicit selected-test signal. |
| T | 2 | 2 | 2 | 5 | 5 | 5 | 50.8 | Most commands are below the table, not in that column; ineligible. |
| L | 5 | 5 | 5 | 4 | 2 | 2 | 93.2 | Better precise targeting after restructuring; no current missing route. |
| M | 5 | 4 | 4 | 3 | 3 | 2 | 82.4 | Must move associated explanations or duplicate them. |
| D | 5 | 4 | 3 | 2 | 1 | 1 | 73.2 | Another page needs supported-platform/caller ownership. |
| G | 4 | 4 | 3 | 3 | 1 | 1 | 68.8 | A generated filename list cannot establish command validity. |
| F | 5 | 4 | 5 | 4 | 2 | 3 | 88 | No genuine pending task; ineligible. |

Arithmetic is checked in evidence.json. N =32+28+22+10+6+2=100. L =32+28+22+8+2.4+0.8=93.2. N clears all hard constraints and uniquely wins. Actual commands already satisfy the sentence; the review's conditional premise is disproved. L receives full accuracy/discovery/context credit and is feasible, not forbidden by scope. Its benefit is a new precise link for a restructured catalog, with no demonstrated failure in present navigation. The current information is already local, partial scope is explicit and reader flow remains clear. No settings, escalation or policy preference needs owner arbitration.

## 6. State the selected action and limits

1. Keep the sentence at line16.
2. Keep the selected test commands below the table.
3. Keep the test prerequisites.
4. Cite lines43,45 and58 in the review reply.
5. Link this decision after root publishes it.
6. Reassess the sentence if the commands move or are removed.

The instructions use short direct sentences, consistent technical names, one action per sentence and an explicit trigger. Applicable ASD-STE100 writing rules were checked at that level; formal approved-dictionary compliance is not claimed. The complete documentation instructions already require accurate examples and explicitly partial lists. No secondary style-guide recommendation is warranted because the actual document follows those relevant rules. No guide update, new Issue or deferred work is selected.

The native reply will cite this published canonical decision. Root verifies the reply and resolves the thread.

## 7. Implement the no-change disposition and verify

No product implementation is required. The complete README is inspected. It has the commands at the stated positions and the commands reference actual tracked test files. Test filenames and the recurring agent-instructions.yml command match. README SHA256 is `9e483a42e1a01130205bc7dfa55fdac5e4a4c36244f98eb57e250d2cc0c86d97`; Git blob `9a88a8ebdba3a24cf45c82639da4bcb2442c5271`, mode100644,13086 bytes. The seven relevant source identities match saved final R1 evidence. All78 tracked raw files, HEAD/tree, index and stage0 are checked before and after private report generation.

The saved Linux exact-tree89f470c aggregate uses `/opt/psstyleguide-runtime/venv/bin/python -m pre_commit run --all-files`. It passes11 hooks with0 skips and exit0, including staged Markdown, policy and agent-instruction controls. This validates unchanged product input; it does not measure documentation discoverability. The aggregate's result.json records completion2026-10-05T15:30:59.829875Z; aggregate log SHA256 `36a436cb6db77d5ac3d86b55ffe2c930dee217382e9d54381075c065c13af45c`. Local complete-source proof, not a fresh execution of suites, resolves the claimed absence. Saved focused manifest tests are not falsely presented as a navigation test.

No product tests, suite, aggregate, installation, Git/native mutation or network request ran for this disposition. No exact-sentence or catalog mirror assertion was added. Root owns hosted semantic reconciliation, fresh independent quality and public closure. Round2/80, deadline2026-10-13T14:30:38.034661Z and A07/A21 transfer3/12 remain unchanged. The review remains terminal Lite with findings in history; a refuted finding is not a rewritten clean review.
