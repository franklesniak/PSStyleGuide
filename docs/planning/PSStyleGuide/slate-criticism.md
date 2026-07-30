# Feedback on the revised PSStyleGuide issue slate

## Overall assessment

Keep the P1/P1A/P1B/P2/P3 split, the stated sequential order, the embedded H1
issue titles, and the P/T identifiers. The revised slate has absorbed most of
the prior criticism. In particular:

- P1 now specifies a fixed generator map, complete-payload byte handling, a
  fail-closed replacement design, exact action roles/default dispositions, an
  offline workflow-policy validator, a reusable raw NUL-safe Git path
  verifier, and an advisory-risk gate.
- P1A now owns a same-stream archive boundary, explicit context/journal
  schemas, nonrecursive cleanup, fixed resource ceilings, namespaced semantic
  cases, canonical JSONL evidence, and three-host execution.
- P1B now has one external event owner, a callable local Markdown workflow,
  immutable artifact ID/digest/path hashes, four static Windows attestations,
  direct-needs approval, one exact-lease writer, an honest transient credential
  model, and real-writer evidence on an isolated ref.
- P2 is specific, bounded, derived-artifact-safe, and suitable as the first
  ordinary source/generated-content exercise of the completed publication
  pipeline.
- P3 now selects a finite Node/Corepack/npm policy, centralizes package
  invocation, hardens the actual prepare installer, preserves the
  repository-specific staged hook, validates raw audit bytes, governs
  exceptions with live issue state, adds read-only recurring checks, and
  extends the existing policy engine instead of replacing it.

This is a much stronger slate. P2 is filing-ready once its predecessors exist.
P1, P1A, P1B, and P3 still need a focused correction pass before filing.

| Priority | Owner | Remaining correction |
| --- | --- | --- |
| Blocker | P1/P1B | Add separately authorized `main` ruleset governance and prove the real writer under an equivalent temporary evidence-ref rule. |
| Blocker | P1A | Separate expected production rejection from harness verdict; the current `Passed`/`DiagnosticCode` rules contradict the negative-case contract. |
| Blocker | P1B | Patch the evidence-ref push trigger as well as the full-ref predicates; the currently described evidence branch cannot start `build.yml`. |
| Blocker | P3 | Close the audit process/stream/termination/resource contract; the current timeout and overflow outcomes are not implementable deterministically. |
| Required | P1 | Define the timeless script-version grammar, expected-version check, authoring progression, exact lock producer command, and stable reciprocal rows. |
| Required | P1A | Publish one atomic oracle per case and prove the supplied helper/context scripts are exact trusted HEAD/index/working blobs. |
| Required | P3 | Bind Husky package/CLI/generated-hook identity, publish literal wrapper operation vectors, and make the audit/Node catalogs physically atomic. |
| Required | P3 | Add a deterministic live-evidence capture path and cryptographically bind each follow-up issue to its exact finding scope. |

## Review baseline

This review compares:

- the revised Terraform slate at local commit
  `09a30857cefdfe985a1a5ce112bc0d69270da7c7`;
- the PSStyleGuide planning slate at local commit
  `713c1cd657b842e18466cb63e2b68d59fab1b0b4`; and
