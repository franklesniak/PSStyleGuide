# Make manual state backup and destructive recovery guidance copy-safe

## Summary

Replace truncating manual-backup redirections and unguarded destructive state
commands with a small, explicit operational workflow:

1. capture a current state snapshot into a protected temporary file;
2. validate the Terraform exit, state format, lineage, serial, and digest;
3. publish the backup to a fresh path without overwrite;
4. verify exact workspace/backend/concurrency identity;
5. preview and review the intended mutation;
6. require an explicit human confirmation bound to that identity;
7. run without force or lock bypass; and
8. verify the result and retain a tested rollback point.

Prefer declarative Terraform workflows (`removed`/`moved`/`import` blocks,
normal plan/apply, provider-version rollback) over manual state mutation
whenever they can express the operation.

## Dependencies and order

Implement after:

1. **Make state-version discovery and recovery examples copy-safe with guarded
   identifiers**; and
2. **Remediate Markdown lint dependency advisories and add npm update
   governance**.

The state-recovery dependency supplies the canonical protected-destination
primitive and exact-block harness. The npm dependency is ordered first in the
linear slate to avoid simultaneous changes to shared generated documentation
and the Markdown workflow.

Record real blocked-by relationships and exact merge commits.

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

- `.github/workflows/Test-StateRecoveryExamples.sh`;
- `.github/workflows/markdownlint.yml`.

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
| `SM-BACKUP-PULL` | capture, validate, and publish a fresh manual backup |
| `SM-LOCAL-CORRUPTION` | preserve a local corrupt state file without clobber |
| `SM-STATE-PUSH` | guarded exceptional manual state push |
| `SM-STATE-RM` | guarded state-forget workflow with dry run |

The exact marker inventory, source blocks, generated copies, and harness tests
must be equal.

## Common safety model

All blocks require:

- Bash and explicitly resolved `terraform`; `jq`/digest tools where named;
- a protected operator-owned directory outside Git and shared world-readable
  temporary locations;
- `umask 077`;
- fresh absolute destination paths;
- both `-e` and `-L` rejection for every final destination;
- no competing process able to replace entries in the protected directory;
- state treated as secret;
- exact native exit capture;
- no command strings or `eval`;
- no recursive/wildcard cleanup;
- exact-path cleanup only for ordinary files created by the block; and
- stable diagnostics that never print state or signed URLs.

The filesystem checks are not a universal adversarial-filesystem sandbox.
Refuse operation when ownership, type, link status, or backend concurrency is
uncertain.

## Requested changes

### 1. Publish manual backups only after validation

Replace every direct pattern like:

```text
terraform state pull > some-backup-path
```

with one canonical `SM-BACKUP-PULL` Bash block.

The block accepts once:

- `STATE_BACKUP_PATH` — new absolute final path;
- `EXPECTED_TERRAFORM_WORKSPACE`;
- `EXPECTED_BACKEND_ID` — an operator-reviewed identifier for the initialized
  backend/configuration; and
- an optional approved timestamp/operation label used only in diagnostics.

It must:

1. disable inherited xtrace before sensitive expansion;
2. validate the exact current workspace with `terraform workspace show`;
3. require the operator to compare the initialized backend configuration to
   `EXPECTED_BACKEND_ID`; a generic script must not pretend it can derive every
   backend's identity uniformly;
4. validate fresh final path and protected ordinary parent;
5. create one unpredictable mode-0600 temporary file in the same parent;
6. run `terraform state pull` with stdout directed only to that temporary file;
7. capture the Terraform exit immediately and reject empty/partial output;
8. reject UTF-8 BOM and non-UTF-8/invalid JSON;
9. run `terraform show -json <temp>` with output discarded to validate that
   Terraform can read the snapshot;
10. use a trusted JSON parser to extract only top-level nonempty `lineage`,
    nonnegative integer `serial`, and recorded `terraform_version`;
11. compute and record SHA-256 without printing state;
12. atomically create the final name without overwriting an existing
    filesystem entry—use a same-filesystem no-replace primitive such as a hard
    link from the validated temporary inode followed by exact temp unlink;
13. verify final inode/bytes/digest/mode and that it remains outside Git; and
14. emit only final path, workspace/backend labels, lineage, serial, digest,
    Terraform version, and UTC creation time.

If pull, validation, or publication fails, no final backup may exist. Remove
only the exact verified ordinary temp file; otherwise retain uncertain state
with a warning.

Explain that `state pull` upgrades the returned snapshot to the newest format
compatible with the locally installed Terraform. The backup is a validated
recovery point, not necessarily a byte copy of backend storage.

For PowerShell, provide an equivalent implementation using:

- explicit BOM-less UTF-8 binary-safe capture;
- `FileMode.CreateNew` for fresh names;
- exact native exit handling; and
- same-directory no-replace publication.

Do not recommend `Set-Content`/`Out-File` as a generic state pipeline without
explicit encoding/exit/partial-file controls.

### 2. Guard local corruption preservation

`SM-LOCAL-CORRUPTION` replaces an unguarded:

```text
mv terraform.tfstate terraform.tfstate.corrupted
```

Require:

- source is one existing ordinary non-link file;
- destination is an absolute fresh path for which neither `-e` nor `-L` is
  true;
- protected same-filesystem parent;
- source SHA-256 before operation;
- atomic no-replace hard-link publication;
- destination digest/inode equality;
- exact source unlink only after destination verification; and
- failure leaves at least one verified copy and reports which paths remain.

Do not use `mv -f`, delete-then-rename, wildcard paths, or a command whose
“no-clobber” success semantics are ambiguous on the supported platform.

### 3. Put manual state push behind a closed checklist

HashiCorp recommends `terraform state push` only for necessary manual repair.
The `SM-STATE-PUSH` section must first prefer:

- backend-native state-version rollback;
- HCP Terraform state rollback UI/API;
- a normal Terraform upgrade/downgrade workflow;
- `moved`/`import`/`removed` blocks; or
- vendor support/escalation.

If manual push remains necessary, require:

1. approved change/incident record and named operator/peer reviewer;
2. maintenance window with all automation and human applies paused;
3. verified backend lock support or a documented stronger external exclusion
   mechanism; if neither exists, stop;
4. exact initialized backend/configuration and workspace equality to reviewed
   expected values;
5. a just-created `SM-BACKUP-PULL` backup of the current remote state;
6. current and proposed state both parse with the exact Terraform version;
7. recorded current/proposed lineage, serial, Terraform version, and SHA-256;
8. proposed lineage equals current lineage;
9. proposed serial is not lower than current remote serial;
10. a reviewed state diff that exposes no unexpected resource binding/output/
    provider-address changes and does not disclose secret values;
11. a tested rollback command using the just-created current backup;
12. a typed confirmation read from a controlling terminal containing exact
    workspace, current serial, proposed serial, and a digest prefix; and
13. one command using the exact proposed path.

The command must not use:

- `-force`;
- `-ignore-remote-version`;
- `-lock=false`;
- stdin (`PATH=-`);
- an unquoted/relative path; or
- automatic retry after safety rejection.

Terraform's differing-lineage and higher-remote-serial checks remain enabled.
Locking remains enabled where the backend supports it. A safety-check or lock
failure stops the procedure; it is not a prompt to add a bypass.

After success:

- immediately pull to a new protected verification path;
- verify workspace/backend, lineage, expected serial behavior, and reviewed
  content;
- run `terraform plan` under the incident/change procedure;
- keep the pre-push backup according to policy; and
- use the tested rollback only after a new explicit review/confirmation.

### 4. Guard state removal and prefer `removed` blocks

State that `terraform state rm` forgets bindings but leaves remote objects; a
later plan may attempt to create replacements and collide with them. Prefer
declarative `removed` blocks when supported because they are reviewable through
normal plan/apply.

For unavoidable `SM-STATE-RM`:

1. bind exact `RESOURCE_ADDRESS` once, reject empty/control values, and pass it
   as one quoted argument;
2. verify expected workspace/backend and exclusive maintenance window;
3. create/validate a fresh current-state backup;
4. run:

   ```text
   terraform state rm -dry-run <one-exact-address>
   ```

5. require exact reviewed match output and no wildcard/broader address;
6. record the remote object's continued existence/ownership plan;
7. require typed confirmation containing workspace and exact address;
8. run with locking enabled and a deliberate nonzero `-lock-timeout`;
9. direct any command-created backup to a protected fresh path when the
   installed Terraform/backend exposes that option; otherwise run from a
   protected directory and inventory the exact backup path immediately;
10. prohibit `-lock=false`, `-ignore-remote-version`, and force-unlock; and
11. pull/validate the new state, run plan, and prove only intended bindings
    changed.

If exact dry-run matches cannot be proven, stop. Do not teach broad module or
resource-class removal in the copyable recovery example.

### 5. Treat state locks and force-unlock accurately

Explain:

- Terraform automatically locks state for write operations when the backend
  supports locking;
- not all backends support it;
- disabling locking is unsafe under concurrency;
- a lock failure means the operation does not continue;
- `force-unlock` is only for an operator's own abandoned lock with the exact
  nonce/ID after proving no active owner; and
- force-unlock is not a routine prerequisite for push/rm/recovery.

Never combine a force-unlock example with immediate destructive mutation.

### 6. Consolidate provider-version recovery

Keep T2's marked S3/Azure/GCS/HCP state-version blocks as the canonical
provider-copy retrieval guidance. Replace overlapping older provider examples
with concise links and provider/versioning caveats. Do not copy or subtly alter
T2 commands in another location.

Manual push/rm examples must not imply that downloading an old provider object
automatically makes it safe to overwrite active state.

### 7. Advance metadata and regenerate

Immediately before finalization:

1. re-read current guide version;
2. increment Minor;
3. use UTC implementation date;
4. reset Revision to `0`;
5. update `Last Updated`; and
6. add a matching top rationale changelog row.

Regenerate through the merged exact generator. Prove all four outputs are
current, LF/BOM-less/CR-free, and idempotent.

