<!-- markdownlint-disable MD013 -->
# TF68-R5: literal checker paths in private clock breakpoints

Status: B97.5 selected and the single-file TF repair released on2026-10-06 after root displayed validation/options, the unique detailed rubric, all scores and controlled-English selection in order. Read-only proposal probes preserved product, dependency and Git state. Root verified native mains PS9817762/TFe21b74f and the clean TFf89d47d worktree immediately before selection. This is separate from resolved TF68-R4, whose command-transport disposition remains valid for its measured input.

## 1. Validation and supported contract

`Invoke-AgentInstructionFixtureClock` accepts the absolute path of the actual checker, reads that path literally with `File.ReadAllText`, and registers both checked clock anchors with `Set-PSBreakpoint -Script $CheckerPath`. The cmdlet's Script parameter supports wildcards. A literal filesystem path is therefore being passed to a pattern-aware parameter without escaping. [Set-PSBreakpoint contract](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/set-psbreakpoint?view=powershell-7.5).

Source is TF head `f89d47d6780db47df29be4eb6d79cab35051f598`, `.github/workflows/Test-AgentInstructions.SelfTest.ps1`, mode 100644, blob `a976b7f224b4e9df0064493e3ec2c5514e9b8046`, SHA256 `2c7aaaeea5efd74c22ea395d93fc3bc1d508f78ae46e4ac1296a41aef905e67d`. The affected registrations are lines 997 and 999. The file remains byte-identical to the current committed input.

These are supported path forms. The helper's documented contract requires an absolute actual-checker path and has no metacharacter restriction. The author-finalization fixture constructs its root from `GetFullPath(GetTempPath())`, a GUID leaf and fixed checker path. The capacity fixture passes the actual loaded production function's `ScriptBlock.File`; a user's checkout can contain brackets or a backtick. Neither caller excludes these characters. A bounded child-only environment probe on Windows and Linux confirmed that a configured existing temporary directory named `configured-temp[ab]` is returned intact by the exact GetTempPath/GetFullPath operations. No parent environment was changed. The .NET contract documents environment-dependent temporary directories, including TMPDIR on Unix. [GetTempPath contract](https://learn.microsoft.com/en-us/dotnet/api/system.io.path.gettemppath?view=net-9.0).

Concrete reproduction: a requested checker in directory `bracket[ab]` has sibling checker files in `bracketa` and `bracketb`. The original helper registers **four breakpoints on the siblings**, two anchor lines per sibling, instead of two on the requested checker. The intended checker runs with the real date. The existing receipt detects the missing controlled readbacks and fails closed. On Linux, literal `star*literal` and `question?literal` directories with `starXliteral` and `questionXliteral` decoys register on both the target and decoy; receipt checks again reject the result. This is a legitimate path-dependent fixture failure, not a demonstrated production validator bypass or silent false pass.

The issue reproduces with a direct in-process helper call. It is not caused by the R4 string command, its length or quoting. Moving the helper to a file would retain the wrong Script parameter semantics unless the registration itself also changes.

Two prospective fixes were tested **only in memory**, using the exact helper body with its two registration expressions replaced: the documented `WildcardPattern.Escape` method before the existing cmdlet, and the current-runspace debugger's literal `SetLineBreakpoint` API. Neither product file nor production validator was rewritten. The synthetic checker contains the same complete anchors and an actual locally scoped date function; it is not a full actual author/capacity fixture. [WildcardPattern.Escape contract](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.wildcardpattern.escape?view=powershellsdk-7.4.0), [Debugger API](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.debugger?view=powershellsdk-7.4.0).

| Platform / helper | Cases | Passed | Expected original failures |
| --- | ---: | ---: | ---: |
| Windows 7.6.5 original | 10 | 6 | 4 |
| Windows escaped cmdlet | 10 | 10 | 0 |
| Windows literal API | 10 | 10 | 0 |
| Linux 7.6.3 original | 14 | 6 | 8 |
| Linux escaped cmdlet | 14 | 14 | 0 |
| Linux literal API | 14 | 14 | 0 |

