# FQ45 retained-group dependency review

The identity registration must run fresh. The other six groups, totaling 37 registrations, have no additional changed effective Linux dependency. The corrected plan is 126 fresh registrations in 17 cells plus 37 retained registrations in six whole groups, still totaling 163. Windows remains 822 tests / 383 pass / 439 skips, followed by all 11 hooks.

This corrects the reuse38 assessment in the earlier preparation review. That review missed the FQ8 subcases inside the identity registration. The admission auditor's finding is real; root's selected D07 correction is appropriately limited to moving the whole identity registration to fresh execution. Earlier review files and the frozen packet are preserved.

## Confirmed identity gap

`Test-CiHelpers.test.mjs:3091–3260` registers one test whose body includes the initial native identity witness, nine FQ7 provider calls across three helpers, and four FQ8 ShouldProcess calls across the initializer and credential helper. Linux therefore makes 14 child calls. Windows adds the actual temporary-PSDrive witness, giving 15.

At lines 3205–3210, the credential helper slice begins at `function Assert-OrdinaryPath {` and ends immediately before `# Do not load user/system Git`. Unlike the smaller ordinary-path extraction, this includes the helper's top-level selector guards. The origin/current prefix diff adds exactly the FQ45 `GIT_ASKPASS`/`SSH_ASKPASS` presence loop. The old prefix hash is `33b8d457d9f0529f568e1ec5a3010b2d559c2e61e93e74e2f3a00be07b03f305`; current is `a288048b7952df88c73445fe538a5068ce5a499a63448c30186e9118652101ab`.

Both credential WhatIf/Confirm children execute those changed prefix bytes before their private-directory call. This affects two Linux children and two Windows children, represented by the four already parsed supplemental forms. The registration's own JavaScript constructor and native identity functions being unchanged does not make its entire effective input unchanged. Fresh identity1 is required; no further syntax run is needed.

## Six retained groups

| Group | Registrations | Full-scope dependency assessment |
| --- | ---: | --- |
| newline | 1 | The constructor, declaration-case generator, failure/dispatch oracles, fixture and complete initializer equal the actual origin. All 14 selected LF/CRLF declaration cases fail at initializer lines 1184–1193, before the credential call at line 1239. The fixture copies the changed credential helper, but neither executes it nor makes a hash/size assertion about it. Its changed bytes are outside every selected execution path. |
| download-capability | 2 | Both complete registrations, `fq40Region`, `fq40Constant`, `foundationOnce` and initializer match the origin. They inspect cap/call ordering and execute only the extracted curl-capability function with matrix and causal mutants. They do not load or call the credential helper. |
| download-boundary | 17 | The complete boundary/oracle constructor and all 17 registrations were checked. Initializer, extracted capability/installer functions and cap are unchanged. The only raw driver difference is the previously introduced Windows curl identity assertion branch. Exact inverse replacement recovers the old constructor; specializing both branches to Linux produces the same `assert.equal(observed.command, '/usr/bin/curl')` behavior and the same remaining text. No credential entry is part of these isolated installer fixtures. |
| path | 3 | Full Linux registration bodies and `fq34Run`/extraction/case construction match the actual origin. Each helper contributes only `Assert-OrdinaryPath` through the next function boundary. All three extracted bodies are unchanged, SHA `3c9a01d4d8a35c3cf4ce37037dbf5de091783e0d3dce9dba043cdfb5168d6bd8`. The later credential selector loops are excluded. |
| consumers | 4 | Full registration, fixture, Node mock and preference/mutant loop match the origin. Both workflow files are byte-identical. Each test executes only three extracted sanitation/Node/status lines through its Node observer. The named Node target appears as observed arguments; the real target and credential helper are not executed. |
| preinstall | 10 | All seven Copilot and three dedicated-review registrations, `copilotBodyFixture`, `copilotPreinstallFixture`, npm observer and exact argument/oracle construction match. Both workflow files and all seven copied package/lock/pin/contract/policy inputs are byte-identical to the actual origin. The selected installation step invokes the built-in-only policy preflight and mocked npm. It does not use the credential helper. |

The older path/consumers/preinstall driver headers differ by the subsequently added inert curl-query string constant and blank lines. These selected constructors never use that constant. The remaining shared header, quote/read helpers, process-completion oracle and relevant fixture bodies match. The imported policy module, workflow contract, runtime pin, and dependency catalog also match each actual origin. This assessment is based on complete registration scopes and constructor closure, not their names.

## Origin and comparison evidence

For each of the seven original groups, this review followed the frozen receipt's `raw_run_directory` to its actual `input/candidate` snapshot. It verified the receipt digest, actual origin source-catalog digest, and every one of the 78 snapshot file hashes. These are the snapshots that fed the accepted native runs, not a convenient later source tree. All seven origin dependency catalogs equal `b75f9a94e9a64d8d165321d27e4fb4e522e173752abdfeb8eaad86b7793d7e61`.

Exact relevant driver slices, source files and extracted helper functions were compared against current integration. The download-boundary Linux specialization hash is `22fd8364e0a1314e621ae89c621c8cf9a8a3f4e7d39fdb179c71bbc913052216`. `evidence.json` records each actual origin path, receipt/catalog identity, current hashes, dispositions and counts.

## Limits

Root still owns the small revised selection/binding packet, source/index and runtime admissions, and actual execution/settlement. Main and supplemental syntax evidence and the existing 78-source/1,914-dependency observation are unaffected. This report grants no runtime or merge credit and requests no extra native qualification or parser run. Only read-only source/hash/diff inspections and these two review outputs were performed; no product/helper imports, fixture evaluation, native test, Git mutation, state change or network operation occurred.
