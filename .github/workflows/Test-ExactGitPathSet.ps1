#Requires -Version 5.1

<#
.SYNOPSIS
Verifies a Git working, staged, or combined path set without decoding Git paths.

.DESCRIPTION
Runs fixed NUL-delimited Git commands, parses stdout as raw bytes, and compares
the observed path set with caller-supplied canonical ASCII repository paths.
Observed path bytes are never decoded or printed.

.PARAMETER RepositoryRoot
Explicit absolute root of the Git worktree to inspect.

.PARAMETER ExpectedPath
Exact canonical ASCII repository-relative path set.

.PARAMETER Mode
Working, Staged, or Both.

.PARAMETER RequireCleanWorkingAgainstIndex
Also require git diff --exit-code to report no working-tree difference.

.PARAMETER GitExecutablePath
Optional exact absolute path of the Git executable. When omitted, the script
uses the module-qualified application resolver once before any Git invocation.

.NOTES
Version: 1.0.20260818.3
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$RepositoryRoot,

    [Parameter(Mandatory = $true)]
    [AllowEmptyCollection()]
    [string[]]$ExpectedPath,

    [Parameter(Mandatory = $true)]
    [ValidateSet('Working', 'Staged', 'Both')]
    [string]$Mode,

    [switch]$RequireCleanWorkingAgainstIndex,

    [AllowNull()]
    [string]$GitExecutablePath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:strVerifierVersion = '1.0.20260818.3'
$script:strVerifierResultSchema = 'PSStyleGuide.ExactGitPathSetResult.v2'
# Wall-clock ceiling for any single native Git invocation (Invoke-GitRaw). The path-set
# reads are sub-second metadata queries, so this 120-second default is orders of magnitude
# above any legitimate run yet converts an otherwise unbounded hang -- for example a
# 'git diff --cached' wedged opening a FIFO substituted into the object store between the
# pre-read scan (Assert-OrdinaryTreeUnder) and the read -- into a prompt, fail-closed
# native-command-timeout. Invoke-GitRaw exposes a per-call override so a test can drive a
# short bound; nothing in normal operation lowers it.
$script:intNativeCommandTimeoutMilliseconds = 120000
# Byte ceiling for hashing the resolved Git executable during authentication. A real Git
# binary is a few MiB, so 512 MiB is over a hundred times any legitimate size yet bounds the
# incremental hash, so an oversized or continuously growing candidate produces a prompt
# git-executable-limit failure instead of reading gigabytes before Git is ever started.
$script:longGitExecutableMaximumBytes = 536870912
$script:objUtf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
# SHA-256 of the empty input, computed once. Get-TreeEvidence records this for every
# zero-length regular file instead of allocating a fresh SHA256 instance and an empty
# byte[] per file (the digest of empty content is constant). The instance ComputeHash
# API is used because the static SHA256.HashData is .NET 5+ only and absent on the
# supported Windows PowerShell 5.1 host.
$script:strEmptyFileSha256 = & {
    $objEmptyDigest = [System.Security.Cryptography.SHA256]::Create()
    try {
        ([System.BitConverter]::ToString(
            $objEmptyDigest.ComputeHash((New-Object byte[] 0)))).Replace('-', '').ToLowerInvariant()
    } finally {
        $objEmptyDigest.Dispose()
    }
}
# Decide the host platform from the runtime, not from $env:OS, which any caller can set. On a
# Unix host that exports OS=Windows_NT, an $env:OS-based check would pick the Windows null
# device (a relative 'NUL' that resolves to a repository file), case-insensitive path
# comparison, and would skip the UnixMode-absent fail-closed guard. OSVersion.Platform is
# Win32NT on Windows and Unix on Linux/macOS on both .NET Framework and .NET.
$script:boolHostIsWindows = [System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT
$script:objPathComparison = if ($script:boolHostIsWindows) {
    [System.StringComparison]::OrdinalIgnoreCase
} else {
    [System.StringComparison]::Ordinal
}

function Get-ScriptVersionRecord {
    # .SYNOPSIS
    # Validates and parses the script's canonical version marker.
    #
    # .DESCRIPTION
    # Locates the only pre-function .NOTES block and the only Version marker,
    # validates its four numeric components and build date, requires it to equal
    # the expected version, and returns the parsed version fields.
    #
    # .PARAMETER ScriptText
    # Complete text of the script whose version marker is validated.
    #
    # .PARAMETER ExpectedVersion
    # Exact canonical four-component version that the marker must contain.
    #
    # .EXAMPLE
    # $hashtableVersion = Get-ScriptVersionRecord -ScriptText $strScriptText -ExpectedVersion '1.0.20000229.0'
    #
    # # Returns the validated version fields when the marker is canonical and equal.
    #
    # .EXAMPLE
    # Get-ScriptVersionRecord -ScriptText $strScriptText -ExpectedVersion '1.0.20000229.1'
    #
    # # Throws 'unexpected-version' when the canonical marker does not equal the expected value.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Collections.Specialized.OrderedDictionary. Contains Version, Major,
    # Minor, BuildDate, and Revision. Throws 'invalid-version' for malformed or
    # ambiguous metadata and 'unexpected-version' for an expected-value mismatch.
    # Parameter-binding and underlying regex or allocation failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: ScriptText
    #   Position 1: ExpectedVersion
    param (
        [Parameter(Mandatory = $true)]
        [string]$ScriptText,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedVersion
    )

    $objFirstFunction = [regex]::Match($ScriptText, '(?m)^function[\x20\x09]+[A-Za-z0-9_-]+[\x20\x09]*\{')
    if (-not $objFirstFunction.Success) {
        throw 'invalid-version'
    }
    $strPreamble = $ScriptText.Substring(0, $objFirstFunction.Index)
    $arrNoteBlocks = @([regex]::Matches($strPreamble, '(?s)<#(?:(?!#>).)*\.NOTES(?:(?!#>).)*#>'))
    $arrAllMarkers = @([regex]::Matches($ScriptText, '(?m)^Version:[^\r\n]*$'))
    if ($arrNoteBlocks.Count -ne 1 -or $arrAllMarkers.Count -ne 1) {
        throw 'invalid-version'
    }
    $strNotes = $arrNoteBlocks[0].Value
    $arrMarkers = @([regex]::Matches(
        $strNotes,
        '(?m)^Version: ([0-9]+)\.([0-9]+)\.([0-9]{8})\.([0-9]+)$'
    ))
    if ($arrMarkers.Count -ne 1 -or $arrMarkers[0].Value -cne $arrAllMarkers[0].Value) {
        throw 'invalid-version'
    }

    $arrComponents = @(
        $arrMarkers[0].Groups[1].Value,
        $arrMarkers[0].Groups[2].Value,
        $arrMarkers[0].Groups[3].Value,
        $arrMarkers[0].Groups[4].Value
    )
    foreach ($strComponent in $arrComponents) {
        if (($strComponent.Length -gt 1 -and $strComponent[0] -eq '0') -or
            $strComponent -notmatch '^[0-9]+$') {
            throw 'invalid-version'
        }
        $intValue = 0L
        if (-not [int64]::TryParse(
            $strComponent,
            [System.Globalization.NumberStyles]::None,
            [System.Globalization.CultureInfo]::InvariantCulture,
            [ref]$intValue
        ) -or $intValue -gt [int]::MaxValue) {
            throw 'invalid-version'
        }
    }

    $objBuildDate = [datetime]::MinValue
    if (-not [datetime]::TryParseExact(
        $arrComponents[2],
        'yyyyMMdd',
        [System.Globalization.CultureInfo]::InvariantCulture,
        [System.Globalization.DateTimeStyles]::None,
        [ref]$objBuildDate
    )) {
        throw 'invalid-version'
    }
    $strCanonicalVersion = $arrComponents -join '.'
    $objVersion = New-Object System.Version(
        [int]$arrComponents[0],
        [int]$arrComponents[1],
        [int]$arrComponents[2],
        [int]$arrComponents[3]
    )
    if ($objVersion.ToString() -cne $strCanonicalVersion) {
        throw 'invalid-version'
    }
    if ($strCanonicalVersion -cne $ExpectedVersion) {
        throw 'unexpected-version'
    }
    return [ordered]@{
        Version = $strCanonicalVersion
        Major = $objVersion.Major
        Minor = $objVersion.Minor
        BuildDate = $objBuildDate.ToString('yyyy-MM-dd', [System.Globalization.CultureInfo]::InvariantCulture)
        Revision = $objVersion.Revision
    }
}

function Test-ScriptVersionParser {
    # .SYNOPSIS
    # Exercises the script-version parser against fixed acceptance fixtures.
    #
    # .DESCRIPTION
    # Confirms one leap-day version is accepted, a version mismatch is
    # categorized as unexpected, and malformed, duplicate, overflow, misplaced,
    # and non-date markers are rejected as invalid.
    #
    # .EXAMPLE
    # Test-ScriptVersionParser
    #
    # # Produces no output when every acceptance and rejection fixture behaves as expected.
    #
    # .EXAMPLE
    # [void](Test-ScriptVersionParser)
    #
    # # Re-runs the fixed parser self-test and discards its intentionally empty output.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # None. Throws 'version-fixture-failure' when a mismatched or invalid fixture
    # is unexpectedly accepted and reaches its explicit sentinel. A valid-fixture
    # rejection, a wrong rejection category, and other parser exceptions propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function declares no parameters.
    param ()

    $strValid = "<#`n.NOTES`nVersion: 1.0.20000229.0`n#>`nfunction Test-Fixture {}`n"
    $arrInvalid = @(
        "<#`n.NOTES`n#>`nfunction Test-Fixture {}`n",
        "<#`n.NOTES`nVersion: 1.0.20000229.0`nVersion: 1.0.20000229.0`n#>`nfunction Test-Fixture {}`n",
        "<#`n.NOTES`nVersion: 01.0.20000229.0`n#>`nfunction Test-Fixture {}`n",
        "<#`n.NOTES`nVersion: 1.0.20010229.0`n#>`nfunction Test-Fixture {}`n",
        "<#`n.NOTES`nVersion: 1.0.20000229.2147483648`n#>`nfunction Test-Fixture {}`n",
        "<#`n.NOTES`nVersion: 1.0.20000229.0.1`n#>`nfunction Test-Fixture {}`n",
        "<#`n.NOTES`nVersion: 1.0.20000229.-1`n#>`nfunction Test-Fixture {}`n",
        "<#`n.NOTES`n#>`nfunction Test-Fixture {`n<#`n.NOTES`nVersion: 1.0.20000229.0`n#>`n}`n"
    )
    [void](Get-ScriptVersionRecord -ScriptText $strValid -ExpectedVersion '1.0.20000229.0')
    try {
        [void](Get-ScriptVersionRecord -ScriptText $strValid -ExpectedVersion '1.0.20000229.1')
        throw 'version-fixture-failure'
    } catch {
        if ($_.Exception.Message -cne 'unexpected-version') {
            throw
        }
    }
    foreach ($strFixture in $arrInvalid) {
        try {
            [void](Get-ScriptVersionRecord -ScriptText $strFixture -ExpectedVersion '1.0.20000229.0')
            throw 'version-fixture-failure'
        } catch {
            if ($_.Exception.Message -cne 'invalid-version') {
                throw
            }
        }
    }
}

function Test-WorktreeDirectoryIdentityEvidence {
    # .SYNOPSIS
    # Confirms worktree classification omits directory identity while the control
    # surface retains it.
    #
    # .DESCRIPTION
    # Builds a temporary tree and checks three facts through Get-TreeEvidence: an
    # empty untracked directory does not change the worktree digest (F4), the same
    # directory does change the control-surface digest, and a file inside a traversed
    # directory is still recorded in the worktree digest so traversal is preserved.
    #
    # .EXAMPLE
    # Test-WorktreeDirectoryIdentityEvidence
    #
    # # Produces no output when every fixture behaves as expected.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # None. Throws 'worktree-directory-fixture-failure' when a fixture behaves
    # unexpectedly. Filesystem and hashing failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260818.1
    #
    # This function declares no parameters.
    param ()

    $strFixtureRoot = [System.IO.Path]::Combine(
        [System.IO.Path]::GetTempPath(),
        ('exactgitpathset-f4-' + [System.Guid]::NewGuid().ToString('N')))
    $objEmptyTracked = New-Object 'System.Collections.Generic.HashSet[string]' `
        ([System.StringComparer]::Ordinal)
    [void][System.IO.Directory]::CreateDirectory($strFixtureRoot)
    try {
        $strFullDirectory = Join-Path $strFixtureRoot 'full'
        $strLeafFile = Join-Path $strFullDirectory 'leaf.txt'
        [void][System.IO.Directory]::CreateDirectory($strFullDirectory)
        [System.IO.File]::WriteAllText($strLeafFile, 'leaf')
        $strEmptyDirectory = Join-Path $strFixtureRoot 'empty'

        # Worktree digest with only the file-bearing directory present.
        $strWorktreeFileOnly = [string](Get-TreeEvidence -RootPath $strFixtureRoot `
                -WorktreeClassification -TrackedRelativePath $objEmptyTracked `
                -AncestorBoundary $strFixtureRoot).Digest

        # Add an empty untracked directory. The worktree digest MUST NOT change, because
        # Git path-set streams report no empty directory, so the walk omits its identity.
        [void][System.IO.Directory]::CreateDirectory($strEmptyDirectory)
        $strWorktreeWithEmpty = [string](Get-TreeEvidence -RootPath $strFixtureRoot `
                -WorktreeClassification -TrackedRelativePath $objEmptyTracked `
                -AncestorBoundary $strFixtureRoot).Digest
        if ($strWorktreeFileOnly -cne $strWorktreeWithEmpty) {
            throw 'worktree-directory-fixture-failure'
        }

        # The control surface records the same directory as identity, so its digest MUST
        # change when the empty directory is present and then removed.
        $strControlWithEmpty = [string](Get-TreeEvidence -RootPath $strFixtureRoot `
                -AncestorBoundary $strFixtureRoot).Digest
        [System.IO.Directory]::Delete($strEmptyDirectory)
        $strControlFileOnly = [string](Get-TreeEvidence -RootPath $strFixtureRoot `
                -AncestorBoundary $strFixtureRoot).Digest
        if ($strControlWithEmpty -ceq $strControlFileOnly) {
            throw 'worktree-directory-fixture-failure'
        }

        # The directory is still traversed under worktree classification, so removing the
        # file inside it MUST change the worktree digest.
        [System.IO.File]::Delete($strLeafFile)
        $strWorktreeNoFile = [string](Get-TreeEvidence -RootPath $strFixtureRoot `
                -WorktreeClassification -TrackedRelativePath $objEmptyTracked `
                -AncestorBoundary $strFixtureRoot).Digest
        if ($strWorktreeFileOnly -ceq $strWorktreeNoFile) {
            throw 'worktree-directory-fixture-failure'
        }
    } finally {
        if ([System.IO.Directory]::Exists($strFixtureRoot)) {
            [System.IO.Directory]::Delete($strFixtureRoot, $true)
        }
    }
}

function Test-IgnoredControlFileEvidence {
    # .SYNOPSIS
    # Confirms an ignored .gitignore or .gitattributes stays evidence-relevant while other
    # ignored content is excluded.
    #
    # .DESCRIPTION
    # Builds a temporary tree that holds a .gitignore, a .gitattributes, and one unrelated
    # file, names all three as ignored-exclusion entries, and checks three facts through
    # Get-TreeEvidence (G1): a change to the unrelated ignored file does not change the
    # worktree digest, a change to the ignored .gitignore does, and a change to the ignored
    # .gitattributes does. Git reads both control files even when the ignored enumeration
    # lists them, so both must stay in the worktree evidence.
    #
    # .EXAMPLE
    # Test-IgnoredControlFileEvidence
    #
    # # Produces no output when every fixture behaves as expected.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # None. Throws 'ignored-control-file-fixture-failure' when a fixture behaves
    # unexpectedly. Filesystem and hashing failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260818.1
    #
    # This function declares no parameters.
    param ()

    $strFixtureRoot = [System.IO.Path]::Combine(
        [System.IO.Path]::GetTempPath(),
        ('exactgitpathset-g1-' + [System.Guid]::NewGuid().ToString('N')))
    $objEmptyTracked = New-Object 'System.Collections.Generic.HashSet[string]' `
        ([System.StringComparer]::Ordinal)
    [void][System.IO.Directory]::CreateDirectory($strFixtureRoot)
    try {
        $strGitignore = Join-Path $strFixtureRoot '.gitignore'
        $strGitattributes = Join-Path $strFixtureRoot '.gitattributes'
        $strUnrelated = Join-Path $strFixtureRoot 'ignored.bin'
        [System.IO.File]::WriteAllText($strGitignore, "ignored.bin`n")
        [System.IO.File]::WriteAllText($strGitattributes, "*.bin binary`n")
        [System.IO.File]::WriteAllText($strUnrelated, 'one')
        # All three are named as ignored-exclusion entries, exactly as the worktree read passes
        # the git ls-files --others --ignored output into AdditionalExcludedPath.
        $arrExcluded = @($strGitignore, $strGitattributes, $strUnrelated)

        $strBaseline = [string](Get-TreeEvidence -RootPath $strFixtureRoot `
                -AdditionalExcludedPath $arrExcluded -WorktreeClassification `
                -TrackedRelativePath $objEmptyTracked -AncestorBoundary $strFixtureRoot).Digest

        # A change to the unrelated ignored file MUST NOT change the digest: it stays excluded.
        [System.IO.File]::WriteAllText($strUnrelated, 'two-different-length')
        $strAfterUnrelated = [string](Get-TreeEvidence -RootPath $strFixtureRoot `
                -AdditionalExcludedPath $arrExcluded -WorktreeClassification `
                -TrackedRelativePath $objEmptyTracked -AncestorBoundary $strFixtureRoot).Digest
        if ($strBaseline -cne $strAfterUnrelated) {
            throw 'ignored-control-file-fixture-failure'
        }

        # A change to the ignored .gitignore MUST change the digest: Git reads it, so it stays
        # evidence-relevant even though it is named as ignored.
        [System.IO.File]::WriteAllText($strGitignore, "ignored.bin`nextra`n")
        $strAfterGitignore = [string](Get-TreeEvidence -RootPath $strFixtureRoot `
                -AdditionalExcludedPath $arrExcluded -WorktreeClassification `
                -TrackedRelativePath $objEmptyTracked -AncestorBoundary $strFixtureRoot).Digest
        if ($strBaseline -ceq $strAfterGitignore) {
            throw 'ignored-control-file-fixture-failure'
        }

        # Restore the .gitignore, then a change to the ignored .gitattributes MUST change the
        # digest for the same reason.
        [System.IO.File]::WriteAllText($strGitignore, "ignored.bin`n")
        [System.IO.File]::WriteAllText($strGitattributes, "*.bin -text`n")
        $strAfterGitattributes = [string](Get-TreeEvidence -RootPath $strFixtureRoot `
                -AdditionalExcludedPath $arrExcluded -WorktreeClassification `
                -TrackedRelativePath $objEmptyTracked -AncestorBoundary $strFixtureRoot).Digest
        if ($strBaseline -ceq $strAfterGitattributes) {
            throw 'ignored-control-file-fixture-failure'
        }
    } finally {
        if ([System.IO.Directory]::Exists($strFixtureRoot)) {
            [System.IO.Directory]::Delete($strFixtureRoot, $true)
        }
    }
}

function Test-EmbeddedRepositoryBoundaryEvidence {
    # .SYNOPSIS
    # Confirms an untracked embedded repository keeps its Git-reported root evidence but is
    # not traversed into its .git internals.
    #
    # .DESCRIPTION
    # Builds a temporary tree with a nested directory that itself holds a .git directory (an
    # untracked embedded repository), then checks four facts through Get-TreeEvidence (G2):
    # the embedded repository contributes exactly one entry and no hashed file; adding files
    # under its .git does not change the worktree digest or the entry count; adding a file
    # directly under the nested root does not change the digest either, because Git never
    # descends past the boundary; and removing the .git marker turns the directory into an
    # ordinary traversed directory, which does change the digest.
    #
    # .EXAMPLE
    # Test-EmbeddedRepositoryBoundaryEvidence
    #
    # # Produces no output when every fixture behaves as expected.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # None. Throws 'embedded-repository-fixture-failure' when a fixture behaves
    # unexpectedly. Filesystem and hashing failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260818.1
    #
    # This function declares no parameters.
    param ()

    $strFixtureRoot = [System.IO.Path]::Combine(
        [System.IO.Path]::GetTempPath(),
        ('exactgitpathset-g2-' + [System.Guid]::NewGuid().ToString('N')))
    $objEmptyTracked = New-Object 'System.Collections.Generic.HashSet[string]' `
        ([System.StringComparer]::Ordinal)
    [void][System.IO.Directory]::CreateDirectory($strFixtureRoot)
    try {
        $strNested = Join-Path $strFixtureRoot 'nested'
        $strNestedGit = Join-Path $strNested '.git'
        [void][System.IO.Directory]::CreateDirectory($strNestedGit)
        [System.IO.File]::WriteAllText((Join-Path $strNestedGit 'HEAD'), "ref: refs/heads/main`n")
        [System.IO.File]::WriteAllText((Join-Path $strNested 'file.txt'), 'inner')

        $objBoundary = Get-TreeEvidence -RootPath $strFixtureRoot -WorktreeClassification `
            -TrackedRelativePath $objEmptyTracked -AncestorBoundary $strFixtureRoot
        $strBoundaryDigest = [string]$objBoundary.Digest

        # The embedded repository contributes exactly one entry (nested) and no hashed file.
        if ([int]$objBoundary.EntryCount -ne 1 -or [int]$objBoundary.FileCount -ne 0) {
            throw 'embedded-repository-fixture-failure'
        }

        # Adding files under nested/.git MUST NOT change the digest or the entry count.
        [System.IO.File]::WriteAllText((Join-Path $strNestedGit 'config'), "[core]`n")
        [System.IO.File]::WriteAllText((Join-Path $strNestedGit 'index'), 'x')
        $objAfterInternals = Get-TreeEvidence -RootPath $strFixtureRoot -WorktreeClassification `
            -TrackedRelativePath $objEmptyTracked -AncestorBoundary $strFixtureRoot
        if ($strBoundaryDigest -cne [string]$objAfterInternals.Digest -or
            [int]$objAfterInternals.EntryCount -ne 1) {
            throw 'embedded-repository-fixture-failure'
        }

        # Adding a file directly under the nested root MUST NOT change the digest, because the
        # boundary is not traversed.
        [System.IO.File]::WriteAllText((Join-Path $strNested 'second.txt'), 'inner2')
        $objAfterInner = Get-TreeEvidence -RootPath $strFixtureRoot -WorktreeClassification `
            -TrackedRelativePath $objEmptyTracked -AncestorBoundary $strFixtureRoot
        if ($strBoundaryDigest -cne [string]$objAfterInner.Digest) {
            throw 'embedded-repository-fixture-failure'
        }

        # Removing the .git marker turns nested into an ordinary traversed directory, so its
        # files now appear as name-only entries and the digest changes.
        [System.IO.Directory]::Delete($strNestedGit, $true)
        $objAfterUnmarked = Get-TreeEvidence -RootPath $strFixtureRoot -WorktreeClassification `
            -TrackedRelativePath $objEmptyTracked -AncestorBoundary $strFixtureRoot
        if ($strBoundaryDigest -ceq [string]$objAfterUnmarked.Digest) {
            throw 'embedded-repository-fixture-failure'
        }
    } finally {
        if ([System.IO.Directory]::Exists($strFixtureRoot)) {
            [System.IO.Directory]::Delete($strFixtureRoot, $true)
        }
    }
}

function Test-AncestorBoundaryValidation {
    # .SYNOPSIS
    # Confirms the AncestorBoundary parameter stops the root-validation walk at a validated
    # ancestor and does not inspect a reparse ancestor above it.
    #
    # .DESCRIPTION
    # Creates a reparse-point directory without administrator rights (a junction on Windows, a
    # symbolic link on Unix) and checks three facts (G3): a fixture whose ancestor is the
    # reparse point is rejected with invalid-repository-root when no boundary is given (the
    # macOS /var and custom TMPDIR case); the same fixture is accepted when the boundary is the
    # fixture leaf, because the reparse ancestor is not inspected; and a reparse-point leaf is
    # still rejected even with a boundary, so the boundary does not disable leaf validation.
    #
    # .EXAMPLE
    # Test-AncestorBoundaryValidation
    #
    # # Produces no output when every fixture behaves as expected.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # None. Throws 'ancestor-boundary-fixture-failure' when a fixture behaves unexpectedly.
    # Filesystem and link-creation failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260818.1
    #
    # This function declares no parameters.
    param ()

    $strBase = [System.IO.Path]::Combine(
        [System.IO.Path]::GetTempPath(),
        ('exactgitpathset-boundary-' + [System.Guid]::NewGuid().ToString('N')))
    [void][System.IO.Directory]::CreateDirectory($strBase)
    $strAncestorLink = $null
    $strLeafLink = $null
    try {
        $strAncestorTarget = Join-Path $strBase 'ancestor-target'
        $strLeafTarget = Join-Path $strBase 'leaf-target'
        $strAncestorLink = Join-Path $strBase 'ancestor-link'
        $strLeafLink = Join-Path $strBase 'leaf-link'
        [void][System.IO.Directory]::CreateDirectory($strAncestorTarget)
        [void][System.IO.Directory]::CreateDirectory($strLeafTarget)
        # Create a reparse-point directory without administrator rights: a junction on Windows,
        # a symbolic link on Unix. PowerShell 6+ names the target -Target; 5.1 names it -Value.
        $boolModernPowerShell = $PSVersionTable.PSVersion.Major -ge 6
        $strLinkKind = if ($script:boolHostIsWindows) { 'Junction' } else { 'SymbolicLink' }
        foreach ($objLinkSpec in @(
                @{ Link = $strAncestorLink; Target = $strAncestorTarget },
                @{ Link = $strLeafLink; Target = $strLeafTarget })) {
            if ($boolModernPowerShell) {
                [void](New-Item -ItemType $strLinkKind -Path $objLinkSpec.Link `
                        -Target $objLinkSpec.Target -ErrorAction Stop)
            } else {
                [void](New-Item -ItemType $strLinkKind -Path $objLinkSpec.Link `
                        -Value $objLinkSpec.Target -ErrorAction Stop)
            }
        }
        $strLeafUnderReparse = Join-Path $strAncestorLink 'leaf'
        [void][System.IO.Directory]::CreateDirectory($strLeafUnderReparse)

        # Without a boundary the reparse ancestor is inspected and rejected.
        $boolRejectedWithoutBoundary = $false
        try {
            [void](Assert-OrdinaryRepositoryRoot -LiteralPath $strLeafUnderReparse)
        } catch {
            if ([string]$_.Exception.Message -ceq 'invalid-repository-root') {
                $boolRejectedWithoutBoundary = $true
            } else {
                throw
            }
        }
        if (-not $boolRejectedWithoutBoundary) {
            throw 'ancestor-boundary-fixture-failure'
        }

        # With the boundary at the leaf the reparse ancestor is not inspected, so a valid leaf
        # is accepted.
        $strValidated = [string](Assert-OrdinaryRepositoryRoot -LiteralPath $strLeafUnderReparse `
                -AncestorBoundary $strLeafUnderReparse)
        if ($strValidated.Length -eq 0) {
            throw 'ancestor-boundary-fixture-failure'
        }

        # A reparse-point leaf is still rejected even with a boundary: the boundary stops the
        # upward walk but still validates the leaf itself.
        $boolRejectedReparseLeaf = $false
        try {
            [void](Assert-OrdinaryRepositoryRoot -LiteralPath $strLeafLink `
                    -AncestorBoundary $strLeafLink)
        } catch {
            if ([string]$_.Exception.Message -ceq 'invalid-repository-root') {
                $boolRejectedReparseLeaf = $true
            } else {
                throw
            }
        }
        if (-not $boolRejectedReparseLeaf) {
            throw 'ancestor-boundary-fixture-failure'
        }
    } finally {
        # Remove the reparse points without following them, then the base tree.
        foreach ($strLinkToRemove in @($strAncestorLink, $strLeafLink)) {
            if (-not [string]::IsNullOrEmpty($strLinkToRemove) -and
                [System.IO.Directory]::Exists($strLinkToRemove)) {
                [System.IO.Directory]::Delete($strLinkToRemove, $false)
            }
        }
        if ([System.IO.Directory]::Exists($strBase)) {
            [System.IO.Directory]::Delete($strBase, $true)
        }
    }
}

function Test-PromisorRemoteActive {
    # .SYNOPSIS
    # Decides whether a promisor/partial-clone config query proves an active promisor remote.
    #
    # .DESCRIPTION
    # Parses the NUL-delimited key-newline-value records that
    # 'git config -z --get-regexp' returns for the promisor, partialclonefilter, and
    # extensions.partialClone keys. Collapses duplicate remote.<name>.promisor definitions to
    # each remote's effective last value, the way Git resolves a boolean (the last value wins).
    # Returns true for extensions.partialClone, for a remote whose effective promisor value is
    # not an explicit Git false, and for a valueless, empty, or malformed value (fail closed).
    # Treats a remote.<name>.partialclonefilter as inert.
    #
    # .PARAMETER PromisorRecordBytes
    # Raw stdout bytes of the promisor config query. A NUL separates records; a newline
    # separates each record's key from its value.
    #
    # .EXAMPLE
    # $boolActive = Test-PromisorRemoteActive -PromisorRecordBytes $hashtablePromisorResult.Stdout
    #
    # # Returns false for an ordinary clone whose only promisor value is an explicit false.
    #
    # .EXAMPLE
    # $boolActive = Test-PromisorRemoteActive -PromisorRecordBytes $arrDuplicateTrueThenFalse
    #
    # # Returns false when a later promisor=false supersedes an earlier promisor=true.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Boolean. True when an active promisor or partial-clone marker remains, false for
    # an ordinary repository. Strict UTF-8 decoding and allocation failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260818.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: PromisorRecordBytes
    param (
        [Parameter(Mandatory = $true)]
        [byte[]]$PromisorRecordBytes
    )

    $strPromisorText = $script:objUtf8Strict.GetString($PromisorRecordBytes)
    $objPromisorLastValue = New-Object 'System.Collections.Generic.Dictionary[string,string]' `
        ([System.StringComparer]::Ordinal)
    $listPromisorKeyOrder = New-Object 'System.Collections.Generic.List[string]'
    $boolExtensionsPartialClone = $false
    foreach ($strPromisorRecord in $strPromisorText.Split([char]0)) {
        if ($strPromisorRecord.Length -eq 0) {
            continue
        }
        $intNewlineIndex = $strPromisorRecord.IndexOf("`n")
        if ($intNewlineIndex -lt 0) {
            $strPromisorKey = $strPromisorRecord
            $strPromisorValue = ''
        } else {
            $strPromisorKey = $strPromisorRecord.Substring(0, $intNewlineIndex)
            $strPromisorValue = $strPromisorRecord.Substring($intNewlineIndex + 1)
        }
        if ($strPromisorKey -match '\.promisor$') {
            # Keep only each remote's last value; Git resolves a boolean config to the last
            # value, so an appended promisor=false supersedes an earlier promisor=true.
            if (-not $objPromisorLastValue.ContainsKey($strPromisorKey)) {
                [void]$listPromisorKeyOrder.Add($strPromisorKey)
            }
            $objPromisorLastValue[$strPromisorKey] = $strPromisorValue
        } elseif ($strPromisorKey -ceq 'extensions.partialclone') {
            # extensions.partialClone is an independent partial-clone marker; refuse on presence.
            $boolExtensionsPartialClone = $true
        }
        # Every other matched key (remote.<name>.partialclonefilter) is an inert filter.
    }
    if ($boolExtensionsPartialClone) {
        return $true
    }
    foreach ($strPromisorKey in $listPromisorKeyOrder) {
        # Fail closed on a valueless, empty, or malformed value; only an explicit Git false
        # (false/no/off/0) marks the remote's promisor as disabled.
        if ($objPromisorLastValue[$strPromisorKey].Trim().ToLowerInvariant() -notin @(
                'false', 'no', 'off', '0')) {
            return $true
        }
    }
    return $false
}

function Test-PromisorRemoteEvidence {
    # .SYNOPSIS
    # Exercises the promisor decision against duplicate-ordering and malformed fixtures.
    #
    # .DESCRIPTION
    # Confirms Test-PromisorRemoteActive collapses duplicate remote.<name>.promisor definitions
    # to the effective last value, honors an explicit false, refuses a truthy, valueless, or
    # malformed value, refuses extensions.partialClone, and treats a partialclonefilter as inert.
    #
    # .EXAMPLE
    # Test-PromisorRemoteEvidence
    #
    # # Produces no output when every promisor fixture returns its expected decision.
    #
    # .EXAMPLE
    # [void](Test-PromisorRemoteEvidence)
    #
    # # Re-runs the fixed promisor self-test and discards its intentionally empty output.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # None. Throws 'promisor-fixture-failure' when a fixture returns an unexpected decision.
    # Encoding and allocation failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260818.0
    #
    # This function declares no parameters.
    param ()

    $strNul = [string][char]0
    $strLf = [string][char]10
    $arrCase = @(
        @{ Active = $false; Text = 'remote.origin.promisor' + $strLf + 'false' + $strNul },
        @{ Active = $true; Text = 'remote.origin.promisor' + $strLf + 'true' + $strNul },
        @{ Active = $false; Text = 'remote.origin.promisor' + $strLf + 'true' + $strNul +
            'remote.origin.promisor' + $strLf + 'false' + $strNul },
        @{ Active = $true; Text = 'remote.origin.promisor' + $strLf + 'false' + $strNul +
            'remote.origin.promisor' + $strLf + 'true' + $strNul },
        @{ Active = $true; Text = 'remote.origin.promisor' + $strLf + 'maybe' + $strNul },
        @{ Active = $true; Text = 'remote.origin.promisor' + $strNul },
        @{ Active = $true; Text = 'extensions.partialclone' + $strLf + 'origin' + $strNul },
        @{ Active = $false; Text = 'remote.origin.partialclonefilter' + $strLf + 'blob:none' + $strNul },
        @{ Active = $false; Text = 'remote.origin.partialclonefilter' + $strLf + 'blob:none' + $strNul +
            'remote.origin.promisor' + $strLf + 'false' + $strNul },
        @{ Active = $true; Text = 'remote.a.promisor' + $strLf + 'false' + $strNul +
            'remote.b.promisor' + $strLf + 'true' + $strNul }
    )
    foreach ($hashtableCase in $arrCase) {
        $arrBytes = $script:objUtf8Strict.GetBytes([string]$hashtableCase.Text)
        $boolActive = Test-PromisorRemoteActive -PromisorRecordBytes $arrBytes
        if ($boolActive -ne [bool]$hashtableCase.Active) {
            throw 'promisor-fixture-failure'
        }
    }
}

function Test-TrackedOnlyWorktreeEvidence {
    # .SYNOPSIS
    # Confirms tracked/control-only worktree evidence ignores untracked churn while tracked
    # and control changes stay evidence-relevant.
    #
    # .DESCRIPTION
    # Builds a temporary tree and checks Get-TreeEvidence under worktree classification. With
    # OmitUntrackedEvidence set, an added untracked file does not change the worktree digest,
    # while a tracked-file edit and an added untracked .gitattributes both change it. Without the
    # switch, the same untracked file does change the digest, so Working/Both behavior is intact.
    #
    # .EXAMPLE
    # Test-TrackedOnlyWorktreeEvidence
    #
    # # Produces no output when every fixture behaves as expected.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # None. Throws 'tracked-only-worktree-fixture-failure' when a fixture behaves unexpectedly.
    # Filesystem and hashing failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260818.0
    #
    # This function declares no parameters.
    param ()

    $strFixtureRoot = [System.IO.Path]::Combine(
        [System.IO.Path]::GetTempPath(),
        ('exactgitpathset-h2-' + [System.Guid]::NewGuid().ToString('N')))
    $objTracked = New-Object 'System.Collections.Generic.HashSet[string]' `
        ([System.StringComparer]::Ordinal)
    [void]$objTracked.Add('tracked.txt')
    [void][System.IO.Directory]::CreateDirectory($strFixtureRoot)
    try {
        $strTrackedFile = Join-Path $strFixtureRoot 'tracked.txt'
        $strUntrackedFile = Join-Path $strFixtureRoot 'untracked.tmp'
        $strAttributesFile = Join-Path $strFixtureRoot '.gitattributes'
        [System.IO.File]::WriteAllText($strTrackedFile, 'tracked-v1')

        # Tracked-only baseline: one tracked file, no untracked entry.
        $strOmitBaseline = [string](Get-TreeEvidence -RootPath $strFixtureRoot `
                -WorktreeClassification -TrackedRelativePath $objTracked `
                -OmitUntrackedEvidence -AncestorBoundary $strFixtureRoot).Digest

        # Add an untracked file. Tracked-only evidence MUST ignore untracked population.
        [System.IO.File]::WriteAllText($strUntrackedFile, 'noise')
        $strOmitWithUntracked = [string](Get-TreeEvidence -RootPath $strFixtureRoot `
                -WorktreeClassification -TrackedRelativePath $objTracked `
                -OmitUntrackedEvidence -AncestorBoundary $strFixtureRoot).Digest
        if ($strOmitBaseline -cne $strOmitWithUntracked) {
            throw 'tracked-only-worktree-fixture-failure'
        }

        # The default worktree mode records the untracked file, so removing it MUST change the
        # digest. This proves Working/Both untracked semantics are unchanged.
        $strDefaultWithUntracked = [string](Get-TreeEvidence -RootPath $strFixtureRoot `
                -WorktreeClassification -TrackedRelativePath $objTracked `
                -AncestorBoundary $strFixtureRoot).Digest
        [System.IO.File]::Delete($strUntrackedFile)
        $strDefaultNoUntracked = [string](Get-TreeEvidence -RootPath $strFixtureRoot `
                -WorktreeClassification -TrackedRelativePath $objTracked `
                -AncestorBoundary $strFixtureRoot).Digest
        if ($strDefaultWithUntracked -ceq $strDefaultNoUntracked) {
            throw 'tracked-only-worktree-fixture-failure'
        }

        # A tracked-file edit stays evidence-relevant in tracked-only mode.
        [System.IO.File]::WriteAllText($strTrackedFile, 'tracked-v2-longer')
        $strOmitTrackedChanged = [string](Get-TreeEvidence -RootPath $strFixtureRoot `
                -WorktreeClassification -TrackedRelativePath $objTracked `
                -OmitUntrackedEvidence -AncestorBoundary $strFixtureRoot).Digest
        if ($strOmitBaseline -ceq $strOmitTrackedChanged) {
            throw 'tracked-only-worktree-fixture-failure'
        }

        # An untracked control file (.gitattributes) stays evidence-relevant in tracked-only
        # mode. Restore the tracked file first so the control file is the only difference.
        [System.IO.File]::WriteAllText($strTrackedFile, 'tracked-v1')
        $strOmitControlBefore = [string](Get-TreeEvidence -RootPath $strFixtureRoot `
                -WorktreeClassification -TrackedRelativePath $objTracked `
                -OmitUntrackedEvidence -AncestorBoundary $strFixtureRoot).Digest
        [System.IO.File]::WriteAllText($strAttributesFile, '* text=auto')
        $strOmitControlAfter = [string](Get-TreeEvidence -RootPath $strFixtureRoot `
                -WorktreeClassification -TrackedRelativePath $objTracked `
                -OmitUntrackedEvidence -AncestorBoundary $strFixtureRoot).Digest
        if ($strOmitControlBefore -ceq $strOmitControlAfter) {
            throw 'tracked-only-worktree-fixture-failure'
        }
    } finally {
        if ([System.IO.Directory]::Exists($strFixtureRoot)) {
            [System.IO.Directory]::Delete($strFixtureRoot, $true)
        }
    }
}

function Test-NativeExitResetInvariant {
    # .SYNOPSIS
    # Confirms every main-body native-command site clears its exit before the guarded call.
    #
    # .DESCRIPTION
    # Reads the verifier's own source text and checks the in-flight native-command diagnostic
    # invariant at every main-body command site. After each native-command-name assignment, the
    # first following native-exit assignment must clear the exit to null, so a native call that
    # throws before it returns leaves the reported exit null instead of the prior command's exit.
    # The command-site search text is built from fragments so this self-test does not match its
    # own source.
    #
    # .EXAMPLE
    # Test-NativeExitResetInvariant
    #
    # # Produces no output when every native-command site clears the exit before its call.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # None. Throws 'native-exit-invariant-fixture-failure' when a site does not clear the exit
    # before its call, or when no sites are found. Filesystem failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260818.0
    #
    # This function declares no parameters.
    param ()

    $strSelfPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'Test-ExactGitPathSet.ps1'))
    $strSelfText = $script:objUtf8Strict.GetString([System.IO.File]::ReadAllBytes($strSelfPath))
    $strCommandNeedle = '$' + 'strNativeCommand = ' + [char]39
    $strExitNeedle = '$' + 'intNativeExit ='
    $strResetNeedle = '$' + 'intNativeExit = ' + '$' + 'null'
    $intSiteCount = 0
    $intSearchFrom = 0
    while ($true) {
        $intCommandIndex = $strSelfText.IndexOf(
            $strCommandNeedle, $intSearchFrom, [System.StringComparison]::Ordinal)
        if ($intCommandIndex -lt 0) {
            break
        }
        $intSiteCount++
        $intExitIndex = $strSelfText.IndexOf(
            $strExitNeedle, $intCommandIndex, [System.StringComparison]::Ordinal)
        if ($intExitIndex -lt 0 -or -not $strSelfText.Substring($intExitIndex).StartsWith(
                $strResetNeedle, [System.StringComparison]::Ordinal)) {
            throw 'native-exit-invariant-fixture-failure'
        }
        $intSearchFrom = $intCommandIndex + $strCommandNeedle.Length
    }
    if ($intSiteCount -lt 10) {
        throw 'native-exit-invariant-fixture-failure'
    }
}

function Test-TrackedOnlyEntryCeiling {
    # .SYNOPSIS
    # Confirms the entry ceiling (H4) exempts the untracked entries OmitUntrackedEvidence omits,
    # yet still counts a traversed directory (the F4 empty-directory bound).
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - not part of the public API surface.
    #
    # Version: 1.0.20260818.0
    param ()

    $strRoot = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(),
        ('exactgitpathset-h4-' + [System.Guid]::NewGuid().ToString('N')))
    $objTracked = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
    [void]$objTracked.Add('t')
    [void][System.IO.Directory]::CreateDirectory($strRoot)
    try {
        [System.IO.File]::WriteAllText((Join-Path $strRoot 't'), 'v1')
        $strBase = [string](Get-TreeEvidence -RootPath $strRoot -WorktreeClassification `
                -TrackedRelativePath $objTracked -OmitUntrackedEvidence -MaximumEntryCount 4 `
                -AncestorBoundary $strRoot).Digest
        for ($i = 0; $i -lt 40; $i++) { [System.IO.File]::WriteAllText((Join-Path $strRoot "u$i"), 'x') }
        # H4: untracked population above the ceiling is neither counted (no throw) nor recorded
        # (digest unchanged) in tracked/control-only mode.
        $strOmit = [string](Get-TreeEvidence -RootPath $strRoot -WorktreeClassification `
                -TrackedRelativePath $objTracked -OmitUntrackedEvidence -MaximumEntryCount 4 `
                -AncestorBoundary $strRoot).Digest
        if ($strBase -cne $strOmit) { throw 'tracked-only-entry-ceiling-fixture-failure' }
        for ($i = 0; $i -lt 40; $i++) { [void][System.IO.Directory]::CreateDirectory((Join-Path $strRoot "d$i")) }
        # F4: a traversed directory always counts, so empty directories above the ceiling throw.
        $boolThrew = $false
        try {
            [void](Get-TreeEvidence -RootPath $strRoot -WorktreeClassification -TrackedRelativePath `
                    $objTracked -OmitUntrackedEvidence -MaximumEntryCount 4 -LimitCategory 'h4-ceiling' `
                    -AncestorBoundary $strRoot)
        } catch {
            if ([string]$_.Exception.Message -cne 'h4-ceiling') { throw }
            $boolThrew = $true
        }
        if (-not $boolThrew) { throw 'tracked-only-entry-ceiling-fixture-failure' }
    } finally {
        if ([System.IO.Directory]::Exists($strRoot)) { [System.IO.Directory]::Delete($strRoot, $true) }
    }
}

function Test-EffectiveConfigNativeExitReset {
    # .SYNOPSIS
    # Confirms Get-EffectiveConfigComponent sets the script-scoped diagnostic fields before its
    # native call (H5), so a throw before the call returns reports effective-config and a null exit.
    #
    # .OUTPUTS
    # None. Throws 'effective-config-diagnostic-fixture-failure' when the fields are not set first.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - not part of the public API surface.
    #
    # Version: 1.0.20260818.0
    param ()

    $strSaved = $script:strNativeCommand
    $intSaved = $script:intNativeExit
    $strConfig = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(),
        ('exactgitpathset-h5-' + [System.Guid]::NewGuid().ToString('N')))
    try {
        [System.IO.File]::WriteAllText($strConfig, "[core]`n`tbare = false`n")
        $objChecks = New-Object 'System.Collections.Generic.List[object]'
        # Simulate a stale prior main-body command, so a missing reset would stay observable, then
        # force Invoke-GitRaw to throw with a GitRecord whose executable path does not exist.
        $script:strNativeCommand = 'sentinel-prior'
        $script:intNativeExit = 4242
        $boolThrew = $false
        try {
            [void](Get-EffectiveConfigComponent -LiteralPath $strConfig `
                    -GitRecord ([ordered]@{ Path = ($strConfig + '.missing'); Length = 0L; Sha256 = '' }) `
                    -WorkingDirectory ([System.IO.Path]::GetTempPath()) -NativeCommandList $objChecks)
        } catch { $boolThrew = $true }
        if (-not $boolThrew -or $script:strNativeCommand -cne 'effective-config' -or
            $null -ne $script:intNativeExit) {
            throw 'effective-config-diagnostic-fixture-failure'
        }
    } finally {
        $script:strNativeCommand = $strSaved
        $script:intNativeExit = $intSaved
        if ([System.IO.File]::Exists($strConfig)) { [System.IO.File]::Delete($strConfig) }
    }
}

function Get-BoundedFileDigest {
    # .SYNOPSIS
    # Gets the SHA-256 digest and exact byte length of one ordinary file, enforcing a
    # byte ceiling during the read.
    #
    # .DESCRIPTION
    # Opens the literal file for shared reading and hashes it incrementally in fixed
    # 64 KiB chunks. Stops and throws the caller's limit category as soon as the bytes
    # read exceed the maximum, so a file that grows after its length was sampled -- or
    # while it is being read -- cannot be read or hashed without bound. The digest is
    # byte-identical to a single ComputeHash over the same content.
    #
    # .PARAMETER LiteralPath
    # Absolute literal file path to hash. Wildcards are not expanded.
    #
    # .PARAMETER MaximumBytes
    # Inclusive upper bound on the bytes read. Reading past it throws LimitCategory.
    #
    # .PARAMETER LimitCategory
    # Error string thrown when the file's content exceeds MaximumBytes.
    #
    # .EXAMPLE
    # $hashtable = Get-BoundedFileDigest -LiteralPath $strPath -MaximumBytes 4194304 -LimitCategory 'git-control-limit'
    #
    # # Returns Digest and ByteCount, or throws 'git-control-limit' above 4 MiB.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Collections.Specialized.OrderedDictionary with Digest (lowercase SHA-256)
    # and ByteCount (Int64). Throws LimitCategory when the content exceeds
    # MaximumBytes; file, stream, allocation, hashing, and parameter-binding failures
    # propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260814.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: LiteralPath
    #   Position 1: MaximumBytes
    #   Position 2: LimitCategory
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [long]$MaximumBytes,

        [Parameter(Mandatory = $true)]
        [string]$LimitCategory
    )

    $objStream = New-Object System.IO.FileStream(
        $LiteralPath,
        [System.IO.FileMode]::Open,
        [System.IO.FileAccess]::Read,
        [System.IO.FileShare]::Read
    )
    $objSha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        $intChunkSize = 65536
        $arrChunk = New-Object byte[] $intChunkSize
        $longRead = 0
        while ($true) {
            $intReadCount = $objStream.Read($arrChunk, 0, $intChunkSize)
            if ($intReadCount -le 0) {
                break
            }
            $longRead += $intReadCount
            if ($longRead -gt $MaximumBytes) {
                throw $LimitCategory
            }
            [void]$objSha256.TransformBlock($arrChunk, 0, $intReadCount, $null, 0)
        }
        [void]$objSha256.TransformFinalBlock((New-Object byte[] 0), 0, 0)
        return [ordered]@{
            Digest = ([System.BitConverter]::ToString($objSha256.Hash)).Replace('-', '').ToLowerInvariant()
            ByteCount = $longRead
        }
    } finally {
        $objSha256.Dispose()
        $objStream.Dispose()
    }
}

