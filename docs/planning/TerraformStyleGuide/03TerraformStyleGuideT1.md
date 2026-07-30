# Make artifact generation byte-deterministic and standardize repository text checkouts on LF

## Summary

Make the style-guide generator emit identical UTF-8 bytes under Windows
PowerShell 5.1 and PowerShell 7, and establish LF as the repository checkout
policy. Move the Markdown workflow to hosted Node 24, pin every currently used
external action to a reviewed full commit SHA, and add review-only GitHub
Actions dependency updates.

This issue establishes foundations only. It does not add the candidate ZIP
validator or activate the new artifact-promotion writer. It also establishes
the reciprocal generator-and-foundation contract with PSStyleGuide without introducing
a shared cross-repository runtime dependency.

## Execution order

This is the first issue in the default TerraformStyleGuide slate order.

Before implementation, record a dated repository-policy decision for the
current npm advisory state. The record must name the audit command/tool
versions, high-severity findings, decision owner, evidence date, accepted
waiting period, and selected order.

- If policy permits the findings to remain temporarily, use the default order.
- If policy requires immediate remediation, implement **Remediate Markdown lint
  dependency advisories and add npm update governance** first. Then record that
  issue's actual merge commit and rebaseline this issue's Node, action,
  workflow, package, affected-file, and validation assumptions before editing.

After it merges:

1. implement **Add a fail-closed cross-platform style-guide candidate
   validator** against T1's actual merge commit and record that consumed commit
   in the T1A issue/pull request; then
2. implement **Promote generated style-guide artifacts through a
   least-privileged verified writer** against both exact prerequisite commits.

Record real GitHub blocked-by relationships when the issues are filed.

## Affected files

Exactly these eight implementation files may change:

- `.gitattributes` — add;
- `.github/dependabot.yml` — add;
- `.github/workflows/Generate-StyleGuideArtifacts.ps1`;
- `.github/workflows/Validate-WorkflowPolicy.mjs` — add;
- `.github/workflows/build.yml`; and
- `.github/workflows/markdownlint.yml`;
- `.github/workflows/package.json`; and
- `.github/workflows/package-lock.json`.

The generator must regenerate these four artifacts during validation, but their
final bytes must remain unchanged:

- `copilot-instructions.md`;
- `terraform.instructions.md`;
- `STYLE_GUIDE_CHAT.md`; and
- `STYLE_GUIDE_FULL.md`.

Do not hand-edit generated artifacts.

## Requested changes

### 1. Normalize each complete payload at the serialization boundary

The complete payloads are:

| Function | Complete final payload |
| --- | --- |
| `New-StyleGuideCopilotVersion` | `$strContent` |
| `New-StyleGuideTerraformInstructionsVersion` | `$strFullContent` |
| `New-StyleGuideChatVersion` | `$strWrappedContent` |
| `New-StyleGuideFullVersion` | `$strOutput` |

Immediately before encoding each payload, use the applicable value in:

```powershell
$strNormalizedContent = <complete-final-payload> -replace "`r`n?", "`n"
```

Requirements:

- normalize after every transformation and concatenation;
- convert CRLF to one LF;
- convert lone CR to one LF;
- preserve existing LF;
- preserve `New-StyleGuideFullVersion`'s existing split/join semantics;
- do not normalize after writing; and
- do not claim semantic support for CR-only source documents.

### 2. Replace edition-dependent writes

At each of the four final write sites:

1. call the one private `Write-StyleGuideArtifact` helper with a closed
   artifact ID, raw destination string, and complete final payload;
2. resolve one unresolved FileSystem-provider path with
   `GetUnresolvedProviderPathFromPSPath` after rejecting wildcard,
   provider-qualified, relative, malformed, and out-of-allowlist input;
3. normalize and encode the entire payload once with
   `System.Text.UTF8Encoding($false)`;
4. prepare and durably flush one unpredictable same-directory `CreateNew`
   temporary file;
5. verify its closed bytes and replace the existing destination exactly once
   with `File.Replace`; and
6. report stable artifact ID, safe destination, phase, and exception category
   on failure without logging content.

Direct final writes, `File.WriteAllText`, `Set-Content`, `Out-File`, copy,
delete-then-move, and fallback writes are prohibited.

Record one updated generator version using the repository's UTC version
convention. Retain `#Requires -Version 5.1`.

