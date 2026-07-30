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
- stop if either merged contract or the reciprocal PS/Terraform generator or
  candidate-validation-layer comparison has an unresolved blocker.

**Make state-version discovery and recovery examples copy-safe with guarded
identifiers** is blocked by this issue. Before T1B merges, record the reviewed
T1B head, final evidence runs, the T2 handoff location, and the accountable
handoff owner. After merge, that owner records the actual protected-branch
landed commit, merge method/time, issue/PR links, and reviewed-head distinction
in T2; T2 independently validates that commit before editing.

## Affected files

Exactly these three files may change:

- `.github/workflows/build.yml`;
- `.github/workflows/markdownlint.yml`;
- `.github/workflows/Validate-WorkflowPolicy.mjs`.

Extend T1's existing permanent offline workflow-policy validator and locked
direct parser; do not add a second validator/parser or change package/lock
bytes. Do not change the
generator, helper, context lifecycle, helper harness, hook, lint configuration,
source guides, or generated artifacts in this issue. T3 later owns the final
package upgrade/audit state and must retain/revalidate this direct parser and
validator.

## Global workflow invariants

- Run `pull_request` for every pull request targeting `main`.
- Run `push` for every push to `main`.
- Do not use workflow-level path filters or a skip-commit convention.
- Add `merge_group` if the repository enables merge queue and requires these
  checks.
- Set workflow/top-level `permissions: {}`.
- Give every job its exact permissions below; give `contents: write` only to
  the final synchronization writer job.
- Use only standard GitHub-hosted runners.
- Use `persist-credentials: false` on every checkout.
- Do not use caches, service containers, reusable remote workflows, or
  unreviewed external actions.
- Permit only the exact repository-local `markdownlint.yml` reusable workflow
  called by `build.yml`.
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

Every `uses:` line must use a full SHA plus matching release annotation.

Extend T1's `.github/workflows/Validate-WorkflowPolicy.mjs` and its existing
locked direct YAML parser. Keep strict core-schema parsing, unique keys,
warnings-as-errors, and the complete T1 rejection of directives, tags,
anchors/aliases, merges, multidocument streams, complex keys, and non-JSON-like
values. The validator accepts the two exact workflow paths,
never fetches the network, and enforces:

- exact events and event filters;
- workflow/called-workflow/job permissions;
- direct job dependencies and event conditions;
- the exact local reusable-workflow path;
- action repository/SHA/release annotation/step role/count;
- checkout credential persistence;
- Node version/cache settings;
- artifact upload/download options;
- static Windows matrix IDs and unique outputs; and
- one and only one contents-writing writer.

Require exact equality to the normative
workflow/job/step-role/repository/SHA/count/input tables. Encode exactly these
roles:

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

The hand-authored issue/validator tables determine exact counts; parsed YAML
never defines policy. Reject missing, duplicate, extra, dynamic,
mutable, wrong-repository, arbitrary-SHA, and swapped upload/download roles.
Add stable positive and negative fixtures for those states plus duplicate YAML
keys, invalid job dependencies, an extra write permission, persisted
credentials, wrong local reusable workflow, and wrong matrix/output mapping.
The verifier is deterministic and offline. Update `uses:`, annotation,
issue tables, validator constants, workflow, action provenance/default review,
and fixtures atomically on an intentional upgrade.

## Requested changes

### 1. Replace the temporary writer and establish one job graph

Delete every T1 temporary pre-promotion generation/commit/push step. Do not
disable or retain it as a fallback. Structurally prove there is exactly one
contents-writing job and one push path after this issue; version control is the
rollback mechanism.

`build.yml` owns all external events: every pull request targeting `main`,
every push to `main`, and `merge_group` when the repository enables merge
queue. Convert `markdownlint.yml` to an exact repository-local reusable
workflow exposed through `workflow_call`; remove its independent
pull-request/push triggers so validation is not duplicated.

