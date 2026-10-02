<!-- markdownlint-disable MD013 -->
# Plan design decisions

This is the decision record for the October 2 plan revision. The work was requested on October 1, 2026, America/Chicago. The date in the folder preserves the existing plan identity. These decisions change planning and execution instructions; they do not certify product work or authorize external settings changes.

Each score is 1 (fails the criterion), 2 (major gaps), 3 (adequate with limits), 4 (strong), or 5 (strongest fit). The weighted total is `sum(weight * score) / 5`, out of 100. These are reasoned assessments, not measured probabilities. Totals below correct minor arithmetic errors in the preliminary chat tables. Each finding has its own criteria. Correctness and usable results outweigh churn and implementation effort.

## D01: Separate historical evidence from current execution

**Validated finding.** The old resume record lists 230 completed IDs. The conservative restoration audit accepts 26 historical leaves and retains 376, including 204 of those 230. Neither record means 376 tasks are unstarted. The October monolith is 2,895,531 bytes. The old orchestration prompt uses a different completion interpretation. [Completion review](COMPLETION-REVIEW.md) explains the evidence.

**Stakeholders.** Repository owner; PS and TF maintainers; PowerShell and Terraform authors; new contributors; implementation and orchestration agents; independent reviewers; CI and test maintainers; security engineers; documentation maintainers; downstream artifact consumers; incident responders; future auditors; the operator funding execution.

**Options.** A: retain the monolith. B: split the 376 bodies without changing execution. C: trust all 230 completed labels and remove that work. D: create current outcome tasks, preserve all 402 original contracts in individual reference files, and map every old ID to evidence and an outcome. A plus an index still has A's conflicting instructions. B plus blind completion carry-forward has C's evidence problem. D includes splitting, indexing and evidence reuse without those defects.

**Rubric.** Evidence accuracy 35%: distinguish executed actions, unverified claims, retirement, and current acceptance. Requirement preservation 25%: no lost original obligation or live issue. Executor usability 25%: bounded reading and unambiguous current work. Restart durability 10%: recover progress from a small disk record. Migration effort 5%: avoid unnecessary churn.

| Option | Accuracy | Preservation | Usability | Durability | Effort | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 2 | 5 | 1 | 2 | 5 | 53 |
| B | 2 | 5 | 3 | 4 | 4 | 66 |
| C | 1 | 1 | 4 | 3 | 4 | 42 |
| D | 5 | 5 | 5 | 5 | 3 | 98 |

**Selected action (controlled English).** Use D. Keep the August source unchanged. Create a reference file for each original task. Read only the active outcome task and its needed references. Keep historical facts separate from current acceptance. Do not repeat an old merge. Do not call a retired requirement implemented. Check each remaining product requirement in its assigned outcome.

## D02: Verify the whole tracked-tree union

**Validated finding.** Native main trees have 81 distinct paths: 9 equal, 55 different, 6 PS-only and 11 TF-only. Comparing only a chosen shared list can miss a one-sided file. Normalized text can conceal byte differences. [Inventory](PATH-INVENTORY.md) names every current path.

**Stakeholders.** Both repository maintainers; PS and TF language users; shared-tool developers; package and generated-artifact consumers; release maintainers; Windows and Linux users; security and license stewards; CI operators; documentation readers; history custodians; reviewers; future auditors.

**Options.** A: compare normalized text. B: compare a hand-selected shared list. C: compare the complete tracked-tree union, raw blobs and modes, with exact justified exceptions. D: first extract a third shared package. Hash-based comparison is a repeatable implementation of C, not an alternative to byte identity. A package may later help if a separate design proves value; it does not remove the need for C.

**Rubric.** Byte correctness 35%: detect content, mode and absence differences. Omission detection 30%: cover the full union and previously required deleted paths. Legitimate language needs 20%: permit necessary narrow differences without whole-file waivers. Repeatability 10%: name immutable inputs and reproducible results. Implementation cost 5%: avoid an extra distribution system.

