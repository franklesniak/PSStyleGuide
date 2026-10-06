<!-- markdownlint-disable MD013 -->
# PS235 recovery R2: converter metadata caching

Status: READ-ONLY PROPOSAL. Recommend A92.7: retain current per-call implementation verification. This is a merits disposition, not a claim that caching cannot work or has negligible benefit. Root must display/select before a corresponding edit.

## 1. Validate

Review5435249947/comment4201048162 targets H504cd7672ac9604ace765a4f451346f801f09ddd over B98177628b7bc02c646724bfc8aa0fd73fed0cd24. The saved overview reports Lite and an agentic-start timeout. Those facts do not invalidate the source comment or attribute service failure to the converter. No native state was queried.

The observation is correct. ConvertFrom-ParserJsonContext232â€“466 hashes its embedded template413â€“421, resolves the digest-named Type423â€“426, and obtains/verifies members436â€“450 on each Markdown opt-in call before invocation452. Compilation is already lazy and ordinarily once per implementation/process. Generic calls skip this path; special names preserve full-root legacy fallback. Metadata work repeats, but neither the comment nor the saved results isolates its cost or shows an adverse user outcome. The proposal is a possible optimization, not a reproduced decoder failure.

Selected C88.5 deliberately keeps source and initialization inside this decoder, without a mutable script-level source string or a second overrideable initializer. Its type identity is tied to the exact payload. Markdown snapshots compare decoder ScriptBlock references3771; fresh conversion remains at3781. SelfTest233â€“385 replaces definitions and tests refusal. Caching Type/MethodInfo metadata differs from caching graphs/verdicts and can be sound: normal CLR metadata is stable. A mutable PowerShell cache still needs exact definition/source ownership, completed-only publication, failed-initialization invalidation and repeated-load semantics. Stable Type metadata alone does not prove that an old tuple belongs to the decoder now called. Neither current nor proposed checks authenticate against arbitrary hostile code already executing in the process.

Current validator SHA e2a7767f70ffc3d38e9225d7ed6a723d9329135e3b104b3cec9654122ae7d35c equals C88's focused candidate. Root's verification covers frozen legacy/default/native differential behavior, repeated same-Type reuse, seven mutants, generic separation, compilation failure and same-name wrong-identity Type refusal on qualified Windows/Linux. Those checks apply to current boundaries; they do not qualify a new cache. Existing initialization controls require zero successful output on failed compilation and leave the default generic path independent.

Actual caller scope matters. Normal workflows/package commands invoke the validator as a script; fixtures use fresh native children for complete CLI checks. The validator invokes the extracted SelfTest child script with shared RuntimeContext at9683â€“9688; that script uses functions already loaded by the parent. Its reuse controls save, replace and restore the decoder function in the same process. The qualified private load-functions.ps1 installs extracted function definitions with Set-Item, after only selected initial statements; it does not execute an arbitrary new script-level initializer beside each definition. No current Import-Module contract for this decoder was found in these inspected callers. Repeated script loads and future import callers remain design hazards, not observed production failures. A reset-at-script-load cache can work for full script entry, but function-only installation or replacement needs its own reset/key rule. A reset at every function installation is feasible if all supported loaders participate; it changes their contract. Definition-keyed lazy initialization can avoid depending on every external loader, with completed-only publication and explicit failure tests. Neither variant is ruled out merely by lack of a benchmark.

Completed cold evidence measured one whole author case: original11.407920466s versus candidate8.074512943s, compilation0.3080119s, first conversion0.3428981s,51 conversions/59 fresh parsers/eight reuse hits and equal outputs. The packet FAILED cleanup and remains failed; separately verified partial timing/functional evidence does not turn it green. It is one ordered pair, not a stable benchmark, and contains no digest/reflection phase measurement. The earlier5.3055s measurement concerned the whole legacy recursive conversion, not metadata cost. Current PS LOCAL-VALIDATION records600 Node assertions and an eleven-hook aggregate with explicit evidence reuse, without isolating this overhead or proving hosted service selection.

