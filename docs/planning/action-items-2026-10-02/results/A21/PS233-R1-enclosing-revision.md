<!-- markdownlint-disable MD013 -->
# PS233 R1: enclosing PowerShell revision

Selected by root after complete display on2026-10-05: **N96: retain the current product bytes and refute the claimed mandatory enclosing increment**. Root read the report, verified the frozen report/evidence hashes, sampled three raw Git objects and checked the scores and probe. No product change is required. Native disposition follows this decision; automatic and manual review results remain distinct. Private source report SHA256c3760b298697bddcd87e548b509768390a02451935f80388b2f1314720d21a81; evidence SHA25687e2114fbc80b432aade720378c2da16d4d8bb80644da112fc0f9a72cecbba4a.

Reviewed input: PS233 H `4783da302e26515d770bad716f02297fe3b08a8d`, published B `f0684acd81a1a6e53d87e43881c1ec4f1310b17c`. Automatic Codex review5418629513/comment4187129240/thread `PRRT_kwDOQkjdhM6pJwxd`, authored by bot199175422, identifies the correct H and claims that the two documentation-only helper changes require top-level line26 to advance from `1.18.20261005.0` to `.1`. Root's complete authenticated `round1-resume-reconciliation.json` supplies attribution. This assessment does not turn the automatic result into the separately required manual-review result.

## 1. Validate the actual claim

The factual premise is correct: B already publishes enclosing `1.18.20261005.0`, and H changes two internal Version annotations to `.1`. These are genuine new documentation bytes relative to the destination's published B. They are not merely unpublished PR232 iterations. However, the alleged mandatory enclosing assignment does not follow from the actual rule.

Actual B/H `STYLE_GUIDE.md`:1023–1041 requires a four-part Notes version; defines the previously published value for the same function or script; requires the current Build date for any modification; and explicitly introduces the revision arithmetic with **“When a `.NOTES` version is assigned or updated”**. Its examples include comment and documentation changes as possible same-day updates. They do not delete that assignment condition or require every enclosing unit to be versioned for every nested metadata edit.

The unchanged accepted `STYLE_GUIDE_RATIONALE.md`:347 removes the possible frequency ambiguity: **“The requirement is scoped to the calculation performed when a version is assigned or updated. It does not dictate how often a project publishes or versions a function or script.”** This explanatory text dates to commitf8b9a3f2, June21; it was not added for PS233 or this finding. The rationale does not override a normative MUST. Here it explains the exact condition already present in the normative sentence. The subsequent N+1 example and provenance discussion must be read within that condition.

Actual AGENTS45–48 requires PowerShell conformance and zero parser/analyzer or uncovered MUST violations. It supplies no additional mandatory publication frequency or enclosing-version trigger. The current enclosing Build is already the genuine October5 modification date. No Major/Minor change is warranted because the validator's function, feature and interfaces are unchanged. Its existing enclosing field is not assigned or updated by this patch, so the conditional revision calculation does not require a new value there. Conversely, each of the two edited helper fields *is* updated: both retain their published Major.Minor.Build and therefore correctly use published revision0+1. Unchanged other annotations are not blanket reassigned.

The current main-validator raw diff has exactly lines5415 and6207; line26 is identical at B and H. Previous token evidence proves49,541 noncomment tokens unchanged. The complete main-validator postimage equals accepted TF e21b74f, and no semantic/public interface or top-level help prose changed. These facts bound this decision; executable equality alone would not excuse a version assignment that violates the rule.

### Earlier decisions and their limits

PS232 R3 A97.2 preserved enclosing fields while correcting49 helper help values. Its warning against an “in-progress increment” was appropriate to that PR but is not sufficient justification for today's already-published B. This assessment rechecks today's actual published `.0` and does not transplant that historical rationale unchanged.

The later PS232 carry-back and six-path readiness records explicitly apply the conditional assignment rule to the destination and preserve enclosing1.18 on October5. The post-TF67 readiness and released two-file model repeat that interpretation. They remain applicable because the governing source, actual tuple, date and metadata-only scope match. Their prior acceptance is supporting history, not evidence that an interpretation can never be wrong. The decisive evidence is the normative condition plus its explicit accepted explanation.

