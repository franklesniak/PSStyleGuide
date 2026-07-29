# Promote generated style-guide artifacts through a least-privileged verified writer

## Summary

Replace the current direct generation/push workflow with an immutable,
digest-bound candidate pipeline. Preparation creates one candidate artifact.
Ubuntu and a complete Windows PowerShell edition × fixture-EOL matrix validate
that exact candidate through the tracked production helper and harness. A
separate approval job gates the only job with `contents: write`. The writer
revalidates the exact artifact, binds the event ref/SHA once, stages only the
four generated files, and pushes one commit with an exact expected-SHA lease
and explicit full destination ref.

## Dependencies

Implement only after both issues merge:

1. **Make artifact generation byte-deterministic and standardize repository
   text checkouts on LF**; and
2. **Add a fail-closed cross-platform style-guide candidate validator**.

Record the actual GitHub blocked-by relationships and exact prerequisite merge
commits. Before editing workflows:

- run the complete T1 generator/runtime/action baseline;
- run every applicable T1A stable harness ID;
- validate exact versions and ordinary-file identities of all three scripts;
  and
- stop if either merged contract or the reciprocal P1/Terraform comparison has
  an unresolved blocker.

**Make state-version discovery and recovery examples copy-safe with guarded
identifiers** is blocked by this issue.

## Affected files

Exactly these two files may change:

- `.github/workflows/build.yml`; and
- `.github/workflows/markdownlint.yml`.

Do not change the generator, helper, context lifecycle, harness, package
manifest, lockfile, hook, lint configuration, source guides, or generated
artifacts in this issue.

## Global workflow invariants

- Run `pull_request` for every pull request targeting `main`.
- Run `push` for every push to `main`.
- Do not use workflow-level path filters or a skip-commit convention.
- Add `merge_group` if the repository enables merge queue and requires these
  checks.
- Set workflow/top-level permissions to `contents: read`.
- Give `contents: write` only to the final synchronization writer job.
- Use only standard GitHub-hosted runners.
- Use `persist-credentials: false` on every checkout.
- Do not use caches, service containers, reusable remote workflows, or
  unreviewed external actions.
- Do not use automatic artifact extraction.
- Do not rely on workflow concurrency for correctness. A stale run loses its
  exact-SHA checks or lease; a newer run handles the newer commit.

## Exact external-action allowlist

Immediately before implementation, re-resolve each official release tag and
retain provenance evidence. The required commits are:

| Action | Exact full SHA | Reviewed release |
| --- | --- | --- |
| `actions/checkout` | `3d3c42e5aac5ba805825da76410c181273ba90b1` | `v7.0.1` |
| `actions/setup-node` | `820762786026740c76f36085b0efc47a31fe5020` | `v7.0.0` |
| `actions/upload-artifact` | `043fb46d1a93c77aae656e7c1c64a875d1fc6a0a` | `v7.0.1` |
| `actions/download-artifact` | `3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c` | `v8.0.1` |

Every `uses:` line must use a full SHA plus matching release annotation. Parse
all workflow YAML structurally and require exact equality to the final
workflow/job/step-role/repository/SHA/count table. At minimum, encode separate
roles for:

- preparation checkout;
- candidate upload;
- Windows-cell checkout;
- Windows-cell download without decompression;
- Windows failure-diagnostic upload;
- writer checkout;
- writer download without decompression;
- writer failure-diagnostic upload;
- Markdown checkout; and
- Markdown Node setup.

Final YAML determines exact counts. Reject missing, duplicate, extra, dynamic,
mutable, wrong-repository, arbitrary-SHA, and swapped upload/download roles.
The verifier is deterministic and offline. Update `uses:`, annotation,
allowlist, and fixtures atomically on an intentional upgrade.

## Requested changes

### 1. Keep Markdown validation read-only

In `.github/workflows/markdownlint.yml`:

- preserve exact hosted Node 24 and `package-manager-cache: false`;
- assert actual Node major 24;
- perform clean `npm ci`;
- run the unchanged outer and nested lint commands;
- invoke the exact tracked T1A harness against the exact tracked helper under
  PowerShell 7 on Ubuntu;
- verify both production scripts and harness are ordinary non-reparse files
  before invocation; and
- retain `contents: read` only.

The helper harness runs independently of whether generated artifacts changed.
The later T2 issue may add its state-recovery shell harness as a separate
stable step without weakening these invariants.

### 2. Prepare one immutable candidate

The read-only preparation job runs on Ubuntu and:

1. checks out the exact event SHA with credentials disabled;
2. verifies `HEAD` is the event commit object;
3. verifies the generator/helper/context/harness paths are tracked ordinary
   non-reparse files with expected versions;
4. runs the exact helper harness;
5. starts from a clean worktree/index;
6. runs the exact generator;
7. requires the complete changed path set to be a subset of exactly:
   - `copilot-instructions.md`;
   - `terraform.instructions.md`;
   - `STYLE_GUIDE_CHAT.md`; and
   - `STYLE_GUIDE_FULL.md`;
8. proves all four files exist as ordinary non-reparse files, are BOM-less,
   contain no CR, and satisfy size bounds;
9. computes `has_changes` from exact candidate-versus-`HEAD` blob bytes;
10. records candidate SHA-256 values and the event SHA/ref;
11. uploads exactly the four explicit paths once with no hidden files,
    overwrite, or mutable name reuse; and
12. emits only the upload action's immutable artifact ID, bare hexadecimal
    artifact digest, unique artifact name, `has_changes`, event SHA, and full
    target ref as job outputs.

Use a collision-free name containing run ID and attempt. Do not derive trust
from the artifact name. The bare `artifact-digest` output is the only expected
ZIP digest supplied to the helper.

Upload on both pull requests and pushes, including no-change candidates, so
the matrix always validates an actual transport. Use the shortest repository-
approved retention that still permits investigation; the candidate is not a
release artifact.

### 3. Validate the exact candidate on Windows

Create a four-cell matrix:

| Edition | Fixture source EOL |
| --- | --- |
| Windows PowerShell exactly 5.1 | LF |
| Windows PowerShell exactly 5.1 | CRLF |
| PowerShell Core major 7 | LF |
| PowerShell Core major 7 | CRLF |

Set `strategy.fail-fast: false`.

Every cell:

1. checks out and verifies the exact event SHA without credentials;
2. asserts the selected PowerShell edition/version;
3. resolves the exact helper/context/harness as tracked ordinary files;
4. runs the permanent harness and requires every applicable stable ID;
5. creates a caller context under `RUNNER_TEMP` through
   `New-StyleGuideCandidateInvocationContext`;
6. downloads the exact preparation artifact by immutable artifact ID using the
   approved action with `skip-decompress: true` and
   `digest-mismatch: error`;
7. proves the download directory contains exactly one ordinary file;
8. invokes the production helper with the propagated bare upload digest,
   exact roots/paths, and supplied artifact/run/attempt labels;
9. builds the selected LF/CRLF source fixture in a separate job-owned checkout
   copy without changing tracked blobs;
10. runs the exact generator under the selected edition;
11. requires all four generated fixture files to equal the four extracted
    candidate files byte-for-byte;
12. proves candidate/fixture bytes are BOM-less and CR-free; and
13. tears down through the two production cleanup lifecycles after stream
    disposal.

No cell selects an artifact by name or expands it automatically. A failure in
action digest verification is distinct from a helper-computed digest mismatch.

### 4. Gate promotion with one terminal approval

Create one read-only approval/aggregate job that:

- depends on preparation, Markdown/Ubuntu validation, and all four Windows
  cells;
- uses `if: always()` so failed or unexpectedly skipped dependencies cannot
  disappear;
- requires every mandatory dependency result to be success;
- verifies all cells report the same artifact ID/digest/event SHA/ref;
- verifies the matrix contains exactly the four expected cells;
- verifies `has_changes` is a canonical `true` or `false`; and
- emits one promotion authorization only for push-to-`main` plus
  `has_changes=true`.

Pull requests finish after approval evidence. A no-change push reports success
without invoking the writer. Cancellation never creates diagnostic artifacts
or a write.

### 5. Snapshot writer identity once

The writer runs only for an approved push to `main` with changes and declares:

```yaml
permissions:
  contents: write
```

Pass purpose-specific `TARGET_REF` and `EXPECTED_SHA` plus GitHub's event
`GITHUB_REF` and `GITHUB_SHA` as environment data. The first executable
PowerShell statements are:

```powershell
$strTargetRef = [string]$env:TARGET_REF
$strExpectedSha = [string]$env:EXPECTED_SHA
$strGitHubRef = [string]$env:GITHUB_REF
$strGitHubSha = [string]$env:GITHUB_SHA
```

Then:

1. reject empty values, leading/trailing whitespace, CR/LF, NUL, and controls;
   never trim or rewrite identity;
2. require both refs to be in `refs/heads/`, pass
   `git check-ref-format`, and match ordinally/case-sensitively;
