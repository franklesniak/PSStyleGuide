<!-- markdownlint-disable MD013 -->
# A06-R1: Preserve each platform pass exit status

State: root displayed the six options, rubric, scores and selected option C, then explicitly released the corresponding repair. Implementation and focused verification are complete. This is the single canonical writer draft. Root owns its eventual planning publication.

## 1. Validate

The current three build platform proof steps call the actual harness twice as direct PowerShell scripts. They then run Git and publish a revision. A script `exit 7` returns control to this caller; subsequent successful Git replaces LASTEXITCODE with zero. The existing required verifier accepts the resulting success job plus same-revision output. Thus the selected required-check admission can accept failed passes.

Root reproduced this with the unchanged actual Windows7 proof body, normal hosted Stop preference and final LASTEXITCODE forwarding, and real fixed Windows Git in an isolated repository. Both harness stubs exited7. The host exited0 and published revision82abb4d8b7a566e33e2517e16ef1b7080b6e4527. The exit0 control also exited0 and published that revision. Evidence: [root reproduction and current evidence](source-validation.json); workflow SHA256 fbe1d77c578e0b48d942fde6d8a094c23206faa6f8c48b31954d31821834b9b1; proof-body SHA256 92720af5b7a4f55518472b628b8f7e78c339bcf8f792f269f12dc66cd7427187. Runtime: Windows PowerShell Core7.6.5 at the root-recorded executable. The experiment proves caller status loss. It is not hosted Windows5.1/Linux execution or an actual generator defect.

