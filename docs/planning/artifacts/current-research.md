# PSStyleGuide findings research notes

Research date: 2026-07-28.

These notes preserve the primary-source facts used while evaluating the open
PSStyleGuide findings. They are paraphrases with exact URLs and reviewed
versions/commits so later issue editing does not depend on repeating searches.

## Filesystem-path contract

### PowerShell `PathIntrinsics`

Source:
[Microsoft Learn: `PathIntrinsics`](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.pathintrinsics?view=powershellsdk-7.4.0)

Relevant facts:

- `GetResolvedProviderPathFromPSPath` resolves an existing PowerShell path to one or
  more provider-internal paths.
- `GetUnresolvedProviderPathFromPSPath` converts a PowerShell path to a
  provider-internal path without requiring wildcard resolution, which is needed for
  an intentionally nonexistent destination.
- The overload returning provider information allows the caller to prove the
  filesystem provider rather than accidentally passing another PowerShell provider.

### .NET full paths

Source:
[Microsoft Learn: `Path.GetFullPath`](https://learn.microsoft.com/en-us/dotnet/api/system.io.path.getfullpath?view=net-6.0)

Relevant facts:

- `GetFullPath` returns an absolute path, and the target need not exist.
- Resolving a relative path against ambient current-directory state is not
  deterministic because that state can change.
- The two-argument deterministic overload is not available in the full
  PowerShell-5.1/.NET-Framework compatibility surface, so the issue should require
  already-resolved filesystem-provider paths rather than rely on an ambient base.

### Platform path comparison

Source:
[Microsoft Learn: `Path.GetRelativePath`](https://learn.microsoft.com/en-us/dotnet/api/system.io.path.getrelativepath?view=netstandard-2.1)

Relevant fact:

- Microsoft's platform implementation uses ordinal case-insensitive path comparison
  on Windows and ordinal case-sensitive comparison on Linux. P1 cannot call this API
  under every PowerShell 5.1 target, but the documented comparison behavior supports
  specifying the same platform semantics explicitly.

### Directory and entry metadata

Sources:

- [Microsoft Learn: `DirectoryInfo`](https://learn.microsoft.com/en-us/dotnet/api/system.io.directoryinfo?view=netframework-4.8)
- [Microsoft Learn: `DirectoryInfo.GetFileSystemInfos`](https://learn.microsoft.com/en-us/dotnet/api/system.io.directoryinfo.getfilesysteminfos?view=net-10.0)

Relevant facts:

- `DirectoryInfo.FullName` supplies the full directory path.
- `GetFileSystemInfos` returns typed filesystem entries and pre-populates attributes.
- `FileSystemInfo.Attributes` is the compatible mechanism for distinguishing
  directories and checking reparse-point metadata across the required .NET
  generations.

## GitHub Actions runtime and immutable pinning

### Node 20 retirement

Source:
[GitHub Changelog: Deprecation of Node 20 on GitHub Actions runners](https://github.blog/changelog/2025-09-19-deprecation-of-node-20-on-github-actions-runners/)

Reviewed page state:

- The page was updated on 2026-05-19.
- Node 20 reached end of life in April 2026.
- GitHub began making Node 24 the default JavaScript-action runtime on
  2026-06-16.
- A temporary opt-out can request the insecure Node version, but GitHub says Node 20
  will be removed from runners in fall 2026.
- GitHub's instruction to action users is to update workflows to current action
  versions that run on Node 24.

### Checkout action metadata

Primary files:

- [checkout v4.3.1 metadata at `34e114876b0b11c390a56381ad16ebd13914f8d5`](https://raw.githubusercontent.com/actions/checkout/34e114876b0b11c390a56381ad16ebd13914f8d5/action.yml)
- [checkout v6.0.2 metadata at `de0fac2e4500dabe0009e67214ff5f5447ce83dd`](https://raw.githubusercontent.com/actions/checkout/de0fac2e4500dabe0009e67214ff5f5447ce83dd/action.yml)
- [checkout v6.0.2 release](https://github.com/actions/checkout/releases/tag/v6.0.2)

Reviewed facts:

- Exact tag resolution was independently checked with `git ls-remote` against the
  official `actions/checkout` repository.
- v4.3.1's `action.yml` declares `runs.using: node20`.
- v6.0.2's `action.yml` declares `runs.using: node24`.
- As of 2026-07-28, both PSStyleGuide workflows use the moving
  `actions/checkout@v4` reference.
- [The exact v6.0.2 README](https://raw.githubusercontent.com/actions/checkout/de0fac2e4500dabe0009e67214ff5f5447ce83dd/README.md)
  says persisted credentials move from `.git/config` to a file under `RUNNER_TEMP`;
  ordinary authenticated `git fetch` and `git push` continue without workflow
  changes. Its runner-version caveat applies to authenticated commands from Docker
  container actions; neither PSStyleGuide workflow uses such a container action.

### GitHub secure-use guidance

Source:
[GitHub Actions secure-use reference](https://docs.github.com/en/actions/reference/security/secure-use)

Relevant facts:

- GitHub says a full-length commit SHA is the only immutable way to reference an
  action release.
- GitHub recommends verifying that the SHA belongs to the official action repository.
- A tag, including a patch or major tag, can move or be deleted.
- A same-line version comment is useful because Dependabot can update both a
  full-SHA action reference and its version annotation.
- Dependabot version updates can maintain GitHub Action SHA pins, but adopting
  Dependabot is a separate repository policy choice.

## Markdown list continuation

Sources:

- [CommonMark 0.31.2 list-item rules](https://spec.commonmark.org/0.31.2/#list-items)
- [markdownlint MD029 documentation](https://github.com/DavidAnson/markdownlint/blob/main/doc/md029.md)

Relevant facts:

- CommonMark defines subsequent blocks as part of an ordered-list item when they are
  indented by the marker width plus its following indentation. For a marker such as
  `4.`, that continuation indentation is three spaces.
- markdownlint's MD029 documentation specifically identifies an unindented fenced
  block between ordered items as splitting one intended list into two.
- The documented repair is to indent the fence as continuation content of the
  preceding item; the subsequent numeric marker then remains part of the original
  ordered sequence.