### 3. Establish the LF checkout policy

Create root `.gitattributes` containing exactly:

```gitattributes
* text=auto eol=lf
```

Do not add language-specific exceptions in this issue.

Use `git add --renormalize .` only in the controlled validation worktree.
Before staging, record current Git attributes and path sets. After staging,
prove the cached path set is exactly the eight affected files and that no
generated artifact changed.

### 4. Use exact hosted Node 24.18.1

In `.github/workflows/markdownlint.yml`:

- use the reviewed setup-node action commit from the action table below;
- configure:

  ```yaml
  with:
    node-version: '24.18.1'
    check-latest: false
    package-manager-cache: false
  ```

- resolve the actual Node process before installation;
- require exact Node `24.18.1` and bundled npm `11.16.0`, and record both
  executable paths and versions before installation;
- run a clean frozen
  `npm ci --ignore-scripts --no-audit --no-fund`;
- hash `package.json` and `package-lock.json` before and after and require
  equality;
- run the unchanged outer Markdown lint command;
- run the unchanged nested-Markdown lint command; and
- classify the native exit of each phase.

Immediately before implementation, recheck the official Node archive and the
signed `SHASUMS256.txt` for the intended Node 24 LTS release. If the selected
patch or its bundled npm differs from `24.18.1`/`11.16.0`, stop before any
package edit and update the literal pair, artifact, checksum, and review
evidence in this issue. A floating major, `latest`, runner `PATH`, or
after-the-fact observation is not an authorized package producer or consumer.

Except for the direct exact YAML parser addition required by the tracked
workflow-policy validator below, do not change:

- `.husky/pre-commit`;
- lint configuration;
- lint script names; or
- repository contributor/runtime-floor policy.

The final package versions, `engines.node`, hook runtime guard, advisory
disposition, npm update policy, and contributor minimum belong to
**Remediate Markdown lint dependency advisories and add npm update
governance**.

### 5. Pin and allowlist the current external actions

Immediately before implementation, resolve these release tags from their
official repositories and retain the output in the pull request. If a tag no
longer resolves to the listed commit, stop and review the upstream change
instead of silently substituting another commit.

| Action | Required full commit SHA | Reviewed release |
| --- | --- | --- |
| `actions/checkout` | `3d3c42e5aac5ba805825da76410c181273ba90b1` | `v7.0.1` |
| `actions/setup-node` | `820762786026740c76f36085b0efc47a31fe5020` | `v7.0.0` |
| `actions/upload-artifact` | `043fb46d1a93c77aae656e7c1c64a875d1fc6a0a` | `v7.0.1` |

Every `uses:` line must contain the exact full SHA plus the matching release
annotation. Tags, branches, abbreviated hashes, dynamic `uses:`, remote
reusable workflows, unreviewed Docker actions, and other external repositories
are prohibited.

The implementation-time verifier must parse all tracked workflow YAML and
require exact multiset equality for the current workflow roles:

| Workflow | Role | Action | Expected count |
| --- | --- | --- | ---: |
| `build.yml` | read-only verification checkout | `actions/checkout` | 1 |
| `build.yml` | current push-only synchronization checkout | `actions/checkout` | 1 |
| `build.yml` | verification artifact upload | `actions/upload-artifact` | 1 |
| `markdownlint.yml` | repository checkout | `actions/checkout` | 1 |
| `markdownlint.yml` | hosted Node setup | `actions/setup-node` | 1 |

Each observed row includes workflow path, job ID, stable step role, repository,
full SHA, release annotation, and count. Reject missing, duplicate, swapped,
and extra uses. The verifier is offline; live upstream resolution belongs to
the reviewed update process.

The later writer-activation issue must replace this exact current-role table
atomically with its final workflow/role/count table.

### 6. Add review-only GitHub Actions updates

Create `.github/dependabot.yml` with normalized exact content equivalent to:

```yaml
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
```

