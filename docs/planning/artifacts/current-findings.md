# Review of the PSStyleGuide P1/P2/P3 GitHub issue slate

## Overall assessment

The revised slate is strong, internally coherent, and close to handoff-ready.
P1, P2, and P3 have distinct ownership, the stipulated P1 → P2 → P3 sequence
is explicit, and P3 carefully states which earlier restrictions it supersedes.
The H1 title convention is clear and should remain unchanged.

P1's generator-unification strategy is also appropriate. P1 and
TerraformStyleGuide T1 converge on observable serialization behavior, byte
encoding, cross-edition evidence, archive trust boundaries, and public helper
semantics while keeping each repository self-contained. The drafts identify
intentional content and harness-placement differences rather than claiming
line-for-line identity. A shared package, module, submodule, or reusable action
would add versioning and coordinated-rollout risks that neither issue needs.
Preserve the current behavioral-convergence approach.

P2 needs no substantive redesign. Its source and generated-artifact contract is
clear, the replacement example is portable, and its validation is proportionate
to the documentation defect.

Before filing, I recommend targeted corrections in P1 and P3 plus filing-time
link cleanup:

- **P1 exact action-role validator — valid:** replace workflow/action minimum
  counts with one exact job/step-role inventory.
- **P3 Node support proof — valid with qualification:** validate the complete
  resolved tree and both required runtime cells, but define the supported
  runtime set precisely.
- **P3 residual approval identity — valid:** prefer exact
  `(Package, AdvisoryUrl)` approval keys, separate package-level audit node
  evidence, and exact composite-set equality.
- **P3 audit graph consistency — valid:** reconcile metadata with the
  enumerated graph and fail closed on every consumed JSON shape.
- **Filing-time references — valid:** replace planning links with filed issue
  relationships and immutable evidence links.
- **Suggested P1 → P3 → P2 fallback — denied as written:** retain the
  user-stipulated P1 → P2 → P3 order; use P3's existing policy-driven
  rebaseline procedure only if an actual policy requires it.

## Review basis

This review considered:

- P1: `docs/planning/PSStyleGuide/01PSStyleGuideP1.md`;
- P2: `docs/planning/PSStyleGuide/02PSStyleGuideP2.md`;
- P3: `docs/planning/PSStyleGuide/03PSStyleGuideP3.md`;
- every recommendation in
  `docs/planning/PSStyleGuide/slate-criticism.md`;
