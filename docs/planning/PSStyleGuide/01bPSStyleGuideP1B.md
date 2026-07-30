# Promote generated style-guide artifacts through a least-privileged verified writer

## Summary

Introduce the slate's only publication boundary. One read-only job prepares an
immutable four-file candidate. Ubuntu and the complete Windows PowerShell
edition × fixture-EOL matrix validate that exact artifact through P1A's landed
production interfaces. One terminal read-only approval compares direct
same-run results and path-bound hashes. Only an approved changed push to
`main` can start the sole write-enabled job, which revalidates and regenerates
at use, creates one exact-parent commit, and performs one exact-lease push.

P1 was deliberately read-only; there is no temporary writer to replace.

## Consumed landed contracts

P1 and P1A must be merged and both real GitHub dependency edges verified.
Before coding, record:

| Contract | Required permanent/landed identity |
| --- | --- |
| P1/P1A issue and PR | Canonical URLs |
| Review/merge | Reviewed heads/bases, merge methods, landed commits/trees |
| Generator | Exact version/hash and fixed four-output transaction |
| Candidate API | Helper/context/harness versions/hashes and public schemas |
| Candidate catalog | Schema/version/hash and complete runtime results |
| Workflow policy | Validator/parser/contract/case versions and hashes |
| Scope verifier | P1 script version/hash and fixtures |
| Risk/action supply | Current advisory decision and pinned manifest/default evidence |
| Main governance | Approved settings-task URL, current/desired/rollback digests, exact application identity |
| Reciprocal | P1↔T1 and P1A↔T1A matrices |

Rerun P1's baseline and every applicable P1A catalog case. Compare landed
interfaces with this issue; a missing dependency, stale risk decision,
identity/schema drift, or reciprocal blocker stops for issue review. A
reviewed PR head is not a substitute for landed state.

P2 consumes this issue's landed publication contract.

## Affected files

Exactly these five paths may change:

- `.github/workflows/build.yml`;
- `.github/workflows/markdownlint.yml`;
- `.github/workflows/Validate-WorkflowPolicy.mjs`;
- `.github/workflows/workflow-policy-contract.json`; and
- `.github/workflows/workflow-policy-cases.json`.

Update P1's single validator and policy/case manifests; do not create a second
policy engine or duplicate P1's parser/path rules. Do not change generator,
candidate scripts/catalog, path verifier, package/lock, hook/lint, guides,
artifacts, `.gitattributes`, or Dependabot. A required parser/package change
stops for explicit scope and supply/audit re-review.

## Closed workflow graph

`build.yml` is the sole external event owner. It runs for every pull request
targeting `main` and every push to `main`, with no path filter, skip-commit
convention, or correctness dependency on concurrency cancellation.
`markdownlint.yml` exposes only an exact inputless/secretless local
`workflow_call`.

Both workflows use top-level `permissions: {}`. The exact job graph is:

| Workflow/job | Direct `needs` | Job permission | Condition | Outputs/side effects |
| --- | --- | --- | --- | --- |
| `build.yml/validate_markdown` | none | `contents: read` | ordinary | same-commit local reusable call; read-only |
| `build.yml/prepare_candidate` | none | `contents: read` | ordinary | immutable candidate ID/digest/hashes and bundle |
| `build.yml/verify_candidate_windows` | `prepare_candidate` | `contents: read` | ordinary | four static attestations |
| `build.yml/approve_candidate` | exactly `prepare_candidate`, `validate_markdown`, `verify_candidate_windows` | `{}` | `${{ always() }}` | canonical approval bundle only |
| `build.yml/synchronize_generated_artifacts` | exactly `approve_candidate` | `contents: write` | exact approved changed push-to-main predicate | sole commit/push |
| `markdownlint.yml/markdownlint` | none | `contents: read` | ordinary | lint and Ubuntu candidate harness; read-only |

No job consumes a transitive output. `approve_candidate` receives every
preparation identity and all four attestations through its direct `needs`;
its bundle includes all data the writer needs. The writer reads only the
approval bundle plus immutable event context. No other job has write
permission, repository mutation, candidate publication, or credential-derived
push state.

