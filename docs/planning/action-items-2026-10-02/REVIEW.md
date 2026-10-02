<!-- markdownlint-disable MD013 -->
# Independent plan review and resolutions

The read-only audit worker reviewed the drafted current tasks, issue coverage, dependencies, byte verification, loop limits and authority. It found the five live issues covered and the material retirement losses explicitly assigned. It raised three P2 findings. Requested worker settings were `gpt-6-astra/high`; effective settings were not exposed. The parent checked each finding against the actual text before changing it.

Scores are 1â€“5. Weighted totals below are recomputed from the displayed criterion scores; they supersede preliminary chat estimates.

## CR1: Residual trigger scope was inconsistent

**Validation.** A14's scope permitted repair only after a supported failure, while its work text and PS155 allow an admitted competing-writer requirement, useful API improvement or changed authority. The narrower sentence could suppress legitimate preventive work.

**Stakeholders.** PS155 owner; generator/verifier maintainers; security engineers; operating-system/runtime specialists; current and future callers; independent reviewers; downstream users; cost owner.

**Options.** A: keep failure-only scope. B: permit any speculative hardening. C: use the complete evidence-based trigger set and require a scoped finding decision. Combining A with a hidden exception retains ambiguity; a threat-model expansion is valid only when actually admitted under C.

**Rubric.** Supported-risk coverage 45%: include all relevant admitted triggers. False-work avoidance 30%: reject speculative framework restoration. Clarity 20%: one consistent condition. Implementation effort 5%.

| Option | Risk coverage | False-work avoidance | Clarity | Effort | Total |
| --- | ---: | ---: | ---: | ---: | ---: |
| A | 2 | 5 | 3 | 5 | 65 |
| B | 5 | 1 | 2 | 5 | 64 |
| C | 5 | 5 | 5 | 4 | 99 |

**Selected action.** Use C. Make the scope match the complete trigger list. Require evidence and a finding decision before repair. Do not use a date or version change alone as a trigger.

## CR2: Serialize review requests across changed inputs

**Validation.** The policy prevented duplicate requests but did not explicitly prevent a new-head review pair while a previous input still had an issued request pending. This can make headless result attribution ambiguous.

**Stakeholders.** Authors; Copilot/Codex review consumers; service operators; independent reviewers; coordinator and restart operators; maintainers merging the candidate; cost owner.

**Options.** A: overlap request sets for different inputs. B: stop all local work until all results arrive. C: permit safe local repair but serialize different-input request sets. C can preserve a terminal old result as history; it cannot turn a pending request into a clean result.

**Rubric.** Attribution correctness 45%; duplicate/request collision prevention 30%; useful progress 20%; implementation effort 5%.

| Option | Attribution | Collision prevention | Progress | Effort | Total |
| --- | ---: | ---: | ---: | ---: | ---: |
| A | 2 | 2 | 5 | 5 | 55 |
| B | 5 | 5 | 1 | 5 | 84 |
| C | 5 | 5 | 5 | 4 | 99 |

**Selected action.** Use C. Keep pending requests bound to their old input. Allow local repair and tests. Wait for each issued old-input request to reach an authenticated terminal result or applicable terminal reconciliation before sending the next input's request set. Record supersession honestly. Never reuse an old clean result for changed bytes.

## CR3: Revalidate completed conditional decisions when assumptions change

**Validation.** A12/A14 can assess protection or residual triggers early. A03/A06 can later change check sources or generator behavior. The old wording refreshed active workers but did not explicitly reopen completed conditional assessments. A no-trigger result could become stale.

**Stakeholders.** Issue/risk owners; protection administrators; generator/workflow maintainers; independent security and quality reviewers; integration maintainers; users of current guide artifacts; coordinator/restart operators; cost owner.

**Options.** A: trust the original conditional result forever. B: rerun all tasks after every merge. C: record each conditional result's relevant inputs and reopen only affected decisions. A plus a final generic assertion still lacks evidence; B repeats unrelated work. C includes a final current-input check at A18/A19.

**Rubric.** Current correctness 45%; dependency coverage 25%; proportionate revalidation 25%; effort 5%.

