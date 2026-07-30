# Current PSStyleGuide issue-slate findings

## Review status

This review covers the current sequential P slate:

1. `01PSStyleGuideP1.md`;
2. `01aPSStyleGuideP1A.md`;
3. `01bPSStyleGuideP1B.md`;
4. `02PSStyleGuideP2.md`; and
5. `03PSStyleGuideP3.md`.

The review uses the criticism in `docs/planning/PSStyleGuide/slate-criticism.md`,
the planning-tree state at PSStyleGuide commit
`977d315d1cb123cc080176055d6034a1f28811e4`, the corresponding copied P files
at TerraformStyleGuide commit `87eb81f`, and the live default branch at
`4346310e7deebffb4159c75e30d9546263dfd649`.

The slate structure, order, issue identifiers, and H1-as-title convention are
sound. No issue addition, deletion, rename, or reorder is warranted. P2 is
ready after corrected predecessors land. P1, P1A, P1B, and P3 require another
contract-closure pass before filing.

## Primary-source and live-state validation

Read-only checks on 2026-07-30 confirmed:

- `main` remains the PSStyleGuide default branch;
- the repository ruleset list is empty;
- classic protection for `main` returns `404 Branch not protected`;
- the official GitHub Actions application still resolves to owner `github`,
  slug `github-actions`, integration ID `15368`; and
- the five P issue drafts are byte-identical in both planning trees.

Current primary sources also confirm:

- GitHub `push.branches` filters use short branch names such as `main`, while
  `github.ref` is a full ref such as `refs/heads/main`;
- repository rulesets can require pull requests, strict/current status checks,
  resolved conversations, deletion protection, and non-fast-forward
  protection;
- a ruleset bypass actor can be an `Integration`, and `always` and `exempt`
  are materially different modes;
- GitHub exposes the active rules that apply to a named branch, which is the
  correct post-activation effective-state check;
- npm's `package-lock-only` mode limits installation state to the lock, while
  `ignore-scripts` is a separate control and is necessary because the
  repository has a root `prepare` lifecycle;
- Node emits `close` only after the child ends and stdio closes, `error` and
  `exit` can race, a delivered signal need not terminate a process, and killing
  a parent does not generally prove its descendants stopped; and
- GitHub's issue API distinguishes issues from pull requests and exposes the
  stable IDs, state, labels, assignees, timestamps, title, and body needed for
  a scope-bound exception record.

Detailed source URLs and the exact live commands/results are retained in
`docs/planning/artifacts/prompt-loop-primary-source-research-2026-07-30.md`.

## Criticism recommendation audit

### Slate structure and sequencing

**Confirmed.** Keep P1 → P1A → P1B → P2 → P3. P1 establishes read-only
generation and policy foundations; P1A creates workflow-inert candidate
validation; P1B activates the sole publication path; P2 is the first ordinary
content exercise; and P3 deliberately supersedes the interim runtime and
dependency policy. P1's dated advisory authorization remains the gate that
makes placing P3 last defensible.

The title-only P2 reference from P3 does not require a fabricated URL. P3 can
record P2's permanent URL and dependency edge when P3 is filed.

### Cross-cutting `main` governance

**Confirmed blocker.** P1B's exact lease is a stale-write control, not a
substitute for repository governance. With no active ruleset or classic branch
protection, contributors, administrators, and other integrations are not
constrained by the intended pull-request/check/conversation/current-branch
policy.

P1 must require a separately authorized administrator settings task. It must
freeze current, desired, and rollback JSON; target exactly
`refs/heads/main`; prohibit deletion and non-fast-forward updates; require a
pull request, resolved conversations, strict/current checks, and the stable
P1B terminal check; and allow exactly the re-resolved official GitHub Actions
integration in `always` mode. Repository settings remain outside P1's affected
file set.

The settings task needs a two-stage dependency:

1. before P1B production activation, test a field-equivalent temporary rule
   on the evidence ref; and
2. after the P1B pull request has produced the stable terminal context but
   before it merges, activate and query the persistent `main` rule.

P1B is blocked on this settings task. P2 and P3 must re-query the exact active
rule, effective branch rules, required check source, and sole bypass before
using the writer handoff. Until then the issues must not call `main`
“protected.”

### P1 version contract

**Confirmed required correction.** P1 publishes only the generator's initial
version template. It does not define the exact `.NOTES` marker, timeless
grammar, expected-version trust source, error taxonomy, change classification,
or same-day progression that P1A already claims to consume. It calls the Git
path verifier “versioned” without specifying its marker or initial version.

