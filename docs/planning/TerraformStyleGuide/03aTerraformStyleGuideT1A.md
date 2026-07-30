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
  `Version: 1.0.<actual-UTC-implementation-YYYYMMDD>.0`, validated by T1's
  complete four-component/date/reset convention;
- remain an ordinary LF, BOM-less UTF-8 file; and
- pass the repository's PowerShell formatting/static checks.

Reject missing, duplicate, malformed, stale, impossible-date, or function-level
decoy versions. The harness checks exact expected script versions from the T1A
commit in addition to ordinary-file identity; commit IDs and SHA-256 remain the
immutable evidence.

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
| T1A-V-01 | `candidate.valid.case-01` | exact four-entry valid archive | success; four exact files; both production cleanups succeed |
| T1A-V-02 | `candidate.valid.case-02` | valid entries with symlink-like external attributes | success; attributes ignored; four ordinary files |
| T1A-P-01 | `candidate.path.case-01` | checkout sibling-prefix path | `containment`; candidate absent |
| T1A-P-02 | `candidate.path.case-02` | filesystem-provider-qualified absolute inputs | success; normalized paths equal native-path control |
| T1A-D-01 | `candidate.digest.case-01` | digest mismatch with all labels supplied | `digest`; candidate absent; all labels in diagnostics |
| T1A-D-02 | `candidate.digest.case-02` | same mismatch with all labels omitted | `digest`; candidate absent; labels are `unavailable` |
| T1A-D-03 | `candidate.digest.case-03` | 63-hex expected digest | `parameter`; candidate absent; archive unopened |
| T1A-D-04 | `candidate.digest.case-04` | 64 characters containing nonhex | `parameter`; candidate absent; archive unopened |
| T1A-D-05 | `candidate.digest.case-05` | `sha256:`-prefixed digest | `parameter`; candidate absent; archive unopened |
| T1A-Z-01 | `candidate.archive.case-01` | invalid/truncated ZIP with matching digest | `archive`; candidate absent |
| T1A-M-01 | `candidate.manifest.case-01` | one required entry missing | `manifest`; candidate absent |
| T1A-M-02 | `candidate.manifest.case-02` | one extra entry | `manifest`; candidate absent |
| T1A-M-03 | `candidate.manifest.case-03` | exact duplicate name | `manifest`; candidate absent |
| T1A-M-04 | `candidate.manifest.case-04` | case-insensitive name collision | `manifest`; candidate absent |
| T1A-M-05 | `candidate.manifest.case-05` | nested name using `/` | `manifest`; candidate absent |
| T1A-M-06 | `candidate.manifest.case-06` | nested name using `\` | `manifest`; candidate absent |
| T1A-M-07 | `candidate.manifest.case-07` | traversal name using `/` | `manifest`; candidate absent |
| T1A-M-08 | `candidate.manifest.case-08` | traversal name using `\` | `manifest`; candidate absent |
| T1A-M-09 | `candidate.manifest.case-09` | leading `/` | `manifest`; candidate absent |
| T1A-M-10 | `candidate.manifest.case-10` | leading `\` | `manifest`; candidate absent |
| T1A-M-11 | `candidate.manifest.case-11` | drive-qualified name | `manifest`; candidate absent |
| T1A-M-12 | `candidate.manifest.case-12` | directory entry | `manifest`; candidate absent |
| T1A-M-13 | `candidate.manifest.case-13` | file/directory collision | `manifest`; candidate absent |
| T1A-M-14 | `candidate.manifest.case-14` | fixed reviewed raw ZIP with empty name | `manifest`; candidate absent; fixture SHA recorded |
| T1A-E-01 | `candidate.environment.case-01` | download/candidate outside trusted root | `containment`; candidate absent |
| T1A-E-02 | `candidate.environment.case-02` | checkout and trusted roots equal | `root`; candidate absent |
| T1A-E-03 | `candidate.environment.case-03` | checkout contains trusted root | `root`; candidate absent |
| T1A-E-04 | `candidate.environment.case-04` | trusted root contains checkout | `root`; candidate absent |
| T1A-E-05 | `candidate.environment.case-05` | relative working/root path | `parameter`; candidate absent |
| T1A-E-06 | `candidate.environment.case-06` | non-filesystem provider path | `parameter`; candidate absent |
| T1A-E-07 | `candidate.environment.case-07` | Windows case variation of the same existing path envelope | Windows only: pass/status 0/`complete`; four valid files; candidate cleanup succeeds; context `Disposed`; sentinel unchanged |
| T1A-E-08 | `candidate.environment.case-08` | Linux differently cased sibling outside trusted root | Linux only: fail/status 1/`containment/case-sensitive-outside`; candidate absent; context cleanup reaches `Disposed`; sentinel unchanged |
| T1A-E-09 | `candidate.environment.case-09` | root or ancestor link/reparse component | `root`; candidate absent |
| T1A-E-10 | `candidate.environment.case-10` | below-root link/reparse component | fail/status 1/`containment/component-reparse`; candidate absent; context cleanup reaches `Disposed` |
| T1A-E-11 | `candidate.environment.case-11` | hidden/system extra download entry | `download`; candidate absent |
| T1A-E-12 | `candidate.environment.case-12` | wildcard root/working path | `parameter`; candidate absent |
| T1A-E-13 | `candidate.environment.case-13` | wildcard path capable of multiple matches under a resolving API | fail/status 1/`parameter/path-wildcard` before resolution/context creation; candidate absent |
| T1A-E-14 | `candidate.environment.case-14` | checkout root missing | fail/status 1/`root/checkout-missing`; candidate absent |
| T1A-E-15 | `candidate.environment.case-15` | checkout root is not a directory | fail/status 1/`root/checkout-not-directory`; candidate absent |
| T1A-E-16 | `candidate.environment.case-16` | trusted root missing | fail/status 1/`root/trusted-missing`; candidate absent |
| T1A-E-17 | `candidate.environment.case-17` | trusted root is not a directory | fail/status 1/`root/trusted-not-directory`; candidate absent |
| T1A-E-18 | `candidate.environment.case-18` | download directory missing | fail/status 1/`download/directory-missing`; candidate absent |
| T1A-E-19 | `candidate.environment.case-19` | download path is not a directory | fail/status 1/`download/not-directory`; candidate absent |
| T1A-E-20 | `candidate.environment.case-20` | retained archive missing | fail/status 1/`download/archive-missing`; candidate absent |
| T1A-E-21 | `candidate.environment.case-21` | retained archive is not an ordinary file | fail/status 1/`download/archive-not-file`; candidate absent |
| T1A-E-22 | `candidate.environment.case-22` | candidate parent missing | fail/status 1/`destination/parent-missing`; candidate absent |
| T1A-E-23 | `candidate.environment.case-23` | candidate parent is not a directory | fail/status 1/`destination/parent-not-directory`; candidate absent |
| T1A-L-01 | `candidate.destination.case-01` | preexisting ordinary candidate file | `destination`; leaf unchanged |
| T1A-L-02 | `candidate.destination.case-02` | preexisting candidate directory | `destination`; leaf unchanged |
| T1A-L-03 | `candidate.destination.case-03` | live link/reparse candidate leaf | `destination`; target and leaf unchanged |
| T1A-L-04 | `candidate.destination.case-04` | dangling link candidate leaf | `destination`; link unchanged |
| T1A-B-01 | `candidate.bytes.case-01` | extracted file begins with UTF-8 BOM | `post-extraction`; owned partial removed |
| T1A-B-02 | `candidate.bytes.case-02` | extracted file contains `0x0D` | `post-extraction`; owned partial removed |
| T1A-K-01 | `candidate.cleanup.case-01` | unjournaled ordinary candidate child | `cleanup`; candidate retained; delete nothing further |
| T1A-K-02 | `candidate.cleanup.case-02` | supported link/reparse substitution | `cleanup`; candidate retained; target unchanged |
| T1A-K-03 | `candidate.cleanup.case-03` | repeated candidate cleanup after safe removal | success/no-op; no unrelated deletion |
| T1A-K-04 | `candidate.cleanup.case-04` | primary failure then candidate-cleanup failure | both reasons reported; uncertain state retained |
| T1A-C-01 | `context.cleanup.case-01` | normal caller-context teardown | success; journaled entries removed deepest first |
| T1A-C-02 | `context.cleanup.case-02` | repeated caller-context teardown | success/no-op under disposed-context contract |
| T1A-C-03 | `context.cleanup.case-03` | unjournaled ordinary context entry | `cleanup`; entire uncertain context retained |
| T1A-C-04 | `context.cleanup.case-04` | link/reparse substitution in context | `cleanup`; context/target retained unchanged |
| T1A-C-05 | `context.cleanup.case-05` | missing/unreadable journaled context entry | `cleanup`; no further deletion |
| T1A-C-06 | `context.cleanup.case-06` | primary failure then caller-cleanup failure | primary prominent; cleanup and retained root reported |
| T1A-C-07 | `context.cleanup.case-07` | proven partial ordinary ownership journal | success; only journaled entries removed nonrecursively |
| T1A-C-08 | `context.cleanup.case-08` | candidate cleanup then context cleanup | success; exact production lifecycles invoked in order |
| T1A-R-01 | `candidate.limit.case-01` | entry one byte below 8 MiB | pass/status 0/`complete`; four valid files; candidate and context cleanups succeed; context `Disposed` |
| T1A-R-02 | `candidate.limit.case-02` | entry exactly 8 MiB | pass/status 0/`complete`; four valid files; candidate and context cleanups succeed; context `Disposed` |
| T1A-R-03 | `candidate.limit.case-03` | declared entry one byte above 8 MiB | `manifest`; candidate absent |
| T1A-R-04 | `candidate.limit.case-04` | actual entry exceeds permitted/declared bytes | `extraction`; stop at first excess; owned partial removed |
| T1A-R-05 | `candidate.limit.case-05` | declared total one byte below 32 MiB | pass/status 0/`complete`; four valid files; candidate and context cleanups succeed; context `Disposed` |
| T1A-R-06 | `candidate.limit.case-06` | declared total exactly 32 MiB | pass/status 0/`complete`; four valid files; candidate and context cleanups succeed; context `Disposed` |
| T1A-R-07 | `candidate.limit.case-07` | declared total one byte above 32 MiB | `manifest`; candidate absent |
| T1A-R-08 | `candidate.limit.case-08` | actual cumulative output exceeds 32 MiB | `extraction`; stop at first excess; owned partial removed |
| T1A-R-09 | `candidate.limit.case-09` | retained archive exactly 32 MiB | pass/status 0/`complete`; four valid files; candidate and context cleanups succeed; context `Disposed` |
| T1A-R-10 | `candidate.limit.case-10` | retained archive one byte above 32 MiB | pre-ZIP limit failure; candidate absent |
| T1A-R-11 | `candidate.limit.case-11` | raw ZIP with negative/inconsistent length state | `manifest`; candidate absent; fixture SHA recorded |
| T1A-R-12 | `candidate.limit.case-12` | length arithmetic overflow fixture | `manifest`; checked overflow; candidate absent |
| T1A-R-13 | `candidate.limit.case-13` | retained archive one byte below 32 MiB | pass/status 0/`complete`; four valid files; candidate and context cleanups succeed; context `Disposed` |
| T1A-W-01 | `candidate.download.case-01` | empty download directory | `download`; candidate absent |
| T1A-W-02 | `candidate.download.case-02` | two top-level download entries | `download`; candidate absent |
| T1A-W-03 | `candidate.download.case-03` | directory as sole download entry | `download`; candidate absent |
| T1A-W-04 | `candidate.download.case-04` | link/reparse as sole download entry | `download`; target unchanged; candidate absent |
| T1A-W-05 | `candidate.download.case-05` | unreadable/unclassifiable download entry | `download`; candidate absent |
| T1A-S-01 | `harness.input.case-01` | missing helper script path | fail/status 1/`harness-input/script-missing`; no context; neither supplied script invoked; sentinel unchanged |
| T1A-S-02 | `harness.input.case-02` | wildcard helper path | fail/status 1/`harness-input/path-wildcard`; no context; neither supplied script invoked; sentinel unchanged |
| T1A-S-03 | `harness.input.case-03` | non-filesystem helper path | fail/status 1/`harness-input/path-provider`; no context; neither supplied script invoked; sentinel unchanged |
| T1A-S-04 | `harness.input.case-04` | multi-match-capable wildcard helper path | fail/status 1/`harness-input/path-wildcard`; no resolution/context; neither script invoked |
| T1A-S-05 | `harness.input.case-05` | reparse helper script | fail/status 1/`harness-input/script-reparse`; no context; neither script invoked; target unchanged |
| T1A-S-06 | `harness.input.case-06` | missing context-manager path | fail/status 1/`harness-input/script-missing`; no context; neither supplied script invoked; sentinel unchanged |
| T1A-S-07 | `harness.input.case-07` | wildcard context-manager path | fail/status 1/`harness-input/path-wildcard`; no context; neither supplied script invoked; sentinel unchanged |
| T1A-S-08 | `harness.input.case-08` | non-filesystem context-manager path | fail/status 1/`harness-input/path-provider`; no context; neither supplied script invoked; sentinel unchanged |
| T1A-S-09 | `harness.input.case-09` | multi-match-capable wildcard context-manager path | fail/status 1/`harness-input/path-wildcard`; no resolution/context; neither script invoked |
| T1A-S-10 | `harness.input.case-10` | reparse context-manager script | fail/status 1/`harness-input/script-reparse`; no context; neither script invoked; target unchanged |
| T1A-S-11 | `harness.input.case-11` | both scripts provider-qualified, exact tracked, and versioned | pass/status 0 through the `T1A-V-01` control; four valid files; context `Disposed` |
| T1A-S-12 | `harness.input.case-12` | untracked ordinary helper script | fail/status 1/`harness-input/script-untracked`; no context; neither supplied script invoked |
| T1A-S-13 | `harness.input.case-13` | untracked ordinary context-manager script | fail/status 1/`harness-input/script-untracked`; no context; neither supplied script invoked |
| T1A-X-01 | `candidate.label.case-01` | explicit empty `ArtifactId` | `parameter`; candidate absent |
| T1A-X-02 | `candidate.label.case-02` | explicit empty `RunId` | `parameter`; candidate absent |
| T1A-X-03 | `candidate.label.case-03` | explicit empty `RunAttempt` | `parameter`; candidate absent |
| T1A-X-04 | `candidate.label.case-04` | explicit null `ArtifactId` | `parameter`; candidate absent |
| T1A-X-05 | `candidate.label.case-05` | explicit null `RunId` | `parameter`; candidate absent |
| T1A-X-06 | `candidate.label.case-06` | explicit null `RunAttempt` | `parameter`; candidate absent |
| T1A-X-07 | `candidate.label.case-07` | valid nonempty labels | selected failure preserves exact label text |
| T1A-X-08 | `candidate.label.case-08` | array supplied as `ArtifactId` | fail/status 1/`parameter/label-not-scalar-string`; no filesystem work; candidate absent |
| T1A-X-09 | `candidate.label.case-09` | array supplied as `RunId` | fail/status 1/`parameter/label-not-scalar-string`; no filesystem work; candidate absent |
| T1A-X-10 | `candidate.label.case-10` | array supplied as `RunAttempt` | fail/status 1/`parameter/label-not-scalar-string`; no filesystem work; candidate absent |
| T1A-X-11 | `candidate.label.case-11` | object supplied as `ArtifactId` | fail/status 1/`parameter/label-not-scalar-string`; no filesystem work; candidate absent |
| T1A-X-12 | `candidate.label.case-12` | object supplied as `RunId` | fail/status 1/`parameter/label-not-scalar-string`; no filesystem work; candidate absent |
| T1A-X-13 | `candidate.label.case-13` | object supplied as `RunAttempt` | fail/status 1/`parameter/label-not-scalar-string`; no filesystem work; candidate absent |

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

Preserve each raw value as `[object]`; do not let PowerShell enumerate or join
it. Validate in this order before any filesystem work:

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

Every case row and emitted result has the fixed fields:
`Id`, `SemanticCase`, `Applicability`, `Fixture`, `InitialState`, `Result`
(`pass|fail|skip`), exact process `Status`, `Phase`, `Subreason`,
`CandidateState` (`absent|four-valid-files|owned-partial-removed|
preexisting-unchanged|uncertain-retained`), `ContextState`, ordered
`CleanupSequence`, `Diagnostics`, and `SentinelState`.

Status is exactly `0` for pass and `1` for helper/harness rejection. The table's
compact repeated phrases inherit these mandatory defaults: every fail has the
literal named phase/subreason, no unproved deletion, unchanged sentinel, and
the candidate/context states stated by its fixture; every successful
end-to-end case has four valid ordinary files, candidate cleanup followed by
context cleanup, final `Disposed`, and unchanged sentinel. “Continues,”
“proceeds,” “applicable,” an `or` oracle, or a slash-combined fixture is not a
final result and must not appear in machine metadata.

At startup, reconcile the applicable expected ID set; at completion, require
one and only one complete result per applicable ID and none for nonapplicable
IDs. Skip is permitted only for the narrow real-link primitive-availability
rule, names exact ID/platform/reason, credits no pass, and cannot eliminate the
required real link rejection on either OS family.

### 14. Use repository-local IDs and shared semantic identities

Every Terraform ID in the table is namespaced `T1A-`. Every row/result also
contains the explicit unique semantic key shown in the table, matching
`^[a-z][a-z0-9]*(\.[a-z][a-z0-9-]*)+$`. IDs and keys are opaque,
append-only, and never changed/reused after merge.

Reciprocal equality means exact equality of semantic key, fixture,
applicability, result, terminal phase/subreason/status, candidate/context
states, diagnostics, sentinel, and cleanup sequence. The P1A↔T1A matrix records
`SemanticCase`, immutable P commit/local ID/evidence, immutable T commit/local
ID/evidence, classification (`same|intentional difference|blocker`), and
rationale. A grouped, missing, or divergent P row is a blocker, not an assumed
oracle. Runtime never downloads or executes the other repository.

Add catalog fixtures for duplicate/missing local ID, duplicate/missing semantic
key, changed mapping, equal key with different expected fields, missing
counterpart classification, and intentional difference without rationale.

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
- [ ] The machine-readable harness inventory exactly equals the normative
      one-row-per-ID table, with no renumbered surviving behavior.
- [ ] Declared and actual resource boundaries pass below/exact cases and reject
      above/overflow/deceptive cases as specified.
- [ ] Both cleanup lifecycles pass independent and combined
      primary-plus-cleanup-failure cases.
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
