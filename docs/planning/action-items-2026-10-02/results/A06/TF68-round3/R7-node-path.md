<!-- markdownlint-disable MD013 -->
# TF68 R7 — existence of the selected Node executable

## 1. Validation and affected users

This is distinct from PS234 R9's relative-working-directory concern. Current lines 590–595 select exactly the first `Application` returned by `Get-Command -All -TotalCount 1`; the selected Source becomes ProcessStartInfo.FileName. A Process.Start false result uses a fixed start diagnostic. A thrown native exception propagates through disposal; no fallback selects another Node. Accepted TF baseline had a File.Exists guard with the fixed `state-recovery: the Node executable could not be resolved` text, so the historical check's removal is real.

The private native probe resolved the first of two scratch node.exe paths, then removed that selected path. Process.Start threw Win32Exception naming the selected path and the OS missing-file cause while the second path still existed. A separate existing invalid executable passed File.Exists but failed Process.Start with the specific invalid-application cause. Neither probe executed a real shim or a fallback. This confirms fail-closed behavior and actionable native diagnosis, not universal path correctness. It does not prove a full wrapper result on Linux or Windows 5.1.

A precheck can give fixed text if the path is already absent at the instant of checking. It cannot authenticate an existing shim or close the check/use race. Conversely, the current native message already gives a concrete path and cause; the alleged diagnostic harm is not established for these cases. The same file's Invoke-GitRaw contract explicitly distinguishes false Start results from propagating process/task/stream failures, so native propagation is not evidence of an accidentally universal fixed-error rule. Existing actual wrapper tests for multiple-node-paths and first-node-failure protect first-selection/no-fallback; they do not specifically simulate disappearance after Get-Command.

Operators need the failing executable and reason. Security owners need no silent fallback or claim of authentication. Maintainers need consistent native-error boundaries. Contributors need truthful preconditions. QA needs actual failure evidence rather than a test of the guard's spelling. Auditors need race limits stated plainly. An existence check is a diagnostic policy option, not a required security repair on the evidence available.

## 2. Options before evaluation

- A. Retain current first-application selection and native launch exceptions.
- B. Restore the single File.Exists guard and its former fixed message, keeping Process.Start authoritative.
- C. Keep resolution unchanged and catch only launch exceptions to return a fixed start diagnostic.
- D. Combine B and C.
- E. Introduce a pinned path, authenticated identity or stronger approved-runtime contract.
- F. Re-resolve or try another Node when the selected path is absent or fails.
- G. Remove the recovery child requirement when Node is unavailable.
- H. Add only a code comment about native propagation and the race boundary.

B close to Start instead of close to resolution narrows one interval but has the same check/use limitation. C retaining raw OS detail provides essentially A's diagnosis plus a new wrapping boundary; bounded new detail schema would require a separate justified contract. E+B does not strengthen E's authentication. F and G violate existing fail-closed/first-application requirements and are ineligible. No broad catch may mask child/native status or cleanup failures.

## 3. Unique weighted rubric

Selection and failure integrity 30%: preserve the first selected path, fail closed, never silently reroute, and retain substantive errors. Actionable diagnosis 30%: preserve specific path/cause information for actual missing or invalid applications. Security accuracy 20%: distinguish existence from executable trust and avoid false race guarantees. Compatibility and evidence 15%: match current native boundaries, actual platform evidence and existing independent tests. Cost 5%: weigh new error contracts and maintenance only after the operational criteria.

## 4. Scores before selection

| Option | Selection and failure integrity 30 | Actionable diagnosis 30 | Security accuracy 20 | Compatibility and evidence 15 | Cost 5 | Total / 100 | Reason and limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 10 | 10 | 10 | 9 | 10 | 98.5 | Actual missing/bad executable failures name the selected path and OS cause; no fallback or false success. |
| B | 10 | 8 | 8 | 9 | 9 | 88 | Detects an already missing path early, but loses OS detail; cannot validate a shim or cover a later race. |
| C | 10 | 7 | 9 | 8 | 7 | 84.5 | Stable text but discards actionable OS failure detail unless a new bounded detail contract is designed. |
| D | 10 | 7 | 8 | 8 | 6 | 82 | Adds both boundaries without additional execution authority; retains the limitations of B and C. |
| E | 8 | 8 | 9 | 5 | 2 | 74.5 | A different runtime-authority contract; no evidence here that authenticated executable identity is required. |
| F | 2 | 6 | 2 | 3 | 7 | 36 | Violates current first-application/no-fallback controls; ineligible. |
| G | 1 | 1 | 1 | 1 | 10 | 14.5 | Would permit loss of a required semantic check; ineligible. |
| H | 10 | 10 | 10 | 8 | 8 | 96 | Same runtime semantics as A; duplicates the native-failure conventions already documented in this file. |

## 5. Selected instructions and validation

Select A. Keep the first application returned by Get-Command. Pass its Source to Process.Start. Keep native launch failures and disposal behavior. Do not try a second executable. Explain that File.Exists does not validate a shim and cannot prevent a later disappearance. State that the demonstrated native messages contain the path and specific failure. Do not claim that a precheck has no possible diagnostic use; its fixed-text use is outweighed here by the actual diagnostic detail already retained. No product edit or new aggregate is required. This is a reasoned rejection of a proposed remedy, not a deferral of a demonstrated runtime defect.

Primary API support: [Get-Command](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/get-command?view=powershell-7.6), [File.Exists](https://learn.microsoft.com/en-us/dotnet/api/system.io.file.exists?view=net-9.0), and [Process.Start](https://learn.microsoft.com/en-us/dotnet/api/system.diagnostics.process.start?view=net-9.0). The selected behavior is established primarily by the exact current source and bounded native probes; these APIs explain their limits.

## Selection and evidence

Root displayed validation, options, this unique rubric, all scores and the selected action before product release. Selected2026-10-06UTC on TF7dd48f52c9e4c17268b4a571919622f4d701e5d0, acceptedB=e21b74fe0b56551008f78f9f2946cd2a0f9c19ce and pairedPS98177628b7bc02c646724bfc8aa0fd73fed0cd24. [Decision evidence](evidence.json) and [parent verification](root-verification.json) bind all7 raw source rows,18 artifacts and29 score calculations. Runtime probes used PowerShell7.6.5/PSScriptAnalyzer1.24 and Node24.18.1. Probe limits and failed private job-selector attempt remain in evidence; no product or hosted execution is inferred from prospective analysis.
