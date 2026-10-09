<!-- markdownlint-disable MD013 -->
# FQ23: process environment cleanup and inherited preferences

- **Status:** Accepted
- **Owner:** A07 coordinator
- **Last Updated:** 2026-10-08
- **Scope:** FQ23, actual unattended environment-provider prompt and same-family lint/selector behavior.
- **Related:** [Focused Linux validation](current-main-validation/fq24-linux-runtime.json), [owner decision process](../../../DECISION-PROCESS.md)

Diagnosis and proposal only. Inspected 2026-10-08T23:27:31Z. Requested reviewer gpt-6.1-sol/high; effective metadata is not exposed. No descendants, product execution, tests, product/planning/index/ref changes, or API mutation occurred. Root owns adoption, implementation, validation, and publication.

## 1. Validated finding and exact scope

**Material product defect confirmed:** on both reported instruction CI executions, the whole initializer under inherited `ConfirmPreference='Low'` prompts while removing an inherited process environment selector. NonInteractive PowerShell terminates before the controlled second curl dispatch. The test's native99 expectation is appropriate; sanitizing the fixture alone would hide an actual unattended-helper failure.

Reviewed integration checkout: `C:/Users/flesniak/.codex/worktrees/r5-toolchain-integration/PSStyleGuide`, HEAD `4eabb04bc8fa2f12c327ea6be8f7450ab0aa3032`. Index is clean. Exactly two unstaged files remain the already reviewed FQ21/FQ22 credential header and README repairs. The three FQ23-relevant files match their committed content:

| File | Bytes | SHA256 |
| --- | ---: | --- |
| `.github/workflows/Initialize-CiToolchain.ps1` | 65798 | `58f346042e5c55a909c42687963027c644dfcfdfffa301f038cc4b5fbad7d7c7` |
| `.github/workflows/Invoke-MarkdownLint.ps1` | 12332 | `daa0108031720a12cb62fc5eee2aa3be75c343c7800168579333db7eaadcdb95` |
| `.github/workflows/Test-CiHelpers.test.mjs` | 243847 | `1e36e68f42ecd4219f153ec74447965f38043a48221cd2e7dafbbf6afd470fbe` |

Independently hashed the two saved native logs:

| Run / saved log under W | Bytes | SHA256 | Recorded suite result |
| --- | ---: | --- | --- |
| `37855732032` / `PR239-round1-instructions-37855732032.log` | 180992 | `15abe4c7fa3ea11fede547d3a66c1e9002133ec7902cfe5898c4aec30257bb9e` | 726 tests, 685 pass, 1 fail, 40 skip, 0 cancelled/todo |
| `37855640235` / `PR239-round1-instructions-37855640235.log` | 181324 | `b39ebdb0218b710c46145cfc860b2ed691f35f7c1645384a211d9be46a21692c` | Same |

W is `C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-R5-B1-implementation-20261007`. Parent authenticated run-status observations identify attempt1 failures completed at23:12:22Z and23:14:49Z respectively. This reviewer verified the saved log contents and hashes, not the remote status API anew.

Both logs identify the sole failing registration `F5 ordinary valid declaration proves curl dispatch observation`, JS2212, with the failed assertion at2225. Expected `/Runtime download failed: 99/u`; actual diagnostic identifies `Remove-Item`, initializer1201, and inability to read/prompt in NonInteractive mode. F5 already passed default native99/one-dispatch and inherited-WhatIf directory refusal assertions before reaching this Low-confirmation assertion. It is a second execution of the copied real initializer, not an isolated mocked cleanup function.

Call chain: `ordinaryDeclarationFixture`2164 creates the declaration, copies the real credential/initializer sources, and substitutes only fixed Git/curl executable locations. `fixture.run`555 copies `process.env` into each child, overlays runner/fixture channels, and removes selected inherited Git/token inputs. It does **not** remove Node/npm selectors. The child is `pwsh -NoLogo -NoProfile -NonInteractive -File`, with ErrorAction Stop, bounded30-second timeout, and native completion admission. The Low-confirmation wrapper2223 changes only ConfirmPreference before invoking the actual initializer. Credential/declaration/path checks run first; exclusive channels open1193–1194, the actual restricted root gate1195 succeeds with explicit Confirm:false, ownership is recorded1196–1200, then1201 requests confirmation on an existing environment item. Curl acquisition1039 is later. Finally cleanup remains ownership checked and channels stay empty; the existing cleanup assertions completed before the diagnostic assertion failed.

