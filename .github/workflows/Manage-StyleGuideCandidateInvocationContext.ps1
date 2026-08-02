#Requires -Version 5.1

<#
.SYNOPSIS
Creates and removes one journaled style-guide candidate invocation context.

.DESCRIPTION
Creates one unpredictable invocation root below an explicitly trusted
temporary parent and removes only exact, journaled ordinary entries. Cleanup
is nonrecursive and retains uncertain state.

.EXAMPLE
PS> . .\Manage-StyleGuideCandidateInvocationContext.ps1

Loads the context-management functions into the current scope.

.INPUTS
None. You can't pipe objects to this script.

.OUTPUTS
None. Dot-sourcing the script defines its two public functions.

.NOTES
Version: 1.0.20260802.11
#>

[CmdletBinding(PositionalBinding = $false)]
[OutputType([void])]
param ()

$versionCandidateContext = [System.Version]'1.0.20260802.11'
$strCandidateContextTypeName = 'PSStyleGuide.CandidateInvocationContext.v1'
$strCandidateRecordTypeName = 'PSStyleGuide.CandidateOwnershipRecord.v1'
$strCandidateCleanupTypeName = 'PSStyleGuide.CandidateCleanupResult.v1'
# The platform decides which comparison, path grammar, link primitive, and
# filesystem-identity rules apply, so it must not be something a caller can
# assert. The OS environment variable is ordinary and inheritable: exporting
# it as Windows_NT to PowerShell 7 on Linux makes every one of those branches
# take its Windows form, which silently disables mount and inode resolution
# and switches path comparison to case-insensitive. OSVersion.Platform is a
# runtime property with no environment input, and is available on both
# Windows PowerShell 5.1 and PowerShell 7.
$boolCandidateIsWindows = [System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT
$objCandidatePathComparison = if ($boolCandidateIsWindows) {
    [System.StringComparison]::OrdinalIgnoreCase
} else {
    [System.StringComparison]::Ordinal
}
$objCandidatePathComparer = if ($boolCandidateIsWindows) {
    [System.StringComparer]::OrdinalIgnoreCase
} else {
    [System.StringComparer]::Ordinal
}
$chrCandidateDirectorySeparator = [System.IO.Path]::DirectorySeparatorChar
$chrCandidateAlternateSeparator = [System.IO.Path]::AltDirectorySeparatorChar
$intCandidateCreationAttemptMaximum = 16

$scriptBlockNewCandidateException = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Code,

        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    $objException = New-Object System.InvalidOperationException($Message)
    $objException.Data['PSStyleGuideDiagnosticCode'] = $Code
    return $objException
}

$scriptBlockStopCandidateOperation = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Code,

        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    throw (& $scriptBlockNewCandidateException -Code $Code -Message $Message)
}

$scriptBlockAssertCandidateRawString = {
    param (
        [AllowNull()]
        [object]$Value,

        [Parameter(Mandatory = $true)]
        [string]$ParameterName,

        [Parameter(Mandatory = $true)]
        [bool]$IsLabel
    )

    if ($null -eq $Value -or $Value.GetType() -ne [System.String]) {
        & $scriptBlockStopCandidateOperation -Code 'parameter' `
            -Message "PSStyleGuide.Context.v1|phase=parameter|name=$ParameterName|reason=type"
    }

    $strValue = [string]$Value
    if ($strValue.Length -eq 0 -or [System.String]::IsNullOrWhiteSpace($strValue)) {
        & $scriptBlockStopCandidateOperation -Code 'parameter' `
            -Message "PSStyleGuide.Context.v1|phase=parameter|name=$ParameterName|reason=empty"
    }
    foreach ($chrValue in $strValue.ToCharArray()) {
        if ([System.Char]::IsControl($chrValue)) {
            & $scriptBlockStopCandidateOperation -Code 'parameter' `
                -Message "PSStyleGuide.Context.v1|phase=parameter|name=$ParameterName|reason=control"
        }
    }
    if ($IsLabel -and $strValue.Length -gt 128) {
        & $scriptBlockStopCandidateOperation -Code 'parameter' `
            -Message "PSStyleGuide.Context.v1|phase=parameter|name=$ParameterName|reason=length"
    }
    return $strValue
}

$scriptBlockGetCandidateDiagnosticCode = {
    param (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.ErrorRecord]$ErrorRecord,

        [Parameter(Mandatory = $true)]
        [string]$Fallback
    )

    if ($null -ne $ErrorRecord.Exception -and
        $null -ne $ErrorRecord.Exception.Data -and
        $ErrorRecord.Exception.Data.Contains('PSStyleGuideDiagnosticCode')) {
        $objCode = $ErrorRecord.Exception.Data['PSStyleGuideDiagnosticCode']
        if ($null -ne $objCode -and $objCode.GetType() -eq [System.String] -and
            $objCode.Length -gt 0 -and $objCode.Length -le 64 -and
            $objCode -match '^[a-z][a-z0-9-]*$') {
            return [string]$objCode
        }
    }
    return $Fallback
}

$scriptBlockAssertCandidateSafePathText = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Value,

        [Parameter(Mandatory = $true)]
        [string]$ParameterName
    )

    if ([System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Value)) {
        & $scriptBlockStopCandidateOperation -Code 'parameter' `
            -Message "PSStyleGuide.Context.v1|phase=parameter|name=$ParameterName|reason=wildcard"
    }
    $boolDriveRelative = $Value.Length -ge 2 -and
        [System.Char]::IsLetter($Value[0]) -and
        $Value[1] -eq ':' -and
        ($Value.Length -eq 2 -or
            ($Value[2] -ne [char]'\' -and $Value[2] -ne [char]'/'))
    if ($boolDriveRelative -or $Value.IndexOf([char]0) -ge 0) {
        & $scriptBlockStopCandidateOperation -Code 'parameter' `
            -Message "PSStyleGuide.Context.v1|phase=parameter|name=$ParameterName|reason=path-grammar"
    }
}

$scriptBlockResolveCandidateExistingDirectory = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Value,

        [Parameter(Mandatory = $true)]
        [string]$ParameterName
    )

    [void](& $scriptBlockAssertCandidateSafePathText -Value $Value -ParameterName $ParameterName)
    $objProvider = $null
    try {
        $arrResolved = @(
            $ExecutionContext.SessionState.Path.GetResolvedProviderPathFromPSPath(
                $Value,
                [ref]$objProvider
            )
        )
    } catch {
        & $scriptBlockStopCandidateOperation -Code 'root-invalid' `
            -Message "PSStyleGuide.Context.v1|phase=root|name=$ParameterName|reason=resolution"
    }
    if ($null -eq $objProvider -or $objProvider.Name -cne 'FileSystem' -or $arrResolved.Count -ne 1) {
        & $scriptBlockStopCandidateOperation -Code 'root-invalid' `
            -Message "PSStyleGuide.Context.v1|phase=root|name=$ParameterName|reason=provider"
    }
    try {
        $strFullPath = [System.IO.Path]::GetFullPath([string]$arrResolved[0])
    } catch {
        & $scriptBlockStopCandidateOperation -Code 'root-invalid' `
            -Message "PSStyleGuide.Context.v1|phase=root|name=$ParameterName|reason=normalization"
    }
    if (-not [System.IO.Path]::IsPathRooted($strFullPath)) {
        & $scriptBlockStopCandidateOperation -Code 'root-invalid' `
            -Message "PSStyleGuide.Context.v1|phase=root|name=$ParameterName|reason=relative"
    }
    return $strFullPath
}

