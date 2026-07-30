# Feedback on the current PSStyleGuide issue slate

## Overall assessment

Keep the P1/P1A/P1B/P2/P3 split and, subject to P1's explicit advisory-risk
gate, keep the proposed order. The current drafts are substantially stronger
than the earlier slate:

- P1 now owns the advisory-order decision, permanent structural workflow
  validator, reusable raw NUL-safe Git path verifier, reviewed action defaults,
  honest checkout-token language, temporary-writer evidence, and a real
  successor handoff.
- P1A now has a closed 96-row case inventory, exact runtime applicability,
  separate caller/candidate cleanup cases, lifecycle states, and handoff
  evidence.
- P1B now makes `build.yml` the sole event owner, calls `markdownlint.yml`
  locally in the same run, propagates four path-bound hashes, maps four unique
  matrix outputs, extends P1's permanent validator, and states checkout versus
  push credential use much more accurately.
- P2 now preserves the Compliant block with a byte oracle, consumes rather than
  paraphrases P1B, uses P1's path verifier, and has PR/post-merge expectations
  that match the proposed graph.
- P3 now includes continuous schedule/manual execution, one shared Node-policy
  implementation, a split pure audit validator/integration harness, individual
  Node/audit cases, a 30-day exception limit, and P1B policy-validator
  preservation.

Those are material improvements. P2 is essentially filing-ready. P1A and P1B
are close after a few contract-level corrections.

The slate still should not be filed unchanged. The remaining issues are
concentrated and concrete:

| Priority | Issue | Remaining correction |
| --- | --- | --- |
| Blocker | P1 | Replace the generic `File.WriteAllText` helper with the closed, verified, old-or-complete-new artifact transaction already specified by T1. |
| Blocker | P1 | Define the exact first generator version and lock the workflow parser/package/lock producer rather than leaving both selections implicit. |
| Blocker | P1A | Validate raw public values before PowerShell coercion and publish the exact context object/journal schema and lifecycle. |
| Blocker | P1B | Make the final job/role/data-flow table complete, change diagnostics to `failure() && !cancelled()`, and remove the two remaining false credential phrases. |
| Blocker | P1B | Prove the actual production writer on an isolated evidence ref; a second temporary workflow containing a copied writer is weaker evidence. |
| Blocker | P3 | Select the exact hashed npm/Corepack identity and Node floors already resolved in T3, or document a proved intentional difference. |
| Blocker | P3 | Add the live `install-husky.mjs` prepare installer to scope and replace its permissive skip logic with a tested fail-closed state machine. |
| Blocker | P3 | Validate raw audit bytes with a closed report-v2/native-outcome contract and bind residual exceptions to retained live follow-up-issue evidence. |
| Required | P1A | Namespace local IDs and add shared semantic case keys so P1A↔T1A compares behavior rather than accidentally reused short IDs. |
| Required | P2 | Remove or defer its impossible-at-first-filing requirement to insert P3's future issue URL. |

Once these points are corrected, the slate will be ready for sequential filing
and implementation.

## Review baseline

