# Prompt-loop primary-source research — 2026-07-30

## Purpose and baseline

This artifact supports the correction pass over the PSStyleGuide issue slate.
It records externally dependent facts so the original sources do not need to
be rediscovered after context compaction.

Planning baseline:

- PSStyleGuide planning branch:
  `977d315d1cb123cc080176055d6034a1f28811e4`;
- TerraformStyleGuide planning branch:
  `87eb81f`;
- PSStyleGuide default `main`:
  `4346310e7deebffb4159c75e30d9546263dfd649`; and
- TerraformStyleGuide default `main`:
  `6ee3f57b2b71b885a5927b770dde47532944de62`.

## Live repository settings

Read-only commands:

```text
gh api repos/franklesniak/PSStyleGuide --jq
  '{default_branch,full_name,updated_at}'

gh api repos/franklesniak/PSStyleGuide/rulesets --jq
  'map({id,name,enforcement,target})'

gh api repos/franklesniak/PSStyleGuide/branches/main/protection

gh api apps/github-actions --jq '{id,slug,owner:.owner.login}'
```

Observed:

```json
{"default_branch":"main","full_name":"franklesniak/PSStyleGuide","updated_at":"2026-07-26T18:45:02Z"}
[]
{"message":"Branch not protected","status":"404"}
{"id":15368,"owner":"github","slug":"github-actions"}
```

Conclusion: `main` has neither a repository ruleset nor classic branch
protection. The official Actions integration can be named exactly in a future
ruleset task, subject to mandatory re-resolution at execution.

## GitHub workflow event and context identities

Source:

- <https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows>
- <https://docs.github.com/en/actions/reference/workflows-and-actions/contexts>

Material facts:

- `on.push.branches` filters use short branch names. GitHub's example uses
  `main` and `releases/**`.
- For a push, `github.ref` is the full updated ref, such as
  `refs/heads/feature-branch-1`.
- Therefore an evidence workflow derived from a production
  `branches: [main]` workflow must separately patch the short branch filter
  and every full-ref predicate. Replacing only `refs/heads/main` cannot cause
  an evidence-ref push to start the workflow.

## GitHub repository rulesets

Sources:

- <https://docs.github.com/en/rest/repos/rules>
- <https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets>
- <https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/creating-rulesets-for-a-repository>

Material facts:

- Repository branch rulesets can target exact included refs.
- Available rules include pull-request requirements, status checks, deletion
  restriction, and non-fast-forward restriction.
- Strict required status checks require the branch to be current with the
  target branch.
- A required status check may be bound to an expected application source.
- A bypass actor may have type `Integration`.
- `bypass_mode: always` and `bypass_mode: exempt` are distinct; exempt mode
  does not run the rules and does not create a bypass audit entry.
- The “Get rules for a branch” endpoint returns all active rules applying to
  the branch, including rules inherited from higher levels, while disabled or
  evaluate-only rules are excluded.

Implication: persistent activation evidence must include both the normalized
ruleset document and an effective-rule query for `main`. A temporary evidence
rule should be field-equivalent apart from its target ref and required-check
availability.

## npm lock-only producer

Source:

- <https://docs.npmjs.com/cli/install/>

Material facts:

- `package-lock-only=true` updates the lock rather than `node_modules`.
- `ignore-scripts=true` is a distinct setting that prevents package lifecycle
  scripts from running.
- `audit` and `fund` are separate controls.

Implication: a repository with a root `prepare` lifecycle needs an explicit
producer command:

```text
npm install --package-lock-only --ignore-scripts --no-audit --no-fund
```

The producer record must also freeze relevant effective configuration and
prove package/lock hashes before and after.

## Node child-process lifecycle

Source:

- <https://nodejs.org/api/child_process.html>

Material facts:

- `close` occurs after the child ends and its stdio streams close.
- `exit` can occur while stdio remains open.
- `error` can be followed by `exit`, so listeners must prevent multiple
  completion.
- `subprocess.kill()` reports signal delivery, not guaranteed termination.
- Killing a parent generally does not prove descendant processes stopped.
- Windows does not implement POSIX signals; supported signal names result in
  forceful termination behavior.
- stdout/stderr pipes have finite platform-specific capacity and must be
  drained deliberately.

Implication: P3 needs one-result state ownership, exact stream overflow and
drain behavior, timeout and grace phases, termination-delivery/close rules,
and an explicit cross-platform descendant-process boundary.

## GitHub issue evidence

Sources:

- <https://docs.github.com/en/rest/issues>
- <https://docs.github.com/en/rest/issues/issues>
- <https://docs.github.com/en/rest/issues/labels>
- <https://docs.github.com/en/rest/issues/assignees>

Material facts:

- Pull requests share the issue representation, so a verifier must explicitly
  reject the `pull_request` field for a governance issue.
- Stable issue responses expose numeric ID, node ID, number, repository URL,
  canonical HTML URL, state, title, body, labels, assignees, and update time.
- The REST API is versioned and clients should send a fixed
  `X-GitHub-Api-Version`.

Implication: P3 can cryptographically bind an exception to exact issue content
by hashing a canonical scope marker/body projection and retaining immutable
issue identities. It also needs a named capture implementation so maintainers
do not hand-author IDs, sorted projections, or digests.

## Research conclusions applied

The sources validate, rather than weaken, the latest criticism. The correction
pass should:

1. add a separately authorized settings-task dependency;
2. fully specify P1 script versions, lock producer, generator result, and
   reciprocal rows;
3. separate P1A production outcome from harness verdict and make every case
   physical and atomic;
4. bind P1A supplied scripts to trusted Git blobs;
5. patch every evidence-workflow trigger/ref literal and run under an
   equivalent temporary rule;
6. close P3 operation, Husky, process, parser, catalog, and issue-evidence
   contracts; and
7. leave the five-file issue slate and order unchanged.
