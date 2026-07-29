# Evaluation of open PSStyleGuide issue-slate findings

## Scope and method

This working evaluation covers every PSStyleGuide finding in
`docs/planning/artifacts/current-findings.md`, in source order. Each finding
will receive its own options, finding-specific weighted rubric, scoring table,
and implementation-ready selection before evaluation proceeds to the next
finding.

Primary-source facts used by the evaluations are retained in
[research-2026-07-29-psstyleguide-slate.md](research-2026-07-29-psstyleguide-slate.md).

The prompt names `02PSStyleGuideP3.md`; the repository's authoritative P3
draft is `docs/planning/PSStyleGuide/03PSStyleGuideP3.md`. This evaluation and
the resulting slate use that existing P3 path rather than creating a
conflicting duplicate.

Evaluation order:

1. C-01 — split P1 along T1/T1A/T1B trust boundaries;
2. C-02 — replace stale “parallel T1” comparisons;
3. C-03 — converge the generator destination-path contract;
4. C-04 — add resource limits and a reusable caller-context lifecycle;
5. C-05 — strengthen the writer credential and identity boundary;
6. C-06 — bound P3's Node support set;
7. C-07 — persist and continuously validate residual audit approvals;
8. I-P1-01 — add explicit-null diagnostic-label cases;
9. I-P1B-01 — define terminal receipt of four matrix attestations;
10. I-P3-01 — make the npm CLI policy explicit across runtime cells; and
11. I-P2-01 — rebase P2's otherwise-ready prerequisite.

This file is intentionally written as work progresses so that each completed
finding remains durable before the next finding begins.

## C-01 — Split P1 along T1/T1A/T1B trust boundaries

### Options

**Option A — Retain one monolithic P1.** Keep generator serialization,
validator/context/harness, production transport, approval, credentials, commit,
and push in one issue. Add internal headings and require one atomic merge. This
minimizes issue mechanics and avoids an intermediate production topology, but
one reviewer must reason about three trust layers and roughly 2,900 lines at
once.

**Option B — Split into P1, P1A, and P1B.** Preserve P1's existing H1 for the
deterministic generator/runtime/action foundation. Create workflow-inert P1A
for the archive validator, caller-context lifecycle, resource limits, and
adversarial harness. Create P1B for immutable transport, the complete matrix,
terminal approval, credential policy, at-use regeneration, commit, lease, and
push. Record exact merge commits and real blocked-by relationships. P2 depends
on P1B; P3 follows P2 under the stipulated linear sequence.

**Option C — Use a two-issue split.** Put generator foundations in P1 and
combine validator plus production activation in P1B. This reduces the original
issue size, but the helper's security proof cannot merge independently of the
write-enabled workflow and the review boundary still combines untrusted ZIP
processing with credentials.

**Option D — Split more finely than TerraformStyleGuide.** Create separate
issues for generator bytes, action/runtime policy, validator, harness,
read-only transport, and writer activation. This gives small review units but
creates many intermediate contracts, more dependency edges, more temporary
workflow states, and a higher risk that a partial sequence becomes the
de-facto final design.

**Option E — Use one umbrella P1 plus P1/P1A/P1B implementation children.**
Keep a non-implementing tracking issue containing the whole outcome and file
three implementation issues beneath it. This preserves a single management
view while retaining trust boundaries, at the cost of a fourth issue whose
requirements can drift or duplicate the children.

Permutations considered:

- P1A may merge before or after a temporary read-only transport, but it must
  remain production-inert until P1B.
- P3 could technically run independently, but the user stipulated one linear
  slate; retaining P3 after P2 avoids a second dependency graph.
- If an umbrella is used, it must not be a second normative specification.

### Evaluation rubric

Score each option from 1 (poor) to 5 (excellent). Weighted total is the sum of
`weight × score ÷ 5`.

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Security review isolation | 25 | ZIP parsing, filesystem ownership, and write credentials need independently auditable boundaries |
| Dependency determinism | 18 | Downstream issues need exact merged contracts, not moving or partially implemented prerequisites |
| Migration/activation safety | 15 | Intermediate merges must not accidentally activate an unproven publisher |
| Cross-repository convergence | 15 | Matching T1/T1A/T1B layers makes behavioral comparison precise without a shared runtime |
| Cold-reader handoff clarity | 12 | A new implementer must understand ownership and execution order without reconstructing a giant issue |
| Evidence traceability | 10 | Acceptance evidence should map to one trust layer and exact commit |
| Churn and issue overhead | 5 | Additional files and dependency administration matter, but less than correctness and usability |

### Scoring

| Option | Isolation | Dependencies | Activation | Convergence | Handoff | Evidence | Churn | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — one P1 | 2 | 4 | 5 | 2 | 2 | 3 | 5 | 61.2 |
| B — P1/P1A/P1B | 5 | 5 | 4 | 5 | 5 | 5 | 3 | **95.0** |
| C — two issues | 3 | 4 | 4 | 3 | 3 | 3 | 4 | 67.6 |
| D — six granular issues | 5 | 4 | 2 | 4 | 3 | 5 | 1 | 75.6 |
| E — umbrella plus three | 5 | 5 | 4 | 5 | 5 | 5 | 2 | 94.0 |

### Selected option

Select **Option B: P1/P1A/P1B without a duplicate umbrella specification**.

Implementation-ready disposition:

1. Keep `01PSStyleGuideP1.md` and its H1, but narrow it to deterministic
   generator output, destination serialization, script metadata, LF checkout,
   hosted Node/action foundations, review-only action updates, and a temporary
   read-only verification boundary.
2. Add `01aPSStyleGuideP1A.md` for the production archive helper, production
   caller-context manager, resource ceilings, separate cleanup owners, and
   permanent cross-platform adversarial harness. It must change no production
   workflow.
3. Add `01bPSStyleGuideP1B.md` for production workflow activation, immutable
   artifact ID/digest transport, Ubuntu plus four Windows cells, exact
   attestation aggregation, terminal approval, final writer, and diagnostics.
4. P1A records P1's exact merge commit. P1B records exact P1 and P1A commits.
   P2 records P1B's exact merge commit and actual blocked-by relationship.
5. No helper or writer behavior is duplicated between issues. Every enduring
   rule has one final owner; later issues consume rather than restate it.

