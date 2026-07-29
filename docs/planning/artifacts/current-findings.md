# PSStyleGuide P1/P2 review findings

## Overall assessment

The slate is directionally strong, preserves the requested P1/P2 naming
convention, and orders the work correctly. The H1 issue titles should remain:

1. P1: `Make artifact generation byte-deterministic across PowerShell editions
   and hosts`
2. P2: `Make the non-compliant blank-line example visibly distinct`

P1 is not ready to file unchanged. Its held-stream verification design, exact
action pins, least-privilege workflow split, deterministic writer contract,
stable fixture IDs, and lease-protected synchronization are all strong.
However, four correctness problems need resolution before filing:

- its P1/T1 parity claim is materially broader than the actual convergence;
- its path-envelope contract is incomplete;
- its rejection postconditions contradict its pre-existing-leaf fixtures and
  omit fail-closed cleanup after candidate creation; and
- its fixed workflow download path does not satisfy its own unique trusted-root
  contract.

P2 has no independent blocking defect. It is appropriately narrow and should
remain P2 after P1. Its prerequisite wording must be refreshed after P1 is
corrected. One low-severity mechanical validation improvement is identified
below.

T1 and T2 were used only as supplied cross-repository context for evaluating
P1 convergence and P2 ordering. They were not independently critiqued.

## Review basis

The following material was reviewed from the current worktree:

- `docs/planning/PSStyleGuide/01PSStyleGuideP1.md`
- `docs/planning/PSStyleGuide/02PSStyleGuideP2.md`
- `docs/planning/PSStyleGuide/slate-criticism.md`
- `docs/planning/TerraformStyleGuide/03TerraformStyleGuideT1.md`
- `docs/planning/TerraformStyleGuide/04TerraformStyleGuideT2.md`
- the generator, workflows, package lock, generated artifacts, and repository
  attributes at the exact current `origin/main` commit
  `4346310e7deebffb4159c75e30d9546263dfd649`

The local review branch was `planning-CRT-PR-852` at
`0aa910138055fde7ef8fa0fb54af4ed0b0559dd3`. P1 and P2 were reviewed at these
worktree hashes and were not changed by this review:

- P1 SHA-256:
  `87DEA8653C9C7BB3FF7229128AC4DAD5C413A40E7687C4852124606E90F12EDF`
- P2 SHA-256:
  `D84539FF65FAB257D0F8A0F7489199523B0FFC95BD300537AB7146C8EEA954F6`

## Supplied-criticism audit

### C-01: Replace the claimed near-total P1/T1 identity with an explicit convergence matrix

**Verdict: Confirmed; blocking P1 correction.**

P1 says the two repositories share the helper filename, interface, validation,
path, digest, enumeration, diagnostics, and harness contracts, then says only
four manifest names and artifact names intentionally differ. That is not
accurate. Important behavioral differences include:

- P1 hashes and parses one already-open `FileStream`; T1 hashes by path and
  opens the archive separately.
- T1 specifies a broader component-walk envelope, mutual root separation,
  post-extraction path revalidation, and a residual race model.
- T1 specifies fail-closed cleanup after output creation; P1 does not.
- The repositories use different artifact transport and workflow details, not
  merely different names.
- The permanent harness coverage and where it runs are not identical.

The issue should replace the blanket identity claim with a compact matrix using
at least these rows:

| Contract area | Intentionally shared | Repository-specific choice |
| --- | --- | --- |
| Helper parameters | Required and optional parameter names and meanings | Caller-specific diagnostic values |
| Archive identity | 64-hex expected/actual digest contract | PS held-stream verification; Terraform path-based flow unless deliberately changed |
| Path security | Agreed root/component/reparse-point invariants | Checkout and temporary-root names |
| Manifest grammar | Parsing rules, duplicate rejection, exact-entry policy | Manifest filename and permitted artifact names |
| Candidate lifecycle | No overwrite and truthful rejection state | Repository-specific destination names |
| Diagnostics | Stable categories and caller-owned labels | Artifact/run values |
| Harness | Stable case intent and failure oracles | Platform-specific setup/skips and workflow placement |
| Transport | Immutable artifact ID and fail-closed digest behavior | Action versions and archive/download shape |

This is the most useful near-term generator unification: converge the security
and observable-behavior contract while keeping repository-specific names and
transport explicit. A cross-repository shared module or action would introduce
its own release, trust, and compatibility boundary and should not be made a P1
prerequisite. If desired later, it should be a separately versioned project
after both repositories have an agreed contract matrix and matching fixtures.

### C-02: Adopt T1's complete path-envelope validation in P1

**Verdict: Confirmed; blocking P1 correction.**

P1 currently checks that roots resolve, rejects a reparse-point root, requires
the trusted temporary location to be outside the checkout, and walks existing
components between the trusted temporary root and the download/candidate
parent. It does not specify the whole security envelope claimed by its parity
language.

