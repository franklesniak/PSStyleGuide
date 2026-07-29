# Make artifact generation byte-deterministic and standardize repository text checkouts on LF

## Summary

`.github/workflows/Generate-StyleGuideArtifacts.ps1` currently writes generated artifacts with edition-dependent PowerShell encoding behavior. Windows PowerShell 5.1 writes `UTF8` with a BOM, while PowerShell 7 writes BOM-less UTF-8. The supported generator can therefore emit different bytes depending on the executing edition.

The repository also lacks a version-controlled line-ending policy, so Git configuration, operating system defaults, or editors can supply CRLF working files even though committed blobs use LF.

Make generation byte-deterministic and establish a safe, least-privileged synchronization pipeline by:

- Canonicalizing CRLF and lone CR to LF in every complete final payload immediately before serialization.
- Writing with resolved paths and explicit BOM-less `.NET` UTF-8 encoding.
- Adding `* text=auto eol=lf`.
- Recording versions for the generator and the new archive-validation helper.
- Running verification for every pull request targeting `main`.
- Running the push pipeline for every push to `main`.
- Preparing one immutable synchronization candidate in a read-only job.
- Downloading by immutable artifact ID with the pinned action, `skip-decompress: true`, and `digest-mismatch: error`.
- Using one shared, versioned PowerShell helper for candidate digest verification, archive validation, and extraction on Windows and Ubuntu.
- Passing preparation's propagated upload digest to that helper, which independently compares it with the retained ZIP's SHA-256 before opening the archive.
- Running the deterministic fixture self-test suite against that exact helper in the Ubuntu pull-request job, all four Windows pull-request cells, all four Windows push cells, and the synchronization writer whenever `has_changes=true`.
- Validating the ZIP manifest before creating an extraction directory.
- Validating the exact candidate in an actual four-cell edition × fixture-EOL Windows matrix.
- Approving the candidate only after the complete Windows matrix succeeds.
- Giving write permission only to the final synchronization job.
- Proving candidate, destination, staged, and committed blob identity.
- Pushing with an exact expected-SHA lease and explicit full-ref destination.
- Retaining diagnostic artifacts after ordinary pull-request failures but not cancellation.
- Requiring local validation to verify each available PowerShell edition before another edition can overwrite its output.
- Refusing to stage from a working tree containing any path other than the four implementation files.
- Proving that every final writer removes lone CR characters without claiming CR-only source compatibility.

This issue is a prerequisite for "Make state-version discovery and recovery examples copy-safe with guarded identifiers." Complete and merge this issue first.

## Affected files

- `.gitattributes` — add.
- `.github/workflows/Generate-StyleGuideArtifacts.ps1`
- `.github/workflows/Expand-StyleGuideCandidateArtifact.ps1` — add.
- `.github/workflows/build.yml`

The following generated artifacts must be regenerated during validation but remain byte-for-byte unchanged:

- `copilot-instructions.md`
- `terraform.instructions.md`
- `STYLE_GUIDE_CHAT.md`
- `STYLE_GUIDE_FULL.md`

Do not hand-edit generated artifacts.

## Requested changes

### 1. Normalize complete payloads at the serialization boundary

Use this mapping:

| Function | Complete final payload |
| --- | --- |
| `New-StyleGuideCopilotVersion` | `$strContent` |
| `New-StyleGuideTerraformInstructionsVersion` | `$strFullContent` |
| `New-StyleGuideChatVersion` | `$strWrappedContent` |
| `New-StyleGuideFullVersion` | `$strOutput` |

Immediately before encoding each complete payload, use:

```powershell
$strNormalizedContent = <complete final payload> -replace "`r`n?", "`n"
```

Replace the explanatory placeholder with the applicable variable.

Requirements:

- Normalize after all transformations and concatenations.
- Convert CRLF to one LF.
- Convert lone CR to one LF.
- Leave existing LF unchanged.
- Preserve `New-StyleGuideFullVersion`'s existing split/join behavior.
- Do not normalize after writing.
- Do not claim semantic compatibility with CR-only source documents.

The generator's frontmatter is already constructed by joining an array with `` "`n" ``; that construction is correct and must not be modified for symmetry with any other repository.

### 2. Replace all four artifact write sites

Replace each artifact-writing `Set-Content` call with:

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

After implementation:

- All four complete payloads are normalized.
- All four writes use `WriteAllText`.
- No artifact-writing `Set-Content` remains.
- No newline is appended implicitly.

### 3. Add the repository-wide LF policy

Create root `.gitattributes` containing exactly:

```gitattributes
* text=auto eol=lf
```

This means:

- Git automatically classifies text and binary files.
- Text is normalized to LF in the index.
- Text is checked out with LF regardless of platform or `core.autocrlf`.
- Binary files are not normalized.
- Later, more-specific rules may override the default when technically justified.

`git add --renormalize .` reapplies clean filters to tracked index entries. It does not add untracked files and does not rewrite existing working-tree bytes. Staging, renormalization, and the exact staged-set verification are performed by the validation block below.

If renormalization stages a path other than the four implementation files, investigate it. Do not commit unexplained mass normalization.

### 4. Record workflow-script versions

Both PowerShell files must contain a top-level comment-based-help `.NOTES` version.

