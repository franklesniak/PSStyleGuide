<!-- markdownlint-disable MD013 -->
# A03-D13 selected decision: isolate setup validation mutations

Status: P96 selected after root review and the required user-facing display. Private implementation is active; no product repair is integrated yet. Preserve D6, D8, D9 including F97, and D11. Root owns integration, product/index/refs, planning records and native operations.

## 1. Validate the finding and its limits

Authenticated automatic Codex review5405665141, bot199175422, comment4177245994, threadPRRT_kwDOQkjdhM6oxlPB, created2026-10-04T11:18:12Z, names exact PS head69e1b0d1b0715bfc4025372c7282fe04c38178dc/treeecae3f224ffa53e007ea7f14614f3c8596671648 and basefb3288934215dfa9a25114cf79ad86e60b5fb107. The run body at workflow892 executes the actual full pre-commit command in the prepared agent worktree. The current pre-commit configuration includes two auto-fixers for ordinary docs/workflow source. Both write files and return failure when fixes are needed. The final setup_inputs array excludes README.md and other ordinary files; moreover that later step need not execute after failure.

GitHub's current primary [setup documentation](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/customize-the-agent-environment#customizing-copilots-development-environment-with-copilot-setup-steps) says a nonzero setup step skips the rest and the agent begins with the current environment. This establishes documented ordinary failure behavior. It does not establish what every cancellation, timeout or hosted service interruption does. The remedy must preserve source bytes without depending on a later cleanup step or signal trap. Ordinary Actions runs are not a separate real Copilot-session proof.

Bounded executed witness: reproduce.py captured exact Git inputs, extracted the unchanged full-validation and final-input Bash run bodies, and ran both on a new four-file private Git fixture. The config contains the actual two fixer hook mappings only; the actual repository Invoke-LockedPythonHook.ps1 is unchanged. Installed Python3.12.10, pre-commit4.6.2 and pre-commit-hooks6.0.0 match the latter two lock pins. Git Bash5.3.15 and Git2.55.0.windows.5 supplied Bash/Git; the PowerShell launcher used existing pwsh. No packages were installed. The actual caller returned1. The hooks added README.md's final newline and removed sample.mjs's trailing spaces. Both tracked raw hashes changed. Running the actual final allowlist check separately then returned0 while both edits remained. This proves caller/fixer mutation plus the allowlist gap; it is not a complete repository aggregate or Linux/hosted experiment. Running the final step manually is an oracle for its coverage, not a claim that the service would run it.

The exact command was `py -3.12 C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A03-PR231-findings-20261004/reproduce.py`. It exited0 after asserting validation exit1, final-check exit0 and both mutations. It internally executes `C:/Program Files/Git/bin/bash.exe <extracted-script>` in the private fixture. Full stdout/stderr, before/after hashes, diff and versions are retained in run.*.log, final.*.log and reproduction-result.json. inputs.json binds seven actual sampled files. The input fixture has ordinary committed content, no staged changes or credentials. The restricted hook config is declared and does not assert all11 hooks ran.

D9 requires complete useful validation and says to report drift/fail without resetting it or fabricating clean success. Restoration therefore conflicts with the prior selected design and is also kill-sensitive. Copy isolation refines the location of validation while preserving its useful checks and native failure. No evidence indicates that current clean H actually acquired fixer edits in the hosted runs; root owns those results. The demonstrated defect is for a supported acquired tree with fixable content, not a claim about those pending runs.

## 2. Stakeholders

Agent users and the owner need the eventual task patch to contain intentional task edits, and need the prepared original worktree to remain usable after setup failure. Current and historical contributors need the same complete hook selection, index interpretation, event identity, main reference and useful ancestry. Both maintainers need common PS/TF behavior without a new profile framework. QA and reviewers need a negative test that fails the old caller and a forced-stop test that does not rely on cleanup. CI/platform operators need the existing59/45-minute limits, no new download/install, and a bounded copy cost. Security/supply-chain reviewers need anonymous setup, exact inputs, copied dependencies rather than new resolution, and no writable sharing back to the agent checkout. Privacy/data owners need no token or secret copied/projected. Recovery operators need failure logs and a prepared original tree even when temporary validation state remains. The UX director needs clear messages distinguishing dependency readiness and failed validation. History/audit consumers need real refs/objects/index and truthful status; an archive-only fixture cannot provide them. Business stakeholders need restrained runtime/storage overhead and no duplicate aggregate. Generated-artifact consumers retain existing checks; no new accessibility/localization or cloud deployment interface is introduced.

