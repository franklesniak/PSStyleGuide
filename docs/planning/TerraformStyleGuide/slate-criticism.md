# Feedback on the TerraformStyleGuide T1/T1A/T1B/T2/T3/T4 issue slate

## Overall assessment

The revised slate is thoughtful, security-conscious, and aimed at real
TerraformStyleGuide defects. The T1/T1A/T1B layering gives generation,
candidate validation, and promotion separate review boundaries while keeping
both repositories self-contained. T2 separates historical-state discovery from
recovery, T3 treats npm advisories as governed state, and T4 gives destructive
state work substantially more protection than the current guide.

Keep the intentional H1 issue titles and the P/T shorthand. The stipulated
execution order for this review is:

1. T1;
2. T1A;
3. T1B;
4. T2;
5. T3; and
6. T4.

I would not file the T slate unchanged. Ten findings below are contract
blockers: the current text either contradicts that order, conflicts with the
corresponding P contract, consumes an interface no predecessor creates, leaves
its own pre-filing work incomplete, or requires behavior that is not valid for
the documented backend. The other findings are precision gaps worth closing
before implementation so that the implementer is not also asked to make policy.

| Finding | Issue(s) | Priority |
| --- | --- | --- |
| S-01 | T1, T3 | High |
| G-01 | P1, T1 | High |
| G-02 | P1A, T1A | High |
| T1A-01 | T1A | High |
| T1B-01 | T1B | Medium |
| PIN-01 | T1, T1B | Medium |
| T2-01 | T1, T1B, T2 | High |
| T2-02 | T2 | Medium |
| T2-03 | T2 | High |
| T2-04 | T2 | Medium |
| T3-01 | T3 | High |
| T3-02 | T3 | High |
| T3-03 | T3 | Medium |
| T4-01 | T4 | High |
| T4-02 | T4 | High |

## Review basis

This review considered:

- [PSStyleGuide P1](../PSStyleGuide/01PSStyleGuideP1.md),
  [P1A](../PSStyleGuide/01aPSStyleGuideP1A.md),
  [P1B](../PSStyleGuide/01bPSStyleGuideP1B.md),
  [P2](../PSStyleGuide/02PSStyleGuideP2.md), and
  [P3](../PSStyleGuide/03PSStyleGuideP3.md);
- [TerraformStyleGuide T1](03TerraformStyleGuideT1.md),
  [T1A](03aTerraformStyleGuideT1A.md),
  [T1B](03bTerraformStyleGuideT1B.md),
  [T2](04TerraformStyleGuideT2.md),
  [T3](05TerraformStyleGuideT3.md), and
  [T4](06TerraformStyleGuideT4.md);
- PSStyleGuide planning commit
  `713c1cd657b842e18466cb63e2b68d59fab1b0b4`;
- the TerraformStyleGuide planning checkout at
  `09a30857cefdfe985a1a5ce112bc0d69270da7c7`; and
