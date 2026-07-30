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
relationship. The T1B handoff records both its reviewed head and actual
ruleset-protected `main` landed commit, merge method/time, issue/PR links,
ruleset ID, normalized rule JSON SHA-256, and effective-rule/bypass evidence. Before
any edit, parse the landed value as a full commit ID, require it exists and is
reachable from live `refs/heads/main`; re-query the exact active/effective rule
and sole official Actions bypass; and validate all enduring T1/T1A/T1B
interfaces/versions at that commit. Stop on absent/disabled/broadened rule,
different bypass actor, predicted/head-only commit, or mismatch.

At implementation start, verify these merged enduring invariants:

- generator output is LF and BOM-less under supported PowerShell editions;
- hosted Markdown validation uses exact Node `24.18.1`/npm `11.16.0`;
- candidate transport uses immutable artifact ID plus propagated digest;
- the production helper enforces exact manifest, containment/link rejection,
  caller-owned context, and fail-closed cleanup;
- the permanent helper harness passes in Ubuntu and all four Windows cells;
- all external actions equal the merged exact role allowlist;
- workflows are unfiltered and read-only except the exact-lease writer; and
- the final reciprocal generator, candidate-validation, and writer-layer
  matrices and CI run are linked.

Consume the merged public interfaces and evidence. Do not restate or alter
helper parameters, cleanup internals, case IDs, workflow roles, or writer
behavior here.

No implementation-time substitution is allowed: use the exact merged Node
`24.18.1` and bundled npm `11.16.0` pair.

## Affected files

Exactly these nine files may change:

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
- `.github/workflows/markdownlint.yml`; and
- `.github/workflows/Validate-WorkflowPolicy.mjs`.

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

The public environment input map is closed:

| Provider field | Exact input | Discovery | Recovery/API | Supported subset |
| --- | --- | ---: | ---: | --- |
| AWS bucket | `AWS_S3_BUCKET` | required | required | 3–63 lowercase alphanumeric/hyphen; alphanumeric endpoints; no `--` or reserved form |
| AWS object key | `AWS_S3_KEY` | required | required | 1–1024-byte safe nonempty segment grammar |
| AWS selected version | `AWS_S3_VERSION_ID` | absent | required | 1–1024-byte safe version grammar; literal `null` allowed |
| Azure account | `AZURE_STORAGE_ACCOUNT` | required | required | 3–24 lowercase ASCII alphanumeric |
| Azure container | `AZURE_STORAGE_CONTAINER` | required | required | 3–63 lowercase alphanumeric/hyphen |
| Azure blob | `AZURE_STORAGE_BLOB` | required | required | 1–1024-byte safe nonempty segment grammar |
| Azure selected version | `AZURE_STORAGE_VERSION_ID` | absent | required | 1–128 bytes `[A-Za-z0-9._~:+%-]+` |
| GCS bucket | `GCS_BUCKET` | required | required | 3–63 lowercase alphanumeric/hyphen |
| GCS object | `GCS_OBJECT` | required | required | 1–1024-byte safe nonempty segment grammar |
| GCS selected generation | `GCS_GENERATION` | absent | required | `[1-9][0-9]{0,19}` |
| HCP hostname | `TFC_HOST` | n/a | required | exactly `app.terraform.io` or `app.eu.terraform.io` |
| HCP organization | `TFC_ORGANIZATION` | n/a | required | `[A-Za-z0-9][A-Za-z0-9_-]{0,63}` |
| HCP workspace | `TFC_WORKSPACE` | n/a | required | same 1–64-byte subset |
| HCP page | `TFC_PAGE_NUMBER` | n/a | required | `[1-9][0-9]{0,19}` |
| HCP bearer token | `TFC_TOKEN` | n/a | required secret | nonempty; no quote, backslash, CR/LF, or control |

Immediately before each standalone marked subshell, show only applicable
`export NAME='replace-with-...'` placeholders and instruct discovery first and
deliberate selected-version assignment before recovery. No marked block
contains a demonstration bucket/key/account/container/blob/object/workspace,
placeholder, live-version query, `latest`, or automatic selection.

As the first in-subshell input operation, set `LC_ALL=C`; copy every applicable
public variable exactly once with `${NAME-}` into a provider-prefixed local,
mark it readonly, and unset the copied public names. HCP executes `set +x`
before its first secret expansion. No later reread, indirect expansion, alias,
or default is permitted. Unset/empty is one `input-missing-or-empty` failure
before filesystem/provider work; control/non-ASCII/whitespace/length/shape
fail separately. Accepted bytes are not trimmed, normalized, decoded, or
rewritten.

