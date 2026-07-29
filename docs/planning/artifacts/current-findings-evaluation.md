# Evaluation of open PSStyleGuide slate findings

## Purpose and method

This file evaluates every open PSStyleGuide finding in
`docs/planning/artifacts/current-findings.md` one at a time. Each finding
receives:

1. a comprehensive option set;
2. a finding-specific weighted rubric;
3. a scored comparison; and
4. one detailed selected resolution.

Scores use a 1–5 scale, where 5 is best. Weighted totals are calculated as:

```text
sum(option score × criterion weight) / 5
```

The result is a percentage from 0 to 100. Criteria concerning correctness,
security, and user/operator reliability intentionally outweigh implementation
effort, churn, and preservation of the current draft.

The Terraform issue descriptions are considered only where a PSStyleGuide issue
makes an explicit cross-repository alignment claim. Terraform-specific content
is not evaluated or revised here.

## P1-1 — Action and Node-runtime modernization is stale and incomplete

### Options

#### Option A — Keep the draft and rely only on implementation-time revalidation

Leave checkout v6.0.2, the “as of 2026-07-28” statement, moving
`setup-node@v4`, Node 20, and implicit Markdown-workflow permissions in the issue.
Expect the implementer to discover and correct all stale choices while executing
the generic revalidation instruction.

This minimizes editing now, but hands a contradictory specification to a new
developer and makes review depend on undocumented judgment at implementation
time.

#### Option B — Update only checkout

Replace checkout v6.0.2 with checkout v7.0.1 at
`3d3c42e5aac5ba805825da76410c181273ba90b1` in examples, references, and
evidence. Leave setup-node, the installed Node toolchain, cache behavior, and
Markdown token permissions unchanged.

This makes P1's named checkout release current but leaves the more urgent
Node 20 dependency in the same affected workflow.

#### Option C — Update both actions but retain the Node 20 lint toolchain

Pin checkout v7.0.1 and setup-node v7.0.0 by full SHA, but keep
`node-version: '20'`. Add explicit `contents: read`.

This removes moving action tags and Node 20 from the actions' embedded runtime,
but deliberately installs an EOL toolchain for the lint commands. It treats
action-runtime migration and user-selected runtime migration as unrelated.

#### Option D — Use Node 22 Maintenance LTS

Pin checkout v7.0.1 and setup-node v7.0.0, declare `contents: read`, disable
automatic package-manager caching, and set `node-version: '22'`.

Node 22 remains supported through April 2027. This is conservative for package
compatibility, but it chooses Maintenance LTS when Node 24 is already Active LTS
and is the runtime generation driving the GitHub Actions migration.

#### Option E — Complete the Node 24 migration inside P1

Within the already affected `markdownlint.yml`:

- pin checkout v7.0.1 at
  `3d3c42e5aac5ba805825da76410c181273ba90b1`;
- pin setup-node v7.0.0 at
  `820762786026740c76f36085b0efc47a31fe5020`;
- install Node 24;
- set `package-manager-cache: false`;
- explicitly declare `permissions: contents: read`; and
- validate both existing lint commands under Node 24.

Update the P1 action contract, references, evidence, and narrow
`markdownlint.yml` non-goal accordingly. Update P2's prerequisite to verify the
result. Retain implementation-time revalidation so later security releases can
replace these exact snapshots coherently.

This is the complete same-file correction. It adds no implementation path and
aligns action runtime, selected toolchain, supply-chain pinning, permissions, and
handoff evidence.

#### Option F — Use Node 26 Current

Apply Option E but install Node 26 instead of Node 24.

This maximizes recency and provides the longest theoretical support horizon, but
Node 26 is Current rather than Active LTS on the review date. It increases the
chance that the current Markdown dependency lock encounters ecosystem
compatibility issues for no demonstrated functional benefit.

#### Option G — Create a prerequisite runtime-modernization issue

Create and complete a new issue that updates checkout, setup-node, Node,
permissions, and caching before P1. Keep those changes out of P1, then make P1
depend on the prerequisite.

This creates a clean project-management boundary and a smaller P1 diff, but it
delays the generator work, adds sequencing overhead, and separates P1's security
claims from the workflow file it already changes.

#### Option H — Use release tags instead of full SHAs

Use `actions/checkout@v7` and `actions/setup-node@v7`, relying on GitHub-owned
action provenance or immutable-release protections, and install Node 24.

This is readable and automatically follows patch releases. It conflicts with
P1's explicit full-SHA supply-chain policy and GitHub's secure-use guidance that
a full commit SHA is the immutable reference available across action releases.

### Evaluation rubric

This finding concerns execution-platform continuity and workflow supply-chain
security. A DevOps operator and cybersecurity reviewer need deterministic,
supported actions; a contributor needs lint behavior that will still run; and a
project manager needs one unambiguous handoff. Churn is relevant but deliberately
small because all comprehensive variants modify an already affected file.

| Criterion | Weight | Scoring guidance |
| --- | ---: | --- |
| Runner continuity | 22 | 5 eliminates Node 20 and uses a supported GitHub action runtime; 1 knowingly retains near-removal dependencies. |
| Immutable supply-chain identity | 20 | 5 pins every touched external action to verified full SHAs; 1 retains moving references. |
| Least privilege and cache safety | 14 | 5 explicitly limits token permissions and disables unnecessary cache writes; 1 relies on permissive defaults. |
| Toolchain support and ecosystem stability | 14 | 5 selects the current Active LTS line; lower scores select EOL, Maintenance-only, or pre-LTS Current lines. |
| Issue/evidence coherence | 12 | 5 updates examples, references, controlled evidence, non-goals, and P2 prerequisites together; 1 leaves contradictions. |
| Operator and newcomer usability | 8 | 5 gives one copy-ready contract with no hidden implementation choices; 1 delegates key choices to inference. |
| Validation quality | 6 | 5 explicitly proves both lint commands on the selected runtime; 1 provides no compatibility gate. |
| Scope/churn efficiency | 4 | 5 resolves the finding in the existing affected path with little sequencing overhead; 1 creates broad or duplicative work. |

Each option receives a 1–5 score per criterion. The weighted result emphasizes
whether CI will execute securely and predictably, not how few issue lines must be
edited.

### Scoring results

Abbreviations: RC = runner continuity; SI = supply-chain identity;
LP = least privilege/cache safety; TS = toolchain stability;
IC = issue coherence; OU = operator usability; VQ = validation quality;
SC = scope/churn efficiency.

| Option | RC | SI | LP | TS | IC | OU | VQ | SC | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Rely on revalidation | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 5 | 23.2 |
| B — Checkout only | 2 | 2 | 1 | 1 | 2 | 2 | 2 | 4 | 36.0 |
| C — Actions only, Node 20 tool | 3 | 5 | 4 | 1 | 4 | 3 | 3 | 4 | 68.4 |
| D — Full update, Node 22 | 5 | 5 | 5 | 4 | 5 | 4 | 5 | 4 | 94.8 |
| E — Full update, Node 24 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | **100.0** |
| F — Full update, Node 26 | 5 | 5 | 5 | 3 | 5 | 4 | 4 | 4 | 90.8 |
| G — Separate prerequisite | 5 | 5 | 5 | 5 | 4 | 3 | 5 | 2 | 92.0 |
| H — Moving v7 tags | 5 | 2 | 5 | 5 | 3 | 5 | 4 | 5 | 82.0 |

Option E wins because it is the only choice that resolves the embedded action
runtime, selected lint runtime, immutable identity, permissions, cache behavior,
evidence, and downstream prerequisite as one coherent contract. Option D is a
credible fallback if Node 24 compatibility testing uncovers a concrete package
defect, but no such defect is presently known.

### Selected resolution

Select Option E.

Revise P1 so its action section uses the following reviewed snapshots, subject
to the existing final implementation-time recheck:

```yaml
uses: actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1
```

```yaml
uses: actions/setup-node@820762786026740c76f36085b0efc47a31fe5020 # v7.0.0
with:
  node-version: '24'
  package-manager-cache: false
```

Keep:

```yaml
uses: actions/upload-artifact@043fb46d1a93c77aae656e7c1c64a875d1fc6a0a # v7.0.1
```

and:

```yaml
uses: actions/download-artifact@3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c # v8.0.1
```

In `markdownlint.yml`, explicitly set:

```yaml
permissions:
  contents: read
```

The Markdown job must run its existing `npm ci`, outer Markdown lint, and nested
Markdown lint commands on Node 24. No package or lockfile update belongs to this
finding.

Replace every checkout-v6-specific statement with checkout-v7 wording, while
retaining the controlled proof that persisted credentials permit the exact
authenticated push. Expand P1's implementation-time action check to cover
setup-node as well as checkout/upload/download. The check must:

1. resolve every selected release tag in the official action repository;
2. match the adjacent version comment;
3. inspect exact `action.yml` runtime metadata;
4. check for a newer required security release; and
5. update the SHA, comment, references, and evidence together if the selected
   release changes.

Change P1's `markdownlint.yml` scope statement so the allowed changes are:

- checkout reference;
- setup-node reference;
- `node-version`;
- `package-manager-cache`; and
- explicit read-only permissions.

Do not change the file's lint commands or error-handling topology unless Node 24
compatibility testing proves that a further change is necessary.

Finally, add P2 prerequisite checks confirming that the Markdown workflow uses
the approved checkout and setup-node full SHAs, Node 24, disabled automatic
package caching, explicit `contents: read`, and passing outer/nested lint.

## P1-2 — The helper does not bind the digest to the archive it consumes

### Options

#### Option A — Retain hash-by-path followed by open-by-path

Keep `Get-FileHash -LiteralPath`, close its internal file handle, and later open
the same pathname as a ZIP. Depend on the trusted runner and repeated path
containment/reparse checks to make replacement unlikely.

This is straightforward but does not prove that the hashed bytes are the bytes
parsed.

#### Option B — Hash the path twice

Hash the pathname before archive opening and again immediately after manifest
validation. Require both digests to match.

This detects some changes but still leaves separate opens. The archive can be
replaced between either hash and the `ZipArchive` open, and a replace-then-restore
sequence can evade the two snapshots.

#### Option C — Hold one file stream for hashing and ZIP processing

After all path/type checks, open the retained archive once as a read-only,
seekable `FileStream`. Compute SHA-256 through `Get-FileHash -InputStream`,
compare the digest, rewind the same stream, and construct `ZipArchive` over it.
Keep the stream and archive alive through manifest validation and extraction,
then dispose both deterministically.

This directly binds the digest to the consumed bytes without buffering the full
artifact.

#### Option D — Buffer the entire ZIP in memory

Read the retained archive into one byte array or `MemoryStream`, hash those
bytes, and construct `ZipArchive` over the same in-memory content.

This has strong identity semantics and makes path replacement irrelevant after
the read. It duplicates the complete archive in memory and creates avoidable
memory-exhaustion risk if artifact size grows or a compromised producer emits a
large archive.

#### Option E — Copy-and-hash into a new trusted file

Open the downloaded file for reading, create a new file under the trusted root
with `FileMode.CreateNew`, copy while hashing, then parse only the newly created
copy.

This can bind the copied bytes to a digest and isolate the parser from the
download pathname. It adds another lifecycle, cleanup rules, file identity,
partial-copy behavior, and storage cost. It also needs a second same-handle rule
or a post-copy reopen can recreate the original gap.

#### Option F — Reopen and compare platform file identities

Hash by path, reopen by path, then compare Windows file IDs or POSIX
device/inode metadata between handles before parsing.

This can detect replacement without holding a single handle, but requires
platform-specific interop not naturally shared by Windows PowerShell 5.1 and
PowerShell 7 on Linux. File identity equality also does not remove all mutation
concerns for a writable file.

#### Option G — Remove the helper digest and trust the download action

Rely only on pinned download-artifact native digest validation and remove the
helper's independent SHA-256 comparison.

This reduces code, but abandons the explicit propagated producer-digest check
and the intended defense-in-depth provenance chain.

#### Option H — Stream through a hashing tee into the parser

Create a custom stream wrapper that hashes bytes as `ZipArchive` reads them,
then compare the final digest.

This appears single-pass, but ZIP readers seek and do not necessarily read every
byte once in order. A correct random-access hashing wrapper would need extensive
state or full buffering and would delay digest failure until after archive
parsing, contrary to P1's required failure order.

### Evaluation rubric

This rubric emphasizes cryptographic provenance, compatibility, and bounded
resource use. A cybersecurity reviewer needs the digest to identify the exact
parser input; an operations engineer needs predictable memory and cleanup; a new
maintainer needs a contract that can be audited without platform interop.

| Criterion | Weight | Scoring guidance |
| --- | ---: | --- |
| Exact hashed/parsed byte identity | 30 | 5 makes the parser consume the exact held bytes that were hashed; 1 leaves independent path opens. |
| PowerShell 5.1/7 and Windows/Linux parity | 18 | 5 uses APIs present across the full support matrix; 1 depends on platform-specific interop. |
| Bounded memory and storage | 15 | 5 streams with constant auxiliary storage; 1 buffers an unbounded complete artifact. |
| Race and lifecycle simplicity | 12 | 5 removes pathname races with one obvious lifetime; 1 adds multiple reopen/copy windows. |
| Fail-before-parse semantics | 10 | 5 compares the digest before constructing/reading the archive; 1 discovers mismatch after parsing. |
| Testability and review clarity | 8 | 5 has direct assertions and a short auditable control flow; 1 requires timing races or opaque interop. |
| Deterministic disposal/cleanup | 5 | 5 has one clear nested-disposal contract; 1 adds partial resources and cleanup ambiguity. |
| Implementation churn | 2 | 5 is a small compatible correction; 1 requires a substantial new subsystem. |

The identity criterion alone carries almost one third of the decision because it
is the property the current contract claims but does not prove. Churn cannot
outweigh a broken provenance assertion.

### Scoring results

Abbreviations: BI = byte identity; CP = compatibility/parity;
BR = bounded resources; RL = race/lifecycle simplicity;
FP = fail-before-parse; TR = test/review clarity; DC = disposal/cleanup;
CH = churn.

| Option | BI | CP | BR | RL | FP | TR | DC | CH | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Path hash/open | 1 | 5 | 5 | 1 | 4 | 2 | 5 | 5 | 59.6 |
| B — Hash path twice | 2 | 5 | 5 | 2 | 4 | 2 | 5 | 4 | 67.6 |
| C — One held stream | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 4 | **99.6** |
| D — Full memory buffer | 5 | 5 | 1 | 4 | 5 | 4 | 4 | 3 | 82.2 |
| E — Copy-and-hash | 5 | 5 | 4 | 3 | 5 | 3 | 2 | 2 | 84.8 |
| F — Platform file IDs | 4 | 1 | 5 | 2 | 4 | 1 | 3 | 1 | 60.4 |
| G — Native digest only | 2 | 5 | 5 | 3 | 4 | 3 | 5 | 5 | 72.0 |
| H — Hashing tee | 3 | 3 | 3 | 2 | 1 | 1 | 3 | 1 | 49.6 |

Option C dominates because the existing cross-edition APIs already express the
required invariant directly. Options D and E also bind bytes, but pay substantial
resource or lifecycle costs without improving the security result.

### Selected resolution

Select Option C.

Revise P1's expected-digest and extraction contracts so the production helper
uses this exact order:

1. Resolve and validate all roots, path components, download-directory entries,
   and archive file type.
2. Repeat containment and indirection checks immediately before file opening.
3. Open the retained archive exactly once with:
   - `FileMode.Open`;
   - `FileAccess.Read`; and
   - an explicitly selected sharing mode.
4. Pass that `FileStream` to `Get-FileHash -InputStream -Algorithm SHA256`.
5. Validate that one hash object and one 64-hex digest were returned.
6. Compare actual and expected digests with ordinal case-insensitive equality.
7. On mismatch, fail before `ZipArchive` construction and before candidate-leaf
   creation.
