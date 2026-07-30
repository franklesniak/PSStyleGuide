# Promote generated style-guide artifacts through a least-privileged verified writer

## Summary

Replace P1's temporary direct publication with one immutable, digest-bound
candidate pipeline. Preparation creates one candidate. Ubuntu and the complete
Windows PowerShell edition × fixture-EOL matrix validate that exact artifact
through the tracked production helper/context/harness. One terminal approval
checks exact dependency results, four path-bound hashes, and four unique cell
attestations. The only
write-enabled job revalidates/regenerates at use, snapshots four identity
values once, stages exactly four files, and performs one explicit
expected-SHA-lease push.

Every checkout disables persisted credentials. GitHub's ephemeral job token is
write-capable for the complete minimal writer job. The pinned checkout may use
it transiently for fetch and must remove retained state; repository validation
receives no ordinary token variable, and only the exact push child process
receives the masked derived authorization header.

## Dependencies

Implement only after:

1. P1, **Make artifact generation byte-deterministic across PowerShell
   editions and hosts**; and
2. P1A, **Add a fail-closed cross-platform style-guide candidate validator**.

Before filing/readying P1B, insert both canonical PSStyleGuide predecessor
URLs, create/verify the real GitHub blocked-by relationships, and retrieve all
three issues to verify repository/number/title/relationships. Do not use
placeholders.

Record P1/P1A actual issue URLs, real GitHub blocked-by relationships, and
exact merge commits. Before editing workflows:

- run P1's complete generator/runtime/action baseline;
- run every applicable P1A stable ID;
- validate exact ordinary-file identities and script versions for generator,
  helper, context manager, harness, workflow-policy validator/parser, and Git
  path-set verifier;
- require P1's advisory-risk decision to remain active and uncontradicted; and
- stop if P1↔T1 or P1A↔T1A has an unresolved blocker.

P2 is blocked by P1B.

## Affected files

Exactly:

- `.github/workflows/build.yml`; and
- `.github/workflows/markdownlint.yml`; and
- `.github/workflows/Validate-WorkflowPolicy.mjs`.

Do not change generator/helper/context/harness/path-verifier code,
package/lock/hook/lint configuration, source guides, generated artifacts,
`.gitattributes`, or Dependabot. Prove P1's reviewed direct YAML parser and
complete package/lock bytes remain exact. If evidence requires a parser
change, stop, recompute scope to include both package files, and repeat
provenance/audit/install review before editing.

## Global workflow invariants

- `build.yml` is the sole external event owner.
- `build.yml` runs `pull_request` for every pull request targeting `main`.
- `build.yml` runs `push` for every push to `main`.
- `markdownlint.yml` exposes only an exact local `workflow_call` interface and
  has no independent external trigger.
- `build.yml` calls `./.github/workflows/markdownlint.yml` in a stable
  `validate_markdown` job from the same commit.
- No workflow-level path filter or skip-commit convention.
- Add `merge_group` only if merge queue requires these checks.
- Workflow/top-level permissions are `contents: read`.
- Only the final writer job has `contents: write`.
- Standard GitHub-hosted runners only.
- Every checkout uses `persist-credentials: false`.
- No cache, service container, remote reusable workflow, automatic artifact
  extraction, or unreviewed external action.
- Correctness does not rely on workflow concurrency. A stale run loses exact
  SHA/ref checks or the lease.
- Every complete PowerShell block uses P1's native-command contract.

## Exact external-action role table

Immediately before implementation and again immediately before merge,
re-resolve each official release tag and retain timestamped
provenance/action-manifest evidence. A changed target, provenance, release
record, manifest digest, or security-relevant default stops merge for renewed
review:

| Action | Full SHA | Reviewed release |
| --- | --- | --- |
| `actions/checkout` | `3d3c42e5aac5ba805825da76410c181273ba90b1` | `v7.0.1` |
| `actions/setup-node` | `820762786026740c76f36085b0efc47a31fe5020` | `v7.0.0` |
| `actions/upload-artifact` | `043fb46d1a93c77aae656e7c1c64a875d1fc6a0a` | `v7.0.1` |
| `actions/download-artifact` | `3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c` | `v8.0.1` |

This table is the sole normative final role inventory:

| Workflow | Job/step IDs | Action/release | Condition | Exact explicitly declared inputs |
| --- | --- | --- | --- | --- |
| `build.yml` | `prepare_candidate/checkout_repository` | checkout `3d3c42e5aac5ba805825da76410c181273ba90b1` (`v7.0.1`) | ordinary step | `ref: ${{ github.sha }}`; `persist-credentials: false` |
| `build.yml` | `prepare_candidate/upload_candidate` | upload `043fb46d1a93c77aae656e7c1c64a875d1fc6a0a` (`v7.0.1`) | ordinary step | unique run/attempt name; four explicit paths; `if-no-files-found: error`; `retention-days: 7`; `overwrite: false`; `include-hidden-files: false`; `archive: true` |
| `build.yml` | `verify_candidate_windows/checkout_repository` | checkout `3d3c42e5aac5ba805825da76410c181273ba90b1` (`v7.0.1`) | ordinary step | `ref: ${{ github.sha }}`; `persist-credentials: false` |
| `build.yml` | `verify_candidate_windows/download_candidate` | download `3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c` (`v8.0.1`) | ordinary step | preparation `artifact-ids`; exact context download path; `skip-decompress: true`; `digest-mismatch: error` |
| `build.yml` | `verify_candidate_windows/upload_failure_diagnostics` | upload `043fb46d1a93c77aae656e7c1c64a875d1fc6a0a` (`v7.0.1`) | `${{ failure() }}` | unique job/matrix/run/attempt name; exact diagnostic paths; `if-no-files-found: warn`; `retention-days: 7`; `overwrite: false`; `include-hidden-files: false`; `archive: true` |
| `build.yml` | `synchronize_generated_artifacts/checkout_repository` | checkout `3d3c42e5aac5ba805825da76410c181273ba90b1` (`v7.0.1`) | ordinary step | `ref: ${{ github.sha }}`; `persist-credentials: false` |
| `build.yml` | `synchronize_generated_artifacts/download_candidate` | download `3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c` (`v8.0.1`) | ordinary step | approval `artifact-ids`; exact context download path; `skip-decompress: true`; `digest-mismatch: error` |
| `build.yml` | `synchronize_generated_artifacts/upload_failure_diagnostics` | upload `043fb46d1a93c77aae656e7c1c64a875d1fc6a0a` (`v7.0.1`) | `${{ failure() }}` | unique job/run/attempt name; exact diagnostic paths; `if-no-files-found: warn`; `retention-days: 7`; `overwrite: false`; `include-hidden-files: false`; `archive: true` |
| `markdownlint.yml` | `markdownlint/checkout_repository` | checkout `3d3c42e5aac5ba805825da76410c181273ba90b1` (`v7.0.1`) | ordinary step | `ref: ${{ github.sha }}`; `persist-credentials: false` |
| `markdownlint.yml` | `markdownlint/setup_node` | setup-node `820762786026740c76f36085b0efc47a31fe5020` (`v7.0.0`) | ordinary step | `node-version: '24'`; `package-manager-cache: false` |

Normative input expansions:

- Candidate name:
  `style-guide-candidate-${{ github.run_id }}-${{ github.run_attempt }}`.
- Candidate path: exact newline-separated
  `copilot-instructions.md`, `powershell.instructions.md`,
  `STYLE_GUIDE_CHAT.md`, `STYLE_GUIDE_FULL.md`, in that order.
- Matrix download path:
  `${{ steps.candidate_context.outputs.download_directory }}`.
- Writer download path:
  `${{ steps.candidate_context.outputs.download_directory }}`.
- Matrix diagnostic name:
  `style-guide-diagnostics-${{ github.job }}-${{ matrix.edition }}-${{ matrix.fixture_eol }}-${{ github.run_id }}-${{ github.run_attempt }}`.
- Writer diagnostic name:
  `style-guide-diagnostics-${{ github.job }}-${{ github.run_id }}-${{ github.run_attempt }}`.
- Diagnostic path:
  `${{ steps.failure_diagnostics.outputs.diagnostic_path }}`.

Both diagnostic steps use `continue-on-error: true`. An explicit YAML input
not listed in the table/normative expansions is prohibited.

For every role, retain a separate **Reviewed effective defaults at pinned
manifest** record containing the full-SHA `action.yml` URL/digest, every input
and default shape, and the effective omitted values affecting credentials,
clean/fetch behavior, caching, artifact selection/extraction, overwrite,
retention, and failure. An omitted key remains real reviewed action behavior;
the validator must not treat it as absent policy.

