# Execution tracker <!-- markdownlint-disable MD013 MD022 -->
Purpose: current state and one next action; chronology is in optional per-task journals.
Restart: read this table, README, LOOP-POLICY, your task file, your task's RESULT; open a journal only when resuming that task.
States: pending, active, validating, waiting_external, waiting_human, complete, verified, conditional-no-trigger, superseded, convergence-blocked. Verified requires an independent reader on final inputs.
Planning head: `bc7e853037cadb49f89df6697552f59788a054b8` (prior published checkpoint) plus current execution checkpoint on `planning-CRT-PR-852`; never merge this branch into main.

| ID | Outcome | State | Owner/worker | Repository and branch | Pinned head/base | PR number | Round used/80 and deadline UTC | Transfers used/cap | Latest evidence | One next action |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [A00](tasks/A00.md) | Reconcile historical obligations and retirement decisions | complete | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A00/RESULT.md) | Reuse the canonical native delivery ledger |
| [A01](tasks/A01.md) | Refresh issue coverage and full-tree baseline | complete | coordinator; post231 verified | PS/TF main | PSf168f83 / TF06ad4f7 | — | 0/80; not started | 0/8 | [Current inventory](results/A01/post231/REPORT.md) | Refresh at next native mutation; retain81 historical paths |
| [A02](tasks/A02.md) | Non-protected shared governance | validating | coordinator; independent review | TF codex/a02-peer-docs | TF06ad4f7 / PSf168f83 | peer PR not opened; source accepted | peer0/80; clock not started; source history retained | 1/12 | [Evidence](results/A02/RESULT.md) | Collect sole aggregate15404 on525147aa; then committed endpoints and native gates |
| [A03](tasks/A03.md) | Converge workflows and retain meaningful admission and freshness controls | validating | coordinator; independent review | TF codex/a02-peer-docs | TF06ad4f7 / PSf168f83 | peer PR not opened; source accepted | peer0/80; clock not started; source history retained | 1/12 | [Evidence](results/A03/RESULT.md) | Collect sole aggregate15404 on525147aa; then committed endpoints and native gates |
| [A04](tasks/A04.md) | Bound ordinary Node downloads and test retries | validating | coordinator | PS/TF main | PS425795b / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A04/RESULT.md) | Refreshed inputs; integrate after A03/A07 acceptance |
| [A05](tasks/A05.md) | Require immutable event acquisition in the YAML guide | active | coordinator | PS/TF main | PS425795b / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A05/RESULT.md) | Exact two-guide authority approved; integrate after A03 foundation |
| [A06](tasks/A06.md) | Converge the generator and artifact verification | validating | coordinator; handoff verified | PS/TF main | PSf168f83 / TF06ad4f7 | — | 0/80; not started | 0/12 | [Evidence](results/A06/RESULT.md) | Current handoff verified; implement C98 and convergence after accepted coherent foundations |
| [A07](tasks/A07.md) | Converge dependency, lint and local toolchain behavior | validating | coordinator; independent review | TF codex/a02-peer-docs | TF06ad4f7 / PSf168f83 | peer PR not opened; source accepted | peer0/80; clock not started; source history retained | 1/12 | [Evidence](results/A07/RESULT.md) | Collect sole aggregate15404 on525147aa; then committed endpoints and native gates |
| [A08](tasks/A08.md) | Converge repository review instructions | verified | a00/d07; coordinator post229 recheck | PS/TF main | PS3e068af / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A08/RESULT.md) | Retain unchanged wrapper; recheck after relevant input change |
| [A09](tasks/A09.md) | Converge current supply checks and preserve truthful history | validating | coordinator | PS/TF main | PS425795b / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A09/RESULT.md) | Historical inputs unchanged; repair current test coupling after prerequisites |
| [A10](tasks/A10.md) | Revalidate PowerShell examples and bounded preflight outcomes | superseded | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A10/RESULT.md) | A18 verifies examples and preflight residuals |
| [A11](tasks/A11.md) | Revalidate Terraform state-version discovery and retrieval | superseded | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A11/RESULT.md) | A18 verifies delivered T2 behavior |
| [A12](tasks/A12.md) | Assess useful main protection | complete | coordinator | PS/TF main | PSf168f83 / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A12/assessment.md) | Rechecked broadened events; retain approved protection |
| [A13](tasks/A13.md) | Apply an authorized protection delta, if selected | verified | coordinator; independent closure passed | PS main ruleset24419725 | PSf168f83 | 231 merged | 0/80; not started | 0/8 | [Evidence](results/A13/RESULT.md) | Post231 rules/check producers verified; reassess relevant changes |
| [A14](tasks/A14.md) | Assess and address live filesystem residuals | conditional-no-trigger | coordinator | PS/TF main | PSf168f83 / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A14/RESULT.md) | Post231 callers reassessed; retain open residual and triggers |
| [A15](tasks/A15.md) | Reconcile Terraform manual recovery scope against current callers | complete | coordinator; proposal review and interface refresh complete | PS/TF main | PSfb32889 / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](results/A15/RESULT.md) | Use reconciled proposal after A06/A07; refresh changed interfaces before A16 integration |
| [A16](tasks/A16.md) | Deliver Terraform Gate A nonmutating foundation | pending | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/12 | [Evidence](tasks/A16.md) | Wait for A15/A06/A07 acceptance |
| [A17](tasks/A17.md) | Deliver Terraform Gate B destructive-procedure guidance | pending | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/16 | [Evidence](tasks/A17.md) | Wait for accepted Gate A and owner approval |
| [A18](tasks/A18.md) | Close remaining byte differences and verify convergence | pending | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/12 | [Evidence](tasks/A18.md) | Run final union and A10/A11 checklist after products |
| [A19](tasks/A19.md) | Reconcile issues and publish final acceptance | pending | coordinator | PS/TF main | PS48f4d8a / TF06ad4f7 | — | 0/80; not started | 0/8 | [Evidence](tasks/A19.md) | Refresh final issue census after A18 |
| [A20](tasks/A20.md) | Protected instruction files | validating | coordinator; independent review | TF codex/a02-peer-docs | TF06ad4f7 / PSf168f83 | peer PR not opened; source accepted | peer0/80; clock not started; source history retained | 1/8 | [Review state](results/A20/integration-current/review-state.json) | Collect sole aggregate15404 on525147aa; then committed endpoints and native gates |
| [A21](tasks/A21.md) | Instruction validator, SelfTest, and classification manifest convergence | validating | coordinator; independent review | TF codex/a02-peer-docs | TF06ad4f7 / PSf168f83 | peer PR not opened; source accepted | peer0/80; clock not started; source history retained | 1/12 | [Evidence](results/A21/RESULT.md) | Collect sole aggregate15404 on525147aa; then committed endpoints and native gates |

