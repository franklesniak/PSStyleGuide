<!-- markdownlint-disable MD013 -->
# FQ23 implementation review and FQ24 fixture-scope decision

- **Status:** Accepted
- **Owner:** A07 coordinator
- **Last Updated:** 2026-10-08
- **Scope:** FQ24 test-only preference lifetime in three maintained Linux registrations; product and filesystem gates unchanged.
- **Related:** [Focused Linux validation](current-main-validation/fq24-linux-runtime.json), [owner decision process](../../../DECISION-PROCESS.md), [FQ23](FQ23-ENVIRONMENT-PREFERENCE.md)

**FQ23 product repair: source PASS. Whole three-file candidate: NOT accepted because FQ24 is a confirmed maintained-fixture defect.** The two WhatIf mutation baselines and internal-stage positive leave an injected preference active at a later real filesystem gate, so they cannot reach their required curl observer. This is a test implementation defect; no product sanitation or filesystem gate repair is justified. The separate40 Windows cleanup-stage forms are suitable source for a bounded root release, subject to native qualification/controller acceptance; they do not traverse the affected role gate and remain unexecuted.

Requested reviewer gpt-6.1-sol/high; effective metadata is not exposed. No descendants, product/test/controller execution, Docker/native probes, product/planning/index/ref/public edits or API calls occurred. Root was notified immediately after the finding. Only this report is written. Root owns adoption, repair, execution, staging and delivery.

## Frozen inputs and reviewed scope

Integration checkout I: `C:/Users/flesniak/.codex/worktrees/r5-toolchain-integration/PSStyleGuide`; branch `codex/r5-toolchain-foundation`; HEAD `4eabb04bc8fa2f12c327ea6be8f7450ab0aa3032`; tree `2d7552415b932eedbfa9c5f0da4413867c6e4ccb`. Read-only status confirms no staged changes and exactly five unstaged tracked files: the three FQ23 paths plus the two preserved FQ21/FQ22 files. No other untracked product path appears. Full three-file native diff and its fixture/caller dependencies were inspected. Actual hashes match the freeze:

| File under `.github/workflows/` | Bytes | SHA256 | Raw candidate blob |
| --- | ---: | --- | --- |
| `Initialize-CiToolchain.ps1` | 65934 | `20fd176523d46168642b812f3ed28449bbf10f4503003d1b695981ce0b8e7740` | `30bbb7b09747e76048e3205695600b31b8be8b21` |
| `Invoke-MarkdownLint.ps1` | 12464 | `7b3e3569dbdabe7823bfce777c02af7920c89f65f2d674f24315a9823d8c882b` | `49c7c09ca26b6b7dfe8040988bb509b3c53c4b31` |
| `Test-CiHelpers.test.mjs` | 252129 | `f82e5a38884744ad0c070511f5a9a745dc842d4e8c486973a80be23056fb4df2` | `195951057403bd099af1516536467eef61260d51` |

Preserved credential SHA256 `699887e6414275ec3a9d7ec5d17715c0adcb301446676d91bfeff6d06d13e769` and README SHA256 `33017e17fd45b1b6aa3e2a76e0c0d185b38c81f708ddb39bfc37bc4a20dccfaf` match the accepted FQ21/FQ22 review. W is `C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-R5-B1-implementation-20261007`. Writer report W/fq23-implementation/REPORT.md is9013 bytes and independently rehashes to `787843c80944d10194472aceeabafd2ed7e36e5f21e8b9c1b0a5d3beb4e6770b`; generated-form-registration-inventory.json is513107 bytes/SHA256 `96711c821048235b042dd3b9db71ef7a3e0927aec3137486eb9292ab38f13647`.

Read the complete accepted canonical FQ23 S96 decision including root's validation/display/release addendum at `C:/Users/flesniak/GitHub/PSStyleGuide/docs/planning/action-items-2026-10-02/results/A07/R5-B1/FQ23-ENVIRONMENT-PREFERENCE.md`. Operative guide/MUST rules and previous FQ8/FQ12/FQ21/FQ22 dispositions remain as recorded in the preceding independent reviews. B/FQ20 was not inspected or changed in this task.

## Accepted product delta and remaining fixture strengths

