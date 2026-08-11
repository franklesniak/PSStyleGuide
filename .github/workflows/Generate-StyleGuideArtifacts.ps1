#Requires -Version 5.1

<#
.SYNOPSIS
Generates the four repository-owned style-guide artifacts.

.DESCRIPTION
Builds every complete payload from the two fixed sources before replacing any
fixed destination. Serialization is UTF-8 without a BOM and normalizes CRLF
and lone CR to LF at the final payload boundary.

.NOTES
Version: 1.0.20260812.0
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:versionGenerator = '1.0.20260812.0'
$script:strGeneratorResultSchema = 'PSStyleGuide.GeneratorResult.v1'
$script:objUtf8Strict = New-Object System.Text.UTF8Encoding($false, $true)
$script:objUtf8NoBom = New-Object System.Text.UTF8Encoding($false)
$script:objPathComparison = if ($env:OS -eq 'Windows_NT') {
    [System.StringComparison]::OrdinalIgnoreCase
} else {
    [System.StringComparison]::Ordinal
}

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

function ConvertTo-LowerHex {
    param (
        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes
    )

    return ([System.BitConverter]::ToString($Bytes) -replace '-', '').ToLowerInvariant()
}

function Get-Sha256Hex {
    param (
        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes
    )

    $objSha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        return ConvertTo-LowerHex -Bytes $objSha256.ComputeHash($Bytes)
    } finally {
        $objSha256.Dispose()
    }
}

function Get-FileSha256Hex {
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
        return ConvertTo-LowerHex -Bytes $objSha256.ComputeHash($objStream)
    } finally {
        $objSha256.Dispose()
        $objStream.Dispose()
    }
}

function Test-PathTextIsSafe {
    param (
        [AllowNull()]
        [string]$RawPath
    )

    if ($null -eq $RawPath -or $RawPath.Length -eq 0 -or $RawPath.Trim().Length -eq 0) {
        return $false
    }

    foreach ($chrCharacter in $RawPath.ToCharArray()) {
        $intCodePoint = [int]$chrCharacter
        if ($intCodePoint -lt 32 -or $intCodePoint -eq 127) {
            return $false
        }
    }

    if ($RawPath.IndexOfAny([char[]]'*?[]') -ge 0 -or $RawPath -match '^[^\\/]+::') {
        return $false
    }

    if (-not [System.IO.Path]::IsPathRooted($RawPath) -or $RawPath -match '^[A-Za-z]:[^\\/]') {
        return $false
    }

    return $true
}

function Assert-OrdinaryPathComponent {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Directory', 'File')]
        [string]$ExpectedType
    )

    if (-not [System.IO.File]::Exists($LiteralPath) -and -not [System.IO.Directory]::Exists($LiteralPath)) {
        throw "missing-path"
    }

    $objAttributes = [System.IO.File]::GetAttributes($LiteralPath)
    if (($objAttributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw "reparse-path"
    }

    $boolIsDirectory = ($objAttributes -band [System.IO.FileAttributes]::Directory) -ne 0
    if (($ExpectedType -eq 'Directory' -and -not $boolIsDirectory) -or
        ($ExpectedType -eq 'File' -and $boolIsDirectory)) {
        throw "nonordinary-path"
    }
}

function Assert-OrdinaryAbsolutePath {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [ValidateSet('Directory', 'File')]
        [string]$ExpectedLeafType
    )

    if (-not (Test-PathTextIsSafe -RawPath $LiteralPath)) {
        throw "invalid-path"
    }

    $strFullPath = [System.IO.Path]::GetFullPath($LiteralPath)
    $listComponents = New-Object 'System.Collections.Generic.List[System.IO.FileSystemInfo]'
    if ($ExpectedLeafType -eq 'Directory') {
        $objLeaf = New-Object System.IO.DirectoryInfo($strFullPath)
        $objCurrent = $objLeaf
    } else {
        $objLeaf = New-Object System.IO.FileInfo($strFullPath)
        $listComponents.Add($objLeaf)
        $objCurrent = $objLeaf.Directory
    }
    while ($null -ne $objCurrent) {
        $listComponents.Add($objCurrent)
        $objCurrent = $objCurrent.Parent
    }

    for ($intIndex = $listComponents.Count - 1; $intIndex -ge 0; $intIndex--) {
        $strExpectedType = if ($intIndex -eq 0) { $ExpectedLeafType } else { 'Directory' }
        Assert-OrdinaryPathComponent -LiteralPath $listComponents[$intIndex].FullName -ExpectedType $strExpectedType
    }

    return $strFullPath
}

