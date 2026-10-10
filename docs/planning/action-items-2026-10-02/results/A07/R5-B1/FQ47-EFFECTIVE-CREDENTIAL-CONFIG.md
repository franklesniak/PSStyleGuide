<!-- markdownlint-disable MD013 -->
# FQ47: Reject effective credential helpers and HTTP headers

Selected implementation decision; product validation remains pending. Finding4235536404, threadPRRT_kwDOQkjdhM6q-51w, concerns published PR239 head03f1dbf72ce486c0fa1d2cdfb74aaf78143e4477. Root supplied the finding identity and concern; this worker verified the product source and primary Git behavior. No shipping-helper test, credential lookup, implementation or acceptance occurred. Root supplied bounded native Git readback; the worker completed only an authorized synthetic transport probe.

## 1. Validate the material finding

The finding is real. Test-CheckoutCredentials.ps1 SHA85fc29a1f49ae427c206aba9da6d5e1fd5ee4ffc26cbba191c314d9593aef7c3 asks only `config --local --get-all credential.helper` at349 and a local header-name regexp at355. Effective names/scopes are already read at362, but their credential inspection checks only core.askpass at369–373. A repository can supply the expected origin and put a helper or header in an included file or config.worktree. The helper can then report success with that credential source still configured.

Git's local query reads one repository source. Includes default off for source-specific reads and on for all-source reads. Enabled worktree configuration is a separate effective source. Consequently the existing effective list sees entries that the earlier checks miss. Root then proved the source/key omission with12 authored local/included/worktree cases on Git2.56.0.windows.2: the two existing queries miss10/12; the explicit effective includes scan sees12/12 (terminal4b2100/0). This is Git query readback, not whole-helper execution or repair acceptance. [Git2.56 configuration](https://git-scm.com/docs/git-config/2.56.0#_options), [upstream source](https://raw.githubusercontent.com/git/git/v2.56.0/Documentation/git-config.adoc)