- TerraformStyleGuide `main` at
  [`6ee3f57b2b71b885a5927b770dde47532944de62`](https://github.com/franklesniak/TerraformStyleGuide/commit/6ee3f57b2b71b885a5927b770dde47532944de62).

The six T issue bodies are byte-identical in the two local planning trees.
TerraformStyleGuide `main` still has edition-dependent `Set-Content` generator
writes and no generator version, broad write-workflow authority with mutable
action tags, a Node 20 Markdown workflow, an ambient npm/Husky hook path, and no
`.gitattributes` or Dependabot configuration. The proposed work therefore
addresses current repository state rather than hypothetical cleanup.

## Findings that should be corrected before filing

### S-01: The issue bodies permit a second execution graph

T1 calls T1-first the “default order” but permits T3 to run first when policy
requires immediate advisory remediation. T3 repeats that exception. That
conflicts with the supplied premise that the issues execute one at a time in
the listed order.

Keep the dated advisory decision, but make it a go/no-go gate for this slate:

- if temporary exposure is accepted, proceed with T1;
- if temporary exposure is not accepted, stop and reissue or renumber the
  complete slate; and
- do not leave both dependency graphs as supported paths in filed issues.

### G-01: P1 and T1 define different generator failure transactions

The common-generator objective and both reciprocal matrices make write and
failure behavior shared semantics unless an intentional difference is
explained. The current drafts already disagree:

- P1 computes all four payloads before mutation, creates a candidate and backup
  for every destination, retains all backups through post-verification, and
  attempts reverse-order restoration. It distinguishes `RolledBack` from
  `ReplacementStateUncertain`.
- T1 performs four independent final writes. Each creates one temporary sibling
  and calls `File.Replace(temp, destination, $null)` without a backup. Its
  failure contract is per-file old-or-new state, with no four-file restoration
  transaction.

This is not a repository-specific content or topology difference. It changes
the observable partial-failure state of the shared generator. Resolve it in the
issue text rather than asking the implementation-time reciprocal matrix to
discover a known blocker. The clearest unification is to give T1 P1's stronger
four-file transaction, including backup ownership, rollback ordering, bounded
diagnostics, and uncertain-state classification. If that is not the intended
common design, revise both contracts together and record the rationale.

### G-02: P1A and T1A disagree on terminal cleanup behavior

P1A makes `Disposed` and `CleanupFailed` terminal capability states. Repeated
calls make zero filesystem, provider, path, native, sleep, or enumeration calls
and never inspect a released name.

T1A's caller-context `Disposed` state is also zero-call, but its candidate
`Disposed` state revalidates parent components and enumerates the candidate leaf
on every repeat. A reoccupied name can move that object to
`RetainedUncertain`. T1A's reciprocal matrix explicitly compares terminal
states and cleanup sequences with P1A.

Both approaches avoid deleting a reoccupied object, but their observable
capability semantics differ. Choose one shared rule before filing. Otherwise
add a literal intentional-difference row with its security rationale,
applicability, expected calls, state transition, and paired P/T evidence. It
cannot currently be classified as reciprocal equality.

### T1A-01: T1A has not satisfied its own pre-filing catalog gate

T1A defines a closed result schema and immutable oracle profiles, then says:
“Every existing case table row must be transcribed with one profile and exact
variations before filing.” The current issue still contains the earlier
four-column case table. Many semantic keys remain ordinal
`candidate.*.case-N` names, rows have not been assigned one profile, and the
text still instructs the future author to split remaining disjunctions and add
catalog-integrity rows.

That is explicitly pre-filing work, not an implementation task. Finish one
canonical catalog in the issue or in a declared machine-readable appendix.
Every row should already contain:

- one immutable ID and semantic key;
- one exact profile;
- all row-specific values required by the result schema;
- one runtime/applicability set;
- one fixture identity;
- exact phase, subreason, state, cleanup, diagnostic, and sentinel outcomes;
  and
- no unresolved slash, range, family, “or,” or ordinal placeholder semantics.

The issue should then say the implementation transcribes and validates that
closed catalog, not defines it.

### T1B-01: Failure diagnostics are not a closed producer/consumer contract

T1B reserves Windows and writer diagnostic upload roles and requires
failure-only, collision-free, bounded artifacts with seven-day retention. It
does not give the workflow enough literal values to implement or structurally
validate that policy. Missing details include:

- the producer step and stable step ID;
- its exact bounded/redacted output file or directory;
- the output name carrying the path;
- literal artifact names and upload path expressions;
- the exact `if-no-files-found` value; and
- compression, overwrite, hidden-file, and archive settings.

P1B already demonstrates the needed degree of closure with exact producer
roles, expressions, `if-no-files-found: error`, `compression-level: 0`, and
archive settings. T1B can use T-specific names, but it should supply the same
complete producer/consumer contract and positive/negative validator fixtures.

### PIN-01: Provenance is frozen before implementation, not before merge

T1 re-resolves the Node/npm pair, YAML package, action release tags, manifests,
and defaults immediately before implementation. T1B similarly re-resolves its
action tags only at implementation start. Neither issue repeats the complete
freeze immediately before merge.

Pinned full SHAs are immutable, but the release tag and release metadata used
to justify them can move, disappear, or acquire a security warning while the
pull request is open. Match P1/P1B by repeating the complete provenance tuple at
a pre-merge freeze gate:

- repository and release/tag;
- full SHA and exact manifest digest;
- manifest input schema/defaults and runtime;
- Node archive and signed checksum;
- bundled npm version; and
- npm tarball/integrity and dated audit result.

Any drift should stop for renewed review rather than silently repinning.

### T2-01: T2 consumes a native Git interface no predecessor creates

T2 says to consume “T1B's merged native Git reader/status classifier” with
closed modes for porcelain status, cached diff, commit/parent diff, and quiet
checks. No such reusable interface exists in the declared predecessor scope:

- T1's exact eight files contain no tracked Git helper. Its
  `Validate-WorkflowPolicy.mjs` explicitly starts no child process.
- T1B's exact three files contain no reusable Git helper either. Its native Git
  handling is workflow-specific prose and inline behavior.
- T2 prohibits reimplementation but has no path, version, command line, or
  result schema to call.

Add a repository-local helper to a predecessor's affected files and handoff,
similar in role to P1's `Test-ExactGitPathSet.ps1`. Define its exact path and
version marker, scalar parameters, closed endpoint modes, raw-byte/NUL
semantics, status classes, stdout/result schema, exit handling, adversarial
fixtures, and prerequisite identity. Alternatively remove the consume claim
and place a complete reusable interface in T2's scope. A prose behavior is not
an API.

### T2-02: Two different HCP page grammars are normative

T2's public input map limits `TFC_PAGE_NUMBER` to
`[1-9][0-9]{0,19}`. Its finalized HCP validation rules later use
`^[1-9][0-9]*$`, with no 20-digit bound. The permanent cases cover empty,
zero, signs, leading zeroes, and non-digits, but do not decide the
20-versus-21-digit boundary.

Choose one grammar and use it in the public map, executable block, helper, and
case catalog. If the 20-digit cap is intentional, add 19-, 20-, and 21-digit
oracles and specify the numeric/string handling that prevents overflow. If
arbitrary-length decimal strings are intended, remove the cap everywhere.

### T2-03: “No reviewed reserved form” is not an executable AWS policy

The AWS bucket contract says “no reserved form” but never lists those forms.
The deliberately narrower character grammar happens to reject some official
reserved names; it still permits at least the `sthree-` and
`amzn-s3-demo-` prefixes and the `-s3alias` suffix. The issue also needs to
decide how its subset treats the documented `-an` suffix condition.

Copy the exact blocked prefix and suffix set into the issue, state whether it is
an intentionally frozen subset or tracks upstream, and add one fixture per
boundary. A link alone is insufficient for a permanent non-network harness.

Primary reference:

- [Amazon S3 general-purpose bucket naming rules](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html)

### T2-04: The required Bash minimum is left to the implementer

T2 requires an explicit Bash shebang/runtime guard but says to “select and
document the minimum Bash version” on the hosted runner. The selected version
controls which syntax the copyable blocks and permanent harness may use.

Put one literal minimum and exact rejection behavior in the issue. Test below,
at, and above that version, and identify the supported runner image only as an
environment expected to provide it—not as a substitute for the runtime guard.

### T3-01: Observed audit findings and approvals have incompatible schemas

T3's normalized current `Findings` include a chosen disposition and evidence
date/tool version. Its exception findings add analysis, controls, owner,
approval identity, timestamps, follow-up evidence, and other governance
metadata. The issue then requires exact equality between current normalized
`Findings` and approved findings.

The raw npm audit report cannot independently derive a chosen disposition or
approval metadata, and literal equality cannot hold between the described
shapes. Split the contract:

1. `ObservedFindings`, derived only from the captured audit report, installed
   tree, lockfile, and evidence envelope; and
2. `Approvals`, keyed by exact `(Package, AdvisoryUrl)` and containing
   governance-only metadata.

Require exact key-set equality. Compare only explicitly copied observed fields
exactly, such as severity, vulnerable range, source ID, fix availability, and
topology hash. Validate approval-only fields separately. Define invalidation
when an observed security field, installed path set, source, fix availability,
scope, or expiry changes.

### T3-02: The evidence manifest prohibits families that the catalog still uses

T3 says to prove `NPM-01..03`, `HOOK-01..06`, and related cases “for each
supported platform/runtime combination.” That produces more than one result for
the same ID. The manifest then rejects family rows and more than one result, and
the issue postpones splitting remaining `NPM-*`, `HOOK-*`, and `AUDIT-*`
families until evidence generation.

Finish the split in the issue. Either:

- give every platform/runtime case its own immutable ID; or
- define `(ID, Platform, Runtime)` as the primary key everywhere and remove the
  one-result-per-ID rule.

The first option fits the issue's existing acceptance language. Assign all
promised `NODE-POLICY-###` and `NODE-CLI-###` IDs now, include exact
applicability, and reject duplicate/missing/unknown final keys. The evidence
producer should not decide how many acceptance cases an issue ID meant.

### T3-03: The governance schedule has no literal schedule

T3 makes a read-only UTC schedule part of event-policy, expiry, and validation
acceptance but gives no cron expression, cadence, or exact time. That leaves a
security-relevant frequency and the workflow-policy validator's expected value
to implementation.

Select one literal cron expression in the issue and add exact positive,
mutated-cron, extra-schedule, and event-topology fixtures. Reusing P3's
`'23 17 * * 3'` would keep the two repositories aligned unless
TerraformStyleGuide needs a documented different cadence. A non-zero minute
also avoids GitHub's most congested start-of-hour window.

Primary reference:

- [GitHub Actions scheduled events](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule)

### T4-01: `state rm -backup` cannot be a universal remote-state contract

T4 requires every `terraform state rm` mutation to include
`-backup="$RM_COMMAND_BACKUP_PATH"` and declares an installed Terraform that
does not support that option unsupported. The current command-specific
Terraform documentation describes `-backup` as a legacy option accepted only
for local-state `state rm`. T4's canonical HCP and other remote-state paths
therefore cannot rely on that flag as a backend-neutral primitive.

The issue already has the right universal backup: a protected pre-mutation
`terraform state pull`. Make that capture, its identity, and its attestation the
backend-neutral recovery evidence. Include `-backup` only in an explicitly
local-state mode after a pinned-version capability check. Give local and remote
mutation modes separate exact argv and cases; never silently omit or retry a
flag.

Primary reference:

- [Terraform `state rm` command options](https://developer.hashicorp.com/terraform/cli/commands/state/rm)

### T4-02: The “every state-bearing role” tuple table is incomplete

T4 says every state-bearing role receives its own exact parent, path, and
attestation, but the table covers only the standalone backup, push
current/proposed/verification files, and state-rm backup/command-backup/
verification files. Later public helpers introduce more sensitive files
without completing that contract, including:

- current/proposed state-show documents, provider schemas, the review manifest,
  temporary indexes, and the redacted difference report;
- desired/current/recovery state and recovery review/report files;
- the state-rm match file and resolver report; and
- local-corruption source, destination, and intermediate evidence.

Some later sections say that tuples exist, but do not assign all exact public
input names, ownership, creation, identity, retention, cleanup, and failure
postconditions. That leaves path authority ambiguous in the most destructive
issue.

Enumerate every state-derived or state-bearing role in one canonical table.
For each role specify the exact parent/path/attestation input names, creator,
consumer, identity checks, maximum size, lifetime, cleanup owner, and
uncertainty behavior. If some scratch files are intentionally helper-private,
say so and define the one invocation-context object that derives and owns them;
do not describe them as separately supplied public paths.

## Scope and reviewability

The six-stage dependency shape is coherent, so none of the findings above
requires combining issues. T4 is nevertheless much larger than the other
stages: roughly 1,500 lines, sixteen affected files, multiple new PowerShell,
JavaScript, and Bash surfaces, offline state rendering/diffing, confirmation,
recovery, `state push`, and `state rm`.

Consider a T4/T4A split after the contracts are corrected:

- T4: protected capture, strict inspection, secret-safe structural difference,
  resource-address resolution, confirmation grammar, and permanent fixtures;
  and
- T4A: destructive push/rm execution, post-mutation verification, recovery,
  and operational evidence.

That split is a reviewability recommendation, not a substitute for closing the
shared contracts first. If T4 remains one issue, require distinct review
checkpoints and evidence bundles for the non-mutating foundation and mutation
layer.

## Strengths to preserve

The following parts are particularly strong and should survive the revisions:

- The T1/T1A/T1B layering mirrors P1/P1A/P1B semantically while avoiding a
  cross-repository runtime dependency.
- T1 uses exact Node/action pins, strict YAML parsing, action-input/default
  review, an honest token model, raw path evidence, and LF/BOM-less output.
- T1A uses one retained archive stream for digest and ZIP identity, validates
  path components, rejects unsafe cleanup, and exposes explicit lifecycle
  evidence.
- T1B uses immutable artifact ID/digest handoff, four Windows matrix cells, a
  terminal approval job, exact ref/SHA/parent/lease checks, and a real-writer
  evidence path.
- T2 separates discovery from recovery, uses hard-link/no-clobber publication,
  and defines signal, identity, and endpoint contracts.
- T3 uses a hashed package-manager identity, finite Node policy, local Husky
  verification, a bounded raw-audit process envelope, and live follow-up
  evidence.
- T4 avoids direct reuse of an old backup as a new proposal, requires a
  serial-successor recovery candidate, protects fresh capture, constrains
  resource addresses, produces a secret-safe difference projection, and
  prohibits force and lock bypasses.

## Recommended disposition

Revise the high-priority contract blockers before filing, close the medium
precision gaps in the same editing pass, and rerun the reciprocal P/T
comparison against the revised text. Then file the T issues in the one
stipulated order and record real issue URLs, `blocked-by` relationships, landed
merge commits, tool versions, and handoff identities as those values become
available.

The slate does not need a conceptual rewrite. It needs contract closure:
one generator failure transaction, one explained terminal cleanup model, a real
native Git interface, completed acceptance catalogs, executable input policies,
and backend-valid state mutation rules.
