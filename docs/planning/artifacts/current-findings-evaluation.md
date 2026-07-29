# PSStyleGuide findings evaluation

## Evaluation status

This file evaluates the open PSStyleGuide findings recorded in
`docs/planning/artifacts/current-findings.md`, one finding at a time. Each
finding received its own options, purpose-built weighted rubric, scoring table,
and implementation-ready selected disposition before work started on the next
finding.

The following findings are open and in scope:

1. `C-01` — replace the inaccurate P1/T1 identity claim.
2. `C-02` — complete P1's path-envelope validation.
3. `C-03` — select and justify the held stream's sharing mode.
4. `C-04` — make rejection postconditions truthful and add fail-closed cleanup.
5. `C-05` — make workflow temporary paths satisfy the unique-root contract.
6. `C-06` — decide whether and how to add a malformed-transport drill.
7. `C-07` — decide GitHub Actions update governance.
8. `C-08` — give current npm advisories a concrete owner and ordering.
9. `C-P2` — preserve P2's narrow scope and refresh its P1 prerequisite.
10. `I-P1-01` — prove the Node 24 toolchain and lint paths locally.
11. `I-P1-02` — complete optional diagnostic-label fixture coverage.
12. `I-P2-01` — prove the rationale heading occurs exactly once.

`C-09` is not open: the review found the current P1/P2 CI evidence wording
already correct. It remains a preservation constraint when the issues are
edited.

The primary-source and implementation-state facts used in the evaluations are
retained in
[`current-findings-evaluation-research.md`](current-findings-evaluation-research.md).

## Evaluation conventions

- Scores use a 1–5 scale, where 5 is best.
- Each finding has its own criteria and weights; a criterion is not reused
  mechanically merely because it appeared in another finding.
- Weighted totals are calculated as
  `sum(score / 5 * criterion weight)` and therefore range from 0 to 100.
- Technical correctness, security, and legitimate operator/developer usability
  receive more weight than churn, implementation effort, or original issue
  boundaries.
- T1/T2 are context for intentional convergence only and are not revised.

## Finding evaluations

### C-01 — Replace the inaccurate P1/T1 identity claim

#### Problem and perspectives

P1 currently says the two repositories share almost the complete helper and
harness contract and that only names differ. The current drafts contradict
that statement in stream handling, path-envelope breadth, lifecycle cleanup,
fixture placement, and workflow transport details.

- A security reviewer needs to distinguish genuinely shared invariants from
  repository-specific threat-model choices.
- An implementer coming in cold needs to know what may be copied, what must be
  adapted, and what must remain intentionally different.
- A maintainer needs drift to be visible without creating a new cross-repository
  release dependency prematurely.
- A project manager needs P1 to remain independently deliverable while still
  advancing the generator-unification objective.

#### Options

**Option A — Keep the current identity claim.**

Treat the drafts as conceptually identical and rely on implementers to discover
the differences. This has no authoring churn, but it makes acceptance criteria
false and encourages unsafe copy/paste.

**Option B — Replace identity with a short prose disclaimer.**

Say the implementations are “similar but not identical” and list the largest
differences in prose. This corrects the overclaim but provides no durable
crosswalk for future changes.

**Option C — Add a contract-level convergence matrix only.**

Replace the blanket statement with a table covering parameters, archive
identity, path security, manifest grammar, lifecycle, diagnostics, harness, and
transport. For each row, state the shared invariant and the repository-specific
choice. Keep both helpers and harnesses repository-local.

**Option D — Extract a shared external helper/action during P1.**

Move common logic to a shared repository, package, submodule, or remote
composite/JavaScript action and have both repositories consume it. Permutations
include a versioned PowerShell module, reusable workflow, composite action, or
generated vendored file. This maximizes physical reuse but adds provenance,
release, availability, pinning, cross-edition, and coordinated-rollout
requirements that P1 does not currently specify.

**Option E — Establish a shared behavioral contract now and defer physical
unification.**

Combine Option C's matrix with:

- an explicit list of shared security invariants;
- a stable fixture-intent crosswalk where the same behaviors should be tested;
- named repository-specific deviations with rationale;
- acceptance language that forbids claiming unlisted equivalence; and
- a non-goal stating that a shared packaged helper/action requires a later,
  separately reviewed trust and release design.

This can later support any Option D packaging permutation without making the
current issue depend on one.

#### Evaluation rubric

This rubric is specific to a cross-repository convergence claim.

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Factual truth and auditability | 28 | A reviewer must be able to prove every claimed shared/different behavior from the issue text. |
| Security-invariant convergence | 24 | Unification is useful only if the two repositories visibly agree on the important safety properties. |
| Long-term drift control | 18 | Future maintainers need a durable way to notice divergence. |
| Cold-start implementer clarity | 15 | A new contributor must know what to share, copy, adapt, and test. |
| Independent evolution and supply-chain safety | 10 | Each repository must remain operable without an underspecified new external dependency. |
| Authoring and implementation churn | 5 | Lower churn is useful, but it cannot outweigh correctness or clarity. |

Scores use 1–5, where 5 is best.

#### Scoring

| Option | Truth 28 | Security 24 | Drift 18 | Clarity 15 | Independence 10 | Churn 5 | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Current claim | 1 | 2 | 2 | 2 | 5 | 5 | 43.4 |
| B — Prose disclaimer | 3 | 3 | 2 | 3 | 5 | 4 | 61.4 |
| C — Matrix only | 5 | 4 | 4 | 5 | 5 | 3 | 89.6 |
| D — Shared dependency now | 4 | 5 | 5 | 3 | 1 | 1 | 76.4 |
| E — Contract now, packaging later | 5 | 5 | 5 | 5 | 4 | 3 | **96.0** |

#### Selected disposition

Select **Option E**.

In P1, replace the near-total-identity sentence with a “Cross-repository
convergence contract” subsection. Add a table with these exact conceptual rows:

1. public helper parameters;
2. archive identity and digest order;
3. path roots, containment, and link rejection;
4. manifest grammar and exact-entry rules;
5. destination lifecycle and cleanup;
6. diagnostics and optional caller labels;
7. permanent fixture intent; and
8. GitHub artifact transport.

For every row, state:

- the invariant deliberately shared with T1;
- P1's concrete implementation;
- the intentional Terraform-specific difference, if any; and
- the evidence that proves the P1 side.

Explicitly preserve P1's stronger held-stream property as an intentional
PowerShell-specific choice. Do not describe filenames and artifact names as the
only differences. Keep the helper and harness repository-local in P1. Add a
non-goal explaining that a shared module/action would need its own versioning,
pinning, provenance, cross-edition, failure-mode, and rollout design after the
behavioral contracts converge. Update acceptance criteria so the matrix, not a
blanket equivalence claim, defines success.

### C-02 — Complete P1's path-envelope validation

#### Problem and perspectives

P1 validates only part of the filesystem path that determines where untrusted
archive bytes are read and where validated output is created. It does not
consistently cover both declared roots from their volume/share root, root
overlap in both directions, post-extraction revalidation, or the residual race
model.

- A cybersecurity engineer needs every path component capable of redirecting
  access covered, not only descendants below the trusted temporary root.
- A PowerShell maintainer needs one contract that works under Windows
  PowerShell 5.1 and PowerShell 7.
- An operator needs a precise phase and offending component when a hosted
  runner violates the expected topology.
- A business stakeholder needs the issue to avoid claiming a guarantee that a
  path-based implementation cannot provide.

#### Options

**Option A — Keep the current partial checks.**

Validate the two roots and the components between the trusted temporary root
and working paths. This is cheapest but leaves ancestors and after-extraction
state outside the asserted envelope.

**Option B — Add only mutual root separation.**

