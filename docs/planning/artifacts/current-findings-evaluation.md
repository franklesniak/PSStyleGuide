# PSStyleGuide open-finding evaluations

## Evaluation status

This file evaluates every open PSStyleGuide finding in
`docs/planning/artifacts/current-findings.md`, one finding at a time. Each
finding receives its own options, purpose-built weighted rubric, scoring table,
and implementation-ready selection before evaluation proceeds to the next
finding.

Complete: 31 consolidated open findings evaluated and selected; all five issue
drafts integrated in execution order; final cross-slate validation passed.

## Open-finding inventory

Repeated cross-slate observations are mapped to the same underlying finding
rather than scored twice. “Satisfied” observations in `current-findings.md`
(the H1/P labels, shared validator and path-verifier reuse, generated-artifact
derivation, and the current issue split/order) require preservation checks
during the final slate audit but are not open findings.

| ID | Open finding | Source occurrences consolidated |
| --- | --- | --- |
| `F01` | Separate issue creation, dependency verification, reviewed head, landed commit, rerun, and implementation-readiness identities | Slate sequencing; P1B recommendation 6; cross-slate 2–3; independent filing/readiness finding |
| `F02` | Remove P2's impossible filing-time URL to future P3 | P2 recommendation 1; cross-slate real-URL rule |
| `F03` | Eliminate or justify P1's temporary remote writer | Cross-slate recommendation 10; independent temporary-writer finding; initial complexity observation |
| `F04` | Close generator source/destination authority at a fixed repository root | P1 recommendation 1; independent ambient-current-directory finding |
| `F05` | Replace the truncating generator write contract without claiming unsupported `File.Replace` failure guarantees | P1 recommendation 1 |
| `F06` | Publish P1's first generator version explicitly | P1 recommendation 2 |
| `F07` | Select the exact YAML parser and lockfile-producing toolchain with freeze/re-resolution rules | P1 recommendation 3; cross-slate recommendation 7 |
| `F08` | Close P1's authored action inputs and intentionally reviewed defaults | P1 recommendation 4; cross-slate recommendation 6 |
| `F09` | Expand the P1↔T1 reciprocal matrix for every new shared foundation | P1 recommendation 5 |
| `F10` | Define ownership and offline availability of workflow fixtures and action-manifest evidence | Independent fixture/manifest-evidence finding |
| `F11` | Validate P1A public values as raw objects before PowerShell coercion and use reachable fixtures | P1A recommendation 1 |
| `F12` | Publish closed P1A context and cleanup-journal schemas | P1A recommendation 2 |
| `F13` | Complete P1A lifecycle/repeated-disposal semantics without inventing unreachable states | P1A recommendation 3 |
| `F14` | Publish explicit initial versions for all P1A scripts | P1A recommendation 4 |
| `F15` | Namespace local case IDs and add cross-repository semantic keys | P1A recommendation 5; cross-slate recommendation 8 |
| `F16` | Publish a closed P1A result-record schema | P1A recommendation 6 |
| `F17` | Add P1B's complete job/direct-needs/permission/data-flow contract | P1B recommendation 1 |
| `F18` | Resolve P1B action-input, archive, and retention differences explicitly | P1B recommendation 2; cross-slate recommendations 6–7 |
| `F19` | Correct P1B diagnostic predicates to exclude cancellation | P1B recommendation 3 |
| `F20` | Correct P1B credential terminology and token-materialization timing | P1B recommendation 4 |
| `F21` | Exercise the real P1B writer graph on isolated evidence state | P1B recommendation 5; cross-slate recommendation 10 |
| `F22` | Freeze exact npm/Corepack identity, integrity, Node floors, and lock producer | P3 recommendation 1; cross-slate recommendation 7 |
| `F23` | Make the production Node-policy CLI observe its own runtime and compiled policy | P3 recommendation 2 |
| `F24` | Include and harden the real `install-husky.mjs` prepare installer | P3 recommendation 3 |
| `F25` | Validate bounded raw audit bytes and native process outcome before object policy | P3 recommendation 4 |
| `F26` | Add raw/schema/process audit fixtures | P3 recommendation 5 |
| `F27` | Bind residual audit exceptions to retained live issue evidence | P3 recommendation 6 |
| `F28` | Prevent caller-spoofed production time while retaining pure-core clock injection | Independent production-time finding |
| `F29` | Establish one authoritative Node-policy case catalog | Independent Node-policy-manifest finding |
| `F30` | Close ambient npm and Corepack configuration | Independent npm/Corepack-configuration finding |
| `F31` | Reduce avoidable cross-slate contract duplication without sacrificing standalone executability | Initial issue-length/maintenance observation |

## F01 — Issue identity and lifecycle protocol

### Options

The design must distinguish facts available when an issue is drafted, created,
started, reviewed, and merged. It must also survive merge-commit, squash, and
rebase workflows.

1. **Keep “final merge commit” as the only identity.** Each successor records
   only one predecessor SHA at implementation start. This is compact but loses
   the reviewed head, merge method, and whether evidence applies to the landed
   tree.
2. **Treat the reviewed PR head as canonical.** Require fast-forward or merge
   commits that retain the head and reject squash/rebase. This makes evidence
   attribution simple but imposes repository-history policy that is outside the
   issues' purpose and still needs a landed-base identity.
3. **Record reviewed head and landed commit without lifecycle phases.** Add both
   values to every dependency/handoff paragraph. This fixes identity ambiguity
   but leaves impossible “before filing” verification and unclear rerun rules.
4. **Use a phased, closed evidence handoff in every issue.** Define:

   - a draft phase containing titles and predecessor references but no invented
     successor URL;
   - creation with `gh issue create --blocked-by` when available, or
     create-then-add as an explicit fallback;
   - post-create retrieval of canonical URL/number and exact `blockedBy`;
   - implementation readiness only after every predecessor is merged and its
     handoff bundle is verified;
   - a completion bundle containing predecessor/successor URLs, reviewed PR
     head SHA, base SHA reviewed against, merge method, landed base commit or
     exact landed commit set, tree identity, and evidence-run identities; and
   - a mandatory landed-state rerun when the landed tree was not the exact tree
     covered by final review evidence.

   Later issue bodies are backpatched with real URLs after creation and with
   predecessor landed data before their implementation, without representing
   those edits as implementation work.
5. **Create a tracked machine-readable slate ledger.** Store all issue IDs,
   dependency edges, PR heads, merge methods, landed identities, and evidence
   runs in a JSON file validated by CI. Issue bodies point to the ledger. This
   is highly auditable but adds a permanent artifact and workflow outside the
   stated product changes.
6. **Store the handoff only in GitHub issue comments or labels.** Avoid body
   backpatches and repository files; post a completion comment with all
   identities. This reduces body churn but makes the normative contract less
   visible, structured verification harder, and offline handoff incomplete.

Useful permutations are option 4 with either atomic creation or the documented
two-step fallback, and option 4 with an optional structured attachment in
retained evidence. The attachment must not become a new repository product
file unless separately authorized.

### Evaluation rubric

Score each option from 0 (fails) to 5 (fully satisfies) for each criterion.
The weighted score is `Σ(score / 5 × weight)`, with a maximum of 100.

| Criterion | Weight | What earns full credit |
| --- | ---: | --- |
| Evidence identity correctness | 30 | Unambiguously binds review, merge, landed tree, and test evidence without treating unlike SHAs as interchangeable |
| Temporal/lifecycle correctness | 20 | Requires each fact only after it can exist and defines creation, verification, readiness, and completion gates |
| Merge-method compatibility | 15 | Works honestly for merge commits, squash, rebase, and fast-forward outcomes |
| Cold-reader usability | 15 | A new implementer can tell exactly which identities to obtain, when, and what mismatch requires |
| Auditability and automation | 10 | Uses canonical retrievable fields and leaves a deterministic handoff that can be independently checked |
| Provenance/security assurance | 7 | Prevents stale or substituted evidence from authorizing later work |
| Scope and maintenance cost | 3 | Avoids unnecessary permanent infrastructure and repetitive upkeep |

The identity, timing, and usability criteria dominate because a low-churn
protocol that attributes evidence to the wrong tree is actively misleading.
Project-management simplicity and document churn are represented, but cannot
compensate for a provenance defect.

### Scoring

| Option | Identity (30) | Timing (20) | Merge methods (15) | Usability (15) | Auditability (10) | Provenance (7) | Scope (3) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Landed commit only | 1 | 1 | 2 | 2 | 2 | 1 | 5 | 30.4 |
| 2. Reviewed head canonical | 3 | 3 | 0 | 2 | 3 | 4 | 2 | 48.8 |
| 3. Two identities, no phases | 4 | 2 | 5 | 3 | 3 | 4 | 4 | 70.0 |
| 4. Phased closed handoff | 5 | 5 | 5 | 5 | 5 | 5 | 4 | **99.4** |
| 5. Tracked slate ledger | 5 | 5 | 5 | 4 | 5 | 5 | 1 | 94.6 |
| 6. Comments/labels only | 3 | 4 | 5 | 3 | 2 | 3 | 5 | 69.2 |

Option 5 is technically strong, but its permanent ledger and validation system
do not improve identity correctness enough to justify expanding all five
implementation scopes.

### Selected resolution

Select **option 4: one phased, closed evidence handoff**, with atomic
create-with-dependency preferred and a verified two-step fallback.

Apply the following exact protocol:

1. Draft all five bodies with issue titles and order only. Never invent an
   issue number, URL, dependency result, PR, run, or SHA.
2. Create P1. Create each successor with its already-created immediate
   predecessor passed to `gh issue create --blocked-by`. If the installed
   GitHub CLI cannot do that, create the successor, immediately add the
   dependency through the supported CLI/API, and treat the two calls as an
   incomplete transaction until verification succeeds.
3. After each creation, retrieve the canonical URL/number and `blockedBy`
   relationship. Backpatch real URLs into the relevant issue bodies. A failed
   lookup, missing edge, unexpected extra dependency, or mismatched repository
   blocks implementation readiness.
4. Do not require predecessor merge facts at filing time. At successor
   implementation start, require the predecessor's closed handoff bundle:
   issue URL, PR URL, reviewed head SHA, base SHA used for final review, merge
   method, landed base commit or exact landed commit set, landed tree SHA, and
   retained validation/evidence-run URLs.
5. Verify that the landed identity is reachable from the intended target branch
   and that its tree contains the accepted predecessor changes. If the final
   reviewed tree and landed tree differ, rerun all predecessor acceptance gates
   against the landed state and retain those run identities before starting the
   successor.
6. At each issue's completion, produce the same bundle for its successor.
   P3 retains the final bundle even though no later issue consumes it.

Revise every dependency and handoff section to use the same lifecycle terms:
**filed**, **dependency-verified**, **implementation-ready**, **reviewed**, and
**landed-and-rerun**. Do not call a reviewed head a merge commit, and do not say
that a future identity was “recorded” before it existed.

## F02 — P2's forward reference to future P3

### Options

1. **Keep the title-only reference permanently.** P2 states that the named P3
   follows and owns dependency remediation, but never requires a forward URL.
   P3 contains the canonical backward URL and dependency edge to P2.
2. **Backpatch P2 after P3 is filed.** File P2 with a clearly noncanonical
   title reference; create P3 blocked by P2; verify P3; then edit P2 to add
   P3's canonical URL. This provides bidirectional navigation at the cost of a
   post-filing body mutation.
3. **Omit every P3 reference from P2.** Leave package scope only as a P2
   non-goal. This avoids future identity entirely but makes ownership of the
   known dependency work less obvious.
4. **File P3 before P2.** Obtain P3's URL first, then file P2 with the real
   link. This violates the required issue order and makes the dependency
   direction awkward.
5. **Use a placeholder URL or predicted issue number.** Replace it after P3
   exists. This is forbidden because numbers are not safely predictable and a
   placeholder can be mistaken for canonical evidence.
6. **Use a repository planning-document anchor instead of an issue URL.** Point
   P2 to the P3 draft path. It is stable before filing, but a local planning
   path is not the canonical work item handed to an implementer.

Option 2 can be combined with option 1 by treating the title as the normative
ownership statement and the later URL as navigational metadata only. The
backpatch must never become a readiness prerequisite for P2 because P3
necessarily follows it.

### Evaluation rubric

Use a 0–5 score and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Temporal truthfulness | 30 | Never claims or requires a P3 identity before P3 exists |
| Sequential integrity | 20 | Preserves P1→P1A→P1B→P2→P3 filing and implementation order |
| Ownership clarity | 20 | Makes it unmistakable that P3, not P2, owns npm remediation |
| Work-item navigation | 10 | Lets a cold reader reach the canonical related work with minimal effort |
| Operational simplicity | 10 | Avoids fragile multi-edit filing choreography |
| Stale/misdirected-link resistance | 7 | Cannot silently point to the wrong issue |
| Documentation churn | 3 | Minimizes low-value body edits |

Temporal correctness and ownership dominate. Bidirectional convenience is
useful but cannot justify a false filing-time requirement or a dependency-order
change.

### Scoring

| Option | Temporal (30) | Sequence (20) | Ownership (20) | Navigation (10) | Simplicity (10) | Link safety (7) | Churn (3) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Permanent title reference | 5 | 5 | 5 | 3 | 5 | 5 | 5 | **96.0** |
| 2. Verified post-filing backpatch | 5 | 5 | 5 | 5 | 3 | 4 | 3 | 93.4 |
| 3. Omit P3 entirely | 5 | 5 | 2 | 1 | 5 | 5 | 5 | 80.0 |
| 4. File P3 first | 5 | 0 | 4 | 5 | 2 | 5 | 1 | 67.6 |
| 5. Placeholder/predicted URL | 0 | 3 | 3 | 4 | 3 | 0 | 2 | 39.2 |
| 6. Planning-file link | 5 | 5 | 4 | 3 | 4 | 4 | 4 | 88.0 |

The permanent title reference wins because P3's own canonical backward edge
already supplies the authoritative relationship; P2 does not need a future URL
to define its scope.

### Selected resolution

Select **option 1: retain a permanent title-only forward reference**.

In P2:

1. Keep the bold P3 H1 text so ownership is obvious.
2. State that the text is descriptive, not a canonical link or prerequisite.
3. Remove the instruction to replace it with P3's URL.
4. Keep P3-owned package files and dependency remediation explicitly outside
   P2.

In P3, after filing:

1. Record P2's real canonical URL.
2. Create and verify P3's real `blockedBy` relation to P2 under F01.
3. Do not require a reciprocal P3 link in P2 for either issue to be ready.

This gives P2 a truthful body at every lifecycle stage while preserving
downstream discoverability through P3's canonical backward relationship.

## F03 — P1's temporary remote writer

### Options

1. **Keep and harden the temporary writer.** Preserve the current
   write-enabled push-to-main job, exact-lease implementation, token-state
   checks, temporary evidence workflow/ref, cleanup proofs, and P1B
   supersession. This proves remote synchronization early but implements and
   reviews a security-sensitive writer that is immediately discarded.
2. **Make P1 entirely read-only.** P1 changes generator serialization,
   deterministic checks, workflow policy, and path verification, but every
   workflow only reports drift. P1 acceptance requires all current sources and
   generated artifacts to remain byte-identical. P1A remains read-only. P1B
   introduces the only remote writer. P2 later commits its two source changes
   and four regenerated artifacts in the same reviewed change.
3. **Move P1B's final candidate/promote writer into P1.** Avoid an interim
   writer by implementing the final graph immediately, then let P1A harden the
   archive validator afterward. This reverses the trust dependency: the writer
   would rely on validation that does not yet exist.
4. **Use a manual maintainer synchronization step between P1 and P1B.** Keep CI
   read-only, document a local generate-and-commit procedure for emergency
   source changes, and require human review. This avoids workflow write tokens
   but creates an unnecessary side path before the final writer.
5. **Freeze guide-source changes until P1B.** Make P1/P1A read-only as in
   option 2 and explicitly prohibit changes to either authoritative source or
   any derived artifact until P1B lands. This is stronger operationally, but
   could block unrelated urgent documentation corrections.
6. **Collapse P1, P1A, and P1B into one issue.** Implement deterministic
   generation, adversarial archive validation, and final publication
   atomically. This removes all interim states but creates an extremely large,
   difficult-to-review security change and violates the approved issue split.

Option 2 and option 5 can be combined as “read-only drift enforcement plus an
exceptional, separately reviewed six-file manual change if an urgent source
repair cannot wait.” The exception must not create a second writer contract.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Least-privilege exposure | 25 | Adds no write authority before the final reviewed writer needs it |
| Source/artifact correctness | 20 | Detects drift and ensures reviewed source and derived bytes remain synchronized |
| Dependency-boundary integrity | 18 | Preserves the reason P1A validation precedes P1B promotion |
| Implementation reliability | 15 | Has few transient mechanisms and no throwaway security-critical path |
| Contributor usability | 10 | Gives clear behavior for ordinary and exceptional changes |
| Evidence proportionality | 7 | Requires evidence commensurate with enduring risk, not deleted machinery |
| Change/scope cost | 5 | Minimizes code and issue churn without weakening stronger criteria |

Security exposure and dependency integrity outweigh the convenience of early
automatic publication. A temporary mechanism receives no credit merely because
it is carefully specified; it must create enduring value.

### Scoring

| Option | Privilege (25) | Correctness (20) | Boundary (18) | Reliability (15) | Usability (10) | Evidence (7) | Scope (5) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Harden temporary writer | 2 | 5 | 5 | 2 | 4 | 1 | 1 | 64.4 |
| 2. P1 read-only | 5 | 5 | 5 | 5 | 4 | 5 | 5 | **98.0** |
| 3. Move final writer into P1 | 3 | 5 | 0 | 3 | 4 | 2 | 2 | 56.8 |
| 4. Manual interim synchronization | 5 | 4 | 5 | 3 | 3 | 4 | 3 | 82.6 |
| 5. Freeze source changes | 5 | 5 | 5 | 4 | 2 | 5 | 5 | 91.0 |
| 6. Collapse P1/P1A/P1B | 4 | 5 | 0 | 2 | 1 | 3 | 0 | 52.2 |

Read-only P1 has the highest assurance and removes an entire credential,
lease, evidence-ref, and cleanup surface. A hard freeze is less usable and is
unnecessary because drift failure already prevents an inconsistent merge.

### Selected resolution

Select **option 2: make P1 entirely read-only**.

Revise P1 as follows:

1. Remove `synchronize_generated_artifacts_temporary`, its `contents: write`,
   exact-lease/token algorithm, action role, temporary evidence workflow/ref,
   push drills, cleanup proof, and every handoff/acceptance reference to them.
2. Give the workflow and every P1 job `permissions: {}` unless a job's actions
   require a documented read grant. Checkout uses the event SHA and
   `persist-credentials: false`.
3. Make the generator matrix regenerate only inside disposable job-owned
   working copies. Compare all four candidate files byte-for-byte with the
   checked-out artifacts and fail on drift; never modify or push the checkout.
4. Require P1's production generator refactor to produce the exact current four
   artifact byte sequences from the exact current two sources on every required
   PowerShell/OS cell. Any byte change is a defect or an explicitly re-scoped
   source/artifact change.
5. State that ordinary source changes must include all four derived artifacts
   in the same reviewed commit. P2 is the first planned such change and occurs
   after P1B.
6. Revise P1B's summary and supersession text: it introduces the one and only
   remote writer; it does not replace temporary direct publication.

If an urgent source correction must precede P1B, handle it as a separate
reviewed source-plus-four-artifact change using the local deterministic
generator. Do not restore a temporary CI writer.

## F04 — Generator repository-root and path authority

### Options

1. **Retain ambient current-directory paths.** Continue opening
   `STYLE_GUIDE.md`, `STYLE_GUIDE_RATIONALE.md`, and four relative destinations
   from the process working directory. This is convenient but lets invocation
   location redirect authoritative reads and writes.
2. **Derive one fixed repository root from `$PSScriptRoot`.** The production
   script resides at `.github/workflows/Generate-StyleGuide.ps1`; resolve its
   parent hierarchy lexically to the repository root, reject an unexpected
   script location, and construct a closed six-path map for exactly two sources
   and four destinations. Validate each path component and ordinary-file
   identity before use. Tests operate on a disposable copied repository layout,
   not by injecting arbitrary production paths.
3. **Accept a mandatory `-RepositoryRoot` parameter.** Validate that it is
   rooted and contains the expected layout, then derive the six paths. This
   supports test fixtures and forks but leaves production authority in the
   caller.
4. **Ask Git for the top-level directory.** Run
   `git rev-parse --show-toplevel`, validate the result, and derive the closed
   map. This follows worktrees naturally but adds a native-command dependency
   and allows ambient Git discovery/configuration to influence file authority.