Each path is checked in initialization-plus-local and LocalOnly modes. Windows covers plain, bracket, backtick-plus-bracket, backtick-only, apostrophe and Unicode paths. Linux also covers literal star and question-mark paths with decoys. For both repaired variants, the recorded breakpoint objects refer only to the exact requested checker: two registrations in ordinary mode, one in LocalOnly. LocalOnly leaves the initialized real date unchanged while controlling the local date. All cases end with zero fixture breakpoints and zero clock receipt variables. Both probe processes exit 0 after collecting these outcomes; the evidence builder independently asserts the expected successes, failures, target identities and cleanup.

The Linux probe used the retained qualified image with network disabled and a mounted scratch output directory. The literal `*` and `?` controls qualify Linux PowerShell path semantics on that mounted scratch filesystem; they are not hosted-runner or native-ext4 acceptance, and they make no Windows-native support claim for those filename characters. No Windows PowerShell 5.1 execution, full aggregate rerun or production path rejection was introduced. `evidence.json` contains exact commands, native exits, identities and per-case objects. The R4 direct reproduction remains retained as prior evidence.

## 2. Stakeholders

Contributors and local/remote agent operators must be able to use valid checkout/temp paths without changing account names or system environment. PS and TF maintainers need one common helper repair and no language-specific algorithm fork. QA/reviewers need exact breakpoint targeting, meaningful decoys and negative controls that retain the original defect. CI/platform engineers need the same code on Windows and Linux; incident/recovery operators need existing primary-error precedence and complete scoped cleanup. Security engineers need fail-closed anchors, the exact installed checker and no production clock bypass. New contributors need an ordinary success path rather than an unexplained debugger failure or manual TMP workaround. Documentation/artifact consumers need no unrelated generated changes. Schedule/maintenance owners need a bounded change with proportional tests, but convenience cannot justify rejecting legitimate paths. Privacy/cloud/accessibility roles have no new data, deployment or UI surface; Unicode filesystem usability remains relevant and is covered.

## 3. Options before rubric/scoring

A. **No change, refute or retry.** Existing receipts prevent a false pass, but the original path deterministically fails. Retrying with the same path cannot fix it. This is not a supported no-change disposition as R4 was.

B. **Escape the literal path only for both existing Script arguments.** Compute `WildcardPattern.Escape($CheckerPath)` once, then use that value for the two `Set-PSBreakpoint` registrations. Keep the original path for literal source reads and checker execution. Retain all current anchor selection, action scope, receipts, cleanup and primary-error handling. Add a bounded persistent bracket/decoy regression to the existing clock-control block. This directly restores the cmdlet's literal-path meaning using the existing mechanism.

C. **Use the debugger's literal `SetLineBreakpoint` API.** The current-runspace overload is present and passed all private probes on both runtimes. Keep current line anchors/actions and existing breakpoint removal. This avoids wildcard processing entirely, but changes from the established cmdlet mechanism to direct runspace/debugger API ownership. It is a viable alternative, not an unsupported API guess.

D. **Use AST-derived line locations with the literal API.** This could also solve path identity, but AST line derivation itself does not fix a wildcard-aware Script parameter. Replacing the complete exact-text anchor checks changes C97's source-drift admission without evidence that those checks are defective. Combine only if a distinct line/anchor finding later warrants it.

E. **Reject paths containing wildcard characters with an earlier diagnostic.** This would fail more clearly, but it would narrow legitimate temp/checkout path support and require users to change environment or clone location. It also requires an explicit contract change. A path restriction is not necessary when B/C work.

F. **Force fixtures into a sanitized temporary root.** Choosing a fixed writable root or changing TMP/TEMP/TMPDIR adds permissions, multi-user, cleanup and environment concerns. Sanitizing only the GUID leaf cannot remove metacharacters in ancestors. It does not fix the capacity helper's actual source-file path. This is at most a user workaround, not the common repair.

G. **Copy the checker into a safe path and execute that copy.** This may avoid wildcard characters but changes source-file identity and the accepted/current/proposed caller context. The LocalOnly capacity function is already loaded from its actual source file. Preserving meaningful exact-source coverage would require a larger redesign, and it risks undermining C97.

H. **Move the helper to a file or change process transport.** This does not change the problematic Script argument. The direct in-process reproduction proves the transport is not the cause. Combining it with B/C inherits the real fix and adds unrelated R4 scope, so it is not a separate justified repair.

