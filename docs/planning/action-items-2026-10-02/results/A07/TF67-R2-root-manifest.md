<!-- markdownlint-disable MD013 -->
# TF67 R2: Retain the root manifest diagnostic

Coordinator-accepted decision. The complete options, rubric, scores and selection were displayed before public disposition. No product edit is selected.

Input: TerraformStyleGuide PR67, H `443b2fe3cbeda18402f0432e5c95379d09096d6a`, tree `89f470ceb6b3e6e9d4ae757e38997f1c6e7bd631`, B `56cb0418dcdcf71be94acc78d8963ea580b8a9e9`. Copilot review5417485797, comment4186175553, thread `PRRT_kwDOSAZRhc6pHcd7`, `.github/workflows/lint-markdown.mjs`:24. The full authenticated review states Lite. Its finding says root package.json is misleading because required comes from canonicalManifest; it proposes generic manifest wording or a path.

## 1. Validate the claim and material benefit

The claim is disproved for the current supported consumers. The module derives repoRoot from its own directory plus `../..` at line6. The public function defaults root to that repository root at line10. It sets manifest to `path.join(root, 'package.json')` at line12. It checks the leaf type and size, then obtains canonicalManifest with `fs.realpathSync(manifest)` at line17. The following relative-path check requires that canonical path to stay inside canonicalRoot. Line22 reads the same file's engines.node. Canonicalization does not select `.github/workflows/package.json` or another dependency manifest.

The root manifest declares Node24.18.1. The workflow manifest has no engines.node field. Root npm delegates lint:md to the workflow package, whose command runs `node lint-markdown.mjs`. That CLI calls lintMarkdownFiles without an argument. The module's location determines repoRoot; npm's working directory does not select its manifest. Husky uses the same workflow-package command. A full `.github` search finds no production importer that passes another manifest or a non-repository directory. The only explicit-root imports are the existing lint test fixtures; those create root/package.json themselves. The accepted root-alias test still means the selected repository's root manifest, reached through an alias.

The exact error tells a new contributor which file, field and format to repair. Generic Markdown-lint package wording removes the root distinction in a repository that has two package manifests. A path can be useful for an arbitrary external API, but the supported repository CLI has an explicit root contract and no reported wrong-file repair. No observed consumer failure or material usability improvement follows from this review hypothesis. This is not a claim that absolute-path diagnostics are always undesirable.

