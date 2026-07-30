# Remediate Markdown lint dependency advisories and add npm update governance

## Summary

Upgrade the repository's Markdown tooling to maintained compatible releases,
declare and enforce a supported local Node policy, prove the actual installed
TerraformStyleGuide Husky hook, resolve or explicitly govern every npm audit
finding, and add review-only npm dependency updates.

This issue owns the final npm/runtime/hook/Dependabot state. It does not infer a
local support policy from a GitHub Action's internal runtime.

## Execution order and policy gate

Default order: implement after **Make state-version discovery and recovery
examples copy-safe with guarded identifiers** and against exact merged
T1/T1A/T1B/T2 commits.

Before using that default, record that repository policy permits the current
high-severity advisories to remain through the earlier work. If policy requires
zero current high-severity findings, implement this issue first, then rebaseline
T1, T1A, T1B, and T2 on its exact merge commit.

Record real GitHub dependencies in the selected order.

## Dated baseline, not acceptance

On 2026-07-29, `corepack npm audit --package-lock-only --json` under Node
26.5.0/npm 11.7.0 reported seven vulnerability **properties** (five high and
two moderate), 14 advisory objects in `via`, two package-name string edges in
`via`, and seven installed audit node paths. The seven property keys were:

- `brace-expansion`;
- `js-yaml`;
- `linkify-it`;
- `markdown-it`;
- `markdownlint-cli2`;
- `minimatch`; and
- `picomatch`.

This count is not approval and must not be copied into final acceptance.
Recompute from the implementation-time registry/lockfile. The durable finding
identity is exact `(Package, AdvisoryUrl)`; installed topology is a separate
exact package-keyed set of audit node paths. Do not invent an
advisory-to-node-path edge that npm's report does not supply.

## Affected files

Required files:

- `.github/workflows/build.yml`;
- `.github/workflows/package.json`;
- `.github/workflows/package-lock.json`;
- `.husky/pre-commit`;
- `.github/dependabot.yml`;
- `.github/workflows/markdownlint.yml`;
- `.github/workflows/Test-MarkdownToolingIntegration.ps1` — add;
- `.github/workflows/Check-NodePolicy.mjs` — add;
- `.github/workflows/Install-Husky.mjs` — add;
- `.github/workflows/node-policy-cases.json` — add;
- `.github/workflows/Validate-NpmAudit.mjs` — add; and
- `.github/workflows/Validate-WorkflowPolicy.mjs`.

Conditionally affected only when the selected package/API/config change
requires a reviewed compatibility edit:

- `.github/workflows/lint-nested-markdown.js`;
- `.github/workflows/.markdownlint.jsonc`.

Conditionally add one structured audit-exception file only if a residual
advisory is explicitly approved:

- `.github/workflows/npm-audit-exceptions.json`.

Determine the complete exact file set after package selection and before
editing. Use that set for working/staged gates. Do not preserve an earlier
issue's file count.

No source guide or generated guide artifact should change.

## Requested changes

### 1. Recompute the package and advisory inventory

From a clean clone and exact prerequisite commit, record:

- Node/npm executable paths and full versions;
- `package.json`;
- lockfile version and root dependency declarations;
- `corepack npm ls --all --json`;
- `corepack npm outdated --json`;
- `corepack npm audit --package-lock-only --json`;
- direct package release/engine requirements and changelogs;
- existing lint scripts/config/nested-lint imports;
- exact `.husky/pre-commit` behavior; and
- exact final T1B/T2 workflow roles/action allowlist.

Normalize the audit report into two sorted sets.

`Findings` contains one unique row per exact `(Package, AdvisoryUrl)`:

- package and advisory URL/source ID;
- severity;
- vulnerable range;
- direct parent(s);
- fix availability;
- chosen disposition; and
- evidence date/tool version.

`AuditNodePaths` contains one unique package key and a sorted unique array of
every installed npm node/dependency path for that package. Do not deduplicate
distinct paths under one package name, form a Cartesian product between
advisories and paths, or treat an aggregate package count as a complete
advisory set.

### 2. Select maintained compatible versions deliberately

For every direct dependency:

- identify the latest maintained release compatible with the repository's lint
  behavior;