P1 must define a slate-wide PowerShell script version profile:

- exactly one `Version: <Major>.<Minor>.<YYYYMMDD>.<Revision>` marker in the
  script-level `.NOTES` block before the first function;
- canonical ASCII nonnegative components with no leading zero except `0`,
  valid `System.Version` bounds, and a real Gregorian build date;
- timeless parsing independent of clocks, filesystems, Git timestamps, and
  file timestamps;
- an expected version bound by a separate reviewed path/commit/blob/hash
  record;
- distinct `invalid-version`, `unexpected-version`, and
  `version-progression` failures; and
- progression from the merge-base version, semantic change class, and UTC date
  of the final material edit, with Revision incremented for a second material
  edit on the same UTC date.

The generator and path verifier receive explicit first-publication versions.
P1A and P3 must consume the landed profile for every PowerShell script they
add or change.

### P1 lock producer

**Confirmed required correction.** Selecting Node `24.18.1` and bundled npm
`11.16.0` does not identify the state-changing command or neutralize the root
`prepare` lifecycle. P1 must require a clean disposable producer, verified
official Node artifact/checksums/signature evidence, exact `yaml: 2.9.0`, and:

```text
npm install --package-lock-only --ignore-scripts --no-audit --no-fund
```

It must retain executable/version/supply/config evidence with secrets redacted
and pre/post package/lock hashes. Every nonproducer is a frozen
`npm ci --ignore-scripts --no-audit --no-fund` consumer and must prove package
and lock bytes unchanged.

### P1 generator result and reciprocal convergence

**Confirmed required correction.** P1 names `RolledBack` and
`ReplacementStateUncertain` but does not publish the exact result schema that
P1A says it consumes. Its P1↔T1 comparison is a prose topic list rather than a
stable executable matrix.

P1 must publish:

- a closed generator invocation/result schema with success, no-change,
  rollback, uncertain-state, cleanup, per-path pre/post identity, backup
  disposition, failure phase/category, bounded recovery evidence, and exit
  mappings;
- crash-boundary and cleanup truth rules; and
- the same stable 16 `GF-*` row meanings used by T1, with one row each,
  immutable commits/locators/evidence hashes, observed values or fixture IDs,
  and `same|intentional difference|blocker`.

The preferred convergence is the same private per-artifact writer boundary in
both repositories. If PS retains its four-file coordinator, it must explicitly
prove equivalent observable failure strength and document backup/crash/result
semantics as an intentional difference.

### P1A production outcome versus harness verdict

**Confirmed blocker.** The case catalog expects negative production
diagnostics, while the result schema says a passed case requires diagnostic
`None`. A correctly rejected malicious candidate therefore cannot be both an
expected production rejection and a passing harness case.

The result must separate expected and actual production result/status/phase/
diagnostic from `HarnessVerdict: pass|fail|skip`. A negative case passes when
the actual rejection exactly matches its oracle. Applicability is an honest
skip. Harness errors are reserved for fixture or orchestration failures.

### P1A atomic case oracles

**Confirmed required correction.** The 96-case total is arithmetically sound,
but ranges such as `PS-P1A-E-01..15` and slash/“plus” descriptions do not bind
each immutable ID to one fixture and one expected outcome. The implementer is
still required to invent the ID allocation.

P1A must require a physical row for each of the original 96 IDs, either
containing the complete oracle or referencing an immutable single oracle
profile. The trusted-script correction requires 14 additional atomic Git
identity rows, for a selected final total of 110. Each row must singularly bind
applicability, fixture, initial state, expected production
result/status/phase/subreason/diagnostic, pre-cleanup state, final
candidate/context state, ordered cleanup sequence, sentinels, source-tree
state, and expected filesystem/native calls. Catalog mutation cases must reject
missing, duplicate, unknown, regrouped, orphaned, multiply emitted, and
undeclared-skip IDs.

### P1A trusted script inputs and public functions

**Confirmed required correction.** The `S-*` inventory mentions supplied
helper/context paths without defining a mandatory harness interface or proving
those paths are the reviewed repository blobs. An untracked, staged,
worktree-modified, filtered, wrong-mode, conflict-stage, or cross-repository
script could otherwise generate trusted-looking evidence.

