# Current PSStyleGuide issue-slate findings

## Review basis

This is a live review of the five PSStyleGuide issue bodies named by
`docs/planning/PSStyleGuide/prompt-01b-in-repo-with-criticism.md`, in their
required sequence:

1. P1;
2. P1A;
3. P1B;
4. P2; and
5. P3.

The review uses:

- PSStyleGuide planning commit
  `92f23345140c740e18fd22600846d9b2cf49cb06`;
- the current repository implementation and planning files;
- `docs/planning/PSStyleGuide/slate-criticism.md`;
- the current TerraformStyleGuide issue bodies only as cross-repository
  alignment context, not as a second critique target; and
- current primary sources where a recommendation depends on external behavior.

Each criticism recommendation receives one of these verdicts:

- **Valid, addressed** — the concern was correct for the earlier draft and the
  current issue text now resolves it;
- **Valid, partially addressed** — the concern remains in a narrower or changed
  form;
- **Valid, open** — the current slate still contains the defect;
- **Not valid** — current evidence contradicts the recommendation; or
- **Superseded** — another current contract resolves or replaces the premise.

Independent findings are recorded after the recommendation that exposed them
or in the cross-issue audit. “Addressed” describes the current planning text;
it does not claim that implementation work has already occurred.

## Criticism recommendation inventory

### Slate and P1

- `C-SLATE-01` — choose/authorize the npm-advisory execution order:
  **Valid, open**.
- `C-P1-01` — correct the failure-upload path: **Valid, open**.
- `C-P1-02` — make the checkout credential statement true:
  **Valid, partially addressed**.
- `C-P1-03` — define temporary structural workflow validation:
  **Valid, open**.
- `C-P1-04` — add the advisory-order decision used by T1:
  **Valid, open**.
- `C-P1-05` — move successor-only facts out of P1 acceptance:
  **Valid, open**.
- `C-P1-06` — distinguish explicit action inputs from reviewed defaults:
  **Valid, open**.

### P1A

- `C-P1A-01` — replace grouped ID ranges with one row per stable ID:
  **Valid, open**.
- `C-P1A-02` — give each ID an exact phase/state oracle:
  **Valid, open**.
- `C-P1A-03` — define the context schema and disposed-state contract:
  **Valid, partially addressed**.
- `C-P1A-04` — distinguish a primitive skip from a missing case:
  **Valid, partially addressed**.

### P1B

- `C-P1B-01` — put Markdown validation in the same job graph:
  **Valid, open**.
- `C-P1B-02` — export four path-bound preparation hashes:
  **Valid, open**.
- `C-P1B-03` — add permanent structural workflow-policy enforcement:
  **Valid, open**.
- `C-P1B-04` — correct the checkout/push credential boundary:
  **Valid, partially addressed**.
- `C-P1B-05` — specify the temporary-branch proof mechanism:
  **Valid, open**.
- `C-P1B-06` — retain and mechanically validate unique matrix outputs:
  **Valid, partially addressed**.

### P2

- `C-P2-01` — update stale P1B pull-request expectations:
  **Valid, open**.
- `C-P2-02` — use a NUL-delimited Git path-set check:
  **Valid, open**.
- `C-P2-03` — classify `git diff --exit-code` correctly:
  **Valid, open**.
- `C-P2-04` — machine-check the unchanged Compliant example:
  **Valid, open**.
- `C-P2-05` — consume, rather than inconsistently restate, P1B:
  **Valid, open**.

### P3

- `C-P3-01` — add continuous read-only audit execution:
  **Valid, open**.
- `C-P3-02` — define an exact exception lifetime:
  **Valid, open**.
- `C-P3-03` — add deterministic audit-policy oracles:
  **Valid, open**.
- `C-P3-04` — separate the pure audit validator from orchestration:
  **Valid, open**.
- `C-P3-05` — use one tracked Node-policy decision:
  **Valid, open**.