5. **Allow six caller-supplied rooted paths after containment checks.** This is
   flexible for tests and alternate layouts, but six values dramatically
   increase substitution, alias, and time-of-check/time-of-use surface.
6. **Add a tracked JSON artifact map.** Load exact source/destination paths from
   a schema-validated repository manifest anchored at `$PSScriptRoot`. This is
   explicit and extensible but adds a seventh authoritative input for a map
   that is intentionally closed and tiny.

The strongest practical permutation is option 2 plus a pure serialization core
that accepts already-read strings/bytes for unit fixtures. Filesystem tests
should copy the exact repository layout under a job-owned temporary root and
execute the script from its normal relative location.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Write-target confinement | 30 | Production can write only the four exact repository destinations |
| Source authenticity | 20 | Production reads only the two exact tracked authoritative source files |
| Link/alias/TOCTOU resistance | 15 | Rejects reparse/symlink or substituted path components and revalidates at use |
| Invocation determinism | 10 | Behavior does not depend on current directory or ambient repository discovery |
| Testability | 10 | Pure logic and filesystem behavior can be tested without weakening production authority |
| Cross-platform semantics | 8 | Has explicit Windows/Unix path behavior on required runtimes |
| Cold-user ergonomics | 5 | Normal execution needs no risky or confusing path arguments |
| Implementation churn | 2 | Adds only machinery justified by the authority boundary |

Write confinement receives the highest weight because this script overwrites
tracked files. Test convenience cannot authorize arbitrary production paths.

### Scoring

| Option | Writes (30) | Sources (20) | Alias/TOCTOU (15) | Determinism (10) | Testing (10) | Platforms (8) | Usability (5) | Churn (2) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Ambient current directory | 0 | 0 | 1 | 2 | 4 | 5 | 4 | 5 | 29.0 |
| 2. Fixed `$PSScriptRoot` map | 5 | 5 | 4 | 5 | 4 | 5 | 5 | 4 | **94.6** |
| 3. Caller repository root | 3 | 3 | 3 | 4 | 5 | 5 | 4 | 4 | 70.6 |
| 4. Git-discovered root | 4 | 4 | 3 | 3 | 3 | 4 | 4 | 3 | 72.6 |
| 5. Six caller paths | 2 | 2 | 2 | 3 | 5 | 5 | 2 | 3 | 53.2 |
| 6. Tracked artifact map | 5 | 5 | 4 | 5 | 5 | 5 | 3 | 2 | 93.8 |

The manifest is almost as safe, but adds mutable configuration without a
current extensibility need. A closed map in code is easier to audit and cannot
silently grow through data-only changes.

### Selected resolution

Select **option 2: a fixed `$PSScriptRoot`-anchored closed map**, paired with
pure in-memory serialization helpers.

P1 must require:

1. The main script verifies its own leaf name and expected
   `.github/workflows` parent relationship, derives the repository root without
   consulting the current directory or Git, and rejects an unexpected layout.
2. One case-sensitive ordinal artifact-ID map defines exactly:
   `styleGuideSource`, `rationaleSource`, `copilotOutput`,
   `powerShellInstructionsOutput`, `chatOutput`, and `fullOutput`.
3. The two source IDs map only to root `STYLE_GUIDE.md` and
   `STYLE_GUIDE_RATIONALE.md`; the four output IDs map only to the current four
   tracked destination files. No public production parameter accepts a root or
   path override.
4. Before reading or writing, validate every existing path component from the
   trusted root through the leaf as an ordinary expected entry, reject
   symlinks/reparse points and provider-qualified/non-FileSystem forms, and
   revalidate the parent and destination immediately before replacement.
5. The pure transformation functions accept content values, not paths. Unit
   tests call those functions directly. Filesystem/matrix tests create a
   disposable complete repository-layout copy and place the script at its
   normal relative path.
6. Invocation from the repository root, `.github/workflows`, or an unrelated
   current directory produces the same four bytes in the same fixed
   destinations.

The P1 affected-file list does not need a separate map file.

## F05 — Generator replacement and failure semantics

### Options

1. **Keep direct `File.WriteAllText`.** Encode the final bytes explicitly but
   truncate each existing destination in place. This is simple and
   deterministic on success, not recoverable on an interrupted write.
2. **Use `File.Replace(temp, destination, $null)` and promise old-or-new.**
   Prepare a same-directory file and replace without a backup. This matches the
   criticism's exact recipe, but Windows documents failed states that disprove
   the promised invariant.
3. **Use staged same-directory candidates, named backups, and an honest
   recovery state machine.** Compute all four byte arrays before mutation.
   Create each candidate exclusively, write/flush/close/reread/hash it, then
   replace each destination with a distinct same-directory backup. Keep all
   backups until the complete four-file set verifies. On failure, classify
   destination/candidate/backup by expected old/new hashes, attempt bounded
   reverse rollback only from proved old backups, and either restore the old
   set or retain every recovery artifact plus a machine-readable uncertain
   state. Never claim crash-proof four-file atomicity.
4. **Implement a manual rename journal.** Rename every old destination to a
   backup, rename every prepared candidate into place, persist a journal after
   each operation, and recover on the next run. This can cover all four files
   but recreates complex filesystem transaction logic and still has crash
   windows around journal durability.
5. **Generate into a separate output directory only.** Never overwrite tracked
   outputs; a human or later workflow reviews and copies candidates. This
   maximizes source safety but breaks the expected local generator experience
   and moves the dangerous final copy elsewhere.
6. **Write sibling `.new` files and stop.** The user manually renames them.
   This is a lightweight form of option 5, but pollutes the working tree and has
   no validated finalization or cleanup contract.
7. **Delegate finalization to Git.** Generate candidates, then use Git commands
   or patches to update the tracked paths. Git provides recovery for committed
   old content, but ambient Git state/configuration and uncommitted user changes
   make it an inappropriate file-write authority.

Option 3 can use an in-memory recovery journal for handled exceptions and an
exclusive on-disk journal for abrupt-process recovery. Because every
destination is tracked, the selected design should use a bounded same-directory
journal only if tests demonstrate that it improves crash recovery on all
required platforms; otherwise it must document abrupt termination as an
uncertain state and leave proved backups untouched.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Existing-byte preservation | 30 | A handled failure cannot silently destroy the only proved old bytes |
| Failure-contract truthfulness | 20 | Promises no stronger atomicity/durability than platform documentation supports |
| Cross-platform predictability | 15 | Defines tested Windows, Linux, and macOS outcomes on required PowerShell runtimes |
| Four-artifact consistency | 12 | Prepares the whole set first and verifies or recovers batch state |
| Authority/path safety | 8 | Uses only F04 destinations and exclusively created siblings on the same volume |
| Local developer usability | 8 | Normal successful generation still updates the four expected files directly |
| Evidence and diagnosability | 5 | Classifies old/new/uncertain state without leaking or deleting recovery data |
| Implementation cost | 2 | Avoids complexity that does not buy demonstrable preservation |

Preservation and honest failure semantics dominate. “Atomic” receives no credit
unless the exact platform contract and injected-failure evidence support it.

### Scoring

| Option | Preserve (30) | Honest (20) | Platforms (15) | Set consistency (12) | Authority (8) | Usability (8) | Diagnosis (5) | Cost (2) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Direct truncation | 1 | 2 | 5 | 1 | 4 | 5 | 1 | 5 | 48.8 |
| 2. Backup-free `File.Replace` promise | 2 | 0 | 2 | 3 | 5 | 5 | 1 | 4 | 43.8 |
| 3. Backed-up staged state machine | 5 | 5 | 4 | 5 | 5 | 5 | 5 | 3 | **96.2** |
| 4. Manual rename journal | 4 | 4 | 2 | 5 | 5 | 4 | 4 | 0 | 76.4 |
| 5. Separate output directory | 5 | 5 | 5 | 4 | 5 | 1 | 3 | 4 | 88.8 |
| 6. Sibling `.new` files | 5 | 5 | 5 | 2 | 5 | 1 | 2 | 5 | 83.4 |
| 7. Git finalization | 3 | 2 | 3 | 3 | 1 | 3 | 2 | 3 | 51.8 |

The selected state machine preserves normal local behavior and materially
improves recoverability without making the unsupported claim that four
filesystem names commit atomically across operating systems and crashes.

### Selected resolution

Select **option 3: staged candidates, distinct backups, verification, and
classified recovery**.

P1 must replace its one-call `WriteAllText` requirement with this closed batch
contract:

1. Compute the exact BOM-less UTF-8 byte arrays and SHA-256 values for all four
   outputs before creating or mutating any file.
2. Read and retain each destination's exact old bytes/hash. Missing,
   non-ordinary, aliased, or unexpected destinations fail before mutation.
3. In each destination directory, reserve unpredictable candidate and backup
   sibling names using exclusive create semantics. Reject pre-existing names;
   do not follow links.
4. Write each candidate through `FileStream`, call `Flush(true)`, close it,
   reread it, and require exact length/hash/bytes before the first replacement.
5. For each changed destination, call `File.Replace(candidate, destination,
   backup, false)`. An unchanged destination is a proved no-op. Keep every
   backup until all four final destinations reread as the expected new bytes.
6. On full success, delete only the exact owned backups/candidates and prove
   their absence. Cleanup failure is reported separately after the valid new
   destination set is proved.
7. On any replacement/verification failure, stop forward progress, inspect
   only the exact owned paths, classify each as `Old`, `New`, `Missing`,
   `Unexpected`, or `Unreadable` from precomputed hashes, and attempt reverse
   rollback only where the old backup is proved. Never delete an unclassified
   or sole proved old copy.
8. Return success only for a fully verified new set. If rollback proves the
   complete old set, throw a `RolledBack` failure. Otherwise throw
   `ReplacementStateUncertain`, retain recovery paths, and print bounded
   operator instructions and hashes.
9. Add injected failures for candidate open/write/flush/close/verify, each
   replacement position, final verification, rollback, and cleanup on every
   required platform. Abrupt process/host/storage failure is explicitly not
   represented as guaranteed atomic.

Link P1's References section to the Microsoft `WriteAllText`, `File.Replace`,
`FileStream.Flush(Boolean)`, and Windows `ReplaceFileW` sources retained in the
research artifact.

## F06 — P1 generator first-publication version

### Options

1. **Leave version implicit.** Rely on the style-guide link and let the
   implementer infer whether the unversioned script has a prior publication.
2. **Publish `1.0.<implementation-UTC-YYYYMMDD>.0`.** State explicitly that the
   current generator has no previously published `.NOTES` version, so P1 is its
   first publication under the repository's `[System.Version]` policy.
3. **Publish a literal date now.** Put `1.0.20260729.0` in the issue draft.
   This is precise today but wrong if implementation occurs later.
4. **Use `0.1.<date>.0` as a pre-stable version.** Signals that the generator is
   evolving, but conflicts with the repository's documented new-script
   convention and the P/T convergence target.
5. **Derive a version from Git or package metadata at runtime.** Avoid manual
   updates, but violates the required `.NOTES` source of truth and makes
   vendored/offline identity dependent on repository state.
6. **Copy whatever T1 publishes.** Guarantees numeric parity only if both issues
   implement on the same date and revision, which is neither required nor
   semantically meaningful.

The compatible permutation is option 2 with a finalization gate that rereads
the target branch immediately before merge and computes same-day revision only
if an actual previously published generator version has appeared meanwhile.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Policy conformance | 35 | Applies the repository's exact first-publication and `[System.Version]` rules |
| Temporal correctness | 20 | Uses the real UTC implementation date and target-branch baseline |
| Consumer identity clarity | 15 | Gives P1A/P1B an exact parseable generator identity |
| Vendoring/offline stability | 12 | Identity travels with the script and needs no Git/package service |
| Cross-repository semantics | 8 | Uses the same rule as T without requiring meaningless numeric equality |
| Implementer clarity | 7 | Removes all inference about prior publication and revision |
| Churn | 3 | Requires minimal ongoing mechanics |

Version-policy correctness outweighs aesthetic preference for a prerelease
number or exact PS/T numerical parity.

### Scoring

| Option | Policy (35) | Time (20) | Identity (15) | Offline (12) | PS/T rule (8) | Clarity (7) | Churn (3) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Implicit | 1 | 2 | 1 | 2 | 2 | 1 | 5 | 30.4 |
| 2. First `1.0.<date>.0` | 5 | 5 | 5 | 5 | 5 | 5 | 5 | **100.0** |
| 3. Literal draft date | 5 | 1 | 5 | 5 | 4 | 4 | 4 | 80.4 |
| 4. `0.1.<date>.0` | 2 | 5 | 4 | 5 | 2 | 3 | 5 | 68.4 |
| 5. Runtime-derived | 1 | 4 | 3 | 0 | 1 | 2 | 2 | 37.6 |
| 6. Copy T1 number | 2 | 1 | 4 | 5 | 1 | 2 | 3 | 48.2 |

The policy-derived first publication is uniquely both exact and future-proof.

### Selected resolution

Select **option 2: first publication at
`1.0.<UTC implementation YYYYMMDD>.0`**.

P1 must say:

- the baseline `Generate-StyleGuide.ps1` has no `.NOTES` version, so there is no
  previously published generator version to parse;
- P1 adds `Version: 1.0.<UTC implementation YYYYMMDD>.0`;
- the implementation date, not issue-draft or PR-open date, supplies `Build`;
- finalization rereads the target branch. If a version was independently
  published before landing, apply the normal major/minor/build/revision rules
  instead of overwriting it;
- the exact final version string and script SHA-256 enter P1's handoff bundle;
  and
- P1A/P1B consume that identity. T1 uses the same policy independently and may
  legitimately have a different build date or revision.

## F07 — YAML parser and lockfile-producing toolchain

### Options

1. **Keep a semver parser range and hosted `node-version: '24'`.** Let npm and
   setup-node choose exact versions. This is convenient but neither dependency
   parsing nor lockfile bytes are attributable to a reviewed toolchain.
2. **Pin only `yaml@2.9.0`.** Record its integrity but continue generating the
   lock with any Node 24/npm pair. Parser code is fixed; lockfile serialization
   and transitive resolution remain variable.
3. **Freeze today's exact parser, Node, and npm forever.** Use `yaml@2.9.0`,
   Node `24.18.1`, and npm `11.16.0` with no update gate. This is reproducible
   now but eventually leaves a security/runtime patch stale.
4. **Use an exact reviewed descriptor with two re-resolution/freeze gates.**
   Propose `yaml@2.9.0` plus registry integrity/tarball, exact Node `24.18.1`,
   and its bundled npm `11.16.0` as the sole P1 lock producer. Immediately
   before implementation and merge, re-query official records. If identity,
   provenance, integrity, compatibility, or the newest eligible Node-24
   security patch changes, stop, update the issue/evidence, regenerate from the
   reviewed manifest, and rerun the full clean-install/parser/workflow suite.
   Freeze the resulting exact tuple in the P1 handoff.
5. **Adopt P3's npm 12/Corepack policy in P1.** Use the eventual package-manager
   descriptor early so the lock is generated once. This improves convergence
   but silently pulls dependency-remediation/runtime-governance scope forward
   and may change more than the one YAML parser.
6. **Avoid a dependency by writing a workflow-YAML parser.** Removes npm
   provenance but creates a security-sensitive YAML implementation, including
   duplicate-key, alias, tag, scalar, and GitHub expression semantics.
7. **Vendor the reviewed parser source.** Commit parser code or its tarball and
   validate a digest offline. This strengthens availability but adds a large
   vendored surface and license/update burden without eliminating Node/npm lock
   identity.

Option 4 may retain Node-major `24` as the later P3 contributor policy, but P1's
workflow action input, evidence, and lock-producing invocation must name the
exact patch selected at the freeze gate.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Supply-chain identity | 30 | Binds parser, tarball/integrity, Node, npm, and official provenance exactly |
| Lockfile reproducibility | 25 | One reviewed tool tuple produces and verifies the committed lock |
| Security currency | 15 | Re-resolves at controlled gates and fails visibly on upstream drift |
| Runtime compatibility | 12 | Proves the parser/tool tuple on exact hosted and local requirements |
| P1/P3 scope discipline | 8 | Adds only the parser/foundation needed now and leaves npm 12 governance to P3 |
| Maintainer usability | 7 | Gives deterministic update and stop/review instructions |
| Churn | 3 | Avoids vendoring or custom parsing unless technically necessary |

An exact but permanently stale tuple cannot outscore an exact tuple with
governed re-resolution. Convenience ranges receive little credit because they
cannot reproduce a reviewed lock.

### Scoring

| Option | Supply chain (30) | Reproduce (25) | Currency (15) | Compatibility (12) | Scope (8) | Usability (7) | Churn (3) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Ranges/major only | 1 | 1 | 3 | 4 | 5 | 3 | 5 | 44.8 |
| 2. Parser only | 3 | 2 | 3 | 4 | 5 | 3 | 5 | 61.8 |
| 3. Exact forever | 5 | 5 | 0 | 4 | 5 | 3 | 5 | 79.8 |
| 4. Exact with freeze gates | 5 | 5 | 5 | 5 | 5 | 5 | 4 | **99.4** |
| 5. Pull P3 npm 12 forward | 5 | 5 | 5 | 4 | 1 | 4 | 3 | 88.6 |
| 6. Custom YAML parser | 2 | 2 | 2 | 3 | 2 | 1 | 0 | 39.8 |
| 7. Vendor parser | 5 | 4 | 2 | 4 | 1 | 2 | 0 | 70.0 |

The exact tuple with explicit re-resolution gives both reproducibility and
security currency while respecting the staged issue boundary.

### Selected resolution

Select **option 4: an exact tuple with implementation and merge freeze gates**.

Put the current proposed tuple in P1:

- direct dev dependency `yaml@2.9.0`;
- registry integrity
  `sha512-2AvhNX3mb8zd6Zy7INTtSpl1F15HW6Wnqj0srWlkKLcpYl/gMIMJiyuGq2KeI2YFxUPjdlB+3Lc10seMLtL4cA==`;
- registry tarball `https://registry.npmjs.org/yaml/-/yaml-2.9.0.tgz`;
- exact workflow and sole lock producer Node `24.18.1`; and
- its official bundled npm `11.16.0`, with the registry identity retained in
  evidence.

At both gates:

1. Query `yaml/latest`, `yaml/2.9.0`, the Node distribution index, and the
   selected npm record over authenticated TLS using the governed network
   environment.
2. Compare exact versions, engines, tarball URLs, integrity, release/security
   metadata, and official source identities with the issue.
3. If a newer eligible Node-24 security patch or any descriptor drift exists,
   stop for review, update the exact tuple, and do not mix old/new evidence.
4. Starting from the reviewed `package.json` and pre-change lock, use only the
   selected Node/npm to add exact `yaml`, regenerate lockfile v3, run `npm ci`,
   prove `npm ls yaml --json` resolves exactly one `2.9.0`, and run every P1
   validator/fixture.
5. Record the final manifest/lock hashes and exact tool tuple in the P1
   handoff. P3 may later supersede the npm/Node policy deliberately.

Change `setup-node`'s P1 input from major `24` to the selected exact patch.

## F08 — P1 action inputs and reviewed defaults

### Options

1. **Rely on pinned-manifest defaults.** Declare only `ref`,
   `persist-credentials`, `node-version`, and `package-manager-cache`; record
   the manifest digest. This is compact but leaves the intended disposition of
   many security/behavior inputs implicit.
2. **Declare every manifest input.** Put literal or expression values for all
   checkout/setup-node inputs, including empty optional values. This maximizes
   YAML visibility but couples the workflow to irrelevant inputs and makes
   empty/null YAML semantics easy to misstate.
3. **Use a closed per-role disposition table.** For every input in the pinned
   manifest, classify it as `Authored` with an exact YAML value,
   `ReviewedDefault` with the exact parsed default, or `NotApplicable` with a
   reason. Author all inputs that select code, credentials, persistence,
   history, subresources, cache, mirrors, or unsafe contexts. The structural
   validator checks authored equality and the separate manifest record checks
   every omitted/default classification.
4. **Wrap actions in local composite actions.** Centralize exact inputs in
   `.github/actions/checkout` and `.github/actions/setup-node`. This reduces
   repeated YAML later, but hides the external action call one layer deeper and
   adds code/path scope.
5. **Remove external actions.** Use native Git and preinstalled Node, avoiding
   action defaults entirely. This reintroduces runner-image drift, credential
   setup, and platform-specific bootstrap logic.
6. **Make only “security-relevant” inputs explicit without a closed
   definition.** This is better than option 1, but reviewers may disagree
   indefinitely about whether progress, safe-directory, path, architecture, or
   token defaults are relevant.