### Actual selector and projection boundaries

The successful aggregate and actual endpoint/finalization commands do **not** demonstrate automatic enforcement of PowerShell Notes versioning. The validator has no such general Notes consumer. `Get-DiscoveredGovernedMarkdownDocumentPath`:5933–6056 selects Markdown/mdc paths; its suffix filter at6008 excludes `.ps1`. The explicit governed-document construction at7594–7620 and7844–7899 adds document paths, not the validator as a Notes-versioned document. The validator's presence in the push-governed input set at85–87 and staged executable input checks at7674–7683 protects policy/input admission; it does not add Notes-version parsing.

`ConvertTo-MetadataComparisonText`:4246–4319 masks only the validated document-level `**Version:**` and `Last Updated` lines, then applies specific mechanical whitespace normalization. It is not a universal semantic projection that strips arbitrary PowerShell comments. `Get-PublishedEndpointMetadataFailure`:6651–6708 computes Markdown revision obligations from that comparison or a changed document revision. That distinct Markdown policy must not be projected onto PowerShell `.NOTES` or used to claim internal notes vanish from rendered documentation.

A bounded Windows PowerShell7.6.5 discriminator extracted only these two exact production functions through their AST. The selector returned `sample.md` and `sample.mdc`, excluding the real validator path. The projection treated a valid document-header Version-only change as equal and retained a body `# Version:` change as different. Exit0/parser errors0. It did not execute the validator or rerun its aggregate. This proves enforcement scope, not the normative conclusion above.

The P1 label is not supported by a demonstrated runtime, security, admission or provenance-contract failure. The same enclosing label is less granular than a separate label for every artifact, but the repository explicitly permits version-frequency choice. Git H/B identify the exact changed artifact; this is not a promise that Notes alone uniquely identifies every Git commit.

## 2. Stakeholders and concrete outcomes

- Both maintainers and the owner need the actual rule applied consistently, truthful current dates, and common implementation bytes without invented exceptions.
- Script consumers, support operators and audit/history readers benefit from ordered assigned versions and exact Git provenance. A top-level `.1` would provide an extra artifact distinction; it is a legitimate optional benefit, not demonstrated repair of a mandated missing distinction.
- New contributors, human/automated reviewers and documentation authors need the distinction between version-frequency policy and arithmetic explained clearly. They must not infer a recursive assignment rule from examples or mistake passing Markdown validation for Notes enforcement.
- QA, CI/platform and agent operators need meaningful tests, input-specific acceptance and no new self-referential Notes linter merely to adjudicate this one comment.
- Security and supply-chain reviewers need existing policy selection, staged identity, validation boundaries and truthful service attribution preserved. Both N and R retain these equally; no option receives security-repair credit for changing a comment.
- Project and cost stakeholders need useful improvements selected on merit. Avoided transfer/runtime cost is a small secondary benefit and cannot justify violating a genuine rule.

No new credential, cloud, customer-data, accessibility, localization, dependency, generated-artifact or external runtime contract is implicated. Those categories do not change these options. Both repositories' consumers and the existing finite convergence lifecycle are included.

## 3. Material options before the rubric

| ID | Option | Benefit and residual |
| --- | --- | --- |
| N | Keep enclosing `.0`; explain the conditional assignment rule and close the finding with source evidence | Correct existing rule application and current shared bytes. The top-level label does not distinguish this helper-metadata-only artifact from B; Git and the edited helper fields do. |
| R | Voluntarily assign enclosing `.1`, then perform an actual TF comparison and any required follow-up | Lawful N+1 if deliberately assigned on October5; more granular top-level provenance. It introduces a new assignment beyond the two helper fields and another shared delta without a demonstrated requirement. |
| G | Propose a protected normative clarification/change requiring an enclosing version on every nested/documentation change, then apply R | Establishes a stricter future frequency contract. Changes the existing deliberate scope; protected guide/generated authority and broader contract analysis would be required. No present defect needs this expansion. |
| L | Add a Notes/enclosing-version validator and tests, with R | Automates the reviewer's proposed frequency rule, but invents a new selector/parser and policy boundary that the current rule does not mandate. Enforcement must follow a justified policy, not create one. |
| A | Assign new same-day versions to every enclosing and helper unit in the touched script | Makes blanket file-touch versioning explicit; loses useful unit distinction and creates numerous unsupported assignments/peer deltas. No current rule requires unchanged functions to be republished. |
| D | Leave the bytes now but defer the enclosing-version question as unresolved work | Retains the candidate temporarily but leaves an answerable finding unsettled and adds an obligation without an external dependency. |