Add `merge_group` only if the repository merge queue actually requires it and
then update this contract/cases atomically. Use standard hosted runners only;
no cache, service container, remote reusable workflow, automatic artifact
extraction, or unreviewed action.

## Exact external-action contract

At implementation and pre-merge freeze gates, re-resolve release tag,
repository provenance, full SHA, release metadata, exact `action.yml` digest,
input schema/defaults, runtime, and security posture:

| Action | Full SHA | Reviewed release |
| --- | --- | --- |
| `actions/checkout` | `3d3c42e5aac5ba805825da76410c181273ba90b1` | `v7.0.1` |
| `actions/setup-node` | `820762786026740c76f36085b0efc47a31fe5020` | `v7.0.0` |
| `actions/upload-artifact` | `043fb46d1a93c77aae656e7c1c64a875d1fc6a0a` | `v7.0.1` |
| `actions/download-artifact` | `3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c` | `v8.0.1` |

A changed target, manifest/default, provenance, or security-relevant runtime
requires renewed review. YAML uses full SHA plus matching adjacent release
comment.

Every checkout authors this full input set:

`repository: ${{ github.repository }}`, `ref: ${{ github.sha }}`,
`token: ${{ github.token }}`, `persist-credentials: false`, `clean: true`,
`fetch-depth: 1`, `fetch-tags: false`, `show-progress: true`, `lfs: false`,
`submodules: false`, `set-safe-directory: true`, and
`allow-unsafe-pr-checkout: false`.

The exact roles and remaining authored inputs are:

| Job/step | Role | Condition | Authored role-specific inputs |
| --- | --- | --- | --- |
| `prepare_candidate/checkout_repository` | checkout | ordinary | closed checkout set |
| `prepare_candidate/upload_candidate` | upload | ordinary | unique run/attempt name; four exact paths; `if-no-files-found: error`; `retention-days: 1`; `compression-level: 0`; `overwrite: false`; `include-hidden-files: false`; `archive: true` |
| `verify_candidate_windows/checkout_repository` | checkout | ordinary | closed checkout set |
| `verify_candidate_windows/download_candidate` | download | ordinary | preparation `artifact-ids`; exact context path; `skip-decompress: true`; `digest-mismatch: error` |
| `verify_candidate_windows/upload_failure_diagnostics` | upload | `${{ failure() && !cancelled() }}` | exact collision-free name/path; `if-no-files-found: error`; `retention-days: 7`; `compression-level: 0`; `overwrite: false`; `include-hidden-files: false`; `archive: true` |
| `synchronize_generated_artifacts/checkout_repository` | checkout | ordinary | closed checkout set |
| `synchronize_generated_artifacts/download_candidate` | download | ordinary | approval `artifact-ids`; exact context path; `skip-decompress: true`; `digest-mismatch: error` |
| `synchronize_generated_artifacts/upload_failure_diagnostics` | upload | `${{ failure() && !cancelled() }}` | exact collision-free name/path and same seven-day diagnostic inputs |
| `markdownlint/checkout_repository` | checkout | ordinary | closed checkout set |
| `markdownlint/setup_node` | setup-node | ordinary | `node-version: '24.18.1'`; `check-latest: false`; `token: ${{ github.token }}`; `package-manager-cache: false` |

Candidate name is
`style-guide-candidate-${{ github.run_id }}-${{ github.run_attempt }}`.
Candidate paths are exactly the four generated files in P1 order. Matrix
diagnostic names include job, edition, fixture EOL, run, and attempt; writer
diagnostics include job, run, and attempt. Exact paths come only from the
bounded diagnostic producer.

For download roles, `artifact-ids`, exact `path`, `skip-decompress`, and
`digest-mismatch` are the complete authored input set. `name`, `pattern`,
`merge-multiple`, cross-run token/repository/run identifiers, and every other
selector are absent and explicitly classified. For every action manifest
input, `workflow-policy-contract.json` records exactly `Authored`,
`ReviewedDefault`, or `NotApplicable`. An extra, missing, duplicate, dynamic,
unknown, or ignored input fails structural validation.