Provider construction uses only the snapshotted locals:

- AWS discovery/recovery pass unchanged bucket/key to `--bucket` and
  `--prefix`/exact equality query, and recovery alone passes
  `--version-id "$aws_s3_version_id"`;
- Azure passes unchanged account/container/blob to `--account-name`,
  `--container-name`, and `--prefix|--name`, with recovery alone using
  `--version-id "$azure_storage_version_id"`;
- GCS constructs exactly `gs://${gcs_bucket}/${gcs_object}` and recovery adds
  `#${gcs_generation}` after delimiter-safe validation; and
- HCP uses separate `curl --data-urlencode` fields for
  organization/workspace/status/page, validated host for URL, and token only
  in the protected curl config.

The harness records redacted field name, accepted length/SHA-256, and NUL-safe
provider argv. Discovery/recovery location bytes must match and selected
version appears only in recovery. Each field has one atomic missing, empty,
control, ASCII, endpoint, length, metacharacter, and valid preservation row.

For AWS, Azure, and GCS recovery:

- require Bash through an explicit shebang/runtime guard; select and document
  the minimum Bash version available on the supported hosted Ubuntu runner;
- assign each input once before validation;
- require explicit `RECOVERY_PARENT`, direct-child `RECOVERY_PATH`, and literal
  `RECOVERY_PARENT_ATTESTATION=private-outside-vcs-no-competing-writers`;
- inspect the parent's canonical path, ordinary/non-link type, effective owner,
  exact mode `0700`, and outside-repository/shared-root relationship;
- use a new path for every attempt;
- use a subshell, `set -euo pipefail`, and `umask 077`;
- reject the destination before provider invocation when
  `[ -e "$RECOVERY_PATH" ] || [ -L "$RECOVERY_PATH" ]`;
- create one private invocation directory on the destination filesystem with
  `mktemp -d` beneath the validated protected parent;
- give the provider one exact absent temporary leaf, not `RECOVERY_PATH`;
- capture provider failure inside an explicit `if` so strict mode cannot bypass
  cleanup;
- on provider failure, delete only the exact journaled partial when the
  invocation directory contains exactly that ordinary non-link file; remove
  the now-empty invocation directory nonrecursively;
- if the partial/root is missing, substituted, linked, unreadable, or contains
  any unjournaled entry, retain the entire uncertain invocation root and report
  it as invalid sensitive state;
- on success, require one nonempty ordinary non-link temporary file, validate
  it with `terraform show -json`, and publish to the still-absent
  `RECOVERY_PATH` with GNU
  `ln --no-target-directory` as a same-filesystem no-replace hard link; never
  use `--force`, `--backup`, or directory-target semantics;
- verify temporary/final byte equality, remove only the temporary link and
  empty invocation directory, and leave one validated final file;
- fail closed and retain the validated temporary file if no-replace hard-link
  publication is unsupported;
- use provider-native no-overwrite flags for the temporary leaf where
  available; and
- never auto-select a version.

The direct destination leaf, shared by `RECOVERY_PATH` and
`TFC_RESPONSE_PATH`, is 1–128 bytes and exactly
`[A-Za-z0-9][A-Za-z0-9._-]{0,127}` under `LC_ALL=C`. Derive it only after
proving the full destination is exactly `"$parent/$leaf"` with one nonempty
component. Reject slash, leading dot/dash, dot entries, whitespace/control/
non-ASCII, and length violations before showing raw input. Render any validated
or retained path for diagnostics only through `printf -v rendered_path '%q'
-- "$path"` and a fixed format.

Explain that `test -e` follows links and can be false for a dangling final
link, while `test -L` identifies the link. The preflight is not an atomic
filesystem lock. The model requires a protected parent with no competing
writer, and the operator remains responsible for choosing a location outside
Git and inappropriate shared storage.

The final postcondition is exact:

- success: `RECOVERY_PATH` is one validated ordinary non-link file and the
  private invocation directory is absent;
- ordinary provider/validation failure: `RECOVERY_PATH` is absent and every
  proven owned ordinary partial is removed; or
