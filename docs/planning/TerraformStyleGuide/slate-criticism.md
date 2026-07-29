# TerraformStyleGuide T1/T2 slate criticism

## Overall assessment

The T1/T2 direction is strong, but the slate is not yet ready to hand to an
implementer unchanged.

T1 has a credible design for deterministic serialization, immutable candidate
transport, archive validation, cross-edition evidence, and a single
lease-protected writer. T2 correctly separates version discovery from
recovery, uses deliberate identifiers, adds provider-native no-overwrite
controls, and substantially improves HCP Terraform secret handling.

The remaining issues are concentrated at trust boundaries:

- T1 preserves end-of-life Node 20 while assigning the replacement runtime to
  a later issue that does not exist.
- T1 lists reviewed action pins but cannot prove their exact workflow/job/step
  roles, conditions, or inputs.
- T1 leaves caller-owned temporary-root creation, stable harness identities,
  and the exact cleanup-function interface underspecified.
- T1's writer still rereads ambient GitHub values after only partially
  normalizing its inputs.
- T1's generator convergence matrix is concrete, but its helper convergence
  language is still hypothetical.
- The required Terraform-specific npm-remediation issue is missing, and the
  seed contract embedded in T1/T2 now trails the revised P3 audit model.
- T2 expands the bearer token directly into curl's line-oriented configuration
  grammar. A token containing a quote and line break can terminate the intended
  header and inject another curl option, including another URL.
- T2 excludes HCP Terraform Europe, accepts malformed page values, and tests
  only the xtrace property rather than the complete four-provider shell
  surface.
- T2's local npm validation proves neither the intended Node runtime nor a
  strict clean-install boundary.

The preferred default order is:

1. T1;
2. T2; and
3. a real Terraform-specific T3 for npm/runtime/hook governance.

That order is coherent only if T1 takes ownership of establishing hosted Node
24 while leaving package, lockfile, hook-floor, and advisory changes to T3,
and only if repository policy permits the known high findings to remain during
T1/T2. If policy requires earlier remediation, the correct order is T3, T1,
T2, with T1 and T2 rebaselined after T3 merges.

## Review basis

This review compared:

- the proposed [T1](./03TerraformStyleGuideT1.md) and
  [T2](./04TerraformStyleGuideT2.md) drafts;
- the current [P1](../PSStyleGuide/01PSStyleGuideP1.md),
  [P2](../PSStyleGuide/02PSStyleGuideP2.md), and
  [P3](../PSStyleGuide/03PSStyleGuideP3.md) drafts;
