# Evaluation of open PSStyleGuide issue-slate findings

## Scope and method

This evaluation covers every finding section in
`docs/planning/artifacts/current-findings.md` that affects the PSStyleGuide P1,
P2, or P3 issue slate. It also records explicit no-change dispositions for the
denied scheduling proposal and the cross-repository convergence finding so no
finding is silently skipped.

The prompt names `02PSStyleGuideP3.md`; the repository's actual P3 draft is
`docs/planning/PSStyleGuide/03PSStyleGuideP3.md`. This evaluation and the later
revision use that existing P3 file.

Findings are evaluated in this order:

1. C-01 — P1 action-role exactness.
2. C-02 — P3 Node support proof.
3. C-03 — P3 residual approval identity.
4. C-04 — P3 audit metadata/graph consistency.
5. C-05 — filing-time reference durability.
6. C-06 — proposed P1 → P3 → P2 fallback.
7. I-P3-01 — vulnerable-package versus advisory counts.
8. I-P3-02 — runtime support set versus unbounded claims.
9. I-P1-01 — one source of truth for the P1 action inventory.
10. I-XR-01 — preserve behavioral P1/T1 convergence.

Each section enumerates options, defines a finding-specific weighted rubric,
scores the options, and gives a cold-reader implementation decision. Scores use
a 1–5 scale, where 5 is best. Weighted totals are out of 100.

## C-01 — Make P1's action-role validator exact

### Options

#### Option A — Exact workflow/repository counts only

Keep the current line scanner, replace every lower-bound comparison with an
exact count, and enumerate the final count for each action repository in each
workflow. Correct the stale checkout sentence.

This closes the extra-occurrence defect but still cannot prove that a counted
action occurs in the intended job or step. A duplicate in one build job can
still mask an absent role in another build job.

#### Option B — One role table plus a fail-closed structural scanner

Define one normative table keyed by:

```text
workflow | job ID | stable step ID | action repository
```

Give every external-action step a stable `id`. For each table row, record its
exact SHA, adjacent version comment, and security-relevant `with` values.
Replace all independent allowlists/count maps with a scanner that tracks the
current workflow, job, and step by indentation, recognizes only P1's approved
ordinary block form, and fails if it encounters aliases, folded/multiline
action values, reusable-job `uses`, duplicate IDs, or another form it cannot
classify exactly. Compare observed and expected role keys as exact sets.

Continue to use actual GitHub workflow runs for authoritative YAML parsing and
execution. The local scanner proves the repository-specific policy.

#### Option C — One role table plus a general YAML parser

Use the same authoritative table as Option B, but load each workflow with a
standards-aware YAML library and walk the parsed jobs/steps tree. This gives the
strongest general YAML handling.

Permutations include adding a direct Node YAML dependency, requiring a
PowerShell YAML module, vendoring a parser, or downloading a pinned tool. Each
adds a dependency or bootstrap surface to P1, conflicts with P1's package-file
exclusion, or complicates Windows PowerShell 5.1 support.

#### Option D — External workflow linter plus a custom policy check

Run a pinned `actionlint`-class tool for syntax and expression checks, then use
a smaller role-table policy validator for exact repository placement and
inputs. This improves syntax diagnostics but still needs custom policy logic
and introduces another executable with provenance, update, and platform
management requirements.

#### Option E — Generate workflows from a machine-readable manifest

Make the role table the source for generated workflow YAML, then verify that
the checked-in workflows equal generated output. This can make role drift
impossible, but it turns P1 into a workflow-generation project and makes manual
workflow review and emergency editing harder.

#### Option F — Rely on GitHub runs and manual review

Remove the exact static claim and retain only full-SHA scanning, actual workflow
runs, and reviewer inspection of job placement. This minimizes code but gives
the weakest repeatable proof and does not satisfy P1/P2's stated exactness.

### Evaluation rubric

The rubric is specific to external-action policy enforcement:

- **Security exactness (SE), 30%:** detects missing, extra, misplaced, or
  input-weakened action roles. This is the highest weight because action
  placement affects credentials, data exposure, and repository mutation.
- **Configuration recognition (CR), 20%:** associates a role with the correct
  YAML job and step without silently misreading unsupported syntax.
- **Single-source maintainability (MA), 15%:** minimizes independent normative
  inventories that can drift.
- **Platform operability (PO), 10%:** works in P1's required PowerShell and
  runner environments.
- **Diagnostic usability (DI), 10%:** gives a new contributor an exact missing,
  extra, malformed, or mismatched role.
- **Dependency/provenance exposure (DE), 8%:** avoids adding an ungoverned
  parser or executable to solve the policy check.
- **Scope and churn (SC), 7%:** stays within P1 without unnecessary workflow
  architecture changes. This is deliberately weighted below correctness.

### Scoring

Ratings are 1–5. The weighted total applies the percentages above.

| Option | SE | CR | MA | PO | DI | DE | SC | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 3 | 2 | 3 | 5 | 3 | 5 | 5 | 66 |
| B | 5 | 4 | 5 | 5 | 5 | 5 | 4 | 95 |
| C | 5 | 5 | 4 | 3 | 5 | 2 | 2 | 84 |
| D | 4 | 5 | 3 | 3 | 4 | 2 | 2 | 73 |
| E | 5 | 5 | 3 | 2 | 3 | 4 | 1 | 77 |
| F | 2 | 1 | 2 | 4 | 2 | 5 | 5 | 49 |