I. **Add a production clock parameter, alter validator bytes, remove the clock, or drop the path-sensitive tests.** This abandons the selected C97 security/test-fidelity constraints and is excluded.

J. **Hand-escape only brackets, normalize separators, or apply string substitutions.** Full-path normalization was already used in the valid probes and does not change wildcard meaning. Bracket-only replacement misses Linux star/question patterns and backtick escape interactions. The runtime's documented escaping method already covers that grammar; hand-maintained escaping has no supported advantage.

Using a native cmdlet plus narrow configuration is B. Reusing existing persistent fixture controls is part of B/C. A temporary operational exception or delayed repair would leave a confirmed supported-input failure; no waiver is needed for the bounded fix. Source changes, new helper files, runtime upgrades and all-provider path APIs are outside the demonstrated need.

## 4. Unique weighted rubric

Scores are 0–10: 0 fails the need; 5 has material unresolved limitations; 10 has strong current bounded support. Totals are weighted scores out of 100, not empirical probabilities.

- **L, 35% — Literal-path correctness and decoy exclusion:** bind exactly the supplied file across the actual wildcard grammar; do not claim a workaround fixes the registration.
- **C, 25% — C97 clock fidelity:** preserve exact checker bytes, both checked anchors, LocalOnly scope, primary-error precedence and fail-closed receipts.
- **P, 20% — Portable supported mechanism:** documented or actually qualified PowerShell behavior, consistent Windows/Linux semantics, no new runtime dependency or undocumented environment assumption.
- **U, 15% — Contributor usability and reliable cleanup:** valid paths work without manual relocation; failures remain understandable and cleanup remains scoped.
- **M, 5% — Maintenance and paired scope:** common small repair, clear ownership and reusable existing tests. Low churn cannot override correctness/usability.

Hard constraints: no production clock/security interface change; no weakening or removal of exact anchors/readbacks; no actual checker byte substitution; no loss of primary errors or cleanup; preserve the accepted/current/proposed/delayed/local/capacity checks; change only root-released paths. No score can waive these constraints.

## 5. Scores before selection

| Option | L | C | P | U | M | Total | Main uncertainty / constraint |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A: no change/retry | 1 | 9 | 4 | 1 | 10 | 40.5 | Confirmed supported paths still fail |
| B: escape both cmdlet registrations | 10 | 10 | 9 | 10 | 9 | 97.5 | Actual changed-byte fixture verification still required |
| C: literal debugger API | 10 | 9 | 9 | 9 | 8 | 93.0 | New direct runspace/debugger API coupling |
| D: AST lines plus literal API | 9 | 8 | 8 | 9 | 6 | 84.0 | Unnecessary anchor-admission redesign |
| E: reject metacharacter paths | 3 | 9 | 9 | 2 | 9 | 58.5 | Narrows legitimate usability |
| F: sanitized temp root | 6 | 5 | 6 | 5 | 6 | 56.0 | Does not cover actual capacity source path |
| G: copy checker | 7 | 3 | 7 | 6 | 5 | 57.5 | Changes source/caller identity |
| H: process/file transport only | 1 | 9 | 8 | 6 | 7 | 54.5 | Does not repair reproduced cause |
| I: production clock/drop proof | 2 | 0 | 8 | 6 | 4 | 34.0 | Violates hard constraints |
| J: manual escape/normalization | 6 | 8 | 6 | 6 | 7 | 65.5 | Incomplete grammar/extra maintenance |

The evidence builder recomputes every total. B leads C by 4.5 points. Both prospective fixes passed the private probes; B wins because it uses the documented escaping operation while retaining the existing cmdlet, breakpoint objects and lifecycle. It fixes the demonstrated input interpretation rather than redesigning the fixture. This recommendation remains conditional on focused tests against the actual edited source after release.

## 6. Selected implementation

Select **B, 97.5**. The instructions below use short direct controlled-English wording. No formal ASD-STE100 dictionary certification is claimed.

