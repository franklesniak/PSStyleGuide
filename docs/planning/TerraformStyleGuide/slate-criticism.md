# TerraformStyleGuide T1/T2 slate criticism

## Overall assessment

The current T1/T2 slate is substantially improved and is close to
implementation-ready. The sequence is correct: T1 should establish deterministic
generation and a controlled synchronization boundary before T2 changes the
source guide, rationale, and generated artifacts.

T1 now includes the important architecture that was previously missing:

- explicit checkout and trusted-temporary roots;
- the same five mandatory and three optional helper parameters as P1;
- full-component path checks;
- a tracked helper-test harness;
- immutable artifact ID and digest propagation;
- pinned external actions;
- least-privileged jobs;
- an actual edition-by-EOL Windows matrix; and
- an exact-lease writer.

Those improvements should be preserved. Four T1 details still need revision,
however: the digest is not bound to the ZIP stream that is consumed, the
checkout/setup-node and Node targets lag the revised P1 and current supported
releases, the fixture table does not fulfill its own stable-ID promise, and the
writer validation remains weaker than P1.

T2's provider-specific recovery work is also strong. Its remaining gaps are
narrower: inherited Bash tracing can expose the HCP token, the HCP API host
excludes Europe, the universal state-safety wording is broader than the
inventoried examples, and shell safety is reviewed but not executed through a
non-network test harness.

## Evidence baseline

This review compared:

- the revised [PowerShell P1](../PSStyleGuide/01PSStyleGuideP1.md) and
  [PowerShell P2](../PSStyleGuide/02PSStyleGuideP2.md);
- the current proposed [Terraform T1](./03TerraformStyleGuideT1.md) and
  [Terraform T2](./04TerraformStyleGuideT2.md);