- the PSStyleGuide working tree and current workflows;
- PSStyleGuide `main` at
  [`4346310e7deebffb4159c75e30d9546263dfd649`](https://github.com/franklesniak/PSStyleGuide/commit/4346310e7deebffb4159c75e30d9546263dfd649);
- a fresh lockfile-only audit on 2026-07-29; and
- the P1/T1 convergence sections for cross-repository context only. T1 and T2
  were not critiqued.

The live baseline still supports the slate:

- `.gitattributes` contains the intended LF rule.
- The generator still has four edition-sensitive artifact writes and the
  PowerShell-specific here-string frontmatter construction.
- The existing build and Markdown workflows still have the weaknesses P1
  addresses.
- P2's compliant and noncompliant blank-line examples still contain the same
  empty third line.
- The staged hook and staged-lint script still admit Node 20.
- The current audit still reports seven vulnerable package properties: five
  high and two moderate.
- Those seven package properties currently contain fourteen object advisories.
  “Vulnerable package node” and “object advisory” are therefore different
  counting units and must not be used interchangeably.

The schema spot-check used Node 26.5.0 and npm 11.7.0 only to inspect the current
audit response. It is not evidence for P3's required Node 22/24 runtime cells.

## Supplied-criticism audit

### C-01: Make P1's action-role validator exact

**Verdict: Valid.**

P1's current verifier correctly rejects an unknown external action repository,
an action in an unapproved workflow, a non-full-SHA reference, and a
SHA/version-comment mismatch. It also separately requires exactly one
`setup-node` occurrence in `markdownlint.yml`.

It does not prove P1's final action-role topology. Its observed-count key is
only:

```text
workflow | action repository
```

Most required counts are lower bounds. An extra approved checkout, upload, or
download therefore passes. An approved action in the wrong job can also mask a
missing intended role elsewhere in that workflow.

The stale “two checkout occurrences” sentence is also a real contradiction.
P1's proposed static YAML topology contains six checkout roles across the two
workflows:

1. build pull-request Ubuntu verification;
2. build pull-request Windows matrix;
3. build push preparation;
4. build push Windows matrix;
5. build synchronization; and
6. Markdown lint.

The intended static artifact roles are two uploads and two downloads, plus one
Markdown `setup-node` role. A matrix action is one YAML role even though GitHub
executes it once per matrix cell; the validator should not confuse static role
count with runtime invocation count.

The recommended role key is appropriate:

```text
workflow | job ID | stable step ID | action repository
```

For each role, the authoritative table should contain the exact SHA, adjacent
release comment, and security-relevant required inputs. Examples include the
checkout ref/credential behavior, upload name/path/archive behavior, download
artifact ID/path/decompression/digest behavior, and setup-node version/cache
behavior. Require exact set equality: every expected role exists once, no
expected role is missing, and no unlisted external action role exists.

Stable step IDs are better evidence than human-readable names. The verifier
must, however, associate `uses` and `with` values with their containing job and
step structurally. Merely extending the current line regex with nearby text
would create another false-exact check. GitHub's actual workflow run remains the
syntax and execution authority; the static check proves the intended inventory.

Required P1/P2 edits:

- replace the minimum-count map with the exact role table;
- replace “the two checkout occurrences” with the actual final inventory;
- make P1 acceptance language state exactly what the verifier proves; and
- refresh P2's prerequisite snapshot after the P1 contract is final.

### C-02: Make P3 prove its Node support contract

**Verdict: Valid in purpose, with a necessary semantic qualification.**

The supplied criticism identifies real gaps:

- P3 says “final selected direct dependency tree,” which can be read as
  excluding transitive packages.
- The copyable block performs clean installation, `npm ls --all`, both full
  lints, and the harness only while Node 24 is active.
- The selected-minimum instruction reruns only the harness.
- The harness exercises the production staged JavaScript entry point but not
  the complete `.husky/pre-commit` surface.
- No negative case proves that both guards fail before npm, npx, or lint
  tooling starts.
- P3 allows a higher selected minimum without explicitly rejecting a candidate
  whose minimum exceeds the retained Node 24 runtime.

P3 should require the complete resolved direct and transitive dependency graph,
plus the selected npm CLI, to admit both required runtimes. If the selected
minimum is less than 24, use two independently clean cells:

- **Selected minimum:** fresh `npm ci`, `npm ls --all`, both production lint
  commands, and the tracked staged/full-lint harness.
- **Node 24:** fresh `npm ci`, `npm ls --all`, both production lint commands,
  and the tracked staged/full-lint harness.

If the selected minimum is 24, one clean Node 24 cell may satisfy both roles.
Hosted Node 24 remains mandatory. A candidate that cannot run on Node 24 is
incompatible with P3 unless a separately reviewed issue changes that hosted
runtime contract.

The current copyable block cannot simply be rerun at the selected minimum
because it hard-codes a Node 24 assertion. Split reusable runtime-cell
validation from the Node-24-specific hosted assertion so each cell proves its
own runtime explicitly.

Add guard-policy cases that prove:

- `package.json`, `.husky/pre-commit`, and
  `lint-staged-markdown.mjs` contain the same reviewed minimum;
- both production guards accept the selected minimum;
- both emit stable reviewed diagnostics for a synthetic below-minimum version;
- rejection occurs before npm, npx, or Markdown tooling can run; and
- the complete hook still reaches the production staged script on an accepted
  runtime.

A test-owned `node` shim and npm/npx sentinels are suitable for the shell hook.
A pure version-decision function is suitable for the JavaScript entry point.
There is no need to execute EOL Node 20.

The phrase “complete supported Node interval” is too strong, however. Node 22
and Node 24 are LTS, while intervening Node 23 is EOL. Two endpoint runs do not
prove every integer major, and `engines.node: >=22` also admits untested future
majors. P3 should distinguish:

- the declared minimum;
- the explicitly validated runtime majors; and
- any intentionally bounded compatibility range.

Likewise, “highest minimum major” is not sufficient for arbitrary disjunctive
or bounded engine ranges. Inspect the semver intersection of every resolved
package's Node constraint and prove that the selected minimum and Node 24 are
members. Do not claim more runtime coverage than was actually reviewed and
executed.

### C-03: Align P3 residual approval identity with the audited risk

**Verdict: Valid.**

P3's prose promises one exact advisory/package/path disposition, but the
validator compares only unique advisory URL sets. It rejects a second use of
the same URL, verifies a package/URL pair, and then accepts any one normalized
`npm explain` path for the package. That cannot prove complete path coverage and
cannot represent the same advisory at two installed paths.

The provenance distinction in the criticism is correct:

- audit `nodes` identifies installed/lockfile node locations associated with a
  vulnerable package property; and
- `npm explain` gives dependency-chain explanations, potentially for several
  installed instances.

The current audit happens to contain one node path for each vulnerable package,
but the validator must not assume that future trees do.

Use the preferred audit-native model:

- approval identity is exact `(Package, AdvisoryUrl)`;
- duplicate rejection and exact residual equality use that composite key, not
  URL alone;
- a separate package-keyed `AuditNodePaths` record is exact, sorted, nonempty,
  and equal to the vulnerability property's `nodes` set;
- `npm explain` chains remain reviewer context rather than approval identity;
  and
- the evidence must not claim that npm mapped each advisory object to each node
  when the audit response supplied only package-level `nodes`.

The stricter per-node alternative is valid only if P3 also resolves every
node's installed version and applies the advisory range with semver-correct
logic. Blindly cross-producting advisory objects and node paths would create
unsupported tuples. The preferred model is simpler and better matched to the
actual audit data.

The associated governance corrections are also valid:

- parse `ExpiresUtc` with one documented invariant
  `DateTimeOffset.TryParseExact` format and explicit UTC styles;
- restrict the follow-up URL to the intended PSStyleGuide repository;
- treat a regex as syntax validation only;
- require API or manual evidence that the target is a live public issue rather
  than a pull request or missing/private item; and
- treat owner acceptance as explicit review evidence, because a nonempty
  `Owner` string cannot prove acceptance.

P3's fail-closed audit command handling should remain. npm documents exit 0
when no vulnerability meets the configured failure condition and nonzero
behavior governed by `audit-level`.

### C-04: Reconcile P3 audit metadata with the graph

**Verdict: Valid.**

P3 currently proves only that five nonnegative metadata severity values sum to
`metadata.vulnerabilities.total`. It does not prove that those values describe
the enumerated `vulnerabilities` object.

The current npm 11 audit response supports the proposed consistency checks:

- it has `auditReportVersion: 2`;
- seven vulnerability properties equal metadata total seven;
- property-level severities derive the reported five-high/two-moderate counts;
- every property has one nonempty `nodes` path in this particular tree;
- string `via` links resolve to named vulnerability properties;
- current `effects` edges are reciprocal with the corresponding string `via`
  relationships; and
- `fixAvailable` appears as either a Boolean or an object with package,
  version, and semver-major information.

Before residual comparison, P3 should validate the selected npm response
fail-closed:

1. require the reviewed audit report version and every field/shape the
   validator consumes;
2. require each property value's `name` to match its property key;
3. require property severity to be one of the five recognized values;
4. derive property-severity counts and compare each count and total exactly
   with metadata;
5. require `via`, `effects`, and `nodes` to have their reviewed array shapes;
6. require each normalized node path to be nonempty, unique, and resolvable to
   the matching package/version in `package-lock.json`;
7. require every string `via` and `effects` target to name a vulnerability
   property;
8. validate reciprocal `via`/`effects` consistency only as part of the
   explicitly observed and recorded npm schema;
9. validate every object advisory's canonical URL, recognized severity, and
   nonempty vulnerable range, including low/info objects even when only
   moderate-or-higher findings require disposition; and
10. accept `fixAvailable` only as a Boolean or the fully validated reviewed
    object form.

An advisory object's severity and its containing vulnerability property's
aggregate severity are separate fields; derive metadata counts from the
properties, not from the advisory-object list.

npm does not promise an immutable full JSON schema in the user-facing audit
documentation. P3 is therefore right to preserve the exact npm version and raw
JSON. The validator should issue a clear schema diagnostic if a later npm
version changes a relied-upon shape, not silently skip unfamiliar data.

### C-05: Replace planning-file references when issues are filed

**Verdict: Valid.**

The current relative paths work in repository Markdown files, but they are not
durable issue-body relationships:

- P2 links directly to the local P1 and P3 planning files.
- P1 names the local P3 planning path.
- P3 links to a local planning research artifact that may not be on the final
  default branch.

Keep those links while the documents are drafts if useful. At filing time:

- replace dependency prose with the real filed issue numbers and URLs;
- record P2 as blocked by P1 and P3 as blocked by P2 using GitHub's actual
  relationship;
- replace every P1/P2 npm-ownership delegation with the real P3 reference;
- use an absolute commit permalink for retained historical research evidence,
  or remove that planning link and retain the direct primary sources; and
- never use a mutable branch URL for evidence whose historical content matters.

The same durability principle should apply to P1's implementation-time
cross-repository comparison: record the exact T1 issue, pull request, merged
commit, or immutable evidence inspected. This strengthens P1's convergence
record without critiquing T1 or creating a cross-repository dependency.

### C-06: Advance P3 immediately after P1 if P2 delays

**Verdict: Denied as written.**

This recommendation appears in the supplied criticism's closing sequence rather
than one of its five numbered headings, but it is still a recommendation and
needs an explicit disposition.

The user stipulated sequential P1 → P2 → P3 execution. The current slate is
designed around that order: P2 commits its source/generated-artifact change
against P1's known lint baseline, then P3 updates the dependency surface and
revalidates the unchanged documentation corpus. P1 → P3 → P2 would be a third
order that the current prerequisite and supersession text does not model.

P3 already contains the correct exception. At filing and implementation time,
check the actual repository/organization vulnerability policy. If that policy
forbids carrying the findings through P1 and P2, make the complete P3 work the
real prerequisite and rebaseline P1/P2 after it merges. Do not reorder for a
hypothetical delay or invent P1 → P3 → P2 informally.

Operational urgency is a valid project-management concern, but it does not
justify changing the requested sequence in this slate review.

## Independent findings

### I-P3-01: Separate vulnerable-package counts from advisory counts

The current audit contains seven vulnerability properties but fourteen object
advisories. P3 correctly records both categories, yet its baseline table shows
only the seven property-level severity counts. Add one sentence to the
implementation-time evidence contract making the units explicit:

```text
metadata total and severity counts describe vulnerable package properties;
object advisory records are counted and compared separately.
```

This prevents a reviewer from expecting seven approval records or treating
fourteen advisory objects as a metadata mismatch. Under the preferred approval
model, residual equality is the exact set of distinct
`(Package, AdvisoryUrl)` keys, while metadata equality remains property-based.

### I-P3-02: Define support as a set, not an accidentally unbounded claim

P3's current exact `engines.node` form, `>=<selected minimum>`, is a lower-bound
declaration. It does not cap compatibility at Node 24, and it does not prove all
future majors. Conversely, testing only selected-minimum and Node 24 does not
establish support for every major numerically between or above them.

The issue should explicitly say whether `engines.node` is:

- only the minimum accepted local-tooling contract, with test evidence limited
  to named majors; or
- a bounded support range, in which case the range and every claimed supported
  major require deliberate evidence.

For this repository, the cleanest contract is likely “minimum floor plus named
validated LTS majors,” not “continuous interval.” That preserves conventional
`engines.node` behavior without overstating test coverage.

### I-P1-01: Make the action inventory the single source of truth

Once P1 adds the role-aware table, derive all exact action checks from it rather
than retaining a separate approved-repository table, minimum-count map, and
one-off setup-node count. Multiple normative inventories would recreate the
drift that produced the stale checkout sentence.

The same table can drive:

- expected role-set equality;
- SHA/comment validation;
- workflow/job/step placement;
- required security-sensitive inputs; and
- readable mismatch diagnostics.

### I-XR-01: Preserve behavioral convergence, then compare implementations

The P1/T1 unification strategy is mature enough for parallel implementation.
Both sides define the same final serialization boundary, BOM-less UTF-8/LF
bytes, PowerShell edition coverage, root/path/archive trust model, and helper
interface while retaining repository-specific artifact names and guide
transformations.

The important remaining implementation discipline is already present:

- whichever implementation starts second compares against current merged
  behavior, not only an older draft;
- every difference is classified as content-specific, deliberately accepted,
  or a defect/follow-up;
- the comparison includes failure behavior and diagnostics, not just happy-path
  bytes; and
- no runtime or merge-order dependency is introduced.

No new cross-repository abstraction should be added to P1. After P1 and T1 have
both produced evidence, a separately scoped proposal can decide whether the
remaining implementations are stable enough to justify shared code.

## Consolidated revisions before handoff

### P1

- Replace the current action occurrence checks with one exact
  workflow/job/step/action role table.
- Validate role-specific required inputs as well as repository/SHA/comment.
- Correct the stale checkout-count sentence and make acceptance language match
  the mechanical proof.
- Keep the H1 title and generator/helper/workflow architecture unchanged.
- Preserve the current P1/T1 behavioral-convergence matrices and
  implementation-time comparison.

### P2

- Make no substantive content change.
- After P1 is final, refresh the prerequisite snapshot so it describes the
  corrected action validator accurately.
- At filing, replace local P1/P3 links with real issue references and record the
  P1 blocked-by relationship.

### P3

- Evaluate Node constraints across the complete resolved tree with semver
  semantics, require Node 24 compatibility, and define exactly which runtimes
  are claimed.
- Run a fresh complete validation cell at the selected minimum and Node 24 when
  they differ.
- Test both guards and the complete hook, including fail-fast below-minimum
  behavior.
- Replace URL-only residual equality with exact
  `(Package, AdvisoryUrl)` equality and separate exact audit-node evidence.
- Reconcile metadata counts with the vulnerability properties and validate all
  consumed audit graph shapes.
- Preserve the exact npm version, raw audit JSON, and direct primary-source
  references.
- Keep P3 after P2 unless an actual policy triggers P3's documented
  prerequisite/rebaseline exception.

### Filing

- Preserve the intentional H1 titles in all three issue bodies.
- Refer to the issues consistently as P1, P2, and P3.
- Convert all planning-path dependencies to actual issue relationships.
- Use immutable commit permalinks for historical repository evidence.

## Strengths to preserve

- Clear P1/P2/P3 ownership and explicit supersession boundaries.
- P1's deterministic serialization boundary and byte-level evidence.
- P1's self-contained, behavior-first P1/T1 convergence strategy.
- P1's explicit archive identity, root containment, candidate lifecycle, and
  cleanup contracts.
- P2's compact, portable documentation correction.
- P3's deliberate dependency review instead of unreviewed `audit fix --force`.
- P3's tracked positive and negative full/staged lint harness.
- Review-only Dependabot governance for both GitHub Actions and npm.
- Exact changed-path controls and preservation of nonsuperseded earlier
  acceptance criteria.

## Primary references

- [PSStyleGuide verified baseline commit](https://github.com/franklesniak/PSStyleGuide/commit/4346310e7deebffb4159c75e30d9546263dfd649)
- [npm: `npm audit`](https://docs.npmjs.com/cli/v11/commands/npm-audit/)
- [npm: `npm explain`](https://docs.npmjs.com/cli/v11/commands/npm-explain/)
- [npm: `package-lock.json`](https://docs.npmjs.com/cli/v11/configuring-npm/package-lock-json/)
- [Node.js release status](https://nodejs.org/en/about/previous-releases)
- [Microsoft Learn: `DateTimeOffset.TryParseExact`](https://learn.microsoft.com/dotnet/api/system.datetimeoffset.tryparseexact)
- [GitHub Docs: Get an issue](https://docs.github.com/en/rest/issues/issues#get-an-issue)
- [GitHub Docs: relative links](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#relative-links)
- [GitHub Docs: permanent links to files](https://docs.github.com/en/repositories/working-with-files/using-files/getting-permanent-links-to-files)