function Read-BoundedFileContent {
    # .SYNOPSIS
    # Reads at most a bounded number of bytes from one ordinary file.
    #
    # .DESCRIPTION
    # Opens the literal file for shared reading and reads up to MaximumBytes bytes into
    # a MaximumBytes+1 buffer. Throws the caller's limit category when the file holds
    # more than MaximumBytes, without allocating or reading the whole file first, so a
    # hostile or corrupted marker cannot force an unbounded allocation before a
    # post-read size check.
    #
    # .PARAMETER LiteralPath
    # Absolute literal file path to read. Wildcards are not expanded.
    #
    # .PARAMETER MaximumBytes
    # Inclusive upper bound on the bytes returned. A larger file throws LimitCategory.
    #
    # .PARAMETER LimitCategory
    # Error string thrown when the file holds more than MaximumBytes.
    #
    # .EXAMPLE
    # $arrBytes = Read-BoundedFileContent -LiteralPath $strMarker -MaximumBytes 4096 -LimitCategory 'invalid-git-control'
    #
    # # Returns up to 4096 bytes, or throws 'invalid-git-control' for a larger file.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Byte[]. The file content, at most MaximumBytes long. Throws LimitCategory
    # above MaximumBytes; file, stream, allocation, and parameter-binding failures
    # propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260814.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: LiteralPath
    #   Position 1: MaximumBytes
    #   Position 2: LimitCategory
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [int]$MaximumBytes,

        [Parameter(Mandatory = $true)]
        [string]$LimitCategory
    )

    $objStream = New-Object System.IO.FileStream(
        $LiteralPath,
        [System.IO.FileMode]::Open,
        [System.IO.FileAccess]::Read,
        [System.IO.FileShare]::Read
    )
    try {
        $arrBuffer = New-Object byte[] ($MaximumBytes + 1)
        $intTotal = 0
        while ($intTotal -lt $arrBuffer.Length) {
            $intReadCount = $objStream.Read($arrBuffer, $intTotal, $arrBuffer.Length - $intTotal)
            if ($intReadCount -le 0) {
                break
            }
            $intTotal += $intReadCount
        }
        if ($intTotal -gt $MaximumBytes) {
            throw $LimitCategory
        }
        $arrResult = New-Object byte[] $intTotal
        [System.Array]::Copy($arrBuffer, 0, $arrResult, 0, $intTotal)
        return ,$arrResult
    } finally {
        $objStream.Dispose()
    }
}

function Assert-OrdinaryTreeUnder {
    # .SYNOPSIS
    # Rejects any non-ordinary entry -- a reparse point or a non-regular Unix file --
    # anywhere below one directory.
    #
    # .DESCRIPTION
    # Walks the tree under RootPath without following links: every entry is tested for
    # the reparse-point attribute before a directory is descended, so a link is never
    # traversed. By default a non-directory, non-reparse entry that is a Unix FIFO, socket,
    # or device (which Git would open and block on) is also rejected through the UnixMode
    # string, and a non-Windows host that cannot report the type fails closed. With
    # -AllowUnixSpecialFile the walk still refuses a reparse point and still enforces the
    # runaway backstop, but permits a Unix special file, because the caller relies on the
    # Invoke-GitRaw native-command timeout (or a zlib-inflate failure) to fail closed on such
    # a file only when a read actually opens it. Throws the caller's limit category on the
    # first offending entry, and on an anomalously large tree (a runaway backstop). RootPath
    # itself is not tested; the caller tests the root before calling.
    #
    # .PARAMETER RootPath
    # Absolute directory whose descendants must all be ordinary files or directories.
    #
    # .PARAMETER LimitCategory
    # Error string thrown for a reparse point, a special Unix entry, an unreadable
    # type on a non-Windows host, or the scan backstop.
    #
    # .PARAMETER AllowUnixSpecialFile
    # When set, do not reject a Unix FIFO, socket, or device below RootPath, and do not fail
    # closed on a non-Windows host that cannot report the entry type. The reparse-point and
    # runaway-backstop refusals stay unconditional. The object-store guard passes this,
    # because a special-file object harms a read only when the read opens it, and that read
    # fails closed through native-command-timeout or a native-command inflate failure.
    #
    # .EXAMPLE
    # Assert-OrdinaryTreeUnder -RootPath $strObjectsPath -LimitCategory 'git-object-store-nonordinary'
    #
    # # Returns nothing when the tree is ordinary; throws otherwise.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # None. Throws LimitCategory for a non-ordinary entry below RootPath or an
    # over-limit scan. Enumeration, metadata, access, and parameter-binding failures
    # propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260817.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: RootPath
    #   Position 1: LimitCategory
    param (
        [Parameter(Mandatory = $true)]
        [string]$RootPath,

        [Parameter(Mandatory = $true)]
        [string]$LimitCategory,

        [switch]$AllowUnixSpecialFile
    )

    $objPending = New-Object System.Collections.Stack
    $objPending.Push($RootPath)
    $longScanned = 0
    while ($objPending.Count -gt 0) {
        $strDirectory = [string]$objPending.Pop()
        foreach ($strEntry in [System.IO.Directory]::EnumerateFileSystemEntries($strDirectory)) {
            $longScanned++
            if ($longScanned -gt 5000000) {
                throw $LimitCategory
            }
            $objAttributes = [System.IO.File]::GetAttributes($strEntry)
            if (($objAttributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw $LimitCategory
            }
            if (($objAttributes -band [System.IO.FileAttributes]::Directory) -ne 0) {
                $objPending.Push([string]$strEntry)
            } elseif (-not $AllowUnixSpecialFile) {
                $objEntryInfo = New-Object System.IO.FileInfo($strEntry)
                $objUnixModeProperty = $objEntryInfo.PSObject.Properties['UnixMode']
                if ($null -ne $objUnixModeProperty) {
                    $strUnixMode = [string]$objUnixModeProperty.Value
                    if ($strUnixMode.Length -gt 0 -and ($strUnixMode[0] -eq 'p' -or
                        $strUnixMode[0] -eq 's' -or $strUnixMode[0] -eq 'b' -or
                        $strUnixMode[0] -eq 'c')) {
                        throw $LimitCategory
                    }
                } elseif (-not $script:boolHostIsWindows) {
                    throw $LimitCategory
                }
            }
        }
    }
}

function Assert-UnoccupiedControlSlot {
    # .SYNOPSIS
    # Confirms a Git control-surface slot is genuinely absent, not occupied by a
    # dangling symlink or other non-resolving entry.
    #
    # .DESCRIPTION
    # [System.IO.File]::Exists and [System.IO.Directory]::Exists both follow
    # symlinks, so a dangling symlink -- a reparse point whose target is absent --
    # reports false from both and would be recorded as 'absent'. A concurrent writer
    # can then expose the link's target for a path-set read (for example the
    # untracked read of info/exclude) and hide it for the control sample, yielding
    # stable evidence for an incorrectly classified control input. The occupying link
    # can be the leaf itself or an ancestor directory of the slot (for example
    # .git/info), whose own File.Exists and Directory.Exists both report false too.
    # Callers invoke this only after File.Exists and Directory.Exists have both
    # returned false. It walks up to the nearest ancestor that genuinely exists as a
    # directory -- readdir lists a dangling symlink regardless of its target -- and if
    # the first non-resolving component below that directory is present as an entry, it
    # fails closed with the caller's category, because the chain is occupied by a
    # non-resolving reparse point or special file rather than being absent. A truly
    # absent slot (the component is missing from an existing ancestor directory, or no
    # ancestor exists) returns without throwing.
    #
    # .PARAMETER LiteralPath
    # Absolute control-slot path whose File and Directory existence both returned
    # false.
    #
    # .PARAMETER Category
    # Fail-closed category to throw when an occupying entry is found.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # None. Throws Category when the slot is occupied by a dangling symlink or other
    # non-resolving entry, or 'git-control-limit' when the bounded ancestor scan
    # exceeds its entry ceiling. Path and access failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260814.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: LiteralPath
    #   Position 1: Category
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [string]$Category
    )

    # Walk up to the nearest ancestor that genuinely exists as a directory. The
    # first path component below it that does not resolve must be missing from that
    # directory's entries for the slot to be truly absent; if it is present instead,
    # it is a dangling symlink (or other non-resolving reparse point / special file)
    # occupying the chain -- at the leaf, or at an ancestor such as .git/info itself,
    # whose own File.Exists and Directory.Exists both report false -- so fail closed.
    # readdir (EnumerateFileSystemEntries) lists such an entry regardless of whether
    # its target resolves. The walk terminates at the validated Git directory, which
    # exists, or at the filesystem root.
    $longScanned = 0
    $strCurrent = $LiteralPath
    while ($true) {
        $strParent = [System.IO.Path]::GetDirectoryName($strCurrent)
        if ([string]::IsNullOrEmpty($strParent)) {
            return
        }
        if ([System.IO.Directory]::Exists($strParent)) {
            $strLeaf = [System.IO.Path]::GetFileName($strCurrent)
            foreach ($strEntry in [System.IO.Directory]::EnumerateFileSystemEntries($strParent)) {
                # Bound the scan: a genuinely absent leaf under an ancestor holding a
                # hostile or accidental number of entries would otherwise traverse the
                # whole directory. Fail closed with git-control-limit past the same
                # ceiling Assert-OrdinaryTreeUnder uses, rather than stall. The counter
                # is cumulative across the ancestor walk.
                $longScanned++
                if ($longScanned -gt 5000000) {
                    throw 'git-control-limit'
                }
                if ([string]::Equals([System.IO.Path]::GetFileName($strEntry), $strLeaf, $script:objPathComparison)) {
                    throw $Category
                }
            }
            return
        }
        $strCurrent = $strParent
    }
}

