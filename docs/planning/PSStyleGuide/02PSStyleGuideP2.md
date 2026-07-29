# Make the non-compliant blank-line example visibly distinct

> **Dependency:** Implement this issue only after **Make artifact generation byte-deterministic across PowerShell editions and hosts** has merged. When both issues have been filed, record the GitHub blocked-by relationship using the actual prerequisite issue.

## Summary

In `STYLE_GUIDE.md`, the `### Blank Line Usage` section presents Compliant and Non-Compliant examples intended to contrast a truly empty blank line with a blank line containing spaces. Both stored examples currently have an empty third line, making them byte-identical and contradicting the explanatory sentence that follows.

Replace the invisible defect with a durable visible visualization. Keep concise, operational interpretation in `STYLE_GUIDE.md`, and place the explanation of why visible substitutes are needed in `STYLE_GUIDE_RATIONALE.md`.

The guidance must remain self-contained and applicable to every adopter of the PowerShell style guide, not only the downstream repository where the defect was discovered.

This originated from the cross-repository work tracked in [franklesniak/copilot-repo-template#851](https://github.com/franklesniak/copilot-repo-template/issues/851) and [franklesniak/copilot-repo-template#852](https://github.com/franklesniak/copilot-repo-template/pull/852).

## Prerequisite

Complete and merge
[P1: Make artifact generation byte-deterministic across PowerShell editions and hosts](01PSStyleGuideP1.md)
before starting. Base P2 on that merged result.

At implementation start, confirm these P1 interfaces and invariants:

- All four generator payloads canonicalize CRLF/lone CR to LF and serialize
  through resolved paths with BOM-less `UTF8Encoding($false)`;
  `#Requires -Version 5.1` and `* text=auto eol=lf` remain.
- The versioned
  `.github/workflows/Expand-StyleGuideCandidateArtifact.ps1` and
  `.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1` are the only
  candidate extraction implementation and permanent fixture owner.
- Both events cover every `main` pull request/push without path filters, use
  least-privilege job permissions, and pin checkout, setup-node, upload, and
  download actions to the approved repository/full-SHA/version tuples with
  matching workflow roles through the exact allowlist validator.
- Markdown validation asserts Node major 24, disables automatic
  package-manager caching, and passes the existing clean install, outer lint,
  and nested lint commands.
- Push preparation uploads one immutable `archive: true` candidate and
  propagates one nonempty artifact ID and 64-hex digest.
- Every started push consumer selects that exact ID, uses
  `skip-decompress: true` and `digest-mismatch: error`, creates one unique
  job-owned trusted temporary root, and passes separate download/candidate
  paths to the helper.
- The helper validates mutually separate roots and every existing component
  from the filesystem volume/share root, repeats the checks at security
  boundaries, states the job-owned/no-competing-writer model, opens the archive
  once with `FileShare.Read`, hashes/rewinds/parses that same stream, validates
  the complete manifest before creation, preserves pre-existing state, and
  performs fail-closed cleanup of invocation-created output through the exact
  ownership journal and named production cleanup function.
- Optional artifact/run labels distinguish omitted, supplied, and explicitly
  empty values, and the permanent stable-ID table proves their exact
  diagnostics.
- The permanent harness definition-only invokes the exact named production
  cleanup function for its mandatory unsafe ordinary-child fixture, and at
  least one real component-or-leaf link rejection executes on both Ubuntu and
  Windows.
- Pull-request evidence runs the harness under Ubuntu PowerShell 7 and only the
  two Windows LF cells because helper behavior is source-EOL-independent;
  neither CRLF cell repeats it. Every four-cell push consumer runs the harness
  and production helper.
- Local validation asserts Desktop exactly 5.1 or Core major 7 in the same
  child process that invokes each harness/generator target.
- P1's controlled `has_changes=true` synchronization drill—not P2's expected
  no-drift merge—proves writer integration, and its propagated-digest,
  malformed-transport, unrelated-trigger, stale-preflight, and exact-lease
  drills pass without touching `main`.
- `.github/dependabot.yml` contains the review-only weekly GitHub Actions entry
  and remains outside P2's affected files.

P1 is the source of truth for those implementation details; P2 does not reopen
or restate their algorithms.

[P3: Remediate Markdown lint dependency advisories and add npm update governance](03PSStyleGuideP3.md)
follows P2. It is not a P2 prerequisite, and its package changes must not be
silently folded into this issue.

## Affected files

Authoritative sources:

- `STYLE_GUIDE.md`
- `STYLE_GUIDE_RATIONALE.md`

Generated artifacts:

- `copilot-instructions.md`
- `powershell.instructions.md`
- `STYLE_GUIDE_CHAT.md`
- `STYLE_GUIDE_FULL.md`

The generated artifacts must change only through regeneration.

## Requested changes

### 1. Repair the visualization in `STYLE_GUIDE.md`

Keep the Compliant heading and fenced block unchanged and copy-ready.

Use exactly:

**Non-Compliant (blank line contains spaces; visualization only):**

Each `·` on line 3 below is an explanatory substitute for one literal U+0020 SPACE on the otherwise blank line. The dots **MUST NOT** be copied into PowerShell code.

```text
{
    Invoke-SomeCmdlet
····
    Invoke-AnotherCmdlet
}
```

The four represented spaces are not allowed. A compliant blank line contains no characters.

Requirements:

- Use a `text` fence.
- Put exactly four U+00B7 MIDDLE DOT characters and nothing else on line 3.
- Warn before the block that the dots are substitutes and must not be copied.
- Keep a heading that names the violation and identifies the block as a visualization.
- Preserve the existing rule and requirement levels.
- Do not store literal trailing whitespace.
- Do not add downstream-specific guidance.
- Preserve this complete canonical snippet exactly once in `STYLE_GUIDE.md` and, after regeneration, exactly once in each generated artifact.

### 2. Extend `STYLE_GUIDE_RATIONALE.md`

Extend the existing `### Blank Line Usage` section under `## Content Relocated from STYLE_GUIDE.md`; do not create a second Blank Line Usage section.

Explain generically that:

- Literal spaces on an otherwise blank line are invisible.
- Editors, formatters, and whitespace-cleanup tools can remove them.
- The Non-Compliant example can therefore drift into byte identity with the Compliant example.
- Visible substitutes preserve the intended defect while keeping the stored Markdown free of trailing whitespace.
- Middle dots are documentation annotations, not PowerShell syntax.

Keep operational guidance concise in `STYLE_GUIDE.md` and extended reasoning in `STYLE_GUIDE_RATIONALE.md`.

Do not duplicate the operational Non-Compliant heading or canonical fenced example in the rationale.

### 3. Advance metadata

At finalization, reread Version and Last Updated from the target branch.

1. Increment the Minor component because the change adds a durable documentation convention and repairs the example's semantics.
2. Use the current UTC date for Build and Last Updated.
3. Set Revision to `0` when `Major.Minor.Build` changes.
4. If that `Major.Minor.Build` already exists at Revision `N`, use `N + 1`.
5. Recompute if the target branch or UTC date changes.
6. Commit metadata with the source change.

### 4. Regenerate artifacts

Run:

```powershell
$ErrorActionPreference = 'Stop'

& pwsh `
    -NoLogo `
    -NoProfile `
    -File './.github/workflows/Generate-StyleGuideArtifacts.ps1'

$intGeneratorExitCode = $LASTEXITCODE

if ($intGeneratorExitCode -ne 0) {
    throw (
        "Generator failed with exit code {0}." -f
        $intGeneratorExitCode
    )
}
```

Commit both sources and all four regenerated artifacts together. Do not defer ordinary synchronization to the post-merge recovery path.

## Why

An invisible Non-Compliant defect cannot teach the intended distinction and can be silently erased by normal whitespace handling. A labeled `text` visualization makes the prohibited content observable without storing prohibited trailing spaces.

Keeping the explanation generic preserves the style guide's usefulness across unrelated repositories and adoption contexts.

## Validation

Run the following blocks in order from the repository root. Every block must begin with `$ErrorActionPreference = 'Stop'`, define every value it consumes, and check native-command exit codes immediately.

### Generate, lint, and check whitespace

```powershell
$ErrorActionPreference = 'Stop'

$objNodeCommand = Get-Command `
    -Name 'node' `
    -CommandType Application `
    -ErrorAction Stop |
    Select-Object -First 1

$objNpmCommand = Get-Command `
    -Name 'npm' `
    -CommandType Application `
    -ErrorAction Stop |
    Select-Object -First 1

$arrNodeVersionOutput = @(
    & $objNodeCommand.Path -p 'process.versions.node'
)
$intNodeExitCode = $LASTEXITCODE

if (
    $intNodeExitCode -ne 0 -or
    $arrNodeVersionOutput.Count -ne 1 -or
    ([string]$arrNodeVersionOutput[0]).Trim() -notmatch '^24\.'
) {
    throw (
        "P2 local validation requires Node.js major 24; output/exit: {0}/{1}." -f
        ($arrNodeVersionOutput -join '; '),
        $intNodeExitCode
    )
}

$blnCiWasDefined = Test-Path -LiteralPath 'Env:CI'
$strPreviousCi = [string]$env:CI

try {
    $env:CI = 'true'

    & $objNpmCommand.Path --prefix .github/workflows ci
    $intNpmExitCode = $LASTEXITCODE

    if ($intNpmExitCode -ne 0) {
        throw ("npm ci failed with exit code {0}." -f $intNpmExitCode)
    }
}
finally {
    if ($blnCiWasDefined) {
        $env:CI = $strPreviousCi
    }
    else {
        Remove-Item -LiteralPath 'Env:CI' -ErrorAction SilentlyContinue
    }
}

& pwsh `
    -NoLogo `
    -NoProfile `
    -File './.github/workflows/Generate-StyleGuideArtifacts.ps1'

$intGeneratorExitCode = $LASTEXITCODE

if ($intGeneratorExitCode -ne 0) {
    throw ("Generator failed with exit code {0}." -f $intGeneratorExitCode)
}

& $objNpmCommand.Path --prefix .github/workflows run lint:md
$intNpmExitCode = $LASTEXITCODE

if ($intNpmExitCode -ne 0) {
    throw ("Markdown lint failed with exit code {0}." -f $intNpmExitCode)
}

& $objNpmCommand.Path --prefix .github/workflows run lint:md:nested
$intNpmExitCode = $LASTEXITCODE

if ($intNpmExitCode -ne 0) {
    throw ("Nested Markdown lint failed with exit code {0}." -f $intNpmExitCode)
}

git diff --check
$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw ("git diff --check failed with exit code {0}." -f $intGitExitCode)
}
```

### Verify working-tree scope and stage exactly six files

```powershell
$ErrorActionPreference = 'Stop'

$arrExpectedStagedPaths = @(
    'STYLE_GUIDE.md'
    'STYLE_GUIDE_RATIONALE.md'
    'copilot-instructions.md'
    'powershell.instructions.md'
    'STYLE_GUIDE_CHAT.md'
    'STYLE_GUIDE_FULL.md'
) | Sort-Object

$arrStatusLines = @(
    git status `
        --porcelain=v1 `
        --untracked-files=all `
        --ignore-submodules=none `
        -- .
)
$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw (
        "Unable to read working-tree status; git exited with {0}." -f
        $intGitExitCode
    )
}

$arrChangedPaths = @(
    $arrStatusLines |
        ForEach-Object {
            if ($_ -notmatch '^..\s+') {
                throw ("Unexpected porcelain status record: {0}" -f $_)
            }

            $_ -replace '^..\s+', ''
        } |
        Sort-Object -Unique
)

$arrWorkingTreeDifferences = @(
    Compare-Object `
        -ReferenceObject $arrExpectedStagedPaths `
        -DifferenceObject $arrChangedPaths `
        -CaseSensitive
)