$scriptBlockAssertCandidateOrdinaryDirectoryEnvelope = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [ref]$ReferenceToFilesystemCallCount
    )

    $strFailureCode = if ($null -ne $ReferenceToFilesystemCallCount) {
        $ReferenceToFilesystemCallCount.Value = [uint32](
            $ReferenceToFilesystemCallCount.Value + 1
        )
        'cleanup-owned-entry-uncertain'
    } else {
        'root-invalid'
    }
    $strFailurePhase = if ($null -ne $ReferenceToFilesystemCallCount) {
        'cleanup'
    } else {
        'root'
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
    if (-not $boolCandidateIsWindows) {
        $arrStatCommands = @(Get-Command -Name 'stat' `
            -CommandType Application -ErrorAction SilentlyContinue)
        if ($arrStatCommands.Count -lt 1) {
            & $scriptBlockStopCandidateOperation -Code $strFailureCode `
                -Message "PSStyleGuide.Context.v1|phase=$strFailurePhase|reason=identity"
        }
        $strStatPath = [string]$arrStatCommands[0].Source
    }
    $strPreviousDevice = $null
    for ($intIndex = $listComponents.Count - 1; $intIndex -ge 0; $intIndex--) {
        $strComponent = $listComponents[$intIndex]
        try {
            $objAttributes = [System.IO.File]::GetAttributes($strComponent)
        } catch {
            & $scriptBlockStopCandidateOperation -Code $strFailureCode `
                -Message "PSStyleGuide.Context.v1|phase=$strFailurePhase|reason=attribute"
        }
        if (($objAttributes -band [System.IO.FileAttributes]::Directory) -eq 0 -or
            ($objAttributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            & $scriptBlockStopCandidateOperation -Code $strFailureCode `
                -Message "PSStyleGuide.Context.v1|phase=$strFailurePhase|reason=nonordinary"
        }

        if (-not $boolCandidateIsWindows) {
            $arrFileSystemStatus = @(& $strStatPath '-Lc' '%d' '--' $strComponent 2>$null)
            $intFileSystemStatusExitCode = $LASTEXITCODE
            if ($intFileSystemStatusExitCode -ne 0 -or
                $arrFileSystemStatus.Count -ne 1 -or
                $arrFileSystemStatus[0] -notmatch '^[0-9]+$') {
                & $scriptBlockStopCandidateOperation -Code $strFailureCode `
                    -Message "PSStyleGuide.Context.v1|phase=$strFailurePhase|reason=identity"
            }
            if ($null -ne $strPreviousDevice -and
                $arrFileSystemStatus[0] -cne $strPreviousDevice) {
                & $scriptBlockStopCandidateOperation -Code $strFailureCode `
                    -Message "PSStyleGuide.Context.v1|phase=$strFailurePhase|reason=mount"
            }
            $strPreviousDevice = [string]$arrFileSystemStatus[0]
        }
    }
}

