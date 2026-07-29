# Review of the PSStyleGuide P1/P2/P3 GitHub issue slate

## Overall assessment

The P1 → P2 → P3 sequence is coherent under the requested assumption that the
issues are implemented one at a time. P1 establishes the generator and
workflow baseline, P2 changes source documentation and regenerates against
that baseline, and P3 then changes the lint dependency/governance surface.

The embedded H1 titles and P1/P2/P3 naming are clear and should be preserved.
The slate is also substantially stronger than its earlier versions:

- P1 has complete-payload LF normalization, BOM-less serialization, immutable
  artifact transport, a same-held-stream digest/ZIP contract, complete path
  component checks, stable fixture IDs, and a single exact-lease writer.
- P2 makes an invisible documentation defect durable without storing forbidden
  trailing spaces and validates the exact canonical visualization.
- P3 gives the known npm advisory graph a real owner, deliberate update
  process, and review-only update-governance target.

I would not hand off the current drafts unchanged. The supplied criticism is
mostly valid. P1 needs targeted convergence, cleanup-test, edition-proof,
link-coverage, and action-pin-verifier corrections. P2 is sound but needs its
prerequisite refreshed and its local Node runtime bound to Node 24. P3 needs
more substantial revision: its known upgrade candidate raises the supported
Node floor beyond the current staged-hook guards, and its validation does not
exercise the staged API, any real negative fixtures, the full residual
disposition record, or its final Dependabot state.

My recommended disposition is:

1. revise P1 before filing;
2. refresh P2 from final P1 and add one local Node check;
3. revise P3's scope and executable evidence before filing; and
4. retain P1 → P2 → P3 unless an actual repository security policy requires
   advisory remediation first.

## Review basis

This review used the current:

- [P1](../PSStyleGuide/01PSStyleGuideP1.md);
- [P2](../PSStyleGuide/02PSStyleGuideP2.md);
- [P3](../PSStyleGuide/03PSStyleGuideP3.md);
- [supplied criticism](../PSStyleGuide/slate-criticism.md); and
- [T1](../TerraformStyleGuide/03TerraformStyleGuideT1.md) and
  [T2](../TerraformStyleGuide/04TerraformStyleGuideT2.md) only where needed to
  evaluate cross-repository convergence claims.