Product delta is exactly four explicit Environment-provider `-Confirm:$false -WhatIf:$false` bindings and two fixed explanatory comments. Original selector names, SilentlyContinue only at the two fixed lists, LiteralPath enumeration, case-insensitive npm selection, config assignment, execution/exit handling and owned cleanup are unchanged. No global preference assignment, Force, privilege, persistent environment mutation or blanket suppression is introduced.

All three external filesystem callers retain inherited WhatIf and explicit unattended Confirm:false: initializer role1034/root1195 and credential private-config311. Their helpers and real pre-mutation ShouldProcess refusal remain unchanged. FQ12 credential Constant New-Variable325 retains explicit WhatIf:false/Confirm:false. Production semantics therefore satisfy the accepted S96 separation: mandatory process-local sanitation, meaningful real filesystem preference gates. The discovered FQ24 behavior is an expected consequence of preserving the role gate, not evidence to weaken it.

JS child-map deletion is confined to explicit undefined overrides in a newly created private environment object. selectorEnvironment clears targeted inherited keys before harmless fixture overlays, uses the platform model for fixed names and case-insensitive npm names, and preserves unrelated state. It never mutates process.env or prints host values. Presence/absence and fixed/npm/all families are deterministic. A fixture-owned Git launcher strips only the harmless synthetic Node inputs before its Node-based fixed Git mock; the actual credential helper still runs. Shell paths/arguments are quoted and the launcher does not scrub the later curl/Node sanitation observer.

The observer checks key presence with Object.hasOwn, all seeded unreviewed variants, ordinary nonsymlink empty owned config paths, and unrelated fixture state before accepted native dispatch. The existing lint success/outer5/nested6 cases retain exact two-call order and aggregated exits; malformed package/ready object cases require intended JSON refusal before any npm call. Eight added preference×presence lint registrations exercise actual Linux whole-lint behavior. The inherited whole-initializer WhatIf+Low case still requires real root-directory refusal, no cleanup-stage marker, no additional sanitation observer or curl dispatch, empty channels and owned cleanup; normal default/Low controls retain exact native99. Fixed/npm/absent probes and all four mutation definitions use completed native children with stage/observer/diagnostic/count discrimination rather than generic nonzero credit.

The21 focused registration/27-child source counts are consistent:13 lint registrations, two npm/absent Low cases, one internal-stage positive, four two-child mutations, and one three-child F5. Actual native execution/count/order reconciliation remains pending. The inventory list groups F5 ahead of the new initializer cases; actual source registration order puts F5 after them, so root should derive/reconcile TAP ordering from source/runtime rather than treat grouped inventory order as a passed plan.

## FQ24: precise validated defect

Test-CiHelpers.test.mjs initializerCleanupStage2274 injects `Write-Output 'FQ23 cleanup stage'` and, for its WhatIf mode, `$WhatIfPreference = $true` immediately after the single actual `$boolOwned = $true` anchor. There is no restoration. All subsequent original initializer code remains active.

After sanitation/config assignments the initializer calls Install-ReviewedRuntime for preferred (candidate1223). That real function calls New-PrivateDirectory at1034 with `-Confirm:$false -WhatIf:$WhatIfPreference` **before** invoking curl1039. The inherited true preference therefore causes `Restricted staging directory creation was declined.` at the preferred-role directory. The inserted stage marker may be printed and sanitation may work correctly, but the curl observer/native99 cannot run. Keeping both real filesystem gates is a hard requirement.

Affected maintained registrations:

1. `FQ23 initializer internal-stage WhatIf sanitation` requires native99/one observer/one accepted dispatch but refuses at the role gate first.
2. `FQ23 initializer sanitation mutation WhatIf fixed` first requires its good baseline to reach native99/observer. That baseline fails at the role gate; the mutation also cannot provide its intended native98 observer discrimination.
3. `FQ23 initializer sanitation mutation WhatIf npm` has the same defect.

Exact generated full-copy evidence supports the call-chain finding: WhatIf baseline SHA256 `c039e57aa74729e5d7e700128384deb19adb081dd7fe26c0c9c9553fb8453e33`; fixed mutation `bc60e93f795a9f94016ce527c458d04c11fd546e8fb186afbdb3118139970623`; npm mutation `a1ef6b0cff06e5026727091f264e3b974ab86116bfea90f4d8b07a11d0396d77`. Each contains exactly one WhatIfPreference assignment, true, and no restoring assignment. This is independently validated source behavior; no new runtime failure is claimed. Parser success cannot establish preference-scope correctness.