| Option | Correctness | Coverage | Language needs | Repeatability | Cost | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 3 | 4 | 4 | 5 | 54 |
| B | 4 | 2 | 4 | 4 | 4 | 68 |
| C | 5 | 5 | 5 | 5 | 4 | 99 |
| D | 4 | 3 | 4 | 4 | 1 | 71 |

**Selected action (controlled English).** Use C. Compare committed bytes at named main commits. Include all tracked paths and modes. Map renamed counterparts. Give each exception an exact scope and a reason. Check the shared parts of a mixed file. Do not treat a repository name, an old difference, or equal behavior as proof of necessity. Do not treat shared absence as delivery of a required capability. Keep truthful historical facts; never alter them to make hashes equal.

## D03: Separate the PR review limit from the convergence limit

**Validated finding.** A per-input retry cap does not bound a work item that changes heads or moves between repositories. The owner clarified that each PR has a limit of **80 rounds or 8 elapsed days or both reviewers clean**, whichever occurs first. The suggested eight-cycle limit applies to repository transfers, not PR review rounds. This clarification supersedes the preliminary aggregate review-budget proposal.

**Stakeholders.** Owner; authors; Copilot and Codex review consumers; independent quality reviewers; maintainers with merge authority; downstream users; security and CI maintainers; operators resuming interrupted work; service administrators; the person paying review and execution costs.

**Options.** A: use only the 80-round/8-day PR limit. B: add eight transfers for every work item. C: add 8/12/16 transfers based on scope, reserve finalization capacity, and preserve required merge gates. D: merge unconditionally at either limit. A permits endless new PRs. D can land a known defect. Splitting a genuinely independent outcome is useful, but splitting or renaming to reset a spent budget is invalid.

**Rubric.** Safe acceptance 40%: no known material defect or failed required gate is converted to success. Bounded total work 25%: counters survive new heads, PRs and restarts. Scope fitness 20%: tightly scoped work ends promptly; coupled work has a declared larger budget. Resume clarity 10%: define the counted unit and clock. Cost control 5%: stop marginal repetition.

| Option | Acceptance | Bounded work | Scope fit | Resume clarity | Cost | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 1 | 3 | 3 | 1 | 64 |
| B | 5 | 5 | 3 | 5 | 5 | 92 |
| C | 5 | 5 | 5 | 5 | 4 | 99 |
| D | 1 | 5 | 1 | 5 | 5 | 52 |

**Selected action (controlled English).** Use C and the owner's PR limit. Count the first implementation as transfer zero. Count each later repair that moves to the other repository as one transfer. Use eight for narrow work, twelve for coupled work, and sixteen only for an approved large scope. Prefer a smaller independent outcome to a large scope. Do not reset counters. Reserve the last two transfer slots for final repair and byte alignment. Follow [the loop policy](LOOP-POLICY.md) at either limit.

## D04: Keep useful controls and combine routine administration

**Validated finding.** The old plan uses separate leaves for issue creation, commencement, publication, review, quality, merge, handoff and closure. Some preserve genuine boundaries; many repeat the same identities and records. Missing historical model-dispatch metadata also prevents some audit credit despite proved product review. The user requires a full decision process for every distinct confirmed finding; that requirement remains.

**Stakeholders.** Owner; maintainers; new contributors; coding agents and their coordinator; code reviewers; security engineers and security executives accountable for residual risk; test and CI maintainers; documentation readers; incident responders; auditors; future operators; downstream consumers; service administrators.

**Options.** A: retain every administrative step and record. B: remove all process records. C: put routine steps in one outcome lifecycle, keep useful safety and acceptance boundaries, and link to primary evidence. A plus automation still generates duplicate work. C can retain a separate record where it is an actual product artifact or an independent approval boundary.

**Rubric.** Prevention of real failures 35%: preserve controls with a concrete supported failure mode. Evidence usefulness 25%: retain enough to review, resume and diagnose. Execution usability 25%: remove duplicate work. Recovery 10%: preserve state across interruption. Migration effort 5%: avoid churn for its own sake.

