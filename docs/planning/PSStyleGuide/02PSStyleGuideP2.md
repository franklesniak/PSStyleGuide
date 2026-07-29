# Make the non-compliant blank-line example visibly distinct

> **Dependency:** Implement this issue only after **Make artifact generation byte-deterministic across PowerShell editions and hosts** has merged. When both issues have been filed, record the GitHub blocked-by relationship using the actual prerequisite issue.

## Summary

In `STYLE_GUIDE.md`, the `### Blank Line Usage` section presents Compliant and Non-Compliant examples intended to contrast a truly empty blank line with a blank line containing spaces. Both stored examples currently have an empty third line, making them byte-identical and contradicting the explanatory sentence that follows.

Replace the invisible defect with a durable visible visualization. Keep concise, operational interpretation in `STYLE_GUIDE.md`, and place the explanation of why visible substitutes are needed in `STYLE_GUIDE_RATIONALE.md`.

The guidance must remain self-contained and applicable to every adopter of the PowerShell style guide, not only the downstream repository where the defect was discovered.

This originated from the cross-repository work tracked in [franklesniak/copilot-repo-template#851](https://github.com/franklesniak/copilot-repo-template/issues/851) and [franklesniak/copilot-repo-template#852](https://github.com/franklesniak/copilot-repo-template/pull/852).

## Prerequisite

Complete and merge **Make artifact generation byte-deterministic across PowerShell editions and hosts** before starting.

At implementation start, confirm:

- Complete generator payloads canonicalize CRLF and lone CR to LF.
- Writes use resolved paths and BOM-less `UTF8Encoding($false)`.
- `#Requires -Version 5.1` remains.
- `.gitattributes` still contains `* text=auto eol=lf`.
- The generator and `.github/workflows/Expand-StyleGuideCandidateArtifact.ps1` have recorded script versions.
- Every pull request targeting `main` runs read-only Ubuntu and Windows verification.
- Every push to `main` runs the push pipeline.
- Neither event has a path filter.
- Artifact actions are pinned to approved full commit SHAs with matching release comments.
- Push preparation declares `archive: true`, uploads one immutable candidate, and exposes its ID and SHA-256 digest.
- Push consumers download only by immutable ID.
- Native downloads use `skip-decompress: true` and `digest-mismatch: error`.
- The versioned shared archive-validation helper is the only candidate extraction implementation.
- Every push consumer passes preparation's propagated upload digest to the helper, which independently compares it with the retained ZIP's SHA-256 before opening the archive.
- Every push consumer runs the deterministic fixture self-test suite against that exact helper on every run, including the digest-mismatch fixture.
- The helper validates the full ZIP manifest before creating or writing the candidate directory.
- The Windows topology contains four actual edition × fixture-EOL cells.
- Each Windows cell validates only its assigned edition and EOL.
- The two LF cells run lone-CR sanitation under their assigned editions.
- A read-only approval job exposes the candidate only after all four push cells succeed.
- The sole write job verifies candidate, destination, staged, and committed blob IDs.
- The write job uses `HEAD:<full-ref>` and an exact expected-SHA `--force-with-lease`.
- Unconditional force updates are prohibited.
- Stale committed artifacts fail pull-request verification.
- The controlled synchronization, propagated-digest rejection, unrelated-trigger, stale-preflight, and exact-lease evidence has passed without creating a synthetic `main` commit.

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

Use content materially equivalent to:

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

### 2. Extend `STYLE_GUIDE_RATIONALE.md`

Explain generically that:

- Literal spaces on an otherwise blank line are invisible.
- Editors, formatters, and whitespace-cleanup tools can remove them.
- The Non-Compliant example can therefore drift into byte identity with the Compliant example.
- Visible substitutes preserve the intended defect while keeping the stored Markdown free of trailing whitespace.
- Middle dots are documentation annotations, not PowerShell syntax.

Keep operational guidance concise in `STYLE_GUIDE.md` and extended reasoning in `STYLE_GUIDE_RATIONALE.md`.

### 3. Advance metadata

At finalization, reread Version and Last Updated from the target branch.

1. Increment the Minor component because the change adds a durable documentation convention and repairs the example's semantics.
2. Use the current UTC date for Build and Last Updated.
3. Set Revision to `0` when `Major.Minor.Build` changes.
4. If that `Major.Minor.Build` already exists at Revision `N`, use `N + 1`.
5. Recompute if the target branch or UTC date changes.
6. Add the matching top rationale changelog row.
7. Commit metadata with the source change.

Drift-only snapshot: if the target remains `2.23.20260726.0` with Last Updated `2026-07-26`, and implementation occurs on 2026-07-28 UTC, use `2.24.20260728.0` and `2026-07-28`. Otherwise recompute.

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

npm --prefix .github/workflows ci
$intNpmExitCode = $LASTEXITCODE

if ($intNpmExitCode -ne 0) {
    throw ("npm ci failed with exit code {0}." -f $intNpmExitCode)
}

& pwsh `
    -NoLogo `
    -NoProfile `
    -File './.github/workflows/Generate-StyleGuideArtifacts.ps1'

$intGeneratorExitCode = $LASTEXITCODE

if ($intGeneratorExitCode -ne 0) {
    throw ("Generator failed with exit code {0}." -f $intGeneratorExitCode)
}

npm --prefix .github/workflows run lint:md
$intNpmExitCode = $LASTEXITCODE

if ($intNpmExitCode -ne 0) {
    throw ("Markdown lint failed with exit code {0}." -f $intNpmExitCode)
}

npm --prefix .github/workflows run lint:md:nested
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

$arrTouchedPaths = @(
    'STYLE_GUIDE.md'
    'STYLE_GUIDE_RATIONALE.md'
    'copilot-instructions.md'
    'powershell.instructions.md'
    'STYLE_GUIDE_CHAT.md'
    'STYLE_GUIDE_FULL.md'
)

$arrExpectedStagedPaths = @($arrTouchedPaths | Sort-Object)

$strMiddleDot = [string][char]0x00B7
$strVisualizationLine = "`n" + ($strMiddleDot * 4) + "`n"
$strNonCompliantMarker = 'Non-Compliant (blank line contains spaces'

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

    if ($strContent.Contains($strNonCompliantMarker)) {
        if (-not $strContent.Contains($strVisualizationLine)) {
            throw (
                "File contains the Non-Compliant example but not the exact " +
                "four-middle-dot visualization line: {0}" -f
                $strTouchedPath
            )
        }
    }
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
- Every touched file that contains the Non-Compliant example contains the exact four-middle-dot visualization line.
- The rationale explains the durability and portability reasons.
- No downstream-specific assumption appears.
- Version, Last Updated, and changelog metadata agree.
- All four generated artifacts match the authoritative sources.
- No touched file begins with `EF BB BF`.
- The working-tree and staged-path sets are each exactly the two sources and four generated artifacts.

### Pull-request evidence

While the pull request is open, confirm:

1. Verification runs because every pull request targeting `main` is covered.
2. The read-only Ubuntu job passes.
3. The Windows matrix displays and completes four distinct edition/EOL cells against committed `HEAD`.
4. The two LF cells complete lone-CR sanitation under their assigned editions.
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
6. Every cell runs the deterministic helper self-test and invokes the shared helper, which independently rehashes the retained ZIP against the propagated digest and validates the manifest before safe extraction.
7. The read-only approval job succeeds only after all four cells.
8. Because sources and generated artifacts were committed together, preparation reports `has_changes=false`.
9. The write-enabled synchronization job skips.
10. No bot synchronization commit is created.

The synchronization consumer's helper integration is established by the prerequisite issue's controlled write-path evidence and static inspection; this issue's no-drift push does not execute the writer.

If preparation reports changes, treat that as a source/artifact synchronization failure. Do not accept a recovery commit as this issue's expected outcome.

## Scope and non-goals

- Do not change rule requirements.
- Do not modify the Compliant example.
- Do not store literal trailing spaces.
- Do not add downstream-specific guidance.
- Do not modify `.gitattributes`.
- Do not modify `.github/workflows/Generate-StyleGuideArtifacts.ps1`.
- Do not modify `.github/workflows/Expand-StyleGuideCandidateArtifact.ps1`.
- Do not modify `.github/workflows/build.yml`.
- Do not modify `.github/copilot-instructions.md`.
- Do not modify `CONTRIBUTING.md`.
- Do not hand-edit generated artifacts.
- Do not change the version format.

## Acceptance criteria

- The two examples visibly differ.
- The middle-dot visualization is exact and safely explained.
- Its third line contains exactly four U+00B7 characters and nothing else.
- The Compliant example remains unchanged.
- No literal trailing whitespace is introduced.
- Rationale remains generic and portable.
- Metadata is recalculated at finalization with the Minor component incremented.
- Both sources and all four generated artifacts are committed together.
- Every validation block starts with `$ErrorActionPreference = 'Stop'`.
- Every required native command has an immediate exit-code check.
- Before staging, the complete changed-path set is exactly the six affected files.
- After staging, the cached path set is exactly the same six files.
- No touched file begins with a UTF-8 BOM.
- No touched file contains a carriage-return byte.
- Every touched file containing the Non-Compliant example contains the exact four-middle-dot line.
- Lint, whitespace, and generator-idempotency checks pass.
- Pull-request Ubuntu verification passes.
- The four-cell pull-request Windows matrix and both lone-CR probes pass.
- Post-merge consumers use the approved pinned artifact actions.
- The native digest configuration and the helper's independent digest comparison pass.
- Deterministic helper self-tests pass in every consumer.
- The post-merge push matrix validates the exact immutable candidate after pre-extraction manifest validation.
- Post-merge preparation reports no candidate changes.
- Synchronization skips and no recovery commit is created.
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
- [GitHub: `actions/upload-artifact` v7 contract](https://raw.githubusercontent.com/actions/upload-artifact/v7/action.yml)
- [GitHub: `actions/download-artifact` v8 contract](https://raw.githubusercontent.com/actions/download-artifact/v8/action.yml)
- [GitHub: `actions/download-artifact` v8 implementation](https://raw.githubusercontent.com/actions/download-artifact/v8/src/download-artifact.ts)
- [franklesniak/copilot-repo-template#851](https://github.com/franklesniak/copilot-repo-template/issues/851)
- [franklesniak/copilot-repo-template#852](https://github.com/franklesniak/copilot-repo-template/pull/852)
