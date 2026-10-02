<!-- markdownlint-disable MD013 -->
# Models and safe parallel work

The owner invoked [model-routing-advisor](C:/Users/flesniak/.agents/skills/model-routing-advisor/SKILL.md). Read its current installed instructions at execution. Do not copy an evergreen model list into the runtime. The catalog exposed to this planning session supports exact `gpt-6-luna`, `gpt-6.1-sol`, and `gpt-6-astra` overrides at the low/medium/high reasoning levels used here. Other available models are not needed by these initial recommendations. Prices and comparative task latency were not verified; these are capability-based starting choices, not a proved cheapest allocation.

[Official selection guidance](https://developers.openai.com/api/docs/guides/model-selection) supports using the lightest setting that meets the quality bar. Runtime/account metadata establishes availability and supported effort. The task files and [task-index.json](task-index.json) specify each active route. Every original leaf also has a revisited route in [historical-map.json](historical-map.json); those are conditional recommendations if a distinct missing step is needed, not 402 automatic dispatches.

## Dispatch and verification

- `gpt-6-luna/medium`: bounded factual inventory (A01) and mechanical historical leaves. Escalate uncertain classification before it affects scope.
- `gpt-6.1-sol/medium`: routine review-instruction or established example work (A08/A10).
- `gpt-6.1-sol/high`: coupled ordinary implementation, dependency changes, current supply analysis and final evidence reconciliation (A02/A04/A05/A07/A09/A19).
- `gpt-6-astra/high`: conflicting historical evidence, trust/security boundaries, generator integration, operational recovery, residual assessment and final convergence (A00/A03/A06/A11–A18 where specified).

At dispatch, show the skill's compact recommendation and use the exact supported override. Increase effort first when the model remains capable; escalate model for material ambiguity, security, coupled architecture or repeated inadequate analysis. Do not reroute merely because a deterministic test failed. Keep a healthy worker on its task and provide the failure evidence.

The parent retains integration and native mutation authority. Routed workers must not spawn descendants. Use at most one implementing worker for a given outcome/scope; reuse it for repairs. Different independent outcome workers are allowed by the owner's request for thoughtful parallelism and the runtime's concurrency limit. Do not create a new user-owned Codex chat for these subtasks.

After spawning, verify effective model/effort if authoritative metadata exposes it. This session's spawn response returned an agent ID without effective settings, so the completion audit's requested `gpt-6-astra/high` override was not independently verified. Unknown metadata is not a failed product test or a reason to repeat an accepted historical review. Record actual reviewer identities; never claim a local agent is Copilot, remote Codex or an unavailable Claude service.

## Ready work and ownership

Use at most the current runtime capacity. This session has four slots: one coordinator and up to three workers. Capacity is a ceiling, not a target. The coordinator owns STATUS, dispatch, scopes, transfer counters, merge order and final acceptance.

| Stage | Useful concurrent work | Write constraints |
| --- | --- | --- |
| Initial audit | A00 historical/retirement analysis; A01 issue/tree census; read-only preparation for A15 | Coordinator alone writes shared tracker; distinct evidence handoffs |
| After baseline | A12 protection assessment; A14 residual research; A15 T4 design while A02 proceeds | A12/A14/A15 are initially read-only; protected edits require actual authority |
| Shared foundations | A03 workflow design, A07 dependency analysis and A08 review-command work | A03/A07 share policy and CI surfaces; analysis can overlap, implementation must acquire those paths and integrate serially |
| After shared foundations | A10 PS language examples and A11 TF language recovery | Separate worktrees/repositories; shared generator/toolchain edits belong to A06/A07 and cannot be duplicated |
| T4 implementation | Gate A helper/test work split into independent read-only design or tests once interfaces are fixed | One Gate A integration writer; Gate B cannot begin before Gate A's actual approval |
| Review waits | Peer diff, independent quality on immutable inputs, unrelated ready read-only tasks | Do not implement both sides of the same outcome simultaneously; pending request state has one owner |
| Final integration | A18 full union audit and independent evidence inspection | Serialize product merges; capture a stable pair of native main commits |

Each writer gets a separate worktree created from the selected repository's current main, allowed paths, relevant contracts, test commands, acceptance predicate and actual public-action authority. Reject overlap in generated outputs, lockfiles, workflow validators or their fixtures, even if source filenames differ. Share interface contracts before parallel tests or research; do not let independent workers invent incompatible helper APIs.

Serialize merges per repository. After any merge, assess its effect on the other workers' pinned base and validation; refresh only invalidated results. One outcome may wait for external review while another proceeds, but that does not permit two incompatible main-branch integrations.

## Durable handoff

Before a real wait or restart, return the actual head/base, allowed/changed paths, selected decisions, tests, pending native request and next action. The coordinator updates STATUS at that meaningful boundary. A worker may use one local scratch handoff while running; final evidence belongs in the outcome result. Do not commit ephemeral timing logs, browser data, credentials, or a new hierarchy of routing/activation receipts.
