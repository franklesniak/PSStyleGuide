<!-- markdownlint-disable MD013 -->
# Advisory models and safe parallel work

Routing is advisory. If the model-routing skill is available, use it; otherwise use the [no-routing wrapper](../coding-agent-loop-without-model-routing.md). This plan does not require a local skill installation or a manual model switch. Resolve exact supported overrides from the runtime catalog; public model descriptions do not establish account availability. Prices are not verified.

Effective model and effort settings are not exposed in this runtime. This limitation is recorded here once; do not repeat an attestation in task results or rerun accepted historical work to recover it.

## Three tiers

| Tier | Current advisory route | Use |
| --- | --- | --- |
| Light | gpt-6-luna / medium | A01 and bounded census/extraction parts of A19 |
| Balanced | gpt-6.1-sol / medium or high | Ordinary bounded implementation, tooling and review-instruction work |
| Highest | gpt-6-astra / high | Security/integration decisions; A21 complete validator selection/convergence; A19 final reconciliation; A18 final union audit |

Task recommendations are starting points, not 402 dispatches. Increase effort or tier when concrete ambiguity warrants it; do not reroute merely because a deterministic test fails. Use a healthy PR-owning worker for its repairs. No routed worker spawns descendants.

## Ownership and parallel work

The worker that owns a PR drafts its finding decisions and implements inside that PR. Complete the selected materiality process before a material edit; no publish-each-decision-before-each-edit gate is required. The coordinator reviews at round boundaries, samples hashes and score totals, and owns native operations, STATUS and counters. Independent final quality verifies integrity at PR level.

Keep one writer per worktree and outcome. The coordinator alone integrates planning files. Serialize shared workflows, lockfiles and generated outputs, and serialize product merges. Never implement both repositories' side of the same convergence outcome simultaneously. Read-only research and immutable-input reviews can run in parallel. Use at most current runtime capacity; capacity is a ceiling, not a target.

A07 and A08 can start after A00/A01. A07 must leave Invoke-MarkdownLint.ps1 and MARKDOWN-LINTING-IMPLEMENTATION.md untouched until PR224 merges; respect all other active path ownership. A08's root protected proposal belongs to A20. A20 and A21 start product implementation after PR224 merges, with explicit authority additionally required for A20. A21 chooses one validator base once and coordinates its classifier interface with A03; it does not port by region. A10/A11 have no new worker lifecycle; A18 owns their residual verification. Continue A15 read-only until its real foundations and gate choices are ready.

## Handoff and restart

Read STATUS's table, README, LOOP-POLICY, your task and its RESULT. Open a journal only when resuming that task; it is append-only history, not mandatory restart input. Keep STATUS within 16 KB and its local configuration within 2 KB. At a meaningful boundary report the pinned input, scoped result, pending native request and next action. Preserve counters and reconcile ambiguous writes before retrying. Do not create per-command receipts or new model-attestation records. Local paths and runtime locations belong only in STATUS's Local configuration.