- review every intervening major release;
- verify license/provenance and published package contents;
- verify `engines.node`;
- document required config/API changes; and
- justify retaining, upgrading, replacing, or removing the dependency.

Upgrade through explicit `package.json` edits and npm exactly `12.0.2`, selected
through the hashed Corepack project identity:

```json
"packageManager": "npm@12.0.2+sha512.b885e890b9418fa1693544d05f53e64f9a73ec194837d4258b15fecdd692347b1dd2a517b1b0cbaf9d31cd8e92c3b70956bd2ecc72833a57b4b3098f5bfa7943"
```

Every package operation is `corepack npm ...`; never invoke ambient `npm` or
`npx`, install npm globally, or add npm as a devDependency. Enable Corepack's
strict project/integrity behavior, assert exact `corepack npm --version`
`12.0.2`, hydrate in the job-local trusted install phase, then prove a second
clean install with network disabled/offline cache only. Re-resolve the dated
npm release/integrity immediately before implementation; drift requires an
explicit reviewed issue update, not an automatic “latest.”

Regenerate lockfile version 3 from a clean dependency state. Never use
`npm audit fix --force`, `--force`, `--legacy-peer-deps`, ignored engines, or
manual lockfile edits.

After selection, require:

- clean `corepack npm ci`;
- `corepack npm ls --all` with no invalid/extraneous/missing dependency;
- exact lockfile/root declaration agreement;
- unchanged script intent for outer/nested lint; and
- reproducible second clean install.

### 3. Declare the final Node policy

The finite reviewed policy is exactly:

| Line | Admitted interval | Floor evidence | Dated current evidence |
| --- | --- | --- | --- |
| Node 22 | `>=22.22.2 <23` | `22.22.2` | `22.23.2` on 2026-07-29 |
| Node 24 | `>=24.15.0 <25` | `24.15.0` | `24.18.1` on 2026-07-29 |

Set `engines.node` exactly to
`>=22.22.2 <23 || >=24.15.0 <25`. Node 20 is EOL; 21/23/25 are
unreviewed/non-LTS lines; Node 26 is current but not yet an admitted LTS line;
Node 27 and later are not silently accepted. There is no general even-major
rule.

Add `.github/workflows/Check-NodePolicy.mjs` as the dependency-free policy
implementation. It exports a pure version predicate for tests and provides a
CLI that always checks `process.versions.node`; the production CLI has no
version-override argument. Implement an explicit two-row major/floor/ceiling
table and accept canonical ASCII `x.y.z` only. Reject prefixes, signs, leading
zeros, missing/extra components, prerelease/build text, Unicode digits,
overflow, every below-floor patch, majors 20/21/23/25/26/27+, and any
unreviewed line.

`engines.node`, workflow setup-node cells, hook diagnostic, and the policy
module must encode the same admitted set. The structural workflow-policy
validator checks that equality.

In `.github/workflows/markdownlint.yml`:

- retain the preferred Node 24 job and disabled automatic setup-node cache;
- add/retain validation at the exact selected minimum;
- query the actual Node process in every job;
- use the selected npm consistently;
- run clean install, outer lint, nested lint, the helper harness, and T2 shell
  harness on the preferred line;
- run package install plus package/hook compatibility evidence on the minimum;
  and
- update the exact action workflow/role/count allowlist atomically for any
  matrix/job changes without changing action commits unless separately
  reviewed.

The T1B `build.yml` remains the sole external event owner. Retain ordinary and
Dependabot pull requests to `main`, `main` pushes, and `merge_group` when
enabled. Add a read-only UTC schedule and optional manual dispatch. Those two
events invoke only the callable Markdown validation plus a read-only terminal
result; candidate preparation, artifact upload, Windows candidate matrix,
promotion approval, and writer are explicitly gated off. Only a changed
push-to-`main` can reach the writer.

### 4. Fail early and clearly in the actual hook

Before testing installed tooling, `.husky/pre-commit` must:

1. preserve the existing staged-Markdown skip behavior;
2. require `node` to resolve as an application;
3. query the actual Node version before package/binary checks;
4. invoke the exact tracked `Check-NodePolicy.mjs` against the actual Node
   process before checking `node_modules`;
