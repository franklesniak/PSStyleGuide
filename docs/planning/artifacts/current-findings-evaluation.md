# PSStyleGuide findings evaluation

## Scope and scoring conventions

This file evaluates each open PSStyleGuide finding recorded in
`docs/planning/artifacts/current-findings.md`, in its recorded order. Each finding
has its own options, purpose-built rubric, scoring table, and selected resolution.
TerraformStyleGuide issues are contextual only and are not revised.

Unless a finding-specific rubric states otherwise, every criterion is scored from
0 to 5:

- 0: does not satisfy the criterion or creates an unacceptable failure;
- 1: very weak;
- 2: weak;
- 3: adequate;
- 4: strong; and
- 5: excellent.

Weighted points equal `score / 5 × weight`. Totals are out of 100. Raw scores are
shown in each table so that another reviewer can reproduce or challenge the result.

## Evaluation status

Complete. All seven findings were evaluated in recorded order, and each selected
resolution has been incorporated into the P1-then-P2 issue slate.

## P1-1 — The security-sensitive archive helper is not automatically exercised before merge

### Problem to solve

The helper is a security boundary: it authenticates the retained candidate ZIP,
validates its central-directory manifest, and controls extraction. P1 currently
requires its malicious-fixture suite only in push consumers. That leaves ordinary
pull-request revisions without automatic execution of the new helper and leaves
Ubuntu coverage dependent on a one-time controlled drill.

### Option dimensions and permutations

Four choices can be combined:

1. **Cadence**
   - one-time controlled evidence only;
   - every pull request;
   - every push consumer; or
   - both every pull request and every push consumer.
2. **Claimed platform coverage**
   - Ubuntu with PowerShell 7 only;
   - Windows PowerShell 5.1 only;
   - Windows PowerShell 7 only;
   - the two Windows editions;
   - Ubuntu PowerShell 7 plus both Windows editions; or
   - all four Windows edition/EOL cells plus Ubuntu.
3. **Placement**
   - existing Ubuntu and Windows verification jobs;
   - a dedicated read-only helper-test job or matrix;
   - both a dedicated job and production-consumer smoke tests; or
   - a privileged event such as `pull_request_target`.
4. **Fixture-suite ownership**
   - duplicate inline YAML/PowerShell in each job;
   - define a workflow-local function repeatedly;
   - place one versioned test harness in a tracked `.ps1` file;
   - use Pester tests plus a smaller consumer smoke test; or
   - add a test mode to the production helper itself.

The full Cartesian product includes combinations that are technically equivalent,
strictly dominated, or unsafe. The following bundles retain every materially
different tradeoff.

### Options

#### Option A — Keep P1 unchanged

Retain the controlled pre-merge drill and push-consumer self-tests as the only helper
execution. This has no additional CI cost or implementation work, but it does not
close the finding: a later pull-request commit can break the helper without any
automatic helper test, and the expected post-merge `has_changes=false` path skips the
Ubuntu synchronization consumer.

#### Option B — Test only on Ubuntu pull requests

Run the full fixture suite in the existing read-only Ubuntu pull-request job under
PowerShell 7. Retain all push-consumer tests. This makes every revision exercise the
helper and proves the most security-sensitive ZIP behavior on a case-sensitive
platform, but Windows PowerShell 5.1 and Windows path semantics still lack pre-merge
coverage.

Fixture code could be inline or tracked. A tracked harness is stronger, but this
bundle remains incomplete because its platform set is incomplete.

#### Option C — Test only in the two Windows LF pull-request cells

Run the suite under Windows PowerShell 5.1 and PowerShell 7 in the existing LF cells;
retain all push-consumer tests. This proves both supported editions before merge and
avoids coupling the helper to irrelevant CRLF generator fixtures. It does not
automatically prove the helper's explicit Ubuntu claim.

#### Option D — Inline the suite in Ubuntu and the two Windows LF cells

Add the complete fixture suite to the existing Ubuntu pull-request job and to the LF
cell for each Windows edition. Retain the in-situ suite before every push-consumer
production invocation. Keep the fixture implementation embedded in `build.yml`.

This closes the coverage gap with three pre-merge executions and no new tracked file.
Its weakness is duplication: a long malicious-archive suite appears in multiple job
branches and can drift between pull-request and push paths.

#### Option E — Run the suite in every pull-request matrix cell

Run it in Ubuntu and all four Windows edition/EOL cells, then retain all
push-consumer tests. This is the maximal execution-count bundle. It closes the
finding, but the helper does not consume generator-source EOL fixtures, so the two
CRLF repetitions do not add a distinct helper behavior. Extra repetitions increase
runtime, log volume, and the number of places a flaky environmental dependency can
fail.

The fixture code may be inline or tracked. Tracking it mitigates drift but does not
make the redundant CRLF executions informative.

#### Option F — Add a dedicated three-cell read-only helper-test matrix

Create a pull-request-only job with these logical cells:

- Ubuntu plus PowerShell 7;
- Windows plus Windows PowerShell 5.1; and
- Windows plus PowerShell 7.

Run the complete fixture suite there and retain a complete in-situ suite in every
push consumer. This produces a clear security gate and focused logs. It adds another
job/matrix and either duplicates the suite in `build.yml` or still needs a reusable
tracked harness. It also separates the helper test from the existing checkout and
fixture preparation jobs, so those jobs must independently prove the exact event SHA
and invoke the exact tracked helper.

#### Option G — Use a tracked harness in existing cells and consumers

Create
`.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1` as the sole
definition of the deterministic valid and malicious fixture suite. It must:

- declare `#Requires -Version 5.1`;
- record a script version;
- accept or resolve the exact tracked production-helper path;
- create all fixture state under a unique runner-temporary root;
- invoke the production helper as a child script rather than reimplement its logic;
- verify expected pass/fail outcomes, candidate-directory lifecycle, and known escape
  sentinels;
- clean all fixture state in `finally`; and
- return nonzero on any unexpected outcome.

Invoke that harness:

- in the existing pull-request Ubuntu job under PowerShell 7;
- in only the LF cell for Windows PowerShell 5.1;
- in only the LF cell for Windows PowerShell 7; and
- immediately before the production helper in every push consumer.

This is the three-platform coverage of Option D with one auditable fixture
definition. It adds one tracked implementation file, so P1's affected-file list,
working-tree/staged-set checks, script-version evidence, and T1 alignment text must
be updated.

#### Option H — Use a dedicated full-suite matrix plus consumer smoke tests

Run the complete tracked harness in the dedicated matrix from Option F. In push
consumers, run only a valid-archive and wrong-digest smoke test before the production
invocation. This reduces repeated malicious-fixture cost, but weakens P1's valuable
in-situ guarantee that every privileged or candidate-consuming environment can reject
every supported archive attack class. A platform-specific extraction regression
could pass the dedicated matrix yet fail differently in a consumer after job-specific
preparation.

#### Option I — Use Pester unit tests plus an in-situ smoke or full suite

Express fixtures and assertions as Pester tests. Run Pester across Ubuntu PowerShell
7 and both Windows editions on every pull request, then either:

- run a small smoke test in push consumers; or
- run the full Pester suite in push consumers.

Pester provides strong test organization and failure reporting. It introduces module
installation, version pinning, supply-chain, cache/network, and PowerShell 5.1 module
compatibility concerns unless Pester is vendored or already controlled by the
repository. For one helper and a deterministic fixture suite, a self-contained
PowerShell harness is simpler and more hermetic.

#### Option J — Add a self-test switch to the production helper

Give the helper a `-SelfTest` mode that constructs fixtures and recursively invokes
its normal mode. Run it on the three claimed platforms and in push consumers. This
keeps one file, but mixes production extraction code with test-only fixture
construction, complicates parameter sets, and creates a risk that tests share private
implementation paths rather than exercising the public caller contract. Security
test code should not expand the production helper's attack surface.

#### Option K — Test fork code with `pull_request_target`

Run the helper suite under `pull_request_target` to gain a privileged base-repository
context. This is unnecessary and unsafe. The suite executes pull-request-controlled
PowerShell and archive fixtures; combining that with a trusted token or secrets is a
well-known workflow-injection hazard. The existing `pull_request` event supplies all
required read-only coverage and must be used.

### Dominance conclusions before scoring

- Options A, B, and C do not prove all claimed platforms before merge.
- Option E adds executions without adding a new helper-input dimension.
- Option K is security-inadmissible regardless of convenience.
- Options D, F, and G all close the finding; their main distinction is whether the
  suite is duplicated, isolated in another job, or owned by one tracked harness.
- Options H and I are legitimate test-engineering alternatives but add either weaker
  consumer assurance or dependency complexity.
- Option J reduces file count at the cost of production/test separation.

### Evaluation rubric

This rubric is specific to testing a security-sensitive, cross-platform archive
boundary. It intentionally gives only 3% to implementation churn and issue scope.
Correct rejection behavior, platform evidence, and realistic invocation dominate.

| ID | Criterion | Weight | Scoring guidance |
| --- | --- | ---: | --- |
| R1 | Pre-merge security regression detection | 26 | 0 means no automatic pre-merge helper execution; 3 catches common regressions on every revision; 5 runs the complete malicious suite on every materially distinct supported platform before merge. |
| R2 | Evidence for the declared platform contract | 18 | 0 proves none of Ubuntu, Windows PowerShell 5.1, and Windows PowerShell 7; 3 proves two; 5 proves all three without treating irrelevant EOL fixtures as platform evidence. |
| R3 | Public-contract and production-path realism | 15 | 0 tests a reimplementation; 3 invokes the helper but not in consumer-like conditions; 5 invokes the exact tracked helper through its public interface and retains in-situ checks before every production use. |
| R4 | Hermeticity and least privilege | 12 | 0 executes untrusted code in a privileged context or depends on uncontrolled services; 3 is read-only but has avoidable external dependencies; 5 is deterministic, temporary-root-contained, dependency-free, and read-only in pull requests. |
| R5 | Fixture consistency and long-term maintainability | 11 | 0 invites materially divergent suites; 3 is manageable with duplication; 5 has one tracked, reviewable fixture definition used everywhere. |
| R6 | Failure localization and diagnostic quality | 7 | 0 obscures which platform or attack fixture failed; 3 supplies adequate logs; 5 identifies the exact platform, fixture, expected outcome, helper result, and containment sentinel. |
| R7 | CI proportionality and reliability | 5 | 0 is prohibitively redundant or flaky; 3 has acceptable overhead; 5 runs once per materially distinct environment with no irrelevant repetitions. |
| R8 | Implementation difficulty, churn, and issue-scope fit | 3 | 0 requires major unrelated infrastructure; 3 is a moderate P1 addition; 5 is a small localized edit. This deliberately low weight prevents convenience from defeating security evidence. |
| R9 | Cross-repository alignment without coupling | 3 | 0 creates a PSStyleGuide-only architecture that cannot sensibly align; 3 is alignable with adaptation; 5 supports the same harness contract in both repositories while keeping repository-specific manifests local. |

