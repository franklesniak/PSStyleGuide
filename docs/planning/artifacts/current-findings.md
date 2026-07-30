# Current PSStyleGuide issue-slate findings

## Review status

Review complete against the current committed versions of:

- `docs/planning/PSStyleGuide/01PSStyleGuideP1.md`;
- `docs/planning/PSStyleGuide/01aPSStyleGuideP1A.md`;
- `docs/planning/PSStyleGuide/01bPSStyleGuideP1B.md`;
- `docs/planning/PSStyleGuide/02PSStyleGuideP2.md`;
- `docs/planning/PSStyleGuide/03PSStyleGuideP3.md`; and
- `docs/planning/PSStyleGuide/slate-criticism.md`.

The pre-existing findings artifact was written before the current issue drafts
and criticism file. Its conclusions are not being carried forward without
revalidation.

## Initial observations

- All five issue descriptions preserve the requested H1 title convention and
  identify the issues as P1, P1A, P1B, P2, and P3.
- The intended dependency order is explicit: P1 → P1A → P1B → P2 → P3.
- The current P1 draft now places the structural workflow-policy validator and
  NUL-safe exact Git path-set verifier in the foundational issue, so older
  criticism that described these mechanisms as absent must be checked for
  supersession.
- The issue drafts are individually below GitHub's issue-body size boundary,
  but the slate contains more than 3,000 lines of implementation contract and
  validation text. Precision is valuable; repeated or nonessential mechanisms
  should still be removed because they increase contradiction and maintenance
  risk.

## Criticism recommendation audit

### Slate structure and sequencing

- **Keep the P1/P1A/P1B/P2/P3 split — valid.** Serialization, adversarial
  archive handling, publication, the source-content repair, and dependency
  governance are distinct review units.
- **Keep P3 last only behind the advisory-risk authorization — valid.** P1
  contains a concrete stop/rebaseline gate rather than silently accepting a
  stale audit baseline.
- **Preserve every H1 and the P/T identifiers — valid and already satisfied.**
- **Distinguish reviewed heads from landed commits — valid and still open.**
  The handoffs generally request a “final merge commit” but do not consistently
  retain the reviewed head, merge method, landed identity, or required rerun
  when those identities differ.

### P1 recommendations

1. **Closed artifact map — valid; the proposed `File.Replace` transaction —
   denied as written.** A closed artifact-ID/destination map and a repository
   root derived from `$PSScriptRoot` materially reduce accidental overwrite
   scope and improve PS/T convergence. `File.WriteAllText` truncates an existing
   destination before writing, so it does not offer old-or-complete-new
   behavior. However, neither .NET nor the underlying Windows `ReplaceFile`
   contract promises the criticism's stronger invariant. Windows explicitly
   documents failed replacement states in which, when no backup path was
   supplied, the old destination no longer exists or has moved. Therefore
   `File.Replace(temp, destination, $null)` cannot support “every failure before
   return leaves the old destination byte-identical.” Do not import that exact
   T1 recipe into P1. If atomic/recoverable local replacement is a real project
   requirement, design and prove a platform-specific transaction with honest
   uncertain-state/recovery semantics. It is not a prerequisite for byte
   determinism or remote-writer safety.
2. **Publish the first generator version explicitly — valid.** The baseline
   script has a `.NOTES` section but no version field, so P1's phrase “existing
   parseable `.NOTES` location” is inaccurate. State that this is first
   publication and require `1.0.<UTC implementation YYYYMMDD>.0` under the
   repository's `[System.Version]` rules.
3. **Lock the YAML parser and lockfile producer — valid and open.** P1 currently
   leaves both the parser identity and lockfile-producing Node/npm pair open.
   Registry evidence confirms that `yaml@2.9.0` is currently the latest release,
   supports Node `>=14.6`, and has the integrity value cited below. Because the
   issue already pins action versions while requiring re-resolution, use the
   same pattern here: name the exact parser and lock producer now, re-resolve
   immediately before implementation/merge, and stop for review on drift.
4. **Make security-relevant action inputs explicit or classify omitted
   defaults — valid.** The separate pinned-manifest-default record is strong,
   but the reciprocal matrix should say which defaults are intentionally
   omitted. Converging the authored inputs where practical makes policy review
   easier. This is a contract-clarity improvement, not evidence that pinned
   defaults are ignored.