5. reject malformed, unsupported, EOL, and unreviewed future majors;
6. require `corepack` to resolve as an application only after Node policy
   passes and require its selected npm identity exactly;
7. print one stable diagnostic with observed version, accepted range, and
   remediation command/guidance;
8. retain GUI Git/version-manager guidance through
   `~/.config/husky/init.sh`;
9. preserve deliberate `--no-verify` guidance as a bypass disclosure, not a
   success path; and
10. invoke the unchanged logical outer then nested lint surfaces only through
    `corepack npm` after runtime/tooling validation.

Preserve exit classification:

- skip/pass is zero;
- lint findings reject the commit;
- tooling/config/runtime failures reject with a distinct stable reason; and
- unexpected npm/hook failures preserve the native status in diagnostics.

Do not replace TerraformStyleGuide's real full-lint hook with PSStyleGuide's
different programmatic staged-content API.

### 5. Install Husky through a tracked fail-closed state machine

Add `.github/workflows/Install-Husky.mjs` and set `prepare` exactly to
`node Install-Husky.mjs`; remove every `|| true` or equivalent swallowed
installation failure. The default state is **required install**. Skip is
permitted only under one of:

- `HUSKY_INSTALL_MODE=skip`;
- `HUSKY=0`; or
- `CI=true` with exact recorded reason `read-only-ci-install`.

Reject unknown/noncanonical values and conflicting state. Required mode
independently resolves the repository root, invokes the project-pinned Husky
through the selected Corepack npm environment, then verifies local
`core.hooksPath` equals exactly `.husky/_`, every required shim is an ordinary
non-link file, and the tracked `.husky/pre-commit` is the exact ordinary
versioned hook. Any install/invocation/verification error is nonzero.

Skip mode proves byte/config/filesystem immutability and reports the exact
selected skip source/reason; it never reports “installed.” Tests run only in
disposable repositories and include a real `git commit` that proves Git invokes
the installed hook. Add atomic cases for required success/failure, each skip,
unknown/conflicting variables, wrong root/hooksPath, missing/linked/untracked
shim/hook, and a hook that direct invocation would pass but Git does not call.

### 6. Add a tracked cross-platform integration harness

Create `.github/workflows/Test-MarkdownToolingIntegration.ps1` with
`#Requires -Version 5.1`, a recorded version, and an explicit path to the
repository under test.

The harness creates disposable repositories/indexes only. It must never mutate
the implementer's real index, hooks, config, or working tree.

For each supported platform/runtime combination, prove:

| ID | Required real behavior |
| --- | --- |
| `NPM-01` | clean install and `corepack npm ls --all` |
| `NPM-02` | outer lint success |
| `NPM-03` | nested lint success |
| `HOOK-01` | no staged Markdown skips without invoking npm |
| `HOOK-02` | staged valid Markdown passes |
| `HOOK-03` | temporary outer-rule violation rejects with exact rule/path |
| `HOOK-04` | temporary nested-fence violation rejects with exact rule/depth/path |
| `HOOK-05` | missing Corepack rejects as tooling failure |
| `HOOK-06` | broken lint configuration rejects distinctly from lint findings |
| `HOOK-08` | installed Husky hook invoked by a real `git commit` passes |
| `HOOK-09` | missing installed lint binary rejects as tooling failure |
| `HOOK-10` | lint tool startup failure rejects distinctly from lint findings |
| `HOOK-11` | real `git commit` invokes installed hook and a test violation rejects |

Replace the grouped `HOOK-07` family with one real installed-hook result per
exact platform/runtime cell:

