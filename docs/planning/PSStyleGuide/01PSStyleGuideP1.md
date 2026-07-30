# Make artifact generation byte-deterministic across PowerShell editions and hosts

## Summary

Make all four generated style-guide artifacts byte-identical under Windows
PowerShell 5.1 and PowerShell 7 on Windows and Ubuntu. Establish one fixed-root,
complete-payload generation contract with one private per-artifact writer; a
safe, offline workflow-policy contract; a raw NUL-safe Git path-set verifier;
and the slate-wide PowerShell script-version profile. Pin the P1
YAML/Node/npm/action supply tuple and keep both workflows strictly read-only.

Require a separately authorized administrator task to establish and prove the
branch rule that makes P1B's later workflow the sole direct updater of `main`.
Repository settings are not part of P1's implementation-file scope.

P1 establishes shared foundations only. P1A owns candidate validation, P1B owns
publication, P2 owns the guide-content change, and P3 supersedes the interim
Node/npm policy while remediating dependencies.

## Slate order and issue identity

Execute the PSStyleGuide slate in this order:

1. P1 — this issue;
2. P1A — **Add a fail-closed cross-platform style-guide candidate validator**;
3. P1B — **Promote generated style-guide artifacts through a
   least-privileged verified writer**;
4. P2 — **Make the non-compliant blank-line example visibly distinct**; and
5. P3 — **Remediate Markdown lint dependency advisories and add npm update
   governance**.

Draft bodies contain titles, never fabricated URLs or issue numbers. File each
successor with `gh issue create --blocked-by <predecessor-url>` when supported;
otherwise create it and immediately add the dependency through GitHub's
supported issue-dependency operation. After every creation, retrieve both
issues and verify repository, number, title, canonical URL, and the `blockedBy`
edge. Retain the five canonical URLs and four verified edges.

Implementation readiness is a later gate, not the filing transaction. Before
P1A or a later phase starts, record for every consumed predecessor:

- permanent issue and reviewed pull-request URLs;
- reviewed head and base commits;
- merge method;
- landed commit(s) and tree; and
- exact contract paths, schema/interface versions, and retained evidence.

Compare landed state with the issue assumptions. A material difference stops
implementation for issue review and reruns all affected validation. Do not
equate issue creation, PR approval, merge, and implementation readiness.

## Advisory-risk gate

Before editing, obtain a dated accountable decision permitting the current npm
advisory state to remain through P2 until P3. Record approver/role and policy,
canonical UTC approval/expiry, exact audit command and native outcome,
Node/Corepack/npm identities, raw-response digest, finding inventory, reason
for sequencing, compensating controls, prohibited package changes, and a hard
expiry no later than P3 completion.

Rerun the exact audit at P1 start. Missing, expired, unauthorized, or materially
worsened evidence stops implementation. If policy does not permit the wait,
rebaseline the slate with the smallest dependency-remediation predecessor;
do not improvise lint dependency changes in P1.

## Separately authorized `main` governance

The current repository has no ruleset or classic branch protection for `main`.
Before P1B implementation, open and approve a separate administrator-owned
settings task containing:

- the current-state export and digest;
- exact desired and rollback JSON;
- accountable approver and role;
- execution window and prerequisites;
- validation and retained audit evidence; and
- incident rollback and restoration proof.

The desired persistent branch ruleset is named
`ps-style-guide-main-protection`, type `branch`, enforcement `active`, includes
exactly `refs/heads/main`, and has no exclusion. It prohibits deletion and
non-fast-forward updates; requires pull requests, resolved conversations, the
stable P1B terminal check `Build Style Guide Artifacts / approve_candidate`
from the GitHub Actions application, and a current branch for ordinary merges;
and contains exactly one bypass actor: the official GitHub Actions integration
ID `15368`, mode `always`.

