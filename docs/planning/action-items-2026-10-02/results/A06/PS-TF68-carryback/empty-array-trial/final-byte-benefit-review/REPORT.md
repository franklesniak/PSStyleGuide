# Final-byte correctness and local ABBA benefit review

**Scoped pass; no material findings.** Independent read-only inspection supports final-byte focused correctness and the selected local benefit threshold. No tests, payloads, parsers, imports, Git or native operations were run. The earlier focused review is reused only for its exact-H differential, reuse/converter coverage and observer qualification.

Final validator `658fa71b68fc47657bbc3147e31a8c805cdf0a34c0653e765bc14ec9971f144c` and SelfTest `f2fbcb89dd737ee4be61dfd26b60297745859189e4e0153b477018f831280ce8` match the archived finalization and benefit inputs. The actual diff from reviewed d40/952 adds five literal null-array cases across the six fields, makes the help durable and updates UTC metadata to October 7. Production guards and other executable paths are unchanged. These assertions now preserve observed exact-H behavior instead of relying on an external null-characterization note.

On each platform, independently decoded 109 current events and 125 addressed blobs match the previously reviewed baseline cases in raw parser/decoder data, complete typed output and refusals. The 30 null cases prove their exact one-field mutation and emit no partial result. Counts are 109 real parser and 109 structural decoder calls; helper-restoration receipts pass. Windows 7.6.5 and Linux 7.6.3 results agree. Fresh exact-file ParseFile and PSScriptAnalyzer 1.24.0 receipts have no syntax errors or Warning/Error diagnostics on either platform. Native exits, transport cleanup and saved input guards pass. Old reuse/converter success is reused evidence, not a newly repeated or stitched full-suite pass.

The benefit dispatcher uses exact plain A/B validator bytes without source timing edits. Its unchanged breakpoint observer records counts/exits; all eight catalog anchors match the actual source. One actual UTC capture, fresh private revisions `90dd742ee3d765807f7b0c0d12bc5ae90057a4d3` / `16963713368cfd7b5e3ab5cc286053b04a1f8e57`, argv, cwd and fixture remain the same for four distinct serial children. The clock is `2026-10-07T00:53:55.5806262+00:00`; it is not a historical replay. Each child substitutes only the live private validator and restores it afterward. The final SelfTest is bound but is not executed in this benefit case.

| Child | Whole-child seconds |
| --- | ---: |
| A1 | 8.967582003 |
| B1 | 7.751853873 |
| B2 | 7.591238315 |
| A2 | 8.620615336 |

Independent arithmetic gives matched reductions **1.215728130 / 1.029377021 seconds**, and median reduction **1.122552575 seconds / 12.76483944%**. Both opposite-order pairs improve and exceed the selected 0.5-second/5% threshold. Within-A spread is 0.347 seconds, within-B 0.161 seconds, and gain spread 0.186 seconds: no contradictory or wide pair is visible. Root recorded no other task-owned payload at release. This supports the root's one-case consistency judgment; it cannot rule out unmeasured external scheduling effects or establish stable performance.

Raw stream hashes, exact success oracle/stdout, empty nonmarker stderr, 52 parser / 44 structural / 8 reuse / 4 generic counts and 52 zero native exits agree in every child (644 total events). The monotonic whole-child metric includes launch, interpreter/bootstrap, observers, first compilation, stream recording and receipt overhead; owned-process cleanup is outside that metric but inside the overall bound. It is not an observer-free microbenchmark.

All four child cleanup receipts are empty. The parent collected exactly two already-exited, owned Git zombies with matching PID/start identities and zero wait statuses; no signals or unknown residue were accepted. Terminal cleanup and saved container absence pass. Host/fixture after-identity hashes recover their full before records. Host state correctly says collected/provisional numerical benefit. Later planning-ref updates do not retroactively alter these completed-run bindings.

The candidate may remain provisional for the normal next gates. Net full-suite cost of the permanent 109-call test, full final-input validation, committed admission, CI/service recovery and paired acceptance remain unproven. This review authorizes no resampling, commit, publication, review request or merge. Cancelled-CI hold, recovery cap 3/3, round 1 deadline `2026-10-14T20:09:39.767792Z`, transfer counters 2/4/6/6 and B99 freeze remain unchanged.