function Assert-OrdinaryAbsoluteFile {
    # .SYNOPSIS
    # Resolves one absolute ordinary file and every directory ancestor.
    #
    # .DESCRIPTION
    # Rejects relative or control-bearing path text. Normalizes the path and
    # requires the file and all ancestors to exist without a reparse-point flag.
    #
    # .PARAMETER LiteralPath
    # Absolute literal file path to normalize and validate.
    #
    # .EXAMPLE
    # $strGitPath = Assert-OrdinaryAbsoluteFile -LiteralPath $strCandidate
    #
    # # Returns the normalized path for one ordinary executable file.
    #
    # .EXAMPLE
    # Assert-OrdinaryAbsoluteFile -LiteralPath '.\git'
    #
    # # Throws 'invalid-ordinary-file' because the path is not absolute.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String. The normalized ordinary file path. Throws
    # 'invalid-ordinary-file' for an invalid, missing, directory, reparse, or
    # non-regular (Unix FIFO/socket/device) entry. Path, metadata, access, and
    # parameter-binding failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260814.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: LiteralPath
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath
    )

    if (-not [System.IO.Path]::IsPathRooted($LiteralPath)) {
        throw 'invalid-ordinary-file'
    }
    foreach ($chrCharacter in $LiteralPath.ToCharArray()) {
        if ([char]::IsControl($chrCharacter)) {
            throw 'invalid-ordinary-file'
        }
    }
    $strFullPath = [System.IO.Path]::GetFullPath($LiteralPath)
    $objFile = New-Object System.IO.FileInfo($strFullPath)
    if (-not $objFile.Exists -or
        ($objFile.Attributes -band [System.IO.FileAttributes]::Directory) -ne 0 -or
        ($objFile.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw 'invalid-ordinary-file'
    }
    # On Unix a path that is neither a directory nor a reparse point can still be a
    # FIFO, socket, or block/character device, which File attributes do not
    # distinguish from a regular file. A caller then opens it -- Get-GitExecutableRecord
    # hashes the Git executable, and the control-surface passes readable control files
    # such as .git and commondir through this guard before hashing -- and opening a
    # FIFO blocks indefinitely instead of failing closed. PowerShell's UnixMode string
    # exposes the type in its first character; reject the explicit special types before
    # any read. On Windows there are no such entries and the property is absent, so the
    # check is a no-op there ('-' and 'd' never fire). On a non-Windows host that does
    # not expose UnixMode (for example PowerShell 7.0, before the property was added),
    # the entry's type cannot be read at all, so fail closed rather than pass a
    # potentially blocking special file.
    $objUnixModeProperty = $objFile.PSObject.Properties['UnixMode']
    if ($null -ne $objUnixModeProperty) {
        $strUnixMode = [string]$objUnixModeProperty.Value
        if ($strUnixMode.Length -gt 0 -and ($strUnixMode[0] -eq 'p' -or
            $strUnixMode[0] -eq 's' -or $strUnixMode[0] -eq 'b' -or
            $strUnixMode[0] -eq 'c')) {
            throw 'invalid-ordinary-file'
        }
    } elseif (-not $script:boolHostIsWindows) {
        throw 'invalid-ordinary-file'
    }
    $objDirectory = $objFile.Directory
    while ($null -ne $objDirectory) {
        if (-not $objDirectory.Exists -or
            ($objDirectory.Attributes -band [System.IO.FileAttributes]::Directory) -eq 0 -or
            ($objDirectory.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw 'invalid-ordinary-file'
        }
        $objDirectory = $objDirectory.Parent
    }
    return $strFullPath
}

function Get-GitExecutableRecord {
    # .SYNOPSIS
    # Resolves and fixes the Git executable identity for one verifier run.
    #
    # .DESCRIPTION
    # Uses the caller's exact path or the module-qualified application resolver.
    # Requires one ordinary file and records its normalized path, byte length,
    # and SHA-256 digest for revalidation before every child process starts.
    #
    # .PARAMETER RequestedPath
    # Optional exact Git executable path. Null or empty text selects resolution.
    #
    # .EXAMPLE
    # $hashtableGit = Get-GitExecutableRecord -RequestedPath $null
    #
    # # Returns the fixed identity of the first resolved Git application.
    #
    # .EXAMPLE
    # $hashtableGit = Get-GitExecutableRecord -RequestedPath 'C:\Program Files\Git\cmd\git.exe'
    #
    # # Returns the fixed identity when the exact path is an ordinary file.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Collections.Specialized.OrderedDictionary. Contains Path, Length,
    # and Sha256. Throws 'git-executable-resolution' or a file-validation
    # failure. Resolver, hashing, allocation, and parameter-binding failures
    # propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260814.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: RequestedPath
    param (
        [AllowNull()]
        [string]$RequestedPath
    )

    if ([string]::IsNullOrEmpty($RequestedPath)) {
        $arrGitCommands = @(Microsoft.PowerShell.Core\Get-Command `
            -Name git `
            -CommandType Application `
            -ErrorAction Stop)
        if ($arrGitCommands.Count -eq 0) {
            throw 'git-executable-resolution'
        }
        $strCandidatePath = [string]$arrGitCommands[0].Source
    } else {
        $strCandidatePath = $RequestedPath
    }
    $strGitPath = Assert-OrdinaryAbsoluteFile -LiteralPath $strCandidatePath
    return [ordered]@{
        Path = $strGitPath
        Length = (New-Object System.IO.FileInfo($strGitPath)).Length
        Sha256 = (Get-BoundedFileDigest -LiteralPath $strGitPath `
            -MaximumBytes $script:longGitExecutableMaximumBytes -LimitCategory 'git-executable-limit').Digest
    }
}

function ConvertTo-NativeArgumentString {
    # .SYNOPSIS
    # Encodes native arguments as one Windows-compatible command-line string.
    #
    # .DESCRIPTION
    # Applies the CommandLineToArgvW-compatible quoting and backslash rules used
    # when ProcessStartInfo.ArgumentList is unavailable, then joins the encoded
    # arguments with single spaces.
    #
    # .PARAMETER ArgumentList
    # Ordered native argument values to encode without changing their content.
    #
    # .EXAMPLE
    # $strArguments = ConvertTo-NativeArgumentString -ArgumentList @('diff', '--name-only')
    #
    # # Returns 'diff --name-only'.
    #
    # .EXAMPLE
    # $strArguments = ConvertTo-NativeArgumentString -ArgumentList @('a b', '')
    #
    # # Returns a quoted command line that preserves the space and empty argument.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String. One encoded native command-line string. Empty collections
    # are rejected during parameter binding; allocation and other binding
    # failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: ArgumentList
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$ArgumentList
    )

    $listQuoted = New-Object 'System.Collections.Generic.List[string]'
    foreach ($strArgument in $ArgumentList) {
        if ($strArgument.Length -eq 0) {
            $listQuoted.Add('""')
            continue
        }
        if ($strArgument -notmatch '[\x20\x09"]') {
            $listQuoted.Add($strArgument)
            continue
        }

        $objBuilder = New-Object System.Text.StringBuilder
        [void]$objBuilder.Append('"')
        $intBackslashes = 0
        foreach ($chrCharacter in $strArgument.ToCharArray()) {
            if ($chrCharacter -eq '\') {
                $intBackslashes++
                continue
            }
            if ($chrCharacter -eq '"') {
                [void]$objBuilder.Append(('\' * (($intBackslashes * 2) + 1)))
                [void]$objBuilder.Append('"')
                $intBackslashes = 0
                continue
            }
            if ($intBackslashes -gt 0) {
                [void]$objBuilder.Append(('\' * $intBackslashes))
                $intBackslashes = 0
            }
            [void]$objBuilder.Append($chrCharacter)
        }
        if ($intBackslashes -gt 0) {
            [void]$objBuilder.Append(('\' * ($intBackslashes * 2)))
        }
        [void]$objBuilder.Append('"')
        $listQuoted.Add($objBuilder.ToString())
    }
    return $listQuoted.ToArray() -join ' '
}

function Stop-NativeProcessTree {
    # .SYNOPSIS
    # Terminates a native child process and its descendants on every supported host.
    #
    # .DESCRIPTION
    # Kills the process and its child tree, falling back to a single-process kill on a
    # host that lacks the tree-kill overload. Process.Kill([bool] entireProcessTree) is
    # .NET Core 3.0+ only; the supported Windows PowerShell 5.1 (.NET Framework) host does
    # not expose it, so calling Kill($true) there would raise a MethodException. Probe for
    # the overload and fall back to the parameterless Kill(), which every supported runtime
    # exposes, so a bound is always enforced. A kill failure -- the child already exited, or
    # a race -- is swallowed: termination is best-effort and the caller fails closed anyway.
    #
    # .PARAMETER Process
    # Started native process whose tree must be terminated.
    #
    # .EXAMPLE
    # Stop-NativeProcessTree -Process $objProcess
    #
    # # Terminates the process tree, or the single process on a host without the overload.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # None. Kill failures are swallowed; parameter-binding failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260816.3
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: Process
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'Private best-effort terminator on a fail-closed cleanup path (output-limit or timeout); -WhatIf/-Confirm must never skip or prompt a resource-bound kill, so ShouldProcess does not apply.'
    )]
    param (
        [Parameter(Mandatory = $true)]
        [System.Diagnostics.Process]$Process
    )

    if ($null -ne $Process.GetType().GetMethod('Kill', [type[]]@([bool]))) {
        try { $Process.Kill($true) } catch { $null = $_ }
    } else {
        try { $Process.Kill() } catch { $null = $_ }
    }
}

function Invoke-GitRaw {
    # .SYNOPSIS
    # Invokes Git and captures its standard streams as raw bytes.
    #
    # .DESCRIPTION
    # Revalidates the fixed Git executable and starts it without a shell. Builds
    # a child environment that removes every inherited GIT_* variable and sets
    # fixed noninteractive configuration controls. Supplies arguments through
    # ArgumentList when available or compatible quoting otherwise. Closes input,
    # drains both output streams concurrently, and limits each stream to 4 MiB.
    # Bounds the whole drain-and-exit wait by TimeoutMilliseconds, so a command
    # that neither writes nor exits cannot hang the verifier: the child tree is
    # terminated and 'native-command-timeout' is thrown.
    #
    # .PARAMETER GitRecord
    # Fixed Git executable record with Path, Length, and Sha256 evidence.
    #
    # .PARAMETER WorkingDirectory
    # Existing working directory assigned to the native process.
    #
    # .PARAMETER ArgumentList
    # Ordered Git arguments passed without shell interpretation.
    #
    # .PARAMETER TimeoutMilliseconds
    # Wall-clock ceiling for the drain-and-exit wait. Defaults to the script native-command
    # timeout. On expiry the child tree is terminated and 'native-command-timeout' is thrown.
    #
    # .EXAMPLE
    # $hashtableResult = Invoke-GitRaw -GitRecord $hashtableGit -WorkingDirectory $strRoot -ArgumentList @('status', '--porcelain=v1', '-z')
    #
    # # Returns ExitCode, raw Stdout bytes, and StderrLength.
    #
    # .EXAMPLE
    # $strLargeBlobId = '<Git blob object ID larger than 4 MiB>'
    # Invoke-GitRaw -GitRecord $hashtableGit -WorkingDirectory $strRoot -ArgumentList @('cat-file', 'blob', $strLargeBlobId)
    #
    # # Schematic: with a blob larger than 4 MiB, throws 'native-output-limit'.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Collections.Specialized.OrderedDictionary. Contains System.Int32
    # ExitCode, System.Byte[] Stdout, and System.Int32 StderrLength. Throws
    # 'native-command' when Process.Start returns false, 'native-output-limit'
    # for oversized output, and 'native-command-timeout' when the drain-and-exit
    # wait exceeds TimeoutMilliseconds; parameter-binding, process, task, and I/O
    # failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260816.3
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: GitRecord
    #   Position 1: WorkingDirectory
    #   Position 2: ArgumentList
    #   Position 3: TimeoutMilliseconds (optional; defaults to the script native-command timeout)
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$GitRecord,

        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory,

        [Parameter(Mandatory = $true)]
        [string[]]$ArgumentList,

        [ValidateRange(1, [int]::MaxValue)]
        [int]$TimeoutMilliseconds = $script:intNativeCommandTimeoutMilliseconds
    )

    $strGitPath = Assert-OrdinaryAbsoluteFile -LiteralPath ([string]$GitRecord.Path)
    # Accepted, bounded residual: this length and SHA-256 check authenticates the
    # executable bytes, but nothing holds the file between the check and the
    # Process.Start call below, so a within-call time-of-check-to-time-of-use
    # window remains. No portable mechanism closes it -- on the Linux CI that runs
    # this verifier, .NET share modes are advisory and do not stop another
    # principal from replacing or renaming the path, and Unix rename/unlink are
    # not governed by file locks. The per-call re-hash bounds cross-call drift;
    # exploitation needs write access to the resolved executable's directory,
    # which in CI is a root-owned system path the unprivileged job cannot write.
    if ((New-Object System.IO.FileInfo($strGitPath)).Length -ne [int64]$GitRecord.Length -or
        (Get-BoundedFileDigest -LiteralPath $strGitPath `
            -MaximumBytes $script:longGitExecutableMaximumBytes `
            -LimitCategory 'git-executable-limit').Digest -cne [string]$GitRecord.Sha256) {
        throw 'git-executable-drift'
    }

    $objStartInfo = New-Object System.Diagnostics.ProcessStartInfo
    $objStartInfo.FileName = $strGitPath
    $objStartInfo.WorkingDirectory = $WorkingDirectory
    $objStartInfo.UseShellExecute = $false
    $objStartInfo.CreateNoWindow = $true
    $objStartInfo.RedirectStandardInput = $true
    $objStartInfo.RedirectStandardOutput = $true
    $objStartInfo.RedirectStandardError = $true
    $objChildEnvironment = $objStartInfo.EnvironmentVariables
    foreach ($strEnvironmentName in @($objChildEnvironment.Keys)) {
        if ($strEnvironmentName.StartsWith('GIT_', [System.StringComparison]::OrdinalIgnoreCase)) {
            [void]$objChildEnvironment.Remove($strEnvironmentName)
        }
    }
    $objChildEnvironment['GIT_CONFIG_NOSYSTEM'] = '1'
    # Git reads the system attributes file ($(prefix)/etc/gitattributes) through a
    # switch of its own, GIT_ATTR_NOSYSTEM; GIT_CONFIG_NOSYSTEM and the
    # core.attributesFile override below do not cover it, because core.attributesFile
    # is only the global attributes file. Without this a system attributes file could
    # normalize content and change the working and untracked reads across hosts, or
    # let a concurrently changed external file perturb a read. Disable it so the
    # reads stay hermetic and host-symmetric.
    $objChildEnvironment['GIT_ATTR_NOSYSTEM'] = '1'
    # Neutralize every ambient input the path-set reads would otherwise depend on,
    # so the result is hermetic and host-symmetric. These -c overrides take the
    # highest git config precedence, so they hold regardless of any value a local
    # config file -- or a file it pulls in with include.path/includeIf -- sets:
    #   - no system or global config;
    #   - no external excludes file (the untracked read's core.excludesFile), no
    #     external attributes file (core.attributesFile), and no diff order file
    #     (diff.orderFile), each of which may point outside the repository; a
    #     diff.orderFile set to a FIFO or other blocking path would otherwise make
    #     every diff read open it and hang to the native-command timeout, and its
    #     ordering is discarded by the HashSet parser regardless;
    #   - a host-independent core.filemode, so a tracked file's executable bit
    #     cannot make the working and staged reads differ between Windows (filemode
    #     false) and Linux (filemode true);
    #   - a host-independent core.ignoreCase=false, so a case-only path difference
    #     (for example a tracked 'a' and an untracked 'A') is never collapsed on a
    #     case-sensitive host whose local config left core.ignoreCase true, which
    #     would otherwise hide the extra path from the untracked and working reads;
    #   - a host-independent core.symlinks=true, so an indexed symlink replaced by an
    #     ordinary file holding the link text is seen as a mode change (a reported
    #     path) rather than collapsed to an equal regular file by a local
    #     core.symlinks=false, which would hide the working-read change;
    #   - host-independent line-ending handling (core.autocrlf=false, core.eol=lf), so
    #     a local core.autocrlf=true cannot normalize CRLF worktree bytes to a matching
    #     LF blob and hide a working-read change, and no host-dependent native EOL
    #     leaks into a text-attributed comparison;
    #   - strict stat validation (core.checkStat=default, core.trustctime=true), so
    #     a relaxed local setting cannot let a same-length content change with a
    #     restored mtime read as clean through Git's cached stat;
    #   - no replacement-ref object substitution (core.useReplaceRefs=false), so a
    #     pre-existing refs/replace/* ref cannot rewrite the objects a diff reads and
    #     hide a worktree-versus-index or index-versus-HEAD difference. Working mode
    #     disables reference evidence, so refs/replace/* is neither hashed nor
    #     neutralized there without this override; disabling it in the fixed prefix
    #     closes that fail-open channel for every mode.
    # info/exclude and info/attributes (repository-local, under the common Git
    # directory) remain covered by Get-GitControlSurfaceEvidence. Submodule
    # ignoring is set per command, never as a global config: --ignore-submodules=all
    # is passed to the worktree-versus-index diffs (the working and clean reads), so a
    # mutable submodule worktree state does not perturb them, while the staged read
    # (git diff --cached) passes --ignore-submodules=none so it keeps submodule
    # sensitivity and still reports a staged gitlink (index-versus-HEAD) change even
    # when a local config or a tracked .gitmodules sets submodule.<name>.ignore=all,
    # which would otherwise suppress that staged gitlink change.
    $strNullDevice = if ($script:boolHostIsWindows) { 'NUL' } else { '/dev/null' }
    $objChildEnvironment['GIT_CONFIG_GLOBAL'] = $strNullDevice
    $objChildEnvironment['GIT_OPTIONAL_LOCKS'] = '0'
    $objChildEnvironment['GIT_TERMINAL_PROMPT'] = '0'
    $objChildEnvironment['LC_ALL'] = 'C'
    $objChildEnvironment['LANG'] = 'C'
    $arrFixedArguments = @(
        '--no-optional-locks',
        '-c', 'core.fsmonitor=false',
        '-c', 'core.untrackedCache=false',
        '-c', 'core.filemode=false',
        '-c', 'core.ignoreCase=false',
        '-c', 'core.symlinks=true',
        '-c', 'core.autocrlf=false',
        '-c', 'core.eol=lf',
        '-c', 'core.checkStat=default',
        '-c', 'core.trustctime=true',
        '-c', 'core.useReplaceRefs=false',
        '-c', ('core.excludesFile=' + $strNullDevice),
        '-c', ('core.attributesFile=' + $strNullDevice),
        '-c', ('diff.orderFile=' + $strNullDevice)
    ) + $ArgumentList
    if ($null -ne $objStartInfo.PSObject.Properties['ArgumentList']) {
        foreach ($strArgument in $arrFixedArguments) {
            [void]$objStartInfo.ArgumentList.Add($strArgument)
        }
    } else {
        $objStartInfo.Arguments = ConvertTo-NativeArgumentString -ArgumentList $arrFixedArguments
    }

    $objProcess = New-Object System.Diagnostics.Process
    $objProcess.StartInfo = $objStartInfo
    $objStdout = New-Object System.IO.MemoryStream
    $objStderr = New-Object System.IO.MemoryStream
    try {
        if (-not $objProcess.Start()) {
            throw 'native-command'
        }
        $objProcess.StandardInput.Close()
        # Bound the drain at the source. Read stdout and stderr concurrently in fixed
        # chunks and stop as soon as either sink would exceed 4 MiB, so a command that
        # emits hundreds of megabytes -- even one that writes them and exits before any
        # intermediate length could be sampled -- cannot fill the sinks: each sink
        # holds at most 4 MiB plus one chunk before the bound is enforced. An earlier
        # design used two unbounded CopyToAsync copies and polled their lengths, but a
        # copy that completed between polls buffered the whole output before the check
        # ran. Reading both streams concurrently (an async read outstanding on each)
        # keeps the child from deadlocking by filling one pipe while the reader waits
        # on the other. On crossing the bound, terminate the child (and its tree) and
        # fail native-output-limit.
        $objStdoutStream = $objProcess.StandardOutput.BaseStream
        $objStderrStream = $objProcess.StandardError.BaseStream
        $intChunkSize = 65536
        $arrStdoutChunk = New-Object byte[] $intChunkSize
        $arrStderrChunk = New-Object byte[] $intChunkSize
        $objStdoutRead = $objStdoutStream.ReadAsync($arrStdoutChunk, 0, $intChunkSize)
        $objStderrRead = $objStderrStream.ReadAsync($arrStderrChunk, 0, $intChunkSize)
        $boolStdoutDone = $false
        $boolStderrDone = $false
        # Bound the drain by wall-clock time. A native command that neither writes nor
        # exits -- for example a 'git diff --cached' wedged opening a FIFO substituted into
        # the object store after the pre-read scan (Assert-OrdinaryTreeUnder) but before
        # this read -- leaves both reads outstanding forever, so an unbounded WaitAny would
        # block here and no closing evidence check would ever run. WaitAny with the
        # remaining budget converts that indefinite hang into a prompt, fail-closed
        # native-command-timeout: terminate the child tree and throw. This is a liveness
        # backstop, not an atomicity guarantee -- it does not fuse the scan and the read
        # into one operation; it bounds the time any single native command may run.
        $objDrainStopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        while (-not ($boolStdoutDone -and $boolStderrDone)) {
            $intRemainingMilliseconds = $TimeoutMilliseconds - [int]$objDrainStopwatch.ElapsedMilliseconds
            if ($intRemainingMilliseconds -le 0) {
                Stop-NativeProcessTree -Process $objProcess
                throw 'native-command-timeout'
            }
            $listPendingReads = New-Object 'System.Collections.Generic.List[System.Threading.Tasks.Task]'
            if (-not $boolStdoutDone) { $listPendingReads.Add($objStdoutRead) }
            if (-not $boolStderrDone) { $listPendingReads.Add($objStderrRead) }
            if ([System.Threading.Tasks.Task]::WaitAny($listPendingReads.ToArray(), $intRemainingMilliseconds) -lt 0) {
                Stop-NativeProcessTree -Process $objProcess
                throw 'native-command-timeout'
            }
            if (-not $boolStdoutDone -and $objStdoutRead.IsCompleted) {
                $intReadCount = $objStdoutRead.GetAwaiter().GetResult()
                if ($intReadCount -le 0) {
                    $boolStdoutDone = $true
                } else {
                    $objStdout.Write($arrStdoutChunk, 0, $intReadCount)
                    $objStdoutRead = $objStdoutStream.ReadAsync($arrStdoutChunk, 0, $intChunkSize)
                }
            }
            if (-not $boolStderrDone -and $objStderrRead.IsCompleted) {
                $intReadCount = $objStderrRead.GetAwaiter().GetResult()
                if ($intReadCount -le 0) {
                    $boolStderrDone = $true
                } else {
                    $objStderr.Write($arrStderrChunk, 0, $intReadCount)
                    $objStderrRead = $objStderrStream.ReadAsync($arrStderrChunk, 0, $intChunkSize)
                }
            }
            if ($objStdout.Length -gt 4194304 -or $objStderr.Length -gt 4194304) {
                # Terminate the oversized child (and its tree) so the resource bound is
                # always enforced; Dispose() in finally does not terminate it.
                Stop-NativeProcessTree -Process $objProcess
                throw 'native-output-limit'
            }
        }
        # Both streams reached EOF, so the child is exiting; still bound the exit wait by
        # the remaining budget (floored so a child that just closed its streams gets a
        # moment to finalize) rather than waiting unbounded on a pathological child that
        # closes its pipes but never exits.
        $intExitWaitMilliseconds = $TimeoutMilliseconds - [int]$objDrainStopwatch.ElapsedMilliseconds
        if ($intExitWaitMilliseconds -lt 1000) { $intExitWaitMilliseconds = 1000 }
        if (-not $objProcess.WaitForExit($intExitWaitMilliseconds)) {
            Stop-NativeProcessTree -Process $objProcess
            throw 'native-command-timeout'
        }
        $intExitCode = $objProcess.ExitCode
        # Each sink is bounded to at most 4 MiB by the loop above, so these arrays are
        # never larger than that bound.
        $arrStdout = $objStdout.ToArray()
        $arrStderr = $objStderr.ToArray()
        return [ordered]@{
            ExitCode = $intExitCode
            Stdout = $arrStdout
            StderrLength = $arrStderr.Length
        }
    } finally {
        $objStdout.Dispose()
        $objStderr.Dispose()
        $objProcess.Dispose()
    }
}

function ConvertFrom-NulPathRecordStream {
    # .SYNOPSIS
    # Converts NUL-delimited path records to opaque Base64 keys.
    #
    # .DESCRIPTION
    # Splits the raw byte sequence only at NUL delimiters, preserves each path as
    # bytes by Base64-encoding it, and returns an ordinal set. It never decodes or
    # prints observed path bytes.
    #
    # .PARAMETER Bytes
    # Complete NUL-delimited raw path-record stream. An empty sequence is allowed.
    #
    # .EXAMPLE
    # $objKeys = ConvertFrom-NulPathRecordStream -Bytes ([byte[]](0x61, 0x00))
    #
    # # Returns a one-element ordinal HashSet containing the Base64 key for byte 0x61.
    #
    # .EXAMPLE
    # ConvertFrom-NulPathRecordStream -Bytes ([byte[]](0x61))
    #
    # # Throws 'malformed-records' because the final NUL delimiter is missing.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Collections.Generic.HashSet[System.String]. One non-enumerated set of
    # opaque Base64 keys. Throws 'malformed-records' for missing terminators, empty
    # records, or duplicate records, and 'record-limit' above 100,000 records.
    # Parameter-binding and allocation failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260814.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: Bytes
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [byte[]]$Bytes
    )

    $objKeys = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
    if ($Bytes.Length -eq 0) {
        return ,$objKeys
    }
    if ($Bytes[$Bytes.Length - 1] -ne 0) {
        throw 'malformed-records'
    }

    $intRecordStart = 0
    for ($intIndex = 0; $intIndex -lt $Bytes.Length; $intIndex++) {
        if ($Bytes[$intIndex] -ne 0) {
            continue
        }
        $intLength = $intIndex - $intRecordStart
        if ($intLength -le 0) {
            throw 'malformed-records'
        }
        # Base64-encode the record slice in place with the offset/length overload
        # rather than copying it into a fresh byte[] first, which avoids a per-record
        # allocation and copy across the up-to-100,000-record ceiling.
        $strKey = [System.Convert]::ToBase64String($Bytes, $intRecordStart, $intLength)
        if (-not $objKeys.Add($strKey)) {
            throw 'malformed-records'
        }
        if ($objKeys.Count -gt 100000) {
            throw 'record-limit'
        }
        $intRecordStart = $intIndex + 1
    }
    if ($intRecordStart -ne $Bytes.Length) {
        throw 'malformed-records'
    }
    return ,$objKeys
}

function ConvertTo-IgnoredExclusionPath {
    # .SYNOPSIS
    # Decodes git ls-files ignored -z output to absolute worktree-walk exclusions.
    #
    # .DESCRIPTION
    # Validates the NUL framing with ConvertFrom-NulPathRecordStream (so a malformed or
    # over-limit stream fails closed), then decodes each NUL-delimited record as strict
    # UTF-8, strips the trailing slash that --directory adds to a collapsed directory,
    # and resolves it to an absolute full path under the repository root. A record that
    # is not strict UTF-8 is skipped rather than decoded: it is then simply not excluded,
    # so the worktree walk processes it and fails closed exactly as before -- the safe
    # direction. The result is only an exclusion hint for the worktree tree walk; a wrong
    # or missing entry never widens the computed path set, it only refuses in its place.
    #
    # .PARAMETER Bytes
    # Complete raw output from
    # `git ls-files --others --ignored --exclude-standard --directory -z`.
    #
    # .PARAMETER RepositoryRoot
    # Absolute repository root the relative ignored entries resolve against.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String[]. Absolute full paths of the gitignored top-level entries.
    # Record-framing, record-limit, and filesystem failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260814.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: Bytes
    #   Position 1: RepositoryRoot
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [byte[]]$Bytes,

        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    # Reuse the hardened NUL-framing and 100,000-record ceiling. Its base64 keys are not
    # used here; the call fails closed on a malformed or oversized stream.
    [void](ConvertFrom-NulPathRecordStream -Bytes $Bytes)
    $listPaths = New-Object 'System.Collections.Generic.List[string]'
    if ($Bytes.Length -eq 0) {
        return ,$listPaths.ToArray()
    }
    $strRoot = [System.IO.Path]::GetFullPath($RepositoryRoot)
    $intRecordStart = 0
    for ($intIndex = 0; $intIndex -lt $Bytes.Length; $intIndex++) {
        if ($Bytes[$intIndex] -ne 0) {
            continue
        }
        $intLength = $intIndex - $intRecordStart
        $intRecordStart = $intIndex + 1
        $strRelative = $null
        try {
            $strRelative = $script:objUtf8Strict.GetString($Bytes, ($intIndex - $intLength), $intLength)
        } catch {
            $strRelative = $null
        }
        if ([string]::IsNullOrEmpty($strRelative)) {
            continue
        }
        # --directory collapses a fully-ignored directory to a single trailing-'/' entry
        # (git always emits '/'); strip it so the path matches the walk's GetFullPath form.
        $strRelative = $strRelative.TrimEnd('/')
        if ($strRelative.Length -eq 0) {
            continue
        }
        $listPaths.Add([System.IO.Path]::GetFullPath((Join-Path $strRoot $strRelative)))
    }
    return ,$listPaths.ToArray()
}

function ConvertTo-SubmoduleExclusionPath {
    # .SYNOPSIS
    # Decodes git ls-files --stage -z output to initialized-submodule worktree-walk exclusions.
    #
    # .DESCRIPTION
    # Validates the NUL framing with ConvertFrom-NulPathRecordStream (so a malformed or
    # over-limit stream fails closed), then parses each NUL-delimited staged record
    # (`<mode> SP <object> SP <stage> TAB <path>`), keeps only the gitlink entries (mode
    # 160000), decodes each path as strict UTF-8, and resolves it to an absolute full path
    # under the repository root. A record that is not strict UTF-8, or is missing the tab
    # separator, is skipped rather than decoded: it is then simply not excluded, so the
    # worktree walk processes it and fails closed exactly as before -- the safe direction.
    # Only a gitlink whose worktree path exists as a directory (an initialized submodule)
    # is returned; an uninitialized gitlink has no populated directory for the walk to
    # descend into. The result is only an exclusion hint for the worktree tree walk; a
    # wrong or missing entry never widens the computed path set, it only refuses in its
    # place. The gitlink object id itself stays covered by the git-index control component.
    #
    # .PARAMETER Bytes
    # Complete raw output from `git ls-files -z --stage`.
    #
    # .PARAMETER RepositoryRoot
    # Absolute repository root the relative gitlink entries resolve against.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String[]. Absolute full paths of the initialized submodule roots.
    # Record-framing, record-limit, and filesystem failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260816.3
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: Bytes
    #   Position 1: RepositoryRoot
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [byte[]]$Bytes,

        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    # Reuse the hardened NUL-framing and 100,000-record ceiling. Its base64 keys are not
    # used here; the call fails closed on a malformed or oversized stream.
    [void](ConvertFrom-NulPathRecordStream -Bytes $Bytes)
    $listPaths = New-Object 'System.Collections.Generic.List[string]'
    if ($Bytes.Length -eq 0) {
        return ,$listPaths.ToArray()
    }
    $strRoot = [System.IO.Path]::GetFullPath($RepositoryRoot)
    $intRecordStart = 0
    for ($intIndex = 0; $intIndex -lt $Bytes.Length; $intIndex++) {
        if ($Bytes[$intIndex] -ne 0) {
            continue
        }
        $intLength = $intIndex - $intRecordStart
        $intRecordStart = $intIndex + 1
        $strRecord = $null
        try {
            $strRecord = $script:objUtf8Strict.GetString($Bytes, ($intIndex - $intLength), $intLength)
        } catch {
            $strRecord = $null
        }
        if ([string]::IsNullOrEmpty($strRecord)) {
            continue
        }
        # `git ls-files --stage` emits `<mode> SP <object> SP <stage> TAB <path>`. Only a
        # gitlink (mode 160000) is a submodule; ordinary files (100644/100755) and symlinks
        # (120000) are not. Split the metadata before the single tab and read the mode.
        $intTabIndex = $strRecord.IndexOf("`t")
        if ($intTabIndex -lt 0) {
            continue
        }
        $arrMetaField = $strRecord.Substring(0, $intTabIndex).Split(' ')
        $strRelative = $strRecord.Substring($intTabIndex + 1)
        if ($arrMetaField.Count -lt 1 -or $arrMetaField[0] -cne '160000' -or $strRelative.Length -eq 0) {
            continue
        }
        # An initialized submodule is populated as an ordinary directory the walk would
        # descend into; an uninitialized gitlink has no such directory, so nothing to skip.
        $strAbsolute = [System.IO.Path]::GetFullPath((Join-Path $strRoot $strRelative))
        if ([System.IO.Directory]::Exists($strAbsolute)) {
            $listPaths.Add($strAbsolute)
        }
    }
    return ,$listPaths.ToArray()
}

function ConvertTo-TrackedRelativePathSet {
    # .SYNOPSIS
    # Decodes git ls-files --stage -z output to the set of tracked repository-relative paths.
    #
    # .DESCRIPTION
    # Validates the NUL framing with ConvertFrom-NulPathRecordStream (so a malformed or
    # over-limit stream fails closed), then parses each NUL-delimited staged record
    # (`<mode> SP <object> SP <stage> TAB <path>`) and decodes the path after the single tab
    # as strict UTF-8. Returns every tracked repository-relative path in a HashSet whose
    # comparer matches the host filesystem's case sensitivity (OrdinalIgnoreCase on Windows,
    # Ordinal elsewhere) -- the same case rule the worktree walk applies to its other path
    # comparisons. A worktree walk classifies a non-directory, non-reparse entry with this
    # set: a tracked path is hashed and byte-limited, and an untracked path is recorded by
    # name and existence only. The '/'-separated ls-files paths already match the
    # '/'-normalized relative paths the walk produces, so membership is a direct set test.
    #
    # A record that is not strict UTF-8, or is missing the tab separator, is skipped rather
    # than decoded: its path is then absent from the set and the walk treats the on-disk
    # entry as untracked. That only relaxes a secondary drift bracket -- the authoritative
    # working and working-repeat reads still bracket the computed path set -- so skipping an
    # exotic name is the safe direction. Every staged record is a tracked path, so, unlike
    # the submodule-exclusion parse, the mode is not inspected; an unmerged path emits
    # several stage records and the HashSet keeps one entry per path.
    #
    # .PARAMETER Bytes
    # Complete raw output from `git ls-files -z --stage`.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Collections.Generic.HashSet[string]. The tracked repository-relative paths,
    # compared with the host filesystem's case sensitivity. Record-framing and record-limit
    # failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260817.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: Bytes
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [byte[]]$Bytes
    )

    # Reuse the hardened NUL-framing and 100,000-record ceiling. Its base64 keys are not
    # used here; the call fails closed on a malformed or oversized stream.
    [void](ConvertFrom-NulPathRecordStream -Bytes $Bytes)
    $objComparer = if ($script:boolHostIsWindows) {
        [System.StringComparer]::OrdinalIgnoreCase
    } else {
        [System.StringComparer]::Ordinal
    }
    $objTracked = New-Object 'System.Collections.Generic.HashSet[string]' ($objComparer)
    if ($Bytes.Length -eq 0) {
        return ,$objTracked
    }
    $intRecordStart = 0
    for ($intIndex = 0; $intIndex -lt $Bytes.Length; $intIndex++) {
        if ($Bytes[$intIndex] -ne 0) {
            continue
        }
        $intLength = $intIndex - $intRecordStart
        $intRecordStart = $intIndex + 1
        $strRecord = $null
        try {
            $strRecord = $script:objUtf8Strict.GetString($Bytes, ($intIndex - $intLength), $intLength)
        } catch {
            $strRecord = $null
        }
        if ([string]::IsNullOrEmpty($strRecord)) {
            continue
        }
        # `git ls-files --stage` emits `<mode> SP <object> SP <stage> TAB <path>`. Every
        # staged record is a tracked path, so -- unlike the submodule-exclusion parse -- the
        # mode is not inspected here; only the path after the single tab is taken.
        $intTabIndex = $strRecord.IndexOf("`t")
        if ($intTabIndex -lt 0) {
            continue
        }
        $strRelative = $strRecord.Substring($intTabIndex + 1)
        if ($strRelative.Length -eq 0) {
            continue
        }
        [void]$objTracked.Add($strRelative)
    }
    return ,$objTracked
}

function New-ExpectedPathKeySet {
    # .SYNOPSIS
    # Builds opaque keys for the caller's expected repository paths.
    #
    # .DESCRIPTION
    # Validates each path as unique canonical printable ASCII repository-relative
    # text. Rejects empty or whitespace-only text, a leading separator, a traversal
    # segment, a backslash, a colon, a doubled slash, control or non-ASCII text,
    # and duplicates, then Base64-encodes its ASCII bytes into an ordinal set.
    #
    # .PARAMETER PathList
    # Exact expected repository-relative path strings. An empty collection is allowed.
    #
    # .EXAMPLE
    # $objKeys = New-ExpectedPathKeySet -PathList @('STYLE_GUIDE.md')
    #
    # # Returns a one-element ordinal HashSet containing the path's Base64 key.
    #
    # .EXAMPLE
    # New-ExpectedPathKeySet -PathList @('../outside')
    #
    # # Throws 'invalid-expected-path' because traversal segments are forbidden.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Collections.Generic.HashSet[System.String]. One non-enumerated set of
    # expected Base64 keys. Throws 'invalid-expected-path' for invalid, non-ASCII,
    # or duplicate paths; parameter-binding, encoding, and allocation failures
    # propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260814.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: PathList
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'Builds an in-memory value and changes no system state; ShouldProcess does not apply.'
    )]
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]]$PathList
    )

    $objAscii = New-Object System.Text.ASCIIEncoding
    $objKeys = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
    if ($PathList.Count -gt 100000) {
        throw 'invalid-expected-path'
    }
    foreach ($strPath in $PathList) {
        if ($null -eq $strPath -or $strPath.Length -eq 0 -or $strPath.Trim().Length -eq 0 -or
            $strPath -match '^[\\/]' -or $strPath -match '(^|/)\.\.?(/|$)' -or
            $strPath.Contains('\') -or $strPath.Contains(':') -or $strPath.Contains('//')) {
            throw 'invalid-expected-path'
        }
        foreach ($chrCharacter in $strPath.ToCharArray()) {
            $intValue = [int]$chrCharacter
            if ($intValue -lt 0x20 -or $intValue -gt 0x7E) {
                throw 'invalid-expected-path'
            }
        }
        $strKey = [System.Convert]::ToBase64String($objAscii.GetBytes($strPath))
        if (-not $objKeys.Add($strKey)) {
            throw 'invalid-expected-path'
        }
    }
    return ,$objKeys
}