Use the repository's approved weekday/time/timezone fields if maintainers
require them. The final normalized configuration must contain exactly one
`github-actions` entry for `/`, no duplicate update blocks, and no automatic
approval or merge behavior.

Dependabot proposals do not authorize an action upgrade. Each upgrade must
re-establish official repository/release provenance and update the `uses:`
lines, release annotations, exact-role allowlist, and negative fixtures
atomically.

The later npm issue replaces this intermediate one-entry invariant with exactly
two entries by adding npm at `/.github/workflows`.

### 7. Isolate current publication and record its boundary

This issue must not activate a new download action, candidate helper, approval
job, or artifact-promotion writer. Preserve the current build workflow's
functional generation/publication behavior with an explicit temporary
least-privilege split:

- set workflow/top-level permissions to `contents: read`;
- run one verification job on applicable pull requests and pushes;
- let that job use a transient authenticated read-only checkout, then generate,
  compare, and upload current generated files without persisted Git
  credentials or repository writes;
- put the existing direct commit/push behavior in a separate job that is
  eligible only for a push to `main`;
- give only that push-only job `contents: write`;
- disable persisted checkout credentials everywhere;
- retain an HTTPS origin with no embedded credential and prohibit
  credential-bearing remote
  URLs, credential helpers, command arguments, and persisted Git config;
- bind `github.token` as a masked environment secret only on the exact push
  step;
- inside that step, construct one Basic authorization header in memory and
  expose it to only the `git push` child through process-scoped
  `GIT_CONFIG_COUNT`, `GIT_CONFIG_KEY_0`, and `GIT_CONFIG_VALUE_0`;
- clear the token/header/config environment in `finally` and run every
  preflight, diff, ref/object, and post-push diagnostic without it;
- prohibit new secrets or external actions; and
- document that T1B replaces this temporary direct-publication job with the
  final unfiltered artifact, matrix, approval, and exact-lease topology.

The temporary push-only job must still start from the exact triggering SHA,
stage only the four generated artifacts, and stop on any other changed path.
It does not claim the immutable-candidate, four-local identity, or exact-lease
properties that T1B will establish.

Call this job the **temporary pre-promotion writer** in workflow comments and
evidence. T1B must delete, not disable or retain as fallback, every temporary
generation/commit/push step. Version control is the rollback mechanism.

The Markdown workflow remains read-only and runs for every pull request
targeting `main`.

The complete temporary workflow graph is normative:

| Workflow/job | Direct `needs` | Literal job `if` | Job permission | Outputs | Permitted side effects |
| --- | --- | --- | --- | --- | --- |
| `build.yml` / `verify` | absent | absent; ordinary event eligibility | exactly `contents: read` | absent | Read checkout, ephemeral generation/validation, and one success-only upload of the four generated artifacts |
| `build.yml` / `temporary-writer` | exactly `[verify]` | `${{ github.event_name == 'push' && github.ref == 'refs/heads/main' && needs.verify.result == 'success' }}` | exactly `contents: write`; all unspecified permissions `none` | absent | Ephemeral regeneration/validation and at most one guarded commit/update of `refs/heads/main` when the exact generated set changed |
| `markdownlint.yml` / `markdownlint` | absent | absent; ordinary event eligibility | exactly `contents: read` | absent | Read checkout, exact Node acquisition, frozen install, and both lint surfaces |

There are exactly three jobs. No matrix, container, service, reusable-workflow
call, dynamic job, job output, extra direct/transitive dependency, second
write-capable job, or `always()`/`failure()`/`cancelled()` widening is allowed.
The `verify` upload step occurs after all validation, declares
`if: ${{ success() }}`, has no `continue-on-error`, and fails `verify` if the
upload fails. Failure, cancellation, or skip uploads nothing.

The writer repeats generation and all path/byte/ref checks from the triggering
SHA; it does not consume the verification artifact or a job output. A
no-change outcome makes no commit or push. Only its final guarded step receives
explicit push credential material. The policy fixtures independently mutate
each job, edge, condition operand/operator, permission, output, step order,
upload condition, side effect, and called-workflow boundary. T1B replaces this
entire graph and deletes the temporary writer rather than retaining a disabled
fallback.