Call `markdownlint.yml` as a read-only job in `build.yml` for the same event
SHA. A called-workflow failure is therefore a direct same-run dependency result
available to the terminal approval job. Do not use `workflow_run`, duplicate
the lint steps in `build.yml`, or rely on branch protection to gate a push
writer.

### 2. Keep called Markdown validation read-only

In `.github/workflows/markdownlint.yml`:

- expose only the reviewed `workflow_call` interface;
- preserve exact hosted Node 24 and `package-manager-cache: false`;
- assert actual Node major 24;
- perform clean `npm ci`;
- invoke the exact tracked `Validate-WorkflowPolicy.mjs` against
  `build.yml`/`markdownlint.yml` and all mandatory policy fixtures;
- run the unchanged outer and nested lint commands;
- invoke the exact tracked T1A harness against the exact tracked helper under
  PowerShell 7 on Ubuntu;
- verify both production scripts and harness are ordinary non-reparse files
  before invocation; and
- retain `contents: read` only.

The helper harness runs independently of whether generated artifacts changed.
The later T2 issue may add its state-recovery shell harness as a separate
stable step without weakening these invariants.

### 3. Prepare one immutable candidate

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
10. records one lowercase bare 64-hex SHA-256 for each exact candidate path and
    records the event SHA/ref;
11. uploads exactly the four explicit paths once with no hidden files,
    overwrite, or mutable name reuse; and
12. emits only the upload action's immutable artifact ID, bare hexadecimal
    artifact digest, unique artifact name, `has_changes`, event SHA, full
    target ref, and these four statically named job outputs:
    - `copilot_instructions_sha256`;
    - `terraform_instructions_sha256`;
    - `style_guide_chat_sha256`; and
    - `style_guide_full_sha256`.

Use a collision-free name containing run ID and attempt. Do not derive trust
from the artifact name. The bare `artifact-digest` output is the only expected
ZIP digest supplied to the helper.

Upload on both pull requests and pushes, including no-change candidates, so
the matrix always validates an actual transport. Use the shortest repository-
approved retention that still permits investigation; the candidate is not a
release artifact.

All downstream consumers require each hash to be lowercase bare 64-hex and map
it to one fixed repository path. The values are nonsecret and remain far below
GitHub job-output limits. Never obtain a preparation hash from the uploaded ZIP
or a job log/summary.

### 4. Validate the exact candidate on Windows

Create a four-cell matrix:

| Edition | Fixture source EOL |
| --- | --- |
| Windows PowerShell exactly 5.1 | LF |
| Windows PowerShell exactly 5.1 | CRLF |
| PowerShell Core major 7 | LF |
| PowerShell Core major 7 | CRLF |

Set `strategy.fail-fast: false` and assign these immutable IDs in the static
matrix:

- `windows-powershell-5.1-lf`;
- `windows-powershell-5.1-crlf`;
- `powershell-7-lf`; and
- `powershell-7-crlf`.

Every cell:

1. performs a transient authenticated checkout with persistence disabled, then
   verifies the exact event SHA;
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
    disposal; and
14. emits only its own statically declared evidence output key.

No cell selects an artifact by name or expands it automatically. A failure in
action digest verification is distinct from a helper-computed digest mismatch.

Declare four unique job outputs, one per canonical cell ID. Each cell writes
only its own key. The value is compact canonical JSON containing the cell ID,
artifact ID/digest, event SHA, full target ref, and the four preparation
hashes. GitHub does not guarantee matrix completion order, so a shared output
name is prohibited. The approval job rejects a missing, empty, duplicate,
extra, malformed, wrong-key, or mismatched payload. No output value authorizes
promotion unless the overall matrix job result is `success`.

### 5. Gate promotion with one terminal approval

Create one read-only approval/aggregate job that:

- directly depends on preparation, the called Markdown/Ubuntu workflow, and
  the four-cell Windows matrix job;
- uses `if: always()` so failed or unexpectedly skipped dependencies cannot
  disappear;
