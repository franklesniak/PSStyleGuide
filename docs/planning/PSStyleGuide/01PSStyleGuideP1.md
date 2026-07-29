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
- Pin checkout, artifact upload, and artifact download actions to approved full commit SHAs.
- Prepare one immutable push candidate in a read-only job.
- Download that candidate by immutable artifact ID.
- Require native fail-closed digest validation and pass preparation's propagated upload digest to the shared archive-validation helper, which independently compares it with the retained ZIP's SHA-256 before opening the archive.
- Use one shared, versioned PowerShell helper for candidate digest verification, archive validation, and extraction in every push consumer.
- Define the deterministic fixture suite once in a tracked, versioned PowerShell harness.
- Run that harness against the exact helper before merge on Ubuntu PowerShell 7, Windows PowerShell 5.1, and Windows PowerShell 7.
- Run the same harness against that exact helper in every push consumer before each production invocation.
- Validate the candidate in an actual four-cell edition × fixture-EOL Windows matrix.
- Run the lone-CR sanitation probe once under each edition.
- Approve the candidate only after the complete matrix succeeds.
- Give `contents: write` only to the final synchronization job.
- Prove candidate, destination, index, and committed-blob identity.
- Push with an explicit destination refspec and exact expected-SHA `--force-with-lease`.
- Check every native-command exit code immediately.
- Preserve useful diagnostic artifacts after ordinary pull-request failures.
- Require local validation to verify each available PowerShell edition before another edition can overwrite its output.
- Refuse to stage from a working tree containing any path other than the five implementation files.

This issue is a prerequisite for **Make the non-compliant blank-line example visibly distinct**.

## Affected files

- `.github/workflows/Generate-StyleGuideArtifacts.ps1`
- `.github/workflows/Expand-StyleGuideCandidateArtifact.ps1` — add.
- `.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1` — add.
- `.github/workflows/build.yml`
- `.github/workflows/markdownlint.yml` — change only the checkout reference unless compatibility validation proves another change is required.

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

The helper's filename, parameter interface, validation order, and diagnostics are intentionally aligned with the equivalent helper in the TerraformStyleGuide repository; the four expected manifest names are the intentional repository-specific difference. This alignment is a design objective, not a cross-repository dependency.

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

The parameter names and semantics are intentionally part of the P1/T1 alignment contract. Do not replace them with ambient current-directory state, `git rev-parse`, `GITHUB_WORKSPACE`, GitHub environment-variable discovery inside the helper, a hashtable, or a configuration file.

#### Explicit path and diagnostic context

The helper must:

1. Require `CheckoutRoot` and `TrustedTemporaryRoot` to each resolve to exactly one existing filesystem-provider directory.
2. Require rooted native or filesystem-provider-qualified absolute paths. Reject wildcards, relative paths, non-filesystem providers, nonexistent roots, files, and reparse/symbolic-link roots.
3. Require the trusted temporary root to be outside and not equal to the checkout root.
4. Require the download directory and candidate directory to be strict descendants of the trusted temporary root.
5. Require neither candidate path to equal, contain, or be contained by the checkout root.
6. Normalize directory roots with exactly one trailing platform directory separator before descendant comparison.
7. Use ordinal case-insensitive path comparison on Windows and ordinal case-sensitive path comparison on Linux. Never use culture-sensitive comparison or a raw, unterminated string prefix.
8. Resolve the existing download directory through the filesystem provider.
9. Require the candidate directory not to exist; resolve and validate its existing parent before deriving the unresolved leaf path.
10. Walk every existing component between the trusted temporary root and the download directory or candidate parent. Reject reparse/symbolic-link components introduced below the trusted root.
11. Repeat the relevant containment and indirection checks immediately before opening the archive and immediately before creating the candidate directory.
12. Treat `ArtifactId`, `RunId`, and `RunAttempt` only as caller-supplied diagnostic labels. Reject an explicitly supplied empty value; represent an omitted value as unavailable and never invent one.

Diagnostics must include all supplied labels, normalized roots, archive path, expected digest, actual digest when computed, and the failing validation phase.

#### Download-directory contract

The helper must require:

- The download directory exists within the trusted temporary root and outside the tracked checkout.
- It contains exactly one filesystem entry.
- That entry is a regular, non-reparse-point file.
- The file can be opened read-only as a ZIP archive.

Do not require a `.zip` filename extension; validate the archive by opening it. The retained file's name comes from the download's Content-Disposition header and may be the literal fallback name `artifact`.