function Assert-OrdinaryRepositoryRoot {
    # .SYNOPSIS
    # Resolves and validates an ordinary absolute repository root.
    #
    # .DESCRIPTION
    # Requires rooted path text, normalizes it to a full path, and walks from the
    # leaf through every ancestor. Each component must exist as a non-reparse
    # directory. An optional AncestorBoundary stops the walk at a caller-validated
    # ancestor, so an ancestor above that boundary is never inspected.
    #
    # .PARAMETER LiteralPath
    # Absolute literal worktree-root path to normalize and validate.
    #
    # .PARAMETER AncestorBoundary
    # Optional absolute ancestor the caller has already validated as an ordinary directory.
    # When supplied, the walk validates every component from the leaf up to and including
    # this boundary and then stops, rather than walking to the filesystem root, so a reparse
    # or otherwise non-ordinary directory above the boundary (for example a symlinked /var or
    # a custom TMPDIR) cannot reject the leaf. A boundary that is not on the leaf's ancestor
    # chain fails closed. When omitted, the walk reaches the filesystem root exactly as
    # before.
    #
    # .EXAMPLE
    # $strRoot = Assert-OrdinaryRepositoryRoot -LiteralPath (Resolve-Path '.').Path
    #
    # # Returns the normalized full path when every component is an ordinary directory.
    #
    # .EXAMPLE
    # Assert-OrdinaryRepositoryRoot -LiteralPath '..\relative'
    #
    # # Throws 'invalid-repository-root' because the supplied path is not rooted.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String. The normalized full repository path. Throws
    # 'invalid-repository-root' for a relative path or when DirectoryInfo.Exists
    # returns false, including absorbed access/filesystem errors, for a
    # non-directory or reparse component, and for an AncestorBoundary that is not on the
    # leaf's ancestor chain. Parameter-binding, path-normalization, and metadata failures
    # after existence is established propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260818.1
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: LiteralPath
    #
    # AncestorBoundary is named, not positional.
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [AllowNull()]
        [string]$AncestorBoundary
    )

    if (-not [System.IO.Path]::IsPathRooted($LiteralPath)) {
        throw 'invalid-repository-root'
    }
    foreach ($chrCharacter in $LiteralPath.ToCharArray()) {
        if ([char]::IsControl($chrCharacter)) {
            throw 'invalid-repository-root'
        }
    }
    $strFullPath = [System.IO.Path]::GetFullPath($LiteralPath)
    # Optional ancestor boundary: a caller that has already validated an ordinary ancestor
    # (for example a self-test that created its fixture root under the temporary directory)
    # passes it here so the walk validates every component from the leaf up to and including
    # the boundary and then stops, rather than walking to the filesystem root. An ancestor
    # above the boundary is never inspected, so a reparse or otherwise non-ordinary ancestor
    # (a symlinked /var, a custom TMPDIR) cannot reject an otherwise valid leaf. A boundary
    # that is not on the leaf's ancestor chain is a caller error and fails closed.
    $strBoundaryFull = $null
    if (-not [string]::IsNullOrEmpty($AncestorBoundary)) {
        if (-not [System.IO.Path]::IsPathRooted($AncestorBoundary)) {
            throw 'invalid-repository-root'
        }
        $strBoundaryFull = [System.IO.Path]::GetFullPath($AncestorBoundary)
    }
    $objCurrent = New-Object System.IO.DirectoryInfo($strFullPath)
    $boolBoundaryReached = $false
    while ($null -ne $objCurrent) {
        if (-not $objCurrent.Exists -or
            ($objCurrent.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0 -or
            ($objCurrent.Attributes -band [System.IO.FileAttributes]::Directory) -eq 0) {
            throw 'invalid-repository-root'
        }
        if ($null -ne $strBoundaryFull -and
            [System.IO.Path]::GetFullPath($objCurrent.FullName).Equals(
                $strBoundaryFull, $script:objPathComparison)) {
            $boolBoundaryReached = $true
            break
        }
        $objCurrent = $objCurrent.Parent
    }
    if ($null -ne $strBoundaryFull -and -not $boolBoundaryReached) {
        throw 'invalid-repository-root'
    }
    return $strFullPath
}

function Get-FramedStringMapDigest {
    # .SYNOPSIS
    # Hashes one ordered string map with unambiguous length framing.
    #
    # .DESCRIPTION
    # Encodes each key and value as strict UTF-8. Writes a big-endian count and
    # a big-endian byte length before each component, then hashes the frame.
    #
    # .PARAMETER StringMap
    # Ordered string dictionary to frame and hash.
    #
    # .EXAMPLE
    # $strDigest = Get-FramedStringMapDigest -StringMap $objEvidenceMap
    #
    # # Returns one lowercase SHA-256 digest for the complete map.
    #
    # .EXAMPLE
    # $strDigest = Get-FramedStringMapDigest -StringMap ([ordered]@{})
    #
    # # Returns the digest of an explicitly framed empty map.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String. The lowercase SHA-256 digest. Encoding, stream, allocation,
    # hashing, enumeration, and parameter-binding failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260814.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: StringMap
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$StringMap
    )

    $objBuffer = New-Object System.IO.MemoryStream
    $objSha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        $arrCount = [System.BitConverter]::GetBytes([int64]$StringMap.Count)
        if ([System.BitConverter]::IsLittleEndian) {
            [System.Array]::Reverse($arrCount)
        }
        $objBuffer.Write($arrCount, 0, $arrCount.Length)
        foreach ($strKey in $StringMap.Keys) {
            foreach ($strValue in @([string]$strKey, [string]$StringMap[$strKey])) {
                $arrValue = $script:objUtf8Strict.GetBytes($strValue)
                $arrLength = [System.BitConverter]::GetBytes([int64]$arrValue.Length)
                if ([System.BitConverter]::IsLittleEndian) {
                    [System.Array]::Reverse($arrLength)
                }
                $objBuffer.Write($arrLength, 0, $arrLength.Length)
                $objBuffer.Write($arrValue, 0, $arrValue.Length)
            }
        }
        # Hash the MemoryStream directly, rewound to its start, instead of
        # $objBuffer.ToArray(): ToArray() would copy the entire framed buffer into a
        # second array before hashing, doubling peak memory for a large map (up to the
        # 100,000-entry ceiling in callers). ComputeHash(Stream) reads from the
        # current position, so the digest is byte-identical to the array form.
        $objBuffer.Position = 0
        return ([System.BitConverter]::ToString($objSha256.ComputeHash($objBuffer))).Replace('-', '').ToLowerInvariant()
    } finally {
        $objSha256.Dispose()
        $objBuffer.Dispose()
    }
}