No user, repository role, administrator, team, deploy key, second application,
or `exempt`-mode bypass is permitted. Immediately before temporary or
persistent rule creation, re-resolve `GET /apps/github-actions` and require
owner `github`, slug `github-actions`, and ID `15368`; drift stops for review.
The app bypass is broad enough for a direct workflow push, so the workflow
policy must continue to prove that only P1B's reviewed writer has
`contents: write`.

Before persistent activation, use a temporary field-equivalent rule targeting
only P1B's unique evidence ref. The real P1B writer must succeed for the exact
parent/lease, while stale/lost lease, non-fast-forward, deletion, and an
ordinary maintainer's direct update fail without moving the ref. Retain
rule/application/run/commit/ref identities, before/after remote values,
effective rules, and audit evidence, then remove the temporary rule/ref and
prove restoration.

After P1B's pull request produces the exact terminal check context, activate
the persistent rule before merging P1B and query the active rules applying to
`main`. Retain the rule ID, normalized rule-JSON SHA-256, effective-rule
result, required check/source, sole bypass identity, and rollback proof.
Before that query use “target `main` commit” or “reviewed head,” not “protected
`main`.” P1B is blocked on this settings task. P2 and P3 must re-query the
same state before consuming the publication handoff.

## Affected files

Exactly these ten implementation paths may change:

- `.github/workflows/Generate-StyleGuideArtifacts.ps1`;
- `.github/workflows/build.yml`;
- `.github/workflows/markdownlint.yml`;
- `.github/workflows/Validate-WorkflowPolicy.mjs` — add;
- `.github/workflows/workflow-policy-contract.json` — add;
- `.github/workflows/workflow-policy-cases.json` — add;
- `.github/workflows/Test-ExactGitPathSet.ps1` — add;
- `.github/workflows/package.json`;
- `.github/workflows/package-lock.json`; and
- `.github/dependabot.yml` — add.

Package/lock changes are limited to exact `yaml@2.9.0` and its reproducible
lock resolution. Do not change the existing lint/hook dependency graph.

Do not modify `.gitattributes`; it must remain exactly:

```gitattributes
* text=auto eol=lf
```

The generator exercises these destinations, but their committed bytes must not
change:

- `copilot-instructions.md`;
- `powershell.instructions.md`;
- `STYLE_GUIDE_CHAT.md`; and
- `STYLE_GUIDE_FULL.md`.

Do not hand-edit generated artifacts.

## Frozen P1 supply tuple

Materialize the complete tuple and both gate results as the immutable
`P1-SUPPLY-FREEZE-v1` record. It includes exact `package.json` and
`package-lock.json` HEAD/stage-0 blob IDs and SHA-256, reviewed working bytes,
Node/npm identities, the sole lock/install producer argv, canonical installed
package-tree identity, normalized audit findings, and the dated policy
decision. P1B consumes this named record without reinterpretation.

Use:

- `yaml@2.9.0`, registry integrity
  `sha512-2AvhNX3mb8zd6Zy7INTtSpl1F15HW6Wnqj0srWlkKLcpYl/gMIMJiyuGq2KeI2YFxUPjdlB+3Lc10seMLtL4cA==`
  and tarball `https://registry.npmjs.org/yaml/-/yaml-2.9.0.tgz`;
- Node `24.18.1`;
- the npm `11.16.0` bundled with that Node release as the sole P1 lock
  producer; and
- exact setup-node `node-version: '24.18.1'`.

Before implementation, independently query the official npm registry and
record the exact tarball URL, integrity, bytes, and SHA-256/SHA-512. Resolve
the same complete tuple again immediately before merge. A changed version,
tarball, integrity, Node patch, bundled npm, engine constraint, or security
status requires renewed review and an atomic tuple/lock update.

From a clean disposable clone, verify the official Node artifact against its
signed release checksums, use the selected Node/npm pair, set only exact
`"yaml": "2.9.0"`, and run exactly:

```text
npm install --package-lock-only --ignore-scripts --no-audit --no-fund
```

