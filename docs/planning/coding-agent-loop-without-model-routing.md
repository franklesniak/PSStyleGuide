<!-- markdownlint-disable MD013 -->
# Execute without model routing

Use [coding-agent-loop.md](coding-agent-loop.md) and the [current modular plan](action-items-2026-10-02/README.md) for all scope, authority, evidence, review, convergence, restart and acceptance rules.

This optional wrapper changes only model selection: use the current agent settings and do not invoke the model-routing-advisor skill or claim a model switch. Use it when the optional routing skill is unavailable or the owner chooses to opt out. Routing is advisory; skill installation is not a prerequisite for execution. Independent bounded work may still be delegated with inherited settings where the owner permits it; retain one writer per scope and the runtime concurrency limit.

Read the current STATUS record first. This wrapper does not reactivate old numeric task state, condensed-plan dispositions, expired exceptions or the legacy controller. It does not create new authority.