### Selected option

**Select Option B.**

For a cold implementer:

1. Finalize stable job IDs and give every external-action step a unique,
   stable step `id`.
2. Create one table containing all six checkout roles, both upload roles, both
   download roles, and the one setup-node role.
3. Put the exact action repository, full SHA, version comment, and
   security-relevant inputs in that same table.
4. Replace the separate approved-action table, observed minimum-count table,
   and setup-node special case with one structural scan.
5. Make the scanner fail on duplicate IDs, unknown external actions, an action
   in an unlisted role, a missing expected role, an extra role, any tuple/input
   mismatch, or workflow syntax it cannot classify.
6. Compare expected and observed role keys with case-sensitive exact set
   equality.
7. Correct “the two checkout occurrences” and make P1 acceptance language say
   that the static check proves the exact supported workflow form and role
   inventory.
8. Retain real GitHub runs as syntax and execution proof.
9. Refresh P2's prerequisite description after this P1 wording is final.

This provides exact policy evidence without adding a package or tool dependency
to P1.

## C-02 — Make P3 prove its Node support contract

### Options

#### Option A — Retain Node 24 validation and rerun only the harness at minimum

Keep P3 substantially as written: run the copyable validation block on Node 24
and rerun `Test-LintStagedMarkdown.ps1` under the selected minimum. This is the
least churn, but it does not prove clean installation, the full lint commands,
or the complete Husky hook at the lower runtime.

#### Option B — Two complete runtime cells using default npm engine behavior

Run fresh `npm ci`, `npm ls --all`, both lint commands, and the tracked harness
at the selected minimum and Node 24. This substantially improves behavioral
coverage, but npm documents `engines` as advisory by default. A dependency with
an incompatible declaration could produce a warning and still install.

#### Option C — Full-tree constraints, strict clean cells, and guard/hook tests

Define the contract as a minimum floor plus named validated LTS majors. Inspect
every resolved direct/transitive Node engine range and its semver intersection.
Require the selected minimum and Node 24 to be members. In each distinct named
cell, run a fresh install with `npm_config_engine_strict=true`, prohibit
`--force`, then run `npm ls --all`, both production lint commands, and the
tracked harness.

Extend the harness to verify manifest/guard agreement, both stable guard
messages, accepted-runtime behavior, below-minimum fail-fast behavior, and the
complete `.husky/pre-commit` path using test-owned shims/sentinels. Keep hosted
Node 24 mandatory; record a separate selected-minimum Windows and Ubuntu or
container result if it is not a second hosted CI cell.

#### Option D — Raise the only supported runtime to Node 24

Set the manifest and both guards to Node 24 and validate one clean Node 24 cell.
This is internally simple and truthful, but it removes a still-supported Node
22 local-development path even when the selected tree works there. It also
does not meet the issue's stated goal of using the actual dependency floor.

#### Option E — Declare and test every numeric major in a bounded interval

Use a range such as `>=22 <25` and execute Node 22, 23, and 24. This makes
“interval” literal, but adds an EOL Node 23 gate and creates security,
maintenance, and availability problems without user value.

#### Option F — Test every currently non-EOL Node release line

Build a matrix for Node 22, Node 24, and current Node 26, updating it whenever
Node's lifecycle changes. This gives broad ecosystem evidence but changes P3
from a dependency remediation into a rolling runtime-support program and
couples the issue to the short Current release phase.

### Evaluation rubric

This rubric evaluates runtime-support truthfulness:

- **Claim accuracy (CA), 25%:** the manifest, prose, and evidence claim only
  runtimes actually established.
- **Dependency compatibility (DC), 20%:** checks the complete resolved tree and
  npm tooling, not only direct packages or successful imports.
- **Guard boundary proof (GB), 15%:** proves both guards and the complete hook
  accept/reject at the correct boundary before tooling starts.
- **Reproducible clean execution (RE), 15%:** uses frozen clean installs and all
  production lint surfaces in each claimed cell.
- **Developer usability (DU), 10%:** gives contributors clear supported
  runtimes and useful diagnostics without requiring EOL software.
- **Lifecycle resilience (LR), 8%:** remains sensible as Node release status
  changes.
- **Scope and churn (SC), 7%:** limits incidental P3 changes. This remains
  subordinate to truthful compatibility.

### Scoring

| Option | CA | DC | GB | RE | DU | LR | SC | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 2 | 2 | 2 | 2 | 3 | 3 | 5 | 48 |
| B | 4 | 4 | 3 | 5 | 4 | 4 | 4 | 80 |
| C | 5 | 5 | 5 | 5 | 5 | 5 | 3 | 97 |
| D | 5 | 4 | 5 | 5 | 2 | 3 | 3 | 84 |
| E | 3 | 5 | 5 | 5 | 1 | 1 | 1 | 70 |
| F | 4 | 5 | 4 | 5 | 4 | 2 | 2 | 81 |

### Selected option

**Select Option C.**

For a cold implementer:

1. After choosing the final lockfile, enumerate every resolved package engine
   constraint, not only direct dependencies.
2. Evaluate the semver intersection. Record why the selected minimum and Node
   24 are both admitted. Reject a candidate that excludes Node 24.
3. Treat `engines.node` as the local minimum declaration. State separately
   that the executed evidence covers the selected supported LTS minimum and
   hosted Node 24; do not call this a continuous numeric interval.
4. Split the current validation so it can run as a reusable cell instead of
   hard-coding Node 24 before every command.