- PSStyleGuide default `main` at
  [`4346310e7deebffb4159c75e30d9546263dfd649`](https://github.com/franklesniak/PSStyleGuide/commit/4346310e7deebffb4159c75e30d9546263dfd649).

The five reviewed P issue files are byte-identical in the TerraformStyleGuide
planning tree and the sibling PSStyleGuide planning tree.

A live read-only repository-settings check on 2026-07-30 found:

- `main` is the default branch;
- the repository ruleset list is empty; and
- classic protection for `main` returns “Branch not protected.”

This makes the governance finding below an existing-state requirement, not a
hypothetical hardening suggestion. A separate live application lookup confirms
the official GitHub Actions application is still owner `github`, slug
`github-actions`, integration ID `15368`.

The proposed P3 supply tuple is internally coherent:

- the official Node distribution lists Node `22.23.2` and `24.18.1`;
- their bundled Corepack package records are `0.34.6` and `0.35.0`;
- the npm registry record for `npm@12.0.2` has the stated 3,045,132-byte
  tarball and SHA-512 integrity; and
- both P3's SHA-224 descriptor and T3's SHA-512 descriptor are correct digests
  of that same tarball. Corepack explicitly supports hash-qualified
  `packageManager` descriptors.

Therefore, do not reopen the runtime tuple merely because P3 uses SHA-224.
Converging on the same SHA-512 descriptor as T3 would reduce needless
cross-repository variance, but the current P3 value is valid if the reciprocal
record identifies it as an intentional difference.

## Slate structure and sequencing

The boundaries and default order are sound:

1. P1 establishes deterministic generation and permanent policy foundations.
2. P1A adds workflow-inert candidate validation.
3. P1B activates the verified publication graph and sole writer.
4. P2 exercises that graph with a normal source/generated-content change.
5. P3 changes the dependency graph and owns the final runtime, hook, audit,
   and update policy.

Keep P1's dated advisory authorization as the gate for allowing P3 to remain
last. If the accountable decision expires, is refused, or the audit materially
worsens, reorder the complete P3 work and rebaseline its successors; do not
smuggle a partial package update into P1 or P2.

The titles already embedded as H1 headings are intentional issue titles and
should remain. P2's title-only forward reference to P3 is also satisfiable:
P3, not P2, is responsible for recording P2's real URL and blocked-by edge
after P3 is filed.

## Cross-cutting blocker: protect `main` without weakening the sole writer

P1 and P1B establish a direct `GITHUB_TOKEN` push to `main`, but neither issue
owns or requires the branch rules that make all other direct updates fail.
The current repository has no ruleset and no classic branch protection.
P1B's exact lease prevents a stale writer update; it does not require ordinary
contributors to use pull requests, resolve conversations, keep the branch
current, or preserve the terminal approval check.

Add a P1 section equivalent in responsibility to T1's separately authorized
governance task:

1. Repository settings remain outside P1's affected-file scope.
2. Open an administrator-owned settings task containing current-state export,
   exact desired and rollback JSON, approver, execution window, validation,
   and incident rollback.
3. Define one active branch ruleset targeting exactly `refs/heads/main`, with
   no exclusions.
4. Prohibit deletion and non-fast-forward updates.
5. Require pull requests, resolved conversations, a current branch, and the
   exact stable P1B terminal approval check.
6. Permit exactly one bypass actor: the re-resolved official GitHub Actions
   integration, mode `always`. Do not add user, role, administrator, team,
   deploy-key, second-app, or exempt-mode bypasses.
7. Before persistent activation, test the real P1B writer under a temporary
   field-equivalent rule targeting only the evidence ref. Prove the expected
   writer succeeds and stale/lost lease, non-fast-forward, deletion, and an
   ordinary maintainer's direct update fail without moving the ref.
8. Activate the persistent rule only after the P1B pull request has produced
   the exact terminal check context, then query the effective rule for
   `main`. Retain rule ID, normalized JSON digest, bypass identity, audit
   evidence, and rollback proof.

P1B must be blocked on this administrator task. P2 and P3 must re-query the
same active/effective rule and bypass before relying on the P1B handoff. Until
that proof exists, use “reviewed head,” “target main commit,” or “landed
commit,” not “protected main.”

## P1 — Make artifact generation byte-deterministic across PowerShell editions and hosts

### What is strong

The fixed source/output authority, complete-payload normalization, BOM-less
UTF-8 encoding, no direct destination truncation, fault categories, exact
action allowlist, explicit/default input dispositions, read-only workflows,
offline YAML policy, reusable Git path verifier, and advisory-order gate are
all appropriate.

Keeping P1 read-only until P1B is also a reasonable PS-specific difference
from T1's temporary writer. P2 does not need publication until after P1B.

### Required correction 1: finish the version contract

P1 gives the generator only a first-version template and says to parse a
“named metadata field.” P1A then refers to a “PSStyleGuide same-day revision
rule” that P1 never defines. P1 also calls `Test-ExactGitPathSet.ps1`
“versioned” and hands its version to successors without specifying the marker,
grammar, expected-version behavior, or bump rules.

Define one slate-wide contract:

- exactly one `Version: <Major>.<Minor>.<YYYYMMDD>.<Revision>` marker in the
  script-level `.NOTES` block before the first function;
- ASCII canonical nonnegative components with no leading zero except `0`,
  valid `[System.Version]` bounds, and a real Gregorian Build date;
- timeless parsing that does not consult clocks or timestamps;
- a separately trusted expected version bound to the reviewed path/commit/hash;
- distinct `invalid-version`, `unexpected-version`, and
  `version-progression` failures; and
- implementation-time progression from merge-base version, change class, and
  UTC date of the final material edit, including the exact same-day Revision
  rule.

Apply it to the P1 generator/path verifier and every later PowerShell script.
This is important for generator convergence: P1/T1 should share version
grammar and evidence semantics even though their artifact names differ.

### Required correction 2: specify the sole lock producer, not only its tuple

P1 correctly selects Node `24.18.1` with bundled npm `11.16.0`, but
“Generate the lock only with the selected pair” still leaves the state-changing
command and lifecycle behavior open. The repository already has a root
`prepare` script, so omission of `--ignore-scripts` is material.

Match T1's producer discipline. From a clean disposable clone, verify the
official Node artifact against signed release checksums, set only exact
`"yaml": "2.9.0"`, and run exactly:

```text
npm install --package-lock-only --ignore-scripts --no-audit --no-fund
```

Record executable paths/versions, artifact/checksum/signature evidence,
effective registry/proxy/certificate/peer/lock/script/audit/fund
configuration with secrets redacted, and pre/post manifest/lock hashes. Every
other runtime is a frozen `npm ci --ignore-scripts --no-audit --no-fund`
consumer and must leave package and lock bytes unchanged. P3 still owns the
durable hash-qualified package-manager policy.

### Required correction 3: make generator convergence executable

P1's reciprocal section is a prose list. T1 now has a closed 16-row `GF-*`
catalog with stable row meanings and exact record fields. Use the same row IDs
and meanings in P1. Require every row exactly once, immutable repository
commits and locators, evidence hashes, observed values/fixture IDs, and one
status `same|intentional difference|blocker`.

The row set must expose, rather than blur, the largest current difference:
P1 specifies a four-file backup/rollback coordinator, while T1 specifies the
same private per-artifact `File.Replace` boundary with no post-replace
semantic gate or rollback fallback. Because generator unification is desired,
prefer the same per-artifact writer contract in both repositories. If P1
retains the cross-file coordinator, define its exact result object, exit
mapping, backup lifecycle, crash boundary, and why its observable failure
strength is intentionally equivalent. P1A currently claims it consumes a
“replacement result schema,” but P1 names `RolledBack` and
`ReplacementStateUncertain` without publishing such a schema.

Repository-specific source composition, frontmatter, artifact filenames, and
the absence of a P1 temporary writer are valid intentional differences.
Path security, serialization, version parsing, native status handling,
credential containment, and failure-state truthfulness are not.

## P1A — Add a fail-closed cross-platform style-guide candidate validator

### What is strong

The raw exact-type boundary, same-stream digest/ZIP processing, fixed manifest,
declared and actual byte ceilings, component/link checks, fresh-file
extraction, journaled nonrecursive cleanup, terminal zero-call behavior, and
canonical bounded evidence are strong. The explicit decision not to retry a
`CleanupFailed` capability is defensible if the reciprocal matrix records it
as an intentional lifecycle difference.

### Blocker 1: negative cases cannot currently pass

The catalog requires an expected diagnostic code for each record, and
validation says expected helper failures count as harness passes. The result
schema, however, has only one `DiagnosticCode` and says:

> `Passed` requires every expected/actual value and fixture identity to match
> and diagnostic `None`.

A correctly observed production rejection should normally emit its expected
non-`None` production diagnostic. Under the current rule it cannot also be a
passed harness case.

Separate production behavior from harness judgment. At minimum emit:

- `ExpectedResult`, `ActualResult`;
- `ExpectedStatus`, `ActualStatus`;
- `ExpectedPhase`, `ActualPhase`;
- `ExpectedDiagnosticCode`, `ActualDiagnosticCode`; and
- `HarnessVerdict: pass|fail|skip`.

A correctly observed production rejection is
`ExpectedResult: rejection`, matching actual failure fields, and
`HarnessVerdict: pass`. An applicability skip is a skip, not a pass.
Reserve harness-error diagnostics for fixture/orchestration failures. Remove
the rule that a pass requires diagnostic `None`.

### Required correction 2: replace range prose with atomic oracles

The issue totals 96 cases correctly, but rows such as `PS-P1A-E-01..15` and
`PS-P1A-S-01..11` are grouped semantic inventories, not mappings from each
immutable ID to one fixture and one oracle. The statement that the future JSON
record is authoritative does not tell a cold implementer which ID receives
which path failure, runtime applicability, status, phase, cleanup sequence, or
diagnostic. It also prevents a meaningful P1A/T1A comparison before code is
written.

Publish a closed `PS-P1A-CASES-v1` row for every ID, or publish immutable
oracle profiles plus one physical ID-to-profile row per case. Each row/result
should have singular fields for applicability, fixture, initial state,
expected production result/status/phase/subreason, pre-cleanup state, final
candidate/context state, ordered cleanup sequence, diagnostics, sentinels,
and source-repository state. Reject prose alternatives such as slash lists,
“plus,” or “applicable” in machine-readable oracle fields.

### Required correction 3: bind the supplied scripts to Git

The `S-*` inventory implies that the permanent harness accepts helper and
context-manager paths, but the issue never publishes that harness interface
or proves that either path is the reviewed repository script. A caller could
supply an untracked, staged replacement, filtered working file, wrong Git
mode, or path from another repository and still produce apparently valid
case evidence.

Declare mandatory raw `HelperPath` and `ContextManagerPath` inputs and exact
expected versions. Derive the trusted repository root from the harness's
fixed `$PSScriptRoot`, not current directory or ambient Git discovery. Before
dot-sourcing either script, require:

- exactly one ordinary `100644` HEAD tree blob at its fixed repository path;
- exactly one matching stage-0 index blob and no conflict stages;
- a no-filter working-file object ID equal to HEAD/index;
- the exact expected script version from trusted harness metadata; and
- repeated ordinary/component and no-filter identity immediately before later
  invocation.

Use raw NUL records and literal pathspecs. Add atomic fixtures for untracked,
HEAD/index absence, staged/unstaged replacement, conflict stage, wrong
mode/type, malformed records, abbreviated/wrong-format IDs, native status
failure, and hostile literal filenames.

While closing this interface, state the exact parameter/return/failure
contracts for both exported context functions. The object schema is exact,
but the public function signatures are presently only implied.

## P1B — Promote generated style-guide artifacts through a least-privileged verified writer

### What is strong

The six-job hierarchical graph is coherent. The local callable workflow,
direct-needs approval, four literal attestation outputs, immutable artifact ID
plus digest and path hashes, job-level least privilege, no-extract downloads,
at-use harness/regeneration, exact remote preflight, one-parent commit,
force-with-lease refspec, post-push verification, and transient push-only HTTP
authorization are all appropriate.

The evidence design also correctly insists on the real `build.yml` and real
writer rather than a copied workflow.

### Blocker 1: the evidence branch is not a workflow trigger

P1B says production `build.yml` runs only for pushes to `main`. Its evidence
section changes the authorized full-ref target/predicate from
`refs/heads/main` to an evidence ref, but it does not change:

```yaml
on:
  push:
    branches:
      - main
```

Pushing the evidence ref therefore cannot start the workflow whose writer is
being tested. Also, the trigger uses the branch name while conditions use the
full `refs/heads/...` value, so this cannot be repaired as one repeated
literal replacement.

Use an upfront allowed-delta manifest that enumerates every exact evidence-only
hunk:

- the push branch filter, using the evidence branch name;
- approval/ref predicates;
- writer condition;
- `TARGET_REF`;
- policy-validator constants;
- bounded scenario selector/instrumentation; and
- one safe source fixture that deterministically changes generated bytes.

The structural comparator must reject every other event, permission, graph,
action/input, candidate, credential, path, commit, lease, refspec, or
diagnostic change. Continue to prohibit `workflow_dispatch`,
`repository_dispatch`, a copied writer, caller-selected refs, wildcards, and
secret inheritance.

### Blocker 2: integrate the ruleset proof

Apply the cross-cutting governance requirements above. The positive evidence
writer must run under the temporary equivalent evidence-ref ruleset, and the
persistent `main` rule must be active/effective before P1B merges. Retain the
exact terminal check context and re-query it after merge.

The temporary evidence ref/rule cleanup should also wait for or cancel every
run, delete the ref with an expected-old guard, prove no active workflow or
policy still names it, and restore settings exactly. Cleanup failure blocks
production enablement; it does not authorize an unprotected fallback.

## P2 — Make the non-compliant blank-line example visibly distinct

P2 is ready after the corrected P1B contract lands.

Keep:

- the exact Compliant byte oracle;
- the visible four-middle-dot `text` example and warning;
- the single rationale-section constraint;
- finalization-time metadata calculation;
- source-only editing followed by generator-derived artifacts;
- exact six-path working/staged gates;
- pull-request proof that the writer is ineligible; and
- post-merge `has_changes=false` proof with no recovery commit.

Do not add package, workflow, generator, or policy work to P2. Do not add a
Terraform counterpart for this repository-specific documentation repair.

After the governance correction, P2's predecessor handoff should also carry
the active ruleset ID, normalized rule digest, effective-rule result, and sole
Actions bypass identity.

## P3 — Remediate Markdown lint dependency advisories and add npm update governance

### What is strong

The proposed Node `22.23.2`/Corepack `0.34.6` and Node
`24.18.1`/Corepack `0.35.0` cells, finite engines range, npm `12.0.2`
descriptor, fresh Corepack/npm state, hostile ambient-config rejection,
central Node policy, preservation of staged-only lint, read-only
schedule/manual graph, two-entry review-only Dependabot policy, and explicit
absence of an exception file when clean are all sound.

The SHA-224 package-manager descriptor is valid. For simpler P3/T3 evidence,
consider using T3's SHA-512 descriptor because it is the hex form of the
registry SRI already recorded by P3. This is convergence, not a correctness
fix.

### Required correction 1: publish the wrapper's literal operation table

`Run-NpmPolicy.mjs` names `ci`, `audit`, `lock-noop`, `run-lint`, and
`run-test`, but describes their arguments as a collection of “fixed CLI
settings” rather than a literal operation-to-argv contract. Publish one closed
table containing, for every operation:

- exact `process.execPath` and Corepack entry-point identity;
- complete ordered argument vector;
- working directory;
- network/cache mode;
- exact environment additions/removals;
- user/global/project config inputs;
- stdin/stdout/stderr handling and timeout;
- accepted native exits; and
- permitted file side effects.

The workflow-policy contract and hostile fixtures should consume this table.
This prevents the implementation, hook, audit validator, and lock producer
from quietly choosing different include/workspace/script/audit/registry
semantics.

### Required correction 2: make Husky installation an identity contract

P3 improves the existing `install-husky.mjs` decision logic but still trusts
“the exact lock-resolved Husky” after a dynamic package import. It does not
specify the final Husky version/integrity, package entry-point bytes, tracked
hook identity, expected `.husky/_` inventory, file hashes, modes, or exact
spawn/import boundary. A different package tree can satisfy the same broad
postconditions.

After package selection, add a strict versioned Husky install contract that
binds:

- exact root dependency, lock version/tarball/integrity, package root, binary
  or public API entry point, and reviewed package-file hashes;
- the tracked `.husky/pre-commit` HEAD/index/no-filter working identity,
  schema marker, mode, length, and SHA-256;
- exact expected `core.hooksPath`;
- the complete generated `.husky/_` path/type/content/hash/mode inventory;
- the installer decision-state schema and exact environment precedence; and
- required, authorized-skip, conflict, import/spawn, native-exit,
  postcondition, immutability, and real-commit cases.

PSStyleGuide may intentionally retain its lowercase installer filename and
programmatic staged-content API. It may also retain a reviewed Husky package
API instead of T3's CLI, but that boundary must be an explicit, hash-bound
intentional difference rather than an unverified dynamic import.

### Blocker 3: close the audit native lifecycle

P3 sets a 120-second timeout, 4-MiB stdout limit, 256-KiB stderr limit, and
outcome precedence, but leaves critical mechanics unspecified:

- no exact structured native-outcome schema;
- no TERM/KILL or Windows process-tree termination contract;
- no termination grace period or delivery/close-failure behavior;
- no rule for continuing to drain streams after an overflow;
- no reconciliation of `error`, `exit`, and `close` races;
- no exact cleanup behavior;
- no numeric JSON depth, token-count, string-token, or number-token ceilings;
  and
- no decision about whether stream-limit detection terminates the child or
  merely records overflow while draining it.

As written, `TimedOut`, `Signaled`, `StdoutLimitExceeded`, and
`StderrLimitExceeded` can differ by host and event timing, while a timed-out
manager invocation has no specified proof that every descendant stopped.

Specify one closed process/result object with mutually valid combinations for
`exit`, `signal`, `timeout`, and `startFailure`; exact byte counts/hashes and
overflow flags; fixed timeout/grace values; one-result emission; stream error
handling; termination delivery; wait-for-close; cleanup; and bounded safe
diagnostics. Define exact parser ceilings and below/at/above fixtures. If
Windows cannot claim the same process-tree termination guarantee, state that
platform boundary explicitly and test the pure outcome model there rather than
claiming unqualified parity.

### Required correction 4: make Node and audit catalogs physically atomic

The Node catalog is a prose coverage list. The audit catalog is a collection
of broad families. Neither allocates each immutable ID to one literal fixture
and one expected result, and the audit catalog has no frozen cardinality.
“Every case exactly once” is not verifiable until the implementer invents the
catalog.

Give every case one physical row. For audit rows include exact layer, fixture
reference/raw length and digest, native outcome, exception state, expected
terminal class, normalized finding set, package-keyed node paths, parser
state, process-call count, and bounded diagnostic. Split every multi-defect
family except deliberately identified precedence cases. Add catalog-mutation
tests for missing, duplicate, unknown, regrouped, multiply emitted, skipped,
and orphaned IDs.

The revised T3 catalog is a useful semantic checklist for raw UTF-8/JSON
boundaries, duplicate keys at every object layer, exact parser resource
limits, process races/overflows, complete report-v2 shapes, reciprocal graph
edges, metadata arithmetic, exit/report seams, exception equality, and
governance. Reuse semantic meanings where applicable while keeping PS-local
namespaces and the PS production architecture.

### Required correction 5: bind and reproduce live follow-up evidence

P3's exception record stores repository/issue identity, state, labels,
assignees, and timestamps, but excludes any binding between the live issue's
content and the exact governed `(Package, AdvisoryUrl)` scope. An open labeled
issue with the right assignee can satisfy the described verifier even if it
does not describe those findings, remediation objective, or target date.

Add:

- a canonical scope hash over the exact sorted findings assigned to the issue;
- a required issue-body marker carrying that hash;
- responsible owner and target date bound to the exception expiry;
- bounded title/body hashes or an equivalent canonical marker projection;
- immutable issue database/node identities and `isPullRequest=false`;
- a closed property order and canonicalization/digest preimage; and
- exact retry count, `Retry-After` policy, request API version, and failure
  behavior.

Also add a named read-only capture tool or an explicit capture mode that
produces the canonical evidence record. The current prose says a maintainer
“live-generates” the projection, but the affected files contain only a
verifier. Do not require hand-authoring API IDs, sorted projections, and
digests. Verification must compare freshly fetched live state to the embedded
record and fail on any scope/content/state/owner/target-date drift; it must
never silently refresh approval.

## Cross-slate convergence model

Unify contracts and evidence, not runtime dependencies.

| Semantic layer | PS owner | Terraform owner | Converge on | Valid repository-specific differences |
| --- | --- | --- | --- | --- |
| Generator | P1 | T1 | `GF-*` rows, trusted fixed map, complete-payload normalization, BOM-less UTF-8/LF, private verified replacement, version grammar, host/fault evidence | Source transforms, frontmatter, destination names |
| Candidate | P1A | T1A | Raw boundary, same-stream identity, path/link safety, fixed manifest/limits, atomic oracles, expected-vs-actual results, trusted script identity | Manifest filenames and intentionally documented cleanup lifecycle |
| Writer | P1B | T1B | One event owner, immutable ID/digest/hashes, direct-needs approval, sole exact-lease writer, honest credential containment, real-writer/equivalent-ruleset evidence | Local job/artifact names and matrix details |
| Dependency policy | P3 | T3 | Finite Node policy, hash-qualified npm, closed manager invocation, verified Husky install, strict raw audit, bounded issue-backed exceptions, recurring read-only checks | PS staged-only hook/API and lowercase existing installer path |
| Content work | P2 | none | Consume the completed PS pipeline without weakening it | The blank-line repair is PS-specific |
| Terraform guidance | none | T2/T4 | No forced PS counterpart | Terraform state/provider guidance is Terraform-specific |

Each reciprocal record should name immutable P/T commits, normative and
implementation locators, evidence paths/digests, observed values/case IDs, one
status `same|intentional difference|blocker`, and a rationale. An intentional
difference should name both literals, repository need, equal
security/failure strength, owner, and review/expiry condition.

The two repositories should remain self-contained. Reusing stable semantic
rows, schema shapes, case meanings, and reviewed algorithms is desirable.
Downloading or executing the other repository at runtime is not.

## Filing recommendation

Do not file the slate unchanged.

The minimum filing gate is:

- P1 defines the settings-task dependency, complete version/producer
  contracts, exact generator result semantics, and stable `GF-*` comparison;
- P1A separates production outcome from harness verdict, publishes atomic
  oracles, and proves exact helper/context script identity;
- P1B patches the evidence trigger, proves the real writer under an equivalent
  temporary ruleset, and activates/verifies the persistent `main` rule;
- P2 remains otherwise unchanged and consumes the corrected P1B handoff; and
- P3 publishes exact wrapper vectors, a hash-bound Husky contract, a complete
  process/stream/parser contract, atomic case rows, and reproducible
  scope-bound live issue evidence.

After those corrections, perform one final reciprocal read against the fixed
Terraform T1/T1A/T1B/T2/T3/T4 slate. Then the P issues are suitable for
sequential filing and implementation.

## Primary references

- [PSStyleGuide default-main baseline](https://github.com/franklesniak/PSStyleGuide/commit/4346310e7deebffb4159c75e30d9546263dfd649)
- [GitHub repository rulesets API](https://docs.github.com/rest/repos/rules)
- [GitHub branch protection API](https://docs.github.com/rest/branches/branch-protection)
- [Corepack package-manager descriptors](https://github.com/nodejs/corepack#when-authoring-packages)
- [Node distribution index](https://nodejs.org/dist/index.json)
- [Node 22.23.2 bundled Corepack record](https://raw.githubusercontent.com/nodejs/node/v22.23.2/deps/corepack/package.json)
- [Node 24.18.1 bundled Corepack record](https://raw.githubusercontent.com/nodejs/node/v24.18.1/deps/corepack/package.json)
- [npm 12.0.2 registry record](https://registry.npmjs.org/npm/12.0.2)
- [npm configuration](https://docs.npmjs.com/cli/v12/using-npm/config/)