- ownership/publication uncertainty: `RECOVERY_PATH` is never overwritten,
  the exact uncertain private root is retained, and the command fails with
  cleanup plus primary diagnostics.

No recovery block recursively removes, follows, retries into, or reuses a
failed destination.

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

Final marked AWS blocks are assembled from the single common standalone
lifecycle below plus these provider-specific fragments; do not duplicate the
cleanup, identity, publication, or signal implementation in this subsection.

Discovery passes the snapshotted values and uses exact-key filtering:

```bash
aws s3api list-object-versions \
  --bucket "$aws_s3_bucket" \
  --prefix "$aws_s3_key" \
  --query "Versions[?Key=='$aws_s3_key'].{Key:Key,VersionId:VersionId,IsLatest:IsLatest,LastModified:LastModified,Size:Size}" \
  --output table
```

Recovery requires deliberate `AWS_S3_VERSION_ID` input and defines only this
provider adapter for the shared recovery lifecycle:

```bash
download_selected_state() {
  local destination=$1
  aws s3api get-object \
    --bucket "$aws_s3_bucket" \
    --key "$aws_s3_key" \
    --version-id "$aws_s3_version_id" \
    "$destination"
}
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

Final marked Azure blocks use the common standalone lifecycle and these
provider-specific fragments only.

Discovery passes the snapshotted values and filters the exact blob name:

```bash
az storage blob list \
  --account-name "$azure_storage_account" \
  --container-name "$azure_storage_container" \
  --include v \
  --prefix "$azure_storage_blob" \
  --query "[?name=='$azure_storage_blob'].{Name:name,VersionId:versionId,IsCurrent:isCurrentVersion}" \
  --auth-mode login \
  --output table
```

Recovery requires deliberate `AZURE_STORAGE_VERSION_ID` input and defines:

```bash
download_selected_state() {
  local destination=$1
  az storage blob download \
    --account-name "$azure_storage_account" \
    --container-name "$azure_storage_container" \
    --name "$azure_storage_blob" \
    --version-id "$azure_storage_version_id" \
    --file "$destination" \
    --overwrite false \
    --auth-mode login
}
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

Final marked GCS blocks use the common standalone lifecycle and these
provider-specific fragments only.

Discovery constructs the exact validated object URI once:

```bash
gcloud storage ls \
  --all-versions \
  --json \
  "gs://${gcs_bucket}/${gcs_object}"
```

Recovery requires deliberate exact `GCS_GENERATION` input and defines:

```bash
download_selected_state() {
  local destination=$1
  gcloud storage cp \
    --no-clobber \
    "gs://${gcs_bucket}/${gcs_object}#${gcs_generation}" \
    "$destination"
}
```

`--no-clobber` protects the private absent temporary leaf; the shared real
GNU `ln --no-target-directory` operation is still the only final-path
publication mechanism.

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
- organization and workspace each match the deliberate supported subset
  `[A-Za-z0-9][A-Za-z0-9_-]{0,63}`;
- `TFC_TOKEN` is nonempty and contains no CR, LF, control byte, double quote,
  or backslash; and
- `TFC_RESPONSE_PARENT`,
  `TFC_RESPONSE_PARENT_ATTESTATION=private-outside-vcs-no-competing-writers`,
  and direct-child `TFC_RESPONSE_PATH` satisfy the exact HCP protected-parent
  contract; neither `-e` nor `-L` is true for the response.

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

## Normative protection, identifier, interruption, and evidence contracts

The following contracts are the only lifecycle implementation requirements for
every final marked block. Provider subsections contribute argv construction
fragments only; they do not define parallel cleanup, identity, publication, or
signal behavior.

### Protected parent is an attested precondition plus an inspected subset

AWS/Azure/GCS recovery accepts three separate values:
`RECOVERY_PARENT`, `RECOVERY_PATH`, and
`RECOVERY_PARENT_ATTESTATION`. The attestation must equal literal
`private-outside-vcs-no-competing-writers`. `RECOVERY_PARENT` is a fully
qualified absolute path resolved with `realpath -e` to exactly itself; it is an
ordinary non-link directory outside repository/shared temporary roots, owned by
the effective UID, mode exactly `0700`, on the destination filesystem.
`RECOVERY_PATH` is one direct-child ordinary filename under that exact parent,
not merely a string-prefix descendant, and is absent under both `-e` and `-L`.