After F03, P1 has only checkout roles in the two workflows plus setup-node in
`markdownlint.yml`; upload-artifact and the temporary writer checkout disappear.
The chosen policy should therefore be written for this smaller final P1 role
set, not the obsolete temporary role table.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Behavioral explicitness | 25 | Every manifest input has an intentional, reviewable disposition |
| Credential/supply-chain safety | 20 | Code selection, token use, persistence, subresources, cache, and mirrors are closed |
| Upstream-drift detection | 15 | Manifest/input/default changes trigger deterministic renewed review |
| Workflow readability | 15 | Authored YAML exposes consequential behavior without irrelevant noise |
| YAML/schema correctness | 10 | Distinguishes absent, null, empty string, booleans, numbers, and expressions exactly |
| Structural enforceability | 8 | One validator can compare role, authored inputs, and reviewed defaults offline |
| Maintenance usability | 5 | A new action release has a clear update procedure |
| Churn | 2 | Avoids wrappers or fields that add no assurance |

The rubric rewards both explicit authored behavior and explicit intentional
omission. Raw line count is not a proxy for assurance.

### Scoring

| Option | Explicit (25) | Security (20) | Drift (15) | Readability (15) | Schema (10) | Validator (8) | Maintenance (5) | Churn (2) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Defaults mostly implicit | 2 | 3 | 4 | 5 | 3 | 3 | 3 | 5 | 64.8 |
| 2. Author every input | 5 | 4 | 4 | 1 | 2 | 4 | 2 | 1 | 68.8 |
| 3. Closed disposition table | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 4 | **99.6** |
| 4. Composite wrappers | 4 | 4 | 4 | 2 | 4 | 4 | 3 | 1 | 71.8 |
| 5. Remove actions | 3 | 2 | 2 | 2 | 3 | 2 | 1 | 0 | 45.2 |
| 6. Undefined relevant subset | 3 | 4 | 3 | 4 | 3 | 3 | 2 | 5 | 66.8 |

The closed disposition table makes omissions as reviewable as authored inputs
without bloating the workflow with values that the action does not consume.

### Selected resolution

Select **option 3: one closed per-role input disposition table**.

For each P1 checkout role, author at least:

- `repository: ${{ github.repository }}`;
- `ref: ${{ github.sha }}`;
- `token: ${{ github.token }}` with job `contents: read`;
- `persist-credentials: false`;
- `clean: true`;
- `fetch-depth: 1`;
- `fetch-tags: false`;
- `show-progress: false`;
- `lfs: false`;
- `submodules: false`;
- `set-safe-directory: false`; and
- `allow-unsafe-pr-checkout: false`.

For P1's setup-node role, author:

- `node-version: '24.18.1'` or the exact F07 re-resolved patch;
- `check-latest: false`;
- `token: ${{ github.token }}` under the same honest token model; and
- `package-manager-cache: false`.

The role table must list exact parsed scalar types, not prose shorthands.
Beside it, add a closed disposition record keyed by pinned action SHA and
manifest SHA-256. It enumerates every manifest input exactly once as
`Authored`, `ReviewedDefault`, or `NotApplicable`, including absent/null
defaults. Any new/removed/renamed input, default/type change, unknown YAML
input, role change, or manifest hash drift stops validation and requires
review. Explicit tokens mean issue prose must say “without persisted
credentials,” never “without credentials.”

Retain the current full-SHA/release re-resolution gate and update the recorded
manifest digests from the final pinned bytes.

## F09 — P1↔T1 reciprocal comparison

### Options

1. **Keep a prose topic list.** Reviewers discuss each listed area and retain
   narrative conclusions. This is flexible but cannot prove that every shared
   foundation was classified.
2. **Use one closed semantic comparison matrix.** Give each cross-repository
   contract a stable semantic key and columns for PS implementation identity, T
   implementation identity, classification (`Equivalent`, `Intentional
   Difference`, or `NotApplicable`), rationale, evidence, and follow-up owner.
   Require the exact same key set in P1 and T1 and reject blanks/unknown keys.
3. **Require byte-identical generator scripts.** Make one repository's script
   a copy of the other. This maximizes superficial unification but ignores
   source formats, destinations, frontmatter, and repository-specific wrappers.
4. **Create a shared package/repository immediately.** Move the serialization,
   path, replacement, and policy logic into a common versioned dependency used
   by both repositories. This may be a sound future architecture, but adds a
   release/supply-chain project far beyond P1/T1.
5. **Compare only externally observable bytes.** Run the same fixture corpus
   through both generators and compare outcomes. This is strong behavioral
   evidence but misses security boundaries such as path authority, recovery,
   action defaults, and evidence cleanup.
6. **Defer reciprocal review until both slates finish.** Avoid blocking early
   implementation on moving drafts, but permits incompatible foundations to
   harden before reconciliation.

Option 2 should include cross-repository semantic fixture keys and shared
behavioral evidence where behavior should match; it should not require local
test IDs, file names, or issue wording to be identical.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Behavioral interoperability | 30 | Proves common semantics where PS/T are intended to converge |
| Difference intentionality | 20 | Every divergence has an explicit technical reason and owner |
| Foundation completeness | 20 | Covers serialization, paths, replacement, parser/toolchain, workflows, evidence, and cases |
| Evolution/update safety | 10 | A new or removed contract cannot disappear silently from one repository |
| Reviewer comprehension | 10 | A cold reviewer can compare outcomes without translating local names |
| Independent auditability | 7 | Stable keys and evidence support mechanical completeness checks |
| Maintenance cost | 3 | Avoids a new shared product unless necessary |

True unification means equivalent contracts and intentional differences, not
byte-identical implementation files.

### Scoring

| Option | Interop (30) | Intent (20) | Complete (20) | Evolution (10) | Comprehension (10) | Audit (7) | Cost (3) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Prose topics | 3 | 3 | 3 | 2 | 3 | 1 | 5 | 56.4 |
| 2. Closed semantic matrix | 5 | 5 | 5 | 5 | 5 | 5 | 4 | **99.4** |
| 3. Byte-identical scripts | 2 | 0 | 2 | 2 | 4 | 4 | 4 | 40.0 |
| 4. Shared package now | 5 | 5 | 5 | 4 | 3 | 5 | 0 | 91.0 |
| 5. Output fixtures only | 4 | 2 | 2 | 2 | 4 | 3 | 5 | 59.2 |
| 6. Defer comparison | 1 | 0 | 1 | 1 | 1 | 0 | 5 | 17.0 |

The matrix reaches nearly the same semantic assurance as a shared package
without creating a third product and release lifecycle.

### Selected resolution

Select **option 2: a closed semantic comparison matrix**.

Expand P1's matrix to contain, at minimum, stable keys for:

- repository-root derivation and the closed source/destination map;
- source ordinary-file/link rejection;
- pure serialization and exact BOM/LF/final-newline behavior;
- all-four precomputation and per-destination replacement/recovery outcomes;
- first-version policy;
- exact YAML parser, Node/npm lock producer, and freeze gates;
- workflow event/path/permission/job contracts;
- authored action inputs versus reviewed defaults;
- the structural workflow-policy validator and offline fixtures;
- the NUL-safe Git path-set verifier;
- native-command capture;
- diagnostic ownership/redaction/retention;
- temporary-state creation/cleanup/uncertainty; and
- reviewed-head/landed evidence handoff.

For each key, require PS evidence, T evidence, classification, and rationale.
An `IntentionalDifference` must identify the repository-specific constraint and
show that the difference does not weaken the shared security/determinism goal.
`NotApplicable` needs equally specific evidence. Missing/extra keys, vague
“same” text, unresolved blockers, or a changed reciprocal result block P1
completion. Local P/T case IDs may differ; later F15 semantic keys provide
behavioral joins.

## F10 — Workflow fixtures and manifest-evidence ownership

### Options

1. **Embed all contracts and raw fixtures in the validator source.** Keep P1's
   eight-file scope by placing role tables, parsed manifest projections,
   positive YAML, negative YAML, expected results, and digests inside
   `Validate-WorkflowPolicy.mjs`. Offline execution is possible, but code,
   policy data, and fixture bytes become difficult to review independently.
2. **Commit one file per YAML fixture plus raw upstream action manifests.** Use
   a fixture directory and manifest snapshot directory. This is transparent
   and byte-faithful but adds many files, vendors upstream text, and requires
   license/provenance/update handling.
3. **Download manifests/fixtures during every validation run.** Keep the
   repository small and always inspect upstream. This contradicts deterministic
   offline validation and lets network/upstream drift change a historical
   commit's result.
4. **Keep fixtures and manifests only in external evidence.** The issue/PR
   retains archives with hashes and run IDs. This avoids repository files but
   means future local/CI validation cannot reproduce the policy suite.
5. **Add two tracked policy-data files and generate disposable fixtures.** A
   closed `workflow-policy-contract.json` owns action roles, authored input
   schemas, parsed reviewed-default projections, pinned manifest URLs/digests,
   job invariants, and allowed workflows. A closed
   `workflow-policy-cases.json` owns stable/semantic IDs, deterministic
   mutation recipes or bounded encoded raw YAML, exact expected phase/status,
   and required runtimes. The validator creates all raw test workflows under a
   job-owned temporary directory, verifies fixture digests, executes them
   offline, and removes only proved owned state.
6. **Use JavaScript modules instead of JSON data.** Separate contract/case
   modules export frozen objects and raw template strings. This improves
   comments/composition but permits executable fixture initialization and makes
   closed schema validation less independent.
7. **Use one combined JSON file.** Simpler affected-file list than option 5,
   but mixes production role truth with adversarial test recipes and causes
   unnecessary review conflicts.

Option 5 may store a small number of irreducibly raw duplicate-key/tag/alias
fixtures as base64 with exact decoded SHA-256; ordinary variations should be
generated from named mutations rather than copied workflow trees.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Offline reproducibility | 25 | A clean checkout runs the entire suite with no network or external archive |
| Policy/evidence integrity | 20 | Binds reviewed action manifests/defaults, roles, cases, and expected outcomes |
| Independent reviewability | 15 | Separates executable validator logic from policy and oracle data |
| Adversarial byte fidelity | 15 | Represents duplicate keys, tags, aliases, encoding, and raw malformed YAML exactly |
| Upstream/workflow drift detection | 10 | Changes in manifests, roles, workflows, or case catalogs fail closed |
| Scope transparency | 8 | Affected files and authoritative ownership are explicit |
| Update ergonomics | 5 | Maintainers can deliberately update one contract or case with clear evidence |
| File/churn cost | 2 | Avoids unnecessary vendored copies and fixture explosion |

Offline determinism and adversarial fidelity outweigh keeping an arbitrary
eight-file limit.

### Scoring

| Option | Offline (25) | Integrity (20) | Review (15) | Raw fidelity (15) | Drift (10) | Scope (8) | Updates (5) | Churn (2) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Embed in validator | 5 | 5 | 1 | 5 | 5 | 3 | 2 | 5 | 81.8 |
| 2. Fixture/manifest directories | 5 | 5 | 5 | 5 | 5 | 5 | 3 | 0 | 96.0 |
| 3. Download at validation | 0 | 1 | 2 | 2 | 0 | 3 | 2 | 5 | 24.8 |
| 4. External evidence only | 0 | 3 | 2 | 4 | 1 | 1 | 1 | 5 | 36.6 |
| 5. Two data files/generated fixtures | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 4 | **99.6** |
| 6. JavaScript data modules | 5 | 5 | 4 | 5 | 5 | 5 | 4 | 4 | 95.6 |
| 7. One combined JSON | 5 | 5 | 3 | 5 | 5 | 5 | 3 | 5 | 92.0 |

Two closed data files retain byte-level adversarial coverage while keeping
upstream manifest text and disposable workflow copies out of the repository.

### Selected resolution

Select **option 5: tracked contract/case data with disposable generated
fixtures**.

Add these P1 affected files:

- `.github/workflows/workflow-policy-contract.json`; and
- `.github/workflows/workflow-policy-cases.json`.

The contract file must have a closed versioned schema containing:

- exact allowed workflow paths and top-level/job invariants;
- the complete role set;
- action repository, full SHA, release, manifest URL/raw SHA-256;
- every manifest input's parsed type/default and F08 disposition;
- exact authored input values/types/expressions;
- permission, event, path-filter, and job-condition policy; and
- an update timestamp plus the F01 reviewed evidence identity, not a mutable
  “latest” locator.

The case file must have a different closed versioned schema containing unique
local ID, cross-repository `SemanticCase`, construction kind, base workflow,
ordered mutation or encoded raw bytes, decoded SHA-256 where raw, expected
phase/status, and required runtimes. No executable expressions or arbitrary
paths are permitted.

`Validate-WorkflowPolicy.mjs` validates both schemas before loading workflows.
It deterministically creates fixtures only below one job-owned temporary root,
never imports or executes fixture JavaScript, runs offline, verifies every
expected ID exactly once, and proves cleanup. An authenticated review tool or
documented manual process may fetch upstream manifests at the F07/F08 freeze
gates, but committed validation consumes only the reviewed projection/digest.

Update P1's affected-file/scope/path-set expectations from eight to ten files
and propagate these enduring contract paths to P1B and P3.

## F11 — P1A raw-object validation boundary

### Options

1. **Use strongly typed public parameters and validation attributes.** Let
   PowerShell binding reject invalid types before function code. This is
   idiomatic for trusted administration commands but loses control over
   coercion order and exact error/status classification.
2. **Accept raw `[object]` values, classify, then normalize privately.** Disable
   pipeline and implicit positional binding. For every untrusted scalar,
   classify automation null/null, string, boolean, numeric, enum, dictionary,
   collection/enumerable, scriptblock, PSObject/custom object, and other object
   before calling `ToString`, path APIs, numeric casts, or normalization.
   Accept only the exact raw types allowed per parameter and pass normalized
   private values to typed internal helpers.
3. **Accept one JSON request envelope.** Parse strict raw JSON into a closed
   object schema, avoiding PowerShell binder coercion. This supplies a clean
   serialization boundary but changes the public PowerShell API and creates a
   new raw JSON parser/encoding contract.
4. **Provide typed public wrappers around one raw internal entry point.** Keep
   ergonomic string/digest/count functions for normal callers and use a raw
   function only in the harness. Untrusted production callers can still enter
   through the coercing wrapper, so the security claim depends on call-site
   discipline.
5. **Compile a C# cmdlet with exact parameter types.** A compiled binder and
   .NET implementation can be more explicit, but still performs parameter
   conversion and adds build/binary/distribution scope.
6. **Stringify everything intentionally.** Define the string representation of
   arrays/custom objects and validate the resulting text. This is easy to call
   but makes semantically different raw inputs indistinguishable and can invoke
   attacker-controlled formatting/`ToString`.

Option 2 can retain strongly typed **private** helpers and ordinary string
ergonomics for accepted callers; only the public trust boundary remains raw.
Fixtures must exercise direct invocation and splatting on every required
PowerShell edition.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Raw type fidelity/fail-closed behavior | 30 | No invalid collection/custom/type value can become an accepted scalar through binding |
| Cross-edition consistency | 20 | Windows PowerShell 5.1 and current PowerShell classify the same raw values identically |
| Pre-side-effect validation | 15 | Type/cardinality/control/length checks complete before path resolution or filesystem access |
| Legitimate caller usability | 12 | Normal scalar calls remain understandable and do not require a new wire format |
| Fixture reachability | 10 | Every negative case reaches the claimed production boundary without binder short-circuit ambiguity |
| Stable diagnostics/status | 8 | Each rejection maps to a deterministic phase/status with bounded evidence |
| Scope cost | 5 | Avoids a compiler, binary, or new protocol when PowerShell can express the boundary |

Type fidelity dominates API terseness. A fixture that cannot reach production
code is not proof of production validation.

### Scoring

| Option | Type fidelity (30) | Editions (20) | Early validation (15) | Usability (12) | Reachable (10) | Diagnostics (8) | Scope (5) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Typed public parameters | 2 | 2 | 2 | 5 | 2 | 2 | 5 | 50.2 |
| 2. Raw public/private typed | 5 | 5 | 5 | 5 | 5 | 5 | 4 | **99.0** |
| 3. JSON envelope | 5 | 5 | 5 | 2 | 5 | 4 | 1 | 87.2 |
| 4. Typed wrappers | 2 | 3 | 3 | 5 | 3 | 3 | 4 | 59.8 |
| 5. Compiled cmdlet | 4 | 4 | 4 | 3 | 4 | 4 | 0 | 73.6 |
| 6. Intentional stringify | 0 | 1 | 1 | 4 | 4 | 1 | 5 | 31.2 |

The raw public boundary preserves PowerShell usability while giving the
implementation, rather than the binder, complete ownership of security
classification.

### Selected resolution

Select **option 2: raw public values with private typed normalization**.

For every security-sensitive public P1A parameter:

1. Declare `[Parameter(Mandatory)] [object]` (or leave it untyped) with
   `ValueFromPipeline = $false`, `ValueFromPipelineByPropertyName = $false`,
   and `CmdletBinding(PositionalBinding = $false)`.
2. Before interpolation, comparison that can coerce, enumeration, property
   access, `ToString`, or any filesystem/native call, classify the raw runtime
   type through one shared helper with a fixed order.
3. Accept paths/digests/labels only when the raw value is exactly
   `System.String`; accept limits only from the explicitly listed integral
   types and range-check before one checked conversion. Do not accept boolean,
   floating point, decimal, enum, dictionary, collection, arbitrary enumerable,
   scriptblock, deserialized/custom object, or `PSObject` wrapping one of those.
4. Define null, `[AutomationNull]::Value`, empty, whitespace, NUL/control,
   invalid surrogate, wildcard, length, and normalization failures separately.
5. After all raw fields pass, create a private immutable normalized record and
   let typed helpers consume only that record.
6. Replace “multiple resolution” fixtures based on impossible wildcard
   expansion with reachable raw array, list, dictionary, custom object,
   wrapped-object, scriptblock, numeric overflow, and disallowed scalar-type
   cases. Require the expected parameter-validation phase, zero filesystem
   calls, and identical behavior on Windows PowerShell 5.1/PowerShell 7.
7. Document accepted raw types in comment help so a legitimate caller does not
   need to infer the boundary.

## F12 — P1A context and ownership-journal schemas

### Options

1. **Retain descriptive PSCustomObjects.** Name the expected properties and
   enums in prose, then access them dynamically. This is flexible but cannot
   distinguish missing, extra, coerced, or wrong-width values reliably.
2. **Define closed versioned PSCustomObject schemas plus one validator.** Use a
   required first `PSTypeName`, exact ordered property names, exact CLR types,
   fixed enums, cardinality/range rules, and cross-field path/state
   relationships for context and journal records. Treat every received object
   as untrusted and validate before property-driven filesystem work.
3. **Use PowerShell classes.** Define typed `CandidateContext` and
   `OwnershipRecord` classes with methods. This gives strong construction
   types, but callers can still mutate public properties; class reloading and
   cross-script type identity are awkward on Windows PowerShell 5.1.
4. **Use immutable C# records/classes.** Compile exact types with private
   setters and constructors. This is structurally strong but adds runtime
   compilation/binary surface and does not remove the need to revalidate
   filesystem claims.
5. **Use hashtables with schema functions.** They are native and easy to clone,
   but case-insensitive keys, unordered variants, and automatic type behavior
   make strict cross-edition equality harder.
6. **Store the context as canonical JSON.** Every call reparses a strict
   versioned JSON envelope. This creates a portable evidence format but is
   cumbersome for PowerShell callers and adds raw JSON/encoding/duplicate-key
   requirements unrelated to archive bytes.
7. **Use private closure/capability objects.** Return an object whose cleanup
   methods close over trusted state rather than accepting fields back. This
   reduces caller tampering but is hard to serialize/test across scripts and
   can hide the exact ownership journal from evidence.

Option 2 can expose a separate deterministic evidence projection while keeping
the live object untrusted. Schema validity never proves that a path still
denotes the same filesystem object; path components are revalidated at use.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Closed structural precision | 25 | Exact property set/order, CLR types, enums, cardinality, and versions are normative |
| Tamper/fail-closed behavior | 20 | Extra/missing/wrapped/coerced/inconsistent fields fail before deletion |
| PowerShell 5.1/7 portability | 15 | Type construction/validation/dot-sourcing behaves identically on all required hosts |
| Lifecycle/path expressiveness | 15 | Represents ownership order, creation status, parentage, state, and uncertainty without ambiguity |
| Cold-reader clarity | 10 | An implementer can construct and validate records from the issue alone |
| Evidence projection | 7 | Produces bounded deterministic nonsecret records for retained proof |
| Fixture testability | 5 | Each field/type/relationship can be independently mutated and rejected |
| Implementation burden | 3 | Avoids a compiler/new wire format unless assurance requires it |

