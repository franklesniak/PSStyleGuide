# Add a fail-closed cross-platform style-guide candidate validator

## Summary

Add one shared PowerShell archive validator/extractor, one caller-owned
temporary-context lifecycle, and one permanent adversarial harness for
generated style-guide candidates. Require equivalent behavior under Windows
PowerShell 5.1 and PowerShell 7 on Windows and Ubuntu.

Treat every caller path, diagnostic label, ZIP entry, resource declaration,
and cleanup claim as untrusted. Hash and parse one continuously held archive
stream, validate the complete manifest and byte ceilings before candidate
creation, extract only fresh ordinary files, and retain uncertain state rather
than recursively deleting it.

P1A is workflow-inert. It adds production code and tests but activates nothing
in `.github/workflows/build.yml` or `markdownlint.yml`.

## Dependency

Implement only after P1, **Make artifact generation byte-deterministic across
PowerShell editions and hosts**, merges.

Record:

- P1's actual issue/blocked-by relationship;
- its exact merge commit;
- the exact generator version;
- P1's completed P1↔T1 matrix; and
- passing generator/action/runtime evidence.

P1B activates these scripts after P1A merges.

## Affected files

Exactly these three files may change:

- `.github/workflows/Expand-StyleGuideCandidateArtifact.ps1` — add;
- `.github/workflows/Manage-StyleGuideCandidateInvocationContext.ps1` — add;
- `.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1` — add.

Each script must:

- declare `#Requires -Version 5.1`;
- record its exact parseable `.NOTES` version under the PSStyleGuide policy;
- remain LF, BOM-less UTF-8; and
- pass repository formatting/static checks.

Do not change a workflow, generator, source guide, generated artifact, package,
lockfile, hook, lint configuration, or Dependabot.

## Public contracts

### Archive validator/extractor

`Expand-StyleGuideCandidateArtifact.ps1` accepts mandatory scalar parameters:

- `CheckoutRoot`;
- `TrustedTemporaryRoot`;
- `DownloadDirectory`;
- `CandidateDirectory`; and
- `ExpectedDigest`.

It accepts optional scalar diagnostic labels:

- `ArtifactId`;
- `RunId`; and
- `RunAttempt`.

Use `$PSBoundParameters` to distinguish omission from explicit binding.
Omitted labels become diagnostic text `unavailable`. Explicit null or empty
labels fail parameter validation. Labels never select/authorize an artifact or
construct a path.

Place functions before the main entry point. When ordinarily dot-sourced,
define functions and return before expansion. Do not add a test switch,
environment backdoor, or alternate expansion entry point.

### Caller invocation context

`Manage-StyleGuideCandidateInvocationContext.ps1` defines exactly:

- `New-StyleGuideCandidateInvocationContext`; and
- `Remove-StyleGuideCandidateInvocationContext`.

Creation accepts one explicit runner-controlled temporary parent and returns a
structured context containing:

- normalized parent;
- fresh invocation root;
- fresh download directory;
- initially absent candidate path;
- diagnostic label; and
- exact ordered ownership metadata.

Removal accepts that context, explicit ordinary paths owned by the invocation,
and any primary failure. It never infers ownership through recursive
enumeration.

The archive helper independently validates every context path and claim.

### Candidate-state cleanup

The archive helper defines exactly:

```text
Remove-StyleGuideCandidateInvocationState
```

Normal helper failure and every `K-*` harness case call this exact function. It
accepts the normalized candidate envelope, explicit ordered ownership journal,
and primary failure. It never delegates recursive candidate deletion to caller
cleanup.

### Permanent harness

`Test-Expand-StyleGuideCandidateArtifact.ps1` accepts mandatory scalar:

- `HelperPath`; and
- `ContextManagerPath`.

Resolve both supplied paths once as exact tracked ordinary non-reparse files,
validate exact P1A versions, and dot-source only the resolved paths. Reject a
missing, relative, wildcard, non-FileSystem, substituted, duplicate, or
unexpected identity before fixture creation. Do not derive the context manager
from a sibling directory or ambient session state.

## Requested changes

### 1. Normalize and classify paths

For every caller path:

1. reject null/empty, wildcard, relative, malformed, ambiguous, and
   non-FileSystem input;
