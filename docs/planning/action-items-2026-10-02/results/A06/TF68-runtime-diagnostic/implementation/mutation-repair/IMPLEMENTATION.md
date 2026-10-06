# Finalization mutation repair

The SelfTest now constructs both date mutants from the parsed, named arguments in the two actual document dispatch calls. Construction runs before the fixture creates directories or commits. It requires exactly one target argument per endpoint, verifies the original document member expression, replaces two distinct argument spans in descending order, rejects an unchanged result, and parses the result again. Function-local decoys are excluded. Actual caller assertions, the clock helper, production checker, and other mutation families are unchanged.

The selected option is the root-approved parsed-argument repair (94.5), recorded in `ROOT-MUTATION-REPAIR-RELEASE.json` and canonical `MUTATION-REPAIR.md`. This record does not authorize another execution.

## Frozen source

- Only `.github/workflows/Test-AgentInstructions.SelfTest.ps1` changed during this repair: preimage `bc758e553ef32a82204aefb238ce4f95a1a3fd0c69de74fa337076077acb2c31`; final SHA256 `1fe8a9b289505421cf207be24a880b0b1dfa8edf97405219babb7a3a20d4c3b9`.
- Main checker remains SHA256 `9ca8f6ab530f4e1f30a9745d38a4f70d94d48016565e568d15b4a02b4b85b011`. Its previous focused checks and original/changed timing remain historical valid evidence.
- Complete candidate: 80 paths, prospective tree `414509ef0a5f6db3cceab5e6b720fbcbcb3cb4ad`, over published H `5ec4bdc06431de05e93067b0e52f0dfbb1631392`; accepted B remains `e21b74fe0b56551008f78f9f2946cd2a0f9c19ce`. No host index/ref/config mutation was performed.

The author fixture remains version `1.1.20261006.0`: accepted B has `1.0.20261003.0`; H's earlier `1.1` is part of this unmerged change. The applicable PowerShell policy is `C:/Users/flesniak/GitHub/PSStyleGuide/STYLE_GUIDE.md`, lines 1025 and 1038, which uses the version on the landing branch and excludes cumulative work-in-progress increments. The draft `1.2` was corrected. New helpers have `1.0.20261006.0`; the existing script version remains `1.11.20261006.0`.

## Completed bounded checks

All execution below used qualified Windows PowerShell 7.6.5. The evidence JSON records complete argument arrays and native exits.

1. Final-byte constructor proof: exit 0. Persistent tests cover missing targets, duplicate commands and parameters, absent arguments, incorrect owner expressions, method calls, already altered arguments, no-op construction, malformed source/output, formatting and colon-bound parentheses, extra arguments, comments, and function-local decoys. Actual checker outputs equal an independent two-member extent replacement oracle for each mutant. The original text substitution is proven ineffective on the current source. The checker is never executed by this proof.
2. Full-file parser and PSScriptAnalyzer 1.24.0: exit 0, no parser errors and no warning/error diagnostics for final SelfTest and unchanged main. Native session 43427 is terminal.
3. Prepared PowerShell driver parsing and Python AST parsing: passed. These checks do not execute the fixture.

Two actual private mutant hashes are `c3eb786a6e8d99ae9fcc6e8f79c9a77fa03dbdccbd61bfc7eea3f4e088c1b553` (require-date off) and `34c062acbb7dc55d982c37a4c6b3ee178cc8a05bab3f4cabf58e53f492d41178` (initial-coverage date requirement). Each differs from the checker only at its two intended argument extents.

The first scratch application script stopped at a pre-write assertion because a function declaration inside fixture text was mistaken for the outer function boundary. Its script and error are preserved. No product write occurred in that attempt. Draft metadata-byte constructor and analyzer results are separately preserved and not represented as final-byte proof.

## Prepared real-caller proof — execution not released

`manifest.prepared.json` has `execution_authorized=false`. `prepare-six.ps1` extracts the actual fixture setup through installed baseline and package materialization, the actual promotion/versioned fixture construction, two repaired mutation controls, and original cleanup. It proves exact prefix restoration after removal of the declared native adapter and exact original `finally`. The actual clock helper is loaded unchanged from final source. No production clock override, oracle change, or retained-source instrumentation is introduced.

The selected six children are:

| Case | Actual caller | Expected native exit |
| --- | --- | ---: |
| 1 | Ordinary promotion, delayed rerun | 0 |
| 2 | Prior-day rendered guide, finalize now | 1 |
| 3 | Same prior-day guide, delayed rerun | 0 |
| 4 | Current-day rendered guide, finalize now | 0 |
| 5 | Repaired require-date mutant, prior-day guide, finalize now | 0 |
| 6 | Repaired initial-coverage mutant, delayed promotion | 1, caught by the existing mutation oracle |

The ordinary validator bootstrap is separate from these six children. The fixture reconstructs the same semantic cases with fresh private B/H identities; it cannot replay the deleted prior run's ephemeral objects. Child argv, cwd, clock, checker hash, native status, and separate raw stdout/stderr are retained. The original regex assertions see concatenated raw streams; cross-stream ordering is not preserved. There is a 45-second child bound, 210-second parent bound, and 240-second container bound, with owned-process cleanup.

The prepared runner reuses the qualified offline image and all 1914 dependency bytes. It binds all 80 source paths, physical HEAD/index/config/config.worktree, full refs, and dependencies before and after on host and private repository. Only the disposable repository is staged. Its approved Husky executable-bit adaptation changes no package bytes. No installs, network access, actual author test, full suite, CI request, or peer work has run in this repair packet.

Root must review and release the concrete manifest before execution. The complete SelfTest and mandatory final all-files gate remain pending under root coordination. The prior failed aggregate directory remains untouched. The previous 600 Node tests and timing measurement are not repeated.
