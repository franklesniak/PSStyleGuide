<!-- markdownlint-disable MD013 -->
# TF68 R8 — precise output type for raw NUL records

## 1. Validation and affected users

The current annotation at actual source line 186 is `[OutputType([System.Array])]`; the review location is line 190. Output prose correctly promises one System.Byte[] per record and no output for empty input. The body prevalidates malformed records, copies each record to a byte array and uses Write-Output -NoEnumerate. All three gate callers at 790–792 consume the record objects through Assert-AllowedPathSet. System.Array is a valid base type but is less precise than this supported contract. This is a metadata/documentation quality opportunity, not a demonstrated runtime parsing defect.

The actual extracted function was evaluated unchanged and with each of `[OutputType([byte[]])]` and `[OutputType('System.Byte[]')]`. Empty, one-record and two-record inputs emitted counts 0/1/2 and preserved exact Byte[] values in all variants. Get-Command exposed System.Array for the original and System.Byte[] for both prospective annotations. All three extracted definitions had zero PSScriptAnalyzer 1.24 warnings/errors. A subsequent bounded full-file in-memory probe checked original source and the single type-literal replacement: each had zero parser errors and zero analyzer warnings/errors, native exit 0. The full script was analyzed, not executed; script/function date metadata had not been changed. String-annotation full-file compatibility was not separately tested.

PowerShell's [OutputType documentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_outputtypeattribute?view=powershell-7.6) describes metadata used by discovery/tooling; it neither enforces nor converts actual output. Precise metadata benefits new callers, editor users and maintainers. Security/QA need byte preservation and all malformed-input refusals unchanged. Operations need a small reviewable change with a truthful validation boundary. No analyzer suppression or emission rewrite is warranted by the measured result.

## 2. Options before evaluation

- A. Keep System.Array and the existing precise prose.
- B. Replace only the annotation with `[OutputType([byte[]])]`; retain output prose and runtime body.
- C. Use the string annotation `[OutputType('System.Byte[]')]` instead.
- D. Broaden the output prose to System.Array to match the current annotation.
- E. Change output emission and the annotation together, using another non-enumeration mechanism.
- F. Declare both Array and Byte[] as outputs.
- G. Use a precise annotation with an analyzer suppression or rule change.

B and C are alternatives for the same metadata. Adding prose to B that restates the already accurate output contract gives no further correction. D+E would weaken a real byte-preservation contract and is ineligible if it changes returned types. No new test should merely search for the literal attribute; test metadata and values instead. Runtime/body rewrites and analyzer exceptions are not needed for this finding.

## 3. Unique weighted rubric

Contract precision 35%: make discoverable output types agree with actual per-record byte arrays, including empty output. Runtime preservation 30%: preserve byte values, object boundaries, prevalidation and callers without new enumeration behavior. Tool compatibility 20%: retain zero parser/analyzer diagnostics and use an actual available built-in type. Reader clarity 10%: keep direct, accurate metadata and prose understandable to a new caller. Maintenance 5%: avoid redundant declarations, exemptions or algorithm changes.

## 4. Scores before selection

| Option | Contract precision 35 | Runtime preservation 30 | Tool compatibility 20 | Reader clarity 10 | Maintenance 5 | Total / 100 | Reason and limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 7 | 10 | 10 | 7 | 10 | 86.5 | Truthful base type, but Get-Command metadata omits the already promised byte element type. |
| B | 10 | 10 | 10 | 10 | 10 | 100 | Exact built-in type, proven metadata and preserved values; full prospective file parses and analyzes cleanly. |
| C | 10 | 10 | 9 | 9 | 9 | 96.5 | Equivalent extracted metadata; string indirection is unnecessary for an available built-in type and full-file variant was not separately tested. |
| D | 5 | 10 | 10 | 5 | 9 | 77 | Documents less than the real byte-preserving contract and leaves imprecise tool metadata. |
| E | 10 | 7 | 8 | 8 | 5 | 82.5 | Adds avoidable enumeration/runtime risk when existing output and analyzer already accept precise metadata. |
| F | 7 | 10 | 9 | 6 | 8 | 82.5 | Redundant broad type weakens the same discovery contract without improving actual values. |
| G | 10 | 10 | 5 | 6 | 5 | 83.5 | No analyzer failure exists; an exemption reduces future defect detection without benefit. |

## 5. Selected instructions and exact proposed scope

Select B. In `.github/workflows/Test-StyleGuideArtifacts.ps1`, change the OutputType attribute of ConvertFrom-NulPathRecordStream from System.Array to byte[]. Keep the function body and output prose unchanged. Update only the file version and that function's version to the actual UTC modification date, following the accepted-baseline revision rule. If implemented on 2026-10-06 UTC, use `2.0.20261006.0` for those two existing `2.0.20261005.0` fields. Do not update unrelated function versions. Do not add a suppression. Do not change emitted records, call sites, Node resolution, generated outputs, dependencies or policy.

After root release, verify actual final bytes with full-file parser and PSScriptAnalyzer 1.24. Run an AST-extracted contract probe against those exact bytes: Get-Command metadata must report System.Byte[]; empty/one/multiple records must preserve types and bytes; final-NUL absence and empty records must still reject before any output; a record with newline/non-ASCII bytes must remain raw bytes. Reuse original-byte broad-metadata control to show the probe detects the intended contract change. This checks behavior and discovery, not literal spelling.

For actual wrapper use, root can run the existing Linux cases `artifact gate recovery role includes verifier child effects: clean`, `stale`, `verifier-worktree`, and `recovery-source` from Test-CiHelpers.test.mjs in its qualified disposable source context. These names were checked in current source. They exercise unchanged consumers with successful and changed-path outcomes. From that disposable repository root, use the qualified Node executable with `--test --test-name-pattern="^artifact gate recovery role includes verifier child effects: (clean|stale|verifier-worktree|recovery-source)$" .github/workflows/Test-CiHelpers.test.mjs`. The final command must be bound to the implementation input; no run is claimed here. Current Windows 5.1 execution remains restricted; do not bypass that restriction. Root can use required hosted platform evidence when applicable.

The applicable AGENTS gate requires one final pre-commit all-files pass on the final candidate before this commit, plus zero parser/analyzer problems for the modified PowerShell file. Root owns that single final all-files gate, ordinary CI and current review admission. No separate full 567-test rerun is required merely for this annotation change, absent another applicable acceptance requirement. Annotation-only risk also does not independently justify repeating long author-finalization fixtures; unchanged-input results can be retained with their original identities. Root must reconcile any additional active acceptance rule before final publication. No gate is waived by this recommendation.

## Selection and evidence

Root displayed validation, options, this unique rubric, all scores and the selected action before product release. Selected2026-10-06UTC on TF7dd48f52c9e4c17268b4a571919622f4d701e5d0, acceptedB=e21b74fe0b56551008f78f9f2946cd2a0f9c19ce and pairedPS98177628b7bc02c646724bfc8aa0fd73fed0cd24. [Decision evidence](evidence.json) and [parent verification](root-verification.json) bind all7 raw source rows,18 artifacts and29 score calculations. Runtime probes used PowerShell7.6.5/PSScriptAnalyzer1.24 and Node24.18.1. Probe limits and failed private job-selector attempt remain in evidence; no product or hosted execution is inferred from prospective analysis.
