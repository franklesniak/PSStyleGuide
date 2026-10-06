<!-- markdownlint-disable MD013 -->
# D93 cleanup observation result

The one released cleanup observation completed on 2026-10-06,17:08:46–17:09:32UTC. Root verified15 phase receipts,4 real ownership controls, all80 source files,1,914 dependency guards, unchanged Git identities and container removal. No comparison child or product test ran. The [root verification](ROOT-RESULT-VERIFICATION.json) binds the raw evidence.

The actual fixture prefix created one adopted Git process after each ordinary B/H commit. Both were already in state `Z` before the selected-call stop, through the original fixture cleanup and at parent return. Exact waits collected successful exit0 for each, without a signal. There were no remaining processes. The existing any-nonempty-before rule would fail this successful cleanup.

Git reports2.55.0; its binary hash is in the verification. The fixture has no queried maintenance/gc overrides. Each commit trace invokes `git maintenance run --auto --quiet --detach` and records the maintenance detach region and successful exits. The phase/trace evidence supports automatic detached maintenance as the source in this reproduction. The short process samples did not observe the fork itself. A trace session ID alone does not identify the forked PID; matching-version public source does not prove the installed binary's build provenance.

The direct-exit, adopted-exit, escaped-live and primary-failure-with-live-child controls all passed. Successful exited children were reaped without signals. Live escaped children received identity-checked termination and were reaped. The primary failure sentinel survived cleanup. Each control and the outer owner ended empty.

The [earlier cold comparison](../cold-comparison/REPORT.md) remains overall failed. Its two process records omit state and command; this result cannot fill those historical gaps. Its verified functional/timing evidence remains valid within its stated limits. Independent source quality remains conditional; no final aggregate or hosted CI acceptance is claimed.

## Private runner correction

1. Failure: the private runner treated every adopted child as a live leak.
2. Cause: it made that judgment before collecting successful exited children; this is a scratch-runner defect, with no product or guide change.
3. Fix: collect successful owned exits first; fail and clean safely for live, failed, signaled, unknown or unrecoverable children; preserve any primary failure.
4. Test: retain these4 executed controls; bind the corrected classification and source guards in one new final validation packet. Do not repeat the cold pair or this observation.
5. Evidence: [verification](ROOT-RESULT-VERIFICATION.json); [original D93 decision](../cold-comparison/cleanup-investigation/REPORT.md). Final packet preparation is released; execution remains subject to root input checks.

## References

The Linux [wait documentation](https://man7.org/linux/man-pages/man2/wait.2.html) explains collection of terminated children and exit status. The [subreaper documentation](https://man7.org/linux/man-pages/man2/PR_SET_CHILD_SUBREAPER.2const.html) explains adoption. Git [maintenance source](https://raw.githubusercontent.com/git/git/v2.55.0/builtin/gc.c) calls daemonize for detached work; its [daemonize implementation](https://raw.githubusercontent.com/git/git/v2.55.0/setup.c) forks and creates a session. These sources support interpretation; the saved runtime evidence establishes this run's observations.