The live PSStyleGuide baseline remains
[`4346310e7deebffb4159c75e30d9546263dfd649`](https://github.com/franklesniak/PSStyleGuide/commit/4346310e7deebffb4159c75e30d9546263dfd649)
on `main`. At that commit:

- `.gitattributes` is exactly `* text=auto eol=lf`;
- the generator has four edition-sensitive
  `Set-Content -Encoding UTF8 -NoNewline` writes and one frontmatter
  here-string;
- `build.yml` has path filters, workflow-level `contents: write`, and moving
  action tags;
- `markdownlint.yml` installs Node 20 and uses moving action tags;
- the Blank Line Usage examples have the same stored empty third line;
- `.husky/pre-commit` and `lint-staged-markdown.mjs` accept Node 20 or newer;
  and
- `samples` contains the two positive Markdown samples but no tracked negative
  sample.

A fresh lockfile-only audit on 2026-07-29 still reports zero critical, five
high, two moderate, and zero low vulnerable package nodes. It currently
returns 14 distinct moderate/high advisory URLs across the object-valued
`via` records, not merely the six representative URLs in P3's References.

The current P1 action SHAs resolve in the official action repositories. Their
exact `action.yml` files confirm Node 24 action runtimes and the relied-on
inputs, including `package-manager-cache`, `archive`, `artifact-ids`,
`skip-decompress`, and `digest-mismatch`.

The known P3 candidate facts are also current:

- installed `markdownlint-cli2@0.20.0` and `markdownlint@0.40.0` declare
  Node `>=20`;
- `markdownlint-cli2@0.23.2` and its bundled `markdownlint@0.41.1` declare
  Node `>=22`;
- the 0.23.0 changelog explicitly removes Node 20 support; and
- 0.23.2 still exports `main` and accepts `nonFileContents`.

The last point justifies testing the repository's staged integration; it does
not prove that integration works.

## Supplied-criticism audit

### C-01: Rebaseline P1's convergence matrix against final T1

**Disposition: Confirmed. Impact: High factual correction.**

P1 still describes its held-stream sequence as a stronger P1-only choice and
warns that T1 may not share it. Current T1 now requires the same
`FileMode.Open`/`FileAccess.Read`/`FileShare.Read` stream to be hashed,
rewound, and retained through the only `ZipArchive`.

P1's Permanent fixtures row is also stale. It says fixtures exercise only the
public helper interface, while current T1 has one narrow definition-only
exception that directly invokes the exact named production cleanup function.

Revise those two rows and the associated acceptance language. Preserve the
repository-specific manifest names, artifact names, fixture details, and
diagnostic values. Require an implementation-start comparison with the
then-current T1, but do not create a runtime or filing dependency between
repositories.

### C-02: Add a generator-specific convergence contract

**Disposition: Confirmed as an improvement opportunity. Impact: Medium.**

P1's existing matrix is almost entirely about the helper, paths, archive,
lifecycle, fixtures, and artifact transport. The user's generator-unification
objective deserves an explicit generator matrix rather than being inferred
from scattered serialization requirements.

The matrix should cover complete-payload normalization, resolved destinations,
`UTF8Encoding($false)`, `WriteAllText`, no implicit newline, common artifact
function behavior, frontmatter construction, script-version policy,
`.gitattributes` versus producer correctness, and cross-edition/raw-byte
validation. It should identify filenames, `applyTo`, descriptions, guide-
specific transforms, and current repository state as intentional differences.

This is behavioral convergence, not a requirement for a shared package,
reusable action, or line-for-line implementation identity. It is not a
standalone security blocker, but it materially improves the stated
cross-repository goal.

### C-03: Deterministically test the exact production cleanup function

**Disposition: Confirmed. Impact: High.**

P1 now has truthful state-specific cleanup outcomes, but it still records only
whether the leaf/files were created and permits either successful removal or a
reported cleanup failure. No deterministic fixture forces the fail-closed
branch, and no named production cleanup function is part of the contract.

Adopt the current T1 shape:

- maintain an exact ownership journal;
- put cleanup in one named production function;
- dispose archive/entry/file streams before cleanup;
- complete an exhaustive envelope, immediate-child, journal, and ordinary-file
  pre-deletion pass before deleting anything;
- remove known files individually and the proven-empty directory
  nonrecursively;
- stop and retain state on missing, extra, replaced, linked, unreadable, or
  uncertain entries; and
- preserve the primary error plus stable cleanup diagnostics.

Add one cross-platform fixture that inserts an unjournaled ordinary immediate
child and invokes that exact function through one documented definition-only
loading path. A real link/reparse substitution can supplement it where
available. Update P1's lifecycle, oracle, controlled evidence, convergence
matrix, and acceptance criteria together.

### C-04: Verify local PowerShell identity inside each child

**Disposition: Confirmed. Impact: Medium to high.**

P1's local loop resolves applications named `pwsh` and `powershell`, labels
them, then invokes the harness and generator with `-File`. The child does not
assert its own `$PSVersionTable`, so the label is not proof of the edition or
version that performed the work.

Use a fixed child `-Command` bootstrap with task-specific expected values passed
as data. In the same child that invokes each target, require Desktop exactly
5.1 or Core major 7, report expected versus observed values, propagate a
nonzero target result, and restore/remove temporary environment variables in
the parent's `finally`. Do this independently for the harness and generator.

### C-05: Require real link coverage on both operating-system families

**Disposition: Confirmed. Impact: High for the path-security claim.**

P1 allows a stable case-level skip when a link primitive or privilege is
unavailable, but it does not require any link/reparse case to execute on each
OS family. All such rows could therefore be skipped on Windows or Ubuntu while
the suite remains otherwise green.

Require at least one real component-or-leaf symbolic-link fixture on Ubuntu and
one real component-or-leaf link/reparse fixture on Windows. A narrowly
identified unavailable form may still skip; an unexpected setup failure must
fail the cell, and a platform-wide link skip must not satisfy acceptance.

### C-06: Align or explain pull-request harness placement

**Disposition: Partially confirmed. Impact: Low to medium.**

There is no correctness defect in P1 running the helper harness in Ubuntu plus
the two Windows LF cells. That covers PowerShell 7 on Ubuntu and both Windows
editions, and helper behavior is independent of the source fixture's EOL
variant. Repeating the full suite in CRLF cells would mainly buy placement
symmetry with T1 at additional CI cost.

The criticism is correct that P1's matrix merely says placement may differ
without recording this rationale. Keep the two-LF-cell optimization if desired,
but identify it as intentional per-edition helper coverage rather than
edition × EOL helper coverage. Running all four cells is optional, not required
to repair a defect. Preserve the stronger rule that all four push cells execute
the harness and production helper.

### C-07: Refresh P2's prerequisite snapshot

**Disposition: Confirmed, with a maintenance qualification. Impact: Medium.**

P2's prerequisite accurately reflects current P1, but the confirmed P1 changes
will make it stale. Update it after P1 is final to mention the shared
held-stream invariant, named/directly tested cleanup, mandatory cross-platform
link coverage, and same-child edition proof.

P2 already says P1 is the source of truth. Keep the prerequisite as a concise
invariant summary and normative link rather than duplicating the final
implementation algorithm. Do not import T2 provider-recovery content.

### C-08: Assert Node 24 before P2's local npm commands

**Disposition: Confirmed. Impact: Medium.**

P2 immediately runs `npm ci` and both lint commands using whichever `node` is
on `PATH`. That contradicts its P1 prerequisite and hosted-evidence claims.
The review environment itself currently has Node 26, illustrating that the
copyable block can pass under a different major.

Resolve `node` and `npm` as applications, query exactly one Node version, and
require major 24 before installation or lint. Reuse P1's validated pattern and
restore `CI` if P2 sets it. Hosted Node 24 evidence remains mandatory.

### C-09: Remove P2's stale metadata snapshot

**Disposition: Confirmed as editorial guidance, not a blocker. Impact: Low.**

The `2.24.20260728.0` value is clearly labeled a conditional drift-only
snapshot and the normative algorithm requires recalculation, so it is not a
logical defect. It is now a dead example and creates needless copy risk.
Remove it and keep the target-branch/current-UTC calculation rules.

### C-10: Resolve P3's known Node-engine and staged-hook mismatch

**Disposition: Confirmed. Impact: High.**

P3 treats an engine change as a possible future discovery, but its named
candidate already requires Node `>=22`. The live pre-commit shell guard and
`lint-staged-markdown.mjs` both admit Node 20. Updating only the three current
P3 files would let an explicitly accepted runtime launch an unsupported
toolchain.

P3 should either:

- add `.husky/pre-commit` and
  `.github/workflows/lint-staged-markdown.mjs` to its affected files, choose
  one explicit floor, update both guards/messages, and add a matching
  `engines.node` field; or
- create a real prerequisite issue for that policy change and place it before
  P3.

Node `>=22` matches the known package floor; Node `>=24` intentionally aligns
local hooks with P1's exact validation major. Either can be coherent if chosen
once and tested at the selected minimum plus Node 24. Do not keep Node 20
guards with an unsupported installed tree.

### C-11: Execute the staged-lint API contract

**Disposition: Confirmed. Impact: High.**

The outer and nested npm scripts never invoke
`lint-staged-markdown.mjs`. That script dynamically imports the programmatic
`main` export and passes staged/index bytes through `nonFileContents`. Current
0.23.2 still exposes both surfaces, but static presence is not behavioral
compatibility.

Add isolated tests for:

1. no staged Markdown;
2. compliant staged Markdown;
3. noncompliant staged Markdown with lint exit 1 and an exact rule/path;
4. differing index and working-tree bytes, proving index bytes are linted; and
5. the selected minimum Node major and Node 24.

Use a disposable clone/worktree or isolated index, check every Git/Node exit,
run on Windows and Linux, and distinguish startup exit 2 from an expected lint
failure.

### C-12: Replace the nonexistent negative-fixture claim

**Disposition: Confirmed. Impact: High for regression evidence.**

P3 says to run existing positive and negative samples and requires existing
negative fixtures to fail correctly. The live `samples` directory has only:

- `test-nested-markdown-linting.md`; and
- `test-recursive-nested-markdown.md`.

No `samples/test-violations-recursive.md` or other tracked negative fixture
exists. Add a reviewed tracked fixture to P3's scope or create deterministic
temporary outer and nested violations during validation and remove them in
`finally`. Require exact expected rule, file, and nested-depth/context
diagnostics; an import/startup error must not count as a passing negative test.

### C-13: Define how P3 supersedes P1/P2 intermediate gates

**Disposition: Confirmed. Impact: Medium to high.**

P1 intentionally requires exactly one Dependabot entry and a six-file
implementation path set. P3 intentionally adds a second entry and changes a
different path set. Therefore P3's blanket acceptance statement that “P1 and
P2 validation remain green” is literally false if it includes those
implementation-time gates.

State that all nonsuperseded generator, workflow, permissions, action pins,
helper/harness, artifacts, and lint behaviors remain green. Explicitly
supersede P1's one-entry Dependabot check and P1/P2 implementation-time path
sets with P3's final checks.

Add an exact normalized-content validator for the two-entry final
`.github/dependabot.yml`. It must reject loss/duplication of either entry,
other ecosystems/directories, wrong schedules, and auto-merge/auto-approval in
the changed scope.

### C-14: Structure residual-advisory dispositions

**Disposition: Confirmed. Impact: High if any residual is accepted.**

P3 promises an owner, dependency path, expiration/review date, and follow-up
issue, but its copyable verifier accepts only an array of URL strings. It
cannot prove those fields, expiry, uniqueness, or applicability.

Use structured records containing exact advisory URL, affected package/path,
owner, invariantly parsed UTC expiration date, and real follow-up issue URL.
Reject duplicate/empty/expired records, derive the approved URL set from them,
require exact equality with current moderate/high/critical results, and reject
any record after the audit becomes clean. Preserve the records in durable
issue/PR evidence.

If approval remains manual, narrow the mechanical claim instead of saying the
URL-only script validates facts it cannot represent.

### C-15: Treat every advisory URL as dynamic evidence

**Disposition: Confirmed. Impact: Medium.**

P3's seven-node severity baseline remains accurate and useful as a dated
comparison. Its References list only six individual advisory URLs—effectively
a representative subset—while the current audit returns 14 distinct URLs from
object-valued `via` records. The omission is acceptable only if References are
explicitly illustrative and implementation evidence records the complete
current result, including multiple advisories on one package and string-valued
dependency links.

Do not freeze today's 14 URLs as the future oracle. Capture the complete audit
at implementation time and compare it with the dated baseline.

### C-16: Retain P1 → P2 → P3 and record blocked-by relationships

**Disposition: Confirmed and substantially already encoded. Impact: Medium
coordination.**

P2 and P3 already contain dependency callouts requiring real blocked-by
relationships after filing. Preserve them and add the actual issue links when
known. Do not use placeholder issue numbers.

The order keeps P1/P2 on one dependency baseline and isolates the pre-1.0
package migration. That is a sound default under the prompt's sequential
assumption.

### C-17: Coordinate P1/T1 without a runtime dependency

**Disposition: Confirmed and partially satisfied. Impact: Medium.**

P1 already states that helpers remain repository-local and that P1 must not
depend on TerraformStyleGuide changes. Preserve that boundary.

Complete the coordination through the corrected helper matrix and new
generator matrix: whichever implementation starts second rereads the current
first contract and records intentional differences. A future shared package or
action needs separate versioning, provenance, immutable consumption, rollout,
and failure-mode design; it should not be introduced implicitly by P1.

### C-18: Keep T2 provider-recovery content out of P2/P3

**Disposition: Confirmed and already satisfied. Impact: Scope guard only.**

Nothing in current P2 or P3 imports T2's S3, Azure, GCS, or HCP recovery work.
No draft change is required. Preserve the distinction: P2/T2 are analogous
only as documentation issues that follow their own deterministic-generator
prerequisites.

### C-19: Define a policy-driven ordering exception

**Disposition: Conditionally confirmed. Impact: Potentially high, but no
current policy violation was established by the supplied material.**

It is valid to say that an actual policy forbidding known high-severity
findings would override the assumed order. In that event, perform the
dependency/hook remediation first and rebaseline P1/P2 after it merges.

Do not reorder the slate solely because such a policy might exist. Confirm the
repository/organization policy and record the exception if it applies. The
known advisories still deserve explicit risk ownership while P1/P2 are open.

## Independent findings

### I-P1-01: P1's action-pin verifier accepts an arbitrary SHA/comment pair

**Severity:** High for the claimed executable provenance gate.

P1 defines exact approved action repositories, SHAs, and release comments, but
its copyable “Verify review-only update governance and immutable action pins”
block checks only this general shape:

```text
uses: <anything>@<40 lowercase hex> # v<integer>.<integer>.<integer>
```

A wrong commit, mismatched release comment, unexpected external action, or
substituted repository can satisfy that regex. Manual static inspection is
listed elsewhere, but the block's heading and acceptance language imply a
stronger mechanical proof.

Replace the regex-only gate with an exact allowlist mapping:

- `actions/checkout` → approved SHA and `v7.0.1`;
- `actions/setup-node` → approved SHA and `v7.0.0`;
- `actions/upload-artifact` → approved SHA and `v7.0.1`; and
- `actions/download-artifact` → approved SHA and `v8.0.1`.

Require every nonlocal `uses:` line to match one allowed repository/SHA/comment
tuple, require every expected action to occur in its intended workflow/steps,
and reject unknown, missing, duplicate-unexpected, or malformed references.
Retain implementation-time upstream/release/runtime review; exact static
validation does not replace that review.

### I-P3-01: P3's audit verifier does not close its command/schema boundary

**Severity:** Medium to high.

P3's requested evidence includes Node and npm versions, but the copyable
validation queries only Node. It resolves `npm` without recording
`npm --version`.

The audit verifier also treats every nonzero exit the same. If the derived URL
set happens to match the allowlist, an unexpected npm error exit is not
explicitly rejected. It assumes the JSON has the expected `metadata` and
`vulnerabilities` shape without validating those members and numeric severity
counts before using them.

Require:

1. exactly one validated npm version result, recorded before and after the
   lockfile update;
2. audit exit 0 for a clean result or the one documented vulnerability exit
   for approved residual findings—every other exit fails;
3. one valid JSON object with required `metadata.vulnerabilities` and
   `vulnerabilities` members;
4. nonnegative integral severity totals consistent with the enumerated result;
5. complete URL/path extraction from object and dependency-link `via` records;
   and
6. the structured disposition equality checks from C-14.

This makes command failure, schema drift, a clean result, and an approved
residual result mechanically distinct.

## Consolidated revisions before handoff

### P1

1. Correct the two stale P1/T1 convergence rows.
2. Add the generator-specific convergence matrix.
3. Specify one journaled named cleanup function and directly test its
   fail-closed branch.
4. Assert edition/version in the same local child that runs each target.
5. Require at least one real link/reparse rejection per OS family.
6. Document the two-LF-cell pull-request harness placement as intentional, or
   choose four-cell symmetry.
7. Replace the action-pin shape regex with an exact approved tuple allowlist.

### P2

1. Refresh the concise P1 prerequisite only after P1 is final.
2. Assert Node major 24 before `npm ci` and both lint commands.
3. Remove the dead dated metadata snapshot while retaining the normative
   recalculation algorithm.

No independent content-design change is needed.

### P3

1. Resolve the Node floor across package metadata, the Husky shell guard, and
   the staged-lint implementation, expanding scope or adding a prerequisite.
2. Execute isolated staged/index behavior on Windows and Linux.
3. Add deterministic positive and negative outer/nested lint evidence.
4. Define which P1/P2 gates are preserved and which P3 supersedes.
5. Validate the exact final two-entry Dependabot file.
6. Replace URL-only residual approvals with durable structured records.
7. Validate npm version, audit exit codes, JSON shape, totals, URLs, and
   dependency paths.
8. Treat the dated seven-node/14-current-URL observations as comparison
   evidence, not a frozen implementation oracle.

## Strengths to preserve

- Embedded H1 issue titles and P1/P2/P3 terminology.
- Repository-generic, portable guidance.
- Existing PSStyleGuide `.gitattributes` preserved.
- Final-payload normalization and BOM-less resolved-path serialization.
- P1's held-stream archive identity and explicit `FileShare.Read`.
- Complete path-envelope validation and honest no-competing-writer model.
- Immutable artifact ID/digest propagation and native fail-closed download.
- Stable fixture IDs and case-specific destination postconditions.
- Four-cell push validation, read-only approval, and one exact-lease writer.
- P2's visible four-middle-dot `text` visualization and no trailing whitespace.
- P2's exact canonical-snippet and rationale nonduplication validation.
- P3's deliberate release/lockfile review, no `npm audit fix --force`,
  review-only Dependabot intent, and clean-install/full-tree audit direction.

## Validation performed for this review

- Resolved live `franklesniak/PSStyleGuide` `main` through the connected GitHub
  repository and confirmed its ref at `4346310e7deebffb4159c75e30d9546263dfd649`.
- Inspected the live generator, workflows, package manifest/lockfile, staged
  hook/implementation, guide examples, rationale heading, and sample tree.
- Re-ran the lockfile-only moderate-threshold audit and confirmed the
  0/5/2/0 severity counts and seven affected package nodes.
- Verified all four selected action commits and relied-on action metadata in
  their official repositories.
- Verified the current and proposed markdownlint engine requirements, 0.23.0
  Node-support change, and 0.23.2 programmatic `main`/`nonFileContents`
  surface from upstream sources.
- Parsed all 15 PowerShell fences across P1/P2/P3 in both Windows PowerShell
  5.1 and PowerShell 7. Syntax success does not substitute for the missing
  behavioral tests identified above.

## Primary references

- [PSStyleGuide live baseline](https://github.com/franklesniak/PSStyleGuide/commit/4346310e7deebffb4159c75e30d9546263dfd649)
- [Live staged Markdown hook](https://github.com/franklesniak/PSStyleGuide/blob/4346310e7deebffb4159c75e30d9546263dfd649/.husky/pre-commit)
- [Live staged Markdown implementation](https://github.com/franklesniak/PSStyleGuide/blob/4346310e7deebffb4159c75e30d9546263dfd649/.github/workflows/lint-staged-markdown.mjs)
- [`markdownlint-cli2` 0.23.2 package metadata](https://github.com/DavidAnson/markdownlint-cli2/blob/v0.23.2/package.json)
- [`markdownlint` 0.41.1 package metadata](https://github.com/DavidAnson/markdownlint/blob/v0.41.1/package.json)
- [`markdownlint-cli2` 0.23.2 programmatic API](https://github.com/DavidAnson/markdownlint-cli2/blob/v0.23.2/markdownlint-cli2.mjs#L881)
- [`markdownlint-cli2` changelog](https://github.com/DavidAnson/markdownlint-cli2/blob/v0.23.2/CHANGELOG.md)
- [Node.js release status](https://nodejs.org/en/about/previous-releases)
- [npm audit documentation](https://docs.npmjs.com/cli/v11/commands/npm-audit)
- [GitHub Dependabot options](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference)