8. Set the same stream's `Position` back to zero.
9. Construct one read-mode `ZipArchive` over that same stream.
10. Use that same archive instance for the complete manifest validation and all
    permitted entry-stream copies.
11. Dispose entry streams, the archive, and the underlying file stream in a
    deterministic nested `try`/`finally` structure.

The helper must not call a path-based ZIP opener after the digest check. The
archive path remains useful diagnostic context, but the held stream is the
security identity.

Update diagnostics and the harness contract:

- Digest mismatch must report expected/actual digest and fail before archive
  construction.
- Invalid-ZIP failure must occur only after a matching digest, when the same
  held stream is interpreted as a ZIP.
- A successful fixture must prove the helper did not require a second archive
  pathname open. Static inspection is acceptable for this implementation
  property; a nondeterministic race test is not required.
- Run the same-stream implementation under Windows PowerShell 5.1,
  PowerShell 7 on Windows, and PowerShell 7 on Ubuntu through the existing
  harness topology.

Use the same contract wording in the shared P1/T1 alignment statement, while
leaving the Terraform issue itself outside this revision.

## P1-3 — Exact directory contracts and candidate-leaf absence are underspecified

### Options

#### Option A — Leave implementation choice implicit

Keep “exactly one entry,” “exactly four paths,” and “candidate must not exist”
without naming an enumeration primitive or final-leaf algorithm.

An experienced implementer might choose safe APIs, but the issue's acceptance
criteria and harness cannot distinguish exhaustive enumeration from
`Get-ChildItem` without `-Force` or a dangling-link-blind existence check.

#### Option B — Standardize on `Get-ChildItem -LiteralPath -Force`

Use the filesystem provider's `Get-ChildItem -LiteralPath -Force` for every
directory count/set and parent-leaf check.

This includes hidden/system entries and is familiar to PowerShell developers.
It retains provider-layer behavior, output/error semantics, and edition
differences in the normative security primitive.

#### Option C — Use `Directory.EnumerateFileSystemEntries`

Resolve every path through the filesystem provider, then materialize
`[System.IO.Directory]::EnumerateFileSystemEntries()` for:

- the download-directory exact count;
- the candidate-parent leaf-name check;
- the extracted candidate exact set; and
- any other security-sensitive count/set assertion.

Use platform-appropriate ordinal leaf comparison, then inspect the matched
entry's attributes/type without following it. Repeat candidate-parent
enumeration immediately before creating the leaf. Reserve `Get-ChildItem
-LiteralPath -Force` for human-readable diagnostics.

This separates exhaustive identity enumeration from diagnostic presentation.

#### Option D — Use `DirectoryInfo.GetFileSystemInfos`

Construct a validated `DirectoryInfo` and call `GetFileSystemInfos()` for each
exact set. Compare `Name` properties and inspect typed entries/attributes.

This is also exhaustive and provides convenient metadata. It eagerly constructs
objects for every entry and couples identity and potentially stale metadata in
one snapshot. It remains a strong alternative if implemented carefully.

#### Option E — Generate a random candidate leaf and skip explicit absence checks

Have the helper choose a cryptographically random child name beneath the trusted
root and retry on collision. Do not accept `CandidateDirectory` from the caller.

This makes collision unlikely and simplifies callers, but changes the aligned
public interface, does not logically prove absence, complicates returned-path
plumbing, and contradicts P1's no-retry lifecycle.

#### Option F — Atomically reserve the candidate with platform-native directory handles

Use Windows native APIs and POSIX `openat`/`mkdirat`-style operations to bind a
directory handle and reject links atomically relative to a held parent handle.

This is the strongest defense against a concurrent local attacker, but requires
substantial platform interop unavailable as one straightforward
PowerShell-5.1/PowerShell-7 implementation. The hosted-runner threat model does
not justify that complexity.

#### Option G — Create first, then validate and delete on failure

Call `Directory.CreateDirectory`, inspect what now exists, and remove it if
validation finds a collision, link, or invalid archive.

This violates the required absent-until-validated lifecycle, can follow or
interact with a preexisting link, and turns a validation failure into a
destructive cleanup operation.

### Evaluation rubric

This rubric treats directory enumeration as an authorization boundary. A
security engineer needs all entries—including hidden and dangling—to count; an
implementer needs APIs that behave the same across supported editions; an
operator needs failures that never mutate an ambiguous target.

| Criterion | Weight | Scoring guidance |
| --- | ---: | --- |
| Exhaustive entry visibility | 26 | 5 necessarily includes hidden/system and all leaf directory entries; 1 permits filtered enumeration. |
| Final-leaf collision/link safety | 22 | 5 explicitly detects every matching final entry before creation; 1 creates or follows before validation. |
| Cross-platform/edition support | 18 | 5 uses the shared .NET/PowerShell 5.1 surface; 1 requires separate native implementations. |
| Deterministic semantics | 12 | 5 has precise ordinal comparison and snapshot rules; 1 leaves provider or retry behavior implicit. |
| Fixture testability | 10 | 5 yields deterministic hidden, file, directory, symlink, and dangling-link outcomes; 1 cannot state a reliable oracle. |
| Diagnostic quality | 6 | 5 can report the exact offending entry/type; 1 collapses conditions into generic existence failure. |
| Resource behavior | 4 | 5 is bounded by small directory snapshots without retries; 1 adds unbounded retry or heavy interop. |
| Churn/interface preservation | 2 | 5 retains the current public API with a focused implementation rule; 1 redesigns callers. |

The final-leaf and exhaustive-visibility criteria dominate because an “exact”
security check that omits one class of entry is not partially correct.

### Scoring results

Abbreviations: EV = exhaustive visibility; FL = final-leaf safety;
CP = compatibility; DS = deterministic semantics; FT = fixture testability;
DQ = diagnostics; RB = resource behavior; CH = churn/API preservation.

| Option | EV | FL | CP | DS | FT | DQ | RB | CH | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Implicit choice | 1 | 1 | 5 | 1 | 1 | 1 | 5 | 5 | 39.2 |
| B — `Get-ChildItem -Force` | 5 | 4 | 5 | 3 | 4 | 4 | 5 | 5 | 87.6 |
| C — .NET entry enumeration | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | **100.0** |
| D — `GetFileSystemInfos` | 5 | 5 | 5 | 4 | 5 | 5 | 4 | 5 | 96.8 |
| E — Random leaf/retry | 4 | 2 | 5 | 2 | 2 | 3 | 2 | 1 | 62.0 |
| F — Native directory handles | 5 | 5 | 1 | 4 | 3 | 3 | 3 | 1 | 73.6 |
| G — Create, inspect, delete | 3 | 1 | 5 | 2 | 2 | 2 | 4 | 3 | 53.6 |

Option C scores highest because it makes the exact-set primitive explicit while
retaining the existing helper API. Option D is nearly equivalent, but Option C
more cleanly separates name enumeration from later type/attribute inspection.

### Selected resolution

Select Option C.

Revise P1 so every normative exact count/set check materializes:

```powershell
[System.IO.Directory]::EnumerateFileSystemEntries($strResolvedDirectory)
```

after the directory has been resolved and proved to be on the FileSystem
provider. Do not use `Get-ChildItem` as the security decision primitive. If it is
used to format diagnostics, require `-LiteralPath -Force`.

For the candidate leaf:

1. Resolve and validate the existing candidate parent.
2. Derive one leaf name; reject an empty name, `.`/`..`, separators, rooted
   input, or any name that changes parent after `GetFullPath`.
3. Enumerate the parent and compare each entry's final name to the candidate
   leaf using ordinal-ignore-case on Windows and ordinal on Linux.
4. Reject any match, regardless of whether it is a file, directory, symlink,
   reparse point, or dangling link.
5. Repeat path containment, component-indirection, and exact parent enumeration
   immediately before `Directory.CreateDirectory`.
6. Create the leaf once. Never delete/recreate or retry under another name.

For the download directory and extracted candidate, materialize the complete
entry array before comparing count, names, and types. Require exactly the
expected entries, then separately require every expected path to be an ordinary
non-reparse file.

Add distinct harness cases with stable expected rejection phases for:

- a hidden/system extra download entry;
- an existing candidate file;
- an existing candidate directory;
- an existing candidate symlink/reparse leaf; and
- a dangling candidate link.

Where link construction is unavailable, mark only that construction-dependent
case as an explicit platform skip; never silently treat it as a pass. The hidden
entry, file, and directory cases must run on all supported environments.

## P1-4 — The P1/T1 alignment assertion remains factually false

### Options

#### Option A — Weaken P1 to match the attached T1

Remove explicit checkout/trusted-root and diagnostic parameters, derive checkout
from helper location, remove the tracked harness, and run inline fixtures in the
older topology.

This achieves textual parity quickly but discards P1's stronger trust envelope,
single fixture source, local validation, and clearer caller/helper contract.

#### Option B — Remove every alignment statement

Keep P1's design but describe it as wholly PSStyleGuide-specific. Do not claim
or pursue parity with T1.

This makes P1 factually self-contained and avoids coordination. It abandons the
user's stated generator/helper unification objective and invites semantic drift.

#### Option C — Make P1 the explicit target shared contract

Retain P1's stronger mandatory/optional parameters, trusted-root behavior,
same-stream identity, exhaustive enumeration, tracked harness, and execution
topology. Rewrite present-tense “is aligned” wording as a normative design
objective: these names and semantics are the shared contract that the parallel
Terraform work must also adopt before parity is claimed.

P1 remains independently implementable and has no runtime dependency on the
other repository. The PS issue describes only its side of the contract; T1 must
be coordinated separately.

#### Option D — Accept and document permanent divergence

List the differing P1 and T1 interfaces as intentional repository-specific
choices while retaining a high-level shared goal of deterministic generation.

This is truthful but treats security and test semantics as domain-specific even
though the artifact transport problem is the same. It weakens maintenance and
cross-repository review.

#### Option E — Publish one shared reusable helper/action

Move extraction and its tests into a third repository, reusable workflow, or
versioned action. Both repositories consume the same external implementation.

This guarantees implementation reuse but introduces release management,
external availability, token/trust policy, version pinning, and cross-repository
debugging. It violates the stated self-contained/no-runtime-dependency boundary.

#### Option F — Generate one repository's helper from the other

Treat one helper/harness pair as canonical and copy or generate it into the
second repository during development.

This can reduce authoring drift without runtime coupling, but adds a separate
source-of-truth tool and risks committed generated code diverging. The issue
slates would need to define regeneration, provenance, and review responsibilities
not currently in scope.

#### Option G — Keep the current false assertion and coordinate informally

Leave P1 unchanged and rely on the downstream author to notice and reconcile the
mismatch while implementing the two repositories in parallel.

This minimizes current editing but makes the handoff knowingly inaccurate and
offers no acceptance evidence for the claimed parity.

### Evaluation rubric

This is a coordination finding, but correctness still outweighs project
convenience. A security architect needs the stronger boundary preserved; a
downstream implementer needs truthful normative wording; maintainers of both
repositories need parity without making either repository operationally depend
on the other.

| Criterion | Weight | Scoring guidance |
| --- | ---: | --- |
| Security-contract integrity | 25 | 5 preserves explicit trust roots, same-stream identity, exhaustive checks, and harness ownership; 1 removes them. |
| Handoff truthfulness | 20 | 5 accurately distinguishes current local requirements from cross-repository coordination; 1 knowingly asserts false parity. |
| Durable cross-repository parity | 18 | 5 defines concrete shared names/semantics and evidence; 1 abandons or informally assumes parity. |
| Repository independence | 12 | 5 keeps both repositories self-contained at runtime; 1 creates a hard external dependency. |
| Testability and acceptance evidence | 10 | 5 makes shared behavior mechanically comparable; 1 offers no parity oracle. |
| Newcomer implementation clarity | 8 | 5 states exactly what P1 implements and what coordination means; 1 requires historical context. |
| Coordination/project risk | 5 | 5 gives one tractable parallel coordination step; 1 adds release systems or hidden work. |
| Draft churn | 2 | 5 needs only focused wording/contract edits; 1 creates a broad new architecture. |

The rubric intentionally gives only two percent to draft churn. Preserving a
misleading contract because it is already written would be a poor trade.

### Scoring results

Abbreviations: SI = security integrity; HT = handoff truth;
DP = durable parity; RI = repository independence; TA = test/acceptance;
IC = implementation clarity; CR = coordination risk; CH = churn.

| Option | SI | HT | DP | RI | TA | IC | CR | CH | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Weaken P1 | 1 | 4 | 5 | 5 | 3 | 3 | 4 | 2 | 66.6 |
| B — Remove alignment | 5 | 5 | 1 | 5 | 2 | 4 | 5 | 5 | 78.0 |
| C — P1 target contract | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | **100.0** |
| D — Permanent divergence | 4 | 5 | 1 | 5 | 3 | 4 | 5 | 4 | 74.6 |
| E — Shared external helper | 5 | 5 | 5 | 1 | 5 | 3 | 1 | 1 | 81.6 |
| F — Development-time generation | 5 | 4 | 5 | 4 | 4 | 2 | 2 | 1 | 82.2 |
| G — Informal coordination | 5 | 1 | 2 | 5 | 2 | 1 | 2 | 5 | 57.8 |

Option C is the only option that simultaneously preserves the improved security
contract, gives the downstream author truthful instructions, and keeps both
repositories self-contained.

### Selected resolution

Select Option C.

Revise P1's helper introduction to say that the following are the normative
PSStyleGuide side of the target P1/T1 shared contract:

- helper filename and purpose;
- five mandatory scalar parameter names and semantics;
- three optional caller-owned diagnostic labels;
- checkout/trusted-root relationship;
- same-held-stream digest/archive identity;
- exhaustive count/set and final-leaf enumeration;
- validation phases and diagnostic fields;
- tracked harness filename/ownership; and
- pre-merge and started-push-consumer execution semantics.

Do not say that the attached T1 already implements those elements. A
cold-reader-safe formulation is:

> These names and semantics define the PSStyleGuide side of the target shared
> P1/T1 contract. Coordinate the parallel TerraformStyleGuide issue to use the
> same common interface and behavior before claiming cross-repository parity.
> The expected manifest names and repository-specific artifact names remain the
> intentional differences. Neither repository has a runtime dependency on the
> other.

P1 remains implementable without waiting on a Terraform commit, so do not add a
GitHub blocked-by dependency on the other repository. The coordination gate is a
documentation/design consistency check before the two slates are represented as
unified.

Add an acceptance item requiring a side-by-side contract review of the final P1
and parallel T1 issue texts. That review must confirm matching common parameter
names, path/digest behavior, enumeration, harness ownership, and conditional job
semantics while permitting only named repository-specific manifest/artifact
differences.

## P1-5 — Writer preflight, commit proof, lease, and refspec use split identities

### Options

#### Option A — Keep the split built-in and explicit environment names

Validate `GITHUB_REF` in preflight, refer to `github.sha` in prose, then use
`TARGET_REF` and `EXPECTED_SHA` for the push. Rely on the workflow author having
assigned both pairs from the same GitHub context.

This normally works, but a future edit can change one source without invalidating
the other and no runtime invariant catches it.

#### Option B — Use only `GITHUB_REF` and `GITHUB_SHA`

Remove `TARGET_REF` and `EXPECTED_SHA`. Validate the built-in variables and use
them directly in every command.

This gives one source of truth and is simple. It makes the controlled stale-ref
and exact-lease drills harder to express without mutating built-in environment
variables or introducing separate test-only command variants.

#### Option C — Validate explicit inputs against built-ins, then use local constants

Keep `TARGET_REF` and `EXPECTED_SHA` as explicit workflow inputs from
`${{ github.ref }}` and `${{ github.sha }}`. At the start of the one complete
mutation block:

1. copy them to local scalar variables;
2. require equality with `GITHUB_REF` and `GITHUB_SHA`;
3. validate the ref form and object IDs; and
4. reuse those locals unchanged everywhere.

This gives an auditable handoff boundary, catches workflow/script wiring drift,
and lets controlled drills mutate one explicit test value while the production
invariant remains clear.

