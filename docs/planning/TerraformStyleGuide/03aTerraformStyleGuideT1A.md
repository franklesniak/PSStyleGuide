# Add a fail-closed cross-platform style-guide candidate validator

## Summary

Add one shared PowerShell validator/extractor, one caller-owned temporary
context lifecycle, and one permanent adversarial harness for generated
style-guide artifact candidates. The implementation must behave the same under
Windows PowerShell 5.1 and PowerShell 7 on Windows and Ubuntu.

The validator treats every caller path, artifact label, ZIP entry, and cleanup
claim as untrusted. It hashes and reads one continuously held archive stream,
validates the complete manifest before creating the candidate directory,
extracts only fresh ordinary files, and retains uncertain state rather than
recursively deleting it.

## Dependency

Implement only after **Make artifact generation byte-deterministic and
standardize repository text checkouts on LF** merges. Record and validate T1's
actual merge commit before work. This issue records its reviewed head and
requires T1B to consume its eventual merge commit; it does not claim to know
that future value.

The next issue, **Promote generated style-guide artifacts through a
least-privileged verified writer**, activates these scripts in workflows.
Nothing in this issue changes production workflow behavior.

## Affected files

Exactly these three files may change:

- `.github/workflows/Expand-StyleGuideCandidateArtifact.ps1` — add;
- `.github/workflows/Manage-StyleGuideCandidateInvocationContext.ps1` — add;
- `.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1` — add.

Each script must:

- declare `#Requires -Version 5.1`;
- contain exactly one script-level `.NOTES` line before its first function,
  `Version: 1.0.<final-material-edit-UTC-YYYYMMDD>.0`, validated by T1's
  timeless grammar, explicit expected-version, and baseline authoring-bump
  layers;
- remain an ordinary LF, BOM-less UTF-8 file; and
- pass the repository's PowerShell formatting/static checks.

Timeless parsing rejects missing, duplicate, malformed, impossible-date, or
function-level decoy versions without reading the clock; an old or future real
date is valid grammar. Consumers check exact expected script versions from the
same T1A commit/path/SHA as `unexpected-version`. Merge validation separately
checks new-file/final-edit date and bump/reset rules. Commit IDs and SHA-256
remain the immutable evidence.

## Public contracts

### Archive validator/extractor

`Expand-StyleGuideCandidateArtifact.ps1` is an advanced script with positional
binding disabled. Its raw boundary is exact:

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

Mandatory omission remains a binder interface error. Every *provided* value,
including null/empty/empty collection, reaches the same first production
validation block. Snapshot all eight `$PSBoundParameters` presence flags and
raw object references without formatting. Reject each provided
string-intended value in exact order: null; runtime type other than exactly
`System.String`; zero length; Unicode-whitespace-only; Unicode control; then
its parameter grammar. Do not cast/interpolate/trim/case-fold/enumerate/place
on the pipeline/call `ToString()`/pass to regex or filesystem APIs before the
type gate. A type error may report only parameter name and safely obtained
runtime type name.

After validation, path strings remain byte-for-character unchanged through
the path grammar; digest must match `\A[0-9A-Fa-f]{64}\z` before creating one
lowercase comparison copy; and each present label must match
`\A[1-9][0-9]{0,19}\z`. Omitted labels, determined only from the snapshot, map
to `unavailable`. Explicit null, empty, whitespace, control, `0`, leading zero,
sign, decimal/exponent, non-ASCII digit, or 21st digit rejects. Labels never
select an artifact, form a path/name, authorize bytes, affect cleanup, or
choose a fixture.

Place function definitions before the main entry point. When dot-sourced
through the ordinary PowerShell invocation context, define functions and
return before normal expansion. Do not add a test switch, environment
backdoor, or alternate expansion entry point.

### Caller invocation context

`Manage-StyleGuideCandidateInvocationContext.ps1` defines exactly:

- `New-StyleGuideCandidateInvocationContext`; and
- `Remove-StyleGuideCandidateInvocationContext`.

`New-StyleGuideCandidateInvocationContext` accepts one explicit
runner-controlled temporary parent. It returns a structured context containing
the normalized parent, invocation root, download directory, initially absent
candidate path, diagnostic label, and exact ownership metadata.

`Remove-StyleGuideCandidateInvocationContext` accepts that context, the
explicit ordinary paths owned by the completed invocation, and any primary
failure. It never infers ownership by recursive enumeration.

The archive helper remains independently distrustful of a context produced by
this companion script.

### Candidate-state cleanup

`Expand-StyleGuideCandidateArtifact.ps1` defines exactly one production
candidate cleanup function:

```text
Remove-StyleGuideCandidateInvocationState
```

The normal helper failure path and every `K-*` harness case invoke this exact
function. It accepts only `CandidateOwnershipState` and `PrimaryFailure`; there
is no envelope/journal/Boolean-disposed overload. It does not delegate
recursive deletion to the caller-context cleanup.

The helper creates and returns the same mutable object whose first
`PSTypeName` is exactly
`TerraformStyleGuide.StyleGuideCandidateOwnershipState.v1`:

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

Construct it in `NotCreated` before candidate creation, transition to `Active`
only after acquiring the fresh directory, and journal each ordinary file at
ownership acquisition. Success and failure return the same object reference.

## Requested changes

### 1. Normalize and classify paths

For every path:

1. reject wildcards, relative paths, ambiguous multiple resolutions, and
   non-filesystem providers;
2. accept native rooted or filesystem-provider-qualified absolute paths;
3. resolve to one deterministic absolute filesystem-provider path before
   calling .NET APIs;
4. use ordinal-ignore-case comparison on Windows and ordinal comparison on
   non-Windows;
5. use separator-aware strict-descendant checks; and
6. materialize each exact `Directory.EnumerateFileSystemEntries` result once
   before counting or inspecting it.

`Get-ChildItem` may support diagnostics only when called with `-LiteralPath`
and `-Force`; it may not establish an exact entry count.

### 2. Validate the complete path-component envelope

The archive helper must:

- require checkout and trusted-temporary roots to be existing ordinary
  directories;
- require the roots to be mutually non-overlapping;
- require download and candidate paths to be strict descendants of the trusted
  root and outside checkout;
- lexically inspect every existing component from volume/share root through
  each declared root, download directory/archive, candidate parent, and created
  candidate path;