P1 should explicitly require:

1. canonical, absolute checkout and trusted temporary roots;
2. mutual non-containment, not only “temporary root is outside checkout”;
3. enumeration of every existing component from the platform path root
   (volume root or UNC share root) through each trusted root and through the
   archive/candidate parents;
4. rejection of reparse points or equivalent redirection objects anywhere in
   that enumerated envelope;
5. containment checks using platform-appropriate path comparison;
6. revalidation after extraction and before accepting or moving the candidate;
7. a documented residual race assumption, including that no competing writer
   may mutate the validated path envelope during the operation; and
8. permanent fixtures that prove the before/after checks and all supported
   link/junction cases, with named platform-capability skips rather than silent
   omission.

The issue should state precisely which checks are shared with T1 and which P1
implements differently because it deliberately keeps one archive stream open.

### C-03: Keep the held-stream design, but choose the sharing mode explicitly

**Verdict: Partially confirmed; required clarification, but the specific enum
value is not uniquely determined.**

The important criticism is valid: “an explicitly selected sharing mode” leaves
a security-relevant implementation choice to the implementer. P1 should name
the exact `FileShare` value and explain the permitted concurrency.

The recommendation that it must be `FileShare.Read` is reasonable but not
logically required:

- `FileShare.Read` permits other readers while denying subsequently opened
  writers through the .NET sharing contract.
- `FileShare.None` is stricter and is defensible because the workflow has no
  identified legitimate concurrent reader.

The issue should choose one. If audit/diagnostic readers are intentionally
allowed, select `FileShare.Read` and test that declared contract. If no
concurrent access is needed, select `FileShare.None`. In either case, keep the
stronger P1 property: compute the digest, rewind, and construct `ZipArchive`
from the same held stream so the parsed bytes are the verified bytes.

### C-04: Make rejection postconditions truthful and add fail-closed cleanup

**Verdict: Confirmed; blocking P1 correction.**

P1 contains three incompatible statements:

- every rejection row must leave the candidate leaf absent;
- fixtures `L-01` through `L-04` begin with a pre-existing file, directory,
  link, or dangling link and require it to remain unchanged; and
- acceptance text alternates between “failures leave it absent” and
  “absent or pre-existing unchanged.”

The harness and acceptance criteria need per-case postconditions:

| Starting state | Required rejection postcondition |
| --- | --- |
| Candidate leaf absent | It remains absent |
| Pre-existing file | Same file remains unchanged |
| Pre-existing directory | Same directory remains unchanged |
| Pre-existing link/junction/dangling link | Same object and target text remain unchanged |
| Candidate created by this invocation, followed by later failure | Invocation-owned candidate is removed |

The helper must track whether it created any candidate state. If a later
validation, move, or finalization step fails, it must attempt cleanup without
touching pre-existing state. A cleanup failure must itself fail the operation
with diagnostics that retain both the original error and cleanup failure; it
must not report a clean rejection while leaving an untrusted candidate behind.

The blanket sentence at P1's rejection-table introduction and the blanket
“failures leave it absent” acceptance criterion should be replaced by this
case-aware contract.

### C-05: Make the trusted temporary-path example satisfy its own contract

**Verdict: Confirmed; blocking P1 correction.**

P1 requires a unique trusted temporary root with download and candidate paths
under it, but the workflow example uses the fixed path
`${{ runner.temp }}/style-guide-candidate-download`. That is a child path under
the runner temporary directory, not the unique trusted root described by the
helper contract, and it can be reused within the job environment.

Each consuming job should create a fresh directory using a platform-native
unique-name primitive, then derive both download and candidate children from
that directory. The job should:

1. create the unique root itself;
2. pass that exact root as `TrustedTemporaryRoot`;
3. place the downloaded archive and candidate only below it;
4. prove the paths are contained before invoking the helper; and
5. clean up only that invocation-owned root in an `always()`/`finally` path,
   surfacing cleanup failure according to the fail-closed contract.

The permanent harness should use the same layout. The issue should not show a
fixed path while requiring a unique one.

### C-06: Add an end-to-end malformed-transport drill

**Verdict: Partially confirmed; valuable evidence improvement, not a helper
correctness blocker by itself.**

P1 already includes direct invalid/truncated archive fixtures, successful
artifact transport, and a controlled wrong-propagated-digest drill. Those test
the helper rejection and the successful transport path. They do not prove that
an actually downloaded malformed payload reaches the same fail-closed
rejection boundary.

Add one controlled-branch drill that uploads known non-ZIP bytes as a distinct
single-file artifact, downloads that immutable artifact ID with the production
download settings, and proves:

- native transport completes for the bytes it was asked to carry;
- the helper rejects before manifest acceptance or candidate creation;
- the diagnostic category is archive format/structure, not digest, unless the
  test intentionally supplies a mismatched expected digest; and
- no write-enabled synchronization step runs.

If the drill is not added, narrow the evidence claims so they do not imply a
malformed payload was exercised through GitHub artifact transport.

### C-07: Add review-only GitHub Actions update governance

**Verdict: Partially confirmed; sound governance recommendation, not a P1
correctness blocker.**

P1's action references were checked against the pinned action metadata and are
current at review time:

- `actions/checkout` v7.0.1
- `actions/setup-node` v7.0.0
- `actions/upload-artifact` v7.0.1
- `actions/download-artifact` v8.0.1

All are pinned by full commit SHA and use the intended Node 24 action runtime.
The repository currently has no `.github/dependabot.yml`. Review-only weekly
updates for the `github-actions` ecosystem would reduce pin staleness while
preserving human review and exact-SHA policy.

This is governance scope, however, and the current P1 explicitly excludes it.
Choose and document one of two coherent dispositions:

1. include `.github/dependabot.yml` in P1, make it the sixth affected file,
   specify weekly review-only pull requests for directory `/`, and state that
   no auto-merge is introduced; or
2. retain P1's five-file limit and link a separate governance issue or
   organization-level policy that owns action-pin refresh.

The current unexplained “do not add Dependabot” exclusion should not be the
final disposition if cross-repository update governance is a stated goal.

### C-08: Track the current npm advisories as real work, not residual prose

**Verdict: Confirmed; separate maintenance work is required.**

On 2026-07-29, running
`npm audit --package-lock-only --json` in `.github/workflows` returned exit
code 1 with seven reported vulnerabilities: five high and two moderate. The
affected dependency graph included `brace-expansion`, `js-yaml`, `linkify-it`,
`markdown-it`, `markdownlint-cli2`, `minimatch`, and `picomatch`.

A GitHub issue search across open and closed repository issues found no issue
dedicated to npm audit/advisory remediation. Issue #137 concerns deterministic
Markdown linting, Husky hook installation, and line endings; it does not own
these advisories.

Do not silently fold dependency upgrades into P1 because that would mix
runtime/toolchain remediation with deterministic artifact transport. Create or
identify a separate issue, link it from P1's known-state section, and state its
ordering. At minimum that issue should require:

- review of direct and transitive advisory paths;
- an explicit decision on any pre-1.0 semver-major
  `markdownlint-cli2` upgrade;
- clean install and both outer/nested lint commands on the selected Node
  runtime;
- lockfile-only review for unrelated package churn; and
- a recorded disposition for any advisory that cannot immediately be removed.

### C-09: Keep CI evidence wording exact

**Verdict: Confirmed as a principle and already addressed in the current
drafts.**

The current P1 and P2 wording does not need the correction suggested here:

- pull-request evidence says only the two LF Windows cells run the permanent
  helper harness and lone-CR probe; the CRLF cells do not repeat it;
- controlled and post-merge push evidence says all four unconditional Windows
  consumers run the helper harness; and
- P2 says its expected no-drift push skips synchronization, while the P1
  controlled `has_changes=true` drill supplies writer-integration evidence.

Preserve that exact distinction when applying the other revisions. In
particular, do not replace “two LF pull-request cells” with “all four
pull-request cells,” and do not claim P2's expected no-drift merge executes the
writer steps.

### C-P2: Preserve P2's narrow design and refresh its P1 prerequisite

**Verdict: Confirmed.**

P2 correctly limits source edits to `STYLE_GUIDE.md` and
`STYLE_GUIDE_RATIONALE.md`, regenerates four derived artifacts, forbids
hand-editing generated files, keeps the compliant example unchanged, uses a
visible U+00B7 visualization rather than literal trailing spaces, and makes the
date bump conditional on actual metadata drift.

No broader transport, helper, action, Dependabot, or dependency-remediation
change belongs in P2. After P1 is revised, update P2's prerequisite summary so
it points to the final P1 helper/path/cleanup and governance dispositions
without duplicating their implementation.

## Independent findings

### I-P1-01: Local validation does not prove the Node 24 toolchain and lint paths

**Severity: Medium; completeness improvement.**

P1 changes both workflow action/runtime metadata and the Markdown lint
workflow, and its pull-request evidence expects the outer and nested lint
commands to pass. Its local validation blocks focus on PowerShell parsing,
generator execution, helper fixtures, artifact bytes, and staging. They do not
explicitly require a clean Node 24 install and both lint scripts.

Add a local validation block that:

1. asserts `process.versions.node` has major version 24;
2. runs `npm ci` in `.github/workflows`;
3. runs `npm run lint:md`;
4. runs `npm run lint:md:nested`; and
5. checks every exit code.