| ID | Platform | Exact actual Node | Exact result |
| --- | --- | --- | --- |
| `HOOK-07-U-22-BELOW` | Ubuntu | `22.22.1` | reject before Corepack/npm/lint: below floor |
| `HOOK-07-W-22-BELOW` | Windows Git Bash | `22.22.1` | reject before Corepack/npm/lint: below floor |
| `HOOK-07-U-22-FLOOR` | Ubuntu | `22.22.2` | accept; pinned npm and lint run |
| `HOOK-07-W-22-FLOOR` | Windows Git Bash | `22.22.2` | accept; pinned npm and lint run |
| `HOOK-07-U-22-CURRENT` | Ubuntu | `22.23.2` | accept; pinned npm and lint run |
| `HOOK-07-W-22-CURRENT` | Windows Git Bash | `22.23.2` | accept; pinned npm and lint run |
| `HOOK-07-U-23` | Ubuntu | `23.0.0` | reject before Corepack/npm/lint: major unreviewed |
| `HOOK-07-W-23` | Windows Git Bash | `23.0.0` | reject before Corepack/npm/lint: major unreviewed |
| `HOOK-07-U-24-BELOW` | Ubuntu | `24.14.0` | reject before Corepack/npm/lint: below floor |
| `HOOK-07-W-24-BELOW` | Windows Git Bash | `24.14.0` | reject before Corepack/npm/lint: below floor |
| `HOOK-07-U-24-FLOOR` | Ubuntu | `24.15.0` | accept; pinned npm and lint run |
| `HOOK-07-W-24-FLOOR` | Windows Git Bash | `24.15.0` | accept; pinned npm and lint run |
| `HOOK-07-U-24-CURRENT` | Ubuntu | `24.18.1` | accept; pinned npm and lint run |
| `HOOK-07-W-24-CURRENT` | Windows Git Bash | `24.18.1` | accept; pinned npm and lint run |
| `HOOK-07-U-25` | Ubuntu | `25.0.0` | reject before Corepack/npm/lint: major unreviewed |
| `HOOK-07-W-25` | Windows Git Bash | `25.0.0` | reject before Corepack/npm/lint: major unreviewed |
| `HOOK-07-U-26` | Ubuntu | `26.5.1` | reject before Corepack/npm/lint: current major unreviewed |
| `HOOK-07-W-26` | Windows Git Bash | `26.5.1` | reject before Corepack/npm/lint: current major unreviewed |

Provision every exact runtime; these rows read the actual process version and
cannot use an override. Re-resolve dated `CURRENT` versions before
implementation; if changed, append new IDs and retire the old rows with a
recorded reason rather than changing their meaning.

`node-policy-cases.json` is the one closed manifest for policy-module,
policy-CLI, and installed-hook cases. Every row has exact `Id`, `Layer`,
`Platform`, `NodeVersionSource`, literal `Input`, `ExpectedExit`,
`ExpectedReason`, `ExpectCorepack`, `ExpectNpm`, and `ExpectLint`. IDs are
opaque; reject family/range/wildcard rows, duplicate/missing/unknown IDs, or
more than one result.

Give every direct pure input one `NODE-POLICY-###` ID: empty, whitespace,
`v` prefix, missing/extra component, leading zero, sign, prerelease, build
metadata, Unicode digit, overflow, Node 20/21, `22.22.1`, `22.22.2`,
`22.23.2`, `22.999.999`, `23.0.0`, `24.14.0`, `24.14.999`,
`24.15.0`, `24.18.1`, `24.999.999`, `25.0.0`, `26.0.0`,
`26.5.1`, and `27.0.0`. Give actual CLI checks separate
`NODE-CLI-###` IDs. Audit all remaining `NPM-*`, `HOOK-*`, and `AUDIT-*`
rows and split any family before evidence.

The same harness owns these append-only audit-validator IDs:

| ID | Fixture | Exact oracle |
| --- | --- | --- |
| `AUDIT-01` | clean audit, no exception file | pass |
| `AUDIT-02` | clean audit, exception file present | fail stale permission |
| `AUDIT-03` | residual audit, no exception file | fail unapproved findings |
| `AUDIT-04` | exact approved findings/topology | pass |
| `AUDIT-05` | new `(Package, AdvisoryUrl)` | fail with exact addition |
| `AUDIT-06` | removed approved finding | fail with exact stale removal |
| `AUDIT-07` | new package node path | fail with exact topology addition |
| `AUDIT-08` | removed approved node path | fail with exact stale topology |
| `AUDIT-09` | one second before expiration | pass |
| `AUDIT-10` | exactly at expiration | fail expired |
| `AUDIT-11` | one second after expiration | fail expired |
| `AUDIT-12` | malformed timestamp | fail schema |
| `AUDIT-13` | unknown property | fail closed schema |
| `AUDIT-14` | duplicate finding identity | fail duplicate |
| `AUDIT-15` | missing owner | fail governance |
| `AUDIT-16` | invalid follow-up issue URL | fail governance |
| `AUDIT-17` | non-JSON audit report | fail audit input |
| `AUDIT-18` | equivalent input in different order | pass with identical normalization |
| `AUDIT-19` | real report captured after clean `corepack npm ci` | CLI result matches current governed state |
| `AUDIT-20` | wrong schema version | fail schema |
| `AUDIT-21` | wrong property type | fail schema |
| `AUDIT-22` | duplicate canonical advisory URL identity | fail duplicate |
| `AUDIT-23` | duplicate audit package property | fail duplicate |
| `AUDIT-24` | duplicate installed node path | fail duplicate |
| `AUDIT-25` | missing follow-up fields | fail governance |
| `AUDIT-26` | missing approval identity | fail governance |
| `AUDIT-27` | truncated JSON audit report | fail audit input |

