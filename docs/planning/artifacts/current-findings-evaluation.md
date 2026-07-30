# PSStyleGuide open-finding evaluations

## Evaluation status

Each open finding from `current-findings.md` is evaluated independently below.
Scores use a finding-specific weighted rubric. Criterion scores are on a
1–5 scale, where 5 is strongest. Weighted totals are normalized to 100.
Technical correctness, failure-state truthfulness, security, and legitimate
operator/contributor usability receive more weight than churn or implementation
convenience.

The selected resolutions preserve the five-issue order and introduce no new
GitHub Issue draft filename.

## F01 — Protect `main` while preserving one verified writer

### Finding

The current repository has no ruleset or classic protection. P1B's exact lease
prevents stale publication but does not force ordinary changes through current,
reviewed pull requests or preserve its terminal check.

### Options

- **A — No settings dependency.** Treat the writer lease and workflow policy
  as sufficient.
- **B — Classic branch protection.** Add a conventional `main` protection
  rule and allow administrators or the writer to bypass it.
- **C — Separately authorized exact ruleset task.** Freeze current/desired/
  rollback JSON; target only `refs/heads/main`; require PRs, current strict
  checks, resolved conversations, no deletion/non-fast-forward; require the
  stable P1B terminal context from the Actions source; allow only the
  re-resolved official Actions integration in `always` mode; test an equivalent
  temporary evidence-ref rule before persistent activation.
- **D — Move publication out of Actions.** Replace `GITHUB_TOKEN` publication
  with a PAT, deploy key, or new GitHub App and protect `main` around it.

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Effective branch protection | 35 | The policy must constrain every non-bypass path, not only one script. |
| Least-privileged bypass | 25 | A broad human/admin/PAT bypass defeats the sole-writer design. |
| Real-writer evidence | 20 | The chosen policy must be proven with the production writer. |
| Rollback and authorization | 15 | Settings mutations need explicit approval and recoverable state. |
| Scope/churn | 5 | Lower weight because security closure dominates convenience. |

### Scoring

| Option | Protection | Least privilege | Evidence | Rollback | Scope | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 2 | 2 | 2 | 5 | 35 |
| B | 3 | 2 | 3 | 3 | 3 | 56 |
| C | 5 | 5 | 5 | 5 | 4 | **99** |
| D | 4 | 2 | 3 | 3 | 1 | 61 |

### Selected resolution

Select **C**. P1 will require—but will not itself execute—a separately
authorized administrator settings task. The task record contains current,
desired, and rollback JSON; approver/role; window; exact rule and integration
identities; verification; audit evidence; and rollback procedure.

The persistent rule targets exactly `refs/heads/main`, has no exclusions,
blocks deletion/non-fast-forward, requires a pull request, resolved
conversations, a current branch, and P1B's exact stable terminal check from the
expected Actions application. Its only bypass is the re-resolved official
GitHub Actions integration in `always` mode. P1B is blocked on this task. P2
and P3 re-query the rule before consuming the handoff.

## F02 — Define one timeless PowerShell script-version contract

### Finding

P1 publishes an initial generator template but no complete marker grammar,
expected-version trust source, progression rule, or path-verifier version.
P1A refers to an undefined same-day rule.

### Options

- **A — Keep per-issue templates.**
- **B — Use file timestamps or Git commit dates as the version.**
- **C — P1-owned version profile.** One exact `.NOTES` marker, timeless
  grammar, trusted expected version, stable failures, merge-base/change-class/
  final-edit-date progression, and per-script initial values.
- **D — Replace embedded versions with hashes only.**

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Parse/validation correctness | 30 | Malformed or ambiguous versions must fail consistently. |
| Independence from ambient time | 25 | Validation cannot change merely because a clock or timestamp changed. |
| Authoring progression | 20 | Maintainers need one deterministic bump rule. |
| Diagnostic precision | 15 | Invalid, unexpected, and bad progression are different failures. |
| Cross-slate reuse | 10 | Later scripts should consume one landed profile. |

### Scoring

| Option | Correctness | Timeless | Progression | Diagnostics | Reuse | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 2 | 3 | 1 | 2 | 1 | 39 |
| B | 2 | 1 | 3 | 2 | 2 | 39 |
| C | 5 | 5 | 5 | 5 | 5 | **100** |
| D | 4 | 5 | 1 | 3 | 3 | 67 |

### Selected resolution

