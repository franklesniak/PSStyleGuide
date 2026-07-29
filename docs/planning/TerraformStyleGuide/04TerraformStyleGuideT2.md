# Make state-version discovery and recovery examples copy-safe with guarded identifiers

> **Dependency:** Implement only after "Make artifact generation byte-deterministic and standardize repository text checkouts on LF" has merged. Record the GitHub blocked-by relationship using the actual prerequisite issue.

## Summary

The S3 recovery example currently combines discovery and retrieval and uses an unquoted `<VERSION_ID>` placeholder. In a POSIX shell, angle brackets are redirection syntax.

Make the state-version examples copy-safe by:

- Separating discovery from recovery.
- Requiring deliberate version selection.
- Guarding and quoting every selected identifier.
- Filtering exact state objects.
- Requiring protected, absolute recovery destinations.
- Mechanically refusing to overwrite an existing recovery file.
- Applying restrictive file-creation permissions.
- Documenting provider-specific versioning applicability.
- Replacing `gsutil` with `gcloud storage`.
- Correcting and paginating the HCP Terraform state-version request.
- Keeping the HCP bearer token out of process arguments.
- Writing secret-bearing HCP responses to fresh protected files.
- Treating recovered state and Archivist URLs as secrets.

Keep `STYLE_GUIDE.md` concise and operational. Put shell mechanics, provider limitations, AWS bucket-class reconciliation, pagination details, and extended security rationale in `STYLE_GUIDE_RATIONALE.md`.

The guidance must remain repository-generic.

## Prerequisite verification

At implementation start, confirm the prerequisite issue established:

- CRLF/lone-CR canonicalization to LF.
- Resolved BOM-less UTF-8 writes.
- `#Requires -Version 5.1`.
- `* text=auto eol=lf`.
- A versioned generator and a versioned shared archive-validation helper (`.github/workflows/Expand-StyleGuideCandidateArtifact.ps1`).
- Local cross-edition validation that verifies each available edition's output before another edition runs.
- Unfiltered `main` coverage for pull requests and pushes.
- Approved full-SHA artifact-action pins.
- Immutable candidate ID/digest propagation from a read-only preparation job that declares `archive: true`.
- Download by ID with `skip-decompress: true` and fatal native digest handling.
- The shared helper as the only candidate extraction implementation, independently comparing the retained ZIP's SHA-256 with the propagated upload digest before opening the archive, and validating the full manifest before creating the candidate directory.
- The deterministic fixture self-test suite, including the digest-mismatch fixture, running against that exact helper in the Ubuntu pull-request verification job and in all four Windows pull-request cells before merge.
- The same exact helper self-test running in all four Windows push cells on every push run, and in the synchronization writer whenever that conditional writer executes.
- Each Windows helper invocation bound to the cell's assigned edition by a mutually exclusive step whose explicit shell is `powershell` for Desktop 5.1 or `pwsh` for Core 7, with the edition asserted in the same process immediately before the suite.
- A Windows topology that is an actual four-cell edition × fixture-EOL cross-product, with the two LF cells supplying lone-CR sanitation coverage.
- Read-only approval after the complete matrix.
- A sole exact-lease writer.
- The four prerequisite implementation paths as the complete pre-stage working-tree set and complete staged set.
- Passing LF, CRLF, lone-CR, propagated-digest rejection, malformed-transport, stale-ref, and lease evidence.

## Affected files

Source files:

- `STYLE_GUIDE.md`
- `STYLE_GUIDE_RATIONALE.md`

Generated files:

- `copilot-instructions.md`
- `terraform.instructions.md`
- `STYLE_GUIDE_CHAT.md`
- `STYLE_GUIDE_FULL.md`

Do not hand-edit generated files.

## Requested changes

### 1. Keep source roles distinct

In `STYLE_GUIDE.md`, include:

- Operational prerequisites.
- Provider applicability.
- Separate discovery and recovery.
- Deliberate selection.
- Guarded commands.
- No-overwrite behavior.
- Concise AWS KMS and directory-bucket guidance.
- Protected destinations.
- Sensitive-state handling.

