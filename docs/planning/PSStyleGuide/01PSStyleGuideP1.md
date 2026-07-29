# Make artifact generation byte-deterministic across PowerShell editions and hosts

## Summary

`.github/workflows/Generate-StyleGuideArtifacts.ps1` writes all four generated artifacts with `Set-Content -Encoding UTF8 -NoNewline`. `UTF8` is edition-divergent: Windows PowerShell 5.1 writes a UTF-8 BOM, while PowerShell 7 does not. The generator declares `#Requires -Version 5.1`, so the same supported script can currently emit different bytes depending on the PowerShell edition.

Line endings are another serialization boundary. Source documents and generator-authored literals can contribute CRLF or lone-CR characters to final payloads. The existing repository-wide rule:

```gitattributes
* text=auto eol=lf
```

correctly standardizes Git-managed text checkouts on LF and must remain unchanged. It is a checkout invariant, not a replacement for producer correctness.

Make generation byte-deterministic and establish an end-to-end provenance chain:

- Normalize CRLF and lone CR to LF in each complete final payload immediately before serialization.
- Write every artifact with BOM-less `UTF8Encoding($false)`.
- Resolve PowerShell paths before passing them to `System.IO.*`.
- Replace the frontmatter here-string with an LF-joined literal.
- Record versions for the generator, the new archive-validation helper, and its tracked self-test harness.
- Remove path filters from both workflow events while retaining `main` branch filters.
- Make stale committed artifacts fail pull-request validation.
- Pin checkout, setup-node, artifact upload, and artifact download actions to approved full commit SHAs.
- Run Markdown lint on Node 24 with explicit read-only permissions and automatic package-manager caching disabled.
- Prepare one immutable push candidate in a read-only job.
- Download that candidate by immutable artifact ID.
- Require native fail-closed digest validation and pass preparation's propagated upload digest to the shared archive-validation helper, which independently hashes the exact retained stream it later parses.
- Create one unique job-owned trusted temporary root in every helper consumer.
- Validate every existing path component from the filesystem volume/share root,
  repeat the checks at security boundaries, and state the residual
  no-competing-writer model.
- Open the retained archive with explicit `FileShare.Read`.
- Preserve pre-existing candidate state and safely remove only
  invocation-created output after a later rejection through one journaled,
  named, directly tested fail-closed cleanup function.
- Use one shared, versioned PowerShell helper for candidate digest verification, archive validation, and extraction in every started push consumer.
- Define the deterministic fixture suite once in a tracked, versioned PowerShell harness.
- Run that harness against the exact helper before merge on Ubuntu PowerShell 7, Windows PowerShell 5.1, and Windows PowerShell 7.
- Require at least one real filesystem-link/reparse rejection on each operating
  system family; a platform-wide link-fixture skip is not passing evidence.
- Run the same harness against that exact helper in every started push consumer before each production invocation.
- Validate the candidate in an actual four-cell edition × fixture-EOL Windows matrix.
- Run the lone-CR sanitation probe once under each edition.
- Approve the candidate only after the complete matrix succeeds.
- Give `contents: write` only to the final synchronization job.
- Prove candidate, destination, index, and committed-blob identity.
- Push with an explicit destination refspec and exact expected-SHA `--force-with-lease`.
- Check every native-command exit code immediately.
- Preserve useful diagnostic artifacts after ordinary pull-request failures.
- Require local validation to assert each PowerShell edition/version in the
  same child process that runs the harness or generator before another edition
  can overwrite its output.
- Add review-only weekly GitHub Actions update proposals while retaining
  immutable full-SHA execution pins and human review.
- Refuse to stage from a working tree containing any path other than the six
  implementation files.
- Mechanically require every external action to match its exact approved
  repository, full SHA, release comment, and workflow role.

This issue is a prerequisite for **Make the non-compliant blank-line example visibly distinct**.
The separately scoped P3 issue,
**Remediate Markdown lint dependency advisories and add npm update governance**,
follows P2 and is not part of this implementation.

## Affected files

- `.github/workflows/Generate-StyleGuideArtifacts.ps1`
- `.github/workflows/Expand-StyleGuideCandidateArtifact.ps1` — add.
- `.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1` — add.
- `.github/workflows/build.yml`
- `.github/workflows/markdownlint.yml` — change only the checkout and setup-node references, Node version, package-manager-cache setting, and explicit read-only permissions unless Node 24 compatibility validation proves another change is required.
- `.github/dependabot.yml` — add one review-only weekly `github-actions`
  update entry.

Do not modify `.gitattributes`.

The following generated artifacts are exercised during validation but must remain byte-for-byte unchanged:

- `copilot-instructions.md`
- `powershell.instructions.md`
- `STYLE_GUIDE_CHAT.md`
- `STYLE_GUIDE_FULL.md`

Do not hand-edit them.

## Requested changes

### 1. Normalize every complete final payload

Immediately before encoding and writing, normalize the complete final payload:

| Function | Complete final payload |
| --- | --- |
| `New-StyleGuideCopilotVersion` | `$strContent` |
| `New-StyleGuidePowerShellInstructionsVersion` | `$strFullContent` |
| `New-StyleGuideChatVersion` | `$strWrappedContent` |
| `New-StyleGuideFullVersion` | `$strOutput` |

Use:

```powershell
$strNormalizedContent = <complete final payload> -replace "`r`n?", "`n"
```

Replace the placeholder with the applicable variable.

Normalize only after all transformations and concatenations. Source-only normalization is insufficient because generator literals can also contribute newline characters.

Preserve `New-StyleGuideFullVersion`'s existing `\r?\n` split and LF join. Final-payload normalization remains required as the uniform serialization invariant.

LF and CRLF are the supported source-EOL equivalence cases. The serialization boundary must remove every CR from final output, but this issue does not claim semantic compatibility with CR-only or mixed-EOL source documents.

### 2. Replace all four artifact write sites

Replace the four artifact-writing `Set-Content` calls with the following pattern:

```powershell
$strNormalizedContent = <complete final payload> -replace "`r`n?", "`n"
$objUtf8NoBomEncoding = New-Object System.Text.UTF8Encoding($false)
$strResolvedDestinationPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
    $DestinationPath
)

[System.IO.File]::WriteAllText(
    $strResolvedDestinationPath,
    $strNormalizedContent,
    $objUtf8NoBomEncoding
)
```

`WriteAllText` must receive the normalized value. It must not append an additional line terminator.

Afterward:

- Each generator function normalizes its complete payload immediately before writing.
- Each destination path is resolved before being passed to `System.IO.File`.
- Each write uses `UTF8Encoding($false)`.
- No artifact-writing `Set-Content` call remains.

### 3. Replace the frontmatter here-string

Use:

```powershell
# Define the YAML frontmatter with LF newlines so regenerated files stay
# stable across Windows and POSIX runners.
$strFrontmatter = @(
    '---'
    'applyTo:  "**/*.ps1"'
    'description: "PowerShell coding standards"'
    '---'
    ''
    ''
) -join "`n"
```

Preserve the two spaces after `applyTo:` and the two final LF characters.

### 4. Record workflow-script versions

All three PowerShell files must contain a top-level comment-based-help `.NOTES` version.

For the new helper and self-test harness, and for the generator if it is still unversioned, use:

```text
Version: 1.0.YYYYMMDD.0
```

Use the current UTC date. At implementation finalization, reread the target branch's top-level `.NOTES` before deciding.

If a generator version already exists, follow the PSStyleGuide Function and Script Versioning policy:

- This serialization correction is fix-class, so do not increment Major or Minor solely for this issue.
- Set Build to the current UTC `YYYYMMDD`.
- Set Revision to `0` when `Major.Minor.Build` changes.
- If the same `Major.Minor.Build` already exists at Revision `N`, use `N + 1`.

Do not change the style guide's own version or metadata.

### Cross-repository generator convergence contract

P1 and the parallel T1 issue intentionally converge generator algorithms,
serialized bytes, failure semantics, and evidence while retaining
repository-local scripts. This matrix defines the PSStyleGuide side:

| Generator area | Deliberately shared target | Intentional repository-specific difference |
| --- | --- | --- |
| Serialization boundary | Normalize each complete final payload with ``-replace "`r`n?", "`n"`` immediately before encoding; resolve the destination; use `UTF8Encoding($false)` and `WriteAllText`; append no implicit newline. | Complete-payload variable names may differ. |
| Common artifact functions | Preserve equivalent observable behavior for the Copilot, Chat, and Full artifact functions. | Guide-specific Full transformations and source/rationale content may differ. |
| Instructions artifact | Use the same serialization primitive and LF-stable frontmatter principles. | Function name, output filename, `applyTo`, and description are PowerShell- versus Terraform-specific. |
| Frontmatter | Construct reviewed lines as an LF-joined array with explicit spaces and final-LF count. | P1 replaces a here-string; current T1 already has an LF-joined form. |
| Script versioning | Use the PSStyleGuide `.NOTES` version calculation policy and retain the supported `#Requires -Version 5.1` baseline. | Starting versions and implementation UTC dates may differ. |
| Repository text policy | Treat LF checkout policy and producer correctness as complementary controls. | P1 preserves its existing `.gitattributes`; T1 adds the same rule because its repository lacks the file. |
| Validation | Prove Windows PowerShell 5.1/PowerShell 7 and LF/CRLF producer equivalence with logical and raw-byte checks. | PSStyleGuide also validates its Node 24 Markdown workflow and PowerShell-specific artifact name. |

Do not infer implementation identity from this matrix. If either issue
introduces a private serialization abstraction, coordinate its observable
contract before implementation rather than creating a P1-only abstraction.
A shared package, module, submodule, or reusable action is not part of either
issue.

Immediately before implementation, compare this matrix with the then-current
T1 issue or merged evidence. The implementation that starts second must record
every remaining intentional difference in issue/PR evidence. This comparison
does not create a runtime, filing, or merge dependency between repositories.

### 5. Run both event pipelines without path filters

Retain:

```yaml
on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
```

Do not configure `paths` or `paths-ignore` for either event.

Do not use workflow concurrency as the correctness mechanism. Correctness comes from exact-SHA checkout, immutable candidate transport, complete validation, and the exact expected-SHA lease.

A synchronization push made with the repository's `GITHUB_TOKEN` does not recursively start another workflow run. Retain `[skip ci]` only as a compatibility convention and defense in depth.

### 6. Add one shared archive-validation and extraction helper

Create:

```text
.github/workflows/Expand-StyleGuideCandidateArtifact.ps1
```

The helper and its harness remain repository-local. Neither repository has a
runtime dependency on the other.

#### Cross-repository convergence contract

P1 and the parallel T1 issue intentionally converge on observable security
invariants, not byte-identical implementations. This matrix defines the
PSStyleGuide side of that contract:

| Contract area | Deliberately shared invariant | P1 implementation and intentional repository-specific choice |
| --- | --- | --- |
| Public parameters | Required root/path/digest parameters and optional caller-owned artifact/run labels have matching names and meanings. | P1 uses the exact scalar parameters below; callers supply PSStyleGuide values. |
| Archive identity | Open one retained `FileStream` with `FileMode.Open`, `FileAccess.Read`, and `FileShare.Read`; hash that stream, compare the propagated 64-hex digest before archive construction, rewind it, and retain the only `ZipArchive` over that stream through extraction. | P1 applies the shared sequence to the PSStyleGuide candidate; manifest and diagnostic values remain repository-specific. |
| Path security | Use explicit mutually separate roots, strict containment, complete component checks, repeated validation, and an honest no-competing-writer operating model. | P1 applies the contract below to the PSStyleGuide checkout, download, and candidate names. |
| Manifest grammar | Reject duplicates, collisions, directories, nested/traversal/absolute names, and any entry outside one exact root-level allowlist. | P1 permits the four PSStyleGuide artifact names below; T1 has its own manifest names. |
| Candidate lifecycle | Never overwrite/reuse a leaf, preserve pre-existing state, and clean invocation-created state after later failure without unsafe recursion. | P1 returns four PSStyleGuide candidate paths and uses the cleanup contract below. |
| Diagnostics | Use stable phases, normalized paths/digests, and optional caller-owned labels that distinguish omitted from explicitly empty. | P1 uses the exact phases and stable case IDs below; values come from the current workflow run. |
| Permanent fixtures | Exercise ordinary archive/path behavior through the production helper's public expansion interface. Permit one narrow definition-only exception that directly invokes the exact named production cleanup function for deterministic unsafe-cleanup evidence. | Case IDs and platform setup may differ. P1 deliberately runs pull-request helper coverage on Ubuntu and the two Windows LF cells because helper behavior is independent of source fixture EOL; T1 repeats it in all Windows pull-request cells. |
| Artifact transport | Select one immutable artifact ID, fail closed on native digest mismatch, and independently verify the propagated upload digest. | P1 uses the exact upload/download action versions and raw/archived shape specified in this issue. |

Immediately before implementation, reread the then-current T1 contract and
record any new intentional divergence in issue/PR evidence. Do not describe
filenames or artifact names as the only differences. A future
shared module/action would need its own versioning, immutable pinning,
provenance, cross-edition compatibility, failure-mode, and coordinated-rollout
design. Creating that package is not part of P1; first converge and prove the
behavioral contracts.

The script must:

- Declare `#Requires -Version 5.1`.
- Record its script version.
- Accept these mandatory scalar parameters:
  - `CheckoutRoot`;
  - `TrustedTemporaryRoot`;
  - `DownloadDirectory`;
  - `CandidateDirectory`; and
  - `ExpectedDigest`.
- Accept optional scalar diagnostic parameters:
  - `ArtifactId`;
  - `RunId`; and
  - `RunAttempt`.
- Resolve filesystem paths before using `.NET` static methods.
- Work under Windows PowerShell 5.1 and PowerShell 7 on Windows and Ubuntu.
- Load required compression assemblies explicitly under Windows PowerShell 5.1.

The parameter names and semantics are intentionally part of the target P1/T1 shared contract. Do not replace them with ambient current-directory state, `git rev-parse`, `GITHUB_WORKSPACE`, GitHub environment-variable discovery inside the helper, a hashtable, or a configuration file.

#### Root and full-component trust contract

The helper must:

1. Require `CheckoutRoot` and `TrustedTemporaryRoot` to each resolve to exactly
   one existing ordinary filesystem-provider directory.
2. Require rooted native or filesystem-provider-qualified absolute paths.
   Reject wildcards, relative paths, non-filesystem providers, nonexistent
   roots, files, and reparse/symbolic-link roots.
3. Require the checkout and trusted temporary roots to be mutually
   non-overlapping: neither may equal or contain the other.