- requires every mandatory dependency result to be success;
- verifies all four unique cell outputs report the same artifact ID/digest,
  event SHA/ref, and four preparation hashes;
- verifies the output key set and embedded cell-ID set are exactly the four
  expected cells;
- verifies `has_changes` is a canonical `true` or `false`; and
- emits one promotion authorization only for push-to-`main` plus
  `has_changes=true`.

Pull requests finish after approval evidence. A no-change push reports success
without invoking the writer. Cancellation never creates diagnostic artifacts
or a write.

### 6. Snapshot writer identity once

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

### 7. Revalidate artifact and candidate in the writer

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

### 8. Prove remote state and create one exact commit

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

### 9. Expand credentials only for the exact push

Keep xtrace disabled and verify it remains disabled before credential
expansion. Do not place the token in a remote URL, command string, ordinary
file, output, artifact, or diagnostic.

Bind `github.token` as a masked environment secret only on the exact push step.
Inside that step, construct the Basic authorization header in memory and expose
it only to the `git push` child through process-scoped `GIT_CONFIG_COUNT`,
`GIT_CONFIG_KEY_0`, and `GIT_CONFIG_VALUE_0`. Restore/remove the token,
header, and Git-config environment in `finally`; unset any Git credential state
before cleanup. All preflight and post-push `ls-remote` diagnostics run without
those values.

Push exactly:

```text
--force-with-lease=<validated-target-ref>:<validated-expected-sha>
HEAD:<validated-target-ref>
```

Do not use bare `git push`, `--force`, an implicit destination, a retry, or a
weaker lease. Capture exit immediately. On rejection, fail and leave the remote
unchanged. On success, query the exact remote ref and require it equals the new
commit.

### 10. Add controlled negative drills

Before enabling writes to `main`, use the exact
`refs/heads/t1b-evidence/<utc>-<random>` protocol and allowed-delta manifest in
section 14 with controlled artifact/run fixtures to prove:

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

### 11. Bound diagnostics and record CI cost

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

### 12. Enforce one complete authored job/role/data-flow policy

The job graph is exact:

| Job | Direct needs | Exact permission | Eligibility/ownership |
| --- | --- | --- | --- |
| `markdown` | none | `contents: read` | calls only `./.github/workflows/markdownlint.yml`; no steps or inherited secrets |
| `prepare` | none | `contents: read` | checkout, generation, hashes, immutable upload, outputs |
| `validate_windows` | `prepare` | `contents: read` | static four-cell matrix; one cell-specific result each |
| `approve` | `markdown`, `prepare`, `validate_windows` | `{}` | `always()`; one decision for success/failure/skipped/no-change |
| `writer` | `prepare`, `validate_windows`, `approve` | `contents: write` | exact protected-main push, approval success, `has_changes == 'true'` |

Only these static action roles exist:

| Role ID | Static count | Expanded runtime count |
| --- | ---: | ---: |
| `prepare.checkout` | 1 | 1 |
| `prepare.upload-candidate` | 1 | 1 |
| `windows.checkout` | 1 | 4 |
| `windows.download-candidate` | 1 | 4 |
| `windows.upload-failure-diagnostics` | 1 | 0–4 |
| `writer.checkout` | 1 | 0–1 |
| `writer.download-candidate` | 1 | 0–1 |
| `writer.upload-failure-diagnostics` | 1 | 0–1 |
| `markdown.checkout` | 1 | 1 |
| `markdown.setup-node` | 1 | 1 |

For every row, the validator stores the exact job/step ID and order,
action/full SHA/release annotation, semantic YAML scalar type and `with`
key/value map, `if`, `continue-on-error`, permissions, environment-key set,
side effect, and output owner. It first rejects missing/extra roles, then
compares values. Expressions must equal one authorized expression text and may
not be composed or sourced elsewhere.