5. For each distinct cell, establish the exact Node and npm versions, set
   `npm_config_engine_strict=true`, prohibit `--force`, run fresh `npm ci`,
   `npm ls --all`, both production lint commands, and the tracked harness, then
   restore any prior environment value.
6. If the minimum is 24, explicitly record that the one clean cell satisfies
   both roles.
7. Extend the harness with stable cases for manifest/guard equality, both
   accepted paths, both rejected paths, exact diagnostics, fail-fast sentinels,
   and complete `.husky/pre-commit` delegation.
8. Use synthetic versions rather than installing EOL Node 20 for negative
   tests.
9. Keep the hosted Node 24 gate. Preserve Windows evidence for the actual hook
   environment and record selected-minimum Ubuntu/container evidence if CI
   remains Node 24-only.

The strict install is essential: default npm behavior can warn instead of
failing for dependency engine mismatches.

## C-03 — Align P3 residual approval identity with the audited risk

### Options

#### Option A — Keep URL identity and require every explain path

Retain one approval per unique advisory URL, but require the approval to list
all normalized `npm explain` chains for its package. This improves path
visibility but still assumes one URL globally identifies the risk and still
cannot prove which advisory applies to which installed node.

#### Option B — Audit-native package/advisory keys plus separate node evidence

Use exact `(Package, AdvisoryUrl)` composite keys for actual and approved
residual sets. Separately record, by package, the exact sorted nonempty
`AuditNodePaths` set from the vulnerability property's `nodes`. Keep normalized
`npm explain` output as reviewer context and never claim the response maps each
advisory object to each node.

Use exact expiry parsing and require evidence that the follow-up URL resolves
to a public non-pull-request issue in `franklesniak/PSStyleGuide`. Record owner
acceptance as manual review evidence.

#### Option C — Advisory/package/node tuples with semver evaluation

Build actual and approved tuples as
`(Package, AdvisoryUrl, AuditNodePath)`. Resolve the installed version for each
node from the lockfile and use semver-correct range evaluation to include only
advisories that apply to that version. Run `npm explain` by exact folder for
each tuple.

This is more granular, but it adds a semver evaluator and substantial mapping
logic to a one-off issue validator. It is justified only if per-installed-node
approval is an explicit governance requirement.

#### Option D — Package-wide residual approvals

Approve one vulnerable package property with its aggregate severity and all
node paths, without listing individual advisory URLs. This is easy to review
but can hide a newly added advisory under an existing package approval.

#### Option E — Prohibit every residual finding

Require final audit exit 0 with no moderate/high/critical findings and remove
the approval mechanism. This is the smallest exact residual set and strongest
default security outcome, but it provides no governed path when a registry
finding has no safe current fix or a policy-approved temporary exception is
necessary.

#### Option F — Delegate residual identity to an external risk system

Require every finding to exist in a vulnerability-management platform and
store only its external record URL in P3 evidence. This can improve enterprise
governance, but creates a new external dependency, may not be publicly
reviewable, and does not eliminate the need to reconcile npm's actual set.

### Evaluation rubric

This rubric evaluates exception identity and governance:

- **Audit provenance fidelity (AP), 25%:** keys approvals only with
  relationships the selected audit response directly establishes.
- **Residual completeness (RC), 20%:** exact equality detects a new, missing,
  duplicate, or stale residual.
- **Tree-shape resilience (TR), 15%:** handles duplicate installed packages and
  several advisories without conflation.
- **Governance strength (GS), 15%:** provides exact expiry, issue, ownership,
  and review evidence.
- **Reviewer comprehension (RV), 10%:** lets a cold security reviewer
  understand what is approved and what is contextual.
- **Implementation reliability (IR), 8%:** avoids fragile mappings or
  unjustified range calculations.
- **Scope and churn (SC), 7%:** fits P3. This is lower than provenance and
  completeness.

### Scoring

| Option | AP | RC | TR | GS | RV | IR | SC | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 3 | 3 | 3 | 4 | 3 | 4 | 5 | 67 |
| B | 5 | 5 | 5 | 5 | 5 | 5 | 4 | 99 |
| C | 5 | 5 | 5 | 5 | 3 | 2 | 1 | 86 |
| D | 2 | 2 | 2 | 3 | 4 | 5 | 5 | 56 |
| E | 5 | 5 | 5 | 3 | 4 | 5 | 2 | 88 |
| F | 4 | 4 | 5 | 5 | 2 | 2 | 1 | 75 |

### Selected option

**Select Option B.**

For a cold implementer:

1. Replace `DependencyPath` in each approval identity with exact `Package` and
   `AdvisoryUrl` fields.
2. Construct the actual residual set from every disposition-requiring object
   advisory as a case-sensitive composite key, not URL alone.
3. Reject duplicate composite keys and require exact equality between approved
   and actual composite-key sets.
4. Build a separate package-keyed record whose `AuditNodePaths` exactly equals
   the normalized, sorted, duplicate-free `nodes` array for that vulnerability
   property.
5. Preserve `npm explain` chains for each package and, where useful, exact
   folder, but label them diagnostic context.
6. Do not cross-product package advisories and node paths.
7. Parse expiry with one documented invariant UTC format, explicit
   `DateTimeStyles`, and `TryParseExact`; require it to be in the future.
8. Require follow-up URLs to target exactly
   `franklesniak/PSStyleGuide/issues/<number>`.
9. Require either an API check or recorded manual evidence that the URL is
   publicly retrievable and is not a pull request.
