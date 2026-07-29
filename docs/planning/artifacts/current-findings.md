# PSStyleGuide P1/P2 review findings

## Overall assessment

P1 followed by P2 is the correct order. The revised issues are substantially
stronger than the earlier drafts: the generator boundary is deterministic, the
candidate pipeline is fail-closed, the helper now has an explicit trusted-root
interface and tracked harness, and P2 has a precise canonical example validator.

I would not file or implement the slate unchanged. Four matters should be
corrected first:

1. The asserted P1/T1 helper alignment is still not true in the attached issue
   texts.
2. P1's concrete action selection is already stale, and its Node 24 migration
   leaves the Markdown workflow's Node 20 setup action and toolchain untouched.
3. The helper hashes the ZIP by path and then reopens it, so the digest is not
   bound to the exact stream consumed by `ZipArchive`.
4. Exact directory enumeration and dangling candidate-leaf rejection remain
   undefined.

The writer identity, fixture oracle, conditional-consumer wording, and one P2
validation helper also need smaller corrections. None of these findings changes
the P1 to P2 ordering or argues for line-for-line identity between the complete
PSStyleGuide and TerraformStyleGuide generators.

## Scope and evidence

- Primary review targets were
  `docs/planning/PSStyleGuide/01PSStyleGuideP1.md` and
  `docs/planning/PSStyleGuide/02PSStyleGuideP2.md`.
- The H1 titles and P1/P2 identifiers are intentional and are not findings.
- The Terraform T1/T2 files were read only to evaluate the claimed shared
  contract. This document does not review the Terraform-specific issue content.
- The current generator, both workflows, `.gitattributes`, source guides,
  generated artifacts, and sibling Terraform generator were inspected.
- Official action tags, exact commit IDs, action metadata, and current release
  pages were rechecked on 2026-07-29.
- Repository Markdown lint, nested-Markdown lint, Git whitespace checks, and
  PowerShell parsing were run locally.

## Prior-criticism audit, recommendation by recommendation

### Recommendation 1 — Reconcile the claimed P1/T1 helper alignment

Status: confirmed concern; preferred remedy denied; alternate remedy incomplete.

The criticism correctly identified a real mismatch. P1 now makes
`CheckoutRoot`, `TrustedTemporaryRoot`, `DownloadDirectory`,
`CandidateDirectory`, and `ExpectedDigest` mandatory; adds optional caller-owned
diagnostic labels; and assigns fixtures to a tracked harness. The attached T1
still describes a different public interface, trust boundary, and fixture
ownership model.

I do not recommend the criticism's preferred fix of weakening P1 to the older
fixed-location T1 model. P1's explicit trusted-temporary-root envelope is the
stronger and more testable contract. Keep it and coordinate the corresponding T1
revision. Until that happens, P1 should not say that the interfaces and
validation behavior are already aligned. It can describe its interface as the
target shared contract.

### Recommendation 2 — Use one writer ref identity from preflight through push

Status: confirmed and only partly addressed.

P1 now supplies:

```yaml
env:
  TARGET_REF: ${{ github.ref }}
  EXPECTED_SHA: ${{ github.sha }}
```

That is an improvement. The preflight still validates `$env:GITHUB_REF`, while
the lease and refspec consume `$env:TARGET_REF`. Similarly, prose refers to
`github.sha`, while the push consumes `$env:EXPECTED_SHA`; equality with
`$env:GITHUB_SHA` is not an explicit invariant.

These values should be copied once into local variables in the single mutation
block, cross-checked against the immutable GitHub variables, validated, and then
reused unchanged for `ls-remote`, parent/HEAD proofs, the exact lease, and the
explicit refspec.

### Recommendation 3 — Bind helper execution to the assigned edition

Status: confirmed concern and resolved.

P1 now requires:

- Ubuntu PowerShell 7 helper coverage;
- Windows PowerShell 5.1 coverage in the Desktop LF cell;
- PowerShell 7 coverage in the Core LF cell;
- edition-specific Windows shells and assertions; and
- the same tracked harness in every push consumer before production helper use.

It explicitly explains that the CRLF cells do not repeat the EOL-independent
helper suite. That is the deliberate optimization offered by the criticism, and
the issue no longer implies that all four pull-request cells exercised it.

### Recommendation 4 — Specify exhaustive enumeration and final-leaf detection

Status: confirmed and unresolved.

P1 uses exact-count and exact-set language, but does not prescribe an exhaustive
enumeration primitive. `Get-ChildItem` without `-Force` omits hidden/system
entries. Ordinary existence checks can also report a dangling final symlink as
absent.

The helper must normatively enumerate every entry, and it must enumerate the
candidate parent for an exact leaf-name match immediately before leaf creation.
The fixture suite still needs distinct hidden/system extra-entry and dangling
final-leaf cases.

### Recommendation 5 — Replace fixture prose with a normative outcome table

Status: confirmed and unresolved.

The current list still mixes:

- ordinary successful extraction;
- successful metadata-ignored extraction;
- rejection cases;
- platform-conditional cases;
- a successful sibling-prefix classification; and
- a successful filesystem-provider-qualified path.

It then refers to “each invalid fixture” and singular “the valid fixture.” Stable
case IDs, explicit success/rejection outcomes, failure phases, candidate-leaf
postconditions, and positive byte/type assertions are still missing.

### Recommendation 6 — Match push-consumer language to the conditional graph

Status: confirmed and partly resolved.

The detailed post-merge sections correctly say that the synchronization job
skips when `has_changes=false`. P1 acceptance and P2 prerequisites still say
every push consumer runs the harness “on every run.” A skipped job has no
executed consumer steps.

The issues should say that all four Windows push cells always run the harness and
helper, while synchronization does so only when `has_changes=true` and the job
starts.

### Recommendation 7 — Preserve a deliberate generator-unification boundary

Status: confirmed guardrail and satisfied.

The revised slate unifies common serialization semantics without requiring the
complete generators to be byte-identical or creating a cross-repository runtime
dependency. It correctly preserves:

- PSStyleGuide's existing `.gitattributes`;
- its replacement of a frontmatter here-string;
- TerraformStyleGuide's already LF-joined frontmatter; and
- domain-specific merge rules, headings, artifacts, and rationale structures.

This is the right meaning of generator unification.

### Recommendation 8 — Make P2's validation helper self-consistent

Status: reasonable quality concern and unresolved; low priority.

P2 still declares `Get-OrdinalOccurrenceCount` without comment-based help. The
style guide's formal repository scope is `.ps1` files, so a transient command
embedded in a planning document is not the same defect as an undocumented
committed function. It is nevertheless a conspicuous inconsistency in a
copy-paste validation block for that very style guide.

Either add complete help or avoid a named function, for example by using a
narrowly scoped script block or inline ordinal-count logic. This should not
block the higher-priority workflow and helper corrections.

## Remaining actionable findings

### P1-1 — Action and Node-runtime modernization is stale and incomplete

Priority: high and time-sensitive.

P1 says that, as of 2026-07-28, checkout v6.0.2 is the selected release. Official
GitHub releases show that checkout v7.0.1 was released on 2026-07-20. Its exact
commit is:

```text
3d3c42e5aac5ba805825da76410c181273ba90b1
```

V7 retains v6's protected credential storage under `RUNNER_TEMP`, runs on
Node 24, and adds dependency/security updates. P1's revalidation instruction
would eventually detect the newer release, but the dated concrete assertion,
examples, references, and checkout-v6-specific controlled-evidence text are
already wrong.

The same affected Markdown workflow still contains:

```yaml
uses: actions/setup-node@v4
with:
  node-version: '20'
```

That has two separate Node 20 dependencies:

- `setup-node@v4` itself declares `runs.using: node20`; and
- the workflow deliberately installs the EOL Node 20 toolchain.

As of this review, the current setup-node release is v7.0.0 at:

```text
820762786026740c76f36085b0efc47a31fe5020
```

Its exact metadata declares `runs.using: node24`. Node 24 is the current Active
LTS line. GitHub is already in the Node 24 runner transition and plans to remove
Node 20 from runners in fall 2026.

Recommended correction:

1. Recheck and use the approved full-SHA checkout v7 release in both workflows.
2. Pin the current approved Node 24-based setup-node release by full SHA.
3. Set the Markdown toolchain to `node-version: '24'`.
4. Set `package-manager-cache: false` because this job does not require caching.
5. Give the Markdown workflow an explicit `permissions: contents: read`.
6. Run both lint commands under Node 24 before finalizing.
7. Update P1's references, examples, non-goals, and controlled push evidence.
8. Add the setup action, toolchain, and permission assertions to P2's
   prerequisite.

These remain changes to the already affected `markdownlint.yml`; P1's five-path
implementation scope does not need to grow. The current upload-artifact v7.0.1
and download-artifact v8.0.1 tags and full SHAs were reverified and remain the
latest releases on the review date.

### P1-2 — The helper does not bind the digest to the archive it consumes

Priority: high.

P1 requires:

1. `Get-FileHash -Algorithm SHA256` against the retained ZIP path;
2. digest comparison; and then
3. opening the archive.

Those are separate path-based opens. The path can identify different bytes
between hashing and `ZipArchive` construction. Repeating containment and
reparse-point checks does not bind file content identity.

Recommended correction:

1. Complete path, type, and indirection validation.
2. Open the retained ZIP once as a read-only `FileStream`.
3. Hash that held stream, using `Get-FileHash -InputStream` or a compatible
   SHA-256 implementation.
4. Compare the digest and fail before archive parsing on mismatch.
5. Rewind the same seekable stream.
6. Construct `ZipArchive` over that same held stream.
7. Keep that archive/stream pair through manifest validation and extraction.
8. Dispose both deterministically.

This is available in both supported PowerShell editions and turns the claimed
digest chain into an identity guarantee for the bytes actually parsed.

### P1-3 — Exact directory contracts and candidate-leaf absence are underspecified

Priority: high.

“Exactly one filesystem entry” and “exactly four paths” are security properties,
not diagnostic descriptions. The issue should prescribe exhaustive enumeration
that cannot omit hidden or system entries.

Recommended correction:

- Materialize `Directory.EnumerateFileSystemEntries` for exact count/set checks.
- If `Get-ChildItem` is used for diagnostics, require `-LiteralPath -Force`.
- Enumerate the candidate parent and compare leaf names with platform-appropriate
  ordinal semantics.
- Reject an existing file, directory, symlink, reparse point, or dangling link
  with that name.
- Repeat the parent enumeration immediately before creation.
- Continue to use `FileMode.CreateNew` for every extracted file.

Add stable fixtures for:

- a hidden/system extra download entry;
- an existing candidate file;
- an existing candidate directory;
- a candidate symlink/reparse leaf; and
- a dangling final candidate link.

A reparse component elsewhere in the path does not prove final-leaf handling.

### P1-4 — The P1/T1 alignment assertion remains factually false

Priority: high coordination requirement.

This is the actionable remainder of prior recommendation 1. P1 now defines a
good target contract, but the attached issue texts do not share it.

Recommended correction: retain P1's stronger contract and coordinate the
equivalent T1 update before presenting the two slates as aligned. At minimum,
the shared contract should name the same:

- mandatory path/digest parameters;
- optional diagnostic parameters;
- trusted-root and checkout-disjointness semantics;
- validation order and same-stream archive identity;
- tracked harness ownership;
- exhaustive leaf/entry behavior; and
- pre-merge versus push execution topology.

The four manifest filenames and domain-specific artifact names should remain the
intentional repository differences.