4. Require `DownloadDirectory` and `CandidateDirectory` to be strict
   descendants of the trusted temporary root and outside the checkout.
5. Normalize directory roots with exactly one trailing platform directory
   separator before descendant comparison.
6. Use ordinal case-insensitive comparison on Windows and ordinal
   case-sensitive comparison on Linux. Never use culture-sensitive comparison
   or a raw, unterminated string prefix.
7. Resolve the existing download directory through the filesystem provider.
8. Resolve and validate the candidate directory's existing parent before
   deriving one unresolved leaf name. Reject an empty name, `.` or `..`,
   separators, rooted input, or any value whose full path changes the parent.
9. Build the lexical absolute component sequence from the filesystem
   volume/share root through every existing component of:
   - both declared roots;
   - the download directory and retained archive;
   - the existing candidate parent; and
   - each candidate path after creation.
10. Obtain every component's attributes through APIs available under Windows
    PowerShell 5.1 and reject:
    - `FileAttributes.ReparsePoint`;
    - a symbolic link, junction, volume-mount/reparse entry, or dangling entry;
    - a file where a directory is required;
    - a directory where a regular file is required; and
    - any attribute, enumeration, or resolution failure.
11. Never follow a link merely to classify the component as safe.
12. Materialize
    `[System.IO.Directory]::EnumerateFileSystemEntries()` for every
    security-sensitive exact count or set. During the candidate-leaf phase,
    compare parent-entry leaf names with ordinal-ignore-case on Windows and
    ordinal on Linux. Reject any matching file, directory, symlink, reparse
    point, or dangling link. Do not use `File.Exists`, `Directory.Exists`, or
    provider filtering as proof that no leaf entry exists.
13. Repeat the relevant full-component, containment, type, parent, and leaf
    checks immediately before opening the archive, immediately before creating
    the candidate directory, and after extraction before returning paths.

The supported operating model is a GitHub-hosted runner with
runner-controlled ancestors, a job-owned checkout, one unique job-owned
trusted temporary root, and no competing writer capable of replacing entries
during the helper call. Repeated validation narrows time-of-check/time-of-use
risk; it does not claim an OS-native directory-handle guarantee.

#### Parameter and diagnostic contract

Before filesystem or archive processing:

1. Validate every mandatory parameter as one scalar value.
2. Use `$PSBoundParameters.ContainsKey(...)` independently for `ArtifactId`,
   `RunId`, and `RunAttempt`.
3. Reject an explicitly supplied empty diagnostic label and name the exact
   parameter.
4. Represent an omitted optional label with the literal `unavailable`.
5. Preserve each supplied nonempty label exactly and never invent a value.

Diagnostics must include the stable phase, all label states, normalized roots,
archive path, expected digest, actual digest when computed, and the offending
component/entry where applicable.

`Get-ChildItem` is not a security decision primitive in this helper. If it is used to format diagnostics, require `-LiteralPath -Force`.

#### Download-directory contract

The helper must require:

- The download directory exists within the trusted temporary root and outside the tracked checkout.
- Materializing `[System.IO.Directory]::EnumerateFileSystemEntries()` returns exactly one filesystem entry, including hidden and system entries.
- That entry is a regular, non-reparse-point file.
- The file can be opened once as a read-only, seekable stream.

Do not require a `.zip` filename extension; validate the archive by constructing `ZipArchive` over the held stream only after digest comparison. The retained file's name comes from the download's Content-Disposition header and may be the literal fallback name `artifact`.

#### Expected-digest contract

After path/type checks and immediately before archive parsing, the helper must:

1. Require the expected digest to match `^[0-9A-Fa-f]{64}$`.
2. Open the retained file exactly once with a constructor available under both
   supported editions using:
   - `FileMode.Open`;
   - `FileAccess.Read`; and
   - `FileShare.Read`.
3. Calculate SHA-256 by passing that stream to `Get-FileHash -InputStream -Algorithm SHA256`.
4. Require exactly one hash object and one 64-hex digest.
5. Compare the actual and expected digests using ordinal, case-insensitive equality.
6. Fail before `ZipArchive` construction and candidate-leaf creation if they differ.
7. Rewind the same seekable stream to position zero.
8. Construct one read-mode `ZipArchive` over that same stream and use that archive instance through manifest validation and extraction.
9. Dispose entry streams, the archive, and the underlying file stream in deterministic nested `try`/`finally` blocks.
10. Record the caller-supplied artifact ID, expected digest, actual digest, caller-supplied run ID, caller-supplied run attempt, and archive path in diagnostics; label omitted optional values as unavailable.

Do not grant `FileShare.Write` or `FileShare.Delete`. `FileShare.Read` permits
benign secondary .NET readers while the stream is held; it is defense in depth,
not a universal cross-platform lock. The no-competing-writer model above
remains required.

The helper must not hash by path and then reopen by path for parsing. The held
stream is the security identity.

The expected value is always the propagated `artifact-digest` output of the pinned upload action, which is a bare hexadecimal SHA-256 string. Never supply the `sha256:`-prefixed form that appears in download-action logs and artifact API metadata.

#### Manifest contract

Using the one `ZipArchive` constructed over the matching-digest held stream, and before creating the candidate destination directory, require exactly these four ordinal, root-level, non-directory entry names:

```text
copilot-instructions.md
powershell.instructions.md
STYLE_GUIDE_CHAT.md
STYLE_GUIDE_FULL.md
```

Reject:

- Missing or extra entries.
- Empty entry names.
- Directory entries.
- Exact duplicates.
- Case-insensitive duplicates or collisions.
- `/` or `\` separators.
- Nested names.
- Traversal names.
- Absolute names.
- Drive-qualified names.
- File/directory collisions.

Complete manifest validation before creating or writing the candidate directory.

#### Destination-directory lifecycle

The caller creates the unique trusted temporary root and may create the
candidate's protected parent beneath it. The candidate leaf must have no
filesystem entry.

The helper must:

1. Resolve the candidate leaf path without creating it.
2. Assert that it is a strict descendant of the trusted temporary root and outside the checkout.
3. Validate the digest, the complete archive, and the manifest.
4. Enumerate the existing parent and prove no entry has that leaf name.
5. Repeat containment, indirection, and exact parent enumeration to reconfirm that the leaf remains absent.
6. Create the leaf exactly once.
7. Never delete and recreate it.
8. Refuse to reuse an existing leaf.
9. Maintain an exact ownership journal containing only:
   - the normalized candidate directory created by this invocation; and
   - each normalized ordinary file after its `FileMode.CreateNew` open
     succeeds.
10. Define one private production cleanup function named
    `Remove-StyleGuideCandidateInvocationState`. The production failure path
    must call that exact function; no copied cleanup implementation is
    permitted.
11. If a later phase fails, capture the original failure and dispose every
    entry stream, the `ZipArchive`, and the retained file stream before calling
    cleanup.
12. Before deleting anything, the cleanup function must complete one full
    pre-deletion safety pass:
    - revalidate every existing component from the filesystem root through the
      trusted root, candidate parent, and candidate leaf;
    - require the candidate leaf to remain the exact ordinary, non-reparse
      directory journaled by this invocation;
    - materialize and exhaustively enumerate its immediate children;
    - require exact ordinal/platform-appropriate equality with the journaled
      file set; and
    - require every expected child to remain one ordinary, non-reparse file
      without following a link.
13. Only after that complete pass may cleanup delete journaled files
    individually and nonrecursively, re-prove that the candidate directory is
    empty and ordinary, and remove that directory nonrecursively.
14. If any component/entry is missing, extra, replaced, unreadable, linked,
    reparse, or otherwise uncertain, stop before deletion. Never traverse,
    recurse, follow, repair, or partially “make progress” through unsafe state.
15. Preserve the original failure and add stable phase `cleanup`, the retained
    absolute path, a safely available offending entry, and the cleanup
    exception when present. Return nonzero.

Place all private function declarations before the helper's main entry point.
Permit ordinary PowerShell definition-only dot-sourcing solely so the tracked
harness can load and invoke the exact cleanup function without running the
expansion entry point. Do not add a public test switch, environment backdoor,
second extraction interface, or cleanup parameter to the public expansion
contract.

Required rejection postconditions are:

| Initial candidate leaf | Rejection postcondition |
| --- | --- |
| Absent | Remains absent for every pre-creation failure |
| Ordinary file | Same file and bytes remain unchanged |
| Ordinary directory | Same directory and contents remain unchanged |
| Link, junction, reparse point, or dangling link | Same entry and link target text remain unchanged |
| Created by this invocation; journal and envelope remain exact ordinary state | Removed after a later failure |
| Created by this invocation; state is missing, extra, replaced, unreadable, linked, reparse, or otherwise uncertain | Retained without traversal or partial deletion; the primary failure and stable `cleanup` diagnostics are both reported |

A digest or manifest failure must leave the candidate leaf nonexistent. A
post-creation failure must safely remove invocation-created state unless
fail-closed cleanup itself encounters an unsafe/unreadable entry; that cleanup
failure and retained path must then be explicit.

#### Extraction contract

For each permitted entry in the already validated, still-held `ZipArchive`:

1. Resolve the destination with `GetFullPath`.
2. Prove it is an immediate child of the candidate root.
3. Open the destination with `FileMode.CreateNew`, write access, and no sharing.
4. Copy only the entry stream.
5. Dispose the entry stream without closing or replacing the held archive stream, then dispose the archive and held stream deterministically after all extraction completes.

Do not restore symlink information, Unix file types or modes, Windows attributes, timestamps, or any other ZIP metadata. ZIP external attributes are not a rejection criterion; safety comes from creating fresh regular files in a fresh directory.

After extraction:

- Materialize `[System.IO.Directory]::EnumerateFileSystemEntries()` for the candidate directory.
- Require exactly the four expected root-level paths.
- Require every path to be a regular, non-reparse-point file.
- Reject every BOM and CR byte.
- Repeat the full-component, containment, type, parent, and leaf checks before
  returning.
- Return or log the four resolved candidate paths.

Never invoke automatic or blind ZIP extraction for the candidate.

#### Tracked permanent helper self-test

Create:

```text
.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1
```

This tracked harness is the sole definition of the deterministic fixture suite. It must:

- Declare `#Requires -Version 5.1`.
- Record its script version.
- Accept the exact tracked production-helper path through a mandatory `HelperPath` parameter.
- Resolve `HelperPath` once to an existing regular, non-reparse-point filesystem file before changing location, and use that absolute path for every invocation.
- Create all fixture state under one unique runner-temporary root using the
  same absence/create/verify and bounded-collision-retry topology required of
  production jobs.
- Invoke ordinary archive/path cases as a child script through the helper's
  documented public parameters. The sole exception is the unsafe-cleanup
  fixture below, which definition-only loads and calls the exact named
  production cleanup function.
- Never copy or reimplement digest, path-containment, archive-validation,
  lifecycle, cleanup, or extraction logic.
- Change working directory during at least one valid case to prove that helper behavior does not depend on ambient location.
- Return nonzero for any unexpected helper outcome, filesystem state, or cleanup failure.
- Clean the complete fixture root in `finally`.

The harness must use these ordered failure/success phase names:

1. `context/path`;
2. `download-enumeration`;
3. `digest`;
4. `archive-open`;
5. `manifest`;
6. `candidate-leaf`;
7. `extraction`;
8. `post-extraction`; and
9. `cleanup`.

Every harness result must name the stable case ID and actual phase. Every
rejection row must require the candidate-leaf postcondition specified in that
row, require named sentinels outside the intended destination to remain absent
or unchanged, and assert the listed diagnostic fields without depending on a
stack trace. `path` means the relevant normalized root/path; `entry` means the
offending entry name/type; `digest` means expected and actual digest; and
`label` means the rejected diagnostic-label name.

Every success row must require all of the following after `post-extraction`: exactly the four expected root-level paths and no extras; every payload is an ordinary non-reparse file; every file has the exact fixture bytes, including the expected dot-content file; no BOM or CR byte exists; and no write occurred outside the candidate directory.