Record executable paths/versions, Node artifact/checksum/signature evidence,
registry/tarball identities, and effective registry/proxy/certificate/peer/
lock/script/audit/fund configuration with secrets redacted. Record pre/post
manifest and lock hashes. Every nonproducer runtime is a frozen
`npm ci --ignore-scripts --no-audit --no-fund` consumer and must leave
manifest and lock bytes unchanged. Never hand-edit the lock. P3 still owns the
durable hash-qualified package-manager policy.

## Generator contract

### Fixed source/output authority

`Generate-StyleGuideArtifacts.ps1` has no public repository-root, source-path,
destination-path, or output-map override. Anchor one canonical repository root
to `$PSScriptRoot`, validate every ancestor/component as an expected ordinary
non-link/reparse path, and use this closed map:

| Sources | Destinations |
| --- | --- |
| `STYLE_GUIDE.md`; `STYLE_GUIDE_RATIONALE.md` | `copilot-instructions.md`; `powershell.instructions.md`; `STYLE_GUIDE_CHAT.md`; `STYLE_GUIDE_FULL.md` |

Reject a missing/unexpected source, destination, duplicate identity,
containment escape, wildcard/provider syntax, symlink, junction, reparse point,
or path identity alias before reading or writing. Keep the transformation core
pure: raw source bytes in, four complete payload byte arrays out. Production
alone supplies the fixed map.

Build `powershell.instructions.md` frontmatter from an explicit line array
joined with LF. Preserve exact keys, values, quoting, closing delimiter, and
two following blank lines. Normalize CRLF and lone CR only after all content
transformation:

```powershell
$strNormalizedContent = $CompleteFinalPayload -replace "`r`n?", "`n"
```

Encode with `System.Text.UTF8Encoding($false)` and add no implicit final
newline.

### Complete-payload generation and private artifact writer

Compute and validate all four complete final byte arrays before any destination
mutation. `Write-StyleGuideArtifact` is the only permitted final-write
boundary and accepts only a closed artifact ID mapped to one fixed destination:

| Artifact ID | Exact destination leaf |
| --- | --- |
| `copilot` | `copilot-instructions.md` |
| `powershell-instructions` | `powershell.instructions.md` |
| `chat` | `STYLE_GUIDE_CHAT.md` |
| `full` | `STYLE_GUIDE_FULL.md` |

Reject null, empty/whitespace, controls, wildcard/provider syntax, relative or
drive-relative paths, artifact/path mismatch, containment escape, alias,
link/reparse components, nonordinary parent, or nonordinary destination before
writing. Every destination must already exist as a tracked ordinary file.

For each artifact in the fixed order, create one unpredictable same-directory
sibling with bounded real-collision retries using `FileMode.CreateNew`,
`FileAccess.Write`, and `FileShare.None`; write the complete byte array through
`FileStream`; call `Flush(true)`; close; reopen; and verify exact length,
SHA-256, BOM/CR/final-newline expectations. Revalidate parent, destination, and
temporary identity, then call `File.Replace(candidate,destination,$null)`
exactly once.

- Before `File.Replace` returns, any failure requires the old destination to
  remain byte-identical and removes only the proven temporary sibling.
- After `File.Replace` returns, the complete new destination and absent
  temporary name are committed success; no fallible semantic gate follows.
- Unsupported replacement, cleanup failure, or uncertain filesystem state
  fails closed without backup/copy/move/direct-write fallback.

Do not claim cross-file crash atomicity. A later-artifact failure may leave
earlier complete replacements visible and must report that exact state; the
generator never claims rollback. Fault-injection cases cover every phase from
pre-create through cleanup on all required hosts without touching the real
repository.

The versioned generator result has exact ordered fields for schema/generator
version, overall `Success|NoChange|Failed|ReplacementStateUncertain`, stable
phase/category/native outcome/exit, and one fixed-order per-artifact record.
Each artifact record contains ID/path, original/candidate/final
length/SHA-256/ordinary identity, replace-returned flag, temporary disposition,
and cleanup result. Unknown combinations fail. Success requires all four final
hashes; uncertainty preserves bounded verified recovery identity without
printing content or hostile bytes.

### Slate-wide PowerShell script versions

Retain `#Requires -Version 5.1`. Every governed PowerShell script has exactly
one complete marker in the script-level `.NOTES` block before its first
function:

```text
Version: <Major>.<Minor>.<YYYYMMDD>.<Revision>
```

The common raw parser is timeless. Components contain ASCII digits only, have
no sign/whitespace/extra component or leading zero except `0`, fit
`System.Version` nonnegative bounds, round-trip canonically, and use a real
invariant proleptic-Gregorian Build date. Parsing reads no clock, Git or
filesystem timestamp, or network. Missing, duplicate, out-of-location/decoy,
malformed, overflow, impossible-date, and component-count failures are
`invalid-version`.

A separately trusted consumer binds the exact expected canonical version to
the reviewed fixed path, commit, Git blob, and SHA-256. Valid but unequal is
`unexpected-version`; version never substitutes for code identity.

Only implementation/merge validation enforces authoring progression. Record
the merge-base blob/version or `absent`, semantic change class, accountable
author, and UTC date of the final material edit. New scripts start
`1.0.<date>.0`; a breaking contract increments Major and resets Minor/
Revision; a compatible capability increments Minor and resets Revision; a
correction preserves Major/Minor, uses the final-edit date, resets Revision
when Build changes, and otherwise increments Revision by exactly one. Test
execution alone never bumps a version. Violations are `version-progression`.

The generator and `Test-ExactGitPathSet.ps1` both first publish
`1.0.<implementation UTC YYYYMMDD>.0`. The unversioned baseline is not an
earlier release. P1A and P3 consume this same grammar, trust separation,
progression rule, and failure taxonomy for every PowerShell script.

## Workflow and action policy

Set workflow-level `permissions: {}`. Every P1 job is read-only and declares
only `contents: read`. Run build verification for every pull request targeting
`main` and every push to `main`, without workflow path filters or skip-commit
logic. Generation checks drift and fails on differences; it never stages,
commits, pushes, receives write permission, or constructs a push credential.
P1B introduces the sole writer.

Pin these reviewed releases to full SHAs, re-resolving tag, release, repository,
manifest digest, and defaults before implementation and merge:

| Action | Full commit SHA | Release |
| --- | --- | --- |
| `actions/checkout` | `3d3c42e5aac5ba805825da76410c181273ba90b1` | `v7.0.1` |
| `actions/setup-node` | `820762786026740c76f36085b0efc47a31fe5020` | `v7.0.0` |
| `actions/upload-artifact` | `043fb46d1a93c77aae656e7c1c64a875d1fc6a0a` | `v7.0.1` |

The normative role/input table is:

| Workflow/job/step | Action | Condition | Authored `with` inputs |
| --- | --- | --- | --- |
| `build.yml/verify_generated_artifacts/checkout_repository` | checkout SHA above | ordinary | `repository: ${{ github.repository }}`; `ref: ${{ github.sha }}`; `token: ${{ github.token }}`; `persist-credentials: false`; `clean: true`; `fetch-depth: 1`; `fetch-tags: false`; `show-progress: true`; `lfs: false`; `submodules: false`; `set-safe-directory: true`; `allow-unsafe-pr-checkout: false` |
| `build.yml/verify_generated_artifacts/upload_failure_diagnostics` | upload SHA above | `${{ failure() && !cancelled() }}` | exact run/job/attempt name; exact producer path; `if-no-files-found: error`; `retention-days: 7`; `compression-level: 0`; `overwrite: false`; `include-hidden-files: false`; `archive: true` |
| `markdownlint.yml/markdownlint/checkout_repository` | checkout SHA above | ordinary | same closed checkout inputs |
| `markdownlint.yml/markdownlint/setup_node` | setup-node SHA above | ordinary | `node-version: '24.18.1'`; `check-latest: false`; `token: ${{ github.token }}`; `package-manager-cache: false` |

