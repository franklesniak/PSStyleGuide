<!-- markdownlint-disable MD013 -->
# A07 decision: remove the affected braces dependency chain

The coordinator selects K before product edits under the ordinary scoped plan authority. This decision supersedes D07-1's no-current-advisory conclusion only for the changed advisory inputs; prior clean observations remain historical. [The investigation](braces-investigation.md) records evidence and limits. The coordinator checked all eleven score totals and six immutable base/candidate package, lock, audit and exception identities. No risk exception, protected edit or bypass is granted. Implementation and verification remain pending.

## 1. Validate

Saved native run37088281916 failed normally with FINDINGS/native1 for GHSA-vfj7-8cjw-p6xm in both965 lock roots. braces3.0.3 is reached through CLI2/micromatch/globby/fast-glob; six package summaries per root share this single advisory. The reviewed advisory marks<=3.0.3 affected and no patched release. Registry observation still shows the current versions as latest. An open immutable upstream patch exists at d0d575e55e74a4e0218e5248fafb79efc3e54ebb, but its package remains3.0.3. No exploit, installation or audit rerun occurred here.

The actual lint commands execute before the audit. Repository/PR configuration can supply patterns to the affected expansion path. Fixed current command arguments, credential-free CI and job timeout do not establish input-depth safety. Root-only CLI removal reduces duplication but leaves the workflow consumer affected. A distinct maintained markdownlint-cli0.49.1 graph is available:77 statically resolved package/version nodes without the affected chain, compatible engines and matching rules/parser. Config/ignore and actual caller compatibility remain verification gates, not claimed execution results. Both accepted/candidate exception tables are empty; candidate-only additions cannot self-authorize. These facts justify a scoped security repair, rather than new receipts or a repeated audit to change a result.

## 2. Stakeholders

- Owner and accountable security risk authority: decide any remaining exposure, explicit expiry and exceptional admission; an agent score is not their authorization.
- Both repository maintainers and A07/A03/A21 owners: preserve shared dependency/CLI/hook behavior, exact caller closure, audit authority and serialized source/peer delivery.
- Documentation authors, new contributors, Windows/Linux PowerShell/Bash and GUI Git users: retain clear diagnostics, hidden/MDC coverage, nested examples, index content and partial-staging behavior without surprising config loss.
- CI/platform and incident operators: bound failures, keep unprivileged fork runs and actual red-check evidence, and avoid hiding a dependency DoS behind policy changes.
- Dependency suppliers and supply-chain/application security reviewers: assess maintained fixes, immutable provenance, related advisories and long-term fork cost.
- Code/independent-quality reviewers, generated-artifact consumers and history custodians: verify behavior/coverage, distinguish historical CLEAN from current findings, and keep parser outputs intact.
- Schedule/cost stakeholders: weigh timely PR224 completion against repeated long validation and permanent custom security patch maintenance.

Privacy/data-storage, production cloud administrators, destructive recovery operators and localization/accessibility standards are not directly changed by this build-time package decision. Diagnostics must remain readable; no new deployment or personal-data processing is proposed.

## 3. Options

