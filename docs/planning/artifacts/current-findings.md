# Review of the PSStyleGuide P1/P2/P3 GitHub issue slate

## Scope and current-state anchor

This review covers P1, P2, and P3 in the required P1 → P2 → P3 order. It
preserves the intentional H1 titles and P1/P2/P3 naming. The parallel
TerraformStyleGuide slate is comparison context, not an additional review
target.

The supplied criticism contains seven numbered recommendations. Each is
audited below before independent findings are added.

Repository and issue evidence was checked against:

- planning commit
  `f4c9e055b9068fe9fb26f3650320645c3c31f979`;
- current `main` commit
  `4346310e7deebffb4159c75e30d9546263dfd649`;
- the current generator, workflows, hook, manifest, and lockfile; and
- the then-current T1/T1A/T1B layer boundaries.

The live implementation baseline still matches the issues' premise:

- `.gitattributes` contains exactly `* text=auto eol=lf`;
- the generator has four edition-sensitive `Set-Content -Encoding UTF8`
  artifact writes and a here-string frontmatter;
- the build workflow has path filters, workflow-wide write permission, mutable
  action tags, and a direct `git push`;
- Markdown CI uses mutable action tags and Node 20; and
- a fresh 2026-07-29 audit under Node 26.5.0/npm 11.7.0 reports seven
  vulnerability properties—five high and two moderate—and fourteen object
  advisory records.

The audit runtime above is baseline-inspection evidence only. It is not
evidence for P3's eventual supported Node/npm cells.

## Overall assessment

The revised slate is materially stronger than the earlier version described
by the supplied criticism. In particular, P1 now has one normative action-role
table, P3 tests complete clean runtime cells, and P3's inline residual-audit
validator checks report topology rather than trusting summary counts. Those
fixes are present and should not be reopened.

The remaining work is unevenly distributed:

| Recommendation | Verdict | Required disposition |
| --- | --- | --- |
| C-01: split P1 | Valid, but architectural rather than a correctness proof | Prefer P1/P1A/P1B; allow one P1 only with explicit layer gates |
| C-02: repair Terraform comparisons | Valid | Compare P1↔T1, P1A↔T1A, and P1B↔T1B |
| C-03: converge destination paths | Valid | Add a fail-closed FileSystem destination contract |
| C-04: add limits and context lifecycle | Valid | Add byte limits and one production caller-context owner |
| C-05: harden the writer | Valid, with cost evidence deferred | Shorten credential lifetime and strengthen identity/use-time proof |
| C-06: bound Node support | Valid | Claim and execute one finite reviewed runtime set |
| C-07: persist audit approvals | Conditionally valid | Add tracked policy only if a residual remains |

P2 is ready after a prerequisite-reference update. P1 is implementable but not
yet the best security-review unit. P3 has strong one-time validation but its
declared Node range and potentially ephemeral residual approvals are not yet
durable repository policy.

Recommended final implementation sequence:

1. P1 — preserve its existing H1, but limit it to deterministic
   generator/runtime/action foundations.
2. P1A — add the archive validator, caller-context lifecycle, resource limits,
   and adversarial harness without activating production publication.
3. P1B — atomically activate transport, four-cell approval, least-privileged
   writer, at-use regeneration, and bounded diagnostics.
4. P2 — preserve its existing H1 and implement after P1B.
5. P3 — preserve its existing H1 and implement after P2 unless its real
   filing-time audit creates a documented blocker that justifies resequencing.

## Supplied-criticism audit

### C-01: Split P1 along T1/T1A/T1B trust boundaries

**Verdict: Valid as a high-value architecture and reviewability
recommendation; not proof that the current single P1 is technically
incoherent.**

P1 is one 2,922-line issue and owns three separable trust layers:

1. deterministic generator/runtime/action foundations;
2. an archive validator plus adversarial harness; and
3. production artifact transport, matrix approval, credentials, commit, and
   push.

The current issue is internally sequenced and could be implemented atomically.
Therefore, line count alone does not make it incorrect. Keeping one issue also
avoids two intermediate workflow migrations and prevents the temporary
publication boundary from existing longer than necessary.

