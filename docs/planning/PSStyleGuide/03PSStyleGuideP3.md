# Remediate Markdown lint dependency advisories and add npm update governance

## Summary

Upgrade the Markdown tooling under `.github/workflows` to deliberately reviewed
maintained releases; enforce one hash-qualified npm and two exact supported
Node/Corepack cells; preserve full, nested, and staged lint semantics; harden
Husky installation and the real hook; validate raw npm-audit process bytes;
govern any temporary residual finding with a live issue; and add review-only
npm updates.

P3 owns the final Node/Corepack/npm/package/hook/audit/Dependabot policy. It
does not weaken P1/P1A/P1B publication controls or change P2 content.

## Consumed landed contracts and order

P3 follows P1, P1A, P1B, then P2. Create P3 with P2's permanent URL and real
blocked-by edge; retrieve both issues and verify repository, number, title,
canonical URL, and relationship.

Before coding, record for all four predecessors:

- permanent issue/PR URLs, reviewed head/base commits, merge methods, landed
  commits/trees, and exact contract paths/schema/interface versions;
- generator/candidate/catalog/workflow-policy/path-verifier versions/hashes;
- final action/input/default and job-graph contract;
- retained candidate/attestation/approval/writer/credential/evidence-ref proof;
- P2 version, six-path source/artifact hashes, and no-change post-merge run;
- all reciprocal matrices without unresolved blockers; and
- P1's advisory-risk decision and exact authorized baseline.

Compare landed state with this issue and rerun enduring evidence. A missing
dependency, landed drift, expired/refused risk decision, critical/materially
worse audit finding, or out-of-sequence package-graph change stops for issue
review/rebaseline. Do not perform a partial dependency update elsewhere.

## Dated observation, not acceptance

On 2026-07-29, an inspection under Node `26.5.0`/npm `11.7.0` returned npm
audit report v2, native exit 1, five high and two moderate vulnerability
properties: `brace-expansion`, `js-yaml`, `linkify-it`, `markdown-it`,
`markdownlint-cli2`, `minimatch`, and `picomatch`. Property count, advisory
object count, and installed-node-path count are different units. That runtime
is not a supported P3 cell. Fresh raw evidence and exact
`(Package, AdvisoryUrl)` plus package-keyed path topology govern acceptance.

## Affected files

Required paths:

- `.github/workflows/build.yml`;
- `.github/workflows/markdownlint.yml`;
- `.github/workflows/Validate-WorkflowPolicy.mjs`;
- `.github/workflows/workflow-policy-contract.json`;
- `.github/workflows/workflow-policy-cases.json`;
- `.github/workflows/Check-NodePolicy.mjs` — add;
- `.github/workflows/node-policy-cases.json` — add;
- `.github/workflows/Run-NpmPolicy.mjs` — add;
- `.github/workflows/Validate-NpmAudit.mjs` — add;
- `.github/workflows/Verify-NpmAuditExceptions.mjs` — add;
- `.github/workflows/npm-audit-policy-cases.json` — add;
- `.github/workflows/package.json`;
- `.github/workflows/package-lock.json`;
- `.github/workflows/install-husky.mjs`;
- `.github/workflows/lint-staged-markdown.mjs`;
- `.github/workflows/Test-LintStagedMarkdown.ps1` — add;
- `.github/workflows/Test-NpmAuditPolicy.ps1` — add;
- `.husky/pre-commit`;
- `.github/dependabot.yml`; and
- `.npmrc` — add.

Conditionally add `.github/workflows/npm-audit-exceptions.json` only for a real
approved residual. When audit is clean, that path must be absent.

After package selection and audit disposition, compute and freeze the exact
path set. Use P1's landed raw path verifier before/after staging and after the
final rerun. A newly necessary path requires documented review, a recomputed
set, and restarted scope validation. Do not change guides/artifacts, generator,
candidate implementation/catalog, P1B writer behavior, or Markdown config
unless an unavoidable selected-package compatibility change is separately
added to scope and justified.

## Frozen runtime and manager policy

Use this proposed current tuple, re-resolved at implementation and pre-merge:

| Role | Exact identity |
| --- | --- |
| `packageManager` | `npm@12.0.2+sha224.4c4977784242293bf5a4f80d28aab2d001ba8a7a4532285591a158aa` |
| npm registry integrity | `sha512-uIXokLlBj6FpNUTQX1PmT5pz7BlIN9QlixX+zdaSNHsd0qUXsbDLr50xzY6Sw7cJVr0uzHKDOle0swmPW/p5Qw==` |
| finite `engines.node` | `>=22.22.2 <23` &#124;&#124; `>=24.15.0 <25` |
| compatibility cell | Node `22.23.2`, bundled Corepack `0.34.6` |
| preferred/sole lock producer | Node `24.18.1`, bundled Corepack `0.35.0` |
| npm engine declaration | exact `12.0.2` |

The npm tarball is
`https://registry.npmjs.org/npm/-/npm-12.0.2.tgz`, observed at 3,045,132
bytes. Every package operation uses explicit Corepack dispatch through F30's
wrapper; never bare `npm`, `npx`, global installation, `corepack use`, or an
open-ended Node range.

At both freeze gates query the official Node distribution index, exact
Node-tag Corepack package, npm registry/tarball, all selected package releases,
and applicable security metadata. Stop on a new eligible security patch,
engine/tag/tarball/integrity mismatch, Corepack behavior change, or selected
package security change. Update the complete tuple, policy cases, action
roles, package/lock, and evidence atomically. Node `24.18.1` alone produces
lockfile v3; Node `22.23.2` must prove a byte-identical no-op.

Both cells record `process.execPath`, `process.versions.node`, bundled
Corepack version/source, `corepack npm --version`, manager descriptor/tarball
digests, clean install/tree/audit/lint/hook results, and lock no-op. P3
explicitly supersedes P1's interim Node `24.18.1`/npm `11.16.0` tuple while
preserving its historical evidence.

## Closed npm/Corepack invocation boundary

All operations go through dependency-free
`.github/workflows/Run-NpmPolicy.mjs`. It exposes only fixed functions/closed
operation names for `ci`, `audit`, `lock-noop`, `run-lint`, and `run-test`;
there is no caller executable, argument array, root, registry, config, cache,
script, include, workspace, timeout, or policy override.

The wrapper derives the repository and job-owned temporary roots from its own
location. It invokes the current `process.execPath` with the ordinary non-link
bundled Corepack JavaScript entry point at the fixed Node-distribution-relative
path, verifies the package version equals the selected cell, and passes `npm`
plus a fixed argument vector. It never resolves npm/npx/Corepack/Node through
PATH.

Build the child environment from a closed allowlist. Remove case-insensitively
every inherited `npm_config_*`, `COREPACK_*`, `NODE_OPTIONS`, `NODE_ENV`,
manager/path override, and npm/Corepack auth/token/password/cert/key value.
Set:

- `COREPACK_ENABLE_STRICT=1`;
- `COREPACK_ENABLE_PROJECT_SPEC=1`;
- `COREPACK_ENV_FILE=0`;
- `COREPACK_DEFAULT_TO_LATEST=0`;
- `COREPACK_ENABLE_UNSAFE_CUSTOM_URLS=0`;
- `COREPACK_ENABLE_DOWNLOAD_PROMPT=0`;
- fresh job-owned `COREPACK_HOME`; and
- exact `COREPACK_NPM_REGISTRY=https://registry.npmjs.org`.

Leave `COREPACK_INTEGRITY_KEYS` unset so bundled trusted keys remain
authoritative; any inherited empty/zero/custom value is removed and recorded
as hostile ambient input. Set `COREPACK_ENABLE_NETWORK=1` only for fixed
manager fetch/install/audit operations and `0` for hydrated lint/test/no-op.

Create fixed empty ordinary user/global npmrc files and pass their exact paths
as CLI `--userconfig`/`--globalconfig`. The tracked root `.npmrc` contains
only the reviewed closed tree-shaping policy:

```ini
allow-directory=none
allow-file=none
allow-git=none
engine-strict=true
install-links=false
strict-peer-deps=true
workspaces=false
```