function Test-PathContainedByRoot {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Root,

        [Parameter(Mandatory = $true)]
        [string]$Candidate
    )

    $strRootWithSeparator = $Root.TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    ) + [System.IO.Path]::DirectorySeparatorChar

    return $Candidate.StartsWith($strRootWithSeparator, $script:objPathComparison)
}

function Initialize-WindowsFileIdentityType {
    if ($env:OS -ne 'Windows_NT' -or ('PSStyleGuide.NativeFileIdentity' -as [type])) {
        return
    }

    Add-Type -TypeDefinition @'
using System;
using System.ComponentModel;
using System.IO;
using System.Runtime.InteropServices;

namespace PSStyleGuide {
    public static class NativeFileIdentity {
        [StructLayout(LayoutKind.Sequential)]
        private struct ByHandleFileInformation {
            public uint FileAttributes;
            public System.Runtime.InteropServices.ComTypes.FILETIME CreationTime;
            public System.Runtime.InteropServices.ComTypes.FILETIME LastAccessTime;
            public System.Runtime.InteropServices.ComTypes.FILETIME LastWriteTime;
            public uint VolumeSerialNumber;
            public uint FileSizeHigh;
            public uint FileSizeLow;
            public uint NumberOfLinks;
            public uint FileIndexHigh;
            public uint FileIndexLow;
        }

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool GetFileInformationByHandle(
            Microsoft.Win32.SafeHandles.SafeFileHandle handle,
            out ByHandleFileInformation information);

        public static string Read(string path) {
            using (FileStream stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.Read)) {
                ByHandleFileInformation information;
                if (!GetFileInformationByHandle(stream.SafeFileHandle, out information)) {
                    throw new Win32Exception(Marshal.GetLastWin32Error());
                }
                if (information.NumberOfLinks != 1) {
                    throw new InvalidDataException("hardlink-alias");
                }
                ulong index = ((ulong)information.FileIndexHigh << 32) | information.FileIndexLow;
                return information.VolumeSerialNumber.ToString("x8") + ":" + index.ToString("x16");
            }
        }
    }
}
'@
}

function Get-OrdinaryFileIdentity {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath
    )

    if ($env:OS -eq 'Windows_NT') {
        Initialize-WindowsFileIdentityType
        return [PSStyleGuide.NativeFileIdentity]::Read($LiteralPath)
    }

    $arrStatOutput = @(& stat '-Lc' '%h:%d:%i' '--' $LiteralPath)
    $intStatExit = $LASTEXITCODE
    if ($intStatExit -ne 0 -or $arrStatOutput.Count -ne 1 -or
        $arrStatOutput[0] -notmatch '^([1-9][0-9]*):([0-9]+):([0-9]+)$') {
        throw "identity-failure"
    }
    if ([uint64]$Matches[1] -ne 1) {
        throw "hardlink-alias"
    }
    return $Matches[2] + ':' + $Matches[3]
}

function Assert-TrackedFile {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,

        [Parameter(Mandatory = $true)]
        [string]$RepositoryPath
    )

    $arrGitCommands = @(Get-Command -Name git -CommandType Application -ErrorAction Stop)
    $strGitPath = [string]$arrGitCommands[0].Source
    $arrOutput = @(& $strGitPath -C $RepositoryRoot ls-files --error-unmatch -- $RepositoryPath 2>$null)
    $intGitExit = $LASTEXITCODE
    if ($intGitExit -ne 0 -or $arrOutput.Count -ne 1 -or $arrOutput[0] -cne $RepositoryPath) {
        throw "untracked-destination"
    }
}

function ConvertFrom-StrictUtf8 {
    param (
        [Parameter(Mandatory = $true)]
        [byte[]]$Bytes
    )

    if ($Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF) {
        throw "utf8-bom"
    }
    return $script:objUtf8Strict.GetString($Bytes)
}

function ConvertTo-NormalizedUtf8 {
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$CompleteFinalPayload
    )

    $strNormalizedContent = $CompleteFinalPayload -replace "`r`n?", "`n"
    return $script:objUtf8NoBom.GetBytes($strNormalizedContent)
}

function New-CopilotPayload {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'Builds an in-memory value and changes no system state; ShouldProcess does not apply.'
    )]
    param (
        [Parameter(Mandatory = $true)]
        [string]$GuideContent
    )

    return $GuideContent
}

function New-PowerShellInstructionsPayload {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'Builds an in-memory value and changes no system state; ShouldProcess does not apply.'
    )]
    param (
        [Parameter(Mandatory = $true)]
        [string]$GuideContent
    )

    $arrFrontmatterLines = @(
        '---',
        'applyTo:  "**/*.ps1"',
        'description: "PowerShell coding standards"',
        '---',
        '',
        ''
    )
    return ($arrFrontmatterLines -join "`n") + $GuideContent
}