For a new or still-unversioned script, use:

```text
Version: 1.0.YYYYMMDD.0
```

Replace `YYYYMMDD` with the implementation's current UTC date.

If the generator has acquired a version before implementation:

1. Increment Major for a breaking interface or behavior-contract change.
2. Increment Minor for a nonbreaking feature or behavior addition.
3. Treat this serialization correction as fix-class; do not increment Major or Minor solely for it.
4. Set Build to the current UTC date.
5. Reset Revision to `0` when `Major.Minor.Build` changes.
6. If that `Major.Minor.Build` already exists at Revision `N`, use `N + 1`.

Do not change the Terraform style guide's version, `Last Updated`, or rationale changelog in this issue.

### 5. Run both events without path filters

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

Do not add `paths` or `paths-ignore` to either event.

Every pull request targeting `main` must instantiate verification, and every push to `main` must instantiate the push pipeline.

Do not rely on workflow concurrency for correctness. A stale writer must be rejected by exact-SHA checks and the final lease; a newer push run handles the newer commit.

Retain `[skip ci]` in the bot commit message only as a compatibility convention. The `GITHUB_TOKEN` trigger rule, not the commit text, prevents recursive workflow execution.

### 6. Add one shared archive-validation and extraction helper

Create:

```text
.github/workflows/Expand-StyleGuideCandidateArtifact.ps1
```

The helper's filename, parameter interface, validation order, and diagnostics are intentionally aligned with the equivalent helper in the PSStyleGuide repository; the four expected manifest names are the intentional repository-specific difference. This alignment is a design objective, not a cross-repository dependency.

The script must:

- Declare `#Requires -Version 5.1`.
- Record its script version.
- Accept:
  - A candidate download directory.
  - An initially nonexistent candidate destination directory.
  - The expected candidate archive digest.
- Derive the trusted checkout root from the helper's own fixed tracked location at `.github/workflows/Expand-StyleGuideCandidateArtifact.ps1`; verify that location invariant and never accept the checkout boundary from the caller, current working directory, or mutable process state.
- Resolve filesystem paths before using `.NET` static methods.
- Work under Windows PowerShell 5.1 and PowerShell 7 on Windows and Ubuntu.
- Load required compression assemblies explicitly under Windows PowerShell 5.1.

For path comparisons:

- Convert PowerShell paths to absolute filesystem-provider paths before passing them to `.NET`.
- Use separator-aware descendant checks; a sibling prefix such as `TerraformStyleGuide-other` is not inside `TerraformStyleGuide`.
- Use ordinal-ignore-case comparison on Windows and ordinal comparison on non-Windows.
- Use `Directory.EnumerateFileSystemEntries` for every exact filesystem-entry assertion. Materialize each enumeration once before counting or inspecting it.
- If PowerShell enumeration is used for supporting diagnostics, require `Get-ChildItem -LiteralPath ... -Force`; plain `Get-ChildItem` is prohibited for an exact-count decision.

#### Download-directory contract

The helper must require:

- The download directory and its existing parent resolve outside the tracked checkout.
- The download directory and existing parent are ordinary directories, not reparse points.
- Exhaustive top-level enumeration contains exactly one filesystem entry, including hidden or system entries.
- That entry is a regular, non-reparse-point file.
- The file can be opened read-only as a ZIP archive.

Do not require a `.zip` filename extension; validate the archive by opening it. The retained file's name comes from the download's Content-Disposition header and may be the literal fallback name `artifact`.

#### Expected-digest contract

Before opening the archive, the helper must:

1. Require the expected digest to match `^[0-9A-Fa-f]{64}$`.
2. Calculate the retained ZIP's SHA-256 with `Get-FileHash -Algorithm SHA256`.
3. Compare the actual and expected digests using ordinal, case-insensitive equality.
4. Fail before opening the archive if they differ.
5. Record the artifact ID, expected digest, actual digest, run ID, run attempt, and archive path in diagnostics when those values are available.

The expected value is always the propagated `artifact-digest` output of the pinned upload action, which is a bare hexadecimal SHA-256 string. Never supply the `sha256:`-prefixed form that appears in download-action logs and artifact API metadata.

#### Manifest contract

Before creating the candidate destination directory, require exactly these four ordinal, root-level, non-directory entry names:

```text
copilot-instructions.md
terraform.instructions.md
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
- Nested paths.
- `.` or `..` traversal.
- Absolute or drive-qualified paths.
- File/directory collisions.
- Any name other than the four exact ordinal names.

Complete manifest validation before creating or writing the candidate directory.

#### Destination-directory lifecycle

The caller may create a protected temporary parent directory outside the checkout, but that parent must be an ordinary non-reparse-point directory and the candidate leaf must have no filesystem entry.

The helper must:

1. Resolve the candidate leaf path from its resolved existing parent without creating it.
2. Assert that the parent and leaf are outside the checkout.
3. Enumerate the parent exhaustively and reject any entry with the candidate leaf name using the operating system's filesystem comparison, including an existing file, directory, symlink, reparse point, or dangling link.
4. Validate the digest, the complete archive, and the manifest.
5. Re-enumerate the parent and reconfirm that the leaf remains absent.
6. Create the leaf exactly once.
7. Never delete and recreate it.
8. Refuse to reuse or follow an existing leaf.

A digest or manifest failure must leave the candidate leaf nonexistent.

#### Extraction contract

For each permitted entry:

1. Resolve the destination with `GetFullPath`.
2. Prove it is an immediate child of the candidate root.
3. Open the destination with `FileMode.CreateNew`, write access, and no sharing.
4. Copy only the entry stream.
5. Dispose all streams and archives deterministically.

Do not restore:

- Symlink information.
- Unix file types or modes.
- Windows attributes.
- Timestamps.
- Any other ZIP metadata.

ZIP external attributes are not a rejection criterion. Safety comes from creating fresh regular files in a fresh directory.

After extraction:

- Enumerate the candidate directory exhaustively with `Directory.EnumerateFileSystemEntries`.
- Require exactly the four expected root-level paths.
- Require every path to be a regular, non-reparse-point file.
- Reject every BOM and CR byte.
- Return or log the four resolved candidate paths.

Failures must include the artifact ID, upload digest, run ID, run attempt, archive path, and offending entry or destination when those values are available.

No workflow step may call an automatic ZIP extraction API for this candidate.

#### Permanent helper self-test

The Ubuntu pull-request job, every Windows pull-request cell, every Windows push cell, and the synchronization writer whenever `has_changes=true` must create deterministic fixtures under a unique runner-temporary root and invoke the exact production helper. The suite must use stable case identifiers and this outcome contract:

| Fixture class | Expected result | Required phase and postcondition |
| --- | --- | --- |
| Exact valid archive with its correct digest | Success | Extract exactly the four expected ordinary, non-reparse-point files with expected bytes. |
| Exact valid archive with one entry carrying symlink-like external attributes | Success | Extract exactly four ordinary, non-reparse-point files; restore no link, type, mode, timestamp, or other ZIP metadata. |
| Valid exact archive with a deliberately altered, well-formed 64-hex expected digest | Reject | Fail before opening the ZIP and before candidate-leaf creation. |
| Missing or extra archive entry | Reject | Fail after ZIP open but before candidate-leaf creation or entry extraction. |
| Exact duplicate or case-only collision | Reject | Fail after ZIP open but before candidate-leaf creation or entry extraction. |
| Forward- or backslash-nested path | Reject | Fail after ZIP open but before candidate-leaf creation or entry extraction. |
| Forward or backward traversal | Reject | Fail after ZIP open but before candidate-leaf creation or entry extraction. |
| Leading-slash, leading-backslash, or drive-qualified name | Reject | Fail after ZIP open but before candidate-leaf creation or entry extraction. |
| Directory entry or file/directory collision | Reject | Fail after ZIP open but before candidate-leaf creation or entry extraction. |
| Empty central-directory name using a reviewed fixed raw fixture | Reject | Fail after ZIP open but before candidate-leaf creation or entry extraction. |
| Invalid or truncated ZIP | Reject | Fail during ZIP open/read before candidate-leaf creation. |
| Hidden extra entry in the download directory | Reject | Fail before selecting or opening an archive. |
| Existing candidate file or directory | Reject | Fail before ZIP extraction and never reuse the leaf. |
| Candidate symlink/reparse point or dangling candidate link | Reject | Fail before ZIP extraction and never follow the leaf. |
| Checkout-sibling prefix path | Success as an outside-checkout classification fixture | Prove the separator-aware check does not misclassify a sibling such as `<checkout>-other` as inside the checkout. |

`ZipArchive.CreateEntry` may be used for constructible cases. Because it rejects an empty name at creation time, use a deterministic reviewed raw fixture for that case.

For each rejection fixture:

- Require the helper to fail.
- Require the destination directory to remain nonexistent.
- Require no write outside the fixture root.
- Require the digest-mismatch fixture to fail before the archive is opened.
- Include the case and offending entry in diagnostics when available.

For each successful archive fixture:

- Require successful extraction.
- Require exactly the four expected root-level regular files.
- Require expected bytes, no BOM or CR, and no restored archive metadata.

For every fixture:

- Compute the actual archive digest except for the deliberately altered expected-digest case.
- Assert the expected success or rejection explicitly; an exception without the matching phase/postcondition assertion is not a complete oracle.
- Clean all fixture state in `finally`.
- Do not silently count an unavailable symlink/reparse fixture as passing. Fail the cell or emit an explicit, narrowly justified platform skip while ensuring the same case executes successfully on another required runner.

These are production contract self-tests exercising the exact tracked helper, not a bypass or alternate extraction implementation. Pull-request Ubuntu verification, all four pull-request Windows cells, all four push Windows cells, and the writer whenever `has_changes=true` collectively exercise both operating-system families before merge and at use time.

### 7. Use least-privileged, immutable candidate transport

Remove workflow-level `contents: write`.

Only the synchronization writer may declare:

```yaml
permissions:
  contents: write
```

All other jobs must use no more than:

```yaml
permissions:
  contents: read