| ID | Exact option | Compatibility/cost and present limit |
| --- | --- | --- |
| A | No code change; preserve red audit and keep current tools | Truthful hold, but vulnerable lint still runs; no repair or accepted-risk grant. |
| B | Apply only existing D07-2 root CLI removal | Useful duplicate reduction; workflow CLI remains affected. Not a complete advisory response. |
| C | Upgrade to a compatible maintained official release | Preferred when it exists; none is available now. Blind major/downgrade/force replacement is not this option. |
| D | Remove CLI2's graph; reuse existing glob13.0.6 and markdownlint0.41.1 through current outer/staged APIs | Removes the affected closure without risk acceptance. Concrete cost: retain required configuration, coverage, index/nested boundaries and diagnostics; prove closure and both platforms. No new framework or generic CLI is needed. |
| K | Replace full outer CLI with maintained markdownlint-cli0.49.1; reuse existing markdownlint API for named staged inputs | Published supported CLI avoids the affected closure on current registry metadata. Same rules/parser and supported file/glob/JSONC/dot/ignore capabilities; fewer full-tree runner changes than D. Config merging/ignore discovery, failure codes and per-path semantics need explicit verification. |
| E | Reuse exact upstream patch in a reviewed pinned/vendored dependency | Retains CLI feature behavior. Eleven-file security fork, guard/direct-AST tests and provenance maintenance required; no official release or audit clearance exists. |
| F | Add a small pre-sink pattern-depth control plus exact temporary exception | Must cover all actual config/argument sinks and verify bounded refusal. Residual affected package and separate owner/admission decision remain. |
| G | Exact temporary exception with current fixed arguments/isolation/timeouts | Preserves behavior quickly, but config-derived patterns remain reachable. Requires real risk owner, fresh expiry/review and a separately valid admission route. No such authority exists. |
| H | Defer admission until a maintained compatible repair is published | Keep failure visible, retain graph and plan a triggered recheck. Unbounded upstream wait and unchanged lint exposure remain. |
| I | Remove Markdown lint entirely | Removes affected execution but violates required outer/nested/staged checks; ineligible. |
| J | Lower severity threshold, skip failed audit, broad exception or false patched identity | Produces misleading admission; ineligible. |

D and K include B's root reduction. K combines native supported tooling where file CLI behavior is needed with the already used library API where exact named index contents are needed. It does not invent a new generic runner. A/H are holds, not green dispositions. E/F may still need G's exact risk/admission step if the actual audit remains affected; that combination does not create a patched release. No other useful combination closes a retained vulnerable graph or substitutes for required behavior.

## 4. New rubric and hard constraints

Scores1–5:1 fails the objective or lacks evidence;2 offers weak/partial benefit;3 offers useful but substantial residual/uncertainty;4 offers strong benefit with a bounded verification task;5 meets the objective on available evidence. Weighted total is sum(weight × score/5). The scores compare proposed paths; they are not test measurements.

| Criterion | Weight | Meaning for this finding |
| --- | ---: | --- |
| Security/advisory resolution | 40 | Remove or correctly contain the actual reachable stack-exhaustion input; do not mistake audit silence for repair. |
| Required consumer behavior | 30 | Preserve rule/config semantics, staged exact bytes, partial staging, outer/nested/hidden/MDC coverage, parser and failure contracts. |
| Verifiable provenance and admission | 15 | Immutable inputs, meaningful negative/positive tests, honest audit result, proper accepted exception authority and reproducible closure. |
| Sustainable shared maintenance | 10 | Avoid permanent bespoke dependency fork or duplicated glob/CLI engines; fit A07/A03/A21 ownership. |
| Bounded delivery cost | 5 | Limit implementation, ongoing review and long validation while preserving safety. |

Hard constraints: implement only the released A07 worktree/path scope; no owner risk inference; no required-check/protected bypass; no candidate-only grant; no loss of required lint/partial-stage behavior; no false CLEAN, fabricated patched identity or stale expiry; no weaker npm/Git credentials/config isolation, graph/schema/expiry checks or process bounds. D/K are eligible as design paths only while retention is made explicit and verified before admission. If required configuration behavior cannot be retained within its bounded scope, revise this decision before proceeding. No high score waives that condition.

## 5. Scores before selection