Select **C**. P1 owns `PSSTYLEGUIDE-POWERSHELL-SCRIPT-VERSION-v1`.
Every governed PowerShell script contains exactly one
`Version: Major.Minor.YYYYMMDD.Revision` in the script `.NOTES` before its
first function. Components are canonical ASCII nonnegative integers, within
`System.Version` bounds, with a real Gregorian build date. Parsing consults no
clock or timestamp.

Expected versions live in separately reviewed harness/policy metadata bound to
fixed path, commit, blob ID, and SHA-256. Validation distinguishes
`invalid-version`, `unexpected-version`, and `version-progression`.
Implementation progression starts from the merge-base version and semantic
change class; Build is the UTC date of the final material edit; a second
material edit on that date increments Revision. Each issue names the exact
first version of every new script.

## F03 — Close the P1 lockfile producer lifecycle

### Finding

P1 freezes Node/npm/YAML identities but not the exact lock-producing command.
The root repository has a `prepare` lifecycle, so omitting script suppression
is behaviorally significant.

### Options

- **A — Keep “generate with selected pair.”**
- **B — Use `npm install --package-lock-only` with defaults.**
- **C — Clean verified producer and frozen consumers.** Verify the official
  Node artifact, set only exact YAML, use the exact script/audit/fund-disabled
  producer command, retain effective config and hashes, then use frozen
  `npm ci` consumers.
- **D — Hand-author or normalize the lockfile.**

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Lock reproducibility | 35 | Equivalent producers must emit identical bytes. |
| Lifecycle isolation | 25 | `prepare` and dependency scripts must not mutate state. |
| Supply evidence | 20 | The executable and package source must be attributable. |
| Consumer immutability | 15 | Validation cells must not rewrite package/lock bytes. |
| Implementation cost | 5 | Lower priority than reproducibility. |

### Scoring

| Option | Reproducible | Isolated | Supply | Consumers | Cost | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 2 | 1 | 2 | 2 | 5 | 38 |
| B | 3 | 1 | 2 | 2 | 4 | 44 |
| C | 5 | 5 | 5 | 5 | 4 | **99** |
| D | 1 | 5 | 1 | 3 | 2 | 39 |

### Selected resolution

Select **C**. From a clean disposable clone, verify Node `24.18.1` against the
official signed checksum material, record the bundled npm `11.16.0`, set only
`yaml: 2.9.0`, and run exactly:

```text
npm install --package-lock-only --ignore-scripts --no-audit --no-fund
```

Record executable paths/versions, Node/checksum/signature evidence,
registry/proxy/certificate/peer/lock/script/audit/fund configuration with
secrets redacted, and pre/post package/lock hashes. Every other P1 cell runs
`npm ci --ignore-scripts --no-audit --no-fund` and proves the manifest and
lock remain byte-identical.

## F04 — Publish generator result semantics and stable reciprocal rows

### Finding

P1 names rollback/uncertain outcomes without the result schema P1A claims to
consume. Its reciprocal comparison has no stable row IDs.

### Options

- **A — Keep prose-only outcomes and comparison topics.**
- **B — Add a result enum but leave recovery details and reciprocal rows open.**
- **C — Closed result object plus shared `GF-*` catalog.** Prefer T1's
  per-artifact writer; otherwise fully specify the PS coordinator as an
  intentional difference.
- **D — Require cross-file crash atomicity from the underlying filesystem.**

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Failure-state truth | 30 | Success/rollback/uncertainty must reflect provable state. |
| Recovery safety | 25 | Backup retention and manual recovery cannot be ambiguous. |
| Reciprocal comparability | 20 | Generator unification needs stable semantic rows. |
| Fault-injection testability | 20 | Every boundary and outcome needs an oracle. |
| Complexity | 5 | Complexity matters only after safety is met. |

### Scoring

| Option | Truth | Recovery | Compare | Test | Complexity | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 2 | 2 | 1 | 2 | 5 | 38 |
| B | 3 | 3 | 2 | 3 | 4 | 57 |
| C | 5 | 5 | 5 | 5 | 4 | **99** |
| D | 1 | 2 | 2 | 1 | 1 | 29 |

### Selected resolution