#### Scoring rules

- Each raw score is an integer from 0 to 5.
- Weighted total is the sum of `raw score / 5 × weight`.
- R4 is a safety gate: an option scoring 0 on R4 cannot be selected even if its total
  were otherwise competitive.
- A selectable option should score at least 4 on R1, R2, and R3 because the finding
  concerns a security boundary with an explicit three-platform contract.
- Redundant CRLF executions cannot increase R2: fixture EOL is not a helper input.

### Scoring table

Scores for options that allow an inline or tracked implementation use the strongest
reasonable variant stated in the option. This prevents an intentionally poor
implementation detail from understating an architecture, while the option text still
identifies residual drift risk.

| Option | R1 | R2 | R3 | R4 | R5 | R6 | R7 | R8 | R9 | Weighted total | Gate result |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A — unchanged | 0 | 2 | 4 | 5 | 3 | 3 | 5 | 5 | 4 | 52.4 | Fails R1/R2 |
| B — Ubuntu PR only | 3 | 2 | 5 | 5 | 4 | 4 | 4 | 4 | 4 | 73.0 | Fails R1/R2 |
| C — two Windows LF cells only | 4 | 3 | 5 | 5 | 4 | 4 | 4 | 4 | 4 | 81.8 | Fails R2 |
| D — inline suite in three existing cells | 5 | 5 | 5 | 5 | 2 | 4 | 5 | 4 | 3 | 90.2 | Pass |
| E — every PR matrix cell | 5 | 5 | 5 | 5 | 3 | 4 | 2 | 3 | 4 | 89.4 | Pass |
| F — dedicated three-cell job, full consumer suite | 5 | 5 | 5 | 5 | 4 | 5 | 4 | 3 | 4 | 95.0 | Pass |
| G — tracked harness in existing cells and consumers | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 3 | 5 | **98.8** | Pass |
| H — dedicated full suite, consumer smoke tests | 5 | 5 | 3 | 5 | 5 | 5 | 5 | 2 | 4 | 91.6 | Fails R3 |
| I — Pester plus full in-situ suite | 5 | 5 | 5 | 2 | 5 | 5 | 3 | 1 | 3 | 87.2 | Pass |
| J — production helper self-test mode | 5 | 5 | 3 | 4 | 4 | 4 | 5 | 4 | 4 | 86.8 | Fails R3 |
| K — `pull_request_target` | 5 | 5 | 4 | 0 | 3 | 3 | 3 | 2 | 1 | 71.6 | Disqualified by R4 |

Option G leads because it combines complete pre-merge platform evidence, exact
production-helper invocation, hermetic read-only execution, and one auditable fixture
definition. Option F is close, but a new dedicated matrix is unnecessary when the
existing jobs already provide all three distinct environments.

### Selected resolution

Select **Option G: one tracked reusable self-test harness, invoked in the three
materially distinct pull-request environments and before every push-consumer
production invocation**.

An implementer coming in cold should make these exact P1 changes:

1. Add
   `.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1` to P1's affected
   files and implementation scope.
2. Require that harness to declare PowerShell 5.1 compatibility and a script version.
   The harness, not `build.yml`, owns the complete deterministic fixture catalog.
3. Require the harness to accept the exact production helper path and any parameters
   needed to exercise the helper's public contract. It must invoke that file; it must
   not copy archive-validation or extraction logic.
4. Keep every fixture beneath one unique runner-temporary root. Include the valid
   archive, wrong digest, missing/extra/duplicate entries, traversal, absolute or
   drive-qualified names, directory entries, separator variants, symlink/reparse
   attempts where constructible, compression-ratio and size limits, preexisting
   destination, and archive mutation/lifecycle cases already required by P1.
5. For each rejection fixture, assert the helper fails, the destination was never
   created, and named sentinels outside the fixture root were not written. For the
   valid fixture, assert exact extraction and returned/resolved paths.
6. Clean the entire fixture root in `finally` and fail the harness if cleanup or any
   expected assertion fails.
7. In the existing Ubuntu pull-request job, invoke the harness with `pwsh` after the
   exact event SHA and clean-checkout invariants are proved.
8. In the Windows pull-request matrix, invoke it only when the fixture is `lf`.
   Because the matrix already crosses edition and EOL, this executes once under
   Windows PowerShell 5.1 and once under PowerShell 7. Do not run it in either `crlf`
   cell.
9. In every push consumer—the four push-matrix cells and synchronization—invoke the
   same harness immediately before invoking the same production helper on the
   downloaded candidate.
10. Keep all pull-request helper tests read-only with `contents: read`. Do not use
    `pull_request_target`, secrets, a PAT, or a GitHub App token.
11. Update P1's affected-file list, local validation, exact working-tree/staged-set
    checks, script-version evidence, controlled-drill evidence, pull-request evidence,
    post-merge evidence, and acceptance criteria from three implementation files to
    four.
12. State that TerraformStyleGuide may adopt the same harness filename, parameter
    interface, and placement pattern independently. Do not make P1 depend on a change
    in that repository.

This resolution preserves the strongest part of the original design—the complete
suite running in every real consumer—while adding repeatable pre-merge proof without
four copies of security test logic.

## P1-2 — The helper cannot implement all required checks from its specified interface

### Problem to solve

P1 gives the helper three inputs but requires behavior that needs more context. The
helper must prove that its download and destination paths are outside the tracked
checkout, yet it receives no authoritative checkout root. It must also include
artifact/run metadata in diagnostics when available without defining how that data
arrives. Ambient current-directory and CI-environment inference would make the same
script behave differently in local tests and production.

The containment check also needs a positive trust boundary. Proving only "not under
checkout" permits extraction into any other filesystem location. P1 already says all
fixture and candidate state belongs beneath a unique runner-temporary root, so the
interface can make that invariant explicit.

### Option dimensions and permutations

The material design axes are:

1. **Checkout-root source**
   - current directory;
   - `git rev-parse`;
   - `GITHUB_WORKSPACE`;
   - a mandatory explicit parameter; or
   - a context/configuration object.
2. **Allowed-root policy**
   - negative check only: outside checkout;
   - positive check only: inside a trusted temporary root;
   - both positive temporary-root containment and negative checkout exclusion; or
   - caller-only validation.
3. **Diagnostic context**
   - read GitHub environment variables;
   - explicit optional scalar parameters;
   - one structured context object;
   - make all fields mandatory; or
   - keep artifact/run metadata entirely in caller logs.
4. **Filesystem indirection**
   - lexical normalized-string checks only;
   - resolved filesystem-provider paths plus separator-boundary comparisons;
   - canonical-link resolution where APIs permit; or
   - fail closed on reparse/symbolic-link components beneath the trusted root.

The following options represent the meaningful bundles.

### Options

#### Option A — Leave the interface implicit

Keep the three documented parameters and let the implementer infer checkout,
temporary-root, and diagnostics. This minimizes prose but creates multiple plausible,
incompatible implementations. A local fixture can accidentally pass because the
current directory happens to be the checkout, while a workflow invocation from
another directory behaves differently.

#### Option B — Discover checkout with Git and diagnostics with environment variables

Have the helper run `git rev-parse --show-toplevel` and read `GITHUB_RUN_ID`,
`GITHUB_RUN_ATTEMPT`, and caller-defined artifact variables. This avoids extra
parameters in CI. It adds a native-command dependency to the archive boundary,
requires the process to start inside the checkout, complicates immediate exit-code
handling, and does not work naturally when the self-test deliberately runs from a
temporary directory.

#### Option C — Require `GITHUB_WORKSPACE` and GitHub environment variables

Treat `GITHUB_WORKSPACE` as the checkout root and read run metadata from the GitHub
environment. This is simple in GitHub-hosted jobs, but makes the helper unusable as
specified in local tests unless callers manufacture CI environment variables. It
also conflates an environment convention with the helper's public contract and still
does not prove that candidate paths lie beneath the intended runner-temporary root.

#### Option D — Add mandatory `CheckoutRoot`; infer diagnostics from the environment

Make checkout explicit while keeping artifact/run metadata ambient. This makes
containment testable locally and fixes the largest interface hole. Diagnostic behavior
can still vary with stale or spoofed environment variables, and the helper knows only
where it must not write, not where it is allowed to write.

#### Option E — Add mandatory `CheckoutRoot` and optional scalar diagnostic parameters

Use explicit parameters such as `CheckoutRoot`, `ArtifactId`, `RunId`, and
`RunAttempt`. The caller passes metadata it actually owns; local tests omit optional
fields. Resolve the checkout, download, and destination-parent paths through the
filesystem provider and compare them with platform-appropriate ordinal semantics.

This is a complete implementation of the original negative "outside checkout"
contract, but any filesystem location outside the checkout remains eligible.

#### Option F — Add explicit trusted roots and optional diagnostics

Require:

- `CheckoutRoot`;
- `TrustedTemporaryRoot`;
- `DownloadDirectory`;
- `CandidateDirectory`; and
- `ExpectedDigest`.

Accept optional `ArtifactId`, `RunId`, and `RunAttempt` solely for diagnostic context.
Resolve existing roots and the download directory through the filesystem provider.
Resolve the nonexistent destination lexically only after resolving and validating its
existing parent. Require both candidate paths to be strict descendants of the trusted
temporary root and neither equal to nor beneath the checkout root.

Reject reparse/symbolic-link components introduced between the trusted temporary root
and either candidate location. Use separator-terminated root comparisons with
`OrdinalIgnoreCase` on Windows and `Ordinal` on Linux. This gives the helper a positive
write envelope as well as checkout protection and remains fully injectable in local
tests.

#### Option G — Pass one structured context object

Pass a hashtable or `PSCustomObject` containing roots, digest, and diagnostics. This
reduces parameter count and is extensible. PowerShell objects are weakly shaped across
script boundaries: misspelled properties become runtime nulls unless the helper adds
substantial schema validation. It also makes command-line invocation and help output
less self-documenting than typed scalar parameters.

A custom class would strengthen shape but is awkward across Windows PowerShell 5.1
script invocation and unnecessary for eight small fields.

#### Option H — Make the caller own containment and metadata

Remove the helper's outside-checkout obligation. Require each workflow caller to
validate roots and log artifact/run context before calling the three-parameter helper.
This produces a smaller extraction API but duplicates the security boundary across
five consumers. A caller can omit or subtly change containment checks while still
using the nominally shared helper.

