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
- persistent `main` rule ID/normalized digest/effective-rule result, exact
  required terminal check/source, and sole official-Actions bypass;
- P2 version, six-path source/artifact hashes, and no-change post-merge run;
- all reciprocal matrices without unresolved blockers; and
- P1's advisory-risk decision and exact authorized baseline.

Compare landed state with this issue and rerun enduring evidence. A missing
dependency, landed drift, expired/refused risk decision, critical/materially
worse audit finding, disabled/broadened/drifted `main` rule, extra bypass, or
out-of-sequence package-graph change stops for issue review/rebaseline. Requery
the active rules applying to `main` rather than trusting stored settings
evidence. Do not perform a partial dependency update elsewhere.

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
- `.github/workflows/Capture-NpmAuditExceptionEvidence.mjs` — add;
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
| `packageManager` | `npm@12.0.2+sha512.b885e890b9418fa1693544d05f53e64f9a73ec194837d4258b15fecdd692347b1dd2a517b1b0cbaf9d31cd8e92c3b70956bd2ecc72833a57b4b3098f5bfa7943` |
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
operation names for `ci`, `audit`, `lock-noop`, and `run-lint`; there is no
caller executable, argument array, root, registry, config, cache, script,
include, workspace, timeout, or policy override. Remove the unused `run-test`
name: this repository has no package test script or production consumer, and a
closed name without one literal operation would be false authority.

The wrapper derives the repository and job-owned temporary roots from its own
location. It invokes the current `process.execPath` with the ordinary non-link
bundled Corepack JavaScript entry point at the fixed Node-distribution-relative
path, verifies the package version equals the selected cell, and passes `npm`
plus a fixed argument vector. It never resolves npm/npx/Corepack/Node through
PATH.

The deeply frozen `PS-P3-NPM-OPERATIONS-v1` table is the single authority.
`<corepack-entry>`, `<empty-user-npmrc>`, `<empty-global-npmrc>`, and
`<operation-cache>` below are wrapper-derived, validated ordinary paths under
the fixed Node distribution or job-owned temporary root, never caller values.
After `process.execPath`, the complete vectors are:

```text
ci:
<corepack-entry> npm ci --ignore-scripts --include=prod --include=dev
--include=optional --include=peer --workspaces=false --install-links=false
--strict-peer-deps=true --registry=https://registry.npmjs.org
--userconfig=<empty-user-npmrc> --globalconfig=<empty-global-npmrc>
--cache=<operation-cache> --prefer-online --no-audit --no-fund
--no-update-notifier --no-progress --color=false

audit:
<corepack-entry> npm audit --package-lock-only --json --audit-level=low
--include=prod --include=dev --include=optional --include=peer
--workspaces=false --install-links=false --strict-peer-deps=true
--registry=https://registry.npmjs.org --userconfig=<empty-user-npmrc>
--globalconfig=<empty-global-npmrc> --cache=<operation-cache> --prefer-online
--no-fund --no-update-notifier --no-progress --color=false

lock-noop:
<corepack-entry> npm install --package-lock-only --ignore-scripts
--include=prod --include=dev --include=optional --include=peer
--workspaces=false --install-links=false --strict-peer-deps=true
--registry=https://registry.npmjs.org --userconfig=<empty-user-npmrc>
--globalconfig=<empty-global-npmrc> --cache=<operation-cache> --offline
--no-audit --no-fund --no-update-notifier --no-progress --color=false

run-lint (vector 1):
<corepack-entry> npm run --ignore-scripts --workspaces=false
--userconfig=<empty-user-npmrc> --globalconfig=<empty-global-npmrc>
--cache=<operation-cache> --offline --no-fund --no-update-notifier
--no-progress --color=false lint:md

run-lint (vector 2, only after vector 1 succeeds):
<corepack-entry> npm run --ignore-scripts --workspaces=false
--userconfig=<empty-user-npmrc> --globalconfig=<empty-global-npmrc>
--cache=<operation-cache> --offline --no-fund --no-update-notifier
--no-progress --color=false lint:md:nested
```

Every row uses the fixed `.github/workflows` package root as working directory,
`shell: false`, hidden Windows console, ignored stdin, and no inherited file
descriptors. `ci` and `audit` use the closed network environment and a fresh
empty operation cache. `lock-noop` and `run-lint` use network-disabled Corepack
plus a fresh operation cache seeded only from the verified preceding `ci`
cache; the seed manifest/digest is evidence.

`ci`, `lock-noop`, and each lint vector have a 300,000-ms timeout, concurrently
captured 4-MiB stdout/stderr limits, and accept only exit 0. `audit` alone uses
the stricter native lifecycle below and accepts native exit 0 or 1 for report
reconciliation. Permitted side effects are: `ci`, only untracked
`node_modules` and its operation cache; `audit`, only its cache and protected
raw evidence; `lock-noop`, package-lock candidate/cache followed by required
byte-identical lock proof; and `run-lint`, cache only with the repository,
index, and tracked files unchanged.

The wrapper, audit validator, hook, workflows, and policy fixtures consume the
same frozen row or its canonical SHA-256. Unknown operation, vector drift,
reordering, extra/missing argument, changed environment/config/stream/timeout/
exit/side-effect disposition, or a caller-built manager command fails.

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

Reject comments, unknown/duplicate/interpolated/scoped-registry/auth keys. The
literal operation table above, not a prose collection of “fixed settings,” is
normative. Clean CI install uses `--ignore-scripts`; the reviewed Husky
lifecycle is tested separately.

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

The catalog contains exactly these 48 physical rows; every row additionally
carries its singular raw value/type, normalized value, exact category/exit,
requirement, and consumer set:

