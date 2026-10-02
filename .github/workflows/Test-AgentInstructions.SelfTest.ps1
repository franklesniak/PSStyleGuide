# .SYNOPSIS
# Runs the extracted metadata and bounded-input self-tests.
#
# .DESCRIPTION
# Validates final-state metadata arithmetic, authenticated endpoint handling,
# bounded input readers and linked-path rejection with functions loaded by
# Test-AgentInstructions.ps1.
#
# .PARAMETER RepositoryRootPath
# The absolute path of the repository that supplies Git and document fixtures.
#
# .PARAMETER Revision
# The exact Git commit used as an authenticated endpoint fixture.
#
# .PARAMETER MaximumBytes
# The maximum permitted byte count for bounded Git path reads.
#
# .PARAMETER MaximumMetadataUtcDate
# The latest trusted UTC calendar date permitted in metadata fixtures.
#
# .EXAMPLE
# & ./Test-AgentInstructions.SelfTest.ps1 @hashtableArguments
#
# # Runs the extracted self-tests with validated named arguments.
#
# .INPUTS
# None. This script does not accept pipeline input.
#
# .OUTPUTS
# None. The script throws when a self-test fails.
#
# .NOTES
# Version: 1.5.20261002.0

[CmdletBinding(PositionalBinding = $false)]
[OutputType([void])]
param(
    [Parameter(Mandatory)][string] $RepositoryRootPath,
    [Parameter(Mandatory)][string] $Revision,
    [Parameter(Mandatory)]
    [ValidateRange(1, 2147483646)]
    [int] $MaximumBytes,
    [Parameter(Mandatory)]
    [ValidatePattern('^\d{4}-\d{2}-\d{2}$')]
    [string] $MaximumMetadataUtcDate
)