The harness must accept mandatory raw `HelperPath` and
`ContextManagerPath` plus separately trusted expected versions. It derives the
repository root from fixed `$PSScriptRoot`, then proves fixed literal path,
ordinary `100644` HEAD blob, matching stage-0 index with no conflict stages,
and no-filter working object ID equal to HEAD/index before dot-sourcing and
immediately before use. P1's raw NUL-safe Git discipline applies.

P1A must also publish exact parameter, return, mutation, diagnostic, and
failure contracts for `New-StyleGuideCandidateInvocationContext`,
`Remove-StyleGuideCandidateInvocationContext`, and
`Remove-StyleGuideCandidateInvocationState`; object schemas alone do not
define callable interfaces.

### P1B evidence trigger

**Confirmed blocker.** P1B changes predicates from `refs/heads/main` to an
evidence ref but leaves `on.push.branches: [main]`. A push to the evidence ref
would not start the workflow. The short trigger name and full predicate ref are
different literals and cannot be corrected by one replacement.

P1B needs a versioned allowed-delta manifest that enumerates exact
evidence-only hunks for the short push branch filter, full-ref approval/writer
predicates, `TARGET_REF`, policy constants, bounded scenario
selector/instrumentation, and one safe source fixture. The comparator must
reject every other trigger, permission, graph, action, input, artifact,
credential, path, commit, lease, refspec, or diagnostic change. Dispatch
events, wildcard refs, secret inheritance, caller-selected refs, and copied
workflows remain prohibited.

### P1B ruleset proof and cleanup

**Confirmed blocker.** P1B must integrate the governance task rather than
merely receive it in prose. The real writer must succeed under the temporary
field-equivalent evidence-ref rule. Stale/lost lease, non-fast-forward,
deletion, and ordinary-maintainer direct updates must fail without moving the
ref.

Cleanup must wait for or cancel every evidence run, delete the ref with an
expected-old guard, prove no active workflow or policy names it, delete the
temporary rule, and re-query restored settings. Cleanup failure blocks
production activation; it never permits an unprotected fallback. The
persistent `main` rule must be active/effective, with exact terminal context
and sole official-Actions bypass, before P1B merges.

### P2

**Confirmed with one dependent edit.** P2's content oracle, scope, generated
artifact discipline, pull-request no-writer proof, and post-merge no-change
proof remain appropriate. Do not add package, generator, workflow, or policy
work to P2.

P2's consumed/handoff evidence must add the active ruleset ID, normalized rule
digest, effective-rule query result, stable required terminal context/source,
and sole official-Actions bypass identity. P2 must stop if that governance
state drifted.

### P3 wrapper operation table

**Confirmed required correction.** Naming five operations is not an invocation
contract. P3 must publish one literal versioned operation table for every real
operation. The selected resolution retains `ci`, `audit`, `lock-noop`, and
`run-lint` and removes unused `run-test`, because the repository has no package
test script or production consumer. Every retained row includes:

- verified `process.execPath` and bundled Corepack entry identity;
- complete ordered argv;
- working directory;
- network/cache/config mode;
- exact environment additions/removals;
- stdin/stdout/stderr handling;
- timeout/termination behavior;
- accepted native exits; and
- permitted filesystem side effects.

The wrapper, hook, audit validator, workflows, and policy fixtures must all
consume the same table or its immutable digest.

### P3 Husky identity

**Confirmed required correction.** “Exact lock-resolved Husky” plus a dynamic
import does not bind the actual package, public entry point, generated support
tree, or tracked hook. P3 must freeze the selected Husky package version,
tarball/integrity, lock node, package root, invoked public API/CLI, reviewed
package-file hashes, and invocation boundary after dependency selection.

It must also freeze the tracked `.husky/pre-commit` HEAD/index/no-filter
working identity, marker/version, length/hash/mode, exact `core.hooksPath`, and
complete `.husky/_` path/type/content/hash/mode inventory. The installer needs
a closed decision result and atomic required/skip/conflict/import-or-spawn/
native/postcondition/immutability/real-commit cases.

### P3 audit process, streams, and parser resources

**Confirmed blocker.** A timeout and byte ceilings are insufficient without a
state machine. Node documents that `error`, `exit`, and `close` can interleave,
that signal delivery does not prove termination, and that killing a parent
does not prove descendants stopped.