| ID | Literal fixture | Exact oracle |
| --- | --- | --- |
| `PS-P3-NODE-001` | JSON null | malformed type |
| `PS-P3-NODE-002` | Boolean | malformed type |
| `PS-P3-NODE-003` | number | malformed type |
| `PS-P3-NODE-004` | array | malformed type |
| `PS-P3-NODE-005` | object | malformed type |
| `PS-P3-NODE-006` | empty string | malformed syntax |
| `PS-P3-NODE-007` | ASCII whitespace | malformed syntax |
| `PS-P3-NODE-008` | `v22.23.2` | prefix rejected |
| `PS-P3-NODE-009` | `+22.23.2` | sign rejected |
| `PS-P3-NODE-010` | `-22.23.2` | sign rejected |
| `PS-P3-NODE-011` | `22.23` | missing component |
| `PS-P3-NODE-012` | `22.23.2.0` | extra component |
| `PS-P3-NODE-013` | `022.23.2` | leading-zero major |
| `PS-P3-NODE-014` | `22.023.2` | leading-zero minor |
| `PS-P3-NODE-015` | `22.23.02` | leading-zero patch |
| `PS-P3-NODE-016` | `22.23.2-rc.1` | prerelease rejected |
| `PS-P3-NODE-017` | `22.23.2+build` | build metadata rejected |
| `PS-P3-NODE-018` | `2.2e1.2` | exponent spelling rejected |
| `PS-P3-NODE-019` | `0x16.23.2` | hexadecimal spelling rejected |
| `PS-P3-NODE-020` | Unicode digit component | non-ASCII digit rejected |
| `PS-P3-NODE-021` | component above safe bound | overflow rejected |
| `PS-P3-NODE-022` | embedded NUL | control rejected |
| `PS-P3-NODE-023` | embedded newline | control rejected |
| `PS-P3-NODE-024` | `22.23.2x` | trailing data rejected |
| `PS-P3-NODE-025` | `20.999.999` | unsupported EOL line |
| `PS-P3-NODE-026` | `21.999.999` | unsupported odd line |
| `PS-P3-NODE-027` | `22.22.1` | one below Node 22 floor |
| `PS-P3-NODE-028` | `22.22.2` | exact Node 22 floor passes |
| `PS-P3-NODE-029` | `22.23.2` | selected Node 22 cell passes |
| `PS-P3-NODE-030` | `22.999.999` | admitted Node 22 upper patch passes |
| `PS-P3-NODE-031` | `23.0.0` | unsupported odd line |
| `PS-P3-NODE-032` | `24.14.999` | one range below Node 24 floor |
| `PS-P3-NODE-033` | `24.15.0` | exact Node 24 floor passes |
| `PS-P3-NODE-034` | `24.18.1` | selected Node 24 cell passes |
| `PS-P3-NODE-035` | `24.999.999` | admitted Node 24 upper patch passes |
| `PS-P3-NODE-036` | `25.0.0` | unsupported odd line |
| `PS-P3-NODE-037` | `26.0.0` | unreviewed future line |
| `PS-P3-NODE-038` | `27.0.0` | unreviewed future line |
| `PS-P3-NODE-039` | mutate admitted major | frozen-policy mutation fails |
| `PS-P3-NODE-040` | mutate floor | frozen-policy mutation fails |
| `PS-P3-NODE-041` | mutate ceiling | frozen-policy mutation fails |
| `PS-P3-NODE-042` | pass CLI positional argument | no-argument CLI fails |
| `PS-P3-NODE-043` | environment policy override | override ignored/rejected |
| `PS-P3-NODE-044` | file policy override | override ignored/rejected |
| `PS-P3-NODE-045` | production imports fixture evaluator | structural failure |
| `PS-P3-NODE-046` | second current-version read | structural failure |
| `PS-P3-NODE-047` | real CLI under Node `22.23.2` | actual-process pass |
| `PS-P3-NODE-048` | real CLI under Node `24.18.1` | actual-process pass |

Both cells consume every synthetic row. The real CLI rows prove only the
actual process and no-argument behavior. Catalog mutation fixtures reject
missing, duplicate, unknown, regrouped, multiply emitted, skipped, orphaned,
or unused rows.

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

At dependency-selection freeze, publish
`PSSTYLEGUIDE-HUSKY-INSTALL-v1` and bind:

- the exact root dependency declaration, selected package version, lock node,
  registry tarball/integrity, package root, and package-manager tree identity;
- the one reviewed public API or CLI entry point actually invoked, its
  package-relative path, length/SHA-256, and every transitively executed
  package file's reviewed length/SHA-256;
- tracked `.husky/pre-commit` as the fixed ordinary HEAD/index/no-filter
  working blob, Git mode `100644`, exactly one
  `# ps-style-guide-hook-schema: 1` marker on physical line 2, final length,
  and SHA-256;
- expected local `core.hooksPath` exactly `.husky/_`; and
- the complete generated `.husky/_` inventory as a sorted fixed array with
  every relative path, entry type, role, length, SHA-256, and Git/filesystem
  mode.

The install cannot use an unverified dynamic resolution. It resolves the
frozen package root and entry from the exact lock/tree, rechecks all bound
bytes immediately before the one import/spawn, and validates the complete
generated inventory afterward. A selected API rather than T3's CLI is allowed
only as a recorded reciprocal intentional difference with equal identity and
failure strength.

Every invocation emits exactly one
`PSStyleGuide.HuskyInstallDecision.v1` record with schema/contract version,
observed control-state category, decision, package/entry identity, hook
identity, pre/post hooksPath, generated-inventory digest, invocation count,
native/import outcome, source-tree/index before/after hashes, and bounded
diagnostic. It never emits environment values, package contents, paths outside
the fixed root, or native exception text.

