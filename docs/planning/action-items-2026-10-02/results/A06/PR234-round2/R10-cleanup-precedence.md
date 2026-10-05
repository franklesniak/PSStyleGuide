<!-- markdownlint-disable MD013 -->
# R10: preserve the primary failure when harness cleanup also fails

Review5420961221, comment4189169317, reviewed input07636c8633b8544eb30c71ce1b24d2bcdef4c74e. Analysis reads the R7-preserved harness SHA256fbfa8555cd9596073abb78200af00eba9df38e60f336c0bf500342401ca17584, subsequently committed by root as d7bb8ada326d52fab091b1d59b932288d56c4d91/tree0d0be7e. Product remains read-only until root releases this selected repair.

## 1. Validate

The final Remove-Item executes under ErrorActionPreference=Stop. Its terminating error can replace an earlier assertion error. R10-before-probe.ps1 extracts the actual final block and uses a synthetic primary throw plus a Remove-Item function that returns or throws. Six Windows7.6.5 cases show: clean succeeds; primary-only retains the primary; cleanup-only returns the cleanup failure; both returns the cleanup failure rather than the primary; containment-only returns its fixed refusal and never calls deletion; primary+containment returns containment rather than primary. No actual file deletion, Git/config action or full product test occurred. This establishes failure precedence, not a reproduced OS file-lock incident. Saved JSON records exact source hash and outcomes.

The suggested blanket ignore is incomplete: a cleanup-only failure must still fail the harness. A Test-Path existence check neither fixes deletion errors after the check nor proves safe containment. There is no need to add such a check to repair precedence. Current successful summary is emitted before finally, so move it after completed cleanup to avoid a success message when cleanup alone fails.

## 2. Stakeholders

Contributors and CI operators need the original assertion and a clear secondary cleanup signal. QA and reviewers need cleanup-only failures to remain nonzero, no delete after failed containment, and negative controls for both precedence and accidental swallowing. PS/TF maintainers need one portable shared harness that retains R7 and all original tests. Artifact users need truthful platform admission. Security reviewers need fixed diagnostics without raw cleanup exception/path leakage. History/recovery operators need failures retained, not silently discarded. Cost owners need a bounded repair without extra workflow jobs. No runtime, credential, privacy, dependency or protected-guide authority changes.

## 3. Options before scoring

- A: Retain finally behavior; deferral has the same diagnostic defect and maps to A.
- B: Follow blanket cleanup suppression, optionally preceded by Test-Path; retain containment throws.
- C: Record that the main test body failed and rethrow it unchanged. Guard the full cleanup operation. Use fixed secondary diagnostics when a primary failure exists; throw a fixed cleanup failure when none exists. Keep containment refusal and move success summary after cleanup.
- D: Capture both errors and throw a new combined/aggregate exception after cleanup.
- E: Add cleanup retries and retain current error precedence.
- F: Move cleanup to a separate workflow/job or external owner with independent result admission.

C plus bounded retries is possible but no transient failure frequency or retry need was established; it adds delay without replacing the precedence repair. D with sanitized combined text still loses the original error identity/stack unless it adds more machinery. Test-Path plus A leaves the demonstrated two-error problem. Removal of cleanup fails the retained containment/cleanup obligation. F requires broader caller/policy scope and is not selected.

## 4. Fresh rubric before scoring

Scale1–5:1 fails,2 weak,3 adequate with material limitation,4 strong,5 fully meets the bounded need. Total=sum(weight times score)/5; scores are judgments.

- Diagnostic fidelity35%: preserve the original assertion/error record and identify a secondary cleanup problem without implying success.
- Fail-closed cleanup30%: cleanup-only failure remains nonzero; containment failure prevents deletion and cannot yield success.
- Detail safety15%: avoid untrusted exception/path contents and keep fixed secondary categories.
- Supported-host behavior10%: deterministic PowerShell5.1/7-compatible control flow without host-policy changes.
- Verification5%: focused negative controls distinguish preservation, swallowing and containment behaviors.
- Proportionality5%: minimal new lifecycle machinery and bounded execution cost.

Hard constraints: retain R7 bytes except necessary surrounding error handling; no production generator change; no hidden cleanup-only failure; no removal after invalid containment; no raw cleanup detail leakage. Root must release product edits before implementation. B fails the cleanup-only constraint; F exceeds proposed finite scope.

## 5. Scores before selection

| Option | Diagnostic35 | Cleanup30 | Safety15 | Host10 | Verify5 | Cost5 | Total | Limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 1 | 5 | 2 | 5 | 4 | 5 | 62 | Demonstrated primary masking persists. |
| B | 5 | 1 | 4 | 5 | 4 | 5 | 72 | Cleanup-only errors become success; ineligible. |
| C | 5 | 5 | 5 | 5 | 5 | 4 | 99 | Requires explicit primary-state and bounded cleanup classification. |
| D | 4 | 5 | 4 | 4 | 4 | 3 | 85 | Combined exception changes primary error identity and adds formatting complexity. |
| E | 3 | 5 | 2 | 3 | 3 | 2 | 68 | Exhausted retries still mask primary; timing and waits add uncertainty. |
| F | 4 | 4 | 4 | 3 | 3 | 1 | 74 | New admission/cleanup ownership and broader paths; no need established. |

## 6. Selected controlled-English action

Select C. Wait for root's implementation release. Initialize a Boolean primary-failure flag before the main try. In its catch, set the flag and use bare throw. Keep the existing tests and R7 controls unchanged.

Run cleanup in a guarded block. Check the resolved absolute parent and the exact generated child-name pattern before deletion. If containment fails, do not delete anything. Record a fixed containment diagnostic. If path resolution or deletion fails, record a fixed cleanup diagnostic. Do not include the raw exception message or path. Do not add an existence check that hides failures.

If cleanup failed and a primary failure exists, emit the fixed diagnostic with Write-Warning and WarningAction Continue. Let the original pending error propagate. If cleanup failed without a primary failure, throw the fixed diagnostic after the cleanup catch. Emit the success summary only after cleanup succeeds. Use a documented non-throwing cleanup catch solely to classify failure; do not replace the main bare rethrow with a new error. Retain the unpublished1.0.20261005.0 metadata.

Selected instructions use direct actions; formal ASD-STE100 dictionary compliance is not claimed. [PowerShell try/catch/finally](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_try_catch_finally) documents finalization during error unwinding. [Write-Warning](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-warning) documents warning preference/control. The exact masking result is established by the local extracted-block probe, not inferred from those pages alone.

## 7. Proposed verification and release boundary

Finite product scope: only .github/workflows/Test-StyleGuideGenerator.ps1. After release, exercise clean, primary-only, cleanup-only, both-fail, containment-only and primary+containment cases against the actual changed control block, with synthetic deletion dispatch. Verify primary message/record preservation, fixed secondary diagnostics, no raw injected cleanup text, no delete on containment refusal and no success summary on failure. Check WarningPreference=Stop cannot replace the primary. Independently break primary-state handling and cleanup-only refusal to show each oracle detects the regression. These are deterministic control probes, not native lock or race experiments. Run the actual focused Windows7 harness once and parser/analyzer checks. Root owns full aggregate, hosted evidence, staging, lifecycle and publication. No implementation has occurred in this preparation.

Implementation is now frozen after root release. [Actual final-byte focused results](IMPLEMENTATION.md) pass156harness assertions,12control cases and3independent mutants; full aggregate/hosted acceptance remain root gates. The preparation above records the pre-edit decision.