#### Option D — Embed GitHub expressions directly into the script

Interpolate `${{ github.ref }}` and `${{ github.sha }}` into PowerShell source
or command arguments at workflow evaluation time.

This removes environment aliases but mixes expression-language quoting with
PowerShell parsing, makes local execution harder, and risks injection/escaping
mistakes. GitHub recommends passing potentially untrusted expression data
through environment variables rather than direct script interpolation.

#### Option E — Derive target and SHA from local Git

Use `git symbolic-ref HEAD` for the branch and `git rev-parse HEAD^{commit}` for
the expected SHA.

Checkout commonly operates in detached-HEAD mode, so no local symbolic branch
may exist. The local commit proves candidate base identity but does not identify
the event's authorized remote destination by itself.

#### Option F — Parse the event payload

Read `GITHUB_EVENT_PATH` and derive the ref and SHA from event JSON inside the
writer.

This adds event-schema branching and file parsing even though GitHub already
supplies normalized ref/SHA values. It increases testing surface and makes the
writer depend on event payload shape.

#### Option G — Query the GitHub API and update the ref through REST

Replace native `git push` with a GitHub API ref update after comparing the
remote SHA.

This can express an explicit target and expected state, but GitHub's update-ref
API does not replace Git's atomic exact expected-object lease in the same simple
call. It also adds API permissions, response handling, and a second object
transport model.

#### Option H — Use a branch name and bare lease

Strip `refs/heads/`, push to a short branch name, and use bare
`--force-with-lease`.

This is concise but reintroduces implicit destination and remote-tracking state,
precisely the ambiguity P1 is designed to remove.

### Evaluation rubric

This finding is about keeping four representations of one authorization
decision—event ref, event SHA, local commit, and remote expected object—from
silently diverging. The rubric therefore gives most weight to explicit
destination and exact compare-and-swap behavior. Testability matters because
the issue requires controlled stale-ref and mismatch drills.

| Criterion | Weight | Scoring guidance |
| --- | ---: | --- |
| Target-ref and destination correctness | 24 | 5 validates one complete `refs/heads/...` identity and uses it as the explicit refspec destination; 1 relies on implicit or shortened destinations. |
| Expected-SHA and exact-lease safety | 24 | 5 proves one full expected object ID and uses it in an explicit exact-object lease; 1 uses remote-tracking state or no compare-and-swap. |
| Single validated identity reuse | 16 | 5 copies, validates, and reuses immutable local values; 1 validates different names from those later consumed. |
| Controlled-drill testability | 10 | 5 permits deliberate ref/SHA substitution without changing production command shape; 1 makes safe drills impractical. |
| Local object-format and commit proof | 8 | 5 accepts the repository-native full object ID and proves it resolves to the checked-out commit object; 1 assumes a fixed abbreviation or omits the proof. |
| Diagnostic and reviewer clarity | 8 | 5 reports built-in/input/local/remote mismatches at their boundary; 1 leaves the failing identity ambiguous. |
| Cross-environment maintainability | 6 | 5 uses normal Git and PowerShell behavior without event-schema or API coupling; 1 adds fragile environment-specific machinery. |
| Scope/churn efficiency | 4 | 5 is a focused rewrite of the existing mutation block; 1 introduces a new transport or authorization system. |

The target and lease criteria jointly carry almost half the score because a
correct local commit is insufficient if the workflow can address or compare a
different remote ref.

### Scoring results

Abbreviations: TR = target/ref correctness; ES = expected-SHA/lease safety;
IR = identity reuse; DT = drill testability; OP = object/commit proof;
DC = diagnostics; CM = cross-environment maintainability; CH = churn.

| Option | TR | ES | IR | DT | OP | DC | CM | CH | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Split identities | 3 | 3 | 1 | 3 | 3 | 2 | 4 | 5 | 54.8 |
| B — Built-ins only | 5 | 5 | 5 | 2 | 4 | 4 | 4 | 5 | 89.6 |
| C — Validated explicit inputs | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | **100.0** |
| D — Direct expressions | 4 | 4 | 4 | 2 | 4 | 2 | 1 | 4 | 69.2 |
| E — Local Git derivation | 2 | 3 | 3 | 2 | 5 | 3 | 3 | 4 | 57.2 |
| F — Event payload | 4 | 4 | 4 | 3 | 4 | 2 | 2 | 2 | 70.8 |
| G — REST ref update | 4 | 3 | 4 | 2 | 4 | 2 | 2 | 1 | 63.2 |
| H — Short ref/bare lease | 1 | 1 | 1 | 2 | 2 | 2 | 4 | 5 | 32.0 |

Option C makes the workflow-to-script handoff explicit without weakening the
Git lease or making the production branch hard to exercise in controlled
drills. Option B is safe in production but scores lower because its built-in
variables are awkward test seams.

### Selected resolution

Select Option C.

At the first executable line of the single complete mutation block, copy:

```powershell
$strTargetRef = [string]$env:TARGET_REF
$strExpectedSha = [string]$env:EXPECTED_SHA
```

The block must then:

1. reject empty values, leading/trailing whitespace, and CR/LF in either local;
2. require `$strTargetRef` to be one complete `refs/heads/...` ref accepted by
   `git check-ref-format`;
3. require exact ordinal equality between `$strTargetRef` and
   `[string]$env:GITHUB_REF`;
4. require exact ordinal-ignore-case equality between `$strExpectedSha` and
   `[string]$env:GITHUB_SHA`;
5. resolve `git rev-parse --verify 'HEAD^{commit}'`, require exactly one
   repository-native full object ID, and require it to equal
   `$strExpectedSha`;
6. call `git ls-remote --refs origin $strTargetRef`, require exactly one
   tab-delimited record, and require both its ref and object ID to equal the
   validated target/expected locals; and
7. reuse only those two locals in the explicit refspec and lease:

```powershell
git push origin `
    "HEAD:$strTargetRef" `
    "--force-with-lease=$strTargetRef`:$strExpectedSha"