function New-ChatPayload {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'Builds an in-memory value and changes no system state; ShouldProcess does not apply.'
    )]
    param (
        [Parameter(Mandatory = $true)]
        [string]$GuideContent
    )

    $strContent = $GuideContent -replace '\r?\n$', ''
    $arrMatches = [regex]::Matches($strContent, '``+')
    $intMaximumBackticks = 0
    foreach ($objMatch in $arrMatches) {
        if ($objMatch.Length -gt $intMaximumBackticks) {
            $intMaximumBackticks = $objMatch.Length
        }
    }
    $intOuterFenceLength = [System.Math]::Max(4, $intMaximumBackticks + 1)
    $strOuterFence = '`' * $intOuterFenceLength
    return "# PowerShell Writing Style Guide - Formatted for Copy-Paste Into LLM Chat`n`n$strOuterFence" +
        "markdown`n$strContent`n$strOuterFence`n"
}

function New-FullPayload {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'Builds an in-memory value and changes no system state; ShouldProcess does not apply.'
    )]
    param (
        [Parameter(Mandatory = $true)]
        [string]$GuideContent,

        [Parameter(Mandatory = $true)]
        [string]$RationaleContent
    )

    $arrRationaleLines = $RationaleContent -split '\r?\n'
    $hashtableSections = @{}
    $hashtableRationaleHeadings = @{}
    $strCurrentAnchor = $null
    $intCurrentLevel = 0
    $listCurrentBody = New-Object 'System.Collections.Generic.List[string]'

    foreach ($strLine in $arrRationaleLines) {
        if ($strLine -match '^(#{2,4}) (.+)$') {
            $intLevel = $Matches[1].Length
            $strHeadingText = $Matches[2]
            if ($null -ne $strCurrentAnchor -and $intCurrentLevel -eq 3) {
                $hashtableSections[$strCurrentAnchor] = $listCurrentBody.ToArray()
            }
            $strAnchor = $strHeadingText.ToLower() -replace '[^a-z0-9 -]', '' -replace ' ', '-'
            $strAnchor = $strAnchor -replace '-+', '-' -replace '^-|-$', ''
            if ($intLevel -eq 3) {
                $strCurrentAnchor = $strAnchor
                $intCurrentLevel = 3
                $listCurrentBody = New-Object 'System.Collections.Generic.List[string]'
                $hashtableRationaleHeadings[$strAnchor] = '### ' + $strHeadingText
            } elseif ($intLevel -eq 2) {
                $strCurrentAnchor = $null
                $intCurrentLevel = 2
            } elseif ($null -ne $strCurrentAnchor -and $intCurrentLevel -eq 3) {
                $listCurrentBody.Add($strLine)
            }
        } elseif ($null -ne $strCurrentAnchor -and $intCurrentLevel -eq 3) {
            $listCurrentBody.Add($strLine)
        }
    }
    if ($null -ne $strCurrentAnchor -and $intCurrentLevel -eq 3) {
        $hashtableSections[$strCurrentAnchor] = $listCurrentBody.ToArray()
    }

    $boolInExecutiveSummary = $false
    $listCurrentBody = New-Object 'System.Collections.Generic.List[string]'
    foreach ($strLine in $arrRationaleLines) {
        if ($strLine -match '^## Executive Summary: Author Profile') {
            $boolInExecutiveSummary = $true
            $listCurrentBody = New-Object 'System.Collections.Generic.List[string]'
        } elseif ($boolInExecutiveSummary -and $strLine -match '^## ') {
            $hashtableSections['executive-summary-author-profile'] = $listCurrentBody.ToArray()
            $hashtableRationaleHeadings['executive-summary-author-profile'] = '## Executive Summary: Author Profile'
            $boolInExecutiveSummary = $false
        } elseif ($boolInExecutiveSummary) {
            $listCurrentBody.Add($strLine)
        }
    }
    if ($boolInExecutiveSummary) {
        $hashtableSections['executive-summary-author-profile'] = $listCurrentBody.ToArray()
        $hashtableRationaleHeadings['executive-summary-author-profile'] = '## Executive Summary: Author Profile'
    }

    $hashtableCleanSections = @{}
    foreach ($strKey in $hashtableSections.Keys) {
        $arrFiltered = @($hashtableSections[$strKey] | Where-Object {
            -not ($_ -match '^> For .+\(STYLE_GUIDE\.md#')
        })
        $arrConverted = @($arrFiltered | ForEach-Object {
            $_ -replace 'STYLE_GUIDE\.md#', '#' -replace '\[([^\]]+)\]\(STYLE_GUIDE\.md\)', '[$1](#powershell-writing-style)'
        })
        $intStart = 0
        while ($intStart -lt $arrConverted.Count -and $arrConverted[$intStart].Trim() -eq '') {
            $intStart++
        }
        $intEnd = $arrConverted.Count - 1
        while ($intEnd -ge 0 -and
            ($arrConverted[$intEnd].Trim() -eq '' -or $arrConverted[$intEnd].Trim() -eq '---')) {
            $intEnd--
        }
        if ($intStart -le $intEnd) {
            $hashtableCleanSections[$strKey] = $arrConverted[$intStart..$intEnd]
        }
    }

    $arrGuideLines = $GuideContent -split '\r?\n'
    $listOutputLines = New-Object 'System.Collections.Generic.List[string]'
    foreach ($strLine in $arrGuideLines) {
        if ($strLine.Trim() -eq '*This section intentionally left blank.*') {
            continue
        }
        if ($strLine -match '^\s*<!--\s*rationale-toc:\s*(.+?)\s*-->\s*$') {
            $listOutputLines.Add($Matches[1].Trim())
            continue
        }
        if ($strLine -match '^\s*<!--\s*rationale-anchor:\s*(.+?)\s*-->\s*$') {
            $strCommentAnchor = $Matches[1].Trim()
            if (-not $hashtableCleanSections.ContainsKey($strCommentAnchor) -or
                -not $hashtableRationaleHeadings.ContainsKey($strCommentAnchor)) {
                throw "missing-rationale-anchor"
            }
            $listOutputLines.Add('')
            $listOutputLines.Add($hashtableRationaleHeadings[$strCommentAnchor])
            $listOutputLines.Add('')
            foreach ($strRationaleLine in $hashtableCleanSections[$strCommentAnchor]) {
                $listOutputLines.Add($strRationaleLine)
            }
            continue
        }

        $listOutputLines.Add($strLine)
        if ($strLine -match '^(#{2,3}) (.+)$') {
            $strHeadingText = $Matches[2]
            $strAnchor = $strHeadingText.ToLower() -replace '[^a-z0-9 -]', '' -replace ' ', '-'
            $strAnchor = $strAnchor -replace '-+', '-' -replace '^-|-$', ''
            if ($hashtableCleanSections.ContainsKey($strAnchor)) {
                $listOutputLines.Add('')
                foreach ($strRationaleLine in $hashtableCleanSections[$strAnchor]) {
                    $listOutputLines.Add($strRationaleLine)
                }
            }
        }
    }

    $strOutput = $listOutputLines.ToArray() -join "`n"
    while ($strOutput -match "`n`n`n") {
        $strOutput = $strOutput -replace "`n`n`n", "`n`n"
    }
    return $strOutput.TrimEnd("`n") + "`n"
}

