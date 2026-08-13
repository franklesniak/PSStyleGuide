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

.NOTES
Version: 1.0.20260813.0
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

    [switch]$RequireCleanWorkingAgainstIndex
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:strVerifierVersion = '1.0.20260813.0'
$script:strVerifierResultSchema = 'PSStyleGuide.ExactGitPathSetResult.v1'

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
    # Starts the exact Git executable without a shell, supplies arguments through
    # ArgumentList when available or compatible quoting otherwise, closes standard
    # input, concurrently drains both output streams, and enforces a 4 MiB limit
    # on each captured stream.
    #
    # .PARAMETER GitPath
    # Exact filesystem path of the Git application to invoke.
    #
    # .PARAMETER WorkingDirectory
    # Existing working directory assigned to the native process.
    #
    # .PARAMETER ArgumentList
    # Ordered Git arguments passed without shell interpretation.
    #
    # .EXAMPLE
    # $hashtableResult = Invoke-GitRaw -GitPath $strGitPath -WorkingDirectory $strRoot -ArgumentList @('status', '--porcelain=v1', '-z')
    #
    # # Returns ExitCode, raw Stdout bytes, and StderrLength.
    #
    # .EXAMPLE
    # $strLargeBlobId = '<Git blob object ID larger than 4 MiB>'
    # Invoke-GitRaw -GitPath $strGitPath -WorkingDirectory $strRoot -ArgumentList @('cat-file', 'blob', $strLargeBlobId)
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
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: GitPath
    #   Position 1: WorkingDirectory
    #   Position 2: ArgumentList
    param (
        [Parameter(Mandatory = $true)]
        [string]$GitPath,

        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory,

        [Parameter(Mandatory = $true)]
        [string[]]$ArgumentList
    )

    $objStartInfo = New-Object System.Diagnostics.ProcessStartInfo
    $objStartInfo.FileName = $GitPath
    $objStartInfo.WorkingDirectory = $WorkingDirectory
    $objStartInfo.UseShellExecute = $false
    $objStartInfo.CreateNoWindow = $true
    $objStartInfo.RedirectStandardInput = $true
    $objStartInfo.RedirectStandardOutput = $true
    $objStartInfo.RedirectStandardError = $true
    if ($null -ne $objStartInfo.PSObject.Properties['ArgumentList']) {
        foreach ($strArgument in $ArgumentList) {
            [void]$objStartInfo.ArgumentList.Add($strArgument)
        }
    } else {
        $objStartInfo.Arguments = ConvertTo-NativeArgumentString -ArgumentList $ArgumentList
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
    # records, or duplicate records; parameter-binding and allocation failures
    # propagate.
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
    # Version: 1.0.20260813.0
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
    # Version: 1.0.20260813.0
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
    # Serializes the complete ordered verifier result without pretty-printing and
    # writes it directly to standard output as one newline-terminated JSON document.
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
    # Version: 1.0.20260813.0
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #
    #   Position 0: Result
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Result
    )

    [Console]::Out.WriteLine(($Result | ConvertTo-Json -Compress))
}

$strCategory = 'tool-failure'
$strNativeOutcome = 'NotApplicable'
$intNativeExit = $null
$objExpectedKeys = $null
$objActualKeys = $null
$objWorkingKeys = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
$objStagedKeys = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
$objUntrackedKeys = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
$intExitCode = 1

