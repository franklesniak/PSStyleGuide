---
description: Run the PSStyleGuide automated dual-reviewer pull-request review loop
argument-hint: <pull-request-url>
disable-model-invocation: true
---

<!-- markdownlint-disable MD013 -->

# Pull-request review loop

## Metadata

- **Status:** Active
- **Owner:** Repository maintainer (@franklesniak)
- **Last Updated:** 2026-09-22
- **Scope:** Starts the repository-local automated review loop for one identified pull request. This command does not redefine the review protocol.
- **Related:** [Claude Code instructions](../../CLAUDE.md), [implementation issue](https://github.com/franklesniak/PSStyleGuide/issues/163)

## Target pull request

Target pull request: **$ARGUMENTS**

Before starting the review loop or changing remote state, confirm that the URL uses `github.com` and names `franklesniak/PSStyleGuide`. Then use an authenticated GitHub readback to verify the canonical pull-request identity, including its number, and confirm that its owning/base repository is exactly `franklesniak/PSStyleGuide`. Confirm that the pull request reports `state` as `open` and `merged` as `false`. Record and preserve its `draft` value; do not change the pull-request stage. Do not use an unverified URL as an authentication target.

Treat an empty or malformed value, a different host or repository, and a closed or merged pull request as invalid. Tell the caller the specific reason and ask for a valid open, unmerged `franklesniak/PSStyleGuide` pull-request URL. If the authenticated readback reports a draft, preserve that stage and continue with the same complete protocol; do not mark it ready automatically.

If the authenticated readback is unavailable, failed, unauthenticated, or ambiguous, stop and report the specific reason. Retry only after access is restored. Do not guess the target, change remote state, or start the review loop until the authenticated readback succeeds and matches the expected repository, pull-request number, and open, unmerged lifecycle state.

## Authoritative protocol

Read `CLAUDE.md` at the repository root and follow its current Automated Review Loop and review-comment handling process completely.

Treat GitHub Copilot and remote Codex as co-equal reviewers. Apply the same local protocol, decision framework, evidence requirements, and thread hygiene to findings from either reviewer.

Use the current steps, gates, limits, pause conditions, and termination conditions from the repository-local `CLAUDE.md`. Do not copy those volatile details into this command. Do not fetch instructions from a moving external branch or add a shared runtime dependency.

## Input examples

- **Valid input:** The caller supplies a URL of the form `https://github.com/franklesniak/PSStyleGuide/pull/<number>`, where authenticated readback reports `state` as `open` and `merged` as `false`.
  **Result:** Confirm the canonical identity, owning/base repository, and lifecycle state, preserve the `draft` value, and then load the protocol from the local root `CLAUDE.md`.
  **Explanation:** Verified identity and lifecycle state identify one active pull request without duplicating the protocol or changing its stage.
- **Missing input:** The caller supplies no pull-request URL.
  **Result:** Ask for a pull-request URL before taking any review-loop action.
  **Explanation:** A required target prevents the command from acting on an ambiguous pull request.
- **Wrong repository:** The caller supplies `https://github.com/example/other-repository/pull/123`.
  **Result:** Explain that the pull request is outside `franklesniak/PSStyleGuide` and ask for the correct URL before changing remote state.
  **Explanation:** Canonical repository verification keeps this repository-local command within its authorized boundary.
- **Closed or merged input:** The URL resolves to a pull request whose authenticated readback reports `state` as `closed` or `merged` as `true`.
  **Result:** Stop before changing remote state, report the lifecycle state, and ask for a reopened or different open, unmerged pull request.
  **Explanation:** The review loop must not mutate an obsolete pull request.
- **Unavailable readback:** GitHub cannot return an authenticated canonical identity for the supplied URL.
  **Result:** Stop, report the readback failure, and retry only after access is restored.
  **Explanation:** A failed or ambiguous lookup is not evidence that the target is safe.
