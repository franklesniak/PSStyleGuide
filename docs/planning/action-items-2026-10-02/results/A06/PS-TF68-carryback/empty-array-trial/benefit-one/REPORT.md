<!-- markdownlint-disable MD013 -->
# D94.1 measured local benefit

The selected single ABBA comparison passed its scoped benefit gate on 2026-10-07. The exact final candidate remains provisional until normal final validation and net full-suite cost assessment finish. It is not committed or accepted, and the failed-CI merge hold remains.

| Matched pair | Original seconds | Candidate seconds | Saving seconds | Saving percent |
| --- | ---: | ---: | ---: | ---: |
| A1 / B1 | 8.967582 | 7.751854 | 1.215728 | 13.556922 |
| A2 / B2 | 8.620615 | 7.591238 | 1.029377 | 11.940876 |
| Median | 8.794099 | 7.671546 | 1.122553 | 12.764839 |

Both opposite-order pairs independently exceed the selected 5% and 0.5-second median thresholds. The 0.186-second difference between pair gains and the 0.347/0.161-second within-version spreads show no wide contradictory pair. No task-owned parallel test ran. This supports one local case; two observations per version do not establish a stable benchmark or exclude all external interference.

Root independently checked raw stdout/nonmarker stderr, identical actual argv/cwd/clock/private revisions, counts52 parser/44 structural/8 reuse/4 generic, and52 zero native exits in each of four fresh processes. Whole-child time includes startup and cold native-helper compilation. The plain source bytes contain no profiling markers. The permanent109-case SelfTest is bound but not executed by this measurement; its cost still counts in the later net-suite gate.

The whole operation took80.516seconds and produced1,009,988bytes within600seconds/2MiB. Every child had empty cleanup; the parent reaped only two exactly identified already-exited Git children with zero statuses. Terminal ownership is empty, the container is absent, and host/fixture/source/dependency/runtime/Git identities are unchanged. Session41852 exited0. No resampling is authorized.

[Root verification](ROOT-RESULT.json), [raw numerical judgment](abba-judgment.json), and [frozen preparation](PREPARATION.md) retain exact identities and original evidence paths. An independent final-byte/benefit reader is active. Final validation/net-suite preparation is separate; no fourth same-input review request, CI retry, product commit, merge or transfer occurred.
