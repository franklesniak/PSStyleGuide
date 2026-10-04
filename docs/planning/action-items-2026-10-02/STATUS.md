# Execution tracker <!-- markdownlint-disable MD013 MD022 -->
Purpose: current state and one next action; chronology is in optional per-task journals.
Restart: read this table, README, LOOP-POLICY, your task file, your task's RESULT; open a journal only when resuming that task.
States: pending, active, validating, waiting_external, waiting_human, complete, verified, conditional-no-trigger, superseded, convergence-blocked. Verified requires an independent reader on final inputs.
Planning head: `e5ada3feae7b2cc20c70d9e0f4770efb6c3e652d` (prior published checkpoint) plus current execution checkpoint on `planning-CRT-PR-852`; never merge this branch into main.

| ID | Outcome | State | Owner/worker | Repository and branch | Pinned head/base | PR number | Round used/80 and deadline UTC | Transfers used/cap | Latest evidence | One next action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [A00](tasks/A00.md) | Reconcile historical obligations and retirement decisions | complete | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A00/RESULT.md) | Reuse the canonical native delivery ledger |
| [A01](tasks/A01.md) | Refresh issue coverage and full-tree baseline | complete | coordinator; post230 verified | PS/TF main | PSfb32889 / TF06ad4f7 | — | 0/80; not started | 0/8 | [Post230 inventory](results/A01/post230/REPORT.md) | Refresh at next native mutation; retain81 historical paths |
| [A02](tasks/A02.md) | Non-protected shared governance | validating | coordinator; local quality passed | TF codex/a02-peer-docs | TF06ad4f7 / PSfb32889 | —;226 accepted | peer not started;226 used10/80 | 1/12 | [Evidence](results/A02/RESULT.md) | Accept remaining A03 source; use verified first-adoption map for coherent TF integration |
| [A03](tasks/A03.md) | Converge workflows and retain meaningful admission and freshness controls | validating | coordinator | PS codex/workflow-setup-convergence | treeecae3f2 / basefb32889 | 230 accepted; next none | 230 used3/80; next not started | 0/12 | [Evidence](results/A03/RESULT.md) | Collect sole repaired aggregate5879; keep product/index frozen |
| [A04](tasks/A04.md) | Bound ordinary Node downloads and test retries | validating | coordinator | PS/TF main | PS425795b / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A04/RESULT.md) | Refreshed inputs; integrate after A03/A07 acceptance |
| [A05](tasks/A05.md) | Require immutable event acquisition in the YAML guide | active | coordinator | PS/TF main | PS425795b / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A05/RESULT.md) | Exact two-guide authority approved; integrate after A03 foundation |
| [A06](tasks/A06.md) | Converge the generator and artifact verification | validating | coordinator | PS/TF main | PS425795b / TF06ad4f7 | — | 0/80; not started | 0/12 | [Evidence](results/A06/RESULT.md) | C98 frontmatter spacing selected; implement generator convergence after accepted foundations |
| [A07](tasks/A07.md) | Converge dependency, lint and local toolchain behavior | validating | coordinator; PS source accepted | PS main; TF integration pending | PSc13abc4 / TF06ad4f7 | [227 merged](https://github.com/franklesniak/PSStyleGuide/pull/227) | 2/80;2026-10-11T09:51:36.838999Z | 0/12 | [Evidence](results/A07/RESULT.md) | Integrate coherent TF set after A20 and A03 source acceptance |
| [A08](tasks/A08.md) | Converge repository review instructions | verified | a00/d07; coordinator post229 recheck | PS/TF main | PS3e068af / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A08/RESULT.md) | Retain unchanged wrapper; recheck after relevant input change |
| [A09](tasks/A09.md) | Converge current supply checks and preserve truthful history | validating | coordinator | PS/TF main | PS425795b / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A09/RESULT.md) | Historical inputs unchanged; repair current test coupling after prerequisites |
| [A10](tasks/A10.md) | Revalidate PowerShell examples and bounded preflight outcomes | superseded | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A10/RESULT.md) | A18 verifies examples and preflight residuals |
| [A11](tasks/A11.md) | Revalidate Terraform state-version discovery and retrieval | superseded | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A11/RESULT.md) | A18 verifies delivered T2 behavior |
| [A12](tasks/A12.md) | Assess useful main protection | complete | coordinator | PS/TF main | PSfb32889 / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A12/assessment.md) | Rechecked broadened events; retain approved protection |
| [A13](tasks/A13.md) | Apply an authorized protection delta, if selected | verified | coordinator; independent closure passed | PS main ruleset24419725 | PSfb32889 | 230 merged | 0/80; not started | 0/8 | [Evidence](results/A13/RESULT.md) | Post230 rules/check producers verified; reassess relevant changes |
| [A14](tasks/A14.md) | Assess and address live filesystem residuals | conditional-no-trigger | coordinator | PS/TF main | PSfb32889 / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A14/RESULT.md) | Post230 caller reassessed; retain open residual and triggers |
| [A15](tasks/A15.md) | Reconcile Terraform manual recovery scope against current callers | validating | coordinator; proposal independently reviewed | PS/TF main | PS425795b / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A15/RESULT.md) | Proposal passed; refresh accepted foundation interfaces before A16 |
| [A16](tasks/A16.md) | Deliver Terraform Gate A nonmutating foundation | pending | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/12 | [Evidence](tasks/A16.md) | Wait for A15/A06/A07 acceptance |
| [A17](tasks/A17.md) | Deliver Terraform Gate B destructive-procedure guidance | pending | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/16 | [Evidence](tasks/A17.md) | Wait for accepted Gate A and owner approval |
| [A18](tasks/A18.md) | Close remaining byte differences and verify convergence | pending | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/12 | [Evidence](tasks/A18.md) | Run final union and A10/A11 checklist after products |
| [A19](tasks/A19.md) | Reconcile issues and publish final acceptance | pending | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](tasks/A19.md) | Refresh final issue census after A18 |
| [A20](tasks/A20.md) | Protected instruction files | validating | coordinator; PS source accepted | PS main; peer integration pending | main3e068af / reviewed84fb436 | [229 merged](https://github.com/franklesniak/PSStyleGuide/pull/229) | 2/80;2026-10-11T17:00:14Z | 0/8 | [Review state](results/A20/integration-current/review-state.json) | Accept A03 source, then coherent TF transfer and reverse comparison |
| [A21](tasks/A21.md) | Instruction validator, SelfTest, and classification manifest convergence | validating | coordinator; PS source accepted | PS codex/instruction-validator-convergence | 425795b / c13abc4 | [228 merged](https://github.com/franklesniak/PSStyleGuide/pull/228) | 1/80;2026-10-11T13:06:25Z | 0/12 | [Evidence](results/A21/RESULT.md) | Integrate A20 coupling, then coherent whole-source TF transfer |

## Local configuration and in-flight native operations

- Planning: `C:/Users/flesniak/GitHub/PSStyleGuide`; peer: `C:/Users/flesniak/GitHub/TerraformStyleGuide`.
- A20 product: `C:/Users/flesniak/.codex/worktrees/ps-shared-governance/PSStyleGuide`; clean84fb436; root owns lifecycle.
- Scratch prefix: `C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-`; A02 suffix `A02-design-20261002`, resume `PR224-review-state.json`; D07 suffix `plan-review-20261002`.
- Node24.18.1/npm11.16.0: prefix + `A07-design-20261002/runtime/node-v24.18.1-win-x64`; Python `py -3.12`; PowerShell7.6.5. PS5.1 Restricted.
- A02 source: PR226 accepted2a2; scratch `A02-landed-exit-20261003/repair-review-state.json`.
- A03: `C:/Users/flesniak/.codex/worktrees/a07-braces-remediation/PSStyleGuide`; codex/workflow-setup-convergence, basefb32889, staged treeecae3f2. Scratch A03-setup-lifecycle-20261004/execution-state.json owns sole repaired aggregate5879 from10:24:19Z; D11 preflight PASS. Prior89382 passed all11 on d13 and is archived in pre-D11-execution-state.json. PR230 accepted; no next PR/request or duplicate aggregate.
- A02 peer: scratch `A02-peer-current-20261003/execution-state.json`; product TEMP `TerraformStyleGuide-A02-peer-docs-20261003`, codex/a02-peer-docs. root owns reviewed docs; audit FINDINGS; transfer1/12.
- Held A07: `C:/Users/flesniak/.codex/worktrees/a07-tooling/PSStyleGuide`; treec68b5e1. Reconciliation complete; preserve index and unrelated edits.
- A21: scratch `A21-selection-20261003/execution-state.json`; PR228 accepted425795b; no native operation live.
- D08 grants: A03 P, CLAUDE repairs, YAML patches, A13 settings; A20/A15 clear-winner execution.
- A20: PR229 accepted3e068af/tree1a338970; all reviews/local/landed gates passed. Scratch A20-source-lifecycle-20261003/execution-state.json; peer awaits A03.
- A13: active24419725; post230 rules and Actions15368 contexts verified atfb32889. Evidence in A03 landed-batch-acceptance.json; no settings change.
- A15: repaired proposal passed independent review; actual GateA/B human approvals later.

## Final results

- [A00: historical delivery and remaining obligations](results/A00/RESULT.md)
- [A01: accepted native inventory](results/A01/RESULT.md)
- [A08: independently verified wrapper scope](results/A08/RESULT.md)
- [A12: accepted read-only protection assessment](results/A12/assessment.md)