Select **C**. P1 publishes a versioned result with exact ordered fields for
overall class, phase, failure category, native outcome, per-path original/
candidate/final hashes and identities, replace-returned state, temporary
disposition, cleanup outcome, bounded retained recovery identity, and stable
exit. Adopt T1's private per-artifact `File.Replace(...,$null)` boundary and
remove the cross-file backup/rollback coordinator. Compute all four payloads
first, but report partial earlier-artifact completion truthfully if a later
artifact fails; do not claim cross-file rollback or crash atomicity. Any
indeterminate replacement or unverifiable final state is
`ReplacementStateUncertain`.

P1 also adopts T1's exact 16 `GF-*` IDs and meanings. Each row appears once and
records both immutable commits/locators, evidence identities/hashes, observed
values or case IDs, one status, and rationale. The now-aligned private
per-artifact writer is expected `same`; repository-specific payload names and
frontmatter remain intentional differences.

## F05 — Separate P1A production behavior from harness judgment

### Finding

A negative production case must emit a non-`None` diagnostic, while the current
schema says a passing harness result requires diagnostic `None`.

### Options

- **A — Treat every expected rejection as a failed harness case.**
- **B — Suppress production diagnostics after a match.**
- **C — Separate expected/actual production fields and harness verdict.**
- **D — Split positive and negative cases into different result schemas.**

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Oracle correctness | 40 | A security rejection must be represented as a successful test. |
| Diagnostic preservation | 25 | Production failure data must not be erased. |
| Skip honesty | 15 | Inapplicable cases cannot masquerade as passes. |
| Machine validation | 15 | Relationships must be closed and testable. |
| Migration effort | 5 | Schema churn is secondary. |

### Scoring

| Option | Oracle | Diagnostics | Skips | Validation | Effort | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 4 | 2 | 3 | 5 | 42 |
| B | 2 | 1 | 3 | 3 | 4 | 39 |
| C | 5 | 5 | 5 | 5 | 4 | **99** |
| D | 4 | 4 | 3 | 2 | 2 | 66 |

### Selected resolution

Select **C**. Each result contains `ExpectedResult`, `ActualResult`,
`ExpectedStatus`, `ActualStatus`, `ExpectedPhase`, `ActualPhase`,
`ExpectedDiagnosticCode`, `ActualDiagnosticCode`, and
`HarnessVerdict: pass|fail|skip`, followed by the existing fixture, cleanup,
runtime, and call-count evidence.

A malicious archive correctly rejected in the expected phase with the expected
diagnostic has `HarnessVerdict: pass`. A primitive that is genuinely
unavailable has `skip` plus the exact probe/reason. Fixture construction,
catalog, or orchestration failures use a separate harness-error category. No
rule requires an actual production diagnostic to be `None`.

## F06 — Make all 110 selected P1A cases physically atomic

### Finding

Group ranges do not tell a cold implementer which ID owns which fixture and
oracle.

### Options

- **A — Keep prose groups and allow implementation-time allocation.**
- **B — Expand all data inline in 110 independent records.**
- **C — Atomic case rows plus immutable oracle profiles.** A row may reference
  exactly one profile while retaining case-specific identity/applicability.
- **D — Generate IDs at test runtime from semantic names.**

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Deterministic allocation | 35 | An ID must have one meaning before code exists. |
| Adversarial oracle depth | 25 | State, cleanup, sentinels, and calls all matter. |
| Catalog mutation defense | 20 | Missing/regrouped/orphaned cases must fail. |
| Maintainability | 15 | Repeated data should not invite drift. |
| Document size | 5 | Compactness is helpful but not authoritative. |

### Scoring

| Option | Allocation | Oracle | Mutation | Maintain | Size | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 2 | 1 | 3 | 5 | 35 |
| B | 5 | 5 | 5 | 3 | 1 | 90 |
| C | 5 | 5 | 5 | 5 | 4 | **99** |
| D | 2 | 3 | 2 | 4 | 4 | 53 |

### Selected resolution

Select **C**. Freeze `PS-P1A-CASES-v1` at exactly 110 physical rows: the
original 96 semantic cases plus 14 atomic trusted-Git identity cases required
by F07. Every row has one immutable ID and semantic key,
applicability/runtime set, fixture identity, initial state, expected
result/status/phase/subreason/diagnostic, pre-cleanup state, final
candidate/context state, cleanup sequence, sentinel and source-tree oracle,
and expected filesystem/native calls. Reusable data may live in one closed
oracle-profile table, but a row references exactly one profile and may not use
slash lists, “plus,” ranges, or alternative values.