This review uses the current PSStyleGuide default-branch head:
[`4346310e7deebffb4159c75e30d9546263dfd649`](https://github.com/franklesniak/PSStyleGuide/commit/4346310e7deebffb4159c75e30d9546263dfd649),
dated 2026-07-26. A fresh connected-repository query on 2026-07-29 confirmed
that it remains the latest commit.

That baseline confirms the proposed problems:

- [`Generate-StyleGuideArtifacts.ps1`](https://github.com/franklesniak/PSStyleGuide/blob/4346310e7deebffb4159c75e30d9546263dfd649/.github/workflows/Generate-StyleGuideArtifacts.ps1)
  has no script version, uses four host-sensitive `Set-Content` final writes,
  and constructs frontmatter with a host/source-EOL-sensitive here-string.
- [`build.yml`](https://github.com/franklesniak/PSStyleGuide/blob/4346310e7deebffb4159c75e30d9546263dfd649/.github/workflows/build.yml)
  is path-filtered, grants workflow-wide `contents: write`, uses mutable action
  tags, and directly commits and pushes.
- [`markdownlint.yml`](https://github.com/franklesniak/PSStyleGuide/blob/4346310e7deebffb4159c75e30d9546263dfd649/.github/workflows/markdownlint.yml)
  is a separately triggered Node 20 workflow.
- [`package.json`](https://github.com/franklesniak/PSStyleGuide/blob/4346310e7deebffb4159c75e30d9546263dfd649/.github/workflows/package.json)
  has no finite Node range or pinned package-manager identity.
- [`.husky/pre-commit`](https://github.com/franklesniak/PSStyleGuide/blob/4346310e7deebffb4159c75e30d9546263dfd649/.husky/pre-commit)
  and
  [`lint-staged-markdown.mjs`](https://github.com/franklesniak/PSStyleGuide/blob/4346310e7deebffb4159c75e30d9546263dfd649/.github/workflows/lint-staged-markdown.mjs)
  independently accept every Node major at or above 20.
- [`install-husky.mjs`](https://github.com/franklesniak/PSStyleGuide/blob/4346310e7deebffb4159c75e30d9546263dfd649/.github/workflows/install-husky.mjs)
  is the actual `prepare` installer. It silently skips for three ambient
  conditions, but P3 does not list or revise it.
- `.gitattributes` is already exactly `* text=auto eol=lf`, and
  `.github/dependabot.yml` is absent.

A read-only audit rerun on the exact commit under Node 26.5.1/npm 11.7.0
reproduced the P3 dated risk shape: exit 1, report version 2, seven vulnerability
properties, fourteen advisory objects, two package-string graph edges, and
seven installed node paths. The keys were `brace-expansion`, `js-yaml`,
`linkify-it`, `markdown-it`, `markdownlint-cli2`, `minimatch`, and `picomatch`;
metadata reported five high and two moderate properties. The issues correctly
treat those values as dated evidence, not acceptance constants.

The proposed action SHAs also still resolve to manifests with the expected
inputs:

- [`actions/checkout`](https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml)
  defaults `token` to `github.token`, so authenticated checkout is not
  credential-free even when persistence is disabled.
- [`actions/upload-artifact`](https://raw.githubusercontent.com/actions/upload-artifact/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a/action.yml)
  includes the proposed `archive` input.
- [`actions/setup-node`](https://raw.githubusercontent.com/actions/setup-node/820762786026740c76f36085b0efc47a31fe5020/action.yml)
  has security-relevant token, latest-selection, and automatic-cache behavior
  that belongs in the explicit/default policy.

## Slate structure and sequencing

### Keep the boundaries

P1/P1A/P1B remains the right decomposition. Serialization, adversarial archive
processing, and write-enabled workflow activation are different review and
rollback units. P1A's workflow-inert boundary is particularly valuable.

P2 should remain the first normal source/generated content change after P1B. It
then proves that the completed pipeline accepts a synchronized six-file change
without a recovery commit.

P3 should remain last only while P1's accountable advisory-risk authorization
is current and the rerun has not materially worsened. The new P1 gate handles
this well. If policy refuses the wait, move the smallest complete dependency
remediation ahead of P1 and rebaseline all successors; do not partially modify
the package graph inside P1.

### Preserve the issue titles and identifiers

Keep every H1 exactly as drafted. Continue referring to the PS issues as P1,
P1A, P1B, P2, and P3 and the Terraform issues as T1, T1A, T1B, T2, T3, and T4.
The embedded H1 titles are deliberate issue titles, not formatting defects.

### Distinguish a reviewed head from the landed commit

Before merge, an issue can record only its reviewed head. The protected-branch
landed identity may differ after merge, squash, or rebase. Each handoff should
carry:

- reviewed head, review/merge method, and final run evidence;
- the actual landed commit recorded after merge;
- exact script versions and hashes;
- the successor's real GitHub dependency edge; and
- revalidation evidence when reviewed and landed identities differ.

The current handoff sections are a good addition, but P1B in particular should
use this terminology explicitly because P2 consumes the landed pipeline.

## P1 — Make artifact generation byte-deterministic across PowerShell editions and hosts

### What is now strong

P1's new eight-file scope is coherent. Adding
`Validate-WorkflowPolicy.mjs`, `Test-ExactGitPathSet.ps1`, the parser
dependency, lockfile update, and Dependabot file makes its stated structural
and path-set controls implementable.

The advisory-risk gate is specific enough to govern the proposed sequence. The
separate explicit-input and reviewed-manifest-default records resolve the old
ambiguity about action defaults. The token wording now correctly admits
transient checkout use, and the exact temporary evidence-workflow path plus
removal proof is a useful P1 boundary.

The reusable NUL-safe Git path verifier is a sensible PS-specific implementation
choice. It can be consumed by P1A/P1B/P2/P3 without introducing a shared
cross-repository runtime.

### Blocking corrections

1. **Replace the generic direct write with T1's exact artifact transaction.**

   P1 still says the private helper accepts an arbitrary destination string and
   calls `File.WriteAllText` exactly once. That makes output bytes deterministic
   only on success. `File.WriteAllText` may truncate the old destination before
   a later write failure, and a generic path does not constrain which file the
   generator may overwrite.

   Use one `Write-StyleGuideArtifact` boundary with this closed map:

   | Artifact ID | Exact destination leaf |
   | --- | --- |
   | `copilot` | `copilot-instructions.md` |
   | `powershell-instructions` | `powershell.instructions.md` |
   | `chat` | `STYLE_GUIDE_CHAT.md` |
   | `full` | `STYLE_GUIDE_FULL.md` |

   Derive the repository root from the script's fixed `$PSScriptRoot` location,
   never the current directory. Reject null, empty, whitespace-only,
   NUL/control/malformed, wildcard, provider-qualified, relative/
   drive-relative/not-fully-qualified, and artifact-ID/path-mismatch inputs in a
   fixed order. Validate each existing component and require all four
   destinations to be tracked ordinary non-reparse files.

   After final payload normalization:

   1. encode the complete bytes once;
   2. create one unpredictable same-directory sibling with bounded
      collision-only retry, `FileMode.CreateNew`, write access, and no sharing;
   3. write all bytes, call `Flush(true)`, and dispose;
   4. verify exact length and SHA-256;
   5. recheck parent and destination; and
   6. call `File.Replace(temp,destination,$null)` exactly once.

   Before replacement returns, every failure must leave the old destination
   byte-identical and remove only the proven temporary sibling. After it
   returns, the complete new file is committed success and no fallible semantic
   gate follows. Unsupported replacement, uncertain cleanup, or substituted
   state must fail without copy/move/direct-write fallback. Add phase-by-phase
   fault injection in all three PowerShell cells.

   This is the main remaining generator-unification gap. P1 should prohibit
   `File.WriteAllText`, just as T1 now does.

2. **Publish the exact first generator version.**

   The baseline script has no version, so “existing parseable `.NOTES`
   location” is inaccurate. Require exactly one script-level line before the
   first function:

   ```text
   Version: 1.0.<actual-UTC-implementation-YYYYMMDD>.0
   ```

   Specify `[System.Version]` parsing, a real eight-digit UTC Build date, first
   publication, Major/Minor/Build/Revision bump rules, midnight recomputation,
   and rejection of missing, duplicate, malformed, impossible/stale-date,
   sign/whitespace/extra-component, or function-level decoy values. Version
   metadata remains descriptive; commit, ordinary-file identity, and SHA-256
   remain immutable evidence.

3. **Lock the workflow parser and lockfile producer.**

   “One reviewed direct YAML parser” and “the exact selected npm” leave two P1
   implementation decisions unspecified. P3 has not yet selected final npm, so
   P1 cannot refer to that future value implicitly.

   Converge with T1 unless re-resolution finds a blocker:

   - exact direct `"yaml": "2.9.0"`;
   - reviewed tarball/integrity and no lifecycle scripts;
   - the exact observed Node/npm pair used to generate P1's version-3 lockfile;
   - strict YAML 1.2 core, one document, unique string keys, and warnings as
     errors; and
   - rejection of directives, anchors, aliases, merge keys, explicit/custom
     tags, multidocument streams, complex/non-string keys, and non-JSON-like
     values before policy evaluation.

   Re-resolve the parser, integrity, audit result, and lock producer immediately
   before implementation. P3 may later replace the package-manager contract but
   must retain and revalidate the parser semantics.

4. **Complete the authored action-input policy or classify the difference.**

   The new reviewed-default record is good, but P1 still authors only `ref` and
   `persist-credentials` for checkout and only Node/cache for setup-node. T1
   authors the security-relevant values explicitly: repository, ref, token,
   persistence, fetch depth/tags/progress, LFS, submodules, clean,
   safe-directory, unsafe-PR behavior, `check-latest`, setup token, and
   compression/retention choices.

   Prefer the same explicit set in P1. If PSStyleGuide intentionally relies on a
   reviewed pinned default for one of those values, add a reciprocal-matrix row
   explaining why rather than silently diverging. Keep the separate complete
   manifest-default record either way.

5. **Expand the P1↔T1 matrix to cover the new foundations.**

   P1's comparison list still omits the most important new shared controls:
   old-or-complete-new replacement, first-version parser, strict workflow
   parser/package identity, explicit versus default action policy, raw Git path
   behavior, token-state inspection, and temporary evidence cleanup. Add these
   rows so the matrix actually proves the desired generator-layer convergence.

### P1↔T1 convergence

P1 and T1 should converge on the semantic generator core:

- closed artifact map and trusted root;
- complete-payload CR/LF normalization;
- BOM-less UTF-8 and exact final-newline behavior;
- same-directory verified replacement transaction;
- exact version grammar;
- locked strict workflow parser;
- explicit/default action policy;
- truthful checkout/push token boundary;
- raw Git path/status parsing; and
- host matrix, hashes, idempotence, and fault injection.

Source composition, exact filenames, frontmatter, and P1's reusable path-verifier
file are intentional differences. Keep both implementations repository-local;
do not add a shared runtime package.

## P1A — Add a fail-closed cross-platform style-guide candidate validator

### What is now strong

The current 96-row catalog is a major improvement. A mechanical count confirms
96 unique IDs, with no duplicate ID. Digest grammar, download cardinality,
script identity, exact resource boundaries, caller cleanup, non-scalar labels,
and per-runtime skip behavior are now explicit rather than hidden inside
ranges.

The issue also defines `Active`/`CleanupFailed`/`Disposed`, separates candidate
and caller cleanup owners, requires one record per ID/runtime, and fails on
missing, duplicate, unexpected, or mismatched totals. Retain all of that.

### Blocking corrections

1. **Validate raw public values before PowerShell binding erases their type.**

   “Mandatory scalar” and cases that expect a “binding/parameter” failure do not
   specify how arrays, objects, null, or provider values survive binding. A
   `[string]` parameter can coerce a collection or object into a misleading
   string before production validation.

   Define the closed public inventory:

   - helper checkout/trusted/download/candidate paths and expected digest;
   - context-creation parent;
   - every explicit cleanup journal path;
   - harness `HelperPath` and `ContextManagerPath`; and
   - optional diagnostic labels.

   Preserve each untrusted scalar as raw `[object]`; do not enumerate, join,
   stringify, trim, or normalize before classification. Reject in a fixed order:
   null, non-string scalar/collection, empty, Unicode-whitespace-only,
   NUL/C0/C1 control or malformed provider syntax, wildcard, relative/
   drive-relative/root-relative/tilde, and unsupported/nonfilesystem provider.
   Accept only a platform-native fully qualified filesystem path or exactly one
   `FileSystem::`-qualified fully qualified path.

   `GetUnresolvedProviderPathFromPSPath` returns one unresolved string; do not
   call a resolving/multi-match API. Replace or clarify the current
   “multiple-resolution path” cases so they exercise a real reachable boundary
   such as raw collection/custom-PSDrive/provider ambiguity.

2. **Publish the exact context and journal schemas.**

   “Nonempty scalar” and “ordered collection” are not exact types. Give the
   context a closed first `PSTypeName`, for example
   `PSStyleGuide.StyleGuideCandidateInvocationContext.v1`, and exact ordered
   properties/types:

   - schema version and context GUID;
   - lifecycle state;
   - normalized temporary parent, invocation root, download directory, and
     expected-absent candidate path;
   - diagnostic label;
   - typed ownership journal; and
   - cleanup summary.

   Give each journal entry its own `PSTypeName`, exact property set/types,
   contiguous unique sequence, `File|Directory` kind, normalized path,
   acquisition phase, and ownership state. Cleanup must treat this object as
   untrusted and reject unknown/missing/extra fields, types, sequence, state, or
   path relationships before deletion.

3. **Use a complete lifecycle and define repeated disposal safely.**

   Add an explicit `CleanupInProgress` transition so re-entry or interruption
   cannot look like an ordinary `Active` cleanup. Use a distinct retained-
   uncertainty terminal state such as `RetainedUncertain`, or record why
   `CleanupFailed` is intentionally equivalent in P1A↔T1A.

   A valid already-`Disposed` context should be success/no-op with the identical
   object and zero filesystem calls. It no longer owns a later path that happens
   to reuse the same name. The current requirement to “prove no journaled entry
   reappeared” after disposal implies filesystem inspection and leaves the
   response to a reused path unclear. Converge with T1A's no-call disposed
   behavior or record a fully specified, non-deleting intentional difference.

   Entry in `CleanupInProgress` or retained uncertainty should return a stable
   retained-state failure with zero deletion. Unknown or forged schema/state
   should fail with zero filesystem calls.

4. **Give all three scripts exact first-publication versions.**

   Require exactly one script-level
   `Version: 1.0.<actual-UTC-implementation-YYYYMMDD>.0` under P1's complete
   parser and bump rules. “Under the PSStyleGuide policy” is not enough for the
   harness to know the expected literal identity.

### Required convergence corrections

1. **Namespace local IDs and add semantic case keys.**

   Short IDs such as `K-03` already have different meanings in the two
   repositories. Prefix the local IDs (`P1A-K-03`, `T1A-K-03`) and give every
   row a stable semantic key such as `cleanup.candidate.repeat-disposed`.

   Every catalog row/result should contain both `Id` and `SemanticCase`.
   Reciprocal equality should compare semantic key, fixture, applicability,
   helper outcome, phase/subreason/status, candidate/context state, cleanup
   sequence, diagnostics, and sentinel state. Add cases for duplicate/missing
   ID or key, remapped key, equal key with different expected fields, and an
   intentional difference without rationale.

2. **Close the result-record schema.**

   The prose lists many result fields, but it does not define a closed property
   schema, allowed state enums, or numeric helper/harness statuses. Adopt T1A's
   fixed fields for ID, semantic case, applicability, fixture, initial state,
   harness result, helper process status, phase, subreason, candidate state,
   context state, cleanup sequence, diagnostics, and sentinel state.

   The current clarification that an expected helper rejection is a harness
   pass is useful. Preserve it and encode both values separately so “status”
   cannot mean helper outcome in one row and harness outcome in another.

### P1A↔T1A convergence

Manifest filenames are the main intentional difference. Raw value grammar,
same-stream archive identity, component/path security, exact resource limits,
fresh extraction, context/journal schema, lifecycle, cleanup ownership,
semantic cases, diagnostics, and runtime behavior should otherwise converge.
Do not create a cross-repository runtime dependency.

## P1B — Promote generated style-guide artifacts through a least-privileged verified writer

### What is now strong

The previous structural blockers are resolved:

- `build.yml` is the sole external event owner.
- `markdownlint.yml` is a same-commit local callable workflow.
- Approval has same-run Markdown, preparation, and Windows dependencies.
- Preparation exports four named path-bound hashes.
- Every cell attests those hashes, and approval compares them.
- P1B extends P1's permanent validator instead of inventing another parser.
- Checkout-token use and push-header construction are mostly distinguished.
- P1's raw Git verifier constrains the final three-file scope.

The static four-key output mapping and negative completion-order fixtures are
especially useful. Keep them.

### Blocking corrections

1. **Write one complete job/role/data-flow table.**

   The current draft distributes job dependencies, permissions, outputs, and
   conditions across prose. Add one normative table that names every job, direct
   `needs`, exact permission, eligibility predicate, output owner, and side
   effect. The writer must directly need every producer whose result/output it
   reads; do not rely on transitive `needs`.

   Use workflow-level `permissions: {}` and give exact permissions to each job.
   The terminal approval needs no repository contents permission. A
   workflow-wide `contents: read` grant is broader than the stated
   least-privilege design.

   Add exact static and expanded runtime role counts, including the local
   callable job. Make the validator reject a missing direct dependency, dormant
   second writer, output read without a direct producer dependency, and extra
   environment or side-effect owner.

2. **Make action inputs fully explicit or record an intentional difference.**

   P1B still authors only `ref`/persistence for checkout and Node/cache for
   setup. Reuse P1's corrected complete input policy. Explicitly decide setup
   token/check-latest, checkout repository/token/fetch/clean/safe-directory
   behavior, upload compression, and candidate retention.

   T1B uses one-day candidate retention and compression level 0. P1B currently
   uses seven days and an omitted compression default. Either converge or add a
   reciprocal row with cost, evidence-retention, and security rationale.
   Retain the separate complete pinned-manifest-default record.

3. **Fix the diagnostic conditions.**

   Both P1B diagnostic role rows use `${{ failure() }}`, while later prose says
   diagnostics run on ordinary failure and never cancellation. Make the
   normative condition exactly:

   ```text
   ${{ failure() && !cancelled() }}
   ```

   Update the workflow, role table, validator constants, and one-condition-at-a-
   time fixtures atomically. This is a direct internal contradiction, not an
   optional hardening.

4. **Remove the two remaining false credential phrases.**

   The summary and credential section are now accurate, but two later phrases
   regress:

   - a Windows cell “checks out/verifies event SHA without credentials”; and
   - writer revalidation occurs “before token materialization,” then begins
     with authenticated checkout.

   Say “without persisted credentials” for the cell. Say “before explicit
   push-header construction or repository mutation” for writer revalidation.
   The job token already exists, and checkout may already have used it.

5. **Prove the actual writer, not a copied writer in a second workflow.**

   `.github/workflows/evidence-p1b-temporary-writer.yml` proves a structurally
   similar copy, not necessarily the production writer's real job dependencies,
   expressions, permissions, and output wiring. Follow T1B's isolated evidence-
   ref pattern:

   - record `PRODUCTION_BASE`;
   - create an unpredictable
     `refs/heads/p1b-evidence/<utc>-<random>` at that commit;
   - on that ref only, patch the same `build.yml` and validator constants using
     an upfront exact allowed-delta manifest;
   - allow only the literal event/ref/predicate/fixture/scenario deltas needed
     for the evidence ref;
   - run the real prepare/matrix/approval/writer path;
   - make each negative drill a closed data-only scenario;
   - record run/ref/parent/tree/lease/hash/diagnostic evidence;
   - restore any evidence-ref protection setting exactly and delete the ref with
     an expected-old guard; and
   - prove the production candidate descends from `PRODUCTION_BASE` and contains
     no evidence commit, string, fixture, selector, alternate event, or push
     path.

   Do not copy the writer, use inherited secrets, weaken `main`, or merge any
   evidence commit.

6. **Make the reviewed-head/landed handoff explicit.**

   P1B's Handoff says “final merge commit” but does not distinguish the reviewed
   candidate from the eventual protected-branch identity. Record both and make
   P2 verify reachability from protected `main`, merge method/time, final
   workflow identities, and rerun evidence when the IDs differ.

### P1B↔T1B convergence

Add the refinements above to the reciprocal matrix:

- exact job/direct-needs/permission/data-flow table;
- explicit and reviewed-default action policy;
- diagnostic condition;
- token existence, checkout use, persistence, and push-header wording;
- production writer evidence-ref method and cleanup;
- raw Git path/status behavior; and
- reviewed-head versus landed-commit handoff.

Repository-local names and paths may differ. A copied writer, wider permission,
missing direct dependency, weaker artifact selection, unpropagated hash, or
weaker lease is a blocker rather than an intentional difference.

## P2 — Make the non-compliant blank-line example visibly distinct

### What is now strong

P2 is ready in substance:

- the Compliant heading/block has an exact baseline hash and mutation tests;
- the Non-Compliant visualization is visible without storing trailing spaces;
- the rationale extends the existing section without duplicating the
  operational block;
- metadata and all four generated artifacts move together;
- P1's NUL-safe verifier owns exact path-set checks;
- `git diff --exit-code` distinguishes equality, ordinary drift, and Git
  failure;
- PR evidence runs preparation, local Markdown validation, all four Windows
  cells, four attestations, and read-only approval; and
- post-merge expects `has_changes=false` and no writer.

The decision to make P1B's retained evidence authoritative instead of restating
writer internals is exactly right.

### One required filing correction

P2 says that “at filing” its title-only P3 reference must be replaced with P3's
actual issue URL. The prescribed filing order is P1→P1A→P1B→P2→P3, so P3 does
not yet exist when P2 is first filed.

Choose one satisfiable protocol:

- leave the P3 title as a clearly noncanonical forward reference, file P3, then
  backpatch and verify P2's link before either issue is marked ready; or
- omit the future URL from P2 and let P3's real blocked-by relationship point
  backward to P2.

Do not fabricate a future issue number or make P2 initial filing depend on an
object that the transaction has not created.

After this wording correction and the upstream P1/P1A/P1B fixes, P2 is
filing-ready.

## P3 — Remediate Markdown lint dependency advisories and add npm update governance

### What is now strong

P3 now has the right overall policy boundary. The weekly UTC schedule and
input-free manual dispatch are read-only and structurally exclude publication.
One `Check-NodePolicy.mjs` is intended to serve engines, hook, staged API,
workflow, and fixtures. The audit pure-core/orchestration split, individual
`NODE-*` and `AUDIT-*` IDs, exact 30-day expiry, absent-clean exception file,
real installed hook, and inherited P1B policy fixtures are all good.

Preserve PSStyleGuide's programmatic staged-index lint API as an intentional
difference from TerraformStyleGuide's full-repository hook.

### Blocking corrections

1. **Select the exact npm/Corepack and Node policy.**

   P3 still says “choose” npm and “any required patch floor,” even though the
   current T3 research resolves a compatible exact contract. Re-resolution
   should be a drift check, not an open design decision.

   Unless current evidence disproves it, use:

   ```json
   "packageManager": "npm@12.0.2+sha512.b885e890b9418fa1693544d05f53e64f9a73ec194837d4258b15fecdd692347b1dd2a517b1b0cbaf9d31cd8e92c3b70956bd2ecc72833a57b4b3098f5bfa7943"
   ```

   and:

   ```text
   >=22.22.2 <23 || >=24.15.0 <25
   ```

   Registry metadata for npm 12.0.2 currently declares
   `^22.22.2 || ^24.15.0 || >=26.0.0`; the finite repository policy deliberately
   admits the reviewed Node 22/24 lines and excludes current-but-unreviewed Node
   26.

   Run every package operation as `corepack npm ...`. Enable Corepack strict
   project/integrity behavior, assert npm exactly 12.0.2 in every cell, use one
   exact Node 24/npm pair as the sole lockfile producer, and prove other cells
   do not rewrite it. Do not use ambient/bundled npm, `npx`, global npm, or an
   npm devDependency.

   Re-resolve the release, integrity, engine, and supported current patch values
   immediately before implementation. If PSStyleGuide needs a different
   contract, record a complete intentional-difference row rather than selecting
   “latest.”

2. **Do not let production callers supply the policy or observed version.**

   The current `Check-NodePolicy.mjs` CLI accepts an observed string and a
   versioned policy. That is appropriate for a pure fixture API, not the
   production CLI: a caller could pass a weaker policy or a fake supported
   version.

   Compile one explicit two-row policy into the tracked module. Its production
   CLI must always read actual `process.versions.node` and have no version,
   policy, environment, or clock override. Expose a separate pure predicate for
   fixture inputs. Give every literal grammar/floor/major case one atomic ID in
   a closed tracked manifest, and make the CLI, import, engines range, workflow
   cells, and installed hook agree.

3. **Add and harden the actual prepare installer.**

   The live `prepare` script invokes `.github/workflows/install-husky.mjs`, but
   P3's affected list and requested changes omit it. Add the existing lowercase
   path to required scope. Do not perform a case-only rename merely to match
   TerraformStyleGuide; the repository-local name is an intentional difference.

   Replace the ambient skip logic with a closed state machine:

   - required installation is the default;
   - skip is allowed only through exact named canonical states, such as
     `HUSKY_INSTALL_MODE=skip`, `HUSKY=0`, or exact `CI=true` with a recorded
     `read-only-ci-install` reason;
   - unknown values and conflicting skip sources fail;
   - required mode resolves the exact repository root, invokes the pinned Husky
     through the selected package environment, and verifies exact
     `core.hooksPath`, ordinary non-link shims, and the tracked hook identity;
   - skip mode proves config/filesystem/byte immutability and never reports
     “installed”; and
   - install, invocation, or verification errors are nonzero.

   Add atomic cases for required success/failure, each skip, unknown/conflicting
   values, wrong root/hooks path, missing/linked/substituted hook or shim, and a
   direct hook that would pass while Git does not invoke it.

4. **Validate raw audit bytes before parsing.**

   P3 currently has PowerShell “parse once” and pass parsed data into the pure
   core. Common PowerShell JSON parsing loses duplicate-key evidence and cannot
   prove strict raw UTF-8/one-value grammar after the fact.

   Invoke exactly:

   ```text
   corepack npm audit --package-lock-only --json
   ```

   Capture stdout and stderr separately into bounded protected streams and
   preserve one native outcome:
   `exit|signal|timeout|startFailure`. Pass the raw stdout file and captured
   outcome to the tracked JavaScript CLI.

   Before `JSON.parse`, enforce:

   - an explicit raw-byte ceiling;
   - BOM-less strict UTF-8;
   - one complete JSON value plus trailing whitespace only;
   - duplicate-key detection through a reviewed tokenizer; and
   - depth, property, array, string, and safe-number ceilings.

   Define a closed report-v2 schema. Reject unknown or missing top-level,
   vulnerability, advisory, CVSS, `fixAvailable`, and metadata properties.
   Reconcile reciprocal `via`/`effects`, sorted unique nodes, severity and
   dependency totals, lockfile paths, and native outcome without inventing
   advisory-to-node Cartesian edges.

   Use a closed decision table:

   | Native outcome | Parsed graph | Result |
   | --- | --- | --- |
   | exit 0 | valid empty | clean; exception file absent |
   | exit 0 | nonempty | status/report mismatch |
   | exit 1 | valid nonempty | evaluate exact residual policy |
   | exit 1 | empty or malformed | status/report/schema failure |
   | other exit, signal, timeout, start failure | any | process/tool failure |

   Give process/tool, raw JSON, schema, status mismatch, policy mismatch, and
   governance distinct stable exit classes.

5. **Expand the audit cases around the raw boundary.**

   The current 25 cases cover the high-level policy well but omit atomic raw
   input and closed-schema cases. Add IDs for non-JSON, truncated JSON,
   duplicate key, trailing second value, BOM, invalid UTF-8, oversized/deep
   input, unknown property, wrong top-level/vulnerability/advisory/CVSS/
   metadata type, signal, timeout, and start failure. Each row should assert one
   exact validator class, normalized findings, node paths, exception state,
   input immutability, and bounded diagnostic.

6. **Bind residual exceptions to canonical live issue evidence.**

   “Real public PSStyleGuide follow-up issue URL” is not enforceable by the pure
   offline validator alone. Define canonical URL/number grammar for exactly:

   ```text
   https://github.com/franklesniak/PSStyleGuide/issues/<positive-decimal>
   ```

   Reject pull URLs, alternate repositories/case, credentials, port, query,
   fragment, trailing slash, encoding, and dot segments. Add a canonical hash
   of the exact sorted `(Package, AdvisoryUrl)` scope assigned to the issue.

   At approval and renewal, require one authorized live GitHub API/UI read and
   retain a bounded evidence record containing repository, canonical URL/
   number, immutable issue ID, open state, absence of `pull_request`, owner,
   timestamps, title/body/scope-marker hashes, verifier/time, and current scope
   hash. Store the evidence-record hash in the exception. Retain no token,
   header, arbitrary response, email, or signed URL.

   The offline validator may say only that URL/scope/evidence fields are
   structurally valid; a reviewer verifies the live record. A closed,
   transferred, deleted, converted, unowned, or scope-changed issue requires
   remediation or a new approval, not a timestamp-only renewal.

### Expected P3 scope after correction

The exact set remains package/disposition-dependent, but required scope should
expect at least:

- `.github/workflows/build.yml`;
- `.github/workflows/markdownlint.yml`;
- `.github/workflows/Validate-WorkflowPolicy.mjs`;
- `.github/workflows/Check-NodePolicy.mjs` — add;
- `.github/workflows/node-policy-cases.json` — add;
- `.github/workflows/Validate-NpmAudit.mjs` — add;
- `.github/workflows/install-husky.mjs`;
- `.github/workflows/lint-staged-markdown.mjs`;
- `.github/workflows/Test-LintStagedMarkdown.ps1` — add;
- `.github/workflows/Test-NpmAuditPolicy.ps1` — add;
- `.github/workflows/package.json`;
- `.github/workflows/package-lock.json`;
- `.husky/pre-commit`; and
- `.github/dependabot.yml`.

Add `npm-audit-exceptions.json` only for a real approved residual. Add
`lint-nested-markdown.js` or `.markdownlint.jsonc` only for a reviewed package
compatibility change. No guide source, generated artifact, generator,
candidate-helper, or writer semantics should change.

## Cross-slate convergence model

Thoughtful unification should align contracts and evidence without creating a
shared runtime dependency:

| Semantic layer | PS owner | Terraform owner | Required convergence | Intentional differences |
| --- | --- | --- | --- | --- |
| Deterministic generation | P1 | T1 | Closed artifact map, trusted root, complete-payload normalization, encoding/newline, verified replacement, version parser, host/fault matrix | Source composition, frontmatter, exact filenames |
| Workflow/path policy | P1 | T1 | Strict locked YAML parser, authored inputs/defaults, token truth, raw Git paths/statuses | P1's reusable PowerShell path-verifier file |
| Candidate validation | P1A | T1A | Raw values, same-stream identity, component security, ceilings, extraction, exact context lifecycle, semantic cases | Four manifest filenames |
| Verified writer | P1B | T1B | One event owner/callable workflow, ID/digest/four hashes, unique cells, approval, at-use regeneration, exact ref/SHA/lease, real-writer evidence | Repository-local job/artifact names |
| Dependency governance | P3 | T3 | Hashed npm/Corepack, finite Node floors, fail-closed installer/hook, raw closed audit, bounded exceptions, schedule, Dependabot | PS staged-index API and existing lowercase installer path |
| PS content repair | P2 | none required | Consume the completed PS pipeline without weakening it | Blank-line visualization is PS-specific |
| Terraform recovery guidance | none required | T2 and T4 | No forced PS counterpart | Terraform state/provider safety is Terraform-specific |

Every reciprocal row should retain exact immutable P/T commits, evidence,
classification (`same`, `intentional difference`, or `blocker`), and rationale.
Repository-local naming is often intentional. Unexplained differences in path
safety, failure transaction, archive identity, cleanup, permissions, token
handling, artifact selection, data flow, approval, or lease are blockers.

The repositories should remain self-contained. Copying the same reviewed
semantic skeleton and case identities into both repositories is appropriate;
making either generator or validator download or execute the other repository
is not.

## Cross-issue consistency edits

Before filing:

1. Preserve all H1 titles and P/T labels exactly.
2. File and verify real GitHub issue URLs and dependency edges without
   fabricating future issue numbers.
3. Distinguish reviewed heads from protected-branch landed commits in every
   handoff.
4. Use P1's one workflow-policy validator in P1B and P3; never add a second
   parser or derive policy from positive YAML.
5. Use P1's one raw Git path verifier throughout the PS slate and retain its
   exact version/hash in each dependency handoff.
6. Record exact authored action inputs and complete reviewed pinned-manifest
   defaults separately.
7. Re-resolve action tags, package releases, integrity, engines, and manifest
   digests immediately before implementation and merge.
8. Namespace local test IDs and compare cross-repository semantic keys.
9. Keep generated artifacts derived-only and commit normal source/artifact
   synchronization together.
10. Treat temporary evidence files/refs/settings as explicit test state with
    exact allowed deltas, cleanup, and final absence proofs.

## Filing recommendation

Revise P1, P1A, P1B, P2, and P3 in place, then perform one final reciprocal
read against the current T slate. The minimum filing gate is:

- P1 uses a closed verified replacement transaction, exact first version,
  locked parser/lock producer, and complete reciprocal matrix;
- P1A validates raw values, publishes exact context/journal/lifecycle schemas,
  and uses local IDs plus semantic keys;
- P1B has a complete direct-needs/permission/data-flow policy, cancellation-safe
  diagnostics, consistent token wording, and proof of the real writer on an
  isolated evidence ref;
- P2's future-P3 link protocol is satisfiable;
- P3 pins npm/Corepack and Node floors, governs the real installer, validates
  raw closed audit input/outcomes, and retains live follow-up-issue evidence;
  and
- every reciprocal matrix has no unexplained security or failure blocker.

After those focused corrections, the P slate will preserve the strongest T
refinements while remaining appropriately specific to PSStyleGuide.
