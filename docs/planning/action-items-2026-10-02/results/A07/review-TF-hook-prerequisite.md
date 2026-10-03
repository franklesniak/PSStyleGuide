<!-- markdownlint-disable MD013 -->
# A07 TF urgent hook prerequisite: pre-edit decision

## 1. Validate

Authenticated TF main remains `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`. Its `.husky/pre-commit` blob `71d8f4949043c1b64ffc68c92dcee58a4c3bde4b` lines17–22 refuses any staged Markdown when `node_modules/.bin/markdownlint-cli2` is absent. This is correct for the current installed graph. The proposed D90/E90 transfer removes that dependency and both CLI graphs, so copying the ten PS paths alone would make the retained hook refuse a correctly installed replacement before invoking its checker. This is a concrete changed-input incompatibility, established from the literal unconditional shell branch and dependency removal; no TF execution or transfer has occurred.

The same hook runs the exact-index staged checker, then full outer and nested commands, and refuses nonzero/unexpected statuses. The proposed staged checker already catches missing API dependencies and returns tooling status2 with locked-setup guidance. The hook already converts that result to a failed commit. Node/npm presence and exact Node selection remain separate controls. Removing a stale binary sentinel does not authorize skipping those checks or the later phases.

## 2. Relevant stakeholders

TF maintainers and documentation contributors need valid commits to work and missing tooling to fail clearly. Windows/Linux and GUI Git users need the same staged-content and full-worktree checks. A07/A21 maintainers and CI operators need a transfer that respects the actual peer interfaces and installed-hook setup. Security and independent reviewers need the affected CLI graph removed without a risk exception, bypass, false success or lost checks. The coordinator and history custodians need source acceptance and transfer accounting to remain separate. Cloud/recovery operators and data owners have no changed runtime, state or secret interface in this hook-only proposal.

## 3. Material options

- **N:** Keep current CLI dependency and sentinel; retain the red security finding and defer transfer.
- **S:** Replace the CLI sentinel with fixed library/helper-file presence sentinels. This can catch absent files early, but presence does not prove imports/configuration work and duplicates the actual caller.
- **R:** Remove only the obsolete CLI sentinel. Reuse the retained actual staged checker and existing shell status classification for tooling refusal.
- **P:** Add a separate import/resolution preflight for all required API modules before the staged checker. This duplicates dependency knowledge and execution without replacing the actual check.
- **H:** Replace TF's hook with PS's shorter staged-only hook. This drops required peer full-worktree phases and is ineligible.
- **K:** Keep CLI2 installed solely as a sentinel while using the API. This retains the affected dependency and is ineligible as the urgent remedy.

The existing actual staged checker is the smaller reusable control in R. A shared new preflight module is P with additional maintenance, not a missing separate useful option.

## 4. Fresh rubric and constraints

Score0–5 means absent, weak, partial, useful with substantial limitations, strong with bounded uncertainty, or fully supported by the inspected design. Weighted total is sum(weight × score/5). **Security closure35** rewards removal of the affected graph; **retained hook behavior35** rewards all existing phases and input semantics; **useful failure boundary20** rewards real tool execution and actionable nonzero failure; **maintenance10** rewards a single dependency authority and small change. Scores are design judgments, not empirical passes.

Hard constraints: keep Node/npm guard, exact runtime, staged content, full outer/nested phases, native failure classification and normal installed-hook execution. Do not add bypasses, retain the affected graph as a marker, copy PS hook topology, or change installer behavior. No TF implementation precedes accepted PS source and the assigned transfer boundary.

## 5. Scores

| Option | Security35 | Behavior35 | Failure20 | Maintenance10 | Total | Key uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| N | 1 | 5 | 3 | 4 | 62 | Honest hold; security repair remains absent. |
| S | 5 | 5 | 3 | 3 | 88 | Sentinels can exist while imports fail. |
| R | 5 | 5 | 4 | 5 | 96 | Actual installed-hook missing-tool cases remain to execute. |
| P | 5 | 5 | 4 | 2 | 90 | Adds a second dependency-resolution contract. |
| H | 5 | 1 | 4 | 4 | 66; ineligible | Drops retained full-worktree phases. |
| K | 1 | 5 | 4 | 2 | 62; ineligible | Affected graph remains installed. |

R wins because the hook already executes and classifies the real API consumer. Another presence/import check adds no required gate that the actual checker lacks. This is an objective responsibility difference; the total does not substitute for future negative controls.

## 6. Controlled selection

Select R for the future TF transfer. Remove only the CLI2 binary prerequisite block. Keep the existing Node/npm check. Invoke the staged checker through the existing shell branch. Keep every existing status refusal. Keep both later full-worktree commands and their failure handling. Keep CI/production hook activation and explicit HUSKY=0 behavior unchanged. Do not edit PS's frozen urgent ten paths for this peer incompatibility.

Amend the future TF path scope to include `.husky/pre-commit` and faithful hook fixtures. This is ordinary scoped repair under the owner-directed transfer; it is not a new human approval requirement or current implementation release.

## 7. Meaningful future verification

After accepted source and TF writer assignment, run normal installed Git commits in private complete TF fixtures on Windows/Linux. Valid staged and full-worktree content must commit. Missing `markdownlint`/required helper and wrong Node must fail with the existing tooling guidance. Invalid staged nested content must fail despite a clean worktree. Clean staged data with an unrelated invalid outer document must fail in the retained full outer phase; repeat with invalid nested content that passes outer lint to prove the final phase remains effective. Preserve empty/non-Markdown staged behavior, normal hooks and source immutability. Reuse unchanged source tests where applicable, but do not call a staged-only PS hook proof a TF full-hook proof. No tests or product changes occurred in this preparation.

Coordinator disposition: retain this selected future adaptation. All six totals were independently recalculated; exact native hook/validator source and paired Git identities were checked. Source acceptance, refreshed native inputs and the stated A21 prerequisite still control implementation. No transfer, test, base selection or product edit is released by this planning record.