In `STYLE_GUIDE_RATIONALE.md`, explain:

- Shell behavior.
- Guard limitations.
- Provider versioning limitations.
- AWS documentation reconciliation.
- Destination and overwrite mechanics.
- Restrictive creation permissions.
- HCP token/response handling.
- Pagination.
- Security rationale.

### 2. Define the common recovery-destination contract

For AWS, Azure, and GCS:

- Require Bash or another POSIX-compatible shell.
- Require `RECOVERY_PATH` to identify a new file.
- Require POSIX absolute-path syntax.
- Require a protected parent directory outside every version-controlled working tree and outside shared world-readable temporary locations.
- Require a fresh path for every recovery.
- Set `umask 077` in a subshell.
- Refuse to run if the final destination is any existing filesystem entry or a symbolic link, including a dangling symbolic link, by checking `[ -e "$RECOVERY_PATH" ] || [ -L "$RECOVERY_PATH" ]`.
- Keep the `${RECOVERY_PATH:?...}` guard directly in the provider command.
- Explain that parameter expansion validates presence, while the surrounding checks validate absolute syntax and nonexistence.
- Explain that POSIX `test -e` follows symbolic links and can be false for a dangling final link, while `test -L` recognizes the link itself; both tests are therefore required.
- Explain that "outside version control" remains a deliberate operator decision; the example does not attempt to discover every enclosing repository or resolve every symlink topology.
- Explain that the AWS preflight is not an atomic filesystem lock. The protected parent and lack of competing writers are part of the model.
- Use provider-native no-overwrite controls where available.

Because recovery runs inside a subshell, `exit 1` exits only that recovery block rather than an interactive parent shell.

### 3. Harden S3 discovery and recovery

State that:

- AWS CLI and configured credentials are required.
- Discovery requires `s3:ListBucketVersions`.
- Retrieval of a selected version requires `s3:GetObjectVersion`.
- The procedure applies to a versioning-capable general-purpose bucket.
- Directory buckets do not support S3 Versioning or `ListObjectVersions`.
- Directory-bucket `GetObject` accepts only the `null` version ID, so directory buckets are outside this historical recovery procedure.
- SSE-S3 requires no KMS authorization.
- General-purpose SSE-KMS and DSSE-KMS retrieval requires applicable `kms:Decrypt` authorization.
- `kms:GenerateDataKey` appears on general-purpose upload/destination paths, not this historical download path.
- Directory-bucket SSE-KMS guidance requires both `kms:GenerateDataKey` and `kms:Decrypt` for ordinary operations, but that is not a directory-bucket version-recovery path.
- Effective authorization may involve identity policies, key policies, grants, encryption mode, and account topology.
- SSE-C uses a different header-based process and is outside this example.
- Current AWS sources must be rechecked immediately before implementation.

Use exact-key discovery:

```bash
aws s3api list-object-versions \
  --bucket acme-corp-terraform-state \
  --prefix environments/prod/terraform.tfstate \
  --query "Versions[?Key=='environments/prod/terraform.tfstate'].{Key:Key,VersionId:VersionId,IsLatest:IsLatest,LastModified:LastModified,Size:Size}" \
  --output table
```

Require the operator to inspect the exact key and metadata and deliberately set `VERSION_ID`.

Use:

```bash
(
  umask 077

  case "${RECOVERY_PATH:?Set RECOVERY_PATH to a new absolute path in a protected directory outside version control.}" in
    /*)
      ;;
    *)
      printf '%s\n' 'RECOVERY_PATH must be an absolute POSIX path.' >&2
      exit 1
      ;;
  esac

  if [ -e "$RECOVERY_PATH" ] || [ -L "$RECOVERY_PATH" ]; then
    printf 'Refusing to overwrite or follow an existing recovery destination: %s\n' \
      "$RECOVERY_PATH" >&2
    exit 1
  fi

  aws s3api get-object \
    --bucket acme-corp-terraform-state \
    --key environments/prod/terraform.tfstate \
    --version-id "${VERSION_ID:?Set VERSION_ID to the exact S3 VersionId selected for recovery.}" \
    "${RECOVERY_PATH:?Set RECOVERY_PATH to a new absolute path in a protected directory outside version control.}"
)
```

