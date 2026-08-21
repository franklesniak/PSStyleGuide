<!-- markdownlint-disable MD013 -->

# Make manual state backup and destructive recovery guidance copy-safe

## Summary

Replace truncating manual-backup redirections and unguarded destructive state commands with a small, explicit operational workflow:

1. capture a current state snapshot into a protected temporary file;
2. validate the Terraform exit, state format, lineage, serial, and digest;
3. publish the backup to a fresh path without overwrite;
4. verify exact workspace/backend/concurrency identity;
5. preview and review the intended mutation;
6. require an explicit human confirmation bound to that identity;
7. run without force or lock bypass; and
8. verify the result and retain a tested recovery point and procedure.

Prefer declarative Terraform workflows (`removed`/`moved`/`import` blocks, normal plan/apply, provider-version rollback) over manual state mutation whenever they can express the operation.

## Dependencies and order

Implement after:

1. **Make state-version discovery and recovery examples copy-safe with guarded identifiers**; and
2. **Remediate Markdown lint dependency advisories and add npm update governance**.

The state-recovery dependency supplies the canonical protected-destination primitive and exact-block harness. T3 completes before this issue to avoid simultaneous changes to shared generated documentation and the callable Markdown workflow.

Record real blocked-by relationships and exact merge commits.

### Mandatory internal review gates

T4 remains one issue but has two separately approved evidence gates.

**Gate A — nonmutating foundation:** implement and freeze only protected parent/path inspection, state-pull capture/publication, state inspection, difference review, address parsing/resolution, confirmation construction/read, case catalog, and their no-mutation harnesses. Record the reviewed commit/tree, every helper version/blob/SHA-256, exact role-table version, catalogs/results, platform/runtime/tool identities, and an operator plus independent peer approval. Gate A fixtures prove mutation child-call count is zero.

**Gate B — destructive procedures:** may start only from Gate A's exact immutable identities and approvals. Any Gate A code, role, schema, path, limit, confirmation, or evidence change invalidates approval and returns to Gate A. Gate B adds/reviews push, rm, recovery, post-mutation verification, and failure/unknown-outcome handling; it records a second operator/independent-peer approval bound to the Gate A digest and final reviewed commit. No issue/PR approval, passing lint, or author self-review substitutes for either gate.

## Affected files

Exactly these sixteen files may change:

Source files:

- `STYLE_GUIDE.md`;
- `STYLE_GUIDE_RATIONALE.md`.

Generated files:

- `copilot-instructions.md`;
- `terraform.instructions.md`;
- `STYLE_GUIDE_CHAT.md`;
- `STYLE_GUIDE_FULL.md`.

Permanent test integration:

- `.github/workflows/Test-StateRecoveryExamples.sh`;
- `.github/workflows/Test-StateRecoveryPowerShell.ps1` — add;
- `.github/workflows/Confirm-StateMutation.mjs` — add;
- `.github/workflows/Inspect-TerraformState.mjs` — add;
- `.github/workflows/Review-TerraformStateDifference.mjs` — add;
- `.github/workflows/Prepare-TerraformStateRecovery.mjs` — add;
- `.github/workflows/Resolve-TerraformStateAddress.mjs` — add;
- `.github/workflows/StateRecoveryCaseCatalog.json` — add;
- `.github/workflows/markdownlint.yml`; and
- `.github/workflows/Validate-WorkflowPolicy.mjs`.

Do not hand-edit generated files.

## Source inventory and consolidation

Inventory both authoritative source files for:

- `terraform state pull`;
- shell/PowerShell redirection to state backup paths;
- `terraform state push`;
- `terraform state rm`;
- `terraform force-unlock`;
- `mv`/copy/rename of `terraform.tfstate`;
- manual recovery/rollback;
- duplicate S3/Azure/GCS/HCP version examples; and
- state backup files created by modifying subcommands.

Classify every occurrence as:

- canonical copyable block owned here;
- concise cross-reference to T2/provider-specific retrieval;
- declarative alternative;
- warning/non-command explanation; or
- removed obsolete duplicate.

Do not retain an older unsafe copy after adding a safe canonical block.

Add unique, nonnested invisible marker pairs and stable IDs:

| ID | Canonical behavior |
| --- | --- |
| `SM-BACKUP-PULL` | Bash capture, validation, and fresh backup publication |
| `SM-BACKUP-PULL-PS` | cross-edition PowerShell equivalent |
| `SM-LOCAL-CORRUPTION` | preserve a local corrupt state file without clobber |
| `SM-STATE-PUSH` | guarded exceptional manual state push |
| `SM-STATE-RM` | guarded state-forget workflow with dry run |

The exact marker inventory, source blocks, generated copies, and harness tests must be equal.

## Common safety model

All blocks require:

- their named interpreter and explicitly resolved `terraform`; `jq`/digest tools where named;
- a protected operator-owned directory outside Git and shared world-readable temporary locations, under the exact platform contract below;
- fresh absolute destination paths;
- both `-e` and `-L` rejection for every final destination;
- no competing process able to replace entries in the protected directory;
- state treated as secret;
- exact native exit capture;
- no command strings or `eval`;
- no recursive/wildcard cleanup;
- exact-path cleanup only for ordinary files created by the block; and
- stable diagnostics that never print state or signed URLs.

The filesystem checks are not a universal adversarial-filesystem sandbox. Refuse operation when ownership, type, link status, or backend concurrency is uncertain.

For POSIX, set `umask 077` before creation and inspect—not infer—the canonical ordinary non-link parent as effective-UID-owned mode exactly `0700` and every state temporary/final as effective-UID-owned mode exactly `0600`.

For Windows, accept only an existing local NTFS/ReFS parent outside repository/ shared roots. Owner is the current process-token user SID. Its DACL is canonical and protected, contains no inherited or deny ACE, and contains exactly three explicit `FullControl` allows: current user SID, LOCAL SYSTEM `S-1-5-18`, and BUILTIN Administrators `S-1-5-32-544`, inheritable to child containers/objects. Immediately after `CreateNew`, while the handle remains exclusive, set and inspect a protected file DACL with inheritance removed and the same three explicit noninheriting allows. Reinspect temporary/final after publication and final after temporary-name removal.

Use SID-based .NET access-control APIs: `WindowsIdentity.GetCurrent().User`, `GetAccessControl`/`SetAccessControl` (or the corresponding `FileSystemAclExtensions` methods), `SetOwner`, `SetAccessRuleProtection($true,$false)`, `FileSystemAccessRule`, `GetOwner`, `AreAccessRulesProtected`, `AreAccessRulesCanonical`, and `GetAccessRules`. Do not parse localized account names, `icacls`, or infer success from the setter. Any mismatch before pull stops; after candidate creation, remove only a still-proven owned unpublished file and otherwise retain the uncertain root.

The Bash blocks require the exact tested Bash contract from T2. The PowerShell block requires Windows PowerShell exactly 5.1 or PowerShell major 7 on Windows and uses no ordinary native-output redirection. Both models protect against ordinary principals; Administrators/SYSTEM retain normal authority, so the operator also attests no authorized competing process.

### Complete state-bearing role authority

`T4-STATE-ROLES-v1` is the sole allocation. “Private” means a helper creates the path only beneath the already validated named invocation-context parent; it is never a caller value or ambient temporary path. `S` is the selected raw state maximum (`536870912` by default); `R` is 16 MiB; `M` is 65,536 bytes.

