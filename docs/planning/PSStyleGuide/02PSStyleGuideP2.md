# Make the non-compliant blank-line example visibly distinct

> **Dependency:** Implement this issue only after **Promote generated
> style-guide artifacts through a least-privileged verified writer** (P1B) has
> merged. When the issues have been filed, record the real blocked-by
> relationship to P1B.

## Summary

In `STYLE_GUIDE.md`, the `### Blank Line Usage` section presents Compliant and Non-Compliant examples intended to contrast a truly empty blank line with a blank line containing spaces. Both stored examples currently have an empty third line, making them byte-identical and contradicting the explanatory sentence that follows.

Replace the invisible defect with a durable visible visualization. Keep concise, operational interpretation in `STYLE_GUIDE.md`, and place the explanation of why visible substitutes are needed in `STYLE_GUIDE_RATIONALE.md`.

The guidance must remain self-contained and applicable to every adopter of the PowerShell style guide, not only the downstream repository where the defect was discovered.

This originated from the cross-repository work tracked in [franklesniak/copilot-repo-template#851](https://github.com/franklesniak/copilot-repo-template/issues/851) and [franklesniak/copilot-repo-template#852](https://github.com/franklesniak/copilot-repo-template/pull/852).

## Prerequisite

Complete and merge P1B before starting. P1B already depends on exact P1 and
P1A merge commits, so it is P2's one final prerequisite. At filing, replace
the title-only reference with P1B's actual issue URL and mark P2 blocked by
P1B. Retrieve both issues and verify repository, number, title, and dependency
relationship before readying P2; do not use a placeholder.

At implementation start, record P1B's exact merge commit and confirm these
enduring interface evidence:

- P1B's actual issue URL and real GitHub blocked-by relationship;
- exact P1/P1A/P1B merge commits;
- generator/helper/context/harness/workflow-policy/path-verifier versions and
  hashes;
- final action provenance, explicit-input, and pinned-manifest-default records;
- retained P1B positive/negative run IDs and exact evidence-workflow removal;
- preparation artifact ID/digest/four hashes, four attestations, approval, and
  writer identity evidence;
- complete P1↔T1, P1A↔T1A, and P1B↔T1B matrices with no unexplained blocker;
  and
- exact merged `.github/dependabot.yml` review-only Actions entry.

P1/P1A/P1B remain the sole source of truth for generator, candidate,
workflow, transport, matrix, approval, credential, and writer algorithms. P2
consumes the exact merged interfaces and retained evidence; it does not
paraphrase or change those algorithms.

**P3: Remediate Markdown lint dependency advisories and add npm update
governance** follows P2. It is not a P2 prerequisite, and its package changes
must not be silently folded into this issue. At filing, replace this title-only
draft reference with P3's actual issue URL wherever P2 delegates npm ownership.

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

Keep this complete Compliant heading and fenced block ordinally unchanged and
copy-ready:

````text
**Compliant (blank line is truly empty):**

```powershell
{
    Invoke-SomeCmdlet

    Invoke-AnotherCmdlet
}
```
````

Before editing, record the exact prerequisite commit and SHA-256 of that
LF-joined snippet. Require exactly one ordinal occurrence in `STYLE_GUIDE.md`
before and after editing and, after regeneration, exactly one in each
generated artifact. Do not trim or normalize before comparison. Negative
self-tests change the empty line, fence language, command text, and duplicate
the block; every mutation must fail.

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

$arrExpectedPaths = @(
    'STYLE_GUIDE.md'
    'STYLE_GUIDE_RATIONALE.md'
    'copilot-instructions.md'
    'powershell.instructions.md'
    'STYLE_GUIDE_CHAT.md'
    'STYLE_GUIDE_FULL.md'
) | Sort-Object

& pwsh `
    -NoLogo `
    -NoProfile `
    -File './.github/workflows/Test-ExactGitPathSet.ps1' `
    -RepositoryRoot '.' `
    -ExpectedPath $arrExpectedPaths `
    -Mode 'Both'

$intVerifierExitCode = $LASTEXITCODE

if ($intVerifierExitCode -ne 0) {
    throw (
        "Pre-stage exact path-set validation failed with exit code {0}." -f
        $intVerifierExitCode
    )
}

git add -- $arrExpectedPaths
$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw ("git add failed with exit code {0}." -f $intGitExitCode)
}