#### Option I — Split containment and extraction into two production helpers

Add one helper that validates/reserves paths and a second that authenticates and
extracts the archive. This offers separation of concerns but creates a time-of-check
to time-of-use gap and makes correct ordering a caller responsibility. Passing a
validated token or open handle could close that gap, but that is disproportionate and
hard to implement portably in PowerShell 5.1.

#### Option J — Make every diagnostic field mandatory

Require artifact ID, run ID, and run attempt in every invocation. Production logs
become uniform, but the valid and malicious local fixtures do not naturally have
GitHub artifact or run identities. Supplying invented identifiers weakens provenance
and makes "available" metadata indistinguishable from synthetic test labels.

#### Option K — Put roots and diagnostics in a JSON configuration file

Pass one configuration-file path and parse a versioned schema. This can be strongly
validated and archived as evidence, but adds file lifecycle, escaping, secret
redaction, schema-version, and tamper questions to a small internal helper. It is
appropriate for a public tool with many settings, not this repository-local boundary.

### Dominance conclusions before scoring

- Options A, B, and C retain ambient-state ambiguity.
- Options D and E fix checkout-root injection; only E also gives diagnostics explicit
  provenance.
- Option F strictly strengthens E with the positive trusted-temporary-root invariant
  P1 already intends.
- Options G and K trade discoverable scalar parameters for unnecessary schema
  machinery.
- Options H and I fragment a boundary P1 is specifically trying to centralize.
- Option J manufactures metadata in tests and misstates provenance.

### Evaluation rubric

This rubric is specific to a filesystem trust-boundary interface. It weights
containment correctness and deterministic context far above parameter-count or scope
churn.

| ID | Criterion | Weight | Scoring guidance |
| --- | --- | ---: | --- |
| C1 | Containment correctness | 27 | 0 has no reliable checkout exclusion; 3 has only a lexical negative check; 5 enforces both an explicit positive trusted root and negative checkout exclusion with separator-safe comparisons. |
| C2 | Explicitness and deterministic behavior | 17 | 0 depends on ambient process state; 3 makes the main root explicit but leaves other behavior ambient; 5 makes every security-relevant input explicit and produces the same decision locally and in CI. |
| C3 | Resistance to path indirection and check/use mistakes | 14 | 0 delegates a racy check to callers; 3 validates resolved parents and boundaries; 5 also fails closed on introduced reparse/symbolic-link components and validates immediately before destination creation. |
| C4 | Cross-platform and local testability | 12 | 0 is GitHub-only or edition-specific; 3 can be adapted with environment scaffolding; 5 is directly injectable under Ubuntu PowerShell 7, Windows PowerShell 5.1, Windows PowerShell 7, and local fixtures. |
| C5 | Diagnostic provenance and usefulness | 10 | 0 omits context or invents it; 3 reads plausible ambient values; 5 receives optional caller-owned values, labels absent values clearly, and emits the validated paths/digests without ambiguity. |
| C6 | Fail-closed ownership of the security boundary | 8 | 0 spreads required checks across callers; 3 centralizes most checks; 5 keeps digest, path envelope, manifest, lifecycle, and extraction gates in the same helper. |
| C7 | API clarity and maintainability | 6 | 0 is opaque or schema-heavy; 3 is understandable with documentation; 5 has typed, discoverable parameters and one responsibility per input. |
| C8 | Independent cross-repository alignment | 3 | 0 relies on repository-specific ambient state; 3 can use the same interface and semantics in P1 and T1 with only manifest differences. |
| C9 | Implementation difficulty and churn | 3 | 0 requires disproportionate infrastructure; 3 is a moderate contract change; 5 is a minimal edit. Its low weight prevents a short parameter list from outranking containment correctness. |

#### Scoring rules

- Raw scores are integers from 0 to 5; weighted total is
  `raw score / 5 × weight`.
- C1 is a safety gate: a selectable option must score at least 4.
- C2, C3, C4, and C6 must each score at least 3.
- An option cannot earn C5 credit for synthetic values presented as real GitHub
  provenance.
- A positive allowed-root check scores higher than a negative checkout-only check
  because it bounds all possible extraction destinations.

### Scoring table

| Option | C1 | C2 | C3 | C4 | C5 | C6 | C7 | C8 | C9 | Weighted total | Gate result |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A — implicit interface | 0 | 0 | 0 | 1 | 1 | 3 | 2 | 2 | 5 | 15.8 | Fails C1/C2/C3 |
| B — Git discovery plus environment | 2 | 1 | 2 | 2 | 3 | 4 | 3 | 2 | 4 | 44.2 | Fails C1/C2/C3/C4 |
| C — GitHub environment contract | 2 | 1 | 2 | 1 | 3 | 4 | 3 | 2 | 4 | 41.8 | Fails C1/C2/C3/C4 |
| D — explicit checkout, ambient diagnostics | 4 | 3 | 3 | 4 | 3 | 5 | 4 | 4 | 4 | 73.4 | Pass |
| E — checkout plus optional diagnostics | 4 | 5 | 3 | 5 | 5 | 5 | 5 | 5 | 3 | 87.8 | Pass |
| F — checkout and trusted root plus diagnostics | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 3 | **98.8** | Pass |
| G — structured context object | 5 | 4 | 5 | 4 | 5 | 5 | 2 | 4 | 2 | 88.2 | Pass |
| H — caller-owned containment | 2 | 4 | 1 | 5 | 4 | 1 | 3 | 2 | 4 | 56.0 | Fails C1/C3/C6 |
| I — split validation/extraction helpers | 4 | 5 | 1 | 4 | 5 | 2 | 2 | 3 | 1 | 69.0 | Fails C3/C6 |
| J — mandatory diagnostics | 4 | 5 | 3 | 2 | 1 | 5 | 4 | 4 | 3 | 70.8 | Fails C4 |
| K — JSON configuration | 5 | 5 | 5 | 4 | 5 | 5 | 2 | 4 | 0 | 90.4 | Pass |

Option F wins decisively. Option K can express the same security facts but adds a
configuration schema and file trust problem. Option E is the best minimal contract,
but its negative-only allowed region is weaker than P1's already intended
runner-temporary-root discipline.

### Selected resolution

Select **Option F: explicit checkout and trusted-temporary roots with optional
caller-owned diagnostic parameters**.

P1 should specify this public helper interface:

```powershell
param (
    [Parameter(Mandatory)]
    [string]$CheckoutRoot,

    [Parameter(Mandatory)]
    [string]$TrustedTemporaryRoot,

    [Parameter(Mandatory)]
    [string]$DownloadDirectory,

    [Parameter(Mandatory)]
    [string]$CandidateDirectory,

    [Parameter(Mandatory)]
    [string]$ExpectedDigest,

    [string]$ArtifactId,

    [string]$RunId,

    [string]$RunAttempt
)
```

The names can change only if P1 and T1 use the same final names. The behavior should
be stated unambiguously:

1. `CheckoutRoot` and `TrustedTemporaryRoot` must each resolve to exactly one existing
   filesystem-provider directory. Require rooted native or filesystem-provider-
   qualified absolute paths. Reject wildcards, relative paths, non-filesystem
   providers, nonexistent roots, files, and reparse/symbolic-link roots.
2. The trusted temporary root must be outside and must not equal the checkout root.
3. `DownloadDirectory` must resolve to exactly one existing filesystem directory.
   `CandidateDirectory` must not exist; its parent must resolve to exactly one existing
   filesystem directory.
4. The download directory and candidate directory must each be strict descendants of
   `TrustedTemporaryRoot`. Neither may equal, contain, or be contained by the checkout
   root.
5. Normalize directory roots with exactly one trailing platform directory separator
   before descendant comparison. Use ordinal case-insensitive comparison on Windows
   and ordinal case-sensitive comparison on Linux. Do not use culture-sensitive
   comparisons or raw string prefixes.
6. Walk every existing component from the trusted root to the download directory and
   candidate parent. Reject any component whose filesystem attributes identify a
   reparse point or symbolic-link indirection. Repeat the relevant checks immediately
   before opening the archive and immediately before creating the destination.
7. Continue to require the archive itself to be one regular, non-reparse-point file.
8. Treat `ArtifactId`, `RunId`, and `RunAttempt` as optional diagnostic labels supplied
   by the caller. Never read them from ambient environment variables inside the
   helper. Reject empty values when a parameter is explicitly supplied.
9. Include all supplied labels plus normalized roots, archive path, expected digest,
   actual digest when computed, and the failing validation phase in error diagnostics.
   Represent omitted values as unavailable; never invent them.
10. Production callers pass:
    - the proved exact checkout path;
    - the unique child root they created under `RUNNER_TEMP`;
    - the download and reserved destination paths beneath that child root;
    - preparation's propagated artifact ID and digest; and
    - the current run ID and attempt.
11. The tracked test harness from P1-1 creates its own unique temporary root and passes
    explicit local labels or omits GitHub-only labels. It changes working directory
    during at least one valid test to prove that ambient location is irrelevant.
12. Add malicious fixtures for:
    - a checkout root that is equal to or contains the trusted root;
    - a download or destination outside the trusted root;
    - a sibling-prefix path such as `repository-other`;
    - case variants on Windows;
    - rejected relative and non-filesystem-provider inputs, plus an accepted
      filesystem-provider-qualified absolute input;
    - a reparse/symlink component where the platform permits construction; and
    - an explicitly supplied empty diagnostic label.

P1's helper section, workflow-call requirements, self-test catalog, controlled drill,
and acceptance criteria must all state this same contract. This gives the helper all
information it needs without Git, GitHub-specific ambient behavior, or weakly shaped
configuration objects.

## P1-3 — The modified workflow retains a Node 20 checkout action despite the active Node 24 migration

### Problem to solve

P1 rewrites `.github/workflows/build.yml` but leaves its
`actions/checkout@v4` reference unstated and unpinned. The current v4.3.1 metadata
declares Node 20. Node 20 is already end-of-life, GitHub switched the default action
runtime toward Node 24 on 2026-06-16, and runner removal of Node 20 is scheduled for
fall 2026. P1 also presents full-SHA pinning as an artifact-action security control
while leaving the equally privileged checkout action on a moving major tag.

### Option dimensions and permutations

The material choices are:

1. **Runtime**
   - retain checkout v4/Node 20 metadata;
   - force v4 through a runner override;
   - use a supported Node 24 checkout major such as v5 or v6; or
   - replace the action with hand-written Git commands.
2. **Reference**
   - moving major tag;
   - moving patch tag;
   - exact full commit SHA with release comment; or
   - a fork or vendored copy.