5. **Expand P1↔T1 for the new foundations — valid.** The current list does not
   explicitly cover the parser/package identity, explicit-versus-default action
   policy, raw Git path verifier, or evidence-state cleanup.

### P1A recommendations

1. **Validate raw public values before PowerShell coercion — valid and
   blocking for the claimed fail-closed contract.** “Mandatory scalar” does not
   specify parameter types. Typed `[string]` binding can erase whether the
   caller supplied a collection or other object. Public untrusted values need a
   closed raw `[object]` classification order before normalization. The
   “multiple-resolution path” cases should also be replaced with reachable
   ambiguity/type fixtures after wildcard rejection.
2. **Publish exact context and journal schemas — valid.** The issue says the
   context contains “exactly” a set of fields but uses descriptions such as
   “nonempty scalar” and “ordered collection.” Cleanup is supposed to treat the
   context as untrusted, which requires exact type names, property sets, enums,
   sequence rules, and path relationships.
3. **Complete lifecycle and repeated disposal — partially valid.** Repeated
   disposal should be a zero-filesystem-call success for the identical valid
   disposed object; it must never inspect or delete a later unrelated object
   that reused a path. A retained-uncertainty state is already represented by
   `CleanupFailed`, so another terminal enum is optional. `CleanupInProgress`
   is useful only if the implementation defines a reachable re-entry or retry
   model; it is not independently a filing blocker.
4. **Give all three scripts explicit first-publication versions — valid
   clarification, low severity.** The linked repository policy already implies
   the values, but saying `1.0.<UTC implementation YYYYMMDD>.0` removes doubt
   and gives the harness an unambiguous initial-version rule.
5. **Namespace IDs and add semantic case keys — valid for reciprocal
   comparison.** Short IDs are locally unique but collide semantically with
   T1A. Local IDs plus cross-repository semantic keys let the matrix compare
   behavior instead of spelling.
6. **Close the result-record schema — valid.** The prose names fields but does
   not define a closed property/type/enum/status contract, even though the
   harness must reject unexpected and mismatched records.

### P1B recommendations

1. **Add a complete job/direct-needs/permission/data-flow table — valid and
   high priority.** The action-role table is not a job-graph table. The final
   contract should make direct output dependencies, exact job predicates,
   permissions, output ownership, and side effects structurally testable.
   Workflow-level `contents: read` is broader than necessary for the approval
   job; job-level grants better match “least privileged.”
2. **Make final action inputs explicit or record intentional differences —
   valid.** In particular, seven-day candidate retention and omitted
   compression differ from the stated T1B model and need either convergence or
   a cost/evidence rationale.
3. **Use `failure() && !cancelled()` for diagnostics — valid defect.** Both
   normative diagnostic rows say only `failure()`, contradicting the later
   “never cancellation” requirement.
4. **Remove the remaining credential-free phrases — valid defects.** A matrix
   checkout is “without persisted credentials,” not “without credentials,” and
   writer work occurs before explicit push-header construction, not before
   token materialization.
5. **Exercise the real writer graph on an evidence ref — valid strengthening.**
   A separately copied workflow can be structurally compared, but it does not
   naturally exercise the production job graph and output wiring. An isolated,
   never-merged evidence-ref delta to the same `build.yml`, with exact allowed
   changes and guarded cleanup, provides stronger evidence.
6. **Make reviewed-head/landed handoff explicit — valid.** P2 consumes the
   landed workflow and needs reachability plus rerun evidence if the reviewed
   and landed identities differ.

### P2 recommendation

1. **Fix the future P3 URL protocol — valid.** P3 does not exist when P2 is
   initially filed in the prescribed order. Keep a clearly noncanonical title
   reference and backpatch after P3 exists, or omit the forward URL and let P3
   point backward.

### P3 recommendations