Use the complete full SHAs and adjacent release comments in YAML. Structurally
parse all workflow YAML and require exact role/explicit-input equality plus
exact reviewed manifest-default metadata. Reject missing, duplicate, extra,
dynamic, mutable, wrong-repository, arbitrary-SHA,
wrong-comment/condition, swapped role, unknown/weakened explicit input, and a
changed test-manifest default without renewed review.

P1's temporary role table is superseded atomically; do not retain two
normative inventories.

## Permanent workflow-policy enforcement

Update P1's exact tracked `.github/workflows/Validate-WorkflowPolicy.mjs`;
do not add a second validator. Retain the reviewed direct YAML parser,
safe/core schema, duplicate-key/alias/custom-tag rejection, stable policy-ID
namespace, and deterministic offline execution.

In addition to exact action roles/explicit keys/default records, prove:

- `build.yml` is the sole external event owner;
- `markdownlint.yml` is call-only and the call uses the same commit;
- exact required events, permissions, jobs, conditions, `needs`, and local
  callable interface;
- preparation ID/digest/four path hashes and their complete consumer flow;
- exact 2×2 matrix, four static emitter mappings, and approval comparisons;
- sole writer/write permission and exact event/`has_changes` predicate; and
- absence of remote/dynamic workflows, mutable actions, cache,
  auto-extraction, persisted credentials, and unknown roles.

Run every P1 policy fixture and add independent negatives for each final-graph
mutation. A missing/skipped negative suite, parser/default drift, or weakened
P1 invariant blocks merge.

Use P1's exact `Test-ExactGitPathSet.ps1` before staging, after staging, and
after final validation. It must prove the complete changed/staged set is
exactly `build.yml`, `markdownlint.yml`, and
`Validate-WorkflowPolicy.mjs`; the P1 package/lock/parser bytes and every other
path remain unchanged.

## Requested changes

### 1. Keep Markdown/Ubuntu validation read-only

In `markdownlint.yml`:

- expose only `on.workflow_call`, with no inputs, secrets, or external event;
- run through `build.yml` job `validate_markdown` using the exact local
  same-commit path and `contents: read`;
- preserve exact Node 24 and disabled setup-node automatic cache;
- assert actual Node major 24;
- perform clean `npm ci`;
- run unchanged outer/nested lint;
- resolve exact tracked helper/context/harness ordinary-file identities and
  versions;
- invoke the harness with exact `HelperPath` and `ContextManagerPath` under
  PowerShell 7 on Ubuntu; and
- retain `contents: read` only.

The helper harness runs even if generated artifacts did not change.
Terminal approval includes `validate_markdown` in its exact same-run `needs`
set.

### 2. Prepare one immutable candidate

One read-only Ubuntu job on pull requests and pushes:

1. checks out exact event SHA without persisted credentials;
2. proves `HEAD` is that commit object;
3. validates generator/helper/context/harness exact tracked ordinary
   identities and versions;
4. runs the exact P1A harness with both explicit script paths;
5. starts clean;
6. runs the exact generator;
7. requires the complete changed path set to be a subset of the four generated
   artifact paths;
8. proves all four are ordinary non-reparse, within reviewed size bounds,
   BOM-less, and CR-free;
9. computes `has_changes` from candidate-versus-`HEAD` blob bytes;
10. records four file SHA-256 values and event SHA/full ref;
11. uploads the four explicit paths once under a collision-free run/attempt
    name; and
12. emits only immutable artifact ID, bare upload digest, unique name,
    canonical `has_changes`, event SHA, full target ref, and these four
    canonical lowercase path-bound outputs:
    - `copilot_instructions_sha256`;
    - `powershell_instructions_sha256`;
    - `style_guide_chat_sha256`; and
    - `style_guide_full_sha256`.

Upload on pull requests and pushes, including no-change candidates, so every
matrix validates real transport. Trust artifact ID plus upload digest, never
the name. Compute the four hashes after all byte/resource checks and before
upload; never reinterpret which path owns a hash.

### 3. Validate the exact candidate in four Windows cells

Matrix:

| Edition | Fixture source EOL | Stable cell key |
| --- | --- | --- |
| Windows PowerShell exactly 5.1 | LF | `desktop/lf` |
| Windows PowerShell exactly 5.1 | CRLF | `desktop/crlf` |
| PowerShell Core major 7 | LF | `core/lf` |
| PowerShell Core major 7 | CRLF | `core/crlf` |

Use `strategy.fail-fast: false`.

Every cell:

1. asserts `strategy.job-total == 4` and exact axes;
2. checks out/verifies event SHA without credentials;
3. resolves/versions exact four production scripts;
4. runs every applicable P1A stable ID;
5. creates a context beneath `RUNNER_TEMP` through the production function;
6. downloads by immutable artifact ID with `skip-decompress: true` and
   `digest-mismatch: error`;
7. proves exactly one ordinary retained archive;
8. invokes the production helper with bare digest, exact roots/paths, and
   supplied labels;
9. builds LF/CRLF source fixtures in a separate owned checkout copy;
10. runs the exact generator under the selected edition;
11. compares all four outputs byte-for-byte with candidate files;
12. proves BOM/CR/resource/type invariants; and
13. tears down through candidate then caller cleanup after stream disposal.

No cell selects by name or auto-extracts.

### 4. Emit collision-free matrix attestations

Define exactly these static matrix job output keys:

```text
attestation_desktop_lf
attestation_desktop_crlf
attestation_core_lf
attestation_core_crlf
```

Each cell emits only its own canonical bounded record after all checks pass.
The record contains exact cell key/axes, artifact ID, bare digest, event SHA,
full ref, canonical `has_changes`, all four named path hashes, and completion
marker.

Use an exact `matrix.include` catalog containing edition, fixture EOL, stable
cell ID, and static emitter selector. Declare all four job outputs and use
exactly four mutually exclusive literal-guarded emitter steps; each canonical
cell can write only its corresponding static key. Do not construct an output
name dynamically or reuse one name. Matrix completion order is not
guaranteed.

The structural validator proves the exact four unique axis/cell rows,
`strategy.job-total == 4`, `fail-fast: false`, each guard/key mapping, and
approval receipt of exactly the four keys. Negative fixtures cover swapped
guard/key, empty key, duplicate embedded cell ID, extra matrix row, and every
completion-order permutation.

### 5. Gate promotion with one terminal approval

One read-only approval job:

- depends exactly on preparation, local `validate_markdown` call, and Windows
  matrix in the same workflow run;
- uses `if: always()`;
- requires the exact dependency result set and success for every member;
- requires exact four-key equality;
- parses each record fail-closed;
- rejects missing/extra/duplicate/empty/malformed/unexpected fields;
- rejects duplicate embedded cell IDs and key/axis disagreement;
- compares every record's artifact identity, event identity, `has_changes`,
  and all four path hashes to preparation;
- verifies canonical `has_changes`; and
- emits promotion authorization only for push-to-`main` plus
  `has_changes=true`.

Pull requests stop after read-only approval. No-change pushes succeed without a
writer. Failure/cancellation/unexpected skip never authorizes a write or
diagnostic artifact on cancellation.

### 6. Snapshot and validate writer identity once

The writer runs only for approved changed push-to-`main` and declares:

```yaml
permissions:
  contents: write
```

Pass purpose-specific `TARGET_REF`/`EXPECTED_SHA` and ambient
`GITHUB_REF`/`GITHUB_SHA`. The first executable statements:

```powershell
$strTargetRef = [string]$env:TARGET_REF
$strExpectedSha = [string]$env:EXPECTED_SHA
$strGitHubRef = [string]$env:GITHUB_REF
$strGitHubSha = [string]$env:GITHUB_SHA
```

Before credential expansion or mutation:

- reject empty, leading/trailing whitespace, CR/LF, and controls; do not trim;
- document that ordinary environment strings cannot contain NUL;
- require refs under `refs/heads/`, valid by `git check-ref-format`, and
  ordinal/case-sensitive equal;
- require complete IDs for active object format, resolve as commits, compare
  canonical IDs case-insensitively;
- capture native exits immediately; and
- never read those four environment variables again.

Use captured target/ref unchanged for checkout proof, remote preflight, parent,
lease, and refspec. Keep values as arguments; no GitHub expression inside
script source or constructed command string.

### 7. Revalidate and regenerate at use

Before token materialization or repository mutation, writer:

1. checks out exact expected commit without persisted credentials;
2. proves clean index/worktree and exact `HEAD`;
3. runs exact P1A harness with both paths;
4. creates a new production context;
5. downloads exact approval artifact ID without decompression;
6. validates/extracts through exact helper and digest;
7. proves four files equal preparation hashes;
8. independently runs expected-commit generator in a separate controlled
   location and proves byte equality with candidate; and
9. disposes streams then applies both cleanup lifecycles.

Trust no matrix filesystem, artifact name, or prior runner candidate.

### 8. Prove remote state and one exact commit

Before copying:

1. `git ls-remote --exit-code origin $strTargetRef`;
2. require one `<complete-id><TAB><exact-ref>` record;
3. require ID equals `$strExpectedSha`;
4. require local `HEAD` equals same commit; and
5. abort without mutation on mismatch.

Copy exact four candidates to exact destinations. Require full changed set
equals those paths; stage exact paths; require cached equality and staged
bytes/hashes equal candidate; reject BOM/CR.

Create one fixed-bot commit/message. Require one parent equal expected SHA,
committed blobs equal candidates, and no other tree path differs.

Candidate equal to `HEAD` is an inconsistency: no commit/push.

### 9. Materialize credentials only for the exact push

GitHub's ephemeral write token exists for the complete minimal writer job.
The pinned writer checkout may use it transiently for fetch. Every checkout
uses `persist-credentials: false`; after checkout cleanup and before repository
scripts, prove no credential helper, `http.*.extraheader`, token-bearing remote
URL, or ordinary token environment variable remains.

Keep xtrace disabled and prove it before expansion. Never place token in remote
URL, command string, ordinary file, artifact, output, or diagnostic.

Pass one process-scoped environment-backed Git HTTP authorization
configuration only to:

```text
git push --force-with-lease=<validated-ref>:<validated-sha> origin HEAD:<validated-ref>
```

Restore/remove all temporary environment values and credential state in
`finally` and repeat the credential-state inspection. No bare push, `--force`,
implicit destination, retry, or weaker lease. Capture exit immediately. On
success query exact remote ref and require new commit; on rejection fail
unchanged.

### 10. Add controlled negative drills

Before enabling `main`, use exactly
`.github/workflows/evidence-p1b-temporary-writer.yml` on one recorded unique
temporary branch. The structural validator requires its writer
steps/roles/scripts to equal the proposed production writer except for one
literal predicate authorizing only the exact evidence ref. Use unique
test-owned artifact fixtures:

- altered well-formed digest fails before ZIP/candidate;
- malformed/extra/duplicate/traversal transport fails through real helper;
- missing/extra/malformed/mismatched matrix attestations fail;
- failed/cancelled/unexpected-skipped dependency blocks approval;
- ref/SHA empty/whitespace/control/malformed/mismatch fails before credential;
- stale remote fails pre-mutation;
- post-preflight race loses exact lease;
- no-op creates no commit/push;
- unrelated PR/branch cannot write;
- token sentinel appears nowhere in logs/artifacts/process command records/
  files; and
- every negative leaves protected remote unchanged.

Mutate test-local identity copies, never production environment values.
Retain the evidence workflow/commit/run IDs, artifact identities, approvals,
and remote before/after IDs. Then delete the evidence workflow and branch.
Final policy and raw NUL-safe path checks prove the evidence path and every
alternate write predicate are absent from the production commit. Never
hand-edit the production predicate for validation.

### 11. Bound diagnostics and measure cost

Upload diagnostics only on ordinary failure, never success/cancellation.
Collision-free names, redaction, test-owned logs/fixtures only, seven-day
retention. Diagnostic failure cannot hide primary failure.

After ten qualifying PR and push runs record per-job/queue/total duration,
failure/rerun causes, and diagnostic bytes. Review quarterly. Open a real
follow-up if median exceeds 15 minutes, p95 exceeds 25, diagnostics exceed
250 MB/month, runner availability blocks contributors, or measured evidence
supports topology change. Cost never silently removes a security cell.

## Reciprocal P1B↔T1B comparison

Extend the exact P1A matrix for:

- artifact identity/digest;
- final action role table;
- triggers/permissions;
- matrix/unique attestations/approval;
- at-use harness/regeneration;
- identity/preflight/staging/commit/lease/refspec/no-op;
- credential existence versus process materialization;
- diagnostics/retention; and
- CI coverage/cost.

Record exact commits/evidence and `same`, `intentional difference`, or
`blocker`. Repository-local names may differ; unexplained security/failure
differences block merge.

## Validation

### Static/local

Prove:

- P1's raw NUL-safe verifier proves exactly the two workflow files and one
  workflow-policy validator changed/staged;
- final roles exactly equal sole role table;
- explicit YAML inputs and reviewed pinned-manifest defaults remain separate
  and exact;
- `build.yml` is sole event owner and the same-commit local Markdown call is in
  approval's exact dependency graph;
- only writer has `contents: write`;
- unfiltered required events;
- no automatic extraction, mutable action, credential persistence, cache,
  remote workflow, command-string Git, recursive cleanup, or skip commit;
