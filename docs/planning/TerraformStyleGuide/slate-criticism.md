# TerraformStyleGuide T1/T2 slate criticism

## Overall assessment

The slate has a sound overall sequence: T1 establishes a deterministic, immutable
documentation artifact, and T2 then changes sensitive state-recovery guidance on
top of that trustworthy baseline. The provider research in T2 is substantially
stronger than the guidance it replaces.

I would not implement the slate unchanged, however. The revised
[PowerShell P1](../PSStyleGuide/01PSStyleGuideP1.md) now defines an explicit
cross-repository contract that [Terraform T1](./03TerraformStyleGuideT1.md) no
longer satisfies. T2 also has two credential/state-safety gaps and does not fully
account for the other backup and recovery examples already in the Terraform
guide.

The recommended order is:

1. Bring T1's helper contract, test harness, and action pins into alignment with
   P1.
2. Update T2's prerequisite language to describe that revised T1.
3. Correct the HCP Terraform example and decide explicitly whether T2 or a
   follow-up issue owns the remaining state backup/recovery snippets.

## Findings

### T1-1 — The helper no longer satisfies the shared P1/T1 trust-boundary contract

Priority: High

T1 asks the extraction helper for three logical inputs and derives the checkout
root from the helper's installed location. It checks that the download and
candidate directories are outside the checkout and that their immediate parent
is ordinary. That is useful, but it does not establish a trusted filesystem
envelope for the work.

Revised P1 intentionally makes the following mandatory scalar parameters a
P1/T1 alignment contract:

- `CheckoutRoot`
- `TrustedTemporaryRoot`
- `DownloadDirectory`
- `CandidateDirectory`
- `ExpectedDigest`

It also defines optional, caller-owned diagnostic parameters for `ArtifactId`,
`RunId`, and `RunAttempt`, and prohibits ambient Git, GitHub, or current-directory
discovery.

The distinction matters. Merely being outside the checkout is not enough if an
existing ancestor below the temporary root is a symlink or Windows reparse point,
or if a path is exchanged after the initial validation. P1 requires the work
paths to be strict descendants of an explicit trusted temporary root, the
checkout to be disjoint from that root, every existing component below the root
to be ordinary, and the relevant checks to be repeated immediately before
opening the archive and creating the candidate.

**Recommendation:** Give T1 the same public helper interface and path semantics
as P1. Keep the implementations repository-specific where necessary, but do not
create two meanings for the same extraction boundary. State explicitly that:

- all five security-sensitive values are mandatory scalar arguments;
- optional run labels are supplied only for diagnostics;
- all paths are canonicalized and compared with platform-appropriate semantics;
- download and candidate paths are strict descendants of the trusted temporary
  root and disjoint from the checkout;
- existing descendants are walked for symlinks/reparse points; and
- the checks are repeated at the last safe points before archive access and
  candidate creation.

This is the most important cross-repository correction because the two issues
currently claim a shared architecture while specifying materially different
trust models.

### T1-2 — The permanent fixture suite has no tracked single source of truth

Priority: High

T1 describes a permanent helper self-test, but it does not add a tracked test
file. Instead, each workflow job is expected to recreate the fixtures and
assertions. That makes drift between jobs likely and leaves local validation
without the same executable contract used in CI.

Revised P1 resolves this by adding
`Test-Expand-StyleGuideCandidateArtifact.ps1` as the sole fixture definition.
Pre-merge jobs invoke it on Ubuntu PowerShell and on Windows PowerShell 5.1 and
PowerShell 7 using LF checkouts; every push consumer invokes the same harness.

**Recommendation:** Add the corresponding tracked Terraform harness and list it
as an affected file. It should own all positive, negative, and adversarial
fixtures, including digest mismatch, archive-shape rejection, checkout overlap,
untrusted ancestors, dangling links, and existing candidate behavior. Workflow
jobs should only supply paths and invoke the harness.

Run the harness:

- locally under every available PowerShell edition;
- pre-merge on Ubuntu PowerShell plus the two Windows LF cells; and
- in every push consumer before the candidate is used.

There is no helper behavior unique to the CRLF matrix cells, so duplicating the
full fixture suite in all four Windows pre-merge cells adds cost without adding
a distinct contract. The generated-document comparisons should, of course,
remain in the full line-ending matrix.

### T1-3 — The checkout action remains a moving Node 20-era tag

Priority: High and time-sensitive

T1 pins `actions/upload-artifact` and `actions/download-artifact`, but leaves
`actions/checkout@v4` untouched in both `build.yml` and `markdownlint.yml`.
That is inconsistent with the slate's exact-pin policy and with revised P1,
which deliberately moves checkout to the Node 24 generation.