if ($arrWorkingTreeDifferences.Count -ne 0) {
    throw (
        "The working-tree path set is not exactly the two sources and four " +
        "generated artifacts. Status: {0}" -f
        ($arrStatusLines -join '; ')
    )
}

git add -- $arrExpectedStagedPaths
$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw ("git add failed with exit code {0}." -f $intGitExitCode)
}
```

### Rerun and verify the staged result

```powershell
$ErrorActionPreference = 'Stop'

$arrGuideBearingPaths = @(
    'STYLE_GUIDE.md'
    'copilot-instructions.md'
    'powershell.instructions.md'
    'STYLE_GUIDE_CHAT.md'
    'STYLE_GUIDE_FULL.md'
)

$strRationalePath = 'STYLE_GUIDE_RATIONALE.md'

$arrTouchedPaths = @(
    $arrGuideBearingPaths
    $strRationalePath
)

$arrExpectedStagedPaths = @($arrTouchedPaths | Sort-Object)

$strMiddleDot = [string][char]0x00B7

$arrCanonicalSnippetLines = @(
    '**Non-Compliant (blank line contains spaces; visualization only):**'
    ''
    'Each `·` on line 3 below is an explanatory substitute for one literal U+0020 SPACE on the otherwise blank line. The dots **MUST NOT** be copied into PowerShell code.'
    ''
    '```text'
    '{'
    '    Invoke-SomeCmdlet'
    ($strMiddleDot * 4)
    '    Invoke-AnotherCmdlet'
    '}'
    '```'
    ''
    'The four represented spaces are not allowed. A compliant blank line contains no characters.'
)

