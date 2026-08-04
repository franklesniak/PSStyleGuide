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
Version: 1.0.20260803.20
#>

[CmdletBinding(PositionalBinding = $false)]
[OutputType([void])]
param ()

$versionCandidateContext = [System.Version]'1.0.20260803.20'
$strCandidateContextTypeName = 'PSStyleGuide.CandidateInvocationContext.v1'
$strCandidateRecordTypeName = 'PSStyleGuide.CandidateOwnershipRecord.v1'
$strCandidateCleanupTypeName = 'PSStyleGuide.CandidateCleanupResult.v1'
# The same ceilings the expansion helper enforces. They are restated rather
# than imported because either script may be loaded without the other, and a
# journal this script accepts must be one that script would accept too.
# The manifest's fixed entry count, restated here for the same reason the byte
# ceilings above it are: either script may be loaded without the other, and a
# journal this script accepts must be one the expansion helper would accept too.
$intCandidateManifestEntryCount = 4
$uintCandidateMaximumEntryByte = [uint64](8 * 1024 * 1024)
$uintCandidateMaximumArchiveByte = [uint64](32 * 1024 * 1024)
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
# A leaf used as an enumeration search pattern must be a literal, and only two
# characters are not: '*' and '?' are the sole expanding forms in the
# two-argument overload -- the only one available on .NET Framework 4.8 -- which
# offers no escaping, so they are refused rather than quoted. The separators are
# refused because they would move the search off the directory being read.
#
# Everything else is matched literally, measured on both runtimes: ':', '\',
# '[', ']', '"', '<' and '>' each match their own file and nothing else. An
# earlier revision refused those too, on the theory that one character set for
# both platforms avoided divergence. It produced divergence instead: they are
# legal in a Unix filename, the download leaf is the one journaled name this
# code does not choose, and an ordinary artifact called 'release:linux.zip'
# therefore expanded successfully and then failed cleanup here, leaving the
# invocation root on disk. The rule is per-platform because what a platform can
# name is per-platform -- GetInvalidFileNameChars is the statement of that, and
# a leaf obtained from an enumeration cannot contain any of it.
#
# What a journaled path may contain is a stricter and separate question,
# answered once by the canonical stored-path check and applied where such a path
# is adopted. Answering it a second time here, in a differently shaped guard,
# is what went wrong.
$arrCandidateRejectedMatchCharacter = [char[]]@(
    [System.IO.Path]::GetInvalidFileNameChars() +
    [char[]]@(
        '*', '?',
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    )
)
$chrCandidateDirectorySeparator = [System.IO.Path]::DirectorySeparatorChar
$chrCandidateAlternateSeparator = [System.IO.Path]::AltDirectorySeparatorChar
# No read here counts higher than a journal-record count plus one, and the
# closed schema caps that well below this. The ceiling exists so that a bound
# cannot be satisfied in shape while being no bound at all.
$intCandidateMaximumEntryCeiling = 64
# The documented label ceiling, and the longest path either platform can name.
$intCandidateMaximumLabelLength = 128
$intCandidateMaximumPathLength = 32767
# The longest single path component either platform can name, which is what
# a journaled leaf and an enumeration search leaf both are.
$intCandidateMaximumLeafLength = 255
# Fixed buffer for bounded hashing, so the read never sizes itself from a file.
$intCandidateHashBuffer = 65536
$intCandidateCreationAttemptMaximum = 16
$arrCandidateStatPath = [string[]]@(
    '/usr/bin/stat',
    '/bin/stat',
    '/usr/local/bin/stat'
)
# Native commands are resolved from a fixed absolute list, never from PATH.
# Get-Command -CommandType Application closes command *precedence* -- an alias
# or function can no longer shadow the name -- but it still searches PATH, in
# PATH order, and PATH is not a trusted input here. On a GitHub-hosted runner
# any earlier step, composite action, or third-party action makes itself first
# in PATH by appending one line to $env:GITHUB_PATH, which is a documented
# platform feature rather than a compromise: "Prepends a directory to the
# system PATH variable and automatically makes it available to all subsequent
# actions in the current job." So a benign action shipping its own bin
# directory becomes this check's source of truth without anyone intending it.
#
# Resolving from a fixed list removes PATH from the decision. What it cannot
# remove is the trust in the resolved file itself: an attacker who can write
# /usr/bin/stat owns the runner, and nothing this script does would survive
# that. That residual is named rather than implied.
$scriptBlockResolveCandidateNativePath = {
    param (
        [Parameter(Mandatory = $true)]
        [string[]]$CandidatePath
    )

    foreach ($strCandidatePath in $CandidatePath) {
        try {
            $objCommandAttributes = [System.IO.File]::GetAttributes($strCandidatePath)
        } catch {
            continue
        }
        # A directory at the name is not a program to run.
        if (($objCommandAttributes -band [System.IO.FileAttributes]::Directory) -ne 0) {
            continue
        }
        return [string]$strCandidatePath
    }
    return ''
}

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
    # Length is decided before anything walks the value: ToCharArray copies the
    # whole string and the foreach boxes every character, so scanning first and
    # capping afterwards charged the run for a value the cap was always going to
    # refuse. Measured on .NET 8.0.10, a control-free oversized label of 64 MiB
    # cost 19,358 ms and 398.13 MiB against 0 ms and 0.03 MiB. The trusted-root
    # parameter carried no cap at all, so it was the worse half; its ceiling is
    # the longest path either platform can express -- Windows extended-length
    # paths stop at 32,767 characters, Linux PATH_MAX far below -- and therefore
    # refuses only values no filesystem could have named.
    $intMaximumLength = if ($IsLabel) {
        $intCandidateMaximumLabelLength
    } else {
        $intCandidateMaximumPathLength
    }
    if ($strValue.Length -gt $intMaximumLength) {
        & $scriptBlockStopCandidateOperation -Code 'parameter' `
            -Message "PSStyleGuide.Context.v1|phase=parameter|name=$ParameterName|reason=length"
    }
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
        $strStatPath = [string](& $scriptBlockResolveCandidateNativePath `
            -CandidatePath $arrCandidateStatPath)
        if ($strStatPath.Length -eq 0) {
            & $scriptBlockStopCandidateOperation -Code $strFailureCode `
                -Message "PSStyleGuide.Context.v1|phase=$strFailurePhase|reason=identity"
        }
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

        [int]$MaximumEntry,

        [string]$MatchPath,

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
    # A caller that only needs to know whether the entry count matches a fixed
    # expectation does not need every path. Materializing the whole listing to
    # answer "is this exactly one file?" makes a directory holding hundreds of
    # thousands of entries cost proportional managed memory before any archive
    # ceiling applies -- 200000 empty files measured 19.11 MiB against 0.16 MiB
    # for a bounded read, and no ceiling is in force at that point because no
    # archive has been opened. MaximumEntry stops the enumerator once that many
    # paths have been seen; a caller expecting N passes N + 1, so "exactly N"
    # and "more than N" stay distinguishable. Because the enumerator ends on
    # its own whenever fewer than MaximumEntry paths exist, a returned count
    # below the bound is still the complete listing, which is what the presence
    # checks downstream rely on. Callers proving a path ABSENT must not pass a
    # bound: absence cannot be concluded from a partial listing.
    #
    # That rule is true and was, on its own, read too far: it does not follow
    # that an absence proof must read EVERYTHING. Every absence proof here names
    # the one path it is disproving, and asking the filesystem about that one
    # name is what MatchPath does. The whole-parent read it replaces was work an
    # unrelated party could inflate simply by keeping files in the same shared
    # temporary directory -- 50000 unrelated entries measured 660 ms and
    # 15.87 MiB on .NET 8, 389 ms and 19.96 MiB on .NET 10, against 72 ms and
    # 0.05 MiB filtered, and the creation loop below retries up to 16 times.
    #
    # Filtering must not become a weaker test, so it is a filter and nothing
    # more: the caller's exact full-path comparison is unchanged, and a search
    # pattern that matches extra names can therefore only be rejected by it. The
    # dangerous direction is matching too FEW, which a literal pattern cannot do
    # -- so a leaf carrying a wildcard metacharacter is refused rather than
    # pattern-matched. Existence APIs are not an option in its place: File.Exists
    # and Directory.Exists disagree with each other on a dangling symbolic link
    # (measured True and False on .NET 8 and .NET 10) and both report absent on
    # Windows, where the link is followed. Enumeration names entries without
    # following them, which is why it was chosen and why it stays.
    #
    # MaximumEntry uses an in-band sentinel: omitted means unbounded, and the
    # parameter defaults to zero, so the `-le 0` branch below is what serves the
    # absence proofs. That makes an explicit `-MaximumEntry 0` read as a bound
    # while meaning the opposite, which is how a cardinality check can be
    # neutered without looking neutered. Omission stays unbounded; an explicitly
    # supplied non-positive bound is a contradiction and is refused here, above
    # the try, so it is not reported as an enumeration failure and no filesystem
    # call is counted for a call that never happened. A bounded filtered read is
    # the same contradiction wearing the other hat -- it would reduce a named
    # absence proof to a partial listing again -- so the two are refused
    # together.
    # Exactly one of the two, always. There used to be a third shape -- neither,
    # meaning read everything -- and no call site has needed it since every read
    # became bounded or filtered. Keeping it meant an unbounded path existed for
    # a caller to reach, and reaching it did not require editing any call site:
    # parking the expected call under `if ($false)` so the source-order table
    # still counted it, then performing the live read through a variable holding
    # this same script block, left the suite green at 115 records and zero
    # failures with the whole parent materialized. Source cannot settle that,
    # because the indirection is unbounded in form; the mode is removed instead.
    #
    # The ceiling refuses the other half of the same trick. A bound is only a
    # bound if it is small: the largest legitimate one here is a journal-record
    # count plus one, which the closed schema caps far below this, so a value
    # like 999999 is a bound in shape and not in effect.
    if (($PSBoundParameters.ContainsKey('MaximumEntry') -eq
            $PSBoundParameters.ContainsKey('MatchPath')) -or
        ($PSBoundParameters.ContainsKey('MaximumEntry') -and
            ($MaximumEntry -le 0 -or $MaximumEntry -gt $intCandidateMaximumEntryCeiling))) {
        & $scriptBlockStopCandidateOperation -Code $strFailureCode `
            -Message "PSStyleGuide.Context.v1|phase=$strFailurePhase|reason=enumeration-bound"
    }
    $strMatchLeaf = ''
    if ($PSBoundParameters.ContainsKey('MatchPath')) {
        $strMatchLeaf = [System.IO.Path]::GetFileName($MatchPath)
        if ($strMatchLeaf.Length -eq 0 -or
            $strMatchLeaf.Length -gt $intCandidateMaximumLeafLength -or
            $strMatchLeaf -ceq '.' -or
            $strMatchLeaf -ceq '..' -or
            $strMatchLeaf.IndexOfAny($arrCandidateRejectedMatchCharacter) -ge 0) {
            & $scriptBlockStopCandidateOperation -Code $strFailureCode `
                -Message "PSStyleGuide.Context.v1|phase=$strFailurePhase|reason=enumeration-filter"
        }
    }

    try {
        if ($null -ne $ReferenceToFilesystemCallCount) {
            $ReferenceToFilesystemCallCount.Value = [uint32]($ReferenceToFilesystemCallCount.Value + 1)
        }
        if ($strMatchLeaf.Length -ne 0) {
            return [string[]]@([System.IO.Directory]::EnumerateFileSystemEntries(
                $LiteralPath, $strMatchLeaf))
        }
        $listEntry = New-Object 'System.Collections.Generic.List[string]'
        $objEnumerator = [System.IO.Directory]::EnumerateFileSystemEntries(
            $LiteralPath).GetEnumerator()
        try {
            while ($listEntry.Count -lt $MaximumEntry -and $objEnumerator.MoveNext()) {
                $listEntry.Add([string]$objEnumerator.Current)
            }
        } finally {
            $objEnumerator.Dispose()
        }
        return [string[]]@($listEntry.ToArray())
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

    # Length first, because everything below is proportional to it and the
    # verdict is not. Round 23 capped the raw entry-point parameters and left
    # this validator uncapped, though it governs strings that are just as
    # untrusted: the four paths a caller-supplied context carries, and every
    # journaled path inside it. Measured on .NET 8.0.10, one 32 MiB path took
    # 7,940 ms and 135.11 MiB here -- and was ACCEPTED, so the cost bought the
    # caller a valid verdict rather than a refusal. A forged context carries
    # four of those plus a journal.
    #
    # The ceiling is the same one the parameter rule uses: the longest path
    # either platform can express, so it refuses only what no filesystem could
    # have named.
    if ($Value.Length -gt $intCandidateMaximumPathLength) {
        throw 'cleanup-context-invalid'
    }

    # This rule governs a path that is STORED, and a stored path is consumed
    # only by literal .NET APIs -- File.Delete, Directory.Delete, GetAttributes,
    # and ordinal comparison -- plus one enumeration search pattern. It used to
    # ask WildcardPattern.ContainsWildcardCharacters, which answers a different
    # question: that method reports '*', '?', '[' and ']', because those are
    # PowerShell wildcard syntax, and nothing downstream of a journaled path
    # parses PowerShell wildcards. Only the parameter rule does, and it calls
    # that method itself, before provider path resolution, where it belongs.
    #
    # The consequence of asking the wrong question was refusing 'build[1].zip',
    # an ordinary artifact name that both platforms can produce and that every
    # downstream operation would have handled literally. What must still be
    # refused is '*' and '?', and for a reason specific to this code rather than
    # to PowerShell: every journaled leaf is used as a literal search pattern
    # when cleanup proves that entry gone, and those two are the only characters
    # that expand there. Refusing them at the point a name is adopted is what
    # keeps a name that cannot be cleaned up from ever being recorded.
    if ($Value.Length -eq 0 -or
        $Value.IndexOfAny([char[]]@('*', '?')) -ge 0 -or
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

    # The label is scanned character by character, so its length is decided
    # first for the same reason the paths above are.
    if ($Context.DiagnosticLabel.Length -gt $intCandidateMaximumLabelLength) {
        throw 'cleanup-context-invalid'
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

    # The cardinality rules below reject a journal that carries more than one
    # root, download directory, candidate directory, or download file -- but
    # they run after every record has been schema-checked, canonicalized, and
    # added to the path set. A schema-shaped context is untrusted input, so a
    # forged journal buys the whole loop before the count that refuses it:
    # measured on .NET 8, 20000 records cost 4960 ms and 48.54 MiB, and 200000
    # cost 60929 ms and 365.03 MiB, for a journal this schema caps at eight.
    #
    # The cap is derived rather than written down. One invocation root, one
    # download directory, one candidate directory, one download file, and one
    # candidate file per manifest name -- so growing the manifest moves it and
    # transcribing it cannot go stale. A literal count in this file has already
    # accepted a deletion once.
    $intMaximumJournalRecord = 4 + $intCandidateManifestEntryCount
    if ($Context.OwnershipJournal.Count -gt $intMaximumJournalRecord) {
        throw 'cleanup-context-invalid'
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
            $objRecord.LeafName.Length -gt $intCandidateMaximumLeafLength -or
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
            # A record's ContentLength is caller-supplied and, until here,
            # unbounded: a forged journal could claim any 64-bit size. Cleanup
            # trusts that number to decide how much evidence to gather, so an
            # uncapped value is an instruction to read an arbitrarily large
            # file. The ceilings that already govern this manifest are the
            # right bound -- a download record can be as large as the archive
            # ceiling, a candidate file as large as one entry -- and nothing
            # legitimate reaches either.
            $uintRecordLengthCeiling = if ($objRecord.Kind -ceq 'DownloadFile') {
                $uintCandidateMaximumArchiveByte
            } else {
                $uintCandidateMaximumEntryByte
            }
            if ($objRecord.ExpectedEntryType -cne 'File' -or
                $objRecord.EntryState -eq 'ExpectedAbsent' -or
                $null -eq $objRecord.ContentLength -or
                $objRecord.ContentLength.GetType() -ne [System.UInt64] -or
                $objRecord.ContentLength -gt $uintRecordLengthCeiling -or
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

# Every path this script opens for reading must first be proven an ordinary
# regular file, and this is the single place that decides it.
#
# The attribute test alone does not: measured on .NET 8.0.10 and .NET 10.0.10, a
# FIFO created with mkfifo reports GetAttributes = Normal (128), carrying
# neither Directory nor ReparsePoint, and the FileStream constructor then blocks
# until a writer appears. An untrusted caller who hands back a schema-valid
# context naming one hangs cleanup indefinitely, before any length or digest is
# ever consulted.
#
# Length cannot decide it: measured, both runtimes, a FIFO and a legitimate
# empty file both report Length 0 without blocking. A journaled file may
# legitimately be empty, so refusing zero here would reject valid input -- the
# round-19 defect, which left the invocation root on disk when it shipped.
# GetUnixFileMode does not decide it either: it returns permissions only,
# identical for both, and does not exist on 5.1.
#
# So the file TYPE is asked for directly, from the same stat this script already
# resolves. Windows needs no equivalent: named pipes live in the \\.\pipe\
# namespace rather than the filesystem, so a journaled path under the invocation
# root cannot name one, and the attribute test carries that platform.
$scriptBlockAssertCandidateOrdinaryRegularFile = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath
    )

    $objAttributes = [System.IO.File]::GetAttributes($LiteralPath)
    if (($objAttributes -band [System.IO.FileAttributes]::Directory) -ne 0 -or
        ($objAttributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        throw 'nonordinary'
    }
    if ($boolCandidateIsWindows) {
        return
    }
    $strStatPath = [string](& $scriptBlockResolveCandidateNativePath `
        -CandidatePath $arrCandidateStatPath)
    if ($strStatPath.Length -eq 0) {
        throw 'nonordinary'
    }
    # %f is the raw mode in hex and %F is the file type as PROSE. GNU coreutils
    # translates its messages, so on a runner whose LC_MESSAGES selects an
    # installed translation %F stops equalling any English literal and every
    # valid cleanup is refused as uncertain. That is a false rejection of
    # legitimate input, which is the defect this code has shipped twice before.
    # The numeric form carries no message catalogue at all.
    #
    # Masking with S_IFMT also states the question better than a literal list
    # did: one test covers a regular file whether or not it is empty, where the
    # prose needed both 'regular file' and 'regular empty file' spelled out.
    # Measured on this image -- regular 0x81a4, empty 0x81a4, fifo 0x11a4,
    # symbolic link 0xa1ff, so 0x8000 after masking is exactly the regular case.
    $arrFileMode = @(& $strStatPath '-c' '%f' '--' $LiteralPath 2>$null)
    if ($LASTEXITCODE -ne 0 -or $arrFileMode.Count -ne 1 -or
        [string]$arrFileMode[0] -notmatch '^[0-9A-Fa-f]{1,8}$') {
        throw 'nonordinary'
    }
    if (([System.Convert]::ToInt32([string]$arrFileMode[0], 16) -band 0xF000) -ne 0x8000) {
        throw 'nonordinary'
    }
}

