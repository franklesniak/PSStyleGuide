# PSStyleGuide current findings evaluation

## Evaluation method and scope

This file evaluates every finding in
`docs/planning/artifacts/current-findings.md` serially. No finding is skipped
because it is low-impact, already satisfied, or conditional; in those cases,
“preserve the current state” is evaluated as a real option.

Each section contains:

1. exhaustive practical options and meaningful permutations;
2. a finding-specific weighted rubric;
3. a 1–5 scoring table, where 1 is poor and 5 is excellent;
4. the weighted score out of 100, calculated as
   `sum(weight × score / 5)`; and
5. one implementation-ready selection.

Technical correctness, security, evidence quality, and legitimate operator or
contributor usability receive more weight than churn, implementation
difficulty, or preservation of the current file count.

The prompt names `02PSStyleGuideP3.md`, but the established slate and current
worktree contain `03PSStyleGuideP3.md`; `02PSStyleGuideP2.md` already owns
sequence number 02. This evaluation therefore treats
`03PSStyleGuideP3.md` as the intended P3 target. Creating a duplicate
`02PSStyleGuideP3.md` would make ordering and downstream handoff ambiguous.

## C-01: Rebaseline P1's convergence matrix against final T1

### Options

#### Option A — Retain the current matrix

Leave P1's “stronger same-stream choice” and public-interface-only fixture
claims unchanged. This minimizes editing but knowingly hands downstream
implementers two false statements about current T1.

#### Option B — Correct only the two stale matrix cells

Change Archive identity to a shared held-stream invariant and add the narrow
definition-only production-cleanup exception to Permanent fixtures. This fixes
today's text but supplies no defense against either draft changing again.

#### Option C — Correct the cells and add an implementation-start divergence check

Apply Option B, then require the implementation that starts second to compare
the then-current P1/T1 contracts and record every intentional difference in the
issue/PR evidence. Keep both repositories self-contained and make manifest
names, artifact names, and diagnostics explicitly repository-specific.

#### Option D — Force identity through a shared runtime component

Replace behavioral coordination with a shared module/action consumed by both
repositories. This can prevent drift, but introduces packaging, provenance,
versioning, rollout, cross-edition, and availability dependencies that neither
issue currently designs.

### Evaluation rubric

| Criterion | Weight | Why it matters for this finding |
| --- | ---: | --- |
| Factual accuracy against current T1 | 35 | A downstream issue must not start from a false contract. |
| Preservation of shared security invariants | 25 | Stream identity and cleanup testing protect the artifact boundary. |
| Cold-reader clarity | 15 | The author should understand shared versus repository-specific behavior without reconstructing history. |
| Resistance to future cross-draft drift | 15 | P1 and T1 may be filed or implemented at different times. |
| Repository independence and scope control | 10 | Coordination must not create an undesigned runtime dependency. |

### Scoring

| Option | Accuracy (35) | Security (25) | Clarity (15) | Drift resistance (15) | Independence (10) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Retain | 1 | 1 | 1 | 1 | 5 | 28 |
| B — Correct cells | 5 | 5 | 4 | 2 | 5 | 88 |
| C — Correct plus recheck | 5 | 5 | 5 | 5 | 5 | **100** |
| D — Shared runtime | 5 | 4 | 2 | 4 | 1 | 75 |

### Selected option

Select **Option C**.

In P1:

1. Rewrite Archive identity as a deliberately shared invariant: one retained
   file stream opened with `FileMode.Open`, `FileAccess.Read`, and
   `FileShare.Read`; hash; exact digest comparison; rewind; the only
   `ZipArchive`; continuous lifetime through extraction; deterministic
   disposal.
2. Rewrite Permanent fixtures to say ordinary archive/path cases use the
   production helper's public expansion interface, while one unsafe-cleanup
   case may definition-only load and invoke the exact named production cleanup
   function.
3. Keep filenames, manifests, artifact names, labels, and fixture placement as
   explicit repository-specific choices.
4. Require the implementation that starts second to reread the current other
   issue/merged evidence and record any divergence.
5. State that this comparison creates no runtime or filing dependency.

## C-02: Add a generator-specific convergence contract

### Options

#### Option A — Rely on scattered generator requirements

Keep normalization, encoding, frontmatter, and validation requirements in
their existing sections and assume implementers will infer P1/T1 convergence.

#### Option B — Add a short prose convergence statement

State that both generators should behave equivalently at serialization
boundaries, without defining the compared surfaces or intentional differences.

#### Option C — Add an explicit behavioral generator matrix

Define shared targets for complete-payload normalization, resolved paths,
BOM-less encoding, write primitives, implicit-newline behavior, common
artifact functions, frontmatter principles, script-version policy, repository
text policy, and cross-edition/raw-byte validation. Give repository-specific
values and transforms their own column. Keep implementations local.

#### Option D — Option C plus coordinated private serializer abstractions

Require each repository to introduce an equivalently contracted private
serialization helper so the four write sites do not repeat the primitive.
This reduces local duplication but expands both issues and makes coordination
of function shape part of the initial implementation.

#### Option E — Publish one shared generator library/action now

Centralize the generator or serializer in a third artifact consumed by both
repositories. This maximizes code reuse but adds versioning, provenance,
availability, cross-repository rollout, and compatibility work.

### Evaluation rubric

| Criterion | Weight | Why it matters for this finding |
| --- | ---: | --- |
| Observable generator equivalence | 30 | The user's stated objective is thoughtful generator unification. |
| Cross-edition byte correctness | 25 | Determinism is the primary purpose of P1/T1. |
| Clarity of intentional differences | 20 | PowerShell- and Terraform-specific values must not be erased. |
| Long-term drift detection | 15 | Future changes should expose divergence instead of silently accumulating it. |
| Initial scope and implementation burden | 10 | Churn matters, but less than correctness and maintainability. |

### Scoring

| Option | Equivalence (30) | Correctness (25) | Differences (20) | Drift (15) | Burden (10) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Scattered requirements | 1 | 3 | 1 | 1 | 5 | 38 |
| B — Prose statement | 3 | 4 | 3 | 2 | 5 | 66 |
| C — Behavioral matrix | 5 | 5 | 5 | 5 | 4 | **98** |
| D — Matrix plus private helpers | 5 | 5 | 4 | 5 | 2 | 90 |
| E — Shared package/action | 5 | 5 | 3 | 5 | 1 | 84 |

### Selected option

Select **Option C**.

Add a separate generator convergence matrix to P1 with these rows:

- serialization boundary;
- common Copilot, Chat, and Full artifact functions;
- instructions artifact;
- frontmatter construction;
- script versioning;
- repository text policy; and
- validation/evidence.

For each row, name the shared observable target and the intentional
PSStyleGuide/TerraformStyleGuide difference. State explicitly that unification
currently means algorithms, bytes, failure semantics, and evidence—not a
runtime import or forced line-for-line identity. Do not require a new private
helper in P1; if both implementations later choose one, coordinate it as a
separate design decision.

## C-03: Deterministically test the exact production cleanup function

### Options

#### Option A — Keep outcome-only cleanup requirements

Retain “removed or cleanup failure reported” and rely on ordinary BOM/CR
failures to cover successful cleanup. The unsafe branch remains unexecuted.

#### Option B — Add an indirect workflow cleanup-failure drill

Try to induce a filesystem failure around a complete helper invocation. This
tests an end-to-end path, but timing, permissions, and platform differences can
make the unsafe state nondeterministic and may not prove the exact deletion
algorithm.

#### Option C — Name, journal, and directly test production cleanup