Reject either root containing the other and retain the current descendant
component walk. This closes one concrete configuration error but not ancestor
links, later substitution, or incomplete lifecycle checks.

**Option C — Adopt a complete repeated lexical/component contract with an
honest race model.**

Normalize absolute inputs, require mutually disjoint roots, enumerate from each
filesystem volume/share root through all existing components, reject
redirection/type/enumeration uncertainty, and repeat relevant checks before
archive open, before candidate creation, and after extraction. State that this
narrows but does not eliminate path check/use races and restrict support to a
job-owned/no-competing-writer hosted-runner model.

**Option D — Implement an OS-native handle-relative sandbox.**

Open directory handles without following links and perform all traversal and
creation relative to verified handles. Permutations include Windows
`CreateFile`/reparse-tag logic plus Unix `openat`/`O_NOFOLLOW`, a native helper,
or a compiled .NET component. This can provide a stronger same-object boundary
but is not realistically portable through one PowerShell script across the
declared editions/platforms without a substantially new implementation and test
surface.

**Option E — Use canonical-path resolution only.**

Resolve final targets with modern link APIs or provider commands, then check
that the resulting strings are inside the trusted root. This is shorter than
Option C but cannot run uniformly on Windows PowerShell 5.1, may follow a link
in order to classify it, and still leaves check/use races.

#### Evaluation rubric

This rubric is specific to filesystem trust-boundary enforcement.

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Link, junction, mount, and ancestor attack coverage | 30 | Any unchecked redirecting component can invalidate containment. |
| Cross-edition/platform implementability | 18 | The same helper must run in the P1 PowerShell 5.1/7 topology. |
| Honest treatment of check/use races | 16 | The issue must neither ignore nor overclaim the residual guarantee. |
| Permanent fixture strength | 16 | Security behavior must be reproducible, phase-specific, and regression-tested. |
| Failure diagnostics and operator usability | 12 | Operators must know which phase/component violated the trust model. |
| Implementation effort and issue churn | 8 | Cost matters, but it is subordinate to a correct trust boundary. |

#### Scoring

| Option | Attack coverage 30 | Portability 18 | Race honesty 16 | Fixtures 16 | Diagnostics 12 | Effort 8 | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Current partial checks | 2 | 5 | 1 | 2 | 3 | 5 | 54.8 |
| B — Root separation only | 3 | 5 | 2 | 3 | 3 | 4 | 65.6 |
| C — Complete repeated contract | 5 | 5 | 5 | 5 | 4 | 3 | **94.4** |
| D — Native handle sandbox | 5 | 1 | 5 | 3 | 3 | 1 | 68.0 |
| E — Canonical target strings | 3 | 2 | 2 | 2 | 3 | 4 | 50.0 |

#### Selected disposition

Select **Option C**.

Replace P1's path subsection with an explicit “Root and full-component trust
contract.” It must require the helper to:

1. resolve each declared root exactly once to one existing ordinary filesystem
   directory;
2. reject equality or containment in either direction between checkout and
   trusted temporary roots;
3. require download and candidate paths to be strict trusted-root descendants
   and outside checkout using separator-aware, OS-appropriate comparison;
4. build the lexical absolute sequence from the volume root or complete UNC
   share root through every existing component of both declared roots, the
   download directory and retained archive, the candidate parent, and created
   candidate paths;
5. obtain attributes through APIs available under Windows PowerShell 5.1;
6. reject every reparse point, symbolic link, junction, volume mount, dangling
   entry, unexpected file/directory type, and attribute/enumeration/resolution
   failure without following a link to classify it;
7. repeat relevant component, containment, parent, type, and leaf checks
   immediately before opening the archive, immediately before creating the
   candidate, and after extraction before returning; and
8. emit stable path-phase identifiers and the offending absolute component.

State the supported model verbatim in substance: GitHub-hosted runners,
runner-controlled ancestors, a job-owned checkout, one unique job-owned trusted
temporary root, and no competing writer capable of replacing entries during
the helper call. Say that repeated checks narrow check/use exposure and do not
provide an OS-native directory-handle guarantee.

Extend the permanent table with root equality/both containment directions,
outside-root, sibling-prefix, case-variant, provider-qualified, ancestor link,
intermediate component link, post-creation substitution, and post-extraction
revalidation cases. A capability-based link skip must remain named and must not
count as a pass.

### C-03 — Select and justify the held stream's sharing mode

#### Problem and perspectives

P1 requires an “explicitly selected sharing mode” but does not select one.
That makes the final stream-concurrency contract implementation-defined.

- A security reviewer wants subsequent writers and deletion sharing denied
  while verified bytes are being parsed.
- An operator or diagnostic tool may have a legitimate reason to read the same
  retained archive concurrently.
- A cross-platform maintainer must not mistake `FileShare` for a universal
  operating-system lock against every non-.NET actor.
- A test author needs an exact constructor and observable concurrency behavior.

#### Options

**Option A — Leave the enum to the implementer.**

Retain the abstract requirement. This avoids prescribing more than the issue
currently proves but defeats auditable implementation and can yield different
behavior across contributors.

**Option B — Select `FileShare.None`.**

Decline every subsequent open until the helper closes the archive. This offers
the narrowest .NET sharing contract and is appropriate if no concurrent
observation is legitimate. It can unnecessarily block benign readers and
differs from the documented default behavior of read-only `FileStream` helpers.

**Option C — Select `FileShare.Read`.**

Allow later read-only opens while not granting write or delete sharing. This is
the documented normal mode for concurrent readers and the default of several
read-oriented .NET APIs, but P1 would name it explicitly rather than rely on a
default. The issue must continue relying on its no-competing-writer operating
model rather than claiming this flag is a universal lock.

**Option D — Select `FileShare.ReadWrite` or include `FileShare.Delete`.**

Allow monitoring tools to write, replace, or delete while the stream is open.
This maximizes external flexibility but directly weakens the verified-byte
threat model and is unjustified for a retained candidate archive.

**Option E — Snapshot the archive into memory, then close the file.**

Open with `None` or `Read`, copy all bytes into a byte array or `MemoryStream`,
close the file, and hash/parse the in-memory snapshot. This also binds hash and
parse to one byte sequence and reduces later filesystem dependence. It adds
memory/size policy, another copy, sensitive-buffer lifecycle, and denial-of-
service considerations that P1 does not currently need for this small archive.

**Option F — Add sharing mode as a public helper parameter.**

Let each caller choose `None` or `Read`. This is flexible but moves a security
decision to every workflow call, expands the public contract and fixtures, and
allows the same helper to behave inconsistently.

#### Evaluation rubric

This rubric is specific to the archive stream's concurrency policy.

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Protection of the verified byte sequence | 28 | Later write/delete sharing must not undermine digest-then-parse identity. |
| Legitimate read-only observability | 20 | Diagnostics should not be blocked without a security reason. |
| Explicitness and reviewability | 18 | The constructor contract must be visible and identical across implementations. |
| Cross-platform semantic honesty | 14 | The issue must state what .NET sharing proves and what the runner model still assumes. |
| Permanent testability | 12 | The selected behavior needs stable positive and negative oracles. |
| Complexity and churn | 8 | A simple stream contract is preferable once the safety properties are met. |

#### Scoring

| Option | Byte protection 28 | Read usability 20 | Explicit 18 | Platform honesty 14 | Tests 12 | Simplicity 8 | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Unspecified | 2 | 3 | 1 | 2 | 1 | 5 | 42.8 |
| B — `FileShare.None` | 5 | 2 | 5 | 4 | 4 | 4 | 81.2 |
| C — `FileShare.Read` | 5 | 5 | 5 | 5 | 5 | 4 | **98.4** |
| D — Write/delete sharing | 1 | 5 | 5 | 4 | 3 | 4 | 68.4 |
| E — Memory snapshot | 5 | 4 | 5 | 4 | 4 | 2 | 86.0 |
| F — Caller parameter | 3 | 4 | 2 | 3 | 3 | 2 | 58.8 |

