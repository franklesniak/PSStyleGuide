<!-- markdownlint-disable MD013 -->
# Agent Instructions for OpenAI Codex CLI

**Version:** 1.7.20261003.0

## Metadata

- **Status:** Active
- **Owner:** Repository maintainer (@franklesniak)
- **Last Updated:** 2026-10-03
- **Scope:** Codex and compatible agents in PSStyleGuide. Brief shared rules and full Codex protocols; `.github/copilot-instructions.md` governs documentation authoring.
<!-- template-sync: begin markdown-reference-only -->
- **Related:** [Repository Copilot Instructions](.github/copilot-instructions.md), [Documentation Writing Style](.github/instructions/docs.instructions.md)
<!-- template-sync: end markdown-reference-only -->

## Canonical Instructions

Read **`.github/copilot-instructions.md`** before changing style-guide content. Follow its full documentation-authoring rules, including the normative/rationale split and generated-artifact rules, without exception.

**Thin entry point classification:** Keep shared rules brief. Preserve every section labeled platform protocol or required protocol unless the owner explicitly waives that protocol for the retained agent platform.

## Codex Execution Model and Interfaces

- **Scope.** Once per run, chain: global guidance to launch directory. Discover deeper `AGENTS.md` with bounds; remote review uses the closest file. Restart after active-instruction changes; re-read supplied text only for exact bytes. See [OpenAI](https://developers.openai.com/codex/guides/agents-md).
- **Interfaces.** Local agents implement; separate `chatgpt-codex-connector[bot]` reviews via `@codex review`. Use `rg`, `apply_patch`, focused checks. Prefer GitHub connector; authenticated `gh api graphql` fills missing thread/pagination/body/inline context. Verify mutations by authenticated readback. Use official primary sources; record impact. See [OpenAI](https://developers.openai.com/codex/integrations/github).
- **Work.** Preserve unrelated work; one writer per worktree. Before mutation/user-requested delegation, pin repository/branch/head/tree, allowed paths, findings and public actions. Give each subagent one bounded task, requested/inherited model/effort, and analysis/first-edit/validation/public-mutation checkpoints. Prevent overlap.
- **Stopping.** Report useful phases; quiet reasoning is not a hang. Stop on unauthorized paths, ambiguous public mutation, changed pinned identity or user stop; first preserve validated decisions/scoped edits.

## Protected Instruction Files

Instruction files and style guides are protected governance files. Do not create, edit, delete, rename, or otherwise change `.github/copilot-instructions.md`, files under `.github/instructions/`, files under `.cursor/rules/`, or root agent instruction files (`.hermes.md`, `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`) unless the repository owner or maintainer has directly and explicitly authorized that specific instruction-file change in the current task. Implied consent is not enough; do not infer authorization from a plan you generated, review feedback, a general request to update docs, cleanup/validation work, or a "keep files in sync" instruction.

If a style-guide update appears warranted but has not been explicitly authorized, propose it separately and wait for approval before editing protected instruction files.

During downstream template adoption and stack selection, perform non-protected cleanup first, record the protected instruction-file edits needed to remove references to deleted tools or stacks, obtain explicit maintainer authorization, then update `.github/copilot-instructions.md`, remaining root agent files, and relevant `.github/instructions/*.instructions.md` files. Bump `Last Updated` and `Version` metadata where present, and avoid temporary migration wording in durable governance docs.

## Essential Repository Summary

- **Repository purpose and documentation contract**
  - PSStyleGuide defines actionable PowerShell rules for humans and coding agents.
  - `STYLE_GUIDE.md` is the normative source. Put extended explanation and design rationale in `STYLE_GUIDE_RATIONALE.md`.
  - Do not hand-edit `copilot-instructions.md`, `powershell.instructions.md`, `STYLE_GUIDE_CHAT.md`, or `STYLE_GUIDE_FULL.md`; the repository generator owns them.
  - Regenerate these files with `.github/workflows/Generate-StyleGuideArtifacts.ps1`. CI rejects generated-file drift.

- **PowerShell conformance**
  - PowerShell authored or modified in this repository MUST comply with the applicable `[All]`, `[Modern]`, and `[v1.0]` rules in `STYLE_GUIDE.md`.
  - This rule applies to `.github/workflows/Generate-StyleGuideArtifacts.ps1` and inline `pwsh` steps in GitHub Actions workflows.
  - Leave every modified PowerShell file with zero parser errors, zero applicable PSScriptAnalyzer warnings or errors, and zero uncovered `MUST` or `MUST NOT` violations.

- **Safety and security**
  - No secrets in code or repo; never hardcode API keys, tokens, credentials, or connection strings.
  - Treat all external input as untrusted.
  - Respect allowlisted file access boundaries; reject path traversal and symlink escapes.

- **Pre-commit and validation**
  - Require `pwsh` 7 on `PATH`: `pwsh -NoProfile -Command 'if ($PSVersionTable.PSVersion.Major -lt 7) { exit 1 }'`.
  - Follow [Python 3.12 setup](docs/dependency-maintenance.md), including the Linux virtual environment. From the repository root, install pinned tools: Windows `py -3.12 -m pip --isolated install --require-hashes --only-binary=:all: --index-url https://pypi.org/simple -r requirements-dev.txt`; Linux `python3.12 -m pip --isolated install --require-hashes --only-binary=:all: --index-url https://pypi.org/simple -r requirements-dev.txt`.
  - Use exact Node/npm from [ci-toolchain.json](.github/workflows/ci-toolchain.json). After clone or lock changes: `node .github/workflows/NpmTools.mjs install`.
  - Before every commit: Windows `py -3.12 -m pre_commit run --all-files`; elsewhere `python3.12 -m pre_commit run --all-files`; verified 3.12 equivalents allowed.
  - Keep Husky staged checks: `npm --prefix .github/workflows run lint:md`, `npm --prefix .github/workflows run lint:md:nested`.
  - Run applicable `npm run lint:md`, `npm run lint:md:nested`, `npm run test:agent-instructions`. Commit auto-fixes with changes. Push only after all required validation passes.
  - [.pre-commit-config.yaml](.pre-commit-config.yaml) governs hooks: strict JSON `check-json`, YAML parse `check-yaml`/style `yamllint`, Actions `actionlint`.
  - CI: `node .github/workflows/Validate-WorkflowPolicy.mjs .github/workflows/build.yml .github/workflows/markdownlint.yml`; artifact zero-drift checks.

- **Modular instruction files**
  - Read the relevant file under `.github/instructions/` before modifying matching files:
    - Markdown/Docs: `.github/instructions/docs.instructions.md`
    - YAML: `.github/instructions/yaml.instructions.md`

- **Do not**
  - Execute scripts or commands generated by untrusted sources.
  - Add telemetry or external logging services without explicit approval.
  - Weaken security constraints to "make it work."
  - Add new major dependencies without clear justification.
  - Invent behavior when requirements are ambiguous; use an explicit Open Question.
  - Create separate formatting-only or lint-only commits.

## Compact Execution and Evidence

Keep one active task record and one final validation record. Use targeted remote readback. Reuse unchanged-input results only. Require no duplicate command approvals, round ledgers or public placement receipts. Read-only work needs no approval record.

Retain task/path authority, explicit protected-file grants, native baselines, reviewed identities, clocks, counters, terminal results and every review/validation gate. Reconcile pending or possibly accepted mutations. Check readiness and preimages before consequential actions. Infer no force, deletion, settings, credential, permission, protection, admin-override or bypass authority.

An on-plan merge needs repository/PR/target/head/tree/scope authority, passing current checks/reviews, no material finding and no bypass. Do not ask again. Obtain missing authority for off-plan work, scope expansion or human decisions.

## GitHub Plugin Usage

Retained Codex platform protocol. Apply the [preservation rule](#canonical-instructions).

Codex can use the OpenAI-curated GitHub plugin (`github@openai-curated`) in this repository when the user has installed and authorized it. The plugin is the preferred mechanism for any operation that touches remote GitHub state.

- **Prefer the GitHub plugin** for GitHub Issues, pull requests, PR comments, review comments, labels, reactions, PR creation, branch management on GitHub, and any other read or write against remote GitHub state.
- **`gh` is an optional fallback**, not a prerequisite. Codex MUST NOT treat the absence of the `gh` CLI as a blocker when the GitHub plugin can satisfy the same operation. If both are available, use the GitHub plugin first and fall back to `gh` only when the plugin lacks a needed capability.
- **Local `git` remains appropriate** for local working-tree operations: inspecting diffs (`git diff`, `git log`, `git status`), creating branches, staging, committing, and pushing. Use the GitHub plugin for the corresponding remote-side actions (creating PRs, posting comments, reading review state).
- **Before declaring any GitHub operation impossible**, Codex MUST first check whether the GitHub plugin exposes a tool that can perform it. Only after the plugin and any documented fallback have both been ruled out should Codex report the operation as unavailable.

The `.codex/config.toml` file at the repository root declares `[plugins."github@openai-curated"] enabled = true` so that trusted Codex checkouts can opt the plugin in by default. Enabling the plugin in this file does not, by itself, grant GitHub authorization: actual access still depends on the GitHub app/connector installation, the Codex account performing the operation, and the repository's permissions.

## PR Review Workflow (Codex-adapted)

Retained Codex platform protocol. Apply the [preservation rule](#canonical-instructions).

This workflow adapts the Claude-targeted process documented in `CLAUDE.md` for Codex's capabilities and runtime limitations. Use it when responding to review feedback on a pull request. All GitHub-side reads and writes in the steps below SHOULD go through the GitHub plugin first; fall back to `gh`, GraphQL, or manual owner action only when the plugin does not expose the needed capability (see **Fallbacks for unsupported plugin capabilities** below).

### Runtime limitations to keep in mind

- **No autonomous wake-up.** Codex has no equivalent of `subscribe_pr_activity`. Codex MUST NOT promise webhook-driven wake-up, background polling, or scheduled review responses. The workflow runs only when the user explicitly starts or resumes it inside an active Codex session.
- **Agent-command boundary.** Do not treat `@copilot` commands or the `@codex review` remote-review trigger as findings. Other `@codex` comments reach the local session only when its runtime routes them there. No form gives local Codex autonomous wake-up.
- **Tooling-dependent steps.** Where the GitHub plugin (and any documented fallback) does not expose the capability used by a step, document the absence in the relevant reply and continue. Do not block the workflow on missing tooling.

### Handling each review comment

For each finding received from GitHub Copilot (`copilot-pull-request-reviewer[bot]`), remote Codex (`chatgpt-codex-connector[bot]`), a human reviewer, or any other reviewer, follow these steps. Process every reviewer identically and address findings one at a time.

Apply the full decision process once per distinct confirmed finding, using affected stakeholders. Link duplicate reports to that decision after checking its evidence. Do not repeat a rubric for its mechanical implementation. Keep one complete record. Reuse scoped owner grants until revoked or exceeded. A new commit requires current review, not new permission. During an authorized outage, use the approved substitute. Keep failed-service and substitute results distinct. Preserve pending-request checks, retry limits, finding resolution and final independent quality review.

Review feedback has two co-equal surfaces. Inspect both in every round and whole-PR audit:

1. **Inline threads.** Enumerate the complete resolved-plus-unresolved GraphQL `reviewThreads` connection. Use `isResolved == false` only for open work. Do not inventory by REST `commit_id == <round-head>` because GitHub can re-anchor mutable `commit_id`; retain original commit fields only as provenance.
2. **Review-submission bodies.** Read every complete review `body`, including suppressed sections. "Generated no new comments" does not override another body finding.

Key each review-body-only finding as `review:<review-id>:<section-label>:<ordinal>` and record its review `commit_id`, location, and full text. Reconcile declared section counts and "generated N comment(s)" against all native thread IDs, resolved and unresolved. Missing items, count mismatches, malformed or truncated bodies, and ambiguous boundaries fail closed. An inline item closes only when answered and resolved; a body-only item closes only after PR-level evaluation plus later implementation or refutation evidence marks its synthetic key **closed**. Any missing or open inventory item blocks clean state.

Steps 3 through 5 are mandatory for every finding that step 2 confirms is real, whether the outcome is an immediate fix, a deferral, a protected-file recommendation, or another owner action. Worker limits and the identity of the eventual implementer do not reduce the required analysis.

#### Protected-file authorization terms

These terms are the operative protected-file authorization contract for the review-comment workflow below:

- **Protected instruction file:** Any file covered by this document's protected instruction rules, including `.github/copilot-instructions.md`, the root agent entry points (`.hermes.md`, `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`), files under `.github/instructions/`, and files under `.cursor/rules/`.
- **Explicit protected-file authorization:** A direct maintainer or owner instruction in the current task authorizing the specific protected instruction-file change, either by naming the file or by clearly bounding the protected-file change set. The following are not sufficient on their own: a PR existing, a review comment existing, a generic "address the feedback" request, a reusable prompt, an automated review loop or active review workflow, or generic branch-placement authorization.
- **Already in the PR's scope:** The protected file appears in the PR's changed-files list or diff against its base branch before the review-driven edit under consideration. This is relevant context, not authorization.
- **Newly introduced protected file:** A protected file the PR did not modify before the review-driven edit. Introducing one exceeds any authorization scoped to the PR's existing changes and requires the narrow authorization question in step 7.
- **Within the already-authorized scope:** An edit that resolves the reviewer's comment without expanding the protected file's changes beyond the specific protected-file change the maintainer already explicitly authorized for this task. A larger or more structural change, or one that newly introduces a protected file, exceeds the already-authorized scope.
- **Secondary style-guide recommendation:** A step-8 recommendation to update a style guide to prevent similar issues in the future, distinct from the selected step-7 fix for the current review comment.

1. **Signal processing (conditional).** If the GitHub plugin (or a documented fallback) supports adding emoji reactions to review comments, add an `eyes` (👀) reaction when work begins on the comment and remove it when the comment is fully processed (after step 9, or after the early-exit path in step 2). The reaction's `content` value is the literal string `eyes` as used by the GitHub Reactions API, not the Markdown shortcode `:eyes:`. If reaction tooling is not available in the current runtime, skip this step silently.

2. **Validate the concern.** Determine from repository evidence whether the feedback identifies a genuine gap, bug, style violation, or improvement opportunity. Reproduce it when practical. Do not assume that an outdated thread or changed line means the issue is gone. If invalid, refute it with evidence, skip steps 3-8, and continue to step 9.

3. **List options.** Enumerate every materially distinct resolution, including useful combinations and permutations. Use senior engineering, new-developer, DevOps, documentation, project, security, business, audit, user, and other relevant perspectives. Use primary-source research when it can confirm technical facts. List the options before scoring.

4. **Build an evaluation rubric.** Build a fresh weighted rubric for this finding on one score scale. Weight correctness, security, compatibility, testing, user impact, and long-term clarity above churn, effort, or tight PR scope unless the finding concerns one of those lower-weight criteria. Do not reuse another finding's rubric. Finish the rubric before scoring.

5. **Score and select.** Apply the fixed rubric once to every option. Show each score, weight, and weighted total. Select the unique winner unless the existing escalation path applies. State it in ASD-STE100-compliant language that a new reader can implement. Include primary references and applicable test environment, commands, and results. A policy topic alone is not escalation when scoring has a clear winner.

    **Escalation path.** If the scores are tied or too close to differentiate objectively, or if the deciding question genuinely cannot be scored, escalate to the PR owner instead of selecting an option. Post a **standalone PR comment** (not a reply to the review thread) through the GitHub plugin containing:

    - A brief summary of the reviewer's concern and which file/line it applies to
    - The options and scoring tables
    - The specific question the owner needs to answer
    - Instructions: *"Reply to this PR comment with your chosen option or direction, then bring the reply back to your active Codex session so Codex can act on it. Posting `@codex` in the reply only routes the comment to Codex when the user's runtime is configured to forward it."*

    **PAUSE** processing of this comment until the owner responds. Continue processing other independent review comments in the meantime.

6. **Post the evaluation.** Reply to an inline thread. For a body-only finding, post a PR comment with its synthetic key, review, commit, and location. Include or link to the complete options, weighted rubric, scores, ASD-STE100 selection, references, tests, and implementation status or SHA. Before posting, verify that all required artifacts are present. End public adjudication with `Generated with Codex`. Prefer the plugin; use `gh` only for a missing capability.

7. **Implement the fix.** Apply the selected option locally, commit, and push to the agent's working branch using local `git`.

    **Protected-file authorization checkpoint.** Before creating, editing, deleting, renaming, or otherwise changing any protected instruction file, including a style guide under `.github/instructions/`, determine whether explicit protected-file authorization already covers that specific protected-file content change in the current task. Keep the selected option fixed while making this authorization determination; do not reopen option selection or ask the maintainer to choose among the scored options again merely because protected-file authorization is required.

    - If explicit protected-file authorization already covers the change and the edit stays within the already-authorized scope, proceed with the selected option under the placement rules below.
    - Otherwise, including when no explicit authorization exists, when the intended edit exceeds the already-authorized scope, or when the edit would newly introduce a protected file the PR did not previously modify, ask one narrow authorization question before editing. The question states the selected option, the protected file, the intended change, the agent's recommendation, and, when applicable, that the protected file is already in the PR's scope. Ask the question in the active Codex session when the owner is present; if the workflow is mediated through PR comments, post it as a standalone PR comment through the GitHub plugin and wait for the user to bring the maintainer's authorization back to the active Codex session.
    - If authorization is declined, record the decision and resolve or leave the review thread according to step 9.

    This checkpoint governs authorization to change protected-file content only. It does not restrict where an authorized fix lands. Use these placement rules:

    - **Outside an active automated review loop:** Push to the working branch only. State whether a merge or cherry-pick is required to make the fix visible on the PR head.
    - **During an active automated review loop:** Push directly to the PR head only when it is in the **same repository**, the remote head is an ancestor of the fix, the push is **non-destructive**, all repository controls remain satisfied, and no higher-priority instruction forbids it.

      **Standing placement authorization.** The documented active review loop supplies explicit authorization for direct PR-head placement when all conditions above hold. No additional per-round, per-session, or PR-specific direct-push authorization from the owner is required. The agent MUST NOT ask the owner for that additional authorization.

      **Outgoing-range audit.** Before the push, inspect the outgoing range from the fetched remote PR-head SHA through the fix once. Confirm that each commit and changed path belongs to the active task, and validate the exact tree. If the range contains unrelated work, construct a clean descendant of the fetched head that contains only authorized fixes, or use the safe fallback.

      Fetch the PR head and verify ancestry. Use an explicit non-force source-to-destination refspec; never use `--force` or a leading `+`. For API placement, record returned SHA(s); verify their chain from the fetched head contains only authorized changes and ends at the exact tested tree and modes. Use one authenticated readback to match the actual placed head. Use actual SHA(s) for reachability and review. Stop on mismatch; reconcile before retry. Use the safe fallback; never bypass policy. Record the mapping and result; no separate placement receipt.

8. **Evaluate style guide impact.** Determine whether the relevant language instruction file(s) under `.github/instructions/` should be updated to prevent the same issue in the future. **Read the full applicable style guide(s) before answering** so the recommendation accounts for what the guide already covers and does not duplicate or contradict existing rules. The protected-file authorization checkpoint in step 7 governs selected fixes that would directly change any protected instruction file, including a style guide under `.github/instructions/`. This step governs secondary style-guide recommendations. If such a secondary update is warranted, write a prompt in a Markdown code fence (suitable for sending to GitHub Copilot's coding agent) that describes the style-guide change. For an inline finding, post the prompt as a reply in the same review thread. For a review-body-only finding, post the prompt as a standalone PR-level comment that cites its synthetic key, source review, reviewed commit, and location when available. In either secondary-recommendation case, do **not** modify the style guide directly; if the maintainer later authorizes that change, handle it through the step-7 protected-file authorization checkpoint.

9. **Resolve or close.** Resolve an inline thread when no style-guide action remains. For a body-only finding, post implementation or refutation evidence and mark its synthetic key **closed**. Leave an item open only for a required style-guide or maintainer decision, and state why. If resolution tooling is absent, record manual closure work. For deferral, apply **Deferring Work**, cite the Issue, then close the review surface.

## Deferring Work

A deferral leaves real work for later; it is not a label for unfinished work.
Only genuine deferred work requires a GitHub Issue.

1. **Earn it.** Defer only when the full per-finding options and weighted rubric select deferral on the merits.
2. **Exclude worker limits.** Context, budget, turns, size, tedium, reviewer availability, and round end are not reasons to defer.
3. **Track it.** Before closure or merge, create and cite a GitHub Issue with the problem, rationale, trigger condition, scope, and origin link. PR text is not a replacement tracker.
4. **Name it correctly.** Deferred work is a future task; an **accepted residual or accepted risk** is bounded and accepted; an **intentional deviation or fail-closed choice** is deliberate behavior. Do not call the latter two pending work.
5. **Close after tracking.** Once the Issue exists, resolve the thread or close the synthetic key. Keep it open only for a required maintainer decision.
6. **Protect scope.** Deferring a governing requirement or PR commitment needs owner authorization.
7. **Sweep the whole PR.** Before clean or merge, inspect every review-submission body, every resolved or unresolved thread, every PR-level comment, and the PR body. Complete convenience deferrals, Issue-track genuine ones, and relabel residuals or deviations. No deferred work may live only in PR text.

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

## Automated Review Loop (User-Initiated)

When the owner asks for multiple rounds, use Copilot and remote Codex as co-equal reviewers while the local session stays active; never present the loop as autonomous.

1. **Gate readiness.** Verify fix commits on the PR head. Keep the PR body's scope, behavior, risks, commands, and results accurate. Read current head and base identities from authenticated GitHub and Git data. Do not require a generated identity block or copy file release labels into the body. Recheck any identity the body does claim.
2. **Baseline and request.** Per bot, record newest review, inline-comment, and PR-comment IDs and times plus head SHA. Request Copilot through the plugin or fallback. Post exact `@codex review`, read it back, and record its ID; do not rely on auto-review.
3. **Poll.** At intervals of at least 60 seconds, paginate authenticated review bodies, `reviewThreads`, and PR comments. Arrival requires a post-baseline event anchored to the recorded head. Stale, failed, or indeterminate observations do not count.
4. **Inventory.** Reconcile all declared counts, "generated N comment(s)", native thread IDs, and synthetic keys across both surfaces; `isResolved == false` selects only open work.
5. **Process.** Apply the per-finding workflow to both reviewers. Skip only closed IDs or keys. Record an unavailable reviewer explicitly; absence is not agreement.
6. **Decide clean state.** Require current-head clean reviews from both available reviewers, reconciled counts, resolved native threads, closed synthetic keys, and the **Deferring Work** sweep. State availability exceptions.
7. **Repeat after placement.** Re-request both reviewers only after fixes reach the PR head and readiness passes. Otherwise state the merge or cherry-pick needed and pause unless direct-push conditions apply. Sweep for sibling defects by property and mutation-test new assertions.

### Safety limits for the optional review cycle

When the optional review cycle is used, retain these finite safety limits:

- **Maximum rounds:** 8 review iterations per cycle invocation. After the eighth round, PAUSE and ask the user to confirm whether to continue.
- **Wall-clock timeout:** 6 hours from cycle start. If the timeout is reached, PAUSE and ask the user to confirm whether to continue.
- **Duplicate-finding skipping:** Track native thread IDs and review-body synthetic keys. Skip only findings whose closure evidence exists.

### Fallbacks for unsupported plugin capabilities

When a workflow step depends on a capability the GitHub plugin does not currently expose, use the following fallbacks and document the chosen fallback in the relevant reply or PR comment:

| Capability | Primary | Fallback |
| --- | --- | --- |
| Request a Copilot code review | GitHub plugin | `gh pr edit --add-reviewer '@copilot'`, `gh api`, or ask the owner to request the review manually |
| Request a remote Codex review | GitHub PR comment with body `@codex review` | `gh api` to create the comment, or ask the owner to post the exact trigger |
| Resolve a review thread | GitHub plugin | `gh api graphql` against the `resolveReviewThread` mutation, or ask the owner to resolve the thread manually |
| Add a reaction on a review comment | GitHub plugin | `gh api -X POST /repos/{owner}/{repo}/pulls/comments/{comment_id}/reactions -f content=eyes`, or skip silently if neither path is available |
| Remove a reaction on a review comment | GitHub plugin | First list the comment's reactions via `gh api /repos/{owner}/{repo}/pulls/comments/{comment_id}/reactions` and find the reaction whose `content` matches the one to remove (e.g. `eyes`) and whose `user.login` is the agent's own identity; then delete by reaction id via `gh api -X DELETE /repos/{owner}/{repo}/pulls/comments/{comment_id}/reactions/{reaction_id}`. Skip silently if neither path is available |
| Post a reply to a review comment thread | GitHub plugin | `gh api` against `/repos/{owner}/{repo}/pulls/{pr}/comments/{comment_id}/replies`, or post a standalone PR comment that quotes the original review comment |

If the primary capability and all listed fallbacks are unavailable in the current runtime, skip the step, note the limitation in the relevant reply, and continue rather than failing the workflow.

---

> This file is the Codex entry point for PSStyleGuide. The repository's generated consumer documentation remains derived from `STYLE_GUIDE.md`.