Mutation fixtures reject missing, duplicate, unknown, regrouped, orphaned,
multiply emitted, undeclared-skip, and profile-unreferenced rows.

## F07 — Bind P1A supplied scripts to trusted Git state and close public APIs

### Finding

The harness can apparently accept helper/context paths without proving they
are the reviewed tracked scripts, and the exported functions lack complete
callable contracts.

### Options

- **A — Trust paths supplied by the workflow.**
- **B — Compare only file hashes to expected values.**
- **C — Fixed-root HEAD/index/no-filter identity at load and use, plus exact
  function signatures/results/failures.**
- **D — Embed copies of helper/context code in the harness.**

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Executed-code identity | 35 | Evidence is valid only for reviewed code. |
| Time-of-check/use resistance | 20 | Identity must be rechecked before invocation. |
| Hostile Git/path handling | 15 | Filters, conflicts, modes, and literal names matter. |
| Public API completeness | 20 | Object schemas do not define function behavior. |
| Implementation burden | 10 | Important, but subordinate to trust. |

### Scoring

| Option | Identity | TOCTOU | Git/path | API | Burden | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 1 | 1 | 2 | 5 | 28 |
| B | 3 | 2 | 2 | 2 | 4 | 51 |
| C | 5 | 5 | 5 | 5 | 4 | **98** |
| D | 4 | 4 | 3 | 3 | 1 | 66 |

### Selected resolution

Select **C**. Add mandatory raw `HelperPath` and `ContextManagerPath` harness
inputs and expected versions from trusted harness metadata. Derive the
repository root only from fixed `$PSScriptRoot`. For each fixed literal path,
prove one ordinary `100644` HEAD tree blob, one matching stage-0 index entry,
no conflict stages, a no-filter working object ID equal to HEAD/index, and the
expected version before dot-sourcing and immediately before later invocation.
Use raw NUL-safe records/literal pathspecs.

Publish exact `[CmdletBinding]` parameter names/types/binding rules, return
types, allowed mutations, lifecycle preconditions/postconditions, diagnostic
codes, and thrown/nonthrowing failure semantics for all three public cleanup/
context functions. Add atomic cases for every absent/staged/unstaged/
conflicted/wrong-mode/filtered/malformed/cross-root identity.

## F08 — Make the P1B evidence workflow triggerable and exactly equivalent

### Finding

Changing only full-ref predicates does not change `push.branches: [main]`, so
the evidence-ref push cannot start the workflow.

### Options

- **A — Add `workflow_dispatch` for testing.**
- **B — Temporarily allow all branches.**
- **C — Versioned exact allowed-delta manifest covering short trigger, full
  predicates, target constant, policy constants, bounded scenario plumbing,
  and one safe source delta.**
- **D — Copy `build.yml` into an evidence-only workflow.**

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Actual triggerability | 35 | The real evidence run must start from the evidence push. |
| Delta boundedness | 30 | Testing must not create a broader publication surface. |
| Production equivalence | 20 | The exercised writer must be the reviewed writer. |
| Abuse resistance | 10 | Caller refs, secrets, and dispatches stay prohibited. |
| Execution effort | 5 | Lower weight than fidelity. |

### Scoring

| Option | Trigger | Bounded | Equivalent | Abuse | Effort | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 2 | 3 | 1 | 4 | 57 |
| B | 5 | 1 | 4 | 1 | 4 | 55 |
| C | 5 | 5 | 5 | 5 | 3 | **98** |
| D | 5 | 3 | 1 | 3 | 3 | 62 |

### Selected resolution

Select **C**. Before creating the evidence commit, generate a closed
allowed-delta manifest listing every exact evidence-only hunk: short evidence
branch name in `on.push.branches`; full evidence ref in approval/writer
predicates; `TARGET_REF`; policy-validator constants; bounded scenario selector
and test instrumentation; and one safe source fixture that guarantees changed
generated bytes.

The structural comparator must prove all other events, permissions, jobs,
needs, actions, inputs, artifact contracts, credentials, paths, commit
algorithm, lease/refspec, and diagnostics equal production. It rejects
dispatches, wildcards, caller refs, secret inheritance, and copied workflows.

## F09 — Integrate equivalent-ruleset writer proof and fail-closed cleanup

### Finding

P1B does not run its real evidence writer under the proposed branch rule or
define complete restoration.

### Options