The operator attests, based on separately reviewed OS/storage evidence, that
the parent is outside version control/shared storage, its access controls apply
to all relevant principals/mount layers, and no other process able to mutate
entries is active. The block/harness may prove only the canonical path,
direct-child relationship, owner, mode, type/link state, filesystem, and
absence subset; it must never report the real-world attestation as
machine-proven. A wrong/missing literal or any failed/unsupported inspection
stops before directory/provider creation.

HCP uses the identical two-layer semantics under HCP-specific names:
`TFC_RESPONSE_PARENT`, `TFC_RESPONSE_PATH`, and
`TFC_RESPONSE_PARENT_ATTESTATION`. Its curl-config root is a direct child mode
`0700`; config and response are mode `0600`; response is acquired with
noclobber. The intentional HCP difference is retention: success retains the
validated page; curl/HTTP/nonempty-partial failure retains the exact response
as invalid sensitive evidence. Cleanup never deletes the response name and
removes only the proven token-config file/root.

Fixtures distinguish enforceable inspection from attested facts. They cover
wrong literal, parent equality/canonicalization, nested/escaped destination,
wrong owner/mode/type/link/filesystem, repository/shared-root membership, and
an attestation that is syntactically valid but intentionally false; the latter
proves the harness does not claim external truth.

### Signal-specific exit and one cleanup owner

Every Bash block has distinct HUP/INT/TERM handlers that ignore further
signals and exit `129`, `130`, or `143`. Only `EXIT` invokes cleanup. On entry,
cleanup captures `$?`, disables its own trap, ignores HUP/INT/TERM, inspects and
cleans exactly once, and preserves the primary nonzero status. Cleanup-only
failure returns `1`; cleanup failure during another primary/signal failure is
reported but never replaces it.

The shared implementation is a closed state machine. Install traps only after
every cleanup variable and ownership flag has an explicit initial value. A
signal handler records only its conventional status and transfers control to
the single `EXIT` owner. On cleanup entry, expand and store `$?` in
`primary_status` before every other expansion or command; then run `set +e`
followed by `set +u`, clear `EXIT`, and ignore HUP/INT/TERM. Classify the status
of each trap operation.

Maintain `cleanup_status=0`, an explicit lifecycle/ownership state, and
`inspection_complete=false`. Enumerate the invocation root with a waited
producer: open a dynamic descriptor from
`find -- "$root" -mindepth 1 -maxdepth 1 -print0`, save `$!`, read every
NUL-delimited entry, close the descriptor, and explicitly classify
`wait "$producer_pid"`. A failed open, read, close, wait, type check, ownership
check, or diagnostic sets cleanup status `1`, retains the whole root, and
authorizes no deletion. No unlink or `rmdir` branch is reachable before all
relevant inspections succeed.

Permit `rm -- "$exact_owned_partial"` only when inventory contains exactly
that journaled path, it is an ordinary non-link, and lifecycle state proves
this invocation created but did not publish it. Permit
`rmdir -- "$exact_root"` only after successful inspection and after the owned
partial was removed successfully or the root was proven empty. Never remove
recursively. Every fallible diagnostic, descriptor operation, `find`, `wait`,
`rm`, and `rmdir` is inside an explicit status branch; no bare cleanup command
may determine flow under shell options. Exit with the primary status when it
is nonzero, otherwise `1` for any cleanup failure, otherwise `0`.

No block invokes one cleanup function directly for `EXIT HUP INT TERM`,
returns zero after a signal, retries, or follows a link. The permanent harness
uses synchronization barriers—not timing sleeps—to deliver every signal during
pre-create, partial-provider, validated-before-publication, and publication
uncertainty phases for AWS/Azure/GCS, with cleanup success/failure
permutations. It also covers diagnostic-write, descriptor-open/read/close,
`find`, `wait`, unlink, `rmdir`, reoccupation, symlink, dangling-link,
unreadable-root, primary-plus-cleanup-failure, cleanup-only-failure, and
second-signal cases. Each stable row asserts status, cleanup call count `1`,
exact remaining identities, reason code, provider call count, and unchanged
sentinels.

### Exact sensitive-file identity at every boundary

Use one shared POSIX state-file identity record:

```text
device:inode:owner_uid:mode_octal:link_count:size
```

