<!-- markdownlint-disable MD013 -->
# TF75 finding 4267106824: full-process audit wiring

Decision proposal only. Root retains selection, writer ownership, execution and publication. No implementation, product import, test, native child, Git operation or public action was performed. Transfer1/8 is unchanged. This analysis concerns reviewed head 8a3b33c318a00c7627e1ca7b46ba006cace93fef and the saved round1 finding, not final PR acceptance.

## Finding and authority

**Confirmed, material P2 test-coverage gap.** In the current test, the synthetic Linux success at2437 and startup-scrub success use no-audit. Their required null audit fields and absence of an audit process are correct. The wrong-registry case enables the audit branch but stops at helper5793–5802, before audit5845. AUDIT-PUBLIC-SUMMARY1435 onward extracts normalization/display functions; adapter cases exercise child-result handling separately. Neither executes the complete top-level audit branch through final currentObservation publication. A regression that skips that branch or drops its normalized output can survive these controls.

The production join is helper5737–5746 (skip/execute),5843–5923 (actual audit child/parse),5958–6042 (shape, normalization, digest/count/summary assignments), and6511–6528 (final observation and npmProcesses). This is a missing causal integration control, not a demonstrated production defect.

Canonical A09 decisions D1/D4 correctly removed routine live-audit dependence from broad property tests. D4's maximum coverage score was conditional on the then-selected scope; it did not establish complete-module audit wiring. Its registry revision correctly retains the audit-enabled refusal. D5 requires exactly-one replacement enumeration. PR243 F1 correctly fixed false current live/historical claims. This new finding justifies an additional controlled whole-process case; it does not invalidate those factual corrections or require restoring live audit to every property success. Authentic old PS205/TF55 live evidence remains bound to its old inputs.

Current TF documentation416–418 accurately describes the existing gap's scope: synthetic no-audit process successes versus controlled production-adapter fixtures. Add a precise controlled-process statement if the new test lands. Do not rewrite historical T1, profile identities, old acceptance records or the live reproduction instructions.

## Actual execution constraints

- The recorder launches process.execPath with the absolute authenticated strNpmCli (2133–2141). A fake npm placed first on PATH does not intercept it.
- It locates adjacent bin/npm, requires containment in the Node distribution, folds npm and checks both the exact reviewed digest and1916-file count before the first child (4630–4710). This check is unconditional, including any-toolchain. The expected digest is f58556342f8abc9245e168904a6579b9b09e7dc10606df7a52fcd454ccec8231 (249–250), derived from the pinned Node archive as documented240–248.
- Strict runtime values are Node24.18.1/npm11.16.0/Linux x64; strict effective configuration and transport/registry checks remain active. any-toolchain relaxes listed comparisons and marks the observation incomplete (4907,5766,5793,6466–6469); it is neither an npm-authentication bypass nor needed for the recommended fixture.
- The four original manifest literals intentionally describe historical inputs. Current production refusal4 must remain. The existing synthetic transform2411–2434 admits current manifests in a private copy only.
- Existing private version-toolchain tests2553–2612 already copy Node/npm, change only copied npm CLI bytes, prove refusal2 under the production npm pins, then admit the private fold in another recorder. That precedent demonstrates the necessary source design boundary, not a new runtime result.
- Child writes must stay in fresh external cache/housekeeping space. Project, installed tree, Node/npm distribution, profile and recorder must stay stable across execution. Synthetic byte binding does not waive ownership, type, containment, inode, mount, startup, configuration, response, or post-run quiescence checks.

## Alternatives and permutation closure