Deterministic fixture cases import the pure validator core and inject the UTC
instant; the production CLI has no clock override. `AUDIT-19` invokes the exact
tracked CLI. Every row asserts exit class, normalized additions/removals,
exception-file state, input immutability, and stable diagnostics. The harness
fails on a missing, duplicate, unexpected, or multiply emitted applicable ID.

Negative fixtures are created temporarily in the disposable repository and
removed in `finally`; do not add repository-wide lint violations as tracked
files.

At least one case must:

1. run clean install so Husky installs its real hook integration;
2. stage test-owned Markdown;
3. invoke `git commit` without directly calling `.husky/pre-commit`;
4. prove Git invokes the installed hook;
5. prove pass or rejection and expected index/commit state; and
6. prove cleanup leaves the source repository untouched.

Run the harness on:

- Ubuntu with selected minimum Node;
- Ubuntu with preferred Node 24;
- Windows/Git Bash with selected minimum Node; and
- Windows/Git Bash with preferred Node 24.

Windows PowerShell 5.1 may orchestrate the harness, but the actual hook executes
through the Git/Husky shell environment. Record exact shell, Git, Node, npm,
package, and harness versions.

### 7. Resolve or govern every advisory

Run after clean installation:

```text
corepack npm audit --package-lock-only --json
```

The preferred final result is zero vulnerabilities at all severities. Also run
the repository-approved human-readable audit and capture native exit codes.

Create `.github/workflows/Validate-NpmAudit.mjs`. Its exported pure core accepts
an audit object, optional exception object, and injected UTC instant for
fixtures. Its production CLI accepts exact report/exception paths and the
captured native audit status, always obtains actual current UTC, and has no
clock-bypass argument. It emits one canonical summary and stable exit classes
for:

- CLI/input/schema failure;
- unapproved or topology-mismatched residuals; and
- expired/stale governance.

The callable workflow captures
`corepack npm audit --package-lock-only --json` to a protected temporary report without
letting strict shell behavior lose the native status, then invokes this exact
validator. Non-JSON/truncated/network/tool failure is an audit-input failure,
not an approved residual. Never hide risk with `--audit-level`.

If a residual finding cannot be removed without a disproportionate or
incompatible change, the optional exception file uses one versioned closed
schema and contains exactly:

- `schemaVersion: 1`;
- `findings`, sorted and unique by `(package, advisoryUrl)`, each with:
  - package, canonical advisory URL, and source ID;
  - severity, vulnerable range, and CVSS when supplied;
  - repository-specific exploitability analysis;
  - explicit compensating controls;
  - accountable owner;
  - canonical whole-second RFC 3339 UTC `createdAt`, `approvedAt`, and
    `expiresAt` values ending in `Z`;
  - canonical follow-up issue URL/number, current scope hash, verification
    time, and retained filing-evidence hash under the exact fields below;
  - explicit approval identity; and
  - evidence that no fixed compatible package tree exists; and
- `auditNodePaths`, sorted and unique by package, each containing the exact
  sorted unique installed paths for that package.

Do not create advisory/path pairs. The validator requires exact equality
between current normalized `Findings` and approved findings and exact equality
between current and approved package-keyed node-path sets.

Approval time is bounded:

- `createdAt` and `approvedAt` must represent the same reviewed approval
  instant;