The supplied split is nevertheless the better handoff design. It allows the
security-sensitive validator and its tests to merge without production
activation, gives the writer an exact merged helper prerequisite, and matches
the parallel Terraform trust boundaries. The need identified in C-04 for a
third caller-context script also invalidates P1's current six-file scope.

Recommended disposition:

- Split P1 into P1, P1A, and P1B as proposed.
- Make P1A workflow-inert and record P1's exact merge commit.
- Make P1B consume exact P1/P1A commits and replace P1's temporary publication
  boundary atomically.
- Make P2 depend on P1B, because P2 changes source/generated bytes and needs
  the final publication path.
- Keep P3 after P2 unless P3's real vulnerability-policy gate requires the
  complete P3 work to run first.

If the maintainer deliberately retains one P1, soften the supplied criticism's
categorical “not ready” claim, but require three explicit internal review
gates, layer-specific acceptance evidence, and all C-02 through C-05
corrections before filing.

### C-02: Replace stale “parallel T1” comparisons

**Verdict: Valid.**

P1's generator section and helper section both refer to “the parallel T1
issue.” In the revised Terraform slate:

- generator/runtime/action foundation behavior belongs to T1;
- validator/context/harness behavior belongs to T1A; and
- transport/approval/writer behavior belongs to T1B.

The current P1 helper matrix therefore points to the wrong owner, and P1 has no
complete reciprocal T1B matrix for credential exposure, four-value identity,
at-use regeneration, terminal dependency aggregation, diagnostics, and
measured CI cost.

Recommended correction:

- If C-01 is adopted, define reciprocal P1↔T1, P1A↔T1A, and P1B↔T1B matrices.
- If P1 remains monolithic, retain one issue but divide its comparison evidence
  into those three named Terraform layers.
- In either form, have the implementation that starts second compare exact
  merge commits and classify every row as `same`, `intentional difference`, or
  `blocker`.
- Treat unexplained observable security/failure differences as blockers.
- Update P2's prerequisite inventory and P3's enduring/non-goal inventory to
  name the final PS scripts and layers.

The repositories should remain runtime-independent. The correction is to
compare current contracts, not to introduce a shared package.

### C-03: Make the generator destination-path contract converge

**Verdict: Valid.**

P1's prescribed write pattern calls the single-argument
`GetUnresolvedProviderPathFromPSPath` overload and immediately passes the
result to `File.WriteAllText`. The same P1 issue has a much stronger path
contract for the archive helper, but it does not apply that contract to the
four generator destinations.

Microsoft documents that the unresolved-path API can accept wildcard-bearing
paths and leaves the wildcard characters unresolved. The current pattern also
does not establish the provider through the overload that returns
`ProviderInfo`, reject a non-filesystem provider, or include the captured
destination in a serialization failure.

“Multiple resolutions” is most directly a concern for resolved wildcard
paths; the unresolved overload returns one provider-internal string. P1 should
still reject wildcard syntax before calling it so a literal `*`, `?`, or
bracket expression cannot reach a .NET filesystem API.

Recommended correction for every final write:

1. reject null/empty, wildcard-bearing, relative, and ambiguous input;
2. obtain the provider/drive metadata and require the FileSystem provider;
3. produce one unambiguous absolute provider-internal path;
4. normalize the complete final payload;
5. serialize once with `UTF8Encoding($false)` and `WriteAllText`; and
6. report the captured destination and underlying exception on failure.

Artifact names and frontmatter content remain intentional repository
differences.

### C-04: Add resource limits and a reusable caller-context lifecycle

**Verdict: Valid.**

P1 enforces an exact four-entry manifest but has no retained-archive,
per-entry declared, total declared, or actual copied-byte limit. Four entries
can still contain a compression bomb, and declared uncompressed lengths are
not proof of the bytes a stream will produce.

P1 also repeats unique-root acquisition and caller teardown in workflow
consumers and its harness. The candidate helper owns only candidate-state
cleanup. The revised T1A contract gives caller-owned context a separate,
reusable production owner.

Recommended correction:

- Add reviewed finite limits for retained archive bytes, declared bytes per
  entry, declared total bytes, actual bytes per entry, and actual total bytes.
- Use T1A's 8 MiB/entry and 32 MiB archive/total defaults unless measured
  PSStyleGuide artifacts require a documented alternative.
- Add
  `.github/workflows/Manage-StyleGuideCandidateInvocationContext.ps1` with
  exact `New-StyleGuideCandidateInvocationContext` and
  `Remove-StyleGuideCandidateInvocationContext` functions.
- Keep the archive helper independently distrustful of the context object.
- Make every workflow consumer and the harness use the production context
  functions rather than copy their algorithms.
- Test caller cleanup and candidate cleanup separately, including primary
  failure preservation, unknown-entry retention, and nonrecursive deepest-first
  deletion of only proven owned entries.

If C-01 is adopted, this work belongs in P1A and P1B activates it.

### C-05: Strengthen the writer credential and identity boundary

**Verdict: Valid, with CI-cost measurement treated as governance rather than a
security prerequisite.**

P1's exact role table sets `persist-credentials: true` for the writer
checkout. The pinned checkout action documents that persisted credentials
configure its token for later authenticated Git commands until post-job
cleanup. Checkout v7 protects that storage under runner temporary state rather
than the ordinary `.git/config` path, but the credential still exists for more
of the job than the one push requires.

P1's mutation block also captures only `TARGET_REF` and `EXPECTED_SHA` in its
first statements. It later reads `GITHUB_REF` and `GITHUB_SHA` directly, then
says none of the four variables may be read again. That is internally
consistent after the comparison, but it is weaker and harder to audit than one
four-value snapshot.

Other confirmed gaps:

- the four identity values do not all receive one closed
  whitespace/control/ref/object grammar before mutation;
- terminal approval runs only after dependencies succeed rather than running
  with `always()` and explicitly rejecting failures/unexpected skips;
- the writer is prohibited from independently regenerating at use;
- no token-sentinel drill proves absence from logs, argv records, files, and
  artifacts; and
- diagnostic upload/retention is not consistently failure-only and bounded.

Recommended correction in P1B, or in the writer layer if P1 stays whole:

1. Set `persist-credentials: false` on every checkout.
2. Snapshot purpose-specific `TARGET_REF`/`EXPECTED_SHA` and ambient
   `GITHUB_REF`/`GITHUB_SHA` as the first four executable statements.
3. Reject empty, leading/trailing-whitespace, CR/LF, control, malformed ref,
   and malformed/noncanonical object values before credential expansion or
   repository mutation. Environment strings cannot contain NUL on ordinary
   hosted platforms, but explicitly documenting that boundary is still
   clearer than silently depending on it.
4. Never reread the four environment variables after snapshot.
5. Make approval use `if: always()`, inspect the exact required dependency
   result set, and fail for any failure, cancellation, or unexpected skip.
6. Independently rerun the exact generator from the expected commit in a
   controlled location and compare it to the validated candidate before
   copying.
7. Expose one environment-backed Git HTTP authorization value only for the
   exact push, then restore/remove it in `finally`.
8. Add token-sentinel and stale/race/no-op/event drills that prove no
   unintended write or disclosure.
9. Make diagnostic uploads ordinary-failure-only, redacted, bounded, uniquely
   named, and explicitly retained for a short period.

Recording real CI duration and storage after deployment is sensible operational
governance. It should not block the initial security correction, and a cost
threshold must not silently remove a required cell.

### C-06: Bound P3's Node support set

**Verdict: Valid.**

P3 now evaluates the complete direct/transitive tree, requires Node 24
compatibility, and runs independently clean selected-minimum and Node 24 cells.
Those are real improvements.

Its normative policy still sets:

```text
engines.node = >=<selected minimum>
```

and gives both guards the same lower-bound-only decision. With a minimum of
22, that admits Node 23, 25, current-but-not-yet-LTS Node 26, and every future
major. On 2026-07-29, Node 22 and 24 are LTS, Node 23 and 25 are EOL, and Node
26 is Current. The manifest/guards therefore claim more than the issue reviews
or executes.