Put cleanup in one named production function, keep an exact ownership journal,
perform a complete pre-deletion safety pass, and permit the harness to load
definitions without running main. A mandatory cross-platform fixture inserts
an unjournaled ordinary child, calls that exact function, and proves retention,
no traversal, and combined diagnostics. Add link/reparse variants only where
the primitive is available.

#### Option D — Make link/reparse substitution the only unsafe fixture

Directly test the production function, but require a link replacement as the
mandatory unsafe state. This is security-relevant but fragile on Windows
runners where link creation may require privileges or a specific primitive.

#### Option E — Redesign around OS directory handles

Replace repeated path validation and the no-competing-writer model with
platform-specific handle-relative deletion. This could narrow races further,
but Windows PowerShell 5.1/Linux portability and implementation complexity
would become a new project.

### Evaluation rubric

| Criterion | Weight | Why it matters for this finding |
| --- | ---: | --- |
| Fail-closed deletion safety | 35 | Cleanup must not turn a primary failure into unsafe recursive deletion. |
| Deterministic executable evidence | 25 | The unsafe branch must run reliably on supported platforms. |
| Identity with production behavior | 20 | A copied test algorithm does not prove the real cleanup path. |
| Diagnostic preservation | 10 | Operators need both the primary cause and retained unsafe state. |
| Cross-platform implementation cost | 10 | Complexity matters after safety and proof are satisfied. |

### Scoring

| Option | Safety (35) | Evidence (25) | Production identity (20) | Diagnostics (10) | Cost (10) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Outcome only | 2 | 1 | 2 | 2 | 5 | 41 |
| B — Indirect drill | 3 | 3 | 2 | 3 | 4 | 58 |
| C — Named function/direct ordinary fixture | 5 | 5 | 5 | 5 | 4 | **98** |
| D — Mandatory link substitution | 5 | 3 | 5 | 5 | 2 | 84 |
| E — OS-handle redesign | 5 | 4 | 4 | 4 | 1 | 81 |

### Selected option

Select **Option C**.

P1 must require:

1. an exact journal containing only the candidate directory and ordinary files
   created by the invocation;
2. one named cleanup function used by the production failure path;
3. archive, entry, and retained file-stream disposal before cleanup;
4. a complete revalidation and immediate-child/journal equality pass before
   the first deletion;
5. individual, nonrecursive file deletion followed by removal of the
   proven-empty directory;
6. immediate stop and retention on any missing, extra, replaced, linked,
   reparse, unreadable, or uncertain state; and
7. preservation of the primary failure plus phase `cleanup`, retained path,
   safely available offending entry, and cleanup exception.

Add one stable mandatory case for an unexpected ordinary child and optional
link/reparse substitution variants where supported. The harness may
definition-only load the function; it must not copy cleanup, add a test switch,
or expose another extraction API.

## C-04: Verify local PowerShell identity inside each child

### Options

#### Option A — Keep executable-name labels

Continue treating `pwsh` as Core 7 and `powershell` as Desktop 5.1 based only
on the resolved command name.

#### Option B — Probe the executable in a separate child

Run a version command first, then start another child with `-File` for the
harness/generator. This catches an obvious wrong executable but does not bind
the reported identity to the process that produced the evidence.

#### Option C — Use an interpolated same-child command string

Build a dynamic `-Command` string that asserts the edition/version and invokes
the target. This couples identity and work, but quoting paths and embedding
values as code create avoidable injection and portability risks.

#### Option D — Use a fixed same-child command with expected values as data

Pass expected edition, version, target path, and helper path through
PSStyleGuide-specific environment variables. A fixed `-Command` prelude reads
and validates them, asserts `$PSVersionTable`, invokes the target in that same
process, and exits nonzero on any failure. The parent checks `$LASTEXITCODE`
immediately and restores every variable in `finally`.

#### Option E — Add a tracked child-bootstrap script

Create another repository script that performs Option D. This is reusable and
testable, but adds a permanent implementation file solely for local validation
when a fixed command is sufficient.

### Evaluation rubric

| Criterion | Weight | Why it matters for this finding |
| --- | ---: | --- |
| Edition/version identity proof | 35 | Evidence must establish Desktop 5.1 or Core 7, not a filename convention. |
| Coupling identity to executed work | 25 | A probe in a different process is indirect. |
| Quoting and data/code separation | 15 | Local paths and values must not become dynamic code. |
| Exit/failure propagation | 15 | The parent must not mistake child startup or target failure for success. |
| Copy/paste usability | 10 | A new contributor should be able to run the validation safely. |

### Scoring

| Option | Identity (35) | Coupling (25) | Data safety (15) | Failure propagation (15) | Usability (10) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Labels | 1 | 1 | 4 | 3 | 5 | 43 |
| B — Separate probe | 3 | 2 | 4 | 4 | 4 | 63 |
| C — Interpolated same-child | 5 | 5 | 2 | 4 | 3 | 84 |
| D — Fixed command/data variables | 5 | 5 | 5 | 5 | 4 | **98** |
| E — Tracked bootstrap | 5 | 5 | 5 | 5 | 2 | 94 |

### Selected option

Select **Option D**.

Rewrite P1's local cross-edition block so each resolved executable starts two
same-child tasks:

1. assert expected edition/version, then run the exact tracked harness against
   the exact helper;
2. assert the same expected edition/version, then run the generator.

Use fixed PSStyleGuide-prefixed environment-variable names for expected
edition, expected major/minor, target, and helper. Reject missing values;
require Desktop exactly 5.1 or Core major 7 before target invocation; write
expected and observed identity into failures; return an explicit nonzero exit;
check it immediately in the parent; and restore/remove all variables in
`finally`. Do not use a separate probe as edition evidence.

## C-05: Require real link coverage on both operating-system families

### Options

#### Option A — Retain unrestricted named skips

Keep stable case-level skip records but allow every link fixture to skip on an
OS family if setup reports unavailable capability or privilege.

#### Option B — Require one real rejection per OS family

Require at least one actual component-or-leaf symbolic-link test on Ubuntu and
one actual component-or-leaf link/reparse test on Windows. Keep narrowly
justified case-level skips for additional unavailable link forms; fail
unexpected setup errors and prohibit platform-wide skips.

#### Option C — Require every link fixture everywhere

Eliminate skips and require ancestor, below-root, leaf, dangling-leaf, and
cleanup-substitution link cases on every runner. Coverage is broad, but Windows
privilege/filesystem differences make the suite brittle.

#### Option D — Replace real links with ZIP external-attribute fixtures

Use symlink-like ZIP metadata as the only cross-platform evidence. This proves
that extraction creates ordinary files, but it does not exercise filesystem
component or leaf indirection.

#### Option E — Build platform-specific privileged link test jobs

Use dedicated Windows/Linux setup and privileges to execute every real link
form. This maximizes coverage but expands workflow permissions, runner
assumptions, and operational cost.

### Evaluation rubric

| Criterion | Weight | Why it matters for this finding |
| --- | ---: | --- |
| Real filesystem-indirection evidence | 35 | The helper claims rejection of links/reparse points in actual paths. |
| Deterministic hosted-runner behavior | 25 | Required CI must be reliable rather than privilege-sensitive. |
| Honest skip semantics | 20 | Missing setup capability must not be reported as passing security coverage. |
| Cross-platform portability | 10 | Both supported OS families need meaningful proof. |
| Workflow/maintenance cost | 10 | Extra privileged jobs should be justified by incremental assurance. |

### Scoring