| Role | Creator → sole consumer | Parent/path/attestation authority | Identity, content, and bound | Lifetime, cleanup, failure postcondition |
| --- | --- | --- | --- | --- |
| Standalone final backup | pull publisher → operator/recovery | `STATE_BACKUP_PARENT` / `STATE_BACKUP_PATH` / `STATE_BACKUP_PARENT_ATTESTATION` | new ordinary protected file; strict state; `1..S` | retained recovery point; never auto-delete; failed publication leaves final absent |
| Standalone capture temp | pull publisher → state inspector/final publisher | private under standalone invocation context | create-new ordinary same-device file; raw pull; `0..S+1` | unlink only while exact owned unpublished identity; uncertainty retains context |
| Local corrupt preservation | no-replace local publisher → operator | `LOCAL_CORRUPT_PARENT` / `LOCAL_CORRUPT_PATH` / `LOCAL_CORRUPT_PARENT_ATTESTATION` | existing corrupt-source identity to new ordinary protected destination; `1..S` | retained incident evidence; no overwrite/delete on ambiguity |
| Push proposed source | operator → difference review/one push | `PUSH_PROPOSED_PARENT` / `PUSH_PROPOSED_PATH` / `PUSH_PROPOSED_PARENT_ATTESTATION` | existing immutable reviewed strict state; `1..S` | retained until verified disposition; mutation never edits/deletes it |
| Push current backup | pull publisher → diff/recovery | `PUSH_BACKUP_PARENT` / `PUSH_BACKUP_PATH` / `PUSH_BACKUP_PARENT_ATTESTATION` | fresh strict pre-push state; `1..S` | retained recovery point; failed pull leaves final absent |
| Push verification pull | pull publisher → inspector/diff | `PUSH_VERIFY_PARENT` / `PUSH_VERIFY_PATH` / `PUSH_VERIFY_PARENT_ATTESTATION` | fresh strict post-push state; `1..S` | retained with change record; uncertain push retains all evidence |
| Push difference report | difference helper → peer/confirmation | `PUSH_REVIEW_PARENT` / `PUSH_REVIEW_PATH` / `PUSH_REVIEW_PARENT_ATTESTATION` | new canonical state-derived report with no state values; `1..R` | retained review evidence; partial output removed only under exact ownership |
| Rm current backup | pull publisher → recovery/peer | `RM_BACKUP_PARENT` / `RM_BACKUP_PATH` / `RM_BACKUP_PARENT_ATTESTATION` | fresh strict pre-rm state; `1..S` | retained recovery point; failed pull leaves final absent |
| Rm command backup | Terraform local-mode rm → inspector | `RM_COMMAND_BACKUP_PARENT` / `RM_COMMAND_BACKUP_PATH` / `RM_COMMAND_BACKUP_PARENT_ATTESTATION` | absent ordinary path becoming strict local command backup; `1..S` | local mode only; retain after call; ambiguity stops without retry |
| Rm exact-match capture | bounded list collector → address resolver | `RM_MATCH_PARENT` / `RM_MATCH_PATH` / `RM_MATCH_PARENT_ATTESTATION` | new ordinary exact address plus LF; `1..M`, at most 1,024 records | remove after resolver/confirmation only under exact identity; otherwise retain |
| Rm resolver report | address resolver → peer/confirmation | `RM_REPORT_PARENT` / `RM_REPORT_PATH` / `RM_REPORT_PARENT_ATTESTATION` | new canonical metadata-only singleton report; `1..R` | retained review evidence; partial removed only while exact owned |
| Rm verification pull | pull publisher → inspector/post-plan | `RM_VERIFY_PARENT` / `RM_VERIFY_PATH` / `RM_VERIFY_PARENT_ATTESTATION` | fresh strict post-rm state; `1..S` | retained with change record; unknown outcome retains all evidence |
| Recovery desired backup | operator → recovery preparer/diff | `RECOVERY_DESIRED_PARENT` / `RECOVERY_DESIRED_PATH` / `RECOVERY_DESIRED_PARENT_ATTESTATION` | existing immutable reviewed strict state; `1..S` | retained recovery source; never modified/deleted by helper |
| Recovery fresh remote | pull publisher → preparer/diff | `RECOVERY_CURRENT_PARENT` / `RECOVERY_CURRENT_PATH` / `RECOVERY_CURRENT_PARENT_ATTESTATION` | fresh strict authoritative state; `1..S` | retained until operation closes; drift restarts review |
| Recovery candidate | recovery preparer → diff/one push | `RECOVERY_OUTPUT_PARENT` / `RECOVERY_OUTPUT_PATH` / `RECOVERY_OUTPUT_PARENT_ATTESTATION` | new strict state differing only by canonical serial token; `1..S` | retained until verified; partial removed only while exact owned |
| Recovery preparation report | recovery preparer → peer/confirmation | `RECOVERY_REPORT_PARENT` / `RECOVERY_REPORT_PATH` / `RECOVERY_REPORT_PARENT_ATTESTATION` | new canonical metadata-only report; `1..R` | retained review evidence; uncertainty retains output and report |
| Recovery verification pull | pull publisher → inspector/diff | `RECOVERY_VERIFY_PARENT` / `RECOVERY_VERIFY_PATH` / `RECOVERY_VERIFY_PARENT_ATTESTATION` | fresh strict post-recovery state; `1..S` | retained with incident record; unknown outcome never auto-rolls back |
| Inspector/show private streams | inspector context → tokenizer/result | private under the exact caller role's invocation context | create-new raw/show streams; raw `0..S+1`, show per selected limit | always exact-owned cleanup after result; identity/cleanup uncertainty retains context |

Every attestation is exactly `private-outside-vcs-no-competing-writers`. It means the operator reviewed OS/storage evidence and asserts the parent is private across relevant principals/mount layers, outside version control/shared temporary storage, and has no active authorized entry mutator. Code proves only the applicable owner/mode/DACL/type/reparse/device/direct-child subset and reports `operator-attested`, never “machine verified.”

Each block snapshots applicable public values once, makes locals immutable, and removes public names from child environments. Missing and empty are distinct fixtures but both reject. There is no `dirname`, current-directory, repository-root, or temporary-directory fallback. Require literal equality first and then prove the path is exactly one direct child of its separately supplied canonical parent under T2's destination-leaf grammar. String-prefix or nested containment is invalid. Distinct roles stay distinct even when parent bytes match.

Standalone, backup, command-backup, match/report, recovery output/report, and verification destinations are fresh. Proposed/desired inputs are existing strict protected identities. Unknown roles, a public path for a private role, tuple reuse by inference, or omitted lifetime/cleanup evidence fails the role catalog. Verification always uses a new path.

### Backend-specific state-rm mode

Before any rm capture or dry run, snapshot and validate exactly one `STATE_BACKEND_MODE` value: `local`, `hcp-cloud`, or `remote-backend`. Bind it to the reviewed initialized backend configuration, exact workspace, `EXPECTED_BACKEND_ID`, Terraform executable/version, and Gate A evidence. Every mode first creates the protected `RM_BACKUP_PATH` with `terraform state pull` and proves its state identity. Missing, ambiguous, changed, or mismatched mode stops before confirmation/mutation.

The single mutation argv is constructed from the selected closed mode:

| Mode | Exact state-rm argv after resolved Terraform executable |
| --- | --- |
| `local` | `state rm -backup=<RM_COMMAND_BACKUP_PATH> -lock-timeout=5m <RESOURCE_ADDRESS>` |
| `hcp-cloud` | `state rm -lock-timeout=5m <RESOURCE_ADDRESS>` |
| `remote-backend` | `state rm -lock-timeout=5m <RESOURCE_ADDRESS>` |

