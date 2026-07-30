# Add a fail-closed cross-platform style-guide candidate validator

## Summary

Add one shared PowerShell archive validator/extractor, one caller-owned
temporary-context lifecycle, one versioned semantic case catalog, and one
permanent adversarial harness. Require equivalent behavior under Windows
PowerShell 5.1 and PowerShell 7 on Windows and Ubuntu.

Treat public values, filesystem claims, ZIP entries, resource declarations,
and cleanup claims as untrusted. Hash and parse one continuously held archive
stream, validate the complete manifest and resource ceilings before candidate
creation, extract only fresh ordinary files, and retain uncertain state rather
than recursively deleting it.

P1A is workflow-inert. P1B consumes these landed interfaces.

## Consumed landed contract

P1 must already be merged and its real GitHub dependency edge to this issue
verified. Before coding, record:

| Identity | Required P1 evidence |
| --- | --- |
| Issue/PR | Permanent URLs |
| Review | Reviewed head/base commits and merge method |
| Landed state | Commit(s), tree, and exact ten-path P1 scope |
| Generator | Version, SHA-256, fixed map, replacement result schema |
| Workflow policy | Validator/parser/contract/case schema versions and hashes |
| Path verifier | Script version/hash and cross-host fixture results |
| Supply/risk | P1 tuple, action/default evidence, current advisory decision |
| Reciprocal | Completed P1↔T1 matrix |

Compare landed state with every assumption below. A missing edge, expired or
contradicted advisory decision, identity mismatch, material contract drift, or
unresolved reciprocal blocker stops implementation and requires issue review.
Rerun affected P1 validation rather than treating a reviewed PR head as the
landed implementation.

## Affected files

Exactly these four paths may change:

- `.github/workflows/Expand-StyleGuideCandidateArtifact.ps1` — add;
- `.github/workflows/Manage-StyleGuideCandidateInvocationContext.ps1` — add;
- `.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1` — add; and
- `.github/workflows/style-guide-candidate-cases.json` — add.

All three scripts declare `#Requires -Version 5.1`, remain LF/BOM-less, and
receive independently governed first-publication `.NOTES` versions:

`1.0.<implementation UTC YYYYMMDD>.0`

The baseline paths are unversioned, not earlier releases. If a path appears or
changes before finalization, apply the PSStyleGuide same-day revision rule to
that script only. Record all three versions and hashes.

Do not change workflows, generator, guides/artifacts, package/lock, hook/lint,
Dependabot, or P1 policy files.

## Public raw-value boundary

Every public parameter is declared as raw `[object]` under
`[CmdletBinding(PositionalBinding = $false)]`; no public command accepts
pipeline or remaining-argument binding. Before any conversion, provider call,
path access, diagnostic interpolation, or collection unrolling, require
`$Value.GetType() -eq [System.String]`. Reject null, arrays (including
single-element arrays), collections, hashtables, PSCustomObjects, PathInfo,
FileInfo/DirectoryInfo, script blocks, wrapped/deserialized objects, and every
other runtime type as `parameter`.

Required strings reject empty/whitespace without trimming or rewriting.
Optional labels use `$PSBoundParameters`: omission becomes literal diagnostic
`unavailable`; an explicitly bound null, empty, whitespace, non-string, control
character, or over-limit value fails before filesystem calls. Labels never
authorize/select an artifact or form a path.

`Expand-StyleGuideCandidateArtifact.ps1` accepts only these named values:

- required `CheckoutRoot`, `TrustedTemporaryRoot`, `DownloadDirectory`,
  `CandidateDirectory`, and `ExpectedDigest`; and
- optional `ArtifactId`, `RunId`, and `RunAttempt`.

`ExpectedDigest` must be an exact string matching `^[0-9A-Fa-f]{64}$`.

The script defines functions before its entry point. Ordinary dot-sourcing
defines functions and returns without expansion. There is no test switch,
environment backdoor, caller-selected policy, or alternate production entry.

## Closed context and journal schemas

`Manage-StyleGuideCandidateInvocationContext.ps1` exports exactly:

- `New-StyleGuideCandidateInvocationContext`; and
- `Remove-StyleGuideCandidateInvocationContext`.

The context has first `PSTypeName`
`PSStyleGuide.CandidateInvocationContext.v1` and exactly these ordered
properties and runtime types:

| Property | Exact type/rule |
| --- | --- |
| `SchemaVersion` | `System.UInt32`, exactly `1` |
| `ContextScriptVersion` | `System.Version`, exact script version |
| `InvocationId` | nonempty `System.Guid` |
| `DiagnosticLabel` | already validated `System.String` |
| `TrustedParentPath` | normalized nonempty `System.String` |
| `InvocationRootPath` | normalized nonempty `System.String` |
| `DownloadDirectoryPath` | normalized nonempty `System.String` |
| `CandidatePath` | normalized nonempty `System.String` naming the initially absent leaf |
| `LifecycleState` | exact `Active`, `CleanupFailed`, or `Disposed` |
| `NextSequence` | `System.UInt32` |
| `OwnershipJournal` | exact one-dimensional `System.Object[]`, including empty without scalar unrolling |

Each journal item has first `PSTypeName`
`PSStyleGuide.CandidateOwnershipRecord.v1` and exactly:

| Property | Exact type/rule |
| --- | --- |
| `SchemaVersion` | `System.UInt32`, exactly `1` |
| `Sequence` | contiguous `System.UInt32` from zero |
| `Kind` | invocation root, download directory/file, candidate directory/file |
| `Path`, `ParentPath`, `LeafName` | exact normalized strings with parent/leaf recomposition |
| `ExpectedEntryType` | exact `File` or `Directory` |
| `CreationPhase` | closed phase enum |
| `EntryState` | `ExpectedAbsent`, `Created`, `Deleted`, or `RetainedUncertain` |
| `ContentLength` | `System.UInt64` or null only for a schema-authorized kind/state |
| `ContentSha256` | lowercase 64-hex string or null under the same rule |

One private validator checks exact first type name, ordered property names,
runtime types without conversion, enum casing, sequence/cardinality, state
transitions, containment, recomposition, and context/journal agreement before
every state transition or filesystem operation. Record validity never proves
live filesystem identity; re-prove that separately.

Creation accepts one raw explicit runner-controlled temporary parent. It
validates an existing ordinary non-reparse FileSystem directory, chooses a
child with `Path.GetRandomFileName()`, proves absence, creates without `-Force`,
and retries a documented finite count only after an exhaustive real collision
proof. Permission/type/attribute/resolution failures fail immediately. It
creates a separate download directory and selects—but does not create—the
candidate leaf.

## Cleanup authority and lifecycle

The archive helper defines exactly
`Remove-StyleGuideCandidateInvocationState`. Normal helper failures and every
cleanup fixture invoke this production function. Caller cleanup never
recursively enumerates ownership and never substitutes its own candidate
deletion.

Use this exact synchronous transition model:

| Current state | Operation/outcome | Next state | Filesystem/native calls |
| --- | --- | --- | ---: |
| `Active` | all exact owned entries proved and removed | `Disposed` success | bounded required calls |
| `Active` | invalid schema/relationship before deletion | `CleanupFailed` | zero deletion calls |
| `Active` | missing, unexpected, unreadable, substituted, reparse, delete, or verification uncertainty | `CleanupFailed` | stop at first uncertainty |
| `Disposed` | same valid context passed again | `Disposed` success | **zero** |
| `CleanupFailed` | same valid context passed again | `CleanupFailed` failure | **zero** |
| any | invalid/tampered context | unchanged failure | **zero** |

Do not add `CleanupInProgress`, retry failed cleanup, or infer disposal from a
missing path. The first `Active` cleanup performs a complete pre-deletion proof,
then removes only exact journaled files and empty directories nonrecursively,
deepest first. Transition to `Disposed` only after those owned deletions prove
the invocation root absent. After a terminal transition, do not inspect those
names again; a new object at a released name is outside the capability.