| ID | Platform or precondition | Expected outcome and phase | Candidate leaf | Required diagnostics or success assertion |
| --- | --- | --- | --- | --- |
| `V-01` | All; exact archive and matching digest | Success, `post-extraction` | Created once | All common success assertions |
| `V-02` | All; permitted entries carry symlink-like external attributes | Success, `post-extraction` | Created once | All common success assertions; payloads are ordinary files and no filesystem link exists |
| `P-01` | All; trusted and candidate paths use a valid sibling-prefix such as `repository-other` | Success, `post-extraction` | Created once | All common success assertions plus the canonical containment classification |
| `P-02` | All; all applicable inputs are filesystem-provider-qualified absolute paths | Success, `post-extraction` | Created once | All common success assertions plus resolved native paths |
| `D-01` | All; wrong well-formed digest and three distinct supplied label sentinels | Reject, `digest` | Absent | Expected/actual `digest`, every exact label sentinel, archive `path`; prove no `ZipArchive` construction |
| `D-02` | All; wrong well-formed digest and all optional labels omitted | Reject, `digest` | Absent | Expected/actual `digest`, every label rendered `unavailable`, archive `path`; invent none |
| `Z-01` | All; invalid/truncated ZIP whose propagated digest matches its bytes | Reject, `archive-open` | Absent | Archive `path`, expected/actual `digest` |
| `M-01` | All; one expected entry missing | Reject, `manifest` | Absent | Missing `entry`, archive `path` |
| `M-02` | All; unexpected extra entry | Reject, `manifest` | Absent | Extra `entry`, archive `path` |
| `M-03` | All; exact duplicate entry | Reject, `manifest` | Absent | Duplicate `entry`, archive `path` |
| `M-04` | All; case-only collision | Reject, `manifest` | Absent | Both colliding `entry` values |
| `M-05` | All; forward-slash nested name | Reject, `manifest` | Absent | Offending `entry` |
| `M-06` | All; backslash nested name | Reject, `manifest` | Absent | Offending `entry` |
| `M-07` | All; forward-slash traversal | Reject, `manifest` | Absent | Offending `entry` |
| `M-08` | All; backslash traversal | Reject, `manifest` | Absent | Offending `entry` |
| `M-09` | All; leading-slash absolute name | Reject, `manifest` | Absent | Offending `entry` |
| `M-10` | All; leading-backslash absolute name | Reject, `manifest` | Absent | Offending `entry` |
| `M-11` | All; drive-qualified name | Reject, `manifest` | Absent | Offending `entry` |
| `M-12` | All; explicit directory entry | Reject, `manifest` | Absent | Offending `entry` and type |
| `M-13` | All; file/directory collision | Reject, `manifest` | Absent | Both colliding `entry` values/types |
| `M-14` | All; reviewed raw ZIP with an empty central-directory name | Reject, `manifest` | Absent | Empty `entry` classification, archive `path` |
| `E-01` | All; download or candidate path outside trusted root | Reject, `context/path` | Absent | Trusted root and offending `path` |
| `E-02` | All; checkout and trusted root equal | Reject, `context/path` | Absent | Both normalized root `path` values |
| `E-03` | All; checkout contains trusted root | Reject, `context/path` | Absent | Both normalized root `path` values |
| `E-04` | All; trusted root contains checkout | Reject, `context/path` | Absent | Both normalized root `path` values |
| `E-05` | All; relative path input | Reject, `context/path` | Absent | Parameter name and supplied `path` |
| `E-06` | All; non-filesystem provider input | Reject, `context/path` | Absent | Parameter name, provider, and `path` |
| `E-07-W` | Windows; case-only path variant at a forbidden overlap boundary | Reject, `context/path` | Absent | Both normalized paths and ordinal-ignore-case result |
| `E-07-L` | Linux; otherwise valid case-distinct sibling paths | Success, `post-extraction` | Created once | All common success assertions plus ordinal containment result |
| `E-08` | Link-capable platform; reparse/symlink component between the volume/share root and either declared root | Reject, `context/path` | Absent | Offending absolute component and root `path` |
| `E-09` | Link-capable platform; reparse/symlink component below trusted root | Reject, `context/path` | Absent | Offending absolute component and working `path` |
| `E-10` | All; hidden/system extra download entry | Reject, `download-enumeration` | Absent | Complete enumerated entry set |
| `L-01` | All; preexisting candidate file | Reject, `candidate-leaf` | Preexisting file unchanged | Candidate `path`, leaf name, and type |
| `L-02` | All; preexisting candidate directory | Reject, `candidate-leaf` | Preexisting directory unchanged | Candidate `path`, leaf name, and type |
| `L-03` | Link-capable platform; preexisting symlink/reparse leaf | Reject, `candidate-leaf` | Preexisting link unchanged | Candidate `path`, leaf name, and type |
| `L-04` | Link-capable platform; dangling candidate link | Reject, `candidate-leaf` | Preexisting dangling link unchanged | Candidate `path`, leaf name, and type |
| `B-01` | All; exact manifest with a BOM in one extracted payload | Reject, `post-extraction` | Helper-created leaf removed | Offending `entry`; successful cleanup and no retained candidate |
| `B-02` | All; exact manifest with a CR byte in one extracted payload | Reject, `post-extraction` | Helper-created leaf removed | Offending `entry`; successful cleanup and no retained candidate |
| `K-01` | All; exact journaled ordinary candidate state plus one unexpected unjournaled ordinary immediate child | Reject and retain, `cleanup` | Helper-created leaf and unexpected child retained without partial deletion | Original induced failure, retained candidate path, offending child, and stable cleanup diagnostics from the exact production function |
| `K-02` | Link-capable platform; replace one exact journaled child with a link/reparse entry before cleanup | Reject and retain, `cleanup` | Helper-created leaf and substituted entry retained without traversal | Original induced failure, retained candidate path, offending child/type, and stable cleanup diagnostics; stable skip allowed only for this supplemental form |
| `X-01` | All; explicitly empty `ArtifactId` | Reject, `context/path` | Absent | Rejected `label` is exactly `ArtifactId`; prove no download enumeration/open |
| `X-02` | All; explicitly empty `RunId` | Reject, `context/path` | Absent | Rejected `label` is exactly `RunId`; prove no download enumeration/open |
| `X-03` | All; explicitly empty `RunAttempt` | Reject, `context/path` | Absent | Rejected `label` is exactly `RunAttempt`; prove no download enumeration/open |

`ZipArchive.CreateEntry` may be used for constructible cases. Because it rejects an empty name at creation time, use a deterministic reviewed raw fixture for `M-14`. Construct `V-02` with `ZipArchiveEntry.ExternalAttributes` where practical or a reviewed raw fixture otherwise.

`K-01` must:

1. definition-only dot-source the exact resolved production helper;
2. create the exact ordinary journaled state the production failure path would
   own;
3. insert the unjournaled ordinary immediate child;
4. invoke `Remove-StyleGuideCandidateInvocationState`;
5. prove no journaled or unexpected entry was deleted;
6. prove outside sentinels remain unchanged; and
7. require the primary and cleanup diagnostics.

The harness must not copy/reimplement cleanup. `K-01` is mandatory on every
supported platform because it requires no link privilege. `K-02` supplements
it where a real link/reparse primitive is available.

On Windows, the harness must also prove the selected .NET sharing semantics with
a temporary probe: a second read-only open succeeds while `FileShare.Read` is
held, a subsequent write open fails, and the primary stream remains usable.
Static review must confirm the production helper selects that exact enum.

The same IDs must execute in each supported shell/platform. Only a fixture
whose setup primitive is unavailable, such as link construction without the
needed platform capability or privilege, may be skipped. Emit a named skip
record containing case ID, platform, and reason; a skip is not a pass and does
not permit other rows to be omitted.

At least one real component-or-leaf symbolic-link fixture must execute and
prove rejection on Ubuntu. At least one real component-or-leaf link/reparse
fixture must execute and prove rejection on Windows. A stable case-level skip
for one genuinely unavailable form remains allowed, but a platform-wide
link-fixture skip cannot satisfy acceptance and an unexpected setup failure
must fail the cell.

These are production contract self-tests exercising the exact tracked helper, not a bypass or alternate extraction implementation.

### 7. Establish least-privileged pull-request and push pipelines

Remove workflow-level `contents: write`.

Only the final synchronization job may declare:

```yaml
permissions:
  contents: write
```

Every other job must have no more than:

```yaml
permissions:
  contents: read
```

#### Native-command contract

Every complete PowerShell `run:` block must:

- Select `powershell` or `pwsh` explicitly.
- Begin with `$ErrorActionPreference = 'Stop'`.
- Capture `$LASTEXITCODE` immediately after every native command.
- Require exit code 0 unless another allowed set is explicitly documented.
- Treat `git diff --exit-code` and `git diff --no-index --exit-code` results as:
  - `0`: equal;
  - `1`: ordinary difference;
  - any other value: command failure.
- Require `git ls-remote --exit-code` to return 0; exit code 2 is failure.
- Validate parsed output counts and shapes.
- Include command purpose and exit code in failures.

Do not rely on `$PSNativeCommandUseErrorActionPreference`.

#### Action pinning and supported runtimes

As of 2026-07-29, use:

```yaml
id: checkout_repository
uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
```

for every checkout step in both `.github/workflows/build.yml` and `.github/workflows/markdownlint.yml`;

```yaml
id: setup_node
uses: actions/setup-node@820762786026740c76f36085b0efc47a31fe5020 # v7.0.0
with:
  node-version: '24'
  package-manager-cache: false
```

for `.github/workflows/markdownlint.yml`;

```yaml
uses: actions/upload-artifact@043fb46d1a93c77aae656e7c1c64a875d1fc6a0a # v7.0.1
```

and:

```yaml
uses: actions/download-artifact@3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c # v8.0.1
```

Use `prepare_push_candidate`, `approve_push_candidate`, and
`synchronize_generated_artifacts` consistently in job dependencies and output
expressions. The approval job contains no external action.

Every checkout role must use:

```yaml
with:
  ref: ${{ github.sha }}
  persist-credentials: false
```

except `synchronize_generated_artifacts`, which must explicitly use
`persist-credentials: true` so its one authenticated production push retains
checkout's protected persisted credential. Do not add another checkout input.

The validator's `$arrExpectedActionRoles` collection below is the sole
normative action-role inventory. Each record supplies the workflow, job ID,
stable step ID, repository, immutable SHA, release comment, exact condition,
and complete input set. Do not duplicate any subset as a prose table,
repository allowlist, occurrence table, or one-off setup-node rule.

Immediately before implementation:

1. Verify each checkout, setup-node, upload, and download SHA in the official action repository.
2. Confirm it matches the adjacent release comment.
3. Inspect each selected commit's exact `action.yml` runtime metadata.
4. Check for a required newer security release.
5. If updated, change the full SHA, release comment, references, and evidence together.
6. Do not use a branch, major-version tag, or patch-version tag.
7. Do not choose a download release lacking `artifact-ids`, `digest-mismatch`, or `skip-decompress`.
8. Confirm checkout and setup-node both declare `runs.using: node24`; confirm upload/download use supported runtimes.

Checkout v7 retains v6's protected persisted-credential storage beneath `RUNNER_TEMP`; its official documentation states that ordinary authenticated Git commands continue to work. Neither PSStyleGuide workflow invokes authenticated Git from a Docker container action. Prove the final synchronization job's production-form authenticated push in the controlled drill.

The Markdown lint workflow must declare workflow- or job-level:

```yaml
permissions:
  contents: read
```

It must assert that `process.versions.node` has major version 24, then run the
existing clean install, outer Markdown lint, and nested Markdown lint commands
with automatic package-manager caching disabled. Do not alter those commands or
update `package.json`/`package-lock.json` in this issue unless Node 24
compatibility testing proves a narrowly necessary correction.

The current npm advisories are owned by the separately scoped
**P3: Remediate Markdown lint dependency advisories and add npm update
governance**, which follows P2. At filing, replace that title-only draft
reference with P3's actual issue URL. Read-only workflow permissions reduce
blast radius but do not remediate vulnerable Markdown parsing code.

Changing checkout, setup-node, the installed Node version, cache behavior,
explicit permissions, the named artifact actions, and review-only Actions
update governance is a targeted runtime, immutability, and least-privilege
correction. Do not migrate unrelated actions or package dependencies in this
issue.

#### Review-only GitHub Actions update governance

Create `.github/dependabot.yml` containing:

```yaml
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
```

Dependabot version updates must remain review-only. Do not add auto-merge,
auto-approval, or an npm ecosystem entry in P1. Review each proposed action
update's upstream release, repository provenance, full SHA, same-line version
comment, runtime, runner minimum, input/output/default compatibility, and
applicable workflow evidence before merging it. Dependabot visibility does not
replace immutable execution-time pins or human review.

#### Pull-request Ubuntu verification

Implement this as job `verify_pull_request_ubuntu`. It must:

- Run only for `pull_request`.
- Use `ubuntu-latest`.
- Declare `contents: read`.
- Check out and verify the exact event SHA.
- Run the tracked helper harness under `pwsh` after exact-SHA and clean-checkout proof.
- Pass an explicit checkout root and a unique trusted temporary root to every helper invocation.
- Run the generator under `pwsh`.
- Apply logical and raw-byte verification against `HEAD`.
- Fail when committed artifacts are stale.
- Never stage, commit, or push.
- Upload the four generated outputs after success or ordinary failure, but not cancellation.

Use:

```yaml
- name: Upload canonical generated artifacts
  id: upload_pull_request_artifacts
  if: ${{ !cancelled() }}
  uses: actions/upload-artifact@043fb46d1a93c77aae656e7c1c64a875d1fc6a0a # v7.0.1
  with:
    name: style-guide-artifacts-pr-${{ github.run_id }}-${{ github.run_attempt }}
    if-no-files-found: error
    overwrite: false
    path: |
      copilot-instructions.md
      powershell.instructions.md
      STYLE_GUIDE_CHAT.md
      STYLE_GUIDE_FULL.md
```

Do not use `continue-on-error` or `always()` to facilitate upload.

A stale-artifact error must instruct the contributor to run the generator, review the output, and commit all four generated artifacts with the source changes.

#### Read-only push preparation

Implement this as job `prepare_push_candidate`. It must:

- Run only for `push`.
- Use `ubuntu-latest`.
- Declare `contents: read`.
- Check out the exact triggering SHA and prove `HEAD == github.sha`.
- Run the generator under `pwsh`.
- Inspect only the four generated paths.
- Reject BOM or CR bytes.
- Determine whether the candidate differs from the triggering commit.
- Upload exactly one immutable candidate containing exactly the four generated files.
- Never stage, commit, or push.

Use:

```yaml
- name: Upload synchronization candidate
  id: upload_candidate
  uses: actions/upload-artifact@043fb46d1a93c77aae656e7c1c64a875d1fc6a0a # v7.0.1
  with:
    name: style-guide-candidate-${{ github.run_id }}-${{ github.run_attempt }}
    if-no-files-found: error
    overwrite: false
    archive: true
    path: |
      copilot-instructions.md
      powershell.instructions.md
      STYLE_GUIDE_CHAT.md
      STYLE_GUIDE_FULL.md
```

Expose:

- `has_changes`
- `candidate_artifact_id`
- `candidate_artifact_digest`
- the run-specific artifact name for diagnostics

Source the ID and digest from:

```text
steps.upload_candidate.outputs.artifact-id
steps.upload_candidate.outputs.artifact-digest
```

Require both to be nonempty. The ID is the authoritative selector; the name is diagnostic only.

#### Candidate archive download, self-test, validation, and extraction

Use this conditional push-consumer topology:

- All four Windows push matrix cells always start, download the producer artifact, run the tracked helper harness, and invoke the production helper.
- Synchronization starts only when approval propagates `has_changes=true`. When it starts, it performs the same download, harness, and helper sequence before entering the mutation block.
- On the expected no-drift P1/P2 push, `has_changes=false`; synchronization is skipped at the job level and none of its steps run.
- Ordinary push logs from the four Windows cells prove the unconditional path. Static inspection plus the controlled `has_changes=true` synchronization drill proves the conditional writer path.

Every started push consumer must:

1. Receive the candidate ID and propagated upload digest.
2. Normalize the exact runner-controlled temporary parent. Generate a
   high-entropy child with `[System.IO.Path]::GetRandomFileName()`, prove no
   entry occupies it, create it without `-Force`, and verify an ordinary
   non-reparse directory. Retry a documented bounded number of times only for
   an actual name collision; fail every other creation/classification error.
   Never silently accept an existing directory.
3. Emit that absolute path as the current job's
   `trusted_temporary_root` output, create a `download` child beneath it, and
   emit that absolute child as `download_directory`.
4. Reserve a separate, initially nonexistent `candidate` child beneath the
   same trusted root and emit it as `candidate_directory`.
5. Download only by artifact ID:

   ```yaml
   - name: Download synchronization candidate archive
     id: download_candidate
     uses: actions/download-artifact@3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c # v8.0.1
     with:
       artifact-ids: ${{ <validated artifact ID> }}
       path: ${{ steps.candidate_paths.outputs.download_directory }}
       skip-decompress: true
       digest-mismatch: error
   ```

