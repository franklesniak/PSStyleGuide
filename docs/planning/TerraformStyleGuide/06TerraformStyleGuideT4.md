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
primitive and exact-block harness. T3 completes before this issue to avoid
simultaneous changes to shared generated documentation and the callable
Markdown workflow.

Record real blocked-by relationships and exact merge commits.

## Affected files

Exactly these ten files may change:

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

The exact marker inventory, source blocks, generated copies, and harness tests
must be equal.

## Common safety model

All blocks require:

- their named interpreter and explicitly resolved `terraform`; `jq`/digest
  tools where named;
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

The Bash blocks require the exact tested Bash contract from T2. The PowerShell
block requires Windows PowerShell exactly 5.1 or PowerShell major 7 on Windows
and uses no ordinary native-output redirection.

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
- `EXPECTED_BACKEND_ID` — a nonsecret canonical
  **operator-attested backend identity** derived from separately reviewed
  backend configuration/account/workspace evidence; and
- an optional approved timestamp/operation label used only in diagnostics.

It must:

1. disable inherited xtrace before sensitive expansion;
2. validate the exact current workspace with `terraform workspace show`;
3. validate the supplied identifier's exact grammar and require the operator
   to compare the initialized backend configuration to it; label the result
   operator-attested, not mechanically derived;
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
    filesystem entry—use
    `ln --no-target-directory <temp> <final>` without `--force`/`--backup` to
    create a same-filesystem hard link from the validated temporary inode,
    followed by exact temp unlink;
13. verify final inode/bytes/digest/mode and that it remains outside Git; and
14. emit only final path, workspace/backend labels, lineage, serial, digest,
    Terraform version, and UTC creation time.

If pull, validation, or publication fails, no final backup may exist. Remove
only the exact verified ordinary temp file; otherwise retain uncertain state
with a warning.

Require the protected temporary and final parent to be on the same filesystem.
Attempt real hard-link publication once. If hard links are unsupported or the
operation fails, do not fall back to copy, move, overwrite, delete/recreate, or
an alternate final name. Leave the final path absent, retain the validated
temporary backup as explicitly reported sensitive state, and tell the operator
to select an access-controlled local filesystem plus a new absent final path.
Unsupported publication is a failure, not a passing skip, on the declared
hosted-runner filesystems.

Explain that `state pull` upgrades the returned snapshot to the newest format
compatible with the locally installed Terraform. The backup is a validated
recovery point, not necessarily a byte copy of backend storage.

Add one copyable `SM-BACKUP-PULL-PS` implementation with the same inputs,
postconditions, and operator-attested backend language. It must:

1. resolve one ordinary non-reparse Terraform executable and use only fixed
   `state pull` arguments—no shell command string or user-controlled process
   arguments;
2. create a `System.Diagnostics.ProcessStartInfo` with
   `UseShellExecute = $false`, redirected stdout/stderr, and no window;
3. call `Path.GetRandomFileName()` and acquire one absent same-parent
   temporary file through a `FileStream` opened with `FileMode.CreateNew`,
   write-only access, and `FileShare.None`; use a documented finite retry only
   for an actual create-new collision and fail immediately for every other
   error;
4. start the process, copy `StandardOutput.BaseStream` bytes directly to the
   file, drain stderr concurrently with an explicit bound, and only then wait
   for stream/process completion so neither pipe can deadlock;
5. capture the native exit exactly, reject start/nonzero/empty/partial output,
   and never print state bytes;
6. dispose process/stream objects before cleanup;
7. require one ordinary non-reparse temporary file containing BOM-less UTF-8
   state that `terraform show -json` accepts; extract/record lineage, serial,
   Terraform version, and SHA-256;
8. publish once with
   `New-Item -ItemType HardLink -Path <final> -Target <temp>` without
   `-Force`, after repeated final-absence/type checks;
9. verify final bytes/digest/file identity, unlink only the temporary hard-link
   name, and retain the final validated backup; and
10. on failure, delete only a still-proven owned ordinary unpublished
    temporary file; retain and report every uncertain or publication-failed
    root.

Ordinary native `>`, `Out-File`, and `Set-Content` are prohibited for state
capture. Windows PowerShell 5.1 treats native byte output as strings, while
byte-preserving native redirection was introduced only in PowerShell 7.4; the
single raw .NET stream algorithm avoids edition branches.

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
- atomic no-replace hard-link publication using
  `ln --no-target-directory` without `--force`/`--backup`;
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
4. exact initialized workspace equality and the same explicit
   operator-attested backend-identity review used by the backup;