function Assert-DocumentMetadataClassificationSelfTest {
    # .SYNOPSIS
    # Exercises classification coverage and trusted-baseline exemption safety.
    #
    # .DESCRIPTION
    # Checks malformed data, undiscovered governed documents, and attempted
    # candidate-only exemptions through the actual classification consumers.
    #
    # .PARAMETER MaximumMetadataUtcDate
    # The trusted finalization UTC date used by the loaded validator.
    #
    # .EXAMPLE
    # Assert-DocumentMetadataClassificationSelfTest -MaximumMetadataUtcDate '2026-10-02'
    #
    # # Throws if classification permits an unsafe exemption or misses a path.
    #
    # .INPUTS
    # None. This function does not accept pipeline input.
    #
    # .OUTPUTS
    # None. The function throws when a security fixture is accepted.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER. Positional parameters are disabled.
    # Version: 1.0.20261002.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param([Parameter(Mandatory)][string] $MaximumMetadataUtcDate)

    $arrTrackedFixturePaths = @(
        'README.md', 'generated.md', '.cursor/rules/operations.mdc',
        'docs/RUNBOOK.md', 'docs/decisions/0001-safety.md')
    $strValidClassification = '{"schemaVersion":2,"authorizedExemptionPaths":[],' +
        '"tier2Paths":["README.md"],"generatedPaths":["generated.md"]}'
    $objValidContext = Get-DocumentMetadataClassificationContext `
        -Content $strValidClassification -TrackedPath $arrTrackedFixturePaths
    if ($null -ne $objValidContext.Failure) {
        throw 'The valid exact classification fixture was rejected.'
    }
    $arrDiscoveredFixturePaths = @(Get-DiscoveredGovernedMarkdownDocumentPath `
            -CandidatePath $arrTrackedFixturePaths `
            -KnownGovernedPath @('docs/decisions/0001-safety.md') `
            -ExemptPath $objValidContext.ExemptPaths)
    if ($arrDiscoveredFixturePaths.Count -ne 2 -or
        $arrDiscoveredFixturePaths -cnotcontains '.cursor/rules/operations.mdc' -or
        $arrDiscoveredFixturePaths -cnotcontains 'docs/RUNBOOK.md') {
        throw 'New or hidden governed Markdown escaped classification discovery.'
    }
    foreach ($strDiscoveredFixturePath in $arrDiscoveredFixturePaths) {
        $objMissingMetadataContext = Get-DocumentMetadataContext `
            -Content "# Operational procedure`n`nRun the reviewed procedure.`n" `
            -RequiresVersion $false
        if ($null -eq $objMissingMetadataContext.Failure) {
            throw "Discovered governed content accepted a missing header: $strDiscoveredFixturePath"
        }
    }

    $arrInvalidClassificationFixtures = @(
        $strValidClassification.Replace('"schemaVersion":2', '"schemaVersion":1'),
        $strValidClassification.Replace('"schemaVersion":2', '"schemaVersion":"2"'),
        $strValidClassification.Replace('"schemaVersion":2,', ''),
        $strValidClassification.Replace('"schemaVersion":2', '"schemaVersion":2,"schemaVersion":2'),
        $strValidClassification.Replace('"schemaVersion":2', '"schemaVersion":2,"unknown":true'),
        $strValidClassification.Replace('"tier2Paths":["README.md"]', '"tier2Paths":null'),
        $strValidClassification.Replace('"README.md"', '42'),
        $strValidClassification.Replace('"README.md"', '"README.md","README.md"'),
        $strValidClassification.Replace('"README.md"', '"generated.md","README.md"'),
        $strValidClassification.Replace('"README.md"', '"untracked.md"'),
        $strValidClassification.Replace('"generated.md"', '"README.md"'),
        $strValidClassification.Replace('"README.md"', '"../README.md"'),
        $strValidClassification.Replace('"README.md"', '"/README.md"'),
        $strValidClassification.Replace('"README.md"', '"docs\\README.md"'),
        $strValidClassification.Replace('"README.md"', '"README\u000a.md"'),
        $strValidClassification.Replace('"README.md"', '"README.txt"'),
        $strValidClassification.Replace('"authorizedExemptionPaths":[]', '"authorizedExemptionPaths":null'),
        $strValidClassification.Replace('"authorizedExemptionPaths":[]', '"authorizedExemptionPaths":["README.md"]'),
        $strValidClassification.Replace('"authorizedExemptionPaths":[]', '"authorizedExemptionPaths":["../future.md"]'),
        $strValidClassification.Replace('"authorizedExemptionPaths":[]', '"authorizedExemptionPaths":["future.md","future.md"]'),
        $strValidClassification.Replace('"authorizedExemptionPaths":[]', '"authorizedExemptionPaths":["z.md","a.md"]'),
        $strValidClassification.Replace('"schemaVersion":2', '"schemaVersion":[[[[[[[[[[2]]]]]]]]]]'),
        $strValidClassification.Replace('"schemaVersion":2', '"schemaVersion":2/*comment*/'),
        $strValidClassification.TrimEnd('}') + ',}'
    )
    foreach ($strInvalidClassification in $arrInvalidClassificationFixtures) {
        $objInvalidContext = Get-DocumentMetadataClassificationContext `
            -Content $strInvalidClassification -TrackedPath $arrTrackedFixturePaths
        if ($null -eq $objInvalidContext.Failure) {
            throw "An unsafe classification fixture was accepted: $strInvalidClassification"
        }
    }

    $arrCandidateActivePaths = @('README.md', 'docs/RUNBOOK.md')
    $arrCandidateOnlyFailures = @(Get-DocumentMetadataClassificationExpansionFailure `
            -HasTrustedBaselineManifest $true `
            -TrustedBaselineExemptPath @('README.md') `
            -TrustedBaselineAuthorizedExemptionPath @() `
            -CandidateExemptPath $arrCandidateActivePaths)
    if ($arrCandidateOnlyFailures.Count -ne 1 -or
        $arrCandidateOnlyFailures[0] -notmatch 'docs/RUNBOOK\.md') {
        throw 'Candidate-only metadata exemption bypassed the trusted baseline.'
    }
    $strCandidateAuthorization = $strValidClassification.Replace(
        '"authorizedExemptionPaths":[]',
        '"authorizedExemptionPaths":["docs/RUNBOOK.md"]')
    $objCandidateAuthorizationContext = Get-DocumentMetadataClassificationContext `
        -Content $strCandidateAuthorization -TrackedPath $arrTrackedFixturePaths
    if ($null -ne $objCandidateAuthorizationContext.Failure -or
        $objCandidateAuthorizationContext.ExemptPaths -ccontains 'docs/RUNBOOK.md') {
        throw 'A candidate future authorization became an active exemption.'
    }
    $arrAuthorizedFailures = @(Get-DocumentMetadataClassificationExpansionFailure `
            -HasTrustedBaselineManifest $true `
            -TrustedBaselineExemptPath @('README.md') `
            -TrustedBaselineAuthorizedExemptionPath @('docs/RUNBOOK.md') `
            -CandidateExemptPath $arrCandidateActivePaths)
    if ($arrAuthorizedFailures.Count -ne 0) {
        throw 'The exact trusted baseline authorization was rejected.'
    }
    $arrWrongAuthorizationFailures = @(Get-DocumentMetadataClassificationExpansionFailure `
            -HasTrustedBaselineManifest $true `
            -TrustedBaselineExemptPath @('README.md') `
            -TrustedBaselineAuthorizedExemptionPath @('docs/another.md') `
            -CandidateExemptPath $arrCandidateActivePaths)
    if ($arrWrongAuthorizationFailures.Count -ne 1) {
        throw 'An authorization for another path permitted the candidate exemption.'
    }
    $arrBootstrapFailures = @(Get-DocumentMetadataClassificationExpansionFailure `
            -HasTrustedBaselineManifest $false `
            -TrustedBaselineExemptPath @() `
            -TrustedBaselineAuthorizedExemptionPath @() `
            -CandidateExemptPath $objValidContext.ExemptPaths)
    if ($arrBootstrapFailures.Count -ne 0) {
        throw 'Initial exact-path classification bootstrap was rejected.'
    }
    foreach ($strUnsafeDiscoveryPath in @('../escape.md', '/root.md', 'docs\bad.md')) {
        $boolDiscoveryRejected = $false
        try {
            $null = @(Get-DiscoveredGovernedMarkdownDocumentPath `
                    -CandidatePath @($strUnsafeDiscoveryPath) `
                    -KnownGovernedPath @() -ExemptPath @())
        } catch {
            $boolDiscoveryRejected = $true
        }
        if (-not $boolDiscoveryRejected) {
            throw "Unsafe tracked document discovery was accepted: $strUnsafeDiscoveryPath"
        }
    }
    $boolGovernedExemptionRejected = $false
    try {
        $null = @(Get-DiscoveredGovernedMarkdownDocumentPath `
                -CandidatePath @('docs/RUNBOOK.md') `
                -KnownGovernedPath @('docs/RUNBOOK.md') `
                -ExemptPath @('docs/RUNBOOK.md'))
    } catch {
        $boolGovernedExemptionRejected = $true
    }
    if (-not $boolGovernedExemptionRejected) {
        throw 'A known governed document was allowed to exempt itself.'
    }

    foreach ($objIgnoreFixture in @(
            [pscustomobject]@{ Path = 'CLAUDE.local.md'; Rules = "CLAUDE.local.md`n"; Expected = $true },
            [pscustomobject]@{ Path = 'nested/CLAUDE.local.md'; Rules = "CLAUDE.local.md`n"; Expected = $true },
            [pscustomobject]@{ Path = 'nested/CLAUDE.local.md'; Rules = "/CLAUDE.local.md`n"; Expected = $false },
            [pscustomobject]@{ Path = 'CLAUDE.local.md'; Rules = "CLAUDE.local.md`n!CLAUDE.local.md`n"; Expected = $false },
            [pscustomobject]@{ Path = 'nested/CLAUDE.local.md'; Rules = "CLAUDE.local.md`n!nested/CLAUDE.local.md`n"; Expected = $false },
            [pscustomobject]@{ Path = 'CLAUDE.md'; Rules = "CLAUDE.local.md`n"; Expected = $false },
            [pscustomobject]@{ Path = 'nested/CLAUDE.md'; Rules = "CLAUDE.local.md`n"; Expected = $false },
            [pscustomobject]@{ Path = 'CLAUDE.md'; Rules = "CLAUDE*.md`n"; Expected = $true }
        )) {
        $boolIgnoreResult = Test-GitIgnorePathEffective `
            -GitIgnoreContent $objIgnoreFixture.Rules `
            -RepositoryRelativePath $objIgnoreFixture.Path
        if ($boolIgnoreResult -ne $objIgnoreFixture.Expected) {
            throw "Personal-memory ignore scope fixture failed: $($objIgnoreFixture.Path)"
        }
    }

    $arrTimestampFixtures = @(
        '2026-10-29T23:59:59Z',
        '2026-10-29T23:59:59.123456789+05:45',
        '2026-10-29T23:59:59.000000001-07:30')
    $strTimestampMarkdown = 'Values: ' +
        (($arrTimestampFixtures | ForEach-Object { '`' + $_ + '`' }) -join ', ') + ".`n"
    $objTimestampContext = Get-MarkdownParseContext -Content $strTimestampMarkdown -LineCount 2
    $arrActualTimestampValues = @($objTimestampContext.ProseBlocks[0].Code)
    if ($arrActualTimestampValues.Count -ne $arrTimestampFixtures.Count) {
        throw 'The real Markdown parser lost timestamp code spans.'
    }
    for ($intTimestampIndex = 0; $intTimestampIndex -lt $arrTimestampFixtures.Count; $intTimestampIndex++) {
        if ($arrActualTimestampValues[$intTimestampIndex] -isnot [string] -or
            $arrActualTimestampValues[$intTimestampIndex] -cne $arrTimestampFixtures[$intTimestampIndex]) {
            throw 'The real Markdown parser changed timestamp type, offset or precision.'
        }
    }
    $objTypedJson = ConvertFrom-ParserJsonContext `
        -Content '{"empty":[],"one":[null],"nested":[[1]],"null":null,"true":true,"false":false,"integer":1,"decimal":1.25,"text":"2026-10-29T23:59:59.123456789+05:45"}' `
        -MaximumBytes 4096
    if ($objTypedJson.empty -isnot [array] -or $objTypedJson.empty.Count -ne 0 -or
        $objTypedJson.one -isnot [array] -or $objTypedJson.one.Count -ne 1 -or
        $null -ne $objTypedJson.one[0] -or $objTypedJson.nested[0] -isnot [array] -or
        $null -ne $objTypedJson.null -or $objTypedJson.true -isnot [bool] -or
        -not $objTypedJson.true -or $objTypedJson.false -isnot [bool] -or $objTypedJson.false -or
        $objTypedJson.integer -isnot [int64] -or $objTypedJson.integer -ne 1 -or
        $objTypedJson.decimal -isnot [double] -or $objTypedJson.decimal -ne 1.25 -or
        $objTypedJson.text -isnot [string] -or $objTypedJson.text -cne $arrTimestampFixtures[1]) {
        throw 'Parser JSON decoding changed typed context shape.'
    }
    foreach ($strInvalidParserJson in @(
            '[]', '{"a":1,"a":2}', '{"a":1,"A":2}', '{"a":1,}',
            '{"a":/* comment */1}', '{"a":1e400}',
            ('{"a":' + ('[' * 65) + '1' + (']' * 65) + '}'),
            ('{"a":"' + ('x' * 4096) + '"}'))) {
        $boolParserJsonRejected = $false
        try {
            $null = ConvertFrom-ParserJsonContext -Content $strInvalidParserJson -MaximumBytes 4096
        } catch {
            $boolParserJsonRejected = $true
        }
        if (-not $boolParserJsonRejected) {
            throw 'Parser JSON decoding accepted malformed, ambiguous or unbounded input.'
        }
    }

    $strProvedPriorValidatorSha256 = '5a61845f756be1d1bc4ddb772ffbc6c71ab525f0394d11d8c672f998a05fb4a5'
    $strLegacyMetadataContent = "# Procedure`n`n- **Status:** Active`n- **Owner:** Maintainers`n- **Last Updated:** 2026-10-01`n- **Scope:** Operational procedure.`n"
    $strInitialGovernedContent = "# Procedure`n`n## Metadata`n`n- **Status:** Active`n- **Owner:** Maintainers`n- **Last Updated:** $MaximumMetadataUtcDate`n- **Scope:** Operational procedure.`n"
    foreach ($objBootstrapFixture in @(
            [pscustomobject]@{ Name = 'valid first governed state'; Path = 'docs/RUNBOOK.md'; Manifest = $false; Current = $strInitialGovernedContent; ExpectedFailure = $false },
            [pscustomobject]@{ Name = 'invalid first governed state'; Path = 'docs/RUNBOOK.md'; Manifest = $false; Current = $strLegacyMetadataContent; ExpectedFailure = $true },
            [pscustomobject]@{ Name = 'stale first governed state'; Path = 'docs/RUNBOOK.md'; Manifest = $false; Current = $strInitialGovernedContent.Replace($MaximumMetadataUtcDate, '2020-01-01'); ExpectedFailure = $true },
            [pscustomobject]@{ Name = 'existing manifest keeps parent checks'; Path = 'docs/RUNBOOK.md'; Manifest = $true; Current = $strInitialGovernedContent; ExpectedFailure = $true },
            [pscustomobject]@{ Name = 'prior governed path keeps parent checks'; Path = 'AGENTS.md'; Manifest = $false; Current = $strInitialGovernedContent; ExpectedFailure = $true }
        )) {
        $boolInitialCoverageFixture = Test-InitialMetadataCoveragePath `
            -HasTrustedBaselineManifest $objBootstrapFixture.Manifest `
            -TrustedBaselineValidatorSha256 $strProvedPriorValidatorSha256 `
            -RepositoryRelativePath $objBootstrapFixture.Path
        $objFixtureBaseContent = $strLegacyMetadataContent
        if ($boolInitialCoverageFixture) { $objFixtureBaseContent = $null }
        $arrBootstrapMetadataFailures = @(Get-PublishedEndpointLastUpdatedFailure `
                -Name $objBootstrapFixture.Path -CurrentContent $objBootstrapFixture.Current `
                -BaseContent $objFixtureBaseContent -TrustedEventUtcDate '' `
                -RequireCurrentMaximumDateForRenderedChange $boolInitialCoverageFixture)
        if (($arrBootstrapMetadataFailures.Count -gt 0) -ne $objBootstrapFixture.ExpectedFailure) {
            throw "Initial metadata coverage fixture failed: $($objBootstrapFixture.Name)"
        }
    }
    # Candidate classification/catalog choices are not inputs to proved prior coverage.
    foreach ($strPriorGovernedFixturePath in @('AGENTS.md', 'docs/decisions/0001-safety.md', '.github/workflows/scripts-README.md')) {
        if (Test-InitialMetadataCoveragePath -HasTrustedBaselineManifest $false `
                -TrustedBaselineValidatorSha256 $strProvedPriorValidatorSha256 `
                -RepositoryRelativePath $strPriorGovernedFixturePath) {
            throw 'Candidate reclassification escaped proved prior governed coverage.'
        }
    }
    $boolUnknownCoverageRejected = $false
    try {
        $null = Test-InitialMetadataCoveragePath -HasTrustedBaselineManifest $false `
            -TrustedBaselineValidatorSha256 ('0' * 64) -RepositoryRelativePath 'docs/RUNBOOK.md'
    } catch { $boolUnknownCoverageRejected = $true }
    if (-not $boolUnknownCoverageRejected) {
        throw 'Unknown trusted prior validator coverage was accepted.'
    }
}

function Assert-PublishedMetadataGitFixture {
    # .SYNOPSIS
    # Tests final-state metadata on a real three-commit scratch branch.
    #
    # .DESCRIPTION
    # Reads baseline, invalid intermediate and valid final bytes from Git.
    # Proves the published endpoint comparison does not walk topic transitions.
    #
    # .PARAMETER MaximumMetadataUtcDate
    # The trusted UTC date used for the final fixture metadata.
    #
    # .EXAMPLE
    # Assert-PublishedMetadataGitFixture -MaximumMetadataUtcDate '2026-10-02'
    #
    # # Throws when invalid intermediate metadata poisons a valid final state.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None. The function throws if a fixture fails.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER. Positional parameters are disabled.
    # Version: 1.0.20261002.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param([Parameter(Mandatory)][string] $MaximumMetadataUtcDate)

    $strTempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    $strFixtureRoot = [IO.Path]::GetFullPath([IO.Path]::Combine(
            $strTempRoot, 'agent-metadata-endpoints-' + [Guid]::NewGuid().ToString('N')))
    if (-not $strFixtureRoot.StartsWith($strTempRoot, [StringComparison]::OrdinalIgnoreCase) -or
        $strFixtureRoot -ceq $strTempRoot) {
        throw 'The published metadata fixture root is unsafe.'
    }
    $strEmptyHooks = [IO.Path]::Combine($strFixtureRoot, 'empty-hooks')
    [void][IO.Directory]::CreateDirectory($strEmptyHooks)
    $strFixtureFile = [IO.Path]::Combine($strFixtureRoot, 'fixture.md')
    $strPriorDate = [DateTime]::ParseExact($MaximumMetadataUtcDate, 'yyyy-MM-dd',
        [Globalization.CultureInfo]::InvariantCulture).AddDays(-1).ToString(
        'yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture)
    $strBaselineContent = "# Fixture`n`n**Version:** 1.0.$($strPriorDate.Replace('-', '')).0`n`n## Metadata`n`n- **Status:** Active`n- **Owner:** Fixture Maintainers`n- **Last Updated:** $strPriorDate`n- **Scope:** Published endpoint regression.`n`n## Content`n`nPublished baseline.`n"
    $strIntermediateContent = $strBaselineContent.Replace('Published baseline.', 'Intermediate change without metadata advancement.')
    $strFinalContent = $strBaselineContent.Replace($strPriorDate, $MaximumMetadataUtcDate).
        Replace($strPriorDate.Replace('-', ''), $MaximumMetadataUtcDate.Replace('-', '')).
        Replace('Published baseline.', 'Corrected final state.')
    $listRevisions = [Collections.Generic.List[string]]::new()
    try {
        & git -c "init.templateDir=$strEmptyHooks" -C $strFixtureRoot init --quiet --initial-branch=topic
        if ($LASTEXITCODE -ne 0) { throw 'Could not initialize the metadata branch fixture.' }
        foreach ($strContent in @($strBaselineContent, $strIntermediateContent, $strFinalContent)) {
            [IO.File]::WriteAllText($strFixtureFile, $strContent, [Text.UTF8Encoding]::new($false))
            & git -c core.autocrlf=false -C $strFixtureRoot add -- fixture.md
            if ($LASTEXITCODE -ne 0) { throw 'Could not index the metadata branch fixture.' }
            & git -C $strFixtureRoot -c user.name=MetadataFixture `
                -c user.email=metadata-fixture@example.invalid -c commit.gpgsign=false `
                -c "core.hooksPath=$strEmptyHooks" commit --quiet --no-gpg-sign --message=fixture
            if ($LASTEXITCODE -ne 0) { throw 'Could not commit the metadata branch fixture.' }
            $strRevision = [string](& git -C $strFixtureRoot rev-parse --verify 'HEAD^{commit}')
            if ($LASTEXITCODE -ne 0 -or $strRevision.Trim() -cnotmatch '^[0-9a-f]{40}$') {
                throw 'Could not read the metadata fixture commit identity.'
            }
            $listRevisions.Add($strRevision.Trim())
        }
        if (@($listRevisions | Select-Object -Unique).Count -ne 3) {
            throw 'The metadata branch fixture did not create three distinct commits.'
        }
        $arrCommittedContent = @(foreach ($strRevision in $listRevisions) {
                Read-GitRevisionText -RepositoryRootPath $strFixtureRoot `
                    -Revision $strRevision -RepositoryRelativePath 'fixture.md' `
                    -MaximumBytes 4096 -RequireRegularFile
            })
        $arrIntermediateFailures = @(Get-PublishedEndpointMetadataFailure `
                -Name 'fixture.md' -CurrentContent $arrCommittedContent[1] `
                -ParentContent $arrCommittedContent[0] -ExpectedUtcDate $MaximumMetadataUtcDate `
                -IsNewDocumentTransition $false)
        $arrFinalFailures = @(Get-PublishedEndpointMetadataFailure `
                -Name 'fixture.md' -CurrentContent $arrCommittedContent[2] `
                -ParentContent $arrCommittedContent[0] -ExpectedUtcDate $MaximumMetadataUtcDate `
                -IsNewDocumentTransition $false)
        $arrChangedPaths = @(Read-GitPublishedEndpointChangedPath `
                -RepositoryRootPath $strFixtureRoot -BaselineRevision $listRevisions[0] `
                -FinalRevision $listRevisions[2] -MaximumBytes 4096)
        if ($arrIntermediateFailures.Count -eq 0 -or $arrFinalFailures.Count -ne 0 -or
            $arrChangedPaths.Count -ne 1 -or $arrChangedPaths[0] -cne 'fixture.md') {
            throw 'A real multi-commit invalid intermediate or valid final endpoint regressed.'
        }
    } finally {
        if ([IO.Directory]::Exists($strFixtureRoot) -and
            $strFixtureRoot.StartsWith($strTempRoot, [StringComparison]::OrdinalIgnoreCase) -and
            $strFixtureRoot -cne $strTempRoot) {
            Remove-Item -LiteralPath $strFixtureRoot -Recurse -Force
        }
    }
}