Expose a named pure fixture decision function while production reads its own
environment once. Test all precedence permutations, malformed values, wrong
starting directory, import/call/nonempty-message failures, missing/linked
inputs, and postcondition failures in disposable Git repositories. Run one real
`prepare` lifecycle install and one explicit `HUSKY=0` clean-CI install.
Workflows intending to skip set `HUSKY=0`; they never rely on ambient `CI`.

The lint/hook harness contains one physical row and oracle for each:
`PS-P3-HUSKY-001` required install; `002` explicit opt-out; `003` production
skip; `004` CI-without-policy conflict; `005` malformed control; `006` wrong
working directory; `007` missing package; `008` package/link substitution;
`009` entry hash drift; `010` hook HEAD/index/working drift; `011` hook mode/
marker drift; `012` import/spawn failure; `013` throw/nonzero outcome; `014`
nonempty failure message; `015` wrong hooksPath; `016` generated-inventory
drift; `017` tracked-source/index mutation; and `018` real installed-hook
commit. Range prose is not authority: the committed catalog has 18 individual
records with literal fixtures, exact decisions, identities, calls, side
effects, and diagnostics, and mutation tests reject missing/duplicate/
unknown/regrouped/orphaned rows.

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

`Test-LintStagedMarkdown.ps1` has `#Requires -Version 5.1`, consumes P1's
landed version profile, first version
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
the native lifecycle and both raw streams, and launches the exact frozen
`audit` operation without a shell; the wrapper never launches audit on its
behalf.

Use exactly: 120,000-ms timeout; 5,000-ms termination grace; 8,388,608 retained
stdout bytes; 65,536 retained stderr bytes; `shell: false`; ignored stdin;
hidden Windows console; raw Buffer streams; and one final result only after
start failure or child `close` plus stream completion.

The internal immutable
`PSStyleGuide.NpmAuditNativeOutcome.v1` has exactly these ordered fields:

```text
SchemaVersion
CommandContract
Kind
Started
TimeoutMilliseconds
TerminationGraceMilliseconds
TerminationScope
TerminationRequested
TerminationDelivered
ForceRequested
ForceDelivered
ExitObserved
CloseObserved
ExitCode
Signal
StdoutObservedBytes
StdoutRetainedBytes
StdoutSha256
StdoutOverflow
StdoutStreamError
StderrObservedBytes
StderrRetainedBytes
StderrSha256
StderrOverflow
StderrStreamError
CleanupStatus
```

`SchemaVersion` is `1`; `CommandContract` is
`PS-P3-NPM-OPERATIONS-v1:audit`. Counts are nonnegative safe integers; hashes
are lowercase SHA-256 over all bytes actually observed while draining, not
only the retained prefix. Booleans and nullable values have exact types.
`Kind` is exactly `StartFailed|TimedOut|StdoutLimitExceeded|
StderrLimitExceeded|StreamFailed|TerminationFailed|Signaled|Exited`.
Publish a closed valid-combination table in the implementation contract: start
failure has no child/exit/close; ordinary exit has one numeric 0–255 exit and
no signal/termination; signal has null exit and canonical supported signal;
timeout/overflow requests termination; and every impossible combination is a
tool failure.

Concurrently drain both streams from spawn. Retain bytes only through each
inclusive cap, but continue bounded draining and hashing after overflow. The
first timeout or overflow sets its flag and requests termination exactly once;
stream errors are recorded and do not resolve the operation early. On hosted
Ubuntu, spawn an isolated process group, deliver `SIGTERM` to the group, wait
5,000 ms, and deliver `SIGKILL` if it has not closed. On Windows, terminate the
direct child with Node's supported forceful behavior, wait for close, record
`TerminationScope=direct-child`, and do not claim descendant-process parity.
A Windows timeout/overflow cannot be release-accepting evidence because
descendant cleanup is unproven; pure outcome fixtures still cover it.

Guard all `error`, `exit`, stream-error, timer, termination, and `close`
handlers with one state owner. Signal delivery success does not prove process
termination. A delivery failure, missing close after force/grace, second
completion attempt, or cleanup uncertainty is `TerminationFailed`.
After close, classify once in exact precedence:

`StartFailed`, `TerminationFailed`, `TimedOut`, `StdoutLimitExceeded`,
`StderrLimitExceeded`, `StreamFailed`, `Signaled`, `Exited`, then parsed-report
result.

Protected raw evidence is create-new, ordinary, non-link, mode `0600` where
supported, under one job-owned fixed root. Dispose handles and remove evidence
in `finally`; cleanup failure fails the job without overwriting the already
recorded primary class. Never log command paths, native error text, raw
streams, environment, or credentials.

For `Exited`, only numeric 0 or 1 is recognized; every other code is
`AuditToolFailed`. Exit 0 must pair with a valid report whose computed
threshold count is zero. Exit 1 must pair with at least one threshold finding
before exceptions and may pass only when every finding has an exact valid
exception. Every other pairing is `NativeReportMismatch`. Exceptions never
convert transport/parser/schema/tool failure into success.

Before `JSON.parse`, reject empty/whitespace stdout, UTF-8 BOM, malformed/
overlong/truncated UTF-8 using a fatal decoder, forbidden controls/non-Unicode
string content, duplicate decoded member names per object, trailing data, or
multiple values. The dependency-free lexical scanner enforces these inclusive
ceilings before `JSON.parse`:

| Resource | Maximum |
| --- | ---: |
| Raw stdout | 8,388,608 bytes |
| Nesting depth | 64 |
| JSON value/token count | 250,000 |
| Properties in one object | 100,000 |
| One decoded string token | 1,048,576 UTF-8 bytes and 524,288 Unicode scalar values |
| One number token | 64 ASCII bytes and 64 digits |

Every ceiling has below/at/above fixtures. Count property names and string
values independently, use checked safe-integer arithmetic, reject lone
surrogates/noncharacters forbidden by the closed policy, and retain each
object's decoded member set. `JSON.parse` alone is insufficient. Require
exactly one object root. Never echo arbitrary streams. Evidence contains only
byte counts/digests, the structured native fields, stable categories, and
allowlisted bounded diagnostics.

Validate exact npm report v2 root/metadata/vulnerability shapes and types;
unknown/missing fields; property/severity/range/isDirect; `via`, `effects`,
`nodes`; object advisory URL/severity/range; Boolean or reviewed object
`fixAvailable`; metadata totals; reciprocal graph targets; and resolution of
every node path to matching lockfile package/version. Derive unique
`(Package, AdvisoryUrl)` keys and keep package-keyed installed-node sets
separate—never cross-product them.

The pure fixture core accepts synthetic byte arrays and native-outcome records
and never spawns. `Test-NpmAuditPolicy.ps1` has PowerShell 5.1 compatibility,
consumes P1's version profile, first version
`1.0.<UTC implementation YYYYMMDD>.0`, invokes the production no-argument CLI
for live evidence, and drives fixture-only adapters for cases. It never runs
npm itself or passes a parsed audit object to production.

## Authoritative audit case catalog

`.github/workflows/npm-audit-policy-cases.json` is the one versioned source for
semantic parsed-report, raw-byte, process, schema, graph, exception, and seam
cases. Every record has unique `PS-P3-AUDIT-*` ID/semantic key, one layer and
requirement, fixture recipe, native outcome, expected terminal category, and
expected bounded evidence. Unknown/duplicate/unconsumed/orphaned cases fail.
Recipes create bytes/files only under fresh disposable roots.

Every physical row additionally contains exact layer, fixture/raw length and
digest, structured native outcome, exception state, parser state, expected
terminal class, normalized finding set, package-keyed node paths, process-call
count, bounded diagnostic, and applicable OS/Node cells. These are the closed
184 physical meanings; no range row exists in the JSON:

