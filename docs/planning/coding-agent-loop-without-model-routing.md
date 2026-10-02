<!-- markdownlint-disable MD013 -->
# Execute without model routing

Use [coding-agent-loop.md](coding-agent-loop.md) and the [current modular plan](action-items-2026-10-02/README.md) for all scope, authority, evidence, review, convergence, restart and acceptance rules.

This optional wrapper changes only model selection: use the current agent settings and do not invoke the model-routing-advisor skill or claim a model switch. Use it only when the owner explicitly chooses to opt out of routing. The normal entry prompt retains the owner's requested model-routing workflow. Independent bounded work may still be delegated with inherited settings where the owner permits it; retain one writer per scope and the runtime concurrency limit.

Read the current STATUS record first. This wrapper does not reactivate old numeric task state, condensed-plan dispositions, expired exceptions or the legacy controller. It does not create new authority.
