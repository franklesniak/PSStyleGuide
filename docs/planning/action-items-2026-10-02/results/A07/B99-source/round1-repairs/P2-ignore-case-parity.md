# PR236 P2 — Align ignore hygiene with case-insensitive compiled names

## 1. Validation and authority

**Material finding confirmed by source inspection and the root-owned native Git reproduction.** Codex review5440089267/comment4205074649/threadPRRT_kwDOQkjdhM6p1T5k refers to H64df5d77043b3e3d019b7d4d704635bd97598293. Current .gitignore22–23 contains only `__pycache__/` and `*.py[cod]`. Get-TrackedCompiledPythonFailure uses the case-insensitive cache-component/suffix predicate; the current SelfTest explicitly expects uppercase variants to fail. A case-sensitive Git match therefore has a hygiene gap for uppercase and mixed-case artifacts. The reviewer reports native exits1 for uppercase examples; this report distinguishes that external observation from our unexecuted private probe.

Git patterns can match files and directories; a trailing slash restricts a pattern to directories. Bracket expressions provide case pairs, and the last matching rule wins. A broad suffix pattern can therefore hide ordinary directories that merely end in .PYC and their legitimate descendants. A directory-only negation can preserve them without unignoring a suffix-named symlink. The precise native link behavior is a required control, not an asserted executed result. [Official Git ignore rules](https://git-scm.com/docs/gitignore).

Existing personal-memory admission adds a concrete ordering constraint: Test-RecursivePersonalMemoryIgnoreContract5350–5405 invalidates an earlier canonical CLAUDE.local.md rule after any later negation. Its real main call and private ignore checks remain unchanged. Put the new compiled-name block before the existing canonical personal-memory rule. Do not alter public instruction files or weaken this invariant. C99.4's canonical .gitignore restoration after oversized-input cases must continue to use the full revised file in the index and later optional-absence revision.

Selected D98.4 prohibits **tracked names** across modes and absence states. Ignore rules are worktree hygiene, not a replacement for complete-index/exact-H enforcement; they cannot grant an exemption for a forced tracked artifact. A gitlink with a forbidden suffix still fails the unchanged name predicate even if a directory exception makes its worktree directory visible. This decision aligns ASCII spelling coverage and preserves ordinary directory contents; it does not claim Git ignore can inspect every absent indexed mode as the validator does.

## 2. Stakeholders

Contributors should not see or accidentally add local compiled artifacts, regardless of case. They must still see legitimate source in suffix-named directories, near matches and public CLAUDE.md files. Security/privacy owners require private CLAUDE.local.md to remain ignored after every negation and forbidden tracked links to remain rejected. Windows/Linux maintainers need repository-contained patterns, not global Git or filesystem settings. CI/review owners need explicit native file/directory/link evidence and durable tests of ordering. Maintainers need a small readable policy without enumerated spelling drift. None of these stakeholders gains from weakening the existing mode-independent name guard, deleting user files or changing public protected instructions.

## 3. OPTIONS — before scoring

- **A: Keep lowercase rules.** Upper and mixed cases remain visible.
- **B: Add only all-uppercase variants.** Mixed cases remain visible.
- **C: Two case-complete bracket patterns.** Also hides legitimate suffix-named directories and their children.
- **D: Case-complete rules plus directory-only exception before personal-memory rule.** Selected; native directory/link distinction must be qualified.
- **E: Enumerate every ASCII case spelling and directory exception.** Correct but large duplicated list with avoidable update risk.
- **F: Force ignore-case through Git or filesystem settings.** Ineligible authority and portability change.
- **G: Make validator case-sensitive instead.** Ineligible weakening of selected filename-wide policy.
- **H: Remove hygiene rules and rely on rejection.** Does not fix ordinary status/add experience.
- **I: Add a cleanup or generated-ignore helper.** Additional execution/write boundary; plain Git behavior still depends on generated rules.

C plus a directory-specific negation is D. D with full spelling enumeration is E. A helper that generates D adds a write/runtime boundary without changing its semantics and is I. Case-insensitive filesystem behavior alone is not portable evidence; F cannot authorize settings changes. Deferring while frozen is available but does not resolve this finding. No ordinary directory exception may become an exemption from tracked-name enforcement or from cache-directory descendants.

## 4. RUBRIC — distinct weights and hard limits

Scores0–5 use the same fit scale but this finding has different criteria and weights. **Coverage34** covers lower/upper/mixed spelling of all three suffixes and cache-directory components at each depth while retaining the existing final name authority. **Usability26** preserves ordinary suffix directories, near matches and normal status/add behavior without manual cleanup. **Security18** protects private-memory ordering, suffix links and force-added artifact refusal without settings/privilege changes. **Compatibility11** fits existing Git/native-platform behavior and current validator/SelfTest/C99 obligations. **Proof8** allows real file/directory/link controls and negative pattern/order mutations. **Cost3** measures pattern size and ongoing maintenance. Weights total100. Weakening filename-wide rejection, changing user settings, losing private-memory protection or relabeling unavailable Windows symlinks as passed is ineligible regardless of score.

## 5. SCORES / SELECTION

| Option | Coverage34 | Usability26 | Security18 | Compat11 | Proof8 | Cost3 | Total /100 | Main tradeoff |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 1 | 2 | 5 | 5 | 2 | 5 | 52.4 | Upper and mixed cases remain visible |
| B | 2 | 3 | 5 | 5 | 3 | 5 | 66.0 | Mixed cases remain visible |
| C | 4 | 4 | 5 | 5 | 4 | 5 | 86.4 | Also hides legitimate suffix-named directories and their children |
| D | 5 | 5 | 5 | 4 | 5 | 4 | 97.2 | Selected; native directory/link distinction must be qualified |
| E | 5 | 4 | 5 | 3 | 4 | 1 | 86.4 | Correct but large duplicated list with avoidable update risk |
| F | 4 | 2 | 1 | 1 | 2 | 4 | 49.0 | Ineligible authority and portability change |
| G | 1 | 3 | 1 | 2 | 3 | 5 | 38.2 | Ineligible weakening of selected filename-wide policy |
| H | 1 | 1 | 5 | 2 | 2 | 5 | 40.6 | Does not fix ordinary status/add experience |
| I | 4 | 3 | 3 | 2 | 4 | 1 | 65.0 | Additional execution/write boundary; plain Git behavior still depends on generated rules |

**Propose D97.2**, the unique highest score. C86.4 fixes the reported case gap but expands the directory-hiding side effect; D explicitly tests and preserves those legitimate paths. E is semantically complete but requires many independently maintained spellings. D retains a4 compatibility score because ordering and directory/link distinctions require native qualification; its score is not evidence that those tests already passed.

## 6. Selected controlled-English steps

1. Keep the old source and evidence unchanged. Use the selected repair after the root selection recorded below.
2. Replace the old compiled-artifact block with the following block. Put it at the end of the file. Move the existing personal-memory comment and CLAUDE.local.md rule intact after it. Keep all other ignore lines in their original order.

   ```gitignore
   # Local compiled Python artifacts must remain untracked.
   *.[pP][yY][cCoOdD]
   !*.[pP][yY][cCoOdD]/
   __[pP][yY][cC][aA][cC][hH][eE]__/
   ```

3. Keep the cache rule after the directory exception. It must still hide cache descendants inside a suffix-named directory. Keep the canonical personal-memory rule after all negations.
4. Change the setup contract and its SelfTest to require these four final operative rules in order. Allow comments and blank lines. Require each compiled rule once. Reject operative rules after this block. Other ignore patterns can change before the block. Do not bind those unrelated patterns to a new schema. Preserve the independent personal-memory contract and existing effective native controls.
5. Keep Get-TrackedCompiledPythonFailure and complete target inventory behavior unchanged. A forced indexed artifact must still fail, even when ignored or absent.
6. Add native Git controls for actual files, actual directories and actual symlink-to-directory names. On Windows, use only qualified capability; record unavailable materialization honestly and retain Linux real-link proof. Do not request privileges or settings changes.
7. Preserve legitimate near matches, standalone cache-named files, private-memory exclusions and public instruction visibility. Preserve canonical-index restoration after the65537-byte ignore test and subsequent optional-input cases.
8. Keep source changes within .gitignore and the two current validator scripts. Use ordinary metadata/version handling and independent final-byte quality before a normal new-head commit/review cycle.

These short instructions are not formally certified ASD-STE100 text.

## 7. Bounded reproduction and final obligations

REPRODUCTION.md and probe-native-data.py compare the old rules, C and D in a fresh tiny private Git repository with core.ignoreCase=false per command. They do not mutate a product repo or global config. Outputs distinguish native0 ignored/native1 visible and actual file/directory/link identity. Required negatives include `module.pyc.txt`, `safe.py`, `standalone/__pycache__`, `__pycache__-source/entry`, `bundle.PYC` and `bundle.PYC/readme.txt`. Required protected/forbidden positives include nested mixed-cache artifacts, mixed suffix files and real link.PYC. Public CLAUDE.md remains visible and private CLAUDE.local.md remains ignored at root and depth. No native run occurred in this proposal.

The final changed-contract tests should cover each suffix/case family (all24 suffix spellings are finite) and all128 ASCII case spellings of the seven cache letters through native pattern matching or a justified finite matrix, including nested paths and cache-under-suffix-directory. Do not imply that a Git pattern proof covers mode/absence states; reuse unchanged D98.4 complete-name evidence at its exact scope and preserve a force-added enforcement control. Negative tests should remove a case pair, move the negation after personal memory, and remove/reorder the cache or directory-exception rule so that real outcomes catch weakened hygiene. Root supplies finite counts/bounds before executing changed tests; no new framework is needed. Final integrated source tests, ordinary aggregate, B/H endpoints, independent quality and both new-head reviews/CI remain separate. A07/A21 transfers7/12 and the original2026-10-15T08:55:16Z round1 deadline do not change.

## Root selection and executed reproduction

Root displayed the options, distinct rubrics, complete score tables and selected instructions before releasing source edits. Both recommendations are selected under the existing owner authority; no new owner decision is needed. The original preparation statements above describe what the author had not executed, not the current reproduction status.

The bounded Windows reproduction ran from 2026-10-07T09:29:31.357696+00:00 to 2026-10-07T09:30:27.847806+00:00. PowerShell7.6.5, Python3.12.10 and native pre-commit4.6.2 used bound runtime and source hashes. Both private setup stages and both probe stages exited0, with every owned Job empty and no cleanup signals. Source, dependency and runtime guards passed. The actual original setup contract accepted the canonical configuration and all nine behavior mutations; native pre-commit parsed all ten. Git recorded60 outcomes for three rule variants, including a real symlink to a directory. The selected pattern variant kept all tested legitimate paths visible and all tested artifact/cache/private-memory paths ignored. The two-pattern alternative hid the ordinary suffix-named directory and its child.

Commands and bounded raw results are identified by [the selection record](selection.json). Full executable hook runs were not part of this reproduction. Independent Linux reproduction also passed: all60 Git outcomes and all10 native schema mappings match Windows, including a real Linux symlink. See [the independent report](linux-reproduction/REPORT.md). Final repaired-source validation remains unfinished. Source changes are limited to the existing three PR paths. No staging, commit, push, merge, new review request, deadline reset or transfer increment is released by this record.