| Option | Correctness | Coverage | Proportionate work | Effort | Total |
| --- | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 2 | 5 | 5 | 49 |
| B | 5 | 5 | 1 | 3 | 78 |
| C | 5 | 5 | 5 | 4 | 99 |

**Selected action.** Use C. Record relevant code, settings, caller and threat-model assumptions with each conditional result. Reopen the affected acceptance when those inputs change. Keep historical evidence and spent budgets. At final acceptance, verify that each retained no-change or no-trigger result still applies.

## Verification

The parent applies these corrections to A14, the reviewer protocol, the post-merge rules and A18/A19 final acceptance. Structural checks and a follow-up independent review are recorded in VALIDATION.md. This review covers planning correctness; it does not substitute for product PR reviews or Terraform operator approvals.

## CR4: Read native objects without local Git replacements

**Validation.** The final reviewer identified that ordinary Git object commands honor `refs/replace`. The helper could report a requested SHA while hashing replacement content. [Git's primary documentation](https://git-scm.com/docs/git-replace) confirms the default behavior and the `--no-replace-objects` control. No replacement in the product repositories is alleged.

**Stakeholders.** Repository maintainers; byte-comparison consumers; local Git users with replacement refs; security and final-quality reviewers; downstream users; future operators reproducing the audit.

**Options.** A: accept ambient replacement behavior. B: inspect and remove replacement refs. C: disable replacement lookup on every read command. B mutates unrelated local Git state and can race; C leaves it intact. An environment-only setting is an alternative implementation of C, but a global command option is explicit at the sole wrapper.

**Rubric.** Native-object fidelity 55%; local-state preservation 25%; reproducibility 15%; implementation effort 5%.

| Option | Fidelity | Preservation | Reproducibility | Effort | Total |
| --- | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 5 | 1 | 5 | 44 |
| B | 4 | 1 | 3 | 2 | 60 |
| C | 5 | 5 | 5 | 4 | 99 |

**Selected action.** Use C. Add `--no-replace-objects` to the helper's Git command wrapper. Test a disposable repository with a replacement commit. Prove that the helper reads the original bytes. Do not remove the user's replacement refs or change product repositories.

## CR5: Preserve historical text while linting its wrapper

**Validation.** The real Markdown CLI reports 402 MD012 errors, one per original extract, for source-preserved trailing blank lines. Active task prose passes. Removing those lines would change each preserved body hash for a formatting-only reason.

**Stakeholders.** Historical-evidence readers; documentation maintainers; lint maintainers; future agents verifying hashes; reviewers; repository owner.

**Options.** A: strip historical source whitespace and change the preservation claim. B: disable only MD012 in each reference wrapper, with an explicit preservation reason. C: skip all Markdown validation. B keeps every other Markdown check and all active-task formatting checks.

**Rubric.** Source preservation 60%; readable references 15%; useful lint coverage 20%; implementation effort 5%.

| Option | Preservation | Readability | Lint coverage | Effort | Total |
| --- | ---: | ---: | ---: | ---: | ---: |
| A | 2 | 5 | 5 | 4 | 63 |
| B | 5 | 5 | 4 | 4 | 95 |
| C | 5 | 3 | 1 | 5 | 78 |

**Selected action.** Use B. Add a narrow MD012 directive before the preserved historical body. Keep that body's bytes unchanged. Run lint again on the complete changed Markdown scope and verify every source hash.

## Corrections from the independent review

[Owner-directed D07](DECISIONS.md#d07-apply-the-independent-plan-review-and-reduce-execution-overhead) consolidates the tracker/journal split, materiality and reply limits, task/ownership changes, historical ledger and advisory routing corrections. PR224 repairs and its original budgets are preserved. Plan verification, changed-Markdown lint and original-contract byte checks are required before publication; no unchecked owner box supplies authority.

The independent D07 reader checked the final structure and all 90 migrated chronology units. Two journal attribution errors and two punctuation changes were corrected against the frozen previous STATUS. `verify-plan.py` passes for 22 tasks, 402 intact contracts, 26 retained credits, one primary owner per ID, 81 baseline paths and the dependency graph. A00's validator also passes against unchanged native mains. STATUS is 8,489 bytes. The normal commit hook validates the complete changed Markdown scope before publication.