#### Selected disposition

Select **Option C: `FileShare.Read`**.

P1 must require the retained archive to be opened exactly in substance as:

```powershell
[System.IO.FileStream]::new(
    $strArchivePath,
    [System.IO.FileMode]::Open,
    [System.IO.FileAccess]::Read,
    [System.IO.FileShare]::Read
)
```

Use a constructor form available in both supported PowerShell/.NET editions.
Do not grant `Write` or `Delete`. Compute SHA-256 from that stream, require it
to be seekable, rewind to byte zero, and construct `ZipArchive` over that exact
stream. Keep the stream and archive disposed through deterministic
`try`/`finally` handling.

Add permanent Windows sharing fixtures that prove:

- a second .NET read-only open is allowed;
- a subsequent .NET write open is denied while the held stream exists; and
- the primary stream remains usable for hash/rewind/parse after the allowed
  reader closes.

Do not make a cross-platform assertion that `FileShare.Read` alone prevents
every external actor from changing a pathname. State that the flag is
defense-in-depth for the held file and that the complete supported model still
requires the C-02 job-owned/no-competing-writer boundary. This combination
gives benign read observability without permitting .NET write/delete sharing
and makes the issue's intended enum unambiguous.

### C-04 — Make rejection postconditions truthful and add fail-closed cleanup

#### Problem and perspectives

P1 simultaneously says every rejection leaves the candidate absent and that
pre-existing files, directories, and links remain unchanged. It also lacks a
complete rule for removing invocation-created output after a later failure.

- A security engineer needs rejected untrusted bytes removed without following
  an attacker-controlled link.
- A data-safety reviewer needs absolute protection for any pre-existing leaf.
- An implementer needs state ownership recorded explicitly rather than inferred
  during exception handling.
- An operator needs the original validation failure and any cleanup failure,
  not a misleading success or overwritten exception.
- A test author needs postconditions based on the fixture's starting state.

#### Options

**Option A — Require absence and remove pre-existing-leaf fixtures.**

Narrow the supported contract so callers guarantee an absent leaf and stop
testing existing objects. The helper could still reject pre-existing state, but
the issue would lose proof that it never overwrites or deletes that state.

**Option B — Add case-specific postconditions without cleanup.**

Correct the table to say absent remains absent and pre-existing remains
unchanged. Leave post-creation failure residue to the caller or job-level
temporary-root cleanup. This makes assertions truthful but lets the helper
return after leaving a candidate that looks usable.

**Option C — Extract to a staging sibling, then rename to the requested leaf.**

Use an invocation-owned staging directory, fully validate it, then move it to
the initially absent candidate leaf. This creates a clearer commit point and
can reduce partial visibility. It still requires safe staging cleanup, adds
another path envelope and rename behavior, and provides limited benefit because
the current candidate itself is job-private and not consumed until return.

**Option D — Validate all extracted content in memory before any directory
creation.**

Read the four permitted entries into bounded byte arrays, validate BOM/CR and
manifest rules, then create the candidate and write final bytes. This reduces
post-creation validation failures but adds explicit size/memory limits and
cannot eliminate write/finalization failures, so cleanup remains necessary.

**Option E — Track invocation ownership and perform narrow, revalidated
fail-closed cleanup.**

Keep manifest validation before creation. Record the exact state created by the
invocation. On later failure, dispose streams, revalidate the candidate
envelope, delete only known ordinary files created by the helper, and remove
the now-empty invocation-created directory. Never recursively delete or touch a
pre-existing object. Preserve both original and cleanup failures.

**Option F — Use unconditional recursive force deletion.**

On any failure call `Remove-Item -Recurse -Force` on the candidate. This is
simple and usually clears residue, but it can follow or remove substituted
state and is incompatible with the trust model.

#### Evaluation rubric

This rubric is specific to output ownership and failure recovery.

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Preservation of pre-existing filesystem state | 24 | A failed verifier must never destroy caller-owned data or links. |
| Removal/containment of rejected invocation output | 24 | Untrusted partial output must not be mistaken for an accepted candidate. |
| Original and cleanup error fidelity | 16 | Incident response requires both causes and retained-path context. |
| Link-safe cleanup behavior | 14 | Cleanup itself must not become a traversal or substitution vulnerability. |
| Deterministic fixture oracles | 14 | Every starting state needs a precise observable postcondition. |
| Lifecycle complexity and churn | 8 | Simpler code is safer only after ownership and cleanup are correct. |

#### Scoring

| Option | Preserve 24 | Contain residue 24 | Error fidelity 16 | Cleanup safety 14 | Test oracles 14 | Simplicity 8 | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Absence only | 1 | 3 | 2 | 2 | 2 | 5 | 44.8 |
| B — Truthful table only | 5 | 2 | 3 | 3 | 4 | 4 | 69.2 |
| C — Staging and rename | 5 | 5 | 4 | 4 | 4 | 2 | 86.4 |
| D — In-memory prevalidation | 5 | 5 | 4 | 5 | 3 | 1 | 84.8 |
| E — Owned narrow cleanup | 5 | 5 | 5 | 5 | 5 | 3 | **96.8** |
| F — Recursive force delete | 1 | 4 | 2 | 1 | 3 | 4 | 48.0 |

#### Selected disposition

Select **Option E**.

P1 must replace every blanket rejection postcondition with this state table:

| Initial candidate leaf | Rejection postcondition |
| --- | --- |
| Absent | Remains absent for every pre-creation failure |
| Ordinary file | Same file and bytes remain unchanged |
| Ordinary directory | Same directory and contents remain unchanged |
| Link, junction, reparse point, or dangling link | Same entry and link target text remain unchanged |
| Created by this invocation | Removed after a later failure, or an explicit fail-closed cleanup failure reports the retained path |

The helper must keep explicit booleans/list state indicating whether it created
the leaf and which exact ordinary files it created. On failure after creation:

1. capture the original exception and phase;
2. dispose `ZipArchive`, entry streams, output streams, and the held
   `FileStream`;
3. rerun the relevant C-02 containment/component/type checks;
4. remove only the known ordinary files created by this invocation;
5. remove the candidate directory only if it is the same invocation-created,
   ordinary, empty directory;
6. never recurse, follow, delete, or “repair” an unexpected entry; and
7. return nonzero with the original failure plus cleanup failure and retained
   absolute path if safe cleanup cannot finish.

Add a post-extraction BOM/CR fixture that proves the normal cleanup path removes
the helper-created candidate. Preserve `L-01`–`L-04` with state-specific
unchanged assertions. Add stable `cleanup` diagnostics and require the harness
to treat residue after an otherwise cleanable failure as a failure. Update the
acceptance criteria to distinguish pre-creation absence, pre-existing-state
preservation, successful post-creation cleanup, and explicit unsafe-cleanup
retention.

### C-05 — Make workflow temporary paths satisfy the unique-root contract

#### Problem and perspectives

P1 requires a unique job-owned trusted temporary root but shows a fixed
`${{ runner.temp }}/style-guide-candidate-download` path. The example therefore
does not instantiate the boundary the helper is required to validate.

- A DevOps engineer needs matrix cells and reruns isolated from one another.
- A security reviewer needs unambiguous ownership before cleanup.
- A PowerShell 5.1 maintainer needs a portable primitive, not a modern
  runtime-only API.
- An incident responder benefits from the selected root being logged without
  using predictable reuse as a security control.

#### Options

**Option A — Keep the fixed child path.**