| Option | Real evidence (35) | Determinism (25) | Skip honesty (20) | Portability (10) | Cost (10) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Unrestricted skips | 1 | 2 | 1 | 5 | 5 | 41 |
| B — One mandatory per family | 5 | 5 | 5 | 5 | 4 | **98** |
| C — Every form everywhere | 5 | 2 | 4 | 2 | 2 | 69 |
| D — Metadata only | 2 | 5 | 5 | 5 | 5 | 79 |
| E — Privileged jobs | 5 | 5 | 5 | 4 | 1 | 90 |

### Selected option

Select **Option B**.

P1 must say that acceptance requires:

- one real component-or-leaf symlink rejection on Ubuntu;
- one real component-or-leaf link/reparse rejection on Windows;
- a stable ID/platform/reason record for any additional skipped form;
- no platform-wide link-fixture skip; and
- a failed cell for unexpected setup failure.

Keep the ZIP external-attribute success case because it proves a different
property: metadata is not restored as a filesystem link.

## C-06: Align or explain pull-request harness placement

### Options

#### Option A — Keep two LF cells without rationale

Retain current behavior and the generic statement that placement may differ.

#### Option B — Keep two LF cells and document the coverage model

Explain that the helper is independent of source fixture EOL, so Ubuntu
PowerShell 7 plus Windows Desktop/Core LF cells provide platform/edition
coverage; CRLF cells test generator EOL equivalence only. Preserve all-four
push-consumer harness execution.

#### Option C — Run the full helper suite in all four Windows PR cells

Match T1's placement exactly and gain redundant EOL-axis executions at the cost
of additional CI minutes and slower feedback.

#### Option D — Move helper tests to dedicated non-matrix jobs

Separate helper platform/edition coverage from generator EOL coverage. This is
conceptually clean but changes workflow topology and dependency wiring more
than the finding requires.

#### Option E — Run extra cells only when helper files change

Use path-sensitive conditional coverage. This reduces cost but complicates
unfiltered PR guarantees and can miss interactions when workflow or runtime
files change.

### Evaluation rubric

| Criterion | Weight | Why it matters for this finding |
| --- | ---: | --- |
| Actual helper coverage sufficiency | 35 | Both platforms/editions and required fixtures must execute. |
| Assurance gained per CI cost | 20 | Redundant EOL-axis runs should provide material evidence. |
| P1/T1 comparability | 20 | Differences should be understandable during coordinated implementation. |
| Downstream workflow clarity | 15 | Job intent should be obvious to a cold reader. |
| Feedback time and runner use | 10 | CI cost is secondary but still operationally relevant. |

### Scoring

| Option | Coverage (35) | Signal/cost (20) | Comparability (20) | Clarity (15) | Runtime (10) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Undocumented two-cell | 4 | 5 | 2 | 1 | 5 | 69 |
| B — Documented two-cell | 5 | 5 | 4 | 5 | 5 | **96** |
| C — Four-cell symmetry | 5 | 2 | 5 | 5 | 2 | 82 |
| D — Dedicated jobs | 5 | 3 | 3 | 4 | 3 | 77 |
| E — Conditional expansion | 4 | 3 | 3 | 2 | 3 | 64 |

### Selected option

Select **Option B**.

Retain P1's Ubuntu plus two-Windows-LF pull-request helper placement. Add a
convergence-matrix note and topology explanation that this is deliberate
platform/edition coverage, not edition × EOL helper coverage. CRLF cells remain
generator-only because the helper consumes constructed ZIP/path fixtures, not
source EOL variants. Keep the harness mandatory in all four push cells and in
the writer whenever it starts.

## C-07: Refresh P2's prerequisite snapshot

### Options

#### Option A — Leave the current snapshot

Allow P2 to describe the pre-correction P1 contract. This is immediately stale
after selected C-01/C-03/C-04/C-05 changes.

#### Option B — Copy final P1 in extensive detail

Duplicate cleanup algorithms, fixtures, local bootstrap, and link rules into
P2. This is explicit but creates a second normative specification that can
drift.

#### Option C — Keep a concise invariant summary plus normative P1 link

After P1 is final, update only the gates P2 genuinely depends on and state that
merged P1 is the implementation source of truth. Add the new held-stream,
named-cleanup/direct-test, mandatory-link, same-child-edition, and exact-pin
invariants without copying algorithms.

#### Option D — Add an executable prerequisite conformance script to P2

Have P2 mechanically inspect the merged workflow/helper before documentation
work begins. This can strengthen evidence but adds a new validator surface and
still needs a human-readable dependency summary.

#### Option E — Remove the snapshot and keep only the P1 link

Avoid all duplication, but make a cold implementer reconstruct which P1
properties are necessary for P2's validation and post-merge expectations.

### Evaluation rubric

| Criterion | Weight | Why it matters for this finding |
| --- | ---: | --- |
| Accuracy against final P1 | 30 | P2 must start only after the actual prerequisite exists. |
| Resistance to copied-contract drift | 25 | P1 remains the normative implementation owner. |
| Cold-start implementer usability | 20 | P2 should expose the gates it relies on. |
| Single source of normative truth | 15 | Algorithms should not have two owners. |
| P2 scope preservation | 10 | Prerequisite text should not reopen generator work. |

### Scoring

| Option | Accuracy (30) | Drift (25) | Usability (20) | Source of truth (15) | Scope (10) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Leave stale | 1 | 1 | 2 | 3 | 5 | 38 |
| B — Copy details | 5 | 2 | 4 | 1 | 2 | 63 |
| C — Concise summary/link | 5 | 5 | 5 | 5 | 5 | **100** |
| D — Conformance script | 5 | 5 | 3 | 4 | 2 | 83 |
| E — Link only | 4 | 5 | 2 | 5 | 5 | 82 |

### Selected option

Select **Option C**.

After P1 revisions are complete, refresh P2's prerequisite bullets to name:

- the shared same-held-stream P1/T1 invariant;
- the journaled named cleanup function and direct fail-closed fixture;
- at least one real link/reparse rejection per OS family;
- the same-child Desktop 5.1/Core 7 local proof; and
- exact approved action tuple validation.

Keep the existing statement that P1 is the source of truth. Do not reproduce
cleanup, path, or child-bootstrap algorithms in P2.

## C-08: Assert Node 24 before P2's local npm commands

### Options

#### Option A — Rely on hosted CI

Let local `npm ci` and lint use any Node on `PATH`; depend on the post-push
workflow for exact Node 24 evidence.

#### Option B — Add a prose prerequisite

Tell the implementer to activate Node 24, but do not make the copyable block
verify it.

#### Option C — Add a simple `node --version` regex

Run the command by name and require output beginning `v24.`. This is better
than prose but does not resolve the exact executable or validate output shape
as carefully as P1.

#### Option D — Reuse P1's resolved-command Node/npm bootstrap

Resolve one `node` and one `npm` application, query
`process.versions.node`, require exactly one major-24 value, set/restore `CI`
around clean installation, and invoke all npm commands through the resolved
npm path with immediate exit checks.

#### Option E — Run validation in a Node 24 container/version manager

Provision a controlled runtime locally. This is reproducible but introduces
another required tool, filesystem/UID concerns, and a validation environment
different from the documented native workflow.

### Evaluation rubric

| Criterion | Weight | Why it matters for this finding |
| --- | ---: | --- |
| Exact runtime evidence | 35 | P2 claims Node 24 compatibility, not generic modern Node success. |
| Consistent executable binding | 20 | Version query and npm work should use the intended toolchain. |
| Environment restoration/failure handling | 15 | Copyable validation must not leak `CI` or ignore native exits. |
| New-developer usability | 20 | Failure should immediately explain the required runtime. |
| P2 scope fit | 10 | The fix should not introduce a new environment platform. |