Construction-time typing helps, but validation of a returned untrusted object
and live filesystem relationships carries more weight.

### Scoring

| Option | Structure (25) | Tamper (20) | PS hosts (15) | Lifecycle (15) | Clarity (10) | Evidence (7) | Tests (5) | Burden (3) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Descriptive PSCustomObject | 2 | 1 | 5 | 3 | 2 | 3 | 3 | 5 | 52.2 |
| 2. Closed PSCustomObject schemas | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 4 | **99.4** |
| 3. PowerShell classes | 4 | 3 | 3 | 4 | 4 | 4 | 4 | 2 | 71.8 |
| 4. Compiled immutable types | 5 | 4 | 3 | 4 | 3 | 4 | 3 | 0 | 76.6 |
| 5. Hashtable schemas | 3 | 2 | 5 | 3 | 3 | 3 | 4 | 5 | 64.2 |
| 6. Canonical JSON context | 5 | 5 | 4 | 4 | 2 | 5 | 4 | 1 | 84.6 |
| 7. Closure/capability | 3 | 4 | 3 | 3 | 2 | 2 | 2 | 2 | 59.0 |

Closed versioned PSCustomObjects maximize portable transparency while still
forcing validation of both record claims and live filesystem state.

### Selected resolution

Select **option 2: closed versioned PSCustomObject schemas**.

P1A must publish two exact schema tables.

The context record has first `PSTypeName`
`PSStyleGuide.CandidateInvocationContext.v1` and exactly these properties:

- `SchemaVersion` (`System.UInt32`, exactly `1`);
- `ContextScriptVersion` (`System.Version`);
- `InvocationId` (`System.Guid`, nonempty);
- `DiagnosticLabel` (`System.String`, already F11-validated);
- `TrustedParentPath`, `InvocationRootPath`, `DownloadDirectoryPath`, and
  `CandidatePath` (exact nonempty normalized `System.String` values);
- `LifecycleState` (`System.String`: `Active`, `CleanupFailed`, or `Disposed`);
- `NextSequence` (`System.UInt32`); and
- `OwnershipJournal` (exact one-dimensional `System.Object[]`, including an
  empty array without scalar unrolling).

Each journal element has first `PSTypeName`
`PSStyleGuide.CandidateOwnershipRecord.v1` and exactly:

- `SchemaVersion` (`UInt32`, `1`);
- `Sequence` (`UInt32`, contiguous from zero);
- `Kind` (closed string enum for invocation root, download directory,
  download file, candidate directory, or candidate file);
- `Path`, `ParentPath`, and `LeafName` (normalized exact strings with proved
  parent/leaf recomposition);
- `ExpectedEntryType` (`File` or `Directory`);
- `CreationPhase` (closed string enum);
- `EntryState` (`ExpectedAbsent`, `Created`, `Deleted`, or
  `RetainedUncertain`); and
- `ContentLength` (`UInt64` or null only where the schema explicitly permits)
  and `ContentSha256` (64 lowercase hex string or null under the same rule).

One private validator checks exact `PSTypeNames[0]`, property name/order,
runtime types without conversion, enum casing, sequence/cardinality, state
transitions, path relationships, containment, and context/journal agreement.
Unknown properties or extra type names after the required first name do not
grant authority. The validator runs before every state transition and
filesystem action; filesystem claims are then independently re-proved.

## F13 — P1A lifecycle and repeated disposal

### Options

1. **Reinspect paths on repeated disposal.** A `Disposed` context proves that
   no journaled path reappeared, then returns success. This can inspect or act
   on unrelated objects created later at reused path names.
2. **Make terminal states zero-filesystem-call.** For an exact schema-valid
   `Disposed` context, return idempotent success after in-memory validation
   only. For `CleanupFailed`, return the retained failure/uncertainty without
   retry or filesystem calls. Only `Active` can enter the one synchronous
   cleanup attempt; success transitions to `Disposed`, any uncertainty to
   terminal `CleanupFailed`.
3. **Add `CleanupInProgress` and `RetainedUncertain`.** Use five states:
   `Active`, `CleanupInProgress`, `CleanupFailed`, `RetainedUncertain`, and
   `Disposed`. This can describe concurrency/recovery finely, but the current
   synchronous single-owner contract has no reachable concurrent re-entry and
   `CleanupFailed` already carries uncertainty.
4. **Retry cleanup from `CleanupFailed`.** Revalidate journaled paths and try
   deletion again. This may clean transient failures but risks deleting a later
   replacement and destroys the evidence that ownership was no longer proved.
5. **Treat missing paths as disposal success.** If cleanup or a later call
   cannot find entries, mark `Disposed`. This confuses absence with proved
   ownership/removal and can hide substitution or external interference.
6. **Return a new immutable context for each transition.** Never mutate the
   prior record; callers replace `Active` with `Disposed`/`CleanupFailed`.
   Historical evidence is clearer, but stale copies can be accidentally
   reused, so an invocation registry/capability would be needed for authority.
7. **Expose a `Dispose()` closure only.** Enforce one call internally and hide
   state transitions. This is convenient but makes explicit journal/state
   evidence and cross-script handoff harder.

Option 2 deliberately does not promise recovery from uncertain cleanup.
Operator remediation occurs outside the helper after evidence retention and
fresh authorization; it is not a second disposal call.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Deletion authority safety | 30 | Never touches a path after ownership has been released or become uncertain |
| Idempotent repeat behavior | 20 | Repeated terminal calls have deterministic status and zero filesystem/native calls |
| Uncertainty honesty | 15 | Never converts missing/substituted/unreadable state into proved cleanup |
| Reachable transition model | 10 | Every state/edge corresponds to an implementable synchronous behavior |
| Caller/operator usability | 10 | Clearly separates safe API repeats from separately authorized remediation |
| Evidence preservation | 7 | Retains primary and cleanup failure without later mutation erasing it |
| Cross-platform consistency | 5 | Does not depend on filesystem-specific name-reuse behavior |
| Churn | 3 | Uses the smallest state model that expresses real behavior |

Deletion safety is decisive: “helpful” retries lose when path ownership is no
longer certain.

### Scoring

| Option | Authority (30) | Repeat (20) | Uncertainty (15) | Reachable (10) | Usability (10) | Evidence (7) | Platforms (5) | Churn (3) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Reinspect after disposed | 2 | 2 | 2 | 4 | 3 | 3 | 2 | 5 | 49.2 |
| 2. Zero-call terminal states | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | **100.0** |
| 3. Five-state model | 5 | 5 | 5 | 2 | 2 | 5 | 5 | 1 | 85.6 |
| 4. Retry failed cleanup | 1 | 1 | 2 | 4 | 3 | 1 | 1 | 3 | 34.2 |
| 5. Missing means disposed | 0 | 3 | 0 | 4 | 4 | 0 | 2 | 5 | 33.0 |
| 6. Immutable transitions | 3 | 2 | 4 | 4 | 2 | 5 | 5 | 1 | 62.6 |
| 7. Closure-only disposal | 3 | 4 | 3 | 3 | 4 | 2 | 3 | 3 | 64.6 |

The three-state zero-call model is both simpler and safer than adding
unreachable concurrency states.

### Selected resolution

Select **option 2: terminal states perform zero filesystem/native calls**.

Publish this exact transition table:

| Current state | Operation/outcome | Next state | Filesystem calls |
| --- | --- | --- | ---: |
| `Active` | valid single cleanup; all owned entries proved and removed | `Disposed` | bounded required calls |
| `Active` | invalid schema/relationship before deletion | `CleanupFailed` | 0 deletion calls |
| `Active` | missing, unexpected, unreadable, substituted, reparse, deletion, or verification uncertainty | `CleanupFailed` | stop at first uncertainty |
| `Disposed` | same schema-valid context passed again | `Disposed` success | **0** |
| `CleanupFailed` | same schema-valid context passed again | `CleanupFailed` failure | **0** |
| any | schema-invalid/tampered context | unchanged failure | **0** |

Cleanup is synchronous and single-owner; concurrent/re-entrant invocation is
unsupported and rejected before deletion. Therefore do not add
`CleanupInProgress`. `CleanupFailed` is the one terminal retained-uncertainty
state; do not add a synonymous enum.

On the first `Active` cleanup, complete the pre-deletion proof before any
delete, delete only exact journaled children deepest-first/nonrecursively, and
transition to `Disposed` only after proving the invocation root absent as the
result of those successful owned deletes. After that transition, never inspect
those names again: a reappearing object is outside the released capability.
Add spies/counters proving every repeated terminal fixture makes zero
filesystem, provider, path-resolution, sleep, or native calls.

## F14 — P1A initial script versions

### Options

1. **Rely on the linked version policy only.** Let implementation infer the
   three initial values. This is technically derivable but unnecessarily
   ambiguous in a contract that validates exact metadata.
2. **Give all three scripts first-publication versions
   `1.0.<UTC implementation YYYYMMDD>.0`.** Compute each independently from the
   target-branch baseline and record exact version/hash identities in handoff.
3. **Give the helper/context scripts `1.0` and the harness `0.1`.** Treat tests
   as less stable. The repository policy does not create this distinction, and
   the permanent harness is an enduring public validation artifact.
4. **Use one shared “P1A version” for the bundle.** All three files always carry
   the same value. This makes handoff easy but forces unrelated same-day
   revision bumps and obscures which file changed later.
5. **Version only the archive helper.** Context manager and harness are
   implementation details. This contradicts their distributable script
   metadata requirements and weakens evidence identity.
6. **Use the P1 generator version for all three.** Numeric alignment looks
   cohesive but invents a shared publication history across different scripts.

Option 2 permits the three first values to be numerically equal because they
are first published on the same implementation date; equality is an outcome,
not a permanent coupled-version rule.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Per-file policy correctness | 35 | Applies first-publication and later revision rules independently to each script |
| Handoff traceability | 20 | Gives P1B exact version/hash identities for helper, context manager, and harness |
| Future maintenance semantics | 15 | Later changes bump only the files whose published content changes |
| Test-artifact status | 12 | Treats the permanent harness as an enduring governed script |
| Implementation clarity | 10 | States the initial value pattern and finalization baseline explicitly |
| PS/T semantic consistency | 5 | Uses the same version rule without coupling unrelated numbers |
| Churn | 3 | Avoids artificial synchronized bumps |

Traceable publication identity outweighs the convenience of one bundle number.

### Scoring

| Option | Policy (35) | Handoff (20) | Maintenance (15) | Harness (12) | Clarity (10) | PS/T (5) | Churn (3) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Implicit policy | 2 | 2 | 3 | 3 | 1 | 3 | 5 | 46.2 |
| 2. Three independent first versions | 5 | 5 | 5 | 5 | 5 | 5 | 5 | **100.0** |
| 3. Harness `0.1` | 2 | 5 | 4 | 2 | 4 | 2 | 4 | 63.2 |
| 4. Coupled bundle version | 3 | 4 | 1 | 4 | 4 | 3 | 1 | 61.2 |
| 5. Helper only | 1 | 1 | 1 | 0 | 2 | 1 | 5 | 22.0 |
| 6. Copy generator version | 1 | 3 | 0 | 3 | 2 | 0 | 2 | 31.4 |

Independent first publications are exact now and remain semantically correct
when the scripts evolve at different rates.

### Selected resolution

Select **option 2: three independently governed first versions**.

P1A must state that these baseline paths do not exist and therefore have no
previously published version:

- `Expand-StyleGuideCandidateArtifact.ps1`;
- `Manage-StyleGuideCandidateInvocationContext.ps1`; and
- `Test-Expand-StyleGuideCandidateArtifact.ps1`.

Each receives `.NOTES` `Version:
1.0.<UTC implementation YYYYMMDD>.0`, using the real date that file is first
published. Finalization rereads the target branch and applies the standard
same-day revision rule independently if a path appeared or changed meanwhile.
The acceptance suite parses each value as `[System.Version]`, compares build
date to the implementation evidence, and rejects copied/stale/missing values.
The P1A handoff records the three exact version strings and SHA-256 hashes.

## F15 — Namespaced local IDs and reciprocal semantic keys

### Options

1. **Keep short IDs such as `M-01`.** They are unique inside one table but
   collide in logs/evidence and convey no cross-repository meaning.
2. **Prefix the existing IDs only.** Rename them to values such as
   `PS-P1A-M-01`. This solves global log collisions but still compares PS/T
   cases by human interpretation.
3. **Use two keys per case in one tracked manifest.** Give every case an
   immutable repository-local `CaseId` (`PS-P1A-M-01`) and a stable,
   implementation-neutral `SemanticCase`
   (`archive.manifest.empty-entry-name`). Require local uniqueness, semantic
   uniqueness where one-to-one, an explicit variant suffix where several local
   cases implement one behavior, and reciprocal PS/T classification.
4. **Make PS and T use identical case IDs.** A single global catalog is easy to
   join, but repository-specific cases and different table groupings force
   unnatural gaps/renumbering.
5. **Use UUIDs.** Collision risk is negligible, but IDs are unmemorable and do
   not express either local grouping or semantics.
6. **Use semantic strings only.** Replace numeric IDs with long hierarchical
   names. This is readable in data but cumbersome in CI output, and variants
   still need a stable local discriminator.
7. **Map IDs only in the reciprocal matrix.** Leave the harness unchanged and
   maintain a prose/table translation. This duplicates catalog ownership and
   allows harness/matrix drift.

Option 3 should move the 96-case catalog into a closed tracked data file that
the harness consumes, leaving the issue's human table as a generated/reviewed
projection rather than a second independent source.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Semantic PS/T comparability | 25 | Joins equivalent behaviors without depending on local spelling or implementation |
| Automated completeness/drift control | 20 | Harness, evidence, and reciprocal matrix consume one closed catalog |
| Global evidence uniqueness | 20 | Every log/result ID is unambiguous across repository, issue, and suite |
| Human diagnosability | 15 | IDs are short enough for logs and semantic keys explain the behavior |
| Catalog evolution | 10 | New variants/repository-specific cases do not renumber existing identities |
| Schema/evidence auditability | 7 | Duplicate/missing/unknown keys and mappings fail deterministically |
| Migration churn | 3 | Renaming cost is bounded and justified |

Cross-repository semantic joinability is more important than preserving short
legacy labels that have not yet been implemented.

### Scoring

| Option | Semantics (25) | Automation (20) | Unique (20) | Human (15) | Evolution (10) | Audit (7) | Churn (3) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Short local IDs | 1 | 1 | 1 | 3 | 2 | 1 | 5 | 30.4 |
| 2. Prefix only | 1 | 2 | 5 | 4 | 3 | 3 | 4 | 57.6 |
| 3. Local + semantic manifest | 5 | 5 | 5 | 5 | 5 | 5 | 3 | **98.8** |
| 4. Identical PS/T IDs | 4 | 4 | 5 | 3 | 1 | 4 | 1 | 73.2 |
| 5. UUIDs | 0 | 3 | 5 | 0 | 5 | 4 | 2 | 48.8 |
| 6. Semantic strings only | 5 | 4 | 5 | 2 | 4 | 4 | 1 | 81.2 |
| 7. Matrix-only mapping | 3 | 1 | 1 | 3 | 2 | 1 | 5 | 40.4 |

Dual keys preserve concise local diagnostics and create a durable reciprocal
join without forcing PS/T implementations into one numbering scheme.

### Selected resolution

Select **option 3: namespaced `CaseId` plus semantic key in one manifest**.

Add `.github/workflows/style-guide-candidate-cases.json` to P1A. Its closed
schema contains exactly one record for every mandatory case, with:

- `CaseId`, matching `^PS-P1A-[A-Z]+-[0-9]{2}$` and immutable after publication;
- `SemanticCase`, a lowercase dot-separated implementation-neutral name;
- optional `SemanticVariant` only when multiple local cases intentionally map
  to one semantic behavior;
- fixture kind/parameters, required runtimes, expected status/phase;
- exact pre-teardown oracle and cleanup oracle; and
- raw fixture digest/length where applicable.

The harness must load this file as inert data, reject duplicate/unknown/missing
properties, prove every `CaseId` executes once on exactly the declared runtime
set, and emit both keys in the F16 result. The P1A issue table should be updated
to show both keys, but the tracked manifest is the implementation source of
truth. P1A↔T1A compares `SemanticCase` plus optional variant and explicitly
classifies PS-only/T-only cases. Renumbering an existing `CaseId` or silently
changing a semantic mapping is a breaking harness change.

## F16 — P1A harness result-record schema

### Options

1. **Keep a prose property list.** Emit PSCustomObjects with the described
   fields. Easy to implement, but extra/missing/type-coerced fields and enum
   drift can pass unnoticed.
2. **Define a closed typed PSCustomObject result plus canonical evidence
   projection.** Validate exact property names/order/CLR types/enums and all
   expected-versus-actual relationships in memory; serialize a fixed
   nonsecret subset to deterministic JSON Lines for retained evidence.
3. **Emit canonical JSON only.** Avoid PowerShell object ambiguity and validate
   with JSON Schema. This is portable but awkward for direct PowerShell callers
   and introduces raw JSON parsing for in-process assertions.
4. **Use Pester result objects.** Gain a familiar test framework/reporters, but
   add a dependency and inherit a broad changing result schema not tailored to
   phase/cleanup/security oracles.
5. **Return only process exit and text logs.** Simple CI integration, but loses
   per-case structured expected/actual status and makes bounded redaction/
   reciprocal comparison fragile.
6. **Use a PowerShell class.** Strong constructor types, but the same 5.1 class
   reload/type-identity concerns as F12 apply, and evidence still needs a
   separate stable projection.
7. **Emit one summary object only.** Counts pass/fail by suite. Compact, but a
   missing case can be hidden unless the complete individual catalog/results
   are independently retained.

Option 2 should keep nondeterministic timestamps/durations out of semantic
result equality while allowing a bounded run envelope to record them
separately.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Oracle correctness/completeness | 25 | Proves each expected case, status, phase, pre-teardown, and cleanup outcome |
| Mismatch visibility | 20 | Expected/actual values and harness/internal failures cannot collapse together |
| Cross-host type stability | 15 | Exact behavior survives Windows PowerShell 5.1 and current PowerShell |
| Retained evidence interoperability | 15 | Has a deterministic, schema-versioned, machine-readable projection |
| Diagnostic usefulness | 10 | Identifies case/semantic/runtime/phase with bounded stable codes |
| Data minimization/redaction | 7 | Excludes arbitrary paths, archive content, environment, and secrets |
| Developer ergonomics | 5 | Supports direct PowerShell assertions and CI aggregation |
| Dependency/churn cost | 3 | Avoids broad frameworks or formats not otherwise needed |

A pretty test report cannot compensate for an open or ambiguous semantic
record.

### Scoring

| Option | Oracle (25) | Mismatch (20) | Hosts (15) | Evidence (15) | Diagnostics (10) | Minimize (7) | Ergonomics (5) | Cost (3) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Prose PSCustomObject | 2 | 2 | 4 | 2 | 3 | 3 | 4 | 5 | 53.2 |
| 2. Closed object + JSONL | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 4 | **99.4** |
| 3. JSON only | 5 | 5 | 4 | 5 | 4 | 5 | 2 | 2 | 90.2 |
| 4. Pester objects | 3 | 3 | 3 | 4 | 4 | 3 | 4 | 1 | 64.8 |
| 5. Exit/text only | 1 | 1 | 5 | 1 | 2 | 2 | 3 | 5 | 39.8 |
| 6. PowerShell class | 4 | 4 | 3 | 4 | 4 | 4 | 3 | 2 | 74.8 |
| 7. Summary only | 1 | 1 | 5 | 2 | 1 | 5 | 3 | 5 | 45.0 |

The dual in-memory/evidence representation gives strict PowerShell behavior and
portable retained proof from one semantic record.

### Selected resolution

Select **option 2: a closed PSCustomObject and canonical JSONL projection**.

Each in-memory result has first `PSTypeName`
`PSStyleGuide.CandidateCaseResult.v1` and exactly:

- `SchemaVersion` (`UInt32`, `1`);
- `CaseId`, `SemanticCase`, and nullable `SemanticVariant` (exact strings);
- `OperatingSystem`, `PowerShellEdition`, and `PowerShellVersion` (closed
  string enums plus exact `System.Version`);
- `ExpectedStatus`, `ActualStatus`, `ExpectedPhase`, and `ActualPhase` (closed
  enums; actual nullable only for a separately coded harness-start failure);
- `ExpectedPreTeardownOracle`, `ActualPreTeardownOracle`,
  `ExpectedCleanupState`, and `ActualCleanupState`;