Reject comments, unknown/duplicate/interpolated/scoped-registry/auth keys.
Fixed CLI settings include official HTTPS registry, prod/dev/optional/peer
inclusion, workspaces false, matching strict-peer/install-link behavior,
package-lock-only audit, audit threshold low, fresh per-operation cache,
prefer-online where network is required, no fund/update-notifier/progress/
color, and noninteractive behavior. Clean CI install uses `--ignore-scripts`;
the reviewed Husky lifecycle is tested separately.

Only `HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY`, and an explicitly reviewed
ordinary CA-file path may cross as transport settings. Validate scheme/path
and never record values. They cannot change registry, credentials, dependency,
script, audit, or manager policy. Evidence records identities, operation,
argument/config digests, cache/network mode, nonsecret proxy-presence
booleans, and effective allowlisted config.

Fixtures seed hostile casing/values in every npm/Corepack control, user/global/
project config, PATH, Node options, credentials, cache state, registry, scripts,
includes, workspaces, and proxy/CA paths and require identical effective
policy or closed rejection.

## Node policy authority

`Check-NodePolicy.mjs` is dependency-free and exports:

- deeply frozen, versioned `NODE_POLICY` for exactly
  `>=22.22.2 <23 || >=24.15.0 <25`;
- pure fixture-only
  `evaluateNodeVersionForFixture(observed, policy)`; and
- zero-parameter `evaluateCurrentNode()`, which reads
  `process.versions.node` exactly once and evaluates only `NODE_POLICY`.

When run as a CLI it accepts no positional argument, time/environment/file
policy, or version override. It calls `evaluateCurrentNode`, emits one bounded
canonical result, and uses closed supported/unsupported/malformed-internal/
tool-failure exits. `lint-staged-markdown.mjs` imports only
`evaluateCurrentNode`; the hook calls the no-argument CLI before resolving
Corepack/npm or `node_modules`.

Add one authoritative `.github/workflows/node-policy-cases.json`. Its closed
schema gives every case a unique `PS-P3-NODE-*` ID, unique lowercase semantic
key, raw JSON type/value, expected normalized value/category/exit, requirement
keys, and applicable pure/CLI/hook/lint/workflow consumers. Unknown, duplicate,
unused, orphaned, or consumer-divergent cases fail.

Cover both exact floors, current cell patches, boundary patches below majors
23/25, gaps 23/25, future 26+, below-floor values, and malformed non-string,
empty, whitespace, prefix/sign, missing/extra components, leading zero,
prerelease/build, exponent/hex/Unicode digits, overflow, NUL/newline, and
trailing data. Structural cases mutate each frozen policy field, pass CLI
arguments, attempt environment/file overrides, import the fixture API from
production, or add a second observed-version read. Both cells consume every
synthetic case; the real CLI proves only its actual process plus no-argument
behavior.

## Husky installer and real hook

Make `.github/workflows/install-husky.mjs` a first-class tested surface. It
accepts no arguments, derives the repository from its location, and uses this
exact decision precedence:

1. exact `HUSKY=0` → `SkippedExplicitOptOut`;
2. exact `NODE_ENV=production` → `SkippedProduction`;
3. exact `CI=true` without `HUSKY=0` →
   `CiRequiresExplicitHuskyPolicy` failure;
4. absent/empty `CI` or exact `CI=false` → install; and
5. any unexpected nonempty control value → closed failure.

Every skip/install/failure emits one stable bounded status; no successful skip
is silent. Before install, validate fixed package root, package/lock, `.git`,
and tracked `.husky` as expected ordinary non-link paths. Only then import the
exact lock-resolved Husky, change to fixed root, invoke once, and treat a throw
or nonempty return message as failure. Verify local `core.hooksPath` equals
`.husky/_`, generated support exists, and tracked hooks remain ordinary files.
Never change user-global Git config.

Expose a named pure fixture decision function while production reads its own
environment once. Test all precedence permutations, malformed values, wrong
starting directory, import/call/nonempty-message failures, missing/linked
inputs, and postcondition failures in disposable Git repositories. Run one real
`prepare` lifecycle install and one explicit `HUSKY=0` clean-CI install.
Workflows intending to skip set `HUSKY=0`; they never rely on ambient `CI`.