### Scoring

| Option | Runtime (35) | Binding (20) | Environment (15) | Usability (20) | Scope (10) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Hosted only | 1 | 3 | 3 | 5 | 5 | 58 |
| B — Prose | 2 | 3 | 4 | 5 | 5 | 68 |
| C — Simple query | 4 | 3 | 4 | 4 | 5 | 78 |
| D — P1 bootstrap | 5 | 5 | 5 | 4 | 5 | **96** |
| E — Container/manager | 5 | 5 | 4 | 2 | 2 | 79 |

### Selected option

Select **Option D**.

Replace the opening of P2's generate/lint block with P1's exact local Node 24
bootstrap. Require one Node major-24 result before `npm ci`; run install with
`CI=true` and restore the prior environment value in `finally`; then use the
same resolved npm command for outer and nested lint. Keep the existing
generator, whitespace, and exit-code checks.

## C-09: Remove P2's stale metadata snapshot

### Options

#### Option A — Retain the expired conditional example

Keep `2.24.20260728.0` with its recomputation warning.

#### Option B — Refresh the example to today's baseline/date

Provide a new concrete value. It will become stale again when implementation
date or target metadata changes.

#### Option C — Remove the snapshot

Keep only the normative target-branch/current-UTC algorithm and acceptance
requirements.

#### Option D — Replace values with placeholders

Show `Major.Minor.YYYYMMDD.Revision` and `<current UTC date>`. This illustrates
shape but duplicates the already clear numbered algorithm.

#### Option E — Add a copyable metadata calculator

Compute the new version from parsed target content and UTC time. This can be
precise, but version-policy parsing and concurrent target changes still need
human finalization and increase P2's validator surface.

### Evaluation rubric

| Criterion | Weight | Why it matters for this finding |
| --- | ---: | --- |
| Final metadata correctness | 35 | The committed version/date must reflect the actual target and UTC date. |
| Resistance to accidental copying | 25 | A concrete stale value is operationally hazardous. |
| Normative algorithm clarity | 20 | The author must understand Minor/Build/Revision behavior. |
| Implementer convenience | 10 | Examples or automation can reduce calculation effort. |
| Editorial simplicity | 10 | This is a documentation issue, so unnecessary machinery has a cost. |

### Scoring

| Option | Correctness (35) | Copy safety (25) | Clarity (20) | Convenience (10) | Simplicity (10) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Retain | 3 | 1 | 3 | 5 | 5 | 58 |
| B — Refresh concrete value | 2 | 2 | 3 | 5 | 4 | 54 |
| C — Remove snapshot | 5 | 5 | 5 | 3 | 5 | **96** |
| D — Placeholders | 4 | 4 | 4 | 4 | 4 | 80 |
| E — Calculator | 5 | 5 | 4 | 3 | 2 | 86 |

### Selected option

Select **Option C**.

Delete the drift-only snapshot paragraph. Preserve the six normative steps:
reread target Version/Last Updated, increment Minor, use current UTC Build/date,
reset or increment Revision correctly, recompute after target/date drift, and
commit metadata with the source change.

## C-10: Resolve P3's Node-engine and staged-hook mismatch

### Options

#### Option A — Keep P3's three-file scope and Node 20 guards

Install the selected dependency tree without changing the hook/runtime
contract. With the known candidate, explicitly admitted Node 20 contributors
would run unsupported packages.

#### Option B — Select an older Node-20-compatible dependency tree

Constrain upgrades to packages that preserve Node 20. This improves contributor
compatibility, but may leave known advisory paths or force outdated direct
versions despite Node 20 being end-of-life.

#### Option C — Support the selected package minimum locally and Node 24 in CI

Expand P3 to `.husky/pre-commit` and `lint-staged-markdown.mjs`; set both
guards/messages and `package.json.engines.node` to the maximum minimum required
by the selected direct tree (currently `>=22`); retain exact Node 24 in the
workflow/full-corpus validation; and test the selected minimum plus Node 24.

#### Option D — Require Node 24 everywhere

Expand the same files but set every local and package guard to `>=24`. This
creates one simple policy and matches hosted validation, but excludes supported
Node 22 contributors unnecessarily if the final package tree still supports
22.

#### Option E — Create a separate Node-policy prerequisite

File and merge a hook/runtime-policy issue before P3, then rebaseline P3.
Separation may aid review but lengthens the dependency chain for a compatibility
change inseparable from the selected package engine floor.

### Evaluation rubric

| Criterion | Weight | Why it matters for this finding |
| --- | ---: | --- |
| Runtime/package technical correctness | 30 | Admitted runtimes must satisfy every selected package engine. |
| Contributor usability across supported Node LTS lines | 25 | Local hooks should not exclude a supported runtime without benefit. |
| One coherent policy across guards/manifest/workflow | 20 | Conflicting floors create confusing failures. |
| Executable minimum-and-hosted evidence | 15 | Declared compatibility must be tested, not inferred. |
| Issue-chain and file-scope cost | 10 | Scope matters only after compatibility is coherent. |

### Scoring

| Option | Correctness (30) | Usability (25) | Policy (20) | Evidence (15) | Scope (10) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Keep Node 20 guards | 1 | 5 | 1 | 1 | 5 | 48 |
| B — Preserve Node 20 tree | 2 | 5 | 3 | 2 | 4 | 63 |
| C — Selected minimum + Node 24 | 5 | 5 | 5 | 5 | 3 | **96** |
| D — Node 24 everywhere | 5 | 3 | 5 | 5 | 3 | 86 |
| E — Separate prerequisite | 5 | 4 | 5 | 5 | 1 | 87 |

### Selected option

Select **Option C**.

Expand P3's affected files to include `.husky/pre-commit` and
`.github/workflows/lint-staged-markdown.mjs`. At implementation time:

1. determine the highest minimum Node major required by the final selected
   direct dependency tree;
2. require that major consistently in both guards/messages and
   `package.json.engines.node`;
3. for the known 0.23.2/0.41.1 candidate, use Node `>=22`;
4. retain exact Node 24 for the hosted workflow and full-corpus validation;
5. run staged integration evidence at the selected minimum and Node 24; and
6. fail/rebaseline if implementation-time releases raise the engine floor.

Do not knowingly install an unsupported tree or keep an end-of-life Node 20
policy merely to preserve three-file scope.

## C-11: Execute the staged-lint API contract

### Options

#### Option A — Trust static upstream API inspection

Rely on the presence of exported `main` and `nonFileContents` in 0.23.2.
This does not exercise repository configuration, path conversion, Git index
reads, diagnostics, or exit mapping.

#### Option B — Require manual spot checks

Have the implementer stage one good and one bad file in their working clone.
This risks disturbing the implementation index and is neither repeatable nor
complete.

#### Option C — Put a temporary test recipe only in P3

Provide a copyable isolated-worktree script in the issue description. It can
cover all cases without a permanent file, but the regression suite disappears
after implementation and hosted CI cannot call the exact same test later.

#### Option D — Add a tracked cross-platform staged-lint harness

Create `.github/workflows/Test-LintStagedMarkdown.ps1`. It builds a disposable
clone or isolated index, invokes the exact production
`lint-staged-markdown.mjs`, and covers no files, compliant, lint-invalid, index
versus working-tree divergence, and startup-failure distinction. Invoke it in
the Node 24 Markdown workflow and require local Windows plus selected-minimum
Node evidence.