Every checkout uses T1's complete explicit input set, with
`repository: ${{ github.repository }}`, the role's exact event/ref SHA,
`token: ${{ github.token }}`, and `persist-credentials: false`. Setup Node
uses T1's exact Node-24/token/cache input set. Each role has a separate closed
omitted-default table keyed by pinned action/input/upstream default/rationale/
security consequence; an undocumented or unknown omission fails.

Candidate upload uses collision-free
`style-guide-candidate-${{ github.run_id }}-${{ github.run_attempt }}`, the
four literal generated paths, `if-no-files-found: error`,
`retention-days: 1`, `compression-level: 0`, `overwrite: false`, and
`include-hidden-files: false`. Windows and writer downloads select only
`artifact-ids: ${{ needs.prepare.outputs.candidate_artifact_id }}`, use their
new protected context download directory, `skip-decompress: true`, and
`digest-mismatch: error`; `name`, `pattern`, `merge-multiple`, `github-token`,
`repository`, and `run-id` are absent.

Failure diagnostic upload runs only under
`failure() && !cancelled()`, is `continue-on-error: true`, names only exact
test-owned diagnostic paths, uses a collision-free job/cell/run/attempt name,
7-day retention, explicit missing-file behavior, no hidden files/overwrite,
and cannot mask the primary result. Candidate archives, arbitrary workspace
trees, tokens, state, signed URLs, and Git configuration are forbidden.

Producer/consumer outputs are exact:

- `prepare` owns artifact ID, bare artifact digest, diagnostic-only unique
  name, event SHA, target ref, `has_changes`, and four path-bound hashes;
- each static matrix include row owns immutable cell ID, runner, executable,
  expected edition/version, source EOL, and one unique output key;
- each cell emits one closed canonical JSON result under only that key;
- `approve` directly consumes preparation, every cell, and Markdown results;
  it rejects empty/duplicate/wrong IDs/keys and schema/hash mismatch; and
- `writer` directly needs every producer whose output/result it reads.

No transitive `needs` assumption is allowed. Fixtures cover every table
dimension, name-based or implicit decompression, cross-run selection, correct
action in wrong role, missing direct need, shared output key, success/
cancellation diagnostics, wildcard/hidden diagnostic paths, and a dormant
second writer.

### 13. State the job-token and Git-push boundary truthfully

GitHub creates a job token before each job and `github.token` remains available
to execution steps. Job permissions bound authority; no job is described as
token-free or credential-free. Read jobs have only `contents: read`; only
`writer` has `contents: write`.

The writer checkout explicitly receives the write-capable job token for
authenticated fetch but does not persist it. Immediately afterward, a
presence-only check rejects an origin with embedded credentials, credential
helpers, or local/global HTTP authorization configuration without printing any
value. The write job may run only its named checkout/download, local reviewed
scripts, fixed Git operations, and failure-diagnostic role—never downloaded
candidate code, untrusted PR code, a remote workflow, or command-string eval.

Only reviewed action `token` inputs may explicitly expand `github.token`.
Only the exact guarded push step may construct the Basic authorization header
and pass it via process-scoped `GIT_CONFIG_COUNT`/key/value variables to the
one direct `git push` child. Every candidate/regeneration/ref/SHA/parent/tree/
lease/path/diagnostic check completes before construction. Clear variables in
`finally`; never place credentials in args, files, remotes, Git config,
outputs, artifacts, or logs. Other scripts receive no explicit token/header/
helper/config environment.

### 14. Prove the real writer on one isolated evidence ref

After static/local/PR evidence, record the final production candidate commit as
`PRODUCTION_BASE`. Create one unpredictable lowercase
`refs/heads/t1b-evidence/<utc>-<random>` at that commit. Evidence-only commits
remain on that ref and are never merged, rebased, cherry-picked, or squashed
into production.