| ID | Literal fixture | Exact oracle |
| --- | --- | --- |
| `PS-P3-AUDIT-001` | clean audit, no exception file | pass |
| `PS-P3-AUDIT-002` | clean audit, exception file present | fail stale permission |
| `PS-P3-AUDIT-003` | residual audit, no exception file | fail unapproved findings |
| `PS-P3-AUDIT-004` | exact approved findings/topology | pass |
| `PS-P3-AUDIT-005` | new `(Package, AdvisoryUrl)` | fail exact addition |
| `PS-P3-AUDIT-006` | removed approved finding | fail stale removal |
| `PS-P3-AUDIT-007` | new package node path | fail topology addition |
| `PS-P3-AUDIT-008` | removed approved node path | fail stale topology |
| `PS-P3-AUDIT-009` | one millisecond before expiration | pass |
| `PS-P3-AUDIT-010` | exactly at expiration | fail expired |
| `PS-P3-AUDIT-011` | one millisecond after expiration | fail expired |
| `PS-P3-AUDIT-012` | malformed timestamp | fail schema |
| `PS-P3-AUDIT-013` | unknown exception property | fail closed schema |
| `PS-P3-AUDIT-014` | duplicate finding identity | fail duplicate |
| `PS-P3-AUDIT-015` | missing owner | fail governance |
| `PS-P3-AUDIT-016` | invalid follow-up issue URL | fail governance |
| `PS-P3-AUDIT-017` | non-JSON audit report | fail audit input |
| `PS-P3-AUDIT-018` | equivalent input in different order | identical normalization |
| `PS-P3-AUDIT-019` | real production no-argument audit | current governed result |
| `PS-P3-AUDIT-020` | wrong exception schema version | fail schema |
| `PS-P3-AUDIT-021` | wrong exception property type | fail schema |
| `PS-P3-AUDIT-022` | duplicate canonical advisory URL identity | fail duplicate |
| `PS-P3-AUDIT-023` | duplicate vulnerability package property | fail duplicate |
| `PS-P3-AUDIT-024` | duplicate installed node path | fail duplicate |
| `PS-P3-AUDIT-025` | missing follow-up fields | fail governance |
| `PS-P3-AUDIT-026` | missing approval identity | fail governance |
| `PS-P3-AUDIT-027` | truncated JSON audit report | fail audit input |
| `PS-P3-AUDIT-028` | empty raw report | audit input failure |
| `PS-P3-AUDIT-029` | UTF-8 BOM | audit input failure |
| `PS-P3-AUDIT-030` | UTF-16LE BOM | audit input failure |
| `PS-P3-AUDIT-031` | stray UTF-8 continuation | audit input failure |
| `PS-P3-AUDIT-032` | truncated multibyte UTF-8 | audit input failure |
| `PS-P3-AUDIT-033` | raw report exactly 8,388,608 bytes | tokenizer/schema oracle |
| `PS-P3-AUDIT-034` | raw report byte 8,388,609 | stdout limit failure |
| `PS-P3-AUDIT-035` | second JSON value | audit input failure |
| `PS-P3-AUDIT-036` | trailing non-whitespace | audit input failure |
| `PS-P3-AUDIT-037` | trailing JSON whitespace | accepted tokenizer boundary |
| `PS-P3-AUDIT-038` | depth 64 | accepted tokenizer boundary |
| `PS-P3-AUDIT-039` | depth 65 | parser resource failure |
| `PS-P3-AUDIT-040` | 250,000 values/tokens | accepted tokenizer boundary |
| `PS-P3-AUDIT-041` | 250,001 values/tokens | parser resource failure |
| `PS-P3-AUDIT-042` | 1,048,576-byte string token | accepted tokenizer boundary |
| `PS-P3-AUDIT-043` | 1,048,577-byte string token | parser resource failure |
| `PS-P3-AUDIT-044` | 64-byte number token | accepted tokenizer boundary |
| `PS-P3-AUDIT-045` | 65-byte number token | parser resource failure |
| `PS-P3-AUDIT-046` | duplicate key in report root | duplicate-key failure |
| `PS-P3-AUDIT-047` | duplicate key in vulnerability object | duplicate-key failure |
| `PS-P3-AUDIT-048` | duplicate key in advisory object | duplicate-key failure |
| `PS-P3-AUDIT-049` | duplicate key in `cvss` | duplicate-key failure |
| `PS-P3-AUDIT-050` | duplicate key in `fixAvailable` | duplicate-key failure |
| `PS-P3-AUDIT-051` | duplicate key in `metadata` | duplicate-key failure |
| `PS-P3-AUDIT-052` | duplicate key in `metadata.vulnerabilities` | duplicate-key failure |
| `PS-P3-AUDIT-053` | duplicate key in `metadata.dependencies` | duplicate-key failure |
| `PS-P3-AUDIT-054` | duplicate key in native-outcome root | outcome schema failure |
| `PS-P3-AUDIT-055` | duplicate key in exception root | exception schema failure |
| `PS-P3-AUDIT-056` | duplicate key in exception finding | exception schema failure |
| `PS-P3-AUDIT-057` | duplicate key in exception topology row | exception schema failure |
| `PS-P3-AUDIT-058` | outcome BOM | outcome input failure |
| `PS-P3-AUDIT-059` | outcome invalid UTF-8 | outcome input failure |
| `PS-P3-AUDIT-060` | outcome second value | outcome input failure |
| `PS-P3-AUDIT-061` | outcome extra property | outcome schema failure |
| `PS-P3-AUDIT-062` | outcome non-string `Kind` | outcome schema failure |
| `PS-P3-AUDIT-063` | impossible `Exited` combination | outcome schema failure |
| `PS-P3-AUDIT-064` | impossible `Signaled` combination | outcome schema failure |
| `PS-P3-AUDIT-065` | impossible `TimedOut` combination | outcome schema failure |
| `PS-P3-AUDIT-066` | impossible `StartFailed` combination | outcome schema failure |
| `PS-P3-AUDIT-067` | stdout count/hash mismatch | outcome identity failure |
| `PS-P3-AUDIT-068` | missing protected stdout evidence | outcome identity failure |
| `PS-P3-AUDIT-069` | native exit `2` | audit tool failure |
| `PS-P3-AUDIT-070` | external `SIGTERM` | signaled failure |
| `PS-P3-AUDIT-071` | timeout closes after TERM | timed-out failure |
| `PS-P3-AUDIT-072` | timeout requires force | timed-out failure with force evidence |
| `PS-P3-AUDIT-073` | process start failure | start failure |
| `PS-P3-AUDIT-074` | stderr exactly 65,536 bytes | accepted stream boundary |
| `PS-P3-AUDIT-075` | stderr byte 65,537 | stderr limit failure |
| `PS-P3-AUDIT-076` | stdout stream failure | stream failure |
| `PS-P3-AUDIT-077` | stderr stream failure | stream failure |
| `PS-P3-AUDIT-078` | termination delivery failure | termination failure |
| `PS-P3-AUDIT-079` | error then close | exactly one result |
| `PS-P3-AUDIT-080` | close without prior exit/error | impossible lifecycle failure |
| `PS-P3-AUDIT-081` | report-root extra property | report schema failure |
| `PS-P3-AUDIT-082` | missing `auditReportVersion` | report schema failure |
| `PS-P3-AUDIT-083` | missing `vulnerabilities` | report schema failure |
| `PS-P3-AUDIT-084` | missing `metadata` | report schema failure |
| `PS-P3-AUDIT-085` | null `vulnerabilities` | report schema failure |
| `PS-P3-AUDIT-086` | array `metadata` | report schema failure |
| `PS-P3-AUDIT-087` | unsafe vulnerability package-property name | report schema failure |
| `PS-P3-AUDIT-088` | vulnerability key/name mismatch | report schema failure |
| `PS-P3-AUDIT-089` | vulnerability extra property | report schema failure |
| `PS-P3-AUDIT-090` | vulnerability missing `name` | report schema failure |
| `PS-P3-AUDIT-091` | vulnerability missing `severity` | report schema failure |
| `PS-P3-AUDIT-092` | vulnerability missing `isDirect` | report schema failure |
| `PS-P3-AUDIT-093` | vulnerability missing `via` | report schema failure |
| `PS-P3-AUDIT-094` | vulnerability missing `effects` | report schema failure |
| `PS-P3-AUDIT-095` | vulnerability missing `range` | report schema failure |
| `PS-P3-AUDIT-096` | vulnerability missing `nodes` | report schema failure |
| `PS-P3-AUDIT-097` | vulnerability missing `fixAvailable` | report schema failure |
| `PS-P3-AUDIT-098` | vulnerability wrong `name` type | report schema failure |
| `PS-P3-AUDIT-099` | vulnerability wrong `severity` | report schema failure |
| `PS-P3-AUDIT-100` | vulnerability wrong `isDirect` | report schema failure |
| `PS-P3-AUDIT-101` | vulnerability wrong `via` | report schema failure |
| `PS-P3-AUDIT-102` | vulnerability wrong `effects` | report schema failure |
| `PS-P3-AUDIT-103` | vulnerability wrong `range` | report schema failure |
| `PS-P3-AUDIT-104` | vulnerability wrong `nodes` | report schema failure |
| `PS-P3-AUDIT-105` | vulnerability wrong `fixAvailable` | report schema failure |
| `PS-P3-AUDIT-106` | invalid `via` entry type | report schema failure |
| `PS-P3-AUDIT-107` | advisory extra property | report schema failure |
| `PS-P3-AUDIT-108` | advisory missing `source` | report schema failure |
| `PS-P3-AUDIT-109` | advisory missing `name` | report schema failure |
| `PS-P3-AUDIT-110` | advisory missing `dependency` | report schema failure |
| `PS-P3-AUDIT-111` | advisory missing `title` | report schema failure |
| `PS-P3-AUDIT-112` | advisory missing `url` | report schema failure |
| `PS-P3-AUDIT-113` | advisory missing `severity` | report schema failure |
| `PS-P3-AUDIT-114` | advisory missing `cwe` | report schema failure |
| `PS-P3-AUDIT-115` | advisory missing `cvss` | report schema failure |
| `PS-P3-AUDIT-116` | advisory missing `range` | report schema failure |
| `PS-P3-AUDIT-117` | advisory wrong `source` | report schema failure |
| `PS-P3-AUDIT-118` | advisory wrong `name` | report schema failure |
| `PS-P3-AUDIT-119` | advisory wrong `dependency` | report schema failure |
| `PS-P3-AUDIT-120` | advisory wrong `title` | report schema failure |
| `PS-P3-AUDIT-121` | advisory wrong `url` | report schema failure |
| `PS-P3-AUDIT-122` | advisory wrong `severity` | report schema failure |
| `PS-P3-AUDIT-123` | advisory wrong `cwe` | report schema failure |
| `PS-P3-AUDIT-124` | advisory wrong `cvss` | report schema failure |
| `PS-P3-AUDIT-125` | advisory wrong `range` | report schema failure |
| `PS-P3-AUDIT-126` | non-string CWE entry | report schema failure |
| `PS-P3-AUDIT-127` | CVSS extra property | report schema failure |
| `PS-P3-AUDIT-128` | CVSS missing `score` | report schema failure |
| `PS-P3-AUDIT-129` | CVSS missing `vectorString` | report schema failure |
| `PS-P3-AUDIT-130` | out-of-range/nonfinite CVSS score | report schema failure |
| `PS-P3-AUDIT-131` | non-string CVSS vector | report schema failure |
| `PS-P3-AUDIT-132` | package-string `via` target absent | graph failure |
| `PS-P3-AUDIT-133` | `effects` target absent | graph failure |
| `PS-P3-AUDIT-134` | `via` edge lacks reciprocal effect | graph failure |
| `PS-P3-AUDIT-135` | effect lacks reciprocal `via` edge | graph failure |
| `PS-P3-AUDIT-136` | unsorted or duplicate `nodes` | graph/schema failure |
| `PS-P3-AUDIT-137` | invalid `fixAvailable: null` | report schema failure |
| `PS-P3-AUDIT-138` | fix object extra property | report schema failure |
| `PS-P3-AUDIT-139` | fix object missing `name` | report schema failure |
| `PS-P3-AUDIT-140` | fix object missing `version` | report schema failure |
| `PS-P3-AUDIT-141` | fix object missing `isSemVerMajor` | report schema failure |
| `PS-P3-AUDIT-142` | fix object wrong `name` | report schema failure |
| `PS-P3-AUDIT-143` | fix object wrong `version` | report schema failure |
| `PS-P3-AUDIT-144` | fix object wrong `isSemVerMajor` | report schema failure |
| `PS-P3-AUDIT-145` | metadata extra property | report schema failure |
| `PS-P3-AUDIT-146` | missing vulnerability count `info` | metadata failure |
| `PS-P3-AUDIT-147` | missing vulnerability count `low` | metadata failure |
| `PS-P3-AUDIT-148` | missing vulnerability count `moderate` | metadata failure |
| `PS-P3-AUDIT-149` | missing vulnerability count `high` | metadata failure |
| `PS-P3-AUDIT-150` | missing vulnerability count `critical` | metadata failure |
| `PS-P3-AUDIT-151` | missing vulnerability count `total` | metadata failure |
| `PS-P3-AUDIT-152` | missing dependency count `prod` | metadata failure |
| `PS-P3-AUDIT-153` | missing dependency count `dev` | metadata failure |
| `PS-P3-AUDIT-154` | missing dependency count `optional` | metadata failure |
| `PS-P3-AUDIT-155` | missing dependency count `peer` | metadata failure |
| `PS-P3-AUDIT-156` | missing dependency count `peerOptional` | metadata failure |
| `PS-P3-AUDIT-157` | missing dependency count `total` | metadata failure |
| `PS-P3-AUDIT-158` | negative metadata count | metadata failure |
| `PS-P3-AUDIT-159` | unsafe-integer metadata count | metadata failure |
| `PS-P3-AUDIT-160` | non-integer metadata count | metadata failure |
| `PS-P3-AUDIT-161` | severity-total arithmetic mismatch | metadata failure |
| `PS-P3-AUDIT-162` | property/severity reconciliation mismatch | metadata failure |
| `PS-P3-AUDIT-163` | dependency-total mismatch | metadata failure |
| `PS-P3-AUDIT-164` | duplicate normalized advisory identity | finding failure |
| `PS-P3-AUDIT-165` | missing follow-up evidence array | governance failure |
| `PS-P3-AUDIT-166` | missing referenced evidence record | governance failure |
| `PS-P3-AUDIT-167` | extra unreferenced evidence record | governance failure |
| `PS-P3-AUDIT-168` | duplicate issue record | governance failure |
| `PS-P3-AUDIT-169` | evidence hash mismatch | governance failure |
| `PS-P3-AUDIT-170` | verified-time mismatch | governance failure |
| `PS-P3-AUDIT-171` | verifier/approval mismatch | governance failure |
| `PS-P3-AUDIT-172` | closed issue record | governance failure |
| `PS-P3-AUDIT-173` | pull-request record | governance failure |
| `PS-P3-AUDIT-174` | wrong repository | governance failure |
| `PS-P3-AUDIT-175` | URL/number mismatch | governance failure |
| `PS-P3-AUDIT-176` | invalid database/node identity | governance failure |
| `PS-P3-AUDIT-177` | responsible owner absent from assignees | governance failure |
| `PS-P3-AUDIT-178` | scope marker/hash mismatch | governance failure |
| `PS-P3-AUDIT-179` | invalid title hash | governance failure |
| `PS-P3-AUDIT-180` | invalid body-marker hash | governance failure |
| `PS-P3-AUDIT-181` | timestamp/order failure | governance failure |
| `PS-P3-AUDIT-182` | approval session exceeds 3,600 seconds | governance failure |
| `PS-P3-AUDIT-183` | valid single-issue record | pass |
| `PS-P3-AUDIT-184` | valid shared-issue exact scope | pass |

