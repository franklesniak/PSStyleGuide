<!-- markdownlint-disable MD013 -->
# TF68 round 5: dedicated setup activation proposal

## 1. Validated facts and limits

The saved exact-head service job **used the legacy coding setup**, despite the new dedicated file in the PR. This validates an activation gap; it does not prove that the dedicated YAML is malformed or that the current run has failed.

`round5-copilot-jobs-first.json`, captured 2026-10-06 07:34:39Z, records run `37430212759`, job `112159069361`, head `5ec4bdc06431de05e93067b0e52f0dfbb1631392`, status `in_progress`, conclusion null. Its coding-only `Run complete repository validation` step began at 07:32:37Z. Root's later checkpoint identifies exact-head Codex result `6011648718` as clean; Copilot and ordinary runs remain independently pending in the supplied observation. This proposal starts no retry and assigns no terminal result to a pending operation.

Raw Git evidence establishes:

- Accepted base `e21b74fe0b56551008f78f9f2946cd2a0f9c19ce` has no `.github/workflows/copilot-code-review.yml`.
- Published H has that file as mode `100644`, blob `780daadb72e9c0861889ccf12e948e6488ad5cbe`, SHA256 `e998905e4883d456cb0c1f62e95e434c7aafb4bc1a51370dbd37ab3e17b6464a`. Its 14 steps omit complete repository validation.
- Both B and H have the **same** coding setup blob `1e63056656df62e78f4b6aaa5f14f0c81b9055cb`, SHA256 `44ea169d2f0fef29086f92bbd5f4145fbd60403d498ea3f96ff16cb702494a29`, including all 15 steps. Therefore the observed coding step cannot distinguish whether GitHub read that file from B, H, default branch, or a registered copy. `head_sha` identifies the reviewed run input; it does not identify the setup configuration's source revision.

The current execution-state explicitly requires actual dedicated selection/completion. A green legacy run would resolve its CI result, but would not prove S1 activation. The S1 proposal already warned about a possible default-branch activation constraint. No code repair, source omission, permission change or rename is supported by this evidence alone.

### Primary-source findings