The review machine's active Node version was 26.5.0, so a local lint pass here
would not by itself prove the issue's Node 24 runtime contract.

### I-P1-02: Optional diagnostic-label fixtures do not cover the full contract

**Severity: Medium; test-oracle improvement.**

P1 requires `ArtifactId`, `RunId`, and `RunAttempt` to be caller-owned optional
diagnostic labels, requires omitted values to render as unavailable, and
rejects explicitly supplied empty values. The permanent table has only one
generic `X-01` empty-label case and a broad `D-01` reference to artifact/run
labels.

Add stable fixture rows for:

- all three labels omitted, with each rendered as unavailable;
- all three labels supplied, with their exact values preserved;
- explicitly empty `ArtifactId`;
- explicitly empty `RunId`; and
- explicitly empty `RunAttempt`.

Each rejection case should identify the exact bad label and prove no archive
parsing or candidate creation occurred. This removes ambiguity over whether a
single implementation path accidentally validates only one of the three
parameters.

### I-P2-01: The mechanical validator does not prove exactly one rationale heading

**Severity: Low; validation hardening.**

P2 says to extend the existing `### Blank Line Usage` rationale section and not
create a duplicate. Its mechanical checks exclude the canonical operational
snippet from the rationale and check the expected visualization, but they do
not count this heading.

Add an ordinal assertion that `STYLE_GUIDE_RATIONALE.md` contains exactly one
line equal to `### Blank Line Usage`. This catches accidental duplicate
sections even if Markdown lint configuration permits same-name headings under
different parents.

## Confirmed strengths

The following parts should be preserved while correcting P1:

- complete-final-payload normalization before every write;
- explicit UTF-8-without-BOM and LF-only byte requirements;
- first-executable-statement local-copy behavior in the writer;
- one-read input evaluation and deterministic null/array handling;
- `Get-FileHash -InputStream` followed by rewind and parsing of the same held
  stream;
- immutable artifact-ID and digest propagation;
- pinned full-SHA actions with explicit version annotations;
- read-only preparation/approval and one narrowly write-enabled synchronization
  job;
- exact remote-ref comparison, complete object IDs, exact force-with-lease
  shape, explicit `HEAD:<full-ref>` push, and no retry/adaptation path;
- stable permanent fixture IDs with named capability skips;
- P2's ordinal content checks, visible-space visualization, scope guard, staged
  rerun check, and precise no-drift evidence language.

## Required disposition before filing

P1 should not be filed until C-01, C-02, C-04, and C-05 are corrected.
C-03 must name and justify an exact sharing mode. I-P1-01 and I-P1-02 should be
added so the validation and diagnostic contracts are complete.

C-06 and C-07 are not blockers if their evidence/governance claims are narrowed
and they receive an explicit separate disposition. C-08 needs a real linked
maintenance issue, but dependency remediation should stay outside P1.

P2 may then be filed after its prerequisite text is refreshed. I-P2-01 is a
small, low-cost validation improvement and should be incorporated without
expanding P2's implementation scope.

## Validation performed during this review

- Compared the current P1 and P2 drafts with the supplied criticism one
  recommendation at a time.
- Compared P1's claimed shared contract against T1 without reviewing T1/T2 as
  independent issue drafts.
- Inspected the exact `origin/main` generator, build workflow, Markdown lint
  workflow, package metadata, attributes, and generated document state.
- Confirmed the current compliant and non-compliant fenced examples in
  `STYLE_GUIDE.md` are ordinally identical, establishing P2's baseline defect.
- Confirmed `STYLE_GUIDE_RATIONALE.md` currently contains one
  `### Blank Line Usage` heading.
- Parsed every P1 and P2 PowerShell validation fence under PowerShell 7.6.4 and
  Windows PowerShell 5.1 without syntax errors.
- Verified the pinned action metadata at each exact SHA, including Node 24
  action runtimes and the upload/download inputs P1 relies on.
- Ran the current package-lock audit and searched repository issues for an
  existing advisory-remediation owner.
- Preserved the reviewed P1 and P2 worktree bytes unchanged.

## Primary references

- [.NET `FileShare` enum](https://learn.microsoft.com/dotnet/api/system.io.fileshare)
- [.NET `FileStream` constructors](https://learn.microsoft.com/dotnet/api/system.io.filestream.-ctor)
- [GitHub Actions dependency updates](https://docs.github.com/code-security/dependabot/working-with-dependabot/keeping-your-actions-up-to-date-with-dependabot)
- [Dependabot configuration options](https://docs.github.com/code-security/dependabot/working-with-dependabot/dependabot-options-reference)
- [GitHub artifact attestations and integrity concepts](https://docs.github.com/actions/security-for-github-actions/using-artifact-attestations)
- [Node.js release schedule](https://nodejs.org/en/about/previous-releases)