### 8. Use one private artifact writer and an exact failure-state transaction

`Write-StyleGuideArtifact` is the only permitted final-write boundary. Its
closed mapping is:

| Artifact ID | Exact destination leaf |
| --- | --- |
| `copilot` | `copilot-instructions.md` |
| `terraform-instructions` | `terraform.instructions.md` |
| `chat` | `STYLE_GUIDE_CHAT.md` |
| `full` | `STYLE_GUIDE_FULL.md` |

Derive the repository root from `$PSScriptRoot` and the script's fixed
`.github/workflows` location, never the current directory. Reject destination
input in this order: null; empty; whitespace-only; NUL/control/malformed;
wildcard; provider-qualified; relative/drive-relative/not-fully-qualified;
then artifact-ID/path mismatch. Use the provider out-parameter overload,
require `FileSystem`, normalize once, and compare the full path to the mapped
path ordinally on Linux and ordinal-ignore-case on Windows. Inspect every
existing component from trusted root through leaf and reject a link/reparse,
non-directory parent, or non-ordinary destination.

All four destinations must already exist as tracked ordinary non-reparse files.
After complete-payload normalization, encode once; create an unpredictable
sibling with bounded collision retries using `FileMode.CreateNew`,
`FileAccess.Write`, and `FileShare.None`; write all bytes; call `Flush(true)`;
dispose; then verify exact length and SHA-256. Recheck parent/destination and
call `File.Replace(temp,destination,$null)` exactly once.

- Before `File.Replace` returns, any failure requires the old destination to
  remain byte-identical and removes only the proven temporary sibling.
- After `File.Replace` returns, the complete new destination and absent
  temporary name are committed success; no fallible semantic gate follows.
- Unsupported `File.Replace`, cleanup failure, or an uncertain filesystem
  state fails closed without copy/move/direct-write fallback.

Fault-injection cases cover every phase from pre-create through cleanup on
Windows PowerShell 5.1, PowerShell 7 on Windows, and PowerShell 7 on Linux.

### 9. Separate timeless version parsing, consumer identity, and authoring bumps

The script-level comment help before the first function contains exactly one:

```text
Version: 1.0.YYYYMMDD.0
```

The common raw parser is timeless. It requires exactly one complete marker line
in the script-level `.NOTES` block before the first function and exact grammar
`Version: <Major>.<Minor>.<YYYYMMDD>.<Revision>`. Components use ASCII digits,
have no sign/whitespace/extra component, and have no leading zero except the
single digit `0`. All four fit `[System.Version]` nonnegative integer bounds
and round-trip canonically; Build is a real invariant proleptic-Gregorian
`yyyyMMdd` date, including leap-day validation. The parser never reads the
clock, Git timestamps, filesystem timestamps, or network. Real old and future
dates remain valid. Missing, duplicate, out-of-location/decoy, malformed,
overflow, impossible-date, and component-count failures are
`invalid-version`, never “stale.”

A trusted consumer separately embeds or supplies the exact expected canonical
version from the same reviewed commit/path/SHA. Ordinal mismatch after valid
parsing is `unexpected-version`. No expected version is derived from the
untrusted script, and version never substitutes for commit, ordinary-file
identity, or SHA-256.

Only implementation/merge validation enforces authoring progression. For every
affected script, record merge-base blob/version (or `absent`), change class,
accountable author, and the UTC date of the final material edit. A new script
starts `1.0.<date>.0`; a breaking contract increments Major and resets Minor
and Revision; a compatible capability increments Minor and resets Revision; a
correction preserves Major/Minor, uses the final-edit date, resets Revision
when Build changes, and otherwise increments Revision by exactly one. An
unchanged file is excluded. A later test run alone never causes a bump.
Decrease, jump, reused revision, wrong final-edit date, or reset violation
fails `version-progression`.

Fixtures are partitioned into timeless grammar, explicit expected-version, and
baseline-to-staged progression cases. T1A and T1B consume these same three
layers.

### 10. Add the permanent locked workflow-policy validator now

