#Requires -Version 5.1

<#
.SYNOPSIS
Validates and expands one style-guide candidate archive.

.DESCRIPTION
Validates raw caller claims, binds the digest and ZIP reader to one retained
archive stream, validates the complete manifest and limits before candidate
creation, and extracts only fresh ordinary files into a journaled context.

.PARAMETER Context
Specifies the exact invocation-context object to validate and update.

.PARAMETER CheckoutRoot
Specifies the raw repository checkout-root claim.

.PARAMETER TrustedTemporaryRoot
Specifies the raw trusted temporary-root claim.

.PARAMETER DownloadDirectory
Specifies the raw context-owned download-directory claim.

.PARAMETER CandidateDirectory
Specifies the raw context-owned candidate-directory claim.

.PARAMETER ExpectedDigest
Specifies the SHA-256 digest expected for the downloaded archive as exactly 64
hexadecimal characters matching '^[0-9A-Fa-f]{64}$'. Uppercase, lowercase, and
mixed-case hexadecimal are accepted, and the value is compared against the
computed digest without regard to case. The supplied value is never trimmed or
rewritten.

.PARAMETER ArtifactId
Specifies the raw workflow artifact identifier.

.PARAMETER RunId
Specifies the raw workflow run identifier.

.PARAMETER RunAttempt
Specifies the raw workflow run-attempt identifier.

.EXAMPLE
PS> $objContext = .\Expand-StyleGuideCandidateArtifact.ps1 @hashtableParameters

Validates and expands one candidate archive, returning the same context object.

.INPUTS
None. You can't pipe objects to this script.

.OUTPUTS
[pscustomobject] The same validated candidate-invocation context supplied by
the caller.

.NOTES
Version: 1.0.20260802.13
#>

[CmdletBinding(PositionalBinding = $false)]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
    'PSReviewUnusedParameter',
    '',
    Justification = 'The isolated executable-entry script block closes over the raw script parameters.'
)]
[OutputType([pscustomobject])]
param (
    [Parameter()]
    [AllowNull()]
    [AllowEmptyString()]
    [AllowEmptyCollection()]
    [object]$Context,

    [Parameter()]
    [AllowNull()]
    [AllowEmptyString()]
    [AllowEmptyCollection()]
    [object]$CheckoutRoot,

    [Parameter()]
    [AllowNull()]
    [AllowEmptyString()]
    [AllowEmptyCollection()]
    [object]$TrustedTemporaryRoot,

    [Parameter()]
    [AllowNull()]
    [AllowEmptyString()]
    [AllowEmptyCollection()]
    [object]$DownloadDirectory,

    [Parameter()]
    [AllowNull()]
    [AllowEmptyString()]
    [AllowEmptyCollection()]
    [object]$CandidateDirectory,

    [Parameter()]
    [AllowNull()]
    [AllowEmptyString()]
    [AllowEmptyCollection()]
    [object]$ExpectedDigest,

    [Parameter()]
    [AllowNull()]
    [AllowEmptyString()]
    [AllowEmptyCollection()]
    [object]$ArtifactId,

    [Parameter()]
    [AllowNull()]
    [AllowEmptyString()]
    [AllowEmptyCollection()]
    [object]$RunId,

    [Parameter()]
    [AllowNull()]
    [AllowEmptyString()]
    [AllowEmptyCollection()]
    [object]$RunAttempt
)

$script:boolCandidateHelperWasDotSourced = $MyInvocation.InvocationName -eq '.'
$script:hashtableCandidateHelperBoundParameters = $PSBoundParameters
$script:versionCandidateHelper = [System.Version]'1.0.20260802.13'
$script:versionCandidateExpectedContext = [System.Version]'1.0.20260802.8'
$script:strCandidateHelperContextTypeName = 'PSStyleGuide.CandidateInvocationContext.v1'
$script:strCandidateHelperRecordTypeName = 'PSStyleGuide.CandidateOwnershipRecord.v1'
$script:strCandidateHelperCleanupTypeName = 'PSStyleGuide.CandidateCleanupResult.v1'
$script:arrCandidateHelperExpectedName = [string[]]@(
    'copilot-instructions.md',
    'powershell.instructions.md',
    'STYLE_GUIDE_CHAT.md',
    'STYLE_GUIDE_FULL.md'
)
$script:uintCandidateHelperMaximumEntryByte = [uint64](8 * 1024 * 1024)
$script:uintCandidateHelperMaximumTotalByte = [uint64](32 * 1024 * 1024)
$script:uintCandidateHelperMaximumArchiveByte = [uint64](32 * 1024 * 1024)
$script:intCandidateHelperBufferSize = 65536
# The platform decides which comparison, path grammar, link primitive, and
# filesystem-identity rules apply, so it must not be something a caller can
# assert. The OS environment variable is ordinary and inheritable: exporting
# it as Windows_NT to PowerShell 7 on Linux makes every one of those branches
# take its Windows form, which silently disables mount and inode resolution
# and switches path comparison to case-insensitive. OSVersion.Platform is a
# runtime property with no environment input, and is available on both
# Windows PowerShell 5.1 and PowerShell 7.
$script:boolCandidateHelperIsWindows = [System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT
$script:objCandidateHelperPathComparison = if ($script:boolCandidateHelperIsWindows) {
    [System.StringComparison]::OrdinalIgnoreCase
} else {
    [System.StringComparison]::Ordinal
}
$script:objCandidateHelperPathComparer = if ($script:boolCandidateHelperIsWindows) {
    [System.StringComparer]::OrdinalIgnoreCase
} else {
    [System.StringComparer]::Ordinal
}
$script:chrCandidateHelperDirectorySeparator = [System.IO.Path]::DirectorySeparatorChar
$script:chrCandidateHelperAlternateSeparator = [System.IO.Path]::AltDirectorySeparatorChar
$script:scriptBlockNewCandidateHelperException = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Code,

        [Parameter(Mandatory = $true)]
        [string]$Phase,

        [Parameter(Mandatory = $true)]
        [string]$Subreason
    )

    $strMessage = "PSStyleGuide.CandidateExpand.v1|phase=$Phase|code=$Code|subreason=$Subreason"
    $objException = New-Object System.InvalidOperationException($strMessage)
    $objException.Data['PSStyleGuideDiagnosticCode'] = $Code
    $objException.Data['PSStyleGuidePhase'] = $Phase
    $objException.Data['PSStyleGuideSubreason'] = $Subreason
    return $objException
}

$script:scriptBlockStopCandidateHelperOperation = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Code,

        [Parameter(Mandatory = $true)]
        [string]$Phase,

        [Parameter(Mandatory = $true)]
        [string]$Subreason
    )

    throw (& $script:scriptBlockNewCandidateHelperException `
        -Code $Code `
        -Phase $Phase `
        -Subreason $Subreason)
}

$script:scriptBlockGetCandidateHelperFailureField = {
    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord,

        [Parameter(Mandatory = $true)]
        [string]$Key,

        [Parameter(Mandatory = $true)]
        [string]$Fallback
    )

    if ($null -ne $ErrorRecord.Exception -and
        $null -ne $ErrorRecord.Exception.Data -and
        $ErrorRecord.Exception.Data.Contains($Key)) {
        $objValue = $ErrorRecord.Exception.Data[$Key]
        if ($null -ne $objValue -and $objValue.GetType() -eq [System.String] -and
            $objValue.Length -gt 0 -and $objValue.Length -le 96 -and
            $objValue -match '^[A-Za-z0-9-]+$') {
            return [string]$objValue
        }
    }
    return $Fallback
}

$script:scriptBlockAssertCandidateHelperRawString = {
    param (
        [AllowNull()]
        [object]$Value,

        [Parameter(Mandatory = $true)]
        [string]$ParameterName,

        [Parameter(Mandatory = $true)]
        [bool]$IsLabel
    )

    if ($null -eq $Value -or $Value.GetType() -ne [System.String]) {
        & $script:scriptBlockStopCandidateHelperOperation `
            -Code 'parameter' -Phase 'parameter' -Subreason "$ParameterName-type"
    }
    $strValue = [string]$Value
    if ($strValue.Length -eq 0 -or [System.String]::IsNullOrWhiteSpace($strValue)) {
        & $script:scriptBlockStopCandidateHelperOperation `
            -Code 'parameter' -Phase 'parameter' -Subreason "$ParameterName-empty"
    }
    foreach ($chrValue in $strValue.ToCharArray()) {
        if ([System.Char]::IsControl($chrValue)) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'parameter' -Phase 'parameter' -Subreason "$ParameterName-control"
        }
    }
    if ($IsLabel -and $strValue.Length -gt 128) {
        & $script:scriptBlockStopCandidateHelperOperation `
            -Code 'parameter' -Phase 'parameter' -Subreason "$ParameterName-length"
    }
    return $strValue
}

$script:scriptBlockAssertCandidateHelperExactProperty = {
    param (
        [Parameter(Mandatory = $true)]
        [object]$Value,

        [Parameter(Mandatory = $true)]
        [string[]]$ExpectedNames
    )

    $arrProperties = @($Value.PSObject.Properties)
    if ($arrProperties.Count -ne $ExpectedNames.Count) {
        throw 'context-invalid'
    }
    for ($intIndex = 0; $intIndex -lt $ExpectedNames.Count; $intIndex++) {
        if ($arrProperties[$intIndex].Name -cne $ExpectedNames[$intIndex] -or
            $arrProperties[$intIndex].MemberType -ne [System.Management.Automation.PSMemberTypes]::NoteProperty) {
            throw 'context-invalid'
        }
    }
}

