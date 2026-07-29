# Feedback on the TerraformStyleGuide T1/T1A/T1B/T2/T3/T4 issue slate

## Overall assessment

The current slate is much stronger than the preceding draft. T1/T1A/T1B now
mirrors PSStyleGuide P1/P1A/P1B at the generator, candidate-validation, and
writer layers without introducing a shared runtime dependency. The validator
and workflow issues have concrete adversarial inventories. T2 and T4 separate
historical-version retrieval from destructive state mutation, and T3 defines a
durable audit-governance mechanism rather than only proposing a package bump.

Keep the intentional H1 titles, the P/T shorthand, and this execution order:

1. T1;
2. T1A;
3. T1B;
4. T2;
5. T3; and
6. T4.

I would not split the slate again. I would correct the findings below before
handoff. The highest-risk remaining defects are the still-conditional execution
order, implementation-defined action policy, an inaccurate writer-credential
lifetime claim, T2 copyable bodies that do not yet implement their own common
contract, npm reproducibility and audit-schema ambiguity in T3, and two
incorrectly generalized Terraform recovery claims in T4.

| Finding | Issue(s) | Priority |
| --- | --- | --- |
| S-01 | Whole slate | High |
| T1-01 | T1 | High |
| T1-02 | T1, T1A, T1B | High |
| T1A-01 | T1, T1A, T1B | Medium |
| T1A-02 | T1A | High |
| T1B-01 | T1, T1B, T2, T3, T4 | High |
| T1B-02 | T1, T1B | High |
| T2-01 | T2 | High |
| T3-01 | T1B, T3 | High |
| T3-02 | T3 | High |
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
  [`61a7dd04bc7d15e4b685d8f252c9535632f7c3f4`](https://github.com/franklesniak/PSStyleGuide/commit/61a7dd04bc7d15e4b685d8f252c9535632f7c3f4);
- TerraformStyleGuide issue-slate commit
  [`4c2c8a2aa3463cd3375b67574fde9f37d445ccb6`](https://github.com/franklesniak/TerraformStyleGuide/commit/4c2c8a2aa3463cd3375b67574fde9f37d445ccb6);
- TerraformStyleGuide planning head
  [`121e7e7d2210df49902590b0f1d23ef7074c9e30`](https://github.com/franklesniak/TerraformStyleGuide/commit/121e7e7d2210df49902590b0f1d23ef7074c9e30);
- TerraformStyleGuide `main`
  [`6ee3f57b2b71b885a5927b770dde47532944de62`](https://github.com/franklesniak/TerraformStyleGuide/commit/6ee3f57b2b71b885a5927b770dde47532944de62);
- current generator, workflow, hook, package, lockfile, and state-recovery
  source text;
- `git ls-files --eol`, action-release resolution, and the pinned actions'
  exact manifests; and
- a fresh `npm audit --package-lock-only --json` run on 2026-07-29 using
  Node 26.5.0 and npm 11.7.0.

The six supplied T bodies match the committed TerraformStyleGuide planning
branch after newline normalization. The later planning-head commit changes
prompts, not the six issue bodies. The remote planning branch and local branch
resolve to the same head, and `main` resolves to the exact commit above.

The earlier CRLF-base objection is resolved: the current TerraformStyleGuide
index has no CRLF or mixed-EOL blob, so T1's five-path renormalization gate is
feasible from this exact planning state. The four pinned action release tags
also resolve to the full commits named by T1/T1B.

The live implementation baseline still justifies the work:

- four generator destinations use edition-dependent `Set-Content`;
- the build workflow has path filters, workflow-wide write permission, mutable
  action tags, default checkout credential persistence, direct push, and a
  skip-commit convention;
- Markdown validation uses mutable action tags and hosted Node 20;
- the package manifest has no Node policy; and
- the hook has no Node-version guard.

The fresh npm audit report is version 2 and has seven vulnerability properties:
five high and two moderate. Those properties contain fourteen object-advisory
records and seven current `nodes` paths. These are distinct units.

## Findings

### S-01: File one deterministic dependency graph

The prompt says the issues execute one at a time in the listed order. The issue
bodies still define two possible graphs:

- T1 calls T1-first the default but permits T3-first after a policy decision;
- T2 conditionally consumes either T1B's Node 24 state or an earlier T3
  runtime/package state;
- T3 can follow T2 or precede and rebaseline T1/T1A/T1B/T2; and
- T4 depends on T2 and T3.

Requiring a dated decision is better than silently carrying advisories, but it
does not make the filed issue relationships deterministic. The current audit
has five high properties, so the alternate graph affects real risk, exact
package/lockfile baselines, action-policy fixtures, affected-file sets, and
blocked-by relationships.

Recommended correction:

1. Decide the repository or organization advisory rule before filing.
2. If the stipulated T1→T1A→T1B→T2→T3→T4 order is permitted, record the
   time-bounded risk decision once and remove the T3-first branches from every
   issue.
3. If policy requires immediate remediation, move and renumber the complete T3
   issue before T1, then rewrite every dependency, baseline, and supersession
   statement once.
4. Do not leave implementation-time authors to choose between two valid issue
   graphs.

This is an ordering decision, not a reason to split T3.

### T1-01: Specify one exact destination resolver and writer

T1 says to obtain one unambiguous path with
`GetUnresolvedProviderPathFromPSPath`, reject wildcard/non-filesystem/multiple
resolution, and then use a .NET write API. That is directionally correct but
not an executable contract.

The unresolved-path API has overloads with different observable information.
The simple result does not itself prove the provider. Unresolved paths can
legitimately name an absent destination, and wildcard characters remain
unresolved unless the caller rejects them. “Multiple resolution” is not a
meaningful postcondition of the single unresolved-path result.

P1 already supplies the stronger behavior that the unification goal should
reuse.

Recommended correction:

- Define one private final-destination/serialization helper used by all four
  generator functions.
- Reject null, empty, wildcard-bearing, and non-rooted input before .NET I/O.
- Use the overload that returns provider/drive metadata and require the
  FileSystem provider.
- Require one rooted provider-internal absolute path; distinguish the permitted
  absent final leaf from a missing/invalid parent.
- Normalize the complete payload once and call
  `File.WriteAllText` once with `UTF8Encoding($false)`.
- Define the exact preexisting/absent destination postcondition on every write
  failure and preserve the underlying exception.
- Add provider-qualified, relative, wildcard, wrong-provider, missing-parent,
  preexisting-leaf, and write-failure cases to the reciprocal P1↔T1 matrix.

Repository-specific artifact names remain intentional differences. Destination
security and byte/error behavior should not.

### T1-02: Apply one native-command contract to every PowerShell surface

T1 classifies the native status of the Markdown phases, and T1B requires
immediate status capture for writer Git commands. The slate does not apply the
same contract to every other complete PowerShell `run:` block and tracked
script that invokes Git, Node/npm, the generator, the helper, or a harness.

`$ErrorActionPreference = 'Stop'` alone does not make native-process failure
semantics uniform across Windows PowerShell 5.1 and PowerShell 7.
`$PSNativeCommandUseErrorActionPreference` is not a cross-edition substitute.

Recommended correction:

- Make T1 establish the common rule and require T1A/T1B to preserve it.
- Select `powershell` or `pwsh` explicitly for each complete block.
- Start with `$ErrorActionPreference = 'Stop'`.
- Capture `$LASTEXITCODE` immediately after every native command, before any
  assignment, pipeline, diagnostic, or helper call can replace it.
- Validate native output count and grammar before using it.
- Classify Git diff statuses as `0 = equal`, `1 = ordinary difference`, and
  every other value as command failure.
- Treat every nonzero `git ls-remote --exit-code` result as failure while
  preserving its status.
- Require tracked scripts to throw or exit nonzero on failure, and require each
  caller to check the result before continuing.
- Add workflow-policy fixtures for omitted and delayed native-status capture.

This should cover validation and helper/harness blocks, not only the final
writer.

### T1A-01: Define parseable script-version metadata before consuming it

T1 says to record a generator version using the repository's UTC convention.
T1A applies the same phrase to three new scripts, requires the harness to check
expected version markers, and T1B requires exact prerequisite versions.

TerraformStyleGuide currently has no script-version field in the generator's
`.NOTES` block and no repository-local parseable script-version convention.
Guide-document version numbers do not define a script field, grammar, initial
value, bump rule, or extraction algorithm. The downstream exact checks
therefore have no normative value to consume.

Recommended correction:

- Define one exact `.NOTES` field name and grammar in T1.
- Define the UTC calculation/bump rule and the generator's expected T1 value.
- Define initial expected values for T1A's helper, context manager, and harness.
- Make the validator distinguish a missing, duplicate, malformed, stale, or
  unexpected field.
- Make T1B compare those exact values from the actual prerequisite merge
  commits before executing any script.
- Reuse PSStyleGuide's observable convention where practical, while keeping
  TerraformStyleGuide self-contained.

### T1A-02: Reconcile idempotent cleanup with missing-state rejection

T1A's cleanup prose treats missing journaled context state as uncertain and
requires cleanup to stop. The mandatory table also requires:

- `K-03`: repeated candidate cleanup after safe removal is a successful no-op;
  and
- `C-02`: repeated caller-context teardown is a successful no-op under a
  “disposed-context contract.”

The candidate cleanup function accepts only an envelope, ownership journal,
and primary failure. No returned cleanup state or disposed token is defined.
The caller-context object likewise has no exact state transition. A second call
therefore cannot distinguish “this exact invocation already completed
successfully” from “the expected path was externally removed or substituted
before first cleanup.” Treating both as success can hide ownership uncertainty;
treating both as failure cannot pass `K-03`/`C-02`.

Recommended correction:

1. Define an exact cleanup state machine.
2. Mark disposed only after the complete first cleanup succeeds.
3. Return or mutate one exact invocation-bound state value that a repeated call
   must present.
4. Permit a no-op only for the same successfully disposed state; a newly
   constructed, copied, tokenless, or pre-first-call missing state must fail
   closed.
5. Add negative cases for a forged disposed claim and external deletion before
   first cleanup.

If no reliable disposed state is needed by production callers, remove the
repeat-success requirements instead of weakening missing-state handling.

### T1B-01: Make temporary and final action policy normative before YAML exists

T1's temporary table names roles and counts, while prose says observed rows
also include job IDs and stable step roles. It does not make conditions or
security-sensitive `with:` inputs part of the normative table.

T1B is still circular at the permanent boundary: it lists roles “at minimum”
and says “Final YAML determines exact counts.” The same implementation then
creates the validator that approves that YAML. This lets the result define its
own policy. T2/T3/T4 later update that implementation-defined table.

The pinned manifests make exact input policy material:

- checkout defaults its token to `github.token` and defaults
  `persist-credentials` to true;
- download-artifact v8 uses the plural input `artifact-ids` and separately
  defines `path`, `skip-decompress`, and `digest-mismatch`;
- upload-artifact v7 defines `name`, `path`, `archive`, hidden-file,
  overwrite, compression, missing-file, and retention behavior; and
- setup-node owns exact Node/cache inputs.

Recommended correction:

- Publish one exact temporary T1 role table before implementation.
- Publish one exact final T1B role table before implementation.
- Key each row by workflow, job ID, stable step ID, and action repository.
- Include exact SHA, release annotation, condition, expected count, and the
  complete permitted input map.
- Forbid every unlisted input, even when the pinned action currently ignores or
  defaults it.
- Require exact role-set and input-set equality.
- Replace the temporary table atomically in T1B.
- Have T2/T3/T4 edit this one normative table and its fixtures explicitly,
  never infer policy from the final YAML.

Retain the existing negative fixtures, and add wrong input name, omitted
required input, default-dependent input, weakened condition, and wrong local
reusable-workflow role cases.

### T1B-02: State the write-token lifetime honestly

T1/T1B substantially improve credential handling by disabling checkout
persistence and materializing an HTTP authorization header only around the
exact push child. T1B's acceptance criterion nevertheless says:

> Credentials exist only for one exact push.

That is not true for a writer job using `GITHUB_TOKEN` with
`contents: write`. GitHub applies permissions at workflow/job scope and makes
`github.token` available to actions even when the workflow does not explicitly
pass it. The pinned checkout action also defaults its `token` input to
`github.token`; `persist-credentials: false` removes later Git configuration
but does not make checkout credential-free or shorten the job token's lifetime.

Choose and document one accurate model:

- With the current design, state that the write-capable job token exists for
  the complete minimal writer job. Guarantee only that no credential is
  persisted or explicitly materialized into a process/file except as specified
  for checkout and the exact push. Fully allowlist every step/action that can
  execute in that job.
- For a true push-step-only credential, keep `GITHUB_TOKEN` read-only and use a
  separately governed environment-protected credential for the push. Define
  issuer, repository/ref scope, approval, rotation/revocation, masking, and
  negative tests.
- If unauthenticated checkout is intended for the public repository, specify
  the exact pinned-action input and prove it works; do not assume
  `persist-credentials: false` prevents checkout from receiving a token.

Update T1's temporary writer and T1B's final writer consistently. Preserve the
process-scoped Git configuration, credential-free diagnostics, exact refspec,
and exact lease.

### T2-01: Make each displayed Bash body satisfy the common contract

T2's common contract is stronger than its three displayed recovery bodies.

First, it requires every block to enforce Bash through a shebang/runtime guard,
but the copyable AWS/Azure/GCS bodies begin with a subshell and immediately use
Bash-only `[[ ... ]]`, arrays, `shopt`, and arithmetic syntax. The permanent
harness has a Bash shebang, but a reader copying only the marked body has no
fail-early interpreter guard.

Second, the common contract says each input is assigned once before validation.
The bodies snapshot `RECOVERY_PATH` but not their selected version:

- AWS reads ambient `VERSION_ID` inside the provider function;
- Azure reads ambient `AZURE_VERSION_ID` inside the provider function; and
- GCS validates ambient `GCS_GENERATION` and later reads it again when building
  the source argument.

Third, “protected parent” is both called a requirement and delegated to the
operator. The bodies only test that the immediate parent is a directory and not
itself a link. They do not classify ancestor links, ownership/mode,
world-writability, or Git containment, while acceptance says each destination
is protected.

Recommended correction:

1. Put an executable Bash version/runtime guard inside every exact marked body,
   or make the complete copyable unit a shebang-bearing script.
2. Snapshot every environment input exactly once into a local scalar before
   validation, then use only that scalar in validation, diagnostics, and the
   provider argv.
3. Define the exact accepted grammar for each opaque selected ID without
   rewriting it.
4. Decide which protected-parent properties are mechanically proved. Implement
   and test those checks, including link ancestors and the declared hosted
   filesystem.
5. State the remaining no-competing-writer, account ownership, and storage
   location facts as operator preconditions rather than claimed script proofs.
6. Add exact harness cases for wrong interpreter, unprotected/world-writable
   parent, link ancestor, Git-contained destination, and provider argv using
   the snapshotted value.

The private-root, exact partial cleanup, real no-replace hard link, and
uncertainty-retention model should remain.

### T3-01: Select one exact npm CLI and one lockfile producer

T3 says to use “one selected supported npm” consistently, but it never defines
how that npm is selected, installed, or asserted. `setup-node` selects Node,
not a single npm CLI. Node 22 and Node 24 can ship different npm versions; the
local hook currently accepts whichever `npm` appears on `PATH`.

Without an exact CLI, lockfile generation, `npm ci`, audit normalization,
package scripts, hook evidence, and behavior across the four Node/OS cells can
come from different tools while still satisfying the prose.

Recommended correction:

- Select one maintained exact npm release whose own engine admits every final
  Node line and patch floor.
- Install or resolve that exact npm in every local and hosted cell.
- Assert the exact npm version before package or audit work.
- Prove npm's `process.execPath`/`process.versions.node` uses the selected active
  Node.
- Use only that npm for lockfile generation, `npm ci`, `npm ls`, audit, both
  lints, and actual-hook tests.
- Designate one exact preferred Node 24/npm pair as the sole lockfile producer.
- Require every other cell to prove it does not rewrite the lockfile.
- Make the hook check or clearly communicate the exact supported npm policy,
  not only that an application named `npm` resolves.

If no one npm release supports the final Node set, define reviewed Node/npm
pairs and one normative producer. Do not promise one npm while using bundled
variants.

### T3-02: Separate observed audit data from approval metadata

The dated baseline still calls five high and two moderate values “affected
package nodes.” In the current npm 11 report, those are seven vulnerability
properties. The same report contains fourteen object-advisory records and
seven `nodes` paths. The issue correctly warns against advisory/path Cartesian
products later, but the baseline still names the wrong unit.

The durable schema is also internally ambiguous:

- normalized `Findings` includes direct parents, `fixAvailable`, chosen
  disposition, and evidence tool/date;
- exception `findings` has a different exact schema containing approval,
  analysis, controls, timestamps, and follow-up data; yet
- the validator is required to enforce “exact equality” between current
  normalized `Findings` and approved findings.

Literal object equality is impossible between those two shapes. Key-set-only
equality would not say which observed severity/range/source changes invalidate
approval.

Recommended correction:

1. Rename the dated counts accurately.
2. Define one closed `ObservedFindings` schema derived only from the audit
   report and lockfile.
3. Define one separate closed `Approvals` schema keyed by exact
   `(Package, AdvisoryUrl)`.
4. State exact key-set equality between observed findings and approvals.
5. List every observed field copied into an approval and require exact equality
   for those fields; define how a change in severity, range, source ID,
   `fixAvailable`, or package topology invalidates approval.
6. Keep `AuditNodePaths` as the separate exact package-keyed topology set.
7. Fail closed on audit report-version or consumed-shape changes, preserving
   the raw report and exact npm version.
8. Keep the exception file absent when the audit is clean.

The existing expiry boundary, injected fixture clock, real-clock CLI,
closed-schema rejection, and `AUDIT-*` inventory are strong.

### T4-01: Correct command-created backup semantics for `state rm`

T4 says to direct a command-created `state rm` backup to a protected path when
the Terraform/backend exposes the option, and otherwise run from a protected
directory and inventory the backup path.

Terraform documents `-state`, `-state-out`, and `-backup` as legacy options for
the local-state form only. A remote/HCP `terraform state rm` does not become a
local-backup-producing command because it runs from a protected directory.

Recommended correction:

- Make the mandatory pre-operation `SM-BACKUP-PULL` snapshot the recovery point
  for every remote/HCP operation.
- Use provider/HCP version history as additional recovery evidence where
  available.
- Permit `-backup=<exact-fresh-protected-path>` only in a separately identified,
  supported local-state branch.
- Remove the fallback claim that changing the current directory reveals a
  remote command-created backup.
- Split `SM-BASH-RM-09` into a local-state option case and a remote-state case
  that proves no command backup is expected.

Do not weaken the fresh backup, dry-run, exact address, lock, confirmation, or
post-plan requirements.

### T4-02: Do not promise a generic no-force rollback of an older backup

T4 requires a “tested rollback command using the just-created current backup,”
while also prohibiting `-force` and requiring the proposed state serial not to
be lower than current.

Terraform's `state push` rejects a pushed state when the destination has a
higher serial. After the proposed state is pushed, the pre-push backup's serial
is less than or equal to the new remote serial. It is therefore not a generally
viable rollback input under the issue's no-force rule. Equality might happen
for a particular repair, but the issue neither requires it nor proves the
backend's resulting serial.

Recommended correction:

1. Treat backend-native or HCP state-version restoration as the preferred
   rollback path and test/document its exact provider semantics.
2. Describe the pre-push backup as a validated recovery point and evidence, not
   as a universally executable rollback command.
3. Before promising a manual no-force push rollback, pull the post-operation
   state and prove the exact lineage/serial relationship permits it.
4. If it does not, stop and require a separately reviewed provider-supported
   recovery or incident procedure. Do not silently edit a serial or add
   `-force`.
5. Extend the push harness with a remote-serial-advanced case that proves the
   old backup is rejected and no automatic rollback runs.

Keep T4's refusal to teach routine force, lock bypass, or automatic rollback.

## Recommended disposition

First resolve S-01 and file one dependency graph. Under the prompt's stipulated
order:

1. **T1** — make the destination/provider/write and native-command contracts
   exact; define version metadata; publish the complete temporary action table.
2. **T1A** — retain the extensive stable-ID/resource/link coverage, but define
   the disposed cleanup state or remove repeat-success semantics.
3. **T1B** — publish the complete final role/input table and use an accurate
   job-token lifetime model while retaining immutable artifact identity,
   unique attestations, one approval, and the exact writer lease.
4. **T2** — make every marked Bash body implement the stated interpreter,
   one-snapshot, and protected-parent contract mechanically or label remaining
   facts as operator preconditions.
5. **T3** — select one exact npm/lockfile producer and make observed audit data
   and governance approvals separate closed schemas.
6. **T4** — make `state rm` backup behavior backend-accurate and remove the
   unsupported promise of a generic no-force rollback command.

After filing, replace title-only dependencies with actual issue URLs and
GitHub blocked-by relationships. Record exact merge commits as implementation
evidence.

## Strengths to preserve

- H1-as-title and P/T shorthand conventions.
- The P1/P1A/P1B↔T1/T1A/T1B layer-for-layer comparison without shared runtime
  code.
- The now-LF-clean planning base and T1 exact changed-path gate.
- Complete-payload normalization and explicit BOM-less UTF-8 serialization.
- T1A's same-stream digest/ZIP identity, finite inclusive limits, fixed raw-ZIP
  provenance, explicit null-label cases, and exact context-manager input.
- Full-component containment/link checks, separate candidate/caller cleanup,
  and uncertainty retention.
- T1B's immutable artifact ID/digest, path-bound hashes, four unique static
  matrix outputs, `if: always()` approval, four-local writer identity, exact
  remote preflight, parent, lease, and refspec.
- T2's deliberate version selection, private invocation root, real
  no-replace publication, exact partial cleanup, and sensitive-state handling.
- T3's finite Node policy, real installed-hook test, audit validator,
  before/at/after-expiry fixtures, and review-only Dependabot governance.
- T4's byte-preserving Windows PowerShell 5.1/7 process-stream contract, real
  hard-link tests, preference for declarative operations, and refusal to teach
  routine force, lock bypass, or automatic rollback.

## Primary references

- [PSStyleGuide reviewed planning commit](https://github.com/franklesniak/PSStyleGuide/commit/61a7dd04bc7d15e4b685d8f252c9535632f7c3f4)
- [TerraformStyleGuide issue-slate commit](https://github.com/franklesniak/TerraformStyleGuide/commit/4c2c8a2aa3463cd3375b67574fde9f37d445ccb6)
- [TerraformStyleGuide reviewed planning head](https://github.com/franklesniak/TerraformStyleGuide/commit/121e7e7d2210df49902590b0f1d23ef7074c9e30)
- [TerraformStyleGuide reviewed `main`](https://github.com/franklesniak/TerraformStyleGuide/commit/6ee3f57b2b71b885a5927b770dde47532944de62)
- [Git attributes](https://git-scm.com/docs/gitattributes)
- [PowerShell unresolved provider-path API](https://learn.microsoft.com/dotnet/api/system.management.automation.pathintrinsics.getunresolvedproviderpathfrompspath)
- [PowerShell preference variables](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_preference_variables)
- [GitHub `GITHUB_TOKEN` authentication](https://docs.github.com/en/actions/tutorials/authenticate-with-github_token)
- [GitHub workflow permissions](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#permissions)
- [Pinned checkout manifest](https://github.com/actions/checkout/blob/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml)
- [Pinned upload-artifact manifest](https://github.com/actions/upload-artifact/blob/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a/action.yml)
- [Pinned download-artifact manifest](https://github.com/actions/download-artifact/blob/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/action.yml)
- [npm audit](https://docs.npmjs.com/cli/v11/commands/npm-audit/)
- [npm package engines](https://docs.npmjs.com/cli/v11/configuring-npm/package-json#engines)
- [Node.js release status](https://nodejs.org/en/about/previous-releases)
- [Terraform `state push`](https://developer.hashicorp.com/terraform/cli/commands/state/push)
- [Terraform `state rm`](https://developer.hashicorp.com/terraform/cli/commands/state/rm)
- [Terraform state storage and locking](https://developer.hashicorp.com/terraform/language/state/backends)