Candidate retention is one day because all consumers are same-run; diagnostics
retain seven days. Both use compression level zero and `archive: true`.
Diagnostic production/upload may be `continue-on-error: true` but cannot hide
the primary failure. Diagnostics contain one bounded redacted LF/BOM-less
summary and allowlisted test-owned files only—never source, arbitrary logs,
environment, token, Git config, or remote URL.

## Candidate preparation

`prepare_candidate`:

1. checks out and proves the exact event commit without retained credentials;
2. verifies landed generator/helper/context/harness/catalog identities;
3. runs every applicable P1A case and starts from a clean tree;
4. runs the exact generator;
5. requires changes to be a subset of the four generated paths;
6. verifies all four as bounded ordinary non-link BOM-less/LF files;
7. computes canonical `has_changes` against `HEAD`;
8. computes path-bound lowercase SHA-256 values;
9. uploads the exact four paths once, even for PR/no-change validation; and
10. emits only immutable artifact ID, bare upload digest, unique name,
    canonical change bit, event SHA/full ref, and the four named path hashes.

Hash after every byte/type/limit check and before upload. Artifact ID plus
digest—not name—is authority.

## Candidate verification

`markdownlint.yml` keeps P1's exact Node tuple, clean install, outer/nested
lint, and runs P1A's full harness under PowerShell 7/Ubuntu regardless of
whether generated content changed.

The Windows job uses `fail-fast: false` and this exact matrix:

| Edition | Fixture EOL | Cell key | Static output |
| --- | --- | --- | --- |
| Windows PowerShell 5.1 | LF | `desktop/lf` | `attestation_desktop_lf` |
| Windows PowerShell 5.1 | CRLF | `desktop/crlf` | `attestation_desktop_crlf` |
| PowerShell 7 | LF | `core/lf` | `attestation_core_lf` |
| PowerShell 7 | CRLF | `core/crlf` | `attestation_core_crlf` |

Each cell proves `strategy.job-total == 4`, checkout/event identity, exact
production script/catalog identities, every applicable P1A case, one
caller-owned context, immutable-ID no-extract/digest-bound download, one
ordinary retained archive, production helper extraction, LF/CRLF source
generation under the selected edition, byte equality for all four files, and
type/BOM/CR/resource invariants. It disposes streams and invokes candidate then
caller cleanup.

Exactly four literal-guarded emitter steps write the four static outputs.
Each canonical record contains cell key/axes, artifact ID/digest, event
SHA/ref, `has_changes`, four named path hashes, and completion marker. No
dynamic output name or shared key is allowed. Policy cases cover swapped
guard/key, duplicate/extra row, empty key, embedded identity mismatch, and
completion-order permutations.

## Terminal approval

`approve_candidate` uses literal `${{ always() }}`, has no token permission,
and checks the exact direct dependency result set. Every dependency must be
`success`; failure, cancellation, or unexpected skip is terminal.

Parse all four records fail-closed. Require exact key set, field set, embedded
cell identities/axes, unique cells, artifact/event/change identities, and all
four path hashes to match preparation. Emit one canonical approval bundle only
when every comparison succeeds. Set `AuthorizeWrite=true` only for exact
push-to-`refs/heads/main` with `has_changes=true`. Pull requests and no-change
pushes end successfully without starting the writer.

## Sole writer

The writer condition is a single literal expression requiring
`approve_candidate.result == 'success'`, exact authorization, push event,
`refs/heads/main`, and changed candidate. `Validate-WorkflowPolicy.mjs`
structurally rejects any second write grant/job/predicate.

Use exactly:

```yaml
if: >-
  ${{
    needs.approve_candidate.result == 'success' &&
    needs.approve_candidate.outputs.authorize_write == 'true' &&
    needs.approve_candidate.outputs.has_changes == 'true' &&
    github.event_name == 'push' &&
    github.ref == 'refs/heads/main'
  }}
```

### Identity and revalidation

Snapshot exactly once, before credential projection or repository mutation:

- approval target ref and expected event commit;
- ambient `GITHUB_REF` and `GITHUB_SHA`.