$scriptBlockGetCandidateImmediateEntry = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [string]$FailureCode,

        [string]$FailurePhase,

        [ref]$ReferenceToFilesystemCallCount
    )

    # Both lifecycles call this, and the supplied call counter is what tells
    # them apart: cleanup passes one, creation does not. Reporting a cleanup
    # code and phase for a creation-time enumeration failure would tell the
    # caller a cleanup had failed when no cleanup had run. This mirrors the
    # ordinary-directory envelope check above rather than inventing a second
    # convention in the same file.
    # The counter separates cleanup from creation, but creation has more than
    # one meaning: enumerating the caller's trusted parent is a root claim,
    # while enumerating the invocation root after creating it is context
    # verification. The check immediately following that second call already
    # reports context-create-verification, so inferring both values from the
    # counter alone made the two disagree about the same enumeration. A call
    # site that knows its own phase states it.
    $strFailureCode = if ($FailureCode.Length -ne 0) {
        $FailureCode
    } elseif ($null -ne $ReferenceToFilesystemCallCount) {
        'cleanup-owned-entry-uncertain'
    } else {
        'root-invalid'
    }
    $strFailurePhase = if ($FailurePhase.Length -ne 0) {
        $FailurePhase
    } elseif ($null -ne $ReferenceToFilesystemCallCount) {
        'cleanup'
    } else {
        'root'
    }
    try {
        if ($null -ne $ReferenceToFilesystemCallCount) {
            $ReferenceToFilesystemCallCount.Value = [uint32]($ReferenceToFilesystemCallCount.Value + 1)
        }
        return [string[]]@([System.IO.Directory]::EnumerateFileSystemEntries($LiteralPath))
    } catch {
        & $scriptBlockStopCandidateOperation -Code $strFailureCode `
            -Message "PSStyleGuide.Context.v1|phase=$strFailurePhase|reason=enumeration"
    }
}

$scriptBlockTestCandidateEntryPresent = {
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
            $objCandidatePathComparison
        )) {
            $intMatches++
        }
    }
    return $intMatches -eq 1
}

$scriptBlockNewCandidateRecord = {
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
        [string]$ExpectedEntryType,

        [Parameter(Mandatory = $true)]
        [string]$CreationPhase,

        [Parameter(Mandatory = $true)]
        [string]$EntryState,

        [AllowNull()]
        [object]$ContentLength,

        [AllowNull()]
        [object]$ContentSha256
    )

    $objRecord = [pscustomobject][ordered]@{
        SchemaVersion = [uint32]1
        Sequence = [uint32]$Sequence
        Kind = [string]$Kind
        Path = [string]$Path
        ParentPath = [string]$ParentPath
        LeafName = [string]$LeafName
        ExpectedEntryType = [string]$ExpectedEntryType
        CreationPhase = [string]$CreationPhase
        EntryState = [string]$EntryState
        ContentLength = $ContentLength
        ContentSha256 = $ContentSha256
    }
    $objRecord.PSObject.TypeNames.Insert(0, $strCandidateRecordTypeName)
    return $objRecord
}

$scriptBlockNewCandidateContext = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$DiagnosticLabel,

        [Parameter(Mandatory = $true)]
        [string]$TrustedParentPath,

        [Parameter(Mandatory = $true)]
        [string]$InvocationRootPath,

        [Parameter(Mandatory = $true)]
        [string]$DownloadDirectoryPath,

        [Parameter(Mandatory = $true)]
        [string]$CandidatePath
    )

    $objRootRecord = & $scriptBlockNewCandidateRecord `
        -Sequence ([uint32]0) `
        -Kind 'InvocationRootDirectory' `
        -Path $InvocationRootPath `
        -ParentPath $TrustedParentPath `
        -LeafName ([System.IO.Path]::GetFileName($InvocationRootPath)) `
        -ExpectedEntryType 'Directory' `
        -CreationPhase 'context' `
        -EntryState 'ExpectedAbsent' `
        -ContentLength $null `
        -ContentSha256 $null
    $objDownloadRecord = & $scriptBlockNewCandidateRecord `
        -Sequence ([uint32]1) `
        -Kind 'DownloadDirectory' `
        -Path $DownloadDirectoryPath `
        -ParentPath $InvocationRootPath `
        -LeafName ([System.IO.Path]::GetFileName($DownloadDirectoryPath)) `
        -ExpectedEntryType 'Directory' `
        -CreationPhase 'context' `
        -EntryState 'ExpectedAbsent' `
        -ContentLength $null `
        -ContentSha256 $null
    $objCandidateRecord = & $scriptBlockNewCandidateRecord `
        -Sequence ([uint32]2) `
        -Kind 'CandidateDirectory' `
        -Path $CandidatePath `
        -ParentPath $InvocationRootPath `
        -LeafName ([System.IO.Path]::GetFileName($CandidatePath)) `
        -ExpectedEntryType 'Directory' `
        -CreationPhase 'context' `
        -EntryState 'ExpectedAbsent' `
        -ContentLength $null `
        -ContentSha256 $null

    $objContext = [pscustomobject][ordered]@{
        SchemaVersion = [uint32]1
        ContextScriptVersion = $versionCandidateContext
        InvocationId = [System.Guid]::NewGuid()
        DiagnosticLabel = [string]$DiagnosticLabel
        TrustedParentPath = [string]$TrustedParentPath
        InvocationRootPath = [string]$InvocationRootPath
        DownloadDirectoryPath = [string]$DownloadDirectoryPath
        CandidatePath = [string]$CandidatePath
        LifecycleState = [string]'Active'
        NextSequence = [uint32]3
        OwnershipJournal = [object[]]@(
            $objRootRecord,
            $objDownloadRecord,
            $objCandidateRecord
        )
    }
    $objContext.PSObject.TypeNames.Insert(0, $strCandidateContextTypeName)
    return $objContext
}

$scriptBlockAssertCandidateExactPropertySchema = {
    param (
        [Parameter(Mandatory = $true)]
        [object]$Value,

        [Parameter(Mandatory = $true)]
        [string[]]$ExpectedNames
    )

    $arrProperties = @($Value.PSObject.Properties)
    if ($arrProperties.Count -ne $ExpectedNames.Count) {
        throw 'cleanup-context-invalid'
    }
    for ($intIndex = 0; $intIndex -lt $ExpectedNames.Count; $intIndex++) {
        if ($arrProperties[$intIndex].Name -cne $ExpectedNames[$intIndex] -or
            $arrProperties[$intIndex].MemberType -ne [System.Management.Automation.PSMemberTypes]::NoteProperty) {
            throw 'cleanup-context-invalid'
        }
    }
}

$scriptBlockAssertCandidateCanonicalStoredPath = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    if ($Value.Length -eq 0 -or
        [System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($Value) -or
        $Value.IndexOf('::', [System.StringComparison]::Ordinal) -ge 0) {
        throw 'cleanup-context-invalid'
    }
    foreach ($chrValue in $Value.ToCharArray()) {
        if ([System.Char]::IsControl($chrValue)) {
            throw 'cleanup-context-invalid'
        }
    }

    if ($boolCandidateIsWindows) {
        if ($Value.IndexOf([char]'/') -ge 0) {
            throw 'cleanup-context-invalid'
        }
        $boolDriveRooted = $Value.Length -ge 3 -and
            [System.Char]::IsLetter($Value[0]) -and
            $Value[1] -eq [char]':' -and
            $Value[2] -eq [char]'\'
        $boolUncRooted = $Value.Length -ge 5 -and
            $Value[0] -eq [char]'\' -and $Value[1] -eq [char]'\'
        if (-not $boolDriveRooted -and -not $boolUncRooted) {
            throw 'cleanup-context-invalid'
        }
        $strRemainder = if ($boolDriveRooted) {
            $Value.Substring(3)
        } else {
            $Value.Substring(2)
        }
        $arrComponents = @($strRemainder.Split([char]'\'))
        if ($boolUncRooted -and $arrComponents.Count -lt 2) {
            throw 'cleanup-context-invalid'
        }
    } else {
        if ($Value[0] -ne [char]'/' -or $Value.IndexOf([char]0) -ge 0) {
            throw 'cleanup-context-invalid'
        }
        $arrComponents = @($Value.Substring(1).Split([char]'/'))
    }

    for ($intIndex = 0; $intIndex -lt $arrComponents.Count; $intIndex++) {
        $strComponent = $arrComponents[$intIndex]
        $boolAllowedTrailingEmpty = $intIndex -eq ($arrComponents.Count - 1) -and
            $strComponent.Length -eq 0 -and
            (($boolCandidateIsWindows -and $boolDriveRooted -and $Value.Length -eq 3) -or
                (-not $boolCandidateIsWindows -and $Value.Length -eq 1))
        if (-not $boolAllowedTrailingEmpty -and
            ($strComponent.Length -eq 0 -or $strComponent -in @('.', '..'))) {
            throw 'cleanup-context-invalid'
        }
    }
}

$scriptBlockAssertCandidateInMemoryContext = {
    param (
        [AllowNull()]
        [object]$Context
    )

    if ($null -eq $Context -or
        $Context.GetType() -ne [System.Management.Automation.PSCustomObject] -or
        $Context.PSObject.TypeNames.Count -eq 0 -or
        $Context.PSObject.TypeNames[0] -cne $strCandidateContextTypeName) {
        throw 'cleanup-context-invalid'
    }

    [void](& $scriptBlockAssertCandidateExactPropertySchema -Value $Context -ExpectedNames @(
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

    if ($Context.SchemaVersion.GetType() -ne [System.UInt32] -or $Context.SchemaVersion -ne [uint32]1 -or
        $Context.ContextScriptVersion.GetType() -ne [System.Version] -or
        $Context.ContextScriptVersion -ne $versionCandidateContext -or
        $Context.InvocationId.GetType() -ne [System.Guid] -or
        $Context.InvocationId -eq [System.Guid]::Empty -or
        $Context.DiagnosticLabel.GetType() -ne [System.String] -or
        $Context.DiagnosticLabel.Length -eq 0 -or $Context.DiagnosticLabel.Length -gt 128 -or
        [System.String]::IsNullOrWhiteSpace($Context.DiagnosticLabel) -or
        $Context.TrustedParentPath.GetType() -ne [System.String] -or
        $Context.TrustedParentPath.Length -eq 0 -or
        $Context.InvocationRootPath.GetType() -ne [System.String] -or
        $Context.InvocationRootPath.Length -eq 0 -or
        $Context.DownloadDirectoryPath.GetType() -ne [System.String] -or
        $Context.DownloadDirectoryPath.Length -eq 0 -or
        $Context.CandidatePath.GetType() -ne [System.String] -or
        $Context.CandidatePath.Length -eq 0 -or
        $Context.LifecycleState.GetType() -ne [System.String] -or
        $Context.LifecycleState -cnotin @('Active', 'CleanupFailed', 'Disposed') -or
        $Context.NextSequence.GetType() -ne [System.UInt32] -or
        $Context.OwnershipJournal.GetType() -ne [System.Object[]] -or
        $Context.NextSequence -ne [uint32]$Context.OwnershipJournal.Count) {
        throw 'cleanup-context-invalid'
    }

    foreach ($strContextPath in @(
        $Context.TrustedParentPath,
        $Context.InvocationRootPath,
        $Context.DownloadDirectoryPath,
        $Context.CandidatePath
    )) {
        [void](& $scriptBlockAssertCandidateCanonicalStoredPath -Value $strContextPath)
    }

    foreach ($chrLabel in $Context.DiagnosticLabel.ToCharArray()) {
        if ([System.Char]::IsControl($chrLabel)) {
            throw 'cleanup-context-invalid'
        }

    }

    $objPathSet = New-Object 'System.Collections.Generic.HashSet[string]' `
        ($objCandidatePathComparer)
    $hashtableKindCount = @{
        InvocationRootDirectory = 0
        DownloadDirectory = 0
        DownloadFile = 0
        CandidateDirectory = 0
        CandidateFile = 0
    }

    for ($intIndex = 0; $intIndex -lt $Context.OwnershipJournal.Count; $intIndex++) {
        $objRecord = $Context.OwnershipJournal[$intIndex]
        if ($null -eq $objRecord -or
            $objRecord.GetType() -ne [System.Management.Automation.PSCustomObject] -or
            $objRecord.PSObject.TypeNames.Count -eq 0 -or
            $objRecord.PSObject.TypeNames[0] -cne $strCandidateRecordTypeName) {
            throw 'cleanup-context-invalid'
        }
        [void](& $scriptBlockAssertCandidateExactPropertySchema -Value $objRecord -ExpectedNames @(
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
            -not $hashtableKindCount.ContainsKey($objRecord.Kind) -or
            $objRecord.Path.GetType() -ne [System.String] -or $objRecord.Path.Length -eq 0 -or
            $objRecord.ParentPath.GetType() -ne [System.String] -or $objRecord.ParentPath.Length -eq 0 -or
            $objRecord.LeafName.GetType() -ne [System.String] -or $objRecord.LeafName.Length -eq 0 -or
            $objRecord.LeafName -in @('.', '..') -or
            $objRecord.LeafName.IndexOf($chrCandidateDirectorySeparator) -ge 0 -or
            $objRecord.LeafName.IndexOf($chrCandidateAlternateSeparator) -ge 0 -or
            $objRecord.ExpectedEntryType.GetType() -ne [System.String] -or
            $objRecord.ExpectedEntryType -cnotin @('File', 'Directory') -or
            $objRecord.CreationPhase.GetType() -ne [System.String] -or
            $objRecord.CreationPhase -cnotin @('context', 'download', 'destination', 'extraction') -or
            $objRecord.EntryState.GetType() -ne [System.String] -or
            $objRecord.EntryState -cnotin @('ExpectedAbsent', 'Created', 'Deleted', 'RetainedUncertain')) {
            throw 'cleanup-context-invalid'
        }

        [void](& $scriptBlockAssertCandidateCanonicalStoredPath -Value $objRecord.Path)
        [void](& $scriptBlockAssertCandidateCanonicalStoredPath -Value $objRecord.ParentPath)

        $strParentPrefix = $objRecord.ParentPath.TrimEnd(
            $chrCandidateDirectorySeparator,
            $chrCandidateAlternateSeparator
        ) + $chrCandidateDirectorySeparator
        $strRecomposed = $strParentPrefix + $objRecord.LeafName
        if (-not [System.String]::Equals(
            $strRecomposed,
            $objRecord.Path,
            $objCandidatePathComparison
        ) -or -not $objPathSet.Add($objRecord.Path)) {
            throw 'cleanup-context-invalid'
        }

        $hashtableKindCount[$objRecord.Kind]++
        if ($objRecord.Kind -in @('InvocationRootDirectory', 'DownloadDirectory', 'CandidateDirectory')) {
            if ($objRecord.ExpectedEntryType -cne 'Directory' -or
                $null -ne $objRecord.ContentLength -or $null -ne $objRecord.ContentSha256) {
                throw 'cleanup-context-invalid'
            }
        } else {
            if ($objRecord.ExpectedEntryType -cne 'File' -or
                $objRecord.EntryState -eq 'ExpectedAbsent' -or
                $null -eq $objRecord.ContentLength -or
                $objRecord.ContentLength.GetType() -ne [System.UInt64] -or
                $null -eq $objRecord.ContentSha256 -or
                $objRecord.ContentSha256.GetType() -ne [System.String] -or
                $objRecord.ContentSha256 -cnotmatch '^[0-9a-f]{64}$') {
                throw 'cleanup-context-invalid'
            }
        }

        if ($objRecord.Kind -eq 'InvocationRootDirectory') {
            if ($objRecord.CreationPhase -cne 'context' -or
                $objRecord.EntryState -eq 'ExpectedAbsent') {
                throw 'cleanup-context-invalid'
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
                throw 'cleanup-context-invalid'
            }
        } elseif ($objRecord.Kind -eq 'DownloadFile') {
            if ($objRecord.CreationPhase -cne 'download') {
                throw 'cleanup-context-invalid'
            }
        } elseif ($objRecord.Kind -eq 'CandidateDirectory') {
            if (($objRecord.EntryState -eq 'ExpectedAbsent' -and $objRecord.CreationPhase -cne 'context') -or
                ($objRecord.EntryState -ne 'ExpectedAbsent' -and $objRecord.CreationPhase -cne 'destination')) {
                throw 'cleanup-context-invalid'
            }
        } elseif ($objRecord.CreationPhase -cne 'extraction') {
            throw 'cleanup-context-invalid'
        }

        if ($objRecord.Kind -eq 'InvocationRootDirectory') {
            if (-not [System.String]::Equals(
                $objRecord.Path,
                $Context.InvocationRootPath,
                $objCandidatePathComparison
            ) -or -not [System.String]::Equals(
                $objRecord.ParentPath,
                $Context.TrustedParentPath,
                $objCandidatePathComparison
            )) {
                throw 'cleanup-context-invalid'
            }
        } elseif ($objRecord.Kind -eq 'DownloadDirectory') {
            if (-not [System.String]::Equals(
                $objRecord.Path,
                $Context.DownloadDirectoryPath,
                $objCandidatePathComparison
            ) -or -not [System.String]::Equals(
                $objRecord.ParentPath,
                $Context.InvocationRootPath,
                $objCandidatePathComparison
            )) {
                throw 'cleanup-context-invalid'
            }
        } elseif ($objRecord.Kind -eq 'DownloadFile') {
            if (-not [System.String]::Equals(
                $objRecord.ParentPath,
                $Context.DownloadDirectoryPath,
                $objCandidatePathComparison
            )) {
                throw 'cleanup-context-invalid'
            }
        } elseif ($objRecord.Kind -eq 'CandidateDirectory') {
            if (-not [System.String]::Equals(
                $objRecord.Path,
                $Context.CandidatePath,
                $objCandidatePathComparison
            ) -or -not [System.String]::Equals(
                $objRecord.ParentPath,
                $Context.InvocationRootPath,
                $objCandidatePathComparison
            )) {
                throw 'cleanup-context-invalid'
            }
        } elseif (-not [System.String]::Equals(
            $objRecord.ParentPath,
            $Context.CandidatePath,
            $objCandidatePathComparison
        )) {
            throw 'cleanup-context-invalid'
        }
    }

    if ($hashtableKindCount.InvocationRootDirectory -ne 1 -or
        $hashtableKindCount.DownloadDirectory -ne 1 -or
        $hashtableKindCount.CandidateDirectory -ne 1 -or
        $hashtableKindCount.DownloadFile -gt 1) {
        throw 'cleanup-context-invalid'
    }
    $objCandidateDirectoryRecord = @($Context.OwnershipJournal | Where-Object {
        $_.Kind -eq 'CandidateDirectory'
    })[0]
    $arrCandidateFileRecords = @($Context.OwnershipJournal | Where-Object {
        $_.Kind -eq 'CandidateFile'
    })
    if ($arrCandidateFileRecords.Count -gt 4 -or
        ($objCandidateDirectoryRecord.EntryState -eq 'ExpectedAbsent' -and
            $arrCandidateFileRecords.Count -ne 0) -or
        ($objCandidateDirectoryRecord.EntryState -eq 'Deleted' -and
            @($arrCandidateFileRecords | Where-Object { $_.EntryState -ne 'Deleted' }).Count -ne 0)) {
        throw 'cleanup-context-invalid'
    }
    if ($Context.LifecycleState -eq 'Active') {
        $objRootRecord = @($Context.OwnershipJournal | Where-Object {
            $_.Kind -eq 'InvocationRootDirectory'
        })[0]
        $objDownloadDirectoryRecord = @($Context.OwnershipJournal | Where-Object {
            $_.Kind -eq 'DownloadDirectory'
        })[0]
        # Which record states an Active context may carry at all is settled by
        # the admitted-state table below. What remains here is the part that
        # table cannot express: the states these two specific kinds must hold.
        if ($objRootRecord.EntryState -cne 'Created' -or
            $objDownloadDirectoryRecord.EntryState -cnotin @('Created', 'ExpectedAbsent')) {
            throw 'cleanup-context-invalid'
        }

        # ExpectedAbsent is reachable only from bounded creation-failure
        # cleanup, where nothing was ever placed beneath the download
        # directory. Rather than trusting which caller asked, require the
        # journal to agree with itself: a download directory that was never
        # created cannot contain a download file, and no candidate can have
        # been created either.
        if ($objDownloadDirectoryRecord.EntryState -ceq 'ExpectedAbsent') {
            $objCandidateRecord = @($Context.OwnershipJournal | Where-Object {
                $_.Kind -eq 'CandidateDirectory'
            })[0]
            if (@($Context.OwnershipJournal | Where-Object {
                        $_.Kind -eq 'DownloadFile'
                    }).Count -ne 0 -or
                @($Context.OwnershipJournal | Where-Object {
                        $_.Kind -eq 'CandidateFile'
                    }).Count -ne 0 -or
                $objCandidateRecord.EntryState -cne 'ExpectedAbsent') {
                throw 'cleanup-context-invalid'
            }
        }
    }
    # Each lifecycle state admits an exact set of record states, and one state
    # additionally demands a member. Stating the pairing as data rather than as
    # a block per lifecycle state keeps every combination classified: an
    # unlisted record state is refused because it was never admitted, not
    # because someone remembered to name it. A per-state deny list would let a
    # record state added later pass silently everywhere it was not yet listed.
    #
    # CleanupFailed is terminal and does no filesystem work, so it reports the
    # owned entries it could not resolve instead of removing them. A surviving
    # Created record would name an entry that is owned and present yet absent
    # from that report, so Created is not admitted here: the producing failure
    # path retypes every Created record before reaching this state.
    $hashtableAdmittedEntryState = @{
        'Active' = [string[]]@('ExpectedAbsent', 'Created', 'Deleted')
        'CleanupFailed' = [string[]]@('ExpectedAbsent', 'Deleted', 'RetainedUncertain')
        'Disposed' = [string[]]@('ExpectedAbsent', 'Deleted')
    }
    $hashtableRequiredEntryState = @{
        'CleanupFailed' = 'RetainedUncertain'
    }
    if (-not $hashtableAdmittedEntryState.ContainsKey($Context.LifecycleState)) {
        throw 'cleanup-context-invalid'
    }
    $arrAdmittedEntryState = [string[]]$hashtableAdmittedEntryState[$Context.LifecycleState]
    foreach ($objRecord in $Context.OwnershipJournal) {
        if ($objRecord.EntryState -cnotin $arrAdmittedEntryState) {
            throw 'cleanup-context-invalid'
        }
    }
    if ($hashtableRequiredEntryState.ContainsKey($Context.LifecycleState)) {
        $strRequiredEntryState = [string]$hashtableRequiredEntryState[$Context.LifecycleState]
        $boolRequiredPresent = $false
        foreach ($objRecord in $Context.OwnershipJournal) {
            if ($objRecord.EntryState -ceq $strRequiredEntryState) {
                $boolRequiredPresent = $true
            }
        }
        if (-not $boolRequiredPresent) {
            throw 'cleanup-context-invalid'
        }
    }
}

$scriptBlockGetCandidateRetainedSequence = {
    param (
        [Parameter(Mandatory = $true)]
        [object]$Context
    )

    $listSequences = New-Object 'System.Collections.Generic.List[uint32]'
    foreach ($objRecord in $Context.OwnershipJournal) {
        if ($objRecord.EntryState -eq 'RetainedUncertain') {
            $listSequences.Add([uint32]$objRecord.Sequence)
        }
    }
    # The unary comma keeps an empty result an empty array. Returning it
    # bare would unroll to null and break the closed result schema.
    return ,[uint32[]]$listSequences.ToArray()
}

$scriptBlockNewCandidateCleanupResult = {
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
        ContextScriptVersion = $versionCandidateContext
        InvocationId = $InvocationId
        PreviousState = [string]$PreviousState
        FinalState = [string]$FinalState
        Success = [bool]$Success
        DiagnosticCode = [string]$DiagnosticCode
        FilesystemCallCount = [uint32]$ReferenceToFilesystemCallCount
        RetainedRecordSequences = [uint32[]]@($RetainedRecordSequences)
    }
    $objResult.PSObject.TypeNames.Insert(0, $strCandidateCleanupTypeName)
    return $objResult
}

