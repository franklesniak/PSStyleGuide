<!-- markdownlint-disable MD013 -->
# TF68 runtime finding: measured JSON conversion repair proposal

This is a proposal for the existing runtime finding. The completed Q pair supplies attribution, not acceptance or a speedup result. No implementation, compilation, test, additional profile, CI request or product change was performed for this proposal. Root must display and release the selected scope before implementation.

## 1. Validation and exact scope

Current TF head is `ed9eea201cfd70a88a6b982b29904e2f6206a692`, tree `414509ef0a5f6db3cceab5e6b720fbcbcb3cb4ad`, against accepted base `e21b74fe0b56551008f78f9f2946cd2a0f9c19ce`. The validator is SHA256 `9ca8f6ab530f4e1f30a9745d38a4f70d94d48016565e568d15b4a02b4b85b011`; SelfTest is `1fe8a9b289505421cf207be24a880b0b1dfa8edf97405219babb7a3a20d4c3b9`. Preserve both current fixture construction and the checked clock adapter. Earlier source must not replace either file.

Root independently verified the one current-context pair: native exit 0, equal outputs, arguments, working directory, B/H and clock; 80 source files, 1,914 dependency files and complete host/private Git guards equal; both child process groups empty and container absent. The result is `PASS_CURRENT_CONTEXT_ATTRIBUTION_NOT_ACCEPTANCE`. See [verification](../diagnostic/ROOT-RESULT-VERIFICATION.json) and [prior Q decision](../REPORT.md). The case was freshly reconstructed; it does not replay an earlier ephemeral Git identity.

| Measurement | Count | Seconds |
| --- | ---: | ---: |
| Control child | 1 | 12.986890149 |
| Timed child | 1 | 12.849493307 |
| Parse context, enclosing total | 59 | 10.527130704 |
| Fresh native Markdown process | 59 | 2.877864008 |
| JSON decoder preparation | 51 | 0.004112154 |
| Native JsonDocument parse | 51 | 0.020988761 |
| Outer recursive PowerShell conversion | 51 | 5.305516866 |
| Seven schema families, combined | 357 | 1.636770039 |
| Snapshot copying | 33 | 0.500072875 |
| Unmeasured context remainder | â€” | 0.181806001 |
| Outside parse context | â€” | 2.322362603 |

There are 1,322 events, 661 complete nested intervals, 59 fresh parser calls, 51 conversions and eight reuse hits. The conversion consumes about 41.29% of this timed case. Do not add enclosing context time to its nested components. Root-shape checks, disposal and context assembly are not separately measured. No difference between the control and instrumented child is a repair speedup. Instrumentation, warm filesystem state and one-case order limit inference.

The real service cancellation remains a merge blocker. Successful ordinary setup took 1,493/1,617 seconds; even zero overhead would require roughly 19.6%/25.8% reductions to reach 1,200 seconds. This pair does not establish that any repair will supply that margin on the service runner. It does establish a concrete local target: recursive object construction, rather than JSON parsing or new parser-process caching. Provider/setup activation remains the separate conditional path in the retained Q/activation records.

### All generic callers and current contracts

| Caller in current validator | MaximumBytes | Contract that must remain |
| --- | ---: | --- |
| Get-AgentSetupPackageFailure, line 487 | 16,384 | Strict unambiguous package objects; exact scripts/dependency admission; existing bounded diagnostic |
| Get-NodeApplicationContext, line 2697 | 4,096 | Exact path/version strings and fresh candidate failure handling |
| Get-TomlParseContext, line 2898 | 4,096 | Exact typed aâ€“r fields, integer/range checks and existing failure result |
| Get-MarkdownParseContext, line 3645 | 16,777,216 | Fresh runtime/package/native checks; seven later schema/range families; owned reuse and deep copies |

