# Feedback on the TerraformStyleGuide T1/T1A/T1B/T2/T3/T4 issue slate

## Overall assessment

Keep the six-issue split, embedded H1 titles, T identifiers, and this one
execution order:

1. T1;
2. T1A;
3. T1B;
4. T2;
5. T3; and
6. T4.

The generator/writer foundations have converged substantially with the revised
PSStyleGuide slate. In particular, P1 now uses T1's private per-artifact
`File.Replace(...,$null)` boundary, the same timeless version grammar, the same
exact lock-producer command, the same 16 `GF-*` meanings, and equivalent
separately authorized `main` governance. P1B and T1B both enumerate the short
evidence trigger separately from full-ref predicates and test the real writer
under a temporary equivalent rule. P3 and T3 now use the same SHA-512 npm
descriptor and a 184-row audit semantic catalog.

Those are meaningful convergence wins. Do not reopen them.

I would still not file the T slate unchanged. T1A explicitly leaves its
physical case catalog unfinished; T2 consumes an interface no predecessor
creates and leaves several copyable policies open; T3 retains unresolved case
families and lacks a literal schedule/package-operation/live-retry contract;
and T4 applies a local-only `state rm` flag to remote/HCP modes while leaving
state-bearing path ownership incomplete.

| Finding | Issue(s) | Priority |
| --- | --- | --- |
| S-01 | T1, T3 | High |
| C-01 | T1A | High |
| C-02 | T1A/P1A | Medium |
| W-01 | T1B | Medium |
| P-01 | T1, T1B | Medium |
| T2-01 | T1/T1B/T2 | High |
| T2-02 | T2 | Medium |
| T2-03 | T2 | High |
| T2-04 | T2 | Medium |
| T3-01 | T3 | High |
| T3-02 | T3 | High |
| T3-03 | T3 | Medium |
| T3-04 | T3 | Medium |
| T3-05 | T3 | Medium |
| T4-01 | T4 | High |
| T4-02 | T4 | High |

## Review basis

This review compares:

- the revised PSStyleGuide P slate at local commit
  `7d207482fcc4cfea20af450a73054aeac552abeb`;
- the current TerraformStyleGuide T slate copied in PSStyleGuide at that same
  planning commit;
- the byte-identical T slate in TerraformStyleGuide planning commit
  `45df8ee86df8879eb8d597d1e048b551647151bc`; and
- TerraformStyleGuide default `main` at
  `6ee3f57b2b71b885a5927b770dde47532944de62`.

The T drafts address real current-state shortcomings: edition-dependent
generator writes, broad write-workflow authority, mutable action tags, old
Node policy, ambient npm/Husky behavior, and missing line-ending/update
governance.

Current primary-source checks also confirm two T2/T4 policy facts:

- Amazon S3 reserves the `xn--`, `sthree-`, and `amzn-s3-demo-` prefixes and
  the `-s3alias`, `--ol-s3`, `.mrap`, `--x-s3`, and `--table-s3` suffixes, and
  gives `-an` a specific account-regional namespace meaning.
- The command-specific Terraform `state rm` documentation says `-state`,
  `-state-out`, and `-backup` are legacy options for local state only, even
  though the general state-command page describes automatic backup behavior
  more broadly. The command-specific contract governs copyable `state rm`
  argv.

## Convergence already achieved

### Generator write/failure semantics

The earlier P1/T1 blocker is resolved. Both now:

- compute all complete payloads before mutation;
- use one private closed artifact-ID/destination map;
- write and durably flush one unpredictable same-directory candidate;
- verify complete bytes before one `File.Replace(candidate,destination,$null)`;
- put no fallible semantic gate after a successful replacement;
- prohibit copy/move/direct-write fallbacks; and
- report partial earlier-artifact completion truthfully rather than claiming
  cross-file rollback or crash atomicity.

Keep this shared `GF-WRITE`/`GF-FAILURE` model.

### Versions, lock production, and reciprocal rows

T1 already has the model P1 now consumes:

