# Feedback on the TerraformStyleGuide T1/T1A/T1B/T2/T3/T4 issue slate

## Overall assessment

The revised slate is substantially stronger than the earlier T1/T2 draft. The
T1/T1A/T1B split gives generator serialization, the candidate validator, and
the write-enabled workflow separate review boundaries. It now has a direct
layer-for-layer counterpart in PSStyleGuide P1/P1A/P1B, which makes the stated
cross-repository unification goal testable without requiring a shared runtime
package. T2 and T4 separate provider-version retrieval from destructive state
operations. T3 is a real dependency-governance issue rather than an incidental
package bump.

Keep the intentional H1 titles, the T1/T1A/T1B/T2/T3/T4 naming, and the
stipulated linear order:

1. T1;
2. T1A;
3. T1B;
4. T2;
5. T3; and
6. T4.

I would not split the slate further before handoff. I would, however, correct
the findings below. The highest-priority defects are the unresolved alternate
T3-first sequence, T1's mismatch with the actual CRLF-bearing planning branch,
T1/T1B's under-specified workflow and credential policy, T1B's undefined
matrix-attestation aggregation, T3's npm-audit identity model, and T4's
untested PowerShell promise.

| Finding | Issue(s) | Priority |
| --- | --- | --- |
| S-01 | Whole slate | High |
| T1-01 | T1 | Blocker if the planning branch is the implementation base |
| T1-02 | T1, T1B | High |
| T1-03 | T1, T1B | High |
| T1-04 | T1 | High |
| T1B-01 | T1B | High |
| T1B-02 | T1, T1B | High |
| T1A-01 | T1, T1A, T1B | Medium |
| T1A-02 | T1A | Medium |
| T1A-03 | T1A, T1B | High |
| T2-01 | T2 | High |
| T3-01 | T3 | High |
| T3-02 | T3 | High |
| T4-01 | T4 | High |

## Review basis

This review considered:

- [T1](03TerraformStyleGuideT1.md);
- [T1A](03aTerraformStyleGuideT1A.md);
- [T1B](03bTerraformStyleGuideT1B.md);
- [T2](04TerraformStyleGuideT2.md);
- [T3](05TerraformStyleGuideT3.md);
- [T4](06TerraformStyleGuideT4.md);
- the revised [PSStyleGuide P1](../PSStyleGuide/01PSStyleGuideP1.md),
  [P1A](../PSStyleGuide/01aPSStyleGuideP1A.md),
  [P1B](../PSStyleGuide/01bPSStyleGuideP1B.md),
  [P2](../PSStyleGuide/02PSStyleGuideP2.md), and
  [P3](../PSStyleGuide/03PSStyleGuideP3.md) contracts;