5. a just-created `SM-BACKUP-PULL` backup of the current remote state;
6. current and proposed state both parse with the exact Terraform version;
7. recorded current/proposed lineage, serial, Terraform version, and SHA-256;
8. proposed lineage equals current lineage;
9. proposed serial is not lower than current remote serial;
10. a reviewed state diff that exposes no unexpected resource binding/output/
    provider-address changes and does not disclose secret values;
11. a tested rollback command using the just-created current backup;
12. a typed confirmation read from a controlling terminal containing the exact
    operation, workspace, operator-attested backend label, current serial,
    proposed serial, and exactly the first 16 lowercase hexadecimal characters
    of the reviewed proposed-state SHA-256; and
13. one command using the exact proposed path and exactly
    `-lock-timeout=5m`.

The command must not use:

- `-force`;
- `-ignore-remote-version`;
- `-lock=false`;
- stdin (`PATH=-`);
- an unquoted/relative path; or
- automatic retry after safety rejection.

Terraform's differing-lineage and higher-remote-serial checks remain enabled.
Locking remains enabled where the backend supports it. Do not retry
automatically. Distinguish lock acquisition failure from
lineage/serial/input/provider failure. A safety-check or lock failure stops the
procedure; it is not a prompt to add a bypass. If the backend does not support
locking, record the backend-appropriate maintenance window/external exclusion
and accountable owner before confirmation; do not claim the timeout supplies a
lock.

The full digest is displayed separately. Confirmation input is read from a
controlling terminal, follows one literal grammar, and is compared ordinally;
do not trim or case-fold except where the grammar explicitly permits it.
Empty, wrong-case, nonhex, short, long, extra-text, or mismatched confirmation
fails before mutation.

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
8. run with locking enabled and exactly `-lock-timeout=5m`;
9. direct any command-created backup to a protected fresh path when the
   installed Terraform/backend exposes that option; otherwise run from a
   protected directory and inventory the exact backup path immediately;
10. prohibit `-lock=false`, `-ignore-remote-version`, and force-unlock; and
11. pull/validate the new state, run plan, and prove only intended bindings
    changed.

If exact dry-run matches cannot be proven, stop. Do not teach broad module or
resource-class removal in the copyable recovery example.

The state-rm confirmation uses the same exact first-16-lowercase-hex backup
digest prefix and controlling-terminal rules, additionally binding the exact
resource address.

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

## Extend the permanent cross-platform harnesses

Update `.github/workflows/Test-StateRecoveryExamples.sh` to extract and execute
the four Bash `SM-*` exact blocks in addition to every T2 `SR-*` block.

Add `.github/workflows/Test-StateRecoveryPowerShell.ps1` with
`#Requires -Version 5.1`, one recorded version, exact source paths, and the same
one-to-one marker/generated-copy/test-inventory checks for
`SM-BACKUP-PULL-PS`. It creates only disposable test-owned protected
directories and never reads or mutates real Terraform state.

Use non-network/test-owned stubs for Terraform, jq/JSON inspection, digest,
terminal confirmation, and remote state. Do **not** stub the no-replace
publication primitive or ordinary local filesystem operations. Capture
NUL-delimited argv and ordered calls.

The following IDs are append-only. Each harness contains matching
machine-readable metadata and rejects missing, duplicate, unexpected, or
multiply emitted applicable IDs. Every row records interpreter/edition,
fixture, initial state, command/confirmation, expected phase/status,
temporary/final state, remote-call count, diagnostics, and sentinels.

### Bash backup/publication

| ID | Setup | Exact oracle |
| --- | --- | --- |
| `SM-BASH-BACKUP-01` | valid state/fresh path | valid final; exact lineage/serial/digest/mode; temp absent |
| `SM-BASH-BACKUP-02` | existing ordinary final file | reject before pull; bytes unchanged |
| `SM-BASH-BACKUP-03` | existing final directory | reject before pull; directory unchanged |
| `SM-BASH-BACKUP-04` | live-link final | reject before pull; link/target unchanged |
| `SM-BASH-BACKUP-05` | dangling-link final | reject before pull; link unchanged |
| `SM-BASH-BACKUP-06` | relative/outside-protected path | reject before pull |
| `SM-BASH-BACKUP-07` | pull nonzero with partial stdout | no final; proven partial removed |
| `SM-BASH-BACKUP-08` | empty output | no final; temp removed |
| `SM-BASH-BACKUP-09` | invalid JSON or BOM | no final; temp removed |
| `SM-BASH-BACKUP-10` | `terraform show` rejection | no final; temp removed |
| `SM-BASH-BACKUP-11` | missing/malformed lineage or serial | no final; temp removed |
| `SM-BASH-BACKUP-12` | competing final creator | exactly one winner; existing winner never overwritten |
| `SM-BASH-BACKUP-13` | post-publication digest mismatch | uncertain temp/final retained and reported |
| `SM-BASH-BACKUP-14` | hard links unsupported | final absent; validated temp retained; fail closed |
| `SM-BASH-BACKUP-15` | cleanup substitution/failure | uncertain root retained; primary plus cleanup reported |