2. accept native rooted or FileSystem-provider-qualified absolute paths;
3. use provider metadata and one deterministic provider-internal absolute
   result before .NET access;
4. use ordinal-ignore-case comparison on Windows and ordinal comparison on
   non-Windows;
5. use separator-aware equality/strict-descendant checks; and
6. materialize each exact `Directory.EnumerateFileSystemEntries` result once
   before counting/inspection.

`Get-ChildItem` may support diagnostics only with `-LiteralPath -Force`; it
cannot establish exact counts.

### 2. Validate the complete path-component envelope

Require checkout and trusted-temporary roots to be existing ordinary
directories and mutually non-overlapping. Require download/candidate paths to
be strict descendants of the trusted root and outside checkout.

Lexically inspect every existing component from volume/share root through:

- each declared root;
- download directory and retained archive;
- candidate parent; and
- created candidate path.

Reject reparse points, symbolic links, junctions, volume mounts, dangling
entries, type mismatches, and every attribute/resolution/enumeration failure.
Never follow a link merely to classify it.

Repeat applicable component, containment, type, parent, and leaf checks before
archive open, before candidate creation, and after extraction.

Supported threat model: GitHub-hosted runner, runner-controlled ancestors, one
job-owned checkout, one job-owned trusted temporary root, and no competing
writer. Repeated validation narrows TOCTOU risk; it is not an OS-native
directory-handle sandbox.

### 3. Acquire and remove caller-owned context

Creation:

1. normalizes the explicit parent to an existing ordinary non-reparse
   FileSystem directory;
2. calls `Path.GetRandomFileName()` for a child;
3. proves no entry has that name;
4. creates without `-Force`;
5. verifies the returned child is one ordinary non-reparse directory;
6. retries a documented finite number only after exhaustive reinspection
   proves a real name collision;
7. fails immediately for permission/type/attribute/resolution errors;
8. creates a separate ordinary download directory; and
9. returns an absent candidate leaf.

Teardown runs after every ZIP/entry/file stream is disposed. Before deletion,
revalidate the context envelope and every explicit owned entry. Remove only
proven ordinary files, then empty ordinary directories, nonrecursively and
deepest-first.

An unexpected, missing, unreadable, substituted, link/reparse, hidden, or
unjournaled entry stops teardown. Retain uncertain state and report root,
phase, offending entry, cleanup exception, and primary failure without hiding
the primary failure.

### 4. Validate parameters and labels before filesystem work

First:

- require `ExpectedDigest` to match `^[0-9A-Fa-f]{64}$`;
- reject explicitly bound null/empty optional labels;
- normalize omitted labels to `unavailable`; and
- initialize stable phase diagnostics.

Stable phases:

- `parameter`;
- `root`;
- `containment`;
- `download`;
- `digest`;
- `archive`;
- `manifest`;
- `destination`;
- `extraction`;
- `post-extraction`; and
- `cleanup`.

Diagnostics include safely available normalized roots/paths, expected digest,
actual digest after computation, retained archive path, supplied/omitted
labels, offending entry/destination, and preserved error. Never log artifact
contents.

### 5. Use one validation order

Exact order:

1. parameter/label grammar;
2. roots, existing components, and root separation;
3. working-path containment/components;
4. exact download content and archive type;
5. candidate-parent safety and leaf absence;
6. one retained archive stream open and SHA-256;
7. rewind the same stream, open ZIP, enforce ceilings, validate manifest;
8. repeat component/containment/parent/leaf checks;
9. create candidate once and extract; and
10. exhaustively validate output bytes/filesystem state.

No phase before step 9 creates the candidate leaf.

### 6. Bind digest and ZIP processing to one stream

The download directory contains exactly one top-level entry, including hidden
or system entries. It must be an ordinary non-reparse file; no `.zip`
extension is required.

After path revalidation:

1. open once with `FileMode.Open`, `FileAccess.Read`, `FileShare.Read`;
2. require readable and seekable;
3. hash with `Get-FileHash -InputStream -Algorithm SHA256`;
4. require one 64-hex result;
5. compare expected/actual ordinally ignoring case;
6. fail before `ZipArchive` construction on mismatch;
7. rewind the same stream to zero;
8. construct one read-only `ZipArchive` with deliberate `leaveOpen`;
9. keep both alive through validation/extraction; and
10. dispose ZIP, then file stream, before cleanup.