function Get-TreeEvidence {
    # .SYNOPSIS
    # Gets bounded byte evidence for one ordinary directory tree.
    #
    # .DESCRIPTION
    # Walks without following links. Records every directory and regular file in
    # ordinal relative-path order. Hashes file content and a length-framed map.
    # Rejects more than 100,000 entries, one file above 64 MiB, or total file
    # length above 1 GiB. Optionally excludes one exact child entry.
    #
    # With WorktreeClassification set (the worktree callers), the walk hashes and byte-limits a
    # tracked ordinary file (named by TrackedRelativePath) and an untracked .gitignore or
    # .gitattributes control input; it records every other untracked ordinary file and every
    # reparse point by name and existence only (sharing one key, so a type change raises no
    # drift), traverses a directory without a 'D:' identity key, and records an untracked embedded
    # Git repository name-only without traversing it. With OmitUntrackedEvidence also set (the
    # staged-plus-clean-only caller), it further omits an untracked ordinary file, reparse point,
    # or embedded repository from the digest and, per H4, from the entry-count ceiling, so
    # unrelated untracked population raises neither worktree drift nor worktree-limit; a tracked
    # entry, an untracked control file, and every traversed directory stay counted. Without the
    # switch (a .git control-surface tree) every non-directory entry is hashed, a directory keeps
    # its 'D:' key, and a reparse or special entry is refused. See the parameter notes below.
    #
    # .PARAMETER RootPath
    # Absolute ordinary directory root to inspect.
    #
    # .PARAMETER ExcludedPath
    # Optional exact absolute entry to exclude without traversal.
    #
    # .PARAMETER AdditionalExcludedPath
    # Optional set of exact absolute entries to exclude without traversal, in addition
    # to ExcludedPath. A worktree read passes the gitignored top-level entries here
    # (enumerated once via git ls-files --others --ignored --directory) so the walk
    # omits what the tracked working diff and the --exclude-standard untracked read
    # already omit. Matched with the same ordinal path comparison the walk uses.
    #
    # .PARAMETER LinkCategory
    # Category thrown for a reparse point. Defaults to 'worktree-link'.
    #
    # .PARAMETER SpecialEntryCategory
    # Category thrown for a Unix FIFO/socket/device, or a non-Windows host that cannot
    # report the entry type. Defaults to 'worktree-special-entry'.
    #
    # .PARAMETER LimitCategory
    # Category thrown for the entry-count or byte ceilings. Defaults to 'worktree-limit'.
    #
    # .PARAMETER MaximumEntryCount
    # Ceiling for the counted-entry total. Defaults to 100000. Every recorded relevant entry and
    # every traversed directory counts; an omitted irrelevant untracked entry does not (H4). Only a
    # self-test lowers it, to prove the counting without the production count of entries.
    #
    # .PARAMETER WorktreeClassification
    # Switches the walk into worktree-classification mode: hash and byte-limit only the
    # tracked ordinary files named by TrackedRelativePath; record an untracked ordinary
    # file or any reparse point by name and existence only, without throwing. Off by
    # default, so a .git control-surface caller keeps the original refuse-and-hash-all
    # behavior.
    #
    # .PARAMETER TrackedRelativePath
    # Set of tracked repository-relative paths ('/'-separated, matching the walk's relative
    # keys), built once by the caller from the pre-walk git ls-files -z --stage output.
    # Required when WorktreeClassification is set; ignored otherwise. Membership decides
    # whether a non-directory, non-reparse entry is hashed (tracked) or recorded by name and
    # existence only (untracked).
    #
    # .PARAMETER OmitUntrackedEvidence
    # Switches the walk into tracked/control-only evidence mode. It omits an untracked ordinary
    # file, reparse point, or embedded repository from the digest and from the entry-count ceiling
    # (H4); a tracked entry, an untracked control file, and every traversed directory stay counted.
    # Off by default and ignored unless WorktreeClassification is set.
    #
    # .PARAMETER AncestorBoundary
    # Optional absolute ancestor the caller has already validated as an ordinary directory,
    # forwarded to Assert-OrdinaryRepositoryRoot. A self-test that builds its fixture under
    # the temporary directory passes the fixture root here, so the root-validation walk stops
    # at that root and never inspects the temporary-directory ancestry (a symlinked /var or a
    # custom TMPDIR). The production callers pass the repository root and its .git subtrees
    # with no boundary, so those keep full-ancestry validation.
    #
    # .EXAMPLE
    # $hashtableTree = Get-TreeEvidence -RootPath $strRepositoryRoot -ExcludedPath $strGitEntry
    #
    # # Returns bounded worktree digest and count evidence without reading .git.
    #
    # .EXAMPLE
    # $strRefsDigest = (Get-TreeEvidence -RootPath $strLooseRefsPath -ExcludedPath $null `
    #     -LinkCategory 'invalid-git-control' -SpecialEntryCategory 'invalid-git-control' `
    #     -LimitCategory 'git-control-limit').Digest
    #
    # # Returns a bounded digest for a .git reference tree, refusing a reparse point,
    # # special file, or over-limit tree as a control-surface category.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Collections.Specialized.OrderedDictionary. Contains Digest,
    # EntryCount, FileCount, and ByteCount. Throws LinkCategory,
    # SpecialEntryCategory, or LimitCategory for refused state (worktree
    # categories by default). Filesystem and hashing failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260818.3
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: RootPath
    #   Position 1: ExcludedPath
    #   Position 2: AdditionalExcludedPath
    #
    # LinkCategory, SpecialEntryCategory, and LimitCategory are named and default to the
    # worktree categories; a control-surface caller overrides them so a failing .git tree
    # reports a control-surface category instead of a worktree one. WorktreeClassification
    # and TrackedRelativePath are named as well; the worktree callers set them to hash only
    # tracked ordinary files. PositionalBinding is disabled, so only Positions 0-2 bind
    # positionally and every other parameter binds by name.
    [CmdletBinding(PositionalBinding = $false)]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$RootPath,

        [Parameter(Position = 1)]
        [AllowNull()]
        [string]$ExcludedPath,

        [Parameter(Position = 2)]
        [string[]]$AdditionalExcludedPath = @(),

        [ValidateNotNullOrEmpty()]
        [string]$LinkCategory = 'worktree-link',

        [ValidateNotNullOrEmpty()]
        [string]$SpecialEntryCategory = 'worktree-special-entry',

        [ValidateNotNullOrEmpty()]
        [string]$LimitCategory = 'worktree-limit',

        [ValidateRange(1, [int]::MaxValue)]
        [int]$MaximumEntryCount = 100000,

        [switch]$WorktreeClassification,

        [switch]$OmitUntrackedEvidence,

        [System.Collections.Generic.HashSet[string]]$TrackedRelativePath,

        [AllowNull()]
        [string]$AncestorBoundary
    )

    $strRoot = Assert-OrdinaryRepositoryRoot -LiteralPath $RootPath -AncestorBoundary $AncestorBoundary
    $strExcluded = if ([string]::IsNullOrEmpty($ExcludedPath)) {
        $null
    } else {
        [System.IO.Path]::GetFullPath($ExcludedPath)
    }
    # Full-path set of additional entries to skip without traversal (the gitignored
    # top-level entries for a worktree read). Compared with the same ordinal path
    # comparison the walk uses for ExcludedPath, so Windows case-insensitivity holds.
    $objAdditionalExcludedComparer = if ($script:boolHostIsWindows) {
        [System.StringComparer]::OrdinalIgnoreCase
    } else {
        [System.StringComparer]::Ordinal
    }
    $objAdditionalExcluded = New-Object 'System.Collections.Generic.HashSet[string]' `
        ($objAdditionalExcludedComparer)
    foreach ($strAdditionalExcludedEntry in $AdditionalExcludedPath) {
        if (-not [string]::IsNullOrEmpty($strAdditionalExcludedEntry)) {
            [void]$objAdditionalExcluded.Add([System.IO.Path]::GetFullPath($strAdditionalExcludedEntry))
        }
    }
    $objMap = New-Object 'System.Collections.Generic.SortedDictionary[string,string]' `
        ([System.StringComparer]::Ordinal)
    $objPending = New-Object 'System.Collections.Generic.Stack[string]'
    $objPending.Push($strRoot)
    $intFileCount = 0
    $intEntryCount = 0
    $longByteCount = 0L
    while ($objPending.Count -ne 0) {
        $strDirectory = $objPending.Pop()
        # No ordering is applied to the enumeration. Every entry is recorded in
        # $objMap, an ordinal SortedDictionary, so the framed digest and the
        # counts are independent of enumeration order. A sort here would be dead
        # work, and Sort-Object specifically would add culture-dependent semantics.
        #
        # Iterate the enumerable lazily rather than materializing it with @(...).
        # A single directory holding far more than the 100,000-entry ceiling would
        # otherwise retain every pathname in one array before the loop could reach
        # the entry-count bound below, so a hostile or accidental directory could
        # exhaust memory before the promised bounded failure. Streaming one entry
        # at a time keeps the retained set within that ceiling, which is enforced
        # after each entry is recorded.
        foreach ($strEntry in [System.IO.Directory]::EnumerateFileSystemEntries($strDirectory)) {
            $strFullEntry = [System.IO.Path]::GetFullPath($strEntry)
            if ($null -ne $strExcluded -and $strFullEntry.Equals($strExcluded, $script:objPathComparison)) {
                continue
            }
            $objAttributes = [System.IO.File]::GetAttributes($strFullEntry)
            $boolReparseEntry = ($objAttributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
            $boolDirectoryEntry = ($objAttributes -band [System.IO.FileAttributes]::Directory) -ne 0
            # Worktree classification (E2): an untracked .gitignore or .gitattributes is a Git
            # control input, not ordinary payload. Git reads the worktree .gitignore for the
            # --exclude-standard untracked set and the worktree .gitattributes for the working
            # diff, tracked or not and in any walked directory, so its bytes decide what a
            # path-set read reports. Detect a regular (non-reparse, non-directory) instance by
            # basename under the host case rule so the untracked branch below leaves it for the
            # hashing branch, and so the ignored-exclusion skip below never drops it. Git
            # refuses to follow a symlinked control file, so a reparse-point instance is not a
            # control input and is recorded name-only below.
            $boolUntrackedControlFile = $false
            if ($WorktreeClassification -and -not $boolReparseEntry -and -not $boolDirectoryEntry) {
                $strEntryName = [System.IO.Path]::GetFileName($strFullEntry)
                if ($strEntryName.Equals('.gitignore', $script:objPathComparison) -or
                    $strEntryName.Equals('.gitattributes', $script:objPathComparison)) {
                    $boolUntrackedControlFile = $true
                }
            }
            # G1: the ignored-exclusion set (git ls-files --others --ignored --directory) can
            # list an ignored .gitignore or .gitattributes that Git still reads as a control
            # input, so a regular control file is never skipped here; it stays evidence-relevant
            # through the hashing branch (E2). Every other ignored top-level entry and every
            # initialized submodule root is skipped without traversal, exactly as before.
            if ($objAdditionalExcluded.Count -ne 0 -and -not $boolUntrackedControlFile -and
                $objAdditionalExcluded.Contains($strFullEntry)) {
                continue
            }
            $strRelativePath = $strFullEntry.Substring($strRoot.Length).TrimStart(
                [System.IO.Path]::DirectorySeparatorChar,
                [System.IO.Path]::AltDirectorySeparatorChar
            ).Replace([System.IO.Path]::DirectorySeparatorChar, '/')
            # H4: an omitted irrelevant untracked entry clears this below so it does not count.
            $boolEntryCounted = $true
            if ($boolReparseEntry) {
                if ($WorktreeClassification) {
                    # Worktree classification (F4): record a reparse point (a symbolic link,
                    # or any other reparse point) by name and existence only -- the same key
                    # an untracked ordinary file receives below. Do not throw, follow the
                    # link, read its target, or descend into it. Git stores a tracked symlink
                    # as a mode-120000 blob it never dereferences, and a clean tracked symlink
                    # appears in neither worktree read, so name-and-existence evidence is
                    # sufficient; a tracked link's target stays bracketed by the working and
                    # working-repeat reads and the git-index control digest. Sharing the
                    # untracked-file key means a type change that keeps the path (a link
                    # replaced by a regular file, or the reverse) does not raise a false
                    # worktree-drift.
                    #
                    # H2: in tracked/control-only mode, omit an untracked reparse point (one not
                    # in the tracked set) from the digest. Keep a tracked reparse point, so
                    # tracked-symlink evidence is unchanged.
                    if (-not ($OmitUntrackedEvidence -and
                            -not $TrackedRelativePath.Contains($strRelativePath))) {
                        $objMap['F:' + $strRelativePath] = ''
                    } else { $boolEntryCounted = $false }
                } else {
                    # Control-surface tree (worktree classification off): a reparse point in a
                    # .git reference tree is still refused, exactly as before.
                    throw $LinkCategory
                }
            } elseif ($boolDirectoryEntry) {
                # Worktree classification (F4): traverse every directory but omit its identity
                # key. Git path-set streams (git ls-files, git diff) report only files and never
                # an empty directory, so recording a 'D:' key would let an empty untracked
                # directory that no path-set read reports change the worktree digest and perturb
                # convergence. The control-surface walk keeps the 'D:' key, because a .git
                # reference tree's directory shape is part of the hashed control surface.
                if ($WorktreeClassification) {
                    # G2: an untracked embedded Git repository is a directory that itself holds a
                    # .git entry. Git reports it as one untracked path (for example nested/) and
                    # never descends into it, so the worktree reads never consume its internals.
                    # Record the Git-reported root by name and existence only -- the same
                    # name-only key an untracked file receives -- and do not traverse it, so the
                    # walk neither hashes, counts, nor drifts on its .git internals and cannot
                    # raise a false worktree-limit from a large nested repository. An initialized
                    # submodule is a gitlink already excluded before this point, so only a
                    # non-submodule embedded repository reaches here.
                    $strNestedGitPath = [System.IO.Path]::Combine($strFullEntry, '.git')
                    $boolEmbeddedRepository = $false
                    try {
                        [void][System.IO.File]::GetAttributes($strNestedGitPath)
                        $boolEmbeddedRepository = $true
                    } catch [System.IO.FileNotFoundException] {
                        $boolEmbeddedRepository = $false
                    } catch [System.IO.DirectoryNotFoundException] {
                        $boolEmbeddedRepository = $false
                    }
                    if ($boolEmbeddedRepository) {
                        # H2: in tracked/control-only mode, omit an untracked embedded
                        # repository from the digest; it is never a tracked entry.
                        if (-not $OmitUntrackedEvidence) {
                            $objMap['F:' + $strRelativePath] = ''
                        } else { $boolEntryCounted = $false }
                    } else {
                        $objPending.Push($strFullEntry)
                    }
                } else {
                    $objMap['D:' + $strRelativePath] = ''
                    $objPending.Push($strFullEntry)
                }
            } elseif ($WorktreeClassification -and -not $boolUntrackedControlFile -and
                -not $TrackedRelativePath.Contains($strRelativePath)) {
                # Worktree classification (F3): an untracked ordinary file -- and not an
                # untracked .gitignore or .gitattributes, which the control-input test above
                # routed to the hashing branch (E2). Record its name and existence only -- the
                # same key a worktree reparse point receives above. Do not open it, probe its
                # Unix type, hash it, or apply the content byte limits: no path-set read consumes
                # untracked payload content (git ls-files --others reports only its name), so
                # hashing it would raise a false worktree-limit or, on content-only churn, a
                # false worktree-drift that no computed-set change can justify. An untracked
                # FIFO/socket/device likewise needs no content-type refusal here, because it is
                # never opened.
                #
                # H2: omit an untracked ordinary file from the digest. H4: omit it from the entry
                # ceiling too, so unrelated untracked population cannot raise worktree-limit.
                if (-not $OmitUntrackedEvidence) {
                    $objMap['F:' + $strRelativePath] = ''
                } else { $boolEntryCounted = $false }
            } else {
                # A tracked ordinary file, an untracked .gitignore or .gitattributes (E2), or
                # any file when worktree classification is off (a .git control-surface tree):
                # hash the content and apply the per-file and aggregate byte limits, because git
                # diff reads a tracked file's content when it compares the worktree against the
                # index, and Git reads an untracked .gitignore/.gitattributes as a control input.
                $objFile = New-Object System.IO.FileInfo($strFullEntry)
                # On Unix an entry that is neither a directory nor a reparse point can
                # still be a FIFO, socket, or device, which File attributes do not
                # distinguish from a regular file, so a zero-length FIFO would receive
                # the same evidence as a zero-byte regular file. PowerShell's UnixMode
                # string exposes the type in its first character. Reject the explicit
                # special types so a special entry cannot alias a regular file. On
                # Windows there are no such entries and the property is absent, so the
                # check is a no-op there. On a non-Windows host that does not expose
                # UnixMode (for example PowerShell 7.0), the entry's type cannot be read,
                # so fail closed rather than hash a potentially blocking special entry
                # as if it were a regular file.
                $objUnixModeProperty = $objFile.PSObject.Properties['UnixMode']
                if ($null -ne $objUnixModeProperty) {
                    $strUnixMode = [string]$objUnixModeProperty.Value
                    if ($strUnixMode.Length -gt 0 -and ($strUnixMode[0] -eq 'p' -or
                        $strUnixMode[0] -eq 's' -or $strUnixMode[0] -eq 'b' -or
                        $strUnixMode[0] -eq 'c')) {
                        throw $SpecialEntryCategory
                    }
                } elseif (-not $script:boolHostIsWindows) {
                    throw $SpecialEntryCategory
                }
                if ($objFile.Length -eq 0) {
                    $strFileDigest = $script:strEmptyFileSha256
                } else {
                    # Enforce the per-file (64 MiB) and aggregate (1 GiB) ceilings during
                    # the content read, not only against the sampled length. A concurrent
                    # writer can grow a regular file after Length is read, and an unbounded
                    # ComputeHash would then read it to the new end (gigabytes, or forever
                    # against a writer that never stops) while $longByteCount kept the
                    # earlier length. Cap each read at the smaller of the per-file ceiling
                    # and the remaining aggregate budget, and credit the exact bytes read,
                    # so the promised bounded worktree-limit failure holds.
                    $longAggregateRemaining = 1073741824 - $longByteCount
                    if ($longAggregateRemaining -lt 1) {
                        throw $LimitCategory
                    }
                    $longFileCeiling = [System.Math]::Min([long]67108864, $longAggregateRemaining)
                    $hashtableFileDigest = Get-BoundedFileDigest `
                        -LiteralPath $strFullEntry `
                        -MaximumBytes $longFileCeiling `
                        -LimitCategory $LimitCategory
                    $longByteCount += $hashtableFileDigest.ByteCount
                    $strFileDigest = $hashtableFileDigest.Digest
                }
                $objMap['F:' + $strRelativePath] = ([string]$objFile.Length + ':' + $strFileDigest)
                $intFileCount++
            }
            # F4/H4: bound traversal on an independent counter (a worktree directory has no 'D:'
            # key). A traversed directory and a recorded relevant entry count; an omitted irrelevant
            # untracked entry does not, so unrelated untracked population no longer raises the limit.
            if ($boolEntryCounted) {
                $intEntryCount++
                if ($intEntryCount -gt $MaximumEntryCount) {
                    throw $LimitCategory
                }
            }
        }
    }
    return [ordered]@{
        Digest = Get-FramedStringMapDigest -StringMap $objMap
        EntryCount = $objMap.Count
        FileCount = $intFileCount
        ByteCount = $longByteCount
    }
}

function Get-GitAdministrativePathRecord {
    # .SYNOPSIS
    # Resolves the repository Git administrative paths without invoking Git.
    #
    # .DESCRIPTION
    # Accepts an ordinary .git directory or an ordinary bounded gitdir pointer
    # file. Resolves an optional bounded commondir pointer. Requires every
    # resolved administrative directory and ancestor to be ordinary.
    #
    # .PARAMETER RepositoryRoot
    # Validated absolute worktree root that owns the .git entry.
    #
    # .EXAMPLE
    # $hashtableGitPath = Get-GitAdministrativePathRecord -RepositoryRoot $strRoot
    #
    # # Returns GitEntry, GitDirectory, and CommonDirectory for a normal clone or worktree.
    #
    # .EXAMPLE
    # Get-GitAdministrativePathRecord -RepositoryRoot $strRootWithLinkedDotGit
    #
    # # Throws 'invalid-git-control' for a reparse-point .git entry.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Collections.Specialized.OrderedDictionary. Contains GitEntry,
    # GitDirectory, and CommonDirectory. Throws 'invalid-git-control' for a
    # missing, linked, malformed, oversized, or nonordinary control path.
    # Filesystem, decoding, and parameter-binding failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260814.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: RepositoryRoot
    param (
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot
    )

    $strGitEntry = [System.IO.Path]::Combine($RepositoryRoot, '.git')
    if (-not [System.IO.File]::Exists($strGitEntry) -and -not [System.IO.Directory]::Exists($strGitEntry)) {
        throw 'invalid-git-control'
    }
    $objGitAttributes = [System.IO.File]::GetAttributes($strGitEntry)
    if (($objGitAttributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw 'invalid-git-control'
    }
    if (($objGitAttributes -band [System.IO.FileAttributes]::Directory) -ne 0) {
        $strGitDirectory = Assert-OrdinaryRepositoryRoot -LiteralPath $strGitEntry
    } else {
        $strGitEntry = Assert-OrdinaryAbsoluteFile -LiteralPath $strGitEntry
        # Enforce the 4 KiB ceiling during the read: a hostile or corrupted gitdir
        # pointer could be arbitrarily large, and ReadAllBytes would allocate and read
        # all of it before a post-read size check, a denial-of-service against the
        # bounded-evidence contract.
        $arrGitEntryBytes = Read-BoundedFileContent -LiteralPath $strGitEntry -MaximumBytes 4096 -LimitCategory 'invalid-git-control'
        if ($arrGitEntryBytes.Length -eq 0) {
            throw 'invalid-git-control'
        }
        $strGitEntryText = $script:objUtf8Strict.GetString($arrGitEntryBytes).TrimEnd("`r", "`n")
        if ($strGitEntryText -notmatch '^gitdir: (.+)$' -or $Matches[1] -match '[\r\n]') {
            throw 'invalid-git-control'
        }
        $strGitDirectoryCandidate = $Matches[1]
        if (-not [System.IO.Path]::IsPathRooted($strGitDirectoryCandidate)) {
            $strGitDirectoryCandidate = Join-Path $RepositoryRoot $strGitDirectoryCandidate
        }
        $strGitDirectory = Assert-OrdinaryRepositoryRoot -LiteralPath (
            [System.IO.Path]::GetFullPath($strGitDirectoryCandidate)
        )
    }

    $strCommonMarker = Join-Path $strGitDirectory 'commondir'
    if ([System.IO.File]::Exists($strCommonMarker)) {
        $strCommonMarker = Assert-OrdinaryAbsoluteFile -LiteralPath $strCommonMarker
        # Enforce the 4 KiB ceiling during the read, as for the gitdir pointer above.
        $arrCommonBytes = Read-BoundedFileContent -LiteralPath $strCommonMarker -MaximumBytes 4096 -LimitCategory 'invalid-git-control'
        if ($arrCommonBytes.Length -eq 0) {
            throw 'invalid-git-control'
        }
        $strCommonText = $script:objUtf8Strict.GetString($arrCommonBytes).TrimEnd("`r", "`n")
        if ($strCommonText -match '[\r\n]') {
            throw 'invalid-git-control'
        }
        $strCommonCandidate = $strCommonText
        if (-not [System.IO.Path]::IsPathRooted($strCommonCandidate)) {
            $strCommonCandidate = Join-Path $strGitDirectory $strCommonCandidate
        }
        $strCommonDirectory = Assert-OrdinaryRepositoryRoot -LiteralPath (
            [System.IO.Path]::GetFullPath($strCommonCandidate)
        )
    } else {
        $strCommonDirectory = $strGitDirectory
    }
    return [ordered]@{
        GitEntry = $strGitEntry
        GitDirectory = $strGitDirectory
        CommonDirectory = $strCommonDirectory
    }
}

function Get-BoundedControlFileComponent {
    # .SYNOPSIS
    # Gets the framed evidence component for one single-file Git control input.
    #
    # .DESCRIPTION
    # Returns 'length:digest' for an ordinary regular file (rejecting a non-ordinary
    # entry and enforcing the 4 MiB component bound during the read), throws
    # 'invalid-git-control' when a directory occupies the slot, and returns 'absent'
    # for a genuinely empty slot (after Assert-UnoccupiedControlSlot refuses a dangling
    # symlink or other non-resolving occupant). This is the File.Exists / Directory.Exists
    # / unoccupied classification the control-evidence loops apply to every single-file
    # input, factored out so the coupled split-index snapshot hashes GitDirectory/index
    # with byte-identical semantics.
    #
    # .PARAMETER LiteralPath
    # Absolute literal control-input path to classify and hash.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String. 'length:digest' for an ordinary file or 'absent' for an empty slot.
    # Throws 'invalid-git-control' for a directory or dangling-symlink slot and
    # 'git-control-limit' above the 4 MiB bound. Filesystem, hashing, and
    # parameter-binding failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260816.3
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: LiteralPath
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath
    )

    $strPath = [System.IO.Path]::GetFullPath($LiteralPath)
    if ([System.IO.File]::Exists($strPath)) {
        [void](Assert-OrdinaryAbsoluteFile -LiteralPath $strPath)
        $objInfo = New-Object System.IO.FileInfo($strPath)
        return ([string]$objInfo.Length + ':' +
            (Get-BoundedFileDigest -LiteralPath $strPath -MaximumBytes 4194304 -LimitCategory 'git-control-limit').Digest)
    } elseif ([System.IO.Directory]::Exists($strPath)) {
        throw 'invalid-git-control'
    } else {
        Assert-UnoccupiedControlSlot -LiteralPath $strPath -Category 'invalid-git-control'
        return 'absent'
    }
}

function Get-EffectiveConfigComponent {
    # .SYNOPSIS
    # Gets the framed evidence component for one repository-local Git configuration file,
    # omitting only the proven path-irrelevant user.name and user.email.
    #
    # .DESCRIPTION
    # Classifies the slot exactly as Get-BoundedControlFileComponent does -- a directory
    # throws 'invalid-git-control', a genuinely empty slot returns 'absent' (after
    # Assert-UnoccupiedControlSlot refuses a dangling symlink), and an ordinary regular file is
    # validated (Assert-OrdinaryAbsoluteFile) and 4 MiB-bounded before it is read. For an
    # ordinary file it lists the file's own entries through Git's own parser
    # (git config --file <path> --no-includes -z --list), removes only the two proven
    # path-irrelevant keys user.name and user.email, and frames the remaining records -- in
    # Git's listed order, so a multi-valued key keeps its order -- with Get-FramedStringMapDigest.
    # Every other key, including a key this verifier does not recognize, is retained by default,
    # so a concurrent authorship edit (user.name/user.email) inside a control bracket cannot
    # raise a false git-control-drift while any read-relevant configuration race still does. This
    # is a default-include denylist, never an allowlist: a key is dropped only by being named
    # here, so an unknown or future path-relevant key is never dropped by omission. --file reads
    # only that one file (not the merged, system, or global config, which Invoke-GitRaw also
    # neutralizes); --no-includes does not open (interpret) an include target -- the include.*
    # key itself still lists and stays in the digest, and an active include is refused separately
    # by the include preflight before any read, so an external include cannot inject a setting.
    #
    # .PARAMETER LiteralPath
    # Absolute literal configuration-file path to classify and digest.
    #
    # .PARAMETER GitRecord
    # Fixed Git executable record used to run the neutralized enumeration.
    #
    # .PARAMETER WorkingDirectory
    # Working directory assigned to the enumeration process.
    #
    # .PARAMETER NativeCommandList
    # Native-command accounting list that receives one 'effective-config' record per read.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String. 'effective:<count>:<digest>' for an ordinary file or 'absent' for an empty
    # slot. Throws 'invalid-git-control' for a directory or dangling-symlink slot,
    # 'git-control-limit' above the 4 MiB bound, and 'native-command' on a malformed
    # enumeration. Filesystem, hashing, native, decoding, and parameter-binding failures
    # propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260818.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: LiteralPath
    #   Position 1: GitRecord
    #   Position 2: WorkingDirectory
    #   Position 3: NativeCommandList
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$GitRecord,

        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory,

        [Parameter(Mandatory = $true)]
        [System.Collections.IList]$NativeCommandList
    )

    $strPath = [System.IO.Path]::GetFullPath($LiteralPath)
    if ([System.IO.Directory]::Exists($strPath)) {
        throw 'invalid-git-control'
    }
    if (-not [System.IO.File]::Exists($strPath)) {
        Assert-UnoccupiedControlSlot -LiteralPath $strPath -Category 'invalid-git-control'
        return 'absent'
    }
    [void](Assert-OrdinaryAbsoluteFile -LiteralPath $strPath)
    if ((New-Object System.IO.FileInfo($strPath)).Length -gt 4194304) {
        throw 'git-control-limit'
    }
    # H5: track the in-flight native command in the script-scoped diagnostic fields before the
    # call (as Resolve-ActiveSharedIndexRecord and Get-HeadResolvedReferenceComponent do), so a
    # throw before it returns reports 'effective-config' with a null exit, not the prior command.
    $script:strNativeCommand = 'effective-config'
    $script:intNativeExit = $null
    $hashtableConfigResult = Invoke-GitRaw `
        -GitRecord $GitRecord `
        -WorkingDirectory $WorkingDirectory `
        -ArgumentList @('config', '--file', $strPath, '--no-includes', '-z', '--list')
    $NativeCommandList.Add([ordered]@{
        Name = 'effective-config'
        ExitCode = $hashtableConfigResult.ExitCode
        StdoutLength = $hashtableConfigResult.Stdout.Length
        StderrLength = $hashtableConfigResult.StderrLength
    })
    $script:intNativeExit = $hashtableConfigResult.ExitCode
    # Exit 0 lists entries; exit 1 means the file holds no entries (empty or comment-only);
    # any other exit is malformed and fails closed.
    if ($hashtableConfigResult.ExitCode -notin @(0, 1)) {
        throw 'native-command'
    }
    $objEffectiveEntries = New-Object System.Collections.Specialized.OrderedDictionary
    if ($hashtableConfigResult.ExitCode -eq 0) {
        # Records are key\nvalue, NUL-separated, exactly like the promisor probe. Keys are
        # already lowercased by Git, so the ordinal match on user.name/user.email is exact.
        $strConfigText = $script:objUtf8Strict.GetString($hashtableConfigResult.Stdout)
        $intEffectiveIndex = 0
        foreach ($strConfigRecord in $strConfigText.Split([char]0)) {
            if ($strConfigRecord.Length -eq 0) {
                continue
            }
            $intNewlineIndex = $strConfigRecord.IndexOf("`n")
            $strConfigKey = if ($intNewlineIndex -lt 0) {
                $strConfigRecord
            } else {
                $strConfigRecord.Substring(0, $intNewlineIndex)
            }
            if ($strConfigKey -ceq 'user.name' -or $strConfigKey -ceq 'user.email') {
                continue
            }
            $objEffectiveEntries[[string]$intEffectiveIndex] = $strConfigRecord
            $intEffectiveIndex++
        }
    }
    return 'effective:' + $objEffectiveEntries.Count + ':' +
        (Get-FramedStringMapDigest -StringMap $objEffectiveEntries)
}

function Resolve-ActiveSharedIndexRecord {
    # .SYNOPSIS
    # Resolves and validates the active split-index backing path for one snapshot read.
    #
    # .DESCRIPTION
    # Runs `git rev-parse --shared-index-path` (which reports the single backing the
    # current index references, or empty when the repository is not in split-index mode),
    # records the native command, and fails closed on a non-zero exit. Decodes the output
    # as strict UTF-8, removes one trailing newline, and treats empty output as the
    # not-split identity 'absent'. A non-empty value is validated before any file access:
    # it must hold no NUL and no interior newline, be at most 4096 characters, resolve
    # (relative to the repository root, so a `..` prefix is canonicalized) to a path whose
    # parent equals GitDirectory under ordinal case-sensitive comparison, carry the exact
    # canonical basename `sharedindex.<40-or-64-lowercase-hex>` matched ordinal,
    # case-sensitive, and culture-invariant, and be an ordinary regular file. The
    # structural checks (NUL, interior newline, over-length, out-of-root/wrong-parent, and
    # wrong-basename) throw 'invalid-git-control'; the ordinary-file check delegates to
    # Assert-OrdinaryAbsoluteFile, which throws 'invalid-ordinary-file' for a directory,
    # reparse point, or Unix special file, exactly as every other control-file check does.
    # The absolute canonical path is used only to open the file; the returned identity is
    # the host-symmetric validated basename.
    #
    # .PARAMETER GitRecord
    # Fixed Git executable record with Path, Length, and Sha256 evidence.
    #
    # .PARAMETER WorkingDirectory
    # Repository root assigned to the resolver process and used as the join base for its
    # relative output.
    #
    # .PARAMETER GitDirectory
    # Validated absolute per-worktree Git directory the backing file must sit directly in.
    #
    # .PARAMETER NativeCommandList
    # Native-command accounting list that receives one 'shared-index-path' record.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Collections.Specialized.OrderedDictionary. Contains Identity (the validated
    # basename, or 'absent' when not in split-index mode) and AbsolutePath (the canonical
    # path to open, or $null when absent). Throws 'native-command' on a non-zero resolver
    # exit, 'native-output-limit' on over-limit output, 'invalid-git-control' for a
    # malformed, out-of-root, wrong-parent, or wrong-basename value, and
    # 'invalid-ordinary-file' for a non-ordinary backing (via Assert-OrdinaryAbsoluteFile).
    # Native, decoding, filesystem, and parameter-binding failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260816.3
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: GitRecord
    #   Position 1: WorkingDirectory
    #   Position 2: GitDirectory
    #   Position 3: NativeCommandList
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$GitRecord,

        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory,

        [Parameter(Mandatory = $true)]
        [string]$GitDirectory,

        [Parameter(Mandatory = $true)]
        [System.Collections.IList]$NativeCommandList
    )

    # Track the in-flight native command in the script-scoped diagnostic fields, the same
    # way the main body brackets every Invoke-GitRaw, so a resolver failure reports
    # 'shared-index-path' rather than the previous command's name.
    $script:strNativeCommand = 'shared-index-path'
    $script:intNativeExit = $null
    $hashtableResolveResult = Invoke-GitRaw `
        -GitRecord $GitRecord `
        -WorkingDirectory $WorkingDirectory `
        -ArgumentList @('rev-parse', '--shared-index-path')
    $NativeCommandList.Add([ordered]@{
        Name = 'shared-index-path'
        ExitCode = $hashtableResolveResult.ExitCode
        StdoutLength = $hashtableResolveResult.Stdout.Length
        StderrLength = $hashtableResolveResult.StderrLength
    })
    $script:intNativeExit = $hashtableResolveResult.ExitCode
    if ($hashtableResolveResult.ExitCode -ne 0) {
        throw 'native-command'
    }
    $strResolved = $script:objUtf8Strict.GetString($hashtableResolveResult.Stdout)
    if ($strResolved.EndsWith("`n")) {
        $strResolved = $strResolved.Substring(0, $strResolved.Length - 1)
    }
    if ($strResolved.Length -eq 0) {
        # Empty output is the documented not-split-index result; no backing to hash.
        return [ordered]@{ Identity = 'absent'; AbsolutePath = $null }
    }
    if ($strResolved.IndexOf([char]0) -ge 0 -or
        $strResolved.IndexOf("`n") -ge 0 -or
        $strResolved.IndexOf("`r") -ge 0 -or
        $strResolved.Length -gt 4096) {
        throw 'invalid-git-control'
    }
    # Output is relative to the caller (the repository root), so join it to the root and
    # canonicalize; GetFullPath resolves a separate-git-dir `..` prefix.
    $strCanonical = [System.IO.Path]::GetFullPath((Join-Path $WorkingDirectory $strResolved))
    $strParent = [System.IO.Path]::GetDirectoryName($strCanonical)
    $strName = [System.IO.Path]::GetFileName($strCanonical)
    if ([string]::IsNullOrEmpty($strParent) -or $strParent -cne $GitDirectory) {
        throw 'invalid-git-control'
    }
    # The literal `sharedindex.` then exactly 40 (SHA-1) or 64 (SHA-256) lowercase-hex
    # object-name digits and nothing else, matched ordinal, case-sensitive, and
    # culture-invariant, so uppercase hex, a wrong-length name, a non-hex character, an
    # empty object name, a wrong prefix, or an extra suffix (for example `.lock`) all fail.
    if (-not [regex]::IsMatch(
        $strName,
        '^sharedindex\.(?:[0-9a-f]{40}|[0-9a-f]{64})$',
        [System.Text.RegularExpressions.RegexOptions]::CultureInvariant)) {
        throw 'invalid-git-control'
    }
    [void](Assert-OrdinaryAbsoluteFile -LiteralPath $strCanonical)
    return [ordered]@{ Identity = $strName; AbsolutePath = $strCanonical }
}

function Get-SplitIndexBracketedEvidence {
    # .SYNOPSIS
    # Gets an internally consistent snapshot coupling the index and its active split-index backing.
    #
    # .DESCRIPTION
    # Split-index mode stores the bulk of the index entries in a single
    # GitDirectory/sharedindex.<oid> file the index `link` extension names; rewriting the
    # backing rewrites the index, so the two always change together and a chimera (index
    # from one instant, backing from another) is not a valid state. This snapshot brackets
    # the pair: it hashes GitDirectory/index (index-before), resolves and validates the
    # active backing (path-before), hashes only that backing, resolves and validates the
    # backing again (path-after), hashes GitDirectory/index again (index-after), and
    # returns the coupled git-index and shared-index components only when index-before
    # equals index-after AND the two backing identities are equal. A change at any internal
    # seam breaks one of those equalities and throws 'git-control-drift', so no torn sample
    # is returned and the stale, unreferenced sharedindex.* files an all-prefix directory
    # scan would hash are never opened. Two resolver invocations run per snapshot.
    #
    # .PARAMETER AdministrativePathRecord
    # Validated GitEntry, GitDirectory, and CommonDirectory path record.
    #
    # .PARAMETER GitRecord
    # Fixed Git executable record used for the two backing resolutions.
    #
    # .PARAMETER WorkingDirectory
    # Repository root assigned to the resolver process and used as the join base.
    #
    # .PARAMETER NativeCommandList
    # Native-command accounting list that receives the two 'shared-index-path' records.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Collections.Specialized.OrderedDictionary. Contains the coupled 'git-index'
    # and 'shared-index' component values. Throws 'git-control-drift' on an intra-snapshot
    # index or backing-identity inequality; resolver, validation, hashing, and filesystem
    # failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260816.3
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: AdministrativePathRecord
    #   Position 1: GitRecord
    #   Position 2: WorkingDirectory
    #   Position 3: NativeCommandList
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$AdministrativePathRecord,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$GitRecord,

        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory,

        [Parameter(Mandatory = $true)]
        [System.Collections.IList]$NativeCommandList
    )

    $strGitDirectory = [string]$AdministrativePathRecord.GitDirectory
    $strIndexPath = Join-Path $strGitDirectory 'index'
    # 1. index-before
    $strIndexBefore = Get-BoundedControlFileComponent -LiteralPath $strIndexPath
    # 2-3. path-before: resolve and validate the one backing the index references.
    $objPathBefore = Resolve-ActiveSharedIndexRecord `
        -GitRecord $GitRecord `
        -WorkingDirectory $WorkingDirectory `
        -GitDirectory $strGitDirectory `
        -NativeCommandList $NativeCommandList
    # 4. Hash only the validated backing (host-symmetric basename, plus length and content).
    $strSharedIndex = 'absent'
    if ($null -ne $objPathBefore.AbsolutePath) {
        $objBackingInfo = New-Object System.IO.FileInfo($objPathBefore.AbsolutePath)
        $strSharedIndex = ($objPathBefore.Identity + ':' + [string]$objBackingInfo.Length + ':' +
            (Get-BoundedFileDigest -LiteralPath $objPathBefore.AbsolutePath `
                -MaximumBytes 4194304 -LimitCategory 'git-control-limit').Digest)
    }
    # 5. path-after: resolve and validate the backing again, independently.
    $objPathAfter = Resolve-ActiveSharedIndexRecord `
        -GitRecord $GitRecord `
        -WorkingDirectory $WorkingDirectory `
        -GitDirectory $strGitDirectory `
        -NativeCommandList $NativeCommandList
    # 6. index-after
    $strIndexAfter = Get-BoundedControlFileComponent -LiteralPath $strIndexPath
    # 7. Contribute the coupled components only when the snapshot is internally consistent:
    # a switch at any internal seam changes the index (its link extension) or the resolved
    # backing identity, so an unequal pair means the control surface moved mid-sample.
    if ($strIndexBefore -cne $strIndexAfter -or
        $objPathBefore.Identity -cne $objPathAfter.Identity) {
        throw 'git-control-drift'
    }
    return [ordered]@{
        'git-index' = $strIndexBefore
        'shared-index' = $strSharedIndex
    }
}

function Get-HeadResolvedReferenceComponent {
    # .SYNOPSIS
    # Gets the object name HEAD resolves to, the sole reference-evidence value.
    #
    # .DESCRIPTION
    # The staged read (git diff --cached) compares the index against the commit HEAD
    # resolves to and consumes no other reference. This helper brackets exactly that
    # object: it runs `git rev-parse --verify --quiet HEAD` through Invoke-GitRaw and
    # returns the resolved object name. git rev-parse resolves HEAD through the loose,
    # packed, and reftable back-ends, through per-worktree refs, and through symbolic-ref
    # chains, so this one storage-agnostic value replaces hashing the whole loose refs
    # tree, packed-refs, and the reftable trees, and is invariant to unrelated-ref churn
    # the staged read never consumes. The command is recorded under the native-command
    # name 'head-object'. Fail-closed handling:
    #   - Invoke-GitRaw itself throws native-command (Process.Start failure),
    #     native-output-limit (over the 4 MiB stream bound), or native-command-timeout;
    #     those propagate unchanged, so a broken or hung Git refuses the read.
    #   - a non-zero exit with empty output is the documented --verify --quiet result for
    #     an unborn or otherwise unresolvable HEAD; it returns 'unresolved', matching git
    #     diff --cached comparing against the empty tree so the staged read still succeeds.
    #   - a non-zero exit that still wrote output is undocumented and throws
    #     invalid-git-control.
    #   - a zero exit whose output, after one trailing newline is stripped, is not exactly
    #     40 (SHA-1) or 64 (SHA-256) lowercase-hex digits -- including empty, over-length,
    #     mixed-case, non-hex, or an embedded NUL/CR/LF -- throws invalid-git-control.
    # A change of the resolved object between the before and after control-surface reads
    # the caller brackets is caught as git-control-drift by that existing comparison,
    # exactly as for every other component; this helper reads once per bracket.
    #
    # .PARAMETER GitRecord
    # Fixed Git executable record with Path, Length, and Sha256 evidence.
    #
    # .PARAMETER WorkingDirectory
    # Repository root assigned to the rev-parse process.
    #
    # .PARAMETER NativeCommandList
    # Native-command accounting list that receives one 'head-object' record.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String. The lowercase 40- or 64-hex object name HEAD resolves to, or
    # 'unresolved' for an unborn or unresolvable HEAD. Throws 'invalid-git-control' for a
    # zero-exit malformed value or a non-zero exit that wrote output; native, decoding,
    # and parameter-binding failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260816.3
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: GitRecord
    #   Position 1: WorkingDirectory
    #   Position 2: NativeCommandList
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$GitRecord,

        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory,

        [Parameter(Mandatory = $true)]
        [System.Collections.IList]$NativeCommandList
    )

    # Track the in-flight native command in the script-scoped diagnostic fields, the same
    # way the main body brackets every Invoke-GitRaw, so a failure here reports
    # 'head-object' rather than the previous command's name.
    $script:strNativeCommand = 'head-object'
    $script:intNativeExit = $null
    $hashtableHeadResult = Invoke-GitRaw `
        -GitRecord $GitRecord `
        -WorkingDirectory $WorkingDirectory `
        -ArgumentList @('rev-parse', '--verify', '--quiet', 'HEAD')
    $NativeCommandList.Add([ordered]@{
        Name = 'head-object'
        ExitCode = $hashtableHeadResult.ExitCode
        StdoutLength = $hashtableHeadResult.Stdout.Length
        StderrLength = $hashtableHeadResult.StderrLength
    })
    $script:intNativeExit = $hashtableHeadResult.ExitCode
    $strResolved = $script:objUtf8Strict.GetString($hashtableHeadResult.Stdout)
    if ($strResolved.EndsWith("`n")) {
        $strResolved = $strResolved.Substring(0, $strResolved.Length - 1)
    }
    if ($hashtableHeadResult.ExitCode -ne 0) {
        # --verify --quiet exits non-zero and writes nothing for an unborn or otherwise
        # unresolvable HEAD; git diff --cached then compares against the empty tree, so the
        # staged read still succeeds and must not refuse. A non-zero exit that nonetheless
        # wrote output is undocumented and fails closed.
        if ($strResolved.Length -ne 0) {
            throw 'invalid-git-control'
        }
        return 'unresolved'
    }
    # A zero exit must yield exactly one lowercase-hex object name (40 SHA-1 or 64 SHA-256)
    # and nothing else, matched ordinal and culture-invariant, so uppercase hex, a
    # wrong-length value, a non-hex character, an empty value, or an embedded NUL/CR/LF all
    # fail closed as invalid-git-control.
    if (-not [regex]::IsMatch(
        $strResolved,
        '^(?:[0-9a-f]{40}|[0-9a-f]{64})$',
        [System.Text.RegularExpressions.RegexOptions]::CultureInvariant)) {
        throw 'invalid-git-control'
    }
    return $strResolved
}

function Get-GitControlSurfaceEvidence {
    # .SYNOPSIS
    # Gets bounded evidence for repository-local Git configuration and references.
    #
    # .DESCRIPTION
    # Hashes the .git pointer when present, the applicable local configuration
    # files, the staging index coupled with the active split-index backing, the
    # commondir pointer, the objects/info/alternates pointer, and -- only when
    # SampleWorktreeControlInput is set -- info/exclude and info/attributes, and --
    # only when IncludeReferenceEvidence is set -- the reference inputs HEAD and the
    # object HEAD resolves to (git rev-parse --verify --quiet HEAD via
    # Get-HeadResolvedReferenceComponent). The active per-worktree configuration
    # GitDirectory/config.worktree is hashed only when IncludeWorktreeConfigEvidence is
    # set, because Git reads that file only when extensions.worktreeConfig is enabled; a
    # repository with the extension unset or false never consults it, so sampling it would
    # let a stale, oversized, or concurrently changed config.worktree refuse or drift a
    # read that cannot depend on it. The main worktree's CommonDirectory/config.worktree is
    # not hashed (for the main worktree GitDirectory equals CommonDirectory, so the active
    # file is still covered). The index and its one
    # active split-index backing are sampled together by Get-SplitIndexBracketedEvidence,
    # which resolves the backing with `git rev-parse --shared-index-path` and brackets
    # the pair so no stale, unreferenced sharedindex.* file is hashed. info/exclude and
    # info/attributes drive only the worktree reads, so a staged-only verification omits
    # them. Uses labeled components so absent and present state cannot collide. The
    # resolved-HEAD component reads whichever ref back-end holds HEAD, so unrelated refs
    # and reflogs never enter it. Repository hooks are not hashed: no verifier command runs a hook and
    # core.fsmonitor is disabled, so hook contents cannot change the computed path set.
    #
    # .PARAMETER AdministrativePathRecord
    # Validated GitEntry, GitDirectory, and CommonDirectory path record.
    #
    # .PARAMETER IncludeReferenceEvidence
    # When set (a Staged or Both read), also samples the reference inputs HEAD and the
    # object HEAD resolves to. A working-only read consumes neither, so it passes $false
    # and a concurrent ref update raises no git-control-drift.
    #
    # .PARAMETER SampleWorktreeControlInput
    # When set (a working, untracked, or clean read), also samples info/exclude and
    # info/attributes. A staged-only read consumes neither, so it passes $false and a
    # nonordinary or concurrently changed info/exclude or info/attributes raises no
    # refusal or git-control-drift for a read that never opens it.
    #
    # .PARAMETER IncludeWorktreeConfigEvidence
    # When set, also samples the active GitDirectory/config.worktree. Git reads that file
    # only when extensions.worktreeConfig is enabled, so the caller passes the already
    # computed $boolWorktreeConfigEnabled: a repository with the extension unset or false
    # passes $false and a nonordinary, oversized, or concurrently changed config.worktree
    # raises no refusal or git-control-drift for a read that never consults it. The default
    # is $true, the fail-closed direction, so a caller that omits it over-samples (a safe
    # spurious refusal) rather than under-samples (a fail-open miss of a live file).
    #
    # .PARAMETER GitRecord
    # Fixed Git executable record used to resolve the active split-index backing.
    #
    # .PARAMETER WorkingDirectory
    # Repository root assigned to the split-index resolver and used as its join base.
    #
    # .PARAMETER NativeCommandList
    # Native-command accounting list that receives the split-index resolver records.
    #
    # .EXAMPLE
    # $hashtableControl = Get-GitControlSurfaceEvidence -AdministrativePathRecord $hashtableGitPath `
    #     -GitRecord $hashtableGit -WorkingDirectory $strRoot -NativeCommandList $listNativeChecks
    #
    # # Returns one digest and bounded component counts.
    #
    # .EXAMPLE
    # Get-GitControlSurfaceEvidence -AdministrativePathRecord $hashtableLinkedControl
    #
    # # Throws when a configuration entry is not ordinary.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Collections.Specialized.OrderedDictionary. Contains Digest and
    # ComponentCount. The Digest covers the staging index coupled with its active
    # split-index backing, the commondir pointer, the objects/info/alternates pointer,
    # and -- when SampleWorktreeControlInput is set -- info/exclude and info/attributes,
    # and -- when IncludeReferenceEvidence is set -- HEAD and the object HEAD resolves
    # to, so concurrent drift of any consumed path-set
    # read input raises git-control-drift. Filesystem, ordinary path, size-bound,
    # hashing, native, and parameter-binding failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260817.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: AdministrativePathRecord
    #   Position 1: IncludeReferenceEvidence
    #   Position 2: SampleWorktreeControlInput
    #   Position 3: IncludeWorktreeConfigEvidence
    #   Position 4: GitRecord
    #   Position 5: WorkingDirectory
    #   Position 6: NativeCommandList
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$AdministrativePathRecord,

        [bool]$IncludeReferenceEvidence = $true,

        [bool]$SampleWorktreeControlInput = $true,

        [bool]$IncludeWorktreeConfigEvidence = $true,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$GitRecord,

        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory,

        [Parameter(Mandatory = $true)]
        [System.Collections.IList]$NativeCommandList
    )

    $objComponents = New-Object 'System.Collections.Generic.SortedDictionary[string,string]' `
        ([System.StringComparer]::Ordinal)
    $strGitEntry = [string]$AdministrativePathRecord.GitEntry
    if ([System.IO.File]::Exists($strGitEntry)) {
        $objGitEntryInfo = New-Object System.IO.FileInfo((Assert-OrdinaryAbsoluteFile -LiteralPath $strGitEntry))
        $objComponents['git-entry'] = ([string]$objGitEntryInfo.Length + ':' +
            (Get-BoundedFileDigest -LiteralPath $strGitEntry -MaximumBytes 4194304 -LimitCategory 'git-control-limit').Digest)
    } else {
        [void](Assert-OrdinaryRepositoryRoot -LiteralPath $strGitEntry)
        $objComponents['git-entry'] = 'directory'
    }

    # Repository-local config, plus the single-file administrative inputs the path-set
    # reads depend on but the worktree tree evidence excludes. Only CommonDirectory/config
    # (common-config) is the repository-local configuration Git actually reads: Git resolves
    # it from $GIT_COMMON_DIR/config, and for the main worktree GitDirectory equals
    # CommonDirectory, so common-config covers it in both the main and the linked worktree.
    # GitDirectory/config is deliberately not sampled -- Git never reads $GIT_DIR/config for a
    # linked worktree, so hashing that inactive slot would let a stale symlink, oversized
    # file, or concurrent edit there refuse or drift a read that cannot depend on it (the same
    # class as the dropped common-config-worktree in C4 and the gated config.worktree in C7).
    # The active per-worktree
    # configuration is GitDirectory/config.worktree (worktree-config-worktree); it is
    # sampled only when IncludeWorktreeConfigEvidence is set (see the direct assignment
    # after the loop below), because Git reads it only when extensions.worktreeConfig is
    # enabled -- an unset or false extension never consults it, so hashing it could refuse
    # or drift a read that cannot depend on it. The
    # main worktree's CommonDirectory/config.worktree is not hashed, because Git reads only
    # the active worktree's file (for the main worktree GitDirectory equals CommonDirectory,
    # so the active file is still covered). info/exclude (the untracked read's
    # --exclude-standard set) and info/attributes (repository-local Git attributes that
    # change the working read via content normalization) drive only the worktree reads,
    # so they are appended only when SampleWorktreeControlInput is set. The reference
    # inputs the staged read consumes -- HEAD itself and the object HEAD resolves to -- are
    # not listed here: they are added in the dedicated reference-evidence block below, only
    # when IncludeReferenceEvidence is set. The commondir pointer is per-worktree
    # (GitDirectory); info/exclude and info/attributes are shared (CommonDirectory). The
    # staging index is not listed here: it is hashed coupled with its active split-index
    # backing by Get-SplitIndexBracketedEvidence below.
    # common-config is bracketed by its EFFECTIVE entries (Get-EffectiveConfigComponent),
    # which omit only the proven path-irrelevant user.name and user.email and retain every
    # other and every unknown key by default, so a concurrent authorship edit cannot raise a
    # false git-control-drift while any read-relevant configuration race still does. It is
    # assigned directly rather than through the whole-file loop below.
    $objComponents['common-config'] = Get-EffectiveConfigComponent `
        -LiteralPath (Join-Path $AdministrativePathRecord.CommonDirectory 'config') `
        -GitRecord $GitRecord `
        -WorkingDirectory $WorkingDirectory `
        -NativeCommandList $NativeCommandList
    $arrBoundedFileSpecifications = @(
        @('commondir-pointer', (Join-Path $AdministrativePathRecord.GitDirectory 'commondir')),
        @('objects-info-alternates', (Join-Path (Join-Path (Join-Path $AdministrativePathRecord.CommonDirectory 'objects') 'info') 'alternates'))
    ) + $(if ($SampleWorktreeControlInput) {
        @(
            @('info-exclude', (Join-Path (Join-Path $AdministrativePathRecord.CommonDirectory 'info') 'exclude')),
            @('info-attributes', (Join-Path (Join-Path $AdministrativePathRecord.CommonDirectory 'info') 'attributes'))
        )
    } else {
        @()
    })
    foreach ($arrSpecification in $arrBoundedFileSpecifications) {
        $objComponents[[string]$arrSpecification[0]] = Get-BoundedControlFileComponent `
            -LiteralPath ([string]$arrSpecification[1])
    }
    # config.worktree is the one conditional single-file control input, so it is assigned to
    # the component map directly rather than through a one-element $(if ...) append: the
    # array-subexpression operator enumerates a single-element append and flattens the
    # @('label', path) pair into two separate string specifications. Git reads config.worktree
    # only when extensions.worktreeConfig is enabled, so IncludeWorktreeConfigEvidence gates
    # it; a disabled repository never opens it, and sampling it would let a stale, oversized,
    # or concurrently changed file refuse or drift a read that cannot depend on it.
    if ($IncludeWorktreeConfigEvidence) {
        $objComponents['worktree-config-worktree'] = Get-EffectiveConfigComponent `
            -LiteralPath (Join-Path $AdministrativePathRecord.GitDirectory 'config.worktree') `
            -GitRecord $GitRecord `
            -WorkingDirectory $WorkingDirectory `
            -NativeCommandList $NativeCommandList
    }

    # HEAD's resolved object is the one reference input the staged read consumes: git
    # diff --cached compares the index against the commit HEAD resolves to and reads no
    # other ref. When IncludeReferenceEvidence is set, hash HEAD itself (git-head, so a
    # retarget of its symref target or a detached OID text is caught) and bracket the
    # object HEAD resolves to (head-resolved). git rev-parse resolves HEAD through the
    # loose, packed, and reftable back-ends, through per-worktree refs, and through symref
    # chains, so head-resolved replaces hashing the whole loose refs tree, packed-refs, and
    # the reftable trees with one storage-agnostic value that is invariant to unrelated-ref
    # churn the staged read never consumes, yet still changes when the object HEAD resolves
    # to moves. An unborn or unresolvable HEAD yields 'unresolved', matching git diff
    # --cached against the empty tree. A working-only read consumes neither, so it passes
    # $false and a concurrent ref update raises no git-control-drift for it. A change of
    # either value across the caller's before/after control bracket raises git-control-drift.
    # Repository hooks are not hashed: no verifier command runs a hook and core.fsmonitor is
    # disabled, so hook contents cannot change the computed path set.
    if ($IncludeReferenceEvidence) {
        $objComponents['git-head'] = Get-BoundedControlFileComponent `
            -LiteralPath (Join-Path $AdministrativePathRecord.GitDirectory 'HEAD')
        $objComponents['head-resolved'] = Get-HeadResolvedReferenceComponent `
            -GitRecord $GitRecord `
            -WorkingDirectory $WorkingDirectory `
            -NativeCommandList $NativeCommandList
    }

    # The staging index and its one active split-index backing are coupled: with
    # core.splitIndex, GitDirectory/index is a small file whose link extension names
    # exactly one GitDirectory/sharedindex.<oid>, and Git opens only that one. Sample the
    # pair as one internally consistent snapshot (index-before, resolved-and-validated
    # backing, index-after, with an intra-snapshot equality gate) rather than hashing
    # every sharedindex.* file in the directory, so a stale, unreferenced backing left
    # after a rewrite is neither hashed nor able to raise false drift, and the backing
    # hashed is always the one Git reads. The two resolver invocations are recorded in
    # NativeCommandList.
    $objSplitIndex = Get-SplitIndexBracketedEvidence `
        -AdministrativePathRecord $AdministrativePathRecord `
        -GitRecord $GitRecord `
        -WorkingDirectory $WorkingDirectory `
        -NativeCommandList $NativeCommandList
    $objComponents['git-index'] = $objSplitIndex['git-index']
    $objComponents['shared-index'] = $objSplitIndex['shared-index']
    return [ordered]@{
        Digest = Get-FramedStringMapDigest -StringMap $objComponents
        ComponentCount = $objComponents.Count
    }
}

function Get-PathSetControlInputDigest {
    # .SYNOPSIS
    # Digests the single-file control inputs the path-set reads depend on.
    #
    # .DESCRIPTION
    # Hashes only the single-file administrative inputs the working, untracked, and
    # staged reads consume -- the applicable config files, the commondir pointer, the
    # objects/info/alternates pointer, and -- only when SampleWorktreeControlInput is
    # set -- info/exclude and info/attributes, and -- only when IncludeReferenceEvidence
    # is set -- the reference inputs HEAD and the object HEAD resolves to -- together with the staging
    # index coupled to its one active split-index backing, into one ordinal-framed
    # digest. The active per-worktree configuration GitDirectory/config.worktree is hashed
    # only when IncludeWorktreeConfigEvidence is set, because Git reads it only when
    # extensions.worktreeConfig is enabled; a repository with the extension unset or false
    # never consults it. The main worktree's CommonDirectory/config.worktree is not hashed.
    # Each config/pointer
    # input is a single file, so each hash is atomic; the index and its active backing
    # are sampled together by Get-SplitIndexBracketedEvidence, whose intra-snapshot gate
    # keeps the coupled component internally consistent. Taken before the reads and again
    # as the verifier's final evidence action, the two digests bracket the read window,
    # closing the final-traversal tail that the aggregate control digest leaves for these
    # inputs. The live worktree cannot be bracketed this way and keep the convergence
    # guarantee.
    #
    # .PARAMETER AdministrativePathRecord
    # Validated GitEntry, GitDirectory, and CommonDirectory path record.
    #
    # .PARAMETER IncludeReferenceEvidence
    # When set (a Staged or Both read), also brackets the reference inputs HEAD and the
    # object HEAD resolves to. A working-only read consumes neither, so it passes $false.
    #
    # .PARAMETER SampleWorktreeControlInput
    # When set (a working, untracked, or clean read), also brackets info/exclude and
    # info/attributes. A staged-only read consumes neither, so it passes $false.
    #
    # .PARAMETER IncludeWorktreeConfigEvidence
    # When set, also brackets the active GitDirectory/config.worktree. Git reads that file
    # only when extensions.worktreeConfig is enabled, so the caller passes the already
    # computed $boolWorktreeConfigEnabled and a repository with the extension unset or false
    # passes $false. The default is $true, the fail-closed direction.
    #
    # .PARAMETER GitRecord
    # Fixed Git executable record used to resolve the active split-index backing.
    #
    # .PARAMETER WorkingDirectory
    # Repository root assigned to the split-index resolver and used as its join base.
    #
    # .PARAMETER NativeCommandList
    # Native-command accounting list that receives the split-index resolver records.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String. One framed digest over the single-file control inputs and the
    # coupled index/split-index snapshot. Filesystem, hashing, native, and
    # parameter-binding failures propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260817.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: AdministrativePathRecord
    #   Position 1: IncludeReferenceEvidence
    #   Position 2: SampleWorktreeControlInput
    #   Position 3: IncludeWorktreeConfigEvidence
    #   Position 4: GitRecord
    #   Position 5: WorkingDirectory
    #   Position 6: NativeCommandList
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$AdministrativePathRecord,

        [bool]$IncludeReferenceEvidence = $true,

        [bool]$SampleWorktreeControlInput = $true,

        [bool]$IncludeWorktreeConfigEvidence = $true,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$GitRecord,

        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory,

        [Parameter(Mandatory = $true)]
        [System.Collections.IList]$NativeCommandList
    )

    $objInputs = New-Object 'System.Collections.Generic.SortedDictionary[string,string]' `
        ([System.StringComparer]::Ordinal)
    # The staging index is not listed here: it is bracketed coupled with its active
    # split-index backing below. Only CommonDirectory/config (common-config) is the
    # repository-local configuration Git reads; GitDirectory/config is deliberately not
    # sampled, because Git never reads $GIT_DIR/config for a linked worktree and for the main
    # worktree it equals CommonDirectory/config, so common-config already covers it (F1, the
    # same class as C4/C7). The active per-worktree config is
    # worktree-config-worktree (GitDirectory/config.worktree), sampled only when
    # IncludeWorktreeConfigEvidence is set (see the direct assignment after the loop below)
    # because Git reads it only when extensions.worktreeConfig is enabled; info/exclude and
    # info/attributes are appended only for a worktree read. HEAD and the object HEAD
    # resolves to are added in the dedicated reference-evidence block after the loop, only
    # for a staged read, exactly as in Get-GitControlSurfaceEvidence.
    # common-config is bracketed by its EFFECTIVE entries (Get-EffectiveConfigComponent),
    # which omit only the proven path-irrelevant user.name and user.email and retain every
    # other and every unknown key by default, so a concurrent authorship edit cannot raise a
    # false git-control-drift while any read-relevant configuration race still does. It is
    # assigned directly rather than through the whole-file loop below.
    $objInputs['common-config'] = Get-EffectiveConfigComponent `
        -LiteralPath (Join-Path $AdministrativePathRecord.CommonDirectory 'config') `
        -GitRecord $GitRecord `
        -WorkingDirectory $WorkingDirectory `
        -NativeCommandList $NativeCommandList
    $arrSingleFileInputs = @(
        @('commondir-pointer', (Join-Path $AdministrativePathRecord.GitDirectory 'commondir')),
        @('objects-info-alternates', (Join-Path (Join-Path (Join-Path $AdministrativePathRecord.CommonDirectory 'objects') 'info') 'alternates'))
    ) + $(if ($SampleWorktreeControlInput) {
        @(
            @('info-exclude', (Join-Path (Join-Path $AdministrativePathRecord.CommonDirectory 'info') 'exclude')),
            @('info-attributes', (Join-Path (Join-Path $AdministrativePathRecord.CommonDirectory 'info') 'attributes'))
        )
    } else {
        @()
    })
    foreach ($arrSpecification in $arrSingleFileInputs) {
        # Get-BoundedControlFileComponent rejects a non-ordinary (reparse/symlink) file so
        # a concurrently substituted link cannot read outside the repository, and enforces
        # the same 4 MiB component bound during the read so a file that grows after its
        # length is sampled cannot be hashed without bound.
        $objInputs[[string]$arrSpecification[0]] = Get-BoundedControlFileComponent `
            -LiteralPath ([string]$arrSpecification[1])
    }
    # config.worktree is the one conditional single-file control input, so it is assigned to
    # the input map directly rather than through a one-element $(if ...) append: the
    # array-subexpression operator enumerates a single-element append and flattens the
    # @('label', path) pair into two separate string specifications. Git reads config.worktree
    # only when extensions.worktreeConfig is enabled, so IncludeWorktreeConfigEvidence gates
    # it exactly as in Get-GitControlSurfaceEvidence; a disabled repository never opens it.
    if ($IncludeWorktreeConfigEvidence) {
        $objInputs['worktree-config-worktree'] = Get-EffectiveConfigComponent `
            -LiteralPath (Join-Path $AdministrativePathRecord.GitDirectory 'config.worktree') `
            -GitRecord $GitRecord `
            -WorkingDirectory $WorkingDirectory `
            -NativeCommandList $NativeCommandList
    }
    # The reference inputs the staged read consumes: HEAD itself (git-head) and the object
    # HEAD resolves to (head-resolved, git rev-parse --verify --quiet HEAD via
    # Get-HeadResolvedReferenceComponent). rev-parse resolves HEAD through every ref
    # back-end and symref chain, so head-resolved is invariant to unrelated-ref churn the
    # staged read never consumes yet changes when the object HEAD resolves to moves; an
    # unborn or unresolvable HEAD yields 'unresolved'. Added only for a staged read,
    # exactly as in Get-GitControlSurfaceEvidence.
    if ($IncludeReferenceEvidence) {
        $objInputs['git-head'] = Get-BoundedControlFileComponent `
            -LiteralPath (Join-Path $AdministrativePathRecord.GitDirectory 'HEAD')
        $objInputs['head-resolved'] = Get-HeadResolvedReferenceComponent `
            -GitRecord $GitRecord `
            -WorkingDirectory $WorkingDirectory `
            -NativeCommandList $NativeCommandList
    }
    # Couple the staging index with its one active split-index backing, bracketed so no
    # stale, unreferenced sharedindex.* file perturbs the digest.
    $objSplitIndex = Get-SplitIndexBracketedEvidence `
        -AdministrativePathRecord $AdministrativePathRecord `
        -GitRecord $GitRecord `
        -WorkingDirectory $WorkingDirectory `
        -NativeCommandList $NativeCommandList
    $objInputs['git-index'] = $objSplitIndex['git-index']
    $objInputs['shared-index'] = $objSplitIndex['shared-index']
    return Get-FramedStringMapDigest -StringMap $objInputs
}