```

#### Native-command contract

Every custom PowerShell `run:` block must:

- Use an explicit `powershell` or `pwsh` shell.
- Begin with `$ErrorActionPreference = 'Stop'`.
- Capture `$LASTEXITCODE` immediately after every native command.
- Require exit code `0` unless another allowed set is explicitly documented.
- Treat Git diff exit code `1` as an ordinary difference only where documented.
- Treat every other diff exit code as command failure.
- Require `git ls-remote --exit-code` to return `0`; exit `2` is failure.
- Validate parsed output count and shape.
- Include command purpose and exit code in failures.

Do not rely on `$PSNativeCommandUseErrorActionPreference`.

#### Artifact-action pins

As of 2026-07-28, use:

```yaml
uses: actions/upload-artifact@043fb46d1a93c77aae656e7c1c64a875d1fc6a0a # v7.0.1
```

and:

```yaml
uses: actions/download-artifact@3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c # v8.0.1
```

Immediately before implementation:

1. Verify each SHA in the official action repository.
2. Verify the adjacent version comment.
3. Check for a newer required security release.
4. If changed, update the SHA, comment, references, and evidence together.
5. Do not use a branch or movable tag.
6. Do not select a download release lacking `artifact-ids`, `skip-decompress`, or `digest-mismatch`.

#### Digest integrity

Every production download must explicitly set:

```yaml
skip-decompress: true
digest-mismatch: error
```

Two complementary protections apply:

1. **Native protection.** The pinned download action obtains the artifact's digest from GitHub metadata, passes it as the expected hash, and fails the action when the computed digest differs and behavior is `error`. Do not attempt a live drill that corrupts GitHub's artifact service to induce a native mismatch; record static evidence instead:
   - The final workflow uses the approved full SHA and the two explicit inputs.
   - The pinned action source obtains `artifact.digest` from GitHub metadata and passes it as the expected hash.
   - It throws when the actual digest differs and behavior is `error`.
   - Successful controlled and post-merge logs show the expected artifact ID/digest and completed download.
   - A version-matched upstream negative test may be cited when available, but is not a repository acceptance blocker.
2. **Independent protection.** Every Windows push cell, and the writer whenever `has_changes=true`, passes preparation's propagated `artifact-digest` output to the shared helper, which independently compares the retained ZIP's SHA-256 with that value before opening the archive, per the helper's expected-digest contract. This protection is exercised by the propagated-digest rejection drill below and by the digest-mismatch self-test fixture.

### 8. Pull-request verification

#### Ubuntu verification

The pull-request Ubuntu job must:

- Run only for `pull_request`.
- Use `ubuntu-latest`.
- Use `contents: read`.
- Check out the exact event SHA.
- Run the permanent helper self-test against the exact tracked helper under `shell: pwsh`, assert Core major version 7 in that same process, and clean the runner-temporary fixture root in `finally`.
- Run the generator with `pwsh`.
- Compare all four artifacts logically and by raw blob identity with `HEAD`.
- Upload exactly four diagnostic artifacts after success or ordinary failure, but not cancellation.
- Use an attempt-qualified name containing `github.run_id` and `github.run_attempt`.
- Set `overwrite: false`.
- Never commit or push.

Use:

```yaml
if: ${{ !cancelled() }}
```

A stale-artifact message must instruct the contributor to regenerate, review, and commit all four artifacts.

#### Four-cell Windows validation topology

Implement separate pull-request and push Windows matrix jobs using:

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

Use these rules:

- `shell: powershell` when `matrix.edition == 'desktop'`;
- `shell: pwsh` when `matrix.edition == 'core'`;
- `shell: pwsh` for edition-neutral fixture preparation and inspection.

Implement helper execution as two mutually exclusive steps rather than a `pwsh` dispatcher:

- The Desktop step uses `if: ${{ matrix.edition == 'desktop' }}` and `shell: powershell`.
- The Core step uses `if: ${{ matrix.edition == 'core' }}` and `shell: pwsh`.
- Each step asserts its required edition/version and invokes the self-test in that same process.
- On push, that same edition-specific step invokes the production helper immediately after its self-test.
- No edition-neutral `pwsh` step may dot-source, call, or launch `Expand-StyleGuideCandidateArtifact.ps1`.

Each cell must:

1. Check out the exact event SHA.
2. Prove `HEAD` equals the expected SHA.
3. Prove the fresh checkout of `STYLE_GUIDE.md`, `STYLE_GUIDE_RATIONALE.md`, the generator, and the helper contains at least one LF and no CR.
4. For push validation:
   - depend on preparation;
   - download preparation's exact ID;
   - retain the downloaded archive outside the checkout with no automatic extraction.
5. In the edition-specific helper step:
   - validate only the assigned edition:
     - `desktop`: `PSEdition == 'Desktop'` and version exactly 5.1;
     - `core`: `PSEdition == 'Core'` and major version 7;
   - run the permanent helper self-test on both events;
   - on push, invoke the shared helper with the propagated digest to validate and safely extract the exact candidate before generation.
6. Prepare only the assigned source fixture:
   - `lf`: retain and prove BOM-less LF with no CR;
   - `crlf`: convert `STYLE_GUIDE.md`, `STYLE_GUIDE_RATIONALE.md`, and the generator using `UTF8Encoding($false)`, `ReadAllText`, and `WriteAllText`, then prove at least one CRLF, no bare LF, no lone CR, and no BOM. Do not stage or restore fixtures between the CRLF setup and the cell's generator run.
7. Run the generator once under the assigned edition.
8. Apply the complete diagnostic-preserving artifact contract.
9. Include event, edition, version, fixture EOL, artifact path, and push artifact ID in failures.

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

1. Restore `STYLE_GUIDE.md`, `STYLE_GUIDE_RATIONALE.md`, and the generator to BOM-less LF.
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

### 9. Push preparation, validation, approval, and writing

#### Read-only preparation

The push-preparation job must:

- Run only on `push`.
- Use `ubuntu-latest` and `contents: read`.
- Check out and verify `github.sha`.
- Run the generator with `pwsh`.
- Inspect only the four generated paths.
- Reject BOM or CR bytes.
- Determine `has_changes` without treating ordinary differences as command failure.
- Upload exactly the four explicit paths in one immutable archive.
- Never stage, commit, or push.

Use an attempt-qualified name, for example:

```text
style-guide-candidate-${{ github.run_id }}-${{ github.run_attempt }}
```

Configure:

- The approved pinned upload action.
- `archive: true`.
- Four explicit file paths.
- No wildcard or directory upload.
- `overwrite: false`.
- `if-no-files-found: error`.

Expose nonempty outputs:

- `has_changes`
- `candidate_artifact_name`
- `candidate_artifact_id`
- `candidate_artifact_digest`

Source the ID and digest from the upload step's `artifact-id` and `artifact-digest` outputs. The ID is the authoritative selector; the name is diagnostic only.

#### Push Windows matrix

Every push cell must:

- Depend on preparation.
- Download the exact preparation artifact ID.
- Use the approved pinned download action.
- Set `skip-decompress: true`.
- Set `digest-mismatch: error`.
- Run the permanent helper self-test and invoke the shared helper with the propagated digest in the cell's explicit edition-specific step.
- Validate the safely extracted candidate rather than an independently regenerated candidate.
- Never stage, commit, or push.

All four cells must succeed.

#### Read-only approval

The approval job must:

- Depend on preparation and the complete four-cell Windows matrix.
- Use no more than `contents: read`.
- Run only after every dependency succeeds.
- Require nonempty artifact ID and digest.
- Copy exactly:
  - `has_changes`
  - `validated_candidate_artifact_id`
  - `validated_candidate_artifact_digest`
- Never download, regenerate, stage, commit, or push.

#### Write-enabled synchronization

The writer must:

- Run only for push.
- Depend on approval.
- Run only when `has_changes == 'true'`.
- Be the sole `contents: write` job.
- Use `ubuntu-latest`.
- Check out and verify the exact triggering SHA.
- Never regenerate.
- Download only the approved artifact ID.
- Use `skip-decompress: true` and `digest-mismatch: error`.
- Run the permanent helper self-test.
- Invoke the same shared helper with the approved digest.
- Copy and stage only the four approved files.
- Never fetch, merge, rebase, amend, or retry.

Configure the writer with:

```yaml
env:
  TARGET_REF: ${{ github.ref }}
  EXPECTED_SHA: ${{ github.sha }}