## 3. Comprehensive distinct options

- N: keep validation in the agent worktree.
- G: retain that execution but broaden the final guard to all tracked files, perhaps use an always condition.
- R: save/restore the original index/worktree after validation, with traps or an always cleanup step.
- S: skip the known fixer hooks during setup validation.
- Q: replace all mutating hook implementations with check-only equivalents and maintain that property over time.
- W: create a linked Git worktree and copy dependencies into it.
- C: make a standalone full-history clone, then reconstruct exact required refs, index/config and installed dependencies.
- P: copy the already prepared standalone repository, its Git metadata and installed local dependencies into one fresh private directory with independent file storage. Run the unchanged hook set there.
- Z: remove the full setup validation run; leave dependencies and hooks installed.
- H: use a hard-linked directory copy to reduce cost.
- O: run validation against an OS/container writable overlay over a read-only prepared source.

G plus R remains restoration and cannot guarantee cleanup after abrupt stop. Adding cleanup to P is resource hygiene; source integrity does not depend on it. A plain archive/init loses history, refs, index/config and check semantics, so it is an inadequate variant of C/P rather than another eligible solution. Symlinking node_modules or .git back to the agent tree is writable sharing, not P. Read-only source permissions alone make fixer hooks fail differently and can break normal agent work; a genuine writable overlay is O. Moving validation to another ordinary workflow is Z for this service and loses the selected local full-run property. Deferral leaves N unresolved. New shared helper/config factoring only relocates C/P unless it introduces another trusted bootstrap; no such framework is needed.

## 4. Unique rubric and hard constraints

Scores1–5, larger is better. Event-tree preservation30 measures whether validation leaves original tracked bytes/index untouched. Check equivalence25 measures the same hook set, exact HEAD/index/ref/history and dependency behavior. Abrupt-failure resilience20 measures independence from cleanup on error, cancellation or timeout. Later-agent usability15 measures retained original dependencies/hooks/history plus truthful useful diagnostics. Continuing cost10 measures runtime/storage/review burden. Total=sum(weight×score)/5. These are design judgments; no proposed solution performance is measured.

Hard constraints: preserve D6/D8/D9/F97/D11; run the complete selected hook set where capability is full; keep failures nonzero without retrying the aggregate; do not reset or relabel the acquired tree; no credentials, permission increase, new installation or altered time budget; no Git/index or dependency files shared writably back to the original worktree; no dependence on a later step/trap to undo mutation. Isolation here prevents normal validation side effects. It is not a security sandbox against arbitrary hostile candidate code that deliberately reaches another path.

## 5. Scores before selection

| Option | Event30 | Checks25 | Abrupt20 | Agent15 | Cost10 | Total | Assessment |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 1 | 5 | 1 | 2 | 5 | 51 | Demonstrated contamination |
| G | 2 | 5 | 1 | 2 | 5 | 57 | Detects some drift; does not prevent it |
| R | 3 | 5 | 2 | 3 | 4 | 68 | Conflicts with D9; restoration can be interrupted |
| S | 4 | 2 | 4 | 4 | 4 | 70 | Omits selected hooks; future fixer gap |
| Q | 5 | 3 | 5 | 4 | 2 | 81 | New hook contracts and continuing mutation audit |
| W | 4 | 4 | 4 | 4 | 4 | 80 | Shared Git common directory/refs; cleanup registration |
| C | 5 | 4 | 5 | 4 | 2 | 86 | Feasible but must reconstruct metadata/config/dependencies |
| P | 5 | 5 | 5 | 5 | 3 | 96 | Recommended independent exact prepared copy |
| Z | 5 | 1 | 5 | 3 | 5 | 74 | Retires selected useful full-run check |
| H | 1 | 5 | 1 | 2 | 5 | 51 | Ordinary writes can change original inodes |
| O | 5 | 4 | 5 | 3 | 1 | 81 | New runtime/sandbox assumptions and portability cost |

