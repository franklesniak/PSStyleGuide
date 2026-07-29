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
- T2 states the S3 Versioning prerequisite precisely, including pre-enable
  `null` versions, suspended buckets, retention, and owner/administrator
  evidence.
- T2 makes `set +x` the first command in the HCP subshell and requires a
  synthetic inherited-xtrace test.
- T2 lists the complete seven-file T1 implementation boundary.

Do not regress those corrections.

The remaining work is concentrated rather than architectural. T1 still
preserves an end-of-life installed Node version, leaves caller-owned temporary
root creation underspecified, promises stable harness IDs without assigning
them, and normalizes writer inputs less rigorously than P1. The cross-repository
convergence text also predates P1's concrete matrix. The proposed slate is
incomplete until the npm-remediation issue required by both T1 and T2 exists as
a real T3. T2 still needs a closed HCP host contract, positive page and safe
curl-config value validation, explicit scope language, and executable
non-network tests for all four shell examples.

The preferred order remains T1, T2, then T3, provided T1 takes ownership of
installing Node 24 while leaving package and lockfile changes to T3. If policy
requires advisory remediation first, use T3, T1, T2 and rebaseline both later
issues after T3 merges.

## Evidence baseline

This review compared:

- the revised [PowerShell P1](../PSStyleGuide/01PSStyleGuideP1.md),
  [PowerShell P2](../PSStyleGuide/02PSStyleGuideP2.md), and
  [PowerShell P3](../PSStyleGuide/03PSStyleGuideP3.md);
- the proposed [Terraform T1](./03TerraformStyleGuideT1.md) and
  [Terraform T2](./04TerraformStyleGuideT2.md);