The issue is a material committed-test readiness blocker, not a private controller-only defect. It prevents the selected oracle/mutation proof and would fail maintained Linux CI even with correct product sanitation. The original FQ23 diagnosis and S96 product selection remain valid; FQ24 needs its own test-scope decision before an edit.

## FQ24 options before rubric

Stakeholders: security/runtime maintainers need unweakened real filesystem refusal, CI operators need deterministic meaningful tests, reviewers need exact-source native positive/negative witnesses, and callers need honest preview scope. Hard constraints: no product change for a fixture mistake; no forcing either real directory gate; preserve whole-initializer early refusal; retain actual sanitation observer/native99 baseline and native98 mutated refusal; bind changed generated forms; keep parent preference/environment unchanged and no false whole-profile pass.

| ID | Complete route |
| --- | --- |
| S | Confine injected WhatIf to the copied actual environment-cleanup block. Save original WhatIf state, enable it only for that block, restore with try/finally before config assignment and Install-ReviewedRuntime. Require an explicit restoration witness as well as existing stage/observer/native outcomes. Keep actual cleanup command text and product source unchanged. |
| C | Execute the exact copied cleanup block in a nested PowerShell script scope with local WhatIf=true, relying on scope exit for restoration. Preserve process environment mutations and prove outer preference after return. Feasible but adds implicit scope/output behavior to a whole-script copy and needs its own native scope proof. |
| R | Set WhatIf=false at one exact later pre-role anchor without saving/restoring the original value. Works for today's injected false→true fixture but hardcodes caller state and does not isolate failure paths. |
| O | Move sanitation observation immediately after cleanup and terminate deliberately before role creation, replacing native99/native98 curl witnesses with explicit stage success/refusal. Feasible exact-stage contract, but changes the selected whole copied-helper dispatch proof and adds new diagnostics/oracles. |
| W | Keep true active but accept the role-directory refusal as successful sanitation proof, or drop the affected positive/mutation cases and rely on Windows snippets. This cannot prove Linux retained-key mutation discrimination at the intended observer. |
| G | Force the role directory's WhatIf false in the product or copied body, mock/remove either directory gate, or reset preferences globally. Violates the retained filesystem contract and can conceal a product regression. |
| N | No change or rerun unchanged tests as transient. Cannot alter deterministic call order/preference inheritance. |

A new pure standalone sanitation helper/rewritten duplicated test block is covered by C/O's altered scope/observer alternatives, with additional extraction/interface drift. A controlled environment API product rewrite does not address this fixture preference lifetime and is outside the finding. Combining W/G with another route does not make weakened gate/mutation proof eligible.

## FQ24 unique weighted rubric and scoring

Weights: preference-lifetime isolation30, faithful sanitation/mutation observation30, preserved real filesystem/user contract25, concrete native proof/reviewability10, bounded repair cost5. Raw0–5; total=sum(weight×raw/5). Scores assess designs, not executed candidate acceptance.

| Criterion | 0 | 1 | 2 | 3 | 4 | 5 |
| --- | --- | --- | --- | --- | --- | --- |
| Lifetime30 | Uncontrolled broad override | Escapes to real mutations | Only normal exit corrected | Correct today's path with state assumptions | Isolated with implicit/extra scope obligations | Explicit original state restored on all cleanup exits before later gates |
| Observation30 | No sanitation proof | Arbitrary nonzero accepted | Missing mutation/reachability | New stage-only contract | Strong proof with added scope/stream obligations | Existing real observer/native99 and native98/prompt discrimination retained |
| Contract25 | Forces external mutations | Mocks/removes meaningful gate | Misleading whole preview | Gate preserved but coverage reduced | Preserved with additional caller assumptions | Both actual directory gates and whole early refusal unchanged |
| Proof10 | Unsupported assertion | Generic pass | Broad new framework | New scope/control proof needed | Exact anchors/commands and sharp new restoration witness; runtime pending | Complete current native positive/mutant proof already available |
| Cost5 | Broad product redesign | New framework | New standalone interface | Several new fixture contracts | Small copied-fixture scope and regeneration | One trivial literal change |