function New-StyleGuidePayload {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'Builds an in-memory value and changes no system state; ShouldProcess does not apply.'
    )]
    param (
        [Parameter(Mandatory = $true)]
        [byte[]]$GuideBytes,

        [Parameter(Mandatory = $true)]
        [byte[]]$RationaleBytes
    )

    $strGuideContent = ConvertFrom-StrictUtf8 -Bytes $GuideBytes
    $strRationaleContent = ConvertFrom-StrictUtf8 -Bytes $RationaleBytes
    $hashtablePayloadStrings = [ordered]@{
        copilot = New-CopilotPayload -GuideContent $strGuideContent
        'powershell-instructions' = New-PowerShellInstructionsPayload -GuideContent $strGuideContent
        chat = New-ChatPayload -GuideContent $strGuideContent
        full = New-FullPayload -GuideContent $strGuideContent -RationaleContent $strRationaleContent
    }

    $hashtablePayloadBytes = [ordered]@{}
    foreach ($strArtifactId in $hashtablePayloadStrings.Keys) {
        $arrBytes = ConvertTo-NormalizedUtf8 -CompleteFinalPayload $hashtablePayloadStrings[$strArtifactId]
        if ($arrBytes.Length -ge 3 -and $arrBytes[0] -eq 0xEF -and $arrBytes[1] -eq 0xBB -and $arrBytes[2] -eq 0xBF) {
            throw "payload-bom"
        }
        if ($arrBytes -contains [byte]0x0D) {
            throw "payload-cr"
        }
        $hashtablePayloadBytes[$strArtifactId] = $arrBytes
    }
    return $hashtablePayloadBytes
}