`<...>` denotes one already validated argv element, never shell text. The local-only backup option is permitted only after the pinned version's `terraform state rm` help/official contract is revalidated and its separate fresh command-backup tuple is proved. HCP/remote construction cannot contain `-backup` and relies on the protected pre-mutation pull recovery point. Unknown-option, nonzero, signal, timeout, or unknown/partial outcome is one terminal mutation attempt: never retry with a different argv or backend mode.

For each role/platform, atomic cases cover missing, empty, wrong literal, parent/path mismatch, nested path, sibling prefix, wrong owner/mode/DACL/type/ reparse/device, repository/shared-root membership, existing destination, and unsupported inspection. A fixture-declared false but syntactically valid attestation proves only literal acceptance is recorded. Rejection returns phase-appropriate `64`/`65`, invokes no state/confirmation/mutation child, creates no path, and preserves sentinels.

## Exact identity, confirmation, decoding, and review contracts

### Backend, label, digest, and terminal confirmation grammar

`EXPECTED_BACKEND_ID` is exactly `backend-v1:<type>:<authority>:<scope>`. Each component is 1–63 ASCII bytes and matches `[a-z0-9](?:[a-z0-9._-]{0,61}[a-z0-9])?`; total length is at most 202. The exact derivation is `10-byte "backend-v1" + 3 colon bytes + 3 × 63-byte components = 202 bytes`; the reachable minimum is 16. Reject uppercase, whitespace/control/Unicode, slash/backslash/percent, empty/additional component, or leading/trailing punctuation. Grammar success does not prove identity; the value remains operator-attested.

Validation order is fixed: require a raw string; reject control/non-ASCII; split literal `backend-v1` plus exactly three components; validate each component's 1–63-byte length and shape; then require whole length 16–202. Bash sets `LC_ALL=C`; PowerShell rejects non-ASCII before counting original bytes rather than using general string character length. Stable cross-platform rows cover total lengths 16, 201 (`63,63,62`), 202 (`63,63,63`), and 203 (`63,63,64`), plus a distinct 64-byte type, authority, and scope; empty/missing/ fourth components; non-ASCII; and leading/trailing punctuation. The 203 and each component-overflow case reject `backend-component-too-long` before a Terraform or filesystem call. Structural validation rejects any remaining backend-ceiling literal `206`.

For these copyable blocks, workspace is the deliberate safe subset `[A-Za-z0-9][A-Za-z0-9._-]{0,89}`. An unsupported historical name stops for a separate reviewed procedure. Optional `OPERATION_LABEL` is absent/empty or a real UTC instant `yyyyMMdd'T'HHmmss'Z'`, hyphen, and a 1–32-byte lowercase slug matching `[a-z0-9](?:[a-z0-9-]{0,30}[a-z0-9])?`; complete length is at most 49 and it never affects a path/command.

A tool-computed SHA-256 must first be exactly 64 ASCII hex, map `A-F` to `a-f`, then match `[0-9a-f]{64}`. User confirmation is never normalized and contains exactly its first 16 lowercase characters.

Generate one compact BOM-less UTF-8 JSON confirmation line:

- push: `["state-push","<workspace>","<backend>",<currentSerial>,<proposedSerial>,"<proposedDigest16>"]`;
- rm: `["state-rm","<workspace>","<backend>","<exactResourceAddress>","<backupDigest16>"]`.

Add dependency-free `.github/workflows/Confirm-StateMutation.mjs`, versioned and hash-recorded, exporting:

```text
serializeConfirmation(fields) -> Buffer
classifyConfirmationBytes(expectedBuffer, deliveredBuffer) -> closed result
readAndConfirm(fields, terminalAdapter) -> closed result
```

The production CLI exposes only `readAndConfirm`; there is no stdin, file, or fixture override. Its exact ordered interfaces are:

```text
node Confirm-StateMutation.mjs --operation state-push
  --workspace W --backend B --current-serial C --proposed-serial P --digest D

node Confirm-StateMutation.mjs --operation state-rm
  --workspace W --backend B --resource-address A --digest D

node Confirm-StateMutation.mjs --operation state-recovery-push
  --workspace W --backend B --current-serial C --recovery-serial R
  --desired-digest DD --recovery-digest RD
```

Options occur once with separate nonempty values; there are no aliases, positionals, environment fallbacks, unknown options, or command strings. The helper independently enforces the workspace, backend, serial, digest, and canonical resource-address grammars. It constructs a new array, applies ECMAScript `JSON.stringify` without replacer/spacing, encodes once with `TextEncoder`, proves strict UTF-8 round-trip, and requires 1–4,096 bytes. Only the first 16 characters of the once-lowercased exact 64-hex digest enter. No final newline is serialized.

The recovery array is `["state-recovery-push",W,B,C,R,DD[0:16],RD[0:16]]`; it follows the same serializer and terminal lifecycle and has its own atomic catalog rows.

The helper ignores redirected standard streams. POSIX opens `/dev/tty` read/write and proves TTY identity; Windows opens `CONIN$`/`CONOUT$` and proves console identity. It never falls back. It writes the expected line exactly once to the controlling terminal, remembers terminal mode, installs supported restoration handlers, enters raw no-echo mode, and accumulates Buffer chunks. The first CR or LF terminates without joining the payload; LF immediately after CR is the same CRLF terminator. Any other already-delivered byte after the terminator—including a second terminator—is `confirmation-second-record`. Drain through the current libuv poll turn so already queued bytes reject.

Byte 4,097 is `confirmation-overflow`. Before equality reject EOF before a terminator, NUL, UTF-8/UTF-16 BOM, malformed/incomplete UTF-8, or extra record. Compare only with `Buffer.equals`. There is no trim, normalization, case fold, retry, partial match, or returned/recorded typed bytes. In `finally`, restore the exact prior terminal mode, remove handlers, destroy streams once, and close descriptors once. Read/write/mode/restore/close uncertainty is status `68`; HUP/INT/TERM restore first and return `129/130/143`. Success is `0`; every nonzero result precedes and excludes the destructive child.

Bash invokes an exact Node/helper path with fixed quoted argv. PowerShell uses `ProcessStartInfo(UseShellExecute=false)`, `ArgumentList` on 7 and the reviewed literal argument encoder on 5.1. Neither caller serializes JSON or reads the confirmation. Safe evidence records helper version/hash, operation fields, and reason, never the expected or delivered line.

Whole-block statuses are: `64` input grammar, `65` environment/identity, `66` snapshot/parse, `67` review/diff, `68` confirmation, `69` lock/exclusion, `70` Terraform mutation, `71` post-verification, `72` cleanup/uncertain state, and `73` stderr overflow. Confirmation mismatch is exactly `68`, starts no destructive child, and leaves all sentinels unchanged.

### Shared streaming state capture and inspection

Add dependency-free `.github/workflows/Inspect-TerraformState.mjs`, versioned `Inspect-TerraformState.v1`. It exports the same streaming tokenizer/metadata core used by its CLI. Bash and PowerShell retain platform-specific protected path/identity acquisition, but neither implements child stream limits or raw state JSON parsing.

The default limit profile is:

| Limit | Exact value |
| --- | ---: |
| Raw state bytes | `536870912` |
| `terraform show -json` bytes | `2147483648` |
| Terraform deadline ms | `900000` |
| TERM grace ms | `5000` |
| Retained stderr bytes | `65536` |
| JSON nesting | `256` |
| Total JSON values | `10000000` |
| Properties per object | `100000` |
| Items per array | `2000000` |
| Raw string-token bytes | `16777216` |
| Raw number-token bytes | `128` |