The logs do **not** identify which fixed selector exists or disclose its value. They demonstrate an existing target in the fixed1201 removal set; do not claim NODE_OPTIONS specifically, a hostile value, a npm selector, or a particular CI service environment configuration. Repeated identical failure is not evidence of a transient failure.

## 2. Related source behavior and previous evidence

All relevant environment-provider removal sites in the three runtime/credential helpers are exactly:

| Site | Existing purpose | Preference defect |
| --- | --- | --- |
| Initializer1201 | Remove stale `STYLEGUIDE_RECOVERY_NODE22`, `NODE_OPTIONS`, `NODE_PATH`; tolerate absence | Confirm inherited: actual CI failure. WhatIf inherited: cleanup would be skipped if reached under that preference. |
| Initializer1206 | Remove every enumerated name matching case-insensitive `^npm_config_`, using LiteralPath | Same prompt/skip risk when any matching name exists; source-confirmed, not the logged failure site. |
| Lint271 | Remove `NODE_OPTIONS`, `NODE_PATH`; tolerate absence | Same prompt risk. Inherited WhatIf skips removal before Node dispatch if this stage is reached. |
| Lint276 | Remove every enumerated case-insensitive npm selector using LiteralPath | Same prompt/skip risk; later owned assignments overwrite only reviewed names, not arbitrary hostile selectors. |

`-ErrorAction SilentlyContinue` on the fixed lists handles ordinary absent-item errors; it does not disable ShouldProcess confirmation. Preserve it, the enumerated names, literal-path handling, removal order, reviewed config assignments, and all native exit handling. Do not add Force, broader ErrorAction suppression, persistent environment edits, or new selector namespaces. Existing archive-process environment isolation718–721 is separate. Node/npm calls inherit the current process environment; no later universal child environment scrub replaces these four removals.

The lint source itself sets reviewed `$env:npm_config_*` and CI values after cleanup, then calls exact preferred Node/npm for both lint scripts. It has no script-wide SupportsShouldProcess/preview contract. Its current WhatIf behavior can therefore leave ambient NODE_OPTIONS or an unreviewed npm selector while still allowing native execution. This is a security-relevant source consequence, not a second observed CI failure or a claim of successful exploitation. Linux whole lint can reach this stage under inherited WhatIf; on Windows the preceding credential helper can instead refuse its private directory creation, so do not claim a Windows whole-lint WhatIf cleanup execution without proving reachability.

Read the actual selected FQ8 S93 at P/results/A07/R5-B1/integration-repair-quality-recheck/REPORT.md and its integration-repair2-preparation/quality/final-readiness records. FQ8 applies to **external filesystem** creation: two New-PrivateDirectory implementations, real pre-mutation ShouldProcess, and three production calls with Confirm:false and WhatIf:$WhatIfPreference (initializer1034/1195; credential311). Keep all three bindings and the controlled decline before directory/DACL/POSIX mutations. A process-local environment scrub has a different purpose: mandatory sanitation before child execution, already paired with unconditional direct environment assignments. Explicit sanitation does not authorize bypass of those external gates.

The specifically requested `integration-repair2-preference-initialization/REPORT.md` records FQ12, not the original FQ8. FQ12 fixed local Constant declaration preference inheritance; its previous F5 WhatIf error prevented later Low-confirmation execution. It is relevant precedent for precise per-command internal initialization bindings, not proof that ambient environment deletion was covered. Earlier FQ8 F5 maintained coverage has all three preference children, but the absence/presence of these selectors was host-dependent. A sanitized private parent can make Low-confirmation pass because absent items do not reach a removal confirmation. The current fixture source independently establishes that explanation. I did not find a bounded retained preparation record proving the exact selector state of every prior native child; therefore report this as a plausible input difference, not a newly verified historic fact. The old Windows aggregate skips this Linux-only F5 registration. Earlier exact-input directory/ACL, source, archive, metadata, credential, and other unrelated checks remain scoped evidence; they are not invalidated or expanded into environment-preference proof.

## 3. Primary source basis

Microsoft documents Environment-provider **ShouldProcess** capability and session-local environment item operations. Removing these items affects the current process/session, not persistent machine/user configuration. Environment names are case-sensitive on Linux and case-insensitive on Windows; keep enumeration with `-imatch` and the exact actual key for removal. [Environment provider](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_provider?view=powershell-7.6), [environment variables](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables?view=powershell-7.6).