function New-ArtifactRecord {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'Builds an in-memory value and changes no system state; ShouldProcess does not apply.'
    )]
    param (
        [Parameter(Mandatory = $true)]
        [string]$ArtifactId,

        [Parameter(Mandatory = $true)]
        [string]$RepositoryPath
    )

    return [ordered]@{
        ArtifactId = $ArtifactId
        Path = $RepositoryPath
        OriginalLength = $null
        OriginalSha256 = $null
        OriginalOrdinaryIdentity = $null
        CandidateLength = $null
        CandidateSha256 = $null
        CandidateOrdinaryIdentity = $null
        FinalLength = $null
        FinalSha256 = $null
        FinalOrdinaryIdentity = $null
        ReplaceReturned = $false
        TemporaryDisposition = 'NotCreated'
        CleanupResult = 'NotRequired'
        Status = 'Pending'
    }
}

function Initialize-AtomicFileReplacementType {
    if ('PSStyleGuide.AtomicFileReplacement' -as [type]) {
        return
    }

    Add-Type -TypeDefinition @'
using System.IO;

namespace PSStyleGuide {
    public static class AtomicFileReplacement {
        public static void Replace(string candidatePath, string destinationPath) {
            File.Replace(candidatePath, destinationPath, null);
        }
    }
}
'@
}