- TerraformStyleGuide `main` at
  [`6ee3f57b2b71b885a5927b770dde47532944de62`](https://github.com/franklesniak/TerraformStyleGuide/commit/6ee3f57b2b71b885a5927b770dde47532944de62);
- the generator, workflows, package manifest/lockfile, hook, and state-recovery
  source text at that commit;
- the dated cross-repository primary-source record; and
- current official Node, GitHub, npm, HashiCorp, curl, AWS, Azure, and Google
  Cloud documentation.

The live repository evidence remains:

- `.gitattributes` and `.github/dependabot.yml` are absent.
- The generator has four
  `Set-Content -Encoding UTF8 -NoNewline` write boundaries.
- The build workflow has source-path filters, workflow-level
  `contents: write`, and moving checkout/upload tags.
- The Markdown workflow uses moving checkout/setup-node tags and installs
  Node 20.
- `package.json` has no `engines.node`.
- The Husky hook has no Node-major guard and runs the complete outer and nested
  repository lint commands.
- Searches of the live repository for open npm, markdownlint, advisory,
  Dependabot, or Node 24 issues return no matching issue. This planning
  directory also has no Terraform T3 draft.

The official Node release table on 2026-07-29 lists Node 22 and Node 24 as LTS,
Node 26 as Current, and Node 20 as EOL. The current dated audit baseline still
distinguishes seven vulnerability properties from fourteen object advisory
records; those are different units, not interchangeable acceptance constants.

All five T1 PowerShell fences and all three T2 PowerShell fences parse as
PowerShell. All seven T2 Bash fences pass `bash -n` through standard input.
Those checks establish syntax only, not behavior.

## Findings

### T1-01: Runtime ownership and the default order contradict each other

**Severity:** High and time-sensitive

T1 modifies `markdownlint.yml` but explicitly prohibits changing its Node
selection. It assigns final workflow runtime ownership to the future npm issue
while retaining T1 → T2 → npm remediation as the default order.

That preserves Node 20 through two implementations even though Node 20 is
already EOL. The action runtime and installed runtime are separate facts:
setup-node v7 itself uses the action runtime selected by its metadata, but T1
still asks it to install Node 20 for the repository's Markdown code.

Use one of two coherent models:

1. **Preferred default-order model:** T1 owns only the workflow baseline:
   exact Node 24, `package-manager-cache: false`, explicit read-only
   permissions, a Node-major assertion, clean CI-mode `npm ci`, and the
   unchanged outer/nested commands. T3 continues to own dependency,
   lockfile, `engines.node`, hook-floor, advisory, and npm Dependabot changes.
2. **Remediation-first model:** T3 owns the runtime and runs before T1. After
   it merges, rebaseline every T1/T2 Node, package, hook, workflow,
   Dependabot, and path-set assumption.

Do not retain both T3 runtime ownership and the default T1 → T2 → T3 order.
Updating T1's installed Node major does not authorize an incidental package or
lockfile update.

**Required change:** Establish and prove Node 24 in T1, or file/execute T3
first and rebaseline the later issues.

### T1-02: The action verifier proves shape, not the approved role policy

**Severity:** High

T1 names four reviewed action repository/SHA/version selections, but its
validator requires only that every nonlocal `uses:` value contain some
40-hex SHA and some nonempty adjacent version comment. That accepts:

- an unknown action repository at an arbitrary full SHA;
- a reviewed repository at an unreviewed SHA;
- a false release comment;
- a valid action moved into the wrong credential or mutation context;
- a missing role masked by a duplicate elsewhere; and
- weakened security-sensitive inputs.

This gap is larger than a repository allowlist. The current P1 design uses one
normative ordered role collection and compares the exact structural role set.
T1 should adopt the same architecture with Terraform-specific roles:

- workflow name and path;
- exact job ID;
- stable action step ID;
- repository;
- immutable SHA;
- exact adjacent version comment;
- exact `if` condition; and
- the complete allowed `with` input set and values.

The scanner should recognize only the approved ordinary block form and fail
closed on duplicate IDs, reusable-job `uses`, flow/quoted/folded action forms,
unparsed `uses` tokens, extra or missing roles, placement changes, tuple
changes, and input changes. Real GitHub runs remain the authoritative YAML
syntax/execution proof.

Do not keep a separate repository allowlist, occurrence map, and setup-node
special case. Derive all exact-set checks and diagnostics from one
`$arrExpectedActionRoles`-style collection after T1's final job/step IDs are
defined.

**Required change:** Replace the shape-only check with a single-source exact
workflow/job/stable-step role validator.

### T1-03: Caller-owned trusted-root creation is still an assertion

**Severity:** High

The helper's internal path and cleanup contracts are detailed, but every
consumer is merely told to create a “unique trusted temporary root.” No shared
algorithm makes uniqueness, ownership, or safe teardown true.

Every production consumer and controlled drill should:

1. normalize the runner-controlled temporary parent;
2. generate a high-entropy child with
   `[System.IO.Path]::GetRandomFileName()`;
3. prove that child is absent;
4. create it without `-Force`;
5. verify exactly one ordinary, non-reparse directory;
6. retry a documented bounded number of times only for a proven name
   collision;
7. create a distinct download child and reserve an initially absent candidate
   path beneath it;
8. pass the resulting absolute paths forward as data; and
9. tear down only invocation-owned, revalidated ordinary state in `finally`
   after all streams are disposed.

`GetRandomFileName()` only returns a name; it does not reserve it.
Directory-creation APIs may return an already existing directory. The
absence/create/verify sequence and collision-only retry rule are therefore
security requirements, not incidental implementation details.

Teardown must stop without recursion when an unexpected entry appears and
must report cleanup failure separately without hiding the primary failure.

**Required change:** Define one reusable trusted-root
factory/output/teardown contract for every helper caller and evidence drill.

### T1-04: Stable harness identities are promised but not assigned

**Severity:** High

T1 requires stable case identifiers, but its outcome table has prose fixture
classes rather than IDs and groups separately executable permutations.
Examples include:

- missing versus extra entries;
- exact duplicate versus case-only collision;
- forward- versus backslash nesting/traversal;
- leading slash, leading backslash, and drive qualification;
- file versus directory preexistence;
- link versus dangling-link preexistence;
- equal roots versus both containment directions; and
- three distinct explicitly empty optional labels.

Grouped rows make it impossible to identify exactly which permutation ran,
failed, or was skipped on a platform. They also weaken cross-repository
comparison.

Assign one ID to every permutation and include its:

- platform/precondition;
- expected phase;
- whether a ZIP may have been constructed;
- initial candidate state;
- post-helper state before harness teardown;
- required diagnostics; and
- outside-sentinel postconditions.

Match P1's diagnostic symmetry: one induced failure with three distinct
supplied label sentinels, the same failure with labels omitted and rendered
`unavailable`, and separate explicit-empty cases for `ArtifactId`, `RunId`,
and `RunAttempt`.

**Required change:** Replace grouped prose classes with individually
addressable stable cases and exact oracles.

### T1-05: The directly tested production cleanup function has no identity

**Severity:** High

T1 says the production failure path and deterministic unsafe-cleanup fixture
must call “one named cleanup function,” but it never supplies the name or an
exact definition-only loading contract.

Use the shared name:

```text
Remove-StyleGuideCandidateInvocationState
```

Require:

1. that exact function to contain the only production cleanup implementation;
2. the production failure path to call it only after entry streams, the
   `ZipArchive`, and retained archive stream are disposed;
3. ordinary dot-sourcing to load definitions and return before main
   execution, without a test switch or alternate expansion implementation;
4. the mandatory unexpected-ordinary-child case to resolve the exact helper
   to an ordinary, non-reparse file, dot-source it, and call the exact function
   directly; and
5. static evidence that the harness neither copies cleanup code nor calls a
   test-only wrapper.

Resolve both helper and harness files before spawning a child process and pass
their absolute paths as data rather than relying on an inherited working
directory.

**Required change:** Name and bind the production cleanup function and
definition-only interface in the helper, harness, validation, and acceptance
contracts.

### T1-06: The writer does not normalize all four ambient inputs once

**Severity:** Medium to high

The writer's exact remote observation, native object-ID proof, blob checks,
single-parent proof, explicit refspec, lease, and no-retry rule are strong.
Its input boundary is weaker.

T1 copies only `TARGET_REF` and `EXPECTED_SHA`, checks only nonemptiness and a
prefix, then rereads `GITHUB_REF` and `GITHUB_SHA`. It does not reject
leading/trailing whitespace or CR/LF, and it never calls
`git check-ref-format` on the complete target ref.

At the first executable boundary:

1. copy `TARGET_REF`, `EXPECTED_SHA`, `GITHUB_REF`, and `GITHUB_SHA` into four
   distinct locals;
2. reject missing/empty values, surrounding whitespace, CR, and LF;
3. require one complete `refs/heads/...` value accepted by
   `git check-ref-format`;
4. compare only those locals using the intended case semantics;
5. reuse the same unchanged locals for checkout, remote, parent, lease, and
   `HEAD:<full-ref>` proofs; and
6. never read those environment variables again.

Purpose-specific controlled tests should mutate test locals, not weaken the
production environment contract.

**Required change:** Match P1's complete one-read normalization boundary while
preserving T1's stronger remote/blob/parent checks.

### T1/T2-01: Helper convergence is hypothetical and T2 freezes unresolved details

**Severity:** Medium

T1's generator-convergence matrix is the right model. It names shared
algorithms, intentional guide-specific differences, repository independence,
and first/second-mover evidence.

The helper introduction still says its contract applies “even if” P1 has not
adopted it. P1 now has a concrete reciprocal helper matrix. Replace the
hypothetical prose with a current behavioral matrix covering:

| Surface | Shared behavioral contract |
| --- | --- |
| Public parameters | Same five mandatory names and three optional labels |
| Archive identity | One retained stream; hash, compare, rewind, one ZIP lifetime |
| Path security | Explicit roots, full-component checks, containment, and no-competing-writer model |
| Manifest | Same exact-set rules with repository-specific filenames |
| Lifecycle | Same journaled cleanup and exact production cleanup-function identity |
| Diagnostics | Same phases and omitted/supplied/empty label semantics |
| Fixtures | Stable comparable IDs with guide-specific manifest payloads |
| Transport | Immutable ID/digest propagation and fatal native mismatch |
| Placement | Explicitly record T1's all-four-Windows-cell choice versus P1's two-LF-cell choice |

Keep implementation and harness code repository-local. A shared module,
submodule, package, reusable action, or cross-repository release dependency is
not a prerequisite.

T2's prerequisite then restates roughly a hundred lines of T1 and future T3
behavior. That snapshot will drift as T1 and T3 are corrected. Once the issues
are filed:

- use actual durable issue URLs and GitHub blocked-by relationships;
- summarize only the merged interfaces T2 consumes;
- require implementation-time verification of those merged interfaces; and
- leave algorithmic detail in T1/T3 as the sources of truth.

**Required change:** Make the helper matrix reciprocal and current, then reduce
T2's prerequisite to durable links plus concise consumed invariants.

### T1/T2-02: The required T3 is missing and its seed contract is outdated

**Severity:** High for slate completeness

T1 cannot close without a real linked npm-remediation issue, and T2's
prerequisite requires that issue. No Terraform T3 draft exists here, and the
live repository has no matching open issue. Embedded prose is not an
independently fileable, orderable issue.

Add:

```text
docs/planning/TerraformStyleGuide/05TerraformStyleGuideT3.md
```

with an H1 issue title such as:

```markdown
# Remediate Markdown lint dependency advisories and add npm update governance
```

Use TerraformStyleGuide's actual full-lint Husky surface. Do not copy P3's
`lint-staged-markdown.mjs` design because that file/API does not exist in the
Terraform repository.

The existing T1 seed must also be updated to the current P3 security model:

1. **Separate units.** Report vulnerability-property severity counts, object
   advisory count, and distinct disposition-key count independently. Do not
   compare seven properties with fourteen advisory objects.
2. **Validate the consumed graph.** Record Node/npm versions and raw report;
   require the reviewed `auditReportVersion`; validate metadata, property
   key/name, severity, `isDirect`, range, `via`, `effects`, `nodes`,
   `fixAvailable`, advisory URLs/ranges/severities, reciprocal selected-schema
   edges, and metadata/property equality.
3. **Use audit-native approval identity.** Key each actionable residual by
   exact `(Package, AdvisoryUrl)`. A package-wide dependency or explain path is
   diagnostic context, not approval identity.
4. **Track nodes separately.** For every remaining vulnerable package, record
   the exact nonempty, duplicate-free audit `nodes` set in a package-keyed
   `AuditNodePaths` record and resolve each path to the matching
   package/version entry in `package-lock.json`.
5. **Harden governance fields.** Require a named owner, separately preserved
   owner-acceptance evidence, one exact future invariant UTC timestamp, a
   publicly retrievable TerraformStyleGuide issue URL that is not a pull
   request, and rationale. Reject duplicate, missing, stale, unexpected, and
   expired records.
6. **Keep explain diagnostic.** Preserve normalized `npm explain --json`
   context for each affected package, including finite cycle/leaf shapes, but
   do not make it part of exact residual identity.
7. **Prove named runtimes.** Treat `engines.node: >=<minimum>` and the hook
   guard as a lower-bound admission rule. Name the supported LTS evidence set:
   selected LTS minimum and Node 24, not every intervening or future major.
8. **Use strict clean cells.** At each distinct runtime, set and verify
   `engine-strict=true`, prohibit `--force`, run a fresh `npm ci`,
   `npm ls --all`, both production lint commands, and the tracked real-hook
   harness.
9. **Make Dependabot exact.** Prefer the exact review-only GitHub Actions entry
   followed by the npm entry for `/.github/workflows`, unless a cited
   repository policy requires the mechanically validated one-entry state.

T3 should own `package.json`, `package-lock.json`, the Husky runtime guard, npm
Dependabot state, its tracked integration harness, and the harness invocation
in `markdownlint.yml`, while preserving T1's pins, permissions, triggers,
installed Node 24, cache setting, and existing lint commands.

**Required change:** Draft, order, and reciprocally link a real Terraform T3,
and update its seed from path-based residual approval to the current
package/advisory plus separate audit-node model.

### T2-01: The HCP token-to-curl boundary permits configuration injection

**Severity:** Critical

The first-command `set +x`, protected response descriptor, `umask 077`,
`curl -q`, and explicit failure handling are all worth preserving.

The token is nevertheless expanded into this line-oriented curl configuration:

```text
header = "Authorization: Bearer $TFC_TOKEN"
```

Curl's official config grammar processes one option per physical line and
interprets quote/backslash escapes inside double-quoted values. A token
containing a double quote plus LF can close the intended header and inject a
new config directive. An injected `url = ...` can cause another request while
the Authorization header remains configured, turning malformed token data
into a credential-destination vulnerability.

Do not rely on “nonempty token” or curl header handling as sanitization.
Before opening the response file or invoking the stub/curl:

- reject CR, LF, every other control character, double quote, and backslash
  unless a reviewed encoding is specified and tested;
- avoid inventing a narrower full token regex without a normative HashiCorp
  token grammar; and
- test config-breaking synthetic values and require rejection before file
  creation or provider invocation.

A safer representation that cannot introduce another curl config line is
acceptable, but it still needs an exact grammar, no command-line token
exposure, and executable tests.

**Required change:** Close and test the token/config grammar before the secret
can reach curl configuration.

### T2-02: The HCP host and page contracts are incomplete

**Severity:** High

The example hardcodes `app.terraform.io`. Official HashiCorp documentation
also identifies `app.eu.terraform.io` for HCP Terraform Europe. At the same
time, accepting an arbitrary host or generic URL would let a typo or hostile
environment value redirect the bearer token.

Introduce one nonsecret host selector and allow exactly:

- `app.terraform.io`; and
- `app.eu.terraform.io`.

Reject schemes, paths, ports, whitespace, and every other host before token
expansion or response-file creation. Build the fixed HTTPS
`/api/v2/state-versions` URL only from the accepted host. State explicitly that
Terraform Enterprise is outside this example; Enterprise support needs a
separate certificate, redirect, trust, and credential-destination contract.

`TFC_PAGE_NUMBER=${TFC_PAGE_NUMBER:-1}` also accepts zero, negatives, leading
signs, whitespace, controls, and arbitrary text. Require one canonical
positive decimal integer, such as `[1-9][0-9]*`, before creating the response
file. Retain page size 100 and continuation until
`meta.pagination.next-page` is `null`.

**Required change:** Add a closed US/EU host allowlist, explicit Enterprise
scope, and canonical positive-page validation, all ordered before secret/file
side effects.

### T2-03: One xtrace test does not prove four copy-safe examples

**Severity:** High

T2's only executable shell behavior test replaces curl and verifies inherited
xtrace handling. The validation otherwise relies on review of the published
blocks. It does not execute:

- common destination guards;
- no-overwrite behavior;
- literal argument boundaries;
- exact provider flags/filters;
- version-ID/generation propagation;
- HCP host/page/token-config rejections; or
- partial-response handling.

Add a reproducible, non-network harness that extracts the exact blocks intended
for publication and:

1. runs `bash -n`;
2. stubs `aws`, `az`, `gcloud`, and `curl`;
3. rejects missing, empty, relative, existing-file, existing-directory,
   symbolic-link, and dangling-link destinations before provider invocation;
4. proves paths containing spaces and shell metacharacters remain one literal
   argument;
5. proves version IDs and generations reach the stub unchanged;
6. proves exact-object filters plus Azure/GCS no-overwrite flags;
7. covers documented S3 versioning evidence outcomes;
8. covers both allowed HCP hosts and every rejected host class;
9. covers valid and invalid page values and config-breaking token values;
10. retains the inherited-xtrace sentinel test; and
11. simulates curl failure and proves the protected partial response remains
    explicitly invalid.

The preferred durable design is a tracked harness added to T2's affected-file
set. If the author intentionally keeps the six-file boundary, the issue must
still specify a complete reproducible harness and preserve its exact source
and results as pull-request evidence. “Any nonzero exit” is never sufficient;
each negative case needs the intended rejection and proof that the provider
stub did not run.

**Required change:** Make executable non-network behavior evidence for all four
published blocks an acceptance prerequisite.

### T2-04: Universal state-safety wording exceeds the modified inventory

**Severity:** Medium

T2 changes four named S3, Azure, GCS, and HCP blocks, but some summary and
acceptance language says “every recovery destination” or speaks
provider-neutrally about recovered state.

The live sources contain additional state operations outside those four
blocks, including:

- local `terraform state pull` backups;
- backup inspection;
- `terraform state push`;
- `terraform state rm`/`mv`;
- another S3 version-listing sequence; and
- manual corruption/reconstruction guidance.

Choose one explicit scope:

1. inventory and harden every backup, discovery, inspection, recovery, and
   destructive state example in both sources; or
2. state that T2's mechanical no-overwrite contract covers only the three
   provider-download blocks and its protected-response contract covers only
   the named HCP discovery block, then file a follow-up for untouched examples.

The second option better matches T2's title and implementation boundary.
Retain the provider-neutral sensitive-state warning, but do not imply that
untouched examples received mechanical protections.

**Required change:** Add a complete state-operation inventory or narrow every
quantifier to the four explicitly modified blocks and record the remainder.

### T2-05: Local Markdown validation inherits an arbitrary runtime

**Severity:** Medium to high

T2 calls ambient `npm`, never queries `node`, does not record the npm version,
does not establish `CI=true`, and does not enforce `engine-strict` when the
merged package contract has an engine floor.

For the preferred T1 → T2 → T3 order:

1. resolve exactly one Node application and one npm application;
2. require exact Node major 24 before install or lint;
3. record and reuse the exact npm path/version;
4. set `CI=true` only around `npm ci`, restoring the previous environment in
   `finally`;
5. run the unchanged outer and nested commands through the resolved npm
   executable; and
6. keep package/lockfile changes outside T2.

If T3 ran first, T2 must instead enforce the merged T3 runtime contract:
selected named runtime, exact engine floor, `engine-strict=true`, no
`--force`, clean install, dependency-tree validation, and both lint commands.

This is validation ownership, not permission for a documentation issue to
change dependencies.

**Required change:** Make T2 prove the exact merged Node/npm boundary rather
than whatever happens to be on `PATH`.

## Strengths to preserve

- T1 then T2 is the correct dependency direction when T1 establishes Node 24
  and policy permits T3 to follow.
- T1 correctly identifies all four serialization boundaries and leaves the
  already LF-joined Terraform frontmatter representation intact.
- The generator convergence matrix separates shared algorithms from
  guide-specific content and avoids a cross-repository runtime dependency.
- The helper's explicit roots, full-component checks, strict containment,
  repeated validation, and no-competing-writer model are strong.
- The five mandatory helper parameters and three optional labels intentionally
  align with P1.
- One held `FileShare.Read` stream binds the accepted digest to the ZIP
  instance consumed through extraction.
- Journaled, nonrecursive, fail-closed cleanup and case-specific destination
  postconditions are the right lifecycle model.
- The immutable artifact ID/digest, download-by-ID, fatal native mismatch,
  malformed-transport drill, and four-cell Windows edition/EOL topology are
  strong evidence choices.
- T1's remote observation, native full object-ID proof, candidate/index/commit
  blob checks, explicit refspec, single-parent proof, exact lease, and no-retry
  rule should remain.
- T1's dated action selections match the reviewed P1 selections; strengthen
  their structural validator without reverting to moving tags.
- T2 correctly separates discovery from recovery and never automatically
  selects a version.
- T2's S3 prerequisite distinguishes enabled/suspended versioning,
  pre-enable `null` versions, retention, and owner/administrator evidence.
- The exact-key AWS/Azure filters, Azure non-HNS scope and
  `--overwrite false`, and GCS Object Versioning/soft-delete distinction plus
  `--no-clobber` are well designed.
- HCP's `/state-versions` endpoint, organization/workspace/finalized filters,
  manual pagination, first-command `set +x`, protected noclobber descriptor,
  restrictive `umask`, and explicit partial-file handling are strong after the
  remaining input contracts are closed.
- State and Archivist URLs remain classified as sensitive, and none of the
  examples performs an automatic rollback.

## Recommended final slate

1. Revise T1 to establish and prove exact Node 24 while leaving dependency and
   hook-floor changes to T3.
2. Give every external action a stable step ID and replace the shape scan with
   one exact role/input table.
3. Define the bounded trusted-root factory and fail-closed teardown used by
   every caller.
4. Assign stable IDs to every helper fixture permutation.
5. Name and bind
   `Remove-StyleGuideCandidateInvocationState`.
6. Normalize all four writer environment inputs once and validate the complete
   target ref.
7. Replace hypothetical helper convergence with a reciprocal current matrix
   and shorten T2's prerequisite after real issue links exist.
8. Add and link a real Terraform-specific T3 using audit-native
   package/advisory identity, separate audit-node sets, exact schema/count
   reconciliation, named LTS runtime cells, actual full-lint hook evidence,
   and exact Dependabot governance.
9. Close T2's HCP token/config, US/EU host, Enterprise-scope, and page-number
   contracts.
10. Add executable non-network coverage for all four T2 shell blocks.
11. Narrow T2's state-operation scope or inventory every adjacent example.
12. Make T2's local validation prove the merged runtime contract.

After those changes, the unification boundary is defensible: observable
serialization, archive, path, lifecycle, diagnostic, action, and runtime
contracts converge across repositories, while source transforms, manifests,
artifact names, state-provider guidance, and implementation files remain
repository-local.

## Primary references

### Repository and cross-repository contracts

- [TerraformStyleGuide reviewed commit](https://github.com/franklesniak/TerraformStyleGuide/commit/6ee3f57b2b71b885a5927b770dde47532944de62)
- [Reviewed generator](https://github.com/franklesniak/TerraformStyleGuide/blob/6ee3f57b2b71b885a5927b770dde47532944de62/.github/workflows/Generate-StyleGuideArtifacts.ps1)
- [Reviewed build workflow](https://github.com/franklesniak/TerraformStyleGuide/blob/6ee3f57b2b71b885a5927b770dde47532944de62/.github/workflows/build.yml)
- [Reviewed Markdown workflow](https://github.com/franklesniak/TerraformStyleGuide/blob/6ee3f57b2b71b885a5927b770dde47532944de62/.github/workflows/markdownlint.yml)
- [Reviewed package manifest](https://github.com/franklesniak/TerraformStyleGuide/blob/6ee3f57b2b71b885a5927b770dde47532944de62/.github/workflows/package.json)
- [Reviewed Husky hook](https://github.com/franklesniak/TerraformStyleGuide/blob/6ee3f57b2b71b885a5927b770dde47532944de62/.husky/pre-commit)
- [Prompt-02 cross-repository primary-source record](../artifacts/prompt-02-primary-source-research.md)
- [Node.js release status](https://nodejs.org/en/about/previous-releases)
- [Node.js EOL guidance](https://nodejs.org/en/about/eol)
- [GitHub Actions secure-use reference](https://docs.github.com/en/actions/reference/security/secure-use)
- [GitHub issue dependencies](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/creating-issue-dependencies)

### npm and runtime governance

- [npm: `package.json` engines](https://docs.npmjs.com/cli/v11/configuring-npm/package-json/#engines)
- [npm: `engine-strict`](https://docs.npmjs.com/cli/v11/using-npm/config/#engine-strict)
- [npm: `npm ci`](https://docs.npmjs.com/cli/v11/commands/npm-ci/)
- [npm: `npm audit`](https://docs.npmjs.com/cli/v11/commands/npm-audit/)
- [npm: `npm explain`](https://docs.npmjs.com/cli/v11/commands/npm-explain/)
- [markdownlint-cli2 v0.23.2 manifest](https://github.com/DavidAnson/markdownlint-cli2/blob/v0.23.2/package.json)
- [markdownlint-cli2 changelog](https://github.com/DavidAnson/markdownlint-cli2/blob/v0.23.2/CHANGELOG.md)

### State recovery and shell behavior

- [Amazon S3 Versioning](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html)
- [AWS CLI `list-object-versions`](https://docs.aws.amazon.com/cli/latest/reference/s3api/list-object-versions.html)
- [Azure Blob Versioning](https://learn.microsoft.com/azure/storage/blobs/versioning-overview)
- [Azure CLI blob commands](https://learn.microsoft.com/cli/azure/storage/blob)
- [Google Cloud Object Versioning](https://cloud.google.com/storage/docs/object-versioning)
- [Google Cloud soft delete](https://cloud.google.com/storage/docs/soft-delete)
- [HCP Terraform state-version API](https://developer.hashicorp.com/terraform/cloud-docs/api-docs/state-versions)
- [HCP Terraform API pagination](https://developer.hashicorp.com/terraform/cloud-docs/api-docs)
- [HCP Terraform Europe](https://developer.hashicorp.com/terraform/cloud-docs/europe)
- [curl configuration grammar](https://curl.se/docs/manpage.html)
- [GNU Bash `set`, xtrace, and noclobber](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)