- timeless `.NOTES` version grammar;
- a separately trusted expected version;
- an implementation/merge authoring-progression gate;
- exact
  `npm install --package-lock-only --ignore-scripts --no-audit --no-fund`;
- frozen consumers; and
- the 16 stable `GF-*` rows.

Keep those meanings synchronized. Repository payloads/frontmatter and T1's
temporary writer can remain intentional differences.

### Writer trigger and branch governance

T1/T1B already distinguish:

- short `on.push.branches` evidence names;
- full evidence refs in conditions and `TARGET_REF`;
- an upfront allowed-delta manifest;
- the sole official-Actions `always` bypass;
- a temporary equivalent evidence-ref rule; and
- persistent active/effective `main` proof before merge.

This now matches P1/P1B's responsibility split. Preserve it.

### Audit semantic rows

T3's `AUDIT-001` through `AUDIT-184` meanings now have direct counterparts in
P3's `PS-P3-AUDIT-001` through `PS-P3-AUDIT-184` rows. Both use strict raw
bytes, structured native outcome, 120-second timeout, 5-second termination
grace, 8-MiB stdout, 64-KiB stderr, exact report-v2 shapes, package-keyed
topology, issue-scope evidence, and a Windows process-tree limitation rather
than a false parity claim.

Treat those meanings as a shared semantic checklist. The repositories can keep
different production orchestration: T3's external driver/outcome files and
P3's in-process spawn owner are acceptable if reciprocal evidence shows equal
failure truth.

## Findings to correct before filing

### S-01 — Remove the second execution graph

T1 calls T1-first the “default order” but permits T3 to execute first if the
advisory decision refuses temporary exposure. T3 repeats that alternate graph.
The supplied premise is one sequential listed order.

Keep the dated advisory decision as a go/no-go gate:

- accepted temporary exposure permits T1 → T1A → T1B → T2 → T3 → T4;
- refused/expired/materially worsened exposure stops this slate and requires
  reissued/renumbered issues; and
- no filed issue supports two predecessor graphs.

Do not smuggle a partial dependency update into T1 or T2.

### C-01 — Finish T1A's physical catalog before filing

T1A defines `T1A-CASES-v1`, `T1A-ORACLES-v1`, singular expected/actual fields,
and correct `HarnessVerdict` semantics. It then says every current row “must be
transcribed ... before filing,” split remaining disjunctions, replace ordinal
semantic names, and append Git-identity cases. That pre-filing work is still
present as an instruction rather than completed data.

Finish the catalog now. Every physical row must have:

- one immutable T-local ID and behavior-named semantic key;
- one oracle profile and only its permitted variations;
- one applicability/runtime set and literal fixture identity;
- one expected production result/status/phase/subreason/diagnostic;
- exact pre-cleanup/final candidate/context states and cleanup sequence;
- exact sentinel/source-tree/native-call results; and
- no ranges, slash lists, “or,” “then,” ordinal placeholder key, or unresolved
  family.

Add physical mutation rows for missing, duplicate, unknown, regrouped,
multiply emitted, skipped-without-authority, orphaned, and unused profiles.
After this, the implementation transcribes/validates a frozen catalog; it does
not decide what each ID means.

P1A's new 110-row table is a useful format, not a requirement to reuse P IDs
or cardinality. Preserve T-specific cleanup cases and join reciprocally on
semantic key.

### C-02 — Resolve terminal candidate-cleanup behavior explicitly

P1A makes `Disposed` and `CleanupFailed` terminal capability states: repeated
calls perform zero provider/path/filesystem/native calls and never inspect a
released name. T1A's caller context is zero-call when disposed, but its
candidate `Disposed` state revalidates the parent and enumerates the leaf; a
reoccupied name can change the returned state.

Both avoid deleting a reoccupied object, but they are not the same lifecycle.
Select one before filing. The simpler convergence is:

- after a proved transition to `Disposed`, ownership is released;
- a repeated call validates only the closed in-memory object and returns the
  same success with zero external calls; and