## Extend the permanent shell harness

Update `.github/workflows/Test-StateRecoveryExamples.sh` to extract and execute
the four `SM-*` exact blocks in addition to every T2 `SR-*` block.

Use non-network/test-owned stubs for Terraform, jq/JSON inspection, digest,
hard-link/no-replace publication, terminal confirmation, and filesystem
operations. Capture NUL-delimited argv and ordered calls.

Mandatory cases:

### Backup/publication

- fresh path success with exact valid state, lineage, serial, digest, and mode;
- existing file/directory/live link/dangling link rejection;
- relative/outside-protected path rejection;
- Terraform pull nonzero with partial stdout;
- empty output;
- invalid JSON/BOM;
- `terraform show` rejection;
- missing/malformed lineage or serial;
- publication race/existing destination;
- digest mismatch after publication; and
- no final path plus exact temp cleanup/retention on each failure.

### Local corruption preservation

- ordinary source/fresh destination success;
- missing/directory/link source;
- every existing destination class;
- hard-link failure;
- verification/digest failure; and
- source remains until one verified destination exists.

### State push

- declarative/backend-native alternative chosen, so no push;
- workspace/backend mismatch;
- absent/invalid current backup;
- no lock support/no external exclusion;
- lineage mismatch;
- proposed serial lower than current;
- review/confirmation refusal or mismatch;
- safety/lock/provider failure;
- exact one permitted argv without force/ignore/lock bypass/stdin;
- post-push verification mismatch; and
- rollback never runs automatically.

### State rm

- declarative `removed` alternative;
- address empty/control/broader-than-reviewed;
- workspace/backend/backup/concurrency failure;
- dry-run zero/one/multiple/unexpected matches;
- confirmation refusal;
- exact quoted address and positive lock timeout;
- no lock/remote-version bypass;
- exact protected command-created backup handling; and
- post-operation state/plan mismatch.

Every negative must assert the intended stable reason, no destructive provider
call before all prerequisites, unchanged stub remote state, and exact
filesystem postcondition.

Run the expanded harness in the merged Markdown workflow on the preferred Node
line. Preserve T3's minimum/preferred runtime evidence, action allowlist,
permissions, helper harness, lints, and T2 tests. Do not add an action or
workflow.

## Validation

From clean disposable clones:

1. run selected Node/npm policy and restore scoped `CI`;
2. clean install and both lint surfaces;
3. run the complete helper and state-recovery harnesses;
4. validate exact `SR-*` plus `SM-*` marker/inventory/test equality;
5. run generator twice and prove stable outputs;
6. prove exact action/permission/event/runtime/Dependabot final state;
7. prove T1/T1A/T1B/T2/T3 enduring evidence remains green;
8. require complete changed/staged path equality to the eight affected files;
9. rerun from staged content; and
10. store PR plus post-merge workflow evidence.

## Acceptance criteria

- [ ] No direct state-pull backup truncates a final destination before a valid
      snapshot exists.
- [ ] Manual backups validate workspace/backend, Terraform exit, state parse,
      lineage, serial, digest, mode, and no-replace publication.
- [ ] Local corruption preservation cannot clobber and never removes the only
      verified copy.
- [ ] Manual state push is exceptional, peer-reviewed, backed up, identity/
      concurrency/lineage/serial/diff/confirmation guarded, and never forced.
- [ ] State rm prefers `removed` blocks, requires dry-run exact matches,
      backup, lock, confirmation, and post-plan evidence.
- [ ] No block disables locks, ignores remote version, auto-force-unlocks, or
      automatically rolls back.
- [ ] Older provider examples point to the exact T2 blocks rather than retain
      unsafe duplicates.
- [ ] Every `SM-*` exact block passes all mandatory non-network cases.
- [ ] All prior `SR-*` tests remain green.
- [ ] Source/generated files advance consistently and remain LF/BOM-less/
      CR-free/idempotent.
- [ ] The changed/staged set equals the eight affected files.

## Non-goals

- Automating destructive state mutation in CI.
- Teaching routine `state push`, force, ignore-version, lock bypass, or
  force-unlock.
- Supporting unprotected/shared directories or competing writers.
- Replacing provider-native historical version recovery.
- Enabling backend versioning/locking.
- Printing or storing state in test artifacts.
- Changing npm packages, action commits, helper, artifact writer, or runtime
  policy.

## References

- [Terraform state pull](https://developer.hashicorp.com/terraform/cli/commands/state/pull)
- [Terraform state push](https://developer.hashicorp.com/terraform/cli/commands/state/push)
- [Terraform state rm](https://developer.hashicorp.com/terraform/cli/commands/state/rm)
- [Terraform state locking](https://developer.hashicorp.com/terraform/language/state/locking)
- [Terraform backend storage and locking](https://developer.hashicorp.com/terraform/language/state/backends)
- [Terraform manual state update overview](https://developer.hashicorp.com/terraform/cli/state)
- [Terraform removed blocks](https://developer.hashicorp.com/terraform/language/resources/syntax#removing-resources)