3. require both SHAs to be complete hexadecimal IDs for the repository's
   active object format, resolve as commit objects, and match their canonical
   IDs case-insensitively;
4. capture every native Git exit immediately; and
5. never read those four environment variables again.

Use `$strTargetRef` and `$strExpectedSha` unchanged for checkout verification,
remote preflight, commit parent, lease, and destination refspec. Keep data as
arguments; do not insert GitHub expressions into script source or build a shell
command string.

### 6. Revalidate artifact and candidate in the writer

Before token expansion or repository mutation, the writer:

1. checks out the exact expected commit with credentials disabled;
2. proves clean working tree/index and exact `HEAD`;
3. runs the exact permanent helper harness;
4. creates a new caller context;
5. downloads the exact artifact by immutable ID with decompression disabled
   and action digest mismatch treated as error;
6. invokes the exact production helper with the propagated bare digest;
7. proves all four extracted files equal preparation's recorded hashes;
8. runs the generator from the expected commit in a separate controlled
   location and proves byte equality with the extracted candidate; and
9. disposes streams and applies both exact cleanup lifecycles.

No writer logic may trust matrix filesystem state, an artifact name, or a
candidate from another job.

### 7. Prove remote state and create one exact commit

Before copying candidates into the checkout:

1. run `git ls-remote --exit-code origin $strTargetRef`;
2. require exactly one `<complete-object-id><TAB><exact-ref>` record;
3. require the object ID to equal `$strExpectedSha`;
4. require local `HEAD` to equal the same commit; and
5. abort without mutation on every mismatch.

Copy exactly the four validated candidate files into their exact repository
destinations using explicit paths. Then:

- require complete working-tree changes to equal those four paths;
- stage exactly those four paths;
- require exact cached path equality;
- require each staged blob hash/bytes to equal its candidate file;
- require no BOM/CR;
- create one commit with fixed bot identity and approved message;
- require exactly one parent equal to `$strExpectedSha`;
- require committed blobs to equal candidate/staged blobs; and
- require no other tree path to differ from the expected parent.

If candidate bytes equal `HEAD`, do not commit or push; report a no-op
inconsistency because preparation should have set `has_changes=false`.

### 8. Expand credentials only for the exact push

Keep xtrace disabled and verify it remains disabled before credential
expansion. Do not place the token in a remote URL, command string, ordinary
file, output, artifact, or diagnostic.

Supply the token through one process-scoped environment-backed Git HTTP
authorization configuration for the single push, restore/remove all temporary
environment values in `finally`, and unset any Git credential state before
cleanup.

Push exactly:

```text
--force-with-lease=<validated-target-ref>:<validated-expected-sha>
HEAD:<validated-target-ref>
```

Do not use bare `git push`, `--force`, an implicit destination, a retry, or a
weaker lease. Capture exit immediately. On rejection, fail and leave the remote
unchanged. On success, query the exact remote ref and require it equals the new
commit.

### 9. Add controlled negative drills

Before enabling writes to `main`, use a unique temporary branch and controlled
artifact/run fixtures to prove:

- propagated digest altered to another well-formed 64-hex value fails before
  ZIP construction/candidate creation;
- malformed/extra/duplicate/path-traversal transport fails through the real
  helper;
- ref mismatch, SHA mismatch, malformed ref, and malformed SHA fail before
  credentials or push;
- stale remote preflight fails before local publication;
- a race after preflight loses the exact lease;
- no-op produces no commit/push;
- unrelated branch/pull-request events cannot write;
- required matrix failure blocks approval/writer;
- an unexpected skipped dependency blocks approval;
- token sentinels never appear in logs, artifacts, process command records, or
  files; and
- all failed drills leave the protected remote target unchanged.

Identity drills mutate separate test-local copies, never the four production
environment inputs.

### 10. Bound diagnostics and record CI cost

Upload diagnostics only after ordinary failure, never success or cancellation.
Use collision-free names, redact secrets and signed URLs, include only
test-owned logs/fixtures, and set `retention-days: 7`. A diagnostic upload
failure must not hide the primary failure.

Retain complete Ubuntu plus four-cell Windows coverage on pull requests and
pushes. After at least ten qualifying runs of each event, record per-job
duration, queue time, total duration, failure/rerun cause, and diagnostic
bytes. Review quarterly.

Open a real topology follow-up if:

- median end-to-end validation exceeds 15 minutes;
- p95 exceeds 25 minutes;
- diagnostic storage exceeds 250 MB/month;
- runner availability materially blocks contributors; or
- repeated measured evidence supports replacing a redundant cell.