1. Change only `.github/workflows/Test-AgentInstructions.SelfTest.ps1` after root releases it.
2. Keep `$CheckerPath` unchanged for source reads and execution.
3. Compute one escaped breakpoint path with `[Management.Automation.WildcardPattern]::Escape($CheckerPath)`.
4. Use the escaped value only in both existing `Set-PSBreakpoint -Script` arguments.
5. Keep line anchors, action bodies, LocalOnly behavior, receipts, cleanup and primary-error handling unchanged.
6. Give the existing persistent clock probe a literal bracket-bearing filename, such as `clock-probe[fixture].ps1`.
7. Create a matching-name decoy, such as `clock-probef.ps1`, inside the same existing private scratch directory.
8. In the positive control, inspect only breakpoints created after its saved initial IDs. Require exactly two registrations on the actual probe path before executing it. Keep the existing pinned-date assertions.
9. Keep all existing missing, duplicate, inactive-anchor, primary-error and cleanup controls. Let the existing literal-path private-directory cleanup remove the new decoy.
10. Update only required function metadata using the actual UTC date and existing version convention.
11. Do not add helper files to the repository, change process transport or change any production validator, guide, instruction, dependency or runtime file.
12. Stop and report any new material finding before expanding the change.

The final implementation may use the existing function's naming convention for the escaped string. The proposed private probe changed the two registration expressions directly in memory to compare alternatives; the selected product implementation computes the common escaped value once. Both have the same intended path semantics, which final-byte tests must establish.

## 7. Required post-release verification and paired scope

The following checks define the required implementation verification. The readiness probes did not complete them. The subsequent [frozen implementation](IMPLEMENTATION.md) and [actual evidence](implementation-evidence.json) now prove the focused checks on the final edited source; final aggregate and native acceptance remain pending:

- Run the same literal/decoy matrix against the actual changed helper on Windows 7 and Linux 7. Include both ordinary and LocalOnly modes, plain/backtick/bracket paths, and Linux `*`/`?` paths with decoys. Assert exact target identity/count and no leaked breakpoints or receipt variables.
- Preserve the original helper as the negative control: bracket cases must fail, and wildcard paths with decoys must not pass the corrected target assertions. Do not weaken the expected failures to make the new test green.
- Execute the existing persistent clock control block, including missing/duplicate/inactive anchors, primary-error preservation and ordinary uninstrumented clock behavior after cleanup. Verify the new bracket/decoy control fails on original helper bytes and passes on changed bytes.
- Re-run the bounded R4 transport probes using the **actual new helper bytes** on both platforms. Record new payload/full-command lengths, literal round trips and original native refusal. The old R4 headroom result remains historical; do not reuse its old helper hash for the new source.
- Parse/analyze the changed file. Execute selected actual author-finalization and capacity focused controls once against final source, preserving C97's installed checker and current/delayed/proposed/worktree/staged/invalid semantics. Root coordinates final aggregate so the worker does not duplicate it.
- Freeze the final source, report hashes/native exits/limits, and let root perform aggregate, metadata endpoints, commit/current reviews/CI and native acceptance. No result here replaces those gates.

This is common A21 fixture behavior. No Terraform language-only exception applies. After TF acceptance, the eventual PS carryback must include this helper correction and persistent regression with the existing R1 common repair; preserve the sole historical T1/P1 provenance path exception. No additional R4 transport change is indicated. Runtime/dependency archives remain unchanged because this proposal changes only the SelfTest source.

The readiness probes remain historical evidence on the original source. Root verified their sampled hashes, all ten score totals, exact repaired target/count and cleanup rows before release. The single-file implementation is now frozen as SHA256 `0f0abc0b9f84b6f5863a823e4c0f277cc479b207cabc240c8a62e1a92dc6f64e`. Actual Windows/Linux matrices, persistent negative controls, transport controls, author/capacity fixtures and final guards passed. [Independent focused quality](../../A06/TF-implementation/final-quality/R5-focused-binding.md) found no material issue and resolved both prior evidence observations. The first prior-day scratch run remains failed and uncredited; its corrected next-day author run passed on both platforms without another product edit. Root staged the sole repair as tree `0fe10c22e777dba76ce7511def2216bd2ec3b996` and started aggregate25941. Actual committed endpoint/current-audit checks, new-input reviews/CI/final binding, normal TF acceptance and actual paired carryback remain required. No new owner approval is needed.