1. **Select exact npm/Corepack identity and Node floors — valid and open.** P3
   presently leaves the npm release and patch floors open. Current registry
   evidence confirms the criticism's proposed exact descriptor and engine:
   npm `12.0.2`, SHA-512
   `b885e890b9418fa1693544d05f53e64f9a73ec194837d4258b15fecdd692347b1dd2a517b1b0cbaf9d31cd8e92c3b70956bd2ecc72833a57b4b3098f5bfa7943`,
   and `^22.22.2 || ^24.15.0 || >=26.0.0`. Use the finite repository range
   `>=22.22.2 <23 || >=24.15.0 <25`, the hash-qualified `packageManager`,
   explicit `corepack npm`, and one exact Node-24 lock producer, subject to the
   same pre-implementation/pre-merge re-resolution used for actions. A proved
   later incompatibility should trigger review and an intentional-difference
   record, not an ambient “latest” selection.
2. **Do not let production callers supply the observed Node version or policy —
   valid.** The production CLI should read `process.versions.node` and enforce a
   compiled tracked policy. Keep caller-supplied values only on a separate pure
   fixture API.
3. **Add and harden the real `install-husky.mjs` prepare installer — valid.**
   It is the live `prepare` target, is omitted from P3's scope, and currently
   silently skips for ambient conditions. At minimum P3 must include and test
   its exact install/skip/failure contract.
4. **Validate raw audit bytes and native outcome before object validation —
   valid for the stated fail-closed policy.** PowerShell object parsing loses
   duplicate-key and raw encoding evidence. The boundary should preserve
   bounded stdout/stderr, one closed native outcome, strict BOM-less UTF-8, one
   JSON value, and a closed report-v2 schema before policy evaluation.
5. **Add raw/schema/process audit fixtures — valid if the raw boundary is
   adopted.** The current 25 cases cover policy outcomes but not malformed raw
   JSON, duplicate keys, encoding/size/depth, unknown fields, signal, timeout,
   or start failure.
6. **Bind residual exceptions to retained live issue evidence — valid
   governance clarification.** The offline validator can prove canonical URL
   and evidence-record structure, not that an issue is currently open and
   owned. Approval/renewal needs an authorized live lookup and a bounded
   retained identity/scope record.

### Cross-slate consistency recommendations

1. **Preserve H1s/P-T labels — valid and satisfied.**
2. **Use real URLs/dependency edges without fabricated numbers — valid, but the
   current transaction wording is ambiguous about creation-time versus
   post-creation verification; see independent findings.**
3. **Distinguish reviewed heads and landed commits — valid and open.**
4. **Reuse P1's one workflow-policy validator — valid and satisfied in P1B/P3.**
5. **Reuse P1's raw Git path verifier — valid and satisfied in P1A/P1B/P2/P3.**
6. **Separate authored inputs and reviewed defaults — valid and substantially
   satisfied; intentional omissions still need reciprocal rationale.**
7. **Re-resolve actions/packages/manifests before implementation and merge —
   valid and substantially satisfied.** Package selections also need an exact
   freeze point after re-resolution.
8. **Namespace local IDs and compare semantic keys — valid and open in P1A.**
9. **Keep generated artifacts derived-only and synchronized with sources —
   valid and satisfied.**
10. **Treat temporary evidence as exact test state with cleanup proofs — valid,
    though eliminating P1's temporary writer is simpler than hardening it.**

## Independent findings

### Filing and readiness are conflated

The repeated “before filing/readying” protocol combines steps that occur at
different times:

1. `gh issue create --blocked-by` can create the successor and dependency edge
   in one operation, or the edge can be added immediately afterward;
2. the successor and its edge can only be retrieved and verified after that
   creation operation;
3. the predecessor's landed merge commit cannot be known until after
   implementation and merge; and
4. the successor can only then pass its implementation-readiness gate.

Define initial body construction, create-with-edge, post-create verification,
later merge-identity backpatch, and implementation readiness separately. This
also resolves P2's impossible forward P3 URL requirement without placeholders.

### P1's temporary writer is avoidable

P1 and P1A deliberately change no guide source or generated artifact bytes, and
P2 requires both sources and all four derived artifacts to land together. P1
can therefore make the build read-only and fail on generation drift until P1B
introduces the final writer. Removing the temporary synchronizer would remove:

- a temporary write-enabled job and token;
- its action role and credential checks;
- exact-lease push code;
- a temporary evidence workflow/branch; and
- cleanup/absence drills for code that P1B immediately replaces.

This is a smaller and safer P1/P1B boundary than implementing two writers in
sequence.

