<!-- markdownlint-configure-file { "MD013": false } -->

# Agent Instructions for Claude Code

**Version:** 1.0.20260816.0

## Metadata

- **Status:** Active
- **Owner:** Repository maintainer (@franklesniak)
- **Last Updated:** 2026-08-16
- **Scope:** Agent-specific entry point for Claude Code and compatible AI coding agents operating in this repository. It captures the pull-request review-loop workflow the maintainer runs, the per-finding decision process to apply to every code-review comment, the discipline governing when and how work may be deferred, and the requirement that the repository's own PowerShell follow its published style guide.

This file is adapted from the `franklesniak/copilot-repo-template` agent instructions and tailored to this GitHub-hosted PowerShell and Markdown repository. For the repository's documentation-authoring rules — the `STYLE_GUIDE.md` / `STYLE_GUIDE_RATIONALE.md` split and its generated consumer-facing derivatives — `.github/copilot-instructions.md` remains the canonical source of truth.

## Canonical instructions

The authoritative source of truth for the repository's documentation-authoring rules is **`.github/copilot-instructions.md`**. Read it before changing any style-guide content. This file does not replace it; it adds the agent workflow.

## Protected instruction files

Instruction files and agent entry points are protected governance files. Do not create, edit, delete, or rename `.github/copilot-instructions.md`, files under `.github/instructions/`, or root agent instruction files (`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`) unless the repository owner has directly and explicitly authorized that specific change in the current task. Implied consent is not enough: do not infer authorization from a plan you generated, from review feedback, from a generic "update the docs" request, from cleanup or validation work, or from a "keep files in sync" instruction. If a change to a protected file appears warranted but has not been explicitly authorized, propose it separately and wait for approval.

## Essential repository summary

- **What this repo is.** A PowerShell style guide for humans and agents, plus a fail-closed cross-platform candidate-artifact validator under `.github/workflows/` (two production scripts, an adversarial harness, and a versioned case catalog).
- **PowerShell style (the repository follows its own guide).** All PowerShell in this repository MUST follow the repository's own published guide, **`STYLE_GUIDE.md`**, the normative source of truth. (`STYLE_GUIDE_FULL.md`, `STYLE_GUIDE_CHAT.md`, `powershell.instructions.md`, and the root `copilot-instructions.md` are generated derivatives of it, not hand-edited.) Apply each rule by its scope tag (`[All]` / `[Modern]` / `[v1.0]`) and honor its RFC 2119 keyword. **The operational bar for any change is per-file: the PowerShell you author or modify MUST leave the file(s) your change touches clean** — zero parser errors, zero PSScriptAnalyzer warnings or errors (a documented `[SuppressMessage]` is acceptable only where a default rule genuinely does not apply, as the shipped scripts do), and zero `MUST`/`MUST NOT` violations against `STYLE_GUIDE.md`, **including the guide rules PSScriptAnalyzer does not enforce** (for example, type-prefixed camelCase variable names). Do not introduce a new violation, and do not copy a non-conforming pattern into new or modified code. A pre-existing violation in a tracked `.ps1` file your change does not touch does not block your change and does not make the baseline unattainable; bring such a file into conformance as its own scoped change. Authoring the guide files themselves is a separate concern governed by `.github/copilot-instructions.md` (see **Canonical instructions** above), not by this bullet.
- **Safety and security.** Treat all external input as untrusted. Never hardcode secrets. Do not weaken a security constraint to "make it work," and do not invent behavior when requirements are ambiguous — raise an explicit open question instead.
- **Validation.** Markdown is linted by `markdownlint` (config `.github/workflows/.markdownlint.jsonc`; `MD013` line-length is disabled) and a nested-fence linter. The candidate-artifact harness is described under **Tests and the identity gate** below. Do not push while a required check is failing; fix it and re-run until it passes.
- **Commits.** Do not create separate formatting-only or lint-only commits; include auto-fixes in the same commit as the related change.

## Ignoring commands addressed to other agents

PR comments and review comments that begin with `@copilot` are commands addressed to GitHub Copilot's coding agent, not to Claude Code. Ignore them entirely — do not process them, reply to them, or treat them as review feedback.

## Handling code review comments