function ConvertFrom-NulIndexRecordStream {
    # .SYNOPSIS
    # Validates raw NUL-delimited Git index flag and path records.
    #
    # .DESCRIPTION
    # Requires each record to contain a flag tag, one ASCII space, and one
    # nonempty opaque path. When AllowUnsafeFlags is not set (a working-tree or
    # clean-working read, where assume-unchanged and skip-worktree can mask a
    # change), only the safe cached marker `H` is accepted and any other tag is
    # rejected as unsafe-index-state; when it is set (a staged-only read, whose
    # cached index-versus-HEAD comparison those flags do not affect), every
    # well-formed record contributes its path. A duplicate path is rejected as
    # malformed-index-records only when AllowUnsafeFlags is not set; when it is set, a
    # path that Git lists once per unmerged stage (stage 1, stage 2, and stage 3)
    # collapses into one key instead. A malformed frame and an excessive count are always
    # rejected, without decoding or printing path bytes.
    #
    # .PARAMETER Bytes
    # Complete raw output from `git ls-files -v -z`.
    #
    # .PARAMETER AllowUnsafeFlags
    # Accept assume-unchanged, skip-worktree, and other non-`H` index flags instead
    # of rejecting them. Set only for a staged-only read, whose index-versus-HEAD
    # comparison those flags do not affect; leave unset whenever a working-tree or
    # clean-working read is performed, so a masked working-tree change fails closed.
    #
    # .EXAMPLE
    # $objIndexKeys = ConvertFrom-NulIndexRecordStream -Bytes ([byte[]](0x48,0x20,0x61,0x00))
    #
    # # Returns the opaque key for path byte 0x61.
    #
    # .EXAMPLE
    # ConvertFrom-NulIndexRecordStream -Bytes ([byte[]](0x68,0x20,0x61,0x00))
    #
    # # Throws 'unsafe-index-state' for an assume-unchanged marker when
    # # AllowUnsafeFlags is not set.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Collections.Generic.HashSet[System.String]. One non-enumerated set
    # of opaque path keys. Throws 'malformed-index-records',
    # 'unsafe-index-state', or 'record-limit'. Allocation and binding failures
    # propagate.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260814.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: Bytes
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [byte[]]$Bytes,

        [switch]$AllowUnsafeFlags
    )

    $objKeys = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
    if ($Bytes.Length -eq 0) {
        return ,$objKeys
    }
    if ($Bytes[$Bytes.Length - 1] -ne 0) {
        throw 'malformed-index-records'
    }
    $intStart = 0
    for ($intIndex = 0; $intIndex -lt $Bytes.Length; $intIndex++) {
        if ($Bytes[$intIndex] -ne 0) {
            continue
        }
        $intLength = $intIndex - $intStart
        if ($intLength -lt 3 -or $Bytes[$intStart + 1] -ne 0x20) {
            throw 'malformed-index-records'
        }
        if (-not $AllowUnsafeFlags -and $Bytes[$intStart] -ne 0x48) {
            throw 'unsafe-index-state'
        }
        # Base64-encode the record slice in place with the offset/length overload
        # rather than copying it into a fresh byte[] first, which avoids a per-record
        # allocation and copy across the up-to-100,000-record ceiling.
        $strKey = [System.Convert]::ToBase64String($Bytes, $intStart + 2, $intLength - 2)
        # An unmerged path is listed once per conflict stage (stage 1, stage 2, and stage 3),
        # so `git ls-files -v -z` repeats its path key. That repeat is legitimate only when
        # AllowUnsafeFlags is set (a staged-only read); the repeated key then collapses into
        # the set with no throw. Whenever AllowUnsafeFlags is not set, only the safe cached
        # `H` marker reaches here, so a repeated path can only be a malformed stream and stays
        # refused. The 100,000-distinct-path ceiling below is unchanged either way.
        if (-not $objKeys.Add($strKey) -and -not $AllowUnsafeFlags) {
            throw 'malformed-index-records'
        }
        if ($objKeys.Count -gt 100000) {
            throw 'record-limit'
        }
        $intStart = $intIndex + 1
    }
    return ,$objKeys
}