This selection gives security reviewers, implementers, project managers, and
business stakeholders clear stop/go boundaries while keeping the number of
issues proportionate.

## C-02 — Replace stale “parallel T1” comparisons

### Options

**Option A — Keep generic “parallel T1” prose.** Let implementers infer which
Terraform issue owns the comparable behavior. This is short but already points
validator behavior at T1 instead of T1A and omits the T1B writer boundary.

**Option B — Add one reciprocal, commit-specific matrix per trust layer.**
P1 compares with T1, P1A with T1A, and P1B with T1B. The implementation that
starts second records both exact commits and classifies every row as `same`,
`intentional difference`, or `blocker`, with evidence and rationale.

**Option C — Remove cross-repository comparisons.** Keep each repository
self-contained and rely on reviewers to notice drift. This avoids stale prose
but abandons the user's explicit generator-unification goal.

**Option D — Introduce a shared cross-repository module/package.** Make both
repositories import one generator/validator implementation. This can eliminate
some algorithm drift, but couples release timing, manifests, workflow trust,
and repository availability; it also cannot erase legitimate artifact and
topology differences.

**Option E — Perform one final cross-repository audit after P1B.** Keep issue
text local and compare all layers only after implementation. This detects drift
late, after earlier design choices and merge commits are expensive to change.

Combinations considered:

- Option B may use pull-request evidence or a tracked planning artifact; either
  is acceptable if the exact commits and complete row set are durable.
- Option B can coexist with small copy/paste reuse during implementation, but
  no runtime dependency is introduced.
- Option E can supplement B as a final regression review, not replace it.

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Observable behavioral convergence | 28 | The stated goal is thoughtful unification, including equivalent failure behavior |
| Resistance to stale evidence | 20 | Moving branches and generic issue names quickly invalidate comparisons |
| Repository independence | 15 | Either repository must build and validate without the other at runtime |
| Auditability and blocker visibility | 15 | Reviewers need exact rows and an explicit disposition for differences |
| Implementer clarity | 12 | A cold reader must know which Terraform layer to inspect |
| Implementation difficulty | 5 | Comparison work has cost, but it is secondary to correct contracts |
| Documentation churn | 5 | Matrix maintenance matters less than preventing unexplained security drift |

Scores use 1–5 and the same weighted-total calculation described for this
section only.

### Scoring

| Option | Convergence | Freshness | Independence | Auditability | Clarity | Difficulty | Churn | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — generic T1 | 1 | 1 | 5 | 2 | 2 | 5 | 5 | 45.4 |
| B — layer matrices | 5 | 5 | 5 | 5 | 5 | 3 | 3 | **96.0** |
| C — remove comparison | 1 | 5 | 5 | 2 | 3 | 5 | 5 | 63.8 |
| D — shared runtime | 5 | 5 | 1 | 5 | 4 | 1 | 1 | 77.6 |
| E — final-only audit | 3 | 3 | 5 | 3 | 3 | 4 | 4 | 68.0 |

### Selected option

Select **Option B**, with a final regression audit from Option E.

Each issue must define its exact comparison rows:

- P1↔T1: complete-payload normalization, destination/provider handling,
  encoding, newline/final-newline behavior, script metadata, Node/action
  foundations, and generated-byte evidence.
- P1A↔T1A: public parameters, omitted/empty/null labels, path/component
  security, same-stream digest/ZIP handling, manifest/resource limits,
  extraction, caller/candidate cleanup, diagnostics, stable cases, and
  platform/edition coverage.
- P1B↔T1B: artifact identity/digest transport, action roles, triggers,
  permissions, matrix/approval topology, at-use validation, identity/ref/SHA
  grammar, remote preflight, staging/commit/lease, credential exposure,
  diagnostics, and cost governance.

Repository-specific filenames, frontmatter, job IDs, and source topology may
be intentional differences. Any unexplained observable security or failure
difference is a blocker. Store exact permanent commit links and keep both
repositories runtime-independent.

## C-03 — Make the generator destination-path contract converge

### Options

**Option A — Keep the current one-line unresolved-path pattern.** Call the
single-result `GetUnresolvedProviderPathFromPSPath` overload and immediately
pass its result to `WriteAllText`. This is compact but does not prove the
provider and can pass unresolved wildcard characters into .NET.

**Option B — Repeat complete fail-closed validation at each write site.** Each
of the four functions independently rejects invalid input, resolves provider
metadata, normalizes, encodes, and writes. This can be correct but duplicates a
security-sensitive algorithm four times.

**Option C — Add one private generator destination/serialization helper.**
Centralize the exact input/provider/absolute-path contract and explicit
BOM-less UTF-8 write, while each generator function supplies only its captured
destination and complete final payload.

**Option D — Accept native absolute filesystem paths only.** Reject every
PowerShell provider-qualified form, even `FileSystem::...`. This simplifies
classification but needlessly narrows supported PowerShell usage and diverges
from the validator contract.

**Option E — Use `Resolve-Path` and require the destination already exists.**
This gains provider metadata easily but prevents creation of a new destination
and conflates a missing leaf with an invalid parent/provider.

**Option F — Add temporary-file plus atomic-replace publication.** Combine
Option C with a same-directory temporary file and atomic replacement. This can
improve crash consistency, but changes ownership/ACL/reparse semantics and is
not necessary to solve deterministic serialization. It deserves a separate
review if atomic generator publication becomes a requirement.

Relevant permutations:

- Option C may return a validated path to each caller or own both validation
  and serialization. Owning serialization is safer because no caller can
  bypass the explicit encoding.
- The helper can permit native rooted and FileSystem-provider-qualified
  absolute paths while rejecting all other providers.
- Atomic replacement is deliberately not mixed into this correction.

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Fail-closed path/serialization correctness | 30 | Incorrect provider or wildcard handling can write the wrong object or fail opaquely |
| Windows PowerShell 5.1/PowerShell 7 compatibility | 18 | The generator explicitly supports both editions and Windows/POSIX hosts |
| Diagnostic usability | 15 | Operators need the captured destination and underlying cause |
| P1↔T1 consistency | 15 | The two generators should expose the same observable safety contract |
| Single-source maintainability | 12 | Four drifting copies of a path boundary are a future defect source |
| Scope/churn | 5 | A small helper is preferable, but correctness dominates |
| Implementation difficulty | 5 | The implementation should remain reviewable by a new maintainer |

