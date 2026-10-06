<!-- markdownlint-disable MD013 -->
# Current PS235 author-case timing result

The one released control/timing pair passed. This is a diagnostic result for one current fixture, not product, CI or paired acceptance. H504cd7672ac9604ace765a4f451346f801f09ddd and accepted B98177628b7bc02c646724bfc8aa0fd73fed0cd24 remain unchanged.

Root checked all28 frozen packet files,78 current source files and1,914 dependency files; marker removal recovered exact H and the fixture adapter recovered the original current author function. Seven Python runtime files compiled without import, and seven PowerShell files parsed without execution. Authenticated native H/B/body and pinned offline image were verified before the separate release. [Readiness](ROOT-READINESS.json) records the scope and primary documentation references.

The complete run lasted76.174seconds within its600-second bound. Fresh control and timing children took11.629 and11.974seconds, respectively. The0.345-second observed difference includes instrumentation and run variance; it is not a stable overhead estimate. Both use shared debugger observers. The current fixture produced52 fresh parser calls,44 structural conversions,8 reuse hits and4 generic conversions. Counts were discovered, not copied from the older59/51/8 case.

| Timed caller phase | Seconds in this one timed child |
| --- | ---: |
| Native parser invocation | 3.313063 |
| Schema checks and construction combined | 3.506881 |
| Structural conversion, including cold initialization | 0.468503 |
| Snapshot hit/store copying | 0.437302 |
| Unsplit caller remainder | 0.287648 |
| Total measured caller | 8.013397 |

The3.960767seconds outside the caller remain unsplit. Inside schema checks, prose took1.914735seconds, lists0.753773seconds and tables0.592413seconds. These inclusive family intervals do not overlap; sibling intervals are subtracted once. Neither the generic calls nor identity/reflection within structural conversion are separately timed.

Root independently checked raw stdout equality, nonmarker stderr equality, the exact success oracle, count/native-exit equality, marker totals and nested bounds, and source/dependency after-guard hashes. The unchanged ownership policy accepted two already-exited adopted Git children with known zero statuses; no signal or live residue was accepted. Both selected children and final setup/driver cleanup passed, and root independently confirmed container absence. Recorded output totaled676,110bytes below2MiB. [Root verification](ROOT-RESULT-VERIFICATION.json) binds raw private artifacts; [pair judgment](pair-judgment.json) includes phase and call details.

No automatic repeat, larger profile, optimization, fourth service request or merge follows from this result. It does not establish the contribution of this case to the1,021-second hosted aggregate, the provider's setup-file choice or a reliable20-minute review margin. The author is preparing a finding-specific interpretation/proposal; [independent result checking](../independent-quality/current-author-diagnostic/REPORT.md) passed with scoped limits. CI hold,3/3 spent attempts, round1/original deadline and B99 execution freeze remain. The provider inquiry remains unsent pending owner authorization.
