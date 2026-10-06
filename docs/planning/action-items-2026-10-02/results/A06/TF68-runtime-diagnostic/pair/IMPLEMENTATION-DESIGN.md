# Concrete C refinement: document-owned structural interpretation reuse

Status: scratch design only; no product implementation or test execution. This refines the selected C91.15 in the existing runtime finding. The frozen diagnostic report, evidence and source files remain unchanged.

## The exact refinement

Run the real bounded native Markdown parser on **every call**, including a possible reuse hit. Perform the existing package-presence and Node-resolution checks first. Preserve its exit, stderr, timeout, output bound and exception handling. Reuse only a previously validated structural interpretation when the normalized parser text, LineCount and newly returned raw parser JSON all match with ordinal equality. This avoids runtime/dependency identity machinery and retains failure freshness.

The metric changes from the earlier proposed parser-call reduction to **unchanged parser-process count and fewer JSON decoding/schema/materialization repetitions**. The measured target is the approximately 7.547 seconds outside the native parser interval, not all 10.396 seconds. Copy/ownership costs and the actual number of matches are still unmeasured.

No global dictionary, content cache, serialized-object framework, persisted result or policy verdict is introduced. The caller passes one explicit current-document slot and a separate prior-document slot through its existing flow.

## Representation and alias isolation

An invocation creates one private budget object with a retained-snapshot count. Each current/prior document owns a distinct small slot object with two fields: Budget and Snapshot. These objects are internal parameters, not command-line parameters or untrusted document data. The slot is never part of a helper's returned metadata/parser context.

A non-null Snapshot contains:

| Field | Exact value |
| --- | --- |
| ParserText | The immutable string actually passed to Get-MarkdownParseContext |
| LineCount | That call's validated integer line count |
| ParserOutput | The immutable string returned by the fresh successful bounded parser process |
| ParserDefinition | Current Get-MarkdownParseContext ScriptBlock reference |
| DecoderDefinition | Current ConvertFrom-ParserJsonContext ScriptBlock reference |
| CopyDefinition | Current private structural-copy helper ScriptBlock reference |
| Context | A private deep copy of the fully validated seven-array structural result |
| PayloadCharacters / Records / Elements | Deterministic retention accounting described below |

Use reference identity for the three immutable function definitions. A changed or reloaded definition causes a miss and clears the snapshot. Do not use timestamps, file hashes or names alone as a substitute. Capturing these references adds no capability to untrusted Markdown. It detects supported test overrides; it is not a security claim against arbitrary PowerShell code injection into the same trusted process.

Only one small, schema-specific copy helper is needed. It copies the existing result shape explicitly:

| Array | Record fields and nested values |
| --- | --- |
| CodeBlockRanges | Start, End |
| ProseBlocks | Start, End, Text; new Code and Links string arrays |
| TableRows | Start, End; new Cells array; each cell Tag, Start, End, Text and new Code/Links string arrays |
| TopLevelBlocks | Type, Tag, Start, End, nullable Text |
| TopLevelListItems | Start, End, nullable Text; new Code/Links string arrays |
| Headings | Tag, Start, End, Text |
| LevelTwoHeadings | Start, End, Text |

All seven arrays and nested record/array objects are new. Preserve the existing PSCustomObject-array and string-array shapes, int coordinate types, null Text, and empty/single/multiple arrays. Immutable strings may be shared. Do not use PSObject.Copy, JSON, CLIXML, shallow cloning or a generic graph copier.

On a miss, the existing full decoder and schema checks run unchanged. Build the private snapshot copy only after their success, before returning the original result object. On a hit, return a new deep copy of the private snapshot. Consequently, mutating a returned context, nested cell, Code/Links array or the MarkdownParseContext attached to a returned metadata object cannot mutate the retained interpretation. No returned object is ever installed back as a snapshot.