#### Expected-digest contract

Before opening the archive, the helper must:

1. Require the expected digest to match `^[0-9A-Fa-f]{64}$`.
2. Calculate the retained ZIP's SHA-256 with `Get-FileHash -Algorithm SHA256`.
3. Compare the actual and expected digests using ordinal, case-insensitive equality.
4. Fail before opening the archive if they differ.
5. Record the caller-supplied artifact ID, expected digest, actual digest, caller-supplied run ID, caller-supplied run attempt, and archive path in diagnostics; label omitted optional values as unavailable.

The expected value is always the propagated `artifact-digest` output of the pinned upload action, which is a bare hexadecimal SHA-256 string. Never supply the `sha256:`-prefixed form that appears in download-action logs and artifact API metadata.

#### Manifest contract

Before creating the candidate destination directory, require exactly these four ordinal, root-level, non-directory entry names:

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

The caller may create a protected temporary parent directory, but the candidate leaf must not exist.

The helper must:

1. Resolve the candidate leaf path without creating it.
2. Assert that it is a strict descendant of the trusted temporary root, outside the checkout, and does not exist.
3. Validate the digest, the complete archive, and the manifest.
4. Reconfirm that the leaf remains absent.
5. Create the leaf exactly once.
6. Never delete and recreate it.
7. Refuse to reuse an existing leaf.

A digest or manifest failure must leave the candidate leaf nonexistent.

#### Extraction contract

For each permitted entry:

1. Resolve the destination with `GetFullPath`.
2. Prove it is an immediate child of the candidate root.
3. Open the destination with `FileMode.CreateNew`, write access, and no sharing.
4. Copy only the entry stream.
5. Dispose all streams and archives deterministically.

Do not restore symlink information, Unix file types or modes, Windows attributes, timestamps, or any other ZIP metadata. ZIP external attributes are not a rejection criterion; safety comes from creating fresh regular files in a fresh directory.

After extraction:

- Enumerate the candidate directory.
- Require exactly the four expected root-level paths.
- Require every path to be a regular, non-reparse-point file.
- Reject every BOM and CR byte.
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
- Create all fixture state under a unique runner-temporary root.
- Invoke the production helper as a child script through the helper's documented public parameters.
- Never copy or reimplement digest, path-containment, archive-validation, or extraction logic.
- Change working directory during at least one valid case to prove that helper behavior does not depend on ambient location.
- Return nonzero for any unexpected helper outcome, filesystem state, or cleanup failure.
- Clean the complete fixture root in `finally`.

The harness must invoke the production helper against:

- one valid exact archive with its correct digest;
- a valid exact archive with a deliberately altered, well-formed 64-hex expected digest;
- missing entry;
- extra entry;
- exact duplicate;
- case-only collision;
- forward-slash nested path;
- backslash nested path;
- forward and backward traversal;
- leading-slash and leading-backslash absolute names;
- drive-qualified name;
- directory entry;
- file/directory collision;
- empty central-directory name using a reviewed fixed raw fixture;
- invalid or truncated ZIP;
- an entry carrying symlink-like external attributes that must still extract as an ordinary regular file, constructed with `ZipArchiveEntry.ExternalAttributes` where practical or a reviewed raw fixture otherwise.
- a checkout root equal to or containing the trusted temporary root;
- a download directory or candidate directory outside the trusted temporary root;
- a sibling-prefix path such as `repository-other`;
- a Windows case-variant containment path;
- rejected relative and non-filesystem-provider paths plus an accepted filesystem-provider-qualified absolute path;
- a reparse/symbolic-link component where the platform and permissions permit construction; and
- an explicitly supplied empty optional diagnostic label.

`ZipArchive.CreateEntry` may be used for constructible cases. Because it rejects an empty name at creation time, use a deterministic reviewed raw fixture for that case.

For each invalid fixture:

- Require the helper to fail.
- Require the destination directory to remain nonexistent.
- Require named sentinels outside the intended destination to remain absent or unchanged.
- Require the digest-mismatch fixture to fail before the archive is opened.
- Include the case and offending entry in diagnostics when available.

For the valid fixture:

- Require successful extraction.
- Require exactly the four expected root-level regular files.

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

As of 2026-07-28, use:

```yaml
uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
```

for every checkout step in both `.github/workflows/build.yml` and `.github/workflows/markdownlint.yml`;

