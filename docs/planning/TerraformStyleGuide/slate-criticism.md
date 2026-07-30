# Feedback on the TerraformStyleGuide T1/T1A/T1B/T2/T3/T4 issue slate

## Overall assessment

The revised slate is substantially stronger and is grounded in the current
TerraformStyleGuide implementation. The T1/T1A/T1B split now gives generation,
candidate validation, and promotion separate review boundaries without creating
a shared cross-repository runtime dependency. T2 correctly separates historical
version retrieval from destructive mutation, T3 treats npm advisories as a
governed state rather than merely a package bump, and T4 gives destructive state
operations the caution they warrant.

Keep the intentional H1 issue titles and the P/T shorthand. I would also keep
the six-issue decomposition. I would not file the T slate unchanged, however.
Eight of the findings below are contract blockers: the issue text either
contradicts the stipulated execution order, disagrees with the corresponding P
contract, promises an interface no predecessor creates, or requires an outcome
that cannot always be performed. The remaining findings are precision gaps that
would otherwise transfer material policy decisions to the implementer.

The required execution order for this review is:

1. T1;
2. T1A;
3. T1B;
4. T2;
5. T3; and
6. T4.

| Finding | Issue(s) | Priority |
| --- | --- | --- |
| S-01 | Whole slate | High |
| G-01 | P1, T1 | High |
| T1-01 | T1, T1B, T2-T4 | High |
| T1A-01 | T1A | High |
| CAT-01 | T1A, T3, T4 | High |
| T1B-01 | T1B | Medium |
| T1B-02 | T1B | Medium |
| PIN-01 | T1, T1B | Medium |
| T2-01 | T2 | High |
| T3-01 | T3 | High |
| T3-02 | T3 | Medium |
| T4-01 | T4 | High |

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
- the PSStyleGuide planning state at
  [`3a0dc2ae977b3161fbef32f8c25ca101290901be`](https://github.com/franklesniak/PSStyleGuide/commit/3a0dc2ae977b3161fbef32f8c25ca101290901be);
- the matching TerraformStyleGuide planning state at
  [`e463bbb9a342d6e1807e06ac7604237ac4903dcd`](https://github.com/franklesniak/TerraformStyleGuide/commit/e463bbb9a342d6e1807e06ac7604237ac4903dcd);
  and
- live TerraformStyleGuide `main` at
  [`6ee3f57b2b71b885a5927b770dde47532944de62`](https://github.com/franklesniak/TerraformStyleGuide/commit/6ee3f57b2b71b885a5927b770dde47532944de62).

The six T issue bodies in the two local planning trees are byte-identical. The
live TerraformStyleGuide repository had no open issue or pull request at review
time. Its generator still has edition-dependent final writes and no generator
version, its workflows still use mutable action tags and a direct broad writer,
and its guide still contains the unsafe state-recovery surfaces inventoried by
T2/T4. The slate is therefore aimed at real current defects rather than
hypothetical cleanup.

## Findings that should be corrected before filing

### S-01: The issue bodies still permit a different execution graph

T1 calls T1-first the “default order” and permits T3 to run first when advisory
policy requires immediate remediation. T2 retains a corresponding
npm-remediation-first branch. T3 again says it may run before T1/T1A/T1B/T2.
That is inconsistent with the premise that these issues execute one at a time
in the listed order.

The dated npm risk decision remains useful, but it should be a go/no-go gate for
the stipulated slate, not a second dependency graph embedded in three issues.
Under this review's premise:

- T1 records the decision;
- a decision permitting temporary exposure allows T1 to proceed;
- a decision refusing temporary exposure stops the slate for rework; and
- if T3 truly must run first, renumber and rewrite the complete slate before
  filing rather than leaving two supported orders in the issue bodies.

Remove the conditional-order language from T1, T2, and T3 after choosing the
filing graph.

### G-01: P1 and T1 already have a known generator-contract blocker

T1 says identical security, error, byte, and write behavior is the default and
that an unexplained difference blocks merge. The supplied P1 and T1 drafts do
not currently meet that rule:

- P1 permits an absent destination leaf and calls
  `System.IO.File.WriteAllText` exactly once.
- T1 requires all four destinations to exist, creates and durably flushes an
  unpredictable sibling, calls `File.Replace` exactly once, and expressly
  prohibits `File.WriteAllText`.
- Their failure-state contracts consequently differ as well: P1 has a direct
  complete-payload write, while T1 promises preservation of an old destination
  through the replacement boundary.

This is not a repository-specific filename, frontmatter, or topology
difference. It is the core observable write and failure contract. The reciprocal
matrix would have to classify it as a blocker on day one.

Decide the shared final-write contract before the issues are filed. If atomic
same-directory replacement is the desired common design, coordinate a matching
P1 change. If the deliberately simpler one-write contract is desired, align T1
with it. Keep repository-local implementations and tests, but make the
destination existence rules, serialization boundary, write count, and
failure-state semantics genuinely equivalent.

### T1-01: Successors consume a reusable Git reader that no predecessor creates

T1 describes raw `BaseStream`/NUL parsing and native-status classification, but
its exact eight affected files contain no reusable Git path/status helper. Its
JavaScript workflow-policy validator explicitly performs no child process. T1B
extends the behavior in prose, but its exact three affected files also create no
such helper. T2 nevertheless says to “consume T1B's merged native Git
reader/status classifier” with closed endpoint modes. T2 cannot consume a
named, versioned interface that does not exist, and its affected-file set does
not include `build.yml`, where an inline T1/T1B implementation might otherwise
have lived.

T1 should add one tracked, repository-local helper comparable in role to P1's
`Test-ExactGitPathSet.ps1`. Define:

- its exact path and version marker;
- scalar CLI parameters and closed endpoint modes;
- stdout/result schema and exit classes;
- NUL/byte/path canonicalization rules;
- `0`/`1`/other/start/signal handling;
- permanent adversarial fixtures; and
- the exact downstream prerequisite hash/version handoff.

T1 should also adopt P1's common native-command rule for every complete
PowerShell `run:` block: explicit shell, stopping error preference, immediate
`$LASTEXITCODE` capture, output-shape validation, and nonzero failure. T1
currently states pieces of that rule for selected Git or Markdown commands but
does not establish it as a common cross-edition contract.

### T1A-01: Repeat-success candidate cleanup has no trustworthy disposed state

T1A's caller invocation context has a closed lifecycle with `Active`,
`CleanupInProgress`, `Disposed`, and `RetainedUncertain`. Its separate candidate
cleanup function accepts only the candidate envelope, ownership journal, and
primary failure. No candidate-lifecycle state is defined or returned. Despite
that, `T1A-K-03` requires a repeated candidate cleanup after safe removal to
succeed as a no-op.

On the second call, an absent candidate could mean either:

- the same invocation already completed safe candidate cleanup; or
- the candidate disappeared or was substituted before the first cleanup.

The stated inputs do not let the function distinguish those cases. Treating
absence as success weakens the fail-closed ownership model.

Define an invocation-bound candidate cleanup state with a closed schema,
identity, transitions, summary, and zero-filesystem-call `Disposed` behavior,
then pass and return that state through the production and harness paths.
Alternatively, remove the repeated-success oracle. Add separate negative cases
for missing-before-first-cleanup, forged disposed state, wrong invocation
identity, and retained-uncertain re-entry.

### CAT-01: Three “one result per ID” catalogs still contain families or missing oracles

The slate repeatedly says that a family/grouped row is not a final test result,
but three current catalogs still defer the required atomization:

- T1A has 109 case rows, but 70 do not contain a literal status and many omit
  the exact subreason, context state, cleanup sequence, diagnostics, or sentinel
  outcome required by its fixed result schema. `T1A-E-09` also combines root
  and ancestor link/reparse cases. General “inherit defaults” text cannot
  supply fixture-specific values that were never named.
- T3 says `NPM-01` through `NPM-03` and most `HOOK-*` cases run “for each
  supported platform/runtime combination,” which reuses one ID for multiple
  results. It lists inputs that should receive `NODE-POLICY-###` and
  `NODE-CLI-###` IDs without assigning those IDs, then postpones splitting
  remaining families until implementation.
- T4 says each confirmation grammar rejection requires its own immutable ID,
  but `SM-BASH-PUSH-07`, `SM-BASH-RM-02`, `SM-BASH-RM-03`, and
  `SM-BASH-RM-07` each combine several independently observable rejection
  cases.

Finish these catalogs in the issue bodies, or attach one canonical
machine-readable appendix per issue. Every row should already have one immutable
ID and every required field before implementation begins. Platform/runtime
dimensions should be encoded in distinct IDs or represented as one explicitly
applicable result—never both. Do not make the evidence-producing pull request
decide what the acceptance catalog meant.

### T1B-01: Two checkout descriptions contradict the truthful token model

T1B says the preparation and writer jobs check out with “credentials disabled.”
The same issue's exact input contract passes
`token: ${{ github.token }}` to every checkout, and its later job-token section
correctly says the writer checkout uses that token for authenticated fetch while
`persist-credentials: false` prevents persistence.

The pinned checkout manifest confirms that `token` defaults to
`github.token`; `persist-credentials` controls whether authentication is
configured for later Git commands. GitHub also creates the job token at job
start and exposes it through `github.token`.

Replace both “credentials disabled” statements with precise language such as
“authenticated transient checkout with credential persistence disabled.”
Require the post-checkout inspection to prove stored checkout authentication is
absent. Do not let the validator certify the stronger and false
credential-disabled description.

Primary references:

- [Pinned checkout action manifest](https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml)
- [GitHub Actions `GITHUB_TOKEN`](https://docs.github.com/en/actions/concepts/security/github_token)

### T1B-02: Failure diagnostics are not a closed producer/consumer contract

T1B reserves Windows and writer diagnostic-upload roles and says they use exact
test-owned paths with explicit missing-file behavior. It does not select:

- the producer step and stable step ID;
- the bounded/redacted file or directory it creates;
- the output name carrying that path;
- the literal upload path expression;
- the exact collision-free names; or
- the `if-no-files-found` value.

The corresponding P1B draft already supplies a useful shape:
`${{ steps.failure_diagnostics.outputs.diagnostic_path }}` and
`if-no-files-found: warn`, with explicit job/step roles and names. T1B need not
copy P-specific identifiers, but it should be equally complete. Define the
producer, its bounded content contract, output, two exact upload paths/names,
missing-file behavior, and validator fixtures before filing.

### PIN-01: Action-tag provenance is checked only before implementation

T1 and T1B require official release-tag resolution immediately before
implementation, but neither repeats that exact provenance check immediately
before merge. Their reciprocal P comparisons do run twice, which makes the
omission more conspicuous. P1 and P1B already require both checks.

A full commit SHA is immutable, but the release tag used to justify it can move
or disappear while the pull request is in progress. Add the same timestamped
tag, release, repository, manifest, and relevant-default comparison immediately
before merge. Drift should stop for renewed review; it must not silently replace
the pinned SHA.

Primary reference:

- [GitHub secure use reference](https://docs.github.com/en/actions/reference/security/secure-use)

### T2-01: The labeled final Bash bodies do not implement their normative contract

T2's common and later normative contracts require an explicit Bash
shebang/runtime guard, one-time input snapshots, validation of every
provider-specific field, and unchanged use of the validated values. The three
provider recovery blocks are labeled “Final recovery body,” but:

- none includes the required shebang/runtime guard;
- AWS reads ambient `VERSION_ID` inside the provider function;
- Azure reads ambient `AZURE_VERSION_ID` inside the provider function;
- GCS reads `GCS_GENERATION` more than once and constructs the provider argument
  from the ambient value;
- bucket, key/account/container/blob/object values are hard-coded rather than
  snapshotted and checked under the later field grammars; and
- the shown bodies therefore cannot satisfy the promised endpoint,
  control-byte, metacharacter, unchanged-argv, and one-read fixtures.

The statement that the later normative text supersedes a “shorter illustrative
guard” does not solve this: these are labeled final full bodies, their marker
inventory is intended to extract them, and the permanent harness is required to
execute the exact finalized blocks.

Replace each displayed final body with the actual contract-compliant copyable
block. Snapshot every external input once into a scalar, validate only the
snapshot, and use only that snapshot in provider argv. Include the selected
Bash minimum/runtime guard and every field grammar. If the long blocks are not
intended to be canonical, relabel them as noncopyable pseudocode and put one
exact executable source of truth elsewhere in the issue.

### T3-01: Observed audit findings and approval records are conflated

T3 defines current normalized `Findings` to include a chosen disposition and
evidence date/tool version. Its exception `findings` add analysis, compensating
controls, owner, approval identity, timestamps, follow-up evidence, and other
governance fields. It then requires exact equality between current normalized
`Findings` and approved findings.

Literal object equality cannot hold between those shapes, and the current audit
report cannot independently derive an approval disposition or approval
metadata. If a projection was intended, its keys and comparison rules are not
defined.

Use two closed structures:

1. `ObservedFindings`, derived only from the captured audit report and lock/tree
   evidence; and
2. `Approvals`, keyed by exact `(Package, AdvisoryUrl)` and containing governance
   metadata.

Require exact key-set equality. Require exact equality only for explicitly
copied observed fields such as severity, vulnerable range, source ID, fix
availability, and topology hash. Then validate approval-only fields separately.
Specify invalidation when any observed security field, path topology, source,
fix availability, scope, or expiry changes.

### T3-02: The scheduled governance event has no exact schedule

T3 makes the read-only schedule part of the event-policy and expiry-governance
acceptance contract but specifies only “a read-only UTC schedule.” It gives no
cron expression, cadence, or exact time. That leaves a security-relevant
execution frequency and a structural-validator expected value to the
implementer.

Choose the literal cron schedule in the issue, state that scheduled/manual
inputs are absent unless deliberately needed, and add positive and mutated-cron
fixtures. The cadence should be short enough that a 30-day exception cannot
remain unnoticed for a material period after expiry.

### T4-01: A generic no-force rollback command cannot be promised

T4 permits a proposed state serial equal to or greater than the current remote
serial and prohibits `-force`. It nevertheless requires a tested rollback
command using the just-created pre-push backup.

After a successful push with a higher serial, that backup has a lower serial
than the new remote. Terraform's normal safety checks reject a push when the
remote serial is higher than the state being pushed. The prohibited `-force`
flag is the escape hatch for that check. Therefore the checklist cannot promise
that the old backup is always directly pushable as a no-force rollback.

Keep the backup as mandatory recovery evidence, but change the rollback
contract:

- prefer backend/HCP state-version restoration and vendor support;
- allow a no-force `terraform state push` rollback only after a fresh pull
  proves lineage and serial permit it;
- otherwise require a new incident decision and backend/provider-specific
  recovery plan; and
- never automatically adjust a serial, force, retry, or roll back.

Add a case where the post-push remote serial is higher than the backup and prove
the generic rollback command is not offered or executed.

Primary reference:

- [Terraform `state push` safety checks](https://developer.hashicorp.com/terraform/cli/commands/state/push)

## Source ambiguity to preserve explicitly

Do not restore the previous categorical criticism that remote
`terraform state rm` never writes a local backup. HashiCorp's current command
pages are internally inconsistent:

- the [`state rm` page](https://developer.hashicorp.com/terraform/cli/commands/state/rm)
  describes `-backup` as a legacy local-state-only option; while
- the broader [`terraform state` page](https://developer.hashicorp.com/terraform/cli/commands/state)
  says modifying remote-state subcommands still write backups to disk and that
  `-backup` controls their path.

T4's conditional wording is therefore directionally safer than either
categorical claim. At implementation time, record the exact installed Terraform
version, backend mode, `terraform state rm -help` output, and a non-network
behavioral fixture. Inventory the actual backup path without claiming that one
generic flag contract applies to every version/backend.

## Strengths to preserve

The following revisions are good and should survive the corrections:

- The T1/T1A/T1B layering mirrors P1/P1A/P1B semantically while keeping each
  repository self-contained.
- T1 uses full action SHAs, a locked direct YAML parser, explicit
  action-input/default review, an honest job-token model, and an LF/BOM-less
  generator objective.
- T1A uses one retained byte stream for digest and ZIP identity, validates every
  path component, has finite archive limits, and separates candidate cleanup
  from caller-context cleanup.
- T1B uses build-owned events, a local `workflow_call`, four path-bound hashes,
  four unique matrix outputs, a terminal approval job, exact ref/SHA/parent/
  lease/refspec checks, and an isolated evidence ref.
- T2 and T4 correctly separate provider-version retrieval from destructive
  mutation, prohibit clobbering protected destinations, and require permanent
  non-network harnesses.
- T3 uses a hashed Corepack package-manager identity, a finite Node policy,
  pure validators, read-only recurring governance, and bounded exceptions.
- T4's Windows raw-stream, strict UTF-8, ACL, file-identity, and no-replace
  requirements are unusually careful, and its no-force/no-lock-bypass posture
  is correct.

## Recommended disposition

Revise the twelve findings above, rerun the reciprocal P/T contract comparison
against the revised text, and then file the six T issues in the one stipulated
order. The issues should record real URLs and `blocked-by` relationships only
when filed, and each successor should consume the actual protected-branch merge
commit—not a planned head or predicted merge value.

No additional issue split is necessary. The work needed here is contract
closure: decide the common generator write model, create the missing reusable
Git interface, make the catalogs atomic, and remove the remaining contradictions
before implementation begins.