Malformed, foreign or incomplete private slot state disables reuse and follows the fresh path; it is never a source of trusted structural data. The production caller constructs slots and never obtains them from an external input. Do not claim to authenticate deliberately forged trusted-code objects; arbitrary same-process code could already replace every validator function.

## Exact identity and fresh failure behavior

Get-MarkdownParseContext receives ParserText only after the caller's original preprocessing. Compare that string using StringComparison.Ordinal and compare LineCount as an integer. Compare the fresh ParserOutput using StringComparison.Ordinal. A mismatch clears the old snapshot and executes the existing full interpretation path. Do not normalize raw parser JSON or use a hash-only key.

The intent and metadata readers both split CRLF/CR/LF, clone lines, blank a closed exact leading front-matter span, and join with LF. Their unclosed-front-matter behavior differs and stays in the original reader before reuse can occur. The snapshot contains only the structural parser result. Each reader still uses its own original line array and policy logic. RequiresVersion does not alter the parser input, but it still affects strict metadata interpretation and is not a cached verdict.

Fresh package/runtime checks and the real parser call precede every hit. Missing Node/package, changed parser code, a nonzero process exit, stderr, timeout, oversized output or new malformed JSON cannot be masked. If the parser changes yet emits exactly the same valid JSON for exactly the same parser input, the structural meaning is identical. If it emits different JSON, full validation runs. Decoder/schema function replacement invalidates reuse even when raw output is unchanged. The copy helper also runs fresh; replacing it invalidates the old snapshot.

Existing overrides of Read-BoundedProcessData and parser/runtime helpers are still executed in their original call path. No opt-in slot is passed into the unrelated direct parser/JSON self-tests. A direct call without a slot always performs full fresh interpretation. A definition override between the two consumers must be tested explicitly and must force the fresh path. The actual source census found no existing Where-Object/cmdlet replacement that needs a new override protocol; do not broaden this into arbitrary ambient-code authentication.

On any parser or conversion failure, release the affected snapshot and rethrow the original substantive failure. Cleanup is idempotent and must not replace that failure. No successful policy result or exception is retained.

## Bounded retention and accounting

Use these fixed retention limits:

- At most **8 retained snapshots** across the normal main validation invocation.
- Each snapshot retains at most **524,288 UTF-16 code units (1 MiB)** of charged string payload, **2,048 structural records**, and **8,192 array elements**.
- Charge ParserText, ParserOutput and every string occurrence in the copied structural result, including field strings and Code/Links elements. Charge duplicates again; sharing does not reduce the conservative accounting. Count every top-level record and nested table cell. Count each element in all seven arrays, Cells and Code/Links arrays, including repeated strings. Use checked Int64 sums.

Thus the additional retained population is bounded by 8 MiB charged string payload, 16,384 fixed-shape records and 65,536 array elements, plus eight small snapshot/slot records. This is deterministic payload/object-count accounting, **not a claim of an exact 8 MiB CLR working-set cap**. Existing transient input/parser/result objects remain governed by their existing bounds. A copy can be temporarily live during return; it is bounded by the same per-snapshot counts. There is no unbounded graph or recursive object type.

Preflight the counts on the already validated context before allocating a retained copy. If any limit is exceeded, or eight snapshots are already retained, return the normal freshly validated result and retain nothing. Do not reject content, truncate arrays or skip a check. A later eligible document may retain a snapshot after a previous owner releases one. Do not evict another live document, maintain an LRU queue, or add a new admission limit.

For a direct endpoint call that has no main owner, at most two local slots may be used only inside that one endpoint invocation (current and prior); their combined population is within the same eight-snapshot limits and they are released in its finally. A direct Get-MarkdownParseContext, Get-DocumentMetadataContext or intent call without an explicit slot remains uncached. Do not allocate fresh global state from a helper.

Create a local endpoint owner only when neither slot was supplied. If a caller supplies a slot whose snapshot is empty because the shared budget is full, do not create another owner to evade the bound. Nested endpoint calls borrow the passed slots; they release only slots they created themselves. The outer owner releases borrowed slots at the documented final consumer. Clearing an invalid snapshot on failure remains idempotent.