P preserves the actual prepared state with fewer reconstruction assumptions than C. Its cost3 acknowledges copying Git objects and installed dependencies. Reflink support can reduce physical copy cost, but correctness must also hold for an ordinary independent copy. The exact acquired setup layout is a standalone repository; this is not a general arbitrary worktree-copy feature.

## 6. Proposed winner and direct implementation steps

Select P96 after root displays this table. Preserve complete validation and move only its working copy. The instructions follow the requested ASD-STE100 writing approach; no formal controlled-dictionary certification is claimed.

1. Keep preparation and hook activation in the original agent worktree.
2. Before validation, reject inherited Git path redirection that could send commands to another repository or index. Keep the existing credential/config checks and npm environment filter.
3. Resolve the original root and runner temporary root. Create one fresh directory under RUNNER_TEMP outside the source tree.
4. Require the acquired source to have its own ordinary .git directory. Reject a .git pointer, external common directory, external object alternates or core.worktree redirection. These checks preserve the already selected acquisition layout; do not silently reconstruct another layout.
5. Copy the whole prepared repository into that fresh directory. Include dotfiles, .git, both installed Node dependency trees and generated Husky files. Preserve modes and ordinary relative dependency links. Use separate file storage or copy-on-write reflinks. Do not use hard links, Git worktree registration, alternates, or links back to original dependency/Git directories. Reject an unsupported dependency link that resolves back into the original source rather than presenting it as isolated.
6. Verify the copy before executing hooks. Compare exact HEAD, captured origin/main, index tree and reachable history availability with the original. Preserve detached HEAD, local hook configuration and existing clean tracked input semantics. Verify that Git's root/common directory resolve inside the copy. The source checks must not refresh or write its index.
7. Run validation with the copy as the working directory. Set child GITHUB_WORKSPACE to that directory for helpers that use it. Keep GITHUB_SHA, native event payload and captured authority identities unchanged. Clear/reject Git directory, worktree, index and object redirection variables; do not let inherited path variables target the original.
8. Use the same installed Python interpreter and existing pre-commit command. Preserve all hooks and their stages/filters. Use copied Node dependencies; do not reinstall them or link them back to the original.
9. Capture the validation status in the same step. Preserve hook output. If validation changes files, identify the disposable validation copy in the diagnostic. Do not copy fixes into the source.
10. Remove only the verified temporary copy when normal cleanup can run. Preserve a nonzero validation result. A cleanup failure must not turn failure into success. Cleanup is optional for source integrity; an abrupt stop can leave only disposable validation state.
11. Keep the original preparation intact for the later agent. Preserve the final immutable setup-input check as a separate guard. Do not depend on that later step to undo or detect ordinary fixer edits.
12. Keep the59-minute job and45-minute validation bounds. Include copy/verification work inside the existing validation phase. If hosted timing fails, retain the result and evaluate that measured bottleneck.

The intended source paths remain copilot-setup-steps.yml and its existing Test-CiHelpers.test.mjs. A newly discovered need to change a helper/contract requires root coordination and a refinement here. No guide, package, lock, launcher, settings, devcontainer or protected-instruction edit is proposed.

