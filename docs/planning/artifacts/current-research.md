# PSStyleGuide slate revision research

Research date: 2026-07-29.

This artifact preserves the primary-source facts used to evaluate and revise the
PSStyleGuide P1/P2 issue slate. It records exact source locations, release
identities, and the practical implication for the issues.

## P1-1: GitHub Actions and Node runtime

### GitHub Node 20 retirement

Source:
[GitHub Changelog: Deprecation of Node 20 on GitHub Actions runners](https://github.blog/changelog/2025-09-19-deprecation-of-node-20-on-github-actions-runners/)

Reviewed facts:

- Node 20 reached end of life in April 2026.
- GitHub began making Node 24 the default action runtime on 2026-06-16.
- The insecure Node-version opt-out is temporary.
- GitHub plans to remove Node 20 from runners in fall 2026.
- GitHub tells action users to move to current action releases that run on
  Node 24.

### Checkout v7.0.1

Sources:

- [Release](https://github.com/actions/checkout/releases/tag/v7.0.1)
- [Exact metadata](https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml)
- [Exact README](https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/README.md)

Exact tag resolution:

```text
3d3c42e5aac5ba805825da76410c181273ba90b1 refs/tags/v7.0.1
```

Reviewed facts:

- GitHub released v7.0.1 on 2026-07-20, before P1's claimed
  2026-07-28 v6.0.2 snapshot.
- The action declares `runs.using: node24`.
- V7 retains v6's credential storage beneath `RUNNER_TEMP`; ordinary
  authenticated `git fetch` and `git push` remain supported.
- V7 adds safer handling for privileged fork-checkout contexts and refreshed
  dependencies/security fixes.
- P1 uses only `push` and `pull_request`, not the privileged
  `pull_request_target` or `workflow_run` cases gated by v7's new input.

### Setup-node v7.0.0

Sources:

- [Release](https://github.com/actions/setup-node/releases/tag/v7.0.0)
- [Exact metadata](https://raw.githubusercontent.com/actions/setup-node/820762786026740c76f36085b0efc47a31fe5020/action.yml)
- [Exact README](https://raw.githubusercontent.com/actions/setup-node/820762786026740c76f36085b0efc47a31fe5020/README.md)
- [Moving v4 metadata](https://raw.githubusercontent.com/actions/setup-node/v4/action.yml)

Exact tag resolution:

```text
820762786026740c76f36085b0efc47a31fe5020 refs/tags/v7.0.0
```

Reviewed facts:

- GitHub released v7.0.0 on 2026-07-14.
- V7 declares `runs.using: node24`; the current moving v4 action declares
  `runs.using: node20`.
- The current PSStyleGuide Markdown workflow also asks setup-node to install
  Node 20, independently of the action's own runtime.
- V7 can automatically enable npm caching when package-manager metadata is
  present. Its documentation recommends `package-manager-cache: false` when
  caching is unnecessary, especially for privileged workflows.
- The action recommends explicit `permissions: contents: read`.

### Node.js release schedule

Source:
[Node.js Release Working Group schedule](https://github.com/nodejs/Release#release-schedule)

Reviewed facts:

- Node 24 is Active LTS on the review date.
- Node 24 enters Maintenance LTS on 2026-10-20 and reaches end of life on
  2028-04-30.
- Node 26 is Current, not yet Active LTS, on the review date.

Implication: Node 24 is the stable toolchain target for the Markdown workflow.

### Full-SHA pinning and permissions

Sources:

- [GitHub secure-use reference](https://docs.github.com/en/actions/reference/security/secure-use)
- [GitHub workflow `permissions`](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#permissions)

Reviewed facts:

- GitHub describes a full-length commit SHA as the only immutable action
  reference.
- Unspecified token permissions inherit enterprise, organization, or repository
  defaults, which may be permissive.
- Declaring one permission makes unspecified permissions `none`.

Implication: pin checkout and setup-node by full SHA and declare
`contents: read` in the Markdown workflow rather than relying on defaults.

### Artifact action verification

Sources:

- [upload-artifact v7.0.1 exact metadata](https://raw.githubusercontent.com/actions/upload-artifact/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a/action.yml)
- [download-artifact v8.0.1 exact metadata](https://raw.githubusercontent.com/actions/download-artifact/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/action.yml)

Exact tag resolutions:

```text
043fb46d1a93c77aae656e7c1c64a875d1fc6a0a refs/tags/v7.0.1
3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c refs/tags/v8.0.1
```

Reviewed facts:

- These remain the latest official releases on 2026-07-29.
- The upload action exposes `archive` and `artifact-digest`.
- The download action exposes `artifact-ids`, `skip-decompress`, and
  `digest-mismatch`, and declares a Node 24 runtime.

## P1-2: Binding the digest to the consumed archive stream

### `Get-FileHash -InputStream`

Source:
[Microsoft Learn: `Get-FileHash`](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/get-filehash)

Reviewed facts:

- `Get-FileHash` has a mandatory `InputStream` parameter set.
- The cmdlet can calculate SHA-256 over a caller-owned stream.
- Local command discovery confirmed `InputStream` exists in both installed
  Windows PowerShell 5.1 and PowerShell 7.6.4.
- After hashing, a seekable stream can be reset to position zero before another
  consumer reads it.

### `ZipArchive(Stream, ZipArchiveMode, Boolean)`

Source:
[Microsoft Learn: `ZipArchive` constructors](https://learn.microsoft.com/dotnet/api/system.io.compression.ziparchive.-ctor)

Reviewed facts:

- `ZipArchive` accepts a caller-supplied stream in `Read` mode.
- The read stream must support reading; using one seekable `FileStream` also
  permits rewinding after hashing.
- The `leaveOpen` argument controls whether disposing the archive also closes
  the underlying stream.
- `InvalidDataException` is raised when the stream cannot be interpreted as a
  ZIP archive.

### File stream ownership

Sources:

- [Microsoft Learn: `FileStream`](https://learn.microsoft.com/dotnet/api/system.io.filestream)
- [Microsoft Learn: `FileShare`](https://learn.microsoft.com/dotnet/api/system.io.fileshare)

Reviewed facts:

- One read-only file handle can remain open across hash comparison, archive
  parsing, manifest validation, and extraction.
- Even where a platform permits a pathname to be renamed or replaced, the held
  handle continues to identify the originally opened bytes.
- Deterministic nested `try`/`finally` disposal is compatible with Windows
  PowerShell 5.1 and PowerShell 7.

Implication: open the retained ZIP once, hash that exact stream, rewind it, and
construct `ZipArchive` over the same held stream. A hash-by-path followed by an
archive open-by-path does not provide the same identity guarantee.

## P1-3: Exhaustive enumeration and dangling final leaves

### PowerShell enumeration defaults

Source:
[Microsoft Learn: `Get-ChildItem`](https://learn.microsoft.com/powershell/module/microsoft.powershell.management/get-childitem)

Reviewed facts:

- `Get-ChildItem` does not display hidden items by default.
- `-Force` includes hidden and system entries that the provider would otherwise
  omit; it does not bypass filesystem permissions.
- `-LiteralPath` prevents wildcard interpretation.
- Provider behavior is broader than filesystem behavior, so callers must first
  prove the FileSystem provider.

### .NET filesystem enumeration

Sources:

- [Microsoft Learn: `Directory.EnumerateFileSystemEntries`](https://learn.microsoft.com/dotnet/api/system.io.directory.enumeratefilesystementries)
- [Microsoft Learn: `DirectoryInfo.GetFileSystemInfos`](https://learn.microsoft.com/dotnet/api/system.io.directoryinfo.getfilesysteminfos)
- [Microsoft Learn: `FileSystemInfo.Attributes`](https://learn.microsoft.com/dotnet/api/system.io.filesysteminfo.attributes)

Reviewed facts:

- `EnumerateFileSystemEntries` returns file and directory names in the specified
  directory without PowerShell's default hidden-item filtering.
- Materializing the enumerable gives one explicit snapshot for count/set
  validation and diagnostics.
- `GetFileSystemInfos` is an eager typed alternative and pre-populates common
  metadata.
- `FileAttributes.ReparsePoint` is available across the required .NET
  generations for indirection detection.

### Existence checks and dangling links

Sources:

- [Microsoft Learn: `File.Exists`](https://learn.microsoft.com/dotnet/api/system.io.file.exists)
- [Microsoft Learn: `Directory.Exists`](https://learn.microsoft.com/dotnet/api/system.io.directory.exists)

Reviewed facts:

- These APIs return `false` rather than throwing for many inaccessible or invalid
  cases.
- An existence result answers whether the target resolves as that object type;
  it is not an exhaustive statement that no directory entry with the leaf name
  exists.
- Enumerating the already validated parent and comparing the final entry name can
  detect files, directories, links, reparse points, and dangling links without
  following the final leaf.

Implication: exact-set checks should use exhaustive .NET enumeration. Candidate
absence should be proved by parent-entry enumeration, repeated immediately
before `Directory.CreateDirectory`, rather than by `File.Exists` or
`Directory.Exists` alone.

## P1-4: Local evidence for the claimed P1/T1 alignment

Authoritative local files:

- `docs/planning/PSStyleGuide/01PSStyleGuideP1.md`
- `docs/planning/TerraformStyleGuide/03TerraformStyleGuideT1.md`

Compared facts:

- P1 names five mandatory scalar parameters:
  `CheckoutRoot`, `TrustedTemporaryRoot`, `DownloadDirectory`,
  `CandidateDirectory`, and `ExpectedDigest`.
- P1 names optional caller-owned `ArtifactId`, `RunId`, and `RunAttempt`
  parameters.
- P1 assigns all fixtures to a tracked
  `Test-Expand-StyleGuideCandidateArtifact.ps1`.
- P1 runs the harness on Ubuntu and the two Windows LF pull-request cells, then
  in every started push consumer.
- The attached T1 describes three logical helper inputs, derives the checkout
  root from helper location, does not define the explicit trusted-root/diagnostic
  interface, and defines fixtures in issue prose rather than a tracked harness.
- The two descriptions therefore do not currently have the same public
  interface, path trust model, harness ownership, or pre-merge topology.

Implication: P1's stronger explicit-root/harness design should remain, but its
present-tense assertion of existing parity is inaccurate until the separate T1
text is coordinated. Because prompt-02 permits edits only to PSStyleGuide issue
files, P1 must describe a target shared contract without editing T1 here.

## P1-5: Canonical writer ref and expected object identity

### GitHub default variables and expression context

Sources:

- [GitHub variables reference](https://docs.github.com/en/actions/reference/variables-reference)
- [GitHub contexts reference](https://docs.github.com/en/actions/learn-github-actions/contexts)

Reviewed facts:

- `GITHUB_REF` is the fully formed ref for the triggering event.
- `GITHUB_SHA` is the commit SHA for the triggering workflow event.
- `${{ github.ref }}` and `${{ github.sha }}` are expression-context values that
  can be copied into explicit step/job environment variables.
- Making two names originate from the same context does not itself require a
  script to prove they remained equal or to reuse one validated value.

### `git ls-remote`

Source:
[Git documentation: `git ls-remote`](https://git-scm.com/docs/git-ls-remote)

Reviewed facts:

- `--refs` suppresses peeled tags and pseudorefs.
- `--exit-code` returns status 2 when no matching ref is found.
- Output records contain an object ID and ref name separated by a tab.

Implication: the writer should validate one full target ref, query that same
value, require exactly one correctly shaped record, and compare its object ID
with one expected commit ID.

### `git push --force-with-lease`

Source:
[Git documentation: `git push`](https://git-scm.com/docs/git-push)

Reviewed facts:

- `--force-with-lease=<ref>:<expect>` protects the named ref by requiring its
  current value to equal the explicit expected object.
- Omitting the expected object or ref delegates more state to local
  remote-tracking information and is not equivalent to the explicit form.
- A refspec `HEAD:<full-ref>` names the destination explicitly.

Implication: one validated local target ref and expected object should be reused
unchanged in the remote preflight, parent/HEAD proofs, explicit lease, and
destination refspec.

## P1-6: Fixture oracle and conditional execution evidence

Authoritative local files:

- `docs/planning/PSStyleGuide/01PSStyleGuideP1.md`
- `docs/planning/PSStyleGuide/02PSStyleGuideP2.md`

Compared facts:

- P1 lists many valid and invalid fixtures but does not give them stable case
  IDs, an ordered failure-phase taxonomy, or per-case postconditions.
- “Throws” alone cannot prove the candidate leaf remained absent or distinguish
  an intended manifest rejection from a later extraction failure.
- The two successful archive modes—ordinary metadata and symlink-like external
  attributes ignored—need separate byte/type assertions.
- P1's workflow graph has four unconditional Windows push consumers and a
  synchronization job guarded by `has_changes=true`.
- The expected no-drift push therefore cannot execute any synchronization step.
- P1 and P2 nevertheless use universal “every consumer on every run” language
  in prerequisite or acceptance text.

Implication: P1 needs a normative stable-ID case table consumed by the tracked
harness. Both issues need one explicit conditional topology whose evidence
combines ordinary push logs, the expected skipped synchronization job, static
inspection, and one controlled `has_changes=true` drill.

## P2-1: Validation helper form

Authoritative local file:
`docs/planning/PSStyleGuide/02PSStyleGuideP2.md`.

Reviewed facts:

- The canonical validation block declares
  `Get-OrdinalOccurrenceCount` without comment-based help.
- Its implementation correctly uses `String.IndexOf` with
  `StringComparison.Ordinal`, advances by the complete needle length, and
  therefore performs non-overlapping ordinal counting.
- P2 also contains a synthetic case designed to show that naïvely counting
  marker-looking text can produce a false positive.
- The primitive is local to one acceptance block and need not be exposed as a
  named PowerShell command.

Implication: preserve the algorithm and self-test in a local script-block
variable. This avoids weakening validation or adding disproportionate help
boilerplate to a transient command.

## Separate maintenance: Markdown dependency advisories

Sources:

- Local `.github/workflows/package.json`
- Local `.github/workflows/package-lock.json`
- [npm: `npm audit`](https://docs.npmjs.com/cli/commands/npm-audit)

Reproduction:

```text
npm --prefix .github/workflows audit --json
```

Result on 2026-07-29:

```text
info=0 low=0 moderate=2 high=5 critical=0 total=7
```

Affected dependency-chain packages reported by npm:

- high: `brace-expansion`, `js-yaml`, `linkify-it`, `minimatch`, and
  `picomatch`;
- moderate: direct `markdown-it` and direct `markdownlint-cli2`.

The advisories concern denial of service, pathological complexity, regular
expression behavior, or incorrect glob matching. npm reports fixes as
available. For the direct chain it proposes `markdownlint-cli2@0.23.2` and
marks that update as semver-major relative to the current pre-1.0 range.

Implication: the advisories matter because pull-request authors control Markdown
processed by CI, but the remediation changes dependencies and the lockfile and
requires regression testing. It should be a separately tracked maintenance
issue, not a silent addition to P1's workflow/helper security change.
