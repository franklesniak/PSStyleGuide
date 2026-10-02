<!-- markdownlint-disable MD013 -->
# Execute the paired repository plan

Use this prompt when the owner instructs you to execute the plan. Preparing or reviewing it does not itself authorize product execution.

```markdown
Execute the plan in `docs/planning/action-items-2026-10-02/README.md`. Work from PSStyleGuide branch `planning-CRT-PR-852` and keep planning progress there. Never merge that branch into main. Use separate product worktrees from each repository's current native main. Find checkout and runtime locations in STATUS under Local configuration. The GitHub repositories are `franklesniak/PSStyleGuide` and `franklesniak/TerraformStyleGuide`.

Read `docs/planning/action-items-2026-10-02/STATUS.md` first, including after every restart or context compaction. Then read README, LOOP-POLICY, your task file and your task's RESULT. STATUS is bounded to 16 KB. Open a journal only when resuming that task; journals are never mandatory cold-start reading. Read only the original contracts and evidence needed for the next action. Use disk progress and authenticated native state; do not infer completion from chat memory or old TEMP completed lists.

Work every live issue and every applicable original requirement to a truthful outcome. Reuse verified historical implementations, reviews and merges. Do not replay administrative leaves or restore retired machinery solely because an old task names it. Use RETIREMENT-REVIEW to preserve useful controls and address actual losses. Keep retired, implemented, conditional, unverified and blocked results distinct.

Follow DECISION-PROCESS.md: complete the seven-step process for material product changes and product-code review findings. Use a note of at most five lines for fixture/setup/lint/environment defects that change neither production code nor guide text. Keep one canonical record; use one reply per thread per round, at most three lines plus a link. The PR body carries the decision summary. One final-byte full pre-commit pass suffices unless the issue explicitly requires two, including PS175.

Routing is advisory: if the model-routing skill is available, use it; otherwise use the no-routing wrapper. Keep one writer per worktree and outcome. No worker spawns descendants. The PR-owning worker drafts decisions and implements after selection; the coordinator reviews at round boundaries and owns integration, native operations, STATUS and counters. Do not require decision publication before each edit.

Run independent research, non-overlapping tasks and immutable-input reviews in parallel where useful. Enforce the task dependency graph and path ownership; serialize shared workflow/lockfile/generated-output edits and product merges. Never implement both repositories' side of one convergence outcome simultaneously. During a review wait, continue other safe work.

For each actual change, implement a focused source-repository PR, validate it, run the Copilot-and-Codex review loop, obtain independent final quality, merge through normal current gates, and verify landed behavior. Diff the accepted bytes against the other repository. If an applicable common difference remains, create a focused peer repair PR and repeat the lifecycle. Compare back after the peer merge; propagate useful review-driven changes until the outcome converges or reaches its cap.

Each PR review stops at the first of: both reviewers clean on the same current input, 80 rounds, or 8 elapsed days from its first request. Each work item has a separate directional repository-transfer cap: 8 for narrow work, 12 for coupled work, 16 only for justified large scope. Initial source implementation is transfer0; first peer repair is1; reverse repair is2. Neither counter resets after a new head, worker, PR replacement or restart. Reserve the last two transfers for final repair/alignment. Follow the exact counter, pending-request, timeout and at-limit rules in LOOP-POLICY.md.

Prefer Copilot Balanced through the supported GitHub Reviewers UI as AGENTS.md requires. Capture baselines, submit once, confirm the native request, and record the observed effort. Use the documented CLI/REST fallback if the UI cannot select Balanced; Lite is acceptable and does not justify a second request. Attribute both reviewers' results to exact inputs. Never duplicate a pending or ambiguously accepted request. Serialize request sets across changed inputs. Preserve genuine failed-service and substitute-review outcomes without relabeling them clean.

On an exhausted limit, stop optional iteration and record the dated owner choice: extend once by a stated N days, accept at limit, or close. Do not silently extend or reset counters. Merge final reviewed changes only when independent quality and required current gates permit it. If a material defect, required approval, failed check or unjustified byte difference remains, record the concrete blocker and next bounded decision. Never call that convergence. Do not create a replacement PR or new task solely to reset a budget.

A merge is on-plan only when the task names the outcome, scope and actual candidate match, applicable checks and review pass, no material finding remains, and no control is bypassed. Do not request redundant permission for routine in-scope actions. Preserve actual protected-file, settings and Terraform Gate A/B authority boundaries; a generated plan cannot invent a missing grant. Prepare concrete readiness before requesting the exact missing decision. Continue independent work while waiting.

Before a meaningful wait, worker handoff or restart, update STATUS with actual inputs, changed paths, evidence, pending native operations, PR round/deadline, transfer count and one next action. Reconcile a possibly accepted write before retrying it. After a relevant input changes, reopen affected completed conditional results and preserve old evidence and counters. Do not rerun unrelated checks.

Complete A18 only after a full native-main tracked-tree union comparison plus original required-capability checks. Compare actual blob bytes and modes. Verify every necessary language/repository exception at exact paths/regions; do not excuse common algorithms or tests by repository name. Preserve truthful historical facts. Check both refs again so the accepted pair is current. Finish A19 with a fresh issue census and explicit original-requirement dispositions. Report unresolved conditional risks honestly; do not force-close them or claim all402 original implementations were delivered.
```

## Current supporting documents

- [Plan entry](action-items-2026-10-02/README.md)
- [Progress and restart record](action-items-2026-10-02/STATUS.md)
- [Two-loop policy](action-items-2026-10-02/LOOP-POLICY.md)
- [Model routing and parallel ownership](action-items-2026-10-02/ROUTING-AND-PARALLELISM.md)
- [Finding decision process](action-items-2026-10-02/DECISION-PROCESS.md)
- [Historical completion reconciliation](action-items-2026-10-02/COMPLETION-REVIEW.md)
- [Retirement merits](action-items-2026-10-02/RETIREMENT-REVIEW.md)

The earlier numeric-state controller, condensed-plan prompts and old completion record are not active entry points for this plan. Do not feed A00–A21 state to the old controller/schema. Use this policy directly unless a later explicit controller migration is validated. Preserve pre-existing local edits and unrelated files. Never commit credentials, browser state or temporary research receipts.
