# TerraformStyleGuide T1/T2 slate criticism

## Overall assessment

T1 followed by T2 is the correct execution order. T1 establishes deterministic
generation and a controlled artifact boundary; T2 can then change the source
guide and regenerate all derived artifacts against that known baseline.

Both issues are unusually thorough and preserve several good decisions:

- repository-local generator, helper, and harness implementations;
- matching P1/T1 public helper parameters and diagnostic-label meanings;
- explicit checkout and trusted-temporary roots;
- full-component path checks and an honest no-competing-writer model;
- immutable artifact ID and digest propagation;
- full-SHA external-action pins and review-only update governance;
- a real edition × fixture-EOL Windows matrix;
- read-only preparation and approval jobs;
- one exact-lease writer;
- provider-specific state-version discovery separated from recovery; and
- deliberate selection, protected destinations, and no-clobber controls.

The issues are not implementation-ready yet. T1 has six material contract gaps:
the digest is not bound to the ZIP stream that is consumed, the selected
checkout/setup-node releases and Node runtime are stale, “unique” temporary
roots have no creation/cleanup algorithm, the harness table contradicts its own
postconditions, local edition validation trusts executable names, and writer
input validation is weaker than P1. T2 then copies that intermediate T1
contract, understates the S3 versioning prerequisite, and leaves several HCP
and executable-validation gaps.

The generator-unification direction should remain behavioral for now. Converge
public parameters, security invariants, phases, diagnostics, fixture IDs, and
workflow evidence, while retaining repository-local scripts and
repository-specific manifest names. A shared package or reusable action can be
considered after both implementations have stable, proven contracts; it should
not become a new prerequisite for this slate.

## Evidence baseline

This review compared:

- the revised [PowerShell P1](../PSStyleGuide/01PSStyleGuideP1.md) and
  [PowerShell P2](../PSStyleGuide/02PSStyleGuideP2.md);
- P1's explicitly separate
  [PowerShell P3](../PSStyleGuide/03PSStyleGuideP3.md) maintenance owner;
- the proposed [Terraform T1](./03TerraformStyleGuideT1.md) and
  [Terraform T2](./04TerraformStyleGuideT2.md);