The hook:

1. skips no-staged-Markdown with zero npm call;
2. resolves actual `node`, then invokes the no-argument Node-policy CLI before
   Corepack/npm or `node_modules`;
3. emits stable observed/accepted/remediation categories;
4. preserves GUI Git/version-manager guidance through
   `~/.config/husky/init.sh`;
5. calls the programmatic staged-content API only after runtime/tool checks;
6. distinguishes lint, config/startup, tooling, and unexpected native failure;
   and
7. discloses `--no-verify` as a deliberate bypass, never a successful check.

Do not replace PSStyleGuide's staged-only API with a full-repository hook.

`Test-LintStagedMarkdown.ps1` has `#Requires -Version 5.1`, first version
`1.0.<UTC implementation YYYYMMDD>.0`, and uses disposable repositories/
indexes only. Its namespaced catalog/evidence covers clean tree, outer/nested
lint, no-staged skip, valid staged pass, outer/nested violations with exact
rule/path, staged-versus-worktree isolation, missing tool, broken config,
Node-policy delegation, installer branches, and a real clean-installed Husky
hook invoked by `git commit`. Run Ubuntu and Windows/Git Bash for both exact
Node cells; record shell/Git/Node/Corepack/npm/package/tool versions and leave
the source repository unchanged.

## Raw npm-audit boundary

`Validate-NpmAudit.mjs` production mode accepts no report, executable,
arguments, root, timeout, clock, policy, or exception override. It derives the
fixed repository and imports only the wrapper's fixed audit invocation
descriptor. `Validate-NpmAudit.mjs` itself calls `child_process.spawn`, owns
the native lifecycle and both raw streams, and launches exact
`npm audit --package-lock-only --json` without a shell; the wrapper never
launches audit on its behalf. Use fixed 120-second, 4-MiB stdout, and 256-KiB
stderr limits; hidden Windows console; and wait for stream close.

Classify in exact precedence:

`StartFailed`, `TimedOut`, `Signaled`, `StdoutLimitExceeded`,
`StderrLimitExceeded`, `Exited`, then report result.

For `Exited`, only numeric 0 or 1 is recognized; every other code is
`AuditToolFailed`. Exit 0 must pair with a valid report whose computed
threshold count is zero. Exit 1 must pair with at least one threshold finding
before exceptions and may pass only when every finding has an exact valid
exception. Every other pairing is `NativeReportMismatch`. Exceptions never
convert transport/parser/schema/tool failure into success.

Before `JSON.parse`, reject empty/whitespace stdout, UTF-8 BOM, malformed/
overlong/truncated UTF-8 using a fatal decoder, forbidden controls/non-Unicode
string content, excessive depth/token/property/string/number limits, duplicate
decoded member names per object, trailing data, or multiple values. Implement
a small dependency-free JSON lexical scanner retaining each object's member
set; `JSON.parse` alone is insufficient. Require exactly one object root.
Never echo arbitrary streams. Evidence contains byte counts/digests, native
fields, stable categories, and allowlisted bounded diagnostics.

Validate exact npm report v2 root/metadata/vulnerability shapes and types;
unknown/missing fields; property/severity/range/isDirect; `via`, `effects`,
`nodes`; object advisory URL/severity/range; Boolean or reviewed object
`fixAvailable`; metadata totals; reciprocal graph targets; and resolution of
every node path to matching lockfile package/version. Derive unique
`(Package, AdvisoryUrl)` keys and keep package-keyed installed-node sets
separate—never cross-product them.

The pure fixture core accepts synthetic byte arrays and native-outcome records
and never spawns. `Test-NpmAuditPolicy.ps1` has PowerShell 5.1 compatibility,
first version `1.0.<UTC implementation YYYYMMDD>.0`, invokes the production
no-argument CLI for live evidence, and drives fixture-only adapters for cases.
It never runs npm itself or passes a parsed audit object to production.

## Authoritative audit case catalog

`.github/workflows/npm-audit-policy-cases.json` is the one versioned source for
semantic parsed-report, raw-byte, process, schema, graph, exception, and seam
cases. Every record has unique `PS-P3-AUDIT-*` ID/semantic key, one layer and
requirement, fixture recipe, native outcome, expected terminal category, and
expected bounded evidence. Unknown/duplicate/unconsumed/orphaned cases fail.
Recipes create bytes/files only under fresh disposable roots.

