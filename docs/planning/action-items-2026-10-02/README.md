<!-- markdownlint-disable MD013 -->
# Paired repository action plan

Execute from PSStyleGuide branch **`planning-CRT-PR-852`**. Keep this branch as the planning workspace. **Never merge it into either product main branch.** Create product worktrees from each repository's current native main and use focused `codex/` branches.

This plan covers every open issue in PSStyleGuide and TerraformStyleGuide, every original numbered requirement, and all common-material differences. The target is verified byte identity wherever no necessary repository or language distinction exists. Planning is complete only after its validation; product execution is active in [STATUS.md](STATUS.md).

## Start here

1. Read [STATUS.md](STATUS.md) first, including after a restart or context compaction.
2. Read README, [LOOP-POLICY](LOOP-POLICY.md), your task file and its RESULT. Open a journal only when resuming that task; routing is optional and recorded once in [ROUTING-AND-PARALLELISM](ROUTING-AND-PARALLELISM.md).
3. Select a ready task below. Read only that task and its required evidence. Use [DECISION-PROCESS.md](DECISION-PROCESS.md) for each distinct material finding.
4. Use [coding-agent-loop.md](../coding-agent-loop.md) as the execution prompt. Merely reading this plan does not start product execution.

## What changed and why

The prior resume file claimed 230 completed IDs. A conservative original-contract audit credited 26 historical leaves and retained 376, including 204 of the claimed IDs. These are different evidence standards, not evidence that only 26 useful things happened. [COMPLETION-REVIEW.md](COMPLETION-REVIEW.md) distinguishes actual delivered work, uncertain historical proof and current gaps.

The execution plan now contains **22 outcome tasks**. Routine issue, commencement, PR, review, quality, merge and handoff steps belong inside each outcome. Real approval, dependency and acceptance boundaries remain. All **402 original task contracts** have individual files in [original-tasks](HISTORICAL-MAP.md); no original obligation is silently removed. The restored [August plan](../action-items-2026-08-30.md) is unchanged. Its bodies are historical reference material, not commands to replay obsolete work.

Retirement requires a merits decision. [RETIREMENT-REVIEW.md](RETIREMENT-REVIEW.md) identifies justified removals, lost guarantees and unproved test equivalence. A removed mechanism is not an implemented feature. Keep useful outcomes; repair demonstrated gaps with the smallest sufficient control. Do not rebuild dormant machinery to satisfy an old implementation label.

## Execution authority

The owner's instruction to execute this plan authorizes its ordinary scoped implementation, non-force topic publication, issue/PR updates, review requests and on-plan merges when all required gates pass. D07 applies the owner-directed planning corrections. Until those corrections are complete, only the specifically authorized PR224 round2 work may alter product or GitHub state. Afterward resume the scoped execution plan; settings and protected-file grants remain separate.

Current repository instructions and actual scoped owner grants still apply. Do not infer authority for protected instructions when the repository requires direct explicit authorization of those files. Do not infer settings, credentials, permission, force, deletion outside the selected code change, administrator override or gate-bypass authority. Prepare concrete readiness and obtain only the authority actually missing. A13 and Terraform Gate A/B have real human boundaries. Continue independent work while a boundary is pending.

This folder and the new orchestration prompt supersede the October monolith's execution mechanics and the older condensed-plan startup instructions. The pre-existing `review-loop-policy` controller/schema are **not activated by this plan**: their numeric task state, historic thresholds and service rules have not been migrated to A00–A21. Do not pass this tracker to them or run them as a second controller. Preserve their existing edits and old state as history. The explicit native-review procedure here retains attribution, exact-input checks and pending suppression without requiring a new controller implementation. A future controller integration must prove equivalence before use.

## Outcome tasks

