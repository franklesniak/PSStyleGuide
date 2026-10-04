<!-- markdownlint-disable MD013 -->
# A06-D4: generated frontmatter spacing

State: C98 selected after parent validation and display of options, rubric and scores on2026-10-04. This is preparation for A06 after its implementation dependencies pass. No product file changed and no A06 acceptance is claimed. Transfers remain0/12.

## Validated finding

At PS main3e068afa36fbc963c4d716df9efb245468791fe8/tree1a3389702ebe93f677bd86bd2169b61e1578f82d, the generator emits two spaces after `applyTo:` and `powershell.instructions.md` contains them. At TF main06ad4f7c9b6847028cafdacf1ae55128d0f2d56c/treedc8f6b82588b8f874d34cd5d0155791aea5793f1, both use one space. Both repositories' scoped documentation and YAML instruction files use one space. This unnecessary difference needs a common convention under the paired-convergence objective. It is a presentation improvement, not a demonstrated matching or security defect.

Parent verification at2026-10-04T08:56:26.766Z independently matched all eight named Git blobs, modes and SHA-256 hashes in the worker evidence. Native main refs matched the accepted pins before and after inspection. The different local `main` refs are stale local diagnostics, not evidence of a changed native base. Both one-space and two-space variants of each complete frontmatter block parse to identical selector and description values.

| Repository | Generator blob | Root artifact blob | Scoped docs blob | Scoped YAML blob |
| --- | --- | --- | --- | --- |
| PS3e068af | a23d38c42770d7463920704e108ccd63240dc90b | e68999483c41c07e732772d88b2c43dd1467f367 | 0b0c1ddc83938cfa9706418d45f619b1bfa03ffd | edef19560d3403985d1417af4772d74bbf9eacf4 |
| TF06ad4f7 | a3e7e664e441d2e51f0b6f5709b8a010d6877e82 | 59eeedcfe4cab11ebf87d439d5117f7203b0ea98 | 4a8f2addc02af857928205199b66cf3918ae9a82 | 924d12c833d07def47d05137b532e622db622fa4 |

All eight modes are100644. Generator path is `.github/workflows/Generate-StyleGuideArtifacts.ps1`; root artifact paths are `powershell.instructions.md` and `terraform.instructions.md`; scoped paths are `.github/instructions/docs.instructions.md` and `.github/instructions/yaml.instructions.md`. Both generator literals are at line1081 at these pins.

Maintainers and new contributors need reproducible generated output. Documentation readers and reviewers benefit from a common convention. QA needs preserved parsed values and exact output comparison. CI/DevOps and security need no new access, installation or runtime mechanism. Delivery owners need the decision included in the existing generator change. No distinct accessibility, privacy or business-data effect was identified.

## Options before scoring

- A: keep the difference permanently. Semantics remain valid, but an unnecessary common-byte exception remains.
- B: use two spaces in both generators and regenerate. Semantics and source/output integrity remain valid, but the convention differs from all four nearby scoped instruction files.
- C: use one space in both generators and regenerate. This also matches the existing Terraform output and nearby instruction files.
- D: edit only the generated PowerShell file. Regeneration will restore the difference, so it fails the source/output constraint.
- E: defer indefinitely. This does not satisfy final convergence. Waiting for prerequisite acceptance is sequencing and can accompany B or C; it is not a different final solution.

Use the existing selected A06 common generation path. A new formatting plugin, separate normalizer or broad frontmatter rewrite adds a mechanism with no supported need. Do not modify selector values, descriptions, artifact locations or protected source prose to solve this spacing issue.

## Finding-specific rubric

Scores are1–5, higher is better; total is `sum(weight * score) / 5`. Correctness35% measures unchanged selector/description meaning. Consistency25% measures agreement with existing instruction formatting. Source/output integrity20% measures whether the generator reproduces the result. Clarity10% measures how easily contributors and reviewers can understand the convention. Cost10% measures implementation and maintenance work. Correctness, consumer consistency and reproducibility carry more weight than churn or effort.

Hard constraints: preserve each existing selector and description; generate changed artifacts from their source; retain no permanent formatting exception without an actual consumer need. D fails source/output integrity. A and E cannot be the completed convergence result. Their scores remain visible for comparison.

| Option | Correctness35 | Consistency25 | Integrity20 | Clarity10 | Cost10 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 1 | 5 | 2 | 5 | 74 |
| B | 5 | 2 | 5 | 4 | 4 | 81 |
| C | 5 | 5 | 5 | 5 | 4 | 98 |
| D | 2 | 4 | 1 | 3 | 5 | 54 |
| E | 5 | 1 | 2 | 1 | 5 | 60 |

Parent recalculated every total. The preserved worker draft incorrectly gave A/B/E totals72/82/58. Correct totals are74/81/60; C98 remains the clear winner. This correction does not change the underlying scores or evidence.

## Selected solution and verification

Use C. Use one space after `applyTo:`. Make the change in the generator. Run the generator to produce the output. Keep each selector and description unchanged. Run the generator again. Check that the output does not change. Do not edit the generated file by hand.

Include this change in A06 after A02/A03 acceptance. Terraform already uses one space; verify that convention when the shared implementation is transferred. Leave the four scoped instruction files unchanged for this finding. Retain raw output comparisons and distinguish this intentional formatting change from content drift. Parse the changed frontmatter and compare it with the original values. Use the selected actual-generator and determinism checks; do not add a permanent test for this trivial spacing change alone. Full A06 platform, integrity and paired-convergence gates still apply.

Current verification used Windows with Node24.18.1 and the existing locked `yaml` package. It read named Git blobs and performed inert YAML parsing only. It did not execute the changed generator, run either product aggregate or test GitHub's actual matching behavior. GitHub documents `applyTo` frontmatter for path-specific instructions; this does not establish that these root export files are automatically consumed on GitHub.

Private evidence is `C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A06-frontmatter-prep-20261004/`: preserved `PROPOSAL.md`, `evidence.json`, `probe.js`, parent `parent-verify.cjs`, `parent-verification.json` and the four-line fixture note. Original evidence SHA256 is1ab05561c03663cc9a00bf789e549c7860afea80449666c396d02c804eb47ab3. The first parent fixture incorrectly searched for an unquoted line in PowerShell source and failed before parsing. The corrected source matcher requires the one actual quoted literal; artifact checks stayed unchanged. No product or source evidence changed.

References: [YAML1.2.2 separation spaces](https://yaml.org/spec/1.2.2/#62-separation-spaces) treats separation whitespace as presentation syntax. [GitHub custom instructions](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/add-custom-instructions/add-repository-instructions) documents `applyTo` glob frontmatter and gives one-space examples. Neither source is used to claim a live matching test. Formal ASD dictionary certification is not claimed.