function Write-StyleGuideArtifact {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('copilot', 'powershell-instructions', 'chat', 'full')]
        [string]$ArtifactId,

        [Parameter(Mandatory = $true)]
        [string]$RawDestinationPath,

        [Parameter(Mandatory = $true)]
        [byte[]]$CompletePayloadBytes,

        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$DestinationMap
    )

    $strExpectedRepositoryPath = $DestinationMap[$ArtifactId]
    $hashtableRecord = New-ArtifactRecord -ArtifactId $ArtifactId -RepositoryPath $strExpectedRepositoryPath
    $strTemporaryPath = $null
    $boolTemporaryIdentityProven = $false
    $strPhase = 'validate-destination'

    try {
        if (-not (Test-PathTextIsSafe -RawPath $RawDestinationPath)) {
            throw "invalid-destination"
        }
        $strExpectedFullPath = [System.IO.Path]::GetFullPath(
            (Join-Path $RepositoryRoot ($strExpectedRepositoryPath -replace '/', [System.IO.Path]::DirectorySeparatorChar))
        )
        $strDestinationPath = [System.IO.Path]::GetFullPath($RawDestinationPath)
        if (-not (Test-PathContainedByRoot -Root $RepositoryRoot -Candidate $strDestinationPath) -or
            -not $strDestinationPath.Equals($strExpectedFullPath, $script:objPathComparison)) {
            throw "artifact-path-mismatch"
        }
        $strDestinationPath = Assert-OrdinaryAbsolutePath -LiteralPath $strDestinationPath -ExpectedLeafType File
        Assert-TrackedFile -RepositoryRoot $RepositoryRoot -RepositoryPath $strExpectedRepositoryPath

        $hashtableRecord.OriginalLength = (New-Object System.IO.FileInfo($strDestinationPath)).Length
        $hashtableRecord.OriginalSha256 = Get-FileSha256Hex -LiteralPath $strDestinationPath
        $hashtableRecord.OriginalOrdinaryIdentity = Get-OrdinaryFileIdentity -LiteralPath $strDestinationPath
        $strParentPath = [System.IO.Path]::GetDirectoryName($strDestinationPath)
        [void](Assert-OrdinaryAbsolutePath -LiteralPath $strParentPath -ExpectedLeafType Directory)

        $hashtableRecord.CandidateLength = $CompletePayloadBytes.Length
        $hashtableRecord.CandidateSha256 = Get-Sha256Hex -Bytes $CompletePayloadBytes

        if ($hashtableRecord.OriginalLength -eq $hashtableRecord.CandidateLength -and
            $hashtableRecord.OriginalSha256 -ceq $hashtableRecord.CandidateSha256) {
            $hashtableRecord.FinalLength = $hashtableRecord.OriginalLength
            $hashtableRecord.FinalSha256 = $hashtableRecord.OriginalSha256
            $hashtableRecord.FinalOrdinaryIdentity = $hashtableRecord.OriginalOrdinaryIdentity
            $hashtableRecord.Status = 'NoChange'
            return $hashtableRecord
        }

        $strPhase = 'create-candidate'
        $objCandidateStream = $null
        for ($intAttempt = 1; $intAttempt -le 16; $intAttempt++) {
            $strCandidateLeaf = '.psstyleguide-' + [guid]::NewGuid().ToString('N') + '.tmp'
            $strTemporaryPath = Join-Path $strParentPath $strCandidateLeaf
            try {
                $objCandidateStream = New-Object System.IO.FileStream(
                    $strTemporaryPath,
                    [System.IO.FileMode]::CreateNew,
                    [System.IO.FileAccess]::Write,
                    [System.IO.FileShare]::None
                )
                $hashtableRecord.TemporaryDisposition = 'Created'
                break
            } catch [System.IO.IOException] {
                if ($intAttempt -eq 16) {
                    throw
                }
            }
        }
        if ($null -eq $objCandidateStream) {
            throw "candidate-create-failure"
        }

        try {
            $strPhase = 'write-candidate'
            $objCandidateStream.Write($CompletePayloadBytes, 0, $CompletePayloadBytes.Length)
            $strPhase = 'flush-candidate'
            $objCandidateStream.Flush($true)
        } finally {
            $objCandidateStream.Dispose()
        }

        $strPhase = 'verify-candidate'
        $strCandidateFullPath = Assert-OrdinaryAbsolutePath -LiteralPath $strTemporaryPath -ExpectedLeafType File
        if (-not [System.IO.Path]::GetDirectoryName($strCandidateFullPath).Equals($strParentPath, $script:objPathComparison)) {
            throw "candidate-parent-mismatch"
        }
        $strCandidateIdentity = Get-OrdinaryFileIdentity -LiteralPath $strCandidateFullPath
        $boolTemporaryIdentityProven = $true
        $hashtableRecord.CandidateOrdinaryIdentity = $strCandidateIdentity
        $objCandidateInfo = New-Object System.IO.FileInfo($strCandidateFullPath)
        if ($objCandidateInfo.Length -ne $CompletePayloadBytes.Length -or
            (Get-FileSha256Hex -LiteralPath $strCandidateFullPath) -cne $hashtableRecord.CandidateSha256) {
            throw "candidate-byte-mismatch"
        }
        $arrCandidateBytes = [System.IO.File]::ReadAllBytes($strCandidateFullPath)
        if (($arrCandidateBytes.Length -ge 3 -and $arrCandidateBytes[0] -eq 0xEF -and
            $arrCandidateBytes[1] -eq 0xBB -and $arrCandidateBytes[2] -eq 0xBF) -or
            $arrCandidateBytes -contains [byte]0x0D -or
            $arrCandidateBytes.Length -eq 0 -or
            $arrCandidateBytes[$arrCandidateBytes.Length - 1] -ne 0x0A) {
            throw "candidate-serialization"
        }

        $strPhase = 'replace-destination'
        [void](Assert-OrdinaryAbsolutePath -LiteralPath $strParentPath -ExpectedLeafType Directory)
        [void](Assert-OrdinaryAbsolutePath -LiteralPath $strDestinationPath -ExpectedLeafType File)
        if ((Get-OrdinaryFileIdentity -LiteralPath $strDestinationPath) -cne
            $hashtableRecord.OriginalOrdinaryIdentity) {
            throw "destination-identity-drift"
        }
        if ((Get-FileSha256Hex -LiteralPath $strDestinationPath) -cne $hashtableRecord.OriginalSha256) {
            throw "destination-content-drift"
        }
        if ((Get-OrdinaryFileIdentity -LiteralPath $strTemporaryPath) -cne $strCandidateIdentity) {
            throw "candidate-identity-drift"
        }

        Initialize-AtomicFileReplacementType
        [PSStyleGuide.AtomicFileReplacement]::Replace($strTemporaryPath, $strDestinationPath)
        $hashtableRecord.ReplaceReturned = $true
        $hashtableRecord.TemporaryDisposition = 'ConsumedByReplace'
        $hashtableRecord.CleanupResult = 'NotRequired'
        # Measure the destination rather than assert it. File.Replace throws on
        # failure, so reaching here means it returned, but every other field in
        # this record is proven; recording the candidate's values as the
        # destination's would make the evidence a claim instead of a result. The
        # replacement has already happened by this point, so a mismatch here is
        # ReplacementStateUncertain rather than Failed.
        $strPhase = 'verify-replacement'
        if ([System.IO.File]::Exists($strTemporaryPath)) {
            $hashtableRecord.TemporaryDisposition = 'RetainedForRecovery'
            $hashtableRecord.CleanupResult = 'NotAttempted'
            $hashtableRecord.Status = 'ReplacementStateUncertain'
            throw "candidate-not-consumed"
        }
        [void](Assert-OrdinaryAbsolutePath -LiteralPath $strDestinationPath -ExpectedLeafType File)
        # Record what was observed before comparing it. Drift is precisely the case
        # where the observed destination state is the evidence needed to diagnose or
        # recover, so comparing first and throwing would empty the record of the one
        # thing it exists to carry.
        $hashtableRecord.FinalSha256 = Get-FileSha256Hex -LiteralPath $strDestinationPath
        $hashtableRecord.FinalLength = [System.IO.FileInfo]::new($strDestinationPath).Length
        $hashtableRecord.FinalOrdinaryIdentity = Get-OrdinaryFileIdentity -LiteralPath $strDestinationPath
        if ($hashtableRecord.FinalSha256 -cne $hashtableRecord.CandidateSha256) {
            $hashtableRecord.Status = 'ReplacementStateUncertain'
            throw "final-content-drift"
        }
        if ($hashtableRecord.FinalLength -ne $CompletePayloadBytes.Length) {
            $hashtableRecord.Status = 'ReplacementStateUncertain'
            throw "final-length-drift"
        }
        $hashtableRecord.Status = 'Success'
        return $hashtableRecord
    } catch {
        $objOriginalError = $_
        if (-not $hashtableRecord.ReplaceReturned -and $null -ne $strTemporaryPath -and
            [System.IO.File]::Exists($strTemporaryPath)) {
            if ($boolTemporaryIdentityProven) {
                try {
                    [System.IO.File]::Delete($strTemporaryPath)
                    $hashtableRecord.TemporaryDisposition = 'RemovedAfterFailure'
                    $hashtableRecord.CleanupResult = 'Success'
                } catch {
                    $hashtableRecord.TemporaryDisposition = 'RetainedForRecovery'
                    $hashtableRecord.CleanupResult = 'Failed'
                    $hashtableRecord.Status = 'ReplacementStateUncertain'
                }
            } else {
                $hashtableRecord.TemporaryDisposition = 'IdentityUnproven'
                $hashtableRecord.CleanupResult = 'NotAttempted'
                $hashtableRecord.Status = 'ReplacementStateUncertain'
            }
        }
        if ($hashtableRecord.Status -eq 'Pending') {
            $hashtableRecord.Status = 'Failed'
        }
        $objException = New-Object System.InvalidOperationException(
            ($strPhase + ':' + $objOriginalError.Exception.Message),
            $objOriginalError.Exception
        )
        $objException.Data['ArtifactRecord'] = $hashtableRecord
        $objException.Data['Phase'] = $strPhase
        throw $objException
    }
}