Re-evaluate immediately if the repository becomes private, standard-runner
billing changes, larger runners are proposed, or retention policy changes.
Cost does not silently remove a security cell.

## Reciprocal workflow comparison

At implementation start and before merge, extend the T1A reciprocal matrix to
cover:

- artifact identity/digest transport;
- action pins and role allowlist;
- triggers and permissions;
- matrix/approval topology;
- at-use harness placement;
- writer identity, remote preflight, staging, commit, lease/refspec, and no-op;
- diagnostics/retention; and
- CI coverage/cost decisions.

Record same, intentional difference, or blocker with exact workflow/test
evidence. Repository-local artifact names and job IDs may differ. An
unexplained security or observable failure difference blocks merge.

## Validation

### Static and local

Prove:

- only the two affected workflow files changed/staged;
- every action equals the final exact role allowlist;
- permissions are read-only except the writer job;
- events are unfiltered as required;
- no automatic extraction, mutable action, credential persistence, cache,
  remote reusable workflow, command-string Git, recursive cleanup, or
  skip-commit behavior exists;
- package/lock/hook/lint config and all four generated artifacts are unchanged;
- both workflow YAML files parse; and
- the generator/helper/context/harness versions match exact prerequisites.

### Pull-request evidence

Require:

- Node 24 clean install and both lints;
- Ubuntu full helper harness;
- one immutable candidate ID/digest;
- all four Windows cells, every applicable stable ID, and exact byte equality;
- read-only approval completion; and
- no writer job.

### Push and writer evidence

Use the controlled temporary branch first. Require:

- exact preparation ID/digest propagation;
- all four Windows cells;
- terminal approval;
- one writer only when changed;
- four-local identity and exact remote preflight;
- candidate/destination/staged/committed blob identity;
- one expected-parent commit;
- exact lease/refspec;
- remote ref equals new commit; and
- every negative drill leaves the remote unchanged.

After controlled evidence passes, enable the exact `main` topology and retain
the run URLs/IDs in the issue.

## Acceptance criteria

- [ ] The workflow runs unfiltered required validation for PRs to and pushes
      on `main`.
- [ ] Only the writer has `contents: write`; every checkout disables persisted
      credentials.
- [ ] External actions equal the exact repository/SHA/role/count allowlist.
- [ ] Preparation uploads exactly one immutable four-file candidate and
      propagates ID plus bare digest.
- [ ] Ubuntu and every Windows cross-product cell invoke the exact production
      harness/helper.
- [ ] Downloads use immutable ID, no automatic extraction, and action digest
      mismatch failure.
- [ ] Approval detects failed and unexpectedly skipped dependencies.
- [ ] Pull requests and no-change pushes cannot write.
- [ ] The writer snapshots/validates four identity values once and never
      rereads them.
- [ ] Remote preflight, parent, lease, and refspec use the same validated pair.
- [ ] Candidate, destination, staged, committed, and remote bytes/IDs match.
- [ ] Credentials exist only for one exact push and never appear in evidence.
- [ ] Digest, manifest, identity, stale-preflight, lease, no-op, event, and
      token drills pass.
- [ ] Failure diagnostics are bounded, redacted, failure-only, and retained
      seven days.
- [ ] Full matrices remain enabled and the measured-cost review is assigned.
- [ ] Only `build.yml` and `markdownlint.yml` are in the changed/staged set.
- [ ] T2 records this issue's exact merge commit as its prerequisite.

## Non-goals

- Changing generator/helper/context/harness code.
- Changing package, lockfile, hook, lint, or Node contributor policy.
- Changing source guides or generated artifact content.
- Supporting arbitrary artifact producers or external workflows.
- Retrying/rebasing a stale writer.
- Using concurrency cancellation as correctness.
- Adding a shared cross-repository runtime.

## References

- [GitHub artifact attestations and security](https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations)
- [upload-artifact](https://github.com/actions/upload-artifact)
- [download-artifact](https://github.com/actions/download-artifact)
- [Workflow permissions](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions#permissions)
- [Matrix jobs](https://docs.github.com/en/actions/how-tos/write-workflows/choose-what-workflows-do/run-job-variations)
- [Git check-ref-format](https://git-scm.com/docs/git-check-ref-format)
- [Git push and leases](https://git-scm.com/docs/git-push)
- [GitHub Actions billing and usage](https://docs.github.com/en/actions/concepts/billing-and-usage)