| Option | Lifetime30 | Observation30 | Contract25 | Proof10 | Cost5 | Total | Eligibility |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| S | 5 | 5 | 5 | 4 | 4 | **97** | Selected; actual repaired native proof pending |
| C | 4 | 4 | 5 | 3 | 3 | 82 | Feasible; implicit scope/stream behavior needs more proof |
| R | 3 | 5 | 4 | 3 | 5 | 79 | Feasible today's path; weaker original-state/error lifetime |
| O | 5 | 3 | 5 | 3 | 3 | 82 | Feasible stage-only alternative; selected dispatch proof replaced |
| W | 2 | 1 | 3 | 1 | 5 | 40 | Ineligible; meaningful Linux mutation proof removed |
| G | 1 | 3 | 0 | 1 | 4 | 30 | Ineligible; violates real filesystem preference contract |
| N | 0 | 0 | 3 | 0 | 5 | 20 | Ineligible; cannot close deterministic readiness defect |

S97 wins on correct lifetime, retained proof and actual gate preservation, rather than churn. No new human preference question is necessary for this clear technical winner within the existing authorized goal. Root must independently validate/display/record this distinct decision before the test repair; this reviewer makes no edit or execution release.

Primary basis remains Microsoft's documented child-scope preference propagation and per-command overrides, together with the actual preserved source gate. [Preference variables](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-7.6), [common parameters](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_commonparameters?view=powershell-7.6), [PowerShell scopes](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-7.6). No direct remote script was imported or executed.

## FQ24 controlled selected repair and verification

1. Change only the committed initializerCleanupStage test-copy transformation and necessary assertions/generated inventory. Keep both products, FQ21/FQ22, B/FQ20 and every real directory gate unchanged.
2. Locate the actual single ownership anchor and the actual single sanitation block end immediately before `$env:npm_config_userconfig` assignment. Reject absent/multiple anchors before constructing a copy. Preserve the exact selected actual sanitation commands; do not reconstruct them from an independent alternative implementation.
3. For WhatIf stage mode only, capture the prior preference, execute the exact actual cleanup block with WhatIf=true inside try/finally, and restore the captured preference in finally. The temporary override must end before configuration/runtime-role work. For ordinary stage mode, keep its prior marker-only transformation. Do not introduce a public product switch or modify ConfirmPreference.
4. Add a fixed restoration marker/assertion on successful return that compares observed prior/restored preference state before any role acquisition. Keep the existing ownership-stage marker, good baseline's one sanitation observer/accepted dispatch and exact native99/empty-channel/owned-cleanup assertions. Keep whole WhatIf+Low refusal before stage-marker execution and before any additional observer/dispatch.
5. Keep the four mutation sites exact one-binding changes. Confirm mutants still require intended removal/NonInteractive failure after stage marker and before the curl observer. WhatIf mutants must run under the temporary true cleanup preference, then restore caller state, reach the rejecting observer, produce dedicated retained-selector/native98, and never record accepted99 dispatch. Require repaired good baselines before mutant credit; do not accept a role-gate failure as the observer result.
6. Rebind driver/source/generated-form hashes and parse the exact regenerated full-copy forms and wrappers. Reconcile source registration order and final27-child prediction with actual maintained TAP; count changes only if real registrations change. Root must execute the three affected registrations/positive controls and complete required affected Linux/aggregate/hooks on final bytes. Existing valid Windows sanitation-stage evidence can retain its own exact inputs; it does not prove this repaired Linux stage lifetime or whole profiles.

No runtime result, repeated CI request, merge or blanket acceptance is implied by selection S97. If root chooses an equivalent narrower explicit save/restore placement, it must preserve the same bounded actual cleanup window, restoration/error-path guarantee and concrete witnesses; do not re-score a mechanical implementation.

## Separate Windows stage source readiness and static/MUST limits

Independently recomputed UTF8 byte counts/SHA256 for **all58** embedded generated-form source strings: zero mismatch. Every one of40 Windows case IDs maps to exactly one Windows form, contains a real `$IsWindows` admission guard, has no Install-ReviewedRuntime call, and records executed=false. There are32 positives (two helpers × four selector families × four preferences), plus8 individual parameter/family mutations linked to good baselines.