Add exact direct `"yaml": "2.9.0"` to `devDependencies` and update the
version-3 lockfile with the reviewed official tarball/integrity and no
lifecycle scripts. Immediately before implementation, re-resolve the package
and integrity and rerun the dated audit decision; drift or a policy-blocking
finding requires review/rebaseline.

There is exactly one lockfile producer. In a clean disposable clone with no
inherited `node_modules`, acquire the official Node `24.18.1` artifact for the
selected producer platform and verify it against the release's signed
`SHASUMS256.txt`. Require `node --version` and `npm --version` to equal
`24.18.1` and `11.16.0` before editing package metadata. Set the one direct
manifest entry to exact `"yaml": "2.9.0"` and, from
`.github/workflows`, run exactly:

```text
npm install --package-lock-only --ignore-scripts --no-audit --no-fund
```

Use a fresh evidence cache and record release URL/artifact, expected/actual
SHA-256, signature result, executable paths, OS/architecture, clean source
commit, effective registry/proxy/certificate/peer/lock/script/audit/fund
configuration with secrets redacted, and pre/post manifest/lock hashes. Do not
add an interim `packageManager`, invoke a second producer, use force/
legacy-peer flags, install globally, format, normalize, or hand-edit the lock.
Require lockfile version 3, exact root dependency and package
registry/integrity identity, and no unrelated resolution churn.

Every other platform/runtime cell is a frozen consumer: record pre-hashes, run
`npm ci --ignore-scripts --no-audit --no-fund`, require identical post-hashes
and an empty manifest/lock diff, then run the parser validation. T3—not T1—owns
the durable hash-qualified package-manager policy and any later authorized
lock regeneration.

`Validate-WorkflowPolicy.mjs` contains a pure parser/policy core and thin CLI.
It accepts exactly `build.yml` then `markdownlint.yml`, performs no network or
child process, and parses one strict YAML 1.2 core document with unique string
keys and warnings-as-errors. Reject directives, anchors, aliases, merge keys,
explicit/custom tags, multidocument streams, complex/non-string keys, and
non-JSON-like values before policy evaluation.

The validator transcribes the normative role policy below; observed YAML never
defines the allowlist. Its append-only fixture inventory gives every syntax,
schema, action, input, permission, event, condition, and role mutation one ID
and one result. Run fixtures and real workflows after the same clean `npm ci`
and exact Node `24.18.1`/npm `11.16.0` assertion used by lint, then prove
offline execution.

T1B extends—not replaces—this validator, parser, and fixture suite. T3
revalidates the same direct parser through its dependency update.

### 11. Normative T1 workflow-role and input policy

Every role occurs exactly once:

| Role ID | Workflow/job/step | Permission and condition | Action/side effect |
| --- | --- | --- | --- |
| `build.verify.checkout` | `build.yml` / `verify` / `checkout` | `contents: read`; PR or push trigger | reviewed checkout SHA; acquire triggering SHA only |
| `build.writer.checkout` | `build.yml` / `temporary-writer` / `checkout` | `contents: write`; literal push-to-main eligibility | reviewed checkout SHA; acquire triggering SHA only |
| `build.verify.upload-generated` | `build.yml` / `verify` / `upload-generated` | `contents: read`; failure/success policy stated below | reviewed upload SHA; four generated paths only |
| `markdown.checkout` | `markdownlint.yml` / `markdownlint` / `checkout` | `contents: read`; ordinary workflow eligibility | reviewed checkout SHA; acquire triggering SHA only |
| `markdown.setup-node` | `markdownlint.yml` / `markdownlint` / `setup-node` | `contents: read`; after checkout | reviewed setup-node SHA; Node distribution only |

All checkout roles declare exactly:

| Input | Required value |
| --- | --- |
| `repository` | `${{ github.repository }}` |
| `ref` | `${{ github.sha }}` |
| `token` | `${{ github.token }}` |
| `persist-credentials` | `false` |
| `fetch-depth` | `1` |
| `fetch-tags` | `false` |
| `show-progress` | `false` |
| `lfs` | `false` |
| `submodules` | `false` |
| `clean` | `true` |
| `set-safe-directory` | `true` |
| `allow-unsafe-pr-checkout` | `false` |

