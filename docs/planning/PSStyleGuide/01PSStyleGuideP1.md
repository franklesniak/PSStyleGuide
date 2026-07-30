# Make artifact generation byte-deterministic across PowerShell editions and hosts

## Summary

Make all four generated style-guide artifacts byte-identical under Windows
PowerShell 5.1 and PowerShell 7 on Windows and Ubuntu. Establish one fixed-root,
multi-file generation transaction; a safe, offline workflow-policy contract;
and a raw NUL-safe Git path-set verifier. Pin the P1 YAML/Node/npm/action supply
tuple and keep both workflows strictly read-only.

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

Generate the lock only with the selected Node/npm pair. Record executable paths,
versions, registry/tarball identities, clean-install tree, and byte-identical
lock no-op. Never hand-edit the lock.

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

### Four-file replacement transaction

Never write a destination with `WriteAllText`, `Set-Content`, `Out-File`, or
truncating/open-in-place behavior. The transaction must:

1. compute all four final byte arrays before any destination mutation;
2. capture ordinary-file metadata and SHA-256 for all existing destinations;
3. create exclusive random candidates and backups in each destination's own
   directory, with restrictive access where supported;
4. write exact candidate bytes through `FileStream`, call `Flush(true)`, close,
   reopen, and verify length/hash/BOM/CR/final-newline expectations;
5. revalidate destination/candidate/backup identity and link/reparse state;
6. replace each existing destination with
   `File.Replace(candidate, destination, backup, false)`;
7. retain every backup until all four replacements and post-verification pass;
   and
8. delete candidates/backups only after success, with bounded cleanup evidence.

On any failure, classify the exact phase and attempt reverse-order restoration
from verified backups. Report `RolledBack` only after all four original
lengths/hashes and path identities are reverified. If the operating system
reports an indeterminate replacement condition, restoration fails, or final
state cannot be proven, report `ReplacementStateUncertain`, retain recoverable
backups, stop, and give bounded manual-recovery paths/hashes. Do not claim
cross-file crash atomicity or that `File.Replace` always preserves one known
name after every platform failure.

Inject failure before/after every create, flush, verify, replace, rollback, and
cleanup boundary. Prove success, honest rollback, and uncertain-state
categories without touching the real repository.

### Script metadata

Retain `#Requires -Version 5.1`. The generator's first published parseable
`.NOTES` version is:

`1.0.<implementation UTC YYYYMMDD>.0`

The unversioned baseline is not an earlier release. Parse and validate the
named metadata field; a guide-document version is not a substitute.

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

Add versioned `Test-ExactGitPathSet.ps1` with `#Requires -Version 5.1`. It
accepts an explicit validated repository root, an exact repository-relative
path array, closed mode `Working`, `Staged`, or `Both`, and optional empty
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

At implementation start and before merge, compare exact PSStyleGuide P1 and
TerraformStyleGuide T1 commits across fixed source/output authority,
path/link rules, serialization, four-file transaction and rollback states,
frontmatter, script version, Node/YAML/npm tuple, action inputs/defaults,
offline fixtures, raw path verifier, native exits, workflow permissions, and
generated byte/idempotence evidence.

For every row retain both evidence identities, status `same`,
`intentional difference`, or `blocker`, and rationale. An unexplained
observable security/failure difference blocks merge. Keep repositories
self-contained.

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
normalization, frontmatter, candidate/flush/replace/rollback/cleanup injected
failures, and `ReplacementStateUncertain`.

Also prove:

- P1's exact Node/YAML/npm tuple, reproducible lock, clean install, and both
  existing outer/nested lint surfaces;
- package/hook/lint declarations unchanged except the YAML parser;
- exact workflow events, permissions, jobs, roles, authored inputs, reviewed
  defaults, and stable diagnostic predicate;
- every workflow-policy and hostile Git-path fixture passes offline;
- no write permission, stage, commit, push, credential derivation, candidate
  helper, download, matrix approval, or final writer exists;
- `.gitattributes` and all applicable tracked text blobs satisfy LF/BOM rules;
- generated destination blobs remain unchanged;
- working and staged sets equal exactly the ten affected paths; and
- validation from staged content produces no additional diff.

Run `git add --renormalize .` only in a disposable validation worktree. Any
unrelated changed path stops for rebaseline.

## Acceptance criteria

- [ ] The fixed two-source/four-destination authority rejects caller path/root
      substitution and every link/reparse/escape.
- [ ] All four payloads are computed before one honest replace/rollback
      transaction; no destination is truncated in place.
- [ ] Success, `RolledBack`, and `ReplacementStateUncertain` are proven with
      injected failures.
- [ ] Windows PowerShell 5.1 and PowerShell 7 produce byte-identical,
      idempotent BOM-less/LF artifacts, with committed outputs unchanged.
- [ ] Generator version is `1.0.<implementation UTC YYYYMMDD>.0`.
- [ ] The exact re-resolved YAML/Node/npm tuple and reproducible lock evidence
      are recorded.
- [ ] Both workflows are unfiltered and read-only; generation only detects
      drift.
- [ ] Every action role/input/default equals the closed contract.
- [ ] The workflow policy/case catalogs and validator pass all offline cases.
- [ ] The raw NUL-safe path verifier passes required hostile-path cells.
- [ ] Dependabot contains exactly one review-only Actions entry.
- [ ] The advisory-risk gate is current and P1↔T1 has no unexplained blocker.
- [ ] The working/staged path sets contain exactly the ten affected files.

## Handoff

Give P1A the permanent P1 issue/PR URLs, reviewed head/base, merge method,
landed commit/tree, generator version/hash, policy schema/version/hashes, path
verifier version/hash, exact action manifest/default evidence, supply tuple,
generator matrix, advisory decision, and P1↔T1 matrix. P1A must compare these
landed contracts with its assumptions before implementation.

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