On that branch only, patch the same `build.yml` and validator constants. An
upfront allowed-delta manifest lists the exact file/hunk/old/new literals that
change the push filter, approval ref, writer condition, `TARGET_REF`, bounded
scenario instrumentation, closed selector, and one source-guide fixture from
`main` to the evidence ref. Reject any other permission, graph, action/input,
candidate, credential, path, commit, lease, refspec, diagnostic, or event
delta. Do not use `workflow_dispatch`, `repository_dispatch`, a caller ref,
wildcard/prefix, secret inheritance, or a copied writer.

The positive evidence source edit deterministically changes generated bytes.
The normal prepare/matrix/approval/real-writer flow must move only the evidence
ref from the event/`EXPECTED_SHA` to one child commit whose tree differs only
at the four generated paths and whose blobs equal propagated hashes. Record
the exact lease/refspec and prove the token-created commit did not recursively
start a run.

Each negative drill is a separate evidence-only commit selected by a closed
enum incapable of carrying a ref/path/command/credential/expression/data.
Before each drill, a maintainer/controller advances the evidence ref with its
own expected-old lease. Record scenario commit, run ID/URL, phase/status,
remote before/after, approval/writer result, diagnostic artifact identity, and
sentinel scan. The stale race makes a separate controlled ref update after
preflight so the unchanged exact writer lease loses.

Do not modify main protection. A smallest temporary rule change may target
only the evidence ref and must have byte/field-equivalent before-state restored
and verified in `finally`, or production enablement is blocked. Cleanup waits
for/cancels all runs, restores settings, deletes the remote ref with an
expected-old guard, proves it absent, removes the local branch, and proves no
rule/environment/policy/active run still names it.

Before main enablement, prove the production candidate descends from
`PRODUCTION_BASE`, contains no evidence commit/string/scenario/instrumentation/
fixture/alternate condition/event/push path, and exactly restores the main-only
normative tables and fixtures. Retain commits, manifest/result, runs, artifact
identity/digest/four hashes, ref/parent/tree evidence, setting before/after,
and cleanup results—never credentials or signed URLs.

### 15. Use one byte-safe Git/status policy and a satisfiable handoff

Extend T1's one validator and hand-authored role schema; do not add a policy
generator or derive constants from positive YAML. All affected-file, evidence-
variant, worktree/index, commit/parent, and generated-four gates read native Git
stdout bytes from NUL-delimited modes. Require empty or one terminal NUL, split
only on `00`, reject interior empty/duplicate/malformed records, and compare
sorted raw canonical repository-path byte sequences.

Run difference predicates separately and classify native status exactly:
`0` no difference, `1` difference, every other status/start failure a tool
failure. Record each command's endpoints and equality/subset/empty oracle.
Fixtures include spaces, tabs, newlines, leading dash, quote/escape characters,
missing-final-NUL, status `0/1/2`, start failure, and combined misleading
path/status/extra-role attacks.

Before merge, record full **reviewed head**, exact script versions parsed under
T1's `.NOTES` contract, final run IDs, T2 blocked-by link, handoff location, and
owner. Do not call the reviewed head a merge commit. T2 records and validates
the actual landed protected-branch commit after merge (merge, squash, or rebase
result), preserving both identities and revalidation evidence when they differ.

## Reciprocal PSStyleGuide writer-layer comparison

At implementation start and before merge, record the exact PSStyleGuide commit
and current writer-layer location: the P1 writer section or eventual P1B
identifier. Extend the reciprocal comparison to cover:

- artifact identity/digest transport;
- action pins and role allowlist;
- triggers and permissions;
- matrix/approval topology;
- at-use harness placement;
- writer identity, remote preflight, staging, commit, lease/refspec, and no-op;
- diagnostics/retention; and
- CI coverage/cost decisions.

Record same, intentional difference, or blocker with exact workflow/test
evidence. Repository-local artifact names, event names, guide paths, and job
decomposition may differ with rationale. Wider credential persistence, weaker
artifact selection, absent trusted regeneration, ambiguous Git object identity,
or a weaker lease is a blocker. The semantic writer-layer name remains stable
if PS planning files are renamed or split.