3. **Scope**
   - only `build.yml`, which P1 already redesigns;
   - both `build.yml` and the unrelated `markdownlint.yml`;
   - a separate prerequisite issue; or
   - a repository-wide action migration.
4. **Update lifecycle**
   - manual re-verification at implementation and periodic review;
   - Dependabot GitHub Actions updates; or
   - an organization policy enforcing full SHA references.

Update automation and organization policy can be layered onto any full-SHA option;
they do not replace selecting a supported immutable version now.

### Options

#### Option A — Leave `actions/checkout@v4`

Make no change. This has zero implementation churn but retains a moving reference and
Node 20 action metadata in a workflow intended to be hardened for long-term use. It
conflicts with GitHub's runtime migration and immutable-reference guidance.

#### Option B — Force Node 24 while retaining checkout v4

Set `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24=true` and retain
`actions/checkout@v4`. This can expose runtime incompatibilities early, but it does not
turn v4 into a supported Node 24 release and does not fix the moving major tag. It was
a migration-testing mechanism, not a durable dependency strategy.

#### Option C — Opt out to insecure Node 20

Set `ACTIONS_ALLOW_USE_UNSECURE_NODE_VERSION=true`. GitHub documents this only as a
temporary opt-out until Node 20 is removed from runners. It extends exposure to an
end-of-life runtime, has a fixed failure horizon, and is inadmissible for a newly
hardened workflow.

#### Option D — Pin checkout v4.3.1 to its full SHA

Use
`actions/checkout@34e114876b0b11c390a56381ad16ebd13914f8d5 # v4.3.1`.
This fixes supply-chain immutability but still selects action metadata that declares
Node 20. It solves only half the finding.

#### Option E — Update to a moving Node 24 major tag

Use `actions/checkout@v6`. This selects the current Node 24 line and receives compatible
updates automatically. A mutable tag can be retargeted, so it is inconsistent with
the security standard P1 applies to artifact actions and with GitHub's strongest
secure-use recommendation.

#### Option F — Update to the v6.0.2 patch tag

Use `actions/checkout@v6.0.2`. This is easier for a human to read and is more precise
than a major tag, but GitHub tags remain mutable. The adjacent version comment on a
full-SHA reference provides the same readability without giving up immutability.

#### Option G — Pin the current approved Node 24 release in `build.yml` only

As of the evaluation date, use:

```yaml
uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
```

Immediately before implementation, verify the SHA in the official checkout
repository, confirm the release comment, inspect `action.yml` for `node24`, and check
for a required newer security release. Apply the verified replacement only to
`build.yml`, which P1 already changes.

State explicitly that the remaining checkout v4 reference in `markdownlint.yml`
requires a separate near-term maintenance issue. This keeps P1 cohesive while
eliminating the risk from the workflow P1 is delivering.

#### Option H — Pin the current Node 24 release in both workflows

Replace checkout in both `build.yml` and `markdownlint.yml` with the verified v6
full SHA. This gives repository-wide checkout consistency and avoids leaving one
workflow near the Node 20 removal horizon. It expands P1 into a second workflow whose
behavior and validation are unrelated to deterministic artifact generation.

This is technically sound if the maintainer explicitly accepts the scope expansion.
It also requires adding `markdownlint.yml` to affected paths, exact staging checks,
validation evidence, and non-goals.

#### Option I — Create a checkout-modernization prerequisite

File and merge a separate issue that updates and pins both workflows, then make P1
depend on it. This preserves single-purpose issues and gives checkout migration its
own evidence. It delays the more important deterministic-generation fix and adds
coordination overhead for a one-line dependency change in `build.yml`.

#### Option J — Replace checkout with hand-written Git commands

Initialize and fetch the exact event SHA using Git directly. This removes the
JavaScript runtime dependency and can be fully explicit. It transfers credential
handling, safe-directory behavior, shallow-fetch semantics, cleanup, submodule/LFS
defaults, and untrusted-ref protections from a maintained official action into custom
workflow code. It is a larger and riskier security surface.

#### Option K — Vendor or fork checkout

Copy checkout code locally or maintain a fork pinned by repository path/SHA. This
provides maximum code ownership but creates an ongoing responsibility to track
upstream security patches and rebuild bundled JavaScript. The repository has no need
for checkout customization that would justify that burden.

#### Option L — Use an untagged latest checkout commit

Pin the newest commit on checkout's default branch rather than a reviewed release.
The reference is immutable, but release provenance, compatibility expectations, and
human-readable change boundaries are weaker. P1 should use a verified released
commit unless a documented security fix exists only after the latest release.

#### Option M — Add Dependabot or an organization SHA policy as part of P1

Pin v6 by full SHA and also add Dependabot GitHub Actions updates or a repository/
organization full-SHA enforcement policy. These are strong lifecycle controls, but
they are separate governance changes. Dependabot configuration adds another affected
file and review stream; organization policy may not be repository-controlled. Either
is a good follow-up, not a substitute for Option G or H.

### Dominance conclusions before scoring

- Options A through D retain Node 20 metadata or a temporary override.
- Options E and F fix the runtime but not immutability.
- Options J through L increase maintenance or weaken release provenance without a
  compensating requirement.
- Options G and H are the strongest direct fixes. Their difference is focused P1
  scope versus immediate repository-wide consistency.
- Option I is clean project management but adds a dependency for a localized change.
- Option M is additive governance and should be assessed separately from the runtime
  and pin selected in this finding.

### Evaluation rubric

This rubric is specific to a workflow dependency facing both runtime retirement and
supply-chain mutability. Scope adherence receives only 3%; supported operation and
immutability receive 46%.

| ID | Criterion | Weight | Scoring guidance |
| --- | --- | ---: | --- |
| N1 | Runtime support and continuity | 24 | 0 remains dependent on removable Node 20 behavior; 3 is a transitional workaround; 5 uses a current released Node 24 action with no insecure override. |
| N2 | Supply-chain immutability | 22 | 0 uses a moving major reference; 2 uses a patch tag; 5 pins a verified full SHA from the official repository. |
| N3 | Checkout security and behavioral compatibility | 14 | 0 reimplements checkout unsafely; 3 probably preserves basic checkout; 5 uses the maintained official release and validates the exact event-SHA/credential behavior P1 needs. |
| N4 | Release provenance and auditability | 12 | 0 has no reviewable provenance; 3 names a release but permits drift; 5 binds exact SHA, version comment, official release, action metadata, and implementation-time reverification. |
| N5 | Coverage of the repository's known runtime risk | 10 | 0 leaves both known v4 uses; 3 fixes only P1's modified workflow and explicitly tracks the other; 5 fixes both current workflow occurrences. |
| N6 | Sustainable update lifecycle | 7 | 0 creates an unsupported fork; 3 relies on occasional manual review; 5 supports clear same-line version metadata and a practical update mechanism. |
| N7 | Delivery sequencing and independence | 4 | 0 blocks P1 on broad governance; 3 adds coordination; 5 resolves the dependency directly in the existing implementation path. |
| N8 | Implementation difficulty, churn, and original-scope fit | 3 | 0 replaces checkout or adds major infrastructure; 3 touches one adjacent workflow; 5 is a one-line change in `build.yml`. |
| N9 | Maintainer and contributor usability | 4 | 0 creates confusing overrides or failures; 3 is understandable with caveats; 5 has an ordinary official action, readable version comment, and no special runner setup. |

#### Scoring rules

- Raw scores are integers from 0 to 5; weighted total is
  `raw score / 5 × weight`.
- N1 and N2 are gates: each must score at least 4.
- A temporary runner environment override cannot score above 3 on N1.
- A tag cannot score above 2 on N2, even when the publisher is trusted.
- N5 rewards resolving both known occurrences, but its 10% weight is not permission
  for an unrelated repository-wide dependency migration.

### Scoring table

| Option | N1 | N2 | N3 | N4 | N5 | N6 | N7 | N8 | N9 | Weighted total | Gate result |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A — unchanged v4 major | 0 | 0 | 3 | 1 | 0 | 2 | 5 | 5 | 2 | 22.2 | Fails N1/N2 |
| B — force Node 24 on v4 | 2 | 0 | 2 | 2 | 1 | 1 | 4 | 4 | 2 | 30.6 | Fails N1/N2 |
| C — insecure Node 20 opt-out | 0 | 0 | 1 | 1 | 0 | 0 | 3 | 4 | 0 | 10.0 | Fails N1/N2 |
| D — v4.3.1 full SHA | 1 | 5 | 4 | 5 | 1 | 3 | 4 | 5 | 3 | 64.8 | Fails N1 |
| E — moving v6 major | 5 | 1 | 5 | 3 | 3 | 4 | 5 | 5 | 5 | 72.2 | Fails N2 |
| F — v6.0.2 tag | 5 | 2 | 5 | 4 | 3 | 3 | 5 | 5 | 5 | 77.6 | Fails N2 |
| G — v6 full SHA in `build.yml` | 5 | 5 | 5 | 5 | 3 | 4 | 5 | 5 | 5 | 94.6 | Pass |
| H — v6 full SHA in both workflows | 5 | 5 | 5 | 5 | 5 | 4 | 4 | 3 | 5 | **96.6** | Pass |
| I — separate prerequisite | 5 | 5 | 5 | 5 | 5 | 4 | 2 | 2 | 4 | 93.6 | Pass |
| J — hand-written Git checkout | 5 | 5 | 2 | 3 | 3 | 1 | 2 | 0 | 1 | 68.6 | Pass, but weak N3 |
| K — vendor or fork checkout | 5 | 5 | 3 | 3 | 3 | 0 | 1 | 0 | 2 | 70.0 | Pass, but weak N6 |
| L — untagged latest full SHA | 5 | 5 | 3 | 1 | 3 | 2 | 4 | 5 | 2 | 73.4 | Pass, but weak N4 |
| M — both pins plus new update governance | 5 | 5 | 5 | 5 | 5 | 5 | 3 | 1 | 3 | 94.4 | Pass |

Option H narrowly outranks focused Option G because it removes the known runtime risk
from both workflows without introducing a new dependency manager or custom checkout
code. The 2-point difference represents repository continuity, not a general license
to migrate every action in P1.

### Selected resolution

Select **Option H: replace both current checkout v4 references with the same verified
Node 24 release pinned by full SHA**.

An implementer should do the following:

1. Add `.github/workflows/markdownlint.yml` to P1's affected-file list. The only
   intended change in that file is the checkout reference unless implementation
   testing proves a necessary compatibility adjustment.
2. In both `build.yml` and `markdownlint.yml`, replace every
   `actions/checkout@v4` occurrence with:

   ```yaml
   actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
   ```

