<!-- markdownlint-disable MD013 -->
# D-A21-02: preserve runtime state through the actual SelfTest loader

## 1. Validate

The new runtime controls pass when all functions execute in one scratch script scope. They fail through a separate child script, which is the actual validator's `& Test-AgentInstructions.SelfTest.ps1` loading model. Linux PowerShell7.5.0 reports that `$script:pythonPathNames` is unset at `Get-Python312CommandContext` parameter binding. A second reproduction defines the exact final production function texts in a real parent script file, then invokes the extracted final test functions in a real child script. It fails identically. Evidence: `linux/loader-contract.log`, `linux/outputs/loader-native-origin.log`, and their saved parent/child scripts. This is a production-test integration defect, not an enforcement bypass or a failure of the selected complete PS base.

The complete dependency inspection found five runtime state variables: Python platform flag, candidate-name array, verified Python context, Python cache key, and verified Node context. Python's two parameter defaults and both resolvers' cache reads/writes explicitly use the nearest `script:` scope. The separate SelfTest has no such initialization. The staged query/reader, bounded process reader, Python probe, Node probe and TOML/Markdown wrappers introduce no other `script:` variable access. The wrappers call the affected resolvers; TOML's prerequisite text remains an inherited immutable value, while Markdown's PSScriptRoot is a script-file identity rather than cache state. Existing SelfTest metadata-date binding is separate and unchanged.

Microsoft's [about_Scopes](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-7.5) states that call-operator scripts create child scopes, unqualified reads search parent scopes, and `script:` selects the nearest ancestor script file. A shared reference object can retain state across those scopes. The reproductions establish the actual repository impact rather than relying only on that documentation.

Exact preimages are validator SHA256 `9cf6941630a647d128b9fbab7643cae013914c8f5180dd1dc0686b37d34c376d` / blob `552a28d7bec17b5f232cb08ccfe13d5bdc1bed7c` and SelfTest SHA256 `a20d675dd148792f406b81f34008f4af377f11e26689e077a73099098f522284` / blob `434d1ecb3f0d29bfc91cc2edef5422bca153b2f7`. They include root's eleven comment-only banner repairs. The worktree still uses HEAD3ba; root reports PR226 merged2a2d14a but has not integrated it here. No product edit has occurred for this finding at decision time.

## 2. Stakeholders

Windows/Linux contributors, local and remote agents, CI operators and both repository maintainers need the actual SelfTest command to execute its controls. Security/supply-chain reviewers need application-only resolution, finite probes and cache provenance to remain intact. Independent quality readers need a loader discriminator that the original same-scope harness lacked. The owner and history custodians need the single whole-PS selection, protected boundaries and source-order gates preserved. Runtime/dependency maintainers need the supported Python/Node invocation contracts unchanged. Cost/schedule stakeholders need bounded verification without another full aggregate before integration. No documentation authoring, cloud operation, credentials, private data, accessibility or localization interface changes in this two-file state-transport repair.

## 3. Options

- N: Keep the code and classify the failure as a harness limitation. This leaves the reproduced actual child model broken.
- R: Remove or move the runtime tests out of the extracted SelfTest. This hides the failure and loses the required loader coverage.
- U: Remove `script:` from scalar reads and remove caching. Inherited reads work, but repeated probes lose the retained cache/performance contract.
- I: Initialize all five scalar variables independently in the child. This repairs one caller by duplicating defaults/caches and obscures which state the controls exercise.
- H: Put runtime state in one reference object, with inherited lookup only. This removes the scalar shadowing, but leaves the child boundary implicit.
- E: Put runtime state in one finite reference object and pass that object explicitly to the existing SelfTest child. Give the private resolvers an explicit optional context parameter. Preserve the loader and test placement. Add a real child-script discriminator.
- D: Dot-source the whole existing SelfTest. This changes the established scope/isolation of every extracted test to solve a small state problem.
- M: Move runtime helpers into a module with private state. This provides native scope isolation but expands the loader/file architecture outside the authorized two files.
- X: Use missing-variable fallbacks or a SelfTest-specific cache exception. This treats individual symptoms, creates a second state policy, and can hide an incomplete caller.
- F: Defer the repair to the final aggregate. This knowingly leaves current code failing and spends the long aggregate discovering a reproduced bounded defect.

