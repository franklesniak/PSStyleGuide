<!-- markdownlint-disable MD013 -->
# FQ45: Reject Git askpass credential sources

- **Status:** Local validation and independent final quality accepted; committed03f1dbf; publication and current-input remote gates pending
- **Owner:** A07 coordinator
- **Last Updated:** 2026-10-09
- **Scope:** PR239 finding4234303339, the credential helper, its maintained regression tests and its runtime documentation
- **Related:** [Decision process](../../../DECISION-PROCESS.md), [review finding](https://github.com/franklesniak/PSStyleGuide/pull/239#discussion_r4234303339), [repository-selector decision](FQ39-GIT-REPOSITORY-SELECTORS.md)

The reviewed head is11224a2f58e2cb1e2ffb3ab443ccc83dd0822950. Codex review5475069939 submitted the finding in threadPRRT_kwDOQkjdhM6q7_Ul. Both round4 review requests are terminal. Copilot5475046748 observed Balanced with zero inline findings; its recurring coverage overview is handled separately. The new askpass finding is not a duplicate of FQ39.

## 1. Validate the finding

The finding is real. The current helper rejects repository selectors, external command configuration, projected tokens, local credential helpers and HTTP authorization headers. It excludes global/system configuration and sets GIT_TERMINAL_PROMPT to0. It does not reject GIT_ASKPASS or SSH_ASKPASS, or inspect the effective core.askPass key. An anonymous-result assertion can therefore succeed while a later Git command in the same process obtains credentials from a program.

Git documents the prompt-source order as GIT_ASKPASS, core.askPass, SSH_ASKPASS, then the terminal. Disabling terminal prompting does not disable the preceding programs. This supports the reported environment-variable defect and identifies the closely related configuration variant in the same credential mechanism. [Credential lookup](https://git-scm.com/docs/gitcredentials.html#_requesting_credentials), [environment controls](https://git-scm.com/docs/git/2.56.0.html)

Root reproduced both variants using the actual unchanged helper, SHA256dc8b92d3bc2d849fc6c304168213ad06cd3da036a4e2d88057cbf2b38397d791, Git2.56.0.windows.2 and PowerShell7.6.5. Each case had a new private scratch repository with the expected anonymous origin, no credential helper and no persisted authorization. The same child PowerShell process called the helper and then `git credential fill`. The askpass program returned only an authored synthetic value. No network request or real credential lookup was made. Native39439 completed0/30afc5.

| Input | Helper result | Later credential command | Synthetic program calls |
| --- | --- | --- | ---: |
| Neither variable; no core.askPass | Success | Refused, exit128 | 0 |
| GIT_ASKPASS | Success | Returned synthetic username/password, exit0 | 2 |
| SSH_ASKPASS | Success | Returned synthetic username/password, exit0 | 2 |
| Both variables | Success | Returned synthetic username/password, exit0 | 2 |
| Local core.askPass | Success | Returned synthetic username/password, exit0 | 2 |

The [reproduction receipt](current-main-validation/pr239-round4-askpass-reproduction.json) preserves exact source/runtime identities and individual results. Scratch files and empty private configuration files remain as evidence. Product files, host configuration and the parent environment were unchanged. This proves the helper's false success and Git's subsequent offline credential sourcing. It does not prove credential disclosure or a poisoned hosted runner. Linux, empty-value, include and worktree variants still require maintained final-source validation.

The helper is called directly by workflows and through Initialize-CiToolchain.ps1 and Invoke-MarkdownLint.ps1. The selected repair applies when those calls reach the helper. Earlier acquisition can already have invoked Git; a later helper check cannot retroactively validate it. Windows initializer capability probes can occur before the helper. Do not claim that refusal means no earlier native command in the entire workflow.

## 2. Stakeholders and constraints

Security and privacy owners need the anonymous check to reject executable credential sources without printing program names, paths or values. Maintainers and CI/DevOps operators need one gate that applies to direct and indirect callers. Windows and Linux users need defined environment-name and empty-value behavior. Linked-worktree users need effective configuration checked without losing normal worktree support.

New contributors and UX/documentation owners need a short diagnostic and a clear correction: remove the two environment variables and the effective askpass setting before using the anonymous helper. Experienced users may intentionally configure askpass elsewhere; the repair must not delete their settings or silently change that context. QA and independent reviewers need actual-source refusal controls and causal mutations, with successful ordinary use retained. Incident and recovery operators need restartable evidence that distinguishes this new finding from earlier accepted tests.

Project/business owners need the defect fixed without delaying it for a new execution framework. Dependency, cloud and artifact consumers benefit indirectly from reliable CI; this change needs no package, permission, cloud-service or generated-artifact change. Accessibility has no new UI beyond plain diagnostic text. No language-specific credential difference justifies divergent PS/TF algorithms.

Hard constraints: retain the credential gate; cover both environment prompt sources and effective core.askPass; preserve selector/token/helper/header checks, fixed Git, native exit handling, configuration isolation and Windows ownership/cleanup; do not print credential-source values; do not claim a sanitized child query makes the surrounding process safe. No score can waive these conditions.

## 3. Options, before scoring

| ID | Option | Consequence |
| --- | --- | --- |
| A | Leave code unchanged; rely on clean runners, documentation or deferral | Keeps the reproduced false success. A clean CI environment does not prove the helper contract. |
| B | Remove or narrow the anonymous-credential gate | Abandons the required assertion instead of repairing it. |
| C | Reject only one askpass environment variable | Leaves another prompt source and core.askPass active. Either one-variable permutation is incomplete. |
| D | Reject nonempty values of both variables and any effective core.askPass setting | Covers active program sources while permitting empty environment entries. Requires separate platform/value semantics and evidence. |
| E | Reject both variables when present, but do not check core.askPass | Gives a simple environment rule but leaves the reproduced configuration variant. |
| F | Reject both variables when present and any effective core.askPass setting | One explicit absence rule, before credential Git for environment inputs and before success for effective configuration. Retains ordinary Git discovery. |
| G | Clear both variables and reject effective core.askPass | Can remove the source, but silently changes caller intent and adds environment-mutation/preference obligations. |
| H | Sanitize only the child environment for the helper's Git queries | The queries can be safe while a later command still inherits the original credential source. |
| I | Put checks only in existing acquisition/caller scripts | Leaves standalone or future helper calls exposed and duplicates the contract. |
| J | Apply F and extend every earlier acquisition guard | Covers a wider time boundary, but needs coordinated workflow/caller tests and a larger supported contract. |
| K | Permit selected trusted askpass programs | A trusted program can still supply credentials, so it cannot establish an anonymous result. |
| L | Replace Git calls throughout the workflows with one sanitized execution wrapper | Could cover the wider flow if every caller is migrated, but introduces a new process/environment interface and larger validation burden. |

The three nonempty subsets of the environment names are individual GIT_ASKPASS, individual SSH_ASKPASS and both. Empty, whitespace, relative-path and case variants are boundaries of D/E/F/G, not separate designs. Clearing one variable while rejecting the other still needs configuration protection. A process sanitizer that also replaces all later Git invocations becomes L; query-only sanitation remains H. Trust exceptions to F become K. Rejecting every GIT_* variable would unnecessarily remove unrelated supported behavior and is not a bounded credential repair.

## 4. New evaluation rubric

Each score is an ordinal engineering judgment:0 fails the criterion,1 leaves a major gap,2 is partial,3 works under substantial conditions,4 has a bounded limitation,5 satisfies it directly. Total=sum(weight times score/5). Scores are not measured probabilities. The weights sum100 and deliberately place implementation cost below correctness and legitimate usability.

| Criterion | Weight | Meaning for this finding |
| --- | ---: | --- |
| C: credential-source coverage | 32 | Covers both environment variables and effective repository configuration, including linked worktrees. |
| F: safe refusal | 24 | Rejects unsupported inputs predictably, preserves credential detection and avoids value disclosure or silent caller-context changes. |
| U: contributor usability | 16 | Preserves ordinary use and gives experienced/new users one clear correction. |
| V: verification strength | 18 | Supports actual-helper tests, positive controls and causal removal of each protection. |
| P: platform and caller fit | 7 | Behaves consistently on Windows/Linux while retaining existing invocation and native-status contracts. |
| M: maintenance cost | 3 | Keeps implementation and tests understandable without an unnecessary framework. |

Security, privacy, QA, platform, maintainer, documentation and user-experience concerns determine the first five criteria. Cost/schedule/churn has only3 percent. F trades one usability point for requiring removal of empty variables. D earns more flexibility but less deterministic refusal/platform/verification credit. G is usable but silently removes caller inputs. J and L need broader coordinated control and proof; their scores reflect that uncertainty rather than merely penalizing file count.

## 5. Scores, before selection

| Option | C | F | U | V | P | M | Total /100 | Main limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 0 | 0 | 2 | 1 | 5 | 5 | 20.0 | Fails coverage constraint. |
| B | 0 | 0 | 1 | 1 | 4 | 5 | 15.4 | Removes required gate. |
| C | 1 | 4 | 4 | 5 | 5 | 5 | 66.4 | Leaves prompt sources. |
| D | 5 | 4 | 5 | 4 | 4 | 5 | 90.2 | Empty values need separately defined semantics. |
| E | 3 | 4 | 4 | 5 | 5 | 5 | 79.2 | Leaves reproduced core.askPass variant. |
| F | 5 | 5 | 4 | 5 | 5 | 5 | 96.8 | Unsupported environments must remove variables. |
| G | 5 | 3 | 5 | 4 | 4 | 4 | 84.8 | Silent environment mutation and preference handling. |
| H | 2 | 2 | 4 | 3 | 3 | 2 | 51.4 | Later caller still has credential source. |
| I | 2 | 3 | 3 | 3 | 3 | 2 | 53.0 | Standalone/future caller gap. |
| J | 5 | 5 | 4 | 4 | 4 | 2 | 90.0 | Wider acquisition proof is not yet prepared. |
| K | 1 | 1 | 3 | 2 | 4 | 2 | 34.8 | Permits credential production. |
| L | 5 | 5 | 3 | 3 | 3 | 1 | 81.2 | Requires complete new caller contract and migration. |

Root recomputed every weighted total before selection. F wins and satisfies all hard constraints. Its narrower temporal boundary is explicit; do not use this repair to claim earlier acquisition was protected. The reproduced helper defect does not require replacing that larger interface.

## 6. Selected solution

Root selected F before any product edit on2026-10-09. The owner already authorizes clear winning in-scope choices. No new owner decision is needed.

1. Check for GIT_ASKPASS and SSH_ASKPASS before the helper starts Git.
2. Stop if either variable is present. Include empty values.
3. Use the existing effective-configuration query to check for core.askPass.
4. Stop if that key is present. Include an empty setting.
5. Do not display the variable value or configuration value.
6. Keep the existing credential, selector and native-status checks.
7. Keep ordinary repositories and linked worktrees supported.
8. Test Windows and Linux behavior with the actual helper source.
9. Test each environment-name removal and removal of the configuration check.
10. Test calls through the initializer and the Markdown launcher.
11. Update the helper description and its runtime documentation.
12. Obtain final validation and review before merge.

These instructions use short imperative sentences, one action per step and consistent technical names. No formal ASD-STE100 dictionary certification is claimed. The documentation change must state the actual helper boundary and correction; it must not promise protection before the helper runs. No protected instruction or normative language guide changes are selected.

## 7. Implementation and verification

Root integrated the selected three-path repair on11224a2 with staged tree0e448484daf1b50c9b0f8924188c4aa90c4c0db5. The independent [source review](current-main-validation/pr239-round4-source-review.md) found no material source, security, test-relevance or applicable shipping PowerShell style issue. It read the complete product guide and recommends no secondary guide change. The six new maintained registrations use44 child invocations per platform. All six passed fresh on Linux (session51847, terminal6c8957), with strict root acceptance of unchanged inputs, empty process settlement and cleanup; their maintained Windows run passed in the accepted aggregate822 (session32463, terminal1c9cae). Required tests include absence positives; all environment-name subsets and present-value boundaries; native platform casing; effective local, included and worktree configuration; empty/mixed-case configuration keys; causal mutants; both real callers; no value disclosure; and existing cleanup/native-failure behavior. The previous actual Linux/Windows acquisition and other unchanged scopes retain their original identities until an explicit applicability check permits reuse.

The offline reproduction is validation of the finding, not final-source acceptance. Local hooks, independent final quality and normal commit are now accepted as recorded below. Fresh remote reviews, current green CI, landing and paired delivery remain. Preserve round4/80, original deadline2026-10-16T22:53:27.970214Z and A07transfers9/12. No CI retry or merge is authorized by this selection alone.

The [repaired-helper mechanism check](current-main-validation/pr239-round4-askpass-repair-verification.json) completed native0/432437 with Git2.56.0.windows.2 and PowerShell7.6.5. The ordinary checkout passes the helper and offline credential lookup exits128 without a credential. GIT_ASKPASS, SSH_ASKPASS, both together and local core.askPass all stop at the intended fixed diagnostic before lookup, with zero synthetic-program calls. This Windows five-case proof uses no network or real credential and does not replace maintained platform validation. Raw receipt SHA2569b2f7e51aabbee4305d1b4907e4a5185fb49766664d26b26cfd062624b57cf13.

Shipping helper parsing and current-driver Node syntax passed; shipping PSScriptAnalyzer1.24.0 reported zero warnings/errors (native0/3bfa74). Updated runtime README passed outer/nested lint (1b71c0). Generated-form analysis completed161 labels/101 distinct bodies with zero parser errors and two raw New-ArchiveProcess heuristic warnings (native1/d32c12). The [raw result](current-main-validation/pr239-round4-generated-syntax-raw.json) remains unchanged; independent review and root inspection confirm the existing constructor applicability decision. It configures an unstarted process and does not change external state. The [current syntax attribution](current-main-validation/pr239-round4-generated-syntax-attribution.json) accepts361 representative labels (166 current,195 retained), with zero applicable findings. The supplemental four changed credential prefixes also parsed and analyzed cleanly. No blanket suppression or raw-clean claim is made. Affected Linux/Windows execution is now accepted as recorded below. The exact native-hook run is accepted under FQ32 retention. Publication and new current-input reviews remain incomplete.

The [reuse audit](current-main-validation/pr239-round4-reuse-selection-review.md) found that the identity registration executes two changed Linux credential prefixes. Its old passing receipt cannot supply current credit. The [D07 correction](FQ45-REUSE-SELECTION-NOTE.md) moves identity1 to fresh execution. Root accepts37 unchanged registrations in six groups and126 fresh passing registrations in17 cells. The [complete Linux union](current-main-validation/linux-current163-acceptance.json) passed native0/137fe6 with163 distinct required names and exact receipt attribution. No Linux registrations remain. The Windows aggregate passed822 tests/383 pass/439 skips; all11 native hooks passed and are now accepted under the exact FQ32 retention disposition; the strict runner cleanup failure remains preserved. The native source/dependency observation verified78 source files and1914 dependency files without changing product state.

The fresh [Windows source readback](current-main-validation/pr239-round4-windows-readiness-acceptance.json) passed native0/a07693:78 raw files match staged blobs and modes, the entire index matches tree0e448484, and exactly three paths are staged. The [Windows aggregate](current-main-validation/pr239-round4-windows-aggregate-runtime.json) passed native0/1c9cae and strict acceptance0/574d81:822 total,383 passes,439 explicit platform skips, zero failures/cancellations/TODO. Jobs were empty without termination, private TEMP was removed, and source/runtime/dependency/Git guards were unchanged. All11 hooks session71591 completed native0; its controller failed cleanup with exit1/ec8ec1. The [failed-run record](current-main-validation/pr239-round4-windows-precommit-failed-a1.json) preserves the two-file residue. Fresh FQ32 verification passed0/e8a218 and the exact native-hook execution is separately accepted with retained residue. The [final independent quality](current-main-validation/pr239-round4-final-local-quality-acceptance.json) passed with no findings. The [normal commit](current-main-validation/pr239-round4-normal-commit.json) passed all three Husky stages and produced `03f1dbf72ce486c0fa1d2cdfb74aaf78143e4477` with the accepted tree. Public gates remain incomplete.
