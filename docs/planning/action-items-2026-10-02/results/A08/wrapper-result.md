<!-- markdownlint-disable MD013 -->
# A08 bounded read-only result

RESULT: command-content no-change recommendation with seven exact necessary differing lines. This is preparation, not A08 product acceptance. A02 is an unaccepted implementation predecessor. The independent [root assessment](assessment.md) corrects the initial budget/fresh-pass concerns and selects causal attribution plus resume reconciliation. No PR is justified for the wrapper itself.

Requested route: gpt-6.1-sol/medium. Effective settings were not exposed. No descendants. Dedicated scratch only. Transfers 0/8. No PR round, clock, pending request, public comment, review, request, settings change, repository edit, commit or push.

## Source identity and reproducibility

Git object reads, not planning checkout files, supplied all product source. Authenticated `gh api repos/OWNER/REPO/git/ref/heads/main --jq .object.sha` confirmed the same native refs during preparation.

| Source | Native main | Tree | Command blob / mode |
| --- | --- | --- | --- |
| PS | 48f4d8a36c8faceee12afac78aaecea0d176125d | 640ee4c0974fb604b2ebf0a1e1e1a328bd213ddc | 8f361e184eef8b292370d1d6e5b00425ab8226c2 / 100644 |
| TF | 06ad4f7c9b6847028cafdacf1ae55128d0f2d56c | dc8f6b82588b8f874d34cd5d0155791aea5793f1 | 62b63fabdc8ce64ede8539b884aa904a46cb3eaf / 100644 |

Source-evidence.json includes four governed source paths per repository, raw SHA-256/size/mode, actual planning checkout identities and exact differing lines. Command SHA-256: PS `4e8a06fb11542176a77c988e522d88807c81f15910542638b9b4baaf4c363cd3`; TF `eb877158c2bf1ca1cafcdd343214c2865dc2816b6e7a42f54bee50dc571d1437`. Both have 53 LF-only lines. All 46 other raw lines are byte-identical. `command.diff` is only a display aid; byte comparison used subprocess Git bytes.

PS planning checkout observed HEAD e0b6765d4bc4772d20a5d101b2daddfce3c1ca1a. TF planning checkout observed HEAD 8e852a9f4fd382a122f32c1ce7461796f8762f8e. Both branch names were planning-CRT-PR-852. These are not product inputs.

## Decision A08-D1: exact repository and issue exceptions

Validated finding: lines 2,17,23,25,39,46 differ only in repository name and the issue link. The command is deliberately repository-local. An identical literal allowlist would reject the correct peer or permit the wrong repository. An identical implementation-issue link would falsify one origin. Authenticated reads show PS163 is the closed thin-command issue, and TF56 is the closed command-convergence issue. Closed historical implementation issues remain valid Related links; the command does not attempt to reopen them. Relative `../../CLAUDE.md` resolves from `.claude/commands/` to the root CLAUDE.md in both trees; both paths exist.

Stakeholders: both maintainers, invoking contributors/agents, remote reviewer operators, instruction/security reviewers and history custodians. Correct target selection protects repository authority. Readers need accurate examples and origin links. Cost owners bear unnecessary runtime configuration. This decision adds no private-data flow, infrastructure/release change or translation/accessibility change.

Options before scoring: A retain the six narrowly differing identity lines. B force identical literals. C introduce common runtime code/configuration or dynamic repository inference. D remove explicit repository identity/origin. A shared static skeleton plus per-repository literal configuration is already A; a separate generated/configuration framework is C. Removal plus dynamic inference remains C or D. Deferral adds no useful evidence because current identities are verified.

Fresh rubric: 1 poor to 5 strong; target correctness35%, authority boundary25%, new-reader clarity20%, durable maintenance15%, implementation burden5%. Total `sum(weight*score)/5`. Hard constraints: no authorization expansion, false issue origin, moving external instructions or new runtime dependency. Scores are judgments.

| Option | Correctness | Authority | Clarity | Maintenance | Burden | /100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 4 | 99 |
| B | 1 | 1 | 2 | 4 | 5 | 37 |
| C | 5 | 4 | 3 | 2 | 2 | 75 |
| D | 1 | 1 | 1 | 2 | 4 | 26 |

