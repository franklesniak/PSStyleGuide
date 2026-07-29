# TerraformStyleGuide T1/T2 slate criticism

## Overall assessment

The proposed order is correct: T1 should establish deterministic generation,
artifact validation, and controlled publication before T2 changes the generated
guide and rationale. T2's provider-specific recovery research is substantially
stronger than the repository's current examples.

The slate should not be implemented unchanged, however. T1 says it is aligned
with the revised PowerShell P1 contract, but its helper interface, trust
boundaries, byte-consumption model, and permanent-test plan are materially
weaker. T1 also leaves moving GitHub actions and the repository's Node 20 lint
runtime in place. Because T2 names the exact implementation delivered by T1 as
a prerequisite, correcting T1 requires a corresponding rewrite of T2's
prerequisite and validation sections.

T2 has four remaining safety gaps: inherited shell tracing can expose the HCP
Terraform token, the HCP API hostname assumes only the US service, the promised
state-safety scope is broader than the examples actually inventoried, and the
copy-safety rules are not exercised by an executable non-network harness.

## Evidence baseline

This review compared:

- the revised [PowerShell P1](../PSStyleGuide/01PSStyleGuideP1.md) and
  [PowerShell P2](../PSStyleGuide/02PSStyleGuideP2.md);
- the proposed [Terraform T1](./03TerraformStyleGuideT1.md) and
  [Terraform T2](./04TerraformStyleGuideT2.md);
