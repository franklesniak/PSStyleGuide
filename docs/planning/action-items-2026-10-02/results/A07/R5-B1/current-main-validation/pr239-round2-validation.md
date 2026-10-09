<!-- markdownlint-disable MD013 -->
# PR239 round 2 repair validation

This record reports completed local validation for FQ33–FQ38. It does not grant remote review, CI, merge or paired-repository acceptance. All eleven native hooks passed. The surrounding controller failed its empty-TEMP check; a separate [exact-run retention acceptance](pr239-round2-native-hooks-retention.json) now records the verified two-file disposition while preserving that failure.

## Candidate and environments

The candidate is commit `2b5514c7a0c35b55d002935dcd771a72be1b1dcf`, tree `11559d9affe64b6549ce54cd1072e41e8190f575`, on `codex/r5-toolchain-foundation`. Its parent is the prior published head `c1ef946fe4585836f27a0a4480bd986899d7c316`. The final test driver has SHA256 `2636b614af82374e5ca0c9836cf5037afcfb9a3ce25650f1fc6bee41793e3c08`. The [source freeze](pr239-round2-source-freeze-v5.json) records the ten changed files. The admitted 78-file source catalog is `b3791c58e486f1740ea3539fc46d11ea28fdc455feca6a393ab40760eee91d88`.

The maintained Windows transport used Node24.18.1, PowerShell7.6.5, .NET10.0.11, an NTFS private directory and the recorded Job Object limits. The maintained Linux transport used the qualified container image `sha256:8bdc7722fc55e19fd3df48d8fddf4568a75d8792cfc4ee105c8a8173559362f4` and a private ext4 namespace. Each runtime receipt records its actual manifest, source, native session and retained raw evidence. These receipts do not claim that the tests ran directly in an unrestricted shell.

## Completed checks

| Check | Actual result | Evidence and scope |
| --- | --- | --- |
| Affected Linux registrations | 111 accepted; no failures, cancellations, skips or todos in the accepted groups | [108 unchanged registrations](pr239-round2-linux-scoped-reuse.json), plus [3 fresh path registrations](pr239-round2-path-encoding-runtime.json). Reused groups retain their actual earlier source identities. |
| Full seven-file Windows aggregate | 786 registrations:352 passed,434 platform skips,0 failures/cancellations/todos | [Fresh aggregate](pr239-round2-windows-aggregate-runtime.json), native session22505/terminal736757, root acceptance183cc4. Skips are not credited as executed tests. |
| Whole JavaScript driver | Node syntax check passed | Root806446, receipt SHA256 `dabad77fec3f27ef3a665122adc0243e1b88cffa7ada69c210df790fc7ea4d8f`. |
| Six changed generated PowerShell forms | 0 parser errors;27 analyzer advisories equal the previously dispositioned finding multisets | Native32ce35; current body hashes and scoped attribution were accepted by root67ee99. No parser credit from old changed bodies was reused. |
| Source integrity | All78 raw files and staged blobs/modes matched; exactly10 staged files; dependency/runtime and Git guards unchanged | Root68bc95 and Windows readback6280c8. The accepted Linux groups and Windows aggregate left no active or forcibly terminated task child, container or private temporary directory. The separate hook retention is recorded below. |
| Independent source review | Passed for unchanged source plus the finite 31-byte serializer correction | Q2 report `8e8620565376eb8cb1b54492fa25f6c8d8a6272ab8d4a1b9b5879aee0c2845ab`; Q3 report `2821402e7cc57fcee3b52bfa6649f1124b2bbc2b264704d6308536422c1208d6`. Runtime closure remains a separate gate. |

## Finding-specific runtime results

| Finding | Executed proof |
| --- | --- |
| FQ33 | The [20-test Linux lint group](pr239-round2-lint-runtime.json) passed, including the complete-value predicate and real-launcher LF, CRLF, prefix, suffix, range and numeric rejection cases. The complete-value predicate also passed in the Windows aggregate. |
| FQ34 | All three actual helpers passed their fresh Windows raw/normalized boundary registration and fresh Linux ordinary/double-slash registration. Unicode input equality, normalized result equality, lexical/provider boundary, causal mutants and bounds remain enforced. The [failed first Windows aggregate](pr239-round2-windows-aggregate-failed-a1.json) remains failed; the repaired run supplies the acceptance. |
| FQ35 | The [five-test record/output group](pr239-round2-records-output-runtime.json) passed, including real off/off/on/off setup, the omission mutant, preserved prior records on failed setup and actual record construction/newline refusal. Windows passed the record-construction boundary; it does not prove a whole Windows recovery setup. |
| FQ36 | The same [record/output group](pr239-round2-records-output-runtime.json) passed the whole-initializer dependency switch combinations, two failure modes and route-removal control. These whole-initializer cases executed on Linux and were platform-skipped on Windows. |
| FQ37 | The [four Linux caller registrations](pr239-round2-consumers-runtime.json) and record/output runner controls passed. The Windows aggregate passed the source-derived runner model and workflow-policy registration. The model is not a native GitHub runner; live runner behavior remains a published-input CI gate. |
| FQ38 | The [eleven-test mutation group](pr239-round2-mutations-runtime.json) passed, including the real `preflight-order` baseline and deliberate mutation. The corrected constructor did not replace the runtime witness. |

## Remaining gates

Copilot review `5468500637`, authenticated on head `c1ef946` at `2026-10-09T09:52:10Z`, repeats the general security-coverage concern about native calls, archives, credentials and Windows access controls. It gives no additional concrete defect beyond FQ33. This maps to the [existing coverage disposition](https://github.com/franklesniak/PSStyleGuide/pull/239#issuecomment-6078368510), with the changed inputs covered by the later complete FQ33–FQ38 source reviews and finite Q2/Q3 addenda. The [independent final runtime addendum](pr239-round2-final-local-quality.json) passed, including the exact-run hook retention disposition; root read all of its report and evidence in16c56c. These are automated reviews; no human review is claimed. The PR body will carry the current scope and remaining gates; no duplicate decision-mirror comment is needed.

The eleven-hook Windows run, session6435, finished with terminal `cdf533`. All eleven configured hooks passed with native/worker exit0 and no skips. The controller exited1 for `Fixture temporary residue`; both final Job observations have 38,910 total processes,0 active and0 terminated. Exactly two ordinary69-byte files remained. The [failed-run record](pr239-round2-windows-precommit-failed-a1.json) preserves the raw failure and namespace. The [canonical FQ32 decision](../FQ32-POWERSHELL-POLICY-PROBE-RESIDUE.md) records fresh applicability of existing option K. The [fresh verification](round2-policy-probe-retention-verification.json), actual session38945/terminalcaba21 exit0, confirmed the exact pair and all original inputs and bounds. The distinct acceptance linked above covers native hook execution with both files retained. No generic cleanup exemption or strict-controller pass is claimed. The [normal commit](pr239-round2-normal-commit.json), actual session96239/terminal0c756a exit0, passed staged, whole-repository and nested Markdown Husky checks; its tree equals the accepted index. Publication, new exact-input Copilot and remote Codex reviews, passing hosted CI, normal merge, landed checks and the Terraform counterpart/reverse comparison remain required.

PR239 remains round2/80 with its original deadline `2026-10-16T22:53:27.970214Z`; A07 remains transfer9/12. The planning branch must never merge to main.