$scriptBlockGetCandidateFileEvidence = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [uint64]$ExpectedLength,

        [Parameter(Mandatory = $true)]
        [ref]$ReferenceToFilesystemCallCount
    )

    try {
        $ReferenceToFilesystemCallCount.Value = [uint32]($ReferenceToFilesystemCallCount.Value + 1)
        & $scriptBlockAssertCandidateOrdinaryRegularFile -LiteralPath $LiteralPath
        $ReferenceToFilesystemCallCount.Value = [uint32]($ReferenceToFilesystemCallCount.Value + 1)
        $objStream = New-Object System.IO.FileStream(
            $LiteralPath,
            [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::Read,
            [System.IO.FileShare]::Read
        )
        try {
            # The proof above is about a NAME; this is about the object that was
            # actually opened. A regular file is seekable and a pipe, socket or
            # device is not, so this refuses a non-regular object explicitly
            # rather than leaving it to be noticed when Length happens to throw.
            # An incidental stop is not a stop -- that lesson is already written
            # into the archive trailer guard, and it applies here too.
            #
            # What this does NOT do is close the window between the proof and
            # the open. A name proven regular can be replaced before the open
            # runs, and if the replacement is a FIFO the open blocks before any
            # check reaches it. Closing that needs a non-blocking or no-follow
            # open, which portable .NET does not expose: FileOptions offers
            # WriteThrough, Asynchronous, RandomAccess, DeleteOnClose,
            # SequentialScan and Encrypted, and none of them is O_NONBLOCK.
            # Opening read-write does avoid the block -- measured, a FIFO opens
            # in 5 ms that way -- but it refuses a legitimate read-only artifact:
            # measured as an unprivileged user, a 0444 regular file opened
            # read-write threw while the same file opened read-only succeeded.
            # Trading a hang for a false rejection is the round-19 defect, so it
            # was not taken.
            #
            # The window needs a writer inside the invocation root, which is
            # created 0755 and owned by this process inside a sticky parent, so
            # a different unprivileged user cannot create, delete or replace
            # anything in it. That leaves the same user or root -- the competing
            # untrusted writer #146 lists as a non-goal, and the same actor the
            # extraction race is documented against.
            if (-not $objStream.CanRead -or -not $objStream.CanSeek) {
                throw 'nonordinary'
            }
            $uintLength = [uint64]$objStream.Length
            # The caller compares this length against the journal before it
            # looks at the digest, so a file whose length already disagrees is
            # refused whatever the hash says -- and hashing it first means
            # reading every byte of a file the journal has already failed to
            # describe. A forged record naming a very large file made that read
            # unbounded. The length is decided here instead, and the digest is
            # computed only for a file the journal still might match. The empty
            # string returned in the other case can never equal a 64-character
            # digest, so a caller that skipped the length comparison entirely
            # would still fail closed.
            if ($uintLength -ne $ExpectedLength) {
                return [ordered]@{
                    Length = $uintLength
                    Sha256 = ''
                }
            }
            # Exactly the validated number of bytes, and not one more.
            # ComputeHash reads a stream to EOF, and EOF is not where the
            # journal said the file ended -- it is wherever the file happens to
            # end when the read gets there. Measured: a file validated at 1,024
            # bytes, appended to by another writer, had ComputeHash consume
            # 201,327,616 bytes. Worse than the volume, a writer that keeps
            # ahead of the reader moves EOF for as long as it likes, so the read
            # need never finish at all.
            #
            # Hashing the validated prefix is also the more correct answer: the
            # journal describes that many bytes, so that is what the digest
            # should attest. This is the same defect the archive allocation had
            # a round earlier, in a second place, which is what comes of fixing
            # one instance of a class without sweeping for its siblings. The
            # bounded loop below is the idiom this file already uses in three
            # other places.
            $objSha256 = [System.Security.Cryptography.SHA256]::Create()
            try {
                $arrHashBuffer = New-Object byte[] $intCandidateHashBuffer
                $uintHashRemaining = $uintLength
                while ($uintHashRemaining -gt 0) {
                    $intHashWanted = if ($uintHashRemaining -lt [uint64]$arrHashBuffer.Length) {
                        [int]$uintHashRemaining
                    } else {
                        $arrHashBuffer.Length
                    }
                    $intHashRead = $objStream.Read($arrHashBuffer, 0, $intHashWanted)
                    if ($intHashRead -le 0) {
                        throw 'truncated'
                    }
                    [void]$objSha256.TransformBlock($arrHashBuffer, 0, $intHashRead, $null, 0)
                    $uintHashRemaining -= [uint64]$intHashRead
                }
                [void]$objSha256.TransformFinalBlock((New-Object byte[] 0), 0, 0)
                # One byte past the validated end. A file that still has more to
                # give is no longer the file the journal describes, and the
                # empty digest is the shape the caller already treats as a
                # mismatch, so no new failure path is needed.
                if ($objStream.Read($arrHashBuffer, 0, 1) -gt 0) {
                    return [ordered]@{
                        Length = $uintLength
                        Sha256 = ''
                    }
                }
                $strHash = ([System.BitConverter]::ToString(
                    $objSha256.Hash
                ) -replace '-', '').ToLowerInvariant()
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
    # Version: 1.0.20260803.20
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
                    -LiteralPath $strTrustedParent `
                    -MatchPath $strInvocationRoot
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

            # Private at creation on Unix, not private a moment afterwards.
            # The default is 0755 under the usual 022 umask -- measured -- which
            # lets any local user traverse the root once its unpredictable name
            # is known and read the downloaded archive and the extracted files.
            # Everything below inherits the protection: POSIX traversal needs
            # execute on every component, so a 0700 root makes the download and
            # candidate directories unreachable whatever their own modes are.
            #
            # The mode goes to the creating call rather than a chmod afterwards,
            # because create-then-protect is a window, and this project has
            # already had to close one of those. 448 is 0700 -- UserRead,
            # UserWrite and UserExecute -- written numerically so the enum type
            # is not referenced on a runtime that lacks it.
            #
            # Windows keeps the single-argument form: it has no Unix mode, and
            # the inherited ACL is what the envelope check already reasons
            # about. PowerShell 7 releases older than the UnixFileMode overload
            # fall back to the same form and are no worse than before.
            # The overload is attempted rather than predicted. An earlier
            # revision tested whether the UnixFileMode TYPE resolved and treated
            # that as proof the two-argument CreateDirectory existed, which is a
            # proxy for the thing actually invoked rather than the thing itself:
            # a runtime carrying the enum without the overload would take the
            # branch and throw a binding error instead of the fallback this code
            # documents. Only a missing overload is caught -- a real creation
            # failure, such as a permission error, still propagates.
            $typeCandidateUnixFileMode = 'System.IO.UnixFileMode' -as [type]
            $boolCandidateRootPrivate = $false
            if (-not $boolCandidateIsWindows -and $null -ne $typeCandidateUnixFileMode) {
                try {
                    $null = [System.IO.Directory]::CreateDirectory(
                        $strInvocationRoot,
                        [System.Enum]::ToObject($typeCandidateUnixFileMode, 448)
                    )
                    $boolCandidateRootPrivate = $true
                } catch [System.Management.Automation.MethodException] {
                    $boolCandidateRootPrivate = $false
                }
            }
            if (-not $boolCandidateRootPrivate) {
                $null = [System.IO.Directory]::CreateDirectory($strInvocationRoot)
            }
            # Ownership is claimed here, on the call that may have created the
            # directory, and not after the checks below have approved of it.
            # CreateDirectory cannot say whether it made the directory or found
            # one, so from this line on the only safe assumption is that this
            # invocation made it -- and everything that follows must be able to
            # report the directory rather than walk away from it. Marking
            # ownership after the checks meant a directory this invocation had
            # just created, which something else then wrote into, was abandoned
            # by the retry below with no record anywhere that it existed:
            # neither the caller nor cleanup could name it, let alone remove it.
            $boolRootCreated = $true
            $objContext.OwnershipJournal[0].EntryState = 'Created'

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
            # deleting this tree.
            #
            # Refusing a directory that already holds anything is what can be
            # done about that here, and it costs nothing: enumeration needs no
            # permission this code does not already use, and the path it
            # enumerates has just been proven ordinary and link-free. A
            # populated directory is by definition not this invocation's, so
            # the loop leaves it untouched and takes a different name; nothing
            # is deleted on that path, and nothing was created on it either.
            #
            # An exclusive marker file inside the directory was tried here and
            # removed. It proved nothing: an exclusive create on a fresh random
            # child name succeeds just as readily inside a directory someone
            # else made, so it never distinguished who created the root. It
            # also required creating a file directly in the invocation root,
            # which the surrounding design deliberately avoids -- files are
            # written only beneath the download and candidate directories, so a
            # Windows ACL granting create-folder and denying create-file there
            # is supported everywhere else and would have failed sixteen times
            # and then reported a collision limit.
            #
            # What remains unclosed is an empty directory placed at this exact
            # name in the window between the parent enumeration and the create.
            # Closing it needs an atomic exclusive directory create, which
            # portable .NET does not offer; the leaf is unpredictable, and an
            # attacker who guessed it would have their empty directory adopted,
            # populated, and removed.
            #
            # A non-empty directory here is not a name collision to retry past.
            # The parent enumeration above already skipped every name that
            # existed, so this state can only arise from the race window, and in
            # that window there is no way to tell a directory this invocation
            # created and something else then populated from one that was
            # already there. Retrying assumed the second reading and leaked the
            # first. Failing here reports it instead: the root is journaled as
            # owned, so the creation failure path runs cleanup and names the
            # residual in its diagnostic rather than losing it.
            #
            # One observed path answers the question, so the read stops there.
            $arrClaimEntries = [string[]]@(
                & $scriptBlockGetCandidateImmediateEntry `
                    -LiteralPath $strInvocationRoot `
                    -FailureCode 'context-create-verification' `
                    -FailurePhase 'context' `
                    -MaximumEntry 1
            )
            if ($arrClaimEntries.Count -ne 0) {
                & $scriptBlockStopCandidateOperation -Code 'context-create-verification' `
                    -Message 'PSStyleGuide.Context.v1|phase=context|reason=unexpected-entry'
            }

            $null = [System.IO.Directory]::CreateDirectory($strDownloadDirectory)
            $objContext.OwnershipJournal[1].EntryState = 'Created'
            [void](& $scriptBlockAssertCandidateOrdinaryDirectoryEnvelope `
                -LiteralPath $strDownloadDirectory)

            # The root was proven empty a few lines ago and this name is under
            # it, so CreateDirectory should have made this directory. It cannot
            # say so, and an observer that had learned the root's name could
            # have placed an empty directory here first, which this call would
            # adopt and cleanup would later remove. Emptiness is the same
            # evidence used for the root and carries the same limit -- an empty
            # squatter is indistinguishable -- but anything already inside is
            # proof the directory is not this invocation's to use.
            $arrDownloadClaimEntries = [string[]]@(
                & $scriptBlockGetCandidateImmediateEntry `
                    -LiteralPath $strDownloadDirectory `
                    -FailureCode 'context-create-verification' `
                    -FailurePhase 'context' `
                    -MaximumEntry 1
            )
            if ($arrDownloadClaimEntries.Count -ne 0) {
                & $scriptBlockStopCandidateOperation -Code 'context-create-verification' `
                    -Message 'PSStyleGuide.Context.v1|phase=context|reason=unexpected-entry'
            }

            $arrRootEntries = [string[]]@(
                & $scriptBlockGetCandidateImmediateEntry `
                    -LiteralPath $strInvocationRoot `
                    -FailureCode 'context-create-verification' `
                    -FailurePhase 'context' `
                    -MaximumEntry 2
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
    # Version: 1.0.20260803.20
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

        # The expected set is derived from the journal alone, so it is known
        # before the directory is read and it bounds the read. Deriving it
        # afterwards made this the one cardinality check in either script that
        # materialized its directory first: a root polluted with unexpected
        # children cost 17.00 MiB of managed heap and 210 ms at 50,000 entries
        # to reach a verdict that only ever needed to see two. The verdict was
        # correct either way, which is exactly why nothing failed and the site
        # survived a sweep of this class.
        $listExpectedRootEntries = New-Object 'System.Collections.Generic.List[string]'
        foreach ($objRecord in $Context.OwnershipJournal) {
            if ($objRecord.ParentPath -eq $Context.InvocationRootPath -and
                $objRecord.EntryState -eq 'Created') {
                $listExpectedRootEntries.Add($objRecord.Path)
            }
        }
        $arrRootEntries = [string[]]@(
            & $scriptBlockGetCandidateImmediateEntry `
                -LiteralPath $Context.InvocationRootPath `
                -MaximumEntry ($listExpectedRootEntries.Count + 1) `
                -ReferenceToFilesystemCallCount ([ref]$uintFilesystemCallCount)
        )
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
            # As above, the journal supplies the expectation without touching
            # the filesystem, so it can bound the read that checks it.
            $arrDownloadRecords = @($Context.OwnershipJournal | Where-Object {
                $_.Kind -eq 'DownloadFile' -and $_.EntryState -eq 'Created'
            })
            $arrDownloadEntries = [string[]]@(
                & $scriptBlockGetCandidateImmediateEntry `
                    -LiteralPath $Context.DownloadDirectoryPath `
                    -MaximumEntry ($arrDownloadRecords.Count + 1) `
                    -ReferenceToFilesystemCallCount ([ref]$uintFilesystemCallCount)
            )
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
                    -ExpectedLength ([uint64]$objRecord.ContentLength) `
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
                    -MatchPath $objRecord.Path `
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
                    -MatchPath $objRecord.Path `
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