3. Immediately before implementation, resolve the intended tag from the official
   `actions/checkout` repository, confirm the full SHA and same-line release comment,
   inspect exact-commit `action.yml` for `runs.using: node24`, review the release and
   security notices, and prefer a required newer security release if one exists.
4. Do not use the v6 major tag, v6.0.2 patch tag, an untagged default-branch commit,
   or a fork.
5. Preserve each workflow's current checkout inputs and permissions unless P1's
   architecture independently requires a change. Explicitly prove the exact event
   SHA after checkout as P1 already requires.
6. Account for checkout v6's credential-storage change: credentials are stored under
   `RUNNER_TEMP` instead of `.git/config`, but the official v6.0.2 documentation says
   ordinary authenticated Git commands continue to work. Confirm the final
   synchronization job's explicit `git push` succeeds in the controlled write drill.
7. Record that neither workflow invokes authenticated Git from a Docker container
   action, so the v6 README's container-action runner-version caveat is not exercised.
8. Run both workflow paths:
   - the Markdown lint workflow must still check out and complete its existing lint
     commands; and
   - P1's pull-request, push, controlled-write, and exact-lease drills must prove
     checkout and authenticated push behavior.
9. Update P1's exact local working-tree/staged set to the generator, production
   helper, test harness, `build.yml`, and `markdownlint.yml`: five implementation
   files after the P1-1 and P1-3 selections.
10. Add exact checkout commit metadata, README, v6.0.2 release, GitHub Node 20
    deprecation notice, and GitHub secure-use guidance to References.
11. Retain the non-goal against a broad action-pinning migration. P1 is making one
    targeted checkout runtime/immutability correction across the only two current
    occurrences; it is not changing unrelated action versions or adding Dependabot/
    policy configuration.

This selection gives the whole repository a supported checkout runtime while keeping
the change bounded, reviewable, and consistent with P1's immutable artifact-action
pins.

## P1-4 — P1 currently fails the repository's own Markdown lint

### Problem to solve

In P1's "Candidate archive download, self-test, validation, and extraction" sequence,
the YAML fence after item 4 is unindented. CommonMark therefore parses it outside the
list, and markdownlint treats items 5 and 6 as a new ordered list that incorrectly
starts at 5. The source fails MD029 and the rendered structure no longer reliably
communicates that the action invocation belongs to step 4.

### Options

#### Option A — Leave the Markdown unchanged

Accept the two lint failures. This preserves bytes but leaves ambiguous rendering and
forces reviewers to distinguish intentional errors from future lint regressions.

#### Option B — Restart the second list at 1 and 2

Change items 5 and 6 to 1 and 2 while leaving the fence unindented. This satisfies
MD029 as two lists, but changes the procedure into two disconnected sequences. A
reader coming in cold can no longer refer unambiguously to steps 5 and 6.

#### Option C — Indent the YAML fence as continuation content of item 4

Indent the opening fence, every YAML line, and the closing fence by three spaces—the
content indentation for the `4.` marker. Keep subsequent markers 5 and 6. This makes
the action example structurally part of step 4, preserves the six-step procedure, and
matches the repair documented by markdownlint.

#### Option D — Convert every marker to `1.` and indent the fence

Indent the fence as in Option C and write every ordered marker as `1.`. Markdown
renderers auto-number the six items, and edits do not require manual renumbering.
However, the raw issue is itself an implementation handoff with repeated references
to numbered steps; explicit source numbers make cold review and discussion easier.

#### Option E — Move the YAML fence before or after the ordered procedure

Introduce the action example before the list, then make item 4 refer back to it, or
place it after all six items. This avoids nested Markdown. It weakens locality between
the download instruction and the exact action configuration and makes accidental
separation during later edits more likely.

#### Option F — Replace the ordered list with bullets

Use six unordered bullets. Lint passes and fence nesting is straightforward, but the
order is security-significant: download must precede self-test and production helper
invocation. Bullets understate that sequencing contract.

#### Option G — Split the sequence into subheadings

Give download, self-test, and production invocation their own headings or paragraphs.
This can be very clear but expands a compact six-step contract and makes it harder to
compare against similar consumer sequences elsewhere in P1/T1.

#### Option H — Disable MD029 around the block

Add markdownlint disable/enable comments. This suppresses the symptom but does not
repair the CommonMark structure. Tool suppression is inappropriate when the linter
has correctly identified a broken list.

#### Option I — Change repository MD029 configuration

Disable MD029 or select a permissive numbering style. The unindented fence would still
terminate the list. A repository-wide rule change for one malformed issue draft is
disproportionate and would reduce future defect detection.

#### Option J — Use raw HTML for the list or code block

An HTML `<ol>`/`<li>` or `<pre><code>` structure can force exact rendering. It is
harder to read and copy in source, bypasses normal Markdown tooling, and complicates
the nested YAML example.

### Dominance conclusions before scoring

- Options A, H, and I hide rather than repair the structural error.
- Options B, E, F, and G can lint cleanly but weaken either sequence continuity or
  example locality.
- Option J replaces a standard Markdown construct with less maintainable HTML.
- Options C and D are fully correct. C preserves the issue's explicit step numbers;
  D optimizes future renumbering.

### Evaluation rubric

This rubric evaluates a procedural Markdown structure, not production code. Correct
rendered sequence and local association of the security-sensitive YAML example carry
the most weight. Scope and churn together receive 4%.

| ID | Criterion | Weight | Scoring guidance |
| --- | --- | ---: | --- |
| M1 | Semantic preservation of the ordered security procedure | 30 | 0 destroys ordering; 3 preserves most meaning with structural separation; 5 renders one six-step sequence in the intended order. |
| M2 | Conformance with the repository's configured Markdown lint | 20 | 0 retains errors; 3 suppresses or works around the rule; 5 passes without disabling a valid rule. |
| M3 | Local association and copyability of the YAML example | 15 | 0 detaches or corrupts the example; 3 leaves a cross-reference; 5 makes the exact YAML visibly part of download step 4 while preserving copied bytes. |
| M4 | Clarity for a cold implementer | 12 | 0 is misleading; 3 is understandable after rereading; 5 makes all six steps and the role of the nested example immediately clear in source and rendering. |
| M5 | CommonMark/GitHub rendering portability | 8 | 0 depends on parser quirks; 3 relies on HTML or extensions; 5 follows the CommonMark list-content rule. |
| M6 | Maintainability under later edits | 7 | 0 is brittle or suppressed; 3 is acceptable; 5 uses ordinary Markdown with an obvious nesting relationship. |
| M7 | Stable step references in review and evidence | 4 | 0 removes identifiable steps; 3 auto-numbers them only when rendered; 5 preserves explicit source numbers 1 through 6. |
| M8 | Amount of editing churn | 2 | 0 rewrites the section; 3 changes several lines; 5 adds only the required indentation. |
| M9 | Adherence to issue scope | 2 | 0 changes repository lint policy; 3 restructures the issue; 5 repairs only the malformed block. |

#### Scoring rules

- Raw scores are integers from 0 to 5; weighted total is
  `raw score / 5 × weight`.
- M1 and M2 must each score at least 4 for selection.
- A lint-disable comment cannot receive full M2 credit when the underlying structure
  remains malformed.
- Source readability matters because the Markdown itself is the handoff artifact.

### Scoring table

| Option | M1 | M2 | M3 | M4 | M5 | M6 | M7 | M8 | M9 | Weighted total | Gate result |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A — unchanged | 1 | 0 | 2 | 2 | 2 | 2 | 2 | 5 | 5 | 28.4 | Fails M1/M2 |
| B — restart at 1 and 2 | 2 | 5 | 3 | 2 | 5 | 4 | 1 | 5 | 5 | 64.2 | Fails M1 |
| C — indent fence under item 4 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | **100.0** | Pass |
| D — all `1.` plus indentation | 5 | 5 | 5 | 4 | 5 | 5 | 3 | 4 | 5 | 95.6 | Pass |
| E — move the example | 4 | 5 | 3 | 3 | 5 | 3 | 3 | 3 | 4 | 77.6 | Pass |
| F — unordered bullets | 2 | 5 | 4 | 3 | 5 | 5 | 2 | 4 | 4 | 71.0 | Fails M1 |
| G — subheadings | 5 | 5 | 4 | 5 | 5 | 3 | 4 | 2 | 3 | 91.4 | Pass |
| H — MD029 suppression | 1 | 3 | 2 | 2 | 2 | 1 | 2 | 3 | 2 | 37.0 | Fails M1/M2 |
| I — repository rule change | 1 | 5 | 2 | 2 | 2 | 1 | 2 | 0 | 0 | 43.0 | Fails M1 |
| J — raw HTML | 5 | 5 | 4 | 3 | 3 | 1 | 4 | 1 | 3 | 80.2 | Pass |

Option C is a complete repair with no tradeoff: it expresses the intended parse tree,
passes the existing rule, retains explicit step numbers, and changes only indentation.

### Selected resolution

Select **Option C: indent the YAML fence as continuation content of item 4**.

The exact repair is:

1. Keep ordered markers 1 through 6 unchanged.
2. Under item 4, prefix the opening ```` ```yaml ```` line, every YAML content line,
   and the closing fence with exactly three spaces. A blank line may remain empty.
3. Do not add three spaces to the YAML content *inside* the logical code block; the
   Markdown parser removes the list continuation indentation, so copied YAML remains
   unchanged.
4. Do not renumber items 5 and 6, move the example, add HTML, disable MD029, or change
   `.markdownlint.jsonc`.
5. Run the repository's configured `markdownlint-cli2` against P1 and run the nested
   Markdown linter.
6. Parse or render the section and confirm it contains one ordered list with six
   items, with the YAML fence inside the fourth list item.

CommonMark's rule for a `4.` marker requires three spaces for subsequent block
content, and markdownlint's own MD029 documentation gives this same repair for an
improperly unindented fenced block.

## P2-1 — P2 requires a rationale changelog that PSStyleGuide does not have

### Problem to solve

P2 requires a "matching top rationale changelog row" and agreement among Version,
Last Updated, and changelog metadata. PSStyleGuide has no rationale changelog,
version-history section, row schema, or source-document rule defining one. An
implementer cannot tell where the row belongs, what columns it needs, or whether older
history must be reconstructed.

### Option dimensions and permutations

The material choices are:

1. **History location**
   - no in-document changelog;
   - a new section in `STYLE_GUIDE_RATIONALE.md`;
   - a new section in `STYLE_GUIDE.md`;
   - a separate `CHANGELOG.md`;
   - GitHub releases/issues/commits; or
   - machine-readable frontmatter.
2. **History depth**
   - current P2 entry only;
   - reconstruct all prior versions;
   - begin prospectively with an explicit policy; or
   - link to Git history rather than duplicate it.
3. **P2 treatment**
   - remove the unsupported requirement;
   - define the convention completely inside P2;
   - make a separate prerequisite; or
   - replace "changelog row" with ordinary rationale prose.

### Options

#### Option A — Leave the changelog wording as written

Let the implementer invent a location and format. This is the lowest-edit choice but
creates non-repeatable outcomes and can introduce a repository policy accidentally.

#### Option B — Remove every changelog requirement from P2

Delete the instruction to add a top rationale changelog row and remove changelog
agreement from content confirmation and acceptance criteria. Continue to update
Version and Last Updated in `STYLE_GUIDE.md`, extend the existing rationale section,
regenerate all outputs, and rely on Git/GitHub history for change provenance.

This matches current PSStyleGuide information architecture and keeps P2 focused on the
blank-line example.

#### Option C — Add a prospective changelog section to the rationale

Define a new `## Change history` section, exact placement, table columns, newest-first
ordering, UTC date/version conventions, first P2 row, future maintenance rules, and
table-of-contents handling. State explicitly that history begins with P2 and that
older entries are not reconstructed.