$script:scriptBlockAssertCandidateHelperCanonicalStoredPath = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    if ($Value.Length -eq 0 -or
        [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Value) -or
        $Value.IndexOf('::', [System.StringComparison]::Ordinal) -ge 0) {
        throw 'context-invalid'
    }
    foreach ($chrValue in $Value.ToCharArray()) {
        if ([System.Char]::IsControl($chrValue)) {
            throw 'context-invalid'
        }
    }

    if ($script:boolCandidateHelperIsWindows) {
        if ($Value.IndexOf([char]'/') -ge 0) {
            throw 'context-invalid'
        }
        $boolDriveRooted = $Value.Length -ge 3 -and
            [System.Char]::IsLetter($Value[0]) -and
            $Value[1] -eq [char]':' -and
            $Value[2] -eq [char]'\'
        $boolUncRooted = $Value.Length -ge 5 -and
            $Value[0] -eq [char]'\' -and $Value[1] -eq [char]'\'
        if (-not $boolDriveRooted -and -not $boolUncRooted) {
            throw 'context-invalid'
        }
        $strRemainder = if ($boolDriveRooted) {
            $Value.Substring(3)
        } else {
            $Value.Substring(2)
        }
        $arrComponents = @($strRemainder.Split([char]'\'))
        if ($boolUncRooted -and $arrComponents.Count -lt 2) {
            throw 'context-invalid'
        }
    } else {
        if ($Value[0] -ne [char]'/' -or $Value.IndexOf([char]0) -ge 0) {
            throw 'context-invalid'
        }
        $arrComponents = @($Value.Substring(1).Split([char]'/'))
    }

    for ($intIndex = 0; $intIndex -lt $arrComponents.Count; $intIndex++) {
        $strComponent = $arrComponents[$intIndex]
        $boolAllowedTrailingEmpty = $intIndex -eq ($arrComponents.Count - 1) -and
            $strComponent.Length -eq 0 -and
            (($script:boolCandidateHelperIsWindows -and $boolDriveRooted -and $Value.Length -eq 3) -or
                (-not $script:boolCandidateHelperIsWindows -and $Value.Length -eq 1))
        if (-not $boolAllowedTrailingEmpty -and
            ($strComponent.Length -eq 0 -or $strComponent -in @('.', '..'))) {
            throw 'context-invalid'
        }
    }
}

$script:scriptBlockAssertCandidateHelperContext = {
    param (
        [AllowNull()]
        [object]$ContextValue
    )

    if ($null -eq $ContextValue -or
        $ContextValue.GetType() -ne [System.Management.Automation.PSCustomObject] -or
        $ContextValue.PSObject.TypeNames.Count -eq 0 -or
        $ContextValue.PSObject.TypeNames[0] -cne $script:strCandidateHelperContextTypeName) {
        throw 'context-invalid'
    }
    [void](& $script:scriptBlockAssertCandidateHelperExactProperty `
        -Value $ContextValue `
        -ExpectedNames @(
            'SchemaVersion',
            'ContextScriptVersion',
            'InvocationId',
            'DiagnosticLabel',
            'TrustedParentPath',
            'InvocationRootPath',
            'DownloadDirectoryPath',
            'CandidatePath',
            'LifecycleState',
            'NextSequence',
            'OwnershipJournal'
        ))

    if ($ContextValue.SchemaVersion.GetType() -ne [System.UInt32] -or
        $ContextValue.SchemaVersion -ne [uint32]1 -or
        $ContextValue.ContextScriptVersion.GetType() -ne [System.Version] -or
        $ContextValue.ContextScriptVersion -ne $script:versionCandidateExpectedContext -or
        $ContextValue.InvocationId.GetType() -ne [System.Guid] -or
        $ContextValue.InvocationId -eq [System.Guid]::Empty -or
        $ContextValue.DiagnosticLabel.GetType() -ne [System.String] -or
        $ContextValue.DiagnosticLabel.Length -eq 0 -or $ContextValue.DiagnosticLabel.Length -gt 128 -or
        [System.String]::IsNullOrWhiteSpace($ContextValue.DiagnosticLabel) -or
        $ContextValue.TrustedParentPath.GetType() -ne [System.String] -or
        $ContextValue.TrustedParentPath.Length -eq 0 -or
        $ContextValue.InvocationRootPath.GetType() -ne [System.String] -or
        $ContextValue.InvocationRootPath.Length -eq 0 -or
        $ContextValue.DownloadDirectoryPath.GetType() -ne [System.String] -or
        $ContextValue.DownloadDirectoryPath.Length -eq 0 -or
        $ContextValue.CandidatePath.GetType() -ne [System.String] -or
        $ContextValue.CandidatePath.Length -eq 0 -or
        $ContextValue.LifecycleState.GetType() -ne [System.String] -or
        $ContextValue.LifecycleState -cnotin @('Active', 'CleanupFailed', 'Disposed') -or
        $ContextValue.NextSequence.GetType() -ne [System.UInt32] -or
        $ContextValue.OwnershipJournal.GetType() -ne [System.Object[]] -or
        $ContextValue.NextSequence -ne [uint32]$ContextValue.OwnershipJournal.Count) {
        throw 'context-invalid'
    }

    foreach ($strContextPath in @(
        $ContextValue.TrustedParentPath,
        $ContextValue.InvocationRootPath,
        $ContextValue.DownloadDirectoryPath,
        $ContextValue.CandidatePath
    )) {
        [void](& $script:scriptBlockAssertCandidateHelperCanonicalStoredPath -Value $strContextPath)
    }

    foreach ($chrLabel in $ContextValue.DiagnosticLabel.ToCharArray()) {
        if ([System.Char]::IsControl($chrLabel)) {
            throw 'context-invalid'
        }

    }

    $objPaths = New-Object 'System.Collections.Generic.HashSet[string]' `
        ($script:objCandidateHelperPathComparer)
    $hashtableCounts = @{
        InvocationRootDirectory = 0
        DownloadDirectory = 0
        DownloadFile = 0
        CandidateDirectory = 0
        CandidateFile = 0
    }

    for ($intIndex = 0; $intIndex -lt $ContextValue.OwnershipJournal.Count; $intIndex++) {
        $objRecord = $ContextValue.OwnershipJournal[$intIndex]
        if ($null -eq $objRecord -or
            $objRecord.GetType() -ne [System.Management.Automation.PSCustomObject] -or
            $objRecord.PSObject.TypeNames.Count -eq 0 -or
            $objRecord.PSObject.TypeNames[0] -cne $script:strCandidateHelperRecordTypeName) {
            throw 'context-invalid'
        }
        [void](& $script:scriptBlockAssertCandidateHelperExactProperty `
            -Value $objRecord `
            -ExpectedNames @(
                'SchemaVersion',
                'Sequence',
                'Kind',
                'Path',
                'ParentPath',
                'LeafName',
                'ExpectedEntryType',
                'CreationPhase',
                'EntryState',
                'ContentLength',
                'ContentSha256'
            ))
        if ($objRecord.SchemaVersion.GetType() -ne [System.UInt32] -or
            $objRecord.SchemaVersion -ne [uint32]1 -or
            $objRecord.Sequence.GetType() -ne [System.UInt32] -or
            $objRecord.Sequence -ne [uint32]$intIndex -or
            $objRecord.Kind.GetType() -ne [System.String] -or
            -not $hashtableCounts.ContainsKey($objRecord.Kind) -or
            $objRecord.Path.GetType() -ne [System.String] -or $objRecord.Path.Length -eq 0 -or
            $objRecord.ParentPath.GetType() -ne [System.String] -or $objRecord.ParentPath.Length -eq 0 -or
            $objRecord.LeafName.GetType() -ne [System.String] -or $objRecord.LeafName.Length -eq 0 -or
            $objRecord.LeafName -in @('.', '..') -or
            $objRecord.LeafName.IndexOf($script:chrCandidateHelperDirectorySeparator) -ge 0 -or
            $objRecord.LeafName.IndexOf($script:chrCandidateHelperAlternateSeparator) -ge 0 -or
            $objRecord.ExpectedEntryType.GetType() -ne [System.String] -or
            $objRecord.ExpectedEntryType -cnotin @('File', 'Directory') -or
            $objRecord.CreationPhase.GetType() -ne [System.String] -or
            $objRecord.CreationPhase -cnotin @('context', 'download', 'destination', 'extraction') -or
            $objRecord.EntryState.GetType() -ne [System.String] -or
            $objRecord.EntryState -cnotin @('ExpectedAbsent', 'Created', 'Deleted', 'RetainedUncertain')) {
            throw 'context-invalid'
        }


        [void](& $script:scriptBlockAssertCandidateHelperCanonicalStoredPath -Value $objRecord.Path)
        [void](& $script:scriptBlockAssertCandidateHelperCanonicalStoredPath -Value $objRecord.ParentPath)

        $strParentPrefix = $objRecord.ParentPath.TrimEnd(
            $script:chrCandidateHelperDirectorySeparator,
            $script:chrCandidateHelperAlternateSeparator
        ) + $script:chrCandidateHelperDirectorySeparator
        if (-not [System.String]::Equals(
            $strParentPrefix + $objRecord.LeafName,
            $objRecord.Path,
            $script:objCandidateHelperPathComparison
        ) -or -not $objPaths.Add($objRecord.Path)) {
            throw 'context-invalid'
        }

        $hashtableCounts[$objRecord.Kind]++
        if ($objRecord.Kind -in @('InvocationRootDirectory', 'DownloadDirectory', 'CandidateDirectory')) {
            if ($objRecord.ExpectedEntryType -cne 'Directory' -or
                $null -ne $objRecord.ContentLength -or $null -ne $objRecord.ContentSha256) {
                throw 'context-invalid'
            }
        } else {
            if ($objRecord.ExpectedEntryType -cne 'File' -or
                $objRecord.EntryState -eq 'ExpectedAbsent' -or
                $null -eq $objRecord.ContentLength -or
                $objRecord.ContentLength.GetType() -ne [System.UInt64] -or
                $null -eq $objRecord.ContentSha256 -or
                $objRecord.ContentSha256.GetType() -ne [System.String] -or
                $objRecord.ContentSha256 -cnotmatch '^[0-9a-f]{64}$') {
                throw 'context-invalid'
            }
        }

        if ($objRecord.Kind -eq 'InvocationRootDirectory') {
            if ($objRecord.CreationPhase -cne 'context' -or
                $objRecord.EntryState -eq 'ExpectedAbsent') {
                throw 'context-invalid'
            }
        } elseif ($objRecord.Kind -eq 'DownloadDirectory') {
            # ExpectedAbsent is legitimate here and only here. Creation records
            # the invocation root, then creates the download directory, so a
            # failure between those steps leaves this record never created while
            # the root is already owned. Modelling that state lets the creation
            # failure path hand a valid context to cleanup, which skips
            # ExpectedAbsent records and still removes the root instead of
            # leaking it. The reverse - an owned download directory under a root
            # that was never created - remains invalid.
            if ($objRecord.CreationPhase -cne 'context') {
                throw 'context-invalid'
            }
        } elseif ($objRecord.Kind -eq 'DownloadFile') {
            if ($objRecord.CreationPhase -cne 'download') {
                throw 'context-invalid'
            }
        } elseif ($objRecord.Kind -eq 'CandidateDirectory') {
            if (($objRecord.EntryState -eq 'ExpectedAbsent' -and $objRecord.CreationPhase -cne 'context') -or
                ($objRecord.EntryState -ne 'ExpectedAbsent' -and $objRecord.CreationPhase -cne 'destination')) {
                throw 'context-invalid'
            }
        } elseif ($objRecord.CreationPhase -cne 'extraction') {
            throw 'context-invalid'
        }

        if ($objRecord.Kind -eq 'InvocationRootDirectory') {
            if (-not [System.String]::Equals(
                $objRecord.Path,
                $ContextValue.InvocationRootPath,
                $script:objCandidateHelperPathComparison
            ) -or -not [System.String]::Equals(
                $objRecord.ParentPath,
                $ContextValue.TrustedParentPath,
                $script:objCandidateHelperPathComparison
            )) {
                throw 'context-invalid'
            }
        } elseif ($objRecord.Kind -eq 'DownloadDirectory') {
            if (-not [System.String]::Equals(
                $objRecord.Path,
                $ContextValue.DownloadDirectoryPath,
                $script:objCandidateHelperPathComparison
            ) -or -not [System.String]::Equals(
                $objRecord.ParentPath,
                $ContextValue.InvocationRootPath,
                $script:objCandidateHelperPathComparison
            )) {
                throw 'context-invalid'
            }
        } elseif ($objRecord.Kind -eq 'DownloadFile') {
            if (-not [System.String]::Equals(
                $objRecord.ParentPath,
                $ContextValue.DownloadDirectoryPath,
                $script:objCandidateHelperPathComparison
            )) {
                throw 'context-invalid'
            }
        } elseif ($objRecord.Kind -eq 'CandidateDirectory') {
            if (-not [System.String]::Equals(
                $objRecord.Path,
                $ContextValue.CandidatePath,
                $script:objCandidateHelperPathComparison
            ) -or -not [System.String]::Equals(
                $objRecord.ParentPath,
                $ContextValue.InvocationRootPath,
                $script:objCandidateHelperPathComparison
            )) {
                throw 'context-invalid'
            }
        } elseif (-not [System.String]::Equals(
            $objRecord.ParentPath,
            $ContextValue.CandidatePath,
            $script:objCandidateHelperPathComparison
        )) {
            throw 'context-invalid'
        }
    }

    if ($hashtableCounts.InvocationRootDirectory -ne 1 -or
        $hashtableCounts.DownloadDirectory -ne 1 -or
        $hashtableCounts.CandidateDirectory -ne 1 -or
        $hashtableCounts.DownloadFile -gt 1) {
        throw 'context-invalid'
    }
    $objCandidateDirectoryRecord = @($ContextValue.OwnershipJournal | Where-Object {
        $_.Kind -eq 'CandidateDirectory'
    })[0]
    $arrCandidateFileRecords = @($ContextValue.OwnershipJournal | Where-Object {
        $_.Kind -eq 'CandidateFile'
    })
    if ($arrCandidateFileRecords.Count -gt 4 -or
        ($objCandidateDirectoryRecord.EntryState -eq 'ExpectedAbsent' -and
            $arrCandidateFileRecords.Count -ne 0) -or
        ($objCandidateDirectoryRecord.EntryState -eq 'Deleted' -and
            @($arrCandidateFileRecords | Where-Object { $_.EntryState -ne 'Deleted' }).Count -ne 0)) {
        throw 'context-invalid'
    }
    if ($ContextValue.LifecycleState -eq 'Active') {
        $objRootRecord = @($ContextValue.OwnershipJournal | Where-Object {
            $_.Kind -eq 'InvocationRootDirectory'
        })[0]
        $objDownloadDirectoryRecord = @($ContextValue.OwnershipJournal | Where-Object {
            $_.Kind -eq 'DownloadDirectory'
        })[0]
        # An ExpectedAbsent download directory is only ever produced by the
        # context manager's own creation-failure cleanup, which never hands a
        # context back. Everything reaching this script therefore had its
        # download directory created, and accepting the relaxed state here
        # would let a forged context journal an archive and candidate beneath a
        # directory its own record says was never created. Cleanup would then
        # exclude that directory, see it as an unexpected root entry, and reach
        # CleanupFailed after a successful expansion.
        if ($objRootRecord.EntryState -cne 'Created' -or
            $objDownloadDirectoryRecord.EntryState -cne 'Created' -or
            @($ContextValue.OwnershipJournal | Where-Object {
                $_.EntryState -eq 'RetainedUncertain'
            }).Count -ne 0) {
            throw 'context-invalid'
        }
    }
    if ($ContextValue.LifecycleState -eq 'Disposed') {
        foreach ($objRecord in $ContextValue.OwnershipJournal) {
            if ($objRecord.EntryState -in @('Created', 'RetainedUncertain')) {
                throw 'context-invalid'
            }
        }
    }
    if ($ContextValue.LifecycleState -eq 'CleanupFailed') {
        $boolRetained = $false
        foreach ($objRecord in $ContextValue.OwnershipJournal) {
            if ($objRecord.EntryState -eq 'RetainedUncertain') {
                $boolRetained = $true
            }
        }
        if (-not $boolRetained) {
            throw 'context-invalid'
        }
    }
}

$script:scriptBlockNewCandidateHelperRecord = {
    param (
        [Parameter(Mandatory = $true)]
        [uint32]$Sequence,

        [Parameter(Mandatory = $true)]
        [string]$Kind,

        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$ParentPath,

        [Parameter(Mandatory = $true)]
        [string]$LeafName,

        [Parameter(Mandatory = $true)]
        [string]$CreationPhase,

        [Parameter(Mandatory = $true)]
        [uint64]$ContentLength,

        [Parameter(Mandatory = $true)]
        [string]$ContentSha256
    )

    $objRecord = [pscustomobject][ordered]@{
        SchemaVersion = [uint32]1
        Sequence = [uint32]$Sequence
        Kind = [string]$Kind
        Path = [string]$Path
        ParentPath = [string]$ParentPath
        LeafName = [string]$LeafName
        ExpectedEntryType = [string]'File'
        CreationPhase = [string]$CreationPhase
        EntryState = [string]'Created'
        ContentLength = [uint64]$ContentLength
        ContentSha256 = [string]$ContentSha256
    }
    $objRecord.PSObject.TypeNames.Insert(0, $script:strCandidateHelperRecordTypeName)
    return $objRecord
}

$script:scriptBlockAddCandidateHelperRecord = {
    param (
        [Parameter(Mandatory = $true)]
        [object]$ContextValue,

        [Parameter(Mandatory = $true)]
        [object]$Record
    )

    $arrJournal = New-Object object[] ($ContextValue.OwnershipJournal.Count + 1)
    [System.Array]::Copy(
        $ContextValue.OwnershipJournal,
        0,
        $arrJournal,
        0,
        $ContextValue.OwnershipJournal.Count
    )
    $arrJournal[$arrJournal.Length - 1] = $Record
    $ContextValue.OwnershipJournal = [object[]]$arrJournal
    $ContextValue.NextSequence = [uint32]($ContextValue.NextSequence + 1)
}

$script:scriptBlockGetCandidateHelperRetainedSequence = {
    param (
        [Parameter(Mandatory = $true)]
        [object]$ContextValue
    )

    $listSequences = New-Object 'System.Collections.Generic.List[uint32]'
    foreach ($objRecord in $ContextValue.OwnershipJournal) {
        if ($objRecord.EntryState -eq 'RetainedUncertain') {
            $listSequences.Add([uint32]$objRecord.Sequence)
        }
    }
    # The unary comma keeps an empty result an empty array. Returning it
    # bare would unroll to null and break the closed result schema.
    return ,[uint32[]]$listSequences.ToArray()
}

$script:scriptBlockNewCandidateHelperCleanupResult = {
    param (
        [Parameter(Mandatory = $true)]
        [System.Guid]$InvocationId,

        [Parameter(Mandatory = $true)]
        [string]$PreviousState,

        [Parameter(Mandatory = $true)]
        [string]$FinalState,

        [Parameter(Mandatory = $true)]
        [bool]$Success,

        [Parameter(Mandatory = $true)]
        [string]$DiagnosticCode,

        [Parameter(Mandatory = $true)]
        [uint32]$ReferenceToFilesystemCallCount,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [uint32[]]$RetainedRecordSequences
    )

    $objResult = [pscustomobject][ordered]@{
        SchemaVersion = [uint32]1
        ContextScriptVersion = $script:versionCandidateExpectedContext
        InvocationId = $InvocationId
        PreviousState = [string]$PreviousState
        FinalState = [string]$FinalState
        Success = [bool]$Success
        DiagnosticCode = [string]$DiagnosticCode
        FilesystemCallCount = [uint32]$ReferenceToFilesystemCallCount
        RetainedRecordSequences = [uint32[]]@($RetainedRecordSequences)
    }
    $objResult.PSObject.TypeNames.Insert(0, $script:strCandidateHelperCleanupTypeName)
    return $objResult
}

$script:scriptBlockGetCandidateHelperEntry = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [string]$Phase,

        [ref]$ReferenceToFilesystemCallCount
    )

    # The caller supplies the phase. Enumeration runs during download,
    # destination, extraction, post-extraction, and cleanup, so hard-coding a
    # cleanup failure here would report an earlier phase's failure as a cleanup
    # failure and let it match the wrong oracle.
    $strFailureCode = if ($Phase -ceq 'cleanup') {
        'cleanup-owned-entry-uncertain'
    } else {
        "$Phase-invalid"
    }
    try {
        if ($null -ne $ReferenceToFilesystemCallCount) {
            $ReferenceToFilesystemCallCount.Value = [uint32]($ReferenceToFilesystemCallCount.Value + 1)
        }
        return [string[]]@([System.IO.Directory]::EnumerateFileSystemEntries($LiteralPath))
    } catch {
        & $script:scriptBlockStopCandidateHelperOperation `
            -Code $strFailureCode -Phase $Phase -Subreason 'enumeration'
    }
}

