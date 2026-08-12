<!-- markdownlint-disable-file MD013 -->
<!-- markdownlint-configure-file { "MD024": { "siblings_only": true } } -->

# Chronological PSStyleGuide-first cross-repository convergence plan

## Purpose

Complete the remaining PSStyleGuide and TerraformStyleGuide convergence work in one clear execution order. PS P1 ([issue #145](https://github.com/franklesniak/PSStyleGuide/issues/145)) and P1A ([issue #146](https://github.com/franklesniak/PSStyleGuide/issues/146)) are complete. Draft PR #164 already contains the PS #160 candidate, so the first active task is its Anthropic Claude Code review loop.

This report contains only numbered leaf tasks. A numbered task has one executor and one completion result. Phase headings provide context but are not tasks. Execute tasks in number order unless a dependency table or the fixed advisory checkpoint states otherwise.

Keep both repositories self-contained. Do not add a shared runtime module, reusable cross-repository workflow, submodule, package, runtime fetch from the other repository, or third source of truth.

## How to use this report

- Start only one feature implementation issue or PR at a time.
- Issue setup, tracker updates, dependency edits, and read-only comparisons do not use the implementation slot.
- A settings operation does not use the implementation slot, but it requires exact administrator authorization.
- Task 43 can start after Task 42 starts because it has an `SS` relationship.
- Task 70 runs at `2026-08-21T23:59:59Z`. This calendar constraint overrides the numeric order if earlier tasks are late.
- A conditional task is skipped only when its stated condition is false. Record the non-applicability result.
- Do not start a later numbered implementation task until the current reciprocal cycle reaches a fixed point.

## Execution classes

- **Coding agent executable:** A coding agent can complete the task with the specified tools and authority. A stated human approval remains a required input.
- **Human execution required:** A repository owner or administrator must make or approve the decision. A coding agent can prepare evidence or a draft. It cannot give the approval.

No numbered task is classified as not executable. The prior plan's non-executable parent controls are now unnumbered rules, and each required action or closure is a separate executable task. Therefore, do not ignore review, quality-check, evidence-publication, tracker-closure, trigger-check, or final-audit tasks. Tasks 18, 25, 32, 38, 39, 41, 43, 70, 90, and 93 are examples of required tasks that do not normally change implementation bytes.

## Execution-order map

| Task range | Ordered result |
| --- | --- |
| 1–5 | Review, quality-check, merge, and reciprocally close PR #164 and PS #160. |
| 6–11 | Implement, review, quality-check, merge, and reciprocally close PS #161. |
| 12–18 | Implement, review, quality-check, merge, and reciprocally close PS #162; post the interim handoff. |
| 19–25 | Implement, review, quality-check, merge, and reciprocally close PS #158; close PS #159. |
| 26–32 | Implement, review, quality-check, merge, and reciprocally close PS #163; close Terraform #31. |
| 33–38 | Implement, review, quality-check, merge, and reciprocally close Terraform #21. |
| 39–41 | Inventory and close all untracked cross-repository blockers. |
| 42–55 | Prepare, review, quality-check, approve, prove, land, and reciprocally close P1B/T1B. |
| 56–61 | Implement, review, quality-check, merge, and close the PS #148 applicability cycle. |
| 62–66 | Implement, review, quality-check, merge, and close Terraform #23 and its PS applicability result. |
| 67–76 | Prepare and review PS #149, make the fixed-date decision, process an approved fallback, and land P3. |
| 77–83 | Implement, review, quality-check, merge, and reciprocally close Terraform #24. |
| 84–89 | Implement, review, quality-check, merge, and close the PS #151 applicability cycle. |
| 90–92 | Check independent residual triggers, close triggered work, and run later paired cycles when applicable. |
| 93 | Publish the final completion audit. |

Task 70 is the only calendar override. If `2026-08-21T23:59:59Z` arrives before Task 69 finishes, run Task 70 at that time, record the incomplete state, and then resume the numbered sequence under the Task 71 decision.

## Dependency relationships

| Code | Relationship | Meaning |
| --- | --- | --- |
| `FS` | Finish-to-start | The predecessor must finish before the successor starts. |
| `FF` | Finish-to-finish | The successor cannot finish before the predecessor finishes. |
| `SS` | Start-to-start | The successor cannot start before the predecessor starts. |
| `SF` | Start-to-finish | The predecessor cannot finish before the successor starts. |

The executable graph primarily uses `FS`. Task 43 uses `SS` because read-only settings preparation can overlap candidate preparation. The slate contains no legitimate `SF` relationship. Do not invent one.

The old tracker closures were `FF` conditions. This report removes the ambiguity by making each final tracker closure a separate task:

- Task 25 closes PS #159 after cycle 4 finishes (`FS`).
- Task 32 closes Terraform #31 after cycle 5 finishes (`FS`).

## Target common foundation

The final PS canonical implementation and synchronized Terraform implementation must share these behaviors:

- fixed repository-root and destination authority;
- complete-payload, BOM-less UTF-8 and LF serialization;
- fresh same-directory candidate creation, durable flush, byte verification, and single-call publication without direct destination truncation;
- `File.Replace` for an existing ordinary tracked destination;
- non-overwriting same-directory `File.Move` for an absent index-tracked destination;
- a closed result that distinguishes pre-publication failure from `ReplacementStateUncertain`;
- no rollback claim after `File.Replace` or `File.Move` returns;
- reusable raw NUL-delimited Git path and status validation with exact native-status handling;
- no JavaScript action in a job that runs repository-controlled code;
- `permissions: {}` on repository-code jobs;
- a separate action-only job for artifact publication;
- a verified official Node distribution in action-free Node jobs;
- strict offline workflow-policy parsing and fixtures;
- machine-readable authority for roles, inputs, defaults, supply identities, and case allocation;
- read-only supply-freeze recording with a reproducible method;
- the same script-version grammar and PowerShell authoring rules; and
- no workflow writer before P1B/T1B explicitly introduces and proves it.

Use this closed reciprocal catalog for every foundation comparison:

| Stable row | Required comparison |
| --- | --- |
| `GF-PARAMETERS` | Public names, types, defaults, and omission, null, empty, and raw-value rules |
| `GF-DESTINATION` | Trusted root, fixed destinations, provider, wildcard, rooted-path, normalization, comparison, and failure rules |
| `GF-CONTENT` | Source order, wrappers, frontmatter, repository-specific names, and complete payload |
| `GF-SERIALIZATION` | CRLF and lone-CR normalization, LF and final-newline rules, BOM-less UTF-8, and byte checks |
| `GF-WRITE` | Complete-payload candidate creation, durable flush, verification, single-call publication, and prohibited fallbacks |
| `GF-FAILURE` | Phase postconditions, cleanup and uncertainty, bounded diagnostics, and fault cases |
| `GF-HOSTS` | Supported editions and hosts, executable identity, cross-cell equality, and idempotence |
| `GF-VERSION` | Timeless marker grammar, trusted expected version, authoring progression, and independent fixtures |
| `GF-NODE-LOCK` | Exact Node/npm producer and provenance, distribution verification, cache and side effects, dependency graph, and frozen consumers |
| `GF-YAML` | Parser package and API, document and schema strictness, diagnostics, and forbidden features |
| `GF-ACTION-PINS` | Closed action roles, full commit pins, provenance, runtime, and atomic pin updates |
| `GF-ACTION-INPUTS` | Authored security inputs and separately reviewed manifest defaults |
| `GF-GIT` | NUL records, byte allowlists, native statuses, cardinality, refs, ancestry, lease, and refspec |
| `GF-GRAPH` | Production and evidence triggers, permissions, needs, conditions, outputs, side effects, and sole writer |
| `GF-CREDENTIALS` | Job-token availability, authentication projection, cleanup, push-only materialization, and absence proofs |
| `GF-EVIDENCE` | Temporary workflow/ref structural equality, drills, retained identities, cleanup, and final absence |

Each applicable row occurs exactly once. Record both repository URLs and commits, normative and implementation locators, evidence paths and SHA-256 values, observed values or fixture IDs, the status, and a reason. Prove omitted rows inapplicable for a narrow non-foundation capability. Duplicate, missing, unknown, renamed, empty, or unexplained rows block closure.

## Verified baseline

This state was verified at `2026-08-12T21:58:28Z`. Re-query GitHub and fetch both `origin/main` refs immediately before each state-changing action.

### Completed foundations and coordination

- PS P1 issue #145 is closed through PR #150 at `3b611fd47a8eb9b24248715be7df97b0f3115e6b`.
- PS P1A issue #146 is closed through PR #153 at `2d56357d9f52c76734027174bf62278e6f3d4cd6`, tree `46f5f4e8627eb341ddc4ef0c8d52483dc4006b50`.
- Terraform T1 issue #20 is closed through PR #26 at `143f54e52075a1ae1e999a6e242073e3d8d4a46b`.
- Terraform PR #27 landed at `aae05282b57f093cec8b63e59138db72c982f10e`.
- Terraform PR #30 landed at `fbfc3aca874e235cace92f506377f5c9e0704160`, tree `3c6e54be9d722b8f61aa225b1414f228f7531268`.
- The dependency clarification is on [PS #147](https://github.com/franklesniak/PSStyleGuide/issues/147#issuecomment-5262751210). It keeps PS #155 and #156 independent.
- The permanent P1A-to-P1B handoff is on [PS #147](https://github.com/franklesniak/PSStyleGuide/issues/147#issuecomment-5262865571).
- PS #152 contains the Terraform PR #29 bypass-eligibility finding and limited 2026-08-01 approval scope.
- PS #152 is blocked only by closed PS #146 and remains an open blocker for PS #147.
- Terraform #21 pins the landed PS P1A source, its four source blobs, and exactly four affected paths.
- The native PS chain is [#147](https://github.com/franklesniak/PSStyleGuide/issues/147) → [#148](https://github.com/franklesniak/PSStyleGuide/issues/148) → [#149](https://github.com/franklesniak/PSStyleGuide/issues/149) → [#151](https://github.com/franklesniak/PSStyleGuide/issues/151).
- The native Terraform chain is [#21](https://github.com/franklesniak/TerraformStyleGuide/issues/21) → [#22](https://github.com/franklesniak/TerraformStyleGuide/issues/22) → [#23](https://github.com/franklesniak/TerraformStyleGuide/issues/23) → [#24](https://github.com/franklesniak/TerraformStyleGuide/issues/24).

### Current active work

[PS PR #164](https://github.com/franklesniak/PSStyleGuide/pull/164) is the only active feature implementation PR. It closes PS #160 when merged. Its base is `2d56357d9f52c76734027174bf62278e6f3d4cd6`. Its head is `1e35e9b50045cca8946c97070109e3c9fc38c804`, tree `33937c64d45b20769cf80d1036fa9ffbf4077ebe`. It is open, draft, mergeable, and clean. Its `verify_generated_artifacts` and `markdownlint` checks pass. It is not a landed baseline.

### Immutable implementation sources

| Role | Commit | Tree or relevant identity |
| --- | --- | --- |
| PS P1 implementation, PR #150 | `3b611fd47a8eb9b24248715be7df97b0f3115e6b` | Landed PS #145 implementation |
| Current PS `main`, PR #153 | `2d56357d9f52c76734027174bf62278e6f3d4cd6` | `46f5f4e8627eb341ddc4ef0c8d52483dc4006b50` |
| Terraform T1 implementation, PR #26 | `143f54e52075a1ae1e999a6e242073e3d8d4a46b` | Landed Terraform #20 implementation |
| Terraform supply-freeze method, PR #27 | `aae05282b57f093cec8b63e59138db72c982f10e` | `.github/workflows/Get-SupplyFreezeDigest.mjs` blob `05778c0eda0273a9217f7dc953795c2240473a14`; `docs/T1-SUPPLY-FREEZE-v1.md` blob `36010d2dac98631845d8e880689f7c315ccbcdb7` |
| Current Terraform `main`, PR #30 | `fbfc3aca874e235cace92f506377f5c9e0704160` | `3c6e54be9d722b8f61aa225b1414f228f7531268` |
| Original PS conformance source | `904df87c24abb4abcb44d2a71859c0589b82c167` | Original three-path patch based on PS PR #150 |
| PS conformance candidate, PR #164 | `1e35e9b50045cca8946c97070109e3c9fc38c804` | Draft tree `33937c64d45b20769cf80d1036fa9ffbf4077ebe`; not landed |

### Current convergence inventory

These files already have identical Git blobs in both repositories. Do not rewrite them only to prove parity:

- `.gitattributes`;
- `.github/dependabot.yml`;
- `.github/workflows/.markdownlint.jsonc`;
- `.github/workflows/lint-nested-markdown.js`;
- `.github/workflows/MARKDOWN-LINTING-IMPLEMENTATION.md`; and
- `.github/workflows/scripts-README.md`.

| Area | PS source | Terraform source | Required disposition |
| --- | --- | --- | --- |
| Generator | `Generate-StyleGuideArtifacts.ps1` blob `c54012e549aedef827ae3ccb669b512a1f14c644` | Same path, blob `e5bdd8f64569541eb3c724387dfdff1847c18793` | Build one best-of-both PS contract, then sync Terraform in the same cycle. |
| Git/worktree checks | Reusable `Test-ExactGitPathSet.ps1` blob `dc786aed1bd8c9d3bdcb25c6ea79207fc1d63c1b` | Embedded in `build.yml` and the policy validator | Keep the reusable PS tool and add every stronger applicable Terraform check. |
| Build topology | `build.yml` blob `208a8b492c1f32e02c0731449db95890b256fc51` | `build.yml` blob `f68dfe2da4842d2086b079e09328e3298856123e` | Adopt action-free repository-code jobs and an action-only publish boundary. |
| Markdown topology | `markdownlint.yml` blob `4afa4f3aba03ffe3796ca72223cb0ebe26c8f34a` | `markdownlint.yml` blob `6a64b2a3b5b737bb7f69dc971b1b21b298013ab0` | Adopt separate action-free policy and lint jobs with verified Node acquisition. |
| Workflow policy | Validator `00263451aa8287a36ad0694143d96741c4cdd1f9`; contract `36374dbf88cb280126f780052e5d860ec96af9a7`; cases `252423934501a1a5ffa7a9d33ea0f001b4068d11` | Validator `fb17e06f2f456a0d7df510b0bb34c52d88b7893b` | Preserve PS machine authority and add every applicable Terraform invariant and negative case. |
| Supply-freeze method | No recorder or method | PR #27 recorder and method | Complete PS #158 after the policy contract stabilizes. |
| PowerShell conformance | Draft PR #164 | Landed PR #30 | Land PR #164, then close its reciprocal cycle. |
| Husky preparation | `install-husky.mjs` and PS-specific `prepare` | Direct `husky` command with accepted failure | Reconcile through PS #149 and Terraform #24. |
| Decision records | PS trust-root and provenance records | Terraform writer and required-check records | Preserve history. Compare active residuals; do not copy records by filename. |

## Chronological task slate

## Task 1 — run the Anthropic Claude Code review loop on PR #164

> **Execution class: Coding agent executable by Anthropic Claude Code.** PR #164 is the current active candidate.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| None | — | PR #164 already exists, has no open native blocker, and has successful initial checks. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Objective

Take PR #164 through the mandatory Anthropic Claude Code review loop. Do not merge it.

### Immutable inputs and affected paths

- Pre-rebase head: `904df87c24abb4abcb44d2a71859c0589b82c167`.
- Original base: `3b611fd47a8eb9b24248715be7df97b0f3115e6b`.
- Current base: `2d56357d9f52c76734027174bf62278e6f3d4cd6`.
- Terraform conformance input: PR #30 merge `fbfc3aca874e235cace92f506377f5c9e0704160`.
- Current candidate head: `1e35e9b50045cca8946c97070109e3c9fc38c804`.
- Original paths: `.github/workflows/Generate-StyleGuideArtifacts.ps1`, `.github/workflows/Test-ExactGitPathSet.ps1`, and `.github/workflows/build.yml`.
- Coupled identity paths: `.github/workflows/workflow-policy-contract.json` and `.github/workflows/Validate-WorkflowPolicy.mjs`.

### Procedure

1. Re-query PR #164 and verify its base, head, tree, draft state, checks, affected paths, and PS #160 closing reference.
2. Confirm that the completed rebase, original patch, Terraform PR #30 authoring conformance, timeless version grammar, and coupled policy identities are present in the candidate.
3. Run the task-local Anthropic Claude Code review-loop prompt below with `<PR_URL_OR_NUMBER>` set to `https://github.com/franklesniak/PSStyleGuide/pull/164`.
4. Preserve runtime behavior and the prohibition on editing `CLAUDE.md` or the four P1A files unless an independently authorized finding requires a different action.
5. If the loop changes bytes, rerun both Markdown surfaces, PowerShell parsing, PSScriptAnalyzer under Windows PowerShell 5.1 and PowerShell 7 where available, policy validation, generator drift, and exact-path verification before the next review round.

### Anthropic Claude Code review-loop prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a dedicated Anthropic Claude Code session:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

### Complete when

The loop returns `TERMINALLY CLEAN` and records the final PR head/tree, review rounds, current-head Copilot and Codex results, processed comments and threads, validation, and deferral sweep. Do not merge.

## Task 2 — run the independent final quality check on PR #164

> **Execution class: Coding agent executable.** Use a fresh coding-agent session after Task 1.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 1 | `FS` | The Claude Code review loop is terminally clean. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Start a fresh coding-agent session that does not inherit the Claude review-loop context.
2. Run the task-local independent final PR quality-check prompt below with `<PR_URL_OR_NUMBER>` set to `https://github.com/franklesniak/PSStyleGuide/pull/164`.
3. Require the audit to cover all review comments and threads, stranded deferrals, PS #160 requirements, PR title/body accuracy, final diff quality, validation, checks, mergeability, and current-head review evidence.
4. If the check changes any reviewable repository byte or finds unfinished implementation work, stop. Complete the work and return to Task 1.
5. If the check changes only PR or issue metadata, re-query it and repeat the affected check sections before accepting the result.

### Independent final PR quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a fresh coding-agent session after the Claude Code review loop is terminally clean:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

### Complete when

The fresh agent returns `PASS` for the same head SHA and tree as Task 1, with no unresolved finding, unfinished requirement, illegitimate or untracked deferral, PR-description error, dependency error, or quality blocker.

## Task 3 — merge PR #164 and close PS #160

> **Execution class: Coding agent executable.** This is a merge and landed-evidence task.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 2 | `FS` | The independent check returned `PASS` for the current head and tree. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Apply the task-local merge gate below.
2. Verify again that the Claude Code terminal-clean record and independent `PASS` record identify the current PR #164 head and tree.
3. Merge PR #164 with the approved method and close PS #160.
4. Record the base, final reviewed head/tree, merge method, landed commit/tree, all five landed blobs, version and digest changes, validation commands and results, runtime identities, review-loop result, final quality-check result, and intentional differences.

### Merge gate

Immediately before the merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

PR #164 is merged, PS #160 is closed, and the permanent landed record exists. Do not start Task 4 before this record exists.

## Task 4 — compare cycle 1 in Terraform and adapt if required

> **Execution class: Coding agent executable.** Work in TerraformStyleGuide after Task 3 lands.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 3 | `FS` | Use only the landed PS #160 commit and blobs. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Fetch both repositories. Record the landed PS #160 commit, tree, and five source blobs.
2. Record the fetched Terraform `main` commit, tree, and mapped destination blobs.
3. Compare the generator, exact-path verifier or embedded checks, build workflow, coupled policy identities, validation, and negative cases.
4. Complete every applicable `GF-*` row and exact file/blob mapping.
5. If no common difference exists, post a pinned no-change record to PS #160, PS #159, and Terraform #31.
6. If a common difference exists, create or update one focused Terraform issue. Pin the landed PS commit and blobs.
7. Start the Terraform adaptation only after issue setup and a free implementation slot.
8. Preserve common behavior. Change only proved repository-specific literals or behavior.
9. If a Terraform repair is required, prepare one focused PR and run all four task-local conditional repair PR lifecycle actions before it merges.

### Destination-comparison controls

1. Read both repositories only from pinned commits. Record every compared blob.
2. Map files by role, not only by filename.
3. Classify each applicable matrix row as `same`, `intentional difference`, or `blocker`.
4. If no common difference exists, post a pinned no-change or non-applicability record. Do not open an implementation issue only for symmetry.
5. If a common difference exists, create or update one focused destination issue. Pin the source commit and blobs.
6. Start the destination adaptation only after issue setup and a free implementation slot. Adapt the landed capability; do not redesign it independently.
7. Prepare one destination candidate and complete the task-local conditional repair PR lifecycle. Record the complete landed identity and validation evidence.
8. Stop this task at its stated destination result. The dependent reverse-comparison task must compare the landed destination result back against the source before the cycle can close.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

Terraform has either a landed focused repair or a pinned no-change record. Record the issue and PR URLs, reviewed and landed identities, affected paths, blobs, validation, and intentional differences.

## Task 5 — reverse-compare cycle 1 in PS and close its fixed point

> **Execution class: Coding agent executable.** Work in PSStyleGuide after Task 4.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 4 | `FS` | Use the final Task 3 PS commit and final Task 4 Terraform commit. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Read both repositories only from the two landed commits. Record all compared blobs.
2. Repeat the same role map and reciprocal matrix in the PS direction.
3. If Terraform added or corrected common behavior, create a focused PS sync-back issue. Pin both landed commits and blobs.
4. Start the PS sync-back only after issue setup and a free implementation slot.
5. If a PS sync-back is required, prepare one focused PR and run all four task-local conditional repair PR lifecycle actions before it merges.
6. If a PS PR lands, compare the new PS commit in Terraform again. For a required Terraform repair, run the same four task-local conditional repair PR lifecycle actions before merge.
7. Stop and run a new decision process if a matrix row changes direction twice.
8. Update PS #159 and Terraform #31 with the permanent cycle 1 record.

### Reverse-comparison and closure controls

1. Read both repositories only from the final pinned commits. Record every compared blob and map files by role.
2. Classify each applicable matrix row as `same`, `intentional difference`, or `blocker`.
3. If the destination adaptation added or corrected common behavior, create or update one focused source sync-back issue. Pin both landed commits and blobs.
4. Start a source sync-back only after issue setup and a free implementation slot. Adapt the common behavior; do not redesign it independently.
5. Prepare the source sync-back candidate and complete the task-local conditional repair PR lifecycle.
6. If the source changes, compare the new landed source result in the destination again. Use the same issue, slot, lifecycle, and evidence controls for each required destination repair.
7. Stop if the same matrix row changes direction twice. Run a new decision process that evaluates both implementations.
8. Close the cycle only when every common row is `same`, every intentional difference has complete evidence, and no blocker remains.
9. Post one permanent closure record with both repositories' final identities, the matrix digest, validation, review outcomes, and no-change or non-applicability results. If a dependent final-recheck task owns closure, post the current reciprocal record and leave final closure to that task.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

Every common row is `same`, every intentional difference has complete evidence, and no blocker remains. The permanent record identifies both repositories' final landed commits and blobs.

## Task 6 — implement PS generator and exact-path convergence

> **Execution class: Coding agent executable.** Work in PSStyleGuide issue #161.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 5 | `FS` | Cycle 1 has a permanent fixed-point record. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Immutable inputs

- PS generator blob at the baseline: `c54012e549aedef827ae3ccb669b512a1f14c644`.
- PS path-verifier blob at the baseline: `dc786aed1bd8c9d3bdcb25c6ea79207fc1d63c1b`.
- Terraform generator blob at `fbfc3aca874e235cace92f506377f5c9e0704160`: `e5bdd8f64569541eb3c724387dfdff1847c18793`.
- Terraform build-workflow blob that contains embedded Git/worktree checks: `f68dfe2da4842d2086b079e09328e3298856123e`.
- Terraform policy-validator blob that contains related fixtures: `fb17e06f2f456a0d7df510b0bb34c52d88b7893b`.
- The landed Task 3 commit is the editing baseline. Replace `<PS_INFRA_LANDED_COMMIT>` in PS #161 before implementation. Use the older PS blobs only to identify pre-convergence behavior.

### Required generated-destination behavior

1. Use the fixed repository map as the only path authority. Require the exact destination to be index-tracked.
2. Permit only an absent filesystem entry or one ordinary non-link file under the validated repository root.
3. Precompute and validate all complete payload bytes before destination mutation.
4. Create a fresh, unpredictable, same-directory ordinary candidate. Use bounded retries for real collisions.
5. Write all bytes, durably flush, close, reopen, and verify length, digest, BOM, carriage-return, and final-newline rules.
6. Revalidate the parent, destination state, and candidate identity immediately before publication.
7. For an existing destination, call `File.Replace(candidate, destination, null)` once. For an absent destination, call non-overwriting, same-directory `File.Move(candidate, destination)` once.
8. Before publication returns, preserve the old destination or proved absence on failure. Remove only the proved candidate.
9. After publication returns, do not attempt rollback and do not claim cross-file atomicity.
10. Return success only when bounded final evidence proves destination bytes and state. Otherwise, return `ReplacementStateUncertain` with bounded recovery evidence.
11. Preserve fixed order and truthful partial-success records when a later artifact fails.

### Reusable Git/path contract

Keep `Test-ExactGitPathSet.ps1` as the reusable implementation. Add all applicable Terraform invariants for fixed executable identity, a constructed child environment, disabled ambient Git controls, raw NUL framing, hostile-byte handling, duplicate and cardinality rejection, exact native-status classification, staged, working, and untracked surfaces, hooks and configuration control-surface detection, and bounded ordinary worktree inspection. Do not duplicate the normative algorithm in workflow YAML. A thin caller can contain job-specific orchestration only.

### Scope, validation, and handoff

1. Freeze the affected-path set before coding. Assign mere pin or fixture changes in `build.yml` or policy files to Task 12.
2. Complete the full foundation catalog and a file-operation matrix for an existing destination, absent tracked destination, unexpected destination, link/reparse substitution, candidate collision, write/flush/verify failure, publication failure, post-publication uncertainty, cleanup failure, and multi-artifact partial success.
3. Keep the issue read-only for workflow publication. P1B/T1B introduces the first writer.
4. Run fault injection outside the real repository. Test Windows PowerShell 5.1, PowerShell 7 on Windows, and PowerShell 7 on Ubuntu.
5. Prove byte-identical, idempotent output; exact result schemas; truthful failure states; no generated drift; hostile-path handling; script-version progression; and clean staged and working path sets.
6. Create or update one focused PS #161 PR. Run initial local validation and required checks.
7. Record the base, candidate head/tree, source and candidate blobs, versions, SHA-256 values, result schema, fixture identities, runtime matrix, and intentional differences. Stop before merge.

### Candidate preparation gate

Before this task is complete:

1. Create or update only the focused PR for the stated issue or approved task.
2. Complete the issue scope, applicable local validation, an accurate PR body, and initial required checks.
3. Record the base, candidate head SHA and tree, affected paths, issue links, and every task-specific source, destination, validation, runtime, and intentional-difference identity.
4. Replace every placeholder and verify every posted identity.
5. Stop before the Claude Code review loop, independent final quality check, or merge. Do not perform a later lifecycle action in this task.

### Complete when

The PS #161 candidate PR exists with complete initial validation and an accurate PR body. It is ready for the Claude Code review loop.

## Task 7 — run the Anthropic Claude Code review loop on the PS #161 PR

> **Execution class: Coding agent executable by Anthropic Claude Code.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 6 | `FS` | The PS #161 candidate PR exists and initial checks pass. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local Anthropic Claude Code review-loop prompt below against the PS #161 PR. Do not merge. If the loop changes bytes, rerun the Task 6 validation and continue the loop on the new head.

### Anthropic Claude Code review-loop prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a dedicated Anthropic Claude Code session:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

### Complete when

The loop returns `TERMINALLY CLEAN` for a recorded head SHA and tree with complete current-head reviewer and deferral-sweep evidence.

## Task 8 — run the independent final quality check on the PS #161 PR

> **Execution class: Coding agent executable.** Use a fresh coding-agent session.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 7 | `FS` | The Claude Code review loop is terminally clean. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local independent final PR quality-check prompt below against the PS #161 PR. Require full PS #161 issue-requirement coverage, comment and deferral audits, PR-body accuracy, final-diff inspection, validation, checks, and mergeability. Return to Task 7 after any head change.

### Independent final PR quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a fresh coding-agent session after the Claude Code review loop is terminally clean:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

### Complete when

The fresh agent returns `PASS` for the same head SHA and tree as Task 7.

## Task 9 — merge the PS #161 PR and publish its handoff

> **Execution class: Coding agent executable.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 8 | `FS` | The independent quality check passed for the current head and tree. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Apply the task-local merge gate below. Merge the focused PS #161 PR, close PS #161, and record the base, reviewed head/tree, merge method, landed commit/tree, source and landed blobs, versions, SHA-256 values, result schema, fixture identities, runtime matrix, validation, review-loop result, final quality-check result, and intentional differences.

### Merge gate

Immediately before the merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

PS #161 is closed by the landed PR and its permanent handoff is ready for the Terraform comparison.

## Task 10 — compare cycle 2 in Terraform and adapt if required

> **Execution class: Coding agent executable.** Work in TerraformStyleGuide after Task 9.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 9 | `FS` | Use the final landed PS #161 commit. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Pin the Task 9 PS commit, tree, generator and verifier blobs, result schemas, and fixtures.
2. Compare the complete generated-destination algorithm and reusable Git/path contract with Terraform.
3. Complete the full foundation catalog and the Task 9 file-operation matrix.
4. If all common behavior matches, post a pinned no-change record.
5. If a common difference exists, create or update one focused Terraform issue before implementation. Then run the four task-local conditional repair PR lifecycle actions.
6. Preserve repository-specific filenames and identity only when the intentional-difference record proves equal security and failure strength.
7. Post the result to PS #161, PS #159, and Terraform #31.

### Destination-comparison controls

1. Read both repositories only from pinned commits. Record every compared blob.
2. Map files by role, not only by filename.
3. Classify each applicable matrix row as `same`, `intentional difference`, or `blocker`.
4. If no common difference exists, post a pinned no-change or non-applicability record. Do not open an implementation issue only for symmetry.
5. If a common difference exists, create or update one focused destination issue. Pin the source commit and blobs.
6. Start the destination adaptation only after issue setup and a free implementation slot. Adapt the landed capability; do not redesign it independently.
7. Prepare one destination candidate and complete the task-local conditional repair PR lifecycle. Record the complete landed identity and validation evidence.
8. Stop this task at its stated destination result. The dependent reverse-comparison task must compare the landed destination result back against the source before the cycle can close.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

Terraform has a landed focused repair or a pinned no-change record, with full identities, validation, and matrix evidence.

## Task 11 — reverse-compare cycle 2 in PS and close its fixed point

> **Execution class: Coding agent executable.** Work in PSStyleGuide after Task 10.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 10 | `FS` | Use only the final landed commits from Tasks 9 and 10. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Use the task-local reverse-comparison and closure controls below. Repeat the foundation and file-operation matrices in the PS direction. Create a focused PS sync-back issue before any correction. Run the four task-local conditional repair PR lifecycle actions for every PS or later Terraform repair. Stop for a new decision process if a row changes direction twice. Update PS #159 and Terraform #31 with the permanent cycle 2 record.

### Reverse-comparison and closure controls

1. Read both repositories only from the final pinned commits. Record every compared blob and map files by role.
2. Classify each applicable matrix row as `same`, `intentional difference`, or `blocker`.
3. If the destination adaptation added or corrected common behavior, create or update one focused source sync-back issue. Pin both landed commits and blobs.
4. Start a source sync-back only after issue setup and a free implementation slot. Adapt the common behavior; do not redesign it independently.
5. Prepare the source sync-back candidate and complete the task-local conditional repair PR lifecycle.
6. If the source changes, compare the new landed source result in the destination again. Use the same issue, slot, lifecycle, and evidence controls for each required destination repair.
7. Stop if the same matrix row changes direction twice. Run a new decision process that evaluates both implementations.
8. Close the cycle only when every common row is `same`, every intentional difference has complete evidence, and no blocker remains.
9. Post one permanent closure record with both repositories' final identities, the matrix digest, validation, review outcomes, and no-change or non-applicability results. If a dependent final-recheck task owns closure, post the current reciprocal record and leave final closure to that task.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

The generator/path cycle has no blocker, every common row is `same`, and every intentional difference is fully proved.

## Task 12 — implement PS workflow isolation and policy convergence

> **Execution class: Coding agent executable.** Work in PSStyleGuide issue #162.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 11 | `FS` | Cycle 2 has a permanent fixed-point record. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Immutable inputs

- PS build: `208a8b492c1f32e02c0731449db95890b256fc51`.
- PS Markdown workflow: `4afa4f3aba03ffe3796ca72223cb0ebe26c8f34a`.
- PS policy validator: `00263451aa8287a36ad0694143d96741c4cdd1f9`.
- PS policy contract: `36374dbf88cb280126f780052e5d860ec96af9a7`.
- PS policy cases: `252423934501a1a5ffa7a9d33ea0f001b4068d11`.
- Terraform build: `f68dfe2da4842d2086b079e09328e3298856123e`.
- Terraform Markdown workflow: `6a64b2a3b5b737bb7f69dc971b1b21b298013ab0`.
- Terraform policy validator: `fb17e06f2f456a0d7df510b0bb34c52d88b7893b`.
- The final landed Task 9 commit is the editing baseline. Replace `<PS_GENERATOR_LANDED_COMMIT>` in PS #162 before implementation. Re-read all overlapping paths from that commit.

### Required topology and policy

1. Repository-code jobs must declare `permissions: {}` and contain no `uses:` key.
2. Acquire the exact triggering commit anonymously through a fixed absolute Git executable. Fail if the public anonymous model is unavailable.
3. Prove a credential-free remote and configuration state before repository code runs.
4. In Node jobs, download the exact official Node distribution from a reviewed URL, verify its reviewed digest before extraction, and assert exact Node/npm identities.
5. Separate policy validation from Markdown lint and generator verification from artifact publication. Use different jobs and runners.
6. A publication job must run no repository code and use only reviewed, full-SHA actions with a closed input/default contract.
7. Do not publish repository-code job diagnostics. If bounded diagnostics remain necessary, use only commit-derived or independently produced evidence through a separate safe design.
8. Preserve unfiltered pull-request and push coverage. Keep every job read-only. P1B owns the first writer.
9. Retain `workflow-policy-contract.json` as the machine-readable authority and `workflow-policy-cases.json` as the external case catalog.
10. Port every applicable Terraform PR #26/#30 invariant and negative fixture: job isolation, action-role multiset, immutable acquisition, runner communication, credential absence, fixed tools, control-surface integrity, worktree containment, Node supply verification, strict YAML/JSON shapes, native statuses, terminal graph behavior, and publish-job restrictions.
11. Run policy parsing and all fixtures strictly offline. Do not reduce Terraform coverage to preserve PS's smaller case count. Do not copy Terraform repository literals or historical decision text.
12. Keep PS #151 separate unless that issue is expressly amended and all of its acceptance evidence is satisfied.

### Comparison, validation, and handoff

1. Complete the full foundation catalog against the final Task 11 state.
2. Add a topology table that lists every workflow, job, step, permission, condition, action, authored input, reviewed default, credential, repository-code execution point, produced byte set, consumed byte set, and side effect.
3. Treat an action or repository-token scope in a repository-code job, an unverified Node distribution, an unexplained missing Terraform negative case, or a weaker failure postcondition as a blocker.
4. Run all offline fixtures, both Markdown surfaces, generator drift, exact-path checks, clean installs, policy preflight and full validation, action/default provenance checks, and pull-request/push graph tests.
5. Record the final case count and prove that every case runs exactly once. Require all initial checks to pass at the candidate head.
6. Create or update one focused PS #162 PR. Record all source and candidate blobs, contract and catalog versions/digests, Node/npm/archive identities, action pins and manifest defaults, final topology, case allocation, runtime results, candidate head/tree, and intentional differences. Stop before merge.

### Candidate preparation gate

Before this task is complete:

1. Create or update only the focused PR for the stated issue or approved task.
2. Complete the issue scope, applicable local validation, an accurate PR body, and initial required checks.
3. Record the base, candidate head SHA and tree, affected paths, issue links, and every task-specific source, destination, validation, runtime, and intentional-difference identity.
4. Replace every placeholder and verify every posted identity.
5. Stop before the Claude Code review loop, independent final quality check, or merge. Do not perform a later lifecycle action in this task.

### Complete when

The PS #162 candidate PR exists with complete initial validation and an accurate PR body.

## Task 13 — run the Anthropic Claude Code review loop on the PS #162 PR

> **Execution class: Coding agent executable by Anthropic Claude Code.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 12 | `FS` | The PS #162 candidate PR exists and initial checks pass. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local Anthropic Claude Code review-loop prompt below against the PS #162 PR. Do not merge. If the loop changes bytes, rerun the Task 12 validation and continue on the new head.

### Anthropic Claude Code review-loop prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a dedicated Anthropic Claude Code session:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

### Complete when

The loop returns `TERMINALLY CLEAN` for a recorded head SHA and tree.

## Task 14 — run the independent final quality check on the PS #162 PR

> **Execution class: Coding agent executable.** Use a fresh coding-agent session.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 13 | `FS` | The Claude Code review loop is terminally clean. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local independent final PR quality-check prompt below against the PS #162 PR. Require full issue-contract, workflow-topology, policy-case, comment, deferral, PR-body, validation, and mergeability coverage. Return to Task 13 after any head change.

### Independent final PR quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a fresh coding-agent session after the Claude Code review loop is terminally clean:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

### Complete when

The fresh agent returns `PASS` for the same head SHA and tree as Task 13.

## Task 15 — merge the PS #162 PR and publish its handoff

> **Execution class: Coding agent executable.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 14 | `FS` | The independent quality check passed for the current head and tree. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Apply the task-local merge gate below. Merge the focused PR, close PS #162, and record all source and landed blobs, contract and catalog versions/digests, Node/npm/archive identities, action pins and manifest defaults, final topology, case allocation, runtime results, reviewed and landed identities, review-loop result, final quality-check result, and intentional differences.

### Merge gate

Immediately before the merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

PS #162 is closed and the final landed policy contract is ready for Task 16.

## Task 16 — compare cycle 3 in Terraform and adapt if required

> **Execution class: Coding agent executable.** Work in TerraformStyleGuide after Task 15.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 15 | `FS` | Use the final landed PS #162 commit and policy contract. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Pin all Task 15 workflow, policy, contract, case, and validation blobs.
2. Complete the full foundation catalog and workflow-topology table in Terraform.
3. Apply all blockers from Task 15's required topology and policy.
4. Post a pinned no-change record or prepare one focused Terraform repair and run the four task-local conditional repair PR lifecycle actions.
5. Update PS #162, PS #159, and Terraform #31 with full identities and validation.

### Destination-comparison controls

1. Read both repositories only from pinned commits. Record every compared blob.
2. Map files by role, not only by filename.
3. Classify each applicable matrix row as `same`, `intentional difference`, or `blocker`.
4. If no common difference exists, post a pinned no-change or non-applicability record. Do not open an implementation issue only for symmetry.
5. If a common difference exists, create or update one focused destination issue. Pin the source commit and blobs.
6. Start the destination adaptation only after issue setup and a free implementation slot. Adapt the landed capability; do not redesign it independently.
7. Prepare one destination candidate and complete the task-local conditional repair PR lifecycle. Record the complete landed identity and validation evidence.
8. Stop this task at its stated destination result. The dependent reverse-comparison task must compare the landed destination result back against the source before the cycle can close.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

Terraform matches every common workflow-policy behavior or has fully proved intentional differences.

## Task 17 — reverse-compare cycle 3 in PS and close its fixed point

> **Execution class: Coding agent executable.** Work in PSStyleGuide after Task 16.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 16 | `FS` | Use only the final landed commits from Tasks 15 and 16. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Use the task-local reverse-comparison and closure controls below with the complete foundation catalog and workflow-topology table. Create a focused PS issue before a sync-back. Run the four task-local conditional repair PR lifecycle actions for every PS or later Terraform repair. Update PS #159 and Terraform #31 with the permanent cycle 3 record.

### Reverse-comparison and closure controls

1. Read both repositories only from the final pinned commits. Record every compared blob and map files by role.
2. Classify each applicable matrix row as `same`, `intentional difference`, or `blocker`.
3. If the destination adaptation added or corrected common behavior, create or update one focused source sync-back issue. Pin both landed commits and blobs.
4. Start a source sync-back only after issue setup and a free implementation slot. Adapt the common behavior; do not redesign it independently.
5. Prepare the source sync-back candidate and complete the task-local conditional repair PR lifecycle.
6. If the source changes, compare the new landed source result in the destination again. Use the same issue, slot, lifecycle, and evidence controls for each required destination repair.
7. Stop if the same matrix row changes direction twice. Run a new decision process that evaluates both implementations.
8. Close the cycle only when every common row is `same`, every intentional difference has complete evidence, and no blocker remains.
9. Post one permanent closure record with both repositories' final identities, the matrix digest, validation, review outcomes, and no-change or non-applicability results. If a dependent final-recheck task owns closure, post the current reciprocal record and leave final closure to that task.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

Every common workflow-policy behavior is `same`, all differences have complete evidence, and no blocker remains.

## Task 18 — post the initial three-cycle handoff

> **Execution class: Coding agent executable.** This is an evidence-publication task, not an implementation task.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 17 | `FS` | Cycles 1 through 3 have permanent fixed-point records. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Post one interim handoff to PS #159 and Terraform #31. List cycles 1 through 3, every PS and Terraform issue and PR, bases, reviewed heads/trees, merge methods, landed commits/trees, source and destination blobs, matrices, validation, review outcomes, intentional differences, and fixed-point result. State that PS #158 remains nonblocking and has no native blocking edge to PS #147 or #152. Verify every identifier before posting. Do not close either tracker.

### Complete when

Both trackers contain a permanent, internally consistent handoff for cycles 1 through 3.

## Task 19 — implement the PS read-only supply-freeze recorder

> **Execution class: Coding agent executable.** Work in PSStyleGuide issue #158.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 18 | `FS` | The final cycle 3 policy contract and interim handoff exist. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Issue update

Before implementation, replace both placeholders and post this planning comment to PS #158 without replacing its body:

> This issue is a child of [PS issue #159](https://github.com/franklesniak/PSStyleGuide/issues/159) and starts after `<PS_WORKFLOW_POLICY_PR_URL>` lands. Re-read the final landed `workflow-policy-contract.json` from `<PS_WORKFLOW_POLICY_LANDED_COMMIT>` before adapting the recorder. Preserve this issue's existing nonblocking scope and immutable Terraform PR #27 source pins.

### Procedure

1. Re-read the final Task 17 policy contract and the immutable Terraform PR #27 inputs.
2. Preserve the issue's existing nonblocking scope.
3. Keep the recorder read-only and capture its output outside the repository.
4. Prove that it does not mutate a manifest, lockfile, installed tree, contract, generated output, staged set, or worktree.
5. Complete a documented reduced reciprocal matrix for the narrow recorder surface. Include every applicable foundation row and prove why omitted rows are inapplicable.
6. Create or update one focused PS #158 PR. Run initial validation and required checks.
7. Record the candidate head/tree, all source and candidate blobs, tool/runtime identities, exact output location, mutation-absence evidence, validation, and intentional differences. Stop before merge.

### Candidate preparation gate

Before this task is complete:

1. Create or update only the focused PR for the stated issue or approved task.
2. Complete the issue scope, applicable local validation, an accurate PR body, and initial required checks.
3. Record the base, candidate head SHA and tree, affected paths, issue links, and every task-specific source, destination, validation, runtime, and intentional-difference identity.
4. Replace every placeholder and verify every posted identity.
5. Stop before the Claude Code review loop, independent final quality check, or merge. Do not perform a later lifecycle action in this task.

### Complete when

The PS #158 candidate PR exists with complete initial validation and an accurate PR body.

## Task 20 — run the Anthropic Claude Code review loop on the PS #158 PR

> **Execution class: Coding agent executable by Anthropic Claude Code.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 19 | `FS` | The PS #158 candidate PR exists and initial checks pass. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local Anthropic Claude Code review-loop prompt below against the PS #158 PR. Do not merge. If the loop changes bytes, rerun the Task 19 validation.

### Anthropic Claude Code review-loop prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a dedicated Anthropic Claude Code session:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

### Complete when

The loop returns `TERMINALLY CLEAN` for a recorded head SHA and tree.

## Task 21 — run the independent final quality check on the PS #158 PR

> **Execution class: Coding agent executable.** Use a fresh coding-agent session.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 20 | `FS` | The Claude Code review loop is terminally clean. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local independent final PR quality-check prompt below. Require PS #158 issue coverage, immutable-source verification, read-only and mutation-absence proof, comments, deferrals, PR-body accuracy, validation, and mergeability. Return to Task 20 after any head change.

### Independent final PR quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a fresh coding-agent session after the Claude Code review loop is terminally clean:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

### Complete when

The fresh agent returns `PASS` for the same head SHA and tree as Task 20.

## Task 22 — merge the PS #158 PR and publish its handoff

> **Execution class: Coding agent executable.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 21 | `FS` | The independent quality check passed for the current head and tree. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Apply the task-local merge gate below. Merge the PR, close PS #158, and record the reviewed and landed identities, all source and destination blobs, tool/runtime identities, exact output location, mutation-absence evidence, validation, review-loop result, final quality-check result, and intentional differences.

### Merge gate

Immediately before the merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

PS #158 is closed and its permanent handoff is ready for Terraform.

## Task 23 — compare cycle 4 in Terraform and adapt if required

> **Execution class: Coding agent executable.** Work in TerraformStyleGuide after Task 22.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 22 | `FS` | Use the final landed PS #158 recorder and handoff. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Pin the PS source and landed commits and blobs and the immutable Terraform PR #27 inputs.
2. Compare the read-only recorder roles with a documented reduced matrix.
3. Prove that both implementations preserve repository state and capture output outside the repository.
4. Post a pinned no-change record or prepare one focused Terraform repair and run the four task-local conditional repair PR lifecycle actions.
5. Update PS #158, PS #159, and Terraform #31 with all identities, validation, and differences.

### Destination-comparison controls

1. Read both repositories only from pinned commits. Record every compared blob.
2. Map files by role, not only by filename.
3. Classify each applicable matrix row as `same`, `intentional difference`, or `blocker`.
4. If no common difference exists, post a pinned no-change or non-applicability record. Do not open an implementation issue only for symmetry.
5. If a common difference exists, create or update one focused destination issue. Pin the source commit and blobs.
6. Start the destination adaptation only after issue setup and a free implementation slot. Adapt the landed capability; do not redesign it independently.
7. Prepare one destination candidate and complete the task-local conditional repair PR lifecycle. Record the complete landed identity and validation evidence.
8. Stop this task at its stated destination result. The dependent reverse-comparison task must compare the landed destination result back against the source before the cycle can close.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

Terraform and PS have the same common supply-freeze behavior or fully proved intentional differences.

## Task 24 — reverse-compare cycle 4 in PS and close its fixed point

> **Execution class: Coding agent executable.** Work in PSStyleGuide after Task 23.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 23 | `FS` | Use only the final landed commits from Tasks 22 and 23. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Use the task-local reverse-comparison and closure controls below and the same reduced matrix. Create a focused PS sync-back issue before any correction. Run the four task-local conditional repair PR lifecycle actions for every PS or later Terraform repair. Update PS #159 and Terraform #31 with the permanent cycle 4 record.

### Reverse-comparison and closure controls

1. Read both repositories only from the final pinned commits. Record every compared blob and map files by role.
2. Classify each applicable matrix row as `same`, `intentional difference`, or `blocker`.
3. If the destination adaptation added or corrected common behavior, create or update one focused source sync-back issue. Pin both landed commits and blobs.
4. Start a source sync-back only after issue setup and a free implementation slot. Adapt the common behavior; do not redesign it independently.
5. Prepare the source sync-back candidate and complete the task-local conditional repair PR lifecycle.
6. If the source changes, compare the new landed source result in the destination again. Use the same issue, slot, lifecycle, and evidence controls for each required destination repair.
7. Stop if the same matrix row changes direction twice. Run a new decision process that evaluates both implementations.
8. Close the cycle only when every common row is `same`, every intentional difference has complete evidence, and no blocker remains.
9. Post one permanent closure record with both repositories' final identities, the matrix digest, validation, review outcomes, and no-change or non-applicability results. If a dependent final-recheck task owns closure, post the current reciprocal record and leave final closure to that task.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

The supply-freeze cycle has no common difference or blocker and has one permanent fixed-point record.

## Task 25 — close the PS foundation umbrella

> **Execution class: Coding agent executable.** This is an issue-evidence and closure task, not implementation.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 24 | `FS` | PS #160, #161, #162, and #158 and all four reciprocal cycles are complete. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Re-query PS #159 and its four native children.
2. Verify that #160, #161, #162, and #158 are closed and that every cycle has a permanent fixed-point record.
3. Post the foundation handoff. Include every issue and PR URL, base, reviewed head/tree, merge method, landed commit/tree, affected path and blob, complete or reduced matrix, validation command and result, runtime identity, review outcome, intentional difference, and reciprocal closure result.
4. Verify that Terraform #31 links the same four cycle records.
5. Close PS #159. Do not create or merge an aggregate foundation PR.

### Complete when

PS #159 is closed with complete, matching evidence in both repositories.

## Task 26 — implement the PS Claude review-loop command

> **Execution class: Coding agent executable.** Work in PSStyleGuide issue #163.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 25 | `FS` | The foundation umbrella is closed and the implementation slot is free. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Immutable design input

Read TerraformStyleGuide `.claude/commands/review-loop.md` from commit `fbdecbae787055a2117d4ada83ae294a7decfe62`, blob `7b0e41361a8ab7259245ad5f0d86d9300008347d`. Do not copy it unchanged: it says `all six steps`, but PSStyleGuide's landed `CLAUDE.md` defines nine review-comment handling steps.

### Procedure

1. Reconfirm the existing owner authorization because the new file is an agent entry point.
2. Add a thin, repository-local command wrapper.
3. Accept a pull-request URL. Require the URL when the caller does not supply it.
4. Delegate the authoritative process to the repository-local root `CLAUDE.md`.
5. Treat Codex and Copilot as co-equal reviewers, as `CLAUDE.md` requires.
6. Do not duplicate a step count, gate count, round limit, or other volatile protocol detail.
7. Do not fetch instructions from a moving external branch or add a shared runtime dependency.
8. Record a line-by-line comparison with the pinned Terraform input. Explain each intentional difference.
9. Complete a documented reduced reciprocal matrix. Run Markdown lint and all applicable local agent-instruction checks.
10. Keep the issue and PR separate from foundation, supply-freeze, and infrastructure-conformance work.
11. Create or update one focused PS #163 PR. Record the candidate head/tree, pinned input, line comparison, validation, and initial checks. Stop before merge.

### Candidate preparation gate

Before this task is complete:

1. Create or update only the focused PR for the stated issue or approved task.
2. Complete the issue scope, applicable local validation, an accurate PR body, and initial required checks.
3. Record the base, candidate head SHA and tree, affected paths, issue links, and every task-specific source, destination, validation, runtime, and intentional-difference identity.
4. Replace every placeholder and verify every posted identity.
5. Stop before the Claude Code review loop, independent final quality check, or merge. Do not perform a later lifecycle action in this task.

### Complete when

The PS #163 candidate PR exists with complete initial validation and an accurate PR body.

## Task 27 — run the Anthropic Claude Code review loop on the PS #163 PR

> **Execution class: Coding agent executable by Anthropic Claude Code.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 26 | `FS` | The PS #163 candidate PR exists and initial checks pass. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local Anthropic Claude Code review-loop prompt below against the PS #163 PR. Do not merge. If the loop changes bytes, rerun the Task 26 validation.

### Anthropic Claude Code review-loop prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a dedicated Anthropic Claude Code session:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

### Complete when

The loop returns `TERMINALLY CLEAN` for a recorded head SHA and tree.

## Task 28 — run the independent final quality check on the PS #163 PR

> **Execution class: Coding agent executable.** Use a fresh coding-agent session.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 27 | `FS` | The Claude Code review loop is terminally clean. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local independent final PR quality-check prompt below. Require PS #163 issue coverage, protected-entry-point authorization, pinned-input comparison, absence of volatile protocol duplication, comments, deferrals, PR-body accuracy, validation, and mergeability. Return to Task 27 after any head change.

### Independent final PR quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a fresh coding-agent session after the Claude Code review loop is terminally clean:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

### Complete when

The fresh agent returns `PASS` for the same head SHA and tree as Task 27.

## Task 29 — merge the PS #163 PR and publish its handoff

> **Execution class: Coding agent executable.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 28 | `FS` | The independent quality check passed for the current head and tree. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Apply the task-local merge gate below. Merge the PR, close PS #163, and record the pinned design input, line comparison, validation, reviewed head/tree, landed commit/tree, review-loop result, final quality-check result, and intentional differences.

### Merge gate

Immediately before the merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

PS #163 is closed and its permanent handoff is ready for Terraform comparison.

## Task 30 — compare cycle 5 in Terraform and adapt if required

> **Execution class: Coding agent executable.** Work in TerraformStyleGuide after Task 29.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 29 | `FS` | Use the final landed PS #163 command. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Pin the PS command and authoritative `CLAUDE.md` blobs and the immutable Terraform command blob.
2. Compare both thin wrappers line by line with a documented reduced matrix.
3. Preserve each repository's authoritative local instruction file and repository identity.
4. Post a pinned no-change record or prepare one focused Terraform repair and run the four task-local conditional repair PR lifecycle actions.
5. Update PS #163 and Terraform #31 with all identities, validation, and intentional differences.

### Destination-comparison controls

1. Read both repositories only from pinned commits. Record every compared blob.
2. Map files by role, not only by filename.
3. Classify each applicable matrix row as `same`, `intentional difference`, or `blocker`.
4. If no common difference exists, post a pinned no-change or non-applicability record. Do not open an implementation issue only for symmetry.
5. If a common difference exists, create or update one focused destination issue. Pin the source commit and blobs.
6. Start the destination adaptation only after issue setup and a free implementation slot. Adapt the landed capability; do not redesign it independently.
7. Prepare one destination candidate and complete the task-local conditional repair PR lifecycle. Record the complete landed identity and validation evidence.
8. Stop this task at its stated destination result. The dependent reverse-comparison task must compare the landed destination result back against the source before the cycle can close.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

Terraform and PS have the same common wrapper behavior and no duplicated volatile protocol text.

## Task 31 — reverse-compare cycle 5 in PS and close its fixed point

> **Execution class: Coding agent executable.** Work in PSStyleGuide after Task 30.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 30 | `FS` | Use only the final landed commits from Tasks 29 and 30. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Use the task-local reverse-comparison and closure controls below and the same line comparison and reduced matrix. Create a focused PS sync-back issue before any correction. Run the four task-local conditional repair PR lifecycle actions for every PS or later Terraform repair. Update PS #163 and Terraform #31 with the permanent cycle 5 record.

### Reverse-comparison and closure controls

1. Read both repositories only from the final pinned commits. Record every compared blob and map files by role.
2. Classify each applicable matrix row as `same`, `intentional difference`, or `blocker`.
3. If the destination adaptation added or corrected common behavior, create or update one focused source sync-back issue. Pin both landed commits and blobs.
4. Start a source sync-back only after issue setup and a free implementation slot. Adapt the common behavior; do not redesign it independently.
5. Prepare the source sync-back candidate and complete the task-local conditional repair PR lifecycle.
6. If the source changes, compare the new landed source result in the destination again. Use the same issue, slot, lifecycle, and evidence controls for each required destination repair.
7. Stop if the same matrix row changes direction twice. Run a new decision process that evaluates both implementations.
8. Close the cycle only when every common row is `same`, every intentional difference has complete evidence, and no blocker remains.
9. Post one permanent closure record with both repositories' final identities, the matrix digest, validation, review outcomes, and no-change or non-applicability results. If a dependent final-recheck task owns closure, post the current reciprocal record and leave final closure to that task.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

The Claude-command cycle has no common difference or blocker and has one permanent fixed-point record.

## Task 32 — close the Terraform initial-convergence tracker

> **Execution class: Coding agent executable.** This is an issue-evidence and closure task, not implementation.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 31 | `FS` | All five initial reciprocal cycles have permanent closure records. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Tracker contract

Terraform #31 retains evidence; it does not authorize an aggregate implementation PR. Its five ordered records are:

1. PS infrastructure conformance from Terraform PR #30.
2. PS generator and path convergence from Terraform PRs #26 and #30.
3. PS workflow and policy convergence from Terraform PRs #26 and #30.
4. PS #158 supply-freeze adaptation from Terraform PR #27.
5. PS Claude-command parity from commit `fbdecbae787055a2117d4ada83ae294a7decfe62`.

### Procedure

1. Re-query Terraform #31.
2. Verify that each cycle record contains the PS issue and landed PR; source and destination commits and blobs; a complete foundation matrix or justified reduced matrix; every focused Terraform sync issue and PR; the reverse PS comparison; validation and intentional differences; and the permanent fixed-point result.
3. Reconcile the tracker against PS #159 and PS #163. Correct a record only with verified evidence.
4. Close Terraform #31. Do not create or merge an aggregate foundation implementation PR.

### Complete when

Terraform #31 is closed and its five records match the permanent records in PSStyleGuide.

## Task 33 — implement Terraform #21 from the landed PS P1A source

> **Execution class: Coding agent executable.** Work in TerraformStyleGuide issue #21.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 32 | `FS` | The five initial cycles are closed and the final Terraform baseline is known. |

Terraform #21 exists, but its creation did not start implementation. Do not start Terraform #22 or #24 in this task.

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Immutable source and scope

- PS source issue and PR: [PS #146](https://github.com/franklesniak/PSStyleGuide/issues/146) and [PS PR #153](https://github.com/franklesniak/PSStyleGuide/pull/153).
- PS landed commit: `2d56357d9f52c76734027174bf62278e6f3d4cd6`.
- PS landed tree: `46f5f4e8627eb341ddc4ef0c8d52483dc4006b50`.
- Terraform #21 must retain its four pinned PS source blobs and exactly four affected paths.
- Preserve the 115-row PS allocation and 141-row Terraform allocation.
- Do not copy `CLAUDE.md`.
- Rebase only Terraform destination assumptions on the final Task 32 Terraform baseline. Do not change the immutable PS source pin.

### Procedure

1. Verify the five Task 32 closure records and the free implementation slot.
2. Re-query Terraform #21. Record its four source blobs, four destination paths, source and destination identities, and expected repository-specific differences.
3. Classify the capability as common.
4. Explicitly commence only Terraform #21.
5. Adapt the landed PS implementation. Do not redesign it independently or introduce a shared dependency.
6. Create or update one focused Terraform #21 PR. Run initial local validation and required checks.
7. Record its base, candidate head/tree, affected paths and destination blobs, validation, runtime identities, and issue links. Stop before merge.

### Candidate preparation gate

Before this task is complete:

1. Create or update only the focused PR for the stated issue or approved task.
2. Complete the issue scope, applicable local validation, an accurate PR body, and initial required checks.
3. Record the base, candidate head SHA and tree, affected paths, issue links, and every task-specific source, destination, validation, runtime, and intentional-difference identity.
4. Replace every placeholder and verify every posted identity.
5. Stop before the Claude Code review loop, independent final quality check, or merge. Do not perform a later lifecycle action in this task.

### Complete when

The Terraform #21 candidate PR exists with complete initial validation and an accurate PR body. Keep #21 open.

## Task 34 — run the Anthropic Claude Code review loop on the Terraform #21 PR

> **Execution class: Coding agent executable by Anthropic Claude Code.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 33 | `FS` | The Terraform #21 candidate PR exists and initial checks pass. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local Anthropic Claude Code review-loop prompt below in TerraformStyleGuide against the Terraform #21 PR. Read that repository's current root `CLAUDE.md`. Do not merge. If the loop changes bytes, rerun the Task 33 validation.

### Anthropic Claude Code review-loop prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a dedicated Anthropic Claude Code session:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

### Complete when

The loop returns `TERMINALLY CLEAN` for a recorded head SHA and tree.

## Task 35 — run the independent final quality check on the Terraform #21 PR

> **Execution class: Coding agent executable.** Use a fresh coding-agent session.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 34 | `FS` | The Claude Code review loop is terminally clean. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local independent final PR quality-check prompt below. Require all Terraform #21 requirements, four-path scope, 115/141-row allocation, comments, deferrals, PR-body accuracy, validation, checks, and mergeability. Return to Task 34 after any head change.

### Independent final PR quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a fresh coding-agent session after the Claude Code review loop is terminally clean:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

### Complete when

The fresh agent returns `PASS` for the same head SHA and tree as Task 34.

## Task 36 — merge the Terraform #21 PR and publish its implementation handoff

> **Execution class: Coding agent executable.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 35 | `FS` | The independent quality check passed for the current head and tree. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Apply the task-local merge gate below. Merge the focused PR. Record its base, reviewed head/tree, merge method, landed commit/tree, affected paths and destination blobs, validation, runtime identities, review-loop result, final quality-check result, and review outcome. Keep Terraform #21 open for reciprocal closure.

### Merge gate

Immediately before the merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

The Terraform #21 implementation is landed and its permanent implementation handoff contains every required identity and evidence item.

## Task 37 — reverse-compare Terraform #21 in PS and apply any sync-back

> **Execution class: Coding agent executable.** Work from a clean PSStyleGuide checkout after Task 36.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 36 | `FS` | Use the landed Terraform #21 result and immutable PS P1A commit. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Replace every placeholder in the reverse-comparison record with a verified identity.
2. Read PS only from `2d56357d9f52c76734027174bf62278e6f3d4cd6` and Terraform only from the Task 36 landed commit. Record every compared blob and map files by role.
3. Complete every applicable foundation row and the exact four-file mapping. Preserve the stated 115-row PS and 141-row Terraform allocations.
4. If no common difference remains, make no PS change and post a pinned reverse-comparison record.
5. If Terraform added or corrected common behavior, create or update one focused PS sync-back issue. Pin both landed commits and blobs.
6. Start the sync-back only after issue setup and a free implementation slot. Prepare one focused PS PR and run the four task-local conditional repair PR lifecycle actions.
7. If PS changes, compare its new landed commit in Terraform. For a required Terraform repair, run the same four task-local conditional repair PR lifecycle actions.
8. Stop for a new decision process if a row changes direction twice.
9. Post the current reciprocal evidence on Terraform #21 and the PS P1A handoff. Do not close Terraform #21 until Task 38 confirms the final Terraform state.

### Reverse-comparison and closure controls

1. Read both repositories only from the final pinned commits. Record every compared blob and map files by role.
2. Classify each applicable matrix row as `same`, `intentional difference`, or `blocker`.
3. If the destination adaptation added or corrected common behavior, create or update one focused source sync-back issue. Pin both landed commits and blobs.
4. Start a source sync-back only after issue setup and a free implementation slot. Adapt the common behavior; do not redesign it independently.
5. Prepare the source sync-back candidate and complete the task-local conditional repair PR lifecycle.
6. If the source changes, compare the new landed source result in the destination again. Use the same issue, slot, lifecycle, and evidence controls for each required destination repair.
7. Stop if the same matrix row changes direction twice. Run a new decision process that evaluates both implementations.
8. Close the cycle only when every common row is `same`, every intentional difference has complete evidence, and no blocker remains.
9. Post one permanent closure record with both repositories' final identities, the matrix digest, validation, review outcomes, and no-change or non-applicability results. If a dependent final-recheck task owns closure, post the current reciprocal record and leave final closure to that task.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

The reverse PS comparison and any PS sync-back are complete, and the final PS candidate identity is known.

## Task 38 — perform the final Terraform recheck and close Terraform #21

> **Execution class: Coding agent executable.** This is a final comparison and issue-closure task.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 37 | `FS` | Use the final landed PS state from Task 37. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Compare the final Task 37 PS landed commit against Terraform.
2. If a common difference remains, create a focused Terraform issue before implementation. Use the task-local execution controls, conditional repair PR lifecycle, and final reciprocal-recheck controls below until the row is `same` or a proved intentional difference.
3. Verify that every common row is `same`, every intentional difference has complete evidence, and no row is a blocker.
4. Post one permanent closure record on Terraform #21 and the PS P1A handoff. Include both repositories' final issue and PR URLs, bases, reviewed heads/trees, merge methods, landed commits/trees, affected paths, source and destination blobs, final matrix digest, validation, runtime identities, review outcomes, and explicit non-applicability results.
5. Close Terraform #21.

### Final reciprocal-recheck controls

1. Read the final source and destination states only from pinned commits. Record every compared blob and map files by role.
2. Classify each applicable matrix row as `same`, `intentional difference`, or `blocker`.
3. If a common destination difference remains, create one focused destination issue. Start it only after issue setup and a free implementation slot. Complete the task-local conditional repair PR lifecycle.
4. After each repair, compare the landed result in the other repository. Stop if the same row changes direction twice and run a new decision process that evaluates both implementations.
5. Close the cycle only when every common row is `same`, every intentional difference has complete evidence, and no blocker remains.
6. Post one permanent closure record with both repositories' final identities, the matrix digest, validation, review outcomes, and no-change or non-applicability results.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

Terraform #21 is closed at a proved reciprocal fixed point.

## Task 39 — inventory all untracked cross-repository differences

> **Execution class: Coding agent executable.** This is read-only analysis and does not start implementation.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 38 | `FS` | The P1A/Terraform #21 reciprocal cycle is closed. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Fetch both current `main` commits and trees in clean checkouts. Pin them as the sweep baselines.
2. Inventory every path that controls generation, validation, workflow policy, Actions permissions and pins, Node/npm acquisition, Markdown lint, Git/path checks, supply-freeze evidence, Dependabot, agent review commands, issue handoffs, and contributor instructions.
3. Map files by role. Do not infer role equality or difference from filenames alone.
4. For every common role, compare bytes and semantics, success and negative cases, failure classification, cleanup, credentials, permissions, native statuses, platform coverage, evidence retention, documentation, and validation commands.
5. Run the full foundation catalog for foundation roles. Use a documented reduced matrix only for a narrow non-foundation role.
6. Classify each row as `same`, `intentional difference`, `tracked work`, or `untracked blocker`.
7. Accept an intentional difference only under the task-local intentional-difference evidence requirements below. Link the owning issue for every `tracked work` row.
8. Treat a missing, duplicate, unknown, renamed, empty, or unexplained row as an `untracked blocker`.
9. For each untracked blocker, validate the finding and complete the required finding-specific decision process before proposing a repair.
10. Publish a read-only inventory that identifies the behind repository, affected role and blobs, evidence, owner/disposition, and proposed focused issue for each blocker. Do not edit implementation files in this task.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Complete when

Every inventoried role has one supported classification and owner. The report contains both baseline identities, file/blob maps, matrices and digests, evidence, and the exact ordered list of untracked blockers.

## Task 40 — close one untracked-blocker reciprocal cycle

> **Execution class: Coding agent executable.** This task is conditional. Repeat it serially for each Task 39 untracked blocker. If no blocker exists, record that result and skip this task.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 39 | `FS` | The complete read-only inventory and ordered blocker list exist. |
| Prior Task 40 instance | `FS` | Close the prior repair cycle before the next instance starts. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Select the next untracked blocker in the published order.
2. Create or update one focused issue in the behind repository. Pin the other repository's landed commit and source blobs.
3. Issue creation does not start implementation. Start only after issue setup and a free implementation slot.
4. Keep both repositories self-contained. Do not combine unrelated fixes or change settings without exact authorization.
5. Prepare one focused repair PR. Run the candidate, Claude Code review-loop, independent final quality-check, and merge actions as discrete lifecycle steps.
6. Compare the landed repair in the other repository. Post a pinned no-change record or run the same four discrete steps for one focused reciprocal repair.
7. Run the reverse comparison. Stop for a new decision process if a row changes direction twice.
8. Close the cycle only when every common row is `same`, all intentional differences have complete evidence, and no blocker remains.
9. Post the permanent closure record with both repositories' final issue and PR URLs, bases, reviewed heads/trees, merge methods, landed commits/trees, paths, blobs, matrix digest, validation, runtimes, review outcomes, and non-applicability results.
10. Repeat Task 40 only if another ordered blocker remains.

### Reciprocal fixed-point controls

1. Read both repositories only from pinned commits. Record every compared blob.
2. Map files by role, not only by filename.
3. Classify each applicable row as `same`, `intentional difference`, or `blocker`.
4. If no common difference exists, post a pinned no-change or non-applicability record. Do not open an implementation issue only for symmetry.
5. If a common difference exists, create or update one focused destination issue. Pin the source commit and blobs.
6. Start the destination adaptation only after issue setup and a free implementation slot. Adapt the landed capability; do not redesign it independently.
7. Prepare one destination candidate and complete the task-local conditional repair PR lifecycle. Record the complete landed identity and validation evidence.
8. Compare the landed destination result back against the source repository.
9. If the destination added or corrected common behavior, create a focused source sync-back issue. Start it only after issue setup and a free implementation slot.
10. Prepare the source sync-back candidate and complete the task-local conditional repair PR lifecycle. Then compare the new source result in the destination again.
11. Stop if the same matrix row changes direction twice. Run a new decision process that evaluates both implementations.
12. Close the cycle only when every common row is `same`, every intentional difference has complete evidence, and no blocker remains.
13. Post one permanent closure record with final identities from both repositories, the matrix digest, validation, review outcomes, and no-change or non-applicability results.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

One blocker cycle is closed at a fixed point. All Task 40 instances are complete when the Task 39 list has no unresolved blocker.

## Task 41 — finalize the global consistency sweep

> **Execution class: Coding agent executable.** This is a verification and evidence-publication task.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 39 | `FS` | The inventory exists. |
| Every applicable Task 40 instance | `FS` | All untracked blocker cycles are closed. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Fetch both final `main` commits and trees.
2. Re-run the complete inventory, file-role map, foundation catalog, and every required reduced matrix.
3. Verify that every role has an owner and disposition, each `tracked work` row links its live planned issue, and no `untracked blocker` remains.
4. Post the final sweep record. Include final commits/trees, file/blob map, matrices and digests, validation, runtimes, intentional differences, explicit non-applicability results, and zero untracked blockers.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Complete when

The permanent global-sweep record proves zero untracked blockers and identifies every remaining planned work item.

## Task 42 — prepare the PS P1B writer candidate and decision evidence

> **Execution class: Coding agent executable.** Work in PSStyleGuide issue #147. Do not merge or change repository settings in this task.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 41 | `FS` | The global sweep proves zero untracked blockers. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Re-read the final PS foundation handoff and every landed contract.
2. Reconcile each PS #147 assumption with those contracts.
3. Verify that the implementation slot is free. Explicitly start only #147.
4. Implement the writer and terminal check `Build Style Guide Artifacts / approve_candidate`.
5. Prepare an amendment or replacement for `docs/decisions/0001-accept-in-repository-trust-root.md`.
6. Create or update one PS #147 PR. Reach one locally validated candidate head. Record its exact head and tree.
7. Record workflow identity, permissions, required-check name, unique evidence ref, source pins, and rollback inputs.
8. Prepare the exact temporary and persistent settings requests and proof plan for PS #152.
9. Do not give the writer effective `contents: write` access before Task 46 records human approval.

### Candidate preparation gate

Before this task is complete:

1. Create or update only the focused PR for the stated issue or approved task.
2. Complete the issue scope, applicable local validation, an accurate PR body, and initial required checks.
3. Record the base, candidate head SHA and tree, affected paths, issue links, and every task-specific source, destination, validation, runtime, and intentional-difference identity.
4. Replace every placeholder and verify every posted identity.
5. Stop before the Claude Code review loop, independent final quality check, or merge. Do not perform a later lifecycle action in this task.

### Complete when

One locally validated P1B candidate and the complete decision/settings evidence package are ready. Keep the PR unmerged.

## Task 43 — prepare read-only PS #152 settings evidence

> **Execution class: Coding agent executable.** This is read-only preparation and can overlap Task 42.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 42 | `SS` | Begin only after Task 42 starts and its proposed design is identifiable. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Re-query PS #152 and current rules, classic branch protection, `main`, application identity, and writer permissions.
2. Preserve the Terraform PR #29 bypass-eligibility finding and the limited 2026-08-01 approval scope.
3. Map every requested temporary and persistent setting to the Task 42 candidate.
4. Prepare the non-mutating bypass-eligibility check, field-equivalent temporary-rule request, effective-bypass and rejection drills, evidence-retention plan, cleanup proof, exact-restoration proof, persistent-ruleset request, and rollback plan.
5. Identify every decision that needs owner or administrator approval. Do not infer approval from prior evidence.
6. Do not change a setting, create a rule, or give the writer effective write access.

### Complete when

PS #152 contains a complete, current, read-only evidence package that an owner can approve or reject without guessing.

## Task 44 — run the Anthropic Claude Code review loop on the PS #147 PR

> **Execution class: Coding agent executable by Anthropic Claude Code.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 42 | `FS` | The PS #147 candidate PR exists and initial checks pass. |
| Task 43 | `FS` | The read-only PS #152 evidence package is complete. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local Anthropic Claude Code review-loop prompt below against the PS #147 PR. Do not merge or change repository settings. If the loop changes bytes or the writer design, rerun the applicable Task 42 validation and refresh Task 43 settings evidence before the next round.

### Anthropic Claude Code review-loop prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a dedicated Anthropic Claude Code session:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

### Complete when

The loop returns `TERMINALLY CLEAN` for a recorded head SHA and tree, and the PS #152 evidence still maps to that exact candidate.

## Task 45 — run the independent final quality check on the PS #147 PR

> **Execution class: Coding agent executable.** Use a fresh coding-agent session.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 44 | `FS` | The Claude Code review loop is terminally clean. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local independent final PR quality-check prompt below. Require full PS #147 issue coverage; writer, evidence, lease/refspec, credential, terminal-result, rollback, comment, deferral, PR-body, validation, and mergeability checks; and consistency with the PS #152 settings request. Return to Task 44 after any head change.

### Independent final PR quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a fresh coding-agent session after the Claude Code review loop is terminally clean:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

### Complete when

The fresh agent returns `PASS` for the same head SHA and tree as Task 44, and the settings evidence still applies.

## Task 46 — approve or reject the P1B authority decisions

> **Execution class: Human execution required.** The repository owner or administrator must decide each item.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 43 | `FS` | Review the exact settings requests and proof plan. |
| Task 45 | `FS` | Review the exact candidate bytes and independent quality-check result. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Human actions

1. Review and approve or reject the proposed trust-root decision.
2. Review and approve or reject each temporary and persistent PS #152 settings request.
3. If integration ID `15368` is unavailable, select and approve another writer design.
4. Do not approve a substitute rule without also approving the writer design.
5. If the design permits human bypass, approve or reject that bypass in a separate decision.
6. Record every approval or rejection, condition, owner, canonical location, and expiry.
7. Do not reuse an approval for different bytes or settings.

### Complete when

The canonical records contain an explicit disposition for every required decision. A rejection sends the affected design back to Task 42 or Task 43 before work continues. After a candidate-byte change, rerun Tasks 44 and 45.

## Task 47 — prove and activate the approved PS #152 settings

> **Execution class: Coding agent executable.** Recorded human approval is a required input. Do not merge PS #147 in this task.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 46 | `FS` | Every applicable approval exists and applies to the current candidate and exact settings. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Verify all approvals. Stop if one is absent, expired, conditional on unmet work, or for different bytes or settings.
2. Revalidate the reviewed PS #147 head.
3. Start the bounded temporary proof under PS #152.
4. Export current rules, classic protection, `main`, application identity, and writer permissions.
5. Perform the non-mutating bypass-eligibility check.
6. If integration ID `15368` is unavailable, stop and return to Task 46.
7. Create the approved temporary field-equivalent rule.
8. Run the effective-bypass and rejection drills. Retain the required evidence.
9. Delete the temporary rule and evidence ref. Prove exact restoration.
10. Revalidate the reviewed PS #147 head.
11. As the final settings action, create the approved persistent ruleset immediately before Task 48.
12. Retain the create response, ruleset ID, normalized JSON, digest, effective rules, exact required check and integration, `main` before and after the setting change, and rollback proof.
13. Close PS #152 only after the persistent rule is active and evidence is complete.
14. Do not copy Terraform ruleset IDs, digests, effective-rule JSON, or audit records.

### Complete when

PS #152 is closed with a proved active persistent rule, complete retained evidence, exact restoration proof for temporary state, and rollback proof.

## Task 48 — merge PS P1B and publish its handoff

> **Execution class: Coding agent executable.** Work in PSStyleGuide issue #147.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 47 | `FS` | PS #152 is closed and the approved persistent rule is active. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Revalidate the reviewed PS #147 head, checks, workflow identity, required check, active ruleset, application identity, and approvals.
2. Stop if any byte, setting, identity, or approval differs from the proved state.
3. Apply the task-local merge gate below. Require the Task 44 terminal-clean record and Task 45 independent `PASS` record to match the current head and tree.
4. Merge the reviewed P1B PR and close PS #147.
5. Post the permanent P1B handoff for Terraform #22. Include all source and landed identities, paths and blobs, permission and credential boundaries, candidate consumption, ancestry/lease/refspec and native-status behavior, failure and cleanup postconditions, ruleset evidence, rollback proof, validation, review-loop result, final quality-check result, and review outcome.

### Merge gate

Immediately before the merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

PS #147 is closed by the proved merge and the permanent landed handoff is sufficient to implement Terraform #22 without redesign.

## Task 49 — update Terraform #22 from the landed PS P1B handoff

> **Execution class: Coding agent executable.** This is issue setup and does not start implementation.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 48 | `FS` | Use the landed PS P1B commit and permanent handoff. |
| Task 38 | `FS` | Terraform #21 is closed. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Issue update

Replace every placeholder with a verified identity and add or amend a `Starting point — reuse landed PSStyleGuide P1B` section in Terraform #22:

> PSStyleGuide P1B landed through `<PS_P1B_PR_URL>` at `<PS_P1B_LANDED_COMMIT>`, tree `<PS_P1B_LANDED_TREE>`. Use that landed implementation and permanent handoff `<PS_P1B_HANDOFF_URL>` as the T1B implementation source. Do not rebuild the writer, evidence protocol, lease/refspec checks, credential boundary, terminal result, or rollback design.
>
> This update records the starting point. It does not commence implementation. Do not create a feature branch or edit implementation files until this record is complete, the preceding cycle has a permanent closure record, and no feature implementation issue or PR is active.
>
> Record every PS source blob and every adapted Terraform destination blob. Change repository names, generated filenames, schema/type prefixes, check names, ruleset names, and local evidence identifiers. Preserve common permissions, job isolation, credential materialization, candidate consumption, ancestry/lease/refspec checks, native statuses, failure postconditions, cleanup, and audit truth.
>
> Use Terraform's own administrator issue and live settings evidence. Never copy PS ruleset IDs, request digests, application/rule responses, `main` values, or audit records. Refresh the reciprocal matrix at implementation start and before merge. An unexplained weaker behavior blocks merge.

### Complete when

Terraform #22 contains verified P1B source pins, scope, expected differences, settings boundary, and explicit start conditions.

## Task 50 — implement Terraform #22

> **Execution class: Coding agent executable.** Work in TerraformStyleGuide issue #22.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 49 | `FS` | The issue record is complete, Terraform #21 is closed, and the implementation slot is free. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Explicitly commence only Terraform #22 from the landed PS P1B commit and final Terraform baseline.
2. Adapt the writer and evidence protocol. Preserve the common controls named in Task 49.
3. Use only Terraform's authorized settings and live evidence.
4. Complete the reciprocal matrix at candidate preparation. Treat unexplained weaker behavior as a blocker.
5. Create or update one focused Terraform #22 PR. Run initial validation and required checks. Record its head SHA and tree. Stop before merge.

### Candidate preparation gate

Before this task is complete:

1. Create or update only the focused PR for the stated issue or approved task.
2. Complete the issue scope, applicable local validation, an accurate PR body, and initial required checks.
3. Record the base, candidate head SHA and tree, affected paths, issue links, and every task-specific source, destination, validation, runtime, and intentional-difference identity.
4. Replace every placeholder and verify every posted identity.
5. Stop before the Claude Code review loop, independent final quality check, or merge. Do not perform a later lifecycle action in this task.

### Complete when

The Terraform #22 candidate PR exists with complete source, destination, validation, settings, and audit evidence.

## Task 51 — run the Anthropic Claude Code review loop on the Terraform #22 PR

> **Execution class: Coding agent executable by Anthropic Claude Code.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 50 | `FS` | The Terraform #22 candidate PR exists and initial checks pass. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local Anthropic Claude Code review-loop prompt below in TerraformStyleGuide. Do not merge or change settings without exact authorization. If bytes change, rerun Task 50 validation and refresh the reciprocal matrix.

### Anthropic Claude Code review-loop prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a dedicated Anthropic Claude Code session:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

### Complete when

The loop returns `TERMINALLY CLEAN` for a recorded head SHA and tree.

## Task 52 — run the independent final quality check on the Terraform #22 PR

> **Execution class: Coding agent executable.** Use a fresh coding-agent session.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 51 | `FS` | The Claude Code review loop is terminally clean. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local independent final PR quality-check prompt below. Require complete Terraform #22 issue, writer, settings, permissions, credentials, evidence, comment, deferral, PR-body, validation, and mergeability coverage. Return to Task 51 after any head change.

### Independent final PR quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a fresh coding-agent session after the Claude Code review loop is terminally clean:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

### Complete when

The fresh agent returns `PASS` for the same head SHA and tree as Task 51.

## Task 53 — merge the Terraform #22 PR and publish its handoff

> **Execution class: Coding agent executable.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 52 | `FS` | The independent quality check passed for the current head and tree. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Apply the task-local merge gate below. Merge the PR, close Terraform #22, and post the complete landed handoff with source, destination, validation, settings, audit, review-loop, and final quality-check evidence.

### Merge gate

Immediately before the merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

Terraform #22 is closed by the landed PR and its complete handoff is ready for reverse comparison.

## Task 54 — reverse-compare T1B in PS and apply any sync-back

> **Execution class: Coding agent executable.** Work from a clean PSStyleGuide checkout.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 53 | `FS` | Use only the landed P1B and T1B commits and blobs. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Use the task-local reverse-comparison and closure controls below and complete catalog. Preserve repository-specific settings identities. If Terraform added or corrected common behavior, prepare one focused PS sync-back and run the four task-local conditional repair PR lifecycle actions. If PS changes, compare Terraform again and run the same lifecycle for any required repair. Post the current reciprocal record without closing the cycle until Task 55.

### Reverse-comparison and closure controls

1. Read both repositories only from the final pinned commits. Record every compared blob and map files by role.
2. Classify each applicable matrix row as `same`, `intentional difference`, or `blocker`.
3. If the destination adaptation added or corrected common behavior, create or update one focused source sync-back issue. Pin both landed commits and blobs.
4. Start a source sync-back only after issue setup and a free implementation slot. Adapt the common behavior; do not redesign it independently.
5. Prepare the source sync-back candidate and complete the task-local conditional repair PR lifecycle.
6. If the source changes, compare the new landed source result in the destination again. Use the same issue, slot, lifecycle, and evidence controls for each required destination repair.
7. Stop if the same matrix row changes direction twice. Run a new decision process that evaluates both implementations.
8. Close the cycle only when every common row is `same`, every intentional difference has complete evidence, and no blocker remains.
9. Post one permanent closure record with both repositories' final identities, the matrix digest, validation, review outcomes, and no-change or non-applicability results. If a dependent final-recheck task owns closure, post the current reciprocal record and leave final closure to that task.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

The reverse PS comparison and any PS sync-back are complete, and the final PS identity is known.

## Task 55 — perform the final Terraform T1B recheck

> **Execution class: Coding agent executable.** This is a comparison and closure task.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 54 | `FS` | Use the final landed PS state from Task 54. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Compare the final PS state back in Terraform. If a focused Terraform repair is required, run the four task-local conditional repair PR lifecycle actions. Apply the row-direction stop rule. Post the permanent P1B/T1B closure record with all required identities and evidence.

### Final reciprocal-recheck controls

1. Read the final source and destination states only from pinned commits. Record every compared blob and map files by role.
2. Classify each applicable matrix row as `same`, `intentional difference`, or `blocker`.
3. If a common destination difference remains, create one focused destination issue. Start it only after issue setup and a free implementation slot. Complete the task-local conditional repair PR lifecycle.
4. After each repair, compare the landed result in the other repository. Stop if the same row changes direction twice and run a new decision process that evaluates both implementations.
5. Close the cycle only when every common row is `same`, every intentional difference has complete evidence, and no blocker remains.
6. Post one permanent closure record with both repositories' final identities, the matrix digest, validation, review outcomes, and no-change or non-applicability results.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

The P1B/T1B cycle is at a fixed point and no blocker remains. Do not start PS #148 before this result.

## Task 56 — implement PS #148

> **Execution class: Coding agent executable.** Work in PSStyleGuide issue #148.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 55 | `FS` | The P1B/T1B cycle is closed and the implementation slot is free. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Re-query PS #148 and its native dependency. Classify the capability and pin all landed inputs and affected paths.
2. Explicitly commence only PS #148.
3. Implement the issue contract.
4. Create or update one focused PS #148 PR. Run initial local validation and required checks. Record its head SHA and tree. Stop before merge.

### Candidate preparation gate

Before this task is complete:

1. Create or update only the focused PR for the stated issue or approved task.
2. Complete the issue scope, applicable local validation, an accurate PR body, and initial required checks.
3. Record the base, candidate head SHA and tree, affected paths, issue links, and every task-specific source, destination, validation, runtime, and intentional-difference identity.
4. Replace every placeholder and verify every posted identity.
5. Stop before the Claude Code review loop, independent final quality check, or merge. Do not perform a later lifecycle action in this task.

### Complete when

The PS #148 candidate PR exists with all required identities, initial validation, and issue-contract evidence.

## Task 57 — run the Anthropic Claude Code review loop on the PS #148 PR

> **Execution class: Coding agent executable by Anthropic Claude Code.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 56 | `FS` | The PS #148 candidate PR exists and initial checks pass. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local Anthropic Claude Code review-loop prompt below against the PS #148 PR. Do not merge. If bytes change, rerun Task 56 validation.

### Anthropic Claude Code review-loop prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a dedicated Anthropic Claude Code session:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

### Complete when

The loop returns `TERMINALLY CLEAN` for a recorded head SHA and tree.

## Task 58 — run the independent final quality check on the PS #148 PR

> **Execution class: Coding agent executable.** Use a fresh coding-agent session.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 57 | `FS` | The Claude Code review loop is terminally clean. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local independent final PR quality-check prompt below. Require complete PS #148 issue-contract, comment, deferral, PR-body, final-diff, validation, checks, and mergeability coverage. Return to Task 57 after any head change.

### Independent final PR quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a fresh coding-agent session after the Claude Code review loop is terminally clean:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

### Complete when

The fresh agent returns `PASS` for the same head SHA and tree as Task 57.

## Task 59 — merge the PS #148 PR and publish its handoff

> **Execution class: Coding agent executable.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 58 | `FS` | The independent quality check passed for the current head and tree. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Apply the task-local merge gate below. Merge the PR, close PS #148, and post the complete landed PS handoff with issue-contract, validation, review-loop, and final quality-check evidence.

### Merge gate

Immediately before the merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

PS #148 is closed by the landed PR and its handoff is ready for Terraform comparison.

## Task 60 — compare PS #148 in Terraform and adapt if applicable

> **Execution class: Coding agent executable.** Work in TerraformStyleGuide after Task 59.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 59 | `FS` | Use the final landed PS #148 commit and blobs. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Compare the affected PS #148 role with Terraform.
2. If common behavior is absent or weaker, create one focused Terraform issue from the landed PS handoff, then run the four task-local conditional repair PR lifecycle actions.
3. If Terraform is already equivalent, post a pinned no-change record.
4. If the blank-line example is PowerShell-specific, post a pinned non-applicability record.
5. Do not create an issue only for symmetry.

### Destination-comparison controls

1. Read both repositories only from pinned commits. Record every compared blob.
2. Map files by role, not only by filename.
3. Classify each applicable matrix row as `same`, `intentional difference`, or `blocker`.
4. If no common difference exists, post a pinned no-change or non-applicability record. Do not open an implementation issue only for symmetry.
5. If a common difference exists, create or update one focused destination issue. Pin the source commit and blobs.
6. Start the destination adaptation only after issue setup and a free implementation slot. Adapt the landed capability; do not redesign it independently.
7. Prepare one destination candidate and complete the task-local conditional repair PR lifecycle. Record the complete landed identity and validation evidence.
8. Stop this task at its stated destination result. The dependent reverse-comparison task must compare the landed destination result back against the source before the cycle can close.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

Terraform has a landed applicable adaptation, a pinned no-change result, or a proved non-applicability record.

## Task 61 — reverse-compare the PS #148 cycle and close its fixed point

> **Execution class: Coding agent executable.** Work in PSStyleGuide after Task 60.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 60 | `FS` | Use the final landed or no-change result from Task 60. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Use the task-local reverse-comparison and closure controls below with the applicable complete or reduced matrix. For any focused PS sync-back or later Terraform repair, run the four task-local conditional repair PR lifecycle actions. Post the permanent closure or non-applicability record.

### Reverse-comparison and closure controls

1. Read both repositories only from the final pinned commits. Record every compared blob and map files by role.
2. Classify each applicable matrix row as `same`, `intentional difference`, or `blocker`.
3. If the destination adaptation added or corrected common behavior, create or update one focused source sync-back issue. Pin both landed commits and blobs.
4. Start a source sync-back only after issue setup and a free implementation slot. Adapt the common behavior; do not redesign it independently.
5. Prepare the source sync-back candidate and complete the task-local conditional repair PR lifecycle.
6. If the source changes, compare the new landed source result in the destination again. Use the same issue, slot, lifecycle, and evidence controls for each required destination repair.
7. Stop if the same matrix row changes direction twice. Run a new decision process that evaluates both implementations.
8. Close the cycle only when every common row is `same`, every intentional difference has complete evidence, and no blocker remains.
9. Post one permanent closure record with both repositories' final identities, the matrix digest, validation, review outcomes, and no-change or non-applicability results. If a dependent final-recheck task owns closure, post the current reciprocal record and leave final closure to that task.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

The PS #148 cross-repository cycle is closed with no blocker.

## Task 62 — implement Terraform #23

> **Execution class: Coding agent executable.** Work in TerraformStyleGuide issue #23.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 61 | `FS` | The PS #148 cycle is closed and the implementation slot is free. |
| Task 53 | `FS` | Terraform #22, the native predecessor of #23, is closed. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Re-query Terraform #23 and verify its native prerequisites.
2. Classify it as Terraform-specific unless comparison proves a common PS role.
3. Explicitly commence only Terraform #23.
4. Implement its state-version recovery contract.
5. Create or update one focused Terraform #23 PR. Run initial local validation and required checks. Record its head SHA and tree. Stop before merge.

### Candidate preparation gate

Before this task is complete:

1. Create or update only the focused PR for the stated issue or approved task.
2. Complete the issue scope, applicable local validation, an accurate PR body, and initial required checks.
3. Record the base, candidate head SHA and tree, affected paths, issue links, and every task-specific source, destination, validation, runtime, and intentional-difference identity.
4. Replace every placeholder and verify every posted identity.
5. Stop before the Claude Code review loop, independent final quality check, or merge. Do not perform a later lifecycle action in this task.

### Complete when

The Terraform #23 candidate PR exists with complete initial identity, validation, failure, recovery, and evidence records.

## Task 63 — run the Anthropic Claude Code review loop on the Terraform #23 PR

> **Execution class: Coding agent executable by Anthropic Claude Code.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 62 | `FS` | The Terraform #23 candidate PR exists and initial checks pass. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local Anthropic Claude Code review-loop prompt below in TerraformStyleGuide. Do not merge. If bytes change, rerun Task 62 validation.

### Anthropic Claude Code review-loop prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a dedicated Anthropic Claude Code session:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

### Complete when

The loop returns `TERMINALLY CLEAN` for a recorded head SHA and tree.

## Task 64 — run the independent final quality check on the Terraform #23 PR

> **Execution class: Coding agent executable.** Use a fresh coding-agent session.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 63 | `FS` | The Claude Code review loop is terminally clean. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local independent final PR quality-check prompt below. Require complete Terraform #23 state-version recovery, issue, comment, deferral, PR-body, final-diff, validation, checks, and mergeability coverage. Return to Task 63 after any head change.

### Independent final PR quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a fresh coding-agent session after the Claude Code review loop is terminally clean:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

### Complete when

The fresh agent returns `PASS` for the same head SHA and tree as Task 63.

## Task 65 — merge the Terraform #23 PR and publish its handoff

> **Execution class: Coding agent executable.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 64 | `FS` | The independent quality check passed for the current head and tree. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Apply the task-local merge gate below. Merge the PR, close Terraform #23, and post the complete landed identity, validation, failure, recovery, evidence, review-loop, and final quality-check record.

### Merge gate

Immediately before the merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

Terraform #23 is closed by the landed PR and its handoff is ready for PS applicability review.

## Task 66 — evaluate Terraform #23 applicability in PS

> **Execution class: Coding agent executable.** This is a comparison task and is conditional for implementation.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 65 | `FS` | Use the landed Terraform #23 commit and blobs. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Search PS for a role affected by Terraform #23's state-version recovery behavior.
2. If PS has a common role and is absent or weaker, create one focused PS issue, then use the task-local execution controls, conditional repair PR lifecycle, and reciprocal fixed-point controls below.
3. If PS is already equivalent, post a pinned no-change record.
4. If PS has no corresponding role, post a pinned non-applicability record.
5. Do not invent a PS issue only for symmetry.

### Reciprocal fixed-point controls

1. Read both repositories only from pinned commits. Record every compared blob.
2. Map files by role, not only by filename.
3. Classify each applicable row as `same`, `intentional difference`, or `blocker`.
4. If no common difference exists, post a pinned no-change or non-applicability record. Do not open an implementation issue only for symmetry.
5. If a common difference exists, create or update one focused destination issue. Pin the source commit and blobs.
6. Start the destination adaptation only after issue setup and a free implementation slot. Adapt the landed capability; do not redesign it independently.
7. Prepare one destination candidate and complete the task-local conditional repair PR lifecycle. Record the complete landed identity and validation evidence.
8. Compare the landed destination result back against the source repository.
9. If the destination added or corrected common behavior, create a focused source sync-back issue. Start it only after issue setup and a free implementation slot.
10. Prepare the source sync-back candidate and complete the task-local conditional repair PR lifecycle. Then compare the new source result in the destination again.
11. Stop if the same matrix row changes direction twice. Run a new decision process that evaluates both implementations.
12. Close the cycle only when every common row is `same`, every intentional difference has complete evidence, and no blocker remains.
13. Post one permanent closure record with final identities from both repositories, the matrix digest, validation, review outcomes, and no-change or non-applicability results.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

The Task 65 result has one proved PS disposition and every applicable reciprocal repair is at a fixed point.

## Task 67 — prepare the PS P3 candidate for merge

> **Execution class: Coding agent executable.** Work in PSStyleGuide issue #149. Prepare a candidate; do not merge before the later owner decision.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 66 | `FS` | Terraform #23 and its PS applicability cycle are complete. |
| Task 48 | `FS` | The P1B PS handoff exists. |
| Task 59 | `FS` | The P2 PS handoff exists. |
| Completed PS #145 and #146 | `FS` | The P1 and P1A handoffs exist. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Scope

PS #149 owns the PS Husky preparation mechanism and dependency/update-governance convergence. Compare Terraform #24's current contract and Terraform's direct `prepare` command. Select one common mechanism unless a proved repository-specific need requires a difference.

### Procedure

1. Verify the P1, P1A, P1B, and P2 landed handoffs and all native issue dependencies.
2. Re-query PS #149, Terraform #24, and current dependency, package-manager, audit, process-runner, exception, Husky, workflow, and evidence contracts.
3. Pin every source commit and blob. Record intended paths and expected repository-specific differences.
4. Verify the implementation slot is free. Explicitly commence only PS #149.
5. Implement the complete PS #149 contract. Preserve common isolation, exact toolchain selection, install/audit vectors, configuration neutralization, bounded process I/O, termination states, JSON validation, exception governance, live-issue verification, scheduled/manual read-only behavior, failure truth, and evidence retention.
6. Create or update one PS #149 PR. Reach one locally validated candidate head. Record its base, head/tree, checks, paths and blobs, validation, runtime identities, decision-record changes, and rollback inputs.
7. Stop before review-loop execution or merge.

### Candidate preparation gate

Before this task is complete:

1. Create or update only the focused PR for the stated issue or approved task.
2. Complete the issue scope, applicable local validation, an accurate PR body, and initial required checks.
3. Record the base, candidate head SHA and tree, affected paths, issue links, and every task-specific source, destination, validation, runtime, and intentional-difference identity.
4. Replace every placeholder and verify every posted identity.
5. Stop before the Claude Code review loop, independent final quality check, or merge. Do not perform a later lifecycle action in this task.

### Complete when

PS #149 has one locally validated candidate PR and a verified evidence package.

## Task 68 — run the Anthropic Claude Code review loop on the PS #149 PR

> **Execution class: Coding agent executable by Anthropic Claude Code.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 67 | `FS` | The PS #149 candidate PR exists and initial checks pass. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local Anthropic Claude Code review-loop prompt below against the PS #149 PR. Do not merge. If bytes change, rerun Task 67 validation and refresh its evidence package.

### Anthropic Claude Code review-loop prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a dedicated Anthropic Claude Code session:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

### Complete when

The loop returns `TERMINALLY CLEAN` for a recorded head SHA and tree.

## Task 69 — run the independent final quality check on the PS #149 PR

> **Execution class: Coding agent executable.** Use a fresh coding-agent session.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 68 | `FS` | The Claude Code review loop is terminally clean. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local independent final PR quality-check prompt below. Require complete PS #149 governance, dependency, audit, Husky, exception, scheduled/manual behavior, issue, comment, deferral, PR-body, validation, and mergeability coverage. Return to Task 68 after any head change.

### Independent final PR quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a fresh coding-agent session after the Claude Code review loop is terminally clean:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

### Complete when

The fresh agent returns `PASS` for the same head SHA and tree as Task 68. The PR is eligible for the checkpoint decision but remains unmerged.

## Task 70 — check the PS #149 advisory-deadline state

> **Execution class: Coding agent executable.** Run this task at exactly `2026-08-21T23:59:59Z`. It is a status check, not implementation.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| None | Calendar constraint | Run at `2026-08-21T23:59:59Z` even if an earlier numbered task is incomplete. |

The PS P1 advisory decision expires at `2026-08-30T23:59:59Z`. The checkpoint is a coordination gate, not a native issue dependency.

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Re-query PS #149 and the P1, P1A, P1B, and P2 handoffs.
2. Record each issue and PR state, reviewed head, checks, dependency state, and merge readiness.
3. If PS #149 is merge-ready, record that its current merge path is available for Task 71.
4. If PS #149 is not merge-ready, prepare the fallback evidence package for Task 71.
5. Record incomplete earlier tasks explicitly. Do not wait beyond the checkpoint and do not create a false PS #149 dependency.

### Complete when

One timestamped, verified checkpoint record states whether the PS #149 merge path is ready and contains the evidence needed for the owner decision.

## Task 71 — select and approve the PS #149 deadline path

> **Execution class: Human execution required.** The repository owner must select the deadline path.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 70 | `FS` | Use the exact timestamped checkpoint evidence. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Human actions

1. If PS #149 is merge-ready, approve or reject its existing merge path.
2. If PS #149 is not merge-ready, approve or reject a separate superseding-decision task.
3. If the superseding task is approved, set its start date to `2026-08-22`.
4. Record the approved scope, owner, canonical approval, and expiry.
5. Approve every repository-settings change in the applicable administrator issue.
6. Do not extend the expiry without a new recorded decision.
7. Do not reuse approval for different bytes or settings.

### Complete when

The canonical record approves the current PS #149 merge path or a separate fallback, or explicitly rejects both. If it rejects both, stop the affected sequence and obtain a new owner decision before Task 76.

## Task 72 — implement an approved advisory fallback

> **Execution class: Coding agent executable.** This task requires explicit fallback approval. Skip it if Task 71 approves the existing PS #149 merge path and does not require a fallback.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 71 | `FS` | The owner approved a separate superseding-decision task and its exact scope. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Verify that no feature implementation issue or PR is active. If the PS #149 PR is still active, preserve its exact head and tree. Close it only when the Task 71 approval expressly authorizes closure. Otherwise, do not start fallback implementation.
2. Prepare the complete fallback from the approved scope.
3. Include the current audit, every accepted finding, each reason, and each compensating control.
4. Include the canonical approval and expiry, exact replacement contract bytes, validator and case changes, and every dependent version, digest, and name pin.
5. Include validation and rollback instructions.
6. Create one focused fallback PR under the separately approved task. Run initial local validation and required checks. Record its head SHA and tree.
7. Prove on the candidate that the validator does not enter `advisory-expired`. Stop before merge.

### Candidate preparation gate

Before this task is complete:

1. Create or update only the focused PR for the stated issue or approved task.
2. Complete the issue scope, applicable local validation, an accurate PR body, and initial required checks.
3. Record the base, candidate head SHA and tree, affected paths, issue links, and every task-specific source, destination, validation, runtime, and intentional-difference identity.
4. Replace every placeholder and verify every posted identity.
5. Stop before the Claude Code review loop, independent final quality check, or merge. Do not perform a later lifecycle action in this task.

### Complete when

The approved fallback candidate PR exists with all required decision, identity, initial validation, and rollback evidence.

## Task 73 — run the Anthropic Claude Code review loop on the fallback PR

> **Execution class: Coding agent executable by Anthropic Claude Code.** Skip this task when Task 72 is skipped.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 72 | `FS` | The approved fallback candidate PR exists and initial checks pass. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local Anthropic Claude Code review-loop prompt below against the fallback PR. Do not merge. If bytes change, rerun Task 72 validation and expiry proof.

### Anthropic Claude Code review-loop prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a dedicated Anthropic Claude Code session:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

### Complete when

The loop returns `TERMINALLY CLEAN` for a recorded head SHA and tree.

## Task 74 — run the independent final quality check on the fallback PR

> **Execution class: Coding agent executable.** Use a fresh coding-agent session. Skip this task when Task 72 is skipped.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 73 | `FS` | The Claude Code review loop is terminally clean. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local independent final PR quality-check prompt below. Require exact approval/scope, advisory-expiry, contract, validator, case, pin, rollback, comment, deferral, PR-body, validation, and mergeability coverage. Return to Task 73 after any head change.

### Independent final PR quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a fresh coding-agent session after the Claude Code review loop is terminally clean:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

### Complete when

The fresh agent returns `PASS` for the same head SHA and tree as Task 73.

## Task 75 — merge the approved fallback PR

> **Execution class: Coding agent executable.** Skip this task when Task 72 is skipped.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 74 | `FS` | The independent quality check passed for the current head and tree. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Apply the task-local merge gate below. Merge the approved fallback before `2026-08-30T23:59:59Z`. Prove that the validator never enters `advisory-expired`. Record the landed identity, validation, review-loop result, final quality-check result, and rollback evidence.

### Merge gate

Immediately before the merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

The approved fallback is landed with all required evidence before advisory expiry.

## Task 76 — land PS #149 and publish the P3 handoff

> **Execution class: Coding agent executable.** Work in PSStyleGuide issue #149.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 69 | `FS` | The PS #149 candidate passed review and the independent quality check. |
| Task 71 | `FS` | The owner approved the current merge path or supplied a later applicable approval. |
| Task 75 | `FS` when applicable | The approved fallback is landed. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Revalidate the approved candidate head, tree, checks, dependencies, decisions, settings, and approval.
2. If Task 75 changed an input or overlapping path, rebase or update the PS #149 candidate. Return to Task 68 for the Claude Code review loop and Task 69 for a new independent quality check. Obtain a new Task 71 approval when the prior approval does not cover the resulting bytes.
3. Stop if any item still differs from the approved evidence.
4. Apply the task-local merge gate below.
5. Merge one PS #149 PR and close the issue.
6. Post the permanent P3 handoff. Include source and landed identities, paths and blobs, common mechanism choice, package and tool identities, validation, runtime evidence, decision records, review-loop result, final quality-check result, intentional differences, and rollback instructions.

### Candidate-refresh gate

Apply this gate only if Procedure step 2 changes the PS #149 PR:

1. Complete the affected issue scope, local validation, PR-body correction, and initial required checks on the new candidate.
2. Record the new base, head SHA and tree, affected paths, issue links, validation, runtime identities, and changed decision or rollback evidence.
3. Stop the merge action. Return to Task 68 for a new Claude Code review loop and Task 69 for a new independent final quality check.
4. Require a new Task 71 approval when the current approval does not cover the new bytes or settings. Do not resume this task until all three records apply to the same current head and tree.

### Merge gate

Immediately before the merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

PS #149 is closed by the approved merge and Terraform #24 can adapt the landed result without redesign.

## Task 77 — update Terraform #24 from the landed PS P3 handoff

> **Execution class: Coding agent executable.** This is issue setup and does not start implementation.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 76 | `FS` | Use the final landed PS #149 commit and handoff. |
| Task 65 | `FS` | Terraform #23, the native predecessor of #24, is closed. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Issue update

Replace all placeholders with verified identities and update Terraform #24:

> PSStyleGuide dependency and npm governance landed through `<PS_P3_PR_URL>` at `<PS_P3_LANDED_COMMIT>`, tree `<PS_P3_LANDED_TREE>`. Use permanent handoff `<PS_P3_HANDOFF_URL>` as the implementation source.
>
> This update records the starting point. It does not commence implementation. Do not create a feature branch or edit implementation files until this record is complete, the preceding cycle has a permanent closure record, and no feature implementation issue or PR is active.
>
> Read every relevant PS source blob from that commit. Do not independently select a package-manager policy, audit parser, process runner, exception schema, Husky installer, workflow topology, or evidence format. Adapt repository identity, issue URLs, package findings, generated filenames, check names, and Terraform-specific dependency graph.
>
> Preserve common isolation, exact toolchain selection, install/audit vectors, configuration neutralization, bounded process I/O, termination states, JSON validation, exception governance, live-issue verification, scheduled/manual read-only behavior, and failure truth. Refresh the reciprocal matrix at start and before merge. An unexplained weaker behavior blocks merge.

### Complete when

Terraform #24 contains the complete pinned starting point, scope, common controls, allowed adaptation surface, and start conditions.

## Task 78 — implement Terraform #24

> **Execution class: Coding agent executable.** Work in TerraformStyleGuide issue #24.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 77 | `FS` | The issue update is complete and the implementation slot is free. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Explicitly commence only Terraform #24 from the landed PS P3 source.
2. Adapt the capability; do not independently redesign the named contracts.
3. Preserve all common controls from Task 77 and record every repository-specific adaptation.
4. Complete the reciprocal matrix at candidate preparation.
5. Create or update one focused Terraform #24 PR. Run initial local validation and required checks. Record its head SHA and tree. Stop before merge.

### Candidate preparation gate

Before this task is complete:

1. Create or update only the focused PR for the stated issue or approved task.
2. Complete the issue scope, applicable local validation, an accurate PR body, and initial required checks.
3. Record the base, candidate head SHA and tree, affected paths, issue links, and every task-specific source, destination, validation, runtime, and intentional-difference identity.
4. Replace every placeholder and verify every posted identity.
5. Stop before the Claude Code review loop, independent final quality check, or merge. Do not perform a later lifecycle action in this task.

### Complete when

The Terraform #24 candidate PR exists with complete source, destination, identity, initial validation, runtime, and intentional-difference evidence.

## Task 79 — run the Anthropic Claude Code review loop on the Terraform #24 PR

> **Execution class: Coding agent executable by Anthropic Claude Code.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 78 | `FS` | The Terraform #24 candidate PR exists and initial checks pass. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local Anthropic Claude Code review-loop prompt below in TerraformStyleGuide. Do not merge. If bytes change, rerun Task 78 validation and refresh the reciprocal matrix.

### Anthropic Claude Code review-loop prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a dedicated Anthropic Claude Code session:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

### Complete when

The loop returns `TERMINALLY CLEAN` for a recorded head SHA and tree.

## Task 80 — run the independent final quality check on the Terraform #24 PR

> **Execution class: Coding agent executable.** Use a fresh coding-agent session.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 79 | `FS` | The Claude Code review loop is terminally clean. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local independent final PR quality-check prompt below. Require complete Terraform #24 package, audit, exception, Husky, workflow, issue, comment, deferral, PR-body, validation, checks, and mergeability coverage. Return to Task 79 after any head change.

### Independent final PR quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a fresh coding-agent session after the Claude Code review loop is terminally clean:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

### Complete when

The fresh agent returns `PASS` for the same head SHA and tree as Task 79.

## Task 81 — merge the Terraform #24 PR and publish its handoff

> **Execution class: Coding agent executable.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 80 | `FS` | The independent quality check passed for the current head and tree. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Apply the task-local merge gate below. Merge the PR, close Terraform #24, and post the full landed handoff with source and destination blobs, identities, validation, runtimes, review-loop result, final quality-check result, and intentional differences.

### Merge gate

Immediately before the merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

Terraform #24 is closed by the landed PR and the result is ready for reverse PS comparison.

## Task 82 — reverse-compare T3 in PS and apply any sync-back

> **Execution class: Coding agent executable.** Work from a clean PSStyleGuide checkout.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 81 | `FS` | Use only the landed PS #149 and Terraform #24 commits and blobs. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Use the task-local reverse-comparison and closure controls below and complete catalog. Compare the Husky mechanism and every common dependency/update-governance behavior. If Terraform added or corrected common behavior, run the four task-local conditional repair PR lifecycle actions for one focused PS sync-back. Compare Terraform again if PS changes and use the same lifecycle for any further repair. Post the current evidence without closing the cycle until Task 83.

### Reverse-comparison and closure controls

1. Read both repositories only from the final pinned commits. Record every compared blob and map files by role.
2. Classify each applicable matrix row as `same`, `intentional difference`, or `blocker`.
3. If the destination adaptation added or corrected common behavior, create or update one focused source sync-back issue. Pin both landed commits and blobs.
4. Start a source sync-back only after issue setup and a free implementation slot. Adapt the common behavior; do not redesign it independently.
5. Prepare the source sync-back candidate and complete the task-local conditional repair PR lifecycle.
6. If the source changes, compare the new landed source result in the destination again. Use the same issue, slot, lifecycle, and evidence controls for each required destination repair.
7. Stop if the same matrix row changes direction twice. Run a new decision process that evaluates both implementations.
8. Close the cycle only when every common row is `same`, every intentional difference has complete evidence, and no blocker remains.
9. Post one permanent closure record with both repositories' final identities, the matrix digest, validation, review outcomes, and no-change or non-applicability results. If a dependent final-recheck task owns closure, post the current reciprocal record and leave final closure to that task.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

The reverse PS comparison and any PS sync-back are complete, and the final PS identity is known.

## Task 83 — perform the final Terraform T3 recheck

> **Execution class: Coding agent executable.** This is a comparison and closure task.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 82 | `FS` | Use the final landed PS state from Task 82. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Compare the final PS state back in Terraform. If a focused Terraform repair is required, run the four task-local conditional repair PR lifecycle actions. Apply the row-direction stop rule. Post the permanent P3/T3 closure record with all required identities, matrices, validation, reviews, and non-applicability results.

### Final reciprocal-recheck controls

1. Read the final source and destination states only from pinned commits. Record every compared blob and map files by role.
2. Classify each applicable matrix row as `same`, `intentional difference`, or `blocker`.
3. If a common destination difference remains, create one focused destination issue. Start it only after issue setup and a free implementation slot. Complete the task-local conditional repair PR lifecycle.
4. After each repair, compare the landed result in the other repository. Stop if the same row changes direction twice and run a new decision process that evaluates both implementations.
5. Close the cycle only when every common row is `same`, every intentional difference has complete evidence, and no blocker remains.
6. Post one permanent closure record with both repositories' final identities, the matrix digest, validation, review outcomes, and no-change or non-applicability results.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

The P3/T3 cycle is at a fixed point and no blocker remains.

## Task 84 — implement PS #151

> **Execution class: Coding agent executable.** Work in PSStyleGuide issue #151.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 83 | `FS` | PS #149 and its full reciprocal cycle are closed. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Re-query PS #151 and all landed policy and P3 contracts.
2. Verify the implementation slot is free. Explicitly commence only PS #151.
3. Implement the issue's Node permission-model confinement and duplicate-key preflight controls without silently attributing them to PS #162.
4. Create or update one focused PS #151 PR. Run initial local validation and required checks. Record its head SHA and tree, affected controls, files and blobs, runtimes, and intentional differences. Stop before merge.

### Candidate preparation gate

Before this task is complete:

1. Create or update only the focused PR for the stated issue or approved task.
2. Complete the issue scope, applicable local validation, an accurate PR body, and initial required checks.
3. Record the base, candidate head SHA and tree, affected paths, issue links, and every task-specific source, destination, validation, runtime, and intentional-difference identity.
4. Replace every placeholder and verify every posted identity.
5. Stop before the Claude Code review loop, independent final quality check, or merge. Do not perform a later lifecycle action in this task.

### Complete when

The PS #151 candidate PR exists with a complete affected-control map and initial validation.

## Task 85 — run the Anthropic Claude Code review loop on the PS #151 PR

> **Execution class: Coding agent executable by Anthropic Claude Code.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 84 | `FS` | The PS #151 candidate PR exists and initial checks pass. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local Anthropic Claude Code review-loop prompt below against the PS #151 PR. Do not merge. If bytes change, rerun Task 84 validation.

### Anthropic Claude Code review-loop prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a dedicated Anthropic Claude Code session:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

### Complete when

The loop returns `TERMINALLY CLEAN` for a recorded head SHA and tree.

## Task 86 — run the independent final quality check on the PS #151 PR

> **Execution class: Coding agent executable.** Use a fresh coding-agent session.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 85 | `FS` | The Claude Code review loop is terminally clean. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Run the task-local independent final PR quality-check prompt below. Require complete PS #151 Node permission-model, duplicate-key preflight, issue, comment, deferral, PR-body, final-diff, validation, checks, and mergeability coverage. Return to Task 85 after any head change.

### Independent final PR quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified pull-request URL or number. Copy the resulting prompt into a fresh coding-agent session after the Claude Code review loop is terminally clean:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

### Complete when

The fresh agent returns `PASS` for the same head SHA and tree as Task 85.

## Task 87 — merge the PS #151 PR and publish its handoff

> **Execution class: Coding agent executable.**

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 86 | `FS` | The independent quality check passed for the current head and tree. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Apply the task-local merge gate below. Merge the PR, close PS #151, and post the full landed handoff with affected controls, files and blobs, validation, runtimes, review-loop result, final quality-check result, and intentional differences.

### Merge gate

Immediately before the merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

PS #151 is closed by the landed PR and its affected-control map is ready for Terraform comparison.

## Task 88 — compare PS #151 in Terraform and adapt if applicable

> **Execution class: Coding agent executable.** Work in TerraformStyleGuide after Task 87.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 87 | `FS` | Use the final landed PS #151 commit and blobs. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Compare the landed Node permission-model and duplicate-key controls with the Terraform validator and workflow topology.
2. If an applicable control is absent or weaker, create one focused Terraform issue from the landed PS commit and blobs, then run the four task-local conditional repair PR lifecycle actions.
3. If Terraform is equivalent, post a pinned no-change record.
4. If a control is structurally inapplicable, post a pinned non-applicability record.
5. Do not create a placeholder issue only for symmetry.

### Destination-comparison controls

1. Read both repositories only from pinned commits. Record every compared blob.
2. Map files by role, not only by filename.
3. Classify each applicable matrix row as `same`, `intentional difference`, or `blocker`.
4. If no common difference exists, post a pinned no-change or non-applicability record. Do not open an implementation issue only for symmetry.
5. If a common difference exists, create or update one focused destination issue. Pin the source commit and blobs.
6. Start the destination adaptation only after issue setup and a free implementation slot. Adapt the landed capability; do not redesign it independently.
7. Prepare one destination candidate and complete the task-local conditional repair PR lifecycle. Record the complete landed identity and validation evidence.
8. Stop this task at its stated destination result. The dependent reverse-comparison task must compare the landed destination result back against the source before the cycle can close.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

Terraform has a landed adaptation, pinned no-change result, or proved structural non-applicability record for every PS #151 control.

## Task 89 — reverse-compare the PS #151 cycle and close its fixed point

> **Execution class: Coding agent executable.** Work in PSStyleGuide after Task 88.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 88 | `FS` | Use the final Task 88 Terraform result. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

Use the task-local reverse-comparison and closure controls below with the applicable complete or reduced matrix. For any focused PS sync-back or later Terraform repair, run the four task-local conditional repair PR lifecycle actions. Post the permanent closure or non-applicability record.

### Reverse-comparison and closure controls

1. Read both repositories only from the final pinned commits. Record every compared blob and map files by role.
2. Classify each applicable matrix row as `same`, `intentional difference`, or `blocker`.
3. If the destination adaptation added or corrected common behavior, create or update one focused source sync-back issue. Pin both landed commits and blobs.
4. Start a source sync-back only after issue setup and a free implementation slot. Adapt the common behavior; do not redesign it independently.
5. Prepare the source sync-back candidate and complete the task-local conditional repair PR lifecycle.
6. If the source changes, compare the new landed source result in the destination again. Use the same issue, slot, lifecycle, and evidence controls for each required destination repair.
7. Stop if the same matrix row changes direction twice. Run a new decision process that evaluates both implementations.
8. Close the cycle only when every common row is `same`, every intentional difference has complete evidence, and no blocker remains.
9. Post one permanent closure record with both repositories' final identities, the matrix digest, validation, review outcomes, and no-change or non-applicability results. If a dependent final-recheck task owns closure, post the current reciprocal record and leave final closure to that task.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

The PS #151 cross-repository cycle is closed and every applicable common control is `same` or a fully proved intentional difference.

## Task 90 — check the independent residual triggers

> **Execution class: Coding agent executable.** This is a read-only trigger check and does not start implementation.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| None | — | No technical predecessor. Run here to avoid interrupting the known capability cycles. Re-run when a listed input changes. |

Keep PS #155 and #156 open and independent. Do not add either issue as a blocker for PS #159, #152, #147, Terraform #21, or Terraform #22 without a new material trigger.

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Trigger check

1. Re-query the current issues, repositories, supported hosts, native helpers, candidate files, and external runners.
2. Revisit PS #155 only if the candidate validator permits a competing writer, Windows PowerShell 5.1 support ends and a portable API becomes available, or a later task adopts a suitable native helper.
3. Revisit PS #156 only if the candidate files change or a suitable external runner becomes available.
4. Classify each trigger as `present` or `absent` and link its evidence.
5. If all triggers are absent, post a dated no-trigger record and stop.
6. If a trigger is present, record the affected issue and exact material evidence. Do not start implementation in this task.

### Complete when

Each trigger has a current, evidence-backed classification and each present trigger identifies the focused residual work that Task 91 must evaluate.

## Task 91 — close one triggered residual cycle

> **Execution class: Coding agent executable.** This task is conditional. Repeat it for each present Task 90 trigger. If all triggers are absent, record that result and skip this task.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 90 | `FS` | A material trigger is documented. |
| Task 89 | `FS` | The preceding known fixed-point cycle is closed. |
| Prior Task 91 instance | `FS` | Close one residual cycle before starting another. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Validate the trigger and complete the required finding-specific decision process.
2. Create one focused issue with only its real dependencies. Issue creation does not start implementation.
3. Verify the implementation slot is free. Explicitly start only that residual issue.
4. Prepare one focused PR and run the four task-local conditional repair PR lifecycle actions.
5. Record the complete landed identity, validation, review, and rollback evidence.
6. Do not change repository settings without exact administrator authorization.
7. If the other repository has the same role, compare the landed result there.
8. Create a reciprocal issue before implementation only when a common difference exists.
9. Start the reciprocal issue only after issue setup and a free implementation slot. Run the four task-local conditional repair PR lifecycle actions, then run the reverse comparison.
10. Close the cycle only when each common behavior is `same` or a proved intentional difference with equal security and failure strength.

### Reciprocal fixed-point controls

1. Read both repositories only from pinned commits. Record every compared blob.
2. Map files by role, not only by filename.
3. Classify each applicable row as `same`, `intentional difference`, or `blocker`.
4. If no common difference exists, post a pinned no-change or non-applicability record. Do not open an implementation issue only for symmetry.
5. If a common difference exists, create or update one focused destination issue. Pin the source commit and blobs.
6. Start the destination adaptation only after issue setup and a free implementation slot. Adapt the landed capability; do not redesign it independently.
7. Prepare one destination candidate and complete the task-local conditional repair PR lifecycle. Record the complete landed identity and validation evidence.
8. Compare the landed destination result back against the source repository.
9. If the destination added or corrected common behavior, create a focused source sync-back issue. Start it only after issue setup and a free implementation slot.
10. Prepare the source sync-back candidate and complete the task-local conditional repair PR lifecycle. Then compare the new source result in the destination again.
11. Stop if the same matrix row changes direction twice. Run a new decision process that evaluates both implementations.
12. Close the cycle only when every common row is `same`, every intentional difference has complete evidence, and no blocker remains.
13. Post one permanent closure record with final identities from both repositories, the matrix digest, validation, review outcomes, and no-change or non-applicability results.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

One triggered residual cycle is at a fixed point. All Task 91 instances are complete when every present Task 90 trigger is closed.

## Task 92 — run one future PS-first paired capability cycle

> **Execution class: Coding agent executable.** This task is conditional. Repeat it for each later common capability. If no later capability is in scope, record that result and skip this task.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Task 89 | `FS` | All currently known capability cycles are closed. |
| Every applicable Task 91 instance | `FS` | Triggered residual work is closed. |
| Prior Task 92 instance | `FS` | The prior future cycle has a permanent fixed-point record. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Procedure

1. Create or update the PS issue. Classify it as `common capability`, `repository-specific capability`, or `administrative only`. Issue creation does not start implementation.
2. Record landed inputs and blobs, intended paths, real native dependencies, expected differences, and any mapped Terraform issue.
3. Verify the implementation slot is free. Explicitly start only the PS implementation.
4. Prepare one PS PR and run the four task-local conditional repair PR lifecycle actions. Post a permanent handoff with exact landed identities and matrix rows.
5. Create or update the Terraform issue only from that landed PS handoff. Do not replace placeholders before the PS PR lands, and never use a branch, reviewed head, test-merge ref, or anticipated squash SHA as the landed commit.
6. After issue setup and a free implementation slot, explicitly start only the Terraform adaptation. Do not create a shared runtime dependency.
7. Run the four task-local conditional repair PR lifecycle actions for the Terraform PR.
8. Run the reverse PS comparison. Create a focused PS sync-back issue before any correction and start it only after issue setup and a free implementation slot.
9. If PS changes, compare Terraform again. Run the four task-local conditional repair PR lifecycle actions for any required Terraform repair.
10. Apply the row-direction stop rule. Repeat until the cycle reaches a fixed point. Do not start the next PS capability before the permanent closure record exists.

### Terraform starting-point template

Replace all placeholders with verified landed identities:

> **Starting point — adapt the landed PSStyleGuide implementation**
>
> PSStyleGuide issue `<PS_ISSUE_URL>` landed through PR `<PS_PR_URL>` at commit `<PS_LANDED_COMMIT>`, tree `<PS_LANDED_TREE>`. The permanent implementation handoff is `<PS_HANDOFF_URL>`.
>
> This update records the starting point. It does not commence implementation. Do not create a feature branch or edit implementation files until the issue record is complete, the preceding cycle has a permanent closure record, and no feature implementation issue or PR is active.
>
> Read source files only from `<PS_LANDED_COMMIT>` and record their Git blobs before copying. Do not follow a branch or independently rebuild the capability.
>
> Adapt only repository identity, domain-specific filenames and payloads, schema/type prefixes, check or ruleset names, proved platform applicability, and repository-specific evidence. Preserve all common security, serialization, path, credential, native-status, atomicity, cleanup, error-handling, and failure-truth behavior.
>
> Create no shared runtime dependency. Complete the applicable closed reciprocal catalog at implementation start and before merge. Missing, duplicate, unknown, renamed, empty, unexplained, or weaker behavior blocks merge.
>
> Do not change repository settings without exact administrator authorization. Run the candidate, Anthropic Claude Code review-loop, independent final quality-check, and merge actions as separate steps. Record source and destination blobs, tests, runtime identities, reviewed head/tree, merge method, landed commit/tree, and the next handoff.

### Reciprocal fixed-point controls

1. Read both repositories only from pinned commits. Record every compared blob.
2. Map files by role, not only by filename.
3. Classify each applicable row as `same`, `intentional difference`, or `blocker`.
4. If no common difference exists, post a pinned no-change or non-applicability record. Do not open an implementation issue only for symmetry.
5. If a common difference exists, create or update one focused destination issue. Pin the source commit and blobs.
6. Start the destination adaptation only after issue setup and a free implementation slot. Adapt the landed capability; do not redesign it independently.
7. Prepare one destination candidate and complete the task-local conditional repair PR lifecycle. Record the complete landed identity and validation evidence.
8. Compare the landed destination result back against the source repository.
9. If the destination added or corrected common behavior, create a focused source sync-back issue. Start it only after issue setup and a free implementation slot.
10. Prepare the source sync-back candidate and complete the task-local conditional repair PR lifecycle. Then compare the new source result in the destination again.
11. Stop if the same matrix row changes direction twice. Run a new decision process that evaluates both implementations.
12. Close the cycle only when every common row is `same`, every intentional difference has complete evidence, and no blocker remains.
13. Post one permanent closure record with final identities from both repositories, the matrix digest, validation, review outcomes, and no-change or non-applicability results.

### Intentional-difference evidence

Limit intentional differences to repository identity and canonical URLs; PowerShell or Terraform source, generated, and artifact filenames or payloads; domain examples and documentation; artifact IDs; schema, type, and diagnostic prefixes; stable check and ruleset names; local evidence identifiers; proved platform conditions; and repository-specific historical decisions or live settings evidence.

For each intentional difference, name both literals or behaviors. Explain the repository need. Prove equal security and failure strength. Name the owner. State the review or expiry condition. Do not use convenience, implementation history, separate authorship, or lower effort as a repository-specific reason.

### Conditional repair PR lifecycle

If this task finds no change or proves non-applicability, record the pinned result and skip the PR-only actions. For each repair PR that this task requires, perform all of these actions in order and keep them discrete:

1. **Candidate action:** Validate the finding through exhaustive options, a finding-specific weighted rubric, a scoring table, and an ASD-STE100-compliant selection. Implement the selected repair. Open or update one focused PR. Complete the issue scope, local validation, PR body, and initial checks. Record the base, head SHA, head tree, affected paths, source and candidate blobs, validation, and issue links. Stop before review or merge.
2. **Claude Code review-loop action:** In a dedicated Anthropic Claude Code session, use the repair prompt below. Require `TERMINALLY CLEAN` for the candidate head. Do not combine this action with candidate preparation or merge.
3. **Independent quality-check action:** After the Claude Code result is terminally clean, use the independent repair prompt below in a fresh coding-agent session. Require `PASS` for the same head SHA and tree. Do not rely on the Claude Code session's unverified summary.
4. **Merge action:** Apply the repair merge gate below. Record the landed identity and validation evidence.
5. If either review action changes implementation bytes, commits, generated files, tests, or another reviewable repository artifact, return to action 2 for the new head. Then repeat action 3 in another fresh session. If only the PR body changes, revalidate the corrected body in action 3.
6. Repeat all four actions for each later reciprocal repair PR. Do not merge a repair directly from the comparison action.

#### Repair Anthropic Claude Code prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into Anthropic Claude Code:

~~~text
Use Anthropic Claude Code to take pull request <PR_URL_OR_NUMBER> through the repository's complete automated review-loop process.

Work in the pull request's repository. Read the repository-local root CLAUDE.md before you act. Follow its current "Handling code review comments," "Deferring work," "Automated review loop," protected-instruction, validation, and identity-gate requirements exactly. Do not use a summary of CLAUDE.md as a substitute for reading it.

Do not merge the pull request.

1. Re-query the pull request. Record the base SHA, current head SHA and tree, draft state, merge state, required checks, linked issues, and existing review/comment baselines.
2. Confirm that the candidate implementation and its initial local validation are complete. If the PR is still a draft, mark it ready for review only when the candidate is ready for the review loop.
3. For each review round, request fresh reviews from both GitHub Copilot (copilot-pull-request-reviewer) and Codex (chatgpt-codex-connector). Treat them as co-equal reviewers.
4. Poll authenticated structured review and comment data at least every 60 seconds. Paginate all results. Count a review for the round only when it is newer than the recorded reviewer baseline and its commit_id equals the recorded PR head SHA.
5. Process every actionable comment from both reviewers, humans, and other reviewers one at a time. For each real finding, complete all nine CLAUDE.md comment-processing steps: validate; list exhaustive options; build a fresh weighted rubric; score the options in a table; select and state the best option in ASD-STE100-compliant language; post the complete evaluation; implement the selected solution; evaluate instruction/style-guide impact; and answer and resolve the thread.
6. Ignore comments that begin with @copilot when they are commands addressed to GitHub Copilot, as CLAUDE.md requires.
7. After each fix, verify that the commit is reachable from the PR head. Run applicable local validation. Search for sibling defects by property and mutation-test new assertions before requesting the next review round.
8. Re-request both reviewers after every head change. A stale review on an earlier head never counts as clean.
9. Run up to 80 rounds. If one reviewer cannot review the diff, document the exact failure in a PR comment and continue only as CLAUDE.md permits.
10. Before declaring the loop clean, run the whole-PR deferred-work sweep across all resolved and unresolved review threads, reviews, inline comments, PR-level comments, and the PR body. Complete illegitimate worker-fact deferrals now. For each legitimate deferral, verify that a self-contained GitHub issue exists, is cited by the PR, and has correct native dependencies. Correct residual/deviation labels that are incorrectly called deferrals.
11. Declare terminal clean only when Copilot and Codex each have a current-head review with no actionable comments, except a reviewer proved non-functional under CLAUDE.md, and no untracked or illegitimate deferral remains.
12. Post and return a terminal review-loop record. Include the PR URL, final head SHA and tree, round count, reviewer review IDs and commit IDs, all processed comment/thread IDs, local validation, deferred-work disposition, non-functional-reviewer evidence if applicable, and the explicit result TERMINALLY CLEAN or NOT CLEAN.

If you reach a blocker, the 80-round cap, or a maintainer decision, stop without merging. State the exact blocker, current head SHA and tree, completed work, open thread IDs, and the next required action.
~~~

#### Repair independent final quality-check prompt

Replace only `<PR_URL_OR_NUMBER>` with the verified repair-PR URL or number. Copy the resulting prompt into a fresh coding-agent session:

~~~text
Perform an independent final quality check of pull request <PR_URL_OR_NUMBER>. Use a fresh coding-agent session. Do not rely on the prior review-loop agent's summary, memory, or context. Re-query and verify all evidence yourself.

Read the repository-local root CLAUDE.md before you act. Apply its current code-review-comment process and deferral rules exactly. Do not merge the pull request.

1. Record the repository, PR URL, base SHA, current head SHA and tree, draft state, merge state, required checks, review decisions, and associated issues.
2. Enumerate and paginate every review, review thread, inline review comment, PR-level comment, commit, check, and PR-body revision available through authenticated structured tooling. Include resolved, unresolved, active, and outdated threads. Record counts and stable IDs so omissions are detectable.
3. Verify that the terminal Claude Code review-loop record applies to the current head SHA. Verify that both Copilot and Codex produced current-head clean results, except any reviewer proved non-functional under CLAUDE.md. A stale result or a head change after the loop is a blocker.
4. Review every code-review comment and thread. Confirm that each real finding was answered and resolved through all required CLAUDE.md steps. If an unaddressed finding exists, process it one at a time through that complete process. Do not accept an "outdated" label as proof that the finding no longer applies.
5. Sweep all review threads, reviews, PR-level comments, commit messages, and the PR body for unfinished-work or deferral language, including defer, follow-up, future, later, TODO, known gap, left open, being added, will be added, out of scope, context, budget, turns, and similar wording.
6. Re-evaluate every possible deferral. A deferral caused by context-window exhaustion, token or turn limits, time pressure, task size, tedium, or another worker fact is illegitimate. Complete that work in this PR. A legitimate deferral must result from the full CLAUDE.md decision process on the merits.
7. For each legitimate deferral, verify that a self-contained GitHub issue exists before merge. Confirm that it states the problem, decision basis, trigger or reopen condition, affected scope, and originating PR/thread. Confirm that the PR cites it. Re-query GitHub and verify that its native blocking and blocked-by dependencies are complete and correct. Correct false, missing, reversed, or tracker-only dependency representations before passing the PR.
8. Distinguish deferred work from accepted residuals and intentional deviations. Require accurate labels and bounded evidence. Do not let pending work hide under residual or deviation language.
9. Identify every issue associated with the PR through closing references, development links, explicit PR-body links, and repository evidence. Build a requirement-to-evidence table for every issue requirement and acceptance criterion. Map each requirement to final code, documentation, tests, validation, or an authorized decision.
10. If an issue requirement is incomplete, return FAIL and draft a copy-paste-ready completion prompt for a coding agent. The prompt must name the PR, issue, missing requirement, relevant paths, required validation, review-loop return condition, and prohibition on merge. Do not describe required work as deferred.
11. Cross-check the PR title and description against the complete final diff, commits, issue scope, tests, validation results, security effects, generated artifacts, breaking changes, intentional differences, deferred-issue links, and rollback information. Update the PR description directly when tooling and authority permit. Otherwise, produce a redline-style replacement that shows exact deletions and additions for the operator. Re-run this quality check after a body correction.
12. Inspect the final diff independently for correctness, security, failure truth, unintended scope, debug artifacts, placeholders, secrets, TODO markers, disabled checks, unjustified suppressions, generated-file drift, stale version/digest/name pins, missing negative tests, and documentation inconsistency. Run or verify all applicable repository validation against the recorded head.
13. Verify that all required checks passed on the current head, the PR is mergeable, the base and head identities are current, every fix commit is reachable from the PR head, and no newer comment or review arrived during this check.
14. If you change any reviewable repository byte, commit the fix to the PR head, run applicable validation, return FAIL, and direct the operator to rerun the Anthropic Claude Code review loop followed by this independent check. If you change only issue/PR metadata, re-query it and repeat the affected quality-check sections.
15. Return a final report with PASS or FAIL, the verified head SHA and tree, issue-requirement matrix, comment/thread audit, deferral audit, PR-description disposition, checks and tests, changes made, blocking completion prompts, and the exact next action.

PASS means: no unfinished requirement; no unaddressed reviewer finding; no illegitimate or untracked deferral; accurate issue dependencies; accurate PR title/body; terminal review evidence for the same head; successful required checks; and no unresolved quality blocker. Anything else is FAIL.
~~~

#### Repair merge gate

Immediately before the repair merge:

1. Re-query the PR, its linked issues, reviews, threads, and checks. Fetch both current `origin/main` refs.
2. Verify that the Claude Code terminal-clean record and independent `PASS` record identify the current head SHA and tree.
3. Stop if the head changed, a new comment or review arrived, a check is incomplete or failed, the PR is not mergeable, an approval is missing, or a dependency or authorization condition is unmet.
4. Use the approved merge method. Record the merge method, landed commit and tree, closed issues, final path and blob identities, and post-merge checks.
5. Post the permanent handoff only from the landed commit. Do not use a reviewed head or anticipated squash SHA as the landed identity.

### Complete when

One future capability has a landed PS source, Terraform adaptation or proved non-applicability, reverse PS comparison, all required sync-backs, and a permanent fixed-point closure record.

## Task 93 — verify final completion

> **Execution class: Coding agent executable.** This is a read-only final audit and evidence-publication task.

### Dependencies

| Predecessor | Relationship | Requirement |
| --- | --- | --- |
| Tasks 1–89 | `FS` | Every known task and reciprocal cycle is complete. |
| Every applicable Task 91 and Task 92 instance | `FS` | All triggered residual and in-scope future cycles are complete. |
| Task 90 | `FS` | The latest residual-trigger record is current. |

### Execution controls

1. Re-query GitHub and fetch both current `origin/main` refs before any issue write, branch rewrite, merge, or settings change in this task.
2. Open or identify one focused issue before each implementation. Issue creation does not start implementation.
3. Read every cross-repository input only from a recorded landed commit and Git blob. Do not copy from a moving branch.
4. Verify that the implementation slot is free before any feature branch, implementation edit, or implementation PR starts.
5. Keep candidate preparation, the Anthropic Claude Code review loop, the independent final quality check, and merge as separate actions. Perform only the lifecycle action or conditional sequence assigned to this task. Do not merge a PR directly from an implementation or comparison action.
6. Do not change repository settings unless the applicable administrator issue authorizes the exact request.
7. Replace every placeholder before posting text. Do not fabricate a SHA, URL, PR number, tree, blob, or evidence identity.
8. Use native dependencies only for real completion prerequisites. A tracker can list children without a false blocking edge.
9. Validate each finding before editing. List exhaustive options, create a finding-specific weighted rubric, score the options in a table, and select the best option.
10. State each selected action in ASD-STE100-compliant language. Keep decision analysis in `TEMP-*` files, not in permanent planning or implementation documents.
11. Record each applicable issue and PR URL, base, reviewed head and tree, merge method, landed commit and tree, affected path, Git blob, validation command, runtime identity, and review outcome.

### Completion audit

Verify all of the following:

- Every implementation had a focused issue record and a separate explicit commencement record. No two feature implementation issues or PRs were active at the same time.
- Every cross-repository input was pinned to a landed commit and blob. No work copied from a moving branch or introduced a shared runtime dependency, reusable cross-repository workflow, submodule, package, or third source of truth.
- Every PR completed a discrete Anthropic Claude Code review loop and then a discrete independent fresh-agent quality check against the same final head SHA and tree before merge. Every permanent cycle record contains both gate results and both repositories' issue and PR URLs, bases, reviewed heads/trees, merge methods, landed commits/trees, paths, blobs, validation, runtime identities, and review outcomes.
- Every merged PR passed the whole-PR comment and deferral audit. No unfinished reviewer finding or illegitimate deferral remains. Every legitimate deferral has a cited, self-contained GitHub issue with correct native dependencies.
- Every merged PR title and body accurately describe its final landed diff, issue scope, validation, security effects, intentional differences, deferred-issue links, and rollback information.
- Every required reciprocal matrix contains each applicable row exactly once. Every common row is `same`. Every intentional difference names both behaviors, repository need, equal security and failure strength, owner, and review or expiry condition. No blocker remains.
- Every posted issue body and comment contains verified identities. No placeholder or fabricated SHA, URL, PR number, tree, or blob remains.
- Every native dependency represents a real prerequisite. No tracker falsely blocks implementation, and no setting changed without exact administrator authorization.
- Initial cycles 1 through 5 closed in order with their Terraform comparisons, required repairs, reverse PS comparisons, and permanent fixed-point records.
- PS #159 and its four children are closed with a permanent landed handoff that names both repositories' final commits and blobs.
- PS #163 closed without duplicating volatile protocol text.
- Terraform #31 contains all five initial cycle records and closed without an aggregate foundation implementation PR.
- PR #164 was reviewed and landed through PS #160, and its reciprocal cycle reached a fixed point.
- The generators share the canonical tracked-present/tracked-absent publication and structured-result behavior.
- Both generators use fixed root/destination authority, complete BOM-less UTF-8/LF payloads, same-directory durable candidate verification, one `File.Replace` or non-overwriting `File.Move` publication call, truthful `ReplacementStateUncertain` reporting, no post-publication rollback claim, and reusable raw NUL-delimited Git validation with exact native-status handling.
- Repository-code jobs in both repositories contain no actions and have no repository-token scopes.
- Both repositories use separate action-only publication jobs, verified official Node distributions in action-free Node jobs, strict offline policy parsing and fixtures, machine-readable authority for roles, inputs, defaults, supply identities and case allocation, and the same script-version grammar and PowerShell authoring rules.
- Both repositories have the same common workflow-policy behavior and case coverage, except for recorded repository-specific literals. No workflow writer existed before P1B/T1B introduced and proved it.
- PS #158 is complete, and both repositories have a read-only, reproducible supply-freeze method.
- Terraform #21 closed from landed PS PR #153 after the reverse PS comparison and all sync-back work.
- The global sweep inventoried all common roles, resolved every untracked blocker through focused cycles, and retained final two-repository evidence.
- PS #147 and #152 are complete, Terraform #22 consumed the landed P1B handoff, and the P1B/T1B cycle has no blocker.
- PS #148 and Terraform #23 each have a landed result and the required cross-repository applicability record.
- PS #149 landed after the deadline-path decision. Terraform #24 consumed its handoff after #23. The P3/T3 cycle reached a fixed point.
- PS #151 has an applicable Terraform follow-up or a pinned structural non-applicability record.
- The advisory decision did not expire without completed PS #149 or a separately approved, fully pinned superseding decision.
- PS #155 and #156 remained independent unless a documented trigger created a focused blocker.
- Every later common capability used a landed PS handoff, a Terraform adaptation, a reverse PS comparison, and fixed-point closure before the next PS implementation.
- No shared cross-repository runtime dependency exists.

### Complete when

Post one permanent final audit that identifies the final PS and Terraform commits and trees, links every fixed-point record, lists all validation and runtime evidence, records every intentional difference and non-applicability result, and states that no blocker remains.

## References

- [PS issue #145](https://github.com/franklesniak/PSStyleGuide/issues/145) and [PS PR #150](https://github.com/franklesniak/PSStyleGuide/pull/150)
- [PS issue #146](https://github.com/franklesniak/PSStyleGuide/issues/146) and [PS PR #153](https://github.com/franklesniak/PSStyleGuide/pull/153)
- PS issues [#147](https://github.com/franklesniak/PSStyleGuide/issues/147), [#148](https://github.com/franklesniak/PSStyleGuide/issues/148), [#149](https://github.com/franklesniak/PSStyleGuide/issues/149), [#151](https://github.com/franklesniak/PSStyleGuide/issues/151), [#152](https://github.com/franklesniak/PSStyleGuide/issues/152), [#155](https://github.com/franklesniak/PSStyleGuide/issues/155), [#156](https://github.com/franklesniak/PSStyleGuide/issues/156), and [#158](https://github.com/franklesniak/PSStyleGuide/issues/158)
- [PS foundation umbrella #159](https://github.com/franklesniak/PSStyleGuide/issues/159), child issues [#160](https://github.com/franklesniak/PSStyleGuide/issues/160), [#161](https://github.com/franklesniak/PSStyleGuide/issues/161), and [#162](https://github.com/franklesniak/PSStyleGuide/issues/162), and [draft PR #164](https://github.com/franklesniak/PSStyleGuide/pull/164)
- [PS Claude-command issue #163](https://github.com/franklesniak/PSStyleGuide/issues/163)
- [Terraform issue #20](https://github.com/franklesniak/TerraformStyleGuide/issues/20), [PR #26](https://github.com/franklesniak/TerraformStyleGuide/pull/26), [PR #27](https://github.com/franklesniak/TerraformStyleGuide/pull/27), and [PR #30](https://github.com/franklesniak/TerraformStyleGuide/pull/30)
- Terraform issues [#21](https://github.com/franklesniak/TerraformStyleGuide/issues/21), [#22](https://github.com/franklesniak/TerraformStyleGuide/issues/22), [#23](https://github.com/franklesniak/TerraformStyleGuide/issues/23), [#24](https://github.com/franklesniak/TerraformStyleGuide/issues/24), and [#31](https://github.com/franklesniak/TerraformStyleGuide/issues/31)
- [GitHub secure-use guidance for Actions](https://docs.github.com/en/actions/reference/security/secure-use)
- [GitHub Actions runner authentication design](https://github.com/actions/runner/blob/main/docs/design/auth.md)
- [GitHub Actions `GITHUB_TOKEN`](https://docs.github.com/en/actions/concepts/security/github_token)
- [GitHub workflow permissions](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#permissions)
- [Node.js permission model](https://nodejs.org/api/permissions.html)
- [.NET `File.Replace`](https://learn.microsoft.com/en-us/dotnet/api/system.io.file.replace)
- [.NET `File.Move`](https://learn.microsoft.com/en-us/dotnet/api/system.io.file.move)
- [Git pathname format and `-z`](https://git-scm.com/docs/git-status#_pathname_format_notes_and_z)
- [GitHub issue dependencies](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/creating-issue-dependencies)