Rely on GitHub-hosted runner isolation and clean images. This will normally
work, but it contradicts the issue and gives no proof that existing state is not
being reused.

**Option B — Use a deterministic run/job-qualified directory.**

Construct a name from run ID, run attempt, job/matrix edition, and EOL mode.
This is human-readable and isolates known jobs/reruns if every dimension is
included. It is still predictable, easy to get incomplete when the matrix
changes, and can reuse state within the same job if a step is repeated.

**Option C — Create a high-entropy job-owned child with bounded collision
retry.**

Generate a fresh leaf below `RUNNER_TEMP`, require it to be absent, create it,
verify it is an ordinary non-reparse directory, and derive fixed download and
candidate children beneath it. Retry a bounded number of times on a name
collision. Log and propagate the absolute root only within the job.

**Option D — Create a temporary file, delete it, and reuse its name as a
directory.**

Use `GetTempFileName`/`New-TemporaryFile` to reserve a name, remove the file,
then create a directory. This creates a file-to-directory substitution window
and does not work uniformly across the declared editions without extra logic.

**Option E — Treat the entire runner temporary directory as the trusted root.**

Pass `${{ runner.temp }}` directly and create fixed children below it. This
avoids pretending the child is the root, but broadens ownership to unrelated
runner/action temporary state and makes safe cleanup impossible.

**Option F — Use `Directory.CreateTempSubdirectory`.**

Use the modern .NET API that creates a unique temporary directory. It is an
excellent primitive on current .NET, but unavailable to Windows PowerShell
5.1/.NET Framework and would make fixture/workflow implementations diverge.

#### Evaluation rubric

This rubric is specific to job-temporary workspace construction.

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Collision, rerun, and matrix isolation | 25 | Each consumer must own state that no other attempt/cell can accidentally reuse. |
| Clarity of the helper containment boundary | 22 | The exact root and its strict descendants must be obvious to code and reviewers. |
| Cleanup ownership and blast radius | 18 | A job may clean only state it demonstrably created. |
| PowerShell edition/platform portability | 14 | The same design must work in Desktop/Core cells and the permanent harness. |
| Diagnostics and reproducibility | 12 | Failures must report the actual root and creation/collision phase. |
| Implementation complexity | 9 | Avoid elaborate allocation machinery once uniqueness and ownership are sound. |

#### Scoring

| Option | Isolation 25 | Boundary 22 | Cleanup 18 | Portability 14 | Diagnostics 12 | Simplicity 9 | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Fixed path | 1 | 3 | 2 | 5 | 4 | 5 | 58.0 |
| B — Run/job-qualified | 3 | 4 | 4 | 5 | 5 | 4 | 80.2 |
| C — Random child + retry | 5 | 5 | 5 | 5 | 4 | 3 | **94.0** |
| D — Temp file conversion | 4 | 4 | 4 | 4 | 3 | 2 | 74.0 |
| E — Whole runner temp | 2 | 3 | 1 | 5 | 3 | 5 | 56.8 |
| F — Modern temp-subdirectory API | 5 | 5 | 5 | 1 | 4 | 4 | 84.6 |

#### Selected disposition

Select **Option C**.

Every production helper consumer and the permanent harness must create one
unique root below the exact runner-controlled temporary parent. Use a primitive
available in both supported editions, such as
`[System.IO.Path]::GetRandomFileName()`, with this contract:

1. normalize and validate the runner temporary parent;
2. generate a high-entropy child leaf;
3. prove no file, directory, reparse point, or dangling entry occupies it;
4. create it without `-Force`;
5. verify the resulting object is the expected ordinary, non-reparse directory;
6. retry a documented bounded number of times only for an actual name
   collision, and fail for every other error;
7. emit the absolute root to the current job's outputs/environment without
   reconstructing it in later steps;
8. create `download` below it and reserve a separate, initially absent
   `candidate` child; and
9. pass the unique root, download directory, and candidate path explicitly to
   the helper.

The issue must acknowledge that `GetRandomFileName` does not create the
directory and `CreateDirectory` can return an existing directory. The
absence/create/verify sequence operates under C-02's runner-controlled,
no-competing-writer model; it must never silently accept an existing leaf.

Add an `always()` cleanup step (excluding cancellation where appropriate) that
revalidates the unique root and removes only the known job-owned archive,
ordinary candidate files/directories, download directory, and empty root.
Cleanup failure must be visible and must not mask the earlier failure.
Diagnostic upload, if needed, must occur before cleanup. Replace every fixed
download-path example, update helper call examples, and require the permanent
harness to use the same topology.

### C-06 — Decide whether and how to add a malformed-transport drill

#### Problem and perspectives

P1 proves malformed ZIP rejection through direct helper fixtures and proves a
valid ZIP through GitHub artifact transport. It does not join those two
boundaries by transporting malformed bytes with the production actions.

- A DevOps reviewer wants evidence that action configuration preserves one raw
  file for the helper rather than pre-extracting or reshaping it.
- A security tester wants the failure attributed to archive parsing, not a
  deliberately falsified digest.
- A project manager wants a controlled test that does not pollute `main` or add
  a permanently failing workflow.
- An operator needs approval and write jobs demonstrably gated after rejection.

#### Options

**Option A — Add no drill and narrow the evidence claims.**

Keep unit/helper coverage and valid-transport integration. State explicitly
that malformed bytes were not transported end to end. This is logically
honest but leaves a meaningful boundary unexercised.

**Option B — Treat the permanent invalid-ZIP helper fixture as sufficient.**

Keep current claims and argue that artifact transport is byte-preserving based
on action metadata. This has strong helper determinism but only indirect
evidence at the transport/helper seam.

**Option C — Add one controlled-branch malformed raw-ZIP transport drill.**

In the already required temporary branch, upload one deterministic malformed
ZIP as a single unarchived file, propagate its real immutable ID/digest, use the
production download inputs, and prove all validation cells reject inside the
helper before candidate creation. Approval and writer must skip.

**Option D — Corrupt GitHub artifact storage to provoke a native digest
mismatch.**

Attempt to change bytes after upload while preserving the original metadata
digest. GitHub does not expose a supported mutation path for this; trying to
simulate it would test a different system or require unsupported interference.

**Option E — Add a permanent expected-failure artifact job to every pull
request.**

Upload and download a malformed artifact on every PR, capture the helper's
expected nonzero status, and make the job pass only for the correct failure.
This provides continuous end-to-end coverage but adds artifact storage,
workflow complexity, and negative-test control-flow risk on every change.

**Option F — Download through a separate REST/CLI path.**

Upload normally, then fetch the artifact with `gh` or the REST API and invoke
the helper. This tests GitHub storage but not the pinned production download
action and introduces authentication/tooling differences.

#### Evaluation rubric

This rubric is specific to negative integration evidence at the artifact seam.

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| End-to-end malformed-byte coverage | 28 | The test should cross upload, ID/digest propagation, download, and helper rejection. |
| Precise failure attribution | 20 | It must distinguish native digest success from helper archive-format rejection. |
| Equivalence to production action configuration | 18 | The same pins and inputs should carry the test bytes. |
| Protected-branch and write-path safety | 14 | The drill must never require a test commit on `main` or reach synchronization. |
| Reproducibility and maintenance value | 12 | A future maintainer must be able to repeat and interpret it. |
| Workflow cost and issue churn | 8 | Negative evidence should not impose unnecessary permanent CI cost. |

#### Scoring

