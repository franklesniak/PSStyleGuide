# Cleanup investigation and bounded next-evidence proposal

**The cold pair passed its comparison. The complete packet failed cleanup and remains failed.** This investigation ran no product code, test, parser, container, Git command or profile. It changed no product, frozen packet, planning or native object. Root must review and display this proposal before preparing or executing its next phase.

## 1. Validate the finding and preserve the limits

The authoritative run is `runs/tf68-ed9-cold-original-changed-one`, authorized manifest SHA256 `785471e3a5f528f57247194ddf27ea5f4291a5b49f0119a702f152e97ad5d92e`. Its host and container exited 1. The parent PowerShell process, PID84, exited 0. `inside.py` failed its line74 assertion because `adopted_cleanup.members_before` contained two records. Cleanup then cleared them. Both selected child groups and the parent group were empty. Final adopted cleanup was empty. Host/private guards were equal and the owned container was absent. Root independently verified these partial results in `../ROOT-RESULT-VERIFICATION.json`; this report supplements that proof.

| Saved fact | Observed value |
| --- | --- |
| Original child | PID5344; start16:40:01.981326Z; end16:40:13.389300Z; exit0; 11.407920466 seconds |
| Candidate child | PID5965; start16:40:13.473199Z; end16:40:21.547760Z; exit0; 8.074512943 seconds |
| B/H/clock/output oracles | Shared current reconstructed fixture; equal exact argv/cwd/clock/stdout; empty non-marker stderr; successful actual author oracle |
| Counts in each child | 59 native calls/starts/exits; 51 conversions; eight reuse hits; four generic decodes |
| Candidate initialization | One compile; 0.3080119 seconds; first structural call0.3428981 seconds; zero normal-path legacy conversions |
| Original path | 51 legacy structural conversions; no native helper compile |
| Separate parent bootstrap | Completed in7.8111535 seconds; not counted as either cold child |
| Adopted record1 | PID5331; PPID1; group/session5331; start_ticks3806 |
| Adopted record2 | PID5339; PPID1; group/session5339; start_ticks3811 |

The single pair measured a 3.333407523-second decrease, about29.22%. This remains valid **partial, one ordered case evidence** for the converter. It is not a stable speedup estimate, a complete packet pass, a clean service run or permission to merge. Preserve the measurement and all raw artifacts. Do not repeat the pair to obtain the missing cleanup evidence.

The scratch finding in five lines:

1. Parent cleanup failed because two adopted records existed before final cleanup.
2. `descendants()` omits state/command/executable; `reap_group()` discards wait receipts, so live-versus-zombie and creator are unknown.
3. Add bounded state, identity, phase and wait receipts in a new investigation packet; keep the frozen detector and failure history.
4. Propose one actual fixture-prefix run and four ownership controls; execute only after root release.
5. See the evidence map below and `evidence.json`; no production defect or detector acceptance repair is established.

### What the cleanup code proves

`owned-group.py:descendants()` finds ancestry from the container Python process but retains only PID, PPID, group, session and start ticks. Its result has no process state, command line, executable, creation parent or exit status. `members(group)` does retain state, but that function's internal results for the two adopted groups were not saved. `cleanup_adopted()` sends SIGTERM before its first reap. `reap_group()` calls nonblocking `waitpid` and discards the returned PID/status. The final disappearance is therefore consistent with both a live process terminated by cleanup and an exited process reaped by cleanup. Neither is proved. PPID1, a separate session, lower PID numbers and a successful final reap do not establish an exited state or a particular creator.