- TerraformStyleGuide planning commit
  [`4c7bb1cecc9c392dd9b95db9387e81645d97c888`](https://github.com/franklesniak/TerraformStyleGuide/commit/4c7bb1cecc9c392dd9b95db9387e81645d97c888);
- TerraformStyleGuide `main` commit
  [`6ee3f57b2b71b885a5927b770dde47532944de62`](https://github.com/franklesniak/TerraformStyleGuide/commit/6ee3f57b2b71b885a5927b770dde47532944de62);
- the current generator, workflows, hook, package manifest, and lockfile;
- `git ls-files --eol` and raw-CR inspection of the supplied planning commit;
  and
- a fresh `npm audit --package-lock-only --json` run on 2026-07-29 with Node
  26.5.0 and npm 11.7.0. Those runtime versions were used only to inspect the
  current audit response, not as proposed T3 support evidence.

The six supplied T issue bodies match TerraformStyleGuide planning commit
`4c7bb1cecc9c392dd9b95db9387e81645d97c888` after normalizing their CRLF
checkout bytes to LF. The sibling TerraformStyleGuide worktree contains later
uncommitted issue-draft edits; this review uses the six supplied bodies and
that exact committed snapshot as its reproducible review basis. The four
reviewed action release tags also still resolve to the full commits named by
T1/T1B.

The live baseline still supports the slate's general purpose:

- the generator has four edition-dependent `Set-Content` artifact writes;
- `build.yml` has path filters, workflow-wide write permission, mutable action
  tags, persisted credentials, a direct push, and a skip-commit convention;
- `markdownlint.yml` uses mutable action tags and hosted Node 20;
- the package manifest has no Node policy;
- the hook has no Node guard; and
- the fresh audit still reports five high and two moderate vulnerability
  properties.

## Findings

### S-01: Resolve the advisory policy before filing one linear dependency graph

The requested operating assumption is one-at-a-time execution in the listed
order. T1, T2, and T3 nevertheless preserve a second graph in which T3 can run
first if policy prohibits carrying the current high-severity findings. That is
a reasonable planning question, but it is not a deterministic filed issue
sequence:

- T1 calls T3 an optional predecessor;
- T2 conditionally consumes either T1's Node 24 state or T3's final runtime
  state;
- T3 can depend on T2 or become T1's predecessor; and
- T4 always depends on both T2 and T3.

The current audit has real high findings, so this is not a theoretical branch.
Leaving the choice until implementation makes blocked-by relationships,
affected-file baselines, action-role inventories, Node/npm expectations, and
supersession evidence conditional.

PSStyleGuide P3 resolves the equivalent sequencing question by naming one
linear prerequisite chain. TerraformStyleGuide should be equally
deterministic.

Recommended correction:

1. Decide the repository/organization advisory rule before filing.
2. Under the stipulated order, record an explicit risk acceptance that permits
   T1/T1A/T1B/T2 to execute before T3, then remove the alternate-first text.
3. If that acceptance cannot be made, move and renumber the complete T3 issue
   before T1 and rewrite every dependency and baseline once.
4. Do not perform a partial package update outside T3 or maintain two live
   dependency graphs in the final issue bodies.

This does not require splitting T3. It requires choosing one sequence.

### T1-01: Reconcile the LF migration with the actual implementation base

T1 requires all of the following:

- add `.gitattributes` with `* text=auto eol=lf`;
- run `git add --renormalize .`;
- prove that the changed and cached path sets contain exactly T1's five
  affected files; and
- prove that tracked text blobs contain no CR byte.

Those requirements cannot all pass on the exact supplied planning commit. It
currently contains eight CRLF blobs:

```text
docs/planning/PSStyleGuide/prompt-01-in-repo.md
docs/planning/PSStyleGuide/prompt-01b-in-repo-with-criticism.md
docs/planning/PSStyleGuide/prompt-02-in-repo.md
docs/planning/PSStyleGuide/prompt-03-in-repo.md
docs/planning/TerraformStyleGuide/prompt-01-in-repo.md
docs/planning/TerraformStyleGuide/prompt-01b-in-repo-with-criticism.md
docs/planning/TerraformStyleGuide/prompt-02-in-repo.md
docs/planning/TerraformStyleGuide/prompt-03-in-repo.md
```

Git documents that text attributes affect index normalization and recommends
reviewing the paths produced by `git add --renormalize .`. T1 currently assumes
the prerequisite index is already LF-clean without making that a dependency.

Recommended correction:

1. Decide which exact commit will be T1's implementation base.
2. If the planning files will not merge to `main`, say that T1 starts from the
   exact LF-clean `main` commit and recheck that fact immediately before work.
3. If the planning commit will merge, normalize the eight prompt files in a
   prerequisite planning-only commit, then record that commit as T1's base.
4. Do not silently widen T1 to normalize arbitrary unrelated files. If another
   CR-bearing tracked text blob appears, stop and rebaseline the affected-file
   contract deliberately.
5. Add `git ls-files --eol`, raw index-blob inspection, and cached path-set
   evidence before and after renormalization.

This is a base-state problem, not a reason to weaken the exact path gate.

### T1-02: Make the action-role inventory normative instead of implementation-defined

T1's temporary action table identifies workflow, prose role, action, and count.
It does not make job ID, stable step ID, condition, or security-relevant
`with:` inputs part of the exact key.

T1B is looser at the most important transition. It lists roles “at minimum,”
says final YAML determines exact counts, and then asks a validator to prove
equality with the final table. That lets the implementation and its validator
define policy from the same result. An approved action can be moved to the
wrong job, given a weaker input, or duplicated in a newly blessed role without
violating a prior normative inventory.

P1 and P1B now have the stronger pattern that should be shared behaviorally:
one temporary and then one final authoritative role table keyed by workflow,
job ID, stable step ID, and action repository, with the exact SHA, release
annotation, condition, and complete allowed input set. Each table drives exact
set equality and all negative fixtures.

Recommended correction:

- Give T1 one exact temporary role table before implementation.
- Give T1B one exact final role table before implementation.
- Use stable step `id` values, not human-readable names, as role identity.
- Include at least checkout `ref` and `persist-credentials`, setup-node
  version/cache behavior, upload name/path/archive/overwrite/hidden-file/
  retention behavior, and download artifact-ID/path/decompression/digest
  behavior.
- Require exact role-set and exact input-set equality. Reject an unknown input
  even when the action would currently ignore it.
- Replace T1's temporary table atomically in T1B; do not retain two competing
  normative allowlists.
- Derive missing, extra, duplicate, misplaced, mutable, arbitrary-SHA,
  wrong-repository, wrong-comment, wrong-condition, and weakened-input
  fixtures from that single table.

Repository-local job names may differ from P1. The security and failure
semantics should not.

### T1-03: Apply one native-command contract to every PowerShell workflow block

T1 requires native-exit classification for the Markdown phases. T1B requires
immediate native Git status capture in the writer identity block. Neither
issue establishes the same rule for every other PowerShell block that runs
Git, npm, the generator, the helper, or a harness.

That matters across Windows PowerShell 5.1 and PowerShell 7.
`$ErrorActionPreference = 'Stop'` does not by itself give a uniform,
fail-closed contract for native processes, and
`$PSNativeCommandUseErrorActionPreference` is not available with identical
semantics across the supported editions.

Recommended correction:

- Port P1's native-command contract into T1 and make T1B preserve it.
- Every complete PowerShell `run:` block should select `powershell` or `pwsh`
  explicitly, begin with `$ErrorActionPreference = 'Stop'`, capture
  `$LASTEXITCODE` immediately after each native command, and validate output
  count/shape before use.
- Classify `git diff --exit-code` and `git diff --no-index --exit-code` as
  `0 = equal`, `1 = ordinary difference`, and every other value as a command
  failure.
- Treat every nonzero `git ls-remote --exit-code` result as failure and retain
  the native status in diagnostics.
- Require every tracked PowerShell script to terminate nonzero or throw on
  failure, and require its caller to check the resulting status before
  continuing.
- Add static fixtures that omit or delay a native status capture and prove the
  workflow-policy check rejects them.

This is a cross-edition correctness contract, not merely a writer hardening
detail.

### T1-04: Make generator convergence an executable, reciprocal contract

T1 says to obtain an unambiguous filesystem destination with
`GetUnresolvedProviderPathFromPSPath`, but it does not prescribe the complete
input/provider contract. Microsoft's API documentation states that the
unresolved-path API can accept wildcard-bearing input and leaves wildcard
characters unresolved. The one-result overload also does not itself prove the
FileSystem provider or turn “multiple resolution” into a meaningful check.

T1 should align with the corresponding P1 behavior:

1. reject null/empty, wildcard-bearing, relative, and ambiguous destination
   input before calling a .NET filesystem API;
2. use the overload that returns provider/drive metadata and require the
   FileSystem provider;
3. produce exactly one absolute provider-internal path;
4. normalize the complete final payload once;
5. serialize once with `UTF8Encoding($false)` and `WriteAllText`; and
6. report the captured destination plus underlying exception on failure.

T1 also has no generator-layer reciprocal comparison. T1A compares validator
behavior with PSStyleGuide, and T1B extends that matrix for workflows, but the
generator foundation itself is merely described as an intended unification
goal.

Add a P1↔T1 matrix at implementation start and before merge covering complete
payload boundaries, destination/provider rules, encoding/newline behavior,
script metadata, native exits, generated-byte evidence, Node/action
foundations, and deliberate repository-specific differences. Record exact
commits and classify every row as `same`, `intentional difference`, or
`blocker`. T1A should then add a P1A↔T1A validator matrix, and T1B should add a
P1B↔T1B writer matrix, rather than beginning comparison in the middle of the
slate.

Artifact names, frontmatter contents, and repository paths can remain
intentional differences. Unexplained generator byte/error differences cannot.

### T1B-01: Define a collision-free four-cell attestation channel

T1B's approval job must verify:

- exactly four expected Windows cells ran;
- each succeeded; and
- every cell reported the same artifact ID, digest, event SHA, and ref.

The issue does not define how four independent runners deliver those reports
to the approval job. Reusing one matrix job output name is unsafe: GitHub does
not guarantee matrix completion order, and the last matrix job to set a
duplicate output name overrides the value.

Recommended correction:

1. Define the exact four cell identities before implementation:
   `desktop/lf`, `desktop/crlf`, `core/lf`, and `core/crlf`.
2. Give each identity a unique output key or another immutable,
   collision-free attestation channel.
3. Require each cell to assert `strategy.job-total == 4`, its exact axis
   values, and the complete propagated tuple before emitting its uniquely
   named record.
4. Have approval require exact key-set equality, parse each record
   fail-closed, and compare every field to preparation's authoritative output.
5. Add fixtures for a missing key, duplicate key, unexpected key, empty
   record, malformed record, mismatched tuple, failed cell, and skipped cell.

Using four unique matrix-output names is sufficient if implemented exactly.
Four explicit jobs or four immutable success-attestation artifacts can also
work, but the latter changes the action-role table and artifact-retention
contract. Do not use one shared “matrix result” output.

P1B already defines the reusable static-output pattern:
`attestation_desktop_lf`, `attestation_desktop_crlf`,
`attestation_core_lf`, and `attestation_core_crlf`. TerraformStyleGuide may use
repository-appropriate names, but it should preserve the same collision-free
identity and exact-key-set behavior.

### T1B-02: Reconcile exact-push credential claims with job-scoped permissions

T1's temporary writer and T1B's final writer both give their job
`contents: write`, disable checkout persistence, and say the write credential
is exposed only for the exact push.

`persist-credentials: false` prevents checkout from leaving its token
configured for later Git commands; it does not shorten the lifetime or
permissions of the job's `GITHUB_TOKEN`. GitHub creates that token before the
job, applies `permissions` at workflow/job—not step—scope, and warns that an
action can access `github.token` even when the workflow does not explicitly
pass it. The current wording therefore promises a stronger credential
boundary than GitHub's job token provides.

Choose and specify one honest design:

- If the job-scoped write `GITHUB_TOKEN` remains, say that it exists for the
  complete minimal writer job. Limit the enforceable guarantee to no persisted
  Git credential and no explicit token materialization into a process/file
  except the push. Minimize and fully allowlist every step that can run in that
  job.
- For a true push-step-only write credential, keep the job token read-only and
  pass a separately governed, environment-protected, least-privileged
  credential only in the push step. Define its issuer, repository/ref scope,
  rotation/revocation, approval, masking, and negative tests. Account for any
  new secret or token-minting action in the affected files and exact role
  table.
- A minimal final write job is also defensible, but the issue must specify
  exactly what cryptographic evidence it trusts from the read-only
  revalidation job and must not imply that job permissions vary by step.

Whichever model is selected, test the actual boundary and update both T1's
temporary publication contract and T1B's final contract consistently.

P1B selects the first model and states its boundary honestly: the write-capable
job token exists for the whole minimal writer job, while checkout persistence
and explicit token materialization are prohibited except for the exact push.
Using that same model in T1/T1B would reduce cross-repository policy drift.

### T1A-01: Define the script-version metadata that later issues validate

T1 says to record a generator version using the repository's UTC convention.
T1A applies the same phrase to three new scripts. T1B then requires exact
versions before using them.

The current TerraformStyleGuide generator has no script-version field in
`.NOTES`, and the repository does not define a parseable script-version
convention. Guide-document version numbers do not by themselves define script
metadata, bump rules, or an extraction location. A downstream implementer
therefore cannot know which exact value T1B must validate.

Recommended correction:

- Define one exact metadata location and grammar in T1, such as a named
  `.NOTES` field.
- Define the UTC calculation/bump rule, initial value for newly added scripts,
  and when a revision increments.
- Give T1A's helper, context manager, and harness their expected
  implementation versions under that rule.
- Make T1B's prerequisite check parse the named field and compare exact values
  from the prerequisite commits.
- Use the same observable convention as P1 if practical, while keeping each
  repository self-contained.

### T1A-02: Test explicit null labels separately from explicit empty labels

T1A's public contract rejects explicitly supplied null or empty values for
`ArtifactId`, `RunId`, and `RunAttempt`. Its mandatory IDs cover omitted labels
and three explicitly empty strings, but no explicit null case.

PowerShell parameter binding can coerce a null value when the target parameter
is typed as `string`. The implementation must still prove that
`$PSBoundParameters` distinguishes omission from explicit binding and that
both forbidden forms fail before filesystem work.

Recommended correction:

- Add one explicit-null ID for each optional label. P1A uses `X-01..03` for
  empty values and `X-04..06` for explicit null values; matching that stable
  division would make the reciprocal matrix mechanical.
- Require the stable `parameter` phase, exact rejected parameter name,
  candidate absence, and proof that download enumeration/archive open did not
  start.
- Keep the three empty-string cases. Null and empty can share the same
  rejection result, but not the same test input.
- Add these cases to the reciprocal P1A↔T1A comparison and require exact
  agreement on omission, empty, and explicit-null behavior.

### T1A-03: Give the harness an exact context-manager dependency

The permanent harness accepts only mandatory `HelperPath`, yet T1A requires
every fixture to live under a context created by the production
`New-StyleGuideCandidateInvocationContext` function. That function is defined
in a different new script. The issue never says how the harness locates,
loads, or version-checks that script.

Without a public input, an implementation must derive a sibling path, depend
on caller session state, search an ambient location, or reimplement context
creation. Each option weakens T1A's “exact tracked production code” claim and
makes T1B's workflow invocation ambiguous.

Recommended correction:

- Add mandatory scalar `ContextManagerPath` to the harness, matching P1A's
  explicit `HelperPath` plus `ContextManagerPath` contract.
- Resolve both supplied paths once as exact tracked ordinary non-reparse
  files, validate their expected script versions, and dot-source only those
  resolved paths.
- Reject missing, relative, wildcard, wrong-provider, substituted, or duplicate
  identities before fixture creation.
- Make every local and T1B workflow call pass both exact paths.
- Add a stable negative case for a wrong/substituted context-manager path and
  prove no fixture root is created.

Do not fold caller-context functions into the archive helper merely to avoid a
second explicit dependency; their separate ownership and cleanup roles are a
strength.

### T2-01: Make the displayed provider blocks satisfy T2's own shell contract

T2 says every input is assigned once before validation. The displayed “Final
recovery body” blocks for AWS, Azure, and GCS instead read ambient
`RECOVERY_PATH` and provider identifiers repeatedly. They do not show the
required snapshot step.

T2 also says “Bash or a compatible POSIX environment,” while the GCS block uses
Bash-only `[[ value =~ regex ]]` syntax. Finally, the prose requires a
protected parent outside Git and shared world-readable temporary locations,
but the displayed blocks and mandatory harness cases do not say which parts
are mechanically checked and which are operator preconditions.

Recommended correction:

- Make all seven marked blocks explicitly Bash-only, or replace every
  Bash-only construct with a reviewed POSIX equivalent. The current harness
  and HCP requirements already favor declaring Bash.
- Snapshot each ambient input once inside the subshell and use only the local
  snapshot afterward.
- For HCP, keep `set +x` as the first subshell command and snapshot the token
  only after tracing is disabled.
- Present the exact complete final bodies, including snapshots, rather than
  mixing normative prose with incomplete “final” snippets.
- State which protected-parent properties the block verifies mechanically.
  Test those properties in the harness.
- State the remaining operator-owned/no-competing-writer assumptions as
  assumptions and do not claim the block proved them.
- Add a harness oracle that the exact snapshotted opaque version identifier or
  generation reaches the provider stub unchanged.

The current S3/Azure/GCS quoting and no-clobber strategy is otherwise sound and
should remain.

### T3-01: Use npm-audit-native identities and validate the consumed graph

The dated T3 baseline calls the five-high/two-moderate values “affected package
nodes.” In the current npm 11 report, those values are seven vulnerability
properties. Each property happens to contain one `nodes` path today, while the
same response contains fourteen object advisory records. Those are three
different units.

T3 then requires one exception per advisory URL/path pair. npm's report groups
object advisory records and package-level `nodes` under a vulnerability
property; it does not necessarily assert that every advisory object applies to
every installed path when several versions of one package are present.
Blindly cross-producting URL and path can approve unsupported tuples.

The revised P3 model is the safer reusable contract:

- approval identity is exact `(Package, AdvisoryUrl)`;
- `AuditNodePaths` is a separate exact package-keyed set copied from the
  vulnerability property;
- each node path must resolve to the matching package/version in the lockfile;
  and
- `npm explain` remains reviewer context, not approval identity.

Use a per-node model only if T3 resolves each installed version and applies
every advisory range with semver-correct logic.

T3 should also specify fail-closed validation for the exact npm version and
every JSON shape it consumes:

- audit report version;
- metadata severity fields and total;
- vulnerability property name/severity;
- `via`, `effects`, and `nodes` arrays;
- object advisory URL/severity/range;
- string dependency links and reciprocal graph targets;
- Boolean or reviewed-object `fixAvailable`; and
- audit exit status versus the derived actionable count.

Derive metadata counts from vulnerability properties. Count object advisories
and residual `(Package, AdvisoryUrl)` keys separately. Preserve the raw report
and exact npm version so an upstream schema change fails clearly instead of
silently dropping evidence.

### T3-02: Make the Node support set and npm selection executable

T3 correctly rejects an unbounded Node range, but it does not require the
default Node 22/24 policy to be represented as an exact set. A simple range
such as `>=22 <25` also admits Node 23, even though the issue describes
supported even-numbered LTS lines.

T3 also says to use “one selected supported npm” consistently. `setup-node`
selects Node, not one exact npm CLI. Node 22 and Node 24 can arrive with
different bundled npm versions, so the issue must either define how the same
npm is selected in every cell or stop promising one npm across cells.

P3 makes both choices executable: it uses a finite Node semver union and
installs/asserts one exact npm CLI in every cell, with one normative lockfile
producer. T3 should reuse that policy shape unless TerraformStyleGuide records
a repository-specific reason to differ.

Recommended correction:

- Express the reviewed Node lines as an exact semver union. For a final 22/24
  policy, admit reviewed Node 22 releases and reviewed Node 24 releases while
  excluding 23 and unreviewed future majors.
- Include any patch floor imposed by the selected npm CLI or package tree.
- Make the hook guard consume the same exact supported-major policy, not only
  a numeric minimum. Test rejected odd, below-floor, malformed, and unreviewed
  future majors before npm/lint starts.
- Choose one npm policy:
  - install and assert one exact npm version in every runtime cell and use it
    for lockfile generation, clean install, audit, lint, and the hook; or
  - explicitly allow each Node line's reviewed bundled npm, record each exact
    pair, select one normative lockfile-producing pair, and prove the other
    pair does not rewrite the lockfile.
- Run `engine-strict=true`, clean `npm ci`, `npm ls --all`, both production
  lints, and the tracked integration harness in every claimed Node/OS cell.
- Make `package.json`, the hook, workflow matrix, and acceptance text describe
  the same finite support set.

The existing T3 requirement for a real clean-installed Husky hook invoked by
`git commit` is excellent and should remain.

### T4-01: Either test the PowerShell equivalent or stop presenting it as equivalent

T4 requires a PowerShell manual-backup implementation with binary-safe
capture, `FileMode.CreateNew`, exact native-exit handling, and same-directory
no-replace publication. Its marker inventory and permanent harness, however,
cover only four `SM-*` Bash blocks in an Ubuntu shell workflow. No stable
PowerShell marker, Windows cell, or PowerShell-specific failure oracle proves
the promised equivalent.

That is especially important for a state file: encoding, native stdout,
no-replace publication, links/reparse points, and file-sharing behavior differ
between Windows PowerShell 5.1, PowerShell 7, and Bash.

Recommended correction:

- Either make the PowerShell text non-copyable explanatory guidance that
  points to the tested Bash workflow, or give it an exact marked block and a
  permanent test contract.
- If retained as copyable code, test it under Windows PowerShell 5.1 and
  PowerShell 7 on Windows with the same backup/publication cases: partial
  native output, nonzero Terraform exit, invalid/BOM state, existing file/
  directory/live-link/dangling-link destination, publication race, digest
  mismatch, and exact cleanup/retention.
- Require byte identity between captured native stdout and the validated state
  file; do not accept host text re-encoding as proof.
- Add the required test file/workflow role to T4's affected-file and action
  inventories before filing.

T4 should also correct its `state rm` backup wording. HashiCorp documents
`-backup` as a legacy option for local state only. For remote/HCP state, do not
imply that changing to a protected working directory will make
`terraform state rm` create a local command backup. Rely on the mandatory
pre-operation `SM-BACKUP-PULL` recovery point and provider/HCP version history;
use `-backup=<fresh-protected-path>` only for the supported local-state form.

## Recommended disposition

First choose one advisory-policy order as required by S-01. Under the prompt's
stipulated sequence, record the risk decision that permits the existing
findings to remain until T3 and keep:

1. **T1** — reconcile the exact base commit, then make generator destinations/
   bytes, LF policy, temporary workflow roles, action pins, native-command
   behavior, credential claims, script metadata, and the P1↔T1 comparison
   exact.
2. **T1A** — add the helper/context/harness with explicit empty and null-label
   cases and defined versions, pass the exact context-manager path into the
   harness, and complete the P1A↔T1A matrix.
3. **T1B** — replace the temporary role table atomically, define the four-cell
   attestation channel, choose an accurate credential-lifetime model, and
   activate the immutable candidate/writer topology with a P1B↔T1B matrix.
4. **T2** — make the seven Bash blocks internally complete and permanently
   test their exact snapshots, destinations, identifiers, and secret handling.
5. **T3** — remediate packages with audit-native identities, fail-closed graph
   validation, a finite Node support set, and an explicit npm-selection
   policy.
6. **T4** — consolidate destructive-state guidance and either test the
   PowerShell equivalent fully or narrow the copyable contract to Bash.

If a real policy forbids carrying the current high findings through T2, do not
call T3 an optional exception inside this sequence. Move/renumber the complete
T3 issue, rewrite all dependencies, and hand off that single alternate slate.

When the drafts are filed, replace title-only dependency references with the
actual issue URLs and GitHub blocked-by relationships. Preserve exact merge
commit links for implementation evidence.

## Strengths to preserve

- The H1-as-title convention and consistent T1/T1A/T1B/T2/T3/T4 names.
- The T1/T1A/T1B decomposition and exact prerequisite commits.
- Complete-payload normalization immediately before BOM-less UTF-8
  serialization.
- Behavior-first comparison of P1/P1A/P1B with T1/T1A/T1B without a shared
  runtime package.
- The same-stream artifact digest/ZIP identity.
- Full-component containment/link checks and fail-closed journal cleanup.
- Stable adversarial helper IDs and real link/reparse coverage on both OS
  families.
- Immutable artifact ID plus propagated digest, decompression disabled, and
  exact candidate revalidation in the writer.
- Read-only validation, one terminal approval, one write job, exact remote
  preflight, exact parent, explicit refspec, and exact lease.
- T2's deliberate state-version selection and sensitive-response handling.
- T3's real installed-hook integration test and review-only Dependabot
  governance.
- T4's preference for declarative operations and its refusal to teach force,
  lock bypass, automatic rollback, or routine manual state mutation.

## Primary references

- [TerraformStyleGuide reviewed planning commit](https://github.com/franklesniak/TerraformStyleGuide/commit/4c7bb1cecc9c392dd9b95db9387e81645d97c888)
- [TerraformStyleGuide reviewed `main` commit](https://github.com/franklesniak/TerraformStyleGuide/commit/6ee3f57b2b71b885a5927b770dde47532944de62)
- [Git: `gitattributes`](https://git-scm.com/docs/gitattributes)
- [PowerShell unresolved provider path API](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.pathintrinsics.getunresolvedproviderpathfrompspath)
- [GitHub Actions workflow syntax: matrix job outputs](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#using-job-outputs-in-a-matrix-job)
- [GitHub Actions contexts: matrix strategy metadata](https://docs.github.com/en/actions/reference/workflows-and-actions/contexts#strategy-context)
- [GitHub: use `GITHUB_TOKEN` for authentication](https://docs.github.com/en/actions/tutorials/authenticate-with-github_token)
- [GitHub Actions workflow token permissions](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#permissions)
- [PowerShell preference variables](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_preference_variables)
- [npm: `npm audit`](https://docs.npmjs.com/cli/v11/commands/npm-audit/)
- [npm: `package.json` engines](https://docs.npmjs.com/cli/v11/configuring-npm/package-json#engines)
- [HCP Terraform state-versions API](https://developer.hashicorp.com/terraform/cloud-docs/api-docs/state-versions)
- [Terraform: `state pull`](https://developer.hashicorp.com/terraform/cli/commands/state/pull)
- [Terraform: `state push`](https://developer.hashicorp.com/terraform/cli/commands/state/push)
- [Terraform: `state rm`](https://developer.hashicorp.com/terraform/cli/commands/state/rm)