### Scoring

| Option | Correctness | Compatibility | Diagnostics | Convergence | Maintainability | Churn | Difficulty | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — current pattern | 1 | 4 | 2 | 1 | 2 | 5 | 5 | 44.2 |
| B — four copies | 5 | 5 | 5 | 5 | 2 | 3 | 3 | 88.8 |
| C — one helper | 5 | 5 | 5 | 5 | 5 | 3 | 3 | **96.0** |
| D — native-only | 4 | 3 | 4 | 3 | 4 | 4 | 4 | 73.4 |
| E — existing leaf | 2 | 3 | 3 | 2 | 3 | 4 | 4 | 53.0 |
| F — atomic replace too | 4 | 4 | 4 | 4 | 3 | 1 | 1 | 71.6 |

### Selected option

Select **Option C: one private serialization boundary in P1**.

The issue must require this sequence for all four final writes:

1. Capture the original destination string for diagnostics.
2. Reject null/empty/whitespace, wildcard-bearing, relative, and malformed
   provider input before filesystem access. Do not trim or rewrite it.
3. Call the unresolved-path overload that returns `ProviderInfo` and
   `PSDriveInfo`; require exactly the FileSystem provider.
4. Require the resulting provider-internal path to be one unambiguous rooted
   absolute path, normalize it once with `Path.GetFullPath`, and reject every
   exception or inconsistent result.
5. Accept one already-complete final payload, normalize CRLF and lone CR to LF
   once at this boundary, and perform no later text transformation.
6. Construct `System.Text.UTF8Encoding($false)` and call
   `File.WriteAllText` exactly once. Do not append an implicit newline.
7. On failure, report the captured destination, stable phase, and preserved
   underlying exception without claiming a partial write succeeded.

Add fixtures for null/empty, relative, wildcard, non-FileSystem provider,
provider-qualified FileSystem, ordinary rooted path, serialization failure,
CRLF, lone CR, BOM absence, CR absence, and repeat-byte idempotence. Apply the
same observable contract in T1 while retaining repository-specific payloads.

## C-04 — Add resource limits and a reusable caller-context lifecycle

### Options

**Option A — Keep exact-four-entry validation without byte ceilings and keep
caller setup inline.** This limits entry count but permits oversized or highly
compressed content and preserves duplicated root/teardown algorithms.

**Option B — Add archive and extraction limits only.** Bound retained,
declared, and actual bytes in the existing helper but leave every workflow and
test to create/remove caller roots independently.

**Option C — Add a caller-context production script only.** Centralize
ownership acquisition and teardown but leave the archive vulnerable to
resource exhaustion within four entries.

**Option D — Add both finite limits and one production context manager in
P1A.** Keep caller cleanup and candidate cleanup as separate owners; make every
consumer invoke the exact production lifecycle.

**Option E — Rely on system temporary directories and recursive cleanup.**
Use `GetTempPath`/random names and delete the root recursively in `finally`.
This is easy but turns an uncertain substituted/link entry into a potentially
destructive traversal.

**Option F — Replace the helper with an external archive action/library.**
Delegate ZIP expansion and cleanup. This adds a supply-chain/action role,
typically auto-extracts before repository-specific manifest validation, and
does not solve caller ownership.

Permutations evaluated for Option D:

- Limits may be constants or parameters. Reviewed constants with test-only
  lower injection are clearer; production callers must not raise them.
- Candidate cleanup remains in the archive helper. Caller-context cleanup
  removes only explicit ordinary owned paths after helper streams are disposed.
- Unknown state is retained with diagnostics rather than recursively “cleaned
  up.”

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Resource-exhaustion resistance | 25 | Four ZIP entries can still exhaust disk, memory, or runner time |
| Ownership-safe cleanup | 22 | Cleanup must never follow or recursively delete uncertain state |
| Reuse without algorithm drift | 15 | Workflow and harness callers need one production lifecycle |
| Cross-platform behavior | 12 | Windows links/reparse points and POSIX links must fail consistently |
| Adversarial testability | 12 | Declared/actual overflow and cleanup substitution need stable oracles |
| Failure diagnostics/recovery | 8 | Retained state and primary failures must remain understandable |
| Churn | 3 | A third script/file is acceptable when it owns a real trust boundary |
| Implementation difficulty | 3 | Complexity matters least relative to filesystem safety |

### Scoring

| Option | Limits | Cleanup | Reuse | Platforms | Tests | Diagnostics | Churn | Difficulty | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — unchanged | 1 | 2 | 1 | 3 | 2 | 2 | 5 | 5 | 38.0 |
| B — limits only | 5 | 2 | 2 | 4 | 3 | 3 | 4 | 4 | 66.2 |
| C — context only | 1 | 5 | 5 | 4 | 4 | 4 | 4 | 4 | 72.4 |
| D — limits + context | 5 | 5 | 5 | 5 | 5 | 5 | 3 | 3 | **97.6** |
| E — recursive temp cleanup | 4 | 1 | 3 | 4 | 2 | 2 | 4 | 4 | 55.8 |
| F — external extractor | 4 | 2 | 2 | 3 | 3 | 3 | 1 | 1 | 55.2 |

### Selected option

Select **Option D** and make P1A its sole implementation owner.

Required production ceilings, unless implementation-time measurements justify
a lower value:

- retained archive: at most 32 MiB;
- exactly four entries;
- declared uncompressed bytes per entry: at most 8 MiB;
- declared uncompressed total: at most 32 MiB;
- actual copied bytes per entry: at most 8 MiB; and
- actual copied total: at most 32 MiB.

Reject negative, overflowed, unreadable, inconsistent, or over-limit values
before candidate creation when knowable. During copy, count bytes independently
of ZIP declarations and stop immediately at the actual ceilings. The current
four generated files total well below these defaults, so the limits preserve
ordinary repository behavior with substantial headroom.

