<!-- markdownlint-disable MD013 -->
# R6: Require the workflow nested lint command in the finite setup contract

Status: root selected E99 after displaying validation, options, the finding-specific rubric, scores and controlled-English steps. The private two-file repair passes focused Windows/Linux validation and independent review. Integration, full combined-candidate validation and native acceptance remain. This is the canonical R6 decision; the private proposal remains historical evidence.

## Exact input and qualified finding

PR66 round2 comment4178863046, threadPRRT_kwDOSAZRhc6o1afa, authenticated Codex review5407658386 on H4375f2e3c98a6aeb0dd916d26620ed63a42abafe. Candidate tree099bb0f83403b6b61cfa2dafa73916b315c791d3; accepted Terraform B06ad4f7c9b6847028cafdacf1ae55128d0f2d56c. The original native comment is preserved in review-comment.json. All78 raw source identities are in source-identities.json.

**The finite-helper omission is valid. The comment's broader claim that the current candidate behavior suites accept the bad command is disproved.** Current lint-markdown.test.mjs already executes the real hook and catches both deletion and a no-op replacement. R1 made that file recurring in candidate-tests. This proposal improves non-executing setup-contract admission and its direct diagnosis; it does not invent absent end-to-end coverage or claim a current production failure with the valid manifest.

Get-AgentSetupPackageFailure requires four root commands and two workflow commands, but omits the workflow nested command. The actual workflow manifest correctly declares `lint:md:nested` as `node lint-nested-markdown.js`. The root command delegates to it, and the real Husky hook calls it after the staged and outer Markdown phases. Deleting it breaks valid Markdown commits; replacing it with a successful no-op allows nested Markdown violations through that hook. The existing recurring test rejects both changed candidates.

The helper parses strict, unambiguous JSON with a16384-byte maximum, requires an exact scripts object, then independently checks each reviewed property for its exact name, string type and exact command. The root package's nested delegate is already checked. The missing workflow expectation is the sole uncovered member among the seven reviewed command properties examined here.

There is no pre-install guarantee: the pure package helper runs without executing candidate commands, and Get-AgentSetupContractFailure calls it, but normal full validation also needs installed parser tools. The D11 pre-install workflow-policy/package checks have a different contract. This proposal does not change their order or expand them.

## Evidence and caller boundaries

| Boundary | Actual evidence | Interpretation |
| --- | --- | --- |
| Package helper, actual manifests | 29 focused cases: baseline admitted;24 mutations of six checked properties rejected; four mutations of workflow nested property admitted | Missing finite expectation proved for deletion, no-op, non-string and case-changed name |
| Actual hook, private repository | Clean0; nested violation1; same violation plus no-op0; missing script1 with npm missing-script output | The manifest command affects actual hook behavior |
| Existing unmodified retained Node test, missing command | One selected test fails, expected clean hook0 versus actual1 | Current recurring suite detects deletion |
| Existing unmodified retained Node test, no-op command | One selected test fails, expected nested failure1 versus actual0 | Current recurring suite detects bypass |
| Hosted current-H candidate suite | Root's authenticated run37225154565/job111503177546:479 tests passed,0 failed/skipped, including final19 Markdown tests | Baseline Linux success; not a mutated-input result |

Production caller chain: Test-AgentInstructions.ps1 Read-AgentSetupInputContent (bounded actual/staged or immutable revision reads) -> Get-AgentSetupContractFailure -> Get-AgentSetupPackageFailure. The main ordinary validator invokes the full contract. Classification-only maintenance selection is a separate role and must not be described as equivalent admission. The setup fixture function Assert-AgentSetupSelfTest reads real setup content, asserts its positive acceptance, clones the input map, rejects unchanged mutations and requires each intended diagnostic from the production full contract. Existing sibling cases cover root commands, workflow outer/prepare, strict JSON ambiguities, scripts-object shape and hook order/commands; the workflow nested member has no corresponding admission mutation.