6. Run the tracked permanent self-test harness against the exact tracked helper.
7. Only after the self-test succeeds, invoke the same helper on the production
   download directory, passing the explicit checkout root, trusted temporary
   root, reserved candidate path, propagated upload digest, artifact ID, run
   ID, and run attempt.
8. Upload any required diagnostic evidence before cleanup.
9. In an `always()` cleanup step that does not run after cancellation,
   revalidate the job-owned envelope and remove only the known ordinary
   archive, helper-created candidate files/directories, download directory, and
   empty unique root. Never recursively delete an unexpected/reparse entry.
   Surface cleanup failure without discarding the earlier failure.

`GetRandomFileName()` generates a name but does not create it, and
`Directory.CreateDirectory()` can return an existing directory. The required
absence/create/verify sequence is therefore part of the contract. It is
supported by the runner-controlled/no-competing-writer model above, not by a
claim of atomic create-new directory semantics.

The helper performs the same-stream digest, full-component enumeration,
manifest, lifecycle, cleanup, and extraction contracts defined in the
shared-helper section above.

#### Four-cell Windows validation topology

Implement pull-request job `verify_pull_request_windows` and push job
`verify_push_windows` using:

```yaml
strategy:
  fail-fast: false
  matrix:
    edition:
      - desktop
      - core
    fixture_eol:
      - lf
      - crlf
```

Every cell must use:

```yaml
runs-on: windows-latest
permissions:
  contents: read
```

No Windows cell may stage, commit, or push.

Use:

- `shell: powershell` when `matrix.edition == 'desktop'`;
- `shell: pwsh` when `matrix.edition == 'core'`;
- `shell: pwsh` for edition-neutral fixture preparation and inspection.

Each cell must:

1. Check out the exact event SHA.
2. Prove `HEAD` equals the expected SHA.
3. Validate only its assigned edition:
   - `desktop`: `PSEdition == 'Desktop'` and version exactly 5.1;
   - `core`: `PSEdition == 'Core'` and major version 7.
4. Prove the fresh checkout of both source documents, the generator, the helper, and the self-test harness contains at least one LF and no CR.
5. For pull-request validation when `fixture_eol == 'lf'`, run the tracked self-test harness under the assigned edition against the exact tracked helper. Do not repeat the helper suite in either `crlf` cell.
6. For push validation:
   - depend on preparation;
   - download preparation's exact ID;
   - run the tracked permanent self-test harness in every cell;
   - invoke the shared helper with explicit checkout/trusted roots, propagated artifact ID/digest, run ID, and run attempt to validate and safely extract the exact candidate before generation.
7. Prepare only the assigned fixture:
   - `lf`: retain and prove BOM-less LF with no CR;
   - `crlf`: convert both sources and the generator using `UTF8Encoding($false)`, `ReadAllText`, and `WriteAllText`, then prove at least one CRLF, no bare LF, no lone CR, and no BOM.
8. Run the generator once under the assigned edition.
9. Apply the complete diagnostic-preserving artifact contract.
10. Include event, edition, version, fixture EOL, artifact path, and push artifact ID in failures.

The pull-request harness placement is intentionally per-platform/per-edition,
not per-edition × source-EOL. The helper consumes constructed archive/path
fixtures and does not depend on the source documents' LF/CRLF variant, so the
Ubuntu run and two Windows LF cells provide the required helper coverage. The
four matrix cells remain mandatory for generator EOL equivalence. Every
started push cell still runs the harness because each independently consumes a
production candidate.

The required normative cells are:

| Fixture EOL | Windows PowerShell 5.1 | PowerShell 7 |
| --- | --- | --- |
| LF | Required | Required |
| CRLF | Required | Required |

##### Diagnostic-preserving artifact contract

After the normative generator run:

1. Run:
   - pull request: artifact-only `git diff --exit-code` against `HEAD`;
   - push: artifact-by-artifact `git diff --no-index --exit-code` against the safely extracted candidate.
2. Store exit code 1 as an ordinary logical difference.
3. Treat every other nonzero exit as command failure.
4. Read generated raw bytes.
5. Diagnose BOM and CR before generic mismatch.
6. Resolve raw identities:
   - pull request: working-tree `git hash-object --no-filters` versus `git rev-parse HEAD:<path>`;
   - push: generated `git hash-object --no-filters` versus candidate `git hash-object --no-filters`.
7. If logical and raw identities differ, report a stale/logical mismatch and include the logical diff.
8. If the raw identity differs while the logical comparison is clean, report a raw-only difference hidden by Git conversion.
9. If the stored logical comparison differed, fail after completing all byte diagnostics.

##### Lone-CR sanitation probe

Run this only in the two `fixture_eol == 'lf'` cells, after the normative LF comparison:

1. Restore both sources and the generator to BOM-less LF.
2. In `STYLE_GUIDE.md`, find an LF with non-newline characters immediately before and after it.
3. Replace exactly that LF with one CR.
4. Write using `UTF8Encoding($false)`.
5. Read the persisted bytes and prove:
   - no BOM;
   - exactly one `0x0D`;
   - no `0x0D 0x0A`.
6. Run the generator under the cell's assigned edition.
7. Require all four outputs to be BOM-less and contain no `0x0D`.
8. Do not compare sanitation outputs with `HEAD` or the push candidate.
9. Do not upload sanitation outputs.

Passing this probe proves writer sanitation only. It does not claim CR-only source compatibility.

#### Read-only candidate approval

Add one non-matrix push-only job named `approve_push_candidate` that:

- Depends directly on preparation and the complete four-cell push matrix.
- Has no more than `contents: read`.
- Runs only after all four matrix cells succeed.
- Requires preparation's ID and digest to be nonempty.
- Emits:
  - `has_changes`;
  - `validated_candidate_artifact_id`;
  - `validated_candidate_artifact_digest`.
- Copies those values exactly from preparation.
- Never downloads, regenerates, stages, commits, or pushes.

#### Write-enabled synchronization

Implement the synchronization job as
`synchronize_generated_artifacts`. It must:

- Run only for `push`.
- Depend on approval.
- Run only when `has_changes == 'true'`.
- Use `ubuntu-latest`.
- Be the only job with `contents: write`.
- Check out and prove the exact triggering SHA.
- Never regenerate.
- Download only the approved artifact ID.
- Run the tracked permanent self-test harness against the exact tracked helper.
- Invoke the shared helper with explicit checkout/trusted roots and the approved artifact ID/digest, run ID, and run attempt to validate and safely extract the approved archive.
- Copy and stage exactly the four artifacts.
- Prove candidate, destination, index, and committed-blob identity.
- Never fetch, merge, rebase, amend, adapt, or retry.

Place the complete preflight, copy, stage, commit, proof, and push sequence in one PowerShell mutation block. Its first executable lines must copy the workflow inputs once:

```powershell
$strTargetRef = [string]$env:TARGET_REF
$strExpectedSha = [string]$env:EXPECTED_SHA
```

Before copying, require:

1. Neither local is empty, has leading/trailing whitespace, or contains CR/LF.
2. `$strTargetRef` is one complete `refs/heads/...` branch ref accepted by `git check-ref-format`.
3. `$strTargetRef` equals `[string]$env:GITHUB_REF` using ordinal comparison.
4. `$strExpectedSha` equals `[string]$env:GITHUB_SHA` using ordinal case-insensitive comparison.
5. `git rev-parse --verify 'HEAD^{commit}'` returns exactly one repository-native full object ID equal to `$strExpectedSha`.
6. `git ls-remote --exit-code --refs origin $strTargetRef` returns exit code 0 and exactly one record.
7. The remote record contains exactly `<object-id><TAB><ref>`, its ref equals `$strTargetRef` ordinally, and its object ID equals `$strExpectedSha`.

After those checks, do not read `TARGET_REF`, `EXPECTED_SHA`, `GITHUB_REF`, or `GITHUB_SHA` again. Reuse the unchanged locals for every target-ref, triggering-SHA, parent, lease, and refspec proof. Do not reconstruct a short branch name.

For each artifact:

1. Recheck candidate BOM and CR.
2. Calculate the candidate blob ID with `git hash-object --no-filters`.
3. Copy it to its tracked destination.
4. Recheck destination BOM and CR.
5. Calculate the destination blob ID.
6. Require candidate and destination IDs to match.

Then:

1. Stage exactly the four artifact paths.
2. Run `git diff --cached --check`.
3. Require the staged path set to equal exactly those paths.
4. Resolve every stage-0 blob with `git rev-parse --verify ":<path>"`.
5. Require every index blob to equal its candidate blob.
6. Configure the existing bot identity.
7. Commit with the existing `[skip ci]` convention.
8. Check the commit exit code immediately.
9. Require exactly one parent equal to `$strExpectedSha`.
10. Resolve every committed blob with `git rev-parse --verify "HEAD:<path>"`.
11. Require every committed blob to equal its candidate blob.
12. Push once and check the exit code immediately.

Supply:

```yaml
env:
  TARGET_REF: ${{ github.ref }}
  EXPECTED_SHA: ${{ github.sha }}
```

Push with:

```powershell
& git push `
    "--force-with-lease=$strTargetRef`:$strExpectedSha" `
    origin `
    "HEAD:$strTargetRef"

$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw (
        ("Synchronization push was rejected with exit code {0}. The exact " +
        "expected-SHA lease did not permit the target update; a newer " +
        "main-branch push run must perform synchronization.") -f
        $intGitExitCode
    )
}
```

The parentheses around the complete concatenated message are required because `-f` binds more tightly than `+`.

Controlled stale-ref and exact-lease drills may supply purpose-specific local test values to this same validation/push logic. Mutate only the value whose rejection the drill proves, restore production inputs afterward, and retain the production equality checks and command shape in the checked-in workflow.

Do not use:

- unconditional `--force`;
- a leading `+` refspec;
- bare `--force-with-lease`;
- a lease without an expected object;
- bare `git push`;
- an implicit destination;
- retries or adaptation against newer history.

### 8. Change nothing else

- Keep `#Requires -Version 5.1`.
- Keep read-side `Get-Content -Raw -Encoding UTF8`.
- Do not modify `.gitattributes`.
- Do not modify either style-guide source.
- Do not modify any generated artifact in the implementing commit.
- Do not claim CR-only or mixed-EOL compatibility.
- Do not create another write-capable job.
- Do not use a PAT or GitHub App token.
- Do not use an external object store as production candidate transport.
- Do not create a permanent test branch.
- Do not modify `.github/copilot-instructions.md`.
- In `.github/workflows/markdownlint.yml`, change only checkout, setup-node, `node-version`, `package-manager-cache`, and explicit `contents: read` unless Node 24 compatibility validation proves another change is required.
- Do not update the Markdown package manifest or lockfile; P3 owns the current
  dependency advisories after P2.
- Do not pin or migrate any action outside the exact roles in
  `$arrExpectedActionRoles`.
- In `.github/dependabot.yml`, add only the review-only weekly
  `github-actions` entry specified above. Do not add npm updates, auto-merge,
  auto-approval, or organization-policy configuration.
- Do not make this issue depend on TerraformStyleGuide changes.

## Validation

### Local Node 24 and Markdown validation

Run from the repository root before PowerShell/generator validation:

```powershell
$ErrorActionPreference = 'Stop'

$objNodeCommand = Get-Command `
    -Name 'node' `
    -CommandType Application `
    -ErrorAction Stop |
    Select-Object -First 1

$objNpmCommand = Get-Command `
    -Name 'npm' `
    -CommandType Application `
    -ErrorAction Stop |
    Select-Object -First 1

$arrNodeVersionOutput = @(
    & $objNodeCommand.Path -p 'process.versions.node'
)
$intNodeExitCode = $LASTEXITCODE

if ($intNodeExitCode -ne 0) {
    throw (
        "Unable to query Node.js; node exited with {0}." -f
        $intNodeExitCode
    )
}

if (
    $arrNodeVersionOutput.Count -ne 1 -or
    ([string]$arrNodeVersionOutput[0]).Trim() -notmatch '^24\.'
) {
    throw (
        "P1 local validation requires Node.js major 24; found: {0}" -f
        ($arrNodeVersionOutput -join '; ')
    )
}

$blnCiWasDefined = Test-Path -LiteralPath 'Env:CI'
$strPreviousCi = [string]$env:CI

try {
    $env:CI = 'true'

    & $objNpmCommand.Path --prefix .github/workflows ci
    $intNpmExitCode = $LASTEXITCODE

    if ($intNpmExitCode -ne 0) {
        throw (
            "npm ci failed with exit code {0}." -f
            $intNpmExitCode
        )
    }
}
finally {
    if ($blnCiWasDefined) {
        $env:CI = $strPreviousCi
    }
    else {
        Remove-Item -LiteralPath 'Env:CI' -ErrorAction SilentlyContinue
    }
}

& $objNpmCommand.Path --prefix .github/workflows run lint:md
$intNpmExitCode = $LASTEXITCODE

if ($intNpmExitCode -ne 0) {
    throw (
        "Outer Markdown lint failed with exit code {0}." -f
        $intNpmExitCode
    )
}

& $objNpmCommand.Path --prefix .github/workflows run lint:md:nested
$intNpmExitCode = $LASTEXITCODE

if ($intNpmExitCode -ne 0) {
    throw (
        "Nested Markdown lint failed with exit code {0}." -f
        $intNpmExitCode
    )
}
```

Do not use a pass under another Node major as Node 24 evidence and do not
update `package.json` or `package-lock.json` in this issue.

### Local cross-edition validation

Run from the repository root:

```powershell
$ErrorActionPreference = 'Stop'

$arrArtifactPaths = @(
    'copilot-instructions.md'
    'powershell.instructions.md'
    'STYLE_GUIDE_CHAT.md'
    'STYLE_GUIDE_FULL.md'
)

$arrEditionCommands = @(
    [pscustomobject]@{
        Label = 'PowerShell 7'
        Name = 'pwsh'
        ExpectedEdition = 'Core'
        ExpectedMajor = 7
        ExpectedMinor = $null
    }
    [pscustomobject]@{
        Label = 'Windows PowerShell 5.1'
        Name = 'powershell'
        ExpectedEdition = 'Desktop'
        ExpectedMajor = 5
        ExpectedMinor = 1
    }
)

$intValidatedEditionCount = 0

$strChildCommand = @'
$ErrorActionPreference = 'Stop'

try {
    $arrRequiredEnvironmentNames = @(
        'PSSTYLEGUIDE_EXPECTED_EDITION'
        'PSSTYLEGUIDE_EXPECTED_MAJOR'
        'PSSTYLEGUIDE_TARGET_KIND'
        'PSSTYLEGUIDE_TARGET_PATH'
    )

    foreach ($strEnvironmentName in $arrRequiredEnvironmentNames) {
        if (
            [string]::IsNullOrWhiteSpace(
                [Environment]::GetEnvironmentVariable(
                    $strEnvironmentName,
                    'Process'
                )
            )
        ) {
            throw (
                "Missing required child environment value: {0}" -f
                $strEnvironmentName
            )
        }
    }

    $strExpectedEdition = [Environment]::GetEnvironmentVariable(
        'PSSTYLEGUIDE_EXPECTED_EDITION',
        'Process'
    )

    $intExpectedMajor = 0

    if (
        -not [int]::TryParse(
            [Environment]::GetEnvironmentVariable(
                'PSSTYLEGUIDE_EXPECTED_MAJOR',
                'Process'
            ),
            [ref]$intExpectedMajor
        )
    ) {
        throw 'PSSTYLEGUIDE_EXPECTED_MAJOR is not an integer.'
    }

    if ($strExpectedEdition -ceq 'Desktop') {
        $intExpectedMinor = 0

        if (
            -not [int]::TryParse(
                [Environment]::GetEnvironmentVariable(
                    'PSSTYLEGUIDE_EXPECTED_MINOR',
                    'Process'
                ),
                [ref]$intExpectedMinor
            )
        ) {
            throw 'PSSTYLEGUIDE_EXPECTED_MINOR is not an integer.'
        }

        if (
            $PSVersionTable.PSEdition -cne 'Desktop' -or
            $PSVersionTable.PSVersion.Major -ne $intExpectedMajor -or
            $PSVersionTable.PSVersion.Minor -ne $intExpectedMinor
        ) {
            throw (
                ("Expected Desktop {0}.{1}; observed {2} {3}.") -f
                $intExpectedMajor,
                $intExpectedMinor,
                $PSVersionTable.PSEdition,
                $PSVersionTable.PSVersion
            )
        }
    }
    elseif ($strExpectedEdition -ceq 'Core') {
        if (
            $PSVersionTable.PSEdition -cne 'Core' -or
            $PSVersionTable.PSVersion.Major -ne $intExpectedMajor
        ) {
            throw (
                "Expected Core major {0}; observed {1} {2}." -f
                $intExpectedMajor,
                $PSVersionTable.PSEdition,
                $PSVersionTable.PSVersion
            )
        }
    }
    else {
        throw (
            "Unsupported expected edition: {0}" -f
            $strExpectedEdition
        )
    }

    $strTargetKind = [Environment]::GetEnvironmentVariable(
        'PSSTYLEGUIDE_TARGET_KIND',
        'Process'
    )

    $strTargetPath = [Environment]::GetEnvironmentVariable(
        'PSSTYLEGUIDE_TARGET_PATH',
        'Process'
    )

    if (-not [System.IO.File]::Exists($strTargetPath)) {
        throw ("Child target is not an existing file: {0}" -f $strTargetPath)
    }

    if ($strTargetKind -ceq 'Harness') {
        $strHelperPath = [Environment]::GetEnvironmentVariable(
            'PSSTYLEGUIDE_HELPER_PATH',
            'Process'
        )

        if (
            [string]::IsNullOrWhiteSpace($strHelperPath) -or
            -not [System.IO.File]::Exists($strHelperPath)
        ) {
            throw (
                "Harness helper is not an existing file: {0}" -f
                $strHelperPath
            )
        }

        & $strTargetPath -HelperPath $strHelperPath
    }
    elseif ($strTargetKind -ceq 'Generator') {
        & $strTargetPath
    }
    else {
        throw ("Unsupported child target kind: {0}" -f $strTargetKind)
    }

    if (-not $?) {
        throw (
            "{0} returned an unsuccessful PowerShell result." -f
            $strTargetKind
        )
    }

    exit 0
}
catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
'@

$scriptInvokeValidatedChild = {
    param (
        [Parameter(Mandatory)]
        [string]$ExecutablePath,

        [Parameter(Mandatory)]
        [string]$ExpectedEdition,

        [Parameter(Mandatory)]
        [int]$ExpectedMajor,

        [AllowNull()]
        [Nullable[int]]$ExpectedMinor,

        [Parameter(Mandatory)]
        [ValidateSet('Harness', 'Generator')]
        [string]$TargetKind,

        [Parameter(Mandatory)]
        [string]$TargetPath,

        [AllowNull()]
        [string]$HelperPath
    )

    $hashtableEnvironmentValues = @{
        PSSTYLEGUIDE_EXPECTED_EDITION = $ExpectedEdition
        PSSTYLEGUIDE_EXPECTED_MAJOR = [string]$ExpectedMajor
        PSSTYLEGUIDE_EXPECTED_MINOR = if ($null -eq $ExpectedMinor) {
            ''
        }
        else {
            [string]$ExpectedMinor.Value
        }
        PSSTYLEGUIDE_TARGET_KIND = $TargetKind
        PSSTYLEGUIDE_TARGET_PATH = $TargetPath
        PSSTYLEGUIDE_HELPER_PATH = [string]$HelperPath
    }

    $hashtablePreviousEnvironment = @{}

    foreach ($strEnvironmentName in $hashtableEnvironmentValues.Keys) {
        $strEnvironmentPath = 'Env:{0}' -f $strEnvironmentName

        $hashtablePreviousEnvironment[$strEnvironmentName] = [pscustomobject]@{
            WasDefined = Test-Path -LiteralPath $strEnvironmentPath
            Value = [Environment]::GetEnvironmentVariable(
                $strEnvironmentName,
                'Process'
            )
        }
    }

    try {
        foreach ($strEnvironmentName in $hashtableEnvironmentValues.Keys) {
            [Environment]::SetEnvironmentVariable(
                $strEnvironmentName,
                [string]$hashtableEnvironmentValues[$strEnvironmentName],
                'Process'
            )
        }

        & $ExecutablePath `
            -NoLogo `
            -NoProfile `
            -NonInteractive `
            -Command $strChildCommand

        $intChildExitCode = $LASTEXITCODE

        if ($intChildExitCode -ne 0) {
            throw (
                ("{0} child under {1} failed with exit code {2}.") -f
                $TargetKind,
                $ExpectedEdition,
                $intChildExitCode
            )
        }
    }
    finally {
        foreach ($strEnvironmentName in $hashtableEnvironmentValues.Keys) {
            $objPreviousEnvironment = $hashtablePreviousEnvironment[
                $strEnvironmentName
            ]

            if ($objPreviousEnvironment.WasDefined) {
                [Environment]::SetEnvironmentVariable(
                    $strEnvironmentName,
                    [string]$objPreviousEnvironment.Value,
                    'Process'
                )
            }
            else {
                [Environment]::SetEnvironmentVariable(
                    $strEnvironmentName,
                    $null,
                    'Process'
                )
            }
        }
    }
}

$strHarnessPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
    './.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1'
)

$strHelperPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
    './.github/workflows/Expand-StyleGuideCandidateArtifact.ps1'
)

$strGeneratorPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
    './.github/workflows/Generate-StyleGuideArtifacts.ps1'
)

foreach ($objEditionCommand in $arrEditionCommands) {
    $objResolvedCommand = Get-Command `
        -Name $objEditionCommand.Name `
        -CommandType Application `
        -ErrorAction SilentlyContinue |
        Select-Object -First 1

    if ($null -eq $objResolvedCommand) {
        Write-Warning (
            "{0} is unavailable locally; CI must supply this coverage." -f
            $objEditionCommand.Label
        )

        continue
    }

    & $scriptInvokeValidatedChild `
        -ExecutablePath $objResolvedCommand.Path `
        -ExpectedEdition $objEditionCommand.ExpectedEdition `
        -ExpectedMajor $objEditionCommand.ExpectedMajor `
        -ExpectedMinor $objEditionCommand.ExpectedMinor `
        -TargetKind 'Harness' `
        -TargetPath $strHarnessPath `
        -HelperPath $strHelperPath

    & $scriptInvokeValidatedChild `
        -ExecutablePath $objResolvedCommand.Path `
        -ExpectedEdition $objEditionCommand.ExpectedEdition `
        -ExpectedMajor $objEditionCommand.ExpectedMajor `
        -ExpectedMinor $objEditionCommand.ExpectedMinor `
        -TargetKind 'Generator' `
        -TargetPath $strGeneratorPath `
        -HelperPath $null

    git diff --exit-code HEAD -- $arrArtifactPaths
    $intGitExitCode = $LASTEXITCODE

    if ($intGitExitCode -ne 0) {
        throw (
            "Artifacts generated by {0} differ from HEAD; git exited with {1}." -f
            $objEditionCommand.Label,
            $intGitExitCode
        )
    }

    foreach ($strArtifactPath in $arrArtifactPaths) {
        $strAbsolutePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
            $strArtifactPath
        )

        $arrBytes = [System.IO.File]::ReadAllBytes($strAbsolutePath)

        if (
            $arrBytes.Length -ge 3 -and
            $arrBytes[0] -eq 0xEF -and
            $arrBytes[1] -eq 0xBB -and
            $arrBytes[2] -eq 0xBF
        ) {
            throw (
                "{0} generated a UTF-8 BOM in {1}." -f
                $objEditionCommand.Label,
                $strArtifactPath
            )
        }

        if ([Array]::IndexOf($arrBytes, [byte]0x0D) -ge 0) {
            throw (
                "{0} generated a carriage return in {1}." -f
                $objEditionCommand.Label,
                $strArtifactPath
            )
        }

        $arrWorkingHashOutput = @(
            & git hash-object --no-filters -- $strArtifactPath
        )
        $intGitExitCode = $LASTEXITCODE

        if ($intGitExitCode -ne 0) {
            throw (
                "Unable to hash {0} after {1}; git exited with {2}." -f
                $strArtifactPath,
                $objEditionCommand.Label,
                $intGitExitCode
            )
        }

        $arrCommittedHashOutput = @(
            & git rev-parse --verify "HEAD:$strArtifactPath"
        )
        $intGitExitCode = $LASTEXITCODE

        if ($intGitExitCode -ne 0) {
            throw (
                "Unable to resolve HEAD:{0}; git exited with {1}." -f
                $strArtifactPath,
                $intGitExitCode
            )
        }

        if (
            ($arrWorkingHashOutput -join "`n").Trim() -cne
            ($arrCommittedHashOutput -join "`n").Trim()
        ) {
            throw (
                "Raw bytes generated by {0} differ from HEAD: {1}" -f
                $objEditionCommand.Label,
                $strArtifactPath
            )
        }
    }

    $intValidatedEditionCount++
}

if ($intValidatedEditionCount -eq 0) {
    throw 'Neither required PowerShell edition is available for local validation.'
}
```

Each child asserts the expected edition/version before invoking its target in
that same process. Each edition's helper suite and generated outputs are
completely verified before another edition can overwrite the outputs. CI
remains responsible for mandatory coverage of both editions and Ubuntu.

### Verify working-tree scope, stage, and verify the staged set

```powershell
$ErrorActionPreference = 'Stop'

$arrExpectedStagedPaths = @(
    '.github/workflows/Generate-StyleGuideArtifacts.ps1'
    '.github/workflows/Expand-StyleGuideCandidateArtifact.ps1'
    '.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1'
    '.github/workflows/build.yml'
    '.github/workflows/markdownlint.yml'
    '.github/dependabot.yml'
) | Sort-Object

git diff --check
$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw ("git diff --check failed with exit code {0}." -f $intGitExitCode)
}

$arrStatusLines = @(
    git status `
        --porcelain=v1 `
        --untracked-files=all `
        --ignore-submodules=none `
        -- .
)
$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw (
        "Unable to read working-tree status; git exited with {0}." -f
        $intGitExitCode
    )
}

$arrChangedPaths = @(
    $arrStatusLines |
        ForEach-Object {
            if ($_ -notmatch '^..\s+') {
                throw ("Unexpected porcelain status record: {0}" -f $_)
            }

            $_ -replace '^..\s+', ''
        } |
        Sort-Object -Unique
)

$arrWorkingTreeDifferences = @(
    Compare-Object `
        -ReferenceObject $arrExpectedStagedPaths `
        -DifferenceObject $arrChangedPaths `
        -CaseSensitive
)

if ($arrWorkingTreeDifferences.Count -ne 0) {
    throw (
        "The working-tree path set is not exactly the six implementation " +
        "files. Status: {0}" -f
        ($arrStatusLines -join '; ')
    )
}

git add -- $arrExpectedStagedPaths
$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw ("git add failed with exit code {0}." -f $intGitExitCode)
}

git diff --cached --check
$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw (
        "git diff --cached --check failed with exit code {0}." -f
        $intGitExitCode
    )
}

$arrStagedPaths = @(git diff --cached --name-only)
$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw (
        "Unable to list staged paths; git exited with {0}." -f
        $intGitExitCode
    )
}

$arrStagedPaths = @($arrStagedPaths | Sort-Object)

$arrStagedDifferences = @(
    Compare-Object `
        -ReferenceObject $arrExpectedStagedPaths `
        -DifferenceObject $arrStagedPaths `
        -CaseSensitive
)

if ($arrStagedDifferences.Count -ne 0) {
    throw (
        "Unexpected staged path set: {0}" -f
        ($arrStagedPaths -join ', ')
    )
}

$arrStagedPaths
```

### Verify review-only update governance and immutable action pins

```powershell
$ErrorActionPreference = 'Stop'

$strDependabotPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
    '.github/dependabot.yml'
)

$strActualDependabot = (
    [System.IO.File]::ReadAllText($strDependabotPath) -replace "`r`n?", "`n"
)

$strExpectedDependabot = @(
    'version: 2'
    'updates:'
    '  - package-ecosystem: github-actions'
    '    directory: /'
    '    schedule:'
    '      interval: weekly'
    ''
) -join "`n"

if ($strActualDependabot -cne $strExpectedDependabot) {
    throw (
        '.github/dependabot.yml must contain only the approved review-only ' +
        'weekly GitHub Actions update entry.'
    )
}

$strArtifactPathInput = @(
    'copilot-instructions.md'
    'powershell.instructions.md'
    'STYLE_GUIDE_CHAT.md'
    'STYLE_GUIDE_FULL.md'
) -join "`n"