Add
`.github/workflows/Manage-StyleGuideCandidateInvocationContext.ps1` defining
exactly `New-StyleGuideCandidateInvocationContext` and
`Remove-StyleGuideCandidateInvocationContext`. Creation accepts an explicit
runner-controlled parent, proves a fresh ordinary non-reparse child through a
finite collision-only retry, creates a separate download directory, and
returns explicit ownership metadata plus an absent candidate leaf. Teardown
revalidates the full envelope and journal, removes proven ordinary entries
nonrecursively deepest-first, and retains everything on uncertainty while
preserving the primary failure.

The archive helper remains independently distrustful of the context. Its
candidate cleanup owns only helper-created candidate files/directory. Every
workflow consumer and the harness must pass an exact context-manager path and
use both production cleanup functions. Test caller cleanup and candidate
cleanup independently, including declared/actual overflow, partial extraction,
unexpected child, link/reparse substitution, missing entry, primary-plus-
cleanup failure, and unrelated sentinel preservation.

## C-05 — Strengthen the writer credential and identity boundary

### Options

**Option A — Preserve checkout credentials.** Keep `contents: write` and
`persist-credentials: true`, then use ordinary `git push`. This is operationally
simple but leaves an authenticated Git configuration available to every later
step and does not bind the push to one expected ref/SHA.

**Option B — Use the ephemeral job `GITHUB_TOKEN`, never persist it, and
materialize it only for the exact push.** Accept honestly that GitHub creates
the write-capable token for the whole writer job. Set every checkout to
`persist-credentials: false`; do not put the token in an ordinary environment,
URL, file, artifact, or command string; pass one environment-backed HTTP
authorization configuration only to the push process and remove it in
`finally`.

**Option C — Keep the job token read-only and use a fine-grained PAT stored in
a protected environment.** Inject it only into the push step. This creates a
true step-scoped materialization boundary, but introduces a long-lived
maintainer credential, rotation/revocation duties, and a new repository secret.

**Option D — Split revalidation from a minimal write job.** Perform all
candidate/harness work read-only, then let a very small `contents: write` job
consume a cryptographically bound approval and push. This reduces write-token
exposure but creates another inter-job evidence boundary and cannot make
`GITHUB_TOKEN` permissions step-scoped.

**Option E — Mint a short-lived GitHub App installation token at promotion.**
Keep the job token read-only, protect App credentials with an environment, and
mint a repository-scoped token immediately before push. This improves lifetime
control but adds App governance, private-key handling, another action/script,
and a more complex incident model.

**Option F — Replace direct synchronization with a bot pull request.** Push a
bot branch or create a PR and require a human/branch protection to merge. This
can improve human oversight but changes the repository's automatic generated-
artifact publication model and still needs a credential to create/update the
branch/PR.

**Option G — Combine B with a deliberately minimal writer topology.** Keep the
ephemeral job token, but move every possible check to read-only jobs, retain
only required at-use revalidation/mutation/push steps in the writer, and state
the actual boundary accurately: the token exists job-wide, while no persisted
or process-visible credential exists outside the exact push.

All viable options also need the same identity, approval, regeneration, lease,
diagnostic, and negative-drill corrections; credential choice alone is not a
complete writer boundary.

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Credential exposure minimization | 28 | A generated-artifact job should have the smallest practical write-capable surface |
| Achievable and accurately stated boundary | 20 | Security claims must match GitHub's job-scoped permission model |
| Credential provenance/lifetime/revocation | 15 | Ephemeral platform tokens reduce long-lived secret risk |
| Operational reliability and recovery | 12 | Maintainers need predictable no-op, race, rejection, and incident behavior |
| Audit and negative-test strength | 10 | Sentinel and event/lease drills must prove the claimed boundary |
| Compatibility with automatic publication | 5 | The repository intentionally synchronizes generated artifacts |
| Configuration churn | 5 | New Apps/secrets/jobs have real governance cost |
| Implementation difficulty | 5 | Complexity can itself create security defects |

### Scoring

| Option | Exposure | Accurate | Lifetime | Operations | Audit | Automation | Churn | Difficulty | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — persisted checkout | 1 | 3 | 1 | 5 | 1 | 5 | 5 | 5 | 49.6 |
| B — nonpersisted job token | 4 | 5 | 5 | 5 | 4 | 5 | 4 | 4 | 90.4 |
| C — protected PAT | 5 | 5 | 2 | 2 | 5 | 3 | 2 | 2 | 75.8 |
| D — separate minimal writer | 4 | 5 | 5 | 4 | 5 | 4 | 3 | 3 | 87.0 |
| E — GitHub App token | 5 | 4 | 4 | 2 | 4 | 3 | 1 | 1 | 73.8 |
| F — bot pull request | 5 | 4 | 5 | 2 | 4 | 1 | 1 | 1 | 74.8 |
| G — B + minimal writer | 5 | 5 | 5 | 5 | 5 | 5 | 3 | 3 | **96.0** |

### Selected option

Select **Option G**. Do not introduce a long-lived PAT or GitHub App solely to
claim step-scoped GitHub permissions. State the platform boundary truthfully:
the ephemeral `GITHUB_TOKEN` has `contents: write` for the complete minimal
writer job, but checkout never persists it and workflow code materializes it
only in the exact push process.

P1B must additionally require:

1. Terminal approval runs with `if: always()`, names the exact prerequisite
   result set, and rejects every failure, cancellation, or unexpected skip.
2. The writer's first four executable statements snapshot purpose-specific
   `TARGET_REF`/`EXPECTED_SHA` and ambient `GITHUB_REF`/`GITHUB_SHA`.
3. Before mutation or token expansion, reject empty values, leading/trailing
   whitespace, CR/LF/control characters, malformed/non-head refs, malformed or
   noncanonical object IDs, ref disagreement, SHA disagreement, and non-commit
   objects. Environment strings cannot ordinarily contain NUL; document that
   platform boundary instead of pretending to test an impossible value.
4. Never reread those four environment variables. Use the captured
   target/ref pair unchanged for checkout proof, remote preflight, expected
   parent, exact lease, and full destination refspec.
5. Independently run the exact expected-commit generator in a controlled
   location immediately before use and compare every candidate byte; do not
   trust another runner's filesystem.
6. Preflight the exact remote ref, create one exact four-file commit with one
   expected parent, and push once with
   `--force-with-lease=<ref>:<expected-sha> HEAD:<ref>`. Never retry/rebase a
   stale writer.