- `FixtureLength` (`UInt64`) and `FixtureSha256` (lowercase hex);
- `InvocationId` (`Guid`);
- `Outcome` (`Passed`, `Failed`, or `HarnessError`);
- `DiagnosticCode` (closed bounded string enum); and
- `FilesystemCallCount` (`UInt32`, required especially for F13 terminal cases).

Reject every unexpected property/type/enum and every inconsistent relationship:
`Passed` requires all expected/actual fields equal, the catalog runtime match,
the fixture hash match, and no diagnostic except `None`. A suite succeeds only
when the multiset of results equals the required `CaseId`×runtime expansion
exactly.

The JSONL projection uses a documented fixed property order and invariant
string forms (including PowerShell version and GUID), BOM-less UTF-8, LF, one
object per result, and no absolute paths, exception stack, environment, or
archive content. A separate run envelope may contain start/end UTC and tool
hashes; those fields do not alter per-case semantic equality.

## F17 — P1B job graph, direct dependencies, permissions, and data flow

### Options

1. **Keep prose plus the action-role table.** Let the validator infer the job
   graph from scattered requirements. This misses direct-`needs` output
   visibility and makes least privilege difficult to review.
2. **Add one closed normative job/data-flow table and encode it in the existing
   policy contract.** For every job, specify workflow, events, runner, exact
   direct `needs`, exact job `if`, exact permissions, side effects, produced
   outputs, and each output consumer. Require top-level `permissions: {}` and
   explicit job grants. The validator compares parsed YAML to the table/data
   contract and rejects transitive output reads.
3. **Use a graph diagram only.** A Mermaid/DOT diagram is readable but not an
   exact typed contract and can drift from YAML.
4. **Use workflow-wide `contents: read` and writer override.** Simpler YAML;
   approval and other jobs receive read authority even when they need no
   repository access.
5. **Split each stage into a reusable workflow.** GitHub `workflow_call`
   boundaries make inputs/outputs explicit, but add multiple workflow files,
   permission/token inheritance complexity, and remote artifact handoffs.
6. **Generate the workflow from a graph manifest.** Treat a JSON graph as source
   and generate YAML. This prevents drift but creates a new generator and makes
   reviewing the actual security workflow less direct.
7. **Derive documentation automatically from YAML.** A tool emits the job table
   for review. This is useful evidence, but a derived table cannot define which
   graph is allowed unless compared to an independent normative contract.

Option 2 uses F10's `workflow-policy-contract.json`; it does not add a second
validator or duplicate job truth in another tracked file.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Authorization/least privilege | 25 | Top-level denial and exact per-job grants expose write only to the authorized writer |
| Direct data-flow correctness | 25 | Every consumed output comes from an exact direct dependency with closed producer/consumer typing |
| Gate/failure semantics | 18 | Conditions and result handling cannot authorize on skip/failure/cancellation |
| Structural enforceability | 12 | Existing validator rejects any graph, permission, output, or side-effect drift |
| Reviewer usability | 10 | One table lets a cold reviewer understand the complete workflow |
| GitHub-semantics fidelity | 7 | Reflects direct `needs`, matrix outputs, reusable-call, and permission behavior accurately |
| Scope/churn | 3 | Reuses existing contract/validator rather than adding workflow generators |

Permissions and direct data flow are co-equal: a read-only job using an
unavailable transitive output is still an incorrect graph.

### Scoring

| Option | Authority (25) | Data flow (25) | Gates (18) | Validator (12) | Review (10) | Semantics (7) | Scope (3) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Prose/action table | 3 | 2 | 3 | 2 | 2 | 2 | 5 | 50.4 |
| 2. Closed job/data table | 5 | 5 | 5 | 5 | 5 | 5 | 4 | **99.4** |
| 3. Diagram only | 1 | 1 | 2 | 0 | 5 | 2 | 4 | 32.4 |
| 4. Workflow-wide read | 2 | 4 | 4 | 4 | 4 | 4 | 5 | 70.6 |
| 5. Stage workflows | 4 | 4 | 4 | 3 | 2 | 3 | 0 | 69.8 |
| 6. Generate workflow | 5 | 5 | 5 | 5 | 3 | 4 | 0 | 91.6 |
| 7. Derived documentation | 3 | 3 | 3 | 2 | 5 | 4 | 4 | 63.6 |

The closed table achieves nearly the same mechanical assurance as generated
YAML without making a generator the new workflow review boundary.

### Selected resolution

Select **option 2: a closed job/data-flow table backed by the existing policy
contract**.

P1B must set `permissions: {}` at the top of both workflows and publish rows
for exactly:

- `build.yml/validate_markdown`: no `needs`; local same-commit reusable call;
  `contents: read`; no outputs or side effects;
- `build.yml/prepare_candidate`: no `needs`; ordinary job condition;
  `contents: read`; produces the immutable candidate identity/digest/name,
  event identity, `has_changes`, and four path-bound hashes; side effect is one
  retained artifact only;
- `build.yml/verify_candidate_windows`: direct
  `needs: [prepare_candidate]`; `contents: read`; consumes only preparation
  outputs; produces exactly four static attestation outputs; diagnostic
  artifacts only under the F19 failure condition;
- `build.yml/approve_candidate`: direct
  `needs: [prepare_candidate, validate_markdown,
  verify_candidate_windows]`; `if: ${{ always() }}`; `permissions: {}`;
  consumes only those direct results/outputs and emits one closed writer
  authorization bundle; no external side effect;
- `build.yml/synchronize_generated_artifacts`: direct
  `needs: [approve_candidate]`; exact approved changed push-to-main predicate;
  `contents: write`; consumes every artifact/event/hash/ref value through the
  approval bundle rather than transitive `needs`; sole repository mutation;
  and
- `markdownlint.yml/markdownlint`: local `workflow_call`; no `needs`;
  `contents: read`; no outputs or side effects.

The table must spell every exact job `if`, runner/reusable call, direct output
schema, producer, consumer, permission key, and side effect. Extend
`workflow-policy-contract.json` with the same closed graph, and make
`Validate-WorkflowPolicy.mjs` reject workflow-level grants, implicit job
permissions, transitive `needs.*` references, output name collisions, unknown
jobs, and any side effect outside the declared rows.

## F18 — P1B artifact action inputs, archive, and retention

### Options

1. **Keep current seven-day candidate retention and default compression.**
   Explicitly classify compression default `6` and archive `true`. This works,
   but retains transient candidate data seven times longer than same-run
   consumers need and preserves an unexplained PS/T difference.
2. **Converge candidate transport on one day, compression zero, and explicit
   archive behavior.** Candidate upload authors every consequential input,
   including `retention-days: 1`, `compression-level: 0`, and `archive: true`
   for its four files. Failure diagnostics remain seven days with their own
   explicit compression/archive/missing-file policy. Downloads author immutable
   ID, protected path, `skip-decompress: true`, and digest mismatch failure;
   every omitted selector/cross-run input is classified.
3. **Use seven days for every artifact.** Maximizes debugging availability but
   increases exposure/storage and conflates candidate transport with
   diagnostic evidence.
4. **Use repository-default retention.** Avoid a potentially unsupported
   one-day setting, but behavior changes with repository configuration and
   cannot be compared reliably across PS/T.
5. **Upload four unarchived artifacts.** `archive: false` supports one file, so
   create four uploads and pass four IDs/digests. This avoids a zip but
   quadruples action roles/data flow and creates cross-file consistency risks.
6. **Avoid artifacts and regenerate independently in every job.** Matrix cells
   can validate deterministic output, but the writer would not promote the
   exact byte object validated by all cells; transport assurance disappears.
7. **Delete candidate immediately after approval.** Minimize retention using
   API cleanup before the writer. This destroys the object the writer still
   needs and adds token/API authority.

The option 2 diagnostic upload can use compression `0` for bounded text/files
unless measured storage cost justifies another explicit value. Candidate and
diagnostic retention are intentionally different because their consumers and
forensic value differ.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Validated-object integrity | 25 | All cells and writer consume the exact immutable four-file artifact ID/digest |
| Exposure/retention minimization | 20 | Candidate exists only for the shortest supported useful window; diagnostics are bounded |
| Explicit deterministic behavior | 15 | Archive/compression/selection/path/digest/missing-file inputs are authored and typed |
| Manifest-drift enforcement | 10 | Every input/default has the F08 closed disposition and digest gate |
| Operational reliability | 10 | Same-run matrix/writer can always retrieve one complete candidate |
| Diagnostic usefulness | 10 | Failure evidence remains long enough for review without masking primary failure |
| PS/T semantic convergence | 7 | Equivalent transport uses equivalent settings or an evidence-backed difference |
| Churn/cost | 3 | Avoids extra artifacts/API jobs and unnecessary storage |

Short retention matters, but never at the expense of promoting the exact
validated object.

### Scoring

| Option | Integrity (25) | Exposure (20) | Explicit (15) | Drift (10) | Reliability (10) | Diagnostics (10) | PS/T (7) | Cost (3) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Seven-day/default compression | 5 | 2 | 3 | 4 | 5 | 5 | 2 | 3 | 74.6 |
| 2. One-day explicit transport | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 4 | **99.4** |
| 3. Seven days everywhere | 5 | 0 | 5 | 5 | 5 | 5 | 2 | 1 | 73.4 |
| 4. Repository defaults | 5 | 1 | 1 | 2 | 4 | 4 | 1 | 5 | 56.4 |
| 5. Four unarchived uploads | 3 | 4 | 5 | 5 | 2 | 4 | 1 | 0 | 69.4 |
| 6. Regenerate, no artifact | 1 | 5 | 5 | 5 | 3 | 2 | 3 | 4 | 66.6 |
| 7. Delete before writer | 0 | 5 | 4 | 4 | 0 | 2 | 2 | 0 | 46.8 |

One explicit four-file candidate is the strongest integrity/exposure balance
and aligns with the sister contract.

### Selected resolution

Select **option 2: one-day explicit candidate transport and separately bounded
diagnostics**.

Candidate upload authors:

- collision-free exact name;
- four literal paths in fixed order;
- `if-no-files-found: error`;
- `retention-days: 1`;
- `compression-level: 0`;
- `overwrite: false`;
- `include-hidden-files: false`; and
- `archive: true`.

Each candidate download authors:

- the exact approved/preparation `artifact-ids` expression;
- the exact fresh P1A context download directory;
- `merge-multiple: false`;
- `skip-decompress: true`; and
- `digest-mismatch: error`.

It omits and explicitly classifies `name`, `pattern`, `github-token`,
`repository`, and `run-id`, proving the artifact is same-run and selected only
by immutable ID. It accepts exactly one retained archive and separately
compares the bare upload digest.

Diagnostic upload authors its collision-free name, exact bounded diagnostic
paths, `if-no-files-found: warn`, `retention-days: 7`,
`compression-level: 0`, `overwrite: false`, `include-hidden-files: false`, and
`archive: true`; it is nonauthoritative and `continue-on-error: true`. Apply
F08's complete manifest disposition/digest rules to upload/download roles and
record the transport settings as `Equivalent` in P1B↔T1B except for a
documented action-version capability difference.

## F19 — P1B diagnostic predicates

### Options

1. **Use `${{ failure() }}`.** Upload diagnostics whenever a prior step/job is
   failed. This contradicts the issue's explicit “never cancellation” rule.
2. **Use `${{ failure() && !cancelled() }}`.** Capture ordinary failures but
   make cancellation an explicit veto. Keep `continue-on-error: true`.
3. **Use `${{ always() && !cancelled() }}` plus a script check.** The step runs
   on successes and decides whether files exist. This wastes work and can
   create diagnostics for nonfailures.
4. **Use `${{ !success() && !cancelled() }}`.** This may include skipped or
   unexpected states that are not a producing failure and is less directly
   aligned with GitHub's status functions.
5. **Create a separate diagnostics job.** Depend on every producer and use one
   terminal condition. This centralizes uploads but requires cross-job
   diagnostic transport, more permissions, and cannot access job-local files
   without another artifact.
6. **Never upload diagnostics.** Rely on job logs. Eliminates exposure but
   weakens bounded cross-matrix/writer failure evidence.

Option 2 applies independently to the Windows-matrix and writer diagnostic
steps. A cancelled run must create no diagnostic artifact even if an earlier
step had failed before cancellation.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Cancellation veto | 30 | No diagnostic step/action runs after run/job cancellation |
| Genuine-failure coverage | 25 | Runs for every eligible preceding failure with locally available bounded evidence |
| Primary-result integrity | 15 | Diagnostic preparation/upload cannot replace or hide the primary failure |
| Predicate auditability | 15 | Exact structural expression directly communicates policy |
| Matrix/writer consistency | 10 | Same semantics apply to both roles and their negative fixtures |
| Churn | 5 | Uses built-in status functions without extra jobs/transport |

Cancellation is weighted highest because the issue explicitly makes it a hard
privacy/cost boundary.

### Scoring

| Option | Cancel (30) | Failures (25) | Primary (15) | Audit (15) | Roles (10) | Churn (5) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. `failure()` | 1 | 5 | 5 | 3 | 2 | 5 | 64.0 |
| 2. `failure() && !cancelled()` | 5 | 5 | 5 | 5 | 5 | 5 | **100.0** |
| 3. `always() && !cancelled()` | 5 | 4 | 4 | 3 | 4 | 4 | 83.0 |
| 4. `!success() && !cancelled()` | 5 | 3 | 4 | 2 | 4 | 5 | 76.0 |
| 5. Diagnostics job | 5 | 4 | 3 | 3 | 3 | 0 | 74.0 |
| 6. No diagnostics | 5 | 0 | 5 | 5 | 5 | 5 | 75.0 |

The exact conjunction is both the most legible and the only option that fully
matches the stated failure/cancellation policy.

### Selected resolution

Select **option 2: `${{ failure() && !cancelled() }}` everywhere diagnostics
are eligible**.

Replace both normative action-role conditions and every corresponding prose,
contract-data, fixture, and acceptance occurrence. Require:

- the literal parsed expression shape, not a textually different equivalent;
- `continue-on-error: true` on preparation and upload so the primary failure
  remains terminal;
- no diagnostic role on approval cancellation, job cancellation, or successful
  execution;
- matrix cases for failure, failure-followed-by-cancellation, pure
  cancellation, success, and unexpected skip; and
- writer equivalents before and after credential materialization, with
  redaction/minimization unchanged.

The validator must reject `${{ failure() }}`, `${{ always() }}`,
`${{ !success() }}`, a missing `!cancelled()`, or any diagnostic action in an
unknown role.

## F20 — P1B credential terminology and materialization timing

### Options

1. **Fix only the two phrases.** Replace “without credentials” with “without
   persisted credentials” and “before token materialization” with “before push
   credential projection.” Correct, but the rest of the issue can still blur
   token existence, action input, Git persistence, and process use.
2. **Define one explicit credential-state model and use it everywhere.** Name
   job-token existence, granted permissions, action-input projection,
   checkout's temporary authentication, post-action retained Git credential
   state, derived push-header construction, exact push exposure, and final
   derived-state cleanup. Assertions target the correct stage and never claim
   the platform token can be made nonexistent inside the job.
3. **Make all checkouts unauthenticated with `token: ''`.** For this public
   repository, fetch over public HTTPS and reserve the job token solely for the
   writer push. This minimizes checkout exposure but may reduce reliability,
   diverges from setup-node token behavior, and does not remove token existence
   in the job.
4. **Persist checkout credentials until push.** Reuse the checkout-installed
   token for Git. Simpler, but directly violates least privilege and makes
   repository scripts run with stored write credentials.
5. **Use a separate GitHub App token generated immediately before push.** The
   job `GITHUB_TOKEN` can have no write grant; mint a short-lived app token
   late. This improves separation but requires app/private-key or OIDC
   infrastructure outside repository scope.
6. **Use an SSH deploy key.** Project a write-only key at push time. This adds
   long-lived secret/key management and is weaker operationally than the
   repository-scoped ephemeral token.
7. **Avoid automatic push.** Have the workflow open a candidate PR or ask a
   maintainer to commit. This changes P1B's approved publication objective.

Option 2 can later adopt option 3 after measured cross-platform fetch evidence,
but wording must remain honest even when no action input receives the token:
GitHub still creates the job token.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Credential-model truthfulness | 25 | Distinguishes token existence, permissions, projection, persistence, use, and cleanup |
| Exposure minimization | 25 | Write-capable derived material reaches only the exact authorized push |
| Checkout/publication reliability | 15 | Exact SHA fetch and exact-lease push work on supported events/runners |
| Structural/test auditability | 15 | Each state has observable nonsecret assertions and negative sentinel drills |
| Cold-reader clarity | 10 | A new implementer cannot misread “no credentials” or cleanup promises |
| PS/T convergence | 7 | Uses the same semantic state model across both repositories |
| Churn/infrastructure | 3 | Avoids new external credentials/services without evidence they are needed |

Truthful modeling and exposure receive equal highest weight; terminology is
part of the security contract, not editorial polish.

### Scoring

| Option | Truth (25) | Exposure (25) | Reliable (15) | Audit (15) | Clarity (10) | PS/T (7) | Infra (3) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Phrase edits only | 3 | 4 | 5 | 2 | 3 | 3 | 5 | 69.2 |
| 2. Credential-state model | 5 | 5 | 5 | 5 | 5 | 5 | 4 | **99.4** |
| 3. Unauthenticated checkout | 5 | 5 | 3 | 4 | 4 | 2 | 4 | 84.2 |
| 4. Persist checkout token | 2 | 0 | 5 | 1 | 2 | 1 | 5 | 36.4 |
| 5. GitHub App token | 5 | 5 | 3 | 4 | 4 | 3 | 0 | 83.2 |
| 6. SSH deploy key | 4 | 3 | 3 | 3 | 3 | 2 | 0 | 61.8 |
| 7. No automatic push | 5 | 5 | 3 | 4 | 4 | 4 | 1 | 85.2 |

The state model preserves the chosen writer architecture while removing false
assurance and making every credential assertion testable.

### Selected resolution

Select **option 2: one exact credential-state model**.

Use these terms throughout P1B:

1. **Job token exists:** GitHub creates `GITHUB_TOKEN` at job start with the
   job's declared permissions. This is true even before any script reads it.
2. **Action input projected:** `${{ github.token }}` is passed to an exact
   checkout/setup action role. Checkout may use temporary authentication.
3. **No retained checkout credential:** after checkout's post-action cleanup
   and before executing repository-controlled code, prove no credential helper,
   credential-bearing remote, `http.*.extraheader`, SSH command/key, askpass,
   or action-created auth file remains. Say “checkout without persisted
   credentials,” not “without credentials.”
4. **No derived push credential:** before the authorized push step, the
   platform token exists but no derived Authorization header/value has been
   placed in script text, command arguments, Git config, remote URL, logs,
   artifacts, or child-process environment.
5. **Exact push projection:** only after all identity/remote/lease checks,
   project the token through the one reviewed process-scoped mechanism for the
   single exact refspec/lease push. Mask any derived value before possible
   logging; disable tracing; never echo or retain it.
6. **Derived state removed:** in `finally`, clear every process environment/Git
   setting created by the push mechanism and repeat the retained-state scan.
   Do not claim the GitHub-managed job token itself was destroyed; it expires
   when the job ends.

The sentinel drills use a synthetic test credential, never the real token, and
scan bounded owned logs/artifacts/config/process records. Add these states and
their exact allowed transitions to `workflow-policy-contract.json` and the
P1B↔T1B matrix.

## F21 — Real P1B writer evidence on isolated state

### Options

1. **Keep a copied temporary evidence workflow.** Reproduce the writer
   algorithm in `evidence-p1b-temporary-writer.yml` and structurally compare it
   to production. Safe for main, but does not exercise production job IDs,
   direct outputs, conditions, and real data flow.
2. **Run the real `build.yml` from an isolated evidence ref with a closed
   literal patch.** Create a unique never-merged branch from the reviewed head.
   Apply only reviewed event/target-ref literal substitutions in `build.yml`
   and matching expected constants in policy data, plus one bounded source
   fixture that creates deterministic artifact drift. Prove all other workflow,
   validator, script, and graph bytes/semantics equal the reviewed production
   versions. Push the evidence ref, let that same `build.yml` execute and write
   exactly one lease-bound commit to the evidence ref, verify the graph/commit,
   retain evidence, then delete the remote ref and prove absence.
3. **Test after merging on main.** Let the first real source change prove the
   writer. This gives full fidelity but makes production the experiment and
   cannot be an acceptance gate for the change that introduces the writer.
4. **Use local mocks only.** Mock Git/artifact/token/Actions behavior and test
   every branch. Deterministic and safe, but cannot prove GitHub output wiring,
   permissions, artifacts, or remote leases.
5. **Add a permanent `workflow_dispatch` evidence mode.** Let maintainers name a
   temporary target ref. This exercises the exact file without patching, but
   permanently enlarges the write-capable event/input/authorization surface.