- `expiresAt` must be later than that instant and no later than exactly
  30 × 24 hours afterward;
- expiration is exclusive and the record fails when `now >= expiresAt`; and
- renewal requires new clean-install/audit/fix-availability evidence, updated
  analysis/controls/follow-up status, and a new accountable approval. Changing
  only timestamps is forbidden.

#### Closed audit report-v2 and native-status contract

The orchestration invokes exactly
`corepack npm audit --package-lock-only --json` with no `--audit-level`.
Capture stdout and stderr separately into protected bounded streams, preserve
the process outcome as one of `exit`, `signal`, `timeout`, or `startFailure`,
and pass the exact native exit plus stdout file to the validator. Do not merge
streams, parse console prose, or let shell strict mode erase the exit.

Before `JSON.parse`, enforce an 8-MiB raw stdout maximum, BOM-less strict UTF-8,
one complete JSON value/trailing-whitespace only, depth/count/string/number
ceilings, and duplicate-key detection with a reviewed JSON tokenizer. The
closed valid report has `auditReportVersion: 2`, `vulnerabilities`, and
`metadata` only. Every vulnerability property has exact keys/types for
`name`, `severity`, `isDirect`, `via`, `effects`, `range`, `nodes`, and
`fixAvailable`; its property key equals `name`.

`via` contains only:

- an advisory object with closed
  `source`, `name`, `dependency`, `title`, `url`, `severity`, `cwe`,
  `cvss { score, vectorString }`, and `range`; or
- a package-name string that is a real edge to another vulnerability property.

`effects` and package-string `via` edges are reciprocal; referenced packages
exist. `nodes` is a sorted unique installed-path set. `fixAvailable` is exactly
`false`, `true`, or closed `{name,version,isSemVerMajor}`. Metadata has closed
nonnegative safe-integer severity counts
`info|low|moderate|high|critical|total` and dependency counts
`prod|dev|optional|peer|peerOptional|total`; reconcile totals/severity
properties without inventing advisory-to-node Cartesian edges.

The decision table is exact:

| Native outcome | Parsed graph | Decision |
| --- | --- | --- |
| exit `0` | valid and empty | continue; exception file must be absent |
| exit `0` | nonempty | status/report mismatch |
| exit `1` | valid and nonempty | evaluate exact exception policy |
| exit `1` | empty or malformed | status/report/schema failure |
| other exit, signal, timeout, start failure | any | process/tool failure; never governed residual |

Validator exit classes are:
`0 PASS`, `20 PROCESS_TOOL`, `21 AUDIT_INPUT_JSON`,
`22 AUDIT_REPORT_SCHEMA`, `23 AUDIT_STATUS_MISMATCH`,
`24 AUDIT_POLICY_MISMATCH`, and `25 AUDIT_GOVERNANCE`. Each fixture expects
one exact class, normalized Finding set, package-keyed AuditNodePaths set,
exception state, and safe diagnostic.

Record the dated baseline as four separate observations: seven vulnerability
properties (the seven package keys listed above), 14 advisory objects, two
package-string graph edges, and seven installed node paths. Store Node/npm/
Corepack versions, exact argv/native outcome, report SHA-256, and the exact
four sets. These numbers describe the 2026-07-29 input only and are prohibited
as acceptance constants.

#### Canonical follow-up reference and filing evidence

A residual exception's finding adds exact closed fields:
`followUpIssueUrl`, `followUpIssueNumber`, `followUpScopeSha256`,
`followUpVerifiedAt`, and `followUpEvidenceSha256`. Parse the URL and require
serialized equality to
`https://github.com/franklesniak/TerraformStyleGuide/issues/<number>`:
lowercase canonical HTTPS host, exact owner/repository/path case, no
credentials/port/query/fragment/trailing slash/encoding/dot segment. Number is
a JSON safe integer whose canonical decimal matches `[1-9][0-9]*` and the URL
exactly; reject `/pull/` and every alternate repository/form.

`followUpScopeSha256` hashes a versioned canonical JSON array of the exact
sorted current `(Package, AdvisoryUrl)` identities assigned to that issue.
Every finding is covered exactly once (or by one explicitly shared issue scope)
with no missing/extra/stale identity. The issue body contains reviewed marker
`npm-audit-findings-sha256: <same-lowercase-64-hex>` plus owner, remediation
objective, and target date.