- TerraformStyleGuide `main` at
  [`6ee3f57b2b71b885a5927b770dde47532944de62`](https://github.com/franklesniak/TerraformStyleGuide/commit/6ee3f57b2b71b885a5927b770dde47532944de62);
- the live
  [`build.yml`](https://github.com/franklesniak/TerraformStyleGuide/blob/6ee3f57b2b71b885a5927b770dde47532944de62/.github/workflows/build.yml),
  [`markdownlint.yml`](https://github.com/franklesniak/TerraformStyleGuide/blob/6ee3f57b2b71b885a5927b770dde47532944de62/.github/workflows/markdownlint.yml),
  and
  [`Generate-StyleGuideArtifacts.ps1`](https://github.com/franklesniak/TerraformStyleGuide/blob/6ee3f57b2b71b885a5927b770dde47532944de62/.github/workflows/Generate-StyleGuideArtifacts.ps1);
- the live `STYLE_GUIDE.md` and `STYLE_GUIDE_RATIONALE.md`; and
- the current primary sources linked in the findings below.

At that commit, `.gitattributes` is absent. The PowerShell 5.1 generator still
has four `Set-Content -Encoding UTF8 -NoNewline` write sites. `build.yml` still
uses moving `actions/checkout@v4` and `actions/upload-artifact@v4`, while
`markdownlint.yml` still uses moving `actions/checkout@v4`,
`actions/setup-node@v4`, and Node 20.

## Findings

### T1-1: The verified digest is not bound to the consumed ZIP stream

**Severity:** High

T1 requires:

```powershell
Get-FileHash -Algorithm SHA256
```

against the retained archive path and then opens that path again for ZIP
processing. The path checks are extensive, but hashing one open and parsing a
later open does not prove that the bytes parsed are the bytes that passed the
digest comparison.

P1 already has the correct shared contract:

1. perform the component, containment, type, and leaf checks;
2. open the retained file once as a read-only, seekable `FileStream` with an
   explicitly selected restrictive sharing mode;
3. hash that stream with `Get-FileHash -InputStream -Algorithm SHA256`;
4. require exactly one valid hash result and compare it with the propagated
   digest;
5. rewind the same held stream;
6. construct one read-only `ZipArchive` over that stream;
7. use that archive through manifest validation and extraction; and
8. dispose entry streams, the archive, and the underlying stream in deterministic
   nested `try`/`finally` blocks.

Repeated path validation remains valuable, but it does not substitute for
same-stream identity.

**Required revision:** Replace T1's path-based digest section with P1's held
stream contract. Update the helper requirements, fixture expectations,
acceptance criteria, T2 prerequisite, and propagated-digest drill together.

### T1-2: The action and Node targets are stale and diverge from P1

**Severity:** High and time-sensitive

T1 is dated 2026-07-29 but prescribes:

- `actions/checkout` v6.1.0;
- `actions/setup-node` v6.5.0; and
- preservation of the lint workflow's Node 20 behavior.

The revised P1 uses the current targets:

- [`actions/checkout` v7.0.1](https://github.com/actions/checkout/releases/tag/v7.0.1)
  at `3d3c42e5aac5ba805825da76410c181273ba90b1`;
- [`actions/setup-node` v7.0.0](https://github.com/actions/setup-node/releases/tag/v7.0.0)
  at `820762786026740c76f36085b0efc47a31fe5020`;
- `node-version: '24'`; and
- `package-manager-cache: false`.

Both action commits declare the Node 24 action runtime. More importantly, the
lint process selected by `node-version` is separate from the action's own
runtime. The official
[Node release table](https://nodejs.org/en/about/previous-releases) marks Node
20 end-of-life and Node 24 LTS. T1's instruction to preserve Node 20 therefore
retains an unsupported lint runtime even if the action itself is pinned.

T1's upload-artifact v7.0.1 and download-artifact v8.0.1 pins are current and
should remain unless implementation-time verification identifies a required
newer release.

The Dependabot difference also needs an explicit decision. T1 intentionally
adds review-only GitHub Actions updates, while P1 intentionally excludes
Dependabot from scope. Repository-specific supply-chain policy can justify that
difference, but it should be labeled as intentional rather than presented as
part of the shared generator/helper contract.

**Required revision:** Align checkout, setup-node, installed Node, and cache
behavior with P1; retain explicit `contents: read` for lint. State whether
TerraformStyleGuide's Dependabot addition is an intentional repository-specific
difference. The final choice determines whether T1 has seven affected files or
six.

### T1-3: The tracked harness exists, but its oracle is not deterministic enough

**Severity:** Medium to high

Adding
`.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1` as the sole
fixture oracle is the right design. The table beneath it, however, says the
suite must use stable case identifiers without assigning any identifiers.
Several rows also combine independently meaningful cases, including:

- forward- and backslash nesting;
- forward and backward traversal;
- leading slash, leading backslash, and drive qualification;
- multiple root-overlap relationships;
- each of the three optional empty labels; and
- different reparse/symlink component locations.

That leaves the implementer to invent both the IDs and the one-to-many mapping
between a prose row and executable results. It also weakens platform-skip
accounting because a grouped row can partially execute while still appearing
covered.

There is an internal postcondition conflict as well. T1 says every rejection
fixture must leave the destination directory nonexistent, but its pre-existing
candidate file, directory, symlink, and dangling-link cases require the
pre-existing entry to remain unchanged. Those cases cannot satisfy a blanket
nonexistence assertion.

Use P1's explicit ID-and-phase table as the structural model, with
Terraform-specific manifest names. While doing so, make the postcondition
row-specific:

- pre-creation cases with no pre-existing leaf require absence;
- pre-existing-leaf cases require the exact original entry to remain unchanged;
- post-creation failure cases require safe removal of only the helper-created
  leaf or an explicit fail-closed cleanup error and retained path; and
- success cases require the complete four-file byte and type contract.

The pull-request topology should also be reconciled. T1 currently repeats the
entire helper suite in all four Windows PR cells; P1 runs it on Ubuntu and the
two Windows LF cells while reserving the CRLF cells for generator behavior.
Repeating the suite is not incorrect, but it adds CI cost without exercising a
helper behavior that depends on source-fixture EOL. Keep the broader topology
only if there is a documented Terraform-specific reason. All four push cells
should continue to run the suite because each is a real candidate consumer.

**Required revision:** Assign one stable ID to every executable case, split
grouped cases where outcome attribution matters, define exact phase,
diagnostics, and row-specific candidate postconditions, and document the chosen
PR-suite topology.

### T1-4: The writer validation remains weaker than P1

**Severity:** Medium

T1's writer already has strong exact-SHA behavior: it resolves a native full
object ID, checks exactly one `ls-remote` record, reuses a full ref in the lease
and destination refspec, and prohibits adaptation to newer history.

The remaining normalization should match P1:

- copy `TARGET_REF` and `EXPECTED_SHA` at the first executable lines of the
  mutation block;
- reject empty values, leading or trailing whitespace, and CR/LF;
- require the complete ref to pass `git check-ref-format`, not merely begin with
  `refs/heads/`;
- compare the locals with `GITHUB_REF` and `GITHUB_SHA` once;
- never reread any of those four environment variables afterward;
- use the unchanged locals for the checkout, remote, parent, lease, and refspec
  proofs; and
- ensure controlled stale-ref and lease drills mutate only a purpose-specific
  local test input.

**Required revision:** Copy P1's writer-input normalization and one-read rule
into T1 while preserving T1's existing exact-lease and blob-identity checks.

### T1/T2-1: Regenerate T2's prerequisite after the final T1 correction

**Severity:** Medium

T2's prerequisite section is now detailed and correctly names the current
seven-path T1 proposal. It should not be frozen before T1 is finalized.

After the corrections above, update T2 to require:

- same-held-stream digest and ZIP consumption;
- the final stable-ID fixture oracle and PR topology;
- the selected checkout/setup-node versions;
- Node 24 and explicit cache behavior;
- the final Dependabot decision and resulting six- or seven-path set; and
- the normalized writer contract.

T2's non-goals currently list only four of T1's seven implementation paths even
though they say not to modify the prerequisite issue's files. Either list the
complete final set or say "all files delivered by T1" and point to the verified
prerequisite manifest.

**Required revision:** Rebuild the dependency gate and non-goal path list from
the merged T1 implementation rather than copying an intermediate proposal.

### T2-1: Inherited Bash tracing can expose the HCP token

**Severity:** High

The proposed HCP block says not to use `set -x`, but it does not disable tracing
that the caller has already enabled. The subshell inherits xtrace. Its early
assignment:

```bash
TFC_TOKEN=${TFC_TOKEN:?...}
```

can therefore place the expanded token in trace output before `curl` starts.
Keeping the token out of curl's process arguments does not protect against a
shell trace leak.

The HCP subshell should make `set +x` its first command, before `umask`, token
expansion, validation, header construction, or any command that could expose
secret-bearing values.

Acceptance must execute this condition. Run the exact published block with
xtrace already enabled, a sentinel token, and stubbed `curl`; then prove the
sentinel appears in neither captured trace output nor the stub's recorded
argument list.

**Required revision:** Add first-command trace disabling and the inherited-
xtrace sentinel test to the example, rationale, validation, and acceptance
criteria.

### T2-2: The HCP endpoint excludes Europe and pagination input is unvalidated

**Severity:** Medium to high

The example hardcodes:

```text
https://app.terraform.io/api/v2/state-versions
```

HashiCorp documents `app.eu.terraform.io` for
[HCP Terraform Europe](https://developer.hashicorp.com/terraform/cloud-docs/europe).
The issue should support both hosted regions without allowing an arbitrary
token destination.

Use a closed environment selector or exact HTTPS host allowlist containing only:

- `app.terraform.io`; and
- `app.eu.terraform.io`.

Reject every other value before token handling. If Terraform Enterprise is out
of scope, state that explicitly; a safe arbitrary-enterprise-host contract
requires separate trust and certificate requirements.

Also require `TFC_PAGE_NUMBER` to be a positive decimal integer. Defaulting to
`1` does not validate a caller-supplied value.

The current state-version endpoint, required organization/workspace filters,
status values, and pagination model are otherwise supported by HashiCorp's
[state-version API reference](https://developer.hashicorp.com/terraform/cloud-docs/api-docs/state-versions)
and
[API overview](https://developer.hashicorp.com/terraform/cloud-docs/api-docs).

**Required revision:** Add closed US/Europe host selection, HTTPS enforcement,
positive-page validation, explicit Terraform Enterprise scope, and accepted/
rejected host tests.

### T2-3: The state-safety scope is ambiguous

**Severity:** Medium to high

T2's acceptance criteria say every recovery destination is protected and
no-clobber, and its sensitive-state section says the examples retrieve a copy
rather than overwrite active backend state. The concrete requested changes
focus on the four provider/API examples.

The current guide and rationale contain other nearby state operations,
including:

- `terraform state pull` redirected to local backup paths;
- `terraform show -json ... | head -50` as backup inspection;
- `terraform state push`;
- state removal commands;
- a second prefix-only S3 version listing; and
- legacy Azure, GCS, and HCP examples.

This does not necessarily require expanding T2 indefinitely, but the issue must
make its quantifier precise. Choose one:

1. inventory and harden every state backup, discovery, inspection, recovery,
   and destructive example in both source documents; or
2. explicitly limit T2 to the four named provider-version blocks and create a
   follow-up issue with the remaining source locations.

The first choice best matches T2's current universal acceptance language. If
the second is intended, narrow phrases such as "every recovery destination" to
the enumerated blocks and avoid a document-wide claim that adjacent
`terraform state push` guidance contradicts.

**Required revision:** Add a complete source-location inventory or narrow the
scope and record the omitted examples in a follow-up issue.

### T2-4: Shell safety needs executable non-network validation

**Severity:** Medium

All seven current Bash fences pass `bash -n`, which is a useful baseline.
T2's written validation, however, stops at generator execution, Markdown lint,
whitespace checks, and content confirmation. Those checks do not prove
control-flow, quoting, no-overwrite, or trace-secrecy behavior.

Require a non-network implementation-time harness that extracts the exact Bash
blocks intended for publication and:

- reruns `bash -n`;
- stubs `aws`, `az`, `gcloud`, and `curl`;
- proves missing, empty, relative, existing, directory, symlink, and dangling
  destination paths fail before a provider call;
- proves paths containing spaces and shell metacharacters remain one literal
  argument;
- proves version and generation selectors reach the stub unchanged;
- proves Azure and GCS no-overwrite flags are present;
- proves no block overwrites a local file;
- verifies US/Europe HCP host acceptance and arbitrary-host rejection;
- verifies positive-page validation; and
- performs the inherited-xtrace sentinel test.

This can be a temporary validation artifact outside the repository rather than
a seventh T2 file. The issue should still define its assertions and require its
captured output as implementation evidence.

**Required revision:** Add this executable harness to T2's validation and make
successful non-network results a prerequisite for accepting the generated
examples.

### Separate maintenance observation: the lint dependency tree has advisories

**Severity:** Medium, not a T1/T2 blocker

A clean audit of `.github/workflows/package-lock.json` at the reviewed commit
reports seven advisories: five high and two moderate. The affected package set
is `brace-expansion`, `js-yaml`, `linkify-it`, `markdown-it`,
`markdownlint-cli2`, `minimatch`, and `picomatch`.

T1 correctly excludes dependency changes from its workflow hardening. Keep that
separation, but create a maintenance issue to:

- update the lint dependency set intentionally;
- perform a clean Node 24 install;
- run outer and nested Markdown lint;
- review the lockfile and command changes; and
- record the post-update audit result.

GitHub Actions Dependabot configuration does not cover this npm dependency
tree, so the proposed review-only action updates do not resolve these
advisories.

## Confirmed strengths to preserve

- T1 before T2 is the correct dependency order.
- T1 correctly identifies the Terraform generator's four serialization
  boundaries and leaves its already-correct LF-joined frontmatter alone.
- The five mandatory helper parameters and three optional diagnostic labels now
  match P1.
- T1's full-component rule is deliberately stronger where needed and correctly
  says to coordinate or document any remaining cross-repository difference
  rather than claiming false parity.
- The tracked helper harness, explicit shell/edition steps, exact fixture-EOL
  matrix, all-push-consumer behavior, immutable candidate transport, and
  diagnostic artifact handling are strong designs.
- T1's exact remote observation, full object-ID handling, exact expected-SHA
  lease, explicit refspec, staged/committed blob proof, and no-retry policy are
  strong.
- T2 correctly separates discovery from recovery and deliberate identifier
  selection.
- T2's S3 bucket-class and KMS reconciliation, Azure non-HNS scope and
  `--overwrite false`, GCS Object Versioning/soft-delete distinction and
  `--no-clobber`, and HCP `/state-versions` filters are well researched.
- The HCP use of `curl -q --config -`, a pre-opened noclobber file descriptor,
  restrictive `umask`, explicit failure handling, and retention of invalid
  partial output is materially safer than the current guide.
- T2 correctly treats state and Archivist URLs as sensitive and avoids
  automatic recovery selection or rollback.

## Recommended final slate

1. Revise T1 to use one held archive stream from digest through extraction.
2. Align T1's checkout/setup-node pins and lint runtime with P1 and Node 24;
   record whether Dependabot is an intentional Terraform-only difference.
3. Replace T1's grouped fixture table with stable IDs and row-specific
   postconditions, and normalize the writer contract.
4. Update T2's prerequisite and non-goal manifest from the final merged T1.
5. Add first-command xtrace disabling, closed US/Europe HCP host selection, and
   positive pagination validation to T2.
6. Resolve T2's state-example scope and require executable non-network shell
   validation.
7. Keep T1 then T2 sequential, and track npm dependency maintenance separately.

With those corrections, the slate provides a sound cross-repository direction:
the shared generator and artifact boundary can converge where behavior should
match, while manifest names, Dependabot policy, and genuinely repository-
specific concerns remain explicit rather than accidental differences.
