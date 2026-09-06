<!-- markdownlint-disable MD013 MD041 -->

We are working on:

- The `planning-CRT-PR-852` branch of [PSStyleGuide](https://github.com/franklesniak/PSStyleGuide). This branch is available locally at `C:\Users\flesniak\GitHub\PSStyleGuide`.
- The `planning-CRT-PR-852` branch of [TerraformStyleGuide](https://github.com/franklesniak/TerraformStyleGuide). This branch is available locally at `C:\Users\flesniak\GitHub\TerraformStyleGuide`.

I need to conduct the following loop:

Use Codex as the orchestration and execution agent for this loop. Treat each `/goal` as a Codex persistent goal, wait for its terminal result, and verify the resulting repository state before the next step. For each `/goal`, locate and obey the target repository's applicable `AGENTS.md`. If none exists, read root `CLAUDE.md` as compatibility workflow instructions; the filename does not change the executor. Do not invoke Claude Code for any step in this loop. Use one compact state record and risk-proportionate validation. Do not create per-command receipts, routing proofs, or paperwork-only lifecycle steps.

When a generated prompt later requires a formal pull-request review loop, use one local Codex executor under the target repository's applicable instructions. Keep it distinct from GitHub Copilot and the remote Codex reviewer triggered by an exact `@codex review` PR comment. Freeze the semantically verified reviewer-facing body before review and keep mutable state and results outside it. Default to one reviewer pair for each final reviewed input. Generate a Copilot REST request from the typed reviewer specification with exact login `copilot-pull-request-reviewer[bot]`; reject the display name `Copilot`. Normalize API collections through the tested helper and require matching authenticated readback. Persist unique request-event, review-run, submitted-review, and conversation-comment baselines with the in-flight attempt. If an accepted request has no effect, use the bounded `RECONCILING` → `NO_EFFECT` → one-retry → `EXHAUSTED` contract while other safe work continues. Do not send the Codex trigger until the Copilot request is confirmed or is terminally proved non-functional through a persisted `terminalDisposition` whose state is `REPOSITORY_AUTHORIZED_NON_FUNCTIONAL`, whose authority and reason are nonempty, and whose recorded time is not earlier than the Copilot request. Persist Copilot `readyAt` as the authenticated release boundary before a Codex request. For a confirmed request, use the matching authenticated confirmation-readback time. For an unconfirmed terminal request, require `readyAt` to equal `terminalDisposition.recordedAt`. Require the Codex request time to be at or after `readyAt`. Treat a request event, submitted review, review run, or conversation comment as baseline evidence when any supplied node, numeric, or database identity overlaps its persisted baseline; every supplied identity must be absent from the matching baseline, every supplied review-run head identity must match the reviewed head, and all valid timestamp aliases for one event time must agree. Causal RFC 3339 ordering must preserve every supplied fractional digit. Before superseding an incomplete reviewed input, require every recorded request for it to be terminal and cross-validate request existence, its incomplete channel set, head, successor head, a disposition time not earlier than every request terminal-result or terminal-disposition boundary, and publication of that disposition before the different-input successor request. Reject a compact review state whose task head and review-input head differ. Reject non-finite or out-of-portable-range JSON numbers before parsing. Require a new pair after a code/diff change or a recorded material scope, behavior, or risk change. Do not request review again for a factual identity correction, result, task-state update, audit record, or comment-only publication on an unchanged reviewed input. Preserve both submitted-review objects and attributable Codex PR-conversation comments.

Normalize native check-run records for complete readback, but do not authenticate Copilot from a mutable check-run name plus the generic GitHub Actions App identity. Require a matching authenticated request event, requested-reviewer record, submitted review, or workflow-run bot actor.

For each confirmed terminal request, persist one closed `terminalResultRef` with the result kind, immutable identity, and observed time while the complete result stays in its separate channel result collection. During compact-state ingestion, cross-validate the reference against the correct channel, actor, every supplied request-baseline identity, losslessly ordered mutually consistent timestamp aliases, required matching normalized head evidence for a terminal conversation result, the reviewed head, and the next different-input request boundary. Reject a missing, duplicate, stale, baseline, wrong-actor, wrong-head, wrong-channel, or wrong-time reference. Do not add this reference to an unconfirmed or nonterminal request.

Keep every frozen reviewed head in `reviewerRequestsPerHead`, including a head that received zero requests. Persist each logical request's bounded physical `attemptCount` as one or two, default an absent legacy value to one, and sum those attempt counts in `reviewerRequestsPerHead`. During ingestion, require the current head and every request head to occur in that map, and require each count to equal the persisted request history. Pass that map into request-decision calls that evaluate retained supersessions. Revalidate its current head, request heads, exact counts, and key syntax there before using only those validated keys, the current head, and request heads as known successor identities for retained supersessions.

- Against the `PSStyleGuide` repo, run a `/goal` pointed at the prompt in `docs\planning\PSStyleGuide\prompt-01b-in-repo-with-criticism.md`. Wait for the goal to finish.
- Against the `PSStyleGuide` repo, run a `/goal` pointed at the prompt in `docs\planning\PSStyleGuide\prompt-02-in-repo.md`. Wait for the goal to finish.
- Commit the changed files to `PSStyleGuide`.
- Copy the resulting `docs\planning\PSStyleGuide\\\*PSStyleGuideP\*.md` files to the `docs\planning\PSStyleGuide` folder in the `TerraformStyleGuide` repo
- Commit the changed files to `TerraformStyleGuide`
- If new GitHub Issue file names have been introduced (e.g., there were four GitHub Issues previously drafted, but now there is six):
  - In the `PSStyleGuide` repo, modify each `docs\planning\PSStyleGuide\prompt-*-in-repo.md` file to reference the newly added/deleted/renamed files in the GitHub Issues slate, in the correct order.
  - In the `PSStyleGuide` repo, modify each `docs\planning\TerraformStyleGuide\prompt-*-in-repo.md` file to reference the newly added/deleted/renamed files in the GitHub Issues slate, in the correct order.
  - Commit the changes to the `PSStyleGuide` repo
  - In the `TerraformStyleGuide` repo, modify each `docs\planning\PSStyleGuide\prompt-*-in-repo.md` file to reference the newly added/deleted/renamed files in the GitHub Issues slate, in the correct order.
  - In the `TerraformStyleGuide` repo, modify each `docs\planning\TerraformStyleGuide\prompt-*-in-repo.md` file to reference the newly added/deleted/renamed files in the GitHub Issues slate, in the correct order.
  - Commit the changes to the `TerraformStyleGuide` repo
- Against the `PSStyleGuide` repo, run a `/goal` pointed at the prompt in `docs\planning\PSStyleGuide\prompt-03-in-repo.md`. Wait for the goal to finish.
- Commit the changed file to `PSStyleGuide`.
- Copy `docs\planning\TerraformStyleGuide\slate-criticism.md` from the `PSStyleGuide` repo to `docs\planning\TerraformStyleGuide\slate-criticism.md` in the `TerraformStyleGuide` repo.
- Commit the changed file to `TerraformStyleGuide`.
- Against the `TerraformStyleGuide` repo, run a `/goal` pointed at the prompt in `docs\planning\TerraformStyleGuide\prompt-01b-in-repo-with-criticism.md`. Wait for the goal to finish.
- Against the `TerraformStyleGuide` repo, run a `/goal` pointed at the prompt in `docs\planning\TerraformStyleGuide\prompt-02-in-repo.md`. Wait for the goal to finish.
- Commit the changed files to `TerraformStyleGuide`.
- Copy the resulting `docs\planning\TerraformStyleGuide\\\*TerraformStyleGuideP\*.md` files to the `docs\planning\TerraformStyleGuide` folder in the `PSStyleGuide` repo
- Commit the changed files to `PSStyleGuide`
- If new GitHub Issue file names have been introduced (e.g., there were four GitHub Issues previously drafted, but now there is six):
  - In the `TerraformStyleGuide` repo, modify each `docs\planning\TerraformStyleGuide\prompt-*-in-repo.md` file to reference the newly added/deleted/renamed files in the GitHub Issues slate, in the correct order.
  - In the `TerraformStyleGuide` repo, modify each `docs\planning\PSStyleGuide\prompt-*-in-repo.md` file to reference the newly added/deleted/renamed files in the GitHub Issues slate, in the correct order.
  - Commit the changes to the `TerraformStyleGuide` repo
  - In the `PSStyleGuide` repo, modify each `docs\planning\TerraformStyleGuide\prompt-*-in-repo.md` file to reference the newly added/deleted/renamed files in the GitHub Issues slate, in the correct order.
  - In the `PSStyleGuide` repo, modify each `docs\planning\PSStyleGuide\prompt-*-in-repo.md` file to reference the newly added/deleted/renamed files in the GitHub Issues slate, in the correct order.
  - Commit the changes to the `PSStyleGuide` repo
- Against the `TerraformStyleGuide` repo, run a `/goal` pointed at the prompt in `docs\planning\TerraformStyleGuide\prompt-03-in-repo.md`. Wait for the goal to finish.
- Commit the changed file to `TerraformStyleGuide`.
- Copy `docs\planning\PSStyleGuide\slate-criticism.md` from the `TerraformStyleGuide` repo to `docs\planning\PSStyleGuide\slate-criticism.md` in the `PSStyleGuide` repo.
- Commit the changed file to `PSStyleGuide`.

Repeat the loop up to 12 times, or until the state of the GitHub Issue drafts across both repositories has converged/stabilized.