- package/lock/parser/hook/lint config/generated artifacts unchanged;
- every inherited and final workflow-policy fixture passes;
- YAML parses; and
- exact prerequisite script versions/commits.

### Pull-request evidence

Require Node 24 lints, Ubuntu full harness, one immutable candidate ID/digest,
all four Windows cells/stable IDs/byte equality, exact four attestations,
read-only approval, and no writer.

### Push/writer evidence

On controlled temporary branch require preparation, four cells, exact
approval, writer only when changed, four-local identity, remote preflight,
candidate/destination/staged/committed equality, one expected-parent commit,
exact lease/refspec, new remote ref, and all negative drills.

Then enable exact `main` topology and retain run URLs/IDs.

## Acceptance criteria

- [ ] Unfiltered required PR/push validation runs.
- [ ] `build.yml` is the sole event owner; `markdownlint.yml` is an exact
      same-commit local callable job in approval's `needs`.
- [ ] Only writer has write permission; all checkouts disable persistence.
- [ ] Actions/conditions/explicit inputs equal one final exact role table and
      reviewed pinned-manifest defaults are separately exact.
- [ ] The permanent tracked workflow-policy validator/parser and all
      positive/negative fixtures pass offline.
- [ ] Preparation uploads one immutable four-file ID/digest candidate.
- [ ] Preparation exports four canonical path-bound hashes consumed by every
      attestation, approval, and writer check.
- [ ] Ubuntu and all four Windows cells use exact production scripts.
- [ ] Downloads use immutable ID, no extraction, digest mismatch error.
- [ ] Four stable unique attestations reach approval without overwrite.
- [ ] Approval detects all failed/cancelled/unexpected-skipped dependencies.
- [ ] PRs/no-change pushes cannot write.
- [ ] Writer snapshots/validates four identity values once.
- [ ] Writer independently regenerates and revalidates at use.
- [ ] Remote preflight, parent, lease, refspec use one validated pair.
- [ ] Candidate/destination/staged/committed/remote bytes and IDs match.
- [ ] Token existence, checkout's transient use/cleanup, absence from
      repository scripts, and push-only explicit header materialization match
      the exact credential contract.
- [ ] Negative identity/digest/manifest/attestation/race/no-op/event/token
      drills pass.
- [ ] Diagnostics are bounded/redacted/failure-only/seven-day.
- [ ] Cost review is assigned without removing required cells.
- [ ] The exact evidence workflow/ref is removed and no alternate production
      write predicate remains.
- [ ] P1's raw NUL-safe verifier proves only `build.yml`, `markdownlint.yml`,
      and `Validate-WorkflowPolicy.mjs` changed/staged.
- [ ] P1B↔T1B has no unexplained blocker.

## Handoff

Provide P2 with P1B's actual issue URL, final merge commit, workflow-policy
validator/parser identity, action provenance/default records, retained
positive/negative run IDs, preparation artifact ID/digest/four hashes, four
attestations/approval, writer preflight/commit/lease/post-push identities,
credential/diagnostic evidence, evidence-workflow removal proof, final
path-set proof, and the P1B↔T1B matrix. P2 records receipt in its own
prerequisite gate.

## Non-goals

- Changing generator/helper/context/harness implementation.
- Changing packages, lockfile, hook, lint, contributor Node policy, or
  Dependabot.
- Changing source/generated content.
- Supporting arbitrary producers/external workflows.
- Retrying/rebasing a stale writer.
- Using concurrency cancellation for correctness.
- Adding a PAT/GitHub App/shared runtime solely for publication.

## References

- [GitHub reusable workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows)
- [GitHub matrix job outputs](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#using-job-outputs-in-a-matrix-job)
- [GitHub strategy context](https://docs.github.com/en/actions/reference/workflows-and-actions/contexts#strategy-context)
- [Use `GITHUB_TOKEN`](https://docs.github.com/en/actions/tutorials/authenticate-with-github_token)
- [GitHub workflow permissions](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#permissions)
- [Pinned checkout action metadata](https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml)
- [upload-artifact](https://github.com/actions/upload-artifact)
- [download-artifact](https://github.com/actions/download-artifact)
- [Git check-ref-format](https://git-scm.com/docs/git-check-ref-format)
- [Git push and leases](https://git-scm.com/docs/git-push)
- [GitHub Actions billing](https://docs.github.com/en/actions/concepts/billing-and-usage)