SSH inputs, sparse checkout/filter, alternate path/server URL, and every
unlisted input remain absent as separately reviewed defaults. Setup Node
declares exactly `node-version: '24.18.1'`, `check-latest: false`,
`package-manager-cache: false`, and `token: ${{ github.token }}`; registry,
scope, cache path, version file, architecture, mirror, and mirror-token inputs
remain absent.

The generated upload declares exact name `style-guide-artifacts`, the four
literal artifact paths, `if-no-files-found: error`, `retention-days: 7`,
`compression-level: 6`, `overwrite: false`, and
`include-hidden-files: false`; wildcard/directory-wide paths are prohibited.
Maintain a separate reviewed-default table keyed by action commit/input/default/
rationale/security consequence, and update it whenever a pinned action changes.

Checkout transiently uses the explicit job token and removes configured Git
authentication before returning. Only the temporary push step may additionally
expand the token and construct a process-scoped Git authorization header.
After every checkout, detect—but never print—credential-bearing remote URLs,
helpers, or HTTP authorization configuration. Other generation/diagnostic
processes receive no explicit token/header/helper/config environment.

### 12. Make all Git path/status gates raw and exact

Launch Git with an argument array and redirected streams; parse stdout from
`BaseStream`. Obtain worktree, index, and untracked paths from NUL-delimited
native modes and split only on `00`. Reject missing final NUL, malformed
record/status, duplicate path, decode ambiguity, or unexpected raw path bytes.
Compare sorted ordinal repository-path byte sequences to the exact eight-file
set.

For `git diff --exit-code`, classify `0` as no difference, `1` as difference,
and every other status as native-tool failure. Capture the exit before any
formatting/cleanup/next command and disable external diff/text conversion.
Disposable-repository fixtures include spaces, tabs, leading dashes, quotes,
non-ASCII, and embedded newlines; each must remain one unexpected path rather
than split or disappear.

### 13. Require separately authorized main-branch governance before T1B

Repository settings are not authorized by this issue's affected-file list.
Before T1B implementation, open and approve a separate administrator-owned
settings task containing the current-state export, exact desired/rollback JSON,
approver, execution window, validation, and incident rollback.

The desired persistent branch ruleset is named
`terraform-style-guide-main-protection`, type `branch`, enforcement `active`,
includes exactly `refs/heads/main`, and has no exclusion. It prohibits deletion
and non-fast-forward updates; requires pull requests, resolved conversations,
the exact terminal T1B check `Build Style Guide Artifacts / approve`, and a
current branch for ordinary merges; and contains exactly one bypass actor:
the official GitHub Actions integration ID `15368`, mode `always`. No user,
repository role, administrator, team, deploy key, second app, or exempt-mode
bypass is permitted. Immediately before creation, re-resolve
`GET /apps/github-actions` and require owner `github`, slug `github-actions`,
and ID `15368`; drift stops for review.

The app bypass is broad enough for a direct workflow push, so the repository
workflow-policy validator must continue to prove that only T1B's reviewed
writer job has `contents: write`. It is not a substitute for the exact
workflow graph.

Before persistent activation, use a temporary byte/field-equivalent ruleset
targeting only T1B's unique evidence ref. The real `GITHUB_TOKEN` writer must
succeed for exact-parent/exact-lease, reject stale/lost lease,
non-fast-forward, and deletion attempts, and prove an ordinary maintainer's
direct update is rejected. Record ruleset/app/run/commit/ref identities,
before/after remote values, effective rules, and audit entry; then remove the
temporary rule/ref and prove restoration. Do not weaken/add bypasses or fall
back to an unprotected push.

After T1B's pull-request `approve` check establishes the exact check context,
activate the persistent rule before merging T1B and query effective rules for
`refs/heads/main`. Retain rule ID and normalized rule-JSON SHA-256. Before that
query, use `target main commit` or `reviewed head`, never “protected.” After it,
use `ruleset-protected main`. Successor issues distinguish reviewed head,
actual merge-method commit, and any generated-artifact child commit and
revalidate the live rule/bypass before relying on the handoff.

## Validation

Run validation from a clean disposable clone or worktree. Do not let one
edition overwrite the evidence produced by another.