Microsoft documents per-command `-Confirm:$false` as overriding automatic confirmation and `-WhatIf:$false` as overriding inherited preview. These switches apply to the individual command, so explicit bindings at four environment calls do not change the later/earlier external gates or caller preference variables. The Remove-Item warning about nonempty-directory prompts is unrelated to this flat Environment-provider namespace. [Common parameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters?view=powershell-7.6), [preference variables](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-7.6), [Remove-Item](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.management/remove-item?view=powershell-7.6).

The .NET API alternative can target Process and delete using a genuine null string. Empty string is no longer equivalent to deletion on .NET9+, and PowerShell's documentation illustrates its null-to-string binding distinction. Replacing the established provider implementation would need native proof of true-null binding, key absence, unusual npm key names, and platform behavior. It is feasible, but offers no needed capability here. [Environment.SetEnvironmentVariable](https://learn.microsoft.com/en-us/dotnet/api/system.environment.setenvironmentvariable?view=net-10.0).

## 4. Options before scoring

Hard constraints: correct actual noninteractive failure; sanitation cannot silently skip before native dispatch; retain meaningful inherited/direct private filesystem ShouldProcess; no global preference reset; preserve bounded ordinary/config/ownership/security checks and native failures; test selector presence explicitly; do not label a synthetic stage as a successful full platform/profile run. Security and correctness outrank minimizing edits. Stakeholders are unattended CI operators, callers using inherited preferences, runtime/security maintainers, and reviewers needing native exact-source evidence.

| ID | Complete candidate |
| --- | --- |
| S | Add both explicit `-Confirm:$false -WhatIf:$false` at the four existing Environment-provider Remove-Item calls. Keep their arguments/order/error behavior. Add deterministic present/absent behavioral and mutation coverage. |
| H | Move those same operations into narrow process-environment helpers with explicit command bindings. Same contract and coverage, but adds declarations/help/calls without needed reuse. |
| A | Replace deletion with controlled process-only environment APIs (including `$env:` null syntax for fixed keys and correctly bound actual-null .NET deletion for enumerated names), or all .NET Process deletion. Preserve names/ordering and add removal/absence/case/native proof. |
| P | Save preferences, override only inside a narrow cleanup scope, restore through finally before all filesystem/native operations. Feasible with disciplined scoping, more state and exception-path proof than S. |
| F | Explicit Confirm:false, plus a new fail-closed refusal whenever inherited WhatIf reaches cleanup/lint. Prevents leakage but introduces a broader unsupported lint/setup refusal contract instead of deterministic internal sanitation. |
| E | Move all native launches to explicitly isolated child-environment maps, including version probes, installs, lint and published runner channels, avoiding ambient process changes. Broader architecture; must prove every launch/publication and recovery consequence. |
| C | Add only Confirm:false. Fixes the observed prompt but leaves lint sanitation skip under WhatIf. |
| I | Fix only initializer; leave lint unchanged, or only fixed lists; leave enumerated npm removal unchanged. Partial same-family repair. |
| G | Set script/global ConfirmPreference=None and WhatIfPreference=false, or force all mutation calls. Silences prompts by defeating the retained filesystem preference contract. |
| T | Sanitize only fixture/CI parent, weaken expected99/dispatch assertions, or catch the prompt as accepted refusal. Hides real caller failure and leaves lint selectors. |
| N | No repair; retry CI as transient. Both logs and source contradict the premise. |

Test-only improvements accompany every eligible product option; they do not substitute for product correction. Binding only WhatIf:false is also ineligible because it leaves the observed prompt. Provider existence checks alone only avoid absent errors and cannot suppress prompts on present items. Attribute-only/renaming/suppression has no effect on this built-in provider behavior.

## 5. Distinct FQ23 rubric and score table

Weights: sanitation/security30, actual failure and semantic correctness25, precise user-preference contract20, credible native proof and observability20, bounded change cost5. Raw0–5; total is sum(weight×raw/5). A score is a design assessment, not executed repair acceptance.

