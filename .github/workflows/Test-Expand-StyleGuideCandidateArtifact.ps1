#Requires -Version 5.1

<#
.SYNOPSIS
Runs the permanent adversarial style-guide candidate validation suite.

.DESCRIPTION
Authenticates the fixed helper and context-manager blobs against HEAD, the
stage-0 index, and the no-filter working object before loading them. It then
executes the versioned 115-case catalog and emits one bounded canonical JSONL
result per catalog row.

.PARAMETER HelperPath
Specifies the raw, fixed path claim for the candidate-expansion helper.

.PARAMETER ContextManagerPath
Specifies the raw, fixed path claim for the invocation-context manager.

.EXAMPLE
PS> .\Test-Expand-StyleGuideCandidateArtifact.ps1 `
    -HelperPath (Resolve-Path .github/workflows/Expand-StyleGuideCandidateArtifact.ps1).Path `
    -ContextManagerPath (Resolve-Path .github/workflows/Manage-StyleGuideCandidateInvocationContext.ps1).Path

Authenticates both scripts and executes the complete candidate-case catalog.

.INPUTS
None. You can't pipe objects to this script.

.OUTPUTS
[string] One canonical JSON object per catalog case, written to the success
stream. The process exit code reports the aggregate result.

.NOTES
Version: 1.0.20260808.2
#>

[CmdletBinding(PositionalBinding = $false)]
[OutputType([string])]
param (
    [Parameter(Mandatory = $true)]
    [AllowNull()]
    [AllowEmptyString()]
    [AllowEmptyCollection()]
    [object]$HelperPath,

    [Parameter(Mandatory = $true)]
    [AllowNull()]
    [AllowEmptyString()]
    [AllowEmptyCollection()]
    [object]$ContextManagerPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:versionCandidateHarness = [System.Version]'1.0.20260808.2'
$script:objCandidateHelperPathClaim = $HelperPath
$script:objCandidateContextManagerPathClaim = $ContextManagerPath
$script:strCandidateExpectedHelperVersion = '1.0.20260808.1'
$script:strCandidateExpectedContextVersion = '1.0.20260808.0'
$script:strCandidateCatalogVersion = '1.0.20260805.1'
# The documented ceiling on what an authenticated native query may return, the
# buffer each pipe is read into, and how long a killed child is given to let its
# outstanding read finish.
$script:intCandidateNativeOutputCeiling = 4194304
$script:intCandidateNativeReadBuffer = 65536
$script:intCandidateNativeDrainMilliseconds = 10000
# The physical allocation size, stated once. It was previously two bare literals
# inside the header check, which is why growing the catalog failed with an
# unhelpful 'header' detail rather than naming the count.
$script:intCandidateCaseCount = 115
$script:strCandidateAllocationSha256 = '1670cdfcfdd2c7c22ca21b4ace19f59cd7bdb104d2503d8791b8639a28918c0e'
$script:strCandidateHelperRelativePath = '.github/workflows/Expand-StyleGuideCandidateArtifact.ps1'
$script:strCandidateContextRelativePath = '.github/workflows/Manage-StyleGuideCandidateInvocationContext.ps1'
$script:strCandidateCatalogRelativePath = '.github/workflows/style-guide-candidate-cases.json'
# Declared expansion of the helper's parameter-prefixed subreason families. The
# helper builds these subreasons by interpolation, so the closed catalog can only
# stay closed if every declared parameter/suffix pair is present in it. An
# interpolated suffix that is absent from this table is itself a failure.
# Phases whose '<phase>-invalid' diagnostic the production code builds by
# interpolation. Every one must be declared in the catalog, so a new phase
# cannot silently widen the taxonomy.
$script:arrCandidateComputedDiagnosticPhase = [string[]]@(
    'archive', 'containment', 'destination', 'digest', 'download',
    'extraction', 'manifest', 'parameter', 'post-extraction', 'root'
)
$script:hashtableCandidateSubreasonFamily = [ordered]@{
    type = [string[]]@(
        'ArtifactId', 'CandidateDirectory', 'CheckoutRoot', 'DownloadDirectory',
        'ExpectedDigest', 'RunAttempt', 'RunId', 'TrustedTemporaryRoot'
    )
    empty = [string[]]@(
        'ArtifactId', 'CandidateDirectory', 'CheckoutRoot', 'DownloadDirectory',
        'ExpectedDigest', 'RunAttempt', 'RunId', 'TrustedTemporaryRoot'
    )
    control = [string[]]@(
        'ArtifactId', 'CandidateDirectory', 'CheckoutRoot', 'DownloadDirectory',
        'ExpectedDigest', 'RunAttempt', 'RunId', 'TrustedTemporaryRoot'
    )
    length = [string[]]@('ArtifactId', 'RunAttempt', 'RunId')
    wildcard = [string[]]@(
        'CandidateDirectory', 'CheckoutRoot', 'DownloadDirectory', 'TrustedTemporaryRoot'
    )
    provider = [string[]]@(
        'CandidateDirectory', 'CheckoutRoot', 'DownloadDirectory', 'TrustedTemporaryRoot'
    )
    relative = [string[]]@(
        'CandidateDirectory', 'CheckoutRoot', 'DownloadDirectory', 'TrustedTemporaryRoot'
    )
    normalization = [string[]]@(
        'CandidateDirectory', 'CheckoutRoot', 'DownloadDirectory', 'TrustedTemporaryRoot'
    )
    missing = [string[]]@(
        'CandidateDirectory', 'CheckoutRoot', 'Context', 'DownloadDirectory',
        'ExpectedDigest', 'TrustedTemporaryRoot'
    )
}
$script:arrCandidateExpectedName = [string[]]@(
    'copilot-instructions.md',
    'powershell.instructions.md',
    'STYLE_GUIDE_CHAT.md',
    'STYLE_GUIDE_FULL.md'
)
$script:strCandidateResultTypeName = 'PSStyleGuide.CandidateCaseResult.v1'
$script:strCandidateEmptySha256 = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
$script:intCandidateBufferSize = 65536
# The harness resolves its own native commands from fixed absolute locations
# for the same reason the production scripts do: Get-Command
# -CommandType Application closes command precedence but still searches PATH,
# and on a hosted runner any earlier step can put itself first in PATH with one
# line appended to $env:GITHUB_PATH. These two are test-side rather than
# security-critical -- git is the one that roots trust, and it is resolved
# separately at the identity check -- but a harness that resolves differently
# from the code it authenticates is a difference waiting to be discovered.
$script:scriptBlockResolveHarnessNativePath = {
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
        if (($objCommandAttributes -band [System.IO.FileAttributes]::Directory) -ne 0) {
            continue
        }
        return [string]$strCandidatePath
    }
    return ''
}
# The platform decides which comparison, path grammar, link primitive, and
# filesystem-identity rules apply, so it must not be something a caller can
# assert. The OS environment variable is ordinary and inheritable: exporting
# it as Windows_NT to PowerShell 7 on Linux makes every one of those branches
# take its Windows form, which silently disables mount and inode resolution
# and switches path comparison to case-insensitive. OSVersion.Platform is a
# runtime property with no environment input, and is available on both
# Windows PowerShell 5.1 and PowerShell 7.
$script:boolCandidateIsWindows = [System.Environment]::OSVersion.Platform -eq [System.PlatformID]::Win32NT
$script:objCandidatePathComparison = if ($script:boolCandidateIsWindows) {
    [System.StringComparison]::OrdinalIgnoreCase
} else {
    [System.StringComparison]::Ordinal
}

$script:scriptBlockNewHarnessException = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Code,

        [Parameter(Mandatory = $true)]
        [string]$Detail
    )

    $objException = New-Object System.InvalidOperationException(
        "PSStyleGuide.CandidateHarness.v1|code=$Code|detail=$Detail"
    )
    $objException.Data['PSStyleGuideHarnessCode'] = $Code
    return $objException
}

$script:scriptBlockStopHarness = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Code,

        [Parameter(Mandatory = $true)]
        [string]$Detail
    )

    throw (& $script:scriptBlockNewHarnessException -Code $Code -Detail $Detail)
}

# ZipFile lives in System.IO.Compression.FileSystem, which .NET Framework does
# not load by default, so Windows PowerShell 5.1 cannot resolve
# [System.IO.Compression.ZipFile] until that assembly is added. Loading both
# compression assemblies here, at script scope, rather than inside whichever
# helper happens to build a fixture first, is what keeps the ordering honest:
# an assertion that runs before any fixture is written still needs the types,
# and a load buried in one helper silently makes every earlier caller depend on
# that helper having run. .NET Core carries both types in assemblies that are
# always present, where Add-Type is either a no-op or fails harmlessly -- so
# each load is tolerated and the resolvable-type check below, not the loader,
# is what decides whether this runtime can proceed.
foreach ($strCandidateCompressionAssembly in @(
    'System.IO.Compression',
    'System.IO.Compression.FileSystem'
)) {
    try {
        Add-Type -AssemblyName $strCandidateCompressionAssembly -ErrorAction Stop
    } catch {
        # Tolerated only if the check below still finds both types.
        $null = $_
    }
}
foreach ($strCandidateCompressionType in @(
    'System.IO.Compression.ZipFile',
    'System.IO.Compression.ZipArchive',
    'System.IO.Compression.ZipArchiveMode'
)) {
    if ($null -eq ($strCandidateCompressionType -as [type])) {
        & $script:scriptBlockStopHarness `
            -Code 'orchestration-failed' `
            -Detail 'compression-type-unavailable'
    }
}

$script:scriptBlockAssertRawString = {
    param (
        [AllowNull()]
        [object]$Value,

        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    if ($null -eq $Value -or $Value.GetType() -ne [System.String]) {
        & $script:scriptBlockStopHarness -Code 'parameter' -Detail "$Name-type"
    }
    $strValue = [string]$Value
    if ($strValue.Length -eq 0 -or [System.String]::IsNullOrWhiteSpace($strValue)) {
        & $script:scriptBlockStopHarness -Code 'parameter' -Detail "$Name-empty"
    }
    foreach ($chrValue in $strValue.ToCharArray()) {
        if ([System.Char]::IsControl($chrValue)) {
            & $script:scriptBlockStopHarness -Code 'parameter' -Detail "$Name-control"
        }
    }
    return $strValue
}

$script:scriptBlockConvertToNativeArgumentString = {
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

$script:scriptBlockInvokeNativeRaw = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $true)]
        [string]$WorkingDirectory,

        [Parameter(Mandatory = $true)]
        [string[]]$ArgumentList
    )

    $objProcessStartInformation = New-Object System.Diagnostics.ProcessStartInfo
    $objProcessStartInformation.FileName = $FilePath
    $objProcessStartInformation.WorkingDirectory = $WorkingDirectory
    $objProcessStartInformation.UseShellExecute = $false
    $objProcessStartInformation.CreateNoWindow = $true
    $objProcessStartInformation.RedirectStandardInput = $true
    $objProcessStartInformation.RedirectStandardOutput = $true
    $objProcessStartInformation.RedirectStandardError = $true

    # Git is the only program this harness starts, so the child environment is
    # built as a Git environment. An inherited GIT_DIR, GIT_WORK_TREE,
    # GIT_INDEX_FILE, object/alternate-object, namespace, ceiling, or
    # GIT_CONFIG_ variable would let the caller choose which repository, index,
    # and object store answer the HEAD, index, and no-filter working-blob
    # queries. Those three answers are the whole trusted-script proof, and they
    # stop being independent evidence about this checkout the moment any of
    # them can be redirected, so no inherited GIT_ variable survives at all.
    # Git also exports GIT_DIR and GIT_INDEX_FILE to every hook it runs, so
    # this is reached without an attacker whenever the harness runs under a
    # pre-commit hook or `git rebase --exec`.
    $objChildEnvironment = $objProcessStartInformation.EnvironmentVariables
    $listInheritedGitName = New-Object System.Collections.Generic.List[string]
    foreach ($objName in $objChildEnvironment.Keys) {
        $strName = [string]$objName
        if ($strName.StartsWith('GIT_', [System.StringComparison]::OrdinalIgnoreCase)) {
            $listInheritedGitName.Add($strName)
        }
    }
    foreach ($strName in $listInheritedGitName) {
        [void]$objChildEnvironment.Remove($strName)
    }

    # Removing every GIT_ name also removes any isolation the caller had set.
    # GIT_CONFIG_GLOBAL pointing at an empty path is how a CI job hides
    # $HOME/.gitconfig, and dropping it lets a global core.hooksPath,
    # commit.gpgsign, alias, or core.pager reach the fixture commits. Config
    # state is therefore set rather than inherited: system config is disabled
    # outright, and global config points at a name that is never created. Git
    # reads a missing config file as empty. The name is unpredictable and
    # chosen per call so it cannot be planted in advance.
    $strAbsentGlobalConfigPath = [System.IO.Path]::Combine(
        [System.IO.Path]::GetTempPath(),
        'psstyleguide-absent-global-' + [System.IO.Path]::GetRandomFileName()
    )
    $objChildEnvironment['GIT_LITERAL_PATHSPECS'] = '1'
    $objChildEnvironment['GIT_OPTIONAL_LOCKS'] = '0'
    $objChildEnvironment['GIT_CONFIG_NOSYSTEM'] = '1'
    $objChildEnvironment['GIT_CONFIG_GLOBAL'] = $strAbsentGlobalConfigPath

    # .NET Framework lowercases these names and .NET on Linux does not, so the
    # readback is deliberately case-insensitive. Anything other than exactly
    # the four names set above means the removal did not take effect on this
    # runtime, which fails closed rather than running Git with an unproved
    # environment.
    $arrRequiredGitName = @(
        'GIT_LITERAL_PATHSPECS',
        'GIT_OPTIONAL_LOCKS',
        'GIT_CONFIG_NOSYSTEM',
        'GIT_CONFIG_GLOBAL'
    )
    $intChildGitNameCount = 0
    foreach ($objName in $objChildEnvironment.Keys) {
        $strName = [string]$objName
        if (-not $strName.StartsWith('GIT_', [System.StringComparison]::OrdinalIgnoreCase)) {
            continue
        }
        if ($arrRequiredGitName -inotcontains $strName) {
            & $script:scriptBlockStopHarness -Code 'script-identity-invalid' `
                -Detail 'native-environment'
        }
        $intChildGitNameCount++
    }
    if ($intChildGitNameCount -ne $arrRequiredGitName.Count) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' `
            -Detail 'native-environment'
    }

    # Replace refs live in the repository rather than the environment, so
    # scrubbing cannot reach them; --no-replace-objects keeps a replaced blob
    # out of the HEAD answer. --no-pager costs nothing and keeps the contract
    # true even if a caller ever stops redirecting output. safe.directory is
    # granted for exactly the directory this call already targets, because
    # disabling global config also drops any ownership grant recorded there;
    # command-line config is protected configuration, so Git honors it.
    $arrEffectiveArgument = @(
        '--no-pager',
        '--no-replace-objects',
        '-c',
        ('safe.directory=' + $WorkingDirectory)
    ) + $ArgumentList
    if ($null -ne $objProcessStartInformation.PSObject.Properties['ArgumentList']) {
        foreach ($strArgument in $arrEffectiveArgument) {
            [void]$objProcessStartInformation.ArgumentList.Add([string]$strArgument)
        }
    } else {
        $objProcessStartInformation.Arguments = (
            & $script:scriptBlockConvertToNativeArgumentString `
                -ArgumentList ([string[]]$arrEffectiveArgument)
        )
    }

    $objProcess = New-Object System.Diagnostics.Process
    $objProcess.StartInfo = $objProcessStartInformation
    $objStandardOutputStream = New-Object System.IO.MemoryStream
    $objStandardErrorStream = New-Object System.IO.MemoryStream
    try {
        if (-not $objProcess.Start()) {
            & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'native-start'
        }
        $objProcess.StandardInput.Close()
        # Both pipes are drained concurrently, because draining one to completion
        # while the other fills its buffer deadlocks the child. The ceiling is
        # therefore enforced from here, while the copies run, rather than after
        # they finish: CopyToAsync has no size limit, so consulting the length
        # afterwards meant the whole output was already in memory and ToArray was
        # about to double it. Measured, a child emitting 64 MiB against this
        # 4 MiB ceiling: 96.74 MiB of managed growth before the refusal.
        #
        # Two tidier-looking designs were tried first and both are wrong, which
        # is why this one polls. A MemoryStream built over a fixed byte[] does
        # bound the sink -- but its Length is the BUFFER size from the moment it
        # is constructed, not the number of bytes written, so a length test
        # against it fires immediately on legitimate output. And letting the copy
        # fault on overflow deadlocks: WaitAll still waits on the sibling task,
        # which cannot complete until the child exits, which it cannot do while
        # blocked writing into a pipe nobody is draining. So the child is killed
        # explicitly, which closes both pipes and lets both tasks finish.
        #
        # An earlier revision polled the two sinks on an interval and killed the
        # child once one had already exceeded the ceiling. That bounded the
        # growth but did not bound it HARD: whatever arrives between two polls
        # is retained, so the ceiling was a target rather than a limit, and the
        # length read raced a pool thread besides. Measured at a 10 ms interval,
        # a 1 GiB child still retained 6.56 MiB against a 4 MiB ceiling.
        #
        # This reads both pipes itself, one buffer at a time, and refuses the
        # chunk that would cross the ceiling rather than absorbing it first.
        # Nothing above the limit is ever written, so the limit is exact. Both
        # reads stay in flight together because draining one to completion while
        # the other fills its buffer deadlocks the child -- that is the failure
        # the copy-fault design hit, where WaitAll waited on a sibling task that
        # could not finish until a blocked child exited.
        #
        # Measured, children emitting 2 MiB, 64 MiB and 1 GiB, and separately
        # flooding stderr rather than stdout: legitimate output collected
        # unchanged, and every oversized case refused with exactly 4.00 MiB
        # retained on whichever pipe flooded, about 7 MiB of managed growth, and
        # no deadlock in any of them.
        $arrReadBuffer = @(
            (New-Object byte[] $script:intCandidateNativeReadBuffer),
            (New-Object byte[] $script:intCandidateNativeReadBuffer)
        )
        $arrReadStream = @(
            $objProcess.StandardOutput.BaseStream,
            $objProcess.StandardError.BaseStream
        )
        $arrReadSink = @($objStandardOutputStream, $objStandardErrorStream)
        $arrReadTask = @(
            $arrReadStream[0].ReadAsync($arrReadBuffer[0], 0, $arrReadBuffer[0].Length),
            $arrReadStream[1].ReadAsync($arrReadBuffer[1], 0, $arrReadBuffer[1].Length)
        )
        $boolReadExceeded = $false
        while (-not $boolReadExceeded -and
            ($null -ne $arrReadTask[0] -or $null -ne $arrReadTask[1])) {
            $arrPending = @($arrReadTask | Where-Object { $null -ne $_ })
            [void][System.Threading.Tasks.Task]::WaitAny($arrPending)
            for ($intPipe = 0; $intPipe -lt 2; $intPipe++) {
                if ($null -eq $arrReadTask[$intPipe] -or
                    -not $arrReadTask[$intPipe].IsCompleted) {
                    continue
                }
                $intRead = [int]$arrReadTask[$intPipe].Result
                if ($intRead -le 0) {
                    $arrReadTask[$intPipe] = $null
                    continue
                }
                if (($arrReadSink[$intPipe].Length + $intRead) -gt
                    $script:intCandidateNativeOutputCeiling) {
                    $boolReadExceeded = $true
                    break
                }
                $arrReadSink[$intPipe].Write($arrReadBuffer[$intPipe], 0, $intRead)
                $arrReadTask[$intPipe] = $arrReadStream[$intPipe].ReadAsync(
                    $arrReadBuffer[$intPipe], 0, $arrReadBuffer[$intPipe].Length)
            }
        }
        if ($boolReadExceeded) {
            # Killing closes both pipes, which is what lets the outstanding read
            # finish instead of waiting on a child that cannot proceed.
            try {
                $objProcess.Kill()
            } catch {
                $null = $_
            }
            try {
                [void][System.Threading.Tasks.Task]::WaitAll(
                    @($arrReadTask | Where-Object { $null -ne $_ }),
                    $script:intCandidateNativeDrainMilliseconds)
            } catch {
                $null = $_
            }
            & $script:scriptBlockStopHarness -Code 'script-identity-invalid' `
                -Detail 'native-output-limit'
        }
        $objProcess.WaitForExit()
        # Retained as a backstop rather than replaced. If the loop above ever
        # fails to observe a breach, the original refusal still fires here.
        if ($objStandardOutputStream.Length -gt $script:intCandidateNativeOutputCeiling -or
            $objStandardErrorStream.Length -gt $script:intCandidateNativeOutputCeiling) {
            & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'native-output-limit'
        }
        return [ordered]@{
            ExitCode = [int]$objProcess.ExitCode
            StandardOutput = [byte[]]$objStandardOutputStream.ToArray()
            StandardErrorLength = [uint32]$objStandardErrorStream.Length
        }
    } finally {
        $objStandardOutputStream.Dispose()
        $objStandardErrorStream.Dispose()
        $objProcess.Dispose()
    }
}

$script:scriptBlockConvertFromStrictUtf8 = {
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [byte[]]$Bytes
    )

    if ($Bytes.Length -ge 3 -and
        $Bytes[0] -eq 0xEF -and $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'bom'
    }
    if ($Bytes -contains [byte]0x0D) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'cr'
    }
    try {
        return (New-Object System.Text.UTF8Encoding($false, $true)).GetString($Bytes)
    } catch {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'utf8'
    }
}

$script:scriptBlockAssertVersionMarkersConsistent = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedVersion,

        [Parameter(Mandatory = $true)]
        [uint32]$ExpectedFunctionCount,

        [Parameter(Mandatory = $true)]
        [string]$OwnVersionVariableName,

        [Parameter(Mandatory = $true)]
        [hashtable]$VersionConstantMap
    )

    # Each production script states its version in three places: the help
    # block's Version line, the constant the code compares against, and a
    # comment inside every public function. Nothing keeps them equal but the
    # hand that edits them, and in this review loop that hand has missed one
    # three separate times -- each caught downstream as a puzzling symptom
    # rather than as what it was.
    #
    # A file may also carry one version that is not its own: the helper pins
    # the context manager's version so it can refuse a mismatched pair. That
    # pinned constant is a different thing from a marker and has to be told
    # apart from one. Every earlier revision told them apart by value, which
    # worked only for as long as the two scripts happened to carry different
    # versions -- and they are both first publications of the same date, so
    # the style guide's own versioning rule makes them the same string. The
    # moment they were made equal, this assertion failed the compliant file
    # and passed the non-compliant one. Value never identified the pinned
    # constant; it only correlated with it, and the correlation was an
    # accident of the versions being wrong.
    #
    # The pinned constant is now found by the name it is assigned to, which is
    # what actually distinguishes it, and every remaining literal in the file
    # must be a marker carrying this file's own version.
    $objMarkerTokens = $null
    $objMarkerErrors = $null
    $objMarkerAst = [System.Management.Automation.Language.Parser]::ParseFile(
        $LiteralPath, [ref]$objMarkerTokens, [ref]$objMarkerErrors)
    if ($null -eq $objMarkerAst -or @($objMarkerErrors).Count -ne 0) {
        & $script:scriptBlockStopHarness `
            -Code 'script-identity-invalid' -Detail 'version-marker-parse'
    }

    $arrVersionConvert = @($objMarkerAst.FindAll(
            {
                param ($SyntaxNode)
                $SyntaxNode -is [System.Management.Automation.Language.ConvertExpressionAst] -and
                $SyntaxNode.Type.TypeName.FullName -match '^(System\.)?Version$'
            },
            $true
        ))
    $arrOwnConstant = @()
    $arrForeignConstant = @()
    $hashtableConstantSeen = @{}
    foreach ($objConvert in $arrVersionConvert) {
        # The conversion sits under a command expression under the assignment,
        # so the assignment is reached by a bounded walk rather than by one
        # .Parent hop. The bound keeps an unrelated enclosing assignment from
        # being mistaken for this constant's own.
        $objAssignment = $null
        $objWalk = $objConvert.Parent
        $intWalk = 0
        while ($null -ne $objWalk -and $intWalk -lt 3) {
            if ($objWalk -is [System.Management.Automation.Language.AssignmentStatementAst]) {
                $objAssignment = $objWalk
                break
            }
            $objWalk = $objWalk.Parent
            $intWalk++
        }
        $strAssignedName = ''
        if ($null -ne $objAssignment -and
            $objAssignment.Left -is [System.Management.Automation.Language.VariableExpressionAst]) {
            $strAssignedName = [string]$objAssignment.Left.VariablePath.UserPath
        }
        # Round 50 named the file's own constant and left everything else as
        # "foreign", counted but not named. Round 51 reported what that admits:
        # move the pin off its literal -- assign the variable from another
        # version variable -- and leave any unrelated [System.Version] literal
        # in the file, and the unrelated one is counted as the pin and skipped
        # by extent, so the check passes while the constant it claims to have
        # identified is not the one the file uses. Measured: control PASS,
        # escape PASS. Naming one side of a partition and inferring the other
        # is not naming; it is the same defect one level in.
        #
        # So every conversion in the file must be assigned to a name this
        # caller declared, exactly once, carrying exactly the version that name
        # is required to carry. An unknown name, a duplicate, a missing one, or
        # a right name holding the wrong version all fail. This also settles a
        # second weakness the round-50 form carried: a foreign constant only
        # had to match *one of* the two pinned versions, so the helper could
        # pin its own version instead of the context manager's and pass.
        if (-not $VersionConstantMap.ContainsKey($strAssignedName)) {
            & $script:scriptBlockStopHarness -Code 'script-identity-invalid' `
                -Detail 'version-marker-constant-unknown'
        }
        if ($hashtableConstantSeen.ContainsKey($strAssignedName)) {
            & $script:scriptBlockStopHarness -Code 'script-identity-invalid' `
                -Detail 'version-marker-constant-duplicate'
        }
        $hashtableConstantSeen[$strAssignedName] = $true
        if ([string]$objConvert.Child.Extent.Text -cne
            ("'" + [string]$VersionConstantMap[$strAssignedName] + "'")) {
            & $script:scriptBlockStopHarness -Code 'script-identity-invalid' `
                -Detail 'version-marker-constant-value'
        }
        if ($strAssignedName -ceq $OwnVersionVariableName) {
            $arrOwnConstant += $objConvert
        } else {
            $arrForeignConstant += $objConvert
        }
    }
    if ($hashtableConstantSeen.Count -ne $VersionConstantMap.Count) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' `
            -Detail ('version-marker-constant-missing-' + $hashtableConstantSeen.Count)
    }
    # Auditing only the [System.Version] conversions leaves the variable open
    # to being written again by something that is not a conversion. Keep the
    # required literal assignment so the map above is satisfied, then add
    # `$script:versionCandidateHelper = $PSVersionTable.PSVersion` further
    # down, and every check here still passes while the constant the file
    # actually runs with carries a different version. Reported at round 52.
    #
    # The conversions are what this routine can read a version out of; they
    # are not what decides the variable's value. So the declared names must
    # be written exactly once each, by any spelling, and the one write is the
    # conversion already checked above.
    foreach ($strDeclaredName in $VersionConstantMap.Keys) {
        $arrAssignment = @($objMarkerAst.FindAll(
                {
                    param ($SyntaxNode)
                    $SyntaxNode -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                    $SyntaxNode.Left -is [System.Management.Automation.Language.VariableExpressionAst]
                },
                $true
            ) | Where-Object {
                ([string]$_.Left.VariablePath.UserPath) -ceq [string]$strDeclaredName
            })
        if (@($arrAssignment).Count -ne 1) {
            & $script:scriptBlockStopHarness -Code 'script-identity-invalid' `
                -Detail ('version-marker-constant-writes-' + @($arrAssignment).Count)
        }
    }
    if (@($arrOwnConstant).Count -ne 1) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' `
            -Detail ('version-marker-constant-' + @($arrOwnConstant).Count)
    }
    if ([string]$arrOwnConstant[0].Child.Extent.Text -cne ("'" + $ExpectedVersion + "'")) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' `
            -Detail 'version-marker-constant-value'
    }

    # The text the parser saw, so the offsets below index the same string the
    # extents were measured against.
    $strText = [string]$objMarkerAst.Extent.Text
    $arrMatch = @([System.Text.RegularExpressions.Regex]::Matches(
        $strText,
        '\b\d+\.\d+\.\d{8}\.\d+\b'
    ))
    $intExpectedMarker = 0
    foreach ($objMatch in $arrMatch) {
        # A pinned constant is skipped by position, never by value, so this
        # count stays correct when the pinned version and this file's own
        # version are the same string.
        $boolPinned = $false
        foreach ($objForeign in $arrForeignConstant) {
            if ($objMatch.Index -ge $objForeign.Extent.StartOffset -and
                ($objMatch.Index + $objMatch.Length) -le $objForeign.Extent.EndOffset) {
                $boolPinned = $true
                break
            }
        }
        if ($boolPinned) {
            continue
        }
        if ($objMatch.Value -cne $ExpectedVersion) {
            & $script:scriptBlockStopHarness `
                -Code 'script-identity-invalid' -Detail 'version-marker'
        }
        $intExpectedMarker++
    }
    # A deleted marker leaves the survivors agreeing with each other, so the
    # equality test above cannot see it; only a count can. That count is
    # derived rather than written down: the help block states the version once,
    # the constant states it once, and every public function repeats it, so a
    # file with two public functions carries four markers and a file with one
    # carries three. Writing a number here would be the same kind of defect
    # this assertion exists to catch, and was: the first revision hard-coded
    # three and silently accepted a deletion from the two-function file.
    $intRequiredMarker = 2 + [int]$ExpectedFunctionCount
    if ($intExpectedMarker -ne $intRequiredMarker) {
        & $script:scriptBlockStopHarness `
            -Code 'script-identity-invalid' -Detail 'version-marker'
    }

    # The count above treats every literal as interchangeable, and they are not.
    # Deleting a public function's marker and adding one matching literal to any
    # unrelated comment preserves the total exactly, so the assertion passes
    # while the contract it states -- one marker in the help block, one on the
    # constant, one inside every public function -- is broken. Measured: the
    # whole suite green with a function's marker gone.
    #
    # So each declared location is checked as a location. The literals are no
    # longer counted in the abstract; they are found where they are supposed to
    # be, and a literal anywhere else is a stray rather than a substitute. The
    # file is parsed once, above, because the pinned-constant extents are
    # needed before the count rather than after it.

    # One '# Version: <expected>' comment inside each public function, and none
    # anywhere else. Comments are tokens rather than syntax, so they are matched
    # against each function's extent by position.
    $arrMarkerComment = @(@($objMarkerTokens) | Where-Object {
            $_.Kind -eq [System.Management.Automation.Language.TokenKind]::Comment -and
            [string]$_.Text -cmatch ('^#\s*Version:\s*' +
                [System.Text.RegularExpressions.Regex]::Escape($ExpectedVersion) + '\s*$')
        })
    $arrPublicFunction = @($objMarkerAst.FindAll(
            {
                param ($SyntaxNode)
                $SyntaxNode -is [System.Management.Automation.Language.FunctionDefinitionAst]
            },
            $true
        ))
    if ($arrPublicFunction.Count -ne [int]$ExpectedFunctionCount) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' `
            -Detail ('version-marker-function-count-' + $arrPublicFunction.Count)
    }
    if ($arrMarkerComment.Count -ne [int]$ExpectedFunctionCount) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' `
            -Detail ('version-marker-comment-count-' + $arrMarkerComment.Count)
    }
    foreach ($objFunction in $arrPublicFunction) {
        $intInside = 0
        foreach ($objComment in $arrMarkerComment) {
            if ($objComment.Extent.StartOffset -ge $objFunction.Extent.StartOffset -and
                $objComment.Extent.EndOffset -le $objFunction.Extent.EndOffset) {
                $intInside++
            }
        }
        if ($intInside -ne 1) {
            & $script:scriptBlockStopHarness -Code 'script-identity-invalid' `
                -Detail ('version-marker-in-' + $objFunction.Name + '-' + $intInside)
        }
    }

    # The count above proves 2 + N non-foreign markers exist and every one of
    # them equals the expected version; the own-constant check binds one of
    # those markers to the constant, and the per-function loop binds N of them
    # to the functions. That leaves exactly one -- the help block's -- accounted
    # for by the total alone. Deleting the help block's marker and adding a
    # stray version literal to any unrelated comment preserves the total, the
    # own-constant, the function count, and the per-function locations, so the
    # help block can carry no marker while this assertion passes. That is the
    # same substitution the per-function check just above closes for a
    # function's marker, left open for the help block's. Bind the last marker
    # too: the help block is the file's leading '<# #>' token and states the
    # version exactly once.
    # Round 66 (Codex P3): the help block was identified by POSITION -- the
    # earliest '<#' token -- not by being the help block. A block comment
    # inserted ahead of the real help (a licence banner, say) becomes the
    # earliest, so moving the marker into that banner and deleting it from the
    # real .SYNOPSIS block preserves the total, the own-constant, the function
    # count, and the per-function locations while the actual help carries no
    # version. Identify the help block by what makes it one: the comment-based
    # help keyword .SYNOPSIS, which the parser itself keys on. Matching the
    # keyword case-insensitively tracks how PowerShell recognises help; the
    # version equality below stays case-sensitive because that is a style rule.
    # Requiring exactly one such block file-wide also refuses a decoy help block
    # that duplicates the keyword to hide an unversioned original. This is the
    # round-56 lesson once more -- key on the thing, not a proxy for it.
    $arrHelpBlockToken = @(@($objMarkerTokens) | Where-Object {
            $_.Kind -eq [System.Management.Automation.Language.TokenKind]::Comment -and
            ([string]$_.Text).StartsWith('<#') -and
            ([string]$_.Text) -imatch '(?m)^\s*\.SYNOPSIS\s*$'
        } | Sort-Object { $_.Extent.StartOffset })
    if (@($arrHelpBlockToken).Count -ne 1) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' `
            -Detail ('version-marker-help-block-count-' + @($arrHelpBlockToken).Count)
    }
    $intHelpBlockMarker = @([System.Text.RegularExpressions.Regex]::Matches(
            [string]$arrHelpBlockToken[0].Text,
            '\b\d+\.\d+\.\d{8}\.\d+\b'
        ) | Where-Object { $_.Value -ceq $ExpectedVersion }).Count
    if ($intHelpBlockMarker -ne 1) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' `
            -Detail ('version-marker-help-block-' + $intHelpBlockMarker)
    }
}

# Rounds 52 and 54 produced three findings of one shape: a live
# `$Context.<field>` read AFTER that field had been captured and
# authenticated. EE6 was the ownership append; GG-A was the
# candidate-directory record; GG-A-prime was the candidate-file record, which
# supplies the expected length and digest the extracted bytes are checked
# against. Each was fixed where it was found, and the third was found only
# because the second prompted a sweep.
#
# Measured, and this is the part that made a rule worth writing: reverting any
# of those three reads leaves the whole suite green -- 113 pass, 2 skip, 0
# fail, empty stderr. No catalog case swaps a journal mid-expansion, so
# nothing observes the difference between reading a capture and reading the
# field it was captured from. Three findings, and the tests could not see any
# of them.
#
# So the shape is refused statically instead. After the capture point, the
# only `$Context.<member>` access production may make is the capture itself:
# the whole right-hand side of an assignment, or a field in a capture literal.
# `@($Context.OwnershipJournal | Where-Object {...})[0]` is neither, and that
# is exactly GG-A-prime.
#
# The capture point is found rather than written down -- the first assignment
# to a variable whose name carries `Authenticated`. Reads BEFORE it are
# untouched, which is deliberate: the entry guard at the top of expansion
# (`if ($Context.LifecycleState -cne 'Active')`) is a legitimate pre-capture
# rejection of a caller-supplied context, and a rule that refused it would be
# refusing the check that makes the capture worth having.
$script:scriptBlockAssertContextReadsAreCaptured = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath
    )

    $objErrors = $null
    $objAst = [System.Management.Automation.Language.Parser]::ParseFile(
        $LiteralPath, [ref]$null, [ref]$objErrors)
    if ($null -eq $objAst -or @($objErrors).Count -ne 0) {
        & $script:scriptBlockStopHarness `
            -Code 'catalog-invalid' -Detail 'context-read-parse'
    }

    # Round 56 replaced three proxies in this rule with the things themselves.
    # Each was reported separately and all three were the same mistake:
    #
    #   HH1 the capture point came from any assignment whose variable NAME
    #       matched 'Authenticated'. Rename or delete the real captures, leave
    #       one late `$boolAuthenticated = $true`, and the point moves past the
    #       live reads while the absent-capture branch stays satisfied.
    #   HH2 a read counted only when its receiver was spelled exactly $Context,
    #       so `$objValidatedContext.OwnershipJournal` was invisible. That alias
    #       is not hypothetical -- production assigns it one line above the
    #       capture block, so the read this rule exists to ban was already
    #       spellable when the rule was written.
    #   HH3 a read counted as captured when ANY ancestor within four hops was an
    #       assignment or a hashtable, and the walk permitted PipelineAst hops,
    #       so `$x = $Context.OwnershipJournal | Select-Object -First 1` reached
    #       an assignment and passed.
    #
    # A name, an ancestor node type, and one spelling of a receiver. None of
    # them is the property being checked.

    $arrAllAssignment = @($objAst.FindAll(
            {
                param ($SyntaxNode)
                return ($SyntaxNode -is
                    [System.Management.Automation.Language.AssignmentStatementAst] -and
                    $SyntaxNode.Left -is
                    [System.Management.Automation.Language.VariableExpressionAst])
            },
            $true
        ))

    # The value an assignment actually stores, unwrapped through the wrappers
    # that do not change it. A Right holding a real pipeline -- more than one
    # element -- returns nothing, because whatever a command did to the value
    # is not a capture of it.
    $scriptBlockUnwrapAssignedValue = {
        param ($AssignmentStatement)
        $objValue = $AssignmentStatement.Right
        if ($objValue -is [System.Management.Automation.Language.PipelineAst]) {
            if (@($objValue.PipelineElements).Count -ne 1) {
                return $null
            }
            $objValue = $objValue.PipelineElements[0]
        }
        if ($objValue -is
            [System.Management.Automation.Language.CommandExpressionAst]) {
            $objValue = $objValue.Expression
        }
        while ($objValue -is
            [System.Management.Automation.Language.ConvertExpressionAst]) {
            $objValue = $objValue.Child
        }
        return $objValue
    }

    # HH2. Every variable that holds the caller's context object, not just the
    # parameter's own name. Iterated to a fixed point so an alias of an alias
    # is one too.
    $hashtableAlias = @{ 'Context' = $true }
    $boolAliasGrew = $true
    while ($boolAliasGrew) {
        $boolAliasGrew = $false
        foreach ($objAssignment in $arrAllAssignment) {
            $strTarget = [string]$objAssignment.Left.VariablePath.UserPath
            if ($hashtableAlias.ContainsKey($strTarget)) {
                continue
            }
            $objValue = & $scriptBlockUnwrapAssignedValue $objAssignment
            if ($objValue -is
                [System.Management.Automation.Language.VariableExpressionAst] -and
                $hashtableAlias.ContainsKey(
                    [string]$objValue.VariablePath.UserPath)) {
                $hashtableAlias[$strTarget] = $true
                $boolAliasGrew = $true
            }
        }
    }

    # The anchor is the authentication itself, not an inferred capture point.
    #
    # The first attempt at this fix classified assignments as "captures" and
    # allowed a read inside one. Mutation testing refuted it: a post-
    # authentication `$objSneak = $objValidatedContext.OwnershipJournal` is
    # itself an assignment storing a context read, so it was classified as a
    # capture and admitted. The rule would have shipped admitting the exact
    # read it exists to ban. That is HH3's complaint one level up, and it is
    # why the classification machinery is gone rather than narrowed.
    #
    # The property is simply stated: once a scope has authenticated the context,
    # it must not read the mutable object again. So the last authentication call
    # in a scope is the boundary, and every context read must precede it. A
    # scope that reads the context and never authenticates it cannot be
    # evaluated, which is refused rather than passed -- round 49's BB1.
    $arrAuthentication = @($objAst.FindAll(
            {
                param ($SyntaxNode)
                return ($SyntaxNode -is
                    [System.Management.Automation.Language.CommandAst] -and
                    ([string]$SyntaxNode.GetCommandName()) -ceq
                    'Test-StyleGuideCandidateInvocationContextIssued')
            },
            $true
        ))

    $scriptBlockResolveScopeStart = {
        param ($SyntaxNode)
        $objScope = $SyntaxNode
        while ($null -ne $objScope) {
            if ($objScope -is
                [System.Management.Automation.Language.FunctionDefinitionAst] -or
                $null -eq $objScope.Parent) {
                return [int]$objScope.Extent.StartOffset
            }
            $objScope = $objScope.Parent
        }
        return -1
    }

    # A receiver may be wrapped in things that do not change which object it is.
    # Round 56 required the receiver to BE a VariableExpressionAst, so
    # `($objValidatedContext).OwnershipJournal` -- a ParenExpressionAst -- was
    # skipped before the alias table was ever consulted. Reported at round 57
    # as JJ1, and it is HH2's property inside the fix for HH2: a rule that names
    # one spelling of a thing is escaped by another spelling of the same thing.
    $scriptBlockUnwrapReceiver = {
        param ($SyntaxNode)
        $objInner = $SyntaxNode
        while ($true) {
            if ($objInner -is
                [System.Management.Automation.Language.ParenExpressionAst]) {
                $objInner = $objInner.Pipeline
                continue
            }
            if ($objInner -is
                [System.Management.Automation.Language.PipelineAst] -and
                @($objInner.PipelineElements).Count -eq 1) {
                $objInner = $objInner.PipelineElements[0]
                continue
            }
            if ($objInner -is
                [System.Management.Automation.Language.CommandExpressionAst]) {
                $objInner = $objInner.Expression
                continue
            }
            if ($objInner -is
                [System.Management.Automation.Language.ConvertExpressionAst]) {
                $objInner = $objInner.Child
                continue
            }
            break
        }
        return $objInner
    }

    # A context piped into a script block arrives as $_ or $PSItem, which is the
    # same object under a name the alias table cannot know. Rather than model
    # what each command does with its input, any pipeline whose source is a
    # context alias is refused outright -- production never pipes the context
    # anywhere, so the permitted shape is "not at all". Reported as JJ2.
    foreach ($objPipeline in @($objAst.FindAll(
                {
                    param ($SyntaxNode)
                    return ($SyntaxNode -is
                        [System.Management.Automation.Language.PipelineAst] -and
                        @($SyntaxNode.PipelineElements).Count -gt 1)
                },
                $true
            ))) {
        $objSource = & $scriptBlockUnwrapReceiver $objPipeline.PipelineElements[0]
        if ($objSource -is
            [System.Management.Automation.Language.VariableExpressionAst] -and
            $hashtableAlias.ContainsKey(
                [string]$objSource.VariablePath.UserPath)) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('context-read-piped-' +
                    [string]$objPipeline.Extent.StartLineNumber)
        }
    }

    foreach ($objRead in @($objAst.FindAll(
                {
                    param ($SyntaxNode)
                    return ($SyntaxNode -is
                        [System.Management.Automation.Language.MemberExpressionAst])
                },
                $true
            ))) {
        $objReceiver = & $scriptBlockUnwrapReceiver $objRead.Expression
        if ($objReceiver -isnot
            [System.Management.Automation.Language.VariableExpressionAst]) {
            continue
        }
        if (-not $hashtableAlias.ContainsKey(
                [string]$objReceiver.VariablePath.UserPath)) {
            continue
        }

        # Each function authenticates for itself, and the entry point is not a
        # function, so code outside any function is scoped to the file. A
        # file-wide boundary would otherwise place one function's
        # authentication against another function's reads.
        $intScopeStart = & $scriptBlockResolveScopeStart $objRead.Parent
        if ($intScopeStart -lt 0) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('context-read-unscoped-' +
                    [string]$objRead.Extent.StartLineNumber)
        }

        # The boundary is the FIRST call that actually authenticates, and only
        # a call carrying -ExpectedValues does that: a bare
        # Test-...Issued is a probe, and production uses one against a
        # throwaway object purely to prove the manager is loaded.
        #
        # Round 56 took the maximum end offset over every call of any shape.
        # Reported immediately: with a real authentication, then a live read,
        # then any later verifier call, the maximum picks the later call and the
        # intervening read looks pre-authentication. Taking the first
        # authenticating call instead means a later one cannot move the
        # boundary at all, which is the property that was wanted.
        $intBoundary = [int]::MaxValue
        foreach ($objAuthentication in $arrAuthentication) {
            if ((& $scriptBlockResolveScopeStart $objAuthentication.Parent) -ne
                $intScopeStart) {
                continue
            }
            $boolAuthenticates = $false
            foreach ($objElement in @($objAuthentication.CommandElements)) {
                if ($objElement -is
                    [System.Management.Automation.Language.CommandParameterAst] -and
                    ([string]$objElement.ParameterName) -ceq 'ExpectedValues') {
                    $boolAuthenticates = $true
                    break
                }
            }
            if (-not $boolAuthenticates) {
                continue
            }
            if ([int]$objAuthentication.Extent.EndOffset -lt $intBoundary) {
                $intBoundary = [int]$objAuthentication.Extent.EndOffset
            }
        }
        if ($intBoundary -eq [int]::MaxValue) {
            $intBoundary = -1
        }
        if ($intBoundary -lt 0) {
            & $script:scriptBlockStopHarness `
                -Code 'catalog-invalid' -Detail 'context-read-capture-absent'
        }
        if ([int]$objRead.Extent.StartOffset -gt $intBoundary) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('context-read-not-captured-' +
                    [string]$objRead.Extent.StartLineNumber)
        }
    }
}

$script:scriptBlockAssertResourceGuardsWired = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath
    )

    # PS-P1A-R-10 through R-13 exercise the length guards by invoking them
    # directly, which proves the guards behave correctly but not that production
    # still calls them. Driving those rows through expansion is not available:
    # the checked-overflow row needs a running total no real archive produces,
    # and re-driving the actual-length rows would land them in a phase the
    # frozen catalog does not record. The wiring is asserted here instead.
    #
    # This reads the parsed command tree rather than source text. Three earlier
    # revisions scanned raw lines and each was bypassed in turn: by deleting a
    # call site, by passing a literal, and by passing a zero-initialised decoy
    # variable. Source text also cannot tell an executable invocation from a
    # commented-out one. Only executable commands appear in the AST.
    $objTokens = $null
    $objParseErrors = $null
    $objScriptAst = [System.Management.Automation.Language.Parser]::ParseFile(
        $LiteralPath,
        [ref]$objTokens,
        [ref]$objParseErrors
    )
    if ($null -eq $objScriptAst -or @($objParseErrors).Count -ne 0) {
        & $script:scriptBlockStopHarness `
            -Code 'catalog-invalid' -Detail 'production-resource-guard'
    }
    $hashtableRequiredInvocation = [ordered]@{
        'scriptBlockAddCandidateHelperDeclaredLength' = [ordered]@{
            Count = 1
            Required = [string[]]@('CurrentTotal', 'DeclaredLength')
            # Each accumulator must be the exact running total production
            # carries forward, so rewiring has to update this table too.
            Accumulator = [ordered]@{
                CurrentTotal = [string[]]@('uintDeclaredTotal')
            }
        }
        'scriptBlockAddCandidateHelperActualLength' = [ordered]@{
            Count = 2
            Required = [string[]]@(
                'CurrentEntryLength', 'CurrentTotalLength', 'ReadLength', 'DeclaredEntryLength'
            )
            Accumulator = [ordered]@{
                CurrentEntryLength = [string[]]@('uintEvidenceLength', 'uintEntryActual')
                CurrentTotalLength = [string[]]@('uintEvidenceTotal', 'uintActualTotal')
            }
        }
    }
    $arrCommandAst = @($objScriptAst.FindAll(
        {
            param ($SyntaxNode)
            $SyntaxNode -is [System.Management.Automation.Language.CommandAst]
        },
        $true
    ))
    foreach ($strName in $hashtableRequiredInvocation.Keys) {
        $hashtableRule = $hashtableRequiredInvocation[$strName]
        $intObserved = 0
        foreach ($objCommandAst in $arrCommandAst) {
            $arrElement = @($objCommandAst.CommandElements)
            if ($arrElement.Count -lt 1 -or
                -not ($arrElement[0] -is
                    [System.Management.Automation.Language.VariableExpressionAst]) -or
                $arrElement[0].VariablePath.UserPath -cne ('script:' + $strName)) {
                continue
            }
            # Bind parameter names to their argument nodes. A separated
            # argument is the following element; an attached one is carried on
            # the parameter node itself.
            $hashtableBoundArgument = @{}
            for ($intIndex = 1; $intIndex -lt $arrElement.Count; $intIndex++) {
                if (-not ($arrElement[$intIndex] -is
                        [System.Management.Automation.Language.CommandParameterAst])) {
                    continue
                }
                $objArgumentAst = $arrElement[$intIndex].Argument
                if ($null -eq $objArgumentAst -and ($intIndex + 1) -lt $arrElement.Count) {
                    $objArgumentAst = $arrElement[$intIndex + 1]
                }
                $hashtableBoundArgument[$arrElement[$intIndex].ParameterName] = $objArgumentAst
            }
            foreach ($strParameter in $hashtableRule.Required) {
                if (-not $hashtableBoundArgument.ContainsKey($strParameter) -or
                    $null -eq $hashtableBoundArgument[$strParameter]) {
                    & $script:scriptBlockStopHarness `
                        -Code 'catalog-invalid' -Detail 'production-resource-guard'
                }
            }
            foreach ($strParameter in $hashtableRule.Accumulator.Keys) {
                $objArgumentAst = $hashtableBoundArgument[$strParameter]
                if (-not ($objArgumentAst -is
                        [System.Management.Automation.Language.VariableExpressionAst]) -or
                    $objArgumentAst.VariablePath.UserPath -cnotin
                        $hashtableRule.Accumulator[$strParameter]) {
                    & $script:scriptBlockStopHarness `
                        -Code 'catalog-invalid' -Detail 'production-resource-guard'
                }
            }
            $intObserved++
        }
        if ($intObserved -lt $hashtableRule.Count) {
            & $script:scriptBlockStopHarness `
                -Code 'catalog-invalid' -Detail 'production-resource-guard'
        }
    }
}

$script:scriptBlockAssertResourceGuardsReached = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [string]$RunRoot
    )

    # The assertion above proves each guard is named in an executable command
    # with the right parameters and accumulators. It cannot prove that command
    # ever runs. Parking a call inside a branch whose condition is constantly
    # false, or after a return, or in a script block nothing invokes, satisfies
    # every structural check while the guard never executes -- and inlining the
    # guard's body at the call site keeps the catalog green, because the
    # observable diagnostics are unchanged. That was the sixth way this file's
    # wiring check has been satisfied without the wiring being real.
    #
    # Structure cannot settle this question: parseable is not reachable, and no
    # amount of pattern matching over an unexecuted tree becomes evidence of
    # execution. So this observes execution instead. For each guard, the helper
    # is copied twice -- once verbatim, once with that guard's body replaced by
    # a throw -- and one expansion is driven through each copy. The verbatim
    # copy must succeed and the poisoned copy must fail. If production no longer
    # reaches the guard, poisoning it changes nothing and both copies succeed,
    # which is the failure this asserts.
    #
    # The two checks answer different questions and neither subsumes the other.
    # Poisoning a guard poisons every one of its call sites at once, so this
    # proves at least one runs, not how many; the structural check is what pins
    # the call count and the accumulator each site carries forward.
    $arrGuardName = [string[]]@(
        'scriptBlockAddCandidateHelperDeclaredLength',
        'scriptBlockAddCandidateHelperActualLength'
    )

    $objTokens = $null
    $objParseErrors = $null
    $objScriptAst = [System.Management.Automation.Language.Parser]::ParseFile(
        $LiteralPath,
        [ref]$objTokens,
        [ref]$objParseErrors
    )
    if ($null -eq $objScriptAst -or @($objParseErrors).Count -ne 0) {
        & $script:scriptBlockStopHarness `
            -Code 'catalog-invalid' -Detail 'production-resource-guard-reached'
    }
    $strSource = [System.IO.File]::ReadAllText($LiteralPath)
    $objEncoding = New-Object System.Text.UTF8Encoding($false)

    $strProbeRoot = [System.IO.Path]::Combine($RunRoot, 'resource-guard-reached')
    [void][System.IO.Directory]::CreateDirectory($strProbeRoot)
    $strCheckoutRoot = [System.IO.Path]::Combine($strProbeRoot, 'checkout')
    [void][System.IO.Directory]::CreateDirectory($strCheckoutRoot)
    $strTrustedRoot = [System.IO.Path]::Combine($strProbeRoot, 'trusted')
    [void][System.IO.Directory]::CreateDirectory($strTrustedRoot)

    # One expansion of one freshly created context through whichever copy is
    # named. Each call builds its own context and archive: sharing them would
    # let one variant's outcome decide the next one's.
    $scriptBlockDriveOneExpansion = {
        param (
            [Parameter(Mandatory = $true)]
            [string]$ScriptPath
        )

        $objProbeContext = New-StyleGuideCandidateInvocationContext `
            -TrustedTemporaryRoot $strTrustedRoot
        $strArchivePath = [System.IO.Path]::Combine(
            $objProbeContext.DownloadDirectoryPath,
            'artifact.zip'
        )
        $objArchive = [System.IO.Compression.ZipFile]::Open(
            $strArchivePath,
            [System.IO.Compression.ZipArchiveMode]::Create
        )
        try {
            foreach ($strEntryName in @(
                'copilot-instructions.md',
                'powershell.instructions.md',
                'STYLE_GUIDE_CHAT.md',
                'STYLE_GUIDE_FULL.md'
            )) {
                $objEntry = $objArchive.CreateEntry($strEntryName)
                $objEntryWriter = New-Object System.IO.StreamWriter($objEntry.Open())
                try {
                    $objEntryWriter.Write('# ' + $strEntryName)
                } finally {
                    $objEntryWriter.Dispose()
                }
            }
        } finally {
            $objArchive.Dispose()
        }
        $objSha256 = [System.Security.Cryptography.SHA256]::Create()
        try {
            $objArchiveStream = [System.IO.File]::OpenRead($strArchivePath)
            try {
                $strExpectedDigest = (
                    [System.BitConverter]::ToString(
                        $objSha256.ComputeHash($objArchiveStream)
                    ) -replace '-', ''
                ).ToLowerInvariant()
            } finally {
                $objArchiveStream.Dispose()
            }
        } finally {
            $objSha256.Dispose()
        }

        try {
            [void](& $ScriptPath `
                -Context $objProbeContext `
                -CheckoutRoot $strCheckoutRoot `
                -TrustedTemporaryRoot $strTrustedRoot `
                -DownloadDirectory $objProbeContext.DownloadDirectoryPath `
                -CandidateDirectory $objProbeContext.CandidatePath `
                -ExpectedDigest $strExpectedDigest)
            return $true
        } catch {
            return $false
        }
    }

    # A throw with no diagnostic code of its own. The helper maps it through its
    # own taxonomy, so this deliberately asserts only that the expansion failed,
    # never which text came back -- tying the check to a wrapped message would
    # make it a source-shaped assertion again.
    $strStubBody = "{`n" +
        "    param (`n" +
        "        [Parameter(ValueFromRemainingArguments = `$true)]`n" +
        "        [AllowNull()]`n" +
        "        [AllowEmptyCollection()]`n" +
        "        [object[]]`$Ignored`n" +
        "    )`n`n" +
        "    throw (New-Object System.InvalidOperationException('guard-reached-probe'))`n" +
        "}`n"

    foreach ($strGuardName in $arrGuardName) {
        $arrAssignment = @($objScriptAst.FindAll(
            {
                param ($SyntaxNode)
                $SyntaxNode -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                    $SyntaxNode.Left -is
                        [System.Management.Automation.Language.VariableExpressionAst] -and
                    $SyntaxNode.Left.VariablePath.UserPath -ceq ('script:' + $strGuardName)
            },
            $true
        ))
        if ($arrAssignment.Count -ne 1) {
            & $script:scriptBlockStopHarness `
                -Code 'catalog-invalid' -Detail 'production-resource-guard-reached'
        }
        $objDefinition = $arrAssignment[0].Right
        $strPoisoned = $strSource.Substring(0, $objDefinition.Extent.StartOffset) +
            $strStubBody +
            $strSource.Substring($objDefinition.Extent.EndOffset)

        $strVerbatimPath = [System.IO.Path]::Combine(
            $strProbeRoot,
            'verbatim-' + $strGuardName + '.ps1'
        )
        $strPoisonedPath = [System.IO.Path]::Combine(
            $strProbeRoot,
            'poisoned-' + $strGuardName + '.ps1'
        )
        [System.IO.File]::WriteAllText($strVerbatimPath, $strSource, $objEncoding)
        [System.IO.File]::WriteAllText($strPoisonedPath, $strPoisoned, $objEncoding)

        $hashtableOutcome = @{}
        foreach ($strVariant in @('verbatim', 'poisoned')) {
            $strVariantPath = if ($strVariant -ceq 'verbatim') {
                $strVerbatimPath
            } else {
                $strPoisonedPath
            }
            $hashtableOutcome[$strVariant] = & $scriptBlockDriveOneExpansion `
                -ScriptPath $strVariantPath
        }

        # Verbatim must succeed, or the probe proves nothing about the poison.
        # Poisoned must fail, or production never reached the guard.
        if (-not $hashtableOutcome['verbatim'] -or $hashtableOutcome['poisoned']) {
            & $script:scriptBlockStopHarness `
                -Code 'catalog-invalid' -Detail 'production-resource-guard-reached'
        }
    }

    # Poisoning a guard poisons every one of its call sites at once, so the runs
    # above prove only that some site is reachable. One guard is called from two
    # phases, and parking the manifest call in an unreachable branch with its
    # arithmetic inlined leaves the structural count satisfied, the poisoned run
    # still failing from the surviving extraction call, and the pre-creation
    # bound gone. Both checks stay green while the archive is read unbounded.
    #
    # Inference from a failure cannot separate those sites: it observes that
    # something stopped, never which call did the stopping. So this records
    # instead of stopping. Each guard is replaced by a body that appends its
    # phase to a file and returns what the guard returns, and the expansion is
    # required to succeed and to have visited every phase the guard serves.
    $strTracePath = [System.IO.Path]::Combine($strProbeRoot, 'trace.txt')
    $strTraceLiteral = $strTracePath.Replace("'", "''")
    # For a valid archive no limit fires, so plain addition returns exactly what
    # the real guard would. If that were ever untrue the traced run would fail,
    # and a failed traced run is itself asserted below.
    $hashtableTracerBody = @{
        'scriptBlockAddCandidateHelperDeclaredLength' = "{`n" +
            "    param (`n" +
            "        [Parameter(Mandatory = `$true)][uint64]`$CurrentTotal,`n" +
            "        [Parameter(Mandatory = `$true)][long]`$DeclaredLength`n" +
            "    )`n`n" +
            "    [System.IO.File]::AppendAllText('$strTraceLiteral',`n" +
            "        'declared' + [System.Environment]::NewLine)`n" +
            "    return [uint64](`$CurrentTotal + [uint64]`$DeclaredLength)`n" +
            "}`n"
        'scriptBlockAddCandidateHelperActualLength' = "{`n" +
            "    param (`n" +
            "        [Parameter(Mandatory = `$true)][uint64]`$CurrentEntryLength,`n" +
            "        [Parameter(Mandatory = `$true)][uint64]`$CurrentTotalLength,`n" +
            "        [Parameter(Mandatory = `$true)][uint64]`$ReadLength,`n" +
            "        [Parameter(Mandatory = `$true)][uint64]`$DeclaredEntryLength,`n" +
            "        [Parameter(Mandatory = `$true)][string]`$Phase,`n" +
            "        [Parameter(Mandatory = `$true)][string]`$DiagnosticCode`n" +
            "    )`n`n" +
            "    [System.IO.File]::AppendAllText('$strTraceLiteral',`n" +
            "        'actual:' + `$Phase + [System.Environment]::NewLine)`n" +
            "    return [ordered]@{`n" +
            "        EntryLength = [uint64](`$CurrentEntryLength + `$ReadLength)`n" +
            "        TotalLength = [uint64](`$CurrentTotalLength + `$ReadLength)`n" +
            "    }`n" +
            "}`n"
    }
    # Splice from the last definition backwards so an earlier replacement cannot
    # move the offsets of a later one.
    $listDefinition = New-Object 'System.Collections.Generic.List[object]'
    foreach ($strGuardName in $arrGuardName) {
        $arrAssignment = @($objScriptAst.FindAll(
            {
                param ($SyntaxNode)
                $SyntaxNode -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                    $SyntaxNode.Left -is
                        [System.Management.Automation.Language.VariableExpressionAst] -and
                    $SyntaxNode.Left.VariablePath.UserPath -ceq ('script:' + $strGuardName)
            },
            $true
        ))
        if ($arrAssignment.Count -ne 1) {
            & $script:scriptBlockStopHarness `
                -Code 'catalog-invalid' -Detail 'production-resource-guard-reached'
        }
        $listDefinition.Add([pscustomobject]@{
            Name = $strGuardName
            Start = [int]$arrAssignment[0].Right.Extent.StartOffset
            End = [int]$arrAssignment[0].Right.Extent.EndOffset
        })
    }
    $strTraced = $strSource
    foreach ($objDefinition in @($listDefinition | Sort-Object -Property Start -Descending)) {
        $strTraced = $strTraced.Substring(0, $objDefinition.Start) +
            $hashtableTracerBody[$objDefinition.Name] +
            $strTraced.Substring($objDefinition.End)
    }
    $strTracedPath = [System.IO.Path]::Combine($strProbeRoot, 'traced.ps1')
    [System.IO.File]::WriteAllText($strTracedPath, $strTraced, $objEncoding)
    if ([System.IO.File]::Exists($strTracePath)) {
        [System.IO.File]::Delete($strTracePath)
    }

    $boolTracedSucceeded = & $scriptBlockDriveOneExpansion -ScriptPath $strTracedPath
    if (-not $boolTracedSucceeded -or -not [System.IO.File]::Exists($strTracePath)) {
        & $script:scriptBlockStopHarness `
            -Code 'catalog-invalid' -Detail 'production-resource-guard-reached'
    }
    $hashtableObservedSite = @{}
    foreach ($strLine in [System.IO.File]::ReadAllLines($strTracePath)) {
        if ($strLine.Length -eq 0) {
            continue
        }
        if (-not $hashtableObservedSite.ContainsKey($strLine)) {
            $hashtableObservedSite[$strLine] = 0
        }
        $hashtableObservedSite[$strLine] = [int]$hashtableObservedSite[$strLine] + 1
    }

    # Presence alone is too weak. The guard reports the phase its caller passed,
    # so a single reachable call carrying the right phase and a zero read length
    # produces the same evidence as a guard that runs on every read -- which
    # means the real call could be lifted out of the read loop, its arithmetic
    # inlined, and a decoy left behind to satisfy this.
    #
    # How often the guard runs is what separates those. Each guard is invoked
    # once per manifest entry or per read chunk, so the fixture's own entry
    # count is the floor, and the decoy can only produce one. The count is what
    # the decoy cannot forge without doing the work it was removed to avoid.
    #
    # The floor is read from the fixture rather than written as a number, so a
    # change to what the probe archive contains cannot silently weaken it.
    $intFixtureEntryCount = @($script:arrCandidateExpectedName).Count
    $hashtableRequiredSite = [ordered]@{
        'declared' = $intFixtureEntryCount
        'actual:manifest' = $intFixtureEntryCount
        'actual:extraction' = $intFixtureEntryCount
    }
    if ($hashtableObservedSite.Count -ne $hashtableRequiredSite.Count) {
        & $script:scriptBlockStopHarness `
            -Code 'catalog-invalid' -Detail 'production-resource-guard-reached'
    }
    foreach ($strRequiredSite in $hashtableRequiredSite.Keys) {
        if (-not $hashtableObservedSite.ContainsKey($strRequiredSite) -or
            [int]$hashtableObservedSite[$strRequiredSite] -lt
                [int]$hashtableRequiredSite[$strRequiredSite]) {
            & $script:scriptBlockStopHarness `
                -Code 'catalog-invalid' -Detail 'production-resource-guard-reached'
        }
    }
}

$script:scriptBlockAssertDirectoryReadsBounded = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [string]$ContextLiteralPath,

        [Parameter(Mandatory = $true)]
        [string]$RunRoot
    )

    # Reading a whole directory to decide whether it holds exactly one entry
    # costs memory proportional to what is there, and at the download check no
    # archive ceiling is in force yet because no archive has been opened. The
    # fix bounds the read; the difficulty is that bounding it changes no
    # observable output, so the catalog cannot see it either way and a silent
    # removal would leave every case green.
    #
    # Two assertions, because neither alone is enough. The first is
    # behavioural: the helpers really do stop early, and really do return
    # everything when unbounded -- otherwise a bound of two would be
    # indistinguishable from an enumeration that is simply broken. The second
    # is structural, and admitted as such: it pins the bound at the call sites
    # whose cardinality is fixed. Structure is a weak form of evidence and this
    # file says so elsewhere, but a resource property with no output to observe
    # leaves nothing else to check at the call site.
    $strProbeRoot = [System.IO.Path]::Combine($RunRoot, 'bounded-directory-read')
    [void][System.IO.Directory]::CreateDirectory($strProbeRoot)
    $strCrowded = [System.IO.Path]::Combine($strProbeRoot, 'crowded')
    [void][System.IO.Directory]::CreateDirectory($strCrowded)
    $intSeeded = 512
    for ($intEntry = 0; $intEntry -lt $intSeeded; $intEntry++) {
        [System.IO.File]::WriteAllBytes(
            [System.IO.Path]::Combine($strCrowded, ('e{0}.bin' -f $intEntry)),
            [byte[]]@()
        )
    }

    $arrBounded = [string[]]@(& $script:scriptBlockGetCandidateHelperEntry `
            -LiteralPath $strCrowded -Phase 'download' -MaximumEntry 2)
    $arrContextBounded = [string[]]@(& $scriptBlockGetCandidateImmediateEntry `
            -LiteralPath $strCrowded -FailureCode 'root-invalid' `
            -FailurePhase 'root' -MaximumEntry 1)
    if ($arrBounded.Count -ne 2 -or $arrContextBounded.Count -ne 1) {
        & $script:scriptBlockStopHarness `
            -Code 'catalog-invalid' -Detail 'bounded-directory-read'
    }
    # These used to assert that a call carrying neither a bound nor a filter
    # returned the whole directory, which documented the very mode that made the
    # source-order site table defeasible: parking the expected call under
    # `if ($false)` and performing the live read through a variable holding the
    # same script block reached that mode without editing any call site, and the
    # suite stayed green with the whole parent materialized. No production site
    # has needed it since every read became bounded or filtered, so the mode is
    # gone and what is asserted here is its absence. An absurd bound is refused
    # for the same reason -- it is a bound in shape and not in effect, and the
    # alias trick would otherwise simply pass one.
    $arrRefusedShape = @(
        @{
            Name = 'helper-neither'
            Probe = { & $script:scriptBlockGetCandidateHelperEntry `
                    -LiteralPath $strCrowded -Phase 'download' }
        },
        @{
            Name = 'helper-absurd'
            Probe = { & $script:scriptBlockGetCandidateHelperEntry `
                    -LiteralPath $strCrowded -Phase 'download' -MaximumEntry 999999 }
        },
        @{
            Name = 'context-neither'
            Probe = { & $scriptBlockGetCandidateImmediateEntry `
                    -LiteralPath $strCrowded -FailureCode 'root-invalid' -FailurePhase 'root' }
        },
        @{
            Name = 'context-absurd'
            Probe = { & $scriptBlockGetCandidateImmediateEntry `
                    -LiteralPath $strCrowded -FailureCode 'root-invalid' `
                    -FailurePhase 'root' -MaximumEntry 999999 }
        }
    )
    foreach ($hashtableRefused in $arrRefusedShape) {
        $boolRefused = $false
        try {
            [void](& ([scriptblock]$hashtableRefused.Probe))
        } catch {
            $boolRefused = $true
        }
        if (-not $boolRefused) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('unbounded-read-admitted-' + $hashtableRefused.Name)
        }
    }

    # The FILTERED read's own refusal -- the sibling of the absurd-bound probes
    # above, which cover 'enumeration-bound' while this half went unexercised in
    # both enumerators. A MatchPath leaf carrying a wildcard cannot serve as a
    # literal filter: it would match many names and reduce a named absence proof
    # to a pattern listing, so both the helper and the context enumerator refuse
    # it with 'enumeration-filter'. Neither refusal is reachable from the public
    # entry point -- every production call site passes an internal name already
    # cleared of wildcards by the parameter boundary check that E-10/S-03/S-04
    # cover -- so this is a direct behavioural probe rather than a catalog row,
    # the same shape the round-59 wiring pins take. Measured: deleting the
    # rejected-character check let an 'e*.bin' filter pattern-match all 512
    # crowded entries with no refusal. The message is checked for the subreason,
    # not merely that it threw, and both '*' and '?' are exercised. The helper
    # reports subreason=, the context manager reason=, and the latter is a
    # substring of the former.
    $arrFilterProbe = @(
        @{ Name = 'helper-star'
            Probe = { & $script:scriptBlockGetCandidateHelperEntry `
                    -LiteralPath $strCrowded -Phase 'download' -MatchPath 'e*.bin' } }
        @{ Name = 'helper-question'
            Probe = { & $script:scriptBlockGetCandidateHelperEntry `
                    -LiteralPath $strCrowded -Phase 'download' -MatchPath 'e?.bin' } }
        @{ Name = 'context-star'
            Probe = { & $scriptBlockGetCandidateImmediateEntry `
                    -LiteralPath $strCrowded -FailureCode 'root-invalid' `
                    -FailurePhase 'root' -MatchPath 'e*.bin' } }
        @{ Name = 'context-question'
            Probe = { & $scriptBlockGetCandidateImmediateEntry `
                    -LiteralPath $strCrowded -FailureCode 'root-invalid' `
                    -FailurePhase 'root' -MatchPath 'e?.bin' } }
    )
    foreach ($hashtableFilter in $arrFilterProbe) {
        $boolFilterRefused = $false
        $strFilterMessage = ''
        try {
            [void]([string[]]@(& ([scriptblock]$hashtableFilter.Probe)))
        } catch {
            $boolFilterRefused = $true
            $strFilterMessage = [string]$_.Exception.Message
        }
        if (-not $boolFilterRefused -or
            -not $strFilterMessage.Contains('reason=enumeration-filter')) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('enumeration-filter-not-refused-' + $hashtableFilter.Name)
        }
    }

    # A directory holding fewer paths than the bound must still come back whole,
    # because the presence checks downstream treat a short result as complete.
    $strSparse = [System.IO.Path]::Combine($strProbeRoot, 'sparse')
    [void][System.IO.Directory]::CreateDirectory($strSparse)
    [System.IO.File]::WriteAllBytes(
        [System.IO.Path]::Combine($strSparse, 'only.bin'), [byte[]]@())
    if ([string[]]@(& $script:scriptBlockGetCandidateHelperEntry `
                -LiteralPath $strSparse -Phase 'download' -MaximumEntry 2).Count -ne 1) {
        & $script:scriptBlockStopHarness `
            -Code 'catalog-invalid' -Detail 'bounded-directory-read'
    }

    # A filtered read turns a leaf into a search pattern, so the guard on it has
    # to refuse what expands and nothing else. It once refused a set spelled
    # identically on both platforms, which is how an ordinary Unix artifact name
    # -- 'release:linux.zip' -- expanded successfully and then failed cleanup,
    # retaining records and leaving the invocation root on disk. No catalog case
    # can see that, because none of them names a download file; re-widening the
    # set passed 115 of 115 silently. So the property is asserted directly:
    # every name the platform can produce must be found by its own filter.
    $strLeafProbe = [System.IO.Path]::Combine($strProbeRoot, 'leaf')
    [void][System.IO.Directory]::CreateDirectory($strLeafProbe)
    $objInvalidLeafChar = New-Object 'System.Collections.Generic.HashSet[char]' (
        ,[char[]][System.IO.Path]::GetInvalidFileNameChars()
    )
    foreach ($strLeaf in [string[]]@(
            'plain.zip', 'release:linux.zip', 'back\slash.zip', 'brack[et].zip',
            'quote".zip', 'less<than.zip', 'more>than.zip')) {
        # What a platform cannot name it cannot enumerate, so those rows are not
        # applicable rather than expected to fail.
        $boolNameable = $true
        foreach ($chrLeaf in $strLeaf.ToCharArray()) {
            if ($objInvalidLeafChar.Contains($chrLeaf)) {
                $boolNameable = $false
            }
        }
        if (-not $boolNameable) {
            continue
        }
        $strLeafPath = [System.IO.Path]::Combine($strLeafProbe, $strLeaf)
        [System.IO.File]::WriteAllBytes($strLeafPath, [byte[]]@())
        if ([string[]]@(& $script:scriptBlockGetCandidateHelperEntry `
                    -LiteralPath $strLeafProbe -Phase 'download' `
                    -MatchPath $strLeafPath) -cnotcontains $strLeafPath -or
            [string[]]@(& $scriptBlockGetCandidateImmediateEntry `
                    -LiteralPath $strLeafProbe -FailureCode 'root-invalid' `
                    -FailurePhase 'root' -MatchPath $strLeafPath) -cnotcontains $strLeafPath) {
            & $script:scriptBlockStopHarness `
                -Code 'catalog-invalid' -Detail 'match-leaf-refused'
        }
    }
    # The other direction, so the guard cannot be relaxed into uselessness: the
    # two characters that do expand stay refused, because a pattern matching
    # more than its one name reopens the whole-directory read the filter
    # replaced.
    foreach ($strExpanding in [string[]]@('star*.zip', 'quest?.zip')) {
        $boolRefused = $false
        try {
            [void](& $script:scriptBlockGetCandidateHelperEntry `
                -LiteralPath $strLeafProbe -Phase 'download' `
                -MatchPath ([System.IO.Path]::Combine($strLeafProbe, $strExpanding)))
        } catch {
            $boolRefused = $true
        }
        if (-not $boolRefused) {
            & $script:scriptBlockStopHarness `
                -Code 'catalog-invalid' -Detail 'match-leaf-admitted'
        }
    }

    # Exact counts, not minimums. A minimum would let one bound be dropped as
    # soon as another was added elsewhere, which is the failure this is for.
    # The cost is that a legitimate new bounded read has to be recorded here --
    # the same deliberate step the version markers require, and it has already
    # caught one addition that would otherwise have slipped past unrecorded.
    # Context gained a fifth bounded site when round 16 found its invocation-root
    # cleanup read deriving its expected set after the read instead of before it.
    # Round 32 moved the candidate-cleanup read from the helper to the context
    # manager along with the deletions it bounded, so the helper is one lower
    # and the context one higher than before.
    $hashtableBoundedSite = [ordered]@{
        $LiteralPath = [int]3
        $ContextLiteralPath = [int]6
    }
    foreach ($strScriptPath in $hashtableBoundedSite.Keys) {
        $objSiteTokens = $null
        $objSiteParseErrors = $null
        $objSiteAst = [System.Management.Automation.Language.Parser]::ParseFile(
            $strScriptPath,
            [ref]$objSiteTokens,
            [ref]$objSiteParseErrors
        )
        if ($null -eq $objSiteAst -or @($objSiteParseErrors).Count -ne 0) {
            & $script:scriptBlockStopHarness `
                -Code 'catalog-invalid' -Detail 'bounded-directory-read'
        }
        $intBoundedCall = @($objSiteAst.FindAll(
                {
                    param ($SyntaxNode)
                    if ($SyntaxNode -isnot
                        [System.Management.Automation.Language.CommandAst]) {
                        return $false
                    }
                    $boolNamed = $false
                    foreach ($objElement in $SyntaxNode.CommandElements) {
                        if ($objElement -is
                            [System.Management.Automation.Language.CommandParameterAst] -and
                            $objElement.ParameterName -ceq 'MaximumEntry') {
                            $boolNamed = $true
                        }
                    }
                    return $boolNamed
                },
                $true
            )).Count
        if ($intBoundedCall -ne [int]$hashtableBoundedSite[$strScriptPath]) {
            & $script:scriptBlockStopHarness `
                -Code 'catalog-invalid' -Detail 'bounded-directory-read'
        }
    }
}

$script:scriptBlockReadArchiveUInt = {
    param ([byte[]]$Buffer, [int]$Index, [int]$Width)
    $lngValue = [int64]0
    for ($intByte = 0; $intByte -lt $Width; $intByte++) {
        $lngValue = $lngValue -bor ([int64]$Buffer[$Index + $intByte] -shl (8 * $intByte))
    }
    return $lngValue
}
$script:scriptBlockWriteArchiveUInt = {
    param ([byte[]]$Buffer, [int]$Index, [int64]$Value, [int]$Width)
    for ($intByte = 0; $intByte -lt $Width; $intByte++) {
        $Buffer[$Index + $intByte] = [byte](($Value -shr (8 * $intByte)) -band 0xFF)
    }
}
$script:scriptBlockNewArchiveByte = {
    param ([string[]]$EntryName)
    $objMemory = New-Object System.IO.MemoryStream
    $objBuilder = New-Object System.IO.Compression.ZipArchive(
        $objMemory,
        [System.IO.Compression.ZipArchiveMode]::Create,
        $true
    )
    try {
        foreach ($strEntryName in $EntryName) {
            $objEntryStream = $objBuilder.CreateEntry(
                $strEntryName,
                [System.IO.Compression.CompressionLevel]::NoCompression
            ).Open()
            $objEntryStream.Dispose()
        }
    } finally {
        $objBuilder.Dispose()
    }
    $arrByte = $objMemory.ToArray()
    $objMemory.Dispose()
    return , $arrByte
}

# The two trailer-bypass archives are built here rather than inside the assertion
# that first needed them, because the catalog now has a case for each and a second
# implementation would be a second thing to keep correct. Variant selects which
# hostile shape to return; FatEntryCount sizes the oversized directory the reader
# is steered onto -- the assertion passes a large value so the bypass is a real
# amplification, the catalog fixtures pass a small one because they only need the
# archive refused.
$script:scriptBlockNewTrailerBypassArchiveByte = {
    param (
        [Parameter(Mandatory = $true)]
        [ValidateSet('decoy', 'zip64')]
        [string]$Variant,

        [Parameter(Mandatory = $true)]
        [int]$FatEntryCount
    )

    $intFixtureEntryCount = @($script:arrCandidateExpectedName).Count
    $arrFatByte = & $script:scriptBlockNewArchiveByte -EntryName ([string[]]@(
            1..$FatEntryCount | ForEach-Object { 'fat{0}.txt' -f $_ }))
    $arrHonestByte = & $script:scriptBlockNewArchiveByte `
        -EntryName ([string[]]@($script:arrCandidateExpectedName))
    # Neither builder writes an archive comment, so each trailer is the final 22
    # bytes and its fields can be read without searching for it.
    $intFatTrailer = $arrFatByte.Length - 22
    $intHonestTrailer = $arrHonestByte.Length - 22
    $intFatCount = [int](& $script:scriptBlockReadArchiveUInt -Buffer $arrFatByte `
            -Index ($intFatTrailer + 10) -Width 2)
    $lngFatSize = & $script:scriptBlockReadArchiveUInt -Buffer $arrFatByte `
        -Index ($intFatTrailer + 12) -Width 4
    $lngFatOffset = & $script:scriptBlockReadArchiveUInt -Buffer $arrFatByte `
        -Index ($intFatTrailer + 16) -Width 4
    $lngHonestSize = & $script:scriptBlockReadArchiveUInt -Buffer $arrHonestByte `
        -Index ($intHonestTrailer + 12) -Width 4
    $lngHonestOffset = & $script:scriptBlockReadArchiveUInt -Buffer $arrHonestByte `
        -Index ($intHonestTrailer + 16) -Width 4
    if ($intFatCount -ne $FatEntryCount -or $intHonestTrailer -lt 1) {
        & $script:scriptBlockStopHarness `
            -Code 'catalog-invalid' -Detail 'trailer-fixture-fields'
    }

    # Fixture one: the honest four-entry directory sits after the fat one and is
    # described by a trailer that declares a 22-byte comment. Those 22 bytes are
    # a second trailer, at the highest offset a signature can occupy, declaring
    # a comment length no bytes satisfy. A scan that skips it on that ground
    # validates the honest directory; the reader takes it and builds the fat one.
    $objDecoyMemory = New-Object System.IO.MemoryStream
    $objDecoyMemory.Write($arrFatByte, 0, $intFatTrailer)
    $objDecoyMemory.Write($arrHonestByte, 0, $intHonestTrailer)
    $arrRealTrailer = New-Object byte[] 22
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrRealTrailer -Index 0 -Value 0x06054B50 -Width 4)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrRealTrailer -Index 8 `
            -Value $intFixtureEntryCount -Width 2)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrRealTrailer -Index 10 `
            -Value $intFixtureEntryCount -Width 2)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrRealTrailer -Index 12 -Value $lngHonestSize -Width 4)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrRealTrailer -Index 16 `
            -Value ($intFatTrailer + $lngHonestOffset) -Width 4)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrRealTrailer -Index 20 -Value 22 -Width 2)
    $objDecoyMemory.Write($arrRealTrailer, 0, 22)
    $arrDecoyTrailer = New-Object byte[] 22
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrDecoyTrailer -Index 0 -Value 0x06054B50 -Width 4)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrDecoyTrailer -Index 8 -Value $intFatCount -Width 2)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrDecoyTrailer -Index 10 -Value $intFatCount -Width 2)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrDecoyTrailer -Index 12 -Value $lngFatSize -Width 4)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrDecoyTrailer -Index 16 -Value $lngFatOffset -Width 4)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrDecoyTrailer -Index 20 -Value 5 -Width 2)
    $objDecoyMemory.Write($arrDecoyTrailer, 0, 22)
    $arrDecoyFile = $objDecoyMemory.ToArray()
    $objDecoyMemory.Dispose()

    # Fixture two: one trailer, honest counts, and both disk fields at 0xFFFF.
    # That is the reader's whole condition for consulting a Zip64 locator, and
    # the locator lives in the last 20 bytes of the fourth central directory
    # record's comment -- inside the span the record walk accounts for, so the
    # walk still lands exactly on the trailer.
    $intZip64Pad = 76
    $intLastRecord = [int]$lngHonestOffset
    $intPosition = [int]$lngHonestOffset
    for ($intRecord = 0; $intRecord -lt $intFixtureEntryCount; $intRecord++) {
        $intLastRecord = $intPosition
        $intPosition = $intPosition + 46 +
            [int](& $script:scriptBlockReadArchiveUInt -Buffer $arrHonestByte `
                    -Index ($intPosition + 28) -Width 2) +
            [int](& $script:scriptBlockReadArchiveUInt -Buffer $arrHonestByte `
                    -Index ($intPosition + 30) -Width 2) +
            [int](& $script:scriptBlockReadArchiveUInt -Buffer $arrHonestByte `
                    -Index ($intPosition + 32) -Width 2)
    }
    if ($intPosition -ne $intHonestTrailer) {
        & $script:scriptBlockStopHarness `
            -Code 'catalog-invalid' -Detail 'trailer-fixture-record-walk'
    }
    $arrHonestWork = $arrHonestByte.Clone()
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrHonestWork -Index ($intLastRecord + 32) `
            -Value $intZip64Pad -Width 2)
    $objZipMemory = New-Object System.IO.MemoryStream
    $objZipMemory.Write($arrFatByte, 0, $intFatTrailer)
    $objZipMemory.Write($arrHonestWork, 0, $intHonestTrailer)
    $lngZip64Record = $objZipMemory.Length
    $arrZip64Record = New-Object byte[] 56
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrZip64Record -Index 0 -Value 0x06064B50 -Width 4)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrZip64Record -Index 4 -Value 44 -Width 8)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrZip64Record -Index 12 -Value 45 -Width 2)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrZip64Record -Index 14 -Value 45 -Width 2)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrZip64Record -Index 24 -Value $intFatCount -Width 8)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrZip64Record -Index 32 -Value $intFatCount -Width 8)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrZip64Record -Index 40 -Value $lngFatSize -Width 8)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrZip64Record -Index 48 -Value $lngFatOffset -Width 8)
    $objZipMemory.Write($arrZip64Record, 0, 56)
    $arrZip64Locator = New-Object byte[] 20
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrZip64Locator -Index 0 -Value 0x07064B50 -Width 4)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrZip64Locator -Index 8 -Value $lngZip64Record -Width 8)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrZip64Locator -Index 16 -Value 1 -Width 4)
    $objZipMemory.Write($arrZip64Locator, 0, 20)
    $arrZip64Trailer = New-Object byte[] 22
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrZip64Trailer -Index 0 -Value 0x06054B50 -Width 4)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrZip64Trailer -Index 4 -Value 0xFFFF -Width 2)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrZip64Trailer -Index 6 -Value 0xFFFF -Width 2)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrZip64Trailer -Index 8 `
            -Value $intFixtureEntryCount -Width 2)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrZip64Trailer -Index 10 `
            -Value $intFixtureEntryCount -Width 2)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrZip64Trailer -Index 12 `
            -Value ($lngHonestSize + $intZip64Pad) -Width 4)
    [void](& $script:scriptBlockWriteArchiveUInt -Buffer $arrZip64Trailer -Index 16 `
            -Value ($intFatTrailer + $lngHonestOffset) -Width 4)
    $objZipMemory.Write($arrZip64Trailer, 0, 22)
    $arrZip64File = $objZipMemory.ToArray()
    $objZipMemory.Dispose()
    if ($Variant -ceq 'decoy') {
        return , $arrDecoyFile
    }
    return , $arrZip64File
}

# Recorded when the script loads, which is the earliest point the run exists.
$script:strCandidateRunStartedUtc = [System.DateTime]::UtcNow.ToString(
    'yyyy-MM-ddTHH:mm:ss.fffffffZ', [System.Globalization.CultureInfo]::InvariantCulture)
# Whether each adversarial trailer fixture is a live bypass is a property of the
# reader and differs by .NET version, so what this runtime actually observed is
# recorded rather than left implicit in a passing suite.
$script:arrCandidateFixtureClassification = @()

$script:scriptBlockAssertArchiveTrailerAgreementEnforced = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [string]$RunRoot
    )

    # The entry-count pre-check exists to bound what ZipArchive materializes, and
    # it can only do that if it inspects the same trailer ZipArchive will. Two
    # ways of breaking that agreement have already shipped in this file, so the
    # property is asserted here rather than trusted.
    #
    # System.IO.Compression locates the trailer by seeking to 18 bytes before the
    # end and taking the LAST occurrence of the signature at or before length-22,
    # searching at most 65539 further bytes. It then commits: no validation, no
    # second candidate. A pre-check that skips a candidate the reader would have
    # taken is therefore describing a different archive than the one about to be
    # parsed, and a pre-check that ignores the disk fields misses the Zip64
    # locator gate, which lets the reader replace the entry count and directory
    # offset outright with values from elsewhere in the file.
    #
    # Each fixture below is proven hostile before it is used as evidence: the
    # harness confirms that ZipArchive really does materialize more than the
    # manifest's four entries from those bytes. A fixture that stopped being a
    # bypass would otherwise keep passing while proving nothing, which is how an
    # earlier version of this file asserted a property it did not hold.
    $intFixtureEntryCount = @($script:arrCandidateExpectedName).Count
    $intFatEntryCount = 2000

    $arrDecoyFile = & $script:scriptBlockNewTrailerBypassArchiveByte `
        -Variant 'decoy' -FatEntryCount $intFatEntryCount
    $arrZip64File = & $script:scriptBlockNewTrailerBypassArchiveByte `
        -Variant 'zip64' -FatEntryCount $intFatEntryCount
    # The conforming control: the same four manifest entries, no bypass.
    $arrHonestByte = & $script:scriptBlockNewArchiveByte `
        -EntryName ([string[]]@($script:arrCandidateExpectedName))

    # Each hostile fixture must actually be hostile: the reader has to build more
    # than the manifest's entries from it, or refusing it proves nothing.
    $scriptBlockCountReaderEntry = {
        param ([byte[]]$ArchiveByte)
        $objStream = New-Object System.IO.MemoryStream(, $ArchiveByte)
        try {
            $objReader = New-Object System.IO.Compression.ZipArchive(
                $objStream,
                [System.IO.Compression.ZipArchiveMode]::Read,
                $true
            )
            try {
                $intSeen = 0
                foreach ($objReaderEntry in $objReader.Entries) { $intSeen++ }
                return $intSeen
            } finally {
                $objReader.Dispose()
            }
        } catch {
            return -1
        } finally {
            $objStream.Dispose()
        }
    }
    # Whether a fixture is a live bypass is a property of the reader, not of this
    # file, and the two do not agree across runtimes. Measured: .NET Framework
    # 4.8 and .NET 8 both materialize 2000 entries from each fixture, while
    # .NET 10 hardened the trailer scan and throws
    # "End of Central Directory record could not be found" on the decoy -- yet
    # still materializes 2000 from the Zip64 fixture. Production refuses all
    # four combinations, because the pre-check reads bytes rather than asking
    # the reader.
    #
    # So the regime is classified instead of assumed. A reader that materializes
    # more than the manifest allows means the bypass is live here and the
    # pre-check has to bound it. A reader that refuses the bytes outright has
    # reached the same verdict by itself, and the pre-check refusing them too is
    # agreement, not evidence of a bypass. What is never acceptable is a fixture
    # that degenerates into an ordinary readable archive: that is the shape a
    # fixture takes when it silently stops testing anything, which is exactly how
    # an earlier version of this file asserted a property it did not hold.
    #
    # Demanding a live bypass on every runtime was the alternative and was
    # rejected: it would turn a future framework hardening -- a security
    # improvement -- into a red suite, which is the wrong thing to reward.
    foreach ($strHostileVariant in @('decoy', 'zip64')) {
        $arrHostileByte = if ($strHostileVariant -ceq 'decoy') {
            $arrDecoyFile
        } else {
            $arrZip64File
        }
        # -1 means the reader threw rather than materializing anything.
        $intReaderSeen = [int](& $scriptBlockCountReaderEntry -ArchiveByte $arrHostileByte)
        $script:arrCandidateFixtureClassification += , ([ordered]@{
            Fixture = if ($strHostileVariant -ceq 'decoy') {
                'archive.trailer.decoy'
            } else {
                'archive.trailer.zip64-gate'
            }
            ReaderRefused = [bool]($intReaderSeen -lt 0)
            ReaderEntryCount = if ($intReaderSeen -lt 0) { $null } else { [uint32]$intReaderSeen }
        })
        if ($intReaderSeen -ge 0 -and $intReaderSeen -le $intFixtureEntryCount) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('reader-fixture-degenerate-' + $strHostileVariant + '-' + $intReaderSeen)
        }
    }
    $intHonestSeen = [int](& $scriptBlockCountReaderEntry -ArchiveByte $arrHonestByte)
    if ($intHonestSeen -ne $intFixtureEntryCount) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail ('reader-honest-count-' + $intHonestSeen)
    }

    $strProbeRoot = [System.IO.Path]::Combine($RunRoot, 'archive-trailer-agreement')
    [void][System.IO.Directory]::CreateDirectory($strProbeRoot)
    $strProbeCheckout = [System.IO.Path]::Combine($strProbeRoot, 'checkout')
    [void][System.IO.Directory]::CreateDirectory($strProbeCheckout)
    $strProbeTrusted = [System.IO.Path]::Combine($strProbeRoot, 'trusted')
    [void][System.IO.Directory]::CreateDirectory($strProbeTrusted)

    # Driven through the production entry point rather than the internal guard,
    # so no rewrite of the guard's shape can satisfy this without the archive
    # actually being refused before extraction.
    $scriptBlockRunProbeExpansion = {
        param (
            [byte[]]$ArchiveByte,
            [string]$ScriptPath
        )
        if ([string]::IsNullOrEmpty($ScriptPath)) {
            $ScriptPath = $LiteralPath
        }
        # Each call builds its own context, as the resource-guard probe does, so
        # one fixture's outcome cannot decide the next one's. The contexts are
        # left in place: they live under the harness run root, which is removed
        # when the run ends, and cleaning up a succeeded expansion here would
        # mean asserting on cleanup's result instead of the archive's.
        $objProbeContext = New-StyleGuideCandidateInvocationContext `
            -TrustedTemporaryRoot $strProbeTrusted
        $strProbeArchive = [System.IO.Path]::Combine(
            $objProbeContext.DownloadDirectoryPath, 'artifact.zip')
        [System.IO.File]::WriteAllBytes($strProbeArchive, $ArchiveByte)
        $objProbeSha256 = [System.Security.Cryptography.SHA256]::Create()
        try {
            $strProbeDigest = ([System.BitConverter]::ToString(
                    $objProbeSha256.ComputeHash($ArchiveByte)) -replace '-', ''
            ).ToLowerInvariant()
        } finally {
            $objProbeSha256.Dispose()
        }
        try {
            [void](& $ScriptPath `
                    -Context $objProbeContext `
                    -CheckoutRoot $strProbeCheckout `
                    -TrustedTemporaryRoot $strProbeTrusted `
                    -DownloadDirectory $objProbeContext.DownloadDirectoryPath `
                    -CandidateDirectory $objProbeContext.CandidatePath `
                    -ExpectedDigest $strProbeDigest)
            return 'accepted'
        } catch {
            return [string]$_.Exception.Data['PSStyleGuideDiagnosticCode']
        }
    }

    foreach ($strHostileVariant in @('decoy', 'zip64')) {
        $arrHostileByte = if ($strHostileVariant -ceq 'decoy') {
            $arrDecoyFile
        } else {
            $arrZip64File
        }
        $strOutcome = [string](& $scriptBlockRunProbeExpansion -ArchiveByte $arrHostileByte)
        if ($strOutcome -cnotin @('archive-invalid', 'manifest-invalid')) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('production-accepted-' + $strHostileVariant + '-' + $strOutcome)
        }
    }
    # Refusing everything would satisfy the rows above, so a conforming archive
    # is required to still expand.
    $strHonestOutcome = [string](& $scriptBlockRunProbeExpansion -ArchiveByte $arrHonestByte)
    if ($strHonestOutcome -cne 'accepted') {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail ('production-refused-honest-' + $strHonestOutcome)
    }

    # The rows above are necessary and nowhere near sufficient. The manifest's
    # own four-entry check rejects both fixtures as well, just after the reader
    # has already built the directory the pre-check exists to bound -- so an
    # expansion that fails proves only that something failed, and a regression
    # in the trailer scan would keep every row above green. Two further
    # assertions pin the part that matters.
    #
    # First: the pre-check itself, called on the same bytes, has to refuse them,
    # and has to accept a conforming archive. That is the property, stated
    # directly, with nothing downstream able to stand in for it.
    $scriptBlockTestPreCheckRefuses = {
        param ([byte[]]$ArchiveByte)
        $objProbeStream = New-Object System.IO.MemoryStream(, $ArchiveByte)
        try {
            [void](& $script:scriptBlockAssertCandidateHelperArchiveEntryCount `
                    -Stream $objProbeStream)
            return $false
        } catch {
            return $true
        } finally {
            $objProbeStream.Dispose()
        }
    }
    foreach ($strHostileVariant in @('decoy', 'zip64')) {
        $arrHostileByte = if ($strHostileVariant -ceq 'decoy') {
            $arrDecoyFile
        } else {
            $arrZip64File
        }
        if (-not (& $scriptBlockTestPreCheckRefuses -ArchiveByte $arrHostileByte)) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('precheck-accepted-' + $strHostileVariant)
        }
    }
    if (& $scriptBlockTestPreCheckRefuses -ArchiveByte $arrHonestByte) {
        & $script:scriptBlockStopHarness `
            -Code 'catalog-invalid' -Detail 'precheck-refused-honest'
    }

    # Second: a pre-check nothing calls refuses nothing, and no observation of
    # its return value can tell. So the guard's body is replaced by a throw in a
    # copy of the helper and a conforming expansion is driven through both
    # copies. The verbatim copy must succeed and the poisoned copy must fail; if
    # production stops reaching the guard, poisoning it changes nothing and both
    # succeed, which is the failure this asserts.
    $strGuardName = 'scriptBlockAssertCandidateHelperArchiveEntryCount'
    $objGuardTokens = $null
    $objGuardParseErrors = $null
    $objGuardAst = [System.Management.Automation.Language.Parser]::ParseFile(
        $LiteralPath,
        [ref]$objGuardTokens,
        [ref]$objGuardParseErrors
    )
    if ($null -eq $objGuardAst -or @($objGuardParseErrors).Count -ne 0) {
        & $script:scriptBlockStopHarness `
            -Code 'catalog-invalid' -Detail 'trailer-guard-parse'
    }
    $arrGuardAssignment = @($objGuardAst.FindAll(
            {
                param ($SyntaxNode)
                $SyntaxNode -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                $SyntaxNode.Left.Extent.Text -ceq ('$script:' + $strGuardName) -and
                $SyntaxNode.Right -is
                    [System.Management.Automation.Language.CommandExpressionAst] -and
                $SyntaxNode.Right.Expression -is
                    [System.Management.Automation.Language.ScriptBlockExpressionAst]
            },
            $true
        ))
    if ($arrGuardAssignment.Count -ne 1) {
        & $script:scriptBlockStopHarness `
            -Code 'catalog-invalid' -Detail 'trailer-guard-assignment'
    }
    $objGuardExtent = $arrGuardAssignment[0].Right.Expression.Extent
    $strGuardSource = [System.IO.File]::ReadAllText($LiteralPath)
    # A throw carrying no diagnostic code of its own: the helper maps it through
    # its own taxonomy, so this asserts only that the expansion failed and never
    # which text came back.
    $strGuardStub = "{`n" +
        "    param (`n" +
        "        [Parameter(ValueFromRemainingArguments = `$true)]`n" +
        "        [AllowNull()]`n" +
        "        [AllowEmptyCollection()]`n" +
        "        [object[]]`$Ignored`n" +
        "    )`n`n" +
        "    throw (New-Object System.InvalidOperationException('trailer-guard-probe'))`n" +
        "}`n"
    $objGuardEncoding = New-Object System.Text.UTF8Encoding($false)
    $strVerbatimPath = [System.IO.Path]::Combine($strProbeRoot, 'helper-verbatim.ps1')
    [System.IO.File]::WriteAllText($strVerbatimPath, $strGuardSource, $objGuardEncoding)
    $strPoisonedPath = [System.IO.Path]::Combine($strProbeRoot, 'helper-poisoned.ps1')
    [System.IO.File]::WriteAllText(
        $strPoisonedPath,
        $strGuardSource.Substring(0, $objGuardExtent.StartOffset) + $strGuardStub +
        $strGuardSource.Substring($objGuardExtent.EndOffset),
        $objGuardEncoding
    )
    $strVerbatimOutcome = [string](& $scriptBlockRunProbeExpansion `
            -ArchiveByte $arrHonestByte -ScriptPath $strVerbatimPath)
    $strPoisonedOutcome = [string](& $scriptBlockRunProbeExpansion `
            -ArchiveByte $arrHonestByte -ScriptPath $strPoisonedPath)
    if ($strVerbatimOutcome -cne 'accepted' -or $strPoisonedOutcome -ceq 'accepted') {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail ('trailer-guard-poison-' + $strVerbatimOutcome + '-' + $strPoisonedOutcome)
    }
}

# Round 15 bounded the enumerations that ask "does this directory hold exactly
# N entries?"; round 16 found one this sweep had missed; round 17 found that the
# check written for round 16 did not carry its own invariant.
#
# That check pinned an aggregate -- how many calls are unbounded, and whether
# each unbounded target is on an allow-list. Two pairs of call sites share a
# target expression while differing in boundedness, so moving -MaximumEntry from
# the bounded member of a pair to the unbounded one preserved both the count and
# the allow-list. Measured: the suite passed 115 of 115 with the cardinality read
# unbounded AND the absence proof reduced to a partial listing -- two defects at
# once, one of them a correctness bug, and the assertion silent.
#
# So boundedness is pinned per call site instead of in aggregate. The table below
# is every enumeration call in source order, and the check compares position by
# position. Swapping a bound between two sites reorders the table; adding,
# removing, or re-purposing a call breaks the comparison until the table is
# updated on purpose, which is the same discipline the round-15 site pin uses.
#
# The unbounded entries all prove a path ABSENT -- the chosen child name before
# creation, and the post-delete "is it really gone?" reads. A partial listing
# cannot establish absence, so bounding one of those would be a correctness
# regression, not a hardening, and this table refuses it in that direction too.
$script:arrCandidateEnumerationScriptBlockName = [string[]]@(
    'scriptBlockGetCandidateImmediateEntry',
    'scriptBlockGetCandidateHelperEntry'
)
# Bound records the exact expression each site passes, not merely that it passes
# one. Presence alone is satisfied by -MaximumEntry 0, which both helpers
# document as meaning unbounded, and by an arbitrarily large literal that bounds
# nothing in practice. $null means the site must pass no bound at all.
#
# Match records the same thing for -MatchPath, and the two together carry the
# rule this table exists to hold: every site is bounded XOR filtered. The sites
# that pass neither were the mistake -- a full parent listing to answer whether
# one named path exists, which an unrelated party sharing the directory could
# inflate at will. Both directions are wrong and both are refused: a site that
# drops its filter reads the whole parent again, and a site that gains one
# where a cardinality count is wanted would count only the filtered name.
$script:arrCandidateContextEnumerationSite = @(
    @{ Target = '$strTrustedParent'; Bound = $null; Match = '$strInvocationRoot' },
    @{ Target = '$strInvocationRoot'; Bound = '1'; Match = $null },
    @{ Target = '$strDownloadDirectory'; Bound = '1'; Match = $null },
    @{ Target = '$strInvocationRoot'; Bound = '2'; Match = $null },
    # Read off the validated plan rather than the caller's context, since round
    # 33. The context these three used to name is a caller-held object, and
    # every read of it is a fresh read: the manager validated one and enumerated
    # another. Pinning the plan spelling here is what stops that being undone.
    @{ Target = '$objCleanupPlan.InvocationRootPath'
        Bound = '($listExpectedRootEntries.Count + 1)'; Match = $null },
    @{ Target = '$objCleanupPlan.DownloadDirectoryPath'
        Bound = '($arrDownloadRecords.Count + 1)'; Match = $null },
    @{ Target = '$objCleanupPlan.CandidatePath'
        Bound = '($arrOwnedCandidateFiles.Count + 1)'; Match = $null },
    # Captured strings rather than record properties, since round 32: a record
    # is a property bag on a caller-held object, and a concurrent writer between
    # two reads makes a checked path and a deleted path two different things.
    # Round 33 carried the same capture up to the evidence phase, so these
    # strings now come off the plan the validator built. The site table follows
    # the code it pins.
    @{ Target = '$strDeleteParent'; Bound = $null; Match = '$strDeletePath' },
    @{ Target = '$strDeleteParent'; Bound = $null; Match = '$strDeletePath' }
)
$script:arrCandidateHelperEnumerationSite = @(
    @{ Target = '$strCanonical'; Bound = $null; Match = '$strComponentName' },
    @{ Target = '$strEntryParent'; Bound = $null; Match = '$strEntryName' },
    # The three candidate-cleanup sites moved to the context manager in round
    # 32, with the deletions they served.
    @{ Target = '$ParentPath'; Bound = $null; Match = '$ExpectedPath' },
    @{ Target = '$strDownloadPath'; Bound = '2'; Match = $null },
    @{ Target = '$strCandidatePath'; Bound = '1'; Match = $null },
    @{ Target = '$strCandidatePath'; Bound = '5'; Match = $null }
)

$script:scriptBlockAssertEnumerationBoundsDeclared = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$HelperLiteralPath,

        [Parameter(Mandatory = $true)]
        [string]$ContextLiteralPath
    )

    $arrScriptSite = @(
        @{ Path = $HelperLiteralPath; Site = $script:arrCandidateHelperEnumerationSite },
        @{ Path = $ContextLiteralPath; Site = $script:arrCandidateContextEnumerationSite }
    )
    foreach ($hashtableScript in $arrScriptSite) {
        $objErrors = $null
        $objAst = [System.Management.Automation.Language.Parser]::ParseFile(
            [string]$hashtableScript.Path, [ref]$null, [ref]$objErrors)
        if ($null -eq $objAst -or @($objErrors).Count -ne 0) {
            & $script:scriptBlockStopHarness `
                -Code 'catalog-invalid' -Detail 'enumeration-bounds-parse'
        }
        $arrCall = @($objAst.FindAll(
                {
                    param ($SyntaxNode)
                    $SyntaxNode -is [System.Management.Automation.Language.CommandAst] -and
                    @($SyntaxNode.CommandElements).Count -gt 0 -and
                    $SyntaxNode.CommandElements[0] -is
                        [System.Management.Automation.Language.VariableExpressionAst] -and
                    $script:arrCandidateEnumerationScriptBlockName -ccontains
                        ($SyntaxNode.CommandElements[0].VariablePath.UserPath -creplace
                            '^script:', '')
                },
                $true
            )) | Sort-Object -Property { $_.Extent.StartOffset }
        $arrExpectedSite = @($hashtableScript.Site)
        if (@($arrCall).Count -ne $arrExpectedSite.Count) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('enumeration-site-count-' + @($arrCall).Count)
        }
        for ($intSite = 0; $intSite -lt $arrExpectedSite.Count; $intSite++) {
            $objCall = @($arrCall)[$intSite]
            $strBoundText = $null
            $strMatchText = $null
            $strTargetText = ''
            for ($intIndex = 1; $intIndex -lt @($objCall.CommandElements).Count; $intIndex++) {
                $objElement = $objCall.CommandElements[$intIndex]
                if ($objElement -isnot
                    [System.Management.Automation.Language.CommandParameterAst]) {
                    continue
                }
                if ($objElement.ParameterName -ceq 'MaximumEntry' -and
                    ($intIndex + 1) -lt @($objCall.CommandElements).Count) {
                    $strBoundText = [string]$objCall.CommandElements[$intIndex + 1].Extent.Text
                }
                if ($objElement.ParameterName -ceq 'MatchPath' -and
                    ($intIndex + 1) -lt @($objCall.CommandElements).Count) {
                    $strMatchText = [string]$objCall.CommandElements[$intIndex + 1].Extent.Text
                }
                if ($objElement.ParameterName -ceq 'LiteralPath' -and
                    ($intIndex + 1) -lt @($objCall.CommandElements).Count) {
                    $strTargetText = [string]$objCall.CommandElements[$intIndex + 1].Extent.Text
                }
            }
            if ($strTargetText -cne [string]$arrExpectedSite[$intSite].Target) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                    -Detail ('enumeration-site-target-' + $intSite + '-' + $strTargetText)
            }
            $objExpectedBound = $arrExpectedSite[$intSite].Bound
            if ($null -eq $objExpectedBound) {
                if ($null -ne $strBoundText) {
                    & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                        -Detail ('enumeration-site-bound-' + $intSite + '-' + $strTargetText)
                }
            } elseif ($strBoundText -cne [string]$objExpectedBound) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                    -Detail ('enumeration-site-bound-' + $intSite + '-' + $strTargetText)
            }
            $objExpectedMatch = $arrExpectedSite[$intSite].Match
            if ($null -eq $objExpectedMatch) {
                if ($null -ne $strMatchText) {
                    & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                        -Detail ('enumeration-site-match-' + $intSite + '-' + $strTargetText)
                }
            } elseif ($strMatchText -cne [string]$objExpectedMatch) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                    -Detail ('enumeration-site-match-' + $intSite + '-' + $strTargetText)
            }
            # The table is only as good as the rule it encodes, so the rule is
            # asserted against the table as well: a future editor who adds a row
            # with neither a bound nor a filter has written down the very defect
            # this check exists to refuse, and one carrying both has written a
            # named absence proof that reads a partial listing.
            if (($null -eq $objExpectedBound) -eq ($null -eq $objExpectedMatch)) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                    -Detail ('enumeration-site-exclusive-' + $intSite + '-' + $strTargetText)
            }
        }
    }
}

# The table above governs calls to the enumeration helpers. It says nothing
# about a directory listing that does not go through one, and for two rounds it
# could not have: the check matches CommandAst nodes naming a helper, so a
# static [System.IO.Directory]::EnumerateDirectories call is not an unpinned
# site but an invisible one. Two of those sat in the Windows identity
# resolution. Measured -- rewriting one of them to list the whole parent and
# post-filter in the pipeline left the suite at 113 passes and zero failures,
# reinstating the unbounded read the table exists to refuse, one file away from
# the table itself.
#
# Adding a second table for direct calls would have pinned the two that exist
# and nothing about the third someone writes later, so the rule here is
# exclusivity instead: a directory listing may appear ONLY inside an enumeration
# helper's own definition. That makes the site table complete by construction --
# every remaining listing is a helper call, and every helper call is a row --
# and it is the difference between detecting this defect and being unable to
# spell it.
#
# Matching is by member NAME rather than by receiver type, because the receiver
# is what varies: Directory::EnumerateFiles and a DirectoryInfo instance's
# EnumerateFiles list the same directory and only one of them names a type the
# parser can resolve.
#
# The command dimension is handled the other way round, and the first attempt at
# it is why. That attempt named the commands a script may NOT call -- Get-ChildItem
# and its aliases -- and a deny-list is only ever as complete as the imagination
# behind it. Measured: `Get-Item -Path (Join-Path $dir '*')` lists the whole
# directory, is named by none of those, and left the suite green at 113 passes
# with a shadow whole-parent read in place. Resolve-Path does the same.
#
# So the commands are allow-listed instead, per script and in full. Anything not
# on the list fails, which closes Get-Item, Resolve-Path, and every spelling
# nobody has thought of yet in one rule rather than one row per name. That is
# affordable here only because the surface is genuinely small -- measured at
# eight distinct commands in the helper and seven in the context manager, in
# scripts that reach for .NET rather than cmdlets -- and it is deliberately NOT
# extended to member names, where the surface is 48 and 37 and a pin would fail
# the suite the first time somebody wrote .Trim(). Refusing legitimate work is
# the round-19 defect, and it does not become acceptable by being a test.
#
# Reflection is denied everywhere rather than outside the helper, because it is
# the generic escape from any rule that matches a name: GetMethod('...').Invoke()
# reaches a listing without ever spelling one. Neither script uses it.
$script:strCandidateListingMemberPattern =
    '^(Enumerate|Get)(Directories|Files|FileSystemEntries|FileSystemInfos)$'
$script:strCandidateReflectionMemberPattern =
    '^(GetMethods?|GetPropert(y|ies)|GetFields?|GetMembers?|InvokeMember|GetConstructors?|CreateInstance)$'
# The only variables a nameless command may invoke besides the internal script
# blocks: absolute native paths this code resolved itself. Measured, that is one
# name per script today.
$script:arrCandidateNativePathVariable = [string[]]@(
    'strStatPath'
)
# ...and the one scriptblock a value reaching such a variable may come from.
# Naming the variable was never enough: the script-block targets get a
# reaching-value check and these did not, so `$strStatPath = 'Get-Item'`
# followed by `& $strStatPath -Path "$dir/*"` would perform an unbounded
# listing while the command allow-list saw no named Get-Item. This is the
# round-26 lesson -- admit by where the value came from, not by what the
# variable is called -- applied to the list it was never applied to.
$script:strCandidateHelperNativeResolver = 'scriptBlockResolveCandidateHelperNativePath'
$script:strCandidateContextNativeResolver = 'scriptBlockResolveCandidateNativePath'
$script:arrCandidateHelperPermittedCommand = [string[]]@(
    'Add-Type',
    'Get-Command',
    'New-Object',
    'Remove-StyleGuideCandidateInvocationContext',
    'Remove-StyleGuideCandidateInvocationState',
    'Set-StrictMode',
    'Sort-Object',
    'Test-StyleGuideCandidateInvocationContextIssued',
    'Where-Object'
)
# True when every self-closure assignment to a variable has a script-block
# literal assignment to that same variable EARLIER in the file. Written as a
# helper because the check needs statement space that a filter expression
# cannot give it -- the first attempt at this reached for $_.Group from inside
# a nested filter, where $_ is one assignment rather than the group, and was
# discarded rather than shipped.
$script:scriptBlockTestSelfClosureSourced = {
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [object[]]$Assignment
    )

    $scriptBlockHasLiteral = {
        param ($SyntaxNode)
        return ($null -ne $SyntaxNode.Right.Find(
            {
                param ($InnerSyntaxNode)
                $InnerSyntaxNode -is
                    [System.Management.Automation.Language.ScriptBlockExpressionAst]
            },
            $false
        ))
    }
    foreach ($objSelf in $Assignment) {
        $strSelfName = [string]$objSelf.Left.VariablePath.UserPath
        if (([string]$objSelf.Right.Extent.Text) -cne ('$' + $strSelfName + '.GetNewClosure()')) {
            continue
        }
        # Round 52, EE1: an earlier offset was the whole test, so a literal
        # inside `if ($false) { $x = {} }` counted as the source while the
        # closure at runtime captured whatever a caller had put in $x. Source
        # order is not reachability, and this routine was treating them as the
        # same thing.
        #
        # Sharing a parent statement block is the property that was actually
        # meant: the literal and the closure that preserves it run under the
        # same condition, which for production is no condition at all. A
        # literal nested in any branch has a different parent and no longer
        # counts. This is an exact-shape test rather than a reachability
        # analysis, which is deliberate -- the file already knows what shape
        # it writes, and inferring reachability is how the last four rules
        # here were escaped.
        $boolPrecededByLiteral = $false
        foreach ($objOther in $Assignment) {
            if ([int]$objOther.Extent.StartOffset -ge [int]$objSelf.Extent.StartOffset) {
                continue
            }
            if (-not [System.Object]::ReferenceEquals($objOther.Parent, $objSelf.Parent)) {
                continue
            }
            if (& $scriptBlockHasLiteral $objOther) {
                $boolPrecededByLiteral = $true
            }
        }
        if (-not $boolPrecededByLiteral) {
            return $false
        }
    }
    return $true
}

$script:arrCandidateContextPermittedCommand = [string[]]@(
    'ForEach-Object',
    'New-Object',
    'Remove-StyleGuideCandidateInvocationContext',
    # Round 41: this file severs the names its private registers were reachable
    # through, because a dot-sourced script creates them in the CALLER's scope.
    # Constrained in round 46 to exactly those three names -- see the argument
    # rule below. Allow-listing the command outright would have let a future
    # change unbind a script-block or native-path variable before an
    # already-admitted `& $x`, so the lookup falls through to caller state
    # while the harness still reports the call as internal.
    'Remove-Variable',
    'Set-Item',
    'Set-StrictMode',
    'Sort-Object',
    'Where-Object'
)
# Set-Item can rebind a NAME. Production uses it for exactly two Function:
# paths, so those two are the whole permitted surface. Without this,
# `Set-Item Variable:x 'Get-Item'` mutates an admitted script-block variable
# through the provider without producing an assignment for the reaching-value
# rule to see, and `& $x -Path "$dir/*"` is then a permitted nameless call that
# performs an unbounded listing.
$script:arrCandidateContextPermittedSetItemPath = [string[]]@(
    'Function:\New-StyleGuideCandidateInvocationContext',
    'Function:\Remove-StyleGuideCandidateInvocationContext',
    'Function:\Test-StyleGuideCandidateInvocationContextIssued'
)
# And what may be written to them. The destination was pinned a round before
# the payload was, which left the half that actually runs unexamined.
$script:arrCandidateContextPermittedSetItemValue = [string[]]@(
    'scriptBlockNewContextFunction',
    'scriptBlockRemoveContextFunction',
    'scriptBlockTestContextFunction'
)
# Every member either script invokes, by name. This is an allow-list because
# the surface is enumerable and was measured to be: 48 names in the helper and
# 44 in the context manager, none of them computed. The deny-lists above match
# what a listing or a reflection call is CALLED, which can only ever enumerate
# mechanisms someone thought of -- and two were missed. Commands supplied as
# data to [System.Management.Automation.PowerShell] reach a listing without
# naming one: Create, AddCommand('Get-Item'), AddParameter('Path', "$dir/*"),
# Invoke. Of those, only Create appears below, so the chain cannot be written.
# The same closes $ExecutionContext.InvokeCommand.InvokeScript(...), which no
# deny-list here mentioned either.
#
# Adding a member to production means adding it here. That is the cost of an
# allow-list and it is the point: a new name is a deliberate act, reviewed,
# rather than something that arrives with a refactor.
# Round 52, EE3. The allow-lists below name a MEMBER, and a name says nothing
# about what it is called on. `Delete` is on the helper's list because
# production calls [System.IO.File]::Delete and [System.IO.Directory]::Delete;
# the same entry admitted `$objDirectoryInfo.Delete($true)`, which is a
# RECURSIVE INSTANCE delete of a caller-controlled path. Same name, opposite
# behaviour, and the list could not tell them apart.
#
# So each name is additionally pinned to the receiver forms production actually
# uses. This table is generated from the two scripts rather than written by
# hand -- every static receiver type and whether the name is ever used as an
# instance call was read out of their parse trees, so it records what the code
# does rather than what someone remembered it doing.
#
# A name on a permitted list but absent from this table is refused: adding a
# member now means declaring how it is called, not just that it is.
# Self-audit after the fix above: the first version of this table was ONE
# map shared by both scripts, built from their union. That quietly widened
# each file by the other's usage -- measured, Expand gained an instance
# `Create` because Manage makes one, and Manage gained an instance
# `ToString` because Expand makes one. A permitted-member list is already
# per-file for exactly this reason, and the receiver table has to be too.
$script:hashtableCandidateHelperMemberReceiver = @{
    'Add' = @{ Static = [string[]]@(); Instance = $true }
    'Append' = @{ Static = [string[]]@(); Instance = $true }
    'Combine' = @{ Static = [string[]]@('System.IO.Path'); Instance = $false }
    'ComputeHash' = @{ Static = [string[]]@(); Instance = $true }
    'Contains' = @{ Static = [string[]]@(); Instance = $true }
    'ContainsKey' = @{ Static = [string[]]@(); Instance = $true }
    'ContainsWildcardCharacters' = @{
        Static = [string[]]@(
            'System.Management.Automation.WildcardPattern'
        )
        Instance = $false
    }
    'Copy' = @{ Static = [string[]]@('System.Array'); Instance = $false }
    'Create' = @{ Static = [string[]]@('System.Security.Cryptography.SHA256'); Instance = $false }
    'CreateDirectory' = @{ Static = [string[]]@('System.IO.Directory'); Instance = $false }
    'Delete' = @{ Static = [string[]]@('System.IO.File'); Instance = $false }
    'Dispose' = @{ Static = [string[]]@(); Instance = $true }
    'EnumerateFileSystemEntries' = @{ Static = [string[]]@('System.IO.Directory'); Instance = $false }
    'Equals' = @{ Static = [string[]]@('System.String'); Instance = $false }
    'Exists' = @{ Static = [string[]]@('System.IO.File'); Instance = $false }
    'Flush' = @{ Static = [string[]]@(); Instance = $true }
    'GetAttributes' = @{ Static = [string[]]@('System.IO.File'); Instance = $false }
    'GetEnumerator' = @{ Static = [string[]]@(); Instance = $true }
    'GetFileName' = @{ Static = [string[]]@('System.IO.Path'); Instance = $false }
    'GetFullPath' = @{ Static = [string[]]@('System.IO.Path'); Instance = $false }
    'GetInvalidFileNameChars' = @{ Static = [string[]]@('System.IO.Path'); Instance = $false }
    'GetType' = @{ Static = [string[]]@(); Instance = $true }
    'IndexOf' = @{ Static = [string[]]@(); Instance = $true }
    'IndexOfAny' = @{ Static = [string[]]@(); Instance = $true }
    'Insert' = @{ Static = [string[]]@(); Instance = $true }
    'IsControl' = @{ Static = [string[]]@('System.Char'); Instance = $false }
    'IsLetter' = @{ Static = [string[]]@('System.Char'); Instance = $false }
    'IsNullOrWhiteSpace' = @{ Static = [string[]]@('System.String'); Instance = $false }
    'IsPathRooted' = @{ Static = [string[]]@('System.IO.Path'); Instance = $false }
    'Min' = @{ Static = [string[]]@('System.Math'); Instance = $false }
    'MoveNext' = @{ Static = [string[]]@(); Instance = $true }
    'NewGuid' = @{ Static = [string[]]@('System.Guid'); Instance = $false }
    'Open' = @{ Static = [string[]]@(); Instance = $true }
    'Read' = @{ Static = [string[]]@(); Instance = $true }
    'ReadAllLines' = @{ Static = [string[]]@('System.IO.File'); Instance = $false }
    'ReferenceEquals' = @{ Static = [string[]]@('System.Object'); Instance = $false }
    'Split' = @{ Static = [string[]]@(); Instance = $true }
    'StartsWith' = @{ Static = [string[]]@(); Instance = $true }
    'Substring' = @{ Static = [string[]]@(); Instance = $true }
    'ToArray' = @{ Static = [string[]]@(); Instance = $true }
    'ToCharArray' = @{ Static = [string[]]@(); Instance = $true }
    'ToInt32' = @{ Static = [string[]]@('System.Convert'); Instance = $false }
    'ToLowerInvariant' = @{ Static = [string[]]@(); Instance = $true }
    'ToString' = @{ Static = [string[]]@('System.BitConverter'); Instance = $true }
    'TransformBlock' = @{ Static = [string[]]@(); Instance = $true }
    'TransformFinalBlock' = @{ Static = [string[]]@(); Instance = $true }
    'TrimEnd' = @{ Static = [string[]]@(); Instance = $true }
    'Write' = @{ Static = [string[]]@(); Instance = $true }
    'WriteAllBytes' = @{ Static = [string[]]@('System.IO.File'); Instance = $false }
}

$script:hashtableCandidateContextMemberReceiver = @{
    'Add' = @{ Static = [string[]]@(); Instance = $true }
    'AddAccessRule' = @{ Static = [string[]]@(); Instance = $true }
    'Combine' = @{ Static = [string[]]@('System.IO.Path'); Instance = $false }
    'Contains' = @{ Static = [string[]]@(); Instance = $true }
    'ContainsKey' = @{ Static = [string[]]@(); Instance = $true }
    'ContainsWildcardCharacters' = @{
        Static = [string[]]@(
            'System.Management.Automation.WildcardPattern'
        )
        Instance = $false
    }
    'Create' = @{
        Static = [string[]]@(
            'System.IO.FileSystemAclExtensions',
            'System.Security.Cryptography.SHA256'
        )
        Instance = $true
    }
    'CreateDirectory' = @{ Static = [string[]]@('System.IO.Directory'); Instance = $false }
    'Delete' = @{ Static = [string[]]@('System.IO.Directory', 'System.IO.File'); Instance = $false }
    'Dispose' = @{ Static = [string[]]@(); Instance = $true }
    'EnumerateFileSystemEntries' = @{ Static = [string[]]@('System.IO.Directory'); Instance = $false }
    'Equals' = @{ Static = [string[]]@('System.String'); Instance = $false }
    'GetAttributes' = @{ Static = [string[]]@('System.IO.File'); Instance = $false }
    'GetCurrent' = @{ Static = [string[]]@('System.Security.Principal.WindowsIdentity'); Instance = $false }
    'GetEnumerator' = @{ Static = [string[]]@(); Instance = $true }
    'GetFileName' = @{ Static = [string[]]@('System.IO.Path'); Instance = $false }
    'GetFullPath' = @{ Static = [string[]]@('System.IO.Path'); Instance = $false }
    'GetInvalidFileNameChars' = @{ Static = [string[]]@('System.IO.Path'); Instance = $false }
    'GetNewClosure' = @{ Static = [string[]]@(); Instance = $true }
    'GetRandomFileName' = @{ Static = [string[]]@('System.IO.Path'); Instance = $false }
    'GetResolvedProviderPathFromPSPath' = @{ Static = [string[]]@(); Instance = $true }
    'GetType' = @{ Static = [string[]]@(); Instance = $true }
    'IndexOf' = @{ Static = [string[]]@(); Instance = $true }
    'IndexOfAny' = @{ Static = [string[]]@(); Instance = $true }
    'Insert' = @{ Static = [string[]]@(); Instance = $true }
    'IsControl' = @{ Static = [string[]]@('System.Char'); Instance = $false }
    'IsLetter' = @{ Static = [string[]]@('System.Char'); Instance = $false }
    'IsNullOrWhiteSpace' = @{ Static = [string[]]@('System.String'); Instance = $false }
    'IsPathRooted' = @{ Static = [string[]]@('System.IO.Path'); Instance = $false }
    'MoveNext' = @{ Static = [string[]]@(); Instance = $true }
    'NewGuid' = @{ Static = [string[]]@('System.Guid'); Instance = $false }
    'Read' = @{ Static = [string[]]@(); Instance = $true }
    'ReferenceEquals' = @{ Static = [string[]]@('System.Object'); Instance = $false }
    # Round 73: scriptBlockDeregisterCandidateContext removes a never-returned
    # context from the three private issuance ArrayLists on creation failure.
    # Instance only, like Add, on lists this manager owns.
    'RemoveAt' = @{ Static = [string[]]@(); Instance = $true }
    'SetAccessRuleProtection' = @{ Static = [string[]]@(); Instance = $true }
    'Split' = @{ Static = [string[]]@(); Instance = $true }
    'Substring' = @{ Static = [string[]]@(); Instance = $true }
    'ToArray' = @{ Static = [string[]]@(); Instance = $true }
    'ToCharArray' = @{ Static = [string[]]@(); Instance = $true }
    'ToInt32' = @{ Static = [string[]]@('System.Convert'); Instance = $false }
    'ToLowerInvariant' = @{ Static = [string[]]@(); Instance = $true }
    'ToObject' = @{ Static = [string[]]@('System.Enum'); Instance = $false }
    'ToString' = @{ Static = [string[]]@('System.BitConverter'); Instance = $false }
    'TransformBlock' = @{ Static = [string[]]@(); Instance = $true }
    'TransformFinalBlock' = @{ Static = [string[]]@(); Instance = $true }
    'TrimEnd' = @{ Static = [string[]]@(); Instance = $true }
}

$script:arrCandidateHelperPermittedMember = [string[]]@(
    'Add', 'Append', 'Combine', 'ComputeHash', 'Contains', 'ContainsKey',
    'ContainsWildcardCharacters', 'Copy', 'Create', 'CreateDirectory',
    'Delete', 'Dispose', 'EnumerateFileSystemEntries', 'Equals', 'Exists',
    'Flush', 'GetAttributes', 'GetEnumerator', 'GetFileName', 'GetFullPath',
    'GetInvalidFileNameChars', 'GetType', 'IndexOf', 'IndexOfAny', 'Insert',
    'IsControl', 'IsLetter', 'IsNullOrWhiteSpace', 'IsPathRooted', 'Min',
    'MoveNext', 'NewGuid', 'Open', 'Read', 'ReadAllLines', 'ReferenceEquals',
    'Split',
    'StartsWith', 'Substring', 'ToArray', 'ToCharArray', 'ToInt32',
    'ToLowerInvariant', 'ToString', 'TransformBlock', 'TransformFinalBlock',
    'TrimEnd', 'Write', 'WriteAllBytes'
)
$script:arrCandidateContextPermittedMember = [string[]]@(
    'Add', 'AddAccessRule', 'Combine', 'Contains', 'ContainsKey',
    'ContainsWildcardCharacters', 'Create', 'CreateDirectory', 'Delete',
    'Dispose', 'EnumerateFileSystemEntries', 'Equals', 'GetAttributes',
    'GetCurrent', 'GetEnumerator', 'GetFileName', 'GetFullPath',
    'GetInvalidFileNameChars', 'GetNewClosure', 'GetRandomFileName',
    'GetResolvedProviderPathFromPSPath', 'GetType', 'IndexOf', 'IndexOfAny',
    'Insert', 'IsControl', 'IsLetter', 'IsNullOrWhiteSpace', 'IsPathRooted',
    'MoveNext', 'NewGuid', 'Read', 'ReferenceEquals', 'RemoveAt',
    'SetAccessRuleProtection',
    'Split',
    'Substring', 'ToArray', 'ToCharArray', 'ToInt32', 'ToLowerInvariant',
    'ToObject', 'ToString', 'TransformBlock', 'TransformFinalBlock', 'TrimEnd'
)
$script:scriptBlockAssertEnumerationPrimitiveExclusive = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$HelperLiteralPath,

        [Parameter(Mandatory = $true)]
        [string]$ContextLiteralPath
    )

    $arrScriptSurface = @(
        @{ Path = $HelperLiteralPath
            Command = $script:arrCandidateHelperPermittedCommand
            Member = $script:arrCandidateHelperPermittedMember
            SetItemPath = [string[]]@()
            SetItemValue = [string[]]@()
            SingleUseMember = @{ GetResolvedProviderPathFromPSPath = 0 }
            NativeResolver = $script:strCandidateHelperNativeResolver
            MemberReceiver = $script:hashtableCandidateHelperMemberReceiver },
        @{ Path = $ContextLiteralPath
            Command = $script:arrCandidateContextPermittedCommand
            Member = $script:arrCandidateContextPermittedMember
            SetItemPath = $script:arrCandidateContextPermittedSetItemPath
            SetItemValue = $script:arrCandidateContextPermittedSetItemValue
            SingleUseMember = @{ GetResolvedProviderPathFromPSPath = 1 }
            NativeResolver = $script:strCandidateContextNativeResolver
            MemberReceiver = $script:hashtableCandidateContextMemberReceiver }
    )
    foreach ($hashtableSurface in $arrScriptSurface) {
        $strScriptPath = [string]$hashtableSurface.Path
        $objErrors = $null
        $objAst = [System.Management.Automation.Language.Parser]::ParseFile(
            $strScriptPath, [ref]$null, [ref]$objErrors)
        if ($null -eq $objAst -or @($objErrors).Count -ne 0) {
            & $script:scriptBlockStopHarness `
                -Code 'catalog-invalid' -Detail 'enumeration-primitive-parse'
        }
        # The variables this file actually defines as script blocks. An earlier
        # revision matched the NAME instead -- anything starting 'scriptBlock' --
        # which is a convention rather than a property: measured, assigning a
        # command name to a variable called $scriptBlockListing and invoking it
        # performed an unbounded directory read and left the suite green at 113
        # passes. What the rule means is "invokes an internal script block", so
        # that is what is checked.
        $arrScriptBlockVariable = [string[]]@(@($objAst.FindAll(
                    {
                        param ($SyntaxNode)
                        $SyntaxNode -is
                            [System.Management.Automation.Language.AssignmentStatementAst] -and
                        $SyntaxNode.Left -is
                            [System.Management.Automation.Language.VariableExpressionAst] -and
                        $true
                    },
                    $true
                )) | Group-Object -Property {
                    [string]$_.Left.VariablePath.UserPath -creplace '^script:', ''
                } | Where-Object {
                    # EVERY assignment, not merely one. Recording that a script
                    # block was assigned somewhere admitted a variable that was
                    # later overwritten with a command name -- measured,
                    # `$x = {}` then `$x = 'Get-Item'` then `& $x` performed an
                    # unbounded listing and left the suite green at 113 passes.
                    # Which assignment reaches the call is not decidable here, so
                    # the admissible set is narrowed to variables that can only
                    # ever hold a script block.
                    @($_.Group | Where-Object {
                        # A script-block literal, or the variable closing over
                        # itself. The second shape was added in round 41: a
                        # helper that reads this file's private registers has to
                        # carry them in a closure, or `&` resolves them at call
                        # time against a DOT-SOURCED scope the caller shares.
                        # `$x = $x.GetNewClosure()` cannot change what $x holds
                        # from a script block into anything else -- the source is
                        # the variable itself -- so it is admitted by that exact
                        # shape rather than by naming the variable.
                        $strRight = [string]$_.Right.Extent.Text
                        $strSelf = [string]$_.Left.VariablePath.UserPath
                        $boolSelfClosure = $strRight -ceq
                            ('$' + $strSelf + '.GetNewClosure()')
                        $boolLiteral = $null -ne $_.Right.Find(
                            {
                                param ($InnerSyntaxNode)
                                $InnerSyntaxNode -is
                                    [System.Management.Automation.Language.ScriptBlockExpressionAst]
                            },
                            $false
                        )
                        -not ($boolLiteral -or $boolSelfClosure)
                    }).Count -eq 0 -and
                    # ...and a literal must PRECEDE every self-closure of it.
                    # A variable whose only assignment is `$x = $x.GetNewClosure()`
                    # has no source in this file: in a dot-sourced script the
                    # value it closes over comes from the CALLER's scope, so
                    # admitting it would let `& $x` invoke caller-supplied code
                    # while the rule reported an internal script block. The
                    # self-closure form preserves what a variable holds; it
                    # cannot establish it.
                    #
                    # Counting literals anywhere in the file is not enough: one
                    # appearing LATER, or in a branch that never runs, would
                    # satisfy the count while the self-closure and the
                    # invocation both used the caller's value. Position is what
                    # makes a capture meaningful, so position is what is checked.
                    (& $script:scriptBlockTestSelfClosureSourced -Assignment @($_.Group))
                } | ForEach-Object { [string]$_.Name })

        # The native-path variables whose EVERY assignment came from the
        # declared resolver, or is $null. A name on the list is a candidate,
        # not an admission.
        $arrNativePathVariable = [string[]]@(@($objAst.FindAll(
                    {
                        param ($SyntaxNode)
                        return ($SyntaxNode -is
                            [System.Management.Automation.Language.AssignmentStatementAst] -and
                            $SyntaxNode.Left -is
                            [System.Management.Automation.Language.VariableExpressionAst])
                    },
                    $true
                )) | Where-Object {
                    $script:arrCandidateNativePathVariable -ccontains
                        ([string]$_.Left.VariablePath.UserPath -creplace '^script:', '')
                } | Group-Object -Property {
                    [string]$_.Left.VariablePath.UserPath -creplace '^script:', ''
                } | Where-Object {
                    @($_.Group | Where-Object {
                        $strResolver = [string]$hashtableSurface.NativeResolver
                        # Round 52, EE4: a recursive Find meant the right-hand
                        # side only had to MENTION the resolver somewhere, so
                        #   $strStatPath = if ($false) { & $resolver ... }
                        #                  else { 'Get-Item' }
                        # was classified as resolver-sourced and the nameless
                        # `& $strStatPath -Path "$dir/*"` that followed was
                        # admitted. A mention is not a source.
                        #
                        # Production writes exactly one shape:
                        #   [string](& $resolver -CandidatePath ...)
                        # so that shape is what is accepted, cast optional, and
                        # every other right-hand side fails by not being it.
                        $objRight = $_.Right
                        if ($objRight -is
                            [System.Management.Automation.Language.CommandExpressionAst]) {
                            $objRight = $objRight.Expression
                        }
                        if ($objRight -is
                            [System.Management.Automation.Language.ConvertExpressionAst]) {
                            $objRight = $objRight.Child
                        }
                        $boolFromResolver = $false
                        if ($objRight -is
                            [System.Management.Automation.Language.ParenExpressionAst]) {
                            $objPipeline = $objRight.Pipeline
                            if ($objPipeline -is
                                [System.Management.Automation.Language.PipelineAst] -and
                                @($objPipeline.PipelineElements).Count -eq 1) {
                                $objCommand = @($objPipeline.PipelineElements)[0]
                                if ($objCommand -is
                                    [System.Management.Automation.Language.CommandAst]) {
                                    $arrResolverElement = @($objCommand.CommandElements)
                                    if ($arrResolverElement.Count -ge 1 -and
                                        $arrResolverElement[0] -is
                                        [System.Management.Automation.Language.VariableExpressionAst] -and
                                        (([string]$arrResolverElement[0].VariablePath.UserPath) `
                                            -creplace '^script:', '') -ceq $strResolver) {
                                        $boolFromResolver = $true
                                    }
                                }
                            }
                        }
                        $boolNullLiteral = ([string]$_.Right.Extent.Text) -ceq '$null'
                        -not ($boolFromResolver -or $boolNullLiteral)
                    }).Count -eq 0
                } | ForEach-Object { [string]$_.Name })

        # A third admissible class, added in round 35: a variable whose every
        # assignment is this file capturing one of its OWN function definitions
        # at load time. Round 34 established the need -- a rollback that resolves
        # a public name can be answered by a fake -- and that the obvious
        # spelling at the call site, ${function:Name}, is not a fix, because it
        # reads the same Function: provider a rebinder writes to. The load-time
        # capture IS a fix, because this script's body runs before any caller
        # can rebind anything.
        #
        # Admitted by the exact shape rather than by variable name, so the rule
        # cannot be satisfied by calling a variable something suggestive: every
        # assignment must be ${function:<Name>}.GetNewClosure() for a function
        # THIS FILE defines. A capture of some other file's function, or a bare
        # ${function:...} without the closure, is not on the list.
        $arrOwnFunctionName = [string[]]@(@($objAst.FindAll(
                    {
                        param ($SyntaxNode)
                        $SyntaxNode -is
                            [System.Management.Automation.Language.FunctionDefinitionAst]
                    },
                    $true
                )) | ForEach-Object { [string]$_.Name })
        $arrOwnClosureVariable = [string[]]@(@($objAst.FindAll(
                    {
                        param ($SyntaxNode)
                        return ($SyntaxNode -is
                            [System.Management.Automation.Language.AssignmentStatementAst] -and
                            $SyntaxNode.Left -is
                            [System.Management.Automation.Language.VariableExpressionAst])
                    },
                    $true
                )) | Group-Object -Property {
                    [string]$_.Left.VariablePath.UserPath -creplace '^script:', ''
                } | Where-Object {
                    @($_.Group | Where-Object {
                        $strRight = [string]$_.Right.Extent.Text
                        $boolOwnCapture = $false
                        foreach ($strOwnName in $arrOwnFunctionName) {
                            if ($strRight -ceq
                                ('${function:' + $strOwnName + '}.GetNewClosure()')) {
                                $boolOwnCapture = $true
                            }
                        }
                        -not $boolOwnCapture
                    }).Count -eq 0
                } | ForEach-Object { [string]$_.Name })

        # Every named command in the file, against the allow-list. A call
        # through a variable -- `& $script:scriptBlockFoo` -- has no command
        # name and is not one of these; those are the internal script blocks the
        # site table already governs.
        foreach ($objCommand in @($objAst.FindAll(
                    {
                        param ($SyntaxNode)
                        $SyntaxNode -is [System.Management.Automation.Language.CommandAst]
                    },
                    $true
                ))) {
            $strCommandName = [string]$objCommand.GetCommandName()
            if ([string]::IsNullOrEmpty($strCommandName)) {
                # A command with no name is an invocation through something.
                # Skipping those outright is what let `& ('Get-' + 'Item')` do
                # an unbounded wildcard listing while naming no forbidden
                # command, member or dynamic member -- green at 113 passes. An
                # earlier round called this class unclosable because the
                # indirection is unbounded in form. That was wrong: the target
                # cannot be traced, but it can be CONSTRAINED, and constraining
                # it is enough.
                #
                # Measured, all 297 nameless invocations across both scripts
                # invoke a variable, and of the 56 distinct variables, 54 are
                # the internal script blocks and the other is the resolved
                # absolute path of stat in each file. So the rule is that a
                # nameless command must invoke one of those two things.
                # `& ('Get-' + 'Item')` fails because its target is not a
                # variable at all, and `$x = 'Get-Item'; & $x` fails because the
                # variable is neither a script block nor a declared native path.
                $objTarget = $objCommand.CommandElements[0]
                $strTarget = ''
                if ($objTarget -is
                    [System.Management.Automation.Language.VariableExpressionAst]) {
                    $strTarget = [string]$objTarget.VariablePath.UserPath -creplace '^script:', ''
                }
                if ($strTarget.Length -eq 0 -or
                    -not ($arrScriptBlockVariable -ccontains $strTarget -or
                        $arrNativePathVariable -ccontains $strTarget -or
                        $arrOwnClosureVariable -ccontains $strTarget)) {
                    & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                        -Detail ('nameless-command-not-permitted-' +
                            [string]$objCommand.Extent.StartLineNumber)
                }
                continue
            }
            if ($strCommandName -ceq 'Remove-Variable') {
                # This command is in the permitted set for exactly one purpose:
                # taking the issuance registers out of a dot-sourced caller's
                # scope. Anything else it could unbind is an invocation target
                # some other rule admitted by its assignment, and unbinding one
                # makes a later `& $scriptBlockFoo` fall through to whatever the
                # caller has bound to that name.
                #
                # Four revisions of this rule tried to decide, from the parse
                # tree, which element PowerShell would bind to -Name. Each was
                # escaped by a spelling the previous one did not model:
                # `Remove-Variable scriptBlockFoo -Force`, because -Name is
                # positional; a splatted hashtable, whose contents are assembled
                # elsewhere; `-Name $name` where $name came from an assignment
                # rather than the register loop; and -- reported at round 51 --
                # `Remove-Variable -Force scriptBlockFoo`, where -Force is a
                # SWITCH and consumes no argument, so the target binds
                # positionally while a rule that skips "the value of a parameter
                # that is not -Name" skips straight past it. Measured: the whole
                # suite green with that call planted in the context manager.
                # A fifth spelling would have followed the fourth.
                #
                # The root cause was the approach, not any one gap in it. Those
                # rules were re-implementing PowerShell's parameter binder from
                # source text, and the binder has more spellings than a rule can
                # enumerate. So this no longer works out what a call means. The
                # file is allowed exactly ONE shape of call, matched
                # structurally, and every other spelling fails by not being that
                # shape -- including spellings nobody has thought of yet, which
                # is the only property that has held up in this loop.
                $arrRemovableName = [string[]]@(
                    'arrCandidateIssuedContext',
                    'arrCandidateIssuedSnapshot',
                    'arrCandidateIssuedState'
                )
                $strRegisterLoopVariable = 'strCandidateRegisterName'
                $boolCanonical = $true
                $arrElement = @($objCommand.CommandElements)
                # Exactly, and only:
                #   Remove-Variable -Name $strCandidateRegisterName `
                #       -Force -ErrorAction SilentlyContinue
                if ($arrElement.Count -ne 6) {
                    $boolCanonical = $false
                } else {
                    $objNameTarget = $arrElement[2]
                    if (-not ($arrElement[1] -is
                            [System.Management.Automation.Language.CommandParameterAst] -and
                            ([string]$arrElement[1].ParameterName) -ceq 'Name')) {
                        $boolCanonical = $false
                    } elseif (-not ($objNameTarget -is
                            [System.Management.Automation.Language.VariableExpressionAst] -and
                            -not $objNameTarget.Splatted -and
                            ([string]$objNameTarget.VariablePath.UserPath) -ceq
                                $strRegisterLoopVariable)) {
                        $boolCanonical = $false
                    } elseif (-not ($arrElement[3] -is
                            [System.Management.Automation.Language.CommandParameterAst] -and
                            ([string]$arrElement[3].ParameterName) -ceq 'Force')) {
                        $boolCanonical = $false
                    } elseif (-not ($arrElement[4] -is
                            [System.Management.Automation.Language.CommandParameterAst] -and
                            ([string]$arrElement[4].ParameterName) -ceq 'ErrorAction')) {
                        $boolCanonical = $false
                    } elseif (-not ($arrElement[5] -is
                            [System.Management.Automation.Language.StringConstantExpressionAst] -and
                            ([string]$arrElement[5].Value) -ceq 'SilentlyContinue')) {
                        $boolCanonical = $false
                    }
                }
                # The loop it must sit in, and the exact list that loop walks.
                # Round 50's rule accepted any foreach over the target name and
                # then scanned its condition for string literals, so a condition
                # that was a VARIABLE offered no literals to reject and the call
                # was admitted having checked nothing -- absence of evidence read
                # as evidence, again, in the rule written to stop exactly that.
                # Measured green with a computed list planted. The names are now
                # read out of the parse tree: anything that is not an array
                # literal of exactly these three constants, in this order, is
                # not the permitted shape.
                if ($boolCanonical) {
                    $objRegisterLoop = $null
                    $objWalk = $objCommand.Parent
                    $intWalk = 0
                    while ($null -ne $objWalk -and $intWalk -lt 6) {
                        if ($objWalk -is
                            [System.Management.Automation.Language.ForEachStatementAst]) {
                            $objRegisterLoop = $objWalk
                            break
                        }
                        $objWalk = $objWalk.Parent
                        $intWalk++
                    }
                    $arrRegisterLiteral = @()
                    if ($null -eq $objRegisterLoop -or
                        ([string]$objRegisterLoop.Variable.VariablePath.UserPath) -cne
                            $strRegisterLoopVariable) {
                        $boolCanonical = $false
                    } else {
                        $objCondition = $objRegisterLoop.Condition
                        if ($objCondition -is
                            [System.Management.Automation.Language.PipelineAst] -and
                            @($objCondition.PipelineElements).Count -eq 1 -and
                            $objCondition.PipelineElements[0] -is
                                [System.Management.Automation.Language.CommandExpressionAst]) {
                            $objArray = $objCondition.PipelineElements[0].Expression
                            if ($objArray -is
                                [System.Management.Automation.Language.ArrayExpressionAst]) {
                                $arrStatement = @($objArray.SubExpression.Statements)
                                if ($arrStatement.Count -eq 1 -and
                                    $arrStatement[0] -is
                                        [System.Management.Automation.Language.PipelineAst] -and
                                    @($arrStatement[0].PipelineElements).Count -eq 1 -and
                                    $arrStatement[0].PipelineElements[0] -is
                                        [System.Management.Automation.Language.CommandExpressionAst]) {
                                    $objList = $arrStatement[0].PipelineElements[0].Expression
                                    if ($objList -is
                                        [System.Management.Automation.Language.ArrayLiteralAst]) {
                                        $arrRegisterLiteral = @($objList.Elements)
                                    }
                                }
                            }
                        }
                    }
                    if ($boolCanonical) {
                        if ($arrRegisterLiteral.Count -ne $arrRemovableName.Count) {
                            $boolCanonical = $false
                        } else {
                            for ($intName = 0
                                $intName -lt $arrRegisterLiteral.Count
                                $intName++) {
                                if (-not ($arrRegisterLiteral[$intName] -is
                                        [System.Management.Automation.Language.StringConstantExpressionAst] -and
                                        ([string]$arrRegisterLiteral[$intName].Value) -ceq
                                            $arrRemovableName[$intName])) {
                                    $boolCanonical = $false
                                }
                            }
                        }
                    }
                }
                if (-not $boolCanonical) {
                    & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                        -Detail ('remove-variable-not-canonical-' +
                            [string]$objCommand.Extent.StartLineNumber)
                }
            }
            if (@($hashtableSurface.Command) -cnotcontains $strCommandName) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                    -Detail ('command-not-permitted-' + $strCommandName + '-' +
                        [string]$objCommand.Extent.StartLineNumber)
            }
            if ($strCommandName -ceq 'Set-Item') {
                # Set-Item is the one permitted command that rebinds a name, and
                # a rebound name is invisible to every rule that reads source.
                # Its target must therefore be a literal from the permitted set:
                # a non-literal path, or any path outside that set, is refused
                # whatever provider it names.
                $strSetItemPath = ''
                $arrSetItemElement = @($objCommand.CommandElements)
                for ($intElement = 1
                    $intElement -lt $arrSetItemElement.Count
                    $intElement++) {
                    $objElement = $arrSetItemElement[$intElement]
                    if ($objElement -isnot
                        [System.Management.Automation.Language.CommandParameterAst]) {
                        continue
                    }
                    if (([string]$objElement.ParameterName) -cne 'LiteralPath' -and
                        ([string]$objElement.ParameterName) -cne 'Path') {
                        continue
                    }
                    $objValue = $objElement.Argument
                    if ($null -eq $objValue -and
                        ($intElement + 1) -lt $arrSetItemElement.Count) {
                        $objValue = $arrSetItemElement[$intElement + 1]
                    }
                    if ($objValue -is
                        [System.Management.Automation.Language.StringConstantExpressionAst]) {
                        $strSetItemPath = [string]$objValue.Value
                    }
                    break
                }
                if ($strSetItemPath.Length -eq 0 -or
                    @($hashtableSurface.SetItemPath) -cnotcontains $strSetItemPath) {
                    & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                        -Detail ('set-item-target-not-permitted-' +
                            [string]$objCommand.Extent.StartLineNumber)
                }
                # Pinning only the destination left the payload unexamined, and
                # the payload is the half that runs. `-Value ([scriptblock]::
                # Create('Get-Item -Path "$dir/*"'))` spends only the permitted
                # Set-Item and the permitted Create, and the command inside the
                # string is not in the parsed tree for any rule here to see. So
                # the value must be one of the closure variables production
                # actually assigns -- a literal, traceable target, not an
                # expression that can build one.
                $strSetItemValue = ''
                for ($intElement = 1
                    $intElement -lt $arrSetItemElement.Count
                    $intElement++) {
                    $objElement = $arrSetItemElement[$intElement]
                    if ($objElement -isnot
                        [System.Management.Automation.Language.CommandParameterAst]) {
                        continue
                    }
                    if (([string]$objElement.ParameterName) -cne 'Value') {
                        continue
                    }
                    $objValue = $objElement.Argument
                    if ($null -eq $objValue -and
                        ($intElement + 1) -lt $arrSetItemElement.Count) {
                        $objValue = $arrSetItemElement[$intElement + 1]
                    }
                    if ($objValue -is
                        [System.Management.Automation.Language.VariableExpressionAst]) {
                        $strSetItemValue =
                            [string]$objValue.VariablePath.UserPath -creplace '^script:', ''
                    }
                    break
                }
                if ($strSetItemValue.Length -eq 0 -or
                    @($hashtableSurface.SetItemValue) -cnotcontains $strSetItemValue) {
                    & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                        -Detail ('set-item-value-not-permitted-' +
                            [string]$objCommand.Extent.StartLineNumber)
                }
            }
            if ($strCommandName -ceq 'ForEach-Object') {
                # ForEach-Object names a member as DATA. Piping a DirectoryInfo
                # to `-MemberName EnumerateFileSystemInfos` invokes that member
                # and emits the whole directory, and the parse tree holds no
                # InvokeMemberExpressionAst and no listing name outside a string
                # -- so the member allow-list, the listing pattern and the
                # helper-region rule all see nothing. Production uses only the
                # bare script-block form, whose contents these same checks walk,
                # so that is the whole permitted shape: any parameter at all is
                # refused rather than -MemberName being named and blocked, which
                # is the deny-list mistake this file has already made twice.
                #
                # Sort-Object and Where-Object were checked for the same
                # property and do not have it: -Property reads a value, it does
                # not invoke a member, and production passes it a literal name.
                # Every element after the command name, not just parameters.
                # ForEach-Object's simplified syntax binds a POSITIONAL string
                # to -MemberName -- `ForEach-Object EnumerateFileSystemInfos`
                # has no parameter node at all, so a rule that rejected only
                # CommandParameterAst would let it through and invoke the very
                # listing member the member allow-list exists to exclude.
                # Production passes exactly one argument here, a script block,
                # so anything else is refused.
                $arrForEachElement = @($objCommand.CommandElements)
                for ($intForEach = 1; $intForEach -lt $arrForEachElement.Count; $intForEach++) {
                    $objElement = $arrForEachElement[$intForEach]
                    if ($objElement -is
                        [System.Management.Automation.Language.ScriptBlockExpressionAst]) {
                        continue
                    }
                    if ($true) {
                        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                            -Detail ('foreach-object-parameter-not-permitted-' +
                                [string]$objCommand.Extent.StartLineNumber)
                    }
                }
            }
            # Add-Type is the one permitted command that can introduce member
            # names no rule above has heard of. Every other entry on the list
            # either takes a script block, whose contents these same checks walk,
            # or returns an object whose methods are ordinary member calls.
            # Measured: -TypeDefinition compiling a C# lister, then calling it as
            # [ShadowLister]::Walk(...), performed an unbounded directory read
            # and left the suite green at 113 passes.
            #
            # Requiring -AssemblyName keeps the code-bearing parameter sets out,
            # but it does not bound WHICH assembly is loaded, and -AssemblyName
            # accepts wildcards and falls back to the current location. A loaded
            # type can then expose a member the allow-list already permits by
            # name -- Create, say -- and do work no rule can tell from a
            # framework call, with no -TypeDefinition anywhere. So the two
            # literal names production uses are pinned, and a variable or a
            # wildcard in their place is refused.
            if ($strCommandName -ceq 'Add-Type') {
                $arrPermittedAssembly = [string[]]@(
                    'System.IO.Compression',
                    'System.IO.Compression.FileSystem'
                )
                $boolAssemblyName = $false
                $arrAddTypeElement = @($objCommand.CommandElements)
                for ($intAdd = 1; $intAdd -lt $arrAddTypeElement.Count; $intAdd++) {
                    $objPreviousAdd = $arrAddTypeElement[$intAdd - 1]
                    if (-not ($objPreviousAdd -is
                            [System.Management.Automation.Language.CommandParameterAst] -and
                            ([string]$objPreviousAdd.ParameterName) -ceq 'AssemblyName')) {
                        continue
                    }
                    $boolAssemblyName = $true
                    $objAssembly = $arrAddTypeElement[$intAdd]
                    $strAssembly = ''
                    if ($objAssembly -is
                        [System.Management.Automation.Language.StringConstantExpressionAst]) {
                        $strAssembly = [string]$objAssembly.Value
                    }
                    if ($arrPermittedAssembly -cnotcontains $strAssembly) {
                        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                            -Detail ('add-type-assembly-not-permitted-' +
                                [string]$objCommand.Extent.StartLineNumber)
                    }
                }
                if (-not $boolAssemblyName) {
                    & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                        -Detail ('add-type-without-assemblyname-' +
                            [string]$objCommand.Extent.StartLineNumber)
                }
            }
        }
        # A member name that is not a literal is refused across the whole file,
        # invocation and plain access alike. Every rule above compares a NAME,
        # and a dynamic member has none to compare: the AST node holds the
        # variable expression, so the comparison sees the text `$strMethod`
        # rather than the EnumerateFileSystemInfos it carries. Measured, that
        # left an unbounded whole-directory listing green at 113 passes -- the
        # fourth hole found in this one rule, after Get-Item, Resolve-Path and
        # the module-qualified spelling.
        #
        # Refusing the dynamic name rather than chasing what it might resolve to
        # is what makes this the last of them: resolving assignments would still
        # miss a name built from an expression, and a deny-list of resolved
        # values is the shape that has now failed four times. Plain access is
        # included because it is the first link of a chain that reaches a
        # listing without ever naming one -- `$obj.$name` yields a method
        # reference, and invoking that is an ordinary literal call. Breaking the
        # first link costs nothing here and needs no second rule.
        #
        # Measured: both production scripts contain zero dynamic member
        # invocations and zero dynamic member accesses, so this refuses nothing
        # they do today.
        foreach ($objDynamic in @($objAst.FindAll(
                    {
                        param ($SyntaxNode)
                        $SyntaxNode -is
                            [System.Management.Automation.Language.MemberExpressionAst] -and
                        $SyntaxNode.Member -isnot
                            [System.Management.Automation.Language.StringConstantExpressionAst]
                    },
                    $true
                ))) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('dynamic-member-not-permitted-' +
                    [string]$objDynamic.Extent.StartLineNumber)
        }
        # ComputeHash handed a stream is refused. It reads to EOF, and EOF is
        # wherever the file happens to end when the read arrives rather than
        # where the journal said it ended -- measured, a file validated at 1,024
        # bytes had 201,327,616 consumed, and a writer that keeps ahead of the
        # reader moves the end for as long as it likes. Both evidence helpers
        # now hash exactly the validated count through the bounded TransformBlock
        # idiom this file already used in three other places.
        #
        # The single-argument form is what does this; ComputeHash over a byte
        # array is bounded by the array and stays permitted. That distinction is
        # the rule, so it is what gets compared -- pinning the loop's shape
        # instead would be satisfied by any editor who rewrote the loop.
        foreach ($objHashCall in @($objAst.FindAll(
                    {
                        param ($SyntaxNode)
                        if ($SyntaxNode -isnot
                            [System.Management.Automation.Language.InvokeMemberExpressionAst]) {
                            return $false
                        }
                        $strMember = if ($SyntaxNode.Member -is
                            [System.Management.Automation.Language.StringConstantExpressionAst]) {
                            [string]$SyntaxNode.Member.Value
                        } else {
                            ''
                        }
                        if ($strMember -cne 'ComputeHash') {
                            return $false
                        }
                        # Every one-argument form, with no inference from how
                        # the argument is spelled. The earlier rule asked
                        # whether the argument's text contained 'stream', which
                        # is a guess about a name rather than a fact about a
                        # call: measured, a stream hash under a variable called
                        # $objSource restored the unbounded read and left the
                        # suite green at 113 passes. The legitimate byte-array
                        # call takes the three-argument form instead, where the
                        # count is explicit and no guess is needed.
                        return (@($SyntaxNode.Arguments).Count -eq 1)
                    },
                    $true
                ))) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('stream-hash-not-permitted-' +
                    [string]$objHashCall.Extent.StartLineNumber)
        }
        # A prose format string for stat is refused outright. The behavioural
        # probe elsewhere in this harness proves the regular-file proof decides
        # correctly, but it can only prove it under the locale the suite runs
        # in: reverting to %F would keep that probe green on an English runner
        # and refuse every valid cleanup on a translated one. The property at
        # stake is that no message catalogue is consulted at all, and that is a
        # property of the source rather than of one run.
        foreach ($objProse in @($objAst.FindAll(
                    {
                        param ($SyntaxNode)
                        $SyntaxNode -is
                            [System.Management.Automation.Language.StringConstantExpressionAst] -and
                        [string]$SyntaxNode.Value -cmatch '%F'
                    },
                    $true
                ))) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('translatable-stat-format-' +
                    [string]$objProse.Extent.StartLineNumber)
        }
        # Reflection is refused across the whole file, helper definition
        # included: it reaches a listing without spelling one, and neither
        # script has any use for it.
        foreach ($objReflection in @($objAst.FindAll(
                    {
                        param ($SyntaxNode)
                        if ($SyntaxNode -isnot
                            [System.Management.Automation.Language.InvokeMemberExpressionAst]) {
                            return $false
                        }
                        $strMember = if ($SyntaxNode.Member -is
                            [System.Management.Automation.Language.StringConstantExpressionAst]) {
                            [string]$SyntaxNode.Member.Value
                        } else {
                            [string]$SyntaxNode.Member.Extent.Text
                        }
                        return ($strMember -match
                            $script:strCandidateReflectionMemberPattern)
                    },
                    $true
                ))) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('reflection-not-permitted-' +
                    [string]$objReflection.Extent.StartLineNumber)
        }
        # Members that are on the allow-list and still read a directory. Being
        # known is not the same as being safe: GetResolvedProviderPathFromPSPath
        # expands a wildcard into the entries it matches, so a second call
        # anywhere is an unbounded directory read that spells no listing name
        # and matches no listing pattern. Production needs exactly one, behind
        # the wildcard guard, so the count is what is pinned -- a rule about
        # where it may appear would have to name a region, and a name is what
        # keeps getting respelled around here.
        foreach ($strBoundedMember in @($hashtableSurface.SingleUseMember.Keys)) {
            $intUse = @($objAst.FindAll(
                    {
                        param ($SyntaxNode)
                        if ($SyntaxNode -isnot
                            [System.Management.Automation.Language.InvokeMemberExpressionAst]) {
                            return $false
                        }
                        if ($SyntaxNode.Member -isnot
                            [System.Management.Automation.Language.StringConstantExpressionAst]) {
                            return $false
                        }
                        return (([string]$SyntaxNode.Member.Value) -ceq $strBoundedMember)
                    },
                    $true
                )).Count
            if ($intUse -ne [int]$hashtableSurface.SingleUseMember[$strBoundedMember]) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                    -Detail ('bounded-member-count-' + $strBoundedMember + '-' +
                        [string]$intUse)
            }
        }
        # Every invoked member, against the allow-list. The two patterns above
        # are deny-lists: they name mechanisms, and a deny-list can only refuse
        # the mechanisms someone thought of. Two got past them -- an embedded
        # [System.Management.Automation.PowerShell] taking its command as data,
        # and $ExecutionContext.InvokeCommand.InvokeScript -- and neither
        # spells a listing or a reflection name anywhere. This asks the
        # opposite question, which the deny-lists cannot: is this member one
        # the production scripts are known to use?
        #
        # They are kept alongside rather than replaced. Both still fire first
        # and say precisely what was wrong, which an allow-list rejection
        # cannot; this one only reports that a name was not on the list.
        foreach ($objMember in @($objAst.FindAll(
                    {
                        param ($SyntaxNode)
                        return ($SyntaxNode -is
                            [System.Management.Automation.Language.InvokeMemberExpressionAst])
                    },
                    $true
                ))) {
            # A computed member name is already refused elsewhere, and it has no
            # name to test here, so it is left to that rule rather than reported
            # twice under a less specific one.
            if ($objMember.Member -isnot
                [System.Management.Automation.Language.StringConstantExpressionAst]) {
                continue
            }
            $strMemberName = [string]$objMember.Member.Value
            if (@($hashtableSurface.Member) -cnotcontains $strMemberName) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                    -Detail ('member-not-permitted-' + $strMemberName + '-' +
                        [string]$objMember.Extent.StartLineNumber)
            }
            # The name is permitted; now the receiver has to be one production
            # uses it on. Without this, a permitted name is permitted on
            # anything -- see the note above the table.
            if (-not $hashtableSurface.MemberReceiver.ContainsKey($strMemberName)) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                    -Detail ('member-receiver-undeclared-' + $strMemberName + '-' +
                        [string]$objMember.Extent.StartLineNumber)
            }
            $hashtableReceiver = $hashtableSurface.MemberReceiver[$strMemberName]
            if ($objMember.Static) {
                $strReceiverType = ''
                if ($objMember.Expression -is
                    [System.Management.Automation.Language.TypeExpressionAst]) {
                    $strReceiverType = [string]$objMember.Expression.TypeName.FullName
                }
                if (@($hashtableReceiver.Static) -cnotcontains $strReceiverType) {
                    & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                        -Detail ('member-receiver-not-permitted-' + $strMemberName + '-' +
                            [string]$objMember.Extent.StartLineNumber)
                }
            } elseif (-not $hashtableReceiver.Instance) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                    -Detail ('member-instance-not-permitted-' + $strMemberName + '-' +
                        [string]$objMember.Extent.StartLineNumber)
            }
        }
        # The helper's own definition is the one region a listing may occupy.
        # Finding it by the same name list the site table uses keeps the two
        # checks from disagreeing about what a helper is.
        $arrDefinition = @($objAst.FindAll(
                {
                    param ($SyntaxNode)
                    $SyntaxNode -is
                        [System.Management.Automation.Language.AssignmentStatementAst] -and
                    $SyntaxNode.Left -is
                        [System.Management.Automation.Language.VariableExpressionAst] -and
                    $script:arrCandidateEnumerationScriptBlockName -ccontains
                        ($SyntaxNode.Left.VariablePath.UserPath -creplace '^script:', '')
                },
                $true
            ))
        if (@($arrDefinition).Count -ne 1) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('enumeration-primitive-definition-' + @($arrDefinition).Count)
        }
        $intDefinitionStart = [int]@($arrDefinition)[0].Extent.StartOffset
        $intDefinitionEnd = [int]@($arrDefinition)[0].Extent.EndOffset

        $arrListing = @($objAst.FindAll(
                {
                    param ($SyntaxNode)
                    if ($SyntaxNode -is
                        [System.Management.Automation.Language.InvokeMemberExpressionAst]) {
                        $strMember = ''
                        if ($SyntaxNode.Member -is
                            [System.Management.Automation.Language.StringConstantExpressionAst]) {
                            $strMember = [string]$SyntaxNode.Member.Value
                        } else {
                            $strMember = [string]$SyntaxNode.Member.Extent.Text
                        }
                        return ($strMember -match $script:strCandidateListingMemberPattern)
                    }
                    # No command branch here: a listing cmdlet cannot reach this
                    # file at all, because the allow-list above admits only
                    # commands that do not list. Naming Get-ChildItem here as
                    # well would be a second, weaker statement of that.
                    return $false
                },
                $true
            ))
        if (@($arrListing).Count -eq 0) {
            & $script:scriptBlockStopHarness `
                -Code 'catalog-invalid' -Detail 'enumeration-primitive-absent'
        }
        foreach ($objListing in @($arrListing)) {
            if ([int]$objListing.Extent.StartOffset -lt $intDefinitionStart -or
                [int]$objListing.Extent.EndOffset -gt $intDefinitionEnd) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                    -Detail ('enumeration-primitive-escaped-' +
                        [string]$objListing.Extent.StartLineNumber)
            }
        }
    }
}

# The download entry's leaf is the only journaled name production does not
# choose, and the filtered absence proofs made that matter: a name legal on the
# filesystem but not legal in the journal was adopted, recorded, and only tested
# once cleanup had to consult the record. Ordering is the whole property, so
# ordering is what is pinned -- the stored-path rule must be applied to
# $strArchivePath before the first call that touches it. A check that runs after
# the metadata read, or after journaling, is the defect this asserts against,
# and it would be invisible to a check that only asked whether the call exists.
# Source order is not execution. The check above proves the stored-path rule is
# applied to the download leaf before the first call that touches it, and that
# is a real property -- but a call parked inside `if ($false)` is still the
# first command naming $strArchivePath, so the ordering pin stays satisfied
# while the rule never runs, and nothing in the catalog supplies a download
# leaf that would notice. Measured: the whole suite green, 115 records, zero
# failures, with the validation bypassed and the archive journaled unvalidated.
#
# The file already knew this. The resource-guard prober above says so in as many
# words, and drives real expansions rather than reading trees, precisely because
# parseable is not reachable. The pin below was written without applying that
# lesson. So execution is observed here the same way: one expansion per leaf
# through the production entry point, with the outcome required to differ by
# leaf. The two checks answer different questions and neither subsumes the
# other -- this one cannot see ordering, and the AST one cannot see execution.
# The regular-file proof asks an external tool what a path is, and the first
# version asked in PROSE: it compared stat's %F against 'regular file' and
# 'regular empty file'. GNU coreutils translates its messages, so a runner whose
# LC_MESSAGES selected an installed translation would have refused every valid
# cleanup -- a false rejection of legitimate input, which this code has now
# shipped twice before and flagged as a risk once without fixing it.
#
# The fix reads the numeric mode instead, and this probe is behavioural rather
# than another source rule on purpose. Five separate holes have been found in
# the AST-shaped rules this suite carries, every one of them a spelling the rule
# did not anticipate. A probe that plants a real FIFO and a real empty file and
# checks what the loaded helper actually decides cannot be defeated by
# respelling the format string, and it fails if either verdict ever inverts.
$script:scriptBlockAssertRegularFileProofExecutes = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RunRoot,

        [Parameter(Mandatory = $true)]
        [string]$HelperLiteralPath,

        [Parameter(Mandatory = $true)]
        [string]$ContextLiteralPath
    )

    if ($script:boolCandidateIsWindows) {
        # Windows has no mkfifo and no filesystem pipes under the invocation
        # root, so the pipe refusal is unobservable there. What IS observable is
        # whether the created root is private, and on Windows it is created with
        # the inherited ACL: a shared trusted parent leaves the archive and the
        # extracted files readable to other local users.
        #
        # Only the unambiguous case is judged -- an allow entry for Everyone or
        # for the built-in Users group -- because what else belongs on a runner
        # cannot be settled from a machine that has none. An ACL that cannot be
        # read at all is skipped rather than failed, so a mis-guess here cannot
        # block the Windows run that exists to answer this.
        $objRootContext = New-StyleGuideCandidateInvocationContext `
            -TrustedTemporaryRoot $RunRoot `
            -DiagnosticLabel 'invocation-root-acl'
        try {
            $objRootAcl = $null
            try {
                $objRootAcl = (New-Object System.IO.DirectoryInfo(
                    [string]$objRootContext.InvocationRootPath)).GetAccessControl()
            } catch {
                $objRootAcl = $null
            }
            if ($null -ne $objRootAcl) {
                foreach ($objRule in @($objRootAcl.GetAccessRules(
                            $true, $true, [System.Security.Principal.SecurityIdentifier]))) {
                    if ($objRule.AccessControlType -ne
                        [System.Security.AccessControl.AccessControlType]::Allow) {
                        continue
                    }
                    $strSid = [string]$objRule.IdentityReference.Value
                    # Everyone, the built-in Users group, and Authenticated
                    # Users. The last was missing and is the one most likely to
                    # be inherited from a shared parent on a domain-joined host.
                    if ($strSid -ceq 'S-1-1-0' -or $strSid -ceq 'S-1-5-32-545' -or
                        $strSid -ceq 'S-1-5-11') {
                        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                            -Detail ('invocation-root-acl-' + $strSid)
                    }
                }
            }
        } finally {
            [void](Remove-StyleGuideCandidateInvocationContext -Context $objRootContext)
        }
        return
    }
    $strFifoPath = [string](& $script:scriptBlockResolveHarnessNativePath `
        -CandidatePath ([string[]]@('/usr/bin/mkfifo', '/bin/mkfifo')))
    if ($strFifoPath.Length -eq 0) {
        & $script:scriptBlockStopHarness `
            -Code 'catalog-invalid' -Detail 'regular-file-proof-mkfifo-absent'
    }
    $strProbeRoot = [System.IO.Path]::Combine($RunRoot, 'regular-file-proof')
    [void][System.IO.Directory]::CreateDirectory($strProbeRoot)

    $strEmptyPath = [System.IO.Path]::Combine($strProbeRoot, 'empty.bin')
    [System.IO.File]::WriteAllBytes($strEmptyPath, [byte[]]@())
    $strPipePath = [System.IO.Path]::Combine($strProbeRoot, 'pipe.bin')
    [void](& $strFifoPath $strPipePath 2>$null)
    if ($LASTEXITCODE -ne 0) {
        & $script:scriptBlockStopHarness `
            -Code 'catalog-invalid' -Detail 'regular-file-proof-mkfifo-failed'
    }

    # An empty regular file must be ADMITTED. That direction matters as much as
    # the refusal: a journaled file may legitimately be empty, and the earlier
    # download-path rule that refused a zero length could not be reused here for
    # exactly that reason.
    # The invocation root must be private at creation. The default under the
    # usual 022 umask is 0755 -- measured -- which lets any local user traverse
    # the root once its unpredictable name is known and read the downloaded
    # archive and the extracted files. Checked here rather than in source
    # because the property is what the filesystem ended up with, and a source
    # change that quietly reverted the mode would still parse.
    $strModeProbeParent = [System.IO.Path]::Combine($strProbeRoot, 'mode')
    [void][System.IO.Directory]::CreateDirectory($strModeProbeParent)
    $objModeContext = New-StyleGuideCandidateInvocationContext `
        -TrustedTemporaryRoot $strModeProbeParent `
        -DiagnosticLabel 'invocation-root-mode'
    $strStatPathForMode = [string](& $script:scriptBlockResolveHarnessNativePath `
        -CandidatePath ([string[]]@('/usr/bin/stat', '/bin/stat')))
    if ($strStatPathForMode.Length -eq 0) {
        & $script:scriptBlockStopHarness `
            -Code 'catalog-invalid' -Detail 'invocation-root-mode-stat-absent'
    }
    $arrRootMode = @(& $strStatPathForMode '-c' '%a' '--' `
        ([string]$objModeContext.InvocationRootPath) 2>$null)
    if ($LASTEXITCODE -ne 0 -or $arrRootMode.Count -ne 1 -or
        [string]$arrRootMode[0] -cne '700') {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail ('invocation-root-mode-' + [string]$arrRootMode[0])
    }
    [void](Remove-StyleGuideCandidateInvocationContext -Context $objModeContext)

    # The mode above is the measured truth, so prose that claims a DIFFERENT one
    # for what these scripts create is checkable against it. Round 28 found a
    # comment still asserting the root was "created 0755" long after the
    # creation path had been changed to refuse anything but a private root --
    # the file contradicting itself two hundred lines apart, in the paragraph
    # that justifies an acknowledged TOCTOU window.
    #
    # This is narrow on purpose and does not pretend otherwise: it pins the
    # literal, not the claim. Reworded drift walks straight past it, which is
    # why the fix was to state the invariant instead of a value -- this only
    # stops the value coming back. Mentions of a mode this code does NOT create
    # are untouched, because they carry no "created".
    foreach ($strModeClaimPath in @($HelperLiteralPath, $ContextLiteralPath)) {
        $strModeClaimText = [System.IO.File]::ReadAllText($strModeClaimPath)
        foreach ($objModeClaim in [regex]::Matches(
                $strModeClaimText,
                'created\s+0?([0-7]{3})\b',
                [System.Text.RegularExpressions.RegexOptions]::CultureInvariant)) {
            if ($objModeClaim.Groups[1].Value -cne [string]$arrRootMode[0]) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                    -Detail ('created-mode-claim-' + $objModeClaim.Groups[1].Value)
            }
        }
    }

    # The context manager's predicate and the helper's predicate are DIFFERENT
    # scriptblocks (scriptBlockAssertCandidateOrdinaryRegularFile vs
    # scriptBlockAssertCandidateHelperOrdinaryRegularFile), and the
    # post-extraction reader opens through the HELPER's. Round 59 exercised only
    # the manager's here and pinned the helper's by call count, which -- Codex
    # observed at round 60 -- leaves the helper predicate's behaviour uncovered:
    # if its Unix stat mode check regresses to accept a pipe, the count stays
    # three and W-06 still refuses its FIFO on a later metadata check, so the
    # suite stays green while a post-extraction open would accept a FIFO. Both
    # predicates are now exercised against the same two fixtures.
    foreach ($hashtableProof in @(
            @{ Block = $scriptBlockAssertCandidateOrdinaryRegularFile
                Label = 'regular-file-proof' },
            @{ Block = $script:scriptBlockAssertCandidateHelperOrdinaryRegularFile
                Label = 'helper-regular-file-proof' })) {
        foreach ($hashtableCase in @(
                @{ Path = $strEmptyPath; MustPass = $true; Name = 'empty-regular' },
                @{ Path = $strPipePath; MustPass = $false; Name = 'named-pipe' })) {
            $boolPassed = $true
            try {
                & $hashtableProof.Block `
                    -LiteralPath ([string]$hashtableCase.Path)
            } catch {
                $boolPassed = $false
            }
            if ($boolPassed -ne [bool]$hashtableCase.MustPass) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                    -Detail ([string]$hashtableProof.Label + '-' +
                        [string]$hashtableCase.Name + '-' +
                        $(if ($boolPassed) { 'admitted' } else { 'refused' }))
            }
        }
    }
}

$script:scriptBlockAssertJournalSwapRefused = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RunRoot
    )

    # Round 52's reference-identity check in scriptBlockAddCandidateHelperRecord
    # refuses to append when the caller's context no longer holds the exact
    # journal array the expansion authenticated -- the fix for EE6/II1. Nothing
    # in the committed suite exercised it. Measured directly: deleting the check
    # left all 115 cases green, so a revert would have been invisible. The
    # normal expansion cases never swap the journal between authentication and
    # append, so only a direct invocation with a swapped array reaches it.
    #
    # Behavioural, with a positive control. The un-swapped append must SUCCEED
    # and the swapped append must be REFUSED with 'journal-swapped'. Requiring
    # the control to succeed is what gives the assertion teeth: an assertion
    # that only checked the refusal would also pass against a guard that always
    # throws, and against a guard deleted entirely the swapped append would
    # wrongly succeed -- which this fails on. Round 33's one-sided-race lesson,
    # applied to a deterministic guard.
    $strSwapRoot = [System.IO.Path]::Combine($RunRoot, 'journal-swap')
    [void][System.IO.Directory]::CreateDirectory($strSwapRoot)
    $objContext = New-StyleGuideCandidateInvocationContext `
        -TrustedTemporaryRoot $strSwapRoot -DiagnosticLabel 'journal-swap'
    try {
        $objAuthenticatedJournal = $objContext.OwnershipJournal
        $uintAuthenticatedSequence = [uint32]$objContext.NextSequence
        $objRecord = & $script:scriptBlockNewCandidateHelperRecord `
            -Sequence $uintAuthenticatedSequence `
            -Kind 'DownloadFile' `
            -Path ([System.IO.Path]::Combine(
                [string]$objContext.DownloadDirectoryPath, 'probe.zip')) `
            -ParentPath ([string]$objContext.DownloadDirectoryPath) `
            -LeafName 'probe.zip' `
            -CreationPhase 'download' `
            -ContentLength ([uint64]1) `
            -ContentSha256 ('0' * 64)

        # Control: an append whose context still holds the authenticated journal
        # must succeed -- and it ADVANCES the capture. The guard has two
        # branches, a journal reference-identity check and a NextSequence check,
        # and the control append moves both the context's journal (to a new
        # array) and its NextSequence forward. Round 59's first version left the
        # capture at the pre-control values, so each attack below tripped BOTH
        # branches at once and neither branch was isolated: deleting only the
        # reference check still left the swap caught by the stale sequence
        # mismatch, with the same subreason, so the assertion proved nothing
        # specific. Reported by Codex at round 60. The capture is advanced with
        # the append -- the returned journal, and the context's own advanced
        # NextSequence -- so each attack now targets exactly one branch.
        $boolControlSucceeded = $true
        try {
            $objAuthenticatedJournal = & $script:scriptBlockAddCandidateHelperRecord `
                -ContextValue $objContext -Record $objRecord `
                -JournalValue $objAuthenticatedJournal `
                -NextSequenceValue $uintAuthenticatedSequence -PhaseValue 'download'
        } catch {
            $boolControlSucceeded = $false
        }
        if (-not $boolControlSucceeded) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail 'journal-swap-control-refused'
        }
        $uintAuthenticatedSequence = [uint32]$objContext.NextSequence

        # Attack A -- swap the journal to a decoy while leaving the sequence
        # matched, so ONLY the reference-identity check can catch it.
        # Attack B -- keep the journal matched while passing a mismatched
        # sequence, so ONLY the NextSequence check can catch it.
        # Each must be refused, naming journal-swapped. Deleting either guard
        # branch now fails exactly one of these.
        foreach ($hashtableAttack in @(
                @{ Name = 'journal'
                    Journal = ([object[]]@())
                    Sequence = $uintAuthenticatedSequence },
                @{ Name = 'sequence'
                    Journal = $objAuthenticatedJournal
                    Sequence = ([uint32]($uintAuthenticatedSequence + 1)) })) {
            $objContext.OwnershipJournal = [object[]]$hashtableAttack.Journal
            $boolSwapRefused = $false
            $strSwapSubreason = 'none'
            try {
                [void](& $script:scriptBlockAddCandidateHelperRecord `
                    -ContextValue $objContext -Record $objRecord `
                    -JournalValue $objAuthenticatedJournal `
                    -NextSequenceValue ([uint32]$hashtableAttack.Sequence) `
                    -PhaseValue 'download')
            } catch {
                $boolSwapRefused = $true
                $objSubreasonMatch = [regex]::Match(
                    [string]$_.Exception.Message, 'subreason=([a-z][a-z0-9-]*)')
                if ($objSubreasonMatch.Success) {
                    $strSwapSubreason = $objSubreasonMatch.Groups[1].Value
                }
            }
            if (-not $boolSwapRefused -or $strSwapSubreason -cne 'journal-swapped') {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                    -Detail ('journal-swap-' + [string]$hashtableAttack.Name +
                        '-not-refused-' + $strSwapSubreason)
            }
            # Restore the authenticated journal so the next attack targets its
            # own branch from a clean matched state.
            $objContext.OwnershipJournal = $objAuthenticatedJournal
        }
    } finally {
        # The context was deliberately corrupted, so its own cleanup is not
        # trusted to dispose the tree; remove the probe root directly.
        [System.IO.Directory]::Delete($strSwapRoot, $true)
    }
}

$script:scriptBlockAssertRetainedSequenceFromCapture = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RunRoot
    )

    # Round 61 (Codex F3): the cleanup failure catch computes retained sequences
    # from the journal it captured and bounded at entry, not from the live
    # $Context a thrown manager may have swapped. Measured before the fix: a
    # rebound manager that replaced $Context.OwnershipJournal with 2,000,000
    # records and threw made the catch iterate all of them (5.5 s on .NET 8) and
    # return attacker-chosen sequences, defeating the bounded result the catch
    # documents. Nothing committed exercised that path.
    #
    # Two parts, so the assertion has teeth in both directions. The CONTROL
    # proves the catch reads the captured journal's contents: a manager that
    # marks one real record RetainedUncertain in place and throws must have that
    # record's sequence reported, so a catch hardcoded to empty fails here. The
    # ATTACK proves it reads the CAPTURE and not the live property: a manager
    # that swaps the journal for a decoy full of RetainedUncertain records and
    # throws must still report the captured journal's own set -- empty, for a
    # fresh context -- so a catch that reads $Context reports the decoy and fails.
    $scriptBlockRealCleanup = (Get-Command `
        -Name Remove-StyleGuideCandidateInvocationContext `
        -CommandType Function).ScriptBlock

    $strControlRoot = [System.IO.Path]::Combine($RunRoot, 'retained-control')
    [void][System.IO.Directory]::CreateDirectory($strControlRoot)
    $objControlContext = New-StyleGuideCandidateInvocationContext `
        -TrustedTemporaryRoot $strControlRoot -DiagnosticLabel 'retained-control'
    $uintControlSequence = [uint32]$objControlContext.OwnershipJournal[1].Sequence
    $objControlResult = $null
    try {
        Set-Item -LiteralPath Function:\Remove-StyleGuideCandidateInvocationContext -Value {
            param (
                [Parameter(Mandatory = $true)]
                [AllowNull()]
                [object]$Context
            )
            $Context.OwnershipJournal[1].EntryState = 'RetainedUncertain'
            throw 'retained-control-throw'
        } -Force
        $objControlResult = Remove-StyleGuideCandidateInvocationState `
            -Context $objControlContext
    } finally {
        Set-Item -LiteralPath Function:\Remove-StyleGuideCandidateInvocationContext `
            -Value $scriptBlockRealCleanup -Force
        [System.IO.Directory]::Delete($strControlRoot, $true)
    }
    $arrControlRetained = [uint32[]]@($objControlResult.RetainedRecordSequences)
    if ($arrControlRetained.Count -ne 1 -or
        $arrControlRetained[0] -ne $uintControlSequence) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail ('retained-capture-control-' + [string]$arrControlRetained.Count)
    }

    $strAttackRoot = [System.IO.Path]::Combine($RunRoot, 'retained-attack')
    [void][System.IO.Directory]::CreateDirectory($strAttackRoot)
    $objAttackContext = New-StyleGuideCandidateInvocationContext `
        -TrustedTemporaryRoot $strAttackRoot -DiagnosticLabel 'retained-attack'
    $objAttackResult = $null
    try {
        Set-Item -LiteralPath Function:\Remove-StyleGuideCandidateInvocationContext -Value {
            param (
                [Parameter(Mandatory = $true)]
                [AllowNull()]
                [object]$Context
            )
            $intDecoy = 4096
            $arrDecoy = New-Object object[] $intDecoy
            for ($intIndex = 0; $intIndex -lt $intDecoy; $intIndex++) {
                $arrDecoy[$intIndex] = [pscustomobject]@{
                    EntryState = 'RetainedUncertain'
                    Sequence = [uint32]$intIndex
                }
            }
            $Context.OwnershipJournal = [object[]]$arrDecoy
            throw 'retained-attack-throw'
        } -Force
        $objAttackResult = Remove-StyleGuideCandidateInvocationState `
            -Context $objAttackContext
    } finally {
        Set-Item -LiteralPath Function:\Remove-StyleGuideCandidateInvocationContext `
            -Value $scriptBlockRealCleanup -Force
        [System.IO.Directory]::Delete($strAttackRoot, $true)
    }
    $intAttackRetained = @($objAttackResult.RetainedRecordSequences).Count
    if ($intAttackRetained -ne 0) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail ('retained-capture-live-' + $intAttackRetained)
    }
}

$script:scriptBlockAssertCandidateRecordUnchangedRefused = {
    # Round 64 (Codex): the pre-create candidate-record guard must refuse a
    # same-session flip of EVERY invariant field, not just the Kind/Sequence/Path
    # round 63 covered. The production check is factored into
    # scriptBlockAssertCandidateHelperRecordUnchanged so it can be exercised in
    # isolation here: an unmutated record passes, and a flip of any one field is
    # refused with subreason candidate-record. Removing any field's check from
    # the production guard reddens exactly this probe. Same-process direct call,
    # the journal-swap probe's mechanism.
    $scriptBlockFreshRecord = {
        $objRecord = [pscustomobject][ordered]@{
            SchemaVersion     = [uint32]1
            Sequence          = [uint32]3
            Kind              = 'CandidateDirectory'
            Path              = 'candidate-root/candidate'
            ParentPath        = 'candidate-root'
            LeafName          = 'candidate'
            ExpectedEntryType = 'Directory'
            CreationPhase     = 'context'
            EntryState        = 'ExpectedAbsent'
            ContentLength     = $null
            ContentSha256     = $null
        }
        $objRecord.PSObject.TypeNames.Insert(
            0, $script:strCandidateHelperRecordTypeName)
        $objRecord
    }
    $objSnapshot = [pscustomobject]@{
        Sequence   = [uint32]3
        Path       = 'candidate-root/candidate'
        ParentPath = 'candidate-root'
        LeafName   = 'candidate'
    }

    $boolControlPassed = $true
    try {
        & $script:scriptBlockAssertCandidateHelperRecordUnchanged `
            -Record (& $scriptBlockFreshRecord) -Snapshot $objSnapshot `
            -PhaseValue 'destination'
    } catch {
        $boolControlPassed = $false
    }
    if (-not $boolControlPassed) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail 'candidate-record-unchanged-control-refused'
    }

    foreach ($hashtableMutation in @(
            @{
                Name = 'SchemaVersion'
                Apply = {
                    param ($RecordToMutate)
                    $RecordToMutate.SchemaVersion = [uint32]2
                }
            },
            @{
                Name = 'Sequence'
                Apply = {
                    param ($RecordToMutate)
                    $RecordToMutate.Sequence = [uint32]5
                }
            },
            @{
                Name = 'Kind'
                Apply = {
                    param ($RecordToMutate)
                    $RecordToMutate.Kind = 'DownloadFile'
                }
            },
            @{
                Name = 'ExpectedEntryType'
                Apply = {
                    param ($RecordToMutate)
                    $RecordToMutate.ExpectedEntryType = 'File'
                }
            },
            @{
                Name = 'CreationPhase'
                Apply = {
                    param ($RecordToMutate)
                    $RecordToMutate.CreationPhase = 'destination'
                }
            },
            @{
                Name = 'ContentLength'
                Apply = {
                    param ($RecordToMutate)
                    $RecordToMutate.ContentLength = [uint64]1
                }
            },
            @{
                Name = 'ContentSha256'
                Apply = {
                    param ($RecordToMutate)
                    $RecordToMutate.ContentSha256 = '0' * 64
                }
            },
            @{
                Name = 'Path'
                Apply = {
                    param ($RecordToMutate)
                    $RecordToMutate.Path = 'candidate-root/other'
                }
            },
            @{
                Name = 'ParentPath'
                Apply = {
                    param ($RecordToMutate)
                    $RecordToMutate.ParentPath = 'evil-root'
                }
            },
            @{
                Name = 'LeafName'
                Apply = {
                    param ($RecordToMutate)
                    $RecordToMutate.LeafName = 'other'
                }
            },
            @{
                Name = 'AddedProperty'
                Apply = {
                    param ($RecordToMutate)
                    $RecordToMutate.PSObject.Properties.Add(
                        [System.Management.Automation.PSNoteProperty]::new(
                            'Injected', [uint32]1))
                }
            },
            @{
                Name = 'RemovedProperty'
                Apply = {
                    param ($RecordToMutate)
                    $RecordToMutate.PSObject.Properties.Remove('ContentSha256')
                }
            },
            @{
                Name = 'TypeName'
                Apply = {
                    param ($RecordToMutate)
                    $RecordToMutate.PSObject.TypeNames.Insert(0, 'Evil.Injected.Type')
                }
            })) {
        $objRecord = & $scriptBlockFreshRecord
        & $hashtableMutation.Apply $objRecord
        $boolRefused = $false
        $strSubreason = 'none'
        try {
            [void](& $script:scriptBlockAssertCandidateHelperRecordUnchanged `
                -Record $objRecord -Snapshot $objSnapshot -PhaseValue 'destination')
        } catch {
            $boolRefused = $true
            $objMatch = [regex]::Match(
                [string]$_.Exception.Message, 'subreason=([a-z][a-z0-9-]*)')
            if ($objMatch.Success) {
                $strSubreason = $objMatch.Groups[1].Value
            }
        }
        if (-not $boolRefused -or $strSubreason -cne 'candidate-record') {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('candidate-record-unchanged-' + [string]$hashtableMutation.Name +
                    '-' + $strSubreason)
        }
    }
}

$script:scriptBlockAssertPreexistingRecordReproofRefused = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RunRoot
    )

    # Round 71 (Codex P2): before the irreversible destination create, expansion
    # re-proves the two PRE-EXISTING records the context manager issued -- the
    # seq-0 root and seq-1 download directories -- against snapshots captured at
    # authentication, with the guard generalised from the candidate re-proof.
    # Round 64 re-proved the candidate record only, so a same-session writer that
    # flipped a pre-existing record after authentication slipped past every
    # pre-create guard: the create ran, and only the post-append context assertion
    # rejected the record -- handing rollback a journal the manager refuses and
    # leaving the issued tree on disk. Reproduced end-to-end by flipping the seq-0
    # root record's EntryState from Created to Deleted in the auth-to-create window.
    # A same-session swap is not expressible as a catalog fixture (this file says so
    # at the journal-swap probe), so the guard sequence is replayed here on the real
    # production scriptblocks, in production's order.
    #
    # Behavioural, with a positive control, like the journal-swap probe. The HONEST
    # guard sequence must PASS; the sequence run after the seq-0 EntryState flip
    # must be REFUSED with subreason candidate-record BEFORE any create. Requiring
    # the control to pass gives it teeth: a guard that always threw would fail the
    # control. And if the attack is NOT refused -- the state a reverted fix returns
    # to -- the probe replays the create, the marking, the post-create context
    # assertion, and the real rollback exactly as expansion does, and fails on the
    # leak the manager then retains: rollback validates the corrupted journal,
    # refuses with FilesystemCallCount 0, and leaves the issued root on disk.
    # Removing the pre-existing EntryState re-proof reddens this probe on that leak;
    # removing the re-proof calls is pinned by scriptBlockAssertRound63JournalPlanWired.
    $strReproofRoot = [System.IO.Path]::Combine($RunRoot, 'preexisting-reproof')
    [void][System.IO.Directory]::CreateDirectory($strReproofRoot)
    $objReproofContext = New-StyleGuideCandidateInvocationContext `
        -TrustedTemporaryRoot $strReproofRoot -DiagnosticLabel 'preexisting-reproof'
    try {
        $objReproofJournal = & $script:scriptBlockAssertCandidateHelperContext `
            -ContextValue $objReproofContext
        $uintReproofSequence = [uint32]$objReproofJournal.Count
        $scriptBlockReproofSnapshot = {
            param ($Record)
            [pscustomobject]@{
                Sequence   = [uint32]$Record.Sequence
                Path       = [string]$Record.Path
                ParentPath = [string]$Record.ParentPath
                LeafName   = [string]$Record.LeafName
            }
        }
        $objCandidateSnapshot = & $scriptBlockReproofSnapshot (@($objReproofJournal |
            Where-Object { $_.Kind -eq 'CandidateDirectory' })[0])
        $objRootSnapshot = & $scriptBlockReproofSnapshot (@($objReproofJournal |
            Where-Object { $_.Kind -eq 'InvocationRootDirectory' })[0])
        $objDownloadSnapshot = & $scriptBlockReproofSnapshot (@($objReproofJournal |
            Where-Object { $_.Kind -eq 'DownloadDirectory' })[0])
        $strReproofCandidateDirectory = [string]$objReproofContext.CandidatePath
        $strReproofRootDirectory = [string]$objReproofContext.InvocationRootPath

        # The pre-create guard sequence expansion runs, on the real scriptblocks
        # and in the real order: the journal-current reference guard, then the
        # candidate re-proof, then the two pre-existing-record re-proofs.
        $scriptBlockReproofGuards = {
            param (
                $Context,
                $Journal,
                $Sequence,
                $CandidateSnapshot,
                $RootSnapshot,
                $DownloadSnapshot
            )
            & $script:scriptBlockAssertCandidateHelperJournalCurrent `
                -ContextValue $Context -JournalValue $Journal `
                -NextSequenceValue $Sequence -PhaseValue 'destination'
            & $script:scriptBlockAssertCandidateHelperRecordUnchanged `
                -Record $Journal[$CandidateSnapshot.Sequence] `
                -Snapshot $CandidateSnapshot `
                -PhaseValue 'destination'
            & $script:scriptBlockAssertCandidateHelperRecordUnchanged `
                -Record $Journal[$RootSnapshot.Sequence] -Snapshot $RootSnapshot `
                -ExpectedKind 'InvocationRootDirectory' -ExpectedEntryState 'Created' `
                -PhaseValue 'destination'
            & $script:scriptBlockAssertCandidateHelperRecordUnchanged `
                -Record $Journal[$DownloadSnapshot.Sequence] -Snapshot $DownloadSnapshot `
                -ExpectedKind 'DownloadDirectory' -ExpectedEntryState 'Created' `
                -PhaseValue 'destination'
        }

        # Control: the honest guard sequence must pass.
        $boolReproofControlPassed = $true
        try {
            & $scriptBlockReproofGuards $objReproofContext $objReproofJournal `
                $uintReproofSequence $objCandidateSnapshot $objRootSnapshot `
                $objDownloadSnapshot
        } catch {
            $boolReproofControlPassed = $false
        }
        if (-not $boolReproofControlPassed) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail 'preexisting-reproof-control-refused'
        }

        # Attack: flip the seq-0 root record's EntryState after authentication, in
        # place -- the journal array reference and NextSequence are unchanged, so
        # the journal-current guard cannot see it. Only the pre-existing-record
        # re-proof can.
        $objReproofJournal[$objRootSnapshot.Sequence].EntryState = 'Deleted'
        $boolReproofRefused = $false
        $strReproofSubreason = 'none'
        try {
            & $scriptBlockReproofGuards $objReproofContext $objReproofJournal `
                $uintReproofSequence $objCandidateSnapshot $objRootSnapshot `
                $objDownloadSnapshot
        } catch {
            $boolReproofRefused = $true
            $objReproofMatch = [regex]::Match(
                [string]$_.Exception.Message, 'subreason=([a-z][a-z0-9-]*)')
            if ($objReproofMatch.Success) {
                $strReproofSubreason = $objReproofMatch.Groups[1].Value
            }
        }

        if ($boolReproofRefused) {
            # Refused before the create, as clean production does. The subreason
            # must name the record guard, and nothing may have been created.
            if ($strReproofSubreason -cne 'candidate-record') {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                    -Detail ('preexisting-reproof-subreason-' + $strReproofSubreason)
            }
            if ([System.IO.Directory]::Exists($strReproofCandidateDirectory)) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                    -Detail 'preexisting-reproof-created-despite-refusal'
            }
        } else {
            # NOT refused: the state a reverted pre-existing-record re-proof returns
            # to. Replay the create, the marking, the post-create context assertion
            # and the real rollback exactly as expansion does, then fail on the leak
            # the manager retains.
            $null = [System.IO.Directory]::CreateDirectory($strReproofCandidateDirectory)
            $objReproofCandidateLive =
                $objReproofContext.OwnershipJournal[$objCandidateSnapshot.Sequence]
            $objReproofCandidateLive.CreationPhase = 'destination'
            $objReproofCandidateLive.EntryState = 'Created'
            try {
                [void](& $script:scriptBlockAssertCandidateHelperContext `
                    -ContextValue $objReproofContext)
            } catch {
                Write-Debug ('Expected corrupted-context refusal: {0}' -f $_)
            }
            [void](Remove-StyleGuideCandidateInvocationState -Context $objReproofContext)
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('preexisting-reproof-attack-not-refused-rootleak-' +
                    [string]([System.IO.Directory]::Exists($strReproofRootDirectory)))
        }
    } finally {
        # The context was deliberately corrupted, so its own cleanup is not trusted
        # to dispose the tree; remove the probe root directly.
        if ([System.IO.Directory]::Exists($strReproofRoot)) {
            [System.IO.Directory]::Delete($strReproofRoot, $true)
        }
    }
}

$script:scriptBlockAssertRound63JournalPlanWired = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath
    )

    # Round 63 (Codex): the journal-plan fixes pinned as structural regressions,
    # in the count/existence shape the wiring assertion below documents and for
    # the same reason -- a same-session journal swap is not expressible as a
    # catalog fixture (this file says so at line 818), so reverting any one of
    # these left all 115 cases green. Each pin fails closed on revert:
    #
    #   * The context assertion READS the OwnershipJournal member off the
    #     caller's object at exactly two sites -- where it captures and validates
    #     the journal it returns, and the journal-current reference guard. Every
    #     other read this PR removed was a post-assertion re-read that could
    #     observe a decoy the assertion never validated; reverting the cleanup or
    #     primary capture to a live $Context.OwnershipJournal read adds a third,
    #     whatever receiver name it is spelled with (the HH2 lesson: count the
    #     member, not the receiver).
    #   * The assertion returns that captured array as the plan; without the
    #     return the two captures above bind $null.
    #   * The destination create carries the candidate-record identity guard that
    #     re-proves Kind and Path before the create.
    $objErrors = $null
    $objAst = [System.Management.Automation.Language.Parser]::ParseFile(
        $LiteralPath, [ref]$null, [ref]$objErrors)
    if ($null -eq $objAst -or @($objErrors).Count -ne 0) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail 'round63-plan-parse'
    }

    $arrJournalMember = @($objAst.FindAll(
            {
                param ($SyntaxNode)
                return ($SyntaxNode -is
                    [System.Management.Automation.Language.MemberExpressionAst] -and
                    $SyntaxNode.Member -is
                    [System.Management.Automation.Language.StringConstantExpressionAst] -and
                    ([string]$SyntaxNode.Member.Value) -ceq 'OwnershipJournal')
            },
            $true
        ))
    # Every OwnershipJournal member expression that is NOT the left side of an
    # assignment is a read; the sole write is the append's re-publication.
    $arrJournalRead = @($arrJournalMember | Where-Object {
            -not ($_.Parent -is
                [System.Management.Automation.Language.AssignmentStatementAst] -and
                [System.Object]::ReferenceEquals($_.Parent.Left, $_))
        })
    if (@($arrJournalRead).Count -ne 2) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail ('round63-journal-read-count-' + [string]@($arrJournalRead).Count)
    }

    $strText = [System.IO.File]::ReadAllText($LiteralPath)
    $intReturn = @([regex]::Matches(
        $strText, '(?m)^\s*return ,\$objJournal\s*$')).Count
    if ($intReturn -ne 1) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail ('round63-plan-return-' + [string]$intReturn)
    }
    # At least one candidate-record refusal must exist -- the guard is present.
    # Round 63 pinned this at exactly one inline stop; round 64 moved it into
    # scriptBlockAssertCandidateHelperRecordUnchanged and round 65 added the
    # shape and type-name proofs, so the stop count is no longer fixed. Total
    # removal (zero) still trips here; which individual field or shape proof is
    # present is pinned by scriptBlockAssertCandidateRecordUnchangedRefused.
    $intIdentityGuard = @([regex]::Matches(
        $strText, "-Subreason 'candidate-record'")).Count
    if ($intIdentityGuard -lt 1) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail ('round63-candidate-record-guard-' + [string]$intIdentityGuard)
    }
    # Round 71 (Codex P2): the destination create additionally re-proves the two
    # PRE-EXISTING records -- the seq-0 root and seq-1 download directories -- each
    # by its own ExpectedKind, before the irreversible create. Removing either call
    # is a same-session-swap regression not expressible as a catalog fixture, so
    # exactly one re-proof call per pre-existing kind is pinned here; total removal
    # reddens this. The generalised guard's refusal BEHAVIOUR -- that a flipped
    # pre-existing record is refused before the create -- is exercised by
    # scriptBlockAssertPreexistingRecordReproofRefused.
    foreach ($strReproofKind in @('InvocationRootDirectory', 'DownloadDirectory')) {
        $intReproofCall = @([regex]::Matches(
            $strText, "-ExpectedKind '" + $strReproofKind + "'")).Count
        if ($intReproofCall -ne 1) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('round71-preexisting-reproof-' + $strReproofKind +
                    '-' + [string]$intReproofCall)
        }
    }
}

$script:scriptBlockAssertOrdinaryFileProofWired = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath
    )

    # Round 57's JJ4: the post-extraction reader must prove the path is an
    # ordinary regular file immediately before opening it. W-06 already
    # exercises the proof's BEHAVIOUR on the download open (a FIFO as the sole
    # download entry is refused), so a broken proof is caught. What no committed
    # case caught was the proof's CALL going missing at the post-extraction
    # open: measured, deleting that one call left all 115 cases green, because
    # every real extracted file is an ordinary file that the FileStream open
    # accepts whether or not the proof ran.
    #
    # Production invokes scriptBlockAssertCandidateHelperOrdinaryRegularFile at
    # three sites, and fewer than three means a reader lost its ordinariness
    # proof. Round 60 adds a second requirement in the same shape: every
    # ownership record must be published through scriptBlockAddCandidateHelperRecord,
    # whose reference-identity guard is what the journal-swap probe exercises --
    # Codex observed that the probe invokes that helper directly, so an
    # expansion edit that appended records inline, bypassing the helper, would
    # not be caught. Production appends at two sites; fewer than two means a
    # publication went inline, around the guard.
    #
    # AST rather than source text, for the reasons the resource-guard wiring
    # assertion states: a commented-out or literal-decoy line is not an
    # executable invocation and does not appear here.
    #
    # This pins the COUNT, not the POSITION. A decoy invocation elsewhere could
    # hold a count at its floor while a real call was removed; the stronger form
    # pins each open (or each publication) to its guard by dataflow, and is
    # recorded as recommended rather than taken -- a wide-surface AST rule is
    # exactly what this loop has been burned writing, and the realistic
    # regression is a dropped call, which a count catches.
    $objErrors = $null
    $objAst = [System.Management.Automation.Language.Parser]::ParseFile(
        $LiteralPath, [ref]$null, [ref]$objErrors)
    if ($null -eq $objAst -or @($objErrors).Count -ne 0) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail 'production-ordinary-file-proof-parse'
    }
    $arrCommandAst = @($objAst.FindAll(
            {
                param ($SyntaxNode)
                return ($SyntaxNode -is
                    [System.Management.Automation.Language.CommandAst] -and
                    @($SyntaxNode.CommandElements).Count -ge 1 -and
                    $SyntaxNode.CommandElements[0] -is
                    [System.Management.Automation.Language.VariableExpressionAst])
            },
            $true
        ))
    foreach ($hashtableRequirement in @(
            @{ Name = 'scriptBlockAssertCandidateHelperOrdinaryRegularFile'
                Minimum = 3; Detail = 'production-ordinary-file-proof' },
            @{ Name = 'scriptBlockAddCandidateHelperRecord'
                Minimum = 2; Detail = 'production-journal-append' },
            # Round 61 (Codex F2): the journal-current guard must run before the
            # destination create as well as inside the append helper, so a
            # same-session swap in the pre-destination window is caught before
            # the irreversible CreateDirectory rather than after, at the next
            # append, when rollback has already been handed the decoy.
            # Round 63 (Codex) carried the same guard to the extraction FILE
            # create, and round 64 (Codex) to the DOWNLOAD phase entry, which
            # opened and hashed the archive with no journal-current check before
            # the download append. So production now calls
            # scriptBlockAssertCandidateHelperJournalCurrent at exactly four
            # sites -- the append helper, the download-phase entry, the
            # destination create, and each file create -- and fewer than four
            # means one lost its guard. Measured: deleting any one left all 115
            # cases green, the same invisibility the round-59 wiring pins were
            # added for.
            #
            # Round 64 (Codex) also factored the candidate-directory record's
            # pre-create field re-proof into
            # scriptBlockAssertCandidateHelperRecordUnchanged, called once before
            # the create; its per-field coverage is exercised in isolation by
            # scriptBlockAssertCandidateRecordUnchangedRefused.
            @{ Name = 'scriptBlockAssertCandidateHelperJournalCurrent'
                Minimum = 4; Detail = 'production-journal-current-guard' },
            @{ Name = 'scriptBlockAssertCandidateHelperRecordUnchanged'
                Minimum = 1; Detail = 'production-candidate-record-unchanged' })) {
        $intCalls = @($arrCommandAst | Where-Object {
                ([string]$_.CommandElements[0].VariablePath.UserPath) -ceq
                    ('script:' + [string]$hashtableRequirement.Name)
            }).Count
        if ($intCalls -lt [int]$hashtableRequirement.Minimum) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ([string]$hashtableRequirement.Detail + '-' + $intCalls)
        }
    }
}

$script:scriptBlockAssertDownloadLeafGuardExecutes = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$HelperLiteralPath,

        [Parameter(Mandatory = $true)]
        [string]$RunRoot
    )

    $strProbeRoot = [System.IO.Path]::Combine($RunRoot, 'download-leaf-guard')
    [void][System.IO.Directory]::CreateDirectory($strProbeRoot)
    $strCheckoutRoot = [System.IO.Path]::Combine($strProbeRoot, 'checkout')
    [void][System.IO.Directory]::CreateDirectory($strCheckoutRoot)
    $strTrustedRoot = [System.IO.Path]::Combine($strProbeRoot, 'trusted')
    [void][System.IO.Directory]::CreateDirectory($strTrustedRoot)

    $objInvalidLeafChar = New-Object 'System.Collections.Generic.HashSet[char]' (
        ,[char[]][System.IO.Path]::GetInvalidFileNameChars()
    )
    # A valid archive under each leaf, so the only thing that can differ between
    # the two runs is the leaf rule itself. 'build[1].zip' must be processed --
    # brackets are PowerShell wildcard syntax but every operation downstream of
    # a journaled path is literal. 'star*.zip' must be refused, because its leaf
    # cannot serve as the literal search pattern cleanup will need.
    foreach ($hashtableCase in @(
            @{ Leaf = 'build[1].zip'; MustSucceed = $true },
            @{ Leaf = 'star*.zip'; MustSucceed = $false })) {
        $strLeaf = [string]$hashtableCase.Leaf
        $boolNameable = $true
        foreach ($chrLeaf in $strLeaf.ToCharArray()) {
            if ($objInvalidLeafChar.Contains($chrLeaf)) {
                $boolNameable = $false
            }
        }
        # Windows cannot name '*', so the refusal is unobservable there rather
        # than expected to fail.
        if (-not $boolNameable) {
            continue
        }

        $objProbeContext = New-StyleGuideCandidateInvocationContext `
            -TrustedTemporaryRoot $strTrustedRoot
        $strArchivePath = [System.IO.Path]::Combine(
            $objProbeContext.DownloadDirectoryPath, $strLeaf)
        $objArchive = [System.IO.Compression.ZipFile]::Open(
            $strArchivePath, [System.IO.Compression.ZipArchiveMode]::Create)
        try {
            foreach ($strEntryName in @(
                'copilot-instructions.md',
                'powershell.instructions.md',
                'STYLE_GUIDE_CHAT.md',
                'STYLE_GUIDE_FULL.md'
            )) {
                $objEntry = $objArchive.CreateEntry($strEntryName)
                $objEntryWriter = New-Object System.IO.StreamWriter($objEntry.Open())
                try {
                    $objEntryWriter.Write('# ' + $strEntryName)
                } finally {
                    $objEntryWriter.Dispose()
                }
            }
        } finally {
            $objArchive.Dispose()
        }
        $objSha256 = [System.Security.Cryptography.SHA256]::Create()
        try {
            $objArchiveStream = [System.IO.File]::OpenRead($strArchivePath)
            try {
                $strExpectedDigest = (
                    [System.BitConverter]::ToString(
                        $objSha256.ComputeHash($objArchiveStream)
                    ) -replace '-', ''
                ).ToLowerInvariant()
            } finally {
                $objArchiveStream.Dispose()
            }
        } finally {
            $objSha256.Dispose()
        }

        $boolSucceeded = $false
        $strObservedSubreason = 'none'
        try {
            [void](& $HelperLiteralPath `
                -Context $objProbeContext `
                -CheckoutRoot $strCheckoutRoot `
                -TrustedTemporaryRoot $strTrustedRoot `
                -DownloadDirectory $objProbeContext.DownloadDirectoryPath `
                -CandidateDirectory $objProbeContext.CandidatePath `
                -ExpectedDigest $strExpectedDigest)
            $boolSucceeded = $true
        } catch {
            $objSubreason = [regex]::Match(
                [string]$_.Exception.Message, 'subreason=([a-z][a-z0-9-]*)')
            if ($objSubreason.Success) {
                $strObservedSubreason = $objSubreason.Groups[1].Value
            }
        }
        if ($boolSucceeded -ne [bool]$hashtableCase.MustSucceed) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('download-leaf-guard-' + $(if ($boolSucceeded) {
                    'admitted'
                } else {
                    'refused'
                }))
        }
        # Which refusal, not merely that one happened. A leaf carrying '*' is
        # refused twice over: once where it is adopted, and again by the context
        # validator when the record reaches it. Asserting only that expansion
        # failed cannot tell those apart, so bypassing the adoption check left
        # this green -- measured, with the archive journaled unvalidated first,
        # which is the whole defect. The subreason is closed-taxonomy contract
        # rather than incidental message text, so pinning it does not make this
        # a source-shaped assertion again.
        if (-not $hashtableCase.MustSucceed -and $strObservedSubreason -cne 'entry-name') {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('download-leaf-guard-late-' + $strObservedSubreason)
        }
    }
}

# This used to assert that the validator was the first command naming
# $strArchivePath, which is a statement about source ORDER, and source order is
# satisfied by code that never runs. Leaving an unreachable copy at the original
# location while moving the real call after the metadata read passed both this
# and the behavioural probe above: 115 records, zero failures, with the leaf
# touched before it was checked.
#
# Order is the wrong property to pin. Production no longer validates a value it
# already holds -- the validator PRODUCES the value -- so what is pinned now is
# provenance: $strArchivePath is assigned exactly once, and that assignment is
# the validator call. A dormant copy cannot satisfy this, because a dead copy is
# either a second assignment or not the assignment at all, and both fail.
$script:scriptBlockAssertDownloadPathProvenance = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$HelperLiteralPath
    )

    $objErrors = $null
    $objAst = [System.Management.Automation.Language.Parser]::ParseFile(
        $HelperLiteralPath, [ref]$null, [ref]$objErrors)
    if ($null -eq $objAst -or @($objErrors).Count -ne 0) {
        & $script:scriptBlockStopHarness `
            -Code 'catalog-invalid' -Detail 'download-path-parse'
    }
    $arrAssignment = @($objAst.FindAll(
            {
                param ($SyntaxNode)
                $SyntaxNode -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                $SyntaxNode.Left.Extent.Text -ceq '$strArchivePath'
            },
            $true
        ))
    if ($arrAssignment.Count -ne 1) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail ('download-path-assignment-' + $arrAssignment.Count)
    }
    # The producing call, wherever it sits inside casts or parentheses on the
    # right-hand side. Naming the scriptblock is what matters, not the shape of
    # the expression wrapped around it.
    $arrProducer = @($arrAssignment[0].Right.FindAll(
            {
                param ($SyntaxNode)
                $SyntaxNode -is [System.Management.Automation.Language.CommandAst] -and
                @($SyntaxNode.CommandElements).Count -gt 0 -and
                $SyntaxNode.CommandElements[0] -is
                    [System.Management.Automation.Language.VariableExpressionAst]
            },
            $true
        ))
    $strProducer = if ($arrProducer.Count -eq 1) {
        [string]$arrProducer[0].CommandElements[0].VariablePath.UserPath -creplace '^script:', ''
    } else {
        ''
    }
    if ($strProducer -cne 'scriptBlockGetCandidateHelperValidatedDownloadPath') {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail ('download-path-producer-' + $strProducer)
    }
}

# The archive ceiling is a bound on a number the stream can change underneath
# it. On Unix a held handle observes in-place growth -- the helper's own comment
# has said so since the single-retained-stream amendment -- so a ceiling checked
# against one read of Length and an allocation sized by a second read are not
# bounded by each other. Measured: a file admitted at 1,024 bytes and grown by
# another writer reported 268,436,480 bytes at the allocation.
#
# What is pinned is the SOURCE of the danger rather than the shape of the
# allocation. Pinning the allocation expression would be satisfied by any
# editor who spelled it differently -- `[byte[]]::new(...)` instead of
# `New-Object byte[]` -- which is the same escape a reviewer found in the
# enumeration rule this suite already carries. A second read of Length is the
# thing that reintroduces the defect, whatever is done with it, so a second read
# is what fails here.
$script:scriptBlockAssertArchiveLengthReadOnce = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$HelperLiteralPath
    )

    $objErrors = $null
    $objAst = [System.Management.Automation.Language.Parser]::ParseFile(
        $HelperLiteralPath, [ref]$null, [ref]$objErrors)
    if ($null -eq $objAst -or @($objErrors).Count -ne 0) {
        & $script:scriptBlockStopHarness `
            -Code 'catalog-invalid' -Detail 'archive-length-parse'
    }
    # Any member access named Length whose target is the archive stream
    # variable, however the access is spelled.
    $arrLengthRead = @($objAst.FindAll(
            {
                param ($SyntaxNode)
                if ($SyntaxNode -isnot
                    [System.Management.Automation.Language.MemberExpressionAst]) {
                    return $false
                }
                if ($SyntaxNode.Expression -isnot
                    [System.Management.Automation.Language.VariableExpressionAst]) {
                    return $false
                }
                if ($SyntaxNode.Expression.VariablePath.UserPath -cne 'objArchiveStream') {
                    return $false
                }
                $strMember = if ($SyntaxNode.Member -is
                    [System.Management.Automation.Language.StringConstantExpressionAst]) {
                    [string]$SyntaxNode.Member.Value
                } else {
                    [string]$SyntaxNode.Member.Extent.Text
                }
                return ($strMember -ceq 'Length')
            },
            $true
        ))
    if (@($arrLengthRead).Count -ne 1) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail ('archive-length-read-' + @($arrLengthRead).Count)
    }
}

$script:scriptBlockResolveCandidateArgumentType = {
    param (
        [AllowNull()]
        [object]$Argument,

        [Parameter(Mandatory = $true)]
        [hashtable]$VariableType
    )

    # Round 28's rule read argument types only from variables, which made the
    # signature check indeterminate the moment an argument was written inline --
    # and indeterminate means "proven by name and arity only". Name and arity
    # are exactly what the round-28 ACL defect satisfied, so inlining
    # `New-Object DirectoryInfo(...)` at that call would have re-admitted it.
    # The AST settles these forms as surely as it settles an assignment, so
    # they are read rather than skipped.
    if ($null -eq $Argument) {
        return ''
    }
    # ([T]::new(...)) and (New-Object T) arrive wrapped in parentheses when
    # written as an argument, so the wrapper is stepped through first.
    $objInner = $Argument
    while ($objInner -is
        [System.Management.Automation.Language.ParenExpressionAst]) {
        $objInner = $objInner.Pipeline
        if ($objInner -is [System.Management.Automation.Language.PipelineAst]) {
            $arrElement = @($objInner.PipelineElements)
            if ($arrElement.Count -ne 1) {
                return ''
            }
            $objInner = $arrElement[0]
        }
        if ($objInner -is
            [System.Management.Automation.Language.CommandExpressionAst]) {
            $objInner = $objInner.Expression
        }
    }
    if ($objInner -is
        [System.Management.Automation.Language.VariableExpressionAst]) {
        $strVariable = [string]$objInner.VariablePath.UserPath
        if ($VariableType.ContainsKey($strVariable)) {
            return [string]$VariableType[$strVariable]
        }
        return ''
    }
    if ($objInner -is
        [System.Management.Automation.Language.ConvertExpressionAst]) {
        # A cast states the type outright.
        return [string]$objInner.Type.TypeName.FullName
    }
    if ($objInner -is
        [System.Management.Automation.Language.InvokeMemberExpressionAst] -and
        $objInner.Static -and
        $objInner.Expression -is
        [System.Management.Automation.Language.TypeExpressionAst] -and
        $objInner.Member -is
        [System.Management.Automation.Language.StringConstantExpressionAst] -and
        ([string]$objInner.Member.Value) -ceq 'new') {
        return [string]$objInner.Expression.TypeName.FullName
    }
    if ($objInner -is
        [System.Management.Automation.Language.CommandAst] -and
        ([string]$objInner.GetCommandName()) -ceq 'New-Object') {
        $arrElements = @($objInner.CommandElements)
        for ($intIndex = 1; $intIndex -lt $arrElements.Count; $intIndex++) {
            if ($arrElements[$intIndex] -is
                [System.Management.Automation.Language.StringConstantExpressionAst]) {
                return [string]$arrElements[$intIndex].Value
            }
        }
        return ''
    }
    if ($objInner -is
        [System.Management.Automation.Language.StringConstantExpressionAst] -or
        $objInner -is
        [System.Management.Automation.Language.ExpandableStringExpressionAst]) {
        return 'System.String'
    }
    if ($objInner -is
        [System.Management.Automation.Language.ConstantExpressionAst]) {
        if ($null -eq $objInner.Value) {
            return ''
        }
        return [string]$objInner.StaticType.FullName
    }
    return ''
}

$script:scriptBlockAssertStaticMembersResolve = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$HelperLiteralPath,

        [Parameter(Mandatory = $true)]
        [string]$ContextLiteralPath
    )

    # Round 28 shipped a call to
    # [System.IO.FileSystemAclExtensions]::CreateDirectory(DirectoryInfo,
    # DirectorySecurity). That member does not exist -- the type carries
    # Create(DirectoryInfo, DirectorySecurity) and
    # CreateDirectory(DirectorySecurity, String) -- so the call threw
    # MethodException at bind time and every Windows PowerShell 7 context
    # creation refused. Nothing caught it, because the only place it could fail
    # was a platform this suite cannot run.
    #
    # It does not need that platform. Binding is decided by the reflection
    # surface of the type, and System.IO.FileSystem.AccessControl ships on
    # Linux even though its methods throw PlatformNotSupportedException there --
    # measured, the type resolves on .NET 8 and .NET 10 here. So the member can
    # be proven present, with an overload that accepts the argument types, on
    # the runtimes this suite actually runs.
    #
    # Arity alone would not have caught it: the call passes two arguments and
    # CreateDirectory takes two. The parameter types are what disagree, so the
    # types are what this checks. Where an argument's type cannot be determined
    # it is skipped rather than guessed, and the skipped count is reported so
    # the coverage claim stays honest.
    $arrTarget = @(
        @{ Label = 'helper'; Path = $HelperLiteralPath },
        @{ Label = 'context'; Path = $ContextLiteralPath }
    )
    foreach ($hashtableTarget in $arrTarget) {
        $objErrors = $null
        $objAst = [System.Management.Automation.Language.Parser]::ParseFile(
            [string]$hashtableTarget.Path, [ref]$null, [ref]$objErrors)
        if ($null -eq $objAst -or @($objErrors).Count -ne 0) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('static-member-parse-' + [string]$hashtableTarget.Label)
        }

        # Every New-Object with a literal type name, and every [T]::new(),
        # assigned to a plain variable. One variable assigned two different
        # types is recorded as indeterminate rather than as either of them.
        $hashtableVariableType = @{}
        $arrAssignment = @($objAst.FindAll(
                {
                    param ($SyntaxNode)
                    return ($SyntaxNode -is
                        [System.Management.Automation.Language.AssignmentStatementAst])
                },
                $true
            ))
        foreach ($objAssignment in $arrAssignment) {
            if ($objAssignment.Left -isnot
                [System.Management.Automation.Language.VariableExpressionAst]) {
                continue
            }
            $strVariable = [string]$objAssignment.Left.VariablePath.UserPath
            $strTypeName = ''
            $objRight = $objAssignment.Right
            if ($objRight -is
                [System.Management.Automation.Language.CommandExpressionAst]) {
                $objRight = $objRight.Expression
            }
            if ($objRight -is
                [System.Management.Automation.Language.InvokeMemberExpressionAst] -and
                $objRight.Static -and
                $objRight.Expression -is
                [System.Management.Automation.Language.TypeExpressionAst] -and
                $objRight.Member -is
                [System.Management.Automation.Language.StringConstantExpressionAst] -and
                ([string]$objRight.Member.Value) -ceq 'new') {
                $strTypeName = [string]$objRight.Expression.TypeName.FullName
            } elseif ($objRight -is
                [System.Management.Automation.Language.PipelineAst]) {
                $arrElement = @($objRight.PipelineElements)
                if ($arrElement.Count -eq 1 -and $arrElement[0] -is
                    [System.Management.Automation.Language.CommandAst]) {
                    $objCommand = $arrElement[0]
                    if (([string]$objCommand.GetCommandName()) -ceq 'New-Object') {
                        $arrElements = @($objCommand.CommandElements)
                        for ($intIndex = 1; $intIndex -lt $arrElements.Count; $intIndex++) {
                            if ($arrElements[$intIndex] -is
                                [System.Management.Automation.Language.StringConstantExpressionAst]) {
                                $strTypeName = [string]$arrElements[$intIndex].Value
                                break
                            }
                        }
                    }
                }
            }
            if ($strTypeName.Length -eq 0) {
                $hashtableVariableType[$strVariable] = ''
                continue
            }
            if ($hashtableVariableType.ContainsKey($strVariable) -and
                ([string]$hashtableVariableType[$strVariable]) -cne $strTypeName) {
                $hashtableVariableType[$strVariable] = ''
                continue
            }
            $hashtableVariableType[$strVariable] = $strTypeName
        }

        # Every [T]::Member(...) whose type and member name are both literal.
        $arrStaticCall = @($objAst.FindAll(
                {
                    param ($SyntaxNode)
                    if ($SyntaxNode -isnot
                        [System.Management.Automation.Language.InvokeMemberExpressionAst]) {
                        return $false
                    }
                    if (-not $SyntaxNode.Static) {
                        return $false
                    }
                    if ($SyntaxNode.Expression -isnot
                        [System.Management.Automation.Language.TypeExpressionAst]) {
                        return $false
                    }
                    return ($SyntaxNode.Member -is
                        [System.Management.Automation.Language.StringConstantExpressionAst])
                },
                $true
            ))
        $intSkippedType = 0
        $intSkippedArgument = 0
        $intProvenName = 0
        $intProvenSignature = 0
        foreach ($objCall in $arrStaticCall) {
            $strTypeName = [string]$objCall.Expression.TypeName.FullName
            $strMember = [string]$objCall.Member.Value
            $typeTarget = $strTypeName -as [type]
            if ($null -eq $typeTarget) {
                # Absent on this runtime, so nothing here can be decided. The
                # production branch that reaches it must resolve the type first.
                $intSkippedType++
                continue
            }
            # `[T]::new(...)` used to be counted proven the moment the type
            # resolved: no constructor was ever looked up, so a call with the
            # wrong arguments passed the very guard that exists to catch a
            # binding failure on a branch no test executes. That is the defect
            # this whole routine was written for, left open in the one syntax
            # that names no method. Reported at round 52.
            #
            # ConstructorInfo and MethodInfo both expose GetParameters(), so
            # the arity and argument-type checks below need no special case --
            # only the overload set is chosen differently.
            if ($strMember -ceq 'new') {
                $arrOverload = @($typeTarget.GetConstructors(
                        [System.Reflection.BindingFlags]::Public -bor
                        [System.Reflection.BindingFlags]::Instance
                    ))
            } else {
                $arrOverload = @($typeTarget.GetMethods(
                        [System.Reflection.BindingFlags]::Public -bor
                        [System.Reflection.BindingFlags]::Static
                    ) | Where-Object { ([string]$_.Name) -ceq $strMember })
            }
            if ($arrOverload.Count -eq 0) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                    -Detail ('static-member-absent-' + $strMember + '-' +
                        [string]$objCall.Extent.StartLineNumber)
            }
            $intProvenName++
            # Arguments is null rather than empty for a no-argument call, and
            # @($null) counts one, which would read as arity 1. The empty array
            # is assigned directly rather than returned from an if, because an
            # empty array emitted as the value of a statement block unwraps to
            # nothing and would leave this null.
            $arrArgument = @()
            if ($null -ne $objCall.Arguments) {
                $arrArgument = @($objCall.Arguments)
            }
            $arrByArity = @($arrOverload | Where-Object {
                    @($_.GetParameters()).Count -eq $arrArgument.Count
                })
            if ($arrByArity.Count -eq 0) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                    -Detail ('static-member-arity-' + $strMember + '-' +
                        [string]$objCall.Extent.StartLineNumber)
            }

            # Argument types, where the AST alone settles them. A variable is
            # usable only when every assignment to it named the same literal
            # type; anything else leaves the call proven by name and arity only.
            $arrArgumentType = New-Object System.Collections.ArrayList
            $boolTyped = $true
            foreach ($objArgument in $arrArgument) {
                $strArgumentType = & $script:scriptBlockResolveCandidateArgumentType `
                    -Argument $objArgument `
                    -VariableType $hashtableVariableType
                if ($strArgumentType.Length -eq 0) {
                    $boolTyped = $false
                    break
                }
                $typeArgument = $strArgumentType -as [type]
                if ($null -eq $typeArgument) {
                    $boolTyped = $false
                    break
                }
                $null = $arrArgumentType.Add($typeArgument)
            }
            if (-not $boolTyped) {
                $intSkippedArgument++
                continue
            }
            $boolAccepts = $false
            foreach ($objOverload in $arrByArity) {
                $arrParameter = @($objOverload.GetParameters())
                $boolMatch = $true
                for ($intIndex = 0; $intIndex -lt $arrParameter.Count; $intIndex++) {
                    if (-not $arrParameter[$intIndex].ParameterType.IsAssignableFrom(
                            $arrArgumentType[$intIndex])) {
                        $boolMatch = $false
                        break
                    }
                }
                if ($boolMatch) {
                    $boolAccepts = $true
                    break
                }
            }
            if (-not $boolAccepts) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                    -Detail ('static-member-signature-' + $strMember + '-' +
                        [string]$objCall.Extent.StartLineNumber)
            }
            $intProvenSignature++
        }
        if ($intProvenName -eq 0) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('static-member-none-' + [string]$hashtableTarget.Label)
        }
        Write-Verbose ('static members in ' + [string]$hashtableTarget.Label +
            ': name-proven ' + [string]$intProvenName +
            ', signature-proven ' + [string]$intProvenSignature +
            ', type absent here ' + [string]$intSkippedType +
            ', argument type undetermined ' + [string]$intSkippedArgument)
    }
}

$script:scriptBlockAssertLifecycleRecordStatesRejected = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RunRoot,

        [Parameter(Mandatory = $true)]
        [string]$HelperLiteralPath
    )

    # Both production validators pair each lifecycle state with the exact set of
    # record states that state admits. That pairing is the only thing between a
    # caller-supplied journal and the two terminal branches, which perform no
    # filesystem work and report owned entries rather than removing them. A
    # CleanupFailed context carrying a surviving Created record names an entry
    # that is owned and present on disk yet absent from RetainedRecordSequences,
    # so nothing removes it and nothing tells the operator it is there.
    #
    # The catalog cannot reach this. Every one of its cases begins Active or
    # NotCreated, so no row ever hands a terminal context to either entry point.
    # The check lives here instead.
    #
    # It drives the real public functions rather than reading source text.
    # Source-shaped assertions in this file have been defeated by moving code
    # into a deleted call site, a literal argument, a decoy variable, a comment,
    # and an unreachable branch; a check that observes returned results cannot
    # be satisfied by any of those.
    #
    # Both directions are asserted. Rejection rows alone would also pass against
    # a validator that refused everything, so the well-formed terminal contexts
    # are required to be accepted and to report exactly the sequences they own.
    $arrScenario = @(
        @{
            Name = 'active-retained'
            LifecycleState = 'Active'
            Mutation = @(@{ Index = 2; EntryState = 'RetainedUncertain' })
            ExpectedDiagnosticCode = 'cleanup-context-invalid'
            ExpectedRetainedSequence = [uint32[]]@()
        },
        @{
            Name = 'disposed-created'
            LifecycleState = 'Disposed'
            Mutation = @()
            ExpectedDiagnosticCode = 'cleanup-context-invalid'
            ExpectedRetainedSequence = [uint32[]]@()
        },
        @{
            Name = 'disposed-retained'
            LifecycleState = 'Disposed'
            Mutation = @(
                @{ Index = 0; EntryState = 'Deleted' },
                @{ Index = 1; EntryState = 'Deleted' },
                @{ Index = 2; EntryState = 'RetainedUncertain' }
            )
            ExpectedDiagnosticCode = 'cleanup-context-invalid'
            ExpectedRetainedSequence = [uint32[]]@()
        },
        @{
            Name = 'failed-created'
            LifecycleState = 'CleanupFailed'
            Mutation = @(@{ Index = 1; EntryState = 'RetainedUncertain' })
            ExpectedDiagnosticCode = 'cleanup-context-invalid'
            ExpectedRetainedSequence = [uint32[]]@()
        },
        @{
            Name = 'failed-unretained'
            LifecycleState = 'CleanupFailed'
            Mutation = @(
                @{ Index = 0; EntryState = 'Deleted' },
                @{ Index = 1; EntryState = 'Deleted' }
            )
            ExpectedDiagnosticCode = 'cleanup-context-invalid'
            ExpectedRetainedSequence = [uint32[]]@()
        },
        @{
            Name = 'failed-retained'
            LifecycleState = 'CleanupFailed'
            Mutation = @(
                @{ Index = 0; EntryState = 'RetainedUncertain' },
                @{ Index = 1; EntryState = 'RetainedUncertain' }
            )
            ExpectedDiagnosticCode = 'cleanup-terminal-failure'
            ExpectedRetainedSequence = [uint32[]]@([uint32]0, [uint32]1)
        },
        @{
            Name = 'disposed-clean'
            LifecycleState = 'Disposed'
            Mutation = @(
                @{ Index = 0; EntryState = 'Deleted' },
                @{ Index = 1; EntryState = 'Deleted' }
            )
            ExpectedDiagnosticCode = 'cleanup-already-disposed'
            ExpectedRetainedSequence = [uint32[]]@()
        }
    )

    # A terminal state the CALLER wrote, not the manager. Round 31 found this
    # returning cleanup-already-disposed with Success true and zero filesystem
    # calls while the invocation directory was still on disk -- a false success,
    # which is worse than a missed refusal, because a caller told the work
    # succeeded does not retry and the directory leaks. Pinned here so the
    # register that closed it cannot quietly stop being consulted.
    $strForgedStateRoot = [System.IO.Path]::Combine($RunRoot, 'forged-terminal-state')
    [void][System.IO.Directory]::CreateDirectory($strForgedStateRoot)
    $objForgedContext = New-StyleGuideCandidateInvocationContext `
        -TrustedTemporaryRoot $strForgedStateRoot `
        -DiagnosticLabel 'forged-terminal-state'
    $objForgedContext.LifecycleState = 'Disposed'
    foreach ($objForgedRecord in $objForgedContext.OwnershipJournal) {
        if ($objForgedRecord.EntryState -ceq 'Created') {
            $objForgedRecord.EntryState = 'Deleted'
        }
    }
    $objForgedResult = Remove-StyleGuideCandidateInvocationContext -Context $objForgedContext
    if ($objForgedResult.Success -or
        ([string]$objForgedResult.DiagnosticCode) -cne 'cleanup-context-altered') {
        & $script:scriptBlockStopHarness -Code 'orchestration-failed' `
            -Detail ('forged-terminal-state-' + [string]$objForgedResult.DiagnosticCode)
    }
    if (-not [System.IO.Directory]::Exists([string]$objForgedContext.InvocationRootPath)) {
        & $script:scriptBlockStopHarness -Code 'orchestration-failed' `
            -Detail 'forged-terminal-state-root-removed'
    }

    # The expansion-side issuance check, which until round 33 had nothing
    # asserting it at all. Round 30 added it, rounds 31 and 32 rewrote what
    # stood beside it, and no assertion would have noticed if any of that had
    # removed it -- so a protection this file argues for in prose was resting
    # on nobody deleting it by accident.
    #
    # Behavioural rather than positional on purpose. An ordering pin over the
    # source can be satisfied by code that never runs, which round 20 measured:
    # wrapping a branch in if ($false) left the suite green. This runs the real
    # entry point against a context this manager never issued and requires the
    # refusal to arrive in the parameter phase with the caller's download
    # directory untouched, which is a claim only the executed check can meet.
    #
    # The forgery is a structural clone under a trusted parent, naming its own
    # tree consistently in both the context and the parameters, so nothing
    # upstream of the issuance check has anything to catch: no path mismatch,
    # no schema defect, no state defect.
    $strUnissuedRoot = [System.IO.Path]::Combine($RunRoot, 'unissued-expansion')
    [void][System.IO.Directory]::CreateDirectory($strUnissuedRoot)
    $objUnissuedContext = New-StyleGuideCandidateInvocationContext `
        -TrustedTemporaryRoot $strUnissuedRoot `
        -DiagnosticLabel 'unissued-expansion'
    $strUnissuedTree = [System.IO.Path]::Combine($strUnissuedRoot, 'aaaaaaaa.unissued')
    $strUnissuedDownload = [System.IO.Path]::Combine($strUnissuedTree, 'download')
    $strUnissuedCandidate = [System.IO.Path]::Combine($strUnissuedTree, 'candidate')
    [void][System.IO.Directory]::CreateDirectory($strUnissuedDownload)
    $objUnissuedContext.InvocationRootPath = $strUnissuedTree
    $objUnissuedContext.DownloadDirectoryPath = $strUnissuedDownload
    $objUnissuedContext.CandidatePath = $strUnissuedCandidate
    $objUnissuedContext.OwnershipJournal[0].Path = $strUnissuedTree
    $objUnissuedContext.OwnershipJournal[0].ParentPath = $strUnissuedRoot
    $objUnissuedContext.OwnershipJournal[0].LeafName = 'aaaaaaaa.unissued'
    $objUnissuedContext.OwnershipJournal[1].Path = $strUnissuedDownload
    $objUnissuedContext.OwnershipJournal[1].ParentPath = $strUnissuedTree
    $objUnissuedContext.OwnershipJournal[1].EntryState = 'Created'
    $objUnissuedContext.OwnershipJournal[2].Path = $strUnissuedCandidate
    $objUnissuedContext.OwnershipJournal[2].ParentPath = $strUnissuedTree
    # The manager acting on the path it authenticated, under a writer that
    # moves the path between the authentication and the delete.
    #
    # Round 32 captured the path at the delete loop; round 33 found the evidence
    # loop reading the caller's record separately, so the check and the use were
    # still two reads. Measured before the fix, 4 runs of 4 across both
    # runtimes: a file OUTSIDE the invocation root was deleted while the
    # authenticated file survived, and the manager refused afterwards.
    #
    # The mutator is a second runspace in this process holding the same record
    # object -- not a script property, which the schema check refuses outright,
    # and the reason round 32's stated mechanism was wrong. It waits on a real
    # event rather than a timer: the higher-sequence file disappearing means the
    # evidence phase is over and the delete loop is running.
    #
    # ONE-SIDED ON PURPOSE. Both assertions hold whether or not the mutator wins
    # its race, so a lost race cannot produce a false failure; it can only
    # produce a weaker pass. A timing-sensitive assertion that fails
    # occasionally is worse than none, because a suite people learn to re-run is
    # a suite that stops being read.
    $strRacedRoot = [System.IO.Path]::Combine($RunRoot, 'raced-delete')
    [void][System.IO.Directory]::CreateDirectory($strRacedRoot)
    $objRacedContext = New-StyleGuideCandidateInvocationContext `
        -TrustedTemporaryRoot $strRacedRoot `
        -DiagnosticLabel 'raced-delete'
    [void][System.IO.Directory]::CreateDirectory(
        [string]$objRacedContext.DownloadDirectoryPath)
    [void][System.IO.Directory]::CreateDirectory([string]$objRacedContext.CandidatePath)
    $strRacedVictimParent = [System.IO.Path]::Combine($strRacedRoot, 'victim')
    [void][System.IO.Directory]::CreateDirectory($strRacedVictimParent)
    $strRacedVictim = [System.IO.Path]::Combine($strRacedVictimParent, 'victim.txt')
    [System.IO.File]::WriteAllBytes($strRacedVictim, [byte[]]@(0x76))
    $objRacedContext.OwnershipJournal[1].EntryState = 'Created'
    $objRacedContext.OwnershipJournal[2].EntryState = 'Created'
    $objRacedContext.OwnershipJournal[2].CreationPhase = 'destination'
    $arrRacedRecord = @()
    foreach ($hashtableRacedFile in @(
        @{ Sequence = [uint32]3; Leaf = 'target.txt'; Byte = [byte]0x74 },
        @{ Sequence = [uint32]4; Leaf = 'trigger.txt'; Byte = [byte]0x67 }
    )) {
        $strRacedPath = [System.IO.Path]::Combine(
            [string]$objRacedContext.CandidatePath, [string]$hashtableRacedFile.Leaf)
        $arrRacedByte = [byte[]]@([byte]$hashtableRacedFile.Byte)
        [System.IO.File]::WriteAllBytes($strRacedPath, $arrRacedByte)
        $objRacedRecord = $objRacedContext.OwnershipJournal[2].PSObject.Copy()
        $objRacedRecord.Sequence = [uint32]$hashtableRacedFile.Sequence
        $objRacedRecord.Kind = 'CandidateFile'
        $objRacedRecord.Path = $strRacedPath
        $objRacedRecord.ParentPath = [string]$objRacedContext.CandidatePath
        $objRacedRecord.LeafName = [string]$hashtableRacedFile.Leaf
        $objRacedRecord.ExpectedEntryType = 'File'
        $objRacedRecord.CreationPhase = 'extraction'
        $objRacedRecord.EntryState = 'Created'
        $objRacedRecord.ContentLength = [uint64]$arrRacedByte.Length
        $objRacedRecord.ContentSha256 = & $script:scriptBlockGetByteArraySha256 -Bytes $arrRacedByte
        $arrRacedRecord += $objRacedRecord
    }
    $strRacedTarget = [string]$arrRacedRecord[0].Path
    $strRacedTrigger = [string]$arrRacedRecord[1].Path
    $objRacedContext.OwnershipJournal = [object[]]@(
        $objRacedContext.OwnershipJournal[0],
        $objRacedContext.OwnershipJournal[1],
        $objRacedContext.OwnershipJournal[2],
        $arrRacedRecord[0],
        $arrRacedRecord[1]
    )
    $objRacedContext.NextSequence = [uint32]5
    $objRacedRunspace = [runspacefactory]::CreateRunspace()
    $objRacedRunspace.Open()
    # A synchronized flag rather than a sleep. BeginInvoke queues onto the
    # thread pool, and cleanup is fast enough to finish before a queued thread
    # is ever scheduled -- measured: the first version of this assertion passed
    # against a deliberately regressed manager, because the mutator had not
    # started. Waiting for the mutator to say it is running removes the startup
    # race without putting a timer anywhere.
    $hashtableRacedSignal = [hashtable]::Synchronized(@{ Running = $false })
    $objRacedRunspace.SessionStateProxy.SetVariable('objRecord', $arrRacedRecord[0])
    $objRacedRunspace.SessionStateProxy.SetVariable('strTrigger', $strRacedTrigger)
    $objRacedRunspace.SessionStateProxy.SetVariable('strVictim', $strRacedVictim)
    $objRacedRunspace.SessionStateProxy.SetVariable('strVictimParent', $strRacedVictimParent)
    $objRacedRunspace.SessionStateProxy.SetVariable('hashtableSignal', $hashtableRacedSignal)
    $objRacedShell = [powershell]::Create()
    $objRacedShell.Runspace = $objRacedRunspace
    [void]$objRacedShell.AddScript({
        $objWatch = [System.Diagnostics.Stopwatch]::StartNew()
        $hashtableSignal.Running = $true
        while ($objWatch.ElapsedMilliseconds -lt 5000) {
            if (-not [System.IO.File]::Exists($strTrigger)) {
                $objRecord.ParentPath = $strVictimParent
                $objRecord.Path = $strVictim
                return
            }
        }
    })
    try {
        $objRacedHandle = $objRacedShell.BeginInvoke()
        $objRacedStart = [System.Diagnostics.Stopwatch]::StartNew()
        while (-not $hashtableRacedSignal.Running -and
            $objRacedStart.ElapsedMilliseconds -lt 5000) {
        }
        [void](Remove-StyleGuideCandidateInvocationContext -Context $objRacedContext)
        [void]$objRacedShell.EndInvoke($objRacedHandle)
    } finally {
        $objRacedShell.Dispose()
        $objRacedRunspace.Close()
        $objRacedRunspace.Dispose()
    }
    if (-not [System.IO.File]::Exists($strRacedVictim)) {
        & $script:scriptBlockStopHarness -Code 'orchestration-failed' `
            -Detail 'raced-delete-victim-removed'
    }
    if ([System.IO.File]::Exists($strRacedTarget)) {
        & $script:scriptBlockStopHarness -Code 'orchestration-failed' `
            -Detail 'raced-delete-target-survived'
    }

    # And the other half of the same property, on the cleanup side. Round 32
    # moved the deletions into the manager, which left the helper's cleanup
    # function delegating everything to whatever answers to the manager's public
    # name and passing the returned object straight back. Measured before the
    # fix: a fake bound to that name returned a schema-shaped cleanup-succeeded
    # with FinalState Disposed while the invocation root was still on disk.
    #
    # The fix proves the CONSEQUENCE instead of the claim, so this asserts the
    # consequence too: with a lying manager installed, the helper must refuse
    # and the root must still be there. A filesystem-call-count oracle would
    # only record that a call happened, which round 20 established is not the
    # same as recording what it decided.
    #
    # The substitution is undone in a finally. The saved value is the real
    # function's ScriptBlock, and rebinding it restores the closure over the
    # manager's private register -- verified by the cases that run after this.
    $strFakeManagerRoot = [System.IO.Path]::Combine($RunRoot, 'fake-manager')
    [void][System.IO.Directory]::CreateDirectory($strFakeManagerRoot)
    $objFakeManagerContext = New-StyleGuideCandidateInvocationContext `
        -TrustedTemporaryRoot $strFakeManagerRoot `
        -DiagnosticLabel 'fake-manager'
    [void][System.IO.Directory]::CreateDirectory(
        [string]$objFakeManagerContext.DownloadDirectoryPath)
    $objFakeManagerContext.OwnershipJournal[1].EntryState = 'Created'
    $scriptBlockRealContextCleanup = (Get-Command `
        -Name Remove-StyleGuideCandidateInvocationContext `
        -CommandType Function).ScriptBlock
    $objFakeManagerResult = $null
    try {
        Set-Item -LiteralPath Function:\Remove-StyleGuideCandidateInvocationContext -Value {
            param (
                [Parameter(Mandatory = $true)]
                [AllowNull()]
                [object]$Context
            )

            $objLie = [pscustomobject]@{
                SchemaVersion = [uint32]1
                InvocationId = $Context.InvocationId
                PreviousState = 'Active'
                FinalState = 'Disposed'
                Success = $true
                DiagnosticCode = 'cleanup-succeeded'
                FilesystemCallCount = [uint32]7
                RetainedRecordSequences = [uint32[]]@()
            }
            $objLie.PSObject.TypeNames.Insert(0, 'PSStyleGuide.CandidateCleanupResult.v1')
            return $objLie
        } -Force
        $objFakeManagerResult = Remove-StyleGuideCandidateInvocationState `
            -Context $objFakeManagerContext
    } finally {
        Set-Item -LiteralPath Function:\Remove-StyleGuideCandidateInvocationContext `
            -Value $scriptBlockRealContextCleanup -Force
    }
    if ($null -eq $objFakeManagerResult -or
        $objFakeManagerResult.Success -or
        ([string]$objFakeManagerResult.DiagnosticCode) -cne 'cleanup-delete-failed') {
        & $script:scriptBlockStopHarness -Code 'orchestration-failed' `
            -Detail ('fake-manager-' + $(if ($null -eq $objFakeManagerResult) {
                'no-result'
            } else {
                [string]$objFakeManagerResult.DiagnosticCode
            }))
    }
    if (-not [System.IO.Directory]::Exists(
            [string]$objFakeManagerContext.InvocationRootPath)) {
        & $script:scriptBlockStopHarness -Code 'orchestration-failed' `
            -Detail 'fake-manager-root-removed'
    }

    $strUnissuedCheckout = [System.IO.Path]::Combine($strUnissuedRoot, 'checkout')
    [void][System.IO.Directory]::CreateDirectory($strUnissuedCheckout)
    $boolUnissuedSucceeded = $false
    $strUnissuedPhase = 'none'
    $strUnissuedSubreason = 'none'
    try {
        [void](& $HelperLiteralPath `
            -Context $objUnissuedContext `
            -CheckoutRoot $strUnissuedCheckout `
            -TrustedTemporaryRoot $strUnissuedRoot `
            -DownloadDirectory $strUnissuedDownload `
            -CandidateDirectory $strUnissuedCandidate `
            -ExpectedDigest ('0' * 64))
        $boolUnissuedSucceeded = $true
    } catch {
        $objUnissuedPhase = [regex]::Match(
            [string]$_.Exception.Message, 'phase=([a-z][a-z0-9-]*)')
        if ($objUnissuedPhase.Success) {
            $strUnissuedPhase = $objUnissuedPhase.Groups[1].Value
        }
        $objUnissuedSubreason = [regex]::Match(
            [string]$_.Exception.Message, 'subreason=([a-z][a-zA-Z0-9-]*)')
        if ($objUnissuedSubreason.Success) {
            $strUnissuedSubreason = $objUnissuedSubreason.Groups[1].Value
        }
    }
    if ($boolUnissuedSucceeded -or
        $strUnissuedPhase -cne 'parameter' -or
        $strUnissuedSubreason -cne 'context-unissued') {
        & $script:scriptBlockStopHarness -Code 'orchestration-failed' `
            -Detail ('unissued-expansion-' + $strUnissuedPhase +
                '-' + $strUnissuedSubreason)
    }
    # The refusal alone is not the claim. A check that refuses AFTER writing is
    # the defect rounds 29 to 32 kept finding, so the download directory must
    # still be empty and the candidate directory must never have been created.
    if (@([System.IO.Directory]::EnumerateFileSystemEntries(
            $strUnissuedDownload)).Count -ne 0 -or
        [System.IO.Directory]::Exists($strUnissuedCandidate)) {
        & $script:scriptBlockStopHarness -Code 'orchestration-failed' `
            -Detail 'unissued-expansion-wrote'
    }

    # The expansion helper must not RELAY an unauthenticated terminal FAILURE.
    # The fake-manager probe above pins the reported-SUCCESS half: a success is
    # authenticated by its filesystem consequence, because no substitute can make
    # the invocation root disappear without removing it. A reported terminal
    # FAILURE has no such consequence -- a genuine CleanupFailed and a forged one
    # leave the same tree on disk -- so a substitute bound to the manager's name
    # can return a schema-shaped {Success=$false, FinalState='CleanupFailed'} for a
    # context the register only ever recorded Active, and a helper that relayed it
    # would tell the caller the tree is permanently retained and stop it retrying
    # over a tree still present. The fix (commit c99d6a9) authenticates the claim
    # against the register exactly as the entry gate does -- the negative-control
    # probe rejecting a binding that answers true for everything, then the CAPTURED
    # values and the claimed state -- and, when it cannot, DOWNGRADES to the
    # captured previous state with the retryable 'cleanup-context-altered', taking
    # the retained sequences from the journal bounded at entry rather than the
    # untrusted result.
    #
    # Behavioural, not positional: this drives the real helper against a lying
    # substitute and asserts the DOWNGRADE ({Success=$false, FinalState='Active',
    # 'cleanup-context-altered', no retained sequences}), not a relayed terminal
    # CleanupFailed. Before the fix this returned the substitute's FinalState
    # unchanged. The binding is restored in a finally, as the fake-manager probe
    # does; the cases that run after this verify the restored closure.
    $strAlteredTerminalRoot = [System.IO.Path]::Combine($RunRoot, 'altered-terminal-relay')
    [void][System.IO.Directory]::CreateDirectory($strAlteredTerminalRoot)
    $objAlteredTerminalContext = New-StyleGuideCandidateInvocationContext `
        -TrustedTemporaryRoot $strAlteredTerminalRoot `
        -DiagnosticLabel 'altered-terminal-relay'
    [void][System.IO.Directory]::CreateDirectory(
        [string]$objAlteredTerminalContext.DownloadDirectoryPath)
    $objAlteredTerminalContext.OwnershipJournal[1].EntryState = 'Created'
    $scriptBlockRealContextCleanupTerminal = (Get-Command `
        -Name Remove-StyleGuideCandidateInvocationContext `
        -CommandType Function).ScriptBlock
    $objAlteredTerminalResult = $null
    try {
        Set-Item -LiteralPath Function:\Remove-StyleGuideCandidateInvocationContext -Value {
            param (
                [Parameter(Mandatory = $true)]
                [AllowNull()]
                [object]$Context
            )

            $objForgedTerminal = [pscustomobject]@{
                SchemaVersion = [uint32]1
                InvocationId = $Context.InvocationId
                PreviousState = 'Active'
                FinalState = 'CleanupFailed'
                Success = $false
                DiagnosticCode = 'cleanup-owned-entry-uncertain'
                FilesystemCallCount = [uint32]4
                RetainedRecordSequences = [uint32[]]@([uint32]0)
            }
            $objForgedTerminal.PSObject.TypeNames.Insert(0,
                'PSStyleGuide.CandidateCleanupResult.v1')
            return $objForgedTerminal
        } -Force
        Write-Verbose 'lifecycle-record-state: altered-terminal-relay probe executing'
        $objAlteredTerminalResult = Remove-StyleGuideCandidateInvocationState `
            -Context $objAlteredTerminalContext
    } finally {
        Set-Item -LiteralPath Function:\Remove-StyleGuideCandidateInvocationContext `
            -Value $scriptBlockRealContextCleanupTerminal -Force
    }
    if ($null -eq $objAlteredTerminalResult -or
        $objAlteredTerminalResult.Success -or
        ([string]$objAlteredTerminalResult.FinalState) -cne 'Active' -or
        ([string]$objAlteredTerminalResult.DiagnosticCode) -cne 'cleanup-context-altered' -or
        @([uint32[]]@($objAlteredTerminalResult.RetainedRecordSequences)).Count -ne 0) {
        & $script:scriptBlockStopHarness -Code 'orchestration-failed' `
            -Detail ('altered-terminal-relay-' + $(if ($null -eq $objAlteredTerminalResult) {
                'no-result'
            } else {
                [string]$objAlteredTerminalResult.FinalState + '-' +
                    [string]$objAlteredTerminalResult.DiagnosticCode
            }))
    }

    # The context manager's cleanup CATCH must not over-claim when the terminal
    # transition it attempts is REFUSED. A cleanup that has begun deleting can
    # throw; the catch then tries to record CleanupFailed through the object's own
    # LifecycleState setter, and a same-session holder can make that setter throw
    # -- so the setter returns false and the register stays at the prior state. On
    # that refused transition the manager must report the CAPTURED PREVIOUS state
    # with a retryable code and leave the owned records where they are: NOT a
    # terminal CleanupFailed (round 68 / issue #157), and NOT records retyped to
    # RetainedUncertain, which an Active context's own validator would refuse and
    # which would strand the very entries a retry would remove (commit c99d6a9,
    # which gated the retype on the transition persisting). Both fixes live on this
    # one branch, so this one probe covers both.
    #
    # (ii) reaching the branch needs a LifecycleState whose setter throws yet
    # passed the entry schema. That schema requires note properties and refuses a
    # script property before any loop runs -- the manager records this at its own
    # capture -- so the setter is made to throw the only way that survives it: the
    # holder REPLACES the note property with a throwing script property AFTER entry
    # validation, from a second runspace holding the same object. (i) the same
    # holder causes the throw, polluting the candidate directory so the manager's
    # non-recursive Directory.Delete of it fails. The swap is written BEFORE the
    # pollution, so a thrown cleanup proves the swap already landed and the setter
    # is certain to refuse; the candidate directory is the first directory deleted,
    # so the download and root records stay Created and the left journal is a valid,
    # retryable Active journal.
    #
    # ONE-SIDED, like the raced-delete probe. The assertions are invariants that
    # clean production holds whatever the race does: it never reports a terminal
    # CleanupFailed the register does not hold, never leaves a RetainedUncertain
    # record while the register is non-terminal, and never reports retained
    # sequences while the register is non-terminal. A lost race merely disposes, or
    # refuses over an Active register, and passes all three. Only the reverted
    # branch violates them, on every run the holder wins the deletion race
    # (measured reliable across dozens of runs on this runtime). The register is
    # read back through the manager's own issuance gate on the CAPTURED paths, so
    # the swapped LifecycleState property is never consulted.
    $strRefusedTransitionRoot = [System.IO.Path]::Combine($RunRoot, 'refused-transition')
    [void][System.IO.Directory]::CreateDirectory($strRefusedTransitionRoot)
    $objRefusedContext = New-StyleGuideCandidateInvocationContext `
        -TrustedTemporaryRoot $strRefusedTransitionRoot `
        -DiagnosticLabel 'refused-transition'
    [void][System.IO.Directory]::CreateDirectory(
        [string]$objRefusedContext.DownloadDirectoryPath)
    [void][System.IO.Directory]::CreateDirectory(
        [string]$objRefusedContext.CandidatePath)
    $objRefusedContext.OwnershipJournal[1].EntryState = 'Created'
    $objRefusedContext.OwnershipJournal[2].EntryState = 'Created'
    $objRefusedContext.OwnershipJournal[2].CreationPhase = 'destination'
    $arrRefusedFileRecord = @()
    $uintRefusedSequence = [uint32]3
    foreach ($strRefusedLeaf in @('aaaa.txt', 'bbbb.txt', 'cccc.txt', 'dddd.txt')) {
        $strRefusedFilePath = [System.IO.Path]::Combine(
            [string]$objRefusedContext.CandidatePath, $strRefusedLeaf)
        $arrRefusedByte = [System.Text.Encoding]::ASCII.GetBytes('refused-' + $strRefusedLeaf)
        [System.IO.File]::WriteAllBytes($strRefusedFilePath, $arrRefusedByte)
        $objRefusedRecord = $objRefusedContext.OwnershipJournal[2].PSObject.Copy()
        $objRefusedRecord.Sequence = [uint32]$uintRefusedSequence
        $objRefusedRecord.Kind = 'CandidateFile'
        $objRefusedRecord.Path = $strRefusedFilePath
        $objRefusedRecord.ParentPath = [string]$objRefusedContext.CandidatePath
        $objRefusedRecord.LeafName = $strRefusedLeaf
        $objRefusedRecord.ExpectedEntryType = 'File'
        $objRefusedRecord.CreationPhase = 'extraction'
        $objRefusedRecord.EntryState = 'Created'
        $objRefusedRecord.ContentLength = [uint64]$arrRefusedByte.Length
        $objRefusedRecord.ContentSha256 = & $script:scriptBlockGetByteArraySha256 -Bytes $arrRefusedByte
        $arrRefusedFileRecord += $objRefusedRecord
        $uintRefusedSequence = [uint32]($uintRefusedSequence + 1)
    }
    $objRefusedContext.OwnershipJournal = [object[]]@(
        $objRefusedContext.OwnershipJournal[0],
        $objRefusedContext.OwnershipJournal[1],
        $objRefusedContext.OwnershipJournal[2],
        $arrRefusedFileRecord[0],
        $arrRefusedFileRecord[1],
        $arrRefusedFileRecord[2],
        $arrRefusedFileRecord[3]
    )
    $objRefusedContext.NextSequence = [uint32]7
    # Captured before the call: the register is re-authenticated afterward from
    # these paths, never from the LifecycleState the holder is about to swap.
    $objRefusedCaptured = [pscustomobject]@{
        InvocationId = $objRefusedContext.InvocationId
        TrustedParentPath = [string]$objRefusedContext.TrustedParentPath
        InvocationRootPath = [string]$objRefusedContext.InvocationRootPath
        DownloadDirectoryPath = [string]$objRefusedContext.DownloadDirectoryPath
        CandidatePath = [string]$objRefusedContext.CandidatePath
    }
    # The highest-sequence candidate file is deleted first, so watching it vanish
    # fires the holder early, a wide window before the candidate directory delete.
    $strRefusedTrigger = [string]$arrRefusedFileRecord[3].Path
    $strRefusedPollute = [System.IO.Path]::Combine(
        [string]$objRefusedContext.CandidatePath, 'refused.marker')
    $hashtableRefusedSignal = [hashtable]::Synchronized(@{ Running = $false })
    $objRefusedRunspace = [runspacefactory]::CreateRunspace()
    $objRefusedRunspace.Open()
    $objRefusedRunspace.SessionStateProxy.SetVariable('objContext', $objRefusedContext)
    $objRefusedRunspace.SessionStateProxy.SetVariable('strTrigger', $strRefusedTrigger)
    $objRefusedRunspace.SessionStateProxy.SetVariable('strPollutePath', $strRefusedPollute)
    $objRefusedRunspace.SessionStateProxy.SetVariable('hashtableSignal', $hashtableRefusedSignal)
    $objRefusedShell = [powershell]::Create()
    $objRefusedShell.Runspace = $objRefusedRunspace
    [void]$objRefusedShell.AddScript({
        $objWatch = [System.Diagnostics.Stopwatch]::StartNew()
        $hashtableSignal.Running = $true
        while ($objWatch.ElapsedMilliseconds -lt 5000) {
            if (-not [System.IO.File]::Exists($strTrigger)) {
                # First the swap the manager's setter will refuse, THEN the
                # pollution that makes cleanup throw. This order makes a thrown
                # cleanup proof that the swap already landed.
                Add-Member -InputObject $objContext -MemberType ScriptProperty `
                    -Name LifecycleState -Force `
                    -Value { 'Active' } `
                    -SecondValue { throw 'refused-by-same-session-holder' }
                [System.IO.File]::WriteAllBytes($strPollutePath, [byte[]]@(0x50))
                return
            }
        }
    })
    $objRefusedResult = $null
    try {
        Write-Verbose 'lifecycle-record-state: refused-transition probe executing'
        $objRefusedHandle = $objRefusedShell.BeginInvoke()
        $objRefusedStart = [System.Diagnostics.Stopwatch]::StartNew()
        while (-not $hashtableRefusedSignal.Running -and
            $objRefusedStart.ElapsedMilliseconds -lt 5000) {
        }
        $objRefusedResult = Remove-StyleGuideCandidateInvocationContext -Context $objRefusedContext
        [void]$objRefusedShell.EndInvoke($objRefusedHandle)
    } finally {
        $objRefusedShell.Dispose()
        $objRefusedRunspace.Close()
        $objRefusedRunspace.Dispose()
    }
    # Does the manager's register actually hold a terminal CleanupFailed for this
    # context? Asked through the issuance gate on the captured paths, so the
    # swapped LifecycleState is not read.
    $boolRefusedRegisterTerminal = [bool](
        Test-StyleGuideCandidateInvocationContextIssued `
            -Context $objRefusedContext -ExpectedState 'CleanupFailed' `
            -ExpectedValues $objRefusedCaptured)
    $boolRefusedAnyRetainedUncertain = $false
    foreach ($objRefusedJournalRecord in $objRefusedContext.OwnershipJournal) {
        if (([string]$objRefusedJournalRecord.EntryState) -ceq 'RetainedUncertain') {
            $boolRefusedAnyRetainedUncertain = $true
        }
    }
    # Assigned directly, not from an if-block: an empty array emitted as a
    # block's value unwraps to $null, and $null.Count throws under strict mode.
    $arrRefusedResultRetained = [uint32[]]@()
    if ($null -ne $objRefusedResult) {
        $arrRefusedResultRetained = [uint32[]]@($objRefusedResult.RetainedRecordSequences)
    }
    if (($null -eq $objRefusedResult) -or
        (([string]$objRefusedResult.FinalState) -ceq 'CleanupFailed' -and
            -not $boolRefusedRegisterTerminal) -or
        ($boolRefusedAnyRetainedUncertain -and -not $boolRefusedRegisterTerminal) -or
        ($arrRefusedResultRetained.Count -ne 0 -and -not $boolRefusedRegisterTerminal)) {
        & $script:scriptBlockStopHarness -Code 'orchestration-failed' `
            -Detail ('refused-transition-' + $(if ($null -eq $objRefusedResult) {
                'no-result'
            } else {
                [string]$objRefusedResult.FinalState +
                    '-ru' + [string]$boolRefusedAnyRetainedUncertain +
                    '-rt' + [string]$boolRefusedRegisterTerminal
            }))
    }

    # Round 71 (Codex P2): the sibling of the refused-transition probe above, on
    # the RECORD side. When a same-session holder rigs a live RECORD's EntryState
    # to throw -- not the context's LifecycleState -- the best-effort courtesy write
    # in the delete loops throws and is recorded (RecordWriteRefused), the whole
    # tree is deleted and each delete verified, the register transitions to Disposed,
    # and then the final live-context re-assertion re-reads the tampered record and
    # throws: the manager reported a false terminal CleanupFailed with EMPTY retained
    # sequences over a succeeded, verified disposal (round 68's failure mode, entered
    # from the record side). The fix consults RecordWriteRefused -- set at three
    # sites and previously never read -- before that re-assertion, and returns the
    # manager's authenticated terminal disposal directly.
    #
    # ONE-SIDED and reliable, like the raced-delete probe. The rig targets the seq-0
    # ROOT record, whose courtesy write is the LAST of the whole cleanup, and is
    # triggered by the FIRST file deletion -- so the holder has the entire file and
    # directory deletion to land the swap before that courtesy write; measured
    # reliable across dozens of runs. The invariant clean production holds whatever
    # the race does: once the tree is fully deleted, cleanup is Disposed and
    # successful with no retained sequences, never a terminal CleanupFailed. The
    # register is read back through the manager's own issuance gate on the CAPTURED
    # paths, so the swapped record field is never consulted. Reverting the consult
    # violates the invariant on every run the holder wins the race.
    $strRecordRefusedRoot = [System.IO.Path]::Combine($RunRoot, 'record-write-refused')
    [void][System.IO.Directory]::CreateDirectory($strRecordRefusedRoot)
    $objRecordRefusedContext = New-StyleGuideCandidateInvocationContext `
        -TrustedTemporaryRoot $strRecordRefusedRoot -DiagnosticLabel 'record-write-refused'
    [void][System.IO.Directory]::CreateDirectory(
        [string]$objRecordRefusedContext.DownloadDirectoryPath)
    [void][System.IO.Directory]::CreateDirectory(
        [string]$objRecordRefusedContext.CandidatePath)
    $objRecordRefusedContext.OwnershipJournal[1].EntryState = 'Created'
    $objRecordRefusedContext.OwnershipJournal[2].EntryState = 'Created'
    $objRecordRefusedContext.OwnershipJournal[2].CreationPhase = 'destination'
    $arrRecordRefusedFile = @()
    $uintRecordRefusedSequence = [uint32]3
    foreach ($strRecordRefusedLeaf in @('aaaa.txt', 'bbbb.txt', 'cccc.txt', 'dddd.txt')) {
        $strRecordRefusedFilePath = [System.IO.Path]::Combine(
            [string]$objRecordRefusedContext.CandidatePath, $strRecordRefusedLeaf)
        $arrRecordRefusedByte = [System.Text.Encoding]::ASCII.GetBytes(
            'record-refused-' + $strRecordRefusedLeaf)
        [System.IO.File]::WriteAllBytes($strRecordRefusedFilePath, $arrRecordRefusedByte)
        $objRecordRefusedRecord = $objRecordRefusedContext.OwnershipJournal[2].PSObject.Copy()
        $objRecordRefusedRecord.Sequence = [uint32]$uintRecordRefusedSequence
        $objRecordRefusedRecord.Kind = 'CandidateFile'
        $objRecordRefusedRecord.Path = $strRecordRefusedFilePath
        $objRecordRefusedRecord.ParentPath = [string]$objRecordRefusedContext.CandidatePath
        $objRecordRefusedRecord.LeafName = $strRecordRefusedLeaf
        $objRecordRefusedRecord.ExpectedEntryType = 'File'
        $objRecordRefusedRecord.CreationPhase = 'extraction'
        $objRecordRefusedRecord.EntryState = 'Created'
        $objRecordRefusedRecord.ContentLength = [uint64]$arrRecordRefusedByte.Length
        $objRecordRefusedRecord.ContentSha256 = & $script:scriptBlockGetByteArraySha256 `
            -Bytes $arrRecordRefusedByte
        $arrRecordRefusedFile += $objRecordRefusedRecord
        $uintRecordRefusedSequence = [uint32]($uintRecordRefusedSequence + 1)
    }
    $objRecordRefusedContext.OwnershipJournal = [object[]]@(
        $objRecordRefusedContext.OwnershipJournal[0],
        $objRecordRefusedContext.OwnershipJournal[1],
        $objRecordRefusedContext.OwnershipJournal[2],
        $arrRecordRefusedFile[0],
        $arrRecordRefusedFile[1],
        $arrRecordRefusedFile[2],
        $arrRecordRefusedFile[3]
    )
    $objRecordRefusedContext.NextSequence = [uint32]7
    # Captured before the call: the register is re-authenticated afterward from
    # these paths, never from the record field the holder is about to swap.
    $objRecordRefusedCaptured = [pscustomobject]@{
        InvocationId = $objRecordRefusedContext.InvocationId
        TrustedParentPath = [string]$objRecordRefusedContext.TrustedParentPath
        InvocationRootPath = [string]$objRecordRefusedContext.InvocationRootPath
        DownloadDirectoryPath = [string]$objRecordRefusedContext.DownloadDirectoryPath
        CandidatePath = [string]$objRecordRefusedContext.CandidatePath
    }
    $strRecordRefusedRootDirectory = [string]$objRecordRefusedContext.InvocationRootPath
    # Target: the seq-0 ROOT record, deleted last, so its courtesy write is the last
    # in the whole cleanup. Trigger: the highest-sequence file, deleted first.
    $objRecordRefusedTarget = $objRecordRefusedContext.OwnershipJournal[0]
    $strRecordRefusedTrigger = [string]$arrRecordRefusedFile[3].Path
    $hashtableRecordRefusedSignal = [hashtable]::Synchronized(@{ Running = $false })
    $objRecordRefusedRunspace = [runspacefactory]::CreateRunspace()
    $objRecordRefusedRunspace.Open()
    $objRecordRefusedRunspace.SessionStateProxy.SetVariable(
        'objTarget', $objRecordRefusedTarget)
    $objRecordRefusedRunspace.SessionStateProxy.SetVariable(
        'strTrigger', $strRecordRefusedTrigger)
    $objRecordRefusedRunspace.SessionStateProxy.SetVariable(
        'hashtableSignal', $hashtableRecordRefusedSignal)
    $objRecordRefusedShell = [powershell]::Create()
    $objRecordRefusedShell.Runspace = $objRecordRefusedRunspace
    [void]$objRecordRefusedShell.AddScript({
        $objWatch = [System.Diagnostics.Stopwatch]::StartNew()
        $hashtableSignal.Running = $true
        while ($objWatch.ElapsedMilliseconds -lt 5000) {
            if (-not [System.IO.File]::Exists($strTrigger)) {
                # Replace the live record's EntryState note property with a throwing
                # script property AFTER the plan capture read its valid value and
                # BEFORE the root record's best-effort courtesy write. The getter
                # answers Created so a read does not throw; the setter throws so the
                # courtesy write is refused and RecordWriteRefused is set.
                Add-Member -InputObject $objTarget -MemberType ScriptProperty `
                    -Name EntryState -Force `
                    -Value { 'Created' } `
                    -SecondValue { throw 'entrystate-refused-by-same-session-holder' }
                return
            }
        }
    })
    $objRecordRefusedResult = $null
    try {
        Write-Verbose 'lifecycle-record-state: record-write-refused probe executing'
        $objRecordRefusedHandle = $objRecordRefusedShell.BeginInvoke()
        $objRecordRefusedStart = [System.Diagnostics.Stopwatch]::StartNew()
        while (-not $hashtableRecordRefusedSignal.Running -and
            $objRecordRefusedStart.ElapsedMilliseconds -lt 5000) {
        }
        $objRecordRefusedResult = Remove-StyleGuideCandidateInvocationContext `
            -Context $objRecordRefusedContext
        [void]$objRecordRefusedShell.EndInvoke($objRecordRefusedHandle)
    } finally {
        $objRecordRefusedShell.Dispose()
        $objRecordRefusedRunspace.Close()
        $objRecordRefusedRunspace.Dispose()
    }
    $boolRecordRefusedTreeGone =
        (-not [System.IO.Directory]::Exists($strRecordRefusedRootDirectory))
    # Does the register hold a terminal Disposed for this context? Asked through the
    # issuance gate on the captured paths, so the swapped record field is not read.
    $boolRecordRefusedRegisterDisposed = [bool](
        Test-StyleGuideCandidateInvocationContextIssued `
            -Context $objRecordRefusedContext -ExpectedState 'Disposed' `
            -ExpectedValues $objRecordRefusedCaptured)
    # Assigned directly, not from an if-block: an empty array emitted as a block's
    # value unwraps to $null, and $null.Count throws under strict mode.
    $arrRecordRefusedRetained = [uint32[]]@()
    if ($null -ne $objRecordRefusedResult) {
        $arrRecordRefusedRetained = [uint32[]]@(
            $objRecordRefusedResult.RetainedRecordSequences)
    }
    # Invariant: once the tree is fully deleted, a completed, verified disposal is
    # reported as terminal Disposed and successful, with no retained sequences and a
    # register that holds Disposed -- never a false CleanupFailed. Reverting the
    # RecordWriteRefused consult violates this on every run the holder wins the race
    # (measured: the tree is gone, yet FinalState is CleanupFailed and the register
    # holds CleanupFailed).
    if (($null -eq $objRecordRefusedResult) -or
        (-not $boolRecordRefusedTreeGone) -or
        (([string]$objRecordRefusedResult.FinalState) -cne 'Disposed') -or
        (-not [bool]$objRecordRefusedResult.Success) -or
        (([string]$objRecordRefusedResult.DiagnosticCode) -cne 'cleanup-succeeded') -or
        ($arrRecordRefusedRetained.Count -ne 0) -or
        (-not $boolRecordRefusedRegisterDisposed)) {
        & $script:scriptBlockStopHarness -Code 'orchestration-failed' `
            -Detail ('record-write-refused-' + $(if ($null -eq $objRecordRefusedResult) {
                'no-result'
            } else {
                [string]$objRecordRefusedResult.FinalState +
                    '-s' + [string]$objRecordRefusedResult.Success +
                    '-tg' + [string]$boolRecordRefusedTreeGone +
                    '-rd' + [string]$boolRecordRefusedRegisterDisposed +
                    '-rc' + [string]$arrRecordRefusedRetained.Count
            }))
    }

    $strScenarioRoot = [System.IO.Path]::Combine($RunRoot, 'lifecycle-record-state')
    [void][System.IO.Directory]::CreateDirectory($strScenarioRoot)
    foreach ($hashtableScenario in $arrScenario) {
        # Each entry point is handed its own freshly created context. Sharing
        # one would let the first call's outcome decide the second's, and a
        # rejected context is left exactly as the caller supplied it.
        foreach ($strEntryPoint in @(
            'Remove-StyleGuideCandidateInvocationContext',
            'Remove-StyleGuideCandidateInvocationState'
        )) {
            $strTrustedParent = [System.IO.Path]::Combine(
                $strScenarioRoot,
                [System.IO.Path]::GetRandomFileName()
            )
            [void][System.IO.Directory]::CreateDirectory($strTrustedParent)
            $objContext = New-StyleGuideCandidateInvocationContext `
                -TrustedTemporaryRoot $strTrustedParent
            if ($objContext.OwnershipJournal.Count -ne 3) {
                & $script:scriptBlockStopHarness `
                    -Code 'orchestration-failed' -Detail 'lifecycle-record-state'
            }
            foreach ($hashtableMutation in $hashtableScenario.Mutation) {
                $objContext.OwnershipJournal[$hashtableMutation.Index].EntryState =
                    [string]$hashtableMutation.EntryState
            }
            # Transitioned through the manager's own recorder rather than by
            # writing the field. A caller cannot write a terminal state onto a
            # context any more -- that was round 31's false-success defect --
            # so a test that did would be exercising a path production no
            # longer has. What these scenarios are for is the record-state
            # table, which is reached the same way either way.
            [void](& $scriptBlockSetCandidateIssuedState `
                -Context $objContext `
                -State ([string]$hashtableScenario.LifecycleState))
            # A context that says Disposed while its tree is still on disk is
            # not a disposed context, it is the forgery round 37 closed -- and
            # the helper now refuses it, correctly. This scenario is about the
            # record-state table, not about that forgery, so its disposed rows
            # are made genuinely disposed: the entries the records call Deleted
            # are actually deleted. The forgery itself is asserted separately.
            if (([string]$hashtableScenario.LifecycleState) -ceq 'Disposed') {
                foreach ($strDisposedPath in @(
                    [string]$objContext.DownloadDirectoryPath,
                    [string]$objContext.InvocationRootPath
                )) {
                    if ([System.IO.Directory]::Exists($strDisposedPath)) {
                        [System.IO.Directory]::Delete($strDisposedPath, $false)
                    }
                }
            }

            # A terminal REFUSAL still costs nothing. A terminal SUCCESS
            # through the helper now costs exactly one call, because round 37
            # made every success it reports prove the invocation root is gone
            # -- it no longer answers already-disposed from a property it read
            # and a verifier it resolved by name. The manager's own entry point
            # still costs nothing, because it authenticates against a register
            # rather than against the filesystem. Stated as an exact expected
            # count per entry point rather than relaxed to "0 or 1", so a call
            # appearing where none belongs is still a failure.
            $uintExpectedCalls = if (
                $strEntryPoint -ceq 'Remove-StyleGuideCandidateInvocationState' -and
                ([string]$hashtableScenario.ExpectedDiagnosticCode) -ceq 'cleanup-already-disposed'
            ) { [uint32]1 } else { [uint32]0 }
            $objResult = & $strEntryPoint -Context $objContext
            if ($objResult.DiagnosticCode -cne $hashtableScenario.ExpectedDiagnosticCode -or
                $objResult.FilesystemCallCount -ne $uintExpectedCalls) {
                & $script:scriptBlockStopHarness `
                    -Code 'orchestration-failed' -Detail 'lifecycle-record-state'
            }
            $arrObserved = [uint32[]]@($objResult.RetainedRecordSequences)
            $arrExpected = [uint32[]]@($hashtableScenario.ExpectedRetainedSequence)
            if ($arrObserved.Count -ne $arrExpected.Count) {
                & $script:scriptBlockStopHarness `
                    -Code 'orchestration-failed' -Detail 'lifecycle-record-state'
            }
            for ($intIndex = 0; $intIndex -lt $arrExpected.Count; $intIndex++) {
                if ($arrObserved[$intIndex] -ne $arrExpected[$intIndex]) {
                    & $script:scriptBlockStopHarness `
                        -Code 'orchestration-failed' -Detail 'lifecycle-record-state'
                }
            }
        }
    }
}

$script:scriptBlockAssertRound73RegisterLeakDeregistered = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RunRoot,

        [Parameter(Mandatory = $true)]
        [string]$ContextLiteralPath
    )

    # Round 73 (Codex P2): scriptBlockNewCandidateContext appended the context, its
    # issuance snapshot, and its lifecycle state to the three parallel, Add-only
    # issuance registers the instant it built the context -- before it created a
    # single directory. A creation failure AFTER that append (the trusted parent
    # cannot be written, so the invocation root create throws) ran the filesystem
    # rollback, threw, and returned no context, but never withdrew the three register
    # entries. Each failed New therefore leaked one strong reference into EACH
    # register, and repeated failures grew all three without bound -- entries
    # describing contexts the caller never received and can never pass back to be
    # disposed. The fix added scriptBlockDeregisterCandidateContext, called from both
    # New-failure branches AFTER the rollback (which needs the context still issued):
    # a context New never returns now leaves no register entry.
    #
    # The registers are script-private and, since the round-50 hardening, removed from
    # the dot-sourcing caller's reach, so their counts cannot be read off the loaded
    # production. This probe therefore mirrors the reproduction exactly: it writes an
    # INSTRUMENTED copy of the REAL context-manager bytes into the run root --
    # byte-identical but for three global aliases captured at the register-declaration
    # site, BEFORE the load-time Remove-Variable takes the names away -- and drives it
    # in a FRESH runspace, so neither the instrumented copy's functions nor the
    # register aliases touch the outer session's already-loaded production. (A
    # dot-source's Set-Item Function: leaks out of a '&' child scope and would clobber
    # the loaded production for every later case; a separate runspace is the only clean
    # isolation, and it is disposed in a finally.)
    #
    # Behavioural, with a positive control. The control -- one SUCCESSFUL New -- must
    # grow all three registers by exactly one, which proves the instrumentation
    # aliases the real registers and that New registers at all; a probe whose aliases
    # were wrong, or whose New never registered, would fail the control. The failing
    # calls must then grow all three by ZERO. Reverting either deregister call reddens
    # this on the leak: growth returns to one-per-failed-call.
    #
    # The fix is called from BOTH New-failure branches, and the two are distinct:
    #   * the NO-ROLLBACK branch (Manage ~2302-2303), taken when the invocation-root
    #     create itself fails so $boolRootCreated is still false and nothing was
    #     rolled back; and
    #   * the POST-ROLLBACK branch (Manage ~2272-2280), taken when the root (and
    #     download) were created, the failure came later, and the manager runs its
    #     filesystem rollback FIRST and then deregisters.
    # A single lever exercises only one branch (Codex round 74: chattr +i on the
    # parent fails the root create, so it drives the no-rollback branch only, and
    # reverting just the post-rollback deregister would leave this probe green). So
    # this probe drives BOTH, with a separate growth-zero assertion for each, and is
    # mutation-proven per branch: reverting the no-rollback deregister reddens the
    # chattr batch, reverting the post-rollback deregister reddens the forced batch.
    #
    #   * No-rollback lever: chattr +i on the trusted parent (root on ext4) makes the
    #     invocation-root create throw before it is made. Where chattr is unavailable
    #     or ineffective the failure cannot be provoked, so that batch records the
    #     miss and is not asserted -- a missing lever is not a production regression.
    #   * Post-rollback lever: a throw injected into the instrumented copy at the end
    #     of a SUCCESSFUL build -- after the root and download dirs exist and the
    #     context is registered, immediately before New returns -- gated by a global
    #     the probe sets only for that batch. Deterministic and needs no chattr, so
    #     the post-rollback branch is always exercised; the forced failures must also
    #     leave the parent empty, proving the manager's rollback ran before it
    #     deregistered.
    $intFailingCallCount = 3
    $strLeakProbeRoot = [System.IO.Path]::Combine($RunRoot, 'round73-register-leak')
    [void][System.IO.Directory]::CreateDirectory($strLeakProbeRoot)
    $objLeakRunspace = [runspacefactory]::CreateRunspace()
    $objLeakRunspace.Open()
    $objLeakRunspace.SessionStateProxy.SetVariable('strManageSourcePath', $ContextLiteralPath)
    $objLeakRunspace.SessionStateProxy.SetVariable('strProbeRoot', $strLeakProbeRoot)
    $objLeakRunspace.SessionStateProxy.SetVariable('intFailingCallCount', $intFailingCallCount)
    $objLeakShell = [powershell]::Create()
    $objLeakShell.Runspace = $objLeakRunspace
    [void]$objLeakShell.AddScript({
        Set-StrictMode -Version Latest
        $ErrorActionPreference = 'Stop'
        $objOutcome = [pscustomobject]@{
            InstrumentationApplied = $false
            ControlGrowth          = @([int]-1, [int]-1, [int]-1)
            ImmutableEffective     = $false
            ThrewCount             = [int]0
            ReturnedAnyContext     = $false
            FailureGrowth          = @([int]-1, [int]-1, [int]-1)
            PostRootThrewCount     = [int]0
            PostRootReturnedAny    = $false
            PostRootGrowth         = @([int]-1, [int]-1, [int]-1)
            PostRootTreeRetained   = $false
            Error                  = ''
        }
        $strImmutableParent = [System.IO.Path]::Combine($strProbeRoot, 'immutable')
        try {
            $strAnchor = '$arrCandidateIssuedState = New-Object System.Collections.ArrayList'
            $strManageText = [System.IO.File]::ReadAllText($strManageSourcePath)
            if (([regex]::Matches($strManageText, [regex]::Escape($strAnchor))).Count -ne 1) {
                $objOutcome.Error = 'anchor-count'
                return $objOutcome
            }
            $strInstrumented = $strAnchor + [System.Environment]::NewLine +
                '$global:objRound73RegisterContext = $arrCandidateIssuedContext' + [System.Environment]::NewLine +
                '$global:objRound73RegisterSnapshot = $arrCandidateIssuedSnapshot' + [System.Environment]::NewLine +
                '$global:objRound73RegisterState = $arrCandidateIssuedState'
            $strManageText = $strManageText.Replace($strAnchor, $strInstrumented)
            # The post-rollback failure lever: a throw at the end of a successful
            # build, gated by a global set only for the post-rollback batch. The
            # anchor is New-context's final in-memory assertion, immediately before
            # it returns -- root and download created, context registered -- so the
            # throw takes the manager's $boolRootCreated (rollback-then-deregister)
            # branch. Must match exactly once.
            $strForceAnchor = '[void](& $scriptBlockAssertCandidateInMemoryContext -Context $objContext)'
            if (([regex]::Matches($strManageText, [regex]::Escape($strForceAnchor))).Count -ne 1) {
                $objOutcome.Error = 'force-anchor-count'
                return $objOutcome
            }
            $strForceInjected =
                'if ($global:objRound73ForcePostRootFailure) { throw ''round73-forced-post-root-failure'' }' +
                [System.Environment]::NewLine + '            ' + $strForceAnchor
            $strManageText = $strManageText.Replace($strForceAnchor, $strForceInjected)
            $strInstrumentedPath = [System.IO.Path]::Combine($strProbeRoot, 'Manage-instrumented.ps1')
            [System.IO.File]::WriteAllText($strInstrumentedPath, $strManageText)
            . $strInstrumentedPath
            $global:objRound73ForcePostRootFailure = $false

            $scriptBlockRegisterCounts = {
                @([int]$global:objRound73RegisterContext.Count,
                    [int]$global:objRound73RegisterSnapshot.Count,
                    [int]$global:objRound73RegisterState.Count)
            }

            # Control: one successful New bumps all three registers by one.
            $strGoodParent = [System.IO.Path]::Combine($strProbeRoot, 'good')
            [void][System.IO.Directory]::CreateDirectory($strGoodParent)
            $arrControlBefore = & $scriptBlockRegisterCounts
            $objControlContext = New-StyleGuideCandidateInvocationContext `
                -TrustedTemporaryRoot $strGoodParent -DiagnosticLabel 'round73-register-control'
            $arrControlAfter = & $scriptBlockRegisterCounts
            $objOutcome.ControlGrowth = @(
                ($arrControlAfter[0] - $arrControlBefore[0]),
                ($arrControlAfter[1] - $arrControlBefore[1]),
                ($arrControlAfter[2] - $arrControlBefore[2]))
            $objOutcome.InstrumentationApplied = $true
            try {
                [void](Remove-StyleGuideCandidateInvocationContext -Context $objControlContext)
            } catch {
                $null = $_
            }

            # No-rollback branch: an immutable trusted parent makes the
            # post-registration invocation-root create throw before the root is made.
            # Confirm the immutability actually took before trusting the growth.
            [void][System.IO.Directory]::CreateDirectory($strImmutableParent)
            $null = & chattr +i $strImmutableParent 2>&1
            try {
                $strWriteProbe = [System.IO.Path]::Combine($strImmutableParent, 'writeprobe')
                [void][System.IO.Directory]::CreateDirectory($strWriteProbe)
                [void][System.IO.Directory]::Delete($strWriteProbe, $true)
                $objOutcome.ImmutableEffective = $false
            } catch {
                $objOutcome.ImmutableEffective = $true
            }
            if ($objOutcome.ImmutableEffective) {
                $arrFailBefore = & $scriptBlockRegisterCounts
                try {
                    for ($intCall = 0; $intCall -lt $intFailingCallCount; $intCall++) {
                        $objFailContext = $null
                        try {
                            $objFailContext = New-StyleGuideCandidateInvocationContext `
                                -TrustedTemporaryRoot $strImmutableParent `
                                -DiagnosticLabel ('round73-register-fail-' + [string]$intCall)
                        } catch {
                            $objOutcome.ThrewCount = [int]($objOutcome.ThrewCount + 1)
                        }
                        if ($null -ne $objFailContext) { $objOutcome.ReturnedAnyContext = $true }
                    }
                } finally {
                    $null = & chattr -i $strImmutableParent 2>&1
                }
                $arrFailAfter = & $scriptBlockRegisterCounts
                $objOutcome.FailureGrowth = @(
                    ($arrFailAfter[0] - $arrFailBefore[0]),
                    ($arrFailAfter[1] - $arrFailBefore[1]),
                    ($arrFailAfter[2] - $arrFailBefore[2]))
            }

            # Post-rollback branch: force a failure AFTER root and download exist and
            # the context is registered, so the manager rolls the tree back and THEN
            # deregisters. Deterministic (no chattr), so this branch is always
            # exercised. Growth must be zero and, because every forced failure ran the
            # rollback, the parent must hold no leftover invocation root.
            $strPostRootParent = [System.IO.Path]::Combine($strProbeRoot, 'postroot')
            [void][System.IO.Directory]::CreateDirectory($strPostRootParent)
            $global:objRound73ForcePostRootFailure = $true
            $arrPostBefore = & $scriptBlockRegisterCounts
            try {
                for ($intCall = 0; $intCall -lt $intFailingCallCount; $intCall++) {
                    $objPostContext = $null
                    try {
                        $objPostContext = New-StyleGuideCandidateInvocationContext `
                            -TrustedTemporaryRoot $strPostRootParent `
                            -DiagnosticLabel ('round73-register-postroot-' + [string]$intCall)
                    } catch {
                        $objOutcome.PostRootThrewCount = [int]($objOutcome.PostRootThrewCount + 1)
                    }
                    if ($null -ne $objPostContext) { $objOutcome.PostRootReturnedAny = $true }
                }
            } finally {
                $global:objRound73ForcePostRootFailure = $false
            }
            $arrPostAfter = & $scriptBlockRegisterCounts
            $objOutcome.PostRootGrowth = @(
                ($arrPostAfter[0] - $arrPostBefore[0]),
                ($arrPostAfter[1] - $arrPostBefore[1]),
                ($arrPostAfter[2] - $arrPostBefore[2]))
            $objOutcome.PostRootTreeRetained =
                ((@([System.IO.Directory]::GetFileSystemEntries($strPostRootParent))).Count -ne 0)
        } catch {
            $objOutcome.Error = [string]$_.Exception.Message
            try { $null = & chattr -i $strImmutableParent 2>&1 } catch { $null = $_ }
        }
        return $objOutcome
    })
    $objLeakOutcome = $null
    try {
        $objLeakOutcome = $objLeakShell.Invoke() | Select-Object -Last 1
    } finally {
        $objLeakShell.Dispose()
        $objLeakRunspace.Close()
        $objLeakRunspace.Dispose()
        if ([System.IO.Directory]::Exists($strLeakProbeRoot)) {
            try {
                $null = & chattr -i ([System.IO.Path]::Combine($strLeakProbeRoot, 'immutable')) 2>&1
            } catch {
                $null = $_
            }
            [System.IO.Directory]::Delete($strLeakProbeRoot, $true)
        }
    }

    if ($null -eq $objLeakOutcome -or -not $objLeakOutcome.InstrumentationApplied) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail ('round73-register-leak-instrumentation-' + $(if ($null -eq $objLeakOutcome) {
                'no-result'
            } else {
                [string]$objLeakOutcome.Error
            }))
    }
    $arrControlGrowth = [int[]]@($objLeakOutcome.ControlGrowth)
    if ($arrControlGrowth[0] -ne 1 -or $arrControlGrowth[1] -ne 1 -or $arrControlGrowth[2] -ne 1) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail ('round73-register-leak-control-' + ($arrControlGrowth -join '-'))
    }
    # Post-rollback branch, asserted unconditionally: the forced failure needs no
    # chattr, so this batch always ran. Every forced call must have thrown, returned
    # no context, rolled its tree back (empty parent), and left the registers
    # unchanged. Reverting the post-rollback deregister reddens the growth check here.
    if ($objLeakOutcome.PostRootThrewCount -ne $intFailingCallCount -or $objLeakOutcome.PostRootReturnedAny) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail ('round73-register-leak-postroot-precondition-t' +
                [string]$objLeakOutcome.PostRootThrewCount + '-r' + [string]$objLeakOutcome.PostRootReturnedAny)
    }
    if ($objLeakOutcome.PostRootTreeRetained) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail 'round73-register-leak-postroot-tree-retained'
    }
    $arrPostRootGrowth = [int[]]@($objLeakOutcome.PostRootGrowth)
    if ($arrPostRootGrowth[0] -ne 0 -or $arrPostRootGrowth[1] -ne 0 -or $arrPostRootGrowth[2] -ne 0) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail ('round73-register-leak-postroot-' + ($arrPostRootGrowth -join '-'))
    }
    # A missing or ineffective immutability lever is not a production regression; the
    # no-rollback-branch growth was never provoked, so there is nothing to assert.
    if (-not $objLeakOutcome.ImmutableEffective) {
        return
    }
    if ($objLeakOutcome.ThrewCount -ne $intFailingCallCount -or $objLeakOutcome.ReturnedAnyContext) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail ('round73-register-leak-precondition-t' + [string]$objLeakOutcome.ThrewCount +
                '-r' + [string]$objLeakOutcome.ReturnedAnyContext)
    }
    $arrFailureGrowth = [int[]]@($objLeakOutcome.FailureGrowth)
    if ($arrFailureGrowth[0] -ne 0 -or $arrFailureGrowth[1] -ne 0 -or $arrFailureGrowth[2] -ne 0) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
            -Detail ('round73-register-leak-' + ($arrFailureGrowth -join '-'))
    }
}

$script:scriptBlockAssertRound73RefusedWriteToleranceNarrow = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RunRoot
    )

    # Round 73 (Codex P2): the round-71 refused-write branch -- entered when a
    # same-session holder rigs a live record's EntryState setter to throw so the
    # best-effort courtesy write in the delete loop is refused (RecordWriteRefused) --
    # SKIPPED the entire final live-context re-assertion whenever ANY courtesy write
    # was refused. A holder that rigged one record's EntryState AND, in the same
    # window, zeroed the context InvocationId (or corrupted any other unrelated field)
    # therefore had the malformed context BLESSED with Disposed / success, because the
    # skip bypassed every check, not only the one on the refused record.
    #
    # The fix RUNS the re-assertion, tolerating ONLY the refused records' live
    # EntryState (their true state is Deleted, taken from the plan, never read from the
    # rigged property) and validating every other field, record, and context invariant.
    # The pure refused-write-only case still reports Disposed / success; an unrelated
    # mutation is reported as an altered context (Success=$false, cleanup-context-
    # altered), NOT blessed.
    #
    # Two cases, both driving the REAL Remove-StyleGuideCandidateInvocationContext on a
    # populated Active context whose seq-0 root record's courtesy write is the LAST of
    # the cleanup, rigged from a second runspace that fires on the FIRST file deletion
    # -- the wide, measured-reliable window the sibling round-71 record-write-refused
    # probe uses.
    #
    #   (a) refused EntryState PLUS an unrelated InvocationId=Empty: the fix must
    #       REFUSE (Success=$false, cleanup-context-altered) rather than bless.
    #       Reverting to the round-71 skip blesses it (Success=$true, cleanup-
    #       succeeded), which reddens this. The refusal half is race-RELIABLE rather
    #       than strictly one-sided: the two mutations land together on the first
    #       deletion, long before the end-of-cleanup re-assertion, so the holder wins
    #       on every observed run (as the sibling probe measures for the same rig). The
    #       hard failure is gated on the mutation actually landing (rig active AND the
    #       live InvocationId zeroed); a holder that never fired asserts nothing.
    #
    #   (b) refused EntryState ONLY, no unrelated mutation: still Disposed / success /
    #       cleanup-succeeded, tree gone. ONE-SIDED -- clean production reports that
    #       whether the rig wins the race (RecordWriteRefused set, tolerated
    #       re-assertion passes) or the rig lands after the call returns (the full
    #       re-assertion already passed on the true Deleted state), so a lost race is
    #       only a weaker pass. This is the control the narrowed tolerance must not
    #       break.
    $strToleranceRoot = [System.IO.Path]::Combine($RunRoot, 'round73-tolerance')
    [void][System.IO.Directory]::CreateDirectory($strToleranceRoot)

    # Builds the populated Active context both cases share: root + download + candidate
    # created, four candidate files journaled and on disk, seq-0 root deleted last.
    $scriptBlockBuildToleranceContext = {
        param (
            [Parameter(Mandatory = $true)]
            [string]$TrustedParent
        )
        $objContext = New-StyleGuideCandidateInvocationContext `
            -TrustedTemporaryRoot $TrustedParent -DiagnosticLabel 'round73-tolerance'
        [void][System.IO.Directory]::CreateDirectory([string]$objContext.DownloadDirectoryPath)
        [void][System.IO.Directory]::CreateDirectory([string]$objContext.CandidatePath)
        $objContext.OwnershipJournal[1].EntryState = 'Created'
        $objContext.OwnershipJournal[2].EntryState = 'Created'
        $objContext.OwnershipJournal[2].CreationPhase = 'destination'
        $arrFileRecord = @()
        $uintSequence = [uint32]3
        foreach ($strLeaf in @('aaaa.txt', 'bbbb.txt', 'cccc.txt', 'dddd.txt')) {
            $strFilePath = [System.IO.Path]::Combine([string]$objContext.CandidatePath, $strLeaf)
            $arrByte = [System.Text.Encoding]::ASCII.GetBytes('round73-tolerance-' + $strLeaf)
            [System.IO.File]::WriteAllBytes($strFilePath, $arrByte)
            $objRecord = $objContext.OwnershipJournal[2].PSObject.Copy()
            $objRecord.Sequence = [uint32]$uintSequence
            $objRecord.Kind = 'CandidateFile'
            $objRecord.Path = $strFilePath
            $objRecord.ParentPath = [string]$objContext.CandidatePath
            $objRecord.LeafName = $strLeaf
            $objRecord.ExpectedEntryType = 'File'
            $objRecord.CreationPhase = 'extraction'
            $objRecord.EntryState = 'Created'
            $objRecord.ContentLength = [uint64]$arrByte.Length
            $objRecord.ContentSha256 = & $script:scriptBlockGetByteArraySha256 -Bytes $arrByte
            $arrFileRecord += $objRecord
            $uintSequence = [uint32]($uintSequence + 1)
        }
        $objContext.OwnershipJournal = [object[]]@(
            $objContext.OwnershipJournal[0],
            $objContext.OwnershipJournal[1],
            $objContext.OwnershipJournal[2],
            $arrFileRecord[0], $arrFileRecord[1], $arrFileRecord[2], $arrFileRecord[3])
        $objContext.NextSequence = [uint32]7
        return $objContext
    }

    try {
        # ---- Case (a): refused write + unrelated InvocationId=Empty must REFUSE ----
        # The rig races cleanup: both mutations land on the FIRST file deletion, long
        # before the end-of-cleanup re-assertion, so on every observed run they are
        # present when production re-asserts. A lost race (runner load, a future
        # cleanup-order change) would leave the mutation un-landed -- and a probe that
        # simply SKIPPED the assertion there could let a reverted production fix pass
        # unnoticed (Codex round 74). So the rig is RETRIED until the mutation lands,
        # the distinguishing assertion runs on the attempt that lands, and if none of
        # the bounded attempts lands the probe FAILS LOUD rather than skipping: a
        # mutation test that can silently not-run is not a mutation test.
        $intToleranceMaxAttempt = 8
        $boolMainMutationLanded = $false
        for ($intMainAttempt = 0;
            $intMainAttempt -lt $intToleranceMaxAttempt -and -not $boolMainMutationLanded;
            $intMainAttempt++) {
            $strMainParent = [System.IO.Path]::Combine(
                $strToleranceRoot, 'refused-plus-unrelated-' + [string]$intMainAttempt)
            [void][System.IO.Directory]::CreateDirectory($strMainParent)
            $objMainContext = & $scriptBlockBuildToleranceContext -TrustedParent $strMainParent
            $objMainTargetRecord = $objMainContext.OwnershipJournal[0]
            $strMainTrigger = [string]$objMainContext.OwnershipJournal[6].Path
            $hashtableMainSignal = [hashtable]::Synchronized(@{ Running = $false })
            $objMainRunspace = [runspacefactory]::CreateRunspace()
            $objMainRunspace.Open()
            $objMainRunspace.SessionStateProxy.SetVariable('objTarget', $objMainTargetRecord)
            $objMainRunspace.SessionStateProxy.SetVariable('objContext', $objMainContext)
            $objMainRunspace.SessionStateProxy.SetVariable('strTrigger', $strMainTrigger)
            $objMainRunspace.SessionStateProxy.SetVariable('hashtableSignal', $hashtableMainSignal)
            $objMainShell = [powershell]::Create()
            $objMainShell.Runspace = $objMainRunspace
            [void]$objMainShell.AddScript({
                $objWatch = [System.Diagnostics.Stopwatch]::StartNew()
                $hashtableSignal.Running = $true
                while ($objWatch.ElapsedMilliseconds -lt 5000) {
                    if (-not [System.IO.File]::Exists($strTrigger)) {
                        # (1) refuse the seq-0 root record's courtesy write by making its
                        # EntryState setter throw, and (2) an UNRELATED mutation: zero the
                        # context InvocationId. Both land together, on the first deletion,
                        # long before the end-of-cleanup re-assertion reads them.
                        Add-Member -InputObject $objTarget -MemberType ScriptProperty `
                            -Name EntryState -Force `
                            -Value { 'Created' } `
                            -SecondValue { throw 'entrystate-refused-by-same-session-holder' }
                        $objContext.InvocationId = [System.Guid]::Empty
                        return
                    }
                }
            })
            $objMainResult = $null
            try {
                $objMainHandle = $objMainShell.BeginInvoke()
                $objMainStart = [System.Diagnostics.Stopwatch]::StartNew()
                while (-not $hashtableMainSignal.Running -and
                    $objMainStart.ElapsedMilliseconds -lt 5000) {
                }
                $objMainResult = Remove-StyleGuideCandidateInvocationContext -Context $objMainContext
                [void]$objMainShell.EndInvoke($objMainHandle)
            } finally {
                $objMainShell.Dispose()
                $objMainRunspace.Close()
                $objMainRunspace.Dispose()
            }
            $boolMainRigActive = $false
            try { $objMainTargetRecord.EntryState = 'probe' } catch { $boolMainRigActive = $true }
            $boolMainMutationLanded = $boolMainRigActive -and
                ($objMainContext.InvocationId -eq [System.Guid]::Empty)
            # The regression is a bless of a context the holder really did alter, so the
            # assertion runs only on an attempt where BOTH mutations are present at the
            # re-assertion. Clean production refuses (cleanup-context-altered); the
            # round-71 skip-everything blesses, which reddens here.
            if ($boolMainMutationLanded) {
                if (($null -eq $objMainResult) -or
                    ([bool]$objMainResult.Success) -or
                    (([string]$objMainResult.DiagnosticCode) -cne 'cleanup-context-altered')) {
                    & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                        -Detail ('round73-tolerance-main-' + $(if ($null -eq $objMainResult) {
                            'no-result'
                        } else {
                            's' + [string]$objMainResult.Success +
                                '-' + [string]$objMainResult.DiagnosticCode
                        }))
                }
            }
        }
        # Fail loud rather than skip: if no bounded attempt landed the mutation, the
        # distinguishing assertion never ran, so the probe cannot vouch for the fix.
        if (-not $boolMainMutationLanded) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('round73-tolerance-main-mutation-never-landed-' +
                    [string]$intToleranceMaxAttempt)
        }

        # ---- Case (b): refused write ONLY still reports Disposed / success ----
        $strControlParent = [System.IO.Path]::Combine($strToleranceRoot, 'refused-only')
        [void][System.IO.Directory]::CreateDirectory($strControlParent)
        $objControlContext = & $scriptBlockBuildToleranceContext -TrustedParent $strControlParent
        $strControlRootDirectory = [string]$objControlContext.InvocationRootPath
        $objControlTargetRecord = $objControlContext.OwnershipJournal[0]
        $strControlTrigger = [string]$objControlContext.OwnershipJournal[6].Path
        $hashtableControlSignal = [hashtable]::Synchronized(@{ Running = $false })
        $objControlRunspace = [runspacefactory]::CreateRunspace()
        $objControlRunspace.Open()
        $objControlRunspace.SessionStateProxy.SetVariable('objTarget', $objControlTargetRecord)
        $objControlRunspace.SessionStateProxy.SetVariable('strTrigger', $strControlTrigger)
        $objControlRunspace.SessionStateProxy.SetVariable('hashtableSignal', $hashtableControlSignal)
        $objControlShell = [powershell]::Create()
        $objControlShell.Runspace = $objControlRunspace
        [void]$objControlShell.AddScript({
            $objWatch = [System.Diagnostics.Stopwatch]::StartNew()
            $hashtableSignal.Running = $true
            while ($objWatch.ElapsedMilliseconds -lt 5000) {
                if (-not [System.IO.File]::Exists($strTrigger)) {
                    # Refuse the seq-0 courtesy write only; nothing else is touched.
                    Add-Member -InputObject $objTarget -MemberType ScriptProperty `
                        -Name EntryState -Force `
                        -Value { 'Created' } `
                        -SecondValue { throw 'entrystate-refused-by-same-session-holder' }
                    return
                }
            }
        })
        $objControlResult = $null
        try {
            $objControlHandle = $objControlShell.BeginInvoke()
            $objControlStart = [System.Diagnostics.Stopwatch]::StartNew()
            while (-not $hashtableControlSignal.Running -and
                $objControlStart.ElapsedMilliseconds -lt 5000) {
            }
            $objControlResult = Remove-StyleGuideCandidateInvocationContext -Context $objControlContext
            [void]$objControlShell.EndInvoke($objControlHandle)
        } finally {
            $objControlShell.Dispose()
            $objControlRunspace.Close()
            $objControlRunspace.Dispose()
        }
        $boolControlTreeGone = (-not [System.IO.Directory]::Exists($strControlRootDirectory))
        # ONE-SIDED: whether or not the rig wins its race, clean production disposes and
        # succeeds. A regression that OVER-refused the pure refused-write case would
        # redden this.
        if (($null -eq $objControlResult) -or
            (([string]$objControlResult.FinalState) -cne 'Disposed') -or
            (-not [bool]$objControlResult.Success) -or
            (([string]$objControlResult.DiagnosticCode) -cne 'cleanup-succeeded') -or
            (-not $boolControlTreeGone)) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('round73-tolerance-control-' + $(if ($null -eq $objControlResult) {
                    'no-result'
                } else {
                    [string]$objControlResult.FinalState +
                        '-s' + [string]$objControlResult.Success +
                        '-' + [string]$objControlResult.DiagnosticCode +
                        '-tg' + [string]$boolControlTreeGone
                }))
        }
    } finally {
        if ([System.IO.Directory]::Exists($strToleranceRoot)) {
            [System.IO.Directory]::Delete($strToleranceRoot, $true)
        }
    }
}

# Round 52, EE5. The taxonomy closure below reads the two production scripts
# with regular expressions, and a regular expression sees one spelling. It
# validates -Code 'literal' and is blind to -Code ('literal'), to a variable,
# and to anything else an editor might write -- so an undeclared diagnostic
# could ship while the catalog still reported a closed set. That is the one
# check #146 requires to "reject unknown values", so a hole in it is worse
# than a hole anywhere else here.
#
# The reported remedy -- refuse non-literal arguments -- cannot be applied as
# stated: production deliberately emits computed codes, measured at 24 -Code
# variables, 6 "$Phase-invalid" interpolations, and one propagated
# $objContextResult.DiagnosticCode. Refusing non-literals would refuse the
# shipped code at three dozen sites.
#
# So the SHAPES are closed instead, and the shape set was measured rather than
# imagined -- every argument to every diagnostic parameter in both scripts is
# one of exactly four AST kinds. A literal is validated by the pass below; an
# interpolation is validated against the declared family table; a variable or
# a propagated member must be named here. Any fifth shape, and any name not on
# these lists, is refused. That is what makes the regex pass sound: it is no
# longer the only thing standing between an undeclared value and the catalog,
# because nothing can reach that pass in a shape the pass cannot read.
$script:hashtableCandidateDiagnosticPassThrough = @{
    'Code' = [string[]]@(
        'Code', 'DiagnosticCode', 'strAbsenceCode', 'strCreationCategory',
        'strFailureCode', 'strPrimaryCode'
    )
    'DiagnosticCode' = [string[]]@('strCode', 'strContextFailureCode')
    'Phase' = [string[]]@('Phase', 'PhaseValue', 'strPrimaryPhase')
    'Subreason' = [string[]]@('Subreason', 'strPrimarySubreason')
    'Fallback' = [string[]]@('strPhase')
}
$script:arrCandidateDiagnosticPropagated = [string[]]@(
    '$objContextResult.DiagnosticCode'
)

$script:scriptBlockAssertProductionTaxonomyClosed = {
    param (
        [Parameter(Mandatory = $true)]
        [object]$Catalog,

        [Parameter(Mandatory = $true)]
        [string[]]$LiteralPath
    )

    $objSubreason = New-Object 'System.Collections.Generic.HashSet[string]' (
        [System.StringComparer]::Ordinal
    )
    foreach ($strValue in $Catalog.ClosedSets.Subreason) {
        [void]$objSubreason.Add([string]$strValue)
    }
    $objDiagnostic = New-Object 'System.Collections.Generic.HashSet[string]' (
        [System.StringComparer]::Ordinal
    )
    foreach ($strValue in $Catalog.ClosedSets.DiagnosticCode) {
        [void]$objDiagnostic.Add([string]$strValue)
    }
    $objPhase = New-Object 'System.Collections.Generic.HashSet[string]' (
        [System.StringComparer]::Ordinal
    )
    foreach ($strValue in $Catalog.ClosedSets.Phase) {
        [void]$objPhase.Add([string]$strValue)
    }

    foreach ($strLiteralPath in $LiteralPath) {
        $strText = & $script:scriptBlockConvertFromStrictUtf8 `
            -Bytes ([System.IO.File]::ReadAllBytes($strLiteralPath))

        # Close the shape set before the text passes read it. See the note above
        # the pass-through table: a spelling these regular expressions cannot
        # see is a value they cannot check.
        $objShapeErrors = $null
        $objShapeAst = [System.Management.Automation.Language.Parser]::ParseFile(
            $strLiteralPath, [ref]$null, [ref]$objShapeErrors)
        if ($null -eq $objShapeAst -or @($objShapeErrors).Count -ne 0) {
            & $script:scriptBlockStopHarness `
                -Code 'catalog-invalid' -Detail 'production-diagnostic-parse'
        }
        foreach ($objShapeCommand in @($objShapeAst.FindAll(
                    {
                        param ($SyntaxNode)
                        return ($SyntaxNode -is
                            [System.Management.Automation.Language.CommandAst])
                    },
                    $true
                ))) {
            $arrShapeElement = @($objShapeCommand.CommandElements)
            # Round 54: the first version of this guard sat inside the loop
            # body, after a recognised -Code/-Phase/-Subreason switch had been
            # found, so a whole-call splat -- `& $stop @fields` -- carried no
            # CommandParameterAst for the loop to find and was never examined.
            # A guard against splats that only runs once a non-splatted call
            # has been recognised is not a guard against splats. Measured at
            # zero splatted elements anywhere in either script, so every
            # command is refused one, not merely the diagnostic helpers.
            foreach ($objSplatElement in $arrShapeElement) {
                if ($objSplatElement -is
                    [System.Management.Automation.Language.VariableExpressionAst] -and
                    $objSplatElement.Splatted) {
                    & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                        -Detail ('production-diagnostic-splat-' +
                            [string]$objShapeCommand.Extent.StartLineNumber)
                }
            }
            for ($intShape = 0; $intShape -lt $arrShapeElement.Count; $intShape++) {
                $objShapeElement = $arrShapeElement[$intShape]
                if ($objShapeElement -isnot
                    [System.Management.Automation.Language.CommandParameterAst]) {
                    continue
                }
                $strShapeParameter = [string]$objShapeElement.ParameterName
                if (-not $script:hashtableCandidateDiagnosticPassThrough.ContainsKey(
                        $strShapeParameter)) {
                    continue
                }
                $objShapeArgument = $objShapeElement.Argument
                if ($null -eq $objShapeArgument -and
                    ($intShape + 1) -lt $arrShapeElement.Count) {
                    $objShapeArgument = $arrShapeElement[$intShape + 1]
                }
                # A splat carries its arguments in a hashtable this pass cannot
                # read, and neither can the text passes below, so a diagnostic
                # assembled that way would reach the catalog unchecked. Measured
                # at zero splatted arguments anywhere in either script, so
                # refusing keeps it that way by construction rather than by
                # anyone remembering. This is the shape that escaped the
                # Remove-Variable rule at round 51.
                if ($objShapeArgument -is
                    [System.Management.Automation.Language.StringConstantExpressionAst]) {
                    continue
                }
                if ($objShapeArgument -is
                    [System.Management.Automation.Language.ExpandableStringExpressionAst]) {
                    # Round 54: this used to admit EVERY expandable string,
                    # while the text passes below validate only the computed
                    # form "$name-suffix". So `-Code "$strCode"` slipped past
                    # the pass-through table AND the closed-set regexes, which
                    # is the same hole one layer along. Only the form those
                    # passes can actually read is admitted here.
                    #
                    # "A pass can read it" is per field, not global. The family
                    # pass below reads -Subreason "$name-suffix"; the computed
                    # pass reads -Code and -Fallback "$name-invalid". Nothing
                    # downstream reads an interpolated -Phase or -DiagnosticCode,
                    # so admitting one of those here would carry its value to the
                    # catalog unchecked -- the same hole one field over from the
                    # round-54 report. Production interpolates only Code,
                    # Fallback and Subreason (measured); an expandable argument
                    # to any other diagnostic parameter is refused rather than
                    # admitted into a form no pass validates.
                    if (@('Code', 'Fallback', 'Subreason') -ccontains $strShapeParameter -and
                        ([string]$objShapeArgument.Extent.Text) -cmatch
                        '^"\$[A-Za-z0-9_]+-[A-Za-z]+"$') {
                        continue
                    }
                    & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                        -Detail ('production-diagnostic-expandable-' +
                            [string]$objShapeCommand.Extent.StartLineNumber)
                }
                if ($objShapeArgument -is
                    [System.Management.Automation.Language.VariableExpressionAst]) {
                    $strShapeName = [string]$objShapeArgument.VariablePath.UserPath
                    if (@($script:hashtableCandidateDiagnosticPassThrough[
                            $strShapeParameter]) -ccontains $strShapeName) {
                        continue
                    }
                    & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                        -Detail ('production-diagnostic-passthrough-' +
                            [string]$objShapeCommand.Extent.StartLineNumber)
                }
                if ($null -ne $objShapeArgument -and
                    $script:arrCandidateDiagnosticPropagated -ccontains
                    ([string]$objShapeArgument.Extent.Text)) {
                    continue
                }
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                    -Detail ('production-diagnostic-shape-' +
                        [string]$objShapeCommand.Extent.StartLineNumber)
            }
        }

        # The shape pass above admits `-Code $strFailureCode` on the strength of
        # the variable's NAME being on the pass-through table; nothing there
        # reads the VALUE the variable carries. The call-site passes below read
        # only values written AT a call site, so a diagnostic written to a
        # variable and then forwarded is invisible to every check -- which is
        # the one thing #146 asks this closure to prevent. Close it where the
        # value is written: every literal assigned, in value position, to a
        # pass-through variable must belong to that variable's field.
        #
        # Only literals in value position are collected -- a direct assignment,
        # or the tail of an if/ternary branch -- never a literal that is an
        # argument to a call in the right-hand side, so a helper's -Key and
        # -Fallback strings are not mistaken for the variable's value. Three
        # right-hand-side shapes are deliberately not literals here and are left
        # to their existing coverage: an interpolation ("$Phase-invalid") is
        # proven whole by the computed pass below; a value returned by a
        # diagnostic-field helper is bounded by that helper's validated
        # -Fallback and by the validated annotations at the throw sites it
        # reads; a propagated variable was itself validated where it was written.
        $hashtablePassThroughField = @{}
        foreach ($strPassKey in $script:hashtableCandidateDiagnosticPassThrough.Keys) {
            foreach ($strPassVar in
                $script:hashtableCandidateDiagnosticPassThrough[$strPassKey]) {
                $hashtablePassThroughField[[string]$strPassVar] = [string]$strPassKey
            }
        }

        # Round 66 (Codex P2): a fallback variable's destination is the field its
        # -Key selects at the call, not the union of all three taxonomies. The
        # one fallback variable, $strPhase, is used as `-Key 'PSStyleGuidePhase'
        # -Fallback $strPhase`, so `$strPhase = 'candidate-record'` -- a valid
        # Subreason but not a Phase -- passed the union test below while
        # production would have emitted it as an undeclared phase. The -Key is a
        # literal at the call, so it is readable; correlate each fallback
        # variable with the set(s) its -Key names and validate its writes
        # against that. A variable used under more than one key must satisfy
        # every one, so the destination is the intersection; a use whose -Key is
        # not a readable literal collapses the destination to empty, refusing
        # every literal rather than guessing -- the round-51 fail-closed shape.
        $hashtableFallbackKeySet = @{
            'PSStyleGuideDiagnosticCode' = $objDiagnostic
            'PSStyleGuidePhase'          = $objPhase
            'PSStyleGuideSubreason'      = $objSubreason
        }
        $hashtableFallbackDestination = @{}
        foreach ($objFallbackCommand in @($objShapeAst.FindAll(
                    {
                        param ($SyntaxNode)
                        $SyntaxNode -is [System.Management.Automation.Language.CommandAst]
                    },
                    $true))) {
            $arrFallbackElement = @($objFallbackCommand.CommandElements)
            for ($intFallback = 0; $intFallback -lt $arrFallbackElement.Count; $intFallback++) {
                $objFallbackParam = $arrFallbackElement[$intFallback]
                if ($objFallbackParam -isnot
                    [System.Management.Automation.Language.CommandParameterAst] -or
                    ([string]$objFallbackParam.ParameterName) -cne 'Fallback') {
                    continue
                }
                $objFallbackArg = $objFallbackParam.Argument
                if ($null -eq $objFallbackArg -and
                    ($intFallback + 1) -lt $arrFallbackElement.Count) {
                    $objFallbackArg = $arrFallbackElement[$intFallback + 1]
                }
                if ($objFallbackArg -isnot
                    [System.Management.Automation.Language.VariableExpressionAst]) {
                    continue
                }
                $strFallbackVar = [string]$objFallbackArg.VariablePath.UserPath
                if (-not ($hashtablePassThroughField.ContainsKey($strFallbackVar) -and
                        $hashtablePassThroughField[$strFallbackVar] -ceq 'Fallback')) {
                    continue
                }
                # Resolve this use's -Key to a recognised set, else leave it null
                # (unresolved) so the intersection below collapses to empty.
                $objUseSet = $null
                for ($intKey = 0; $intKey -lt $arrFallbackElement.Count; $intKey++) {
                    $objKeyParam = $arrFallbackElement[$intKey]
                    if ($objKeyParam -isnot
                        [System.Management.Automation.Language.CommandParameterAst] -or
                        ([string]$objKeyParam.ParameterName) -cne 'Key') {
                        continue
                    }
                    $objKeyArg = $objKeyParam.Argument
                    if ($null -eq $objKeyArg -and
                        ($intKey + 1) -lt $arrFallbackElement.Count) {
                        $objKeyArg = $arrFallbackElement[$intKey + 1]
                    }
                    if ($objKeyArg -is
                        [System.Management.Automation.Language.StringConstantExpressionAst] -and
                        $hashtableFallbackKeySet.ContainsKey([string]$objKeyArg.Value)) {
                        $objUseSet = $hashtableFallbackKeySet[[string]$objKeyArg.Value]
                    }
                    break
                }
                if (-not $hashtableFallbackDestination.ContainsKey($strFallbackVar)) {
                    $objSeed = New-Object 'System.Collections.Generic.HashSet[string]' (
                        [System.StringComparer]::Ordinal)
                    if ($null -ne $objUseSet) {
                        foreach ($strSeed in $objUseSet) { [void]$objSeed.Add($strSeed) }
                    }
                    $hashtableFallbackDestination[$strFallbackVar] = $objSeed
                } elseif ($null -eq $objUseSet) {
                    $hashtableFallbackDestination[$strFallbackVar].Clear()
                } else {
                    $hashtableFallbackDestination[$strFallbackVar].IntersectWith($objUseSet)
                }
            }
        }

        foreach ($objAssign in @($objShapeAst.FindAll(
                    {
                        param ($SyntaxNode)
                        $SyntaxNode -is
                            [System.Management.Automation.Language.AssignmentStatementAst] -and
                        $SyntaxNode.Left -is
                            [System.Management.Automation.Language.VariableExpressionAst]
                    },
                    $true
                ) | Where-Object {
                    $hashtablePassThroughField.ContainsKey(
                        [string]$_.Left.VariablePath.UserPath)
                })) {
            $strAssignField = $hashtablePassThroughField[
                [string]$objAssign.Left.VariablePath.UserPath]
            # A Fallback variable's destination is the field its -Key selects,
            # resolved above into $hashtableFallbackDestination; a fallback
            # variable never used as `-Fallback $var` has no readable
            # destination and its literals are refused rather than admitted by
            # union. The other fields resolve to one exact set.
            $objAssignSet = $null
            if ($strAssignField -ceq 'Phase') { $objAssignSet = $objPhase }
            elseif ($strAssignField -ceq 'Subreason') { $objAssignSet = $objSubreason }
            elseif ($strAssignField -ceq 'Fallback') {
                $objAssignSet = if ($hashtableFallbackDestination.ContainsKey(
                        [string]$objAssign.Left.VariablePath.UserPath)) {
                    $hashtableFallbackDestination[
                        [string]$objAssign.Left.VariablePath.UserPath]
                } else {
                    New-Object 'System.Collections.Generic.HashSet[string]' (
                        [System.StringComparer]::Ordinal)
                }
            }
            else { $objAssignSet = $objDiagnostic }
            $queueValueNode = New-Object 'System.Collections.Generic.Queue[object]'
            $queueValueNode.Enqueue($objAssign.Right)
            while ($queueValueNode.Count -gt 0) {
                $objValueNode = $queueValueNode.Dequeue()
                if ($null -eq $objValueNode) { continue }
                if ($objValueNode -is
                    [System.Management.Automation.Language.PipelineAst]) {
                    # A pipeline of a single expression is that expression's
                    # value; a pipeline that invokes a command yields the
                    # command's return -- the documented helper boundary -- and
                    # is not descended into.
                    if (@($objValueNode.PipelineElements).Count -eq 1 -and
                        $objValueNode.PipelineElements[0] -is
                            [System.Management.Automation.Language.CommandExpressionAst]) {
                        $queueValueNode.Enqueue(
                            $objValueNode.PipelineElements[0].Expression)
                    }
                    continue
                }
                if ($objValueNode -is
                    [System.Management.Automation.Language.CommandExpressionAst]) {
                    # Round 66 (self-found while mutation-testing the fallback fix
                    # above): a direct `$var = 'literal'` assignment has a
                    # CommandExpressionAst on its right, not a PipelineAst, so
                    # without this the walk descended if/ternary branch tails but
                    # silently skipped every plain assignment -- the ten
                    # `$strPhase = '<phase>'` writes among them. The literal is
                    # this node's Expression.
                    $queueValueNode.Enqueue($objValueNode.Expression)
                    continue
                }
                if ($objValueNode -is
                    [System.Management.Automation.Language.ParenExpressionAst]) {
                    $queueValueNode.Enqueue($objValueNode.Pipeline)
                    continue
                }
                if ($objValueNode -is
                    [System.Management.Automation.Language.IfStatementAst]) {
                    foreach ($objIfClause in $objValueNode.Clauses) {
                        $queueValueNode.Enqueue($objIfClause.Item2)
                    }
                    if ($null -ne $objValueNode.ElseClause) {
                        $queueValueNode.Enqueue($objValueNode.ElseClause)
                    }
                    continue
                }
                if ($objValueNode -is
                    [System.Management.Automation.Language.StatementBlockAst]) {
                    $arrBlockStatement = @($objValueNode.Statements)
                    if ($arrBlockStatement.Count -gt 0) {
                        $queueValueNode.Enqueue(
                            $arrBlockStatement[$arrBlockStatement.Count - 1])
                    }
                    continue
                }
                # TernaryExpressionAst exists only in PowerShell 7, but this
                # harness must remain loadable in Windows PowerShell 5.1.
                if ($objValueNode.GetType().FullName -ceq
                    'System.Management.Automation.Language.TernaryExpressionAst') {
                    $queueValueNode.Enqueue($objValueNode.IfTrue)
                    $queueValueNode.Enqueue($objValueNode.IfFalse)
                    continue
                }
                if ($objValueNode -is
                    [System.Management.Automation.Language.StringConstantExpressionAst]) {
                    $strAssignLiteral = [string]$objValueNode.Value
                    if (-not $objAssignSet.Contains($strAssignLiteral)) {
                        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                            -Detail ('production-passthrough-literal-' +
                                [string]$objAssign.Extent.StartLineNumber)
                    }
                    continue
                }
                # An expandable string, a bare variable, or any command/member
                # value is not a literal in value position and is covered by the
                # passes named above rather than validated here.
            }
        }

        foreach ($objMatch in [regex]::Matches($strText, "-Subreason\s+'([^']*)'")) {
            if (-not $objSubreason.Contains($objMatch.Groups[1].Value)) {
                & $script:scriptBlockStopHarness `
                    -Code 'catalog-invalid' -Detail 'production-subreason'
            }
        }
        foreach ($objMatch in [regex]::Matches($strText, "-(?:Code|DiagnosticCode)\s+'([^']*)'")) {
            if (-not $objDiagnostic.Contains($objMatch.Groups[1].Value)) {
                & $script:scriptBlockStopHarness `
                    -Code 'catalog-invalid' -Detail 'production-diagnostic'
            }
        }
        foreach ($objMatch in [regex]::Matches($strText, '-Subreason\s+"\$[A-Za-z0-9_]+-([A-Za-z]+)"')) {
            $strSuffix = $objMatch.Groups[1].Value
            if (-not $script:hashtableCandidateSubreasonFamily.Contains($strSuffix)) {
                & $script:scriptBlockStopHarness `
                    -Code 'catalog-invalid' -Detail 'production-subreason-family'
            }
            foreach ($strParameter in $script:hashtableCandidateSubreasonFamily[$strSuffix]) {
                if (-not $objSubreason.Contains($strParameter + '-' + $strSuffix)) {
                    & $script:scriptBlockStopHarness `
                        -Code 'catalog-invalid' -Detail 'production-subreason-family'
                }
            }
        }

        # A literal fallback is emitted verbatim when an exception carries no
        # annotation, so it must be declared for the field it lands in. Checking
        # the union of the closed sets is not enough: a diagnostic fallback
        # spelled with a declared subreason would pass the union test while the
        # runtime emitted an undeclared DiagnosticCode. Resolve the destination
        # field from the invocation, then validate against that field alone.
        foreach ($objMatch in [regex]::Matches($strText, "-Fallback\s+'([^']*)'")) {
            $strFallback = $objMatch.Groups[1].Value
            $intInvocationStart = $strText.LastIndexOf(
                '& $script',
                $objMatch.Index,
                [System.StringComparison]::Ordinal
            )
            if ($intInvocationStart -lt 0) {
                & $script:scriptBlockStopHarness `
                    -Code 'catalog-invalid' -Detail 'production-fallback-field'
            }
            $strInvocation = $strText.Substring(
                $intInvocationStart,
                $objMatch.Index - $intInvocationStart
            )
            # An explicit -Key names the destination directly. The
            # diagnostic-code helper takes no key and names it by identity.
            $objDestinationSet = $null
            if ($strInvocation.IndexOf(
                    "-Key 'PSStyleGuideDiagnosticCode'",
                    [System.StringComparison]::Ordinal) -ge 0) {
                $objDestinationSet = $objDiagnostic
            } elseif ($strInvocation.IndexOf(
                    "-Key 'PSStyleGuidePhase'",
                    [System.StringComparison]::Ordinal) -ge 0) {
                $objDestinationSet = $objPhase
            } elseif ($strInvocation.IndexOf(
                    "-Key 'PSStyleGuideSubreason'",
                    [System.StringComparison]::Ordinal) -ge 0) {
                $objDestinationSet = $objSubreason
            } elseif ($strInvocation.IndexOf(
                    'GetCandidateDiagnosticCode',
                    [System.StringComparison]::Ordinal) -ge 0) {
                $objDestinationSet = $objDiagnostic
            }
            # An unresolvable destination fails closed rather than falling back
            # to the union test this check replaced.
            if ($null -eq $objDestinationSet) {
                & $script:scriptBlockStopHarness `
                    -Code 'catalog-invalid' -Detail 'production-fallback-field'
            }
            if (-not $objDestinationSet.Contains($strFallback)) {
                & $script:scriptBlockStopHarness `
                    -Code 'catalog-invalid' -Detail 'production-fallback'
            }
        }

        # A phase-derived code is built by interpolation, so every phase that can
        # reach the fallback must have its '<phase>-invalid' form declared.
        $arrComputed = @([regex]::Matches($strText, '-(?:Code|Fallback)\s+"\$[A-Za-z0-9_]+-([A-Za-z-]+)"'))
        foreach ($objMatch in $arrComputed) {
            if ($objMatch.Groups[1].Value -cne 'invalid') {
                & $script:scriptBlockStopHarness `
                    -Code 'catalog-invalid' -Detail 'production-computed-code'
            }
            foreach ($strPhase in $script:arrCandidateComputedDiagnosticPhase) {
                if (-not $objDiagnostic.Contains($strPhase + '-invalid')) {
                    & $script:scriptBlockStopHarness `
                        -Code 'catalog-invalid' -Detail 'production-computed-code'
                }
            }
        }
    }
}

# Round 66 (Codex "refuse unresolved sources"): the taxonomy check above proves
# every diagnostic value a text or AST pass can SEE is in the closed set, but by
# construction it cannot resolve a value whose source is a parameter or a
# computed string -- the exact gap Codex named. The production builders now carry
# that proof themselves: each diagnostic parameter declares a [ValidateSet(...)],
# so PowerShell refuses an out-of-set value at binding whatever its source. This
# asserts the declared sets are EXACTLY the catalog's closed sets -- neither
# narrowed, which would refuse a legitimate diagnostic at runtime, nor widened,
# which would readmit the drift the gate exists to stop -- so the runtime gate
# and the oracle cannot disagree about what the taxonomy is. Manage encodes phase
# and subreason in its message string, so only its -Code is a taxonomy field and
# only -Code is gated; Expand emits all three through typed parameters.
$script:scriptBlockAssertProductionValidateSetsClosed = {
    param (
        [Parameter(Mandatory = $true)]
        [object]$Catalog,

        [Parameter(Mandatory = $true)]
        [string]$HelperLiteralPath,

        [Parameter(Mandatory = $true)]
        [string]$ContextLiteralPath
    )

    $objDiagnostic = New-Object 'System.Collections.Generic.HashSet[string]' (
        [System.StringComparer]::Ordinal
    )
    foreach ($strValue in $Catalog.ClosedSets.DiagnosticCode) {
        [void]$objDiagnostic.Add([string]$strValue)
    }
    $objPhase = New-Object 'System.Collections.Generic.HashSet[string]' (
        [System.StringComparer]::Ordinal
    )
    foreach ($strValue in $Catalog.ClosedSets.Phase) {
        [void]$objPhase.Add([string]$strValue)
    }
    $objSubreason = New-Object 'System.Collections.Generic.HashSet[string]' (
        [System.StringComparer]::Ordinal
    )
    foreach ($strValue in $Catalog.ClosedSets.Subreason) {
        [void]$objSubreason.Add([string]$strValue)
    }

    # Each expectation names a production file, the builder scriptblock inside it
    # (by variable name, scope prefix stripped), and the closed set every gated
    # parameter's [ValidateSet(...)] must equal.
    $arrExpectation = @(
        [ordered]@{
            Path    = $HelperLiteralPath
            Builder = 'scriptBlockNewCandidateHelperException'
            Fields  = [ordered]@{
                Code      = $objDiagnostic
                Phase     = $objPhase
                Subreason = $objSubreason
            }
        },
        [ordered]@{
            Path    = $ContextLiteralPath
            Builder = 'scriptBlockNewCandidateException'
            Fields  = [ordered]@{
                Code = $objDiagnostic
            }
        }
    )

    foreach ($hashtableExpectation in $arrExpectation) {
        $strBuilder = [string]$hashtableExpectation.Builder
        $objErrors = $null
        $objAst = [System.Management.Automation.Language.Parser]::ParseFile(
            [string]$hashtableExpectation.Path, [ref]$null, [ref]$objErrors)
        if ($null -eq $objAst -or @($objErrors).Count -ne 0) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('validateset-parse-' + $strBuilder)
        }

        # Find the builder's assignment by its variable name (scope stripped),
        # then the scriptblock literal it is assigned. A builder this cannot find
        # is a structural change to fail on, not to skip.
        $objBuilderScriptBlock = $null
        foreach ($objAssign in @($objAst.FindAll(
                    {
                        param ($SyntaxNode)
                        $SyntaxNode -is
                            [System.Management.Automation.Language.AssignmentStatementAst] -and
                        $SyntaxNode.Left -is
                            [System.Management.Automation.Language.VariableExpressionAst]
                    },
                    $true
                ))) {
            $strName = ([string]$objAssign.Left.VariablePath.UserPath) -replace '^[A-Za-z]+:', ''
            if ($strName -cne $strBuilder) { continue }
            $objBuilderScriptBlock = $objAssign.Right.Find(
                {
                    param ($SyntaxNode)
                    $SyntaxNode -is
                        [System.Management.Automation.Language.ScriptBlockExpressionAst]
                },
                $true
            )
            break
        }
        if ($null -eq $objBuilderScriptBlock -or
            $null -eq $objBuilderScriptBlock.ScriptBlock.ParamBlock) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                -Detail ('validateset-builder-' + $strBuilder)
        }

        foreach ($strField in $hashtableExpectation.Fields.Keys) {
            $objExpectedSet = $hashtableExpectation.Fields[$strField]
            $objParameter = $null
            foreach ($objCandidate in $objBuilderScriptBlock.ScriptBlock.ParamBlock.Parameters) {
                if (([string]$objCandidate.Name.VariablePath.UserPath) -ceq $strField) {
                    $objParameter = $objCandidate
                    break
                }
            }
            if ($null -eq $objParameter) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                    -Detail ('validateset-param-' + $strBuilder + '-' + $strField)
            }

            # Collect the ValidateSet's declared literals. More than one
            # ValidateSet on the parameter, or a non-literal member, is a shape
            # this equality cannot read and is refused rather than guessed.
            $objValidateSet = $null
            foreach ($objAttribute in $objParameter.Attributes) {
                if ($objAttribute -is
                        [System.Management.Automation.Language.AttributeAst] -and
                    ([string]$objAttribute.TypeName.Name) -ceq 'ValidateSet') {
                    if ($null -ne $objValidateSet) {
                        & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                            -Detail ('validateset-attr-count-' + $strBuilder + '-' + $strField)
                    }
                    $objValidateSet = $objAttribute
                }
            }
            if ($null -eq $objValidateSet) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                    -Detail ('validateset-absent-' + $strBuilder + '-' + $strField)
            }
            $objDeclared = New-Object 'System.Collections.Generic.HashSet[string]' (
                [System.StringComparer]::Ordinal
            )
            foreach ($objArgument in $objValidateSet.PositionalArguments) {
                if ($objArgument -isnot
                    [System.Management.Automation.Language.StringConstantExpressionAst]) {
                    & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                        -Detail ('validateset-nonliteral-' + $strBuilder + '-' + $strField)
                }
                $strDeclared = [string]$objArgument.Value
                if (-not $objDeclared.Add($strDeclared)) {
                    & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                        -Detail ('validateset-duplicate-' + $strBuilder + '-' + $strField +
                            '-' + $strDeclared)
                }
            }

            # Ordinal set equality, reported per offending value so a drift names
            # itself. A missing value narrows the gate below the taxonomy; an
            # extra value widens it above the taxonomy; both break the invariant.
            foreach ($strWanted in $objExpectedSet) {
                if (-not $objDeclared.Contains($strWanted)) {
                    & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                        -Detail ('validateset-missing-' + $strBuilder + '-' + $strField +
                            '-' + $strWanted)
                }
            }
            foreach ($strDeclared in $objDeclared) {
                if (-not $objExpectedSet.Contains($strDeclared)) {
                    & $script:scriptBlockStopHarness -Code 'catalog-invalid' `
                        -Detail ('validateset-extra-' + $strBuilder + '-' + $strField +
                            '-' + $strDeclared)
                }
            }
        }
    }
}

$script:scriptBlockGetScriptVersionRecord = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ScriptText,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedVersion
    )

    $objFirstFunction = [regex]::Match(
        $ScriptText,
        '(?m)^function[\x20\x09]+[A-Za-z0-9_-]+[\x20\x09]*\{'
    )
    if (-not $objFirstFunction.Success) {
        & $script:scriptBlockStopHarness -Code 'invalid-version' -Detail 'function'
    }
    $strPreamble = $ScriptText.Substring(0, $objFirstFunction.Index)
    $arrNoteBlocks = @([regex]::Matches(
        $strPreamble,
        '(?s)<#(?:(?!#>).)*\.NOTES(?:(?!#>).)*#>'
    ))
    $arrAllMarkers = @([regex]::Matches($ScriptText, '(?m)^Version:[^\r\n]*$'))
    if ($arrNoteBlocks.Count -ne 1 -or $arrAllMarkers.Count -ne 1) {
        & $script:scriptBlockStopHarness -Code 'invalid-version' -Detail 'marker-count'
    }
    $arrMarkers = @([regex]::Matches(
        $arrNoteBlocks[0].Value,
        '(?m)^Version: ([0-9]+)\.([0-9]+)\.([0-9]{8})\.([0-9]+)$'
    ))
    if ($arrMarkers.Count -ne 1 -or $arrMarkers[0].Value -cne $arrAllMarkers[0].Value) {
        & $script:scriptBlockStopHarness -Code 'invalid-version' -Detail 'marker-grammar'
    }
    $arrParts = [string[]]@(
        $arrMarkers[0].Groups[1].Value,
        $arrMarkers[0].Groups[2].Value,
        $arrMarkers[0].Groups[3].Value,
        $arrMarkers[0].Groups[4].Value
    )
    foreach ($strPart in $arrParts) {
        $intPart = 0L
        if (($strPart.Length -gt 1 -and $strPart[0] -eq '0') -or
            -not [int64]::TryParse(
                $strPart,
                [System.Globalization.NumberStyles]::None,
                [System.Globalization.CultureInfo]::InvariantCulture,
                [ref]$intPart
            ) -or $intPart -gt [int]::MaxValue) {
            & $script:scriptBlockStopHarness -Code 'invalid-version' -Detail 'component'
        }
    }
    $objDate = [datetime]::MinValue
    if (-not [datetime]::TryParseExact(
        $arrParts[2],
        'yyyyMMdd',
        [System.Globalization.CultureInfo]::InvariantCulture,
        [System.Globalization.DateTimeStyles]::None,
        [ref]$objDate
    )) {
        & $script:scriptBlockStopHarness -Code 'invalid-version' -Detail 'date'
    }
    $strVersion = $arrParts -join '.'
    $objVersion = New-Object System.Version(
        [int]$arrParts[0],
        [int]$arrParts[1],
        [int]$arrParts[2],
        [int]$arrParts[3]
    )
    if ($objVersion.ToString() -cne $strVersion -or $strVersion -cne $ExpectedVersion) {
        & $script:scriptBlockStopHarness -Code 'unexpected-version' -Detail 'binding'
    }
    return $objVersion
}

$script:scriptBlockAssertOrdinaryDirectoryEnvelope = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath
    )

    $objCurrent = New-Object System.IO.DirectoryInfo($LiteralPath)
    $strPreviousDevice = $null
    # Resolved once, above the loop. A bare 'stat' would bind to a function or
    # alias in the invoking scope, and a PowerShell function never sets
    # $LASTEXITCODE, so a stale status plus chosen numeric output could pass or
    # fail the device check. Resolving per component instead measured ~9.7 ms
    # against ~3.1 ms for the native call, on a loop walking every ancestor.
    $strHarnessStatPath = $null
    if (-not $script:boolCandidateIsWindows) {
        $strHarnessStatPath = [string](& $script:scriptBlockResolveHarnessNativePath `
            -CandidatePath ([string[]]@('/usr/bin/stat', '/bin/stat', '/usr/local/bin/stat')))
        if ($strHarnessStatPath.Length -eq 0) {
            & $script:scriptBlockStopHarness -Code 'script-identity-invalid' `
                -Detail 'directory-identity'
        }
    }
    while ($null -ne $objCurrent) {
        try {
            $objAttributes = [System.IO.File]::GetAttributes($objCurrent.FullName)
        } catch {
            & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'directory-attribute'
        }
        if (($objAttributes -band [System.IO.FileAttributes]::Directory) -eq 0 -or
            ($objAttributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
            & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'directory-component'
        }
        if (-not $script:boolCandidateIsWindows) {
            $arrFileSystemStatus = @(& $strHarnessStatPath '-Lc' '%d' '--' `
                $objCurrent.FullName 2>$null)
            if ($LASTEXITCODE -ne 0 -or $arrFileSystemStatus.Count -ne 1 -or
                $arrFileSystemStatus[0] -notmatch '^[0-9]+$') {
                & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'directory-identity'
            }
            if ($null -ne $strPreviousDevice -and
                $strPreviousDevice -cne $arrFileSystemStatus[0]) {
                & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'directory-mount'
            }
            $strPreviousDevice = [string]$arrFileSystemStatus[0]
        }
        $objCurrent = $objCurrent.Parent
    }
}

$script:scriptBlockResolveFixedScriptClaim = {
    param (
        [AllowNull()]
        [object]$Value,

        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedPath
    )

    $strValue = & $script:scriptBlockAssertRawString -Value $Value -Name $Name
    if ([System.Management.Automation.WildcardPattern]::ContainsWildcardCharacters($strValue)) {
        & $script:scriptBlockStopHarness -Code 'parameter' -Detail "$Name-wildcard"
    }
    $strProviderPath = $strValue
    $intSeparator = $strValue.IndexOf('::', [System.StringComparison]::Ordinal)
    if ($intSeparator -ge 0) {
        $strProviderName = $strValue.Substring(0, $intSeparator)
        if ($strProviderName -cnotin @(
            'FileSystem',
            'Microsoft.PowerShell.Core\FileSystem'
        )) {
            & $script:scriptBlockStopHarness -Code 'parameter' -Detail "$Name-provider"
        }
        $strProviderPath = $strValue.Substring($intSeparator + 2)
    }
    $boolDriveRelative = $strProviderPath.Length -ge 2 -and
        [System.Char]::IsLetter($strProviderPath[0]) -and
        $strProviderPath[1] -eq [char]':' -and
        ($strProviderPath.Length -eq 2 -or
            ($strProviderPath[2] -ne [char]'\' -and $strProviderPath[2] -ne [char]'/'))
    if ($boolDriveRelative -or -not [System.IO.Path]::IsPathRooted($strProviderPath)) {
        & $script:scriptBlockStopHarness -Code 'parameter' -Detail "$Name-relative"
    }
    try {
        $strFullPath = [System.IO.Path]::GetFullPath($strProviderPath)
    } catch {
        & $script:scriptBlockStopHarness -Code 'parameter' -Detail "$Name-normalization"
    }
    if (-not [System.String]::Equals(
        $strFullPath,
        $ExpectedPath,
        $script:objCandidatePathComparison
    )) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail "$Name-fixed-path"
    }
    return $strFullPath
}

$script:scriptBlockTestByteSequenceEqual = {
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [byte[]]$Left,

        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [byte[]]$Right
    )

    if ($Left.Length -ne $Right.Length) {
        return $false
    }
    for ($intIndex = 0; $intIndex -lt $Left.Length; $intIndex++) {
        if ($Left[$intIndex] -ne $Right[$intIndex]) {
            return $false
        }
    }
    return $true
}

$script:scriptBlockConvertFromAsciiMetadata = {
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [byte[]]$Bytes
    )

    foreach ($bytValue in $Bytes) {
        if ($bytValue -lt 0x20 -or $bytValue -gt 0x7E) {
            & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'metadata-byte'
        }
    }
    return [System.Text.Encoding]::ASCII.GetString($Bytes)
}

$script:scriptBlockSplitOneNulGitRecord = {
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [byte[]]$Bytes,

        [Parameter(Mandatory = $true)]
        [byte[]]$ExpectedPathBytes
    )

    if ($Bytes.Length -lt 3 -or $Bytes[$Bytes.Length - 1] -ne 0) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'record-termination'
    }
    $intNullByteCount = @($Bytes | Where-Object { $_ -eq 0 }).Count
    if ($intNullByteCount -ne 1) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'record-cardinality'
    }
    $intTab = -1
    for ($intIndex = 0; $intIndex -lt ($Bytes.Length - 1); $intIndex++) {
        if ($Bytes[$intIndex] -eq 9) {
            if ($intTab -ne -1) {
                & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'record-tab'
            }
            $intTab = $intIndex
        }
    }
    if ($intTab -le 0) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'record-tab'
    }
    $arrMetadata = New-Object byte[] $intTab
    [System.Array]::Copy($Bytes, 0, $arrMetadata, 0, $intTab)
    $intPathLength = $Bytes.Length - $intTab - 2
    $arrPath = New-Object byte[] $intPathLength
    [System.Array]::Copy($Bytes, $intTab + 1, $arrPath, 0, $intPathLength)
    if (-not (& $script:scriptBlockTestByteSequenceEqual -Left $arrPath -Right $ExpectedPathBytes)) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'literal-path'
    }
    return & $script:scriptBlockConvertFromAsciiMetadata -Bytes $arrMetadata
}

$script:scriptBlockGetTrimmedAsciiLine = {
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [byte[]]$Bytes
    )

    $intContentLength = $Bytes.Length
    if ($intContentLength -gt 0 -and $Bytes[$intContentLength - 1] -eq 0x0A) {
        $intContentLength--
        if ($intContentLength -gt 0 -and $Bytes[$intContentLength - 1] -eq 0x0D) {
            $intContentLength--
        }
    }
    if ($intContentLength -eq 0) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'native-line'
    }
    for ($intIndex = 0; $intIndex -lt $intContentLength; $intIndex++) {
        if ($Bytes[$intIndex] -lt 0x20 -or $Bytes[$intIndex] -gt 0x7E) {
            & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'native-line'
        }
    }
    $intExpectedLength = $intContentLength
    if ($Bytes.Length -gt $intContentLength) {
        $intExpectedLength += if ($Bytes[$intContentLength] -eq 0x0D) { 2 } else { 1 }
    }
    if ($Bytes.Length -ne $intExpectedLength) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'native-line'
    }
    return [System.Text.Encoding]::ASCII.GetString($Bytes, 0, $intContentLength)
}

$script:scriptBlockGetCandidateTreeObjectId = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Metadata,

        [Parameter(Mandatory = $true)]
        [ValidateSet(40, 64)]
        [int]$ObjectIdLength
    )

    $objTreeMatch = [regex]::Match(
        $Metadata,
        '^100644 blob ([0-9a-f]+)$',
        [System.Text.RegularExpressions.RegexOptions]::CultureInvariant
    )
    if (-not $objTreeMatch.Success -or
        $objTreeMatch.Groups[1].Value.Length -ne $ObjectIdLength) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'tree-record'
    }
    return $objTreeMatch.Groups[1].Value
}

$script:scriptBlockGetCandidateIndexObjectId = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Metadata,

        [Parameter(Mandatory = $true)]
        [ValidateSet(40, 64)]
        [int]$ObjectIdLength,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedObjectId
    )

    $objIndexMatch = [regex]::Match(
        $Metadata,
        '^100644 ([0-9a-f]+) 0$',
        [System.Text.RegularExpressions.RegexOptions]::CultureInvariant
    )
    if (-not $objIndexMatch.Success -or
        $objIndexMatch.Groups[1].Value.Length -ne $ObjectIdLength -or
        $objIndexMatch.Groups[1].Value -cne $ExpectedObjectId) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'index-record'
    }
    return $objIndexMatch.Groups[1].Value
}

$script:scriptBlockAssertCandidateWorkingObjectId = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$ObjectId,

        [Parameter(Mandatory = $true)]
        [ValidateSet(40, 64)]
        [int]$ObjectIdLength,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedObjectId
    )

    if ($ObjectId.Length -ne $ObjectIdLength -or
        $ObjectId -cnotmatch '^[0-9a-f]+$' -or
        $ObjectId -cne $ExpectedObjectId) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'working-object'
    }
}

$script:scriptBlockAssertTrackedBlobIdentity = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,

        [Parameter(Mandatory = $true)]
        [string]$GitPath,

        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [string]$RelativePath
    )

    [void](& $script:scriptBlockAssertOrdinaryDirectoryEnvelope -LiteralPath $RepositoryRoot)
    $objFile = New-Object System.IO.FileInfo($LiteralPath)
    if (-not $objFile.Exists -or
        ($objFile.Attributes -band [System.IO.FileAttributes]::Directory) -ne 0 -or
        ($objFile.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'working-file-type'
    }
    [void](& $script:scriptBlockAssertOrdinaryDirectoryEnvelope -LiteralPath $objFile.Directory.FullName)

    $arrRelativeBytes = [System.Text.Encoding]::ASCII.GetBytes($RelativePath)
    $objFormatResult = & $script:scriptBlockInvokeNativeRaw -FilePath $GitPath -WorkingDirectory $RepositoryRoot `
        -ArgumentList @('rev-parse', '--show-object-format')
    if ($objFormatResult.ExitCode -ne 0) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'object-format-status'
    }
    $strObjectFormat = & $script:scriptBlockGetTrimmedAsciiLine `
        -Bytes $objFormatResult.StandardOutput
    $intObjectIdLength = if ($strObjectFormat -ceq 'sha1') {
        40
    } elseif ($strObjectFormat -ceq 'sha256') {
        64
    } else {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'object-format'
    }

    $objTreeResult = & $script:scriptBlockInvokeNativeRaw -FilePath $GitPath -WorkingDirectory $RepositoryRoot `
        -ArgumentList @('ls-tree', '-z', 'HEAD', '--', $RelativePath)
    if ($objTreeResult.ExitCode -ne 0) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'tree-status'
    }
    $strTreeMetadata = & $script:scriptBlockSplitOneNulGitRecord `
        -Bytes $objTreeResult.StandardOutput `
        -ExpectedPathBytes $arrRelativeBytes
    $strHeadObjectId = & $script:scriptBlockGetCandidateTreeObjectId `
        -Metadata $strTreeMetadata `
        -ObjectIdLength $intObjectIdLength

    $objIndexResult = & $script:scriptBlockInvokeNativeRaw -FilePath $GitPath -WorkingDirectory $RepositoryRoot `
        -ArgumentList @('ls-files', '--stage', '-z', '--', $RelativePath)
    if ($objIndexResult.ExitCode -ne 0) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'index-status'
    }
    $strIndexMetadata = & $script:scriptBlockSplitOneNulGitRecord `
        -Bytes $objIndexResult.StandardOutput `
        -ExpectedPathBytes $arrRelativeBytes
    [void](& $script:scriptBlockGetCandidateIndexObjectId `
        -Metadata $strIndexMetadata `
        -ObjectIdLength $intObjectIdLength `
        -ExpectedObjectId $strHeadObjectId)

    $objWorkingResult = & $script:scriptBlockInvokeNativeRaw -FilePath $GitPath -WorkingDirectory $RepositoryRoot `
        -ArgumentList @('hash-object', '--no-filters', '--', $RelativePath)
    if ($objWorkingResult.ExitCode -ne 0) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'working-status'
    }
    $strWorkingObjectId = & $script:scriptBlockGetTrimmedAsciiLine `
        -Bytes $objWorkingResult.StandardOutput
    [void](& $script:scriptBlockAssertCandidateWorkingObjectId `
        -ObjectId $strWorkingObjectId `
        -ObjectIdLength $intObjectIdLength `
        -ExpectedObjectId $strHeadObjectId)

    return $strHeadObjectId
}

$script:scriptBlockAssertTrackedScriptIdentity = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,

        [Parameter(Mandatory = $true)]
        [string]$GitPath,

        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [string]$RelativePath,

        [Parameter(Mandatory = $true)]
        [string]$ExpectedVersion,

        [Parameter(Mandatory = $true)]
        [uint32]$ExpectedFunctionCount
    )

    $strHeadObjectId = & $script:scriptBlockAssertTrackedBlobIdentity `
        -RepositoryRoot $RepositoryRoot `
        -GitPath $GitPath `
        -LiteralPath $LiteralPath `
        -RelativePath $RelativePath

    $arrFileBytes = [System.IO.File]::ReadAllBytes($LiteralPath)
    $strScriptText = & $script:scriptBlockConvertFromStrictUtf8 -Bytes $arrFileBytes
    [void](& $script:scriptBlockGetScriptVersionRecord `
        -ScriptText $strScriptText `
        -ExpectedVersion $ExpectedVersion)
    $arrParseErrors = $null
    $arrTokens = $null
    $objAbstractSyntaxTree = [System.Management.Automation.Language.Parser]::ParseInput(
        $strScriptText,
        [ref]$arrTokens,
        [ref]$arrParseErrors
    )
    if ($arrParseErrors.Count -ne 0) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'parser'
    }
    $arrFunctions = @($objAbstractSyntaxTree.FindAll({
        param ($SyntaxNode)
        $SyntaxNode -is [System.Management.Automation.Language.FunctionDefinitionAst]
    }, $true))
    if ($arrFunctions.Count -ne $ExpectedFunctionCount) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'function-count'
    }
    return $strHeadObjectId
}

$script:scriptBlockAssertExactPropertyNames = {
    param (
        [Parameter(Mandatory = $true)]
        [object]$Value,

        [Parameter(Mandatory = $true)]
        [string[]]$Names,

        [Parameter(Mandatory = $true)]
        [string]$Detail
    )

    if ($null -eq $Value) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' -Detail "$Detail-null"
    }
    $arrProperties = @($Value.PSObject.Properties)
    if ($arrProperties.Count -ne $Names.Count) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' -Detail "$Detail-property-count"
    }
    for ($intIndex = 0; $intIndex -lt $Names.Count; $intIndex++) {
        if ($arrProperties[$intIndex].Name -cne $Names[$intIndex] -or
            $arrProperties[$intIndex].MemberType -ne
                [System.Management.Automation.PSMemberTypes]::NoteProperty) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' -Detail "$Detail-property-order"
        }
    }
}

$script:scriptBlockReadCandidateCatalog = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath
    )

    $objFile = New-Object System.IO.FileInfo($LiteralPath)
    if (-not $objFile.Exists -or
        ($objFile.Attributes -band [System.IO.FileAttributes]::Directory) -ne 0 -or
        ($objFile.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' -Detail 'file-type'
    }
    $arrBytes = [System.IO.File]::ReadAllBytes($LiteralPath)
    $strText = & $script:scriptBlockConvertFromStrictUtf8 -Bytes $arrBytes
    try {
        $objCatalog = $strText | ConvertFrom-Json
    } catch {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' -Detail 'json'
    }
    & $script:scriptBlockAssertExactPropertyNames -Value $objCatalog -Names @(
        'SchemaVersion',
        'CatalogVersion',
        'CaseCount',
        'CaseIdPattern',
        'SemanticCasePattern',
        'OracleProfilePattern',
        'ClosedSets',
        'Cases'
    ) -Detail 'catalog'
    if ($null -eq $objCatalog.SchemaVersion -or
        $objCatalog.SchemaVersion.GetType() -notin @([System.Int32], [System.Int64]) -or
        $objCatalog.SchemaVersion -ne 1 -or
        $null -eq $objCatalog.CatalogVersion -or
        $objCatalog.CatalogVersion.GetType() -ne [System.String] -or
        $objCatalog.CatalogVersion -cne $script:strCandidateCatalogVersion -or
        $null -eq $objCatalog.CaseCount -or
        $objCatalog.CaseCount.GetType() -notin @([System.Int32], [System.Int64]) -or
        $objCatalog.CaseCount -ne $script:intCandidateCaseCount -or
        $null -eq $objCatalog.CaseIdPattern -or
        $objCatalog.CaseIdPattern.GetType() -ne [System.String] -or
        $objCatalog.CaseIdPattern -cne '^PS-P1A-[A-Z]+-[0-9]{2}$' -or
        $null -eq $objCatalog.SemanticCasePattern -or
        $objCatalog.SemanticCasePattern.GetType() -ne [System.String] -or
        $objCatalog.SemanticCasePattern -cne '^[a-z0-9]+(?:[.-][a-z0-9]+)*$' -or
        $null -eq $objCatalog.OracleProfilePattern -or
        $objCatalog.OracleProfilePattern.GetType() -ne [System.String] -or
        $objCatalog.OracleProfilePattern -cne '^oracle\.ps-p1a-[a-z]+-[0-9]{2}\.v1$' -or
        $null -eq $objCatalog.Cases -or
        $objCatalog.Cases.GetType() -ne [System.Object[]] -or
        $objCatalog.Cases.Count -ne $script:intCandidateCaseCount) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' -Detail 'header'
    }
    & $script:scriptBlockAssertExactPropertyNames -Value $objCatalog.ClosedSets -Names @(
        'Applicability',
        'RequiredRuntime',
        'PrimitiveProbeRule',
        'InitialState',
        'Result',
        'Status',
        'Phase',
        'Subreason',
        'DiagnosticCode',
        'PreCleanupState',
        'CleanupSequence',
        'CandidateFinalState',
        'ContextFinalState',
        'SentinelState',
        'SourceState',
        'HarnessVerdict',
        'HarnessDiagnosticCode'
    ) -Detail 'closed-sets'
    foreach ($objClosedSetProperty in $objCatalog.ClosedSets.PSObject.Properties) {
        if ($null -eq $objClosedSetProperty.Value -or
            $objClosedSetProperty.Value.GetType() -ne [System.Object[]] -or
            $objClosedSetProperty.Value.Count -eq 0) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' -Detail 'closed-set-type'
        }
        $objClosedSetValues = New-Object 'System.Collections.Generic.HashSet[string]' (
            [System.StringComparer]::Ordinal
        )
        foreach ($objClosedSetValue in $objClosedSetProperty.Value) {
            if ($null -eq $objClosedSetValue -or
                $objClosedSetValue.GetType() -ne [System.String] -or
                $objClosedSetValue.Length -eq 0 -or
                -not $objClosedSetValues.Add($objClosedSetValue)) {
                & $script:scriptBlockStopHarness `
                    -Code 'catalog-invalid' `
                    -Detail 'closed-set-value'
            }
        }
    }

    $objCaseIds = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
    $objSemantics = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
    $objProfiles = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::Ordinal)
    $objAllocationBuilder = New-Object System.Text.StringBuilder
    foreach ($objCase in $objCatalog.Cases) {
        & $script:scriptBlockAssertExactPropertyNames -Value $objCase -Names @(
            'CaseId',
            'SemanticCase',
            'SemanticVariant',
            'OracleProfile',
            'FixtureRecipe',
            'RequiredRuntimes',
            'Applicability',
            'PrimitiveProbeRule',
            'InitialState',
            'ExpectedResult',
            'ExpectedStatus',
            'ExpectedPhase',
            'ExpectedSubreason',
            'ExpectedDiagnosticCode',
            'ExpectedPreCleanupState',
            'ExpectedCleanupSequence',
            'ExpectedCandidateFinalState',
            'ExpectedContextFinalState',
            'ExpectedFilesystemCallCount',
            'ExpectedSentinelState',
            'ExpectedSourceState',
            'FixtureLength',
            'FixtureSha256'
        ) -Detail 'case'
        foreach ($strProperty in @(
            'CaseId','SemanticCase','OracleProfile','FixtureRecipe','Applicability',
            'PrimitiveProbeRule','InitialState',
            'ExpectedResult','ExpectedStatus','ExpectedPhase','ExpectedSubreason',
            'ExpectedDiagnosticCode','ExpectedPreCleanupState','ExpectedCleanupSequence',
            'ExpectedCandidateFinalState','ExpectedContextFinalState',
            'ExpectedSentinelState','ExpectedSourceState'
        )) {
            if ($null -eq $objCase.$strProperty -or
                $objCase.$strProperty.GetType() -ne [System.String] -or
                $objCase.$strProperty.Length -eq 0) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' -Detail 'case-string'
            }
        }
        if ($objCase.CaseId -cnotmatch $objCatalog.CaseIdPattern -or
            $objCase.SemanticCase -cnotmatch $objCatalog.SemanticCasePattern -or
            ($null -ne $objCase.SemanticVariant -and
                ($objCase.SemanticVariant.GetType() -ne [System.String] -or
                    $objCase.SemanticVariant -cnotmatch $objCatalog.SemanticCasePattern)) -or
            $objCase.OracleProfile -cnotmatch $objCatalog.OracleProfilePattern -or
            $null -eq $objCase.RequiredRuntimes -or
            $objCase.RequiredRuntimes.GetType() -ne [System.Object[]] -or
            $objCase.RequiredRuntimes.Count -ne 3 -or
            $objCase.RequiredRuntimes[0] -cne 'WindowsPowerShell5.1' -or
            $objCase.RequiredRuntimes[1] -cne 'PowerShell7Windows' -or
            $objCase.RequiredRuntimes[2] -cne 'PowerShell7Ubuntu' -or
            -not $objCaseIds.Add($objCase.CaseId) -or
            -not $objSemantics.Add($objCase.SemanticCase) -or
            -not $objProfiles.Add($objCase.OracleProfile) -or
            $null -eq $objCase.ExpectedFilesystemCallCount -or
            $objCase.ExpectedFilesystemCallCount.GetType() -notin @(
                [System.Int32],
                [System.Int64]
            ) -or
            $objCase.ExpectedFilesystemCallCount -lt 0 -or
            ($null -ne $objCase.FixtureLength -and
                ($objCase.FixtureLength.GetType() -notin @(
                        [System.Int32],
                        [System.Int64]
                    ) -or
                    $objCase.FixtureLength -lt 0)) -or
            ($null -ne $objCase.FixtureSha256 -and
                ($objCase.FixtureSha256.GetType() -ne [System.String] -or
                    $objCase.FixtureSha256 -cnotmatch '^[0-9a-f]{64}$'))) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' -Detail 'case-value'
        }
        $hashtableSetMap = [ordered]@{
            Applicability = 'Applicability'
            PrimitiveProbeRule = 'PrimitiveProbeRule'
            InitialState = 'InitialState'
            ExpectedResult = 'Result'
            ExpectedStatus = 'Status'
            ExpectedPhase = 'Phase'
            ExpectedSubreason = 'Subreason'
            ExpectedDiagnosticCode = 'DiagnosticCode'
            ExpectedPreCleanupState = 'PreCleanupState'
            ExpectedCleanupSequence = 'CleanupSequence'
            ExpectedCandidateFinalState = 'CandidateFinalState'
            ExpectedContextFinalState = 'ContextFinalState'
            ExpectedSentinelState = 'SentinelState'
            ExpectedSourceState = 'SourceState'
        }
        foreach ($strCaseProperty in $hashtableSetMap.Keys) {
            $strSetProperty = $hashtableSetMap[$strCaseProperty]
            if ($objCase.$strCaseProperty -cnotin @($objCatalog.ClosedSets.$strSetProperty)) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' -Detail 'case-enum'
            }
        }
        foreach ($strRequiredRuntime in $objCase.RequiredRuntimes) {
            if ($null -eq $strRequiredRuntime -or
                $strRequiredRuntime.GetType() -ne [System.String] -or
                $strRequiredRuntime -cnotin @($objCatalog.ClosedSets.RequiredRuntime)) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' -Detail 'case-runtime'
            }
        }
        $boolLinkSemanticCase = & $script:scriptBlockTestLinkSemanticCase `
            -SemanticCase $objCase.SemanticCase
        if (($boolLinkSemanticCase -and $objCase.PrimitiveProbeRule -cne 'required-link') -or
            (-not $boolLinkSemanticCase -and $objCase.PrimitiveProbeRule -cne 'none')) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' -Detail 'case-probe-rule'
        }
        $boolNotCreatedCase = $objCase.SemanticCase.StartsWith(
            'script.',
            [System.StringComparison]::Ordinal
        ) -or $objCase.SemanticCase -in @(
            'environment.trusted.nonfilesystem-provider',
            'environment.trusted.link-component',
            'environment.trusted.wrong-type'
        )
        # Every other case begins Active, which left the terminal lifecycle states
        # unreachable from the catalog: no row could hand an already-terminal
        # context to an entry point. The exception is named rather than the rule
        # relaxed, so admitting one terminal-start case does not quietly admit a
        # wrong initial state everywhere else.
        $arrTerminalStartCase = [string[]]@('helper.cleanup.terminal-initial-state')
        $boolTerminalStartCase = $objCase.SemanticCase -cin $arrTerminalStartCase
        if ($boolTerminalStartCase) {
            if ($objCase.InitialState -cnotin @('CleanupFailed', 'Disposed')) {
                & $script:scriptBlockStopHarness `
                    -Code 'catalog-invalid' -Detail 'case-initial-state'
            }
        } elseif (($boolNotCreatedCase -and $objCase.InitialState -cne 'NotCreated') -or
            (-not $boolNotCreatedCase -and $objCase.InitialState -cne 'Active')) {
            & $script:scriptBlockStopHarness -Code 'catalog-invalid' -Detail 'case-initial-state'
        }
        [void]$objAllocationBuilder.Append($objCase.CaseId)
        [void]$objAllocationBuilder.Append([char]0)
        [void]$objAllocationBuilder.Append($objCase.SemanticCase)
        [void]$objAllocationBuilder.Append([char]0)
        [void]$objAllocationBuilder.Append($objCase.OracleProfile)
        [void]$objAllocationBuilder.Append([char]10)
    }
    $arrAllocationBytes = (New-Object System.Text.UTF8Encoding($false)).GetBytes(
        $objAllocationBuilder.ToString()
    )
    $strAllocationSha256 = & $script:scriptBlockGetByteArraySha256 -Bytes $arrAllocationBytes
    if ($strAllocationSha256 -cne $script:strCandidateAllocationSha256) {
        & $script:scriptBlockStopHarness -Code 'catalog-invalid' -Detail 'allocation-identity'
    }
    return $objCatalog
}

$script:scriptBlockAssertCatalogMutationsRejected = {
    param (
        [Parameter(Mandatory = $true)]
        [object]$Catalog,

        [Parameter(Mandatory = $true)]
        [string]$RunRoot
    )

    $arrMutationSpecifications = @(
        [pscustomobject][ordered]@{
            Name = 'missing-property'
            Apply = {
                param ([object]$CatalogMutation)
                [void]$CatalogMutation.Cases[0].PSObject.Properties.Remove('SemanticVariant')
            }
        },
        [pscustomobject][ordered]@{
            Name = 'missing-case'
            Apply = {
                param ([object]$CatalogMutation)
                $CatalogMutation.Cases = [object[]]@(
                    $CatalogMutation.Cases | Select-Object -First 109
                )
            }
        },
        [pscustomobject][ordered]@{
            Name = 'unknown-property'
            Apply = {
                param ([object]$CatalogMutation)
                Add-Member `
                    -InputObject $CatalogMutation.Cases[0] `
                    -MemberType NoteProperty `
                    -Name 'UnknownProperty' `
                    -Value $true
            }
        },
        [pscustomobject][ordered]@{
            Name = 'duplicate-case-id'
            Apply = {
                param ([object]$CatalogMutation)
                $CatalogMutation.Cases[1].CaseId = $CatalogMutation.Cases[0].CaseId
            }
        },
        [pscustomobject][ordered]@{
            Name = 'duplicate-semantic-case'
            Apply = {
                param ([object]$CatalogMutation)
                $CatalogMutation.Cases[1].SemanticCase = $CatalogMutation.Cases[0].SemanticCase
            }
        },
        [pscustomobject][ordered]@{
            Name = 'duplicate-oracle-profile'
            Apply = {
                param ([object]$CatalogMutation)
                $CatalogMutation.Cases[1].OracleProfile = $CatalogMutation.Cases[0].OracleProfile
            }
        },
        [pscustomobject][ordered]@{
            Name = 'invalid-semantic-rename'
            Apply = {
                param ([object]$CatalogMutation)
                $CatalogMutation.Cases[0].SemanticCase = 'archive.valid.renamed'
            }
        },
        [pscustomobject][ordered]@{
            Name = 'slash-list-applicability'
            Apply = {
                param ([object]$CatalogMutation)
                $CatalogMutation.Cases[0].Applicability = 'Windows/Linux'
            }
        },
        [pscustomobject][ordered]@{
            Name = 'runtime-set-order'
            Apply = {
                param ([object]$CatalogMutation)
                $CatalogMutation.Cases[0].RequiredRuntimes = [object[]]@(
                    'PowerShell7Windows',
                    'WindowsPowerShell5.1',
                    'PowerShell7Ubuntu'
                )
            }
        },
        [pscustomobject][ordered]@{
            Name = 'primitive-probe-rule'
            Apply = {
                param ([object]$CatalogMutation)
                $CatalogMutation.Cases[0].PrimitiveProbeRule = 'required-link'
            }
        },
        [pscustomobject][ordered]@{
            Name = 'initial-state-relationship'
            Apply = {
                param ([object]$CatalogMutation)
                $CatalogMutation.Cases[0].InitialState = 'NotCreated'
            }
        },
        [pscustomobject][ordered]@{
            Name = 'closed-set-null'
            Apply = {
                param ([object]$CatalogMutation)
                $CatalogMutation.ClosedSets.Status = $null
            }
        },
        [pscustomobject][ordered]@{
            Name = 'case-count'
            Apply = {
                param ([object]$CatalogMutation)
                $CatalogMutation.CaseCount = 109
            }
        },
        [pscustomobject][ordered]@{
            Name = 'semantic-variant-grammar'
            Apply = {
                param ([object]$CatalogMutation)
                $CatalogMutation.Cases[0].SemanticVariant = 'invalid/variant'
            }
        },
        [pscustomobject][ordered]@{
            Name = 'fixture-sha256-grammar'
            Apply = {
                param ([object]$CatalogMutation)
                $CatalogMutation.Cases[0].FixtureSha256 = 'ABC'
            }
        },
        [pscustomobject][ordered]@{
            Name = 'header-pattern'
            Apply = {
                param ([object]$CatalogMutation)
                $CatalogMutation.CaseIdPattern = '.*'
            }
        }
    )
    $objUtf8WithoutBom = New-Object System.Text.UTF8Encoding($false)
    foreach ($objMutationSpecification in $arrMutationSpecifications) {
        $strCatalogJson = $Catalog | ConvertTo-Json -Depth 32 -Compress
        $objCatalogMutation = $strCatalogJson | ConvertFrom-Json
        & $objMutationSpecification.Apply $objCatalogMutation
        $strMutationPath = [System.IO.Path]::Combine(
            $RunRoot,
            'catalog-mutation-' + $objMutationSpecification.Name + '.json'
        )
        $strMutationJson = $objCatalogMutation | ConvertTo-Json -Depth 32 -Compress
        [System.IO.File]::WriteAllText($strMutationPath, $strMutationJson, $objUtf8WithoutBom)
        try {
            $boolRejected = $false
            try {
                [void](& $script:scriptBlockReadCandidateCatalog -LiteralPath $strMutationPath)
            } catch {
                if ($_.Exception.Data['PSStyleGuideHarnessCode'] -cne 'catalog-invalid') {
                    throw
                }
                $boolRejected = $true
            }
            if (-not $boolRejected) {
                & $script:scriptBlockStopHarness `
                    -Code 'orchestration-failed' `
                    -Detail ('catalog-mutation-' + $objMutationSpecification.Name)
            }
        } finally {
            [System.IO.File]::Delete($strMutationPath)
        }
    }
}

$script:scriptBlockGetFileEvidence = {
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
    try {
        $objSha256 = [System.Security.Cryptography.SHA256]::Create()
        try {
            $strSha256 = ([System.BitConverter]::ToString(
                $objSha256.ComputeHash($objStream)
            ) -replace '-', '').ToLowerInvariant()
        } finally {
            $objSha256.Dispose()
        }
        return [ordered]@{
            Length = [uint64]$objStream.Length
            Sha256 = [string]$strSha256
        }
    } finally {
        $objStream.Dispose()
    }
}

$script:scriptBlockGetByteArraySha256 = {
    param (
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [byte[]]$Bytes
    )

    $objSha256 = [System.Security.Cryptography.SHA256]::Create()
    try {
        return ([System.BitConverter]::ToString(
            $objSha256.ComputeHash($Bytes)
        ) -replace '-', '').ToLowerInvariant()
    } finally {
        $objSha256.Dispose()
    }
}

$script:scriptBlockWriteRepeatedBytes = {
    param (
        [Parameter(Mandatory = $true)]
        [System.IO.Stream]$Stream,

        [Parameter(Mandatory = $true)]
        [uint64]$Length,

        [Parameter(Mandatory = $true)]
        [byte]$Value,

        [AllowNull()]
        [byte[]]$Prefix
    )

    $uintWritten = [uint64]0
    if ($null -ne $Prefix -and $Prefix.Length -gt 0) {
        if ([uint64]$Prefix.Length -gt $Length) {
            & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'prefix-length'
        }
        $Stream.Write($Prefix, 0, $Prefix.Length)
        $uintWritten = [uint64]$Prefix.Length
    }
    $arrBuffer = New-Object byte[] $script:intCandidateBufferSize
    for ($intIndex = 0; $intIndex -lt $arrBuffer.Length; $intIndex++) {
        $arrBuffer[$intIndex] = $Value
    }
    while ($uintWritten -lt $Length) {
        $uintRemaining = [uint64]($Length - $uintWritten)
        $intWrite = if ($uintRemaining -gt [uint64]$arrBuffer.Length) {
            $arrBuffer.Length
        } else {
            [int]$uintRemaining
        }
        $Stream.Write($arrBuffer, 0, $intWrite)
        $uintWritten = [uint64]($uintWritten + [uint64]$intWrite)
    }
}

$script:scriptBlockNewEntrySpecification = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [uint64]$Length,

        [Parameter(Mandatory = $true)]
        [byte]$Value,

        [AllowNull()]
        [byte[]]$Prefix,

        [Parameter(Mandatory = $true)]
        [string]$Compression,

        [Parameter()]
        [int]$ExternalAttributes = 0
    )

    return [pscustomobject][ordered]@{
        Name = $Name
        Length = [uint64]$Length
        Value = [byte]$Value
        Prefix = $Prefix
        Compression = $Compression
        ExternalAttributes = [int]$ExternalAttributes
    }
}

$script:scriptBlockGetDefaultEntrySpecifications = {
    $listEntries = New-Object 'System.Collections.Generic.List[object]'
    $bytValue = [byte]0x41
    foreach ($strName in $script:arrCandidateExpectedName) {
        $arrPrefix = [System.Text.Encoding]::UTF8.GetBytes("# $strName`n")
        $listEntries.Add((& $script:scriptBlockNewEntrySpecification `
            -Name $strName `
            -Length ([uint64]$arrPrefix.Length) `
            -Value $bytValue `
            -Prefix $arrPrefix `
            -Compression 'Optimal'))
        $bytValue = [byte]($bytValue + 1)
    }
    return [object[]]$listEntries.ToArray()
}

$script:scriptBlockNormalizeZipFixtureHeaders = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [uint16]$ExpectedEntryCount
    )

    if (-not [System.BitConverter]::IsLittleEndian) {
        & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'zip-endianness'
    }
    $arrBytes = [System.IO.File]::ReadAllBytes($LiteralPath)
    $intEndOfCentralDirectoryOffset = $arrBytes.Length - 22
    if ($intEndOfCentralDirectoryOffset -lt 0 -or
        [System.BitConverter]::ToUInt32($arrBytes, $intEndOfCentralDirectoryOffset) -ne
            [uint32]0x06054B50 -or
        [System.BitConverter]::ToUInt16($arrBytes, $intEndOfCentralDirectoryOffset + 8) -ne
            $ExpectedEntryCount -or
        [System.BitConverter]::ToUInt16($arrBytes, $intEndOfCentralDirectoryOffset + 10) -ne
            $ExpectedEntryCount -or
        [System.BitConverter]::ToUInt16($arrBytes, $intEndOfCentralDirectoryOffset + 20) -ne 0) {
        & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'zip-end-record'
    }
    $uintCentralDirectorySize = [System.BitConverter]::ToUInt32(
        $arrBytes,
        $intEndOfCentralDirectoryOffset + 12
    )
    $uintCentralDirectoryOffset = [System.BitConverter]::ToUInt32(
        $arrBytes,
        $intEndOfCentralDirectoryOffset + 16
    )
    if ([uint64]$uintCentralDirectoryOffset + [uint64]$uintCentralDirectorySize -ne
        [uint64]$intEndOfCentralDirectoryOffset) {
        & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'zip-central-bounds'
    }

    $intCentralEntryOffset = [int]$uintCentralDirectoryOffset
    for ($intEntryIndex = 0; $intEntryIndex -lt $ExpectedEntryCount; $intEntryIndex++) {
        if ($intCentralEntryOffset -gt ($intEndOfCentralDirectoryOffset - 46) -or
            [System.BitConverter]::ToUInt32($arrBytes, $intCentralEntryOffset) -ne
                [uint32]0x02014B50) {
            & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'zip-central-entry'
        }
        $arrBytes[$intCentralEntryOffset + 4] = [byte]20
        $arrBytes[$intCentralEntryOffset + 5] = [byte]0
        $uintNameLength = [System.BitConverter]::ToUInt16($arrBytes, $intCentralEntryOffset + 28)
        $uintExtraLength = [System.BitConverter]::ToUInt16($arrBytes, $intCentralEntryOffset + 30)
        $uintCommentLength = [System.BitConverter]::ToUInt16($arrBytes, $intCentralEntryOffset + 32)
        $intCentralEntryOffset += 46 + [int]$uintNameLength +
            [int]$uintExtraLength + [int]$uintCommentLength
    }
    if ($intCentralEntryOffset -ne $intEndOfCentralDirectoryOffset) {
        & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'zip-central-cardinality'
    }
    [System.IO.File]::WriteAllBytes($LiteralPath, $arrBytes)
}

$script:scriptBlockRewriteZipFixtureAsStored = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [object[]]$Specifications
    )

    if (-not [System.BitConverter]::IsLittleEndian -or
        $Specifications.Count -eq 0 -or
        $Specifications.Count -gt [uint16]::MaxValue) {
        & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'stored-zip-platform'
    }
    $arrOriginalBytes = [System.IO.File]::ReadAllBytes($LiteralPath)
    $intEndOfCentralDirectoryOffset = $arrOriginalBytes.Length - 22
    if ($intEndOfCentralDirectoryOffset -lt 0 -or
        [System.BitConverter]::ToUInt32($arrOriginalBytes, $intEndOfCentralDirectoryOffset) -ne
            [uint32]0x06054B50 -or
        [System.BitConverter]::ToUInt16(
            $arrOriginalBytes,
            $intEndOfCentralDirectoryOffset + 10
        ) -ne [uint16]$Specifications.Count) {
        & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'stored-zip-end-record'
    }
    $uintOriginalCentralOffset = [System.BitConverter]::ToUInt32(
        $arrOriginalBytes,
        $intEndOfCentralDirectoryOffset + 16
    )
    $arrCrc32 = New-Object uint32[] $Specifications.Count
    $intOriginalCentralEntryOffset = [int]$uintOriginalCentralOffset
    for ($intEntryIndex = 0; $intEntryIndex -lt $Specifications.Count; $intEntryIndex++) {
        $objSpecification = $Specifications[$intEntryIndex]
        if ($objSpecification.Compression -cne 'NoCompression' -or
            $null -ne $objSpecification.Prefix -or
            [uint64]$objSpecification.Length -gt [uint32]::MaxValue -or
            $intOriginalCentralEntryOffset -gt ($intEndOfCentralDirectoryOffset - 46) -or
            [System.BitConverter]::ToUInt32(
                $arrOriginalBytes,
                $intOriginalCentralEntryOffset
            ) -ne [uint32]0x02014B50) {
            & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'stored-zip-entry'
        }
        $uintNameLength = [System.BitConverter]::ToUInt16(
            $arrOriginalBytes,
            $intOriginalCentralEntryOffset + 28
        )
        $uintExtraLength = [System.BitConverter]::ToUInt16(
            $arrOriginalBytes,
            $intOriginalCentralEntryOffset + 30
        )
        $uintCommentLength = [System.BitConverter]::ToUInt16(
            $arrOriginalBytes,
            $intOriginalCentralEntryOffset + 32
        )
        $arrExpectedNameBytes = [System.Text.Encoding]::UTF8.GetBytes(
            [string]$objSpecification.Name
        )
        $arrOriginalNameBytes = New-Object byte[] ([int]$uintNameLength)
        [System.Array]::Copy(
            $arrOriginalBytes,
            $intOriginalCentralEntryOffset + 46,
            $arrOriginalNameBytes,
            0,
            $arrOriginalNameBytes.Length
        )
        if (-not (& $script:scriptBlockTestByteSequenceEqual `
                -Left $arrOriginalNameBytes `
                -Right $arrExpectedNameBytes) -or
            [System.BitConverter]::ToUInt32(
                $arrOriginalBytes,
                $intOriginalCentralEntryOffset + 24
            ) -ne [uint32]$objSpecification.Length) {
            & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'stored-zip-evidence'
        }
        $arrCrc32[$intEntryIndex] = [System.BitConverter]::ToUInt32(
            $arrOriginalBytes,
            $intOriginalCentralEntryOffset + 16
        )
        $intOriginalCentralEntryOffset += 46 + [int]$uintNameLength +
            [int]$uintExtraLength + [int]$uintCommentLength
    }
    if ($intOriginalCentralEntryOffset -ne $intEndOfCentralDirectoryOffset) {
        & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'stored-zip-cardinality'
    }

    [System.IO.File]::Delete($LiteralPath)
    $objArchiveStream = $null
    $objBinaryWriter = $null
    try {
        $objArchiveStream = New-Object System.IO.FileStream(
            $LiteralPath,
            [System.IO.FileMode]::CreateNew,
            [System.IO.FileAccess]::Write,
            [System.IO.FileShare]::None
        )
        $objBinaryWriter = New-Object System.IO.BinaryWriter(
            $objArchiveStream,
            [System.Text.Encoding]::UTF8,
            $true
        )
        $arrRelativeOffsets = New-Object uint32[] $Specifications.Count
        for ($intEntryIndex = 0; $intEntryIndex -lt $Specifications.Count; $intEntryIndex++) {
            $objSpecification = $Specifications[$intEntryIndex]
            $arrNameBytes = [System.Text.Encoding]::UTF8.GetBytes([string]$objSpecification.Name)
            if ($arrNameBytes.Length -gt [uint16]::MaxValue -or
                $objArchiveStream.Position -gt [uint32]::MaxValue) {
                & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'stored-zip-bounds'
            }
            $arrRelativeOffsets[$intEntryIndex] = [uint32]$objArchiveStream.Position
            $objBinaryWriter.Write([uint32]0x04034B50)
            $objBinaryWriter.Write([uint16]20)
            $objBinaryWriter.Write([uint16]0)
            $objBinaryWriter.Write([uint16]0)
            $objBinaryWriter.Write([uint16]0)
            $objBinaryWriter.Write([uint16]0x2821)
            $objBinaryWriter.Write([uint32]$arrCrc32[$intEntryIndex])
            $objBinaryWriter.Write([uint32]$objSpecification.Length)
            $objBinaryWriter.Write([uint32]$objSpecification.Length)
            $objBinaryWriter.Write([uint16]$arrNameBytes.Length)
            $objBinaryWriter.Write([uint16]0)
            $objBinaryWriter.Write($arrNameBytes)
            & $script:scriptBlockWriteRepeatedBytes `
                -Stream $objArchiveStream `
                -Length ([uint64]$objSpecification.Length) `
                -Value ([byte]$objSpecification.Value) `
                -Prefix $null
        }

        $uintCentralDirectoryOffset = [uint32]$objArchiveStream.Position
        for ($intEntryIndex = 0; $intEntryIndex -lt $Specifications.Count; $intEntryIndex++) {
            $objSpecification = $Specifications[$intEntryIndex]
            $arrNameBytes = [System.Text.Encoding]::UTF8.GetBytes([string]$objSpecification.Name)
            $objBinaryWriter.Write([uint32]0x02014B50)
            $objBinaryWriter.Write([uint16]20)
            $objBinaryWriter.Write([uint16]20)
            $objBinaryWriter.Write([uint16]0)
            $objBinaryWriter.Write([uint16]0)
            $objBinaryWriter.Write([uint16]0)
            $objBinaryWriter.Write([uint16]0x2821)
            $objBinaryWriter.Write([uint32]$arrCrc32[$intEntryIndex])
            $objBinaryWriter.Write([uint32]$objSpecification.Length)
            $objBinaryWriter.Write([uint32]$objSpecification.Length)
            $objBinaryWriter.Write([uint16]$arrNameBytes.Length)
            $objBinaryWriter.Write([uint16]0)
            $objBinaryWriter.Write([uint16]0)
            $objBinaryWriter.Write([uint16]0)
            $objBinaryWriter.Write([uint16]0)
            $objBinaryWriter.Write([uint32]$objSpecification.ExternalAttributes)
            $objBinaryWriter.Write([uint32]$arrRelativeOffsets[$intEntryIndex])
            $objBinaryWriter.Write($arrNameBytes)
        }
        $uintCentralDirectorySize = [uint32](
            $objArchiveStream.Position - [long]$uintCentralDirectoryOffset
        )
        $objBinaryWriter.Write([uint32]0x06054B50)
        $objBinaryWriter.Write([uint16]0)
        $objBinaryWriter.Write([uint16]0)
        $objBinaryWriter.Write([uint16]$Specifications.Count)
        $objBinaryWriter.Write([uint16]$Specifications.Count)
        $objBinaryWriter.Write($uintCentralDirectorySize)
        $objBinaryWriter.Write($uintCentralDirectoryOffset)
        $objBinaryWriter.Write([uint16]0)
    } finally {
        if ($null -ne $objBinaryWriter) {
            $objBinaryWriter.Dispose()
        }
        if ($null -ne $objArchiveStream) {
            $objArchiveStream.Dispose()
        }
    }
}

$script:scriptBlockWriteZipFromSpecifications = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [object[]]$Specifications
    )

    Add-Type -AssemblyName System.IO.Compression -ErrorAction Stop
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction Stop
    } catch {
        if (-not ('System.IO.Compression.ZipArchive' -as [type])) {
            throw
        }
    }
    $objArchiveStream = New-Object System.IO.FileStream(
        $LiteralPath,
        [System.IO.FileMode]::CreateNew,
        [System.IO.FileAccess]::Write,
        [System.IO.FileShare]::None
    )
    try {
        $objArchive = New-Object System.IO.Compression.ZipArchive(
            $objArchiveStream,
            [System.IO.Compression.ZipArchiveMode]::Create,
            $true
        )
        try {
            foreach ($objSpecification in $Specifications) {
                $objCompression = if ($objSpecification.Compression -ceq 'NoCompression') {
                    [System.IO.Compression.CompressionLevel]::NoCompression
                } else {
                    [System.IO.Compression.CompressionLevel]::Optimal
                }
                $objEntry = $objArchive.CreateEntry(
                    $objSpecification.Name,
                    $objCompression
                )
                $objEntry.LastWriteTime = New-Object System.DateTimeOffset(
                    2000,
                    1,
                    1,
                    0,
                    0,
                    0,
                    [System.TimeSpan]::Zero
                )
                $objEntry.ExternalAttributes = $objSpecification.ExternalAttributes
                $objEntryStream = $objEntry.Open()
                try {
                    & $script:scriptBlockWriteRepeatedBytes `
                        -Stream $objEntryStream `
                        -Length ([uint64]$objSpecification.Length) `
                        -Value ([byte]$objSpecification.Value) `
                        -Prefix $objSpecification.Prefix
                } finally {
                    $objEntryStream.Dispose()
                }
            }
        } finally {
            $objArchive.Dispose()
        }
    } finally {
        $objArchiveStream.Dispose()
    }
    & $script:scriptBlockNormalizeZipFixtureHeaders `
        -LiteralPath $LiteralPath `
        -ExpectedEntryCount ([uint16]$Specifications.Count)
}

$script:scriptBlockSetResourceLengths = {
    param (
        [Parameter(Mandatory = $true)]
        [object[]]$Specifications,

        [Parameter(Mandatory = $true)]
        [uint64[]]$Lengths,

        [Parameter(Mandatory = $true)]
        [string]$Compression
    )

    if ($Specifications.Count -ne $Lengths.Count) {
        & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'resource-cardinality'
    }
    for ($intIndex = 0; $intIndex -lt $Specifications.Count; $intIndex++) {
        $Specifications[$intIndex].Length = [uint64]$Lengths[$intIndex]
        $Specifications[$intIndex].Prefix = $null
        $Specifications[$intIndex].Compression = $Compression
    }
    return [object[]]$Specifications
}

$script:scriptBlockRemoveLastCentralDirectoryName = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath
    )

    if (-not [System.BitConverter]::IsLittleEndian) {
        & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'zip-endianness'
    }
    $arrBytes = [System.IO.File]::ReadAllBytes($LiteralPath)
    $listCentralOffset = New-Object 'System.Collections.Generic.List[int]'
    $intEndOfCentralDirectoryOffset = -1
    for ($intIndex = 0; $intIndex -le ($arrBytes.Length - 4); $intIndex++) {
        $uintSignature = [System.BitConverter]::ToUInt32($arrBytes, $intIndex)
        if ($uintSignature -eq [uint32]0x02014B50) {
            $listCentralOffset.Add($intIndex)
        } elseif ($uintSignature -eq [uint32]0x06054B50) {
            $intEndOfCentralDirectoryOffset = $intIndex
        }
    }
    if ($listCentralOffset.Count -ne 4 -or $intEndOfCentralDirectoryOffset -lt 0) {
        & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'zip-central-shape'
    }
    $intCentralOffset = $listCentralOffset[$listCentralOffset.Count - 1]
    $uintNameLength = [System.BitConverter]::ToUInt16($arrBytes, $intCentralOffset + 28)
    $uintExtraLength = [System.BitConverter]::ToUInt16($arrBytes, $intCentralOffset + 30)
    $uintCommentLength = [System.BitConverter]::ToUInt16($arrBytes, $intCentralOffset + 32)
    if ($uintNameLength -eq 0 -or $uintExtraLength -ne 0 -or $uintCommentLength -ne 0) {
        & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'zip-central-name'
    }
    $intNameOffset = $intCentralOffset + 46
    $intAfterNameOffset = $intNameOffset + [int]$uintNameLength
    $uintCentralSize = [System.BitConverter]::ToUInt32(
        $arrBytes,
        $intEndOfCentralDirectoryOffset + 12
    )
    [System.Array]::Copy(
        [System.BitConverter]::GetBytes([uint16]0),
        0,
        $arrBytes,
        $intCentralOffset + 28,
        2
    )
    $arrRewritten = New-Object byte[] ($arrBytes.Length - [int]$uintNameLength)
    [System.Array]::Copy($arrBytes, 0, $arrRewritten, 0, $intNameOffset)
    [System.Array]::Copy(
        $arrBytes,
        $intAfterNameOffset,
        $arrRewritten,
        $intNameOffset,
        $arrBytes.Length - $intAfterNameOffset
    )
    $intNewEndOfCentralDirectoryOffset = $intEndOfCentralDirectoryOffset - [int]$uintNameLength
    [System.Array]::Copy(
        [System.BitConverter]::GetBytes([uint32]($uintCentralSize - $uintNameLength)),
        0,
        $arrRewritten,
        $intNewEndOfCentralDirectoryOffset + 12,
        4
    )
    [System.IO.File]::WriteAllBytes($LiteralPath, $arrRewritten)
}

$script:scriptBlockSetZipCommentLength = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [uint64]$TargetLength
    )

    if (-not [System.BitConverter]::IsLittleEndian) {
        & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'zip-endianness'
    }
    $arrBytes = [System.IO.File]::ReadAllBytes($LiteralPath)
    if ($arrBytes.Length -lt 22 -or
        [System.BitConverter]::ToUInt32($arrBytes, $arrBytes.Length - 22) -ne
            [uint32]0x06054B50 -or
        [System.BitConverter]::ToUInt16($arrBytes, $arrBytes.Length - 2) -ne 0 -or
        $TargetLength -lt [uint64]$arrBytes.Length) {
        & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'zip-comment-shape'
    }
    $uintGap = [uint64]($TargetLength - [uint64]$arrBytes.Length)
    if ($uintGap -gt [uint16]::MaxValue -or $TargetLength -gt [int]::MaxValue) {
        & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'zip-comment-length'
    }
    [System.Array]::Copy(
        [System.BitConverter]::GetBytes([uint16]$uintGap),
        0,
        $arrBytes,
        $arrBytes.Length - 2,
        2
    )
    $arrRewritten = New-Object byte[] ([int]$TargetLength)
    [System.Array]::Copy($arrBytes, 0, $arrRewritten, 0, $arrBytes.Length)
    for ($intIndex = $arrBytes.Length; $intIndex -lt $arrRewritten.Length; $intIndex++) {
        $arrRewritten[$intIndex] = [byte]0x43
    }
    [System.IO.File]::WriteAllBytes($LiteralPath, $arrRewritten)
}

$script:scriptBlockNewZipFixture = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [string]$SemanticCase
    )

    $arrSpecifications = [object[]]@(& $script:scriptBlockGetDefaultEntrySpecifications)
    switch -Exact ($SemanticCase) {
        'archive.attributes.linklike-ignored' {
            foreach ($objEntrySpecification in $arrSpecifications) {
                $objEntrySpecification.ExternalAttributes = [int]0xA1FF0000
            }
        }
        'manifest.entry.missing' {
            $arrSpecifications = [object[]]@($arrSpecifications | Select-Object -First 3)
        }
        'manifest.entry.extra' {
            $arrSpecifications += & $script:scriptBlockNewEntrySpecification `
                -Name 'extra.md' -Length ([uint64]2) -Value ([byte]0x0A) `
                -Prefix ([byte[]](0x78, 0x0A)) -Compression 'Optimal'
        }
        'manifest.entry.duplicate-exact' {
            $arrSpecifications[3].Name = $arrSpecifications[0].Name
        }
        'manifest.entry.duplicate-case' {
            $arrSpecifications[3].Name = $arrSpecifications[0].Name.ToUpperInvariant()
        }
        'manifest.path.nested-forward' {
            $arrSpecifications[3].Name = 'nested/STYLE_GUIDE_FULL.md'
        }
        'manifest.path.nested-back' {
            $arrSpecifications[3].Name = 'nested\STYLE_GUIDE_FULL.md'
        }
        'manifest.path.traversal-forward' {
            $arrSpecifications[3].Name = '../STYLE_GUIDE_FULL.md'
        }
        'manifest.path.traversal-back' {
            $arrSpecifications[3].Name = '..\STYLE_GUIDE_FULL.md'
        }
        'manifest.path.leading-forward' {
            $arrSpecifications[3].Name = '/STYLE_GUIDE_FULL.md'
        }
        'manifest.path.leading-back' {
            $arrSpecifications[3].Name = '\STYLE_GUIDE_FULL.md'
        }
        'manifest.path.drive-qualified' {
            $arrSpecifications[3].Name = 'C:\STYLE_GUIDE_FULL.md'
        }
        'manifest.entry.directory' {
            $arrSpecifications[3].Name = 'STYLE_GUIDE_FULL.md/'
            $arrSpecifications[3].Length = [uint64]0
            $arrSpecifications[3].Prefix = $null
        }
        'manifest.entry.file-directory-collision' {
            $arrSpecifications[2].Name = 'STYLE_GUIDE_FULL.md/'
            $arrSpecifications[2].Length = [uint64]0
            $arrSpecifications[2].Prefix = $null
        }
        'manifest.entry.raw-empty-name' {
            $arrSpecifications[3].Name = 'x'
        }
        'output.bytes.bom' {
            $arrSpecifications[0].Length = [uint64]5
            $arrSpecifications[0].Prefix = [byte[]](0xEF, 0xBB, 0xBF, 0x78, 0x0A)
        }
        'output.bytes.cr' {
            $arrSpecifications[0].Length = [uint64]3
            $arrSpecifications[0].Prefix = [byte[]](0x78, 0x0D, 0x0A)
        }
        'resource.entry.below' {
            $arrSpecifications = & $script:scriptBlockSetResourceLengths -Specifications $arrSpecifications `
                -Lengths ([uint64[]]@((8MB - 1), 0, 0, 0)) -Compression 'Optimal'
        }
        'resource.entry.at' {
            $arrSpecifications = & $script:scriptBlockSetResourceLengths -Specifications $arrSpecifications `
                -Lengths ([uint64[]]@((8MB), 0, 0, 0)) -Compression 'Optimal'
        }
        'resource.entry.above' {
            $arrSpecifications = & $script:scriptBlockSetResourceLengths -Specifications $arrSpecifications `
                -Lengths ([uint64[]]@((8MB + 1), 0, 0, 0)) -Compression 'Optimal'
        }
        'resource.total.below' {
            $arrSpecifications = & $script:scriptBlockSetResourceLengths -Specifications $arrSpecifications `
                -Lengths ([uint64[]]@((8MB), (8MB), (8MB), (8MB - 1))) -Compression 'Optimal'
        }
        'resource.total.at' {
            $arrSpecifications = & $script:scriptBlockSetResourceLengths -Specifications $arrSpecifications `
                -Lengths ([uint64[]]@((8MB), (8MB), (8MB), (8MB))) -Compression 'Optimal'
        }
        'resource.total.above' {
            $arrSpecifications = & $script:scriptBlockSetResourceLengths -Specifications $arrSpecifications `
                -Lengths ([uint64[]]@((8MB), (8MB), (8MB), (8MB + 1))) -Compression 'Optimal'
        }
        'resource.archive.below' {
            $arrSpecifications = & $script:scriptBlockSetResourceLengths `
                -Specifications $arrSpecifications `
                -Lengths ([uint64[]]@(
                    (8MB - 16KB),
                    (8MB - 16KB),
                    (8MB - 16KB),
                    (8MB - 16KB)
                )) `
                -Compression 'NoCompression'
        }
        'resource.archive.at' {
            $arrSpecifications = & $script:scriptBlockSetResourceLengths `
                -Specifications $arrSpecifications `
                -Lengths ([uint64[]]@(
                    (8MB - 16KB),
                    (8MB - 16KB),
                    (8MB - 16KB),
                    (8MB - 16KB)
                )) `
                -Compression 'NoCompression'
        }
        default {}
    }

    & $script:scriptBlockWriteZipFromSpecifications `
        -LiteralPath $LiteralPath `
        -Specifications $arrSpecifications
    if ($SemanticCase -in @('resource.archive.below', 'resource.archive.at')) {
        & $script:scriptBlockRewriteZipFixtureAsStored `
            -LiteralPath $LiteralPath `
            -Specifications $arrSpecifications
    }

    if ($SemanticCase -ceq 'manifest.entry.raw-empty-name') {
        & $script:scriptBlockRemoveLastCentralDirectoryName -LiteralPath $LiteralPath
    }
    if ($SemanticCase -ceq 'resource.archive.below') {
        & $script:scriptBlockSetZipCommentLength `
            -LiteralPath $LiteralPath `
            -TargetLength ([uint64](32MB - 1))
    }
    if ($SemanticCase -ceq 'resource.archive.at') {
        & $script:scriptBlockSetZipCommentLength `
            -LiteralPath $LiteralPath `
            -TargetLength ([uint64](32MB))
    }

    if ($SemanticCase -ceq 'archive.zip.truncated') {
        $objStream = New-Object System.IO.FileStream(
            $LiteralPath,
            [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::Write,
            [System.IO.FileShare]::None
        )
        try {
            if ($objStream.Length -lt 8) {
                & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'truncate-length'
            }
            $objStream.SetLength($objStream.Length - 7)
        } finally {
            $objStream.Dispose()
        }
    }
    if ($SemanticCase -ceq 'resource.archive.above') {
        $objStream = New-Object System.IO.FileStream(
            $LiteralPath,
            [System.IO.FileMode]::Open,
            [System.IO.FileAccess]::Write,
            [System.IO.FileShare]::None
        )
        try {
            $objStream.SetLength([long](32MB + 1))
        } finally {
            $objStream.Dispose()
        }
    }
    if ($SemanticCase -ceq 'archive.trailer.decoy' -or
        $SemanticCase -ceq 'archive.trailer.zip64-gate') {
        # Built by the same function the trailer-agreement assertion uses, so the
        # two cannot drift. The oversized directory is small here: the case only
        # needs the archive refused, while the assertion needs it to be a real
        # amplification and asks for a much larger one.
        $strBypassVariant = if ($SemanticCase -ceq 'archive.trailer.decoy') {
            'decoy'
        } else {
            'zip64'
        }
        $arrBypassByte = & $script:scriptBlockNewTrailerBypassArchiveByte `
            -Variant $strBypassVariant -FatEntryCount 8
        [System.IO.File]::WriteAllBytes($LiteralPath, $arrBypassByte)
    }
    return & $script:scriptBlockGetFileEvidence -LiteralPath $LiteralPath
}

$script:scriptBlockTestLinkSemanticCase = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$SemanticCase
    )

    return $SemanticCase -in @(
        'environment.checkout.link-component',
        'environment.trusted.link-component',
        'candidate.preexisting.live-link',
        'candidate.preexisting.dangling-link',
        'helper.cleanup.link-substitution',
        'context.cleanup.link-substitution',
        'download.entry.link',
        'script.helper.link',
        'script.context.link'
    )
}

$script:scriptBlockNewSymbolicLink = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LinkPath,

        [Parameter(Mandatory = $true)]
        [string]$TargetPath,

        [Parameter(Mandatory = $true)]
        [bool]$Directory
    )

    try {
        $boolTargetIsDirectory = [System.IO.Directory]::Exists($TargetPath)
        $boolTargetIsFile = [System.IO.File]::Exists($TargetPath)
        if (($boolTargetIsDirectory -or $boolTargetIsFile) -and
            $boolTargetIsDirectory -ne $Directory) {
            throw 'link-target-type'
        }
        if ($script:boolCandidateIsWindows) {
            $strItemType = if ($Directory -and $boolTargetIsDirectory) {
                'Junction'
            } else {
                'SymbolicLink'
            }
            $null = New-Item -ItemType $strItemType -Path $LinkPath -Target $TargetPath `
                -ErrorAction Stop
        } else {
            # A bare command name resolves alias, then function, then cmdlet,
            # then application, so a defined ln in the invoking scope binds
            # ahead of the utility. Such a command never sets $LASTEXITCODE,
            # leaving a stale zero that reads as success, and the reparse-point
            # check below then reports the link primitive as unavailable --
            # which silently drops every required link case on a host that
            # supports them. Resolve the application and invoke it by path.
            $strLinkPath = [string](& $script:scriptBlockResolveHarnessNativePath `
                -CandidatePath ([string[]]@('/usr/bin/ln', '/bin/ln', '/usr/local/bin/ln')))
            if ($strLinkPath.Length -eq 0) {
                throw 'link-utility'
            }
            $arrOutput = @(& $strLinkPath '-s' '--' $TargetPath $LinkPath 2>$null)
            if ($LASTEXITCODE -ne 0 -or $arrOutput.Count -ne 0) {
                throw 'link'
            }
        }
        $objAttributes = [System.IO.File]::GetAttributes($LinkPath)
        if (($objAttributes -band [System.IO.FileAttributes]::ReparsePoint) -eq 0) {
            throw 'link-attribute'
        }
        return $true
    } catch {
        return $false
    }
}

$script:scriptBlockRemoveTestTree = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [string]$ApprovedParent
    )

    $strFullPath = [System.IO.Path]::GetFullPath($LiteralPath)
    $strParent = [System.IO.Path]::GetFullPath($ApprovedParent).TrimEnd(
        [System.IO.Path]::DirectorySeparatorChar,
        [System.IO.Path]::AltDirectorySeparatorChar
    ) + [System.IO.Path]::DirectorySeparatorChar
    if (-not $strFullPath.StartsWith($strParent, $script:objCandidatePathComparison)) {
        & $script:scriptBlockStopHarness -Code 'orchestration-failed' -Detail 'teardown-containment'
    }
    if (-not [System.IO.Directory]::Exists($strFullPath) -and
        -not [System.IO.File]::Exists($strFullPath)) {
        return
    }

    $objRootAttributes = [System.IO.File]::GetAttributes($strFullPath)
    if (($objRootAttributes -band [System.IO.FileAttributes]::Directory) -eq 0 -or
        ($objRootAttributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        & $script:scriptBlockStopHarness -Code 'orchestration-failed' -Detail 'teardown-root-type'
    }
    $stackPendingDirectory = New-Object 'System.Collections.Generic.Stack[string]'
    $listDirectory = New-Object 'System.Collections.Generic.List[string]'
    $stackPendingDirectory.Push($strFullPath)
    while ($stackPendingDirectory.Count -gt 0) {
        $strDirectory = $stackPendingDirectory.Pop()
        $listDirectory.Add($strDirectory)
        foreach ($strEntry in [System.IO.Directory]::EnumerateFileSystemEntries($strDirectory)) {
            $objAttributes = [System.IO.File]::GetAttributes($strEntry)
            $boolDirectory = ($objAttributes -band [System.IO.FileAttributes]::Directory) -ne 0
            $boolReparse = ($objAttributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
            if ($boolReparse) {
                if ($boolDirectory) {
                    [System.IO.Directory]::Delete($strEntry, $false)
                } else {
                    [System.IO.File]::SetAttributes($strEntry, [System.IO.FileAttributes]::Normal)
                    [System.IO.File]::Delete($strEntry)
                }
            } elseif ($boolDirectory) {
                $stackPendingDirectory.Push($strEntry)
            } else {
                [System.IO.File]::SetAttributes($strEntry, [System.IO.FileAttributes]::Normal)
                [System.IO.File]::Delete($strEntry)
            }
        }
    }
    for ($intIndex = $listDirectory.Count - 1; $intIndex -ge 0; $intIndex--) {
        [System.IO.File]::SetAttributes(
            $listDirectory[$intIndex],
            [System.IO.FileAttributes]::Directory
        )
        [System.IO.Directory]::Delete($listDirectory[$intIndex], $false)
    }
}

$script:scriptBlockGetProductionFailureField = {
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

$script:scriptBlockNewObservation = {
    return [ordered]@{
        Result = 'rejection'
        Status = 'failed'
        Phase = 'none'
        Subreason = 'fixture'
        DiagnosticCode = 'orchestration-failed'
        PreCleanupState = 'NotCreated'
        CleanupSequence = 'none'
        CandidateFinalState = 'NotCreated'
        ContextFinalState = 'NotCreated'
        FilesystemCallCount = [uint32]0
        FixtureLength = [uint64]0
        FixtureSha256 = $script:strCandidateEmptySha256
        InvocationId = [System.Guid]::NewGuid()
        SentinelState = 'intact'
        SourceState = 'unchanged'
        AuthorizedSkip = $false
        SkipCode = $null
    }
}

$script:scriptBlockNewCaseResult = {
    param (
        [Parameter(Mandatory = $true)]
        [object]$Case,

        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Observation,

        [Parameter(Mandatory = $true)]
        [string]$OperatingSystem,

        [Parameter(Mandatory = $true)]
        [string]$PowerShellEdition,

        [Parameter(Mandatory = $true)]
        [System.Version]$PowerShellVersion
    )

    $boolMatched = $Case.ExpectedResult -ceq $Observation.Result -and
        $Case.ExpectedStatus -ceq $Observation.Status -and
        $Case.ExpectedPhase -ceq $Observation.Phase -and
        $Case.ExpectedSubreason -ceq $Observation.Subreason -and
        $Case.ExpectedDiagnosticCode -ceq $Observation.DiagnosticCode -and
        $Case.ExpectedPreCleanupState -ceq $Observation.PreCleanupState -and
        $Case.ExpectedCleanupSequence -ceq $Observation.CleanupSequence -and
        $Case.ExpectedCandidateFinalState -ceq $Observation.CandidateFinalState -and
        $Case.ExpectedContextFinalState -ceq $Observation.ContextFinalState -and
        [uint32]$Case.ExpectedFilesystemCallCount -eq $Observation.FilesystemCallCount -and
        $Case.ExpectedSentinelState -ceq $Observation.SentinelState -and
        $Case.ExpectedSourceState -ceq $Observation.SourceState
    if ($null -ne $Case.FixtureLength) {
        $boolMatched = $boolMatched -and
            [uint64]$Case.FixtureLength -eq $Observation.FixtureLength
    }
    if ($null -ne $Case.FixtureSha256) {
        $boolMatched = $boolMatched -and
            $Case.FixtureSha256 -ceq $Observation.FixtureSha256
    }

    $boolOppositePlatformSkip = $Observation.SkipCode -ceq 'skip-opposite-platform' -and
        $Case.Applicability -cne 'All' -and
        $Case.Applicability -cne $OperatingSystem
    $boolPrimitiveSkip = $Observation.SkipCode -ceq 'skip-link-primitive-unavailable' -and
        $Case.PrimitiveProbeRule -ceq 'required-link'
    $boolSkipAuthorized = $Observation.AuthorizedSkip -and
        ($boolOppositePlatformSkip -or $boolPrimitiveSkip)
    $strVerdict = if ($Observation.AuthorizedSkip -and -not $boolSkipAuthorized) {
        'fail'
    } elseif ($boolSkipAuthorized) {
        'skip'
    } elseif ($boolMatched) {
        'pass'
    } else {
        'fail'
    }
    $strHarnessCode = if ($Observation.AuthorizedSkip -and -not $boolSkipAuthorized) {
        'orchestration-failed'
    } elseif ($boolSkipAuthorized) {
        [string]$Observation.SkipCode
    } elseif ($boolMatched) {
        'None'
    } else {
        'orchestration-failed'
    }
    $strActualResult = if ($Observation.AuthorizedSkip) { 'rejection' } else { $Observation.Result }
    $strActualStatus = if ($Observation.AuthorizedSkip) { 'failed' } else { $Observation.Status }

    $objResult = [pscustomobject][ordered]@{
        SchemaVersion = [uint32]1
        CaseId = [string]$Case.CaseId
        SemanticCase = [string]$Case.SemanticCase
        SemanticVariant = $Case.SemanticVariant
        OperatingSystem = [string]$OperatingSystem
        PowerShellEdition = [string]$PowerShellEdition
        PowerShellVersion = $PowerShellVersion
        ExpectedResult = [string]$Case.ExpectedResult
        ActualResult = [string]$strActualResult
        ExpectedStatus = [string]$Case.ExpectedStatus
        ActualStatus = [string]$strActualStatus
        ExpectedPhase = [string]$Case.ExpectedPhase
        ActualPhase = [string]$Observation.Phase
        ExpectedDiagnosticCode = [string]$Case.ExpectedDiagnosticCode
        ActualDiagnosticCode = [string]$Observation.DiagnosticCode
        ExpectedPreCleanupState = [string]$Case.ExpectedPreCleanupState
        ActualPreCleanupState = [string]$Observation.PreCleanupState
        ExpectedCleanupSequence = [string]$Case.ExpectedCleanupSequence
        ActualCleanupSequence = [string]$Observation.CleanupSequence
        ExpectedCandidateFinalState = [string]$Case.ExpectedCandidateFinalState
        ActualCandidateFinalState = [string]$Observation.CandidateFinalState
        ExpectedContextFinalState = [string]$Case.ExpectedContextFinalState
        ActualContextFinalState = [string]$Observation.ContextFinalState
        FixtureLength = [uint64]$Observation.FixtureLength
        FixtureSha256 = [string]$Observation.FixtureSha256
        InvocationId = [System.Guid]$Observation.InvocationId
        HarnessVerdict = [string]$strVerdict
        HarnessDiagnosticCode = [string]$strHarnessCode
        FilesystemCallCount = [uint32]$Observation.FilesystemCallCount
    }
    $objResult.PSObject.TypeNames.Insert(0, $script:strCandidateResultTypeName)
    return $objResult
}

$script:scriptBlockAssertUnauthorizedSkipsRejected = {
    param (
        [Parameter(Mandatory = $true)]
        [object]$Catalog,

        [Parameter(Mandatory = $true)]
        [string]$OperatingSystem,

        [Parameter(Mandatory = $true)]
        [string]$PowerShellEdition,

        [Parameter(Mandatory = $true)]
        [System.Version]$PowerShellVersion
    )

    $objCase = $Catalog.Cases[0]
    foreach ($strSkipCode in @(
        'unexpected-skip',
        'skip-opposite-platform',
        'skip-link-primitive-unavailable'
    )) {
        $hashtableObservation = & $script:scriptBlockNewObservation
        $hashtableObservation.AuthorizedSkip = $true
        $hashtableObservation.SkipCode = $strSkipCode
        $objResult = & $script:scriptBlockNewCaseResult `
            -Case $objCase `
            -Observation $hashtableObservation `
            -OperatingSystem $OperatingSystem `
            -PowerShellEdition $PowerShellEdition `
            -PowerShellVersion $PowerShellVersion
        if ($objResult.HarnessVerdict -cne 'fail' -or
            $objResult.HarnessDiagnosticCode -cne 'orchestration-failed') {
            & $script:scriptBlockStopHarness `
                -Code 'orchestration-failed' `
                -Detail 'unauthorized-skip-accepted'
        }
    }
}

$script:scriptBlockConvertToCanonicalCaseJson = {
    param (
        [Parameter(Mandatory = $true)]
        [object]$Result
    )

    $hashtableProjection = [ordered]@{
        SchemaVersion = [uint32]$Result.SchemaVersion
        CaseId = [string]$Result.CaseId
        SemanticCase = [string]$Result.SemanticCase
        SemanticVariant = $Result.SemanticVariant
        OperatingSystem = [string]$Result.OperatingSystem
        PowerShellEdition = [string]$Result.PowerShellEdition
        PowerShellVersion = $Result.PowerShellVersion.ToString()
        ExpectedResult = [string]$Result.ExpectedResult
        ActualResult = [string]$Result.ActualResult
        ExpectedStatus = [string]$Result.ExpectedStatus
        ActualStatus = [string]$Result.ActualStatus
        ExpectedPhase = [string]$Result.ExpectedPhase
        ActualPhase = [string]$Result.ActualPhase
        ExpectedDiagnosticCode = [string]$Result.ExpectedDiagnosticCode
        ActualDiagnosticCode = [string]$Result.ActualDiagnosticCode
        ExpectedPreCleanupState = [string]$Result.ExpectedPreCleanupState
        ActualPreCleanupState = [string]$Result.ActualPreCleanupState
        ExpectedCleanupSequence = [string]$Result.ExpectedCleanupSequence
        ActualCleanupSequence = [string]$Result.ActualCleanupSequence
        ExpectedCandidateFinalState = [string]$Result.ExpectedCandidateFinalState
        ActualCandidateFinalState = [string]$Result.ActualCandidateFinalState
        ExpectedContextFinalState = [string]$Result.ExpectedContextFinalState
        ActualContextFinalState = [string]$Result.ActualContextFinalState
        FixtureLength = [uint64]$Result.FixtureLength
        FixtureSha256 = [string]$Result.FixtureSha256
        InvocationId = $Result.InvocationId.ToString('D')
        HarnessVerdict = [string]$Result.HarnessVerdict
        HarnessDiagnosticCode = [string]$Result.HarnessDiagnosticCode
        FilesystemCallCount = [uint32]$Result.FilesystemCallCount
    }
    return ($hashtableProjection | ConvertTo-Json -Compress)
}

# #146 permits a bounded run envelope carrying UTC start/end, tool and catalog
# hashes, and the runtime-observed classification of any adversarial fixture
# whose hostility depends on the .NET version. It is a separate object, so
# per-case equality is untouched: every consumer selects case results by the
# presence of CaseId, which this object deliberately does not carry.
#
# The .NET version is recorded because without it the classification says only
# "on some runtime the decoy was refused", which is not evidence of anything.
# It is part of the observation, not an addition to it.
$script:scriptBlockConvertToCanonicalEnvelopeJson = {
    param (
        [Parameter(Mandatory = $true)]
        [object]$HelperEvidence,

        [Parameter(Mandatory = $true)]
        [object]$ContextEvidence,

        [Parameter(Mandatory = $true)]
        [object]$CatalogEvidence
    )

    $hashtableEnvelope = [ordered]@{
        Schema = 'PSStyleGuide.CandidateRunEnvelope.v1'
        SchemaVersion = [uint32]1
        StartedUtc = [string]$script:strCandidateRunStartedUtc
        CompletedUtc = [System.DateTime]::UtcNow.ToString(
            'yyyy-MM-ddTHH:mm:ss.fffffffZ',
            [System.Globalization.CultureInfo]::InvariantCulture)
        HarnessVersion = $script:versionCandidateHarness.ToString()
        HelperVersion = [string]$script:strCandidateExpectedHelperVersion
        ContextVersion = [string]$script:strCandidateExpectedContextVersion
        CatalogVersion = [string]$script:strCandidateCatalogVersion
        HelperSha256 = [string]$HelperEvidence.Sha256
        ContextSha256 = [string]$ContextEvidence.Sha256
        CatalogSha256 = [string]$CatalogEvidence.Sha256
        RuntimeVersion = [System.Environment]::Version.ToString()
        AdversarialFixtureClassification = @($script:arrCandidateFixtureClassification)
    }
    return ($hashtableEnvelope | ConvertTo-Json -Depth 4 -Compress)
}

$script:scriptBlockNewCaseFixtureLayout = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RunRoot,

        [Parameter(Mandatory = $true)]
        [string]$CaseId
    )

    $strLeaf = $CaseId.ToLowerInvariant() + '-' +
        [System.Guid]::NewGuid().ToString('N').Substring(0, 8)
    $strCaseRoot = [System.IO.Path]::GetFullPath(
        [System.IO.Path]::Combine($RunRoot, $strLeaf)
    )
    $strCheckout = [System.IO.Path]::Combine($strCaseRoot, 'checkout')
    $strTrusted = [System.IO.Path]::Combine($strCaseRoot, 'trusted')
    $strSentinelDirectory = [System.IO.Path]::Combine($strCaseRoot, 'sentinel')
    $strSentinelFile = [System.IO.Path]::Combine($strSentinelDirectory, 'sentinel.bin')
    [void][System.IO.Directory]::CreateDirectory($strCheckout)
    [void][System.IO.Directory]::CreateDirectory($strTrusted)
    [void][System.IO.Directory]::CreateDirectory($strSentinelDirectory)
    [System.IO.File]::WriteAllBytes(
        $strSentinelFile,
        [byte[]](0x50, 0x31, 0x41, 0x0A)
    )
    return [ordered]@{
        CaseRoot = $strCaseRoot
        Checkout = $strCheckout
        Trusted = $strTrusted
        SentinelDirectory = $strSentinelDirectory
        SentinelFile = $strSentinelFile
        SentinelSha256 = (& $script:scriptBlockGetFileEvidence -LiteralPath $strSentinelFile).Sha256
    }
}

$script:scriptBlockTestSentinelIntact = {
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Layout
    )

    try {
        $objEvidence = & $script:scriptBlockGetFileEvidence -LiteralPath $Layout.SentinelFile
        return $objEvidence.Sha256 -ceq $Layout.SentinelSha256 -and
            $objEvidence.Length -eq [uint64]4
    } catch {
        return $false
    }
}

$script:scriptBlockAddTestDownloadRecord = {
    param (
        [Parameter(Mandatory = $true)]
        [object]$Context,

        [Parameter(Mandatory = $true)]
        [string]$LiteralPath,

        [Parameter(Mandatory = $true)]
        [uint64]$Length,

        [Parameter(Mandatory = $true)]
        [string]$Sha256
    )

    $objRecord = [pscustomobject][ordered]@{
        SchemaVersion = [uint32]1
        Sequence = [uint32]$Context.NextSequence
        Kind = [string]'DownloadFile'
        Path = [string]$LiteralPath
        ParentPath = [string]$Context.DownloadDirectoryPath
        LeafName = [string][System.IO.Path]::GetFileName($LiteralPath)
        ExpectedEntryType = [string]'File'
        CreationPhase = [string]'download'
        EntryState = [string]'Created'
        ContentLength = [uint64]$Length
        ContentSha256 = [string]$Sha256
    }
    $objRecord.PSObject.TypeNames.Insert(
        0,
        'PSStyleGuide.CandidateOwnershipRecord.v1'
    )
    $arrJournal = New-Object object[] ($Context.OwnershipJournal.Count + 1)
    [System.Array]::Copy(
        $Context.OwnershipJournal,
        0,
        $arrJournal,
        0,
        $Context.OwnershipJournal.Count
    )
    $arrJournal[$arrJournal.Length - 1] = $objRecord
    $Context.OwnershipJournal = [object[]]$arrJournal
    $Context.NextSequence = [uint32]($Context.NextSequence + 1)
}

$script:scriptBlockInvokeExpansionFixture = {
    param (
        [Parameter(Mandatory = $true)]
        [object]$Case,

        [Parameter(Mandatory = $true)]
        [string]$RunRoot,

        [Parameter(Mandatory = $true)]
        [string]$HelperLiteralPath
    )

    $objObservation = & $script:scriptBlockNewObservation
    $hashtableLayout = & $script:scriptBlockNewCaseFixtureLayout -RunRoot $RunRoot -CaseId $Case.CaseId
    $objContext = $null
    $objHeldStream = $null
    $boolFixtureLinkCreated = $true
    try {
        $strSemantic = [string]$Case.SemanticCase

        if ($strSemantic -ceq 'environment.trusted.nonfilesystem-provider') {
            try {
                # PSVersionTable exists on both editions, so this path
                # resolves and reaches the provider comparison. The previous
                # fixture named a variable that does not exist, so resolution
                # threw first and the non-filesystem-provider rejection this
                # case is named for was never exercised.
                [void](New-StyleGuideCandidateInvocationContext `
                    -TrustedTemporaryRoot 'Variable::PSVersionTable')
            } catch {
                # The fallback converted an absent diagnostic into the expected
                # one, and phase and subreason were assigned unconditionally, so
                # any unrelated creation failure satisfied this case even with
                # the production provider check removed. Require the structured
                # rejection instead. Creation wraps its failure, so the category
                # and composite shape are what is readable here.
                $strObservedCode = & $script:scriptBlockGetProductionFailureField `
                    -ErrorRecord $_ `
                    -Key 'PSStyleGuideDiagnosticCode' `
                    -Fallback 'none'
                if ($strObservedCode -cne 'root-invalid' -or
                    $_.Exception.Message.IndexOf(
                        'PSStyleGuide.ContextCreate.v1|category=root-invalid|cleanup=not-required',
                        [System.StringComparison]::Ordinal) -lt 0) {
                    & $script:scriptBlockStopHarness `
                        -Code 'fixture-failed' -Detail 'provider-evidence'
                }
                $objObservation.Phase = 'root'
                $objObservation.Subreason = 'provider'
                $objObservation.DiagnosticCode = 'root-invalid'
            }
            return $objObservation
        }
        if ($strSemantic -ceq 'environment.trusted.wrong-type') {
            $strWrongType = [System.IO.Path]::Combine($hashtableLayout.CaseRoot, 'trusted-file')
            [System.IO.File]::WriteAllBytes($strWrongType, [byte[]](0x78))
            try {
                [void](New-StyleGuideCandidateInvocationContext -TrustedTemporaryRoot $strWrongType)
            } catch {
                # Any exception from context creation reached this catch and the
                # expected phase, subreason, and diagnostic were then recorded
                # unconditionally, so the case passed even when the production
                # rejection under test never ran. Require the structured
                # diagnostic the production check actually emits instead. The
                # creation failure is wrapped, so the inner reason is not
                # readable here; the category and composite shape are, and an
                # unrelated failure carries neither.
                $strObservedCode = & $script:scriptBlockGetProductionFailureField `
                    -ErrorRecord $_ `
                    -Key 'PSStyleGuideDiagnosticCode' `
                    -Fallback 'none'
                if ($strObservedCode -cne 'root-invalid' -or
                    $_.Exception.Message.IndexOf(
                        'PSStyleGuide.ContextCreate.v1|category=root-invalid|cleanup=not-required',
                        [System.StringComparison]::Ordinal) -lt 0) {
                    & $script:scriptBlockStopHarness `
                        -Code 'fixture-failed' -Detail 'wrong-type-evidence'
                }
                $objObservation.Phase = 'root'
                $objObservation.Subreason = 'nonordinary-directory'
                $objObservation.DiagnosticCode = 'root-invalid'
            }
            return $objObservation
        }
        if ($strSemantic -ceq 'environment.trusted.link-component') {
            $strTarget = [System.IO.Path]::Combine($hashtableLayout.CaseRoot, 'trusted-target')
            $strLink = [System.IO.Path]::Combine($hashtableLayout.CaseRoot, 'trusted-link')
            [void][System.IO.Directory]::CreateDirectory($strTarget)
            $boolFixtureLinkCreated = & $script:scriptBlockNewSymbolicLink `
                -LinkPath $strLink -TargetPath $strTarget -Directory $true
            if (-not $boolFixtureLinkCreated) {
                $objObservation.AuthorizedSkip = $true
                $objObservation.SkipCode = 'skip-link-primitive-unavailable'
                return $objObservation
            }
            try {
                [void](New-StyleGuideCandidateInvocationContext -TrustedTemporaryRoot $strLink)
            } catch {
                # Any exception from context creation reached this catch and the
                # expected phase, subreason, and diagnostic were then recorded
                # unconditionally, so the case passed even when the production
                # rejection under test never ran. Require the structured
                # diagnostic the production check actually emits instead. The
                # creation failure is wrapped, so the inner reason is not
                # readable here; the category and composite shape are, and an
                # unrelated failure carries neither.
                $strObservedCode = & $script:scriptBlockGetProductionFailureField `
                    -ErrorRecord $_ `
                    -Key 'PSStyleGuideDiagnosticCode' `
                    -Fallback 'none'
                if ($strObservedCode -cne 'root-invalid' -or
                    $_.Exception.Message.IndexOf(
                        'PSStyleGuide.ContextCreate.v1|category=root-invalid|cleanup=not-required',
                        [System.StringComparison]::Ordinal) -lt 0) {
                    & $script:scriptBlockStopHarness `
                        -Code 'fixture-failed' -Detail 'link-component-evidence'
                }
                $objObservation.Phase = 'root'
                $objObservation.Subreason = 'nonordinary-directory'
                $objObservation.DiagnosticCode = 'root-invalid'
            }
            return $objObservation
        }

        if ($strSemantic -ceq 'environment.roots.trusted-ancestor') {
            $hashtableLayout.Checkout = [System.IO.Path]::Combine(
                $hashtableLayout.Trusted,
                'checkout-child'
            )
            [void][System.IO.Directory]::CreateDirectory($hashtableLayout.Checkout)
        } elseif ($strSemantic -ceq 'environment.roots.checkout-ancestor') {
            $hashtableLayout.Trusted = [System.IO.Path]::Combine(
                $hashtableLayout.Checkout,
                'trusted-child'
            )
            [void][System.IO.Directory]::CreateDirectory($hashtableLayout.Trusted)
        }

        $objContext = New-StyleGuideCandidateInvocationContext `
            -TrustedTemporaryRoot $hashtableLayout.Trusted
        $objObservation.InvocationId = $objContext.InvocationId
        $objObservation.PreCleanupState = 'Active'
        $objObservation.CandidateFinalState = 'Absent'
        $objObservation.ContextFinalState = 'Active'

        if ($strSemantic -ceq 'path.containment.sibling-prefix') {
            $strSibling = $hashtableLayout.Trusted + '-sibling'
            if (& $script:scriptBlockTestCandidateHelperPathContained `
                -Root $hashtableLayout.Trusted -Candidate $strSibling) {
                & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'sibling-prefix-accepted'
            }
            $objObservation.Phase = 'containment'
            $objObservation.Subreason = 'relationship'
            $objObservation.DiagnosticCode = 'containment-invalid'
            $objCleanup = Remove-StyleGuideCandidateInvocationContext -Context $objContext
            $objObservation.CleanupSequence = 'context'
            $objObservation.ContextFinalState = $objCleanup.FinalState
            $objObservation.FilesystemCallCount = [uint32]$objCleanup.FilesystemCallCount
            return $objObservation
        }

        $strArchivePath = [System.IO.Path]::Combine(
            $objContext.DownloadDirectoryPath,
            'candidate-artifact.bin'
        )
        $boolCreateDefaultArchive = $strSemantic -cnotin @(
            'download.entries.empty',
            'download.entries.two-files',
            'download.entry.directory',
            'download.entry.link',
            'download.entry.nonregular'
        )
        if ($strSemantic -ceq 'download.entry.nonregular') {
            # A FIFO reports Normal attributes and zero length, so nothing in the
            # ordinary-file predicate distinguishes it from an archive; opening one
            # for reading blocks until a writer appears. Linux-only: Windows has no
            # equivalent the download path can encounter.
            $strFifoPath = [string](& $script:scriptBlockResolveHarnessNativePath `
                -CandidatePath ([string[]]@('/usr/bin/mkfifo', '/bin/mkfifo')))
            if ($strFifoPath.Length -eq 0) {
                & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'fifo-utility'
            }
            $arrFifoOutput = @(& $strFifoPath '--' $strArchivePath 2>$null)
            if ($LASTEXITCODE -ne 0 -or $arrFifoOutput.Count -ne 0) {
                & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'fifo-create'
            }
            # A blocking defect cannot report itself. If the gate this row
            # covers is removed, production opens the pipe and waits for a
            # writer that never arrives, so the whole suite stops: the run dies
            # of a job timeout naming nothing, instead of this row failing and
            # naming the cause. A detached writer therefore blocks on the write
            # end for the life of the case. With the gate present production
            # never opens the pipe at all, so that writer stays blocked and is
            # reaped by its own timeout; without the gate the two opens meet,
            # the writer closes an empty stream, production continues on an
            # empty archive, and this row fails on its own diagnostic like
            # every other row. conv=nocreat keeps the writer from putting an
            # ordinary file where the pipe was if cleanup unlinks it first.
            $strFifoTimeoutPath = [string](& $script:scriptBlockResolveHarnessNativePath `
                -CandidatePath ([string[]]@('/usr/bin/timeout', '/bin/timeout')))
            $strFifoWriterPath = [string](& $script:scriptBlockResolveHarnessNativePath `
                -CandidatePath ([string[]]@('/usr/bin/dd', '/bin/dd')))
            if ($strFifoTimeoutPath.Length -eq 0 -or $strFifoWriterPath.Length -eq 0) {
                & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'fifo-writer'
            }
            $objFifoWriterStart = New-Object System.Diagnostics.ProcessStartInfo
            $objFifoWriterStart.FileName = $strFifoTimeoutPath
            $objFifoWriterStart.UseShellExecute = $false
            $objFifoWriterStart.CreateNoWindow = $true
            $arrFifoWriterArgument = [string[]]@(
                '20',
                $strFifoWriterPath,
                'if=/dev/null',
                ('of=' + $strArchivePath),
                'conv=nocreat'
            )
            if ($null -ne $objFifoWriterStart.PSObject.Properties['ArgumentList']) {
                foreach ($strFifoWriterArgument in $arrFifoWriterArgument) {
                    [void]$objFifoWriterStart.ArgumentList.Add([string]$strFifoWriterArgument)
                }
            } else {
                $objFifoWriterStart.Arguments = (
                    & $script:scriptBlockConvertToNativeArgumentString `
                        -ArgumentList $arrFifoWriterArgument
                )
            }
            $null = [System.Diagnostics.Process]::Start($objFifoWriterStart)
        }
        if ($strSemantic -ceq 'download.entries.two-files') {
            [System.IO.File]::WriteAllBytes(
                [System.IO.Path]::Combine($objContext.DownloadDirectoryPath, 'one'),
                [byte[]](1)
            )
            [System.IO.File]::WriteAllBytes(
                [System.IO.Path]::Combine($objContext.DownloadDirectoryPath, 'two'),
                [byte[]](2)
            )
        } elseif ($strSemantic -ceq 'download.entry.directory') {
            [void][System.IO.Directory]::CreateDirectory($strArchivePath)
        } elseif ($strSemantic -ceq 'download.entry.link') {
            $boolFixtureLinkCreated = & $script:scriptBlockNewSymbolicLink `
                -LinkPath $strArchivePath `
                -TargetPath $hashtableLayout.SentinelDirectory `
                -Directory $true
            if (-not $boolFixtureLinkCreated) {
                $objObservation.AuthorizedSkip = $true
                $objObservation.SkipCode = 'skip-link-primitive-unavailable'
                return $objObservation
            }
        } elseif ($boolCreateDefaultArchive) {
            $hashtableFixtureEvidence = & $script:scriptBlockNewZipFixture `
                -LiteralPath $strArchivePath `
                -SemanticCase $strSemantic
            $objObservation.FixtureLength = [uint64]$hashtableFixtureEvidence.Length
            $objObservation.FixtureSha256 = [string]$hashtableFixtureEvidence.Sha256
        }

        if ($strSemantic -in @(
            'resource.actual.entry-overrun',
            'resource.actual.total-overrun',
            'resource.declared.negative-inconsistent',
            'resource.arithmetic.checked-overflow'
        )) {
            $objResourceError = $null
            try {
                switch -Exact ($strSemantic) {
                    'resource.actual.entry-overrun' {
                        [void](& $script:scriptBlockAddCandidateHelperActualLength `
                            -CurrentEntryLength ([uint64](8MB)) `
                            -CurrentTotalLength ([uint64]0) `
                            -ReadLength ([uint64]1) `
                            -DeclaredEntryLength ([uint64](8MB)) `
                            -Phase 'manifest' `
                            -DiagnosticCode 'manifest-invalid')
                    }
                    'resource.actual.total-overrun' {
                        [void](& $script:scriptBlockAddCandidateHelperActualLength `
                            -CurrentEntryLength ([uint64]0) `
                            -CurrentTotalLength ([uint64](32MB)) `
                            -ReadLength ([uint64]1) `
                            -DeclaredEntryLength ([uint64](8MB)) `
                            -Phase 'manifest' `
                            -DiagnosticCode 'manifest-invalid')
                    }
                    'resource.declared.negative-inconsistent' {
                        [void](& $script:scriptBlockAddCandidateHelperDeclaredLength `
                            -CurrentTotal ([uint64]0) `
                            -DeclaredLength ([long]-1))
                    }
                    'resource.arithmetic.checked-overflow' {
                        [void](& $script:scriptBlockAddCandidateHelperDeclaredLength `
                            -CurrentTotal ([uint64]::MaxValue) `
                            -DeclaredLength ([long]1))
                    }
                }
            } catch {
                $objResourceError = $_
            }
            if ($null -eq $objResourceError) {
                & $script:scriptBlockStopHarness `
                    -Code 'fixture-failed' `
                    -Detail 'resource-guard-accepted'
            }
            $objObservation.Phase = & $script:scriptBlockGetProductionFailureField `
                -ErrorRecord $objResourceError `
                -Key 'PSStyleGuidePhase' `
                -Fallback 'none'
            $objObservation.Subreason = & $script:scriptBlockGetProductionFailureField `
                -ErrorRecord $objResourceError `
                -Key 'PSStyleGuideSubreason' `
                -Fallback 'failure'
            $objObservation.DiagnosticCode = & $script:scriptBlockGetProductionFailureField `
                -ErrorRecord $objResourceError `
                -Key 'PSStyleGuideDiagnosticCode' `
                -Fallback 'orchestration-failed'
            [System.IO.File]::Delete($strArchivePath)
            $objCleanup = Remove-StyleGuideCandidateInvocationContext -Context $objContext
            $objObservation.CleanupSequence = 'context'
            $objObservation.ContextFinalState = [string]$objContext.LifecycleState
            $objObservation.FilesystemCallCount = [uint32]$objCleanup.FilesystemCallCount
            return $objObservation
        }

        if ($strSemantic -ceq 'environment.hidden-extra-detected') {
            $strHiddenPath = [System.IO.Path]::Combine(
                $objContext.DownloadDirectoryPath,
                '.hidden-extra'
            )
            [System.IO.File]::WriteAllBytes($strHiddenPath, [byte[]](0x78))
            if ($script:boolCandidateIsWindows) {
                [System.IO.File]::SetAttributes(
                    $strHiddenPath,
                    [System.IO.FileAttributes]::Hidden
                )
            }
        }
        if ($strSemantic -ceq 'download.entry.unreadable' -and
            [System.IO.File]::Exists($strArchivePath)) {
            $objHeldStream = New-Object System.IO.FileStream(
                $strArchivePath,
                [System.IO.FileMode]::Open,
                [System.IO.FileAccess]::ReadWrite,
                [System.IO.FileShare]::None
            )
        }

        if ($strSemantic -ceq 'environment.checkout.link-component') {
            $strCheckoutTarget = [System.IO.Path]::Combine(
                $hashtableLayout.CaseRoot,
                'checkout-target'
            )
            $strCheckoutLink = [System.IO.Path]::Combine(
                $hashtableLayout.CaseRoot,
                'checkout-link'
            )
            [void][System.IO.Directory]::CreateDirectory($strCheckoutTarget)
            $boolFixtureLinkCreated = & $script:scriptBlockNewSymbolicLink `
                -LinkPath $strCheckoutLink -TargetPath $strCheckoutTarget -Directory $true
            if (-not $boolFixtureLinkCreated) {
                $objObservation.AuthorizedSkip = $true
                $objObservation.SkipCode = 'skip-link-primitive-unavailable'
                return $objObservation
            }
            $hashtableLayout.Checkout = $strCheckoutLink
        } elseif ($strSemantic -ceq 'environment.roots.equal') {
            $hashtableLayout.Checkout = $hashtableLayout.Trusted
        } elseif ($strSemantic -ceq 'environment.roots.case-alias') {
            $hashtableLayout.Checkout = $hashtableLayout.Trusted.ToUpperInvariant()
        } elseif ($strSemantic -ceq 'environment.checkout.missing') {
            $hashtableLayout.Checkout = [System.IO.Path]::Combine(
                $hashtableLayout.CaseRoot,
                'missing-checkout'
            )
        }

        if ($strSemantic -ceq 'environment.candidate.case-collision') {
            [System.IO.File]::WriteAllBytes(
                [System.IO.Path]::Combine($objContext.InvocationRootPath, 'Candidate'),
                [byte[]](0x78)
            )
        } elseif ($strSemantic -ceq 'candidate.preexisting.file') {
            [System.IO.File]::WriteAllBytes($objContext.CandidatePath, [byte[]](0x78))
        } elseif ($strSemantic -ceq 'candidate.preexisting.directory') {
            [void][System.IO.Directory]::CreateDirectory($objContext.CandidatePath)
        } elseif ($strSemantic -ceq 'candidate.preexisting.live-link') {
            $boolFixtureLinkCreated = & $script:scriptBlockNewSymbolicLink `
                -LinkPath $objContext.CandidatePath `
                -TargetPath $hashtableLayout.SentinelDirectory `
                -Directory $true
        } elseif ($strSemantic -ceq 'candidate.preexisting.dangling-link') {
            $boolFixtureLinkCreated = & $script:scriptBlockNewSymbolicLink `
                -LinkPath $objContext.CandidatePath `
                -TargetPath ([System.IO.Path]::Combine($hashtableLayout.CaseRoot, 'absent-target')) `
                -Directory $true
        }
        if ((& $script:scriptBlockTestLinkSemanticCase -SemanticCase $strSemantic) -and
            -not $boolFixtureLinkCreated) {
            $objObservation.AuthorizedSkip = $true
            $objObservation.SkipCode = 'skip-link-primitive-unavailable'
            return $objObservation
        }

        $objCheckoutClaim = [object]$hashtableLayout.Checkout
        $objTrustedClaim = [object]$hashtableLayout.Trusted
        $objDownloadClaim = [object]$objContext.DownloadDirectoryPath
        $objCandidateClaim = [object]$objContext.CandidatePath
        $objExpectedDigest = [object]$objObservation.FixtureSha256
        $hashtableOptional = @{}

        switch -Exact ($strSemantic) {
            'path.provider.filesystem-qualified' {
                $objCheckoutClaim = 'FileSystem::' + $hashtableLayout.Checkout
                $objTrustedClaim = 'Microsoft.PowerShell.Core\FileSystem::' + $hashtableLayout.Trusted
                $objDownloadClaim = 'FileSystem::' + $objContext.DownloadDirectoryPath
                $objCandidateClaim = 'FileSystem::' + $objContext.CandidatePath
            }
            'digest.mismatch.labels-omitted' { $objExpectedDigest = '0' * 64 }
            'digest.mismatch.labels-present' {
                $objExpectedDigest = '0' * 64
                $hashtableOptional.ArtifactId = 'artifact-146'
                $hashtableOptional.RunId = '9001'
                $hashtableOptional.RunAttempt = '2'
            }
            'digest.grammar.short' { $objExpectedDigest = '0' * 63 }
            'digest.grammar.nonhex' { $objExpectedDigest = 'g' * 64 }
            'digest.grammar.prefixed' { $objExpectedDigest = 'sha256:' + ('0' * 64) }
            'environment.checkout.relative' { $objCheckoutClaim = 'relative-checkout' }
            'environment.path.wildcard' { $objCheckoutClaim = $hashtableLayout.Checkout + '*' }
            'environment.path.raw-array' { $objCheckoutClaim = [object[]]@($hashtableLayout.Checkout) }
            'environment.path.raw-object' {
                $objCheckoutClaim = [pscustomobject]@{
                    Path = $hashtableLayout.Checkout
                }
            }
            'label.artifact.explicit-null' { $hashtableOptional.ArtifactId = $null }
            'label.artifact.empty' { $hashtableOptional.ArtifactId = '' }
            'label.artifact.whitespace' { $hashtableOptional.ArtifactId = '   ' }
            'label.artifact.raw-array' { $hashtableOptional.ArtifactId = [object[]]@('artifact-146') }
            'label.runid.raw-object' { $hashtableOptional.RunId = [pscustomobject]@{ Value = '9001' } }
            'label.runattempt.control' { $hashtableOptional.RunAttempt = "2`n" }
            'label.artifact.over-limit' { $hashtableOptional.ArtifactId = 'x' * 129 }
            'label.artifact.valid' { $hashtableOptional.ArtifactId = 'artifact-146' }
            'label.run-identities.valid' {
                $hashtableOptional.RunId = '9001'
                $hashtableOptional.RunAttempt = '2'
            }
            default {}
        }

        $objExpansionError = $null
        $objReturnedContext = $null
        try {
            $objReturnedContext = & $HelperLiteralPath `
                -Context $objContext `
                -CheckoutRoot $objCheckoutClaim `
                -TrustedTemporaryRoot $objTrustedClaim `
                -DownloadDirectory $objDownloadClaim `
                -CandidateDirectory $objCandidateClaim `
                -ExpectedDigest $objExpectedDigest `
                @hashtableOptional
        } catch {
            $objExpansionError = $_
        } finally {
            if ($null -ne $objHeldStream) {
                $objHeldStream.Dispose()
                $objHeldStream = $null
            }
        }

        if ($null -eq $objExpansionError) {
            if (-not [object]::ReferenceEquals($objContext, $objReturnedContext)) {
                & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'context-reference'
            }
            $objObservation.Result = 'success'
            $objObservation.Status = 'succeeded'
            $objObservation.Phase = 'none'
            $objObservation.Subreason = 'none'
            $objObservation.DiagnosticCode = 'none'
            $objObservation.CleanupSequence = 'helper-context'
            $objCleanup = Remove-StyleGuideCandidateInvocationState -Context $objContext
            $objObservation.FilesystemCallCount = [uint32]$objCleanup.FilesystemCallCount
        } else {
            $objObservation.Result = 'rejection'
            $objObservation.Status = 'failed'
            $objObservation.Phase = & $script:scriptBlockGetProductionFailureField `
                -ErrorRecord $objExpansionError `
                -Key 'PSStyleGuidePhase' `
                -Fallback 'none'
            $objObservation.Subreason = & $script:scriptBlockGetProductionFailureField `
                -ErrorRecord $objExpansionError `
                -Key 'PSStyleGuideSubreason' `
                -Fallback 'failure'
            $objObservation.DiagnosticCode = & $script:scriptBlockGetProductionFailureField `
                -ErrorRecord $objExpansionError `
                -Key 'PSStyleGuideDiagnosticCode' `
                -Fallback 'orchestration-failed'
            if ($objObservation.Phase -ceq 'parameter') {
                $objObservation.CleanupSequence = 'context'
                foreach ($strEntry in [System.IO.Directory]::EnumerateFileSystemEntries(
                    $objContext.DownloadDirectoryPath
                )) {
                    $objAttributes = [System.IO.File]::GetAttributes($strEntry)
                    if (($objAttributes -band [System.IO.FileAttributes]::Directory) -eq 0 -and
                        ($objAttributes -band [System.IO.FileAttributes]::ReparsePoint) -eq 0) {
                        [System.IO.File]::Delete($strEntry)
                    }
                }
                $objCleanup = Remove-StyleGuideCandidateInvocationContext -Context $objContext
                $objObservation.FilesystemCallCount = [uint32]$objCleanup.FilesystemCallCount
            } else {
                $objObservation.CleanupSequence = 'helper-context'
            }
        }

        $objObservation.ContextFinalState = [string]$objContext.LifecycleState
        if ([System.IO.Directory]::Exists($objContext.CandidatePath) -or
            [System.IO.File]::Exists($objContext.CandidatePath)) {
            $objObservation.CandidateFinalState = if ($objContext.LifecycleState -ceq 'CleanupFailed') {
                'RetainedUncertain'
            } else {
                'Present'
            }
        } else {
            $objObservation.CandidateFinalState = 'Absent'
        }
        if (-not (& $script:scriptBlockTestSentinelIntact -Layout $hashtableLayout)) {
            $objObservation.SentinelState = 'changed'
        }
        return $objObservation
    } finally {
        if ($null -ne $objHeldStream) {
            $objHeldStream.Dispose()
        }
        if (-not (& $script:scriptBlockTestSentinelIntact -Layout $hashtableLayout)) {
            $objObservation.SentinelState = 'changed'
        }
        & $script:scriptBlockRemoveTestTree `
            -LiteralPath $hashtableLayout.CaseRoot `
            -ApprovedParent $RunRoot
    }
}

$script:scriptBlockNewExpandedFixture = {
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Layout,

        [Parameter(Mandatory = $true)]
        [string]$HelperLiteralPath
    )

    $objContext = New-StyleGuideCandidateInvocationContext `
        -TrustedTemporaryRoot $Layout.Trusted
    $strArchivePath = [System.IO.Path]::Combine(
        $objContext.DownloadDirectoryPath,
        'candidate-artifact.bin'
    )
    $hashtableEvidence = & $script:scriptBlockNewZipFixture `
        -LiteralPath $strArchivePath `
        -SemanticCase 'archive.valid.exact'
    $objReturnedContext = & $HelperLiteralPath `
        -Context $objContext `
        -CheckoutRoot $Layout.Checkout `
        -TrustedTemporaryRoot $Layout.Trusted `
        -DownloadDirectory $objContext.DownloadDirectoryPath `
        -CandidateDirectory $objContext.CandidatePath `
        -ExpectedDigest $hashtableEvidence.Sha256
    if (-not [object]::ReferenceEquals($objContext, $objReturnedContext)) {
        & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'expanded-context-reference'
    }
    return [ordered]@{
        Context = $objContext
        ArchivePath = $strArchivePath
        FixtureLength = [uint64]$hashtableEvidence.Length
        FixtureSha256 = [string]$hashtableEvidence.Sha256
    }
}

$script:scriptBlockSetCleanupObservation = {
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Observation,

        [Parameter(Mandatory = $true)]
        [object]$CleanupResult,

        [Parameter(Mandatory = $true)]
        [string]$Subreason,

        [Parameter(Mandatory = $true)]
        [string]$CleanupSequence,

        [Parameter(Mandatory = $true)]
        [object]$Context
    )

    $Observation.Result = if ($CleanupResult.Success) { 'success' } else { 'rejection' }
    $Observation.Status = if ($CleanupResult.Success) { 'succeeded' } else { 'failed' }
    $Observation.Phase = 'cleanup'
    $Observation.Subreason = $Subreason
    $Observation.DiagnosticCode = [string]$CleanupResult.DiagnosticCode
    $Observation.CleanupSequence = $CleanupSequence
    $Observation.ContextFinalState = [string]$Context.LifecycleState
    $Observation.FilesystemCallCount = [uint32]$CleanupResult.FilesystemCallCount
    $Observation.CandidateFinalState = if (
        [System.IO.Directory]::Exists($Context.CandidatePath) -or
        [System.IO.File]::Exists($Context.CandidatePath)
    ) {
        if ($CleanupResult.FinalState -ceq 'CleanupFailed') {
            'RetainedUncertain'
        } else {
            'Present'
        }
    } else {
        'Absent'
    }
}

$script:scriptBlockInvokeContextCleanupFixture = {
    param (
        [Parameter(Mandatory = $true)]
        [object]$Case,

        [Parameter(Mandatory = $true)]
        [string]$RunRoot,

        [Parameter(Mandatory = $true)]
        [string]$HelperLiteralPath
    )

    $objObservation = & $script:scriptBlockNewObservation
    $hashtableLayout = & $script:scriptBlockNewCaseFixtureLayout `
        -RunRoot $RunRoot `
        -CaseId $Case.CaseId
    $objContext = $null
    try {
        $strSemantic = [string]$Case.SemanticCase
        if ($strSemantic -ceq 'context.cleanup.candidate-then-context') {
            $hashtableExpanded = & $script:scriptBlockNewExpandedFixture `
                -Layout $hashtableLayout `
                -HelperLiteralPath $HelperLiteralPath
            $objContext = $hashtableExpanded.Context
            $objObservation.FixtureLength = $hashtableExpanded.FixtureLength
            $objObservation.FixtureSha256 = $hashtableExpanded.FixtureSha256
            $objObservation.InvocationId = $objContext.InvocationId
            $objObservation.PreCleanupState = 'Active'
            $objCleanupResult = Remove-StyleGuideCandidateInvocationState -Context $objContext
            & $script:scriptBlockSetCleanupObservation `
                -Observation $objObservation `
                -CleanupResult $objCleanupResult `
                -Subreason 'candidate-before-context' `
                -CleanupSequence 'helper-context' `
                -Context $objContext
            return $objObservation
        }

        if ($strSemantic -ceq 'context.cleanup.primary-and-cleanup-failure') {
            # Drive a real expansion failure whose caller cleanup also fails, and
            # prove both survive. Two download entries reject in the download
            # phase, which is past the parameter phase, so the helper runs its
            # production cleanup transition and aggregates the cleanup category
            # with the primary failure instead of replacing it.
            $objContext = New-StyleGuideCandidateInvocationContext `
                -TrustedTemporaryRoot $hashtableLayout.Trusted
            $objObservation.InvocationId = $objContext.InvocationId
            $objObservation.PreCleanupState = 'Active'
            foreach ($strDownloadLeaf in @('candidate-artifact.bin', 'unexpected.bin')) {
                [System.IO.File]::WriteAllBytes(
                    [System.IO.Path]::Combine($objContext.DownloadDirectoryPath, $strDownloadLeaf),
                    [byte[]](0x78)
                )
            }

            $objPrimaryError = $null
            try {
                [void](& $HelperLiteralPath `
                    -Context $objContext `
                    -CheckoutRoot $hashtableLayout.Checkout `
                    -TrustedTemporaryRoot $hashtableLayout.Trusted `
                    -DownloadDirectory $objContext.DownloadDirectoryPath `
                    -CandidateDirectory $objContext.CandidatePath `
                    -ExpectedDigest ('0' * 64))
            } catch {
                $objPrimaryError = $_
            }
            if ($null -eq $objPrimaryError) {
                & $script:scriptBlockStopHarness `
                    -Code 'fixture-failed' -Detail 'composite-accepted'
            }

            $strPrimaryCode = & $script:scriptBlockGetProductionFailureField `
                -ErrorRecord $objPrimaryError `
                -Key 'PSStyleGuideDiagnosticCode' `
                -Fallback 'none'
            $strPrimaryPhase = & $script:scriptBlockGetProductionFailureField `
                -ErrorRecord $objPrimaryError `
                -Key 'PSStyleGuidePhase' `
                -Fallback 'none'
            $strCompositeCleanupCode = & $script:scriptBlockGetProductionFailureField `
                -ErrorRecord $objPrimaryError `
                -Key 'PSStyleGuideCleanupCode' `
                -Fallback 'none'
            # The primary failure must be a real non-parameter production
            # rejection, and the cleanup category must ride alongside it rather
            # than overwrite it. Either half missing is a fixture failure.
            if ($strPrimaryCode -cne 'download-invalid' -or
                $strPrimaryPhase -cne 'download' -or
                $strCompositeCleanupCode -cne 'cleanup-owned-entry-uncertain' -or
                $objContext.LifecycleState -cne 'CleanupFailed') {
                & $script:scriptBlockStopHarness `
                    -Code 'fixture-failed' -Detail 'composite-evidence'
            }

            # The terminal repeat is the observable cleanup result on this path,
            # and it must stay zero-call while retaining the uncertainty evidence.
            $objCleanupResult = Remove-StyleGuideCandidateInvocationContext -Context $objContext
            if ($objCleanupResult.Success -or
                $objCleanupResult.FilesystemCallCount -ne [uint32]0 -or
                $objCleanupResult.RetainedRecordSequences.Count -eq 0) {
                & $script:scriptBlockStopHarness `
                    -Code 'fixture-failed' -Detail 'composite-terminal-repeat'
            }
            & $script:scriptBlockSetCleanupObservation `
                -Observation $objObservation `
                -CleanupResult $objCleanupResult `
                -Subreason 'primary-and-cleanup' `
                -CleanupSequence 'context' `
                -Context $objContext
            $objObservation.DiagnosticCode = $strCompositeCleanupCode
            return $objObservation
        }

        $objContext = New-StyleGuideCandidateInvocationContext `
            -TrustedTemporaryRoot $hashtableLayout.Trusted
        $objObservation.InvocationId = $objContext.InvocationId
        $objObservation.PreCleanupState = 'Active'
        $strSubreason = 'succeeded'

        switch -Exact ($strSemantic) {
            'context.cleanup.forged-length' {
                # A caller-supplied journal decides how much evidence cleanup
                # gathers. A record claiming more than the archive ceiling is
                # refused by the context validator before any filesystem call,
                # so a forged length cannot direct an unbounded read.
                $objForgedRecord = [pscustomobject][ordered]@{
                    SchemaVersion = [uint32]1
                    Sequence = [uint32]$objContext.OwnershipJournal.Count
                    Kind = 'DownloadFile'
                    Path = [System.IO.Path]::Combine(
                        $objContext.DownloadDirectoryPath, 'forged.zip')
                    ParentPath = $objContext.DownloadDirectoryPath
                    LeafName = 'forged.zip'
                    ExpectedEntryType = 'File'
                    CreationPhase = 'download'
                    EntryState = 'Created'
                    ContentLength = [uint64](32MB + 1)
                    ContentSha256 = ('0' * 64)
                }
                $objForgedRecord.PSObject.TypeNames.Insert(
                    0, 'PSStyleGuide.CandidateOwnershipRecord.v1')
                $arrForgedJournal = New-Object object[] (
                    $objContext.OwnershipJournal.Count + 1)
                [System.Array]::Copy(
                    $objContext.OwnershipJournal, $arrForgedJournal,
                    $objContext.OwnershipJournal.Count)
                $arrForgedJournal[$arrForgedJournal.Length - 1] = $objForgedRecord
                $objContext.OwnershipJournal = [object[]]$arrForgedJournal
                $objContext.NextSequence = [uint32]$arrForgedJournal.Length
                $strSubreason = 'context-invalid'
            }
            'context.cleanup.unjournaled-entry' {
                [System.IO.File]::WriteAllBytes(
                    [System.IO.Path]::Combine($objContext.DownloadDirectoryPath, 'unexpected.bin'),
                    [byte[]](0x78)
                )
                $strSubreason = 'root-cardinality'
            }
            'context.cleanup.link-substitution' {
                [System.IO.Directory]::Delete($objContext.DownloadDirectoryPath, $false)
                $boolLinkCreated = & $script:scriptBlockNewSymbolicLink `
                    -LinkPath $objContext.DownloadDirectoryPath `
                    -TargetPath $hashtableLayout.SentinelDirectory `
                    -Directory $true
                if (-not $boolLinkCreated) {
                    $objObservation.AuthorizedSkip = $true
                    $objObservation.SkipCode = 'skip-link-primitive-unavailable'
                    return $objObservation
                }
                $strSubreason = 'nonordinary'
            }
            'context.cleanup.missing-entry' {
                [System.IO.Directory]::Delete($objContext.DownloadDirectoryPath, $false)
                $strSubreason = 'missing-entry'
            }
            'context.cleanup.partial-journal' {
                $objContext.OwnershipJournal = [object[]]@($objContext.OwnershipJournal[0])
                $strSubreason = 'context-invalid'
            }
            default {}
        }

        if ($strSemantic -ceq 'context.cleanup.disposed-repeat') {
            $objFirstCleanup = Remove-StyleGuideCandidateInvocationContext -Context $objContext
            if (-not $objFirstCleanup.Success -or $objFirstCleanup.FinalState -cne 'Disposed') {
                & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'context-first-cleanup'
            }
            $objObservation.PreCleanupState = 'Disposed'
            $objCleanupResult = Remove-StyleGuideCandidateInvocationContext -Context $objContext
            $strSubreason = 'already-disposed'
        } else {
            $objCleanupResult = Remove-StyleGuideCandidateInvocationContext -Context $objContext
        }

        & $script:scriptBlockSetCleanupObservation `
            -Observation $objObservation `
            -CleanupResult $objCleanupResult `
            -Subreason $strSubreason `
            -CleanupSequence 'context' `
            -Context $objContext
        return $objObservation
    } finally {
        if (-not (& $script:scriptBlockTestSentinelIntact -Layout $hashtableLayout)) {
            $objObservation.SentinelState = 'changed'
        }
        & $script:scriptBlockRemoveTestTree `
            -LiteralPath $hashtableLayout.CaseRoot `
            -ApprovedParent $RunRoot
    }
}

$script:scriptBlockInvokeHelperCleanupFixture = {
    param (
        [Parameter(Mandatory = $true)]
        [object]$Case,

        [Parameter(Mandatory = $true)]
        [string]$RunRoot,

        [Parameter(Mandatory = $true)]
        [string]$HelperLiteralPath
    )

    $objObservation = & $script:scriptBlockNewObservation
    $hashtableLayout = & $script:scriptBlockNewCaseFixtureLayout `
        -RunRoot $RunRoot `
        -CaseId $Case.CaseId
    $objContext = $null
    try {
        $strSemantic = [string]$Case.SemanticCase
        if ($strSemantic -ceq 'helper.cleanup.primary-and-cleanup-failure') {
            # Drive a real expansion failure and prove the primary diagnostic
            # survives the cleanup transition instead of being replaced by it.
            # A candidate file carrying a carriage return is rejected in
            # post-extraction, past the parameter phase, so the helper runs its
            # production cleanup and aggregates the cleanup category alongside
            # the primary failure.
            #
            # Issue #146 states this row's oracle as both failures surviving.
            # Stated plainly, this row does not deliver that oracle, and the
            # assertions below do not pretend otherwise. The candidate-cleanup
            # leg cannot be made to fail here: every candidate-cleanup failure
            # requires the candidate directory to diverge from the journal
            # between extraction and the helper's own cleanup, inside one call,
            # which needs the competing writer the issue lists as a non-goal.
            #
            # What this row does prove is that the primary failure survives the
            # cleanup transition and that the cleanup category is carried as its
            # own separately readable value with its own exact outcome. The
            # retained-uncertainty half stays covered by K-01 and K-02. The
            # conflict between this row's oracle and the issue's non-goal is
            # tracked in issue #154 and needs an issue-level decision, not a
            # harness workaround.
            $objContext = New-StyleGuideCandidateInvocationContext `
                -TrustedTemporaryRoot $hashtableLayout.Trusted
            $objObservation.InvocationId = $objContext.InvocationId
            $objObservation.PreCleanupState = 'Active'
            $strArchivePath = [System.IO.Path]::Combine(
                $objContext.DownloadDirectoryPath,
                'candidate-artifact.bin'
            )
            $hashtableEvidence = & $script:scriptBlockNewZipFixture `
                -LiteralPath $strArchivePath `
                -SemanticCase 'output.bytes.cr'
            $objObservation.FixtureLength = [uint64]$hashtableEvidence.Length
            $objObservation.FixtureSha256 = [string]$hashtableEvidence.Sha256

            $objPrimaryError = $null
            try {
                [void](& $HelperLiteralPath `
                    -Context $objContext `
                    -CheckoutRoot $hashtableLayout.Checkout `
                    -TrustedTemporaryRoot $hashtableLayout.Trusted `
                    -DownloadDirectory $objContext.DownloadDirectoryPath `
                    -CandidateDirectory $objContext.CandidatePath `
                    -ExpectedDigest $hashtableEvidence.Sha256)
            } catch {
                $objPrimaryError = $_
            }
            if ($null -eq $objPrimaryError) {
                & $script:scriptBlockStopHarness `
                    -Code 'fixture-failed' -Detail 'composite-accepted'
            }

            $strPrimaryCode = & $script:scriptBlockGetProductionFailureField `
                -ErrorRecord $objPrimaryError `
                -Key 'PSStyleGuideDiagnosticCode' `
                -Fallback 'none'
            $strPrimaryPhase = & $script:scriptBlockGetProductionFailureField `
                -ErrorRecord $objPrimaryError `
                -Key 'PSStyleGuidePhase' `
                -Fallback 'none'
            $strCompositeCleanupCode = & $script:scriptBlockGetProductionFailureField `
                -ErrorRecord $objPrimaryError `
                -Key 'PSStyleGuideCleanupCode' `
                -Fallback 'none'
            # The primary failure must still be the one reported, and the
            # cleanup category must ride alongside it as its own value. A
            # missing cleanup code, or one that has taken the primary's place,
            # is the regression this row exists to catch.
            # The cleanup leg reachable here succeeds, so its code is pinned to
            # that exact value rather than to "anything that is not the primary
            # code." Accepting any non-primary value let a success code stand in
            # for a failure code, which is the whole distinction this row is
            # supposed to police. Pinning it means a regression that drops the
            # cleanup field, overwrites it with the primary code, or changes the
            # cleanup outcome all fail here.
            if ($strPrimaryCode -cne 'post-extraction-invalid' -or
                $strPrimaryPhase -cne 'post-extraction' -or
                $strCompositeCleanupCode -cne 'cleanup-succeeded') {
                & $script:scriptBlockStopHarness `
                    -Code 'fixture-failed' -Detail 'composite-evidence'
            }

            # The terminal repeat is the observable cleanup result on this path.
            $objCleanupResult = Remove-StyleGuideCandidateInvocationState -Context $objContext
            $objObservation.Result = 'rejection'
            $objObservation.Status = 'failed'
            $objObservation.Phase = $strPrimaryPhase
            $objObservation.Subreason = 'primary-and-cleanup'
            $objObservation.DiagnosticCode = $strPrimaryCode
            $objObservation.CleanupSequence = 'helper-context'
            $objObservation.ContextFinalState = [string]$objContext.LifecycleState
            $objObservation.FilesystemCallCount = [uint32]$objCleanupResult.FilesystemCallCount
            $objObservation.CandidateFinalState = if (
                [System.IO.Directory]::Exists($objContext.CandidatePath) -or
                [System.IO.File]::Exists($objContext.CandidatePath)
            ) {
                'RetainedUncertain'
            } else {
                'Absent'
            }
            return $objObservation
        }

        $hashtableExpanded = & $script:scriptBlockNewExpandedFixture `
            -Layout $hashtableLayout `
            -HelperLiteralPath $HelperLiteralPath
        $objContext = $hashtableExpanded.Context
        $objObservation.InvocationId = $objContext.InvocationId
        $objObservation.FixtureLength = $hashtableExpanded.FixtureLength
        $objObservation.FixtureSha256 = $hashtableExpanded.FixtureSha256
        $objObservation.PreCleanupState = 'Active'
        $strSubreason = 'succeeded'

        if ($strSemantic -ceq 'helper.cleanup.unjournaled-entry') {
            [System.IO.File]::WriteAllBytes(
                [System.IO.Path]::Combine($objContext.CandidatePath, 'unexpected.bin'),
                [byte[]](0x78)
            )
            $strSubreason = 'candidate-cardinality'
        } elseif ($strSemantic -ceq 'helper.cleanup.link-substitution') {
            $objFileRecord = @($objContext.OwnershipJournal | Where-Object {
                $_.Kind -ceq 'CandidateFile'
            })[0]
            [System.IO.File]::Delete($objFileRecord.Path)
            $boolLinkCreated = & $script:scriptBlockNewSymbolicLink `
                -LinkPath $objFileRecord.Path `
                -TargetPath $hashtableLayout.SentinelFile `
                -Directory $false
            if (-not $boolLinkCreated) {
                $objObservation.AuthorizedSkip = $true
                $objObservation.SkipCode = 'skip-link-primitive-unavailable'
                return $objObservation
            }
            $strSubreason = 'candidate-identity'
        }

        if ($strSemantic -ceq 'helper.cleanup.terminal-initial-state') {
            # Every other row begins Active, so the terminal states were reachable
            # only as an outcome, never as an input. This row hands an already
            # terminal context to both entry points and requires each to answer
            # from the journal alone: no filesystem call, no re-inspection of
            # names the lifecycle has already released.
            # A terminal context is not automatically a valid one. CleanupFailed
            # admits ExpectedAbsent, Deleted, and RetainedUncertain records and
            # nothing else, because a surviving Created record would name an
            # entry that is owned and present on disk yet absent from the
            # retained-sequence report -- so nothing would remove it and nothing
            # would tell the operator it is there. This row forges exactly that
            # state and requires both entry points to refuse it from the journal
            # alone, touching no filesystem name the lifecycle has released.
            #
            # An earlier revision of this row disposed the context and re-called
            # both entry points, which exercised the already-disposed success
            # path instead. That proved the repeat was cheap, not that a
            # malformed terminal context is rejected, and it duplicated K-03.
            # Dispose normally first, so every field of the context is exactly
            # what production itself produced, then flip one record to a state
            # the reached lifecycle does not admit. Disposed admits only
            # ExpectedAbsent and Deleted, so Created violates the admitted-state
            # table and nothing else -- no required-state rule applies to
            # Disposed, and every other invariant still holds. That isolation is
            # the point: an earlier revision forged CleanupFailed with a Created
            # record, which tripped several checks at once, so removing any one
            # of them left the row still passing and it proved nothing.
            $objDispose = Remove-StyleGuideCandidateInvocationState -Context $objContext
            if (-not $objDispose.Success -or $objDispose.FinalState -cne 'Disposed') {
                & $script:scriptBlockStopHarness `
                    -Code 'fixture-failed' -Detail 'terminal-initial-dispose'
            }
            $objContext.OwnershipJournal[0].EntryState = 'Created'
            $objObservation.PreCleanupState = 'Disposed'
            $objHelperEntry = Remove-StyleGuideCandidateInvocationState -Context $objContext
            if ($objHelperEntry.Success -or
                $objHelperEntry.DiagnosticCode -cne 'cleanup-context-invalid' -or
                $objHelperEntry.FilesystemCallCount -ne [uint32]0) {
                & $script:scriptBlockStopHarness `
                    -Code 'fixture-failed' -Detail 'terminal-initial-helper-entry'
            }
            $objCleanupResult = Remove-StyleGuideCandidateInvocationContext -Context $objContext
            if ($objCleanupResult.Success -or
                $objCleanupResult.FilesystemCallCount -ne [uint32]0) {
                & $script:scriptBlockStopHarness `
                    -Code 'fixture-failed' -Detail 'terminal-initial-context-entry'
            }
            # Both entry points refused without touching the filesystem, which
            # means the candidate tree they declined to act on is still there.
            # Restoring the lifecycle value the forge overwrote makes the context
            # valid again so the real production cleanup can remove it; the
            # rejection above stays the recorded result. Without this the row
            # would have to declare a candidate final state no other row uses.
            $objContext.OwnershipJournal[0].EntryState = 'Deleted'
            $strSubreason = 'context-invalid'
        } elseif ($strSemantic -ceq 'helper.cleanup.disposed-repeat') {
            $objFirstCleanup = Remove-StyleGuideCandidateInvocationState -Context $objContext
            if (-not $objFirstCleanup.Success -or $objFirstCleanup.FinalState -cne 'Disposed') {
                & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'helper-first-cleanup'
            }
            $objObservation.PreCleanupState = 'Disposed'
            $objCleanupResult = Remove-StyleGuideCandidateInvocationState -Context $objContext
            $strSubreason = 'already-disposed'
        } else {
            $objCleanupResult = Remove-StyleGuideCandidateInvocationState -Context $objContext
        }

        & $script:scriptBlockSetCleanupObservation `
            -Observation $objObservation `
            -CleanupResult $objCleanupResult `
            -Subreason $strSubreason `
            -CleanupSequence 'helper-context' `
            -Context $objContext
        return $objObservation
    } finally {
        if (-not (& $script:scriptBlockTestSentinelIntact -Layout $hashtableLayout)) {
            $objObservation.SentinelState = 'changed'
        }
        & $script:scriptBlockRemoveTestTree `
            -LiteralPath $hashtableLayout.CaseRoot `
            -ApprovedParent $RunRoot
    }
}

$script:scriptBlockInvokeRequiredIdentityGit = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$GitPath,

        [Parameter(Mandatory = $true)]
        [string]$RepositoryRoot,

        [Parameter(Mandatory = $true)]
        [string[]]$ArgumentList
    )

    $objResult = & $script:scriptBlockInvokeNativeRaw `
        -FilePath $GitPath `
        -WorkingDirectory $RepositoryRoot `
        -ArgumentList $ArgumentList
    if ($objResult.ExitCode -ne 0) {
        & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'identity-git-command'
    }
    return $objResult
}

$script:scriptBlockNewIdentityRepository = {
    param (
        [Parameter(Mandatory = $true)]
        [System.Collections.IDictionary]$Layout,

        [Parameter(Mandatory = $true)]
        [string]$GitPath,

        [Parameter(Mandatory = $true)]
        [string]$HelperSourcePath,

        [Parameter(Mandatory = $true)]
        [string]$ContextSourcePath
    )

    $strRepositoryRoot = [System.IO.Path]::Combine($Layout.CaseRoot, 'identity-repository')
    $strWorkflowDirectory = [System.IO.Path]::Combine(
        $strRepositoryRoot,
        '.github',
        'workflows'
    )
    [void][System.IO.Directory]::CreateDirectory($strWorkflowDirectory)
    $strHelperPath = [System.IO.Path]::Combine(
        $strRepositoryRoot,
        $script:strCandidateHelperRelativePath.Replace('/', [System.IO.Path]::DirectorySeparatorChar)
    )
    $strContextPath = [System.IO.Path]::Combine(
        $strRepositoryRoot,
        $script:strCandidateContextRelativePath.Replace('/', [System.IO.Path]::DirectorySeparatorChar)
    )
    [System.IO.File]::WriteAllBytes(
        $strHelperPath,
        [System.IO.File]::ReadAllBytes($HelperSourcePath)
    )
    [System.IO.File]::WriteAllBytes(
        $strContextPath,
        [System.IO.File]::ReadAllBytes($ContextSourcePath)
    )
    [void](& $script:scriptBlockInvokeRequiredIdentityGit `
        -GitPath $GitPath -RepositoryRoot $strRepositoryRoot -ArgumentList @('init', '-q'))
    [void](& $script:scriptBlockInvokeRequiredIdentityGit `
        -GitPath $GitPath -RepositoryRoot $strRepositoryRoot `
        -ArgumentList @('config', 'user.name', 'PSStyleGuide Harness'))
    [void](& $script:scriptBlockInvokeRequiredIdentityGit `
        -GitPath $GitPath -RepositoryRoot $strRepositoryRoot `
        -ArgumentList @('config', 'user.email', 'harness@example.invalid'))
    [void](& $script:scriptBlockInvokeRequiredIdentityGit `
        -GitPath $GitPath -RepositoryRoot $strRepositoryRoot -ArgumentList @('add', '--', '.'))
    [void](& $script:scriptBlockInvokeRequiredIdentityGit `
        -GitPath $GitPath -RepositoryRoot $strRepositoryRoot `
        -ArgumentList @('commit', '-q', '-m', 'identity baseline'))
    $objBranchResult = & $script:scriptBlockInvokeRequiredIdentityGit `
        -GitPath $GitPath -RepositoryRoot $strRepositoryRoot `
        -ArgumentList @('branch', '--show-current')
    $strInitialBranch = & $script:scriptBlockGetTrimmedAsciiLine `
        -Bytes $objBranchResult.StandardOutput
    return [ordered]@{
        RepositoryRoot = $strRepositoryRoot
        HelperPath = $strHelperPath
        ContextPath = $strContextPath
        InitialBranch = $strInitialBranch
    }
}

$script:scriptBlockInvokeScriptIdentityFixture = {
    param (
        [Parameter(Mandatory = $true)]
        [object]$Case,

        [Parameter(Mandatory = $true)]
        [string]$RunRoot,

        [Parameter(Mandatory = $true)]
        [string]$GitPath,

        [Parameter(Mandatory = $true)]
        [string]$HelperSourcePath,

        [Parameter(Mandatory = $true)]
        [string]$ContextSourcePath
    )

    $objObservation = & $script:scriptBlockNewObservation
    $hashtableLayout = & $script:scriptBlockNewCaseFixtureLayout `
        -RunRoot $RunRoot `
        -CaseId $Case.CaseId
    try {
        $strSemantic = [string]$Case.SemanticCase
        $boolExpectedSuccess = $strSemantic -in @(
            'script.helper.provider-qualified-valid',
            'script.context.provider-qualified-valid'
        )
        $boolRejected = $false
        $objIdentityError = $null
        try {
            $hashtableRepository = & $script:scriptBlockNewIdentityRepository `
                -Layout $hashtableLayout `
                -GitPath $GitPath `
                -HelperSourcePath $HelperSourcePath `
                -ContextSourcePath $ContextSourcePath
            $boolHelperCase = $strSemantic.StartsWith(
                'script.helper.',
                [System.StringComparison]::Ordinal
            )
            $strLiteralPath = if ($boolHelperCase) {
                $hashtableRepository.HelperPath
            } else {
                $hashtableRepository.ContextPath
            }
            $strRelativePath = if ($boolHelperCase) {
                $script:strCandidateHelperRelativePath
            } else {
                $script:strCandidateContextRelativePath
            }
            $strExpectedVersion = if ($boolHelperCase) {
                $script:strCandidateExpectedHelperVersion
            } else {
                $script:strCandidateExpectedContextVersion
            }
            $uintFunctionCount = if ($boolHelperCase) { [uint32]1 } else { [uint32]3 }

            switch -Exact ($strSemantic) {
                'script.helper.path-missing' {
                    $strLiteralPath = [System.IO.Path]::Combine(
                        $hashtableRepository.RepositoryRoot,
                        'missing-helper.ps1'
                    )
                    $strRelativePath = 'missing-helper.ps1'
                }
                'script.context.path-missing' {
                    $strLiteralPath = [System.IO.Path]::Combine(
                        $hashtableRepository.RepositoryRoot,
                        'missing-context.ps1'
                    )
                    $strRelativePath = 'missing-context.ps1'
                }
                'script.helper.path-wildcard' {
                    [void](& $script:scriptBlockResolveFixedScriptClaim `
                        -Value ($strLiteralPath + '*') `
                        -Name 'HelperPath' `
                        -ExpectedPath $strLiteralPath)
                    return $objObservation
                }
                'script.context.path-wildcard' {
                    [void](& $script:scriptBlockResolveFixedScriptClaim `
                        -Value ($strLiteralPath + '*') `
                        -Name 'ContextManagerPath' `
                        -ExpectedPath $strLiteralPath)
                    return $objObservation
                }
                'script.helper.nonfilesystem-provider' {
                    [void](& $script:scriptBlockResolveFixedScriptClaim `
                        -Value 'Variable::PSStyleGuideCandidateFixture' `
                        -Name 'HelperPath' `
                        -ExpectedPath $strLiteralPath)
                    return $objObservation
                }
                'script.helper.raw-array' {
                    [void](& $script:scriptBlockResolveFixedScriptClaim `
                        -Value ([object[]]@($strLiteralPath)) `
                        -Name 'HelperPath' `
                        -ExpectedPath $strLiteralPath)
                    return $objObservation
                }
                'script.context.raw-object' {
                    [void](& $script:scriptBlockResolveFixedScriptClaim `
                        -Value ([pscustomobject]@{ Path = $strLiteralPath }) `
                        -Name 'ContextManagerPath' `
                        -ExpectedPath $strLiteralPath)
                    return $objObservation
                }
                'script.helper.link' {
                    $strLinkPath = [System.IO.Path]::Combine(
                        $hashtableRepository.RepositoryRoot,
                        'helper-link.ps1'
                    )
                    $boolLinkCreated = & $script:scriptBlockNewSymbolicLink `
                        -LinkPath $strLinkPath -TargetPath $strLiteralPath -Directory $false
                    if (-not $boolLinkCreated) {
                        $objObservation.AuthorizedSkip = $true
                        $objObservation.SkipCode = 'skip-link-primitive-unavailable'
                        return $objObservation
                    }
                    $strLiteralPath = $strLinkPath
                }
                'script.context.link' {
                    $strLinkPath = [System.IO.Path]::Combine(
                        $hashtableRepository.RepositoryRoot,
                        'context-link.ps1'
                    )
                    $boolLinkCreated = & $script:scriptBlockNewSymbolicLink `
                        -LinkPath $strLinkPath -TargetPath $strLiteralPath -Directory $false
                    if (-not $boolLinkCreated) {
                        $objObservation.AuthorizedSkip = $true
                        $objObservation.SkipCode = 'skip-link-primitive-unavailable'
                        return $objObservation
                    }
                    $strLiteralPath = $strLinkPath
                }
                'script.helper.provider-qualified-valid' {
                    $strLiteralPath = & $script:scriptBlockResolveFixedScriptClaim `
                        -Value ('FileSystem::' + $strLiteralPath) `
                        -Name 'HelperPath' `
                        -ExpectedPath $strLiteralPath
                }
                'script.context.provider-qualified-valid' {
                    $strLiteralPath = & $script:scriptBlockResolveFixedScriptClaim `
                        -Value ('Microsoft.PowerShell.Core\FileSystem::' + $strLiteralPath) `
                        -Name 'ContextManagerPath' `
                        -ExpectedPath $strLiteralPath
                }
                'script.helper.untracked' {
                    $strLiteralPath = [System.IO.Path]::Combine(
                        $hashtableRepository.RepositoryRoot,
                        'untracked-helper.ps1'
                    )
                    [System.IO.File]::WriteAllBytes(
                        $strLiteralPath,
                        [System.IO.File]::ReadAllBytes($HelperSourcePath)
                    )
                    $strRelativePath = 'untracked-helper.ps1'
                }
                'script.context.head-absent' {
                    [void](& $script:scriptBlockInvokeRequiredIdentityGit `
                        -GitPath $GitPath -RepositoryRoot $hashtableRepository.RepositoryRoot `
                        -ArgumentList @('rm', '--cached', '--', $strRelativePath))
                    [void](& $script:scriptBlockInvokeRequiredIdentityGit `
                        -GitPath $GitPath -RepositoryRoot $hashtableRepository.RepositoryRoot `
                        -ArgumentList @('commit', '-q', '-m', 'remove context from head'))
                    [void](& $script:scriptBlockInvokeRequiredIdentityGit `
                        -GitPath $GitPath -RepositoryRoot $hashtableRepository.RepositoryRoot `
                        -ArgumentList @('add', '--', $strRelativePath))
                }
                'script.helper.index-absent' {
                    [void](& $script:scriptBlockInvokeRequiredIdentityGit `
                        -GitPath $GitPath -RepositoryRoot $hashtableRepository.RepositoryRoot `
                        -ArgumentList @('rm', '--cached', '--', $strRelativePath))
                }
                'script.context.conflict-stage' {
                    [void](& $script:scriptBlockInvokeRequiredIdentityGit `
                        -GitPath $GitPath -RepositoryRoot $hashtableRepository.RepositoryRoot `
                        -ArgumentList @('checkout', '-q', '-b', 'identity-side'))
                    [System.IO.File]::WriteAllBytes($strLiteralPath, [byte[]](0x73, 0x0A))
                    [void](& $script:scriptBlockInvokeRequiredIdentityGit `
                        -GitPath $GitPath -RepositoryRoot $hashtableRepository.RepositoryRoot `
                        -ArgumentList @('add', '--', $strRelativePath))
                    [void](& $script:scriptBlockInvokeRequiredIdentityGit `
                        -GitPath $GitPath -RepositoryRoot $hashtableRepository.RepositoryRoot `
                        -ArgumentList @('commit', '-q', '-m', 'side context'))
                    [void](& $script:scriptBlockInvokeRequiredIdentityGit `
                        -GitPath $GitPath -RepositoryRoot $hashtableRepository.RepositoryRoot `
                        -ArgumentList @('checkout', '-q', $hashtableRepository.InitialBranch))
                    [System.IO.File]::WriteAllBytes($strLiteralPath, [byte[]](0x6D, 0x0A))
                    [void](& $script:scriptBlockInvokeRequiredIdentityGit `
                        -GitPath $GitPath -RepositoryRoot $hashtableRepository.RepositoryRoot `
                        -ArgumentList @('add', '--', $strRelativePath))
                    [void](& $script:scriptBlockInvokeRequiredIdentityGit `
                        -GitPath $GitPath -RepositoryRoot $hashtableRepository.RepositoryRoot `
                        -ArgumentList @('commit', '-q', '-m', 'main context'))
                    [void](& $script:scriptBlockInvokeNativeRaw `
                        -FilePath $GitPath `
                        -WorkingDirectory $hashtableRepository.RepositoryRoot `
                        -ArgumentList @('merge', '--no-edit', 'identity-side'))
                }
                'script.helper.staged-replacement' {
                    [System.IO.File]::WriteAllBytes($strLiteralPath, [byte[]](0x78, 0x0A))
                    [void](& $script:scriptBlockInvokeRequiredIdentityGit `
                        -GitPath $GitPath -RepositoryRoot $hashtableRepository.RepositoryRoot `
                        -ArgumentList @('add', '--', $strRelativePath))
                }
                'script.context.unstaged-replacement' {
                    [System.IO.File]::WriteAllBytes($strLiteralPath, [byte[]](0x78, 0x0A))
                }
                'script.helper.wrong-mode' {
                    [void](& $script:scriptBlockInvokeRequiredIdentityGit `
                        -GitPath $GitPath -RepositoryRoot $hashtableRepository.RepositoryRoot `
                        -ArgumentList @('update-index', '--chmod=+x', '--', $strRelativePath))
                    [void](& $script:scriptBlockInvokeRequiredIdentityGit `
                        -GitPath $GitPath -RepositoryRoot $hashtableRepository.RepositoryRoot `
                        -ArgumentList @('commit', '-q', '-m', 'wrong mode'))
                }
                'script.context.wrong-tree-type' {
                    [System.IO.File]::Delete($strLiteralPath)
                    [void][System.IO.Directory]::CreateDirectory($strLiteralPath)
                    [System.IO.File]::WriteAllBytes(
                        [System.IO.Path]::Combine($strLiteralPath, 'child'),
                        [byte[]](0x78)
                    )
                    [void](& $script:scriptBlockInvokeRequiredIdentityGit `
                        -GitPath $GitPath -RepositoryRoot $hashtableRepository.RepositoryRoot `
                        -ArgumentList @('add', '-A', '--', $strRelativePath))
                    [void](& $script:scriptBlockInvokeRequiredIdentityGit `
                        -GitPath $GitPath -RepositoryRoot $hashtableRepository.RepositoryRoot `
                        -ArgumentList @('commit', '-q', '-m', 'wrong tree type'))
                }
                'script.git.ls-tree-malformed' {
                    [void](& $script:scriptBlockGetCandidateTreeObjectId `
                        -Metadata ('100755 blob ' + ('0' * 40)) `
                        -ObjectIdLength 40)
                    return $objObservation
                }
                'script.git.ls-files-malformed' {
                    [void](& $script:scriptBlockGetCandidateIndexObjectId `
                        -Metadata ('100644 ' + ('0' * 40) + ' 1') `
                        -ObjectIdLength 40 `
                        -ExpectedObjectId ('0' * 40))
                    return $objObservation
                }
                'script.git.object-id-abbreviated' {
                    [void](& $script:scriptBlockAssertCandidateWorkingObjectId `
                        -ObjectId ('0' * 12) `
                        -ObjectIdLength 40 `
                        -ExpectedObjectId ('0' * 40))
                    return $objObservation
                }
                'script.git.object-id-wrong-format' {
                    [void](& $script:scriptBlockAssertCandidateWorkingObjectId `
                        -ObjectId ('0' * 64) `
                        -ObjectIdLength 40 `
                        -ExpectedObjectId ('0' * 40))
                    return $objObservation
                }
                'script.git.native-status-failure' {
                    $strLiteralPath = $HelperSourcePath
                    $strRelativePath = $script:strCandidateHelperRelativePath
                    $hashtableRepository.RepositoryRoot = $hashtableLayout.CaseRoot
                }
                'script.git.hostile-literal-substitution' {
                    $arrHostileRecord = [System.Text.Encoding]::ASCII.GetBytes(
                        '100644 blob ' + ('0' * 40) + "`thostile.ps1`0"
                    )
                    [void](& $script:scriptBlockSplitOneNulGitRecord `
                        -Bytes $arrHostileRecord `
                        -ExpectedPathBytes ([System.Text.Encoding]::ASCII.GetBytes($strRelativePath)))
                    return $objObservation
                }
                default {}
            }

            [void](& $script:scriptBlockAssertTrackedScriptIdentity `
                -RepositoryRoot $hashtableRepository.RepositoryRoot `
                -GitPath $GitPath `
                -LiteralPath $strLiteralPath `
                -RelativePath $strRelativePath `
                -ExpectedVersion $strExpectedVersion `
                -ExpectedFunctionCount $uintFunctionCount)
        } catch {
            $boolRejected = $true
            $objIdentityError = $_
        }

        # An expected rejection is satisfied only by the refusal that case
        # exists to prove. A fixture-failed error from repository setup or
        # mutation, or any unrelated exception, reaches the same catch, and
        # relabelling it as the intended rejection lets the case pass without
        # exercising the check at all. Five semantics are refused by the raw
        # path grammar before any Git work and so carry 'parameter'; every
        # other identity semantic must reach the identity proof itself.
        if ($boolRejected) {
            $strRequiredHarnessCode = switch -CaseSensitive ($strSemantic) {
                'script.helper.path-wildcard' { 'parameter' }
                'script.context.path-wildcard' { 'parameter' }
                'script.helper.nonfilesystem-provider' { 'parameter' }
                'script.helper.raw-array' { 'parameter' }
                'script.context.raw-object' { 'parameter' }
                default { 'script-identity-invalid' }
            }
            $strObservedHarnessCode = ''
            if ($null -ne $objIdentityError.Exception -and
                $null -ne $objIdentityError.Exception.Data -and
                $objIdentityError.Exception.Data.Contains('PSStyleGuideHarnessCode')) {
                $objObservedCode = $objIdentityError.Exception.Data['PSStyleGuideHarnessCode']
                if ($null -ne $objObservedCode -and
                    $objObservedCode.GetType() -eq [System.String]) {
                    $strObservedHarnessCode = [string]$objObservedCode
                }
            }
            if ($strObservedHarnessCode -cne $strRequiredHarnessCode) {
                throw $objIdentityError
            }
        }

        if ($boolExpectedSuccess -and $boolRejected) {
            throw $objIdentityError
        }
        if (-not $boolExpectedSuccess -and -not $boolRejected) {
            & $script:scriptBlockStopHarness -Code 'fixture-failed' -Detail 'identity-accepted'
        }

        $objObservation.Result = if ($boolExpectedSuccess) { 'success' } else { 'rejection' }
        $objObservation.Status = if ($boolExpectedSuccess) { 'succeeded' } else { 'failed' }
        $objObservation.Phase = 'identity'
        $objObservation.Subreason = $strSemantic.Substring('script.'.Length).Replace('.', '-')
        $objObservation.DiagnosticCode = if ($boolExpectedSuccess) {
            'none'
        } else {
            'script-identity-invalid'
        }
        return $objObservation
    } finally {
        if (-not (& $script:scriptBlockTestSentinelIntact -Layout $hashtableLayout)) {
            $objObservation.SentinelState = 'changed'
        }
        & $script:scriptBlockRemoveTestTree `
            -LiteralPath $hashtableLayout.CaseRoot `
            -ApprovedParent $RunRoot
    }
}

function Invoke-StyleGuideCandidateHarness {
    # .SYNOPSIS
    # Executes the fixed 115-case style-guide candidate harness.
    #
    # .DESCRIPTION
    # Authenticates the fixed production scripts, loads their public functions,
    # executes every catalog row once for the current runtime, emits canonical
    # JSONL evidence, and fails if any result or required primitive differs
    # from its singular oracle.
    #
    # .EXAMPLE
    # Invoke-StyleGuideCandidateHarness
    #
    # # Emits exactly one canonical JSON object for every catalog row.
    #
    # .EXAMPLE
    # $arrCaseJson = @(Invoke-StyleGuideCandidateHarness)
    #
    # # Captures the complete canonical JSONL projection for further validation.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [string] One canonical JSON object per style-guide candidate case.
    #
    # .NOTES
    # This function consumes only the fixed script parameters and repository
    # paths established by the enclosing trusted harness.
    #
    # Version: 1.0.20260808.2
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param ()

    Set-StrictMode -Version Latest

    $strRepositoryRoot = [System.IO.Path]::GetFullPath(
        [System.IO.Path]::Combine($PSScriptRoot, '..', '..')
    )
    [void](& $script:scriptBlockAssertOrdinaryDirectoryEnvelope `
        -LiteralPath $strRepositoryRoot)
    $strExpectedHelperPath = [System.IO.Path]::GetFullPath(
        [System.IO.Path]::Combine(
            $strRepositoryRoot,
            $script:strCandidateHelperRelativePath.Replace(
                '/',
                [System.IO.Path]::DirectorySeparatorChar
            )
        )
    )
    $strExpectedContextPath = [System.IO.Path]::GetFullPath(
        [System.IO.Path]::Combine(
            $strRepositoryRoot,
            $script:strCandidateContextRelativePath.Replace(
                '/',
                [System.IO.Path]::DirectorySeparatorChar
            )
        )
    )
    $strCatalogPath = [System.IO.Path]::GetFullPath(
        [System.IO.Path]::Combine(
            $strRepositoryRoot,
            $script:strCandidateCatalogRelativePath.Replace(
                '/',
                [System.IO.Path]::DirectorySeparatorChar
            )
        )
    )
    $strHelperLiteralPath = & $script:scriptBlockResolveFixedScriptClaim `
        -Value $script:objCandidateHelperPathClaim `
        -Name 'HelperPath' `
        -ExpectedPath $strExpectedHelperPath
    $strContextLiteralPath = & $script:scriptBlockResolveFixedScriptClaim `
        -Value $script:objCandidateContextManagerPathClaim `
        -Name 'ContextManagerPath' `
        -ExpectedPath $strExpectedContextPath

    # Git is the root of this harness's trust: every HEAD, index, mode, and
    # working-object claim below is whatever this binary says it is. Resolving
    # it through PATH made that root as movable as PATH, and PATH is not a
    # trusted input. Get-Command -CommandType Application closes command
    # *precedence* -- no alias or function can shadow the name -- but -All
    # returns PATH order, so element zero is simply the earliest PATH match. On
    # a GitHub-hosted runner any earlier step, composite action, or third-party
    # action becomes that match by appending one line to $env:GITHUB_PATH,
    # which the platform documents as "Prepends a directory to the system PATH
    # variable and automatically makes it available to all subsequent actions
    # in the current job." No compromise is required, and a benign action that
    # ships its own bin directory would silently author the identity proof.
    #
    # Reproduced before this change: a shell script named git placed on PATH
    # resolved as element zero and passed through to the real binary
    # convincingly enough to look ordinary.
    #
    # The fixed locations below are read through GetFolderPath rather than
    # %ProgramFiles% so the Windows list does not depend on another environment
    # variable. What remains trusted is the resolved file itself: an attacker
    # who can write /usr/bin/git or the Program Files copy already owns the
    # runner, and no check here would survive that.
    $arrGitCandidatePath = if ($script:boolCandidateIsWindows) {
        $strProgramFiles = [System.Environment]::GetFolderPath(
            [System.Environment+SpecialFolder]::ProgramFiles)
        $strProgramFilesX86 = [System.Environment]::GetFolderPath(
            [System.Environment+SpecialFolder]::ProgramFilesX86)
        [string[]]@(
            [System.IO.Path]::Combine($strProgramFiles, 'Git', 'cmd', 'git.exe'),
            [System.IO.Path]::Combine($strProgramFiles, 'Git', 'bin', 'git.exe'),
            [System.IO.Path]::Combine($strProgramFilesX86, 'Git', 'cmd', 'git.exe'),
            [System.IO.Path]::Combine($strProgramFilesX86, 'Git', 'bin', 'git.exe')
        )
    } else {
        [string[]]@('/usr/bin/git', '/bin/git', '/usr/local/bin/git')
    }
    $strGitPath = ''
    foreach ($strGitCandidate in $arrGitCandidatePath) {
        if ($strGitCandidate.Length -eq 0) {
            continue
        }
        try {
            $objGitAttributes = [System.IO.File]::GetAttributes($strGitCandidate)
        } catch {
            continue
        }
        if (($objGitAttributes -band [System.IO.FileAttributes]::Directory) -ne 0) {
            continue
        }
        $strGitPath = [string]$strGitCandidate
        break
    }
    if ($strGitPath.Length -eq 0) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'git-missing'
    }
    $hashtableHelperEvidenceBefore = & $script:scriptBlockGetFileEvidence `
        -LiteralPath $strHelperLiteralPath
    $hashtableContextEvidenceBefore = & $script:scriptBlockGetFileEvidence `
        -LiteralPath $strContextLiteralPath
    $hashtableCatalogEvidenceBefore = & $script:scriptBlockGetFileEvidence `
        -LiteralPath $strCatalogPath

    [void](& $script:scriptBlockAssertTrackedScriptIdentity `
        -RepositoryRoot $strRepositoryRoot `
        -GitPath $strGitPath `
        -LiteralPath $strHelperLiteralPath `
        -RelativePath $script:strCandidateHelperRelativePath `
        -ExpectedVersion $script:strCandidateExpectedHelperVersion `
        -ExpectedFunctionCount ([uint32]1))
    [void](& $script:scriptBlockAssertTrackedScriptIdentity `
        -RepositoryRoot $strRepositoryRoot `
        -GitPath $strGitPath `
        -LiteralPath $strContextLiteralPath `
        -RelativePath $script:strCandidateContextRelativePath `
        -ExpectedVersion $script:strCandidateExpectedContextVersion `
        -ExpectedFunctionCount ([uint32]3))

    # The catalog is the oracle. Authenticate it against HEAD, the index, and the
    # no-filter working object before consuming a single expectation, exactly as
    # the two production scripts are authenticated. The allocation hash binds only
    # case IDs, semantic names, and profile names, so without this a staged or
    # unstaged catalog edit could rewrite expected diagnostics, states, counts, or
    # closed sets and still be accepted as the oracle.
    [void](& $script:scriptBlockAssertTrackedBlobIdentity `
        -RepositoryRoot $strRepositoryRoot `
        -GitPath $strGitPath `
        -LiteralPath $strCatalogPath `
        -RelativePath $script:strCandidateCatalogRelativePath)
    $objCatalog = & $script:scriptBlockReadCandidateCatalog -LiteralPath $strCatalogPath
    [void](& $script:scriptBlockAssertProductionTaxonomyClosed `
        -Catalog $objCatalog `
        -LiteralPath ([string[]]@($strHelperLiteralPath, $strContextLiteralPath)))
    [void](& $script:scriptBlockAssertProductionValidateSetsClosed `
        -Catalog $objCatalog `
        -HelperLiteralPath $strHelperLiteralPath `
        -ContextLiteralPath $strContextLiteralPath)
    [void](& $script:scriptBlockAssertVersionMarkersConsistent `
        -LiteralPath $strHelperLiteralPath `
        -ExpectedVersion $script:strCandidateExpectedHelperVersion `
        -ExpectedFunctionCount ([uint32]1) `
        -OwnVersionVariableName 'script:versionCandidateHelper' `
        -VersionConstantMap @{
            'script:versionCandidateHelper' =
                $script:strCandidateExpectedHelperVersion
            'script:versionCandidateExpectedContext' =
                $script:strCandidateExpectedContextVersion
        })
    [void](& $script:scriptBlockAssertVersionMarkersConsistent `
        -LiteralPath $strContextLiteralPath `
        -ExpectedVersion $script:strCandidateExpectedContextVersion `
        -ExpectedFunctionCount ([uint32]3) `
        -OwnVersionVariableName 'versionCandidateContext' `
        -VersionConstantMap @{
            'versionCandidateContext' =
                $script:strCandidateExpectedContextVersion
        })
    [void](& $script:scriptBlockAssertResourceGuardsWired -LiteralPath $strHelperLiteralPath)
    [void](& $script:scriptBlockAssertContextReadsAreCaptured `
        -LiteralPath $strHelperLiteralPath)
    $arrContextLoadOutput = @(. $strContextLiteralPath)
    if ($arrContextLoadOutput.Count -ne 0) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'context-load-output'
    }
    $arrHelperLoadOutput = @(. $strHelperLiteralPath)
    if ($arrHelperLoadOutput.Count -ne 0) {
        & $script:scriptBlockStopHarness -Code 'script-identity-invalid' -Detail 'helper-load-output'
    }
    foreach ($strFunctionName in @(
        'New-StyleGuideCandidateInvocationContext',
        'Remove-StyleGuideCandidateInvocationContext',
        'Remove-StyleGuideCandidateInvocationState'
    )) {
        $arrFunctions = @(Get-Command -Name $strFunctionName -CommandType Function -All)
        if ($arrFunctions.Count -ne 1) {
            & $script:scriptBlockStopHarness `
                -Code 'script-identity-invalid' `
                -Detail 'loaded-function-cardinality'
        }
    }

    $strOperatingSystem = if ($script:boolCandidateIsWindows) { 'Windows' } else { 'Linux' }
    $strPowerShellEdition = if ($PSVersionTable.PSEdition -eq 'Desktop') {
        'Desktop'
    } else {
        'Core'
    }
    $versionPowerShell = [System.Version]$PSVersionTable.PSVersion
    $strRequiredRuntime = if ($strOperatingSystem -ceq 'Windows' -and
        $strPowerShellEdition -ceq 'Desktop') {
        'WindowsPowerShell5.1'
    } elseif ($strOperatingSystem -ceq 'Windows' -and
        $strPowerShellEdition -ceq 'Core') {
        'PowerShell7Windows'
    } elseif ($strOperatingSystem -ceq 'Linux' -and
        $strPowerShellEdition -ceq 'Core') {
        'PowerShell7Ubuntu'
    } else {
        & $script:scriptBlockStopHarness -Code 'orchestration-failed' -Detail 'unsupported-runtime'
    }
    $strTemporaryParent = [System.IO.Path]::GetFullPath([System.IO.Path]::GetTempPath())
    [void](& $script:scriptBlockAssertOrdinaryDirectoryEnvelope `
        -LiteralPath $strTemporaryParent)
    if ($strTemporaryParent.StartsWith(
        $strRepositoryRoot.TrimEnd(
            [System.IO.Path]::DirectorySeparatorChar,
            [System.IO.Path]::AltDirectorySeparatorChar
        ) + [System.IO.Path]::DirectorySeparatorChar,
        $script:objCandidatePathComparison
    )) {
        & $script:scriptBlockStopHarness -Code 'orchestration-failed' -Detail 'temporary-inside-repository'
    }
    $strRunRoot = [System.IO.Path]::Combine(
        $strTemporaryParent,
        'psstyleguide-candidate-' + [System.IO.Path]::GetRandomFileName()
    )
    if ([System.IO.Directory]::Exists($strRunRoot) -or [System.IO.File]::Exists($strRunRoot)) {
        & $script:scriptBlockStopHarness -Code 'orchestration-failed' -Detail 'run-root-collision'
    }
    [void][System.IO.Directory]::CreateDirectory($strRunRoot)

    $uintPassCount = [uint32]0
    $uintFailCount = [uint32]0
    $uintSkipCount = [uint32]0
    $objExecutedCaseIds = New-Object 'System.Collections.Generic.HashSet[string]' (
        [System.StringComparer]::Ordinal
    )
    $objExecutedLinkCategories = New-Object 'System.Collections.Generic.HashSet[string]' (
        [System.StringComparer]::Ordinal
    )
    try {
        & $script:scriptBlockAssertCatalogMutationsRejected `
            -Catalog $objCatalog `
            -RunRoot $strRunRoot
        & $script:scriptBlockAssertEnumerationBoundsDeclared `
            -HelperLiteralPath $strHelperLiteralPath `
            -ContextLiteralPath $strContextLiteralPath
        & $script:scriptBlockAssertEnumerationPrimitiveExclusive `
            -HelperLiteralPath $strHelperLiteralPath `
            -ContextLiteralPath $strContextLiteralPath
        & $script:scriptBlockAssertArchiveLengthReadOnce `
            -HelperLiteralPath $strHelperLiteralPath
        & $script:scriptBlockAssertStaticMembersResolve `
            -HelperLiteralPath $strHelperLiteralPath `
            -ContextLiteralPath $strContextLiteralPath
        & $script:scriptBlockAssertDownloadPathProvenance `
            -HelperLiteralPath $strHelperLiteralPath
        & $script:scriptBlockAssertRegularFileProofExecutes `
            -RunRoot $strRunRoot `
            -HelperLiteralPath $strHelperLiteralPath `
            -ContextLiteralPath $strContextLiteralPath
        & $script:scriptBlockAssertJournalSwapRefused -RunRoot $strRunRoot
        & $script:scriptBlockAssertRetainedSequenceFromCapture -RunRoot $strRunRoot
        & $script:scriptBlockAssertOrdinaryFileProofWired `
            -LiteralPath $strHelperLiteralPath
        & $script:scriptBlockAssertRound63JournalPlanWired `
            -LiteralPath $strHelperLiteralPath
        & $script:scriptBlockAssertCandidateRecordUnchangedRefused
        & $script:scriptBlockAssertPreexistingRecordReproofRefused -RunRoot $strRunRoot
        & $script:scriptBlockAssertDownloadLeafGuardExecutes `
            -HelperLiteralPath $strHelperLiteralPath `
            -RunRoot $strRunRoot
        & $script:scriptBlockAssertLifecycleRecordStatesRejected -RunRoot $strRunRoot `
            -HelperLiteralPath $strHelperLiteralPath
        & $script:scriptBlockAssertRound73RegisterLeakDeregistered -RunRoot $strRunRoot `
            -ContextLiteralPath $strContextLiteralPath
        & $script:scriptBlockAssertRound73RefusedWriteToleranceNarrow -RunRoot $strRunRoot
        & $script:scriptBlockAssertResourceGuardsReached `
            -LiteralPath $strHelperLiteralPath `
            -RunRoot $strRunRoot
        & $script:scriptBlockAssertArchiveTrailerAgreementEnforced `
            -LiteralPath $strHelperLiteralPath `
            -RunRoot $strRunRoot
        & $script:scriptBlockAssertDirectoryReadsBounded `
            -LiteralPath $strHelperLiteralPath `
            -ContextLiteralPath $strContextLiteralPath `
            -RunRoot $strRunRoot
        & $script:scriptBlockAssertUnauthorizedSkipsRejected `
            -Catalog $objCatalog `
            -OperatingSystem $strOperatingSystem `
            -PowerShellEdition $strPowerShellEdition `
            -PowerShellVersion $versionPowerShell
        foreach ($objCase in $objCatalog.Cases) {
            if (-not $objExecutedCaseIds.Add([string]$objCase.CaseId)) {
                & $script:scriptBlockStopHarness -Code 'catalog-invalid' -Detail 'duplicate-execution'
            }
            if ($strRequiredRuntime -cnotin @($objCase.RequiredRuntimes)) {
                & $script:scriptBlockStopHarness `
                    -Code 'orchestration-failed' `
                    -Detail 'case-runtime-undeclared'
            }

            [void](& $script:scriptBlockAssertTrackedScriptIdentity `
                -RepositoryRoot $strRepositoryRoot `
                -GitPath $strGitPath `
                -LiteralPath $strHelperLiteralPath `
                -RelativePath $script:strCandidateHelperRelativePath `
                -ExpectedVersion $script:strCandidateExpectedHelperVersion `
                -ExpectedFunctionCount ([uint32]1))
            [void](& $script:scriptBlockAssertTrackedScriptIdentity `
                -RepositoryRoot $strRepositoryRoot `
                -GitPath $strGitPath `
                -LiteralPath $strContextLiteralPath `
                -RelativePath $script:strCandidateContextRelativePath `
                -ExpectedVersion $script:strCandidateExpectedContextVersion `
                -ExpectedFunctionCount ([uint32]3))

            $objObservation = $null
            $boolApplicable = $objCase.Applicability -ceq 'All' -or
                $objCase.Applicability -ceq $strOperatingSystem
            if (-not $boolApplicable) {
                $objObservation = & $script:scriptBlockNewObservation
                $objObservation.AuthorizedSkip = $true
                $objObservation.SkipCode = 'skip-opposite-platform'
            } else {
                try {
                    if ($objCase.SemanticCase.StartsWith(
                        'script.',
                        [System.StringComparison]::Ordinal
                    )) {
                        $objObservation = & $script:scriptBlockInvokeScriptIdentityFixture `
                            -Case $objCase `
                            -RunRoot $strRunRoot `
                            -GitPath $strGitPath `
                            -HelperSourcePath $strHelperLiteralPath `
                            -ContextSourcePath $strContextLiteralPath
                    } elseif ($objCase.SemanticCase.StartsWith(
                        'context.cleanup.',
                        [System.StringComparison]::Ordinal
                    )) {
                        $objObservation = & $script:scriptBlockInvokeContextCleanupFixture `
                            -Case $objCase `
                            -RunRoot $strRunRoot `
                            -HelperLiteralPath $strHelperLiteralPath
                    } elseif ($objCase.SemanticCase.StartsWith(
                        'helper.cleanup.',
                        [System.StringComparison]::Ordinal
                    )) {
                        $objObservation = & $script:scriptBlockInvokeHelperCleanupFixture `
                            -Case $objCase `
                            -RunRoot $strRunRoot `
                            -HelperLiteralPath $strHelperLiteralPath
                    } else {
                        $objObservation = & $script:scriptBlockInvokeExpansionFixture `
                            -Case $objCase `
                            -RunRoot $strRunRoot `
                            -HelperLiteralPath $strHelperLiteralPath
                    }
                } catch {
                    $objObservation = & $script:scriptBlockNewObservation
                }
            }

            if (-not $objObservation.AuthorizedSkip) {
                $strLinkCategory = switch -Exact ($objCase.SemanticCase) {
                    'environment.checkout.link-component' { 'root' }
                    'environment.trusted.link-component' { 'root' }
                    'download.entry.link' { 'below-root' }
                    'candidate.preexisting.live-link' { 'candidate' }
                    'helper.cleanup.link-substitution' { 'candidate' }
                    'context.cleanup.link-substitution' { 'context' }
                    default { $null }
                }
                if ($null -ne $strLinkCategory) {
                    [void]$objExecutedLinkCategories.Add($strLinkCategory)
                }
            }

            $objResult = & $script:scriptBlockNewCaseResult `
                -Case $objCase `
                -Observation $objObservation `
                -OperatingSystem $strOperatingSystem `
                -PowerShellEdition $strPowerShellEdition `
                -PowerShellVersion $versionPowerShell
            switch -Exact ($objResult.HarnessVerdict) {
                'pass' { $uintPassCount++ }
                'fail' { $uintFailCount++ }
                'skip' { $uintSkipCount++ }
                default {
                    & $script:scriptBlockStopHarness `
                        -Code 'orchestration-failed' `
                        -Detail 'result-verdict'
                }
            }
            Write-Output (& $script:scriptBlockConvertToCanonicalCaseJson -Result $objResult)
        }

        if ($objExecutedCaseIds.Count -ne $script:intCandidateCaseCount -or
            [uint32]($uintPassCount + $uintFailCount + $uintSkipCount) -ne
                [uint32]$script:intCandidateCaseCount) {
            & $script:scriptBlockStopHarness -Code 'orchestration-failed' -Detail 'result-total'
        }
        foreach ($strRequiredLinkCategory in @('root', 'below-root', 'candidate', 'context')) {
            if (-not $objExecutedLinkCategories.Contains($strRequiredLinkCategory)) {
                & $script:scriptBlockStopHarness `
                    -Code 'orchestration-failed' `
                    -Detail 'required-link-coverage'
            }
        }

        [void](& $script:scriptBlockAssertTrackedScriptIdentity `
            -RepositoryRoot $strRepositoryRoot `
            -GitPath $strGitPath `
            -LiteralPath $strHelperLiteralPath `
            -RelativePath $script:strCandidateHelperRelativePath `
            -ExpectedVersion $script:strCandidateExpectedHelperVersion `
            -ExpectedFunctionCount ([uint32]1))
        [void](& $script:scriptBlockAssertTrackedScriptIdentity `
            -RepositoryRoot $strRepositoryRoot `
            -GitPath $strGitPath `
            -LiteralPath $strContextLiteralPath `
            -RelativePath $script:strCandidateContextRelativePath `
            -ExpectedVersion $script:strCandidateExpectedContextVersion `
            -ExpectedFunctionCount ([uint32]3))
        $hashtableHelperEvidenceAfter = & $script:scriptBlockGetFileEvidence `
            -LiteralPath $strHelperLiteralPath
        $hashtableContextEvidenceAfter = & $script:scriptBlockGetFileEvidence `
            -LiteralPath $strContextLiteralPath
        $hashtableCatalogEvidenceAfter = & $script:scriptBlockGetFileEvidence `
            -LiteralPath $strCatalogPath
        foreach ($strEvidenceName in @('Length', 'Sha256')) {
            if ($hashtableHelperEvidenceBefore[$strEvidenceName] -cne
                    $hashtableHelperEvidenceAfter[$strEvidenceName] -or
                $hashtableContextEvidenceBefore[$strEvidenceName] -cne
                    $hashtableContextEvidenceAfter[$strEvidenceName] -or
                $hashtableCatalogEvidenceBefore[$strEvidenceName] -cne
                    $hashtableCatalogEvidenceAfter[$strEvidenceName]) {
                & $script:scriptBlockStopHarness `
                    -Code 'orchestration-failed' `
                    -Detail 'source-state-changed'
            }
        }
        Write-Output (& $script:scriptBlockConvertToCanonicalEnvelopeJson `
                -HelperEvidence $hashtableHelperEvidenceAfter `
                -ContextEvidence $hashtableContextEvidenceAfter `
                -CatalogEvidence $hashtableCatalogEvidenceAfter)

        if ($uintFailCount -ne 0) {
            & $script:scriptBlockStopHarness -Code 'orchestration-failed' -Detail 'case-failure'
        }
    } finally {
        & $script:scriptBlockRemoveTestTree `
            -LiteralPath $strRunRoot `
            -ApprovedParent $strTemporaryParent
    }
}

try {
    Invoke-StyleGuideCandidateHarness
} catch {
    Write-Error -ErrorRecord $_
    exit 1
}