The AWS CLI has no provider-native no-clobber option for `s3api get-object`, so the protected parent, fresh path, and immediate preflight are mandatory.

### 4. Explain shell and AWS behavior in the rationale

Explain:

- Unquoted angle brackets are redirection operators.
- `${parameter:?word}` is POSIX parameter expansion.
- It fails for unset or empty values.
- It prevents the containing command from running.
- Bash leaves the interactive parent shell open.
- The guard does not verify that an identifier is the intended version.

Add a dated AWS reconciliation:

1. `ListObjectVersions` is unsupported for directory buckets.
2. S3 Versioning is unsupported there, and `GetObject` accepts only `null`.
3. General-purpose permission tables identify `kms:Decrypt` for KMS-encrypted retrieval.
4. General-purpose SSE-KMS guidance identifies `kms:Decrypt` for downloads and `kms:GenerateDataKey` for uploads.
5. Directory-bucket `GetObject` and dedicated directory-bucket KMS guidance require both actions for ordinary SSE-KMS access.
6. The pages describe different bucket classes and operations.
7. The general-purpose example therefore follows general-purpose retrieval guidance.
8. No directory-bucket version-recovery command may be added.

Explain destination handling:

- State can contain plaintext secrets.
- Relative paths inherit the current directory.
- Shared temporary directories can expose state.
- A restrictive `umask` limits newly created permissions.
- The preflight and provider-native options refuse existing destinations.
- The operator still must choose the correct protected location.

### 5. Harden Azure Blob Storage recovery

Require:

- Azure CLI and authentication.
- Applicable blob-read permission.
- `Storage Blob Data Reader` as one suitable predefined role.
- A POSIX-compatible shell.
- Blob Versioning enabled on a supported account.
- A statement that hierarchical-namespace accounts do not currently support Blob Versioning and are outside this version-ID procedure.

Use discovery:

```bash
az storage blob list \
  --account-name stacmeterraform \
  --container-name tfstate \
  --include v \
  --prefix environments/prod/terraform.tfstate \
  --query "[?name=='environments/prod/terraform.tfstate'].{Name:name,VersionId:versionId,IsCurrent:isCurrentVersion}" \
  --auth-mode login \
  --output table
```

Require deliberate selection of `AZURE_VERSION_ID`.

Use:

```bash
(
  umask 077

  case "${RECOVERY_PATH:?Set RECOVERY_PATH to a new absolute path in a protected directory outside version control.}" in
    /*)
      ;;
    *)
      printf '%s\n' 'RECOVERY_PATH must be an absolute POSIX path.' >&2
      exit 1
      ;;
  esac

  if [ -e "$RECOVERY_PATH" ] || [ -L "$RECOVERY_PATH" ]; then
    printf 'Refusing to overwrite or follow an existing recovery destination: %s\n' \
      "$RECOVERY_PATH" >&2
    exit 1
  fi

  az storage blob download \
    --account-name stacmeterraform \
    --container-name tfstate \
    --name environments/prod/terraform.tfstate \
    --version-id "${AZURE_VERSION_ID:?Set AZURE_VERSION_ID to the exact Azure blob version ID selected for recovery.}" \
    --file "${RECOVERY_PATH:?Set RECOVERY_PATH to a new absolute path in a protected directory outside version control.}" \
    --overwrite false \
    --auth-mode login
)
```

`--overwrite false` is defense in depth in addition to the common preflight; the Azure CLI documents the download command's `--overwrite` default as true.

### 6. Modernize GCS recovery

Require:

- Google Cloud CLI and authentication.
- `storage.objects.list` and `storage.objects.get`.
- `Storage Object Viewer` as one suitable predefined role.
- A POSIX-compatible shell.
- Object Versioning enabled on the bucket.

State concisely:

- This procedure retrieves generations retained through Object Versioning.
- Cloud Storage soft delete is a separate retention and recovery mechanism.
- `gcloud storage ls --all-versions` must not be presented as enumerating soft-deleted objects.
- No soft-delete restoration procedure is added in this issue.

Use:

```bash
gcloud storage ls \
  --all-versions \
  --json \
  gs://acme-corp-terraform-state/environments/prod/terraform.tfstate
```

Require deliberate selection of the exact numeric `generation`.

Use:

```bash
(
  umask 077

  case "${RECOVERY_PATH:?Set RECOVERY_PATH to a new absolute path in a protected directory outside version control.}" in
    /*)
      ;;
    *)
      printf '%s\n' 'RECOVERY_PATH must be an absolute POSIX path.' >&2
      exit 1
      ;;
  esac

  if [ -e "$RECOVERY_PATH" ] || [ -L "$RECOVERY_PATH" ]; then
    printf 'Refusing to overwrite or follow an existing recovery destination: %s\n' \
      "$RECOVERY_PATH" >&2
    exit 1
  fi

  gcloud storage cp \
    --no-clobber \
    "gs://acme-corp-terraform-state/environments/prod/terraform.tfstate#${GCS_GENERATION:?Set GCS_GENERATION to the exact GCS generation selected for recovery.}" \
    "${RECOVERY_PATH:?Set RECOVERY_PATH to a new absolute path in a protected directory outside version control.}"
)
```

`--no-clobber` is defense in depth in addition to the common preflight.

Do not select a generation automatically.

### 7. Correct and secure HCP Terraform discovery

Use `HCP Terraform (formerly Terraform Cloud)` on first use.

Direct operators to the workspace's `States` tab.

For the API:

- Require Bash and curl.
- Use `GET /state-versions`.
- Require the organization and workspace-name filters.
- Filter `status=finalized`.
- Use explicit manual pagination.
- Do not use `/workspaces/<WORKSPACE_ID>/state-versions`.
- Require an API token authorized to read state versions.
- Treat the token as a secret.
- Treat every response page as a secret because it contains Archivist URLs.
- State that HashiCorp documents those URLs as secret-bearing and valid for a limited time.
- Disable shell tracing.
- Do not expand the token into a curl command-line argument.
- Do not print the raw response into ordinary terminal output.
- Require a fresh protected response file for each page.

Use:

```bash
(
  umask 077

  TFC_RESPONSE_PATH=${TFC_RESPONSE_PATH:?Set TFC_RESPONSE_PATH to a new absolute path in a protected directory for this response page.}
  TFC_TOKEN=${TFC_TOKEN:?Set TFC_TOKEN to an HCP Terraform API token that can read state versions.}
  TFC_WORKSPACE_NAME=${TFC_WORKSPACE_NAME:?Set TFC_WORKSPACE_NAME to the exact HCP Terraform workspace name.}
  TFC_ORGANIZATION_NAME=${TFC_ORGANIZATION_NAME:?Set TFC_ORGANIZATION_NAME to the exact HCP Terraform organization name.}
  TFC_PAGE_NUMBER=${TFC_PAGE_NUMBER:-1}

  case "$TFC_RESPONSE_PATH" in
    /*)
      ;;
    *)
      printf '%s\n' 'TFC_RESPONSE_PATH must be an absolute POSIX path.' >&2
      exit 1
      ;;
  esac

  if [ -e "$TFC_RESPONSE_PATH" ] || [ -L "$TFC_RESPONSE_PATH" ]; then
    printf 'Refusing to overwrite or follow an existing HCP response file: %s\n' \
      "$TFC_RESPONSE_PATH" >&2
    exit 1
  fi

  set -C
  exec 3> "$TFC_RESPONSE_PATH" || {
    printf 'Unable to create new HCP response file without overwriting: %s\n' \
      "$TFC_RESPONSE_PATH" >&2
    exit 1
  }
  set +C

  curl -q \
    --config - \
    --fail \
    --silent \
    --show-error \
    --get \
    --data-urlencode "filter%5Bworkspace%5D%5Bname%5D=$TFC_WORKSPACE_NAME" \
    --data-urlencode "filter%5Borganization%5D%5Bname%5D=$TFC_ORGANIZATION_NAME" \
    --data-urlencode "filter%5Bstatus%5D=finalized" \
    --data-urlencode "page%5Bnumber%5D=$TFC_PAGE_NUMBER" \
    --data-urlencode "page%5Bsize%5D=100" \
    https://app.terraform.io/api/v2/state-versions \
    >&3 <<EOF
header = "Authorization: Bearer $TFC_TOKEN"
header = "Content-Type: application/vnd.api+json"
EOF

  curl_exit_code=$?
  exec 3>&-

  if [ "$curl_exit_code" -ne 0 ]; then
    printf 'curl failed with exit code %s; the protected response file may be empty or partial and must not be treated as valid: %s\n' \
      "$curl_exit_code" "$TFC_RESPONSE_PATH" >&2
    exit "$curl_exit_code"
  fi
)
```