At initial approval and every renewal, an authorized maintainer performs one
live GitHub API/UI read after filing and retains a bounded evidence record:
endpoint/time/actor, repository, canonical URL/number, immutable database ID/
node ID, `state=open`, absence of `pull_request`, creation/update times,
owner/assignee, title/body hash, scope marker, and current scope hash. Canonical
record SHA-256 equals `followUpEvidenceSha256`;
`followUpVerifiedAt` equals its time and is in the same approval session within
the at-most-30-day window. Retain no token/header/arbitrary response/email/
signed URL.

The pure validator checks only offline URL/number grammar, scope coverage,
canonical timestamps/hashes, evidence-reference presence/freshness, and
exception policy. It performs no network access or issues permission and says
only “offline reference/evidence fields valid,” never “issue exists/open.”
A reviewer independently validates the retained record. Closed/transferred/
deleted/converted/unowned/scope-changed issues require remediation or a new
filed/reapproved issue—not a timestamp/hash-only edit.

Fixtures separately cover offline URL/number/scope/evidence errors and retained
external records for nonexistent, pull-request, closed, wrong repository/ID,
missing owner, changed marker/body, and valid open issue.

Reject unknown/missing properties, wrong types, noncanonical/duplicate URLs or
paths, duplicate finding/package identities, malformed timestamps, empty
owner/follow-up/approval, invalid issue URLs, missing or extra findings,
missing or extra node paths, expired entries, and any exception file when the
normalized audit is empty. The file is absent when no residual exists; never
create a blank mechanism “for later.”

Run this same validator:

- for every ordinary and Dependabot pull request to `main`;
- for merge queue when enabled;
- for every push to `main` before writer authorization;
- on the read-only UTC schedule; and
- on optional read-only manual dispatch.

The schedule/manual path invokes no candidate, artifact, approval, or writer
job. Scheduled failure creates visible evidence and requires a normal
issue/pull-request fix; it never auto-edits, auto-approves, or auto-merges.

### 8. Establish final npm Dependabot governance

Change `.github/dependabot.yml` to normalized exact content with two and only
two update entries:

1. `github-actions` at `/`; and
2. `npm` at `/.github/workflows`.

Both use the approved review-only schedule. Reject duplicate/extra ecosystems,
wrong directories, ignored security updates without approval, and every
automatic approval/merge behavior.

Dependabot proposals require normal CI, package/changelog/engine review,
lockfile review, actual-hook integration evidence, and audit normalization.
They do not bypass the action SHA allowlist or residual-risk process.

This two-entry state replaces T1's intermediate one-entry assertion.

### 9. Revalidate merged behavior and declare supersession

Classify prior controls:

Enduring behavior that must remain green:

- deterministic generator and LF/BOM policy;
- helper/context/harness stable IDs and cleanup behavior;
- immutable artifact ID/digest transport;
- action pins/permissions/events;
- full Windows matrices and exact-lease writer;
- T2 exact-block state-recovery harness;
- outer/nested lint semantics; and
- generated artifact bytes unless a reviewed lint fix is separately required.

Final-state assertions replaced here:

- Node/package/contributor floor;
- package and lockfile content;
- hook runtime guard;
- Markdown job runtime matrix; and
- exactly two Dependabot entries.

One-time implementation gates superseded here:

- earlier issue-specific affected-file counts; and
- T1's one-entry Dependabot path gate.

Do not describe enduring security behavior as superseded.

## Validation

From fresh clones and clean dependency state:

1. run selected minimum and preferred Node versions;
2. record actual Node path/version, Corepack path/version, exact selected
   `npm@12.0.2` version, and verified package-manager descriptor/integrity;
3. scope/restore `CI=true` around `corepack npm ci`;
4. hydrate once in the job-local trusted phase, then run a second
   `corepack npm ci` from clean `node_modules` with network disabled;
5. run `corepack npm ls --all`;
6. run both lint scripts;
7. run every `NPM-*`, `HOOK-*`, and `AUDIT-*` integration-harness ID;
8. perform at least one real installed Husky `git commit` on each OS family;
9. capture native status plus normalized and human-readable audit;
10. invoke the exact tracked audit validator and validate exceptions, if any;
11. validate exact two-entry Dependabot content;
12. run the structural workflow validator, including schedule/manual
    no-writer fixtures and Node-policy equality;