| Criterion | 0 | 1 | 2 | 3 | 4 | 5 |
| --- | --- | --- | --- | --- | --- | --- |
| Sanitation30 | Executes with uncontrolled selectors | Hides exposure | Known skip remains | Covers only some sites/launches | Complete isolation with new mechanics to establish | Exact mandatory cleanup at all four sites; no broader authority |
| Correctness25 | Retains failure | Oracle-only workaround | Partial prompt remedy | Additional behavioral ambiguity | Fixes failure with changed semantics to establish | Same removal semantics/order and unattended completion |
| Preference20 | Disables external refusal | Broad override | Misleading preview | New broad caller behavior | Preserves external gates with extra scoped obligations | Only internal sanitation overrides; unchanged real filesystem gates |
| Proof20 | No relevant proof route | Claimed from unrelated passes | Generic pass lacks phase witnesses | Many new paths or stage obligations | Existing sharp witnesses plus bounded deterministic additions; runtime pending | Complete final native positive/negative exact-input proof available |
| Cost5 | Unbounded redesign | Broad launch redesign | Several new contracts | New helper/API/scoped state | Modest local changes | Four bindings and maintained focused fixtures |

| Option | Security | Correctness | Preference | Proof | Cost | Total | Eligibility |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| S | 5 | 5 | 5 | 4 | 5 | **96** | Selected; runtime proof still required |
| H | 5 | 5 | 5 | 3 | 3 | 90 | Feasible; added helper/interface work without benefit |
| A | 4 | 4 | 5 | 3 | 3 | 79 | Feasible; null/empty/platform binding and altered error behavior |
| P | 4 | 4 | 4 | 3 | 3 | 75 | Feasible; restore/scope/exception obligations |
| F | 5 | 4 | 4 | 3 | 3 | 81 | Feasible; new unnecessary external refusal contract |
| E | 4 | 4 | 5 | 2 | 1 | 73 | Feasible architectural alternative; broad execution/publication proof |
| C | 2 | 3 | 4 | 3 | 5 | 60 | Ineligible; WhatIf sanitation skip remains |
| I | 3 | 3 | 4 | 3 | 5 | 66 | Ineligible; same-family sibling/selector gap remains |
| G | 1 | 4 | 0 | 2 | 4 | 38 | Ineligible; violates meaningful external refusal |
| T | 1 | 1 | 4 | 2 | 5 | 40 | Ineligible; fixture acceptance hides product defect |
| N | 0 | 0 | 4 | 0 | 5 | 21 | Ineligible; real failure unaddressed |

S wins independently of churn: it gives the strongest sanitation, correctness and preference preservation while retaining the proven provider implementation. Its proof score4 deliberately excludes unexecuted native repair validation. No new owner permission question is required for this clear bounded selection within the authorized repair objective; root must retain/display the complete process before editing.

## 6. Controlled selected actions and meaningful verification