$script:scriptBlockTestCandidateHelperEntryPresent = {
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [string[]]$EntryList,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedPath
    )

    $intMatches = 0
    foreach ($strEntry in $EntryList) {
        if ([System.String]::Equals(
            $strEntry,
            $ExpectedPath,
            $script:objCandidateHelperPathComparison
        )) {
            $intMatches++
        }
    }
    return $intMatches -eq 1
}

$script:scriptBlockExpandCandidateHelperMountField = {
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$Value
    )

    # mountinfo escapes space, tab, newline, and backslash as three octal
    # digits. Decoded in one pass so an already-decoded backslash cannot be
    # re-read as the start of another escape.
    $objBuilder = New-Object System.Text.StringBuilder
    for ($intIndex = 0; $intIndex -lt $Value.Length; $intIndex++) {
        if ($Value[$intIndex] -eq '\' -and ($intIndex + 3) -lt $Value.Length) {
            $strOctal = $Value.Substring($intIndex + 1, 3)
            if ($strOctal -cmatch '^[0-7]{3}$') {
                [void]$objBuilder.Append([char][System.Convert]::ToInt32($strOctal, 8))
                $intIndex += 3
                continue
            }
        }
        [void]$objBuilder.Append($Value[$intIndex])
    }
    return $objBuilder.ToString()
}

$script:scriptBlockTestCandidateHelperPathPrefix = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Prefix,

        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if ($Prefix -ceq '/') {
        return $true
    }
    if (-not $Path.StartsWith($Prefix, [System.StringComparison]::Ordinal)) {
        return $false
    }
    return ($Path.Length -eq $Prefix.Length -or $Path[$Prefix.Length] -eq '/')
}