10. Record explicit owner acceptance separately from the nonempty owner field.

If organizational policy later requires per-node approval, adopt Option C in
separately reviewed scope with a real semver implementation. Do not silently
turn package-level audit evidence into per-advisory node mappings.

## C-04 — Reconcile P3 audit metadata with the graph

### Options

#### Option A — Retain metadata self-consistency only

Keep the current five severity parses and require their sum to equal metadata
total. This proves that metadata is internally arithmetically consistent, but
not that it describes the enumerated graph.

#### Option B — Add property count and severity reconciliation

Require vulnerability property count to equal total, validate each property
severity, and derive severity counts from properties. This closes the principal
metadata gap but leaves node paths, edges, advisory shapes, and remediation
shapes only partially checked.

#### Option C — Validate every consumed graph shape and relationship

Record the exact npm version and audit report version. Validate the expected
top-level objects; every vulnerability property's key/name, severity,
`isDirect`, range, `via`, `effects`, `nodes`, and `fixAvailable` shapes; exact
metadata/property count equality; lockfile resolution for every node path; and
edge consistency for the selected observed schema. Validate all object
advisories before selecting those that require disposition.

Allow additive fields to remain in raw evidence, but fail if a field the
validator consumes is missing, changes type, or violates a recorded invariant.

#### Option D — Enforce an exact generated JSON Schema

Capture one audit response, generate a closed JSON Schema, and reject any
response with additional or changed fields. This is mechanically strict but
confuses harmless additive npm output with a security failure, becomes tightly
coupled to one patch release, and still needs semantic cross-field checks.

#### Option E — Use npm internals or an external audit library

Call Arborist/metavulnerability internals or another library to construct a
typed graph instead of validating CLI JSON. This may expose richer objects but
relies on an internal or additional API with its own version/provenance
surface. It is unnecessary for a one-issue evidence validator.

#### Option F — Preserve raw JSON and rely on human review

Check only command exit and nonempty parseable JSON, then require a reviewer to
inspect the saved report. Raw evidence is valuable, but manual review alone is
not repeatable exact-set enforcement and is prone to overlooking stale
approvals or graph inconsistencies.

### Evaluation rubric

This rubric evaluates audit graph validation:

- **Inconsistency detection (ID), 25%:** detects metadata/graph disagreement,
  malformed nodes, bad edges, and ignored severities.
- **Fail-closed schema use (FS), 20%:** rejects changes to every relied-upon
  shape without falsely claiming an eternal npm schema.
- **Lockfile traceability (LT), 15%:** ties audit node paths to the reviewed
  resolved package/version tree.
- **Upgrade reviewability (UR), 15%:** produces a clear deliberate review point
  when npm output evolves.
- **Diagnostic quality (DQ), 10%:** identifies the exact field, property, path,
  or edge that failed.
- **Maintenance stability (MS), 8%:** avoids excessive coupling to harmless
  additive fields or undocumented internals.
- **Scope and churn (SC), 7%:** remains implementable in P3, below correctness
  in weight.

### Scoring

| Option | ID | FS | LT | UR | DQ | MS | SC | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 3 | 2 | 1 | 3 | 3 | 5 | 5 | 56 |
| B | 4 | 3 | 3 | 4 | 4 | 5 | 4 | 75 |
| C | 5 | 5 | 5 | 5 | 5 | 4 | 3 | 96 |
| D | 5 | 5 | 5 | 2 | 3 | 1 | 1 | 75 |
| E | 5 | 4 | 5 | 3 | 4 | 2 | 1 | 78 |
| F | 2 | 1 | 1 | 2 | 2 | 5 | 5 | 42 |

### Selected option

**Select Option C.**

For a cold implementer, perform these checks before residual comparison:

1. Record Node, npm, raw audit JSON, exit code, and
   `auditReportVersion`; require the reviewed report version.
2. Require `metadata.vulnerabilities` and a nonnull object-valued
   `vulnerabilities`.
3. For every vulnerability property, require its value's `name` to equal the
   property key and require recognized shapes for severity, `isDirect`, range,
   `via`, `effects`, `nodes`, and `fixAvailable`.
4. Derive property-level severity counts and require exact equality with all
   five metadata counts and total. Do not derive these counts from advisory
   objects.
5. Require each `nodes` set to be nonempty, normalized, and duplicate-free.
   Resolve each path to the corresponding `package-lock.json` `packages`
   entry, package name, and exact version.
6. Require every string `via` target and every `effects` target to name an
   enumerated vulnerability property.
7. For the selected npm/report schema, require each `effects` edge to have the
   observed reciprocal string `via` edge. If npm changes that contract, fail
   with a schema-review diagnostic rather than silently accepting it.
8. Validate every object advisory's canonical URL, recognized severity, and
   nonempty range before filtering by the disposition threshold. Reject an
   unknown severity.
9. Accept `fixAvailable` only as a Boolean or a reviewed object with validated
   package name, version, and Boolean semver-major marker.
10. Preserve additive unknown fields in raw evidence, but never consume an
    unvalidated field.

This gives exact semantic checks without the brittleness of a closed
sample-generated schema.

## C-05 — Replace planning-file references when issues are filed

### Options

#### Option A — Keep repository-relative planning links

Leave P1/P2/P3 as currently written. This is convenient while browsing the
draft directory but produces issue-body links whose resolution context and
target branch differ from the source files.