With `LC_ALL=C`, obtain it from exactly
`stat -c '%d:%i:%u:%a:%h:%s' -- "$path"` with native stderr suppressed.
Require one line containing exactly six canonical nonnegative decimal fields,
except that `mode_octal` is canonical octal; reject nonzero status,
extra/missing output, or malformed fields. Separately require `-f "$path"` and
`! -L "$path"`. Resolve and parse the effective UID once with `id -u` and the
protected-parent device once with `stat -c '%d'`. Diagnostics use stable
reason codes and encoded paths, never native error text or state bytes.

After AWS/Azure/GCS provider success and before validation/publication, require
the one journaled temporary to have the effective owner, mode `600`, protected
parent/root device, link count `1`, and nonzero size. Save its device/inode.
After the real no-replace hard link, snapshot both names and require the same
saved device/inode, owner, mode, size, and link count `2`; require
`cmp -- "$recovery_temp" "$recovery_path"` success. Unlink the exact temporary,
snapshot the final again, and require the same identity and link count `1`
before removing the empty root.

Publication eligibility and cleanup ownership are distinct. Wrong mode blocks
publication but still permits cleanup only if effective owner, device, ordinary
non-link type, exact journaled path, and link count `1` prove ownership. Wrong
owner/device/link count, substitution, failed inspection, or an extra entry is
`candidate-identity-uncertain`: retain the whole root and unlink nothing. Any
post-publication mismatch is `publication-identity-uncertain`: retain both
names and the root. A no-replace publication failure retains the validated
strict-identity temporary.

For HCP, snapshot the response immediately after noclobber acquisition and
again after curl exits and its descriptor closes. Both snapshots must have the
same device/inode, effective owner, mode `600`, response-parent device, and
link count `1`; success also requires nonzero size. Content or identity failure
retains the exact response under the existing sensitive-evidence rule.

Atomic fixtures cover wrong mode, wrong owner, initial extra hard link,
device/inspection failure, inode substitution, post-link identity/link-count
mismatch, and post-unlink link count other than `1` for all three recovery
providers. HCP covers acquisition and post-curl wrong mode/owner/link count,
substitution, and inspection failure. Positive rows record the exact tuple at
every phase. The Ubuntu harness uses real GNU `stat` and `ln`; a declared
noninteractive privileged fixture step may arrange a foreign UID but is never
part of production code.

### Deliberately narrow provider-field grammars

Set `LC_ALL=C` before validation. Reject NUL, every C0/C1/DEL control,
non-ASCII, whitespace, or an over-limit byte sequence before logging or
provider invocation. Accepted bytes are passed to the provider unchanged—no
trim, case fold, Unicode normalization, decode/re-encode, shell arithmetic, or
automatic selection.

| Field | Exact supported subset |
| --- | --- |
| `AWS_S3_BUCKET` | 3–63 lowercase ASCII alphanumeric/hyphen; alphanumeric endpoints; no `--` or reviewed reserved form |
| AWS key | 1–1024 bytes of nonempty `/`-separated safe segments using `[A-Za-z0-9._~+=,@-]`; no empty, `.`/`..`, leading slash |
| `AWS_S3_VERSION_ID` | 1–1024 bytes `[A-Za-z0-9._~+/%=-]+`; literal `null` is valid |
| Azure account | 3–24 lowercase ASCII alphanumeric |
| Azure container | 3–63 lowercase alphanumeric/hyphen; alphanumeric endpoints; no `--` |
| Azure blob | 1–1024 bytes of the same nonempty safe-segment model |
| `AZURE_STORAGE_VERSION_ID` | 1–128 bytes `[A-Za-z0-9._~:+%-]+` |
| GCS bucket | 3–63 lowercase alphanumeric/hyphen; alphanumeric endpoints; no `--` |
| GCS object | 1–1024 bytes of the same nonempty safe-segment model |
| `GCS_GENERATION` | `[1-9][0-9]{0,19}` |
| HCP organization/workspace | 1–64 bytes: `[A-Za-z0-9]` followed by at most 63 `[A-Za-z0-9_-]` |

These are intentional copyable safe subsets, not complete provider grammars.
Immediately before implementation, recheck official provider sources; a needed
identifier outside a subset requires an issue/table/fixture change, not ad hoc
relaxation. Add one atomic fixture per field at every endpoint/length/control/
metacharacter boundary and assert exact unchanged provider argv.

### Raw-byte affected-path and native-status evidence