Native hashtable/reference semantics are reused by H/E. A generic context framework is M's larger redesign, not required here. A smaller unqualified-scalar repair with caching still writes the wrong local scalar and collapses into U or I. A temporary missing-variable waiver is X. Combining E with existing parser/transport code requires no second engine or new public mode.

## 4. Fresh rubric and hard constraints

Scores are design judgments, not measured reliability. Each score is0–5: 0 absent, 1 weak, 2 material gaps, 3 workable with significant limitations, 4 strong with bounded limitations, 5 directly addresses the complete criterion. Total=`sum(weight*score)/5`.

| Criterion | Weight | Meaning |
| --- | ---: | --- |
| Correct runtime and state behavior | 30 | Preserve verified identity, fallback, cache keys and strict failures in parent and child scopes. |
| Actual caller coverage | 25 | Preserve separate SelfTest loading and all supported platform/default/injected consumers. |
| Discriminating verification | 20 | Make genuine child-scope and cache regressions observable without expensive whole-suite dependence. |
| Maintainability and explicit ownership | 15 | Keep finite state ownership clear and avoid duplicate algorithms/defaults or broad scope changes. |
| Bounded churn/cost | 10 | Stay within the two owned files and keep validation/integration cost proportionate. |

Hard constraints: keep selected complete PS base P94; preserve all runtime, staged, parser, bounded transport and existing controls; do not remove/relocate controls or dot-source away their isolation; no public policy/mode changes, new framework/file, global state leakage, protected expectation change, initializer grant or authority inference; edit only the owned validator/SelfTest pair. A high score cannot waive these constraints.

## 5. Scores before selection

| Option | Runtime30 | Callers25 | Verification20 | Ownership15 | Churn10 | Total | Constraint or uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 1 | 1 | 1 | 2 | 5 | 31 | Known child failure persists. |
| R | 2 | 1 | 0 | 2 | 4 | 31 | Ineligible: removes/relocates required controls. |
| U | 3 | 4 | 3 | 3 | 4 | 67 | Ineligible: loses retained caching; repeated process cost. |
| I | 3 | 3 | 3 | 2 | 4 | 59 | Duplicate defaults and caches can diverge. |
| H | 5 | 4 | 4 | 4 | 4 | 86 | Correct reference semantics; implicit child dependency remains. |
| E | 5 | 5 | 5 | 4 | 3 | 93 | Requires explicit loader/context plumbing and real child tests. |
| D | 3 | 2 | 3 | 2 | 4 | 54 | Ineligible: broad test isolation change. |
| M | 5 | 5 | 4 | 3 | 1 | 82 | Ineligible: new module/file architecture. |
| X | 2 | 2 | 2 | 2 | 5 | 46 | Masks incomplete caller/default ownership. |
| F | 1 | 1 | 2 | 2 | 2 | 29 | Leaves current defect and delays its cheap discriminator. |

Arithmetic is checked in `core-loader-score-check.json`. E's total is `(150+125+100+60+30)/5=93`. H is `(150+100+80+60+40)/5=86`. These scores compare proposed solutions; they are not empirical acceptance evidence.

## 6. Selected solution

Select E. Create one finite runtime-context hashtable in the validator. Keep the platform flag, Python names, Python context/key and Node context in that object. Pass the same object to the actual SelfTest invocation. Bind it in the child. Let private resolver parameters receive that object. Keep the current probe and cache rules. Use the same object for the existing Python-name mutation controls. Restore changed fields after each control.