The same source exposes two adjacent forms within this finding: the exact credential.helper lookup omits `credential.<URL>.helper`, and `^http\..*\.extraheader$` requires a subsection, omitting generic http.extraHeader. Those settings affect credential acquisition or HTTP requests. Repeated helpers can supply credentials; an empty helper entry resets a list. [Credential contexts and helpers](https://git-scm.com/docs/gitcredentials#_configuration_options), [credential source](https://raw.githubusercontent.com/git/git/v2.56.0/Documentation/config/credential.adoc). HTTP extraHeader supports generic, repeated and empty-reset settings. [HTTP configuration source](https://raw.githubusercontent.com/git/git/v2.56.0/Documentation/config/http.adoc)

This is distinct from [FQ45](C:/Users/flesniak/GitHub/PSStyleGuide/docs/planning/action-items-2026-10-02/results/A07/R5-B1/FQ45-GIT-ASKPASS.md), which selected absence checks for GIT_ASKPASS, SSH_ASKPASS and effective core.askPass. That repair correctly covers those prompt sources and already uses effective config for its key. FQ47 extends the existing helper/header assertion to the configuration sources Git actually loads. Preserve FQ45 and every earlier control. No claim is made about an exploited runner, disclosed credential or protection before the helper executes.

Two further input details belong to the same effective-query repair. GIT_CONFIG redirects only git config as an implicit --file; other Git commands still load the repository. Root proved expected origin unchanged while an authored empty alternate file changes the effective scan from118B with the included helper visible to0B/exit0 (d223c7/0). Refuse GIT_CONFIG presence, including empty, before Git/private staging. Do not clear it only for the assertion. [Git configuration environment](https://git-scm.com/docs/git-config/2.56.0#_environment)

Line framing is insufficient. Git rejects literal LF in a quoted subsection; subsection backslash-n/t become n/t, unlike value escapes. A bare CR and tab can remain in the subsection. Git prints the key without quoting. NUL output emits scope-NUL/key-NUL pairs, which cannot be forged by subsection CR/tab. [Git parser source](https://raw.githubusercontent.com/git/git/v2.56.0/config.c), [Git output source](https://raw.githubusercontent.com/git/git/v2.56.0/builtin/config.c)

The worker's corrected transport probe (39e6ba/0) uses isolated authored metadata and existing PowerShell native capture:5 native lines join into13 scope/key pairs with26 NULs and the trailing delimiter intact. Eight generic/URL helper/header normal/CR/tab cases classify as prohibited; four benign lookalikes remain benign. Bare CR becomes LF inside the opaque subsection; tabs remain. No exact original subsection-byte preservation is claimed. Matching only the first section and final variable retains the all-context key-presence policy despite that normalization. Keep exact core.askpass matching for FQ45. No raw-process executor is needed.

Attempts1–3 stopped and remain preserved; their private environment setter passed $null through a string overload, creating present-empty selectors. The correction removes Env: entries and asserts absence. The third attempt's raw Git comparison independently contained13 pairs, so no NUL transport loss was established. This private fixture correction grants no product/runtime qualification and is documented in the five-line D07 note. Linux transport still needs current-source validation.

## 2. Stakeholders and hard constraints

| Stakeholders | Finding-specific needs and effect on selection |
| --- | --- |
| Owner, both maintainers, experienced contributors | Restore the advertised anonymous gate with one understandable policy; keep intended configuration unchanged. Avoid a replacement Git execution interface. |
| New contributors, documentation authors/readers, UX directors | Identify the prohibited setting and explain removal from its supplying include or worktree configuration. Do not require users to diagnose an invisible local-only check or silently erase their personal configuration. |
| Security executives, supply-chain/application/infrastructure engineers, privacy owners | Refuse executable helpers and persisted HTTP headers across effective sources without invoking them, reading credential stores or publishing values/configuration rows. A trusted helper still supplies credentials. |
| CI/release/DevOps engineers, local/remote agent operators, Windows/Linux/Bash/PowerShell users | Preserve real Git discovery, global/system exclusion, exact native status, benign includes, linked worktrees, qualified Windows host/ACL and private cleanup. Avoid host-specific parsing or a new dependency. |
| QA analysts, code reviewers, independent-quality reviewers | Use actual helper source and real Git with isolated authored metadata; cover key forms, source routes, negative controls and cleanup. Distinguish planned tests from receipts. |
| Incident/recovery operators, auditors/history custodians | Keep prior decisions and receipts; refuse uncertain input without editing it. Revalidate affected callers on frozen final bytes rather than importing prior helper success. |
| Dependency, cloud/backend and generated-artifact consumers, business/schedule owners | Benefit from reliable anonymous CI. No package/cloud setting, artifact format or public API change is required. Implementation cost is secondary to safety and usability. |
| Terraform/PowerShell peer maintainers, accessibility/localization users | Carry the same common helper behavior in later paired delivery. No language-specific credential algorithm or new UI is needed; use a short plain diagnostic. |

Hard constraints: preserve the anonymous credential assertion, FQ45, selectors/tokens/external-command checks, fixed Git and global/system isolation; cover both generic and URL-specific helper/header keys from effective configuration; preserve supported benign includes/worktrees; collect names/scopes rather than values; preserve record boundaries despite opaque subsections; refuse config-only source redirection; do not execute credential programs or mutate supplied configuration; keep native failure and Windows ownership/cleanup behavior. Scores cannot waive these constraints. The existing contract rejects persisted header settings, not just values that look like Authorization. Presence refusal includes empty/reset entries; it is conservative and must be documented. No new settings/protected-file authority is inferred.

## 3. Distinct options and combinations

| ID | Option | Consequence |
| --- | --- | --- |
| A | No change, documentation only or deferral | Leaves current false success; fails coverage. |
| B | Remove or narrow the anonymous assertion | Abandons the required credential gate. |
| C | Add --includes only to existing --local queries | Still misses worktree scope, generic header and URL helper forms. |
| D | Remove --local but retain current key patterns | Fixes source visibility; incomplete key families remain. |
| E | Separate corrected local/worktree NUL names-only queries, includes and GIT_CONFIG presence guard | Can cover current sources; duplicates queries/scope handling. |
| F | One effective NUL-framed names/scopes scan; refuse GIT_CONFIG presence; remove two local queries | Rejects empty/reset and unrelated-context keys; opaque subsection CR may normalize without changing family classification. |
| G | Add F checks but retain old local queries | Correct refusal plus redundant narrower calls; helper-value retrieval remains. |
| H | Check only settings that match the current origin | Narrows no-retained-credentials contract; must reproduce URL matching and precedence. |
| I | Permit empty resets, trusted helpers or non-authorization headers | Needs value inspection/trust exceptions; does not establish required absence. |
| J | Suppress credential settings only in the helper query environment | Can produce safe queries while subsequent caller Git remains configured. |
| K | Automatically unset or rewrite the supplied configuration | Mutates caller intent and supplied files; introduces rollback/ownership obligations. |
| L | Apply F and reject all includes and worktree configuration | Adds unnecessary rejection of legitimate benign configuration. |
| M | Factor F into a new shared configurable credential-policy component | Potential reuse; introduces a new policy/configuration interface without a second implementation need. |
| N | Apply F and migrate all acquisition Git to a new sanitized wrapper | Wider temporal protection needs migration and caller contract proof. |
| O | Call credential fill or perform a network authentication probe | Can execute configured programs, read actual credentials or contact a server. |
| P | F but retain newline-framed scope/key records | Bare CR can split the credential key and forge row-shaped benign text; tab splitting is ambiguous. |
| Q | F with a new raw-byte native process reader | Can preserve exact bytes; introduces unnecessary process/error/cleanup surface after existing capture proof. |
| R | F plus reject every control character or unusual subsection | Needlessly rejects benign opaque contexts; does not replace sound record framing. |
| S | F but clear GIT_CONFIG only during config queries | Hides caller override rather than refusing it; surrounding Git still has different source semantics. |
| T | F without a GIT_CONFIG selector guard | Native-proved empty alternate file hides effective keys with exit0 while origin is unchanged. |
| U | Refuse GIT_CONFIG only; leave original family/source queries | Closes selector bypass but leaves source and key-family finding unresolved. |

Helper-only and header-only permutations are incomplete variants of C/D. Checking both local and worktree with includes and corrected patterns is E; it can be correct but needlessly duplicates information already in the effective list. F combines explicit --includes, NUL scope/key framing and presence refusal of the config-only selector. E and eligible F-derived variants use the same framing/selector controls unless the option explicitly omits them. P isolates newline framing, Q a raw-reader replacement, R blanket unusual-name rejection, S query-only selector clearing, T selector omission and U selector-only repair. F uses the now-proved existing capture; Q adds an unnecessary executor. These are distinct combinations with distinct safety and usability costs. F with legacy checks is G; F with a blanket include/worktree prohibition is L; F with a shared configurable policy abstraction is M; F plus every acquisition caller migration is N. Query-only sanitization or disabling repository config for the assertion is J because the surrounding caller can remain credentialed. Repeating local checks or trusting an allowlisted helper does not establish absence. A deferral or documentation-only path leaves the confirmed product finding and collapses into A.

## 4. New rubric, before scoring

Each criterion uses0–5:0 fails,1 leaves a major gap,2 is partial,3 needs substantial conditions,4 has a bounded stated limitation,5 directly meets the criterion. Total=sum(weight×score/5). Scores are engineering judgments, not measured probabilities. These weights are new for this finding and sum100.

| Criterion | Weight | Meaning and stakeholder basis |
| --- | ---: | --- |
| C: effective-source correctness | 30 | Covers both key families, generic/URL forms, included and worktree settings, multiplicity and empty presence, config-only redirection and opaque-subsection record framing. Required by security and CI consumers. |
| S: privacy and source integrity | 23 | Avoids program execution, value inspection/disclosure, credential lookup and caller-config mutation; preserves provenance/isolation. Required by privacy and security owners. |
| U: legitimate contributor usability | 17 | Keeps benign include/worktree use, clear correction and consistent absence policy. Reflects new users, experienced users and documentation/UX. |
| T: causal validation quality | 16 | Supports actual-source/native-Git positives, refusal controls, key/source mutants and caller boundaries with reproducible evidence. Reflects QA and reviewers. |
| R: platform/error/recovery fit | 10 | Fits existing supported Git/PowerShell, native failures, private cleanup and restartable scoped attribution. Reflects operators/auditors. |
| M: long-term maintenance | 4 | Uses existing information and interfaces without redundant calls, policy components or new packages. Reflects maintainers and cost stakeholders. |

F loses one usability point because even an empty reset or unrelated-context header/helper must be removed from the anonymous context. That is the transparent conservative contract rather than a claim those entries always yield a credential. E preserves users but adds source-specific handling and extra failure paths; G still retrieves helper values. H is more flexible but changes the advertised assertion and requires URL matching. More file churn alone is not a correctness penalty.

## 5. Scores, before selection

| Option | C30 | S23 | U17 | T16 | R10 | M4 | Total/100 | Main limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 0 | 1 | 3 | 1 | 3 | 5 | 28.0 | Leaves current false success; fails coverage. |
| B | 0 | 0 | 2 | 1 | 3 | 5 | 20.0 | Abandons the required credential gate. |
| C | 2 | 4 | 4 | 4 | 4 | 5 | 68.8 | Still misses worktree scope, generic header and URL helper forms. |
| D | 3 | 4 | 4 | 4 | 4 | 5 | 74.8 | Fixes source visibility; incomplete key families remain. |
| E | 5 | 5 | 4 | 4 | 4 | 3 | 89.8 | Can cover current sources; duplicates queries/scope handling. |
| F | 5 | 5 | 4 | 5 | 5 | 5 | 96.6 | Rejects empty/reset and unrelated-context keys; opaque subsection CR may normalize without changing family classification. |
| G | 5 | 4 | 4 | 4 | 4 | 4 | 86.0 | Correct refusal plus redundant narrower calls; helper-value retrieval remains. |
| H | 4 | 4 | 5 | 4 | 4 | 3 | 82.6 | Narrows no-retained-credentials contract; must reproduce URL matching and precedence. |
| I | 2 | 2 | 5 | 3 | 4 | 2 | 57.4 | Needs value inspection/trust exceptions; does not establish required absence. |
| J | 1 | 2 | 4 | 3 | 3 | 3 | 46.8 | Can produce safe queries while subsequent caller Git remains configured. |
| K | 4 | 1 | 3 | 3 | 3 | 2 | 56.0 | Mutates caller intent and supplied files; introduces rollback/ownership obligations. |
| L | 5 | 4 | 2 | 4 | 4 | 4 | 79.2 | Adds unnecessary rejection of legitimate benign configuration. |
| M | 5 | 5 | 4 | 4 | 4 | 3 | 89.8 | Potential reuse; introduces a new policy/configuration interface without a second implementation need. |
| N | 5 | 4 | 3 | 3 | 3 | 1 | 75.0 | Wider temporal protection needs migration and caller contract proof. |
| O | 3 | 0 | 2 | 2 | 2 | 2 | 36.8 | Can execute configured programs, read actual credentials or contact a server. |
| P | 2 | 4 | 4 | 4 | 3 | 5 | 66.8 | Bare CR can split the credential key and forge row-shaped benign text; tab splitting is ambiguous. |
| Q | 5 | 5 | 4 | 4 | 4 | 2 | 89.0 | Can preserve exact bytes; introduces unnecessary process/error/cleanup surface after existing capture proof. |
| R | 5 | 5 | 2 | 4 | 4 | 4 | 83.8 | Needlessly rejects benign opaque contexts; does not replace sound record framing. |
| S | 2 | 3 | 4 | 4 | 4 | 4 | 63.4 | Hides caller override rather than refusing it; surrounding Git still has different source semantics. |
| T | 1 | 3 | 4 | 4 | 4 | 5 | 58.2 | Native-proved empty alternate file hides effective keys with exit0 while origin is unchanged. |
| U | 1 | 4 | 4 | 3 | 4 | 5 | 59.6 | Closes selector bypass but leaves source and key-family finding unresolved. |

F wins at96.6, ahead of the next eligible designs E/M at89.8. It directly satisfies the hard constraints. The preference is rooted in native effective-source coverage, privacy and verification, not just fewer calls. Moving5 weight points from correctness to usability still leaves F ahead of the more permissive H. There is no material unresolved preference or technical tie requiring an owner decision. This worker selects F as the implementation recommendation; root owns integration and operational release.

## 6. Selected action proposal

1. Keep the existing selector, token and askpass checks.
2. Stop if GIT_CONFIG is present, even if its value is empty.
3. Do this check before Git or private staging.
4. Keep the fixed Git executable and configuration isolation.
5. Read effective configuration with `config --null --includes --show-scope --name-only --list`.
6. Stop if the native command fails.
7. Join the captured native lines with one LF separator.
8. Read alternating scope and key fields between NUL delimiters.
9. Require complete pairs and the final NUL delimiter.
10. Stop if the framing or scope is invalid.
11. Keep the refusal of system and global configuration.
12. Treat the subsection text as opaque.
13. Match section and final variable names without case sensitivity.
14. Stop for credential.helper or `credential.<URL>.helper`.
15. Stop for http.extraHeader or `http.<URL>.extraHeader`.
16. Include empty, repeated and reset entries.
17. Keep the exact core.askPass absence check.
18. Use fixed category diagnostics without values, rows, URLs or paths.
19. Remove the two narrower local queries.
20. Keep benign includes and linked worktrees.
21. Preserve supplied configuration and existing isolation changes. Do not silently clear the refused selector.
22. Keep native failure, Windows ownership and cleanup controls.
23. Explain the required absence in helper and runtime documentation.
24. Test the final helper on Windows and Linux before publication.

These instructions use one action per sentence, consistent names and explicit conditions under the owner's ASD-STE100 direction. No formal dictionary certification is claimed. A diagnostic should name the fixed policy category, not echo the key's URL subsection, value or supplying path. Preserve the helper's current temporal boundary: it cannot undo Git or capability probes performed by an earlier caller. The selected product/test/runtime-documentation repair does not require instruction-file or style-guide edits; any later secondary guide assessment belongs to the applicable full-guide review.

## 7. Meaningful validation and writer handoff

All repair tests below are proposed, not executed. The bounded query/transport observations above are diagnosis evidence only. Reuse `r3NativeCredentialRepository` at3556–3569 and `r3CredentialFixture(t,true)` for actual qualified Git. They author minimal isolated ordinary and linked-worktree metadata without commits, network, hooks or host configuration. Extend the existing FQ45 real-config refusal oracle, private cleanup checks and source mutation inverse checks. Use only synthetic inert settings; never inspect host credential stores or invoke configured helpers. Never change production origin expectations to permit a loopback auth probe.

| Scope | Proposed cases and oracles |
| --- | --- |
| Core24 | Four key forms × local/included/linked-worktree source × empty/synthetic nonempty. Each must fail the intended fixed category; no success sentinel, credential lookup or config mutation; current strict Windows private-config cleanup remains required. |
| Effective include routes | Active conditional include for each family; inactive condition positives; a nested include for helper and header. Use established gitdir conditions, not a newly required Git-version feature. Benign includes must continue to pass. |
| Key semantics | Mixed-case section/key; generic and URL-scoped variants; similar unrelated names must pass. Use the existing expected origin and an unrelated synthetic URL context to prove the stated all-context absence rule. Include repeated entries and an empty reset after nonempty values for each family; reject by key presence. |
| Framing and selector | On each platform, actual helper capture of bare CR/tab relevant keys and benign lookalikes, including row-shaped subsection text; exact scope/key pairing and trailing NUL. Test quoted backslash/quote and literal backslash-n/t semantics; malformed LF must fail at native status. Malformed/truncated NUL or unknown scope must fail closed without row disclosure. GIT_CONFIG absent positive and present-empty/configured-empty alternate-file refusals must occur before Git/private staging. Remove the actual selector guard and prove the same included helper/expected origin exposes false success; restore exact source. |
| Positive controls | Ordinary and linked-worktree absence; benign local/included/worktree config and near-key names. Genuine success must use the qualified real Git, not a mock. Keep FQ45 askpass environment/config positives and refusals on final source. |
| Causal controls | Remove each actual helper/header guard and show the same configured input false-passes. Cover each generic/URL family arm. Narrow the effective query to local and show a worktree negative false-passes; disable includes and show an included negative false-passes. Use exact one-change/inverse-equality mutations after the final source is frozen. Include a line-framing mutant with a relevant CR subsection and a broad family-match mutant with a benign lookalike. |
| Native failure/cleanup | Malformed included config or include recursion must fail at effective-query status rather than look like key absence. Preserve independent origin-resolution and Windows Git-version failures. Check bounded logs, no supplied-config changes and proved private cleanup; retain uncertain cleanup evidence. |
| Callers | Exercise both actual initializer and Markdown launcher at their real helper-call boundary with an included helper and a worktree header. Refusal must prevent subsequent download/dependency/lint publication. Existing earlier Windows capability probes are outside that claim. No whole-caller acquisition acceptance is inferred. |

One writer must own Test-CiHelpers.test.mjs for FQ46/FQ47/FQ48. This analysis owns no product path. The writer must update mocks that currently return absence from --get-all/--get-regexp to express NUL-framed effective scope/key pairs instead; move relevant unexpected-status assertions to the effective query. R3/FQ45 mock call-count assertions currently expect4 Linux/5 Windows calls; removing two queries changes those counts to2/3, so update the expectation without weakening refusal or dispatch oracles. Do not hardcode a fresh total or claim reuse from old registration names; root will derive affected scopes from final source dependencies.

Root must first integrate the selected decisions and freeze the combined candidate. Then validate shipping/generated PowerShell syntax and applicable analyzer/style rules, meaningful current-source Windows/Linux tests, actual required hooks, independent final quality and current remote review/CI. Prior process/Job qualifications retain their exact origin; source changes alone do not justify qualification replay or blanket runtime reuse. Root owns the current counters, deadline, native receipts, state, paired16-path handoff and later publication. This proposal leaves A07 transfers9/12, PR round5/80 and original2026-10-16T22:53:27.970214Z deadline unchanged.

## Evidence pins and scope

Root12-case query evidence: SHA65ead33ab8320dd7db0cddd4de3cc6e0af9b31ac7e15f187cf3d610331602252. Root GIT_CONFIG selector evidence: SHAac150fd05011000cc3419561ac93773f35ece640c949792757b61202bac5bffc. Paths and all private transport scripts, authored metadata, raw names/scopes observations and failed-attempt receipts are pinned in evidence.json. Root's first stopped query setup attempt remains in its own preserved namespace; no native failure has been relabeled as success.

F is the clear selected proposal at96.6 after the complete source, selector and framing assessment. The highest eligible alternatives score89.8. No protected product/driver/planning/state/STATUS or remote file was changed. This handoff is ready for root's one shared writer and frozen current-source validation; it grants no runtime acceptance.

Root selection: F96.6. Root read the complete21-option record and sampled score arithmetic. Complete options, rubric and scores were displayed before implementation release. The canonical wording preserves existing process isolation while forbidding silent removal of the rejected selector. Product implementation and current-source testing remain pending. This file is the canonical finding record.

Root implementation readback found that the default string EndsWith overload is unsuitable for literal NUL framing. Native qualified PowerShell7.6.5 probe7aad0b/0 returned true for no NUL, a final NUL, and a NUL followed by text; explicit Ordinal returned false/true/false. Root directed the shared writer to use literal ordinal framing and the selected explicit OrdinalIgnoreCase key comparisons, with missing-delimiter and trailing-fragment negatives. This implements the existing selected framing contract; it does not grant helper acceptance. The selector-removal causal fixture uses a benign nonempty alternate config so the independent strict-framing refusal does not mask that control; the configured-empty-file early-refusal test remains required.
