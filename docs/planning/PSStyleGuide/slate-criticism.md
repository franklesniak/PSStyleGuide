# Criticism of the revised PSStyleGuide issue slate

## Review basis

This review compares the five revised PSStyleGuide drafts with the six revised
TerraformStyleGuide drafts as sequential implementation contracts. It treats
repository-specific behavior as intentional when the drafts say so and reports
only gaps that would still leave an implementer or validator a material choice.

The overall slate is substantially stronger. P1 has one explicit P1→P1A→P1B→
P2→P3 graph, a dated advisory gate, a two-gate supply tuple, exact generator/
Git/workflow-policy contracts, and symmetric evidence. P1A has a closed
110-row physical catalog and zero-call terminal cleanup. P1B has a single
least-privileged writer plus isolated real-ref/ruleset evidence. P3 has a
hash-qualified manager, literal package vectors, 48 physical Node cases, 184
physical audit cases, exact schedule, and live issue governance.

Six actionable closures remain.

## C-01 — P1B does not allocate literal diagnostic producers and paths

**Validity:** confirmed.

P1B's action-role table says the Windows and writer diagnostic uploads use an
“exact collision-free name/path,” and the following prose says exact paths
come from “the bounded diagnostic producer.” It never names that producer
step, its exact output path, its creation primitive, its byte ceiling, or the
literal upload path for either role.

This is circular authority: the workflow-policy contract cannot distinguish an
approved file from a newly selected file, glob, or directory because the issue
has not supplied the literal. T1B now closes the equivalent boundary with a
two-row producer/upload table.

**Recommendation:** add one normative table for the Windows-cell and writer
diagnostics. For each, freeze:

- sole producer step and ordered position;
- exact repository-relative path;
- no-replace BOM-less UTF-8/JSONL creation and byte ceiling;
- closed redacted schema;
- exact collision-free artifact name;
- every upload-artifact input and condition; and
- zero success/cancellation upload, glob, directory, alternate producer, or
  second-file behavior.

Add structural and runtime fixtures for missing producer, producer after
upload, wrong literal, wildcard/directory, oversized file, wrong encoding,
success/cancellation upload, and primary-failure masking.

## C-02 — P3 combines observed audit facts and human approval in one finding

**Validity:** confirmed.

P3's exception schema says each exception contains package/advisory facts,
range, severity, dependency types, installed paths, reason, controls, owner,
approval, expiry, and follow-up evidence in one finding object. That object is
then used as both the observed audit state and the approval.

The native npm report cannot produce reason, controls, owner, approval, or
expiry. Whole-object equality either asks observed normalization to synthesize
human governance or makes it unclear which subset is copied and compared.
Topology/fix-availability drift can also be missed if only the aggregate
finding identity is treated as observed.

**Recommendation:** use separate closed collections:

- `ObservedFindings` for report/tree/lock/native facts only; and
- `Approvals` for analysis, controls, owner, approval/expiry, and follow-up
  evidence.

Require exact `(Package, AdvisoryUrl)` key equality. Each approval should copy
and exactly match the reviewed severity, range, source, fix availability/type,
dependency types, topology, and report/lock identities from its observed row.
Validate current observed equality, copied-fact equality, node-path equality,
and governance in separate phases. Any fact, topology, scope, or expiry drift
must revoke the approval.

## C-03 — P3 leaves non-audit physical catalog records outside the issue

**Validity:** confirmed.

P3 physically lists all 48 Node rows and all 184 audit rows. Its Husky section,
however, abbreviates IDs `002`–`018` in prose and says the future committed
catalog will contain the literal records. The full/nested/staged/real-hook npm
and hook behaviors are requirements but do not have one physical ID per
platform/runtime result. The capture-helper negative/response/header cases
also lack a closed physical allocation.

That conflicts with the issue's own one-ID/one-result rule. A later implementer
still decides identifiers, applicability, fixtures, and exact result
cardinality. T3 now physically allocates its Node, npm, hook, installer,
capture, and audit sets.

**Recommendation:** before filing, list every immutable record for:

- manager clean-install/no-op/lint operations on each exact OS/Node cell;
- full, nested, staged-only, and real installed-hook outcomes on each
  applicable OS/Node cell;