`STATE_LIMIT_PROFILE` is absent/`default-v1` or `reviewed-large-state-v1`. The latter additionally requires canonical positive safe integers `STATE_MAX_BYTES` (`536870913..2147483648`), `STATE_SHOW_JSON_MAX_BYTES` (at least state limit, at most `8589934592`), and `STATE_TOOL_TIMEOUT_MS` (`900001..3600000`); a 1–64 safe-ASCII `STATE_LIMIT_REVIEW_ID`; and exact `STATE_LIMIT_REVIEW_ATTESTATION=reviewed-capacity-and-large-state-v1`. Missing/extra-in-default, signs, leading zeros, whitespace, exponent, unsafe/ inconsistent/hard-cap values fail before creation. Record observed size, growth, protected-volume capacity, limits, latency, operator/peer, and incident/change ID as operator-reviewed. There is no unlimited profile. Before capture, platform-native available space must be at least selected raw maximum plus 64 MiB reserve.

Closed modes `capture` and `validate` receive exact Terraform path, state path, profile values, and working-directory identity as separate argv values. No environment fallback, shell, stdin, user command, or arbitrary Terraform argument exists. Capture reopens the caller-created exact zero-length candidate without truncation and spawns only `terraform state pull`; validate spawns only `terraform show -json <exact-state-path>`. Both use `shell:false`, closed stdin, concurrent raw Buffer stdout/stderr drains, writable backpressure, saturated limit+1 counters, and a distinct start/exit/signal/timeout/TERM/KILL/read/write/ close outcome.

At state/show byte limit+1, stderr byte 65,537, stream error, or deadline, stop writes, TERM the exact process/group, wait 5,000 ms, KILL if needed, and keep draining/discarding to close. Stderr is never persisted, decoded, or emitted. Its overflow is status `73`; state overflow, timeout, start/read/write/close, empty output, nonzero, or signal is `66`. No success exists until child close, output flush/close, and caller identity reinspection. Result output contains only safe profile, saturated counts, native outcome, termination phase, metadata/digest on success.

The tokenizer consumes raw Buffer chunks and rejects UTF-8/UTF-16 BOM, invalid/incomplete UTF-8, unescaped NUL, grammar error, second value, non-whitespace suffix, duplicate decoded object key, or any ceiling. It never constructs resource values/secret strings as a general object graph. Raw-state format `4` projects exactly one top-level `version:4`, canonical Terraform version, canonical safe-integer `serial`, and 1–128 safe-ASCII `lineage`; other fields are validated but not retained. Show JSON requires supported `format_version` major `1` and canonical Terraform version; unknown properties under a supported minor are allowed only after full strict validation. Hash the original state incrementally without re-encoding.

Atomic cases cover every profile/number boundary, state/show byte limit−1/ limit/limit+1, deadline/TERM/KILL, simultaneous/backpressure/stream/close failure, every UTF-8/BOM/suffix class, each parser limit at/over, duplicate keys at each layer, metadata missing/duplicate/type/range, raw version `4` versus unsupported, and show `1.x` versus `2.x`. Every result asserts status/phase, termination calls, retained count, file identity/postcondition, no secret output, and unchanged remote state.

### Windows canonical path, reparse, file-ID, and hard-link mechanics

Use one fixed C# `Add-Type` Win32 helper on both PowerShell editions. Accept only a fully qualified local drive path; reject relative, UNC/device/extended- device/provider/ADS/extra-colon/wildcard/control/trailing-file-separator syntax. Call `Path.GetFullPath` once and use only that canonical path.

Walk every existing component to the protected parent using `CreateFileW(OPEN_EXISTING)` with `FILE_FLAG_OPEN_REPARSE_POINT` and `FILE_FLAG_BACKUP_SEMANTICS` for directories. Inspect `FILE_ATTRIBUTE_TAG_INFO`, normalized handle path, type, and volume; reject any reparse/non-directory/open/attribute/path mismatch. Treat any ordinary, directory, live/dangling reparse, or indeterminate leaf as existing; a `Test-Path` false result is not absence proof.

After `FileMode.CreateNew`/write-only/`FileShare.None`, retain `SafeFileHandle` and inspect `FileAttributeTagInfo`, `FileIdInfo`, and link count from `GetFileInformationByHandle`. Require ordinary non-reparse, protected-parent volume, and exactly one link. Identity is opaque `(VolumeSerialNumber,128-bit FileId)`.

Publish exactly once with `CreateHardLinkW(final,temp,NULL)`. Microsoft documents this primitive as NTFS-only; a ReFS parent may satisfy the ACL/file-ID inspection but must take the explicit unsupported-publication failure path with final absent and validated temporary retained. No PowerShell `-Force`, fallback, copy/move/delete/recreate/retry/alternate name. Open both names no-follow and require ordinary type, equal volume/file ID, link count `2`, length/digest/ACL equality; then unlink exact temp, reopen final, and require the original identity with link count `1`. Unsupported/ambiguous API, filesystem, ID, or link count fails closed. An initial link count above one proves an undisclosed hard link.

These handle checks prove inspected file identity, not an adversarial `openat`-style namespace sandbox. T4's protected DACL and no-authorized- competitor attestation are mandatory on both editions; if unavailable, refuse.

### Offline secret-safe state-difference review

Add dependency-free `.github/workflows/Review-TerraformStateDifference.mjs`, versioned `Review-TerraformStateDifference.v1`. It imports, and cannot raise, the `Inspect-TerraformState.mjs` tokenizer/limits. Its only ordered CLI is:

```text
node Review-TerraformStateDifference.mjs
  --manifest MANIFEST
  --configuration-root ROOT
  --current-state CURRENT
  --current-show CURRENT_SHOW
  --proposed-state PROPOSED
  --proposed-show PROPOSED_SHOW
  --provider-schema PROVIDER_SCHEMA
  --output REPORT
```

There are no aliases, environment paths, network calls, stdin, arbitrary Terraform arguments, or value-output mode. All seven inputs and fresh report are separately proven protected ordinary non-link identities. Show and `terraform providers schema -json` captures use the same bounded collector, Terraform executable/version, strict JSON, and a no-network attestation.

The BOM-less strict manifest is `TerraformStyleGuide.StateDifferenceReview.v1`, at most 16 MiB, depth 32, 100,000 rows, 4,096 bytes per safe string, with duplicate rejection and exactly these closed sections:

1. review ID/time/operator/peer/change reference and literal `reviewed-exact-configuration-schema-and-change-set-v1`;
2. helper/Terraform hash/version and limit profile;
3. Git object format, full commit/tree, sorted tracked configuration path/mode/blob/working-hash rows, lockfile hash, and clean stage-0 index/ worktree/untracked proof;
4. local/remote module key/source/version/resolved directory/canonical tree hash rows;
5. hashes/counts/format metadata for both raw states, both show documents, provider schema, and lockfile;
6. provider source, lock version/checksums, schema key/version, and reviewed alias/module configuration identities;
7. opaque safe resource/output subject IDs with exact reviewed address, mode, type, name, provider/config/schema/instance identities or output type/sensitivity;
8. safe manifest path IDs for schema/configuration-known paths; dynamic elements collapse to their nearest reviewed schema path; and
9. a sorted unique exact allowance set of `(subjectId,pathId,oldKind,newKind,change,sensitivity)`.

The helper proves Git root/commit/tree, HEAD/stage-0/no-filter working bytes, absence of untracked Terraform configuration, module tree hashes, lock/input/ tool/provider identities. It does not parse HCL and labels subject/path truth `operator-and-peer-reviewed`.

Require exact manifest identities for every show resource/output, provider configuration, instance key, schema version, and schema row. Unknown or unsafe identity becomes only `unreviewed-identity-present`. Lineage must match. Equal raw-state hashes yield `identical` with no rows; unequal hashes with no semantic row yield `serialization-only-difference` and reject.

