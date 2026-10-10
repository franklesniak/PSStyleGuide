<!-- markdownlint-disable MD013 -->
# FQ50: Spell out Configuration in affected local variable names

Selected before implementation. This is a local combined-source review finding, not another remote review round. The first combined packet manifest is1f4b94afe1b6d6443ce4579c1f2720330f1f17032de8bd131d8c65b4b92f943f; credential helper SHA00f9ad8f9b2e1cfa421f255358a86f4da3664eb811adcd7662d1d4c0a19e09d0. Review REPORT SHA6fb93b15e15068e0a4517295881e6990b0958bd799cfeac92a452c154b3f7725.

## Validation

The finding is real. Root read STYLE_GUIDE.md578-603 and the helper's full affected identifier inventory in native a36daa/0. The descriptive portion after a type prefix must be fully spelled out. Nine affected locals abbreviate Configuration: arrEffectiveConfig, intEffectiveConfigExit, strEffectiveConfig, arrConfigFields, intConfigField, strConfigScope, strConfigKey, strConfigSection and strConfigVariable. The first two existed before this repair but are touched; seven are new. There is no Git-term exemption for these local descriptive names. This is a repository naming defect, not evidence of a runtime failure.

The normative primary source is [the repository guide](../../../../../../STYLE_GUIDE.md#local-variable-naming-type-prefixed-camelcase). Literal Git command config, environment name GIT_CONFIG, native APIs and format names are distinct and must retain their spelling. No Internet research is needed to establish this local rule. The independent reader inventoried both shipping PowerShell files and found no additional introduced abbreviated descriptive locals.

## Options and perspectives

Developers and new maintainers need consistent descriptive names. DevOps, security and business owners need identical runtime behavior and no new recovery requirement. Documentation and UX owners need implementation terminology consistent with the guide without user-facing behavior changes. QA needs a precise rename with unchanged test causality. Project cost matters less than these requirements.

| Option | Approach | Consequence |
| --- | --- | --- |
| A | Leave the names, document or defer the violation. | Does not meet the current rule. |
| B | Expand all nine names, their references and exact test anchors. | Meets the rule without changing behavior. |
| C | Rename only the seven newly introduced locals. | Leaves two touched names inconsistent with the rule and their peers. |
| D | Replace every occurrence of Config, including commands and APIs. | Corrupts external names and can change or break behavior. |
| E | Change the guide or introduce an exception. | Requires an unnecessary protected policy change; does not meet the current rule. |
| F | Refactor the parser and use compliant replacement names. | Adds behavioral and validation risk beyond the naming repair. |
| G | Add fully spelled aliases while keeping abbreviated locals. | Retains the violation and adds redundant state. |

B includes both new and previously existing touched names. Rename mechanics may use exact identifier mappings or syntax tokens if the result is independently checked. B plus a parser redesign is F; B plus a policy change adds E without resolving an additional finding. Removing configuration checks would break the accepted credential contract. Such removal is not an eligible naming repair. No option is authorized to change protected policy merely because it receives a numerical score.

## Finding-specific rubric

Scores range0-5:0 fails;1 leaves a major gap;2 is partial;3 requires extra conditions;4 has a bounded limitation;5 directly meets this finding's criterion. Total equals the sum of each weight times its score divided by5. These are design judgments, not probabilities. Existing authority and required behavior remain hard constraints.

| Criterion | Weight | Meaning of5 |
| --- | ---: | --- |
| Current rule compliance | 30 | All nine affected local names follow the unchanged guide. |
| Runtime behavior preserved | 30 | Commands, environment names, APIs, values, control flow and comparisons are unchanged. |
| Reader clarity | 18 | A new maintainer sees consistent descriptive names without aliases. |
| Verification confidence | 14 | Exact rename comparison and existing affected tests can establish the bounded change. |
| Maintenance burden | 5 | No aliases, exceptions, or new abstraction require upkeep. |
| Implementation cost | 3 | The edit is small and direct. |

## Scores

| Option | Compliance30 | Behavior30 | Clarity18 | Verification14 | Maintenance5 | Cost3 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 0 | 5 | 3 | 2 | 3 | 5 | 52.4 |
| B | 5 | 5 | 5 | 5 | 5 | 5 | 100.0 |
| C | 3 | 5 | 4 | 4 | 3 | 4 | 79.0 |
| D | 5 | 0 | 2 | 1 | 2 | 4 | 44.4 |
| E | 0 | 5 | 2 | 2 | 1 | 2 | 45.0 |
| F | 5 | 3 | 4 | 3 | 2 | 1 | 73.4 |
| G | 1 | 5 | 2 | 3 | 1 | 3 | 54.4 |

B is the clear winner. A/C/G leave the existing rule unmet; D breaks external spelling. E changes a protected rule instead of satisfying it. F can satisfy naming but adds unnecessary behavioral uncertainty. No owner preference or new approval is needed.

## Selected instructions and validation

1. Rename the nine local variables in the credential helper.
2. Use Configuration in place of Config in each selected name.
3. Update every reference to each selected variable.
4. Update the exact source anchors in the existing tests.
5. Keep Git commands and environment names unchanged.
6. Keep API names, string values, comparisons and control flow unchanged.
7. Do not change the guide or add aliases.
8. Compare the changed text with the original text.
9. Confirm that only the selected names and their test anchors changed.
10. Run the parser and the affected existing tests on the final source.
11. Preserve the first frozen packet and its evidence.

These short controlled-English steps follow the owner's ASD-STE100 direction; no formal dictionary certification is claimed. No new naming-only test is required. Existing credential and caller tests remain the meaningful behavior tests. The final candidate's source catalog and generated forms must be rebound after the edit.

Root displayed validation, all options, the unique rubric, full scores and selection before author release. No renamed-source runtime test has run at this decision point. The earlier shipping check7c1a07/1 had zero parser errors, no credential analyzer issues, and two separately explained unchanged initializer warnings; its raw exit remains1 and is not credit for this edit. The corrected private packet is pr239-round5-implementation-a2, with one existing writer. Round5/80, original deadline and transfers9/12 remain unchanged.