$arrExpectedActionRoles = @(
    [pscustomobject]@{
        Workflow = 'build'
        Path = '.github/workflows/build.yml'
        Job = 'verify_pull_request_ubuntu'
        Step = 'checkout_repository'
        Repository = 'actions/checkout'
        Sha = '3d3c42e5aac5ba805825da76410c181273ba90b1'
        Version = 'v7.0.1'
        IfCondition = ''
        Inputs = [ordered]@{
            ref = '${{ github.sha }}'
            'persist-credentials' = 'false'
        }
    }
    [pscustomobject]@{
        Workflow = 'build'
        Path = '.github/workflows/build.yml'
        Job = 'verify_pull_request_ubuntu'
        Step = 'upload_pull_request_artifacts'
        Repository = 'actions/upload-artifact'
        Sha = '043fb46d1a93c77aae656e7c1c64a875d1fc6a0a'
        Version = 'v7.0.1'
        IfCondition = '${{ !cancelled() }}'
        Inputs = [ordered]@{
            name = (
                'style-guide-artifacts-pr-${{ github.run_id }}-' +
                '${{ github.run_attempt }}'
            )
            'if-no-files-found' = 'error'
            overwrite = 'false'
            path = $strArtifactPathInput
        }
    }
    [pscustomobject]@{
        Workflow = 'build'
        Path = '.github/workflows/build.yml'
        Job = 'verify_pull_request_windows'
        Step = 'checkout_repository'
        Repository = 'actions/checkout'
        Sha = '3d3c42e5aac5ba805825da76410c181273ba90b1'
        Version = 'v7.0.1'
        IfCondition = ''
        Inputs = [ordered]@{
            ref = '${{ github.sha }}'
            'persist-credentials' = 'false'
        }
    }
    [pscustomobject]@{
        Workflow = 'build'
        Path = '.github/workflows/build.yml'
        Job = 'prepare_push_candidate'
        Step = 'checkout_repository'
        Repository = 'actions/checkout'
        Sha = '3d3c42e5aac5ba805825da76410c181273ba90b1'
        Version = 'v7.0.1'
        IfCondition = ''
        Inputs = [ordered]@{
            ref = '${{ github.sha }}'
            'persist-credentials' = 'false'
        }
    }
    [pscustomobject]@{
        Workflow = 'build'
        Path = '.github/workflows/build.yml'
        Job = 'prepare_push_candidate'
        Step = 'upload_candidate'
        Repository = 'actions/upload-artifact'
        Sha = '043fb46d1a93c77aae656e7c1c64a875d1fc6a0a'
        Version = 'v7.0.1'
        IfCondition = ''
        Inputs = [ordered]@{
            name = (
                'style-guide-candidate-${{ github.run_id }}-' +
                '${{ github.run_attempt }}'
            )
            'if-no-files-found' = 'error'
            overwrite = 'false'
            archive = 'true'
            path = $strArtifactPathInput
        }
    }
    [pscustomobject]@{
        Workflow = 'build'
        Path = '.github/workflows/build.yml'
        Job = 'verify_push_windows'
        Step = 'checkout_repository'
        Repository = 'actions/checkout'
        Sha = '3d3c42e5aac5ba805825da76410c181273ba90b1'
        Version = 'v7.0.1'
        IfCondition = ''
        Inputs = [ordered]@{
            ref = '${{ github.sha }}'
            'persist-credentials' = 'false'
        }
    }
    [pscustomobject]@{
        Workflow = 'build'
        Path = '.github/workflows/build.yml'
        Job = 'verify_push_windows'
        Step = 'download_candidate'
        Repository = 'actions/download-artifact'
        Sha = '3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c'
        Version = 'v8.0.1'
        IfCondition = ''
        Inputs = [ordered]@{
            'artifact-ids' = (
                '${{ needs.prepare_push_candidate.outputs.' +
                'candidate_artifact_id }}'
            )
            path = '${{ steps.candidate_paths.outputs.download_directory }}'
            'skip-decompress' = 'true'
            'digest-mismatch' = 'error'
        }
    }
    [pscustomobject]@{
        Workflow = 'build'
        Path = '.github/workflows/build.yml'
        Job = 'synchronize_generated_artifacts'
        Step = 'checkout_repository'
        Repository = 'actions/checkout'
        Sha = '3d3c42e5aac5ba805825da76410c181273ba90b1'
        Version = 'v7.0.1'
        IfCondition = ''
        Inputs = [ordered]@{
            ref = '${{ github.sha }}'
            'persist-credentials' = 'true'
        }
    }
    [pscustomobject]@{
        Workflow = 'build'
        Path = '.github/workflows/build.yml'
        Job = 'synchronize_generated_artifacts'
        Step = 'download_candidate'
        Repository = 'actions/download-artifact'
        Sha = '3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c'
        Version = 'v8.0.1'
        IfCondition = ''
        Inputs = [ordered]@{
            'artifact-ids' = (
                '${{ needs.approve_push_candidate.outputs.' +
                'validated_candidate_artifact_id }}'
            )
            path = '${{ steps.candidate_paths.outputs.download_directory }}'
            'skip-decompress' = 'true'
            'digest-mismatch' = 'error'
        }
    }
    [pscustomobject]@{
        Workflow = 'markdownlint'
        Path = '.github/workflows/markdownlint.yml'
        Job = 'markdownlint'
        Step = 'checkout_repository'
        Repository = 'actions/checkout'
        Sha = '3d3c42e5aac5ba805825da76410c181273ba90b1'
        Version = 'v7.0.1'
        IfCondition = ''
        Inputs = [ordered]@{
            ref = '${{ github.sha }}'
            'persist-credentials' = 'false'
        }
    }
    [pscustomobject]@{
        Workflow = 'markdownlint'
        Path = '.github/workflows/markdownlint.yml'
        Job = 'markdownlint'
        Step = 'setup_node'
        Repository = 'actions/setup-node'
        Sha = '820762786026740c76f36085b0efc47a31fe5020'
        Version = 'v7.0.0'
        IfCondition = ''
        Inputs = [ordered]@{
            'node-version' = '''24'''
            'package-manager-cache' = 'false'
        }
    }
)

function Get-ActionRolePositionKey {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object]$Role
    )

    return '{0}|{1}|{2}' -f $Role.Workflow, $Role.Job, $Role.Step
}

function Get-WorkflowExternalActionRole {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$WorkflowName,

        [Parameter(Mandatory)]
        [string]$WorkflowPath
    )

    $strAbsoluteWorkflowPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
        $WorkflowPath
    )
    $arrLines = [System.IO.File]::ReadAllLines($strAbsoluteWorkflowPath)

    if (@($arrLines | Where-Object { $_ -match "`t" }).Count -ne 0) {
        throw ("Workflow contains a tab: {0}" -f $WorkflowPath)
    }

    $arrAllUsesLineNumbers = @(
        for ($intLineIndex = 0; $intLineIndex -lt $arrLines.Count; $intLineIndex++) {
            if (
                $arrLines[$intLineIndex] -match
                    '(?<![A-Za-z0-9_-])(?:"uses"|''uses''|uses)\s*:'
            ) {
                $intLineIndex + 1
            }
        }
    )

    $arrJobHeaders = @()
    $blnInsideJobs = $false

    for ($intLineIndex = 0; $intLineIndex -lt $arrLines.Count; $intLineIndex++) {
        $strLine = $arrLines[$intLineIndex]

        if ($strLine -ceq 'jobs:') {
            if ($blnInsideJobs) {
                throw ("Workflow has duplicate jobs keys: {0}" -f $WorkflowPath)
            }

            $blnInsideJobs = $true
            continue
        }

        if (-not $blnInsideJobs) {
            continue
        }

        if ($strLine -match '^[^\s#]') {
            $blnInsideJobs = $false
            continue
        }

        if ($strLine -match '^  (?<Job>[a-z][a-z0-9_]*)\s*:\s*$') {
            $arrJobHeaders += [pscustomobject]@{
                Job = $Matches.Job
                Start = $intLineIndex
            }
        }
    }

    $arrDuplicateJobIds = @(
        $arrJobHeaders |
            Group-Object -CaseSensitive -Property Job |
            Where-Object { $_.Count -ne 1 }
    )

    if ($arrDuplicateJobIds.Count -ne 0) {
        throw (
            "Workflow has duplicate job IDs: {0}: {1}" -f
            $WorkflowPath,
            ($arrDuplicateJobIds.Name -join ', ')
        )
    }

    $arrObservedRoles = @()
    $arrParsedUsesLineNumbers = @()

    for ($intJobIndex = 0; $intJobIndex -lt $arrJobHeaders.Count; $intJobIndex++) {
        $objJob = $arrJobHeaders[$intJobIndex]
        $intJobEnd = if ($intJobIndex + 1 -lt $arrJobHeaders.Count) {
            $arrJobHeaders[$intJobIndex + 1].Start - 1
        }
        else {
            $arrLines.Count - 1
        }

        $arrStepsKeys = @(
            for (
                $intLineIndex = $objJob.Start + 1;
                $intLineIndex -le $intJobEnd;
                $intLineIndex++
            ) {
                if ($arrLines[$intLineIndex] -ceq '    steps:') {
                    $intLineIndex
                }
            }
        )

        if ($arrStepsKeys.Count -gt 1) {
            throw (
                "Job has duplicate steps keys: {0}|{1}" -f
                $WorkflowPath,
                $objJob.Job
            )
        }

        if ($arrStepsKeys.Count -eq 0) {
            continue
        }

        $intStepsStart = $arrStepsKeys[0]
        $arrStepStarts = @(
            for (
                $intLineIndex = $intStepsStart + 1;
                $intLineIndex -le $intJobEnd;
                $intLineIndex++
            ) {
                if ($arrLines[$intLineIndex] -match '^      -(?:\s|$)') {
                    $intLineIndex
                }
            }
        )

        $arrExternalStepIds = @()

        for (
            $intStepIndex = 0;
            $intStepIndex -lt $arrStepStarts.Count;
            $intStepIndex++
        ) {
            $intStepStart = $arrStepStarts[$intStepIndex]
            $intStepEnd = if ($intStepIndex + 1 -lt $arrStepStarts.Count) {
                $arrStepStarts[$intStepIndex + 1] - 1
            }
            else {
                $intJobEnd
            }

            $arrUsesIndices = @(
                for (
                    $intLineIndex = $intStepStart;
                    $intLineIndex -le $intStepEnd;
                    $intLineIndex++
                ) {
                    if ($arrLines[$intLineIndex] -match '^        uses\s*:') {
                        $intLineIndex
                    }
                }
            )

            if ($arrUsesIndices.Count -eq 0) {
                continue
            }

            if ($arrUsesIndices.Count -ne 1) {
                throw (
                    "Action step has a duplicate uses key: {0}|{1}|line {2}" -f
                    $WorkflowPath,
                    $objJob.Job,
                    ($intStepStart + 1)
                )
            }

            $intUsesIndex = $arrUsesIndices[0]
            $arrParsedUsesLineNumbers += $intUsesIndex + 1
            $strUsesLine = $arrLines[$intUsesIndex]

            if ($strUsesLine -match '^        uses:\s+\./') {
                continue
            }

            if (
                $strUsesLine -cnotmatch (
                    '^        uses:\s+' +
                    '(?<Repository>[^@\s]+)@' +
                    '(?<Sha>[0-9a-f]{40})\s+' +
                    '#\s+(?<Version>v[0-9]+\.[0-9]+\.[0-9]+)\s*$'
                )
            ) {
                throw (
                    "External action tuple is unsupported: {0}|line {1}: {2}" -f
                    $WorkflowPath,
                    ($intUsesIndex + 1),
                    $strUsesLine
                )
            }

            $strRepository = $Matches.Repository
            $strSha = $Matches.Sha
            $strVersion = $Matches.Version
            $arrIdValues = @(
                for (
                    $intLineIndex = $intStepStart;
                    $intLineIndex -le $intStepEnd;
                    $intLineIndex++
                ) {
                    if ($arrLines[$intLineIndex] -match '^        id:\s*(?<Id>.+?)\s*$') {
                        $Matches.Id
                    }
                }
            )

            if (
                $arrIdValues.Count -ne 1 -or
                $arrIdValues[0] -cnotmatch '^[a-z][a-z0-9_]*$'
            ) {
                throw (
                    "External action step needs one stable ID: {0}|{1}|line {2}" -f
                    $WorkflowPath,
                    $objJob.Job,
                    ($intStepStart + 1)
                )
            }

            $strStepId = $arrIdValues[0]
            $arrExternalStepIds += $strStepId
            $arrIfValues = @(
                for (
                    $intLineIndex = $intStepStart;
                    $intLineIndex -le $intStepEnd;
                    $intLineIndex++
                ) {
                    if ($arrLines[$intLineIndex] -match '^        if:\s*(?<If>.+?)\s*$') {
                        $Matches.If
                    }
                }
            )

            if ($arrIfValues.Count -gt 1) {
                throw (
                    "External action step has duplicate if keys: {0}|{1}|{2}" -f
                    $WorkflowPath,
                    $objJob.Job,
                    $strStepId
                )
            }

            $strIfCondition = if ($arrIfValues.Count -eq 1) {
                $arrIfValues[0]
            }
            else {
                ''
            }

            $arrWithIndices = @(
                for (
                    $intLineIndex = $intStepStart;
                    $intLineIndex -le $intStepEnd;
                    $intLineIndex++
                ) {
                    if ($arrLines[$intLineIndex] -match '^        with\s*:') {
                        $intLineIndex
                    }
                }
            )

            if ($arrWithIndices.Count -ne 1) {
                throw (
                    "External action step needs one block-form with map: {0}|{1}|{2}" -f
                    $WorkflowPath,
                    $objJob.Job,
                    $strStepId
                )
            }

            $intWithIndex = $arrWithIndices[0]

            if ($arrLines[$intWithIndex] -cne '        with:') {
                throw (
                    "External action with map must use block form: {0}|{1}|{2}" -f
                    $WorkflowPath,
                    $objJob.Job,
                    $strStepId
                )
            }

            $hashtableInputs = [ordered]@{}
            $intInputIndex = $intWithIndex + 1

            while ($intInputIndex -le $intStepEnd) {
                $strInputLine = $arrLines[$intInputIndex]

                if ($strInputLine -match '^\s*$') {
                    $intInputIndex++
                    continue
                }

                if ($strInputLine -notmatch '^          ') {
                    break
                }

                if (
                    $strInputLine -cnotmatch (
                        '^          (?<Key>[a-z][a-z0-9-]*):' +
                        '\s*(?<Value>.*?)\s*$'
                    )
                ) {
                    throw (
                        "Unsupported action input syntax: {0}|line {1}: {2}" -f
                        $WorkflowPath,
                        ($intInputIndex + 1),
                        $strInputLine
                    )
                }

                $strInputKey = $Matches.Key
                $strInputValue = $Matches.Value

                if ($hashtableInputs.Contains($strInputKey)) {
                    throw (
                        "Duplicate action input: {0}|{1}|{2}|{3}" -f
                        $WorkflowPath,
                        $objJob.Job,
                        $strStepId,
                        $strInputKey
                    )
                }

                if ($strInputValue -ceq '|') {
                    $arrBlockLines = @()
                    $intInputIndex++

                    while (
                        $intInputIndex -le $intStepEnd -and
                        $arrLines[$intInputIndex] -match '^            (?<Content>.*)$'
                    ) {
                        $arrBlockLines += $Matches.Content
                        $intInputIndex++
                    }

                    if ($arrBlockLines.Count -eq 0) {
                        throw (
                            "Empty action input block: {0}|{1}|{2}|{3}" -f
                            $WorkflowPath,
                            $objJob.Job,
                            $strStepId,
                            $strInputKey
                        )
                    }

                    $hashtableInputs[$strInputKey] = $arrBlockLines -join "`n"
                    continue
                }

                if ([string]::IsNullOrWhiteSpace($strInputValue)) {
                    throw (
                        "Empty action input: {0}|{1}|{2}|{3}" -f
                        $WorkflowPath,
                        $objJob.Job,
                        $strStepId,
                        $strInputKey
                    )
                }

                $hashtableInputs[$strInputKey] = $strInputValue
                $intInputIndex++
            }

            $arrObservedRoles += [pscustomobject]@{
                Workflow = $WorkflowName
                Path = $WorkflowPath
                Job = $objJob.Job
                Step = $strStepId
                Repository = $strRepository
                Sha = $strSha
                Version = $strVersion
                IfCondition = $strIfCondition
                Inputs = $hashtableInputs
            }
        }

        $arrDuplicateStepIds = @(
            $arrExternalStepIds |
                Group-Object -CaseSensitive |
                Where-Object { $_.Count -ne 1 }
        )

        if ($arrDuplicateStepIds.Count -ne 0) {
            throw (
                "Job has duplicate external-action step IDs: {0}|{1}: {2}" -f
                $WorkflowPath,
                $objJob.Job,
                ($arrDuplicateStepIds.Name -join ', ')
            )
        }
    }

    $arrUnparsedUsesLines = @(
        Compare-Object `
            -ReferenceObject $arrAllUsesLineNumbers `
            -DifferenceObject $arrParsedUsesLineNumbers
    )

    if ($arrUnparsedUsesLines.Count -ne 0) {
        throw (
            "Workflow contains an unsupported uses form: {0}: {1}" -f
            $WorkflowPath,
            ($arrUnparsedUsesLines.InputObject -join ', ')
        )
    }

    return $arrObservedRoles
}