Generate a random 256-bit per-run HMAC key kept only in memory. If either provider schema or either `sensitive_values` tree marks a subtree sensitive, do not descend; HMAC canonical tokens and emit only `sensitive-subtree-changed` or no row. Reviewed non-sensitive paths retain only old/new JSON kind plus `added|removed|type-changed|value-changed|unchanged`. Dynamic/unknown keys or elements reject. Temporary indexes contain only manifest numeric IDs, enums, and HMACs, mode `0600`, and are deleted under exact identity proof; failure is status `67`.

Additional exact ceilings are index bytes `268435456`, rows `100000`, and report 16 MiB. The canonical report fields are:

```text
schemaVersion helperVersion reviewId configurationIdentity terraformVersion
currentMetadata proposedMetadata providerSchemaSha256 outcome rows counts
summarySha256
```

Rows contain only manifest labels/IDs, kinds, sensitivity, and change enum. No value, dynamic/state-derived identifier, raw/encoded fragment, length/ entropy clue, native diagnostic, stable leaf digest, HMAC, or index path may appear. `summarySha256` hashes all fields/rows except itself. Proceed only when observed changed rows equal allowances exactly and all provenance passes. Canary fixtures scan stdout, stderr, report, result objects, cleaned temp root, and artifacts for raw, Base64, hex, URL/JSON encoding, substring, and stable/ ephemeral hash leakage.

### T2 signal contract on every T4 Bash phase

Record the exact landed T2 commit/evidence and extend the same `Test-StateRecoveryExamples.sh` signal driver. Each T4 Bash block has distinct HUP/INT/TERM handlers returning `129/130/143` and one EXIT cleanup owner: capture primary first, disable EXIT, ignore further signals, cleanup once; primary nonzero wins, cleanup-only failure returns `1`.

Use synchronized barriers for each block/ownership phase and all three signals with cleanup success/failure. Before a push/rm child starts, interruption proves zero destructive calls. During/after start, remote outcome is `unknown`; retain backup/evidence, never retry/force/unlock/delete evidence/auto-rollback, and require incident/manual remote verification. Publication-window uncertainty retains names unless handle identity proves exact safe cleanup. Every case has one stable ID/result with signal/status/phase/cleanup count/path state/child count/remote sentinel. All prior T2 signal IDs remain unchanged and green.

## Requested changes

### 1. Publish manual backups only after validation

Replace every direct pattern like:

```text
terraform state pull > some-backup-path
```

with one canonical `SM-BACKUP-PULL` Bash block.

The block accepts once:

- `STATE_BACKUP_PARENT` — exact protected canonical parent;
- `STATE_BACKUP_PATH` — new absolute final path;
- `STATE_BACKUP_PARENT_ATTESTATION` — exact `private-outside-vcs-no-competing-writers`;
- `EXPECTED_TERRAFORM_WORKSPACE`;
- `EXPECTED_BACKEND_ID` — a nonsecret canonical **operator-attested backend identity** derived from separately reviewed backend configuration/account/workspace evidence; and
- an optional approved timestamp/operation label used only in diagnostics.

It must:

1. disable inherited xtrace before sensitive expansion;
2. validate the exact current workspace with `terraform workspace show`;
3. validate the supplied identifier's exact grammar and require the operator to compare the initialized backend configuration to it; label the result operator-attested, not mechanically derived;
4. validate fresh final path and protected ordinary parent;
5. create one unpredictable mode-0600 temporary file in the same parent;
6. invoke exact `Inspect-TerraformState.mjs` capture mode so only bounded raw Terraform stdout reaches that temporary identity;
7. require its closed native/process/stream outcome and reject empty/partial/ oversized output;
8. require its strict BOM-less UTF-8/JSON raw-state validation;
9. invoke its bounded validate mode for `terraform show -json <temp>`;
10. consume only its supported format, nonempty lineage, canonical safe-integer serial, recorded Terraform version, byte count, and digest metadata;
11. compute and record SHA-256 without printing state;
12. atomically create the final name without overwriting an existing filesystem entry—use `ln --no-target-directory <temp> <final>` without `--force`/`--backup` to create a same-filesystem hard link from the validated temporary inode, followed by exact temp unlink;
13. verify final inode/bytes/digest/mode and that it remains outside Git; and
14. emit only final path, workspace/backend labels, lineage, serial, digest, Terraform version, and UTC creation time.

If pull, validation, or publication fails, no final backup may exist. Remove only the exact verified ordinary temp file; otherwise retain uncertain state with a warning.

Require the protected temporary and final parent to be on the same filesystem. Attempt real hard-link publication once. If hard links are unsupported or the operation fails, do not fall back to copy, move, overwrite, delete/recreate, or an alternate final name. Leave the final path absent, retain the validated temporary backup as explicitly reported sensitive state, and tell the operator to select an access-controlled local filesystem plus a new absent final path. Unsupported publication is a failure, not a passing skip, on the declared hosted-runner filesystems.

Explain that `state pull` upgrades the returned snapshot to the newest format compatible with the locally installed Terraform. The backup is a validated recovery point, not necessarily a byte copy of backend storage.

Add one copyable `SM-BACKUP-PULL-PS` implementation with the same inputs, postconditions, and operator-attested backend language. It must:

1. resolve one ordinary non-reparse Terraform executable and use only fixed `state pull` arguments—no shell command string or user-controlled process arguments;
2. invoke the exact resolved Node and `Inspect-TerraformState.mjs` capture mode with fixed argv, `UseShellExecute = $false`, and no window;
3. call `Path.GetRandomFileName()` and acquire one absent same-parent temporary file through a `FileStream` opened with `FileMode.CreateNew`, write-only access, and `FileShare.None`; use a documented finite retry only for an actual create-new collision and fail immediately for every other error;
4. let the shared helper stream exact `state pull` stdout into the acquired identity, drain bounded stderr, apply deadline/termination/backpressure, and return one closed native outcome without exposing bytes;
5. reject every non-success/empty/partial/overflow result and require the caller to re-prove candidate identity;
6. dispose helper/process/stream objects before cleanup;
7. invoke shared validate mode, which performs complete strict raw UTF-8/JSON tokenization and bounded `terraform show -json`, then records only lineage, serial, format/Terraform version, byte count, and SHA-256;
8. publish once with the reviewed `CreateHardLinkW(final,temp,NULL)` interop primitive after repeated no-follow final-absence/type checks;
9. verify final bytes/digest/file identity, unlink only the temporary hard-link name, and retain the final validated backup; and
10. on failure, delete only a still-proven owned ordinary unpublished temporary file; retain and report every uncertain or publication-failed root.

Ordinary native `>`, `Out-File`, and `Set-Content` are prohibited for state capture. Windows PowerShell 5.1 treats native byte output as strings, while byte-preserving native redirection was introduced only in PowerShell 7.4; the single raw .NET stream algorithm avoids edition branches.

### 2. Guard local corruption preservation

`SM-LOCAL-CORRUPTION` replaces an unguarded:

```text
mv terraform.tfstate terraform.tfstate.corrupted
```

Add a distinct source tuple:

```text
LOCAL_CORRUPTION_SOURCE_PARENT
LOCAL_CORRUPTION_SOURCE
LOCAL_CORRUPTION_SOURCE_ATTESTATION
```