The two-pass main loop may fill all eight slots with early documents. Large documents may exceed the 1 MiB charge and remain on the fresh path. This is intentional conservative behavior. Record actual retained, hit and fallback counts in the bounded case; do not expand the limits automatically to improve a benchmark.

## Actual data flow and discard points

| Source/caller | Proposed explicit slot flow | Ownership / discard |
| --- | --- | --- |
| Main document construction at 8072–8145 | Create distinct current/prior slots for this document; pass current to intent at 8116 and prior to intent at 8121 | Never share slots between paths or current/prior, even for equal content |
| No current metadata intent | Current intent may have parsed, but no strict endpoint follows | Clear both slots before storing a no-metadata record |
| Initial metadata coverage discards parent | Existing logic sets MetadataParentContent to null | Clear prior slot at the same point; never pass it as a parent context later |
| Local document record | Store the two slots alongside its existing fields, only for the later endpoint call | The snapshot is not in Content or any public returned metadata object |
| Decision lifecycle/link checks | Continue receiving only their existing Name/Content/Baseline strings; operative Markdown remains independent | No slots passed and no operative reuse |
| Get-NestedClaudeImportFailure at 8230 | Pass a projection containing only Path and Content, the only two properties read by its actual implementation | No snapshot alias exposed through the document record passed to this unrelated helper |
| Required-Version endpoint at 8245 | Pass the matching current/prior slots to Get-PublishedEndpointMetadataFailure and onward to strict metadata extraction | Separate current/prior; all policy logic remains fresh |
| LastUpdated endpoint at 8255 | Pass matching current/prior slots to Get-PublishedEndpointLastUpdatedFailure and onward to its metadata extractions at 4408/4430 | Preserve original MetadataParentContent selection |
| LastUpdated version removal at 4463 | Its already parsed prior document becomes the nested version check's current input | Pass the same prior-owned slot as that nested call's current slot; null parent remains null |
| LastUpdated present Version at 4473 | Recheck current and any actually versioned prior document under required-Version policy | Reuse only the corresponding current/prior structural slots; RequiresVersion checks still execute |
| Completion, skip or failure of a document endpoint | No further normal metadata consumer needs its slots | Release both in finally |
| Exception before endpoint loop / after construction | A document record may still own a snapshot | A main-owner try/finally releases every retained slot before control leaves the validation region |
| Following SelfTest phase | Existing document records are used by Path/Content/metadata policy tests | All slots are cleared before this phase; no cross-case snapshot is retained |

The direct nested LastUpdated→Version path is a real repeated-input opportunity: the same CurrentContent/BaseContent arguments are passed again, and RequiresVersion changes policy rather than parser preprocessing. The intent→endpoint path is real but not every prior/current value survives coverage selection. The implementation must count actual hits; no assumed 17-hit claim is permitted.

## Precise prospective edits

Only `.github/workflows/Test-AgentInstructions.ps1` and focused regressions in `.github/workflows/Test-AgentInstructions.SelfTest.ps1` are proposed. No workflow, clock mechanism, dependency, guide, generator or peer file changes.

1. Add a small private slot-release helper and a schema-specific structural-copy/accounting helper. Slot construction can be a short private factory if repeated construction would otherwise obscure the exact budget fields; no generic cache manager.
2. Add an optional internal slot parameter to Get-MarkdownParseContext. Keep package/runtime/process code before the hit check. Keep the existing decoder/schema body as the miss path. Capture the successful context in a local variable instead of immediately returning it; optionally retain an isolated copy, then return the existing result.
3. Add optional internal slots to Test-DocumentMetadataHeaderIntent and Get-DocumentMetadataContext and forward them only to their existing parser call. Keep original line preprocessing, early returns and metadata logic.
4. Add explicit current/prior slots to the two endpoint helpers. Forward matching slots to metadata calls and the two existing LastUpdated→Version delegations. When called directly, create/release local slots only for that invocation; preserve direct parser/metadata helper behavior.
5. Add main-local owner construction, per-document slots, the Path/Content projection for the nested-Claude helper and idempotent finally release. Preserve failure collection order and every safe input read. The PowerShell try/finally adds no child scope; existing variables needed by the following SelfTest remain available, with reuse slots cleared.
6. Update only required script/touched-function NOTES versions to the genuine edit date. Read applicable style instructions before actual edits. Root owns staging, final gates, counters and subsequent paired implementation.

