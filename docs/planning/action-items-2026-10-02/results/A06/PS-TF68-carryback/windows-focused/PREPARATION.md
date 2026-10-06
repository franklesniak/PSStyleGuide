<!-- markdownlint-disable MD013 -->
# Preparation provenance and execution boundary

**Preparation only; no Windows packet command has executed.** The final executable is `runner.py`, consuming the explicit command array in `manifest.json`. Root owns release. Source/index/ref/dependency guards are frozen while the separate Linux final run proceeds.

## Prior Windows hosting evidence

There is **no qualified prior Windows Job Object / pre-start-gated-worker runner** in the A06 evidence inspected here. This packet does not claim one.

The retained predecessor launchers are:

- `C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A06-TF-peer-20261005/writer/TF68-round6-timeout-remedy/implementation/launch-windows.py`: binds qualified PowerShell/Node, uses an explicit Popen child, timeout180s, taskkill `/PID <own-child> /T /F` on timeout, then product/Git guards.
- `C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A06-TF-peer-20261005/writer/TF68-R11-S1-R13-implementation/run-windows.py`: runs its prepared private Windows fixture via explicit native tools with subprocess.run(timeout600), retains exits and source hashes. Its setup driver creates/removes a file-root-preserving helper only in that fixture.
- `C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A06-TF-peer-20261005/writer/TF68-R5/run-windows-next-day.py`: qualified actual next-day author/capacity caller, subprocess.run(timeout3600), preserved complete result and source guards. The historical run passed in31m18s and is reused only for its actual source/runtime/behavior scope.

Those records support tool, source-control-body and private-fixture reuse. They do not establish Windows ownership of detached descendants after a parent exits. Linux D93 wait/subreaper controls remain Linux evidence.

## Newly prepared hosting mechanics

The new runner adds one Python worker per command, with an stdin gate. Its only pre-gate activity reads the frozen command specification. The parent creates a Windows Job Object with `JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE`, assigns the waiting worker, then sends the gate byte. Tested commands and all normally inherited descendants therefore start within the owned job. Job-assignment failure refuses the command. No breakaway flag is enabled.

After terminal status, the parent reads job accounting. Unexpected live descendants make the group fail and receive owned-job termination; cleanup must reach zero active processes. Timeout/error also terminates that job, waits for its worker and records the original native failure separately from cleanup errors. Closing the job supplies the final kill-on-close boundary. A worker that never received successful assignment is the only direct PID eligible for fallback kill; it cannot have started the tested command. No unrelated-process inventory, broad kill or outer recursive deletion is used.

These mechanics are source-reviewed preparation, not previously executed qualification. The source uses the standard Windows Job APIs via ctypes with explicit signatures and structures. Python source syntax was compiled in memory; no Job API or packet test ran. Root can review this concrete runner and authorize the one actual focused run without inventing a new product decision or separate harness-test cycle. Any real runner failure remains a failure requiring inspection; no success is precredited.

## Driver changes

C88 persistent, S1 setup and R2 focus drivers are exact retained copies. R8 is the retained contract body combined with one parser/PSSA pass across the three changed PowerShell files; only source/output bindings and the actual PS baseline negative changed. The actual PS blank-line helper and four selected CI helper tests run from the frozen private source copy. Exact original/adapted hashes are in the manifest.

PSSA's existing hydrated OneDrive module is copied byte-for-byte into nonsynchronized packet storage (51files), not installed or altered. The new wrapper selects explicit Python3.12, PowerShell7.6.5, Node24.18.1/npm11.16.0 and installed native Git; no default host Python is used as a product runtime.

Root agreed to omit the redundant Windows31-minute author/capacity replay and allocate actual destination author/P1/capacity behavior to its required Linux full SelfTest. The Windows packet claims only its six listed focused groups. All remaining aggregate, endpoint, platform, review and native acceptance gates remain root-owned.