```

Keep target validation, remote preflight, copying, staging, commit creation, and push in one complete PowerShell `run:` block. Before copying:

1. Copy `$env:TARGET_REF` to `$strTargetRef` and `$env:EXPECTED_SHA` to `$strExpectedSha`.
2. Require both local values to be nonempty.
3. Require `$strTargetRef` to begin with `refs/heads/`.
4. Require `$strTargetRef` to equal `$env:GITHUB_REF` using ordinal comparison.
5. Require `$strExpectedSha` to equal `$env:GITHUB_SHA` using ordinal, case-insensitive comparison.
6. Resolve the checked-out commit with `git rev-parse --verify "HEAD^{commit}"`, capture `$LASTEXITCODE` immediately, require exactly one complete hexadecimal object ID, and require it to equal `$strExpectedSha`. This establishes the repository's native full object-ID length without accepting an abbreviation or hard-coding one hash algorithm.
7. Run `git ls-remote --exit-code --refs origin $strTargetRef`, capture `$LASTEXITCODE` immediately, and require zero.
8. Parse exactly one `<object-id><TAB><ref>` line.
9. Require the returned ref to equal `$strTargetRef` and the returned object ID to equal `$strExpectedSha`.

Use `$strTargetRef` and `$strExpectedSha` unchanged for the later lease and destination refspec. Do not re-read another ref source.

For each artifact:

1. Reject candidate BOM and CR.
2. Calculate the candidate blob with `git hash-object --no-filters`.
3. Copy to the tracked destination.
4. Recheck destination BOM and CR.
5. Calculate the destination blob.
6. Require candidate and destination blob identity.

Then:

1. Stage exactly the four artifacts.
2. Run `git diff --cached --check`.
3. Require the exact staged path set.
4. Resolve every stage-0 blob with `git rev-parse --verify ":<path>"`.
5. Require every staged blob to equal the candidate blob.
6. Configure the existing bot identity.
7. Commit with the existing `[skip ci]` message.
8. Require the synchronization commit's sole parent to equal `github.sha`.
9. Resolve every committed blob with `git rev-parse --verify "HEAD:<path>"`.
10. Require every committed blob to equal the candidate blob.

Push in that same PowerShell block using:

```powershell
& git push `
    "--force-with-lease=$($strTargetRef):$($strExpectedSha)" `
    origin `
    "HEAD:$($strTargetRef)"
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

Prohibit:

- `--force`
- Leading `+` refspecs
- Bare `--force-with-lease`
- A lease without an expected object
- Bare `git push`
- An implicit destination
- Retry or adaptation to newer history

### 10. Change nothing else

- Keep `#Requires -Version 5.1` on the generator.
- Keep `Get-Content -Raw -Encoding UTF8`.
- Do not rename generator functions or parameters.
- Do not change source Markdown.
- Do not change guide version/date/changelog metadata.
- Do not introduce a PAT or broad secret.
- Do not add another write-enabled job.
- Do not add speculative `.gitattributes` exceptions.
- Do not claim CR-only source compatibility.
- Do not use cache, a permanent test branch, external storage, or independent regeneration for candidate transport.
- Do not weaken or retry the exact-lease push.
- Do not migrate unrelated actions to SHA pins.
- Do not modify any path outside the four affected implementation files.
- Keep all four generated artifacts byte-for-byte unchanged.