6. **Use a separate test repository.** Mirror the commit and run the workflow
   there. Protects the primary repo but changes repository identity,
   permissions, branch protection, token, and settings.
7. **Use GitHub environment approval on main.** Put the writer behind manual
   approval and test a no-op. This does not prove a changed push and introduces
   a permanent external setting dependency.

Option 2 must treat the evidence ref and its commits as hostile/noncanonical:
they are never merged, tagged, used as a dependency handoff, or accepted as
production source.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Production-graph fidelity | 30 | Exercises the same workflow path, job IDs, outputs, artifact flow, conditions, and writer code |
| Default-branch safety | 20 | No evidence operation can mutate or become reachable from `main` |
| Remote/credential realism | 15 | Uses actual GitHub token permissions, artifacts, remote state, and exact lease |
| Cleanup/nonpersistence | 15 | Deletes only proved test state and proves workflow/ref/credential absence |
| Evidence auditability | 10 | Exact before/run/writer/after identities and allowed deltas are retained |
| Repeatability/negative drills | 7 | Unique refs support stale lease, no-op, unrelated event, and cleanup cases |
| Permanent-surface cost | 3 | Leaves no enduring test-only event or writer path |

Real job-graph fidelity is weighted highest; structural similarity alone is not
execution evidence.

### Scoring

| Option | Fidelity (30) | Main safety (20) | Real auth (15) | Cleanup (15) | Audit (10) | Drills (7) | Surface (3) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Copied workflow | 3 | 5 | 4 | 4 | 4 | 5 | 3 | 78.8 |
| 2. Real workflow/evidence ref | 5 | 5 | 5 | 4 | 5 | 5 | 5 | **97.0** |
| 3. Test on main after merge | 5 | 0 | 5 | 1 | 4 | 1 | 5 | 60.4 |
| 4. Local mocks | 2 | 5 | 0 | 5 | 4 | 5 | 5 | 65.0 |
| 5. Permanent dispatch mode | 5 | 3 | 5 | 4 | 4 | 5 | 0 | 84.0 |
| 6. Separate repository | 3 | 5 | 3 | 4 | 4 | 4 | 2 | 73.8 |
| 7. Environment/no-op | 2 | 2 | 3 | 3 | 3 | 1 | 1 | 46.0 |

The isolated-ref method is the only pre-merge option that runs the production
workflow graph without retaining a production test entry point.

### Selected resolution

Select **option 2: execute the real `build.yml` on a unique isolated evidence
ref**.

P1B must specify this exact acceptance transaction:

1. Record the reviewed production head and hashes of `build.yml`,
   `workflow-policy-contract.json`, the validator, and all writer scripts.
2. Create a unique branch name below `refs/heads/evidence/p1b/<run-id>-<nonce>`
   from that head; prove local/remote absence and validate the ref format.
3. In one test-only commit, change only the exact production `main` event/ref
   literals to that full evidence ref and the matching expected constants in
   the policy contract. Add one bounded recognizable change to an authoritative
   style-guide source that deterministically changes at least one generated
   artifact. No generated artifact is pre-updated.
4. Run a semantic comparator that parses both production/evidence workflow and
   contract data, requires equality of all jobs, `needs`, conditions except the
   named literal predicate, permissions, roles, inputs, outputs, scripts, and
   writer algorithm, and rejects every other delta.
5. Push the test commit to the evidence ref. Require the real preparation,
   reusable Markdown job, four Windows cells, approval, and
   `synchronize_generated_artifacts` jobs to run. The writer must create exactly
   one child commit updating only the derived artifact subset with the expected
   parent, message, tree, author policy, refspec, and exact lease.
6. Verify candidate ID/digest/hashes, four attestations, approval bundle,
   credential sentinel/state evidence, remote before/after IDs, commit
   reachability, changed path set, and no second workflow run from the
   `GITHUB_TOKEN` push.
7. Repeat separate uniquely named refs for stale-lease/no-op/failure cases as
   needed; a negative run must never mutate its ref unexpectedly.
8. Retain immutable run URLs/IDs and exact commit/hash/delta records. Delete
   each exact remote evidence ref, verify `ls-remote` absence, delete only its
   proved local state, and show that no temporary workflow file or permanent
   dispatch mode exists in the reviewed production tree.

Replace P1B's copied `evidence-p1b-temporary-writer.yml` requirement with this
protocol and add the semantic comparator cases to the existing policy suite.

## F22 — P3 exact npm, Corepack, Node floors, and lock producer

### Options

1. **Leave versions for implementation-time selection.** Require “latest
   compatible” npm/Node and record what happened. This cannot serve as a
   reviewed dependency contract.
2. **Use each Node release's bundled npm.** Avoid Corepack and external npm
   selection. Node 22/24 currently bundle different npm 10/11 releases, neither
   is the selected npm 12 remediation target.
3. **Pin npm 12 only in `package.json`.** Add `packageManager: npm@12.0.2` but
   omit a tarball hash and exact Corepack/Node patches. Version drift and
   enforcement bypass remain possible.
4. **Use a hash-qualified npm descriptor, exact Node/Corepack cells, and two
   freeze gates.** Set npm
   `12.0.2+sha224.<reviewed-tarball-hash>`, use explicit `corepack npm`, define
   the finite supported Node range from npm's engines, use exact Node 22/24
   security patches and their exact bundled Corepack versions, designate one
   exact Node-24 tuple as sole lock producer, and re-resolve all identities
   immediately before implementation/merge.
5. **Install one global Corepack/npm version independently of Node.** Normalize
   both cells with `npm install -g corepack@...`. This creates a bootstrap chain
   through the very bundled npm being replaced and mutates runner-global state.
6. **Use a container image with Node/npm/Corepack pinned by digest.** Strong
   environment identity, but Windows/hook behavior still needs host testing and
   image build/provenance becomes another product.
7. **Support Node 26/current too.** Follow npm's open-ended `>=26` engine.
   This violates the intended finite LTS contributor policy and expands
   unbounded future behavior.
8. **Use an alternative manager such as pnpm.** Avoid npm CLI governance but
   requires lockfile migration, dependency semantics changes, and scope far
   beyond advisory remediation.

Option 4 permits two exact bundled Corepack versions because Corepack is part
of each exact official Node distribution. The behavior/configuration contract
must be identical even when those implementation versions differ.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Package-manager supply-chain integrity | 25 | Binds npm version, tarball hash/integrity, Corepack identity, and official Node source |
| Lockfile reproducibility | 20 | One exact tuple alone produces the committed lock and all cells verify it |
| Runtime-policy correctness | 18 | Finite supported Node lines satisfy exact npm/Corepack engines with measured floors |
| Bypass resistance | 12 | Explicit invocation and strict/integrity controls reject ambient/system manager substitution |
| Security currency | 10 | Controlled re-resolution adopts eligible security patches only after renewed review |
| Contributor/CI usability | 8 | Same commands work clearly on supported local and hosted environments |
| Scope discipline | 5 | Remediates npm policy without changing package manager or adding an image product |
| Churn | 2 | Minimizes bootstrap/global-state machinery |

Supply-chain and reproducibility outrank convenience of bundled but different
npm versions.

### Scoring

| Option | Supply (25) | Lock (20) | Runtime (18) | Bypass (12) | Currency (10) | Usability (8) | Scope (5) | Churn (2) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Select later | 1 | 1 | 2 | 1 | 3 | 3 | 5 | 5 | 36.4 |
| 2. Bundled npm | 4 | 2 | 4 | 3 | 4 | 5 | 4 | 5 | 71.6 |
| 3. Unhashed npm pin | 3 | 3 | 3 | 2 | 3 | 4 | 5 | 5 | 62.0 |
| 4. Hashed npm/exact cells | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 4 | **99.6** |
| 5. Global bootstrap | 4 | 5 | 5 | 4 | 5 | 3 | 3 | 1 | 85.8 |
| 6. Digest-pinned container | 5 | 5 | 3 | 5 | 4 | 2 | 1 | 0 | 80.0 |
| 7. Add Node 26+ | 4 | 2 | 0 | 3 | 4 | 2 | 2 | 3 | 49.6 |
| 8. Change manager | 3 | 3 | 2 | 4 | 4 | 1 | 0 | 0 | 53.4 |

The exact hash-qualified finite policy is the only option that closes both the
manager supply chain and the supported runtime surface.

### Selected resolution

Select **option 4: hash-qualified npm, exact Node/Corepack cells, and one exact
lock producer**.

Use this current proposed contract, subject to both freeze gates:

- `packageManager`:
  `npm@12.0.2+sha224.4c4977784242293bf5a4f80d28aab2d001ba8a7a4532285591a158aa`;
- npm registry integrity:
  `sha512-uIXokLlBj6FpNUTQX1PmT5pz7BlIN9QlixX+zdaSNHsd0qUXsbDLr50xzY6Sw7cJVr0uzHKDOle0swmPW/p5Qw==`;
- finite `engines.node`:
  `>=22.22.2 <23 || >=24.15.0 <25`;
- compatibility cell: Node `22.23.2`, bundled Corepack `0.34.6`;
- lock-producer/preferred cell: Node `24.18.1`, bundled Corepack `0.35.0`;
  and
- every package operation invoked as `corepack npm ...`, never bare `npm`,
  `npx`, `corepack use`, or a global manager install.

At implementation and merge, query the official Node index, exact Node-tag
Corepack package, npm registry record/tarball, and applicable security
metadata. Stop for review on a new eligible security patch, engine change,
version/tag/tarball/integrity mismatch, or Corepack behavior change. Update the
complete tuple atomically, then regenerate the lock only with the selected
Node-24 tuple.

Both cells prove their actual `process.execPath`, `process.versions.node`,
`corepack --version`, `corepack npm --version`, package-manager descriptor
hash, clean install/tree/audit/lint/hook results, and byte-identical lock
no-op. P3 records P1's former tuple as deliberately superseded rather than
silently overwriting its evidence.

## F23 — Production Node-policy observation and policy authority

### Options

1. **Keep CLI arguments for observed version and policy.** Maximizes fixture
   injection but lets production callers claim a different runtime or weaken
   the policy.
2. **Separate production and pure APIs.** Export one frozen tracked policy and
   a pure evaluator that accepts an observed string/policy only for tests.
   Production CLI accepts no arguments, reads `process.versions.node`, and
   evaluates only the compiled policy. Production imported callers pass the
   actual process value to a policy-bound wrapper, not caller input.
3. **Read observed version/policy from environment variables.** Easy for shell
   hooks and CI but directly spoofable by ambient/caller state.
4. **Run `node --version` and parse stdout.** Uses a child process that may
   resolve a different executable than the already running CLI.
5. **Trust `engines.node` and npm warnings.** Avoid custom code, but npm engine
   strictness/configuration is variable and hook code needs the same decision
   before invoking npm.
6. **Read `.nvmrc`/`.node-version` as the policy.** Useful version-manager
   metadata usually selects one preferred version, not a finite two-LTS
   support union.
7. **Use setup-node's action output.** Authoritative only inside workflow jobs,
   unavailable to local hook/imported paths, and still must match the actual
   process.
8. **Use a semver dependency directly.** Reliable parsing/range behavior, but
   adds a package dependency before the hook has validated Node/npm/install
   state; the policy authority problem remains.

Option 2 may expose a pure `evaluateNodeVersionForFixture` by name so production
code cannot accidentally use the injection surface without an explicit
review-visible import.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Runtime-observation authenticity | 25 | Production evaluates the exact Node process executing policy code |
| Policy-source consistency | 20 | CLI, hook, import, engines, workflow, and cases implement one tracked finite rule |
| Caller-spoof resistance | 20 | No production argument/environment/file can substitute observed version or policy |
| Pure fixture testability | 15 | Every canonical/malformed/floor/major case is injected without spawning or patching production |
| Local/CI usability | 10 | One no-argument command gives stable categories before npm/node_modules |
| Structural evidence | 7 | Validator proves production imports/calls the bound API and case catalog |
| Dependency/churn cost | 3 | Remains dependency-free and small |

Authenticity and spoof resistance outweigh the apparent convenience of one
overloaded function for both production and tests.

### Scoring

| Option | Authentic (25) | Consistent (20) | Spoof-proof (20) | Tests (15) | Usability (10) | Evidence (7) | Cost (3) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Caller arguments | 1 | 2 | 0 | 5 | 3 | 2 | 5 | 39.8 |
| 2. Bound production/pure test APIs | 5 | 5 | 5 | 5 | 5 | 5 | 5 | **100.0** |
| 3. Environment inputs | 1 | 2 | 0 | 5 | 4 | 2 | 5 | 41.8 |
| 4. Spawn `node --version` | 3 | 4 | 4 | 3 | 3 | 3 | 4 | 68.6 |
| 5. Engines/npm only | 2 | 2 | 2 | 1 | 3 | 1 | 5 | 39.4 |
| 6. Version file policy | 3 | 1 | 2 | 3 | 2 | 2 | 3 | 44.6 |
| 7. setup-node output | 2 | 2 | 2 | 2 | 1 | 2 | 3 | 38.6 |
| 8. Semver dependency | 4 | 3 | 2 | 5 | 3 | 3 | 1 | 65.8 |

Only the split API simultaneously provides authentic production observation
and complete pure malformed-version fixtures.

### Selected resolution

Select **option 2: policy-bound production entry points and a clearly separate
pure fixture API**.

`Check-NodePolicy.mjs` must:

- export a deeply frozen, versioned `NODE_POLICY` containing exactly
  `>=22.22.2 <23 || >=24.15.0 <25` (or the F22 re-resolved equivalent);
- export `evaluateNodeVersionForFixture(observed, policy)` as a dependency-free
  pure function that accepts raw fixture values and never reads process state;
- export `evaluateCurrentNode()` with no parameters; it reads
  `process.versions.node` exactly once and evaluates only `NODE_POLICY`; and
- when executed as the CLI, reject every positional argument, read no policy/
  version environment variable or file, call `evaluateCurrentNode()`, emit one
  bounded canonical result, and use closed exit codes for supported,
  unsupported, malformed-internal, and tool failure.

`lint-staged-markdown.mjs` imports `evaluateCurrentNode`; it does not import the
fixture API. The hook invokes the no-argument CLI before resolving Corepack/npm
or `node_modules`. The workflow calls the no-argument CLI and separately proves
setup-node's reported version equals the running process.

The F29 catalog tests the pure API with synthetic inputs and tests the CLI only
with its real supported/unsupported process plus unexpected-argument cases.
`Validate-WorkflowPolicy.mjs` rejects a CLI version/policy argument,
environment override, alternate import, or production reference to the fixture
API.

## F24 — `install-husky.mjs` installation and skip contract

### Options

1. **Leave the installer outside P3.** Treat the current helper as incidental
   even though `package.json` invokes it through `prepare`.
2. **Keep the current silent skip behavior.** Return success for
   `CI=true`, `HUSKY=0`, or `NODE_ENV=production`; otherwise import Husky,
   change directory, and trust its return string.
3. **Specify and harden the installer as a first-class P3 surface.** Use a
   closed decision model, observable reason codes, an installer-relative
   repository root, exact postconditions, and disposable-repository fixtures.
4. **Delete the helper and run `husky` directly from `prepare`.** Reduce code,
   but lose explicit production/CI behavior and repository-root validation.
5. **Replace Husky with a hand-written `core.hooksPath` installer.** Gain
   control at the cost of duplicating Husky's installation and upgrade logic.
6. **Always install, including CI and production.** Avoid branching, but fail
   when development dependencies are intentionally absent and mutate
   short-lived CI Git configuration unnecessarily.
7. **Swallow installation failures.** Make `prepare` best-effort so dependency
   installation succeeds, at the cost of a falsely healthy local hook state.
8. **Move installation to `postinstall`.** Run later in npm's lifecycle, but
   broaden package-side effects and depart from Husky's documented `prepare`
   integration.

Option 3 can preserve the supported upstream skip cases without letting a
generic ambient CI variable silently suppress local policy.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Local hook correctness | 22 | A reported install leaves the exact tracked hook path active and usable |
| Install/CI determinism | 20 | Every environment combination has one closed, observable outcome |
| Failure truthfulness | 16 | Unexpected ambient state, Husky errors, and bad postconditions fail rather than disappear |
| Git/filesystem safety | 14 | Fixed root, ordinary-file checks, and disposable tests avoid caller or user-global mutation |
| Cross-platform behavior | 10 | Works consistently from supported shells and arbitrary starting directories |
| Supply-chain consistency | 8 | Uses only the lock-pinned Husky through the selected package-manager lifecycle |
| Fixture completeness | 7 | Branches, malformed environment values, and failure paths are deterministic tests |
| Scope/churn | 3 | The implementation remains a small lifecycle helper |

Hook correctness, deterministic lifecycle behavior, and honest failure account
for 58% of the decision; brevity cannot compensate for a silently absent hook.

### Scoring

| Option | Hook (22) | Determinism (20) | Truth (16) | Safety (14) | Platform (10) | Supply (8) | Fixtures (7) | Scope (3) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Omit from P3 | 1 | 1 | 1 | 2 | 2 | 2 | 0 | 5 | 27.4 |
| 2. Current silent skips | 3 | 2 | 1 | 3 | 4 | 4 | 2 | 5 | 53.0 |
| 3. Closed hardened installer | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 4 | **99.4** |
| 4. Direct `husky` | 3 | 2 | 2 | 2 | 3 | 5 | 1 | 5 | 51.6 |
| 5. Hand-written installer | 4 | 4 | 4 | 4 | 2 | 2 | 4 | 1 | 71.0 |
| 6. Always install | 4 | 1 | 3 | 3 | 3 | 4 | 2 | 4 | 57.2 |
| 7. Swallow failures | 0 | 3 | 0 | 2 | 3 | 3 | 2 | 5 | 34.2 |
| 8. `postinstall` | 3 | 2 | 3 | 2 | 3 | 3 | 2 | 3 | 51.8 |

Only the explicit installer contract makes “installed,” “deliberately
skipped,” and “failed” mutually exclusive evidence-bearing outcomes.

### Selected resolution

Select **option 3: make `install-husky.mjs` a hardened, tested P3 surface**.

Add `.github/workflows/install-husky.mjs` to P3's affected files and specify
these production rules:

- accept no positional arguments and derive the repository root solely from
  the script's own location;
- evaluate the environment with this precedence: exact `HUSKY=0` yields
  `SkippedExplicitOptOut`; `NODE_ENV=production` yields
  `SkippedProduction`; exact `CI=true` without `HUSKY=0` fails with
  `CiRequiresExplicitHuskyPolicy`; absent/empty `CI` or exact `CI=false`
  continues; unexpected nonempty values for these controls fail closed;
- emit one bounded stable status for every skip, install, or failure—never a
  silent successful skip;
- before installation, require the fixed package root, `package.json`,
  lockfile, `.git`, and tracked `.husky` inputs to be expected ordinary
  non-link paths; do not read or write user-global Git configuration;
- only after deciding to install, import the exact lock-resolved `husky`,
  change to the fixed root, invoke it once, and treat any thrown error or
  nonempty return message as failure; and
- after success, verify local `core.hooksPath` is exactly `.husky/_`, the
  expected generated support directory exists, and each tracked hook remains
  an ordinary file. A postcondition failure is an installer failure.

Expose a clearly fixture-only pure decision function while the production CLI
reads its own environment exactly once. Test all precedence permutations,
unexpected values, wrong starting directories, import/call failures, missing
or linked inputs, nonempty Husky messages, and postcondition failures in
disposable temporary Git repositories. Also run one real `prepare` install and
one explicit `HUSKY=0` clean-CI install. Production/CI commands that intend to
skip hooks set `HUSKY=0` explicitly; they do not rely on ambient `CI`.

## F25 — Raw npm-audit bytes and native-process outcome

### Options

1. **Keep the parsed PowerShell-object boundary.** Let PowerShell capture and
   parse npm output, then pass an object to JavaScript policy code.
2. **Let the production JavaScript CLI own launch, raw bytes, strict decoding,
   parsing, schema, and policy.** Spawn exact `corepack npm audit` without a
   shell; classify start/timeout/signal/exit; bound both streams; reject BOM,
   malformed UTF-8, duplicate names, extra values, and resource-limit breaches
   before validating the report.
3. **Capture raw bytes in PowerShell and pipe them to JavaScript stdin.** Keep
   native launch in the harness but define a byte-preserving IPC protocol and
   send process metadata separately.
4. **Use `execFile` and `JSON.parse` directly.** Obtain buffers and limits with
   little code, but silently accept duplicate member names and blur buffer
   overflow/timeout/exit combinations unless wrapped carefully.