### P1-5 — Writer preflight, commit proof, lease, and refspec use split identities

Priority: medium.

The values currently originate from the same GitHub context, so this is not an
immediate exploit. It is an unnecessary maintenance-sensitive split in the most
security-sensitive mutation block.

Recommended correction:

1. Copy `TARGET_REF` and `EXPECTED_SHA` into local variables once.
2. Require the target to be a complete `refs/heads/` name.
3. Require it to equal `GITHUB_REF`.
4. Resolve `HEAD^{commit}` once and require it to equal both the expected SHA
   and `GITHUB_SHA`.
5. Use the same local target in `ls-remote`.
6. Validate exactly one `<object-id><TAB><ref>` result.
7. Use the unchanged locals in the exact lease and `HEAD:<full-ref>` refspec.

The controlled stale-preflight and exact-lease drills should mutate only the
specific local test input whose rejection they intend to prove.

### P1-6 — The fixture suite still lacks an executable oracle

Priority: medium.

Convert the prose list into a normative table with at least:

- stable case ID;
- platform/precondition;
- expected success or rejection;
- expected failure phase;
- whether the candidate leaf must remain absent;
- expected diagnostics; and
- required path, type, and byte assertions after success.

Explicitly classify both archive success cases:

1. an exact archive with the correct digest; and
2. an exact archive with symlink-like external attributes that extract as
   ordinary regular files.

Also classify the sibling-prefix and provider-qualified path successes, the
Windows case-variant result, and platform-conditional symlink construction.
“An exception occurred” is not enough for a negative oracle.

### P1/P2-1 — “Every push consumer on every run” is unattainable

Priority: medium.

Use one conditional graph contract throughout both issues:

- The four Windows push cells always download, self-test, and invoke the helper.
- Synchronization self-tests and invokes the helper only when
  `has_changes=true`.
- On the expected P1/P2 no-drift push, synchronization is skipped and none of
  its steps run.
- The controlled `has_changes=true` drill plus static inspection supplies writer
  evidence.

Update P1 acceptance and P2 prerequisite/acceptance language to match those
semantics.

### P2-1 — The named validation function remains undocumented

Priority: low.

This is prior recommendation 8. It is a handoff-quality issue rather than a
functional defect. Add full help to `Get-OrdinalOccurrenceCount` or use a
non-function implementation while preserving ordinal, non-overlapping counting
and the synthetic false-positive self-test.

### Separate maintenance — The Markdown dependency lock reports known advisories

Priority: medium, but not a P1/P2 blocker.

After a clean install, `npm audit` reports seven development-dependency
advisories: five high and two moderate. They include denial-of-service issues in
packages used while globbing and parsing repository Markdown. Pull-request
authors control Markdown input, so this is relevant to check availability even
after token permissions are reduced.

Do not silently fold a dependency refresh into P1's already large security
change. Create a separate maintenance issue to update the Markdown toolchain and
lockfile, run the outer and nested fixture suites under Node 24, and record the
post-update audit result.

## Confirmed strengths and resolved concerns

- P1 then P2 remains the correct dependency order.
- `.gitattributes` already has the correct repository-wide LF policy and neither
  issue edits it.
- P1's final-payload normalization, path resolution, BOM-less encoding, and
  `WriteAllText` contract is correct.
- The frontmatter replacement preserves the intentional PSStyleGuide bytes;
  TerraformStyleGuide's already-correct array form remains repository-specific.
- The helper interface is now implementable without ambient Git, GitHub, or
  current-directory discovery.
- Automatic pre-merge helper coverage now exists on Ubuntu and both Windows
  editions.
- The LF/CRLF matrix and separate lone-CR sanitation probes have distinct and
  coherent purposes.
- The immutable candidate ID, native digest check, propagated digest check,
  read-only approval, sole writer, blob proofs, and exact lease form are sound
  apart from the same-stream and canonical-identity findings above.