- reject reparse points, symbolic links, junctions, volume mounts, dangling
  entries, type mismatches, and every attribute/resolution/enumeration failure;
- never follow a link merely to classify it; and
- repeat applicable component, containment, type, parent, and leaf checks
  before archive open, before candidate creation, and after extraction.

The supported model is a GitHub-hosted runner with runner-controlled ancestors,
one job-owned checkout, one job-owned trusted temporary root, and no competing
writer. Repeated validation narrows time-of-check/time-of-use risk; it is not
an OS-native directory-handle sandbox.

### 3. Acquire and remove caller-owned context safely

Creation must:

1. normalize the explicit parent to an existing ordinary non-reparse
   filesystem directory;
2. call `Path.GetRandomFileName()` for a child name;
3. prove no filesystem entry has that child name;
4. create without `-Force`;
5. verify the returned exact child is one ordinary non-reparse directory;
6. retry a documented finite number of times only after exhaustive
   reinspection proves an actual name collision;
7. fail immediately for permission, type, attribute, resolution, or
   classification errors;
8. create a separate ordinary download directory; and
9. return a candidate leaf path that has no filesystem entry.

Use run/artifact metadata only for diagnostics, never as ownership or
authorization.

Teardown must run after every ZIP, entry, and file stream is disposed. Before
deleting anything, it revalidates the complete context envelope and every
explicit owned entry. It removes only proven ordinary files and then empty
ordinary directories, nonrecursively and deepest first. It never follows,
wildcards, traverses, or recursively removes.

An unexpected, missing, unreadable, substituted, link, reparse, hidden, or
unjournaled entry stops teardown. Retain uncertain state and report the root,
phase, offending entry, cleanup exception, and primary failure without hiding
the primary failure.

### 4. Enforce parameter and diagnostic grammar first

Before filesystem/archive work:

- snapshot presence/raw references and apply the exact null/type/empty/
  whitespace/control gate to every provided value;
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

Diagnostics include safely available normalized roots/paths, expected digest,
actual digest after computation, retained archive path, supplied/omitted
labels, offending entry/destination, and preserved underlying error. Never log
artifact contents.

### 5. Use one validation order

The exact phase order is:

1. parameter/label grammar;
2. roots, all existing components, and root separation;
3. working-path containment/components;
4. exact download-directory content and archive-file type;
5. candidate-parent safety and candidate-leaf absence;
6. one retained archive stream open and SHA-256;
7. rewind that same stream, open ZIP, enforce limits, and validate manifest;
8. repeat component/containment/parent/leaf checks;
9. create candidate once and extract; and
10. exhaustively validate output bytes and filesystem state.

No phase before step 9 creates the candidate leaf.

### 6. Bind digest and ZIP processing to one stream

The download directory must contain exactly one top-level filesystem entry,
including hidden/system entries. It must be an ordinary non-reparse file; no
`.zip` extension is required.

After revalidating the path:

1. open the file exactly once with `FileMode.Open`, `FileAccess.Read`, and
   `FileShare.Read`;
2. require a readable, seekable stream;
3. hash that stream with `Get-FileHash -InputStream -Algorithm SHA256`;
4. require one valid 64-hex result;
5. compare expected/actual ordinally, ignoring case;
6. fail before `ZipArchive` construction on mismatch;
7. rewind the same stream to position zero;
8. construct one read-only `ZipArchive` with deliberate `leaveOpen`;
9. keep both objects alive through manifest validation/extraction; and
10. dispose ZIP before file stream and both before cleanup.

Do not hash by path and reopen, copy to another file/memory buffer, or accept a
`sha256:` prefix.

### 7. Validate exact manifest and resource limits

Before candidate creation, require exactly four root-level nondirectory entry
names using ordinal comparison:

```text
copilot-instructions.md
terraform.instructions.md
STYLE_GUIDE_CHAT.md
STYLE_GUIDE_FULL.md
```