| ID | Complete treatment | Main consequence |
| --- | --- | --- |
| A | Keep current suite; add comments or more extracted-function/adapter assertions. | Cannot cover the missing module-level join. |
| B | Add a separate Linux whole-module subprocess case: copy the admitted Node/npm distribution, intercept only audit in copied npm CLI, bind six private literals, use strict mode, retain real config/version/ls and all guards. | Deterministic actual process wiring; explicitly synthetic npm identity and audit response. |
| C | Same as B with any-toolchain. | Still needs private npm binding, unnecessarily omits strict comparison/transport branches and must emit complete=false. |
| D | Replace npm wholesale with a minimal command emulator in a copied distribution and bind its private tree. | Full module runs, but config/ls/version answers become another maintained fake implementation. |
| E | Instrument the full recorder's spawn boundary or use a Node preload/builtin mock while leaving npm intact. | Complete module can run, but actual npm process and startup/child binding are bypassed or altered; adds a separate instrumented execution model. |
| F | Run an isolated real npm against a local controlled registry/server. | Genuine npm normalization/transport; requires server/protocol/registry or TLS authority changes and process lifecycle work beyond this wiring gap. |
| G | Add a separate routine live audit under qualified inputs. | Real service coverage; variable registry/network/advisories remain a routine dependency. |
| H | Add only an opt-in live audit or historical installed-input reproduction. | Useful separately; ordinary regression suite can still pass without exercising the join. Historic installation is not current-input evidence. |
| I | Add a production public injection hook or relax npm authentication for tests. | Unnecessary public/security change, inadmissible. |
| J | Insert B into every existing property success instead of retaining their no-audit behavior. | Covers wiring but repeats controlled audit setup and couples later unrelated refusals to that fixture. |

These cover the meaningful axes: whole-module versus extracted execution; response control at real npm CLI, full fake npm, recorder runtime, local registry, or live service; strict versus diagnostic mode; separate versus shared property placement; current versus historic inputs. Merely changing the test name, adding retries, skipping unavailable service, or deriving expected output from actual output does not supply a new valid alternative. A PATH-only shim is unreachable here. B with a shared private setup function remains B; it must not mutate the existing property's fixture. Combining B with retained unit/adapter and no-audit tests is the selected complement, not a claim that those tests are interchangeable. A wholly independent miniature recorder is A. Arbitrary package or runtime versions are not required permutations: existing production qualification remains.

## Finding-specific rubric

Scores0–5:0 contradicts the requirement;1 severe gap;2 major gap;3 adequate with significant limitations;4 strong with a bounded limitation;5 directly meets the criterion. Total=sum(weight*score)/5. Scores are design judgments, not observed passes.

1. **Causal audit-to-publication coverage31%** — QA and reviewers need the real module, child outcome, normalization and final emitted fields.5 requires exact independent nonempty output and native-process expectations plus a causal negative control.
2. **Preserved qualification and truthful evidence24%** — security reviewers and history custodians need unchanged production pins/guards and explicit private transformations.5 retains strict production flow and distinguishes fixture authentication from actual reviewed npm/history.
3. **Reliable contributor/CI operation19%** — maintainers and contributors need a deterministic offline test, bounded child/output handling and no service incident masking later cases.5 has no routine network or historical installation.
4. **Interpretability and faithful surrounding behavior16%** — optional-tool users, support and new reviewers need a small explainable fixture and real surrounding config/ls/runtime behavior.5 avoids a fake replacement for unrelated npm behavior and makes complete-versus-synthetic scope explicit.
5. **Maintenance and reciprocal applicability7%** — both repositories' maintainers need narrow independently counted transforms and reusable assertions without a new controller or duplicated npm implementation.
6. **Incremental effort3%** — CI/cost owners benefit from low implementation and execution overhead; effort cannot outweigh correctness.

Hard constraints: no production trust relaxation, hidden live service, false historical/live proof, removed existing negative controls, self-derived production oracle, or public test hook. Inadmissible options do not become selectable through their total.