#### Option E — Refactor staged lint into a library with unit tests

Split Git/index and markdownlint integration into exported functions and adopt
a JavaScript test framework. This can improve unit isolation but changes the
production design and adds test dependencies during a security update.

### Evaluation rubric

| Criterion | Weight | Why it matters for this finding |
| --- | ---: | --- |
| Proof of real Git-index behavior | 30 | The staged hook exists specifically to lint index bytes. |
| Durable regression protection | 25 | A future dependency update can break the same API again. |
| Windows/Linux and Node-policy coverage | 20 | The hook is contributor-facing across platforms/runtimes. |
| Isolation from the implementation index | 15 | Validation must not corrupt or rewrite the change being reviewed. |
| Added production/test complexity | 10 | New files are justified only by lasting evidence value. |

### Scoring

| Option | Real behavior (30) | Durability (25) | Platforms (20) | Isolation (15) | Complexity (10) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Static inspection | 1 | 1 | 2 | 5 | 5 | 44 |
| B — Manual spot checks | 3 | 1 | 3 | 3 | 5 | 54 |
| C — Temporary recipe | 5 | 2 | 4 | 5 | 4 | 79 |
| D — Tracked harness | 5 | 5 | 5 | 5 | 2 | **94** |
| E — Library/unit refactor | 5 | 5 | 5 | 4 | 1 | 89 |

### Selected option

Select **Option D**.

Expand P3 to add
`.github/workflows/Test-LintStagedMarkdown.ps1` and modify
`.github/workflows/markdownlint.yml` only enough to run that tracked harness
after the clean install under hosted Node 24.

The harness must:

1. declare/verify its supported PowerShell runtime and resolve the exact
   production script;
2. create a unique test-owned disposable repository beneath a safe temporary
   parent;
3. copy only the production script/config/package context required or use an
   isolated worktree/index without touching the implementation index;
4. prove no staged Markdown returns 0;
5. prove compliant staged Markdown returns 0;
6. prove a known Markdown violation returns lint exit 1 with exact rule/path,
   not startup exit 2;
7. make working-tree content differ from staged content and prove staged bytes
   are authoritative;
8. check every Git/Node exit immediately; and
9. remove only its own temporary state in `finally`.

Run the exact harness in Ubuntu CI on Node 24 and locally on Windows at the
selected minimum Node major and Node 24. If practical, also run local Ubuntu
minimum-major evidence; at minimum the production package's engine and
selected-minimum install must be separately proved.

## C-12: Replace the nonexistent negative-fixture claim

### Options

#### Option A — Keep referring to existing negative samples

Leave the acceptance criterion unverifiable because no such tracked file
exists.

#### Option B — Add permanent outer and nested negative sample files

Create reviewed fixtures under `samples`. They are visible and reusable, but
the repository's normal all-Markdown lint commands would need explicit
exclusions or the tracked repository would fail by design.

#### Option C — Generate deterministic negatives inside the tracked harness

Extend the selected C-11 harness to create test-owned outer and fenced/nested
Markdown violations, run the exact production commands/APIs, assert exact
rules and context, and remove fixtures in `finally`. Keep the existing positive
sample corpus unchanged.

#### Option D — Put temporary-negative commands only in the issue

Generate/remove deterministic files during implementation without a tracked
harness. This proves the upgrade once but loses future regression evidence.

#### Option E — Mutate an existing positive sample temporarily

Edit/stage/restore a positive fixture. This reduces new fixture design but risks
worktree/index contamination and couples negative evidence to restoration
correctness.

### Evaluation rubric

| Criterion | Weight | Why it matters for this finding |
| --- | ---: | --- |
| Exact expected-failure semantics | 30 | Startup failure must not masquerade as lint rejection. |
| Outer and nested surface coverage | 25 | P3 promises both lint paths remain fail-closed. |
| Deterministic repeatability | 20 | The same rule/context should fail on every validation run. |
| Repository corpus cleanliness | 10 | Permanent intentionally-invalid Markdown complicates normal lint. |
| Future regression value | 15 | Dependency updates can change rules, APIs, or diagnostics later. |

### Scoring

| Option | Failure proof (30) | Surface coverage (25) | Repeatability (20) | Corpus (10) | Durability (15) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Keep claim | 1 | 1 | 1 | 5 | 1 | 28 |
| B — Permanent negatives | 5 | 5 | 5 | 2 | 5 | 94 |
| C — Harness-generated negatives | 5 | 5 | 5 | 5 | 5 | **100** |
| D — Issue-only temporaries | 5 | 5 | 3 | 5 | 2 | 83 |
| E — Mutate positives | 3 | 3 | 2 | 4 | 2 | 55 |

### Selected option

Select **Option C**.

Use the tracked C-11 harness to create and clean deterministic temporary:

- outer Markdown with one selected enabled rule violation; and
- nested fenced Markdown with one selected enabled nested rule violation.

Require the exact fixture path, rule ID, nested file/depth context, and lint
exit 1. Treat import/config/startup exit 2 or missing diagnostics as failure.
Run the existing positive sample corpus and require success. Remove every
reference to “existing negative fixtures” unless permanent negative files are
actually added later.

## C-13: Define how P3 supersedes P1/P2 intermediate gates

### Options

#### Option A — Keep “P1 and P2 validation remain green”

Leave an impossible blanket acceptance statement even though P3 intentionally
changes P1's exact Dependabot content and a different affected-path set.

#### Option B — Narrow the sentence only

Say “nonsuperseded behavior remains green” without naming the superseded gates
or mechanically validating the final governance file.

#### Option C — Add an explicit supersession contract and exact final validator

List preserved behavioral gates, identify P1's one-entry Dependabot and earlier
implementation path sets as superseded, define P3's final affected set, and
compare normalized `.github/dependabot.yml` content with exactly the two
approved review-only entries.

#### Option D — Move npm Dependabot governance to a later P4

Keep P3 dependency-only so P1's one-entry file survives P3. This restores one
intermediate assertion but separates remediation from the update governance
intended to prevent recurrence.

#### Option E — Parse Dependabot YAML semantically

Use a YAML parser/schema to validate two logical entries regardless of
formatting. This is flexible but adds a parser dependency or environment
assumption to the security validation and can accept formatting/extra-key
variation beyond the exact intended file.

### Evaluation rubric

| Criterion | Weight | Why it matters for this finding |
| --- | ---: | --- |
| Truthfulness of final acceptance | 30 | An issue must not require mutually exclusive states. |
| Mechanical governance proof | 25 | The final update channels must be exact and review-only. |
| Preservation of nonsuperseded behavior | 20 | P3 must not regress generator/workflow/lint contracts. |
| Reviewer auditability | 15 | Preserved versus replaced gates should be explicit. |
| Issue-sequence/scope efficiency | 10 | Extra issues or dependencies should deliver material value. |

### Scoring

| Option | Truth (30) | Governance proof (25) | Regression (20) | Auditability (15) | Scope (10) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Blanket green | 1 | 1 | 2 | 1 | 5 | 32 |
| B — Wording only | 4 | 2 | 4 | 3 | 5 | 69 |
| C — Supersession + exact validator | 5 | 5 | 5 | 5 | 4 | **98** |
| D — Move to P4 | 5 | 5 | 4 | 4 | 1 | 85 |
| E — Semantic YAML parser | 5 | 4 | 5 | 4 | 2 | 86 |

### Selected option

Select **Option C**.

P3 must explicitly state:

- P1/P2 generator, artifact, permission, immutable-action, helper/harness,
  source/generated no-drift, and lint-behavior gates remain;