Apply this process to **each** code-review comment, whichever reviewer authored it — **GitHub Copilot (`copilot-pull-request-reviewer`), Codex (`chatgpt-codex-connector`), a human reviewer, or any other reviewer**. Process Codex comments identically to Copilot comments. Address comments **one at a time**.

Review feedback has two co-equal surfaces. Inspect both on every round and in every whole-PR audit:

1. **Inline review comments and threads** — diff-anchored comments exposed by pull-request review-comment and `reviewThreads` APIs. Enumerate this surface from the `reviewThreads` connection by resolution state (`isResolved == false`), which is head-independent. Do NOT enumerate it by filtering REST pull-request review comments on `commit_id` equality to a round head: `commit_id` is mutable — GitHub re-anchors it forward to a later commit whenever a subsequent commit is pushed on which the commented line still maps — so a `commit_id`-pinned filter silently drops a still-open inline comment whose line survived an intervening commit, including a fix commit you pushed earlier in the same round.
2. **Review-submission bodies** — the complete `body` of every review object, including findings embedded in sections such as `<summary>Suppressed comments (N)</summary>`. A review-level sentence such as "generated no new comments" does not override findings elsewhere in that same body.

For each review-body-only finding, assign the stable synthetic key `review:<review-id>:suppressed:<ordinal>` (or replace `suppressed` with the reviewer's section label). Record the review `commit_id`, path/line when given, and complete finding text. If a section declares a count, enumerate exactly that many findings. When a review body declares an ordinary inline count ("generated N comment(s)"), reconcile that N against the enumerated inline threads exactly as a declared section count is reconciled; an inline comment the body counts but the inventory does not enumerate is a fail-closed audit error, not a clean round. A count mismatch, malformed section, truncated body, or ambiguous boundary is a fail-closed audit error: do not declare the review or PR clean until the inventory is complete.

"Handled" depends on the feedback surface:

- An inline thread is handled only when it is both **answered and resolved**.
- A review-body-only finding has no native thread to resolve. It is handled only when a PR-level comment cites its synthetic key and source review, contains the required evaluation, and a later PR-level comment records implementation or refutation evidence and marks that key **closed**. Never describe a synthetic finding as natively resolved.

Treat address-and-close as one unit of work, not two optional halves. Maintain an inventory of every native thread ID and synthetic key; a missing or open item blocks clean state.

Steps 2 through 5 are **mandatory for every finding that survives step 1 as real**, whatever becomes of it. A fix you implement now, a deferral, and a recommendation the owner must act on (a protected-file change, a scope decision) all get the same options, rubric, scoring table, and selection. **The rigor is independent of who implements the fix, or whether you can implement it at all.** A recommendation the owner reads deserves *more* care than a change you make yourself, not less: the owner relies on your rubric and table to decide. A finding's outcome never shrinks its analysis — and neither do your context, budget, or turns remaining (see **Deferring work**, rule 2).

**1. Validate the feedback.** Determine whether the comment represents a material opportunity for improvement, and/or confirm that any bug it points out is real — reproduce it where it can be reproduced. A finding that turns out to be false is **refuted with evidence, not accommodated**: say so in a reply, with the evidence, then skip to resolving the thread. Do not assume that because a line changed, or because the comment is marked "outdated," the issue is gone — check whether it still applies against the current code.

**2. List the options — exhaustively.** Think hard about every materially distinct way to address the finding. Be exhaustive, and where applicable consider **permutations and combinations** of options, not only mutually exclusive base options. Generate options from **multiple perspectives** — a senior software engineer, a new developer, a DevOps expert, a documentation expert, a project manager, a cybersecurity executive, a cybersecurity technical expert, a business stakeholder, and any other role that would see the problem differently. Do **primary-source Internet research** as needed to bolster the options and confirm correctness (for example, language, framework, cloud-provider, API, or tooling documentation); link and explain any research you rely on in a `References` section of the reply.

> **Gate:** you must list the options before continuing — in chat or in the reply to the reviewer's comment.

**3. Build a fresh evaluation rubric.** Develop a rubric to score the options and determine which is best. **Do not reuse a rubric across different findings** — each finding gets its own. Derive the criteria and their weights from the same range of perspectives used above. Weigh criteria such as **amount of churn**, **difficulty to implement**, and **adherence to the original issue scope** *lower* than criteria such as **technical correctness** and legitimate usability considerations — those first three tend to bias a rubric toward minimal, status-quo-preserving options even when a substantively better option exists. Score every criterion on one common scale (for example 1-5) and show the weights so the computation is auditable.

> **Gate:** you must describe the rubric in detail before continuing — in chat or in the reply.

**4. Apply the rubric and show the scores.** Score every option against every criterion and present the results in a Markdown table, including each option's weighted total.

> **Gate:** you must show the scoring table before continuing — in chat or in the reply.

**5. Select the best option.** Use the table to pick the winner. State the selected option in detail — **idiot-proof**, so that someone **coming in cold** understands exactly what needs to be done. Ensure that when you state the selected option in detail, your response follows `ASD-STE100`. Include relevant primary-source references and, where applicable, **local testing information**: environment details, the commands or tests run, and the specific, detailed results of those runs. Where the winner is close to a runner-up, say so and say what separated them; where an option is disqualified on substance rather than score, say that too.

> **Gate:** you must state the selected option before continuing — in chat or in the reply.

**6. Post the evaluation.** For an inline finding, reply on its review thread. For a review-body-only finding, post a PR-level comment that cites its synthetic key, review ID/URL, reviewed commit, and path/line when available. Include the options, rubric, scoring table, selected option, `References` section (when research informed the decision), and either a note that implementation follows or the commit SHA that implements it. End every reply with the Claude Code attribution footer. Before posting, verify the reply actually contains all four artifacts — **options, rubric, scoring table, and selected option** — for any finding that survived step 1; a reply missing any of them is incomplete whatever the finding's outcome, so complete it before posting.

**7. Implement the solution.** Apply the selected option, commit, and make the change visible on the PR (reachable from the PR's head ref). If implementation reveals the selected option is wrong or unworkable, say so plainly, state what changed, and re-select — do not quietly substitute a different approach. Before changing any **protected instruction file** to satisfy a comment, confirm explicit owner authorization for that specific change (per **Protected instruction files**); if it is not covered, ask one narrow authorization question before editing, keeping the selected option fixed while you do.

**8. Evaluate style-guide impact.** Consider whether the relevant instruction file(s) should be updated to prevent the same class of issue in the future. Read the applicable guide first so the recommendation does not duplicate or contradict existing rules. If a change is warranted, recommend it separately (a protected-file change needs explicit owner authorization); do not edit the guide directly without that authorization.

**9. Close the finding.** Mark an inline thread resolved once the reply is posted. For a review-body-only finding, post the implementation/refutation evidence as a PR-level comment, cite the synthetic key, and mark it **closed** in the inventory; GitHub supplies no thread resolution control for it. An addressed-but-open item hides real state — a reader cannot tell a handled finding from an open one. The one exception: a finding that genuinely needs a maintainer's decision you should not make on their behalf (or a step-8 style-guide recommendation the owner must see first) — in that case, say so explicitly and leave the native thread or synthetic key open. That exception governs **closure only** and never exempts steps 2-5. When the selected option is to **defer** the work, that is not one of those cases: follow **Deferring work** below, open the tracking issue, reference it in the reply, and close the native thread or synthetic key.

When asked to take a PR to a clean review state, apply this to **every** open native thread and every open or previously uninventoried review-body finding on the PR, not only the most recent ones.

## Deferring work

When the analysis of a finding, a self-found gap, or a task concludes that the work should not be done now, that is a **deferral**. A deferral is a deliberate decision with a high bar — never a fallback for work that is simply unfinished. Apply this whichever way the item arose: a reviewer's comment, something you found yourself, or a "known gap" you are tempted to write into a PR description.

**1. Deferral must be earned, not assumed.** A deferral is legitimate only when the full decision process — validate the finding, list the options exhaustively, build a fresh rubric, score, and select — has been run and has **concluded, on the merits, that deferring is the best option**. Deferral is a conclusion of that analysis, never its starting point.

**2. These are never reasons to defer.** Do not defer because you (the agent) are low on context, budget, or turns; because the change is large or tedious; because a reviewer or another agent might catch it later; or because a review round or the loop is ending. None of these bear on whether the work should be done — they are facts about the worker, not the work. If one of them is the real reason, the honest move is to do the work, or to state plainly that it is unfinished and why — not to relabel it "deferred."

**3. Genuinely deferred work is tracked in a GitHub issue.** A PR description, a review-thread reply, or a "Known gaps" list is not a tracker: it disappears from view the moment the PR merges. Any work the analysis genuinely defers **must** be captured in a GitHub issue before the thread or PR that raised it is resolved or merged. The issue states the problem, why it was deferred (the analysis conclusion, in brief), the condition that should reopen or trigger it, the scope it touches, and a link back to the originating PR or thread. Issue #154 is the model — a self-contained, reopen-conditioned record that outlives the PR. The originating PR text links the issue, so a reader of the merged history can always find the open work.

**4. Distinguish a deferral from a residual or a deviation.** Not everything left unfinished is deferred work, and calling all three "deferred" hides the items that genuinely are:

- **Deferred work** — a real future task the analysis chose not to do now. Track it in a GitHub issue, per rule 3.
- **Accepted residual / accepted risk** — a limitation that is understood, bounded, and knowingly accepted, often because no portable mechanism can close it. Document it at the code and in the PR as an accepted residual with its bound; it is not a perpetually open thread, and not "deferred."
- **Intentional deviation / fail-closed choice** — behavior deliberately chosen (for example, refusing rather than degrading). Record it as a flagged deviation; it is not a gap at all.

Say which of the three a thing is, in those terms. Do not write "deferred" or "deliberately left open" over a residual or a deviation — that language asserts pending work exists when it does not.

**5. Do not leave a review thread open as a stand-in for a tracker.** Per **Handling code review comments** step 9, resolve the thread. If the finding is genuinely deferred, open the issue (rule 3), reference it in the reply, and resolve the thread — the issue, not the thread, carries the work forward. Leaving a thread open is only for the case step 9 names: a decision that is genuinely the maintainer's to make.

**6. A scope-reducing deferral needs owner authorization.** If deferring would drop something the governing issue or contract required — for example, narrowing a scope that issue #146 fixed — that is a scope change. Raise it explicitly and get the owner's decision, exactly as a protected-file or scope change would. Do not absorb a required item into a "Known gaps" list on your own authority.

**7. Before a PR is taken clean or merged, sweep for stranded deferrals.** A per-finding deferral decision (rules 1-6) only governs the finding in front of you at the time. It does not catch work that an earlier round — or a moment when an agent was low on context, budget, or turns — pushed into a comment and walked away from. That stranded work is exactly what disappears when the PR merges. So before you declare a PR terminally clean or merge it, **sweep every review submission body, every review thread (resolved or not), every PR-level comment, and the PR body** for deferred-work language ("defer," "follow-up," "future," "later," "TODO," "known gap," "left open," "being added," "will be added," and the like). Re-evaluate each item you find against this section — **whoever deferred it and whenever, including deferrals you did not create**:

- If it was deferred for a **worker-fact** — the agent's context, budget, turns, or the size or tedium of the change (rule 2) — it was never a legitimate deferral. **Complete it now, in this PR.**
- If it is **genuinely deferred** (rule-1-earned, on the merits), it must live in a **GitHub issue** (rule 3) that the PR cites. If no such issue exists, open it and cite it *before* proceeding — a review comment or a "Known gaps" bullet is not a tracker (rule 5).
- If it is really an **accepted residual** or an **intentional deviation** (rule 4), relabel it in those terms — do not leave "deferred" or "deliberately left open" language asserting pending work that does not exist.

The sweep's guarantee is exact: when the PR is declared clean or merged, **no deferred work is left living only in a comment** — every item is either done in this PR or tracked in a cited issue. Run this sweep as a distinct pass, not as a side effect of processing the latest round's comments; the deferrals most likely to be lost are the oldest ones.

## Automated review loop

Run this loop when asked to review a pull request (for example, "start the review loop"). It drives the PR through repeated review rounds using **both** automated reviewers.

### Reviewers

Treat **GitHub Copilot (`copilot-pull-request-reviewer`) and Codex (`chatgpt-codex-connector`) as co-equal reviewers.** Each round, obtain a fresh review from both:

- **Copilot:** request it explicitly with `request_copilot_review` (or equivalent).
- **Codex:** request it explicitly every round by posting a pull-request comment whose body is exactly `@codex review`. There is no dedicated review-request tool for Codex the way `request_copilot_review` exists for Copilot, so post the comment with the ordinary issue-comment tool (for example `add_issue_comment` or equivalent). Codex also auto-reviews when a pull request is opened for review or a draft is marked ready, but that auto-trigger is not reliable enough to depend on — always post the explicit `@codex review` request so a Codex review is actually obtained for the round.

If a reviewer cannot read the diff (Copilot has a size limit and may return "wasn't able to review any files") or is otherwise non-functional, note that in a PR comment and continue with the reviewer(s) that are working — but the loop is not "clean" on the strength of a reviewer that never actually reviewed.

### Round procedure

1. Establish a **review-readiness gate** before requesting either reviewer. Confirm the fix commit is reachable from the PR head. Update the PR body to the exact current head/tree, versions, identities, commands, and results that it claims. Read the body and head back through the API and compare them with the committed files. Do not request review while the body is stale or while identity evidence is incomplete.
2. Record detection baselines (the newest existing review-submission ID/time, inline-comment ID/time, and PR-comment ID/time for each bot) and the current PR head SHA, then request the reviews: request Copilot with `request_copilot_review` (or equivalent), and request Codex by posting an `@codex review` pull-request comment. Do not rely on Codex's auto-trigger to stand in for this explicit request.
3. Wait for the reviews by **active polling** — do not rely on webhook delivery alone. Poll at least every 60 seconds using authenticated structured tooling, paginating the complete review submissions **with their bodies**, inline review comments/threads, and PR-level comments. A new round has arrived for a reviewer only when that reviewer posts a review or comment newer than its baseline and the review/comment is explicitly anchored to the recorded head SHA. A stale verdict never counts toward arrival or clean state.
4. Inventory all feedback surfaces. Parse every new review body, including each suppressed/advisory section, and verify any declared item count. Reconcile the resulting synthetic keys with inline comments to avoid duplicates without dropping either surface.
5. Process every actionable inline and review-body finding from **both** reviewers via **Handling code review comments** above (validate → options → rubric → score → select → post → implement → style-guide → close). Track native comment/thread IDs and synthetic keys; skip only items whose closure evidence already exists.
6. Re-request review once the round's fix commits are reachable from the PR head and the review-readiness gate passes again, then repeat.

### Exit condition and round cap

- **Clean only when BOTH reviewers agree and every surface is closed.** The loop is clean only when **both Copilot and Codex return a review anchored to the current head SHA with no actionable inline or review-body findings**, every declared review-body count is reconciled, every native thread is resolved, and every synthetic key is closed with evidence. A review sentence such as "generated no new comments" is not a clean result when its body contains a suppressed/advisory finding. A stale verdict never counts; a reviewer that genuinely cannot read the diff (per **Reviewers**) is recorded non-functional and excepted. When both reviewers and all feedback surfaces are clean, stop and report the terminal-clean state.
- **Deferred-work sweep before clean.** Before declaring the loop terminally clean, run the **Deferring work** rule-7 sweep across the whole PR. A PR is not clean while deferred work sits untracked in a comment or a PR-body bullet: complete convenience-deferrals in this PR, and open and cite a GitHub issue for any genuine deferral, before you call the loop clean.
- **Round cap: 80.** Run up to **80 rounds** per invocation. If 80 rounds are reached before both reviewers are clean, pause and report where things stand rather than continuing silently.

### Discipline

- Before re-requesting, confirm the round's fix commits are reachable from the PR head. If a fix landed on a development branch that is not the PR head, make it visible on the PR head (or state the merge or cherry-pick needed) before re-requesting.
- Almost every defect this kind of loop finds is in work from a preceding round, or in the machinery meant to guard it. When you close a defect, sweep for its siblings by **property**, not by the exact spelling of the previous fix, and **mutation-test** every new assertion (prove it fails when the check it guards is removed) before trusting it.

## Tests and the identity gate

The candidate-artifact validator ships with an adversarial harness, `.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1`, which authenticates the two production scripts by their git-blob identity before it runs. **Commit your change before running the harness**, or the identity gate will refuse the modified working tree.
