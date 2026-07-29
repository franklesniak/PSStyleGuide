# Feedback on the PSStyleGuide P1/P2 GitHub issue slate

## Overall assessment

P1 followed by P2 is the right order, and the slate is close to ready. P1 has
already resolved most of the problems raised against earlier drafts: its public
helper interface now matches T1 at the surface, the writer uses one validated
ref identity, edition-specific steps invoke the helper, the fixture suite has
stable phases and normative oracles, and P2 no longer introduces a
noncompliant named validation function.

The baseline assertions are also accurate as of PSStyleGuide `main` commit
[`4346310`](https://github.com/franklesniak/PSStyleGuide/commit/4346310e7deebffb4159c75e30d9546263dfd649):

- `.gitattributes` already contains exactly `* text=auto eol=lf`.
- The generator still supports Windows PowerShell 5.1, uses four
  edition-sensitive `Set-Content -Encoding UTF8` writes, and constructs the
  PowerShell frontmatter with a here-string.
- The build workflow is path-filtered, has workflow-level `contents: write`,
  and uses movable action tags.
- The two Blank Line Usage examples currently encode the same blank line, so
  P2 addresses a real defect.

I would not file P1 unchanged, however. Its strongest archive-identity
protection is better than T1's current prescription, while several path and
cleanup protections in T1 are stronger than P1's. The correct unification is
the union of those protections, not selecting one issue wholesale as the
template for the other. P1 also contains an impossible global rejection
postcondition and overstates the degree of P1/T1 identity.

## Required corrections to P1

### 1. Replace the claimed near-total P1/T1 identity with an explicit convergence matrix

P1 currently says the common behavior matches T1 and only named manifest and
artifact details differ. That is not true even after the public helper
parameters were aligned.

The two issues still differ in material ways:

| Surface | P1 | T1 |
| --- | --- | --- |
| Archive identity | Hashes and extracts through one continuously held stream | Hashes by path, then opens the path for extraction |
| Path-component trust | Checks components below the trusted temporary root | Checks from the filesystem volume/share root through every protected path |
| Root relationships | Requires the temporary root to be outside checkout | Requires all protected roots to be mutually non-overlapping |
| Revalidation | Before archive open and candidate creation | Also after extraction |
| Race model | Implicit | Explicitly limited to job-owned paths on a GitHub-hosted runner without competing writers |
| Post-creation failure | No complete cleanup contract | Fail-closed, non-recursive cleanup contract |
| Pull-request helper coverage | Two Windows LF cells | All four Windows edition × EOL cells |
| Action governance | No Dependabot configuration | Weekly, review-only GitHub Actions updates |
| Lint runtime | Moves the lint job to Node 24 | Leaves the Terraform repository's existing Node/package behavior alone |
| Frontmatter | Replaces a here-string | Preserves an already-correct LF-joined array |

Replace the blanket parity statement with a small normative matrix in both
issues. For every shared concern, identify:

1. the common public contract;
2. the common security and failure semantics;
3. the common fixture IDs or equivalent test coverage;
4. the repository-specific implementation detail, if any; and
5. the reason that the difference is intentional.

The shared target should be:

- P1's same-held-stream digest and extraction design;
- T1's full path-component validation, revalidation, race assumptions, and
  cleanup behavior;
- the same externally observable diagnostics and fixture outcomes for common
  cases; and
- repository-local generators and helpers, with no runtime dependency between
  repositories.

Coordinate the corresponding T1 wording before implementation. In particular,
do not weaken P1 to T1's current hash-by-path/reopen sequence merely to make the
text look identical. T1 should adopt the stronger held-stream rule.

Legitimate differences should be named rather than hidden: manifest filenames,
artifact names, guide-specific merge logic, frontmatter construction work,
existing `.gitattributes` state, lint-runtime migration, and any deliberately
different CI matrix coverage. “Unified” should mean equivalent common
algorithms and contracts, not line-for-line script identity or cross-repository
byte equality.

### 2. Adopt T1's complete path-envelope validation in P1

P1 validates components between the trusted temporary root and the working
paths. That does not prove that an ancestor of the trusted root itself is not a
symlink, junction, mount-like redirect, or reparse point. A caller-selected
“trusted” root cannot make its unchecked ancestors trustworthy.

Specify all of the following:

- Resolve `CheckoutRoot`, `TrustedTemporaryRoot`, `DownloadDirectory`, and
  `CandidateDirectory` to absolute filesystem-provider paths before trust
  decisions.
- Require the checkout root, trusted temporary root, download directory, and
  candidate directory to have the exact permitted containment relationships.
  In particular, the two roots must be mutually non-overlapping: neither may
  equal, contain, or be contained by the other.
- Use separator-aware ordinal containment checks: ordinal-ignore-case on
  Windows and ordinal on case-sensitive runners. A sibling with a common text
  prefix must remain a sibling.
- Walk every existing component starting at the filesystem volume root or UNC
  share root and continuing through both roots, the download path, the archive
  leaf, the candidate parent, and every created candidate path.
- Reject a symlink, junction, reparse point, or an inability to obtain required
  attributes. Do not resolve through the component and then treat the resolved
  target as trusted.
- Re-run the relevant checks immediately before opening the archive,
  immediately before creating the candidate directory, and after extraction
  before accepting or publishing any candidate bytes.
- State the residual race assumption honestly: this contract is designed for
  job-owned paths on a GitHub-hosted runner where no competing writer is
  expected. Repeated path inspection does not create a general-purpose
  race-free filesystem sandbox.

Extend the permanent suite with ancestor-link and protected-root-link cases,
not only links below an otherwise trusted root. If a particular runner cannot
create a required link primitive, the case may be marked unavailable on that
runner only when the same semantic case is required to execute on at least one
other mandatory runner. A suite in which every platform skips the security case
is not passing coverage.

### 3. Keep the held-stream design, but choose the sharing mode explicitly

P1 correctly requires the helper to open the archive once, compute SHA-256
through `Get-FileHash -InputStream`, rewind the same seekable stream, and build
one `ZipArchive` over that stream. This closes the identity gap between “the
bytes that were hashed” and “the bytes that were extracted” and should remain
the common P1/T1 contract.

The issue currently says to use an explicitly selected sharing mode but does
not select one. Require read access with `FileShare.Read`:

- other readers may inspect the archive;
- a second handle is not permitted to write to or delete the archive while the
  helper holds it; and
- the helper itself never reopens the path between digest verification and
  extraction.

The permanent suite should assert, under both Windows PowerShell 5.1 and
PowerShell 7, that hashing leaves the stream open, that the stream is rewound,
and that the exact same stream instance supplies `ZipArchive`. A path-based
`Get-FileHash` call followed by a new `FileStream` must be a prohibited
implementation, even if it happens to pass the normal fixture.

### 4. Make rejection postconditions truthful and add fail-closed cleanup

P1 says, in one place, that the candidate leaf is absent after every rejection.
Its own fixtures require a preexisting candidate file, directory, symlink, or
reparse point to remain unchanged. Those requirements cannot both be true.
Post-extraction rejection also occurs after the helper created the candidate,
yet P1 does not completely specify cleanup.

Replace every global “leaf absent on rejection” assertion with a per-case
postcondition:

| Rejection class | Required candidate-leaf result |
| --- | --- |
| Failure before creation when the leaf was initially absent | Still absent |
| Preexisting file, directory, link, or reparse leaf | Byte-for-byte and type-for-type unchanged |
| Controlled post-creation validation failure involving only ordinary helper-created entries | Safely cleaned; leaf absent |
| Cleanup-time safety check finds an unexpected entry, link, reparse point, or changed envelope | Do not follow or recursively delete it; preserve evidence and report both the original and cleanup failures |

Add the corresponding implementation contract:

1. Track whether this invocation created the candidate directory and which
   ordinary files it created.
2. Dispose the archive and all streams before cleanup.
3. Revalidate the complete path envelope before removing anything.
4. Remove only known ordinary, non-reparse helper-created files.
5. Remove the candidate directory only if it is still an ordinary directory and
   is empty.
6. Never recurse through, follow, or delete an unexpected or reparse entry.
7. Preserve the primary failure and append cleanup diagnostics rather than
   replacing the original cause.

Add at least one post-extraction fixture containing a UTF-8 BOM and one
containing a CR byte. Each should prove that controlled cleanup removes the
helper-created candidate. Add a cleanup-safety fixture that substitutes or adds
an unsafe entry and proves that no out-of-envelope target is touched. Stable
failure phases should distinguish extraction/manifest rejection from cleanup
failure.

This is both a correctness and an incident-response requirement: callers need
to know whether a rejected candidate was absent, deliberately preserved, or
only partially cleaned.

### 5. Make the trusted temporary-path example satisfy its own contract

P1 correctly tells callers to create a unique trusted temporary root and place
the download and candidate directories beneath it. Its workflow example then
uses a fixed download path such as
`${{ runner.temp }}/style-guide-candidate-download`, which does not demonstrate
that unique-root contract and can place the download beside, rather than under,
the value passed as `TrustedTemporaryRoot`.

Use one initialization step that:

1. creates a unique job-owned child of `runner.temp`, incorporating immutable
   run/attempt/job-or-matrix identifiers or a securely generated unique
   suffix;
2. creates the download directory as an exact child of that root;
3. defines an initially nonexistent candidate leaf under the same root;
4. exports all three absolute paths through `GITHUB_ENV` or step outputs; and
5. passes those exact exported values to `download-artifact`, the harness, and
   the production helper.

The writer and every matrix cell should use separate roots. Do not rely on a
fixed directory left over from a previous attempt, and do not make the helper
guess which download path an action used.

### 6. Add an end-to-end malformed-transport drill

P1's permanent suite tests malformed and truncated ZIP inputs directly. Keep
those cases, but also port T1's controlled `upload-artifact`/`download-artifact`
transport drill (including the `archive: false` malformed payload) into P1's
acceptance evidence.

The unit-style fixture proves the helper rejects bad bytes. The workflow drill
proves that the actual pinned upload action, download action, selected inputs,
digest output, trusted paths, and production helper are wired together as the
issue claims. It should run only in a controlled, non-default-ref context,
expect the helper to reject at the specified phase, verify the candidate
postcondition, and then clean up its test artifacts safely.

If the drafter chooses not to port this drill, P1 must narrow its evidence
claims. The permanent suite alone cannot prove the complete Actions transport
path.

### 7. Add review-only GitHub Actions update governance

The action SHAs presently proposed by P1 are current and internally consistent
as of 2026-07-29:

- `actions/checkout` `v7.0.1`;
- `actions/setup-node` `v7.0.0`;
- `actions/upload-artifact` `v7.0.1`; and
- `actions/download-artifact` `v8.0.1`.

Keep those verified full-length pins. Do not copy T1's older checkout/setup-node
SHAs into P1 for superficial parity; instead, update T1 during its required
preimplementation pin revalidation.

P1 should also add `.github/dependabot.yml`, making six affected files, with a
weekly `github-actions` entry for directory `/`. The policy should open
reviewable pull requests only: no automatic merge and no bypass of the normal
tests or review. Keep the human-readable release tag on the same line as each
full SHA so that Dependabot can update the pinned reference and its annotation.
This is the same review-only governance T1 already proposes and removes an
otherwise unnecessary cross-repository difference.

The move from Node 20 to Node 24 in P1's lint job is reasonable and should
remain PSStyleGuide-specific: GitHub began changing Actions runners to Node 24
by default on 2026-06-16 after Node 20 reached end of life. Retain explicit
read-only permissions and `package-manager-cache: false`.

### 8. Track the current npm advisories as real work, not residual prose

Running the repository's own lockfile through
`npm audit --package-lock-only --json` on 2026-07-29 reports seven vulnerable
package nodes: five high and two moderate. They include direct
`markdown-it`/`markdownlint-cli2` dependencies and transitive
`brace-expansion`, `js-yaml`, `linkify-it`, `minimatch`, and `picomatch`
dependencies. The published advisories are primarily denial-of-service,
quadratic-complexity, or ReDoS issues. Pull-request Markdown is processed by
this toolchain, so this is not merely an inventory curiosity.

Do not silently combine a package-lock migration with the generator and writer
redesign unless the project deliberately accepts the added review surface.
The preferred handling is:

- file and link a separately scoped dependency-remediation issue;
- require a clean or explicitly dispositioned audit result and the existing
  lint suite;
- add a weekly npm entry for `/.github/workflows` to the same Dependabot file
  in that issue; and
- state in P1 that its read-only permissions reduce impact but do not remediate
  vulnerable parsing code.

That dependency issue can follow P2 so P1 and P2 retain a stable lint baseline.
If repository policy prohibits merging while high-severity advisories have
known fixes, make it P0, complete it first, and rebaseline P1's package and
workflow assumptions. What is not acceptable is leaving “address separately”
without an issue, owner, or ordering decision.

### 9. Keep CI evidence wording exact

P1's choice to execute the archive/helper suite in only the two Windows LF
pull-request cells can be defensible because the archive contract is
EOL-independent and both PowerShell editions are still covered. T1 instead
runs it in all four Windows cells.

Choose and document one of these policies:

- run the common suite in all four cells for identical P1/T1 evidence; or
- retain P1's two-cell optimization, identify it in the convergence matrix as
  intentional, and state precisely that helper coverage is per edition rather
  than per edition × EOL combination.

Do not say that only manifest names differ if this topology differs. In either
case:

- all four Windows push cells must download, verify, and approve the candidate;
- the synchronization writer must run only when `has_changes=true`;
- a normal no-drift push must show the four read-only cells as successful and
  the writer job as skipped; and
- the controlled change-producing drill, not a no-drift run, supplies dynamic
  evidence for the writer path.

P2's current explanation of the skipped writer is precise; keep it and update
only its prerequisite details if P1 changes.

## P2 feedback

P2 has no independent blocking defect. Its proposed visualization is
copy-safe and appropriately generic:

- the warning precedes the example;
- the fenced block is `text`, not PowerShell;
- the third line contains exactly four U+00B7 middle-dot characters;
- the rationale explains the durable rule without duplicating the operational
  snippet; and
- the source files and all four generated artifacts are committed together,
  making a no-drift post-merge result the correct expectation.

Its ordinal occurrence-count validation is now a script block with a synthetic
false-positive self-test, so it no longer contradicts the guide's
comment-based-help requirement for named functions. Preserve that design. The
version/date shown in the metadata example is explicitly labeled as a
drift-only snapshot; it need not be rewritten as a predicted future date.

After P1 is corrected, update P2's prerequisite snapshot and acceptance text
to name the final P1 file set, helper/path/cleanup contract, CI topology, and
Dependabot result. Do not import Terraform-specific state-recovery guidance
from T2. T2 affects the sequencing and common generator baseline, but its
provider-oriented content is unrelated to the generic PowerShell blank-line
example.

## Recommended disposition

Return P1 to the drafter for the nine corrections above, coordinate the common
security-contract changes into T1, and then file P1 followed by P2. Keep the H1
issue titles and the P1/P2/T1/T2 names exactly as requested.

The minimum filing bar for P1 should be:

- an accurate P1/T1 convergence matrix;
- same-held-stream hashing and extraction with a chosen sharing mode;
- validation of every protected path component from the volume/share root;
- mutual root non-overlap, repeated validation, and an explicit race model;
- per-fixture candidate postconditions and fail-closed cleanup;
- unique workflow paths that satisfy the helper contract;
- an end-to-end malformed-transport drill or appropriately narrowed evidence;
- current full-SHA action pins plus review-only Actions Dependabot; and
- a concrete, ordered disposition for the existing npm advisories.

Once those items are incorporated, P2 can remain narrowly focused and should
follow P1 without further expansion.

## References

- [PSStyleGuide baseline commit `4346310`](https://github.com/franklesniak/PSStyleGuide/commit/4346310e7deebffb4159c75e30d9546263dfd649)
- [Microsoft Learn: `Get-FileHash`, including `-InputStream`](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/get-filehash)
- [Microsoft Learn: `System.IO.FileShare`](https://learn.microsoft.com/dotnet/api/system.io.fileshare)
- [GitHub Docs: secure use of third-party actions](https://docs.github.com/actions/security-for-github-actions/security-guides/security-hardening-for-github-actions#using-third-party-actions)
- [GitHub Docs: keeping actions up to date with Dependabot](https://docs.github.com/en/code-security/how-tos/secure-your-supply-chain/secure-your-dependencies/auto-update-actions)
- [GitHub Docs: Dependabot support for full-SHA action references and same-line annotations](https://docs.github.com/en/code-security/reference/supply-chain-security/supported-ecosystems-and-repositories#github-actions)
- [GitHub changelog: Node 20 deprecation and Node 24 runner migration](https://github.blog/changelog/2025-09-19-deprecation-of-node-20-on-github-actions-runners/)
- [`actions/checkout` at the proposed `v7.0.1` commit](https://github.com/actions/checkout/commit/3d3c42e5aac5ba805825da76410c181273ba90b1)
- [`actions/setup-node` at the proposed `v7.0.0` commit](https://github.com/actions/setup-node/commit/820762786026740c76f36085b0efc47a31fe5020)
- [`actions/upload-artifact` at the proposed `v7.0.1` commit](https://github.com/actions/upload-artifact/commit/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a)
- [`actions/download-artifact` at the proposed `v8.0.1` commit](https://github.com/actions/download-artifact/commit/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c)
- [GitHub Advisory Database: `brace-expansion` exponential-time denial of service](https://github.com/advisories/GHSA-3jxr-9vmj-r5cp)
- [GitHub Advisory Database: `js-yaml` quadratic CPU consumption](https://github.com/advisories/GHSA-52cp-r559-cp3m)
- [GitHub Advisory Database: `linkify-it` quadratic-complexity denial of service](https://github.com/advisories/GHSA-v245-v573-v5vm)
- [GitHub Advisory Database: `markdown-it` quadratic-complexity denial of service](https://github.com/advisories/GHSA-6v5v-wf23-fmfq)
- [GitHub Advisory Database: `minimatch` ReDoS](https://github.com/advisories/GHSA-7r86-cg39-jmmj)
- [GitHub Advisory Database: `picomatch` ReDoS](https://github.com/advisories/GHSA-c2c7-rcm5-vvqj)