#### Option B — Create in execution order, then backfill real relationships

Prepare issue bodies without local planning-path links. File P1, P2, and P3 in
execution order. As each number becomes available, insert the actual issue URL
where ownership or dependency is discussed and create GitHub's blocked-by
relationships. After P3 exists, backfill its actual URL into the P1/P2
delegation text.

Replace the research artifact link with an exact commit permalink or remove it
in favor of direct primary sources.

#### Option C — Use repository-root blob links

Convert each planning link to a GitHub path rooted at the repository or default
branch. This may render from an issue, but it still points to planning documents
rather than the real work items and a branch link is mutable.

#### Option D — Leave explicit issue-number placeholders

Put tokens such as `PSSTYLE-P1-ISSUE-URL` in each body and require the filer to
replace them. This makes the missing data obvious but risks publishing literal
placeholders and still needs a backfill workflow.

#### Option E — Publish planning documents on `main`

Merge the planning files to the default branch and link issues to those stable
paths. This makes the files accessible, but branch content remains mutable and
duplicates the issue as the source of truth.

#### Option F — File in reverse order to know every downstream number

Create P3, then P2, then P1 so upstream bodies can include downstream issue
numbers immediately; add blocked-by relationships after all exist. The work
order can still be P1 → P2 → P3, but reverse issue numbering is less intuitive
and does not eliminate editing the dependency relationships.

### Evaluation rubric

This rubric evaluates durable issue handoff:

- **Reference durability (RD), 25%:** links identify the intended immutable
  evidence or live issue over time.
- **Dependency truth (DT), 20%:** GitHub visibly represents P1 → P2 → P3.
- **Cold-reader navigation (CN), 15%:** a downstream implementer can move
  directly among real issues and evidence.
- **Historical reproducibility (HR), 15%:** cited research can be retrieved in
  the exact reviewed state.
- **Filing reliability (FR), 10%:** minimizes forgotten placeholders and
  partially populated relationships.
- **Draft usability (DU), 8%:** remains workable before issue numbers exist.
- **Scope and churn (SC), 7%:** limits administrative edits, below durability
  and truth.

### Scoring

| Option | RD | DT | CN | HR | FR | DU | SC | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 2 | 3 | 1 | 5 | 5 | 5 | 50 |
| B | 5 | 5 | 5 | 5 | 4 | 4 | 4 | 95 |
| C | 3 | 2 | 4 | 2 | 4 | 5 | 4 | 63 |
| D | 2 | 3 | 3 | 3 | 2 | 4 | 5 | 57 |
| E | 4 | 3 | 4 | 2 | 3 | 5 | 2 | 67 |
| F | 5 | 5 | 4 | 5 | 3 | 4 | 3 | 89 |

### Selected option

**Select Option B.**

For a cold filer:

1. Use each document's H1 as its issue title and body heading.
2. Create P1 first, P2 second, and P3 third so issue numbering follows work
   order.
3. Immediately after P2 exists, mark P2 blocked by P1 using GitHub's issue
   relationship and put P1's actual issue URL in P2's prerequisite text.
4. Immediately after P3 exists, mark P3 blocked by P2 and put P2's actual issue
   URL in P3's prerequisite text.
5. Backfill P3's actual URL wherever P1 or P2 delegates npm work.
6. Verify the final issue bodies contain no
   `docs/planning/PSStyleGuide/...` links or unresolved placeholders.
7. Use a full commit-SHA permalink for any retained planning research record.
   If that exact artifact is not accessible to the intended reviewers, remove
   it and keep the direct primary-source references.
8. Verify the issue relationship UI or API reports exactly P2 blocked by P1
   and P3 blocked by P2.

The draft revisions should remove repository-relative planning links now while
retaining clear filing instructions for the actual relationships.

## C-06 — Proposed P1 → P3 → P2 fallback

### Options

#### Option A — Unconditional P1 → P2 → P3

Remove P3's policy exception and always follow the stipulated order. This is
simple and preserves baselines, but could knowingly conflict with a real
organization rule that prohibits carrying high findings.

#### Option B — Default P1 → P2 → P3 with one policy-driven rebaseline

Retain the stipulated sequence. At filing and implementation, verify the actual
repository/organization vulnerability policy. Only if that policy forbids the
default sequence, make the complete P3 remediation the real prerequisite,
perform it before P1/P2, and rebaseline all affected P1/P2 assumptions.

#### Option C — Advance P3 after P1 whenever P2 is delayed

Use P1 → P3 → P2 based on elapsed time or project-management concern. This
violates the requested sequence and creates an unmodeled baseline in which P2
must reinterpret P3's later-package supersession language.

#### Option D — Always perform P3 first

Use P3 → P1 → P2 because the current audit has high findings. This prioritizes
remediation but discards the requested work order even when policy permits it
and forces broad P1/P2 rebaselining.

#### Option E — Parallelize P2 and P3 after P1

Start P2 and P3 concurrently, then reconcile. This directly violates the
one-at-a-time requirement and creates overlapping edits to validation and
package assumptions.

### Evaluation rubric

This rubric evaluates issue sequencing:

- **User-order fidelity (UF), 30%:** honors the explicit one-at-a-time
  P1 → P2 → P3 requirement.
- **Baseline integrity (BI), 25%:** each issue starts from the predecessor state
  its validation and supersession text assumes.
- **Policy responsiveness (PR), 20%:** can comply with an actual vulnerability
  policy without hand-waving.