Python/runtime boundary: current D9 creates `RUNNER_TEMP/agent-validation-python` outside the checkout, publishes its bin directory through GITHUB_PATH, and exports VALIDATION_PYTHON. Invoke-LockedPythonHook.ps1 uses application discovery on PATH (`python3.12`, then `python3`, then `python` on Linux); it does not resolve a repository-relative .venv. Keep that external prepared interpreter and PATH selection unchanged when changing cwd. Do not copy or relocate a Python venv as if it were portable, and do not add a .venv link into the original agent checkout. If a local test fixture uses .venv, invoke its existing absolute interpreter and prove launcher discovery explicitly; that fixture layout is not the hosted contract. Python documents that venv scripts use absolute interpreter paths and environments are generally nonportable: [Python3.12 venv](https://docs.python.org/3.12/library/venv.html#how-venvs-work). Shared external runtimes and pre-commit caches are retained setup infrastructure, not writable aliases to the agent repository or its Node dependencies. The proposal does not claim immutable runtime storage or an OS sandbox. Tests must preserve the prepared runtime's usability and show the launcher still selects the intended interpreter.

Primary references: [GitHub setup behavior](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/customize-the-agent-environment), [pre-commit run and mutation semantics](https://pre-commit.com/#usage), [locked final-newline fixer source](https://github.com/pre-commit/pre-commit-hooks/blob/v6.0.0/pre_commit_hooks/end_of_file_fixer.py), [locked trailing-whitespace fixer source](https://github.com/pre-commit/pre-commit-hooks/blob/v6.0.0/pre_commit_hooks/trailing_whitespace_fixer.py), [Git repository layout and common-directory/alternates semantics](https://git-scm.com/docs/gitrepository-layout), and [finding](https://github.com/franklesniak/PSStyleGuide/pull/231#discussion_r4177245994). Git layout documentation supports retaining objects/refs/index, not a claim that all hooks are path-independent. Actual caller tests must establish that separately.

## 7. Required implementation verification and current unknowns

Completed evidence is the bounded old-caller witness above, static source/caller/test inspection, primary-source research and exact input capture. No selected-remedy implementation or performance proof exists yet. Existing tests stub the suite and preserve exit37, but do not exercise mutating hooks or interruption. Extend that existing surface after root releases implementation.

Required focused checks:

1. Execute the actual revised body on a tiny real Git graph with independent event/main history. Use the actual two installed fixer hooks to prove dirty committed README and source content return failure while original raw files, index, HEAD, refs, hook files and prepared dependencies remain unchanged. Prove fixes occur only in the copy.
2. Keep a clean control and native exit37 control. Prove the complete production command is still selected once and its status survives diagnostics/cleanup. Do not run a second full aggregate merely to test dispatch.
3. Use a declared sentinel hook that edits only its current repository, records its location, then waits. Terminate the validation process group after its edit. Verify original bytes/index/dependencies remain unchanged without executing cleanup. Record this as local interruption evidence, not hosted cancellation semantics.
4. Exercise source/copy paths with spaces, pre-existing temporary destination, copy failure, .git pointer/external alternates, inherited Git path redirection and malformed links. Prevent a failed copy from running validation in the original directory.
5. Verify copied modes, relative node_modules/.bin links, local hook configuration, detached event HEAD, index, disjoint main ancestry and unchanged event payload. A helper that uses GITHUB_WORKSPACE must read the copy. Use existing actual instruction-validator metadata modes on a representative exact input where feasible; a fake history assertion is not full metadata-check acceptance.
6. Mutate away the cwd/workspace switch, replace copy with writable sharing, or swallow suite failure. Each mutation must fail the intended oracle. Keep failed fixture logs and explain scratch corrections in at most five lines.
7. Rerun affected existing Copilot caller, immutable input, historical capability/main and shape tests plus YAML/actionlint. Root integrates and runs the single required final aggregate on final source bytes, then current native review/quality/hosted/landed and later peer gates.

Material unknowns: Linux complete-copy overhead; exact hosted phase headroom; whether any current helper uses an uninspected absolute source path; actual service behavior on abrupt cancellation/timeout. The proposal requires meaningful caller and metadata tests before claiming equivalence. The copy is a side-effect boundary for normal hooks, not a hostile-code sandbox. D9's Node-only historical subset remains explicit and unchanged. All22 outcomes/402 contracts/5 issues remain; neither source nor peer work is accepted by this investigation.

## Root selection and implementation release

At 2026-10-04T11:31:43.208238+00:00, root had read both complete proposals, independently matched all seven sampled Git and raw worktree identities, checked the reproduction and parser evidence, rechecked primary GitHub/Git documentation, and recalculated all19 score totals. Two draft D13 arithmetic totals were corrected to Z74/O81 without changing criterion scores or the P96 winner; the original failure and short note remain in private evidence. Root displayed validation, all options, distinct rubrics, corrected tables and selected direct actions before releasing either remedy.

The existing bounded worker a03_pr231_findings now owns only the private implementation directory under C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A03-PR231-findings-20261004. Its exact source is69e1b0d/treeecae3f2. The allowed repair is copilot-setup-steps.yml plus Test-CiHelpers.test.mjs; all73 other tracked files stay exact. Root retains product integration, planning and native operations. No new owner input is required. Focused behavior/mutation checks precede one final source aggregate and the ordinary review/quality/hosted gates. No source or paired acceptance is claimed.

Frozen private proposal SHA256: 89d508d62ee203ca71086f9f85ecca7a3a7922b1fbcab22ddabc46ffe87e34c1.

## Implemented and independently checked

The final copy wrapper creates a separate prepared repository and Git directory, keeps the existing external Python runtime, validates copied Git state and links, and runs the same full suite once with both cwd and GITHUB_WORKSPACE set to the copy. An explicit failed-cd guard prevents fallback execution in the original repository. Cleanup preserves a failed suite status and turns a cleanup failure after suite success into failure. Abrupt termination can leave a temporary copy; original-file protection does not depend on cleanup. This is not a hostile-code sandbox.

Private evidence is C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A03-PR231-findings-20261004/implementation. HANDOFF.json identifies the frozen files and no live private session. IMPLEMENTATION.md SHA256 is4e8cbd793f3dacaebaf36dd41aa2075d186ab8a8e1eff62e7cc2a3733a0eec7b; the final production body SHA256 ise710f37230042d8472a5f769f8a39014d7b76db222db9286dcc2219b43b69b08. Root read the report, patch, actual oracles and intended mutation failures, checked the handback hashes and independently reproduced treec82fa2e before product integration.

- final-cd-isolation-linux.json/log:23/23 final affected cases pass, zero failures/skips,3111.584ms. They cover cwd/workspace, copy failure, interrupted cleanup, interpreter discovery, the failed-cd guard and existing caller contracts. The earlier full affected run passed113/113 before the final refinements; it is not a full113-case pass on final bytes.
- Four mutation controls fail their intended assertions when cwd/workspace switching is removed, writable hard links replace independent copies, or suite failure is swallowed. A separate before/final witness proves failed cd returns36 without entering the suite. Earlier mutation evidence predates that final guard; it is not relabeled as a final rerun.
- windows-fixers-cd-final.json/log: two actual locked fixer hooks fail inside the copy and all original fixture bytes, including Git state and dependencies, remain identical. Two declared Windows path-rendering adaptations leave the production Linux body unchanged. This reduced real-hook fixture is not the11-hook aggregate.
- metadata-cd-final.json/log: the real accepted-base checker passes MetadataClassificationOnly for B=fb328893/H=69e1b0d through the production Linux copy wrapper with only the suite dispatch substituted. This proves that mode and input; it is not all metadata modes or a final-candidate aggregate.
- Final strict YAML/actionlint checks pass. Root's real staged-input preflight passed11:56:40Z. The single all-files product aggregate78543 started11:56:40.611177Z and remains pending at this checkpoint.

The private fixture corrections are retained in IMPLEMENTATION.md and their original logs: scoped text matching/UTF-8 setup, explicit failure assertions, configured actionlint cache, explicit cleanup calls, interpreter discovery, failed-cd protection and per-command Git newline handling. These corrections implement the selected constraints without changing the decision, suite scope, permission or time limits. Root preserves all73 out-of-scope tracked files and recorded dependency/hook files. Actual repaired-input hosted copy overhead and phase headroom remain unmeasured; current native reviews/checks, independent quality, merge/landed verification and peer convergence still follow.