**Recommendation:** Add `markdownlint.yml` to T1's affected files and replace
only the checkout reference in both workflows with the full commit for
`actions/checkout` v6.0.2:

```text
de0fac2e4500dabe0009e67214ff5f5447ce83dd
```

Retain the readable version comment used by the other pins. Reconfirm the commit
and release immediately before implementation. This makes the intended T1
implementation scope six files:

1. `.gitattributes`
2. `Generate-StyleGuide.ps1`
3. `Expand-StyleGuideCandidateArtifact.ps1`
4. `Test-Expand-StyleGuideCandidateArtifact.ps1`
5. `build.yml`
6. `markdownlint.yml`

T1's References section should also cite the artifact actions' source at the
exact pinned commits, not mutable version-tag URLs. Release pages are useful
additional evidence, but they are not a substitute for the source that will
actually execute.

### T1/T2-1 — T2's prerequisite contract is already stale

Priority: High

T2 currently treats four T1 implementation paths as prerequisites, versions only
the generator and helper, expects the helper suite in all four Windows
pre-merge cells, and mentions only the artifact action pins. Those statements
match the older T1 draft, not the revised shared architecture.

If T1 is corrected as above, T2's readiness checklist and non-goals would be
factually wrong on the day T1 closes. That weakens the sequential issue boundary:
an implementer could satisfy T2's written prerequisite checks while missing the
tracked harness, explicit trusted-root contract, or checkout pin.

**Recommendation:** Revise T2 after revising T1. Its prerequisites should verify:

- the generator, extraction helper, and tracked harness versions;
- the explicit checkout/trusted-temporary-root helper interface;
- the shared harness in Ubuntu and both Windows LF pre-merge environments;
- the harness in every push consumer;
- exact checkout, upload-artifact, and download-artifact pins; and
- all six T1 implementation paths.

Its T1 non-goals list should name the same six paths. This is more durable than
restating an older workflow layout in T2.

### T2-1 — The HCP Terraform example is unsafe when shell tracing is inherited

Priority: High

T2 says not to use `set -x`, but its proposed HCP Terraform subshell does not
actively disable inherited tracing before it expands `TFC_TOKEN`. A caller can
enter the block with xtrace already enabled. In that case, an assignment such as
`TFC_TOKEN=${TFC_TOKEN:?...}` emits the expanded token in the trace even though
the token is correctly kept out of the curl process arguments.

This is not merely theoretical: executing the proposed assignment under inherited
`set -x` prints the token value to the trace stream.

**Recommendation:** Make `set +x` the first command in the HCP subshell, before
any token expansion, validation, assignment, or curl configuration is built.
Keep the current stdin-fed curl configuration and exclusive output descriptor;
those are good controls for process-list and overwrite exposure.

Add an executable acceptance check that starts the block with xtrace enabled,
uses a sentinel token and a stub curl command, and asserts that the sentinel
appears in neither captured trace output nor process arguments. A prose
prohibition cannot verify behavior inherited from the surrounding shell.

### T2-2 — The HCP Terraform API hostname is not repository-generic

Priority: Medium

T2 hardcodes `https://app.terraform.io/api/v2/state-versions`. HCP Terraform
organizations can also reside in HCP Europe, whose service uses the
`app.eu.terraform.io` hostname. A general “HCP Terraform” recovery example that
only works for the global environment is therefore incomplete.

This should not be fixed with an unrestricted arbitrary base URL: the bearer
token is sent to that host, so accepting an unvalidated endpoint creates a
credential-exfiltration footgun.

**Recommendation:** Require an explicitly selected HCP Terraform environment and
validate it against the documented HCP Terraform hostnames before constructing
the API URL. Provide the standard-host example and a verified HCP Europe
alternative. Reject non-HTTPS and unrecognized hosts. If Terraform Enterprise is
intentionally out of scope, say so; do not silently imply that the hardcoded
global host covers every HCP Terraform organization.

The final implementation should verify the exact Europe API URL against current
HashiCorp documentation rather than infer it only from the web-console hostname.

### T2-3 — The stated safety invariant does not cover the guide's other state commands

Priority: High

T2's acceptance criteria say every recovery destination is absolute, protected,
new, and no-clobber. The issue inventory, however, is limited mainly to the four
provider/API recovery blocks. The current guide and rationale also contain
adjacent state operations such as:

- `terraform state pull > terraform.tfstate.backup`;
- `terraform show -json ... | head -50`;
- `terraform state push terraform.tfstate.backup`;
- deletion of local state and backup files; and
- a second S3 version-listing example that filters only by prefix.

