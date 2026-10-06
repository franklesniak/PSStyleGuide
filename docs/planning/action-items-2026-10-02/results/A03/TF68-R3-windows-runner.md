<!-- markdownlint-disable MD013 -->
# TF68-R3: Retain the supported Windows runner

Date: 2026-10-06. Owner: A03, coordinated with A06. One finding covers Copilot comments4190960527 and4190960581 in review5423146423 on Terraform PR68. Both comments report the same runner-availability concern. Input Hf89d47d6780db47df29be4eb6d79cab35051f598/tree24ca66c74b176bb83037c453ee506aa3fee0cf5f; acceptedBe21b74fe0b56551008f78f9f2946cd2a0f9c19ce. Root displayed validation, options, rubric, scores and selection in order before disposition. No product edit is selected.

## Validation

The allegation is not substantiated for the actual target repository. The current GitHub runner reference lists `windows-2025` for public and private repositories. GitHub's runner-images announcement records general availability from April8,2025. More decisively, both current-head build runs allocated this exact label and completed both required Windows jobs successfully. This is observed execution, not a guess from a label or a queued job.

PR run37403248039 contains Windows5.1 job112074941564 and Windows7 job112074941567. Push run37403245728 contains jobs112074934298 and112074934224 respectively. Each native job has labels exactly `["windows-2025"]`, completed/success status, and two successful156assertion passes. Actual editions are Desktop5.1.26100.33438 and Core7.6.6, imagewin25-vs2026/20260925.250.1. PR checkout5ae270467cb8321ace156efc5f187869fb0b19c9 has ordered parentsB/H and the candidate tree; the push checkout isH. The same-revision artifact gate and publication also passed.

The workflow's actual label lines are9 and137; the second review comment is attached to adjacent line138. Workflow SHA256f167000746a833091b656bfe796c57d667badff691fd4d6a305307166982afdc. Full native proof is `C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A06-TF-peer-20261005/R3-runner-native-evidence.json`; the independently checked complete proof is [current platform evidence](../A06/TF-PR68-R2-platform-proof.json), SHA2562c9c8eab9ee93ea0697d16d3fd579c39326bb8f25bff2037d8e47f7c06c31c2d.

This evidence does not promise future queue capacity or an immutable image patch level. An explicit OS label still receives image updates. A future actual availability failure or announced withdrawal is a reassessment trigger. Copilot's separate20minute Linux setup timeout is not evidence that the Windows label is unavailable.

## Stakeholders and options

Experienced maintainers and QA need actual supported-platform execution; new contributors and documentation readers need an understandable runner choice. DevOps and project managers need predictable allocation and diagnosis. Security engineers and executives need the existing credential-free acquisition and required admission controls preserved. Business stakeholders need useful coverage without gratuitous infrastructure ownership. UX concerns here are legible failure causes and reliable contribution checks, not a new user interface. Both repository owners need paired workflow behavior without an unnecessary new divergence. No personal-data or regulated-transaction interface changes.

Options, enumerated before scoring:

- A: Keep `windows-2025`; answer both comments with primary documentation and current native results.
- B: Replace both labels with `windows-latest`.
- C: Replace both labels with `windows-2022`.
- D: Add2022 alongside2025, including matching policy/admission coverage.
- E: Move to a separately managed or self-hosted runner. Provisioning and access would require their own actual authority.
- F: Fall back to another label or make Windows jobs optional when unavailable.
- G: Keep the label but add an availability policy, documentation requirement or preflight check.
- H: Repeat the same current Windows jobs solely for additional availability evidence.
- I: Keep the code but defer replying to the finding.

Adding A's evidence to B-H retains the corresponding extra change without addressing another demonstrated defect. Multi-label combinations reduce to D or F. A queue preflight cannot guarantee later allocation; a same-revision successful job already supplies stronger evidence for the current candidate. Removing the Windows jobs is the coverage-losing limit of F. Pinning a different2025 image label without a demonstrated image requirement also reduces to an unnecessary label change. A separate availability monitor would require an actual operational need and does not establish the present finding.

## Finding-specific rubric

