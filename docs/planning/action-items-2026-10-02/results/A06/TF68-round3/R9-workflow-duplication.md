<!-- markdownlint-disable MD013 -->
# TF68 R9 — Windows acquisition and proof duplication

## 1. Validation and affected users

This repeats the maintenance opportunity adjudicated in [PS234 R11](C:/Users/flesniak/GitHub/PSStyleGuide/docs/planning/action-items-2026-10-02/results/A06/PR234-round2/R11-inline-workflow.md). The current locked YAML parser read the actual current build workflow successfully. The two parsed Windows acquisition bodies are equal (4,679 characters in this probe's representation). All three platform proof blocks contain 23 lines; Windows proof bodies intentionally differ in current host and ExpectedHost. The earlier record used a different body representation/length, so its numeric length is not treated as current evidence.

Acquisition runs before the immutable repository checkout. A repository helper is absent or unverified then. Loading one is a new bootstrap path, not simple extraction. Proof runs after checkout and can technically use a helper, but current independent policy admits exact proof shape, current host, two passes, immediate native statuses and same-revision publication. Existing actual-body negative controls and mutation expectations remain important. No current drift or runtime failure is demonstrated by repetition.

GitHub [supports YAML anchors and aliases](https://docs.github.com/en/actions/reference/workflows-and-actions/reusing-workflow-configurations), with support [announced in September 2025](https://github.blog/changelog/2025-09-18-actions-yaml-anchors-and-non-public-workflow-templates/). That does not make them admissible here: actual Validate-WorkflowPolicy rejects aliases, anchors and explicit tags, and the current locked parser/policy probe rejects an anchored input with `yaml-feature`. A claim that GitHub does not support anchors would be false. A claim that aliases are a drop-in local change would also be false.

Security/audit owners need a defined pre-checkout trust chain. Operators need correct host and shell selection. Contributors benefit from fewer edits but must be able to see what CI executes. QA needs an independent oracle rather than one shared erroneous helper and expected result. Paired maintainers need explicit common-input closure. Delivery owners need sustainable maintenance without trading away current admission controls.

## 2. Options before evaluation

- A. Keep the current inline acquisition/proof and independent policy/behavior controls.
- B. Move both bodies to repository helpers invoked before checkout.
- C. Keep acquisition inline and factor only post-checkout proof, with new helper/input admission and independent controls.
- D. Use native YAML anchors/aliases, changing the strict parser/policy deliberately and testing that new admission boundary.
- E. Introduce a reusable workflow or matrix with explicit immutable inputs and verifier/platform outputs.
- F. Generate repeated inline blocks from a common source and verify synchronization.
- G. Acquire an externally pinned bootstrap/helper or action before repository acquisition.

B adjusted to obey the pre-trust boundary reduces to C or G. C plus D/E adds two abstraction layers without a demonstrated additional need. Dropping platform jobs, native checks or credential checks is ineligible. D must not bypass the parser by broad exceptions. G requires new explicit trust-source review. These alternatives are feasible design projects only under their stated extra contracts; no score grants that scope now.

## 3. Unique weighted rubric

Bootstrap trust 30%: preserve action-free credential-free acquisition before executing repository code and verify the immutable checkout. Independent admission 30%: preserve exact current-host/two-pass/native-status/revision controls and separate expectations. Operator and test clarity 20%: keep executed paths, failure attribution and platform differences inspectable. Maintenance 15%: reduce demonstrated drift burden while accounting for helper/source/policy coupling. Cost 5%: consider migration and trust-source lifecycle only after correctness and usability.

## 4. Scores before selection

| Option | Bootstrap trust 30 | Independent admission 30 | Operator and test clarity 20 | Maintenance 15 | Cost 5 | Total / 100 | Reason and limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 10 | 10 | 10 | 6 | 10 | 94 | Windows acquisition pair is equal; current proof and platform failure oracles remain explicit. |
| B | 1 | 8 | 5 | 10 | 4 | 54 | Helper is absent or unverified at this stage; ineligible. |
| C | 10 | 8 | 9 | 8 | 6 | 87 | Feasible but needs helper/source admission and independent negative controls for the newly indirect proof. |
| D | 10 | 7 | 8 | 9 | 6 | 83.5 | GitHub supports anchors; actual strict parser rejects them, so this needs a new policy boundary and independent tests. |
| E | 9 | 7 | 7 | 9 | 4 | 77.5 | Changes finite job/host/output topology and verifier admission, not merely repeated text. |
| F | 10 | 8 | 7 | 8 | 5 | 82.5 | Adds source/emitted synchronization and shared-oracle risks while keeping generated duplication. |
| G | 6 | 8 | 7 | 7 | 2 | 67.5 | New acquisition trust source and update obligation; no current correctness need supports that expansion. |

## 5. Selected instructions and validation

Select A. Keep the current inline bodies and independent proof controls. Apply any future shared acquisition fix to both current Windows callers. Verify each actual body. Do not call a repository helper before verified checkout. Do not add YAML aliases under the current parser. Keep deliberate host differences. State that post-checkout factoring is possible, but the current evidence does not justify a new helper or admission contract. This is the validated current merits decision, not an untracked factoring commitment. No product edit or repeat workflow run is required for this response.

## Selection and evidence

Root displayed validation, options, this unique rubric, all scores and the selected action before product release. Selected2026-10-06UTC on TF7dd48f52c9e4c17268b4a571919622f4d701e5d0, acceptedB=e21b74fe0b56551008f78f9f2946cd2a0f9c19ce and pairedPS98177628b7bc02c646724bfc8aa0fd73fed0cd24. [Decision evidence](evidence.json) and [parent verification](root-verification.json) bind all7 raw source rows,18 artifacts and29 score calculations. Runtime probes used PowerShell7.6.5/PSScriptAnalyzer1.24 and Node24.18.1. Probe limits and failed private job-selector attempt remain in evidence; no product or hosted execution is inferred from prospective analysis.