Stakeholders: contributors need usable setup failures and working commits; maintainers need independent finite authority and coherent shared code; reviewers need attributable mutation evidence; CI operators need deterministic supported-runtime checks; repository owners need nested-lint enforcement and the accepted baseline/candidate role separation preserved.

## Materially distinct options

| ID | Option | Benefits and costs |
| --- | --- | --- |
| N | Keep existing helper and rely on existing recurring execution coverage | Already catches the reported candidate mutations; retains incomplete setup diagnosis |
| P | Require only presence and string type for the nested property | Gives a direct missing/type error but admits a changed valid-string no-op |
| E | Add the exact finite workflow expectation and two meaningful admission mutations in the existing SelfTest | Completes the current independent contract; direct property diagnosis; retains actual-hook coverage unchanged |
| J | Expand runtime-only hook checks and leave finite admission unchanged | Can exercise more behavior but duplicates existing missing/no-op execution detection; no deterministic finite closure |
| F | Introduce a shared independently governed command contract/config, then consume it in manifests/callers and validators | Centralizes future contract evolution and can provide full correctness; requires explicit bounded reader, accepted/proposed authority and generation/consumer coupling plus additional meaningful tests |
| H | Redesign hook execution to call the nested adapter directly, retaining the public npm aliases | Removes the hook's dependency on the alias, but root/user alias consumers still need admission protection; changes caller behavior and test coupling |
| R | Remove the nested-lint obligation and its tests/caller | Reduces machinery, but violates the selected mandatory nested-lint contract; ineligible |
| D | Document and defer finite-helper closure while retaining recurring tests | Makes the limitation explicit with current CI protection; defers the direct diagnostic and contract completeness |

F is a valid alternative, not forbidden by scope or a no-refactor rule. It must use an independently reviewed authority source. Deriving the expected command from the same candidate package value being validated would accept a candidate's own weakening and is not a correct F implementation. Combining E with retained execution tests is already E; adding redundant runtime tests to E does not materially improve the two witnessed behaviors. Combining exact admission with F is covered by F. Removing aliases as part of H would introduce an additional compatibility loss and is not needed to compare its strongest relevant form.

## Finding-specific weighted rubric

Scores range from0 (does not satisfy) to5 (fully satisfies). Total is sum(weight times score)/5. Correctness, contributor diagnosis, non-executing authority and meaningful evidence carry85%; maintenance/review burden carries only5%.

| Criterion | Weight | What earns a high score |
| --- | --- | --- |
| C: finite contract completeness | 35 | Independently rejects omitted, mistyped, misnamed or changed workflow nested command while preserving valid inputs and all siblings |
| U: actionable setup diagnosis/usability | 20 | Names the broken setup package/property at the existing admission boundary, with clear recovery and no extra indirection |
| A: non-executing deterministic admission | 15 | Checks strict bounded data against independent reviewed authority without running candidate commands; preserves role distinctions |
| T: meaningful proportional evidence | 15 | Adds discriminating admission proof, preserves real execution evidence and avoids a new testing blind spot or duplicate framework |
| P: supported runtime/caller preservation | 10 | Retains supported PowerShell/Node operation, public npm aliases, hook phase order, native statuses and existing scopes |
| M: maintenance/review burden | 5 | Makes future command changes and review straightforward without unnecessary parallel sources or infrastructure |

## Score table and recommendation

| Option | C35 | U20 | A15 | T15 | P10 | M5 | Total/100 | Eligible |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 2 | 1 | 3 | 5 | 5 | 5 | 57 | Yes |
| P | 3 | 4 | 3 | 4 | 5 | 5 | 73 | Yes |
| E | 5 | 5 | 5 | 5 | 5 | 4 | 99 | Yes |
| J | 2 | 2 | 3 | 2 | 4 | 2 | 47 | Yes |
| F | 5 | 4 | 5 | 4 | 5 | 3 | 91 | Yes |
| H | 3 | 3 | 4 | 3 | 4 | 2 | 64 | Yes |
| R | 0 | 1 | 0 | 0 | 5 | 3 | 17 | No |
| D | 2 | 2 | 3 | 4 | 5 | 4 | 57 | Yes |

