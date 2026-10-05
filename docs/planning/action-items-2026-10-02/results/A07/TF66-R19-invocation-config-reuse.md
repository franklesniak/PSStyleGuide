<!-- markdownlint-disable MD013 -->
# R19 — reuse the validated configuration within one staged invocation

## 1. Validate actual work and scope

Comment4179947038 correctly identifies a repeated whole-tree scan. The current staged process calls `lintOuterMarkdownContents`, which loads configuration, then calls `lintNestedMarkdownContents` with an undefined configuration, triggering another load. Each standalone full outer/nested CLI already loads once. The scan excludes node_modules, .git and .venv at any depth. It does not traverse installed dependencies by design.

Actual staged execution with a wrapper around real globSync recorded exactly two identical-selector scans on a private250-file/500-directory non-Markdown tree. Windows scan times were85.53 and59.00ms; Linux46.20 and21.31ms. These single synthetic measurements do not establish a production latency defect, representative large-repository cost or expected CI speedup. They establish duplicated work that one invocation can avoid. No full suite or production benchmark ran.

The [D90/E90 contract](review-braces-decision.md#current-d-reassessment-and-implementation-contract) requires rejecting introduced selectors throughout ordinary nondependency paths. Restricting checks to root/workflow would violate it. Actual independent loads in both probes also reject a nested selector introduced between calls. That is observed current freshness, not an atomic concurrency guarantee or a rule requiring a second scan between the two phases of one invocation. A private invocation-owned configuration can retain fresh checks between independent public calls while reusing one snapshot within the staged process. No unsupported-config race-free assurance exists today and none is proposed.

Input: TF H `dde2b9abe761af69a7f561512df7d44d0dec6745`, tree `d59a740b7b1d88f7986075ac9328d9998629aa71`, B `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`. Full authenticated comments are in `review-comments.json`; ten immutable raw source blobs/modes/hashes are in `source-identities.json`. Windows/Linux probe code, commands and observations are in `probe.mjs`, `windows/result.json`, `linux/result.json` and `linux-run.json`. No product edit, dependency installation, full suite or aggregate was performed. Scores are judgments, not measured reliability.

## 2. Stakeholders

Contributors and GUI Git users benefit from less repeated traversal, especially with many local directories. Both maintainers and security reviewers need complete unsupported-selector refusal and explicit rule semantics. API/test consumers need fresh default loads and no stale process-global cache. CI/platform engineers need bounded evidence rather than an unmeasured speed claim. QA needs shared outer/nested configuration and default freshness verified through actual behavior. Reviewers need a small change that keeps the current authority boundary. No personal data, credentials, deployed runtime or destructive recovery changes are involved.

## 3. Options and combinations

N retains existing loading. E measures and retains it until a representative bottleneck warrants optimization. P loads and validates once in the staged CLI, passes that invocation-owned configuration to both phases, and keeps standalone API defaults fresh. M caches per repository for the life of the process. V adds explicit cache invalidation or a filesystem snapshot. R narrows scanning to root/workflow paths. G combines complete Markdown/config discovery into one reusable walk. S moves validation to CLI preflight and trusts downstream APIs. X removes selector refusal.

P includes the useful combination of invocation ownership plus unchanged default API behavior. It does not require global caching, an invalidation framework or narrowing coverage. S with preserved independent API defaults and a validated invocation-owned value becomes P. G may also use P, but its extra full-tree discovery restructuring has a different cost and is not needed to remove this duplicate. Caching keyed only by root is not invalidation. A robust V must account for newly created nested selectors, not only the selected config file's mtime.

## 4. Unique rubric and gates

Scores0–5 mean:0 fails the objective;1 very weak;2 substantial limitations;3 useful but limited;4 strong with a stated residual;5 satisfies the criterion on the inspected design/evidence. Total=sum(weight×score)/5. Hard constraints override totals. Churn/effort are not reasons to reject a correct useful change.

Coverage35 preserves recursive ordinary-tree refusal and exclusions. Freshness20 preserves fresh independent default API/CLI invocations without inventing a requirement for repeated scanning inside one invocation. Execution cost20 rewards eliminating demonstrated redundant traversal, while discounting unmeasured global speed claims. Compatibility15 preserves existing two-argument outer/default nested behavior and current status/rules. Proof7 rewards actual positive/negative policy controls and discriminating shared-config evidence. Maintenance3 penalizes stateful cache/invalidation or extra discovery architecture.

Hard constraints: no loss of nested selector detection, exclusions, regular/bounded rules loading, explicit JSONC/JSON priority, outer/nested rule differences,0/1/2 behavior, or existing default fresh loads. No process-global stale cache. Sharing the declared validated configuration within one CLI invocation is eligible. No atomic snapshot promise is implied.

## 5. Scores before selection

| Option | Coverage 35 | Freshness 20 | Execution cost 20 | Compatibility 15 | Proof 7 | Maintenance 3 | Total | Evidence/tradeoff |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 5 | 5 | 3 | 5 | 4 | 5 | 90.6 | Retains all behavior but leaves the confirmed duplicate invocation scan without targeted cost evidence. |
| E | 5 | 5 | 3 | 5 | 5 | 5 | 92 | Bounded measurement establishes the small current sample; no runtime improvement. |
| P | 5 | 5 | 4 | 5 | 4 | 4 | 94 | One validated config per staged invocation removes one real scan; standalone default loads remain fresh. |
| M | 5 | 1 | 4 | 3 | 3 | 3 | 70 | Process-global cache can miss later roots/selector additions/config changes. |
| V | 5 | 4 | 3 | 3 | 3 | 1 | 76.8 | Correct invalidation/snapshot can be designed, but proving it may cost another walk and adds state. |
| R | 1 | 5 | 5 | 2 | 4 | 5 | 61.6 | Ineligible: root/workflow-only checks miss nested unsupported selectors. |
| G | 5 | 5 | 4 | 4 | 3 | 2 | 88.4 | Shared complete discovery may reduce more traversal, but couples full-tree and staged APIs. |
| S | 4 | 3 | 4 | 2 | 3 | 3 | 68 | Moving checks entirely to an entrypoint loses independent API/default safety unless it becomes P. |
| X | 0 | 0 | 5 | 1 | 1 | 5 | 27.4 | Ineligible: removes the selected unsupported-configuration contract. |

Recommend P94. E92 is a reasonable no-change alternative because measured overhead is modest and not representative. P wins on the concrete removal of one repeated scan without narrowing policy or introducing a global cache; the recommendation does not depend on declaring a production performance incident. The two-point margin is not empirical certainty. Implementation must preserve fresh defaults and prove the intended shared invocation behavior; if that needs a larger architecture, return to this same decision rather than silently expand.

## 6. Selected controlled-English steps

Keep the complete selector scan. Load the configuration once inside the staged caller's existing tooling-error boundary. Keep that value local to the invocation. Pass the value to the outer and nested phases. Add an optional preloaded configuration parameter to the outer helper, consistent with the existing nested helper. Use a fresh validated load when that parameter is omitted. Preserve the current outer call form. Do not add a module cache. Do not narrow discovery. Keep native status and install guidance unchanged.

The preloaded value is a configuration object returned by the existing repository loader; it is not accepted-policy authority or a bypass permission. The staged caller must always obtain it through that loader. Existing direct API callers can already control their in-process execution; this change does not create a privileged boundary. Document the optional parameter so callers know the default remains a fresh load.

Proposed paths: `.github/workflows/lint-nested-markdown.js`, `.github/workflows/lint-staged-markdown.mjs`, and the existing `lint-markdown.test.mjs` only for meaningful combined-invocation regressions. No guide/protected metadata edit is needed. Controlled-English intent is followed without formal dictionary certification.

## 7. Meaningful verification after selection

Use an actual staged Git fixture with configured rules and nested content to prove both phases enforce the same loaded rules and still reject unsupported nested configuration before linting. Record one real scan for that invocation with instrumentation that delegates to actual glob, not a mocked result. Preserve existing independent-call config-change, JSONC/JSON, unsupported-selector and0/1/2 controls; verify a new independent default load still rejects a newly introduced selector. Reuse unchanged full CLI evidence because those paths already load once. Do not add an assertion that merely searches for a parameter name or mirrors assignment syntax. No full suite is requested here. Root selection/private implementation release must precede any postimage; the cited probe is diagnosis only.

## Coordinator selection and evidence

Root selected P (94/100) at 2026-10-05T00:50:37.233582+00:00, after displaying the alternatives, finding-specific rubric, complete score table and controlled-English steps in that order. The authorized author is implementing only the selected private repair. No product integration, new remote request or acceptance has occurred. No additional owner decision is needed.

Root read all four proposals, checked all23 new weighted totals, sampled four raw source blobs against native H, and read the complete Windows/Linux probe results and probe code. The frozen diagnostic guard covers the unchanged78 tracked files, index and1910 dependency files. The nine selector controls passed on both platforms. Actual staged execution recorded two scans before the selected repair; these are synthetic timing samples, not production benchmarks.

Private commands and full outputs are located by [STATUS](../../STATUS.md), under `TF-coherent-20261004/implementation/round5-review-findings`. Windows used pinned Node24.18.1 with `probe.mjs`; Linux used `run-linux.py` with its exact recorded Docker image, arguments and network-disabled run. No full aggregate was repeated for the diagnosis.

| Diagnostic evidence | SHA256 |
| --- | --- |
| `HANDOFF.md` | `0bf764e89a1b02aa93fc41172df3221a41de572226e51c9a1f78daafbc29e701` |
| `evidence-catalog.json` | `f08f72e90776f16ab015e628d987aec219f264364b6c0b0bea7ced21a3c8b2e5` |
| `final-source-guard.json` | `6e695acbb4820fb7e661972869b79aa8019e8cf015252f2e4d020d6cb884f5ef` |
| `windows/result.json` | `1a0477bc77a6fbd664794cfcda7ac0e36a2ccf08dbe5bb7c245fb459da27b55b` |
| `linux/result.json` | `23cc455b29f420d268b775e8e268fc7474b896b03858898d4cf4ff6ab9f6c87b` |

[Canonical peer lifecycle](../A02/coherent-peer-candidate.json) records implementation, tests, native dispositions, review rounds and acceptance separately.

## Private implementation verification

The final private implementation passes focused Windows/Linux checks and independent source review. Full candidate validation is still required before publication. The actual staged process uses one real selector scan; the final configured-rule case fails with the original two-scan implementation. Independent API freshness controls also pass.

Fixture note: the retained fake module lacked the new loader export, so three expected status-2 cases could pass before reaching the intended call. Add that export and an outer-call marker. All five status cases pass on each platform with the staged-byte assertions retained.

Encoding note: private default-decoding edits changed existing Unicode test literals. Restore the complete21009-byte original prefix from raw Git bytes and retain the two added tests unchanged. The three affected Unicode cases pass on each platform; the rejected freeze remains recorded.

The [canonical peer evidence](../A02/coherent-peer-candidate.json) links the frozen handoff, source guards, exact commands/logs and independent report. Neither focused evidence nor this review establishes full-aggregate, native-review or paired acceptance.