$arrDeclaredOutputTypes = @($MyInvocation.MyCommand.OutputType.Name)
if ($arrDeclaredOutputTypes.Count -ne 1 -or
    $arrDeclaredOutputTypes[0] -cne 'System.Void') {
    throw 'The extracted self-test must declare one void output contract.'
}
$script:strMaximumMetadataUtcDate = $MaximumMetadataUtcDate
Assert-DocumentMetadataClassificationSelfTest -MaximumMetadataUtcDate $MaximumMetadataUtcDate
Assert-PublishedMetadataGitFixture -MaximumMetadataUtcDate $MaximumMetadataUtcDate

$intCapacityMaximumBytes = 573440
# Exercise the actual bounded reader at both sides of the finite role cap.
foreach ($intBoundaryBytes in @(
        $intCapacityMaximumBytes, ($intCapacityMaximumBytes + 1)
    )) {
    $objBoundaryStream = [IO.MemoryStream]::new([byte[]]::new($intBoundaryBytes))
    $boolBoundaryRejected = $false
    try {
        $arrBoundaryBytes = @(Read-BoundedStreamData -Stream $objBoundaryStream `
                -MaximumBytes $intCapacityMaximumBytes `
                -DisplayName 'Validator capacity boundary')
        if ($arrBoundaryBytes.Count -ne $intBoundaryBytes) {
            throw 'The validator boundary reader returned an incomplete result.'
        }
    } catch [IO.InvalidDataException] {
        if ($_.Exception.Message -cne
            "Validator capacity boundary must not exceed $intCapacityMaximumBytes bytes.") {
            throw
        }
        $boolBoundaryRejected = $true
    } finally {
        $objBoundaryStream.Dispose()
    }
    if ($boolBoundaryRejected -ne
        ($intBoundaryBytes -gt $intCapacityMaximumBytes)) {
        throw 'The validator capacity boundary did not fail closed exactly.'
    }
}
# These input-reader fixtures need no candidate code or parent-scope mutation.
Assert-RepositoryInputMetadataMutationRejected `
    -Name 'missing Git index entry mutation' `
    -GitIndexEntryCount 0 `
    -Failure 'missing Git index entry mutation must have exactly one Git index entry.'

Assert-RepositoryInputMetadataMutationRejected `
    -Name 'Git symlink mode mutation' `
    -GitMode '120000' `
    -Failure 'Git symlink mode mutation must be a stage-0 regular file with Git mode 100644.'

