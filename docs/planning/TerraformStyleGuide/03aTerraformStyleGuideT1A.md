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
standardize repository text checkouts on LF** merges. Record and validate the
exact prerequisite merge commit before work.

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
- record one repository-convention UTC version;
- remain an ordinary LF, BOM-less UTF-8 file; and
- pass the repository's PowerShell formatting/static checks.

## Public contracts

### Archive validator/extractor

`Expand-StyleGuideCandidateArtifact.ps1` accepts five mandatory scalar
parameters:

- `CheckoutRoot`;
- `TrustedTemporaryRoot`;
- `DownloadDirectory`;
- `CandidateDirectory`; and
- `ExpectedDigest`.

It accepts three optional scalar diagnostic labels:

- `ArtifactId`;
- `RunId`; and
- `RunAttempt`.

The helper must use `$PSBoundParameters` to distinguish omitted labels from
explicit null/empty values. Omitted labels become the diagnostic text
`unavailable`. Explicit null or empty labels fail parameter validation.
Labels are never used for selection, authorization, digest trust, or path
construction.

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
function. It accepts the normalized candidate envelope, the explicit ordered
ownership journal, and the primary failure. It does not delegate recursive
deletion to the caller-context cleanup.

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

- require `ExpectedDigest` to match `^[0-9A-Fa-f]{64}$`;
- reject explicit null/empty optional labels;
- normalize omitted labels to `unavailable`; and
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

Count actual copied bytes and stop at the same per-entry/total limits. A
declared length is not trusted proof of actual output.

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
- return/log the four normalized candidate paths.

### 9. Fail closed during candidate cleanup

`Remove-StyleGuideCandidateInvocationState` must perform one complete
pre-deletion pass:

- validate the candidate envelope;
- exhaustively enumerate immediate children;
- require exact equality with the ownership journal;
- validate every journaled child as its expected ordinary non-reparse file;
  and
- require safe parent/leaf relationships.

Only after all checks pass may it delete journaled files nonrecursively and
remove the proven empty candidate directory. If any state is uncertain, delete
nothing further, retain the path, and emit primary plus cleanup diagnostics.

### 10. Implement the permanent stable-ID harness

`Test-Expand-StyleGuideCandidateArtifact.ps1` accepts mandatory scalar
`HelperPath`. It resolves that exact tracked helper once as an ordinary
non-reparse file and uses the absolute path for every child-script invocation.
It creates every fixture beneath one new caller context and cleans only proven
owned fixture state in `finally`.

The harness may dot-source the helper once for the deterministic cleanup cases
and call `Remove-StyleGuideCandidateInvocationState`. It may not reimplement
path, digest, archive, manifest, extraction, or cleanup logic.

Every case emits its stable ID, platform, phase, expected/actual outcome,
initial candidate state, final candidate state before harness teardown,
required diagnostics, and outside-sentinel result.

Mandatory IDs:

| IDs | Mandatory coverage |
| --- | --- |
| `V-01..02` | exact valid archive; valid archive with symlink-like external attributes ignored |
| `P-01..02` | checkout sibling-prefix; filesystem-provider-qualified absolute path |
| `D-01..02` | digest failure with all labels; equivalent failure with all labels omitted/`unavailable` |
| `Z-01` | invalid/truncated ZIP with matching digest |
| `M-01..14` | missing, extra, exact duplicate, case collision, both nesting separators, both traversal separators, leading slash, leading backslash, drive qualification, directory entry, file/directory collision, raw empty name |
| `E-01..10` | outside root, equal roots, each overlap direction, relative, non-filesystem provider, Windows/Linux case behavior, root/ancestor link, below-root link, hidden/system extra download entry |
| `L-01..04` | preexisting file, directory, live link/reparse leaf, dangling link |
| `B-01..02` | post-extraction BOM and CR |
| `K-01..02` | mandatory unjournaled ordinary child retention; supported link/reparse substitution retention |
| `X-01..03` | explicitly empty `ArtifactId`, `RunId`, and `RunAttempt` |

Each slash direction, overlap direction, leaf type, and explicit-empty label is
an independent row. Use a fixed reviewed raw ZIP for `M-14` if `ZipArchive`
cannot create the empty-name fixture.

Required postconditions:

- failures before helper creation leave candidate absent;
- preexisting leaves remain unmodified/unfollowed;
- ordinary helper-owned partial state is removed only by the production cleanup
  function;
- unsafe/ownership-uncertain state is retained;
- unrelated sentinels remain unchanged; and
- digest mismatch occurs before ZIP construction.

A narrowly justified link-primitive skip names the case, platform, and reason
and is not a pass. At least one real link/reparse rejection must execute on
each OS family.

## Reciprocal PSStyleGuide comparison

At implementation start and before merge, compare the then-current
PSStyleGuide P1 issue/implementation and this issue across:

- public parameters and omission/empty rules;
- archive identity and digest;
- full-component path security;
- manifest/limits/extraction;
- caller context and both cleanup lifecycles;
- diagnostics/stable IDs/skips/postconditions; and
- platform/edition support.

For each row record P1 evidence, Terraform evidence, status (`same`,
`intentional difference`, `blocker`), and rationale. Repository paths,
manifest filenames/bytes, and workflow topology may differ intentionally.
Unexplained security/error behavior differences block merge.

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
- every exact enumeration includes hidden/system entries;
- only the three affected files changed/staged; and
- generator outputs/workflows remain unchanged.

If hosted cross-platform evidence needs a temporary workflow, use a uniquely
named branch/workflow for evidence, remove it before the final commit, and
prove it is absent from the final changed/staged path set.

## Acceptance criteria

- [ ] The helper, context lifecycle, and harness have versioned PowerShell 5.1
      compatible implementations.
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
- [ ] Real link/reparse rejection executes on both OS families.
- [ ] The reciprocal P1/Terraform matrix has no unexplained blocker.
- [ ] The final path gate contains exactly the three affected files.
- [ ] No production workflow consumes the new scripts yet.
- [ ] The pull request records the exact T1A merge commit consumed by T1B.

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