Reject null/empty, whitespace, controls, CR/LF, malformed/non-head refs, or
identity mismatch without trimming. Validate ref with `git check-ref-format`;
require complete active-object-format commit IDs; compare refs ordinally and
canonical IDs case-insensitively. Never reread the four environment values.
Use captured values unchanged for checkout proof, remote preflight, parent,
lease, and refspec.

Checkout exact expected commit, prove clean tree/index/HEAD and no retained
checkout credential, run the landed P1A harness, create a fresh context,
download exact approved artifact ID without extraction, validate through the
production helper/digest, and compare all path-bound hashes. Independently run
the expected-commit generator in a separate controlled location and require
byte equality. Dispose streams and apply both cleanup lifecycles.

Before copying, `git ls-remote --exit-code origin <target-ref>` must return
exactly one complete-ID/TAB/exact-ref row equal to expected commit and local
HEAD. Any mismatch fails before mutation. Copy exactly four candidates, prove
the complete changed set, stage exact paths, and verify candidate/destination/
index hashes plus BOM/CR. Create one fixed-bot commit with one parent equal to
expected SHA and no other tree change. Candidate equal to `HEAD` is an
inconsistency, not a no-op writer success.

### Honest credential model

The job's write-capable `GITHUB_TOKEN` exists from job start. The explicit
checkout token input projects it to the action; `persist-credentials: false`
prevents retained repository credentials after action cleanup. Do not claim
the token is absent or destroyed.

Before repository scripts, prove no credential helper, `http.*.extraheader`,
token-bearing remote URL, or derived ordinary token/header variable/file.
Keep xtrace disabled. Only immediately before the exact push, mask the derived
authorization value and provide one child-process-scoped environment-backed
HTTP header to:

```text
git push --force-with-lease=<validated-ref>:<validated-sha> origin HEAD:<validated-ref>
```

Never put token/header in URL, command string, Git config, file, output,
artifact, or diagnostic. Remove all derived state in `finally` and re-prove
its absence. No bare push, implicit destination, retry/rebase, `--force`, or
weaker lease. Capture native status immediately. On success, query the exact
remote ref and require the new commit; on rejection, fail without retry.

## Real-writer evidence without a copied workflow

Before enabling the `main` predicate, create one unique, isolated,
never-merged evidence ref. Before creating its commit, produce a versioned
allowed-delta manifest containing every exact evidence-only hunk:

- `on.push.branches` changes the short branch filter `main` to the exact short
  evidence branch name;
- approval/ref predicates and the writer condition change the full
  `refs/heads/main` literal to the exact full evidence ref;
- `TARGET_REF` and workflow-policy constants change to that same full ref;
- a bounded scenario selector/test adapter is added only where required by the
  named negative drill; and
- one safe test-owned source fixture deterministically changes generated bytes.

The manifest binds production/evidence commit and workflow blob identities,
ordered hunk locations, old/new byte hashes, scenario, and overall digest.
There is no generic repeated replacement: the short trigger branch and full
context refs are distinct values.

A structural semantic comparator must prove production and evidence workflow
trees are identical except those enumerated hunks. It rejects every other
event, permission, job/needs edge, action/input/default, artifact/candidate,
credential, path, commit, lease, refspec, or diagnostic change. Continue to
prohibit `workflow_dispatch`, `repository_dispatch`, copied writers,
caller-selected refs, wildcard filters, and secret inheritance.

Run changed and no-change success plus altered digest, malformed/extra/
duplicate/traversal archive, missing/extra/malformed/mismatched attestations,
failed/cancelled/skipped dependency, malformed/mismatched ref/SHA, stale
preflight, lost lease, unrelated event/ref, unexpected path, and token-sentinel
drills. Test-local adapters mutate fixtures, never production environment
identity. Every negative leaves the target unchanged. Verify success creates
exactly one writer commit with the expected parent/tree and no other writer.

