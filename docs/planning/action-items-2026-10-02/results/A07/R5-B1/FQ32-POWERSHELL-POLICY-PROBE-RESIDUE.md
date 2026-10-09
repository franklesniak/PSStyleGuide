<!-- markdownlint-disable MD013 -->
# FQ32: exact-run PowerShell policy-probe residue disposition

**Root selected and implemented K: exact-run retention with separate hook-execution acceptance.** Preserve the failed controller and its namespace. Verify the exact bounded residue and unchanged validation inputs. Record the genuine11-hook success with an explicit retained-platform-probe disposition. Do not convert controller exit1 to exit0. Root selected K after presenting the options, rubric, scores and controlled-English steps. Native verification f84a4c passed in 8.812 seconds. Independent final readback remains pending.

## 1. Validated finding and limits

Current consumer: the private Windows final11 controller `W/pr239-date-final-windows-bound/run.py`. Run: `C:/Users/flesniak/PSStyleGuide-R5-private-runner-20261005/pr239-date-final-win-precommit-20261009-a1`. Root observed session5594, terminal03b7e9, controller native exit1. The saved result independently shows worker/native0, all11 configured hooks passed in order with0 skipped, Job total38916/active0/terminated0 before and after cleanup, no cleanup failures, and the sole primary failure `Fixture temporary residue`. The run lasted2053.062s,08:36:58.740841–09:11:11.796820UTC. The strict controller result remains failed.

The controller assigns its worker to the Windows Job before release and sets both TEMP and TMP to this run's private `temp`. Its worker checks storage before and after native execution (lines111–115). The main path checks native success, natural Job settlement, stream/total output caps, exact hook rows, source/index/metadata closure and runtime hashes before line159 rejects any remaining TEMP entry. The later owner comparison and `temp.rmdir()` at160–161 were not reached. The finally path checks Job emptiness, source metadata and deadline again; no cleanup error was recorded. We also read and verified the saved owner against the command/manifest nonce and SHA. This does not substitute for the skipped in-run owner check: root must freshly verify it for any separate disposition.

The only entries observed are ordinary, non-reparse, one-link files:

| Exact basename | Bytes | Last-write UTC | SHA256 |
| --- | ---: | --- | --- |
| `__PSScriptPolicyTest_glbrlxmx.tug.psm1` | 69 | 08:40:42.691315 | `1e498b481b597e1897ab45df9d9f735b8044575bcaad5f7fa3b19051b722a093` |
| `__PSScriptPolicyTest_u4o5w0g5.345.ps1` | 69 | 08:40:42.690808 | same |

Each contains one ASCII comment ending with tick count318178453, without a newline. Total residue is138 bytes. Reads were capped at70 bytes per file. File identity/size/mtime remained equal across reads. No file was run, edited, moved or deleted. `evidence.json` records full identity details and hashes of all inspected receipts/source files. Alternate streams and current ACLs were not newly probed; their fresh verification belongs to root's proposed disposition checks.