- P3 supersedes P1's exact-one-Dependabot-entry assertion;
- P3's final affected-path set supersedes P1/P2's implementation-time path
  sets only for P3 implementation; and
- P2 source/generated bytes remain unchanged.

Add a normalized ordinal comparison requiring exactly:

1. weekly review-only `github-actions` updates for `/`; and
2. weekly review-only npm updates for `/.github/workflows`.

Reject missing/duplicate/extra entries, different directories/ecosystems or
schedules, and auto-merge/auto-approval in the changed scope.

## C-14: Structure residual-advisory dispositions

### Options

#### Option A — Keep a URL-only array

Continue claiming owner/date/path/follow-up validation without representing
those values.

#### Option B — Use structured inline records plus durable PR/issue evidence

Represent URL, dependency path, owner, UTC expiry, and real follow-up issue in
the validation block. Mechanically validate every field and exact set equality,
then copy the reviewed table into durable PR/issue evidence. Keep the array
empty for a clean audit.

#### Option C — Add a tracked exceptions file and continuous CI enforcement

Store structured exceptions in the repository and make workflow audit
validation enforce expiry on every run. This gives durable automation but
expands P3 into ongoing vulnerability-policy infrastructure and requires
careful handling when the audit changes.

#### Option D — Prohibit all residual findings

Require audit exit 0 with no exception mechanism. This is strongest when fixes
exist, but can make P3 impossible to complete if a newly published reachable
advisory has no safe release or mitigation.

#### Option E — Store exceptions only in an external risk system

Use a security/GRC ticket as source of truth. This can improve organizational
workflow, but the repository validator cannot independently prove the record
without an integration and access model.

### Evaluation rubric

| Criterion | Weight | Why it matters for this finding |
| --- | ---: | --- |
| Completeness of risk decision data | 30 | URL alone cannot support an accountable exception. |
| Machine-verifiable correspondence to audit | 25 | Missing, duplicate, unrelated, or stale approvals must fail. |
| Expiry and follow-up enforceability | 20 | Temporary acceptance must not become permanent by neglect. |
| Durable reviewer/auditor evidence | 15 | The decision must survive local command history. |
| Operational burden proportionality | 10 | A one-time remediation should not accidentally create a new platform. |

### Scoring

| Option | Completeness (30) | Verification (25) | Expiry (20) | Audit trail (15) | Burden (10) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A — URL array | 1 | 2 | 1 | 2 | 5 | 36 |
| B — Structured inline + durable evidence | 5 | 5 | 5 | 4 | 4 | **95** |
| C — Tracked/continuous exceptions | 5 | 5 | 5 | 5 | 2 | 94 |
| D — No residual ever | 5 | 5 | 5 | 5 | 1 | 92 |
| E — External system only | 5 | 3 | 5 | 5 | 2 | 84 |

### Selected option

Select **Option B**, with clean audit as the default.

Replace the URL array with records containing:

- exact advisory URL;
- affected package and dependency path;
- nonempty named owner;
- invariant UTC expiry date;
- real HTTPS follow-up issue URL; and
- concise reachability/mitigation rationale.

The validator must reject duplicate URLs, empty fields, invalid/expired dates,
non-issue URLs, approvals unrelated to the current audit/path, missing current
findings, and records remaining after a clean result. Require exact current
moderate/high/critical URL equality and record the reviewed table in the
implementation PR/issue. If ongoing exceptions become common, create a
separate tracked-policy/continuous-enforcement issue rather than silently
expanding P3.

## C-15: Treat every advisory URL as dynamic evidence

### Options

#### Option A — Keep six individual References as the effective baseline

This is incomplete even today and conflates package-node count with advisory
count.

#### Option B — Freeze all 14 currently observed URLs in P3

This is complete for the 2026-07-29 observation but becomes stale when npm or
the advisory database changes.

#### Option C — Capture a dynamic normalized before/after advisory graph

Keep the dated seven-package-node severity table for comparison. At
implementation, traverse the complete audit graph and record every package,
object advisory URL/severity/range, string-valued dependency link, dependency
path, and remediation before and after the update. Mark References as
illustrative.

#### Option D — Option C plus attach raw audit JSON

Preserve normalized evidence and the full raw command output as a PR artifact
or attachment. This aids forensic review but creates an additional storage and
retention dependency.

#### Option E — Replace evidence with live advisory links only

Link to npm/GitHub pages and rely on reviewers to reconstruct the graph. That
is not reproducible and loses the exact implementation-time state.

### Evaluation rubric

| Criterion | Weight | Why it matters for this finding |
| --- | ---: | --- |
| Complete advisory/dependency graph | 30 | Package-node and advisory counts are different security facts. |
| Temporal correctness | 25 | Advisory data can change between drafting and implementation. |
| Reproducible before/after evidence | 20 | Reviewers need to see what the update actually removed or retained. |
| Reviewer comprehensibility | 15 | Normalized tables are easier to audit than raw nested JSON. |
| Evidence storage burden | 10 | Durability matters, but a new artifact service is not automatically needed. |

### Scoring

| Option | Completeness (30) | Temporal (25) | Reproducibility (20) | Clarity (15) | Burden (10) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Six references | 1 | 1 | 2 | 4 | 5 | 41 |
| B — Freeze 14 | 5 | 1 | 3 | 3 | 3 | 62 |
| C — Dynamic normalized graph | 5 | 5 | 5 | 5 | 4 | **98** |
| D — Graph plus raw attachment | 5 | 5 | 5 | 5 | 3 | 96 |
| E — Live links only | 2 | 2 | 1 | 2 | 5 | 42 |

### Selected option

Select **Option C**.

Keep P3's dated seven-package-node table, explicitly label individual
References as illustrative, and require a complete normalized audit graph at
implementation time. Record before/after:

- Node and npm versions;
- audit exit and severity totals;
- every affected package node;
- every object advisory URL, severity, vulnerable range, and fix;
- every string-valued dependency link;
- all resolved dependency paths from `npm explain`; and
- the final disposition.

Do not encode 14 as a future expected count. The implementation evidence must
derive counts from that run and explain changes from the dated baseline.

## C-16: Retain P1 → P2 → P3 and record blocked-by relationships

### Options

#### Option A — Keep prose ordering only

Leave dependency text in issue bodies but create no GitHub relationship.

#### Option B — Preserve the order and add real blocked-by links after filing

File the issues with their H1 titles, then update P2 to block on the actual P1
issue and P3 to block on the actual P2 issue. Keep the relative planning links
as drafting context.

#### Option C — Combine all work into one issue

One issue guarantees order internally but mixes generator/workflow security,
documentation semantics, and a pre-1.0 dependency migration into one large
review/rollback unit.

#### Option D — Run P1/P2/P3 in parallel

Reduce calendar time but allow P2 to regenerate against a moving generator and
P3 to change the lint baseline while earlier evidence is still being produced.

#### Option E — Track order only in a project/milestone

Use external planning metadata without issue-level blocked-by relationships.
This can aid portfolio reporting but is less visible to someone opening one
issue directly.

### Evaluation rubric

| Criterion | Weight | Why it matters for this finding |
| --- | ---: | --- |
| Technical dependency correctness | 30 | Each issue assumes the prior merged baseline. |
| Downstream handoff clarity | 25 | The implementer must know what can start now. |
| GitHub-native traceability | 20 | Real relationships should replace placeholder references. |
| Resistance to accidental out-of-order work | 15 | Planning metadata should enforce, not merely suggest, sequence. |
| Coordination overhead | 10 | Relationships should remain simple to maintain. |