- **Coordination clarity (CC), 10%:** gives the project manager and implementer
  one unambiguous decision rule.
- **Delivery predictability (DP), 8%:** avoids surprise rebases and overlapping
  work.
- **Scope and churn (SC), 7%:** limits rework, below correctness and policy.

### Scoring

| Option | UF | BI | PR | CC | DP | SC | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 2 | 5 | 5 | 5 | 88 |
| B | 5 | 5 | 5 | 5 | 4 | 4 | 97 |
| C | 1 | 3 | 3 | 2 | 2 | 2 | 43 |
| D | 1 | 4 | 5 | 3 | 3 | 1 | 58 |
| E | 1 | 2 | 3 | 1 | 2 | 2 | 36 |

### Selected option

**Select Option B.**

No new P1 → P3 → P2 branch should be added. Keep the current P3 ordering rule:

1. Default to P1 → P2 → P3.
2. Check the actual governing policy at filing and implementation time.
3. Do not reorder for a hypothetical risk or schedule delay.
4. If the policy truly forbids the default order, perform the complete P3
   dependency/hook change first or file it as the real prerequisite.
5. After that exception merges, rebaseline every affected P1/P2 Node, npm,
   lockfile, path-set, validation, and supersession assumption.
6. Record the policy source and the decision.

The issue slate already expresses this option. Preserve it and do not
incorporate the supplied criticism's P1 → P3 → P2 scheduling suggestion.

## I-P3-01 — Separate vulnerable-package counts from advisory counts

### Options

#### Option A — Add one terminology sentence

State that metadata counts vulnerable package properties while object advisory
records are counted separately. This is clear but does not require mechanical
reconciliation of the two collections.

#### Option B — Define and validate both counting units

Name three distinct units in P3:

- vulnerability properties counted by metadata;
- object advisory records counted from object-valued `via` members; and
- distinct disposition keys counted as `(Package, AdvisoryUrl)`.

Record all three before and after remediation. Reconcile metadata only with
property severities, validate every object advisory separately, and compare
only distinct disposition keys with approvals.

#### Option C — Hard-code the current fourteen advisories in the issue

Add a dated table containing every current package/URL/severity/range record.
This is useful review context, but registry data may change before P3 starts and
the table can be mistaken for a permanent expected set.

#### Option D — Count only unique advisory URLs

Collapse object advisories across packages and use the unique URL count
everywhere. This loses package context and can hide one advisory affecting
several package properties.

#### Option E — Commit a raw audit snapshot as a normative fixture

Add the current audit JSON to the repository and test the validator against it.
This gives excellent parser regression coverage but creates another affected
file and may encourage treating a dated registry response as the final
expected audit result.

#### Option F — Remove all dated counts

Require only implementation-time dynamic discovery. This avoids stale numbers
but removes useful proof that the issue addresses the observed current defect.

### Evaluation rubric

This rubric evaluates audit-count semantics:

- **Unit correctness (UC), 30%:** never conflates package properties,
  advisories, and approval identities.
- **Mechanical drift detection (MD), 20%:** new or missing records cannot hide
  behind another count.
- **Reviewer clarity (RC), 20%:** security and business reviewers can explain
  each number.
- **Evidence completeness (EC), 15%:** before/after records support the
  remediation decision.
- **Temporal resilience (TR), 8%:** dated context cannot silently become a
  stale expected final set.
- **Scope and churn (SC), 7%:** fits P3, below correctness.

### Scoring

| Option | UC | MD | RC | EC | TR | SC | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 4 | 3 | 5 | 3 | 5 | 5 | 80 |
| B | 5 | 5 | 5 | 5 | 5 | 4 | 99 |
| C | 5 | 4 | 4 | 5 | 2 | 2 | 83 |
| D | 2 | 2 | 3 | 2 | 3 | 4 | 48 |
| E | 5 | 5 | 4 | 5 | 3 | 1 | 87 |
| F | 1 | 1 | 2 | 1 | 5 | 5 | 36 |

### Selected option

**Select Option B.**

For a cold implementer:

1. Add explicit definitions near P3's baseline and validation:
   `metadata.vulnerabilities.total` counts vulnerability properties, not
   advisory objects.
2. Record the dated baseline as seven properties and fourteen object
   advisories, while saying both are implementation-time dynamic evidence.
3. Derive metadata severity counts from property-level severities.
4. Validate and count every object advisory independently.
5. Derive the residual approval set from distinct
   `(Package, AdvisoryUrl)` keys.
6. Report all three counts in diagnostics and pull-request evidence.
7. Do not require the final run to preserve the dated seven/fourteen values;
   require it to be internally consistent and exactly dispositioned.

This clarification composes directly with the selected C-03 and C-04 designs.

## I-P3-02 — Define support as a set, not an accidentally unbounded claim

### Options

#### Option A — Minimum admission rule plus named validation set

Keep `engines.node` and both guards as an exact lower-bound rule such as
`>=22`. Describe it as the minimum admitted local-tooling version, not as a
claim that every future major has been tested. Separately name the executed
support evidence: the selected LTS minimum and hosted Node 24.

This follows conventional package-engine practice and keeps future Node
versions from being rejected solely because they were released later. It
requires precise language distinguishing “admitted by the floor” from
“explicitly validated.”

#### Option B — Exact union of validated LTS major lines

Use a disjunctive range such as `>=22 <23 || >=24 <25` and make both guards
match it. This is the most literal tested-support set, but it rejects Node 26
and requires coordinated manifest/guard edits whenever another LTS line is
accepted.

