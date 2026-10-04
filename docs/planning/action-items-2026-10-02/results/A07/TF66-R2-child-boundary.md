<!-- markdownlint-disable MD013 -->
# R2: validate the outer Markdown child before execution

Status: selected B97.6 before implementation. Private repair and targeted validation are released; no repair pass, product integration or native acceptance is claimed.

## 1. Validation and materiality

[Codex comment4178502047](https://github.com/franklesniak/TerraformStyleGuide/pull/66#discussion_r4178502047) points to `lint-markdown.mjs:16` on exact H `e2f0652654ef0954e17fc3a255b87375908d0521`. The adapter obtains a child path from its `root` argument, calls `statSync(child).isFile()`, then passes the path to the real bounded Node child runner. `statSync` follows a leaf symlink. A normal leaf reached through an escaping ancestor link also passes. The invoked bytes can therefore be outside the selected repository. This contradicts the selected ordinary-file/path boundary; it is a material executable validation defect.

The private reproduction imports the unchanged raw H adapter and NpmTools module. Its selected children only print `PRIVATE_CHILD_EXECUTED:` plus their actual filename and exit0. There is no network, credential use or external application access. Every host fixture is under this private findings directory; Linux uses an isolated temporary directory in the existing read-only, network-disabled image. Full reproduction commands, platform/runtime, paths and results are retained in [Windows command/log](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/implementation/round1-review-findings/reproduce-links-windows.json), [Windows native details](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/implementation/round1-review-findings/native-links-win32.json), [Linux command/log](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/implementation/round1-review-findings/reproduce-links-linux.json) and [Linux native details](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/implementation/round1-review-findings/native-links-linux.json).

| Actual native case | Windows24.18.1 | Linux24.18.1 | Meaning |
| --- | --- | --- | --- |
| Ordinary regular child | Marker executed; status0 | Marker executed; status0 | Valid baseline. |
| Leaf symlink to private sibling outside root | Marker executed; status0 | Marker executed; status0 | Actual escaping leaf defect. |
| Leaf symlink to another private file inside root | Marker executed; status0 | Marker executed; status0 | Current check does not establish a non-symlink leaf. |
| Workflows ancestor junction/directory symlink outside root | Marker executed; status0 | Marker executed; status0 | Leaf-only repair is insufficient. |

All four cases used real children and links; none was skipped. The outside directory deliberately shares the `repository` name prefix, so a raw string-prefix test would not prove containment. Windows external leaf `lstatSymbolic=true`, ancestor leaf `lstatSymbolic=false`, and both `statFile=true` demonstrate the different mechanisms. The native logs show actual marker execution, not merely a mocked spawn callback. Windows log SHA256 `5b654b63967b842fd3bba4cbde5cd6c5aec7d821d84d0c56bba71dbddafa845c`; Linux log SHA256 `f0540d9d8309e0d6f1d150d909b06cc417e4c0a18c827f0130b2c3f3f0fbd4f4`.

Existing boundaries matter. `lint-nested-markdown.js:54–73` already uses leaf `lstat`, canonical paths and component-aware relative containment for Markdown/configuration data. Importing that helper from the unchecked child would execute/load the child before proving its boundary. `NpmTools.mjs:40` has a private bounded ordinary-file reader, but it lacks ancestor containment and is not an exported child-execution interface. `lint-staged-markdown.mjs:109/129` loads its own trusted relative module; it is not the reported exported adapter's separately selected-root child guard. Nested `node lint-nested-markdown.js` is itself a trusted entry point. The proposed fix is not a general module loader or repository sandbox. Existing caller paths are package `lint:md`, the Husky outer phase, and Invoke-MarkdownLint's outer phase; the CI and hook then also run nested lint.

The [A14 retained assessment](C:/Users/flesniak/GitHub/PSStyleGuide/docs/planning/action-items-2026-10-02/results/A14/RESULT.md) and complete [D92/D93 native decision](https://github.com/franklesniak/PSStyleGuide/issues/155#issuecomment-5943334454) concern generator/verifier competing-writer and alias residuals, plus retired P1A consumers. This reproduction establishes a new static failure in a current lint caller without admitting a competing writer. It justifies this narrow repair; it neither reactivates retired helpers nor closes PS155, repairs publication/cleanup races, or claims universal Windows alias identity. A14's no-trigger conclusion remains scoped to its named unchanged consumers.

## 2. Stakeholders and hard constraints

Contributors, documentation authors and local agent operators need the lint command to run the intended child with unchanged flags and useful errors. Windows junction/symlink users and Linux CI operators need a check that works on their native path semantics without rejecting a valid repository root alias. Security engineers and accountable security owners need static escape rejection with explicit residual limits; privacy/data owners need no invented claim that all inherited user authority is confined. QA and independent reviewers need native-link negatives proving that a refused child never runs, plus ordinary-child/status controls. Node maintainers and repository maintainers need native APIs and a small understandable boundary, not another dependency or general loader. UX/localization readers need actionable tooling errors. Business/CI owners need bounded execution and low recurring overhead. Cloud recovery, Terraform state mutation and publication administrators receive no new operation, privilege or credential interface here; no recovery or settings approval is implicated.

Hard constraints: reject a symbolic-link or nonregular leaf and a canonical child outside the selected canonical repository before the child runner; preserve the Node version gate, `--outer`, bounded runner, cwd behavior, output and 0/1/2 semantics; keep valid regular children usable on Windows/Linux; preserve all meaningful existing tests; do not load the unvalidated child to obtain its validator. Do not assert protection against concurrent path substitution, hardlink aliases, malicious replacement of already trusted modules or arbitrary same-user code. A score cannot waive these constraints.

## 3. Options before scoring

| Option | Action and tradeoff |
| --- | --- |
| N | Keep the check and document the residual. No runtime churn; leaves the reproduced static boundary false. |
| L | Replace stat with leaf lstat/non-symlink regular validation only. Small; the real ancestor-link reproduction still passes. |
| C | Check canonical root/child containment only. Blocks external resolution but still permits symbolic-link leaves inside root and does not express the complete ordinary-file rule. |
| B | Combine leaf lstat/non-symlink regular validation with canonical root/child containment; pass the checked canonical child to the existing bounded runner. Add focused native-link tests in the retained suite. |
| S | Reject every linked ancestor component as well as the leaf. Strong static refusal; needlessly rejects in-root directory/root aliases and creates more path-walk rules. |
| F | Factor a pure common boundary helper into NpmTools or a new module, then use it here and migrate other suitable callers. Can share logic; creates a broader public/import coupling without a second identical child-selection consumer. |
| G | Require tracked Git regular-file mode and exact blob identity for the child before running it. Adds Git/revision prerequisites, rejects ordinary source-archive or evolving-worktree use, and remains path-based at execution. |
| H | Replace pathname execution with a retained-descriptor/in-memory execution scheme. Potentially addresses a different race window, but changes module resolution and platform behavior and lacks a proved portable Node implementation for this whole contract. |
| R | Remove the adapter or run the nested child directly. Removes the failing check rather than supplying its guarantee; loses the selected bounded outer interface. |

B is the useful combination of L/C and native tests. Importing `validateMarkdownInput` from the child before checking it is excluded by the hard constraint; factoring its pure logic elsewhere is F. A static digest allowlist is G-like identity coupling without a complete lookup-to-exec race solution. B plus a new dependency, custom permissions or broad recurring filesystem matrix adds no required static guarantee. Delaying the same repair is scheduling, while indefinite deferral is N. Removal plus another wrapper restates B/F rather than a distinct improvement. No option recreates the retired P1A code.

## 4. New finding-specific rubric

Scores0–5 mean absent, weak, partial, useful with limits, strong, and fully supported for the scoped static guarantee. Total is sum(weight times score/5), out of100. These are design judgments, not measured probabilities. Correctness and the concrete security boundary receive60%; meaningful evidence, portability and usability receive35%; maintenance/convenience receives5%.

| Criterion | Weight | Finding-specific meaning |
| --- | ---: | --- |
| Static child identity and containment | 40 | Refuse both reproduced escape mechanisms and the nonregular/non-symlink boundary before execution. |
| Correct runtime behavior | 20 | Preserve valid root/child use, Node selection, child arguments, cwd, limits, output and statuses. |
| Discriminating verification | 15 | Support actual native-link, no-child-execution, ordinary-child and failure-propagation controls. |
| Portable and truthful limits | 12 | Use available Windows/Linux APIs and distinguish static checks from races, hardlinks and module trust. |
| Operational usability | 8 | Produce a clear tooling failure without new contributor setup, permissions or invocation modes. |
| Proportionate maintenance | 5 | Minimize duplicated interfaces and unrelated migrations; effort cannot dominate the first five criteria. |

## 5. Scores before selection

| Option | Identity40 | Behavior20 | Tests15 | Portability12 | Usability8 | Maintenance5 | Total | Main limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 0 | 5 | 1 | 5 | 1 | 5 | 41.6 | Does not close the static defect. |
| L | 2 | 5 | 3 | 5 | 4 | 5 | 68.4 | Ancestor escape remains. |
| C | 3 | 4 | 3 | 5 | 4 | 5 | 72.4 | Symbolic-link leaf remains admissible. |
| B | 5 | 5 | 5 | 4 | 5 | 5 | 97.6 | Path lookup-to-spawn race remains outside this claim. |
| S | 5 | 3 | 5 | 4 | 3 | 4 | 85.4 | Rejects useful contained aliases. |
| F | 5 | 5 | 4 | 4 | 4 | 3 | 91 | New helper/caller coupling must be qualified. |
| G | 4 | 2 | 4 | 3 | 2 | 2 | 64.4 | Adds Git authority/interface; still path-based. |
| H | 5 | 1 | 2 | 1 | 1 | 0 | 54 | Portable complete runtime behavior is unproved. |
| R | 0 | 0 | 0 | 5 | 1 | 4 | 17.6 | Removes required guarantees/interface. |

N/L/C/R cannot close the hard constraints; H is not an implementable qualified replacement today, and G changes supported use. F is feasible but has no demonstrated second consumer requiring this factoring. B has the clear lead among proportionate complete repairs. [score-verification.json](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/implementation/round1-review-findings/score-verification.json) supplies arithmetic checks.

## 6. Recommended selected instructions

Select B97.6. Root completed the ordered decision sequence before release.

1. Keep the current Node version check.
2. Read the child leaf metadata with `lstatSync`.
3. Reject a symbolic link or a nonregular file.
4. Resolve the repository root and child path with `realpathSync`.
5. Calculate the child path relative to the canonical root.
6. Reject an absolute result, `..`, or a result that starts with `..` and the platform separator.
7. Pass the checked canonical child path to the current bounded runner.
8. Keep `--outer`, the existing cwd and the current output/status rules.
9. Add the focused tests below to the retained lint suite.
10. Preserve the stated race and module-trust limits.

These short instructions follow the owner's controlled-English intent; no formal ASD-STE100 dictionary certification is claimed.

## 7. Proposed scope and validation; not executed repairs

Likely product paths: `.github/workflows/lint-markdown.mjs` and `.github/workflows/lint-markdown.test.mjs`. R1 separately supplies its already selected workflow caller. No dependency, manifest, protected-policy, general filesystem helper or retired consumer needs a change for this option.

After release, test actual external leaf links and escaping ancestor links on Windows/Linux; require a tooling error and prove the benign external marker did not execute. Test an in-root symbolic-link leaf, directory leaf, missing/broken child and failed lookup; preserve useful diagnostics and no runner invocation. Keep a normal regular child and a contained root/directory alias positive. Include a same-prefix sibling escape and component-aware containment cases; do not advertise a different-drive/UNC native test unless that environment actually runs. Keep the existing status1/status2/unexpected exit, timeout, output limit and version-mismatch tests. Run the complete retained Markdown suite once on each available supported runtime, plus R1's affected workflow-role/native-failure tests. The before-repair probes above are validation of the finding, not tests of a repair. No full suite or duplicate review was run during this proposal task.

Primary API references: Node24.18.1 [lstatSync](https://nodejs.org/download/release/v24.18.1/docs/api/fs.html#fslstatsyncpath-options) inspects the link itself; [realpathSync](https://nodejs.org/download/release/v24.18.1/docs/api/fs.html#fsrealpathsyncpath-options) returns a resolved path; [path.relative](https://nodejs.org/download/release/v24.18.1/docs/api/path.html#pathrelativefrom-to) gives platform-specific relative components. These APIs support the static check, not an atomic execution guarantee. Native reproduction and exact source, not a documentation assertion, establish the current failure.

## Coordinator selection and execution boundary

Root read this full proposal and the actual source, verified the cited private log hashes, recomputed every weighted total, and displayed options, the distinct rubric, scores and selected instructions in that order before release. This is the canonical selected decision; the linked private proposal is retained historical evidence. One writer is released for private postimages and focused tests only. Product integration, final validation, native review and acceptance remain due.
