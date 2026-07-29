# Feedback on the revised PSStyleGuide issue slate

## Overall assessment

The P1/P1A/P1B split is a substantial improvement. It gives deterministic
generation, candidate validation, and publication separate merge boundaries,
and it makes the intended reciprocal relationship with TerraformStyleGuide much
easier to review. Keep that split.

The slate should not be filed unchanged, however. P1B currently has two
unimplementable data-flow requirements and one unimplementable job dependency;
P1 and P1B state a checkout credential invariant that the selected action does
not satisfy; P1A's grouped test ranges do not define the promised stable
oracles; P2 contains stale P1B expectations; and P3 cannot continuously enforce
expiring audit exceptions because it adds neither a scheduled event nor a
defined maximum lifetime.

The most important revisions are:

| Priority | Owner | Revision required before filing |
| --- | --- | --- |
| Blocker | P1B | Make `build.yml` the event owner and call `markdownlint.yml` through `workflow_call`; an approval job cannot use `needs` to depend on a job in a separate workflow run. |
| Blocker | P1B | Export four path-bound preparation hashes. The writer is required to compare against them, but P1B currently exports no such values. |
| Blocker | P1B | Add a tracked, locked-parser workflow-policy validator and its package/lock scope, or name another concrete structural enforcement mechanism. |
| Blocker | P1 and P1B | Correct the token boundary. `persist-credentials: false` removes checkout authentication after fetch; it does not mean the default `github.token` was never materialized for checkout. |
| Blocker | P3 | Add read-only schedule/manual audit execution, an exact exception lifetime, and deterministic audit-policy fixtures. |
| Required | P1A | Replace grouped case ranges with a one-row-per-ID oracle aligned with T1A. |
| Required | P1 | Correct the failure-upload path: “the four-file list in Affected files” names implementation files, not generated artifacts. |
| Required | P2 | Reconcile pull-request and matrix expectations with P1B and harden the Git path-set checks. |
| Required | Slate | Record a dated owner decision that permits current high-severity npm findings to remain until P3, or rebaseline the slate if policy does not permit that wait. |

After those changes, the issue boundaries are sound and the slate is suitable
for sequential implementation.

## Review baseline