5. **Redirect stdout/stderr to temporary files.** Avoid memory pressure and
   preserve bytes, but introduce file cleanup/link/race requirements for a
   bounded report.
6. **Call an internal npm audit library API.** Avoid CLI text parsing, but bind
   policy to an undocumented internal API and bypass the selected Corepack/npm
   command identity.
7. **Add a third-party strict JSON parser.** Simplify duplicate detection but
   make the audit validator depend on an installed package before it can assess
   that package tree.
8. **Trust native exit code only.** Extremely small, but cannot enforce
   exceptions, graph closure, schema, severity, or malformed-report handling.
9. **Accept JSON Lines or recover the last JSON value.** Tolerate diagnostic
   contamination, but creates ambiguity over which bytes are authoritative.

For options 2 and 3, the process/result cross-product must include start
failure, timeout, signal, output overflow, exit 0, vulnerability exit, other
nonzero exit, missing output, and valid/invalid report permutations.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Boundary authenticity | 22 | Policy sees the exact bounded stdout bytes and complete native outcome it owns |
| Malformed-input rejection | 20 | Encoding, BOM, lexical, duplicate-name, root, trailing-data, and limit failures are distinct |
| Process correctness | 18 | Start, timeout, signal, overflow, close, and closed exit/report combinations cannot be confused |
| Policy/schema integrity | 15 | Only one validated report object reaches vulnerability and exception evaluation |
| Cross-platform determinism | 9 | No shell, locale, PowerShell conversion, or platform-specific redirection semantics |
| Supply-chain independence | 7 | Boundary needs only the selected Node built-ins and exact Corepack command |
| Diagnostic safety | 6 | Bounded stderr and stable categories preserve troubleshooting without leaking arbitrary bytes |
| Scope/churn | 3 | Added implementation and fixtures remain reviewable |

Raw-boundary authenticity, malformed-input rejection, and native-process
correctness deliberately carry 60% of the score.

### Scoring

| Option | Boundary (22) | Malformed (20) | Process (18) | Policy (15) | Platform (9) | Supply (7) | Diagnostics (6) | Scope (3) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Parsed PowerShell object | 0 | 1 | 2 | 3 | 1 | 4 | 2 | 4 | 32.4 |
| 2. JavaScript owns full boundary | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 4 | **99.4** |
| 3. PowerShell bytes/JS policy | 4 | 5 | 4 | 5 | 2 | 5 | 4 | 2 | 83.6 |
| 4. `execFile` + `JSON.parse` | 4 | 2 | 3 | 3 | 5 | 5 | 3 | 5 | 68.0 |
| 5. Temporary files | 5 | 5 | 4 | 5 | 3 | 5 | 4 | 1 | 89.2 |
| 6. npm internal API | 2 | 3 | 2 | 4 | 4 | 0 | 3 | 2 | 52.0 |
| 7. Third-party strict parser | 4 | 5 | 4 | 5 | 5 | 0 | 4 | 3 | 82.6 |
| 8. Exit only | 1 | 0 | 2 | 0 | 5 | 5 | 1 | 5 | 31.8 |
| 9. Recover JSON value | 2 | 0 | 3 | 2 | 3 | 5 | 2 | 4 | 42.8 |

Owning both launch and raw interpretation in one dependency-free CLI removes
the lossy cross-language handoff and scores highest on every controlling risk.

### Selected resolution

Select **option 2: the production `Validate-NpmAudit.mjs` CLI owns the complete
process-and-bytes boundary**.

Production mode accepts no report, executable, arguments, root, timeout, or
policy overrides. It derives the fixed repository root, creates the closed F30
environment, and spawns the selected `corepack` executable with an argument
array for exact `npm audit --package-lock-only --json` semantics,
`shell: false`, piped streams, hidden Windows console, and fixed 120-second,
4-MiB stdout, and 256-KiB stderr limits. It waits for stream close, not merely
process exit. The fixture-only core accepts synthetic byte arrays and a
synthetic native-outcome record; it never spawns.

Classify in this order: `StartFailed`, `TimedOut`, `Signaled`,
`StdoutLimitExceeded`, `StderrLimitExceeded`, `Exited`, then report status.
For an exited process, require a numeric code in the closed set `{0, 1}`;
any other code is `AuditToolFailed`. Exit 0 must pair with a schema-valid report
whose computed threshold count is zero; exit 1 must pair with at least one
reported threshold vulnerability before exception policy and may ultimately
pass only when every such finding is covered by a valid exception. All other
exit/report pairings fail as `NativeReportMismatch`; exception handling never
converts start/transport/parser/schema/tool failure into success.

Before `JSON.parse`, reject empty stdout, a leading UTF-8 BOM, malformed UTF-8
using a fatal decoder, forbidden control/non-Unicode string content, excessive
nesting/token/property/string/number limits, duplicate decoded member names in
each object, trailing non-whitespace, or more than one JSON value. Implement a
small dependency-free lexical scanner for these checks, then require exactly
one object root and pass it to the F26 closed schema. Do not echo arbitrary
stdout/stderr; evidence contains byte counts, SHA-256 digests, native fields,
stable categories, and only allowlisted bounded diagnostics.

The PowerShell evidence harness invokes this no-argument CLI and consumes its
canonical result; it never runs npm itself and never passes an already parsed
audit object.

## F26 — Raw/schema/process fixture ownership and completeness

### Options

1. **Keep only inline parsed-report cases.** Exercise policy examples inside
   JavaScript tests but omit raw bytes and native outcomes.
2. **Create one authoritative versioned npm-audit case manifest.** Store
   semantic parsed-report, raw-byte, process-outcome, schema, graph, exception,
   and cross-product cases in `.github/workflows/npm-audit-policy-cases.json`;
   generate disposable files/process adapters from it.
3. **Create separate manifests per layer.** Keep raw, process, schema, and
   policy cases modular, with a meta-validator proving unique IDs and coverage.
4. **Store raw fixtures as many tracked `.json`/binary files.** Make byte
   fixtures visually direct, but expand the affected-file and path-safety
   surface substantially.
5. **Generate cases procedurally only.** Use test loops/fuzz seeds without a
   reviewable case inventory.
6. **Snapshot actual npm output.** Test realistic reports but couple expected
   bytes to live registry/npm formatting and omit malformed permutations.
7. **Property-based fuzz only.** Explore broad lexical inputs but provide weak
   stable traceability from requirements to named cases.
8. **Rely on integration tests.** Run the live command and omit injected
   failures because they are difficult to reproduce.

The catalog alternatives must account for the Cartesian seams—not merely each
layer alone—especially valid report plus wrong exit, invalid report plus exit
0/1, overflow plus partial valid prefix, and timeout/signal plus output.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Boundary coverage | 21 | Named cases cover raw bytes, process state, parser, schema, graph, policy, and exceptions |
| Seam/permutation coverage | 20 | Cross-layer contradictions and precedence are explicitly exercised |
| Review traceability | 17 | Stable IDs and semantic keys map each requirement to one authoritative expected result |
| Deterministic replay | 15 | Offline tests generate exact bytes/outcomes without network, clock, or platform variance |
| Drift prevention | 11 | Validator rejects duplicate IDs, orphan requirements, unknown fields, and unused cases |
| Failure diagnostics | 8 | Every case expects one stable category and bounded evidence shape |
| Maintenance usability | 5 | Adding an npm schema/policy case requires one obvious edit |
| File/churn cost | 3 | Fixture count and repository noise stay controlled |

Coverage and traceability carry 58%; fixture neatness is secondary to proving
the dangerous cross-layer combinations.

### Scoring

| Option | Boundary (21) | Seams (20) | Trace (17) | Replay (15) | Drift (11) | Diagnostics (8) | Usability (5) | Cost (3) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Parsed inline cases | 2 | 1 | 2 | 5 | 1 | 3 | 3 | 5 | 47.2 |
| 2. One authoritative manifest | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 4 | **99.4** |
| 3. Layered manifests | 5 | 5 | 4 | 5 | 4 | 5 | 3 | 2 | 90.6 |
| 4. Tracked raw fixture tree | 5 | 4 | 4 | 5 | 3 | 4 | 2 | 0 | 80.6 |
| 5. Procedural only | 4 | 4 | 1 | 5 | 2 | 3 | 3 | 5 | 66.4 |
| 6. npm snapshots | 2 | 1 | 2 | 2 | 2 | 3 | 3 | 3 | 39.2 |
| 7. Fuzz only | 4 | 3 | 1 | 3 | 1 | 2 | 2 | 4 | 51.0 |
| 8. Integration only | 1 | 0 | 1 | 1 | 0 | 2 | 3 | 5 | 19.8 |

A single case source gives reviewers one closed inventory while generators
retain byte-level and process-level fidelity.

### Selected resolution

Select **option 2: add one closed
`.github/workflows/npm-audit-policy-cases.json` catalog**.

The catalog has a schema version, unique namespaced `CaseId` values
(`PS-P3-AUDIT-*`), a stable `SemanticCase`, exactly one layer/requirement key,
fixture recipe, native outcome, expected terminal category, and expected
bounded evidence fields. Recipes encode byte fragments/base64 rather than
tracking a fixture tree; the test harness writes them only beneath a fresh
disposable root. Unknown fields, duplicate IDs/semantic keys, unconsumed cases,
missing expected categories, and requirement keys without at least one
positive and one negative case fail structural validation.

The mandatory closed inventory covers:

- **raw/lexical:** empty, whitespace, BOM, invalid/truncated/overlong UTF-8,
  NUL/control content, truncated token, invalid escape, unpaired surrogate,
  duplicate decoded key at root and nested levels, two values, scalar/array
  root, trailing garbage, numeric hazards, and each byte/depth/token/property/
  string limit at boundary and over boundary;
- **native process:** start error, timeout, each representative signal,
  stdout/stderr overflow, exit 0 clean, exit 1 vulnerable, exit 0 vulnerable,
  exit 1 clean, exit above 1, null/inconsistent fields, and valid-looking
  partial output attached to every non-exit terminal state;
- **npm schema v2:** exact root/metadata/vulnerability/via/effects/nodes/fix
  shapes, missing/unknown/wrong-type fields, severity/count disagreements,
  Boolean-versus-object `fixAvailable`, URL/name/range constraints, and
  canonical ordering;
- **graph/policy:** direct and transitive findings, cycles, dangling/ambiguous
  nodes, multi-path reachability, dev/optional/peer/prod membership,
  exception none/valid/expired/mismatched/overbroad, and recomputed totals; and
- **seams:** every accepted parsed-policy example under both native exit codes,
  malformed input under 0 and 1, exception-pass with native vulnerability exit,
  and parser/schema/policy precedence when multiple defects coexist.

The catalog is authoritative for test expectations; issue prose states the
closed requirements but does not maintain a second divergent fixture list.

## F27 — Live issue evidence for audit exceptions

### Options

1. **Validate exception URLs syntactically offline.** Require a GitHub issue URL
   and expiry fields but never verify the referenced issue.
2. **Call GitHub live during every audit.** Require the issue to be open and
   labeled/assigned on each pull request, local run, and scheduled run.
3. **Split offline records from a privileged live verifier.** Track a minimal
   immutable issue-evidence projection and digest; validate it deterministically
   on every run; refresh/verify live on exception creation, scheduled/manual
   maintenance, and before release.
4. **Disallow all exceptions.** Fail on every threshold vulnerability until the
   dependency graph is clean.
5. **Trust a signed maintainer text file.** Verify a Git signature or CODEOWNERS
   review but do not connect the approval to current issue state.
6. **Use issue-form body fields as the only policy store.** Fetch and parse the
   live issue body each run instead of maintaining a repository record.
7. **Use labels only.** Treat an open issue with a particular label as an
   exception, omitting package/range/severity/path and expiry scope.
8. **Use a security-advisory object instead of an issue.** Better confidentiality
   for sensitive disclosures, but ordinary dependency advisories and ownership
   workflow do not necessarily map to repository security advisories.
9. **Permit exceptions only through branch-protection review.** Treat merged
   JSON as approval without proving the referenced tracking issue remains open,
   owned, or within expiry.

For options with live state, permutations include public/private repository,
404/403/rate limit/network failure, issue versus pull request, open/closed,
transferred/deleted, label/assignee change, stale record, repository mismatch,
and changed immutable identity.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Exception authenticity | 23 | Approval binds an exact finding scope to a real current owned issue |
| Fail-closed security | 19 | Closed/stale/mismatched/unavailable evidence cannot silently authorize risk |
| Deterministic PR/local use | 16 | Untrusted and offline checks do not depend on mutable network state |
| Scope/expiry precision | 14 | Package, advisory, paths, severity ceiling, owner, reason, and short expiry are closed |
| Operational resilience | 10 | Rate limits/outages have bounded privileged handling without bypass |
| Auditability | 9 | Canonical projection/digest and refresh history show exactly what was approved |
| Maintainer usability | 6 | Creation, refresh, renewal, and removal are documented and testable |
| Churn/scope | 3 | Workflow and record additions remain proportionate |

Authenticity and fail-closed behavior outweigh the convenience of a URL or
merged approval record that can become stale immediately.

### Scoring

| Option | Authentic (23) | Closed (19) | Offline (16) | Scope (14) | Resilience (10) | Audit (9) | Usability (6) | Churn (3) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. URL syntax only | 1 | 1 | 5 | 3 | 5 | 2 | 5 | 5 | 55.4 |
| 2. Live every run | 5 | 5 | 0 | 5 | 1 | 4 | 2 | 2 | 68.8 |
| 3. Offline record + live verifier | 5 | 5 | 5 | 5 | 5 | 5 | 4 | 3 | **97.6** |
| 4. No exceptions | 5 | 5 | 5 | 5 | 2 | 5 | 0 | 5 | 88.0 |
| 5. Signed file only | 3 | 2 | 5 | 4 | 5 | 4 | 2 | 2 | 69.4 |
| 6. Issue body only | 5 | 4 | 0 | 5 | 1 | 3 | 2 | 3 | 63.8 |
| 7. Label only | 3 | 2 | 1 | 0 | 3 | 2 | 4 | 4 | 41.4 |
| 8. Security advisory | 4 | 4 | 0 | 4 | 2 | 4 | 1 | 1 | 57.8 |
| 9. Review only | 3 | 2 | 5 | 4 | 5 | 4 | 4 | 5 | 73.6 |

The split design retains current live authorization without making routine
untrusted checks flaky or overprivileged.

### Selected resolution

Select **option 3: deterministic offline exception records plus a fail-closed
privileged live verifier**.

Keep `npm-audit-exceptions.json` empty when no exception is required. Each
exception must use a closed schema containing stable `ExceptionId`, exact
package/advisory identity, vulnerable range, maximum severity, dependency-type
and canonical root-to-node path set, reason, owner login, `ApprovedAt`,
`ExpiresAt` (maximum 30 days), and an issue record with the fixed repository,
number, numeric ID, node ID, canonical URL, state, sorted labels/assignees,
`UpdatedAt`, `FetchedAt`, REST API version, and SHA-256 of that canonical
projection. It must not copy arbitrary issue title/body/comments into evidence.

The ordinary pull-request/local validator is network-free. It validates schema,
scope, path coverage, issue/repository identity shape, canonical digest, clock
rules from F28, and freshness: live evidence is at most 24 hours old and the
exception has not expired. Stale or invalid records fail and cannot suppress a
finding.

Add a read-only scheduled/manual/live-check path with top-level
`permissions: {}` and only its verifier job granted `contents: read` and
`issues: read`. For each exception it performs one bounded versioned
`GET /repos/{owner}/{repo}/issues/{number}` request and requires HTTP 200,
the immutable IDs/repository/number to match, no `pull_request` member,
`state=open`, exact `security-audit-exception` label, and the declared owner in
assignees. A changed `updated_at` requires regeneration/review of the canonical
record. Authentication, network, 403/404/429, malformed response, rate-limit,
or stale-state failure is terminal; retries honor `Retry-After` with a small
bounded attempt count and never reuse a response past freshness.

Document an explicit create/refresh/renew/remove procedure: a maintainer opens
and assigns the tracking issue, applies the policy label, uses the live tool to
generate the projection, reviews exact scope/expiry, and merges the record.
Renewal repeats live verification and review; closing/removing the issue first
requires removing or replacing the exception. Release evidence includes a
fresh successful live check. The F26 catalog injects every HTTP/state mismatch
through a transport adapter without contacting GitHub.

## F28 — Production clock observation and time-policy authority

### Options

1. **Keep caller-supplied `now` in production.** Reuse the pure validator API
   for CLI/integration calls by passing a timestamp argument or object.
2. **Split production and fixture time APIs.** Production reads the system
   clock exactly once inside the policy-bound entry point; a distinctly named
   pure fixture API accepts synthetic time.
3. **Read `NOW`/`SOURCE_DATE_EPOCH` from the environment.** Easy deterministic
   CI, but any caller can revive an expired exception.
4. **Use workflow expression time.** Pass `github.run_started_at` or a generated
   workflow value to the CLI; useful evidence, but still caller plumbing and
   unavailable locally.
5. **Use the live GitHub response `Date` header.** Server-origin time is strong
   for the privileged verifier but unavailable to offline checks and potentially
   absent on failure.
6. **Use issue `updated_at` or commit time.** Immutable-ish repository evidence,
   but neither represents the evaluation instant.
7. **Use a monotonic clock.** Correct for durations within one process, not
   absolute UTC expiry.
8. **Remove time-based expiry.** Rely only on issue state/manual revocation,
   allowing unattended exceptions to persist.
9. **Use signed trusted time.** Maximum authenticity but requires another
   network/service/trust system disproportionate to this repository.

The chosen design must specify parsing, single-read semantics, leap/clock-skew
bounds, `ApprovedAt ≤ FetchedAt ≤ now < ExpiresAt`, and production rejection of
every alternate time source.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Production-time authenticity | 24 | The evaluator itself observes one current clock instant, not caller policy data |
| Expiry fail-closed behavior | 21 | Malformed/skewed/expired/future records cannot be made valid through an override |
| Fixture completeness | 17 | Boundary, equality, skew, malformed, and rollover cases are pure deterministic inputs |
| Cross-surface consistency | 14 | Offline CLI, live verifier, workflow, and evidence share one UTC rule |
| Operational availability | 10 | Local/offline evaluation needs no additional network time authority |
| Evidence clarity | 8 | One canonical observed instant and source category are recorded without ambiguity |
| Implementation/churn | 6 | Uses stable runtime primitives with a small test seam |

Authenticity and expiry correctness carry 45%; testability is preserved through
an explicit non-production seam rather than a production override.

### Scoring

| Option | Authentic (24) | Closed (21) | Fixtures (17) | Consistent (14) | Available (10) | Evidence (8) | Cost (6) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Caller `now` | 0 | 0 | 5 | 3 | 5 | 2 | 5 | 44.6 |
| 2. Bound production/pure fixture | 5 | 5 | 5 | 5 | 5 | 5 | 5 | **100.0** |
| 3. Environment time | 1 | 0 | 5 | 3 | 5 | 3 | 5 | 51.0 |
| 4. Workflow time | 2 | 2 | 4 | 3 | 1 | 3 | 4 | 51.6 |
| 5. GitHub response date | 5 | 5 | 4 | 2 | 0 | 5 | 2 | 74.6 |
| 6. Issue/commit time | 2 | 1 | 4 | 2 | 5 | 2 | 4 | 51.0 |
| 7. Monotonic clock | 1 | 1 | 4 | 1 | 5 | 1 | 4 | 41.8 |
| 8. No expiry | 0 | 0 | 1 | 2 | 5 | 1 | 5 | 26.6 |
| 9. Trusted-time service | 5 | 5 | 3 | 4 | 0 | 5 | 0 | 74.4 |

The split API is the only option with both an authentic production instant and
unrestricted deterministic time-edge testing.

### Selected resolution

Select **option 2: a policy-bound production clock and separate pure fixture
API**.

The production audit entry point accepts no time argument, option, stdin field,
environment variable, policy file, or imported caller time. At its start it
calls `Date.now()` exactly once, requires a finite integer millisecond value
within the JavaScript date range, constructs one canonical UTC instant with
exactly millisecond precision, and passes only that captured instant through
schema, freshness, and expiry evaluation. The result records
`ObservedAtUtc` and `ClockSource=SystemUtc`; it does not read the clock again.

Export a conspicuously named `evaluateTimePolicyForFixture(record, nowMs,
policy)` pure function for the F26 tests. Production code must call a separate
zero-parameter wrapper bound to the frozen policy. Structural validation
rejects CLI arguments, environment controls, file inputs, direct fixture-API
imports, or multiple clock reads on production paths.

Use closed ISO 8601 UTC strings of form `YYYY-MM-DDTHH:mm:ss.sssZ`; reject
offsets, missing milliseconds, leap-second spelling, noncanonical equivalents,
and invalid calendar values. Enforce:

`ApprovedAt ≤ FetchedAt ≤ ObservedAtUtc < ExpiresAt`,
`ExpiresAt - ApprovedAt ≤ 30 days`, and
`ObservedAtUtc - FetchedAt ≤ 24 hours`.

Permit at most five minutes of future skew for live response/server timestamps
only while generating a record; ordinary offline validation never moves its
clock backward and fails a record whose `FetchedAt` is in its future. The live
verifier captures its own system instant under the same rule and records the
GitHub HTTP `Date` only as corroborating evidence, not as policy time.

## F29 — Canonical Node-policy case manifest

### Options

1. **Keep cases inline in issue prose and test source.** Do not add a tracked
   case artifact.
2. **Add one authoritative
   `.github/workflows/node-policy-cases.json`.** Give every raw version/policy
   case a namespaced ID, semantic key, input, expected category, and consumer
   requirements.
3. **Reuse the npm-audit case manifest.** Put Node policy and audit cases in one
   broad P3 catalog.
4. **Use test-framework parameter arrays.** Make executable test code the
   source of truth without a language-neutral manifest.
5. **Generate version cases algorithmically from the range.** Test floors,
   ceilings, and nearby patches with loops but omit an enumerated reviewed
   inventory.
6. **Use a standard semver package test suite.** Rely on dependency behavior
   rather than the repository's finite-major/canonical-string policy.
7. **Add separate CLI and pure-API manifests.** Model injection and production
   behavior independently, risking duplicate semantic expectations.
8. **Use snapshots of CLI output.** Record end-to-end text while leaving
   policy-to-case coverage implicit.

Relevant permutations are types, empty/whitespace/sign/prefix/build/prerelease,
leading zeros/component count/large components, both exact floors, interior
patches, major ceilings/gaps/future majors, policy mutation, real CLI/no-arg,
unexpected argument, and production-import structure.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Policy boundary coverage | 22 | Canonical/malformed/floor/ceiling/major and policy-mutation cases are explicit |
| Requirement traceability | 20 | Stable IDs and semantic keys map each rule to exact expected categories |
| Consumer consistency | 17 | Pure API, real CLI, hook, lint import, and workflow prove the same catalog/policy |
| Drift detection | 15 | Structural checks reject orphan, duplicate, unused, or expectation-divergent cases |
| Deterministic portability | 10 | Language-neutral inputs replay identically on both selected runtime cells |
| Review usability | 8 | A reviewer can understand support boundaries without reading test control flow |
| Maintenance effort | 5 | Updating a finite tuple changes one obvious case source |
| File/churn cost | 3 | Adds minimal artifact complexity |

Boundary coverage and cross-consumer truth outweigh saving one small JSON file.

### Scoring

| Option | Coverage (22) | Trace (20) | Consumers (17) | Drift (15) | Portable (10) | Review (8) | Maintain (5) | Cost (3) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Inline prose/source | 4 | 2 | 2 | 1 | 3 | 3 | 2 | 5 | 51.2 |
| 2. One Node case manifest | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 4 | **99.4** |
| 3. Combined broad P3 catalog | 5 | 4 | 4 | 4 | 5 | 2 | 2 | 2 | 80.0 |
| 4. Test arrays | 5 | 3 | 3 | 3 | 3 | 2 | 3 | 5 | 68.4 |
| 5. Generated cases | 4 | 2 | 3 | 3 | 5 | 2 | 4 | 5 | 65.0 |
| 6. Semver suite | 3 | 1 | 2 | 2 | 4 | 1 | 4 | 4 | 46.0 |
| 7. Separate manifests | 5 | 4 | 3 | 3 | 5 | 4 | 2 | 1 | 76.2 |
| 8. CLI snapshots | 3 | 2 | 2 | 2 | 3 | 2 | 2 | 4 | 47.6 |

One focused catalog supplies a common proof object for the pure and production
surfaces without mixing unrelated audit-report cases.

### Selected resolution

Select **option 2: add one authoritative
`.github/workflows/node-policy-cases.json`**.

The versioned closed schema gives each case a unique `CaseId` in the
`PS-P3-NODE-*` namespace, a unique stable `SemanticCase`, raw JSON input type
and value, expected normalized version or null, expected category/exit class,
covered requirement keys, and applicable consumers (`PureApi`, `RealCli`,
`HookStructure`, `LintImport`, `WorkflowCell`). Unknown fields, duplicate
IDs/semantic keys, absent requirements, cases no consumer executes, and
consumer-specific expected-result forks fail validation.

The minimum manifest includes positive canonical values at each exact floor,
interior patch, and final representable boundary below majors 23 and 25;
negative canonical major gaps and future 26; and malformed non-string, empty,
whitespace, `v`/sign prefixes, missing/extra components, leading zeros,
prerelease/build metadata, exponent/hex/Unicode digits, overflow components,
embedded NUL/newline, and valid version plus trailing data. Separate structural
cases mutate each frozen policy field, pass unexpected CLI arguments, attempt
environment/file overrides, import the fixture API from production, and make
multiple observed-version reads.

The pure test runner consumes every synthetic value on both exact Node cells.
The real CLI cannot inject versions; it proves the current process's one
matching catalog semantic and rejects every argument. Hook/lint/workflow
structural checks consume their manifest entries without pretending to run an
unsupported real Node binary. If F22 re-resolution changes a floor or cell,
the policy and this catalog change atomically in the same lock-producing
commit; issue prose references the catalog instead of maintaining a duplicate
row-by-row table.

## F30 — Ambient npm/Corepack configuration and invocation policy

### Options

1. **Inherit the caller environment/configuration.** Invoke `corepack npm` and
   rely on project defaults plus CI conventions.
2. **Set a few documented environment values.** Pin registry and strict mode
   but leave unknown `npm_config_*`, Corepack credentials, config files, cache,
   proxies, and Node options inherited.
3. **Use one closed dependency-free invocation wrapper.** Build a case-insensitive
   sanitized child environment, fixed Corepack/npm arguments, empty user/global
   config files, validated project config, fixed roots, and command-specific
   network/cache/script policy.
4. **Use only CLI flags.** Put every npm option on command lines but leave
   Corepack and process-level environment/config resolution untouched.
5. **Use a committed `.npmrc` only.** Make settings reviewable, but higher
   priority environment/user configuration can still override it.
6. **Run in a digest-pinned container.** Isolate host configuration strongly,
   but duplicate the exact Node/Corepack/npm supply tuple and complicate local
   hook parity.
7. **Unset only known-dangerous variables.** Maintain a denylist of current
   bypasses, accepting future controls and casing/alias variants.
8. **Allow a caller-supplied config/root for enterprise proxies.** Improve
   customization but let the caller alter registry, auth, scripts, dependency
   surface, or audit threshold.
9. **Run bare npm after Corepack preparation.** Resolve the pinned manager once
   and then trust PATH for subsequent commands.

The environment matrix includes case variants and empty/nonempty values for
every `npm_config_*`/`COREPACK_*`, user/global/project config, registry/auth,
proxy/CA, `NODE_OPTIONS`, `NODE_ENV`, cache warmth, offline/online operation,
workspaces/includes/scripts, and PATH/executable substitution.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Policy-bypass resistance | 23 | Ambient config cannot disable integrity/project checks or weaken tree/audit rules |
| Reproducible dependency surface | 20 | Producer and both cells resolve/install/audit the same closed graph semantics |
| Credential/registry safety | 16 | No inherited auth or registry substitution crosses the wrapper boundary |
| Executable identity | 13 | The exact running Node invokes its bundled, verified Corepack package without PATH ambiguity |
| Cross-platform/local parity | 10 | Windows/Linux and local/CI share one wrapper and normalized config model |
| Network/enterprise usability | 8 | Explicit network modes and allowlisted proxy/CA transport remain possible without policy override |
| Evidence/testability | 7 | Effective settings, identities, and hostile ambient fixtures are provable without secrets |
| Scope/churn | 3 | Centralization offsets the added wrapper/config surface |

Bypass resistance, graph determinism, and credential safety carry 59%, far
more than the convenience of inheriting a developer's npm setup.

### Scoring

| Option | Bypass (23) | Graph (20) | Credentials (16) | Executable (13) | Platform (10) | Network (8) | Evidence (7) | Scope (3) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Inherit all | 0 | 1 | 0 | 2 | 4 | 5 | 1 | 5 | 29.6 |
| 2. Set a few values | 2 | 2 | 1 | 3 | 4 | 5 | 2 | 5 | 50.0 |
| 3. Closed wrapper | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 4 | **99.4** |
| 4. CLI flags only | 3 | 4 | 2 | 3 | 4 | 5 | 3 | 4 | 66.6 |
| 5. Project `.npmrc` only | 2 | 3 | 2 | 2 | 5 | 5 | 3 | 5 | 58.0 |
| 6. Pinned container | 5 | 5 | 5 | 4 | 1 | 2 | 4 | 0 | 80.2 |
| 7. Denylist | 2 | 3 | 2 | 3 | 4 | 4 | 3 | 5 | 57.0 |
| 8. Caller config | 1 | 2 | 0 | 3 | 4 | 5 | 2 | 5 | 42.2 |
| 9. Bare npm | 3 | 4 | 3 | 1 | 4 | 4 | 2 | 5 | 62.2 |

The closed wrapper is the only option that simultaneously controls resolution,
manager identity, graph behavior, registry/auth, and audit semantics.

### Selected resolution

Select **option 3: centralize every package operation in
`.github/workflows/Run-NpmPolicy.mjs`** and add a minimal validated project
`.npmrc`.

The production wrapper accepts one closed operation enum (`ci`, `audit`,
`lock-noop`, `run-lint`, or `run-test`) from trusted internal imports—not
arbitrary executable/arguments/config—and derives the repository, temporary,
config, and cache roots itself. It invokes `process.execPath` with the ordinary
non-link bundled Corepack entry point at the fixed relative Node-distribution
path, verifies the bundled package version equals the F22 cell, then passes
`npm` and the fixed operation vector. It never resolves `npm`, `npx`, a
Corepack shim, or an alternate Node through PATH.

Build the child environment from a closed allowlist of required OS/process
variables. Remove case-insensitively every inherited `npm_config_*`,
`COREPACK_*`, `NODE_OPTIONS`, `NODE_ENV`, npm auth/token/password/cert/key
value, and manager/path override. Then set:

- `COREPACK_ENABLE_STRICT=1`, `COREPACK_ENABLE_PROJECT_SPEC=1`,
  `COREPACK_ENV_FILE=0`, `COREPACK_DEFAULT_TO_LATEST=0`,
  `COREPACK_ENABLE_UNSAFE_CUSTOM_URLS=0`,
  `COREPACK_ENABLE_DOWNLOAD_PROMPT=0`, a fresh job-owned `COREPACK_HOME`, and
  exact `COREPACK_NPM_REGISTRY=https://registry.npmjs.org`; leave
  `COREPACK_INTEGRITY_KEYS` unset so bundled trusted keys remain authoritative,
  and reject any credential-bearing Corepack variable;
- `COREPACK_ENABLE_NETWORK=1` only for the closed install/audit/manager-fetch
  operations and `0` for already hydrated lint/test/no-op verification; and
- fixed empty ordinary user/global npmrc files through exact CLI
  `--userconfig`/`--globalconfig` paths, plus fresh fixed-per-invocation cache.

The tracked root `.npmrc` is a closed, comment-free, credential-free set of
tree-shaping values shared by lock production and `npm ci`; structural
validation rejects unknown/duplicate/interpolated/scoped-registry/auth keys.
Every operation additionally pins applicable CLI settings: official HTTPS
registry, workspaces false, includes for prod/dev/optional/peer, strict peer
behavior, install links, audit threshold low, scripts explicitly on only for
the separately reviewed lifecycle test and off for clean CI dependency
installation, no fund/update notifier/progress/color, noninteractive mode,
and package-lock-only audit.

Allow only `HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY`, and an explicitly reviewed
CA-file path as transport inputs; validate their scheme/path and never record
secret values. They cannot alter registry, auth, dependency, script, audit, or
Corepack policy. Evidence records operation, Node/Corepack/npm identities,
argument/config digests, nonsecret proxy-presence booleans, cache mode, and
effective allowlisted npm config. Fixtures seed hostile values in every casing,
user/global/project config, PATH, warm cache, and weakening Corepack control
and prove identical effective policy or a closed rejection.

## F31 — Reduce repeated contracts without weakening issue implementability

### Options

1. **Keep every issue fully self-contained.** Repeat path, schema, workflow,
   action, validation, and evidence contracts wherever they are relevant.
2. **Centralize all detail in one planning artifact.** Make issue bodies short
   pointers to an external master specification.
3. **Assign canonical ownership and use exact landed-contract handoffs.** Each
   issue fully specifies only its introduced/changed contract; successors name
   predecessor issue/PR/commit/path/interface and describe their delta plus
   local acceptance criteria.
4. **Use shared tracked policy manifests only.** Replace prose repetition with
   JSON contracts, even for rationale, sequencing, and operational procedure.
5. **Collapse P1/P1A/P1B/P2/P3 into one issue.** Eliminate cross-issue
   repetition but lose phased dependency/readiness and review boundaries.
6. **Use reusable issue templates/Markdown includes.** Conceptually share text,
   but GitHub issue bodies do not natively render repository includes as
   immutable inline content.
7. **Leave repetition and add a generated consistency checker.** Mechanically
   compare duplicated blocks without improving review length.
8. **Use terse title-only cross-references.** Remove most detail and rely on
   readers to infer which predecessor contract applies.
9. **Move implementation-ready scripts into issue attachments/gists.** Reduce
   body size but create mutable/external specification authority.

The handoff design must cover a cold implementer opening only one issue, a
successor created before predecessor merge, landed code that differs from the
draft, later contract supersession, and permanent issue/PR/commit identity.

### Evaluation rubric

Use 0–5 scores and `Σ(score / 5 × weight)`.

| Criterion | Weight | Full-credit behavior |
| --- | ---: | --- |
| Cross-issue correctness | 22 | One canonical owner prevents contradictory copies and successors bind exact landed state |
| Standalone implementability | 20 | A cold reader can identify inputs, delta, tests, evidence, and completion from the issue |
| Maintenance/drift control | 18 | A contract change has one normative edit and explicit affected successors |
| Review usability | 14 | Bodies foreground the phase's decisions instead of burying them in copied machinery |
| Audit traceability | 11 | Permanent issue/PR/commit/path/interface identities connect every handoff |
| Phased execution safety | 8 | Readiness and rerun rules handle draft-versus-landed differences |
| Body/authoring efficiency | 5 | Material duplication and size fall substantially |
| Migration churn | 2 | Editing cost has limited influence |

Correctness, implementability, and drift prevention carry 60%; reducing line
count is valuable only when those properties remain intact.

### Scoring

| Option | Correct (22) | Standalone (20) | Drift (18) | Review (14) | Trace (11) | Phases (8) | Efficiency (5) | Churn (2) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1. Repeat everything | 2 | 5 | 0 | 1 | 2 | 3 | 0 | 5 | 42.8 |
| 2. Master artifact | 4 | 0 | 5 | 3 | 3 | 2 | 5 | 2 | 59.6 |
| 3. Canonical owner/landed handoff | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 3 | **99.2** |
| 4. Manifests only | 4 | 2 | 5 | 3 | 4 | 2 | 4 | 2 | 68.8 |
| 5. One issue | 4 | 3 | 4 | 1 | 2 | 0 | 4 | 0 | 55.2 |
| 6. Template/include | 2 | 2 | 3 | 3 | 2 | 2 | 4 | 3 | 48.8 |
| 7. Checker over copies | 4 | 4 | 3 | 1 | 3 | 3 | 0 | 2 | 59.4 |
| 8. Terse references | 4 | 0 | 5 | 4 | 3 | 2 | 5 | 4 | 63.2 |
| 9. External scripts | 2 | 1 | 2 | 3 | 1 | 1 | 4 | 3 | 37.4 |

Canonical ownership plus exact landed handoffs removes contradiction risk while
preserving all information a phase implementer actually needs.

### Selected resolution

Select **option 3: one canonical issue owns each contract; successors bind its
exact landed implementation and state only their delta**.

Apply these ownership boundaries:

- **P1** owns repository-path/link rules, source-to-output manifest,
  multi-file replacement semantics, action-input disposition, baseline
  read-only workflow policy, and workflow policy/case manifests.
- **P1A** owns the raw PowerShell boundary, test-scope/context/journal/result
  schemas, lifecycle, candidate case catalog, and harness/evidence projection.
- **P1B** owns only the publication delta: artifact transfer, closed job graph,
  credential projection, single-writer predicate, and isolated real-writer
  evidence. It updates shared policy manifests instead of restating P1's
  validator internals.
- **P2** owns narrow hardened-default content changes and their semantic
  assertions. It invokes the exact landed P1/P1A/P1B tooling and names expected
  interfaces; remove copied path-validation, writer, and evidence-script bodies.
- **P3** owns the superseding Node/Corepack/npm tuple, Node/Husky/audit/runtime
  policies, their case catalogs, and ambient invocation wrapper. It explicitly
  supersedes the named P1 runtime tuple rather than silently duplicating it.

Every successor begins with an execution record naming permanent predecessor
issue URL(s), reviewed PR URL(s), reviewed head/base commits, merge method,
landed commit/tree, and exact contract paths/interface versions. Before coding,
compare those landed values to the assumptions in the issue; a material
difference stops for issue review and reruns affected validation. Title-only
forward references are permitted only where F02 says the later issue does not
yet exist.

Each issue remains standalone by including its own affected files, delta
requirements, closed validation commands/categories, evidence and acceptance
criteria, rollback/ownership, and a compact “consumed landed contracts” table.
It must not paste a predecessor's full implementation pseudocode or duplicate
its exhaustive fixture list. Shared tracked JSON is normative for machine
tables; prose states invariants and ownership. `Validate-WorkflowPolicy.mjs`
also checks declared schema/interface versions so a successor cannot silently
consume a different predecessor contract.

## Issue-integration trace

This trace records where each selected resolution is normative in the revised
slate. Section names, not transient line numbers, are the durable locator.

| Findings | Owning revised issue sections |
| --- | --- |
| F01 | P1 **Slate order and issue identity**; every successor **Consumed landed contract(s)**; every **Handoff** |
| F02 | P2 **Consumed landed contracts** permanent title-only P3 reference; P3 dependency gate owns the backward URL/edge |
| F03 | P1 **Workflow and action policy** read-only contract; P1B **Summary** and **Sole writer** |
| F04–F06 | P1 **Generator contract** fixed authority, four-file transaction, and script metadata |
| F07–F08 | P1 **Frozen P1 supply tuple** and **Workflow and action policy** |
| F09 | P1 **Reciprocal P1↔T1 comparison** |
| F10 | P1 **Offline workflow-policy fixtures** and ten-path **Affected files** |
| F11 | P1A **Public raw-value boundary** |
| F12–F14 | P1A **Closed context and journal schemas**, **Cleanup authority and lifecycle**, and **Affected files** |
| F15–F16 | P1A **Canonical case catalog** and **Result and evidence schema** |
| F17 | P1B **Closed workflow graph** and **Permanent workflow-policy delta** |
| F18–F19 | P1B **Exact external-action contract** |
| F20 | P1B **Honest credential model** |
| F21 | P1B **Real-writer evidence without a copied workflow** |
| F22 | P3 **Frozen runtime and manager policy** |
| F23 | P3 **Node policy authority** |
| F24 | P3 **Husky installer and real hook** |
| F25 | P3 **Raw npm-audit boundary** |
| F26 | P3 **Authoritative audit case catalog** |
| F27–F28 | P3 **Exception and production-time policy** |
| F29 | P3 **Node policy authority** case manifest |
| F30 | P3 **Closed npm/Corepack invocation boundary** |
| F31 | All five issues' ownership, consumed-contract, validation, acceptance, and handoff structure |

## Final validation record

Completed 2026-07-29:

- exactly 31 finding sections exist; each has exactly one Options, Evaluation
  rubric, Scoring, and Selected resolution stage;
- all 31 rubrics are textually distinct, contain at least five criteria, and
  sum to 100 weight;
- every scoring-table total recomputes from its declared weights and every
  selected row is the unique highest-scoring option;
- every selected finding maps to a named revised-issue section above;
- the five issue titles/order are P1, P1A, P1B, P2, P3 and each body remains
  below GitHub's 65,536-byte issue-body limit;
- all seven changed/new task Markdown artifacts are BOM-less UTF-8/LF with no
  carriage-return bytes;
- repository-wide `npm run lint:md` and `npm run lint:md:nested` pass; and
- `git diff --check` passes.
