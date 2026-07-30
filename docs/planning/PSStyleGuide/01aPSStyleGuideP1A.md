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

Before filing/readying P1A, insert P1's canonical PSStyleGuide issue URL,
create the real GitHub `blocked by` relationship, retrieve both issues, and
verify repository/number/title/relationship. Do not use a placeholder.

Record:

- P1's actual issue/blocked-by relationship;
- its exact merge commit;
- the exact generator version;
- the active advisory-risk decision;
- exact workflow-policy validator/parser and Git path-set verifier versions,
  hashes, and fixture results;
- P1's completed P1↔T1 matrix; and
- passing generator/action/runtime evidence.

Stop if the decision is expired/materially contradicted, the real GitHub
blocked-by relationship is absent, any recorded P1 tool/evidence identity
differs, or P1↔T1 has an unresolved blocker.

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
versioned structured context containing exactly:

- nonempty scalar schema/script versions and invocation ID;
- scalar normalized FileSystem parent, fresh invocation root, fresh download
  directory, and initially absent candidate path;
- nonempty scalar diagnostic label;
- lifecycle state from the closed set `Active`, `CleanupFailed`, `Disposed`;
  and
- an ordered collection of ownership records, each with kind, normalized path,
  parent relationship, creation phase, and expected ordinary type.

Removal accepts that context, explicit ordinary paths owned by the invocation,
and any primary failure. It never infers ownership through recursive
enumeration. It validates the complete schema and relationships before
deletion and transitions the same context to `Disposed` only after complete
proved cleanup.

A second removal is a successful no-op only for the same valid `Disposed`
context and only after proving no journaled entry reappeared. An `Active`
context with missing, unexpected, unreadable, or substituted state becomes
`CleanupFailed`, retains uncertainty, and reports it. A missing path never
implies prior disposal.

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
the primary failure. Set `Disposed` only after all journaled entries and
directories are proved removed. Set `CleanupFailed` on uncertainty/failure and
never convert it to `Disposed` because a later path lookup is missing.

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

The table below is the closed mandatory inventory. No grouped range is an
oracle. `All` means Windows PowerShell 5.1 on Windows, PowerShell 7 on Windows,
and PowerShell 7 on Ubuntu. Windows/Linux rows execute only on the named OS
family and have an explicit expected status in the applicability matrix.

Every result also records exact fixture parameters, platform/edition, expected
and actual status/phase, candidate/archive/download/context state before
harness teardown, candidate and caller cleanup owner/result, required
structured diagnostic fields, and outside-sentinel/source-repository
postcondition.