This can be coherent, but it establishes permanent documentation governance while
fixing one example.

#### Option D — Reconstruct a complete rationale changelog

Use Git history and versions to backfill prior entries, then add P2 at the top. This
would give readers rich history but requires historical interpretation, may be
incomplete, and turns P2 into a research/migration project. It risks asserting
unsupported summaries for older releases.

#### Option E — Add history to `STYLE_GUIDE.md`

Place a changelog table in the main operational guide near Version and Last Updated.
It makes version history visible, but increases the size of every generated artifact
and conflicts with the slate's goal of keeping the main guide concise and operational.

#### Option F — Create a separate `CHANGELOG.md`

Introduce a conventional repository-level changelog with a documented schema and P2
entry. This avoids enlarging the guide, but adds another authoritative document and
requires decisions about historical backfill, generated-artifact inclusion, release
workflow, and future ownership. It belongs in a dedicated governance issue.

#### Option G — Use GitHub releases, issues, or pull requests as the changelog

Replace the row requirement with a link to the implementing issue/PR or a release.
This avoids duplicate history but makes the guide dependent on repository hosting and
does not help downstream copies that consume the documents without GitHub context.
Ordinary References can retain provenance without calling it a changelog.

#### Option H — Add version metadata/frontmatter to the rationale

Give `STYLE_GUIDE_RATIONALE.md` its own version/date fields or YAML frontmatter and
require them to match the guide. This can make synchronization machine-checkable but
does not provide a changelog row. It also creates a second version authority and
requires generator/template changes outside P2's documentation repair.

#### Option I — Add an HTML comment as hidden change history

Store a dated/versioned comment near the rationale edit. It avoids visible clutter but
is invisible to readers, unconventional, difficult to discover, and still lacks a
repository-wide policy.

#### Option J — Replace the row with an ordinary rationale note

Add a sentence in the existing Blank Line Usage rationale explaining that the visible
substitute was adopted in the current guide version/date. This gives local historical
context without a table. It duplicates metadata in prose and will become stale, while
the rationale already explains the substantive reason for the change.

#### Option K — Create a separate prerequisite for changelog policy

File a policy issue that chooses location, schema, backfill, ownership, and generation
behavior; make P2 depend on it. This is appropriate only if maintainers independently
want a changelog. It needlessly blocks the correctness repair if the changelog was
merely text copied from TerraformStyleGuide.

### Dominance conclusions before scoring

- Option A is not implementable deterministically.
- Options C through F, H, and K establish new repository governance beyond the
  demonstrated need.
- Options G, I, and J provide weaker or duplicative history without a complete
  convention.
- Option B is the only option that aligns exactly with current PSStyleGuide
  information architecture and P2's actual user-facing objective.

### Evaluation rubric

This rubric is specific to documentation governance and metadata authority. It gives
most weight to repository-policy correctness, deterministic implementation, and
avoiding contradictory sources of truth. Difficulty and scope total only 6%.

| ID | Criterion | Weight | Scoring guidance |
| --- | --- | ---: | --- |
| D1 | Fit with established PSStyleGuide documentation policy | 24 | 0 invents an unspecified convention; 3 is plausible but unsupported; 5 follows the current source roles or explicitly establishes a complete new policy. |
| D2 | Determinism for a cold implementer | 18 | 0 leaves location/schema unknown; 3 requires judgment; 5 states exactly what is added or removed with no missing format decision. |
| D3 | Reader usefulness and information architecture | 16 | 0 adds invisible/noisy material; 3 supplies useful history with some clutter; 5 keeps operational and rationale content in their proper roles. |
| D4 | Metadata integrity and single authority | 14 | 0 creates contradictory version/date authorities; 3 can be kept synchronized manually; 5 avoids duplicate authority or defines enforceable synchronization. |
| D5 | Long-term policy consistency | 10 | 0 creates a one-off orphan convention; 3 is maintainable with discipline; 5 has no new policy burden or a fully specified durable policy. |
| D6 | Ongoing maintainer burden | 7 | 0 requires historical reconstruction or extensive upkeep; 3 adds modest recurring work; 5 adds no new maintenance surface. |
| D7 | Usefulness in downstream and offline copies | 5 | 0 depends entirely on repository-host context; 3 remains partly useful; 5 is self-contained or avoids unnecessary hosted references. |
| D8 | Adherence to P2's original scope | 3 | 0 makes changelog governance a prerequisite; 3 adds adjacent policy; 5 remains the blank-line documentation repair. |
| D9 | Implementation churn | 3 | 0 adds multiple files/history; 3 adds a section; 5 removes unsupported sentences or makes an equally small edit. |

#### Scoring rules

- Raw scores are integers from 0 to 5; weighted total is
  `raw score / 5 × weight`.
- D1 and D2 must each score at least 4.
- A new changelog option can score 5 on D1 only if it defines location, schema,
  ordering, history depth, ownership, and future update rules.
- Git commit history is valid provenance; the rubric does not assume every guide must
  duplicate it in document content.

### Scoring table

| Option | D1 | D2 | D3 | D4 | D5 | D6 | D7 | D8 | D9 | Weighted total | Gate result |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A — leave undefined row | 0 | 0 | 1 | 0 | 0 | 2 | 2 | 5 | 5 | 14.0 | Fails D1/D2 |
| B — remove changelog requirements | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | **100.0** | Pass |
| C — prospective rationale changelog | 4 | 5 | 4 | 4 | 3 | 2 | 5 | 2 | 2 | 77.4 | Pass |
| D — reconstructed full history | 2 | 2 | 4 | 2 | 2 | 0 | 5 | 0 | 0 | 44.2 | Fails D1/D2 |
| E — main-guide changelog | 2 | 4 | 2 | 3 | 3 | 2 | 5 | 1 | 2 | 54.4 | Fails D1 |
| F — separate `CHANGELOG.md` | 4 | 4 | 4 | 4 | 4 | 2 | 4 | 1 | 1 | 73.6 | Pass |
| G — hosted history links | 3 | 4 | 3 | 4 | 3 | 4 | 1 | 3 | 4 | 66.4 | Fails D1 |
| H — rationale metadata/frontmatter | 2 | 4 | 2 | 1 | 2 | 2 | 4 | 1 | 1 | 45.2 | Fails D1 |
| I — hidden HTML history | 1 | 3 | 0 | 2 | 1 | 2 | 4 | 3 | 4 | 34.2 | Fails D1/D2 |
| J — ordinary dated rationale note | 3 | 5 | 4 | 2 | 2 | 3 | 5 | 4 | 4 | 68.8 | Fails D1 |
| K — changelog-policy prerequisite | 4 | 5 | 3 | 4 | 4 | 2 | 5 | 0 | 0 | 73.8 | Pass |

Option B is the unique best result because the supposed changelog is not an existing
PSStyleGuide feature. Removing an accidental cross-repository requirement restores a
complete and internally consistent P2 rather than deleting a genuine user feature.

### Selected resolution

Select **Option B: remove every unsupported changelog requirement from P2**.

Make these exact changes:

1. In "Advance metadata", delete "Add the matching top rationale changelog row."
2. Renumber the remaining instruction to commit metadata with the source change so
   the list is contiguous.
3. Keep the existing rules to reread the target branch, increment Minor, use the
   implementation UTC date, reset or increment Revision as specified, and update
   Version and Last Updated together.
4. In Acceptance criteria, replace "Version, Last Updated, and changelog metadata
   agree" with "Version and Last Updated agree with the finalized target baseline and
   UTC implementation date."
5. Remove any changelog check from content confirmation or validation prose. Do not
   replace it with a hidden comment, dated rationale sentence, GitHub release, or new
   file.
6. State that P2 extends the existing
   `### Blank Line Usage` section in `STYLE_GUIDE_RATIONALE.md`; it does not create a
   new history section.
7. Keep the implementing issue/PR and Git history as repository provenance, and keep
   any genuinely useful external sources in References. Do not describe those links
   as an in-guide changelog.
8. Do not add `CHANGELOG.md`, rationale frontmatter, a version table, or a changelog
   convention as part of P2.

After these edits, the only document metadata P2 owns is the already established
Version and Last Updated data in `STYLE_GUIDE.md`. The rationale owns explanatory
content, not duplicate release metadata.

## P2-2 — The automated middle-dot test proves only global co-occurrence, not the required example

### Problem to solve

P2's current script checks only global co-occurrence: if a touched file contains the
Non-Compliant marker, the same file must contain an LF-delimited line of four middle
dots somewhere. A malformed intended block can pass when the dot line appears in
unrelated prose or another fence. The script does not prove unique occurrence,
warning order, fence language, block line positions, or absence of a conflicting
second marker.

### Option dimensions and permutations

The meaningful axes are:

1. **Match scope**
   - whole-file co-occurrence;
   - exact canonical multi-line snippet;
   - a bounded region starting at the unique marker; or
   - a parsed Markdown syntax tree.
2. **Occurrence policy**
   - at least one;
   - exactly one canonical snippet;
   - exactly one marker plus exactly one validated block; or
   - snapshot/hash equality.
3. **Expected-file policy**
   - test any touched file opportunistically;
   - name the five documents that contain the guide;
   - separately name the rationale, which should not duplicate the operational
     example; or
   - discover outputs from the generator.
4. **Implementation**
   - inline PowerShell;
   - a new permanent validation script;
   - Node/`markdown-it`;
   - Pester; or
   - manual review only.

### Options

#### Option A — Keep the global co-occurrence check