#### Option C — Bounded continuous range

Use `>=22 <25` and test the endpoints. This still admits EOL Node 23, so it does
not solve the mismatch between a numeric interval and the actual LTS support
policy.

#### Option D — Node 24 only

Use `>=24 <25` and validate one runtime. This is simple and exact but needlessly
rejects Node 22 when the selected dependency tree and hook work there.

#### Option E — Remove `engines.node`

Treat the hook and staged-script guards as the only runtime policy. This avoids
range semantics but removes the package-manager-visible compatibility signal
and creates two independent sources of truth.

#### Option F — Add npm `devEngines` as an exact enforcement layer

Keep broad `engines.node`, add an exact `devEngines.runtime` rule, and align the
guards with it. This can make npm fail early, but `devEngines` behavior depends
on newer npm versions and introduces a second manifest runtime construct that
must remain synchronized.

### Evaluation rubric

This rubric evaluates support-policy communication:

- **Semantic honesty (SH), 30%:** prose clearly distinguishes admission,
  validation, and lifecycle support.
- **Contributor compatibility (CC), 20%:** avoids rejecting a usable
  environment without a security or correctness reason.
- **Policy consistency (PC), 15%:** manifest and both guards express one
  understandable rule.
- **Lifecycle manageability (LM), 15%:** does not require emergency edits for
  every Node release while still enabling deliberate support updates.
- **Evidence alignment (EA), 10%:** acceptance criteria name only executed
  runtime evidence.
- **Tooling portability (TP), 5%:** works with the selected Node/npm range.
- **Scope and churn (SC), 5%:** fits P3; this is intentionally the lowest
  weight.

### Scoring

| Option | SH | CC | PC | LM | EA | TP | SC | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 4 | 5 | 5 | 5 | 4 | 5 | 5 | 92 |
| B | 5 | 3 | 5 | 2 | 5 | 5 | 3 | 81 |
| C | 3 | 2 | 4 | 2 | 2 | 5 | 3 | 56 |
| D | 5 | 2 | 5 | 4 | 5 | 5 | 4 | 84 |
| E | 2 | 4 | 3 | 4 | 4 | 5 | 4 | 66 |
| F | 5 | 4 | 4 | 2 | 5 | 2 | 1 | 77 |

### Selected option

**Select Option A.**

For a cold implementer:

1. Keep one exact lower-bound string in `engines.node`, derived from the
   selected tree's reviewed minimum.
2. Make `.husky/pre-commit` and `lint-staged-markdown.mjs` enforce that same
   lower bound and message.
3. Call this the “minimum admitted local-tooling major,” not the “complete
   supported interval.”
4. In validation and acceptance, list the exact runtime majors executed:
   selected supported LTS minimum and Node 24.
5. State that a lower-bound range does not mean every future major has received
   explicit test evidence.
6. Do not claim Node 23 as a supported target merely because it is numerically
   between the two tested LTS lines.
7. If repository policy later requires rejection of every untested or EOL
   major, adopt Option B as a deliberate policy change and update all three
   guards plus their tests together.

This choice balances conventional minimum-version behavior with truthful test
claims. C-02's strict cells still prove the two named runtime roles.

## I-P1-01 — Make the action inventory the single source of truth

### Options

#### Option A — Keep several tables and cross-check them

Retain approved repositories, required counts, and one-off checks as separate
structures, then add validation that their keys agree. This detects some drift
but preserves redundant normative data and complicated reconciliation.

#### Option B — One in-script normative role table

Create one ordered collection of role records. Each record contains workflow
path/name, job ID, step ID, repository, SHA, version comment, and required
security-sensitive inputs. Derive approved repositories, expected role keys,
counts, tuples, input checks, and diagnostics only from this collection.

#### Option C — Infer the expected inventory from the workflows

Scan the workflows and treat whatever roles are present as the expected set,
then validate only pins and comments. This removes duplication but makes the
configuration under test define its own policy; an unintended added role
becomes automatically approved.

#### Option D — Generate workflows from the role table

Use one manifest to render all external-action steps or complete workflows.
This makes the source authoritative but introduces a generation lifecycle and
reduces direct workflow readability.

#### Option E — Add a separate machine-readable policy file

Store the role table as committed JSON/YAML and have a validator consume it.
This cleanly separates data and code and may support future tooling, but adds a
seventh P1 affected file and another format/parser surface for a small fixed
inventory.

#### Option F — Put policy annotations beside workflow steps

Add structured comments near each `uses` step and have the validator parse
them. This improves locality but allows deletion of an action and its annotation
together unless another independent inventory still exists.

### Evaluation rubric

This rubric evaluates policy-source architecture:

- **Drift resistance (DR), 30%:** one edit cannot silently redefine or omit an
  expected action role.
- **Audit readability (AR), 20%:** a reviewer can inspect one complete
  normative inventory.
- **Diagnostic coherence (DC), 15%:** all mismatch messages use the same role
  identity and expected values.
- **Implementation simplicity (IS), 15%:** avoids reconciliation or generation
  machinery that obscures the policy.
- **Extension safety (ES), 10%:** future deliberate action roles have one
  obvious update path.
- **Dependency independence (DI), 5%:** needs no new parser or tool.
- **Scope and churn (SC), 5%:** remains inside P1's existing validation
  surface.

### Scoring