- **A — Test the writer before any ruleset exists.**
- **B — Activate the permanent `main` rule first and test only after merge.**
- **C — Temporary field-equivalent evidence rule, negative actor/ref drills,
  exact cleanup, then persistent activation and effective query.**
- **D — Grant a human administrator emergency bypass during rollout.**

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Governance assurance | 35 | The rule must actually constrain non-writer paths. |
| Writer fidelity | 25 | The production writer must succeed under equivalent rules. |
| Cleanup completeness | 20 | Evidence state/settings cannot linger. |
| Authorization/audit | 15 | Settings changes need explicit accountable control. |
| Operational cost | 5 | Lower weight than rollout safety. |

### Scoring

| Option | Governance | Fidelity | Cleanup | Authority | Cost | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 3 | 3 | 3 | 5 | 45 |
| B | 3 | 2 | 2 | 3 | 3 | 48 |
| C | 5 | 5 | 5 | 5 | 3 | **98** |
| D | 2 | 3 | 2 | 2 | 3 | 43 |

### Selected resolution

Select **C**. The administrator task creates a temporary rule identical to the
desired persistent rule except its exact evidence ref and any check that cannot
exist until the P1B PR runs. Under it, prove the real writer succeeds and
stale/lost lease, non-fast-forward, deletion, and ordinary-maintainer direct
updates fail without moving the ref.

Cleanup waits for or cancels every evidence run, deletes the ref with an
expected-old guard, proves no active workflow/policy names it, removes the
temporary rule, and re-queries the original settings. Any cleanup uncertainty
blocks production. After the PR exposes the stable terminal context, activate
the persistent rule, query its normalized JSON and effective rules for `main`,
verify the sole Actions bypass, and only then permit merge.

## F10 — Carry branch-governance proof into P2

### Finding

P2 consumes the writer but not the rule that makes it the sole direct updater.

### Options

- **A — Trust P1B's handoff without re-query.**
- **B — Record only the ruleset ID.**
- **C — Re-query ID, normalized digest, effective rules, required check/source,
  and sole bypass before P2; carry them in P2's final handoff.**
- **D — Add new branch-settings work to P2.**

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Fresh governance evidence | 35 | Settings can drift independently of Git commits. |
| Contract continuity | 25 | Later phases must know exactly what they rely on. |
| P2 scope preservation | 20 | P2 should remain a content issue. |
| Cold-reader clarity | 15 | Stop conditions and evidence must be explicit. |
| Churn | 5 | A small handoff edit is acceptable. |

### Scoring

| Option | Freshness | Continuity | Scope | Clarity | Churn | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 2 | 5 | 2 | 5 | 45 |
| B | 2 | 3 | 5 | 3 | 5 | 58 |
| C | 5 | 5 | 5 | 5 | 4 | **99** |
| D | 5 | 4 | 1 | 3 | 1 | 66 |

### Selected resolution

Select **C**. P2 remains a six-path content/artifact issue. Before coding it
re-fetches the persistent rule by ID, hashes normalized JSON, queries active
rules applying to `main`, verifies the exact required terminal context and
Actions source, and proves one official-Actions `always` bypass and no other
bypass. Missing, disabled, broadened, or drifted state stops implementation.
The same evidence is included in P2's handoff to P3.

## F11 — Publish one literal P3 npm-operation table

### Finding

P3 names wrapper operations but leaves their ordered arguments and runtime
behavior as “fixed settings.”

### Options

- **A — Let each caller assemble arguments.**
- **B — Centralize code but document only common flags.**
- **C — One versioned closed operation table consumed by every caller/policy.**
- **D — Invoke npm through shell command strings.**

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Invocation exactness | 35 | Subtle argv variance changes install/audit semantics. |
| Ambient-config resistance | 25 | Environment/config cannot weaken policy. |
| Single authority | 20 | Hook, workflow, audit, and tests must agree. |
| Auditability | 15 | A reviewer needs a literal ordered vector and side effects. |
| Table size | 5 | Compactness is secondary. |

### Scoring

| Option | Exact | Resistant | Authority | Auditable | Size | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 2 | 1 | 2 | 5 | 35 |
| B | 3 | 3 | 3 | 3 | 4 | 59 |
| C | 5 | 5 | 5 | 5 | 4 | **99** |
| D | 1 | 1 | 1 | 1 | 4 | 23 |

### Selected resolution