## Validation

### Static and local

Prove:

- only the three affected files changed/staged;
- every action equals the final exact role allowlist;
- permissions are read-only except the writer job;
- events are unfiltered as required;
- no automatic extraction, mutable action, credential persistence, cache,
  remote reusable workflow, command-string Git, recursive cleanup, or
  skip-commit behavior exists;
- the T1 temporary writer and every second/dormant push path are absent;
- package/lockfile bytes and T1's locked direct parser remain unchanged;
- hook/lint config and all four generated artifacts are unchanged;
- the tracked structural validator passes both workflows and every mandatory
  positive/negative fixture; and
- the generator/helper/context/harness versions match exact prerequisites.

### Pull-request evidence

Require:

- Node 24 clean install and both lints;
- Ubuntu full helper harness;
- one immutable candidate ID/digest;
- all four unique Windows output keys/cell IDs, every applicable stable ID,
  exact byte equality, and matching candidate hashes;
- read-only approval completion; and
- no writer job.

### Push and writer evidence

Use the exact isolated evidence-ref protocol first. Require:

- exact preparation ID/digest/four-hash propagation;
- all four unique Windows cells;
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
- [ ] `build.yml` is the event owner; the repository-local callable
      `markdownlint.yml` is a direct same-run approval dependency with no
      duplicate independent triggers.
- [ ] Workflow default permissions are empty; only the writer has
      `contents: write`; checkout authentication is transient and every
      checkout disables persistence.
- [ ] External actions equal the exact repository/SHA/role/count allowlist.
- [ ] The tracked locked-parser validator structurally enforces workflow,
      action, dependency, matrix, output, credential, and permission policy.
- [ ] Preparation uploads exactly one immutable four-file candidate and
      propagates ID, bare digest, and four path-bound hashes.
- [ ] Ubuntu and every Windows cross-product cell invoke the exact production
      harness/helper.
- [ ] Exactly four unique matrix output keys map to the four canonical cell IDs
      and carry matching candidate identity/hashes.
- [ ] Downloads use immutable ID, no automatic extraction, and action digest
      mismatch failure.
- [ ] Approval detects failed and unexpectedly skipped dependencies.
- [ ] Pull requests and no-change pushes cannot write.
- [ ] The writer snapshots/validates four identity values once and never
      rereads them.
- [ ] Remote preflight, parent, lease, and refspec use the same validated pair.
- [ ] Candidate, destination, staged, committed, and remote bytes/IDs match.
- [ ] Only the guarded writer push process receives an explicit Git push
      authorization header; token expansions are limited to the normative
      action inputs and push role and never appear in evidence.
- [ ] Digest, manifest, identity, stale-preflight, lease, no-op, event, and
      token drills pass.
- [ ] Failure diagnostics are bounded, redacted, failure-only, and retained
      seven days.
- [ ] Full matrices remain enabled and the measured-cost review is assigned.
- [ ] The T1 temporary writer is removed and exactly one push path remains.
- [ ] The reciprocal PS writer-layer/Terraform matrix has no unexplained
      blocker.
- [ ] Only the three declared affected files are in the changed/staged set.
- [ ] The reviewed T1B head, T2 blocked-by relationship, handoff location, and
      owner are recorded; T2 must record and validate the actual landed commit
      after this issue merges.

## Non-goals

- Changing generator/helper/context/harness code.
- Changing package/lockfile beyond the direct YAML parser, or changing hook,
  lint, or Node contributor policy.
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
- [Workflow job outputs](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#jobsjob_idoutputs)
- [Reusable workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows)
- [Git check-ref-format](https://git-scm.com/docs/git-check-ref-format)
- [Git push and leases](https://git-scm.com/docs/git-push)
- [GitHub Actions billing and usage](https://docs.github.com/en/actions/concepts/billing-and-usage)