Source is a canonical absolute direct child of its separately snapshotted parent; neither is inferred from destination. The exact literal is `terraform-paused-no-open-state-writers-v1`. Before setting it, the accountable operator stops and verifies every Terraform/local-backend automation, CI agent, editor, recovery utility, scheduled task, and other possible open writer and prevents new writers through handoff. This is operator-attested. Lock-info absence, `lsof`, advisory lock, `chmod`, destination protection, or a quiet interval is never proof. The destination keeps the separate `private-outside-vcs-no-competing-writers` attestation.

The state machine:

1. snapshots all six source/destination tuple values once and validates them before touching paths;
2. requires a no-symlink source path and ordinary non-link source, effective UID, mode `0600`, link count `1`; records `(device,inode,uid,mode,nlink,size)` plus SHA-256 (zero size allowed);
3. proves the protected fresh destination is on the same device and absent under both existence/link tests;
4. rechecks source tuple/digest and destination absence immediately before one `ln --no-target-directory -- "$LOCAL_CORRUPTION_SOURCE" "$DESTINATION"`;
5. after success requires both names to have the original identity/size/digest and link count `2`, then repeats those checks immediately before unlink;
6. unlinks only the exact still-proven source once, reopens destination no-follow, and requires original identity/digest with link count `1`; and
7. releases source-writer exclusion only after final identity/digest and source-absent handoff.

All inspection uses the reviewed structured identity routine under `LC_ALL=C`; no corrupt bytes or localized `ls` are parsed/displayed. Before link failure leaves source and destination absent. Once a link may exist, failure deletes neither remaining name. Ambiguous source unlink retains destination and reports both path states. Any identity/digest change is an attestation breach, not permission to refresh expected values. No force, backup, fallback, alternate name, copy, rename, or retry is allowed.

Atomic cases cover source/destination type and identity, link count `0|1|2|many`, devices, empty/nonempty bytes, every destination conflict, writer opening/mutating at each barrier, source removal/substitution, link/ unlink nonzero/signal/unknown, each tuple/digest mismatch, exact `1→2→1`, unsupported filesystem/GNU behavior, cleanup, and every signal phase. Whenever publication began at least one name remains.

### 3. Put manual state push behind a closed checklist

HashiCorp recommends `terraform state push` only for necessary manual repair. The `SM-STATE-PUSH` section must first prefer:

- backend-native state-version rollback;
- HCP Terraform state rollback UI/API;
- a normal Terraform upgrade/downgrade workflow;
- `moved`/`import`/`removed` blocks; or
- vendor support/escalation.

If manual push remains necessary, require:

1. approved change/incident record and named operator/peer reviewer;
2. maintenance window with all automation and human applies paused;
3. verified backend lock support or a documented stronger external exclusion mechanism; if neither exists, stop;
4. exact initialized workspace equality and the same explicit operator-attested backend-identity review used by the backup;
5. a just-created `SM-BACKUP-PULL` backup of the current remote state;
6. current and proposed state both parse with the exact Terraform version;
7. recorded current/proposed lineage, serial, Terraform version, and SHA-256;
8. proposed lineage equals current lineage;
9. compare full raw-state SHA-256 first: byte-identical input is `no-change` with no confirmation/push; otherwise require supported format and exactly `proposedSerial = currentSerial + 1`, rejecting lower, equal, skipped, and safe-integer-overflow serials;
10. a reviewed state diff that exposes no unexpected resource binding/output/ provider-address changes and does not disclose secret values;
11. a tested reviewed recovery procedure; never promise a direct push of the lower-serial current backup;
12. a typed confirmation read from a controlling terminal containing the exact operation, workspace, operator-attested backend label, current serial, proposed serial, and exactly the first 16 lowercase hexadecimal characters of the reviewed proposed-state SHA-256; and
13. one command using the exact proposed path and exactly `-lock-timeout=5m`.

The command must not use:

- `-force`;
- `-ignore-remote-version`;
- `-lock=false`;
- stdin (`PATH=-`);
- an unquoted/relative path; or
- automatic retry after safety rejection.

The one mutation argv is exactly:

```text
terraform state push -lock-timeout=5m "$PUSH_PROPOSED_PATH"
```

It uses closed stdin and the separately validated proposed-state tuple.

Terraform's differing-lineage and higher-remote-serial checks remain enabled. Locking remains enabled where the backend supports it. Do not retry automatically. Distinguish lock acquisition failure from lineage/serial/input/provider failure. A safety-check or lock failure stops the procedure; it is not a prompt to add a bypass. If the backend does not support locking, record the backend-appropriate maintenance window/external exclusion and accountable owner before confirmation; do not claim the timeout supplies a lock.

The full digest is displayed separately. Confirmation input is read from a controlling terminal, follows one literal grammar, and is compared ordinally; do not trim or case-fold except where the grammar explicitly permits it. Empty, wrong-case, nonhex, short, long, extra-text, or mismatched confirmation fails before mutation.

After success:

- immediately pull to a new protected verification path;
- verify workspace/backend, lineage, expected serial behavior, and reviewed content;
- run `terraform plan` under the incident/change procedure;
- keep the pre-push backup according to policy; and
- use the tested reviewed recovery procedure only through a new incident, peer review, continuous exclusion, diff, and confirmation.

Continuous writer exclusion begins before the authoritative pull and remains held through post-push verification. It pauses named human and automated writers and has an accountable owner. A lock obtained only by `state pull` or `state push` does not protect the review gap. Intervening drift, lost exclusion, unknown child outcome, or verification mismatch stops without retry or automatic rollback.

Prefer the exact backend's tested immutable-version restore. The procedure records selected historical version, permission, lock/exclusion behavior, whether a new version is created, verification read, and ambiguous-failure action. HCP uses its workspace-locked rollback that duplicates the selected version as a new current version. Native recovery is still destructive and requires a fresh change record, operator/peer, current/desired identities, secret-safe diff, continuous exclusion, confirmation, one call, and fresh verification.

For a supported backend without native restore, add dependency-free `.github/workflows/Prepare-TerraformStateRecovery.mjs`, versioned `Prepare-TerraformStateRecovery.v1`, with only:

```text
node Prepare-TerraformStateRecovery.mjs
  --desired-backup DESIRED
  --fresh-remote CURRENT
  --output RECOVERY
  --report REPORT
```

Every input/output has its own protected parent/path/attestation tuple and uses `Inspect-TerraformState` limits. Require BOM-less strict format `4`, nonempty equal lineage, canonical serials, pinned Terraform rendering, exact input identities, and safe `current.serial + 1`. Locate the unique top-level serial token by streaming-parser byte offset, copy every desired-backup byte before it, write only the canonical decimal successor, and copy every byte after it to a fresh protected output. Never fully parse/re-emit the state. An independent stream comparison proves all non-serial bytes equal the desired backup, lineage is unchanged, successor serial exact, and validation passes.

The compact report contains only schema/helper versions, whole-file digests, lineage, desired/current/recovery serials, old/new token offset/length, byte counts, and `candidate-is-desired-except-serial`. It contains no state value, resource/output identity, fragment, native diagnostic, path, or neighboring bytes.

Review fresh remote versus recovery using the diff helper and a recovery-specific manifest. Pull authoritative state again before confirmation and require byte/digest/lineage/serial equality with the reviewed current. Then confirm `state-recovery-push` with workspace/backend, current/recovery serials, desired-backup digest prefix, and recovery digest prefix; execute one normal `state push -lock-timeout=5m` of the absolute recovery path; and verify fresh remote identity/content/diff before releasing exclusion. Drift restarts review, never in-place regeneration. Direct old-backup push, editor changes, full JSON reserialization, force/bypass, automatic retry/recovery, or proceeding after unknown outcome is prohibited.

### 4. Guard state removal and prefer `removed` blocks