- `C-P3-06` — consume the corrected P1B workflow validator/parser:
  **Valid, open**.
- `C-P3-07` — reconcile package-update order with current advisories:
  **Valid, open**.

### Cross-slate consistency

- `C-CROSS-01` — add real issue URLs and blocked-by relationships when filed:
  **Valid, partially addressed**.
- `C-CROSS-02` — keep predecessor commits in successors, not successor work in
  predecessor acceptance: **Valid, open**.
- `C-CROSS-03` — give counterpart stable IDs one meaning:
  **Valid, open**.
- `C-CROSS-04` — use one external event owner after P1B:
  **Valid, open**.
- `C-CROSS-05` — retain one tracked workflow-policy validator after P1B:
  **Valid, open**.
- `C-CROSS-06` — distinguish explicit action keys from reviewed defaults:
  **Valid, open**.
- `C-CROSS-07` — re-resolve external action tags before implementation/merge:
  **Valid, partially addressed**.
- `C-CROSS-08` — use NUL-safe affected-file equality gates:
  **Valid, open**.
- `C-CROSS-09` — preserve the five intentional H1 issue titles:
  **Valid, addressed**.

## P1 review

### `C-SLATE-01` and `C-P1-04` — Valid, open

The prompt fixes the execution order as P1→P1A→P1B→P2→P3, so the issue slate
should not preserve an alternate T3-first graph. It still needs one dated,
accountable record that the current high-severity npm findings may remain
through P2. P1 currently states the sequence without naming the audit command
and npm version, owner, evidence date, accepted waiting period, or risk
decision.

Under the required sequence, add that record as a P1 start gate and make P3
consume it. If the repository's governing policy cannot authorize the wait,
the slate itself must be regenerated rather than leaving implementers to make
an undocumented exception.

### `C-P1-01` — Valid, open

P1's upload role still says its `path` is “the exact newline-separated
four-file list in **Affected files**.” The Affected files are the generator,
two workflow files, and Dependabot configuration. That conflicts with the
role's generated-artifact verification purpose.

Name the intended paths directly:

1. `copilot-instructions.md`;
2. `powershell.instructions.md`;
3. `STYLE_GUIDE_CHAT.md`; and
4. `STYLE_GUIDE_FULL.md`.

If the failure evidence is instead meant to be purpose-built logs, define their
producer, contents, redaction, size bounds, and exact paths. “Affected files”
cannot mean both implementation scope and generated evidence.

### `C-P1-02` — Valid, partially addressed

P1 now correctly states that GitHub creates a write-capable token for the
complete temporary writer job. It still says not to materialize that token into
Git configuration while its pinned checkout role omits `token` and therefore
uses checkout's default `github.token`. The pinned action configures
authentication for fetch and removes it afterward when
`persist-credentials: false`.

Choose one accurate contract:

- permit the pinned checkout action's reviewed transient authentication,
  require its cleanup, prove no credential state remains before repository
  scripts, and reserve explicit process-scoped HTTP authorization for push; or
- define and test a credential-free public-repository acquisition path.

`persist-credentials: false` proves absence after checkout cleanup, not absence
during checkout.

### `C-P1-03` — Valid, open

P1 requires structural YAML parsing, exact role/input equality, and negative
fixtures, but:

- its affected-file set contains no validator;
- package and lockfile content are frozen; and
- no temporary parser, exact parser version, command, or evidence-retention
  mechanism is named.

If this is temporary review tooling, name the parser/version and exact command,
retain fixtures/results in pull-request evidence, and state that P1B replaces
it with the permanent tracked validator. If it is permanent repository code,
add its path and locked dependency to P1's scope.

### `C-P1-05` — Valid, open

“P1A records P1's exact merge commit” remains in P1 acceptance. P1 cannot prove
a future successor action at its own merge. Keep the successor handoff in P1's
execution-order text and make it a P1A dependency/acceptance gate, not a P1
closure criterion.