function Add-KeySet {
    # .SYNOPSIS
    # Adds every source key to a target set.
    #
    # .DESCRIPTION
    # Mutates the supplied target HashSet by adding each string from the source
    # HashSet. Existing target keys remain present and duplicate Add results are
    # deliberately suppressed.
    #
    # .PARAMETER Target
    # Ordinal string HashSet that receives the source keys.
    #
    # .PARAMETER Source
    # String HashSet whose keys are enumerated into the target.
    #
    # .EXAMPLE
    # Add-KeySet -Target $objActualKeys -Source $objWorkingKeys
    #
    # # Adds all working keys to the actual-key set without producing output.
    #
    # .EXAMPLE
    # Add-KeySet -Target $objKeys -Source $objKeys
    #
    # # Leaves the set unchanged because every key already exists.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # None. The Target object is mutated in place. Enumeration, collection, and
    # parameter-binding failures are propagated.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: Target
    #   Position 1: Source
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.HashSet[string]]$Target,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [System.Collections.Generic.HashSet[string]]$Source
    )

    foreach ($strKey in $Source) {
        [void]$Target.Add($strKey)
    }
}

function Write-VerifierResult {
    # .SYNOPSIS
    # Writes the exact-path verifier result as one compact JSON line.
    #
    # .DESCRIPTION
    # Serializes the complete ordered verifier result to depth six without
    # pretty-printing. Writes one newline-terminated JSON document to stdout.
    #
    # .PARAMETER Result
    # Complete exact-path verifier result dictionary to serialize.
    #
    # .EXAMPLE
    # Write-VerifierResult -Result $hashtableResult
    #
    # # Writes one compact JSON result line to standard output and returns no pipeline output.
    #
    # .EXAMPLE
    # Write-VerifierResult -Result ([ordered]@{ Success = $true })
    #
    # # Writes {"Success":true} followed by the platform newline.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # None on the PowerShell success stream. Writes one System.String line to
    # standard output. Parameter-binding, JSON serialization, and console-write
    # failures are propagated.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Version: 1.0.20260814.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: Result
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Result
    )

    [Console]::Out.WriteLine(($Result | ConvertTo-Json -Depth 6 -Compress))
}

$strCategory = 'tool-failure'
$strNativeOutcome = 'NotApplicable'
# NativeCommand and NativeExit describe the in-flight native command together: name the
# command when it begins and clear its exit until the command returns and the exit is
# captured. A command that throws before it returns -- an Invoke-GitRaw Process.Start
# failure, the 4 MiB output limit, or the native-command timeout -- then leaves NativeExit
# null in the result instead of the previous command's exit.
$strNativeCommand = 'NotApplicable'
$intNativeExit = $null
$objExpectedKeys = $null
$objActualKeys = $null
$objWorkingKeys = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
$objStagedKeys = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
$objUntrackedKeys = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
$objIndexKeys = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
$listNativeChecks = New-Object 'System.Collections.Generic.List[object]'
$hashtableGitExecutable = $null
$hashtableControlBefore = $null
$hashtableControlAfter = $null
$hashtableWorktreeBefore = $null
$hashtableWorktreeAfter = $null
$boolEvidenceStable = $false
$intMissingCount = 0
$intUnexpectedCount = 0
$intExitCode = 1

