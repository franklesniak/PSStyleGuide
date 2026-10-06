<!-- markdownlint-disable MD013 -->
# Round 4 repair: focused evidence binding

**PASS_FOCUSED_EVIDENCE_BINDING.** No material finding. This addendum binds the previous source review (`round4-repair-implementation.md`, SHA256 `f1d4336b27d3b09a5b79d5515e170449627f3bf037a135889b006a1b6ef298ac`) to the final focused packet and closes its five pending focused-control items. It is not full aggregate, committed-input, hosted-review, CI, or landing acceptance.

Frozen packet under `writer/TF68-R11-S1-R13-implementation`:

- IMPLEMENTATION.md: `7c4306926d0fd04ee35b1fb8179a379e58748ffa9b5ed75709d79aa32d36a949`.
- evidence.json: `0d757d426cab263f193b198fd6692a57a0b7e43714dd96b2474fa674c26614dd`.
- source-final.json: `045da9f92d5189a462a00f960f0e59d024fdc776f715cd427ace608fa6c7db5d`.

Independently verified all 59 recorded artifact sizes/hashes, Windows result-log and executed-driver bindings, eight Linux command/log bindings, exact archive membership and raw content for all 80 sources and 1,914 dependencies, and their current workspace content hashes. No mismatch. Reviewed both runner and finalization implementations: the recorded pre-staging host guards check HEAD/index/refs and all source/dependency bytes; isolated Linux guards run after each command and require clean fixture state. The unchanged Husky executable-bit adaptation is explicitly qualified. Subsequent root-owned staging is separate from those recorded input guards.

Saved final Windows session 16507 and Linux session 97683 report terminal zero. Final Windows parser/analyzer and actual reader/security tests passed; four selected Node tests passed. Linux's eight focused groups passed, with 150 affected tests and zero failures/cancellations/skips/todo. These are focused results, not the full seven-suite or final precommit total.

Reviewed actual `extra-reader-controls.ps1` and `discovery-controls.mjs` plus terminal logs. Required coding-workflow deletion fails both with and without its index entry. Native Linux worktree and indexed symbolic links fail actual reader admission. The security-loop omission mutant accepts the injected action and therefore fails the actual refusal oracle; the catalog omission mutant loses the review input and therefore fails the present-file oracle. Exact original functions are restored in `finally` and the positive reader is checked afterward.

The Linux spaced-path Git application is an executable forwarding shim to actual Git, not a copied binary. Seven selected-application receipts bind actual proof execution. Replacing that selected application with exit 73 makes the proof fail while healthy system Git remains available, demonstrating no fallback. The original fixed-selector mutant still passes the ordinary proof but produces no selected-application receipt, so the new discriminator rejects it. Windows supplies actual PATH discovery through its installed spaced `cmd/git.exe` and real missing-runtime/tool checks; it does not supply native Windows symbolic-link evidence.

All four Windows and one Linux scratch failures remain preserved. The two early AST drivers lost file-bound script-root context; the first extra-reader expectation rejected the correct earlier missing-file refusal; the next private mutant leaked function state before explicit restoration was added; Linux attempt 1 could not find existing actionlint on its driver PATH. Final corrected drivers passed with unchanged product bytes. These failures are not erased or characterized as product passes.

No duplicate tests, source edits, native actions, or new agents were performed by this reviewer. Root still owns final all-files precommit, full seven-suite validation with the actual updated count, accepted-base/new-candidate endpoints and audit, new commit/tree/body binding, fresh exact-input reviews, actual ordinary and dedicated-service completion, and strict landing/pair gates. Current cancelled runs are not recovered by this packet. Preserve no-failing-CI merge, hourly retry bounds, no generalized historical exception, original deadline `2026-10-13T23:47:31Z`, counters A06/A03/A21/A07 `1/3/5/5` of 12, and no PS repair before TF acceptance.