Retain `Contains(marker)` followed by `Contains(LF + dots + LF)`. It is short and
catches complete omission, but it demonstrably accepts a wrong target block when a
dot line exists elsewhere.

#### Option B — Require one exact canonical snippet in each guide-bearing document

Build the approved heading, warning, `text` fence, brace/command lines, exact
four-middle-dot third line, closing fence, and follow-up sentence as an array of
literal lines joined with LF. Require exactly one ordinal occurrence and exactly one
heading marker in:

- `STYLE_GUIDE.md`;
- `copilot-instructions.md`;
- `powershell.instructions.md`;
- `STYLE_GUIDE_CHAT.md`; and
- `STYLE_GUIDE_FULL.md`.

Require no operational-example marker in `STYLE_GUIDE_RATIONALE.md`; that file should
extend its existing Blank Line Usage explanation rather than duplicate the main-guide
example. Retain independent BOM, CR, and trailing-whitespace checks.

This is strict and highly diagnostic. It intentionally turns P2's "materially
equivalent" suggested wording into canonical accepted wording.

#### Option C — Parse a bounded marker-to-fence region in PowerShell

Require one unique heading marker, locate the next fenced block, and assert:

- warning text occurs between heading and fence;
- the fence info string is exactly `text`;
- the fence has exactly six content lines;
- line 3 is exactly four U+00B7 characters;
- other block lines match the brace and command skeleton; and
- the prohibition sentence precedes the block.

This permits prose variation while testing structure. It requires a small Markdown
parser/state machine or carefully bounded indexing. Edge cases around backtick fence
length, nested examples, or prose containing fence-like text can make an ad hoc parser
less trustworthy than an exact snippet.

#### Option D — Parse Markdown with the repository's `markdown-it` dependency

Write a Node validation step that parses each expected file and inspects the heading,
paragraph order, code-fence language, and fence content. This respects Markdown
structure and handles fences robustly. It adds a cross-language validation script or
large inline Node command, couples P2 validation to dependency installation, and
still needs exact rules to identify the intended heading/paragraphs.

#### Option E — Add a permanent PowerShell content-validation script

Create a tracked validator that enforces Option B or C and run it locally and in CI.
This makes the semantic regression test durable after P2. It adds another production
maintenance file and P1 workflow change after P1 has already merged. The current
workflow's stale-artifact verification proves generator determinism, not arbitrary
style-guide semantic rules; adding one content-specific validator invites a broader
policy decision about which prose deserves permanent executable checks.

#### Option F — Add Pester tests

Express the exact or structural assertions as Pester tests. This gives good reporting
and future extensibility, but introduces the same module/dependency concerns discussed
for P1-1 and is disproportionate for one fixed Markdown example.

#### Option G — Check line offsets around the marker

Split content on LF, find the marker, then assert fixed relative line numbers for the
warning, fence, dots, and closing fence. This is dependency-free and clearer than a
regex. It is brittle to paragraph wrapping or an added explanatory line and still
needs uniqueness and expected-file checks.

#### Option H — Use one regular expression for the bounded block

Use an escaped, anchored, multiline regex that captures heading, warning, fence, and
content. It can require exactly one match and reject other markers. It is compact but
harder for new contributors to audit, especially with backticks, braces, U+00B7,
line-ending anchors, and PowerShell string escaping.

#### Option I — Compare whole-file hashes or snapshots

Regenerate and compare expected full-file hashes. This detects any difference but
conflates the example with version/date/rationale changes and requires updating
snapshots whenever any legitimate guide text changes. P1 already supplies source/
artifact byte identity; a whole-file snapshot adds no targeted semantic explanation.

#### Option J — Rely only on manual content confirmation

Delete the automated middle-dot check and review the rendered/source blocks manually.
Human review can understand prose, but it is not repeatable evidence and can miss an
invisible or confusable Unicode character.

#### Option K — Count only code points and marker occurrences

Require one marker, exactly four U+00B7 code points near it, and no other middle dots
in the file. This is stronger than Option A but can still pass when dots are in the
wrong line or outside a `text` fence. Prohibiting all other middle dots also creates an
unnecessary guide-wide content restriction.

### Dominance conclusions before scoring

- Options A, J, and K do not prove the required block.
- Options C, D, G, and H are viable structural approaches with different parser and
  brittleness tradeoffs.
- Options E and F make a one-time P2 acceptance check into new permanent test
  infrastructure.
- Option I is overbroad and duplicates P1's byte-identity role.
- Option B is simplest if the issue is willing to specify canonical wording; P2
  already supplies that wording and values durable exactness.

### Evaluation rubric

This rubric is specific to executable validation of a Unicode Markdown example.
False-positive resistance, exact code points, and complete output coverage receive
57%. Difficulty and churn receive only 7%.

| ID | Criterion | Weight | Scoring guidance |
| --- | --- | ---: | --- |
| V1 | Proof of the required semantic structure | 27 | 0 checks unrelated content; 3 validates only part of the block; 5 proves heading, warning order, `text` fence, exact block lines, and follow-up meaning as one bounded unit. |
| V2 | Unicode and byte-level precision | 16 | 0 accepts confusable/whitespace variants; 3 checks dots somewhere; 5 requires exactly four U+00B7 characters on the intended LF-delimited line and retains BOM/CR/trailing-space checks. |
| V3 | Expected-file coverage and uniqueness | 14 | 0 tests an arbitrary subset; 3 opportunistically checks touched files; 5 names every guide-bearing source/artifact, requires exactly one accepted block/marker in each, and handles rationale separately. |
| V4 | Failure diagnostics and cold-implementer clarity | 12 | 0 yields an opaque mismatch; 3 identifies the file; 5 identifies file, expected count/snippet component, actual count, and violated invariant using readable validation code. |
| V5 | Maintainability and resistance to test drift | 10 | 0 snapshots unrelated content or uses fragile offsets; 3 is maintainable with care; 5 has one obvious canonical expectation matching the issue's required source text. |
| V6 | Hermetic cross-platform execution | 8 | 0 requires uncontrolled tooling; 3 uses installed dependencies; 5 uses built-in PowerShell/.NET behavior and explicit LF strings with no network or platform-specific shell. |
| V7 | Alignment with source/generated-artifact roles | 6 | 0 hand-validates generated files differently; 3 checks some outputs; 5 applies one source expectation to all generated copies while keeping the rationale's role distinct. |
| V8 | Implementation difficulty | 4 | 0 adds a parser framework; 3 requires moderate indexing; 5 is a small literal-array/count check. |
| V9 | Scope and churn | 3 | 0 adds permanent infrastructure; 3 adds a script; 5 changes only P2's validation block and wording. |

#### Scoring rules

- Raw scores are integers from 0 to 5; weighted total is
  `raw score / 5 × weight`.
- V1, V2, and V3 must each score at least 4.
- A whole-file snapshot cannot substitute for a targeted semantic diagnostic.
- Manual review remains useful but cannot earn full credit for exact U+00B7 identity.

### Scoring table

| Option | V1 | V2 | V3 | V4 | V5 | V6 | V7 | V8 | V9 | Weighted total | Gate result |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A — global co-occurrence | 1 | 3 | 2 | 2 | 2 | 5 | 3 | 5 | 5 | 48.0 | Fails V1/V2/V3 |
| B — exact canonical snippet | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 5 | **100.0** | Pass |
| C — bounded PowerShell parser | 5 | 5 | 5 | 4 | 4 | 5 | 5 | 3 | 5 | 94.0 | Pass |
| D — `markdown-it` AST | 5 | 5 | 5 | 4 | 4 | 3 | 5 | 2 | 3 | 88.8 | Pass |
| E — permanent validator | 5 | 5 | 5 | 5 | 5 | 5 | 4 | 2 | 1 | 94.0 | Pass |
| F — Pester tests | 5 | 5 | 5 | 5 | 4 | 2 | 4 | 1 | 1 | 86.4 | Pass |
| G — line-offset checks | 4 | 5 | 5 | 4 | 2 | 5 | 5 | 4 | 5 | 85.4 | Pass |
| H — bounded regex | 5 | 5 | 5 | 2 | 2 | 5 | 5 | 3 | 5 | 85.2 | Pass |
| I — whole-file hashes | 5 | 5 | 5 | 1 | 0 | 5 | 2 | 1 | 0 | 70.6 | Pass |
| J — manual review only | 2 | 2 | 2 | 2 | 1 | 5 | 2 | 5 | 5 | 47.0 | Fails V1/V2/V3 |
| K — code-point/marker counts | 2 | 5 | 3 | 3 | 2 | 5 | 3 | 4 | 5 | 64.2 | Fails V1/V3 |

Option B wins because P2 already provides exact approved wording. Treating that
wording as canonical makes the validation both stricter and simpler than building a
partial Markdown parser.

### Selected resolution

Select **Option B: require exactly one canonical multi-line snippet in every
guide-bearing document**.

P2 should make its requested main-guide wording exact rather than "materially
equivalent" and use the same exact text as its validation oracle. The snippet must
contain, in order:

1. the exact bold heading
   `Non-Compliant (blank line contains spaces; visualization only):`;
2. the exact pre-block explanation that each middle dot substitutes for one U+0020
   SPACE and must not be copied;
3. a `text` fence;
4. exactly these six fence-content lines:
   - `{`;
   - four spaces plus `Invoke-SomeCmdlet`;
   - four U+00B7 MIDDLE DOT characters and nothing else;
   - four spaces plus `Invoke-AnotherCmdlet`;
   - `}`; and
   - no additional content line;
5. the closing fence; and
6. the exact follow-up sentence that the represented spaces are prohibited and a
   compliant blank line has no characters.

The revised validation block should:

1. Define `$arrGuideBearingPaths` as `STYLE_GUIDE.md` plus the four generated
   artifacts.
2. Define `$strRationalePath` separately.
3. Build `$strCanonicalSnippet` from an array of literal strings joined with
   ``"`n"``. Do not use an indented here-string whose incidental indentation or final
   newline can obscure the expected bytes.
4. Define the exact heading line as `$strNonCompliantMarker`.
5. Implement a small `Get-OrdinalOccurrenceCount` function using
   `String.IndexOf(..., [StringComparison]::Ordinal)` and a forward-moving offset.
   Reject an empty needle.
6. For every guide-bearing path, require:
   - canonical snippet count equals 1; and
   - marker count equals 1.
7. For `STYLE_GUIDE_RATIONALE.md`, require both counts equal 0. Extend its existing
   `### Blank Line Usage` prose without copying the operational block or exact
   heading.
8. On failure, report the path, expected count, actual snippet count, and actual
   marker count.
9. Retain independent checks for UTF-8 BOM, any CR byte, and trailing whitespace in
   all six touched files.
