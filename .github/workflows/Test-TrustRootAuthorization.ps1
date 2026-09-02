# .SYNOPSIS
# Validates one exact trust-root maintenance candidate as inert Git data.
# .DESCRIPTION
# Reads the authorization manifest only from the authenticated trusted revision.
# Candidate blobs are decoded and parsed, but never sourced, imported, invoked,
# built, installed, or executed.
# .PARAMETER RepositoryRootPath
# The trusted repository worktree.
# .PARAMETER TrustedRevision
# The exact checked-out default-branch commit that owns the verifier and manifest.
# .PARAMETER BaseRevision
# The exact authorized candidate base commit.
# .PARAMETER HeadRevision
# The exact authorized candidate head commit.
# .PARAMETER AuthorizationManifestPath
# The fixed trusted-revision authorization path.
# .EXAMPLE
# ./Test-TrustRootAuthorization.ps1 @hashtableArguments
#
# # Validates an exact candidate and writes one Boolean result.
# .INPUTS
# None. This script does not accept pipeline input.
# .OUTPUTS
# [System.Boolean] True only for the exact authorized candidate.
# .NOTES
# Version: 1.0.20260902.2

[CmdletBinding(PositionalBinding = $false)]
[OutputType([bool])]
param(
    [Parameter(Mandatory)][string] $RepositoryRootPath,
    [Parameter(Mandatory)][string] $TrustedRevision,
    [Parameter(Mandatory)][string] $BaseRevision,
    [Parameter(Mandatory)][string] $HeadRevision,
    [Parameter()][switch] $AuthorizationApplicabilityOnly,
    [Parameter()][string] $AuthorizationManifestPath =
        '.github/workflows/trust-root-authorization.json'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$intManifestMaximumBytes = 65536
$intCandidateMaximumPaths = 16
$intCandidateMaximumBlobBytes = 573440
$strObjectIdPattern = '^[0-9a-f]{40}$'
$strAuthorizationPath = '.github/workflows/trust-root-authorization.json'
$strVerifierPath = '.github/workflows/Test-TrustRootAuthorization.ps1'
$arrTrustRootPaths = @(
    '.gitattributes',
    '.github/.gitattributes',
    '.github/workflows/.gitattributes',
    '.github/workflows/Test-TrustRootAuthorization.ps1',
    '.github/workflows/Test-AgentInstructions.SelfTest.ps1',
    '.github/workflows/Test-AgentInstructions.ps1',
    '.github/workflows/Test-AgentInstructionParserManifest.mjs',
    '.github/workflows/trust-root-authorization.json',
    '.github/workflows/agent-instructions.yml'
)

function Invoke-BoundedProcessByte {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][string] $FileName,
        [Parameter(Mandatory)][string[]] $ArgumentList,
        [Parameter(Mandatory)][ValidateRange(1, 2147483646)][int] $MaximumBytes,
        [Parameter()][ValidateRange(100, 60000)][int] $TimeoutMilliseconds = 10000
    )

    $objStartInfo = [Diagnostics.ProcessStartInfo]::new($FileName)
    $objStartInfo.UseShellExecute = $false
    $objStartInfo.CreateNoWindow = $true
    $objStartInfo.RedirectStandardOutput = $true
    $objStartInfo.RedirectStandardError = $true
    foreach ($strArgument in $ArgumentList) {
        $objStartInfo.ArgumentList.Add($strArgument)
    }
    $objProcess = [Diagnostics.Process]::new()
    $objProcess.StartInfo = $objStartInfo
    if (-not $objProcess.Start()) {
        throw "Could not start $FileName."
    }
    $objMemory = [IO.MemoryStream]::new()
    $arrBuffer = [byte[]]::new(8192)
    $objStopwatch = [Diagnostics.Stopwatch]::StartNew()
    $objErrorTask = $objProcess.StandardError.ReadToEndAsync()
    while ($true) {
        $intRemainingMilliseconds =
            $TimeoutMilliseconds - [int] $objStopwatch.ElapsedMilliseconds
        if ($intRemainingMilliseconds -le 0) {
            $objProcess.Kill($true)
            throw "$FileName exceeded its time limit."
        }
        $objReadTask = $objProcess.StandardOutput.BaseStream.ReadAsync(
            $arrBuffer,
            0,
            $arrBuffer.Length
        )
        $objCompletedTask = [Threading.Tasks.Task]::WhenAny(
            $objReadTask,
            [Threading.Tasks.Task]::Delay($intRemainingMilliseconds)
        ).GetAwaiter().GetResult()
        if (-not [object]::ReferenceEquals($objCompletedTask, $objReadTask)) {
            $objProcess.Kill($true)
            throw "$FileName exceeded its time limit."
        }
        $intRead = $objReadTask.GetAwaiter().GetResult()
        if ($intRead -eq 0) {
            break
        }
        if ($objMemory.Length + $intRead -gt $MaximumBytes) {
            $objProcess.Kill($true)
            throw "$FileName output exceeded $MaximumBytes bytes."
        }
        $objMemory.Write($arrBuffer, 0, $intRead)
    }
    $intRemainingMilliseconds =
        $TimeoutMilliseconds - [int] $objStopwatch.ElapsedMilliseconds
    if ($intRemainingMilliseconds -le 0 -or
        -not $objProcess.WaitForExit($intRemainingMilliseconds)) {
        $objProcess.Kill($true)
        throw "$FileName exceeded its time limit."
    }
    $strError = $objErrorTask.GetAwaiter().GetResult()
    $arrBytes = $objMemory.ToArray()
    if ([Text.Encoding]::UTF8.GetByteCount($strError) -gt 65536) {
        throw "$FileName error output exceeded 65536 bytes."
    }
    return [pscustomobject]@{
        ExitCode = $objProcess.ExitCode
        Bytes = $arrBytes
        Error = $strError
    }
}

