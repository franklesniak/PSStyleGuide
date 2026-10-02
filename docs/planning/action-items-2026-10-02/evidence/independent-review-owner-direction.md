<!-- markdownlint-disable MD013 MD047 MD022 MD032 -->
# Owner direction: apply the independent plan review, then resume

An independent review of `docs/planning/action-items-2026-10-02/` is complete. Verdict: the plan is ready to continue after specific corrections. The policies (raw byte comparison of the full union, the two separate loop limits, the retirement merits review, issue ownership) are sound and were reproduced. The execution layer is disproportionate and is the thing to fix. Do the steps below in order. Treat this message as owner direction for the planning branch: record ONE consolidated planning decision (a new `D07` entry in `DECISIONS.md` that links this message) instead of a separate validate/options/rubric/scores record per item. The finding-specific decision process stays mandatory for product work, as redefined in step 3.

## Step 0: finish what is in flight, do not discard it

1. Keep every local PR 224 repair you have made (F1, F2, F3, F4, D14, D15, D16, D17). Finish the two released full aggregate passes on the frozen 71-path candidate. If they pass, commit through the normal hook, push `codex/shared-governance` without force, update the stale PR 224 body, and start round 2 with the normal Copilot Balanced request then the single `@codex review` trigger. If a pass fails, record the failure in the A02 journal (step 2) and repair; do not open a new decision record for a fixture or setup defect.
2. Keep all counters exactly as they are: PR 224 stays at round 1/80 until round 2 is requested, its first-request clock and 2026-10-10 deadline are unchanged, and A02's transfer count carries into A02a below. Nothing in this message resets a budget.
3. Post no further decision-mirror comments on PR 224. From now on, each resolved review thread gets one reply of at most three lines plus a link to the decision file at a planning commit; the PR body carries the decision summary itself.
4. Do not edit product files or post to GitHub as part of steps 1 through 6. The only product activity until step 7 is the PR 224 round-2 work in item 1.

## Step 1: fix the entry file

- `docs/planning/action-items-2026-10-02.md` says product execution has not started. It has: A02 is active and PR 224 exists. Replace that sentence with the actual state and a pointer to STATUS.

## Step 2: restructure STATUS.md into a tracker plus per-task journals

Measured: STATUS.md is 71 KB, 192 lines, 81 paragraphs averaging 878 characters; 58 paragraphs narrate A02/PR 224; 25 planning commits added 170 lines in about 7.5 hours; cold start reads 114 KB before any task result. This violates the plan's own D04 ("do not create a new receipt for every command") and the README's "small disk record".

1. Create `results/<TASK>/journal.md` for every task that has narrative in STATUS (A00 through A15). Move every chronology paragraph into the journal of the task it describes, verbatim, in order. Journals are append-only history and are never required reading at restart.
2. Rewrite STATUS.md to at most 16 KB with exactly these parts:
   - A five-line header: tracker purpose, restart rule ("read this table, README, LOOP-POLICY, your task file, your task's RESULT; open a journal only when resuming that task"), state vocabulary, and the planning head.
   - One table, one row per task, columns: ID, outcome, state, owner/worker, repository and branch, pinned head/base, PR number, round used/80 and deadline UTC, transfers used/cap, latest evidence link, one next action.
   - A "Local configuration and in-flight native operations" section of at most 2 KB: worktree paths, runtime locations, the pending native operation per task if any, and pending owner questions as one line each. Move the local resume-file contents here only by reference.
   - A "Final results" list with one link per completed task.
3. State vocabulary becomes: pending, active, validating, waiting_external, waiting_human, complete, verified, conditional-no-trigger, superseded, convergence-blocked. Use `verified` only after an independent reader confirms the completion predicate on the final inputs. Use `superseded` for outcomes replaced on the merits (what the A00 ledger calls "replaced").
4. Add a size check to `verify-plan.py`: fail if STATUS.md exceeds 16,384 bytes.

## Step 3: add a materiality rule to DECISION-PROCESS.md

Measured: 51 result documents contain 58 option score tables; D15, D16, and D17 are full seven-step records about the private SelfTest fixture's materialization, a .NET hashing API choice, and a FIFO probe in a test helper. Insert this rule after step 1 of the process:

- Full seven-step process: a finding that changes product behavior, security properties, policy text, a public interface or contract, a settings proposal, or any reviewer finding on product code.
- Short note (at most five lines: what failed, root cause, fix, test, link): a test-fixture, scratch-setup, formatting, lint, environment, or tooling-availability defect that does not change production code or guide text.
- One canonical record per finding, stored in the owning task's results folder. Duplicate reports link to it. PR replies are a link plus at most three lines.
- Drop the post-decision "guide-contract audits" unless a decision changes guide or instruction text.
- Do not repeat the model-route attestation ("requested X, effective unknown") in every document; it is recorded once in ROUTING-AND-PARALLELISM.md.
- The coordinator samples worker hashes and score totals instead of re-verifying every one; the independent final-quality reader covers integrity at the PR level.
- Two full pre-commit passes are required only where an issue's own acceptance criteria require them (PS #175). Elsewhere one pass on the final bytes is sufficient.

