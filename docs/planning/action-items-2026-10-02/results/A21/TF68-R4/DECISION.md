<!-- markdownlint-disable MD013 -->
# TF68-R4: review of the fixture clock's child-process transport

Status: A96 selected by root after displaying validation, options, detailed rubric, scores and selection in order on2026-10-06. No product, dependency, Git index/ref/configuration, planning or native-state changes. No aggregate test rerun. Canonical review identity: comment `4190960625`, thread `PRRT_kwDOSAZRhc6pTBjD`, head `f89d47d6780db47df29be4eb6d79cab35051f598`.

## 1. Validate the finding

The reviewer suggests writing `Invoke-AgentInstructionFixtureClock` into a temporary file and dot-sourcing it instead of embedding its text in the child `pwsh -Command` string. The asserted concern is command-line capacity and debugging/quoting fragility. The current line 1293 belongs to the private author-finalization fixture, not a production validator interface.

Immutable SelfTest identity: mode `100644`, blob `a976b7f224b4e9df0064493e3ec2c5514e9b8046`, SHA256 `2c7aaaeea5efd74c22ea395d93fc3bc1d508f78ae46e4ac1296a41aef905e67d`. The helper body is 6,577 characters. The wrapper is the exact AST-extracted assignment at lines 1279–1300. It starts the actual PowerShell executable directly; it does not use `cmd.exe`, a batch file, shell `-c`, or `-EncodedCommand`.

Primary limits matter. Windows `CreateProcessW` permits a complete command line of 32,767 characters including its terminating NUL. The often cited 8,191-character command-interpreter limit is not this launch path's limit. Linux limits each argument string to 32 pages and also limits the argument/environment total; the current qualified Linux image reports 4,096-byte pages, `ARG_MAX` 2,097,152, an 8-MiB stack limit and 811 environment bytes. [Microsoft process contract](https://learn.microsoft.com/en-us/windows/win32/api/processthreadsapi/nf-processthreadsapi-createprocessw), [Linux execve contract](https://man7.org/linux/man-pages/man2/execve.2.html).

Bounded native probes executed the **unchanged helper and unchanged wrapper** against a scratch checker with the same two clock anchors. They retained the real process transport, helper serialization, parameter-token allowlist, quoting, clock installation/readback/cleanup, catch behavior and native exit. They did not invoke the full author fixture or claim production-checker behavioral coverage from a synthetic checker.

| Observation | Windows 7.6.5 | Linux 7.6.3 |
| --- | ---: | ---: |
| Helper characters | 6,577 | 6,577 |
| Largest measured full Windows command / Linux command argument | 7,404 characters | 7,163 UTF-8 bytes |
| Applicable process/string ceiling, including NUL | 32,767 characters | 131,072 bytes |
| Remaining space after the NUL | 25,362 characters | 123,908 bytes |
| Probe parent exit | 0 | 0 |
| Positive child invocations | Four, all exit 0 | Four, all exit 0 |
| Missing-value parameter refusal | Expected exit 1, original message | Expected exit 1, original message |

The largest case deliberately includes all four permitted switches plus two real-width 40-character revisions; actual individual caller modes use subsets. The scratch path contains a space, apostrophe, dollar sign, backtick, semicolon and non-ASCII character. Literal argument data also contains quotes, brackets and a trailing backslash. All tested values round-trip exactly. Both initialization and local clock readbacks report the pinned date. A missing argument for the real `-InputRevision` parameter reports its original refusal, without being replaced by an initialization-clock error.

Actual caller inventory: the accepted/current/delayed calls at 1308 use two revisions and an optional finalization flag; the documented worktree case at 1530 uses the same finite transport; proposed-policy and invalid-mode controls at 1694–1750 use fixed switches/revisions; the local changed-worktree call at 1847 uses no arguments and requires the local clock; the invalid finalization modes at 1858 use fixed switches/revisions. Capacity fixtures use the helper in process and do not serialize this wrapper. The whitelist contains six fixed parameter tokens; all other values receive single-quoted PowerShell literals with apostrophes doubled. The helper text is current test code, not untrusted input.

Conclusion: the present length or quoting defect is **not reproduced**, and measured commands have substantial headroom. A file can reduce command size and give helper code a file identity, but that is a possible future maintenance improvement rather than a current correctness repair. The wrapper already catches exceptions and emits their messages; merely moving the helper to a file does not itself improve the returned stack diagnostics or remove the remaining argument quoting. The current ordinary/full fixture results supplied by root remain independent corroboration for their exact inputs; this analysis does not relabel the Copilot timeout as a pass or infer its cause.

Limits: measurements are for the pinned source, observed runtimes and controlled paths, not all possible future helper growth, all environments or every filesystem path. No Windows PowerShell 5.1 run is claimed. No near-limit failure was manufactured by padding production code. The current local Windows 5.1 restriction remains respected. [PowerShell Command/File semantics](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_pwsh?view=powershell-7.5).