[PS232 R7](https://github.com/franklesniak/PSStyleGuide/blob/818cf71224054ce04c81e7dd79eb4751d8bbd6b6/docs/planning/action-items-2026-10-02/results/A07/PS232-R7-node-diagnostic.md) deliberately selected file/field/remedy wording after real missing/invalid declaration probes. R2 does not invalidate that evidence. R1 subsequently removed only the redundant mismatch fallback. [PS232 R9](https://github.com/franklesniak/PSStyleGuide/blob/818cf71224054ce04c81e7dd79eb4751d8bbd6b6/docs/planning/action-items-2026-10-02/results/A07/PS232-R9-entry-helper.md) remains applicable: direct-call and inert-import boundaries are unchanged. This decision evaluates the new wording request separately; it does not reopen either prior design.

Primary evidence is the full committed source and callers, not a review excerpt. Immutable source: [helper](https://github.com/franklesniak/TerraformStyleGuide/blob/443b2fe3cbeda18402f0432e5c95379d09096d6a/.github/workflows/lint-markdown.mjs), [root manifest](https://github.com/franklesniak/TerraformStyleGuide/blob/443b2fe3cbeda18402f0432e5c95379d09096d6a/package.json), [workflow manifest](https://github.com/franklesniak/TerraformStyleGuide/blob/443b2fe3cbeda18402f0432e5c95379d09096d6a/.github/workflows/package.json), and [tests](https://github.com/franklesniak/TerraformStyleGuide/blob/443b2fe3cbeda18402f0432e5c95379d09096d6a/.github/workflows/lint-markdown.test.mjs). External research is unnecessary for this local file-selection claim.

## 2. Identify affected stakeholders

- New and experienced contributors, including Windows, Linux, Bash and PowerShell users, must find the root manifest rather than change the workflow dependency manifest. The present fixed message supplies the file and field without a separate lookup.
- Both repository maintainers, documentation authors and agent operators need common diagnostics consistent with setup instructions. Review-only wording changes also create another common-file comparison obligation.
- CI, platform and recovery operators need stable tooling failure status and preservation of native filesystem and parser causes. They do not need a larger interface to identify the existing root file.
- Application and supply-chain security reviewers need contained, non-symlink, bounded manifests and no weakening of exact-runtime admission. Privacy owners need proportionate output; no secret or exploitable disclosure is established here.
- QA and independent quality reviewers need real fixture admission/execution evidence, source applicability and a truthful distinction between saved and newly run tests.
- Owner, audit/history custodians and schedule/cost stakeholders need an evidence-backed closure without an invented defect, future task or repeated aggregate.

Terraform users are affected through contributor tooling, not Terraform runtime behavior. Generated-artifact consumers, cloud administrators, security executives, accessibility and localization roles have no distinct changed surface: no cloud operation, artifact, settings, localized text or UI is proposed. Their interests in safety and clarity are covered above; no omitted authority is required.

## 3. List applicable options before scoring

| ID | Option | Consequence |
| --- | --- | --- |
| N | Retain the root package.json engines.node message; reply with source evidence | Preserves the precise current remedy and existing contract. |
| G | Use generic Markdown-lint package/manifest wording | Removes the explicit root location while retaining field/format. |
| P | Replace root wording with the actual canonical manifest path | Names a concrete file but gives a workspace-dependent location instead of the stable repository-root instruction. |
| Q | Keep the current instruction and append the canonical path | Retains precision and adds path detail that no current consumer requires. |
| D | Move declaration guidance to documentation and use a shorter command error | Reuses existing setup documentation but requires an extra lookup at the failure point. |
| F | Factor common manifest-error formatting across lint/npm helpers | Feasible native-code reuse; adds a shared interface/materialization and caller-verification obligation without a common defect. |
| R | Remove the declaration diagnostic or use a generic tooling error | Loses the actionable file/field/remedy. |
| T | Leave the message and defer the requested wording change | Same current product behavior as N, but invents future work despite disproved premises. |

Equivalent synonyms that still say repository-root package.json and engines.node collapse into N's semantic outcome; they offer no distinct demonstrated repair. Q combines N with P. Adding a source comment repeats the immediately adjacent path.join expression and does not improve the user-facing contract. A new dependency/framework is unnecessary for any option. A targeted exception cannot fix a nondefect and would weaken admission; it is ineligible. Deferral has no genuine task or trigger to track.

## 4. Define the R2 rubric

Scores range from0 to5:0 contradicts the criterion;1 has a major deficit;2 has a substantial residual;3 is usable with a material residual;4 meets the criterion with a limited residual;5 fully meets it for inspected supported consumers. Total = sum(weight × score /5). These are reasoned judgments, not measured failure rates.

| Criterion | Weight | Finding-specific meaning |
| --- | ---: | --- |
| Source and remedy correctness | 35 | Name the actual manifest and exact field/format without implying a different package. |
| First-failure usability | 25 | Let a new contributor locate and repair the declared field directly across ordinary/alias roots. |
| Bounded diagnostic safety | 20 | Preserve fixed invalid-input guidance, native causes and runtime rejection without unnecessary arbitrary input/path output. |
| Caller/output consistency | 12 | Keep the established CLI/API and setup-guide contract rather than invent a new consumer requirement. |
| Long-term upkeep | 6 | Avoid duplicated guidance and unneeded shared-interface/closure maintenance. |
| Delivery and verification cost | 2 | Keep work proportionate; reuse valid results and avoid unnecessary repeated controls. |

Hard constraints: preserve bounded/contained/non-symlink manifest checks, exact runtime policy, refusal before child execution, native parser/filesystem causes,0/1/2 statuses and valid mismatch detail. Do not claim that the review identifies a different manifest. Scores cannot waive these constraints. A deferred task requires an actual unresolved benefit; T fails that constraint.

## 5. Score every option before selection

| Option | Correctness35 | Usability25 | Safety20 | Consistency12 | Upkeep6 | Cost2 | Total | Key uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 5 | 5 | 5 | 5 | 5 | 5 | 100 | Reopen if a supported non-repository-root consumer appears. |
| G | 3 | 3 | 5 | 3 | 5 | 5 | 71.2 | Generic package wording could send readers to workflow/package.json. |
| P | 5 | 4 | 4 | 4 | 4 | 4 | 87 | Concrete aliases/long paths may help external callers; none is present. |
| Q | 5 | 5 | 4 | 4 | 4 | 4 | 92 | Extra path may be useful later; no current missing information. |
| D | 2 | 2 | 5 | 3 | 3 | 4 | 56.4 | Extra lookup cannot restore immediate file/field guidance. |
| F | 5 | 5 | 3 | 4 | 2 | 1 | 84.4 | New common error interface and executable closure need proof. |
| R | 0 | 0 | 5 | 1 | 5 | 5 | 30.4 | Fails actionable diagnostic preservation; ineligible. |
| T | 5 | 5 | 5 | 3 | 2 | 3 | 90.8 | No actual future task exists; ineligible. |

Arithmetic is checked in evidence.json. N =35+25+20+12+6+2=100; Q =35+25+16+9.6+4.8+1.6=92. N clears every hard constraint and uniquely wins. The deciding evidence is that root/package.json is the file being read and the current message already gives its exact repair location. Generic wording decreases clarity; path variants add variable output without a demonstrated missing remedy. Their safety scores reflect additional unneeded output/caller verification, not a claim that a known privacy vulnerability exists. The selection is not based on preserving scope or chasing review cleanliness.

## 6. State the selected action and limits

1. Keep the current declaration diagnostic.
2. Keep the root package.json selection.
3. Keep the manifest checks.
4. Keep the existing caller tests.
5. Explain canonicalManifest in the review reply.
6. Link this decision after root publishes it.
7. Reassess this decision if a supported caller changes the root contract.

The instructions use short direct sentences, one action per sentence, consistent technical names and explicit conditions. Applicable ASD-STE100 writing rules were checked at that level. No formal approved-dictionary compliance is claimed. No guide or instruction rule changes are warranted: this is a mistaken reading of an existing local path expression, not a missing authoring contract. No new Issue or deferred work is selected.

The native reply will cite this published canonical decision. Root verifies the reply and resolves the thread.

## 7. Implement the no-change disposition and verify

No product implementation is required. The full source/caller inspection above is complete. Current helper SHA256 is `ccd5ba35d181af52734d2d372eaa3af5a6c75a771f7eb7a721dc43c21b30aa68`; Git blob `08942d7df2fa607941ebb901e0477f1088175326`, mode100644. Relevant helper, test, manifests, README, local test and recurring CI caller hashes exactly match the saved R1 final evidence. The before/after guard in evidence.json covers all78 tracked raw files, HEAD/tree, index and stage0.

Saved Windows Node24.18.1 command: `node --test --test-name-pattern=^actual root manifest execution boundary: .github/workflows/lint-markdown.test.mjs` with the pattern supplied as one argument. All11 cases pass with0 failures/skips. They use real benign children and include root-alias, malformed, wrong-version and manifest filesystem/size boundaries. Saved ten-case equivalence probe performs20 real API calls; missing-field, invalid-field, mismatch and exact cases keep message/code/status/execution behavior. Named-test log SHA256 `8f600fef5c21933021264fa094592a632dd05fa450c3d244d517e1c128008944`; equivalence log `3fc0e26323a6375e9c23fc3ad6c19f3ea24ddd9852ec11f379ab76dc1f1e5d7f`.

Saved Linux aggregate runs the pinned Python pre_commit command on exact candidate tree89f470c. Its11 hooks pass with0 skips; result.json records exit0 and completion2026-10-05T15:30:59.829875Z. It is useful corroboration, not a new test of the mistaken wording claim. No product test, suite, aggregate, install or network request ran for this analysis. The source and existing executable fixture results are sufficient; no mirror assertion is added. Root retains fresh independent quality, hosted semantic evidence, reply/resolution and merge gates. Round2/80, fixed deadline2026-10-13T14:30:38.034661Z and A07/A21 transfer3/12 remain unchanged.