State that `terraform state rm` forgets bindings but leaves remote objects; a later plan may attempt to create replacements and collide with them. Prefer declarative `removed` blocks when supported because they are reviewable through normal plan/apply.

For unavoidable `SM-STATE-RM`:

Add dependency-free `.github/workflows/Resolve-TerraformStateAddress.mjs`, versioned `Resolve-TerraformStateAddress.v1`. It exports `parseCanonicalResourceAddress(Buffer)`; the resolver and confirmation helper import that exact parser. Its only ordered CLI is:

```text
node Resolve-TerraformStateAddress.mjs
  --address RESOURCE_ADDRESS
  --matches MATCH_FILE
  --output REPORT
```

There are no aliases, stdin, environment fallback, network, Terraform execution, multiple-address, permissive, or normalization modes. Parse raw ASCII bytes with a deterministic lexer/parser:

```text
address       := module-step* resource-spec
module-step   := "module." identifier instance-key? "."
resource-spec := "data."? identifier "." identifier instance-key?
instance-key  := "[" (integer-index | quoted-key) "]"
```

The complete address is 1–2,048 bytes, no control/DEL/non-ASCII/whitespace/ NUL/BOM/wildcard/splat/extra token, and at most 64 module steps. `identifier` is `[A-Za-z_][A-Za-z0-9_-]{0,127}`. Integer index is canonical `0|[1-9][0-9]*` and at most `9007199254740991`. A quoted key is strict JSON/HCL-compatible; decoded length 1–128 ASCII bytes with alphanumeric/ underscore endpoints and only reviewed internal punctuation `._-~:/@%+=,`, space, quote, and backslash. Re-serialize once with `JSON.stringify` and require byte equality, permitting necessary `\"`/`\\` but rejecting alternate escapes, controls, or normalization. Module-only address rejects; omitted indexes remain syntactically possible but must pass the singleton proof below.

1. bind and parse exact `RESOURCE_ADDRESS` once and pass it as one argv element;
2. verify expected workspace/backend and exclusive maintenance window;
3. create/validate a fresh current-state backup;
4. capture exactly `terraform state list "$RESOURCE_ADDRESS"` through the bounded collector into a fresh protected match file (stdout 65,536 bytes, 1,024 LF records, 2,048 bytes each; strict ASCII/UTF-8; empty stderr); require complete bytes equal exactly `RESOURCE_ADDRESS + LF`, parse that line independently to the same structure, and require the address equals one reviewed diff-manifest subject;
5. run:

   ```text
   terraform state rm -dry-run "$RESOURCE_ADDRESS"
   ```

   Require start/exit zero and empty bounded stderr but do not parse localized dry-run stdout. The `state list` byte equality—not dry-run prose—is the exact singleton/cardinality oracle. Repeat state-list capture before confirmation to a new path and require byte/digest/report equality.
6. record the remote object's continued existence/ownership plan;
7. require typed confirmation containing workspace and exact address;
8. revalidate the closed `STATE_BACKEND_MODE` and run its one exact argv with locking enabled and exactly `-lock-timeout=5m`;
9. for `local` only, direct the command-created backup to exact fresh `RM_COMMAND_BACKUP_PATH` under its supplied tuple and inventory it immediately; for `hcp-cloud`/`remote-backend`, prove argv contains no `-backup` and retain the protected pre-mutation pull;
10. prohibit retry after unknown-option/nonzero/unknown outcome, `-lock=false`, `-ignore-remote-version`, and force-unlock; and
11. pull/validate the new state, run plan, and prove only intended bindings changed.

If exact dry-run matches cannot be proven, stop. Do not teach broad module or resource-class removal in the copyable recovery example.

The state-rm confirmation uses the same exact first-16-lowercase-hex backup digest prefix and controlling-terminal rules, additionally binding the exact resource address.

The resolver report retains only schema/helper versions, approved Terraform/ configuration/workspace/backend identity, canonical address/address SHA-256, `matchCount:1`, match-set SHA-256, and `outcome:"exact-singleton"`. It never retains object ID/value, native/provider diagnostics, unreviewed address, or match fragments. Remove the match file only under exact identity proof. Confirmation consumes the shared parser. Mutation argv is exactly the one backend-mode row above, with closed stdin, one address argument, no glob/eval/ word splitting/retry/bypass. Fixtures prove local has exactly one validated `-backup` element, HCP/remote have none, and mode/config/workspace drift makes zero mutation calls.

### 5. Treat state locks and force-unlock accurately

Explain:

- Terraform automatically locks state for write operations when the backend supports locking;
- not all backends support it;
- disabling locking is unsafe under concurrency;
- a lock failure means the operation does not continue;
- `force-unlock` is only for an operator's own abandoned lock with the exact nonce/ID after proving no active owner; and
- force-unlock is not a routine prerequisite for push/rm/recovery.

Never combine a force-unlock example with immediate destructive mutation.

### 6. Consolidate provider-version recovery

Keep T2's marked S3/Azure/GCS/HCP state-version blocks as the canonical provider-copy retrieval guidance. Replace overlapping older provider examples with concise links and provider/versioning caveats. Do not copy or subtly alter T2 commands in another location.

Manual push/rm examples must not imply that downloading an old provider object automatically makes it safe to overwrite active state.

### 7. Advance metadata and regenerate

Immediately before finalization:

1. re-read current guide version;
2. increment Minor;
3. use UTC implementation date;
4. reset Revision to `0`;
5. update `Last Updated`; and
6. add a matching top rationale changelog row.

Regenerate through the merged exact generator. Prove all four outputs are current, LF/BOM-less/CR-free, and idempotent.

## Extend the permanent cross-platform harnesses

Update `.github/workflows/Test-StateRecoveryExamples.sh` to extract and execute the four Bash `SM-*` exact blocks in addition to every T2 `SR-*` block.

Add `.github/workflows/Test-StateRecoveryPowerShell.ps1` with `#Requires -Version 5.1`, one recorded version, exact source paths, and the same one-to-one marker/generated-copy/test-inventory checks for `SM-BACKUP-PULL-PS`. It creates only disposable test-owned protected directories and never reads or mutates real Terraform state.

Use non-network/test-owned stubs for Terraform, jq/JSON inspection, digest, terminal confirmation, and remote state. Do **not** stub the no-replace publication primitive or ordinary local filesystem operations. Capture NUL-delimited argv and ordered calls.

Run the expanded Bash harness in the callable Markdown workflow on the preferred Node line. Add permanent Windows jobs inside that same local reusable workflow for the PowerShell harness:

- Windows PowerShell exactly 5.1 on `windows-latest`; and
- PowerShell major 7 on `windows-latest`.

The T1B event-owning build job continues to depend on the called workflow's overall success for the same SHA. Preserve T3's minimum/preferred runtime and audit evidence, action allowlist, permissions, helper harness, lints, and T2 tests. Do not add an external action, independent trigger, or separate workflow. Update `Validate-WorkflowPolicy.mjs` atomically for exact new Windows jobs, action roles/counts, shells, permissions, and stable harness steps.

## Validation

From clean disposable clones:

1. run selected Node/npm policy and restore scoped `CI`;
2. clean install and both lint surfaces;
3. run the complete helper, Bash state-recovery, and PowerShell state-recovery harnesses under every required OS/edition;
4. validate exact `SR-*`, Bash `SM-*`, and PowerShell `SM-BACKUP-PULL-PS` marker/inventory/test equality;
5. run generator twice and prove stable outputs;
6. run the structural workflow validator and prove exact action/permission/event/runtime/Dependabot/called-workflow final state;
7. prove T1/T1A/T1B/T2/T3 enduring evidence remains green;
8. require complete changed/staged path equality to the sixteen affected files;
9. rerun from staged content; and
10. store PR plus post-merge workflow evidence.

