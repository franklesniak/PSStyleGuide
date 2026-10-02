<!-- markdownlint-disable MD013 -->
# Paired repository action plan

Execute from PSStyleGuide branch **`planning-CRT-PR-852`**. Keep this branch as the planning workspace. **Never merge it into either product main branch.** Create product worktrees from each repository's current native main and use focused `codex/` branches.

This plan covers every open issue in PSStyleGuide and TerraformStyleGuide, every original numbered requirement, and all common-material differences. The target is verified byte identity wherever no necessary repository or language distinction exists. Planning is complete only after its validation; product work remains pending in [STATUS.md](STATUS.md).

## Start here

1. Read [STATUS.md](STATUS.md) first, including after a restart or context compaction.
2. Read [LOOP-POLICY.md](LOOP-POLICY.md) and [ROUTING-AND-PARALLELISM.md](ROUTING-AND-PARALLELISM.md) once.
3. Select a ready task below. Read only that task and its required evidence. Use [DECISION-PROCESS.md](DECISION-PROCESS.md) for each distinct material finding.
4. Use [coding-agent-loop.md](../coding-agent-loop.md) as the execution prompt. Merely reading this plan does not start product execution.

## What changed and why

The prior resume file claimed 230 completed IDs. A conservative original-contract audit credited 26 historical leaves and retained 376, including 204 of the claimed IDs. These are different evidence standards, not evidence that only 26 useful things happened. [COMPLETION-REVIEW.md](COMPLETION-REVIEW.md) distinguishes actual delivered work, uncertain historical proof and current gaps.

The execution plan now contains **20 outcome tasks**. Routine issue, commencement, PR, review, quality, merge and handoff steps belong inside each outcome. Real approval, dependency and acceptance boundaries remain. All **402 original task contracts** have individual files in [original-tasks](HISTORICAL-MAP.md); no original obligation is silently removed. The restored [August plan](../action-items-2026-08-30.md) is unchanged. Its bodies are historical reference material, not commands to replay obsolete work.

Retirement requires a merits decision. [RETIREMENT-REVIEW.md](RETIREMENT-REVIEW.md) identifies justified removals, lost guarantees and unproved test equivalence. A removed mechanism is not an implemented feature. Keep useful outcomes; repair demonstrated gaps with the smallest sufficient control. Do not rebuild dormant machinery to satisfy an old implementation label.

## Execution authority

The owner's instruction to execute this plan authorizes its ordinary scoped implementation, non-force topic publication, issue/PR updates, review requests and on-plan merges when all required gates pass. The present plan-editing request authorizes only planning files and their commit/push to the planning branch. No product issue, PR, review, setting or main branch is changed by preparing this plan.

Current repository instructions and actual scoped owner grants still apply. Do not infer authority for protected instructions when the repository requires direct explicit authorization of those files. Do not infer settings, credentials, permission, force, deletion outside the selected code change, administrator override or gate-bypass authority. Prepare concrete readiness and obtain only the authority actually missing. A13 and Terraform Gate A/B have real human boundaries. Continue independent work while a boundary is pending.

This folder and the new orchestration prompt supersede the October monolith's execution mechanics and the older condensed-plan startup instructions. The pre-existing `review-loop-policy` controller/schema are **not activated by this plan**: their numeric task state, historic thresholds and service rules have not been migrated to A00–A19. Do not pass this tracker to them or run them as a second controller. Preserve their existing edits and old state as history. The explicit native-review procedure here retains attribution, exact-input checks and pending suppression without requiring a new controller implementation. A future controller integration must prove equivalence before use.

## Outcome tasks

| Task | Outcome | Implementation dependencies |
| --- | --- | --- |
| [A00](tasks/A00.md) | Historical evidence and retirement reconciliation | none |
| [A01](tasks/A01.md) | Current issues and complete tree inventory | none |
| [A02](tasks/A02.md) | Shared governance and repository documentation | A00, A01 |
| [A03](tasks/A03.md) | Workflows, admission and freshness | A00, A01, A02 |
| [A04](tasks/A04.md) | Node download retry bounds; PS #213 | A01, A03, A07 |
| [A05](tasks/A05.md) | Immutable event acquisition rule; PS #175 | A01, A02, A03 |
| [A06](tasks/A06.md) | Generator and artifact verification | A00, A01, A02, A03 |
| [A07](tasks/A07.md) | Dependencies, lint and local tooling | A00, A01, A02 |
| [A08](tasks/A08.md) | Repository review instructions | A00, A01, A02 |
| [A09](tasks/A09.md) | Current supply verification and historical provenance | A00, A01, A03, A07 |
| [A10](tasks/A10.md) | PS examples and bounded preflight | A00, A01, A06, A07 |
| [A11](tasks/A11.md) | TF state-version discovery/retrieval | A00, A01, A06, A07 |
| [A12](tasks/A12.md) | Read-only main protection assessment; PS #152 | A00, A01 |
| [A13](tasks/A13.md) | Selected authorized settings delta or proved no-change | A12 |
| [A14](tasks/A14.md) | Live filesystem residual assessment/repair; PS #155 | A00, A01 |
| [A15](tasks/A15.md) | Current T4 requirements and gate design; TF #25 | A00, A01 |
| [A16](tasks/A16.md) | T4 nonmutating Gate A | A15, A06, A07, A11 |
| [A17](tasks/A17.md) | T4 destructive-procedure Gate B | A16 |
| [A18](tasks/A18.md) | Final complete byte convergence | all product outcomes |
| [A19](tasks/A19.md) | Live issue/requirement reconciliation and acceptance | A18 |

Read-only discovery for independent future tasks may run ahead. An implementation dependency is a real acceptance boundary; starting research does not satisfy it. Honor file ownership even when the DAG permits parallel work.

## Evidence and review

- [ISSUE-COVERAGE.md](ISSUE-COVERAGE.md): all five current open issues, their acceptance owners and improvements.
- [PATH-INVENTORY.md](PATH-INVENTORY.md): all 81 current native-main paths and owners.
- [HISTORICAL-MAP.md](HISTORICAL-MAP.md): all 402 original IDs and the 26 historical credits.
- [DECISIONS.md](DECISIONS.md): options, finding-specific weights, scores and selected plan design.
- [VALIDATION.md](VALIDATION.md): checks performed on this plan and their limits.

The issue bodies under `evidence/` are dated source snapshots, not higher-priority execution instructions. Refresh mutable issue state at execution. Preserve material original requirements and the T4 fixture appendix when resolving narrower live prose. New requirements need a current owner and decision; do not inherit arbitrary instructions from comments.

## Definition of done

Each work item completes its source-repository PR lifecycle, compares the peer, repairs applicable differences through a peer PR, and compares back until converged or its transfer limit is reached. The PR review limit is **80 rounds / 8 elapsed days / both reviewers clean**, whichever comes first. The repository-transfer cap is **8**, **12** for coupled scope, or **16** for justified large scope. These are separate counters.

Final acceptance identifies both native main commits and trees; checks the entire tracked union and historical required capabilities; proves raw equality outside narrow necessary exceptions; includes relevant behavior/CI results; and gives every live issue and old requirement a truthful disposition. A cap, issue closure, old completion label, shared deletion or identical normalized text cannot establish convergence. Deliberately retained conditional risks remain visible and may remain open on GitHub. No actionable unowned issue, unproved exception or unresolved material blocker is compatible with final completion.