The decoder at lines 232â€“325 checks UTF-8 bytes, parses with depth 64, disallows comments/trailing commas, requires an object root, rejects empty/duplicate property names, preserves strings, uses Int64 when TryGetInt64 succeeds and otherwise finite Double, preserves Boolean/null and object-array cardinality, then disposes JsonDocument. The recursive ordered-dictionary Contains check is case-insensitive. This is verified rather than inferred: PowerShell 7.6.3 Compiler.BuildHashtable constructs ordered dictionaries with OrdinalIgnoreCaseComparer. [Pinned compiler source](https://raw.githubusercontent.com/PowerShell/PowerShell/v7.6.3/src/System.Management.Automation/engine/parser/Compiler.cs).

Object creation has another compatibility edge. Casting the ordered dictionary to PSCustomObject treats a string-valued PSTypeName key specially; a nonstring value remains a property. A naive native PSNoteProperty-only translation is not equivalent. Property order, reserved member names and failure behavior also need differential controls. This is a repair-design constraint, not a newly asserted exploitable product defect. [Pinned conversion source, SetObjectProperties](https://raw.githubusercontent.com/PowerShell/PowerShell/v7.6.3/src/System.Management.Automation/engine/LanguagePrimitives.cs).

Direct ConvertFrom-Json is not an equivalent replacement: its documented duplicate-key and comment behavior differs, and DateKind String was introduced in 7.5. The repository's documented prerequisite is PowerShell 7, not 7.5. Keep that minimum; the currently qualified Windows 7.6.5 and Linux 7.6.3 are test environments, not authority to raise the minimum. [ConvertFrom-Json documentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertfrom-json?view=powershell-7.5); local scripts-README.md line 68.

## 2. Stakeholders and decision limits

Contributors need acceptable local runtime and useful failures on supported PowerShell versions. Security and policy owners need unchanged input admission, fresh failures and all test cases. Reviewers need a small auditable change with differential evidence. CI/recovery operators need cold-process measurements, bounded memory and reliable cleanup. Both repositories need the same common algorithm and preserved language exceptions. Platform owners need an actual successful service run, not extrapolation. None of these needs justifies skipped checks, date changes, broader privileges, failed-CI merge, a new persistent process, or a global result cache.

The target is the measured conversion. Keep parser subprocesses, native exit/status handling, JsonDocument parsing/options/disposal, all seven schema families, document-local snapshot limits, exact input/definition checks and deep copying. Do not change dependencies, runtime policy or the fixture clock. A compile/type identity error must fail closed; it cannot become a successful decoded object.

## 3. Relevant options before scoring

| ID | Concrete option | Scope and tradeoff |
| --- | --- | --- |
| A | Keep code; seek a supported service/setup correction and one policy-compliant retry when released. | Preserves behavior; does not repair measured local conversion cost or guarantee service completion. |
| B | Narrow PowerShell-only converter changes: replace repeated scriptblock dispatch with a typed method or explicit traversal, retain the existing casts. | Avoids a C# helper; object/array pipeline semantics and actual payoff still need proof. A few local loop substitutions may save little. |
| C | Use a compiled native walker only for the Markdown call through an explicit private opt-in; retain the original converter for all generic calls and name-sensitive inputs. | Targets all 51 measured conversions; confines new behavior and preserves unusual PowerShell cast semantics through exact legacy fallback. Adds one process-local compiled implementation. |
| D | Use the same native walker for all four callers, with the same bounded compatibility fallback. | One optimized generic algorithm, but changes package/runtime/TOML admission paths without measured need. |
| E | Native duplicate/name/number prevalidation, then ConvertFrom-Json with explicit options. | Two walks and an alternate parser; prevalidation must restore every strict rule and date/numeric behavior. A 7.5-only switch cannot be assumed available. |
| F | Use ConvertFrom-Json directly, or native deserialization with default options. | Known semantic differences; ineligible without the missing validation, which makes it E or a custom walker. |
| G | Fuse native JSON conversion with all seven Markdown schema families and final context construction. | Can remove intermediate graphs but rewrites a larger security boundary; schema costs are smaller than conversion. |
| H | Check in a precompiled helper or add a new package/module. | Avoids per-process compile time; adds binary/provenance/runtime/dependency maintenance and new coupled inputs. |
| I | Compile/load a helper outside the decoder or preload it in every child. | Moves cost rather than removing cold cost, including children that never need Markdown; adds a coupled bootstrap contract. |
| J | Enlarge/globalize interpretation cache, cache successful parser output, or retain a parser process. | Different freshness/lifetime protocol; not a repair for the measured conversion under the current contract. Ineligible where it skips fresh parser/runtime checks. |
| K | Run two independent immutable author cases concurrently after deriving a safe case graph. | Potential caller-family gain; mutable checkout/ref/clock scenarios cannot share the current fixture concurrently. Larger isolation/scheduling change. |
| L | Optimize schema loops or snapshot copying only. | Preserves decoder; targets about 2.14 seconds instead of 5.31 seconds in this case, with risk to ownership/shape. |
| M | C plus schema fusion, larger runner, concurrency, bootstrap or retry as one immediate change. | Combines uncertain effects and obscures attribution; each extra branch needs its own eligibility/authority and evidence. |
| N | Run another broad profile before a repair. | Repeats resolved attribution; no additional measurement is needed to propose the exact converter scope. |
| O | Remove cases, weaken schemas/duplicates/clock checks, hide cancellation or merge despite it. | Ineligible. |

C and D include two implementation permutations: directly mirror every special PowerShell property behavior in C#, or route the finite name-sensitive cases through the unchanged PowerShell decoder. The latter avoids duplicating subtle cast behavior and is the evaluated version. E may retain the old path on older PowerShell, but this adds parser/version branches without evidence of a better benefit. A/provider clarification can proceed independently under root authority; it is not evidence that C succeeded. H could follow only if measured compilation cost defeats C and its additional supply-chain scope receives a new decision. B remains the smallest fallback if C cannot preserve compatibility.

## 4. Unique weighted rubric

Scores are 0â€“10 judgments for this next repair, not success probabilities. Zero violates the criterion; five means substantial unresolved burden; ten means the proposed scope directly preserves or strongly supports it. A known hard-limit violation makes an option ineligible regardless of total.

| Criterion | Weight | Detailed assessment |
| --- | ---: | --- |
| S: Security and failure fidelity | 30 | Keeps strict JSON/byte/depth/schema bounds, fresh parser/runtime errors, no partial success and original authority/clock; isolates failure paths. |
| B: Behavioral compatibility | 25 | Preserves every output type, order/cardinality, special name behavior, generic callers, supported runtime minimum and document ownership. |
| P: Measured-target payoff | 20 | Removes work from the observed 5.31-second conversion while counting cold startup; no credit for assumed hosted success. |
| U: Operational usability | 10 | Works with installed runtimes, useful bounded failures, no new setup burden, simple process cleanup and understandable fallback. |
| A: Audit and test precision | 10 | Narrow boundaries, discriminating old/new oracles, transparent identity/lifetime, maintainable implementation. |
| C: Delivery cost | 5 | Small scope and review burden; cost cannot outweigh safety or compatibility. |

Total = (30S + 25B + 20P + 10U + 10A + 5C) / 10.

| Option | S | B | P | U | A | C | Total | Eligibility |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 10 | 10 | 1 | 3 | 9 | 9 | 73.5 | Eligible; no runtime repair |
| B | 9 | 9 | 5 | 9 | 8 | 8 | 80.5 | Eligible; payoff uncertain |
| C | 9 | 9 | 9 | 8 | 9 | 8 | 88.5 | Eligible with the controls below |
| D | 9 | 8 | 9 | 8 | 8 | 8 | 85.0 | Eligible; wider unmeasured caller impact |
| E | 8 | 6 | 8 | 5 | 6 | 6 | 69.0 | Only with all compatibility branches |
| F | 1 | 2 | 9 | 8 | 4 | 9 | 42.5 | Ineligible: known contract loss |
| G | 7 | 7 | 10 | 7 | 5 | 4 | 72.5 | Eligible only after broader proof |
| H | 8 | 9 | 9 | 4 | 6 | 3 | 76.0 | New dependency/supply-chain scope |
| I | 9 | 8 | 6 | 6 | 6 | 5 | 73.5 | Cold cost remains |
| J | 3 | 5 | 8 | 4 | 3 | 4 | 46.5 | Ineligible as stated |
| K | 8 | 8 | 7 | 5 | 5 | 3 | 69.5 | Needs new independent-case protocol |
| L | 8 | 8 | 4 | 8 | 7 | 6 | 70.0 | Eligible; smaller measured target |
| M | 6 | 6 | 9 | 4 | 3 | 2 | 59.0 | No combined eligibility established |
| N | 10 | 10 | 1 | 2 | 7 | 2 | 67.0 | Eligible but redundant |
| O | 0 | 1 | 8 | 0 | 0 | 10 | 23.5 | Ineligible |

## 5. Selected proposal: C88.5

Select C for a bounded implementation and proof. It has a clear lead among eligible repairs because it targets the measured work while leaving the three unrelated generic callers on their exact existing path. This is a proposed selection for root display, not an execution release. There is no assertion of a service pass or a guaranteed percentage improvement.

1. Keep the current two source files as the starting point.
2. Add one private opt-in to the existing JSON decoder.
3. Use it only from the Markdown context caller.
4. Convert ordinary object graphs with one compiled walker.
5. Use the existing decoder for name-sensitive graphs.
6. Keep all existing parse, schema, runtime and reuse checks.
7. Prove old and new behavior with focused controls.
8. Measure the same real case in fresh child processes.
9. Stop if behavior differs or cold runtime does not improve.
10. Let root run the required final gates and service sequence.

### Exact implementation design

Proposed product scope is only `.github/workflows/Test-AgentInstructions.ps1` and its existing `.SelfTest.ps1`. Inside ConvertFrom-ParserJsonContext, add an optional private switch such as `UseNativeStructuralConversion`, default false. Only the current Markdown call supplies it. Do not infer opt-in from MaximumBytes: that limit is a bound, not a caller identity. Preserve the current recursive scriptblock verbatim as the default and compatibility path. Keep the current common UTF-8 bound, JsonDocumentOptions, Parse call, root check and finally disposal. Do not add a new schema or rejection limit.

The embedded C# walker accepts the already parsed JsonElement and builds only fresh values. For each object, use an OrdinalIgnoreCase name set, reject empty names/duplicates and add properties in encounter order. Native PSObject has a PSCustomObject base; PSNoteProperty supplies ordinary property values. Use object[] for every array, including zero/one/nested/null elements; no pipeline emission occurs inside recursion. Use GetString, TryGetInt64 followed by finite GetDouble, Boolean and null exactly as the old branches do. Never retain JsonElement outside the live document. [PSObject constructor source](https://raw.githubusercontent.com/PowerShell/PowerShell/v7.6.3/src/System.Management.Automation/engine/MshObject.cs), [PSNoteProperty API](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.psnoteproperty.-ctor?view=powershellsdk-7.4.0), [TryGetInt64](https://learn.microsoft.com/en-us/dotnet/api/system.text.json.jsonelement.trygetint64?view=net-10.0), [GetDouble](https://learn.microsoft.com/en-us/dotnet/api/system.text.json.jsonelement.getdouble?view=net-10.0).

Use a finite internal result discriminator: complete graph, legacy-name fallback, or one of the existing explicit decoder failures. Map explicit failures back to the exact existing PowerShell throw messages. Unexpected native/compiler errors remain errors through the existing caller wrapper; never convert them to legacy success. A legacy-name result contains no partial graph. On that result, decode the entire still-live root with the unchanged scriptblock. This preserves error order and zero partial output. Route any occurrence, at any nesting level, of PSTypeName or the reserved PSObject/PSBase/PSAdapted/PSExtended/PSTypeNames names through this compatibility path, irrespective of value type. This is routing, not a new rejection: the original decoder decides the exact result. Check names before native property insertion; if a later nested occurrence is found, discard the private partial graph and restart the original walk. Do not implement a broad catch-and-fallback.

Compile one immutable, stateless helper implementation lazily at the first opted-in call. Keep its source literal and all initialization within the existing decoder definition; do not add a second overrideable PowerShell helper or mutable script-level source string. Use a unique reviewed implementation identifier/type name tied to the exact C# payload, and verify its expected public conversion signature and identifier before reuse. A conflicting loaded implementation must fail closed rather than silently use Add-Type's existing-name result. This prevents accidental stale versions; it is not authentication against arbitrary code already running in the process. The ordinary process loads one implementation, retains code/type metadata until process exit, and retains no JSON strings, graphs, verdicts or runtime results in static fields. No per-document or per-call type generation and no global result cache are permitted.

Use only installed PowerShell/.NET assemblies and APIs available to the existing PowerShell 7 runtime floor; no DateKind switch, new JsonDocument options or package installation. Add-Type must compile in memory without an output assembly. If explicit references are required, retain the installed runtime's default reference closure and bind additional references to its actual System.Text.Json/System.Management.Automation assemblies; do not search the working directory. Compilation failure is bounded by the existing child limit and fails validation. Compilation warnings/errors must not become successful parser output. A measured cold compile is part of total validation time. [Add-Type runtime and lifetime documentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/add-type?view=powershell-7.5).

The new helper does not cache input. Existing document-local reuse still executes the fresh parser before a hit and compares the existing ConvertFrom-ParserJsonContext definition reference. The embedded helper belongs to that definition, so replacing the function invalidates snapshots as before. Do not change the eight-snapshot budget, owned/borrowed slots, cleanup, copy definitions or seven output arrays. Direct default decoder calls remain fresh. A name-sensitive fallback is slower by design but cannot accept anything the baseline refuses. Do not promise compatibility with arbitrary hostile type-data/code injection; test the real supported process and existing override seams.

Apply only required touched-function/script metadata against accepted B, not cumulative WIP increments. Preserve genuine current edit date and existing parsed date-mutant construction. No README, package, guide, workflow, classifier, native parser program or policy edit is implied. If compilation requires a new runtime floor, external dependency, broader helper protocol or schema change, stop and return that concrete finding before expanding scope.

## 6. Meaningful verification after release

No item below has run for this proposal.

| Layer | Required discriminator and result |
| --- | --- |
| Strict decoder differential | Run baseline, changed default and changed opt-in over the same deterministic corpus. Compare output types recursively, property order/names, Int64/Double values (including signed zero/limits/exponents), exact strings, TypeNames, array cardinality/nesting/nulls, rejection and no partial output. Include Unicode and escaped duplicate names, empty names, duplicate-case names at every nesting kind, root scalars/arrays, byte bounds, exact depth boundary/overflow, comments, trailing commas, NaN/infinite/huge numbers and timestamp precision/offsets. Do not use JSON roundtrip as the sole equality oracle. |
| Cast compatibility | Include string/nonstring/null/nested PSTypeName and case variants, all reserved names, ordinary names such as Count/Length, property ordering and late invalid values after earlier valid fields. Prove these inputs use the unchanged full-root fallback and that opt-in has the same result/error. A native-always-PSNoteProperty mutant must fail this control. |
| All caller integration | Exercise actual setup-package refusal/success, Node identity types and failure path, TOML typed context, and Markdown schema families. Confirm the first three do not initialize the native helper. Keep the actual package/runtime checks in the cold case. |
| Native-path proof | Show ordinary Markdown payloads use native conversion, with one type initialization per fresh process, no original recursive walk on the normal path and no static graph retention. A forced-old-path mutant must be distinguished even if outputs match. Test repeated calls and a conflicting type/implementation in a disposable process; compilation/identity failure must not fall back or emit success. |
| Security/freshness | Retain malformed parser schema/range controls, changed/failed native parser output and runtime failure between consumers; preserve decoder-definition override, hostile returned-object mutation, borrowed/local slot cleanup and eight-snapshot budget tests. No fresh process count reduction is expected. |
| Source quality | Full-file parser and PSScriptAnalyzer 1.24 on the two actual changed files; current mutation-constructor controls must still find and change two actual arguments. Run focused contracts on qualified Windows 7.6.5 and Linux 7.6.3. Review use of only PowerShell 7-era APIs; do not label the entire 7.x range empirically tested. |
| Cold actual caller comparison | Prepare a reviewed original/changed pair from current source, one fresh actual fixture, same B/H/clock/argv/cwd/oracles, separate new child processes and equal non-marker outputs/native exits. Include compilation, generic runtime bootstrap and all native processes in wall time. Expect 59 fresh native calls and 51 opted-in conversions/eight reuse hits for the same case; explain any true input difference. Count structural conversion separately from runtime JSON. Root must release the concrete runner before execution. |
| Final gates and hosted proof | Only after focused equivalence and positive cold-case evidence, root decides the one mandatory complete all-files validation and affected classifier/local-validation checks. Preserve every actual author mutation/control. Root handles both reviews and current-head CI, including actual service setup; no merge while any required CI is failed/cancelled, no retry faster than hourly. |

Use bounded private mutants for missing duplicate/empty-name rejection, date coercion, array collapse, non-finite acceptance, unconditional helper fallback and stale implementation identity. They must be killed by the relevant focused assertions. Do not build a large new production testing framework or repeat unrelated Node/generator/semantic suites solely for this converter. Reuse unaffected exact-source evidence and rebind changed checks honestly.

A positive one-case result justifies the final gates; it does not establish service margin. Record compile duration, first-call and whole-child duration, native and conversion counts, zero failures/skips and source/dependency/Git guards. If cold total is not lower, if name fallback dominates actual normal payloads, or if compatibility is not exact, stop rather than broadening the cache or omitting checks. Root can then select the already described PowerShell-only or caller-isolation alternative on actual evidence.

## 7. Authority, paired scope and next action

No new human permission is needed to prepare this proposal. Root must review/display the ordered decision and issue the concrete implementation release. Nothing here authorizes Git/native operations or another experiment. Root retains original round 6, deadline 2026-10-13T23:47:31Z and transfers A06/A03/A21/A07 = 1/3/5/5 of 12. No count is changed here.

This is common instruction-validator work. Any eventual accepted TF repair belongs in the existing conditional PS carryback, preserving the exact T1/P1 fixture-provenance exception and rebinding actual landed TF/current accepted PS inputs. Root determines applicable accounting before the destination edit. Prospective or locally tested bytes are not accepted main. Current cancelled service CI still blocks merge.

**Next action:** root reviews this C88.5 proposal and its evidence. If selected, release only the two-file implementation and bounded equivalence controls first. Review the actual cold-comparison packet before launching it. There is no further diagnostic needed before making that implementation decision.