### P1 still derives authoritative inputs from the ambient current directory

The baseline generator names `STYLE_GUIDE.md`, `STYLE_GUIDE_RATIONALE.md`, and
all four destinations as relative strings. P1 rejects relative final
destinations but does not explicitly change the main entry point to construct
the absolute mapped destinations, and it does not close the two source paths at
all. Derive the repository root from the script's fixed
`.github/workflows` location, require the two exact tracked ordinary source
files, and construct all four mapped destinations from that root. Otherwise the
new helper either rejects the script's own current calls or an implementer
retains current-directory authority outside the helper.

### Workflow-policy fixture and manifest-evidence ownership is unclear

P1's exact eight-file scope names no fixture or pinned-manifest snapshot files,
yet it requires tracked positive/negative workflow copies, reviewed manifest
defaults, and deterministic offline validation over explicit manifest paths.
State whether the complete fixture catalog and expected manifest/default
records are embedded in `Validate-WorkflowPolicy.mjs`, stored as separately
tracked files (which changes scope), or retained only as external governed
evidence. The validator cannot both require explicit upstream manifest files
and run offline everywhere unless their source and identity are defined.

### Production time must not be caller-spoofable

P3 correctly injects `now` into the pure audit core for deterministic fixtures.
The production entry point should obtain current UTC time from its trusted
runtime and offer no caller-controlled clock override, just as the production
Node-policy CLI should not accept a caller-supplied observed version. Retain
time injection only on the pure test API.

### P3 lacks a named external Node-policy case manifest

The issue specifies 19 `NODE-*` rows but does not include the criticism's
proposed `node-policy-cases.json` in affected files or name another single
authoritative catalog. Embedding copies in the hook harness, workflow, and
module would recreate drift. Add one tracked immutable case manifest, or state
which one existing file is its sole owner and make every consumer validate
against it.

### P3 does not close ambient npm and Corepack configuration

Pinning npm's executable does not pin its behavior. npm reads command-line
flags, every `npm_config_*` environment variable, project/user/global/built-in
configuration files, and defaults. Those inputs can change the audit registry,
failure threshold, submitted dependency tree, workspace scope, lockfile/tree
selection, cache behavior, and lifecycle execution. `NODE_ENV=production`
alone defaults `omit` to `dev`. Corepack likewise permits ambient variables to
disable project-spec enforcement or integrity checks and can load a different
environment file.

Define one closed invocation environment for install, audit, and verification:

- select the intended public registry, `audit-level`, include/omit/workspace,
  `package-lock-only`, script, and cache behavior explicitly;
- reject or sanitize unapproved `npm_config_*`, `NODE_ENV`, and
  `COREPACK_*` controls before invoking either tool;
- bind user/global configuration to known empty or reviewed files without
  overwriting the user's real configuration;
- make the intentionally permitted proxy/network variables and credential
  redaction behavior explicit; and
- capture the effective nonsecret configuration in evidence so a result is
  attributable to the reviewed command contract.

This is necessary for P3's claimed fail-closed reproducibility and should be
represented in the raw/process fixture catalog.

## Primary-source and local verification

- GitHub's dependency documentation requires an existing issue to be selected
  as the blocking issue, while `gh issue create --blocked-by` permits the
  predecessor to be attached during successor creation. This supports the
  create-then-retrieve/verify filing protocol, not a pre-creation verification
  step:
  <https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/creating-issue-dependencies>.
- GitHub documents that the `needs` context contains only direct dependencies
  and that matrix outputs are combined only when output names are unique:
  <https://docs.github.com/en/actions/reference/workflows-and-actions/contexts#needs-context>
  and
  <https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax-for-github-actions#using-job-outputs-in-a-matrix-job>.
- The pinned checkout manifest defaults `token` to `github.token` and describes
  temporary Git authentication, confirming that “without credentials” is
  false even when persistence is disabled:
  <https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml>.
- GitHub's status functions define `failure()` and `cancelled()` independently,
  supporting the exact `failure() && !cancelled()` diagnostic condition:
  <https://docs.github.com/en/actions/reference/workflows-and-actions/expressions#status-check-functions>.
- Microsoft documents that `[string]` parameter binding can convert an array to
  a string and that `[object]` or an untyped parameter preserves the supplied
  type:
  <https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_type_conversion>.
