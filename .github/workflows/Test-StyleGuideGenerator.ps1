#Requires -Version 5.1
# .SYNOPSIS
# Exercises actual generation and focused composition/publication controls.
#
# .DESCRIPTION
# Uses disposable repositories and the current PowerShell executable. Actual
# publication tests are separate from synthetic platform and failure controls.
# Does not change execution policy or claim protection against competing writers.
#
# .PARAMETER ExpectedHost
# Optional hosted-cell identity. LinuxPowerShell7 also requires native ext4.
#
# .EXAMPLE
# ./.github/workflows/Test-StyleGuideGenerator.ps1
#
# # Runs the focused suite on the current supported host.
#
# .INPUTS
# None. Pipeline input is not supported.
#
# .OUTPUTS
# System.String. A final summary; a failed assertion terminates the script.
#
# .NOTES
# All parameters are named. Version: 1.0.20261005.0
[CmdletBinding(PositionalBinding = $false)]
[OutputType([string])]
param (
    [ValidateSet('Current', 'WindowsPowerShell51', 'WindowsPowerShell7', 'LinuxPowerShell7')]
    [string]$ExpectedHost = 'Current'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
if (Test-Path Variable:PSNativeCommandUseErrorActionPreference) {
    $PSNativeCommandUseErrorActionPreference = $false
}
$strPowerShell = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
$boolWindows = [Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT
if (($ExpectedHost -eq 'WindowsPowerShell51' -and
        (-not $boolWindows -or $PSVersionTable.PSEdition -cne 'Desktop' -or $PSVersionTable.PSVersion.Major -ne 5)) -or
    ($ExpectedHost -eq 'WindowsPowerShell7' -and (-not $boolWindows -or $PSVersionTable.PSVersion.Major -ne 7)) -or
    ($ExpectedHost -eq 'LinuxPowerShell7' -and ($boolWindows -or $PSVersionTable.PSVersion.Major -ne 7))) {
    throw 'generator-test: wrong platform or PowerShell edition'
}
$strGit = (Microsoft.PowerShell.Core\Get-Command -Name git -CommandType Application -All -TotalCount 1 -ErrorAction Stop).Source
$strRepository = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
$strRepository = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($strRepository)
$strScratchParent = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath([IO.Path]::GetTempPath())
$strScratch = Join-Path -Path $strScratchParent -ChildPath ('styleguide-generator-' + [Guid]::NewGuid().ToString('N'))
[void][IO.Directory]::CreateDirectory($strScratch)
$objEncoding = New-Object System.Text.UTF8Encoding($false, $true)
$strGeneratorPath = Join-Path -Path $PSScriptRoot -ChildPath 'Generate-StyleGuideArtifacts.ps1'
$strGenerator = [IO.File]::ReadAllText($strGeneratorPath, $objEncoding)
$strStorage = 'not-required'
if ($ExpectedHost -eq 'LinuxPowerShell7') {
    foreach ($strStoragePath in @($strRepository, $strScratch)) {
        $arrStorage = @(& /usr/bin/findmnt --noheadings --output FSTYPE --target $strStoragePath)
        if ($LASTEXITCODE -ne 0 -or $arrStorage.Count -ne 1 -or $arrStorage[0].Trim() -cne 'ext4') {
            throw 'generator-test: native ext4 is required for source and fixture storage'
        }
    }
    $strStorage = 'ext4'
}
$script:intAssertions = 0


function Assert-GeneratorCondition {
    # .SYNOPSIS
    # Requires a focused test condition.
    #
    # .DESCRIPTION
    # Counts successful assertions and terminates on a failed assertion.
    #
    # .PARAMETER Condition
    # The condition required to be true.
    #
    # .PARAMETER Label
    # Fixed diagnostic describing the violated expectation.
    #
    # .EXAMPLE
    # Assert-GeneratorCondition -Condition ($intExit -eq 0) -Label 'native exit'
    #
    # # Terminates if the native command failed.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # None. Failure terminates.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - Not public API. Parameters, return shape and
    # positional contract may change without notice. All parameters are named.
    #
    # Version: 1.0.20261005.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param ([bool]$Condition, [string]$Label)

    if (-not $Condition) {
        throw ('generator-test: ' + $Label)
    }
    $script:intAssertions++
}


function Invoke-GeneratorFixture {
    # .SYNOPSIS
    # Runs the real fixture generator in a separate process.
    #
    # .DESCRIPTION
    # Keeps native status separate from the parsed result and requires one object.
    #
    # .PARAMETER Root
    # Absolute fixture repository directory.
    #
    # .EXAMPLE
    # $objRun = Invoke-GeneratorFixture -Root $strFixture
    #
    # # Returns ExitCode and Result without converting failure into success.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # System.Management.Automation.PSCustomObject. Native exit and parsed result.
    # Invalid output terminates.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - Not public API. Parameters, return shape and
    # positional contract may change without notice. All parameters are named.
    #
    # Version: 1.0.20261005.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param ([string]$Root)

    $strScript = Join-Path -Path $Root -ChildPath '.github/workflows/Generate-StyleGuideArtifacts.ps1'
    $arrOutput = @(& $strPowerShell -NoLogo -NoProfile -NonInteractive -File $strScript)
    $intExit = $LASTEXITCODE
    Assert-GeneratorCondition -Condition ($arrOutput.Count -eq 1) -Label 'result cardinality'
    $objResult = $arrOutput[0] | ConvertFrom-Json -ErrorAction Stop
    Assert-GeneratorCondition -Condition ($objResult -is [pscustomobject] -and
        $objResult.Schema -ceq 'StyleGuide.GeneratorResult.v2' -and $objResult.Artifacts.Count -eq 4) -Label 'result schema'
    [pscustomobject]@{ ExitCode = $intExit; Result = $objResult }
}


function Assert-GeneratorByteSequence {
    # .SYNOPSIS
    # Compares all four fixture outputs with independent golden bytes.
    #
    # .DESCRIPTION
    # Byte comparison includes encoding, newline and complete payload identity.
    #
    # .PARAMETER Root
    # Absolute fixture repository directory.
    #
    # .PARAMETER Golden
    # Independently captured path-to-byte map.
    #
    # .EXAMPLE
    # Assert-GeneratorByteSequence -Root $strFixture -Golden $hashtableGolden
    #
    # # Rejects any output-byte drift.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # None. A mismatch terminates.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - Not public API. Parameters, return shape and
    # positional contract may change without notice. All parameters are named.
    #
    # Version: 1.0.20261005.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param ([string]$Root, [hashtable]$Golden)

    Assert-GeneratorCondition -Condition ($Golden.Count -eq 4) -Label 'golden cardinality'
    foreach ($strName in $Golden.Keys) {
        $arrBytes = [IO.File]::ReadAllBytes((Join-Path -Path $Root -ChildPath $strName))
        Assert-GeneratorCondition -Condition ([Convert]::ToBase64String($arrBytes) -ceq
            [Convert]::ToBase64String($Golden[$strName])) -Label ('golden ' + $strName)
    }
}


$boolPrimaryFailure = $false
try {
    # Load only the actual function declarations and fixed initialization. Never
    # dot-source the entry point, which would publish into the source checkout.
    $arrTokens = $null
    $arrErrors = $null
    $objSyntax = [System.Management.Automation.Language.Parser]::ParseInput($strGenerator, [ref]$arrTokens, [ref]$arrErrors)
    Assert-GeneratorCondition -Condition ($arrErrors.Count -eq 0) -Label 'generator parser'
    $arrFunctions = @($objSyntax.FindAll({ param($objNode)
                $objNode -is [System.Management.Automation.Language.FunctionDefinitionAst]
            }, $false))
    Assert-GeneratorCondition -Condition ($arrFunctions.Count -gt 0) -Label 'actual function extraction'
    . ([scriptblock]::Create($strGenerator.Substring(0, $arrFunctions[0].Extent.StartOffset)))
    foreach ($objFunction in $arrFunctions) {
        . ([scriptblock]::Create($objFunction.Extent.Text))
    }
    $strFixture = Join-Path -Path $strScratch -ChildPath 'actual'
    $strScripts = Join-Path -Path $strFixture -ChildPath '.github/workflows'
    [void][IO.Directory]::CreateDirectory($strScripts)
    [IO.File]::WriteAllText((Join-Path -Path $strScripts -ChildPath 'Generate-StyleGuideArtifacts.ps1'), $strGenerator, $objEncoding)
    $hashtableGolden = @{}
    $arrOutputNames = @('copilot-instructions.md', $script:hashtableLanguage.ScopedPath, 'STYLE_GUIDE_CHAT.md', 'STYLE_GUIDE_FULL.md')
    foreach ($strName in @('STYLE_GUIDE.md', 'STYLE_GUIDE_RATIONALE.md') + $arrOutputNames) {
        $arrBytes = [IO.File]::ReadAllBytes((Join-Path -Path $strRepository -ChildPath $strName))
        [IO.File]::WriteAllBytes((Join-Path -Path $strFixture -ChildPath $strName), $arrBytes)
        if ($arrOutputNames -ccontains $strName) {
            $hashtableGolden[$strName] = $arrBytes
        }
    }
    & $strGit -c core.hooksPath= -c core.autocrlf=false init --quiet $strFixture
    Assert-GeneratorCondition -Condition ($LASTEXITCODE -eq 0) -Label 'fixture init'
    & $strGit -C $strFixture -c core.autocrlf=false add --all
    Assert-GeneratorCondition -Condition ($LASTEXITCODE -eq 0) -Label 'fixture tracking'
    $objRun = Invoke-GeneratorFixture -Root $strFixture
    Assert-GeneratorCondition -Condition ($objRun.ExitCode -eq 0 -and $objRun.Result.Overall -ceq 'NoChange') -Label 'real no-change'
    Assert-GeneratorByteSequence -Root $strFixture -Golden $hashtableGolden
    $strCopilot = Join-Path -Path $strFixture -ChildPath 'copilot-instructions.md'
    foreach ($strMethod in @('File.Replace', 'File.Move')) {
        if ($strMethod -eq 'File.Replace') {
            [IO.File]::WriteAllText($strCopilot, "stale`n", $objEncoding)
        } else {
            [IO.File]::Delete($strCopilot)
        }
        $objRun = Invoke-GeneratorFixture -Root $strFixture
        Assert-GeneratorCondition -Condition ($objRun.ExitCode -eq 0 -and $objRun.Result.Overall -ceq 'Success') -Label 'real publication'
        $objArtifact = $objRun.Result.Artifacts[0]
        Assert-GeneratorCondition -Condition ($objArtifact.PublicationMethod -ceq $strMethod -and
            $objArtifact.CandidateOrdinaryIdentity -ceq $objArtifact.FinalOrdinaryIdentity -and
            $objArtifact.CandidateSha256 -ceq $objArtifact.FinalSha256) -Label 'candidate-final identity'
        Assert-GeneratorByteSequence -Root $strFixture -Golden $hashtableGolden
    }
    $objRun = Invoke-GeneratorFixture -Root $strFixture
    Assert-GeneratorCondition -Condition ($objRun.ExitCode -eq 0 -and $objRun.Result.Overall -ceq 'NoChange') -Label 'real determinism'
    Assert-GeneratorByteSequence -Root $strFixture -Golden $hashtableGolden

    # Every composition policy uses the same parsed sections and cleaner.
    $hashtableOriginalLanguage = $script:hashtableLanguage
    $objOriginalCulture = [Threading.Thread]::CurrentThread.CurrentCulture
    try {
        foreach ($strCulture in @('en-US', 'tr-TR')) {
            [Threading.Thread]::CurrentThread.CurrentCulture = [Globalization.CultureInfo]::GetCultureInfo($strCulture)
            $strGuide = "# Guide`n## GROUP`n### IDENTITY`n*This section intentionally left blank.*`n"
            $strRationale = "## Group Rationale`n### IDENTITY`n`nbody [guide](STYLE_GUIDE.md)`n#### Detail`nkept`n"
            $script:hashtableLanguage = $hashtableOriginalLanguage.Clone()
            $script:hashtableLanguage.Composition = 'HeadingLinked'
            $strFull = New-FullPayload -GuideContent $strGuide -RationaleContent $strRationale
            Assert-GeneratorCondition -Condition ($strFull.Contains("### IDENTITY`n`nbody") -and
                $strFull.Contains('#### Detail') -and -not $strFull.Contains('intentionally')) -Label 'culture heading composition'
            # Kill each actual casing site independently, rather than changing
            # both together (which can conceal matching culture-sensitive bugs).
            $strFullFunction = ($arrFunctions | Where-Object { $_.Name -eq 'New-FullPayload' }).Extent.Text
            $arrCasing = [regex]::Matches($strFullFunction, '\.ToLowerInvariant\(\)')
            Assert-GeneratorCondition -Condition ($arrCasing.Count -eq 2) -Label 'independent casing sites'
            if ($strCulture -eq 'tr-TR') {
                foreach ($objCasing in $arrCasing) {
                    $strMutant = $strFullFunction.Remove($objCasing.Index, $objCasing.Length).Insert($objCasing.Index, '.ToLower()')
                    $strMutatedOutput = & {
                        . ([scriptblock]::Create($strMutant))
                        New-FullPayload -GuideContent $strGuide -RationaleContent $strRationale
                    }
                    Assert-GeneratorCondition -Condition (-not $strMutatedOutput.Contains('body')) -Label 'casing mutation killed'
                }
            }
        }
        $script:hashtableLanguage = $hashtableOriginalLanguage.Clone()
        $script:hashtableLanguage.Composition = 'ExplicitBody'
        $script:hashtableLanguage.SummaryHeading = 'Executive Summary: Fixture'
        $script:hashtableLanguage.SummaryAnchor = 'executive-summary-fixture'
        $script:hashtableLanguage.SummaryBefore = 'Version Requirements'
        $script:hashtableLanguage.AppendStandalone = $true
        $strGuide = "# Guide`n- [Version Requirements](#version-requirements)`n`n---`n`n## Version Requirements`n<!-- RATIONALE: identity -->`n<!-- rationale-toc: - [Extra](#extra) -->`n<!-- rationale-anchor: extra -->`n"
        $strRationale = "## Executive Summary: Fixture`nsummary`n## Group Rationale`n### IDENTITY`nbody`n### Extra`nextra body`n## Recovery`nrecover [guide](STYLE_GUIDE.md)`n## Appendix`nappendix`n"
        $strFull = New-FullPayload -GuideContent $strGuide -RationaleContent $strRationale
        Assert-GeneratorCondition -Condition ($strFull.IndexOf('## Executive Summary: Fixture') -lt
            $strFull.IndexOf('## Version Requirements') -and $strFull.IndexOf('## Recovery') -lt $strFull.IndexOf('## Appendix') -and
            ([regex]::Matches($strFull, '## Executive Summary: Fixture')).Count -eq 1 -and
            $strFull.Contains("### Extra`n`nextra body") -and $strFull.Contains("## Version Requirements`nbody") -and
            -not $strFull.Contains('STYLE_GUIDE.md')) -Label 'marker summary standalone ordering'
        # Presence comes from all emitted content, not only inferred insertions.
        $strSummaryToc = '- [Executive Summary: Fixture](#executive-summary-fixture)'
        $strBoundary = "- [Version Requirements](#version-requirements)`n## Version Requirements`n"
        $arrSummaryCases = @(
            @{ Prefix = 'Executive Summary: Fixture is discussed here.'; TocCount = 0; HeadingCount = 1 },
            @{ Prefix = '## Executive Summary: Fixture'; TocCount = 0; HeadingCount = 1 },
            @{ Prefix = '<!-- rationale-toc: ' + $strSummaryToc + ' -->'; TocCount = 1; HeadingCount = 1 },
            @{ Prefix = '<!-- rationale-anchor: executive-summary-fixture -->'; TocCount = 0; HeadingCount = 1 },
            @{ Prefix = "# Guide`n" + ("`n---`n" * 100); TocCount = 1; HeadingCount = 1 }
        )
        foreach ($hashtableCase in $arrSummaryCases) {
            $strFull = New-FullPayload -GuideContent ($hashtableCase.Prefix + "`n" + ($strBoundary * 100)) -RationaleContent $strRationale
            Assert-GeneratorCondition -Condition (
                ([regex]::Matches($strFull, [regex]::Escape($strSummaryToc))).Count -eq $hashtableCase.TocCount -and
                ([regex]::Matches($strFull, '(?m)^## Executive Summary: Fixture$')).Count -eq $hashtableCase.HeadingCount
            ) -Label 'summary presence across repeated boundaries'
        }
        $boolRejected = $false
        try {
            $null = New-FullPayload -GuideContent '<!-- RATIONALE: absent -->' -RationaleContent $strRationale
        } catch {
            $boolRejected = $_.Exception.Message -ceq 'missing-rationale-anchor'
        }
        Assert-GeneratorCondition -Condition $boolRejected -Label 'missing anchor refusal'
    } finally {
        $script:hashtableLanguage = $hashtableOriginalLanguage
        [Threading.Thread]::CurrentThread.CurrentCulture = $objOriginalCulture
    }
    $strFence = '`' * 4096
    $strChat = New-ChatPayload -GuideContent ($strFence + "`n")
    Assert-GeneratorCondition -Condition ($strChat.Contains(('`' * 4097) + 'markdown')) -Label 'large fence sizing'
    $arrNormalized = ConvertTo-NormalizedUtf8 -CompleteFinalPayload "a`r`nb`rc`n"
    Assert-GeneratorCondition -Condition ($objEncoding.GetString($arrNormalized) -ceq "a`nb`nc`n") -Label 'LF serialization'

    $strGuidePath = Join-Path -Path $strFixture -ChildPath 'STYLE_GUIDE.md'
    $arrGuideBytes = [IO.File]::ReadAllBytes($strGuidePath)
    foreach ($arrBadBytes in @([byte[]]@(239, 187, 191, 65), [byte[]]@(195, 40))) {
        [IO.File]::WriteAllBytes($strGuidePath, $arrBadBytes)
        $objRun = Invoke-GeneratorFixture -Root $strFixture
        Assert-GeneratorCondition -Condition ($objRun.ExitCode -ne 0 -and $objRun.Result.Overall -ceq 'Failed') -Label 'invalid source encoding'
        Assert-GeneratorByteSequence -Root $strFixture -Golden $hashtableGolden
    }
    [IO.File]::WriteAllBytes($strGuidePath, $arrGuideBytes)
    $strAlias = Join-Path -Path $strFixture -ChildPath 'alias.md'
    $null = New-Item -ItemType HardLink -Path $strAlias -Value $strGuidePath
    $objRun = Invoke-GeneratorFixture -Root $strFixture
    Assert-GeneratorCondition -Condition ($objRun.ExitCode -ne 0) -Label 'real hard-link refusal'
    [IO.File]::Delete($strAlias)

    # A post-publication identity failure is injected into a scratch copy only.
    $strMutation = $strGenerator.Replace('$strFinalIdentityBeforeRead = Get-OrdinaryFileIdentity -LiteralPath $strDestinationPath',
        "throw 'injected-final-identity-failure'")
    Assert-GeneratorCondition -Condition ($strMutation -cne $strGenerator) -Label 'publication mutation applied'
    [IO.File]::WriteAllText((Join-Path -Path $strScripts -ChildPath 'Generate-StyleGuideArtifacts.ps1'), $strMutation, $objEncoding)
    [IO.File]::WriteAllText($strCopilot, "stale`n", $objEncoding)
    $objRun = Invoke-GeneratorFixture -Root $strFixture
    Assert-GeneratorCondition -Condition ($objRun.ExitCode -ne 0 -and
        $objRun.Result.Overall -ceq 'ReplacementStateUncertain' -and
        $objRun.Result.Artifacts[0].PublicationReturned) -Label 'uncertain publication fails closed'

    # Inject stable final observations that differ from the candidate. The bytes
    # and publication are real; this is not a native substitution or race test.
    $strBeforeIdentityRead = '$strFinalIdentityBeforeRead = Get-OrdinaryFileIdentity -LiteralPath $strDestinationPath'
    $strAfterIdentityRead = '$hashtableRecord.FinalOrdinaryIdentity = Get-OrdinaryFileIdentity -LiteralPath $strDestinationPath'
    $strCandidateEqualityGuard = 'if ($hashtableRecord.FinalOrdinaryIdentity -cne $strCandidateIdentity) {'
    foreach ($strTarget in @($strBeforeIdentityRead, $strAfterIdentityRead, $strCandidateEqualityGuard)) {
        Assert-GeneratorCondition -Condition (
            ([regex]::Matches($strGenerator, [regex]::Escape($strTarget))).Count -eq 1
        ) -Label 'candidate equality injection target'
    }
    $strIdentityInjection = $strGenerator.Replace($strBeforeIdentityRead,
        '$strFinalIdentityBeforeRead = $strCandidateIdentity + '':injected-final''').Replace($strAfterIdentityRead,
        '$hashtableRecord.FinalOrdinaryIdentity = $strFinalIdentityBeforeRead')
    foreach ($boolDisableCandidateEquality in @($false, $true)) {
        $strControlledGenerator = $strIdentityInjection
        if ($boolDisableCandidateEquality) {
            $strControlledGenerator = $strIdentityInjection.Replace($strCandidateEqualityGuard, 'if ($false) {')
        }
        [IO.File]::WriteAllText((Join-Path -Path $strScripts -ChildPath 'Generate-StyleGuideArtifacts.ps1'),
            $strControlledGenerator, $objEncoding)
        foreach ($strMethod in @('File.Replace', 'File.Move')) {
            if ($strMethod -eq 'File.Replace') {
                [IO.File]::WriteAllText($strCopilot, "stale`n", $objEncoding)
            } else {
                [IO.File]::Delete($strCopilot)
            }
            $objRun = Invoke-GeneratorFixture -Root $strFixture
            $objArtifact = $objRun.Result.Artifacts[0]
            Assert-GeneratorCondition -Condition ($objArtifact.PublicationReturned -and
                $objArtifact.PublicationMethod -ceq $strMethod -and $objArtifact.FinalState -ceq 'Existing' -and
                $objArtifact.FinalOrdinaryIdentity -ceq ($objArtifact.CandidateOrdinaryIdentity + ':injected-final') -and
                $objArtifact.CandidateOrdinaryIdentity -cne $objArtifact.FinalOrdinaryIdentity -and
                $objArtifact.CandidateLength -eq $objArtifact.FinalLength -and
                $objArtifact.CandidateSha256 -ceq $objArtifact.FinalSha256) -Label 'injected same-byte different-identity publication'
            $boolIdentityRefusal = $objRun.ExitCode -ne 0 -and
                $objRun.Result.Overall -ceq 'ReplacementStateUncertain' -and
                $objArtifact.Status -ceq 'ReplacementStateUncertain' -and
                $objRun.Result.Phase -ceq 'verify-publication' -and
                $objRun.Result.Category -ceq 'filesystem-state-uncertain'
            if ($boolDisableCandidateEquality) {
                Assert-GeneratorCondition -Condition (-not $boolIdentityRefusal -and $objRun.ExitCode -eq 0 -and
                    $objRun.Result.Overall -ceq 'Success' -and $objArtifact.Status -ceq 'Success') -Label 'candidate equality mutation killed'
            } else {
                Assert-GeneratorCondition -Condition $boolIdentityRefusal -Label 'candidate identity mismatch fails closed'
            }
            Assert-GeneratorByteSequence -Root $strFixture -Golden $hashtableGolden
        }
    }
    [IO.File]::WriteAllText((Join-Path -Path $strScripts -ChildPath 'Generate-StyleGuideArtifacts.ps1'), $strGenerator, $objEncoding)

    # Synthetic Unix dispatch controls execute the actual identity function.
    $strIdentityFunction = ($arrFunctions | Where-Object { $_.Name -eq 'Get-OrdinaryFileIdentity' }).Extent.Text
    foreach ($strPlatform in @('Linux', 'MacOS', 'FreeBsd', 'Unknown')) {
        foreach ($strMode in @('clean', 'native-failure', 'empty', 'multiline', 'hardlink')) {
            $strControlled = [regex]::Replace($strIdentityFunction,
                '(?s)\$boolHostIs(Linux|MacOS|FreeBsd) = \[System.Runtime.InteropServices.RuntimeInformation\]::IsOSPlatform\(.+?\n    \)',
                { param($objMatch) '$boolHostIs' + $objMatch.Groups[1].Value + ' = $' +
                    ($objMatch.Groups[1].Value -eq $strPlatform).ToString().ToLowerInvariant() })
            $objProbe = & {
                $script:boolHostIsWindows = $false
                $script:arrStatArguments = @()
                function stat {
                    $script:arrStatArguments = @($args)
                    $global:LASTEXITCODE = if ($strMode -eq 'native-failure') { 7 } else { 0 }
                    if ($strMode -ne 'empty') {
                        if ($strMode -eq 'hardlink') { '2:123:456' } else { '1:123:456' }
                    }
                    if ($strMode -eq 'multiline') { '1:123:456' }
                }
                . ([scriptblock]::Create($strControlled))
                $strOutcome = $null
                try { $strOutcome = Get-OrdinaryFileIdentity -LiteralPath '/fixture' } catch { $strOutcome = $_.Exception.Message }
                [pscustomobject]@{ Outcome = $strOutcome; Arguments = $script:arrStatArguments }
            }
            $strExpected = if ($strPlatform -eq 'Unknown') { 'unsupported-platform' }
            elseif ($strMode -eq 'clean') { '123:456' }
            elseif ($strMode -eq 'hardlink') { 'hardlink-alias' }
            else { 'identity-failure' }
            Assert-GeneratorCondition -Condition ($objProbe.Outcome -ceq $strExpected) -Label 'synthetic identity result'
            if ($strPlatform -ne 'Unknown') {
                $strExpectedFlag = if ($strPlatform -eq 'Linux') { '-Lc' } else { '-f' }
                Assert-GeneratorCondition -Condition ($objProbe.Arguments.Count -ge 3 -and
                    $objProbe.Arguments[0] -ceq $strExpectedFlag) -Label 'synthetic identity dispatch'
            }
            # Each guard is removed independently; its own existing refusal oracle
            # must then fail. These are synthetic function probes, not native stat.
            if ($strPlatform -eq 'Linux' -and $strMode -in @('native-failure', 'multiline', 'hardlink')) {
                $strGuard = switch ($strMode) {
                    'native-failure' { '$intStatExit -ne 0 -or ' }
                    'multiline' { '$arrStatOutput.Count -ne 1 -or' }
                    'hardlink' { '[uint64]$Matches[1] -ne 1' }
                }
                $strReplacement = if ($strMode -eq 'hardlink') { '$false' } else { '' }
                $strMutant = $strControlled.Replace($strGuard, $strReplacement)
                Assert-GeneratorCondition -Condition ($strMutant -cne $strControlled) -Label 'identity guard mutation applied'
                $strMutantOutcome = & {
                    $script:boolHostIsWindows = $false
                    function stat {
                        $global:LASTEXITCODE = if ($strMode -eq 'native-failure') { 7 } else { 0 }
                        if ($strMode -eq 'hardlink') { '2:123:456' } else { '1:123:456' }
                        if ($strMode -eq 'multiline') { '1:123:456' }
                    }
                    . ([scriptblock]::Create($strMutant))
                    try { Get-OrdinaryFileIdentity -LiteralPath '/fixture' } catch { $_.Exception.Message }
                }
                Assert-GeneratorCondition -Condition ($strMutantOutcome -ceq '123:456' -and
                    $strMutantOutcome -cne $strExpected) -Label 'independent identity guard mutation killed'
            }
        }
    }
} catch {
    $boolPrimaryFailure = $true
    throw
} finally {
    $strCleanupFailure = $null
    try {
        # Only this invocation's independently named child may be removed.
        $strResolvedScratch = [IO.Path]::GetFullPath($strScratch)
        if ([IO.Path]::GetDirectoryName($strResolvedScratch).TrimEnd('\', '/') -cne $strScratchParent.TrimEnd('\', '/') -or
            [IO.Path]::GetFileName($strResolvedScratch) -cnotmatch '^styleguide-generator-[0-9a-f]{32}$') {
            $strCleanupFailure = 'generator-test: cleanup containment failure'
        } else {
            Remove-Item -LiteralPath $strResolvedScratch -Recurse -Force
        }
    } catch {
        # Classify cleanup without exposing its details or replacing the primary error.
        $strCleanupFailure = 'generator-test: cleanup failed'
    }
    if ($null -ne $strCleanupFailure) {
        if ($boolPrimaryFailure) {
            Write-Warning -Message $strCleanupFailure -WarningAction Continue
        } else {
            throw $strCleanupFailure
        }
    }
}
'Generator tests passed: {0} assertions; edition={1}; version={2}; executable={3}; storage={4}; image={5}/{6}.' -f
    $script:intAssertions, $PSVersionTable.PSEdition, $PSVersionTable.PSVersion, $strPowerShell, $strStorage,
    $env:ImageOS, $env:ImageVersion