### Generator byte matrix

For each available supported edition:

- Windows PowerShell exactly 5.1;
- PowerShell Core major 7 on Windows; and
- PowerShell Core major 7 on Ubuntu;

perform:

1. record executable path, edition, full version, OS, and Git version;
2. start from exact committed source and artifact bytes;
3. run the exact generator;
4. capture all four output SHA-256 values;
5. prove no UTF-8 BOM and no `0x0D` byte;
6. prove a second run is byte-for-byte idempotent; and
7. compare hashes across every executed edition.

At minimum, Windows PowerShell 5.1 and one PowerShell 7 run must produce
identical hashes before merge.

Add controlled temporary fixtures proving CRLF and lone CR are converted to LF
at each complete-payload boundary. Restore test-owned state in `finally`.

### Reciprocal PSStyleGuide generator-and-foundation matrix

At implementation start and again before merge, record the exact reviewed
PSStyleGuide commit and its P1 normative location. The closed symmetric catalog
is:

| Stable row | Required comparison |
| --- | --- |
| `GF-PARAMETERS` | Public names/types/defaults and omission/null/empty/raw-value rules |
| `GF-DESTINATION` | Trusted root, allowed destinations, provider/wildcard/rooted-path rules, normalization, comparison, and failure state |
| `GF-CONTENT` | Source order, wrappers/frontmatter, repository-specific names, and complete payload |
| `GF-SERIALIZATION` | CRLF/lone-CR normalization, LF/final newline, BOM-less UTF-8, and byte checks |
| `GF-WRITE` | Complete-payload write path, temporary identity/create, flush/close, atomic replace, and prohibited fallbacks |
| `GF-FAILURE` | Phase postconditions, cleanup/uncertainty, bounded diagnostics, and fault cases |
| `GF-HOSTS` | Editions/hosts, executable identity, cross-cell equality, and idempotence |
| `GF-VERSION` | Timeless marker grammar, explicit expected version, authoring bump gate, and independent fixtures |
| `GF-NODE-LOCK` | Exact Node/npm producer/provenance, cache/side effects, YAML graph, and frozen consumers |
| `GF-YAML` | Parser package/API, document/schema/strictness, diagnostics, and forbidden YAML features |
| `GF-ACTION-PINS` | Closed roles, full pins, publisher/repository/release provenance, internal runtime, and atomic updates |
| `GF-ACTION-INPUTS` | Authored security inputs versus separately inventoried pinned-manifest defaults |
| `GF-GIT` | NUL records, byte allowlists, native statuses, cardinality, refs, ancestry, lease, and refspec |
| `GF-GRAPH` | Production/evidence triggers, permissions, direct needs, conditions, outputs, side effects, and sole writer |
| `GF-CREDENTIALS` | Job-token availability, transient fetch auth, persistence/cleanup, push-only materialization, and absence |
| `GF-EVIDENCE` | Temporary workflow/ref structural equality, drills, retained identities, cleanup, and final absence |

Each row occurs exactly once and records both repository URLs/commits,
normative locators, implementation locators, retained evidence paths/SHA-256,
observed values/fixture IDs, one status
`same|intentional difference|blocker`, and rationale. An intentional
difference names both literals, repository need, equal security/failure
strength, owner, and review/expiry condition. Repository paths/names/payloads
or platform applicability can differ; parser strictness, credential
containment, Git status handling, failure postconditions, or cleanup guarantees
cannot be excused by equal happy-path output.

Duplicate/missing/unknown IDs, changed row meaning, empty evidence/locator, or
unexplained difference is a blocker. If either fixed head moves before merge,
rerun all 16 rows. This is an evidence schema, not a shared runtime dependency;
an unmatched PS contract is recorded as a blocker rather than omitted.

### Node and lint

From `.github/workflows`:

1. resolve the reviewed official Node `24.18.1`/npm `11.16.0` consumer pair;
2. require exact executable paths and versions;
3. save the caller's `CI` environment state;
4. set process-scoped `CI=true` only for `npm ci`;
5. restore the prior `CI` value or absence in `finally`;
6. run both existing lint scripts with the same npm application; and
7. prove package, lockfile, hook, and lint configuration are unchanged.

