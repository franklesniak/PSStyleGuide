# TerraformStyleGuide T1/T2 slate criticism

## Overall assessment

The revised slate is much closer to implementation-ready. T1 now gives
TerraformStyleGuide a credible deterministic-generation and artifact-boundary
design, and T2 builds on it in the right order. Several material defects from
the earlier drafts are resolved:

- T1 hashes and reads the ZIP through one retained `FileStream` opened with
  `FileShare.Read`.
- T1 defines journaled, nonrecursive, fail-closed cleanup and exercises the
  exact production cleanup function with an unsafe-state fixture.
- T1 uses the current checkout, setup-node, upload-artifact, and
  download-artifact full-SHA pins selected by P1.
- T1's local validation binds each child process to Desktop exactly 5.1 or
  Core major 7 instead of trusting executable names.
- T1's rejection postconditions now distinguish initially absent,
  pre-existing, helper-created, and unsafe destination states.
- T1 now defines a concrete generator-convergence matrix and an
  implementation-time first/second-mover evidence record.
- T1 now gives the future npm-remediation issue a substantially stronger
  package/Node/hook/audit/Dependabot ownership contract, and T2 reflects it.
- T2 states the S3 Versioning prerequisite precisely, including pre-enable
  `null` versions, suspended buckets, retention, and owner/administrator
  evidence.
- T2 makes `set +x` the first command in the HCP subshell and requires a
  synthetic inherited-xtrace test.
- T2 lists the complete seven-file T1 implementation boundary.
- T2 now derives its guide version at implementation time instead of carrying
  the stale `2.7.20260728.0` example.

Do not regress those corrections.

The remaining work is concentrated rather than architectural. T1 still
preserves an end-of-life installed Node version, leaves caller-owned temporary
root creation underspecified, promises stable harness IDs without assigning
them, never gives its production cleanup function the exact name its harness
must call, validates action pins by shape instead of by approved tuple, and
normalizes writer inputs less rigorously than P1. Its cross-repository text also
now covers generator convergence but leaves the helper contract hypothetical.
The proposed slate is incomplete until the npm-remediation issue required by
both T1 and T2 exists as a real, Terraform-specific T3; detailed requirements
embedded in T1 are not a substitute for the issue itself. T2 still needs a
closed HCP host contract, positive page and safe curl-config value validation,
explicit scope language, executable non-network tests for all four shell
examples, and an exact merged-runtime boundary around its local npm validation.

The preferred order remains T1, T2, then T3, provided T1 takes ownership of
installing Node 24 while leaving package, lockfile, hook-floor, and advisory
changes to T3. If policy requires advisory remediation first, use T3, T1, T2
and rebaseline both later issues after T3 merges. This policy gate should be
resolved when the issues are filed and again when implementation starts; it is
not a reason to reorder speculatively.

## Evidence baseline

This review compared:

- the revised [PowerShell P1](../PSStyleGuide/01PSStyleGuideP1.md),
  [PowerShell P2](../PSStyleGuide/02PSStyleGuideP2.md), and
  [PowerShell P3](../PSStyleGuide/03PSStyleGuideP3.md);
- the proposed [Terraform T1](./03TerraformStyleGuideT1.md) and
  [Terraform T2](./04TerraformStyleGuideT2.md), synchronized in this planning
  repository at `a1970768eb27fd8c71800253f38af9b69185a33f`;