The closed inventory includes:

- raw empty/whitespace/BOM/invalid UTF-8/control/truncation/escape/surrogate/
  duplicate/root/two-value/trailing/numeric/resource-boundary cases;
- start error, timeout, signals, both stream overflows, 0/1/other exits,
  inconsistent/null fields, and partial valid output on non-exit outcomes;
- npm report-v2 root/metadata/vulnerability/via/effects/nodes/fix positive and
  every missing/unknown/wrong-type/count/severity disagreement;
- direct/transitive/cycle/dangling/ambiguous/multipath and prod/dev/optional/
  peer graph cases;
- none/valid/expired/mismatched/overbroad exceptions; and
- every 0/1×clean/vulnerable/malformed seam, exception-pass with native 1,
  and multi-defect precedence.

The harness must execute every case exactly once on both Node cells and both OS
families where applicable, preserve fixture bytes, and reject missing,
duplicate, unexpected, skipped, or category/evidence mismatches.

## Exception and production-time policy

Preferred acceptance is zero vulnerabilities at every severity and no
`npm-audit-exceptions.json`. The validator rejects an empty/stale exception
file.

If no maintained compatible clean tree exists, the conditional file has one
closed schema. Each exception includes stable ID; exact package/advisory,
vulnerable range, maximum severity, dependency types, canonical root-to-node
path set, reason/controls, owner login, and canonical `ApprovedAt`/`ExpiresAt`
(maximum 30 days). Its issue record contains fixed repository/number/numeric
ID/node ID/canonical URL/state/sorted labels/assignees/`UpdatedAt`/`FetchedAt`/
REST API version and SHA-256 of that canonical projection. Do not copy issue
title/body/comments.

Offline validation requires exact scope/topology equality, real repository/
issue identity shape, canonical digest, evidence no older than 24 hours, and:

`ApprovedAt ≤ FetchedAt ≤ ObservedAtUtc < ExpiresAt`

with `ExpiresAt - ApprovedAt ≤ 30 days`. Missing, extra, duplicate, fixed,
stale, future, expired, broadened, or topology-changed records fail.

Production audit code accepts no time argument/environment/file/caller value.
At start it calls `Date.now()` exactly once, requires a finite integer, and
records one `ObservedAtUtc` with exact millisecond UTC form plus
`ClockSource=SystemUtc`. A separately named pure fixture API accepts synthetic
time. Reject offsets, missing milliseconds, leap-second spelling,
noncanonical/invalid dates, alternate production clocks, and multiple reads.
Only live-record generation allows up to five minutes of server-timestamp
future skew; offline validation never moves time backward.

`Verify-NpmAuditExceptions.mjs` is a separate read-only live tool. For each
record it makes one bounded versioned
`GET /repos/{owner}/{repo}/issues/{number}` and requires HTTP 200, matching
immutable IDs/repository/number, no `pull_request`, `state=open`, exact
`security-audit-exception` label, and owner among assignees. Auth/network/
403/404/429/malformed/rate-limit/stale state fails; small bounded retries honor
`Retry-After`. A changed live `updated_at` requires regenerated canonical
evidence and review rather than silently accepting the old projection. The
tool uses its own system instant under the same rule; HTTP `Date` is
corroboration only.

Document create/refresh/renew/remove: maintainer creates/assigns/labels the
issue, live-generates the projection, reviews exact scope/expiry, and merges
it. Renewal repeats live evidence and approval; timestamps alone never renew.
Closing/removing an issue first requires removing/replacing the exception.
Release evidence includes a fresh live success.

## Dependency selection and reproducibility

For every direct package, review maintained compatible releases, intervening
major/pre-1.0 changes, license, provenance, tarball/package contents,
`engines.node`, changelog, API/config behavior, and retain/upgrade/replace/
remove rationale. Edit exact declarations explicitly and regenerate lockfile
from clean state with the sole producer. Never use `npm audit fix --force`,
`--force`, `--legacy-peer-deps`, ignored engines, or manual lock edits.