**Separate observation reported to root:** a literal bracket-bearing checker directory makes the debugger breakpoints fail to fire. It also fails in a direct in-process helper call with no child or serialized command, and leaves zero breakpoints after cleanup. `Set-PSBreakpoint -Script` permits wildcards. This is distinct from the R4 transport allegation; dot-sourcing a helper file alone does not correct it. `direct-bracket-result.json` and the retained failed path probe establish the narrow observation. Root owns its classification and any additional decision/scope. [Debugger path contract](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/set-psbreakpoint?view=powershell-7.5).

## 2. Stakeholders and needs

The owner and PS/TF maintainers need factual review dispositions and no unnecessary divergence. Contributors and agent operators on Windows/Linux need reliable startup and useful failures. QA and independent reviewers need the actual child-process, accepted-policy and clock-refusal coverage retained; a shorter command must not silently substitute an in-process simulation. CI and recovery engineers need bounded, source-qualified files and reliable cleanup if more scratch files are introduced. Security engineers need unchanged production clock semantics, no executable untrusted content and preservation of primary failures. Documentation consumers need no unrelated guide/generated-output drift. Maintenance and schedule owners need evidence commensurate with this private test transport; low churn cannot justify retaining a real defect. Privacy, cloud administrators, accessibility and localization users have no changed data/deployment/UI surface in this proposal; non-ASCII literal transport was nevertheless checked. Dependency maintainers are unaffected because no runtime/package change is proposed.

## 3. Supported options, before scoring

A. **Keep the current transport and respond with measured evidence.** Refute the current length/quoting claim within the stated bounds. Retain the R1/C97 checked clock mechanism and existing regression controls. Reassess if actual helper/caller growth or a reproduced native failure changes those facts. This is not a blanket guarantee against all future length limits.

B. **Retain the transport and add a length guard or persistent transport regression.** A pre-launch guard can give an earlier message, and a focused serialization test can preserve current special-character behavior. A guard needs the actual native quoting/executable/encoding accounting, platform thresholds and path allowance; a raw command-string length check alone would be incomplete. It would introduce a new arbitrary boundary or testing surface despite large present headroom. Private measured evidence already answers the review without that permanent cost.

C. **Write the helper once into the existing private scratch area and dot-source it from a short `-Command`.** This is the reviewer's smaller change. It removes most helper bytes from the command and allows a helper file identity. It still builds/interprets the checker command arguments. It adds an executable file lifetime, read/write failure cases and cleanup obligations. It must write the exact current helper once, keep it outside the fixture's tracked snapshots, preserve the no-competing-writer assumption, and retain primary errors if file cleanup fails. It is a sound fallback if growth becomes material; it does not address the independent bracket path issue.

D. **Write a complete parameterized `.ps1` wrapper and launch `-File`.** This also moves invocation code out of the command and gives the wrapper a stable diagnostic name. However, exact flags/arrays need deliberate transport: `-File` does not directly support arbitrary array argument values, and a JSON/data file or finite named interface adds parsing/validation and cleanup. It can be designed correctly, but it replaces more of the proven caller than the review requires.

E. **Send the script through standard input.** This avoids argument capacity and executable scratch files, but PowerShell stdin uses statement-oriented parsing/exit rules. Preserving exact multiline here-strings, primary failures, output capture and termination needs new qualification. It is not a transparent improvement over the current string command.

F. **Use `-EncodedCommand`.** This makes transport quoting less visible but expands UTF-16LE command bytes into Base64, reducing Windows capacity headroom. It makes raw diagnostics harder to inspect and does not remove the command-line limit. It offers no advantage for the tested finite literals.

G. **Factor a new tracked helper/module for both caller contexts.** This gives reusable source identity and can use C or D transport. It expands repository setup/snapshot/install inputs and paired-file ownership for a single private helper already defined once. A duplicate helper copy would create drift and is excluded; a future second independent consumer could justify real factoring.

H. **Replace the child with an in-process runspace/invocation.** This eliminates native argument limits, but changes isolation, native status and actual child-caller semantics. It fails the retained test-fidelity constraint for this fixture. The existing capacity fixture's in-process use does not authorize replacing the author-finalization child.

I. **Remove the clock wrapper, delay/retry until dates agree, or delete affected caller tests.** This loses deterministic midnight coverage or the production caller checks established by R1/C97. It fails hard constraints. Reusing an existing scratch file for C and documenting its lifetime is part of C; combining a measured guard with C/D does not establish additional present benefit. Deferral of a hypothetical transport refactor is A, not deferral of a demonstrated defect. No exception to production clock or security policy is an acceptable option.

## 4. New finding-specific rubric

Scores are 0–10: 0 fails the need, 5 has material unresolved limitations, 10 has strong support for the present scoped consumer. Weighted totals are out of 100 and are engineering comparisons, not probabilities or test counts.