Explain:

- All required values are validated before the response file is created, so an unset input does not leave a misleading empty file.
- The `[ -e "$TFC_RESPONSE_PATH" ] || [ -L "$TFC_RESPONSE_PATH" ]` preflight rejects every existing entry and a dangling final symbolic link.
- `set -C` enables Bash's `noclobber` option, and `exec 3> "$TFC_RESPONSE_PATH"` opens the exact requested path before any network request. If that exclusive create fails, curl does not run.
- `umask 077` restricts permissions on the newly created response file.
- `-q` is the first option and disables automatic reading of the user's default curl configuration.
- `--config -` reads sensitive header configuration from standard input.
- The token therefore does not appear in curl's ordinary argument list.
- An unquoted here-document is intentional so the guarded token expands.
- Curl writes its response to already-open file descriptor 3 while standard input remains available to `--config -`.
- The example captures curl's exit status immediately and closes file descriptor 3 before evaluating that status.
- `--fail` makes HTTP 400-and-later responses fail.
- `--silent --show-error` removes progress while retaining errors.
- `--get` moves encoded data into the query string.
- Curl expects the `name` portion of `name=content` to be pre-encoded, hence `%5B` and `%5D`.
- Values are encoded by curl.
- `finalized` excludes pending and discarded uploads.
- `TFC_PAGE_NUMBER` defaults to 1.
- Page size 100 is the documented maximum.
- Curl's `--no-clobber` output behavior is not used: curl can choose a numbered alternative filename rather than failing on the exact requested path, which would violate this contract.
- If curl fails after the exact path is created, the empty or partial protected file is deliberately retained, is not valid response data, and must be handled according to organizational retention and secure-deletion policy; retry with a fresh path.
- Exact-path no-clobber protection assumes a protected parent directory with no competing writer able to remove or replace entries during the operation.
- The operator must inspect the protected response using a trusted local JSON viewer.
- The operator must continue with fresh response paths until `meta.pagination.next-page` is `null`.
- Every page file contains sensitive hosted URLs and must remain outside Git, logs, tickets, chat, and unprotected artifacts.
- Do not use `set -x` or another tracing facility.
- Do not add an automatic `jq` loop or rollback command.

### 8. Treat recovered state as sensitive

State provider-neutrally:

- Recovered state can contain plaintext secrets.
- Keep it outside Git, issues, tickets, chat, logs, and unprotected artifacts.
- Limit local access.
- Do not reuse recovery paths.
- Validate the selected version before using the file for any operational recovery.
- These examples retrieve a copy; they do not overwrite active backend state.
- Follow organizational retention and secure-deletion requirements.
- Do not prescribe an OS-specific deletion command.

### 9. Advance guide version and metadata

Immediately before finalization:

1. Re-read the current guide version.
2. Increment Minor.
3. Use the UTC implementation date.
4. Reset Revision to `0`.
5. Update `Last Updated`.
6. Add a matching top rationale changelog row.