On uncertainty, preserve the primary failure and cleanup failure, mark affected
records `RetainedUncertain`, stop further deletion, and report only bounded
root/phase/entry/category evidence. Spies must prove repeated terminal calls
make zero provider, path, filesystem, native, sleep, or enumeration calls.

## Archive and extraction contract

### Paths and fixed order

For each already type-validated path, reject wildcard, relative, malformed,
ambiguous, or non-FileSystem syntax. Accept native rooted or
FileSystem-provider-qualified absolute strings. Obtain one deterministic
provider-internal path, normalize once, compare ordinal-ignore-case on Windows
and ordinal elsewhere, and use separator-aware equality/descendant tests.

Require checkout and trusted roots to be existing ordinary directories and
mutually non-overlapping. Download/candidate paths are strict descendants of
the trusted root and outside checkout. Lexically inspect every existing
component from volume/share root through all declared paths and created leaves;
reject links, reparse points, junctions, volume mounts, dangling entries, type
mismatch, or inspection failure without following the entry. Recheck before
archive open, candidate creation, and after extraction.

Use exactly this order:

1. raw type/value/label/digest grammar;
2. roots, components, and root separation;
3. working-path containment/components;
4. exact download content/archive type;
5. candidate-parent safety and leaf absence;
6. one retained archive stream open and SHA-256;
7. rewind the same stream, open ZIP, enforce limits, validate manifest;
8. repeat component/containment/parent/leaf checks;
9. create candidate exactly once and extract; and
10. validate output bytes/filesystem state exhaustively.

No earlier phase creates the candidate leaf. Stable phases are `parameter`,
`root`, `containment`, `download`, `digest`, `archive`, `manifest`,
`destination`, `extraction`, `post-extraction`, and `cleanup`.

### One retained archive

The download directory contains exactly one top-level entry, including hidden
and system entries. It is an ordinary non-reparse file; extension is irrelevant.
Open once with `FileMode.Open`, `FileAccess.Read`, `FileShare.Read`; require
readable/seekable; hash the held stream with SHA-256; require one 64-hex result;
and compare ordinal-ignore-case. A mismatch occurs before ZIP construction.
Rewind the same stream, construct one read-only `ZipArchive` with deliberate
`leaveOpen`, keep both open through extraction, then dispose ZIP and stream
before cleanup. Do not hash by path and reopen/copy.

Before candidate creation require exactly these four root-level, ordinal,
nondirectory names:

```text
copilot-instructions.md
powershell.instructions.md
STYLE_GUIDE_CHAT.md
STYLE_GUIDE_FULL.md
```

Reject empty/missing/extra/duplicate/case-colliding names, either separator,
nesting/traversal, leading separator, drive qualification, directory entries,
and file/directory collisions.

Closed inclusive ceilings are four entries; 8 MiB declared and actual bytes
per entry; 32 MiB declared and actual total; and 32 MiB retained archive.
Reject negative, overflowed, inconsistent, or unreadable lengths and count
actual copied bytes independently.

Immediately before candidate creation, reject any ordinary, link/reparse, or
dangling leaf with its name. Create once. For each permitted entry, compute one
immediate-child normalized destination, prove containment, open
`FileMode.CreateNew` with no sharing, journal ownership, copy with limits, and
dispose deterministically. Restore no ZIP attributes, modes, links, or
timestamps. After extraction require exactly four ordinary non-reparse files,
repeat containment/component checks, and reject UTF-8 BOM and every `0x0D`.

## Canonical case catalog

`style-guide-candidate-cases.json` has one closed schema/version and exactly one
record per mandatory case. Each record contains:

- immutable `CaseId` matching `^PS-P1A-[A-Z]+-[0-9]{2}$`;
- unique lowercase dot-separated `SemanticCase`;
- optional `SemanticVariant` only for an intentional many-to-one semantic map;
- fixture recipe/raw digest and length where applicable;
- required runtimes and primitive-probe rule;
- expected status/phase, pre-teardown oracle, cleanup oracle, diagnostic code,
  and filesystem-call count.

Unknown/missing properties, duplicate IDs/semantic keys, unused cases,
undeclared skips, or expectation forks fail. Generate test-owned ZIP/path
fixtures in fresh contexts; never track a fixture tree. These groups are the
closed seed inventory:

| IDs | Required semantic inventory |
| --- | --- |
| `PS-P1A-V-01..02` | exact valid archive; link-like ZIP attributes ignored into ordinary files |
| `PS-P1A-P-01..02` | sibling-prefix containment rejection; provider-qualified success |
| `PS-P1A-D-01..05` | digest mismatch with present/omitted labels; short, nonhex, and prefixed digest |
| `PS-P1A-Z-01` | matching-digest invalid/truncated ZIP |
| `PS-P1A-M-01..14` | missing, extra, exact/case duplicate, slash/backslash nested/traversal, leading separators, drive, directory, collision, raw empty name |
| `PS-P1A-E-01..15` | outside/equal/ancestor roots, relative/provider/case/link/hidden/wildcard/missing/type failures, plus raw array/object path values replacing unreachable multi-resolution strings |
| `PS-P1A-L-01..04` | preexisting file, directory, live link, dangling link candidate leaves |
| `PS-P1A-B-01..02` | extracted BOM and CR |
| `PS-P1A-K-01..04` | unjournaled/link substitution, zero-call disposed repeat, primary plus candidate-cleanup failure |
| `PS-P1A-C-01..08` | normal/zero-call disposed repeat, unjournaled/link/missing uncertainty, primary plus cleanup failure, partial journal, candidate-then-context cleanup |
| `PS-P1A-R-01..13` | per-entry/total/archive below/at/above bounds, actual overruns, negative/inconsistent lengths, checked overflow |
| `PS-P1A-W-01..05` | empty/two-entry/directory/link/unreadable download |
| `PS-P1A-S-01..11` | missing/wildcard/provider/raw array-or-object/link helper/context-manager paths and both valid provider-qualified paths |
| `PS-P1A-X-01..10` | explicit empty/null/non-scalar labels and exact valid labels |

Each individual record—not the range label—is the executable oracle and has a
distinct semantic key. The catalog preserves the original 96-case cardinality;
if compact group counts do not total 96, implementation stops and reconciles
the catalog before code is accepted. Every runtime emits exactly one result for
all 96 IDs, including fixed/conditional skip records.

`All` cases run on Windows PowerShell 5.1, PowerShell 7/Windows, and PowerShell
7/Ubuntu. Windows/Linux comparison cases have fixed opposite-platform skip
codes. Per-OS link cases may skip only after the exact primitive-creation probe,
with ID/runtime/probe/reason recorded. At least one real root link, below-root
link, candidate substitution, and context substitution must execute per OS
family or that runtime fails.

## Result and evidence schema

Every in-memory result has first `PSTypeName`
`PSStyleGuide.CandidateCaseResult.v1` and exactly:

- `SchemaVersion` (`UInt32`, `1`);
- exact strings `CaseId`, `SemanticCase`, and nullable `SemanticVariant`;
- closed `OperatingSystem`/`PowerShellEdition` strings and exact
  `PowerShellVersion` (`System.Version`);
- closed expected/actual status and phase values;
- expected/actual pre-teardown oracle and cleanup state;
- `FixtureLength` (`UInt64`) and lowercase `FixtureSha256`;
- nonempty `InvocationId` (`Guid`);
- `Outcome` (`Passed`, `Failed`, or `HarnessError`);
- closed bounded `DiagnosticCode`; and
- `FilesystemCallCount` (`UInt32`).

Unknown fields/types/enums or inconsistent relationships fail. `Passed`
requires every expected/actual value and fixture identity to match and
diagnostic `None`. Suite success requires exact multiset equality with the
catalog's case×runtime expansion.

Emit a canonical JSONL projection with fixed property order/invariant strings,
BOM-less UTF-8, LF, and one object per result. It contains no absolute paths,
exception stack, environment, archive contents, or secrets. A separate bounded
run envelope may record UTC start/end and tool/catalog hashes without changing
per-case equality.

## Reciprocal P1A↔T1A comparison