### Scoring

| Option | Dependency (30) | Handoff (25) | Traceability (20) | Order safety (15) | Overhead (10) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Prose only | 4 | 3 | 1 | 2 | 5 | 59 |
| B — Real blocked-by chain | 5 | 5 | 5 | 5 | 4 | **98** |
| C — Combine | 5 | 2 | 3 | 5 | 1 | 69 |
| D — Parallel | 1 | 2 | 2 | 1 | 5 | 37 |
| E — Project only | 4 | 4 | 3 | 4 | 3 | 74 |

### Selected option

Select **Option B**.

Keep the issue descriptions ordered P1, P2, P3. After filing:

1. add the actual P1 issue as P2's blocker;
2. add the actual P2 issue as P3's blocker;
3. replace no H1 title with “revision” language;
4. use no invented issue number; and
5. ensure the final handoff lists the three issues in execution order.

## C-17: Coordinate P1/T1 without a runtime dependency

### Options

#### Option A — Implement independently with no comparison

Allow both repositories to solve similar problems separately and accept drift.

#### Option B — Perform an informal implementation-time diff

Ask maintainers to compare scripts without a defined behavioral contract or
recorded outcome.

#### Option C — Use reciprocal behavioral matrices and a second-mover check

Maintain repository-local scripts while defining shared generator/helper
invariants, intentional differences, and evidence. Whichever implementation
starts second rereads the first merged/current contract and records divergence.

#### Option D — Use a Git submodule or copied vendored script

Create a cross-repository source dependency. This adds update coordination and
still requires local artifact/manifest specialization.

#### Option E — Publish a shared versioned module/action

Centralize behavior with immutable consumption. This may be appropriate later,
but needs package ownership, provenance, cross-edition compatibility, release,
rollback, and synchronized adoption design.

### Evaluation rubric

| Criterion | Weight | Why it matters for this finding |
| --- | ---: | --- |
| Accurate behavioral convergence | 30 | Equivalent security/serialization outcomes are the current goal. |
| Repository autonomy and availability | 25 | One repository must not break because another is unavailable or moving. |
| Coordinated rollout/rollback safety | 20 | Shared changes should not create asymmetric half-migrations. |
| Long-term maintenance/drift visibility | 15 | Intentional differences must stay explicit. |
| Near-term deliverability | 10 | P1/T1 should remain implementable without a new product. |

### Scoring

| Option | Convergence (30) | Autonomy (25) | Rollout (20) | Maintenance (15) | Delivery (10) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Independent | 1 | 5 | 1 | 2 | 5 | 51 |
| B — Informal diff | 3 | 5 | 2 | 3 | 4 | 68 |
| C — Matrices/second mover | 5 | 5 | 5 | 5 | 4 | **98** |
| D — Submodule/vendor | 5 | 2 | 2 | 3 | 1 | 59 |
| E — Shared package/action | 5 | 3 | 3 | 5 | 1 | 74 |

### Selected option

Select **Option C**.

Implement C-01 and C-02's matrices in P1, retain repository-local code, and
require a dated second-mover comparison in implementation evidence. Shared
areas are serialization, public helper parameters, archive identity, path
security, lifecycle, diagnostics, fixtures, and artifact transport. Explicit
differences include manifests, filenames, frontmatter values, guide transforms,
Node work, and existing `.gitattributes` state. Any future shared package/action
must be a separately designed follow-up.

## C-18: Keep T2 provider-recovery content out of P2/P3

### Options

#### Option A — Preserve current separation and explicit non-goals

Keep P2 focused on the blank-line documentation defect and P3 on lint
dependencies/governance. Mention T2 only as a parallel sequence context, not
as content to implement.

#### Option B — Summarize T2 provider work in P2's prerequisite

Give cross-repository context, but burden a documentation issue with unrelated
S3/Azure/GCS/HCP operational security.

#### Option C — Copy T2 recovery requirements into P2

Turn P2 into a multi-repository/provider issue with unrelated sources,
credentials, shell examples, and validation.

#### Option D — Add only a non-normative link to T2

This is harmless but less explicit than preserving the current non-goal and can
suggest a dependency where none exists.

#### Option E — Merge the PSStyleGuide and TerraformStyleGuide slates

Coordinate everything in shared issues. This destroys repository ownership and
creates cross-repository completion dependencies.

### Evaluation rubric

| Criterion | Weight | Why it matters for this finding |
| --- | ---: | --- |
| Relevance to P2/P3 objectives | 35 | Provider recovery does not repair PowerShell documentation or npm tooling. |
| Implementer cognitive load | 25 | Unrelated cloud contracts obscure the task's actual acceptance gates. |
| Security-risk isolation | 20 | Provider credentials/state handling deserves its own review surface. |
| Cross-repository conceptual clarity | 10 | Parallel sequencing should not be mistaken for content identity. |
| Change/coordination cost | 10 | No-op preservation should win when the current state is correct. |

### Scoring

| Option | Relevance (35) | Cognitive load (25) | Isolation (20) | Clarity (10) | Cost (10) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Preserve separation | 5 | 5 | 5 | 5 | 5 | **100** |
| B — Summarize T2 | 3 | 3 | 4 | 4 | 4 | 68 |
| C — Copy T2 | 1 | 1 | 1 | 2 | 1 | 22 |
| D — Link only | 4 | 4 | 5 | 4 | 5 | 86 |
| E — Merge slates | 1 | 1 | 1 | 1 | 1 | 20 |

### Selected option

Select **Option A**.

No new T2 content belongs in P1/P2/P3. Preserve P2/P3's existing file and
topic boundaries. In P2's prerequisite, state only that T2 is not imported and
that each repository's documentation issue depends on its own generator
baseline. This finding requires preservation, not scope expansion.

## C-19: Define a policy-driven ordering exception

### Options

#### Option A — Ignore policy until implementation fails

Proceed P1 → P2 → P3 even if a known organizational/repository policy forbids
open high findings.

#### Option B — Always move P3 before P1

Minimize advisory exposure immediately, but force P1/P2 rebaselining and change
the prompt's requested sequence even when no policy requires it.

#### Option C — Add a filing/start gate with two explicit valid sequences

Confirm applicable security policy before filing/starting. Default to
P1 → P2 → P3. If policy forbids carrying the findings, perform the
dependency/hook remediation first, then rebaseline P1/P2 against its merged
Node/package state and record the exception.

#### Option D — Fold dependency remediation into P1

Avoid ordering delay by mixing the package migration, hook policy, generator,
workflow, artifact security, and governance in one issue.

#### Option E — Pause all slate work until every advisory is externally fixed

Eliminate acceptance decisions but can block indefinitely on upstream packages
and prevents unrelated security hardening.

### Evaluation rubric

| Criterion | Weight | Why it matters for this finding |
| --- | ---: | --- |
| Actual policy compliance | 35 | A documented mandatory policy outranks planning convenience. |
| Reduction of vulnerable-parser exposure | 25 | Pull-request Markdown reaches the affected toolchain. |
| Coherent P1/P2 baseline | 20 | Earlier issues should not validate against a dependency state that immediately changes. |
| Decision/audit clarity | 15 | Reviewers need the reason for default or exceptional order. |
| Calendar efficiency | 5 | Speed matters, but cannot override policy or coherent evidence. |

### Scoring