| Option | Failure prevention | Evidence | Usability | Recovery | Effort | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 4 | 3 | 1 | 3 | 5 | 59 |
| B | 1 | 1 | 5 | 1 | 4 | 43 |
| C | 5 | 5 | 5 | 5 | 3 | 98 |

**Selected action (controlled English).** Use C. Keep one task record and one final result. Link to Git, GitHub and CI evidence. Do not create a new receipt for every command. Keep real test catalogs, security checks, pending-review suppression, required approvals and the user's finding decisions. Do not request new permission for an unchanged in-scope action. Do not repeat a proved historical review only to recover unavailable model metadata. Assess retired controls on their merits under [the retirement review](RETIREMENT-REVIEW.md).

## D05: Parallel scopes with task-specific model routing

**Validated finding.** The old serial slot prevents independent read-only work. Unrestricted writers can conflict in the same worktree, workflow policy or generated outputs. The runtime exposes exact model and reasoning overrides; it does not expose pricing or post-spawn effective settings in this session.

**Stakeholders.** Task authors; coordinator and subagents; PS and TF maintainers; contributors using the same checkout; integration and release owners; CI operators; independent reviewers; security specialists; documentation editors; restart operators; account and cost owner.

**Options.** A: one model, fully serial work. B: unrestricted parallel writers. C: independent scopes, one writer per worktree, serialized merges and per-task routing. C includes parallel research, tests and review where inputs are fixed; it serializes overlapping integration work. A can remain the fallback when no independent scope exists.

**Rubric.** Integration correctness 35%: no overlapping ownership or stale acceptance. Reasoning adequacy 30%: match difficulty and uncertainty. Useful throughput 20%: parallelize independent work rather than creating duplicate reviews. Recovery clarity 10%: durable handoffs and clear ownership. Operating cost 5%: select the lightest verified model that meets the quality bar; exact cost optimality is unverified.

| Option | Integration | Reasoning | Throughput | Recovery | Cost | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 3 | 1 | 4 | 2 | 67 |
| B | 1 | 3 | 5 | 1 | 3 | 50 |
| C | 5 | 5 | 4 | 5 | 4 | 95 |

**Selected action (controlled English).** Use C. Give each worker one bounded scope and a separate worktree for edits. Keep one integration owner. Select an available model and effort before dispatch. Verify effective settings when the runtime exposes them. Record unknown settings as unknown. Follow [routing and parallel work](ROUTING-AND-PARALLELISM.md). Do not spawn descendants from a routed worker.

## D06: Preserve Terraform #25 safety while replacing stale execution assumptions