Arithmetic is independently reproducible from score-verification.json. E=35+20+15+15+10+4=99; F=35+16+15+12+10+3=91. F receives equal full correctness, non-executing authority and compatibility scores when implemented correctly. Its separate contract/read/generation boundaries make diagnosis less local and require additional authority-consumer evidence; the difference is not predominantly churn. N receives full evidence credit for the existing behavior tests, but that does not close this distinct finite admission gap. P cannot reject a valid-string bypass. J adds duplicate behavior evidence without addressing the missing static obligation. H can keep hook enforcement but leaves the exposed aliases' contract incomplete. D improves disclosure rather than admission.

**Selected E99.** Root released the exact private repair after reviewing the proposal and displaying the scoring table. Existing owner approval covers this in-scope repair.

## Selected controlled-English implementation steps

1. Add the workflow `lint:md:nested` property to the existing expected-command table. Require the exact value `node lint-nested-markdown.js`.
2. Keep the strict JSON parser, byte bound, exact names, string checks and existing failure message.
3. Add two cases to the existing setup SelfTest. Remove the property in one case. Replace its value with a harmless successful no-op in the other case. Require the expected package-command failure for the workflow nested property. Ensure each mutation changes the actual input.
4. Keep the actual setup positive case and all sibling controls. Keep the real hook test and candidate Node caller unchanged.
5. Run focused package and setup controls against the private repaired copy. Confirm both new negatives fail against the original helper and pass against the repair. Check the parser and applicable analyzer rules on both changed PowerShell files.
6. Preserve actual B/H metadata roles. Date only the modified helper version notes as required. Do not bump already-current file versions merely because this is another unpublished candidate commit.
7. Give root the exact private diff, source guards and focused results. Root integrates and runs the frozen candidate lifecycle. Transfer the same common repair to PowerShell only after Terraform acceptance and renewed reverse comparison.

## Exact proposed scope, tests and secondary guide assessment

Only `.github/workflows/Test-AgentInstructions.ps1` (workflow expectation, modified private helper version note) and `.github/workflows/Test-AgentInstructions.SelfTest.ps1` (two admission controls, modified private helper version note). No manifests, hooks, workflow YAML, docs, caps, initializer or classification changes are needed. Existing outer/main file versions are already20261004.0 in this candidate. Modified helper notes currently1.0.20261003.0 should become1.0.20261004.0 if implemented on October4. Actual accepted B, not the previous unpublished H, governs published-baseline comparisons. Final implementation must verify exact notes before editing.

Minimum durable new evidence is the two mutation cases at the production admission boundary, not assertions that merely mirror table text. Re-run the29-case scratch property matrix to prove the new member shares all existing strict guards. Run the actual affected extracted setup function (including its real positive and existing sibling controls) on supported Windows and cached Linux if feasible; do not run a full SelfTest/aggregate in the worker. Existing real-hook missing/no-op evidence establishes the retained independent execution oracle; duplicate new Node tests are unnecessary. Parser/analyzer checks and an exact two-path scope audit remain required. Root owns final aggregate and native review lifecycle.

Accepted PSf168 has the byte-identical finite package helper (SHA71464623579ee1f533a8efa5fb0570b60bef0b88d96017e0441f1f9ca6e80012), so this is common code owed back after acceptance, not a Terraform profile exception. Its package already has the same nested command. PS's recurring caller addition remains the separately selected E97 reverse work. No paired completion or transfer increment is claimed here.

Read the entire applicable accepted PS STYLE_GUIDE.md,148759 bytes, blob21bbb515429eb5fdac47f14128a95d5fd55122aa, SHA331a401e3f26dbd4c497e156784c8f3e41f17bc295ec9f6a734639f2d6bb62fd; guide-read-assessment.json records the five complete read ranges. No secondary guide amendment is recommended. The defect is an omitted repository command expectation. Existing defensive validation, positive/negative evidence, PowerShell formatting, named private parameters and published-version rules already address the general concern. Adding repository-specific npm command literals to a standalone PowerShell guide would not improve its general guidance. Preserve the selected existing SelfTest architecture; no Pester migration or new framework is proposed.

