# Decision 0001: Accept the in-repository trust root for pull-request policy checks

## Metadata

- **Status:** Active
- **Owner:** Repository Maintainers
- **Last Updated:** 2026-08-29
- **Scope:** Records the accepted in-repository trust-root limitation, its consequences, and the conditions that require reconsideration. Does not claim that the limitation is absent.

## Status

Accepted on 2026-08-01 by Frank Lesniak, PSStyleGuide repository owner.

This records a deliberate, dated acceptance of a known security limitation. It is not a
statement that the limitation does not exist, and it is not a to-do item. If any of the
review triggers in the last section fire, this decision must be reopened.

## 1. The concern, and whether it is real

Issue #145 builds a chain of integrity checks for the Markdown lint workflow. The contract
records the validator's digest, the validator records the contract's digest, the case
catalog is pinned by content hash, and the npm manifest and lockfile are compared against
digests hard-coded in the workflow itself. Each link was hardened during the review of
pull request #150.

Every one of those checks is executed by a step inside `.github/workflows/markdownlint.yml`.

For a `pull_request` event, GitHub runs the workflow file taken from the merge of the
pull-request head into the base branch. That means **the workflow file that runs is the
contributor's version, not the version on `main`**. A pull request can therefore delete
the `Get-FileHash` validator gate, the `--preflight` gate, and the hard-coded package
digests in the same commit that introduces whatever those gates were meant to catch.

The concern is real and is not a defect in the implementation. It is a property of where
the trust root sits: every pin in this design is anchored in a file the pull request can
rewrite.

Confirmed against the primary source rather than assumed; see reference 1.

## 2. What an attacker actually gains, and what they do not

Scoping the impact matters more than restating the mechanism, because the blast radius is
narrower than "the integrity chain can be bypassed" suggests.

The workflows in this repository declare `permissions: {}` at the workflow level and
`contents: read` at the job level, do not persist checkout credentials, and consume no
secrets. This repository is public, so a workflow triggered by a pull request from a fork
receives a read-only token and no secrets regardless of what the workflow file asks for
(references 2 and 3).

| Capability | Available to an attacker who rewrites the workflow? |
| --- | --- |
| Write to the repository | No. No secret or write-scoped token is reachable. |
| Read repository secrets | No. There are none, and fork runs receive none. |
| Persist checkout credentials | No. `persist-credentials: false`, and there is nothing to persist. |
| Execute arbitrary code on a runner | Yes — but this is already true of any CI that installs and runs dependencies against pull-request content. |
| **Produce a green check that does not mean what it claims** | **Yes. This is the actual exposure.** |

The real loss is the trustworthiness of the continuous-integration verdict as a merge
signal. A hostile pull request could show a passing Markdown lint job while having
disabled every policy check that job exists to perform. Nothing is stolen; the reviewer is
misled.

That reframing is what makes acceptance reasonable. The control that actually stops this
is a human reading the diff before merging, and a workflow-file edit is one of the most
conspicuous things a diff can contain — it appears in the changed-files list by name.

## 3. Options considered

Options were drawn from several role perspectives so the list is not just an engineer's
list. Permutations of the individually viable options are included.

- **A. Accept and document only.** Record the residual; change nothing operationally.
- **B. Accept, document, and require approval for workflow runs from all outside
  contributors.** As A, plus tightening the repository Actions setting so that no pull
  request from anyone outside the repository runs a workflow until the owner approves it.
- **C. Transfer the repository to a GitHub organization and enforce a required workflow.**
  Organization-level required workflows are defined outside the repository, so a pull
  request cannot rewrite them.
- **D. Gate the job behind a GitHub Environment with a required reviewer.** Execution
  pauses until a human approves the run.
- **E. Move policy enforcement into a `pull_request_target` workflow.** That event uses the
  workflow file from the base branch, which a pull request cannot edit.
- **F. Add a CODEOWNERS entry for `.github/workflows/` and require code-owner review.**
  Makes any workflow edit require an explicit, enforced approval rather than reviewer
  memory.

### How the perspectives differed

| Perspective | Position |
| --- | --- |
| Senior engineer | E is the strongest in-repository fix on paper, but `pull_request_target` is a well-documented footgun: it runs with a write-capable token, so a mistake there is worse than the problem being solved. |
| New contributor | A and B are legible. E would be actively confusing to read and easy to misuse later. |
| DevOps | B is a two-click repository setting with real value. C is a migration with ongoing overhead. |
| Documentation | A is mandatory regardless of which technical option is chosen, because a residual that is not written down is a residual nobody re-evaluates. |
| Product management | C changes how the whole account is administered to fix one repository. Disproportionate. |
| Security executive | Wants the residual formally accepted, owned, dated, and given explicit review triggers, rather than left implicit. |
| Security engineer | Notes the blast radius is already small; recommends B as cheap defence in depth and warns strongly against E. |
| Business stakeholder | This is a personal, public style-guide repository with no secrets and no production dependency. Cost of C is not justified by the exposure. |

## 4. Evaluation rubric

Weights deliberately place technical correctness above effort. Churn, difficulty, and
scope adherence are weighted at half the value of the correctness and safety criteria, so
that a cheap option cannot win on cheapness alone.