Apply the same rule to P1A→P1B and P1B→P2 handoffs during later review.

### `C-P1-06` — Valid, open

The role table calls its values “Complete inputs,” prohibits every unlisted
input, and says not to rely on an action default. The YAML necessarily has both
explicit keys and action-resolved defaults. Checkout's default `token`,
`clean`, and `fetch-depth` behavior demonstrates why these are different
sets.

Define:

- the exact explicitly declared YAML input-key/value set; and
- the separately reviewed effective defaults from each pinned manifest.

Reject an unlisted explicit YAML key, and fail/review when a security-relevant
default changes at the pinned action revision.

### Independent P1 concern: temporary-branch proof is under-specified

P1 validation requires controlled temporary-branch push evidence, while the
production temporary writer is eligible only for pushes to `main`. P1 does not
say how the proof changes the target without weakening or hand-editing the
production predicate.

Define a uniquely named temporary evidence workflow/branch or another exact
mechanism, and require its removal plus absence from the final four-path set.

## P1A review

### `C-P1A-01` — Valid, open

P1A still uses grouped ranges such as `M-01..14`, `E-01..10`, and
`R-01..08`. A grouped prose list does not bind an individual ID to one fixture,
phase, result, cleanup owner, and pre-teardown state. It therefore cannot prove
the later acceptance criterion that every mandatory ID has one oracle.

Replace the grouped table with one row per ID and align the semantic IDs with
current T1A unless a reciprocal-matrix row records a real repository-specific
difference. At minimum, add the currently absent or collapsed cases identified
by the criticism:

- invalid digest grammar (`D-03..05`);
- wildcard/multiple/missing/wrong-type paths (`E-12..15`);
- download cardinality/type/unreadability (`W-01..05`);
- complete helper and context-manager identities (`S-01..11`);
- caller cleanup lifecycle (`C-01..08`);
- below/exact/above archive limits and corrupt length metadata (`R-09..13`);
- valid and non-scalar labels (`X-07..10`); and
- machine-readable missing/duplicate/unexpected/multiply emitted ID checks.

Current P1A and T1A also assign different behavior to `K-03`. A stable
cross-repository ID cannot have two meanings without an explicit intentional
difference.

### `C-P1A-02` — Valid, open

Rows like “Windows/Linux case behavior” and “negative/overflow/inconsistent
length ceilings” still do not state individual oracles. Every row needs:

- exact fixture/invocation;
- applicability by OS/edition;
- expected success or exact failure phase;
- candidate and caller-context state before harness teardown;
- cleanup owner/result;
- required diagnostic fields; and
- unchanged outside-sentinel result.

Resource rows must state byte values and whether a boundary is below, exactly
at, or above an inclusive limit. A nonzero process result alone is never a
sufficient oracle.

### `C-P1A-03` — Valid, partially addressed

P1A now names the high-level context fields, which addresses part of the
recommendation. It still does not define:

- scalar versus ordered-collection types;
- exact field names/grammar;
- ownership-journal entry schema;
- context state transitions; or
- whether/how a second removal is an authorized no-op.

This matters because current T1A requires repeated candidate and caller cleanup
to succeed only after prior safe disposal, while missing journaled state is
otherwise an uncertainty. Define an invocation-bound active/disposed state
that changes only after complete cleanup, or explicitly reject repeat cleanup
and make the reciprocal difference intentional. Do not treat an arbitrary
missing path as proof of earlier successful disposal.

### `C-P1A-04` — Valid, partially addressed

P1A now requires a skipped link primitive to name the case, platform, and
reason, says a skip is not a pass, records skip totals, and requires at least
one real link rejection per OS family. Those are material improvements.

It still says each “applicable” ID reports once without defining the expected
applicability matrix. A missing executable case could be reclassified as
inapplicable. Require:

- one record for every normative ID on every expected runtime;
- explicit `pass`, `fail`, or `skip` status;
- an exact closed list of skippable primitive-dependent rows;
- failure when a required executable row is absent or skipped; and
- separate pass/fail/skip totals that equal the expected inventory.