### PowerShell backup/publication

| ID | Setup | Exact oracle |
| --- | --- | --- |
| `SM-PS-BACKUP-01` | valid ASCII state | byte-identical valid final on 5.1 and 7 |
| `SM-PS-BACKUP-02` | valid non-ASCII UTF-8 state | exact stdout/final bytes on 5.1 and 7 |
| `SM-PS-BACKUP-03` | process start failure | no final; owned empty temp removed |
| `SM-PS-BACKUP-04` | nonzero with no stdout | no final; temp removed; native status retained |
| `SM-PS-BACKUP-05` | nonzero with partial stdout | no final; exact partial removed |
| `SM-PS-BACKUP-06` | zero with empty/truncated output | no final; validation failure |
| `SM-PS-BACKUP-07` | invalid/BOM state | no final; validation failure |
| `SM-PS-BACKUP-08` | existing ordinary final | reject before process; bytes unchanged |
| `SM-PS-BACKUP-09` | live/dangling reparse final | reject before process; target unchanged |
| `SM-PS-BACKUP-10` | cleanup substitution/failure | uncertain root retained; both reasons reported |
| `SM-PS-BACKUP-11` | real hard-link publication | final bytes/identity verified; temp name absent |
| `SM-PS-BACKUP-12` | two competing publishers | exactly one create succeeds; loser cannot overwrite |
| `SM-PS-BACKUP-13` | hard links unsupported | final absent; validated temp retained; fail closed |
| `SM-PS-BACKUP-14` | stdout/stderr exceed process edge cases | no deadlock; bounded diagnostics; exact result |
| `SM-PS-BACKUP-15` | existing final directory | reject before process; directory unchanged |

Every `SM-PS-*` row runs under Windows PowerShell exactly 5.1 and PowerShell
major 7 unless the row is explicitly edition-specific. A skip names
ID/edition/platform/reason and is not a pass.

### Local corruption preservation

| ID | Setup | Exact oracle |
| --- | --- | --- |
| `SM-BASH-CORR-01` | ordinary source/fresh final | final verified; source unlinked only afterward |
| `SM-BASH-CORR-02` | missing source | reject; no final |
| `SM-BASH-CORR-03` | directory/link source | reject; source/target unchanged |
| `SM-BASH-CORR-04` | any existing final class | reject; both paths unchanged |
| `SM-BASH-CORR-05` | hard-link unsupported/failure | source remains only verified copy |
| `SM-BASH-CORR-06` | verification/digest failure | at least one verified source remains |

### State push

| ID | Setup | Exact oracle |
| --- | --- | --- |
| `SM-BASH-PUSH-01` | declarative/backend-native alternative selected | no push |
| `SM-BASH-PUSH-02` | workspace/backend attestation mismatch | no push |
| `SM-BASH-PUSH-03` | absent/invalid current backup | no push |
| `SM-BASH-PUSH-04` | no lock support/external exclusion | no push |
| `SM-BASH-PUSH-05` | lineage mismatch | no push |
| `SM-BASH-PUSH-06` | proposed serial lower than current | no push |
| `SM-BASH-PUSH-07` | confirmation empty/case/nonhex/short/long/extra/mismatch | no push |
| `SM-BASH-PUSH-08` | safety/lock/provider failure | one attempt; no bypass/retry |
| `SM-BASH-PUSH-09` | all gates pass | one exact argv with `-lock-timeout=5m`; no prohibited flag/stdin |
| `SM-BASH-PUSH-10` | post-push verification mismatch | fail incident; no automatic rollback |
| `SM-BASH-PUSH-11` | rollback path present | never runs without new review/confirmation |

### State rm

| ID | Setup | Exact oracle |
| --- | --- | --- |
| `SM-BASH-RM-01` | declarative `removed` alternative | no state rm |
| `SM-BASH-RM-02` | empty/control/broader address | reject before dry run |
| `SM-BASH-RM-03` | workspace/backend/backup/concurrency failure | reject before dry run |
| `SM-BASH-RM-04` | dry run zero matches | no mutation |
| `SM-BASH-RM-05` | dry run one exact match | proceed only to confirmation |
| `SM-BASH-RM-06` | dry run multiple/unexpected matches | no mutation |
| `SM-BASH-RM-07` | confirmation mismatch or bad digest prefix | no mutation |
| `SM-BASH-RM-08` | all gates pass | exact address and `-lock-timeout=5m`; no bypass |
| `SM-BASH-RM-09` | command-created backup | exact protected fresh path inventoried |
| `SM-BASH-RM-10` | post-state/plan mismatch | fail incident; no automatic rollback |