Those examples remain inconsistent with T2's universal wording. Relative shell
redirection can overwrite an existing file and inherits the caller's umask.
Printing state JSON to a terminal can expose sensitive values. Prefix-only S3
listing reintroduces the collision problem that T2 correctly fixes in its
primary example. The deletion example also carries operating-system assumptions
despite T2 explicitly avoiding an OS-specific workflow.

**Recommendation:** Choose and document one of two scopes:

1. Expand T2's inventory and harden all backup, inspection, restore, and
   provider-version examples in both `STYLE_GUIDE.md` and the rationale; or
2. Narrow T2's acceptance language to the four provider/API blocks and add a
   sequential T3 dedicated to local/manual state backup, inspection, restore,
   deletion, and duplicate recovery examples.

The second option is likely easier to review and keeps T2 focused, but it must be
explicit. At minimum, the duplicate S3 listing should not survive with weaker
key-matching guidance than the primary S3 block.

### T2-4 — Copy-safety needs executable validation, not only generated-text checks

Priority: Medium

T2's planned generator, Markdown, link, and whitespace checks confirm that the
documents reproduce cleanly. They do not establish that the shell blocks parse
or that their fail-closed gates prevent a provider command from running.

The examples are security-sensitive enough to justify a small deterministic
test harness during implementation. It need not contact any cloud service or
become a permanent repository feature.

**Recommendation:** In addition to the existing document checks:

- run `bash -n` over the exact Bash blocks extracted from the generated guide;
- substitute stub `aws`, `az`, `gcloud`, and `curl` commands;
- assert that missing, relative, existing, and dangling-link destinations stop
  before the stub provider command is invoked;
- assert that sentinel files are never overwritten;
- exercise spaces and shell metacharacters in safe path values; and
- include the inherited-xtrace credential check from T2-1.

This turns “copy-safe” from a review judgment into repeatable evidence without
requiring credentials or network access.

## Confirmed strengths

The following parts should be preserved:

- The T1/T2 ordering and exact artifact-digest handoff are appropriate.
- T1 correctly keeps the immutable candidate separate from the checked-out
  branch and uses a lease-protected writer.
- Adding `.gitattributes` in TerraformStyleGuide is repository-specific and
  necessary; the Terraform generator's frontmatter is already LF-joined, so it
  should not copy an unnecessary PowerShellStyleGuide change.
- T2's exact S3-key query, general-purpose-bucket versioning caveat, and
  provider-specific KMS permission reconciliation are materially better than the
  current placeholder.
- T2 correctly distinguishes Azure Blob versioning constraints, GCS object
  versions from soft delete, and cloud-native object recovery from local
  Terraform state rollback.
- The HCP Terraform plan correctly filters by organization, workspace, and
  uploaded status; treats pagination as manual and bounded; keeps the token out
  of command-line arguments; and treats state download URLs as sensitive.
- The common destination guards, `umask 077`, dangling-symlink check, exclusive
  file creation, and partial-file cleanup are a strong shared baseline.

## Primary references used for this review

- [GitHub Actions: checkout v6.0.2 release](https://github.com/actions/checkout/releases/tag/v6.0.2)
- [GitHub Actions: checkout exact pinned source](https://github.com/actions/checkout/tree/de0fac2e4500dabe0009e67214ff5f5447ce83dd)
- [GitHub: Node 20 runner-action deprecation](https://github.blog/changelog/2025-09-19-deprecation-of-node-20-on-github-actions-runners/)
- [HashiCorp: HCP Terraform API overview](https://developer.hashicorp.com/terraform/cloud-docs/api-docs)
- [HashiCorp: state versions API](https://developer.hashicorp.com/terraform/cloud-docs/api-docs/state-versions)
- [HashiCorp: HCP Terraform Europe](https://developer.hashicorp.com/terraform/cloud-docs/europe)
- [HashiCorp: HCP Terraform security model](https://developer.hashicorp.com/terraform/cloud-docs/architectural-details/security-model)
- [AWS: S3 API permission mapping](https://docs.aws.amazon.com/AmazonS3/latest/userguide/using-with-s3-policy-actions.html)
- [AWS CLI: list object versions](https://docs.aws.amazon.com/cli/latest/reference/s3api/list-object-versions.html)
- [Microsoft: Azure Storage blob CLI](https://learn.microsoft.com/en-us/cli/azure/storage/blob?view=azure-cli-latest)
- [Microsoft: Blob versioning overview](https://learn.microsoft.com/en-us/azure/storage/blobs/versioning-overview)
- [Google Cloud CLI: storage ls](https://docs.cloud.google.com/sdk/gcloud/reference/storage/ls)
- [Google Cloud CLI: storage cp](https://docs.cloud.google.com/sdk/gcloud/reference/storage/cp)
- [curl command-line reference](https://curl.se/docs/manpage.html)