## Step 4: LOOP-POLICY.md additions

1. At-limit owner decision. Append to "What happens at a limit": when a PR reaches round 80 or its 8-day deadline, the coordinator records a dated owner decision with exactly one value: `extend once by N days` (N stated), `accept at limit`, or `close`. Waiting on the owner's own pending authority is a valid reason to request an extension. There is no silent extension. The rounds, clock, and transfers are not reset by an extension.
2. Exception classes. In "Exact byte comparison and necessary exceptions", define four pre-approved classes that still require a per-path row in the owning result and in A18, but one decision each rather than one decision per file:
   - repository identity strings (owner/repo slug, clone URL, product name, copyright holders);
   - language-scoped file names (`powershell.instructions.md` versus `terraform.instructions.md` and their references);
   - normative guide content and its generated derivatives;
   - metadata lines (`Version`, `Last Updated`, `.NOTES` versions) in a file that no convergence PR has touched.
   Add the rule: when a convergence PR touches a shared file in both repositories, synchronize its metadata lines so the file converges; do not preserve stale dates as "history" on a file you are editing anyway. This supersedes the preservation reading of D-A02-01 for touched files only.
3. Review replies. Add: one reply per thread per round, at most three lines plus a link; the PR body carries the decision summary; planning-branch links are supporting evidence, not the record of truth, because that branch is never merged.

## Step 5: task structure, ownership, and dependencies

Measured: A03, A05, A06, A07, and A08 all depend on A02; A02 owns 19 paths including six protected files and the instruction validator; PATH-INVENTORY assigns `Test-AgentInstructions.ps1` and its SelfTest to A06 while PR 224 adds 748 and 366 lines to them; the validator is the most divergent file in the union (11,090 differing lines, 22 shared function names, none byte-identical); ten outcomes are effectively serial behind A02.