### Git and workflow policy

Prove:

- `.gitattributes` has exact required content;
- tracked text blobs and the eight staged files contain no CR byte;
- all external actions equal the exact role allowlist;
- negative fixtures reject a mutable tag, arbitrary 40-hex SHA, wrong
  repository, duplicate use, extra workflow, and swapped role;
- Dependabot has exactly one permitted entry;
- workflow permissions did not broaden; and
- the token is expanded only in exact checkout/setup-node inputs and the exact
  temporary push step, never appears in a remote/config/argument/log, and every
  non-checkout diagnostic runs without explicit credential material;
- exactly one temporary contents-writing push path exists; and
- generated artifact blobs are unchanged.

### Exact scope gate

Before staging, require the complete changed/untracked path set to equal the
eight affected files. After `git add --renormalize .`, require the cached path
set to equal the same eight paths. Fail on every additional path, including a
generated artifact.

After all validation, run the generator and lint once more from the exact
staged content and require an empty worktree/index delta beyond those eight
intentional paths.

## Acceptance criteria

- [ ] All four complete payloads normalize CRLF and lone CR immediately before
      explicit BOM-less UTF-8 serialization.
- [ ] Windows PowerShell 5.1 and PowerShell 7 produce identical artifact bytes.
- [ ] Repeated generation is byte-idempotent and the four committed generated
      artifacts remain unchanged.
- [ ] `.gitattributes` contains exactly `* text=auto eol=lf`.
- [ ] Hosted Markdown validation runs on exact Node `24.18.1` with bundled npm
      `11.16.0` and automatic setup-node package-manager caching disabled.
- [ ] Clean installation and both unchanged lint surfaces pass.
- [ ] Package/lock changes are exactly the direct `yaml@2.9.0` parser and its
      reviewed version-3 lock metadata; hook and lint policy do not change.
- [ ] One verified official Node/npm pair performs the one allowed lock rewrite;
      every other cell is a hash-proven frozen consumer.
- [ ] Marker grammar, expected-version identity, and baseline authoring
      progression are tested independently without a runtime clock gate.
- [ ] Every current external action equals its exact official
      repository/SHA/workflow-role/count allowlist row.
- [ ] Mutable, arbitrary, swapped, duplicate, missing, and extra action
      fixtures fail offline.
- [ ] Dependabot has exactly one review-only GitHub Actions entry for `/`.
- [ ] No new writer, candidate download, helper, approval job, secret, or
      external action is activated.
- [ ] The temporary writer uses only process-scoped environment-backed HTTP
      authorization for the exact push and stores no credential.
- [ ] The exact three-job temporary graph, edges, conditions, outputs,
      permissions, step order, side effects, and negative fixtures pass.
- [ ] The reciprocal 16-row generator-and-foundation matrix has no missing,
      duplicate, unknown, or unexplained blocker.
- [ ] T1B is blocked on the separately authorized ruleset task and exact
      temporary real-writer compatibility evidence; no issue file claims
      `main` is protected before effective-rule proof.
- [ ] The exact raw-byte working/staged path gates contain only the eight
      affected files and distinguish Git statuses `0`, `1`, and tool failure.
- [ ] T1A is required to record and validate this issue's actual merge commit;
      this pull request records its reviewed head and successor handoff, not an
      unknowable future merge commit.

## Non-goals

- Candidate ZIP parsing or extraction.
- Caller temporary-root ownership.
- Permanent helper harness implementation.
- Artifact download/promotion or writer redesign.
- Package or lockfile changes beyond the exact YAML parser addition.
- Declaring the final contributor Node minimum.
- Changing hook or lint semantics.
- Hand-editing generated outputs.

## References

- [Node.js release status](https://nodejs.org/en/about/previous-releases)
- [setup-node](https://github.com/actions/setup-node)
- [GitHub secure use reference](https://docs.github.com/en/actions/reference/security/secure-use)
- [Git attributes](https://git-scm.com/docs/gitattributes)
- [git add](https://git-scm.com/docs/git-add)
- [PowerShell about character encoding](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_character_encoding)
- [Dependabot options](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference)