1. Change only the four environment Remove-Item invocations in the two PowerShell files. Bind Confirm:false and WhatIf:false on each call. Keep SilentlyContinue only where it already tolerates absent fixed names. Preserve LiteralPath for enumerated names, case-insensitive npm selection, exact config replacements, owned cleanup, native result handling and runner publication.
2. Explain briefly near sanitation that process-local selector removal is mandatory before child execution. Do not claim script-wide preview support. Leave New-PrivateDirectory declarations/ShouldProcess bodies and all three `-Confirm:$false -WhatIf:$WhatIfPreference` filesystem callers byte-identical. Preserve the FQ12 local Constant initialization binding. Apply published-version metadata rules only as required; an unmerged work-in-progress commit is not a newly published version.
3. In the maintained fixture, explicitly construct a private child-environment selector set instead of relying on ambient parent state. Preserve unrelated fixture variables; never clear the whole process environment or print values. For absence controls delete only the targeted names from the child map, case-insensitively for npm and with the platform model for fixed keys. For presence controls use harmless fixture values (not host values). Keep NoProfile/NonInteractive, native completion, timeout, strict paths/config checks, and cleanup witnesses.
4. Preserve F5's exact behavioral phases: ordinary valid input reaches exactly one controlled curl/native99 failure; inherited WhatIf+Low refuses at the real restricted directory gate with no extra dispatch and empty channels; Low without WhatIf reaches one additional curl/native99 with owned staging removed. Make the presence test deterministically include the stale recovery selector and harmless NODE_OPTIONS/NODE_PATH; use a fixture-owned Git launcher that removes only synthetic Node selectors before its Node-based Git mock so the preflight mock cannot fail before product cleanup. The test must still execute the real credential logic. Add a separate npm-only presence case with fixed selectors absent to exercise1206 rather than stopping at1201. Both paths need an executed phase marker/observation and exact expected diagnostic; an arbitrary nonzero exit is insufficient. Include a true absent-target control.
5. Extend the existing actual lint fixture and its child Node observer to check **key absence**, not just falsy values, before both native lint operations. Verify every seeded unreviewed case-variant npm key is absent, NODE_OPTIONS/NODE_PATH are absent, and the reviewed npm config paths identify ordinary empty owned files. Verify unrelated fixture state survives and exact outer/nested native exit aggregation and call order remain. Exercise default, Low, inherited WhatIf, and Low+WhatIf on Linux with present and absent selectors; cases may share the existing finite fixture setup rather than duplicate a framework. Explicit whole-lint WhatIf is possible on Linux because the credential branch does not create the Windows private directory.
6. Keep whole-initializer WhatIf refusal **before** cleanup; do not force it past that gate just to obtain a positive preview run. A copied-source cleanup-stage control may set WhatIf=true immediately after the single exact `$boolOwned = $true` admission, before sanitation, to witness the initializer's internal stage bindings. Require exact one anchor, stage marker, sanitized environment observation, and intended native99 dispatch/cleanup; label it as an internal-stage preference perturbation, not a real whole-initializer WhatIf success. This closes the otherwise unreachable inherited-WhatIf removal branch without weakening the actual gate test.
7. Add four meaningful copied-source mutation controls: remove Confirm binding separately from fixed and enumerated removal; with only the appropriate seeded targets present under Low, require marker then native NonInteractive confirmation failure at the intended site and no later dispatch. Remove WhatIf binding separately from fixed and enumerated removal; at reachable cleanup stage under WhatIf, require the observer to reject retained key(s) with a dedicated sanitation diagnostic before a successful Node/npm outcome. Use exact one relevant replacement, keep other bindings intact, and prove each good baseline reaches the intended marker/observer. These controls detect both selector families; a marker-only or source-token assertion is insufficient. Do not credit initializer whole WhatIf's earlier directory refusal as a deletion-mutation witness.
8. Root should execute the real affected Linux maintained cases on final bytes, including F5, lint modes, preferred/recovery initialization and their existing archive/install/exit controls. Execute changed process-environment cleanup and preference controls under actual Windows PowerShell7.6.5 with real Windows case-insensitive environment behavior and the existing qualified private NTFS/temp prerequisites. Existing Windows credential whole-WhatIf refusal must remain. If a Windows cleanup-stage control uses a copied actual source or reviewed native snippet because Windows preflight refuses earlier, record that precise stage scope; do not advertise it as whole Windows lint/acquisition/profile proof. No fake profile or POSIX overlay substitutes for native Windows behavior. Preserve genuine platform skips.
9. Rebind hashes/catalog after implementation, check native parser/PSScriptAnalyzer and Node syntax/generated fixture wrappers, then execute required maintained aggregate and configured hooks with unchanged-source receipts. Check final source diff confines semantic changes to those bindings/comments and focused fixtures. Existing clean source/ACL/archive/credential evidence is reusable only on unchanged inputs/mechanisms. Parent decides finite runtime limits/case counts from actual registrations, not this proposal. After later FQ20 base integration, rerun ordinary exact-head CI/review and publication gates as required. This proposal itself closes no runtime gate.

## 7. Delivery/state limits

FQ20 reader-first service-schema bridge has no direct dependency on these environment removal sites: its prerequisite retains the old initializer and ordinary test source. Continue that separate five-path work unchanged. Do not pull these fixes into it, inspect its mutable candidate, widen its acceptance scope, or prematurely publish the schema2 writer. FQ23 belongs to the later R5/B1 integration repair alongside the already reviewed FQ21/FQ22 work.

No CI relaunch, retry exemption, merge, review request, reset clock, transfer increment, source change, or native profile pass is proposed as completed. PR239 remains on the original round1 first-request time2026-10-08T22:53:27.970214Z and deadline2026-10-16T22:53:27.970214Z; A07 transfer9/12 remains unchanged. Both current instruction runs are failures. Root can adopt S96 within the existing authorized objective, then implement and obtain the actual gates above. No additional user decision or acceptance machinery is needed.

## Root decision and execution release

At 2026-10-08T23:33:00.173853+00:00, root read the complete proposal, independently verified both failure-log hashes, all three affected source hashes, all four removal sites, and all11 score totals (native d06f7f). Root verified Microsoft primary documentation for Environment-provider ShouldProcess and per-command Confirm/WhatIf overrides. Options, rubric, complete score table and selected controlled actions were displayed to the owner before product edits. S96 is accepted. The preceding proposal-only statements describe preparation, not the current release. Implementation is authorized in the three named integration files, preserving the existing FQ21/FQ22 edits. No runtime or publication acceptance is claimed.
