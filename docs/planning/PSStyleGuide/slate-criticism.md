# Feedback on the PSStyleGuide P1/P2/P3 GitHub issue slate

## Overall assessment

This is a strong and nearly handoff-ready slate. P1, P2, and P3 have distinct
ownership, their P1 → P2 → P3 ordering is coherent, and the supersession
language prevents a later issue from silently undoing an earlier issue's
security or validation contract.

The generator-unification approach is also now appropriately calibrated. P1
and TerraformStyleGuide T1 converge on the same serialization boundary,
BOM-less LF bytes, cross-edition behavior, archive trust model, and public
helper semantics without creating a cross-repository runtime dependency. The
remaining intentional differences—including artifact names, guide-specific
transformations, and the different pull-request helper-harness placement—are
identified rather than hidden. I would preserve that design.

P2 needs no substantive content redesign. It fixes a real defect, keeps the
example portable across unrelated adopters, avoids storing the prohibited
trailing spaces, separates operational guidance from rationale, and requires
the sources and generated artifacts to move together.

I would nevertheless make the targeted corrections below before handing off
the slate. The first affects P1. The next three affect P3. The final item is
filing hygiene across the slate.

## Current-state anchors

These observations were rechecked on 2026-07-29 against PSStyleGuide `main` at
commit
[`4346310e7deebffb4159c75e30d9546263dfd649`](https://github.com/franklesniak/PSStyleGuide/commit/4346310e7deebffb4159c75e30d9546263dfd649):

- `.gitattributes` already contains exactly `* text=auto eol=lf`.
- The generator still has four edition-sensitive `Set-Content -Encoding UTF8`
  writes and a here-string frontmatter source, so P1 addresses live behavior.
- The build and Markdown workflows still have the action, permission, trigger,
  and Node-runtime weaknesses described by P1.
- The two Blank Line Usage examples still have byte-identical empty third
  lines, so P2 addresses a live documentation defect.
- The staged hook and staged-lint script still admit Node 20 or newer.
- A fresh lockfile-only audit still reports seven vulnerable package nodes:
  five high and two moderate.
- The seven reported nodes are `brace-expansion`, `js-yaml`, `linkify-it`,
  `markdown-it`, `markdownlint-cli2`, `minimatch`, and `picomatch`.

The dated P3 baseline therefore remains accurate. Node 22 and Node 24 are
currently LTS releases, while Node 20 is EOL. P3 is right to remove Node 20
from the supported local-tooling contract.

## 1. Make P1's action-role validator as exact as P1 and P2 claim

### Finding

P1's action validator correctly rejects:

- an unknown external action repository;
- an unapproved workflow;
- a non-full-SHA reference;
- a SHA/version-comment mismatch; and
- an extra setup-node occurrence.

It does not, however, prove the claimed exact role inventory.

`$hashtableRequiredOccurrences` contains only workflow/action keys and the
loop rejects a count only when it is *less than* the required minimum.
Consequently, extra approved checkout, upload, or download steps pass. A
required occurrence in the wrong job can also satisfy the count for a missing
intended occurrence because the key contains no job or step role.

There is a related prose contradiction. P1 says not to migrate actions other
than “the two checkout occurrences,” but P1's final workflow topology requires
more than two YAML checkout steps:

1. build pull-request Ubuntu verification;
2. build pull-request Windows matrix;
3. build push preparation;
4. build push Windows matrix;
5. build synchronization; and
6. Markdown lint.

The intended permanent artifact roles likewise appear to be two uploads
(pull-request diagnostics and push candidate) and two downloads (push Windows
consumer and synchronization consumer), plus one Markdown setup-node step.

This matters beyond neatness. An upload step placed in an unintended job can
change the data-exfiltration surface; an extra checkout can change credential
and repository-state behavior; and a missing consumer download can be masked
by a duplicate elsewhere. P2 currently inherits the overstatement by calling
this an “exact allowlist validator.”

### Recommended correction

Define one authoritative role table after final job and step IDs are selected.
Key every expected external action by:

```text
workflow | job ID | stable step ID | action repository
```

For each key, record the exact SHA, adjacent version comment, and any
security-relevant required inputs. Then require exact set equality:

- every expected role occurs exactly once in the workflow YAML;
- no expected role is missing;
- no approved action occurs in an unlisted role;
- no additional external action occurs; and
- the exact role has the expected repository/SHA/version tuple.

At minimum, replace the lower-bound count comparisons with exact counts for
the complete intended inventory and reject every extra occurrence. The
stronger job/step-aware table is preferable because it proves the statement
that an action appears only in its approved role.

Use stable step IDs for the verifier rather than relying only on human-readable
step names. Keep GitHub's real workflow run as syntax/execution evidence; the
static verifier should prove the intended inventory, not attempt to replace
GitHub's workflow parser.

Finally:

- replace “the two checkout occurrences” with the actual final inventory;
- update P1's acceptance language to describe precisely what is mechanically
  proved; and
- refresh P2's prerequisite snapshot after the P1 validator is corrected.

## 2. Make P3 prove the complete supported Node interval

### Finding

P3 aligns `package.json`, `.husky/pre-commit`, and
`lint-staged-markdown.mjs` on a selected minimum and runs the staged harness at
that minimum and at Node 24. That is good, but it does not yet completely prove
the runtime-support claim:

- “highest minimum ... required by the final selected direct dependency tree”
  can be read as considering only direct packages; a transitive package can
  impose the actual floor;
- the copyable validation block performs clean installation and
  `npm ls --all` only while Node 24 is active;
- the selected-minimum instruction reruns the harness, but does not clearly
  require a fresh `npm ci`, `npm ls --all`, both production lint commands, and
  the harness under that minimum;
- the harness does not invoke the complete `.husky/pre-commit` surface;
- no negative case proves that both local guards reject a below-minimum major
  before invoking npm/lint tooling; and
- “if ... releases require a higher minimum, use that higher value” has no
  explicit upper bound, even though P3 simultaneously requires Node 24 to
  remain supported.

### Recommended correction

Define the selected minimum as the highest Node floor in the complete resolved
direct *and transitive* tree, not merely the direct dependency set. Require:

```text
selected minimum <= 24
```

If a candidate requires Node 25 or later, it is incompatible with P3's retained
Node 24 contract. Select another safe candidate, explicitly redesign the
hosted-runtime policy in separately reviewed scope, or disposition the
otherwise unavoidable advisory; do not claim that Node 24 still works.

Run two clean runtime cells when the selected minimum is below 24:

| Runtime | Required evidence |
| --- | --- |
| Selected minimum | Fresh `npm ci`, `npm ls --all`, both production lint commands, and the tracked staged/full-lint harness |
| Node 24 | Fresh `npm ci`, `npm ls --all`, both production lint commands, and the tracked staged/full-lint harness |

If the selected minimum is 24, one clean Node 24 cell can satisfy both roles,
provided the evidence says so explicitly. Retain hosted Node 24 as the
nonoptional gate.

Also add small guard-policy cases:

- the manifest and both guards contain the same selected minimum;
- both guards emit the reviewed stable diagnostic;
- the staged script and hook accept the selected minimum; and
- both reject a synthetic below-minimum major before npm, npx, or Markdown
  tooling can run.

There is no need to execute an EOL Node 20 binary merely to test the rejection.
For the shell hook, a test-owned `node` shim can report a below-minimum version
and an npm/npx sentinel can prove fail-fast behavior. For the JavaScript guard,
factor the version decision into a small pure function that the harness can
exercise with a synthetic version while the production entry point still uses
`process.versions.node`.

## 3. Make P3's residual approval identity match its stated unit of risk

### Finding

P3 says each residual approval identifies one exact
advisory/package/dependency-path combination. The validator does not compare
that tuple.

It:

1. forbids duplicate advisory URLs;
2. confirms that an approval's package/URL pair occurs once in the audit
   advisory records;
3. confirms that the selected dependency path is *one* path returned by
   `npm explain`; and
4. compares the approved and actual residual sets only as unique advisory-URL
   sets.

That permits a missing path disposition to pass. It also prevents representing
the same advisory at two installed paths because a second record with the same
URL is rejected before its package/path can distinguish it. A package-wide
`npm explain <package>` can legitimately return multiple installed instances;
npm's documentation specifically recommends a folder path when an exact
duplicate instance must be explained.

There is an additional provenance issue: the audit's `nodes` field identifies
vulnerable installed/lockfile node locations, whereas the recursive
`npm explain` formatter produces human-readable dependency chains for the
package as a whole. Selecting any one explain chain does not establish that
every audit-reported vulnerable node has a disposition.

### Recommended correction

Choose and document one of these two internally consistent models.

#### Preferred model: audit-native approval identity

- Key each approval by exact `(Package, AdvisoryUrl)`, the pair directly
  established by an object advisory in the audit graph.
- Maintain a separate package-keyed, exact, sorted, nonempty
  `AuditNodePaths` set equal to each vulnerability property's `nodes` value.
  Do not present that package-level set as an advisory-to-node mapping that npm
  did not supply.
- Keep normalized `npm explain` chains as diagnostic/reviewer context, not as
  the identity used for exact residual-set equality.
- Reject duplicate package/URL composite keys rather than duplicate URLs.
- Compare actual and approved composite-key sets exactly.
- Separately require every audit node path to be represented in the recorded
  node-path evidence.

#### Stricter per-node model

- Key each approval by
  `(Package, AdvisoryUrl, AuditNodePath)`.
- Resolve the exact version at each audit node from the lockfile.
- Use semver-correct range evaluation to prove that the advisory applies to
  that node before constructing the actual tuple set.
- Require exact tuple-set equality and reject only duplicate composite keys.
- Use `npm explain <exact-folder-path>` to attach the corresponding readable
  chain.

Do not blindly cross-product every advisory for a package with every node for
that package; different advisory ranges may cover different installed
versions. The preferred model is simpler and stays closest to what the audit
JSON directly proves.

For either model, retain the current fail-closed handling of `npm audit` exit
codes. npm documents that exit 0 means no vulnerability at the configured
threshold and that nonzero behavior depends on `audit-level`; that part of P3
is sound.

Also tighten the associated governance fields:

- Parse `ExpiresUtc` with `DateTimeOffset.TryParseExact`, one documented
  invariant-culture UTC format, and explicit `DateTimeStyles`; checking only a
  trailing `Z` plus culture-sensitive `TryParse` accepts more than the issue
  claims.
- Treat the issue-URL regex as syntax validation only. Either query GitHub's
  “Get an issue” endpoint and require a live public issue in the intended
  repository, or make public reachability and owner acceptance explicit manual
  review evidence. A regex and nonempty `Owner` string cannot prove either
  fact.

## 4. Close P3's audit metadata/graph consistency gap

### Finding

The P3 validator proves that the five metadata severity counts are
nonnegative and sum to `metadata.vulnerabilities.total`. It does not prove that
those counts describe the enumerated `vulnerabilities` object.

In particular, it does not require:

- the number of vulnerability properties to equal metadata `total`;
- each vulnerability node to have a recognized `severity`;
- counts derived from node severities to equal the metadata counts;
- each vulnerability node to have a nonempty, unique `nodes` list;
- audit node paths to resolve to matching lockfile package/version entries; or
- `effects` links to resolve consistently, as it already requires for string
  `via` links.

The validator also silently ignores an object advisory with an unknown or
misspelled severity because it collects only objects whose severity happens to
be moderate, high, or critical. That is not fail-closed schema handling.

### Recommended correction

Before residual disposition:

1. Require every vulnerability property to contain the expected fields and
   recognized shapes used by the selected, recorded npm version.
2. Require node-level severity to be exactly one of `info`, `low`, `moderate`,
   `high`, or `critical`.
3. Derive counts from the vulnerability properties and require exact equality
   with every metadata severity count and `total`.
4. Require each `nodes` list to be nonempty and duplicate-free, normalize its
   paths, and resolve each path to the matching package/version in
   `package-lock.json`.
5. Require every string `via` and every `effects` edge to resolve to a named
   vulnerability node; if reciprocal edge consistency is part of the observed
   npm schema, validate that too.
6. Validate every object advisory's URL, severity, and range; reject unknown
   severities rather than ignoring them.
7. Validate `fixAvailable` only to the shapes P3 actually consumes or records:
   boolean or the reviewed object form.

Preserve the raw audit JSON, selected npm version, and human-readable evidence
as P3 already requires. If a later npm version changes the relied-upon JSON
shape, the check should fail with a schema diagnostic and prompt review rather
than partially accepting the new shape.

## 5. Replace planning-file references when the issues are filed

### Finding

Several references work only while these drafts are read as repository files:

- P2 links to `01PSStyleGuideP1.md` and `03PSStyleGuideP3.md`.
- P1 names the P3 planning path.
- P3 links to
  `../artifacts/prompt-02-primary-source-research.md`.

Those are not durable issue-body references as written. GitHub documents a
different relative form for repository assets referenced from issues and pull
request comments, and the planning artifact may not exist on the eventual
PSStyleGuide default branch at all.

### Recommended correction

At filing time:

- replace P1/P2/P3 planning-path dependencies with the actual filed issue
  numbers and URLs;
- record P2's real blocked-by relationship to P1;
- use the actual P3 issue reference wherever P1 or P2 delegates npm ownership;
  and
- either replace P3's research-record link with an absolute commit permalink
  to a file that reviewers can access, or remove it and rely on the direct
  primary-source references already present in P3.

Do not use a mutable branch link for evidence whose exact historical contents
matter.

## Recommended disposition and sequence

I would give the drafter this concrete direction:

1. **P1:** retain the generator/helper/workflow architecture, but replace the
   minimum-count action check with an exact job/step-role inventory and correct
   the stale “two checkout occurrences” sentence.
2. **P2:** retain the issue substantively as written; after P1 is final, refresh
   its prerequisite summary and replace planning links with actual issue
   references.
3. **P3:** preserve its dependency-review, lint-regression, and two-ecosystem
   Dependabot design, but complete the runtime-floor proof, align residual-set
   equality with the declared approval identity, and validate audit metadata
   against the enumerated graph.
4. **Filing:** convert every cross-issue dependency to a real GitHub
   relationship and every retained research artifact to a durable permalink.

Under the stipulated sequential execution model, P1 → P2 → P3 remains
defensible. Because the repository currently carries known high-severity
findings, P2 should not become a scheduling reason to leave P3 idle for an
extended period; if that risk materializes, advance P3 immediately after P1
and refresh the prerequisite/supersession text deliberately.

## References

- [npm Docs: `npm audit`](https://docs.npmjs.com/cli/v11/commands/npm-audit/)
- [npm Docs: `npm explain`](https://docs.npmjs.com/cli/v11/commands/npm-explain/)
- [Node.js: release status](https://nodejs.org/en/about/previous-releases)
- [Microsoft Learn: `DateTimeOffset.TryParseExact`](https://learn.microsoft.com/dotnet/api/system.datetimeoffset.tryparseexact)
- [GitHub Docs: Get an issue](https://docs.github.com/en/rest/issues/issues#get-an-issue)
- [GitHub Docs: relative links in issues, pull requests, and comments](https://docs.github.com/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#relative-links)
- [GitHub Docs: permanent links to files](https://docs.github.com/repositories/working-with-files/using-files/getting-permanent-links-to-files)