- a new object at the released name is outside the old capability.

If T1A intentionally retains reinspection, publish one literal reciprocal
intentional-difference row with exact calls, transitions, security rationale,
owner, and review condition. Do not label the behaviors `same`.

### W-01 — Close T1B diagnostic producer/consumer literals

T1B reserves Windows/writer diagnostic upload roles and states the desired
security properties, but still leaves the producer step/output/path and some
action values as prose such as “explicit missing-file behavior.”

For each diagnostic role publish:

- producer step ID and one exact bounded output path/output name;
- canonical LF/BOM-less redacted schema and allowlisted copied files;
- literal collision-free artifact name expression;
- exact upload path expression and condition
  `${{ failure() && !cancelled() }}`;
- `if-no-files-found: error`, `retention-days: 7`,
  `compression-level: 0`, `overwrite: false`,
  `include-hidden-files: false`, and `archive: true`; and
- positive/negative policy cases for path/name/predicate/input drift.

The producer and upload may be best-effort, but neither may hide the primary
failure or read arbitrary workspace/log/environment/Git/credential state.

### P-01 — Add complete pre-merge provenance freeze gates

T1 re-resolves its supply tuple immediately before implementation; T1B does the
same for actions. A full SHA is immutable, but its release/tag justification,
manifest/defaults, runtime, package security status, or selected Node artifact
can change while the pull request is open.

Repeat the complete freeze immediately before merge:

- action repository/release/tag/full SHA/action manifest digest/runtime and
  every input/default disposition;
- Node artifact and signed checksum evidence;
- bundled npm/Corepack identity;
- YAML/npm tarball/integrity/bytes;
- effective producer/consumer configuration; and
- dated audit/security result.

Drift stops for renewed review and atomic contract/evidence update. It never
silently repins.

### T2-01 — Provide the reusable native Git interface T2 consumes

T2 says to consume “T1B's merged native Git reader/status classifier” and
prohibits reimplementation. Neither T1's eight paths nor T1B's three paths
creates a reusable helper with that API.

Either add a predecessor helper and handoff or put the complete interface in
T2. Name its exact path/version and define:

- fixed-root and raw scalar parameter contract;
- closed porcelain/cached-diff/commit-parent/quiet modes;
- raw NUL/byte parsing, active object-format IDs, and literal pathspecs;
- stable native status/result/diagnostic schema;
- complete stdout/stderr/cardinality/termination behavior; and
- hostile filename, malformed record, conflict, mode, missing object, and
  native failure fixtures.

A workflow-specific prose behavior is not a callable predecessor interface.

### T2-02 — Choose one HCP page-number grammar

The input map caps `TFC_PAGE_NUMBER` at 20 digits, while the later validator
uses an unbounded positive-decimal regex. Pick one.

If 20 digits is the policy, use the same grammar everywhere and add 19-, 20-,
and 21-digit rows with string-only handling that cannot overflow. If arbitrary
canonical decimal length is intended, remove the cap everywhere and add an
explicit resource ceiling independent of integer conversion.

### T2-03 — Publish the literal AWS bucket policy

“No reviewed reserved form” is not executable. The issue's narrower character
grammar still admits official reserved forms, including `sthree-` and
`amzn-s3-demo-` prefixes and `-s3alias`; it also needs an explicit account-
regional `-an` decision.

Freeze one literal prefix/suffix set in the issue and the offline catalog:

- prefixes: `xn--`, `sthree-`, `amzn-s3-demo-`;
- suffixes: `-s3alias`, `--ol-s3`, `.mrap`, `--x-s3`, `--table-s3`; and
- `-an` only under an explicitly supported account-regional namespace shape,
  or reject it in this deliberately narrower policy.

Add immediately shorter/exact/longer and case/position fixtures for every
literal. State whether the set is a dated frozen subset or tracks an upstream
version; a link alone is not permanent offline authority.

Primary source:

- <https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucketnamingrules.html>

