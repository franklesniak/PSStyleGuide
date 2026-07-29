# Make state-version discovery and recovery examples copy-safe with guarded identifiers

## Summary

Make four provider-specific state-version surfaces safe to copy:

1. Amazon S3 object-version discovery/retrieval;
2. Azure Blob version discovery/retrieval;
3. Google Cloud Storage generation discovery/retrieval; and
4. HCP Terraform state-version API discovery into protected response files.

Separate discovery from recovery, require deliberate exact-version selection,
guard every identifier, write only fresh protected destinations, use
provider-native no-clobber controls where available, and permanently execute
the exact finalized Bash blocks with non-network stubs.

“Every destination” in this issue means every destination introduced or
modified by this issue. Manual backups and destructive state mutation have a
separate filing: **Make manual state backup and destructive recovery guidance
copy-safe**.

## Dependency

Implement only after **Promote generated style-guide artifacts through a
least-privileged verified writer** merges. Record the real blocked-by
relationship and exact merge commit.

At implementation start, verify these merged enduring invariants:

- generator output is LF and BOM-less under supported PowerShell editions;
- hosted Markdown validation uses exact Node 24;
- candidate transport uses immutable artifact ID plus propagated digest;
- the production helper enforces exact manifest, containment/link rejection,
  caller-owned context, and fail-closed cleanup;
- the permanent helper harness passes in Ubuntu and all four Windows cells;
- all external actions equal the merged exact role allowlist;
- workflows are unfiltered and read-only except the exact-lease writer; and
- the final reciprocal P1/Terraform matrix and CI run are linked.

Consume the merged public interfaces and evidence. Do not restate or alter
helper parameters, cleanup internals, case IDs, workflow roles, or writer
behavior here.

If npm remediation ran first due to advisory policy, use its exact merged
runtime/package contract rather than the default Node 24 prerequisite.

## Affected files

Exactly these eight files may change:

Source files:

- `STYLE_GUIDE.md`;
- `STYLE_GUIDE_RATIONALE.md`.

Generated files:

- `copilot-instructions.md`;
- `terraform.instructions.md`;
- `STYLE_GUIDE_CHAT.md`;
- `STYLE_GUIDE_FULL.md`.

Permanent test integration:

- `.github/workflows/Test-StateRecoveryExamples.sh` — add;
- `.github/workflows/markdownlint.yml`.

Do not hand-edit generated files.

## Exact scope inventory

Add stable invisible marker pairs around every finalized owned Bash block.
Use these IDs exactly and do not nest markers:

| ID | Surface |
| --- | --- |
| `SR-AWS-DISCOVERY` | exact-key S3 version discovery |
| `SR-AWS-RECOVERY` | selected S3 version retrieval |
| `SR-AZURE-DISCOVERY` | exact-name Azure version discovery |
| `SR-AZURE-RECOVERY` | selected Azure version retrieval |
| `SR-GCS-DISCOVERY` | exact-object GCS generation discovery |
| `SR-GCS-RECOVERY` | selected GCS generation retrieval |
| `SR-HCP-DISCOVERY` | one protected, paginated HCP API response |

The issue must inventory but not change/validate these adjacent workflows:

- every `terraform state pull > ...` direct-redirection backup;
- every `terraform state push`;
- `terraform state rm`;
- local corruption recovery using `mv`;
- overlapping older S3/provider examples; and
- destructive rollback guidance

in both `STYLE_GUIDE.md` and `STYLE_GUIDE_RATIONALE.md`. Link each location to
the destructive-state follow-up. Do not claim this issue authorizes or tests
state mutation.

## Common destination contract

For AWS, Azure, and GCS recovery:

- require Bash or a compatible POSIX environment;
- assign each input once before validation;
- require `RECOVERY_PATH` to be a new absolute POSIX file path;
- require a protected parent outside version-controlled worktrees and shared
  world-readable temporary locations;
