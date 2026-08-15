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
Version: 1.0.20260814.0
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

$script:strVerifierVersion = '1.0.20260814.0'
$script:strVerifierResultSchema = 'PSStyleGuide.ExactGitPathSetResult.v2'
$script:objUtf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
$script:objPathComparison = if ($env:OS -eq 'Windows_NT') {
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

function Get-FileSha256Hex {
    # .SYNOPSIS
    # Gets the SHA-256 digest of one ordinary file.
    #
    # .DESCRIPTION
    # Opens the literal file for shared reading, hashes its complete byte stream,
    # and returns lowercase hexadecimal text without separators.
    #
    # .PARAMETER LiteralPath
    # Absolute literal file path to hash. Wildcards are not expanded.
    #
    # .EXAMPLE
    # $strDigest = Get-FileSha256Hex -LiteralPath $strGitPath
    #
    # # Returns the lowercase SHA-256 digest of the selected Git executable.
    #
    # .EXAMPLE
    # Get-FileSha256Hex -LiteralPath $strMissingPath
    #
    # # Propagates the file-open failure for a missing path.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String. The lowercase SHA-256 digest. File, stream, allocation, and
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

    $objStream = New-Object System.IO.FileStream(
        $LiteralPath,
        [System.IO.FileMode]::Open,
        [System.IO.FileAccess]::Read,
        [System.IO.FileShare]::Read
    )
    $objSha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        return ([System.BitConverter]::ToString($objSha256.ComputeHash($objStream))).Replace('-', '').ToLowerInvariant()
    } finally {
        $objSha256.Dispose()
        $objStream.Dispose()
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
    # 'invalid-ordinary-file' for an invalid, missing, directory, or reparse
    # entry. Path, metadata, access, and parameter-binding failures propagate.
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
        Sha256 = Get-FileSha256Hex -LiteralPath $strGitPath
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
    # 'native-command' when Process.Start returns false and 'native-output-limit'
    # for oversized output; parameter-binding, process, task, and I/O failures
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
    #   Position 0: GitRecord
    #   Position 1: WorkingDirectory
    #   Position 2: ArgumentList
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$GitRecord,

        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory,

        [Parameter(Mandatory = $true)]
        [string[]]$ArgumentList
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
        (Get-FileSha256Hex -LiteralPath $strGitPath) -cne [string]$GitRecord.Sha256) {
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
    # Neutralize every ambient input the path-set reads would otherwise depend on,
    # so the result is hermetic and host-symmetric. These -c overrides take the
    # highest git config precedence, so they hold regardless of any value a local
    # config file -- or a file it pulls in with include.path/includeIf -- sets:
    #   - no system or global config;
    #   - no external excludes file (the untracked read's core.excludesFile) and no
    #     external attributes file (core.attributesFile), each of which may point
    #     outside the repository;
    #   - a host-independent core.filemode, so a tracked file's executable bit
    #     cannot make the working and staged reads differ between Windows (filemode
    #     false) and Linux (filemode true);
    #   - strict stat validation (core.checkStat=default, core.trustctime=true), so
    #     a relaxed local setting cannot let a same-length content change with a
    #     restored mtime read as clean through Git's cached stat.
    # info/exclude and info/attributes (repository-local, under the common Git
    # directory) remain covered by Get-GitControlSurfaceEvidence. Submodule
    # ignoring is set per command, never as a global config: --ignore-submodules=all
    # is passed to the worktree-versus-index diffs (the working and clean reads), so a
    # mutable submodule worktree state does not perturb them, while the staged read
    # (git diff --cached) passes --ignore-submodules=none so it keeps submodule
    # sensitivity and still reports a staged gitlink (index-versus-HEAD) change even
    # when a local config or a tracked .gitmodules sets submodule.<name>.ignore=all,
    # which would otherwise suppress that staged gitlink change.
    $strNullDevice = if ($env:OS -eq 'Windows_NT') { 'NUL' } else { '/dev/null' }
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
        '-c', 'core.checkStat=default',
        '-c', 'core.trustctime=true',
        '-c', ('core.excludesFile=' + $strNullDevice),
        '-c', ('core.attributesFile=' + $strNullDevice)
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
        $objStdoutTask = $objProcess.StandardOutput.BaseStream.CopyToAsync($objStdout)
        $objStderrTask = $objProcess.StandardError.BaseStream.CopyToAsync($objStderr)
        # Bound the drain instead of buffering the whole streams before the size
        # check. If either sink crosses 4 MiB while the child is still writing,
        # terminate the child (and its tree) and fail with native-output-limit, so a
        # command that emits hundreds of megabytes cannot exhaust the verifier. The
        # MemoryStream length getter reads a 64-bit field, so sampling it while
        # CopyToAsync writes returns a valid (at worst slightly stale) length.
        while (-not ($objStdoutTask.IsCompleted -and $objStderrTask.IsCompleted)) {
            if ($objStdout.Length -gt 4194304 -or $objStderr.Length -gt 4194304) {
                # Process.Kill(bool entireProcessTree) is .NET Core 3.0+ only; on the
                # supported Windows PowerShell 5.1 (.NET Framework) host that overload
                # is absent, so Kill($true) would raise a MethodException that this
                # catch would silently discard, leaving the oversized child running
                # (Dispose() in finally does not terminate it). Probe for the tree-kill
                # overload and fall back to the parameterless Kill(), which every
                # supported runtime exposes, so the resource bound is always enforced.
                if ($null -ne $objProcess.GetType().GetMethod('Kill', [type[]]@([bool]))) {
                    try { $objProcess.Kill($true) } catch { $null = $_ }
                } else {
                    try { $objProcess.Kill() } catch { $null = $_ }
                }
                throw 'native-output-limit'
            }
            [void][System.Threading.Tasks.Task]::WaitAny(@($objStdoutTask, $objStderrTask), 25)
        }
        $objProcess.WaitForExit()
        [System.Threading.Tasks.Task]::WaitAll(@($objStdoutTask, $objStderrTask))
        $intExitCode = $objProcess.ExitCode
        $arrStdout = $objStdout.ToArray()
        $arrStderr = $objStderr.ToArray()
        if ($arrStdout.Length -gt 4194304 -or $arrStderr.Length -gt 4194304) {
            throw 'native-output-limit'
        }
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
        $arrRecord = New-Object byte[] $intLength
        [System.Array]::Copy($Bytes, $intRecordStart, $arrRecord, 0, $intLength)
        $strKey = [System.Convert]::ToBase64String($arrRecord)
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
    # directory.
    #
    # .PARAMETER LiteralPath
    # Absolute literal worktree-root path to normalize and validate.
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
    # returns false, including absorbed access/filesystem errors, and for a
    # non-directory or reparse component. Parameter-binding, path-normalization,
    # and metadata failures after existence is established propagate.
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
        throw 'invalid-repository-root'
    }
    foreach ($chrCharacter in $LiteralPath.ToCharArray()) {
        if ([char]::IsControl($chrCharacter)) {
            throw 'invalid-repository-root'
        }
    }
    $strFullPath = [System.IO.Path]::GetFullPath($LiteralPath)
    $objCurrent = New-Object System.IO.DirectoryInfo($strFullPath)
    while ($null -ne $objCurrent) {
        if (-not $objCurrent.Exists -or
            ($objCurrent.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0 -or
            ($objCurrent.Attributes -band [System.IO.FileAttributes]::Directory) -eq 0) {
            throw 'invalid-repository-root'
        }
        $objCurrent = $objCurrent.Parent
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
    # .PARAMETER RootPath
    # Absolute ordinary directory root to inspect.
    #
    # .PARAMETER ExcludedPath
    # Optional exact absolute entry to exclude without traversal.
    #
    # .EXAMPLE
    # $hashtableTree = Get-TreeEvidence -RootPath $strRepositoryRoot -ExcludedPath $strGitEntry
    #
    # # Returns bounded worktree digest and count evidence without reading .git.
    #
    # .EXAMPLE
    # $hashtableHooks = Get-TreeEvidence -RootPath $strHooksPath -ExcludedPath $null
    #
    # # Returns bounded evidence for all ordinary hook entries.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Collections.Specialized.OrderedDictionary. Contains Digest,
    # EntryCount, FileCount, and ByteCount. Throws 'worktree-link' or
    # 'worktree-limit' for refused state. Filesystem and hashing failures
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
    #   Position 0: RootPath
    #   Position 1: ExcludedPath
    param (
        [Parameter(Mandatory = $true)]
        [string]$RootPath,

        [AllowNull()]
        [string]$ExcludedPath
    )

    $strRoot = Assert-OrdinaryRepositoryRoot -LiteralPath $RootPath
    $strExcluded = if ([string]::IsNullOrEmpty($ExcludedPath)) {
        $null
    } else {
        [System.IO.Path]::GetFullPath($ExcludedPath)
    }
    $objMap = New-Object 'System.Collections.Generic.SortedDictionary[string,string]' `
        ([System.StringComparer]::Ordinal)
    $objPending = New-Object 'System.Collections.Generic.Stack[string]'
    $objPending.Push($strRoot)
    $intFileCount = 0
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
            if (($objAttributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
                throw 'worktree-link'
            }
            $strRelativePath = $strFullEntry.Substring($strRoot.Length).TrimStart(
                [System.IO.Path]::DirectorySeparatorChar,
                [System.IO.Path]::AltDirectorySeparatorChar
            ).Replace([System.IO.Path]::DirectorySeparatorChar, '/')
            if (($objAttributes -band [System.IO.FileAttributes]::Directory) -ne 0) {
                $objMap['D:' + $strRelativePath] = ''
                $objPending.Push($strFullEntry)
            } else {
                $objFile = New-Object System.IO.FileInfo($strFullEntry)
                # On Unix an entry that is neither a directory nor a reparse point can
                # still be a FIFO, socket, or device, which File attributes do not
                # distinguish from a regular file, so a zero-length FIFO would receive
                # the same evidence as a zero-byte regular file. PowerShell's UnixMode
                # string exposes the type in its first character. Reject the explicit
                # special types so a special entry cannot alias a regular file; the
                # check is a no-op where UnixMode is absent (Windows, which has no such
                # entries in an ordinary worktree) and never fires on a regular file
                # ('-') or directory ('d').
                $objUnixModeProperty = $objFile.PSObject.Properties['UnixMode']
                if ($null -ne $objUnixModeProperty) {
                    $strUnixMode = [string]$objUnixModeProperty.Value
                    if ($strUnixMode.Length -gt 0 -and ($strUnixMode[0] -eq 'p' -or
                        $strUnixMode[0] -eq 's' -or $strUnixMode[0] -eq 'b' -or
                        $strUnixMode[0] -eq 'c')) {
                        throw 'worktree-special-entry'
                    }
                }
                if ($objFile.Length -gt 67108864) {
                    throw 'worktree-limit'
                }
                $longByteCount += $objFile.Length
                if ($longByteCount -gt 1073741824) {
                    throw 'worktree-limit'
                }
                $strFileDigest = if ($objFile.Length -eq 0) {
                    $objEmptySha = [System.Security.Cryptography.SHA256]::Create()
                    try {
                        ([System.BitConverter]::ToString($objEmptySha.ComputeHash((New-Object byte[] 0)))).Replace('-', '').ToLowerInvariant()
                    } finally {
                        $objEmptySha.Dispose()
                    }
                } else {
                    Get-FileSha256Hex -LiteralPath $strFullEntry
                }
                $objMap['F:' + $strRelativePath] = ([string]$objFile.Length + ':' + $strFileDigest)
                $intFileCount++
            }
            if ($objMap.Count -gt 100000) {
                throw 'worktree-limit'
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
        $arrGitEntryBytes = [System.IO.File]::ReadAllBytes($strGitEntry)
        if ($arrGitEntryBytes.Length -eq 0 -or $arrGitEntryBytes.Length -gt 4096) {
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
        $arrCommonBytes = [System.IO.File]::ReadAllBytes($strCommonMarker)
        if ($arrCommonBytes.Length -eq 0 -or $arrCommonBytes.Length -gt 4096) {
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

function Get-GitControlSurfaceEvidence {
    # .SYNOPSIS
    # Gets bounded evidence for repository-local Git configuration and hooks.
    #
    # .DESCRIPTION
    # Hashes the .git pointer when present, the applicable local configuration
    # files, the staging index, split-index backing files, info/exclude,
    # info/attributes, HEAD, packed-refs, the commondir pointer, the shared and
    # per-worktree loose refs trees, the shared and per-worktree reftable backend
    # trees, and ordinary bounded hook directory trees. Uses labeled components so
    # absent and present state cannot collide. The refs trees exclude logs/
    # (reflogs), a sibling of refs/, so benign reflog churn raises no drift.
    #
    # .PARAMETER AdministrativePathRecord
    # Validated GitEntry, GitDirectory, and CommonDirectory path record.
    #
    # .EXAMPLE
    # $hashtableControl = Get-GitControlSurfaceEvidence -AdministrativePathRecord $hashtableGitPath
    #
    # # Returns one digest and bounded component counts.
    #
    # .EXAMPLE
    # Get-GitControlSurfaceEvidence -AdministrativePathRecord $hashtableLinkedControl
    #
    # # Throws when a configuration or hook entry is not ordinary.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.Collections.Specialized.OrderedDictionary. Contains Digest,
    # ComponentCount, HookEntryCount, and HookByteCount. The Digest also covers
    # the staging index, info/exclude, info/attributes, HEAD, packed-refs, the
    # commondir pointer, and the shared and per-worktree loose refs trees, so
    # concurrent drift of any path-set read input raises git-control-drift.
    # Filesystem, ordinary path,
    # size-bound, hashing, and parameter-binding failures propagate.
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
    #   Position 0: AdministrativePathRecord
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$AdministrativePathRecord
    )

    $objComponents = New-Object 'System.Collections.Generic.SortedDictionary[string,string]' `
        ([System.StringComparer]::Ordinal)
    $strGitEntry = [string]$AdministrativePathRecord.GitEntry
    if ([System.IO.File]::Exists($strGitEntry)) {
        $objGitEntryInfo = New-Object System.IO.FileInfo((Assert-OrdinaryAbsoluteFile -LiteralPath $strGitEntry))
        $objComponents['git-entry'] = ([string]$objGitEntryInfo.Length + ':' +
            (Get-FileSha256Hex -LiteralPath $strGitEntry))
    } else {
        [void](Assert-OrdinaryRepositoryRoot -LiteralPath $strGitEntry)
        $objComponents['git-entry'] = 'directory'
    }

    # Local config, plus the single-file administrative inputs the path-set reads
    # depend on but the worktree tree evidence excludes: the staging index
    # (working/staged/index-flags reads), info/exclude (the untracked read's
    # --exclude-standard set), info/attributes (repository-local Git attributes
    # that can change the working read via content normalization), HEAD plus
    # packed-refs (the staged read resolves HEAD against the index), and the
    # commondir pointer (which resolves the common Git directory for a linked
    # worktree). The index, HEAD, and commondir pointer are per-worktree
    # (GitDirectory); info/exclude, info/attributes, and packed-refs are shared
    # (CommonDirectory).
    $arrBoundedFileSpecifications = @(
        @('common-config', (Join-Path $AdministrativePathRecord.CommonDirectory 'config')),
        @('common-config-worktree', (Join-Path $AdministrativePathRecord.CommonDirectory 'config.worktree')),
        @('worktree-config', (Join-Path $AdministrativePathRecord.GitDirectory 'config')),
        @('worktree-config-worktree', (Join-Path $AdministrativePathRecord.GitDirectory 'config.worktree')),
        @('git-index', (Join-Path $AdministrativePathRecord.GitDirectory 'index')),
        @('git-head', (Join-Path $AdministrativePathRecord.GitDirectory 'HEAD')),
        @('info-exclude', (Join-Path (Join-Path $AdministrativePathRecord.CommonDirectory 'info') 'exclude')),
        @('info-attributes', (Join-Path (Join-Path $AdministrativePathRecord.CommonDirectory 'info') 'attributes')),
        @('packed-refs', (Join-Path $AdministrativePathRecord.CommonDirectory 'packed-refs')),
        @('commondir-pointer', (Join-Path $AdministrativePathRecord.GitDirectory 'commondir'))
    )
    foreach ($arrSpecification in $arrBoundedFileSpecifications) {
        $strLabel = [string]$arrSpecification[0]
        $strPath = [System.IO.Path]::GetFullPath([string]$arrSpecification[1])
        if ([System.IO.File]::Exists($strPath)) {
            $objInfo = New-Object System.IO.FileInfo((Assert-OrdinaryAbsoluteFile -LiteralPath $strPath))
            if ($objInfo.Length -gt 4194304) {
                throw 'git-control-limit'
            }
            $objComponents[$strLabel] = ([string]$objInfo.Length + ':' + (Get-FileSha256Hex -LiteralPath $strPath))
        } elseif ([System.IO.Directory]::Exists($strPath)) {
            throw 'invalid-git-control'
        } else {
            $objComponents[$strLabel] = 'absent'
        }
    }

    $intHookEntryCount = 0
    $longHookByteCount = 0L
    $arrHookSpecifications = @(
        @('common-hooks', (Join-Path $AdministrativePathRecord.CommonDirectory 'hooks')),
        @('worktree-hooks', (Join-Path $AdministrativePathRecord.GitDirectory 'hooks'))
    )
    foreach ($arrSpecification in $arrHookSpecifications) {
        $strLabel = [string]$arrSpecification[0]
        $strPath = [System.IO.Path]::GetFullPath([string]$arrSpecification[1])
        if ([System.IO.Directory]::Exists($strPath)) {
            $hashtableHooks = Get-TreeEvidence -RootPath $strPath -ExcludedPath $null
            $objComponents[$strLabel] = $hashtableHooks.Digest
            $intHookEntryCount += $hashtableHooks.EntryCount
            $longHookByteCount += $hashtableHooks.ByteCount
        } elseif ([System.IO.File]::Exists($strPath)) {
            throw 'invalid-git-control'
        } else {
            $objComponents[$strLabel] = 'absent'
        }
    }

    # The staged read resolves HEAD against the index, so a concurrent move of the
    # branch ref (commit, reset --soft, update-ref) changes the staged path set.
    # Hash the shared loose refs tree so that drift is caught alongside HEAD and
    # packed-refs above. logs/ (reflogs) is a sibling of refs/ and is deliberately
    # not walked, so benign reflog churn raises no spurious drift.
    $strLooseRefsPath = [System.IO.Path]::GetFullPath(
        (Join-Path $AdministrativePathRecord.CommonDirectory 'refs'))
    if ([System.IO.Directory]::Exists($strLooseRefsPath)) {
        $objComponents['loose-refs'] = (
            Get-TreeEvidence -RootPath $strLooseRefsPath -ExcludedPath $null).Digest
    } elseif ([System.IO.File]::Exists($strLooseRefsPath)) {
        throw 'invalid-git-control'
    } else {
        $objComponents['loose-refs'] = 'absent'
    }

    # Per-worktree refs (refs/bisect, refs/worktree, refs/rewritten) are not shared:
    # Git stores them under the worktree's own Git directory, outside the common
    # refs tree hashed above. For a linked worktree GitDirectory differs from
    # CommonDirectory, so a HEAD that points at a per-worktree ref (for example
    # refs/worktree/*) resolves the staged read against GitDirectory/refs, which
    # loose-refs above does not cover; moving that ref would otherwise leave both
    # before/after digests equal. Hash GitDirectory/refs under a distinct label so
    # per-worktree ref drift is caught. For the main worktree GitDirectory equals
    # CommonDirectory, so this repeats the shared tree, which is inert. logs/ stays
    # a sibling of refs/ and is not walked, so reflog churn raises no spurious drift.
    $strWorktreeRefsPath = [System.IO.Path]::GetFullPath(
        (Join-Path $AdministrativePathRecord.GitDirectory 'refs'))
    if ([System.IO.Directory]::Exists($strWorktreeRefsPath)) {
        $objComponents['worktree-loose-refs'] = (
            Get-TreeEvidence -RootPath $strWorktreeRefsPath -ExcludedPath $null).Digest
    } elseif ([System.IO.File]::Exists($strWorktreeRefsPath)) {
        throw 'invalid-git-control'
    } else {
        $objComponents['worktree-loose-refs'] = 'absent'
    }

    # Reftable reference backend: with extensions.refStorage=reftable, branch tips
    # live under <dir>/reftable/ rather than the loose refs/ tree or packed-refs
    # captured above, so a concurrent update-ref through that backend would change
    # the staged read (HEAD resolved against the index) while the loose/packed
    # components stayed equal. Hash the shared and per-worktree reftable trees;
    # absent for the default files backend.
    $strCommonReftablePath = [System.IO.Path]::GetFullPath(
        (Join-Path $AdministrativePathRecord.CommonDirectory 'reftable'))
    if ([System.IO.Directory]::Exists($strCommonReftablePath)) {
        $objComponents['common-reftable'] = (
            Get-TreeEvidence -RootPath $strCommonReftablePath -ExcludedPath $null).Digest
    } elseif ([System.IO.File]::Exists($strCommonReftablePath)) {
        throw 'invalid-git-control'
    } else {
        $objComponents['common-reftable'] = 'absent'
    }
    $strWorktreeReftablePath = [System.IO.Path]::GetFullPath(
        (Join-Path $AdministrativePathRecord.GitDirectory 'reftable'))
    if ([System.IO.Directory]::Exists($strWorktreeReftablePath)) {
        $objComponents['worktree-reftable'] = (
            Get-TreeEvidence -RootPath $strWorktreeReftablePath -ExcludedPath $null).Digest
    } elseif ([System.IO.File]::Exists($strWorktreeReftablePath)) {
        throw 'invalid-git-control'
    } else {
        $objComponents['worktree-reftable'] = 'absent'
    }

    # Split-index backing files: with core.splitIndex, GitDirectory/index is a small
    # file whose link extension references the bulk of the entries in
    # GitDirectory/sharedindex.<hash>. The git-index component and the direct index
    # bracket cover only GitDirectory/index, so a change to a backing file would go
    # unseen. Hash every top-level sharedindex.* file (ordinal-framed); without a
    # split index there are none (absent).
    $objSharedIndex = New-Object 'System.Collections.Generic.SortedDictionary[string,string]' `
        ([System.StringComparer]::Ordinal)
    if ([System.IO.Directory]::Exists($AdministrativePathRecord.GitDirectory)) {
        foreach ($strSharedIndexFile in [System.IO.Directory]::GetFiles($AdministrativePathRecord.GitDirectory)) {
            $strSharedIndexName = [System.IO.Path]::GetFileName($strSharedIndexFile)
            if (-not $strSharedIndexName.StartsWith('sharedindex.', [System.StringComparison]::Ordinal)) {
                continue
            }
            $strSharedIndexFull = [System.IO.Path]::GetFullPath(
                (Assert-OrdinaryAbsoluteFile -LiteralPath $strSharedIndexFile))
            $objSharedIndexInfo = New-Object System.IO.FileInfo($strSharedIndexFull)
            if ($objSharedIndexInfo.Length -gt 4194304) {
                throw 'git-control-limit'
            }
            $objSharedIndex[$strSharedIndexName] = ([string]$objSharedIndexInfo.Length + ':' +
                (Get-FileSha256Hex -LiteralPath $strSharedIndexFull))
        }
    }
    if ($objSharedIndex.Count -eq 0) {
        $objComponents['shared-index'] = 'absent'
    } else {
        $objComponents['shared-index'] = Get-FramedStringMapDigest -StringMap $objSharedIndex
    }
    return [ordered]@{
        Digest = Get-FramedStringMapDigest -StringMap $objComponents
        ComponentCount = $objComponents.Count
        HookEntryCount = $intHookEntryCount
        HookByteCount = $longHookByteCount
    }
}

function Get-PathSetControlInputDigest {
    # .SYNOPSIS
    # Digests the single-file control inputs the path-set reads depend on.
    #
    # .DESCRIPTION
    # Hashes only the single-file administrative inputs the working, untracked, and
    # staged reads consume -- the staging index, HEAD, info/exclude, info/attributes,
    # packed-refs, the applicable config files, and the commondir pointer -- into one
    # ordinal-framed digest. Each is a single file, so each hash is atomic. Taken
    # before the reads and again as the verifier's final evidence action, the two
    # digests bracket the read window with atomic reads, closing the final-traversal
    # tail that the aggregate control digest leaves for these inputs. Tree-shaped
    # control inputs (loose refs, hooks, reftable, split-index backing files) and the
    # live worktree cannot be bracketed this way and keep the convergence guarantee.
    #
    # .PARAMETER AdministrativePathRecord
    # Validated GitEntry, GitDirectory, and CommonDirectory path record.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # System.String. One framed digest over the single-file control inputs.
    # Filesystem and hashing failures propagate.
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
    #   Position 0: AdministrativePathRecord
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$AdministrativePathRecord
    )

    $objInputs = New-Object 'System.Collections.Generic.SortedDictionary[string,string]' `
        ([System.StringComparer]::Ordinal)
    $arrSingleFileInputs = @(
        @('git-index', (Join-Path $AdministrativePathRecord.GitDirectory 'index')),
        @('git-head', (Join-Path $AdministrativePathRecord.GitDirectory 'HEAD')),
        @('info-exclude', (Join-Path (Join-Path $AdministrativePathRecord.CommonDirectory 'info') 'exclude')),
        @('info-attributes', (Join-Path (Join-Path $AdministrativePathRecord.CommonDirectory 'info') 'attributes')),
        @('packed-refs', (Join-Path $AdministrativePathRecord.CommonDirectory 'packed-refs')),
        @('common-config', (Join-Path $AdministrativePathRecord.CommonDirectory 'config')),
        @('common-config-worktree', (Join-Path $AdministrativePathRecord.CommonDirectory 'config.worktree')),
        @('worktree-config', (Join-Path $AdministrativePathRecord.GitDirectory 'config')),
        @('worktree-config-worktree', (Join-Path $AdministrativePathRecord.GitDirectory 'config.worktree')),
        @('commondir-pointer', (Join-Path $AdministrativePathRecord.GitDirectory 'commondir'))
    )
    foreach ($arrSpecification in $arrSingleFileInputs) {
        $strLabel = [string]$arrSpecification[0]
        $strPath = [System.IO.Path]::GetFullPath([string]$arrSpecification[1])
        if ([System.IO.File]::Exists($strPath)) {
            # Mirror Get-GitControlSurfaceEvidence: reject a non-ordinary (reparse/
            # symlink) file so a concurrently substituted link cannot read outside
            # the repository, and enforce the same 4 MiB component bound.
            $objInfo = New-Object System.IO.FileInfo((Assert-OrdinaryAbsoluteFile -LiteralPath $strPath))
            if ($objInfo.Length -gt 4194304) {
                throw 'git-control-limit'
            }
            $objInputs[$strLabel] = ([string]$objInfo.Length + ':' +
                (Get-FileSha256Hex -LiteralPath $strPath))
        } elseif ([System.IO.Directory]::Exists($strPath)) {
            throw 'invalid-git-control'
        } else {
            $objInputs[$strLabel] = 'absent'
        }
    }
    return Get-FramedStringMapDigest -StringMap $objInputs
}

function ConvertFrom-NulIndexRecordStream {
    # .SYNOPSIS
    # Validates raw NUL-delimited Git index flag and path records.
    #
    # .DESCRIPTION
    # Requires each record to contain the safe cached marker `H`, one ASCII
    # space, and one nonempty opaque path. Rejects assume-unchanged,
    # skip-worktree, unmerged, removed, duplicate, malformed, and excessive
    # records without decoding or printing path bytes.
    #
    # .PARAMETER Bytes
    # Complete raw output from `git ls-files -v -z`.
    #
    # .EXAMPLE
    # $objIndexKeys = ConvertFrom-NulIndexRecordStream -Bytes ([byte[]](0x48,0x20,0x61,0x00))
    #
    # # Returns the opaque key for path byte 0x61.
    #
    # .EXAMPLE
    # ConvertFrom-NulIndexRecordStream -Bytes ([byte[]](0x68,0x20,0x61,0x00))
    #
    # # Throws 'unsafe-index-state' for an assume-unchanged marker.
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
        [byte[]]$Bytes
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
        if ($Bytes[$intStart] -ne 0x48) {
            throw 'unsafe-index-state'
        }
        $arrPath = New-Object byte[] ($intLength - 2)
        [System.Array]::Copy($Bytes, $intStart + 2, $arrPath, 0, $arrPath.Length)
        $strKey = [System.Convert]::ToBase64String($arrPath)
        if (-not $objKeys.Add($strKey)) {
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
    $strSelfPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'Test-ExactGitPathSet.ps1'))
    $strSelfText = $script:objUtf8Strict.GetString([System.IO.File]::ReadAllBytes($strSelfPath))
    [void](Get-ScriptVersionRecord -ScriptText $strSelfText -ExpectedVersion $script:strVerifierVersion)

    $strRepositoryRoot = Assert-OrdinaryRepositoryRoot -LiteralPath $RepositoryRoot
    $objExpectedKeys = New-ExpectedPathKeySet -PathList $ExpectedPath
    $hashtableGitExecutable = Get-GitExecutableRecord -RequestedPath $GitExecutablePath
    $hashtableAdministrativePaths = Get-GitAdministrativePathRecord -RepositoryRoot $strRepositoryRoot
    $hashtableControlBefore = Get-GitControlSurfaceEvidence `
        -AdministrativePathRecord $hashtableAdministrativePaths
    $hashtableWorktreeBefore = Get-TreeEvidence `
        -RootPath $strRepositoryRoot `
        -ExcludedPath $hashtableAdministrativePaths.GitEntry
    # Atomic single-file bracket for every single-file control input the path-set
    # reads consume (index, HEAD, info/exclude, info/attributes, packed-refs, config,
    # commondir). Get-GitControlSurfaceEvidence hashes each as one component of a
    # multi-file traversal, so a change to any one during that traversal's own tail
    # (after that component is hashed, before the scan completes) can leave the
    # aggregate digest stale -- for example info/exclude drives the untracked read's
    # --exclude-standard set. Each input is a single file, so hashing them here
    # (before the reads) and again as the verifier's final evidence action brackets
    # the reads with atomic reads: a change across them raises git-control-drift.
    # This bracket, like every evidence pass, is itself a sequential read, so a
    # single-file input changed after its own hash but before the pass completes --
    # and any change to a tree-shaped input (loose refs, hooks, reftable, split-index
    # backing files) or the live worktree, which git reads in place, during the final
    # converged traversal -- is the irreducible residual: no portable mechanism reads
    # a live multi-file surface atomically, and adding another recheck only moves the
    # tail to that recheck (infinite regress). The residual is bounded to a concurrent
    # second writer racing a sub-second window, which single-actor CI does not have;
    # against accidental drift the convergence is conclusive.
    $strControlInputDigestBefore = Get-PathSetControlInputDigest `
        -AdministrativePathRecord $hashtableAdministrativePaths

    $strNativeCommand = 'repository-root'
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

    if (($Mode -in @('Working', 'Both')) -or $RequireCleanWorkingAgainstIndex) {
        # A worktree-versus-index diff (the working and clean reads below) makes Git
        # run a clean or process filter driver for any path whose filter attribute
        # names a driver with a configured clean/process command. That driver is an
        # external program, outside the hashed evidence, so its output -- and thus
        # the read -- can change while the config that names it, the attributes that
        # assign it, the index, and both evidence digests all stay equal.
        # '--no-textconv' disables only diff textconv, not clean/process, and no
        # config or command-line override neutralizes an arbitrarily named driver
        # assigned by an in-tree .gitattributes. Refuse (fail closed) when such a
        # driver is configured. The probe runs in the same neutralized environment
        # as the reads (no system or global config), so a developer's global Git LFS
        # drivers are already excluded and never trip it; only a repository-local
        # clean or process driver refuses.
        $strNativeCommand = 'filter-config'
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
        if ($intNativeExit -eq 0) {
            $strFilterKeyText = $script:objUtf8Strict.GetString($hashtableFilterResult.Stdout)
            foreach ($strFilterKey in $strFilterKeyText.Split([char]0)) {
                if ($strFilterKey.Length -gt 0 -and $strFilterKey -imatch '\.(clean|process)$') {
                    throw 'git-filter-active'
                }
            }
        }
    }

    if ($Mode -in @('Working', 'Both')) {
        $strNativeCommand = 'working'
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
        # A staged read (index versus HEAD) resolves HEAD's commit and tree through
        # the object database, which may include an external store named by
        # objects/info/alternates (for example a 'git clone --shared' repository).
        # That external store sits outside the hashed control surface and the
        # convergence bracket, so another process can redirect or remove it after
        # the staged read while every control and worktree digest still converges,
        # yielding a success whose staged path set no longer reproduces. The store
        # cannot be snapshotted portably, so refuse (fail closed) when the staged
        # comparison depends on an external object store rather than return an
        # unsound result. An ordinary clone has no alternates file and is
        # unaffected; the working read never traverses HEAD's tree objects, and CI
        # runs Mode Working and never reaches here. Modeled on the git-filter-active
        # refusal above.
        $strAlternatesPath = [System.IO.Path]::Combine(
            [string]$hashtableAdministrativePaths.CommonDirectory, 'objects', 'info', 'alternates')
        if ([System.IO.File]::Exists($strAlternatesPath) -and
            (New-Object System.IO.FileInfo($strAlternatesPath)).Length -gt 0) {
            throw 'git-alternates-active'
        }
        $strNativeCommand = 'staged'
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
    $objIndexKeys = ConvertFrom-NulIndexRecordStream -Bytes $hashtableIndexResult.Stdout

    if ($RequireCleanWorkingAgainstIndex) {
        $strNativeCommand = 'working-index'
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
    # then keeps traversing HEAD, refs, and hooks, so an index (or other component)
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
    $hashtableWorktreeAfter = Get-TreeEvidence `
        -RootPath $strRepositoryRoot `
        -ExcludedPath $hashtableAdministrativePaths.GitEntry
    $hashtableControlAfter = Get-GitControlSurfaceEvidence `
        -AdministrativePathRecord $hashtableAdministrativePaths
    while ($intConvergenceCount -lt $intConvergenceLimit) {
        $intConvergenceCount++
        $hashtableWorktreeConfirm = Get-TreeEvidence `
            -RootPath $strRepositoryRoot `
            -ExcludedPath $hashtableAdministrativePaths.GitEntry
        $hashtableControlConfirm = Get-GitControlSurfaceEvidence `
            -AdministrativePathRecord $hashtableAdministrativePaths
        if ($hashtableControlConfirm.Digest -ceq $hashtableControlAfter.Digest -and
            $hashtableWorktreeConfirm.Digest -ceq $hashtableWorktreeAfter.Digest) {
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
    if ($hashtableWorktreeBefore.Digest -cne $hashtableWorktreeAfter.Digest) {
        throw 'worktree-drift'
    }
    # Final atomic single-file control-input read -- the last evidence action. It
    # re-reads every single-file control input after the converged control traversal,
    # so a change to any one during that traversal's tail (which the aggregate
    # control digest could miss) is caught here against the pre-read bracket. A change
    # after this read is post-return state that no verifier can observe; tree-shaped
    # inputs and the live worktree keep the convergence guarantee only.
    $strControlInputDigestFinal = Get-PathSetControlInputDigest `
        -AdministrativePathRecord $hashtableAdministrativePaths
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
        'invalid-repository-root', 'invalid-ordinary-file', 'invalid-expected-path',
        'git-executable-resolution', 'git-executable-drift', 'malformed-records',
        'malformed-index-records', 'unsafe-index-state', 'record-limit',
        'repository-boundary', 'invalid-git-control', 'git-control-limit',
        'worktree-link', 'worktree-limit', 'worktree-special-entry',
        'git-control-drift', 'worktree-drift',
        'evidence-unstable', 'git-filter-active', 'git-alternates-active',
        'native-command', 'native-output-limit', 'working-index-difference'
    )) {
        $strCategory = $_.Exception.Message
    }
    if ($strCategory -in @('malformed-records', 'malformed-index-records')) {
        $intExitCode = 3
    } elseif ($strCategory -in @('native-command', 'native-output-limit')) {
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