$strCanonicalSnippet = $arrCanonicalSnippetLines -join "`n"
$strNonCompliantMarker = $arrCanonicalSnippetLines[0]

$scriptGetOrdinalOccurrenceCount = {
    param (
        [Parameter(Mandatory)]
        [string]$Content,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Needle
    )

    if ($Needle.Length -eq 0) {
        throw 'Cannot count occurrences of an empty string.'
    }

    $intCount = 0
    $intOffset = 0

    while ($intOffset -le ($Content.Length - $Needle.Length)) {
        $intIndex = $Content.IndexOf(
            $Needle,
            $intOffset,
            [StringComparison]::Ordinal
        )

        if ($intIndex -lt 0) {
            break
        }

        $intCount++
        $intOffset = $intIndex + $Needle.Length
    }

    return $intCount
}

$strLegacyVisualizationLine = "`n" + ($strMiddleDot * 4) + "`n"

$strSyntheticFalsePositive = @(
    $strNonCompliantMarker
    ''
    '```text'
    'WRONG'
    '```'
    ''
    'Unrelated example:'
    ($strMiddleDot * 4)
    'End'
) -join "`n"

if (
    -not $strSyntheticFalsePositive.Contains($strLegacyVisualizationLine) -or
    (& $scriptGetOrdinalOccurrenceCount `
        -Content $strSyntheticFalsePositive `
        -Needle $strCanonicalSnippet) -ne 0
) {
    throw 'Canonical-snippet validator self-test failed.'
}