Require two clean reproducible installs, exact root/lock agreement, and
`npm ls --all` with no invalid/extraneous/missing node under the wrapper's
strict environment. Every cell runs Node policy, install/tree, raw audit,
outer/nested/staged lint, and hook harness; preferred Node 24 additionally runs
complete P1A/P2 enduring evidence. Nonproducer cells prove no lock rewrite.

## Final workflow and update governance

Keep P1B's PR/push publication graph, sole writer predicate, action pins,
artifact semantics, direct needs, and permission boundaries. Extend
`markdownlint.yml` internally with the exact OS×Node cells; setup-node uses
the exact patch from the closed matrix, `check-latest: false`, explicit token,
and `package-manager-cache: false`. Re-resolve every action at implementation
and pre-merge and update the single policy contract atomically on any approved
change.

The proposed exact dependency matrix is:

| Cell key | Hosted runner | Node | Bundled Corepack |
| --- | --- | --- | --- |
| `ubuntu/node22` | `ubuntu-24.04` | `22.23.2` | `0.34.6` |
| `ubuntu/node24` | `ubuntu-24.04` | `24.18.1` | `0.35.0` |
| `windows/node22` | `windows-2025` | `22.23.2` | `0.34.6` |
| `windows/node24` | `windows-2025` | `24.18.1` | `0.35.0` |

At both freeze gates verify those hosted labels remain available and record
their image identities. A retired label requires an explicit matrix/policy
update, not fallback to `*-latest`.

Add to `build.yml`:

```yaml
schedule:
  - cron: '23 17 * * 3'
workflow_dispatch:
```

Manual dispatch has no inputs. For schedule/manual:

- the same-commit local `validate_markdown` dependency suite runs read-only;
- `verify_audit_exception_issues` runs with only `contents: read` and
  `issues: read`, using the live tool (and succeeds with canonical `None` when
  no exception file exists);
- `dependency_policy_result` directly needs exactly those two jobs, uses
  `${{ always() }}`, has `permissions: {}`, and requires both success; and
- every preparation/artifact/matrix/approval/writer/diagnostic publication job
  is structurally ineligible.

Ordinary and Dependabot PRs use deterministic offline exception validation;
push uses the same. Scheduled/manual live state supersedes stored freshness for
that run only after exact identity/scope equality; it never rewrites files or
authorizes publication.

Extend the existing workflow policy/contract/cases—do not replace P1's parser
or P1B's cases. Prove exact event-to-job graph, final runtime roles, setup-node
inputs/defaults, wrapper calls, sole issue-read job, and absence of a
schedule/manual path to artifacts, secrets, or writes.

Normalize `.github/dependabot.yml` to exactly two review-only entries:
`github-actions` at `/` and `npm` at `/.github/workflows`, on approved
schedules. Reject duplicate/extra ecosystems, wrong directories, unapproved
ignores, auto-approval, or auto-merge. Proposals require CI, provenance/
license/changelog/engine review, lock diff, both exact cells, real hook, raw
audit policy, and immutable action-role review.

## Enduring and superseded contracts

Must remain green: deterministic generator transaction; P1A path/limit/context/
cleanup/catalog behavior; immutable artifact ID/digest; exact P1B job/action/
permission/attestation/approval/writer/credential/evidence contracts; P2
content/version; and unchanged generated bytes.

P3 supersedes only package/lock content, runtime/manager/contributor policy,
Husky installer/hook guard, Markdown runtime cell roles, audit governance, and
one-entry Dependabot state. Earlier affected-file counts were phase gates, not
current invariants.

## Validation

From fresh clones and empty dependency/cache state:

1. re-resolve/freeze supply tuple and selected packages at both gates;
2. run all operations through the closed wrapper on both exact Node/Corepack
   cells and Windows/Ubuntu;
3. prove descriptor/manager/executable/config identity and hostile ambient
   cases;
4. run two clean installs, exact tree, lock producer/no-op checks;
5. run every Node-policy, installer, lint, staged, real-hook, raw/process/
   schema/graph/exception/seam catalog case;
