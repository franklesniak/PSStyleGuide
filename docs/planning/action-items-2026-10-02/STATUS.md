# Execution tracker <!-- markdownlint-disable MD013 MD022 -->
Purpose: current state and one next action; chronology is in optional per-task journals.
Restart: read this table, README, LOOP-POLICY, your task file, your task's RESULT; open a journal only when resuming that task.
States: pending, active, validating, waiting_external, waiting_human, complete, verified, conditional-no-trigger, superseded, convergence-blocked. Verified requires an independent reader on final inputs.
Planning head: `e39128df62b7952f3a98a689e8ccb02b080608d3` (published execution checkpoint) plus current execution checkpoint on `planning-CRT-PR-852`; never merge this branch into main.

| ID | Outcome | State | Owner/worker | Repository and branch | Pinned head/base | PR number | Round used/80 and deadline UTC | Transfers used/cap | Latest evidence | One next action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [A00](tasks/A00.md) | Reconcile historical obligations and retirement decisions | complete | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A00/RESULT.md) | Reuse the canonical native delivery ledger |
| [A01](tasks/A01.md) | Refresh issue coverage and full-tree baseline | complete | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A01/RESULT.md) | Reuse accepted inventory; refresh at next mutation |
| [A02](tasks/A02.md) | Non-protected shared governance | validating | coordinator | PS codex/shared-governance | 519c420 / 48f4d8a | [224](https://github.com/franklesniak/PSStyleGuide/pull/224) | 3/80; 2026-10-10T07:26:08.214692Z | 0/12 | [Evidence](results/A02/RESULT.md) | Update PR body, resolve F5 and request round4 |
| [A03](tasks/A03.md) | Converge workflows and retain meaningful admission and freshness controls | waiting_human | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/12 | [Evidence](results/A03/RESULT.md) | Exact option L prepared; await owner choice |
| [A04](tasks/A04.md) | Bound ordinary Node downloads and test retries | validating | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A04/design.md) | Integrate after A03/A07 acceptance |
| [A05](tasks/A05.md) | Require immutable event acquisition in the YAML guide | waiting_human | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A05/design.md) | Await exact two-guide authority |
| [A06](tasks/A06.md) | Converge the generator and artifact verification | validating | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/12 | [Evidence](results/A06/RESULT.md) | Retain retirements; validate current generator |
| [A07](tasks/A07.md) | Converge dependency, lint and local toolchain behavior | active | A07 worker (a00) | PS codex/a07-tooling | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/12 | [Evidence](results/A07/RESULT.md) | First15-path batch passed; integrate held paths after PR224 |
| [A08](tasks/A08.md) | Converge repository review instructions | verified | a00 + independent d07 | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A08/RESULT.md) | Recheck wrapper only after relevant input change |
| [A09](tasks/A09.md) | Converge current supply checks and preserve truthful history | validating | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A09/RESULT.md) | Repair affected current supply tests after prerequisites |
| [A10](tasks/A10.md) | Revalidate PowerShell examples and bounded preflight outcomes | superseded | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A10/RESULT.md) | A18 verifies examples and preflight residuals |
| [A11](tasks/A11.md) | Revalidate Terraform state-version discovery and retrieval | superseded | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A11/RESULT.md) | A18 verifies delivered T2 behavior |
| [A12](tasks/A12.md) | Assess useful main protection | complete | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A12/assessment.md) | Reuse accepted protection assessment |
| [A13](tasks/A13.md) | Apply an authorized protection delta, if selected | waiting_human | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A12/desired-ps-ruleset.json) | Await exact ruleset authority |
| [A14](tasks/A14.md) | Assess and address live filesystem residuals | conditional-no-trigger | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A14/RESULT.md) | Reopen only on changed caller/threat inputs |
| [A15](tasks/A15.md) | Reconcile Terraform manual recovery scope against current callers | validating | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A15/read-only-design.md) | Resolve D5 oracles; refresh scope after foundations |
| [A16](tasks/A16.md) | Deliver Terraform Gate A nonmutating foundation | pending | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/12 | [Evidence](tasks/A16.md) | Wait for A15/A06/A07 acceptance |
| [A17](tasks/A17.md) | Deliver Terraform Gate B destructive-procedure guidance | pending | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/16 | [Evidence](tasks/A17.md) | Wait for accepted Gate A and owner approval |
| [A18](tasks/A18.md) | Close remaining byte differences and verify convergence | pending | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/12 | [Evidence](tasks/A18.md) | Run final union and A10/A11 checklist after products |
| [A19](tasks/A19.md) | Reconcile issues and publish final acceptance | pending | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](tasks/A19.md) | Read TF22/PR63 and reconcile final evidence |
| [A20](tasks/A20.md) | Protected instruction files | waiting_human | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A02/protected-v2-request.md) | Await PR224 merge and explicit protected authority |
| [A21](tasks/A21.md) | Instruction validator, SelfTest, and classification manifest convergence | pending | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/12 | [Evidence](results/A21/RESULT.md) | Refresh census after PR224; select one whole base |

## Local configuration and in-flight native operations

- Planning: `C:/Users/flesniak/GitHub/PSStyleGuide`; peer: `C:/Users/flesniak/GitHub/TerraformStyleGuide`.
- PS product: `C:/Users/flesniak/.codex/worktrees/ps-shared-governance/PSStyleGuide`. Coordinator owns publication; published519c420/tree `c204d80a4bd0a8252ba05e34485d3018317dca66`; full10-hook and actual B/H checks passed.
- Scratch prefix: `C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-`; A02 uses suffix `A02-design-20261002` (resume `PR224-review-state.json`, validation `D14-native-validation`); D07 uses `plan-review-20261002`.
- Node24.18.1/npm11.16.0: scratch prefix + `A07-design-20261002/runtime/node-v24.18.1-win-x64`; Python `py -3.12`; PowerShell7.6.5. PS5.1 remains Restricted. No Docker container remains.
- A02: Round2 clean on d9b9e1c. Round3 terminal on f81f769: Copilot5393527247 observed Balanced/none; Codex5393521315/comment4167109675 confirmed F5. Candidate CI37023858676 passed. F5 repaired in519c420; independent local quality approved. Fresh reviews/CI pending. No native operation pending. Clock/baselines in resume file.
- A07 is frozen at `C:/Users/flesniak/.codex/worktrees/a07-tooling/PSStyleGuide`; staged treec68b5e1 passed all11 hooks; a00 resumes after F5/PR224 before held-path integration. A15 scope/identity proposal prepared; D5 open. A21 whole-base census prepared; no base selected. A08 verified; A03 option L unselected. Preserve unrelated edits.
- Await A03-D1: owner-label gate L, procedural boundary P, or another direction.
- Await A20: six-file protected-v2 grant and separate two-CLAUDE protocol grant.
- Await A05: two YAML-guide immutable-acquisition patch grant.
- Await A13: exact PS ruleset and bounded ordinary-PR validation/restoration grant.
- At PR224 deadline only: request one dated extension/accept-at-limit/close decision; none supplied.

## Final results

- [A00: historical delivery and remaining obligations](results/A00/RESULT.md)
- [A01: accepted native inventory](results/A01/RESULT.md)
- [A08: independently verified wrapper scope](results/A08/RESULT.md)
- [A12: accepted read-only protection assessment](results/A12/assessment.md)