- TerraformStyleGuide `main` at commit
  [`6ee3f57b2b71b885a5927b770dde47532944de62`](https://github.com/franklesniak/TerraformStyleGuide/commit/6ee3f57b2b71b885a5927b770dde47532944de62);
- the live
  [`build.yml`](https://github.com/franklesniak/TerraformStyleGuide/blob/6ee3f57b2b71b885a5927b770dde47532944de62/.github/workflows/build.yml),
  [`markdownlint.yml`](https://github.com/franklesniak/TerraformStyleGuide/blob/6ee3f57b2b71b885a5927b770dde47532944de62/.github/workflows/markdownlint.yml),
  and
  [`Generate-StyleGuide.ps1`](https://github.com/franklesniak/TerraformStyleGuide/blob/6ee3f57b2b71b885a5927b770dde47532944de62/Generate-StyleGuide.ps1);
- the current dependency lock and a clean `npm audit` at that exact commit; and
- current GitHub, Microsoft, Google, AWS, and HashiCorp primary documentation
  linked in the relevant findings below.

At that commit, `.gitattributes` is absent, the generator still targets
PowerShell 5.1 and uses four `Set-Content -Encoding UTF8 -NoNewline` calls,
`build.yml` uses moving `actions/checkout@v4` and
`actions/upload-artifact@v4`, and `markdownlint.yml` uses moving
`actions/checkout@v4`, moving `actions/setup-node@v4`, and Node 20.

## Findings

### T1-1: The helper is not aligned with the revised P1 trust contract

**Severity:** High

T1 repeatedly describes its helper as aligned with PowerShell P1, but the
specified interface accepts only three logical inputs:

- download directory;
- candidate directory; and
- expected digest.

It derives the checkout root from the helper's own fixed location, has no
explicit trusted temporary root, and mentions artifact ID, run ID, and run
attempt in diagnostics only "when available." There are no caller-owned
optional parameters through which those values become available.

The revised P1 target contract deliberately requires five scalar path/digest
inputs:

- `CheckoutRoot`;
- `TrustedTemporaryRoot`;
- `DownloadDirectory`;
- `CandidateDirectory`; and
- `ExpectedDigest`.

It also defines optional scalar `ArtifactId`, `RunId`, and `RunAttempt`
diagnostic inputs. That interface supports validation of both important
relationships: the untrusted download and candidate paths must be strict
descendants of the caller-established trusted temporary root, and the checkout
must be disjoint from that root. A helper-local assumption about repository
layout cannot prove either relationship on the caller's behalf.

T1 should adopt the stronger contract rather than declaring a reduced interface
equivalent. Its path-validation phase should explicitly require:

1. scalar, nonempty inputs with no wildcards;
2. filesystem-provider paths only, including rejection of registry, variable,
   function, alias, and other provider-qualified paths;
3. normalization against an explicit base for relative inputs;
4. component-by-component inspection of every existing ancestor;
5. rejection of symlink, junction, mount-point, and other reparse components;
6. strict-descendant proofs for download and candidate paths under the trusted
   temporary root;
7. checkout/trusted-root disjointness in both directions;
8. platform-appropriate case comparison;
9. a final "last safe moment" revalidation immediately before opening the ZIP;
   and
10. a final destination revalidation immediately before the candidate becomes
    visible.

These are not PowerShell-specific embellishments. They define the trust
boundary for an artifact produced by another job and consumed before a possible
repository write.

**Required revision:** Replace the three-input helper interface with the revised
P1 five-input plus three-optional-diagnostic interface, and copy the complete
relationship and reparse-point requirements into T1 in Terraform-specific
language.

### T1-2: The verified bytes are not bound to the consumed ZIP stream

**Severity:** High

T1 calculates the SHA-256 digest with `Get-FileHash -Path` and later opens the
same pathname again for ZIP inspection. This proves that some bytes at that path
were hashed; it does not bind the bytes subsequently parsed and extracted to
the successfully verified stream.

The helper should instead:

1. finish path and component validation;
2. open the archive once as a read-only, seekable `FileStream` with restrictive
   sharing;
3. hash that held stream with `Get-FileHash -InputStream`;
4. compare the normalized digest in constant, ordinal form;
5. rewind the same stream to position zero; and
6. construct `ZipArchive` over that still-held stream for validation and
   extraction.

The stream should remain open until archive processing is complete. Path
revalidation is still necessary, but it is not a substitute for consuming the
same byte stream that passed the digest check.

**Required revision:** Rewrite the digest, archive-open, and extraction phases
around one held stream. Update every corresponding acceptance criterion and
fixture expectation.

### T1-3: The "permanent helper self-test" has no tracked fixture oracle

**Severity:** High

T1 calls its test plan permanent, but its affected-files list contains no test
script. Instead, workflow jobs are expected to construct and evaluate fixtures
inline. That invites the Ubuntu and Windows cells to drift and leaves no single
reviewable definition of the helper's security contract.

The grouped outcome table is also not yet an executable oracle:

- it promises stable fixture IDs but supplies no IDs;
- several distinct failure modes are grouped into one row;
- failure phases are not named consistently;
- required diagnostic fields are not specified per case;
- candidate-tree postconditions are not specified per case; and
- several boundary cases from the revised P1 suite are absent or ambiguous.

T1 should add a tracked fixture harness, for example
`.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1`. The harness
should be the sole fixture constructor and outcome oracle used by all
PowerShell cells.
Give every fixture a stable ID and record:

- platform or precondition;
- exact inputs;
- expected success or named failure phase;
- required diagnostic fields;
- expected candidate-tree postcondition; and
- whether the helper may have created any destination content.

At minimum, the matrix should independently cover:

- valid absolute, relative, and filesystem-provider-qualified inputs;
- non-filesystem provider rejection;
- missing, empty, wildcarded, and multi-valued inputs;
- download/candidate equality and ancestor/descendant inversions;
- checkout/trusted-root equality and nesting in either direction;
- platform-appropriate case behavior;
- optional diagnostic fields absent, empty, and populated;
- symlink/reparse components at each security-relevant level;
- missing archive, multiple archives, digest mismatch, and archive replacement
  attempts;
- duplicate entries, duplicate manifest, missing manifest, unexpected entries,
  directory entries, absolute paths, drive-qualified paths, traversal, mixed
  separators, malformed ZIP metadata, and excessive size/count;
- manifest/guide/rationale digest or length mismatch;
- pre-existing candidate destination, dangling-link destination, and simulated
  publish failure; and
- success with byte-for-byte expected output and no extra files.

The pre-merge topology should also follow the revised P1 structure:

- Ubuntu with PowerShell 7;
- Windows with Windows PowerShell and LF source;
- Windows with PowerShell 7 and LF source; and
- separate CRLF generation/build consumers where needed.

All four push consumers should always start. The three validation cells should
run for both drift and no-drift fixtures, while only the selected writer may
enter mutation steps when `has_changes == 'true'`. The CRLF cells do not need
to duplicate helper tests whose behavior is independent of generator source
line endings.

**Required revision:** Add the tracked harness to the affected files, version
it with the helper, replace the grouped prose table with stable fixture rows,
and make every matrix cell invoke that harness.

### T1-4: Action and runtime modernization is incomplete

**Severity:** High and time-sensitive

T1 pins only artifact upload and download actions. That leaves both workflows'
checkout actions moving, and it leaves the lint workflow on a moving
`setup-node@v4` plus Node 20. This is inconsistent with T1's own
reproducibility and supply-chain goals.

The revised P1 already records the current exact modernization target:

- `actions/checkout` v7.0.1 at
  `3d3c42e5aac5ba805825da76410c181273ba90b1`;
- `actions/setup-node` v7.0.0 at
  `820762786026740c76f36085b0efc47a31fe5020`; and
- Node 24 with package-manager caching explicitly disabled unless the issue
  deliberately enables and constrains it.

GitHub's action metadata and release notes should still be rechecked at
implementation time. The exact SHA, release tag, and relevant runtime behavior
should be recorded together, just as T1 already requires for artifact actions.

`markdownlint.yml` should also receive explicit least-privilege
`permissions: contents: read`. The build workflow may grant `contents: write`
only to the selected writer job or otherwise at the narrowest practical scope;
validation jobs do not need write permission.

After adding the fixture harness, the corrected T1 affected-file set should be
six paths:

1. `.gitattributes`;
2. `Generate-StyleGuide.ps1`;
3. `.github/workflows/Expand-StyleGuideCandidateArtifact.ps1`;
4. `.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1`;
5. `.github/workflows/build.yml`; and
6. `.github/workflows/markdownlint.yml`.

The staged-path allowlist, evidence map, implementation sequence, rollback
plan, and non-goals must all use this same six-path set.

**Required revision:** Include checkout and setup-node pinning, Node 24,
least-privilege lint permissions, and `markdownlint.yml` in T1's implementation
scope and acceptance criteria.

### T1-5: The writer contract needs final normalization

**Severity:** Medium

T1's writer is much improved: it copies target values into locals, resolves a
native full object ID, requires an exact `ls-remote` observation, and uses an
exact lease and fully qualified refspec. The remaining requirements should be
made as explicit as they are in revised P1:

- validate the complete target ref with `git check-ref-format`, not only the
  `refs/heads/` prefix;
- reject whitespace, carriage return, and line feed in all control values;
- copy the target ref and expected SHA at the first executable lines of the
  mutation block and never reread their environment variables;
- use only the validated local ref in parent and remote proofs; and
- ensure controlled failure drills mutate only the intended local test input,
  never the real environment or remote reference.

**Required revision:** Copy the revised P1 writer normalization and drill
constraints into T1, preserving T1's already-strong exact-lease behavior.

### T1/T2-1: T2's prerequisite becomes stale when T1 is corrected

**Severity:** High

T2 currently names a four-file T1 implementation, versions only the generator
and helper, describes all four PR cells as Windows harness consumers, carries
forward path-based hashing, and discusses only the artifact action pins.

After the T1 corrections above, T2 must require the exact delivered versions of
the generator, helper, and fixture harness, and must name the six implementation
paths. Its prerequisite evidence should confirm:

- the five required and three optional helper parameters;
- same-held-stream digest and ZIP consumption;
- the exhaustive, stable-ID fixture oracle;
- the actual Ubuntu/Windows Desktop/Windows Core topology;
- all four push consumers starting on every push;
- writer-only mutation on drift;
- exact checkout, setup-node, upload, and download pins;
- Node 24 and lint-workflow permissions; and
- successful LF and CRLF generated-output validation.

T2 should fail closed if the repository does not match that delivered T1
contract. It should not preserve obsolete T1 details merely because they appear
in the current draft.

**Required revision:** Regenerate T2's dependency gate, affected-file evidence,
and validation references from the corrected final T1.

### T2-1: The HCP example can expose the token under inherited xtrace

**Severity:** High

Saying "do not use `set -x`" does not neutralize tracing inherited from the
caller's shell. In the current proposed block, the parameter expansion that
validates `TFC_TOKEN` may itself be traced before the script has disabled
anything, exposing the token in a terminal transcript or CI log.

The HCP example should execute in a subshell and make `set +x` its first command
before any token expansion, validation, header construction, or `curl`
invocation. It should avoid placing the token in process arguments or error
messages and should keep the authorization header inside the command boundary.

Acceptance must test this, not merely inspect it. Run the exact published block
with tracing already enabled, a sentinel token, and stubbed `curl`; then prove
that the sentinel appears in neither captured trace output nor the stub's
recorded argument list.

**Required revision:** Add first-command trace disabling and an inherited-xtrace
sentinel test to the HCP acceptance criteria.

### T2-2: The HCP API host assumes only the US service

**Severity:** Medium to high

The proposed example hardcodes `https://app.terraform.io`. HCP Terraform Europe
uses `https://app.eu.terraform.io`, as documented in
[HCP Terraform Europe](https://developer.hashicorp.com/terraform/cloud-docs/europe).
Silently encouraging users to substitute an arbitrary hostname would be worse,
because a bearer token could then be sent to an attacker-controlled endpoint.

The issue should choose an explicit environment selector or validated API-host
allowlist covering the standard and Europe services. Require HTTPS and reject
all other hosts before token handling. If Terraform Enterprise is intentionally
out of scope, say so; supporting arbitrary enterprise installations requires a
different trust and certificate configuration contract.

The block should also validate `TFC_PAGE_NUMBER` as a positive decimal integer
before interpolation. The current default does not prevent callers from
supplying malformed values.

HashiCorp's
[API overview](https://developer.hashicorp.com/terraform/cloud-docs/api-docs)
and
[state-version endpoint](https://developer.hashicorp.com/terraform/cloud-docs/api-docs/state-versions)
should be rechecked at implementation time for token, pagination, filter, and
temporary-download-URL behavior.

**Required revision:** Add a closed host/environment selection, HTTPS and
positive-page validation, explicit Terraform Enterprise scope, and tests for
accepted and rejected hosts.

### T2-3: The promised state-safety scope is broader than the inventory

**Severity:** High

T2 promises that every recovery destination and every displayed recovery
command is copy-safe, but its concrete inventory focuses on four provider/API
blocks. The current guide and rationale contain adjacent state commands with
the same safety implications, including:

- `terraform state pull` redirected to a local backup path;
- `terraform show -json` piped through truncating display commands;
- `terraform state push`;
- deletion commands;
- another prefix-only S3 listing; and
- legacy Azure, GCS, and HCP snippets outside the primary four blocks.

The issue needs an explicit scope decision:

1. expand T2's inventory and acceptance criteria to cover every state backup,
   inspection, recovery, and destructive example in both source documents; or
2. narrow T2's universal wording to the four named blocks and file a follow-up
   issue with an enumerated command inventory.

The first option better matches the current T2 title and acceptance language.
Whichever option is chosen, distinguish copy-safe local destinations from
provider-side non-overwrite guarantees and from destructive operations that
require separate warnings and confirmation.

**Required revision:** Add a complete source-location inventory or narrow the
claim and create an explicit follow-up. Do not retain universal acceptance
language with partial coverage.

### T2-4: Copy-safety needs executable non-network validation

**Severity:** Medium

Generator execution, Markdown linting, whitespace checks, and visual review
cannot prove shell control-flow properties. The issue should require a
non-network implementation-time harness that extracts the exact fenced Bash
blocks destined for publication and exercises them with stubbed provider
commands.

The harness should:

- run `bash -n` on each exact block;
- stub `aws`, `az`, `gcloud`, and `curl`;
- prove missing, empty, relative, existing, directory, symlink, and dangling
  destination paths fail before the provider command is called;
- prove paths containing spaces and shell metacharacters remain one literal
  argument;
- prove no example overwrites an existing local file;
- assert required version/generation selectors reach the provider command
  unchanged;
- exercise provider-side no-overwrite flags where promised; and
- perform the inherited-xtrace sentinel check from T2-1.

This may be a temporary implementation validation artifact rather than a
permanent repository file, but the issue should specify its inputs, assertions,
captured evidence, and disposal.

**Required revision:** Add this harness to the implementation plan and make its
successful output required evidence before generated-file acceptance.

### Separate maintenance observation: the Markdown dependency lock has advisories

**Severity:** Medium, not a T1/T2 blocker

A clean audit at the reviewed commit reports seven advisories in the current
lint dependency tree: five high and two moderate. The implicated locked
packages include `markdownlint-cli2` 0.20.0 and transitive packages. The
suggested upgrade crosses a pre-1.0 minor boundary, so it should not be folded
silently into T1's workflow hardening.

Create a separate maintenance issue to:

- update the lint dependency set intentionally;
- perform a clean Node 24 install;
- run outer and nested Markdown lint;
- review lockfile and command changes; and
- record the post-update audit result.

This work can proceed independently and does not change the required T1 before
T2 ordering.

## Confirmed strengths to preserve

The following parts of the slate are well founded and should survive revision:

- T1 before T2 is the right dependency order.
- T1 correctly treats line endings as repository-specific: the generator's
  PowerShell 5.1 `Set-Content -Encoding UTF8` behavior is the real portability
  concern, while the frontmatter is already assembled from LF-delimited array
  elements.
- T1's exhaustive tracked-file enumeration, normalized path comparison, exact
  candidate-leaf detection, drift/no-drift split, writer selection, full native
  object-ID resolution, exact remote observation, exact lease, and explicit
  refspec are strong improvements.
- T1 correctly requires all push consumers to start and confines mutation to
  the selected writer when drift exists.
- T2's provider-specific direction is strong: immutable identifiers rather
  than timestamp inference, explicit Azure version IDs, GCS generation-aware
  selection, HCP state-version enumeration, and destination non-overwrite
  checks are the correct foundation.
- T2's dated AWS permission reconciliation is valuable because AWS documentation
  varies by bucket class and operation. Preserve the requirement to recheck
  current primary documentation rather than flattening those distinctions into
  a universal KMS statement. Relevant sources include the
  [S3 policy-action mapping](https://docs.aws.amazon.com/AmazonS3/latest/userguide/using-with-s3-policy-actions.html),
  [SSE-KMS guidance](https://docs.aws.amazon.com/AmazonS3/latest/userguide/UsingKMSEncryption.html),
  and
  [`GetObject` API reference](https://docs.aws.amazon.com/AmazonS3/latest/API/API_GetObject.html).
- The Azure and GCS research targets are appropriate. Recheck the
  [Azure versioning limitations](https://learn.microsoft.com/en-us/azure/storage/blobs/versioning-overview),
  [Azure CLI blob commands](https://learn.microsoft.com/en-us/cli/azure/storage/blob?view=azure-cli-latest),
  [`gcloud storage ls`](https://docs.cloud.google.com/sdk/gcloud/reference/storage/ls),
  and
  [`gcloud storage cp`](https://docs.cloud.google.com/sdk/gcloud/reference/storage/cp)
  when implementing.

## Recommended final slate

1. Revise T1 to the five-input trust contract, one-held-stream archive model,
   tracked stable-ID fixture harness, six affected files, current exact action
   pins, Node 24, least-privilege permissions, and normalized writer contract.
2. Revise T2's prerequisite to the final delivered T1 contract.
3. Revise T2's HCP block for inherited tracing, closed US/Europe host selection,
   positive pagination validation, and explicit Enterprise scope.
4. Resolve T2's all-state-examples scope and require an executable non-network
   copy-safety harness.
5. Implement and merge T1 before beginning T2.
6. Track the Markdown dependency update separately so its compatibility and
   audit evidence remain reviewable.

With those changes, the two-issue sequence is a sound plan: T1 will provide a
reproducible and security-testable publication boundary, and T2 can then improve
state-recovery guidance without weakening that boundary.
