<!-- markdownlint-disable MD013 -->

# Add a fail-closed cross-platform style-guide candidate validator

## Summary

Add one shared PowerShell validator/extractor, one caller-owned temporary context lifecycle, and one permanent adversarial harness for generated style-guide artifact candidates. The implementation must behave the same under Windows PowerShell 5.1 and PowerShell 7 on Windows and Ubuntu.

The validator treats every caller path, artifact label, ZIP entry, and cleanup claim as untrusted. It hashes and reads one continuously held archive stream, validates the complete manifest before creating the candidate directory, extracts only fresh ordinary files, and retains uncertain state rather than recursively deleting it.

## Dependency

Implement only after **Make artifact generation byte-deterministic and standardize repository text checkouts on LF** merges. Record and validate T1's actual merge commit before work. This issue records its reviewed head and requires T1B to consume its eventual merge commit; it does not claim to know that future value.

The next issue, **Promote generated style-guide artifacts through a least-privileged verified writer**, activates these scripts in workflows. Nothing in this issue changes production workflow behavior.

## Affected files

Exactly these three files may change:

- `.github/workflows/Expand-StyleGuideCandidateArtifact.ps1` — add;
- `.github/workflows/Manage-StyleGuideCandidateInvocationContext.ps1` — add;
- `.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1` — add.

Each script must:

- declare `#Requires -Version 5.1`;
- contain exactly one script-level `.NOTES` line before its first function, `Version: 1.0.<final-material-edit-UTC-YYYYMMDD>.0`, validated by T1's timeless grammar, explicit expected-version, and baseline authoring-bump layers;
- remain an ordinary LF, BOM-less UTF-8 file; and
- pass the repository's PowerShell formatting/static checks.

Timeless parsing rejects missing, duplicate, malformed, impossible-date, or function-level decoy versions without reading the clock; an old or future real date is valid grammar. Consumers check exact expected script versions from the same T1A commit/path/SHA as `unexpected-version`. Merge validation separately checks new-file/final-edit date and bump/reset rules. Commit IDs and SHA-256 remain the immutable evidence.

## Public contracts

### Archive validator/extractor

`Expand-StyleGuideCandidateArtifact.ps1` is an advanced script with positional binding disabled. Its raw boundary is exact:

| Parameter | Presence | Exact declaration after `[Parameter(...)]` | Accepted provided value after production validation |
| --- | --- | --- | --- |
| `CheckoutRoot` | mandatory | `[AllowNull()] [AllowEmptyString()] [AllowEmptyCollection()] [object]` | Runtime type exactly `System.String`, then the path grammar |
| `TrustedTemporaryRoot` | mandatory | same | Runtime type exactly `System.String`, then the path grammar |
| `DownloadDirectory` | mandatory | same | Runtime type exactly `System.String`, then the path grammar |
| `CandidateDirectory` | mandatory | same | Runtime type exactly `System.String`, then the path grammar |
| `ExpectedDigest` | mandatory | same | Runtime type exactly `System.String`; exactly 64 ASCII hex |
| `ArtifactId` | optional | `[AllowNull()] [AllowEmptyString()] [AllowEmptyCollection()] [object]` | If present, exact `System.String` canonical positive decimal, 1–20 digits |
| `RunId` | optional | same | If present, exact `System.String` canonical positive decimal, 1–20 digits |
| `RunAttempt` | optional | same | If present, exact `System.String` canonical positive decimal, 1–20 digits |

Mandatory omission remains a binder interface error. Every *provided* value, including null/empty/empty collection, reaches the same first production validation block. Snapshot all eight `$PSBoundParameters` presence flags and raw object references without formatting. Reject each provided string-intended value in exact order: null; runtime type other than exactly `System.String`; zero length; Unicode-whitespace-only; Unicode control; then its parameter grammar. Do not cast/interpolate/trim/case-fold/enumerate/place on the pipeline/call `ToString()`/pass to regex or filesystem APIs before the type gate. A type error may report only parameter name and safely obtained runtime type name.

After validation, path strings remain byte-for-character unchanged through the path grammar; digest must match `\A[0-9A-Fa-f]{64}\z` before creating one lowercase comparison copy; and each present label must match `\A[1-9][0-9]{0,19}\z`. Omitted labels, determined only from the snapshot, map to `unavailable`. Explicit null, empty, whitespace, control, `0`, leading zero, sign, decimal/exponent, non-ASCII digit, or 21st digit rejects. Labels never select an artifact, form a path/name, authorize bytes, affect cleanup, or choose a fixture.

Place function definitions before the main entry point. When dot-sourced through the ordinary PowerShell invocation context, define functions and return before normal expansion. Do not add a test switch, environment backdoor, or alternate expansion entry point.

### Caller invocation context

`Manage-StyleGuideCandidateInvocationContext.ps1` defines exactly:

- `New-StyleGuideCandidateInvocationContext`; and
- `Remove-StyleGuideCandidateInvocationContext`.

`New-StyleGuideCandidateInvocationContext` accepts one explicit runner-controlled temporary parent. It returns a structured context containing the normalized parent, invocation root, download directory, initially absent candidate path, diagnostic label, and exact ownership metadata.

`Remove-StyleGuideCandidateInvocationContext` accepts that context, the explicit ordinary paths owned by the completed invocation, and any primary failure. It never infers ownership by recursive enumeration.

The archive helper remains independently distrustful of a context produced by this companion script.

### Candidate-state cleanup

`Expand-StyleGuideCandidateArtifact.ps1` defines exactly one production candidate cleanup function:

```text
Remove-StyleGuideCandidateInvocationState
```

The normal helper failure path and every `K-*` harness case invoke this exact function. It accepts only `CandidateOwnershipState` and `PrimaryFailure`; there is no envelope/journal/Boolean-disposed overload. It does not delegate recursive deletion to the caller-context cleanup.

The helper creates and returns the same mutable object whose first `PSTypeName` is exactly `TerraformStyleGuide.StyleGuideCandidateOwnershipState.v1`:

| Property | Exact type/meaning |
| --- | --- |
| `SchemaVersion` | `[uint32]1` |
| `CandidateId` | new nonempty immutable `[guid]` |
| `LifecycleState` | `[string]`; one of `NotCreated`, `Active`, `CleanupInProgress`, `Disposed`, or `RetainedUncertain` |
| `TrustedTemporaryRootPath` | immutable normalized nonempty `[string]` |
| `CandidateParentPath` | immutable normalized nonempty strict descendant |
| `CandidateDirectoryPath` | immutable normalized exact leaf |
| `OwnershipJournal` | ordered `[object[]]` of closed v1 entries |
| `CleanupAttempt` | `[uint32]0`; increment only on valid nonterminal cleanup entry |
| `CleanupSummary` | `$null`, then closed ID/prior/final/primary/cleanup/removed/retained/leaf summary |

Construct it in `NotCreated` before candidate creation, transition to `Active` only after acquiring the fresh directory, and journal each ordinary file at ownership acquisition. Success and failure return the same object reference.

## Requested changes

### 1. Normalize and classify paths

For every path:

1. reject wildcards, relative paths, ambiguous multiple resolutions, and non-filesystem providers;
2. accept native rooted or filesystem-provider-qualified absolute paths;
3. resolve to one deterministic absolute filesystem-provider path before calling .NET APIs;
4. use ordinal-ignore-case comparison on Windows and ordinal comparison on non-Windows;
5. use separator-aware strict-descendant checks; and
6. bound every enumeration by the cardinality it is checking. An enumeration that asks "does this directory hold exactly N entries?" stops after N + 1 results and concludes from that; it does not materialize the directory. Materializing is unbounded work chosen by whatever wrote the directory: measured at 19.11 MiB of managed heap for a 200,000-entry directory versus 0.16 MiB bounded, for the identical verdict. An enumeration that proves a path *absent* is deliberately unbounded, because absence cannot be concluded from a partial listing.

`Get-ChildItem` may support diagnostics only when called with `-LiteralPath` and `-Force`; it may not establish an exact entry count.

### 2. Validate the complete path-component envelope

The archive helper must:

- require checkout and trusted-temporary roots to be existing ordinary directories;
- require the roots to be mutually non-overlapping;
- require download and candidate paths to be strict descendants of the trusted root and outside checkout;
- lexically inspect every existing component from volume/share root through each declared root, download directory/archive, candidate parent, and created candidate path;
- reject reparse points, symbolic links, junctions, volume mounts, dangling entries, type mismatches, and every attribute/resolution/enumeration failure;
- never follow a link merely to classify it; and
- repeat applicable component, containment, type, parent, and leaf checks before archive open, before candidate creation, and after extraction.

The supported model is a GitHub-hosted runner with runner-controlled ancestors, one job-owned checkout, one job-owned trusted temporary root, and no competing writer. Repeated validation narrows time-of-check/time-of-use risk; it is not an OS-native directory-handle sandbox.

### 3. Acquire and remove caller-owned context safely

Creation must:

1. normalize the explicit parent to an existing ordinary non-reparse filesystem directory;
2. call `Path.GetRandomFileName()` for a child name;
3. prove no filesystem entry has that child name;
4. create without `-Force`;
5. verify the returned exact child is one ordinary non-reparse directory;
6. retry a documented finite number of times only after exhaustive reinspection proves an actual name collision;
7. fail immediately for permission, type, attribute, resolution, or classification errors;
8. create a separate ordinary download directory; and
9. return a candidate leaf path that has no filesystem entry.

Use run/artifact metadata only for diagnostics, never as ownership or authorization.

Teardown must run after every ZIP, entry, and file stream is disposed. Before deleting anything, it revalidates the complete context envelope and every explicit owned entry. It removes only proven ordinary files and then empty ordinary directories, nonrecursively and deepest first. It never follows, wildcards, traverses, or recursively removes.

An unexpected, missing, unreadable, substituted, link, reparse, hidden, or unjournaled entry stops teardown. Retain uncertain state and report the root, phase, offending entry, cleanup exception, and primary failure without hiding the primary failure.

### 4. Enforce parameter and diagnostic grammar first

Before filesystem/archive work:

- snapshot presence/raw references and apply the exact null/type/empty/whitespace/control gate to every provided value;
- require `ExpectedDigest` to match `\A[0-9A-Fa-f]{64}\z`;
- require every present label to match `\A[1-9][0-9]{0,19}\z`;
- normalize only omitted labels to `unavailable`; and
- initialize stable phase diagnostics.

Stable phases cover:

- parameter;
- root;
- containment;
- download;
- digest;
- archive;
- manifest;
- destination;
- extraction;
- post-extraction; and
- cleanup.

Diagnostics include safely available normalized roots/paths, expected digest, actual digest after computation, retained archive path, supplied/omitted labels, offending entry/destination, and preserved underlying error. Never log artifact contents.

### 5. Use one validation order

The exact phase order is:

1. parameter/label grammar;
2. roots, all existing components, and root separation;
3. working-path containment/components;
4. exact download-directory content and archive-file type;
5. candidate-parent safety and candidate-leaf absence;
6. one archive read into a private buffer and SHA-256 over that buffer;
7. over the same buffer, open ZIP, enforce limits, and validate manifest;
8. repeat component/containment/parent/leaf checks;
9. create candidate once and extract; and
10. exhaustively validate output bytes and filesystem state.

No phase before step 9 creates the candidate leaf.

### 6. Bind digest and ZIP processing to one stream

The download directory must contain exactly one top-level filesystem entry, including hidden/system entries. It must be an ordinary non-reparse file; no `.zip` extension is required.

Attribute checks alone do not establish that. A named pipe reports `Normal` attributes, carries no reparse point, and reports a length of zero, so every check above accepts it — and opening one for reading blocks until a writer appears, which for an untrusted download entry hangs the job with no diagnostic naming a cause. **Refuse a zero-length entry before the open**, not after it: pipes, sockets, and device nodes all report zero, and a regular file of zero bytes cannot be an archive either, because the end-of-central-directory record alone is twenty-two bytes. The size floor the format already implies is therefore applied ahead of the open rather than behind it.

After revalidating the path:

1. open the file exactly once with `FileMode.Open`, `FileAccess.Read`, and `FileShare.Read`;
2. require a readable, seekable stream;
3. read that stream exactly once into a private in-memory buffer bounded by the 32 MiB retained-archive ceiling, then dispose the file stream;
4. hash that buffer with `Get-FileHash -InputStream -Algorithm SHA256`;
5. require one valid 64-hex result;
6. compare expected/actual ordinally, ignoring case;
7. fail before `ZipArchive` construction on mismatch;
8. bound the archive over that buffer, before constructing `ZipArchive`, by identifying the trailer the way the reader identifies it:
   - `System.IO.Compression` seeks to eighteen bytes before the end and takes the **last** `PK\x05\x06` at or before `length-22`, searching at most 65557 bytes, then commits — no validation, no second candidate, identical on .NET Framework 4.8 and on .NET 8 and later. Select that same record.
   - If that record fails validation, **refuse the archive**. Do not continue scanning for an earlier candidate: a pre-check that skips a record the reader would have taken is describing a different archive than the one about to be parsed, which is strictly worse than not checking at all.
   - Require the declared comment length to reach exactly the end of the file.
   - Require **both** end-of-central-directory disk fields to be zero. Either field at its sixteen-bit maximum is the reader's own condition for consulting a Zip64 locator in the twenty bytes before the record, and a locator found there replaces the entry count and directory offset outright with values read from elsewhere in the file. Twenty bytes fit inside a central-directory record's comment.
   - Count central-directory records without reading them: read at most five forty-six-byte record heads, step over each name, extra field, and comment by position rather than reading them, accept the optional digital-signature record only as the terminal record, refuse Zip64 markers, and require the directory to end exactly at the trailer;
9. construct one read-only `ZipArchive` over that same buffer with deliberate `leaveOpen`;
10. keep it alive through manifest validation/extraction; and
11. dispose the ZIP before cleanup.

Do not hash by path and reopen, copy to another file, read the archive file a second time, or accept a `sha256:` prefix.

### 7. Validate exact manifest and resource limits

Before candidate creation, require exactly four root-level nondirectory entry names using ordinal comparison:

```text
copilot-instructions.md
terraform.instructions.md
STYLE_GUIDE_CHAT.md
STYLE_GUIDE_FULL.md
```