[Add-Type documentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/add-type?view=powershell-7.5) confirms in-memory compilation and PowerShell7's existing-type-name compilation behavior. This supports exact implementation checks, not a speed claim or empirical qualification of all PowerShell7 versions.

## 2. Stakeholders and constraints

Both maintainers and new/experienced contributors need predictable validation without new setup. Documentation/generator consumers need exact JSON values/types/order and failure behavior. Windows/Linux PowerShell and CI/recovery operators need lazy initialization, bounded children and useful native failures. Security/supply-chain and privacy owners need no stale implementation acceptance or retained input graphs. QA/independent reviewers need discriminating reload/type/failure tests and honest timing. Cost/schedule owners benefit from lower runtime only when evidence supports the added state/review burden. No cloud permissions or accessibility UI change is proposed; Unicode behavior remains in existing controls.

Hard constraints: retain strict byte/depth/parser/schema/cast fidelity, generic isolation, fresh parser/runtime errors, deep copying and definition overrides. Do not raise the PowerShell7 floor, add dependencies, move cold cost outside reported totals, accept incomplete initialization, mask type/native failures or use a name-only cache. A source/initializer ownership change must revise C88's affected boundary and paired obligations before implementation. Scores cannot waive these conditions.

## 3. Options before scoring

A retains current verification. B caches only digest/name at script scope. C caches the verified identity/Type/FieldInfo/Result Type/MethodInfo tuple with per-definition/source binding, script-reload reset and completed-only state. D uses lazy metadata inside a new per-definition closure. E hardcodes the digest with separate source-consistency qualification. F changes invocation to a typed/delegate path but retains identity checks. G factors a private cached initializer. H initializes eagerly. I ships a compiled/package helper. J measures the baseline phase before edits. K caches graphs/verdicts or retains a parser. L removes identity checks. M resets verified cache state when a decoder definition is installed and when the full script loads, with explicit loader participation and fail-closed initialization.

B+C is C. C+F needs both lifetime and invocation proofs. C+D is D's lifetime mechanism. E+C adds both literal-digest drift and reload obligations. A+J is A now plus a separately released diagnostic. G without caching is factoring with no eliminated metadata work. H/I change bootstrap/supply contracts. K/L fail hard constraints. No-change is not a deferred implementation promise or new issue obligation.

## 4. Unique rubric

Ratings0â€“10 are judgments, not measurements:0 violates the criterion;5 has material unresolved burden;10 directly preserves/supports this consumer. Total=sum(weight*rating)/10.

| Criterion | Weight | Specific meaning |
| --- | ---: | --- |
| B: Decoder fidelity | 33 | Exact results/errors/types, default separation, runtime floor and definition replacement. |
| I: Identity and recovery | 27 | Exact payload binding, wrong-Type refusal, no incomplete/stale cache, reload/failure recovery and no graphs. |
| U: Usability | 19 | Lazy setup, no new contributor steps, useful failures and clear bounded lifecycle. |
| P: Performance evidence | 11 | Targets demonstrated work; includes cold cost; no assumed hosted benefit. |
| M: Audit/maintenance | 7 | Verifiable lifetime, independent controls and paired scope. |
| C: Delivery cost | 3 | Churn/qualification effort after fidelity, safety and usability. |

## 5. Scores before selection