| Option | Security40 | Behavior30 | Verification15 | Maintenance10 | Cost5 | Total | Key uncertainty/constraint |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 2 | 5 | 5 | 2 | 5 | 70 | Red audit remains; lint still executes. |
| B | 2 | 5 | 5 | 4 | 4 | 73 | Affected workflow closure remains. |
| C | 1 | 5 | 2 | 5 | 4 | 58 | No compatible official release now. |
| D | 5 | 4 | 4 | 5 | 2 | 88 | Configuration/caller retention must pass concrete tests. |
| K | 5 | 4 | 4 | 5 | 4 | 90 | Published CLI still needs exact config/caller, install and audit proof. |
| E | 4 | 5 | 3 | 2 | 3 | 78 | Unmerged patch, new fork maintenance, audit treatment unproved. |
| F | 3 | 4 | 3 | 3 | 3 | 66 | All sinks/control proof and real risk/admission authority absent. |
| G | 2 | 5 | 4 | 3 | 4 | 68 | Owner approval/admission absent; reachable patterns remain. |
| H | 2 | 5 | 4 | 5 | 4 | 72 | Unknown release timing, unchanged current exposure. |
| I | 5 | 1 | 4 | 5 | 5 | 73; ineligible | Drops required checks. |
| J | 1 | 5 | 1 | 1 | 5 | 48; ineligible | Violates truthful security admission. |

Arithmetic is checked statically. K and D have equally strong proposed removal/behavior evidence; K is preferred because it keeps a published maintained full-file CLI rather than implementing that caller as a project runner, while both reuse the existing string API for index data. The two-point margin is not empirical proof of superiority: the concrete discriminator is fewer new full-tree CLI responsibilities for the same required benefit. Behavior remains4, not5, because actual config/caller compatibility is untested. D is a useful fallback if K cannot retain a concrete required behavior; revise this same selection before implementing that fallback. E is technically real but creates an unreleased security-fork/audit/provenance obligation. No score waives compatibility or owner authority.

## 6. Selected agent recommendation

Select K as the A07 repair path: maintained markdownlint-cli for full outer files, existing direct API for exact named staged/outer-wrapper strings. Keep the current failed check visible until validation supports a new result. Keep risk authority unchanged.

Keep root/workflow npm lint:md and lint:md:nested interfaces. Delegate the root command to workflow tooling as already selected in D07-2. Pin markdownlint-cli0.49.1 there and use explicit quoted md/mdc globs, --dot, config and exclusions for full outer lint. Replace current staged CLI2 nonFileContents with markdownlint/sync named strings using exact index bytes and existing JSONC config; retain0/1/2 wrapper semantics. Keep the nested-content interface, safe path reader and direct markdown-it14.3.2 parser. Reuse the already selected D07-3 staged/nested API behavior from frozen A07 in this isolated repair. Adapt its bounded lintOuterMarkdownContents wrapper to the same direct API now. This retains the stronger index/nested tests during migration and avoids leaving a deferred CLI2 caller. Do not copy unrelated Python, installation or hook-topology changes into this urgent repair. Remove CLI2 from both graphs only after every live caller is replaced; remove only now-unused scoped overrides/transitives. Do not rewrite historical supply profiles.

Keep all supported Markdown/MDC and hidden paths. Keep exclusions and regular-file/root checks. Keep nested MD041/MD051 differences. Keep0 success,1 lint findings and2 tooling failure. Preserve all actually required per-path rule/config behavior. Map configuration discovery, ignores and overrides before removing their CLI implementation. Maintained CLI merges rc/default config even with --config and auto-reads .markdownlintignore; explicit config is not an isolation claim. Freeze actual tracked and introduced-config behavior, ordinary hidden/MDC exclusions, cross-platform case/Unicode handling and tool failures before acceptance. Do not silently accept a configuration that is no longer applied. If preserving a supported behavior needs a larger contract change, stop and revise the scope.

Keep audit algorithms, exact pins, isolation and risk table unchanged. Recheck the complete graph after regeneration. A zero count is necessary current evidence, not a lifetime security guarantee. Any remaining finding needs a new applicable disposition. Do not make an exception in place of a failed compatibility check.

