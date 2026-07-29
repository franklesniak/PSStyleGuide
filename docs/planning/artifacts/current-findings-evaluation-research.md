# Research record for PSStyleGuide findings evaluation

## Record metadata

- Retrieved: 2026-07-29
- Repository: `franklesniak/PSStyleGuide`
- Local branch: `planning-CRT-PR-852`
- Local commit: `0aa910138055fde7ef8fa0fb54af4ed0b0559dd3`
- Exact reviewed `origin/main`:
  `4346310e7deebffb4159c75e30d9546263dfd649`
- Purpose: retain the primary-source and current-state facts used to evaluate
  the open PSStyleGuide P1/P2 findings.

## .NET file sharing

### `System.IO.FileShare`

Source:
[Microsoft Learn — FileShare enum](https://learn.microsoft.com/dotnet/api/system.io.fileshare?view=net-10.0)

Relevant retained facts:

- `FileShare` controls what subsequent operations may do with the same file.
- `None` declines all sharing; later open requests fail until the stream closes.
- `Read` permits later readers. Without `Write`, later writers are not
  permitted. Without `Delete`, later delete sharing is not permitted.
- Microsoft's example for a read-only stream that permits other readers is:
  `FileMode.Open`, `FileAccess.Read`, `FileShare.Read`.
- Microsoft describes concurrent reading as a typical `FileShare` use case.

Implication:

P1 must choose an exact enum. `Read` is a documented normal read-only choice;
`None` is stricter but prevents benign secondary readers. Neither changes the
need to hash, rewind, and parse the same held stream.

### `FileStream` constructors

Source:
[Microsoft Learn — FileStream constructors](https://learn.microsoft.com/dotnet/api/system.io.filestream.-ctor?view=net-10.0)

Relevant retained facts:

- Constructors accepting `FileAccess` and `FileShare` make both choices
  explicit.
- Constructors that omit `FileShare` default to `FileShare.Read`.
- File-backed streams are seekable when the underlying device supports seeking.

Implication:

P1 should not rely on the constructor default because its security contract
requires an auditable sharing decision. It can explicitly select
`FileShare.Read`, hash with `Get-FileHash -InputStream`, set `Position = 0`, and
construct `ZipArchive` over that same stream.

## .NET path and link behavior

### Full and root paths

Sources:

- [Microsoft Learn — Path.GetFullPath](https://learn.microsoft.com/dotnet/api/system.io.path.getfullpath?view=net-10.0)
- [Microsoft Learn — Path.GetPathRoot](https://learn.microsoft.com/dotnet/api/system.io.path.getpathroot?view=net-10.0)
- [Microsoft Learn — Windows path formats](https://learn.microsoft.com/dotnet/standard/io/file-path-formats)

Relevant retained facts:

- `GetFullPath` returns a fully qualified path but does not require the target to
  exist. It is lexical normalization, not proof that the path has no links.
- The one-argument overload depends on current directory/current volume for a
  relative path; callers must first require rooted inputs or use a stable base.
- `GetPathRoot` distinguishes Unix `/`, Windows drive roots, and UNC
  `\\server\share` roots and does not verify existence.
- A UNC server/share pair forms the volume boundary; traversal cannot go above
  that volume.

Implication:

P1 needs both lexical containment checks and filesystem-attribute checks.
Component enumeration must start at the root returned for the normalized path,
including the full UNC share boundary where applicable.

### Reparse points and links

Sources:

- [Microsoft Learn — FileAttributes enum](https://learn.microsoft.com/dotnet/api/system.io.fileattributes?view=net-10.0)
- [Microsoft Learn — FileSystemInfo.LinkTarget](https://learn.microsoft.com/dotnet/api/system.io.filesysteminfo.linktarget?view=net-10.0)
- [Microsoft Learn — ResolveLinkTarget](https://learn.microsoft.com/dotnet/api/system.io.filesysteminfo.resolvelinktarget?view=net-10.0)
- [Microsoft Learn — ReparsePointAware](https://learn.microsoft.com/dotnet/api/microsoft.visualstudio.utilities.internal.reparsepointaware?view=visualstudiosdk-2022)

Relevant retained facts:

- `FileAttributes.ReparsePoint` is supported on Windows, Linux, and macOS and
  applies to files and directories.
- Modern .NET link-target APIs recognize symbolic links and Windows junctions,
  but they are not available under all runtimes P1 supports.
- Microsoft's `ReparsePointAware` documentation identifies reparse-point
  injection and path-check/use races as security risks. It explains that a
  handle-based operation is required for a true same-object guarantee.

Implication:

P1 should use the cross-runtime attributes available to both Windows PowerShell
5.1 and PowerShell 7, enumerate every existing component, and repeat checks at
security boundaries. It must also state honestly that repeated path checks
narrow but do not eliminate time-of-check/time-of-use risk. The supported
GitHub-hosted-runner model therefore requires runner-controlled ancestors,
job-owned roots, and no competing writer during the helper call.

### Temporary names and directory creation

Sources:

- [Microsoft Learn — Path.GetRandomFileName](https://learn.microsoft.com/dotnet/api/system.io.path.getrandomfilename?view=net-10.0)
- [Microsoft Learn — Directory.CreateDirectory](https://learn.microsoft.com/dotnet/api/system.io.directory.createdirectory?view=net-10.0)

Relevant retained facts:

- `GetRandomFileName` returns a random file or directory name and does not
  create it.
- `CreateDirectory` creates missing path components, but if the directory
  already exists it returns that existing directory rather than proving a
  create-new operation.

Implication:

The workflow must not treat a fixed `RUNNER_TEMP` child as unique. It should use
a high-entropy generated child name, prove the selected path did not already
exist, create it under the runner-controlled temporary parent, verify the
ordinary-directory result, and operate under the stated no-competing-writer
model. A bounded retry is appropriate for a name collision; silently reusing an
existing directory is not.

## GitHub artifact actions

### Pinned upload action

Source:
[actions/upload-artifact action.yml at `043fb46`](https://raw.githubusercontent.com/actions/upload-artifact/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a/action.yml)

Exact reviewed identity:

- Commit: `043fb46d1a93c77aae656e7c1c64a875d1fc6a0a`
- P1 annotation: v7.0.1
- Runtime: `node24`

Retained contract:

- `archive: true` means the action ZIP-archives the upload.
- `archive: false` uploads one file as-is.
- With `archive: false`, only one file is allowed and its filename becomes the
  artifact name; the separate `name` input is ignored.
- Outputs are `artifact-id`, `artifact-url`, and `artifact-digest`.
- `artifact-digest` is the uploaded artifact's SHA-256 digest.

Implication:

A malformed-transport drill can upload a prebuilt invalid ZIP as the sole file
with `archive: false`, propagate that upload's immutable ID and digest, and
exercise the production download/helper boundary without trying to corrupt
GitHub's storage service.

### Pinned download action

Source:
[actions/download-artifact action.yml at `3e5f45b`](https://raw.githubusercontent.com/actions/download-artifact/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/action.yml)

Exact reviewed identity:

- Commit: `3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c`
- P1 annotation: v8.0.1
- Runtime: `node24`

Retained contract:

- `artifact-ids` selects comma-separated immutable artifact IDs and is mutually
  exclusive with selection by name.
- `skip-decompress: true` retains the artifact without automatic extraction.
- `digest-mismatch` accepts `ignore`, `info`, `warn`, or `error`.
- Its default is `error`, which fails the action.

Implication:

P1's production flow should continue setting both `skip-decompress: true` and
`digest-mismatch: error` explicitly, select by one propagated immutable ID, and
independently compare the retained ZIP with the propagated upload digest in the
shared helper.

### Pinned checkout and setup actions

Sources:

- [actions/checkout action.yml at `3d3c42e`](https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml)
- [actions/setup-node action.yml at `8207627`](https://raw.githubusercontent.com/actions/setup-node/820762786026740c76f36085b0efc47a31fe5020/action.yml)

Exact reviewed identity:

- checkout v7.0.1:
  `3d3c42e5aac5ba805825da76410c181273ba90b1`, `node24`
- setup-node v7.0.0:
  `820762786026740c76f36085b0efc47a31fe5020`, `node24`
- setup-node exposes `package-manager-cache`; its default is `true`.

Implication:

P1's pins and Node 24 metadata are current at review time. Explicit
`package-manager-cache: false` remains necessary to preserve the intended
read-only/no-cache semantics.

## GitHub Actions security and update governance

### Immutable action references and least privilege

Sources:

- [GitHub secure use reference](https://docs.github.com/en/actions/reference/security/secure-use)
- [GitHub workflow syntax — permissions](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax)

Relevant retained facts:

- GitHub describes a full-length commit SHA as the only immutable action
  release reference.
- GitHub recommends verifying the SHA belongs to the action's repository.
- GitHub recommends explicitly declaring the minimum `GITHUB_TOKEN`
  permissions.
- Setting a job-level `permissions` map can narrow one job; unspecified
  permissions become `none`.

Implication:

Dependabot proposals must update the full SHA and same-line version annotation
for human review; execution-time pins must remain immutable. Only the
synchronization job should receive `contents: write`.

### Dependabot for GitHub Actions

Sources:

- [Keeping actions current with Dependabot](https://docs.github.com/en/code-security/how-tos/secure-your-supply-chain/secure-your-dependencies/auto-update-actions)
- [Supported ecosystems and repositories](https://docs.github.com/en/code-security/reference/supply-chain-security/supported-ecosystems-and-repositories)

Relevant retained facts:

- The configuration file is `.github/dependabot.yml`, `version: 2`.
- The ecosystem is `github-actions`.
- The directory must be `/` for workflows under `.github/workflows`.
- A weekly schedule is supported and creates reviewable update pull requests.
- Dependabot can update version comments when the version annotation is on the
  same line as a full-SHA action reference.

Implication:

The minimal review-only configuration is one weekly `github-actions` entry for
`/`; no auto-merge configuration is needed or desired. The issue should require
human review of release notes, the resolved SHA, runtime, inputs/outputs, and
workflow evidence.

## Node and npm state

### Node release status

Source:
[Node.js release schedule](https://nodejs.org/en/about/previous-releases)

Retained state on 2026-07-29:

- Node 24 (“Krypton”) is LTS.
- Node 20 (“Iron”) reached end of life on 2026-03-24.
- The Node project recommends production use of supported LTS lines.

Implication:

P1 should validate the selected Node 24 runtime explicitly rather than accept a
pass under an arbitrary newer local Node installation.

### npm audit behavior

Source:
[npm audit documentation](https://docs.npmjs.com/cli/v9/commands/npm-audit/)

Retained facts:

- `npm audit` uses the dependency tree represented by the lock/shrinkwrap.
- It returns zero when no vulnerabilities are found and nonzero by default when
  vulnerabilities are found.
- `--audit-level` changes the failure threshold, not which findings appear in
  the report.
- Some findings require manual review or a semver-major update.

### Current package-lock audit

Command:

```powershell
npm --prefix .github/workflows audit --package-lock-only --json
```

Environment and result on 2026-07-29:

- Node: 26.5.0
- npm: 11.7.0
- Exit code: 1
- Total: 7
- Critical: 0
- High: 5
- Moderate: 2
- Low: 0
- Reported packages: `brace-expansion`, `js-yaml`, `linkify-it`,
  `markdown-it`, `markdownlint-cli2`, `minimatch`, and `picomatch`
- Direct reported packages: `markdown-it` and `markdownlint-cli2`
- npm's reported remediation for the direct toolchain leads to
  `markdownlint-cli2@0.23.2` and is classified as semver-major because the
  current package is pre-1.0.

Repository issue search across both open and closed issues:

- `npm audit`: no result
- `advisory`: no result
- `vulnerability`: no result
- `markdownlint-cli2 security`: issue #137 only
- Issue #137 is about deterministic Markdown lint/Husky behavior and line
  endings; its description does not own npm advisory remediation.

Implication:

The advisory work needs a separately named and ordered issue. It must not be
presented as already tracked by #137, and it should not be silently bundled into
P1's generator/workflow change.