Score each criterion from0to10:0 defeats the requirement;5 provides partial or uncertain support;10 has strong support from current evidence. Intermediate scores reflect a reasoned tradeoff. Weighted total is the sum of score times weight divided by10. These are engineering judgments, not statistical measurements.

| Criterion | Weight | What the score assesses |
| --- | ---: | --- |
| Technical correctness | 35% | Uses a supported runner and addresses the actual current evidence instead of assuming a scheduling defect. |
| Required test coverage | 25% | Preserves real Windows5.1/7 execution and same-revision admission. QA, users and maintainers depend on these guarantees. |
| Operational predictability | 20% | Avoids silent platform movement, fallback semantics and new infrastructure ownership; preserves security and DevOps diagnosis. |
| Contributor/reviewer clarity | 15% | Gives new contributors and reviewers a concise, verifiable explanation without a misleading future-capacity guarantee. |
| Maintenance and cost | 5% | Avoids unnecessary jobs, policy upkeep or runner management. Churn alone cannot outweigh correctness. |

Hard constraints: do not skip either required Windows edition; do not bypass protection; do not credit an unstarted job as passed; do not provision new security-sensitive runner access without actual authority. F fails if implemented as optional or silently degraded coverage.

## Scores

| Option | Correctness | Coverage | Predictability | Clarity | Maintenance | Total | Main limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 10 | 10 | 9 | 9 | 10 | **96.5** | Future service availability remains conditional. |
| B | 7 | 8 | 6 | 7 | 8 | 71 | Adds a moving OS-family alias without solving an observed fault. |
| C | 6 | 7 | 8 | 8 | 7 | 70 | Replaces already proved2025 behavior with different platform evidence. |
| D | 8 | 10 | 6 | 6 | 4 | 76 | More coverage can be useful, but no present requirement justifies the added matrix and admission scope. |
| E | 5 | 8 | 4 | 3 | 2 | 51 | Adds infrastructure, security and operator ownership without a current allocation defect. |
| F | 3 | 4 | 6 | 5 | 5 | 42.5 | Optional/degraded coverage fails the hard constraints. |
| G | 8 | 10 | 8 | 8 | 6 | 84 | Duplicates supported-label/current-run evidence and cannot guarantee future capacity. |
| H | 7 | 10 | 7 | 5 | 7 | 74.5 | Repeating four already successful cells gives little new evidence. |
| I | 6 | 10 | 8 | 4 | 10 | 73 | Leaves a directly answerable concern unresolved for readers. |

## Selected action

Select A. Keep `windows-2025`. Keep both required Windows jobs. Reply to each comment. Include the GitHub runner reference. Include the completed run results. Record both comments under TF68-R3. Resolve each thread after the reply is confirmed. Reassess if GitHub removes the label or an actual run shows an availability problem.

These instructions use short direct controlled wording. No formal ASD dictionary certification is claimed. No product file, settings rule, transfer count or review clock changes. Existing scoped approval permits this clear-winner disposition. No owner action is needed. The separate command-length finding remains open.

## Execution and limits

Root verified the current raw workflow, four exact-label job records, eight pass lines and existing independent platform binding. Existing completed tests are reused because this decision changes no product bytes. No extra Windows run is required solely to answer this finding. Both native replies are confirmed and both exact threads are resolved. Reply4191014123 addresses comment4190960527; reply4191034944 addresses comment4190960581. Complete readback round2-progress-11.json confirms only the separate R4 review thread remains unresolved. The current TF execution state retains exact reply bodies, IDs, native timestamps and local verification timestamps. This decision does not accept the entire PR or mark either reviewer clean.

## References

- [GitHub-hosted runner reference](https://docs.github.com/en/actions/reference/runners/github-hosted-runners): current supported labels, checked2026-10-06.
- [GitHub runner-images GA announcement](https://github.com/actions/runner-images/issues/11742): official availability announcement.
- [Current PR build run](https://github.com/franklesniak/TerraformStyleGuide/actions/runs/37403248039): actual current-tree Windows and Linux execution.
- [Current push build run](https://github.com/franklesniak/TerraformStyleGuide/actions/runs/37403245728): actual current-head execution.