| ID | Causal31 | Qualification24 | Reliable19 | Interpretable16 | Maintenance7 | Effort3 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 5 | 5 | 3 | 5 | 5 | 68.8 |
| B | 5 | 5 | 5 | 4 | 4 | 3 | 94.2 |
| C | 4 | 4 | 5 | 3 | 4 | 3 | 80.0 |
| D | 5 | 4 | 5 | 2 | 2 | 2 | 79.6 |
| E | 3 | 3 | 5 | 2 | 3 | 3 | 64.4 |
| F | 5 | 3 | 4 | 3 | 1 | 1 | 72.2 |
| G | 5 | 5 | 1 | 4 | 3 | 2 | 77.0 |
| H | 2 | 5 | 3 | 3 | 3 | 2 | 62.8 |
| I | 5 | 0 | 5 | 3 | 2 | 2 | 63.6; inadmissible |
| J | 5 | 5 | 4 | 3 | 2 | 2 | 83.8 |

B's qualification5 applies to preserving production authority and explicitly scoped private admission, not to pretending patched npm is the reviewed release. Its interpretability4, maintenance4 and effort3 account for six literal bindings, a copied executable distribution and an npm prefix. C buys no required capability and drops meaningful strict flow. F offers deeper npm/network integration, but that is a different test goal; it is fairly credited with causal5 while its extra server/trust model lowers this bounded choice. J repeats work without covering an additional integration edge. B clearly leads under the stated goal; no close-tie preference is hidden.

## Selected proposal, subject to root disposition

Select B94.2. Add one separately named Linux/x64 test, for example AUDIT-WHOLE-PROCESS. Keep the existing LINUX property test and extracted controls. Change only the test file and the current method's coverage description. Leave the production recorder and historical profile unchanged.

1. Assert the original four manifest pins against the existing independent historical oracle. Also assert exactly one original npm digest declaration and exactly one numeric file-count declaration against the fixed values above. Do not read these expected values back from the declarations being checked. Their authority remains the previously pinned archive, not a digest printed by the fixture. Add independent wrong-value, missing-declaration and duplicate-declaration controls, including the numeric count.
2. Create a fresh protected disposable checkout and external caches. Copy the real current manifest/lock/profile/installed tree and the complete qualified Node/npm layout, retaining the launcher relationship. Copy actual process.execPath; do not symlink it back to the original distribution. Preserve modes and containment requirements. Use the established clean launch/configuration protocol. Pin reviewed registry `https://registry.npmjs.org/` in the finite clean fixture environment; do not inherit private npm credentials or arbitrary user/global configuration.
3. Insert a fixed audit-response prefix in the copied npm CLI after its single verified shebang. Retain all remaining original CLI bytes exactly. It returns the fixed nonempty audit JSON, empty stderr and native1 for the exact audit operation. Validate the required audit flags, canonical registry environment, excluded raw registry argv and cache/housekeeping arguments before returning that response. A malformed audit command must fail with a fixed non-success status, never fall through to a live npm audit. Pass only the existing --version, config list/get registry and ls operations to real copied npm; reject unexpected operations. Do not add an environment or public recorder switch for arbitrary responses. The response is fixed test data. No audit network request occurs.
4. First run the private manifest-bound recorder with the original npm digest/count and the modified copied npm. Require refusal2, empty stdout and the fixed npm identity diagnostic before npm execution. Obtain the private fold/count using the existing bounded production-fold observation technique. Treat it only as a test input, never as proof of reviewed npm. The original exact-pin assertion in step1 prevents this rebinding from concealing a production-pin change. Retain the existing original-helper current-manifest refusal4.
5. Bind exactly the four private manifest identities and two private npm identities in another disposable recorder copy. Require global exactly-one matches for all six declarations, enforce digest/integer grammars and prove inverse replacement returns the original raw source bytes. Keep all guard/function/branch/output code identical. Do not rebind Node/npm version, registry, config, profile digest, platform, mode or any guard. The test runs with --json and required fresh --cache-directory only: neither --no-audit nor --any-toolchain.
6. Execute the complete private recorder as a real subprocess using the copied Node. Use explicit finite outer timeout and existing16MiB output bound; assert no launch error or signal before inspecting native status. Root must select a timeout within its existing admitted native deadline; do not disable it to accommodate a hang. The ordinary run must return0. Audit child1 is an accepted vulnerability result; it is not recorder failure.
7. Use the concrete independent oracle below. Require exactly one audit entry with nativeExit1/signal null/stderrLength0, one ls entry with nativeExit0/signal null, and no failed/signalled other npm operation. Assert exact registry, complete=true, empty incompleteBecause, unchanged historical supplyFreeze, and private script/npm identity joins. complete=true means the synthetic strict recorder filled its required fields; it does not authenticate live advisories or historical installed bytes. Keep that distinction in the test name/comment and documentation.
8. Require before/after fingerprints of the fixture checkout and copied Node/npm distribution to match. Scope allowed writes to external cache/housekeeping. Avoid a marker written inside the copied npm tree. A diagnostic obtained before the first child is not an actual audit observation.
9. Run two private single-site source mutants through the same full-process oracle: force the skip-audit branch; replace published currentObservation audit fields with null at the final join. Each mutation must match exactly once and leave all other bytes unchanged. Each must be rejected by the semantic oracle, not counted as success merely because the process launches or emits JSON. Restore/retain immutable positive source between mutants. These directly cover the reported skipped branch and disconnected publication; existing response unit tests continue to cover detailed adapter failures.