- The artifact upload and download inputs relied on by P1 exist at the exact
  pinned commits.
- P2's factual premise remains true: the stored Compliant and Non-Compliant
  example bodies are byte-equivalent.
- P2 removed the invalid rationale-changelog requirement and names the existing
  `### Blank Line Usage` rationale destination.
- P2's canonical snippet validator now rejects the earlier global-co-occurrence
  false positive and requires one exact snippet/marker in each guide-bearing
  output.
- P2 correctly commits both authoritative sources with all four regenerated
  artifacts, making a no-drift post-merge push the expected result.

## Validation performed

- `npm --prefix .github/workflows run lint:md` — passed, 0 errors across
  32 Markdown files.
- `npm --prefix .github/workflows run lint:md:nested` — passed, 18 nested
  Markdown blocks checked.
- `git diff --check` — passed.
- All four complete PowerShell fences in P2 parsed under PowerShell 7.6.4 and
  Windows PowerShell 5.1.
- P1's seven PowerShell fences parsed under both editions; its
  placeholder-bearing fragments were treated as illustrative, not executable
  validation blocks.
- Official tag resolution confirmed:
  - checkout v7.0.1:
    `3d3c42e5aac5ba805825da76410c181273ba90b1`;
  - setup-node v7.0.0:
    `820762786026740c76f36085b0efc47a31fe5020`;
  - upload-artifact v7.0.1:
    `043fb46d1a93c77aae656e7c1c64a875d1fc6a0a`; and
  - download-artifact v8.0.1:
    `3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c`.
- Exact action metadata confirms Node 24 runtimes for the recommended checkout
  and setup-node commits and the required archive/digest inputs for the artifact
  commits.
- The current P2 example bodies were extracted and compared; both third lines
  are empty and the bodies are equal.

## Primary references

- [GitHub: checkout v7.0.1 release](https://github.com/actions/checkout/releases/tag/v7.0.1)
- [GitHub: checkout v7.0.1 exact metadata](https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml)
- [GitHub: checkout v7.0.1 exact README](https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/README.md)
- [GitHub: setup-node v7.0.0 release](https://github.com/actions/setup-node/releases/tag/v7.0.0)
- [GitHub: setup-node v7.0.0 exact metadata](https://raw.githubusercontent.com/actions/setup-node/820762786026740c76f36085b0efc47a31fe5020/action.yml)
- [GitHub: setup-node v4 metadata](https://raw.githubusercontent.com/actions/setup-node/v4/action.yml)
- [GitHub: Node 20 runner-action deprecation](https://github.blog/changelog/2025-09-19-deprecation-of-node-20-on-github-actions-runners/)
- [Node.js release schedule](https://github.com/nodejs/Release#release-schedule)
- [GitHub: secure-use reference](https://docs.github.com/en/actions/reference/security/secure-use)
- [GitHub: workflow permissions](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#permissions)
- [GitHub: upload-artifact v7.0.1 exact metadata](https://raw.githubusercontent.com/actions/upload-artifact/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a/action.yml)
- [GitHub: download-artifact v8.0.1 exact metadata](https://raw.githubusercontent.com/actions/download-artifact/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/action.yml)
- [Microsoft Learn: `Get-FileHash`](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/get-filehash)
- [Microsoft Learn: `ZipArchive` stream constructor](https://learn.microsoft.com/dotnet/api/system.io.compression.ziparchive.-ctor)
- [Microsoft Learn: `Get-ChildItem -Force`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/get-childitem)
- [Microsoft Learn: `Directory.EnumerateFileSystemEntries`](https://learn.microsoft.com/dotnet/api/system.io.directory.enumeratefilesystementries)
- [Git: `git ls-remote`](https://git-scm.com/docs/git-ls-remote)
- [Git: `git push`](https://git-scm.com/docs/git-push)
- [npm: `npm audit`](https://docs.npmjs.com/cli/commands/npm-audit)
