# Execution tracker <!-- markdownlint-disable MD013 MD022 -->
Purpose: current state and one next action; chronology is in optional per-task journals.
Restart: read this table, README, LOOP-POLICY, your task file, your task's RESULT; open a journal only when resuming that task.
States: pending, active, validating, waiting_external, waiting_human, complete, verified, conditional-no-trigger, superseded, convergence-blocked. Verified requires an independent reader on final inputs.
Planning head: `d19f5d18f456f46e397c489c7fb438f0866ead2a` (prior published checkpoint) plus current execution checkpoint on `planning-CRT-PR-852`; never merge this branch into main.

| ID | Outcome | State | Owner/worker | Repository and branch | Pinned head/base | PR number | Round used/80 and deadline UTC | Transfers used/cap | Latest evidence | One next action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [A00](tasks/A00.md) | Reconcile historical obligations and retirement decisions | complete | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A00/RESULT.md) | Reuse the canonical native delivery ledger |
| [A01](tasks/A01.md) | Refresh issue coverage and full-tree baseline | complete | coordinator; native refresh verified | PS/TF main | PSc13abc4 / TF06ad4f7 | — | 0/80; not started | 0/8 | [Post227 inventory](results/A01/post227/CURRENT-REFRESH-POST227.md) | Refresh at next native mutation; preserve historical 81 |
| [A02](tasks/A02.md) | Non-protected shared governance | active | coordinator; local quality passed | TF codex/a02-peer-docs | TF06ad4f7 / PS2a2d14a | —;226 accepted | peer not started;226 used10/80 | 1/12 | [Evidence](results/A02/RESULT.md) | Retain reviewed two docs; satisfy current A07 audit gate before acceptance |
| [A03](tasks/A03.md) | Converge workflows and retain meaningful admission and freshness controls | waiting_human | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/12 | [Evidence](results/A03/RESULT.md) | Exact option L prepared; await owner choice |
| [A04](tasks/A04.md) | Bound ordinary Node downloads and test retries | validating | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A04/design.md) | Integrate after A03/A07 acceptance |
| [A05](tasks/A05.md) | Require immutable event acquisition in the YAML guide | waiting_human | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A05/design.md) | Await exact two-guide authority |
| [A06](tasks/A06.md) | Converge the generator and artifact verification | validating | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/12 | [Evidence](results/A06/RESULT.md) | Retain retirements; validate current generator |
| [A07](tasks/A07.md) | Converge dependency, lint and local toolchain behavior | active | coordinator; PS source accepted | PS main; TF integration pending | PSc13abc4 / TF06ad4f7 | [227 merged](https://github.com/franklesniak/PSStyleGuide/pull/227) | 2/80;2026-10-11T09:51:36.838999Z | 0/12 | [Evidence](results/A07/RESULT.md) | Integrate coherent TF foundation after accepted A21 and scoped grants |
| [A08](tasks/A08.md) | Converge repository review instructions | verified | a00 + independent d07 | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A08/RESULT.md) | Recheck wrapper only after relevant input change |
| [A09](tasks/A09.md) | Converge current supply checks and preserve truthful history | validating | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A09/RESULT.md) | Repair affected current supply tests after prerequisites |
| [A10](tasks/A10.md) | Revalidate PowerShell examples and bounded preflight outcomes | superseded | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A10/RESULT.md) | A18 verifies examples and preflight residuals |
| [A11](tasks/A11.md) | Revalidate Terraform state-version discovery and retrieval | superseded | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A11/RESULT.md) | A18 verifies delivered T2 behavior |
| [A12](tasks/A12.md) | Assess useful main protection | complete | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A12/assessment.md) | Reuse accepted protection assessment |
| [A13](tasks/A13.md) | Apply an authorized protection delta, if selected | waiting_human | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A12/desired-ps-ruleset.json) | Await exact ruleset authority |
| [A14](tasks/A14.md) | Assess and address live filesystem residuals | conditional-no-trigger | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A14/RESULT.md) | Reopen only on changed caller/threat inputs |
| [A15](tasks/A15.md) | Reconcile Terraform manual recovery scope against current callers | validating | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A15/read-only-design.md) | D5 proposal reviewed; await exact amendments and foundations |
| [A16](tasks/A16.md) | Deliver Terraform Gate A nonmutating foundation | pending | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/12 | [Evidence](tasks/A16.md) | Wait for A15/A06/A07 acceptance |
| [A17](tasks/A17.md) | Deliver Terraform Gate B destructive-procedure guidance | pending | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/16 | [Evidence](tasks/A17.md) | Wait for accepted Gate A and owner approval |
| [A18](tasks/A18.md) | Close remaining byte differences and verify convergence | pending | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/12 | [Evidence](tasks/A18.md) | Run final union and A10/A11 checklist after products |
| [A19](tasks/A19.md) | Reconcile issues and publish final acceptance | pending | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](tasks/A19.md) | Refresh final issue census after A18 |
| [A20](tasks/A20.md) | Protected instruction files | waiting_human | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A02/protected-v2-request.md) | PR224 merged; await explicit protected authority |
| [A21](tasks/A21.md) | Instruction validator, SelfTest, and classification manifest convergence | waiting_external | coordinator; reviews and CI pending | PS codex/instruction-validator-convergence | 2273a23 / c13abc4 | [228](https://github.com/franklesniak/PSStyleGuide/pull/228) | 1/80;2026-10-11T13:06:25Z | 0/12 | [Evidence](results/A21/RESULT.md) | Reconcile current-head Copilot, automatic Codex and instruction CI |

## Local configuration and in-flight native operations

- Planning: `C:/Users/flesniak/GitHub/PSStyleGuide`; peer: `C:/Users/flesniak/GitHub/TerraformStyleGuide`.
- A21 product: `C:/Users/flesniak/.codex/worktrees/ps-shared-governance/PSStyleGuide`; codex/instruction-validator-convergence clean2273a23/tree5cc; root owns lifecycle.
- Scratch prefix: `C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-`; A02 suffix `A02-design-20261002`, resume `PR224-review-state.json`; D07 suffix `plan-review-20261002`.
- Node24.18.1/npm11.16.0: prefix + `A07-design-20261002/runtime/node-v24.18.1-win-x64`; Python `py -3.12`; PowerShell7.6.5. PS5.1 Restricted; no Docker container remains.
- A02 source: PR226 accepted2a2; round10; four landed runs pass. Worktree suffix `governance-push-exit/PSStyleGuide`; scratch `A02-landed-exit-20261003/repair-review-state.json`.
- A07 follow-up: `C:/Users/flesniak/.codex/worktrees/a07-braces-remediation/PSStyleGuide`; clean reviewedc9; PR227 mergedc13 and all five landed runs pass. Resume: scratch suffix `A07-reconcile-20261003/execution-state.json`; source accepted.
- A02 peer: scratch `A02-peer-current-20261003/execution-state.json`; product TEMP `TerraformStyleGuide-A02-peer-docs-20261003`, codex/a02-peer-docs. root owns reviewed docs; audit FINDINGS; transfer1/12.
- Held A07: `C:/Users/flesniak/.codex/worktrees/a07-tooling/PSStyleGuide`; treec68b5e1. Reconciliation complete; preserve index and unrelated edits.
- A21: scratch suffix `A21-selection-20261003/execution-state.json`; PR228 round1; Copilot37125185247, automatic Codex5969455000 and instructionCI37125066160 pending; no duplicate request.
- Await A03-D1: owner-label L, procedural P or other direction.
- Await A20: six protected-v2 files and separate two-CLAUDE protocol grant.
- Await A05: two YAML-guide patch grant.
- Await A13: exact ruleset and bounded PR validation/restoration grant.
- Await A15: D1/D3/D4/D5 amendments at938367c; actual Gate grants separate.

## Final results

- [A00: historical delivery and remaining obligations](results/A00/RESULT.md)
- [A01: accepted native inventory](results/A01/RESULT.md)
- [A08: independently verified wrapper scope](results/A08/RESULT.md)
- [A12: accepted read-only protection assessment](results/A12/assessment.md)