Every negative must assert the intended stable reason, no destructive provider
call before all prerequisites, unchanged stub remote state, and exact
filesystem postcondition.

The Bash harness executes real same-filesystem
`ln --no-target-directory` without `--force`/`--backup`; the PowerShell harness
executes real `New-Item -ItemType HardLink` without `-Force`. Both prove absent
target success, existing ordinary/directory/link target refusal without byte
changes, and two synchronized publisher processes with exactly one success and
one already-exists failure. Use bounded repetition only as supplemental
evidence. An unavailable primitive is the explicit fail-closed case, never a
mocked pass.

Run the expanded Bash harness in the callable Markdown workflow on the
preferred Node line. Add permanent Windows jobs inside that same local reusable
workflow for the PowerShell harness:

- Windows PowerShell exactly 5.1 on `windows-latest`; and
- PowerShell major 7 on `windows-latest`.

The T1B event-owning build job continues to depend on the called workflow's
overall success for the same SHA. Preserve T3's minimum/preferred runtime and
audit evidence, action allowlist, permissions, helper harness, lints, and T2
tests. Do not add an external action, independent trigger, or separate
workflow. Update `Validate-WorkflowPolicy.mjs` atomically for exact new Windows
jobs, action roles/counts, shells, permissions, and stable harness steps.

## Validation

From clean disposable clones:

1. run selected Node/npm policy and restore scoped `CI`;
2. clean install and both lint surfaces;
3. run the complete helper, Bash state-recovery, and PowerShell state-recovery
   harnesses under every required OS/edition;
4. validate exact `SR-*`, Bash `SM-*`, and PowerShell `SM-BACKUP-PULL-PS`
   marker/inventory/test equality;
5. run generator twice and prove stable outputs;
6. run the structural workflow validator and prove exact
   action/permission/event/runtime/Dependabot/called-workflow final state;
7. prove T1/T1A/T1B/T2/T3 enduring evidence remains green;
8. require complete changed/staged path equality to the ten affected files;
9. rerun from staged content; and
10. store PR plus post-merge workflow evidence.

## Acceptance criteria

- [ ] No direct state-pull backup truncates a final destination before a valid
      snapshot exists.
- [ ] Manual backups validate workspace/backend, Terraform exit, state parse,
      lineage, serial, digest, mode, and no-replace publication.
- [ ] The backend label is explicitly operator-attested; no generic block
      claims to derive every remote backend identity.
- [ ] Windows PowerShell 5.1 and PowerShell 7 use one raw .NET stdout-stream
      capture contract and produce byte-identical non-ASCII backup evidence.
- [ ] Bash and PowerShell exercise real same-filesystem no-replace publication,
      existing-target refusal, and exactly-one-winner race cases.
- [ ] Unsupported hard-link publication fails closed with final absent and
      validated temporary state retained; there is no copy/move fallback.
- [ ] Local corruption preservation cannot clobber and never removes the only
      verified copy.
- [ ] Manual state push is exceptional, peer-reviewed, backed up, identity/
      concurrency/lineage/serial/diff/confirmation guarded, and never forced.
- [ ] Push/rm confirmations require the exact first 16 lowercase SHA-256
      characters plus their operation-specific fields.
- [ ] Manual state push and state rm use exactly `-lock-timeout=5m`, never
      disable locking, and require external exclusion for a no-lock backend.
- [ ] State rm prefers `removed` blocks, requires dry-run exact matches,
      backup, lock, confirmation, and post-plan evidence.
- [ ] No block disables locks, ignores remote version, auto-force-unlocks, or
      automatically rolls back.
- [ ] Older provider examples point to the exact T2 blocks rather than retain
      unsafe duplicates.
- [ ] Every one-row-per-ID Bash and PowerShell `SM-*` oracle passes exactly once
      on each applicable runtime.
- [ ] All prior `SR-*` tests remain green.
- [ ] Source/generated files advance consistently and remain LF/BOM-less/
      CR-free/idempotent.
- [ ] The callable workflow's permanent Windows 5.1/7 evidence is a same-run
      approval dependency and the workflow-policy validator recognizes it.
- [ ] The changed/staged set equals the ten affected files.

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
- [PowerShell 5.1 redirection](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-5.1#redirecting-binary-data)
- [PowerShell 7 redirection](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-7.5#redirecting-binary-data)
- [.NET redirected standard output](https://learn.microsoft.com/dotnet/api/system.diagnostics.process.standardoutput?view=netframework-4.8.1)
- [.NET FileMode.CreateNew](https://learn.microsoft.com/dotnet/api/system.io.filemode)
- [PowerShell New-Item hard links](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/new-item?view=powershell-5.1)