### Independent P1A concern: successor work remains in acceptance

“P1B records P1A's exact merge commit” is still a P1A acceptance item. Keep it
as a successor handoff and make P1B prove it. P1A can prove only its reviewed
head, own merge prerequisites, and the exact evidence handed to P1B.

## P1B review

### `C-P1B-01` — Valid, open

P1B requires terminal approval to depend on “Markdown/Ubuntu validation,” but
keeps that validation in `.github/workflows/markdownlint.yml` without defining
one external event owner and a local `workflow_call`. A job's `needs` set can
name jobs in its own workflow graph, not a job in a separately triggered
workflow run. Make `build.yml` the event owner, make `markdownlint.yml` locally
callable, and put the call job in approval's exact dependency set.

### `C-P1B-02` — Valid, open

Preparation computes four file SHA-256 values in requested-change step 2.10,
but step 2.12 exports only artifact ID, upload digest, unique name,
`has_changes`, event SHA, and full ref. Matrix records likewise omit the four
hashes. The writer therefore cannot perform step 7.7's promised comparison to
“preparation hashes.” Export four statically named, path-bound hashes, bind
them into every cell attestation and approval comparison, and pass the approved
values to the writer.

### `C-P1B-03` — Valid, open

P1B requires structural parsing and exact policy equality, yet freezes the
implementation to the two workflow files and later requires that only those
two files change. No parser, tracked validator, dependency manifest, lockfile,
or negative fixtures are in scope. Expand the implementation to a permanent,
offline validator and locked reviewed YAML parser, then require P3 to retain
and rerun them while changing the workflow package graph.

### `C-P1B-04` — Valid, partially addressed

The issue now correctly says the write-capable token exists for the complete
writer job and requires `persist-credentials: false`. It still claims workflow
code does not materialize the token until the push, overlooking the pinned
checkout action's transient authentication during fetch. State the honest
boundary: checkout may transiently use the token, removes its stored
credential state, repository scripts receive no ordinary token variable, and
only the exact push child process receives the masked token-derived header.

### `C-P1B-05` — Valid, open

Validation demands a controlled temporary-branch writer run while the
production predicate authorizes writes only for changed pushes to `main`.
P1B does not say how both can be true without hand-editing the production
workflow. Specify a reproducible evidence mechanism, such as a uniquely named
temporary evidence workflow whose exact path is verified and whose removal is
proved before the final production commit.

### `C-P1B-06` — Valid, partially addressed

The four static output names and stable cell keys avoid last-finisher
overwrites, and approval requires four-key equality. The permanent structural
proof is absent: no validator can prove that each canonical matrix cell writes
only its corresponding output key. Approval also needs to reject empty keys
and duplicate embedded cell IDs while comparing the four path hashes omitted
by `C-P1B-02`.

### Independent P1B concern: successor work remains in acceptance

“P2 records P1B's exact merge commit” is still a P1B acceptance item. Keep it
as a successor handoff and make P2 prove it. P1B can prove only its reviewed
head, own merge prerequisites, and the exact evidence handed to P2.

## P2 review

### `C-P2-01` — Valid, open

The pull-request evidence still describes the pre-P1B graph: it says only the
LF Windows cells run the helper suite, the CRLF cells do not repeat it, and
preparation and approval skip. P1B instead requires preparation and read-only
approval on pull requests and requires all four Windows cells to execute every
applicable P1A ID plus the production helper/context/harness. Only the writer
should skip. Rewrite this section against P1B's final merged interface.

### `C-P2-02` — Valid, open

The working-tree gate parses line-delimited `git status --porcelain=v1` with
`^..\s+`. That does not safely decode quoted paths or rename/copy records and
therefore cannot prove exact path-set equality. Compute the union of modified,
cached, and untracked paths through NUL-delimited Git output and compare
decoded paths ordinally with the six allowed paths. Use NUL-delimited output
for the later staged-path equality check too.