`workflow-policy-contract.json` records every manifest input as exactly one of
`Authored`, `ReviewedDefault`, or `NotApplicable`, including credential,
checkout clean/fetch, cache, extraction, retention, overwrite, and unsafe-link
behavior. It stores the exact pinned `action.yml` URL/digest and reviewed
default shape. Unknown, duplicate, omitted-without-disposition, or extra
literal inputs fail.

Failure diagnostics use the exact name
`style-guide-verification-${{ github.job }}-${{ github.run_id }}-${{ github.run_attempt }}`
and a fresh job-owned `RUNNER_TEMP` directory. The producer writes one bounded,
redacted, BOM-less/LF summary with stable phase/native-exit/path/size/hash
fields and may copy only a verified bounded ordinary generated destination.
Never copy sources, environment, credentials, Git config, remote URLs, or
arbitrary logs. Producer and upload may use `continue-on-error: true`; neither
may hide the primary failure.

## Offline workflow-policy fixtures

Implement `Validate-WorkflowPolicy.mjs` over exact `yaml@2.9.0` with safe/core
schema settings. Reject duplicate keys, aliases, merge keys, custom tags,
unknown shapes, dynamic names/expressions where literals are required,
unbounded nodes, mutable actions, remote reusable workflows, cache roles,
credential persistence, auto-extraction, write permissions, unknown roles, and
role/input/default drift.

`workflow-policy-contract.json` is the single machine-readable contract.
`workflow-policy-cases.json` is the single versioned, namespaced positive/
negative case catalog. Tests generate disposable workflow/manifest fixtures
from it and remain offline; no copied third-party manifest or temporary
fixture workflow is production authority. Cover missing/extra/duplicate/
swapped jobs and steps, trigger/permission/needs/condition mutation, wrong
repository/SHA/comment/input/default, writer introduction, dynamic values,
parser hazards, and every action-input disposition.

## Exact Git path-set verifier

Add `Test-ExactGitPathSet.ps1` with `#Requires -Version 5.1` and first version
`1.0.<implementation UTC YYYYMMDD>.0` under the P1 version profile. It accepts
an explicit validated repository root, an exact repository-relative path
array, closed mode `Working`, `Staged`, or `Both`, and optional empty
working-versus-index requirement.

Resolve Git as an application and use `System.Diagnostics.Process` with
argument arrays and raw redirected bytes:

- `git diff --no-renames --name-only -z`;
- `git diff --cached --no-renames --name-only -z`; and
- `git ls-files --others --exclude-standard -z`.

Capture native status immediately. Split only on byte `0x00`, require exact
termination/cardinality, and compare raw expected ASCII bytes ordinally.
Never decode or print hostile path bytes. Emit stable missing, unexpected,
malformed, and native-command categories. Disposable repositories cover spaces,
tabs, quotes, backslashes, newline-bearing names, supported non-ASCII names,
deletion, rename, untracked, and mixed staged/unstaged state under Windows
PowerShell 5.1 and PowerShell 7.

All complete PowerShell workflow blocks explicitly select `powershell` or
`pwsh`, start with `$ErrorActionPreference = 'Stop'`, capture
`$LASTEXITCODE` immediately, validate output shape, and fail nonzero. Treat
`git diff --exit-code` status 0 as equal, 1 as ordinary difference, and every
other status as command failure.

## Dependabot

Add exactly one review-only `github-actions` entry for `/` on a weekly
schedule. No automatic approval or merge. Every proposal requires release,
provenance, SHA, runtime, manifest/default, and role-table review. P3 adds the
second npm entry for `/.github/workflows`.

## Reciprocal P1↔T1 comparison

At implementation start and before merge, compare exact immutable P1/T1
commits using this closed symmetric catalog:

| Stable row | Required comparison |
| --- | --- |
| `GF-PARAMETERS` | Public names/types/defaults and omission/null/empty/raw-value rules |
| `GF-DESTINATION` | Trusted root, mapped destinations, provider/wildcard/root rules, normalization, comparison, failure |
| `GF-CONTENT` | Source order, wrappers/frontmatter, repository-specific names, complete payload |
| `GF-SERIALIZATION` | CR/lone-CR normalization, LF/final newline, BOM-less UTF-8, byte checks |
| `GF-WRITE` | Complete payload, temporary identity/create, flush/close, atomic replace, prohibited fallbacks |
| `GF-FAILURE` | Phase postconditions, cleanup/uncertainty, bounded diagnostics, fault cases |
| `GF-HOSTS` | Editions/hosts, executable identity, equality, idempotence |
| `GF-VERSION` | Timeless grammar, trusted expected version, authoring gate, fixtures |
| `GF-NODE-LOCK` | Exact producer/provenance/config, YAML graph, frozen consumers |
| `GF-YAML` | Parser package/API, document/schema strictness, diagnostics, forbidden features |
| `GF-ACTION-PINS` | Roles, full pins, provenance, runtime, atomic updates |
| `GF-ACTION-INPUTS` | Authored security inputs and reviewed manifest defaults |
| `GF-GIT` | NUL records, byte allowlists, statuses, cardinality, refs, lease/refspec |
| `GF-GRAPH` | Production/evidence triggers, permissions, needs, conditions, outputs, side effects, writer |
| `GF-CREDENTIALS` | Job-token availability, auth projection, cleanup, push-only materialization |
| `GF-EVIDENCE` | Temporary workflow/ref/rule equality, drills, retained identities, cleanup, absence |

Each row occurs exactly once and records both repository URLs/commits,
normative and implementation locators, evidence paths/SHA-256, observed
values/fixture IDs, one status `same|intentional difference|blocker`, and
rationale. An intentional difference names both literals, repository need,
equal security/failure strength, owner, and review/expiry condition. Duplicate,
missing, unknown, renamed, empty, or unexplained rows block merge. Repository
payloads/names and P1's lack of a temporary writer can differ; path security,
serialization, version parsing, native status, credential containment, and
failure truth cannot. Keep both repositories self-contained.

## Validation

Use clean disposable clones/worktrees. Never let one runtime overwrite another
cell's evidence.

For Windows PowerShell 5.1 on Windows, PowerShell 7 on Windows, and PowerShell
7 on Ubuntu:

1. record executable, edition/version, OS, and Git;
2. start from exact committed source/artifact bytes;
3. run generation;
4. capture all four SHA-256 values;
5. prove no UTF-8 BOM or `0x0D`;
6. prove second-run byte idempotence; and
7. compare hashes across cells.

At minimum, Windows PowerShell 5.1 and one PowerShell 7 cell must match.
Exercise fixed-map success, path/link/reparse rejection, CRLF/lone-CR
normalization, frontmatter, every candidate/flush/replace/cleanup injected
failure, partial earlier-artifact success, and
`ReplacementStateUncertain`.

Also prove:

- P1's exact Node/YAML/npm tuple, reproducible lock, clean install, and both
  existing outer/nested lint surfaces;
- every timeless/expected/progression version case for both P1 scripts;
- package/hook/lint declarations unchanged except the YAML parser;
- exact workflow events, permissions, jobs, roles, authored inputs, reviewed
  defaults, and stable diagnostic predicate;
- every workflow-policy and hostile Git-path fixture passes offline;
- no write permission, stage, commit, push, credential derivation, candidate
  helper, download, matrix approval, or final writer exists;
- `.gitattributes` and all applicable tracked text blobs satisfy LF/BOM rules;
- generated destination blobs remain unchanged;
- the separately authorized settings task is approved, with exact desired and
  rollback JSON, and P1B remains blocked on its temporary/persistent proof;