Microsoft documents that direct script calls can leave or replace LASTEXITCODE, while a new `-File` process returns zero on successful completion, one on a terminating exception, or the explicit exit value. This applies to [PowerShell7](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-7.5#lastexitcode) and [Windows PowerShell5.1](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-5.1#lastexitcode). GitHub's [hosted shell contract](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#jobsjob_idstepsshell) supplies Stop preference and forwards the final native status. Neither feature preserves an earlier overwritten status. References read2026-10-05.

## 2. Stakeholders

The owner, both maintainers and generated-artifact consumers need the existing required check to represent both actual passes. Windows5.1/7 and Linux7 contributors need the selected host with normal policy, reproducible failures, and no extra setup. CI/platform operators and QA need separate first-pass and second-pass refusal evidence. Security and supply-chain reviewers need failed or missing proof to prevent publication, with no added token permission. Incident operators and history custodians need honest evidence of what ran. New contributors, authors, agents and their operators need a short documented invocation whose status does not depend on previous native commands. Reviewers and cost/schedule owners need a bounded change and small controls. Accessibility, localization, privacy and application/cloud administrators have no new interface or data exposure from this internal process boundary; broader settings, recovery design and guide changes remain outside this finding.

## 3. Options

- A: Retain the direct calls and rely on logs, Stop preference and final status. The reproduced false success remains.
- B: Keep direct script calls. Reset status before each call. Capture immediate success and LASTEXITCODE. Reject failures. This is the smaller repair, but direct scripts still share caller process state and need a maintained status convention.
- C: Resolve the current host executable. Start each harness pass with `-File`. Capture its native status immediately. Reject a nonzero status before any later command. Keep the normal platform shell, two passes, same-revision output and existing aggregate.
- D: Put each pass in a separate workflow step with immediate failure checks. Keep the revision publication after both steps. This can preserve each failure, but it expands the finite role graph and retains direct-script status conventions unless it incorporates C.
- E: Use B and require a defined, validated harness success report after each pass. This adds independent completion-shape checking but also adds a caller/callee contract and leaves the direct-call status convention.
- F: Use C and require a defined, validated harness success report after each pass. This adds a second success signal and a parser/migration interface. It cannot prove that a maliciously replaced harness ran its tests.

Native `-File` reuse is C. A shared extra launcher would implement C but adds an unnecessary file/interface outside the freeze. Removal and deferral are ineligible boundary choices: removal loses required real-host proof, and deferral retains the confirmed false-success path. A targeted exception also fails the hard constraints. An external action or runtime installer is unnecessary. D combined with a process boundary shares C's semantics but adds step-graph overhead. E/F must still preserve native failure; a success report alone is insufficient.

## 4. New rubric

Scores are1–5: 1 fails the criterion; 2 has major gaps; 3 is adequate with material limits; 4 is strong with a bounded drawback; 5 fully serves this finding. Weighted total is sum(weight times score)/5. Scores express judgment, not measured probabilities.

| Criterion | Weight | Meaning |
| --- | ---: | --- |
| Failure preservation | 45 | Neither failed pass can reach revision publication or a successful proof result. |
| Host semantics | 20 | Use the selected actual5.1/7 executable and normal policy. Separate explicit exit from inherited or stale LASTEXITCODE. |
| Verification strength | 15 | Separate failed-pass controls reproduce the real invocation boundary and prove no output. |
| Maintainability and usability | 10 | New contributors and reviewers can understand the invocation and fixed pass-failure diagnostic. Avoid competing success contracts and unclear status ownership. |
| Runtime cost | 5 | Keep the existing tests with small process overhead and no extra installation. |
| Change cost | 5 | Limit interface/schema churn and fit the current freeze. |

Hard constraints: run the actual focused harness twice in each selected cell; never use an execution-policy bypass; preserve the required verifier and publisher dependency; reject each failed pass before revision output; do not claim fixture execution as real hosted generator proof. A score cannot waive these constraints.

## 5. Scores before selection

| Option | Failure | Host | Verification | Maintainability | Runtime | Change | Total | Key uncertainty / hard constraint |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 1 | 5 | 1 | 5 | 5 | 5 | 52 | Proven false success; fails hard constraint. |
| B | 4 | 4 | 4 | 4 | 5 | 5 | 82 | More shared-state status assumptions than a process boundary. |
| C | 5 | 5 | 5 | 4 | 4 | 4 | 96 | Small process-start cost; real hosted runs remain required. |
| D | 5 | 4 | 5 | 4 | 4 | 3 | 91 | Separate steps clarify pass diagnostics but expand exact graph maintenance. |
| E | 5 | 4 | 5 | 3 | 4 | 3 | 89 | New success contract plus direct-call native-status convention. |
| F | 5 | 5 | 5 | 3 | 4 | 2 | 92 | New success contract and corresponding migration/shape tests. |

Arithmetic checked for all six rows. C has the highest score and meets every hard constraint. F has the same runtime score as C: JSON validation is not assigned an unmeasured runtime penalty. D/E/F offer useful diagnostics, but the existing harness already prints a completion summary and C identifies the failed pass at its native boundary. Their extra interfaces do not add demonstrated coverage for this status-loss defect. The lower maintenance/change scores reflect those additional contracts, not line count alone. C removes the measured status-loss mechanism with the existing runtime and does not extend a result schema.

## 6. Selected solution

Use option C. Get the executable path of the current PowerShell process. Fail if that path is empty or absent. Use that executable for each harness pass. Use `-NoLogo -NoProfile -NonInteractive -File`. Keep the cell's fixed `-ExpectedHost` value. Read LASTEXITCODE immediately after each process ends. Fail if it is not integer zero. Do not start pass2 if pass1 fails. Do not write the revision if either pass fails. Keep the same-revision Git check after pass2. Keep normal hosted execution policy.

Update the exact workflow-policy proof interface. Add mutations for the process call and each immediate status check. Add actual-proof-body fixture controls for pass1 exit7 and pass2 exit7. Require a failed host result and an absent revision in both cases. Require two recorded calls and the exact revision in the success case. Also test a terminating exception. Keep these fixture results separate from real hosted generator evidence.

These short instructions use one action per sentence, consistent names, explicit conditions and limits in the ASD-STE100 style. No formal dictionary certification is claimed. The repair stays in build.yml, Validate-WorkflowPolicy.mjs, its cases/tests and Test-CiHelpers.test.mjs. No new path, required-context setting, dependency or guide edit is needed.

## 7. Implementation and verification

Root released option C before the corresponding repair. Each of the three actual proof bodies now resolves its current process executable, launches each real harness pass with -File, captures integer native status immediately, and refuses failure before another pass or revision output. The exact workflow policy and four focused catalog mutations changed atomically.

Focused Windows7.6.5 verification: the actual proof-body fixture exercised12 combinations (three role bodies times first-pass exit7, second-pass exit7, terminating exception, and two-success control). All three failure cases per role returned nonzero and produced no revision output. Pass1/exception stopped after one call; pass2 stopped after two. Each success made two calls with the expected host argument and published the exact fixture revision. This used real current-host child processes and real fixed Windows Git in a private repository. Foreign Git paths were adapted in the Linux role body; the harness was a fixture. These are caller controls, not actual hosted Windows5.1/Linux generator passes.

`platform-controls.log` records4/4 test groups passing,0failed,0cancelled,0skipped. The other groups execute admission failure cases and the actual Windows acquisition body with synthetic external Git. `policy-test.log` records178/178 passing across both required-context names. `workflow-cli.log` confirms the final graph. Final actual generator Windows7 runs each passed112 assertions in their separate logs. Full Linux aggregate and actual hosted cells remain root-owned and unexecuted here. Root's original reproduction evidence remains unchanged.