Initializer fixed target includes stale recovery; lint fixed target is only NODE_OPTIONS/NODE_PATH. Their seeds and native observer key lists reflect that difference, so lint is not falsely required to delete the recovery selector. The Windows observer uses native Environment keys and case-insensitive `-imatch`/`-iin`, with mixed/uppercase npm seeds and actual absent-key observations. Positive cases require status0 plus stage/acceptance markers and preserved unrelated state. Confirm mutations retain explicit WhatIf:false and select Low; intended NonInteractive removal failure/no acceptance is meaningful. WhatIf mutations retain Confirm:false and select inherited WhatIf; retained-key observer rejection/no acceptance is meaningful. No native mock platform or real external-directory/NTFS/install/profile success is asserted.

These forms are suitable **source** for root's bounded native Windows cleanup-stage release because FQ24's later role gate is absent. Root must still pin actual Windows PowerShell7.6.5 and use the specified private child-map removal with native case-insensitive comparison before seeding. Actual completion/status/markers/intended site diagnostics and unchanged-source receipts remain required. This report does not accept a future controller, approve ambient environment mutation or execute a case. Existing whole Windows credential WhatIf/ACL prerequisites remain separate; passing stage cases cannot close them or all FQ23.

Generated static inventory records54 PowerShell forms with zero parser errors; three concrete Node bodies and whole driver qualified syntax exit0; one sealed Git shell launcher still awaits root Bash -n. All are inert source evidence. Six full initializer copies retain only the accepted unchanged New-ArchiveProcess heuristic. Fresh product raw findings retain BOM heuristic/unstarted constructor while lint has none. Independently rehashed prior repair3-static-acceptance.json SHA256 `d5a6d17e4194557d782a1d3d0567898070dfe43453c2fc1c4ebb079081106f80`; its rule-applicability reasoning is reused, not its old-source acceptance. Current diff leaves constructor body unchanged (reported SHA256 `45e7d8912d72b8a71425369f3dfe508490f9fa90b5c2e97fb5dde54f53a0470b`). An unstarted Process constructor changes no external state, and the PowerShell7 UTF8-noBOM requirement is applicable. No blanket suppression, fictional zero-raw-findings claim, or fake profile pass is used.

The four product parameter bindings/comments introduce no new declaration/output/path/encoding/exception/naming/layout contract. Prior exact-input full source/MUST evidence remains scoped to unchanged mechanisms; changed observer/wrapper syntax is covered only by these current inert records. FQ24 is behavioral lifetime correctness that analyzer/parser cannot prove.

## Final handoff

Root may consider the independent Windows stage release while retaining exact unexecuted scope. Keep product/tests frozen until FQ24 S97 is adopted and displayed. Whole FQ23 source/readiness remains blocked on the committed fixture repair and actual runtime validation; no failing native CI is made clean by this source review.

After repair, remaining gates include final affected Linux tests,40 native Windows stage cases and separate whole Windows preference prerequisites, complete maintained aggregate, all11 hooks/exact staged matching, independent local acceptance and normal service/review/CI/landed/paired lifecycle. FQ20 proceeds independently. PR239's original round1/deadline2026-10-16T22:53:27.970214Z and A07 transfer9/12 remain unchanged. No counter, clock, public review or CI rerun was initiated here.

## Root decision and bounded repair release

At 2026-10-08T23:53:11.982526+00:00, root read the complete independent report and verified source role-gate-before-curl ordering (native50b8be), the three generated-copy hashes and absence of restoration, all7score totals and primary Microsoft preference-scope documentation (nativebbb3e2). Options, distinct rubric, full score table and controlled selected steps were displayed before repair. S97 is accepted for mechanical test-only implementation. FQ23 product source is accepted; overall Linux/runtime/public acceptance remains incomplete. The original Windows stage40cases passed separately at native7ffe12/session56592/terminal3faf44 and retain only their exact-source scope. Preserve their old inventory and receipt; emit new generated records separately. No source change, clock/counter reset or public acceptance is implied by this record.

## Current root acceptance 2026-10-09T01:38:31.756839+00:00

S97 implementation was independently reviewed on final JS854ed00a; no new material finding. Root1f4577 accepted exact current source/controller/syntax scope. The actual focused21-case Linux run completed exit0 at native63859/65b97e; root8ef17a verified complete raw and native receipts, all21passes/no skips, unchanged inputs, empty children/scratch and removed owned namespace/container. [Linux acceptance](current-main-validation/fq24-linux-runtime.json). This proves the selected fixture preference restoration and current FQ23 focused Linux behavior; whole aggregate/hooks/publication/paired delivery remain required.