## Acceptance criteria

- [ ] No direct state-pull backup truncates a final destination before a valid snapshot exists.
- [ ] Manual backups validate workspace/backend, Terraform exit, state parse, lineage, serial, digest, mode, and no-replace publication.
- [ ] The backend label is explicitly operator-attested; no generic block claims to derive every remote backend identity.
- [ ] Backend identifiers are exactly 16–202 ASCII bytes under the derived three-component grammar, with atomic 201/202/203 and component-boundary oracles on both platforms.
- [ ] Every state-bearing role consumes its own exact parent/path/attestation triple or is helper-private under its one invocation context; `T4-STATE-ROLES-v1` records creator, consumer, identity/content/size, lifetime, cleanup order, failure postcondition, retained uncertainty, and the distinction between operator attestation and platform inspection.
- [ ] Gate A has independent approval and zero mutation calls before Gate B; Gate B is bound to Gate A's immutable digest and has a second independent approval, with any foundation drift returning the work to Gate A.
- [ ] POSIX parent/file modes and Windows owner/protected-DACL/exact-SID ACEs are inspected at every required phase; no Windows acceptance uses `umask` as a security control.
- [ ] Windows PowerShell 5.1 and PowerShell 7 use one raw .NET stdout-stream capture contract and produce byte-identical non-ASCII backup evidence.
- [ ] PowerShell retains at most 65,536 raw stderr bytes, drains excess through EOF, fails on byte 65,537 with status 73, and emits no stderr payload.
- [ ] Every candidate and show stream is bounded and completely tokenized by `Inspect-TerraformState.v1` before publication; all process, byte, UTF-8, JSON, metadata, profile, timeout, and parser-ceiling oracles pass.
- [ ] Windows component traversal, reparse rejection, file identity, link counts, and no-replace hard-link publication use the one reviewed handle-based Win32 helper and fail closed when unavailable.
- [ ] Bash and PowerShell exercise real same-filesystem no-replace publication, existing-target refusal, and exactly-one-winner race cases.
- [ ] Unsupported hard-link publication fails closed with final absent and validated temporary state retained; there is no copy/move fallback.
- [ ] Local corruption preservation cannot clobber and never removes the only verified copy; it consumes the paused-source-writer attestation and proves exact source/destination identity and link count `1→2→1`.
- [ ] Manual state push is exceptional, peer-reviewed, backed up, identity/ concurrency/lineage/serial/diff/confirmation guarded, and never forced.
- [ ] Push/rm confirmations require the exact first 16 lowercase SHA-256 characters plus their operation-specific fields.
- [ ] Backend/workspace/label/digest inputs and canonical JSON confirmation lines use `Confirm-StateMutation.mjs`, raw controlling-terminal byte comparison/restoration, status 68, and zero-destructive-call mismatch oracle through every `SM-CONFIRM-01..69` row.
- [ ] State-difference approval uses only the offline redacted structural/ change-kind projection, exact Git/module/provider/subject/path manifest, per-run HMAC comparison, and exact allowance equality; no state value or value-derived stable digest appears in logs/evidence.
- [ ] Content-changing ordinary pushes require exactly current serial plus one; byte-identical input is a no-op, serialization-only change rejects, and recovery uses either reviewed native restore or the exact serial-splice candidate helper—never a direct old-backup push.
- [ ] Manual state push and state rm use exactly `-lock-timeout=5m`, never disable locking, and require external exclusion for a no-lock backend.
- [ ] State rm attests exactly one `local|hcp-cloud|remote-backend` mode after a protected pre-mutation pull; local alone has one validated `-backup` argv element, HCP/remote have none, and no failed/unknown attempt is retried with a different vector.
- [ ] State rm prefers `removed` blocks, requires dry-run exact matches, canonical address parsing, Terraform-produced singleton equality, repeat match before confirmation, backup, lock, and post-plan evidence; every `SM-ADDRESS-01..36` row has one oracle.
- [ ] No block disables locks, ignores remote version, auto-force-unlocks, or automatically rolls back.
- [ ] Older provider examples point to the exact T2 blocks rather than retain unsafe duplicates.
- [ ] Every one-row-per-ID Bash and PowerShell `SM-*` oracle passes exactly once on each applicable runtime.
- [ ] The closed state-recovery case catalog has no disjunctive row, includes all atomic split IDs and the complete 108-row signal product, and reconciles exactly with every harness result/cell.
- [ ] All prior `SR-*` tests remain green.
- [ ] Every T4 Bash phase consumes T2's exact HUP/INT/TERM 129/130/143 and one-EXIT-owner contract; cleanup runs once and an interrupted started mutation is retained as unknown without retry/rollback.
- [ ] Source/generated files advance consistently and remain LF/BOM-less/ CR-free/idempotent.
- [ ] The callable workflow's permanent Windows 5.1/7 evidence is a same-run approval dependency and the workflow-policy validator recognizes it.
- [ ] The changed/staged set equals the sixteen affected files.

## Non-goals

- Automating destructive state mutation in CI.
- Teaching routine `state push`, force, ignore-version, lock bypass, or force-unlock.
- Supporting unprotected/shared directories or competing writers.
- Replacing provider-native historical version recovery.
- Enabling backend versioning/locking.
- Printing or storing state in test artifacts.
- Changing npm packages, action commits, helper, artifact writer, or runtime policy.

## References

- [Terraform state pull](https://developer.hashicorp.com/terraform/cli/commands/state/pull)
- [Terraform state push](https://developer.hashicorp.com/terraform/cli/commands/state/push)
- [Terraform state rm](https://developer.hashicorp.com/terraform/cli/commands/state/rm)
- [Terraform state locking](https://developer.hashicorp.com/terraform/language/state/locking)
- [Terraform backend storage and locking](https://developer.hashicorp.com/terraform/language/state/backends)
- [Terraform manual state update overview](https://developer.hashicorp.com/terraform/cli/state)
- [Terraform removed blocks](https://developer.hashicorp.com/terraform/language/resources/syntax#removing-resources)
- [PowerShell 5.1 redirection](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-5.1#redirecting-binary-data)
- [PowerShell 7 redirection](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-7.5#redirecting-binary-data)
- [.NET redirected standard output](https://learn.microsoft.com/dotnet/api/system.diagnostics.process.standardoutput?view=netframework-4.8.1)
- [.NET FileMode.CreateNew](https://learn.microsoft.com/dotnet/api/system.io.filemode)
- [CreateHardLinkW](https://learn.microsoft.com/windows/win32/api/winbase/nf-winbase-createhardlinkw)
- [CreateFileW and reparse-point flags](https://learn.microsoft.com/windows/win32/api/fileapi/nf-fileapi-createfilew)
- [FILE_ID_INFO](https://learn.microsoft.com/windows/win32/api/winbase/ns-winbase-file_id_info)
- [.NET UTF8Encoding](https://learn.microsoft.com/dotnet/api/system.text.utf8encoding?view=netframework-4.8.1)
- [.NET FileSystemSecurity](https://learn.microsoft.com/dotnet/api/system.security.accesscontrol.filesystemsecurity?view=netframework-4.8.1)

> IMPORTANT: You MUST see `docs\planning\TerraformStyleGuide\06TerraformStyleGuideT4.md` in branch `planning-CRT-PR-852` for the complete append-only fixture inventory and exact oracle requirements in Section **Extend the permanent cross-platform harnesses**, including subsections **Bash backup/publication**, **PowerShell backup/publication**, **Local corruption preservation**, **State push**, and **State rm**.