Serialize this as A07-owned urgent dependency work in the isolated current-main worktree. Preserve the original frozen c68 worktree and its history. Later integration must explicitly reconcile the overlapping accepted root/staged/nested changes; its old fifteen-path patch cannot be applied blindly or described as byte-unchanged on the new base. Held Invoke-MarkdownLint.ps1 and MARKDOWN-LINTING-IMPLEMENTATION.md need no selected urgent edit: their preserved phase names/semantics suffice. Any newly necessary held-path delta must get an explicit ownership/ordering amendment before edits. A03 owns any actual workflow/policy integration; A21 owns any necessary validator/bootstrap/selector coupling. Refresh current PS/TF source and native authority before each integration. Do not absorb the repair into A02's eleven paths or grant a new first-install baseline by assumption. Security-first merge changes PR224 B and invalidates its exact48f initializer pin. Explicitly reassess the new known accepted baseline and closed initial mapping, refresh affected B/H proof and reviews, without widening/bypassing the initializer. No owner or operational approval is asserted.

Primary sources and exact research evidence are linked in [the investigation](braces-investigation.md). The existing [markdownlint API](https://github.com/DavidAnson/markdownlint/blob/v0.41.1/README.md) accepts named strings with explicit configuration; this is already used by the nested helper. Its API documentation is evidence of a viable consumer, not proof that a replacement is implemented.

## 7. Pending implementation and meaningful verification

No step7 execution occurred. Before a writer starts, freeze the final selected scope and config/caller compatibility mapping. Released urgent scope: package.json/package-lock.json, .github/workflows/package.json/package-lock.json, .github/workflows/lint-staged-markdown.mjs, .github/workflows/lint-nested-markdown.js, a necessary thin .github/workflows/lint-markdown.mjs caller and its meaningful .github/workflows/lint-markdown.test.mjs tests, directly coupled existing NpmTools.test.mjs assertions, docs/dependency-maintenance.md and .github/workflows/scripts-README.md. New wrapper files are optional when the maintained CLI/API can meet the contracts without them. Reuse only the already selected D07-3 staged/nested behavior, preserve the direct parser and extraction, and record current/future hook-topology coverage honestly. No other frozen-batch implementation is released. Held Invoke-MarkdownLint.ps1/MARKDOWN-LINTING-IMPLEMENTATION.md stay untouched unless a concrete incompatibility requires an explicit scope amendment. No workflow/protected change is presumed necessary. Audit helper changes require a separate concrete need; do not weaken it to accept the remedy.

Use exact Node24.18.1/npm11.16.0 and normal NpmTools locked setup. Inspect both complete installed graphs and lock closures: no braces/micromatch/globby/CLI2 consumer remains; direct parser still works. Run real outer and nested repo commands and actual shell hook. Preserve the existing A07 nine-case tests: empty index, clean-index/invalid-worktree, nested-invalid-index/clean-worktree, invalid/valid hook, hidden Unicode/spaced MDC, rename/delete, wrong runtime, missing tool and unexpected status. Add explicit CLI full outer positives/negatives for md/mdc, hidden paths, exclusions, config rules, native2/3/4 tool failures, no unintended ambient/config-driven suppression and safe path handling; add genuine configuration/ignore/override compatibility cases as established by the supported mapping, and a hostile-pattern/config refusal test that reaches the chosen caller rather than a self-referential string assertion. Keep leaf/ancestor symlink, path escape, source-byte and actual index boundaries. Test Windows and Linux, including real CLI child failures.

Run the actual unchanged audit helper for both roots, installed-graph checks and relevant hosted/local authority modes; retain raw results and prior failure. Verify exception state remains empty, candidate grants are rejected, schema/expiry/native-output limits remain, and no affected registry/lock entries merely disappeared through identity manipulation. Run affected current validator/bootstrap/helper tests, normal required aggregate checks and actual CI/reviewer/final-quality gates on the same final input. Only then propose source acceptance, followed by the ordinary counted TF/reverse comparison. If a maintained release becomes available before implementation, reassess C against K/D instead of continuing churn automatically.