| Option | Policy (35) | Exposure (25) | Baseline (20) | Clarity (15) | Schedule (5) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Ignore | 1 | 1 | 5 | 2 | 5 | 43 |
| B — Always P3 first | 5 | 5 | 3 | 4 | 2 | 86 |
| C — Conditional gate | 5 | 5 | 5 | 5 | 4 | **99** |
| D — Fold into P1 | 3 | 4 | 1 | 2 | 3 | 54 |
| E — Pause all | 5 | 5 | 1 | 2 | 1 | 71 |

### Selected option

Select **Option C**.

Add an ordering note to P3 and the slate handoff:

- confirm repository/organization vulnerability policy at filing and again at
  implementation start;
- absent a prohibition, retain P1 → P2 → P3;
- if high findings cannot remain open, file/perform the P3 package/hook work
  first (or a renamed prerequisite with the same full scope), then rebaseline
  all P1/P2 Node, package, validation, and path assumptions after merge; and
- record the policy source and ordering decision in issue relationships/PR
  evidence.

Do not reorder merely because a hypothetical policy might exist.

## I-P1-01: Make the action-pin verifier enforce approved tuples

### Options

#### Option A — Keep the generic 40-hex/version regex

Continue accepting any external action repository, any lowercase 40-hex
commit, and any semantic-looking comment.

#### Option B — Compare complete expected `uses:` lines

Hard-code every approved line and require exact occurrences. This is strong but
can be awkward when the same action appears multiple times or indentation/step
placement changes.

#### Option C — Parse and validate an exact action allowlist with occurrence rules

Extract nonlocal `uses:` references into repository, SHA, and adjacent version
comment. Map each approved action to its exact SHA/comment, reject unknown
tuples, and require expected workflow/occurrence coverage. Keep a separate
implementation-time upstream metadata/release review.

#### Option D — Resolve every action commit online during local validation

Query GitHub for repo/commit/tag correspondence each time. This adds network,
authentication/rate-limit, and mutable remote-state dependencies to a local
static gate.

#### Option E — Adopt a third-party action pinning scanner

Use a supply-chain tool to detect mutable refs. Such tools may verify full-SHA
shape but still need repository-specific approved-version policy and their own
installation/provenance.

### Evaluation rubric

| Criterion | Weight | Why it matters for this finding |
| --- | ---: | --- |
| Exact approved provenance proof | 35 | A full SHA is not necessarily the reviewed SHA. |
| Resistance to repository/SHA/comment substitution | 25 | An attacker or mistake must not satisfy a shape-only gate. |
| Missing/unknown/occurrence detection | 20 | The complete intended action surface must be present and only that surface. |
| Maintainability during approved updates | 10 | SHA/comment changes should be one clear policy update. |
| Validator simplicity/portability | 10 | The gate runs locally without a new dependency. |

### Scoring

| Option | Provenance (35) | Substitution (25) | Completeness (20) | Maintenance (10) | Simplicity (10) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Generic regex | 1 | 1 | 2 | 5 | 5 | 40 |
| B — Exact lines | 5 | 5 | 4 | 3 | 4 | 90 |
| C — Parsed exact allowlist | 5 | 5 | 5 | 5 | 4 | **98** |
| D — Online resolution | 5 | 5 | 4 | 2 | 2 | 84 |
| E — Third-party scanner | 5 | 4 | 4 | 3 | 1 | 79 |

### Selected option

Select **Option C**.

Rewrite P1's pin validator around an exact map:

- `actions/checkout` →
  `3d3c42e5aac5ba805825da76410c181273ba90b1`, `v7.0.1`;
- `actions/setup-node` →
  `820762786026740c76f36085b0efc47a31fe5020`, `v7.0.0`;
- `actions/upload-artifact` →
  `043fb46d1a93c77aae656e7c1c64a875d1fc6a0a`, `v7.0.1`; and
- `actions/download-artifact` →
  `3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c`, `v8.0.1`.

Parse each nonlocal `uses:` line, require an allowed repository with its exact
SHA/comment, and fail unknown/missing/mismatched references. Require checkout
in both workflows, setup-node only where intended, and upload/download in the
build workflow's required roles. Reverify official commit metadata and newer
security releases immediately before implementation; the local allowlist
proves the checked-in result, not continued upstream freshness.

## I-P3-01: Close P3's npm audit command and schema boundary

### Options

#### Option A — Keep the current URL-set logic

Allow any nonzero audit exit to pass if the extracted URL set equals approvals,
do not query npm version, and assume JSON member shape.

#### Option B — Constrain exit codes only

Require clean or documented vulnerability exits, but retain unvalidated JSON
shape and incomplete Node/npm evidence.

#### Option C — Validate tools, exit semantics, JSON shape, counts, and graph

Resolve/query one Node and npm application; require exact Node policy; classify
audit exit as clean, vulnerability, or command error; parse one JSON object;
validate required members and integral counts; traverse object/string `via`
records and dependency paths; then apply structured exception equality.

#### Option D — Replace npm audit with a third-party scanner

Use another vulnerability engine/SBOM scanner. This can add insight but changes
the advisory source, identity model, installation/provenance, and acceptance
semantics rather than fixing the current npm boundary.

#### Option E — Add a formal checked-in JSON Schema and validator dependency

Validate npm output with a dedicated schema tool. This is rigorous but npm's
output can evolve, and adding another package to the package-remediation issue
creates a recursive dependency/provenance burden.

### Evaluation rubric

| Criterion | Weight | Why it matters for this finding |
| --- | ---: | --- |
| Command-error versus vulnerability discrimination | 30 | A scanner failure must never count as an approved finding. |
| Audit JSON structural integrity | 25 | Security decisions require validated fields and numeric totals. |
| Tool/version and graph evidence completeness | 20 | Reproducibility needs Node, npm, packages, URLs, and paths. |
| Compatibility with npm's supported output model | 15 | The validator should be strict without inventing a fragile private schema. |
| Implementation/dependency burden | 10 | New scanners or schema packages need strong justification. |

### Scoring

| Option | Exit semantics (30) | Structure (25) | Evidence (20) | Compatibility (15) | Burden (10) | Weighted total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A — Current logic | 1 | 2 | 2 | 3 | 5 | 43 |
| B — Exit codes only | 4 | 2 | 3 | 4 | 5 | 68 |
| C — Complete inline validation | 5 | 5 | 5 | 5 | 4 | **98** |
| D — Third-party scanner | 5 | 4 | 5 | 3 | 1 | 81 |
| E — Formal schema dependency | 5 | 5 | 5 | 4 | 2 | 91 |

### Selected option

Select **Option C**.

P3's primary validation must:

1. query and record exactly one Node version and one npm version;
2. require the selected Node policy and use the same resolved npm executable;
3. capture stdout and exit immediately from
   `audit --package-lock-only --audit-level=moderate --json`;
4. accept exit 0 only for a clean result and the documented vulnerability exit
   only when structured approvals exactly match; reject every other exit;
5. require one JSON object with `metadata.vulnerabilities` and
   `vulnerabilities`;
6. require nonnegative integral critical/high/moderate/low/total counts and
   internal consistency;
7. traverse object advisories plus string dependency links and associate the
   complete graph with `npm explain` paths; and
8. apply C-14's duplicate, field, expiry, follow-up, clean-state, and exact-set
   rules.

Keep the dated audit table as comparison evidence. Do not hard-code today's
advisory count as the only accepted future shape.

## Selected slate-level outcome

All 21 findings have now been evaluated before issue editing. The selected
slate remains:

1. P1 — deterministic generator and secure workflow/artifact baseline;
2. P2 — blank-line documentation correction and regeneration; and
3. P3 — dependency remediation, staged-lint regression coverage, Node-floor
   alignment, and final npm governance.

The only ordering exception is the documented policy gate in C-19.