- all 18 installer decisions as complete IDs with singular fixtures/oracles;
  and
- live capture/retry/header/state-drift behavior.

Each record needs literal platform/runtime applicability, fixture, expected
identity/native outcome, side effects, diagnostic, and result. Freeze family
counts and reject missing, duplicate, unknown, regrouped, skipped, orphaned,
unused, or multiply emitted IDs.

## W-01 — The P3 npm operation authority has no literal frozen digest

**Validity:** confirmed.

P3 provides complete `PS-P3-NPM-OPERATIONS-v1` vectors and says consumers use
the frozen row “or its canonical SHA-256,” but it does not define the exact
canonical preimage or give the expected digest. Different whitespace, row
labels, environment tables, or vector serialization could therefore produce
different “canonical” hashes while each consumer claims compliance.

**Recommendation:** define one exact BOM-less UTF-8/LF preimage, including its
final-newline rule, and put its literal SHA-256 in the issue. Bind the wrapper,
hook, workflow-policy validator, audit result, harness, and evidence to that
same identifier/digest. Add mutations for whitespace, order, missing/extra
argument, environment/config/network/cache, timeout, exit, and side-effect
disposition.

## W-02 — P3's live GitHub retry policy does not close reset-header behavior

**Validity:** confirmed.

P3 permits three attempts, names retryable statuses, and constrains
`Retry-After`, but when that header is absent it always uses one- and
two-second fallback delays. It does not define canonical
`x-ratelimit-reset`/`x-ratelimit-remaining` parsing, required waits above the
30-second cap, duplicate/date/malformed headers, or the exact attempt budget
across `/user` and `/issues/{number}`.

This can immediately retry a primary-rate-limit response before reset or let
different clients interpret the same headers differently.

**Recommendation:** freeze:

- exact request and per-logical-GET/whole-operation attempt ceilings;
- precedence between canonical integer `Retry-After`, canonical reset epoch,
  and fixed fallback;
- one captured system instant and ceiling-delay calculation;
- a hard 30-second maximum with fail-closed over-cap behavior;
- duplicate, signed, padded, date-form, malformed, past, and missing headers;
  and
- the rule that cached/offline state never substitutes for a required live
  read.

Physically allocate response/header/retry/exhaustion/drift cases and record only
safe endpoint/attempt/status/delay-source evidence.

## W-03 — P1B does not explicitly revalidate P1's package/audit freeze

**Validity:** confirmed.

P1 has a sound implementation/pre-merge supply tuple, and P1B forbids package
or lock changes. P1B's dependency table consumes only a general
“current advisory decision and pinned manifest/default evidence.” It does not
explicitly require the exact protected P1 manifest/lock blob identities,
Node/npm producer, installed tree, normalized audit result, and policy decision
to remain equal at P1B start and immediately before P1B merge.

An upstream Dependabot/registry/advisory change between issues could therefore
leave P1B using stale assumptions without a precise stop/rebaseline trigger.

**Recommendation:** name and consume one immutable P1 supply-freeze record.
At P1B start and pre-merge, require exact manifest/lock blob IDs and SHA-256,
Node/npm pair, install producer argv, installed-tree identity, normalized audit
state, and policy decision equality. Drift stops P1B and rebaselines affected
successors; P1B never refreshes the lock or imports P3 work.

## Intentional differences that are not findings

- P2's blank-line example change and T2/T4's state-recovery work are
  repository-specific product work, not a symmetry requirement.
- P1A's 110 cases and T1A's larger allocation need semantic reciprocal mapping,
  not equal local counts.
- PSStyleGuide's staged-content hook and TerraformStyleGuide's full-lint hook
  are deliberate repository contracts.
- PowerShell-specific cleanup states and Terraform-specific state-file
  ownership need equal safety properties, not identical runtime types.

## Convergence judgment

The slate is not yet at a no-finding fixed point. C-01 through C-03 affect
copyable implementation determinism or evidence cardinality and should close
before filing. W-01 through W-03 are bounded contract hardening that should be
resolved in the same revision because downstream structural validators depend
on exact literals.

No issue draft needs to be added, deleted, renamed, or reordered.