## Local configuration and in-flight native operations

- Planning: `C:/Users/flesniak/GitHub/PSStyleGuide`; branch planning-CRT-PR-852. Peer: `C:/Users/flesniak/GitHub/TerraformStyleGuide`.
- Scratch prefix: `C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-`; all suffixes below are relative to it. Closed lifecycles remain in their task RESULT links.
- Runtime: prefix + `A07-design-20261002/runtime/node-v24.18.1-win-x64` (Node24.18.1/npm11.16.0); `py -3.12`; PowerShell7.6.5. PS5.1 Restricted.
- A03 source accepted at mainf168f83/treec82fa2e; all candidate and landed checks pass. Closed source state: `A03-setup-lifecycle-20261004/execution-state.json`. Do not repeat merge/reviews.
- Coherent TF: frozen39-path/78-file tree525147aa in `C:/Users/flesniak/AppData/Local/Temp/TerraformStyleGuide-A02-peer-docs-20261003`, HEAD06ad. State `TF-coherent-20261004/execution-state.json`; capacity repair focused Win/Linux375/0 each; independent private/integrated reviews pass. Staged preflight passed; sole aggregate15404 live. Do not edit state while its wrapper runs. Both prior failures retained. Session `TF-coherent-20261004/capacity-validation-session.json`. Reverse capacity addendum ready; accepted-TF refresh due. Five outcomes transfer1; no peer PR clock.
- Held A07: `C:/Users/flesniak/.codex/worktrees/a07-tooling/PSStyleGuide`, treec68b5e1; preserve index/unrelated edits. A20 source accepted in PR229.
- A07 R5/B1 selected: results/A07/recovery-runtime; private `A07-recovery-runtime-proposal-20261004`. No implementation yet.
- A06 current handoff: results/A06/post231-readiness; verified; no product writer.
- TF accepted-base fixture: `TF-accepted-base-20261004`; verified clean B; classifier not yet run.
- Retained grants: A03 P, A20 protected previews/CLAUDE repairs, A05 exact YAML patches and A13 settings. A15 preparation complete; actual GateA/B human approvals remain later boundaries. PS ruleset24419725 remains active.

## Final results

- [A00: historical delivery and remaining obligations](results/A00/RESULT.md)
- [A01: accepted native inventory](results/A01/RESULT.md)
- [A08: independently verified wrapper scope](results/A08/RESULT.md)
- [A12: accepted read-only protection assessment](results/A12/assessment.md)
- [A15: selected recovery proposal and current foundation interfaces](results/A15/RESULT.md)