7. Keep xtrace disabled. Pass one environment-backed Git HTTP authorization
   configuration only to that push process; clear/restore it in `finally`.
8. Add digest, malformed transport, identity, stale-preflight, lease-race,
   no-op, unrelated-event, failed/skipped dependency, and token-sentinel
   drills. Prove the protected remote remains unchanged for every negative.
9. Upload redacted, bounded, uniquely named diagnostics only on ordinary
   failure, never success/cancellation, with seven-day retention.

Measure CI time/storage after deployment and review it as governance evidence.
Cost thresholds may open a follow-up but must not silently remove a required
security cell.

## C-06 — Bound P3's Node support set

### Options

**Option A — Keep `>=<selected minimum>`.** This conventional library-style
floor is easy to understand but claims support for untested EOL, Current, and
future majors.

**Option B — Declare a finite semver union of reviewed LTS lines.** After
package selection, express every supported major line and any required patch
floor exactly; make package metadata, both production guards, and CI use the
same set.

**Option C — Support only hosted Node 24.** Use one tested LTS line everywhere.
This is very clear and secure but removes the useful older-LTS contributor
floor if the dependency tree works on Node 22.

**Option D — Support only the selected minimum Node 22 line.** This minimizes
the declared set but discards the preferred hosted Node 24 role and delays
testing against the newer LTS used by Actions/tooling.

**Option E — Use a contiguous range such as `>=22 <25`.** This looks bounded
but admits Node 23, which is EOL and not an intended validation cell.

**Option F — Put exact versions only in workflow matrix documentation.** Keep
`package.json` broad and rely on CI. Contributors and package managers still
receive a false engine claim.

**Option G — Use only `.nvmrc`/`.node-version`.** Pin a preferred developer
runtime but omit a package support range. This helps version-manager users but
does not define all supported lines or enforce the hook.

The finite set must be derived after selecting packages/npm. A future issue may
deliberately add a newly reviewed LTS line; P3 must not auto-admit it.

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Truthful support declaration | 28 | Metadata must not claim unreviewed/EOL runtimes |
| Complete executable coverage | 20 | Every claimed role needs clean install and compatibility evidence |
| Contributor usability | 16 | Local failures should be early, stable, and explain the accepted range |
| Future-major fail-closed behavior | 14 | A new runtime must not become supported without review |
| Package/npm engine compatibility | 12 | The final tree and CLI must admit every declared line |
| Change churn | 5 | A union and tests are modest compared with misleading metadata |
| Implementation difficulty | 5 | Guard logic should remain maintainable |

### Scoring

| Option | Truth | Coverage | Usability | Future-safe | Engines | Churn | Difficulty | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — open minimum | 1 | 3 | 4 | 1 | 4 | 5 | 5 | 52.8 |
| B — finite union | 5 | 5 | 5 | 5 | 5 | 3 | 3 | **96.0** |
| C — Node 24 only | 5 | 5 | 3 | 5 | 5 | 4 | 4 | 91.6 |
| D — Node 22 only | 4 | 5 | 3 | 5 | 4 | 4 | 4 | 83.6 |
| E — `>=22 <25` | 2 | 4 | 5 | 2 | 5 | 4 | 4 | 68.8 |
| F — CI list only | 2 | 3 | 3 | 2 | 4 | 4 | 4 | 56.0 |
| G — version file only | 2 | 2 | 3 | 3 | 4 | 4 | 4 | 54.8 |

### Selected option

Select **Option B**.

P3 must choose the finite set only after the final dependency/npm tree is
known. If Node 22 and Node 24 remain the supported roles, use a semver union
equivalent to:

```text
<reviewed Node 22 patch floor> <23 || <reviewed Node 24 patch floor> <25
```

Use valid semver union syntax in `engines.node`; do not admit 23, 25, current
26, or any future major. If the selected npm/package tree raises a patch floor,
encode it in both relevant clauses.

Create one dependency-free production decision implementation that both the
pre-commit guard and tracked integration harness exercise, or use two
implementations with exact shared fixtures and equality proof if shell/
PowerShell reuse is impractical. Test:

- the lowest supported patch and a normal current patch on every supported
  major;
- one patch below each applicable floor;
- a below-minimum major;
- every intervening unsupported major;
- current-but-unreviewed and above-maximum majors;
- malformed, empty, prefixed, whitespace, and extra-component versions.

Every claimed Node/OS role runs a clean install, package-tree validation, real
hook evidence, and relevant lint/harness work. Diagnostics state the observed
version, exact accepted union, and remediation. Do not phrase the durable
policy as “even-numbered majors”: Node's announced post-26 release cycle makes
that an unstable synonym for LTS.

## C-07 — Persist and continuously validate residual audit approvals

### Options

**Option A — Keep approvals only in P3's implementation-time validation
block.** Capture strong evidence in the pull request but merge no durable
exception record or validator.

**Option B — Always create an exception file, even when empty.** Keep one
stable schema and validator path. This makes future exceptions easy but leaves
an unnecessary permanent approval mechanism and can normalize empty
waiver-file maintenance.

**Option C — Add a tracked audit-policy validator and conditionally add an
exception file only for real residuals.** The validator requires a clean audit
and absent exception file by default; if residuals exist, it requires exact,
unexpired, approved equality.

**Option D — Use only public follow-up issues.** Record each residual in a
GitHub issue and trust humans to notice expiry/topology changes. Issues provide
accountability but are not an executable dependency-graph policy.

**Option E — Use registry/Dependabot dismissals as the sole record.** Rely on
platform alerts and dismissal metadata. That state may not represent
lockfile-only npm audit topology or travel with a clone/branch.

**Option F — Require zero findings with no exception path.** Fail P3 until
every advisory is eliminated. This is preferred when a maintained compatible
tree exists, but an absolute rule can force a disproportionate/incompatible
tool replacement or leave the issue permanently blocked without an explicit
risk decision.

Option C includes F as its ordinary successful case while retaining a tightly
bounded escape path for a genuinely unavoidable residual.

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Continuous policy correctness | 30 | Merged CI must enforce the current audit result, not only historical PR evidence |
| Clean-state simplicity | 15 | A zero audit should have no stale or blank approval artifact |
| Expiry/topology drift detection | 20 | New, removed, changed, or expired findings must fail automatically |
| Audit-native identity fidelity | 15 | Approval keys must match npm's actual package/advisory graph without false cross-products |
| Owner/incident usability | 10 | Maintainers need a real owner, follow-up, evidence, and clear tool-vs-policy failure |
| Churn | 5 | One validator/conditional record is acceptable for durable governance |
| Implementation difficulty | 5 | Parsing rigor matters more than convenience |