Selected solution: Keep the six exact identity lines. Keep the remaining shared lines identical. Do not add runtime configuration. Use each command only for its named repository. Recheck the exception when the owner, repository URL or implementation origin changes. One identical wrapper cannot retain both fixed literal authorities without configuration; adding that framework brings no supported benefit to these two static wrappers.

## Decision A08-D2: factual update-date exception

Validated finding: line15 has PS2026-09-22 and TF2026-09-23. Native file history ties PS last change to 80c61b57fe4c578f76f106f979f4dcb422727bd3, 2026-09-22T17:29:44-05:00 (UTC September22), and TF to 500b9ba82920cc4cb2aa0d7e78cb18298a16707b, 2026-09-22T23:26:10-05:00 (UTC September23). Metadata therefore records different factual last changes. No current substantive wrapper edit requires bumping either date. The full dated source log is in PS-command-history.txt and TF-command-history.txt.

Stakeholders: documentation maintainers, readers, metadata validators, auditors/history custodians and future synchronization workers. Review services use behavior rather than the date. No security boundary, infrastructure, private-data or user accessibility behavior changes.

Options before scoring: A retain each factual date. B normalize to one date without substantive edit. C remove the date. D move dates to a separate history/configuration record. Changing both wrapper contents for a real future reason is outside this present no-change finding; it must use actual finalization metadata then. Deferral collapses to A pending a real edit.

Fresh rubric: history truth50%, reader utility25%, unchanged semantics20%, churn5%; scores1–5, total `sum(weight*score)/5`. Hard constraints: no fabricated update history or unsupported metadata removal.

| Option | Truth | Utility | Semantics | Churn | /100 |
| --- | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 4 | 5 | 5 | 95 |
| B | 1 | 3 | 5 | 4 | 49 |
| C | 2 | 2 | 5 | 3 | 53 |
| D | 4 | 3 | 5 | 2 | 77 |

Selected solution: Keep each factual update date. Record line15 as a narrow historical exception. Recheck it after a substantive command change. Equal metadata would require changing a true source fact; separate configuration does not improve this static historical field.

## Actual command interfaces and examples

The description, argument-hint and `$ARGUMENTS` define a manually invoked command with one PR URL. `disable-model-invocation: true` does not establish a Claude tool in this Codex session. Current official Claude documentation supports command files and these frontmatter/argument forms. The filename grants no review-service, timer or outage authority.

Static walkthrough of all five written examples: valid target requires authenticated canonical identity/open/unmerged readback then delegates; missing target asks for URL; wrong repository stops before mutation; closed/merged target stops; unavailable or ambiguous readback stops. Draft preservation is explicit in the main target instructions and valid-result text. Malformed URL, wrong host and unauthenticated readback are also explicitly rejected outside the example list. No executable URL parser is supplied, so these are instruction inspections, not executed adversarial/parser tests. Readback failure is not treated as a missing PR or authority to retry a public write.

Command lines31–35 require local root CLAUDE.md, co-equal remote Copilot/Codex findings and the complete root process. They copy no numeric step count, retry limit or orchestration state. No duplicate request receipt, automatic wakeup claim, external moving-branch fetch or shared runtime dependency appears. Do not duplicate those policies into the wrapper.

## Root governance assessment and escalation

Root source identities are in source-evidence.json: PS CLAUDE blob3bb0afcae09e05b6a8022d339b12721e8a1473d2; TF CLAUDE blob3cc21fc793944033be430ad08722081db4e7b9dd. Frozen A02 protected patches preserve the following loop clauses. They compact other evidence/placement provisions and do not authorize unrelated A08 edits.