For deliberately deep/count/long values that cannot satisfy the closed npm
schema, `ExpectedParserState` distinguishes tokenizer acceptance followed by
schema rejection from tokenizer rejection. Multi-defect cases exist only where
their row explicitly tests precedence.

The harness must execute every case exactly once on both Node cells and both OS
families where applicable, preserve fixture bytes, and reject missing,
duplicate, unknown, regrouped, multiply emitted, skipped, orphaned, unused,
or category/evidence mismatches.

## Exception and production-time policy

Preferred acceptance is zero vulnerabilities at every severity and no
`npm-audit-exceptions.json`. The validator rejects an empty/stale exception
file.

If no maintained compatible clean tree exists, the conditional file has one
closed schema. Each exception includes stable ID; exact package/advisory,
vulnerable range, maximum severity, dependency types, canonical root-to-node
path set, reason/controls, owner login, and canonical `ApprovedAt`/`ExpiresAt`
(maximum 30 days). Each finding also binds one follow-up issue number/URL,
scope SHA-256, verification instant, and evidence-record SHA-256.

`FollowUpScopeSha256` hashes this exact BOM-less UTF-8/no-whitespace/no-final-
newline canonical JSON value, constructed with new null-prototype objects and
native `JSON.stringify`:

```text
["PSStyleGuide.NpmAuditFindingScope.v1",
 [{"Package":"<exact>","AdvisoryUrl":"<canonical exact>"}]]
```