& pwsh `
    -NoLogo `
    -NoProfile `
    -File './.github/workflows/Generate-StyleGuideArtifacts.ps1'

$intGeneratorExitCode = $LASTEXITCODE

if ($intGeneratorExitCode -ne 0) {
    throw (
        "Final generator run failed with exit code {0}." -f
        $intGeneratorExitCode
    )
}

foreach ($strTouchedPath in $arrTouchedPaths) {
    $strAbsolutePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
        $strTouchedPath
    )

    $arrBytes = [System.IO.File]::ReadAllBytes($strAbsolutePath)

    if (
        $arrBytes.Length -ge 3 -and
        $arrBytes[0] -eq 0xEF -and
        $arrBytes[1] -eq 0xBB -and
        $arrBytes[2] -eq 0xBF
    ) {
        throw ("File begins with a UTF-8 BOM: {0}" -f $strTouchedPath)
    }

    if ([Array]::IndexOf($arrBytes, [byte]0x0D) -ge 0) {
        throw ("File contains a carriage-return byte: {0}" -f $strTouchedPath)
    }

    $strContent = [System.IO.File]::ReadAllText($strAbsolutePath)

    if ([regex]::IsMatch($strContent, '(?m)[\x20\x09]+$')) {
        throw ("File contains trailing whitespace: {0}" -f $strTouchedPath)
    }
}

foreach ($strGuideBearingPath in $arrGuideBearingPaths) {
    $strAbsolutePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
        $strGuideBearingPath
    )

    $strContent = [System.IO.File]::ReadAllText($strAbsolutePath)

    $intSnippetCount = & $scriptGetOrdinalOccurrenceCount `
        -Content $strContent `
        -Needle $strCanonicalSnippet

    $intMarkerCount = & $scriptGetOrdinalOccurrenceCount `
        -Content $strContent `
        -Needle $strNonCompliantMarker

    if ($intSnippetCount -ne 1 -or $intMarkerCount -ne 1) {
        throw (
            ("Canonical Non-Compliant example count mismatch in {0}; " +
            "expected snippet/marker counts 1/1, actual {1}/{2}.") -f
            $strGuideBearingPath,
            $intSnippetCount,
            $intMarkerCount
        )
    }
}

$strRationaleAbsolutePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
    $strRationalePath
)

$strRationaleContent = [System.IO.File]::ReadAllText($strRationaleAbsolutePath)

$arrRationaleLines = @(
    ($strRationaleContent -replace "`r`n?", "`n").Split(
        [string[]]@("`n"),
        [StringSplitOptions]::None
    )
)