function ConvertFrom-StrictUtf8Text {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][byte[]] $Bytes,
        [Parameter(Mandatory)][string] $Name,
        [Parameter()][switch] $AllowNul
    )

    if ($Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and
        $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF) {
        throw "$Name must not contain a UTF-8 byte-order mark."
    }
    foreach ($byteValue in $Bytes) {
        if (($byteValue -lt 0x20 -and
                $byteValue -notin @(0x09, 0x0A) -and
                -not ($AllowNul -and $byteValue -eq 0x00)) -or
            $byteValue -eq 0x7F -or $byteValue -eq 0x0D) {
            throw "$Name contains a prohibited control byte or non-LF newline."
        }
    }
    try {
        return [Text.UTF8Encoding]::new($false, $true).GetString($Bytes)
    }
    catch {
        throw "$Name is not strict UTF-8."
    }
}

function Read-GitBlobByte {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([byte])]
    param(
        [Parameter(Mandatory)][string] $RepositoryRootPath,
        [Parameter(Mandatory)][string] $BlobId,
        [Parameter(Mandatory)][int] $MaximumBytes
    )

    $objSizeResult = Invoke-BoundedProcessByte -FileName 'git' `
        -ArgumentList @('-C', $RepositoryRootPath, 'cat-file', '-s', $BlobId) `
        -MaximumBytes 32
    $strSize = [Text.Encoding]::ASCII.GetString($objSizeResult.Bytes).Trim()
    $intSize = 0
    if ($objSizeResult.ExitCode -ne 0 -or
        -not [int]::TryParse($strSize, [ref] $intSize) -or
        $intSize -gt $MaximumBytes) {
        throw "Authorized blob $BlobId exceeds its byte limit."
    }
    $objResult = Invoke-BoundedProcessByte -FileName 'git' `
        -ArgumentList @('-C', $RepositoryRootPath, 'cat-file', 'blob', $BlobId) `
        -MaximumBytes $intSize
    if ($objResult.ExitCode -ne 0) {
        throw "Could not read authorized blob $BlobId."
    }
    return [byte[]] $objResult.Bytes
}

function Assert-NoDuplicateJsonProperty {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param([Parameter(Mandatory)][System.Text.Json.JsonElement] $Element)

    if ($Element.ValueKind -eq [System.Text.Json.JsonValueKind]::Object) {
        $setNames = [Collections.Generic.HashSet[string]]::new(
            [StringComparer]::Ordinal
        )
        foreach ($objProperty in $Element.EnumerateObject()) {
            if (-not $setNames.Add($objProperty.Name)) {
                throw "Authorization JSON contains duplicate property $($objProperty.Name)."
            }
            Assert-NoDuplicateJsonProperty -Element $objProperty.Value
        }
    }
    elseif ($Element.ValueKind -eq [System.Text.Json.JsonValueKind]::Array) {
        foreach ($objItem in $Element.EnumerateArray()) {
            Assert-NoDuplicateJsonProperty -Element $objItem
        }
    }
}

function Assert-ExactPropertySet {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)][object] $InputObject,
        [Parameter(Mandatory)][string[]] $PropertyName,
        [Parameter(Mandatory)][string] $Name
    )

    $arrActual = @($InputObject.PSObject.Properties.Name | Sort-Object)
    $arrExpected = @($PropertyName | Sort-Object)
    if ($arrActual.Count -ne $arrExpected.Count -or
        [string]::Join("`n", $arrActual) -cne
            [string]::Join("`n", $arrExpected)) {
        throw "$Name has an unexpected property set."
    }
}