$arrDuplicateExpectedPositions = @(
    $arrExpectedActionRoles |
        Group-Object `
            -CaseSensitive `
            -Property { Get-ActionRolePositionKey -Role $_ } |
        Where-Object { $_.Count -ne 1 }
)

if ($arrDuplicateExpectedPositions.Count -ne 0) {
    throw (
        "Expected action inventory has duplicate positions: {0}" -f
        ($arrDuplicateExpectedPositions.Name -join ', ')
    )
}

$arrObservedActionRoles = @()

foreach (
    $objWorkflowGroup in
    $arrExpectedActionRoles |
        Group-Object -CaseSensitive -Property Workflow
) {
    $arrWorkflowPaths = @(
        $objWorkflowGroup.Group.Path |
            Sort-Object -Unique
    )

    if ($arrWorkflowPaths.Count -ne 1) {
        throw (
            "Expected workflow has multiple paths: {0}: {1}" -f
            $objWorkflowGroup.Name,
            ($arrWorkflowPaths -join ', ')
        )
    }

    $arrObservedActionRoles += @(
        Get-WorkflowExternalActionRole `
            -WorkflowName $objWorkflowGroup.Name `
            -WorkflowPath $arrWorkflowPaths[0]
    )
}

$arrExpectedPositionKeys = @(
    $arrExpectedActionRoles |
        ForEach-Object {
            Get-ActionRolePositionKey -Role $_
        } |
        Sort-Object
)
$arrObservedPositionKeys = @(
    $arrObservedActionRoles |
        ForEach-Object {
            Get-ActionRolePositionKey -Role $_
        } |
        Sort-Object
)
$arrPositionDifferences = @(
    Compare-Object `
        -ReferenceObject $arrExpectedPositionKeys `
        -DifferenceObject $arrObservedPositionKeys `
        -CaseSensitive
)

if ($arrPositionDifferences.Count -ne 0) {
    throw (
        "External action role set mismatch: {0}" -f
        (
            @(
                $arrPositionDifferences |
                    ForEach-Object {
                        '{0}:{1}' -f $_.SideIndicator, $_.InputObject
                    }
            ) -join ', '
        )
    )
}

foreach ($objExpectedRole in $arrExpectedActionRoles) {
    $strPositionKey = Get-ActionRolePositionKey -Role $objExpectedRole
    $arrMatchingObservedRoles = @(
        $arrObservedActionRoles |
            Where-Object {
                (Get-ActionRolePositionKey -Role $_) -ceq $strPositionKey
            }
    )

    if ($arrMatchingObservedRoles.Count -ne 1) {
        throw (
            "External action position is not unique: {0}" -f
            $strPositionKey
        )
    }

    $objObservedRole = $arrMatchingObservedRoles[0]

    foreach (
        $strPropertyName in
        @('Repository', 'Sha', 'Version', 'IfCondition')
    ) {
        if (
            [string]$objObservedRole.$strPropertyName -cne
                [string]$objExpectedRole.$strPropertyName
        ) {
            throw (
                "External action {0} mismatch at {1}; expected/actual: {2}/{3}" -f
                $strPropertyName,
                $strPositionKey,
                $objExpectedRole.$strPropertyName,
                $objObservedRole.$strPropertyName
            )
        }
    }

    $arrExpectedInputNames = @(
        $objExpectedRole.Inputs.Keys |
            Sort-Object
    )
    $arrObservedInputNames = @(
        $objObservedRole.Inputs.Keys |
            Sort-Object
    )
    $arrInputNameDifferences = @(
        Compare-Object `
            -ReferenceObject $arrExpectedInputNames `
            -DifferenceObject $arrObservedInputNames `
            -CaseSensitive
    )

    if ($arrInputNameDifferences.Count -ne 0) {
        throw (
            "External action input set mismatch at {0}: {1}" -f
            $strPositionKey,
            (
                @(
                    $arrInputNameDifferences |
                        ForEach-Object {
                            '{0}:{1}' -f $_.SideIndicator, $_.InputObject
                        }
                ) -join ', '
            )
        )
    }

    foreach ($strInputName in $arrExpectedInputNames) {
        if (
            [string]$objExpectedRole.Inputs[$strInputName] -cne
                [string]$objObservedRole.Inputs[$strInputName]
        ) {
            throw (
                "External action input mismatch at {0}|{1}; expected/actual: {2}/{3}" -f
                $strPositionKey,
                $strInputName,
                $objExpectedRole.Inputs[$strInputName],
                $objObservedRole.Inputs[$strInputName]
            )
        }
    }
}
```

### Pull-request evidence

Confirm:

1. The workflow runs for every pull request targeting `main`, including unrelated-path changes.
2. Ubuntu verification is read-only, runs the tracked helper harness under PowerShell 7, and fails for stale artifacts.
3. Diagnostic upload uses the approved pinned upload action, runs after ordinary failure but not cancellation, and uses a run-and-attempt-qualified name.
4. The Windows matrix displays and completes four distinct edition/EOL cells.
5. The two LF cells each run the tracked helper harness and the lone-CR probe under their assigned editions; neither CRLF cell repeats the helper suite.
6. BOM, CR, logical-staleness, and raw-only failures produce distinct diagnostics.
7. No pull-request job has `contents: write`.
8. Push-only jobs skip.
9. Static inspection confirms full-SHA checkout, setup-node, and artifact-action
   pins, Node 24 metadata, Markdown read-only permissions/cache configuration,
   and the exact lease form.
10. The separate Markdown lint workflow checks out with checkout v7.0.1,
    installs and asserts Node major 24 through pinned setup-node v7.0.0 with
    automatic package-manager caching disabled, and completes its existing
    outer and nested lint commands.
11. `.github/dependabot.yml` contains only the review-only weekly
    `github-actions` entry and no auto-merge/npm configuration.

### Controlled push evidence

Use a unique temporary branch or an isolated repository with equivalent Actions permissions. Never run drills against `main`.

#### Successful synchronization drill

1. Temporarily admit only the exact validation branch in the push branch filter.
2. Commit deliberate drift to one generated artifact.
3. Push the branch.
4. Confirm preparation reports `has_changes=true` and produces one nonempty ID/digest pair.
5. Confirm all four Windows cells:
   - download the same ID;
   - use native `digest-mismatch: error`;
   - create and pass a distinct unique job-owned trusted temporary root with
     separate download and initially absent candidate children;
   - run the tracked permanent helper harness, including digest mismatch,
     path-envelope, mandatory real-link, and exact production cleanup-function
     fixtures;
   - invoke the shared helper with explicit checkout/trusted roots and
     caller-owned diagnostic context, which opens with `FileShare.Read`, hashes
     and parses one held stream, validates every existing component from the
     filesystem root at every required boundary, and validates the manifest
     before candidate-directory creation;
   - safely extract and validate the exact candidate; and
   - clean only job-owned temporary state.
6. Confirm approval runs only after all four cells and propagates the same ID/digest.
7. Confirm only synchronization has `contents: write`.
8. Confirm synchronization repeats the tracked harness, unique-root topology,
   mandatory production cleanup-function fixture, and explicit
   helper-interface/lifecycle/cleanup contracts.
9. Confirm candidate, destination, index, and committed blob IDs match.
10. Confirm the commit's only parent is the triggering SHA.
11. Confirm the exact lease and explicit `HEAD:<full-ref>` refspec.
12. Confirm the bot commit contains only the four artifacts.
13. Confirm the `GITHUB_TOKEN` update creates no recursive workflow run.
14. Confirm a manual rerun uses a new attempt-qualified artifact name and does not overwrite the prior artifact.
15. Confirm checkout v7's protected persisted credentials permit the production-form authenticated push without storing credentials in `.git/config`.

#### Propagated-digest rejection drill

1. Use the successful controlled branch.
2. Replace only the expected-digest value supplied to the shared helper with a known-wrong, well-formed 64-hex value.
3. Leave the pinned download action, immutable ID, and real artifact unchanged.
4. Confirm the action's native download succeeds against GitHub's metadata.
5. Confirm the helper fails before `ZipArchive` construction, manifest validation, or candidate-directory creation.
6. Do not describe this as a native action mismatch.
7. Remove the test-only value afterward.

Static inspection of the pinned action contract and source supplies evidence that native v8 uses the artifact metadata digest internally and that `digest-mismatch: error` is fail-closed.

#### Malformed-transport rejection drill

1. In the temporary branch only, create a deterministic, reviewed
   invalid/truncated ZIP.
2. Upload that exact single file with the approved upload action and
   `archive: false`.
3. Note that with `archive: false` the file's name becomes the artifact name
   and the `name` input is ignored; this is harmless because selection is by
   immutable ID.
4. Propagate that upload's real immutable ID and digest as the candidate.
5. Confirm all four Windows cells download the exact ID with
   `skip-decompress: true` and `digest-mismatch: error`.
6. Confirm native download/digest validation and the helper's independent
   digest comparison both succeed for the bytes that were actually uploaded.
7. Confirm each cell then rejects in the helper's `archive-open` phase before
   manifest validation or candidate-directory creation.
8. Confirm approval and synchronization skip.
9. Remove every test-only mutation afterward.

Do not describe this as a native action digest mismatch and do not attempt to
corrupt GitHub's artifact service. The rejected artifact does not need to reach
the writer; the writer uses the same helper and is separately exercised by the
tracked harness and successful write drill.

#### Unrelated-file-only trigger check

1. Base a new temporary-branch commit on the successful synchronization commit.
2. Change only a tracked unrelated path.
3. Push normally.
4. Confirm the push workflow runs.
5. Confirm preparation reports `has_changes=false`.
6. Confirm approval succeeds and synchronization skips.

#### Preflight stale-ref rejection drill

1. Ensure a candidate difference exists.
2. In the controlled branch only, substitute a known nonmatching repository-native object ID for the local expected-object value immediately before the preliminary remote comparison; do not change the target ref or push command shape.
3. Confirm the exact remote-record comparison fails before copying, staging, committing, or pushing.
4. Confirm no retry.

#### Exact-lease rejection drill

1. Start with the remote validation branch at the real triggering SHA.
2. Let checkout, preparation, the four-cell matrix, approval, preliminary remote guard, copying, staging, commit creation, and blob proofs use the real SHA.
3. In the controlled branch only, substitute a known nonmatching repository-native complete object ID into `$strExpectedSha` immediately before the production-form push; leave the target and refspec unchanged.
4. Invoke the production-form push.
5. Require a nonzero exit.
6. Use `git ls-remote` afterward to prove the remote still equals the original triggering SHA.
7. Confirm no fetch, rebase, amendment, regeneration, adaptation, or retry.

Remove every test-only mutation and delete the temporary branch after evidence collection.

### Post-merge evidence

After merge:

1. Confirm the `main` push pipeline runs.
2. Confirm preparation uploads one immutable candidate and exposes its ID/digest.
3. Confirm the four-cell matrix validates that exact candidate.
4. Confirm the native digest configuration and the helper's independent digest check pass.
5. Confirm the tracked helper harness passes in all four unconditional Windows consumers.
6. Because this issue intentionally leaves generated artifacts unchanged, confirm `has_changes=false`.
7. Confirm approval succeeds and synchronization skips.
8. Confirm no bot synchronization commit is created.
9. Observe the first naturally occurring unrelated-file-only push to `main`; do not create a synthetic `main` commit solely for this observation.

## Acceptance criteria

- All four complete payloads normalize with `` -replace "`r`n?", "`n" `` immediately before serialization.
- All four writes use resolved paths, `UTF8Encoding($false)`, and `WriteAllText`.
- The LF-joined frontmatter is exact.
- Generated artifacts remain byte-identical under supported LF and CRLF inputs.
- `.gitattributes` remains unchanged with `* text=auto eol=lf`.
- The generator, helper, and tracked self-test harness receive correctly calculated script versions.
- Both events retain `branches: [main]` and have no path filter.
- Every pull request targeting `main` obtains verification.
- Every push to `main` starts the push pipeline.
- Pull-request jobs are read-only and stale artifacts fail.
- Every checkout in `build.yml` and `markdownlint.yml` uses the approved
  checkout v7 Node 24 full commit SHA with a matching comment, and the exact
  role validator rejects a missing, extra, duplicate, misplaced, malformed, or
  input-weakened action step.