- all 16 reciprocal rows occur once with no unexplained blocker;
- working and staged sets equal exactly the ten affected paths; and
- validation from staged content produces no additional diff.

Run `git add --renormalize .` only in a disposable validation worktree. Any
unrelated changed path stops for rebaseline.

## Acceptance criteria

- [ ] The fixed two-source/four-destination authority rejects caller path/root
      substitution and every link/reparse/escape.
- [ ] All four payloads are computed before fixed-order private per-artifact
      replacement; no destination is truncated in place.
- [ ] Every per-artifact success/failure, partial complete replacement, cleanup,
      and `ReplacementStateUncertain` result is truthful under injected faults.
- [ ] Windows PowerShell 5.1 and PowerShell 7 produce byte-identical,
      idempotent BOM-less/LF artifacts, with committed outputs unchanged.
- [ ] Generator and path verifier versions, expected identities, timeless
      grammar, and authoring progression pass the P1 profile.
- [ ] The exact re-resolved YAML/Node/npm tuple, verified producer command/
      configuration, frozen consumers, and reproducible lock evidence exist.
- [ ] Both workflows are unfiltered and read-only; generation only detects
      drift.
- [ ] Every action role/input/default equals the closed contract.
- [ ] The workflow policy/case catalogs and validator pass all offline cases.
- [ ] The raw NUL-safe path verifier passes required hostile-path cells.
- [ ] Dependabot contains exactly one review-only Actions entry.
- [ ] The advisory-risk gate is current; the separately authorized ruleset
      task is approved and blocks P1B until its evidence; P1↔T1's 16 rows have
      no unexplained blocker.
- [ ] The working/staged path sets contain exactly the ten affected files.

## Handoff

Give P1A the permanent P1 issue/PR URLs, reviewed head/base, merge method,
landed commit/tree, generator version/hash, policy schema/version/hashes, path
verifier version/hash, exact action manifest/default evidence, supply tuple,
generator result/host matrix, script-version profile, verified lock-producer
record, advisory decision, settings-task URL/approved desired and rollback
digests, and P1↔T1 matrix. P1A must compare these landed contracts with its
assumptions before implementation.

## Non-goals

- Candidate ZIP validation/extraction or caller-owned temporary roots.
- Publication, staging, committing, pushing, or any temporary/final writer.
- Source-guide or generated-artifact content changes.
- Lint/hook dependency remediation or final contributor Node policy.
- A shared cross-repository runtime package.

## References

- [PSStyleGuide Function and Script Versioning](https://github.com/franklesniak/PSStyleGuide/blob/main/STYLE_GUIDE.md#function-and-script-versioning)
- [PowerShell unresolved provider paths](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.pathintrinsics.getunresolvedproviderpathfrompspath)
- [PowerShell character encoding](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_character_encoding)
- [File.Replace](https://learn.microsoft.com/en-us/dotnet/api/system.io.file.replace)
- [ReplaceFile failure behavior](https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-replacefilea)
- [FileStream.Flush(Boolean)](https://learn.microsoft.com/en-us/dotnet/api/system.io.filestream.flush)
- [yaml 2.9.0 registry record](https://registry.npmjs.org/yaml/2.9.0)
- [Official Node distribution index](https://nodejs.org/dist/index.json)
- [npm 11.16.0 registry record](https://registry.npmjs.org/npm/11.16.0)
- [GitHub workflow permissions](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#permissions)
- [Pinned checkout manifest](https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml)
- [Pinned setup-node manifest](https://raw.githubusercontent.com/actions/setup-node/820762786026740c76f36085b0efc47a31fe5020/action.yml)
- [Pinned upload-artifact manifest](https://raw.githubusercontent.com/actions/upload-artifact/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a/action.yml)
- [Git status pathname format and `-z`](https://git-scm.com/docs/git-status#_pathname_format_notes_and_z)
- [Git attributes](https://git-scm.com/docs/gitattributes)