If the branch remains at `2.6.20260726.0` and implementation occurs on 2026-07-28 UTC, use:

```text
2.7.20260728.0
```

Otherwise recompute.

The changelog must mention:

- Exact-object discovery.
- Guarded identifiers.
- Protected, no-clobber recovery destinations.
- Restrictive creation permissions.
- AWS bucket-class/KMS reconciliation.
- Azure versioning applicability.
- GCS Object Versioning and soft-delete distinction.
- `gcloud storage`.
- HCP endpoint, finalized filtering, pagination, token transport, and protected response files.
- Sensitive recovered-state handling.

### 10. Regenerate generated artifacts

After the prerequisite issue has merged:

```powershell
$ErrorActionPreference = 'Stop'

& pwsh `
    -NoLogo `
    -NoProfile `
    -File './.github/workflows/Generate-StyleGuideArtifacts.ps1'

$intGeneratorExitCode = $LASTEXITCODE

if ($intGeneratorExitCode -ne 0) {
    throw (
        "Generator failed with exit code {0}." -f
        $intGeneratorExitCode
    )
}
```

Commit all four generated artifacts with the two source documents. Do not defer them to synchronization.

## Validation

Run from the repository root.

Every PowerShell block must:

- Begin with `$ErrorActionPreference = 'Stop'`.
- Define every variable it consumes.
- Check every native command's exit code immediately.

### Generate, lint, and check whitespace

```powershell
$ErrorActionPreference = 'Stop'

npm --prefix .github/workflows ci
$intNpmExitCode = $LASTEXITCODE
if ($intNpmExitCode -ne 0) {
    throw ("npm ci failed with exit code {0}." -f $intNpmExitCode)
}

& pwsh `
    -NoLogo `
    -NoProfile `
    -File './.github/workflows/Generate-StyleGuideArtifacts.ps1'

$intGeneratorExitCode = $LASTEXITCODE
if ($intGeneratorExitCode -ne 0) {
    throw ("Generator failed with exit code {0}." -f $intGeneratorExitCode)
}

npm --prefix .github/workflows run lint:md
$intNpmExitCode = $LASTEXITCODE
if ($intNpmExitCode -ne 0) {
    throw ("Markdown lint failed with exit code {0}." -f $intNpmExitCode)
}

npm --prefix .github/workflows run lint:md:nested
$intNpmExitCode = $LASTEXITCODE
if ($intNpmExitCode -ne 0) {
    throw ("Nested Markdown lint failed with exit code {0}." -f $intNpmExitCode)
}

git diff --check
$intGitExitCode = $LASTEXITCODE
if ($intGitExitCode -ne 0) {
    throw ("git diff --check failed with exit code {0}." -f $intGitExitCode)
}
```

### Verify working-tree scope and stage exactly six files

```powershell
$ErrorActionPreference = 'Stop'

$arrExpectedStagedPaths = @(
    'STYLE_GUIDE.md'
    'STYLE_GUIDE_RATIONALE.md'
    'copilot-instructions.md'
    'terraform.instructions.md'
    'STYLE_GUIDE_CHAT.md'
    'STYLE_GUIDE_FULL.md'
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
        "The working-tree path set is not exactly the two sources and four " +
        "generated artifacts. Status: {0}" -f
        ($arrStatusLines -join '; ')
    )
}

git add -- $arrExpectedStagedPaths
$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw ("git add failed with exit code {0}." -f $intGitExitCode)
}
```

### Rerun and verify the staged result

Rerun the generator, then require:

- `git diff --exit-code -- <six paths>` returns 0.
- `git diff --cached --check` returns 0.
- The staged path set exactly equals the six expected paths.
- No touched file starts with `EF BB BF`.
- No touched file contains a `0x0D` byte.

### Content confirmation

Confirm:

- Exact-object filters.
- Quoted, guarded identifiers.
- Absolute-path checks plus `[ -e ] || [ -L ]` rejection of every existing destination and every dangling final symbolic link.
- `umask 077` in every recovery block.
- Azure `--overwrite false`.
- GCS `--no-clobber`.
- No automatic selection.
- S3 general-purpose-bucket scope.
- Directory-bucket exclusion.
- Accurate AWS KMS reconciliation.
- Azure HNS exclusion.
- GCS Object Versioning scope and soft-delete distinction.
- HCP token absent from command arguments.
- HCP raw output written through a pre-opened exact-path no-clobber descriptor to a fresh protected file, with explicit empty/partial-file handling on curl failure.
- Pagination continues until `next-page` is `null`.
- Generated artifacts match sources.

### Pull-request evidence

Confirm:

1. Verification runs for every pull request targeting `main`.
2. Read-only Ubuntu passes.
3. The Windows matrix displays and completes four distinct edition/EOL cells.
4. The two LF cells complete lone-CR sanitation under their assigned editions.
5. Diagnostic upload uses the approved pin.
6. Push jobs skip.
7. No pull-request job has write permission.

### Post-merge push evidence

Confirm:

1. Read-only preparation runs.
2. One immutable candidate is uploaded with nonempty ID/digest.
3. Every Windows push cell downloads the same ID.
4. Every Windows push cell reports `success`, runs the deterministic helper self-test, and invokes the shared archive helper with the propagated digest.
5. Native digest-mismatch behavior is `error`, and the helper's independent digest comparison passes.
6. Approval succeeds after the complete matrix.
7. Preparation reports `has_changes=false`.
8. The conditional writer reports `skipped`; none of its steps, including its helper self-test or helper invocation, executes on this no-drift run. Its integration remains evidenced by the prerequisite issue's controlled `has_changes=true` write-path run and static inspection.
9. No bot synchronization commit is created.

If preparation reports changes, investigate source/artifact synchronization. Do not accept a recovery commit as this issue's expected outcome.

## Acceptance criteria

- Discovery and recovery are separate.
- Every provider requires deliberate version selection.
- Every selected identifier is quoted and guarded.
- Every recovery destination is nonempty, absolute, protected, new, and no-clobber; every final symbolic link, including a dangling link, is rejected.
- Every recovery block uses `umask 077`.
- Azure explicitly disables overwrite.
- GCS explicitly uses no-clobber.
- AWS performs an immediate nonexistence check.
- S3 prerequisites and bucket-class scope are accurate.
- General-purpose KMS retrieval guidance identifies `kms:Decrypt`.
- Directory-bucket KMS text is reconciled without implying version recovery.
- Azure requires Blob Versioning on a supported non-HNS account.
- GCS requires Object Versioning and distinguishes soft delete.
- HCP uses `/api/v2/state-versions`.
- HCP filters exact organization/workspace and `finalized`.
- HCP handles HTTP failures and manual pagination.
- HCP token data is supplied through `--config -`, not an expanded argument.
- HCP responses are written through a pre-opened Bash `noclobber` descriptor to the exact requested fresh protected path.
- HCP does not silently select an alternate output filename when the requested path is occupied.
- HCP curl failures retain an explicitly invalid empty or partial protected file and direct the operator to use a fresh path.
- Archivist URLs and recovered state are identified as secrets.
- No automatic selection, rollback, or `jq` loop is introduced.
- Version/date/changelog metadata agree.
- All four generated artifacts are committed with the sources.
- Before staging, the complete changed-path set is exactly the six affected files.
- After staging, the cached path set is exactly the same six files.
- No touched file begins with a BOM.
- No touched file contains a carriage-return byte.
- Post-merge preparation reports `has_changes=false`.
- No downstream-specific assumption is introduced.

## Non-goals

- Do not automate version selection.
- Do not overwrite active backend state.
- Do not add directory-bucket recovery.
- Do not add Azure HNS alternate recovery.
- Do not add GCS soft-delete restoration.
- Do not add an HCP rollback or automatic pagination loop.
- Do not add SSE-C recovery.
- Do not prescribe OS-specific deletion.
- Do not modify the prerequisite issue's files:
  - `.gitattributes`
  - `.github/workflows/Generate-StyleGuideArtifacts.ps1`
  - `.github/workflows/Expand-StyleGuideCandidateArtifact.ps1`
  - `.github/workflows/build.yml`