Assert-RepositoryInputMetadataMutationRejected `
    -Name 'nonzero Git stage mutation' `
    -GitStage '2' `
    -Failure 'nonzero Git stage mutation must be a stage-0 regular file with Git mode 100644.'

Assert-RepositoryInputMetadataMutationRejected `
    -Name 'non-file worktree item mutation' `
    -IsFileInfo $false `
    -Failure 'non-file worktree item mutation must be a regular worktree file.'

Assert-RepositoryInputMetadataMutationRejected `
    -Name 'reparse-point mutation' `
    -Attributes ([System.IO.FileAttributes]::Normal -bor [System.IO.FileAttributes]::ReparsePoint) `
    -Failure 'reparse-point mutation must not be a symbolic link or reparse point.'

Assert-RepositoryInputMetadataMutationRejected `
    -Name 'link-type mutation' `
    -LinkType 'SymbolicLink' `
    -Failure 'link-type mutation must not have a link type.'

Assert-RepositoryInputMetadataMutationRejected `
    -Name 'Unix device mutation' `
    -UnixMode 'crw-rw-rw-' `
    -Failure 'Unix device mutation must have a regular Unix file type.'

$strPathSafetyTempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$strPathSafetyRoot = [IO.Path]::Combine(
    $strPathSafetyTempRoot,
    'agent-input-path-' + [Guid]::NewGuid().ToString('N')
)
if (-not $strPathSafetyRoot.StartsWith(
        $strPathSafetyTempRoot,
        [StringComparison]::OrdinalIgnoreCase
    )) {
    throw 'The repository-input path fixture root is unsafe.'
}
$strPathSafetyRepository = [IO.Path]::Combine($strPathSafetyRoot, 'repository')
$strPathSafetyLinkedDirectory =
    [IO.Path]::Combine($strPathSafetyRepository, 'linked')
$strPathSafetyOutsideDirectory = [IO.Path]::Combine($strPathSafetyRoot, 'outside')
$strPathSafetyInput = [IO.Path]::Combine(
    $strPathSafetyLinkedDirectory,
    'input.md'
)
[void][IO.Directory]::CreateDirectory($strPathSafetyLinkedDirectory)
[IO.File]::WriteAllText(
    $strPathSafetyInput,
    'safe',
    [Text.UTF8Encoding]::new($false)
)
try {
    & git -C $strPathSafetyRepository init --quiet
    & git -C $strPathSafetyRepository add -- linked/input.md
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not create the repository-input path fixture index.'
    }
    $arrSafeRepositoryInput = [byte[]]@(Read-RepositoryInputData `
            -Path $strPathSafetyInput `
            -RepositoryRootPath $strPathSafetyRepository `
            -RepositoryRelativePath 'linked/input.md' `
            -DisplayName 'safe path fixture' `
            -MaximumBytes 64)
    if ([Text.Encoding]::UTF8.GetString($arrSafeRepositoryInput) -cne 'safe') {
        throw 'The safe repository-input path fixture returned unexpected bytes.'
    }

    [IO.File]::Delete($strPathSafetyInput)
    [IO.Directory]::Delete($strPathSafetyLinkedDirectory)
    [void][IO.Directory]::CreateDirectory($strPathSafetyOutsideDirectory)
    [IO.File]::WriteAllText(
        [IO.Path]::Combine($strPathSafetyOutsideDirectory, 'input.md'),
        'outside',
        [Text.UTF8Encoding]::new($false)
    )
    if ([IO.Path]::DirectorySeparatorChar -eq '\') {
        [void](New-Item -ItemType Junction `
                -Path $strPathSafetyLinkedDirectory `
                -Target $strPathSafetyOutsideDirectory)
    } else {
        [void](New-Item -ItemType SymbolicLink `
                -Path $strPathSafetyLinkedDirectory `
                -Target $strPathSafetyOutsideDirectory)
    }
    $boolLinkedComponentRejected = $false
    try {
        [void](Read-RepositoryInputData `
                -Path $strPathSafetyInput `
                -RepositoryRootPath $strPathSafetyRepository `
                -RepositoryRelativePath 'linked/input.md' `
                -DisplayName 'linked path fixture' `
                -MaximumBytes 64)
    } catch {
        $boolLinkedComponentRejected = $_.Exception.Message.Contains(
            'unsafe linked path component: linked.',
            [StringComparison]::Ordinal
        )
    }
    if (-not $boolLinkedComponentRejected) {
        throw 'An intermediate linked repository-input component was accepted.'
    }
} finally {
    if (Test-Path -LiteralPath $strPathSafetyLinkedDirectory) {
        $objLinkedFixtureItem =
            Get-Item -Force -LiteralPath $strPathSafetyLinkedDirectory
        if (($objLinkedFixtureItem.Attributes -band
                [IO.FileAttributes]::ReparsePoint) -ne 0) {
            Remove-Item -Force -LiteralPath $strPathSafetyLinkedDirectory
        }
    }
    if ([IO.Directory]::Exists($strPathSafetyRoot)) {
        Remove-Item -Recurse -Force -LiteralPath $strPathSafetyRoot
    }
}

function ConvertTo-CreatedPushCommitEvidenceObject {
    # .SYNOPSIS
    # Creates one Actions-shaped created-push commit evidence object.
    #
    # .DESCRIPTION
    # Returns the exact bounded property shape that the created-push evidence
    # parser accepts, with optional timestamp data for focused self-tests.
    #
    # .PARAMETER Id
    # The full Git object ID used for both commit and tree fixture fields.
    #
    # .PARAMETER Distinct
    # Whether the fixture commit is distinct from every retained remote ref.
    #
    # .PARAMETER Timestamp
    # The optional timestamp string included in the inert evidence object.
    #
    # .EXAMPLE
    # ConvertTo-CreatedPushCommitEvidenceObject -Id $strId -Distinct $true
    #
    # # Returns one bounded created-push evidence fixture.
    #
    # .INPUTS
    # None. This helper does not accept pipeline input.
    #
    # .OUTPUTS
    # [System.Management.Automation.PSCustomObject] One evidence fixture object.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20260914.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][string] $Id,
        [Parameter(Mandatory)][bool] $Distinct,
        [string] $Timestamp = ''
    )

    return [pscustomobject]@{
        id = $Id
        tree_id = $Id
        distinct = $Distinct
        message = ''
        timestamp = $Timestamp
        url = ''
        author = [pscustomobject]@{
            name = ''
            email = ''
            username = $null
        }
        committer = [pscustomobject]@{
            name = ''
            email = ''
            username = $null
        }
    }
}

$strBaseline = @(
    '# Endpoint fixture'
    '**Version:** 1.0.20260830.0'
    '## Metadata'
    '- **Status:** Active'
    '- **Owner:** Repository Maintainers'
    '- **Last Updated:** 2026-08-30'
    '- **Scope:** Extracted final-state regression.'
    '## Content'
    'Published baseline.'
) -join "`n"
$strFinal = @(
    '# Endpoint fixture'
    '**Version:** 1.0.20260831.0'
    '## Metadata'
    '- **Status:** Accepted'
    '- **Owner:** Repository Maintainers'
    '- **Last Updated:** 2026-08-31'
    '- **Scope:** Extracted final-state regression.'
    '## Content'
    'Corrected published final.'
) -join "`n"
if (@(Get-PublishedEndpointMetadataFailure -Name 'fixture.md' `
        -CurrentContent $strFinal -ParentContent $strBaseline `
        -ExpectedUtcDate '2026-08-31' `
        -IsNewDocumentTransition $false).Count -ne 0) {
    throw 'The extracted published-final regression was rejected.'
}

$strHigherTerminalRevision = $strFinal.Replace(
    '**Version:** 1.0.20260831.0',
    '**Version:** 1.0.20260831.3'
)
if (@(Get-PublishedEndpointMetadataFailure `
    -Name 'fixture.md' -CurrentContent $strHigherTerminalRevision `
    -ParentContent $strBaseline -ExpectedUtcDate '2026-08-31' `
    -IsNewDocumentTransition $false) -cnotcontains
    ('fixture.md Version revision must be exactly 0 when a published-baseline ' +
        'major, minor, or date segment changes.')) {
    throw 'The extracted higher-order revision reset did not fail closed.'
}

$strMetadataOnlyHigherRevision = $strBaseline.Replace(
    '**Version:** 1.0.20260830.0',
    '**Version:** 1.0.20260902.5'
).Replace(
    '- **Last Updated:** 2026-08-30',
    '- **Last Updated:** 2026-09-02'
)
if (@(Get-PublishedEndpointMetadataFailure `
    -Name 'fixture.md' -CurrentContent $strMetadataOnlyHigherRevision `
    -ParentContent $strBaseline -ExpectedUtcDate '2026-09-02' `
    -IsNewDocumentTransition $false) -cnotcontains
    ('fixture.md Version revision must be exactly 0 when a published-baseline ' +
        'major, minor, or date segment changes.')) {
    throw 'The extracted metadata-only higher-order reset did not fail closed.'
}
$strMetadataOnlyHigherReset = $strMetadataOnlyHigherRevision.Replace(
    '**Version:** 1.0.20260902.5',
    '**Version:** 1.0.20260902.0'
)
if (@(Get-PublishedEndpointMetadataFailure `
        -Name 'fixture.md' -CurrentContent $strMetadataOnlyHigherReset `
        -ParentContent $strBaseline -ExpectedUtcDate '2026-09-02' `
        -IsNewDocumentTransition $false).Count -ne 0) {
    throw 'The extracted metadata-only higher-order reset was rejected.'
}

$strMetadataOnlySameTupleIncrement = $strBaseline.Replace(
    '**Version:** 1.0.20260830.0',
    '**Version:** 1.0.20260830.1'
)
if (@(Get-PublishedEndpointMetadataFailure `
        -Name 'fixture.md' -CurrentContent $strMetadataOnlySameTupleIncrement `
        -ParentContent $strBaseline -ExpectedUtcDate '2026-08-30' `
        -IsNewDocumentTransition $false).Count -ne 0) {
    throw 'The extracted metadata-only same-tuple increment was rejected.'
}
$strMetadataOnlySameTupleSkip = $strMetadataOnlySameTupleIncrement.Replace(
    '**Version:** 1.0.20260830.1',
    '**Version:** 1.0.20260830.2'
)
if (@(Get-PublishedEndpointMetadataFailure `
    -Name 'fixture.md' -CurrentContent $strMetadataOnlySameTupleSkip `
    -ParentContent $strBaseline -ExpectedUtcDate '2026-08-30' `
    -IsNewDocumentTransition $false) -cnotcontains
    ('fixture.md Version revision must be exactly 1 after a published change ' +
        'with an unchanged published-baseline major, minor, and date tuple.')) {
    throw 'The extracted metadata-only same-tuple skip did not fail closed.'
}

$strSameTupleFinal = $strBaseline.Replace(
    '**Version:** 1.0.20260830.0',
    '**Version:** 1.0.20260830.1'
).Replace('Published baseline.', 'Published final on the same tuple.')
if (@(Get-PublishedEndpointMetadataFailure `
    -Name 'fixture.md' -CurrentContent $strSameTupleFinal `
    -ParentContent $strBaseline -ExpectedUtcDate '2026-08-30' `
    -IsNewDocumentTransition $false).Count -ne 0) {
    throw 'The extracted exact same-tuple revision increment was rejected.'
}
$strSkippedSameTupleRevision = $strSameTupleFinal.Replace(
    '**Version:** 1.0.20260830.1',
    '**Version:** 1.0.20260830.2'
)
if (@(Get-PublishedEndpointMetadataFailure `
    -Name 'fixture.md' -CurrentContent $strSkippedSameTupleRevision `
    -ParentContent $strBaseline -ExpectedUtcDate '2026-08-30' `
    -IsNewDocumentTransition $false) -cnotcontains
    ('fixture.md Version revision must be exactly 1 after a published change ' +
        'with an unchanged published-baseline major, minor, and date tuple.')) {
    throw 'The extracted skipped same-tuple revision did not fail closed.'
}

if (@(Get-PublishedEndpointMetadataFailure -Name 'fixture.md' `
        -CurrentContent $strFinal -ParentContent $null -ExpectedUtcDate '' `
        -IsNewDocumentTransition $true `
        -RequireExpectedUtcDateForRenderedChange $false).Count -ne 0) {
    throw 'The extracted baseline-absent revision zero was rejected.'
}
$strNewDocumentNonzeroRevision = $strFinal.Replace(
    '**Version:** 1.0.20260831.0',
    '**Version:** 1.0.20260831.1'
)
if (@(Get-PublishedEndpointMetadataFailure -Name 'fixture.md' `
        -CurrentContent $strNewDocumentNonzeroRevision -ParentContent $null `
        -ExpectedUtcDate '' -IsNewDocumentTransition $true `
        -RequireExpectedUtcDateForRenderedChange $false) -cnotcontains
    'fixture.md Version revision must be exactly 0 when no published baseline exists.') {
    throw 'The extracted baseline-absent nonzero revision did not fail closed.'
}

$strSameTupleRollback = $strBaseline.Replace(
    '**Version:** 1.0.20260830.0',
    '**Version:** 1.0.20260830.4'
)
$arrRollbackFailures = @(Get-PublishedEndpointMetadataFailure `
    -Name 'fixture.md' -CurrentContent $strBaseline `
    -ParentContent $strSameTupleRollback -ExpectedUtcDate '2026-08-30' `
    -IsNewDocumentTransition $false)
if ($arrRollbackFailures -cnotcontains
    'fixture.md Version revision must not decrease from 4 to 0.') {
    throw 'The extracted same-tuple revision rollback did not fail closed.'
}

$strDateRollback = $strFinal.Replace(
    '**Version:** 1.0.20260831.0',
    '**Version:** 2.0.20260829.0'
).Replace('- **Last Updated:** 2026-08-31',
    '- **Last Updated:** 2026-08-29')
if (-not (@(Get-PublishedEndpointMetadataFailure `
        -Name 'fixture.md' -CurrentContent $strDateRollback `
        -ParentContent $strBaseline -ExpectedUtcDate '2026-08-29' `
        -IsNewDocumentTransition $false) -match
        'Version date must not move backward')) {
    throw 'The extracted independent date rollback did not fail closed.'
}

