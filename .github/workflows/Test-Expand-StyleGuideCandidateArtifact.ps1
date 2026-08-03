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
Version: 1.0.20260803.13
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

$script:versionCandidateHarness = [System.Version]'1.0.20260803.13'
$script:objCandidateHelperPathClaim = $HelperPath
$script:objCandidateContextManagerPathClaim = $ContextManagerPath
$script:strCandidateExpectedHelperVersion = '1.0.20260803.10'
$script:strCandidateExpectedContextVersion = '1.0.20260803.4'
$script:strCandidateCatalogVersion = '1.0.20260803.2'
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
        $objStandardOutputTask = $objProcess.StandardOutput.BaseStream.CopyToAsync(
            $objStandardOutputStream
        )
        $objStandardErrorTask = $objProcess.StandardError.BaseStream.CopyToAsync(
            $objStandardErrorStream
        )
        $objProcess.WaitForExit()
        [System.Threading.Tasks.Task]::WaitAll(@(
            $objStandardOutputTask,
            $objStandardErrorTask
        ))
        if ($objStandardOutputStream.Length -gt 4194304 -or
            $objStandardErrorStream.Length -gt 4194304) {
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
        [uint32]$ExpectedFunctionCount
    )

    # Each production script states its version in three places: the help
    # block's Version line, the constant the code compares against, and a
    # comment inside every public function. Nothing keeps them equal but the
    # hand that edits them, and in this review loop that hand has missed one
    # three separate times -- each caught downstream as a puzzling symptom
    # rather than as what it was.
    #
    # The harness already knows the version it expects, so requiring every
    # marker in the file to equal it costs one pass over the text and turns a
    # recurring editing slip into an immediate, named failure. Any version
    # literal anywhere in the file that is not the expected one is a
    # desynchronisation, so no marker can be added without being covered.
    $strText = [System.IO.File]::ReadAllText($LiteralPath)
    $arrMatch = @([System.Text.RegularExpressions.Regex]::Matches(
        $strText,
        '\b\d+\.\d+\.\d{8}\.\d+\b'
    ))
    $intExpectedMarker = 0
    foreach ($objMatch in $arrMatch) {
        if ($objMatch.Value -ceq $ExpectedVersion) {
            $intExpectedMarker++
            continue
        }
        # A version literal that is not this file's own is only legitimate when
        # it names the other script this one is pinned to, which the harness
        # verifies separately. Anything else is a stale marker.
        if ($objMatch.Value -cne $script:strCandidateExpectedHelperVersion -and
            $objMatch.Value -cne $script:strCandidateExpectedContextVersion) {
            & $script:scriptBlockStopHarness `
                -Code 'script-identity-invalid' -Detail 'version-marker'
        }
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
            param ($objNode)
            $objNode -is [System.Management.Automation.Language.CommandAst]
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
                param ($objNode)
                $objNode -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                    $objNode.Left -is
                        [System.Management.Automation.Language.VariableExpressionAst] -and
                    $objNode.Left.VariablePath.UserPath -ceq ('script:' + $strGuardName)
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
                param ($objNode)
                $objNode -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                    $objNode.Left -is
                        [System.Management.Automation.Language.VariableExpressionAst] -and
                    $objNode.Left.VariablePath.UserPath -ceq ('script:' + $strGuardName)
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
    $arrUnbounded = [string[]]@(& $script:scriptBlockGetCandidateHelperEntry `
            -LiteralPath $strCrowded -Phase 'download')
    if ($arrBounded.Count -ne 2 -or $arrUnbounded.Count -ne $intSeeded) {
        & $script:scriptBlockStopHarness `
            -Code 'catalog-invalid' -Detail 'bounded-directory-read'
    }
    $arrContextBounded = [string[]]@(& $scriptBlockGetCandidateImmediateEntry `
            -LiteralPath $strCrowded -FailureCode 'root-invalid' `
            -FailurePhase 'root' -MaximumEntry 1)
    $arrContextUnbounded = [string[]]@(& $scriptBlockGetCandidateImmediateEntry `
            -LiteralPath $strCrowded -FailureCode 'root-invalid' -FailurePhase 'root')
    if ($arrContextBounded.Count -ne 1 -or $arrContextUnbounded.Count -ne $intSeeded) {
        & $script:scriptBlockStopHarness `
            -Code 'catalog-invalid' -Detail 'bounded-directory-read'
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

    # Exact counts, not minimums. A minimum would let one bound be dropped as
    # soon as another was added elsewhere, which is the failure this is for.
    # The cost is that a legitimate new bounded read has to be recorded here --
    # the same deliberate step the version markers require, and it has already
    # caught one addition that would otherwise have slipped past unrecorded.
    $hashtableBoundedSite = [ordered]@{
        $LiteralPath = [int]4
        $ContextLiteralPath = [int]4
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
                    param ($objNode)
                    if ($objNode -isnot
                        [System.Management.Automation.Language.CommandAst]) {
                        return $false
                    }
                    $boolNamed = $false
                    foreach ($objElement in $objNode.CommandElements) {
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
                param ($objNode)
                $objNode -is [System.Management.Automation.Language.AssignmentStatementAst] -and
                $objNode.Left.Extent.Text -ceq ('$script:' + $strGuardName) -and
                $objNode.Right -is
                    [System.Management.Automation.Language.CommandExpressionAst] -and
                $objNode.Right.Expression -is
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

$script:scriptBlockAssertLifecycleRecordStatesRejected = {
    param (
        [Parameter(Mandatory = $true)]
        [string]$RunRoot
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
            $objContext.LifecycleState = [string]$hashtableScenario.LifecycleState

            $objResult = & $strEntryPoint -Context $objContext
            if ($objResult.DiagnosticCode -cne $hashtableScenario.ExpectedDiagnosticCode -or
                $objResult.FilesystemCallCount -ne [uint32]0) {
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
        param ($objNode)
        $objNode -is [System.Management.Automation.Language.FunctionDefinitionAst]
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
            $uintFunctionCount = if ($boolHelperCase) { [uint32]1 } else { [uint32]2 }

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
    # Version: 1.0.20260803.13
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
        -ExpectedFunctionCount ([uint32]2))

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
    [void](& $script:scriptBlockAssertVersionMarkersConsistent `
        -LiteralPath $strHelperLiteralPath `
        -ExpectedVersion $script:strCandidateExpectedHelperVersion `
        -ExpectedFunctionCount ([uint32]1))
    [void](& $script:scriptBlockAssertVersionMarkersConsistent `
        -LiteralPath $strContextLiteralPath `
        -ExpectedVersion $script:strCandidateExpectedContextVersion `
        -ExpectedFunctionCount ([uint32]2))
    [void](& $script:scriptBlockAssertResourceGuardsWired -LiteralPath $strHelperLiteralPath)
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
        & $script:scriptBlockAssertLifecycleRecordStatesRejected -RunRoot $strRunRoot
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
                -ExpectedFunctionCount ([uint32]2))

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
            -ExpectedFunctionCount ([uint32]2))
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