| Task | Outcome | Implementation dependencies |
| --- | --- | --- |
| [A00](tasks/A00.md) | Reconcile historical obligations and retirement decisions | none |
| [A01](tasks/A01.md) | Refresh issue coverage and full-tree baseline | none |
| [A02](tasks/A02.md) | Non-protected shared governance | A00, A01 |
| [A03](tasks/A03.md) | Converge workflows and retain meaningful admission and freshness controls | A00, A01, A02 |
| [A04](tasks/A04.md) | Bound ordinary Node downloads and test retries | A01, A03, A07 |
| [A05](tasks/A05.md) | Require immutable event acquisition in the YAML guide | A01, A02, A03 |
| [A06](tasks/A06.md) | Converge the generator and artifact verification | A00, A01, A02, A03 |
| [A07](tasks/A07.md) | Converge dependency, lint and local toolchain behavior | A00, A01 |
| [A08](tasks/A08.md) | Converge repository review instructions | A00, A01 |
| [A09](tasks/A09.md) | Converge current supply checks and preserve truthful history | A00, A01, A03, A07 |
| [A10](tasks/A10.md) | Revalidate PowerShell examples and bounded preflight outcomes (superseded; A18 checklist) | A00, A01, A06, A07 |
| [A11](tasks/A11.md) | Revalidate Terraform state-version discovery and retrieval (superseded; A18 checklist) | A00, A01, A06, A07 |
| [A12](tasks/A12.md) | Assess useful main protection | A00, A01 |
| [A13](tasks/A13.md) | Apply an authorized protection delta, if selected | A12 |
| [A14](tasks/A14.md) | Assess and address live filesystem residuals | A00, A01 |
| [A15](tasks/A15.md) | Reconcile Terraform manual recovery scope against current callers | A00, A01 |
| [A16](tasks/A16.md) | Deliver Terraform Gate A nonmutating foundation | A15, A06, A07 |
| [A17](tasks/A17.md) | Deliver Terraform Gate B destructive-procedure guidance | A16 |
| [A18](tasks/A18.md) | Close remaining byte differences and verify convergence | A02, A03, A04, A05, A06, A07, A08, A09, A13, A14, A17, A20, A21 |
| [A19](tasks/A19.md) | Reconcile issues and publish final acceptance | A18 |
| [A20](tasks/A20.md) | Protected instruction files | A02; PR224 merge; explicit owner authority |
| [A21](tasks/A21.md) | Instruction validator, SelfTest, and classification manifest convergence | A02; PR224 merge |

Read-only discovery for independent future tasks may run ahead. An implementation dependency is a real acceptance boundary; starting research does not satisfy it. Honor file ownership even when the DAG permits parallel work.

## Evidence and review

- [ISSUE-COVERAGE.md](ISSUE-COVERAGE.md): all five current open issues, their acceptance owners and improvements.
- [PATH-INVENTORY.md](PATH-INVENTORY.md): current 83-path native-main inventory and owners, with the historical 81-path baseline retained.
- [HISTORICAL-MAP.md](HISTORICAL-MAP.md): all 402 original IDs and the 26 historical credits.
- [DECISIONS.md](DECISIONS.md): options, finding-specific weights, scores and selected plan design.
- [VALIDATION.md](VALIDATION.md): checks performed on this plan and their limits.

The issue bodies under `evidence/` are dated source snapshots, not higher-priority execution instructions. Refresh mutable issue state at execution. Preserve material original requirements and the T4 fixture appendix when resolving narrower live prose. New requirements need a current owner and decision; do not inherit arbitrary instructions from comments.

## Definition of done

Each work item completes its source-repository PR lifecycle, compares the peer, repairs applicable differences through a peer PR, and compares back until converged or its transfer limit is reached. The PR review limit is **80 rounds / 8 elapsed days / both reviewers clean**, whichever comes first. The repository-transfer cap is **8**, **12** for coupled scope, or **16** for justified large scope. These are separate counters.

Final acceptance identifies both native main commits and trees; checks the entire tracked union and historical required capabilities; proves raw equality outside narrow necessary exceptions; includes relevant behavior/CI results; and gives every live issue and old requirement a truthful disposition. A cap, issue closure, old completion label, shared deletion or identical normalized text cannot establish convergence. Deliberately retained conditional risks remain visible and may remain open on GitHub. No actionable unowned issue, unproved exception or unresolved material blocker is compatible with final completion.