Before the positive writer and governance-negative drills, the separately
authorized administrator task installs a temporary field-equivalent branch
rule targeting only the full evidence ref. It has the desired persistent
deletion/non-fast-forward/pull-request/conversation/current-check policy and
exactly the re-resolved official GitHub Actions integration in `always` mode,
subject only to evidence-ref and preexisting-check-context differences
explicitly approved in the settings task. Under that rule prove:

- the real `GITHUB_TOKEN` writer's exact-parent/exact-lease update succeeds;
- stale/lost lease and non-fast-forward updates fail without moving the ref;
- deletion fails without moving the ref; and
- an ordinary maintainer's direct update fails without moving the ref.

Retain temporary rule ID/normalized JSON digest, effective-rule query,
application/run/commit/ref identities, before/after refs, and audit evidence.

Retain issue/commit/workflow/run/artifact/remote-before/remote-after evidence,
then wait for or cancel every evidence run; delete the remote evidence ref with
an expected-old guard; prove no active workflow, policy, or retained reference
names it; remove the temporary rule; and re-query exact settings restoration.
Cleanup uncertainty blocks production activation and never authorizes an
unprotected fallback.

After this pull request has produced the stable
`Build Style Guide Artifacts / approve_candidate` check, the administrator
task activates `ps-style-guide-main-protection` before merge. Query normalized
rule JSON and all active rules applying to `main`; require exact targeting,
pull-request/resolved/current/check/deletion/non-fast-forward behavior, the
GitHub Actions expected check source, and exactly one official-Actions
`always` bypass. Retain rule ID/digest/effective result and rollback proof.

The evidence commit is never merged and no evidence workflow file remains.
Final validation proves production `build.yml` has the exact `main` trigger
and full-ref literals, the evidence ref/rule are absent, persistent `main`
governance is active/effective, and the comparator/evidence bundle identifies
the reviewed production commit. If landed production differs, rerun evidence
on a new isolated ref.

## Permanent workflow-policy delta

Extend P1's existing contract/cases; do not restate its parser internals.
Machine policy now proves the exact job/direct-needs/permission/condition/
output/side-effect table, all action roles/input dispositions, preparation
bundle flow, matrix rows/static emitters, terminal approval, sole writer
predicate, candidate/diagnostic artifact contracts, credential invariants,
short trigger versus full-ref constants, the evidence allowed-delta manifest,
and absence of remote/dynamic workflows, dispatch evidence triggers, wildcard
refs, cache, auto-extraction, persisted credentials, transitive output use, or
unknown roles.

Every P1 case remains passing. Add one independent negative case per graph,
role, bundle, matrix, approval, permission, predicate, credential, and evidence
mutation. Fixture data remains offline and disposable.

Use P1's landed `Test-ExactGitPathSet.ps1` before staging, after staging, and
after final validation to prove exactly the five affected paths.

## Reciprocal P1B↔T1B comparison

Compare exact landed PS/T contracts across artifact identity/digest, final
action roles/inputs/defaults, job graph/direct needs/permissions, matrix/static
attestations, approval bundle, at-use harness/regeneration, identity/preflight/
staging/commit/lease/refspec/no-op, honest token/projection/derived-state model,
real-writer allowed deltas/triggers, equivalent-ruleset evidence, persistent
ruleset/effective-rule state, diagnostics, and coverage/cost.

Record exact commits/evidence and `same`, `intentional difference`, or
`blocker`. Repository-local names may differ; unexplained security/failure
differences block merge.

## Validation

Static/offline validation proves:

- the exact five-path scope and unchanged P1/P1A/package/guide/artifact bytes;
- top-level `{}`, exact direct job graph, and only writer `contents: write`;
- every action role, literal condition, authored input, and reviewed default;
- exact candidate/diagnostic retention, compression, archive, selection, and
  `${{ failure() && !cancelled() }}` predicates;
- all inherited and new policy cases;
- no mutable action, cache, remote workflow, auto-extraction, persisted
  credential, recursive cleanup, skip commit, transitive output, or second
  writer; and
- exact prerequisite versions/commits/schemas.

Pull-request evidence requires Node lints, Ubuntu harness, immutable candidate
ID/digest/four hashes, all four Windows cells and byte equality, exact four
attestations, read-only approval, and no writer.