**Attribution is strong; the exact interruption is not proved.** PowerShell7.6.5 creates this random `.ps1`/`.psm1` pair in its temporary directory. Both contents use one fixed comment plus the same tick count. It attempts deletion in a finally block, but permits leftovers when removal is unavailable. [PowerShell7.6.5 policy source, lines397–403 and462–467](https://github.com/PowerShell/PowerShell/blob/v7.6.5/src/System.Management.Automation/security/wldpNativeMethods.cs#L397). Its deletion helper suppresses I/O and access errors. [PowerShell7.6.5 PathUtils, lines665–683](https://github.com/PowerShell/PowerShell/blob/v7.6.5/src/System.Management.Automation/utils/PathUtils.cs#L665). Microsoft also documents this temporary pair. [Application-control documentation](https://github.com/MicrosoftDocs/PowerShell-Docs/blob/main/reference/docs-conceptual/security/app-control/application-control.md).

The actual final hook calls `Test-AgentInstructions.ps1 -SelfTest -RequireStagedInputMatch` (`.pre-commit-config.yaml`). Its extracted self-test resolves actual pwsh at `Test-AgentInstructions.SelfTest.ps1:4553`; the100ms timeout case at4706 launches it with a30s sleep, using the real process reader at4720. `Assert-ApplicationRuntimeSelfTest` is called at4739. `Read-BoundedProcessData` starts its deadline before launching (`Test-AgentInstructions.ps1:1965–1971`), kills the process tree after failure at1999, and reaps it at2001. Thus the deadline can expire during PowerShell startup, before its policy-file finally block completes. A250ms timeout control also exists at2931, called at10605. These children inherit run TEMP and do not redirect it into a test-specific subdirectory.

This is a plausible legitimate probe-leftover route. A transient deletion failure is another route supported by upstream code. No saved process/PID timeline identifies which child wrote this pair or which route occurred. Shared timestamp/tick is consistent with one upstream creation call; it is not cryptographic process provenance. No evidence shows a product-owned fixture directory or a product teardown assertion was left incomplete. The self-tests remove their own explicit fixture roots, not all siblings in shared runtime TEMP. The current defect is the private controller's blanket assumption that every runtime TEMP file belongs to product fixture teardown.

FQ31's accepted42 controls cover Linux `/proc` identity, bounded cmdline collection, signal/settlement and fixture-link traversal. They do not cover Windows AppLocker startup files or their retention. Their raw success is reusable for its original scope and supplies no automatic exception here. Earlier strict Windows passes likewise cannot prove all possible policy-probe startups delete their files.

Changing how final-hook acceptance treats residual files changes the acceptance contract. Use the full decision process, not the five-line tooling exception. No production defect is established that requires changing the product timeout or test teardown.

## 2. Stakeholders

The owner and coordinator need truthful final-byte validation without redundant34-minute work. Windows contributors and local-agent operators need valid timeout tests to remain usable. Product and independent reviewers need to distinguish a hook result from controller containment and cleanup results. QA needs negative controls that preserve process termination behavior. Platform/security owners need AppLocker and execution-policy checks intact, plus narrow private-file handling without reparse traversal. Evidence custodians need immutable failure history and exact retained-file attribution. Maintainers of both repositories benefit from no unrelated product changes or cross-platform control spread. Schedule/cost stakeholders benefit from reusing an unchanged complete hook run when its assertions remain valid. No cloud/customer payload, generated artifact, localization, accessibility, Linux product behavior or external communication is affected by this private two-file decision; those roles do not change the choice.

## 3. Options, before scoring

| ID | Distinct option | Main tradeoff |
| --- | --- | --- |
| N | Preserve failure and defer all acceptance, without change. | Safe stop, no completion remedy. |
| R | Rerun all11 under the unchanged controller. | May produce a clean pass, but the same runtime race can recur; does not fix the assumption. |
| B | Remove the empty-TEMP check, ignore probe-like names, or recursively delete arbitrary TEMP contents. | Small implementation; masks unrelated residue and weakens evidence. Reject. |
| P | Change product self-tests to isolate child TEMP and clean it, then rerun applicable tests and all11. | Can make fixture cleanup explicit; changes product inputs and expands required validation for an unproved product defect. |
| C | Add a narrowly validated runtime-probe cleanup path to a new controller; qualify its negative cases and rerun all11. | Reusable controller remedy and fresh strict pass; new cleanup/acceptance logic and full rerun cost. |
| E | Verify this exact pair, archive exact bytes, perform bounded external disposition, and separately reuse unchanged hook success. | Truthful exact-run recovery; deletion introduces filesystem operations that hook validity does not require. Original controller stays failed. |
| F | Factor a reusable configurable residue-cleanup framework, qualify it, and rerun. | Broad reuse; disproportionate configuration, review and restart surface for two inert files. |
| K | Verify this exact pair and retain it in its private failed namespace; separately accept unchanged native hook execution with an explicit retained-residue state. | No deletion or controller edit; requires a precise scoped receipt and no namespace reuse. |
| D | Disable policy probes/security settings, remove timeout negatives, or make timeout assertions permissive. | Conceals the trigger by weakening security/test behavior. Reject. |

No-change plus another run is R. A name-only targeted exception is B, not K. K's exception is tied to exact run, names,138 bytes, SHA, manifest, final source and actual receipt. Combining a general future repair with K is separable future work; it is not required to resolve this run. Extra filesystem tracing may help upstream diagnosis later, but is not needed to establish these exact retained bytes or the completed hooks.

## 4. Finding-specific rubric

Scores are0–5:0 fails the criterion,1 is poor,3 is adequate with material limits,5 strongly meets it. Weighted total is the sum of `weight × score / 5`. The scores express engineering judgment, not empirical probabilities.

| Criterion | Weight | Meaning for this finding |
| --- | ---: | --- |
| Truthful evidence | 25 | Preserves exit1, real hook0, exact final inputs, original files and attribution without invented pass credit. |
| Bounded cleanup safety | 25 | Preserves policy checks, private containment, no-follow boundaries and negative tests; avoids unnecessary destructive handling. Retention is safe disposition if exact, bounded and private. |
| Diagnostic coverage | 20 | Explains the observed bytes, checks all relevant saved gates, rejects unrelated/modified residue and covers conditions needed for the chosen disposition. |
| Restart reliability | 20 | Leaves a clear durable receipt and reproducible next action; avoids retry races and general exceptions. Exact-run decisions lose a point because a different future residue requires new review. |
| Cost and churn | 10 | Avoids unnecessary product edits, reusable frameworks, native reruns and maintenance while fully resolving the actual scoped decision. |

Hard constraints: Never relabel or overwrite the failed controller receipt. Never bypass AppLocker, timeout tests, source/index/runtime gates or Job settlement. Never accept unknown extra residue. Do not infer an exact producer PID. Any reuse needs root's fresh exact-input and evidence checks. Only root can approve the separate acceptance contract. A retained namespace must remain private and must not be reused. A high score cannot waive these constraints.

## 5. Scores, before recommendation

| Option | Truth25 | Safety25 | Coverage20 | Restart20 | Cost10 | Total/100 | Key uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 5 | 4 | 2 | 1 | 1 | 59 | No remedy or completion. |
| R | 5 | 4 | 3 | 2 | 1 | 67 | Same probe race may recur. |
| B | 1 | 0 | 1 | 3 | 5 | 31 | Fails hard constraints. |
| P | 5 | 5 | 4 | 4 | 1 | 84 | No established product defect; new validation scope. |
| C | 5 | 4 | 5 | 5 | 2 | 89 | Unnecessary deletion and new qualification. |
| E | 5 | 4 | 5 | 4 | 5 | 91 | Safe deletion still needs extra path/identity operations. |
| F | 5 | 4 | 5 | 4 | 0 | 81 | Unnecessary deletion and a broad framework. |
| K | 5 | 5 | 5 | 4 | 5 | 96 | Exact fresh retention verification and explicit scope required. |
| D | 1 | 0 | 0 | 2 | 4 | 21 | Fails hard constraints. |

Root reduced cost below reliability to follow the owner's priorities. Root scored C/F cleanup safety consistently with E because deletion is unnecessary here. The final arithmetic is recorded in [the root decision](current-main-validation/policy-probe-retention-root-decision.json); this supersedes the private proposal's original weights. K wins because the real hook properties already passed and138 bytes can remain safely bounded in the private failed namespace. Deletion adds no hook-validity evidence. C is the best option if the owner requires a new strict-controller pass or chooses a reusable future cleanup contract. Its higher cost does not make its result less valid. The independent reader's retention suggestion was assessed as the fully specified K option; the unsafe broad-ignore option remains separate and rejected.

## 6. Selected action: K

These instructions use short, direct controlled English. No formal ASD-STE100 dictionary certification is claimed.

1. Preserve the original failed run and all its receipts.
2. Verify the actual terminal session5594 and exit1.
3. Verify the manifest hash and owner nonce.
4. Verify the private parent, run directory and TEMP ancestry without following links.
5. Verify the recorded private ACL and current access boundary.
6. Enumerate only this TEMP directory.
7. Require exactly the two names listed in this report.
8. Require ordinary files with no reparse point, extra stream or hard link.
9. Read at most70 bytes from each file.
10. Require69 bytes and the recorded SHA256 for each file.
11. Require138 total residue bytes.
12. Stop if any check differs.
13. Verify the saved native0, worker0 and exact11 ordered Passed rows.
14. Verify the saved empty Job with zero terminated processes.
15. Verify the original caps, elapsed time, runtime/storage receipts and absence of other failures.
16. Recheck the final source, index, MERGE_HEAD, config, dependency and runtime closure against the released manifest.
17. Keep both residue files in the retained private namespace.
18. Do not delete, execute or change either file.
19. Do not reuse the namespace.
20. Write one new disposition receipt after all checks succeed.

The new receipt state is `native_hooks_passed_with_retained_platform_probe_residue`. It records `controller_state=failed`, `controller_exit=1`, `native_hook_exit=0`, `worker_exit=0`, `configured_hooks=11`, `passed=11`, `skipped=0`, `private_temp_removed=false`, `namespace_retained=true`, `residue_count=2`, `residue_bytes=138`, the exact names/hashes, the original result/native/command/owner/log/manifest hashes, root's decision hash and fresh verification time. It records `no_rerun=true` and `no_controller_pass_claim=true`. This is a separate scoped hook-execution acceptance with explicit retention disposition. It does not satisfy the old strict-controller empty-TEMP predicate and must never be fed through that acceptor as if exit0 occurred.

Use a finite root verification budget, proposed60s, existing8MiB log limits,1MiB individual JSON limits,70-byte residue reads,2-entry TEMP census and64KiB new receipt. No process, Docker, test or product execution is needed for K. Root can separately decide the normal commit once all other required gates are satisfied. This proposal itself gives no commit permission.

## 7. Verification status and concrete next action

Performed: bounded read-only inspection of the actual pair and saved receipts; owner/manifest/TEMP equality checks; source/controller/test teardown review; primary upstream7.6.5 research; score arithmetic. No product/controller changes, deletions, tests, native probes, Git mutations or canonical state writes occurred.

Next: root selects the option, then performs K's finite fresh readback and writes the distinct disposition receipt if it passes. Root need not rerun the34-minute hook command solely to remove two independently understood runtime comments. The exact accepted Linux/aggregate evidence remains scoped to its original final inputs; root must preserve its existing final-source reconciliation. No source edit is proposed, so this diagnosis introduces no additional product-test scope.

If K's checks fail, retain failure and investigate the differing condition. If root selects C instead, qualify empty-TEMP success, a legitimate bounded pair, wrong content/extension/name, third file, oversize, directory/reparse/hard-link/alternate-stream entries, parent/owner drift, deletion failure and retained prior failure. Use actual Windows filesystem controls for those cases. Then run all11 once on final bytes in a fresh namespace. Those tests are proposed, not run. FQ31's Linux42 controls do not substitute for them.

## 8. Actual implementation and remaining gates

Root verification f84a4c exited 0. It completed fresh manifest, raw receipt, owner, private access, no-reparse ancestry, exact file, single-link, alternate-stream, source, dependency, runtime, Husky, Git metadata, hook, Job and limit checks. Win32 read-only file handles verified exactly 69 bytes per file. No product or controller bytes changed. No files were deleted. No test was rerun.

The [distinct acceptance receipt](current-main-validation/pr239-date-final-native-hooks-retention.json) is SHA256 `0b72f0b4665c2fdb720b3e9f7b517d114dfe3329d6334487a5982647dd713ab2`. It preserves controller exit 1, strict-controller-pass false and private-temp-removed false. It separately accepts native hook exit 0 and all eleven passed checks. The failed raw run and both files remain unchanged. This is a decision for that exact run only.

Independent final readback passed: final-local addendum SHA256 b05d82d6413baf1a8fd727ab991cb2e27c991a3a470aaa6f7d539ea07aebf881 and evidence 9ee33be2afdaa8b703d2cbb7d720e158297176b9d8651bf1dbbad02ba43a22a5, fully read by root754812. Normal commit fd8996 passed all three Husky stages and produced c1ef946fe4585836f27a0a4480bd986899d7c316. Current public reviews, passing CI/service proof, landed verification and paired convergence remain required. No owner input is required for this selected action under the standing clear-winner direction. The prior proposal and independent assessment remain immutable in the private workspace.

## Round 2 recurrence: exact-run assessment pending

The later run `pr239-round2-win-precommit-20261009-a1` finished at `2026-10-09T15:08:58.443336Z`, after 2,560.5 seconds. Root observed session6435, terminal `cdf533`, controller exit1. Its native and worker exits are0; all eleven ordered hooks passed without skips. Both final Job observations show 38,910 total,0 active and0 terminated processes. The sole primary failure is `Fixture temporary residue`, with no additional cleanup failure.

Root's bounded directory listing `0837c4` found exactly `__PSScriptPolicyTest_amb5dfpl.y2x.ps1` and `__PSScriptPolicyTest_h4jg5bqb.rch.psm1`, each69 bytes and ordinary in that initial observation. This does not replace fresh no-follow identity, content, link, stream, private-access, ownership and complete input checks. The [failed-run record](current-main-validation/pr239-round2-windows-precommit-failed-a1.json), SHA256 `271a010a53d2778f187eb47e8ed5f0b5b966cff5fad02b0a544b5fe95aefdcde`, preserves all raw receipt hashes.

This is a new exact-run assessment of the same FQ32 finding. The options and rationale above are reusable only if the new bounded evidence establishes their applicability. The previous two-file disposition does not automatically accept this different pair. The existing preparer is checking applicability and preparing an inert verifier derivative; root must review and execute any fresh verification. The strict controller remains failed, the namespace remains retained, and no all-eleven acceptance, source edit, rerun or cleanup action has been authorized by this pending assessment.

## Round 2 recurrence: selected K and fresh verification completed

Root reviewed the sealed new-pair assessment and verifier derivative, then selected existing option K. The same finding-specific options, rubric and score remain applicable; K scored96. The [root decision](current-main-validation/round2-policy-probe-retention-root-decision.json) pins the new run, pair, manifest and current inputs. It does not grant an exemption to another run.

Run the finite verifier once. Keep both files. Preserve the original failure. These selected steps are now complete: actual verifier session38945, terminal `caba21`, exited0 after43.641 seconds. Root read the full [verification observation](current-main-validation/round2-policy-probe-retention-verification.json), SHA256 `41e3d0aca5bad5e5a411eb7e596bc70ef620487b6f2f855136c14ca3ba159e97`. It confirms the exact file identities,69 bytes each, expected contents, single links, no extra streams or reparse points, private access, unchanged manifest/source/index/dependencies/runtimes/Husky/Git, all eleven native hooks, empty Jobs and original limits. The producer PID and reason for incomplete deletion were not observed.

The [distinct acceptance](current-main-validation/pr239-round2-native-hooks-retention.json), SHA256 `1b9103dc5f7d1974752454ce8c11e837e8a45d56fa3921bb01e2b0bc55a87913`, accepts native hook exit0 and eleven passes for this exact run. It preserves controller exit1, strict-controller-pass false and private-temp-removed false. The original failed receipt and both files remain unchanged. No test was rerun. No product or controller was changed. No file was deleted. Final independent runtime review and normal publication gates remain.

The [independent final local quality](current-main-validation/pr239-round2-final-local-quality.json) passed this fresh disposition; root full read16c56c. The [normal commit](current-main-validation/pr239-round2-normal-commit.json) then passed all three Husky stages and produced `2b5514c7a0c35b55d002935dcd771a72be1b1dcf` with the accepted tree. Current public reviews, CI, landing and paired convergence remain required.