1. **General arrival-attribution concern, escalated.** PS CLAUDE346,357–361 / TF362,373–377 records request head/baselines then defines new-review detection by author plus timestamp. It treats fresh comments as sufficient arrival evidence; with no baseline it accepts any bot review/comment as new. The later clean gate PS369 / TF385 still requires current-head reviews, so this is not evidence that an old review can pass that final gate. It is an insufficient causal arrival predicate, especially for headless remote comments, and does not itself bind material body input. A delayed old-input bot comment newer than the baseline meets the written arrival predicate. No live request or exploit was performed. The goal LOOP-POLICY protocol1,3,4 supplies authenticated baseline exclusion, request time and exact-input attribution now. That procedural protection for this goal does not change general root bytes. Route any design/repair at gpt-6-astra/high after a complete finding-specific decision and exact protected authority.
2. **General same-input request concern, escalated.** PS412 / TF427 explicitly requests a fresh pair even when no code changed and all findings were addressed without action. A nonmaterial factual correction or decision can therefore trigger repeated same-input review outside this goal. This conflicts with original controller guarantees retained by A00. Current goal LOOP-POLICY6–7 requires new rounds for changed head/diff/material scope and stops with both clean; it handles this goal safely. Do not activate the old controller to repair this clause. Route root-policy design with item1; no new protected proposal is made here.
3. **Balanced transport already defined.** PS304–317 / TF320–333 makes Balanced UI preference control transport and permits quoted CLI @copilot/REST bot-login fallback; PS346 / TF362 generic `request_copilot_review or equivalent` must obey that earlier explicit transport rule. It is not authorization to bypass Balanced selection. The wrapper delegates the whole root file. No new wrapper clause is needed. CLI/public REST fields do not expose effort; observed effort must come from overview/timeline. No actual review effort was observed in this preparation.
4. **Reviewer equality already defined.** PS325 / TF341 requires Copilot and separate remote Codex, exact `@codex review`, pending suppression, explicit scoped outage substitution and distinct identities/results. Review handling PS172 onward / TF188 onward includes both inline threads and complete review bodies. Local agent output cannot replace remote Codex. Old historical outage grants are not reused.
5. **Goal-specific limits already settled.** Current product main has80rounds and6hours (PS329,414–423 / TF345,429–438), The inspected CLAUDE sections have no optional8round clause; AGENTS separately retains its optional8-round/6-hour Codex cycle. The current goal’s owner80rounds/8elapsed days overrides these older limits only for this execution. This is not a product-wide limit amendment. Nothing in the wrapper copies those limits. Do not manufacture a root change simply to match a goal-specific instruction.
6. **General resume resets budgets, escalated.** PS432 / TF447 explicitly resets the round counter and timeout on resume and starts a fresh request. The surrounding clause requires an explicit PR-owner resume comment. The independent assessment treats that as general new-invocation authority and selects reconciliation of still-pending requests; it does not classify the owner-authorized reset itself as a defect. Current goal LOOP-POLICY forbids resets across pause/resume/restart and preserves pending reconciliation. It supplies the execution rule now. Product repair remains a higher-route protected design decision; no edit or authority is inferred.
7. **Wakeup is not automatic.** PS335 / TF351 permits a runtime timer pattern; it does not create one. The current goal requires a user request for future scheduled wakeups. No automation was created or claimed. No unsupported product promise was found in the wrapper.

## Original requirements and retained dispositions

original-dispositions.json preserves each of37 ledger rows, original source hash, historical credit, policy and owner. original-contracts.txt retains the consulted original bodies. No historical lifecycle is replayed here.

- IDs10–18: A00 review-controller disposition stays **unverified**. Exact input, semantic changes, two reviewers, truthful failures, pending suppression and restart-safe reconciliation remain useful obligations. This command assessment does not prove controller schemas, serializers, deterministic scenario suite, 10/15-minute performance or historical planning lifecycle. The old controller remains inactive. Current manual goal orchestration is sole authority.
- ID155: prior commencement is not recreated. ID156: current thin-command contract is satisfied by source inspection for URL requirement, local delegation, equal reviewers and no copied volatile count; agent/lint execution and final predicate await prerequisites/integration. IDs157–161: old PR creation/review/quality/merge/handoff history is retained; no new PR manufactured. Historical COMPLETE_VERIFIED credits159,160 remain preserved rather than current product acceptance.
- IDs162–170: current reciprocal command comparison is available; no peer repair indicated for wrapper bytes. Historical COMPLETE_VERIFIED credits167,168,169 remain preserved. Other lifecycle original predicates remain unverified and are not fabricated by this read-only result.
- IDs171–181: reverse comparison also finds only the exact seven exception lines. Product fixed-point closure still needs accepted A02 and disposition of applicable root concerns; no final closure is claimed.
- ID182: historical Terraform31 umbrella includes five wider cycles. Command parity alone cannot close it. Keep A19 reconciliation across the owning outcomes; no issue mutation or success label.
- A00 R01 remains a replacement of duplicate PR-body identity machinery, not proof that its automatic writer was implemented. Current native input identity remains required. R06 contributor-owned artifact path is not review-controller implementation.