Consume T1B's merged native Git reader/status classifier rather than
reimplementing line parsing. It exposes closed endpoint modes for
`status --porcelain=v1 -z`, cached diff, commit/parent diff, and quiet
difference. Preserve Buffer/NUL records, reject malformed/final-NUL/duplicate/
noncanonical paths, and classify only native `0` as no difference, `1` as
difference, and every other/start/signal outcome as tool failure.

Apply independent endpoint checks to the exact nine T2 paths at worktree,
index, commit/parent, and post-generator layers. Record whether each expected
set is equality, subset, or empty; never use one layer's status as evidence for
another. Disposable Git fixtures include spaces, tabs, newline, leading dash,
quotes/non-ASCII, malformed NUL records, external diff/text conversion, and
native `0/1/2` plus start failure.

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
- provide non-network `aws`, `az`, `gcloud`, `curl`, `terraform`, and
  supporting remote/tool stubs;
- exercise real same-filesystem `ln`, ordinary-file classification, cleanup,
  and competing-final behavior; do not stub the no-replace primitive;
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

Mandatory provider-download lifecycle IDs are append-only and each has one
machine-readable harness row:

| ID | Stub/filesystem setup | Exact oracle |
| --- | --- | --- |
| `AWS-PART-01` | nonzero, no output | final absent; empty private root removed |
| `AWS-PART-02` | nonzero, ordinary partial | final absent; exact partial/root removed |
| `AWS-PART-03` | nonzero, substituted/extra entry | final absent; uncertain root retained |
| `AWS-PART-04` | zero, invalid state | final absent; ordinary temporary state removed |
| `AWS-PART-05` | zero, valid state | one validated final; private root absent |
| `AWS-PART-06` | ordinary final sentinel exists before block start | exit `1`, `destination-preexisting`; provider/mktemp/publication counts `0`; sentinel identity/bytes/mode/mtime unchanged; no root/temp |
| `AWS-PART-07` | final absent at preflight; wrapper creates competing sentinel immediately before real `ln` | exit `1`, `publication-race`; provider/validator/publication counts `1`; competitor unchanged; exact validated temp/root retained |
| `AZURE-PART-01` | nonzero, no output | final absent; empty private root removed |
| `AZURE-PART-02` | nonzero, ordinary partial | final absent; exact partial/root removed |
| `AZURE-PART-03` | nonzero, substituted/extra entry | final absent; uncertain root retained |
| `AZURE-PART-04` | zero, invalid state | final absent; ordinary temporary state removed |
| `AZURE-PART-05` | zero, valid state | one validated final; private root absent |
| `AZURE-PART-06` | ordinary final sentinel exists before block start | exit `1`, `destination-preexisting`; provider/mktemp/publication counts `0`; sentinel identity/bytes/mode/mtime unchanged; no root/temp |
| `AZURE-PART-07` | final absent at preflight; wrapper creates competing sentinel immediately before real `ln` | exit `1`, `publication-race`; provider/validator/publication counts `1`; competitor unchanged; exact validated temp/root retained |
| `GCS-PART-01` | nonzero, no output | final absent; empty private root removed |
| `GCS-PART-02` | nonzero, ordinary partial | final absent; exact partial/root removed |
| `GCS-PART-03` | nonzero, substituted/extra entry | final absent; uncertain root retained |
| `GCS-PART-04` | zero, invalid state | final absent; ordinary temporary state removed |
| `GCS-PART-05` | zero, valid state | one validated final; private root absent |
| `GCS-PART-06` | ordinary final sentinel exists before block start | exit `1`, `destination-preexisting`; provider/mktemp/publication counts `0`; sentinel identity/bytes/mode/mtime unchanged; no root/temp |
| `GCS-PART-07` | final absent at preflight; wrapper creates competing sentinel immediately before real `ln` | exit `1`, `publication-race`; provider/validator/publication counts `1`; competitor unchanged; exact validated temp/root retained |

Each row also asserts provider argv/version ID, phase/status, temporary/final
identity tuple, required diagnostics, and unchanged outside sentinels. For
each `07`, the wrapper records NUL-safe argv, delegates the unchanged
`ln --no-target-directory -- "$recovery_temp" "$recovery_path"` call to real
GNU `ln`, and proves that call returned nonzero. The retained root contains
exactly one validated ordinary non-link temporary whose identity and bytes
differ from the competing final; no cleanup unlink or `rmdir` succeeds. The
harness rejects missing, duplicate, unexpected, or multiply emitted IDs and
rejects any expected field containing an alternative, wildcard, or
provider-dependent branch. Shared fixture functions are permitted; provider
identity is not collapsed.