Recommended correction:

- Define one exact finite set of reviewed major lines after package selection.
- Express that set as a semver union in `package.json`, including any patch
  floor imposed by the selected npm CLI or dependency tree.
- Make both production guards implement the same set, not a simple numeric
  minimum.
- Add stable cases for every supported major, one below-floor major, an
  intervening unsupported/EOL major, a malformed version, and an
  above-maximum/unreviewed future major.
- Continue running fresh complete cells for every claimed runtime role.

If the selected policy is Node 22 plus Node 24, the range must not admit 23,
25, 26, or later majors. A future P3/Dependabot review can deliberately add a
new line.

### C-07: Persist and continuously validate residual audit approvals

**Verdict: Valid when the final audit is not clean; unnecessary when the final
audit is clean.**

P3's current inline validator is unusually strong:

- it uses exact `(Package, AdvisoryUrl)` residual identity;
- keeps package-keyed `AuditNodePaths` separate;
- validates the consumed report-version-2 graph and metadata;
- resolves audit nodes in the lockfile;
- validates invariant UTC expiry;
- checks a public PSStyleGuide issue that is not a pull request; and
- records owner-acceptance evidence separately.

Those records exist only in the issue's implementation-time validation block.
P3's fixed seven-file scope provides no tracked exception record or permanent
audit-policy validator. If a residual is accepted, the merged repository will
not automatically reject expiry, topology drift, a new finding, a removed
finding with stale approval, or changed node paths.

Recommended correction:

- Keep the exception file absent for a clean audit.
- If a residual remains, conditionally add a tracked structured file using
  P3's exact package/advisory keys and separate package/node sets.
- Add a tracked validator that reproduces every audit shape, graph, lockfile,
  owner, follow-up, and expiry check on the selected npm version.
- Invoke it in read-only hosted CI after clean installation.
- Require exact equality: no missing, extra, duplicate, expired, or stale
  record.
- Reject an exception file when the current audit is clean.
- Compute P3's final changed/staged path set after the audit disposition rather
  than permanently fixing it at seven paths.

Because `npm audit` depends on registry availability and changing advisory
data, preserve the raw response, exact npm version, and a diagnostic that
distinguishes registry/tool failure from a policy violation. Do not convert a
network failure into a clean result.

## Independent findings

### I-P1-01: Add explicit-null diagnostic-label cases

P1's helper distinguishes omitted labels from explicitly empty strings, and
its stable `X-01..03` cases cover the three empty-string inputs. T1A's newer
public contract rejects explicit null or empty values.

For `[string]` parameters, PowerShell can coerce an explicitly bound null into
an empty string. The observable rejection can be the same, but the harness
should prove that `$PSBoundParameters` sees the label as supplied and that
filesystem/archive work does not start.

Recommended correction:

- Add one explicit-null case for `ArtifactId`, `RunId`, and `RunAttempt`.
- Require the parameter phase, exact label name, candidate absence, and no
  download enumeration/archive open.
- State whether explicit-null behavior is shared with T1A or an intentional
  difference.

### I-P1B-01: Define how terminal approval receives four matrix attestations

P1 requires a four-cell push matrix and says approval runs only after the
matrix succeeds. Each cell consumes preparation's ID/digest directly, so the
current topology is not vulnerable merely because it lacks a per-cell output.
It also does not let terminal approval mechanically prove the exact four cell
identities and each cell's complete artifact/SHA/ref tuple.

The stronger T1B requirement needs an explicit transport. GitHub combines
matrix outputs, but completion order is not guaranteed and duplicate output
names are overwritten by the last finishing cell.

Recommended correction:

- Give `desktop/lf`, `desktop/crlf`, `core/lf`, and `core/crlf` unique stable
  attestation keys.
- Have every cell assert the exact matrix axes, `strategy.job-total == 4`, and
  the complete propagated tuple.
- Make terminal approval require exact four-key equality and compare every
  record to preparation.
- Add missing, extra, duplicate/malformed, mismatched, failed, and skipped
  fixtures.

This can use unique matrix outputs without another external action. Reusing one
shared output name is not sufficient.