Select **C**. Define `PS-P3-NPM-OPERATIONS-v1` with one row each for `ci`,
`audit`, `lock-noop`, and `run-lint`. Remove the unused `run-test` name because
the repository has no package test script or production consumer; retaining a
name without one literal operation would create false authority. Every row
contains verified Node/Corepack identities, complete ordered argv, cwd,
cache/network/config mode, environment additions/removals, stdin/stdout/stderr
handling, timeout/termination owner, accepted native outcomes, and exact
permitted file side effects.

`Run-NpmPolicy.mjs` owns and freezes the table. The hook, audit validator,
workflows, test harnesses, and workflow-policy contract reference the exact
row/digest and may not construct their own manager arguments.

## F12 — Bind Husky installation and generated-hook identity

### Finding

The installer trusts a broad lock-resolved dynamic import without freezing the
package entry point, generated support files, or tracked hook identity.

### Options

- **A — Keep broad postcondition checks.**
- **B — Freeze only the Husky version/integrity.**
- **C — Freeze package/entry bytes, tracked hook, generated support inventory,
  decision result, and atomic cases.**
- **D — Replace Husky with a custom hook installer in P3.**

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Package/entry identity | 35 | The invoked implementation must be the reviewed one. |
| Installer decision correctness | 25 | Required/skip/conflict behavior must be deterministic. |
| Cross-platform behavior | 15 | Real Windows/Git Bash and Ubuntu hooks must agree. |
| Mutation detection | 20 | Hook/support tree drift must fail. |
| Effort | 5 | Lower priority than executing trusted code. |

### Scoring

| Option | Identity | Decision | Platforms | Mutation | Effort | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 2 | 3 | 3 | 2 | 5 | 46 |
| B | 3 | 3 | 3 | 3 | 4 | 59 |
| C | 5 | 5 | 5 | 5 | 3 | **98** |
| D | 4 | 3 | 2 | 4 | 1 | 65 |

### Selected resolution

Select **C**. After package selection, freeze exact Husky root dependency,
lock node, tarball/integrity, package root, public API/CLI entry, reviewed
entry/package-file hashes, and exact import/spawn semantics. Freeze tracked
`.husky/pre-commit` as ordinary `100755` or repository-confirmed Git mode with
schema/version marker, length, SHA-256, and matching HEAD/index/no-filter
working object.

Define exact `core.hooksPath` and every generated `.husky/_` path, entry type,
bytes/hash, and mode. The installer returns one closed decision record.
Atomic cases cover required install, authorized skip, conflicting controls,
untrusted/missing package or hook, import/spawn/native failure, postcondition
failure, source immutability, and a real commit through the installed hook.

## F13 — Close P3 audit lifecycle, streams, and parser ceilings

### Finding

The current timeout/stream ceilings and precedence do not define races,
termination, draining, cleanup, descendant behavior, or numeric JSON limits.

### Options

- **A — Rely on `spawn` events and current precedence.**
- **B — Use `execFile`/`maxBuffer` and accept platform defaults.**
- **C — Explicit one-owner state machine, structured outcome, bounded
  streaming/termination/cleanup, exact parser ceilings, platform boundary.**
- **D — Run audit in a container and treat container exit as the whole model.**

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Lifecycle determinism | 30 | Races must emit exactly one truthful result. |
| Process containment | 20 | Timeout/overflow must not leave unmanaged work. |
| Resource safety | 20 | Streams and JSON must have enforceable ceilings. |
| Cross-platform truth | 15 | Claims must match Windows and Unix capabilities. |
| Fixture testability | 10 | Below/at/above and race cases need pure oracles. |
| Complexity | 5 | Complexity is acceptable when bounded and necessary. |

### Scoring

| Option | Determinism | Containment | Resources | Platforms | Tests | Complexity | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 2 | 1 | 2 | 2 | 2 | 5 | 37 |
| B | 3 | 2 | 3 | 2 | 3 | 4 | 51 |
| C | 5 | 5 | 5 | 5 | 5 | 3 | **98** |
| D | 4 | 4 | 4 | 2 | 3 | 1 | 66 |

### Selected resolution

Select **C**. Define a closed audit native-state machine with one owner and one
terminal emission. The result records start state/error, pid, timeout, TERM/
kill request and delivery, fixed grace expiry, exit code/signal, close state,
stdout/stderr exact counts/digests/overflow flags, stream errors, cleanup, and
bounded diagnostic. Valid field combinations and terminal precedence are
explicit.