- `markdownlint.yml` uses the approved setup-node v7 full commit SHA, installs Node 24 with automatic package-manager caching disabled, declares `contents: read`, and passes its unchanged outer and nested lint commands.
- Local and hosted validation assert Node major 24 before a clean install and
  both existing Markdown lint commands.
- Artifact uploads and downloads use approved full commit SHAs with matching
  comments; `$arrExpectedActionRoles` proves the exact role set, placement,
  tuple, condition, and complete allowed input sets.
- Preparation declares `archive: true` and exposes one nonempty immutable ID/digest pair.
- All four Windows push cells always download only by that ID, run the tracked harness, and invoke the helper.
- Synchronization downloads only by that ID, runs the tracked harness, and invokes the helper only when `has_changes=true` and the job starts.
- On the expected no-drift push, all four Windows cells succeed and synchronization is skipped at the job level.
- Native downloads set `digest-mismatch: error` and `skip-decompress: true`.
- The shared helper is the only candidate extraction implementation.
- Every helper consumer creates one unique job-owned trusted temporary root,
  with separate download and initially absent candidate children, and never
  silently reuses an existing root.
- The helper receives explicit mutually non-overlapping checkout and trusted
  temporary roots, requires download/candidate paths beneath that trusted root
  and outside checkout, and does not infer security context from Git or GitHub
  environment variables.
- The helper uses separator-safe platform path comparisons, checks every
  existing component from the filesystem volume/share root, rejects
  reparse/symlink indirection and uncertainty, and repeats relevant checks
  before archive open, before candidate creation, and after extraction.
- The issue states the runner-controlled, job-owned, no-competing-writer
  residual race model without claiming an OS-native handle guarantee.
- The helper distinguishes omitted, supplied, and explicitly empty
  `ArtifactId`, `RunId`, and `RunAttempt` values through caller binding state.
- The helper opens the retained archive once with `FileShare.Read`, hashes that
  held stream, compares it with the propagated upload digest, rewinds it, and
  constructs/uses `ZipArchive` over the same stream.
- Every security-sensitive exact count/set uses materialized `Directory.EnumerateFileSystemEntries`; candidate-parent enumeration rejects matching files, directories, links/reparse points, and dangling links immediately before creation.
- The candidate leaf is absent until digest and manifest validation succeed and
  is created once. Pre-creation failures leave absence intact, pre-existing
  leaves remain unchanged, and later failures use the exact ownership journal
  and named `Remove-StyleGuideCandidateInvocationState` function to remove
  proven ordinary state or retain all uncertain state with the primary and
  `cleanup` failures.
- One tracked, versioned harness owns the deterministic fixture suite and
  invokes ordinary cases through the exact tracked helper's public expansion
  interface. Only the unsafe-cleanup fixture definition-only loads and invokes
  the exact named production cleanup function.
- Pull-request verification runs that harness under Ubuntu PowerShell 7 and in the two Windows LF cells under Windows PowerShell 5.1 and PowerShell 7.
- Every started push consumer runs that same tracked harness against the exact tracked helper before its production helper invocation.
- The harness implements every stable case ID in the normative oracle table, emits the expected phase/diagnostic record, and distinguishes a named platform skip from a pass.
- Mandatory `K-01` proves the exact production cleanup function retains an
  unexpected unjournaled ordinary child without partial deletion and reports
  both failures.
- Every rejection case applies its row's state-specific candidate
  postcondition; digest mismatch fails before `ZipArchive` construction.
- Both archive successes, sibling-prefix and filesystem-qualified successes,
  Windows/Linux case behavior, hidden/system enumeration, mutual root overlap,
  volume/share-root and below-root component links, existing
  file/directory/link/dangling candidate leaves, all manifest forms, invalid
  ZIP, post-extraction BOM/CR cleanup, supplied/omitted labels, and all three
  empty-label cases have the table's required path/type/byte oracle.
- At least one real component-or-leaf link rejection executes on Ubuntu and at
  least one real component-or-leaf link/reparse rejection executes on Windows;
  no platform-wide link-fixture skip satisfies acceptance.
- Only the exact four entries are extracted, as new regular, non-reparse-point files.
- The Windows topology is an actual four-cell edition × EOL matrix with `fail-fast: false`.
- Each cell runs only its assigned edition and EOL.
- The two LF cells run lone-CR sanitation under their assigned editions.
- Approval runs only after all four push cells succeed.
- The sole write job downloads only the approved ID.
- Candidate, destination, stage-0 index, and committed blob IDs match.
- The mutation block copies `TARGET_REF` and `EXPECTED_SHA` once, validates them against `GITHUB_REF` and `GITHUB_SHA`, proves one native full `HEAD^{commit}` and one exact remote record, then reuses the unchanged locals.
- The synchronization commit has exactly one parent equal to the validated expected-SHA local.
- The final push uses `HEAD:<target-ref>` and an exact expected-SHA lease.
- No unconditional force form, implicit destination, adaptation, or retry exists.
- Every native command has an immediate exit-code check.
- Every custom workflow and local PowerShell block begins with `$ErrorActionPreference = 'Stop'`.
- Local validation asserts Desktop exactly 5.1 or Core major 7 in the same
  child process that invokes each harness/generator target, then verifies that
  edition's result before another edition can overwrite it.
- Local validation requires Node major 24, clean install, and both Markdown lint
  commands.
- CI supplies mandatory coverage for both editions.
- Before local staging, the complete changed-path set is exactly the generator,
  helper, self-test harness, build workflow, Markdown lint workflow, and
  Dependabot configuration.
- After staging, the cached path set is exactly those same six files.
- Controlled synchronization, propagated-digest rejection, malformed-
  transport rejection, unrelated-trigger, stale-preflight, and exact-lease
  drills pass without touching `main`.
- The generator and helper convergence matrices truthfully identify shared
  observable invariants and repository-specific values, transforms, names,
  fixtures, placement, and transport choices; implementation-start evidence
  records current divergence without claiming blanket P1/T1 identity or
  creating a runtime dependency.
- `.github/dependabot.yml` contains exactly one review-only weekly
  `github-actions` entry for `/`; no npm entry, auto-merge, or auto-approval is
  introduced, and every external action matches its exact approved
  repository/full-SHA/same-line-version tuple and required workflow role.
- No generated artifact, source guide, or `.gitattributes` changes in the
  implementing commit; `markdownlint.yml` changes only at checkout,
  setup-node, Node version/assertion, cache configuration, and explicit
  read-only permissions unless Node 24 compatibility validation proves another
  change is required.

## References

- [PSStyleGuide: Programmatic File Writing Encoding](https://github.com/franklesniak/PSStyleGuide/blob/main/STYLE_GUIDE.md#programmatic-file-writing-encoding)
- [PSStyleGuide: Line Endings for Byte-Exact Text Artifacts](https://github.com/franklesniak/PSStyleGuide/blob/main/STYLE_GUIDE.md#line-endings-for-byte-exact-text-artifacts)
- [PSStyleGuide: Resolving Paths for .NET Static Methods](https://github.com/franklesniak/PSStyleGuide/blob/main/STYLE_GUIDE.md#resolving-paths-for-net-static-methods)
- [PSStyleGuide: Function and Script Versioning](https://github.com/franklesniak/PSStyleGuide/blob/main/STYLE_GUIDE.md#function-and-script-versioning)
- [Microsoft Learn: `about_Character_Encoding`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_character_encoding)
- [Microsoft Learn: `about_Operator_Precedence`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_operator_precedence)
- [Microsoft Learn: `about_Preference_Variables`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_preference_variables)
- [Microsoft Learn: `about_Quoting_Rules`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_quoting_rules)
- [Microsoft Learn: `about_Automatic_Variables`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_automatic_variables)
- [Microsoft Learn: `Get-FileHash`](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/get-filehash)
- [Microsoft Learn: `UTF8Encoding` constructor](https://learn.microsoft.com/dotnet/api/system.text.utf8encoding.-ctor)
- [Microsoft Learn: `File.WriteAllText`](https://learn.microsoft.com/dotnet/api/system.io.file.writealltext)
- [Microsoft Learn: `File.ReadAllText`](https://learn.microsoft.com/dotnet/api/system.io.file.readalltext)
- [Microsoft Learn: `File.ReadAllBytes`](https://learn.microsoft.com/dotnet/api/system.io.file.readallbytes)
- [Microsoft Learn: `FileMode`](https://learn.microsoft.com/dotnet/api/system.io.filemode)
- [Microsoft Learn: PowerShell `PathIntrinsics`](https://learn.microsoft.com/dotnet/api/system.management.automation.pathintrinsics)
- [Microsoft Learn: `Path.GetFullPath`](https://learn.microsoft.com/dotnet/api/system.io.path.getfullpath)
- [Microsoft Learn: `Path.GetPathRoot`](https://learn.microsoft.com/dotnet/api/system.io.path.getpathroot)
- [Microsoft Learn: `Path.GetRandomFileName`](https://learn.microsoft.com/dotnet/api/system.io.path.getrandomfilename)
- [Microsoft Learn: `Path.GetRelativePath` platform comparison behavior](https://learn.microsoft.com/dotnet/api/system.io.path.getrelativepath)
- [Microsoft Learn: `Directory.EnumerateFileSystemEntries`](https://learn.microsoft.com/dotnet/api/system.io.directory.enumeratefilesystementries)
- [Microsoft Learn: `DirectoryInfo`](https://learn.microsoft.com/dotnet/api/system.io.directoryinfo)
- [Microsoft Learn: `FileSystemInfo.Attributes`](https://learn.microsoft.com/dotnet/api/system.io.filesysteminfo.attributes)
- [Microsoft Learn: `FileStream`](https://learn.microsoft.com/dotnet/api/system.io.filestream)
- [Microsoft Learn: `FileShare`](https://learn.microsoft.com/dotnet/api/system.io.fileshare)
- [Microsoft Learn: `ZipArchive` constructors](https://learn.microsoft.com/dotnet/api/system.io.compression.ziparchive.-ctor)
- [Microsoft Learn: `ZipArchive.Entries`](https://learn.microsoft.com/dotnet/api/system.io.compression.ziparchive.entries)
- [Microsoft Learn: `ZipArchive.CreateEntry`](https://learn.microsoft.com/dotnet/api/system.io.compression.ziparchive.createentry)
- [Microsoft Learn: `ZipArchiveEntry.Open`](https://learn.microsoft.com/dotnet/api/system.io.compression.ziparchiveentry.open)
- [Microsoft Learn: `ZipArchiveEntry.FullName`](https://learn.microsoft.com/dotnet/api/system.io.compression.ziparchiveentry.fullname)
- [Microsoft Learn: `ZipArchiveEntry.ExternalAttributes`](https://learn.microsoft.com/dotnet/api/system.io.compression.ziparchiveentry.externalattributes)
- [Git: `git status`](https://git-scm.com/docs/git-status)
- [Git: `gitattributes`](https://git-scm.com/docs/gitattributes)
- [Git: `git diff`](https://git-scm.com/docs/git-diff)
- [Git: `git hash-object`](https://git-scm.com/docs/git-hash-object)
- [Git: `git rev-parse`](https://git-scm.com/docs/git-rev-parse)
- [Git: `git ls-remote`](https://git-scm.com/docs/git-ls-remote)
- [Git: `git push`](https://git-scm.com/docs/git-push)
- [GitHub Docs: Store and share data with workflow artifacts](https://docs.github.com/en/actions/tutorials/store-and-share-data)
- [GitHub Docs: Workflow syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax)
- [GitHub Docs: Workflow `permissions`](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#permissions)
- [GitHub Docs: Evaluate expressions in workflows and actions](https://docs.github.com/en/actions/reference/workflows-and-actions/expressions)
- [GitHub Docs: Secure use reference](https://docs.github.com/en/actions/reference/security/secure-use)
- [GitHub Docs: Keep actions up to date with Dependabot](https://docs.github.com/en/code-security/how-tos/secure-your-supply-chain/secure-your-dependencies/auto-update-actions)
- [GitHub Docs: Dependabot supported ecosystems](https://docs.github.com/en/code-security/reference/supply-chain-security/supported-ecosystems-and-repositories)
- [GitHub Docs: `GITHUB_TOKEN` trigger behavior](https://docs.github.com/en/actions/concepts/security/github_token)
- [GitHub Changelog: Deprecation of Node 20 on GitHub Actions runners](https://github.blog/changelog/2025-09-19-deprecation-of-node-20-on-github-actions-runners/)
- [Node.js: release status](https://nodejs.org/en/about/previous-releases)
- [Node.js Release Working Group schedule](https://github.com/nodejs/Release#release-schedule)
- [GitHub: `actions/checkout` v7.0.1 exact metadata](https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml)
- [GitHub: `actions/checkout` v7.0.1 exact README](https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/README.md)
- [GitHub: `actions/checkout` v7.0.1 release](https://github.com/actions/checkout/releases/tag/v7.0.1)
- [GitHub: `actions/setup-node` v7.0.0 exact metadata](https://raw.githubusercontent.com/actions/setup-node/820762786026740c76f36085b0efc47a31fe5020/action.yml)
- [GitHub: `actions/setup-node` v7.0.0 exact README](https://raw.githubusercontent.com/actions/setup-node/820762786026740c76f36085b0efc47a31fe5020/README.md)
- [GitHub: `actions/setup-node` v7.0.0 release](https://github.com/actions/setup-node/releases/tag/v7.0.0)
- [GitHub: `actions/upload-artifact` v7.0.1 exact metadata](https://raw.githubusercontent.com/actions/upload-artifact/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a/action.yml)
- [GitHub: `actions/upload-artifact` v7.0.1 exact README](https://raw.githubusercontent.com/actions/upload-artifact/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a/README.md)
- [GitHub: `upload-artifact` v7.0.1](https://github.com/actions/upload-artifact/releases/tag/v7.0.1)
- [GitHub: `actions/download-artifact` v8.0.1 exact metadata](https://raw.githubusercontent.com/actions/download-artifact/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/action.yml)
- [GitHub: `actions/download-artifact` v8.0.1 exact README](https://raw.githubusercontent.com/actions/download-artifact/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/README.md)
- [GitHub: `actions/download-artifact` v8.0.1 exact implementation](https://raw.githubusercontent.com/actions/download-artifact/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/src/download-artifact.ts)
- [GitHub: `download-artifact` v8.0.1](https://github.com/actions/download-artifact/releases/tag/v8.0.1)
- [franklesniak/copilot-repo-template#851](https://github.com/franklesniak/copilot-repo-template/issues/851)
- [franklesniak/copilot-repo-template#852](https://github.com/franklesniak/copilot-repo-template/pull/852)
