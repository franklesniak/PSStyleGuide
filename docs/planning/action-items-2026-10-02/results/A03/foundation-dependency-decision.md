<!-- markdownlint-disable MD013 -->
# D-A03-FOUNDATION-01: explicit prerequisite acceptance

Selected 2026-10-05. This decision clarifies implementation prerequisites. It does not accept a product stage or mark an outcome complete.

## Validated finding

The formal 22-task dependency graph is acyclic. Its broad completion predicates can nevertheless produce a real execution deadlock. A06 depends on A03. A16 depends on A06 and A07. Known A03 workflow and A07 runtime integration requires the real A16 recovery harness. Requiring that future integration before starting A06 or A16 creates a cycle. Calling known missing integration complete would conceal a requirement.

The existing [A15 foundation sequence](../A15/foundation-refresh/REPORT.md#staging-and-ownership-sequence) already separates accepted usable foundations, A16 harness implementation, coordinated integration, and actual Gate A acceptance. [A06's design](../A06/design.md) separates Windows generator proof from later recovery proof. [R5/B1](../A07/recovery-runtime/PROPOSAL.md) requires independently usable acquisition without making an absent harness its prerequisite. These are the primary contract sources for this correction. No external service behavior is assumed or changed.

Root checked the current task contracts, those source paragraphs, and the independent readiness analysis. The conflict is in the prerequisite wording; it is not a reproduced product defect. The existing LOOP-POLICY reopening rule applies to invalidated delivered behavior. It cannot excuse known missing work.

## Stakeholders and constraints

Maintainers and the coordinator need an executable order with one writer per coupled surface. Security and DevOps owners need tested acquisition, isolated credentials, and publication that rejects missing or failed platform results. QA and reviewers need exact accepted input identities. New contributors, documentation readers and UX owners need a clear start condition and visible remaining work. Recovery operators and independent peers retain their real approval roles. Business and schedule owners benefit from avoiding duplicate harnesses and administrative work. This change adds no user interface or localization surface.

Hard constraints: retain all 22 outcomes, all 402 original contracts and their remaining owners, and all 26 historical credits. Preserve R5/B1, B99 and A15 D2/D5 requirements. Accept actual prerequisites before dependent implementation. Do not enable callers of absent files. Preserve actual Gate A/B approvals and all spent transfer/review budgets. A score cannot waive a constraint.

## Options

| Option | Approach and consequence |
| --- | --- |
| A | Keep broad-final prerequisites. This honestly retains missing work but cannot reach the harness needed to complete it. |
| B | Call current foundations broad completion and defer known gaps through reopening. This falsely marks selected missing work complete and is ineligible. |
| C | Bind dependencies to explicit accepted foundation stages. Keep each broad outcome and its later obligations open with the same owner. Reuse the A15 sequence. |
| D | Move later integration acceptance into A16/A17. This can work, but changes ownership and completion contracts and risks hiding promised interfaces. |
| E | Build all foundations, generator and recovery work together before accepting prerequisites. Beginning blocked writers now violates current dependency boundaries and is ineligible. |
| F | Record a hold until a later correction. This is truthful, but does not resolve the release problem. |

Restoring retired infrastructure, omitting required Windows cells, or substituting model reviews for real approvals fails a hard constraint. A new foundation outcome is unnecessary; C provides that separation inside existing outcomes. Reused native evidence and a coherent integration candidate after actual prerequisite acceptance are parts of C, not separate options.

## Finding-specific rubric

Score each criterion from 0 to 5: absent, seriously deficient, substantial gaps, workable with limits, strong, or fully covered. Total = sum(weight × score) / 5. These are engineering judgments, not measured product results.

| Criterion | Weight | Evaluation |
| --- | ---: | --- |
| Prerequisite integrity | 30 | Every released stage has actual implementation, validation, review, normal acceptance and usable inputs. A deadlocked boundary cannot supply its promised acceptance. |
| Requirement and owner coverage | 25 | Every selected obligation remains visible with one accountable owner; no false completion or loss of later integration. |
| Executable order | 20 | The harness can be built before its execution is required, with serialized coupled edits and no missing-file consumers. |
| Restart and review clarity | 15 | A new reader can identify the exact start condition, acceptance evidence and remaining work. |
| Change economy | 5 | Avoid unnecessary new outcomes, ownership transfers and contract changes. |
| Operating cost | 5 | Avoid duplicate implementations, tests, records and repeated stalled work. |

## Scores before selection

| Option | Integrity30 | Coverage25 | Order20 | Clarity15 | Economy5 | Cost5 | Total | Limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 2 | 5 | 0 | 2 | 5 | 2 | 50 | Retains the deadlock |
| B | 1 | 1 | 5 | 2 | 5 | 5 | 47 | Ineligible false completion |
| C | 5 | 5 | 5 | 5 | 4 | 4 | **98** | Actual stage acceptance is still required |
| D | 4 | 4 | 5 | 3 | 2 | 3 | 78 | Larger ownership and acceptance migration |
| E | 2 | 4 | 4 | 2 | 1 | 1 | 56 | Ineligible before prerequisite acceptance |
| F | 4 | 5 | 0 | 4 | 5 | 1 | 67 | Honest hold without delivery |

C scores `(150 + 125 + 100 + 75 + 20 + 20) / 5 = 98`. D is a viable broader alternative. F is the honest fallback if required acceptance is unavailable.

## Selected action: C98

Keep the existing outcomes. Use the following start conditions. Record accepted commits, trees, scope and validation in the existing owner result. Keep each broad task open while known work remains. Do not use a stage label as acceptance evidence.

| Boundary | Required accepted result | Work that remains with its current owner |
| --- | --- | --- |
| A03 foundation → A06 implementation | Accepted paired coherent workflow contracts, including D6/D9/D11/D12/D13, devcontainer/security behavior and coupled tests. Complete PR232, applicable compare-back, and the normal lifecycle. | A03 R5/B1 credential and schema consumers; later TF D2 jobs, policy, cases and publication wiring. |
| A06 foundation → A16 implementation | Selected shared generator/verifier work, current TF T2 child, required generator platform proof, artifact integrity and paired acceptance. | A06 actual new-harness and Node22 caller integration and affected integrity tests. Generator tests do not prove recovery behavior. |
| A07 foundation → A16 implementation | Applicable current locks, audits, hooks and lint; B99 delivery and qualification; independently usable R5/B1 Linux/Windows acquisition with real archive, version, credential, extraction, isolation and failure proof. Accept its coordinated A03 consumers. | A07 actual A16 harness execution on required runtimes and platform cells. Acquisition tests do not prove recovery behavior. |
| A16 implementation → coherent Gate A candidate | Accepted preceding foundations and the selected A15 design. Build the real 13-path recovery-owned source and harness batch. | Integrate A03 D2 workflow/policy cases, A06 caller, A07 runtime evidence and A21 seven-loader closure under their existing owners. |
| Gate A candidate → A16 acceptance | Same-revision required platform results, zero mutation calls, normal lifecycle, and real operator plus independent-peer approval bound to the actual commit/tree/contracts. | A17's nine-path Gate B scope and fresh applicable approval if approved inputs change. |
| A17 → A18/A19 | Approved Gate A predecessor, required Gate B cells, helper-only Windows scope, real Gate B approvals, generated equality and common convergence. | A18 full-union/capability/exception recheck and A19 current issues plus all 402 dispositions. |

Preserve the anticipated eight-path R5/B1 acquisition scope. Refresh its accepted source inputs before release. A07 owns the initializer, runtime metadata, Invoke-MarkdownLint and two interface documents. A03 owns credentials, Copilot setup, shared CI-helper tests and the workflow/policy graph. A04 retains its ordinary download requirements and dependencies. A06 and A21 retain caller and admission work. Serialize overlapping edits.

Build the harness only after its required foundations are accepted. Enable a caller only when its real input is present in the coherent candidate. Run all required platform cells. Obtain the real Gate A approvals before Gate B starts. Reopen only invalidated delivered behavior. Do not classify known missing work as conditional-no-trigger.

Keep all existing counters. A stage does not create a new transfer-zero start, PR clock or cap. Leave A18's broad completion prerequisites intact. This decision does not grant protected-file or operational authority.

The instructions use short direct sentences, explicit conditions and consistent technical names. No formal ASD-STE100 dictionary certification is claimed.

## Implementation and verification

The README and A03/A06/A07/A16 contracts now identify these stages. Existing owner results link this decision and retain their unfinished work. The task graph, original contracts, remaining-owner ledger, dispositions, historical credits and counters are unchanged. No product bytes, PR description, settings or gate approval changed.

Validation: the existing `verify-plan.py` passed with 22 outcomes, 402 intact contracts with one owner, 26 historical credits and an acyclic graph. Markdown lint passed on the changed documents. Root also confirmed no diff in the graph, ledger, historical map or original-task files. Product validation is not needed for this planning-only clarification. Actual prerequisite acceptance remains pending and must be recorded before a writer is released.

Local edit note: the first insertion stopped at A07's different heading after applying the preceding planned edits. Root read the actual heading and applied the remaining insertion once. No product file changed; plan and Markdown validation were rerun.