At implementation start and before merge compare exact landed PSStyleGuide and
TerraformStyleGuide P1A/T1A contracts across raw binding, omission/null rules,
schemas/types, archive/digest order, path/link safety, manifest/limits,
extraction, both cleanup lifecycles, zero-call terminal behavior, case semantic
keys, runtime applicability/skips, result/evidence schemas, and diagnostics.

Join on `SemanticCase` plus optional variant; classify PS-only/T-only cases.
Record exact evidence and `same`, `intentional difference`, or `blocker`.
Manifest filenames may differ intentionally; unexplained security/failure
differences block merge.

## Validation

Run exact tracked scripts/catalog in clean disposable worktrees under Windows
PowerShell 5.1, PowerShell 7 on Windows, and PowerShell 7 on Ubuntu. Record
script/catalog versions and hashes, executable/edition/OS/Git, exact
pass/fail/skip totals, and duration.

Static and dynamic checks prove:

- public raw non-string values fail before any filesystem/provider call;
- no recursive/wildcard deletion, automatic ZIP extraction, ambient root,
  alternate cleanup, or production test switch exists;
- context/journal/result ordered schemas and every mutation are rejected;
- terminal repeats perform zero filesystem/native calls;
- one held archive stream and exact validation/extraction order are observed;
- every catalog case executes once on its declared runtime set;
- expected helper failures count as harness pass, while missing/duplicate/
  unexpected/status/skip/total mismatch fails the suite;
- sentinels and source repository remain byte-identical;
- P1's exact path verifier proves only the four affected paths changed/staged
  before and after rerun; and
- generator, workflows, artifacts, package/update policy remain unchanged.

Any temporary hosted-evidence workflow is test-owned, absent from the final
commit, and not required by the production harness.

## Acceptance criteria

- [ ] Four affected files are versioned/hashed as required and LF/BOM-less.
- [ ] Every public value crosses the raw exact-type boundary before conversion
      or filesystem work.
- [ ] Context, journal, lifecycle, and result schemas are exact and mutation
      tested.
- [ ] Cleanup is nonrecursive/journal-based; uncertainty is retained; terminal
      repeats make zero calls.
- [ ] One archive stream is opened, hashed, rewound, parsed, and disposed in
      order; digest mismatch precedes ZIP construction.
- [ ] Component, containment, root-separation, link, download, manifest, and
      declared/actual limit cases pass on both OS families.
- [ ] Extraction creates only four fresh ordinary BOM-less/LF files and
      restores no ZIP metadata.
- [ ] The authoritative catalog contains exactly 96 unique namespaced IDs and
      semantic keys, with exact case×runtime results and honest skips.
- [ ] JSONL evidence is canonical, bounded, and path/content/secret minimizing.
- [ ] Real link/reparse rejection executes on both OS families.
- [ ] P1A↔T1A has no unexplained blocker.
- [ ] P1's landed verifier proves final path sets equal the four affected files.
- [ ] No production workflow consumes the scripts.

## Handoff

Give P1B permanent P1A issue/PR URLs, reviewed head/base, merge method, landed
commit/tree, all three script versions/hashes, catalog schema/version/hash,
exact public schemas, per-runtime JSONL/run evidence, primitive probes,
cleanup/zero-call proof, final path-set proof, and P1A↔T1A matrix. P1B compares
these landed identities with its assumptions before activating anything.

## Non-goals

- Workflow trigger/permission/job/action or artifact-transport changes.
- Downloading/uploading a real Actions artifact.
- Committing generated output.
- An OS-native adversarial filesystem sandbox or competing untrusted writer.
- A shared cross-repository runtime module.

## References

- [PowerShell parameter binding](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_parameter_binding)
- [Path.GetRandomFileName](https://learn.microsoft.com/dotnet/api/system.io.path.getrandomfilename)
- [FileStream](https://learn.microsoft.com/dotnet/api/system.io.filestream)
- [Get-FileHash](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/get-filehash)
- [ZipArchive](https://learn.microsoft.com/dotnet/api/system.io.compression.ziparchive)
- [File attributes](https://learn.microsoft.com/dotnet/api/system.io.fileattributes)
