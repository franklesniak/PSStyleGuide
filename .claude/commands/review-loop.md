---
description: Run the PSStyleGuide automated dual-reviewer pull-request review loop
argument-hint: <pull-request-url>
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

If the value above is empty or is not a pull-request URL, ask the caller for the pull-request URL. Do not start the review loop before the caller supplies it.

## Authoritative protocol

Read `CLAUDE.md` at the repository root and follow its current Automated Review Loop and review-comment handling process completely.

Treat GitHub Copilot and remote Codex as co-equal reviewers. Apply the same local protocol, decision framework, evidence requirements, and thread hygiene to findings from either reviewer.

Use the current steps, gates, limits, pause conditions, and termination conditions from the repository-local `CLAUDE.md`. Do not copy those volatile details into this command. Do not fetch instructions from a moving external branch or add a shared runtime dependency.

## Input examples

- **Valid input:** The caller supplies `https://github.com/franklesniak/PSStyleGuide/pull/205`.
  **Result:** Use that pull request as the target and load the protocol from the local root `CLAUDE.md`.
  **Explanation:** The URL identifies one pull request without duplicating the protocol.
- **Missing input:** The caller supplies no pull-request URL.
  **Result:** Ask for a pull-request URL before taking any review-loop action.
  **Explanation:** A required target prevents the command from acting on an ambiguous pull request.