On first timeout or stream-limit event, mark the winning cause, stop retaining
bytes beyond the limit while continuing bounded draining, request termination,
wait the fixed grace and final close, then apply the documented forceful
fallback. No later event overwrites the primary cause. Start/error/exit/close
races cannot resolve twice. Unix may use a deliberately isolated process
group if implementable. Windows must not claim portable descendant termination;
test the production child plus pure lifecycle model and fail any unproven
cleanup.

Freeze inclusive JSON ceilings for depth, tokens, object properties, string
bytes/scalars, and numeric token bytes/digits. Add below/at/above fixtures for
each ceiling and every event race/overflow/termination combination.

## F14 — Make P3 Node and audit catalogs physical and immutable

### Finding

The catalogs describe semantic families rather than one ID-to-fixture/oracle
row. The audit catalog lacks a frozen count.

### Options

- **A — Keep narrative inventories.**
- **B — Allocate rows during implementation and freeze afterward.**
- **C — Predeclare physical atomic rows, immutable profiles, frozen counts, and
  catalog-mutation cases.**
- **D — Property-based random generation without stable case IDs.**

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Executable coverage | 35 | Every stated seam must become a deterministic test. |
| Physical atomicity | 25 | IDs cannot hide multiple independent defects. |
| Mutation detection | 20 | Missing/duplicate/regrouped/orphaned IDs must fail. |
| Reciprocal mapping | 10 | Stable semantic keys support P3↔T3 comparison. |
| Maintenance | 10 | Profiles can reduce safe repetition. |

### Scoring

| Option | Coverage | Atomic | Mutation | Reciprocal | Maintain | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 2 | 1 | 1 | 2 | 4 | 34 |
| B | 4 | 4 | 3 | 3 | 3 | 70 |
| C | 5 | 5 | 5 | 5 | 5 | **100** |
| D | 4 | 2 | 2 | 1 | 2 | 51 |

### Selected resolution

Select **C**. The issue freezes catalog version and exact row count after the
rows are authored; implementation may not invent, merge, or silently skip
rows. Each Node row has one raw value/type and expected normalized result,
category, exit, requirement, and consumer set.

Each audit row has one layer, fixture/raw length/digest, native outcome,
exception state, parser state, expected terminal class, normalized findings,
package-keyed paths, process-call count, and diagnostic. A row may reference
one immutable profile; multi-defect rows are explicitly labeled precedence
cases. Mutation fixtures reject missing, duplicate, unknown, regrouped,
orphaned, multiply emitted, skipped, and unused-profile records.

## F15 — Bind live exception issues to exact governed findings

### Finding

An open labeled assigned issue can satisfy the current verifier even if its
content does not describe the exact exception scope. No capture implementation
produces the canonical record.

### Options

- **A — Keep metadata-only issue verification.**
- **B — Compare title/body text directly without a canonical marker.**
- **C — Canonical finding-scope hash, required body marker, target date/owner,
  bounded content hashes, immutable IDs, named capture tool, exact API/retry
  behavior.**
- **D — Eliminate all exceptions and block unless audit is clean.**

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Finding-scope binding | 30 | Approval must cover exactly the residual findings. |
| Live freshness/integrity | 25 | Closed, edited, or reassigned issues must fail. |
| Maintainer usability | 20 | Humans should not hand-author IDs/digests/projections. |
| API failure behavior | 15 | Rate limits, malformed data, and drift must fail closed. |
| Data minimization | 5 | Retain only bounded governance evidence. |
| Churn | 5 | Secondary to security and operability. |

### Scoring

| Option | Scope | Fresh | Usable | API | Minimal | Churn | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 3 | 3 | 3 | 4 | 5 | 49 |
| B | 3 | 3 | 2 | 3 | 2 | 4 | 53 |
| C | 5 | 5 | 5 | 5 | 5 | 3 | **98** |
| D | 5 | 5 | 1 | 5 | 5 | 1 | 80 |

### Selected resolution

Select **C**, while preserving “no exception” as the preferred acceptance.
Canonicalize the exact sorted finding set and hash it. The follow-up issue body
must carry a versioned marker with that scope hash, responsible owner, and
target date equal to exception expiry. The stored projection includes
repository, number, numeric/database ID, node ID, `isPullRequest=false`, state,
sorted labels/assignees, scope hash, bounded title/body-marker hashes,
updated/fetched times, API version, and closed property order/preimage digest.