| Option | B33 | I27 | U19 | P11 | M7 | C3 | Total | Basis / limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A Current verification | 10 | 10 | 10 | 4 | 9 | 10 | 92.7 | Qualified behavior; isolated metadata cost unknown. |
| B Digest/name cache | 9 | 7 | 9 | 5 | 8 | 8 | 79.2 | Reload/source binding remains necessary; reflection remains. |
| C Verified tuple cache | 9 | 8 | 8 | 6 | 7 | 6 | 79.8 | Feasible with new mutable lifetime contract; payoff unmeasured. |
| D Per-definition closure | 9 | 9 | 8 | 6 | 7 | 5 | 82.2 | Better ownership but new load/override semantics. |
| E Literal digest | 9 | 9 | 9 | 5 | 6 | 7 | 82.9 | Adds maintained source/digest consistency invariant. |
| F Typed/delegate invocation | 9 | 9 | 8 | 5 | 7 | 6 | 81.4 | Signature/runtime proof required; hashing remains. |
| G Cached initializer | 8 | 8 | 8 | 6 | 6 | 5 | 75.5 | New replaceable helper and freshness seam. |
| H Eager initialization | 8 | 9 | 6 | 4 | 6 | 6 | 72.5 | Generic callers acquire setup/failure timing; cold cost remains. |
| I Compiled/package helper | 8 | 8 | 5 | 7 | 5 | 3 | 69.6 | New provenance/runtime obligations. |
| J Baseline phase diagnostic | 10 | 10 | 8 | 5 | 8 | 4 | 87.5 | Quantifies opportunity; another private execution with no present failure. |
| K Cache graphs/parser | 2 | 2 | 4 | 9 | 3 | 5 | 33.1 | Ineligible freshness/ownership change. |
| L Remove identity checks | 1 | 1 | 8 | 7 | 5 | 9 | 35.1 | Ineligible wrong-Type/stale implementation acceptance. |
| M Definition-install/reload reset | 9 | 9 | 9 | 6 | 8 | 6 | 85.1 | Feasible; all actual function-only loaders/override paths must participate or use a definition key. |

A leads because fidelity and operation are demonstrated while benefit is not isolated. C/D are possible sound projects, not inherently insecure. Their scores reflect unqualified lifecycle semantics and uncertain gain. J is safe but adds execution to size an unproven opportunity. No assertion that overhead is negligible supports this choice.

## 6. Proposed controlled-English choice

Select A92.7. Instructions use short direct sentences and consistent terms; formal ASD-STE100 dictionary certification is not claimed.

1. Keep the current converter code.
2. Keep implementation verification on each opted-in conversion.
3. Keep lazy compilation and generic-call separation.
4. Record that metadata overhead has not been measured separately.
5. Do not treat the service-start warning as converter timing.
6. Reuse evidence only for its recorded scope.
7. Preserve failed packets and their limits.
8. Let root record the review and CI disposition.

No new source test or repair is required for A. Current reviews/CI, independent final quality, actual endpoints/audit and paired/service acceptance remain required. This decision grants no cache implementation or merge waiver.

If root requires quantified optimization, J is the precise next diagnostic proposal, not an execution release. Use one new private child on qualified Windows7.6.5, sourceH504 and frozen qualified dependencies; no installs/network/Git writes. Extract the exact decoder into a bounded private driver and prove removal of instrumentation recovers its committed extent. Measure one cold opted-in canonical object and127 subsequent identical calls. Timestamp only digest/resolution/member-verification and whole conversion; report instrumentation overhead and first compilation honestly. Preserve document disposal, exact output types/arrays, direct exit, zero partial output, generic isolation and owned cleanup. Limits:60s child,90s parent,1MiB output; guard source/index/dependencies. No cache candidate, fullSelfTest, cold author-pair replay or hosted attribution. Root must review/release the actual driver first. This diagnostic can bound an opportunity, not guarantee a speedup. Any later cache needs meaningful completed/failed/corrupt initialization, repeated load, changed definition/template, wrong type, mixed sources, generic isolation and special-name controls; old evidence cannot qualify new state semantics by hash reuse.

## 7. Limits and accounting

Evidence binds exact committed blobs/modes, prior scope, comments and checked scores. This worker performed read-only source/Git inspection and host hashing/packaging only. No candidate/parser/import/test/probe/native request, source/index/ref/planning/state/counter change or descendant occurred. B99 remains frozen. Round1/deadline2026-10-14T20:09:39.767792Z and transfers2/4/6/6of12 are unchanged. Root owns the current service outcome and acceptance; a separate worker owns recovery-cap disposition.