- `GetUnresolvedProviderPathFromPSPath` returns one provider-internal string and
  leaves wildcard characters unresolved; it is not a multi-match resolver:
  <https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.pathintrinsics.getunresolvedproviderpathfrompspath>.
- .NET documents that `WriteAllText` truncates an existing target. .NET's
  `File.Replace` page does not promise atomic old-or-new failure behavior, and
  the Windows `ReplaceFile` contract explicitly lists partial failure states:
  <https://learn.microsoft.com/en-us/dotnet/api/system.io.file.writealltext>,
  <https://learn.microsoft.com/en-us/dotnet/api/system.io.file.replace>, and
  <https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-replacefilea>.
- Current registry records used in this review:
  <https://registry.npmjs.org/yaml/2.9.0> and
  <https://registry.npmjs.org/npm/12.0.2>. Corepack documents hash-qualified
  `packageManager` descriptors, explicit `corepack npm`, strict project-spec
  behavior, and integrity controls:
  <https://github.com/nodejs/corepack>.
- npm documents that configuration comes from flags, `npm_config_*`
  environment variables, four npmrc layers, and defaults:
  <https://docs.npmjs.com/cli/v12/using-npm/config/>. Its audit contract
  confirms that `audit-level` controls the native exit threshold, `omit`
  changes the submitted tree, `NODE_ENV=production` defaults to omitting
  development dependencies, and `package-lock-only` changes the selected tree:
  <https://docs.npmjs.com/cli/v12/commands/npm-audit/>. Corepack separately
  documents ambient switches that bypass project-spec or integrity enforcement:
  <https://github.com/nodejs/corepack#environment-variables>.
- The four action release tags currently resolve to the SHAs in P1/P1B:
  checkout `v7.0.1`, setup-node `v7.0.0`, upload-artifact `v7.0.1`, and
  download-artifact `v8.0.1`. Their pinned manifests also contain the cited
  token/cache/archive/download controls.
- A local read-only audit rerun on 2026-07-29 under Node `26.5.1` and npm
  `11.7.0` reproduced exit `1`, report version `2`, seven vulnerability
  properties, fourteen object advisory records, two string graph edges, seven
  unique node paths, five high properties, and two moderate properties.

## Filing assessment

**The slate is materially stronger, but it is not ready to file unchanged.**
The sequence, issue boundaries, H1s, P labels, dependency-gate concept, and
shared-validator direction are sound. Every recommendation in
`slate-criticism.md` has been audited above. Adopt the criticism except where
this review denies or narrows it: the exact `File.Replace` failure invariant is
unsupported, additional P1A lifecycle enum names are conditional rather than
mandatory, and filing-time identity must be separated from later
implementation readiness.

Before filing, revise in this order:

1. **P1 — major revision.** Prefer removing the temporary writer entirely. In
   either design, close repository-root/source/destination authority, publish
   the first version, select the parser and lock producer, resolve fixture and
   manifest-evidence ownership, complete the reciprocal matrix, and do not
   promise the disproved `File.Replace` transaction invariant.
2. **P1A — targeted blocking revision.** Validate raw objects before binding,
   publish closed context/journal/result schemas, guarantee zero-call repeated
   disposal, publish initial versions, and add semantic reciprocal keys.
3. **P1B — targeted blocking revision.** Publish the complete job graph and
   least-privilege table, resolve explicit-input differences, correct
   diagnostic predicates and credential language, exercise the real writer on
   an isolated evidence ref, and close reviewed-head/landed-commit handoff.
4. **P2 — nearly ready after upstream corrections.** Repair only the impossible
   future P3 URL protocol and consume the final P1/P1A/P1B contracts.
5. **P3 — major revision.** Freeze npm/Corepack/Node identities, close ambient
   npm/Corepack configuration, split trusted production observations from pure
   fixture injection, include the Husky installer, validate raw native audit
   results, add raw/schema/process and Node-policy case catalogs, and bind
   exceptions to retained live issue evidence.

Prepare all five descriptions as a coherent slate, but treat issue creation,
dependency-edge verification, merge-identity backpatching, and implementation
readiness as separate lifecycle stages. Re-run package/action resolution and
the reciprocal review immediately before each implementation and merge.
