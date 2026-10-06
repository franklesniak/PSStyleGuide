<!-- markdownlint-disable MD013 -->
# Owner CI hold and merge audit

**Current disposition,2026-10-06:** Owner accepted both historical cases. The subsequent goal continuation was confirmed active by get_goal at04:49:11Z. Resume the unfinished plan under the retained no-failing-CI merge rule and hourly maximum retry rate. The earlier pause and evidence below are history. No GitHub outage is proved by these records. Historical acceptance is not permission to bypass a current or future failed/cancelled workflow.

Status: paused for owner triage. The owner directed: do not merge any PR while CI is failing; CI may be relaunched at most once per hour; pause further work if a PR was merged with CI failing. This report preserves the distinction between a failed ordinary check, a cancelled review service workflow, and a failure first produced after merge. No new implementation, review request, merge or CI relaunch was made during this audit.

## Findings requiring owner review

1. TerraformStyleGuide PR67 merged at2026-10-05T17:00:39Z, head443b2fe3cbeda18402f0432e5c95379d09096d6a, mergee21b74fe0b56551008f78f9f2946cd2a0f9c19ce. Its final-head [Copilot workflow37338466878](https://github.com/franklesniak/TerraformStyleGuide/actions/runs/37338466878) was cancelled at16:28:44Z. Authenticated job111859168634 says it exceeded the maximum20minute execution time while running complete repository validation. All11 ordinary candidate workflows completed successfully before the merge, and all landed workflows passed. The earlier process accepted the separate Lite review and evidence-backed dispositions while preserving the service cancellation. It did not make that workflow successful. This is the pre-merge non-success case triggering the conservative owner hold. The observed cause is timeout, not a billing rejection.
2. PSStyleGuide PR224 merged at2026-10-03T06:05:19Z, head4b69e39d2fdcbe6990ed483a712c5be4ae7874f2, merge3ba0f4d9686af41ae0e77c65ea374fff9d1cef53. Its7 ordinary final-head workflows completed successfully before merge. The [landed instruction workflow37101903079](https://github.com/franklesniak/PSStyleGuide/actions/runs/37101903079) started after merge and failed at06:25:09Z. Its checker logged successful transition checks, then the PowerShell caller read the wrong completion indicator and threw. The recorded F13 repair replaced that script-completion check with PowerShell `$?`, retaining native `$LASTEXITCODE` checks for native calls. PR226 delivered that repair; its candidate and landed workflow inventories are successful. The original failure is preserved. It was not a known failing pre-merge check and not a budget rejection.

## Scope and native evidence

Read-only authenticated complete REST pagination enumerated closed PRs in both repositories and selected all14 merges since2026-10-02T00:00:00Z. This includes historical TF65. For each final PR head and actual merged commit, all workflow-run pages were saved. The latest run per workflow/event created before merge was compared with the native merge timestamp. All ordinary pre-merge selected runs are terminal success and their latest update precedes merge. Earlier superseded failures remain in the inventory; they are not current failures. The two cases above have exact attempt1 job/annotation/log evidence. This audit does not claim to cover every PR beforeOctober2 or inspect account billing.

| PR | Merged UTC | Ordinary final-head CI | Review workflow | Landed CI |
| --- | --- | --- | --- | --- |
| [PSStyleGuide#234](https://github.com/franklesniak/PSStyleGuide/pull/234) | 2026-10-05T22:55:51Z | 11successful | Latest runs successful | All recorded workflows successful |
| [PSStyleGuide#233](https://github.com/franklesniak/PSStyleGuide/pull/233) | 2026-10-05T18:24:13Z | 11successful | Latest runs successful | All recorded workflows successful |
| [PSStyleGuide#232](https://github.com/franklesniak/PSStyleGuide/pull/232) | 2026-10-05T13:12:25Z | 11successful | Latest runs successful | All recorded workflows successful |
| [PSStyleGuide#231](https://github.com/franklesniak/PSStyleGuide/pull/231) | 2026-10-04T13:07:52Z | 11successful | Latest runs successful | All recorded workflows successful |
| [PSStyleGuide#230](https://github.com/franklesniak/PSStyleGuide/pull/230) | 2026-10-04T09:07:46Z | 9successful | Latest runs successful | All recorded workflows successful |
| [PSStyleGuide#229](https://github.com/franklesniak/PSStyleGuide/pull/229) | 2026-10-03T19:03:23Z | 6successful | Latest runs successful | All recorded workflows successful |
| [PSStyleGuide#228](https://github.com/franklesniak/PSStyleGuide/pull/228) | 2026-10-03T13:32:51Z | 8successful | Latest runs successful | All recorded workflows successful |
| [PSStyleGuide#227](https://github.com/franklesniak/PSStyleGuide/pull/227) | 2026-10-03T12:11:07Z | 7successful | Latest runs successful | All recorded workflows successful |
| [PSStyleGuide#226](https://github.com/franklesniak/PSStyleGuide/pull/226) | 2026-10-03T08:08:02Z | 6successful | Latest runs successful | All recorded workflows successful |
| [PSStyleGuide#225](https://github.com/franklesniak/PSStyleGuide/pull/225) | 2026-10-03T04:18:11Z | 8successful | Latest runs successful | All recorded workflows successful |
| [PSStyleGuide#224](https://github.com/franklesniak/PSStyleGuide/pull/224) | 2026-10-03T06:05:19Z | 7successful | Latest runs successful | Instruction workflow failed; later repairPS226 |
| [TerraformStyleGuide#67](https://github.com/franklesniak/TerraformStyleGuide/pull/67) | 2026-10-05T17:00:39Z | 11successful | Cancelled:20minute timeout | All recorded workflows successful |
| [TerraformStyleGuide#66](https://github.com/franklesniak/TerraformStyleGuide/pull/66) | 2026-10-05T05:03:00Z | 11successful | Latest runs successful | All recorded workflows successful |
| [TerraformStyleGuide#65](https://github.com/franklesniak/TerraformStyleGuide/pull/65) | 2026-10-02T00:18:44Z | 7successful | Latest runs successful | All recorded workflows successful |

Canonical evidence: [inventory](inventory.json), [PS224 details](PSStyleGuide-224/37101903079/detail.json), [TF67 details](TerraformStyleGuide-67/37338466878/detail.json), [raw evidence hashes](native-evidence-hashes.json). Raw native pages/logs remain at C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A06-TF-peer-20261005/owner-ci-audit-20261006. Existing repair evidence: ../A02/landed-exit-handoff.md and the PR226 native inventory.

## Current work saved

TF68 remains open at7dd48f52c9e4c17268b4a571919622f4d701e5d0/tree0fe10c22e777dba76ce7511def2216bd2ec3b996; no merge. All11 ordinary current-head workflows passed, including both567-test runs and both11-hook setup runs. Its separate Copilot review workflow37412403267 timed out at20minutes and is cancelled; the completed Lite review contains R6-R9 findings. Codex is clean. R6-R9 decisions remain unfinished; private source snapshots and probes are saved under scratch writer/TF68-round3. No product edits were released. The worker was instructed to save and stop; its subsequent native status was pending_init and root interrupted that pending initialization. No test session is outstanding in the current root.

Planning C:/Users/flesniak/GitHub/PSStyleGuide remains planning-CRT-PR-852 at publishedf644bc2f014c945ccb7c166f3677490d8440cae9 plus local checkpoint/audit changes and preserved unrelated work. Product worktree C:/Users/flesniak/AppData/Local/Temp/TerraformStyleGuide-A02-peer-docs-20261003 remains clean on codex/a06-generator-convergence at7dd48f5. PS main9817762 and TF maine21b74f acceptance history are preserved; no rollback or force action is authorized. Held A07 index remains untouched.

TF68 round3/80, first request2026-10-05T23:47:31Z, original deadline2026-10-13T23:47:31Z. Transfers A06/A03/A21/A07 remain1/3/5/5of12. Other original clocks/counters stay unchanged. Pausing does not reset deadlines. The overall22-outcome/402-contract/five-issue goal remains incomplete. The later PS repair and remaining plan phases have not started.

## Resume boundary

Wait for the owner to review these cases and explicitly resume. Do not implement, request reviews, merge, rerun CI or schedule retries while paused. On resume, read STATUS, this report, LOOP-POLICY, and current execution-state.json. Reconcile live native state and any elapsed deadlines before an action. Retain the no-failing-CI merge rule and minimum3600seconds between CI relaunches for the same PR. Treat the existing cancelled Copilot job as non-success requiring explicit reconciliation under the owner's direction; a valid Lite review does not make its workflow green. Do not silently waive the rule through old service-disposition logic. Reuse valid completed validation and resume the unfinished R6-R9 decision process only after the hold is lifted.

GitHub's current documentation says standard GitHub-hosted runner usage in public repositories is free; larger runners are charged. Neither observed failure establishes a budget problem. See [GitHub Actions billing](https://docs.github.com/en/billing/concepts/product-billing/github-actions) and [GitHub-hosted runners](https://docs.github.com/en/actions/reference/runners/github-hosted-runners).