```yaml
uses: actions/upload-artifact@043fb46d1a93c77aae656e7c1c64a875d1fc6a0a # v7.0.1
```

and:

```yaml
uses: actions/download-artifact@3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c # v8.0.1
```

Immediately before implementation:

1. Verify each checkout, upload, and download SHA in the official action repository.
2. Confirm it matches the adjacent release comment.
3. Check for a required newer security release.
4. If updated, change the full SHA, release comment, and evidence together.
5. Do not use a branch, major-version tag, or patch-version tag.
6. Do not choose a download release lacking `artifact-ids`, `digest-mismatch`, or `skip-decompress`.
7. Confirm the selected checkout release declares `runs.using: node24`.

Checkout v6 stores persisted credentials beneath `RUNNER_TEMP` instead of `.git/config`; the official v6.0.2 documentation states that ordinary authenticated Git commands continue to work without workflow changes. Neither PSStyleGuide workflow invokes authenticated Git from a Docker container action. Prove the final synchronization job's authenticated push in the controlled drill.

Changing the two current checkout references is a targeted runtime and immutability correction. Do not add Dependabot or organization-policy configuration and do not migrate unrelated actions in this issue.

#### Pull-request Ubuntu verification

The Ubuntu pull-request job must:

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

The preparation job must:

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

Every push consumer—the four Windows push cells and the synchronization job—must:

1. Receive the candidate ID and propagated upload digest.
2. Create one unique trusted temporary root outside the checkout, then create the download directory beneath it.
3. Reserve a separate, initially nonexistent candidate-directory path beneath the same trusted temporary root.
4. Download only by artifact ID:

   ```yaml
   - name: Download synchronization candidate archive
     uses: actions/download-artifact@3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c # v8.0.1
     with:
       artifact-ids: ${{ <validated artifact ID> }}
       path: ${{ runner.temp }}/style-guide-candidate-download
       skip-decompress: true
       digest-mismatch: error
   ```

5. Run the tracked permanent self-test harness against the exact tracked helper.
6. Only after the self-test succeeds, invoke the same helper on the production download directory, passing the explicit checkout root, trusted temporary root, reserved candidate path, propagated upload digest, artifact ID, run ID, and run attempt.

The helper performs the digest, manifest, lifecycle, and extraction contracts defined in the shared-helper section above.

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

Add one non-matrix push-only approval job that:

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

The synchronization job must:

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

Before copying, require `GITHUB_REF` to be a complete `refs/heads/` branch ref and run:

```powershell
git ls-remote --exit-code --refs origin $env:GITHUB_REF
```

Require:

- exit code 0;
- exactly one record;
- exactly two tab-separated fields;
- an exact ref-name match;
- remote object ID equal to `github.sha`.

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
9. Require exactly one parent equal to `github.sha`.
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
    "--force-with-lease=$($env:TARGET_REF):$($env:EXPECTED_SHA)" `
    origin `
    "HEAD:$($env:TARGET_REF)"

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
- In `.github/workflows/markdownlint.yml`, change only the checkout reference unless checkout-v6 compatibility validation proves another change is required.
- Do not pin or migrate any action other than the two checkout occurrences and the artifact actions named in this issue.
- Do not add Dependabot or organization-policy configuration.
- Do not make this issue depend on TerraformStyleGuide changes.

## Validation

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
        -File './.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1' `
        -HelperPath './.github/workflows/Expand-StyleGuideCandidateArtifact.ps1'

    $intHarnessExitCode = $LASTEXITCODE

    if ($intHarnessExitCode -ne 0) {
        throw (
            "Helper self-test failed under {0} with exit code {1}." -f
            $objEditionCommand.Label,
            $intHarnessExitCode
        )
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

Each edition's helper suite and generated outputs are completely verified before another edition can overwrite the outputs. CI remains responsible for mandatory coverage of both editions and Ubuntu.

### Verify working-tree scope, stage, and verify the staged set

```powershell
$ErrorActionPreference = 'Stop'