### Scoring

| Option | Continuous | Clean | Drift | Identity | Operations | Churn | Difficulty | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — PR-only | 1 | 5 | 1 | 4 | 2 | 5 | 5 | 51.0 |
| B — always-present file | 4 | 2 | 5 | 5 | 3 | 2 | 2 | 75.0 |
| C — validator + conditional file | 5 | 5 | 5 | 5 | 5 | 3 | 3 | **96.0** |
| D — issue-only | 2 | 4 | 2 | 2 | 4 | 5 | 5 | 56.0 |
| E — dismissal-only | 2 | 3 | 2 | 2 | 3 | 4 | 4 | 49.0 |
| F — unconditional zero | 5 | 5 | 5 | 5 | 4 | 2 | 2 | 92.0 |

### Selected option

Select **Option C**, with zero findings as the preferred result.

Add a tracked `.github/workflows/Test-NpmAuditPolicy.ps1` (or give the existing
tracked integration harness an equally explicit audit-policy entry point) that
uses the selected exact npm CLI and:

1. captures raw report-version-2 JSON and native exit status;
2. distinguishes registry/tool failures from vulnerability-policy failures;
3. validates every consumed metadata, vulnerability-property, `via`,
   `effects`, `nodes`, object advisory, and `fixAvailable` shape;
4. derives metadata counts from properties and validates reciprocal graph
   links;
5. resolves every node path to the matching package/version in
   `package-lock.json`;
6. forms unique residual approval identity as exact
   `(Package, AdvisoryUrl)`;
7. keeps `AuditNodePaths` as a separate exact package-keyed set rather than
   inventing advisory/path cross-products; and
8. runs in read-only hosted CI after clean installation.

If audit is clean, `.github/workflows/npm-audit-exceptions.json` must be absent;
the validator rejects an empty/stale file. If a residual remains, conditionally
add that file with exact package/advisory records, exact package/node sets,
severity/CVSS where supplied, exploitability, compensating controls, owner,
UTC creation/expiry, real public follow-up issue, approval identity/date, and
evidence that no compatible fixed tree exists.

Require exact equality: no missing, extra, duplicate, expired, topology-changed,
or already-fixed record. Recompute P3's affected/staged path set after the
audit disposition instead of preserving a fixed seven-file claim.

## I-P1-01 — Add explicit-null diagnostic-label cases

### Options

**Option A — Treat empty-string tests as sufficient.** Rely on PowerShell's
possible null-to-empty string coercion and keep `X-01..03` only.

**Option B — Add one explicit-null case per optional label.** Preserve the
three empty cases and add distinct stable IDs proving that explicit binding is
observed and rejected before filesystem/archive work.

**Option C — Add one representative explicit-null case.** Test only
`ArtifactId` and infer equivalent behavior for `RunId`/`RunAttempt`. This
leaves three independent binding names incompletely covered.

**Option D — Add `[ValidateNotNullOrEmpty()]` to the parameters.** Let the
PowerShell binder reject null/empty. This is concise but can change diagnostic
phase/text and makes it harder to prove the public omitted-versus-explicit
contract through `$PSBoundParameters`.

**Option E — Change label types to a custom wrapper/object.** Preserve null
identity without string coercion. This over-engineers diagnostic-only labels
and creates an unnecessary public interface change.

**Option F — Remove optional labels.** Eliminate the distinction entirely.
This weakens failure correlation for artifact/run/attempt diagnostics.

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Public-contract completeness | 25 | Omitted, empty, and explicit null are separately specified caller states |
| Proof of pre-filesystem rejection | 20 | Invalid diagnostics must not trigger enumeration/archive work |
| PowerShell binding fidelity | 18 | The test must observe `$PSBoundParameters`, not assume string value identity |
| Stable diagnostic quality | 15 | Failures need exact parameter and phase for operators |
| P1A↔T1A convergence | 10 | Equivalent public contracts should have equivalent cases |
| Test maintainability | 8 | Stable independent rows are easier to diagnose than combined fixtures |
| Churn | 4 | Three additional cases are low cost |

### Scoring

| Option | Contract | Pre-FS | Binding | Diagnostics | Convergence | Maintainability | Churn | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — empty only | 1 | 2 | 1 | 2 | 2 | 5 | 5 | 38.6 |
| B — three null cases | 5 | 5 | 5 | 5 | 5 | 4 | 4 | **97.6** |
| C — one null case | 3 | 4 | 3 | 3 | 3 | 5 | 5 | 68.8 |
| D — validation attribute | 4 | 5 | 3 | 4 | 4 | 4 | 4 | 80.4 |
| E — wrapper type | 5 | 5 | 5 | 4 | 2 | 1 | 1 | 81.4 |
| F — remove labels | 5 | 5 | 5 | 1 | 1 | 4 | 4 | 77.6 |

### Selected option

Select **Option B**.

Keep `X-01..03` as explicit empty-string cases and add:

- `X-04` — explicitly bound null `ArtifactId`;
- `X-05` — explicitly bound null `RunId`; and
- `X-06` — explicitly bound null `RunAttempt`.

Each child invocation must bind the named parameter explicitly to `$null`, not
omit it. The oracle requires:

- failure in stable `parameter` phase;
- exact rejected label name;
- proof that `$PSBoundParameters` observed the key as supplied;
- candidate leaf remains absent;
- download enumeration, archive open, and digest computation did not begin;
  and
- no unrelated sentinel changed.

The observable rejection may equal the corresponding empty-string case; the
input and binding evidence must remain separate. Add the six rows to the
P1A↔T1A comparison and classify any cross-repository difference explicitly.

## I-P1B-01 — Define terminal receipt of four matrix attestations

### Options

**Option A — Trust matrix job success only.** Let approval depend on the matrix
and assume success proves all four intended cells and the propagated tuple.
This does not give approval a mechanically inspectable four-cell identity set.