- Do not modify `.github/copilot-instructions.md`.
- Do not hand-edit generated artifacts.
- Do not run Terraform CLI validation.

## References

- [POSIX parameter expansion](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_02)
- [POSIX `test`](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/test.html)
- [GNU Bash redirections](https://www.gnu.org/software/bash/manual/html_node/Redirections.html)
- [GNU Bash `set` and `noclobber`](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)
- [GNU Bash parameter expansion](https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html)
- [Curl FAQ: protecting credentials](https://curl.se/docs/faq.html)
- [Curl known risks](https://curl.se/docs/knownrisks.html)
- [Curl manual](https://curl.se/docs/manpage.html)
- [curl CVE-2022-27778: `--no-clobber` uses numbered alternative filenames](https://curl.se/docs/CVE-2022-27778.html)
- [AWS CLI `list-object-versions`](https://docs.aws.amazon.com/cli/latest/reference/s3api/list-object-versions.html)
- [AWS `ListObjectVersions`](https://docs.aws.amazon.com/AmazonS3/latest/API/API_ListObjectVersions.html)
- [AWS required permissions](https://docs.aws.amazon.com/AmazonS3/latest/userguide/using-with-s3-policy-actions.html)
- [AWS general-purpose SSE-KMS permissions](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingKMSEncryption.html#sse-kms-permissions)
- [AWS KMS key policies](https://docs.aws.amazon.com/kms/latest/developerguide/key-policies.html)
- [AWS `GetObject`](https://docs.aws.amazon.com/AmazonS3/latest/API/API_GetObject.html)
- [AWS CLI `get-object`](https://docs.aws.amazon.com/cli/latest/reference/s3api/get-object.html)
- [AWS directory-bucket SSE-KMS](https://docs.aws.amazon.com/AmazonS3/latest/userguide/s3-express-UsingKMSEncryption.html)
- [AWS directory-bucket naming](https://docs.aws.amazon.com/AmazonS3/latest/userguide/directory-bucket-naming-rules.html)
- [Azure Blob Versioning](https://learn.microsoft.com/en-us/azure/storage/blobs/versioning-overview)
- [Azure CLI blob commands](https://learn.microsoft.com/en-us/cli/azure/storage/blob?view=azure-cli-latest)
- [Azure CLI data authorization](https://learn.microsoft.com/en-us/azure/storage/blobs/authorize-data-operations-cli)
- [Azure built-in roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles)
- [Google Cloud Object Versioning](https://docs.cloud.google.com/storage/docs/object-versioning)
- [Google Cloud versioned-object operations](https://docs.cloud.google.com/storage/docs/using-versioned-objects)
- [Google Cloud `gsutil` status](https://docs.cloud.google.com/storage/docs/gsutil)
- [`gcloud storage ls`](https://docs.cloud.google.com/sdk/gcloud/reference/storage/ls)
- [`gcloud storage cp`](https://docs.cloud.google.com/sdk/gcloud/reference/storage/cp)
- [Google Cloud Storage IAM](https://cloud.google.com/storage/docs/access-control/iam)
- [HCP Terraform state versions API](https://developer.hashicorp.com/terraform/cloud-docs/api-docs/state-versions)
- [HCP Terraform API authentication and pagination](https://developer.hashicorp.com/terraform/cloud-docs/api-docs)
- [HCP Terraform workspace state](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/state)
- [Terraform sensitive data](https://developer.hashicorp.com/terraform/language/manage-sensitive-data)
- [GitHub Actions job conditions](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/control-jobs-with-conditions)
- [GitHub Actions `needs` context](https://docs.github.com/en/actions/reference/workflows-and-actions/contexts#needs-context)
- [copilot-repo-template#851](https://github.com/franklesniak/copilot-repo-template/issues/851)
- [copilot-repo-template#852](https://github.com/franklesniak/copilot-repo-template/pull/852)
