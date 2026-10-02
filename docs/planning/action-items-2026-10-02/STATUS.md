<!-- markdownlint-disable MD013 -->
# Execution status and restart record

This is the sole current execution tracker. Product execution has **not started**. Planning/restructuring, historical evidence and current tree/issue inventories are prepared; they do not complete any product outcome. The old TEMP state and its completed402 marker are historical only.

After compaction or restart: read this file, README.md, LOOP-POLICY.md and the current task. Then read only its decisions, pending native operation and required predecessor results. Refresh mutable GitHub state before a mutation. Do not reconstruct progress from chat memory.

The coordinator owns this file. Workers return a concise handoff; they do not concurrently edit it. Use pending, active, validating, waiting_external, waiting_human, complete, conditional-no-trigger, or convergence-blocked. `Complete` requires the task predicate; history and planning work are not product completion. A conditional no-change may satisfy a dependency only when its actual branch predicate permits it.

| ID | Outcome | State | Owner | Transfers used/cap | PRs / evidence / next action |
| --- | --- | --- | --- | --- | --- |
| [A00](tasks/A00.md) | Reconcile historical obligations and retirement decisions | pending | unassigned | 0/8 | Read task; verify actual prerequisites |
| [A01](tasks/A01.md) | Refresh issue coverage and full-tree baseline | pending | unassigned | 0/8 | Read task; verify actual prerequisites |
| [A02](tasks/A02.md) | Converge shared governance, metadata and repository documentation | pending | unassigned | 0/12 | Read task; verify actual prerequisites |
| [A03](tasks/A03.md) | Converge workflows and retain meaningful admission and freshness controls | pending | unassigned | 0/12 | Read task; verify actual prerequisites |
| [A04](tasks/A04.md) | Bound ordinary Node downloads and test retries | pending | unassigned | 0/8 | Read task; verify actual prerequisites |
| [A05](tasks/A05.md) | Require immutable event acquisition in the YAML guide | pending | unassigned | 0/8 | Read task; verify actual prerequisites |
| [A06](tasks/A06.md) | Converge the generator and artifact verification | pending | unassigned | 0/12 | Read task; verify actual prerequisites |
| [A07](tasks/A07.md) | Converge dependency, lint and local toolchain behavior | pending | unassigned | 0/12 | Read task; verify actual prerequisites |
| [A08](tasks/A08.md) | Converge repository review instructions | pending | unassigned | 0/8 | Read task; verify actual prerequisites |
| [A09](tasks/A09.md) | Converge current supply checks and preserve truthful history | pending | unassigned | 0/8 | Read task; verify actual prerequisites |
| [A10](tasks/A10.md) | Revalidate PowerShell examples and bounded preflight outcomes | pending | unassigned | 0/8 | Read task; verify actual prerequisites |
| [A11](tasks/A11.md) | Revalidate Terraform state-version discovery and retrieval | pending | unassigned | 0/8 | Read task; verify actual prerequisites |
| [A12](tasks/A12.md) | Assess useful main protection | pending | unassigned | 0/8 | Read task; verify actual prerequisites |
| [A13](tasks/A13.md) | Apply an authorized protection delta, if selected | pending | unassigned | 0/8 | Read task; verify actual prerequisites |
| [A14](tasks/A14.md) | Assess and address live filesystem residuals | pending | unassigned | 0/8 | Read task; verify actual prerequisites |
| [A15](tasks/A15.md) | Reconcile Terraform manual recovery scope against current callers | pending | unassigned | 0/8 | Read task; verify actual prerequisites |
| [A16](tasks/A16.md) | Deliver Terraform Gate A nonmutating foundation | pending | unassigned | 0/12 | Read task; verify actual prerequisites |
| [A17](tasks/A17.md) | Deliver Terraform Gate B destructive-procedure guidance | pending | unassigned | 0/16 | Read task; verify actual prerequisites |
| [A18](tasks/A18.md) | Close remaining byte differences and verify convergence | pending | unassigned | 0/12 | Read task; verify actual prerequisites |
| [A19](tasks/A19.md) | Reconcile issues and publish final acceptance | pending | unassigned | 0/8 | Read task; verify actual prerequisites |

## Active handoffs and review state

None. At a meaningful boundary, keep one compact entry per active outcome. Include repository/worktree/branch, pinned head and base, paths owned, current stage, decision and test links, prerequisite outputs still needed, transfer number, and one next action. For each open PR retain first-request UTC, deadline UTC, rounds used/80, reviewed head and material body scope, last per-channel requests/results, native event/reviewer/review/workflow baselines needed for pending-request reconciliation, and final-quality result. Put a larger in-flight native baseline in one local resume file linked here; retain it across restart, then discard it after terminal evidence is linked. Do not commit secrets, browser session data or temporary receipts.

Record a possibly accepted mutation before retrying it. A missing local receipt does not justify repeating a native write. Preserve request history when a head changes. Preserve the PR clock and outcome transfer counter when a worker or chat changes.

## Final results

None. Add one result per completed outcome: accepted PS/TF commit and tree, relevant PR/check/review links, actual exception decisions, tests, historical requirement dispositions, issue disposition, cap outcome and remaining conditional risk. Do not paste full CI logs. Retain enough evidence for the next task without requiring unrelated archived task bodies.