| ID | Exact fixture | Runtime | Exact phase and pre-teardown oracle |
| --- | --- | --- | --- |
| `V-01` | exact four-entry valid archive | All | success; four exact ordinary files; candidate then caller cleanup succeed |
| `V-02` | valid entries with symlink-like external attributes | All | success; attributes ignored; four ordinary files |
| `P-01` | checkout sibling-prefix path | All | `containment`; candidate absent; context active |
| `P-02` | FileSystem-provider-qualified absolute inputs | All | success; normalized paths equal native-path control |
| `D-01` | digest mismatch with all labels supplied | All | `digest`; archive held but unopened as ZIP; candidate absent; labels exact |
| `D-02` | digest mismatch with labels omitted | All | `digest`; candidate absent; labels are `unavailable` |
| `D-03` | 63-hex expected digest | All | `parameter`; no download enumeration/archive open; candidate absent |
| `D-04` | 64 characters containing nonhex | All | `parameter`; no filesystem work; candidate absent |
| `D-05` | `sha256:`-prefixed digest | All | `parameter`; no filesystem work; candidate absent |
| `Z-01` | invalid/truncated ZIP with matching digest | All | `archive`; held stream disposed; candidate absent |
| `M-01` | one required entry missing | All | `manifest`; candidate absent |
| `M-02` | one extra entry | All | `manifest`; candidate absent |
| `M-03` | exact duplicate name | All | `manifest`; candidate absent |
| `M-04` | case-insensitive name collision | All | `manifest`; candidate absent |
| `M-05` | nested name using `/` | All | `manifest`; candidate absent |
| `M-06` | nested name using `\` | All | `manifest`; candidate absent |
| `M-07` | traversal name using `/` | All | `manifest`; candidate absent |
| `M-08` | traversal name using `\` | All | `manifest`; candidate absent |
| `M-09` | leading `/` | All | `manifest`; candidate absent |
| `M-10` | leading `\` | All | `manifest`; candidate absent |
| `M-11` | drive-qualified name | All | `manifest`; candidate absent |
| `M-12` | directory entry | All | `manifest`; candidate absent |
| `M-13` | file/directory collision | All | `manifest`; candidate absent |
| `M-14` | reviewed raw ZIP with empty name | All | `manifest`; candidate absent; fixture SHA exact |
| `E-01` | download/candidate outside trusted root | All | `containment`; candidate absent |
| `E-02` | checkout and trusted roots equal | All | `root`; candidate absent |
| `E-03` | checkout contains trusted root | All | `root`; candidate absent |
| `E-04` | trusted root contains checkout | All | `root`; candidate absent |
| `E-05` | relative root/working path | All | `parameter`; candidate absent |
| `E-06` | non-FileSystem provider path | All | `parameter`; candidate absent |
| `E-07` | Windows case-variant containment | Windows | ordinal-ignore-case expected containment result; candidate absent |
| `E-08` | Linux case-variant containment | Linux | ordinal expected noncontainment/control result; candidate absent |
| `E-09` | root or ancestor link/reparse component | Per OS | `root`; candidate absent; target unchanged |
| `E-10` | below-root link/reparse component | Per OS | `containment`; candidate absent; target unchanged |
| `E-11` | hidden/system extra download entry | All | `download`; candidate absent |
| `E-12` | wildcard root/working path | All | `parameter`; candidate absent |
| `E-13` | multiple-resolution path | All | `parameter`; candidate absent |
| `E-14` | missing required root/path | All | `root`; candidate absent |
| `E-15` | file where directory required | All | `root`; candidate absent |
| `L-01` | preexisting ordinary candidate file | All | `destination`; leaf unchanged |
| `L-02` | preexisting candidate directory | All | `destination`; leaf unchanged |
| `L-03` | live link/reparse candidate leaf | Per OS | `destination`; leaf/target unchanged |
| `L-04` | dangling link candidate leaf | Per OS | `destination`; link unchanged |
| `B-01` | extracted file begins with UTF-8 BOM | All | `post-extraction`; candidate cleanup removes owned partial only |
| `B-02` | extracted file contains `0x0D` | All | `post-extraction`; candidate cleanup removes owned partial only |
| `K-01` | unjournaled ordinary candidate child | All | `cleanup`; candidate retained; no further deletion |
| `K-02` | link/reparse substitution in candidate | Per OS | `cleanup`; candidate/target retained unchanged |
| `K-03` | repeated candidate cleanup after safe removal | All | success/no-op under disposed candidate state; no unrelated deletion |
| `K-04` | primary failure then candidate-cleanup failure | All | primary prominent; cleanup reason and retained state reported |
| `C-01` | normal caller-context teardown | All | success; journaled entries removed deepest-first; state `Disposed` |
| `C-02` | repeated caller-context teardown | All | success/no-op only for same valid `Disposed` context |
| `C-03` | unjournaled ordinary context entry | All | `cleanup`; state `CleanupFailed`; entire uncertain context retained |
| `C-04` | link/reparse substitution in context | Per OS | `cleanup`; context/target retained unchanged |
| `C-05` | missing/unreadable journaled context entry | All | `cleanup`; state `CleanupFailed`; no further deletion |
| `C-06` | primary failure then caller-cleanup failure | All | primary prominent; cleanup reason/root/state reported |
| `C-07` | proven partial ordinary ownership journal | All | success only for exact journaled entries; no unjournaled deletion |
| `C-08` | candidate cleanup then context cleanup | All | success; exact production lifecycles invoked in order |
| `R-01` | entry one byte below 8 MiB | All | manifest passes; content oracle continues |
| `R-02` | entry exactly 8 MiB | All | inclusive boundary passes |
| `R-03` | declared entry one byte above 8 MiB | All | `manifest`; candidate absent |
| `R-04` | actual entry exceeds permitted/declared bytes | All | `extraction`; stop at first excess; owned partial removed |
| `R-05` | declared total one byte below 32 MiB | All | manifest passes |
| `R-06` | declared total exactly 32 MiB | All | inclusive boundary passes |
| `R-07` | declared total one byte above 32 MiB | All | `manifest`; candidate absent |
| `R-08` | actual cumulative output exceeds 32 MiB | All | `extraction`; stop at first excess; owned partial removed |
| `R-09` | retained archive exactly 32 MiB | All | inclusive archive boundary proceeds |
| `R-10` | retained archive one byte above 32 MiB | All | pre-ZIP `archive` limit failure; candidate absent |
| `R-11` | reviewed raw ZIP with negative/inconsistent length | All | `manifest`; candidate absent; fixture SHA exact |
| `R-12` | length arithmetic overflow fixture | All | `manifest`; checked overflow; candidate absent |
| `R-13` | retained archive one byte below 32 MiB | All | archive boundary proceeds |
| `W-01` | empty download directory | All | `download`; candidate absent |
| `W-02` | two top-level download entries | All | `download`; candidate absent |
| `W-03` | directory as sole download entry | All | `download`; candidate absent |
| `W-04` | link/reparse as sole download entry | Per OS | `download`; target unchanged; candidate absent |
| `W-05` | unreadable/unclassifiable download entry | All | `download`; candidate absent |
| `S-01` | missing helper script path | All | harness input failure before context creation |
| `S-02` | wildcard helper path | All | harness input failure before context creation |
| `S-03` | non-FileSystem helper path | All | harness input failure before context creation |
| `S-04` | multiple-resolution helper path | All | harness input failure before context creation |
| `S-05` | reparse/untracked helper path | Per OS | harness input failure before context creation |
| `S-06` | missing context-manager path | All | harness input failure before context creation |
| `S-07` | wildcard context-manager path | All | harness input failure before context creation |
| `S-08` | non-FileSystem context-manager path | All | harness input failure before context creation |
| `S-09` | multiple-resolution context-manager path | All | harness input failure before context creation |
| `S-10` | reparse/untracked context-manager path | Per OS | harness input failure before context creation |
| `S-11` | both scripts provider-qualified and valid | All | exact tracked versions resolve and proceed |
| `X-01` | explicit empty `ArtifactId` | All | `parameter`; no filesystem work; candidate absent |
| `X-02` | explicit empty `RunId` | All | `parameter`; no filesystem work; candidate absent |
| `X-03` | explicit empty `RunAttempt` | All | `parameter`; no filesystem work; candidate absent |
| `X-04` | explicit null `ArtifactId` | All | `parameter`; no filesystem work; candidate absent |
| `X-05` | explicit null `RunId` | All | `parameter`; no filesystem work; candidate absent |
| `X-06` | explicit null `RunAttempt` | All | `parameter`; no filesystem work; candidate absent |
| `X-07` | valid nonempty labels | All | selected digest failure preserves exact label text |
| `X-08` | array/object supplied as `ArtifactId` | All | binding/`parameter` failure; no filesystem work |
| `X-09` | array/object supplied as `RunId` | All | binding/`parameter` failure; no filesystem work |
| `X-10` | array/object supplied as `RunAttempt` | All | binding/`parameter` failure; no filesystem work |

Closed applicability:

| Runtime | Required executable rows | Fixed expected skip | Conditionally skippable only after exact primitive probe |
| --- | --- | --- | --- |
| Windows PowerShell exactly 5.1 | every `All`, `Windows`, and `Per OS` row | `E-08` with `linux-comparison-only` | `E-09`, `E-10`, `L-03`, `L-04`, `K-02`, `C-04`, `W-04`, `S-05`, `S-10` |
| PowerShell 7 on Windows | every `All`, `Windows`, and `Per OS` row | `E-08` with `linux-comparison-only` | `E-09`, `E-10`, `L-03`, `L-04`, `K-02`, `C-04`, `W-04`, `S-05`, `S-10` |
| PowerShell 7 on Ubuntu | every `All`, `Linux`, and `Per OS` row | `E-07` with `windows-comparison-only` | `E-09`, `E-10`, `L-03`, `L-04`, `K-02`, `C-04`, `W-04`, `S-05`, `S-10` |

Every runtime emits one record for all 96 IDs, including fixed/conditional
skip records. A negative-case oracle that correctly observes the required
helper failure reports harness status `pass`; `fail` means the harness did not
meet the row.

Required common postconditions:

- pre-creation failures leave candidate absent;
- explicit-null/empty/non-scalar failures prove no filesystem work;
- preexisting leaves remain unchanged/unfollowed;
- helper partial state is removed only by candidate cleanup;
- caller state is removed only by caller cleanup;
- uncertain state is retained as `CleanupFailed`;
- sentinels and source repository remain byte-identical; and
- digest mismatch precedes ZIP construction.

Maintain one closed runtime applicability matrix with expected `pass`, `fail`,
or specifically authorized primitive-dependent `skip` for every ID/runtime
pair. Missing/unexpected/duplicate ID, status mismatch, unexpected skip, or
pass/fail/skip total mismatch fails the harness. A skip records ID, runtime,
primitive probe, and reason and never counts as pass.

At least one real root/ancestor link rejection, below-root link rejection,
candidate-leaf substitution, and caller-context substitution executes per OS
family. Failure to meet that minimum fails the runtime even if individual skip
records are well formed.

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
Git, catalog version, expected/actual pass/fail/skip totals, and duration.
Every mandatory ID reports exactly one expected status in each runtime's
closed applicability matrix.

Static checks prove:

- no recursive/wildcard deletion;
- no automatic ZIP extraction;
- no ambient root derivation;
- exact one definition of each cleanup function;
- normal/helper harness use exact production cleanup;
- every exact enumeration includes hidden/system entries;
- context schema/state transitions and repeated cleanup match the exact public
  contract;
- P1's exact tracked Git path-set verifier proves only the three affected files
  changed/staged before and after rerun; and
- generator, workflows, artifacts, package/update policy remain unchanged.

If hosted evidence requires a temporary workflow, use exactly
`.github/workflows/evidence-p1a-harness.yml`; remove it before the final commit
and use the tracked path-set verifier to prove it is absent.

## Acceptance criteria

- [ ] All three scripts are versioned PowerShell 5.1-compatible LF/BOM-less
      files.
- [ ] The harness accepts exact helper and context-manager paths.
- [ ] Caller acquisition proves fresh ownership with bounded collision-only
      retry.
- [ ] The context has the exact versioned field types and
      `Active`/`CleanupFailed`/`Disposed` transitions.
- [ ] Both cleanup paths are nonrecursive, journal-based, and retain uncertain
      state.
- [ ] Repeated cleanup succeeds only for the same valid disposed context/state;
      missing active state never implies disposal.
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
- [ ] All 96 mandatory IDs have one explicit fixture/runtime/status/phase/
      pre-teardown/cleanup/diagnostic/sentinel oracle.
- [ ] Missing, duplicate, unexpected, skipped, or mismatched ID/status/totals
      fail the harness.
- [ ] Real link/reparse rejection executes on both OS families.
- [ ] P1A↔T1A has no unexplained blocker.
- [ ] P1's exact raw NUL-safe verifier proves final working/staged path sets
      equal the three affected files.
- [ ] No production workflow consumes the scripts.

## Handoff

Provide P1B with P1A's actual issue URL, final merge commit, helper/context/
harness versions and hashes, catalog version, all per-runtime results and skip
probes, exact context-state/cleanup evidence, final path-set proof, and the
P1A↔T1A matrix. P1B records receipt in its own dependency gate.

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