- TerraformStyleGuide `main` at
  [`6ee3f57b2b71b885a5927b770dde47532944de62`](https://github.com/franklesniak/TerraformStyleGuide/commit/6ee3f57b2b71b885a5927b770dde47532944de62);
- the live generator, workflows, source documents, generated documents,
  package manifest, and lockfile at that commit; and
- the primary references linked below.

At that commit, `.gitattributes` and `.github/dependabot.yml` are absent, the
generator has four `Set-Content -Encoding UTF8 -NoNewline` serialization
boundaries, and both workflows use moving action tags. The Markdown workflow
installs Node 20. A fresh
`npm audit --package-lock-only --audit-level=moderate --json` on 2026-07-29
reports zero critical, five high, two moderate, and zero low vulnerability
nodes: `brace-expansion`, `js-yaml`, `linkify-it`, `markdown-it`,
`markdownlint-cli2`, `minimatch`, and `picomatch`.

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

P1 already resolves the ownership boundary cleanly. T1 should own the workflow
runtime selection because it already modifies `markdownlint.yml`; T3 should own
the package manifest, lockfile, and advisory remediation. Updating the
installed major does not authorize an incidental dependency upgrade.

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

If T1 will not own Node 24, then T3 must include `markdownlint.yml`, run before
T1, and force T1/T2 to be rebaselined. Leaving Node 20 until an unspecified
later issue is not acceptable.

**Required revision:** Make Node 24 and disabled automatic package-manager
caching part of T1's workflow, validation, acceptance, and T2 prerequisite
contracts while keeping dependency changes in T3.

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

### T1/T2-1: The convergence contract is hypothetical and duplicated

**Severity:** Medium

T1 still says its rules govern “even if” the PowerShell proposal has not
adopted the same rule and tells implementers to compare issue descriptions
later. P1 now has a concrete convergence matrix. T1 also already converges on
the held-stream identity and full-component path model, so the hypothetical
wording is stale.

Replace it with a reciprocal, current matrix covering at least:

| Contract surface | Required cross-repository treatment |
| --- | --- |
| Public parameters | Same five mandatory names and three diagnostic labels |
| Archive identity | Same retained-stream hash/rewind/ZIP lifetime |
| Path security | Same explicit roots, component checks, containment, and no-competing-writer model |
| Manifest | Same exact-set rules; repository-specific filenames |
| Lifecycle | Same journaled cleanup and case-specific postconditions |
| Diagnostics | Same label semantics, phase naming, and safe context |
| Fixtures | Stable comparable IDs; repository-specific manifest cardinality where needed |
| Artifact transport | Same immutable ID/digest propagation and native digest rejection |

Document every intentional difference beside that matrix. Repository-local
scripts, manifests, and workflow artifact names remain appropriate; a shared
package or reusable action is not a prerequisite.

T2's long prerequisite copy is currently accurate, including the seven-file
non-goal boundary, but it will drift as T1 is corrected. After T1 is final,
reduce T2 to a concise invariant summary, a normative relative link to T1, and
a requirement to verify the merged implementation. T1 should remain the
source of truth for helper and workflow detail.

**Required revision:** Replace T1's future comparison instruction with a
reciprocal convergence matrix, and make T2 reference final T1 rather than
freezing another long implementation specification.

### T1/T2-2: The required npm-remediation issue does not exist

**Severity:** High for slate completeness; not a reason to expand T1 or T2

T1 and T2 correctly say a comment, placeholder, or unlinked draft is
insufficient. T1 cannot close, and T2's prerequisite cannot be satisfied,
because this planning directory contains no real T3 issue description.

Add `05TerraformStyleGuideT3.md` with an H1 issue title following the existing
issue-description convention, for example:

```markdown
# Remediate Markdown lint dependency advisories and add npm update governance
```

T3 should own:

- `.github/workflows/package.json`;
- `.github/workflows/package-lock.json`;
- the npm entry for `/.github/workflows` in
  `.github/dependabot.yml`;
- implementation-time re-audit and exact disposition of every advisory;
- deliberate updates to the smallest coherent direct-dependency set;
- complete lockfile review, including registries, Git/local dependencies,
  scripts, and engine changes;
- clean Node 24 `npm ci` and `npm ls --all`;
- positive outer and nested lint tests; and
- negative outer and nested lint tests proving lint still rejects violations.

Follow P3's maintenance model: no `npm audit fix --force`, no auto-merge, and
no blanket acceptance of residual moderate-or-higher findings. Any residual
must have an exact rationale, owner, and time-bounded follow-up. Make the npm
Dependabot disposition concrete in T3 rather than delegating the choice to a
later implementer.

Link T3 from T1 and T2 and state the final ordering. With T1 owning Node 24,
the default remains T1, T2, T3. If policy forces T3 first, rebaseline T1 and T2
after it merges.

**Required revision:** Draft, name, order, and reciprocally link a real T3
before treating this as a complete sequential slate.

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

## Confirmed strengths to preserve

- T1 then T2 is the correct dependency direction.
- T1 correctly identifies all four generator serialization boundaries and
  leaves the already-correct LF-joined frontmatter construction alone.
- The helper's explicit roots, full-component checks, strict containment,
  repeated validation, and documented no-competing-writer model are strong.
- The five mandatory helper parameters and three optional diagnostic labels
  intentionally match P1.
- The held `FileShare.Read` stream now binds the accepted digest to the exact
  ZIP instance consumed through extraction.
- T1's journaled cleanup, direct unsafe-state production-function fixture, and
  case-specific postconditions resolve the earlier lifecycle contradiction.
- The permanent harness, immutable artifact ID/digest, download-by-ID,
  malformed-transport drill, diagnostic artifacts, and edition/EOL matrix are
  sound design choices.
- T1's current full-SHA action pins, local child edition assertions, exact
  remote observation, complete object IDs, blob proofs, explicit refspec,
  exact lease, single-parent proof, and no-retry rule should remain.
- Review-only weekly GitHub Actions Dependabot governance does not replace
  immutable pins or human review.
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
- State and Archivist URLs remain treated as sensitive, and no example
  automatically selects or rolls back a version.

## Recommended final slate

1. Revise T1 to install Node 24 while retaining its current action pins and
   leaving package/lockfile changes to T3.
2. Define and reuse the caller-owned trusted-root factory and teardown.
3. Assign stable IDs to every harness permutation and add symmetric diagnostic
   cases.
4. Normalize all four writer environment inputs once.
5. Replace hypothetical convergence prose with a reciprocal P1/T1 matrix and
   make T2 link to final T1 as its implementation source of truth.
6. Finish T2's HCP host, page, and curl-config value contracts.
7. Resolve T2's state-example scope and require executable non-network shell
   evidence.
8. Add and link a real T3 for npm advisory remediation and npm Dependabot
   governance.

With those changes, the slate supports the intended unification boundary:
observable generator, artifact, security, diagnostic, and validation contracts
converge across repositories, while scripts, manifests, source documents, and
genuinely repository-specific details remain local.

## Primary references

### Repository and generator/workflow maintenance

- [TerraformStyleGuide reviewed commit](https://github.com/franklesniak/TerraformStyleGuide/commit/6ee3f57b2b71b885a5927b770dde47532944de62)
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