function Assert-CandidateSyntax {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)][string] $Syntax,
        [Parameter(Mandatory)][string] $Text,
        [Parameter(Mandatory)][string] $Path
    )

    if ($Syntax -ceq 'powershell') {
        $objTokens = $null
        $arrErrors = $null
        [void] [Management.Automation.Language.Parser]::ParseInput(
            $Text,
            $Path,
            [ref] $objTokens,
            [ref] $arrErrors
        )
        if ($arrErrors.Count -gt 0) {
            throw "$Path has invalid PowerShell syntax."
        }
        return
    }
    if ($Syntax -ceq 'yaml') {
        $strNodeSource = @'
const yaml = require('js-yaml');
let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => { input += chunk; });
process.stdin.on('end', () => {
  yaml.load(input, { schema: yaml.FAILSAFE_SCHEMA, json: false });
});
'@
        $objStartInfo = [Diagnostics.ProcessStartInfo]::new('node')
        $objStartInfo.UseShellExecute = $false
        $objStartInfo.CreateNoWindow = $true
        $objStartInfo.RedirectStandardInput = $true
        $objStartInfo.RedirectStandardOutput = $true
        $objStartInfo.RedirectStandardError = $true
        $objStartInfo.ArgumentList.Add('-e')
        $objStartInfo.ArgumentList.Add($strNodeSource)
        $objProcess = [Diagnostics.Process]::new()
        $objProcess.StartInfo = $objStartInfo
        if (-not $objProcess.Start()) {
            throw 'Could not start the trusted YAML parser.'
        }
        $objOutputTask = $objProcess.StandardOutput.ReadToEndAsync()
        $objErrorTask = $objProcess.StandardError.ReadToEndAsync()
        $objProcess.StandardInput.Write($Text)
        $objProcess.StandardInput.Close()
        if (-not $objProcess.WaitForExit(10000)) {
            $objProcess.Kill($true)
            throw 'The trusted YAML parser exceeded its time limit.'
        }
        $strOutput = $objOutputTask.GetAwaiter().GetResult()
        $strError = $objErrorTask.GetAwaiter().GetResult()
        if ([Text.Encoding]::UTF8.GetByteCount($strOutput + $strError) -gt 65536) {
            throw 'The trusted YAML parser output exceeded 65536 bytes.'
        }
        if ($objProcess.ExitCode -ne 0) {
            throw "$Path has invalid YAML syntax."
        }
        return
    }
    if ($Syntax -cne 'markdown') {
        throw "$Path declares an unsupported syntax class."
    }
}