R plus a factual response is R; N plus the bounded evidence is N. A code comment that repeats the rule adds another unnecessary product edit and offers no benefit over N's finding disposition. Removing version metadata violates the existing presence requirement. Resetting Major/Minor, inventing a date, or reverting the two lawful helper assignments to avoid the concern fails the established semantic/date or convergence constraints. A necessary repository-specific exception is unsupported because no language or consumer distinction requires this shared file to differ. No new factoring/helper/dependency is useful for two numeric documentation fields. G/L combinations collapse into the policy-plus-enforcement expansion.

## 4. New finding-specific rubric

Score0 means absent/harmful,1 major gap,2 partial,3 adequate with material residual,4 strong with a bounded limit,5 full scoped fit. Total is sum(weight*score/5). These are comparative engineering judgments, not measurements of runtime reliability. Criteria and weights are set for this finding before the table below.

| Criterion | Weight | Meaning |
| --- | ---: | --- |
| Existing policy fidelity | 35 | Apply the actual frequency/assignment condition, destination baseline and genuine-date arithmetic without inventing a MUST or exemption. |
| Honest provenance | 20 | Preserve ordered assigned values and explain exactly which artifact/unit the evidence identifies. |
| Precise unit and change scope | 20 | Apply assignments to demonstrated changed/versioned units; avoid creating a new frequency contract or unrelated version churn. |
| Runtime and authority preservation | 10 | Retain executable behavior, selectors, security, tests and protected-file boundaries. |
| Common-result coherence | 10 | Preserve or deliver the same supported shared result through truthful accepted-main comparison, without unearned differences. |
| Discriminating verification | 4 | Prove actual source/consumer facts without treating nonapplicable green tests as rule enforcement. |
| Delivery effort | 1 | Complete the bounded disposition without unnecessary lifecycle or framework work. |

Hard constraints: no backdating, invented semantic bump, forbidden protected edit, dropped helper assignment, concealed peer difference, weakening of existing acceptance gates, or claim that tests decide the natural-language frequency rule. No optional top-level label is inherently unsafe. Root remains the only public/product release authority.

## 5. Scores and selection

| Option | Fidelity35 | Provenance20 | Scope20 | Preservation10 | Common10 | Verification4 | Effort1 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 5 | 4 | 5 | 5 | 5 | 5 | 5 | 96.0 |
| R | 5 | 5 | 3 | 5 | 3 | 4 | 4 | 87.0 |
| G | 3 | 5 | 2 | 3 | 2 | 3 | 1 | 61.6 |
| L | 2 | 4 | 2 | 3 | 2 | 4 | 1 | 51.4 |
| A | 3 | 2 | 1 | 4 | 2 | 3 | 1 | 47.6 |
| D | 4 | 3 | 2 | 5 | 3 | 3 | 3 | 67.0 |

N is the unique winner at96. Arithmetic:35+16+20+10+10+4+1=96. R:35+20+12+10+6+3.2+0.8=87. All totals are checked in `PS233-R1-evidence.json`.

N and R both earn full policy fidelity and runtime preservation: a voluntarily assigned `.1` is allowed, and retaining the already-current unassigned field is allowed. R earns the provenance advantage for its new top-level artifact label. N's scope/common advantage reflects concrete absence of any required enclosing assignment and the already identical complete accepted-peer file; it does not assume that all peer edits are bad. Even eliminating the entire10-point common-result criterion leaves N ahead by5 points. G/L are not eligible for execution under the current release and change the deliberately limited contract; their lower scores reflect that policy mismatch, not merely permission inconvenience. A obscures which units changed; D has no unavailable fact or authority needed to resolve this finding.