### T2-04 — Select the Bash minimum in the issue

T2 asks the implementer to choose the minimum Bash version. That version
determines which syntax is safe in the copyable blocks and harness.

Put one literal minimum and exact failure diagnostic in the issue. Add below,
at, and above fixtures and a malformed/unavailable-runtime case. A hosted image
expected to provide the version is environment evidence, not a runtime guard.

### T3-01 — Separate observed audit facts from approval metadata

T3's normalized current `Findings` include disposition/evidence choices, while
exception entries add controls, owner, approval, expiry, and follow-up
metadata. The issue then asks current findings and approvals to compare by
exact equality, even though a raw audit cannot derive governance decisions.

Use two closed collections:

1. `ObservedFindings`, derived only from raw audit, installed tree, lock, and
   native envelope; and
2. `Approvals`, keyed by exact `(Package, AdvisoryUrl)` and holding governance
   metadata.

Require exact key-set equality. Compare copied observed fields—severity, range,
source/advisory identity, fix availability, dependency types, and topology
hash—exactly. Validate reason/controls/owner/approval/expiry/follow-up fields
separately. Any observed security/topology/fix/scope drift invalidates approval.

### T3-02 — Split remaining Node/npm/hook families physically

T3 now has 184 physical audit rows, but it still describes `NPM-01..03`,
`HOOK-01..06`, and direct Node values across multiple platform/runtime cells
while also prohibiting family rows and more than one result per ID. The
evidence producer must not decide whether an ID meant one or several cases.

Before filing, either:

- allocate one physical immutable ID per platform/runtime case; or
- define `(ID, Platform, Runtime)` as the primary key everywhere and allow one
  result per declared tuple.

The first matches the existing acceptance language. Allocate every
`NODE-POLICY-*`, `NODE-CLI-*`, `NPM-*`, `HOOK-*`, and capture-helper ID with
literal fixture, applicability, expected outcome, identity, side effects, and
diagnostic. Reject missing/duplicate/unknown/regrouped/orphaned final keys.

### T3-03 — Select one literal governance schedule

T3 makes a read-only UTC schedule normative but gives no cron/cadence/time.
Use one literal and validate it. Reusing P3's:

```yaml
schedule:
  - cron: '23 17 * * 3'
```

would reduce cross-repository variance. Add exact positive, mutated-cron,
extra-schedule, deleted-schedule, and event-to-job topology cases. If another
cadence is needed, document why.

Primary source:

- <https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule>

### T3-04 — Publish a literal package-operation authority

T3 correctly requires hash-qualified Corepack npm and prohibits ambient
`npm`/`npx`, but manager arguments/config/network/cache/streams/timeouts/side
effects remain distributed across prose and callers. P3 now has one frozen
operation table.

Add a T-local `T3-NPM-OPERATIONS-v1` authority. For every install, audit,
lock-noop, lint, and hook/package-manager operation publish:

- verified Node/Corepack entry identities;
- complete ordered argv and cwd;
- exact environment additions/removals;
- user/global/project config inputs;
- network/cache/proxy/CA mode;
- stdin/stdout/stderr/timeout/termination ownership;
- accepted native exits; and
- permitted filesystem side effects.

The workflow, hook, audit driver, and fixtures consume that table/digest rather
than building manager commands independently. T-local operation names can
differ from P3; semantically equivalent argv/policy should compare `same`.

### T3-05 — Close capture/live-client retry behavior

T3's capture helper is strong: it binds scope, owner, target date, immutable
issue identity, title/body hashes, and a minimized canonical record. It does
not publish retry/rate-limit/redirect behavior.

Define exact API version and headers, response caps, redirect policy, total
attempts, retryable statuses, `Retry-After`/`x-ratelimit-reset` parsing and
maximum wait, fallback delays, and terminal behavior. GitHub documents both
primary and secondary rate limits using `403`/`429` and rate-limit headers.