6. run production raw audit and preserve bounded byte/native evidence;
7. require zero findings or exact current exception plus live issue evidence;
8. test time before/at/after expiry, stale/future/fractional/offset cases, and
   zero caller clock controls;
9. run outer/nested/staged lint and real `git commit` hook on both OS families;
10. validate exact two-entry Dependabot and all inherited/new workflow cases;
11. rerun P1/P1A/P1B/P2 enduring evidence and require generated bytes unchanged;
12. use P1's exact path verifier before/after staging/final rerun against the
    frozen computed set; and
13. rerun from staged content with no additional diff.

Capture ordinary/Dependabot PR, post-merge push, schedule, and input-free
manual runs. Schedule/manual evidence contains only dependency validation,
live issue verification, and read-only terminal result; all publication jobs
are ineligible.

## Acceptance criteria

- [ ] Complete predecessor identities/landed contracts are verified and all
      enduring evidence remains green.
- [ ] The two exact Node/Corepack cells, hash-qualified npm, finite engines
      range, sole producer, and two freeze gates are proven.
- [ ] Every package operation uses the closed wrapper; hostile ambient config,
      credentials, PATH, and policy controls cannot weaken it.
- [ ] Node production policy observes the current process once, accepts no
      caller policy/version, and matches the authoritative case catalog.
- [ ] Husky installer has observable closed skip/install/failure behavior and
      real prepare/install/postcondition tests.
- [ ] Full, nested, staged-only, and real installed-hook semantics pass on
      both Node cells and OS families.
- [ ] Production audit owns native launch/raw bytes/strict parsing/schema/
      policy, accepts no caller report/clock, and all catalog cases pass.
- [ ] Audit is clean or every exact residual has a current ≤30-day exception,
      ≤24-hour offline evidence, and open labeled/assigned live issue.
- [ ] Exception file is absent when clean; live verification is fail-closed
      and release evidence is fresh.
- [ ] Schedule/manual graph is dependency-only/read-only, with only the live
      job granted `issues: read`; publication is structurally ineligible.
- [ ] Final action roles/inputs/defaults and all inherited/new policy cases
      pass both provenance freeze gates.
- [ ] Dependabot has exactly review-only Actions `/` and npm
      `/.github/workflows`.
- [ ] Generated artifacts/P2 content/P1B writer behavior remain unchanged.
- [ ] P1's raw verifier proves the frozen affected/staged set before and after
      final rerun.

## Non-goals

- Source-guide/generated-artifact or writer-architecture changes.
- Replacing staged-only lint with a full-repository hook.
- Auto-approving/merging updates, force/audit-force/legacy-peer/engine bypass,
  global npm installation, or open-ended Node support.
- Permanent, ownerless, URL-only, or offline-only audit exceptions.
- A new parser/workflow-policy engine or shared cross-repository runtime.

## References

- [Official Node distribution index](https://nodejs.org/dist/index.json)
- [Node 22.23.2 bundled Corepack record](https://raw.githubusercontent.com/nodejs/node/v22.23.2/deps/corepack/package.json)
- [Node 24.18.1 bundled Corepack record](https://raw.githubusercontent.com/nodejs/node/v24.18.1/deps/corepack/package.json)
- [npm 12.0.2 registry record](https://registry.npmjs.org/npm/12.0.2)
- [Corepack project and environment controls](https://github.com/nodejs/corepack)
- [npm configuration](https://docs.npmjs.com/cli/v12/using-npm/config/)
- [npm clean install](https://docs.npmjs.com/cli/v12/commands/npm-ci/)
- [npm audit](https://docs.npmjs.com/cli/v12/commands/npm-audit/)
- [Node child processes](https://nodejs.org/api/child_process.html)
- [Node TextDecoder](https://nodejs.org/api/util.html)
- [RFC 8259 JSON](https://datatracker.ietf.org/doc/rfc8259/)
- [Husky installation guidance](https://typicode.github.io/husky/how-to.html)
- [GitHub Issues REST API](https://docs.github.com/en/rest/issues/issues)
- [GitHub scheduled workflows](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule)
- [GitHub-hosted runner images](https://github.com/actions/runner-images)
- [Dependabot options](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference)