## Validation

### Local cross-edition validation

Run from the repository root:

```powershell
$ErrorActionPreference = 'Stop'

$arrArtifactPaths = @(
    'copilot-instructions.md'
    'terraform.instructions.md'
    'STYLE_GUIDE_CHAT.md'
    'STYLE_GUIDE_FULL.md'
)

$arrEditionCommands = @(
    [pscustomobject]@{
        Label = 'PowerShell 7'
        Name = 'pwsh'
    }
    [pscustomobject]@{
        Label = 'Windows PowerShell 5.1'
        Name = 'powershell'
    }
)

$intValidatedEditionCount = 0

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

    & $objResolvedCommand.Path `
        -NoLogo `
        -NoProfile `
        -File './.github/workflows/Generate-StyleGuideArtifacts.ps1'

    $intGeneratorExitCode = $LASTEXITCODE

    if ($intGeneratorExitCode -ne 0) {
        throw (
            "Generator failed under {0} with exit code {1}." -f
            $objEditionCommand.Label,
            $intGeneratorExitCode
        )
    }

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

Each edition is completely verified before another edition can overwrite its outputs. CI remains responsible for mandatory coverage of both editions.

### Verify working-tree scope, stage, renormalize, and verify the staged set

```powershell
$ErrorActionPreference = 'Stop'

$arrExpectedStagedPaths = @(
    '.gitattributes'
    '.github/workflows/Expand-StyleGuideCandidateArtifact.ps1'
    '.github/workflows/Generate-StyleGuideArtifacts.ps1'
    '.github/workflows/build.yml'
) | Sort-Object

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
        "The working-tree path set is not exactly the four implementation " +
        "files. Status: {0}" -f
        ($arrStatusLines -join '; ')
    )
}

git add -- `
    .gitattributes `
    .github/workflows/Expand-StyleGuideCandidateArtifact.ps1
$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw ("git add failed with exit code {0}." -f $intGitExitCode)
}

git add --renormalize .
$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw ("git add --renormalize failed with exit code {0}." -f $intGitExitCode)
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
        "Unexpected staged path set after renormalization; investigate " +
        "before committing: {0}" -f
        ($arrStagedPaths -join ', ')
    )
}

git ls-files --eol
$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw ("git ls-files --eol failed with exit code {0}." -f $intGitExitCode)
}

$arrStagedPaths
```

Use `git check-attr text eol` on representative text files and require `text: auto`, `eol: lf`.

### Pull-request evidence

Confirm:

1. Every pull request targeting `main` runs.
2. Ubuntu verification is read-only and runs the exact helper self-test under PowerShell 7.
3. The Windows matrix displays and completes four distinct edition/EOL cells.
4. Every Windows cell runs the exact helper self-test in the same process as its assigned edition assertion: Desktop 5.1 under `powershell`, Core 7 under `pwsh`.
5. No edition-neutral fixture step invokes the helper.
6. The two LF cells run lone-CR sanitation under their assigned editions.
7. Diagnostic upload runs after ordinary failure but not cancellation.
8. Diagnostic names contain run ID and attempt.
9. No pull-request job has write permission.
10. Push-only jobs skip.
11. All artifact actions use approved SHAs.
12. Every production download is by ID with both integrity inputs.
13. Static review confirms no event path filters and no prohibited push form.

### Controlled temporary-branch evidence

Use a uniquely named temporary branch. Temporarily add only that exact branch to the push branch filter.

1. Commit one stale generated artifact so `has_changes=true`.
2. Push.
3. Confirm one immutable candidate with nonempty ID/digest.
4. Confirm all four Windows cells download the same ID, run the permanent helper self-test (including the digest-mismatch fixture), and invoke the shared helper with the propagated digest.
5. Confirm approval propagates the same ID/digest only after the complete matrix.
6. Confirm only the writer has write permission.
7. Confirm the writer runs the self-test and invokes the same helper.
8. Confirm candidate, destination, index, and commit blob identity.
9. Confirm the synchronization commit's parent is the triggering SHA.
10. Confirm `TARGET_REF` equals `GITHUB_REF`, the same validated local target ref is used for preflight, lease, and refspec, and the exact expected-SHA lease is applied.
11. Confirm only four artifacts are committed.
12. Confirm no recursive workflow run.