$arrExpectedStagedPaths = @(
    '.github/workflows/Generate-StyleGuideArtifacts.ps1'
    '.github/workflows/Expand-StyleGuideCandidateArtifact.ps1'
    '.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1'
    '.github/workflows/build.yml'
    '.github/workflows/markdownlint.yml'
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
        "The working-tree path set is not exactly the five implementation " +
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
9. Static inspection confirms full-SHA checkout and artifact-action pins and the exact lease form.
10. The separate Markdown lint workflow checks out successfully with the same pinned checkout release and completes its existing lint commands.

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
   - run the tracked permanent helper harness, including the digest-mismatch and path-envelope fixtures;
   - invoke the shared helper with explicit checkout/trusted roots and caller-owned diagnostic context, which independently rehashes the retained ZIP against the propagated digest and validates the manifest before candidate-directory creation;
   - safely extract and validate the exact candidate.
6. Confirm approval runs only after all four cells and propagates the same ID/digest.
7. Confirm only synchronization has `contents: write`.
8. Confirm synchronization repeats the tracked harness and explicit helper-interface contracts.
9. Confirm candidate, destination, index, and committed blob IDs match.
10. Confirm the commit's only parent is the triggering SHA.
11. Confirm the exact lease and explicit `HEAD:<full-ref>` refspec.
12. Confirm the bot commit contains only the four artifacts.
13. Confirm the `GITHUB_TOKEN` update creates no recursive workflow run.
14. Confirm a manual rerun uses a new attempt-qualified artifact name and does not overwrite the prior artifact.
15. Confirm checkout v6's persisted credentials permit the production-form authenticated push without storing credentials in `.git/config`.

#### Propagated-digest rejection drill

1. Use the successful controlled branch.
2. Replace only the expected-digest value supplied to the shared helper with a known-wrong, well-formed 64-hex value.
3. Leave the pinned download action, immutable ID, and real artifact unchanged.
4. Confirm the action's native download succeeds against GitHub's metadata.
5. Confirm the helper fails before opening the ZIP, running manifest validation, or creating the candidate directory.
6. Do not describe this as a native action mismatch.
7. Remove the test-only value afterward.

Static inspection of the pinned action contract and source supplies evidence that native v8 uses the artifact metadata digest internally and that `digest-mismatch: error` is fail-closed.

#### Unrelated-file-only trigger check

1. Base a new temporary-branch commit on the successful synchronization commit.
2. Change only a tracked unrelated path.
3. Push normally.
4. Confirm the push workflow runs.
5. Confirm preparation reports `has_changes=false`.
6. Confirm approval succeeds and synchronization skips.

#### Preflight stale-ref rejection drill

1. Ensure a candidate difference exists.
2. Supply a known nonmatching value only to the preliminary remote-ref comparison.
3. Confirm failure before copying, staging, committing, or pushing.
4. Confirm no retry.

#### Exact-lease rejection drill

1. Start with the remote validation branch at the real triggering SHA.
2. Let checkout, preparation, the four-cell matrix, approval, preliminary remote guard, copying, staging, commit creation, and blob proofs use the real SHA.
3. Replace only the lease expectation with a known nonmatching complete object ID.
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
5. Confirm the tracked helper harness passes in every consumer.
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
- Every checkout in `build.yml` and `markdownlint.yml` uses the same approved Node 24 full commit SHA with a matching comment.
- Artifact uploads and downloads use approved full commit SHAs with matching comments.
- Preparation declares `archive: true` and exposes one nonempty immutable ID/digest pair.
- Every push consumer downloads only by that ID.
- Native downloads set `digest-mismatch: error` and `skip-decompress: true`.
- The shared helper is the only candidate extraction implementation.
- The helper receives explicit checkout and trusted temporary roots, requires both candidate paths beneath that trusted root and outside the checkout, and does not infer security context from Git or GitHub environment variables.
- The helper applies separator-safe platform path comparisons, rejects reparse/symlink path components beneath the trusted root, and receives optional artifact/run labels only from callers.
- The helper independently compares the retained ZIP's SHA-256 with the propagated upload digest before opening the archive.
- The candidate leaf is absent until digest and manifest validation succeed, and failures leave it absent.
- One tracked, versioned harness owns the deterministic fixture suite and invokes the exact tracked helper through its public interface.
- Pull-request verification runs that harness under Ubuntu PowerShell 7 and in the two Windows LF cells under Windows PowerShell 5.1 and PowerShell 7.
- Every push consumer runs that same tracked harness against the exact tracked helper on every run.
- Every invalid fixture fails before candidate-directory creation or extraction, and the digest-mismatch fixture fails before the archive is opened.
- Duplicate, case-colliding, nested, traversal, absolute, drive-qualified, directory, empty-name, missing, extra, file/directory-collision, invalid-ZIP, digest-mismatch, metadata-ignored, outside-trusted-root, checkout-overlap, sibling-prefix, case-variant, relative/non-filesystem-provider rejection, filesystem-provider-qualified acceptance, reparse/symlink-component, and empty-diagnostic cases are covered.
- Only the exact four entries are extracted, as new regular, non-reparse-point files.
- The Windows topology is an actual four-cell edition × EOL matrix with `fail-fast: false`.
- Each cell runs only its assigned edition and EOL.
- The two LF cells run lone-CR sanitation under their assigned editions.
- Approval runs only after all four push cells succeed.
- The sole write job downloads only the approved ID.
- Candidate, destination, stage-0 index, and committed blob IDs match.
- The synchronization commit has exactly one parent equal to `github.sha`.
- The final push uses `HEAD:<target-ref>` and an exact expected-SHA lease.
- No unconditional force form, implicit destination, adaptation, or retry exists.
- Every native command has an immediate exit-code check.
- Every custom workflow and local PowerShell block begins with `$ErrorActionPreference = 'Stop'`.
- Local validation verifies each available edition immediately after that edition runs.
- CI supplies mandatory coverage for both editions.
- Before local staging, the complete changed-path set is exactly the generator, helper, self-test harness, build workflow, and Markdown lint workflow.
- After staging, the cached path set is exactly those same five files.
- Controlled synchronization, propagated-digest rejection, unrelated-trigger, stale-preflight, and exact-lease drills pass without touching `main`.
- No generated artifact, source guide, `.gitattributes`, or governance file changes in the implementing commit; `markdownlint.yml` changes only at its checkout reference unless compatibility validation proves another change is required.

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
- [Microsoft Learn: `Path.GetRelativePath` platform comparison behavior](https://learn.microsoft.com/dotnet/api/system.io.path.getrelativepath)
- [Microsoft Learn: `DirectoryInfo`](https://learn.microsoft.com/dotnet/api/system.io.directoryinfo)
- [Microsoft Learn: `FileSystemInfo.Attributes`](https://learn.microsoft.com/dotnet/api/system.io.filesysteminfo.attributes)
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
- [GitHub Docs: Evaluate expressions in workflows and actions](https://docs.github.com/en/actions/reference/workflows-and-actions/expressions)
- [GitHub Docs: Secure use reference](https://docs.github.com/en/actions/reference/security/secure-use)
- [GitHub Docs: `GITHUB_TOKEN` trigger behavior](https://docs.github.com/en/actions/concepts/security/github_token)
- [GitHub Changelog: Deprecation of Node 20 on GitHub Actions runners](https://github.blog/changelog/2025-09-19-deprecation-of-node-20-on-github-actions-runners/)
- [GitHub: `actions/checkout` v6.0.2 exact metadata](https://raw.githubusercontent.com/actions/checkout/de0fac2e4500dabe0009e67214ff5f5447ce83dd/action.yml)
- [GitHub: `actions/checkout` v6.0.2 exact README](https://raw.githubusercontent.com/actions/checkout/de0fac2e4500dabe0009e67214ff5f5447ce83dd/README.md)
- [GitHub: `actions/checkout` v6.0.2 release](https://github.com/actions/checkout/releases/tag/v6.0.2)
- [GitHub: `actions/upload-artifact` v7.0.1 exact metadata](https://raw.githubusercontent.com/actions/upload-artifact/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a/action.yml)
- [GitHub: `actions/upload-artifact` v7.0.1 exact README](https://raw.githubusercontent.com/actions/upload-artifact/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a/README.md)
- [GitHub: `upload-artifact` v7.0.1](https://github.com/actions/upload-artifact/releases/tag/v7.0.1)
- [GitHub: `actions/download-artifact` v8.0.1 exact metadata](https://raw.githubusercontent.com/actions/download-artifact/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/action.yml)
- [GitHub: `actions/download-artifact` v8.0.1 exact README](https://raw.githubusercontent.com/actions/download-artifact/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/README.md)
- [GitHub: `actions/download-artifact` v8.0.1 exact implementation](https://raw.githubusercontent.com/actions/download-artifact/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/src/download-artifact.ts)
- [GitHub: `download-artifact` v8.0.1](https://github.com/actions/download-artifact/releases/tag/v8.0.1)
- [franklesniak/copilot-repo-template#851](https://github.com/franklesniak/copilot-repo-template/issues/851)
- [franklesniak/copilot-repo-template#852](https://github.com/franklesniak/copilot-repo-template/pull/852)