- TerraformStyleGuide `main` at
  [`6ee3f57b2b71b885a5927b770dde47532944de62`](https://github.com/franklesniak/TerraformStyleGuide/commit/6ee3f57b2b71b885a5927b770dde47532944de62);
- the live
  [`build.yml`](https://github.com/franklesniak/TerraformStyleGuide/blob/6ee3f57b2b71b885a5927b770dde47532944de62/.github/workflows/build.yml),
  [`markdownlint.yml`](https://github.com/franklesniak/TerraformStyleGuide/blob/6ee3f57b2b71b885a5927b770dde47532944de62/.github/workflows/markdownlint.yml),
  and
  [`Generate-StyleGuideArtifacts.ps1`](https://github.com/franklesniak/TerraformStyleGuide/blob/6ee3f57b2b71b885a5927b770dde47532944de62/.github/workflows/Generate-StyleGuideArtifacts.ps1);
- the live `STYLE_GUIDE.md`, `STYLE_GUIDE_RATIONALE.md`, package manifest, and
  lockfile; and
- the primary references linked below.

At that commit:

- `.gitattributes` and `.github/dependabot.yml` are absent;
- the Windows PowerShell 5.1 generator still has four
  `Set-Content -Encoding UTF8 -NoNewline` write sites;
- `build.yml` still uses moving `actions/checkout@v4` and
  `actions/upload-artifact@v4` references;
- `markdownlint.yml` still uses moving checkout/setup-node v4 references and
  installs Node 20; and
- a fresh `npm audit --package-lock-only --audit-level=moderate --json` on
  2026-07-29 exits 1 with zero critical, five high, two moderate, and zero low
  vulnerability nodes. The reported packages are `brace-expansion`, `js-yaml`,
  `linkify-it`, `markdown-it`, `markdownlint-cli2`, `minimatch`, and
  `picomatch`.

All five PowerShell fences in T1 and all three in T2 parse in both Windows
PowerShell 5.1 and PowerShell 7. All seven T2 Bash fences pass `bash -n`.
Those are syntax results, not behavioral proof.

## Findings

### T1-1: Hashing and ZIP consumption use different file opens

**Severity:** High

T1 requires path-based:

```powershell
Get-FileHash -Algorithm SHA256
```

and later opens the same path as a ZIP. Even with repeated path checks, the
bytes parsed are not mechanically the same file instance that produced the
accepted digest. The stated job-owned/no-competing-writer model limits the
race, but it does not justify leaving a needless identity gap when P1 already
defines a portable stronger contract.

T1 should adopt this exact sequence:

1. complete the component, containment, type, and leaf checks;
2. open the retained file once with `FileMode.Open`, `FileAccess.Read`, and
   `FileShare.Read`;
3. require a readable, seekable stream;
4. pass that stream to
   `Get-FileHash -InputStream -Algorithm SHA256`;
5. require exactly one hash result containing exactly one 64-hex digest;
6. compare it ordinally and case-insensitively with the propagated digest;
7. rewind the same held stream;
8. construct one read-only `ZipArchive` over that stream;
9. retain it through manifest validation and extraction; and
10. dispose entry streams, the archive, and then the underlying stream in
    deterministic `try`/`finally` scopes before cleanup.

Do not grant `FileShare.Write` or `FileShare.Delete`. Document, as P1 does,
that `FileShare.Read` permits benign secondary readers while denying later
write/delete sharing on Windows, but is not a universal cross-platform lock.
Keep the no-competing-writer operating model.

The Windows harness should probe the selected share behavior: a second
read-only open succeeds, a write open fails while the primary stream is held,
and the primary stream remains usable. Update the digest-mismatch fixture and
controlled drill to say “before `ZipArchive` construction/read,” not “before
the file is opened.”

**Required revision:** Replace the path-hash/reopen contract everywhere in T1
and in T2's prerequisite with the held-stream contract above.

### T1-2: The dated action pins and Node target are already stale

**Severity:** High and time-sensitive

T1 says “as of 2026-07-29” but selects:

- checkout v6.1.0;
- setup-node v6.5.0; and
- preservation of the Markdown workflow's Node 20 behavior.

The corresponding current targets used by P1 are:

- `actions/checkout` v7.0.1 at
  `3d3c42e5aac5ba805825da76410c181273ba90b1`;
- `actions/setup-node` v7.0.0 at
  `820762786026740c76f36085b0efc47a31fe5020`;
- `node-version: '24'`; and
- `package-manager-cache: false`.

Both actions declare the Node 24 action runtime. That runtime is distinct from
the Node version installed for Markdown lint. The
[Node release table](https://nodejs.org/en/about/previous-releases) marks Node
20 end-of-life and Node 24 LTS, so pinning the action while retaining Node 20
does not solve the lint-runtime problem.

T1's upload-artifact v7.0.1 and download-artifact v8.0.1 pins are current as of
the same review and should remain unless the implementation-time recheck finds
a newer required security release.

Align T1 with P1 by requiring:

- the checkout/setup-node pins above with exact same-line version comments;
- explicit `contents: read` on Markdown lint;
- Node major 24;
- automatic package-manager caching disabled;
- a clean `npm ci` with CI behavior;
- the existing outer and nested lint commands; and
- local and hosted assertions that the lint process actually runs Node major
  24.

Update T1's checkout credential-storage explanation and controlled push
evidence for checkout v7. Add P1-style executable static validation that every
external `uses:` value has one 40-hex SHA and one exact version comment; prose
inspection alone is weaker than the rest of T1's validation.

This does not authorize package updates in T1. The advisory dependency graph
belongs to the separate maintenance issue described below.

**Required revision:** Replace the stale pins and Node-preservation non-goal,
then update the affected workflow contract, validation, acceptance criteria,
references, and T2 prerequisite together.

### T1-3: “Unique trusted temporary root” has no production algorithm

**Severity:** High

T1 repeatedly requires one unique, job-owned trusted temporary root, but tells
consumers only to “create one” outside checkout. A fixed child of
`RUNNER_TEMP`, or `RUNNER_TEMP` itself, can therefore satisfy the prose in an
implementer's reading while violating the ownership and isolation assumptions
on which the path contract depends.

Every helper consumer, including the harness, should use the same production
topology:

1. normalize the runner-controlled temporary parent;
2. generate a high-entropy child name with
   `[System.IO.Path]::GetRandomFileName()`;
3. prove no filesystem entry occupies the child;
4. create it without `-Force`;
5. verify that the result is one ordinary, non-reparse directory;
6. retry a documented bounded number of times only for a proven name
   collision;
7. fail every other creation, enumeration, or classification error;
8. create a separate download child and an initially absent candidate leaf or
   candidate parent/leaf topology beneath that root; and
9. emit absolute paths for subsequent steps rather than reconstructing them
   from names.

`GetRandomFileName()` generates a name but does not create it, while
`Directory.CreateDirectory()` can return an existing directory. The
absence/create/verify sequence is therefore part of the contract, not an
implementation detail.

Each consumer must own cleanup in `finally`: dispose handles, revalidate the
owned envelope, remove only known ordinary files and empty directories, never
follow/recurse through an unexpected entry, and surface cleanup failure without
discarding the original failure. Do not silently reuse a pre-existing root.

**Required revision:** Add the creation, output, bounded-retry, separation, and
owned-cleanup algorithm to the Windows cells, writer, Ubuntu harness use, local
harness, controlled drills, and acceptance criteria.

### T1-4: The harness has grouped cases and a contradictory rejection oracle

**Severity:** High

The permanent harness is the correct architecture, but its table says stable
case identifiers are required without assigning any identifiers. It also
groups independently meaningful permutations:

- forward- and backslash nesting;
- forward and backward traversal;
- leading slash, leading backslash, and drive qualification;
- three different root-overlap relationships;
- each of the three optional empty labels;
- different symlink/reparse component locations; and
- BOM and CR post-extraction failures.

Grouped rows weaken failure attribution and platform-skip accounting. More
importantly, T1 requires every rejection fixture to leave the destination
nonexistent, while its pre-existing candidate file, directory, symlink, and
dangling-link cases require the original entry to remain untouched. Those
contracts cannot both be true. The acceptance criterion repeats the blanket
absence claim.

Use P1's stable-ID table as the structural model, adapted for Terraform's four
manifest names. At minimum:

- give every executable permutation one stable ID;
- split BOM and CR into separate cases;
- split the three root relationships and each path spelling;
- use one failure with all three distinct supplied label sentinels;
- use a second failure with all labels omitted and require `unavailable`;
- give `ArtifactId`, `RunId`, and `RunAttempt` separate explicitly empty cases;
- assert the phase and proof that no `ZipArchive` was constructed for digest
  rejection;
- test hidden/system extra download entries;
- distinguish ancestor links from links below the trusted root; and
- record the exact platform/precondition for every link case.

Make candidate postconditions case-specific:

| Case class | Required final state |
| --- | --- |
| Pre-creation rejection with no pre-existing leaf | Candidate leaf absent |
| Pre-existing file/directory/link/dangling-link rejection | Exact original entry unchanged |
| Successful extraction | Four exact ordinary files with expected bytes |
| Post-creation BOM/CR rejection | Only invocation-created files and empty leaf removed |
| Unsafe or ownership-uncertain cleanup | Path retained; no recursion/following; primary and cleanup failures both reported |

T1 claims fail-closed cleanup diagnostics but has no deterministic unsafe-cleanup
fixture. Add one that exercises the exact production cleanup function, or
narrow the acceptance claim. The harness must not copy the cleanup algorithm,
and harness teardown after the assertion does not prove production cleanup.

Running the complete helper suite in all four Windows pull-request cells is
more coverage than P1, which reserves the CRLF cells for generator behavior.
That is not incorrect. Keep it only as a documented Terraform-specific choice
whose CI cost is accepted; all four push consumers should continue to run the
suite because each consumes a real candidate.

**Required revision:** Replace the grouped table with stable IDs, exact phases,
diagnostics, and case-specific final-state oracles, then update all blanket
absence language.

### T1-5: Local cross-edition validation trusts labels, not child facts

**Severity:** Medium to high

The local loop resolves applications named `pwsh` and `powershell`, labels them
as PowerShell 7 and Windows PowerShell 5.1, and invokes the harness and
generator. Neither child process asserts the expected `PSEdition` and exact
major/minor version before performing work.

The workflow cells already require edition assertions in the same process.
Local validation should do the same. For each child invocation, pass expected
edition and version values through task-specific environment variables or an
equivalent non-ambiguous bootstrap, then make the child:

1. reject missing expectations;
2. require `Core` major 7 for `pwsh`;
3. require `Desktop` version exactly 5.1 for `powershell`;
4. assert before invoking the harness or generator;
5. report expected and observed edition/version; and
6. restore or remove all task-specific environment variables in `finally`.

This protects the evidence against shims, unexpected installations, and
mislabeling. CI remains responsible for mandatory availability of both
editions.

**Required revision:** Bind each local result to an in-child edition/version
assertion rather than executable naming alone.

### T1-6: Writer input normalization is weaker than P1

**Severity:** Medium

T1's exact remote observation, full object-ID validation, explicit refspec,
exact expected-SHA lease, single-parent proof, and no-retry policy are strong.
The initial input handling should match P1:

1. copy `TARGET_REF` and `EXPECTED_SHA` at the first executable lines of the
   mutation block;
2. reject empty values, leading/trailing whitespace, and CR/LF;
3. require the complete ref to begin with `refs/heads/` and pass
   `git check-ref-format`;
4. compare the locals once with `GITHUB_REF` and `GITHUB_SHA`;
5. validate one native full `HEAD^{commit}` and one exact remote record; and
6. never read `TARGET_REF`, `EXPECTED_SHA`, `GITHUB_REF`, or `GITHUB_SHA`
   again.

Reuse the unchanged locals for checkout/HEAD, remote, parent, lease, and
destination-refspec proofs. Controlled stale-ref and lease tests should mutate
only purpose-specific local test inputs, not weaken or repurpose the production
environment contract.

**Required revision:** Copy P1's one-read normalization contract while
preserving T1's stronger blob and exact-lease proofs.

### T1/T2-1: The npm advisory graph needs a real third issue

**Severity:** Medium to high; not a reason to expand T1 or T2

T1 correctly keeps package changes out of generator/workflow hardening, and
its review-only `github-actions` Dependabot entry now matches P1. That entry
does not monitor or remediate the nested npm project.

Create a real T3 after T2, analogous to P3, owning:

- `.github/workflows/package.json`;
- `.github/workflows/package-lock.json`; and
- extension of `.github/dependabot.yml` with a review-only weekly npm entry for
  `/.github/workflows`.

T3 should re-audit at implementation time, review direct release notes and
engine requirements, deliberately update the smallest coherent direct
dependency set, inspect the complete lockfile diff, reject unexpected
registries/Git/local dependencies/scripts, require Node 24 and clean `npm ci`,
run `npm ls --all`, preserve positive and negative outer/nested lint behavior,
and require either a clean moderate-or-higher audit or exact, owner-assigned,
time-bounded residual advisory dispositions. Do not use
`npm audit fix --force` as a substitute for release review, and do not add
auto-merge.

The default order should be:

1. T1;
2. T2; and
3. T3.

If repository policy requires advisory remediation first, move T3 before T1
and rebaseline T1/T2 pins, Node, package behavior, and validation against the
merged result. Do not leave the current seven-node audit result as prose with
no owner.

**Required revision:** Add and link the separately scoped issue, state its
ordering, and keep T1/T2 package files unchanged.

### T1/T2-2: T2 freezes an intermediate prerequisite

**Severity:** Medium

T2 copies a long implementation manifest from T1, including the current
path-based digest, harness topology, action-governance state, and seven-file
set. Every correction above will make that copy stale.

After T1 is final, replace the copied implementation narrative with:

- a concise invariant summary;
- a normative relative link to T1;
- explicit verification of the merged implementation before T2 starts; and
- the statement that T1 remains the source of truth for helper/workflow detail.

The summary should still name the gates T2 genuinely depends on:

- deterministic BOM-less LF generation;
- final pinned actions and Node 24 lint behavior;
- unique job-owned temporary roots;
- complete component and lifecycle validation;
- held-stream digest/ZIP identity with `FileShare.Read`;
- stable-ID harness and controlled malformed-transport evidence;
- immutable ID/digest propagation;
- read-only approval and exact-lease writing; and
- review-only GitHub Actions governance.

T2's non-goals say not to modify prerequisite files but list only four of T1's
seven paths. Say “do not modify any file delivered by T1” and link to the
verified prerequisite manifest, or list the complete final set. Link T3 as a
follow-on, not a T2 prerequisite.

**Required revision:** Rebuild the prerequisite and non-goal contract from
final T1 rather than preserving an intermediate duplicate.

### T2-1: “Versioning-capable” is not a sufficient S3 recovery prerequisite

**Severity:** Medium to high

Every general-purpose S3 bucket is versioning-capable, but S3 Versioning is
disabled by default. Historical versions exist only after versioning has been
enabled; objects that predate enablement retain a `null` version until modified.
Suspending versioning preserves existing noncurrent versions but changes how
later writes are versioned.

T2 should require the operator to establish:

- this is a general-purpose bucket;
- S3 Versioning was enabled before the desired historical version was created;
- the current state is known (`Enabled` or `Suspended`);
- the exact key/version exists and remains retained; and
- lifecycle expiration has not removed it.

If the example performs `get-bucket-versioning` directly, add the corresponding
authorization requirement. Otherwise require confirmation from the bucket
owner/administrator or existing operational evidence. “Versioning-capable”
must not stand in for this check.

The directory-bucket exclusion and the current general-purpose
SSE-KMS/DSSE-KMS retrieval distinction are otherwise well framed and should be
preserved.

**Required revision:** Replace the capability statement with an explicit
versioning-state and desired-version provenance prerequisite in the example,
rationale, validation, and acceptance criteria.

### T2-2: Inherited Bash xtrace exposes the HCP token

**Severity:** High

The proposed HCP prose says not to use `set -x`, but a caller can already have
xtrace enabled. A `( ... )` subshell inherits that state. The early assignment:

```bash
TFC_TOKEN=${TFC_TOKEN:?Set TFC_TOKEN to an HCP Terraform API token that can read state versions.}
```

is printed after expansion, exposing the token before curl starts.

This review reproduced the exposure using the exact proposed block, a synthetic
sentinel token, and a stubbed `curl`; no network request was made.

Make:

```bash
set +x
```

the first command inside the HCP subshell, before `umask`, host/path/page
validation, token expansion, or any other command. Do not re-enable tracing.

Also harden the value inserted into curl's stdin configuration. Curl config is
line-oriented and quoted values recognize escape syntax; curl's header handling
does not sanitize CR/LF. Reject CR, LF, and any other character that would
escape the selected config representation, or encode the header through a
mechanism whose exact grammar is validated. Do not invent a brittle complete
token regex unless HashiCorp documents it as normative.

Acceptance must execute an inherited-xtrace test:

1. start Bash with xtrace already enabled;
2. use a synthetic sentinel token;
3. stub curl and prohibit network access;
4. run the exact block intended for publication;
5. capture complete stdout, stderr/xtrace, and the stub's argument vector;
6. require the first traced command in the subshell to be `set +x`; and
7. require the sentinel to appear in neither output nor process arguments.

Add malformed config-value cases to prove they fail before response-file
creation or a provider call.

**Required revision:** Add first-command trace disabling, safe config-value
validation, and executable sentinel tests to the example, rationale,
validation, and acceptance criteria.

### T2-3: The HCP endpoint excludes Europe and the page input is unvalidated

**Severity:** Medium to high

T2 hardcodes:

```text
https://app.terraform.io/api/v2/state-versions
```

HashiCorp also hosts HCP Terraform Europe at `app.eu.terraform.io`. A closed
region/host selector should accept exactly:

- `app.terraform.io`; and
- `app.eu.terraform.io`.

Reject every other value before token expansion. Do not accept an arbitrary URL
or generic `TFC_ADDRESS`, because that turns a typo or hostile environment value
into a bearer-token destination. If Terraform Enterprise is out of scope, say
so. Supporting arbitrary Enterprise hosts requires a separate trust,
certificate, redirect, and token-destination contract.

`TFC_PAGE_NUMBER=${TFC_PAGE_NUMBER:-1}` defaults but does not validate a
supplied value. Require a positive decimal integer before response-file
creation. Keep page size 100, required organization/workspace filters,
`status=finalized`, and continuation until `meta.pagination.next-page` is
`null`; those match HashiCorp's current API documentation.

**Required revision:** Add closed US/Europe host selection, explicit Enterprise
scope, positive-page validation, and accepted/rejected host/page tests.

### T2-4: The state-safety quantifier is broader than the inventoried changes

**Severity:** Medium

T2's concrete work targets the S3, Azure, GCS, and HCP state-version examples,
but its acceptance language says “every recovery destination” is protected and
no-clobber and its security section speaks generally about recovered state.

The live source documents contain other nearby state operations, including:

- `terraform state pull` redirected to local backup paths;
- `terraform show -json ... | head -50` for backup inspection;
- `terraform state push`;
- state removal commands;
- a second prefix-only S3 version listing; and
- other manual corruption/reconstruction guidance.

Choose one explicit scope:

1. inventory and harden every state backup, discovery, inspection, recovery,
   and destructive example in both source documents; or
2. limit T2 to the four named provider/API blocks, narrow every universal
   acceptance statement accordingly, and create a follow-up issue listing the
   remaining source locations.

The second choice is more consistent with T2's title and six-file implementation
scope. The provider-neutral sensitive-state warning should remain, but it must
not imply that untouched adjacent examples acquired protections they do not
have.

**Required revision:** Add a complete source-location inventory or narrow the
quantifier and record the omitted state-handling examples as follow-up work.

### T2-5: Shell safety is reviewed but not executed

**Severity:** Medium to high

T2's validation runs generation, Markdown lint, whitespace checks, content
searches, and CI. It does not run `bash -n` or prove the control-flow,
argument-boundary, no-overwrite, host-selection, pagination, and secret-trace
properties on which acceptance depends.

Require a non-network implementation-time harness that extracts the exact Bash
blocks intended for publication and:

- runs `bash -n`;
- stubs `aws`, `az`, `gcloud`, and `curl`;
- fails missing, empty, relative, existing-file, existing-directory, symlink,
  and dangling-link destinations before any provider call;
- proves paths containing spaces and shell metacharacters remain one literal
  argument;
- proves version IDs and generations reach the stub unchanged;
- proves exact-object filters and Azure/GCS no-overwrite flags;
- proves no block overwrites a local file;
- validates S3 versioning prerequisites without a real backend;
- tests both allowed HCP hosts and arbitrary-host rejection;
- tests positive and invalid page numbers;
- tests config-breaking token values;
- performs the inherited-xtrace sentinel test; and
- retains/labels an invalid protected HCP response file after a simulated curl
  failure.

The harness may be a temporary artifact outside the repository rather than a
seventh T2 implementation file. It must never make a network request and must
capture enough output to prove the expected rejection reason, not merely a
nonzero exit.

**Required revision:** Add executable non-network shell evidence as an
acceptance prerequisite.

## Confirmed strengths to preserve

- T1 before T2 is the correct dependency order.
- T1 correctly identifies all four generator serialization boundaries and
  leaves the already-correct LF-joined frontmatter construction alone.
- The explicit-root, full-component, strict-containment, repeated-validation,
  and no-competing-writer model is strong.
- The five mandatory helper parameters and three optional diagnostic labels
  intentionally match P1.
- Retaining repository-local helpers while comparing observable contracts is
  the right current unification boundary.
- The permanent harness, immutable artifact ID/digest, explicit download
  integrity inputs, malformed-transport drill, diagnostic artifacts, and
  edition/EOL matrix are strong designs.
- T1's exact remote observation, native full object-ID handling, explicit
  refspec, exact expected-SHA lease, staged/committed blob proof, and no-retry
  rule should remain.
- Review-only weekly GitHub Actions Dependabot governance now appropriately
  matches P1; it does not replace immutable pins or human review.
- T2 correctly separates discovery from recovery and requires deliberate
  identifier selection.
- T2's exact-key provider filters, Azure non-HNS scope and
  `--overwrite false`, GCS Object Versioning/soft-delete distinction and
  `--no-clobber`, and HCP `/state-versions` filters are well researched.
- The HCP use of `curl -q --config -`, a pre-opened noclobber descriptor,
  restrictive `umask`, explicit error handling, and retention of invalid
  partial output is materially safer than the current guide once the trace,
  host, page, and config-value gaps are closed.
- T2 correctly treats state and Archivist URLs as sensitive and avoids
  automatic selection or rollback.

## Recommended final slate

1. Revise T1 to use one held archive stream with explicit `FileShare.Read` from
   digest through extraction.
2. Align T1's checkout/setup-node pins, Node 24 lint behavior, and executable
   pin validation with P1.
3. Define the unique temporary-root factory and owned cleanup for every helper
   consumer.
4. Replace T1's grouped harness table and blanket rejection oracle with stable
   IDs and case-specific postconditions.
5. Bind local validation to in-child edition assertions and normalize the
   writer's environment/ref contract.
6. Refresh T2's prerequisite and non-goals from the final T1.
7. Make the S3 versioning prerequisite operationally exact.
8. Add first-command xtrace disabling, safe curl-config input handling, closed
   US/Europe HCP host selection, and positive-page validation.
9. Resolve T2's state-example scope and require executable non-network shell
   evidence.
10. Add T3 after T2 for the npm advisory graph and npm Dependabot entry.

With those corrections, the slate provides a defensible cross-repository
direction: shared observable generator and artifact-boundary behavior converges
where it should, while manifest names, source documents, and genuinely
repository-specific details remain explicit.

## Primary references

### Repository and generator/workflow maintenance

- [TerraformStyleGuide `main` reviewed commit](https://github.com/franklesniak/TerraformStyleGuide/commit/6ee3f57b2b71b885a5927b770dde47532944de62)
- [Microsoft Learn: `Get-FileHash`](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/get-filehash)
- [.NET `FileStream`](https://learn.microsoft.com/dotnet/api/system.io.filestream)
- [.NET `FileShare`](https://learn.microsoft.com/dotnet/api/system.io.fileshare)
- [.NET `Path.GetRandomFileName`](https://learn.microsoft.com/dotnet/api/system.io.path.getrandomfilename)
- [Node.js release status](https://nodejs.org/en/about/previous-releases)
- [checkout v7.0.1](https://github.com/actions/checkout/releases/tag/v7.0.1)
- [setup-node v7.0.0](https://github.com/actions/setup-node/releases/tag/v7.0.0)
- [upload-artifact v7.0.1](https://github.com/actions/upload-artifact/releases/tag/v7.0.1)
- [download-artifact v8.0.1](https://github.com/actions/download-artifact/releases/tag/v8.0.1)
- [GitHub Docs: Dependabot for GitHub Actions](https://docs.github.com/en/code-security/how-tos/secure-your-supply-chain/secure-your-dependencies/auto-update-actions)
- [GitHub Docs: Dependabot supported ecosystems](https://docs.github.com/en/code-security/reference/supply-chain-security/supported-ecosystems-and-repositories)
- [npm: `npm audit`](https://docs.npmjs.com/cli/commands/npm-audit)

### State recovery and shell behavior

- [Amazon S3 Versioning](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html)
- [Amazon S3 `GetBucketVersioning`](https://docs.aws.amazon.com/AmazonS3/latest/API/API_GetBucketVersioning.html)
- [AWS CLI `list-object-versions`](https://docs.aws.amazon.com/cli/latest/reference/s3api/list-object-versions.html)
- [AWS required permissions](https://docs.aws.amazon.com/AmazonS3/latest/userguide/using-with-s3-policy-actions.html)
- [Azure Blob Versioning](https://learn.microsoft.com/azure/storage/blobs/versioning-overview)
- [Azure CLI blob commands](https://learn.microsoft.com/cli/azure/storage/blob)
- [Google Cloud Object Versioning](https://cloud.google.com/storage/docs/object-versioning)
- [Google Cloud soft delete](https://cloud.google.com/storage/docs/soft-delete)
- [HCP Terraform state-version API](https://developer.hashicorp.com/terraform/cloud-docs/api-docs/state-versions)
- [HCP Terraform API overview and pagination](https://developer.hashicorp.com/terraform/cloud-docs/api-docs)
- [HCP Terraform in Europe](https://developer.hashicorp.com/terraform/cloud-docs/europe)
- [GNU Bash `set`, xtrace, and noclobber](https://www.gnu.org/software/bash/manual/html_node/The-Set-Builtin.html)
- [curl manual](https://curl.se/docs/manpage.html)
- [curl credential-handling FAQ](https://curl.se/docs/faq.html)