A conservative implementation may fail immediately rather than wait beyond a
small cap, but it must not hammer the API, sleep unboundedly, accept stale
state, or silently refresh approval. Add physical cases for each response,
header, retry exhaustion, oversized/malformed body, drift, and valid capture.

Primary source:

- <https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api>

### T4-01 — Make `state rm` argv backend-valid

T4 requires `-backup="$RM_COMMAND_BACKUP_PATH"` for every `terraform state rm`
mutation and treats a binary lacking it as unsupported. The command-specific
Terraform reference says `-state`, `-state-out`, and `-backup` are legacy
options for local state only. That cannot be the universal HCP/remote contract.

Use the already-required protected pre-mutation `terraform state pull` capture,
identity, and attestation as the backend-neutral recovery evidence. Define
separate exact modes:

- local state: use the selected/pinned version's supported local-only backup
  argv and attest the produced backup; and
- HCP/remote state: omit the local-only flag by construction, retain the
  protected pull and backend/version/lock/run evidence, and never retry after
  an unknown-option failure.

Give each mode one literal argv and case set. Never silently omit/retry a flag.

Primary source:

- <https://developer.hashicorp.com/terraform/cli/commands/state/rm>

### T4-02 — Complete the state-bearing role/ownership table

T4 says every state-bearing role gets an exact parent/path/attestation, but its
canonical table omits later public/helper-sensitive files, including:

- state-show current/proposed documents and provider schemas;
- review manifest, temporary indexes, and redacted difference report;
- desired/current/recovery states and recovery review/report;
- state-rm match/resolver artifacts; and
- local-corruption source/destination/intermediate evidence.

Put every role in one table with exact public input names or mark it
helper-private under one invocation-context owner. For each role specify:

- creator and consumers;
- trusted parent/path/attestation fields;
- ordinary/link/containment/content/hash/size checks;
- lifetime and retention;
- cleanup owner/order;
- mutation and failure postconditions; and
- retained-uncertainty/manual-recovery evidence.

No state-derived path should be “defined later” in a destructive issue.

## Scope and reviewability

The six-stage dependency shape remains coherent. The corrections above do not
require merging issues.

T4 is still much larger than the other stages and combines a non-mutating
inspection foundation with destructive push/rm/recovery. After closing the
shared contracts, consider:

- T4 — protected capture, strict inspection, structural secret-safe
  difference, resource-address resolution, confirmation grammar, fixtures; and
- T4A — destructive push/rm execution, verification, recovery, and operational
  evidence.

That is a reviewability recommendation, not permission to postpone T4's path/
backend contracts. If split, update both repositories' prompt file lists in
one atomic planning change.

## Strengths to preserve

- T1/T1A/T1B mirror the P foundation without runtime cross-repository
  dependency.
- T1's private writer, version contract, producer discipline, ruleset task,
  and 16-row reciprocal matrix are strong.
- T1B's immutable artifact identity, four static Windows attestations,
  terminal approval, exact writer lease, honest credentials, allowed-delta
  evidence branch, and equivalent temporary rule are strong.
- T2 correctly separates discovery from recovery and uses no-clobber,
  identity-bound publication.
- T3's SHA-512 manager descriptor, finite Node policy, hash-bound Husky
  package/hook inventory, structured raw audit, 184 audit rows, and
  scope-bound capture evidence are strong.
- T4's protected capture, serial-successor recovery, secret-safe structural
  comparison, confirmation discipline, and prohibitions on force/lock bypass
  are strong.

## Recommended disposition

Revise the sixteen findings above, keeping the existing issue order and names
unless the author deliberately chooses the optional T4/T4A review split.
Then rerun the reciprocal matrices.

The next revision should produce:

- one execution graph;
- a completed physical T1A catalog and explicit cleanup comparison;
- literal diagnostic/provenance contracts;
- a real reusable Git interface and executable T2 input policies;
- physically allocated T3 families plus schedule/operation/retry authority;
- backend-valid T4 state-rm modes; and
- one complete state-bearing ownership table.

After those corrections, the slate will be suitable for sequential filing and
implementation.
