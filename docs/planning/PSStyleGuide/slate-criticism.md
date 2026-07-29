# Feedback on the revised PSStyleGuide P1/P2/P3 GitHub issue slate

## Overall assessment

P2 is substantively ready, and P3 is much stronger than its earlier draft.
The latest P revisions fixed the previously identified action-role, Node
runtime, audit-graph, residual-identity, expiry-parsing, and durable-link
problems. Those findings should not be carried forward.

P1 is not yet ready to file in its current form. The revised
TerraformStyleGuide slate split its equivalent work into a deterministic
generator foundation (T1), an inert candidate-validator layer (T1A), and final
workflow activation (T1B). PSStyleGuide P1 still combines all three layers in
one 2,900-line issue and now refers to the obsolete, pre-split meaning of “T1.”
More importantly, the newer Terraform issues added security controls that P1
does not contain.

I would preserve the repository-local implementation model. The two
repositories should converge on observable generator, archive, lifecycle,
writer, and validation contracts without acquiring a cross-repository runtime
dependency. The revised Terraform split makes that convergence easier to
review, implement, and prove.

## Current-state anchor

These observations were rechecked on 2026-07-29 against PSStyleGuide `main` at
commit
[`4346310e7deebffb4159c75e30d9546263dfd649`](https://github.com/franklesniak/PSStyleGuide/commit/4346310e7deebffb4159c75e30d9546263dfd649):

- `.gitattributes` already contains exactly `* text=auto eol=lf`.
- The generator still has four edition-sensitive
  `Set-Content -Encoding UTF8` writes and an edition-sensitive frontmatter
  here-string.
- The build and Markdown workflows still use mutable v4 action tags.
- Hosted Markdown validation still selects Node 20.
- The Husky and JavaScript staged-lint guards still admit Node 20 or newer.
- The dated seven-package-node audit baseline in P3 still describes the
  planning baseline that must be recomputed at implementation time.

The proposed issues therefore still address live repository behavior. The
feedback below is about issue architecture and missing acceptance boundaries,
not about removing the work.

## Improvements in the latest P drafts to preserve

The latest edits resolved several earlier material findings:

- P1 now defines one exact job/stable-step action-role inventory, exact
  occurrence equality, complete allowed inputs, and negative fixtures.
- P1 no longer describes an impossible “two checkout occurrences” inventory.
- P3 selects its Node floor from the complete direct/transitive tree and
  requires clean selected-minimum and Node 24 runtime cells.
- P3 exercises the complete Husky hook and includes fail-fast below-minimum
  guard cases.
- P3 uses audit-native `(Package, AdvisoryUrl)` residual identity, preserves
  package-keyed audit-node sets separately, and keeps `npm explain` diagnostic.
- P3 reconciles audit metadata with the enumerated graph and validates node
  paths, `via`/`effects`, advisory shapes, and remediation shapes.
- P3 uses exact invariant UTC expiry parsing, verifies a publicly retrievable
  PSStyleGuide issue that is not a pull request, and records owner acceptance
  separately.
- P3 now uses a durable commit permalink for its research record.

Those corrections are sound and should survive the revisions below.

## 1. Split P1 along the same trust boundaries as T1/T1A/T1B

Severity: High

P1 currently owns all of the following in one issue:

1. generator serialization;
2. frontmatter construction;
3. Node 24 and action pinning;
4. Dependabot’s intermediate GitHub Actions entry;
5. a security-sensitive ZIP validator/extractor;
6. its adversarial harness;
7. artifact upload/download topology;
8. a cross-edition Windows matrix;
9. terminal approval; and
10. the only repository writer.

Its title mentions only deterministic generation, while its acceptance surface
extends through credentialed publication. The implementation cannot review or
merge the validator independently before activating it, and a defect in any
one layer blocks all six files and all evidence.

The revised Terraform issues establish a better sequence:

- [T1](../TerraformStyleGuide/03TerraformStyleGuideT1.md) makes generation
  deterministic and leaves a temporary, explicit publication boundary.
- [T1A](../TerraformStyleGuide/03aTerraformStyleGuideT1A.md) adds the helper,
  caller-context lifecycle, and permanent harness without changing production
  workflow behavior.
- [T1B](../TerraformStyleGuide/03bTerraformStyleGuideT1B.md) activates the
  already merged scripts and replaces temporary publication with the final
  verified writer.

### Recommended correction

Create the analogous PSStyleGuide sequence:

1. **P1:** deterministic serialization/frontmatter, Node 24, action pins,
   one-entry Dependabot state, and a temporary least-privilege publication
   boundary;
2. **P1A:** candidate validator, caller-context lifecycle, and permanent
   harness, with no production workflow activation; and
3. **P1B:** final immutable candidate, matrices, approval, and exact-lease
   writer.

Keep the existing H1 title convention in every issue. Record actual GitHub
blocked-by relationships and exact prerequisite merge commits.

P2 should depend on P1B, not merely the generator foundation, because its
generated-artifact change relies on the final publication path. P3’s default
order may remain after P2, subject to its existing vulnerability-policy gate.

If the drafter deliberately keeps one P1, the issue should explain why the
cross-repository trust boundaries differ and supply an equally reviewable
staged activation plan. File count alone is not a sufficient rationale.

## 2. Replace P1’s stale “parallel T1” comparisons

Severity: High

P1’s generator matrix still treats “T1” as the complete Terraform generator,
helper, transport, matrix, and writer issue. That is no longer true:

- generator convergence belongs to Terraform T1;
- helper/context/harness convergence belongs to T1A; and
- workflow/writer convergence belongs to T1B.

The stale text hides material differences by referring to one old comparison
point. For example, it says the candidate parameter contract is P1/T1, but the
current contract is in T1A. It also has no reciprocal writer matrix matching
T1B’s credential, identity, diagnostics, and at-use validation requirements.

### Recommended correction

Define three reciprocal matrices:

| PS layer | Terraform comparison | Required comparison evidence |
| --- | --- | --- |
| P1 | T1 | payloads, path resolution, encoding, bytes, Node/action baseline |
| P1A | T1A | public parameters, limits, context, both cleanups, cases, editions |
| P1B | T1B | transport, roles, matrices, approval, writer identity/credentials |

The implementation that starts second should consume the other repository’s
exact merge commit and record every status as `same`, `intentional difference`,
or `blocker`. An unexplained security or observable failure difference should
block merge.

Update P2’s prerequisite snapshot and P3’s enduring/non-goal inventory to name
all final PS scripts and layers. Do not leave P2 coupled to the current
two-script P1 inventory if a caller-context script is added.

## 3. Make the generator destination-path contract actually converge

Severity: Medium to high

P1 requires each writer to call
`GetUnresolvedProviderPathFromPSPath`, but its prescribed pattern does not
explicitly:

- reject wildcard-bearing inputs;
- reject non-filesystem providers;
- reject ambiguous/multiple resolutions;
- require one unambiguous filesystem path; or
- retain the destination in the failure diagnostic.

Terraform T1 now requires all of those controls at every final write site. This
is part of generator unification, not a repository-specific content
difference.

### Recommended correction

Adopt T1’s exact path contract for each P1 write:

1. reject wildcard, non-filesystem-provider, and multiple-resolution inputs;
2. obtain exactly one unresolved filesystem provider path;
3. normalize the complete payload;
4. write once with explicit `UTF8Encoding($false)` and `WriteAllText`; and
5. report the captured destination if serialization fails.

Retain PSStyleGuide’s intentional frontmatter replacement and artifact names.
The shared target is the serialization/path/failure boundary, not identical
source text.

## 4. Add T1A’s resource limits and reusable caller-context lifecycle

Severity: High

P1’s ZIP helper validates an exact four-file manifest and extracts fresh
ordinary files, but it sets no maximum for:

- retained archive bytes;
- declared uncompressed bytes per entry;
- declared total uncompressed bytes; or
- actual copied bytes.

An exact entry count does not bound a compression bomb or an untruthful entry
length. T1A now caps the archive at 32 MiB, each entry at 8 MiB, the total
declared output at 32 MiB, and the actual copied output at the same limits.

P1 also duplicates trusted-root acquisition and teardown behavior in workflow
consumers and the harness. T1A instead adds
`Manage-StyleGuideCandidateInvocationContext.ps1` with exact
`New-StyleGuideCandidateInvocationContext` and
`Remove-StyleGuideCandidateInvocationContext` functions. This gives both
repositories one reusable owner for collision-only creation and nonrecursive,
fail-closed caller teardown, separate from the candidate helper’s own cleanup.

### Recommended correction

- Add the same finite declared/actual archive limits unless measured
  PSStyleGuide artifacts require a separately justified value.
- Add the caller-context script with the same public function names and
  meanings.
- Make the helper remain independently distrustful of the context.
- Exercise both production cleanup lifecycles in the permanent harness.
- Require every production consumer to use the context functions rather than
  copy their algorithms into workflow YAML.
- Preserve uncertain state and the primary failure if either cleanup cannot
  prove exact ownership.

Artifact filenames and fixture placement may differ. Resource exhaustion,
ownership, and cleanup behavior should not.

## 5. Bring P1’s writer up to T1B’s credential and identity boundary

Severity: High

P1’s normative action-role table deliberately gives the synchronization
checkout `persist-credentials: true`. The reviewed checkout action documents
that this configures its token in local Git configuration until post-job
cleanup. T1B instead disables persisted credentials on every checkout and
expands one environment-backed HTTP authorization value only for the exact
push.

P1 also:

- snapshots only `TARGET_REF` and `EXPECTED_SHA` at the start, then reads
  `GITHUB_REF` and `GITHUB_SHA` later;
- does not explicitly reject NUL and other control characters in all four
  identity inputs;
- says the writer must never regenerate, while T1B regenerates from the exact
  expected commit in a separate controlled location and compares bytes;
- does not require terminal approval to inspect and reject every failed or
  unexpectedly skipped dependency; and
- lacks T1B’s explicit token-sentinel, bounded diagnostic-retention, and
  measured-CI-cost evidence.

These are security and failure-observability differences, not guide-specific
values.

### Recommended correction

Adopt T1B’s writer boundary:

1. use `persist-credentials: false` everywhere;
2. snapshot `TARGET_REF`, `EXPECTED_SHA`, `GITHUB_REF`, and `GITHUB_SHA` in the
   first executable statements and never reread them;
3. reject empty, whitespace-mutated, CR/LF, NUL, control, malformed-ref, and
   malformed-object inputs before mutation or credential expansion;
4. revalidate the exact artifact/helper/harness and independently regenerate
   from the expected commit before copying;
5. make terminal approval inspect the complete dependency result set,
   including unexpected skips;
6. expose the token only through one process-scoped environment-backed Git HTTP
   authorization configuration for the exact push, then restore/remove it in
   `finally`;
7. prove with sentinels that the token never enters logs, command records,
   files, or artifacts; and
8. bound failure-only diagnostics and record matrix cost without silently
   deleting a security cell.

Update the exact action-role inventory atomically. The final writer checkout
must then require `persist-credentials: false`, not `true`.

## 6. P3’s Node policy still admits unreviewed future and non-LTS majors

Severity: Medium to high

P3 now says its evidence does not claim every intervening, EOL, or future major
has been tested. Its required policy nevertheless sets:

```text
engines.node = >=<selected minimum>
```

and aligns both local guards to the same minimum-only decision. If the selected
minimum is 22, that contract admits Node 23, 25, 26, and every future major.
That contradicts the stated support boundary and the requirement to select a
supported LTS line.

Terraform T3 correctly requires a bounded range and rejects unreviewed future
majors.

### Recommended correction

Define one bounded set of reviewed Node major lines and use it consistently in:

- `package.json`;
- `.husky/pre-commit`;
- `lint-staged-markdown.mjs`; and
- the tracked harness.

For example, if only Node 22 and 24 are supported, choose an exact semver union
that admits those major lines without admitting 23, 25, or future majors. The
implementation should derive the final syntax from the reviewed package tree;
the issue need not hard-code a range before selection.

Add stable cases for:

- each supported major;
- one below-minimum major;
- an intervening unsupported major; and
- an above-maximum/future major.

Keep the current clean selected-minimum and Node 24 runtime cells.

## 7. Make residual P3 audit approvals durable and continuously enforced

Severity: High when any residual exists

P3’s audit-native validation is strong, but its
`$arrApprovedResiduals` and `$arrRecordedAuditNodes` records exist only in a
copyable implementation-time validation block. They are not part of the
seven-file repository state, and `markdownlint.yml` runs only the lint
regression harness.

If a residual is approved, nothing in the merged repository automatically
fails when:

- the approval expires;
- the audit graph changes;
- a node path appears or disappears;
- the advisory is fixed but the stale approval remains; or
- a new moderate/high/critical advisory is introduced.

T3 has the right lifecycle idea: no exception file for a clean result, but a
structured tracked exception file plus CI validation when a residual exists.
P3’s audit-native `(Package, AdvisoryUrl)` identity and separate package-keyed
node sets are more precise than blindly cross-producting advisory URLs and
paths, so that P3 model should be retained.

### Recommended correction

Conditionally add a tracked structured exception file only when the final audit
has a residual. Add a permanent validator that:

- reproduces P3’s reviewed report-version/schema checks;
- requires exact current residual-key equality;
- requires exact package-keyed audit-node-set equality;
- validates owner acceptance, public follow-up, and exact UTC expiry;
- fails after expiry or topology drift; and
- rejects an exception file when the audit is clean.

Invoke it in hosted Markdown CI after clean installation. Compute the final P3
changed/staged set after the audit result is known instead of permanently
requiring exactly seven paths.

## P2 disposition

P2 needs no substantive content redesign. It fixes a live documentation defect,
keeps the visible substitute explicitly non-copyable, separates operational
guidance from rationale, advances metadata, and regenerates all dependent
artifacts.

After the P1 split and contracts are final:

- make P2 depend on P1B’s actual issue and exact merge commit;
- refresh its prerequisite snapshot to include the context lifecycle and both
  cleanup owners;
- replace title-only draft references with actual filed issue URLs; and
- retain P2’s six-file source/generated scope and Node 24 lint evidence.

## Recommended final slate

1. **P1:** deterministic generator/Node/action foundation.
2. **P1A:** inert candidate validator, caller context, and adversarial harness.
3. **P1B:** immutable transport, matrices, approval, and least-privilege writer.
4. **P2:** blank-line visualization and regenerated documentation artifacts.
5. **P3:** dependency/runtime/hook/audit governance, subject to the existing
   policy gate that may move it earlier.

Before filing, update every cross-repository comparison to the exact
T1/T1A/T1B layer, use real GitHub dependencies, and replace planning references
with actual issue URLs or immutable commit permalinks.

With those corrections, the two repositories can share a genuinely coherent
generator and artifact-security design while remaining independently
implementable.

## References

- [PSStyleGuide reviewed commit](https://github.com/franklesniak/PSStyleGuide/commit/4346310e7deebffb4159c75e30d9546263dfd649)
- [TerraformStyleGuide T1](../TerraformStyleGuide/03TerraformStyleGuideT1.md)
- [TerraformStyleGuide T1A](../TerraformStyleGuide/03aTerraformStyleGuideT1A.md)
- [TerraformStyleGuide T1B](../TerraformStyleGuide/03bTerraformStyleGuideT1B.md)
- [TerraformStyleGuide T3](../TerraformStyleGuide/05TerraformStyleGuideT3.md)
- [Pinned checkout action metadata](https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml)
- [Pinned upload-artifact action metadata](https://raw.githubusercontent.com/actions/upload-artifact/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a/action.yml)
- [Pinned download-artifact action metadata](https://raw.githubusercontent.com/actions/download-artifact/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/action.yml)
- [npm `package.json` engines](https://docs.npmjs.com/cli/v11/configuring-npm/package-json/#engines)
- [npm audit](https://docs.npmjs.com/cli/v11/commands/npm-audit/)
- [Node.js release status](https://nodejs.org/en/about/previous-releases)