function Assert-SemanticInvariant {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)][string] $Invariant,
        [Parameter(Mandatory)][string] $Text,
        [Parameter(Mandatory)][string] $Path
    )

    if ($Invariant -ceq 'exact-maintenance-production-call-is-gated') {
        $arrTokens = $null
        $arrParseErrors = $null
        $objAst = [Management.Automation.Language.Parser]::ParseInput(
            $Text,
            [ref] $arrTokens,
            [ref] $arrParseErrors
        )
        $arrCalls = @($objAst.FindAll({
                    param($objNode)
                    $objNode -is [Management.Automation.Language.CommandAst] -and
                    $objNode.GetCommandName() -ceq
                        'Get-TrustRootRangeMutationFailure'
                }, $true))
        $intProductionSwitchCalls = 0
        $intSelfTestSwitchCalls = 0
        foreach ($objCall in $arrCalls) {
            $boolHasPrivateSwitch = @($objCall.CommandElements |
                    Where-Object {
                        $_ -is [Management.Automation.Language.CommandParameterAst] -and
                        $_.ParameterName -ceq
                            'ExactAuthorizedMaintenanceProductionCall'
                    }).Count -eq 1
            if (-not $boolHasPrivateSwitch) {
                continue
            }
            $boolHasSelfTestAncestor = $false
            $objParent = $objCall.Parent
            while ($null -ne $objParent) {
                if ($objParent -is
                    [Management.Automation.Language.IfStatementAst] -and
                    $objParent.Extent.Text -cmatch '^if \(\$SelfTest\)') {
                    $boolHasSelfTestAncestor = $true
                    break
                }
                $objParent = $objParent.Parent
            }
            if ($boolHasSelfTestAncestor) {
                $intSelfTestSwitchCalls++
            }
            else {
                $intProductionSwitchCalls++
            }
        }
        $strAuthorizedFixturePattern =
            '(?s)\$script:boolTrustedMaintenanceAuthorizationValidated = ' +
            '\$true\s+\$arrAuthorizedFixtureFailures = @\(\s+' +
            'Get-TrustRootRangeMutationFailure\s+`.*?' +
            '-RepositoryRelativePath \$strAuthorizationFixtureTrustPath\s+\)'
        $strHermeticFixturePattern =
            '(?s)\$strAuthorizationFixtureRoot = \[IO\.Path\]::Combine\(' +
            '.*?agent-instruction-trust-root-.*?' +
            '\$strAuthorizationFixtureRepository =.*?' +
            "commit --quiet --no-gpg-sign -m 'trust-root baseline'.*?" +
            "commit --quiet --no-gpg-sign -m 'trust-root mutation'.*?" +
            'git clone --quiet --depth 1 --no-local --no-hardlinks.*?' +
            '--is-shallow-repository.*?rev-list\s+`\s+' +
            '--max-parents=0 HEAD.*?' +
            'The depth-one clone did not reproduce the apparent-root condition\.'
        $strNoMutationFixturePattern =
            '(?s)\$arrNoMutationFixtureFailures = @\(\s+' +
            'Get-TrustRootRangeMutationFailure\s+`.*?' +
            '-BaseRevision \$strAuthorizationFixtureHead\.Trim\(\)\s+`.*?' +
            '-HeadRevision \$strAuthorizationFixtureHead\.Trim\(\).*?' +
            '\$arrNoMutationFixtureFailures\.Count -ne 0'
        $strFixtureCleanupPattern =
            '(?s)finally \{\s+' +
            '\$script:boolTrustedMaintenanceAuthorizationValidated =.*?' +
            'Remove-Item -LiteralPath \$strAuthorizationFixtureRoot ' +
            '-Recurse -Force\s+\}\s+\}'
        if ($arrParseErrors.Count -ne 0 -or
            $Text -cnotmatch
                '(?s)if \(\$ExactAuthorizedMaintenanceProductionCall -and\s+' +
                '-not \$script:boolTrustedMaintenanceAuthorizationValidated\) ' +
                "\{\s+throw 'The production maintenance call requires exact " +
                "trusted authorization\.'" -or
            $Text -cnotmatch
                '(?s)if \(\$ExactAuthorizedMaintenanceProductionCall -and\s+' +
                '\$script:boolTrustedMaintenanceAuthorizationValidated\) ' +
                '\{\s+return' -or
            $intProductionSwitchCalls -ne 1 -or
            $intSelfTestSwitchCalls -ne 2 -or
            $Text -cnotmatch $strHermeticFixturePattern -or
            $Text -cnotmatch $strAuthorizedFixturePattern -or
            ([regex]::Match(
                    $Text,
                    $strAuthorizedFixturePattern
                ).Value.Contains(
                    '-ExactAuthorizedMaintenanceProductionCall',
                    [StringComparison]::Ordinal
                )) -or
            $Text -cnotmatch
                'The hermetic trust-root mutation fixture was not diagnosed\.' -or
            $Text -cnotmatch $strNoMutationFixturePattern -or
            $Text -cnotmatch $strFixtureCleanupPattern -or
            $Text -cmatch
                '(?s)\$strAuthorizationFixtureBase = \[string\] \(\s+' +
                '& git -C \$strRepositoryRootPath rev-list --max-parents=0 HEAD' -or
            $Text -cnotmatch
                'An unauthorized production maintenance call did not fail closed\.') {
            throw "$Path does not satisfy semantic invariant $Invariant."
        }
        return
    }

    if ($Invariant -ceq 'published-path-array-binding-is-explicit') {
        $arrTokens = $null
        $arrParseErrors = $null
        [void] [Management.Automation.Language.Parser]::ParseInput(
            $Text,
            [ref] $arrTokens,
            [ref] $arrParseErrors
        )
        $strExplicitCallPattern =
            '(?s)\[string\[\]\] ' +
            '\$arrPublishedNewRefBoundaryRevisions = @\(\).*?' +
            '\[string\[\]\] ' +
            '\$arrPublishedNewRefIntroducedCommitRevisions = @\(\).*?' +
            '-NewRefBoundaryRevision ' +
            '\$arrPublishedNewRefBoundaryRevisions\s+`.*?' +
            '-NewRefIntroducedCommitRevision\s+`\s+' +
            '\$arrPublishedNewRefIntroducedCommitRevisions\s+`'
        $strHelperValidationPattern =
            '(?s)\$arrBoundaries = @\(\$NewRefBoundaryRevision\)\s+' +
            '\$arrIntroducedCommits = ' +
            '@\(\$NewRefIntroducedCommitRevision\).*?' +
            'foreach \(\$strRevision in ' +
            '@\(\$arrBoundaries \+ \$arrIntroducedCommits\)\).*?' +
            '\[string\]::IsNullOrEmpty\(\$strRevision\).*?' +
            "throw 'The created-ref path range contains an invalid revision\.'"
        if ($arrParseErrors.Count -ne 0 -or
            $Text -cnotmatch $strExplicitCallPattern -or
            $Text -cnotmatch $strHelperValidationPattern -or
            $Text -cmatch
                '(?s)-NewRefBoundaryRevision\s+\$\(' -or
            $Text -cmatch
                '(?s)-NewRefIntroducedCommitRevision\s+\$\(' -or
            $Text -cnotmatch
                'A created ref with no introduced commits reported changed paths\.' -or
            $Text -cnotmatch
                'A zero-boundary created ref returned an incorrect ' +
                'final-tree path set\.' -or
            $Text -cnotmatch
                'A nonzero-boundary created ref returned an incorrect ' +
                'changed-path set\.' -or
            $Text -cnotmatch
                "Name = 'null boundary'" -or
            $Text -cnotmatch
                "Name = 'empty boundary'" -or
            $Text -cnotmatch
                "Name = 'invalid introduced revision'") {
            throw "$Path does not satisfy semantic invariant $Invariant."
        }
        return
    }

    if ($Invariant -ceq 'legacy-transition-marker-is-inert-data') {
        $arrTokens = $null
        $arrParseErrors = $null
        $objAst = [Management.Automation.Language.Parser]::ParseInput(
            $Text,
            [ref] $arrTokens,
            [ref] $arrParseErrors
        )
        $arrScopedName = @(
            'script:strLegacyMetadataRangeCompatibilityMarker',
            'script:strLegacyStyleGuideRationaleCompatibilityMarker',
            'script:strLegacyOperationalLintGuideCompatibilityMarker'
        )
        $arrUnqualifiedName = @(
            'strLegacyMetadataRangeCompatibilityMarker',
            'strLegacyStyleGuideRationaleCompatibilityMarker',
            'strLegacyOperationalLintGuideCompatibilityMarker'
        )
        $arrAssignments = @($objAst.FindAll({
                    param($objNode)
                    $objNode -is
                        [Management.Automation.Language.AssignmentStatementAst] -and
                    $objNode.Left -is
                        [Management.Automation.Language.VariableExpressionAst]
                }, $true))
        $arrScopedAssignments = @($arrAssignments | Where-Object {
                $arrScopedName -ccontains $_.Left.VariablePath.UserPath
            })
        $arrUnqualifiedAssignments = @($arrAssignments | Where-Object {
                $arrUnqualifiedName -ccontains $_.Left.VariablePath.UserPath
            })
        $strExactBlockPattern =
            '(?m)^# Trusted-bootstrap compatibility data; do not use as active policy\.$' +
            '\n\$script:strLegacyMetadataRangeCompatibilityMarker =\n' +
            "    'metadata-range-transition-policy-v1'\n" +
            '\$script:strLegacyStyleGuideRationaleCompatibilityMarker =\n' +
            "    'style-guide-rationale-metadata-policy-v1'\n" +
            '\$script:strLegacyOperationalLintGuideCompatibilityMarker =\n' +
            "    'operational-lint-guide-metadata-policy-v1'$"
        $boolExactOccurrenceInventory = $true
        foreach ($strScopedName in $arrScopedName) {
            if ([regex]::Matches(
                    $Text,
                    [regex]::Escape([char] 36 + $strScopedName)
                ).Count -ne 2) {
                $boolExactOccurrenceInventory = $false
            }
        }
        if ($arrParseErrors.Count -ne 0 -or
            $arrScopedAssignments.Count -ne 3 -or
            @($arrScopedAssignments.Left.VariablePath.UserPath |
                    Sort-Object -Unique).Count -ne 3 -or
            $arrUnqualifiedAssignments.Count -ne 0 -or
            -not $boolExactOccurrenceInventory -or
            $Text -cnotmatch $strExactBlockPattern -or
            $Text.Contains(
                'PSUseDeclaredVarsMoreThanAssignments',
                [StringComparison]::Ordinal
            )) {
            throw "$Path does not satisfy semantic invariant $Invariant."
        }
        return
    }

    if ($Invariant -ceq 'workflow-created-push-history-fetch-is-bounded') {
        $arrRequiredLiteral = @(
            'PUSH_COMMIT_EVIDENCE: ${{ toJson(github.event.commits) }}',
            'const evidence = process.env.PUSH_COMMIT_EVIDENCE;',
            'Buffer.byteLength(evidence, "utf8") > 1048576',
            'commits = JSON.parse(evidence);',
            '!Array.isArray(commits) || commits.length > 2048',
            '!/^[0-9a-f]{40}$/.test(entry.id)',
            'seenCommitIds.has(entry.id)',
            'if (ids.length > 0 &&',
            'ids[ids.length - 1] !== process.env.PUSH_AFTER_SHA',
            '(ids.length > 0 ? "\n" : ""), "utf8");',
            'fetch_depth=$((push_commit_count + 1))',
            'test "${fetch_depth}" -le 2049',
            "destination_local_ref='refs/remotes/event/created-destination'",
            '--no-write-fetch-head --no-recurse-submodules origin',
            '"${PUSH_REF}:${destination_local_ref}"',
            'test "${fetched_destination}" = "${PUSH_AFTER_SHA}"',
            'git cat-file -e "${push_commit_id}^{commit}"',
            'cmp --silent "${raw_refs}" "${raw_refs_after}"'
        )
        foreach ($strRequiredLiteral in $arrRequiredLiteral) {
            if (-not $Text.Contains(
                    $strRequiredLiteral,
                    [StringComparison]::Ordinal
                )) {
                throw "$Path does not satisfy semantic invariant $Invariant."
            }
        }
        if ($Text -cmatch '(?m)(^|\s)--force(\s|$)' -or
            $Text.Contains(
                '"+${PUSH_REF}:${destination_local_ref}"',
                [StringComparison]::Ordinal
            )) {
            throw "$Path does not satisfy semantic invariant $Invariant."
        }
        return
    }

    $hashtablePatterns = @{
        'adr-lifecycle-migration-is-enforced' =
            '(?s)function Get-DecisionRecordLifecycleFailure.*?' +
            'An unchanged published legacy ADR did not remain valid\..*?' +
            'A changed legacy ADR did not require lifecycle migration'
        'created-ref-metadata-baseline-is-consumed' =
            '(?s)function Get-CreatedRefMetadataBaselineRevision.*?' +
            '\$strCreatedRefMetadataBaselineRevision =\s+' +
            'Get-CreatedRefMetadataBaselineRevision'
        'created-ref-paths-use-endpoint-boundary' =
            '(?s)function Read-GitPublishedEndpointChangedPath.*?' +
            'elseif \(\$BaselineAbsent -and ' +
            '\$arrBoundaries\.Count -eq 1\).*?' +
            '''diff''.*?\$arrBoundaries\[0\], \$FinalRevision.*?' +
            'A created ref with introduced commits must have one boundary'
        'docs-status-lifecycle-values' =
            'Draft \| Proposed \| Active \| Accepted \| Superseded \| Deprecated'
        'docs-owner-enforcer-relationship' =
            '(?m)^- `\.github/instructions/docs\.instructions\.md` owns these ' +
            'documentation rules\.$\n^- `\.github/workflows/' +
            'Test-AgentInstructions\.ps1` is a non-owner enforcement mechanism\. ' +
            'It checks the named owner at the exact input revision and rejects ' +
            'stale repository-specific documentation claims\.$'
        'extracted-self-test-is-invoked' =
            '& \(Join-Path \$strRepositoryRootPath \$strExtractedSelfTestPath\)'
        'extracted-self-test-version-and-topology' =
            '(?s)# Version: 1\.2\.\d{8}\.\d+.*Get-CreatedRefBoundaryContext'
        'metadata-history-validates-parent-edges' =
            'function Get-GovernedMetadataHistoryFailure'
        'new-ref-boundary-cap-is-64' =
            '\$intMetadataMaximumBoundaries = 64'
        'pr-merge-bases-use-all-and-cap' =
            'merge-base --all'
        'published-finalization-date-is-enforced' =
            '(?s)\$strTrustedEventUtcDate = ' +
            '\$objTrustedEventTimestamp\.ToString\(.*?' +
            'ExpectedUtcDate = \$strTrustedEventUtcDate.*?' +
            'IsWorktreeTransition = \$true'
        'ordinary-pr-uses-normal-trust-audit' =
            '(?s)if \(\s*\$script:boolTrustedMaintenanceAuthorizationValidated' +
            '.*?-ExactAuthorizedMaintenanceProductionCall.*?else \{\s+' +
            '@\(Get-TrustRootRangeMutationFailure'
        'trusted-maintenance-switch-is-explicit' =
            '\$TrustedMaintenanceAuthorizationValidated'
        'verifier-audits-authorized-history' =
            'The candidate history contains unauthorized path'
        'verifier-reads-trusted-revision-manifest' =
            'ls-tree\s+`?\s*\$TrustedRevision\s+--\s+\$AuthorizationManifestPath'
        'workflow-checkout-is-trusted-sha' =
            '(?s)ref: \$\{\{ github\.sha \}\}.*?fetch-depth: >-\s+' +
            "\$\{\{ github\.event_name == 'push' && github\.event\.created " +
            '&& 1 \|\| 0 \}\}'
        'workflow-permissions-are-read-only' =
            'permissions:\s+contents: read'
        'workflow-persist-credentials-is-false' =
            'persist-credentials: false'
        'workflow-uses-trusted-authorization-output' =
            'TrustedMaintenanceAuthorizationValidated'
    }
    if (-not $hashtablePatterns.ContainsKey($Invariant) -or
        $Text -cnotmatch $hashtablePatterns[$Invariant]) {
        throw "$Path does not satisfy semantic invariant $Invariant."
    }
}

if ($AuthorizationManifestPath -cne $strAuthorizationPath) {
    throw 'The authorization manifest path is not the fixed trusted path.'
}
foreach ($strRevision in @($TrustedRevision, $BaseRevision, $HeadRevision)) {
    if ($strRevision -cnotmatch $strObjectIdPattern) {
        throw "Authorization received an invalid commit ID: $strRevision"
    }
    & git -C $RepositoryRootPath cat-file -e "$strRevision`^{commit}" 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Authorization commit is unavailable: $strRevision"
    }
}
$strCheckedOutRevision = [string] (& git -C $RepositoryRootPath `
        rev-parse --verify 'HEAD^{commit}')
if ($LASTEXITCODE -ne 0 -or $strCheckedOutRevision.Trim() -cne $TrustedRevision) {
    throw 'The checked-out trusted revision does not match the authenticated revision.'
}
if ($AuthorizationApplicabilityOnly) {
    $arrMergeBases = @(
        & git -C $RepositoryRootPath merge-base --all `
            $BaseRevision $HeadRevision 2>$null |
            ForEach-Object { ([string] $_).Trim() }
    )
    if ($LASTEXITCODE -ne 0 -or $arrMergeBases.Count -lt 1 -or
        $arrMergeBases.Count -gt 64 -or
        @($arrMergeBases | Where-Object {
                $_ -cnotmatch $strObjectIdPattern
            }).Count -gt 0) {
        throw 'The authorization applicability merge-base set is indeterminate.'
    }
    $boolTrustRootChanged = $false
    foreach ($strMergeBase in $arrMergeBases) {
        & git -C $RepositoryRootPath diff --quiet --no-ext-diff --no-textconv `
            $strMergeBase $HeadRevision -- @arrTrustRootPaths
        if ($LASTEXITCODE -eq 1) {
            $boolTrustRootChanged = $true
        }
        elseif ($LASTEXITCODE -ne 0) {
            throw 'Could not inspect trust-root maintenance applicability.'
        }
    }
    Write-Output $boolTrustRootChanged
    return
}
$strManifestEntry = [string] (& git -C $RepositoryRootPath ls-tree `
        $TrustedRevision -- $AuthorizationManifestPath)
if ($LASTEXITCODE -ne 0 -or
    $strManifestEntry -cnotmatch '^100644 blob ([0-9a-f]{40})\t') {
    throw 'The trusted revision authorization manifest is not one regular blob.'
}
$strManifestBlob = $Matches[1]
$arrManifestBytes = @(Read-GitBlobByte -RepositoryRootPath $RepositoryRootPath `
        -BlobId $strManifestBlob -MaximumBytes $intManifestMaximumBytes)
$strManifestText = ConvertFrom-StrictUtf8Text -Bytes $arrManifestBytes `
    -Name 'The trusted authorization manifest'
try {
    $objJsonDocument = [System.Text.Json.JsonDocument]::Parse($strManifestText)
    Assert-NoDuplicateJsonProperty -Element $objJsonDocument.RootElement
    $objManifest = ConvertFrom-Json -InputObject $strManifestText
}
catch {
    throw 'The trusted authorization manifest is malformed JSON.'
}
Assert-ExactPropertySet -InputObject $objManifest -Name 'The authorization manifest' `
    -PropertyName @(
        'schema_version', 'authorization_id', 'candidate', 'limits',
        'allowed_paths'
    )
if ($objManifest.schema_version -ne 1 -or
    [string] $objManifest.authorization_id -cnotmatch
        '^[a-z0-9][a-z0-9-]{0,127}$') {
    throw 'The authorization manifest identity is invalid.'
}
Assert-ExactPropertySet -InputObject $objManifest.candidate -Name 'The candidate identity' `
    -PropertyName @('base_commit', 'head_commit', 'head_tree', 'parent_commits')
if ($objManifest.candidate.base_commit -cne $BaseRevision -or
    $objManifest.candidate.head_commit -cne $HeadRevision -or
    [string] $objManifest.candidate.head_tree -cnotmatch $strObjectIdPattern) {
    throw 'The event commits do not match the exact authorization.'
}
$strHeadTree = [string] (& git -C $RepositoryRootPath rev-parse `
        --verify "$HeadRevision`^{tree}")
if ($LASTEXITCODE -ne 0 -or $strHeadTree.Trim() -cne $objManifest.candidate.head_tree) {
    throw 'The candidate tree does not match the exact authorization.'
}
$arrActualParents = @(
    ([string] (& git -C $RepositoryRootPath rev-list --parents -n 1 $HeadRevision)).Trim() `
        -split '\s+' | Select-Object -Skip 1
)
$arrAuthorizedParents = @($objManifest.candidate.parent_commits)
if ($arrAuthorizedParents.Count -gt 64 -or
    @($arrAuthorizedParents | Where-Object {
            [string] $_ -cnotmatch $strObjectIdPattern
        }).Count -gt 0) {
    throw 'The authorized parent commit list is invalid.'
}
if ([string]::Join("`n", $arrActualParents) -cne
    [string]::Join("`n", $arrAuthorizedParents)) {
    throw 'The candidate parent commits do not match the exact authorization.'
}
Assert-ExactPropertySet -InputObject $objManifest.limits -Name 'The authorization limits' `
    -PropertyName @('maximum_paths', 'maximum_blob_bytes', 'maximum_manifest_bytes')
if ($objManifest.limits.maximum_paths -gt $intCandidateMaximumPaths -or
    $objManifest.limits.maximum_paths -lt 1 -or
    $objManifest.limits.maximum_blob_bytes -gt $intCandidateMaximumBlobBytes -or
    $objManifest.limits.maximum_blob_bytes -lt 1 -or
    $objManifest.limits.maximum_manifest_bytes -ne $intManifestMaximumBytes) {
    throw 'The authorization limits exceed the trusted verifier limits.'
}
$arrAllowedPaths = @($objManifest.allowed_paths)
if ($arrAllowedPaths.Count -lt 1 -or
    $arrAllowedPaths.Count -gt $objManifest.limits.maximum_paths) {
    throw 'The authorization path count is outside its limit.'
}
$setAllowedPaths = [Collections.Generic.HashSet[string]]::new(
    [StringComparer]::Ordinal
)
foreach ($objPath in $arrAllowedPaths) {
    Assert-ExactPropertySet -InputObject $objPath -Name 'An authorized path' `
        -PropertyName @(
            'path', 'mode', 'blob', 'bytes', 'sha256', 'encoding',
            'syntax', 'semantic_invariants'
        )
    $strPath = [string] $objPath.path
    if ([IO.Path]::IsPathRooted($strPath) -or
        $strPath.Contains('\', [StringComparison]::Ordinal) -or
        $strPath -match '(^|/)\.\.?(/|$)' -or
        $strPath.IndexOfAny([char[]] @("`0", "`r", "`n", "`t")) -ge 0 -or
        -not $setAllowedPaths.Add($strPath) -or
        $strPath -ceq $AuthorizationManifestPath) {
        throw 'The authorization contains an unsafe, duplicate, or self-authorizing path.'
    }
    if ($objPath.mode -cne '100644' -or
        $objPath.blob -cnotmatch $strObjectIdPattern -or
        $objPath.bytes -lt 0 -or
        $objPath.bytes -gt $objManifest.limits.maximum_blob_bytes -or
        $objPath.sha256 -cnotmatch '^[0-9a-f]{64}$' -or
        $objPath.encoding -cne 'utf-8-no-bom-lf') {
        throw "$strPath has an invalid authorized object contract."
    }
    $strTreeEntry = [string] (& git -C $RepositoryRootPath ls-tree `
            $HeadRevision -- $strPath)
    if ($LASTEXITCODE -ne 0 -or
        $strTreeEntry -cnotmatch '^([0-7]{6}) blob ([0-9a-f]{40})\t(.+)$' -or
        $Matches[1] -cne $objPath.mode -or
        $Matches[2] -cne $objPath.blob -or
        $Matches[3] -cne $strPath) {
        throw "$strPath is missing, linked, deleted, or has a mismatched Git identity."
    }
    $arrBlobBytes = @(Read-GitBlobByte -RepositoryRootPath $RepositoryRootPath `
            -BlobId $objPath.blob `
            -MaximumBytes ($objManifest.limits.maximum_blob_bytes + 1))
    if ($arrBlobBytes.Count -ne $objPath.bytes) {
        throw "$strPath has a mismatched byte count."
    }
    $strSha256 = [Convert]::ToHexString(
        [Security.Cryptography.SHA256]::HashData([byte[]] $arrBlobBytes)
    ).ToLowerInvariant()
    if ($strSha256 -cne $objPath.sha256) {
        throw "$strPath has a mismatched SHA-256 value."
    }
    $strText = ConvertFrom-StrictUtf8Text -Bytes $arrBlobBytes -Name $strPath
    Assert-CandidateSyntax -Syntax $objPath.syntax -Text $strText -Path $strPath
    $arrInvariants = @($objPath.semantic_invariants)
    if ($arrInvariants.Count -lt 1 -or
        @($arrInvariants | Where-Object {
                $_ -isnot [string] -or [string]::IsNullOrWhiteSpace($_)
            }).Count -gt 0 -or
        @($arrInvariants | Sort-Object -Unique).Count -ne $arrInvariants.Count) {
        throw "$strPath has missing or duplicate semantic invariants."
    }
    foreach ($strInvariant in $arrInvariants) {
        Assert-SemanticInvariant -Invariant $strInvariant -Text $strText -Path $strPath
    }
    if ($strPath -ceq $strVerifierPath) {
        $strTrustedVerifierEntry = [string] (& git -C $RepositoryRootPath ls-tree `
                $TrustedRevision -- $strVerifierPath)
        if ($LASTEXITCODE -ne 0 -or
            $strTrustedVerifierEntry -cnotmatch '^100644 blob ([0-9a-f]{40})\t' -or
            $Matches[1] -cne $objPath.blob) {
            throw 'The candidate verifier differs from the trusted verifier that authorizes it.'
        }
    }
}

$objDiff = Invoke-BoundedProcessByte -FileName 'git' -MaximumBytes 1048576 `
    -ArgumentList @(
        '-C', $RepositoryRootPath, 'diff', '--name-status', '-z', '--no-renames',
        '--no-ext-diff', '--no-textconv', $BaseRevision, $HeadRevision, '--'
    )
if ($objDiff.ExitCode -ne 0) {
    throw 'Could not enumerate the exact candidate path set.'
}
$strDiff = ConvertFrom-StrictUtf8Text -Bytes $objDiff.Bytes `
    -Name 'The candidate path list' -AllowNul
$arrDiffFields = @($strDiff -split "`0" | Where-Object { $_ -cne '' })
if ($arrDiffFields.Count % 2 -ne 0) {
    throw 'The candidate path list is malformed.'
}
$setChangedPaths = [Collections.Generic.HashSet[string]]::new(
    [StringComparer]::Ordinal
)
for ($intIndex = 0; $intIndex -lt $arrDiffFields.Count; $intIndex += 2) {
    if ($arrDiffFields[$intIndex] -cnotin @('A', 'M') -or
        -not $setChangedPaths.Add($arrDiffFields[$intIndex + 1])) {
        throw 'The candidate contains a deleted, renamed, duplicate, or malformed path.'
    }
}
if ($setChangedPaths.Count -ne $setAllowedPaths.Count) {
    throw 'The candidate changed-path count does not match the authorization.'
}
foreach ($strChangedPath in $setChangedPaths) {
    if (-not $setAllowedPaths.Contains($strChangedPath)) {
        throw "The candidate contains unauthorized path $strChangedPath."
    }
}

$objHistory = Invoke-BoundedProcessByte -FileName 'git' -MaximumBytes 1048576 `
    -ArgumentList @(
        '-C', $RepositoryRootPath, 'log', '--format=', '--name-only', '-z',
        '--no-renames', '--no-ext-diff', '--no-textconv',
        '--diff-merges=separate', '--root', $HeadRevision, '--not',
        $BaseRevision, '--'
    )
if ($objHistory.ExitCode -ne 0) {
    throw 'Could not enumerate the authorized candidate history.'
}
$strHistory = ConvertFrom-StrictUtf8Text -Bytes $objHistory.Bytes `
    -Name 'The candidate history path list' -AllowNul
$arrHistoryPaths = @(
    $strHistory -split "`0" | Where-Object { $_ -cne '' }
)
foreach ($strHistoryPath in $arrHistoryPaths) {
    if (-not $setAllowedPaths.Contains($strHistoryPath)) {
        throw "The candidate history contains unauthorized path $strHistoryPath."
    }
}

Write-Output $true