$script:scriptBlockGetCandidateHelperMountResolvedPath = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath
    )

    # A bind mount makes lexical ancestry lie. With /b bound from /a/sub,
    # everything created below /b is physically inside /a, yet walking /b's
    # parents never reaches /a and the two directories have different inodes,
    # so neither the path text nor the identity chain can see the relationship.
    # Mount topology is the only place it is recorded, so each root is resolved
    # to the device and in-filesystem subtree it actually occupies.
    if ($script:boolCandidateHelperIsWindows) {
        return $null
    }
    try {
        $arrMountLines = [string[]]@(
            [System.IO.File]::ReadAllLines('/proc/self/mountinfo')
        )
    } catch {
        & $script:scriptBlockStopCandidateHelperOperation `
            -Code 'root-invalid' -Phase 'root' -Subreason 'mount'
    }
    # Parse first, decide second. Line order in mountinfo does not track
    # visibility: MS_MOVE can place the visible record before the one it
    # hides, so picking the later line can select a hidden filesystem root.
    $listCandidate = New-Object 'System.Collections.Generic.List[object]'
    $objParentIdentifiers = New-Object 'System.Collections.Generic.HashSet[string]' (
        [System.StringComparer]::Ordinal
    )
    foreach ($strLine in $arrMountLines) {
        $arrFields = $strLine.Split(' ')
        if ($arrFields.Count -lt 5) {
            continue
        }
        $strMountPoint = & $script:scriptBlockExpandCandidateHelperMountField -Value $arrFields[4]
        if (-not (& $script:scriptBlockTestCandidateHelperPathPrefix `
                -Prefix $strMountPoint -Path $LiteralPath)) {
            continue
        }
        $listCandidate.Add([pscustomobject][ordered]@{
            MountId = [string]$arrFields[0]
            ParentId = [string]$arrFields[1]
            Device = & $script:scriptBlockExpandCandidateHelperMountField -Value $arrFields[2]
            FsRoot = & $script:scriptBlockExpandCandidateHelperMountField -Value $arrFields[3]
            MountPoint = $strMountPoint
        })
    }
    $intLongest = -1
    foreach ($objCandidate in $listCandidate) {
        if ($objCandidate.MountPoint.Length -gt $intLongest) {
            $intLongest = $objCandidate.MountPoint.Length
        }
    }
    # Only the deepest mount point can govern this path. Within that group,
    # mounting B over A records B.ParentId as A.MountId, so the visible mount
    # is the one no sibling at the same point claims as its parent.
    foreach ($objCandidate in $listCandidate) {
        if ($objCandidate.MountPoint.Length -eq $intLongest) {
            [void]$objParentIdentifiers.Add($objCandidate.ParentId)
        }
    }
    $strBestMountPoint = $null
    $strBestDevice = $null
    $strBestFsRoot = $null
    $intVisibleCount = 0
    foreach ($objCandidate in $listCandidate) {
        if ($objCandidate.MountPoint.Length -ne $intLongest) {
            continue
        }
        if ($objParentIdentifiers.Contains($objCandidate.MountId)) {
            continue
        }
        $intVisibleCount++
        $strBestMountPoint = $objCandidate.MountPoint
        $strBestDevice = $objCandidate.Device
        $strBestFsRoot = $objCandidate.FsRoot
    }
    # Exactly one record in the group must be unclaimed. Anything else means
    # the topology was not understood, which fails closed rather than guessing.
    if ($intVisibleCount -ne 1) {
        & $script:scriptBlockStopCandidateHelperOperation `
            -Code 'root-invalid' -Phase 'root' -Subreason 'mount'
    }
    if ($null -eq $strBestMountPoint) {
        & $script:scriptBlockStopCandidateHelperOperation `
            -Code 'root-invalid' -Phase 'root' -Subreason 'mount'
    }
    $strRelative = if ($strBestMountPoint -ceq '/') {
        $LiteralPath
    } else {
        $LiteralPath.Substring($strBestMountPoint.Length)
    }
    $strTruePath = if ($strBestFsRoot -ceq '/') {
        $strRelative
    } else {
        $strBestFsRoot + $strRelative
    }
    if ($strTruePath.Length -eq 0) {
        $strTruePath = '/'
    }
    return [string[]]@($strBestDevice, $strTruePath)
}

$script:scriptBlockGetCandidateHelperIdentityChain = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath
    )

    # Lexical comparison cannot see two spellings that name the same directory,
    # such as a same-filesystem bind alias, and device alone cannot either
    # because an alias shares it. Inode is what separates them. The chain holds
    # every ancestor identity, so an alias of an ancestor is caught as well as
    # an alias of the path itself. Windows returns an empty chain; the identity
    # rule there is not implemented and the lexical rules still apply.
    $listIdentity = New-Object 'System.Collections.Generic.List[string]'
    if ($script:boolCandidateHelperIsWindows) {
        return ,[string[]]$listIdentity.ToArray()
    }
    $arrStatCommands = @(Get-Command -Name 'stat' `
        -CommandType Application -ErrorAction SilentlyContinue)
    if ($arrStatCommands.Count -lt 1) {
        & $script:scriptBlockStopCandidateHelperOperation `
            -Code 'root-invalid' -Phase 'root' -Subreason 'identity'
    }
    $strStatPath = [string]$arrStatCommands[0].Source
    $objCurrent = New-Object System.IO.DirectoryInfo($LiteralPath)
    while ($null -ne $objCurrent) {
        $arrStatus = @(& $strStatPath '-Lc' '%d:%i' '--' $objCurrent.FullName 2>$null)
        if ($LASTEXITCODE -ne 0 -or $arrStatus.Count -ne 1 -or
            $arrStatus[0] -notmatch '^[0-9]+:[0-9]+$') {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'root-invalid' -Phase 'root' -Subreason 'identity'
        }
        $listIdentity.Add([string]$arrStatus[0])
        $objCurrent = $objCurrent.Parent
    }
    # The unary comma keeps a single-element chain an array.
    return ,[string[]]$listIdentity.ToArray()
}

$script:scriptBlockAssertCandidateHelperDirectoryEnvelope = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [string]$Phase,

        [ref]$ReferenceToFilesystemCallCount
    )

    if ($null -ne $ReferenceToFilesystemCallCount) {
        $ReferenceToFilesystemCallCount.Value = [uint32](
            $ReferenceToFilesystemCallCount.Value + 1
        )
    }
    $strFailureCode = if ($Phase -ceq 'cleanup') {
        'cleanup-owned-entry-uncertain'
    } else {
        "$Phase-invalid"
    }
    $listComponents = New-Object 'System.Collections.Generic.List[string]'
    $objCurrent = New-Object System.IO.DirectoryInfo($LiteralPath)
    while ($null -ne $objCurrent) {
        $listComponents.Add($objCurrent.FullName)
        $objCurrent = $objCurrent.Parent
    }
    # Resolve stat as an Application once per envelope check, before the
    # component loop. A bare command name can bind to a function or alias, which
    # never sets $LASTEXITCODE, so the check would read a stale exit code from an
    # earlier native call and pass silently. The resolution is a local, not a
    # $script: cache: this file is both dot-sourced and invoked, so a script-scope
    # cache is not guaranteed to exist in the resolved scope and Set-StrictMode
    # makes reading an unset one throw. Hoisting it out of the loop keeps the
    # lookup off the per-component path.
    $strStatPath = $null
    if (-not $script:boolCandidateHelperIsWindows) {
        $arrStatCommands = @(Get-Command -Name 'stat' `
            -CommandType Application -ErrorAction SilentlyContinue)
        if ($arrStatCommands.Count -lt 1) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code $strFailureCode -Phase $Phase -Subreason 'identity'
        }
        $strStatPath = [string]$arrStatCommands[0].Source
    }
    $strPreviousDevice = $null
    for ($intIndex = $listComponents.Count - 1; $intIndex -ge 0; $intIndex--) {
        $strComponent = $listComponents[$intIndex]
        try {
            $objAttributes = [System.IO.File]::GetAttributes($strComponent)
        } catch {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code $strFailureCode -Phase $Phase -Subreason 'attribute'
        }
        if (($objAttributes -band [System.IO.FileAttributes]::Directory) -eq 0 -or
            ($objAttributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code $strFailureCode -Phase $Phase -Subreason 'nonordinary-directory'
        }
        if (-not $script:boolCandidateHelperIsWindows) {
            $arrFileSystemStatus = @(& $strStatPath '-Lc' '%d' '--' $strComponent 2>$null)
            $intFileSystemStatusExitCode = $LASTEXITCODE
            if ($intFileSystemStatusExitCode -ne 0 -or
                $arrFileSystemStatus.Count -ne 1 -or
                $arrFileSystemStatus[0] -notmatch '^[0-9]+$') {
                & $script:scriptBlockStopCandidateHelperOperation `
                    -Code $strFailureCode -Phase $Phase -Subreason 'identity'
            }
            if ($null -ne $strPreviousDevice -and
                $arrFileSystemStatus[0] -cne $strPreviousDevice) {
                & $script:scriptBlockStopCandidateHelperOperation `
                    -Code $strFailureCode -Phase $Phase -Subreason 'mount'
            }
            $strPreviousDevice = [string]$arrFileSystemStatus[0]
        }
    }
}

$script:scriptBlockGetCandidateHelperFileEvidence = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [string]$Phase,

        [ref]$ReferenceToFilesystemCallCount
    )

    $strFailureCode = if ($Phase -ceq 'cleanup') {
        'cleanup-owned-entry-uncertain'
    } else {
        "$Phase-invalid"
    }
    try {
        if ($null -ne $ReferenceToFilesystemCallCount) {
            $ReferenceToFilesystemCallCount.Value = [uint32]($ReferenceToFilesystemCallCount.Value + 1)
        }
        $objAttributes = [System.IO.File]::GetAttributes($LiteralPath)
        if (($objAttributes -band [System.IO.FileAttributes]::Directory) -ne 0 -or
            ($objAttributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw 'nonordinary'
        }
        if ($null -ne $ReferenceToFilesystemCallCount) {
            $ReferenceToFilesystemCallCount.Value = [uint32]($ReferenceToFilesystemCallCount.Value + 1)
        }
        $objStream = New-Object System.IO.FileStream(
            $LiteralPath,
            [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::Read,
            [System.IO.FileShare]::Read
        )
        try {
            $uintLength = [uint64]$objStream.Length
            $objSha256 = [System.Security.Cryptography.SHA256]::Create()
            try {
                $strSha256 = (
                    [System.BitConverter]::ToString($objSha256.ComputeHash($objStream)) -replace
                        '-', ''
                ).ToLowerInvariant()
            } finally {
                $objSha256.Dispose()
            }
        } finally {
            $objStream.Dispose()
        }
        return [ordered]@{
            Length = $uintLength
            Sha256 = $strSha256
        }
    } catch {
        & $script:scriptBlockStopCandidateHelperOperation `
            -Code $strFailureCode -Phase $Phase -Subreason 'file-evidence'
    }
}