The finding objects are the exact sorted unique findings assigned to that
issue, ordered by `Package` then `AdvisoryUrl`. No residual is missing,
duplicated, or covered by two issue scopes.

The issue body contains exactly one reviewed marker block:

```text
<!-- psstyleguide-npm-audit-exception:v1 -->
npm-audit-findings-sha256: <same lowercase 64-hex>
responsible-owner: <exact login>
target-date: <canonical YYYY-MM-DD>
```

The target date equals the exception expiry's UTC calendar date. The issue
title states the remediation objective. Hash the complete bounded title and
the canonical three-field marker projection separately; do not retain raw
title/body/comments in the exception file.

The exception root includes a sorted unique `FollowUpEvidence` array with one
record per referenced issue and no unreferenced record. Each
`PSStyleGuide.NpmAuditFollowUpEvidence.v1` record has this exact property order:

```text
EvidenceSchema
VerificationMethod
ApiVersion
VerifiedAt
VerificationActor
RepositoryOwner
RepositoryName
IssueUrl
IssueNumber
IssueDatabaseId
IssueNodeId
State
IsPullRequest
CreatedAt
UpdatedAt
Labels
Assignees
ResponsibleOwner
TargetDate
ScopeMarker
ScopeSha256
TitleSha256
BodyMarkerSha256
```

`VerificationMethod` is `github-rest-user-and-issue-v1`; `ApiVersion` is
`2022-11-28`; repository is exactly `franklesniak/PSStyleGuide`; state is
`open`; `IsPullRequest` is false; IDs are positive safe/valid immutable
identities; labels/assignees are sorted unique closed identity records; the
exact `security-audit-exception` label exists; `ResponsibleOwner` appears once
among assignees; and canonical UTC timestamps satisfy
`CreatedAt ≤ UpdatedAt ≤ VerifiedAt`. SHA-256 covers exact canonical preimages.
Every finding's issue/scope/evidence fields equal its one referenced record.

Offline validation requires exact scope/topology equality, real repository/
issue identity shape, canonical scope/content/evidence digests, evidence no
older than 24 hours, and:

`VerifiedAt ≤ ApprovedAt ≤ ObservedAtUtc < ExpiresAt`

with `ExpiresAt - ApprovedAt ≤ 30 days`. Missing, extra, duplicate, fixed,
stale, future, expired, broadened, content-drifted, or topology-changed records
fail.

Production audit code accepts no time argument/environment/file/caller value.
At start it calls `Date.now()` exactly once, requires a finite integer, and
records one `ObservedAtUtc` with exact millisecond UTC form plus
`ClockSource=SystemUtc`. A separately named pure fixture API accepts synthetic
time. Reject offsets, missing milliseconds, leap-second spelling,
noncanonical/invalid dates, alternate production clocks, and multiple reads.
Only live-record generation allows up to five minutes of server-timestamp
future skew; offline validation never moves time backward.