try {
    Test-ScriptVersionParser
    $strSelfPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'Test-ExactGitPathSet.ps1'))
    $strSelfText = (New-Object System.Text.UTF8Encoding($false, $true)).GetString(
        [System.IO.File]::ReadAllBytes($strSelfPath)
    )
    [void](Get-ScriptVersionRecord -ScriptText $strSelfText -ExpectedVersion $script:strVerifierVersion)

    $strRepositoryRoot = Assert-OrdinaryRepositoryRoot -LiteralPath $RepositoryRoot

    $objExpectedKeys = New-ExpectedPathKeySet -PathList $ExpectedPath
    $arrGitCommands = @(Get-Command -Name git -CommandType Application -ErrorAction Stop)
    $strGitPath = [string]$arrGitCommands[0].Source

    if ($Mode -in @('Working', 'Both')) {
        $hashtableWorkingResult = Invoke-GitRaw -GitPath $strGitPath -WorkingDirectory $strRepositoryRoot `
            -ArgumentList @('diff', '--no-renames', '--name-only', '-z', '--')
        if ($hashtableWorkingResult.ExitCode -ne 0) {
            $intNativeExit = $hashtableWorkingResult.ExitCode
            throw 'native-command'
        }
        $objWorkingKeys = ConvertFrom-NulPathRecordStream -Bytes $hashtableWorkingResult.Stdout

        $hashtableUntrackedResult = Invoke-GitRaw -GitPath $strGitPath -WorkingDirectory $strRepositoryRoot `
            -ArgumentList @('ls-files', '--others', '--exclude-standard', '-z', '--')
        if ($hashtableUntrackedResult.ExitCode -ne 0) {
            $intNativeExit = $hashtableUntrackedResult.ExitCode
            throw 'native-command'
        }
        $objUntrackedKeys = ConvertFrom-NulPathRecordStream -Bytes $hashtableUntrackedResult.Stdout
        Add-KeySet -Target $objWorkingKeys -Source $objUntrackedKeys
    }

    if ($Mode -in @('Staged', 'Both')) {
        $hashtableStagedResult = Invoke-GitRaw -GitPath $strGitPath -WorkingDirectory $strRepositoryRoot `
            -ArgumentList @('diff', '--cached', '--no-renames', '--name-only', '-z', '--')
        if ($hashtableStagedResult.ExitCode -ne 0) {
            $intNativeExit = $hashtableStagedResult.ExitCode
            throw 'native-command'
        }
        $objStagedKeys = ConvertFrom-NulPathRecordStream -Bytes $hashtableStagedResult.Stdout
    }

    if ($RequireCleanWorkingAgainstIndex) {
        $hashtableCleanResult = Invoke-GitRaw -GitPath $strGitPath -WorkingDirectory $strRepositoryRoot `
            -ArgumentList @('diff', '--exit-code', '--no-renames', '--')
        $intNativeExit = $hashtableCleanResult.ExitCode
        if ($intNativeExit -eq 1) {
            throw 'working-index-difference'
        }
        if ($intNativeExit -ne 0) {
            throw 'native-command'
        }
    }

    $objActualKeys = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
    if ($Mode -in @('Working', 'Both')) {
        Add-KeySet -Target $objActualKeys -Source $objWorkingKeys
    }
    if ($Mode -in @('Staged', 'Both')) {
        Add-KeySet -Target $objActualKeys -Source $objStagedKeys
    }

    $intMissingCount = 0
    foreach ($strKey in $objExpectedKeys) {
        if (-not $objActualKeys.Contains($strKey)) {
            $intMissingCount++
        }
    }
    $intUnexpectedCount = 0
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
        $intExitCode = 0
    }
} catch {
    $strNativeOutcome = $_.Exception.GetType().FullName
    if ($_.Exception.Message -in @(
        'invalid-version', 'unexpected-version', 'version-fixture-failure',
        'invalid-repository-root', 'invalid-expected-path', 'malformed-records',
        'native-command', 'native-output-limit', 'working-index-difference'
    )) {
        $strCategory = $_.Exception.Message
    }
    if ($strCategory -eq 'malformed-records') {
        $intExitCode = 3
    } elseif ($strCategory -eq 'native-command' -or $strCategory -eq 'native-output-limit') {
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
    NativeExit = $intNativeExit
    ExpectedCount = $intExpectedCount
    ActualCount = $intActualCount
    MissingCount = if ($strCategory -eq 'path-set-mismatch') { $intMissingCount } else { 0 }
    UnexpectedCount = if ($strCategory -eq 'path-set-mismatch') { $intUnexpectedCount } else { 0 }
    WorkingCount = $objWorkingKeys.Count
    StagedCount = $objStagedKeys.Count
    UntrackedCount = $objUntrackedKeys.Count
    ExitCode = $intExitCode
}
Write-VerifierResult -Result $hashtableResult
exit $intExitCode