1. Split A02:
   - A02 keeps its ID and becomes "A02: non-protected shared governance" with exactly the PR 224 scope. Its transfer count carries over unchanged.
   - Add `A20: protected instruction files` (the six-file protected-v2 request, plus A08's root CLAUDE.md protocol repair if the owner approves it). Dependencies: A02 merged, plus the explicit owner authority. Cap 8.
   - Add `A21: instruction validator, SelfTest, and classification manifest convergence`. Dependencies: A02 merged; coordinate with A03 on the classifier and with A06 on nothing else. Cap 12. First action of A21: decide once, with one finding decision, which repository's validator is the base implementation; do not port by region.
   - Remove `Test-AgentInstructions.ps1` and `Test-AgentInstructions.SelfTest.ps1` from A06's and A02's path ownership; assign both, and `.github/document-metadata-classification.json`, `Classify-InstructionMaintenance.mjs`, and its test, to A21 after PR 224 merges. Note for A21: TF's classifier lists `Test-AgentInstructions.SelfTest.ps1`, a file TF does not have.
2. After PR 224 merges, move these paths from A02 to A07: `.github/workflows/Invoke-MarkdownLint.ps1`, `.github/workflows/MARKDOWN-LINTING-IMPLEMENTATION.md`, `.github/workflows/ci-toolchain.json`, `.github/workflows/npm-risk-exceptions.json`.
3. Dependencies: A07 depends on A00 and A01 only (it must not touch the two PR 224 paths above until that PR merges). A08 depends on A00 and A01 only; its protected root-file proposal moves to A20.
4. Fold A10 and A11 into A18: set both to `superseded` with the note "no defect found; residual verification is an A18 checklist item", and add their verification items to A18's validation section. Keep their results as evidence.
5. Coordinator role: the worker that owns a PR drafts the decisions and implements inside that PR; the coordinator reviews at round boundaries and owns native operations, STATUS, and counters. Stop the publish-each-decision-before-each-edit rule.
6. Update `task-index.json`, the README task table, PATH-INVENTORY, `evidence/path-ownership.json`, and `verify-plan.py` (task count and ID set) for A20 and A21. Keep every task file's existing sections.

## Step 6: historical ledger, routes, and original-task files

Measured: `results/A00/dispositions.json` uses only `unverified` (339) and `replaced` (63); `historical-map.json` has 124 IDs with more than one owner and 402 per-ID "revisited route" fields; the RETAIN audit reason is the same sentence on every row. Of the 18 original task families, 13 delivered their product outcome through native merged PRs, 3 were delivered and then retired or superseded on the merits, and 2 were never done (the convergence sweep and final acceptance). The review did not repeat completed product work and dropped no unfinished work.

1. In the ledger, add `delivered_via` (native PR or commit) and widen `present_disposition` to: `delivered-historically`, `delivered-then-retired`, `superseded`, `conditional-no-trigger`, `pending`, `unverified-administrative-leaf`. Populate `delivered_via` from this family table, then verify each PR natively before writing it:
   - 1–9 metadata policy: PS PR 180. 10–18 review-loop correction: PR 182 on the planning branch (controller now inactive, superseded by LOOP-POLICY). 19–40 PR 78 port: PS PR 174 repaired by PR 180; TF partly PRs 49 and 51; three-repository fixed point still A18. 41–68 PR-body identity: PS PRs 186, 188–196, then retired by PR 218. 69–97 generator cycles: PS PRs 197, 198, 199, 202; TF PRs 49, 51. 98–125 workflow isolation: PS PRs 200, 210, 212; TF PR 60; parts retired by PR 218. 126–154 supply freeze: PS PRs 203, 205; TF PRs 53, 55; made optional by PR 218. 155–182 review-loop command: PS PR 206; TF PR 57. 183–209 T1A validator: TF PR 58, PS PR 208, then retired by PRs 63 and 221. 210–222 inventory/U1: PS PRs 212, 217; global sweep never ran. 223–260 P1B writer: superseded by PRs 221 and 63; IDs 226, 229, 230 stay with A12/A13. 261–287: PS PR 222. 288–305: TF PR 64. 306–351: PS PRs 219, 220; TF PR 62. 352–378: PS PR 223; TF PR 65; issue 213 open. 379–390: D92/D93 comments, conditional. 391–401: template, A18. 402: not done.
2. Give every original ID exactly one `remaining_owner` (primary); record collaborators elsewhere if needed. Keep the 26 historical credits untouched.
3. Remove the per-ID `model`, `reasoning`, and `routing_reason` fields from `historical-map.json` and any HISTORICAL-MAP.md columns. In one scripted pass over `original-tasks/*.md`, replace the "Revisited route" bullet with a "Current disposition" bullet pulled from the ledger. Do not change any byte inside the ORIGINAL CONTRACT markers; rerun the body-hash check.
4. Delete each task's `original-dispositions.json` copy (A04, A06, A08 wrapper, A09, A10, A11, A14) after folding any owner-specific notes into the ledger. The A00 ledger is the single ledger; owners update rows in it.
5. Update `verify-plan.py` for the new fields and vocabulary, then run it. Lint the changed Markdown. Commit and push the planning branch normally. Add a short "Corrections from the independent review" section to REVIEW.md that links the `D07` entry.

## Step 7: execution prompt and routing

1. In `coding-agent-loop.md`, remove the machine-specific paths and the dependency on the installed routing skill from the fenced prompt; point to the "Local configuration" section of STATUS instead, and keep the routing instruction only in the form "if the model-routing skill is available, use it; otherwise use the no-routing wrapper". Add the restart reading budget from step 2.
2. Routing is advisory. Keep three tiers. Raise A21 (validator) and A19 (final reconciliation) to the highest tier. Keep A01 and the census parts of A19 light. State once in ROUTING-AND-PARALLELISM.md that effective settings are not exposed; do not repeat it per task.

## Step 8: open product decisions, and what to prepare while waiting

1. A03-D1 (maintenance approval). The gap is real: the accepted-base job prints MAINTENANCE_REQUIRED and exits 0, and the Codex P1 finding on PR 224 shows a manifest change skips the accepted-base table comparison. The review scored an option the design did not: an owner-label gate. In the accepted-base job, when classification is `maintenance_required`, fail unless the PR carries an owner-applied label read from the event payload (no token needed); add `labeled` and `unlabeled` to the pull_request_target types; make that job a required check in the A12 ruleset; apply the same to TF after it lands in PS. Prepare the exact patch and its classifier/workflow-policy tests read-only now; implement only after the owner decision below.
2. PR 221 / TF PR 63 and the closures of #147, #156, #151, #209, #181 stand. Restore nothing, reopen nothing. Record one reopen trigger in the A06 result: a real automatic-publication or archive-promotion consumer. A19 must read TF #22 and TF PR 63 natively; the review could not reach TF's API.
3. Start A07 and A08 workers now under the new dependencies. Continue A15 read-only. A12 and A14 stay as accepted.
4. Resume PR 224 as A02 round 2 per step 0.

## Owner decisions [fill in before sending; delete lines you are not deciding now]

- A03-D1: [ ] adopt the owner-label gate (option L) / [ ] accept the procedural boundary (option P) / [ ] other: ___
- A02 protected-v2 six-file instruction request: [ ] approved as frozen / [ ] declined / [ ] revise: ___
- A05 two-guide `yaml.instructions.md` immutable-acquisition patch: [ ] approved / [ ] declined
- A08 two-CLAUDE root protocol proposal (now A20): [ ] approved / [ ] declined
- A13 PS ruleset `ps-style-guide-main-protection` as proposed by A12, with the bounded restoration and ordinary-PR validation instead of a direct-push drill: [ ] approved / [ ] declined
- PR 224 if it reaches its 2026-10-10 deadline while waiting on the above: [ ] extend once by ___ days / [ ] accept at limit / [ ] close

Report back with: the planning commit that lands steps 1–7, the new STATUS.md size, the verify-plan result, PR 224's round-2 state, and the exact owner decisions you are still waiting on.