| Option | E2E 28 | Attribution 20 | Production parity 18 | Safety 14 | Repeatability 12 | Cost 8 | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Narrow claims | 1 | 4 | 1 | 5 | 4 | 5 | 56.8 |
| B — Helper fixture only | 2 | 5 | 2 | 5 | 5 | 5 | 72.4 |
| C — Controlled raw-ZIP drill | 5 | 5 | 5 | 5 | 4 | 3 | **94.4** |
| D — Corrupt service digest | 5 | 1 | 2 | 1 | 1 | 1 | 46.0 |
| E — Permanent PR negative job | 5 | 5 | 5 | 4 | 5 | 1 | 90.8 |
| F — REST/CLI download | 4 | 3 | 3 | 3 | 2 | 2 | 61.6 |

#### Selected disposition

Select **Option C**.

Add a “Malformed-transport rejection drill” beneath P1's controlled temporary-
branch evidence:

1. create a deterministic, reviewed invalid/truncated ZIP in the temporary
   branch only;
2. upload that exact single file with the approved pinned upload action and
   `archive: false`;
3. acknowledge that the file's name becomes the artifact name and `name` is
   ignored, which is harmless because selection uses the immutable ID;
4. propagate the real upload `artifact-id` and `artifact-digest` as the
   candidate outputs;
5. let every four-cell Windows consumer download that exact ID using
   `skip-decompress: true` and `digest-mismatch: error`;
6. prove native download/digest verification succeeds for the actual uploaded
   malformed bytes;
7. prove the helper's independent digest comparison succeeds and archive
   construction/read then fails with the stable archive-format phase before
   manifest acceptance or candidate creation;
8. prove approval and synchronization skip; and
9. remove every test-only mutation before completing the issue.

Do not call this a native digest-mismatch test and do not attempt to corrupt
GitHub's artifact service. Do not require the rejected artifact to reach the
writer: the writer uses the same helper and is separately covered by the
permanent harness and successful controlled `has_changes=true` drill.

### C-07 — Decide GitHub Actions update governance

#### Problem and perspectives

P1 correctly pins current action versions to full SHAs, but the repository has
no mechanism that opens reviewable updates when those pins age. The issue
currently forbids Dependabot without assigning that maintenance elsewhere.

- A supply-chain reviewer wants immutable execution-time references and timely
  notification of upstream releases.
- A maintainer wants version comments and SHAs updated together in a normal PR.
- A security executive wants human approval retained rather than auto-merging
  workflow-code changes.
- A project manager wants a named owner instead of indefinite residual prose.
- A developer wants low-noise configuration that does not mix npm upgrades into
  an action-pin change.

#### Options

**Option A — Keep exact pins and no update mechanism.**

Rely on manual audits. This preserves immutable execution and has no bot noise,
but update discovery is informal and easy to defer.

**Option B — Create a separate action-governance issue.**

Keep P1 at five files and require a later issue to add Dependabot or another
update process. This can be coherent if that issue is actually created and
ordered, but it separates a small configuration change from the pins it governs.

**Option C — Add minimal review-only GitHub Actions Dependabot in P1.**

Add one `.github/dependabot.yml` entry for `github-actions`, directory `/`, and
weekly scheduling. Keep full-SHA references, same-line release comments, human
review, and no auto-merge. Make the configuration P1's sixth affected file.

**Option D — Add both GitHub Actions and npm Dependabot entries in P1.**

Use one configuration file for action and npm updates. This increases coverage
but opens package-update PRs before C-08's advisory/remediation policy is
defined and conflates separate acceptance surfaces.

**Option E — Auto-merge patch/minor action updates.**

Use Dependabot plus auto-approval/merge rules. This shortens exposure to old
pins but automatically changes executable workflow dependencies and conflicts
with deliberate review of runtime/input/output changes.

**Option F — Depend exclusively on an organization/enterprise policy.**

Configure centrally managed action updating or policy enforcement outside the
repository. This may be ideal at scale, but no such authoritative current policy
is in evidence and the issue would not be self-contained for a downstream
implementer.

#### Evaluation rubric

This rubric is specific to immutable action-pin maintenance.

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Timely action-update discovery | 24 | Immutable pins otherwise remain stale without a visible signal. |
| Preservation of immutable pins and human review | 23 | Update automation must not silently execute mutable or unreviewed code. |
| Explicit repository ownership | 18 | The maintenance path must exist in the slate, not as an aspiration. |
| Cross-repository governance consistency | 14 | Matching PS/Terraform policy reduces maintainer surprise and drift. |
| Noise and failure-domain control | 12 | The mechanism should propose only the dependency class P1 can review well. |
| Configuration and review churn | 9 | A small, legible configuration is preferable once governance is adequate. |

#### Scoring

| Option | Discovery 24 | Immutable/review 23 | Ownership 18 | Consistency 14 | Noise 12 | Churn 9 | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Manual only | 1 | 5 | 1 | 1 | 5 | 5 | 55.2 |
| B — Separate issue | 4 | 5 | 4 | 3 | 4 | 4 | 81.8 |
| C — Actions-only Dependabot | 5 | 5 | 5 | 5 | 4 | 4 | **95.8** |
| D — Actions plus npm | 5 | 4 | 4 | 4 | 2 | 2 | 76.4 |
| E — Auto-merge | 5 | 1 | 3 | 3 | 1 | 2 | 53.8 |
| F — External policy only | 5 | 5 | 3 | 5 | 4 | 3 | 86.8 |

#### Selected disposition

Select **Option C**.

Add `.github/dependabot.yml` to P1's affected files and require exactly this
minimal semantic configuration:

```yaml
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
```

State that Dependabot is review-only. Do not add auto-merge, auto-approval, or
an npm ecosystem entry. Every proposed action update must receive human review
of:

- upstream release notes and repository provenance;
- the full commit SHA and same-line version annotation;
- declared action runtime;
- changed inputs, outputs, defaults, and runner minimums;
- compatibility with `archive: false`, immutable ID selection,
  `skip-decompress`, and fail-closed digest behavior where applicable; and
- all P1/P2 workflow evidence relevant to the changed action.

Dependabot visibility must not replace the full-SHA execution policy. Update
P1's file count, scope guard, staging list, validation, and acceptance criteria
from five to six files. Add a static check that the configuration has only the
one intended ecosystem/directory/schedule entry and that no workflow contains
an unpinned external action.

### C-08 — Give current npm advisories a concrete owner and ordering

#### Problem and perspectives

The current lockfile audit reports seven vulnerable package nodes, including
the direct Markdown parser/linter toolchain used on pull-request-controlled
Markdown. P1/P2 merely call this “separate maintenance,” and no matching open or
closed repository issue exists.

- A security reviewer needs a bounded remediation target and a recorded
  disposition for anything that remains.
- A documentation/tooling maintainer needs dependency upgrades tested against
  both ordinary and nested Markdown lint behavior.
- A project manager needs an explicit place in the issue order.
- A P1 implementer needs a stable package baseline while redesigning the
  generator/workflow trust boundary.
- A business stakeholder needs the high-severity inventory treated as real
  work without hiding a pre-1.0 semver-major upgrade inside another change.

#### Options

**Option A — Leave the “separate maintenance” prose unchanged.**

Record the audit but create no issue or order. This has no immediate churn and
no accountable path to remediation.

**Option B — Bundle package remediation into P1.**

Update `package.json`/lockfile while changing the writer, helper, harness,
workflow architecture, action pins, and Node runtime. This reduces exposure
soon but combines two broad regression surfaces and obscures whether failures
come from workflow redesign or parser/linter changes.

**Option C — Create a P0 dependency issue before P1.**

Remediate advisories first, then rebaseline all P1/P2 toolchain assumptions.
This is the right permutation if repository policy forbids proceeding with
known high findings or if an active exploit/exposure assessment demands
immediate treatment. No such blocking policy or active incident is currently
in evidence.

**Option D — Create a separately scoped P3 after P2.**

Keep P1 and P2 on the currently validated lint baseline, then perform the
dependency/lockfile migration with its own audit and regression gates. Add a
weekly npm Dependabot entry in P3 after P1 creates the shared configuration
file. P1 and P2 link P3 as the concrete owner.

