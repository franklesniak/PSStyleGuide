# Make artifact generation byte-deterministic and standardize repository text checkouts on LF

## Summary

Make the style-guide generator emit identical UTF-8 bytes under Windows
PowerShell 5.1 and PowerShell 7, and establish LF as the repository checkout
policy. Move the Markdown workflow to hosted Node 24, pin every currently used
external action to a reviewed full commit SHA, and add review-only GitHub
Actions dependency updates.

This issue establishes foundations only. It does not add the candidate ZIP
validator or activate the new artifact-promotion writer. It also establishes
the reciprocal generator-layer contract with PSStyleGuide without introducing
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

### 4. Use exact hosted Node 24

In `.github/workflows/markdownlint.yml`:

- use the reviewed setup-node action commit from the action table below;
- configure:

  ```yaml
  with:
    node-version: '24'
    package-manager-cache: false
  ```

- resolve the actual Node process before installation;
- require exact major 24 and log the full Node and npm versions;
- run a clean `npm ci`;
- run the unchanged outer Markdown lint command;
- run the unchanged nested-Markdown lint command; and
- classify the native exit of each phase.

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

### 9. Publish and consume one parseable generator version

The script-level comment help before the first function contains exactly one:

```text
Version: 1.0.YYYYMMDD.0
```

The four decimal components must parse as `[System.Version]`; Build is exactly
eight digits and a real UTC date. Use the actual implementation UTC date,
recomputing it if work crosses midnight. Later published changes increment
Major for breaking public/output changes or Minor for nonbreaking capability,
always set Build to the modification UTC date, reset Revision to `0` when
Major/Minor/Build changes, and otherwise increment Revision.

Reject missing, duplicate, malformed, impossible/stale date, extra component,
sign/whitespace, or a decoy function-level `Version:`. The version is human
metadata and never substitutes for commit, ordinary-file identity, or SHA-256.
T1A and T1B consume this exact parser/semantics.

### 10. Add the permanent locked workflow-policy validator now

Add exact direct `"yaml": "2.9.0"` to `devDependencies` and update the
version-3 lockfile with the reviewed official tarball/integrity and no
lifecycle scripts. Immediately before implementation, re-resolve the package
and integrity and rerun the dated audit decision; drift or a policy-blocking
finding requires review/rebaseline.

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
and exact Node-24 assertion used by lint, then prove offline execution.

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
declares exactly `node-version: '24'`, `check-latest: false`,
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

### Reciprocal PSStyleGuide generator-layer matrix

At implementation start and again before merge, record the exact reviewed
PSStyleGuide commit and the current generator-layer location (the exact P1
section or its eventual P1 generator issue identifier). Compare:

| Contract row | Required evidence |
| --- | --- |
| public generator parameters | names, types, defaults, omission rules |
| destination resolution | one filesystem path; wildcard, provider, missing, and multi-match behavior |
| content assembly | source order, wrapper/frontmatter, and final payload |
| byte serialization | CRLF/lone-CR normalization, LF, UTF-8 without BOM, final-newline behavior |
| write boundary | exactly one explicit complete-payload write per artifact |
| failure destination state | preexisting/absent destination postcondition and diagnostics |
| edition/host tests | Windows PowerShell 5.1 and PowerShell 7 evidence |

For every row, record PS evidence, Terraform evidence, status (`same`,
`intentional difference`, or `blocker`), and rationale. Identical
security/error/byte behavior is the default. Repository paths, manifest names,
and workflow topology may differ intentionally. Every deliberate difference
requires a repository-specific reason and stable evidence; every unexplained
difference blocks merge. Add a short human-readable summary above the complete
matrix. Store it in the pull request or a tracked planning artifact.

### Node and lint

From `.github/workflows`:

1. resolve and record one Node/npm application pair;
2. require the observed Node major to be 24;
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
- [ ] Hosted Markdown validation runs on actual Node major 24 with automatic
      setup-node package-manager caching disabled.
- [ ] Clean installation and both unchanged lint surfaces pass.
- [ ] Package/lock changes are exactly the direct `yaml@2.9.0` parser and its
      reviewed version-3 lock metadata; hook and lint policy do not change.
- [ ] Every current external action equals its exact official
      repository/SHA/workflow-role/count allowlist row.
- [ ] Mutable, arbitrary, swapped, duplicate, missing, and extra action
      fixtures fail offline.
- [ ] Dependabot has exactly one review-only GitHub Actions entry for `/`.
- [ ] No new writer, candidate download, helper, approval job, secret, or
      external action is activated.
- [ ] The temporary writer uses only process-scoped environment-backed HTTP
      authorization for the exact push and stores no credential.
- [ ] The reciprocal generator-layer matrix has no unexplained blocker.
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
- Package or lockfile upgrades.
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