Do not hash by path and reopen, copy to memory/another file, or accept a
`sha256:` prefix.

### 7. Validate exact manifest and finite resources

Before candidate creation require exactly four root-level nondirectory names,
ordinally:

```text
copilot-instructions.md
powershell.instructions.md
STYLE_GUIDE_CHAT.md
STYLE_GUIDE_FULL.md
```

Reject empty names, missing/extra entries, exact/case-insensitive duplicates,
both separators, nesting/traversal, leading slash/backslash, drive
qualification, directory entries, and file/directory collisions.

Production ceilings:

- exactly four entries;
- at most 8 MiB declared uncompressed bytes per entry;
- at most 32 MiB declared total uncompressed bytes;
- at most 32 MiB retained archive bytes;
- at most 8 MiB actual copied bytes per entry; and
- at most 32 MiB actual copied bytes total.

Reject negative, overflowed, inconsistent, or unreadable lengths. Count actual
bytes independently and stop at the ceilings; declared length is not proof of
output.

### 8. Extract only fresh ordinary files

Candidate leaf remains absent until digest, ZIP, limits, and manifest pass.
Immediately before creation, exhaustively reject any file, directory, live
link/reparse, or dangling link with the leaf name. Create once; never
delete/recreate or reuse.

For every permitted entry:

- compute one immediate-child destination with `GetFullPath`;
- prove it remains beneath candidate root;
- open with `FileMode.CreateNew`, write access, no sharing;
- journal before/at successful ownership acquisition;
- copy only entry bytes with actual counters; and
- dispose entry/destination streams deterministically.

Restore no link/type/mode/attribute/timestamp metadata. ZIP external attributes
are ignored, not treated as a safe destination type.

After extraction require exactly the four expected ordinary non-reparse files,
repeat containment/components, reject UTF-8 BOM and every `0x0D`, and return
the four normalized paths.

### 9. Fail closed during candidate cleanup

`Remove-StyleGuideCandidateInvocationState` performs a complete pre-deletion
pass:

- validate candidate envelope;
- enumerate immediate children exactly;
- require equality with ownership journal;
- validate every child as expected ordinary non-reparse file; and
- require safe parent/leaf relationships.

Only then delete journaled files nonrecursively and remove the proven empty
candidate directory. On uncertainty, delete nothing further and emit primary
plus cleanup diagnostics.

### 10. Implement the permanent stable-ID harness

Create every fixture under one production caller context. Clean only proven
owned fixture state in `finally`. The harness may dot-source the helper for
cleanup cases and call the exact production cleanup; it may not reimplement
path, digest, archive, manifest, extraction, context, or cleanup algorithms.

Mandatory IDs:

| IDs | Coverage |
| --- | --- |
| `V-01..02` | exact valid archive; symlink-like ZIP external attributes ignored |
| `P-01..02` | checkout sibling-prefix; FileSystem-provider-qualified absolute path |
| `D-01..02` | digest failure with all labels; all labels omitted/`unavailable` |
| `Z-01` | invalid/truncated ZIP with matching digest |
| `M-01..14` | missing, extra, exact duplicate, case collision, both nesting separators, both traversal separators, leading slash, leading backslash, drive qualification, directory, file/directory collision, raw empty name |
| `E-01..10` | outside root, equal roots, both overlap directions, relative, non-FileSystem, Windows/Linux case behavior, root/ancestor link, below-root link, hidden/system extra download entry |
| `L-01..04` | preexisting file, directory, live link/reparse leaf, dangling link |
| `B-01..02` | post-extraction BOM and CR |
| `R-01..08` | archive, declared per-entry/total, actual per-entry/total, negative/overflow/inconsistent length ceilings |
| `K-01..04` | unjournaled child, link/reparse substitution, caller unknown child, primary-plus-cleanup failure retention |
| `X-01..03` | explicitly empty `ArtifactId`, `RunId`, `RunAttempt` |
| `X-04..06` | explicitly bound null `ArtifactId`, `RunId`, `RunAttempt` |
| `H-01` | wrong/substituted context-manager path before fixture creation |

Each row emits ID, platform, phase, expected/actual, initial candidate state,
pre-teardown final state, required diagnostics, and outside-sentinel result.
Each direction/type/label is independent.