Keep the call operator and every existing test location. Add a bounded real child-script test that inherits the production resolver functions and receives the context explicitly. Prove parent/child cache identity, changed-name cache invalidation, and restoration. Keep injected fixtures from changing the live context. Exercise both Python and Node state. Retain a mutation that removes the context handoff or restores the old script-scoped dependency; it must fail through the actual loader model.

Use exact final function ASTs and the actual call boundary on Windows7.6.5 and Linux7.5.0. Keep original failures. Correct Linux console wrapping only in the scratch entrypoint harness diagnostic normalization; do not change product diagnostics for that harness issue. Do not run a full SelfTest or aggregate. Root retains accepted-source/shared-caller/protected-policy/native gates.

## 7. Implementation and verification

Decision completed before first edit; root independently read it and recalculated all10 totals before continued implementation. Selected E is implemented in only the validator/SelfTest pair. The validator owns one finite `hashtableRuntimeContext`; private resolver defaults read its fields through a `RuntimeContext` parameter. The actual call operator passes that object to the SelfTest's mandatory internal parameter, and the child binds the same reference. Existing Python-name controls now mutate and restore that object's fields. No public mode, test relocation, global variable, module, parser or authority change was made.

Final validator: 452848 bytes, blob `0b5789dbfc42fc05dfc4b99cd492aa578adb208a`, SHA256 `1c222f5baf94c3758247a41b028b4ff4d1a40cf7bc961fd3d6a25f573229936c`. Final SelfTest: 203280 bytes, blob `92db79a8d552e8c9adade97818f92851b365373d`, SHA256 `a6e1faa5e039a72f978a6d7f2d4d6cd1f69a6dc749b69adb55283fe172c0d754`. Both parse without errors and PSScriptAnalyzer1.24.0 reports no Error/Warning findings. `git diff --check` passes. Root's prior banner comments remain intact. The product worktree remains HEAD3ba with exactly two unstaged paths and no index change.

`core-loader/verify-loader.ps1` extracts the final runtime initializer, all production function definitions, actual SelfTest parameter/binding ASTs, the two focused test functions, and the exact main-file call-operator loader statement. It writes native parent/child script files and runs that boundary. It passes on Windows7.6.5/Python3.12.10/Node24.18.1 and Linux7.5.0/Python3.12.3/Node24.18.1. The parent warms both caches; the actual child reuses those identities, rejects changed Python names, restores the original contract, and verifies injected fixtures did not change live state. The nested durable child-script discriminator is retained in the SelfTest function.

Both platforms also pass the ordinary actual local entrypoint with staged mode, all8 real-entrypoint negatives, and4 in-memory weakening mutations: staged matching removal, Python application-filter removal, lowering the Node minimum, and bypassing Python cache-key equality. Omitting the actual loader's context argument rejects on both platforms with the missing mandatory RuntimeContext diagnostic. This is an expected negative, not a passing mutated candidate. Logs and generated parent/child scripts are under `core-loader/`; `final-file-checks.json` binds the reviewed bytes. Original scope failures remain under `linux/`; no failure was overwritten to claim success.

Linux used the cached image `sha256:2540dd9d184baa1f2bae22b0572200342a54d1d0bd7ab0dbdb326c36cee5bcdb`, no host mounts, and the repository's actual locked Node bootstrap in a copied private repository. Copied raw file SHA256 values match the final Windows inputs. The owned container `psstyleguide-a21-linux-focused-20261003` was removed normally. No full SelfTest or aggregate ran. No commit, staging, native-ref, GitHub, planning, peer or protected-file write occurred.

No new whole-base choice or completion target is introduced. Root must independently review these final changed bytes and later run the assembled final aggregate after accepted source/caller integration. A07 setup/hook activation, shared A21 selector/loader closure, common TF implementation/test equality, A20 protected expectations and A03 choices retain their existing gates. PR226 source acceptance/landing remains root-owned; its merge is not integrated into this worktree by this repair.
