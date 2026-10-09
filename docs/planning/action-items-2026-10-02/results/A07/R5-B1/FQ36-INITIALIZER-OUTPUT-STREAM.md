<!-- markdownlint-disable MD013 -->
# FQ36: preserve the initializer success output

## Validation and stakeholders

Codex comment4228859879 in review5468513559 targets Initialize-CiToolchain.ps1 at c1ef946fe4585836f27a0a4480bd986899d7c316. Both dependency commands invoke native Node without stdout routing. The script's OUTPUTS block promises one completion string. Preflight JSON and npm logs therefore become additional success-stream values. Current workflow callers display the script output; none requires log text as a function result. The promised capture interface remains material even without a known current caller that fails on an array.

Root probe731586 on Windows PowerShell7.6.5/.NET10.0.11 and Node24.18.1 reproduced three captured success values from two native log lines and the completion marker. A streaming information route left exactly one result, preserved both diagnostic lines and preserved native exit7. This isolated stream probe does not replace a whole initializer test or its existing failure checks. Evidence: [pure probe evidence](current-main-validation/pr239-round2-pure-probes.json).

Senior maintainers and API consumers need a stable result shape. New users, CI/DevOps and incident operators need visible diagnostic output. Security engineers and QA need native failures to remain failures. Documentation and UX owners need the stated interface to match behavior. Business and project owners need a bounded repair. No credential, cloud privilege, localization or accessibility interface changes; log access remains available to the same caller.

## Options

1. Stream each child stdout line to the information stream, with visible diagnostics.
2. Discard child stdout.
3. Capture all child stdout and emit it as information after completion.
4. Pipe child stdout to Out-Host.
5. Document mixed success output instead of preserving the single result.
6. Build a custom native-process and log framework.
7. Make no change or defer.

All repairs retain stderr and nonzero checks and include tests. Streaming plus the existing exit checks is option1, not an additional design. Combining discard and capture has no advantage. A custom framework can implement option1 but adds process-control and lifecycle changes that this finding does not need.

## Rubric

Scores0-5 mean fails, weak, partial, adequate with uncertainty, strong, and fully suitable. Total is sum(weight*score)/5. Result-contract correctness30% protects capture callers. Diagnostic usability25% preserves visible useful logs and troubleshooting. Native-failure handling20% preserves refusal before publication. Bounded streaming15% avoids collecting an unbounded command transcript in memory and keeps timely logs. Caller control5% preserves stream redirection. Implementation effort5% is below correctness and usability. These scores express judgments, not performance measurements.

Hard constraints: preserve the promised single result, retain visible diagnostics and preserve nonzero failure handling. Options2,5and7 fail at least one hard constraint regardless of their totals.

| Option | Contract30 | Diagnostics25 | Failure20 | Bounded15 | Control5 | Effort5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 Stream to information | 5 | 5 | 5 | 5 | 5 | 4 | 99 |
| 2 Discard stdout | 5 | 1 | 5 | 5 | 2 | 5 | 77 |
| 3 Capture then emit | 5 | 4 | 5 | 2 | 4 | 4 | 84 |
| 4 Out-Host | 5 | 3 | 5 | 5 | 3 | 5 | 88 |
| 5 Document mixed output | 1 | 4 | 5 | 5 | 2 | 5 | 68 |
| 6 Custom framework | 5 | 4 | 4 | 4 | 3 | 1 | 82 |
| 7 No change/defer | 0 | 4 | 5 | 5 | 1 | 5 | 61 |

Option1 wins. It uses an existing PowerShell stream and retains logs. Capturing all output delays diagnostics and grows memory. Out-Host is less useful for structured stream capture. A custom process framework would require separate lifecycle qualification.

## Selected action

1. Send each stdout line from preflight and npm installation to the information stream.
2. Keep stderr separate.
3. Keep both native exit-code checks.
4. Keep the single completion result.
5. Document the log stream in the existing OUTPUTS block.
6. Test successful setup with each dependency-switch combination.
7. Test preflight and install failures.
8. Confirm that a failure cannot publish runner records or a success result.
9. Use a negative control that removes the stdout route.

Use Write-Information with InformationAction Continue for visible diagnostics. Do not accumulate the native transcript. The instructions use short active sentences and consistent terms; no formal ASD-STE100 dictionary certification is claimed.

## References and verification

[Microsoft Write-Information](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-information?view=powershell-7.6) and [PowerShell redirection](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-7.6), checked2026-10-09, describe the separate information and success streams. Root verified stream and native-exit behavior locally rather than assuming it.

The owner-facing options, rubric and table preceded implementation. Whole initializer validation remains pending. Current round2 reviews are both terminal; original deadlines and transfer9/12 remain unchanged.

## Local implementation at source freeze

Both dependency commands now stream stdout through Write-Information -InformationAction Continue. The immediate native-exit checks remain in place. The OUTPUTS block and runtime documentation describe the separate log stream. Seven whole-initializer fixture executions are prepared: four dependency-switch combinations, two native failure modes, and one route-removal mutant. These native fixture tests remain unexecuted; the earlier isolated stream probe retains only its original narrow scope.

The [frozen source record](current-main-validation/pr239-round2-source-freeze.json) identifies that historical repair input. Root syntax and whitespace checks passeda48f78.

## Current verification

The real initializer passed all four dependency-switch combinations, both native failure modes and the route-removal control within the accepted Linux record/output group. The Windows aggregate platform-skipped those whole-initializer cases. [Current candidate and validation](current-main-validation/pr239-round2-validation.md) supersedes the pending-test statements above and identifies the actual input attribution and remaining gates.