$scriptBlockGetCandidateFileEvidence = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [ref]$ReferenceToFilesystemCallCount
    )

    try {
        $ReferenceToFilesystemCallCount.Value = [uint32]($ReferenceToFilesystemCallCount.Value + 1)
        $objAttributes = [System.IO.File]::GetAttributes($LiteralPath)
        if (($objAttributes -band [System.IO.FileAttributes]::Directory) -ne 0 -or
            ($objAttributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw 'nonordinary'
        }
        $ReferenceToFilesystemCallCount.Value = [uint32]($ReferenceToFilesystemCallCount.Value + 1)
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
                $strHash = (
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
            Sha256 = $strHash
        }
    } catch {
        & $scriptBlockStopCandidateOperation -Code 'cleanup-owned-entry-uncertain' `
            -Message 'PSStyleGuide.Context.v1|phase=cleanup|reason=file-evidence'
    }
}

function New-StyleGuideCandidateInvocationContext {
    # .SYNOPSIS
    # Creates one journaled style-guide candidate invocation context.
    #
    # .DESCRIPTION
    # Validates an explicit temporary parent, creates a fresh invocation root
    # and download directory, selects an absent candidate leaf, and returns the
    # exact mutable context object that owns those filesystem entries.
    #
    # .PARAMETER TrustedTemporaryRoot
    # Specifies the raw FileSystem directory below which to create the context.
    #
    # .PARAMETER DiagnosticLabel
    # Specifies an optional opaque diagnostic label of at most 128 UTF-16 code
    # units. Omission stores the literal value unavailable.
    #
    # .EXAMPLE
    # $objContext = New-StyleGuideCandidateInvocationContext `
    #     -TrustedTemporaryRoot $strTemporaryRoot
    #
    # # Returns one active PSStyleGuide.CandidateInvocationContext.v1 object.
    #
    # .EXAMPLE
    # $objContext = New-StyleGuideCandidateInvocationContext `
    #     -TrustedTemporaryRoot $strTemporaryRoot `
    #     -DiagnosticLabel 'candidate-validation'
    #
    # # Stores the exact opaque label on the returned context.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [pscustomobject] One PSStyleGuide.CandidateInvocationContext.v1 object.
    #
    # .NOTES
    # This function supports named parameters only.
    #
    # Version: 1.0.20260802.11
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
        [object]$TrustedTemporaryRoot,

        [Parameter()]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [object]$DiagnosticLabel
    )

    Set-StrictMode -Version Latest

    $boolLabelProvided = $PSBoundParameters.ContainsKey('DiagnosticLabel')
    $objContext = $null
    $boolRootCreated = $false
    $strCreationCategory = 'context-create-failed'

    try {
        $strTrustedTemporaryRoot = & $scriptBlockAssertCandidateRawString `
            -Value $TrustedTemporaryRoot `
            -ParameterName 'TrustedTemporaryRoot' `
            -IsLabel $false
        if ($boolLabelProvided) {
            $strDiagnosticLabel = & $scriptBlockAssertCandidateRawString `
                -Value $DiagnosticLabel `
                -ParameterName 'DiagnosticLabel' `
                -IsLabel $true
        } else {
            $strDiagnosticLabel = 'unavailable'
        }

        $strTrustedParent = & $scriptBlockResolveCandidateExistingDirectory `
            -Value $strTrustedTemporaryRoot `
            -ParameterName 'TrustedTemporaryRoot'
        [void](& $scriptBlockAssertCandidateOrdinaryDirectoryEnvelope `
            -LiteralPath $strTrustedParent)

        for ($intAttempt = 0; $intAttempt -lt $intCandidateCreationAttemptMaximum; $intAttempt++) {
            $strInvocationLeaf = [System.IO.Path]::GetRandomFileName()
            $strInvocationRoot = [System.IO.Path]::GetFullPath(
                [System.IO.Path]::Combine($strTrustedParent, $strInvocationLeaf)
            )
            $arrParentEntries = [string[]]@(
                & $scriptBlockGetCandidateImmediateEntry `
                    -LiteralPath $strTrustedParent
            )
            $boolCollision = $false
            foreach ($strEntry in $arrParentEntries) {
                if ([System.String]::Equals(
                    $strEntry,
                    $strInvocationRoot,
                    $objCandidatePathComparison
                )) {
                    $boolCollision = $true
                }
            }
            if ($boolCollision) {
                continue
            }

            $strDownloadDirectory = [System.IO.Path]::GetFullPath(
                [System.IO.Path]::Combine($strInvocationRoot, 'download')
            )
            $strCandidatePath = [System.IO.Path]::GetFullPath(
                [System.IO.Path]::Combine($strInvocationRoot, 'candidate')
            )
            $objContext = & $scriptBlockNewCandidateContext `
                -DiagnosticLabel $strDiagnosticLabel `
                -TrustedParentPath $strTrustedParent `
                -InvocationRootPath $strInvocationRoot `
                -DownloadDirectoryPath $strDownloadDirectory `
                -CandidatePath $strCandidatePath

            $null = [System.IO.Directory]::CreateDirectory($strInvocationRoot)

            # Prove the path is an ordinary link-free directory before anything
            # reads or writes through it. CreateDirectory succeeds on a name
            # that is already a symbolic link to a directory, and both checks
            # below reach through the path: the enumeration would describe the
            # link's target and the claim would be written inside it, outside
            # trusted storage. The parent enumeration above skips names that
            # already exist, so such a link can only appear in the window
            # between that enumeration and this create -- which is exactly the
            # window these checks exist to close, so they cannot be the first
            # thing to assume it is shut.
            [void](& $scriptBlockAssertCandidateOrdinaryDirectoryEnvelope `
                -LiteralPath $strInvocationRoot)

            # CreateDirectory returns the same thing whether it made the
            # directory or found one already there, so on its own it is not
            # evidence of ownership -- and ownership is what later authorises
            # deleting this tree. Prove it twice before recording it.
            #
            # An unpredictable leaf makes the pre-existing case unlikely rather
            # than impossible, and unlikely is the wrong footing for a claim
            # that drives a delete. Neither failure below removes anything: a
            # directory that fails these tests is by definition not this
            # invocation's to delete, so the loop leaves it alone and takes a
            # different name.
            $arrClaimEntries = [string[]]@(
                & $scriptBlockGetCandidateImmediateEntry `
                    -LiteralPath $strInvocationRoot `
                    -FailureCode 'context-create-verification' `
                    -FailurePhase 'context'
            )
            if ($arrClaimEntries.Count -ne 0) {
                continue
            }
            # Emptiness alone would still admit an empty directory someone else
            # made. An exclusive create refuses the name outright if another
            # participant already holds it, which no pre-existing directory can
            # satisfy on our behalf.
            $strClaimPath = [System.IO.Path]::Combine(
                $strInvocationRoot,
                'claim-' + [System.Guid]::NewGuid().ToString('N')
            )
            try {
                $objClaimStream = New-Object System.IO.FileStream(
                    $strClaimPath,
                    [System.IO.FileMode]::CreateNew,
                    [System.IO.FileAccess]::Write,
                    [System.IO.FileShare]::None
                )
                $objClaimStream.Dispose()
            } catch {
                continue
            }
            # The claim is transient by necessity: the verification below
            # requires the root to hold exactly the download directory, so a
            # marker left behind would fail the very check it precedes.
            try {
                [System.IO.File]::Delete($strClaimPath)
            } catch {
                & $scriptBlockStopCandidateOperation -Code 'context-create-verification' `
                    -Message 'PSStyleGuide.Context.v1|phase=context|reason=claim-residue'
            }
            if ([System.IO.File]::Exists($strClaimPath)) {
                & $scriptBlockStopCandidateOperation -Code 'context-create-verification' `
                    -Message 'PSStyleGuide.Context.v1|phase=context|reason=claim-residue'
            }

            $boolRootCreated = $true
            $objContext.OwnershipJournal[0].EntryState = 'Created'

            $null = [System.IO.Directory]::CreateDirectory($strDownloadDirectory)
            $objContext.OwnershipJournal[1].EntryState = 'Created'
            [void](& $scriptBlockAssertCandidateOrdinaryDirectoryEnvelope `
                -LiteralPath $strDownloadDirectory)

            $arrRootEntries = [string[]]@(
                & $scriptBlockGetCandidateImmediateEntry `
                    -LiteralPath $strInvocationRoot `
                    -FailureCode 'context-create-verification' `
                    -FailurePhase 'context'
            )
            if ($arrRootEntries.Count -ne 1 -or
                -not (& $scriptBlockTestCandidateEntryPresent `
                    -EntryList $arrRootEntries `
                    -ExpectedPath $strDownloadDirectory)) {
                & $scriptBlockStopCandidateOperation -Code 'context-create-verification' `
                    -Message 'PSStyleGuide.Context.v1|phase=context|reason=unexpected-entry'
            }

            [void](& $scriptBlockAssertCandidateInMemoryContext -Context $objContext)
            return $objContext
        }

        & $scriptBlockStopCandidateOperation -Code 'context-create-collision-limit' `
            -Message 'PSStyleGuide.Context.v1|phase=context|reason=collision-limit'
    } catch {
        $strCreationCategory = & $scriptBlockGetCandidateDiagnosticCode `
            -ErrorRecord $_ `
            -Fallback 'context-create-failed'
        if ($boolRootCreated -and $null -ne $objContext) {
            $objCleanupResult = Remove-StyleGuideCandidateInvocationContext -Context $objContext
            $strRecordSequences = (@($objContext.OwnershipJournal | ForEach-Object {
                [string]$_.Sequence
            })) -join ','
            $strRootLeaf = [System.IO.Path]::GetFileName($objContext.InvocationRootPath)
            $strMessage = 'PSStyleGuide.ContextCreate.v1' +
                "|category=$strCreationCategory" +
                "|cleanup=$($objCleanupResult.DiagnosticCode)" +
                "|root-leaf=$strRootLeaf" +
                "|records=$strRecordSequences"
            throw (& $scriptBlockNewCandidateException `
                -Code 'context-create-composite-failure' `
                -Message $strMessage)
        }
        throw (& $scriptBlockNewCandidateException `
            -Code $strCreationCategory `
            -Message "PSStyleGuide.ContextCreate.v1|category=$strCreationCategory|cleanup=not-required")
    }
}

function Remove-StyleGuideCandidateInvocationContext {
    # .SYNOPSIS
    # Removes caller-owned entries from one validated invocation context.
    #
    # .DESCRIPTION
    # Proves the exact in-memory journal and live filesystem identity, removes
    # only journaled download and invocation entries without recursion, and
    # returns one bounded cleanup result. Uncertainty is retained fail-closed.
    # Validation and cleanup uncertainty are reported as Success false rather
    # than thrown to the caller.
    #
    # .PARAMETER Context
    # Specifies the raw PSStyleGuide.CandidateInvocationContext.v1 object to
    # validate and transition.
    #
    # .EXAMPLE
    # $objCleanupResult = Remove-StyleGuideCandidateInvocationContext `
    #     -Context $objContext
    #
    # # Returns one PSStyleGuide.CandidateCleanupResult.v1 object.
    #
    # .EXAMPLE
    # $objRepeatResult = Remove-StyleGuideCandidateInvocationContext `
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
    # Version: 1.0.20260802.11
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
        [void](& $scriptBlockAssertCandidateInMemoryContext -Context $Context)
        $guidInvocationId = $Context.InvocationId
        $strPreviousState = $Context.LifecycleState
    } catch {
        return (& $scriptBlockNewCandidateCleanupResult `
            -InvocationId $guidInvocationId `
            -PreviousState $strPreviousState `
            -FinalState $strPreviousState `
            -Success $false `
            -DiagnosticCode 'cleanup-context-invalid' `
            -ReferenceToFilesystemCallCount ([uint32]0) `
            -RetainedRecordSequences ([uint32[]]@()))
    }

    if ($Context.LifecycleState -eq 'Disposed') {
        return (& $scriptBlockNewCandidateCleanupResult `
            -InvocationId $Context.InvocationId `
            -PreviousState 'Disposed' `
            -FinalState 'Disposed' `
            -Success $true `
            -DiagnosticCode 'cleanup-already-disposed' `
            -ReferenceToFilesystemCallCount ([uint32]0) `
            -RetainedRecordSequences ([uint32[]]@()))
    }
    if ($Context.LifecycleState -eq 'CleanupFailed') {
        $arrRetained = & $scriptBlockGetCandidateRetainedSequence -Context $Context
        return (& $scriptBlockNewCandidateCleanupResult `
            -InvocationId $Context.InvocationId `
            -PreviousState 'CleanupFailed' `
            -FinalState 'CleanupFailed' `
            -Success $false `
            -DiagnosticCode 'cleanup-terminal-failure' `
            -ReferenceToFilesystemCallCount ([uint32]0) `
            -RetainedRecordSequences $arrRetained)
    }

    try {
        foreach ($objRecord in $Context.OwnershipJournal) {
            if ($objRecord.Kind -in @('CandidateDirectory', 'CandidateFile') -and
                $objRecord.EntryState -eq 'Created') {
                & $scriptBlockStopCandidateOperation -Code 'cleanup-candidate-owned' `
                    -Message 'PSStyleGuide.Context.v1|phase=cleanup|reason=candidate-owned'
            }
        }

        [void](& $scriptBlockAssertCandidateOrdinaryDirectoryEnvelope `
            -LiteralPath $Context.TrustedParentPath `
            -ReferenceToFilesystemCallCount ([ref]$uintFilesystemCallCount))
        [void](& $scriptBlockAssertCandidateOrdinaryDirectoryEnvelope `
            -LiteralPath $Context.InvocationRootPath `
            -ReferenceToFilesystemCallCount ([ref]$uintFilesystemCallCount))

        $arrRootEntries = [string[]]@(
            & $scriptBlockGetCandidateImmediateEntry `
                -LiteralPath $Context.InvocationRootPath `
                -ReferenceToFilesystemCallCount ([ref]$uintFilesystemCallCount)
        )
        $listExpectedRootEntries = New-Object 'System.Collections.Generic.List[string]'
        foreach ($objRecord in $Context.OwnershipJournal) {
            if ($objRecord.ParentPath -eq $Context.InvocationRootPath -and
                $objRecord.EntryState -eq 'Created') {
                $listExpectedRootEntries.Add($objRecord.Path)
            }
        }
        if ($arrRootEntries.Count -ne $listExpectedRootEntries.Count) {
            & $scriptBlockStopCandidateOperation -Code 'cleanup-owned-entry-uncertain' `
                -Message 'PSStyleGuide.Context.v1|phase=cleanup|reason=root-cardinality'
        }
        foreach ($strExpectedEntry in $listExpectedRootEntries) {
            if (-not (& $scriptBlockTestCandidateEntryPresent `
                -EntryList $arrRootEntries `
                -ExpectedPath $strExpectedEntry)) {
                & $scriptBlockStopCandidateOperation -Code 'cleanup-owned-entry-uncertain' `
                    -Message 'PSStyleGuide.Context.v1|phase=cleanup|reason=root-entry'
            }
        }

        $objDownloadDirectoryRecord = @($Context.OwnershipJournal | Where-Object {
            $_.Kind -eq 'DownloadDirectory'
        })[0]
        if ($objDownloadDirectoryRecord.EntryState -eq 'Created') {
            [void](& $scriptBlockAssertCandidateOrdinaryDirectoryEnvelope `
                -LiteralPath $Context.DownloadDirectoryPath `
                -ReferenceToFilesystemCallCount ([ref]$uintFilesystemCallCount))
            $arrDownloadEntries = [string[]]@(
                & $scriptBlockGetCandidateImmediateEntry `
                    -LiteralPath $Context.DownloadDirectoryPath `
                    -ReferenceToFilesystemCallCount ([ref]$uintFilesystemCallCount)
            )
            $arrDownloadRecords = @($Context.OwnershipJournal | Where-Object {
                $_.Kind -eq 'DownloadFile' -and $_.EntryState -eq 'Created'
            })
            if ($arrDownloadEntries.Count -ne $arrDownloadRecords.Count) {
                & $scriptBlockStopCandidateOperation -Code 'cleanup-owned-entry-uncertain' `
                    -Message 'PSStyleGuide.Context.v1|phase=cleanup|reason=download-cardinality'
            }
            foreach ($objRecord in $arrDownloadRecords) {
                if (-not (& $scriptBlockTestCandidateEntryPresent `
                    -EntryList $arrDownloadEntries `
                    -ExpectedPath $objRecord.Path)) {
                    & $scriptBlockStopCandidateOperation -Code 'cleanup-owned-entry-uncertain' `
                        -Message 'PSStyleGuide.Context.v1|phase=cleanup|reason=download-entry'
                }
                $hashtableEvidence = & $scriptBlockGetCandidateFileEvidence `
                    -LiteralPath $objRecord.Path `
                    -ReferenceToFilesystemCallCount ([ref]$uintFilesystemCallCount)
                if ($hashtableEvidence.Length -ne $objRecord.ContentLength -or
                    $hashtableEvidence.Sha256 -cne $objRecord.ContentSha256) {
                    & $scriptBlockStopCandidateOperation -Code 'cleanup-owned-entry-uncertain' `
                        -Message 'PSStyleGuide.Context.v1|phase=cleanup|reason=download-identity'
                }
            }
        }

        $arrFilesToDelete = @($Context.OwnershipJournal | Where-Object {
            $_.ExpectedEntryType -eq 'File' -and $_.EntryState -eq 'Created'
        } | Sort-Object -Property Sequence -Descending)
        foreach ($objRecord in $arrFilesToDelete) {
            $uintFilesystemCallCount = [uint32]($uintFilesystemCallCount + 1)
            [System.IO.File]::Delete($objRecord.Path)
            $arrParentEntries = [string[]]@(
                & $scriptBlockGetCandidateImmediateEntry `
                    -LiteralPath $objRecord.ParentPath `
                    -ReferenceToFilesystemCallCount ([ref]$uintFilesystemCallCount)
            )
            if (& $scriptBlockTestCandidateEntryPresent `
                -EntryList $arrParentEntries `
                -ExpectedPath $objRecord.Path) {
                & $scriptBlockStopCandidateOperation -Code 'cleanup-delete-failed' `
                    -Message 'PSStyleGuide.Context.v1|phase=cleanup|reason=file-present'
            }
            $objRecord.EntryState = 'Deleted'
        }

        $arrDirectoriesToDelete = @($Context.OwnershipJournal | Where-Object {
            $_.Kind -in @('DownloadDirectory', 'InvocationRootDirectory') -and
            $_.EntryState -eq 'Created'
        } | Sort-Object -Property Sequence -Descending)
        foreach ($objRecord in $arrDirectoriesToDelete) {
            $uintFilesystemCallCount = [uint32]($uintFilesystemCallCount + 1)
            [System.IO.Directory]::Delete($objRecord.Path, $false)
            $arrParentEntries = [string[]]@(
                & $scriptBlockGetCandidateImmediateEntry `
                    -LiteralPath $objRecord.ParentPath `
                    -ReferenceToFilesystemCallCount ([ref]$uintFilesystemCallCount)
            )
            if (& $scriptBlockTestCandidateEntryPresent `
                -EntryList $arrParentEntries `
                -ExpectedPath $objRecord.Path) {
                & $scriptBlockStopCandidateOperation -Code 'cleanup-delete-failed' `
                    -Message 'PSStyleGuide.Context.v1|phase=cleanup|reason=directory-present'
            }
            $objRecord.EntryState = 'Deleted'
        }

        $Context.LifecycleState = 'Disposed'
        [void](& $scriptBlockAssertCandidateInMemoryContext -Context $Context)
        return (& $scriptBlockNewCandidateCleanupResult `
            -InvocationId $Context.InvocationId `
            -PreviousState $strPreviousState `
            -FinalState 'Disposed' `
            -Success $true `
            -DiagnosticCode 'cleanup-succeeded' `
            -ReferenceToFilesystemCallCount $uintFilesystemCallCount `
            -RetainedRecordSequences ([uint32[]]@()))
    } catch {
        # Only entries this invocation actually created can be uncertain. An
        # ExpectedAbsent record names a path that was never created, so it stays
        # ExpectedAbsent; retyping it would contradict the record schema, which
        # binds every non-ExpectedAbsent candidate-directory record to the
        # destination phase, and would invalidate the terminal context.
        foreach ($objRecord in $Context.OwnershipJournal) {
            if ($objRecord.EntryState -eq 'Created') {
                $objRecord.EntryState = 'RetainedUncertain'
            }
        }
        $Context.LifecycleState = 'CleanupFailed'
        $arrRetained = & $scriptBlockGetCandidateRetainedSequence -Context $Context
        $strCode = & $scriptBlockGetCandidateDiagnosticCode `
            -ErrorRecord $_ `
            -Fallback 'cleanup-owned-entry-uncertain'
        return (& $scriptBlockNewCandidateCleanupResult `
            -InvocationId $Context.InvocationId `
            -PreviousState $strPreviousState `
            -FinalState 'CleanupFailed' `
            -Success $false `
            -DiagnosticCode $strCode `
            -ReferenceToFilesystemCallCount $uintFilesystemCallCount `
            -RetainedRecordSequences $arrRetained)
    }
}

# Bind both public functions to this file's private state. The functions are
# deliberately consumed after this script is dot-sourced and may be invoked
# from a different script scope; without a closure, PowerShell would resolve
# unqualified private variables against that caller's dynamic scope.
$scriptBlockNewContextFunction = ${function:New-StyleGuideCandidateInvocationContext}.GetNewClosure()
$scriptBlockRemoveContextFunction = ${function:Remove-StyleGuideCandidateInvocationContext}.GetNewClosure()
[void](Set-Item -LiteralPath Function:\New-StyleGuideCandidateInvocationContext `
    -Value $scriptBlockNewContextFunction -Force)
[void](Set-Item -LiteralPath Function:\Remove-StyleGuideCandidateInvocationContext `
    -Value $scriptBlockRemoveContextFunction -Force)
