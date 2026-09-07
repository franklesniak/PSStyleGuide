<!-- markdownlint-disable MD013 -->

# Repository agent instructions

## GitHub Copilot pull-request reviews

Use `Balanced` as the preferred effort for each GitHub Copilot pull-request review.

This preference controls the transport choice even when a task or controller describes the REST reviewer request. Keep that REST request as the fallback.

1. Capture the request-event, requested-reviewer, submitted-review, and Copilot workflow-run baselines required by the active review-loop policy.
2. Open the pull request on GitHub. In the `Reviewers` section, use the control next to Copilot. Select `Balanced`, then submit one request.
3. Confirm one new authenticated request event or exact-head Copilot workflow run. Do not repeat an accepted request while its result is pending.
4. When the review finishes, read the effort from the pull-request timeline or Copilot overview. Record the observed value. Do not infer `Balanced` from an HTTP `201` response or from reviewer identity alone.
5. If the supported interface cannot select `Balanced`, record the reason and use the GitHub CLI special value `@copilot`: `gh pr edit PR-NUMBER --add-reviewer '@copilot'`. The quotes are required in PowerShell. If that command is unavailable, use `gh api --method POST "repos/OWNER/REPOSITORY/pulls/PR-NUMBER/requested_reviewers" -f "reviewers[]=copilot-pull-request-reviewer[bot]"`. A resulting `Lite` review is an acceptable fallback. It does not fail or stall the review loop.
6. Do not send a second request only because GitHub used `Lite`. Continue the review loop with that result unless another active rule independently requires a new review.

The GitHub CLI and public REST review-request API select a reviewer but do not expose a per-request effort option as of 2026-09-07. For the CLI, `@copilot` is a documented special value, not a reviewer login. For a direct REST request, send reviewer login `copilot-pull-request-reviewer[bot]`; do not send display name `Copilot`. Captured browser cookies, CSRF tokens, nonces, multipart boundaries, and internal form fields are transient secrets or implementation details. Do not store, publish, replay, or document them.

References: [GitHub Copilot code-review effort levels](https://docs.github.com/en/copilot/concepts/agents/code-review#review-effort-level) and [GitHub review-request REST parameters](https://docs.github.com/en/rest/pulls/review-requests?apiVersion=2022-11-28#request-reviewers-for-a-pull-request).