function Write-GeneratorResult {
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Result
    )

    [Console]::Out.WriteLine(($Result | ConvertTo-Json -Depth 8 -Compress))
}

$listArtifactRecords = New-Object 'System.Collections.Generic.List[object]'
$strOverall = 'Failed'
$strResultPhase = 'initialize'
$strResultCategory = 'tool-failure'
$strNativeOutcome = 'NotApplicable'
$intExitCode = 1

try {
    Test-ScriptVersionParser
    $strSelfPath = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot 'Generate-StyleGuideArtifacts.ps1'))
    $arrSelfBytes = [System.IO.File]::ReadAllBytes($strSelfPath)
    $strSelfText = $script:objUtf8Strict.GetString($arrSelfBytes)
    [void](Get-ScriptVersionRecord -ScriptText $strSelfText -ExpectedVersion $script:versionGenerator)

    $strResultPhase = 'validate-fixed-authority'
    $strWorkflowRoot = Assert-OrdinaryAbsolutePath -LiteralPath $PSScriptRoot -ExpectedLeafType Directory
    $strRepositoryRootCandidate = Join-Path -Path (
        Join-Path -Path $strWorkflowRoot -ChildPath '..'
    ) -ChildPath '..'
    $strRepositoryRoot = Assert-OrdinaryAbsolutePath -LiteralPath (
        [System.IO.Path]::GetFullPath($strRepositoryRootCandidate)
    ) -ExpectedLeafType Directory

    $hashtableSourceMap = [ordered]@{
        guide = 'STYLE_GUIDE.md'
        rationale = 'STYLE_GUIDE_RATIONALE.md'
    }
    $hashtableDestinationMap = [ordered]@{
        copilot = 'copilot-instructions.md'
        'powershell-instructions' = 'powershell.instructions.md'
        chat = 'STYLE_GUIDE_CHAT.md'
        full = 'STYLE_GUIDE_FULL.md'
    }

    $hashtableIdentities = @{}
    $hashtableSourceBytes = @{}
    foreach ($strSourceId in $hashtableSourceMap.Keys) {
        $strRepositoryPath = $hashtableSourceMap[$strSourceId]
        $strSourcePath = [System.IO.Path]::GetFullPath((Join-Path $strRepositoryRoot $strRepositoryPath))
        if (-not (Test-PathContainedByRoot -Root $strRepositoryRoot -Candidate $strSourcePath)) {
            throw "source-containment"
        }
        $strSourcePath = Assert-OrdinaryAbsolutePath -LiteralPath $strSourcePath -ExpectedLeafType File
        $strIdentity = Get-OrdinaryFileIdentity -LiteralPath $strSourcePath
        if ($hashtableIdentities.ContainsKey($strIdentity)) {
            throw "duplicate-source-identity"
        }
        $hashtableIdentities[$strIdentity] = $strRepositoryPath
        $hashtableSourceBytes[$strSourceId] = [System.IO.File]::ReadAllBytes($strSourcePath)
    }
    foreach ($strArtifactId in $hashtableDestinationMap.Keys) {
        $strRepositoryPath = $hashtableDestinationMap[$strArtifactId]
        $strDestinationPath = [System.IO.Path]::GetFullPath((Join-Path $strRepositoryRoot $strRepositoryPath))
        if (-not (Test-PathContainedByRoot -Root $strRepositoryRoot -Candidate $strDestinationPath)) {
            throw "destination-containment"
        }
        $strDestinationPath = Assert-OrdinaryAbsolutePath -LiteralPath $strDestinationPath -ExpectedLeafType File
        Assert-TrackedFile -RepositoryRoot $strRepositoryRoot -RepositoryPath $strRepositoryPath
        $strIdentity = Get-OrdinaryFileIdentity -LiteralPath $strDestinationPath
        if ($hashtableIdentities.ContainsKey($strIdentity)) {
            throw "duplicate-path-identity"
        }
        $hashtableIdentities[$strIdentity] = $strRepositoryPath
    }

    $strResultPhase = 'compute-complete-payloads'
    $hashtablePayloads = New-StyleGuidePayload `
        -GuideBytes $hashtableSourceBytes.guide `
        -RationaleBytes $hashtableSourceBytes.rationale
    if ($hashtablePayloads.Count -ne 4) {
        throw "payload-cardinality"
    }

    $strResultPhase = 'replace-artifacts'
    foreach ($strArtifactId in $hashtableDestinationMap.Keys) {
        $strDestinationPath = [System.IO.Path]::GetFullPath(
            (Join-Path $strRepositoryRoot $hashtableDestinationMap[$strArtifactId])
        )
        try {
            $hashtableRecord = Write-StyleGuideArtifact `
                -ArtifactId $strArtifactId `
                -RawDestinationPath $strDestinationPath `
                -CompletePayloadBytes $hashtablePayloads[$strArtifactId] `
                -RepositoryRoot $strRepositoryRoot `
                -DestinationMap $hashtableDestinationMap
            $listArtifactRecords.Add($hashtableRecord)
        } catch {
            if ($_.Exception.Data.Contains('ArtifactRecord')) {
                $listArtifactRecords.Add($_.Exception.Data['ArtifactRecord'])
                $strResultPhase = [string]$_.Exception.Data['Phase']
                if ($_.Exception.Data['ArtifactRecord'].Status -eq 'ReplacementStateUncertain') {
                    $strOverall = 'ReplacementStateUncertain'
                    $strResultCategory = 'filesystem-state-uncertain'
                } else {
                    $strOverall = 'Failed'
                    $strResultCategory = 'artifact-write-failure'
                }
            }
            throw
        }
    }

    $boolAnyReplacement = @($listArtifactRecords | Where-Object { $_.Status -eq 'Success' }).Count -gt 0
    $strOverall = if ($boolAnyReplacement) { 'Success' } else { 'NoChange' }
    $strResultPhase = 'complete'
    $strResultCategory = 'none'
    $strNativeOutcome = 'Success'
    $intExitCode = 0
} catch {
    if ($strOverall -notin @('Failed', 'ReplacementStateUncertain')) {
        $strOverall = 'Failed'
    }
    if ($strResultCategory -eq 'tool-failure') {
        $strResultCategory = 'validation-failure'
    }
    $strNativeOutcome = $_.Exception.GetType().FullName
    $intExitCode = 1
}

$hashtableResult = [ordered]@{
    Schema = $script:strGeneratorResultSchema
    GeneratorVersion = $script:versionGenerator
    Overall = $strOverall
    Phase = $strResultPhase
    Category = $strResultCategory
    NativeOutcome = $strNativeOutcome
    ExitCode = $intExitCode
    Artifacts = $listArtifactRecords.ToArray()
}
Write-GeneratorResult -Result $hashtableResult
exit $intExitCode