try {
    Test-ScriptVersionParser
    Test-WorktreeDirectoryIdentityEvidence
    Test-IgnoredControlFileEvidence
    Test-EmbeddedRepositoryBoundaryEvidence
    Test-AncestorBoundaryValidation
    Test-PromisorRemoteEvidence
    Test-TrackedOnlyWorktreeEvidence
    Test-TrackedOnlyEntryCeiling
    Test-NativeExitResetInvariant
    Test-EffectiveConfigNativeExitReset
    $strSelfPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'Test-ExactGitPathSet.ps1'))
    $strSelfText = $script:objUtf8Strict.GetString([System.IO.File]::ReadAllBytes($strSelfPath))
    [void](Get-ScriptVersionRecord -ScriptText $strSelfText -ExpectedVersion $script:strVerifierVersion)

    $strRepositoryRoot = Assert-OrdinaryRepositoryRoot -LiteralPath $RepositoryRoot
    $objExpectedKeys = New-ExpectedPathKeySet -PathList $ExpectedPath
    $hashtableGitExecutable = Get-GitExecutableRecord -RequestedPath $GitExecutablePath
    $hashtableAdministrativePaths = Get-GitAdministrativePathRecord -RepositoryRoot $strRepositoryRoot

    # Refuse a repository-local include.path/includeIf BEFORE any in-repository Git
    # command, so a FIFO or malformed include target can never block or error the first
    # in-repo command (the ignored enumeration, the rev-parse boundary check, or the
    # split-index resolver) before this refusal runs. Git expands include directives while
    # it reads configuration during repository setup for every in-repo command, and
    # --no-includes on a `git config` subcommand does NOT stop that setup-time expansion,
    # so detect includes WITHOUT repository discovery: read each configuration file Git
    # consults for this worktree through an empty, neutral Git directory
    # (git --git-dir=<neutral> config --file <path> --no-includes ...), which reports the
    # include key WITHOUT expanding (opening) its target. No -c override disables include
    # expansion and the resolved targets cannot be enumerated and snapshotted portably, so
    # refuse (fail closed) on any include directive, for every mode. System and global
    # config are already excluded by the neutralized Invoke-GitRaw environment; a fresh
    # checkout's local config has no includes.
    $strNeutralGitDirectory = [System.IO.Path]::Combine(
        [System.IO.Path]::GetTempPath(),
        ('exactgitpathset-neutral-' + [System.Guid]::NewGuid().ToString('N')))
    [void][System.IO.Directory]::CreateDirectory($strNeutralGitDirectory)
    try {
        $strCommonConfigPath = [System.IO.Path]::GetFullPath(
            (Join-Path $hashtableAdministrativePaths.CommonDirectory 'config'))
        # extensions.worktreeConfig lives in the common config and decides whether Git
        # reads GitDirectory/config.worktree. Read it the same neutral way so
        # config.worktree is checked for includes exactly when Git would consult it.
        $boolWorktreeConfigEnabled = $false
        if ([System.IO.File]::Exists($strCommonConfigPath)) {
            # F3: refuse a non-ordinary common config (a FIFO/socket/device satisfies
            # File.Exists) before 'git config --file' opens it, because opening a FIFO blocks
            # until a writer appears. Assert-OrdinaryAbsoluteFile inspects attributes and the
            # UnixMode type without opening the path, matching Get-EffectiveConfigComponent.
            [void](Assert-OrdinaryAbsoluteFile -LiteralPath $strCommonConfigPath)
            $strNativeCommand = 'worktree-config-extension'
            $intNativeExit = $null
            $hashtableWorktreeConfigResult = Invoke-GitRaw `
                -GitRecord $hashtableGitExecutable `
                -WorkingDirectory $strNeutralGitDirectory `
                -ArgumentList @(('--git-dir=' + $strNeutralGitDirectory), 'config', '--file', $strCommonConfigPath,
                    '--no-includes', '--type=bool', '--get', 'extensions.worktreeConfig')
            $listNativeChecks.Add([ordered]@{
                Name = $strNativeCommand
                ExitCode = $hashtableWorktreeConfigResult.ExitCode
                StdoutLength = $hashtableWorktreeConfigResult.Stdout.Length
                StderrLength = $hashtableWorktreeConfigResult.StderrLength
            })
            $intNativeExit = $hashtableWorktreeConfigResult.ExitCode
            # Exit 0 with a boolean value means the extension is present; exit 1 means the
            # key is absent (the common case). Any other exit is malformed and fails closed.
            if ($intNativeExit -notin @(0, 1)) {
                throw 'native-command'
            }
            if ($intNativeExit -eq 0) {
                $boolWorktreeConfigEnabled = (
                    $script:objUtf8Strict.GetString($hashtableWorktreeConfigResult.Stdout).Trim() -ceq 'true')
            }
        }
        # The distinct configuration files Git reads for this worktree. Only the common
        # config (CommonDirectory/config) seeds the scan: Git resolves the repository-local
        # config from $GIT_COMMON_DIR/config, and for the main worktree GitDirectory equals
        # CommonDirectory, so the common config covers it in both the main and the linked
        # worktree. GitDirectory/config is deliberately not scanned -- Git never reads
        # $GIT_DIR/config for a linked worktree, so an include directive there cannot inject a
        # read-relevant setting yet would otherwise raise a false git-config-include-active;
        # this matches the control-input digest, which for the same reason does not sample
        # GitDirectory/config (F1, the same dependency scope as C4/C7). GitDirectory/config.worktree
        # is read only when extensions.worktreeConfig is enabled. A duplicate full path is
        # probed once.
        $listConfigFilePath = New-Object 'System.Collections.Generic.List[string]'
        foreach ($strCandidateConfigPath in @(
            $strCommonConfigPath
        )) {
            if ([System.IO.File]::Exists($strCandidateConfigPath) -and
                -not $listConfigFilePath.Contains($strCandidateConfigPath)) {
                $listConfigFilePath.Add($strCandidateConfigPath)
            }
        }
        if ($boolWorktreeConfigEnabled) {
            $strWorktreeConfigFilePath = [System.IO.Path]::GetFullPath(
                (Join-Path $hashtableAdministrativePaths.GitDirectory 'config.worktree'))
            if ([System.IO.File]::Exists($strWorktreeConfigFilePath) -and
                -not $listConfigFilePath.Contains($strWorktreeConfigFilePath)) {
                $listConfigFilePath.Add($strWorktreeConfigFilePath)
            }
        }
        foreach ($strConfigFilePath in $listConfigFilePath) {
            # F3: refuse a non-ordinary config file (a FIFO/socket/device satisfies File.Exists)
            # immediately before 'git config --file' opens it, so a special file swapped in after
            # the list was built cannot block the read. Matches Get-EffectiveConfigComponent.
            [void](Assert-OrdinaryAbsoluteFile -LiteralPath $strConfigFilePath)
            $strNativeCommand = 'include-config'
            $intNativeExit = $null
            $hashtableIncludeResult = Invoke-GitRaw `
                -GitRecord $hashtableGitExecutable `
                -WorkingDirectory $strNeutralGitDirectory `
                -ArgumentList @(('--git-dir=' + $strNeutralGitDirectory), 'config', '--file', $strConfigFilePath,
                    '--no-includes', '-z', '--name-only', '--get-regexp', '^include(\.|if\.)')
            $listNativeChecks.Add([ordered]@{
                Name = $strNativeCommand
                ExitCode = $hashtableIncludeResult.ExitCode
                StdoutLength = $hashtableIncludeResult.Stdout.Length
                StderrLength = $hashtableIncludeResult.StderrLength
            })
            $intNativeExit = $hashtableIncludeResult.ExitCode
            # 'git config --get-regexp' exits 1 when no key matches (the hermetic case) and
            # 0 when an include/includeIf key is present. Any match means an unbracketed
            # external include could inject a read-relevant setting, so refuse.
            if ($intNativeExit -notin @(0, 1)) {
                throw 'native-command'
            }
            if ($intNativeExit -eq 0) {
                throw 'git-config-include-active'
            }
        }
    } finally {
        if ([System.IO.Directory]::Exists($strNeutralGitDirectory)) {
            [System.IO.Directory]::Delete($strNeutralGitDirectory, $true)
        }
    }

    # The staged read (git diff --cached) is index-versus-HEAD and never consumes the
    # worktree, so a staged-only verification must not scan or bracket it: an ordinary
    # tracked symlink, or any worktree state exceeding the tree walker's limits, would
    # otherwise refuse (worktree-link/worktree-limit) a read that does not depend on it.
    # Gather and bracket the worktree evidence only when a working-tree or clean-working
    # read is requested.
    $boolWorktreeReadRequested = ($Mode -in @('Working', 'Both')) -or $RequireCleanWorkingAgainstIndex
    # HEAD and the ref trees are consumed only by the staged read (git diff --cached
    # resolves HEAD against the index); a working-only read is worktree-versus-index plus
    # an index-reading ls-files, neither of which consumes a reference. Sample the
    # reference evidence in the control brackets only for a staged read, so a concurrent
    # ref update raises no git-control-drift for a working-only verification.
    $boolIncludeReferenceEvidence = ($Mode -in @('Staged', 'Both'))
    # Enumerate the gitignored top-level entries once, before the reads, so the worktree
    # walk omits what the tracked working diff and the --exclude-standard untracked read
    # already omit. An ignored tree (for example node_modules) that holds a symlink,
    # special file, or over-limit content would otherwise refuse an empty working set.
    # --directory collapses a fully-ignored directory to one trailing-slashed entry. The
    # identical set is reused across the before/after/confirm walks so the drift
    # comparison stays apples-to-apples; a new ignored tree created mid-window is not in
    # the set and the later walk fails closed, the safe direction. Only a worktree read
    # walks the tree, so a staged-only read skips this.
    $arrIgnoredExcludedPath = @()
    if ($boolWorktreeReadRequested) {
        $strNativeCommand = 'ignored'
        $intNativeExit = $null
        $hashtableIgnoredResult = Invoke-GitRaw `
            -GitRecord $hashtableGitExecutable `
            -WorkingDirectory $strRepositoryRoot `
            -ArgumentList @('ls-files', '--others', '--ignored', '--exclude-standard', '--directory', '-z', '--')
        $listNativeChecks.Add([ordered]@{
            Name = $strNativeCommand
            ExitCode = $hashtableIgnoredResult.ExitCode
            StdoutLength = $hashtableIgnoredResult.Stdout.Length
            StderrLength = $hashtableIgnoredResult.StderrLength
        })
        $intNativeExit = $hashtableIgnoredResult.ExitCode
        if ($intNativeExit -ne 0) {
            throw 'native-command'
        }
        $arrIgnoredExcludedPath = ConvertTo-IgnoredExclusionPath `
            -Bytes $hashtableIgnoredResult.Stdout -RepositoryRoot $strRepositoryRoot
    }
    # Enumerate the initialized submodule roots once, before the reads, so the worktree
    # walk omits them. An initialized submodule is an ordinary subdirectory holding a
    # nested repository; the parent's reads never consume its internals (the working and
    # clean diffs pass --ignore-submodules=all and ls-files --others does not report
    # gitlink content), so a symlink, special file, or over-limit content inside it would
    # otherwise refuse an otherwise clean parent verification. The gitlink object id stays
    # covered by the git-index control component, so excluding the worktree directory does
    # not hide a staged gitlink change. Only a worktree read walks the tree, so a
    # staged-only read skips this.
    $arrSubmoduleExcludedPath = @()
    # The tracked repository-relative path set (F3) is derived once, below, from the same
    # gitlinks git ls-files --stage output; it stays $null for a staged-only read that does
    # not walk the worktree, and the worktree walks are the only consumers.
    $objTrackedRelativePath = $null
    if ($boolWorktreeReadRequested) {
        $strNativeCommand = 'gitlinks'
        $intNativeExit = $null
        $hashtableGitlinkResult = Invoke-GitRaw `
            -GitRecord $hashtableGitExecutable `
            -WorkingDirectory $strRepositoryRoot `
            -ArgumentList @('ls-files', '-z', '--stage', '--')
        $listNativeChecks.Add([ordered]@{
            Name = $strNativeCommand
            ExitCode = $hashtableGitlinkResult.ExitCode
            StdoutLength = $hashtableGitlinkResult.Stdout.Length
            StderrLength = $hashtableGitlinkResult.StderrLength
        })
        $intNativeExit = $hashtableGitlinkResult.ExitCode
        if ($intNativeExit -ne 0) {
            throw 'native-command'
        }
        $arrSubmoduleExcludedPath = ConvertTo-SubmoduleExclusionPath `
            -Bytes $hashtableGitlinkResult.Stdout -RepositoryRoot $strRepositoryRoot
        # F3: build the tracked repository-relative path set one time from the same
        # git ls-files --stage output (no extra Git read). The before/after/confirm worktree
        # walks share it, so each hashes and byte-limits only tracked ordinary files while an
        # untracked ordinary file is recorded by name and existence only; its content -- which
        # no path-set read consumes -- then cannot raise a false worktree-limit or drift.
        $objTrackedRelativePath = ConvertTo-TrackedRelativePathSet -Bytes $hashtableGitlinkResult.Stdout
    }
    # The identical exclusion set (gitignored top-level entries plus initialized submodule
    # roots) is reused across the before/after/confirm walks so the drift comparison stays
    # apples-to-apples; a tree created mid-window is absent from the set and the later walk
    # fails closed, the safe direction.
    $arrWorktreeExcludedPath = @($arrIgnoredExcludedPath) + @($arrSubmoduleExcludedPath)
    $hashtableControlBefore = Get-GitControlSurfaceEvidence `
        -AdministrativePathRecord $hashtableAdministrativePaths `
        -IncludeReferenceEvidence $boolIncludeReferenceEvidence `
        -SampleWorktreeControlInput $boolWorktreeReadRequested `
        -IncludeWorktreeConfigEvidence $boolWorktreeConfigEnabled `
        -GitRecord $hashtableGitExecutable `
        -WorkingDirectory $strRepositoryRoot `
        -NativeCommandList $listNativeChecks
    $hashtableWorktreeBefore = if ($boolWorktreeReadRequested) {
        Get-TreeEvidence `
            -RootPath $strRepositoryRoot `
            -ExcludedPath $hashtableAdministrativePaths.GitEntry `
            -AdditionalExcludedPath $arrWorktreeExcludedPath `
            -WorktreeClassification `
            -TrackedRelativePath $objTrackedRelativePath `
            -OmitUntrackedEvidence:(-not ($Mode -in @('Working', 'Both')))
    } else {
        $null
    }
    # Atomic single-file bracket for every single-file control input the path-set
    # reads consume (index, HEAD, head-resolved, info/exclude, info/attributes, config,
    # commondir). Get-GitControlSurfaceEvidence hashes each as one component of a
    # multi-file traversal, so a change to any one during that traversal's own tail
    # (after that component is hashed, before the scan completes) can leave the
    # aggregate digest stale -- for example info/exclude drives the untracked read's
    # --exclude-standard set. Each input is a single file, so hashing them here
    # (before the reads) and again as the verifier's final evidence action brackets
    # the reads with atomic reads: a change across them raises git-control-drift.
    # This bracket, like every evidence pass, is itself a sequential read, so a
    # single-file input changed after its own hash but before the pass completes --
    # and any change to a tree-shaped input (the split-index backing files) or the
    # live worktree, which git reads in place, during the final
    # converged traversal -- is the irreducible residual: no portable mechanism reads
    # a live multi-file surface atomically, and adding another recheck only moves the
    # tail to that recheck (infinite regress). The residual is bounded to a concurrent
    # second writer racing a sub-second window, which single-actor CI does not have;
    # against accidental drift the convergence is conclusive.
    $strControlInputDigestBefore = Get-PathSetControlInputDigest `
        -AdministrativePathRecord $hashtableAdministrativePaths `
        -IncludeReferenceEvidence $boolIncludeReferenceEvidence `
        -SampleWorktreeControlInput $boolWorktreeReadRequested `
        -IncludeWorktreeConfigEvidence $boolWorktreeConfigEnabled `
        -GitRecord $hashtableGitExecutable `
        -WorkingDirectory $strRepositoryRoot `
        -NativeCommandList $listNativeChecks

    $strNativeCommand = 'repository-root'
    $intNativeExit = $null
    $hashtableRootResult = Invoke-GitRaw `
        -GitRecord $hashtableGitExecutable `
        -WorkingDirectory $strRepositoryRoot `
        -ArgumentList @('rev-parse', '--is-inside-work-tree', '--show-prefix')
    $listNativeChecks.Add([ordered]@{
        Name = $strNativeCommand
        ExitCode = $hashtableRootResult.ExitCode
        StdoutLength = $hashtableRootResult.Stdout.Length
        StderrLength = $hashtableRootResult.StderrLength
    })
    $intNativeExit = $hashtableRootResult.ExitCode
    if ($intNativeExit -ne 0) {
        throw 'native-command'
    }
    $arrRootExpected = [byte[]](0x74, 0x72, 0x75, 0x65, 0x0A, 0x0A)
    if ([System.Convert]::ToBase64String($hashtableRootResult.Stdout) -cne
        [System.Convert]::ToBase64String($arrRootExpected)) {
        throw 'repository-boundary'
    }

    # Refuse a partial clone / promisor remote before any read. A partial clone marks
    # its remote with remote.<name>.promisor (and remote.<name>.partialclonefilter, and
    # on some versions extensions.partialClone), and Git will lazily fetch a missing
    # object from that promisor remote on demand during a read -- resolving HEAD's tree
    # for a staged diff, or an absent index blob for a working diff. That fetch runs an
    # external transport (honoring remote.<name>.uploadpack, which can execute a
    # configured wrapper), can reach the network or block, and draws on an object
    # source that sits outside every hashed control digest, so a converged success could
    # depend on an external store the snapshot cannot bracket. No -c override disables
    # lazy fetching on every supported Git version, so refuse (fail closed) when a
    # promisor remote is configured. An ordinary clone has none. Modeled on the
    # git-alternates-active refusal, and unconditional because both the working and the
    # staged reads can trigger the fetch.
    # Anchor the name regex to Git's actual promisor/partial-clone keys --
    # remote.<name>.promisor, remote.<name>.partialclonefilter, and
    # extensions.partialClone -- so an unrelated custom key such as foo.promisory does
    # not false-match and refuse every mode. --no-includes keeps an external include
    # from being expanded (opened) during this probe. The query returns key\nvalue
    # records (no --name-only) so the boolean value is available: an ordinary
    # repository can explicitly set remote.<name>.promisor=false to disable an
    # inherited promisor, which must not be treated as an active promisor remote.
    $strNativeCommand = 'promisor-config'
    $intNativeExit = $null
    $hashtablePromisorResult = Invoke-GitRaw `
        -GitRecord $hashtableGitExecutable `
        -WorkingDirectory $strRepositoryRoot `
        -ArgumentList @('config', '--no-includes', '-z', '--get-regexp',
            '^(remote\..*\.(promisor|partialclonefilter)|extensions\.partialclone)$')
    $listNativeChecks.Add([ordered]@{
        Name = $strNativeCommand
        ExitCode = $hashtablePromisorResult.ExitCode
        StdoutLength = $hashtablePromisorResult.Stdout.Length
        StderrLength = $hashtablePromisorResult.StderrLength
    })
    $intNativeExit = $hashtablePromisorResult.ExitCode
    # 'git config --get-regexp' exits 1 when no key matches (the ordinary-clone case)
    # and 0 when a promisor or partial-clone key is present.
    if ($intNativeExit -notin @(0, 1)) {
        throw 'native-command'
    }
    if ($intNativeExit -eq 0) {
        # Records are key\nvalue, NUL-separated. Test-PromisorRemoteActive collapses duplicate
        # remote.<name>.promisor definitions to each remote's effective last value (Git resolves
        # a boolean to the last value), refuses extensions.partialClone unconditionally, treats a
        # remote.<name>.partialclonefilter as inert, and fails closed on a valueless, empty, or
        # malformed value. An ordinary clone that sets remote.<name>.promisor=false to disable an
        # inherited promisor is therefore not refused, even when an earlier promisor=true is
        # superseded by a later promisor=false in the same record stream.
        if (Test-PromisorRemoteActive -PromisorRecordBytes $hashtablePromisorResult.Stdout) {
            throw 'git-promisor-remote'
        }
    }

    # F2: this alternates/object-store preflight runs before the filter-driver attr pathspec
    # query below, as well as before the working, staged, and clean reads. The attr query
    # (git ls-files --stage -- ':(attr:filter=...)') evaluates .gitattributes and can resolve a
    # tracked .gitattributes blob from the object store when the worktree copy is absent, so it
    # too can open an alternates-backed or special/FIFO object and block; validating the store
    # ordinary here refuses such a store promptly with the accurate category instead of hanging
    # the attr query or misreporting it as git-filter-active.
    #
    # The working, staged, and clean reads all resolve tracked content through the local
    # object database: the staged read resolves HEAD's commit and tree, and a worktree-
    # versus-index read (the working and the -RequireCleanWorkingAgainstIndex clean reads)
    # reads an index blob object whenever a tracked file's stat no longer matches the index.
    # That database may include an external store named by objects/info/alternates (for
    # example a 'git clone --shared' repository) or a redirected objects directory, and on
    # Unix a loose object or pack file that is a FIFO/socket/device would make a read block
    # opening it. The object store sits outside the hashed control surface and the
    # convergence bracket, so another process can redirect or remove it after a read while
    # every control and worktree digest still converges, yielding a success whose path set no
    # longer reproduces. It cannot be snapshotted portably, so refuse (fail closed) before any
    # read when the comparison depends on an external or non-ordinary object store. An
    # ordinary clone has no alternates file and a plain objects tree of ordinary files and is
    # unaffected. objects/info/alternates is hashed as a control input in
    # Get-GitControlSurfaceEvidence and Get-PathSetControlInputDigest, so a mid-window change
    # to it trips git-control-drift.
    $strAlternatesPath = [System.IO.Path]::Combine(
        [string]$hashtableAdministrativePaths.CommonDirectory, 'objects', 'info', 'alternates')
    if ([System.IO.File]::Exists($strAlternatesPath)) {
        # Validate the alternates path as an ordinary regular file before reading its length.
        # On Unix a FIFO/socket/device satisfies File.Exists and reports zero length, so the
        # length test alone would bypass this refusal; a read would then open the FIFO and
        # block forever waiting for a writer, even when every required object exists locally.
        # Assert-OrdinaryAbsoluteFile inspects attributes and the UnixMode type without opening
        # the path, so it rejects the special types (invalid-ordinary-file) and cannot itself
        # hang; malformed administrative state then fails promptly instead of hanging.
        [void](Assert-OrdinaryAbsoluteFile -LiteralPath $strAlternatesPath)
        if ((New-Object System.IO.FileInfo($strAlternatesPath)).Length -gt 0) {
            throw 'git-alternates-active'
        }
    }
    # Reject an external or redirected object store, but allow a Unix special-file object. If
    # CommonDirectory/objects -- or a child such as objects/pack, objects/<fanout>, or an
    # individual pack/loose object -- is a reparse point to a location outside the repository,
    # a read resolves objects from that external store (a route beyond the alternates file and
    # a promisor remote) and succeeds silently, which no timeout can catch, so the reparse-point
    # refusal stays. The objects tree is not bracketed by the control digests, so its later
    # removal or redirection would not trip git-control-drift; validate it here and refuse a
    # reparse or non-directory object root, and any reparse point beneath it, before any read.
    # A Unix special file (FIFO/socket/device) beneath objects is NOT refused here
    # (-AllowUnixSpecialFile): it can harm a read only when the read opens it, and such a read
    # blocks to the Invoke-GitRaw native-command timeout, or fails zlib inflation and returns
    # native-command -- both fail-closed, and exactly the backstop already relied on for a
    # special file substituted after this one-time pre-read scan. An unreferenced special-file
    # object that no command opens is therefore not a reason to refuse an otherwise correct
    # repository. An ordinary clone has a plain objects tree of ordinary files and is unaffected.
    $strObjectsPath = [System.IO.Path]::GetFullPath(
        (Join-Path $hashtableAdministrativePaths.CommonDirectory 'objects'))
    if ([System.IO.Directory]::Exists($strObjectsPath)) {
        $objObjectsInfo = New-Object System.IO.DirectoryInfo($strObjectsPath)
        if (($objObjectsInfo.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw 'git-object-store-nonordinary'
        }
        Assert-OrdinaryTreeUnder -RootPath $strObjectsPath -LimitCategory 'git-object-store-nonordinary' -AllowUnixSpecialFile
    } elseif ([System.IO.File]::Exists($strObjectsPath)) {
        throw 'git-object-store-nonordinary'
    } else {
        Assert-UnoccupiedControlSlot -LiteralPath $strObjectsPath -Category 'git-object-store-nonordinary'
    }

    if (($Mode -in @('Working', 'Both')) -or $RequireCleanWorkingAgainstIndex) {
        # A worktree-versus-index diff (the working and clean reads below) makes Git run a
        # clean or long-running process filter driver for a path whose 'filter' attribute
        # names a driver with a configured clean/process command. That driver is an external
        # program, outside the hashed evidence, so its output -- and thus the read -- can
        # change while the config that names it, the attributes that assign it, the index, and
        # both evidence digests all stay equal. '--no-textconv' disables only diff textconv,
        # not clean/process, and no config or command-line override neutralizes an arbitrarily
        # named driver assigned by an in-tree .gitattributes.
        #
        # A driver runs only for a path whose 'filter' attribute selects it, so a configured
        # but dormant driver (for example filter.lfs.clean/.process with no tracked path
        # carrying filter=lfs) cannot affect any compared path. Probe the repository-local
        # filter config, collect the capable drivers (those with a clean or process command),
        # and ask Git through its own attribute engine whether any tracked path selects each
        # one. Refuse (fail closed) only for an active driver -- or one that cannot be proved
        # dormant -- and allow a dormant driver. The probe and the per-driver query run in the
        # same neutralized environment as the reads (no system or global config), so a
        # developer's global Git LFS drivers are already excluded and never trip it; only a
        # repository-local clean or process driver that a tracked path selects refuses.
        $strNativeCommand = 'filter-config'
        $intNativeExit = $null
        $hashtableFilterResult = Invoke-GitRaw `
            -GitRecord $hashtableGitExecutable `
            -WorkingDirectory $strRepositoryRoot `
            -ArgumentList @('config', '-z', '--name-only', '--get-regexp', '^filter\.')
        $listNativeChecks.Add([ordered]@{
            Name = $strNativeCommand
            ExitCode = $hashtableFilterResult.ExitCode
            StdoutLength = $hashtableFilterResult.Stdout.Length
            StderrLength = $hashtableFilterResult.StderrLength
        })
        $intNativeExit = $hashtableFilterResult.ExitCode
        # 'git config --get-regexp' exits 1 when no key matches; that is the common
        # hermetic case (no repository-local filter driver) and is not a failure.
        if ($intNativeExit -notin @(0, 1)) {
            throw 'native-command'
        }
        # Collect the capable drivers: those whose config keys include a clean or a process
        # command. Strip the 'filter.' prefix and the '.clean'/'.process' suffix so a dotted
        # driver name (filter.my.tool.clean -> my.tool) stays intact. A driver with only, for
        # example, a .smudge or .required key cannot transform a diff read and is skipped.
        $listCapableFilterDriver = New-Object 'System.Collections.Generic.List[string]'
        $objCapableFilterSeen = New-Object 'System.Collections.Generic.HashSet[string]' `
            ([System.StringComparer]::Ordinal)
        if ($intNativeExit -eq 0) {
            $strFilterKeyText = $script:objUtf8Strict.GetString($hashtableFilterResult.Stdout)
            foreach ($strFilterKey in $strFilterKeyText.Split([char]0)) {
                if ($strFilterKey.Length -eq 0) {
                    continue
                }
                $strFilterDriverName = $null
                if ($strFilterKey -imatch '^filter\.(.+)\.clean$') {
                    $strFilterDriverName = $matches[1]
                } elseif ($strFilterKey -imatch '^filter\.(.+)\.process$') {
                    $strFilterDriverName = $matches[1]
                }
                if ($null -ne $strFilterDriverName -and $strFilterDriverName.Length -gt 0 -and
                    $objCapableFilterSeen.Add($strFilterDriverName)) {
                    $listCapableFilterDriver.Add($strFilterDriverName)
                }
            }
        }
        # For each capable driver, ask Git which tracked paths select it and read each
        # selected entry's index mode. The 'attr' pathspec magic evaluates the repository's
        # own .gitattributes (and info/attributes), so this is Git's exact per-path filter
        # selection, not a re-implementation, and --stage adds the index mode. A clean/process
        # conversion filter runs only for a regular blob (100644/100755); Git never streams a
        # symlink (120000) or gitlink (160000) entry through a filter. So an empty selection, or
        # a selection whose every entry is a symlink or gitlink, leaves the driver dormant for
        # the worktree diff and is allowed. A regular blob entry, any other mode, a malformed
        # frame, or a non-zero exit that leaves the driver's status undeterminable, refuses
        # (fail closed) as git-filter-active.
        foreach ($strFilterDriverName in $listCapableFilterDriver) {
            $strNativeCommand = 'filter-select'
            $intNativeExit = $null
            $hashtableFilterSelectResult = Invoke-GitRaw `
                -GitRecord $hashtableGitExecutable `
                -WorkingDirectory $strRepositoryRoot `
                -ArgumentList @('ls-files', '-z', '--stage', '--', (':(attr:filter=' + $strFilterDriverName + ')'))
            $listNativeChecks.Add([ordered]@{
                Name = $strNativeCommand
                ExitCode = $hashtableFilterSelectResult.ExitCode
                StdoutLength = $hashtableFilterSelectResult.Stdout.Length
                StderrLength = $hashtableFilterSelectResult.StderrLength
            })
            $intNativeExit = $hashtableFilterSelectResult.ExitCode
            if ($intNativeExit -ne 0) {
                throw 'git-filter-active'
            }
            # Classify every selected entry by its index mode. git ls-files --stage prints
            # `<mode> SP <object> SP <stage> TAB <path>`, so the leading ASCII field before the
            # first space is the mode. Read only that field; never decode the path bytes. Allow
            # only a symlink (120000) or gitlink (160000) entry. Refuse a regular blob, any other
            # mode, or a malformed frame as git-filter-active. An unmerged path yields one record
            # per stage, and each stage is classified on its own, so a regular blob at any stage
            # refuses.
            $arrSelectedBytes = $hashtableFilterSelectResult.Stdout
            if ($arrSelectedBytes.Length -gt 0) {
                if ($arrSelectedBytes[$arrSelectedBytes.Length - 1] -ne 0) {
                    throw 'git-filter-active'
                }
                $intSelectStart = 0
                for ($intSelectIndex = 0; $intSelectIndex -lt $arrSelectedBytes.Length; $intSelectIndex++) {
                    if ($arrSelectedBytes[$intSelectIndex] -ne 0) {
                        continue
                    }
                    $intModeEnd = -1
                    for ($intModeScan = $intSelectStart; $intModeScan -lt $intSelectIndex; $intModeScan++) {
                        if ($arrSelectedBytes[$intModeScan] -eq 0x20) {
                            $intModeEnd = $intModeScan
                            break
                        }
                    }
                    if ($intModeEnd -le $intSelectStart) {
                        throw 'git-filter-active'
                    }
                    $strSelectedMode = [System.Text.Encoding]::ASCII.GetString(
                        $arrSelectedBytes, $intSelectStart, $intModeEnd - $intSelectStart)
                    if ($strSelectedMode -cne '120000' -and $strSelectedMode -cne '160000') {
                        throw 'git-filter-active'
                    }
                    $intSelectStart = $intSelectIndex + 1
                }
            }
        }
    }

    if ($Mode -in @('Working', 'Both')) {
        $strNativeCommand = 'working'
        $intNativeExit = $null
        $hashtableWorkingResult = Invoke-GitRaw `
            -GitRecord $hashtableGitExecutable `
            -WorkingDirectory $strRepositoryRoot `
            -ArgumentList @('diff', '--no-ext-diff', '--no-textconv', '--no-renames', '--ignore-submodules=all', '--name-only', '-z', '--')
        $listNativeChecks.Add([ordered]@{
            Name = $strNativeCommand
            ExitCode = $hashtableWorkingResult.ExitCode
            StdoutLength = $hashtableWorkingResult.Stdout.Length
            StderrLength = $hashtableWorkingResult.StderrLength
        })
        $intNativeExit = $hashtableWorkingResult.ExitCode
        if ($intNativeExit -ne 0) {
            throw 'native-command'
        }
        $objWorkingKeys = ConvertFrom-NulPathRecordStream -Bytes $hashtableWorkingResult.Stdout

        $strNativeCommand = 'untracked'
        $intNativeExit = $null
        $hashtableUntrackedResult = Invoke-GitRaw `
            -GitRecord $hashtableGitExecutable `
            -WorkingDirectory $strRepositoryRoot `
            -ArgumentList @('ls-files', '--others', '--exclude-standard', '-z', '--')
        $listNativeChecks.Add([ordered]@{
            Name = $strNativeCommand
            ExitCode = $hashtableUntrackedResult.ExitCode
            StdoutLength = $hashtableUntrackedResult.Stdout.Length
            StderrLength = $hashtableUntrackedResult.StderrLength
        })
        $intNativeExit = $hashtableUntrackedResult.ExitCode
        if ($intNativeExit -ne 0) {
            throw 'native-command'
        }
        $objUntrackedKeys = ConvertFrom-NulPathRecordStream -Bytes $hashtableUntrackedResult.Stdout
        Add-KeySet -Target $objWorkingKeys -Source $objUntrackedKeys
    }

    if ($Mode -in @('Staged', 'Both')) {
        $strNativeCommand = 'staged'
        $intNativeExit = $null
        $hashtableStagedResult = Invoke-GitRaw `
            -GitRecord $hashtableGitExecutable `
            -WorkingDirectory $strRepositoryRoot `
            -ArgumentList @('diff', '--cached', '--no-ext-diff', '--no-textconv', '--no-renames', '--ignore-submodules=none', '--name-only', '-z', '--')
        $listNativeChecks.Add([ordered]@{
            Name = $strNativeCommand
            ExitCode = $hashtableStagedResult.ExitCode
            StdoutLength = $hashtableStagedResult.Stdout.Length
            StderrLength = $hashtableStagedResult.StderrLength
        })
        $intNativeExit = $hashtableStagedResult.ExitCode
        if ($intNativeExit -ne 0) {
            throw 'native-command'
        }
        $objStagedKeys = ConvertFrom-NulPathRecordStream -Bytes $hashtableStagedResult.Stdout
    }

    $strNativeCommand = 'index-flags'
    $intNativeExit = $null
    $hashtableIndexResult = Invoke-GitRaw `
        -GitRecord $hashtableGitExecutable `
        -WorkingDirectory $strRepositoryRoot `
        -ArgumentList @('ls-files', '-v', '-z', '--')
    $listNativeChecks.Add([ordered]@{
        Name = $strNativeCommand
        ExitCode = $hashtableIndexResult.ExitCode
        StdoutLength = $hashtableIndexResult.Stdout.Length
        StderrLength = $hashtableIndexResult.StderrLength
    })
    $intNativeExit = $hashtableIndexResult.ExitCode
    if ($intNativeExit -ne 0) {
        throw 'native-command'
    }
    $objIndexKeys = ConvertFrom-NulIndexRecordStream `
        -Bytes $hashtableIndexResult.Stdout `
        -AllowUnsafeFlags:($Mode -eq 'Staged' -and -not $RequireCleanWorkingAgainstIndex)

    if ($RequireCleanWorkingAgainstIndex) {
        $strNativeCommand = 'working-index'
        $intNativeExit = $null
        $hashtableCleanResult = Invoke-GitRaw `
            -GitRecord $hashtableGitExecutable `
            -WorkingDirectory $strRepositoryRoot `
            -ArgumentList @('diff', '--quiet', '--exit-code', '--no-ext-diff', '--no-textconv', '--no-renames', '--ignore-submodules=all', '--')
        $listNativeChecks.Add([ordered]@{
            Name = $strNativeCommand
            ExitCode = $hashtableCleanResult.ExitCode
            StdoutLength = $hashtableCleanResult.Stdout.Length
            StderrLength = $hashtableCleanResult.StderrLength
        })
        $intNativeExit = $hashtableCleanResult.ExitCode
        if ($intNativeExit -eq 1) {
            throw 'working-index-difference'
        }
        if ($intNativeExit -ne 0) {
            throw 'native-command'
        }
    }

    # Close the read window with a bounded convergence loop, not a single
    # after-sample. Each pass samples the worktree tree first and the control
    # surface last, so an administrative mutation during the (possibly long)
    # worktree scan changes control-after and is caught. A single control scan is
    # not an atomic snapshot: Get-GitControlSurfaceEvidence hashes the index early,
    # then keeps traversing HEAD and the object HEAD resolves to, so an index (or other component)
    # change after its own git-index hash but before that scan completes would leave
    # a stale control-after. Requiring two consecutive full (worktree, control)
    # samples to agree closes that intra-call gap: a change during one pass makes
    # the next pass differ and forces another pass, so a converged pair reflects a
    # window with no observed change. The before/after check below then rejects any
    # net drift across the reads. Persistent churn that never settles within the
    # bound is refused (evidence-unstable). A quiescent repository converges on the
    # first confirmation. Residual: a change confined entirely to the tail of the
    # final converged pass needs a concurrent second writer, which single-actor CI
    # does not have.
    $intConvergenceLimit = 8
    $intConvergenceCount = 0
    $boolConverged = $false
    $hashtableWorktreeAfter = if ($boolWorktreeReadRequested) {
        Get-TreeEvidence `
            -RootPath $strRepositoryRoot `
            -ExcludedPath $hashtableAdministrativePaths.GitEntry `
            -AdditionalExcludedPath $arrWorktreeExcludedPath `
            -WorktreeClassification `
            -TrackedRelativePath $objTrackedRelativePath `
            -OmitUntrackedEvidence:(-not ($Mode -in @('Working', 'Both')))
    } else {
        $null
    }
    $hashtableControlAfter = Get-GitControlSurfaceEvidence `
        -AdministrativePathRecord $hashtableAdministrativePaths `
        -IncludeReferenceEvidence $boolIncludeReferenceEvidence `
        -SampleWorktreeControlInput $boolWorktreeReadRequested `
        -IncludeWorktreeConfigEvidence $boolWorktreeConfigEnabled `
        -GitRecord $hashtableGitExecutable `
        -WorkingDirectory $strRepositoryRoot `
        -NativeCommandList $listNativeChecks
    while ($intConvergenceCount -lt $intConvergenceLimit) {
        $intConvergenceCount++
        $hashtableWorktreeConfirm = if ($boolWorktreeReadRequested) {
            Get-TreeEvidence `
                -RootPath $strRepositoryRoot `
                -ExcludedPath $hashtableAdministrativePaths.GitEntry `
                -AdditionalExcludedPath $arrWorktreeExcludedPath `
                -WorktreeClassification `
                -TrackedRelativePath $objTrackedRelativePath `
                -OmitUntrackedEvidence:(-not ($Mode -in @('Working', 'Both')))
        } else {
            $null
        }
        $hashtableControlConfirm = Get-GitControlSurfaceEvidence `
            -AdministrativePathRecord $hashtableAdministrativePaths `
            -IncludeReferenceEvidence $boolIncludeReferenceEvidence `
            -SampleWorktreeControlInput $boolWorktreeReadRequested `
            -IncludeWorktreeConfigEvidence $boolWorktreeConfigEnabled `
            -GitRecord $hashtableGitExecutable `
            -WorkingDirectory $strRepositoryRoot `
            -NativeCommandList $listNativeChecks
        $boolWorktreeStable = (-not $boolWorktreeReadRequested) -or
            ($hashtableWorktreeConfirm.Digest -ceq $hashtableWorktreeAfter.Digest)
        if ($hashtableControlConfirm.Digest -ceq $hashtableControlAfter.Digest -and
            $boolWorktreeStable) {
            $boolConverged = $true
            break
        }
        $hashtableControlAfter = $hashtableControlConfirm
        $hashtableWorktreeAfter = $hashtableWorktreeConfirm
    }
    if (-not $boolConverged) {
        throw 'evidence-unstable'
    }
    if ($hashtableControlBefore.Digest -cne $hashtableControlAfter.Digest) {
        throw 'git-control-drift'
    }
    if ($boolWorktreeReadRequested -and
        $hashtableWorktreeBefore.Digest -cne $hashtableWorktreeAfter.Digest) {
        throw 'worktree-drift'
    }
    # Bracket the local object database around the path-set reads. Neither the worktree
    # digest nor the control-surface digest records the loose/pack objects, so a required
    # object removed or corrupted after a read -- HEAD's commit and tree objects for the
    # staged read, or an index blob for a worktree-versus-index read of a stat-dirty file --
    # would leave every sampled digest converged while a fresh comparison now fails or yields
    # a different set. Repeat each performed read here and require the same path set, binding
    # the object database to the same converged-tail residual as the bracketed inputs rather
    # than leaving it unbracketed for the whole read window. A read that now exits non-zero,
    # or whose path set differs, fails closed as object-store-drift; the residual tail after
    # this repeat needs a concurrent second writer, which single-actor CI does not have.
    if ($Mode -in @('Working', 'Both')) {
        $strNativeCommand = 'working-repeat'
        $intNativeExit = $null
        $hashtableWorkingRepeat = Invoke-GitRaw `
            -GitRecord $hashtableGitExecutable `
            -WorkingDirectory $strRepositoryRoot `
            -ArgumentList @('diff', '--no-ext-diff', '--no-textconv', '--no-renames', '--ignore-submodules=all', '--name-only', '-z', '--')
        $listNativeChecks.Add([ordered]@{
            Name = $strNativeCommand
            ExitCode = $hashtableWorkingRepeat.ExitCode
            StdoutLength = $hashtableWorkingRepeat.Stdout.Length
            StderrLength = $hashtableWorkingRepeat.StderrLength
        })
        $intNativeExit = $hashtableWorkingRepeat.ExitCode
        if ($intNativeExit -ne 0) {
            throw 'object-store-drift'
        }
        $strNativeCommand = 'untracked-repeat'
        $intNativeExit = $null
        $hashtableUntrackedRepeat = Invoke-GitRaw `
            -GitRecord $hashtableGitExecutable `
            -WorkingDirectory $strRepositoryRoot `
            -ArgumentList @('ls-files', '--others', '--exclude-standard', '-z', '--')
        $listNativeChecks.Add([ordered]@{
            Name = $strNativeCommand
            ExitCode = $hashtableUntrackedRepeat.ExitCode
            StdoutLength = $hashtableUntrackedRepeat.Stdout.Length
            StderrLength = $hashtableUntrackedRepeat.StderrLength
        })
        $intNativeExit = $hashtableUntrackedRepeat.ExitCode
        if ($intNativeExit -ne 0) {
            throw 'object-store-drift'
        }
        $objWorkingRepeat = ConvertFrom-NulPathRecordStream -Bytes $hashtableWorkingRepeat.Stdout
        Add-KeySet -Target $objWorkingRepeat -Source (
            ConvertFrom-NulPathRecordStream -Bytes $hashtableUntrackedRepeat.Stdout)
        if (-not $objWorkingRepeat.SetEquals($objWorkingKeys)) {
            throw 'object-store-drift'
        }
    }
    if ($Mode -in @('Staged', 'Both')) {
        $strNativeCommand = 'staged-repeat'
        $intNativeExit = $null
        $hashtableStagedRepeat = Invoke-GitRaw `
            -GitRecord $hashtableGitExecutable `
            -WorkingDirectory $strRepositoryRoot `
            -ArgumentList @('diff', '--cached', '--no-ext-diff', '--no-textconv', '--no-renames', '--ignore-submodules=none', '--name-only', '-z', '--')
        $listNativeChecks.Add([ordered]@{
            Name = $strNativeCommand
            ExitCode = $hashtableStagedRepeat.ExitCode
            StdoutLength = $hashtableStagedRepeat.Stdout.Length
            StderrLength = $hashtableStagedRepeat.StderrLength
        })
        $intNativeExit = $hashtableStagedRepeat.ExitCode
        if ($intNativeExit -ne 0) {
            throw 'object-store-drift'
        }
        $objStagedRepeat = ConvertFrom-NulPathRecordStream -Bytes $hashtableStagedRepeat.Stdout
        if (-not $objStagedRepeat.SetEquals($objStagedKeys)) {
            throw 'object-store-drift'
        }
    }
    # Final atomic single-file control-input read -- the last evidence action. It
    # re-reads every single-file control input after the converged control traversal,
    # so a change to any one during that traversal's tail (which the aggregate
    # control digest could miss) is caught here against the pre-read bracket. A change
    # after this read is post-return state that no verifier can observe; tree-shaped
    # inputs and the live worktree keep the convergence guarantee only.
    $strControlInputDigestFinal = Get-PathSetControlInputDigest `
        -AdministrativePathRecord $hashtableAdministrativePaths `
        -IncludeReferenceEvidence $boolIncludeReferenceEvidence `
        -SampleWorktreeControlInput $boolWorktreeReadRequested `
        -IncludeWorktreeConfigEvidence $boolWorktreeConfigEnabled `
        -GitRecord $hashtableGitExecutable `
        -WorkingDirectory $strRepositoryRoot `
        -NativeCommandList $listNativeChecks
    if ($strControlInputDigestBefore -cne $strControlInputDigestFinal) {
        throw 'git-control-drift'
    }
    # Re-resolve the Git administrative pointers from disk and require them to equal
    # the record resolved before the reads. Every evidence pass and every control
    # path above is joined onto the cached GitDirectory/CommonDirectory, but native
    # Git re-follows the on-disk .git pointer on every call. On a linked worktree or
    # submodule the .git gitdir pointer -- and the commondir pointer it resolves --
    # can be rewritten after the initial resolution, leaving the cached directories
    # hashing one index/HEAD while native Git reads another, with every cached-path
    # digest still equal so no other bracket fires. Re-resolving here and comparing
    # the resolved paths brackets that drift the same way the single-file inputs are
    # bracketed; a mismatch fails closed. The record is resolved once before the
    # reads (the pre-read snapshot), so this final resolution closes the window from
    # that point through the last read. An ordinary clone whose .git is a directory
    # resolves to the same paths and never trips this.
    $hashtableAdministrativePathsFinal = Get-GitAdministrativePathRecord `
        -RepositoryRoot $strRepositoryRoot
    if ($hashtableAdministrativePathsFinal.GitEntry -cne $hashtableAdministrativePaths.GitEntry -or
        $hashtableAdministrativePathsFinal.GitDirectory -cne $hashtableAdministrativePaths.GitDirectory -or
        $hashtableAdministrativePathsFinal.CommonDirectory -cne $hashtableAdministrativePaths.CommonDirectory) {
        throw 'git-control-drift'
    }
    $boolEvidenceStable = $true

    $objActualKeys = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
    if ($Mode -in @('Working', 'Both')) {
        Add-KeySet -Target $objActualKeys -Source $objWorkingKeys
    }
    if ($Mode -in @('Staged', 'Both')) {
        Add-KeySet -Target $objActualKeys -Source $objStagedKeys
    }
    foreach ($strKey in $objExpectedKeys) {
        if (-not $objActualKeys.Contains($strKey)) {
            $intMissingCount++
        }
    }
    foreach ($strKey in $objActualKeys) {
        if (-not $objExpectedKeys.Contains($strKey)) {
            $intUnexpectedCount++
        }
    }
    if ($intMissingCount -ne 0 -or $intUnexpectedCount -ne 0) {
        $strCategory = 'path-set-mismatch'
        $intExitCode = 2
    } else {
        $strCategory = 'none'
        $strNativeOutcome = 'Success'
        $intExitCode = 0
    }
} catch {
    $strNativeOutcome = $_.Exception.GetType().FullName
    if ($_.Exception.Message -in @(
        'invalid-version', 'unexpected-version', 'version-fixture-failure',
        'worktree-directory-fixture-failure',
        'invalid-repository-root', 'invalid-ordinary-file', 'invalid-expected-path',
        'git-executable-resolution', 'git-executable-drift', 'git-executable-limit',
        'malformed-records',
        'malformed-index-records', 'unsafe-index-state', 'record-limit',
        'repository-boundary', 'invalid-git-control', 'git-control-limit',
        'worktree-link', 'worktree-limit', 'worktree-special-entry',
        'git-control-drift', 'worktree-drift', 'object-store-drift',
        'evidence-unstable', 'git-filter-active', 'git-alternates-active',
        'git-config-include-active', 'git-promisor-remote', 'git-object-store-nonordinary',
        'native-command', 'native-output-limit', 'native-command-timeout',
        'working-index-difference'
    )) {
        $strCategory = $_.Exception.Message
    }
    if ($strCategory -in @('malformed-records', 'malformed-index-records')) {
        $intExitCode = 3
    } elseif ($strCategory -in @('native-command', 'native-output-limit', 'native-command-timeout')) {
        $intExitCode = 4
    } elseif ($strCategory -eq 'working-index-difference') {
        $intExitCode = 2
    } else {
        $intExitCode = 5
    }
}

$intExpectedCount = if ($null -eq $objExpectedKeys) { 0 } else { $objExpectedKeys.Count }
$intActualCount = if ($null -eq $objActualKeys) { 0 } else { $objActualKeys.Count }
$hashtableResult = [ordered]@{
    Schema = $script:strVerifierResultSchema
    VerifierVersion = $script:strVerifierVersion
    Success = $intExitCode -eq 0
    Mode = $Mode
    Category = $strCategory
    NativeOutcome = $strNativeOutcome
    NativeCommand = $strNativeCommand
    NativeExit = $intNativeExit
    ExpectedCount = $intExpectedCount
    ActualCount = $intActualCount
    MissingCount = $intMissingCount
    UnexpectedCount = $intUnexpectedCount
    WorkingCount = $objWorkingKeys.Count
    StagedCount = $objStagedKeys.Count
    UntrackedCount = $objUntrackedKeys.Count
    IndexCount = $objIndexKeys.Count
    GitExecutableLength = if ($null -eq $hashtableGitExecutable) { $null } else { $hashtableGitExecutable.Length }
    GitExecutableSha256 = if ($null -eq $hashtableGitExecutable) { $null } else { $hashtableGitExecutable.Sha256 }
    ControlSurfaceDigestBefore = if ($null -eq $hashtableControlBefore) { $null } else { $hashtableControlBefore.Digest }
    ControlSurfaceDigestAfter = if ($null -eq $hashtableControlAfter) { $null } else { $hashtableControlAfter.Digest }
    WorktreeDigestBefore = if ($null -eq $hashtableWorktreeBefore) { $null } else { $hashtableWorktreeBefore.Digest }
    WorktreeDigestAfter = if ($null -eq $hashtableWorktreeAfter) { $null } else { $hashtableWorktreeAfter.Digest }
    WorktreeEntryCount = if ($null -eq $hashtableWorktreeBefore) { 0 } else { $hashtableWorktreeBefore.EntryCount }
    WorktreeFileCount = if ($null -eq $hashtableWorktreeBefore) { 0 } else { $hashtableWorktreeBefore.FileCount }
    WorktreeByteCount = if ($null -eq $hashtableWorktreeBefore) { 0 } else { $hashtableWorktreeBefore.ByteCount }
    EvidenceStable = $boolEvidenceStable
    NativeChecks = $listNativeChecks.ToArray()
    ExitCode = $intExitCode
}
Write-VerifierResult -Result $hashtableResult
exit $intExitCode