Provider cases:

- exact S3 key filter, unchanged `AWS_S3_VERSION_ID`, expected flags, and no provider
  call before validation;
- exact Azure filter, unchanged `AZURE_STORAGE_VERSION_ID`, `--overwrite false`, and
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

Invoke the exact harness as a stable step in the callable Ubuntu
`.github/workflows/markdownlint.yml` validation workflow after clean install
and both lint surfaces. The T1B event-owning `build.yml` job therefore gates
the same event SHA on this result. Preserve merged:

- exact hosted Node `24.18.1`/npm `11.16.0` and disabled automatic
  package-manager cache;
- exact action pins/role allowlist;
- read-only permissions;
- the local `workflow_call` boundary and event-owner triggers;
- helper harness step; and
- one ordinary Ubuntu job.

Do not add an external action or a separate workflow. Update the exact
step/job/role fixtures in `Validate-WorkflowPolicy.mjs` atomically; do not add a
cross-workflow `needs` edge.

## Local validation

Resolve one Node and npm application pair. Prove npm's actual
`process.execPath`/`process.versions.node` matches exact Node `24.18.1` and npm
`11.16.0`. Record paths and full versions.

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
6. require the complete working path set to equal the nine affected files;
7. stage exactly those nine paths;
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
- [ ] Every direct destination leaf satisfies the exact shared 1–128-byte
      grammar and every public provider input is snapshotted once, unset, and
      used unchanged through its closed provider construction.
- [ ] Every recovery/HCP parent has the exact attestation literal plus the
      independently inspected canonical/direct-child/owner/mode/type subset;
      tests never claim to prove the real-world no-competitor assertion.
- [ ] HUP, INT, and TERM return exactly 129, 130, and 143 through one EXIT
      cleanup owner; cleanup runs once and never replaces a primary nonzero
      status.
- [ ] Cleanup uses the closed waited-producer inspection state machine,
      authorizes no deletion before inspection completes, classifies every
      fallible operation/diagnostic, and retains every uncertain root.
- [ ] Discovery and recovery remain separate and selection is deliberate.
- [ ] S3 exact-key, bucket-class, versioning, KMS, and permission guidance is
      internally consistent.
- [ ] Azure exact-name, role, versioning, HNS, and `--overwrite false`
      guidance is correct.
- [ ] GCS uses `gcloud storage`, distinguishes Object Versioning/soft delete,
      and requires canonical positive generation passed unchanged.
- [ ] HCP uses the correct state-versions endpoint, filters, pagination, closed
      US/EU hosts, protected config/response files, and closed token grammar.
- [ ] Every provider identifier satisfies its exact field-specific ASCII/length
      subset and reaches provider argv byte-for-byte unchanged.
- [ ] No token appears in command arguments, trace, logs, files other than the
      short-lived protected config, or artifacts.
- [ ] Every exact block passes syntax and mandatory non-network behavioral
      cases in the tracked harness.
- [ ] Every AWS/Azure/GCS `*-PART-*` row proves the exact success, ordinary
      failure cleanup, uncertainty retention, preexisting-final `06`, and
      publication-race `07` postcondition with one oracle per ID.
- [ ] Provider, published, retained, and HCP response files satisfy the exact
      numeric state-file identity tuple at every boundary, including link-count
      `1→2→1` for successful hard-link publication.
- [ ] The permanent harness runs in the callable same-run read-only Ubuntu
      validation gate.
- [ ] Both source files and all four generated files advance consistently and
      pass LF/BOM/lint/idempotence checks.
- [ ] Local npm validation uses one resolved pair and restores `CI`.
- [ ] All affected-path layers use the merged NUL-byte parser and distinguish
      native Git status 0, 1, and tool/start failure.
- [ ] The adjacent destructive-state inventory is explicit and linked to T4.
- [ ] The workflow-policy validator recognizes the exact new stable step
      without changing the T1B event/permission/writer topology.
- [ ] The changed/staged set equals the nine affected files.

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
- [GNU ln](https://www.gnu.org/software/coreutils/manual/html_node/ln-invocation.html)
- [GNU mktemp](https://www.gnu.org/software/coreutils/manual/html_node/mktemp-invocation.html)
- [Terraform show](https://developer.hashicorp.com/terraform/cli/commands/show)