| Criterion | Weight | What a 5 means |
| --- | --- | --- |
| Closes the gap | 1.0 | A pull request genuinely cannot bypass the checks. |
| Reduces blast radius | 1.0 | Meaningfully shrinks what a bypass achieves. |
| Avoids introducing a new vulnerability | 1.0 | No new attack surface created by the fix. |
| Auditability | 1.0 | The residual and its owner are visible in the record. |
| Operable by a solo maintainer | 0.75 | No recurring friction for a one-person repository. |
| Amount of churn | 0.5 | Few files touched. |
| Difficulty to implement | 0.5 | Little work, little expertise required. |
| Adherence to issue #145 scope | 0.5 | Does not disturb the ten permitted implementation paths. |

Maximum attainable weighted score is 31.25.

## 5. Scoring

| Criterion | A | B | C | D | E | F |
| --- | --- | --- | --- | --- | --- | --- |
| Closes the gap | 1 | 2 | 5 | 2 | 4 | 2 |
| Reduces blast radius | 2 | 4 | 5 | 3 | 1 | 3 |
| Avoids new vulnerability | 5 | 5 | 4 | 5 | 1 | 5 |
| Auditability | 5 | 5 | 4 | 3 | 2 | 4 |
| Operable by solo maintainer | 5 | 4 | 2 | 2 | 3 | 3 |
| Amount of churn | 5 | 5 | 1 | 3 | 2 | 3 |
| Difficulty to implement | 5 | 5 | 1 | 4 | 2 | 3 |
| Adherence to #145 scope | 4 | 4 | 1 | 2 | 2 | 2 |
| **Weighted total** | **23.75** | **26.00** | **21.00** | **19.00** | **13.25** | **20.25** |
| **Percentage** | **76.0** | **83.2** | **67.2** | **60.8** | **42.4** | **64.8** |

Option E scores worst despite being the only in-repository option that genuinely closes
the gap, because it would trade a low-impact integrity problem for a high-impact one. That
is the intended behaviour of the rubric: correctness is weighted highly, but so is not
making things worse.

Option C scores well on correctness and poorly on everything else. It remains the correct
answer if this repository ever moves under an organization for unrelated reasons.

## 6. Decision

**Option B is selected: accept the residual, document it here, and require approval for
workflow runs from all outside contributors.**

The gap is not closed. It is accepted, with these compensating controls recorded as the
basis for acceptance:

1. The owner reviews every pull-request diff before merge, and a workflow-file edit is
   conspicuous in that diff.
2. Workflows hold no secrets and no write permission, so a bypass yields neither.
3. Fork pull requests will not execute any workflow until the owner approves the run.
4. Issue #152 adds a branch ruleset requiring a pull request and resolved conversations
   before `main` can change.

Adding the owner as a required reviewer via a GitHub Environment (option D) was
specifically considered and rejected: the owner is already the sole reviewer of every pull
request, so a self-approval step adds a click without adding a decision.

## 7. What to do about it, step by step

One setting change is required. It takes about thirty seconds and needs no code.

1. Open `https://github.com/franklesniak/PSStyleGuide/settings/actions`.
2. Scroll to **Fork pull request workflows from outside collaborators**.
3. Select **Require approval for all external contributors**.
4. Press **Save**.

The default is to require approval only for first-time contributors, which means a
returning outside contributor's workflow runs automatically. After this change, every
outside pull request waits for an explicit approval before any workflow executes.

The cost is one extra click per outside pull request, on the **Approve and run** button
that appears on the pull request's checks tab. It does not affect the owner's own branches
or pull requests.

## 8. When this decision must be revisited

Reopen this decision if any of the following becomes true.

- The repository moves under a GitHub organization, which makes option C cheap.
- Any workflow in this repository gains `contents: write`, a secret, or a deployment
  credential. Issue #147 introduces a write-enabled publication job, so that issue is an
  explicit trigger to re-read this decision.
- The repository becomes private, which changes the fork and token model.
- The repository gains contributors other than the owner, which weakens compensating
  control 1.
- A continuous-integration result is ever used as an automated merge gate without a human
  reading the diff.

## References

### Canonical guides

- [STYLE_GUIDE.md](../../STYLE_GUIDE.md)
- [STYLE_GUIDE_RATIONALE.md](../../STYLE_GUIDE_RATIONALE.md)

Each source was retrieved and confirmed to resolve on 2026-08-01 rather than cited from
memory.

1. [Events that trigger workflows](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows)
   — establishes that `pull_request` runs the workflow from the merge of the head into the
   base, which is the mechanism this decision accepts.
2. [Approving workflow runs from public forks](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/approve-runs-from-forks)
   — the setting changed in section 7, and the approval model for fork runs.
3. [GITHUB_TOKEN reference](https://docs.github.com/en/actions/concepts/security/github_token)
   — confirms fork pull requests receive a read-only token and no secrets.
4. [Preventing pwn requests](https://securitylab.github.com/resources/github-actions-preventing-pwn-requests/)
   — GitHub Security Lab on why `pull_request_target` was rejected as option E.
5. [Available rules for rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets)
   — the ruleset capabilities relied on by compensating control 4 and by issue #152.
6. [Disabling and enabling a workflow](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/disable-and-enable-workflows)
   — the containment action available if a hostile pull request is ever observed.
