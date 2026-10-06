<!-- markdownlint-disable MD013 -->
# A04 conditional addendum: dedicated Copilot review setup

**The selected A04 implementation scope does not change.** The new `.github/workflows/copilot-code-review.yml` adds one separate Copilot installer consumer to the read-only integration census. It does not call the ordinary initializer. D04-1 R93, D04-2 Q99 and D04-3 C93 remain applicable without new scoring; A03-D6 B98 already covers the inherited Copilot configuration boundary. No new material finding was identified.

This comparison pins accepted PS `98177628b7bc02c646724bfc8aa0fd73fed0cd24`, published-but-unaccepted TF `5ec4bdc06431de05e93067b0e52f0dfbb1631392` / tree `441d84c13f46d94c6a032e828615a10fae8d4c7e`, and accepted TF `e21b74fe0b56551008f78f9f2946cd2a0f9c19ce`. Publication/state comes from the coordinator; no native operation was performed. Current review/CI or acceptance is not inferred from local evidence.

## Exact impact

| Consumer | Current contract | A04 consequence |
| --- | --- | --- |
| Ordinary `Initialize-CiToolchain.ps1` | Fixed curl; connect20 / max180 / retry2; still no first-argument `--disable` or `--retry-max-time` | Existing two-flag repair and actual whole-helper tests remain due. |
| Coding `copilot-setup-steps.yml` | Separate verified runtime installer; first-argument disable; connect20 / max120 / retry3 / retry-max300 / retry-all-errors | Preserve selected A03-D6 behavior. Do not import ordinary retry policy. |
| New `copilot-code-review.yml`, step `Set up verified official Node.js runtime` | Exactly the same complete 6,318-byte runtime step as coding setup and accepted PS coding setup | Add this path to the comparison/test integration census; no additional A04 product edit. |

The three complete Copilot runtime steps have raw SHA256 `412d19aaadd0e8f7855a2707c673de66b99284b6cb431965be0ed03dfaa92520`. Each retains fixed curl/tar selection, official pinned Node supply, immediate native failure, SHA-256 before extraction/execution and runtime identity checks. The new workflow has zero ordinary-initializer invocations. Its runtime step begins at line 452 and curl invocation is line 527 at the pinned TF head.

The ordinary download/native-exit/digest region is still exactly 611 bytes, SHA256 `5e84f78352fcfa91d07bba26533e11acbe6010ce41083be4075daa36a95a29d0`, in accepted PS, accepted TF and published TF. The complete TF initializer is unchanged from accepted TF. The ordinary caller census remains four per repository: `markdownlint.yml` jobs `policy` and `markdownlint` request workflow dependencies; `agent-instructions.yml` jobs `accepted-policy` and `candidate-tests` request both switches. Build and both Copilot workflows add no ordinary caller. R13 increases only the candidate behavior budget; it does not change download semantics, and the shortest relevant ordinary job remains 20 minutes.

`evidence.json` expands the prior 19-path raw identity census by this one new workflow, across three pinned snapshots (60 rows, including explicit absent-file records). It records modes/blobs/SHA256, exact ordinary calls, complete runtime-step hashes, the actual curl line, and existing test regions. It does not replace the historical postA06 report or claim a full task acceptance audit.

## Applicable tests and reuse

The current CI helper file now has per-workflow actual runtime cases for both coding and review setup. Those cases capture first-argument disable and the existing TLS/retry/origin arguments, plus download/version failure behavior. The persistent `dedicated review setup preserves every preparation guard and omits only the aggregate` test compares every retained parsed step against coding setup, including the runtime body. Its actual production assertion is recorded in the evidence.

The real-curl asynchronous contamination test still extracts the coding setup command, not the new review command directly. Its source bytes are unchanged between pinned PS and TF; the full-step parity assertion binds the new consumer to that same command. This is explicit source/parity coverage, not a claim that a second real-curl test ran. Retain both the actual contamination test and parity oracle when integrating A04; no duplicate network fixture or new installer policy is justified by the identical body. If a future review-runtime body diverges, reassess that caller before reusing the shared proof.

After actual TF acceptance and the existing A06/A03/A07 integration prerequisites, the A04 writer should work from the current complete `Test-CiHelpers.test.mjs`, preserving R11 discovery, both Copilot runtime case groups and review parity. Reuse the selected asynchronous loopback pattern for new **ordinary whole-helper** Retry-After numeric/date, connection/partial stalls, exhaustion, output reset, native-exit/digest-order, valid/wrong digest and curlrc header/additional-URL controls. Validate production arguments before test-only endpoint/timing substitution. Keep the failing watchdog and record actual Linux curl/runtime versions. No production timeout/URL override, all-error retry addition, sidecar hash policy or outer watchdog implementation is selected.

The ordinary implementation remains first-argument `--disable` plus `--retry-max-time 300`, connect20/max180/retry2 unchanged. The retry timer bounds retry admission, not an in-flight transfer; retain the existing nominal 483-second algorithm-envelope qualification. Historical extracted-segment timings and interrupted probes are not current Linux whole-helper acceptance. Run meaningful affected policy/classifier/helper checks and required final gates against final destination bytes, without counting skips as platform passes.

## Next boundary

First bind actual accepted TF landing and current PS main, including any accepted ten-path carryback. Then resume the existing PS-first A04 implementation → needed TF counterpart → reverse comparison lifecycle under one writer. Preserve independent repository contracts and converge the common initializer as already selected. No new owner authority, duplicate decision, A04 workflow rewrite, or counter increment is required for this read-only addendum.

A04 remains implementation-unaccepted, transfers 0/8, review rounds 0/80 and clock not started. No tests, installs, product/planning edits, Git ref/index/config mutations, native actions, descendants or counter changes occurred. Both local repository guards remained equal during these immutable reads. Current TF review/CI and service acceptance remain root-owned and pending their actual outcomes.
