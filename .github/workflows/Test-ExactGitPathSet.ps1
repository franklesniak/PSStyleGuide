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
Version: 1.0.20260812.0
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

$script:versionVerifier = '1.0.20260812.0'
$script:strVerifierResultSchema = 'PSStyleGuide.ExactGitPathSetResult.v1'

function Get-ScriptVersionRecord {
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

function ConvertFrom-NulPathRecord {
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

function New-ExpectedPathKey {
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
    [void](Get-ScriptVersionRecord -ScriptText $strSelfText -ExpectedVersion $script:versionVerifier)

    $strRepositoryRoot = Assert-OrdinaryRepositoryRoot -LiteralPath $RepositoryRoot

    $objExpectedKeys = New-ExpectedPathKey -PathList $ExpectedPath
    $arrGitCommands = @(Get-Command -Name git -CommandType Application -ErrorAction Stop)
    $strGitPath = [string]$arrGitCommands[0].Source

    if ($Mode -in @('Working', 'Both')) {
        $hashtableWorkingResult = Invoke-GitRaw -GitPath $strGitPath -WorkingDirectory $strRepositoryRoot `
            -ArgumentList @('diff', '--no-renames', '--name-only', '-z', '--')
        if ($hashtableWorkingResult.ExitCode -ne 0) {
            $intNativeExit = $hashtableWorkingResult.ExitCode
            throw 'native-command'
        }
        $objWorkingKeys = ConvertFrom-NulPathRecord -Bytes $hashtableWorkingResult.Stdout

        $hashtableUntrackedResult = Invoke-GitRaw -GitPath $strGitPath -WorkingDirectory $strRepositoryRoot `
            -ArgumentList @('ls-files', '--others', '--exclude-standard', '-z', '--')
        if ($hashtableUntrackedResult.ExitCode -ne 0) {
            $intNativeExit = $hashtableUntrackedResult.ExitCode
            throw 'native-command'
        }
        $objUntrackedKeys = ConvertFrom-NulPathRecord -Bytes $hashtableUntrackedResult.Stdout
        Add-KeySet -Target $objWorkingKeys -Source $objUntrackedKeys
    }

    if ($Mode -in @('Staged', 'Both')) {
        $hashtableStagedResult = Invoke-GitRaw -GitPath $strGitPath -WorkingDirectory $strRepositoryRoot `
            -ArgumentList @('diff', '--cached', '--no-renames', '--name-only', '-z', '--')
        if ($hashtableStagedResult.ExitCode -ne 0) {
            $intNativeExit = $hashtableStagedResult.ExitCode
            throw 'native-command'
        }
        $objStagedKeys = ConvertFrom-NulPathRecord -Bytes $hashtableStagedResult.Stdout
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
    VerifierVersion = $script:versionVerifier
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