**Option E — Insert dependency remediation between P1 and P2.**

Complete workflow hardening first, then upgrade the lint toolchain before the
content fix. This shortens exposure compared with Option D, but it makes the
named P1/P2 sequence misleading or requires renaming the existing P2.

**Option F — Add npm Dependabot without remediating the current audit.**

Let the bot propose updates and treat its PRs as the owner. This improves
discovery but does not define acceptance, major-upgrade review, or the
disposition of existing advisories.

**Option G — Point C-08 to issue #137.**

Extend the existing deterministic lint/Husky/line-ending issue informally.
That issue has a different goal and acceptance surface; treating it as the
owner would make both issues harder to review and would not be truthful today.

#### Evaluation rubric

This rubric is specific to an already-known vulnerable development toolchain.

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Risk reduction with explicit accountability | 25 | Known findings need a named issue, owner, and completion condition. |
| Regression isolation and review quality | 21 | Parser/linter changes must be distinguishable from generator/workflow changes. |
| Time-to-remediation proportional to exposure | 18 | Pull-request-controlled Markdown makes indefinite deferral unacceptable. |
| Stable P1/P2 implementation baseline | 14 | The two large existing issues should not chase a moving lint baseline mid-change. |
| Audit and dependency-test completeness | 14 | Remediation must cover direct/transitive paths, clean install, and both lint modes. |
| Scheduling and issue churn | 8 | Ordering should remain understandable to the downstream author. |

#### Scoring

| Option | Accountability 25 | Isolation 21 | Timeliness 18 | Stable baseline 14 | Completeness 14 | Scheduling 8 | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Residual prose | 1 | 2 | 1 | 5 | 1 | 5 | 41.8 |
| B — Bundle into P1 | 4 | 1 | 5 | 1 | 3 | 2 | 56.6 |
| C — P0 before P1 | 5 | 5 | 5 | 3 | 5 | 2 | 89.6 |
| D — Separate P3 after P2 | 5 | 5 | 3 | 5 | 5 | 4 | **91.2** |
| E — Between P1 and P2 | 5 | 5 | 4 | 4 | 5 | 3 | 90.4 |
| F — Dependabot only | 3 | 4 | 3 | 5 | 2 | 5 | 67.6 |
| G — Reuse issue #137 | 2 | 1 | 3 | 3 | 2 | 4 | 42.6 |

#### Selected disposition

Select **Option D: add a real P3 after P2**.

Create `docs/planning/PSStyleGuide/03PSStyleGuideP3.md` with the H1 title
`Remediate Markdown lint dependency advisories and add npm update governance`.
The slate order becomes P1, P2, P3. P3 must:

1. rerun and preserve the current `npm audit --package-lock-only --json`
   baseline;
2. map every direct and transitive advisory path;
3. review the proposed pre-1.0 semver-major `markdownlint-cli2` update and
   current upstream release notes rather than blindly running
   `npm audit fix --force`;
4. make only deliberate `package.json` and lockfile changes;
5. run on Node 24 with a clean `npm ci`;
6. prove the existing outer and nested Markdown lint commands and configuration
   semantics remain intact;
7. require a clean audit or an explicit, time-bounded, owner-assigned
   disposition for every residual finding;
8. add a weekly `npm` entry for directory `/.github/workflows` to the
   `.github/dependabot.yml` created by P1;
9. retain review-only dependency updates and prohibit auto-merge; and
10. document before/after package versions, advisory paths, and lockfile churn.

P1 and P2 should link to P3 by local issue-description path and say that their
read-only permissions reduce blast radius but do not remediate vulnerable
parsing code. P3 is not a P1/P2 prerequisite under the selected ordering. If
the repository later supplies a policy that forbids merging while remediable
high advisories remain, move the same issue to P0 and rebaseline P1/P2; do not
silently change ordering based on an assumed policy.

### C-P2 — Preserve P2's narrow scope and refresh its P1 prerequisite

#### Problem and perspectives

P2 is a focused documentation-source correction whose validation deliberately
reuses P1's generator/workflow architecture. P1's selected dispositions change
that prerequisite, but copying all P1 implementation detail into P2 would make
the smaller issue harder to understand and easier to drift.

- A documentation author needs P2 to say exactly which two source files change
  and which four files are generated.
- A new implementer needs to know P1 must already be merged and which commands/
  CI behavior can be trusted.
- A project manager needs the P1 → P2 → P3 order unmistakable.
- A maintainer needs one source of truth for helper security details.
- A reviewer needs P2's no-drift push evidence stated precisely.

#### Options

**Option A — Copy all final P1 contracts into P2's prerequisite.**

Restate path, stream, cleanup, action, workflow, fixture, and Dependabot details
inside P2. This is self-contained but duplicates hundreds of lines and will
drift.

**Option B — Use only a generic P1-complete statement.**

Replace the detailed prerequisite with one link/sentence. This minimizes churn
but does not tell a cold-start implementer which assumptions P2 validation
relies on.

**Option C — Use a concise invariant summary and normative link to P1.**

State that P1 is merged, list only the stable interfaces/behaviors P2 consumes,
and make P1 the implementation source of truth. Explicitly state that P2 does
not reopen P1 choices. Preserve P2's own exact validation/evidence wording.

**Option D — Make P2 independent of P1.**

Duplicate helper/workflow setup or provide alternate commands that work before
P1. This weakens sequential delivery, expands P2, and creates two paths for the
same generator validation.

**Option E — Merge P2 into P1.**

Fix the blank-line example while redesigning the generator. This reduces issue
count but mixes a content/version change into an issue intentionally expected
to leave generated artifact bytes unchanged.

#### Evaluation rubric

This rubric is specific to a sequential issue prerequisite.

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Correct execution-order dependency | 24 | P2 must never run against the pre-P1 generator/workflow contract. |
| Preservation of P2's narrow content scope | 23 | The small visual/rationale correction should remain independently reviewable. |
| Truthfulness after final P1 decisions | 20 | The prerequisite cannot cite obsolete path, cleanup, file-count, or governance behavior. |
| Cold-start clarity | 17 | A downstream author must know which P1 capabilities P2 consumes. |
| Resistance to duplicated-contract drift | 10 | P1 should remain the sole detailed source for its implementation. |
| Editing churn | 6 | A compact prerequisite is preferable after the other qualities are met. |

#### Scoring

| Option | Order 24 | Narrowness 23 | Truth 20 | Clarity 17 | Drift 10 | Churn 6 | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Copy P1 | 4 | 2 | 5 | 4 | 1 | 2 | 66.4 |
| B — Link only | 3 | 5 | 2 | 2 | 5 | 5 | 68.2 |
| C — Invariants + link | 5 | 5 | 5 | 5 | 5 | 4 | **98.8** |
| D — Independent P2 | 2 | 1 | 3 | 3 | 1 | 1 | 39.6 |
| E — Merge into P1 | 3 | 1 | 4 | 2 | 3 | 2 | 50.2 |

#### Selected disposition

Select **Option C**.

Rewrite P2's prerequisite so a cold reader learns:

- P1 must already be merged and P2 must be based on that result.
- The generator uses the deterministic UTF-8-no-BOM/LF writer at all four
  output sites.
- The tracked shared helper and permanent harness own artifact validation and
  extraction.
- The final workflow runs for all relevant events, uses the pinned Node 24
  actions, immutable artifact ID/digest flow, unique job-owned temporary roots,
  full-component checks, held-stream `FileShare.Read` contract, and fail-closed
  cleanup.
- The pull-request topology runs the harness only in the two LF cells, while
  every four-cell push consumer runs it.