Reject empty names, missing/extra entries, exact or case-insensitive
duplicates, `/` or `\`, nesting/traversal, leading slash/backslash, drive
qualification, directory entries, and file/directory collisions.

Enforce before extraction:

- exactly four entries;
- at most 8 MiB declared uncompressed length per entry;
- at most 32 MiB declared total uncompressed length;
- at most 32 MiB retained archive length; and
- no negative, overflowed, inconsistent, or unreadable length.

“At most” is inclusive. Accumulate declared and actual lengths with checked
64-bit arithmetic. Count actual copied bytes and stop on the first byte that
would exceed the same per-entry/total limits. A declared length is not trusted
proof of actual output. Tests generate large ordinary fixtures
streamingly/sparsely beneath the disposable context; do not commit large
expanded blobs. Use fixed reviewed raw ZIP bytes, with recorded SHA-256 and
construction rationale, only for metadata states `ZipArchive` cannot create.

### 8. Create and extract only fresh ordinary files

The candidate leaf must be absent until digest, ZIP, limits, and manifest pass.
Immediately before creation, exhaustively reject any file, directory, live
link/reparse point, or dangling link with the leaf name. Create once; never
delete/recreate or reuse.

For each permitted entry:

- compute one immediate-child destination with `GetFullPath`;
- prove it remains under candidate root;
- open with `FileMode.CreateNew`, write access, and no sharing;
- journal the path before/at successful ownership acquisition;
- copy only entry bytes; and
- dispose entry/destination streams deterministically.

Do not restore link information, Unix type/mode, Windows attributes,
timestamps, or any ZIP metadata. External attributes are ignored, not treated
as a safe destination type.

After extraction:

- repeat component and containment validation;
- enumerate exact candidate contents;
- require exactly the four expected ordinary non-reparse files;
- reject UTF-8 BOM bytes and every `0x0D` byte; and
- return the four normalized candidate paths plus the same Active
  `CandidateOwnershipState`; log only safe paths/ID/state, never contents.

### 9. Fail closed during candidate cleanup

`Remove-StyleGuideCandidateInvocationState` treats its lifecycle object as
untrusted. Before filesystem work require exact PSTypeName/property set/types,
nonempty ID, allowed state, immutable envelope, journal schema/order/unique
paths, Owned flags, attempt count, and summary consistency. Missing, forged,
copied-loose, reactivated, path/ID-mutated, or contradictory state is
`cleanup/candidate-state-invalid` with zero filesystem/deletion calls.

Transitions are closed:

1. `NotCreated`: revalidate the trusted parent and materialize its immediate
   entries once. Exact candidate-leaf absence moves to `Disposed` with an empty
   cleanup. Any matching/unclassifiable entry moves to `RetainedUncertain`;
   delete nothing.
2. `Active`: perform one complete pre-deletion pass over envelope, exact
   immediate-child equality, journaled ordinary-file identity, and
   parent/leaf relationships. Any uncertainty moves to `RetainedUncertain`
   before deletion. Only a complete pass increments attempt, enters
   `CleanupInProgress`, removes journaled files nonrecursively in safe order,
   and removes the proven-empty candidate directory. Complete success sets all
   journal `Owned=false`, retains acquisition evidence, records absent leaf,
   and moves to `Disposed`. Inspection/deletion failure stops immediately,
   records removed/retained entries, and moves to `RetainedUncertain`; no
   retry.
3. `Disposed`: validate only the in-memory closed object schema and require all
   entries `Owned=false`. Return the identical object, attempt, journal, and
   summary with success and **zero provider, path, filesystem, or native
   calls**. Do not inspect the released parent or leaf; any new occupant is
   outside this capability.
4. Entry in `CleanupInProgress` or `RetainedUncertain` returns stable nonzero
   `cleanup/candidate-state-retained`, with **zero provider, path, filesystem,
   native, or deletion calls**.

During the one Active cleanup, parent enumeration—not
`File.Exists`/`Directory.Exists`—defines absence. Nothing is followed or
recursively removed. After the transition, caller-context cleanup may continue
only from the exact returned `Disposed` object and never reinspects the
released candidate name. Any other candidate result makes the invocation
context `RetainedUncertain`. Primary failure remains primary, with
candidate/context cleanup outcomes attached separately.

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

Every rejection has zero deletion and records CandidateId, transition, attempt
count, exact removed/retained sequence, sentinel, and context consequence.
Terminal repeat rows additionally use provider/path/filesystem/native spies and
require an exact zero-call vector. `T1A-K-04` remains the primary-failure plus
partial-cleanup-failure case.

### 10. Implement the permanent stable-ID harness

`Test-Expand-StyleGuideCandidateArtifact.ps1` accepts mandatory scalar
`HelperPath` and `ContextManagerPath`. It resolves both exact tracked scripts
once as ordinary non-reparse files, requires their expected version markers,
and uses only those normalized absolute paths for child-script invocations.
For each path, reject missing, relative, wildcard (including a
multi-match-capable wildcard), non-filesystem-provider, wrong-type, untracked,
and reparse input. A
filesystem-provider-qualified absolute path is valid. The harness creates every
fixture beneath one context produced by the exact supplied context manager and
cleans only proven owned fixture state in `finally`.

The harness may dot-source the helper once for the deterministic cleanup cases
and call `Remove-StyleGuideCandidateInvocationState`. It may not reimplement
path, digest, archive, manifest, extraction, or cleanup logic.

Every case emits its stable ID, platform, phase, expected/actual outcome,
initial candidate state, final candidate and caller-context state before
harness teardown, required diagnostics, and outside-sentinel result. The
harness contains matching machine-readable metadata and fails for a missing,
duplicate, unexpected, or multiply emitted applicable ID. IDs are append-only:
do not renumber a surviving behavior.

Unless a row states success, its exact oracle is a nonzero failure in the named
phase, no unproved deletion, unchanged outside sentinel, and candidate/context
state exactly as stated. Parameter/download failures perform no archive work.

| ID | SemanticCase | Fixture/invocation | Exact pre-teardown oracle |
| --- | --- | --- | --- |
| T1A-V-01 | `archive.valid.exact-four-files` | exact four-entry valid archive | success; four exact files; both production cleanups succeed |
| T1A-V-02 | `archive.valid.external-attributes-ignored` | valid entries with symlink-like external attributes | success; attributes ignored; four ordinary files |
| T1A-P-01 | `path.containment.checkout-sibling-prefix-rejected` | checkout sibling-prefix path | `containment`; candidate absent |
| T1A-P-02 | `path.provider.filesystem-qualified-accepted` | filesystem-provider-qualified absolute inputs | success; normalized paths equal native-path control |
| T1A-D-01 | `digest.mismatch.labels-supplied` | digest mismatch with all labels supplied | `digest`; candidate absent; all labels in diagnostics |
| T1A-D-02 | `digest.mismatch.labels-omitted` | same mismatch with all labels omitted | `digest`; candidate absent; labels are `unavailable` |
| T1A-D-03 | `digest.grammar.short-rejected` | 63-hex expected digest | `parameter`; candidate absent; archive unopened |
| T1A-D-04 | `digest.grammar.nonhex-rejected` | 64 characters containing nonhex | `parameter`; candidate absent; archive unopened |
| T1A-D-05 | `digest.grammar.prefixed-rejected` | `sha256:`-prefixed digest | `parameter`; candidate absent; archive unopened |
| T1A-Z-01 | `archive.invalid.header-rejected` | invalid ZIP header with matching digest | `archive/invalid-zip`; candidate absent |
| T1A-Z-02 | `archive.truncated.rejected` | truncated otherwise-valid ZIP with matching digest | `archive/truncated-zip`; candidate absent |
| T1A-M-01 | `manifest.entry.required-missing` | one required entry missing | `manifest`; candidate absent |
| T1A-M-02 | `manifest.entry.extra-rejected` | one extra entry | `manifest`; candidate absent |
| T1A-M-03 | `manifest.name.exact-duplicate-rejected` | exact duplicate name | `manifest`; candidate absent |
| T1A-M-04 | `manifest.name.case-collision-rejected` | case-insensitive name collision | `manifest`; candidate absent |
| T1A-M-05 | `manifest.name.forward-slash-nesting-rejected` | nested name using `/` | `manifest`; candidate absent |
| T1A-M-06 | `manifest.name.backslash-nesting-rejected` | nested name using `\` | `manifest`; candidate absent |
| T1A-M-07 | `manifest.name.forward-slash-traversal-rejected` | traversal name using `/` | `manifest`; candidate absent |
| T1A-M-08 | `manifest.name.backslash-traversal-rejected` | traversal name using `\` | `manifest`; candidate absent |
| T1A-M-09 | `manifest.name.leading-forward-slash-rejected` | leading `/` | `manifest`; candidate absent |
| T1A-M-10 | `manifest.name.leading-backslash-rejected` | leading `\` | `manifest`; candidate absent |
| T1A-M-11 | `manifest.name.drive-qualified-rejected` | drive-qualified name | `manifest`; candidate absent |
| T1A-M-12 | `manifest.entry.directory-rejected` | directory entry | `manifest`; candidate absent |
| T1A-M-13 | `manifest.entry.file-directory-collision-rejected` | file/directory collision | `manifest`; candidate absent |
| T1A-M-14 | `manifest.name.raw-empty-rejected` | fixed reviewed raw ZIP with empty name | `manifest`; candidate absent; fixture SHA recorded |
| T1A-E-01 | `path.download.outside-trusted-root-rejected` | download directory outside trusted root | `containment/download-outside`; candidate absent |
| T1A-E-02 | `path.roots.equal-rejected` | checkout and trusted roots equal | `root`; candidate absent |
| T1A-E-03 | `path.roots.checkout-contains-trusted-rejected` | checkout contains trusted root | `root`; candidate absent |
| T1A-E-04 | `path.roots.trusted-contains-checkout-rejected` | trusted root contains checkout | `root`; candidate absent |
| T1A-E-05 | `path.working.relative-rejected` | relative working path | `parameter/path-not-fully-qualified`; candidate absent |
| T1A-E-06 | `path.provider.nonfilesystem-rejected` | non-filesystem provider path | `parameter`; candidate absent |
| T1A-E-07 | `path.case.windows-alias-accepted` | Windows case variation of the same existing path envelope | Windows only: pass/status 0/`complete`; four valid files; candidate cleanup succeeds; context `Disposed`; sentinel unchanged |
| T1A-E-08 | `path.case.linux-sibling-rejected` | Linux differently cased sibling outside trusted root | Linux only: fail/status 1/`containment/case-sensitive-outside`; candidate absent; context cleanup reaches `Disposed`; sentinel unchanged |
| T1A-E-09 | `path.root.reparse-rejected` | declared root is a link/reparse component | `root/root-reparse`; candidate absent |
| T1A-E-10 | `path.component.reparse-rejected` | below-root link/reparse component | fail/status 1/`containment/component-reparse`; candidate absent; context cleanup reaches `Disposed` |
| T1A-E-11 | `download.hidden-extra-entry-rejected` | hidden extra download entry | `download/extra-entry`; candidate absent |
| T1A-E-12 | `path.root.wildcard-rejected` | wildcard root path | `parameter/path-wildcard`; candidate absent |
| T1A-E-13 | `path.wildcard.multi-match-rejected` | wildcard path capable of multiple matches under a resolving API | fail/status 1/`parameter/path-wildcard` before resolution/context creation; candidate absent |
| T1A-E-14 | `path.checkout.missing-rejected` | checkout root missing | fail/status 1/`root/checkout-missing`; candidate absent |
| T1A-E-15 | `path.checkout.not-directory-rejected` | checkout root is not a directory | fail/status 1/`root/checkout-not-directory`; candidate absent |
| T1A-E-16 | `path.trusted.missing-rejected` | trusted root missing | fail/status 1/`root/trusted-missing`; candidate absent |
| T1A-E-17 | `path.trusted.not-directory-rejected` | trusted root is not a directory | fail/status 1/`root/trusted-not-directory`; candidate absent |
| T1A-E-18 | `path.download.missing-rejected` | download directory missing | fail/status 1/`download/directory-missing`; candidate absent |
| T1A-E-19 | `path.download.not-directory-rejected` | download path is not a directory | fail/status 1/`download/not-directory`; candidate absent |
| T1A-E-20 | `path.archive.missing-rejected` | retained archive missing | fail/status 1/`download/archive-missing`; candidate absent |
| T1A-E-21 | `path.archive.not-file-rejected` | retained archive is not an ordinary file | fail/status 1/`download/archive-not-file`; candidate absent |
| T1A-E-22 | `path.candidate-parent.missing-rejected` | candidate parent missing | fail/status 1/`destination/parent-missing`; candidate absent |
| T1A-E-23 | `path.candidate-parent.not-directory-rejected` | candidate parent is not a directory | fail/status 1/`destination/parent-not-directory`; candidate absent |
| T1A-E-24 | `path.candidate.outside-trusted-root-rejected` | candidate path outside trusted root | `containment/candidate-outside`; candidate absent |
| T1A-E-25 | `path.root.relative-rejected` | relative root path | `parameter/path-not-fully-qualified`; candidate absent |
| T1A-E-26 | `path.ancestor.reparse-rejected` | ancestor below volume/share root is link/reparse | `root/ancestor-reparse`; candidate absent |
| T1A-E-27 | `download.system-extra-entry-rejected` | system extra download entry | `download/extra-entry`; candidate absent |
| T1A-E-28 | `path.working.wildcard-rejected` | wildcard working path | `parameter/path-wildcard`; candidate absent |
| T1A-L-01 | `destination.preexisting.ordinary-file-retained` | preexisting ordinary candidate file | `destination`; leaf unchanged |
| T1A-L-02 | `destination.preexisting.directory-retained` | preexisting candidate directory | `destination`; leaf unchanged |
| T1A-L-03 | `destination.preexisting.live-reparse-retained` | live link/reparse candidate leaf | `destination`; target and leaf unchanged |
| T1A-L-04 | `destination.preexisting.dangling-link-retained` | dangling link candidate leaf | `destination`; link unchanged |
| T1A-B-01 | `output.bytes.utf8-bom-rejected` | extracted file begins with UTF-8 BOM | `post-extraction`; owned partial removed |
| T1A-B-02 | `output.bytes.carriage-return-rejected` | extracted file contains `0x0D` | `post-extraction`; owned partial removed |
| T1A-K-01 | `cleanup.candidate.unjournaled-entry-retained` | unjournaled ordinary candidate child | `cleanup`; candidate retained; delete nothing further |
| T1A-K-02 | `cleanup.candidate.reparse-substitution-retained` | supported link/reparse substitution | `cleanup`; candidate retained; target unchanged |
| T1A-K-03 | `cleanup.candidate.repeat-disposed` | repeated candidate cleanup after safe removal | success/no-op; zero provider/path/filesystem/native calls |
| T1A-K-04 | `cleanup.candidate.primary-and-cleanup-failure` | primary failure then candidate-cleanup failure | both reasons reported; uncertain state retained |
| T1A-C-01 | `cleanup.context.normal-disposal` | normal caller-context teardown | success; journaled entries removed deepest first |
| T1A-C-02 | `cleanup.context.repeat-disposed` | repeated caller-context teardown | success/no-op under disposed-context contract |
| T1A-C-03 | `cleanup.context.unjournaled-entry-retained` | unjournaled ordinary context entry | `cleanup`; entire uncertain context retained |
| T1A-C-04 | `cleanup.context.reparse-substitution-retained` | link/reparse substitution in context | `cleanup`; context/target retained unchanged |
| T1A-C-05 | `cleanup.context.journaled-entry-missing` | missing journaled context entry | `cleanup/context-entry-missing`; no further deletion |
| T1A-C-06 | `cleanup.context.primary-and-cleanup-failure` | primary failure then caller-cleanup failure | primary prominent; cleanup and retained root reported |
| T1A-C-07 | `cleanup.context.partial-journal` | proven partial ordinary ownership journal | success; only journaled entries removed nonrecursively |
| T1A-C-08 | `cleanup.context.candidate-before-context` | candidate cleanup then context cleanup | success; exact production lifecycles invoked in order |
| T1A-C-09 | `cleanup.context.journaled-entry-unreadable` | unreadable journaled context entry | `cleanup/context-entry-unreadable`; no further deletion |
| T1A-R-01 | `limit.entry.below-8mib-accepted` | entry one byte below 8 MiB | pass/status 0/`complete`; four valid files; candidate and context cleanups succeed; context `Disposed` |
| T1A-R-02 | `limit.entry.at-8mib-accepted` | entry exactly 8 MiB | pass/status 0/`complete`; four valid files; candidate and context cleanups succeed; context `Disposed` |
| T1A-R-03 | `limit.entry.above-8mib-rejected` | declared entry one byte above 8 MiB | `manifest`; candidate absent |
| T1A-R-04 | `limit.actual-entry-overrun-rejected` | actual entry exceeds permitted/declared bytes | `extraction`; stop at first excess; owned partial removed |
| T1A-R-05 | `limit.declared-total.below-32mib-accepted` | declared total one byte below 32 MiB | pass/status 0/`complete`; four valid files; candidate and context cleanups succeed; context `Disposed` |
| T1A-R-06 | `limit.declared-total.at-32mib-accepted` | declared total exactly 32 MiB | pass/status 0/`complete`; four valid files; candidate and context cleanups succeed; context `Disposed` |
| T1A-R-07 | `limit.declared-total.above-32mib-rejected` | declared total one byte above 32 MiB | `manifest`; candidate absent |
| T1A-R-08 | `limit.actual-total-overrun-rejected` | actual cumulative output exceeds 32 MiB | `extraction`; stop at first excess; owned partial removed |
| T1A-R-09 | `limit.archive.at-32mib-accepted` | retained archive exactly 32 MiB | pass/status 0/`complete`; four valid files; candidate and context cleanups succeed; context `Disposed` |
| T1A-R-10 | `limit.archive.above-32mib-rejected` | retained archive one byte above 32 MiB | pre-ZIP limit failure; candidate absent |
| T1A-R-11 | `limit.raw-zip.negative-length-rejected` | raw ZIP with negative length state | `manifest/negative-length`; candidate absent; fixture SHA recorded |
| T1A-R-12 | `limit.length-arithmetic.overflow-rejected` | length arithmetic overflow fixture | `manifest`; checked overflow; candidate absent |
| T1A-R-13 | `limit.archive.below-32mib-accepted` | retained archive one byte below 32 MiB | pass/status 0/`complete`; four valid files; candidate and context cleanups succeed; context `Disposed` |
| T1A-R-14 | `limit.raw-zip.inconsistent-length-rejected` | raw ZIP with inconsistent length fields | `manifest/inconsistent-length`; candidate absent; fixture SHA recorded |
| T1A-W-01 | `download.entry-count.zero-rejected` | empty download directory | `download`; candidate absent |
| T1A-W-02 | `download.entry-count.two-rejected` | two top-level download entries | `download`; candidate absent |
| T1A-W-03 | `download.entry.directory-rejected` | directory as sole download entry | `download`; candidate absent |
| T1A-W-04 | `download.entry.reparse-rejected` | link/reparse as sole download entry | `download`; target unchanged; candidate absent |
| T1A-W-05 | `download.entry.unreadable-rejected` | unreadable download entry | `download/entry-unreadable`; candidate absent |
| T1A-W-06 | `download.entry.unclassifiable-rejected` | unclassifiable download entry | `download/entry-unclassifiable`; candidate absent |
| T1A-S-01 | `harness.input.helper-missing-rejected` | missing helper script path | fail/status 1/`harness-input/script-missing`; no context; neither supplied script invoked; sentinel unchanged |
| T1A-S-02 | `harness.input.helper-wildcard-rejected` | wildcard helper path | fail/status 1/`harness-input/path-wildcard`; no context; neither supplied script invoked; sentinel unchanged |
| T1A-S-03 | `harness.input.helper-nonfilesystem-rejected` | non-filesystem helper path | fail/status 1/`harness-input/path-provider`; no context; neither supplied script invoked; sentinel unchanged |
| T1A-S-04 | `harness.input.helper-multimatch-rejected` | multi-match-capable wildcard helper path | fail/status 1/`harness-input/path-wildcard`; no resolution/context; neither script invoked |
| T1A-S-05 | `harness.input.helper-reparse-rejected` | reparse helper script | fail/status 1/`harness-input/script-reparse`; no context; neither script invoked; target unchanged |
| T1A-S-06 | `harness.input.context-missing-rejected` | missing context-manager path | fail/status 1/`harness-input/script-missing`; no context; neither supplied script invoked; sentinel unchanged |
| T1A-S-07 | `harness.input.context-wildcard-rejected` | wildcard context-manager path | fail/status 1/`harness-input/path-wildcard`; no context; neither supplied script invoked; sentinel unchanged |
| T1A-S-08 | `harness.input.context-nonfilesystem-rejected` | non-filesystem context-manager path | fail/status 1/`harness-input/path-provider`; no context; neither supplied script invoked; sentinel unchanged |
| T1A-S-09 | `harness.input.context-multimatch-rejected` | multi-match-capable wildcard context-manager path | fail/status 1/`harness-input/path-wildcard`; no resolution/context; neither script invoked |
| T1A-S-10 | `harness.input.context-reparse-rejected` | reparse context-manager script | fail/status 1/`harness-input/script-reparse`; no context; neither script invoked; target unchanged |
| T1A-S-11 | `harness.input.provider-qualified-tracked-scripts-accepted` | both scripts provider-qualified, exact tracked, and versioned | pass/status 0 through the `T1A-V-01` control; four valid files; context `Disposed` |
| T1A-S-12 | `harness.input.helper-untracked-rejected` | untracked ordinary helper script | fail/status 1/`harness-input/script-untracked`; no context; neither supplied script invoked |
| T1A-S-13 | `harness.input.context-untracked-rejected` | untracked ordinary context-manager script | fail/status 1/`harness-input/script-untracked`; no context; neither supplied script invoked |
| T1A-X-01 | `label.artifact.empty-rejected` | explicit empty `ArtifactId` | `parameter`; candidate absent |
| T1A-X-02 | `label.run-id.empty-rejected` | explicit empty `RunId` | `parameter`; candidate absent |
| T1A-X-03 | `label.run-attempt.empty-rejected` | explicit empty `RunAttempt` | `parameter`; candidate absent |
| T1A-X-04 | `label.artifact.null-rejected` | explicit null `ArtifactId` | `parameter`; candidate absent |
| T1A-X-05 | `label.run-id.null-rejected` | explicit null `RunId` | `parameter`; candidate absent |
| T1A-X-06 | `label.run-attempt.null-rejected` | explicit null `RunAttempt` | `parameter`; candidate absent |
| T1A-X-07 | `label.valid-text-preserved` | valid nonempty labels | selected failure preserves exact label text |
| T1A-X-08 | `label.artifact.array-rejected` | array supplied as `ArtifactId` | fail/status 1/`parameter/label-not-scalar-string`; no filesystem work; candidate absent |
| T1A-X-09 | `label.run-id.array-rejected` | array supplied as `RunId` | fail/status 1/`parameter/label-not-scalar-string`; no filesystem work; candidate absent |
| T1A-X-10 | `label.run-attempt.array-rejected` | array supplied as `RunAttempt` | fail/status 1/`parameter/label-not-scalar-string`; no filesystem work; candidate absent |
| T1A-X-11 | `label.artifact.object-rejected` | object supplied as `ArtifactId` | fail/status 1/`parameter/label-not-scalar-string`; no filesystem work; candidate absent |
| T1A-X-12 | `label.run-id.object-rejected` | object supplied as `RunId` | fail/status 1/`parameter/label-not-scalar-string`; no filesystem work; candidate absent |
| T1A-X-13 | `label.run-attempt.object-rejected` | object supplied as `RunAttempt` | fail/status 1/`parameter/label-not-scalar-string`; no filesystem work; candidate absent |

Required postconditions:

- failures before helper creation leave candidate absent;
- preexisting leaves remain unmodified/unfollowed;
- ordinary helper-owned partial state is removed only by the production cleanup
  function;
- unsafe/ownership-uncertain state is retained;
- unrelated sentinels remain unchanged; and
- digest mismatch occurs before ZIP construction.

Both production cleanup lifecycles must be exercised independently and in one
combined failure path. A primary failure followed by cleanup failure reports
both without replacing the primary reason.

A narrowly justified link-primitive skip names the case, platform, and reason
and is not a pass. At least one real link/reparse rejection must execute on
each OS family.

### 11. Apply one raw public path grammar at every script boundary

The public path inventory is closed:

| Boundary | Raw path parameters |
| --- | --- |
| archive helper | `CheckoutRoot`, `TrustedTemporaryRoot`, `DownloadDirectory`, `CandidateDirectory`, and the retained archive path from exact enumeration |
| context creation | runner-controlled temporary parent |
| context cleanup | every explicit journaled owned path |
| harness | `HelperPath`, `ContextManagerPath` |

Every public path-looking parameter is declared `[object]` with the applicable
`[Parameter(...)]`, `[AllowNull()]`, `[AllowEmptyString()]`, and
`[AllowEmptyCollection()]`; the harness uses mandatory named parameters.
Preserve each raw value as one object reference and do not let PowerShell
enumerate or join it. Validate in this order before any filesystem work:

1. null → status 1, `parameter/path-null`;
2. non-string scalar or collection → `parameter/path-type`;
3. empty → `parameter/path-empty`;
4. Unicode whitespace-only → `parameter/path-whitespace`;
5. NUL/C0/C1 control or malformed provider syntax →
   `parameter/path-malformed`;
6. unescaped PowerShell wildcard grammar → `parameter/path-wildcard`;
7. relative, drive-relative, root-relative, `~`, or otherwise not fully
   qualified → `parameter/path-not-fully-qualified`; and
8. unsupported/nonfilesystem provider → `parameter/path-provider`.

Accept only a platform-native fully qualified filesystem path or exactly one
`FileSystem::`-qualified fully qualified path. Reject aliases/custom PSDrives.
Use `GetUnresolvedProviderPathFromPSPath` with provider/drive out values,
require `FileSystem`, and normalize once. This API returns one unresolved
string; production code must not call a resolving/multi-match API. Every
grammar rejection creates no context/directory/archive/candidate, attempts no
cleanup of unowned state, and leaves the outside sentinel unchanged.

Structured context/candidate-state/journal inputs remain `[object]` and must
pass exact first `PSTypeName`, runtime type, closed property set/type, array
shape, and lifecycle consistency before any property or element access.
Hashtable/`PSCustomObject` substitution and PowerShell collection flattening
are not accepted accidentally. `PrimaryFailure` remains an `ErrorRecord`,
`Exception`, or explicit null under the stated contract and is never converted
to text to decide cleanup/status.

The atomic raw-boundary catalog gives every parameter its own null, integer,
Boolean, one-element array, two-element array, empty array, hashtable,
`PSCustomObject`, `StringBuilder`, empty, whitespace-only, and control case.
Digest adds 63/65 length and nonhex classes; each optional label adds omission,
zero, leading zero, sign, non-ASCII digit, and overlength. Each case proves its
one phase/subreason, no filesystem/archive side effect, no attacker-object
`ToString()` call, bounded diagnostics, and edition parity.

### 12. Publish the invocation-context schema and lifecycle

The returned object's first `PSTypeName` is exactly
`TerraformStyleGuide.StyleGuideCandidateInvocationContext.v1`, with this
ordered closed schema:

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

Each journal entry's first `PSTypeName` is
`TerraformStyleGuide.StyleGuideCandidateOwnershipEntry.v1` and its closed
properties are contiguous unique `Sequence [uint32]`, `Kind [string]`
(`File|Directory`), normalized `Path [string]`, `Acquisition [string]`, and
`Owned [bool]`. Journal only actually acquired entries; cleanup is deepest
first then descending sequence. Choosing `CandidateDirectoryPath` does not own
it.

Cleanup treats the object as untrusted and validates type names, exact property
sets/types, schema/state/ID, journal order, path relationships, and current
filesystem envelope before deletion. Its transitions are:

- `Active` → `CleanupInProgress` before deletion → `Disposed` only after every
  owned entry is safely removed and the invocation root is proven absent;
- any inspection/ownership/deletion/summary failure →
  `RetainedUncertain`;
- a valid returned `Disposed` object is success/no-op with the identical
  object/fields and zero filesystem calls;
- entry in `CleanupInProgress` or `RetainedUncertain` is a stable nonzero
  retained-state result with zero deletion; and
- missing/unknown/forged schema/state is invalid-context failure with zero
  filesystem calls.

`CleanupSummary` records context ID, prior/final state, attempts, ordered
removed/retained paths, primary failure, cleanup result, and safe offending
reason. It contains no secret content. Mutate and return the same object;
callers replace their reference with it. Context metadata is not cryptographic
authorization, so every Active cleanup revalidates actual ownership.

### 13. Make the case catalog and results structurally atomic

The normative catalog version is `T1A-CASES-v1`; its immutable closed oracle
dictionary is `T1A-ORACLES-v1`. The 118-row table in section 10, the 13 new
IDs in the candidate-lifecycle table in section 9 (`K-05` through `K-17`; the
repeated `K-03` is one physical row), and the eight `I` rows below are the sole
**139-row physical allocation**. There is no range record. Each ID maps
literally to one materialized profile named `T1A-ORACLE-<ID>`; for example,
`T1A-V-01` maps only to `T1A-ORACLE-T1A-V-01`. Every materialized profile
copies the row's exact fixture/invocation and singular oracle and expands all
remaining fields below before the issue is filed. Every row has exact fields:

```text
Id SemanticCase Applicability Fixture InitialState OracleProfile
ExpectedResult ExpectedStatus ExpectedPhase ExpectedSubreason
PreCleanupCandidateState FinalCandidateState FinalContextState
CleanupSequence ExpectedDiagnostics SentinelState SourceRepositoryState
```

Emitted records repeat every expected field and add corresponding `Actual*`
fields, exact fixture parameters, runtime/edition/platform, and
`HarnessVerdict (pass|fail|skip)`. A correctly observed production rejection
is `ExpectedResult: rejection`, `ExpectedStatus: 1`,
`HarnessVerdict: pass`; it is not a failed test. Applicability skip uses
`ExpectedResult: skip`, `ExpectedStatus: null`, `HarnessVerdict: skip` and
earns no pass.

Candidate states are exactly `not-applicable|absent|four-valid-files|
owned-partial|preexisting-unchanged|uncertain-retained`; context states are
`not-created|Active|Disposed|RetainedUncertain`. Cleanup is an ordered array
containing only `candidate-cleanup|candidate-cleanup-noop|context-cleanup|
context-cleanup-noop|none`. Slash lists, “then,” “applicable,” `or`, or prose
alternatives are invalid metadata.

The following oracle-family descriptions constrain those already materialized
per-row profiles; they are not catalog rows, dynamic generators, or permission
to choose a profile during implementation:

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

Each materialized profile declares all fixed fields and only the literal
variations in its physical row. Unknown fields/profiles, a profile name that
does not equal the row's literal bijection, fixed-field override, missing
variation, contradictory state, or prose alternative fails static catalog
validation. All 139 profiles and ID/key meanings are frozen by this issue; new
behavior appends a new row/profile.

Each row mutates one parameter, path, separator, platform, leaf, or outcome
only. The physical tables contain no `or` fixture and no ordinal
`*.case-NN` semantic key. P1A must split grouped evidence before it can satisfy
multiple Terraform keys.

Startup expands profiles/rows, validates schema/unique sets, and computes exact
applicable `(ID,runtime)` pairs. Completion requires one complete record for
every pair and none outside it. Mutation tests independently prove missing,
duplicate, unexpected, and multiply emitted results fail. Retain profile/
catalog versions, canonical expanded SHA-256, profile/applicability/expected
result counts, and per-runtime pass/fail/skip totals.

### 14. Use repository-local IDs and shared semantic identities

Every Terraform ID in the table is namespaced `T1A-`. Every row/result also
contains the explicit unique semantic key shown in the table, matching
`^[a-z][a-z0-9]*(\.[a-z][a-z0-9-]*)+$`. IDs and keys are opaque,
append-only, and never changed/reused after merge.

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

Reciprocal equality means exact equality of semantic key, fixture,
applicability, result, terminal phase/subreason/status, candidate/context
states, diagnostics, sentinel, and cleanup sequence. The P1A↔T1A matrix records
`SemanticCase`, immutable P commit/local ID/evidence, immutable T commit/local
ID/evidence, classification (`same|intentional difference|blocker`), and
rationale. A grouped, missing, or divergent P row is a blocker, not an assumed
oracle. Runtime never downloads or executes the other repository.

Run each catalog-integrity row against a disposable mutated catalog, never by
changing the authoritative in-memory catalog.

### 15. Prove both supplied scripts are the exact HEAD/index/working blobs

The harness derives its trusted repository root from the ordinary non-reparse
`.github/workflows` `$PSScriptRoot` by exactly two parents; it never trusts the
current directory or an ambient Git root. Launch Git directly with argument
arrays/raw streams, remove or reject `GIT_DIR`, `GIT_WORK_TREE`,
`GIT_INDEX_FILE`, object/alternate-object, and pathspec-mode variables, and set
child-only `GIT_LITERAL_PATHSPECS=1`, `GIT_OPTIONAL_LOCKS=0`. Every command uses
`--no-replace-objects --no-pager -C <trusted-root>`. Record Git path/version.

Require raw stdout exactly for:

```text
git ... rev-parse --is-inside-work-tree
git ... rev-parse --show-prefix
git ... rev-parse --show-object-format=storage
git ... rev-parse --verify HEAD^{commit}
```

The first is `true` plus LF, prefix is one empty LF record, object format is
`sha1|sha256`, and HEAD is one full lowercase 40/64-hex commit. Normalize each
raw public script path once, compare to its exact absolute role destination,
then map—not derive—it to:

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

Parse NUL records from `BaseStream`. Tree output is exactly one
`100644 blob <full-oid>\t<exact-path>\0`; index output is exactly one
`100644 <same-oid> 0\t<exact-path>\0`; no conflict stage/duplicate/trailing
bytes are allowed. `ls-files` status 1/no record is `script-untracked`; every
other unexpected nonzero/start error is `git-tool-failure`. The no-filter
working OID is one LF-terminated full OID equal to HEAD/index; it never uses
`-w`, filters, conversion, or index bytes as a working-file substitute.

Both roles must pass completely before either is dot-sourced/invoked. Retain
only normalized role paths, OIDs, and expected versions. Immediately before
each later invocation repeat ordinary/component identity and no-filter OID.
Diagnostics identify fixed role/command/status/structural reason and safe OIDs,
not raw output/path/content/environment/stderr.

Keep `T1A-S-12`/`13` for untracked roles and append atomic rows for HEAD/index
absence, staged and unstaged replacement, conflict stage, wrong mode/nonblob,
duplicate/truncated/malformed records, path mismatch, abbreviated/wrong-format
OID, expected status 1, unexpected status 2, and start failure. Disposable
repos include spaces, tabs/newlines, leading dash, wildcard/pathspec-magic,
quotes, and non-ASCII to prove literal fixed selection.

## Reciprocal PSStyleGuide comparison

At implementation start and before merge, compare the then-current
PSStyleGuide **candidate-validation layer** and this issue. Record the exact PS
commit and current location: the P1 candidate-validation section or its
eventual P1A identifier. Compare:

- public parameters and omission/empty rules;
- archive identity and digest;
- full-component path security;
- manifest/limits/extraction;
- caller context and both cleanup lifecycles;
- diagnostics/stable IDs/skips/postconditions; and
- platform/edition support.

For each row record PS candidate-layer evidence, Terraform evidence, status
(`same`, `intentional difference`, `blocker`), and rationale. Repository paths,
manifest filenames/bytes, and workflow topology may differ intentionally.
Unexplained security/error behavior differences block merge. The semantic
layer name remains stable if PS planning files are renamed or split.

Store the completed matrix in the pull request or a tracked planning artifact.
The repositories remain self-contained; do not introduce a shared runtime
package.

## Validation

Run the exact tracked harness against the exact tracked helper under:

- Windows PowerShell exactly 5.1 on Windows;
- PowerShell 7 on Windows; and
- PowerShell 7 on Ubuntu.

Use clean disposable clones/worktrees and record script versions, executable
paths, editions, OS versions, Git versions, case totals, skips, and duration.
All mandatory applicable IDs must report exactly one result.

Also perform static checks proving:

- no recursive/wildcard deletion in either production script;
- no automatic ZIP extraction action/API;
- no ambient root derivation from current directory or GitHub environment;
- one definition of each exact cleanup function;
- normal helper and harness call the same candidate cleanup;
- the harness resolves the supplied helper and context-manager paths once and
  invokes only those exact tracked versions;
- every exact enumeration includes hidden/system entries;
- only the three affected files changed/staged; and
- generator outputs/workflows remain unchanged.

If hosted cross-platform evidence needs a temporary workflow, use a uniquely
named branch/workflow for evidence, remove it before the final commit, and
prove it is absent from the final changed/staged path set.

## Acceptance criteria

- [ ] The helper, context lifecycle, and harness have versioned PowerShell 5.1
      compatible implementations.
- [ ] Timeless marker parsing, exact expected-version identity, and
      baseline-to-staged authoring progression pass independent cases.
- [ ] Every provided public raw value reaches one production type/empty/
      whitespace/control/grammar gate with no binder conversion, enumeration,
      attacker `ToString()`, or pre-gate side effect.
- [ ] Caller-root acquisition proves new ownership with bounded
      collision-only retry.
- [ ] Both production cleanup paths are nonrecursive, journal-based, and retain
      uncertain state.
- [ ] The archive is opened once, hashed as one stream, rewound, and parsed as
      the same stream.
- [ ] Digest mismatch precedes ZIP construction and candidate creation.
- [ ] Complete path-component, root-separation, containment, link, type, and
      exact-download checks pass on Windows and Ubuntu.
- [ ] Manifest and resource limits pass before candidate creation.
- [ ] Extraction creates only four fresh ordinary files and restores no ZIP
      metadata.
- [ ] Post-extraction BOM/CR/type/content checks pass.
- [ ] Every mandatory stable ID has one explicit oracle and pre-teardown
      postcondition.
- [ ] `T1A-CASES-v1` exactly expands `T1A-ORACLES-v1`; every machine-readable
      atomic row/result has singular expected/actual fields, profile, behavior
      key, and one applicable-runtime result.
- [ ] Catalog mutation cases reject missing/duplicate/changed IDs, semantic
      keys, mappings, profiles, counterpart classifications, and results.
- [ ] Declared and actual resource boundaries pass below/exact cases and reject
      above/overflow/deceptive cases as specified.
- [ ] Both cleanup lifecycles pass independent and combined
      primary-plus-cleanup-failure cases.
- [ ] Candidate ownership transitions are exactly
      NotCreated/Active/CleanupInProgress/Disposed/RetainedUncertain; repeated
      Disposed cleanup proves leaf absence and never deletes a reoccupied leaf.
- [ ] Helper and context-manager inputs independently prove exact trusted-root,
      HEAD tree, stage-0 index, and no-filter working blob identity before
      either script is invoked.
- [ ] Real link/reparse rejection executes on both OS families.
- [ ] The reciprocal PS candidate-validation-layer/Terraform matrix has no
      unexplained blocker.
- [ ] The final path gate contains exactly the three affected files.
- [ ] No production workflow consumes the new scripts yet.
- [ ] T1B is required to record and validate this issue's actual merge commit;
      this pull request records its reviewed head and successor handoff.

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