| Option | DR | AR | DC | IS | ES | DI | SC | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 2 | 3 | 3 | 5 | 4 | 5 | 5 | 66 |
| B | 5 | 5 | 5 | 4 | 5 | 5 | 4 | 96 |
| C | 1 | 3 | 3 | 4 | 4 | 5 | 4 | 56 |
| D | 5 | 3 | 3 | 1 | 4 | 4 | 1 | 67 |
| E | 5 | 5 | 5 | 3 | 5 | 4 | 2 | 90 |
| F | 3 | 3 | 4 | 4 | 3 | 5 | 3 | 68 |

### Selected option

**Select Option B.**

For a cold implementer:

1. Define one ordered array of action-role records in P1's copyable validator.
2. Include every expected placement, tuple, comment, and required input in the
   record itself.
3. Derive the repository allowlist by selecting the records' distinct
   repositories.
4. Derive expected composite role keys and any human-readable counts from the
   records.
5. Match each observed external-action step to exactly one record.
6. Produce missing, extra, duplicate, tuple, and input diagnostics from that
   record and observed step.
7. Delete the separate approved-action map, required-occurrence map, and
   setup-node special case.
8. Never infer policy from the observed workflows themselves.

This is the data architecture used by selected C-01 Option B; it does not add a
new affected file.

## I-XR-01 — Preserve behavioral P1/T1 convergence

### Options

#### Option A — Preserve repository-local implementations and shared contracts

Keep P1's current generator and helper convergence matrices, repository-local
scripts, implementation-time comparison, and explicit difference
classification. Link the exact T1 issue/commit evidence inspected.

#### Option B — Require the same private helper design in both repositories

Coordinate a repository-local serialization helper and require equivalent
function boundaries/names in P1 and T1. This may reduce local code duplication
but constrains implementation before either repository has produced stable
evidence.

#### Option C — Create a shared module or reusable action now

Move generator serialization or candidate validation into one shared runtime
dependency. This maximizes code reuse but adds release, pinning, provenance,
availability, cross-edition, and coordinated-rollout requirements outside P1.

#### Option D — Require line-for-line copied implementations

Keep repositories independent but copy the exact code and use diffs to detect
divergence. Guide-specific functions, artifact names, and harness placement
make those diffs noisy, so textual identity can obscure behavioral equivalence.

#### Option E — Publish a shared external contract test suite

Create a third artifact or repository containing fixtures that both
implementations consume. This can prove convergence, but adds its own
versioning and provenance problem before the local contracts have stabilized.

#### Option F — Remove cross-repository coordination

Let each repository solve serialization and artifact security independently.
This reduces coordination but abandons the user's unification objective and
invites preventable behavioral divergence.

### Evaluation rubric

This rubric evaluates cross-repository convergence strategy:

- **Behavioral convergence (BC), 25%:** establishes the same observable byte,
  failure, path, archive, and diagnostic invariants.
- **Repository independence (RI), 20%:** either repository can build, validate,
  and recover without the other.
- **Rollout safety (RS), 15%:** parallel work and different merge times cannot
  break a runtime dependency.
- **Security/provenance simplicity (SP), 15%:** avoids adding an artifact whose
  integrity and updates require new controls.
- **Long-term maintainability (LM), 10%:** produces useful comparison evidence
  without noisy false differences.
- **Cold-reader clarity (CC), 8%:** intentional similarities and differences
  are explicit.
- **Scope and churn (SC), 7%:** stays within P1; lower than correctness.

### Scoring

| Option | BC | RI | RS | SP | LM | CC | SC | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 4 | 5 | 5 | 98 |
| B | 5 | 4 | 3 | 4 | 4 | 3 | 3 | 79 |
| C | 5 | 1 | 2 | 2 | 5 | 3 | 1 | 57 |
| D | 4 | 5 | 3 | 4 | 2 | 2 | 2 | 71 |
| E | 5 | 3 | 3 | 3 | 4 | 3 | 1 | 69 |
| F | 1 | 5 | 5 | 5 | 2 | 3 | 5 | 71 |

### Selected option

**Select Option A.**

For a cold implementer:

1. Preserve P1's generator convergence matrix and candidate-helper convergence
   matrix.
2. Keep every implementation and harness repository-local.
3. Immediately before P1 implementation, inspect the then-current T1 issue or
   merged implementation and record its exact issue, pull request, or commit
   permalink.
4. Compare serialization boundaries, encoded bytes, newline behavior, failure
   behavior, public helper parameters, validation order, path/archive trust
   rules, diagnostics, and harness evidence.
5. Classify every difference as guide-specific content, a deliberately accepted
   design difference, or a defect/follow-up.
6. Do not compare final guide bytes across repositories.
7. Do not introduce a shared package, module, submodule, reusable action, or
   merge-order dependency in P1.
8. Consider shared code only in a later proposal after both local
   implementations have stable evidence.

No substantive P1 convergence redesign is required. C-05's immutable-link rule
should make the implementation-time comparison record durable.

## Selected-option implementation map

- **P1:** implement C-01 Option B and I-P1-01 Option B; preserve I-XR-01
  Option A; apply C-05 filing cleanup.
- **P2:** refresh the P1 prerequisite snapshot after the action validator is
  final; apply C-05 filing cleanup; otherwise preserve the issue.
- **P3:** implement C-02 Option C, C-03 Option B, C-04 Option C,
  I-P3-01 Option B, and I-P3-02 Option A; preserve C-06 Option B; apply C-05
  filing cleanup.