GitHub documents dedicated-file precedence and fallback to coding setup. It separately states that coding setup must be present on the default branch to trigger, and distinguishes ordinary workflow validation from later agent use. The inspected pages do **not** explicitly identify the source revision used to look up the dedicated review file. Default-branch activation is the leading inference from these rules and the observed fallback, not a proved internal lookup algorithm. [Review environment](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-code-review#customizing-copilot-code-reviews-environment), [setup environment](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/customize-the-agent-environment#customizing-copilots-development-environment-with-copilot-setup-steps).

The documented head-branch rule applies expressly to repository instructions, agent instructions and skills. It cannot be extended to workflow selection. GitHub's July 17 changelog confirms the dedicated file feature and fallback, but supplies no revision-selection guarantee. [Instructions rule](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-code-review#customizing-copilots-reviews-with-custom-instructions), [official feature announcement](https://github.blog/changelog/2026-07-17-copilot-code-review-customization-and-configurability-improvements/).

Documented runner controls support larger runners and ARC, not a discovered switch to choose the PR-head setup file. Availability for this repository/account is unverified. Runner settings descriptions differ between the current runner page and July changelog regarding shared versus separate organization controls; no unsupported setting is assumed. Standard public-runner minutes are free, while larger runners are charged. Neither this selection observation nor previous timeout annotations establish a billing failure. [Runner configuration](https://docs.github.com/en/copilot/how-tos/copilot-on-github/set-up-copilot/configure-runners), [billing](https://docs.github.com/en/billing/concepts/product-billing/github-actions).

### Bootstrap timing is not established

The accepted-base lineage is not a fast-service baseline. TF67's final head, which merged to e21, had Copilot run `37338466878` cancelled during full validation at the observed 20-minute service limit; ordinary and landed workflows passed. Historical owner acceptance remains closed and grants no new exception. The earlier TF66 record also shows full validation consuming about 19 minutes before review processing timed out. These are historical workload warnings, not predictions for a new bootstrap. A smaller file diff does not make all-files validation smaller. No new timing test was run.

The current isolated Linux full Node run logged 600 tests in 219,394.7 ms (about 3m39s). Root records 22m31s for the 11-hook aggregate, with the final instruction-mutation hook dominant. That log has no per-case timing. It does not identify a specific internal hotspot or prove that more CPU, retries or a bootstrap will finish within the service limit. A later bounded performance investigation must begin with that missing attribution rather than an assumed optimization.

## 2. Options before scoring

All alternatives preserve current request ownership and wait for pending operations before any new action. “Green” means every applicable current CI result, including dynamic setup, plus required reviews/gates; ordinary success cannot substitute for a cancelled service run.

| ID | Distinct option and practical boundary |
| --- | --- |
| A | Wait for current results only, retaining the unresolved activation requirement. Safe now, but it does not resolve workflow activation even if legacy setup succeeds. |
| B | If every current gate becomes green, explicitly revise delivery sequencing: normal source landing first, then actual dedicated-service activation proof before S1/task completion. Preserve all essential premerge code/security/CI/review gates. If current CI fails, this branch is unavailable. |
| C | After current results, prepare a separately reviewed activation/bootstrap dependency on accepted base. Merge it only with all its own gates green, then rebind TF68 and prove dedicated selection before TF68 completion. Its legacy setup can also timeout. |
| D | Split/bootstrap immediately without first using the current pending result. Adds parallel dependency/review work and repeats an unresolved timing risk. No current release permits this action. |
| E | Profile the actual full-validation bottleneck and optimize it while preserving tests and security semantics. Could help both service paths; no concrete safe speedup or runtime margin has yet been established. |
| F | After a terminal failure, retry unchanged legacy setup at most hourly, with exact-input binding and retained failed evidence. Variance may allow success, but retry does not change file selection or supply a reliability guarantee. No automatic loop. |
| G | Ask GitHub for the precise dedicated-file registration/revision rule or a supported service-side correction. Useful if activation remains ambiguous; response time and available remedy are unknown. Sending that message needs explicit authority. |
| H | Use a supported larger runner after verifying actual account availability, configuration path, cost and measured benefit. May reduce CPU time; does not itself establish dedicated-file selection. |
| I | Use an isolated supported ARC runner. Requires infrastructure/security operations and evidence; disproportionately large without a measured need. |
| J | Rename the PR-only workflow/job or dispatch its ordinary Actions workflow to force service activation. No supporting selection rule; the current filename/job are already documented. Ineligible as an asserted fix. |
| K | Use a hypothetical setup-source/default-branch-selection setting. No such supported control was found. Ineligible until a real documented control is identified; G is the valid discovery path. |
| L | Switch default branch, direct-push main, or self-accept a bootstrap to make the file visible. Bypasses required admission and changes repository authority. Ineligible. |
| M | Ignore current failure/cancellation because Lite review or ordinary CI passed, delete its check, or reuse historical TF67 acceptance. Violates the owner's rule. Ineligible. |
| N | Remove/soften the coding full sweep, introduce an unproved service-only skip, or disable reviews to avoid their failure. Violates retained validation/review requirements and is not S1 activation. Ineligible. |

B can be combined with G if post-landing selection is still unclear. C can be followed by E or a permitted F only after a concrete failure is inspected. Such combinations retain each prerequisite and do not become a waiver. Increasing the already-59-minute YAML ceiling has no demonstrated power over an external service limit and is not another viable fix.

## 3. New activation rubric

Scores are 0–10; total = sum(weight × score) / 10. These are engineering judgments, not measured success probabilities.

- **Truthful admission, 30%:** preserve every required current-input CI/review/security gate; distinguish source landing from feature activation; never relabel pending, cancelled or failed work.
- **Activation effectiveness, 25%:** give an observable route to service selecting the intended file, accounting for registration uncertainty and the bootstrap's own timeout risk.
- **Security and test fidelity, 20%:** retain accepted-source trust, bounded setup readers, required defaults, no-credential/no-action checks, dependency fixes and full coding/ordinary validation.
- **Operator/contributor usability, 15%:** minimize needless waiting and circular work; provide clear stop conditions, useful diagnostics and reproducible next steps without gambling on runtimes.
- **Verification quality, 7%:** bind exact inputs and native receipts, prove the selected setup rather than only YAML syntax, and preserve failures.
- **Churn/cost, 3%:** avoid duplicate PRs, paid infrastructure and repeated checks when a supported lower-cost route suffices.

Hard constraints override totals: no failing-CI merge, no duplicate pending request, retries no faster than hourly, no default-branch manipulation, no review/validation bypass, no clock/counter reset. An uncertain branch is not an implementation release.

| ID | Admission30 | Activation25 | Security20 | Usability15 | Verification7 | Churn3 | Total | Eligibility |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 10 | 4 | 10 | 8 | 6 | 10 | 79.2 | Safe immediate wait; incomplete remedy |
| B | 10 | 8 | 10 | 9 | 10 | 10 | **93.5** | Conditional on all-green current input and explicit sequencing selection |
| C | 10 | 6 | 10 | 7 | 9 | 4 | 83.0 | Conditional bootstrap preparation; timing unproved |
| D | 8 | 6 | 10 | 4 | 8 | 3 | 71.5 | Wasteful before pending outcome |
| E | 10 | 6 | 9 | 6 | 8 | 4 | 78.8 | Needs a demonstrated optimization |
| F | 9 | 3 | 10 | 5 | 5 | 10 | 68.5 | Limited retry, not selection repair |
| G | 10 | 6 | 10 | 7 | 7 | 8 | 82.8 | Provider response unavailable |
| H | 9 | 6 | 8 | 5 | 6 | 2 | 70.3 | Availability/cost/benefit unproved |
| I | 9 | 6 | 7 | 3 | 6 | 1 | 65.0 | Infrastructure prerequisite |
| J | 7 | 2 | 8 | 4 | 4 | 8 | 53.2 | Ineligible unsupported fix |
| K | 7 | 2 | 8 | 4 | 3 | 8 | 52.5 | Ineligible nonexistent/unverified control |
| L | 0 | 8 | 1 | 2 | 2 | 8 | 28.8 | Ineligible admission bypass |
| M | 0 | 8 | 1 | 5 | 1 | 10 | 33.2 | Ineligible CI waiver |
| N | 2 | 6 | 3 | 5 | 6 | 7 | 40.8 | Ineligible validation/review bypass |

## 4. Selected conditional procedure — B93.5

B is the clear planning winner **if its green-input condition becomes true**. It is not a claim that current CI is green or that the service will select the new file after landing. No implementation or merge is released by this report.

1. Let the existing Copilot request and ordinary runs finish. Reconcile Codex's clean exact-head result. Preserve all requests, logs and conclusions. Do not retry while one is pending.
2. If any applicable current CI fails or is cancelled, stop the merge path. Inspect its actual cause. B is unavailable. A new run may occur only under root's control, after the hourly boundary and current-request reconciliation. Do not call a Lite review a successful workflow.
3. If all current CI and both current-input reviews are clean, root must explicitly select and record the revised delivery order before merge. Keep all normal premerge validation, final audit, immutable endpoints and security/quality gates. Record that the legacy setup passed, but dedicated activation remains unproved.
4. Only then perform the normal reviewed source landing. This enables default-branch registration without direct writes or an acceptance bypass. Keep S1 operational delivery and the affected overall task incomplete; do not label the dedicated setup successful.
5. Bind the actual landed commit/tree and updated native main. Use the next legitimate exact-input review/service run, under existing request authorization/rate limits, to inspect the selected user-step list and terminal result. Require dedicated preparation, absence of the coding-only full sweep, retained final immutable guard, and successful service completion. Ordinary manual workflow success alone does not pass this gate. Do not create a dummy product change to trigger it.
6. If selection still falls back or post-landing CI fails, preserve the evidence, stop further merges/affected delivery and report to the owner for the applicable triage. Ask the provider the exact registration, source-revision and feature-availability questions only if authorized. Do not add a retrospective waiver.

The owner need not choose a speculative timeout or purchase runners for B. The concrete missing authorization is **root's selection of this revised sequencing**, which changes the prior placement of native activation proof; that change must be displayed and recorded, not silently inferred. It does not weaken an essential code/security/review/CI premerge check. If the owner requires dedicated-service proof strictly before any default-branch landing, B is unavailable and root must choose C or await a supported provider route. No user confirmation is requested by this worker.

## 5. Concrete C fallback scope and limits

If B is unavailable or rejected, a bootstrap is only a promising proposal. An isolated candidate based on accepted e21 would need narrow integration in at least seven paths: new `copilot-code-review.yml`; `Test-AgentInstructions.ps1`; `Test-AgentInstructions.SelfTest.ps1`; `Test-CiHelpers.test.mjs`; workflow `package.json`; workflow `package-lock.json`; and `docs/dependency-maintenance.md`.

The first four are the inseparable S1 preparation/security/regression closure. Reapply their narrow changes to accepted-base source; do not copy the current full CI helper/SelfTest files and accidentally import A06-dependent tests or other repairs. The three dependency paths retain selected R2: accepted base contains affected KaTeX 0.16.27, so a bootstrap cannot assume a clean current audit while omitting the known fix. Preserve required genuine metadata. Any necessary R1/R5 or other prerequisite repair must be assessed against the actual minimal candidate, not silently omitted or imported wholesale. The seven paths are a derivable design lower bound, **not an apply-ready validated patch or final exhaustive implementation scope**.

Retain the same no-action/no-credential, strict old-input/default, optional historical absence, bounded staged/revision reader and meaningful negative tests. Run the bootstrap's required actual checks/reviews and legacy dynamic setup. If it times out, it cannot merge. Historical accepted-base cancellation makes that risk concrete. A performance fix requires its own measured proposal; shortening the diff does not establish sufficient runtime margin.

Only after a fully green bootstrap lands may root rebind/rebase the still-unaccepted TF68 input and request its new exact-head validation/reviews. Preserve the original TF68 deadline `2026-10-13T23:47:31Z`, review history and coupled transfer accounting. A dependency PR does not reset the task clock or erase failed attempts. Root must select/release any scope, counter or lifecycle changes before implementation.

## 6. Evidence boundary

The JSON binds B/H raw Git identities, actual saved job steps, current execution-state digest/selected fields, original S1 and security decisions, historical accepted-base timing, primary-source claims and every weighted total. No product/planning/Git/dependency/native mutation, test, CI launch, review request, counter change or descendant occurred. This report is a decision proposal; it changes no acceptance state.