$script:scriptBlockAssertCandidateHelperOrdinaryFileMetadata = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [string]$Phase
    )

    try {
        $objAttributes = [System.IO.File]::GetAttributes($LiteralPath)
        if (($objAttributes -band [System.IO.FileAttributes]::Directory) -ne 0 -or
            ($objAttributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw 'nonordinary'
        }
        $objFile = New-Object System.IO.FileInfo($LiteralPath)
        if (-not $objFile.Exists -or $objFile.Length -lt 0) {
            throw 'missing'
        }
        return [uint64]$objFile.Length
    } catch {
        & $script:scriptBlockStopCandidateHelperOperation `
            -Code "$Phase-invalid" -Phase $Phase -Subreason 'file-metadata'
    }
}

function Remove-StyleGuideCandidateInvocationState {
    # .SYNOPSIS
    # Removes candidate and caller-owned invocation state in trusted order.
    #
    # .DESCRIPTION
    # Proves and removes exact journaled candidate files and the candidate
    # directory first, then invokes the loaded context-manager cleanup function
    # for the download file, download directory, and invocation root. Validation
    # and cleanup uncertainty are reported as Success false rather than thrown
    # to the caller.
    #
    # .PARAMETER Context
    # Specifies the raw PSStyleGuide.CandidateInvocationContext.v1 object to
    # validate and transition.
    #
    # .EXAMPLE
    # $objCleanupResult = Remove-StyleGuideCandidateInvocationState `
    #     -Context $objContext
    #
    # # Returns one PSStyleGuide.CandidateCleanupResult.v1 object.
    #
    # .EXAMPLE
    # $objRepeatResult = Remove-StyleGuideCandidateInvocationState `
    #     -Context $objContext
    #
    # # A valid disposed repeat succeeds with FilesystemCallCount equal to zero.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [pscustomobject] One PSStyleGuide.CandidateCleanupResult.v1 object whose
    # Success property communicates validation or cleanup failure.
    #
    # .NOTES
    # This function supports named parameters only.
    #
    # Version: 1.0.20260802.13
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseShouldProcessForStateChangingFunctions',
        '',
        Justification = 'The issue-defined public interface prohibits additional common parameters.'
    )]
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory = $true)]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [object]$Context
    )

    Set-StrictMode -Version Latest

    $uintFilesystemCallCount = [uint32]0
    $guidInvocationId = [System.Guid]::Empty
    $strPreviousState = 'Invalid'
    try {
        [void](& $script:scriptBlockAssertCandidateHelperContext -ContextValue $Context)
        $guidInvocationId = $Context.InvocationId
        $strPreviousState = $Context.LifecycleState
    } catch {
        return (& $script:scriptBlockNewCandidateHelperCleanupResult `
            -InvocationId $guidInvocationId `
            -PreviousState $strPreviousState `
            -FinalState $strPreviousState `
            -Success $false `
            -DiagnosticCode 'cleanup-context-invalid' `
            -ReferenceToFilesystemCallCount ([uint32]0) `
            -RetainedRecordSequences ([uint32[]]@()))
    }

    if ($Context.LifecycleState -eq 'Disposed') {
        return (& $script:scriptBlockNewCandidateHelperCleanupResult `
            -InvocationId $Context.InvocationId `
            -PreviousState 'Disposed' `
            -FinalState 'Disposed' `
            -Success $true `
            -DiagnosticCode 'cleanup-already-disposed' `
            -ReferenceToFilesystemCallCount ([uint32]0) `
            -RetainedRecordSequences ([uint32[]]@()))
    }
    if ($Context.LifecycleState -eq 'CleanupFailed') {
        $arrRetained = & $script:scriptBlockGetCandidateHelperRetainedSequence -ContextValue $Context
        return (& $script:scriptBlockNewCandidateHelperCleanupResult `
            -InvocationId $Context.InvocationId `
            -PreviousState 'CleanupFailed' `
            -FinalState 'CleanupFailed' `
            -Success $false `
            -DiagnosticCode 'cleanup-terminal-failure' `
            -ReferenceToFilesystemCallCount ([uint32]0) `
            -RetainedRecordSequences $arrRetained)
    }

    try {
        $objCandidateDirectoryRecord = @($Context.OwnershipJournal | Where-Object {
            $_.Kind -eq 'CandidateDirectory'
        })[0]
        $arrCandidateFileRecords = @($Context.OwnershipJournal | Where-Object {
            $_.Kind -eq 'CandidateFile'
        })

        # Prove the trusted context-manager cleanup function is loaded before any
        # filesystem work. Deleting candidate entries first and only then finding
        # the caller cleanup missing would destroy owned state that this function
        # can no longer hand off, so the precondition is checked while the
        # filesystem is still untouched.
        $arrCommands = @(Get-Command -Name Remove-StyleGuideCandidateInvocationContext `
            -CommandType Function -ErrorAction SilentlyContinue)
        if ($arrCommands.Count -ne 1) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'cleanup-context-invalid' -Phase 'cleanup' -Subreason 'context-manager-not-loaded'
        }

        if ($objCandidateDirectoryRecord.EntryState -eq 'Created') {
            [void](& $script:scriptBlockAssertCandidateHelperDirectoryEnvelope `
                -LiteralPath $Context.CandidatePath `
                -Phase 'cleanup' `
                -ReferenceToFilesystemCallCount ([ref]$uintFilesystemCallCount))
            $arrCandidateEntries = [string[]]@(
                & $script:scriptBlockGetCandidateHelperEntry `
                    -LiteralPath $Context.CandidatePath `
                    -Phase 'cleanup' `
                    -ReferenceToFilesystemCallCount ([ref]$uintFilesystemCallCount)
            )
            $arrOwnedCandidateFiles = @($arrCandidateFileRecords | Where-Object {
                $_.EntryState -eq 'Created'
            })
            if ($arrCandidateEntries.Count -ne $arrOwnedCandidateFiles.Count) {
                & $script:scriptBlockStopCandidateHelperOperation `
                    -Code 'cleanup-owned-entry-uncertain' -Phase 'cleanup' -Subreason 'candidate-cardinality'
            }
            foreach ($objRecord in $arrOwnedCandidateFiles) {
                if (-not (& $script:scriptBlockTestCandidateHelperEntryPresent `
                    -EntryList $arrCandidateEntries `
                    -ExpectedPath $objRecord.Path)) {
                    & $script:scriptBlockStopCandidateHelperOperation `
                        -Code 'cleanup-owned-entry-uncertain' -Phase 'cleanup' -Subreason 'candidate-entry'
                }
                $hashtableEvidence = & $script:scriptBlockGetCandidateHelperFileEvidence `
                    -LiteralPath $objRecord.Path `
                    -Phase 'cleanup' `
                    -ReferenceToFilesystemCallCount ([ref]$uintFilesystemCallCount)
                if ($hashtableEvidence.Length -ne $objRecord.ContentLength -or
                    $hashtableEvidence.Sha256 -cne $objRecord.ContentSha256) {
                    & $script:scriptBlockStopCandidateHelperOperation `
                        -Code 'cleanup-owned-entry-uncertain' -Phase 'cleanup' -Subreason 'candidate-identity'
                }
            }

            $arrToDelete = @($arrOwnedCandidateFiles | Sort-Object -Property Sequence -Descending)
            foreach ($objRecord in $arrToDelete) {
                $uintFilesystemCallCount = [uint32]($uintFilesystemCallCount + 1)
                [System.IO.File]::Delete($objRecord.Path)
                $arrRemaining = [string[]]@(
                    & $script:scriptBlockGetCandidateHelperEntry `
                        -LiteralPath $Context.CandidatePath `
                        -Phase 'cleanup' `
                        -ReferenceToFilesystemCallCount ([ref]$uintFilesystemCallCount)
                )
                if (& $script:scriptBlockTestCandidateHelperEntryPresent `
                    -EntryList $arrRemaining `
                    -ExpectedPath $objRecord.Path) {
                    & $script:scriptBlockStopCandidateHelperOperation `
                        -Code 'cleanup-delete-failed' -Phase 'cleanup' -Subreason 'candidate-file-present'
                }
                $objRecord.EntryState = 'Deleted'
            }

            $uintFilesystemCallCount = [uint32]($uintFilesystemCallCount + 1)
            [System.IO.Directory]::Delete($Context.CandidatePath, $false)
            $arrRootEntries = [string[]]@(
                & $script:scriptBlockGetCandidateHelperEntry `
                    -LiteralPath $Context.InvocationRootPath `
                    -Phase 'cleanup' `
                    -ReferenceToFilesystemCallCount ([ref]$uintFilesystemCallCount)
            )
            if (& $script:scriptBlockTestCandidateHelperEntryPresent `
                -EntryList $arrRootEntries `
                -ExpectedPath $Context.CandidatePath) {
                & $script:scriptBlockStopCandidateHelperOperation `
                    -Code 'cleanup-delete-failed' -Phase 'cleanup' -Subreason 'candidate-directory-present'
            }
            $objCandidateDirectoryRecord.EntryState = 'Deleted'
        } elseif ($objCandidateDirectoryRecord.EntryState -eq 'ExpectedAbsent' -and
            $arrCandidateFileRecords.Count -ne 0) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'cleanup-context-invalid' -Phase 'cleanup' -Subreason 'candidate-journal'
        }

        $objContextResult = Remove-StyleGuideCandidateInvocationContext -Context $Context
        $uintCombinedCalls = [uint32]($uintFilesystemCallCount + $objContextResult.FilesystemCallCount)
        return (& $script:scriptBlockNewCandidateHelperCleanupResult `
            -InvocationId $objContextResult.InvocationId `
            -PreviousState $strPreviousState `
            -FinalState $objContextResult.FinalState `
            -Success $objContextResult.Success `
            -DiagnosticCode $objContextResult.DiagnosticCode `
            -ReferenceToFilesystemCallCount $uintCombinedCalls `
            -RetainedRecordSequences $objContextResult.RetainedRecordSequences)
    } catch {
        # Only entries this invocation actually created can be uncertain. An
        # ExpectedAbsent record names a path that was never created, so it stays
        # ExpectedAbsent; retyping it would contradict the record schema, which
        # binds every non-ExpectedAbsent candidate-directory record to the
        # destination phase, and would invalidate the terminal context.
        #
        # Every Created record is retained, not just the candidate ones. This
        # cleanup can fail before it delegates to the caller, leaving the
        # invocation root and download entries present and owned, and a
        # CleanupFailed context must name at least one retained record.
        foreach ($objRecord in $Context.OwnershipJournal) {
            if ($objRecord.EntryState -eq 'Created') {
                $objRecord.EntryState = 'RetainedUncertain'
            }
        }
        $Context.LifecycleState = 'CleanupFailed'
        $arrRetained = & $script:scriptBlockGetCandidateHelperRetainedSequence -ContextValue $Context
        $strCode = & $script:scriptBlockGetCandidateHelperFailureField `
            -ErrorRecord $_ `
            -Key 'PSStyleGuideDiagnosticCode' `
            -Fallback 'cleanup-owned-entry-uncertain'
        return (& $script:scriptBlockNewCandidateHelperCleanupResult `
            -InvocationId $Context.InvocationId `
            -PreviousState $strPreviousState `
            -FinalState 'CleanupFailed' `
            -Success $false `
            -DiagnosticCode $strCode `
            -ReferenceToFilesystemCallCount $uintFilesystemCallCount `
            -RetainedRecordSequences $arrRetained)
    }
}

$script:scriptBlockConvertToCandidateHelperNormalizedPath = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Value,

        [Parameter(Mandatory = $true)]
        [string]$ParameterName
    )

    if ([System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Value)) {
        & $script:scriptBlockStopCandidateHelperOperation `
            -Code 'parameter' -Phase 'parameter' -Subreason "$ParameterName-wildcard"
    }
    $strProviderPath = $Value
    $intProviderSeparator = $Value.IndexOf('::', [System.StringComparison]::Ordinal)
    if ($intProviderSeparator -ge 0) {
        $strProviderName = $Value.Substring(0, $intProviderSeparator)
        if ($strProviderName -cnotin @('FileSystem', 'Microsoft.PowerShell.Core\FileSystem')) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'parameter' -Phase 'parameter' -Subreason "$ParameterName-provider"
        }
        $strProviderPath = $Value.Substring($intProviderSeparator + 2)
    }
    $boolDriveRelative = $strProviderPath.Length -ge 2 -and
        [System.Char]::IsLetter($strProviderPath[0]) -and
        $strProviderPath[1] -eq ':' -and
        ($strProviderPath.Length -eq 2 -or
            ($strProviderPath[2] -ne [char]'\' -and $strProviderPath[2] -ne [char]'/'))
    if ($boolDriveRelative -or -not [System.IO.Path]::IsPathRooted($strProviderPath)) {
        & $script:scriptBlockStopCandidateHelperOperation `
            -Code 'parameter' -Phase 'parameter' -Subreason "$ParameterName-relative"
    }
    try {
        return [System.IO.Path]::GetFullPath($strProviderPath)
    } catch {
        & $script:scriptBlockStopCandidateHelperOperation `
            -Code 'parameter' -Phase 'parameter' -Subreason "$ParameterName-normalization"
    }
}

$script:scriptBlockTestCandidateHelperPathContained = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Root,

        [Parameter(Mandatory = $true)]
        [string]$Candidate
    )

    $strRootPrefix = $Root.TrimEnd(
        $script:chrCandidateHelperDirectorySeparator,
        $script:chrCandidateHelperAlternateSeparator
    ) + $script:chrCandidateHelperDirectorySeparator
    return $Candidate.StartsWith($strRootPrefix, $script:objCandidateHelperPathComparison)
}