- use a new path for every attempt;
- use a subshell and `umask 077`;
- reject the destination before provider invocation when
  `[ -e "$RECOVERY_PATH" ] || [ -L "$RECOVERY_PATH" ]`;
- keep `${RECOVERY_PATH:?...}` in the provider command;
- use provider-native no-overwrite flags when available; and
- never auto-select a version.

Explain that `test -e` follows links and can be false for a dangling final
link, while `test -L` identifies the link. The preflight is not an atomic
filesystem lock. The model requires a protected parent with no competing
writer, and the operator remains responsible for choosing a location outside
Git and inappropriate shared storage.

Recovered state, API pages, signed/Archivist URLs, and provider diagnostics can
contain plaintext secrets. Keep them out of Git, logs, issues, tickets, chat,
and unprotected artifacts. Limit access, use fresh paths, validate a selected
version before operational use, and follow organizational retention/deletion
policy.

## Provider requirements

### Amazon S3

Document:

- AWS CLI/configured credentials;
- discovery permission `s3:ListBucketVersions`;
- retrieval permission `s3:GetObjectVersion`;
- Versioning must have been enabled before the recoverable write;
- `Enabled` versus `Suspended` and `null` version semantics;
- lifecycle expiration/permanent deletion can remove old versions;
- exact-key empty results mean stop;
- recovery does not enable/suspend Versioning;
- general-purpose buckets only;
- directory buckets do not support Versioning/ListObjectVersions and accept
  only `null` in their GetObject version path;
- SSE-S3 needs no KMS authorization;
- general-purpose SSE-KMS/DSSE-KMS retrieval may need `kms:Decrypt`;
- `kms:GenerateDataKey` belongs to applicable upload/destination paths, not
  this historical download;
- SSE-C is outside this example; and
- current AWS bucket-class/KMS documentation must be rechecked immediately
  before implementation.

Final discovery body:

```bash
aws s3api list-object-versions \
  --bucket acme-corp-terraform-state \
  --prefix environments/prod/terraform.tfstate \
  --query "Versions[?Key=='environments/prod/terraform.tfstate'].{Key:Key,VersionId:VersionId,IsLatest:IsLatest,LastModified:LastModified,Size:Size}" \
  --output table
```

Require deliberate setting of `VERSION_ID`.

Final recovery body:

```bash
(
  umask 077

  case "${RECOVERY_PATH:?Set RECOVERY_PATH to a new absolute path in a protected directory outside version control.}" in
    /*) ;;
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

AWS has no `s3api get-object` no-clobber flag. The protected parent, fresh path,
and immediate preflight are mandatory.

### Azure Blob Storage

Document:

- Azure CLI/authentication;
- applicable blob-read permission;
- `Storage Blob Data Reader` as a suitable predefined role;
- Blob Versioning enabled on a supported account; and
- hierarchical-namespace accounts do not currently support Blob Versioning
  and are outside this version-ID procedure.

Final discovery body:

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

Require deliberate setting of `AZURE_VERSION_ID`.

Final recovery body:

```bash
(
  umask 077

  case "${RECOVERY_PATH:?Set RECOVERY_PATH to a new absolute path in a protected directory outside version control.}" in
    /*) ;;
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

`--overwrite false` is defense in depth; the common preflight remains required.

### Google Cloud Storage

Document:

- Google Cloud CLI/authentication;
- `storage.objects.list` and `storage.objects.get`;
- `Storage Object Viewer` as a suitable predefined role;
- Object Versioning enabled;
- this procedure retrieves versions retained through Object Versioning;
- soft delete is separate and not enumerated by
  `gcloud storage ls --all-versions`; and
- no soft-delete restoration is added.

Final discovery body:

```bash
gcloud storage ls \
  --all-versions \
  --json \
  gs://acme-corp-terraform-state/environments/prod/terraform.tfstate
```

Require deliberate setting of exact `GCS_GENERATION`.

Final recovery body:

```bash
(
  umask 077

  case "${RECOVERY_PATH:?Set RECOVERY_PATH to a new absolute path in a protected directory outside version control.}" in
    /*) ;;
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

  if ! [[ "$GCS_GENERATION" =~ ^[1-9][0-9]*$ ]]; then
    printf '%s\n' 'GCS_GENERATION must be a canonical positive decimal.' >&2
    exit 1
  fi

  gcloud storage cp \
    --no-clobber \
    "gs://acme-corp-terraform-state/environments/prod/terraform.tfstate#${GCS_GENERATION}" \
    "${RECOVERY_PATH:?Set RECOVERY_PATH to a new absolute path in a protected directory outside version control.}"
)
```

Validate the generation before constructing the source argument or calling
gcloud. Do not trim, convert with shell arithmetic, accept locale digits, or
auto-select a live/latest value. Pass the reviewed decimal string unchanged.

### HCP Terraform

Use `HCP Terraform (formerly Terraform Cloud)` on first mention. Direct
operators to the workspace `States` tab as the ordinary UI path.

For the API:

- require Bash and resolved curl;
- use `GET /api/v2/state-versions`;
- require organization/workspace filters;
- filter `status=finalized`;
- use explicit `page[number]` and fixed maximum `page[size]=100`;
- require a token authorized to read state versions;
- use only `app.terraform.io` or `app.eu.terraform.io`;
- keep Terraform Enterprise hosts out of scope;
- never put the token on curl's command line;
- disable inherited xtrace before any secret expansion;
- ignore ambient curl configuration;
- write one protected response page per request; and
- retain failed empty/partial response files as invalid sensitive evidence,
  retrying only with a fresh path.

The finalized block must implement these exact validation rules before config
or response-file creation:

- `TFC_HOST` is exactly `app.terraform.io` or `app.eu.terraform.io`;
- `TFC_PAGE_NUMBER` matches `^[1-9][0-9]*$`;
- organization and workspace are nonempty, contain no controls, and satisfy
  the then-current documented HCP name grammar;
- `TFC_TOKEN` is nonempty and contains no CR, LF, control byte, double quote,
  or backslash; and
- `TFC_RESPONSE_PATH` is an absolute POSIX fresh path for which neither
  `-e` nor `-L` is true.

The block must:

1. make `set +x` its first command inside a subshell;
2. use `umask 077`;
3. create one random, absent, mode-0600 curl config in an owned protected
   temporary directory;
4. write one option per physical config line, including the validated quoted
   bearer header and JSON API content type;
5. open the exact response path with Bash `noclobber` before curl;
6. invoke curl with `--disable` first, explicit
   `--config "$TFC_CURL_CONFIG_PATH"`, `--fail --silent --show-error --get`,
   URL-encoded filters/page values, and exact
   `"https://${TFC_HOST}/api/v2/state-versions"`;
7. capture curl's exit immediately and close the response descriptor;
8. remove only the exact ordinary owned config file and empty config directory
   without recursion or link following;
9. restore the parent shell's xtrace state by leaving the subshell; and
10. never print the token or raw response.

Use curl's `--data-urlencode` for values; percent-encode the bracketed query
parameter names as required. Do not use curl output `--no-clobber`, because it
can select an alternative filename. Continue with fresh response paths until
`meta.pagination.next-page` is null. Do not add an automatic `jq` loop or state
rollback command.

Curl config quoted parameters interpret backslash escapes. Rejecting
quote/backslash/control bytes before writing the file is a required
authorization boundary, not an optional hygiene check.

## Source roles and generated output

`STYLE_GUIDE.md` stays concise and operational:

- prerequisites/applicability;
- separated discovery/recovery;
- deliberate selection;
- guarded commands;
- fresh protected destinations;
- no-clobber behavior; and
- concise sensitive-state warnings.

`STYLE_GUIDE_RATIONALE.md` owns:

- angle-bracket redirection and `${parameter:?word}` behavior;
- `-e`/`-L`, subshell, `umask`, and non-atomic guard limits;
- AWS general-purpose/directory-bucket/KMS reconciliation;
- Azure hierarchical-namespace limitation;
- GCS Object Versioning versus soft delete and generation grammar;
- HCP host/page/curl-config/token/xtrace/response mechanics;
- provider-specific least privilege; and
- the exact out-of-scope destructive-state inventory/T4 link.

Immediately before finalization:

1. re-read the current guide version;
2. increment Minor;
3. use the UTC implementation date;
4. reset Revision to `0`;
5. update `Last Updated`; and
6. add a matching top rationale changelog row.

Run the merged generator once from exact source. Never edit generated files
directly. Prove all four generated outputs are LF, BOM-less, CR-free, current,
and idempotent.

## Permanent exact-block harness

Create `.github/workflows/Test-StateRecoveryExamples.sh`.

The script must:

- be LF/BOM-less and start with an explicit Bash shebang;
- record a test version;
- accept exact source paths;
- validate one-to-one equality among the issue inventory, source markers,
  extracted bodies, generated copies, and tests;
- fail on missing, duplicate, nested, malformed, or unexpected markers;
- extract only fenced-block bodies without evaluating surrounding Markdown;
- run `bash -n` on each exact body;
- execute in one new owned sandbox with a closed test `PATH`;
- provide non-network `aws`, `az`, `gcloud`, `curl`, and supporting stubs;
- fail every unexpected executable/network attempt;
- capture each stub call as a NUL-delimited argv record and ordered call log;
  and
- assert exact rejection message/code and filesystem postcondition for every
  case.

Mandatory common cases:

- missing, empty, relative, existing file, existing directory, live link, and
  dangling-link destination before provider invocation;
- successful fresh absolute destinations containing spaces and shell
  metacharacters;
- restrictive mode;
- provider success/failure;
- documented partial-file retention/removal;
- exact owned cleanup; and
- no token/state bytes in stdout/stderr/call logs.

Provider cases:

- exact S3 key filter, unchanged `VERSION_ID`, expected flags, and no provider
  call before validation;
- exact Azure filter, unchanged `AZURE_VERSION_ID`, `--overwrite false`, and
  expected auth mode;
- exact GCS object, `--all-versions`, `--no-clobber`, and unchanged generation;
- GCS positive one-/20-digit generations and rejection of empty, zero, signs,
  whitespace, leading zero, decimal/exponent/comma, Unicode digit, `#`, slash,
  query/shell metacharacter, and alphabetic text;
- both HCP hosts;
- rejected arbitrary host, scheme, port, path, userinfo, and enterprise host;
- page empty/zero/negative/plus/space/leading-zero/query/control values;
- token empty/CR/LF/quote/backslash/control;
- inherited xtrace;
- exact curl config mode/content and argv;
- absence of ambient `.curlrc`;
- simulated curl/HTTP failure with invalid partial response;
- config cleanup and response retention; and
- zero token bytes in any observable evidence.

A case passes only with the intended reason and postcondition; any nonzero exit
is not sufficient.

Invoke the exact harness as a stable step in the existing Ubuntu
`.github/workflows/markdownlint.yml` job after clean install and both lint
surfaces. Preserve merged:

- hosted Node 24 and disabled automatic package-manager cache;
- exact action pins/role allowlist;
- read-only permissions;
- unfiltered triggers;
- helper harness step; and
- one ordinary Ubuntu job.

Do not add an external action or a separate workflow.

## Local validation

Resolve one Node and npm application pair. Prove npm's actual
`process.execPath`/`process.versions.node` matches the selected Node and exact
merged major (Node 24 in default order). Record paths and full versions.

Save whether process `CI` exists and its exact value. Set `CI=true` only around
clean `npm ci`; in `finally`, restore the prior value exactly or remove it.
Use the same resolved npm application for outer and nested lint.

Then:

1. run the generator;
2. run the exact Bash harness;
3. run all content/marker/inventory assertions;
4. prove generated artifacts match source and rerun idempotently;
5. prove package, lockfile, hook, Node policy, lint config, helper/context/
   harness, build workflow, and Dependabot are unchanged;
6. require the complete working path set to equal the eight affected files;
7. stage exactly those eight paths;
8. require cached path equality and LF/BOM/CR policy;
9. rerun validation from staged content; and
10. prove no further generator diff.

Store pull-request evidence for the permanent shell step, existing helper
harness, full Windows matrix, immutable artifact, approval, and absence of a
writer. After merge, store the push run proving all matrices, exact artifact,
and either correct no-op or exact-lease writer behavior.

## Acceptance criteria

- [ ] The exact owned surface is seven stable marked Bash blocks covering four
      provider surfaces.
- [ ] Every destination introduced/modified here is fresh, absolute,
      protected, restrictive, and guarded against file/directory/live/dangling
      link overwrite.
- [ ] Discovery and recovery remain separate and selection is deliberate.
- [ ] S3 exact-key, bucket-class, versioning, KMS, and permission guidance is
      internally consistent.
- [ ] Azure exact-name, role, versioning, HNS, and `--overwrite false`
      guidance is correct.
- [ ] GCS uses `gcloud storage`, distinguishes Object Versioning/soft delete,
      and requires canonical positive generation passed unchanged.
- [ ] HCP uses the correct state-versions endpoint, filters, pagination, closed
      US/EU hosts, protected config/response files, and closed token grammar.
- [ ] No token appears in command arguments, trace, logs, files other than the
      short-lived protected config, or artifacts.
- [ ] Every exact block passes syntax and mandatory non-network behavioral
      cases in the tracked harness.
- [ ] The permanent harness runs in ordinary read-only Ubuntu CI.
- [ ] Both source files and all four generated files advance consistently and
      pass LF/BOM/lint/idempotence checks.
- [ ] Local npm validation uses one resolved pair and restores `CI`.
- [ ] The adjacent destructive-state inventory is explicit and linked to T4.
- [ ] The changed/staged set equals the eight affected files.

## Non-goals

- Destructive `terraform state push`, `state rm`, or rollback.
- Manual `terraform state pull` backup publication.
- Local corruption-file moves.
- Enabling/disabling provider versioning.
- GCS soft-delete restoration.
- HCP Terraform Enterprise/custom hosts.
- Automatic version selection or pagination loops.
- Prescribing OS-specific secure deletion.
- Package/lockfile/hook/runtime-policy changes.
- Helper, artifact, approval, or writer redesign.

## References

- [AWS S3 ListObjectVersions](https://docs.aws.amazon.com/AmazonS3/latest/API/API_ListObjectVersions.html)
- [AWS S3 GetObject permissions](https://docs.aws.amazon.com/AmazonS3/latest/API/API_GetObject.html)
- [Azure Blob versions](https://learn.microsoft.com/azure/storage/blobs/versioning-overview)
- [Azure blob download CLI](https://learn.microsoft.com/cli/azure/storage/blob#az-storage-blob-download)
- [Google Cloud versioned objects](https://cloud.google.com/storage/docs/using-versioned-objects)
- [gcloud storage cp](https://cloud.google.com/sdk/gcloud/reference/storage/cp)
- [HCP Terraform state versions API](https://developer.hashicorp.com/terraform/cloud-docs/api-docs/state-versions)
- [HCP Terraform in Europe](https://developer.hashicorp.com/terraform/cloud-docs/europe)
- [curl config-file grammar](https://curl.se/docs/manpage.html)
- [GNU Bash manual](https://www.gnu.org/software/bash/manual/bash.html)