```

Do not read `TARGET_REF`, `EXPECTED_SHA`, `GITHUB_REF`, or `GITHUB_SHA` again
after the equality checks. Do not reconstruct a short branch name.

Controlled drills may supply purpose-specific local test values to the same
validation/push logic so stale-ref and mismatched-input paths are observable.
The production workflow values must be restored and the final checked-in
mutation block must still source `TARGET_REF`/`EXPECTED_SHA` directly from
`${{ github.ref }}`/`${{ github.sha }}` and validate them against the built-ins.

## P1-6 — The fixture suite lacks an executable oracle

### Options

#### Option A — Keep the prose fixture inventory

Retain the current lists of invalid and valid conditions, with the general rule
that invalid cases throw and valid cases succeed.

This is compact, but it does not identify the required failure phase,
diagnostics, mutation postcondition, or successful byte/type assertions.

#### Option B — Add one narrative paragraph per fixture

Expand every fixture bullet into prose explaining setup and expected behavior.

This can capture all required facts, but reviewers cannot scan it reliably for
missing columns or compare cases. Repeated prose also makes phase names and
candidate-leaf rules prone to drift.

#### Option C — Put a normative case table and assertion rules in P1

Give every fixture a stable ID and one row containing platform/precondition,
expected outcome, exact failure phase, candidate-leaf postcondition,
diagnostic fields, and success assertions. Define a small phase vocabulary
before the table and make the tracked harness emit one record per row.

This keeps the executable oracle beside the helper contract and makes omissions
visible during issue review.

#### Option D — Add a machine-readable JSON or YAML fixture manifest

Create a separate data file with case IDs and expectations, then make the
harness load it.

This provides a strong executable source of truth, but expands P1's affected
file set and requires a schema/parser whose correctness must itself be tested.
Some setup logic—especially symlink creation—would still live in PowerShell.

#### Option E — Introduce Pester and express every case as a test

Add Pester to the repository and use test cases, tags, and assertions as the
normative oracle.

This yields rich reporting but adds a package/bootstrap decision and changes the
requested dependency-free tracked harness design. Windows PowerShell 5.1 and
PowerShell 7 environments may resolve different available Pester versions
unless P1 also adds dependency management.

#### Option F — Generate and assert fixtures inline in each workflow job

Keep no tracked fixture harness. Put complete setup and assertions directly in
the Windows, Ubuntu, and synchronization jobs.

This makes each job self-contained but duplicates security-sensitive test logic,
weakens local reproduction, and makes identical behavior hard to establish.

#### Option G — Split fixture-oracle work into a later issue

Implement the production helper and minimal success check in P1, then create a
follow-up issue for the complete negative suite.

This reduces the immediate P1 diff but ships the security boundary without the
evidence required to review its reject-before-mutate claims.

#### Option H — Use a normative table plus a separate generated results artifact

Adopt Option C and also require the harness to serialize a JSON results artifact
for every matrix cell.

This gives excellent machine comparison, but the repository already obtains
per-case evidence through logs and tracked source. A new result-upload lifecycle
adds naming, retention, and cross-job handling without resolving an identified
gap.

### Evaluation rubric

This finding concerns the difference between a list of interesting inputs and
a test oracle. A security reviewer must know that each rejection happens before
the prohibited mutation, while contributors must be able to see exactly what
successful extraction proves.

| Criterion | Weight | Scoring guidance |
| --- | ---: | --- |
| Oracle unambiguity | 24 | 5 assigns stable IDs and explicit expected outcomes/phases; 1 says only “throws” or “succeeds.” |
| Negative safety postconditions | 20 | 5 states candidate-leaf absence and forbidden side effects for every rejection; 1 does not test mutation timing. |
| Positive-case completeness | 15 | 5 asserts exact paths, ordinary-file types, bytes, and no extras; 1 accepts process success alone. |
| Single source and drift resistance | 14 | 5 keeps one normative case definition consumed by all environments; 1 duplicates or defers it. |
| Platform-conditional clarity | 10 | 5 distinguishes required cross-platform cases from explicit construction-dependent skips; 1 silently loses coverage. |
| Diagnostic usability | 8 | 5 specifies phase and case-specific fields; 1 treats any exception as sufficient. |
| Maintainability and extensibility | 6 | 5 makes new cases and missing expectations obvious without extra infrastructure; 1 is hard to extend consistently. |
| Scope/churn efficiency | 3 | 5 fits the existing helper/harness issue with no new dependency or artifact lifecycle; 1 adds broad machinery. |

Failure-phase and leaf-postcondition evidence outweigh convenience because the
production contract's core promise is reject-before-mutate.

### Scoring results

Abbreviations: OU = oracle unambiguity; NS = negative safety;
PC = positive completeness; SS = single source; PL = platform clarity;
DU = diagnostics; ME = maintainability; CH = churn.

| Option | OU | NS | PC | SS | PL | DU | ME | CH | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Prose inventory | 1 | 1 | 1 | 2 | 2 | 1 | 3 | 5 | 29.6 |
| B — Narrative cases | 4 | 4 | 4 | 3 | 4 | 4 | 2 | 3 | 74.2 |
| C — Normative table | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | **100.0** |
| D — Data manifest | 5 | 5 | 5 | 4 | 4 | 4 | 3 | 2 | 89.4 |
| E — Pester suite | 5 | 5 | 5 | 5 | 4 | 5 | 3 | 1 | 93.2 |
| F — Inline per-job fixtures | 4 | 4 | 4 | 1 | 3 | 3 | 1 | 2 | 63.2 |
| G — Later issue | 1 | 1 | 1 | 2 | 2 | 1 | 2 | 4 | 27.8 |
| H — Table plus result artifact | 5 | 5 | 5 | 5 | 5 | 5 | 4 | 2 | 97.0 |

Option C fully specifies the oracle using the tracked harness already in scope.
Option H adds useful reporting in some projects, but its extra artifact lifecycle
does not improve whether a case passes or fails.

### Selected resolution

Select Option C.

Replace P1's free-form fixture lists with a normative table. The issue must
define these failure phases, in execution order:

1. `context/path`;
2. `download-enumeration`;
3. `digest`;
4. `archive-open`;
5. `manifest`;
6. `candidate-leaf`;
7. `extraction`; and
8. `post-extraction`.

The table must include stable rows for:

- `V-01` exact archive and matching digest success;
- `V-02` exact archive whose entry external attributes resemble symlinks but
  whose permitted payloads extract as ordinary files;
- `P-01` valid sibling-prefix containment;
- `P-02` filesystem-qualified absolute path success;
- `D-01` digest mismatch;
- `Z-01` matching-digest invalid/truncated ZIP;
- `M-01` missing expected entry;
- `M-02` unexpected extra entry;
- `M-03` exact duplicate entry;
- `M-04` case-colliding entry;
- `M-05` through `M-12` nested forward-slash, nested backslash, traversal in
  both separator styles, leading slash, leading backslash, drive-qualified,
  and explicit directory entries;
- `M-13` file/directory collision and `M-14` empty entry name;
- `E-01` through `E-08` outside-trusted-root, checkout overlap, invalid root
  relationship, relative input, non-filesystem provider, Windows case variant,
  reparse component, and hidden/system extra-download-entry cases;
- `L-01` through `L-04` preexisting candidate file, directory,
  symlink/reparse point, and dangling link; and
- `X-01` an explicitly supplied empty optional diagnostic label.

Every negative row must name its platform/precondition, expected `reject`
outcome, exact phase, `candidate leaf absent` postcondition, and required
diagnostic fields. “Any exception” is not an oracle. Diagnostic assertions
must include the case ID and phase plus the relevant path, entry name,
expected/actual digest, or ref/root identity; they must not require secrets or
unstable stack traces.

Every success row must require:

- exactly the expected candidate paths and no extras;
- every payload is an ordinary non-reparse file;
- exact expected bytes, including the expected dot-content file;
- no writes outside the candidate directory; and
- the expected success phase/record.

`V-02` specifically proves that ZIP external attributes are metadata only and
cannot create a filesystem link. `P-01` and `P-02` must assert the intended
canonical containment result, not just extraction success. `E-06` must state
the Windows rejection and the applicable Linux ordinal result.

The harness must execute the same case IDs in each supported shell/platform.
Only a fixture whose setup primitive is unavailable—such as link construction
without required privilege—may be skipped, and the skip must be a named record
containing case ID, platform, and reason. A skip is neither a pass nor permission
to omit all other rows in that environment.

## P1/P2-1 — “Every push consumer on every run” is unattainable

### Options

#### Option A — Keep the universal wording

Continue to require every push consumer to run the helper on every push and
allow readers to infer that job-level conditions are an exception.

This preserves the current draft but leaves acceptance impossible on the
intended no-drift run, when the synchronization job is skipped.

#### Option B — Redefine “consumer” as a job that started

Change the sentence to “every started consumer” without documenting which jobs
start under which condition.

This removes the direct contradiction but leaves operators to reconstruct the
conditional graph from workflow YAML and makes evidence ownership ambiguous.

#### Option C — Define one explicit conditional topology in both issues

State that all four Windows push cells always download, self-test, and invoke
the helper; synchronization does so only when `has_changes=true`; the expected
no-drift run skips synchronization entirely; and static inspection plus the
controlled change-producing drill supplies synchronization evidence.

This describes exactly what GitHub Actions can execute and assigns evidence to
both graph branches.

#### Option D — Always start synchronization and condition only its mutation

Remove the synchronization job-level condition. Always download and self-test,
then skip commit/push steps when `has_changes=false`.

This makes the universal helper sentence attainable but changes the workflow
topology, artifact flow, permissions exposure, duration, and no-drift contract
solely to preserve wording.

#### Option E — Remove helper self-test/invocation from synchronization

Rely on the four Windows cells for all helper coverage. Let synchronization
consume their evidence or trust its downloaded artifact without invoking the
helper.

This simplifies conditional semantics but removes defense at the write-capable
point of consumption and weakens the intended writer trust boundary.

#### Option F — Force `has_changes=true` on every push

Arrange generation so synchronization always has a change, causing the job and
helper to run.

This defeats idempotence, invites bot-commit loops or meaningless changes, and
invalidates the no-drift milestone.

#### Option G — Add a separate unconditional synchronization-preflight job

Create a read-only job that always runs the harness/helper, while the existing
write-capable synchronization job remains conditional.

This can provide unconditional evidence but adds a fifth consumer-like path
whose result still does not prove that the conditional writer used the same
downloaded bytes and invocation.

### Evaluation rubric

This is a workflow-graph truthfulness finding. The chosen text must preserve
helper validation at the write-capable boundary while describing both the
ordinary no-drift run and the deliberately change-producing proof.

| Criterion | Weight | Scoring guidance |
| --- | ---: | --- |
| Semantic attainability | 25 | 5 can be satisfied by every described graph branch; 1 requires steps inside a skipped job. |
| Security at the point of use | 20 | 5 retains helper validation in every job that actually consumes the archive, including the writer; 1 removes writer-side validation. |
| Evidence truth and completeness | 18 | 5 assigns runtime/static/drill evidence to every conditional branch; 1 accepts evidence that cannot exist. |
| Operator comprehension | 15 | 5 states which jobs start and which steps run for both condition outcomes; 1 hides conditions behind shorthand. |
| No-drift behavior preservation | 10 | 5 preserves the skipped synchronization job on a clean run; 1 manufactures changes or changes the graph. |
| P1/P2 consistency | 8 | 5 uses one identical conditional contract in prerequisites, design, and acceptance; 1 leaves contradictions. |
| Scope/churn efficiency | 4 | 5 fixes issue wording and evidence allocation only; 1 adds jobs or redesigns execution. |

The rubric rewards attainable evidence rather than a larger raw count of
executions. A deliberately skipped job is correct behavior, not a missing test.

### Scoring results

Abbreviations: SA = semantic attainability; PU = point-of-use security;
ET = evidence truth; OC = operator comprehension; ND = no-drift preservation;
CI = cross-issue consistency; CH = churn.

| Option | SA | PU | ET | OC | ND | CI | CH | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Universal wording | 1 | 4 | 1 | 1 | 4 | 1 | 5 | 41.2 |
| B — “Started consumer” only | 3 | 5 | 3 | 2 | 5 | 3 | 5 | 70.6 |
| C — Explicit topology | 5 | 5 | 5 | 5 | 5 | 5 | 5 | **100.0** |
| D — Always start sync | 5 | 5 | 5 | 4 | 2 | 4 | 2 | 87.0 |
| E — Remove writer invocation | 5 | 1 | 4 | 4 | 5 | 5 | 4 | 76.6 |
| F — Force changes | 5 | 4 | 2 | 2 | 1 | 2 | 1 | 60.2 |
| G — Add preflight job | 5 | 3 | 4 | 3 | 4 | 4 | 1 | 75.6 |

Option C is the only resolution that is simultaneously true, secure at the
writer, and faithful to the established no-drift graph.

### Selected resolution

Select Option C.

Use this one conditional contract throughout P1 and P2:

- On every push run, all four Windows consumer matrix cells start, download the
  producer artifact, run the tracked helper harness, and invoke the production
  helper on the retained archive.
- The synchronization job starts only when the producer reports
  `has_changes=true`. A started synchronization job downloads the same producer
  artifact, runs the same harness, invokes the same helper, and only then enters
  the writer mutation block.
- On the expected no-drift P1/P2 push, `has_changes=false`; synchronization is
  skipped at the job level, so none of its steps run.
- Runtime logs from the four Windows cells prove the unconditional push path.
  Static inspection of the synchronization graph plus a controlled
  `has_changes=true` drill proves the conditional writer path.

Replace “every push consumer on every run” and similar universal shorthand in
P1 acceptance and P2 prerequisites/acceptance. Use “every started push
consumer” only when it is immediately accompanied by the topology above.

The controlled drill must restore the repository to the intended generated
state. Its evidence must show the synchronization job started, ran harness and
helper before the mutation block, and exercised the exact explicit-ref,
exact-lease push path. A normal no-drift run must show the four Windows cells
succeeded and synchronization was skipped—not failed or silently omitted.

## P2-1 — The named validation function is undocumented

### Options

#### Option A — Leave the transient function unchanged

Keep `Get-OrdinalOccurrenceCount` without comment-based help because it appears
only inside a planning-document validation block rather than a committed
`.ps1` file.

This is functionally adequate but conspicuous in an issue whose output is a
PowerShell style guide and whose validation block is meant to be copied.

#### Option B — Add complete comment-based help

Retain the named function and add synopsis, description, parameter help,
outputs, examples, notes, and link/compatibility information consistent with
the generated guide's function standard.

This is maximally self-demonstrating, but turns a short local counting primitive
into a disproportionately large part of the acceptance command.

#### Option C — Use a local script block instead of a function

Store the same strongly typed `param` block and ordinal, non-overlapping loop in
a narrowly named script-block variable, invoke it with `&`, and keep the
synthetic false-positive self-test.

This preserves behavior and copy/paste use while avoiding a named command to
which the function-help rule applies.

#### Option D — Duplicate the loop inline at every call site

Remove the helper abstraction and repeat the `IndexOf` loop for each required
section/marker.

This avoids an undocumented function but creates many subtly drift-prone copies
of security-relevant validation logic.

#### Option E — Count escaped regular-expression matches

Use `[regex]::Matches($content, [regex]::Escape($needle)).Count`.

This is concise, but the default regex matching/culture/options contract is less
obviously identical to `StringComparison.Ordinal`, and future edits can
accidentally remove escaping.

#### Option F — Use PowerShell `Select-String -AllMatches`

Pipe content to `Select-String`, escape the needle, and count match objects.

This depends on cmdlet line/input behavior and regex semantics when the required
contract is an ordinal count over one canonical string.

#### Option G — Move the validator into a permanent repository script

Create a reusable `.ps1` validation tool with full help and tests, then have the
issue invoke it.

This is appropriate if validation becomes a maintained product, but P2
currently scopes a one-time copy-ready acceptance check and does not authorize
another implementation file.

### Evaluation rubric

The functional counting contract is primary: canonical sections must be counted
ordinally and non-overlapping, including a synthetic example where naïve marker
counting would lie. The presentation must also be internally credible for a
PowerShell style-guide issue.

| Criterion | Weight | Scoring guidance |
| --- | ---: | --- |
| Counting-algorithm correctness | 28 | 5 preserves ordinal, non-overlapping counting over the full string and rejects empty needles; 1 changes matching semantics. |
| Style-guide self-consistency | 18 | 5 either fully documents a named function or uses a construct outside that rule; 1 demonstrates the exact antipattern being removed. |
| Copy/paste acceptance usability | 16 | 5 remains one self-contained command block with little boilerplate; 1 needs external setup. |
| PowerShell 5.1/7 compatibility | 12 | 5 uses APIs and syntax shared by both editions; 1 depends on edition-specific behavior. |
| Readability and proportionality | 10 | 5 makes the small primitive obvious without dominating the validator; 1 obscures the acceptance logic. |
| Self-testability | 8 | 5 retains direct normal and synthetic false-positive assertions; 1 is hard to isolate. |
| Issue-scope preservation | 5 | 5 changes only the validation example; 1 adds permanent files or dependencies. |
| Churn | 3 | 5 is a narrowly mechanical replacement; 1 requires broad restructuring. |

Correctness outweighs aesthetics, but Option A cannot win merely because the
current function works: the finding is specifically about handoff consistency.

### Scoring results

Abbreviations: AC = algorithm correctness; SC = self-consistency;
CU = copy usability; CP = compatibility; RP = readability/proportionality;
ST = self-testability; IS = issue scope; CH = churn.

| Option | AC | SC | CU | CP | RP | ST | IS | CH | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Undocumented function | 5 | 1 | 4 | 5 | 4 | 5 | 5 | 5 | 80.4 |
| B — Full function help | 5 | 5 | 4 | 5 | 2 | 5 | 5 | 2 | 89.0 |
| C — Local script block | 5 | 5 | 5 | 5 | 4 | 5 | 5 | 4 | **97.4** |
| D — Duplicate inline loops | 4 | 4 | 2 | 5 | 1 | 2 | 5 | 3 | 67.2 |
| E — Escaped regex | 3 | 5 | 5 | 5 | 5 | 4 | 5 | 5 | 87.2 |
| F — `Select-String` | 2 | 5 | 3 | 4 | 3 | 3 | 5 | 4 | 66.6 |
| G — Permanent validator | 5 | 5 | 3 | 5 | 4 | 5 | 1 | 1 | 85.2 |

Option C retains the exact algorithm and its tests while removing the
documentation inconsistency with minimal scope. Option B is valid but adds
large help prose to a transient local primitive.

### Selected resolution

Select Option C.

In P2's canonical validation block, replace:

```powershell
function Get-OrdinalOccurrenceCount {
    param(...)
    # Existing ordinal, non-overlapping loop.
}
```

with a block-scoped variable such as:

```powershell
$scriptGetOrdinalOccurrenceCount = {
    param(
        [Parameter(Mandatory)]
        [string] $Content,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $Needle
    )

    $intCount = 0
    $intIndex = 0

    while (($intIndex = $Content.IndexOf(
                $Needle,
                $intIndex,
                [System.StringComparison]::Ordinal
            )) -ge 0) {
        $intCount++
        $intIndex += $Needle.Length
    }

    return $intCount
}
```

Invoke it with:

```powershell
& $scriptGetOrdinalOccurrenceCount -Content $strContent -Needle $strNeedle
```

Keep the existing normal assertions and the synthetic false-positive self-test.
Do not replace ordinal string matching with regex or line-oriented cmdlet
semantics. Validate the final fenced block with both Windows PowerShell 5.1 and
PowerShell 7 parsers.

## Separate maintenance — The Markdown dependency lock reports advisories

### Options

#### Option A — Accept the advisories without a tracked action

Leave the lock unchanged and rely on reduced token permissions and hosted-runner
isolation.

Least privilege limits repository impact but does not restore CI availability;
crafted pull-request Markdown is still processed by the affected parser/glob
chain.

#### Option B — Fold dependency updates into P1

Add `package.json`, `package-lock.json`, parser/linter upgrades, and regression
work to P1 alongside Node/action and artifact-pipeline changes.

This resolves the advisories early but combines two independent security review
surfaces and contradicts P1's intentionally narrow Markdown-workflow scope.

#### Option C — Fold dependency updates into P2

Upgrade the Markdown toolchain while changing generator serialization and
content.

This provides an opportunity to test generated Markdown, but dependency
resolution is unrelated to P2's generator contract and makes a regression hard
to attribute.

#### Option D — Make dependency remediation a prerequisite to P1

Create and complete a maintenance issue before any P1 work.

This prioritizes availability risk but delays the higher-priority action
runtime, archive-identity, path, and writer corrections even though the
advisories do not prevent those changes from being reviewed.

#### Option E — Track a separate maintenance issue

Keep the P1/P2 order unchanged and create a distinct maintenance item for the
Markdown package and lockfile refresh. Require Node 24 outer/nested lint
regression, fixture coverage for affected parsing/globbing paths, and a recorded
post-update audit.

This gives the advisories a real owner and acceptance evidence without silently
expanding either issue in the two-issue slate.

#### Option F — Add npm `overrides` only

Force fixed transitive versions while keeping the current direct
`markdownlint-cli2` range.

Overrides can be a tactical fix, but compatibility across the parser/glob graph
must still be tested and npm already indicates that the direct toolchain update
is the supported complete remediation.

#### Option G — Enable Dependabot and accept generated update PRs

Configure automated npm update PRs for `.github/workflows`.

Automation improves ongoing maintenance, but it does not by itself decide or
prove the current pre-1.0 toolchain migration. It also adds repository policy
work beyond the present issue revision.

#### Option H — Suppress or audit-exempt the findings temporarily

Record allow-list entries or make CI tolerate the current audit result until a
future date.

This can avoid noisy gates, but no current gate is blocking work and suppression
would reduce visibility without remediating the availability exposure.

### Evaluation rubric

This boundary decision must keep a real CI availability risk visible while
protecting the reviewability of P1 and P2. Because npm proposes a pre-1.0 direct
tool upgrade, passing regression evidence is nearly as important as removing
advisories.

| Criterion | Weight | Scoring guidance |
| --- | ---: | --- |
| Security remediation | 25 | 5 removes the affected dependency paths and verifies the audit; 1 only accepts or suppresses them. |
| Functional regression evidence | 20 | 5 requires outer/nested lint and targeted parser/glob fixtures on the updated lock; 1 changes or accepts dependencies without proof. |
| Scope isolation and reviewability | 16 | 5 gives dependency work a coherent independent diff; 1 combines unrelated generator/helper changes. |
| Scheduling urgency | 12 | 5 creates an actionable near-term item without indefinite deferral; 1 leaves no owner. |
| Node/toolchain compatibility | 10 | 5 proves the selected direct/transitive versions on Node 24; 1 assumes compatibility. |
| Maintenance sustainability | 8 | 5 leaves a supported direct dependency chain and repeatable audit practice; 1 relies on temporary suppression. |
| Handoff clarity | 6 | 5 names affected files, checks, owner boundary, and completion evidence; 1 records only a vague concern. |
| Churn efficiency | 3 | 5 avoids unnecessary policy or unrelated implementation changes; 1 adds broad machinery. |

This rubric does not treat “not a P1/P2 blocker” as “unimportant.” It separates
sequencing from ownership.

### Scoring results

Abbreviations: SR = security remediation; RE = regression evidence;
SI = scope isolation; SU = scheduling urgency; TC = toolchain compatibility;
MS = sustainability; HC = handoff clarity; CH = churn.

| Option | SR | RE | SI | SU | TC | MS | HC | CH | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Accept | 1 | 1 | 4 | 1 | 3 | 1 | 1 | 5 | 36.0 |
| B — Fold into P1 | 5 | 3 | 1 | 5 | 3 | 2 | 2 | 1 | 64.4 |
| C — Fold into P2 | 5 | 3 | 1 | 3 | 3 | 2 | 2 | 1 | 59.6 |
| D — Prerequisite issue | 5 | 5 | 4 | 5 | 5 | 4 | 5 | 2 | 93.4 |
| E — Separate maintenance issue | 5 | 5 | 5 | 4 | 5 | 5 | 5 | 5 | **97.6** |
| F — Overrides only | 3 | 3 | 4 | 4 | 2 | 2 | 3 | 4 | 62.6 |
| G — Dependabot only | 4 | 4 | 5 | 3 | 4 | 5 | 4 | 3 | 81.8 |
| H — Suppress | 1 | 2 | 4 | 2 | 3 | 1 | 3 | 4 | 44.2 |

Option E gives the advisories an actionable and testable resolution without
delaying or obscuring the higher-priority P1 corrections. Option D is also
defensible if project policy requires zero known high advisories before any
other work, but that policy is not present in this repository.

### Selected resolution

Select Option E.

Do not add dependency updates to P1 or P2 and do not create a third issue file
inside this prompt's two-file revision scope. Record the handoff as a separate
maintenance issue to be created and prioritized alongside, but not as a
blocked-by prerequisite for, P1.

That maintenance issue should affect only the Markdown toolchain and directly
necessary tests/documentation, principally:

- `.github/workflows/package.json`;
- `.github/workflows/package-lock.json`;
- parser/glob fixture or lint-script files if regression coverage requires
  them; and
- narrowly related Markdown-workflow install/lint configuration.

Its acceptance evidence must:

1. perform a clean install under Node 24;
2. run the outer Markdown lint suite;
3. run all nested-fence fixtures;
4. exercise representative pathological parser/linkification/glob inputs with
   bounded completion;
5. record `npm --prefix .github/workflows audit --json`;
6. explain any remaining advisory rather than silently suppressing it; and
7. confirm the package and lockfile diff contains no unrelated dependency
   churn.

The current reproducible baseline is seven development-dependency advisories:
five high and two moderate. P1 may still prove that the existing lock runs on
Node 24, but that compatibility result is not a claim that the advisories have
been remediated.