P3 must publish one immutable native-outcome object and state machine covering
start, stream reads/errors, overflow, timeout, termination request/delivery,
grace expiry, final close, cleanup, and one-result emission. It must specify
whether overflow triggers termination, continued bounded draining, TERM/KILL
or Windows behavior, descendant-process limits, fixed grace, valid
exit/signal/start-failure/timeout combinations, byte counts/digests, overflow
flags, bounded diagnostics, and precedence.

The strict JSON scanner also needs exact inclusive depth, token, property,
string-token byte/scalar, and numeric-token ceilings with below/at/above
fixtures. Where Windows cannot prove Unix-style process-group termination, the
issue must state the platform boundary and test the pure outcome model instead
of claiming portable descendant termination.

### P3 physical Node/audit catalogs

**Confirmed required correction.** The Node and audit catalogs describe
families, not immutable rows. The audit catalog has no frozen cardinality.
“Exactly once” is not testable until each ID has one literal fixture and
oracle.

Every Node and audit case must be a physical row or a row referencing one
immutable atomic profile. Audit rows singularly bind layer, raw
length/digest/fixture, native outcome, exception state, terminal class,
normalized finding set, package-keyed node paths, parser state, process-call
count, and bounded diagnostic. Multi-defect rows are allowed only as named
precedence cases. Catalog mutation cases cover missing, duplicate, unknown,
regrouped, orphaned, multiply emitted, and skipped IDs.

### P3 live exception evidence

**Confirmed required correction.** The current issue projection can prove that
an open labeled assigned issue exists, but not that its content governs the
exact findings. A maintainer is also told to “live-generate” canonical
evidence without any named capture implementation.

P3 must add a named read-only capture mode/tool. Each follow-up issue receives
a canonical scope hash over the exact sorted finding set and a required body
marker carrying that hash. The canonical projection binds repository, number,
numeric/database ID, node ID, `isPullRequest=false`, state, sorted labels and
assignees, owner, target date equal to exception expiry, scope hash, bounded
title/body-marker hashes, updated/fetched timestamps, API version, and closed
property order/preimage.

The live client needs an exact request API version, retry count, accepted
`Retry-After` forms and cap, pagination disposition, size limits, and
fail-closed response rules. Verification freshly fetches state and fails on
scope/content/state/owner/date drift. It never silently refreshes approval.

### Cross-slate convergence model

**Confirmed.** Converge on stable semantic rows, schema shapes, evidence, and
security/failure semantics while keeping both repositories self-contained.
Repository-specific source transforms, artifact names, frontmatter, cleanup
lifecycle, staged-lint architecture, and content work can remain intentional
differences.

The current SHA-224 npm descriptor is valid and must not be treated as a
correctness defect. Converging on T3's SHA-512 descriptor is a low-risk
consistency improvement because it is the hex form of the already-recorded
registry SRI. The selected resolution should use SHA-512 unless re-resolution
changes the tuple.

## Independent findings

### A settings task is a predecessor contract, not an affected implementation file

The governance correction must not silently expand P1's ten implementation
paths or P1B's five implementation paths. The correct artifact is a separately
authorized administrator task/record whose immutable URL, approved JSON,
execution evidence, rule ID/digest, and rollback evidence become consumed
contracts. This preserves both repository-settings authorization and exact
Git path-set validation.

### Required-check identity must be discovered before persistent activation

The desired ruleset cannot safely invent the terminal check name/source.
P1B must first produce the stable terminal check on its pull request, capture
the exact context and GitHub Actions source, and only then authorize persistent
activation. The pull request cannot merge until the activated rule is queried
and proven effective. This closes the otherwise circular dependency without
temporarily weakening `main`.

### Version and case profiles need one physical owner

Repeating prose copies across P1, P1A, P1B, and P3 invites drift. P1 should own
the PowerShell version profile; each successor consumes it and names only its
script-specific expected versions. Likewise, each case catalog may use
immutable oracle profiles to control document size, but every physical case row
must reference exactly one profile and carry every case-specific identity.

### P3 should align the descriptor digest with T3

The SHA-224 descriptor is accepted by Corepack and is not defective. Selecting
the same SHA-512 descriptor used by T3 reduces an unnecessary reciprocal
difference, makes the descriptor hex directly traceable to the stored registry
SRI, and simplifies the manager-evidence row. This is selected only if the
pre-implementation registry re-resolution confirms the same tarball/integrity.

## Filing assessment

Do not file the slate unchanged. Preserve the five-file slate and order, then
resolve the findings above. The correction pass should not add issue files.
After revision, rerun the reciprocal review against the current T slate and
require no unexplained `blocker` row before filing.