This review uses PSStyleGuide `main` commit
[`4346310e7deebffb4159c75e30d9546263dfd649`](https://github.com/franklesniak/PSStyleGuide/commit/4346310e7deebffb4159c75e30d9546263dfd649),
dated 2026-07-26.

That baseline confirms the problem statement:

- [`build.yml`](https://github.com/franklesniak/PSStyleGuide/blob/4346310e7deebffb4159c75e30d9546263dfd649/.github/workflows/build.yml)
  is path-filtered, grants workflow-wide `contents: write`, gives checkout the
  repository token, directly commits and pushes, and uses mutable action tags.
- [`markdownlint.yml`](https://github.com/franklesniak/PSStyleGuide/blob/4346310e7deebffb4159c75e30d9546263dfd649/.github/workflows/markdownlint.yml)
  is an independently triggered Node 20 workflow, so it is not currently a job
  in the build run's dependency graph.
- [`Generate-StyleGuideArtifacts.ps1`](https://github.com/franklesniak/PSStyleGuide/blob/4346310e7deebffb4159c75e30d9546263dfd649/.github/workflows/Generate-StyleGuideArtifacts.ps1)
  uses host-sensitive final writes and a source-newline-sensitive here-string.
- [`package.json`](https://github.com/franklesniak/PSStyleGuide/blob/4346310e7deebffb4159c75e30d9546263dfd649/.github/workflows/package.json)
  has no finite Node/npm contract, while the
  [hook](https://github.com/franklesniak/PSStyleGuide/blob/4346310e7deebffb4159c75e30d9546263dfd649/.husky/pre-commit)
  and
  [staged-content implementation](https://github.com/franklesniak/PSStyleGuide/blob/4346310e7deebffb4159c75e30d9546263dfd649/.github/workflows/lint-staged-markdown.mjs)
  independently accept every Node major at or above 20.
- `.github/dependabot.yml` is absent at the baseline commit.

The P3 audit observation is appropriately labeled as dated evidence rather
than acceptance. Its separation of vulnerability-property count, object
advisory count, and installed-node-path count is especially useful and should
be preserved.

## P1 — Make artifact generation byte-deterministic across PowerShell editions and hosts

### What is strong

P1 has the right implementation boundary. One private final-write helper, one
complete-payload normalization point, explicit BOM-less UTF-8, and no implicit
final newline are a coherent generator contract. The explicit frontmatter line
array is also the right fix for a here-string whose bytes otherwise depend on
the source checkout.

The three-cell generator matrix is proportionate to the repository's stated
support: Windows PowerShell 5.1 on Windows, PowerShell 7 on Windows, and
PowerShell 7 on Ubuntu. The requirement to retain all four hashes per cell,
prove a second-run fixed point, and keep committed generated artifacts
unchanged makes P1 a genuine foundation rather than a cosmetic encoding edit.

The temporary/final publication distinction is clear. P1 correctly excludes
the candidate helper, context lifecycle, permanent harness, immutable download,
matrix approval, and final writer.

### Required revisions

1. **Correct the failure-upload path.** The normative role row says the upload
   has four explicit paths. The following paragraph says those paths are “the
   exact newline-separated four-file list in Affected files.” P1's Affected
   files are the generator, two workflows, and Dependabot file. Uploading those
   is not the stated generated-artifact evidence.

   Name the intended paths directly. If the purpose is to retain generated
   verification output, use, in order:

   - `copilot-instructions.md`;
   - `powershell.instructions.md`;
   - `STYLE_GUIDE_CHAT.md`; and
   - `STYLE_GUIDE_FULL.md`.

   If the intended evidence is instead a purpose-built diagnostic bundle, name
   its producer and exact bounded paths. Do not use “Affected files” for either
   meaning.

2. **Make the checkout credential statement true.** The selected checkout
   action's exact metadata defaults `token` to `github.token`, and the exact
   implementation configures authentication before fetch and removes it after
   fetch when persistence is disabled. See the pinned
   [`action.yml`](https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml)
   and
   [`git-source-provider.ts`](https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/src/git-source-provider.ts).
   Therefore, `persist-credentials: false` proves that checkout credentials do
   not remain available to later ordinary steps; it does not prove that the
   token was never materialized into Git configuration.

   Choose and state one honest contract:

   - allow the reviewed checkout action to use the job token transiently,
     require its removal, prove no credential state remains before repository
     scripts, and reserve the explicit process-scoped header for the push; or
   - replace the writer checkout with a concretely specified, tested
     credential-free public-repository acquisition path.

   The first is simpler and still materially improves the live workflow. Apply
   the same wording to P1B and the reciprocal T1/T1B records.

3. **Define how temporary structural workflow validation is performed.** P1
   requires structural parsing, exact role/input equality, and negative YAML
   fixtures while freezing the package and lockfile and allowing no tracked
   validator. State whether this is temporary review tooling or repository
   code. If temporary, name the parser/tool and exact version, retain its
   command and fixtures in pull-request evidence, and say that P1B replaces it
   with the permanent tracked validator. If permanent, its path and dependency
   belong in Affected files.

4. **Add the advisory-order decision used by T1.** P3 documents current high
   findings, yet P1 states an unconditional P1→P1A→P1B→P2→P3 order. Before P1
   starts, require a dated record naming the audit command/npm version,
   findings, decision owner, evidence date, accepted waiting period, and chosen
   order. If repository policy permits the wait, the requested sequence remains
   intact. If it does not, the slate must be rebaselined rather than silently
   running several issues on a disallowed dependency state.

5. **Move successor-only facts out of P1 acceptance.** “P1A records P1's exact
   merge commit” cannot be satisfied when P1 merges because that successor work
   has not started. Retain it as a P1 handoff and P1A dependency criterion, not
   a P1 closure condition. Apply the same rule to the P1A→P1B and P1B→P2
   handoffs.

6. **Clarify what “complete inputs” means.** The role table lists required YAML
   `with:` keys, but each action also has reviewed defaults. Say “exact
   explicitly declared input-key set” and separately require review of
   security-relevant action defaults. “Every unlisted input is prohibited” is
   otherwise ambiguous between absent YAML keys and action-resolved defaults.

### P1↔T1 convergence

Use one semantic generator matrix in both repositories:

- final destination/provider validation;
- complete-payload normalization;
- BOM-less UTF-8 and final-newline behavior;
- repository-specific frontmatter;
- script metadata;
- exact Node/action foundations;
- native-command status handling;
- cross-edition hashes and idempotence; and
- the temporary publication boundary.

The different generated filenames and frontmatter values are intentional.
Token materialization, workflow-policy enforcement, native exit
classification, and serialization failures are not acceptable unexplained
differences. Both P1 and T1 should use the same corrected terminology for those
rows.

## P1A — Add a fail-closed cross-platform style-guide candidate validator

### What is strong

Making P1A workflow-inert is an excellent review boundary. The archive helper,
caller context manager, and permanent harness can be reviewed under both
PowerShell editions without simultaneously changing permissions or enabling a
writer.

The security model is substantially more precise than the live repository:
caller paths and labels are untrusted, checkout and temporary roots cannot
overlap, every existing component is classified, one held stream is hashed and
parsed, manifest and declared limits precede candidate creation, actual bytes
are counted independently, files use `CreateNew`, and uncertain state is
retained rather than recursively removed.

Explicit `HelperPath` and `ContextManagerPath` inputs are important. Keep the
prohibition on sibling derivation and ambient-session substitution.

### Required revisions

1. **Replace grouped ID ranges with the full stable oracle table.** Rows such
   as `M-01..14`, `E-01..10`, and `R-01..08` do not map individual IDs to
   fixtures, phases, and pre-teardown outcomes. That conflicts with the later
   requirement that every mandatory ID have exactly one oracle.

   Use T1A's one-row-per-ID form as the shared baseline. P1A is currently
   missing or collapsing at least:

   - invalid digest grammar (`D-03..05`);
   - wildcard, multiple-resolution, missing, and wrong-type paths
     (`E-12..15`);
   - download cardinality/type/unreadability cases (`W-01..05`);
   - the complete helper/context-manager identity cases (`S-01..11`);
   - normal, repeated, uncertain, partial, and combined caller-cleanup cases
     (`C-01..08`);
   - archive below/exact/above boundaries and corrupt length states
     (`R-09..13`);
   - valid labels and non-scalar labels (`X-07..10`); and
   - append-only ID metadata plus missing/duplicate/unexpected/multiply emitted
     result checks.

   P1A's `K-03` also has a different meaning from T1A's `K-03`. Stable IDs
   should mean the same behavior in the reciprocal layer unless the matrix
   records an intentional repository-specific reason.

2. **Give every ID an exact phase and state oracle.** A category label such as
   “Windows/Linux case behavior” is not enough to implement a fail-closed test.
   Each row should state success or the exact failure phase, candidate state,
   caller-context state, cleanup owner, and sentinel result. Boundary cases
   must say whether the limit is inclusive.

3. **Make the context schema and disposed-state contract concrete.** Name the
   returned fields and their scalar/ordered-collection types. Define whether a
   second removal is a successful no-op and how that disposed state is
   represented. Otherwise P1B can consume a context shape that the P1A harness
   did not actually standardize.

4. **Separate a skipped primitive from a missing case.** Retain the narrow
   platform skip rule, but require the harness summary to count pass, fail, and
   skip separately and to fail if a required executable case silently
   disappears. A skip still emits exactly one record for its stable ID.

### P1A↔T1A convergence

This layer should be nearly identical between repositories. The exact manifest
filenames are the primary intentional difference. Public parameters, omission
semantics, path security, same-stream archive identity, ceilings, cleanup
ownership, stable IDs, diagnostics, and platform behavior should converge.

Do not create a shared runtime package. Copying the reviewed contract and case
catalog into two self-contained implementations is preferable to adding a new
cross-repository availability or supply-chain dependency.

## P1B — Promote generated style-guide artifacts through a least-privileged verified writer

### What is strong

The intended topology is sound: one read-only preparation job, one immutable
artifact identity, Ubuntu coverage, a four-cell Windows edition/EOL
cross-product, unique attestations, a read-only terminal approval, and one
write-enabled job that revalidates at use. Exact remote preflight, one expected
parent, an explicit destination refspec, and a full expected-SHA lease are the
right stale-writer controls.

The issue also correctly rejects matrix filesystem trust, artifact-name trust,
automatic extraction, no-op commits, credential persistence, and concurrency
as a correctness mechanism.

### Blocking revisions

1. **Put Markdown validation in the same job graph.** P1B says approval depends
   on “Markdown/Ubuntu validation,” but it leaves `markdownlint.yml` as a
   separate workflow. `needs` identifies jobs in the current workflow run; it
   cannot directly depend on a job from an independently triggered run.

   Follow T1B's topology:

   - `build.yml` owns `pull_request`, `push`, and any enabled `merge_group`;
   - `markdownlint.yml` exposes `on.workflow_call` and removes its independent
     PR/push triggers;
   - `build.yml` calls it with
     `uses: ./.github/workflows/markdownlint.yml`; and
   - terminal approval names that call job in its exact `needs` set.

   GitHub documents both the required `workflow_call` declaration and the
   same-commit local call syntax in
   [Reuse workflows](https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows).

2. **Export the four preparation hashes.** Preparation step 10 records four
   file hashes, but step 12's output list contains only artifact ID, upload
   digest, name, `has_changes`, event SHA, and target ref. The writer later
   requires equality with “preparation hashes,” which are unavailable in a new
   job.

   Add four statically named, path-bound job outputs, include all four in every
   cell attestation, require equality in approval, and pass them to the writer.
   The names should be stable and unambiguous, for example:

   - `copilot_instructions_sha256`;
   - `powershell_instructions_sha256`;
   - `style_guide_chat_sha256`; and
   - `style_guide_full_sha256`.

3. **Add permanent structural policy enforcement.** P1B promises a structural
   parser, exact role/condition/input equality, and negative fixtures, but its
   two-file scope provides no parser or validator. Text matching is not an
   adequate substitute for YAML dependency, permission, condition, matrix, or
   input validation.

   Adopt the T1B pattern and expand Affected files to:

   - `.github/workflows/build.yml`;
   - `.github/workflows/markdownlint.yml`;
   - `.github/workflows/Validate-WorkflowPolicy.mjs` — add;
   - `.github/workflows/package.json`; and
   - `.github/workflows/package-lock.json`.

   Add one reviewed direct YAML parser, lock it, use a safe core schema, reject
   duplicate keys/custom tags/aliases, and make the validator deterministic
   and offline. It should verify exact events, local callable topology,
   dependencies, permissions, action roles and explicit input keys, Windows
   matrix/output mapping, and the sole writer. P3 must retain and rerun it while
   upgrading the package graph.

4. **Correct the checkout/push credential boundary.** Apply the P1 correction
   here too. With the current checkout action, “never materialized until the
   exact push” is false even with `persist-credentials: false`. A supportable
   contract is:

   - GitHub creates a write-capable token for the complete writer job;
   - the exact pinned checkout action may use it transiently for fetch;
   - checkout removes it, and validation proves no credential state remains;
   - repository scripts receive no ordinary token environment variable;
   - the push step receives a masked token and exposes its derived header only
     through child-process-scoped Git configuration; and
   - cleanup removes the header and all temporary Git configuration.

   If push-only materialization is a hard requirement, P1B must specify a
   credential-free acquisition mechanism instead of `actions/checkout`.

5. **Specify the temporary-branch proof mechanism.** The final writer is
   authorized only for changed pushes to `main`, yet validation requires a
   controlled temporary-branch write before enabling `main`. State exactly how
   that proof is run without weakening or hand-editing the production event
   predicate. A uniquely named temporary evidence workflow, removed before the
   final commit, is one acceptable pattern if its path and absence are checked.

6. **Retain unique matrix outputs, but test their exact mapping.** GitHub warns
   that a shared matrix output name is overwritten by whichever cell finishes
   last. The proposed four names are therefore correct. The policy validator
   should prove each canonical cell can set only its own key, and approval
   should reject every empty key and every duplicated embedded cell ID. See the
   [matrix-output warning](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#jobsjob_idoutputs).

### P1B↔T1B convergence

P1B should reuse T1B's semantic writer layer, including:

- one external event owner and one exact local callable workflow;
- a tracked locked-parser policy validator;
- preparation ID, upload digest, and four path-bound hashes;
- four unique cell outputs and fail-closed terminal approval;
- at-use helper execution and independent regeneration;
- one captured ref/SHA pair;
- exact preflight, parent, tree, lease, refspec, and post-push identity;
- the same honest checkout-versus-push credential distinction; and
- bounded failure-only diagnostics and measured CI cost.

Repository names and generated filenames may differ. Wider credentials, a
second event owner, absent hash propagation, or a weaker lease are blockers,
not intentional differences.

## P2 — Make the non-compliant blank-line example visibly distinct

### What is strong

The proposed content is ready in principle. A `text` fence with exactly four
U+00B7 MIDDLE DOT characters makes the defect visible without committing
trailing spaces. The warning appears before the block, explicitly says the dots
are substitutes, and keeps the example from becoming copy-paste PowerShell.

The source/rationale division is also correct. `STYLE_GUIDE.md` should contain
the concise operational rule and one canonical visualization;
`STYLE_GUIDE_RATIONALE.md` should explain why an invisible example is unstable
without duplicating the operational block. Regenerating and committing all four
derived artifacts with both source files is the correct normal path.

### Required revisions

1. **Update stale P1B pull-request expectations.** P2 says:

   - only the LF Windows cells run the helper suite;
   - the CRLF cells do not repeat it; and
   - “push-only preparation, approval, and synchronization jobs skip” on a pull
     request.

   P1B instead requires every Windows cell to run every applicable P1A ID,
   preparation to upload a candidate on pull requests and pushes, and read-only
   approval to complete on pull requests. Only the writer should skip on a pull
   request. Rewrite the Pull-request evidence section to consume P1B exactly.

2. **Use a NUL-delimited Git path-set check.** Parsing
   `git status --porcelain=v1` with `^..\s+` is not a complete Git pathname
   parser: quoted names and rename/copy records have different representations.
   Compute a union from NUL-delimited working-tree, cached, and untracked path
   commands, or use another exact NUL-safe implementation. Then compare the
   ordinal path set with the six affected files.

3. **Classify `git diff --exit-code` correctly.** P1's inherited native-command
   contract distinguishes 0 (equal), 1 (ordinary difference), and values above
   1 (command failure). The P2 rerun block currently treats every nonzero value
   as “the generator changed the staged expected result.” Preserve the actual
   failure class and status.

4. **Machine-check the unchanged Compliant example.** The acceptance criterion
   is currently confirmed only by inspection. Record the exact baseline
   Compliant snippet or its source-blob-local boundaries and compare it
   ordinally after editing. This complements the strong exact count for the new
   Non-Compliant snippet.

5. **Do not restate implementation details that P1B owns inconsistently.** P2
   should validate the exact merged P1B interface, not paraphrase held-stream,
   matrix, and writer behavior in a way that can drift. Retain the exact P1B
   merge commit and run URLs as evidence; keep P2's permanent contract focused
   on six-file content, metadata, regeneration, and no-drift publication.

With those changes, P2 is the closest issue in the slate to filing-ready.

## P3 — Remediate Markdown lint dependency advisories and add npm update governance

### What is strong

P3 correctly treats runtime, package, hook, audit, and Dependabot behavior as
one final policy. The finite Node union is much better than the live
`>=20`-equivalent checks, and the issue correctly refuses to infer contributor
support from an action's internal JavaScript runtime.

The audit model is also strong:

- exact `(Package, AdvisoryUrl)` is the approval identity;
- `AuditNodePaths` remains a separate package-keyed topology set;
- advisory objects are not cross-producted with installed nodes;
- current audit output is dated evidence, not acceptance;
- clean state requires no exception file; and
- the real installed Husky hook must be exercised through `git commit`.

Preserve PSStyleGuide's staged-index API as an intentional difference from
TerraformStyleGuide's full-repository hook.

### Blocking revisions

1. **Add continuous execution.** Expiring exceptions are not governed
   continuously if validation runs only on pull requests and pushes. P3
   currently excludes `build.yml`, while corrected P1B makes `build.yml` the
   sole event owner.

   Add `build.yml` to the computed P3 scope and require:

   - ordinary and Dependabot pull requests to `main`;
   - pushes to `main`;
   - `merge_group` when enabled;
   - one read-only UTC schedule; and
   - optional read-only `workflow_dispatch`.

   Schedule/manual runs should call only the local Markdown/dependency
   validation and a read-only terminal result. They must not run candidate
   preparation, artifact upload, Windows candidate validation, promotion
   approval, or the writer. GitHub notes that scheduled workflows run from the
   latest default-branch commit; see
   [Events that trigger workflows](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule).

2. **Define the exception lifetime.** “Within repository maximum” references no
   maximum in P3 or the live repository. Use the T3 contract:

   - UTC timestamps ending in `Z`;
   - an injected validation instant for fixtures;
   - `expiresAt` later than that instant and no later than exactly 30×24 hours;
   - exclusive expiry, so `now >= expiresAt` fails; and
   - exact before, at, and after-expiry cases.

3. **Add deterministic audit-policy oracles.** P3 specifies a production audit
   parser but no stable audit fixture catalog. Add `AUDIT-*` cases for at least:

   - clean report/no exception;
   - clean report with stale exception file;
   - residual report without approval;
   - exact approved residual;
   - missing/extra/duplicate approval keys;
   - missing/extra/topology-changed node paths;
   - advisory/schema/type/metadata/graph mismatches;
   - Boolean and reviewed-object `fixAvailable` forms;
   - unsupported report version;
   - audit exit versus derived-result mismatch;
   - before/at/after expiry;
   - malformed timestamps and over-30-day expiry;
   - immutable input fixtures; and
   - distinct vulnerability, policy, schema, registry/tool, and native-exit
     diagnostics.

4. **Separate the pure audit validator from orchestration.** Prefer a tracked
   dependency-free `Validate-NpmAudit.mjs` pure core plus CLI, with
   `Test-NpmAuditPolicy.ps1` orchestrating exact npm and cross-platform
   integration. The pure core can accept parsed audit data, optional exception
   data, and injected UTC time, which makes schema/topology/expiry fixtures
   deterministic without invoking the live registry.

5. **Use one tracked Node-policy decision.** P3 currently asks the shell hook
   and `lint-staged-markdown.mjs` to implement the same rule and then compare
   fixtures. That still creates two policy implementations. Add a
   dependency-free `Check-NodePolicy.mjs` with a pure exported decision and
   small CLI. The hook can invoke it before npm or `node_modules` checks, and the
   staged implementation can import it. Give the enumerated version forms
   individual stable oracles rather than collapsing all of them into
   `HOOK-08`.

6. **Consume the corrected P1B validator and parser.** P3's computed scope must
   include the existing `Validate-WorkflowPolicy.mjs` and retain or deliberately
   update its reviewed direct YAML parser. Rerun its positive and negative
   fixtures after the package upgrade, including the schedule/manual
   no-publication graph. Do not let the dependency remediation accidentally
   remove P1B's structural enforcement.

7. **Reconcile the package-update order with the current findings.** The slate's
   default order may remain P1→P1A→P1B→P2→P3 only after the P1 policy record
   accepts the dated waiting period. P3 should state how to rebaseline its
   prerequisite assumptions if policy instead requires earlier remediation.

### Recommended P3 scope after convergence

The final exact path set should be computed from selected packages, but the
issue should expect at least:

- `.github/workflows/build.yml`;
- `.github/workflows/markdownlint.yml`;
- `.github/workflows/Validate-WorkflowPolicy.mjs`;
- `.github/workflows/Check-NodePolicy.mjs` — add;
- `.github/workflows/Validate-NpmAudit.mjs` — add;
- `.github/workflows/Test-NpmAuditPolicy.ps1` — add;
- `.github/workflows/Test-LintStagedMarkdown.ps1` — add;
- `.github/workflows/lint-staged-markdown.mjs`;
- `.github/workflows/package.json`;
- `.github/workflows/package-lock.json`;
- `.husky/pre-commit`;
- `.github/dependabot.yml`; and
- conditionally, `.github/workflows/npm-audit-exceptions.json`.

Any compatibility-required lint configuration or nested-lint change remains
conditional and must be added explicitly before editing.

## Cross-issue convergence model

Use the following semantic layers in both repositories. This is the useful form
of generator unification; a shared runtime package is not required.

| Layer | PS owner | Terraform owner | Required convergence | Intentional differences |
| --- | --- | --- | --- | --- |
| Deterministic generator | P1 | T1 | Destination/provider checks, complete-payload normalization, encoding/newlines, metadata, host matrix, native exits, temporary writer boundary | Source composition, frontmatter, generated filenames |
| Candidate validation | P1A | T1A | Same-stream identity, component security, ceilings, fresh extraction, context and cleanup ownership, stable oracles | Exact four manifest filenames |
| Verified writer | P1B | T1B | Event owner, local callable workflow, policy parser, ID/digest/four hashes, unique cell outputs, approval, at-use regeneration, ref/SHA/lease/token model | Job and artifact names only where semantics remain equal |
| Content repair | P2 | T2/T4 have different domains | Consume the merged generator/writer boundary without weakening it | PS blank-line documentation has no forced Terraform analogue |
| Dependency governance | P3 | T3 | Finite Node policy, one npm, real hook, primary audit keys plus separate node paths, bounded exceptions, schedule/manual validation, Dependabot review | PS staged-index lint API versus Terraform full-lint hook |

Every reciprocal matrix should record:

- the exact PS and Terraform commits;
- concrete evidence on both sides;
- `same`, `intentional difference`, or `blocker`; and
- rationale for every intentional difference.

Use stable semantic layer names even if planning filenames later change. Keep
the matrices in pull-request evidence or tracked planning artifacts, not in an
unreviewed external document.

## Cross-slate consistency edits

Before filing, make these mechanical consistency changes:

1. Put actual issue URLs and real GitHub blocked-by relationships into each
   successor when it is filed.
2. Keep consumed predecessor merge commits in successor Dependencies sections.
   Remove future-successor actions from predecessor acceptance checklists.
3. Use one meaning for each stable test ID across P/T counterpart layers.
4. Use one exact external event owner after P1B.
5. Use one tracked workflow-policy validator after P1B; P3 updates rather than
   replaces it.
6. Use “exact explicitly declared action input keys” when discussing YAML and
   separately record reviewed action defaults.
7. Re-resolve every external action tag immediately before implementation and
   before merge. Treat the listed SHAs as reviewed snapshots, not timeless
   values.
8. Make affected-file equality a gate for each issue, but calculate it with
   NUL-safe Git pathname handling.
9. Preserve the exact issue H1 titles:
   - P1 — **Make artifact generation byte-deterministic across PowerShell
     editions and hosts**;
   - P1A — **Add a fail-closed cross-platform style-guide candidate
     validator**;
   - P1B — **Promote generated style-guide artifacts through a
     least-privileged verified writer**;
   - P2 — **Make the non-compliant blank-line example visibly distinct**; and
   - P3 — **Remediate Markdown lint dependency advisories and add npm update
     governance**.

## Filing recommendation

Revise P1, P1A, P1B, P2, and P3 in place, then perform one final reciprocal
read against the merged Terraform issue text. The minimum filing gate is:

- every blocker in the priority table has a concrete issue-level resolution;
- P1A has a complete one-row-per-ID oracle table;
- P1B has an executable same-run dependency graph and complete hash flow;
- the checkout credential claim matches the pinned action's actual behavior;
- P3 has scheduled, deterministic, at-most-30-day audit governance;
- P2's PR/post-merge evidence matches the corrected P1B graph; and
- the dated npm-risk owner decision permits the selected sequential order.

Once those conditions are met, file in the requested P1, P1A, P1B, P2, P3
sequence and retain the split architecture.
