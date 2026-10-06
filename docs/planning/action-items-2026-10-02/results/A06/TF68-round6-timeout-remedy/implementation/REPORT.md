<!-- markdownlint-disable MD013 -->
# C88.5 conversion repair: focused validation

The selected two-file repair is implemented and its focused checks pass. It is not full acceptance. The actual cold caller comparison, full final validation, new-input reviews and hosted CI remain pending. TF68 remains unmerged while its current dynamic setup run is cancelled.

## Exact candidate

- Worktree: C:/Users/flesniak/AppData/Local/Temp/TerraformStyleGuide-A02-peer-docs-20261003; branch codex/a06-generator-convergence.
- HEAD ed9eea201cfd70a88a6b982b29904e2f6206a692; accepted base e21b74fe0b56551008f78f9f2946cd2a0f9c19ce. Only the two files below are uncommitted; index unchanged.
- Candidate tree e71b81232ba0f197acf5f126e4b14f1e90ee7da2 was reconstructed in memory from actual Git entries and changed bytes; no Git objects or index were written for verification.
- Test-AgentInstructions.ps1 SHA256 e2a7767f70ffc3d38e9225d7ed6a723d9329135e3b104b3cec9654122ae7d35c.
- Test-AgentInstructions.SelfTest.ps1 SHA256 dd2aaf7f23e77f00cf264ba1b4b130d34006cec9958f94e24570f2982231415e.

The [selected C88.5 decision](../repair-proposal/REPORT.md) is unchanged. Only the Markdown caller opts into the embedded stateless converter. Other callers retain the original path. Special property names use the original full-root conversion. Root verified that the original recursive converter remains byte-identical and read the actual complete two-file diff. No parser/schema/freshness/reuse/deep-copy/dependency/clock policy was removed.

## Results and evidence

[Root verification](ROOT-FOCUSED-VERIFICATION.json) binds52 artifact hashes, the80-file candidate catalog, four successful Windows runs and two Linux packets. It includes the complete command results, source identities and evidence locations. Frozen prechange files match the actual HEAD blobs.

| Check | Windows7.6.5 | Linux7.6.3 | Meaning |
| --- | --- | --- | --- |
| Persistent strict conversion and actual reuse tests | Passed on final hashes | Passed on final hashes | Types, names/order, arrays/nulls, numeric/string fidelity, byte/depth bounds, rejected malformed data; fresh parser, ownership and mutation controls |
| External baseline/caller/path controls | 12 checks passed | 12 checks passed | Actual frozen original versus candidate; package/Node/TOML callers do not initialize helper; lazy Type identity, native/legacy path and error propagation |
| Seven deliberately broken variants | All detected | All detected | Always-legacy path, duplicate/empty names, non-finite numbers, singleton arrays, PSTypeName and timestamp coercion |
| Initialization/type failure controls | 2 passed | 2 passed | Compiler failure cannot emit success; wrong-identity loaded type rejected while generic path remains usable |
| Whole-file parser and PSScriptAnalyzer1.24.0 | Zero errors/diagnostics on both final files | Zero errors/diagnostics on both final files | Actual loaded module/assembly identity retained |

Each successful Windows run retained matching complete source/Git guards. Each Linux packet retained80 source/1,914 dependency guards. The Linux analysis-only packet additionally bound51 installed analyzer files and the loaded PSv7 assembly SHA256 a816f622b3bc1b3000afd51be8c40358050a544675181c55d0e14fdfd1ce470c. All selected child groups were empty. Root verified both named containers were absent after completion.

The first Linux packet remains recorded as failed: all three behavioral commands passed, then analysis could not locate PSScriptAnalyzer in its isolated environment. A separate analysis-only run transported the existing qualified1.24.0 distribution read-only, with no download/install/image/product-dependency change, and passed. The behavioral commands were not repeated.

Scratch preparation corrections: one AST-literal lookup and one uncompileable mutant were corrected; neither was credited as a product failure or a detected mutant. Root corrected a verifier typo and distinguished host-only manifest payloads before its final verification. No product repair or broad rerun followed these tooling corrections.

PowerShell7.0 [Add-Type source](https://raw.githubusercontent.com/PowerShell/PowerShell/v7.0.0/src/Microsoft.PowerShell.Commands.Utility/commands/utility/AddType.cs) shows that default compiler references come from the installed runtime reference folder and actual PowerShell assembly. The selected code adds no explicit current-directory reference search or newer runtime switch. This is source-level compatibility evidence; the actual executed versions are7.6.5 and7.6.3. Do not claim every7.x version was executed.

## Recovery and next action

The original a06 worker stopped because its model service reported capacity exhaustion. At recovery, root found the analysis-only run already complete; no task-owned local test/container remained. Preserve all completed results. A bounded replacement worker prepares only the unexecuted cold comparison packet.

Inspect that packet before one root-authorized execution. Include first compilation, bootstrap, all fresh native parser calls and whole-child time. Require output/oracle equality and unchanged source/dependency/Git guards. A positive local timing result is not hosted service acceptance. Do not merge with failed/cancelled CI. Round6/80, original deadline2026-10-13T23:47:31Z and A06/A03/A21/A07 transfers1/3/5/5of12 remain unchanged.

The subsequent [cold comparison](cold-comparison/REPORT.md) produced verified equal-output timing improvement, but its complete packet failed on parent adopted-descendant cleanup. That failure is under read-only investigation; no broad rerun is released.