`inside.py` rejects any nonempty adopted-before census even if cleanup succeeds. That matches the frozen strict rule. It is not yet a proven detector defect. An exited adopted process still has a reaping obligation; simply ignoring an observed Z state would also be insufficient. A future proposed distinction must prove ownership, collect wait results, complete normal reaping, reject unhandled live/unknown descendants, and preserve primary failure. It cannot rewrite this run as passed. [Linux wait semantics](https://man7.org/linux/man-pages/man2/wait.2.html), [subreaper semantics](https://man7.org/linux/man-pages/man2/PR_SET_CHILD_SUBREAPER.2const.html), and the [kernel proc field definitions](https://www.kernel.org/doc/html/latest/filesystems/proc.html) support those distinctions.

### Trace the actual current caller

| Phase and saved source | Relevant behavior | Attribution limit |
| --- | --- | --- |
| Container setup, `inside.py` and `common.py` | Private bundle reconstruction/guards/runtime version calls; common Git helper supplies `gc.auto=0` and `maintenance.auto=false` | No phase census or command/PID creation record was saved. These helpers completed before the pair. |
| Driver bootstrap, `pair-driver.ps1:12` | Dots the current validator with `-RequireStagedInputMatch`; normal Node/Python/Git/Markdown admission executes | `-SelfTest` is absent. The product's `Assert-MarkdownParserTransportCleanup` call is inside `if ($SelfTest)` and is not part of this bootstrap or either selected child. |
| Clock and inquiry prefix, `author-one-case.ps1:34-437` | Current mutation-constructor control; same-process breakpoint/clock controls; bounded Node lstat inquiries, shape/native-exit/output/timeout controls and snapshots | Clock probes invoke private scripts in the parent runspace. Inquiry helpers launch real native processes and use `Read-BoundedProcessData`. No native inquiry PID or cleanup-state receipt identifies the two records. |
| Private Git setup, `author-one-case.ps1:438-532` | Clone/checkouts/index/mode/snapshot checks; ordinary private `git commit` creates B when needed and then H | Unlike `common.git`, actual commit commands do not pass maintenance suppression. Two commit sites immediately precede the first selected child. This is the leading attribution hypothesis, not proof. |
| Selected original/candidate transport, `run-child.py` | Fresh children5344/5965; subreaper enabled; group-specific cleanup has empty before/after | Good selected-group results do not themselves inspect descendants that create a different session/group. Their creation attribution remains unproved. |
| Parent tail, `inside.py:67-79` | Private guard readback; owned-group cleanup; adopted cleanup; strict before/after assertions | PID5331/5339 were first recorded only here. There is no reliable conversion from their raw start ticks to a phase because clock-tick rate/boot anchor and phase observations were not recorded. |

Git is a credible explanation for own-session children: primary Git commit code calls automatic maintenance. However, version matters. Git2.43 invokes `maintenance run --auto` and lets an actual needed auto-GC detach; Git2.56 chooses `--detach`/`--no-detach` through maintenance configuration and can detach in the maintenance task runner. The saved runtime records Node24.18.1, npm11.16.0, Python3.12.3 and PowerShell7.6.3, but **not Git's version or binary identity**. Do not treat current documentation as the pinned image's proven implementation. [Git2.43 commit source](https://raw.githubusercontent.com/git/git/v2.43.0/builtin/commit.c), [Git2.43 process source](https://raw.githubusercontent.com/git/git/v2.43.0/run-command.c), [Git2.43 GC source](https://raw.githubusercontent.com/git/git/v2.43.0/builtin/gc.c), [Git2.56 process source](https://raw.githubusercontent.com/git/git/v2.56.0/run-command.c), [Git2.56 GC source](https://raw.githubusercontent.com/git/git/v2.56.0/builtin/gc.c), [current Git maintenance documentation](https://git-scm.com/docs/git-maintenance).

## 2. Relevant stakeholders

The owner and both maintainers need a truthful failed result and a useful next gate without another unnecessary comparison. Converter and documentation consumers need unchanged admission, freshness, dates and outputs. New contributors and Windows/Linux operators need a runner with explicit bounds, dependable cleanup and useful failure receipts. QA and independent reviewers need controls that distinguish direct exit, adopted exit, live descendants, detached sessions and primary failure. Security/recovery operators need ownership evidence before signals and proof that every owned child is reaped. Platform engineers need the actual Git/runtime identity and normal maintenance semantics; silently suppressing it would change the observed caller. Auditors and schedule/cost owners need the original round/deadline and preserved partial measurement. Dependency maintainers have no requested change. Privacy/accessibility/localization roles have no changed interface or external data flow; the investigation uses an offline private fixture and bounded whitelisted process records, not arbitrary environment or credentials.

## 3. Practical options before scoring

| ID | Concrete option | Practical effect and limit |
| --- | --- | --- |
| A | Stop here; retain the failure and defer all progress. | Safe and truthful; leaves the missing attribution unresolved. |
| B | Treat empty-after as sufficient, assume Git zombies and declare the full packet passed. | Discards the strict rule and unknown live state; ineligible. |
| C | Repeat the unchanged complete cold pair. | Repeats valid timing work and still omits the missing process fields. |
| D | Retain valid pair evidence; prepare one phased current actual fixture prefix plus ownership controls; decide a later repair only from the new facts. | Targets the missing state/creator/wait evidence; selected children0; no comparison replay or semantic suppression. |
| E | Run only synthetic ownership controls. | Useful discriminator tests but cannot attribute the actual two records or validate the Git hypothesis. |
| F | Immediately change the detector to reap first or ignore zombies. | Reap-first may become a valid later normal-housekeeping repair; ignoring unreaped/unknown children is not valid. Current identity/state evidence is insufficient for immediate acceptance change. |
| G | Force private fixture Git maintenance to run in the foreground. | Potential later fixture isolation repair; keeps maintenance work but changes its scheduling and needs actual-version/provenance evidence and a new validation decision. |
| H | Explicitly disable private fixture auto maintenance or remove bootstrap/clock/inquiry checks. | Changes actual caller setup/control coverage and may mask the cause. No immediate justification; silent suppression is ineligible. |
| I | Immediately repair product process handling or revert the converter. | Could be required if a current product native caller leaks live children, but no such defect is attributed here. Unsupported immediate product change is ineligible. |
| J | Add `--init` or replace the container supervisor/shared cleanup architecture. | A genuine environment alternative if reaping policy is the cause; can also hide provenance and requires new runtime/ownership qualification. |
| K | Run a broad profile, full SelfTest/full suite or reinstall dependencies now. | Broader cost and scope; does not target the missing receipt; outside the proposed release. |

D includes the useful parts of A (truthful retained failure) and E (discriminating controls). F/G/I/J remain conditional branches after D, not simultaneous implementation. A proved product finding must receive its own current-consumer decision. There is no reason now to change common production code, factor a new global cleanup module, add persistent processes or install a tool. A native syscall trace is a possible escalation only if bounded phase/process/Git receipts remain inconclusive; it is not part of D's first phase.

## 4. Finding-specific rubric and hard constraints

Scores0-10 are judgments: 0 violates or cannot serve the criterion; 5 leaves a material gap; 10 directly serves it. This is a new rubric for the missing cleanup evidence, not the converter's C88.5 rubric. Total=(30T+25O+20A+10P+10E+5C)/10.

| Criterion | Weight | What earns a high score |
| --- | ---: | --- |
| T: Truth and evidence fidelity | 30 | Preserves failed history and valid partial measurement; distinguishes facts, hypotheses and unknown state. |
| O: Ownership and recovery | 25 | Proves owned process identity; reaps exits; rejects live/unknown residue; preserves primary error and bounded final cleanup. |
| A: Attribution precision | 20 | Identifies actual creator/phase/version with discriminating evidence rather than repeating broad work. |
| P: Product and caller fidelity | 10 | Keeps real current fixture/bootstrap/control/Git semantics and avoids unsupported production change. |
| E: Evidence efficiency | 10 | Reuses valid evidence and runs only the missing bounded control. |
| C: Change and review burden | 5 | Keeps the next packet small, inspectable and reversible. |

Hard constraints: no retrospective full-pass claim; no unknown-child exemption; no weakened owned cleanup; no skipped actual caller controls; no silent Git behavior suppression; no product/native/planning/frozen-packet edit or execution without the separate root release. A high score cannot waive any constraint. Full scoring is appropriate because some options change an acceptance/security contract; the scratch omission itself stays in the five-line note above.

## 5. All scores before selection

| ID | T | O | A | P | E | C | Total | Eligibility and key uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 8 | 10 | 1 | 10 | 4 | 10 | 70.0 | Eligible deferral; no resolution |
| B | 2 | 1 | 1 | 4 | 10 | 10 | 29.5 | Ineligible truth/cleanup loss |
| C | 5 | 9 | 4 | 9 | 2 | 8 | 60.5 | Redundant and still missing state/creator |
| D | 9 | 10 | 9 | 10 | 9 | 8 | 93.0 | Eligible bounded proposal; attribution still must be measured |
| E | 8 | 10 | 5 | 10 | 10 | 9 | 83.5 | Eligible controls; actual cause remains unknown |
| F | 5 | 5 | 2 | 10 | 8 | 8 | 53.5 | Immediate acceptance change unsupported; conditional reap-first only |
| G | 7 | 9 | 5 | 6 | 7 | 6 | 69.5 | Conditional fixture scheduling change, version not bound |
| H | 5 | 9 | 2 | 4 | 7 | 7 | 56.0 | No immediate justification; silent/skipping form ineligible |
| I | 4 | 8 | 2 | 2 | 2 | 3 | 41.5 | Immediate unsupported product edit ineligible |
| J | 7 | 9 | 4 | 7 | 6 | 5 | 67.0 | Conditional environment alternative; larger qualification |
| K | 5 | 9 | 3 | 9 | 1 | 5 | 56.0 | Outside next scope; redundant breadth |

The winner clears the hard constraints by proposing observation and controls only. It does not select a zombie exemption, product repair or a successful replacement packet. The score gives no empirical probability of the Git hypothesis.

## 6. Selected proposal: D93.0

1. Keep the original packet result as failed.
2. Keep the completed pair result as partial evidence.
3. Prepare a new packet for cleanup evidence only.
4. Use the same pinned image and current source.
5. Capture the actual Git version and binary hash.
6. Keep the actual fixture prefix and both B/H commit calls.
7. Create new private B/H objects and a new actual UTC clock.
8. Stop before the first selected child call.
9. Set the selected-child limit to zero.
10. Record process state and identity at each named phase.
11. Record each successful wait and its exit or signal result.
12. Keep the original cleanup failure condition in the observation packet.
13. Run the four ownership controls in private processes.
14. Ask root to review the exact packet before execution.
15. If evidence identifies a live product leak, return that finding for a product decision.
16. If evidence identifies only exited adopted children, propose normal reaping with controls for live and unknown children.
17. If attribution remains unknown, stop and propose the one missing trace.

These instructions use short direct sentences and consistent terms. No formal ASD-STE100 dictionary compliance is claimed.

### Exact necessary evidence and minimal preparation envelope

Prepare under a **new** directory/run ID, never overwrite or replay this consumed packet. Keep source HEADed9eea2, accepted Be21b74f, exact two source hashes and80-file/1,914-dependency catalogs unless root first reconciles a changed input. Keep the full source/dependency/Git/index/refs/modes guards, offline image SHA256 `8bdc7722fc55e19fd3df48d8fddf4568a75d8792cfc4ee105c8a8173559362f4`, pull never and read-only payload mounts. No install/network/service/native operation is proposed.

One private current actual prefix must retain ordinary driver bootstrap, clock and inquiry controls, all snapshot/mode checks, the exact ordinary B/H commit commands and original finally. Add only phase receipts. Stop at the position currently occupied by `$script:PairCase=`; record the freshly constructed B/H/clock there, then return through the original finally. **No original/candidate checker substitution, no selected child, no timing comparison and no full SelfTest/aggregate.** Prefix limits: one child,60 seconds; controls: four children,5 seconds each; parent100 seconds; whole container180 seconds; at most five task children; selected comparison children0. Keep2MiB per stream/trace,2,000 receipt events,32MiB total output and bounded final TERM/KILL/reap intervals within the container limit. Root reviews feasibility and exact hashes before release; failure is terminal, not an automatic retry.

Capture phase receipts immediately before/after bootstrap, clock/inquiry controls, private clone/setup, B commit, H commit, pre-selected stop, fixture finally and parent exit. Each process record needs raw `/proc/stat` plus parsed state, PID/PPID/group/session/start_ticks, bounded comm/cmdline, executable path/identity when readable, exact observation timestamp and phase. Record absent/unreadable fields explicitly; never infer them. Capture clock-tick rate and monotonic/UTC anchors. Maintain an owned identity ledger across exits and changed sessions. Do not signal by a stale PID alone. Capture direct-parent exits and adopted wait statuses without consuming a direct Popen child's status behind its owner's back. Do not reap an unrelated PID or use a machine-wide kill/reap pattern.

For the B/H commit windows only, capture bounded Git Trace2 events to a private file. Preserve Git argv/config/maintenance behavior; restore tracing environment after each window. Record actual Git binary/version/exec-path and only the relevant maintenance.auto, maintenance.autoDetach, gc.autoDetach, gc.auto, gc.autoPackLimit and enabled-task values with origin/unset receipts. Match trace/process events by stable identity when possible. Do not assert that a trace SID alone is a reliable OS PID. This captures creation evidence even if an exited process has empty cmdline or inaccessible exe. Binding the installed Git version permits a subsequent exact-version primary-source check; the two source versions cited above remain illustrative comparisons.

| Ownership control | Required observation and outcome |
| --- | --- |
| Direct exited child | Known child exits normally; Popen owner collects its status; no direct/adopted/group residue remains. |
| Exited adopted child in a new session | Known intermediate leader exits; its known child has exited but is not yet reaped; record actual Z state and identity, collect exact successful wait/exit receipt and prove final absence. The frozen before-census rule must still be reported as failed when nonempty. |
| Live adopted child in an escaped session | Known child calls setsid and remains live after its leader exits; group-only check cannot suffice; adoption/identity ledger must find it, report failure, terminate and reap it within bounds; no exemption for a detached session. |
| Primary failure with owned live residue | Raise a unique primary sentinel while an owned detached child remains; cleanup must remove/reap it and retain the sentinel as primary, with separate cleanup receipts/errors. |

State/identity capture precedes any signal. Instrument wait receipts at the existing reap sites without changing the observation packet's acceptance rule. Distinguish an already observed Z state from a process that cleanup terminates. The controls must verify both state transitions and terminal emptiness, not merely mocked list contents. A future detector repair must also treat unreadable/racing identity as failure, preserve PID-reuse checks, and prove that normal reaping succeeds before any success decision.

## 7. Implementation and verification state

Only this report and evidence record are delivered. The selected observation/control packet has **not** been implemented, parsed or executed. No repair is authorized by the score table. Root must validate/display the options, rubric, scores and choice, then release bounded preparation. Root separately reviews and releases its execution. Keep TF68 round6/80, deadline2026-10-13T23:47:31Z, transfers A06/A03/A21/A07=1/3/5/5of12. Cancelled hosted CI remains a merge blocker. No full packet status, review round or transfer count is changed here.