$intBlankLineUsageHeadingCount = @(
    $arrRationaleLines |
        Where-Object {
            [string]::Equals(
                $_,
                '### Blank Line Usage',
                [StringComparison]::Ordinal
            )
        }
).Count

if ($intBlankLineUsageHeadingCount -ne 1) {
    throw (
        ("STYLE_GUIDE_RATIONALE.md must contain exactly one ordinal " +
        "'### Blank Line Usage' heading; expected 1, actual {0}.") -f
        $intBlankLineUsageHeadingCount
    )
}

$intRationaleSnippetCount = & $scriptGetOrdinalOccurrenceCount `
    -Content $strRationaleContent `
    -Needle $strCanonicalSnippet

$intRationaleMarkerCount = & $scriptGetOrdinalOccurrenceCount `
    -Content $strRationaleContent `
    -Needle $strNonCompliantMarker

if ($intRationaleSnippetCount -ne 0 -or $intRationaleMarkerCount -ne 0) {
    throw (
        ("The rationale must explain the convention without duplicating the " +
        "operational example; snippet/marker counts were {0}/{1}.") -f
        $intRationaleSnippetCount,
        $intRationaleMarkerCount
    )
}

git diff --exit-code -- $arrTouchedPaths
$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw (
        "The final generator run changed the staged expected result; " +
        "git exited with {0}." -f
        $intGitExitCode
    )
}

git diff --cached --check
$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw (
        "git diff --cached --check failed with exit code {0}." -f
        $intGitExitCode
    )
}

$arrStagedPaths = @(git diff --cached --name-only)
$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw (
        "Unable to list staged paths; git exited with {0}." -f
        $intGitExitCode
    )
}

$arrStagedPaths = @($arrStagedPaths | Sort-Object)