#### Propagated-digest rejection drill

1. Use the successful controlled branch.
2. Replace only the expected-digest value supplied to the shared helper with a known-wrong, well-formed 64-hex value.
3. Leave the pinned download action, immutable ID, and real artifact unchanged.
4. Confirm the action's native download succeeds against GitHub's metadata.
5. Confirm the helper fails before opening the ZIP, running manifest validation, or creating the candidate directory.
6. Do not describe this as a native action mismatch.
7. Remove the test-only value afterward.

#### Malformed-transport drill

1. In the temporary branch only, create a prebuilt malformed ZIP.
2. Upload that single ZIP with the approved upload action and `archive: false`. Note that with `archive: false` the file's name becomes the artifact name and the `name` input is ignored; this is harmless because selection is by immutable ID.
3. Propagate its immutable ID and digest as the candidate.
4. Confirm every Windows cell fails inside the shared helper before candidate-directory creation.
5. Confirm approval and the writer skip.
6. Do not require that rejected artifact to reach the writer; the writer uses the same helper and is separately exercised by the permanent self-test suite and the successful write drill.

Also perform:

- Unrelated-file-only trigger check.
- Preflight stale-ref rejection before copying/staging.
- Exact-lease rejection after local commit but before remote update.
- Manual rerun proving a new attempt-qualified artifact name.

Do not attempt to corrupt GitHub's artifact service to induce a native digest mismatch. Record the pinned-source/configuration evidence instead.

Delete the temporary branch and remove every test-only mutation.

### Post-merge evidence

After merge:

1. The `main` push starts the pipeline.
2. Preparation uploads one immutable candidate.
3. All four Windows cells validate it through the self-test and the shared helper under their assigned editions.
4. Preparation reports `has_changes=false`.
5. Approval succeeds.
6. Writer skips.
7. No bot commit is created.
8. Both events retain only the `main` branch filter and no path filters.

This no-drift run proves the four read-only Windows consumers and the expected writer skip. The writer's helper integration and `has_changes=true` path are proved by the controlled temporary-branch synchronization drill and static inspection; none of the skipped writer's steps are described as having executed here.

Observe the first natural unrelated-file-only `main` push; do not create a synthetic `main` commit solely for observation.

## Acceptance criteria

- All four payloads normalize CRLF/lone CR to LF at serialization.
- All writes use resolved paths, `UTF8Encoding($false)`, and `WriteAllText`.
- The existing LF-joined frontmatter construction is unchanged.
- `.gitattributes` contains exactly `* text=auto eol=lf`.
- Renormalization produces no unexplained path.
- Generator and helper versions are correctly recorded.
- Both events cover `main` without path filters.
- Only the writer has `contents: write`.
- Artifact actions use approved full SHAs.
- Preparation declares `archive: true` and exposes one nonempty immutable ID/digest pair.
- Production downloads use immutable IDs, `skip-decompress: true`, and `digest-mismatch: error`.
- Pinned-source/configuration evidence establishes fatal native mismatch behavior without an infeasible live corruption drill.
- The shared helper is the only candidate extraction implementation.
- The helper independently compares the retained ZIP's SHA-256 with the propagated upload digest before opening the archive.
- The helper derives and verifies the trusted checkout root from its fixed tracked location rather than caller input, the working directory, or `GITHUB_WORKSPACE`.
- Separator-aware, OS-appropriate path comparison rejects the checkout while accepting a checkout-sibling prefix as outside.
- Every exact filesystem-entry assertion uses exhaustive enumeration that includes hidden/system entries.
- Existing files, directories, symlinks, reparse points, and dangling links at the candidate leaf are rejected before extraction.
- The candidate leaf is absent until digest and manifest validation succeed, and failures leave it absent.
- Only the four exact entries are accepted.
- Archive metadata is ignored.
- Extracted results are exactly four regular, non-reparse-point files.
- Ubuntu pull-request verification and every pull-request Windows cell run the deterministic fixture suite against the exact tracked helper before merge.
- Every Windows push cell runs the suite and production helper on every push; the synchronization job runs them whenever `has_changes=true` and is skipped when `has_changes=false`.
- Helper invocations and their edition/version assertions occur in the same explicit-shell process; edition-neutral steps never invoke the helper.
- Every rejection fixture satisfies its specified failure phase and leaves the candidate leaf absent; the digest-mismatch fixture fails before the archive is opened.
- Both successful archive fixtures extract exactly four ordinary files; the external-attributes case proves archive metadata is ignored rather than restored.
- Duplicate, case-colliding, nested, traversal, absolute, drive-qualified, directory, empty-name, missing, extra, file/directory-collision, hidden-extra-download-entry, existing/dangling-leaf, invalid-ZIP, digest-mismatch, and metadata-ignored cases are covered.
- An end-to-end malformed raw ZIP is rejected before extraction.
- The Windows topology is an actual four-cell edition × EOL matrix with `fail-fast: false`.
- Each cell runs only its assigned edition and EOL.
- The two LF cells run lone-CR sanitation under their assigned editions.
- Approval runs only after the complete matrix.
- The writer downloads only the approved candidate.
- Candidate, destination, index, and commit blobs match.
- The synchronization commit is a single child of `github.sha`.
- The writer validates one canonical `TARGET_REF` against `GITHUB_REF`, proves `EXPECTED_SHA` is the checkout's complete repository-native commit object ID, uses both values unchanged for remote preflight and `HEAD:<full-ref>`, and applies the exact expected-SHA lease.
- No prohibited force or retry behavior exists.
- Local validation verifies each available edition immediately after that edition runs, and CI supplies mandatory coverage for both editions.
- Before staging, the complete changed-path set is exactly the four implementation files.
- After staging and renormalization, the cached path set is exactly those same four files.
- LF, CRLF, and lone-CR sanitation evidence passes.
- Controlled synchronization, propagated-digest rejection, malformed-transport, unrelated-trigger, stale-preflight, and exact-lease drills pass without touching `main`.
- Test-only mutations are removed.
- Exactly four implementation files change.
- Generated artifacts remain byte-for-byte unchanged.