Add a named read-only capture mode/tool that fetches the issue and produces the
projection; maintainers never hand-author it. Define exact API version, maximum
attempts, retryable statuses, `Retry-After` syntax/cap, response/body limits,
and terminal failures. Verification freshly fetches live state and fails any
scope/content/state/owner/date drift without refreshing approval.

## F16 — Converge P3's npm descriptor on SHA-512

### Finding

P3's SHA-224 descriptor is valid but differs unnecessarily from T3's SHA-512
descriptor for the same tarball and registry SRI.

### Options

- **A — Retain SHA-224 and record an intentional difference.**
- **B — Use an unqualified `npm@12.0.2` descriptor.**
- **C — Use the T3 SHA-512 descriptor after re-resolution.**
- **D — Select a different npm version solely to eliminate the row.**

### Evaluation rubric

| Criterion | Weight | Why it matters |
| --- | ---: | --- |
| Supply traceability | 35 | Descriptor material should map directly to registry evidence. |
| Reciprocal convergence | 25 | Equivalent inputs should avoid arbitrary differences. |
| Corepack correctness | 20 | The descriptor must remain supported and exact. |
| Migration simplicity | 10 | This is a planning edit, not a runtime redesign. |
| Freeze-gate resilience | 10 | Re-resolution must still control changes. |

### Scoring

| Option | Trace | Converge | Correct | Simple | Freeze | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 4 | 2 | 5 | 5 | 5 | 76 |
| B | 2 | 5 | 2 | 5 | 2 | 55 |
| C | 5 | 5 | 5 | 5 | 5 | **100** |
| D | 2 | 2 | 3 | 1 | 1 | 42 |

### Selected resolution

Select **C** conditionally. Replace the descriptor with:

```text
npm@12.0.2+sha512.b885e890b9418fa1693544d05f53e64f9a73ec194837d4258b15fecdd692347b1dd2a517b1b0cbaf9d31cd8e92c3b70956bd2ecc72833a57b4b3098f5bfa7943
```

This is the lowercase hex representation of the currently recorded registry
SRI and matches T3. At P3's implementation freeze gate, recompute it from the
fresh registry/tarball record. Any changed bytes or integrity stops and
rebaselines the complete tuple; the planning value is not blind authority.

## Issue-integration trace

| Finding | Issue(s) updated | Required integration |
| --- | --- | --- |
| F01 | P1, P1B, P2, P3 | Separate settings task, sole bypass, persistent/effective evidence |
| F02 | P1, P1A, P3 | One P1-owned PowerShell version profile and per-script expected values |
| F03 | P1 | Exact verified producer and immutable consumers |
| F04 | P1, P1A | Closed generator result and stable `GF-*` matrix |
| F05 | P1A | Expected/actual production fields and harness verdict |
| F06 | P1A | 110 physical rows/profiles and mutation tests |
| F07 | P1A | Trusted Git blobs and complete public function contracts |
| F08 | P1B | Allowed-delta manifest patches trigger and predicates |
| F09 | P1B | Equivalent temporary rule, negative drills, cleanup, persistent rule |
| F10 | P2 | Re-query and hand off governance evidence |
| F11 | P3 | Literal versioned npm operation table |
| F12 | P3 | Hash-bound Husky package, hook, support inventory, decisions |
| F13 | P3 | Native state machine, resource ceilings, platform boundary |
| F14 | P3 | Physical Node/audit rows, counts, mutation tests |
| F15 | P3 | Scope marker/hash, capture tool, exact live verification |
| F16 | P3 | SHA-512 descriptor, subject to freeze-gate re-resolution |

## Final selection

All selected options are compatible and retain the existing issue boundaries:

- P1 owns foundational version, producer, generator-result, reciprocal, and
  external governance-task contracts.
- P1A owns atomic candidate oracles, truthful harness results, trusted script
  identity, and complete candidate/context APIs.
- P1B owns exact trigger-equivalent real-writer evidence, temporary-rule proof,
  cleanup, and persistent-rule activation gating.
- P2 remains content-only and revalidates the landed governance contract.
- P3 owns the literal manager table, verified Husky surface, audit lifecycle and
  resource model, physical catalogs, scope-bound live evidence, and final
  SHA-512 descriptor.

No selected option requires a new issue file, issue reorder, new parser engine,
shared cross-repository runtime, or weakening of the existing exact path-set
boundaries.