**Option B — Use four unique matrix output names.** Define static output keys
for `desktop/lf`, `desktop/crlf`, `core/lf`, and `core/crlf`; each child emits
only its own complete record. GitHub combines the distinct outputs for
approval.

**Option C — Replace the matrix with four explicit jobs.** Give every cell a
separate job ID and output. This is collision-free and explicit but duplicates
job YAML and makes future common changes error-prone.

**Option D — Upload one immutable attestation artifact per cell.** Approval
downloads/verifies four records. This creates a new action-role/retention/
artifact-identity surface and risks confusing evidence artifacts with the
candidate artifact.

**Option E — Call one local reusable workflow four times.** Explicit callers
could produce distinct outputs, but local reusable workflow permissions,
secrets, ref behavior, and an additional workflow file enlarge the policy
surface without improving the four-output primitive.

**Option F — Have preparation predict the four cells.** Approval validates a
preparation manifest and trusts aggregate matrix success. This proves intended
configuration, not the identity/tuple actually observed by each runner.

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Exact four-cell completeness | 28 | Approval must prove precisely the required cross-product ran |
| Completion-order/collision safety | 20 | Matrix order is undefined and duplicate output names overwrite |
| Tuple binding integrity | 15 | Every cell must bind artifact ID/digest/ref/SHA to its exact axes |
| Failure/skip visibility | 15 | Failed, cancelled, or unexpected skipped dependencies must block promotion |
| Workflow clarity | 8 | Reviewers should understand the transport from YAML alone |
| Additional action/trust surface | 8 | New evidence artifacts/actions add supply-chain and cleanup policy |
| Churn | 6 | Duplication matters, but less than exact approval evidence |

### Scoring

| Option | Complete | Collision-safe | Binding | Result-safe | Clarity | Surface | Churn | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — success only | 1 | 5 | 2 | 2 | 5 | 5 | 5 | 59.6 |
| B — unique outputs | 5 | 5 | 5 | 5 | 4 | 5 | 4 | **97.2** |
| C — explicit jobs | 5 | 5 | 5 | 5 | 3 | 5 | 2 | 93.2 |
| D — attestation artifacts | 5 | 5 | 5 | 5 | 3 | 2 | 2 | 88.4 |
| E — local reusable workflow | 4 | 4 | 4 | 4 | 2 | 3 | 1 | 71.6 |
| F — preparation manifest | 2 | 5 | 3 | 2 | 5 | 5 | 5 | 68.2 |

### Selected option

Select **Option B**.

P1B must define exactly four static job output keys, for example:

```text
attestation_desktop_lf
attestation_desktop_crlf
attestation_core_lf
attestation_core_crlf
```

Every child:

1. asserts `strategy.job-total == 4`;
2. validates its exact edition and fixture-EOL axes;
3. compares its artifact ID, bare digest, event SHA, full ref, and
   `has_changes` to preparation;
4. performs all required helper/harness/generator byte checks; and
5. emits one canonical, bounded record under only its own stable key.

Terminal approval runs with `if: always()`, requires exact success for
preparation, Markdown/Ubuntu validation, and the matrix job, then requires
exact equality of the four-key set. It parses each record fail-closed, rejects
empty/duplicate/malformed/unexpected fields, and compares every tuple to
preparation. Only an approved push to `main` with canonical
`has_changes=true` authorizes the writer.

Add controlled fixtures for missing, extra, duplicate/malformed, wrong-axis,
mismatched tuple, failed cell, cancelled cell, unexpected skip, and an
attempted shared output name. Four explicit jobs remain the fallback only if
implementation proves GitHub cannot express the static unique-output mapping
without empty-value overwrite.

## I-P3-01 — Make the npm CLI policy explicit across runtime cells

### Options

**Option A — Use whichever npm each Node installation bundles.** Record
versions but impose no policy. Node 22 and 24 cells can interpret lock/audit
behavior differently and hosted patch updates can silently change npm.

**Option B — Install and assert one exact npm CLI in every cell.** Use the same
version for lockfile generation, clean install, tree validation, audit, lint,
and hook tests across supported Node lines.

**Option C — Review one bundled npm per Node line.** Record exact Node/npm
pairs, designate one normative lockfile producer, and prove other pairs install
without rewriting. This is contributor-friendly but the pairs drift when a
hosted Node patch changes.

**Option D — Use one exact npm only for lockfile/audit mutation and bundled npm
for compatibility cells.** This clearly separates roles but means “green on
Node 22/24” does not prove the exact production lint/audit CLI behaves in all
cells.

**Option E — Pin a package-manager field and rely on Corepack.** Corepack's
ordinary workflow is designed around package managers such as Yarn/pnpm and is
not a reliable substitute for explicitly selecting npm. It also adds another
tool/lifecycle assumption.

**Option F — Run npm in a container.** This can pin Node/npm together but
diverges from the real Git hook and Windows/Git Bash environment and adds an
image supply chain.

**Option G — Vendor the npm CLI.** Commit/package npm itself. This is excessive
for a small Markdown toolchain and creates a large maintenance/security
surface.

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Lockfile/audit reproducibility | 25 | npm version affects lockfile and report behavior |
| Compatibility with every supported Node | 18 | The selected CLI must actually run on all declared lines |
| Cross-cell semantic equality | 15 | CI roles should not prove subtly different install/lint policies |
| Contributor usability | 12 | Local remediation must be understandable and repeatable |
| Package-manager provenance/security | 10 | The CLI itself is part of the reviewed dependency toolchain |
| Hosted CI determinism | 10 | Runner image/bundled npm drift must fail clearly |
| Churn | 5 | One explicit install/assert step is acceptable |
| Implementation difficulty | 5 | Operational complexity can cause bypasses |

### Scoring

| Option | Reproducible | Node-compatible | Equal semantics | Usability | Provenance | CI stable | Churn | Difficulty | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — ambient bundled | 1 | 4 | 1 | 5 | 2 | 1 | 5 | 5 | 50.4 |
| B — one exact npm | 5 | 5 | 5 | 4 | 4 | 5 | 3 | 3 | **91.6** |
| C — reviewed bundled pairs | 4 | 5 | 3 | 5 | 5 | 3 | 4 | 4 | 83.0 |
| D — exact mutation only | 4 | 5 | 3 | 4 | 4 | 4 | 4 | 4 | 80.6 |
| E — Corepack field | 3 | 3 | 4 | 3 | 3 | 4 | 3 | 2 | 64.0 |
| F — container | 5 | 3 | 2 | 1 | 3 | 5 | 1 | 1 | 62.2 |
| G — vendored npm | 5 | 5 | 5 | 2 | 2 | 5 | 1 | 1 | 78.8 |