`Capture-NpmAuditExceptionEvidence.mjs` is the named read-only capture tool.
Its CLI has this exact ordered single-use syntax and no aliases:

```text
node Capture-NpmAuditExceptionEvidence.mjs --issue-number NUMBER
--scope-sha256 HASH --responsible-owner LOGIN --target-date YYYY-MM-DD
--output NEW-PROTECTED-PATH
```

A nonlogged `GITHUB_TOKEN` environment value supplies authentication. The tool
uses no redirects and performs versioned `GET /user` followed by
`GET /repos/franklesniak/PSStyleGuide/issues/{number}`. Each response is at
most 1 MiB. It rejects non-200, malformed/oversized/unknown required shape,
identity mismatch, pull request, non-open state, missing label/assignee,
missing/duplicate/wrong markers, scope/date/owner mismatch, or unsafe content.
It writes only the canonical minimized record with create-new mode `0600`;
never token, headers, raw response, title, body, comments, email, or exception
text. The approver embeds that exact record and deletes the scratch file in the
same reviewed change.

`Verify-NpmAuditExceptions.mjs` uses the same client and reconstructs/fetches
every embedded record. Both tools make at most three total attempts. Only HTTP
`429`, `502`, `503`, and `504` are retryable. `Retry-After`, when present, must
be canonical ASCII integer seconds from 0 through 30; otherwise retry fails.
When absent, delays are exactly one second before attempt two and two seconds
before attempt three. Redirect, auth/network, `403`, `404`, exhausted retry,
malformed response, or rate-limit metadata without a valid bounded delay fails
closed. Send exact `Accept: application/vnd.github+json`,
`X-GitHub-Api-Version: 2022-11-28`, and a fixed User-Agent. The tools use one
system instant; HTTP `Date` is corroboration only.

Fresh verification compares live canonical state to the embedded record and
fails any scope/title-marker/body-marker/state/owner/assignee/target-date/
identity/timestamp drift. It never rewrites or silently refreshes approval.

Document create/refresh/renew/remove: the maintainer creates/assigns/labels and
marks the issue, runs the capture tool, reviews exact scope/expiry/content, and
merges the record. Renewal repeats live reads, fix-availability analysis,
scope/content/assignee review, capture, and approval; timestamps alone never
renew. Closing/removing an issue first requires removing/replacing the
exception. Release evidence includes a fresh live verifier success.

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

At both gates re-fetch `ps-style-guide-main-protection`, hash normalized JSON,
query all active rules applying to `main`, and require exact
pull-request/resolved/current/check/deletion/non-fast-forward policy, stable
P1B terminal check from the expected Actions source, and the single
official-Actions `always` bypass. Settings drift blocks P3 and is never repaired
through workflow YAML.

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
2. run every literal `PS-P3-NPM-OPERATIONS-v1` row through the closed wrapper
   on both exact Node/Corepack cells and Windows/Ubuntu;
3. prove descriptor/manager/executable/config identity and hostile ambient
   cases;
4. run two clean installs, exact tree, lock producer/no-op checks;
5. run all 48 Node-policy rows, 18 Husky identity/decision rows, and 184 audit
   raw/process/schema/graph/exception/seam rows exactly once per applicable
   cell;
6. run production raw audit and preserve bounded byte/native/lifecycle/
   termination/cleanup evidence;
7. require zero findings or exact current exception plus live issue evidence;
8. test time before/at/after expiry, stale/future/fractional/offset cases, and
   zero caller clock controls;
9. run outer/nested/staged lint and real `git commit` hook on both OS families;
10. validate exact two-entry Dependabot and all inherited/new workflow cases;
11. re-query the persistent `main` rule/effective state/sole bypass;
12. rerun P1/P1A/P1B/P2 enduring evidence and require generated bytes unchanged;
13. use P1's exact path verifier before/after staging/final rerun against the
    frozen computed set; and
14. rerun from staged content with no additional diff.

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
      credentials, PATH, and policy controls cannot weaken its literal ordered
      vector/environment/stream/timeout/exit/side-effect table.
- [ ] Node production policy observes the current process once, accepts no
      caller policy/version, and matches all 48 physical catalog rows.
- [ ] Husky package/entry bytes, tracked hook, generated support inventory, and
      installer decision are hash-bound; all 18 physical rows and a real
      prepare/install/commit pass.
- [ ] Full, nested, staged-only, and real installed-hook semantics pass on
      both Node cells and OS families.
- [ ] Production audit owns native launch/raw bytes/strict parsing/schema/
      policy, has one exact cross-platform-truthful lifecycle result, accepts
      no caller report/clock, and all 184 physical catalog rows pass.
- [ ] Audit is clean or every exact residual has a current ≤30-day exception,
      ≤24-hour offline evidence, and open labeled/assigned live issue.
- [ ] Exception file is absent when clean; the named capture tool binds exact
      issue scope/content/owner/target date; live verification/retry is
      fail-closed and release evidence is fresh.
- [ ] Schedule/manual graph is dependency-only/read-only, with only the live
      job granted `issues: read`; publication is structurally ineligible.
- [ ] Final action roles/inputs/defaults and all inherited/new policy cases
      pass both provenance freeze gates.
- [ ] Dependabot has exactly review-only Actions `/` and npm
      `/.github/workflows`.
- [ ] Generated artifacts/P2 content/P1B writer behavior remain unchanged.
- [ ] Persistent `main` governance remains active/effective with the stable
      terminal check/source and sole official-Actions bypass.
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