### I-P3-01: Make the npm CLI policy explicit across runtime cells

P3 requires lockfile regeneration through “the selected npm version” and says
the selected npm CLI must admit the supported Node runtimes. Its runtime cells
resolve whichever `npm` application accompanies each active Node
installation. Node 22 and Node 24 need not bundle the same npm version.

Recommended correction:

Choose and document one of two coherent models:

1. install/assert one exact npm CLI in every cell and use it for lockfile
   generation, `npm ci`, `npm ls`, audit, lint, and harness execution; or
2. allow one reviewed bundled npm per Node line, designate one exact
   Node/npm pair as the normative lockfile producer, and prove every other
   supported pair installs without rewriting the lockfile.

In either model, record exact Node/npm pairs, validate npm's own Node engine,
and avoid claiming one selected npm if the cells intentionally use several.

### I-P2-01: P2 is substantively ready after prerequisite rebasing

No independent P2 content defect was found. Its replacement visualization,
rationale separation, version advancement, generated-artifact regeneration,
six-file scope, and content checks are proportionate to the documentation
defect.

If P1 is split, P2 must depend on P1B and update its prerequisite snapshot to
include the context manager, both cleanup owners, resource limits, terminal
approval, and final credential policy. Those are prerequisite-reference
changes, not a redesign of P2's content work.

## Consolidated revisions before handoff

### P1 — Make artifact generation byte-deterministic across PowerShell editions and hosts

Preserve P1's H1 and its deterministic byte contract, frontmatter behavior,
four-edition test intent, sole normative action-role table, and immutable
action pins. Narrow the issue to the generator/runtime/action foundation if
C-01 is adopted.

Before handoff:

- apply C-03's destination contract to every final generator write;
- make the P1↔T1 matrix reciprocal and commit-specific;
- keep temporary transport read-only and workflow-inert with respect to final
  branch publication; and
- state the exact merge evidence P1A must consume.

If the issue is not split, incorporate every P1A/P1B item below and divide
acceptance evidence into the same three trust layers.

### P1A — fail-closed candidate validation

Create P1A from P1's current helper and harness sections while preserving their
path-containment, exact-manifest, stream-copy, staged-manifest, and cleanup
contracts.

Before handoff:

- add the retained, declared, and actual byte limits in C-04;
- add the production invocation-context script and independent caller/candidate
  cleanup tests;
- add the explicit-null label cases in I-P1-01;
- change the comparison owner from generic “parallel T1” to exact P1A↔T1A;
  and
- keep the issue workflow-inert so merging validation code alone cannot
  publish bytes.

P1A must name P1's actual merge commit, not a moving branch.

### P1B — verified least-privileged publication

Create P1B from P1's transport, matrix, terminal approval, writer, diagnostic,
and mutation sections. Preserve the exact role-table schema and make it the
sole action inventory.

Before handoff:

- set all checkouts to `persist-credentials: false`;
- implement the four-value snapshot and closed identity grammar from C-05;
- independently regenerate from the expected commit immediately before use;
- define the exact four-cell attestation transport from I-P1B-01;
- make terminal approval run with `always()` and reject every non-success or
  unexpected dependency result;
- expose authentication only for the exact push and clear it in `finally`;
- add sentinel, race, stale-ref/SHA, no-op, event, and failure-diagnostic
  drills; and
- make the P1B↔T1B comparison reciprocal and commit-specific.

P1B must consume exact P1 and P1A merge commits and replace the temporary
publication boundary atomically. Post-deployment duration/storage measurements
should be retained as governance evidence, not used to waive a security cell.

### P2 — Make the non-compliant blank-line example visibly distinct

Preserve P2's H1 and content plan. No new implementation mechanism is needed.
If the split is accepted, replace every P1 prerequisite reference with P1B,
record the actual GitHub blocked-by relationship, and refresh the prerequisite
snapshot to match the merged context/cleanup/resource/writer contracts.

Retain P2's six-file boundary and its requirement to regenerate rather than
manually edit derived artifacts.

### P3 — Remediate Markdown lint dependency advisories and add npm update governance