Reject empty names, missing/extra entries, exact or case-insensitive duplicates, `/` or `\`, nesting/traversal, leading slash/backslash, drive qualification, directory entries, and file/directory collisions.

Enforce before extraction:

- exactly four entries;
- at most 8 MiB declared uncompressed length per entry;
- at most 32 MiB declared total uncompressed length;
- at most 32 MiB retained archive length; and
- no negative, overflowed, inconsistent, or unreadable length.

“At most” is inclusive. Accumulate declared and actual lengths with checked 64-bit arithmetic. Count actual copied bytes and stop on the first byte that would exceed the same per-entry/total limits. A declared length is not trusted proof of actual output. Tests generate large ordinary fixtures streamingly/sparsely beneath the disposable context; do not commit large expanded blobs. Use fixed reviewed raw ZIP bytes, with recorded SHA-256 and construction rationale, only for metadata states `ZipArchive` cannot create.

### 8. Create and extract only fresh ordinary files

The candidate leaf must be absent until digest, ZIP, limits, and manifest pass. Immediately before creation, exhaustively reject any file, directory, live link/reparse point, or dangling link with the leaf name. Create once; never delete/recreate or reuse.

For each permitted entry:

- compute one immediate-child destination with `GetFullPath`;
- prove it remains under candidate root;
- open with `FileMode.CreateNew`, write access, and no sharing;
- journal the path before/at successful ownership acquisition;
- copy only entry bytes; and
- dispose entry/destination streams deterministically.

Do not restore link information, Unix type/mode, Windows attributes, timestamps, or any ZIP metadata. External attributes are ignored, not treated as a safe destination type.

After extraction:

- repeat component and containment validation;
- enumerate exact candidate contents;
- require exactly the four expected ordinary non-reparse files;
- reject UTF-8 BOM bytes and every `0x0D` byte; and
- return the four normalized candidate paths plus the same Active `CandidateOwnershipState`; log only safe paths/ID/state, never contents.

### 9. Fail closed during candidate cleanup

`Remove-StyleGuideCandidateInvocationState` treats its lifecycle object as untrusted. Before filesystem work require exact PSTypeName/property set/types, nonempty ID, allowed state, immutable envelope, journal schema/order/unique paths, Owned flags, attempt count, and summary consistency. Missing, forged, copied-loose, reactivated, path/ID-mutated, or contradictory state is `cleanup/candidate-state-invalid` with zero filesystem/deletion calls.

Transitions are closed:

1. `NotCreated`: revalidate the trusted parent and stream its immediate entries exactly once without materializing or retaining the collection. Stop on the first matching or unclassifiable entry and move to `RetainedUncertain`; delete nothing. If the enumeration completes with no match or uncertainty, exact candidate-leaf absence moves to `Disposed` with an empty cleanup. Enumeration failure also moves to `RetainedUncertain`.
2. `Active`: perform one complete pre-deletion pass over envelope, exact immediate-child equality, journaled ordinary-file identity, and parent/leaf relationships. Any uncertainty moves to `RetainedUncertain` before deletion. Only a complete pass increments attempt, enters `CleanupInProgress`, removes journaled files nonrecursively in safe order, and removes the proven-empty candidate directory. Complete success sets all journal `Owned=false`, retains acquisition evidence, records absent leaf, and moves to `Disposed`. Inspection/deletion failure stops immediately, records removed/retained entries, and moves to `RetainedUncertain`; no retry.
3. `Disposed`: validate only the in-memory closed object schema and require all entries `Owned=false`. Return the identical object, attempt, journal, and summary with success and **zero provider, path, filesystem, or native calls**. Do not inspect the released parent or leaf; any new occupant is outside this capability.
4. Entry in `CleanupInProgress` or `RetainedUncertain` returns stable nonzero `cleanup/candidate-state-retained`, with **zero provider, path, filesystem, native, or deletion calls**.

During the one Active cleanup, parent enumeration—not `File.Exists`/`Directory.Exists`—defines absence. Nothing is followed or recursively removed. After the transition, caller-context cleanup may continue only from the exact returned `Disposed` object and never reinspects the released candidate name. Any other candidate result makes the invocation context `RetainedUncertain`. Primary failure remains primary, with candidate/context cleanup outcomes attached separately.

Candidate-lifecycle rows are atomic:

| ID | `SemanticCase` | Singular oracle |
| --- | --- | --- |
| `T1A-K-03` | `cleanup.candidate.disposed-repeat` | valid Disposed object returns identical success with zero calls |
| `T1A-K-05` | `cleanup.candidate.disposed-name-file` | new ordinary file at released name is untouched; identical success and zero calls |
| `T1A-K-06` | `cleanup.candidate.disposed-name-directory` | new directory at released name is untouched; identical success and zero calls |
| `T1A-K-07` | `cleanup.candidate.disposed-name-live-link` | new live link at released name is untouched; identical success and zero calls |
| `T1A-K-08` | `cleanup.candidate.disposed-name-dangling-link` | new dangling link at released name is untouched; identical success and zero calls |
| `T1A-K-09` | `cleanup.candidate.disposed-name-unreadable` | inaccessible sentinel at released name is not inspected; identical success and zero calls |
| `T1A-K-10` | `cleanup.candidate.not-created-absent` | NotCreated with absent leaf transitions to Disposed |
| `T1A-K-11` | `cleanup.candidate.not-created-occupied` | NotCreated with occupied leaf transitions to RetainedUncertain |
| `T1A-K-12` | `cleanup.candidate.in-progress-repeat` | CleanupInProgress returns retained failure with zero calls |
| `T1A-K-13` | `cleanup.candidate.retained-repeat` | RetainedUncertain returns retained failure with zero calls |
| `T1A-K-14` | `cleanup.candidate.loose-state-rejected` | obsolete loose envelope/journal is invalid with zero calls |
| `T1A-K-15` | `cleanup.candidate.disposed-owned-rejected` | Disposed journal reactivated with `Owned=true` is invalid with zero calls |
| `T1A-K-16` | `cleanup.candidate.id-mutated-rejected` | CandidateId mutation is invalid with zero calls |
| `T1A-K-17` | `cleanup.candidate.envelope-mutated-rejected` | immutable envelope/path mutation is invalid with zero calls |

Every rejection has zero deletion and records CandidateId, transition, attempt count, exact removed/retained sequence, sentinel, and context consequence. Terminal repeat rows additionally use provider/path/filesystem/native spies and require an exact zero-call vector. `T1A-K-04` remains the primary-failure plus partial-cleanup-failure case.

### 10. Implement the permanent stable-ID harness

`Test-Expand-StyleGuideCandidateArtifact.ps1` accepts mandatory scalar `HelperPath` and `ContextManagerPath`. It resolves both exact tracked scripts once as ordinary non-reparse files, requires their expected version markers, and uses only those normalized absolute paths for child-script invocations. For each path, reject missing, relative, wildcard (including a multi-match-capable wildcard), non-filesystem-provider, wrong-type, untracked, and reparse input. A filesystem-provider-qualified absolute path is valid. The harness creates every fixture beneath one context produced by the exact supplied context manager and cleans only proven owned fixture state in `finally`.

The harness may dot-source the helper once for the deterministic cleanup cases and call `Remove-StyleGuideCandidateInvocationState`. It may not reimplement path, digest, archive, manifest, extraction, or cleanup logic.

Every case emits its stable ID, platform, phase, expected/actual outcome, initial candidate state, final candidate and caller-context state before harness teardown, required diagnostics, and outside-sentinel result. The harness contains matching machine-readable metadata and fails for a missing, duplicate, unexpected, or multiply emitted applicable ID. IDs are append-only: do not renumber a surviving behavior.

Unless a row states success, its exact oracle is a nonzero failure in the named phase, no unproved deletion, unchanged outside sentinel, and candidate/context state exactly as stated. Parameter/download failures perform no archive work.

Required postconditions:

- failures before helper creation leave candidate absent;
- preexisting leaves remain unmodified/unfollowed;
- ordinary helper-owned partial state is removed only by the production cleanup function;
- unsafe/ownership-uncertain state is retained;
- unrelated sentinels remain unchanged; and
- digest mismatch occurs before ZIP construction.

Both production cleanup lifecycles must be exercised independently and in one combined failure path. A primary failure followed by cleanup failure reports both without replacing the primary reason.

A narrowly justified link-primitive skip names the case, platform, and reason and is not a pass. At least one real link/reparse rejection must execute on each OS family.

### 11. Apply one raw public path grammar at every script boundary

The public path inventory is closed:

| Boundary | Raw path parameters |
| --- | --- |
| archive helper | `CheckoutRoot`, `TrustedTemporaryRoot`, `DownloadDirectory`, `CandidateDirectory`, and the retained archive path from exact enumeration |
| context creation | runner-controlled temporary parent |
| context cleanup | every explicit journaled owned path |
| harness | `HelperPath`, `ContextManagerPath` |

Every public path-looking parameter is declared `[object]` with the applicable `[Parameter(...)]`, `[AllowNull()]`, `[AllowEmptyString()]`, and `[AllowEmptyCollection()]`; the harness uses mandatory named parameters. Preserve each raw value as one object reference and do not let PowerShell enumerate or join it. Validate in this order before any filesystem work:

1. null → status 1, `parameter/path-null`;
2. non-string scalar or collection → `parameter/path-type`;
3. empty → `parameter/path-empty`;
4. Unicode whitespace-only → `parameter/path-whitespace`;
5. NUL/C0/C1 control or malformed provider syntax → `parameter/path-malformed`;
6. unescaped PowerShell wildcard grammar → `parameter/path-wildcard`;
7. relative, drive-relative, root-relative, `~`, or otherwise not fully qualified → `parameter/path-not-fully-qualified`; and
8. unsupported/nonfilesystem provider → `parameter/path-provider`.

Accept only a platform-native fully qualified filesystem path or exactly one `FileSystem::`-qualified fully qualified path. Reject aliases/custom PSDrives. Use `GetUnresolvedProviderPathFromPSPath` with provider/drive out values, require `FileSystem`, and normalize once. This API returns one unresolved string; production code must not call a resolving/multi-match API. Every grammar rejection creates no context/directory/archive/candidate, attempts no cleanup of unowned state, and leaves the outside sentinel unchanged.

Structured context/candidate-state/journal inputs remain `[object]` and must pass exact first `PSTypeName`, runtime type, closed property set/type, array shape, and lifecycle consistency before any property or element access. Hashtable/`PSCustomObject` substitution and PowerShell collection flattening are not accepted accidentally. `PrimaryFailure` remains an `ErrorRecord`, `Exception`, or explicit null under the stated contract and is never converted to text to decide cleanup/status.

The atomic raw-boundary catalog gives every parameter its own null, integer, Boolean, one-element array, two-element array, empty array, hashtable, `PSCustomObject`, `StringBuilder`, empty, whitespace-only, and control case. Digest adds 63/65 length and nonhex classes; each optional label adds omission, zero, leading zero, sign, non-ASCII digit, and overlength. Each case proves its one phase/subreason, no filesystem/archive side effect, no attacker-object `ToString()` call, bounded diagnostics, and edition parity.

### 12. Publish the invocation-context schema and lifecycle

The returned object's first `PSTypeName` is exactly `TerraformStyleGuide.StyleGuideCandidateInvocationContext.v1`, with this ordered closed schema:

| Property | Exact type/initial value |
| --- | --- |
| `SchemaVersion` | `[uint32]1` |
| `ContextId` | nonempty `[guid]` |
| `LifecycleState` | `[string]'Active'` |
| `TemporaryParentPath` | normalized nonempty `[string]` |
| `InvocationRootPath` | normalized nonempty `[string]` |
| `DownloadDirectoryPath` | normalized nonempty `[string]` |
| `CandidateDirectoryPath` | normalized nonempty `[string]`; expected absent leaf |
| `DiagnosticLabel` | nonempty safe `[string]`; never ownership |
| `OwnershipJournal` | exact `[object[]]` of v1 entries |
| `CleanupSummary` | `$null` initially; exact summary after attempt |

Each journal entry's first `PSTypeName` is `TerraformStyleGuide.StyleGuideCandidateOwnershipEntry.v1` and its closed properties are contiguous unique `Sequence [uint32]`, `Kind [string]` (`File|Directory`), normalized `Path [string]`, `Acquisition [string]`, and `Owned [bool]`. Journal only actually acquired entries; cleanup is deepest first then descending sequence. Choosing `CandidateDirectoryPath` does not own it.

Cleanup treats the object as untrusted and validates type names, exact property sets/types, schema/state/ID, journal order, path relationships, and current filesystem envelope before deletion. Its transitions are:

- `Active` → `CleanupInProgress` before deletion → `Disposed` only after every owned entry is safely removed and the invocation root is proven absent;
- any inspection/ownership/deletion/summary failure → `RetainedUncertain`;
- a valid returned `Disposed` object is success/no-op with the identical object/fields and zero filesystem calls;
- entry in `CleanupInProgress` or `RetainedUncertain` is a stable nonzero retained-state result with zero deletion; and
- missing/unknown/forged schema/state is invalid-context failure with zero filesystem calls.

`CleanupSummary` records context ID, prior/final state, attempts, ordered removed/retained paths, primary failure, cleanup result, and safe offending reason. It contains no secret content. Mutate and return the same object; callers replace their reference with it. Context metadata is not cryptographic authorization, so every Active cleanup revalidates actual ownership.

### 13. Make the case catalog and results structurally atomic

The normative catalog version is `T1A-CASES-v1`; its immutable closed oracle dictionary is `T1A-ORACLES-v1`. The 120-row table in section 10, the 13 new IDs in the candidate-lifecycle table in section 9 (`K-05` through `K-17`; the repeated `K-03` is one physical row), and the eight `I` rows below are the sole **141-row physical allocation**. There is no range record. Each ID maps literally to one materialized profile named `T1A-ORACLE-<ID>`; for example, `T1A-V-01` maps only to `T1A-ORACLE-T1A-V-01`. Every materialized profile copies the row's exact fixture/invocation and singular oracle and expands all remaining fields below before the issue is filed. Every row has exact fields:

```text
Id SemanticCase Applicability Fixture InitialState OracleProfile
ExpectedResult ExpectedStatus ExpectedPhase ExpectedSubreason
PreCleanupCandidateState FinalCandidateState FinalContextState
CleanupSequence ExpectedDiagnostics SentinelState SourceRepositoryState
```

Emitted records repeat every expected field and add corresponding `Actual*` fields, exact fixture parameters, runtime/edition/platform, and `HarnessVerdict (pass|fail|skip)`. A correctly observed production rejection is `ExpectedResult: rejection`, `ExpectedStatus: 1`, `HarnessVerdict: pass`; it is not a failed test. Applicability skip uses `ExpectedResult: skip`, `ExpectedStatus: null`, `HarnessVerdict: skip` and earns no pass.

Candidate states are exactly `not-applicable|absent|four-valid-files| owned-partial|preexisting-unchanged|uncertain-retained`; context states are `not-created|Active|Disposed|RetainedUncertain`. Cleanup is an ordered array containing only `candidate-cleanup|candidate-cleanup-noop|context-cleanup| context-cleanup-noop|none`. Slash lists, “then,” “applicable,” `or`, or prose alternatives are invalid metadata.

The following oracle-family descriptions constrain those already materialized per-row profiles; they are not catalog rows, dynamic generators, or permission to choose a profile during implementation:

| Profile | Immutable expansion; row-specific fields |
| --- | --- |
| `OP-SUCCESS-EXTRACT` | success/0/`complete`/`none`; pre-cleanup four files; final candidate absent/context Disposed; candidate then context cleanup; unchanged sentinels/source; row supplies applicability/fixture/initial state/diagnostics |
| `OP-SUCCESS-CANDIDATE-NOOP` | success/0/`cleanup`/`candidate-already-disposed`; final candidate absent/context Active; candidate-noop only; unchanged sentinels/source |
| `OP-SUCCESS-CONTEXT-NOOP` | success/0/`cleanup`/`context-already-disposed`; final candidate absent/context Disposed; context-noop only; unchanged sentinels/source |
| `OP-SUCCESS-PARTIAL-JOURNAL` | success/0; final candidate absent/context Disposed; context cleanup; row supplies exact removed sequence |
| `OP-REJECT-PRECONTEXT` | rejection/1; candidate absent/context not-created; no cleanup; row supplies exact phase/subreason |
| `OP-REJECT-PRECANDIDATE` | rejection/1; candidate absent/context Disposed; context cleanup; row supplies exact phase/subreason |
| `OP-REJECT-PREEXISTING` | rejection/1; pre/final candidate preexisting-unchanged/context Disposed; context cleanup; row supplies exact leaf identity and reason |
| `OP-REJECT-PARTIAL-REMOVED` | rejection/1; pre-cleanup owned-partial/final absent/context Disposed; candidate then context cleanup; row supplies exact owned sequence/reason |
| `OP-REJECT-CANDIDATE-RETAINED` | rejection/1; pre/final uncertain-retained/context RetainedUncertain; candidate then context cleanup; row supplies primary/cleanup reasons and retained paths |
| `OP-REJECT-CONTEXT-RETAINED` | rejection/1; row's proven candidate state/context RetainedUncertain; context cleanup; row supplies exact reason/retained paths |
| `OP-SKIP-PRIMITIVE` | skip/null/`applicability`; no fixture; candidate not-applicable/context not-created; no cleanup; row supplies platform/probe/reason |
| `OP-CATALOG-REJECTION` | rejection/1/`catalog`; candidate/context not-applicable; no cleanup; row supplies mutation/subreason |

Each materialized profile declares all fixed fields and only the literal variations in its physical row. Unknown fields/profiles, a profile name that does not equal the row's literal bijection, fixed-field override, missing variation, contradictory state, or prose alternative fails static catalog validation. All 141 profiles and ID/key meanings are frozen by this issue; new behavior appends a new row/profile.

Each row mutates one parameter, path, separator, platform, leaf, or outcome only. The physical tables contain no `or` fixture and no ordinal `*.case-NN` semantic key. P1A must split grouped evidence before it can satisfy multiple Terraform keys.

Startup expands profiles/rows, validates schema/unique sets, and computes exact applicable `(ID,runtime)` pairs. Completion requires one complete record for every pair and none outside it.

Not every implementation property has a different public result, so the separate normative manifest `T1A-HARNESS-PROOFS-v1` contains exactly these two proof rows. It does not add a functional oracle to the 141-row `T1A-CASES-v1` catalog.

Each proof row has the closed schema:

```text
Id SemanticCase Applicability ProductionBoundary
Control Perturbation ExpectedStatus ExpectedPhase ExpectedPostcondition
```

| ID | `SemanticCase` | Applicability | Exact control and perturbation | Singular proof oracle |
| --- | --- | --- | --- | --- |
| `T1A-H-01` | `harness.resource.bounded-cardinality-enumeration` | Windows PowerShell 5.1 on Windows; PowerShell 7 on Windows; PowerShell 7 on Ubuntu | Parse the exact supplied helper and context-manager command trees. Derive one temporary traced copy from the exact source and prove an exact-count check for `N` advances the source at most `N + 1` times. Derive one temporary mutant that eagerly materializes that source; the static proof must reject it before execution. | pass/status 0/`harness-proof` only when the exact-source AST is valid, the traced bound is `N + 1` or less, and the eager mutant is rejected; no candidate/context filesystem state |
| `T1A-H-02` | `harness.race.pre-journal-population-retained` | Windows PowerShell 5.1 on Windows; PowerShell 7 on Windows; PowerShell 7 on Ubuntu | From the exact supplied source, derive one temporary rendezvous copy that pauses after candidate-directory creation and before ownership is journaled. The positive control releases the pause with no competing entry and must succeed. The perturbation uses a synchronized second process to create one ordinary sentinel before release. | pass/status 0/`harness-proof` only when the control succeeds and the perturbation fails as `destination/pre-journal-populated`, retains candidate and context as uncertain, preserves the competing sentinel, and performs no deletion of it |

The harness records the exact source commit, blob IDs, SHA-256 values, deterministic source-to-copy transformation identity, temporary-copy hashes, parser errors, trace count, process synchronization evidence, and final filesystem state. It removes the temporary proof copies after the results are sealed. A proof copy never becomes a production entry point, and no test switch or environment backdoor is added to a production script.

Exactly six proof results exist: one result for each of the two IDs on each of the three runtime cells. Startup validates the manifest version, closed schema, literal two-ID set, semantic keys, exact applicability, and the six expected `(ID,runtime)` pairs. Completion rejects missing, duplicate, unknown, skipped, orphaned, or multiply emitted proof results. It retains the manifest version, canonical expanded SHA-256, expected/result counts, and per-runtime totals.

The phrase “none outside it” governs the 141-row functional catalog. The six harness-proof results are authorized only by `T1A-HARNESS-PROOFS-v1`.

Mutation tests independently prove missing, duplicate, unexpected, and multiply emitted results fail. Retain profile/catalog versions, canonical expanded SHA-256, profile/applicability/expected result counts, and per-runtime pass/fail/skip totals.

### 14. Use repository-local IDs and shared semantic identities

Every Terraform ID in the table is namespaced `T1A-`. Every row/result also contains the explicit unique semantic key shown in the table, matching `^[a-z][a-z0-9]*(\.[a-z][a-z0-9-]*)+$`. IDs and keys are opaque, append-only, and never changed/reused after merge.

Required behavior-key mappings include:

| Local ID | Exact `SemanticCase` |
| --- | --- |
| `T1A-V-01` | `archive.valid.exact-four-files` |
| `T1A-V-02` | `archive.valid.external-attributes-ignored` |
| `T1A-P-01` | `path.containment.checkout-sibling-prefix-rejected` |
| `T1A-P-02` | `path.provider.filesystem-qualified-accepted` |
| `T1A-D-01` | `digest.mismatch.labels-supplied` |
| `T1A-D-02` | `digest.mismatch.labels-omitted` |
| `T1A-M-05` | `manifest.name.forward-slash-nesting-rejected` |
| `T1A-M-06` | `manifest.name.backslash-nesting-rejected` |
| `T1A-L-03` | `destination.preexisting.live-reparse-retained` |
| `T1A-K-03` | `cleanup.candidate.repeat-disposed` |
| `T1A-C-02` | `cleanup.context.repeat-disposed` |
| `T1A-R-06` | `limit.declared-total.at-32mib-accepted` |
| `T1A-W-02` | `download.entry-count.two-rejected` |
| `T1A-S-11` | `harness.input.provider-qualified-tracked-scripts-accepted` |

Add exact disposable-catalog rows:

| ID | `SemanticCase` | Profile and subreason |
| --- | --- | --- |
| `T1A-I-01` | `catalog.local-id.duplicate-rejected` | `OP-CATALOG-REJECTION`; `duplicate-local-id` |
| `T1A-I-02` | `catalog.local-id.missing-rejected` | `OP-CATALOG-REJECTION`; `missing-local-id` |
| `T1A-I-03` | `catalog.semantic-key.duplicate-rejected` | `OP-CATALOG-REJECTION`; `duplicate-semantic-key` |
| `T1A-I-04` | `catalog.semantic-key.missing-rejected` | `OP-CATALOG-REJECTION`; `missing-semantic-key` |
| `T1A-I-05` | `catalog.mapping.changed-rejected` | `OP-CATALOG-REJECTION`; `id-key-mapping-changed` |
| `T1A-I-06` | `catalog.oracle.divergence-rejected` | `OP-CATALOG-REJECTION`; `equal-key-oracle-differs` |
| `T1A-I-07` | `catalog.counterpart.classification-missing-rejected` | `OP-CATALOG-REJECTION`; `counterpart-classification-missing` |
| `T1A-I-08` | `catalog.intentional-difference.rationale-missing-rejected` | `OP-CATALOG-REJECTION`; `intentional-difference-rationale-missing` |

Reciprocal equality means exact equality of semantic key, fixture, applicability, result, terminal phase/subreason/status, candidate/context states, diagnostics, sentinel, and cleanup sequence. The P1A↔T1A matrix records `SemanticCase`, immutable P commit/local ID/evidence, immutable T commit/local ID/evidence, classification (`same|intentional difference|blocker`), and rationale. A grouped, missing, or divergent P row is a blocker, not an assumed oracle. Runtime never downloads or executes the other repository.

Run each catalog-integrity row against a disposable mutated catalog, never by changing the authoritative in-memory catalog.

### 15. Prove both supplied scripts are the exact HEAD/index/working blobs

The harness derives its trusted repository root from the ordinary non-reparse `.github/workflows` `$PSScriptRoot` by exactly two parents; it never trusts the current directory or an ambient Git root. Launch Git directly with argument arrays/raw streams, remove or reject `GIT_DIR`, `GIT_WORK_TREE`, `GIT_INDEX_FILE`, object/alternate-object, and pathspec-mode variables, and set child-only `GIT_LITERAL_PATHSPECS=1`, `GIT_OPTIONAL_LOCKS=0`. Every command uses `--no-replace-objects --no-pager -C <trusted-root>`. Record Git path/version. Resolve Git, and every other native command, from a fixed absolute location list rather than through `PATH`. On Windows derive the locations from `Environment.GetFolderPath`, not from `%ProgramFiles%`. If no listed location holds an ordinary file, fail closed. Resolving by command name is insufficient even when the search is restricted to applications: that restriction closes command *precedence* — an alias or function can no longer shadow the name — but the search still runs in `PATH` order, and `PATH` is caller-controlled. The resolved file itself remains trusted; that residual is documented rather than checked.

Require raw stdout exactly for:

```text
git ... rev-parse --is-inside-work-tree
git ... rev-parse --show-prefix
git ... rev-parse --show-object-format=storage
git ... rev-parse --verify HEAD^{commit}
```

The first is `true` plus LF, prefix is one empty LF record, object format is `sha1|sha256`, and HEAD is one full lowercase 40/64-hex commit. Normalize each raw public script path once, compare to its exact absolute role destination, then map—not derive—it to:

| Role | Fixed repository path |
| --- | --- |
| helper | `.github/workflows/Expand-StyleGuideCandidateArtifact.ps1` |
| context manager | `.github/workflows/Manage-StyleGuideCandidateInvocationContext.ps1` |

For each fixed repository path run:

```text
git ... ls-tree --full-tree -r -z HEAD -- <path>
git ... ls-files --cached --stage --full-name -z --error-unmatch -- <path>
git ... hash-object --no-filters -- <normalized-absolute-path>
```

Parse NUL records from `BaseStream`. Tree output is exactly one `100644 blob <full-oid>\t<exact-path>\0`; index output is exactly one `100644 <same-oid> 0\t<exact-path>\0`; no conflict stage/duplicate/trailing bytes are allowed. `ls-files` status 1/no record is `script-untracked`; every other unexpected nonzero/start error is `git-tool-failure`. The no-filter working OID is one LF-terminated full OID equal to HEAD/index; it never uses `-w`, filters, conversion, or index bytes as a working-file substitute.

Both roles must pass completely before either is dot-sourced/invoked. Retain only normalized role paths, OIDs, and expected versions. Immediately before each later invocation repeat ordinary/component identity and no-filter OID. Diagnostics identify fixed role/command/status/structural reason and safe OIDs, not raw output/path/content/environment/stderr.

Keep `T1A-S-12`/`13` for untracked roles and append atomic rows for HEAD/index absence, staged and unstaged replacement, conflict stage, wrong mode/nonblob, duplicate/truncated/malformed records, path mismatch, abbreviated/wrong-format OID, expected status 1, unexpected status 2, and start failure. Disposable repos include spaces, tabs/newlines, leading dash, wildcard/pathspec-magic, quotes, and non-ASCII to prove literal fixed selection.

## Reciprocal PSStyleGuide comparison

At implementation start and before merge, compare the then-current PSStyleGuide **candidate-validation layer** and this issue. Record the exact PS commit and current location: the P1 candidate-validation section or its eventual P1A identifier. Compare:

- public parameters and omission/empty rules;
- archive identity and digest;
- full-component path security;
- manifest/limits/extraction;
- caller context and both cleanup lifecycles;
- diagnostics/stable IDs/skips/postconditions; and
- platform/edition support.

For each row record PS candidate-layer evidence, Terraform evidence, status (`same`, `intentional difference`, `blocker`), and rationale. Repository paths, manifest filenames/bytes, and workflow topology may differ intentionally. Unexplained security/error behavior differences block merge. The semantic layer name remains stable if PS planning files are renamed or split.

Store the completed matrix in the pull request or a tracked planning artifact. The repositories remain self-contained; do not introduce a shared runtime package.

## Validation

Run the exact tracked harness against the exact tracked helper under:

- Windows PowerShell exactly 5.1 on Windows;
- PowerShell 7 on Windows; and
- PowerShell 7 on Ubuntu.

Use clean disposable clones/worktrees and record script versions, executable paths, editions, OS versions, Git versions, case totals, skips, and duration. All mandatory applicable IDs must report exactly one result.

Also perform static checks proving:

- no recursive/wildcard deletion in either production script;
- no automatic ZIP extraction action/API;
- no ambient root derivation from current directory or GitHub environment;
- one definition of each exact cleanup function;
- normal helper and harness call the same candidate cleanup;
- the harness resolves the supplied helper and context-manager paths once and invokes only those exact tracked versions;
- every exact enumeration includes hidden/system entries, exact-count scans retain at most `N + 1` entries, and absence scans do not accumulate the completed sequence;
- only the three affected files changed/staged; and
- generator outputs/workflows remain unchanged.

If hosted cross-platform evidence needs a temporary workflow, use a uniquely named branch/workflow for evidence, remove it before the final commit, and prove it is absent from the final changed/staged path set.

## Acceptance criteria

- [ ] The helper, context lifecycle, and harness have versioned PowerShell 5.1 compatible implementations.
- [ ] Timeless marker parsing, exact expected-version identity, and baseline-to-staged authoring progression pass independent cases.
- [ ] Every provided public raw value reaches one production type/empty/whitespace/control/grammar gate with no binder conversion, enumeration, attacker `ToString()`, or pre-gate side effect.
- [ ] Caller-root acquisition proves new ownership with bounded collision-only retry.
- [ ] Both production cleanup paths are nonrecursive, journal-based, and retain uncertain state.
- [ ] The archive is opened once, hashed as one stream, rewound, and parsed as the same stream.
- [ ] Digest mismatch precedes ZIP construction and candidate creation.
- [ ] Complete path-component, root-separation, containment, link, type, and exact-download checks pass on Windows and Ubuntu.
- [ ] Manifest and resource limits pass before candidate creation.
- [ ] Extraction creates only four fresh ordinary files and restores no ZIP metadata.
- [ ] Post-extraction BOM/CR/type/content checks pass.
- [ ] Every mandatory stable ID has one explicit oracle and pre-teardown postcondition.
- [ ] `T1A-CASES-v1` exactly expands `T1A-ORACLES-v1`; every machine-readable atomic row/result has singular expected/actual fields, profile, behavior key, and one applicable-runtime result.
- [ ] Catalog mutation cases reject missing/duplicate/changed IDs, semantic keys, mappings, profiles, counterpart classifications, and results.
- [ ] `T1A-HARNESS-PROOFS-v1` contains exactly two rows and six applicable results; its bounded-enumeration and pre-journal race proofs pass with their controls and fail for missing, duplicate, unknown, skipped, orphaned, or multiply emitted results.
- [ ] Declared and actual resource boundaries pass below/exact cases and reject above/overflow/deceptive cases as specified.
- [ ] Both cleanup lifecycles pass independent and combined primary-plus-cleanup-failure cases.
- [ ] Candidate ownership transitions are exactly NotCreated/Active/CleanupInProgress/Disposed/RetainedUncertain; repeated Disposed cleanup proves leaf absence and never deletes a reoccupied leaf.
- [ ] Helper and context-manager inputs independently prove exact trusted-root, HEAD tree, stage-0 index, and no-filter working blob identity before either script is invoked.
- [ ] Real link/reparse rejection executes on both OS families.
- [ ] The reciprocal PS candidate-validation-layer/Terraform matrix has no unexplained blocker.
- [ ] The final path gate contains exactly the three affected files.
- [ ] No production workflow consumes the new scripts yet.
- [ ] T1B is required to record and validate this issue's actual merge commit; this pull request records its reviewed head and successor handoff.

## Non-goals

- Changing workflow triggers, permissions, jobs, actions, or artifact transport.
- Downloading or uploading a real GitHub Actions artifact.
- Committing generated output changes.
- Providing an OS-native adversarial filesystem sandbox.
- Supporting untrusted concurrent writers beneath the job-owned root.
- Sharing one runtime module across repositories.

## References

- [Path.GetRandomFileName](https://learn.microsoft.com/dotnet/api/system.io.path.getrandomfilename)
- [Directory.CreateDirectory](https://learn.microsoft.com/dotnet/api/system.io.directory.createdirectory)
- [FileStream](https://learn.microsoft.com/dotnet/api/system.io.filestream)
- [Get-FileHash](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/get-filehash)
- [ZipArchive](https://learn.microsoft.com/dotnet/api/system.io.compression.ziparchive)
- [File attributes](https://learn.microsoft.com/dotnet/api/system.io.fileattributes)
- [PowerShell about providers](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_providers)

> IMPORTANT: You MUST see `docs\planning\TerraformStyleGuide\03aTerraformStyleGuideT1A.md` in branch `planning-CRT-PR-852` for the complete append-only fixture inventory and exact oracle requirements in Section **10. Implement the permanent stable-ID harness**, including the `T1A-V`, `T1A-P`, `T1A-D`, `T1A-Z`, `T1A-M`, `T1A-E`, `T1A-L`, `T1A-B`, `T1A-K`, `T1A-C`, `T1A-R`, `T1A-W`, `T1A-S`, and `T1A-X` case families.
