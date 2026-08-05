# CLAUDE.md — working agreement for coding agents in this repository

This file orients Claude Code (and other coding agents) working in
`PSStyleGuide`. For the repository's documentation-authoring rules — the
`STYLE_GUIDE.md` / `STYLE_GUIDE_RATIONALE.md` split and its generated
consumer-facing derivatives — follow `.github/copilot-instructions.md`.

## Responding to code-review comments

A review comment is not "handled" until its thread is both **answered and
resolved**. Treat *address and resolve* as one unit of work, not two optional
halves. For every review thread you act on:

1. **Address it.** Make the change the comment calls for. If the finding does
   not hold, or is intentionally out of scope, establish that **with evidence** —
   do not assume that a changed line, or an "outdated" label, means the issue is
   gone. Check whether it still applies against the current code.
2. **Reply on the thread.** Document the outcome: the fix, naming the commit and
   the file/line it landed at; or, for a finding you are not changing, the
   reasoned disposition — refuted with evidence, or accepted as a documented,
   bounded residual with the trade-off named. Where more than one defensible fix
   exists, show the options you weighed and why you chose one. End every reply
   with the Claude Code attribution footer.
3. **Resolve the thread.** Mark it resolved once the reply is posted. An
   addressed-but-unresolved thread hides real state — a reader cannot tell a
   handled comment from an open one. The one exception: a finding that genuinely
   needs a maintainer's decision you should not make on their behalf. In that
   case, say so explicitly on the thread and leave it open.

When asked to take a pull request to a clean review state, apply this to **every
unresolved thread on the PR**, not only the most recent ones.

## Tests

The candidate-artifact validator ships with an adversarial harness,
`.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1`, which
authenticates the two production scripts by their git-blob identity before it
runs. **Commit your change before running the harness**, or the identity gate
will refuse the modified working tree.