### `C-P2-03` — Valid, open

The idempotency block maps every nonzero `git diff --exit-code` result to “the
generator changed” even though exit 1 means an ordinary difference and values
above 1 mean command failure. Branch explicitly on 0, 1, and greater-than-1 so
the evidence preserves whether generation drifted or Git itself failed.

### `C-P2-04` — Valid, open

“The Compliant example is unchanged” is still an inspection item. Record its
exact baseline bytes, blob-local boundaries, or an ordinal baseline hash before
editing and verify the same region after editing and regeneration. This is
needed because the otherwise strong canonical-snippet validator covers only
the new Non-Compliant block.

### `C-P2-05` — Valid, open

P2 correctly says P1/P1A/P1B remain the source of truth, but then restates
their matrix, held-stream, cleanup, attestation, writer, credential, and
post-merge algorithms throughout validation and acceptance. Some of those
restatements already contradict P1B, as `C-P2-01` shows. Keep P2's permanent
contract focused on the six files, metadata, exact regeneration, and no-drift
publication; cite the exact merged P1B commit and retained run evidence for
the inherited CI contract.

### Independent P2 concern: all pathname proofs need one encoding

Fixing only the pre-stage status parser would leave the cached
`git diff --cached --name-only` gate line-delimited. The issue should define
one NUL-safe pathname decoder and reuse it for every working-tree, untracked,
cached, and staged path-set proof.

## P3 review

### `C-P3-01` — Valid, open

P3 excludes `build.yml`, leaves the inherited event graph unchanged, and
requires only pull-request cells plus a post-merge push. That cannot
continuously enforce expiring exceptions. Add `build.yml` to the computed
scope and make the sole event owner support ordinary and Dependabot pull
requests, main pushes, enabled merge queue, one read-only UTC schedule, and
optional read-only manual execution. Schedule/manual dispatch must call only
the local dependency/Markdown validation and a read-only terminal result; it
must not enter candidate preparation, artifact transport, Windows candidate
validation, promotion approval, or the writer.

### `C-P3-02` — Valid, open

“Future and within repository maximum” names no maximum. Define timestamps as
UTC values ending in `Z`, inject the validation instant for fixtures, require
`expiresAt` to be later than that instant and no more than exactly 30×24 hours
after it, and use exclusive expiry (`now >= expiresAt` fails). Test exact
before, at, and after-expiry boundaries.

### `C-P3-03` — Valid, open

The production parser requirements are detailed, but P3 has no stable
`AUDIT-*` fixture inventory binding inputs to exact outcomes. Add individual
oracles for clean/stale/residual/approved states; missing, extra, duplicate,
and topology-changed approvals; schema/type/metadata/graph failures; both
allowed `fixAvailable` shapes; report-version and native-exit disagreement;
timestamp/30-day boundaries; immutable fixtures; and distinct vulnerability,
policy, schema, registry/tool, and native-exit diagnostics.

### `C-P3-04` — Valid, open

`Test-NpmAuditPolicy.ps1` is asked both to invoke the live npm/registry path and
to validate pure schema, graph, topology, and expiry rules. That makes
deterministic negative fixtures unnecessarily dependent on orchestration.
Add a dependency-free `Validate-NpmAudit.mjs` pure core plus CLI that accepts
parsed audit data, optional exceptions, and an injected UTC instant; keep the
PowerShell harness responsible for exact-npm and cross-platform integration.

### `C-P3-05` — Valid, open

The issue permits the shell hook and `lint-staged-markdown.mjs` to contain
separate policy implementations so long as common fixtures compare them.
That tests drift but does not eliminate it. Add one dependency-free
`Check-NodePolicy.mjs` pure decision plus CLI, import it from the staged
implementation, and invoke it from the hook before npm or `node_modules`
checks. Give each admitted, rejected, malformed, whitespace, and
extra-component version form its own stable oracle instead of collapsing all
runtime failures into `HOOK-08`.