10. Retain regeneration idempotence and exact staged-path checks.
11. Update content confirmation and acceptance criteria to say the canonical snippet
    occurs exactly once in each named guide-bearing document, the rationale does not
    duplicate it, and the rationale's existing Blank Line Usage section contains the
    durability/portability explanation.
12. Demonstrate the validator's strength before filing by applying its logic to a
    synthetic string containing a wrong target block and an unrelated four-dot line;
    the new check must fail.

This closes both false-positive classes: a dot line elsewhere cannot satisfy the
snippet, and a second conflicting heading cannot coexist with the required unique
marker.

## P1/P2-1 — Evidence links point to moving major branches instead of the reviewed action commits

### Problem to solve

P1 pins upload/download actions by full SHA but cites `action.yml` and implementation
files through moving `v7` and `v8` branch URLs. P2 repeats those moving links. A later
reader may inspect code that did not produce the pinned workflow behavior, undermining
the digest/archive evidence the issues are designed to preserve.

### Option dimensions and permutations

The material choices are:

1. **Reference identity**
   - moving major branch/tag;
   - exact patch tag;
   - full commit SHA; or
   - locally archived copy.
2. **Presentation**
   - raw file URL;
   - GitHub blob permalink with line anchors;
   - release page;
   - commit page; or
   - multiple complementary links.
3. **Evidence set**
   - `action.yml` only;
   - README only;
   - implementation only;
   - all files that directly support the issue's claims; or
   - a prose summary with cryptographic file hashes.

### Options

#### Option A — Keep moving v7/v8 links

This is easy to read and always shows the newest major-line behavior. It cannot prove
what the pinned commit did and can silently change after the issue is filed.

#### Option B — Link exact patch tags

Use `/v7.0.1/` and `/v8.0.1/` raw or blob URLs. This aligns the visible label with
the intended release but tags remain mutable. It is better human context, not
immutable evidence.

#### Option C — Replace every source link with a full-SHA raw URL

Use exact commit IDs in URLs for `action.yml`, README, and the download implementation.
These links retrieve the exact reviewed bytes. Raw pages are less navigable and do not
show line numbers or repository context.

#### Option D — Use full-SHA GitHub blob permalinks with line anchors

Link `blob/<full-sha>/<path>#Lx-Ly` for each relied-upon contract. This is immutable,
human-readable, and focuses attention. Line ranges remain valid because the commit is
fixed. A link that is too narrowly anchored can omit surrounding defaults or control
flow needed to understand the claim.

#### Option E — Combine exact full-SHA source links with release pages

For each action, link exact-commit metadata/README/implementation files and retain the
exact patch-release page as human-readable provenance. Use raw URLs or full-SHA blob
permalinks according to whether whole-file download or line-focused review is more
useful.

This separates two roles cleanly: the commit link proves bytes; the release page
explains the version label and release context.

#### Option F — Link only the pinned commit page

A commit page proves repository identity and timestamp but makes the reader search the
diff/tree for each contract. It is weaker direct evidence than file-specific links.

#### Option G — Copy relevant action source into planning artifacts

Archive the reviewed files or excerpts beneath `docs/planning/artifacts`. This protects
against remote unavailability but duplicates third-party copyrighted source, requires
license/provenance handling, and can be mistaken for executable vendored code.
Exact-commit upstream links plus concise research notes are sufficient.

#### Option H — Remove implementation-level links

Retain release pages and trust action documentation. This shortens References but
cannot substantiate the crucial claim that download passes `artifact.digest` as
`expectedHash`, honors `skip-decompress`, and throws for `digest-mismatch: error`.

#### Option I — Add source-file hashes beside moving links

Record SHA-256 hashes of retrieved source files. This detects later drift but forces
the reader to download and hash content and still does not directly retrieve the
reviewed version. Git commit identity already supplies a standard content-addressed
reference.

#### Option J — Add an automated link/content verifier

Create a script that fetches References, verifies expected commits/hashes, and checks
key strings. This offers strong repeatability but introduces network-dependent test
infrastructure for issue prose. Implementation-time action-SHA reverification and
immutable URLs provide the needed assurance with much less machinery.

#### Option K — Link P2 only to P1 rather than repeat evidence

Remove action source links from P2 and say its workflow assumptions are established
by prerequisite P1. This avoids duplication but makes P2 less self-contained for an
implementer or reviewer who opens it directly. Exact repeated links are low-cost and
prevent ambiguity.

### Dominance conclusions before scoring

- Options A and B do not bind evidence immutably.
- Options F and H omit directly relevant source context.
- Options G, I, and J add archival or verification machinery without improving on
  exact Git object identity.
- Option K is defensible but weakens P2's standalone evidence.
- Options C and D are strong single-format solutions; Option E combines immutable
  technical evidence with readable release provenance.

### Evaluation rubric

This rubric is specific to preserving third-party action-contract evidence. Exact
identity, direct support, and reproducibility receive 64%. Link-edit churn receives
only 2%.

| ID | Criterion | Weight | Scoring guidance |
| --- | --- | ---: | --- |
| E1 | Identity with the pinned executable commit | 28 | 0 can move independently; 3 detects or limits drift; 5 retrieves the exact full-SHA source used by the workflow. |
| E2 | Direct support for every relied-upon contract | 20 | 0 is generic documentation; 3 proves some inputs/outputs; 5 covers metadata, digest output, archive mode, expected-hash flow, skip-decompress, and fatal mismatch logic. |
| E3 | Independent audit reproducibility | 16 | 0 requires trust in prose; 3 requires searching; 5 lets a reviewer retrieve the reviewed bytes and map each issue claim without guessing a revision. |
| E4 | Link durability | 10 | 0 is a moving branch; 3 is a tag or hosted-only summary; 5 uses immutable Git object URLs in the official repositories. |
| E5 | Human readability and navigation | 10 | 0 is opaque hashes only; 3 provides raw source; 5 combines readable file/release context and clear link labels. |
| E6 | Self-contained usefulness of both P1 and P2 | 7 | 0 requires finding another issue; 3 gives indirect context; 5 gives each issue the evidence needed to interpret its own workflow expectations. |
| E7 | Provenance and copyright hygiene | 4 | 0 copies unattributed third-party code; 3 includes provenance with local copies; 5 links official upstream source and paraphrases only the needed facts. |
| E8 | Ongoing maintenance burden | 3 | 0 adds network test infrastructure; 3 needs several links updated with pins; 5 naturally changes only when the approved action pin changes. |
| E9 | Issue-edit churn | 2 | 0 adds files/scripts; 3 adds many annotations; 5 replaces or supplements a few Reference bullets. |

#### Scoring rules

- Raw scores are integers from 0 to 5; weighted total is
  `raw score / 5 × weight`.
- E1 and E2 must each score at least 4.
- A release page can explain a version but cannot by itself earn immutable-identity
  credit.
- A link set should include only source files that materially support issue claims.

### Scoring table

| Option | E1 | E2 | E3 | E4 | E5 | E6 | E7 | E8 | E9 | Weighted total | Gate result |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A — moving v7/v8 links | 0 | 4 | 1 | 1 | 5 | 5 | 5 | 5 | 5 | 47.2 | Fails E1 |
| B — patch-tag links | 2 | 4 | 3 | 2 | 5 | 5 | 5 | 5 | 5 | 66.8 | Fails E1 |
| C — full-SHA raw links | 5 | 5 | 5 | 5 | 3 | 5 | 5 | 5 | 5 | 96.0 | Pass |
| D — full-SHA blob/line links | 5 | 4 | 5 | 5 | 5 | 5 | 5 | 4 | 4 | 95.0 | Pass |
| E — exact sources plus releases | 5 | 5 | 5 | 5 | 5 | 5 | 5 | 4 | 4 | **99.0** | Pass |
| F — commit page only | 5 | 2 | 3 | 5 | 3 | 3 | 5 | 5 | 5 | 74.8 | Fails E2 |
| G — locally copied action source | 5 | 5 | 5 | 4 | 3 | 5 | 1 | 1 | 0 | 86.4 | Pass |
| H — release/docs only | 2 | 2 | 2 | 3 | 5 | 4 | 5 | 5 | 5 | 56.2 | Fails E1/E2 |
| I — source hashes plus moving links | 3 | 5 | 4 | 3 | 2 | 5 | 5 | 2 | 2 | 72.6 | Fails E1 |
| J — automated link verifier | 5 | 5 | 5 | 5 | 2 | 5 | 5 | 0 | 0 | 89.0 | Pass |
| K — P2 links only to P1 | 4 | 4 | 4 | 5 | 4 | 1 | 5 | 5 | 5 | 79.6 | Pass |

Option E is strongest: full-SHA files establish the exact behavior, while release
pages explain why those commits are labeled v7.0.1 and v8.0.1.

### Selected resolution

Select **Option E: exact full-SHA source links plus exact patch-release pages**.

Replace the moving P1 and P2 Reference bullets with clearly labeled links to:

#### Upload action v7.0.1

- Exact `action.yml`:
  `https://raw.githubusercontent.com/actions/upload-artifact/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a/action.yml`
- Exact README:
  `https://raw.githubusercontent.com/actions/upload-artifact/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a/README.md`
- Release:
  `https://github.com/actions/upload-artifact/releases/tag/v7.0.1`

#### Download action v8.0.1

- Exact `action.yml`:
  `https://raw.githubusercontent.com/actions/download-artifact/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/action.yml`
- Exact README:
  `https://raw.githubusercontent.com/actions/download-artifact/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/README.md`
- Exact implementation:
  `https://raw.githubusercontent.com/actions/download-artifact/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/src/download-artifact.ts`
- Release:
  `https://github.com/actions/download-artifact/releases/tag/v8.0.1`

P1 should additionally include the exact checkout v6.0.2 metadata and README,
v6.0.2 release, GitHub Node 20 deprecation notice, and GitHub secure-use reference
selected under P1-3.

Implementation rules:

1. Use full 40-character SHAs in every source URL.
2. Keep exact patch-release pages only as explanatory companions; never cite them as
   immutable source.
3. Label each link by file and release so a reader knows which claim it supports.
4. Keep P2 self-contained by repeating the exact artifact-action links relevant to
   its inherited workflow evidence.
5. If implementation-time reverification chooses newer approved action releases,
   update workflow pin, same-line release comment, exact source URLs, implementation
   URLs, and release URLs as one atomic evidence change.
6. Remove all raw `/v7/` and `/v8/` source URLs from both issues.
7. Do not copy third-party source files into the repository and do not add a
   network-dependent link verifier.

This ensures the prose, executable pin, and cited implementation cannot drift apart.
