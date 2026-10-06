# TF68-R5 implementation

Status: frozen focused implementation, ready for root aggregate. This is not final PR acceptance. Root selected B 97.5 after the complete ordered decision process; the proposal and its original evidence remain unchanged.

## Product scope

Only `.github/workflows/Test-AgentInstructions.SelfTest.ps1` changed over TF `f89d47d6780db47df29be4eb6d79cab35051f598`. The helper computes one documented wildcard-escaped breakpoint path and uses it for both existing `Set-PSBreakpoint -Script` arguments. The literal `CheckerPath` still supplies the source read and actual invocation. Exact anchor admission, both actions, LocalOnly, readback receipts, primary-error preservation and scoped cleanup are unchanged.

The existing persistent control now uses `clock-probe[fixture].ps1` with matching decoy `clock-probef.ps1`. It requires exactly two new breakpoints, both on the actual probe, before execution. The existing difference 0/1, missing/duplicate/inactive anchor, primary error and uninstrumented post-cleanup checks remain. Existing private-directory cleanup owns the decoy.

Postimage mode 100644, blob `d0a6b62013d1772388aa7d20773d2db592bf91dc`, SHA256 `0f0abc0b9f84b6f5863a823e4c0f277cc479b207cabc240c8a62e1a92dc6f64e`, 242137 bytes. The diff has 11 insertions and 3 deletions. Current Oct 6 function metadata remains truthful: the clock helper is new in this PR and author fixture 1.1 is the in-progress update over accepted-B 1.0; no artificial same-day publication revision was added.

## Executed focused checks

| Check | Windows 7.6.5 | Linux 7.6.3 |
| --- | --- | --- |
| Actual helper path matrix, ordinary and LocalOnly | 10/10 | 14/14 |
| Original helper negative control | 4 expected failures /10 | 8 expected failures /14 |
| Exact changed persistent block; original helper rejected | exit 0 | exit 0 |
| R4 rebound actual helper/caller transport | parent 0; four positive children 0, intended parameter refusal 1 | same |
| Actual next-day author and prior-day capacity fixture | exit 0 | exit 0 |
| Parser/PSScriptAnalyzer 1.24.0 | zero errors/warnings | parser exercised by focused drivers |

Every repaired matrix row asserts exact breakpoint target/count and zero remaining breakpoints/clock variables. Linux adds literal `*` and `?` with decoys on the mounted scratch filesystem; this does not claim hosted or native-ext4 acceptance. The original failure controls remain distinct from successful commands.

R4 transport remains unchanged. New helper body is 6676 characters. Measured maximum Windows full command is 7520 characters, leaving 25246 characters below the 32767 limit including NUL. Linux maximum command payload is 7272 UTF8 bytes, leaving 123799 bytes below the 32-page per-argument bound with measured 4096-byte pages including NUL. Literal round trips and early primary refusal pass.

Complete executable/argument arrays, native exits, source/driver hashes and outputs are in `implementation-evidence.json`, `actual-windows/native-results.json`, `actual-linux/native-results.json`, `windows-next-day-focus.json` and root's `R5-linux-focused` receipts. Actual focus invokes `actual-focus-next-day.ps1 -RepositoryRootPath <qualified repository>`. It retains actual source-file AST identity, changes exactly one checked private author timestamp expression in memory to tomorrow, and executes all real author consumers followed by prior-day capacity and cleanup. No production checker bytes or clock interface change. Linux uses the unchanged pinned offline image and R2-qualified dependency closure.

## Preserved failed attempt and boundaries

The initial reused R1 driver pinned the author fixture to Oct 5 and exited 1 because current committed scripts-README and dependency-maintenance metadata legitimately records Oct 6. The exact validator correctly rejected dates later than its controlled clock. Root and independent reader confirmed the scratch date-binding mismatch. The failed log, receipt and driver are retained. Root authorized one next-day author run, whose derived baseline/prior/current/future dates and real Git commit dates are coherent. Product bytes did not change between attempts. Capacity remains prior-day and persistent probes remain fixed 2000-date controls.

Final source/index/refs guards passed, and all 1914 installed dependency files match the unchanged R2 catalog. No dependency archive or runtime update is needed. No Windows 5.1 bypass, aggregate, shared Git mutation, native publication or review action was performed by this worker. Root still owns aggregate, current audit, metadata endpoints, commit, current reviews/CI and acceptance. After TF acceptance, common PS A21 carryback must include R1 and R5 while preserving the sole historical T1/P1 provenance fixture-path exception.