& pwsh `
    -NoLogo `
    -NoProfile `
    -File './.github/workflows/Test-ExactGitPathSet.ps1' `
    -RepositoryRoot '.' `
    -ExpectedPath $arrExpectedPaths `
    -Mode 'Staged' `
    -RequireWorkingSetEmpty

$intVerifierExitCode = $LASTEXITCODE

if ($intVerifierExitCode -ne 0) {
    throw (
        "Post-stage exact path-set validation failed with exit code {0}." -f
        $intVerifierExitCode
    )
}
```

The exact merged P1 verifier captures raw native stdout with
`System.Diagnostics.Process`, parses NUL-delimited records, disables rename
collapse, and unions unstaged/cached/untracked sources. Do not replace it with
line-oriented `git status` or `git diff --name-only`.

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

$arrCanonicalCompliantSnippetLines = @(
    '**Compliant (blank line is truly empty):**'
    ''
    '```powershell'
    '{'
    '    Invoke-SomeCmdlet'
    ''
    '    Invoke-AnotherCmdlet'
    '}'
    '```'
)

$strCanonicalCompliantSnippet = $arrCanonicalCompliantSnippetLines -join "`n"
$strCompliantMarker = $arrCanonicalCompliantSnippetLines[0]

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

    $intCompliantSnippetCount = & $scriptGetOrdinalOccurrenceCount `
        -Content $strContent `
        -Needle $strCanonicalCompliantSnippet

    $intCompliantMarkerCount = & $scriptGetOrdinalOccurrenceCount `
        -Content $strContent `
        -Needle $strCompliantMarker

    $intMarkerCount = & $scriptGetOrdinalOccurrenceCount `
        -Content $strContent `
        -Needle $strNonCompliantMarker

    if (
        $intSnippetCount -ne 1 -or
        $intMarkerCount -ne 1 -or
        $intCompliantSnippetCount -ne 1 -or
        $intCompliantMarkerCount -ne 1
    ) {
        throw (
            ("Canonical example count mismatch in {0}; expected " +
            "Compliant snippet/marker and Non-Compliant snippet/marker " +
            "counts 1/1/1/1, actual {1}/{2}/{3}/{4}.") -f
            $strGuideBearingPath,
            $intCompliantSnippetCount,
            $intCompliantMarkerCount,
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

if ($intGitExitCode -eq 1) {
    & pwsh `
        -NoLogo `
        -NoProfile `
        -File './.github/workflows/Test-ExactGitPathSet.ps1' `
        -RepositoryRoot '.' `
        -ExpectedPath $arrExpectedStagedPaths `
        -Mode 'Both'

    $intVerifierExitCode = $LASTEXITCODE

    if ($intVerifierExitCode -ne 0) {
        throw (
            ("Generator drift occurred and exact path-set validation also " +
            "failed with exit code {0}.") -f
            $intVerifierExitCode
        )
    }

    throw (
        "The final generator run differs from the staged expected result."
    )
}
elseif ($intGitExitCode -ne 0) {
    throw (
        "Unable to compare the final generator result; git command failed " +
        "with exit code {0}." -f
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

& pwsh `
    -NoLogo `
    -NoProfile `
    -File './.github/workflows/Test-ExactGitPathSet.ps1' `
    -RepositoryRoot '.' `
    -ExpectedPath $arrExpectedStagedPaths `
    -Mode 'Staged' `
    -RequireWorkingSetEmpty

$intVerifierExitCode = $LASTEXITCODE

if ($intVerifierExitCode -ne 0) {
    throw (
        "Final exact path-set validation failed with exit code {0}." -f
        $intVerifierExitCode
    )
}
```

### Content confirmation

Confirm:

- The exact baseline Compliant snippet/digest is unchanged and its
  snippet/marker each occur exactly once in every guide-bearing file.
- The Non-Compliant visualization visibly differs.
- Line 3 contains exactly four U+00B7 characters and nothing else.
- The warning precedes the visualization.
- The dots are explicitly identified as documentation substitutes that must not be copied.
- No touched line has literal trailing whitespace.
- No touched file contains a carriage-return byte.
- The complete canonical Non-Compliant snippet and its exact heading marker
  each occur exactly once in `STYLE_GUIDE.md` and each generated artifact.
- `STYLE_GUIDE_RATIONALE.md` contains neither the canonical snippet nor its exact operational heading.
- An ordinal exact-line count proves `STYLE_GUIDE_RATIONALE.md` contains
  exactly one `### Blank Line Usage` heading.
- That existing rationale section explains the durability and portability
  reasons without creating a duplicate section.
- No downstream-specific assumption appears.
- Version and Last Updated agree with the finalized target baseline and UTC implementation date.
- All four generated artifacts match the authoritative sources.
- No touched file begins with `EF BB BF`.
- P1's raw NUL-safe verifier proves the working-tree and staged-path sets are
  each exactly the two sources and four generated artifacts.

### Pull-request evidence

While the pull request is open, confirm:

1. Verification runs because every pull request targeting `main` is covered.
2. Preparation uploads the immutable four-file candidate, including the
   no-change case.
3. The same-commit local Markdown/dependency call passes read-only.
4. All four Windows edition/EOL cells execute every applicable P1A ID and the
   exact production helper/context/harness against that candidate.
5. Four unique hash-bound attestations reach the read-only terminal approval.
6. Approval succeeds only after the exact successful dependency result set.
7. The writer skips because a pull request is not an approved changed push to
   `main`; no pull-request job has `contents: write`.

### Post-merge evidence

After merge to `main`, confirm:

1. The same read-only preparation/Markdown/four-cell/approval graph succeeds
   against the merged commit.
2. Preparation reports `has_changes=false` because both sources and all four
   generated artifacts were committed together.
3. The writer skips at job level and none of its steps run.
4. No bot synchronization commit is created.

P1B's exact merge and retained controlled `has_changes=true` evidence remain
the authority for writer internals. If P2 preparation reports changes, fail as
a source/artifact synchronization defect; do not accept a recovery commit as
P2's expected outcome.

## Scope and non-goals

- Do not change rule requirements.
- Do not modify the Compliant example.
- Do not store literal trailing spaces.
- Do not add downstream-specific guidance.
- Do not modify `.gitattributes`.
- Do not modify `.github/workflows/Generate-StyleGuideArtifacts.ps1`.
- Do not modify `.github/workflows/Expand-StyleGuideCandidateArtifact.ps1`.
- Do not modify
  `.github/workflows/Manage-StyleGuideCandidateInvocationContext.ps1`.
- Do not modify `.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1`.
- Do not modify `.github/workflows/Validate-WorkflowPolicy.mjs`.
- Do not modify `.github/workflows/Test-ExactGitPathSet.ps1`.
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
- The exact baseline Compliant snippet/digest remains ordinally unchanged,
  occurs once per guide-bearing file, and passes mutation self-tests.
- No literal trailing whitespace is introduced.
- The canonical Non-Compliant snippet and exact operational heading each occur
  exactly once in `STYLE_GUIDE.md` and each generated artifact.
- The rationale contains exactly one ordinal line equal to
  `### Blank Line Usage`; that existing section remains generic and portable
  and does not duplicate the canonical snippet or operational heading.
- Metadata is recalculated at finalization with the Minor component incremented.
- Both sources and all four generated artifacts are committed together.
- Every validation block starts with `$ErrorActionPreference = 'Stop'`.
- Every required native command has an immediate exit-code check.
- Local validation resolves Node/npm applications, requires Node major 24
  before clean installation, and restores the caller's `CI` environment state.
- Before staging, P1's raw NUL-safe verifier proves the complete changed-path
  set is exactly the six affected files.
- After staging and final rerun, the same verifier proves cached equality and
  an empty unstaged/untracked set.
- No touched file begins with a UTF-8 BOM.
- No touched file contains a carriage-return byte.
- The canonical validator rejects a wrong target block even when an unrelated four-middle-dot line is present.
- The canonical validator uses the local ordinal-count script block, not an undocumented named function, and the fenced command parses in Windows PowerShell 5.1 and PowerShell 7.
- Lint, whitespace, and generator-idempotency checks pass.
- `git diff --exit-code` distinguishes equal, ordinary generator difference,
  and Git command failure with stable diagnostics.
- Pull-request preparation, same-commit Markdown call, all four P1B Windows
  cells, four unique hash-bound attestations, and read-only approval pass.
- The pull-request writer skips and no pull-request job has write permission.
- Post-merge preparation reports no candidate changes.
- Post-merge writer skips at job level, none of its steps run, and no recovery
  commit is created.
- Exact P1B merge/run evidence remains the sole authority for publication
  internals; P2 does not restate them.
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