- **C, 30% — Present correctness:** addresses the demonstrated transport facts; avoids treating an unrelated debugger path failure as a serialization defect; preserves actual native argument meaning.
- **U, 20% — Debugging and legitimate usability:** useful bounded errors, ordinary contributor operation, no needless manual files or runtime exceptions; value of diagnostic identity is credited.
- **F, 25% — Test fidelity:** retains actual child/native outcomes and all R1/C97 initialization/local anchors, current/delayed/invalid/refusal behavior and error precedence.
- **L, 20% — Lifecycle reliability and recovery:** avoids new unqualified executable-file/pipe lifetime hazards, preserves cleanup and exact-source attribution, and permits bounded diagnosis.
- **M, 5% — Continuing maintenance:** scope, paired convergence, reviewer effort and complexity. This cannot override correctness or legitimate usability.

Hard constraints: no production validator clock override; no loss of the accepted/current/proposed/delayed/local/invalid-mode checks; no hiding a failed child or primary exception; no weaker source qualification; no unrelated guide, runtime, dependency or native-state changes. A high score cannot waive those constraints. For a current non-defect, speculative future flexibility is not scored as an executed improvement.

## 5. Scores before selection

| Option | C | U | F | L | M | Total | Principal limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A: retain and evidence-backed refutation | 10 | 8 | 10 | 10 | 10 | 96.0 | Future growth still requires re-evaluation |
| B: add guard/regression | 9 | 9 | 10 | 9 | 8 | 92.0 | New boundary/accounting or test surface without present pressure |
| C: temporary helper file | 9 | 9 | 9 | 8 | 8 | 87.5 | Adds file lifetime; remaining dynamic invocation unchanged |
| D: complete File wrapper | 9 | 10 | 8 | 8 | 7 | 86.5 | Larger argument/exit-interface change |
| E: stdin | 8 | 7 | 7 | 7 | 8 | 73.5 | Statement parsing and exit differences |
| F: EncodedCommand | 7 | 6 | 8 | 8 | 9 | 73.5 | Expands payload and obscures diagnostics |
| G: new tracked shared helper | 9 | 9 | 9 | 7 | 5 | 84.0 | New installed/tracked input and paired ownership |
| H: in-process replacement | 6 | 7 | 3 | 7 | 6 | 56.5 | Fails child-process fidelity constraint |
| I: remove/retry/delete coverage | 1 | 2 | 0 | 6 | 8 | 23.0 | Fails deterministic clock and coverage constraints |

The evidence builder computes the totals. A scores highest because current behavior is correct in the bounded transport probes, capacity headroom is substantial and no new lifecycle is needed. B offers future diagnostics but does not repair a measured present failure. C is a reasonable future design if new evidence makes command growth or file-level debugging material; it is not rejected as intrinsically unsafe. The score does not erase the separate bracket-path observation.

## 6. Selected solution

Select **A, 96.0** for TF68-R4. The following instructions use short direct controlled-English wording; no formal ASD-STE100 dictionary certification is claimed.

1. Keep the current child-process transport for TF68-R4.
2. Preserve the exact R1/C97 helper and fixture controls.
3. Bind the review response to head `f89d47d6780db47df29be4eb6d79cab35051f598` and the retained measurements.
4. State the Windows and Linux limits that apply to this launch path.
5. State the tested quoting and native-error results.
6. State that the probe used a synthetic checker with the exact current helper and caller.
7. Do not claim unlimited future capacity or full fixture coverage from this probe.
8. Keep the bracket-path observation separate. Obtain its owner disposition before any repair.
9. Re-evaluate this decision if a future source or supported-path change materially reduces headroom or reproduces a transport error.
10. Let root publish any review reply and manage native thread resolution.

## 7. Verification, limits and handoff

`probe.ps1` ran with the verified Windows PowerShell 7.6.5 executable and inside the retained Linux image (`sha256:8bdc7722fc55e19fd3df48d8fddf4568a75d8792cfc4ee105c8a8173559362f4`) with network disabled. Both parent probes exited 0; each contains four child exit-0 controls and one expected child exit-1 parameter refusal. `evidence.json` binds exact commands, raw source, helper/caller identity, native results, measured limits and all retained scratch artifacts. The direct bracket probe exited 0 after asserting the expected non-firing behavior and zero leaked breakpoints. Initial scratch path/control mistakes and their logs remain disclosed there; they are not counted as current transport failures.

A final immutable read confirmed the SelfTest bytes, HEAD, index and refs unchanged. No product implementation or additional aggregate run is required for recommended option A. All current CI/review/acceptance states remain as reported by root; this record grants no merge or publication authority. C97's no-production-clock-change and exact-source assumptions remain valid. No extra R4 reverse PS delta is indicated by this disposition; the existing common R1/R2 PS carryback obligations remain. Any separately selected bracket-path correction would need its own paired A21 scope.

Root reopened the exact probe code and sampled source/result hashes, recomputed all nine scores, and checked the primary references. A96 is selected. Next step: publish one evidence-backed reply and resolve the exact R4 thread after readback. TF68-R5 owns the separate bracket-path decision. No product edit has been prepared or performed for R4.