### `C-P3-06` — Valid, open

P3 neither includes nor consumes P1B's promised structural validator/parser;
indeed, current P1B has not yet put them in scope. After correcting P1B, P3
must include the existing validator and reviewed locked YAML parser in its
computed path/dependency scope, then rerun positive and negative workflow
fixtures—including the schedule/manual no-publication subgraph—after package
changes.

### `C-P3-07` — Valid, open

P3 fixes the P1→P1A→P1B→P2→P3 order and says not to maintain an alternate
graph, but it does not condition that wait on P1's accountable advisory-risk
decision. Require the dated P1 authorization as a prerequisite. If governing
policy refuses the wait, specify that the slate must be rebaselined and
regenerated rather than allowing an implementer to improvise partial package
changes.

### Independent P3 concern: exact-path validation remains unspecified

P3 requires final changed/staged equality to a computed path set but does not
name a NUL-safe mechanism. Reuse the corrected P2 pathname decoder rather than
reintroducing line-delimited `git status` or `git diff --name-only` parsing.

## Cross-slate review

### `C-CROSS-01` — Valid, partially addressed

P1A, P1B, P2, and P3 now instruct the filer to record predecessor issue URLs,
blocked-by relationships, and merge commits. That is the correct handoff, but
the real URLs and GitHub relationships do not yet exist in these draft bodies.
Treat their insertion and verification as a filing transaction, not an
implementation-time TODO.

### `C-CROSS-02` — Valid, open

Successors generally consume predecessor commits in their dependency text, but
P1, P1A, and P1B still require the next issue to record the current merge
commit in the current issue's acceptance checklist. Remove those three
future-successor criteria and retain the corresponding gates in P1A, P1B, and
P2 respectively.

### `C-CROSS-03` — Valid, open

P1A's grouped table omits counterpart IDs and assigns `K-03` a different
meaning from current T1A. Converge on T1A's one-row semantic inventory for
shared helper/context/archive behavior. Add a new repository-specific ID only
when PSStyleGuide behavior truly has no Terraform counterpart, and record that
as an intentional reciprocal-matrix difference.

### `C-CROSS-04` — Valid, open

P1B does not make `build.yml` the sole external event owner or expose
`markdownlint.yml` solely through a local `workflow_call`. Consequently, its
terminal approval cannot have the exact Markdown call job in the same `needs`
graph. P3's schedule/manual extension depends on correcting this topology
first.

### `C-CROSS-05` — Valid, open

P1B's exact two-file scope cannot add the promised tracked workflow-policy
validator or locked parser, and P3 neither includes nor consumes them. Add the
validator in P1B and make P3 update and rerun it, including all positive and
negative graph fixtures.

### `C-CROSS-06` — Valid, open

P1 and P1B still label their action tables “Complete inputs,” prohibit
unlisted defaults, and demand equality with all inputs. P3 inherits the same
phrasing for its final role policy. Across the slate, separate exact explicit
YAML keys/values from reviewed effective defaults in the pinned action
manifest.

### `C-CROSS-07` — Valid, partially addressed

P1 and P1B require official action tags to be re-resolved immediately before
implementation. Neither requires the second re-resolution immediately before
merge, and P3's final role update merely says to retain the old SHAs. Require
both checkpoints, with any changed tag target forcing renewed provenance and
manifest review rather than silent substitution.

### `C-CROSS-08` — Valid, open

Every issue wants an exact affected/changed/staged path gate, which addresses
the policy intent. No common NUL-safe implementation is defined; P2 includes a
known-unsafe porcelain parser, and P3 leaves the method unspecified. Define one
tested pathname decoder and reuse it across the five issues.

### `C-CROSS-09` — Valid, addressed

A mechanical first-line check confirms all five files preserve exactly one
intended H1 title:

1. `Make artifact generation byte-deterministic across PowerShell editions and hosts`;
2. `Add a fail-closed cross-platform style-guide candidate validator`;
3. `Promote generated style-guide artifacts through a least-privileged verified writer`;
4. `Make the non-compliant blank-line example visibly distinct`; and
5. `Remediate Markdown lint dependency advisories and add npm update governance`.

## TerraformStyleGuide convergence

The useful unification boundary is semantic, not a shared runtime package.
Against TerraformStyleGuide commit
`4523b280fdff5034d31fa70f97bdc35dc05af129`, PSStyleGuide should adopt the
same reviewed layers while preserving repository-specific content:

| Layer | Converge | Preserve as intentional difference |
| --- | --- | --- |
| Generator | One resolved destination/provider boundary, complete-payload newline normalization, BOM-less LF encoding, cross-host byte identity, native-exit discipline, and temporary writer controls | Source composition, metadata placement, and generated filenames |
| Candidate validator | Same-stream digest/archive identity, exact path/component defenses, resource ceilings, context state and cleanup ownership, one-row stable-ID oracles | The exact four-file manifest and any genuinely PS-only fixture |
| Verified writer | One event owner/local callable workflow, permanent locked-parser validator, artifact ID/upload digest/four hashes, four unique outputs, terminal approval, at-use regeneration, captured ref/SHA, exact lease/refspec, and honest token boundary | Repository-local job, artifact, and generated-path names |
| Dependency governance | Finite shared Node decision, one exact npm, pure audit validator with injected time, at-most-30-day exceptions, scheduled/manual read-only validation, and two review-only Dependabot entries | PSStyleGuide's staged-index API versus TerraformStyleGuide's full-repository hook |

Current Terraform T1A already provides the clearest base oracle catalog;
porting its shared rows and then changing only manifest-specific values is
safer than independently repairing P1A's grouped ranges. Current Terraform T1B
also demonstrates the missing five-file workflow-policy scope, same-commit
local call, and four preparation hashes. Current Terraform T3 demonstrates the
pure Node/audit policy split and continuous event subgraph. These are planning
patterns to converge, not evidence that either repository's implementation is
already complete.

## Primary-source verification

The recommendations above were rechecked against current primary behavior:

- GitHub requires `on.workflow_call` for a reusable workflow and
  `./.github/workflows/{filename}` selects the same commit as the caller:
  [Reuse workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows).
- GitHub warns that matrix jobs have no guaranteed run order and a reused
  output name is overwritten by the last matrix job:
  [Workflow syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#jobsjob_idoutputs).
- The exact pinned checkout manifest defaults `token` to `github.token`,
  describes Git configuration for fetch, and separately defines
  `persist-credentials`:
  [checkout action metadata](https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml).
- Scheduled workflows run from the latest default-branch commit:
  [Events that trigger workflows](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule).
- Git documents that porcelain `-z` emits unquoted NUL-terminated paths and
  that `git diff --exit-code` uses 0 for equality and 1 for differences:
  [git status](https://git-scm.com/docs/git-status#_pathname_format_notes_and_z)
  and [git diff](https://git-scm.com/docs/git-diff#Documentation/git-diff.txt---exit-code).

## Independent findings and filing assessment

The slate is not filing-ready. The minimum coherent repair sequence is:

1. authorize the advisory waiting period or regenerate the issue order;
2. make P1's credential, action-input, upload-path, and structural-validation
   contracts executable;
3. replace P1A's grouped catalog with exact one-row oracles and a closed
   applicability/state model;
4. port the current Terraform T1B graph/hash/validator layer into P1B;
5. simplify P2 to consume that merged interface and make its Git/content
   proofs machine-safe; and
6. port the current Terraform T3 continuous/pure-policy layer into P3.

No criticism recommendation was denied or superseded. Of the 38 distinct
recommendations audited, one is fully addressed (`C-CROSS-09`), seven are
partially addressed, and 30 remain open.