The deciding fact is explicit accepted policy scope, not a preference between tied numerical scores. The full assignment-frequency sentence makes the reviewer's asserted mandatory implication false. R remains an optional enhancement, but this finding supplies no consumer needing it. No owner preference question or new permission is necessary for N.

## 6. Selected controlled-English action

1. Keep `Test-AgentInstructions.ps1` unchanged at H4783da3.
2. Keep enclosing `1.18.20261005.0` while the actual modification date remains October5 and the accepted inputs remain unchanged.
3. Keep the two assigned helper revisions at `.1`.
4. Explain the assignment condition and accepted rationale in the finding disposition.
5. State that the existing Markdown checks do not enforce PowerShell Notes versions.
6. Treat comment4187129240 as a refuted mandatory-change claim after root reviews this decision.
7. Let root publish one bounded reply and resolve the thread through the normal protocol.
8. Preserve the automatic review's finding history and the separate manual-review and Copilot results.
9. Reassess if the date, published baseline, policy, script behavior or selected field assignments change.
10. Continue the existing PR lifecycle and actual accepted-main comparison.

These are short controlled-English instructions; no formal ASD-STE100 dictionary certification is claimed. Proposed product changes: none. This report is not itself a native reply or resolution.

## 7. Evidence, candidate and peer implications

The bounded selector/projection probe ran once with fixed PowerShell7.6.5 and exited0. The full previous focused parser/analyzer,49,541-token equivalence,11 manifest tests and20-call wrapper equivalence remain valid at their recorded scopes because product bytes did not change. Root's final aggregate and endpoint results are reused only for what they actually validate; no suite, aggregate, dependency acquisition or requalification was repeated here.

`PS233-R1-evidence.json` includes the actual review/comment, source excerpts/raw identities, exact two-line B/H delta, canonical decision hashes, scores, probe command/output hash and complete before/after source/index guards. HEAD, branch, all tracked raw bytes, raw index, stage0 and clean status remain identical. `PS233-R1-probe.ps1` and `.log` are private. An initial source read used the planning checkout path and a broad temporary-file lookup was unproductive; both were read-only and were corrected to the exact product path/scoped sources. No product or test outcome was inferred from those lookups.

N changes neither candidate H nor review-facing implementation scope, starts no new round and consumes no transfer. Root must still complete actual reviewers, independent final quality, native/landed gates and accepted-main comparison. A07/A21 remain4/12 for this existing PS repair. No broad task completion is claimed.

R would change H and the PR's assertion that the enclosing field is preserved, invalidate changed-input review acceptance, and introduce a top-level-note difference from accepted TF. It would require the normal repair validation/lifecycle and, if still applicable after PS acceptance, a released A21 transfer5/12 to TF. A07 would remain4/12. On the same day and unchanged TF baseline, TF could legitimately adopt `.1` from its `.0`, restoring equality. Therefore an extra increment does **not** inevitably cause endless version ping-pong. Its extra transfer is simply unnecessary under the selected current rule. On a later date, actual Build and revision arithmetic must be recomputed for affected units; do not fabricate a date or promise current byte equality.

Primary local sources were read from the named immutable Git objects; no external behavior needed research. Reviewer-facing references: [normative versioning](https://github.com/franklesniak/PSStyleGuide/blob/f0684acd81a1a6e53d87e43881c1ec4f1310b17c/STYLE_GUIDE.md#function-and-script-versioning), [accepted revision rationale](https://github.com/franklesniak/PSStyleGuide/blob/f0684acd81a1a6e53d87e43881c1ec4f1310b17c/STYLE_GUIDE_RATIONALE.md#function-and-script-versioning-revision-counting), [actual candidate](https://github.com/franklesniak/PSStyleGuide/blob/4783da302e26515d770bad716f02297fe3b08a8d/.github/workflows/Test-AgentInstructions.ps1), and [finding](https://github.com/franklesniak/PSStyleGuide/pull/233#discussion_r4187129240). Planning decisions provide supporting interpretation and history; the accepted rule text and actual product/native records remain the authority.