**Validated finding.** [TF #25](https://github.com/franklesniak/TerraformStyleGuide/issues/25) specifies a nonmutating Gate A and destructive-procedure Gate B, an exact sixteen-file set and old T1/T1A/T1B dependencies. Its current test caller is `Test-StateRecoveryExamples.mjs`; the issue names `.sh`. A closed old dependency does not prove a retired capability exists. HashiCorp describes state push as exceptional and retains lineage/serial checks; state recovery can lose data or expose secrets.

**Stakeholders.** Terraform operators; cloud and backend administrators; on-call and disaster-recovery staff; infrastructure owners; data owners; security and privacy engineers; independent operational peers; Windows PowerShell 5.1, PowerShell 7 and Bash users; guide authors; test maintainers; CI operators; maintainers; future readers copying examples; the owner approving scope.

**Options.** A: implement the historical sixteen-file contract literally. B: drop the helpers, gates and safety constraints wholesale. C: map every acceptance requirement to current supported callers, reconcile stale locators and dependencies, then deliver Gate A and Gate B separately with meaningful tests and explicit approvals. D: replace all manual examples with declarative guidance now. D may reduce some supported surface but cannot establish coverage for exceptional recovery without a substantive decision. C considers D for each example and retains unresolved requirements rather than silently deleting them.

**Rubric.** Data and secret safety 40%: preserve a verified recovery point and avoid unintended mutation or disclosure. Supported-use coverage 25%: safe copyable paths for real recovery. Verifiability 20%: test the actual shell blocks and callers. Operator usability 10%: prefer native/declarative workflows where sufficient. Implementation burden 5%: avoid a new framework without a measured need.

| Option | Safety | Coverage | Verifiability | Usability | Burden | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 3 | 3 | 2 | 2 | 1 | 52 |
| B | 1 | 2 | 1 | 3 | 5 | 33 |
| C | 5 | 5 | 5 | 4 | 3 | 96 |
| D | 4 | 2 | 4 | 5 | 4 | 72 |

**Selected action (controlled English).** Use C. Read the complete issue and the fixture appendix. Map each acceptance requirement to a current file and a test. Keep a distinct approval for each gate. Do not run a real destructive command to validate a guide. Use isolated state and provider fixtures. Keep the exact safety requirements unless a new finding decision and applicable owner approval change them. Do not restore retired machinery to satisfy a stale filename or phase label.

## D07: Apply the independent plan review and reduce execution overhead

The [owner direction](evidence/independent-review-owner-direction.md) accepts the plan's convergence, retirement, issue-ownership and separate-budget policies and requires the execution corrections below. This is the single consolidated planning decision authorized by that message; no separate scoring record is required for each correction.

Preserve PR224 repairs and finish its released validation, normal publication and round2. Preserve the original first-request clock, deadline, round count and A02 transfer count. Move the tracker chronology verbatim to task journals, keep STATUS within16,384 bytes and make restart reads task-scoped. Use the full finding process for material product changes and product review findings; use a five-line note for nonproduction fixture/setup defects. Keep PR replies to three lines plus a decision link. The PR body carries the durable reviewer-facing decision summary. Sample worker evidence at round boundaries and retain independent final quality. Require two full pre-commit passes only where the issue requires them, including PS175.

Split protected instructions into A20 and validator/classification convergence into A21 after PR224 merges. A21 must select one base implementation before convergence; do not continue region-by-region porting. Assign developer-tool paths to A07, release A07/A08 from the A02 dependency, and move A10/A11 residual verification to A18. Keep one writer per worktree and let the PR owner draft decisions and implement without a publication checkpoint before each edit. Retain the real owner-authority boundaries.

Use one historical ledger with native delivery provenance, one remaining owner per original ID and unchanged26 historical credits. Preserve every original-contract byte. Remove per-original routing and duplicate disposition copies after their notes are folded into that ledger. Keep advisory three-tier routing, with A21 and final A19 reconciliation at the highest tier and census work light. Use the no-routing wrapper when the optional skill is absent.

At a review limit, obtain one dated owner choice: `extend once by N days`, `accept at limit`, or `close`; never reset counters or silently extend. The four exception classes in LOOP-POLICY receive one class decision each and per-path evidence. Synchronize metadata when convergence edits a shared file in both repositories; untouched historical metadata remains an allowed class.

No checkbox in the owner message is selected. A03-D1, protected-v2, A05, the A08 root protocol proposal now owned by A20, A13 and any eventual deadline extension remain pending. Prepare option L read-only; do not implement it without the owner decision. Prior retirements and issue closures stand. Validation of these planning corrections belongs in REVIEW and the plan verifier; this decision does not claim product completion.

## References and validation

- [Official model selection guidance](https://developers.openai.com/api/docs/guides/model-selection): use the lightest setting that meets the quality bar. The runtime catalog remains the availability source.
- [Copilot effort levels](https://docs.github.com/en/copilot/concepts/agents/code-review#review-effort-level): repository `AGENTS.md` supplies the exact Balanced transport and fallback rule.
- [Terraform state push](https://developer.hashicorp.com/terraform/cli/commands/state/push) and [removed blocks](https://developer.hashicorp.com/terraform/language/block/removed): support the distinction between exceptional manual mutation and declarative removal.
- [curl retry duration](https://curl.se/docs/manpage.html#--retry-max-time): retry-start and individual-transfer limits have different semantics; A04 must test the actual caller.

Primary pages were opened during this review. No product tests or operational recovery were run by this planning change. The plan's structural validation, source-preservation checks, Markdown lint and independent review are recorded in [VALIDATION.md](VALIDATION.md).