## References

- [PowerShell character encoding](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_character_encoding)
- [Microsoft Learn: `about_Operator_Precedence`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_operator_precedence)
- [Microsoft Learn: `about_Preference_Variables`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_preference_variables)
- [Microsoft Learn: `about_Environment_Variables`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_environment_variables)
- [Microsoft Learn: `about_Comment_Based_Help`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_comment_based_help)
- [Microsoft Learn: `Get-FileHash`](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/get-filehash)
- [Microsoft Learn: `Get-ChildItem`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/get-childitem)
- [`.NET UTF8Encoding`](https://learn.microsoft.com/dotnet/api/system.text.utf8encoding.-ctor)
- [`File.WriteAllText`](https://learn.microsoft.com/dotnet/api/system.io.file.writealltext)
- [`File.ReadAllBytes`](https://learn.microsoft.com/dotnet/api/system.io.file.readallbytes)
- [`Directory.EnumerateFileSystemEntries`](https://learn.microsoft.com/dotnet/api/system.io.directory.enumeratefilesystementries)
- [`.NET FileAttributes`](https://learn.microsoft.com/dotnet/api/system.io.fileattributes)
- [`Path.GetFullPath`](https://learn.microsoft.com/dotnet/api/system.io.path.getfullpath)
- [`FileMode`](https://learn.microsoft.com/dotnet/api/system.io.filemode)
- [`ZipArchive.Entries`](https://learn.microsoft.com/dotnet/api/system.io.compression.ziparchive.entries)
- [`ZipArchive.CreateEntry`](https://learn.microsoft.com/dotnet/api/system.io.compression.ziparchive.createentry)
- [`ZipArchiveEntry.Open`](https://learn.microsoft.com/dotnet/api/system.io.compression.ziparchiveentry.open)
- [`ZipArchiveEntry.FullName`](https://learn.microsoft.com/dotnet/api/system.io.compression.ziparchiveentry.fullname)
- [`ZipArchiveEntry.ExternalAttributes`](https://learn.microsoft.com/dotnet/api/system.io.compression.ziparchiveentry.externalattributes)
- [Git attributes](https://git-scm.com/docs/gitattributes)
- [Git `status`](https://git-scm.com/docs/git-status)
- [Git `add --renormalize`](https://git-scm.com/docs/git-add#Documentation/git-add.txt---renormalize)
- [Git `hash-object`](https://git-scm.com/docs/git-hash-object)
- [Git `rev-parse`](https://git-scm.com/docs/git-rev-parse)
- [Git `ls-remote`](https://git-scm.com/docs/git-ls-remote)
- [Git push and exact leases](https://git-scm.com/docs/git-push)
- [GitHub Actions workflow syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax)
- [GitHub Actions variables](https://docs.github.com/en/actions/reference/workflows-and-actions/variables)
- [GitHub Actions job conditions](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/control-jobs-with-conditions)
- [GitHub Actions `needs`](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#jobsjob_idneeds)
- [GitHub Docs: Evaluate expressions in workflows and actions](https://docs.github.com/en/actions/reference/workflows-and-actions/expressions)
- [GitHub secure-use reference](https://docs.github.com/en/actions/reference/security/secure-use)
- [`upload-artifact` v7.0.1 README](https://github.com/actions/upload-artifact/blob/v7.0.1/README.md)
- [`download-artifact` v8.0.1 inputs](https://github.com/actions/download-artifact/blob/v8.0.1/action.yml)
- [`download-artifact` v8.0.1 implementation](https://github.com/actions/download-artifact/blob/v8.0.1/src/download-artifact.ts)
- [GitHub `GITHUB_TOKEN` trigger behavior](https://docs.github.com/en/actions/concepts/security/github_token)
- [PSStyleGuide generator](https://github.com/franklesniak/PSStyleGuide/blob/main/.github/workflows/Generate-StyleGuideArtifacts.ps1)
- [PSStyleGuide `.gitattributes`](https://github.com/franklesniak/PSStyleGuide/blob/main/.gitattributes)
- [PSStyleGuide Function and Script Versioning](https://github.com/franklesniak/PSStyleGuide/blob/main/STYLE_GUIDE.md#function-and-script-versioning)
- [copilot-repo-template#851](https://github.com/franklesniak/copilot-repo-template/issues/851)
- [copilot-repo-template#852](https://github.com/franklesniak/copilot-repo-template/pull/852)