## Primary references and limits

Primary code: [finite helper](https://github.com/franklesniak/TerraformStyleGuide/blob/4375f2e3c98a6aeb0dd916d26620ed63a42abafe/.github/workflows/Test-AgentInstructions.ps1#L429), [setup fixtures](https://github.com/franklesniak/TerraformStyleGuide/blob/4375f2e3c98a6aeb0dd916d26620ed63a42abafe/.github/workflows/Test-AgentInstructions.SelfTest.ps1#L2480), [actual hook](https://github.com/franklesniak/TerraformStyleGuide/blob/4375f2e3c98a6aeb0dd916d26620ed63a42abafe/.husky/pre-commit#L87), [retained execution test](https://github.com/franklesniak/TerraformStyleGuide/blob/4375f2e3c98a6aeb0dd916d26620ed63a42abafe/.github/workflows/lint-markdown.test.mjs), [full applicable guide](https://github.com/franklesniak/PSStyleGuide/blob/f168f83b89f64b6bca9d520ddec4b58969060fb6/STYLE_GUIDE.md). These contents were read from immutable local Git blobs; no network claims are needed.

Decision authority: planning DECISION-PROCESS.md and A21 shared-closure-handoff.md; retained A03 setup contracts; current E97 recurring-lint-suite-decision.md. No new source job, dependency, framework or execution authority is requested.

Focused proof used Windows PowerShell7.6.5 and the pinned Node24.18.1/npm11.16.0 runtime. No Linux bad-script mutation was run. Root's hosted Linux positive result is distinct. Initial real-hook scratch setup failed because npm cannot load the same file as both global and user config; its exit1 log is retained and the corrected fresh fixture uses two separate empty files. Two existing-test mutation runs inherited default TEMP/npm cache: their ordinary temporary fixtures and npm diagnostic cache writes occurred outside this evidence directory. That scope deviation was reported to root; no product or installed dependency changed. Future focused executions must explicitly locate TEMP/TMP/cache inside scratch. No product repair, private repair postimage, full suite, install or native service action occurred in this phase.

## Completed private repair and independent verification

The exact two-file repair is frozen. It adds the missing workflow expectation and two durable mutation rows. Only the two modified private-helper date notes also change; top-level versions and metadata roles remain. Windows completed once on its original handle, exit0 in494.656 seconds. Linux final completed exit0 in63.5 seconds. Each platform produced64 identical result records: original/repaired29-case matrices, two durable mutation discriminators against each helper, and both complete affected setup functions. The original helper rejected24 of28 mutations; the repair rejects28 of28 and preserves the positive. Both complete PowerShell postimages parse and pass PSScriptAnalyzer with zero warnings/errors. The initial Linux private-copy permission failure is retained separately and was fixed only in the fixture. No production guard changed.

[Frozen handoff](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/implementation/round2-review-findings/repair/HANDOFF.md) SHA256 `b483a0a8fb6e3c06a7f469fe556fe584365d472732b79a5434e951ee4fa4309c`; patch SHA256 `6cf1e0947a1807c89e86639e8fc4fd3d06223b881d970b52e4bebd4e04dbba34`. [Independent bounded PASS](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-prepublication-quality-20261004/TF66-R6-REPAIR-REVIEW-20261004.md) SHA256 `25fea28c7a4d49442f8c6016f9e1b153aa595f9634d59bc18d3bea2b6665a2ed` found no actionable material issue. Root sampled the complete diff and validator postimage hash. The independent reader reconstructed the exact diff and verified both postimages, all78 source files, the index and all1910 dependency files. No product integration or full aggregate occurred in this private phase. R8/R9 and current native acceptance are separate gates.

Generated with Codex
