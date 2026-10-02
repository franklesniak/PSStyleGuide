<!-- markdownlint-disable MD013 -->
# F9: check Git failure before normalizing example output

Status: implemented; six focused command cases, scoped guide audit and final normal aggregate pass.

## Validation and stakeholders

Copilot5395257580 lists a previously missed low-severity suggestion on CONTRIBUTING's finalization example. Its native Git command may produce no stdout when HEAD or origin/main cannot resolve. Calling Trim on that null output precedes the intended LASTEXITCODE guard. An actual empty Git fixture confirms default Continue emits the null-method diagnostic then the friendly candidate-head guard; Stop terminates at the null-method diagnostic and misses the guard. See reproduce.ps1/log. This is command robustness and diagnostic quality, not an authority bypass or universal claim that the guard never runs.

New contributors, maintainers, Windows/PowerShell users, agents copying the documented command and reviewers need clear failures without changing finalization/base authority. CI/history consumers need the same exact endpoint values. No privacy, cloud, credentials, external service or localization contract changes.

Hard constraints: preserve the native failure, exact HEAD/accepted-base resolution, existing worktree and prerequisites sequence, accepted-code execution, first-install limitation and finalization evidence semantics. No fallback revision, suppressed failure or new approval step.

## Options and rubric

N: no change. B: capture Git stdout as a string, check LASTEXITCODE, then Trim. C: cast to string before the current inline Trim. T: wrap the complete example in a broad try/catch. R: remove the example. H: introduce a reusable revision-resolver helper/public command. B/C are both small; B preserves explicit failure-first execution and avoids manipulating failed output.

Fresh0–5 rubric: correct diagnostics40; contributor usability25; authority preservation20; maintenance10; cost5. Total=sum(weight*score)/5.

| Option | Diagnostics40 | Usability25 | Authority20 | Maintenance10 | Cost5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 1 | 2 | 5 | 5 | 5 | 53 |
| B | 5 | 5 | 5 | 5 | 4 | 99 |
| C | 4 | 4 | 5 | 5 | 5 | 87 |
| T | 3 | 3 | 3 | 3 | 3 | 60 |
| R | 1 | 1 | 4 | 4 | 5 | 42 |
| H | 5 | 4 | 5 | 2 | 1 | 85 |

N leaves misleading output. C avoids null dereference but retains output processing before failure handling. T risks masking unrelated errors. R removes the actual supported caller. H adds a public abstraction for two simple statements. B is the smallest clear failure-first command sequence.

## Selection and verification

Select B. Assign each rev-parse result to its existing string variable. Test LASTEXITCODE immediately. Keep the existing explanatory throw. Trim only after success. Change only those statements in CONTRIBUTING; do not add metadata to this optional no-header Tier2 document.

Run the actual extracted acquisition statements in disposable Git fixtures under Continue and Stop: missing HEAD, valid HEAD with missing accepted-base ref, and both valid refs. Require the intended diagnostic without a null-method error on failures and exact commit strings on success. Do not execute worktree creation or actual finalization in this focused guide probe. The unchanged actual validator B/H tests cover that separate contract.

After the edit, audit the affected guide region against the documented authority/prerequisite/finalization sequence and documentation placement conventions. Record that scoped audit here. Include the guide in the one combined final normal pre-commit; parent owns publication and final native endpoint verification.

## Scoped guide-contract audit

The edited region retains the existing prerequisite to refresh and resolve the real accepted destination base, run accepted code from its detached worktree, install its locked dependencies, and bind finalization to the exact committed candidate. The initial-install limitation, later no-context verification, unchanged-input evidence reuse, and absence of automatic remote authority remain explicit. Only native output acquisition order changed. The example remains a PowerShell code fence in the existing section; CONTRIBUTING retains its valid optional no-header classification. No protected instruction, normative style-guide source, cross-reference rule, metadata placement, or version convention changed.

The extracted current statements passed missing-head, missing-base, and both-valid cases under Continue and Stop (guide-probe.ps1/log). Both failures retain the intended native-failure diagnostic without null-method noise. Both successful cases return the exact private fixture commits. These checks do not claim to rerun the unchanged worktree/finalization sequence or a native remote gate.

Combined normal pre-commit session72653 passed all10 hooks on final tree6223b82bced692b5eb32e31bcbc5fd11447015f8 at2026-10-02T19:35:21.3724355Z. Final readback confirms the guide blob229ad5e4b109d1d7c1d47e35d7a305dcbdc00e2b, mode100644 and no unstaged changes. One earlier aggregate stopped on an unrelated new SelfTest scope fixture; its one-line correction left guide and production bytes unchanged. Parent now owns normal commit/publication and native exact-endpoint validation.

## Committed candidate

Normal product commit `8b6c1da46b568cb3b44e60fc511a03ac1fc4edf0` preserves the validated tree `6223b82bced692b5eb32e31bcbc5fd11447015f8`. Actual proposed-code finalization and classification passed with B `48f4d8a36c8faceee12afac78aaecea0d176125d` and H equal to this commit; finalization captured UTC2026-10-02. The accepted-base fixture retained its HEAD and exact staged candidate tree with no unstaged changes. These checks do not establish already-installed native enforcement. [Whole-PR quality](F7-F9-quality.md) records independent source review and final evidence reconciliation; current remote review/CI and merge gates remain separate.
