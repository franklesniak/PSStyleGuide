# PR236 P1 — Preserve each required hook's executable behavior

## 1. Validation and authority

**Material finding confirmed by source inspection and the root-owned original-H reproduction.** Codex review5440089267, comment4205074634/threadPRRT_kwDOQkjdhM6p1T5Y, is bound to H64df5d77043b3e3d019b7d4d704635bd97598293. The current finite reader accepts a block `stages` field on every hook (validator890–925). The later checks inspect selected launcher/module/selector lines (1069–1107); only agent-instruction-contract has whole-body equality (1108–1118). Appending `stages:`, then an indented `- manual`, to check-json, check-yaml or actionlint changes none of those selected lines. The same omission applies to workflow-policy-contract. This is a valid configuration shape with a different activation contract. Manual stages require explicit invocation; ordinary run/commit does not imply manual. [Official stage documentation](https://pre-commit.com/#confining-hooks-to-run-at-certain-stages), [pinned4.6.2 native runner](https://raw.githubusercontent.com/pre-commit/pre-commit/v4.6.2/pre_commit/commands/run.py).

This completes accepted **C97.0**, not a new policy scope. Its step4 permits ordinary comments/blanks, step6 protects the exact active instruction guard, and step7 requires all eleven reviewed IDs/bodies/pins. P2 D98.4 also retained all eleven existing hook bodies and normal activation. Prior qualified tests establish their tested inputs, not safety of every currently admitted field combination. Root reports old-H CI/service success; that cannot disprove this admission counterexample.

Sibling analysis covers the complete admitted field vocabulary, not just stages:

| Property | Current source behavior | Required repair boundary |
| --- | --- | --- |
| stages | Arbitrary finite token arrays accepted on most hooks | Exact reviewed stage membership where present; absent override elsewhere |
| types | Arbitrary tag arrays; JSON can become Python, or YAML gain incompatible tag | Exact reviewed AND-tag membership; no unreviewed narrowing |
| files | Some whole-line checks, some selected regex lines, actionlint unconstrained body | Compare each complete reviewed selector, including folded scalar content |
| pass_filenames | Either boolean accepted except exact instruction body | Preserve each hook's reviewed field presence/value and default |
| always_run | Either boolean accepted on other hooks | Preserve workflow-policy/instruction true and reviewed absence elsewhere |
| entry | Wrapper/module lines can coexist with extra text; workflow body not exact | Compare complete command content, not anchor lines |
| args | Arbitrary array/literal data accepted; added --help may change command behavior | Exact ordered arguments and literal contents; absent when not reviewed |
| language/minimum version | system admitted, arbitrary finite version on other hooks | Exact reviewed presence/value; preserve actionlint inherited configuration |
| name | Finite one-line display label, agent name already exact | Permit existing benign display-name grammar except existing exact agent requirement |
| unknown/global fields | exclude/types_or/exclude_types/alias/additional_dependencies and top-level overrides already rejected | Keep these refusals; do not introduce new tolerated behavior keys |

`types` combines with files through AND filtering and false pass_filenames supplies no file arguments. Native execution effects of arbitrary extra command text remain unmeasured; the concrete authority defect is that the admission function accepts command changes it promises to exclude. [Native4.6.2 runner](https://raw.githubusercontent.com/pre-commit/pre-commit/v4.6.2/pre_commit/commands/run.py). No claim that every mutation exits successfully or that unexecuted native tests passed.

## 2. Stakeholders

The owner and security reviewer require admission to preserve actual executable checks. Contributors need understandable hook-specific diagnostics and freedom to keep ordinary comments, LF/CRLF, blanks and benign names. Maintainers need legitimate pinned dependency updates to remain an explicit reviewed process; this repair must not change the current actionlint pin or its inherited runtime. Windows/Linux and CI maintainers need no extra installed parser. Test and independent-quality readers need full-value mutations, native-data parity and evidence that the actual admission caller remains wired. Schedule/cost matters after correctness; fast partial rejection is not closure. Public instruction text, privacy rules, accepted optional setup, target-name enforcement, conversion guards and metadata policy remain outside this repair's source changes.

## 3. OPTIONS — before scoring

- **A: Retain current contract.** Leaves the demonstrated activation gap.
- **B: Reject only newly reported stages overrides.** Leaves types, operands, command and selector gaps.
- **C: Closed per-hook behavior-field schema inside the finite reader.** Selected; qualify field extraction and full value comparisons.
- **D: Exact normalized behavior-body projection for all eleven hooks.** Sound, but order/format coupling beyond semantic fields.
- **E: Literal whole-configuration equality.** Sound but rejects legitimate comments, names and layout changes.
- **F: Native Python parse plus closed semantic/duplicate-key schema.** Sound if qualified; adds trusted runtime/parser boundary.
- **G: C plus mandatory native parse at each product admission.** Sound but duplicate authority and extra runtime.
- **H: Only aggregate/reviewer evidence.** Does not enforce the product admission invariant.
- **I: New standalone hook-contract executable.** Separate invocation and dependency boundary must itself be enforced.
- **J: New general PowerShell YAML parser framework.** Large new ambiguous-input and dependency surface.

B combined with selected-line checks remains B, not complete C. C with an internal field helper is still C; a new external executable is I. Native parsing alone is insufficient: a valid schema deliberately allows behavior overrides, so F/G require the same closed contract. D can retain non-behavior names/comments but comparison of a normalized body usually rejects harmless field reordering; whole-file E additionally binds unrelated comments and root text. Deferral may keep the PR frozen, but is not a finding disposition. No option may waive CI, use direct-main edits, delete required hooks or weaken the target-name policy.

## 4. RUBRIC — distinct weights and hard limits

Scores0–5 mean absent, poor, partial, workable, strong and complete fit; these are prospective engineering judgments, not measured test results. Weights total100. **Behavior32** covers every reviewed hook's activation, selectors, whole command and arguments. **Security24** fails closed on extra fields/scalar ambiguities without expanding executable authority. **Usability19** keeps legitimate formatting/display choices and precise diagnostics with no new contributor setup. **Compatibility13** preserves the eleven hooks, finite safe-reader architecture and actual accepted source/runtime contracts. **Proof9** supports meaningful field-removal/addition mutations and native-data parity through actual functions/callers. **Cost3** measures sustained code/maintenance/runtime burden only after the other criteria. An incomplete activation/operand check, accepted hiding form, lost required hook or unsupported claimed test pass makes an option ineligible regardless of total.

## 5. SCORES / SELECTION

| Option | Behavior32 | Security24 | Usability19 | Compat13 | Proof9 | Cost3 | Total /100 | Main tradeoff |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 1 | 1 | 2 | 5 | 1 | 5 | 36.6 | Leaves the demonstrated activation gap |
| B | 2 | 2 | 4 | 5 | 3 | 5 | 59.0 | Leaves types, operands, command and selector gaps |
| C | 5 | 5 | 5 | 4 | 5 | 4 | 96.8 | Selected; qualify field extraction and full value comparisons |
| D | 5 | 5 | 4 | 4 | 5 | 4 | 93.0 | Sound, but order/format coupling beyond semantic fields |
| E | 5 | 5 | 2 | 2 | 4 | 4 | 78.4 | Sound but rejects legitimate comments, names and layout changes |
| F | 5 | 4 | 4 | 3 | 4 | 2 | 82.6 | Sound if qualified; adds trusted runtime/parser boundary |
| G | 5 | 5 | 4 | 4 | 5 | 2 | 91.8 | Sound but duplicate authority and extra runtime |
| H | 1 | 2 | 3 | 5 | 3 | 5 | 48.8 | Does not enforce the product admission invariant |
| I | 4 | 4 | 3 | 2 | 4 | 1 | 69.2 | Separate invocation and dependency boundary must itself be enforced |
| J | 5 | 4 | 3 | 2 | 4 | 1 | 75.6 | Large new ambiguous-input and dependency surface |

**Propose C96.8**, the unique highest score. C closes the shared cause without treating inert formatting as behavior. D is a sound second choice at93.0; its lower usability reflects avoidable order/body-format coupling. F/G can be sound, but add an executable parser dependency or duplicated product admission path. C's compatibility/cost scores remain4 because the finite field map and canonical constants need maintenance and qualification. Root selected this option after displaying both complete decisions. The selection below releases only the scoped source repair.

## 6. Selected controlled-English steps

1. Keep H64 and the reproduction records unchanged. Use the selected repair after the root selection recorded below.
2. Use the current finite reader and safe input path. Record each admitted hook field and its complete value. Keep duplicate/unknown-key and scalar-boundary rejection.
3. Define trusted per-hook behavior contracts in the current validator. Do not learn the expected contract from candidate YAML. Cover all eleven IDs and every behavior-bearing field in the table above.
4. Require the reviewed field set and values. Keep args and scalar data ordered and exact. Compare types/stages as finite reviewed sets only if the implementation rejects duplicate tokens and tests order equivalence; do not normalize command/scalar whitespace into a different command. Do not add defaults or optional overrides that the reviewed contract does not contain.
5. Preserve finite benign name handling for other hooks. Keep the existing exact agent-instruction body requirement. Keep comments/blanks outside scalar data and LF/CRLF positives. Keep literal comment-looking scalar data significant.
6. Leave the actual eleven-hook configuration and actionlint pin unchanged. Preserve its current repository/revision admission rules. Do not add a new hook, parser dependency or invocation path.
7. Emit a diagnostic that names the hook and violated behavior field. Add actual-contract mutations for every field family, including remote actionlint and workflow-policy-contract. Verify the real main call through existing bounded fixtures.
8. Preserve accepted optional-workflow controls, strict readers,109 conversion cases, complete-name enforcement and canonical .gitignore index restoration. Update only the current validator/SelfTest plus P2's .gitignore within the current three-path PR scope, with ordinary actual UTC metadata.

These are controlled short instructions; no formal ASD-STE100 dictionary certification is claimed.

## 7. Bounded reproduction and final obligations

REPRODUCTION.md supplies exact future commands, owned input/output layout, qualified runtimes,4MiB streams/16MiB total,15s Git commands and180s/stage limits. The original-function probe and native configuration data parse distinguish admission from service/hook execution. They are unexecuted here. Root may release that small packet independently of source edits.

After selected repair, test canonical LF/CRLF, harmless names/comments/blanks and permitted field ordering; preserve all prior hiding/Unicode-linebreak refusals. Mutate every hook's present/absent behavior fields, full args/commands/selectors, stages and types. Include a remove-required-field case and a retain-anchor/add-extra-content case. Exercise actual setup-contract functions and a targeted real-main invalid config with a specific diagnostic; do not rely on a duplicated regex or source-string wiring assertion. Keep native schema data checks as comparison evidence, not a second product parser. Use unchanged qualified bounded transports; no broad29-mode replay is implied. Final-byte parser/PSSA, ordinary eleven-hook aggregate including full SelfTest, required actual B/H endpoints/audit, independent quality and normal new-head review/CI remain required. Existing old-H results stay historical; no source edit, test, review request, transfer or clock reset occurred here.

## Root selection and executed reproduction

Root displayed the options, distinct rubrics, complete score tables and selected instructions before releasing source edits. Both recommendations are selected under the existing owner authority; no new owner decision is needed. The original preparation statements above describe what the author had not executed, not the current reproduction status.

The bounded Windows reproduction ran from 2026-10-07T09:29:31.357696+00:00 to 2026-10-07T09:30:27.847806+00:00. PowerShell7.6.5, Python3.12.10 and native pre-commit4.6.2 used bound runtime and source hashes. Both private setup stages and both probe stages exited0, with every owned Job empty and no cleanup signals. Source, dependency and runtime guards passed. The actual original setup contract accepted the canonical configuration and all nine behavior mutations; native pre-commit parsed all ten. Git recorded60 outcomes for three rule variants, including a real symlink to a directory. The selected pattern variant kept all tested legitimate paths visible and all tested artifact/cache/private-memory paths ignored. The two-pattern alternative hid the ordinary suffix-named directory and its child.

Commands and bounded raw results are identified by [the selection record](selection.json). Full executable hook runs were not part of this reproduction. Independent Linux reproduction also passed: all60 Git outcomes and all10 native schema mappings match Windows, including a real Linux symlink. See [the independent report](linux-reproduction/REPORT.md). Final repaired-source validation remains unfinished. Source changes are limited to the existing three PR paths. No staging, commit, push, merge, new review request, deadline reset or transfer increment is released by this record.
