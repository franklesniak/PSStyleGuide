# Prepared runtime diagnostic â€” not launched

The existing final aggregate ran from06:56:04.501756 to07:18:35.600072 UTC (1351.10 seconds). Its preceding seven-suite Node run took219.47 seconds and passed600 tests. Hosted service37430212759 passed10 hooks by07:33:11.6199615, then reached its20-minute ceiling while the instruction contract/mutation hook was active. These facts locate the expensive hook but do not identify a function or prove a product defect.

## Proposed single measurement

Run the actual hook entry once in the existing qualified offline Linux image:

`pwsh -NoLogo -NoProfile -NonInteractive -File .github/workflows/Test-AgentInstructions.ps1 -SelfTest -RequireStagedInputMatch`

No Node suite, generator, pre-commit aggregate, installation, network request or hosted action is included. The source is H5ec4bdc/tree441d84c with accepted origin/main e21, in a separate temporary Git repository inside the container. The original80 source files and both dependency roots (1914 qualified regular files) are checked before any private copy changes. The prepared manifest has execution_authorized=false. Launch requires root release, a separately saved authorized manifest and its exact approved hash.

## Timing instrumentation

Only the disposable copies of Test-AgentInstructions.ps1 and Test-AgentInstructions.SelfTest.ps1 receive added statements. instrument.ps1 parses the exact source with PowerShell ASTs and inserts begin/end Console.Error markers at complete statement boundaries. The main SelfTest block has374 timed statements strictly inside its SelfTest block (no unconditional outer marker). The extracted self-test has135, including major top-level groups and the actual FileInquiry, Snapshot, InvokeCheck and Check scriptblock caller statements. The latter identify repeated authoritative file probes and real checker process calls inside the author-finalization group. Each marker records process ID, monotonic Stopwatch timestamp/frequency, original file/line, AST statement kind and begin/end. No source text is replaced. Removing the marked insertions reconstructs each exact original string; raw-byte equality is rechecked in Linux before execution. Both instrumented files parse with0 errors in preparation. Full insertion catalog and instrumented raw hashes are in prepared-instrumentation/instrumentation.json.

Markers introduce no function or scriptblock wrapper, no extra PowerShell scope, no exception catch, no return-value transformation and no native command. They do not modify arguments, assertions, child clock instrumentation, timeouts or LASTEXITCODE. No script mutation is accepted as product code. A terminating statement can have a begin without an end; the original throw and exit behavior remain active and such intervals will be reported as incomplete, not successes. Console writes add measurement overhead, so measured intervals are diagnostic approximations, not performance acceptance or a guaranteed hosted duration. The exact statements still run sequentially.

The two diagnostic copies are staged only in the disposable repository so RequireStagedInputMatch remains meaningful. The resulting private diagnostic tree is recorded separately and cannot be confused with the accepted/published source tree. After preparation, the runner records an identity baseline covering every diagnostic source byte, every dependency byte, index, refs, origin and the pinned Husky executable-bit adaptation inherited from the qualified runner. Normal execution and failure both produce final equality guards. All original source bytes remain in the input archive and history bundle.

## Limits and cleanup

The instruction process is limited to2550 seconds; its process group gets bounded TERM then KILL cleanup on timeout. The host container command is limited to2700 seconds (45minutes). The container has a unique name and manifest-hash label. Before cleanup, the host verifies exact container ID, image and label and stops only that owned container. No Docker restart or unrelated container action is included. Host finally preserves terminal status and current-source guard, even on timeout/failure. Logs are written continuously to the dedicated output directory so root can inspect progress without another run.

The launcher is derived from the reviewed round4 runner: common.py adds explicit --no-replace-objects; inside.py replaces the test block with the single timed instruction entry and inserts only the two prepared scratch sources; launch.py accepts only the diagnostic role and preserves source/dependency/Git guards. Before and after checks pin host H, accepted B, origin, complete80-file catalog, current index, all refs, index/config bytes and both installed dependency trees. All host Git operations are read-only except writing a history bundle into this scratch directory. No host source/index/config/ref mutation occurs.

## Review and launch boundary

Root should inspect instrument.ps1, insertion catalog, inside.py and launch.py. No diagnostic run has started. After root releases this exact method, save manifest.authorized.json with only execution_authorized=true changed, bind its hash, and execute `launch.py --execute-root-approved --manifest <authorized path> --approved-manifest-sha256 <hash>`. Keep the original prepared manifest. Any new instrumentation concern must be resolved before launch; no retry or second measurement is implied.

After the one run, parse complete event pairs to report inclusive group time, per-caller count/total/max and unmatched markers. Compare the real command's native result and immutable guards. Attribute a bottleneck only where that evidence supports it. If a correctness-preserving repair is indicated, prepare its own options, stakeholder rubric, score table and selected proposal before any product edit.

Preparation correction before launch: the outer if(SelfTest) envelope was excluded so normal checker children do not emit diagnostic markers. Only actual SelfTest execution emits the inserted main-script timing. The prior proposed375 count is superseded by374; no diagnostic ran with the first preparation.