### Selected option

Select **Option B**.

At implementation time:

1. Review the candidate npm release's provenance/changelog and its own
   `engines.node`; require it to admit every selected Node line and patch
   floor.
2. Record the exact npm version as one normative constant in P3 evidence and
   expose a stable repository command that installs/asserts it without force
   or engine bypass.
3. In every local/hosted cell, first prove the active `node` executable and
   version, install/resolve the exact npm, prove `npm`'s
   `process.execPath`/`process.versions.node` points to that Node, and require
   exact npm equality.
4. Use only that application for lockfile generation, `npm ci`,
   `npm ls --all`, `npm audit`, both lint surfaces, and the real installed-hook
   tests.
5. Designate one exact Node/npm pair—normally preferred Node 24 plus the
   selected npm—as the only lockfile producer. Other cells must start from the
   committed lockfile and prove no rewrite.
6. Add an appropriate npm engine declaration if it communicates the local
   contract accurately; do not add a misleading package-manager field merely
   for appearance.
7. Record exact Node/npm pairs in pull-request evidence and fail rather than
   silently accepting a runner's bundled npm.

If no maintained npm release supports every selected Node line, revisit the
Node set or deliberately choose Option C and rewrite the issue to describe
multiple reviewed CLIs. Do not claim one selected npm while using several.

## I-P2-01 — Rebase P2's otherwise-ready prerequisite

### Options

**Option A — Leave P2 blocked by the original monolithic P1 title.** After the
split, that title refers only to generator foundations and no longer proves the
final publication path P2 relies on.

**Option B — Make P2 depend on P1B and refresh the prerequisite snapshot.**
Keep P2's documentation work unchanged; consume the final merged
generator/helper/context/workflow/writer contract.

**Option C — Run P2 after P1 but before P1A/P1B.** The deterministic generator
can regenerate P2 output, but the later writer activation then has to absorb a
new source/generated baseline and P2 cannot retain final publication evidence.

**Option D — Run P2 before all P1 work.** Fix the content immediately using the
current edition-sensitive generator. This risks line-ending/artifact churn and
must be revalidated after P1.

**Option E — Fold P2's documentation change into P1B.** This avoids a dependency
edge but mixes an unrelated visual/content correction into the security-
sensitive writer activation.

**Option F — List P1, P1A, and P1B as separate direct prerequisites.** This is
technically complete but redundant: P1B already depends on exact P1/P1A merge
commits and is the final public boundary.

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Correct final generator/publication baseline | 30 | P2 changes source and generated bytes and must use the enduring path |
| Deterministic linear sequencing | 20 | The slate should have one obvious next issue |
| Content/security scope isolation | 15 | P2 should remain a focused documentation correction |
| Cold-reader dependency clarity | 15 | The filed blocked-by relationship must identify the real final prerequisite |
| Validation continuity | 10 | P2 evidence should include the merged helper/matrix/writer behavior it relies on |
| Churn | 5 | Prerequisite prose changes are low-cost |
| Implementation difficulty | 5 | Rebasing should not redesign P2 |

### Scoring

| Option | Baseline | Sequence | Isolation | Clarity | Validation | Churn | Difficulty | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — stale P1 | 2 | 1 | 5 | 2 | 2 | 5 | 5 | 51.0 |
| B — depend on P1B | 5 | 5 | 5 | 5 | 5 | 4 | 4 | **98.0** |
| C — between P1/P1A | 3 | 2 | 4 | 3 | 3 | 4 | 4 | 61.0 |
| D — before P1 | 1 | 1 | 4 | 2 | 1 | 4 | 4 | 38.0 |
| E — merge into P1B | 4 | 4 | 1 | 2 | 4 | 2 | 2 | 61.0 |
| F — depend on all three | 5 | 4 | 5 | 4 | 5 | 3 | 3 | 89.0 |

### Selected option

Select **Option B**.

P2 keeps its existing H1, rationale/content change, metadata advancement,
six-file source/generated scope, exact regeneration, lint, whitespace, content,
and post-merge checks. Change only its prerequisite-facing contract:

1. State that P2 implements only after
   **Promote generated style-guide artifacts through a least-privileged
   verified writer** (P1B) merges.
2. When filed, record P2's real blocked-by relationship to P1B and retain
   P1B's exact merge commit in implementation evidence.
3. At implementation start verify P1B's inherited exact P1/P1A versions,
   generator destination/byte behavior, context manager, both cleanup owners,
   resource limits, immutable artifact ID/digest, four attestations, terminal
   approval, nonpersisted credential policy, exact writer identity/lease, and
   final action-role table.
4. Consume those interfaces; do not restate their algorithms or add them to
   P2's affected files.
5. Retain P3 after P2 in the stipulated sequence and make P3 consume the final
   P1B/P2 runtime and documentation baseline.

No other P2 revision is justified by this finding.

## Resulting issue order

The selected options produce one linear slate:

1. [P1 — Make artifact generation byte-deterministic across PowerShell
   editions and hosts](../PSStyleGuide/01PSStyleGuideP1.md)
2. [P1A — Add a fail-closed cross-platform style-guide candidate
   validator](../PSStyleGuide/01aPSStyleGuideP1A.md)
3. [P1B — Promote generated style-guide artifacts through a least-privileged
   verified writer](../PSStyleGuide/01bPSStyleGuideP1B.md)
4. [P2 — Make the non-compliant blank-line example visibly
   distinct](../PSStyleGuide/02PSStyleGuideP2.md)
5. [P3 — Remediate Markdown lint dependency advisories and add npm update
   governance](../PSStyleGuide/03PSStyleGuideP3.md)

Each issue consumes exact predecessor merge commits. When filed, replace
title-only references with actual issue URLs and record real blocked-by
relationships. The issue bodies do not identify themselves as revisions or
include change-log commentary about this planning pass.