$strTupleRollback = $strFinal.Replace(
    '**Version:** 1.0.20260831.0',
    '**Version:** 0.9.20260831.0'
)
if (-not (@(Get-PublishedEndpointMetadataFailure `
        -Name 'fixture.md' -CurrentContent $strTupleRollback `
        -ParentContent $strBaseline -ExpectedUtcDate '2026-08-31' `
        -IsNewDocumentTransition $false) -match
        'Version major and minor tuple must not move backward')) {
    throw 'The extracted independent major/minor rollback did not fail closed.'
}

$strUnversionedBaseline = @(
    '# Unversioned endpoint fixture'
    '## Metadata'
    '- **Status:** Active'
    '- **Owner:** Repository Maintainers'
    '- **Last Updated:** 2026-08-30'
    '- **Scope:** Extracted unversioned final-state regression.'
    '## Content'
    'Published baseline.'
) -join "`n"
$strUnversionedFinal = $strUnversionedBaseline.Replace(
    '- **Last Updated:** 2026-08-30',
    '- **Last Updated:** 2026-08-31'
).Replace('Published baseline.', 'Published final.')
if (@(Get-PublishedEndpointLastUpdatedFailure -Name 'fixture.md' `
        -CurrentContent $strUnversionedFinal `
        -BaseContent $strUnversionedBaseline `
        -TrustedEventUtcDate '2026-08-31' `
        -RequireCurrentMaximumDateForRenderedChange $false).Count -ne 0) {
    throw 'The extracted unversioned published-final regression was rejected.'
}
$arrStaleFailures = @(Get-PublishedEndpointLastUpdatedFailure `
    -Name 'fixture.md' `
    -CurrentContent ($strUnversionedBaseline + "`nRendered final change.") `
    -BaseContent $strUnversionedBaseline `
    -TrustedEventUtcDate '2026-08-31')
if (-not ($arrStaleFailures -match 'Last Updated must be 2026-08-31')) {
    throw 'The extracted stale unversioned final did not fail closed.'
}

$strSameDayFinal = $strUnversionedBaseline.Replace('Published baseline.', 'Second edit on the same day.')
if (@(Get-PublishedEndpointLastUpdatedFailure -Name 'same-day.md' `
        -CurrentContent $strSameDayFinal -BaseContent $strUnversionedBaseline `
        -TrustedEventUtcDate '' -RequireCurrentMaximumDateForRenderedChange $false).Count -ne 0) {
    throw 'A valid same-day final document was rejected.'
}
if (-not (@(Get-PublishedEndpointLastUpdatedFailure -Name 'backward-date.md' `
        -CurrentContent $strSameDayFinal.Replace('2026-08-30', '2026-08-29') `
        -BaseContent $strUnversionedBaseline -TrustedEventUtcDate '') -match 'must not move backward')) {
    throw 'A backward final date was accepted.'
}
if (-not (@(Get-PublishedEndpointLastUpdatedFailure -Name 'stale-authoring.md' `
        -CurrentContent $strSameDayFinal -BaseContent $strUnversionedBaseline `
        -TrustedEventUtcDate '' -RequireCurrentMaximumDateForRenderedChange $true) -match 'Last Updated must be')) {
    throw 'The local authoring date check was lost.'
}

if (@(Read-GitPublishedEndpointChangedPath `
        -RepositoryRootPath $RepositoryRootPath `
        -BaselineRevision $Revision -FinalRevision $Revision `
        -MaximumBytes $MaximumBytes).Count -ne 0) {
    throw 'Identical endpoint trees reported changed paths.'
}