Isolated-ref evidence requires the real workflow equivalence proof, one writer
commit only on authorized changed success, all negative drills, exact
credential cleanup, temporary-rule enforcement, guarded remote deletion,
run/ref/rule cleanup, and absence of evidence state. Final production
validation uses the exact `main` topology, proves the persistent rule/effective
state and sole bypass, and retains run/rule/audit URLs/IDs.

Measure ten qualifying runs and review quarterly: job/queue/total duration,
rerun/failure causes, and diagnostic bytes. Open a follow-up if median exceeds
15 minutes, p95 exceeds 25, diagnostics exceed 250 MB/month, or runner
availability blocks contributors. Never silently remove a security cell.

## Acceptance criteria

- [ ] The exact direct job graph and permissions match the closed table.
- [ ] `build.yml` is sole event owner; `markdownlint.yml` is same-commit,
      call-only, inputless, secretless, and read-only.
- [ ] Every action role/input/default equals one final contract.
- [ ] Candidate and diagnostic artifact inputs/retention/compression/archive/
      predicates are exact.
- [ ] Preparation emits one immutable ID/digest/change/ref/four-hash bundle.
- [ ] Ubuntu and all four Windows cells use landed production contracts and
      emit four unique static attestations.
- [ ] Approval directly consumes all required jobs/data and fails every
      failure/cancel/skip/mismatch.
- [ ] PRs/no-change pushes cannot write; exactly one job/predicate can.
- [ ] Writer revalidates/regenerates at use and proves remote, parent, staged,
      commit, lease, refspec, and post-push identities.
- [ ] Credential evidence truthfully distinguishes job token, action
      projection, retained state, and push-only derived state.
- [ ] Real `build.yml` isolated-ref evidence proves success/negative cases,
      exact short-trigger/full-ref allowed deltas, one commit, equivalent
      temporary-rule enforcement, ref/rule cleanup, and no copied workflow.
- [ ] `ps-style-guide-main-protection` is active/effective before merge, with
      exact required check/source and the sole official-Actions `always`
      bypass.
- [ ] Diagnostics are bounded/redacted/failure-and-not-cancelled/seven-day.
- [ ] Existing and new workflow-policy cases pass offline.
- [ ] P1's landed verifier proves only the five affected paths.
- [ ] P1B↔T1B has no unexplained blocker.

## Handoff

Give P2 permanent P1B issue/PR URLs, reviewed head/base, merge method, landed
commit/tree, policy schema/version/hashes, exact job/action/default contract,
candidate and four-attestation/approval bundles, writer preflight/commit/lease/
post-push evidence, credential and diagnostic proof, isolated-ref equivalence/
allowed-delta/ruleset/deletion proof, persistent rule ID/normalized digest/
effective-rule result/required check/source/sole bypass, final scope proof, and
P1B↔T1B matrix. P2 compares these landed interfaces with its assumptions
before changing content.

## Non-goals

- Generator/candidate/path-verifier/package/hook/lint implementation changes.
- Source or generated content changes.
- Arbitrary producers, external workflows, stale-writer retry/rebase, or
  concurrency cancellation as correctness.
- PAT/GitHub App/shared runtime solely for publication.

## References

- [GitHub reusable workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows)
- [GitHub matrix job outputs](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#using-job-outputs-in-a-matrix-job)
- [GitHub workflow permissions](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#permissions)
- [GitHub `GITHUB_TOKEN`](https://docs.github.com/en/actions/concepts/security/github_token)
- [Pinned checkout manifest](https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml)
- [Pinned setup-node manifest](https://raw.githubusercontent.com/actions/setup-node/820762786026740c76f36085b0efc47a31fe5020/action.yml)
- [Pinned upload-artifact manifest](https://raw.githubusercontent.com/actions/upload-artifact/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a/action.yml)
- [Pinned download-artifact manifest](https://raw.githubusercontent.com/actions/download-artifact/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/action.yml)
- [Git check-ref-format](https://git-scm.com/docs/git-check-ref-format)
- [Git push and leases](https://git-scm.com/docs/git-push)