13. run T1/T1A/T1B/T2 complete evidence;
14. regenerate and require unchanged four output blobs;
15. require exact changed/staged path equality to the final computed T3 set;
    and
16. rerun from staged content with no additional diff.

Capture pull-request evidence for every required job/cell and a post-merge push
showing the artifact pipeline remains correct.

## Acceptance criteria

- [ ] Final direct packages are maintained, justified, and installed
      reproducibly without force flags.
- [ ] `packageManager` equals the exact hashed `npm@12.0.2` descriptor;
      every package command uses Corepack and the second install is offline.
- [ ] Lockfile version/tree exactly matches `package.json`;
      `corepack npm ls --all`
      passes.
- [ ] `engines.node` is exactly
      `>=22.22.2 <23 || >=24.15.0 <25`; policy module, CLI, workflow,
      and hook enforce the same finite table.
- [ ] No ordinary validation relies on EOL Node 20.
- [ ] Malformed, below-minimum, odd/intervening, admitted 22/24 boundaries, and
      the first unreviewed future even major have explicit passing or rejecting
      oracles.
- [ ] The exact outer and nested lint behaviors remain correct.
- [ ] Every tracked integration ID passes on minimum/Node 24 and both OS
      families.
- [ ] At least one real clean-installed Husky hook is invoked by `git commit`.
- [ ] The tracked fail-closed installer is the exact `prepare` command;
      required installation verifies `.husky/_`, and only the three closed
      skip states may avoid installation without mutation.
- [ ] Temporary outer/nested violations and tooling/runtime failures reject for
      the intended reason.
- [ ] One tracked validator governs every local/hosted audit invocation with
      stable input/schema, mismatch, and expiry exit classes.
- [ ] Audit orchestration applies the exact 8-MiB/strict-UTF-8/duplicate-key/
      closed-report-v2 graph schema and the explicit native
      `0`/`1`/other/signal/timeout/start-failure decision table.
- [ ] The audit is zero with no exception file, or current
      `(Package, AdvisoryUrl)` findings and package-keyed node paths exactly
      equal one valid, approved, unexpired, at-most-30-day exception state.
- [ ] Every `AUDIT-*` clean, residual, topology, schema, duplicate, and
      before/at/after-expiry oracle passes.
- [ ] Offline follow-up URL/scope/evidence validation is distinguished from
      the reviewed live filing record that proves the issue existed, was open,
      and was correctly scoped at initial approval/latest renewal.
- [ ] Every policy/hook platform/version case has one immutable ID, one
      literal input/oracle, and exactly one reconciled result; no family ID
      remains.
- [ ] Ordinary/Dependabot PR, merge-group, `main` push, schedule, and manual
      event fixtures all invoke the same validator; schedule/manual cannot
      reach publication.
- [ ] Dependabot contains exactly GitHub Actions `/` and npm
      `/.github/workflows`, review-only.
- [ ] Exact action pins/roles, permissions, triggers, helper, artifact,
      matrices, writer, and T2 shell evidence remain green.
- [ ] Generated artifacts remain byte-stable unless separately reviewed.
- [ ] The final affected-file gate is recomputed and exact.

## Non-goals

- Upgrading external GitHub Actions without a separate provenance review.
- Changing state-recovery or destructive-state guidance.
- Replacing the full-lint Terraform hook with a staged-content API.
- Automatically approving/merging dependency updates.
- Accepting permanent or ownerless advisory exceptions.
- Forming unproved advisory-to-node-path pairs.
- Using `--force`, `npm audit fix --force`, or engine bypasses.

## References

- [npm audit](https://docs.npmjs.com/cli/commands/npm-audit/)
- [npm package.json engines](https://docs.npmjs.com/cli/configuring-npm/package-json#engines)
- [Git hooks](https://git-scm.com/docs/githooks)
- [Husky](https://typicode.github.io/husky/)
- [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2)
- [Node.js release status](https://nodejs.org/en/about/previous-releases)
- [Dependabot options](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference)