Required postconditions:

- pre-creation failures leave candidate absent;
- explicit-null/empty failures prove no download enumeration/archive open;
- preexisting leaves remain unchanged/unfollowed;
- helper partial state is removed only by candidate cleanup;
- caller state is removed only by caller cleanup;
- uncertain state is retained;
- sentinels remain unchanged; and
- digest mismatch precedes ZIP construction.

A narrowly justified link-primitive skip names case/platform/reason and is not
a pass. At least one real link/reparse rejection executes per OS family.

## Reciprocal P1A↔T1A comparison

At implementation start and before merge compare exact PSStyleGuide P1A and
TerraformStyleGuide T1A commits across:

- public parameters and omission/empty/null rules;
- archive identity/digest and validation order;
- component/path security;
- manifest/resource limits/extraction;
- caller context and both cleanup lifecycles;
- harness inputs, stable IDs, skips/postconditions;
- diagnostics; and
- platform/edition support.

Record `same`, `intentional difference`, or `blocker` with exact evidence.
Manifest filenames are intentional; unexplained security/error differences
block merge. Do not add a shared runtime package.

## Validation

Run exact tracked harness/helper/context under:

- Windows PowerShell exactly 5.1 on Windows;
- PowerShell 7 on Windows; and
- PowerShell 7 on Ubuntu.

Use clean disposable worktrees. Record script versions, paths, editions, OS,
Git, case totals, skips, and duration. Every applicable mandatory ID reports
exactly one result.

Static checks prove:

- no recursive/wildcard deletion;
- no automatic ZIP extraction;
- no ambient root derivation;
- exact one definition of each cleanup function;
- normal/helper harness use exact production cleanup;
- every exact enumeration includes hidden/system entries;
- only the three affected files changed/staged; and
- generator, workflows, artifacts, package/update policy remain unchanged.

A temporary evidence workflow must be uniquely named, removed before final
commit, and absent from final path sets.

## Acceptance criteria

- [ ] All three scripts are versioned PowerShell 5.1-compatible LF/BOM-less
      files.
- [ ] The harness accepts exact helper and context-manager paths.
- [ ] Caller acquisition proves fresh ownership with bounded collision-only
      retry.
- [ ] Both cleanup paths are nonrecursive, journal-based, and retain uncertain
      state.
- [ ] One archive stream is opened, hashed, rewound, parsed, and disposed in
      exact order.
- [ ] Digest mismatch precedes ZIP construction/candidate creation.
- [ ] Component, containment, link, type, root-separation, and download checks
      pass on both OS families.
- [ ] Manifest and declared/actual resource ceilings pass before/during
      extraction.
- [ ] Extraction creates only four fresh ordinary files and restores no ZIP
      metadata.
- [ ] BOM/CR/type/content postconditions pass.
- [ ] Empty and explicit-null label cases prove pre-filesystem rejection.
- [ ] Caller and candidate cleanup failures are tested separately.
- [ ] Every mandatory ID has one oracle and pre-teardown postcondition.
- [ ] Real link/reparse rejection executes on both OS families.
- [ ] P1A↔T1A has no unexplained blocker.
- [ ] Final working/staged path sets equal the three affected files.
- [ ] No production workflow consumes the scripts.
- [ ] P1B records P1A's exact merge commit.

## Non-goals

- Changing triggers, permissions, jobs, actions, or artifact transport.
- Downloading/uploading a real Actions artifact.
- Committing generated output.
- Providing an OS-native adversarial filesystem sandbox.
- Supporting competing untrusted writers under the job root.
- Sharing a runtime module across repositories.

## References

- [Path.GetRandomFileName](https://learn.microsoft.com/dotnet/api/system.io.path.getrandomfilename)
- [Directory.CreateDirectory](https://learn.microsoft.com/dotnet/api/system.io.directory.createdirectory)
- [FileStream](https://learn.microsoft.com/dotnet/api/system.io.filestream)
- [Get-FileHash](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/get-filehash)
- [ZipArchive](https://learn.microsoft.com/dotnet/api/system.io.compression.ziparchive)
- [File attributes](https://learn.microsoft.com/dotnet/api/system.io.fileattributes)
- [PowerShell providers](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_providers)