- P1's controlled `has_changes=true` drill, not P2's expected no-drift merge,
  proves writer integration.
- P1's `.github/dependabot.yml` is established but is not modified by P2.
- P3 owns npm advisory remediation and follows P2, so it is not a P2
  prerequisite.

Link P1 rather than repeating its algorithms, fixture matrix, or workflow
implementation. Keep P2 at exactly two edited source files plus four generated
artifacts. Preserve all C-09 evidence distinctions and the conditional metadata
date rule.

### I-P1-01 — Prove the Node 24 toolchain and lint paths locally

#### Problem and perspectives

P1 changes the Markdown workflow to Node 24 and expects clean install plus
outer/nested lint success, but its local validation can pass on the reviewer's
ambient Node. The current review machine is Node 26.5.0, demonstrating why that
is not equivalent evidence.

- A DevOps engineer needs local and CI runtime assumptions aligned.
- A new developer needs an immediate, actionable failure if the wrong Node is
  active.
- A dependency maintainer needs lockfile installation, not only a linter left
  in `node_modules` from earlier work.
- A reviewer needs every command's exit status enforced.
- A project manager wants the check added without starting the P3 package
  migration early.

#### Options

**Option A — Rely entirely on pull-request CI.**

The pinned setup action provisions Node 24 and provides authoritative hosted
evidence. This is valid eventually but delays failures until after a push and
leaves P1's “local validation” incomplete.

**Option B — Check only that the local Node major is 24.**

Fail fast on the runtime, but do not reinstall dependencies or execute lint.
This proves environment selection, not package compatibility or scripts.

**Option C — Run lint under whatever local Node is active.**

Record the version and accept any passing supported runtime. This is convenient
but does not prove the exact Node 24 contract and can mask runtime-specific
behavior.

**Option D — Use CI Node 24 only, but add explicit workflow assertions.**

Have the workflow print/assert major 24 before `npm ci` and lint. This is strong
hosted evidence and should be retained, but it does not satisfy local
preflight.

**Option E — Require local Node major 24, clean install, and both lint paths.**

Add one fail-fast PowerShell block that checks Node/npm availability, requires
major 24, runs CI-mode `npm ci` from the workflows package, then runs outer and
nested lint with explicit exit checks.

**Option F — Run local validation in an official Node 24 container.**

Use a pinned Node image to make the runtime reproducible. This is strong when
Docker is present, but adds an unavailable prerequisite for many Windows
contributors and differs from the host filesystem/shell paths used by CI.

**Option G — Add `.nvmrc`, `.node-version`, or `engines.node` as enforcement.**

Version metadata improves developer discovery and could be combined with
Option E. None is uniformly enforced by the existing Windows/PowerShell/npm
flow, and adding package metadata overlaps P3's deliberately separate package
review.

#### Evaluation rubric

This rubric is specific to local runtime/toolchain evidence.

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Fidelity to the declared Node 24 environment | 26 | Passing on Node 26 or another version is not proof of P1's selected runtime. |
| Dependency and lint regression detection | 22 | A clean lockfile install and both lint modes are the behaviors at risk. |
| Reproducibility for another contributor | 18 | A cold-start developer should be able to repeat the evidence. |
| Fail-fast exit-code discipline | 14 | Tool startup and lint failures must not be mistaken for success. |
| Contributor usability and diagnostics | 12 | Wrong/missing runtimes should produce an actionable message. |
| Files/scope churn | 8 | Avoid package/version-file changes unless they materially improve proof. |

#### Scoring

| Option | Node fidelity 26 | Regression 22 | Reproducible 18 | Exit discipline 14 | Usability 12 | Churn 8 | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — CI only | 2 | 3 | 2 | 4 | 3 | 5 | 57.2 |
| B — Version check only | 4 | 2 | 3 | 5 | 4 | 5 | 72.0 |
| C — Ambient Node lint | 1 | 2 | 1 | 4 | 5 | 5 | 48.8 |
| D — Hosted assertion only | 3 | 4 | 4 | 5 | 3 | 5 | 76.8 |
| E — Node 24 + clean full lint | 5 | 5 | 5 | 5 | 4 | 4 | **96.0** |
| F — Node 24 container | 5 | 5 | 5 | 5 | 3 | 2 | 90.4 |
| G — Version metadata | 5 | 3 | 4 | 3 | 5 | 2 | 74.0 |

#### Selected disposition

Select **Option E**, while retaining Option D's hosted assertion.

Add a P1 local-validation PowerShell block that:

1. resolves `node` and `npm` or fails with installation guidance;
2. parses `process.versions.node` and requires major version exactly 24;
3. temporarily sets `CI=true` for the clean install so the repository's Husky
   installer follows its intentional CI skip path, then restores the caller's
   environment;
4. runs `npm --prefix .github/workflows ci`;
5. runs `npm --prefix .github/workflows run lint:md`;
6. runs `npm --prefix .github/workflows run lint:md:nested`; and
7. checks `$LASTEXITCODE` immediately after every native command.

Do not run `npm install`, update the manifest/lockfile, or use the review
machine's Node 26 pass as acceptance evidence. In both `build.yml` and
`markdownlint.yml`, assert the provisioned `process.versions.node` major is 24
before the install/lint steps. Record the local and hosted version output in
the evidence. P3, not P1, owns later package-version changes.

### I-P1-02 — Complete optional diagnostic-label fixture coverage

#### Problem and perspectives

P1 defines three independent optional labels—`ArtifactId`, `RunId`, and
`RunAttempt`—with a three-state contract: omitted, supplied nonempty, or
explicitly supplied empty. Its table has one generic empty-label case and no
complete oracle for omitted versus supplied labels.

- An API designer needs PowerShell binding state distinguished with
  `$PSBoundParameters`, not guessed from the resulting string value.
- An operator needs exact caller IDs retained in failure logs and omitted IDs
  labeled honestly as unavailable.
- A test maintainer needs to identify which parameter regressed.
- A security reviewer needs empty/untrusted context rejected before filesystem
  or archive processing.
- A project manager wants small data-driven cases rather than a new helper API.

#### Options

**Option A — Keep one generic `X-01`.**

Let the implementation choose which label to empty. This proves one validation
path but can leave two parameters unchecked.

**Option B — Loop over all three names inside one stable case.**

Keep `X-01` and make it a data-driven subloop that empties each label. This is
compact, but one aggregate result can make diagnostics and partial failure less
obvious.

**Option C — Add separate stable cases for omitted, supplied, and each empty
label.**

Use one digest rejection with all exact labels supplied, one with all omitted,
and three early rejections—one per explicitly empty label. Give each an exact
diagnostic oracle and phase.

**Option D — Make all labels mandatory.**

Require every caller to provide all three. This removes omitted-state
complexity but makes local/unit callers invent GitHub context, contrary to the
caller-owned/no-invention design.

**Option E — Replace the three parameters with a context object or hashtable.**

Centralize label validation and allow schema evolution. This substantially
changes the public helper interface, complicates strict binding and cross-
process invocation, and still needs field-by-field tests.

**Option F — Remove diagnostic labels.**

Log only the archive path and digest. This simplifies the helper but makes
matrix/run failures harder to correlate and abandons an intentional operational
feature.

#### Evaluation rubric

This rubric is specific to optional PowerShell parameter-state behavior.

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Complete omitted/supplied/empty state coverage | 26 | All three parameters and all meaningful binding states must be proven. |
| Phase and diagnostic-oracle specificity | 22 | Each failure must name the exact parameter and occur before side effects. |
| Regression localization | 18 | A case ID should immediately identify which label contract broke. |
| PowerShell 5.1/7 binding fidelity | 14 | Tests must exercise the real public script parameters in each edition. |
| Harness maintainability | 12 | Coverage should remain understandable and data-driven where safe. |
| Case-count and issue churn | 8 | Extra rows are acceptable but should earn their maintenance cost. |