Reduced original reciprocal catalog: GF-PARAMETERS applies to required PR URL/$ARGUMENTS and empty/malformed/lifecycle handling; GF-DESTINATION to fixed owning/base repository and local CLAUDE authority; GF-CONTENT to root delegation, co-equal findings and the exact identity exceptions; GF-SERIALIZATION to verified UTF-8/LF raw command bytes; GF-HOSTS to documented Claude command support only, not live invocation; GF-VERSION to factual dated metadata. GF-FAILURE applies to no-readback/no-mutation stop. GF-EVIDENCE applies to raw pinned identities and explicit no-native-mutation limits. GF-WRITE, GF-NODE-LOCK, GF-YAML, GF-ACTION-PINS, GF-ACTION-INPUTS, GF-GIT, GF-GRAPH and GF-CREDENTIALS are not implementation changes in this Markdown-only wrapper; their wider foundation obligations remain with A02/A03/A06/A07/A09/A18. No foundation/security equivalence is inferred from this reduced catalog.

## Validation and next action

Observed: inspect.py and verify.py completed exit0 using Python3.12; verify.py checked the raw exception boundary, strict UTF-8/BOM absence, shared delegation,37 disposition rows and all score totals. raw Git comparisons are53/53 lines,46 equal,7 classified; all modes100644. Authenticated issue and main-ref reads completed exit0. Command links/metadata/history and all written input examples were inspected. No product lint, agent validator, live Claude command, PR review, pending reconciliation or reviewer-service behavior test ran. This preparation must not be reported as those tests passing.

After A02 acceptance, refresh both native heads and actual root protocols. Parent must assess the escalated root concerns at the higher route and decide their current applicability. If no relevant source changes, reuse this wrapper proof; do not create a wrapper PR. If a protected root change is selected, finish its decision, exact authorization, PS-first implementation/review/quality/merge and reciprocal lifecycle. Verify Markdown outer/nested lint, affected agent-instruction tests and relevant negative attribution cases for that actual candidate. Test old-input arrival, pre-request result, unauthenticated actor, incomplete pagination, material same-head scope, ambiguous accepted request and same-input nonmaterial correction. Use fixtures for any executable consumer introduced; do not claim prose tests implement native reconciliation. Refresh source identity after each landed change.

References checked2026-10-02:

- [Claude command/skill documentation](https://code.claude.com/docs/en/slash-commands): command files accept these frontmatter fields; arguments expand through `$ARGUMENTS`; model invocation can be disabled. No local Claude runtime was exercised.
- [GitHub Copilot effort](https://docs.github.com/en/copilot/concepts/agents/code-review#review-effort-level): PR Reviewers allows effort selection; overview reports used effort.
- [GitHub CLI pr edit](https://cli.github.com/manual/gh_pr_edit): @copilot is the documented special review-request value; no effort flag is exposed.
- [GitHub review-request REST](https://docs.github.com/en/rest/pulls/review-requests?apiVersion=2022-11-28#request-reviewers-for-a-pull-request): request body accepts user logins/team slugs, with no effort field. No request was sent.

Coordinator review: eight raw native source hashes and Git modes verified. The linked independent assessment controls the final interpretation of root-protocol concerns. This copied report retains the original37 dispositions. Detailed source histories, inspection scripts and raw contract excerpts remain in the named scratch directory; no product runtime acceptance is claimed.