- TerraformStyleGuide `main` at
  [`6ee3f57b2b71b885a5927b770dde47532944de62`](https://github.com/franklesniak/TerraformStyleGuide/commit/6ee3f57b2b71b885a5927b770dde47532944de62);
- the live generator, workflows, source documents, generated documents,
  package manifest, and lockfile at that commit; and
- the primary references linked below.

At that commit, `.gitattributes` and `.github/dependabot.yml` are absent, the
generator has four `Set-Content -Encoding UTF8 -NoNewline` serialization
boundaries, and both workflows use moving action tags. The build workflow has
path filters and workflow-level `contents: write`; the Markdown workflow
installs Node 20. The package has no `engines.node`, and the Husky hook has no
Node-major guard. TerraformStyleGuide also has no PSStyleGuide-style
`lint-staged-markdown.mjs`, so a future T3 must test TerraformStyleGuide's
actual full-lint hook rather than copying P3's staged-content design. A fresh
`npm audit --package-lock-only --audit-level=moderate --json` on 2026-07-29
reports zero critical, five high, two moderate, and zero low vulnerability
nodes: `brace-expansion`, `js-yaml`, `linkify-it`, `markdown-it`,
`markdownlint-cli2`, `minimatch`, and `picomatch`. Its object-valued `via`
records currently expose 14 distinct advisory URLs. Seven package nodes and 14
URLs are different measures and both are time-stamped evidence, not future
acceptance constants.

The current action baseline in T1 is:

- checkout v7.0.1 at
  `3d3c42e5aac5ba805825da76410c181273ba90b1`;
- setup-node v7.0.0 at
  `820762786026740c76f36085b0efc47a31fe5020`;
- upload-artifact v7.0.1 at
  `043fb46d1a93c77aae656e7c1c64a875d1fc6a0a`; and
- download-artifact v8.0.1 at
  `3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c`.

Those pins are current for this review and remain subject to T1's required
implementation-time reverification. Do not describe them as stale merely
because the live repository still uses v4 tags.

All five T1 PowerShell fences and all three T2 PowerShell fences parse in both
Windows PowerShell 5.1 and PowerShell 7. All seven T2 Bash fences pass
`bash -n`. These are syntax checks, not behavioral evidence.

## Findings

### T1-1: The action pins are current, but the installed Node target is not

**Severity:** High and time-sensitive

T1 correctly separates an action's own Node runtime from the Node version that
`setup-node` installs for Markdown lint. It then preserves the live workflow's
Node 20 behavior and prohibits changing “the Node version.” That is no longer a
safe baseline: the
[Node release table](https://nodejs.org/en/about/previous-releases) marks Node
20 end-of-life and Node 24 LTS.

P1 resolves the ownership boundary cleanly by establishing Node 24 before its
later package remediation. T1's new linked-issue contract instead assigns the
Markdown workflow's Node selection to T3 while retaining the default order T1,
T2, T3. Those two decisions are incompatible now that Node 20 is already EOL:
the default order would knowingly implement and validate two issues on the
retired runtime.

The smallest default-order correction is for T1 to own only the workflow
runtime selection because it already modifies `markdownlint.yml`; T3 can still
own the package manifest, lockfile, hook floor, and advisory remediation.
Updating the installed major does not authorize an incidental dependency
upgrade.

T1 should require:

- `node-version: '24'`;
- `package-manager-cache: false`;
- a clean, CI-mode `npm ci`;
- the existing outer and nested lint commands;
- local and hosted evidence that the lint process actually uses Node major 24;
  and
- continued exact-SHA action validation with adjacent release comments.

Keep the four current action selections unless the implementation-time check
finds a newer required release. Remove only the Node-preservation language, not
the package/lockfile and lint-rule boundaries.

If T1 will not own Node 24, then the now-specified T3 must be drafted, include
`markdownlint.yml`, run before T1, and force T1/T2 to be rebaselined. Leaving
Node 20 until an unfiled issue runs after T2 is not acceptable.

**Required revision:** Either make Node 24 and disabled automatic
package-manager caching part of T1's workflow, validation, acceptance, and T2
prerequisite contracts while keeping dependency changes in T3, or file and
execute T3 first and rebaseline T1/T2. Do not retain both T3 ownership and the
T1 → T2 → T3 default order.

### T1-2: The caller-owned trusted-root factory is still undefined

**Severity:** High

T1's helper-side lifecycle is now strong: it journals owned objects, deletes
only revalidated ordinary entries nonrecursively, retains unsafe state, and
preserves primary plus cleanup failures. The remaining gap is earlier in the
lifecycle. Windows cells, the writer, and harness consumers are told to create
“one unique trusted temporary root,” but there is no normative factory that
makes uniqueness and ownership true.

Every production consumer should use the same topology:

1. normalize the runner-controlled temporary parent;
2. generate a high-entropy child with
   `[System.IO.Path]::GetRandomFileName()`;
3. prove the child is absent;
4. create it without `-Force`;
5. verify the result is one ordinary, non-reparse directory;
6. retry a documented bounded number of times only for a proven name
   collision, failing every other error;
7. create a separate download child and initially absent candidate topology
   beneath it; and
8. pass absolute paths forward rather than reconstructing them from names.

`GetRandomFileName()` does not create anything, while directory-creation APIs
may return an existing directory. The absence/create/verify sequence is
therefore part of the security contract.

The caller should own root teardown in `finally` after all streams are
disposed. It must revalidate the envelope, remove only known ordinary files
and empty directories, never recurse through an unexpected entry, and surface
cleanup failure without hiding the primary failure. The permanent harness may
encapsulate the same topology for its own fixtures, but no consumer may weaken
the normative algorithm or substitute a fixed/pre-existing child.

**Required revision:** Define and reuse one bounded-retry trusted-root
factory/output/teardown contract in every helper consumer, controlled drill,
and relevant acceptance criterion.

### T1-3: The harness promises stable IDs but still groups distinct cases

**Severity:** High

T1 now has coherent case-specific destination oracles, separate BOM and CR
rows, and an excellent direct unsafe-cleanup fixture. Preserve those changes.

The table nevertheless says that stable case identifiers are mandatory while
its first column contains only prose fixture classes. It also groups distinct
executable permutations:

- missing and extra entries;
- exact duplicates and case-only collisions;
- forward-slash and backslash nesting;
- forward and backward traversal;
- leading slash, leading backslash, and drive qualification;
- directory entries and file/directory collisions;
- existing files and existing directories;
- links and dangling links;
- equal roots and each contains-the-other direction;
- relative paths and non-filesystem providers; and
- root links and ancestor links.

Grouped cases make failure attribution, platform skips, and future parity
comparison unreliable. Optional-label evidence is also asymmetric: there is a
success with labels omitted and a failure with labels supplied, but no failure
with all labels omitted that proves the `unavailable` diagnostic fallback.
The single explicitly-empty row should become three separately identified
cases, one for each optional label.

Use a stable-ID column and give each permutation its own row. Match P1's
diagnostic symmetry:

- one induced failure with three distinct supplied sentinels;
- one equivalent failure with all labels omitted, requiring `unavailable`;
  and
- separate explicit-empty cases for `ArtifactId`, `RunId`, and `RunAttempt`.

Every row should name the expected phase, platform/precondition, diagnostic
fragments, initial state, final state before harness teardown, and whether the
ZIP may have been constructed. Keep T1's stronger four-cell helper coverage if
the CI cost is intentional, but label it as a Terraform-specific choice.

**Required revision:** Replace grouped fixture classes with individually
addressable stable IDs and add the missing omitted-label failure case without
weakening the corrected lifecycle oracles.

### T1-4: Writer inputs are not normalized to P1's one-read contract

**Severity:** Medium to high

The writer's remote observation, native full object-ID proof, exact staged-path
set, blob comparisons, explicit refspec, exact expected-SHA lease, single-parent
proof, and no-retry policy are strong.

Its input boundary is weaker. T1 copies `TARGET_REF` and `EXPECTED_SHA`, checks
only nonemptiness and a `refs/heads/` prefix, then compares them with ambient
`GITHUB_REF` and `GITHUB_SHA`. It does not reject leading/trailing whitespace
or CR/LF, call `git check-ref-format`, or make all four environment reads
one-time reads.

Match P1 by requiring the writer to:

1. copy `TARGET_REF`, `EXPECTED_SHA`, `GITHUB_REF`, and `GITHUB_SHA` into
   distinct locals at the first executable boundary;
2. reject missing/empty values, leading/trailing whitespace, and CR/LF;
3. require the complete target to begin with `refs/heads/` and pass
   `git check-ref-format`;
4. compare only the normalized locals;
5. reuse those unchanged locals for checkout, remote, parent, lease, and
   destination-refspec proofs; and
6. never read those four environment variables again.

Controlled stale-ref and lease tests should alter purpose-specific test locals,
not weaken or repurpose the production environment contract.

**Required revision:** Adopt P1's complete one-read normalization contract
while preserving T1's stronger remote, blob, parent, and lease proofs.

### T1-5: The directly tested cleanup function is never actually named

**Severity:** High

T1 requires the production failure path and deterministic unsafe-cleanup
fixture to call “one named cleanup function,” but it never supplies that name.
The implementer can therefore choose one identifier in the helper, a different
one in the harness, or satisfy the prose with an ad hoc wrapper. T2 then repeats
the phrase “exact named production cleanup function” without a resolvable
contract.

Match P1 and name the function
`Remove-StyleGuideCandidateInvocationState`. Require:

1. that exact function to contain the only production cleanup implementation;
2. the production failure path to invoke it after entry streams, the
   `ZipArchive`, and the retained archive stream are disposed;
3. the helper's ordinary dot-source behavior to load definitions and return
   before main execution, without a test switch or alternate public expansion
   interface;
4. the mandatory unexpected-ordinary-child fixture to dot-source the exact
   resolved helper and call this function directly; and
5. static and behavioral evidence that the harness does not copy cleanup logic
   or call a test-only wrapper.

Resolve the helper and harness to ordinary, non-reparse absolute files before a
child process runs. Pass those paths as data to the fixed child command, as P1
does, rather than relying on the child's inherited current directory.

**Required revision:** Put the exact production function and resolved-file
identity into T1's lifecycle, harness, local-validation, and acceptance
contracts, then make T2 refer to that concrete contract.

### T1-6: The action-pin verifier accepts unreviewed full-SHA tuples

**Severity:** High

T1 selects the same four reviewed action releases as P1, but its validation
only requires a 40-hex value and a nonempty adjacent version comment. That
shape check would accept an arbitrary repository, an unreviewed commit in an
approved repository, or a false version comment.

Use an exact local allowlist keyed by repository:

- `actions/checkout` →
  `3d3c42e5aac5ba805825da76410c181273ba90b1`, `v7.0.1`;
- `actions/setup-node` →
  `820762786026740c76f36085b0efc47a31fe5020`, `v7.0.0`;
- `actions/upload-artifact` →
  `043fb46d1a93c77aae656e7c1c64a875d1fc6a0a`, `v7.0.1`; and
- `actions/download-artifact` →
  `3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c`, `v8.0.1`.

Parse every nonlocal `uses:` line into repository, SHA, and release comment.
Reject unknown repositories, mismatched tuples, and use in an unapproved
workflow. Require checkout in both workflows, setup-node only in
`markdownlint.yml`, and the required upload/download roles in `build.yml`.
Keep the separate implementation-time upstream release and action-metadata
review; the local allowlist proves the checked-in tuple, not continued
freshness.

**Required revision:** Replace the shape-only inspection with P1's exact
repository/SHA/version/workflow-role validator and make the acceptance language
say “approved tuple,” not merely “approved full SHA.”

### T1/T2-1: Helper convergence is still hypothetical and T2 duplicates T1

**Severity:** Medium

T1's new generator matrix is the right model and should be preserved. It
defines shared serialization algorithms, identifies repository-specific
frontmatter/content, avoids a runtime dependency, and gives the second mover an
explicit drift record.

The helper introduction still uses the older hypothetical wording: its rules
govern “even if” P1 has not adopted the same full-component contract, followed
by a future comparison instruction. P1 now has a concrete helper convergence
matrix, and the two drafts already agree on the held-stream and full-component
models. Replace this remaining prose with a reciprocal current matrix:

| Helper/workflow surface | Required cross-repository treatment |
| --- | --- |
| Public parameters | Same five mandatory names and three diagnostic labels |
| Archive identity | Same retained-stream hash/compare/rewind/ZIP lifetime |
| Path security | Same explicit roots, component checks, containment, and no-competing-writer model |
| Manifest | Same exact-set rules; repository-specific filenames |
| Lifecycle | Same journaled cleanup, exact cleanup-function name, and case-specific postconditions |
| Diagnostics | Same label semantics, phase naming, and safe context |
| Fixtures | Stable comparable IDs; repository-specific manifest values where needed |
| Artifact transport | Same immutable ID/digest propagation and native digest rejection |
| Pull-request placement | Record T1's all-four-Windows-cell helper suite versus P1's two-LF-cell choice as intentional if the extra T1 coverage is retained |

Document every intentional difference beside the helper matrix and use the same
first/second-mover evidence rule as the generator matrix. Repository-local
scripts, manifests, workflow artifact names, and source transforms remain
appropriate; a shared package, module, submodule, or reusable action is not a
prerequisite.

T2's prerequisite grew further in `a197076`. It is accurate as a snapshot,
including the generator handoff and future npm-issue responsibilities, but it
duplicates many pages of T1 behavior and will drift as T1 or the not-yet-filed
T3 changes. After T1 is final, reduce T2 to a concise invariant summary,
normative relative links to T1 and the real T3, and a requirement to verify
their merged implementations. T1/T3 should remain the sources of truth.

**Required revision:** Preserve T1's new generator matrix, replace the helper's
remaining hypothetical prose with a reciprocal current matrix, and make T2
reference final T1/T3 rather than freezing their implementation
specifications.

### T1/T2-2: The required npm-remediation issue does not exist

**Severity:** High for slate completeness; not a reason to expand T1 or T2

T1 and T2 now contain a useful seed specification for this work: final
package/Node/workflow/hook policy, isolated real-hook evidence, structured
residual risk, Dependabot final state, and supersession are all assigned to the
future issue. Preserve that design direction.

They also correctly say a comment, placeholder, or unlinked draft is
insufficient. T1 cannot close, and T2's prerequisite cannot be satisfied,
because this planning directory still contains no real T3 issue description.
Embedding increasingly detailed T3 prose inside T1/T2 does not create an
independently fileable, orderable, reviewable issue.

Add `05TerraformStyleGuideT3.md` with an H1 issue title following the existing
issue-description convention, for example:

```markdown
# Remediate Markdown lint dependency advisories and add npm update governance
```

T3 should own:

- `.github/workflows/package.json`;
- `.github/workflows/package-lock.json`;
- `.husky/pre-commit`, to align its admitted Node floor and guard message with
  the selected package tree;
- the npm entry for `/.github/workflows` in `.github/dependabot.yml`;
- one tracked, cross-platform Markdown integration harness;
- the harness invocation in `.github/workflows/markdownlint.yml` after clean
  installation, while establishing exact hosted Node 24 and preserving T1's
  action pins, permissions, triggers, cache setting, and existing lint
  commands; and
- `lint-nested-markdown.js` only if a reviewed package/API compatibility change
  actually requires it.

T3's implementation contract should require:

- implementation-time Node and npm versions plus a fresh normalized audit
  graph containing severity counts, every affected package node, each
  object-valued advisory URL/severity/range, every string-valued `via` link, and
  every normalized `npm explain --json` dependency path;
- deliberate updates to the smallest coherent direct-dependency set;
- complete lockfile review, including registries, Git/local dependencies,
  scripts, integrity values, and engine changes;
- `package.json` `engines.node` and the Husky guard set to the highest minimum
  Node major required by the final selected tree, currently expected to be
  Node 22 for the known candidate, while hosted full-corpus validation remains
  exact Node 24;
- clean Node 24 `npm ci` and `npm ls --all`;
- the actual TerraformStyleGuide hook/full-lint surface under the selected
  minimum and Node 24; and
- existing positive samples plus harness-generated temporary outer and nested
  violations proving exact lint-rule failure rather than tooling startup
  failure.

Do not copy P3's `lint-staged-markdown.mjs` requirements: that file and API
surface do not exist in TerraformStyleGuide. The tracked harness should instead
exercise the exact Husky hook's current contract: no staged Markdown exits
zero; staged Markdown runs both repository lint commands; compliant content
passes; deterministic temporary outer and nested violations fail for the
expected rules; and tooling/configuration failure cannot masquerade as an
expected lint rejection. Remove T1's “documented equivalent evidence” escape
hatch for the installed-hook smoke test: run at least one real Git-triggered,
Husky-installed invocation in the disposable repository, in addition to direct
deterministic harness cases.

Follow P3's security model: no `npm audit fix --force`, no auto-merge, no frozen
future advisory count, and no blanket acceptance of residual
moderate-or-higher findings. T1's seed contract still needs the command/schema
boundary made explicit: record the npm version; run
`audit --package-lock-only --audit-level=moderate --json`; accept only clean
exit 0 or the documented vulnerability exit; reject every command/registry
failure; validate `metadata.vulnerabilities` plus nonnegative internally
consistent counts; walk both object advisories and string-valued `via` links;
and bind every affected package to normalized `npm explain --json` paths.

Accept the vulnerability exit only when structured inline records exactly
match the current advisory URL/package/normalized-path graph. Each residual
record needs a named owner, future UTC expiry, real follow-up issue, and
reachability/mitigation rationale; duplicate, missing, unexpected, expired, and
clean-result-stale records must fail. Prefer the exact two-entry review-only
Dependabot state used by P3. If an applicable repository policy rejects npm
Dependabot, cite that policy and mechanically validate the retained exact
one-entry state; do not leave the choice to implementer preference.

Link T3 from T1 and T2 and state the final ordering. If T1 adopts finding T1-1
and owns the Node 24 workflow baseline, the default remains T1, T2, T3. If Node
selection remains in T3 or policy forces advisory remediation first, the
coherent order is T3, T1, T2, followed by rebaselining T1/T2 against the merged
package, Node, hook, workflow, Dependabot, and lockfile state.

**Required revision:** Draft, name, order, and reciprocally link a real T3
before treating this as a complete sequential slate. Base it on P3's audit and
governance rigor, but use TerraformStyleGuide's full-lint Husky surface rather
than importing PSStyleGuide's staged-content implementation.

### T2-1: The HCP block still has endpoint and input-grammar gaps

**Severity:** High

The inherited-xtrace defect is fixed: `set +x` is now the first subshell
command, and T2 requires a synthetic sentinel test. Preserve that exact
ordering and do not re-enable tracing.

Three independent gaps remain:

1. The request URL is hardcoded to `app.terraform.io`, excluding
   [HCP Terraform Europe](https://developer.hashicorp.com/terraform/cloud-docs/europe)
   at `app.eu.terraform.io`.
2. `TFC_PAGE_NUMBER=${TFC_PAGE_NUMBER:-1}` supplies a default but accepts
   non-decimal, zero, negative, whitespace-bearing, and control-bearing input.
3. A merely nonempty token is interpolated into a quoted, line-oriented curl
   config entry. Double quotes, backslashes, CR, LF, or other control
   characters can change that representation. Curl's header handling is not a
   sanitizer.

Introduce a nonsecret host selector and accept exactly:

- `app.terraform.io`; and
- `app.eu.terraform.io`.

Reject every other host before token expansion or response-file creation, then
construct the fixed HTTPS API URL from the accepted value. Do not accept an
arbitrary URL or generic `TFC_ADDRESS`; that would turn a typo or hostile
environment value into a bearer-token destination. State that Terraform
Enterprise is out of scope. Enterprise support would need a separate
certificate, redirect, trust, and token-destination contract.

Require the page number to be a canonical positive decimal integer before
creating the response file. Keep page size 100, the exact organization,
workspace, and `finalized` filters, and continuation until
`meta.pagination.next-page` is `null`.

Define the curl-config value grammar exactly. At minimum, reject CR, LF,
double quote, backslash, and other control characters before opening the
response file, unless the issue instead specifies and tests an encoding that
is safe under curl's documented config grammar. Do not invent an unnecessarily
narrow complete token regex without a normative HashiCorp token grammar.

The synthetic test must cover both allowed hosts; arbitrary/scheme/path host
inputs; valid and invalid pages; and config-breaking token values. Rejections
must occur before file creation, stub invocation, or token disclosure.

**Required revision:** Add closed US/Europe host selection, explicit Enterprise
scope, canonical positive-page validation, and a tested safe curl-config value
contract while preserving first-command `set +x`.

### T2-2: The state-safety quantifier exceeds the issue inventory

**Severity:** Medium

T2 changes four provider/API recovery blocks, but some acceptance and security
language says “every recovery destination” or speaks universally about state
handling. The live source documents also contain nearby state operations that
are not in T2's requested changes, including local `terraform state pull`
backups, backup inspection, `terraform state push`, state removal, another S3
version listing, and manual corruption/reconstruction guidance.

Choose one scope:

1. inventory and harden every backup, discovery, inspection, recovery, and
   destructive state example in both source documents; or
2. limit T2 explicitly to the four named S3, Azure, GCS, and HCP blocks,
   narrow every universal acceptance statement, and create a follow-up issue
   with the omitted source locations.

The second option better matches T2's title and six-file implementation
boundary. Keep the provider-neutral sensitive-state warning, but do not imply
that untouched adjacent examples gained protections.

**Required revision:** Add a complete state-operation inventory or narrow the
quantifier to the four modified blocks and record the remainder as explicit
follow-up.

### T2-3: Only the HCP xtrace behavior is executed

**Severity:** Medium to high

The current validation plan reviews the four shell blocks and executes a
focused HCP xtrace stub. It does not require `bash -n` or behavioral tests for
the shared destination guards, literal argument boundaries, provider flags,
HCP host/page/config rejection, or no-overwrite behavior.

Require a temporary, non-network implementation harness that extracts the
exact blocks intended for publication and:

- runs `bash -n`;
- stubs `aws`, `az`, `gcloud`, and `curl`;
- rejects missing, empty, relative, existing-file, existing-directory,
  symbolic-link, and dangling-link destinations before provider invocation;
- proves paths with spaces and shell metacharacters remain one literal
  argument;
- proves version IDs and generations reach the stub unchanged;
- proves exact-object filters and Azure/GCS no-overwrite flags;
- proves no example overwrites an existing local entry;
- covers S3's documented versioning evidence paths;
- tests both allowed HCP hosts and all rejected host classes;
- tests positive and invalid page values;
- tests config-breaking token values;
- retains the existing inherited-xtrace sentinel test; and
- simulates curl failure and verifies that the protected partial response is
  retained and clearly invalid.

The harness may remain outside the repository so it does not expand T2's
six-file implementation set. It must prohibit network access, capture exact
argument vectors and outputs, and assert the expected rejection reason rather
than treating any nonzero result as success.

**Required revision:** Make executable non-network syntax and behavioral
evidence for all four published blocks an acceptance prerequisite.

### T2-4: Local npm validation does not establish the T1 runtime boundary

**Severity:** Medium to high

T2's validation runs ambient `npm` directly and never queries `node`. Once T1
owns exact hosted Node 24, a contributor can still validate T2 under an
unsupported or behaviorally different local major and report success. The
block also does not resolve one Node/npm application pair or set and restore
`CI` around `npm ci`.

Mirror P2's corrected prerequisite and validation boundary:

1. keep the prerequisite concise and link normatively to final T1;
2. resolve exactly one `node` application and one `npm` application;
3. query `process.versions.node` and require exact major 24 before installation
   or lint;
4. record `npm --version` and reuse the same resolved npm path;
5. set `CI=true` only around `npm ci`, restoring the prior environment state in
   `finally`; and
6. run the unchanged outer and nested lint commands through that resolved npm
   executable.

This remains a T2 validation change, not permission to update the dependency
tree. If policy caused T3 to run first, T2 must instead assert the
implementation-time runtime/package contract produced by that merged issue.

**Required revision:** Make T2's local install/lint evidence prove the exact
merged runtime contract rather than inheriting whatever Node/npm happens to be
on `PATH`.

## Confirmed strengths to preserve

- T1 then T2 is the correct dependency direction.
- T1 correctly identifies all four generator serialization boundaries and
  leaves the already-correct LF-joined frontmatter construction alone.
- T1's generator-convergence matrix now clearly separates shared algorithms
  and byte contracts from repository-specific content and avoids a runtime
  dependency.
- The helper's explicit roots, full-component checks, strict containment,
  repeated validation, and documented no-competing-writer model are strong.
- The five mandatory helper parameters and three optional diagnostic labels
  intentionally match P1.
- The held `FileShare.Read` stream now binds the accepted digest to the exact
  ZIP instance consumed through extraction.
- T1's journaled cleanup, direct unsafe-state production-function fixture, and
  case-specific postconditions resolve the earlier lifecycle contradiction;
  the remaining problem is contractual naming and exact file/function identity.
- The permanent harness, immutable artifact ID/digest, download-by-ID,
  malformed-transport drill, diagnostic artifacts, and edition/EOL matrix are
  sound design choices.
- T1's selected full-SHA action tuples, local child edition assertions, exact
  remote observation, complete object IDs, blob proofs, explicit refspec,
  exact lease, single-parent proof, and no-retry rule should remain. Strengthen
  the validator without replacing the reviewed selections.
- Review-only weekly GitHub Actions Dependabot governance does not replace
  immutable pins or human review.
- T1/T2's expanded future npm-issue ownership correctly recognizes the
  Terraform repository's full-lint Husky surface instead of copying
  PSStyleGuide's staged-content API, which does not exist in
  TerraformStyleGuide.
- T2 correctly separates discovery from recovery and requires deliberate
  identifier selection.
- T2's S3 prerequisite now distinguishes enabled and suspended versioning,
  pre-enable `null` versions, lifecycle retention, and delegated evidence.
- T2's exact-key provider filters, Azure non-HNS scope and
  `--overwrite false`, GCS Object Versioning/soft-delete distinction and
  `--no-clobber`, and HCP `/state-versions` filters are well researched.
- The HCP first-command `set +x`, `curl -q --config -`, pre-opened noclobber
  descriptor, restrictive `umask`, explicit failure handling, and retention of
  invalid partial output form a strong base once the remaining input contracts
  are closed.
- T2's complete seven-file T1 non-goal boundary is accurate.
- T2's versioning section now uses only the implementation-time algorithm.
- State and Archivist URLs remain treated as sensitive, and no example
  automatically selects or rolls back a version.

## Recommended final slate

1. Revise T1 to install and prove Node 24 while retaining its current action
   selections and leaving package/lockfile changes to T3.
2. Define and reuse the caller-owned trusted-root factory and teardown.
3. Name `Remove-StyleGuideCandidateInvocationState`, resolve the exact helper
   and harness files, and make production plus the direct fixture call it.
4. Assign stable IDs to every harness permutation and add symmetric diagnostic
   cases.
5. Normalize all four writer environment inputs once.
6. Replace the shape-only action check with the exact approved
   repository/SHA/version/workflow-role validator.
7. Preserve the new generator matrix, replace the helper's hypothetical prose
   with its reciprocal current matrix, and make T2 link to final T1/T3.
8. Finish T2's HCP host, page, and curl-config value contracts.
9. Resolve T2's state-example scope and require executable non-network shell
   evidence.
10. Make T2's local npm block prove the merged Node/npm contract.
11. Add and link a real Terraform-specific T3 for advisory remediation, hook
    compatibility, regression evidence, and exact npm Dependabot governance.

With those changes, the slate supports the intended unification boundary:
observable generator, artifact, security, diagnostic, and validation contracts
converge across repositories, while scripts, manifests, source documents, and
genuinely repository-specific details remain local.

## Primary references

### Repository and generator/workflow maintenance

- [TerraformStyleGuide reviewed commit](https://github.com/franklesniak/TerraformStyleGuide/commit/6ee3f57b2b71b885a5927b770dde47532944de62)
- [Reviewed TerraformStyleGuide generator](https://github.com/franklesniak/TerraformStyleGuide/blob/6ee3f57b2b71b885a5927b770dde47532944de62/.github/workflows/Generate-StyleGuideArtifacts.ps1)
- [Reviewed TerraformStyleGuide build workflow](https://github.com/franklesniak/TerraformStyleGuide/blob/6ee3f57b2b71b885a5927b770dde47532944de62/.github/workflows/build.yml)
- [Reviewed TerraformStyleGuide Markdown workflow](https://github.com/franklesniak/TerraformStyleGuide/blob/6ee3f57b2b71b885a5927b770dde47532944de62/.github/workflows/markdownlint.yml)
- [Prompt-02 cross-repository primary-source record](../artifacts/prompt-02-primary-source-research.md)
- [Microsoft Learn: `Get-FileHash`](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/get-filehash)
- [.NET `FileStream`](https://learn.microsoft.com/dotnet/api/system.io.filestream)
- [.NET `FileShare`](https://learn.microsoft.com/dotnet/api/system.io.fileshare)
- [.NET `Path.GetRandomFileName`](https://learn.microsoft.com/dotnet/api/system.io.path.getrandomfilename)
- [Node.js release status](https://nodejs.org/en/about/previous-releases)
- [Node.js end-of-life releases](https://nodejs.org/en/about/eol)
- [checkout v7.0.1](https://github.com/actions/checkout/releases/tag/v7.0.1)
- [setup-node v7.0.0](https://github.com/actions/setup-node/releases/tag/v7.0.0)
- [upload-artifact v7.0.1](https://github.com/actions/upload-artifact/releases/tag/v7.0.1)
- [download-artifact v8.0.1](https://github.com/actions/download-artifact/releases/tag/v8.0.1)
- [GitHub Docs: Dependabot for GitHub Actions](https://docs.github.com/en/code-security/how-tos/secure-your-supply-chain/secure-your-dependencies/auto-update-actions)
- [GitHub Docs: Dependabot-supported ecosystems](https://docs.github.com/en/code-security/reference/supply-chain-security/supported-ecosystems-and-repositories)
- [npm: `npm audit`](https://docs.npmjs.com/cli/commands/npm-audit)
- [npm: `npm explain`](https://docs.npmjs.com/cli/commands/npm-explain)
- [markdownlint-cli2 v0.23.2 package manifest](https://github.com/DavidAnson/markdownlint-cli2/blob/v0.23.2/package.json)
- [markdownlint-cli2 changelog](https://github.com/DavidAnson/markdownlint-cli2/blob/v0.23.2/CHANGELOG.md)

### State recovery and shell behavior

- [Amazon S3 Versioning](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html)
- [AWS CLI `list-object-versions`](https://docs.aws.amazon.com/cli/latest/reference/s3api/list-object-versions.html)
- [Azure Blob Versioning](https://learn.microsoft.com/azure/storage/blobs/versioning-overview)
- [Azure CLI blob commands](https://learn.microsoft.com/cli/azure/storage/blob)
- [Google Cloud Object Versioning](https://cloud.google.com/storage/docs/object-versioning)
- [Google Cloud soft delete](https://cloud.google.com/storage/docs/soft-delete)
- [HCP Terraform state-version API](https://developer.hashicorp.com/terraform/cloud-docs/api-docs/state-versions)
- [HCP Terraform API and pagination](https://developer.hashicorp.com/terraform/cloud-docs/api-docs)
- [HCP Terraform Europe](https://developer.hashicorp.com/terraform/cloud-docs/europe)
- [GNU Bash `set`, xtrace, and noclobber](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)
- [curl manual](https://curl.se/docs/manpage.html)