#### Scoring

| Option | State coverage 26 | Oracle 22 | Localization 18 | Binding 14 | Maintainability 12 | Churn 8 | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Generic case | 2 | 2 | 2 | 4 | 5 | 5 | 57.6 |
| B — One looped case | 4 | 3 | 3 | 5 | 5 | 4 | 77.2 |
| C — Separate stable cases | 5 | 5 | 5 | 5 | 4 | 3 | **94.4** |
| D — Make labels mandatory | 4 | 5 | 4 | 5 | 3 | 2 | 81.6 |
| E — Context object | 4 | 3 | 3 | 2 | 2 | 1 | 56.8 |
| F — Remove labels | 1 | 1 | 1 | 5 | 5 | 5 | 47.2 |

#### Selected disposition

Select **Option C**.

Keep the existing public parameter list. The helper must use
`$PSBoundParameters.ContainsKey(...)` independently for `ArtifactId`, `RunId`,
and `RunAttempt`:

- omitted means diagnostics render the literal unavailable marker chosen by the
  issue;
- supplied nonempty means diagnostics preserve the exact caller value; and
- explicitly supplied `''` is rejected in `context/path` before archive
  enumeration/open or candidate creation.

Replace the underspecified table coverage with:

| ID | Label setup | Expected oracle |
| --- | --- | --- |
| `D-01` | Wrong well-formed digest; all three labels supplied with distinct sentinel values | `digest` rejection contains every exact sentinel |
| `D-02` | Wrong well-formed digest; all three labels omitted | `digest` rejection renders each as unavailable and invents none |
| `X-01` | Empty `ArtifactId`; other labels valid/omitted as specified | Early rejection names only `ArtifactId` |
| `X-02` | Empty `RunId`; other labels valid/omitted as specified | Early rejection names only `RunId` |
| `X-03` | Empty `RunAttempt`; other labels valid/omitted as specified | Early rejection names only `RunAttempt` |

All five cases must invoke the tracked production helper through its public
parameters in every supported shell/platform. The empty cases must prove no
download enumeration, stream open, ZIP construction, or candidate creation.
The digest cases must prove the expected/actual digest and archive path remain
present alongside the exact label rendering.

### I-P2-01 — Prove the rationale heading occurs exactly once

#### Problem and perspectives

P2 says to extend the existing `### Blank Line Usage` rationale section and
forbids creating a duplicate, but its content validator does not count that
heading.

- A documentation editor needs the change placed in the existing section.
- A Markdown maintainer knows duplicate-heading lint rules can be configured by
  sibling scope and are not a substitute for this issue-specific invariant.
- A test author needs an ordinal, culture-independent assertion.
- A new developer needs an error that reports the actual count and file.
- A project manager wants a tiny check that does not broaden P2.

#### Options

**Option A — Trust editing instructions and review.**

Do not add a mechanical check. Human review can catch a duplicate, but the
acceptance criterion remains unproven.

**Option B — Rely on Markdown lint duplicate-heading rules.**

Use MD024/related rules as indirect proof. Configuration can permit the same
heading under different parents, and future rule changes can weaken the oracle.

**Option C — Count exact heading lines ordinally and require one.**

Split the rationale using P2's existing ordinal newline method and count lines
exactly equal to `### Blank Line Usage`. Fail unless the count is one and report
the actual count.

**Option D — Parse a Markdown abstract syntax tree.**

Load the document through a parser and count level-three headings whose text
matches. This is semantically rich but adds a parser/API dependency to a simple
content check and can itself be affected by P3's dependency changes.

**Option E — Infer uniqueness from generated-artifact equality.**

Regenerate and assert the four artifacts match expected sources. Generation
faithfully reproduces a duplicate and therefore does not detect the defect.

**Option F — Use a regular expression over the whole file.**

Count multiline matches allowing optional whitespace. This can accidentally
accept malformed or indented headings and is less exact than the issue's
literal heading requirement.

#### Evaluation rubric

This rubric is specific to one structural Markdown invariant.

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Ability to detect zero or duplicate sections | 25 | Both omission and duplication violate the requested change. |
| Fidelity to the exact issue requirement | 22 | The target is one literal level-three heading, not approximate prose. |
| Resistance to false positives/negatives | 18 | Fenced text, indentation, or sibling configuration must not satisfy the check accidentally. |
| PowerShell edition portability | 15 | P2 validation must parse/run under Windows PowerShell 5.1 and PowerShell 7. |
| Failure-message clarity | 12 | The author should see file, expected count, and actual count immediately. |
| Implementation complexity | 8 | A one-line structural invariant should not require a new dependency. |

#### Scoring

| Option | Detect 25 | Fidelity 22 | Precision 18 | Portability 15 | Diagnostics 12 | Simplicity 8 | Total / 100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Human review | 1 | 2 | 3 | 5 | 2 | 5 | 52.4 |
| B — Markdown lint | 2 | 3 | 3 | 5 | 3 | 5 | 64.2 |
| C — Exact ordinal line count | 5 | 5 | 5 | 5 | 5 | 5 | **100.0** |
| D — Markdown AST | 5 | 5 | 5 | 3 | 4 | 1 | 85.2 |
| E — Generated equality | 1 | 2 | 3 | 5 | 2 | 4 | 50.8 |
| F — Multiline regex | 4 | 3 | 3 | 5 | 4 | 5 | 76.6 |

#### Selected disposition

Select **Option C**.

In P2's mechanical content-confirmation script, reuse the already normalized
ordinal line collection for `STYLE_GUIDE_RATIONALE.md`, then:

1. count lines exactly equal to `### Blank Line Usage` using
   `[StringComparison]::Ordinal`;
2. require the count to equal one;
3. throw a message containing the repository-relative file, expected count
   `1`, and actual count; and
4. run the same assertion after regeneration/staging in the final content
   confirmation.

Do not add a parser, change Markdown lint configuration, or weaken the equality
with whitespace/case normalization. Keep P2's existing checks that the
operational snippet/heading do not leak into the rationale.

## Consolidated selected issue slate

The evaluated findings produce three implementation issues in this execution
order:

| Order | Issue | Purpose | Prerequisite |
| ---: | --- | --- | --- |
| 1 | [P1 — Make artifact generation byte-deterministic across PowerShell editions and hosts](../PSStyleGuide/01PSStyleGuideP1.md) | Implement the deterministic generator/helper, complete its security and lifecycle contract, integrate it with the pinned workflows, add controlled transport evidence, and establish review-only GitHub Actions update governance. | None |
| 2 | [P2 — Make the non-compliant blank-line example visibly distinct](../PSStyleGuide/02PSStyleGuideP2.md) | Make the narrow source/content change after the P1 baseline, preserving exact generation and adding the ordinal uniqueness oracle. | P1 |
| 3 | [P3 — Remediate Markdown lint dependency advisories and add npm update governance](../PSStyleGuide/03PSStyleGuideP3.md) | Re-audit and deliberately remediate the Markdown tooling dependency graph, preserve the lint contract, and extend review-only governance to the nested npm project. | P2 |

The issue split keeps implementation ownership explicit:

- P1 owns `C-01` through `C-07`, `I-P1-01`, and `I-P1-02`.
- P2 owns `C-P2` and `I-P2-01`.
- P3 owns `C-08`.
- `C-09` remains a cross-issue preservation constraint: CI results are
  execution evidence, while static checks are source/configuration evidence.

All twelve open findings have a selected disposition incorporated into the
ordered slate. The research record is sufficient to retain the time-sensitive
action pins, runtime support status, API semantics, and audit baseline without
requiring the implementer to repeat this planning pass.