Preserve P3's H1, complete direct/transitive evaluation, fresh clean runtime
cells, report-v2 graph validation, exact expiry semantics, live public
follow-up issue, owner evidence, immutable action pins, and durable research
link.

Before handoff:

- replace the open-ended lower-bound Node range with C-06's finite reviewed
  set and matching guards/tests;
- adopt one explicit npm model from I-P3-01;
- choose the final packages and regenerate the lockfile using the normative
  Node/npm producer before recording findings;
- if the resulting audit is clean, require no exception file;
- if any residual remains, add C-07's tracked record and permanent CI
  validator and expand the affected-path contract accordingly; and
- distinguish registry/tool failure from a vulnerability-policy result.

### Filing and dependency mechanics

- Preserve the existing three H1 titles verbatim in the final issue bodies.
- Refer to the issues as P1, P1A, P1B, P2, and P3 in planning prose.
- After filing, replace placeholders with actual issue URLs and record P2's
  blocked-by relationship to P1B.
- Replace branch-relative implementation evidence with permanent links to
  exact merge commits.
- Do not make PSStyleGuide consume TerraformStyleGuide runtime code or make
  either repository's implementation depend on the other's release timing.
- Treat the Terraform issues solely as reciprocal comparison evidence at the
  corresponding trust boundary.

## Strengths to preserve

- P1's intentional H1 and its repository-specific artifact/frontmatter names.
- P1's single complete action-role table, including workflow, job, stable step
  identifier, repository, full commit, reviewed version, activation condition,
  and complete non-default inputs.
- P1's explicit omitted-versus-empty diagnostic-label behavior.
- P1's archive-helper path, component, same-stream, exact-manifest, staged
  verification, and cleanup invariants.
- P2's separation of the defective visualization from its explanatory
  rationale and its generated-artifact checks.
- P3's evaluation of the complete installed tree rather than direct
  dependencies alone.
- P3's separate clean runtime cells and complete install/lint/harness
  acceptance work in each cell.
- P3's audit-native `(Package, AdvisoryUrl)` residual identities, separate
  package/node-path sets, graph validation, lockfile resolution, exact UTC
  expiry, and real public follow-up issue checks.
- The slate's use of immutable action SHAs and exact role ownership rather than
  a vague global pinning instruction.

## Primary references

Repository evidence:

- [PSStyleGuide planning commit](https://github.com/franklesniak/PSStyleGuide/commit/f4c9e055b9068fe9fb26f3650320645c3c31f979)
- [PSStyleGuide current `main` anchor](https://github.com/franklesniak/PSStyleGuide/commit/4346310e7deebffb4159c75e30d9546263dfd649)
- [T1](../TerraformStyleGuide/03TerraformStyleGuideT1.md),
  [T1A](../TerraformStyleGuide/03aTerraformStyleGuideT1A.md),
  [T1B](../TerraformStyleGuide/03bTerraformStyleGuideT1B.md),
  [T2](../TerraformStyleGuide/04TerraformStyleGuideT2.md),
  [T3](../TerraformStyleGuide/05TerraformStyleGuideT3.md), and
  [T4](../TerraformStyleGuide/06TerraformStyleGuideT4.md) comparison context

Primary behavior and policy sources:

- [PowerShell unresolved provider path API](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.pathintrinsics.getunresolvedproviderpathfrompspath)
- [GitHub Actions matrix job outputs](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#using-job-outputs-in-a-matrix-job)
- [GitHub secure use reference](https://docs.github.com/en/actions/reference/security/secure-use)
- [Pinned checkout action metadata](https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml)
- [Node.js release status](https://nodejs.org/en/about/previous-releases)
- [`npm audit` report behavior](https://docs.npmjs.com/cli/v11/commands/npm-audit/)
- [`package.json` `engines` semantics](https://docs.npmjs.com/cli/v11/configuring-npm/package-json#engines)
- [GitHub issue dependencies](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/creating-issue-dependencies)
- [GitHub permanent file links](https://docs.github.com/en/repositories/working-with-files/using-files/getting-permanent-links-to-files)