$arrPathDifferences = @(
    Compare-Object `
        -ReferenceObject $arrExpectedStagedPaths `
        -DifferenceObject $arrStagedPaths `
        -CaseSensitive
)

if ($arrPathDifferences.Count -ne 0) {
    throw (
        "Unexpected staged path set: {0}" -f
        ($arrStagedPaths -join ', ')
    )
}

$arrStagedPaths
```

### Content confirmation

Confirm:

- The Compliant example is unchanged.
- The Non-Compliant visualization visibly differs.
- Line 3 contains exactly four U+00B7 characters and nothing else.
- The warning precedes the visualization.
- The dots are explicitly identified as documentation substitutes that must not be copied.
- No touched line has literal trailing whitespace.
- No touched file contains a carriage-return byte.
- The complete canonical snippet and its exact heading marker each occur exactly once in `STYLE_GUIDE.md` and each of the four generated artifacts.
- `STYLE_GUIDE_RATIONALE.md` contains neither the canonical snippet nor its exact operational heading.
- An ordinal exact-line count proves `STYLE_GUIDE_RATIONALE.md` contains
  exactly one `### Blank Line Usage` heading.
- That existing rationale section explains the durability and portability
  reasons without creating a duplicate section.
- No downstream-specific assumption appears.
- Version and Last Updated agree with the finalized target baseline and UTC implementation date.
- All four generated artifacts match the authoritative sources.
- No touched file begins with `EF BB BF`.
- The working-tree and staged-path sets are each exactly the two sources and four generated artifacts.

### Pull-request evidence

While the pull request is open, confirm:

1. Verification runs because every pull request targeting `main` is covered.
2. The read-only Ubuntu job passes, including the tracked helper harness under PowerShell 7.
3. The Windows matrix displays and completes four distinct edition/EOL cells against committed `HEAD`.
4. The two LF cells complete the tracked helper harness and lone-CR sanitation under their assigned editions; neither CRLF cell repeats the helper suite.
5. Diagnostic upload uses the approved pinned upload action.
6. Push-only preparation, approval, and synchronization jobs skip.
7. No pull-request job has `contents: write`.

### Post-merge evidence

After merge to `main`, confirm:

1. Read-only preparation runs.
2. It uploads exactly one immutable candidate using the approved pinned upload action.
3. It exposes a nonempty ID and 64-hex digest.
4. Every Windows push cell downloads that exact ID using the approved pinned download action.
5. Native digest behavior is `error`.
6. Every cell runs the tracked deterministic helper harness, creates one unique
   job-owned trusted temporary root, and invokes the shared helper with
   explicit checkout/trusted roots and caller-owned artifact/run context; the
   helper uses `FileShare.Read`, hashes and parses one held stream, validates
   the full path envelope/manifest before candidate creation, and safely
   extracts or cleans the exact permitted bytes.
7. The read-only approval job succeeds only after all four cells.
8. Because sources and generated artifacts were committed together, preparation reports `has_changes=false`.
9. The write-enabled synchronization job skips.
10. No bot synchronization commit is created.

The synchronization consumer's helper integration is established by the prerequisite issue's controlled `has_changes=true` write-path evidence and static inspection; this issue's expected no-drift push skips the synchronization job and executes none of its steps.

If preparation reports changes, treat that as a source/artifact synchronization failure. Do not accept a recovery commit as this issue's expected outcome.

## Scope and non-goals

- Do not change rule requirements.
- Do not modify the Compliant example.
- Do not store literal trailing spaces.
- Do not add downstream-specific guidance.
- Do not modify `.gitattributes`.
- Do not modify `.github/workflows/Generate-StyleGuideArtifacts.ps1`.
- Do not modify `.github/workflows/Expand-StyleGuideCandidateArtifact.ps1`.
- Do not modify `.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1`.
- Do not modify `.github/workflows/build.yml`.
- Do not modify `.github/workflows/markdownlint.yml`.
- Do not modify `.github/dependabot.yml`.
- Do not modify `.github/workflows/package.json` or
  `.github/workflows/package-lock.json`; P3 owns that work.
- Do not modify `.github/copilot-instructions.md`.
- Do not modify `CONTRIBUTING.md`.
- Do not hand-edit generated artifacts.
- Do not change the version format.

## Acceptance criteria

- The two examples visibly differ.
- The complete canonical Non-Compliant snippet is exact and safely explained.
- Its third line contains exactly four U+00B7 characters and nothing else.
- The Compliant example remains unchanged.
- No literal trailing whitespace is introduced.
- The canonical snippet and exact operational heading each occur exactly once in `STYLE_GUIDE.md` and each generated artifact.
- The rationale contains exactly one ordinal line equal to
  `### Blank Line Usage`; that existing section remains generic and portable
  and does not duplicate the canonical snippet or operational heading.
- Metadata is recalculated at finalization with the Minor component incremented.
- Both sources and all four generated artifacts are committed together.
- Every validation block starts with `$ErrorActionPreference = 'Stop'`.
- Every required native command has an immediate exit-code check.
- Local validation resolves Node/npm applications, requires Node major 24
  before clean installation, and restores the caller's `CI` environment state.
- Before staging, the complete changed-path set is exactly the six affected files.
- After staging, the cached path set is exactly the same six files.
- No touched file begins with a UTF-8 BOM.
- No touched file contains a carriage-return byte.
- The canonical validator rejects a wrong target block even when an unrelated four-middle-dot line is present.
- The canonical validator uses the local ordinal-count script block, not an undocumented named function, and the fenced command parses in Windows PowerShell 5.1 and PowerShell 7.
- Lint, whitespace, and generator-idempotency checks pass.
- Pull-request Ubuntu verification and its PowerShell 7 helper harness pass.
- The four-cell pull-request Windows matrix, both LF-cell helper-harness executions, and both lone-CR probes pass.
- Post-merge consumers use the approved pinned artifact actions.
- The native digest configuration and the helper's independent digest comparison pass.
- All four Windows push cells run the tracked deterministic helper harness and production helper.
- Static inspection and P1's controlled `has_changes=true` drill prove that a started synchronization job runs the same harness/helper sequence before mutation.
- Every production helper invocation receives explicit checkout/trusted roots and caller-owned artifact/run context.
- The post-merge push matrix validates the exact immutable candidate through
  unique job-owned roots, `FileShare.Read`, the same-held-stream digest/archive
  contract, full-component enumeration/revalidation, pre-creation manifest
  validation, and fail-closed cleanup.
- Post-merge preparation reports no candidate changes.
- Synchronization skips at the job level, none of its steps run, and no recovery commit is created.
- No unrelated or downstream-specific change is introduced.

## References

- [Unicode Consortium: Latin-1 Supplement](https://www.unicode.org/charts/PDF/U0080.pdf)
- [GitHub Docs: Code blocks](https://docs.github.com/get-started/writing-on-github/working-with-advanced-formatting/creating-and-highlighting-code-blocks)
- [EditorConfig: `trim_trailing_whitespace`](https://spec.editorconfig.org/#supported-pairs)
- [pre-commit-hooks: `trailing-whitespace`](https://github.com/pre-commit/pre-commit-hooks#trailing-whitespace)
- [Microsoft Learn: `System.Version`](https://learn.microsoft.com/dotnet/api/system.version)
- [Microsoft Learn: `about_Preference_Variables`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_preference_variables)
- [Microsoft Learn: `about_Automatic_Variables`](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_automatic_variables)
- [Microsoft Learn: `File.ReadAllBytes`](https://learn.microsoft.com/dotnet/api/system.io.file.readallbytes)
- [Microsoft Learn: `File.ReadAllText`](https://learn.microsoft.com/dotnet/api/system.io.file.readalltext)
- [Git: `git status`](https://git-scm.com/docs/git-status)
- [Git: `git diff`](https://git-scm.com/docs/git-diff)
- [npm Docs: `npm ci`](https://docs.npmjs.com/cli/commands/npm-ci)
- [GitHub Docs: Workflow syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax)
- [GitHub Docs: Secure use reference](https://docs.github.com/en/actions/reference/security/secure-use)
- [GitHub: `actions/checkout` v7.0.1 exact metadata](https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml)
- [GitHub: `actions/setup-node` v7.0.0 exact metadata](https://raw.githubusercontent.com/actions/setup-node/820762786026740c76f36085b0efc47a31fe5020/action.yml)
- [GitHub: `actions/upload-artifact` v7.0.1 exact metadata](https://raw.githubusercontent.com/actions/upload-artifact/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a/action.yml)
- [GitHub: `actions/upload-artifact` v7.0.1 exact README](https://raw.githubusercontent.com/actions/upload-artifact/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a/README.md)
- [GitHub: `actions/upload-artifact` v7.0.1 release](https://github.com/actions/upload-artifact/releases/tag/v7.0.1)
- [GitHub: `actions/download-artifact` v8.0.1 exact metadata](https://raw.githubusercontent.com/actions/download-artifact/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/action.yml)
- [GitHub: `actions/download-artifact` v8.0.1 exact README](https://raw.githubusercontent.com/actions/download-artifact/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/README.md)
- [GitHub: `actions/download-artifact` v8.0.1 exact implementation](https://raw.githubusercontent.com/actions/download-artifact/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/src/download-artifact.ts)
- [GitHub: `actions/download-artifact` v8.0.1 release](https://github.com/actions/download-artifact/releases/tag/v8.0.1)
- [franklesniak/copilot-repo-template#851](https://github.com/franklesniak/copilot-repo-template/issues/851)
- [franklesniak/copilot-repo-template#852](https://github.com/franklesniak/copilot-repo-template/pull/852)