## Focused discriminator tests for implementation release

| Control | Required evidence |
| --- | --- |
| Same slot/input/output | Two real bounded parser calls, two availability paths, one full structural interpretation; exact output shapes and values match uncached calls |
| Native/parser freshness | After a first success, missing package/runtime, nonzero/stderr/timeout/oversized result on the second call still fails; process is not skipped |
| Changed raw JSON | Fresh malformed/duplicate-property/invalid-type/range output must fail full validation rather than reuse the previous context |
| Definition override | Replace decoder/schema/copy definition between calls; prove the old snapshot cannot bypass that override; restore in finally |
| Exact identity | Changed normalized text or LineCount forces full interpretation; CRLF/LF/CR and blanked front matter use actual normalized text and original line count, not raw-content assumptions |
| Hostile returned mutation | Mutate every record family, nullable Text, Cells and Code/Links arrays on both a miss result and a hit result; the next result remains equal to a fresh control |
| Separate ownership | Equal content in another document or prior slot does not hit; cleared, discarded-parent, new invocation and SelfTest cases do not inherit state |
| Eight-slot boundary | Fill eight eligible owners; the ninth still returns the correct freshly validated result without retention; release one and allow a later eligible owner |
| Per-snapshot limits | Exercise exact boundary and over-bound payload/record/element cases using valid parser contexts; over-bound means fresh success, not refusal or partial output |
| Real endpoint delegation | Optional/present/removed/new Version and initial metadata coverage preserve exact diagnostics and dates while reducing only repeated structural interpretations |
| Complete schema regression | Existing malformed JSON, duplicate/case-ambiguous properties, range/overlap/type, empty/one/multiple, table/nesting and timestamp controls remain effective |
| Actual caller measurement | Same bounded original/changed immutable author case, real clock helper and native exits; parser count unchanged, conversion count reduced, guards and output equal; report copying cost and total time |

Use private wrappers/counters around actual invoked helpers to distinguish process and structural interpretation counts. Persistent tests should check observable correctness and actual call behavior, not literal slot names or budget implementation spelling. Include small meaningful mutants that skip the fresh parser, accept changed LineCount/raw output, share returned arrays, retain discarded parents, ignore the budget, or reuse after decoder replacement. Preserve every failed attempt.

Parser/analyzer checks and affected metadata/placement/classification tests remain required on the actual changed bytes. Root coordinates any mandatory final all-files gate and hosted acceptance. No unchanged full author/capacity matrix or duplicate aggregate is implied by this design preparation.

## Score impact and feasibility stop

This is C with stronger freshness, not a new finding. All other previously displayed options and scores remain applicable. Reduce C's measured-target score from 8.5 to 8 because the native subprocess remains, and implementation-cost score from 7 to 6 for the explicit copier/budget plumbing. Other criteria stay unchanged: 9.5/9.5/8/9/9/6 at weights 30/25/20/15/7/3 gives **89.85**, still above B's further-measurement 84.9. Root should display this refinement before implementation release.

The design is worthwhile only if actual structural-copy cost and the bounded retained population produce a measurable improvement while all output/freshness controls pass. No service-limit margin is promised. If exact shape-preserving copying or required ownership becomes substantially larger than these two files, or actual reuse is too small, stop and return the evidence to root. Do not silently replace this design with a global cache, decoder rewrite, dropped checks or broader retention. No extra profiling run is authorized by this document.