$script:scriptBlockAssertCandidateHelperEntryAbsent = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ParentPath,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedPath,

        [Parameter(Mandatory = $true)]
        [string]$Phase
    )

    $arrEntries = [string[]]@(
        & $script:scriptBlockGetCandidateHelperEntry -LiteralPath $ParentPath -Phase $Phase
    )
    foreach ($strEntry in $arrEntries) {
        if ([System.String]::Equals(
            $strEntry,
            $ExpectedPath,
            $script:objCandidateHelperPathComparison
        )) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code "$Phase-invalid" -Phase $Phase -Subreason 'leaf-present'
        }
    }
}

$script:scriptBlockReadCandidateHelperValidatedFile = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [uint64]$ExpectedLength,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedSha256
    )

    $objStream = New-Object System.IO.FileStream(
        $LiteralPath,
        [System.IO.FileMode]::Open,
        [System.IO.FileAccess]::Read,
        [System.IO.FileShare]::Read
    )
    try {
        if ([uint64]$objStream.Length -ne $ExpectedLength) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'post-extraction-invalid' -Phase 'post-extraction' -Subreason 'length'
        }
        $objSha256 = [System.Security.Cryptography.SHA256]::Create()
        $arrBuffer = New-Object byte[] $script:intCandidateHelperBufferSize
        $listPrefix = New-Object 'System.Collections.Generic.List[byte]'
        try {
            while ($true) {
                $intRead = $objStream.Read($arrBuffer, 0, $arrBuffer.Length)
                if ($intRead -eq 0) {
                    break
                }
                for ($intIndex = 0; $intIndex -lt $intRead; $intIndex++) {
                    if ($listPrefix.Count -lt 3) {
                        $listPrefix.Add($arrBuffer[$intIndex])
                    }
                    if ($arrBuffer[$intIndex] -eq 0x0D) {
                        & $script:scriptBlockStopCandidateHelperOperation `
                            -Code 'post-extraction-invalid' -Phase 'post-extraction' -Subreason 'cr'
                    }
                }
                [void]$objSha256.TransformBlock($arrBuffer, 0, $intRead, $null, 0)
            }
            [void]$objSha256.TransformFinalBlock((New-Object byte[] 0), 0, 0)
            $strActualSha256 = (
                [System.BitConverter]::ToString($objSha256.Hash) -replace '-', ''
            ).ToLowerInvariant()
        } finally {
            $objSha256.Dispose()
        }
        if ($listPrefix.Count -eq 3 -and
            $listPrefix[0] -eq 0xEF -and $listPrefix[1] -eq 0xBB -and $listPrefix[2] -eq 0xBF) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'post-extraction-invalid' -Phase 'post-extraction' -Subreason 'bom'
        }
        if ($strActualSha256 -cne $ExpectedSha256) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'post-extraction-invalid' -Phase 'post-extraction' -Subreason 'sha256'
        }
    } finally {
        $objStream.Dispose()
    }
}

$script:scriptBlockAddCandidateHelperDeclaredLength = {
    param (
        [Parameter(Mandatory = $true)]
        [uint64]$CurrentTotal,

        [Parameter(Mandatory = $true)]
        [long]$DeclaredLength
    )

    if ($DeclaredLength -lt 0) {
        & $script:scriptBlockStopCandidateHelperOperation `
            -Code 'manifest-invalid' -Phase 'manifest' -Subreason 'declared-length'
    }
    $uintDeclaredLength = [uint64]$DeclaredLength
    if ($CurrentTotal -gt ([uint64]::MaxValue - $uintDeclaredLength)) {
        & $script:scriptBlockStopCandidateHelperOperation `
            -Code 'manifest-invalid' -Phase 'manifest' -Subreason 'actual-overflow'
    }
    if ($uintDeclaredLength -gt $script:uintCandidateHelperMaximumTotalByte -or
        $CurrentTotal -gt ($script:uintCandidateHelperMaximumTotalByte - $uintDeclaredLength)) {
        & $script:scriptBlockStopCandidateHelperOperation `
            -Code 'manifest-invalid' -Phase 'manifest' -Subreason 'total-limit'
    }
    if ($uintDeclaredLength -gt $script:uintCandidateHelperMaximumEntryByte) {
        & $script:scriptBlockStopCandidateHelperOperation `
            -Code 'manifest-invalid' -Phase 'manifest' -Subreason 'entry-limit'
    }
    return [uint64]($CurrentTotal + $uintDeclaredLength)
}

$script:scriptBlockAddCandidateHelperActualLength = {
    param (
        [Parameter(Mandatory = $true)]
        [uint64]$CurrentEntryLength,

        [Parameter(Mandatory = $true)]
        [uint64]$CurrentTotalLength,

        [Parameter(Mandatory = $true)]
        [uint64]$ReadLength,

        [Parameter(Mandatory = $true)]
        [uint64]$DeclaredEntryLength,

        [Parameter(Mandatory = $true)]
        [string]$Phase,

        [Parameter(Mandatory = $true)]
        [string]$DiagnosticCode
    )

    if ($CurrentEntryLength -gt ([uint64]::MaxValue - $ReadLength) -or
        $CurrentTotalLength -gt ([uint64]::MaxValue - $ReadLength)) {
        & $script:scriptBlockStopCandidateHelperOperation `
            -Code $DiagnosticCode -Phase $Phase -Subreason 'actual-overflow'
    }
    $uintNewEntryLength = [uint64]($CurrentEntryLength + $ReadLength)
    $uintNewTotalLength = [uint64]($CurrentTotalLength + $ReadLength)
    if ($uintNewEntryLength -gt $DeclaredEntryLength -or
        $uintNewEntryLength -gt $script:uintCandidateHelperMaximumEntryByte -or
        $uintNewTotalLength -gt $script:uintCandidateHelperMaximumTotalByte) {
        & $script:scriptBlockStopCandidateHelperOperation `
            -Code $DiagnosticCode -Phase $Phase -Subreason 'actual-limit'
    }
    return [ordered]@{
        EntryLength = $uintNewEntryLength
        TotalLength = $uintNewTotalLength
    }
}

if ($script:boolCandidateHelperWasDotSourced) {
    return
}

$script:scriptBlockInvokeCandidateArtifactExpansion = {
    Set-StrictMode -Version Latest

    $objArchiveStream = $null
    $objZipArchive = $null
    $objPrimaryError = $null
    $objValidatedContext = $null
    $strPhase = 'parameter'

    try {
        foreach ($strRequiredParameter in @(
            'Context',
            'CheckoutRoot',
            'TrustedTemporaryRoot',
            'DownloadDirectory',
            'CandidateDirectory',
            'ExpectedDigest'
        )) {
            if (-not $script:hashtableCandidateHelperBoundParameters.ContainsKey($strRequiredParameter)) {
                & $script:scriptBlockStopCandidateHelperOperation `
                    -Code 'parameter' -Phase 'parameter' -Subreason "$strRequiredParameter-missing"
            }
        }

        $strCheckoutRoot = & $script:scriptBlockAssertCandidateHelperRawString `
            -Value $CheckoutRoot -ParameterName 'CheckoutRoot' -IsLabel $false
        $strTrustedTemporaryRoot = & $script:scriptBlockAssertCandidateHelperRawString `
            -Value $TrustedTemporaryRoot -ParameterName 'TrustedTemporaryRoot' -IsLabel $false
        $strDownloadDirectory = & $script:scriptBlockAssertCandidateHelperRawString `
            -Value $DownloadDirectory -ParameterName 'DownloadDirectory' -IsLabel $false
        $strCandidateDirectory = & $script:scriptBlockAssertCandidateHelperRawString `
            -Value $CandidateDirectory -ParameterName 'CandidateDirectory' -IsLabel $false
        $strExpectedDigest = & $script:scriptBlockAssertCandidateHelperRawString `
            -Value $ExpectedDigest -ParameterName 'ExpectedDigest' -IsLabel $false
        if ($strExpectedDigest -cnotmatch '^[0-9A-Fa-f]{64}$') {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'parameter' -Phase 'parameter' -Subreason 'ExpectedDigest-grammar'
        }

        if ($script:hashtableCandidateHelperBoundParameters.ContainsKey('ArtifactId')) {
            $null = & $script:scriptBlockAssertCandidateHelperRawString `
                -Value $ArtifactId -ParameterName 'ArtifactId' -IsLabel $true
        }
        if ($script:hashtableCandidateHelperBoundParameters.ContainsKey('RunId')) {
            $null = & $script:scriptBlockAssertCandidateHelperRawString `
                -Value $RunId -ParameterName 'RunId' -IsLabel $true
        }
        if ($script:hashtableCandidateHelperBoundParameters.ContainsKey('RunAttempt')) {
            $null = & $script:scriptBlockAssertCandidateHelperRawString `
                -Value $RunAttempt -ParameterName 'RunAttempt' -IsLabel $true
        }

        try {
            [void](& $script:scriptBlockAssertCandidateHelperContext -ContextValue $Context)
        } catch {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'parameter' -Phase 'parameter' -Subreason 'Context-schema'
        }
        if ($Context.LifecycleState -cne 'Active') {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'parameter' -Phase 'parameter' -Subreason 'Context-state'
        }
        $objValidatedContext = $Context

        $strCheckoutPath = & $script:scriptBlockConvertToCandidateHelperNormalizedPath `
            -Value $strCheckoutRoot -ParameterName 'CheckoutRoot'
        $strTrustedPath = & $script:scriptBlockConvertToCandidateHelperNormalizedPath `
            -Value $strTrustedTemporaryRoot -ParameterName 'TrustedTemporaryRoot'
        $strDownloadPath = & $script:scriptBlockConvertToCandidateHelperNormalizedPath `
            -Value $strDownloadDirectory -ParameterName 'DownloadDirectory'
        $strCandidatePath = & $script:scriptBlockConvertToCandidateHelperNormalizedPath `
            -Value $strCandidateDirectory -ParameterName 'CandidateDirectory'

        $boolTrustedPathMatchesContext = [System.String]::Equals(
            $strTrustedPath,
            $Context.TrustedParentPath,
            $script:objCandidateHelperPathComparison
        )
        $boolDownloadPathMatchesContext = [System.String]::Equals(
            $strDownloadPath,
            $Context.DownloadDirectoryPath,
            $script:objCandidateHelperPathComparison
        )
        $boolCandidatePathMatchesContext = [System.String]::Equals(
            $strCandidatePath,
            $Context.CandidatePath,
            $script:objCandidateHelperPathComparison
        )
        if (-not $boolTrustedPathMatchesContext -or
            -not $boolDownloadPathMatchesContext -or
            -not $boolCandidatePathMatchesContext) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'parameter' -Phase 'parameter' -Subreason 'Context-path-mismatch'
        }

        $strPhase = 'root'
        [void](& $script:scriptBlockAssertCandidateHelperDirectoryEnvelope `
            -LiteralPath $strCheckoutPath `
            -Phase 'root')
        [void](& $script:scriptBlockAssertCandidateHelperDirectoryEnvelope `
            -LiteralPath $strTrustedPath `
            -Phase 'root')
        $boolRootsEqual = [System.String]::Equals(
            $strCheckoutPath,
            $strTrustedPath,
            $script:objCandidateHelperPathComparison
        )
        $boolCheckoutContainsTrusted = & $script:scriptBlockTestCandidateHelperPathContained `
            -Root $strCheckoutPath `
            -Candidate $strTrustedPath
        $boolTrustedContainsCheckout = & $script:scriptBlockTestCandidateHelperPathContained `
            -Root $strTrustedPath `
            -Candidate $strCheckoutPath
        if ($boolRootsEqual -or $boolCheckoutContainsTrusted -or $boolTrustedContainsCheckout) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'root-invalid' -Phase 'root' -Subreason 'overlap'
        }

        # The checks above are string comparisons, so two different spellings of
        # the same directory pass them. Compare filesystem identity as well:
        # equal identity means the same directory, and finding one root's
        # identity anywhere in the other's ancestor chain means one contains the
        # other however it was spelled.
        $arrCheckoutIdentity = & $script:scriptBlockGetCandidateHelperIdentityChain `
            -LiteralPath $strCheckoutPath
        $arrTrustedIdentity = & $script:scriptBlockGetCandidateHelperIdentityChain `
            -LiteralPath $strTrustedPath
        if ($arrCheckoutIdentity.Count -gt 0 -and $arrTrustedIdentity.Count -gt 0 -and
            ($arrTrustedIdentity -ccontains $arrCheckoutIdentity[0] -or
                $arrCheckoutIdentity -ccontains $arrTrustedIdentity[0])) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'root-invalid' -Phase 'root' -Subreason 'overlap'
        }

        # Identity comparison sees an alias of a root, but not an alias of a
        # directory below one: /b bound from /a/sub shares no inode with /a and
        # never lists /a as an ancestor. Resolving both roots through mount
        # topology exposes the subtree each one really occupies.
        $arrCheckoutMount = & $script:scriptBlockGetCandidateHelperMountResolvedPath `
            -LiteralPath $strCheckoutPath
        $arrTrustedMount = & $script:scriptBlockGetCandidateHelperMountResolvedPath `
            -LiteralPath $strTrustedPath
        if ($null -ne $arrCheckoutMount -and $null -ne $arrTrustedMount -and
            $arrCheckoutMount[0] -ceq $arrTrustedMount[0] -and
            ((& $script:scriptBlockTestCandidateHelperPathPrefix `
                    -Prefix $arrCheckoutMount[1] -Path $arrTrustedMount[1]) -or
                (& $script:scriptBlockTestCandidateHelperPathPrefix `
                    -Prefix $arrTrustedMount[1] -Path $arrCheckoutMount[1]))) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'root-invalid' -Phase 'root' -Subreason 'overlap'
        }

        $strPhase = 'containment'
        $boolTrustedContainsDownload = & $script:scriptBlockTestCandidateHelperPathContained `
            -Root $strTrustedPath `
            -Candidate $strDownloadPath
        $boolTrustedContainsCandidate = & $script:scriptBlockTestCandidateHelperPathContained `
            -Root $strTrustedPath `
            -Candidate $strCandidatePath
        $boolCheckoutContainsDownload = & $script:scriptBlockTestCandidateHelperPathContained `
            -Root $strCheckoutPath `
            -Candidate $strDownloadPath
        $boolCheckoutContainsCandidate = & $script:scriptBlockTestCandidateHelperPathContained `
            -Root $strCheckoutPath `
            -Candidate $strCandidatePath
        if (-not $boolTrustedContainsDownload -or
            -not $boolTrustedContainsCandidate -or
            $boolCheckoutContainsDownload -or
            $boolCheckoutContainsCandidate) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'containment-invalid' -Phase 'containment' -Subreason 'relationship'
        }
        [void](& $script:scriptBlockAssertCandidateHelperDirectoryEnvelope `
            -LiteralPath $Context.InvocationRootPath `
            -Phase 'containment')
        [void](& $script:scriptBlockAssertCandidateHelperDirectoryEnvelope `
            -LiteralPath $strDownloadPath `
            -Phase 'containment')

        $strPhase = 'download'
        $arrDownloadEntries = [string[]]@(
            & $script:scriptBlockGetCandidateHelperEntry -LiteralPath $strDownloadPath `
                -Phase 'download'
        )
        if ($arrDownloadEntries.Count -ne 1) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'download-invalid' -Phase 'download' -Subreason 'entry-count'
        }
        $strArchivePath = $arrDownloadEntries[0]
        $uintArchiveMetadataLength = & $script:scriptBlockAssertCandidateHelperOrdinaryFileMetadata `
            -LiteralPath $strArchivePath `
            -Phase 'download'
        if ($uintArchiveMetadataLength -gt $script:uintCandidateHelperMaximumArchiveByte) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'download-invalid' -Phase 'download' -Subreason 'archive-limit'
        }
        [void](& $script:scriptBlockAssertCandidateHelperEntryAbsent `
            -ParentPath $Context.InvocationRootPath `
            -ExpectedPath $strCandidatePath `
            -Phase 'destination')

        if (@($Context.OwnershipJournal | Where-Object { $_.Kind -eq 'DownloadFile' }).Count -ne 0) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'parameter' -Phase 'parameter' -Subreason 'download-already-journaled'
        }

        try {
            $objArchiveStream = New-Object System.IO.FileStream(
                $strArchivePath,
                [System.IO.FileMode]::Open,
                [System.IO.FileAccess]::Read,
                [System.IO.FileShare]::Read
            )
        } catch {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'download-invalid' -Phase 'download' -Subreason 'archive-open'
        }
        $strPhase = 'digest'
        if (-not $objArchiveStream.CanRead -or -not $objArchiveStream.CanSeek -or
            [uint64]$objArchiveStream.Length -ne $uintArchiveMetadataLength -or
            [uint64]$objArchiveStream.Length -gt $script:uintCandidateHelperMaximumArchiveByte) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'archive-invalid' -Phase 'archive' -Subreason 'stream'
        }
        $objArchiveSha256 = [System.Security.Cryptography.SHA256]::Create()
        try {
            $strActualDigest = ([System.BitConverter]::ToString(
                $objArchiveSha256.ComputeHash($objArchiveStream)
            ) -replace '-', '').ToLowerInvariant()
        } finally {
            $objArchiveSha256.Dispose()
        }
        if ($strActualDigest -cnotmatch '^[0-9a-f]{64}$') {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'archive-invalid' -Phase 'digest' -Subreason 'hash-shape'
        }

        $objDownloadRecord = & $script:scriptBlockNewCandidateHelperRecord `
            -Sequence $Context.NextSequence `
            -Kind 'DownloadFile' `
            -Path $strArchivePath `
            -ParentPath $strDownloadPath `
            -LeafName ([System.IO.Path]::GetFileName($strArchivePath)) `
            -CreationPhase 'download' `
            -ContentLength ([uint64]$objArchiveStream.Length) `
            -ContentSha256 $strActualDigest
        [void](& $script:scriptBlockAddCandidateHelperRecord `
            -ContextValue $Context `
            -Record $objDownloadRecord)
        [void](& $script:scriptBlockAssertCandidateHelperContext -ContextValue $Context)

        if (-not [System.String]::Equals(
            $strActualDigest,
            $strExpectedDigest,
            [System.StringComparison]::OrdinalIgnoreCase
        )) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'digest-mismatch' -Phase 'digest' -Subreason 'mismatch'
        }

        $objArchiveStream.Position = 0
        $strPhase = 'archive'
        Add-Type -AssemblyName System.IO.Compression -ErrorAction Stop
        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction Stop
        } catch {
            if (-not ('System.IO.Compression.ZipArchive' -as [type])) {
                throw
            }
        }
        try {
            $objZipArchive = New-Object System.IO.Compression.ZipArchive(
                $objArchiveStream,
                [System.IO.Compression.ZipArchiveMode]::Read,
                $true
            )
        } catch {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'archive-invalid' -Phase 'archive' -Subreason 'zip-open'
        }

        $strPhase = 'manifest'
        $arrZipEntries = @($objZipArchive.Entries)
        if ($arrZipEntries.Count -ne 4) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'manifest-invalid' -Phase 'manifest' -Subreason 'entry-count'
        }
        $objOrdinalNames = New-Object 'System.Collections.Generic.HashSet[string]' (
            [System.StringComparer]::Ordinal
        )
        $objIgnoreCaseNames = New-Object 'System.Collections.Generic.HashSet[string]' (
            [System.StringComparer]::OrdinalIgnoreCase
        )
        $hashtableEntryMap = @{}
        $uintDeclaredTotal = [uint64]0
        foreach ($objEntry in $arrZipEntries) {
            $strEntryName = [string]$objEntry.FullName
            if (-not $objOrdinalNames.Add($strEntryName)) {
                & $script:scriptBlockStopCandidateHelperOperation `
                    -Code 'manifest-invalid' -Phase 'manifest' -Subreason 'duplicate-exact'
            }
            if (-not $objIgnoreCaseNames.Add($strEntryName)) {
                & $script:scriptBlockStopCandidateHelperOperation `
                    -Code 'manifest-invalid' -Phase 'manifest' -Subreason 'duplicate-case'
            }
            if ($strEntryName.Length -eq 0 -or $strEntryName.IndexOf('/') -ge 0 -or
                $strEntryName.IndexOf('\') -ge 0 -or $strEntryName -match '^[A-Za-z]:' -or
                $objEntry.Name.Length -eq 0 -or
                $strEntryName -cnotin $script:arrCandidateHelperExpectedName) {
                & $script:scriptBlockStopCandidateHelperOperation `
                    -Code 'manifest-invalid' -Phase 'manifest' -Subreason 'entry-name'
            }
            $longDeclaredLength = [long]$objEntry.Length
            $uintDeclaredTotal = & $script:scriptBlockAddCandidateHelperDeclaredLength `
                -CurrentTotal $uintDeclaredTotal `
                -DeclaredLength $longDeclaredLength
            $hashtableEntryMap[$strEntryName] = $objEntry
        }
        foreach ($strExpectedName in $script:arrCandidateHelperExpectedName) {
            if (-not $hashtableEntryMap.ContainsKey($strExpectedName)) {
                & $script:scriptBlockStopCandidateHelperOperation `
                    -Code 'manifest-invalid' -Phase 'manifest' -Subreason 'missing-entry'
            }
        }

        # Acquire immutable content evidence while the one trusted archive stream
        # remains held. A candidate-file ownership record is not published until
        # both its exact length and SHA-256 are known.
        $hashtableEntryEvidence = @{}
        $uintEvidenceTotal = [uint64]0
        foreach ($strExpectedName in $script:arrCandidateHelperExpectedName) {
            $objEvidenceEntry = $hashtableEntryMap[$strExpectedName]
            $objEvidenceStream = $null
            $objEvidenceSha256 = $null
            try {
                $objEvidenceStream = $objEvidenceEntry.Open()
                $objEvidenceSha256 = [System.Security.Cryptography.SHA256]::Create()
                $arrEvidenceBuffer = New-Object byte[] $script:intCandidateHelperBufferSize
                $uintEvidenceLength = [uint64]0
                while ($true) {
                    $intEvidenceRead = $objEvidenceStream.Read(
                        $arrEvidenceBuffer,
                        0,
                        $arrEvidenceBuffer.Length
                    )
                    if ($intEvidenceRead -eq 0) {
                        break
                    }
                    $uintEvidenceRead = [uint64]$intEvidenceRead
                    $hashtableNewEvidenceLength = & $script:scriptBlockAddCandidateHelperActualLength `
                        -CurrentEntryLength $uintEvidenceLength `
                        -CurrentTotalLength $uintEvidenceTotal `
                        -ReadLength $uintEvidenceRead `
                        -DeclaredEntryLength ([uint64]$objEvidenceEntry.Length) `
                        -Phase 'manifest' `
                        -DiagnosticCode 'manifest-invalid'
                    [void]$objEvidenceSha256.TransformBlock(
                        $arrEvidenceBuffer,
                        0,
                        $intEvidenceRead,
                        $null,
                        0
                    )
                    $uintEvidenceLength = $hashtableNewEvidenceLength.EntryLength
                    $uintEvidenceTotal = $hashtableNewEvidenceLength.TotalLength
                }
                if ($uintEvidenceLength -ne [uint64]$objEvidenceEntry.Length) {
                    & $script:scriptBlockStopCandidateHelperOperation `
                        -Code 'manifest-invalid' -Phase 'manifest' -Subreason 'actual-declared-mismatch'
                }
                [void]$objEvidenceSha256.TransformFinalBlock((New-Object byte[] 0), 0, 0)
                $strEvidenceSha256 = ([System.BitConverter]::ToString(
                    $objEvidenceSha256.Hash
                ) -replace '-', '').ToLowerInvariant()
                $hashtableEntryEvidence[$strExpectedName] = [ordered]@{
                    Length = [uint64]$uintEvidenceLength
                    Sha256 = [string]$strEvidenceSha256
                }
            } catch {
                if ($_.Exception.Data.Contains('PSStyleGuideDiagnosticCode')) {
                    throw
                }
                & $script:scriptBlockStopCandidateHelperOperation `
                    -Code 'manifest-invalid' -Phase 'manifest' -Subreason 'entry-read'
            } finally {
                if ($null -ne $objEvidenceSha256) {
                    $objEvidenceSha256.Dispose()
                }
                if ($null -ne $objEvidenceStream) {
                    $objEvidenceStream.Dispose()
                }
            }
        }

        $strPhase = 'destination'
        [void](& $script:scriptBlockAssertCandidateHelperDirectoryEnvelope `
            -LiteralPath $strCheckoutPath `
            -Phase 'destination')
        [void](& $script:scriptBlockAssertCandidateHelperDirectoryEnvelope `
            -LiteralPath $strTrustedPath `
            -Phase 'destination')
        [void](& $script:scriptBlockAssertCandidateHelperDirectoryEnvelope `
            -LiteralPath $Context.InvocationRootPath `
            -Phase 'destination')
        [void](& $script:scriptBlockAssertCandidateHelperDirectoryEnvelope `
            -LiteralPath $strDownloadPath `
            -Phase 'destination')
        [void](& $script:scriptBlockAssertCandidateHelperEntryAbsent `
            -ParentPath $Context.InvocationRootPath `
            -ExpectedPath $strCandidatePath `
            -Phase 'destination')

        $objCandidateDirectoryRecord = @($Context.OwnershipJournal | Where-Object {
            $_.Kind -eq 'CandidateDirectory'
        })[0]
        if ($objCandidateDirectoryRecord.EntryState -cne 'ExpectedAbsent') {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'destination-invalid' -Phase 'destination' -Subreason 'candidate-state'
        }
        $null = [System.IO.Directory]::CreateDirectory($strCandidatePath)
        $objCandidateDirectoryRecord.CreationPhase = 'destination'
        $objCandidateDirectoryRecord.EntryState = 'Created'
        [void](& $script:scriptBlockAssertCandidateHelperDirectoryEnvelope `
            -LiteralPath $strCandidatePath `
            -Phase 'destination')

        $strPhase = 'extraction'
        $uintActualTotal = [uint64]0
        foreach ($strExpectedName in $script:arrCandidateHelperExpectedName) {
            $objEntry = $hashtableEntryMap[$strExpectedName]
            $hashtableExpectedEvidence = $hashtableEntryEvidence[$strExpectedName]
            $strDestinationPath = [System.IO.Path]::GetFullPath(
                [System.IO.Path]::Combine($strCandidatePath, $strExpectedName)
            )
            if (-not (& $script:scriptBlockTestCandidateHelperPathContained `
                -Root $strCandidatePath `
                -Candidate $strDestinationPath)) {
                & $script:scriptBlockStopCandidateHelperOperation `
                    -Code 'extraction-invalid' -Phase 'extraction' -Subreason 'destination-containment'
            }
            [void](& $script:scriptBlockAssertCandidateHelperEntryAbsent `
                -ParentPath $strCandidatePath `
                -ExpectedPath $strDestinationPath `
                -Phase 'extraction')

            $objDestinationStream = $null
            $objEntryStream = $null
            $objEntrySha256 = $null
            $objFileRecord = $null
            try {
                $objDestinationStream = New-Object System.IO.FileStream(
                    $strDestinationPath,
                    [System.IO.FileMode]::CreateNew,
                    [System.IO.FileAccess]::Write,
                    [System.IO.FileShare]::None
                )
                $objFileRecord = & $script:scriptBlockNewCandidateHelperRecord `
                    -Sequence $Context.NextSequence `
                    -Kind 'CandidateFile' `
                    -Path $strDestinationPath `
                    -ParentPath $strCandidatePath `
                    -LeafName $strExpectedName `
                    -CreationPhase 'extraction' `
                    -ContentLength ([uint64]$hashtableExpectedEvidence.Length) `
                    -ContentSha256 ([string]$hashtableExpectedEvidence.Sha256)
                [void](& $script:scriptBlockAddCandidateHelperRecord `
                    -ContextValue $Context `
                    -Record $objFileRecord)

                $objEntryStream = $objEntry.Open()
                $objEntrySha256 = [System.Security.Cryptography.SHA256]::Create()
                $arrBuffer = New-Object byte[] $script:intCandidateHelperBufferSize
                $uintEntryActual = [uint64]0
                while ($true) {
                    $intRead = $objEntryStream.Read($arrBuffer, 0, $arrBuffer.Length)
                    if ($intRead -eq 0) {
                        break
                    }
                    $uintRead = [uint64]$intRead
                    $hashtableNewActualLength = & $script:scriptBlockAddCandidateHelperActualLength `
                        -CurrentEntryLength $uintEntryActual `
                        -CurrentTotalLength $uintActualTotal `
                        -ReadLength $uintRead `
                        -DeclaredEntryLength ([uint64]$objEntry.Length) `
                        -Phase 'extraction' `
                        -DiagnosticCode 'extraction-invalid'
                    $objDestinationStream.Write($arrBuffer, 0, $intRead)
                    [void]$objEntrySha256.TransformBlock($arrBuffer, 0, $intRead, $null, 0)
                    $uintEntryActual = $hashtableNewActualLength.EntryLength
                    $uintActualTotal = $hashtableNewActualLength.TotalLength
                }
                if ($uintEntryActual -ne [uint64]$objEntry.Length -or
                    $uintEntryActual -ne [uint64]$hashtableExpectedEvidence.Length) {
                    & $script:scriptBlockStopCandidateHelperOperation `
                        -Code 'extraction-invalid' -Phase 'extraction' -Subreason 'actual-declared-mismatch'
                }
                [void]$objEntrySha256.TransformFinalBlock((New-Object byte[] 0), 0, 0)
                $strEntrySha256 = (
                    [System.BitConverter]::ToString($objEntrySha256.Hash) -replace '-', ''
                ).ToLowerInvariant()
                if ($strEntrySha256 -cne [string]$hashtableExpectedEvidence.Sha256) {
                    & $script:scriptBlockStopCandidateHelperOperation `
                        -Code 'extraction-invalid' -Phase 'extraction' -Subreason 'content-changed'
                }
                $objDestinationStream.Flush($true)
            } catch {
                if ($null -ne $objEntryStream) {
                    $objEntryStream.Dispose()
                    $objEntryStream = $null
                }
                if ($null -ne $objDestinationStream) {
                    $objDestinationStream.Dispose()
                    $objDestinationStream = $null
                }
                throw
            } finally {
                if ($null -ne $objEntrySha256) {
                    $objEntrySha256.Dispose()
                }
                if ($null -ne $objEntryStream) {
                    $objEntryStream.Dispose()
                }
                if ($null -ne $objDestinationStream) {
                    $objDestinationStream.Dispose()
                }
            }
        }

        $strPhase = 'post-extraction'
        [void](& $script:scriptBlockAssertCandidateHelperDirectoryEnvelope `
            -LiteralPath $strCandidatePath `
            -Phase 'post-extraction')
        $arrCandidateEntries = [string[]]@(
            & $script:scriptBlockGetCandidateHelperEntry -LiteralPath $strCandidatePath `
                -Phase 'post-extraction'
        )
        if ($arrCandidateEntries.Count -ne 4) {
            & $script:scriptBlockStopCandidateHelperOperation `
                -Code 'post-extraction-invalid' -Phase 'post-extraction' -Subreason 'entry-count'
        }
        foreach ($strExpectedName in $script:arrCandidateHelperExpectedName) {
            $strDestinationPath = [System.IO.Path]::GetFullPath(
                [System.IO.Path]::Combine($strCandidatePath, $strExpectedName)
            )
            if (-not (& $script:scriptBlockTestCandidateHelperEntryPresent `
                -EntryList $arrCandidateEntries `
                -ExpectedPath $strDestinationPath)) {
                & $script:scriptBlockStopCandidateHelperOperation `
                    -Code 'post-extraction-invalid' -Phase 'post-extraction' -Subreason 'missing-entry'
            }
            $objRecord = @($Context.OwnershipJournal | Where-Object {
                $_.Kind -eq 'CandidateFile' -and $_.LeafName -ceq $strExpectedName
            })[0]
            [void](& $script:scriptBlockReadCandidateHelperValidatedFile `
                -LiteralPath $strDestinationPath `
                -ExpectedLength $objRecord.ContentLength `
                -ExpectedSha256 $objRecord.ContentSha256)
        }

        [void](& $script:scriptBlockAssertCandidateHelperContext -ContextValue $Context)
    } catch {
        $objPrimaryError = $_
    } finally {
        if ($null -ne $objZipArchive) {
            $objZipArchive.Dispose()
        }
        if ($null -ne $objArchiveStream) {
            $objArchiveStream.Dispose()
        }
    }

    if ($null -ne $objPrimaryError) {
        $strPrimaryCode = & $script:scriptBlockGetCandidateHelperFailureField `
            -ErrorRecord $objPrimaryError `
            -Key 'PSStyleGuideDiagnosticCode' `
            -Fallback "$strPhase-invalid"
        $strPrimaryPhase = & $script:scriptBlockGetCandidateHelperFailureField `
            -ErrorRecord $objPrimaryError `
            -Key 'PSStyleGuidePhase' `
            -Fallback $strPhase
        $strPrimarySubreason = & $script:scriptBlockGetCandidateHelperFailureField `
            -ErrorRecord $objPrimaryError `
            -Key 'PSStyleGuideSubreason' `
            -Fallback 'failure'

        $objCleanupResult = $null
        if ($strPrimaryPhase -cne 'parameter' -and $null -ne $objValidatedContext) {
            $objCleanupResult = Remove-StyleGuideCandidateInvocationState -Context $objValidatedContext
        }
        $strCleanupCode = if ($null -eq $objCleanupResult) {
            'not-required'
        } else {
            $objCleanupResult.DiagnosticCode
        }
        $objCompositeException = & $script:scriptBlockNewCandidateHelperException `
            -Code $strPrimaryCode `
            -Phase $strPrimaryPhase `
            -Subreason $strPrimarySubreason
        $objCompositeException.Data['PSStyleGuideCleanupCode'] = $strCleanupCode
        throw $objCompositeException
    }

    return $Context
}

& $script:scriptBlockInvokeCandidateArtifactExpansion