### Concrete fixed response and independent expectations

Use auditReportVersion2; counts {info:0,low:0,moderate:0,high:1,critical:0,total:1}; one vulnerability named TASK_A09_AUDIT_PRIVATE_PACKAGE with severity high, isDirect false, range <1.0.0 and via [TASK_A09_AUDIT_PRIVATE_VIA]. Both names are fixed fake sentinels. There is one inherited-only high package and no direct-advisory package. Every other summary bucket, including unclassified, is zero.

The hand-authored normalized object contains that package's severity/isDirect/range, advisories:[], viaPackages:[the fixed via sentinel], the exact counts and auditReportVersion2. Use independently specified canonical bytes and their SHA256 in the assertion; do not invoke the production normalizer to manufacture the expected value and do not accept merely a64-hex pattern. EVIDENCE.json contains the complete response, normalized object, canonical bytes and independently calculated digest. Assert the exact digest, exact counts and exact fixed-vocabulary summary. Require both private sentinels absent from serialized public stdout/stderr. This is enough nonempty data to detect null/empty/default publication.

### Affected verification after authorization

Before native release: review the complete finite test/doc diff, original-pin negative controls, exactly-one six-binding transform and inverse proof, npm prefix allowlist/fallthrough, strict flags and fixed independent oracle. Check syntax using already qualified tooling under root authority. No install, runtime qualification or live registry audit is implied.

Minimum actual affected validation is the new Linux whole-process positive/refusal/mutation cases plus the focused original-pin/transform controls they add or change. Reuse existing qualified Node24.18.1/npm11.16.0 and network-disabled environment. Run HISTORICAL-MANIFEST-PINS, SYNTHETIC-PIN-TRANSFORM and AUDIT-PUBLIC-SUMMARY if their shared definitions are touched; retain the prior LINUX result for unchanged code, but rerun it if fixture/setup/helper changes affect it. Normal required precommit/document checks remain root-owned. Verify current guide416–418 and sibling claims accurately say controlled full-process synthetic audit, while existing broad properties remain no-audit and historical evidence remains historical.

Expected evidence joins: exact new test/helper/profile/package/lock/doc hashes; admitted runtime identity; selected test name and actual pass/fail/skip; positive recorder0/audit1/no signal; refusal2/no record; both mutants rejected; unchanged protected fingerprints; bounded completion. No actual results are claimed here. A Windows skip is not Linux coverage. This analysis does not reopen the final quality gate or alter the completed round1 review events.

## Inputs and limits

Read the saved TF75 round1 status, canonical A09 decisions, accepted PR243 F1 and current full-flow source slices. The helper/test hashes match the previously frozen candidate. Evidence records exact bytes. No historical objects were reacquired, no npm response was fetched, and no source/test was executed. All execution/implementation/public grants in this packet are false. Root's next action is to disposition B and, if selected, release the bounded test/document edit to the sole writer.
