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
# Version: 1.6.20261002.0

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
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261002.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param([Parameter(Mandatory)][string] $MaximumMetadataUtcDate)

    $strNewVersionedDocument = "# New versioned fixture`n`n**Version:** 1.0.$($MaximumMetadataUtcDate.Replace('-', '')).0`n`n## Metadata`n`n- **Status:** Active`n- **Owner:** Fixture Maintainers`n- **Last Updated:** $MaximumMetadataUtcDate`n- **Scope:** Null-base finalization.`n`n## Procedure`n`nFollow the current procedure.`n"
    if (@(Get-PublishedEndpointMetadataFailure -Name 'new-versioned.md' `
                -CurrentContent $strNewVersionedDocument -ParentContent $null `
                -ExpectedUtcDate $MaximumMetadataUtcDate -IsNewDocumentTransition $true `
                -RequireExpectedUtcDateForRenderedChange $true).Count -ne 0) {
        throw 'Current-date null-base versioned finalization was rejected.'
    }
    $strEarlierVersionedDate = [DateTime]::ParseExact($MaximumMetadataUtcDate, 'yyyy-MM-dd',
        [Globalization.CultureInfo]::InvariantCulture).AddDays(-1).ToString('yyyy-MM-dd')
    $strEarlierVersionedDocument = $strNewVersionedDocument.Replace(
        $MaximumMetadataUtcDate, $strEarlierVersionedDate).Replace(
        $MaximumMetadataUtcDate.Replace('-', ''), $strEarlierVersionedDate.Replace('-', ''))
    if (-not (@(Get-PublishedEndpointMetadataFailure -Name 'new-versioned.md' `
                -CurrentContent $strEarlierVersionedDocument -ParentContent $null `
                -ExpectedUtcDate $MaximumMetadataUtcDate -IsNewDocumentTransition $true `
                -RequireExpectedUtcDateForRenderedChange $true) -match 'Last Updated must')) {
        throw 'Stale null-base versioned finalization bypassed the explicit date requirement.'
    }
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
    $arrSuffixPaths = @('docs/RUNBOOK.MD', 'docs/mixed.Md', 'docs/example.MdC',
        '.cursor/rules/operations.MDC', 'docs/exact.md', 'docs/exact.MD')
    $arrSuffixDiscovered = @(Get-DiscoveredGovernedMarkdownDocumentPath `
            -CandidatePath ($arrSuffixPaths + @('notes.txt')) -KnownGovernedPath @() -ExemptPath @())
    if ($arrSuffixDiscovered.Count -ne $arrSuffixPaths.Count) { throw 'Markdown suffix discovery lost exact paths.' }
    foreach ($strSuffixPath in $arrSuffixPaths) {
        if ($arrSuffixDiscovered -cnotcontains $strSuffixPath) { throw "Markdown suffix path changed: $strSuffixPath" }
        foreach ($strCategory in @('tier2Paths', 'generatedPaths', 'authorizedExemptionPaths')) {
            $hashtableManifest = @{ schemaVersion = 2; tier2Paths = @(); generatedPaths = @(); authorizedExemptionPaths = @() }
            $hashtableManifest[$strCategory] = @($strSuffixPath)
            $objSuffixContext = Get-DocumentMetadataClassificationContext `
                -Content ($hashtableManifest | ConvertTo-Json -Compress) -TrackedPath $arrSuffixPaths
            if ($objSuffixContext.Failure) { throw "Valid Markdown suffix classification failed: $strSuffixPath" }
        }
    }
    foreach ($strCaseAlias in @('AGENTS.MD', '.cursor/rules/operations.MDC')) {
        if (-not (Test-GovernedInstructionPathCaseMismatch -RepositoryRelativePath $strCaseAlias `
                    -GovernedRootPaths @('AGENTS.md'))) {
            throw "Existing governed-family casing rule was lost: $strCaseAlias"
        }
    }
    $objUpperCandidate = Get-DocumentMetadataClassificationContext `
        -Content '{"schemaVersion":2,"authorizedExemptionPaths":[],"tier2Paths":["docs/RUNBOOK.MD"],"generatedPaths":[]}' `
        -TrackedPath $arrSuffixPaths
    foreach ($strAuthorizedPath in @('docs/RUNBOOK.MD', 'docs/runbook.md')) {
        $arrSuffixFailures = @(Get-DocumentMetadataClassificationExpansionFailure `
                -HasTrustedBaselineManifest $true -TrustedBaselineExemptPath @() `
                -TrustedBaselineAuthorizedExemptionPath @($strAuthorizedPath) `
                -CandidateExemptPath $objUpperCandidate.ExemptPaths `
                -TrustedBaselineGeneratedPath @() -CandidateGeneratedPath @())
        if (($strAuthorizedPath -ceq 'docs/RUNBOOK.MD') -ne ($arrSuffixFailures.Count -eq 0)) {
            throw 'Markdown suffix recognition changed exact authorization identity.'
        }
    }
    if (@(Get-DocumentMetadataClassificationExpansionFailure `
            -HasTrustedBaselineManifest $true -TrustedBaselineExemptPath $objUpperCandidate.ExemptPaths `
            -TrustedBaselineAuthorizedExemptionPath @() -CandidateExemptPath $objUpperCandidate.ExemptPaths `
            -TrustedBaselineGeneratedPath @() -CandidateGeneratedPath $objUpperCandidate.ExemptPaths).Count -eq 0) {
        throw 'An uppercase Tier2 path gained unauthenticated generated status.'
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
            -CandidateExemptPath $arrCandidateActivePaths `
            -TrustedBaselineGeneratedPath @() -CandidateGeneratedPath @())
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
            -CandidateExemptPath $arrCandidateActivePaths `
            -TrustedBaselineGeneratedPath @() -CandidateGeneratedPath @())
    if ($arrAuthorizedFailures.Count -ne 0) {
        throw 'The exact trusted baseline authorization was rejected.'
    }
    $arrWrongAuthorizationFailures = @(Get-DocumentMetadataClassificationExpansionFailure `
            -HasTrustedBaselineManifest $true `
            -TrustedBaselineExemptPath @('README.md') `
            -TrustedBaselineAuthorizedExemptionPath @('docs/another.md') `
            -CandidateExemptPath $arrCandidateActivePaths `
            -TrustedBaselineGeneratedPath @() -CandidateGeneratedPath @())
    if ($arrWrongAuthorizationFailures.Count -ne 1) {
        throw 'An authorization for another path permitted the candidate exemption.'
    }
    $arrBootstrapFailures = @(Get-DocumentMetadataClassificationExpansionFailure `
            -HasTrustedBaselineManifest $false `
            -TrustedBaselineExemptPath @() `
            -TrustedBaselineAuthorizedExemptionPath @() `
            -CandidateExemptPath $objValidContext.ExemptPaths `
            -TrustedBaselineGeneratedPath @() -CandidateGeneratedPath $objValidContext.GeneratedPaths)
    if ($arrBootstrapFailures.Count -ne 1) {
        throw 'A missing trusted manifest bypassed the closed initialization proof.'
    }
    $strJoinerPath = 'a' + [char]0x200d + 'b.md'
    $strComposedPath = [string][char]0x00e9 + '.md'
    $strDecomposedPath = 'e' + [char]0x0301 + '.md'
    $arrCategoryTrackedPaths = @('a.md', 'b.md', 'ab.md', $strJoinerPath, $strComposedPath, $strDecomposedPath)
    $arrCategoryCases = @(
        @{ Name = 'unchanged'; BT = @('a.md'); BG = @('b.md'); BA = @(); CT = @('a.md'); CG = @('b.md'); CA = @(); Failure = '' },
        @{ Name = 'Tier2 to generated'; BT = @('a.md'); BG = @(); BA = @(); CT = @(); CG = @('a.md'); CA = @(); Failure = 'unauthenticated generated status: a.md' },
        @{ Name = 'generated to Tier2'; BT = @(); BG = @('a.md'); BA = @(); CT = @('a.md'); CG = @(); CA = @(); Failure = '' },
        @{ Name = 'category swap'; BT = @('a.md'); BG = @('b.md'); BA = @(); CT = @('b.md'); CG = @('a.md'); CA = @(); Failure = 'unauthenticated generated status: a.md' },
        @{ Name = 'remove Tier2'; BT = @('a.md'); BG = @('b.md'); BA = @(); CT = @(); CG = @('b.md'); CA = @(); Failure = '' },
        @{ Name = 'remove generated'; BT = @('a.md'); BG = @('b.md'); BA = @(); CT = @('a.md'); CG = @(); CA = @(); Failure = '' },
        @{ Name = 'remove all'; BT = @('a.md'); BG = @('b.md'); BA = @(); CT = @(); CG = @(); CA = @(); Failure = '' },
        @{ Name = 'new Tier2'; BT = @(); BG = @(); BA = @(); CT = @('a.md'); CG = @(); CA = @(); Failure = 'unauthenticated metadata exemption: a.md' },
        @{ Name = 'new generated'; BT = @(); BG = @(); BA = @(); CT = @(); CG = @('a.md'); CA = @(); Failure = 'unauthenticated generated status: a.md' },
        @{ Name = 'authorized Tier2'; BT = @(); BG = @(); BA = @('a.md'); CT = @('a.md'); CG = @(); CA = @(); Failure = '' },
        @{ Name = 'authorized generated'; BT = @(); BG = @(); BA = @('a.md'); CT = @(); CG = @('a.md'); CA = @(); Failure = '' },
        @{ Name = 'wrong authorization'; BT = @('a.md'); BG = @(); BA = @('b.md'); CT = @(); CG = @('a.md'); CA = @(); Failure = 'unauthenticated generated status: a.md' },
        @{ Name = 'candidate authorization inert'; BT = @('a.md'); BG = @(); BA = @(); CT = @('a.md'); CG = @(); CA = @('b.md'); Failure = '' },
        @{ Name = 'remove and authorize'; BT = @('a.md'); BG = @(); BA = @(); CT = @(); CG = @(); CA = @('a.md'); Failure = '' },
        @{ Name = 'ordinal generated joiner'; BT = @($strJoinerPath); BG = @('ab.md'); BA = @(); CT = @(); CG = @('ab.md', $strJoinerPath); CA = @(); Failure = "unauthenticated generated status: $strJoinerPath" },
        @{ Name = 'ordinal union joiner'; BT = @('ab.md'); BG = @(); BA = @(); CT = @('ab.md', $strJoinerPath); CG = @(); CA = @(); Failure = "unauthenticated metadata exemption: $strJoinerPath" },
        @{ Name = 'ordinal normalization distinction'; BT = @($strComposedPath); BG = @($strDecomposedPath); BA = @(); CT = @(); CG = @($strDecomposedPath, $strComposedPath); CA = @(); Failure = "unauthenticated generated status: $strComposedPath" },
        @{ Name = 'ordinal exact authorization'; BT = @(); BG = @('ab.md'); BA = @($strJoinerPath); CT = @(); CG = @('ab.md', $strJoinerPath); CA = @(); Failure = '' }
    )
    foreach ($objCase in $arrCategoryCases) {
        $strBaseline = @{ schemaVersion = 2; tier2Paths = $objCase.BT; generatedPaths = $objCase.BG; authorizedExemptionPaths = $objCase.BA } | ConvertTo-Json -Compress
        $strCandidate = @{ schemaVersion = 2; tier2Paths = $objCase.CT; generatedPaths = $objCase.CG; authorizedExemptionPaths = $objCase.CA } | ConvertTo-Json -Compress
        $objBaseline = Get-DocumentMetadataClassificationContext -Content $strBaseline -TrackedPath $arrCategoryTrackedPaths
        $objCandidate = Get-DocumentMetadataClassificationContext -Content $strCandidate -TrackedPath $arrCategoryTrackedPaths
        if ($objBaseline.Failure -or $objCandidate.Failure) { throw "Invalid category fixture: $($objCase.Name)" }
        $arrFailures = @(Get-DocumentMetadataClassificationExpansionFailure `
                -HasTrustedBaselineManifest $true `
                -TrustedBaselineExemptPath $objBaseline.ExemptPaths `
                -TrustedBaselineAuthorizedExemptionPath $objBaseline.AuthorizedExemptionPaths `
                -CandidateExemptPath $objCandidate.ExemptPaths `
                -TrustedBaselineGeneratedPath $objBaseline.GeneratedPaths `
                -CandidateGeneratedPath $objCandidate.GeneratedPaths)
        if (($objCase.Failure -ceq '' -and $arrFailures.Count -ne 0) -or
            ($objCase.Failure -cne '' -and -not ($arrFailures -match [regex]::Escape($objCase.Failure)))) {
            throw "Category transition failed: $($objCase.Name): $($arrFailures -join '; ')"
        }
    }
    $arrInitialTier2 = @('ACKNOWLEDGMENTS.md', 'CONTRIBUTING.md', 'README.md',
        'samples/test-nested-markdown-linting.md', 'samples/test-recursive-nested-markdown.md')
    $arrInitialGenerated = @('STYLE_GUIDE_CHAT.md', 'STYLE_GUIDE_FULL.md',
        'copilot-instructions.md', 'powershell.instructions.md')
    $hashtableInitialMapping = @{
        schemaVersion = 2
        authorizedExemptionPaths = @()
        tier2Paths = $arrInitialTier2
        generatedPaths = $arrInitialGenerated
    }
    $strInitialMapping = $hashtableInitialMapping | ConvertTo-Json -Depth 5
    $objInitialMapping = Get-DocumentMetadataClassificationContext -Content $strInitialMapping `
        -TrackedPath @($arrInitialTier2 + $arrInitialGenerated + @('docs/extra.md'))
    $strInitialBase = '48f4d8a36c8faceee12afac78aaecea0d176125d'
    $strInitialValidatorSha = '5a61845f756be1d1bc4ddb772ffbc6c71ab525f0394d11d8c672f998a05fb4a5'
    if (@(Get-InitialDocumentMetadataClassificationFailure -BaselineRevision $strInitialBase `
                -TrustedBaselineValidatorSha256 $strInitialValidatorSha -CandidateContext $objInitialMapping).Count -ne 0) {
        throw 'The parsed closed initial mapping with harmless formatting was rejected.'
    }
    foreach ($objInitialNegative in @(
            @{ Base = ('0' * 40); Sha = $strInitialValidatorSha; Context = $objInitialMapping },
            @{ Base = $strInitialBase; Sha = ('0' * 64); Context = $objInitialMapping })) {
        if (@(Get-InitialDocumentMetadataClassificationFailure -BaselineRevision $objInitialNegative.Base `
                    -TrustedBaselineValidatorSha256 $objInitialNegative.Sha -CandidateContext $objInitialNegative.Context).Count -eq 0) {
            throw 'An unsupported initialization identity was accepted.'
        }
    }
    foreach ($strChangedMapping in @(
            $strInitialMapping.Replace('"ACKNOWLEDGMENTS.md",', ''),
            $strInitialMapping.Replace('"README.md",', '"README.md", "docs/extra.md",'),
            $strInitialMapping.Replace('"authorizedExemptionPaths": []', '"authorizedExemptionPaths": ["docs/extra.md"]'),
            $strInitialMapping.Replace('"STYLE_GUIDE_CHAT.md",', '').Replace('"README.md",', '"README.md", "STYLE_GUIDE_CHAT.md",'))) {
        $objChangedMapping = Get-DocumentMetadataClassificationContext -Content $strChangedMapping `
            -TrackedPath @($arrInitialTier2 + $arrInitialGenerated + @('docs/extra.md'))
        if (@(Get-InitialDocumentMetadataClassificationFailure -BaselineRevision $strInitialBase `
                    -TrustedBaselineValidatorSha256 $strInitialValidatorSha -CandidateContext $objChangedMapping).Count -eq 0) {
            throw 'An omitted, expanded, authorized or reclassified initial mapping was accepted.'
        }
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

    foreach ($objRecursiveIgnoreFixture in @(
            [pscustomobject]@{ Name = 'canonical all-depth pattern'; Rules = "CLAUDE.local.md`n"; Paths = @('.gitignore'); Expected = $true },
            [pscustomobject]@{ Name = 'native recursive alias'; Rules = "**/CLAUDE.local.md`n"; Paths = @('.gitignore'); Expected = $true },
            [pscustomobject]@{ Name = 'enumerated root and literal depth'; Rules = "/CLAUDE.local.md`n/nested/CLAUDE.local.md`n"; Paths = @('.gitignore'); Expected = $false },
            [pscustomobject]@{ Name = 'deep later negation'; Rules = "CLAUDE.local.md`n!tools/project/CLAUDE.local.md`n"; Paths = @('.gitignore'); Expected = $false },
            [pscustomobject]@{ Name = 'exclusion restores proof'; Rules = "!tools/project/CLAUDE.local.md`nCLAUDE.local.md`n"; Paths = @('.gitignore'); Expected = $true },
            [pscustomobject]@{ Name = 'broad later negation'; Rules = "CLAUDE.local.md`n!*.md`n"; Paths = @('.gitignore'); Expected = $false },
            [pscustomobject]@{ Name = 'harmless later negation needs reordering'; Rules = "CLAUDE.local.md`n!README.local.md`n"; Paths = @('.gitignore'); Expected = $false },
            [pscustomobject]@{ Name = 'escaped negation is literal'; Rules = "CLAUDE.local.md`n\!example.md`n"; Paths = @('.gitignore'); Expected = $true },
            [pscustomobject]@{ Name = 'comments do not negate'; Rules = "CLAUDE.local.md`n# !*.md`n"; Paths = @('.gitignore'); Expected = $true },
            [pscustomobject]@{ Name = 'leading space remains literal'; Rules = " CLAUDE.local.md`n"; Paths = @('.gitignore'); Expected = $false },
            [pscustomobject]@{ Name = 'native trailing spaces'; Rules = "CLAUDE.local.md  `n"; Paths = @('.gitignore'); Expected = $true },
            [pscustomobject]@{ Name = 'escaped trailing space is literal'; Rules = "CLAUDE.local.md\ `n"; Paths = @('.gitignore'); Expected = $false },
            [pscustomobject]@{ Name = 'nested override invalidates proof'; Rules = "CLAUDE.local.md`n"; Paths = @('.gitignore', 'tools/.gitignore'); Expected = $false },
            [pscustomobject]@{ Name = 'case alias invalidates proof'; Rules = "CLAUDE.local.md`n"; Paths = @('.gitignore', 'tools/.GITIGNORE'); Expected = $false },
            [pscustomobject]@{ Name = 'root ignore is required'; Rules = "CLAUDE.local.md`n"; Paths = @(); Expected = $false }
        )) {
        if ((Test-RecursivePersonalMemoryIgnoreContract `
                -GitIgnoreContent $objRecursiveIgnoreFixture.Rules `
                -TrackedPath $objRecursiveIgnoreFixture.Paths) -ne $objRecursiveIgnoreFixture.Expected) {
            throw "Recursive root-ignore proof failed: $($objRecursiveIgnoreFixture.Name)"
        }
    }
    foreach ($strRecursiveRule in @("CLAUDE.local.md`n", "**/CLAUDE.local.md`n")) {
        foreach ($strPrivatePath in @('CLAUDE.local.md', 'nested/CLAUDE.local.md', 'tools/project/CLAUDE.local.md')) {
            if (-not (Test-GitIgnorePathEffective -GitIgnoreContent $strRecursiveRule `
                    -RepositoryRelativePath $strPrivatePath)) {
                throw "Native Git rejected recursive personal-memory coverage: $strPrivatePath"
            }
        }
        foreach ($strPublicPath in @('CLAUDE.md', 'nested/CLAUDE.md', 'tools/project/CLAUDE.md')) {
            if (Test-GitIgnorePathEffective -GitIgnoreContent $strRecursiveRule `
                    -RepositoryRelativePath $strPublicPath) {
                throw "Native Git hid public instructions: $strPublicPath"
            }
        }
    }

    $strLegacyMetadataContent = "# Procedure`n`nInvalid prior metadata.`n"
    $strInitialGovernedContent = "# Procedure`n`n## Metadata`n`n- **Status:** Active`n- **Owner:** Maintainers`n- **Last Updated:** $MaximumMetadataUtcDate`n- **Scope:** Operational procedure.`n"
    foreach ($objPromotionFixture in @(
            [pscustomobject]@{ Name = 'trusted exempt promotion'; Path = 'README.md'; Exempt = @('README.md'); Current = $strInitialGovernedContent; Allowed = $true; Fails = $false },
            [pscustomobject]@{ Name = 'stale promoted document'; Path = 'README.md'; Exempt = @('README.md'); Current = $strInitialGovernedContent.Replace($MaximumMetadataUtcDate, '2020-01-01'); Allowed = $true; Fails = $true },
            [pscustomobject]@{ Name = 'invalid promoted header'; Path = 'README.md'; Exempt = @('README.md'); Current = $strLegacyMetadataContent; Allowed = $true; Fails = $true },
            [pscustomobject]@{ Name = 'nonexempt invalid parent'; Path = 'docs/RUNBOOK.md'; Exempt = @('README.md'); Current = $strInitialGovernedContent; Allowed = $false; Fails = $true },
            [pscustomobject]@{ Name = 'candidate-only exemption cannot supply proof'; Path = 'docs/RUNBOOK.md'; Exempt = @(); Current = $strInitialGovernedContent; Allowed = $false; Fails = $true },
            [pscustomobject]@{ Name = 'known governed path wins'; Path = 'AGENTS.md'; Exempt = @('AGENTS.md'); Current = $strInitialGovernedContent; Allowed = $false; Fails = $true },
            [pscustomobject]@{ Name = 'ADR remains previously governed'; Path = 'docs/decisions/0001-safety.md'; Exempt = @('docs/decisions/0001-safety.md'); Current = $strInitialGovernedContent; Allowed = $false; Fails = $true }
        )) {
        $boolPromotedCoverage = Test-InitialMetadataCoveragePath `
            -HasTrustedBaselineManifest $true `
            -TrustedBaselineExemptPath $objPromotionFixture.Exempt `
            -RepositoryRelativePath $objPromotionFixture.Path
        $objPromotionBaseContent = $strLegacyMetadataContent
        if ($boolPromotedCoverage) { $objPromotionBaseContent = $null }
        $arrPromotionFailures = @(Get-PublishedEndpointLastUpdatedFailure `
                -Name $objPromotionFixture.Path -CurrentContent $objPromotionFixture.Current `
                -BaseContent $objPromotionBaseContent -TrustedEventUtcDate '' `
                -RequireCurrentMaximumDateForRenderedChange $boolPromotedCoverage)
        if ($boolPromotedCoverage -ne $objPromotionFixture.Allowed -or
            ($arrPromotionFailures.Count -gt 0) -ne $objPromotionFixture.Fails) {
            throw "Trusted exemption promotion fixture failed: $($objPromotionFixture.Name)"
        }
    }

    # Candidate classification/catalog choices are not inputs to proved prior coverage.
    foreach ($strPriorGovernedFixturePath in @('AGENTS.md', 'docs/decisions/0001-safety.md', '.github/workflows/scripts-README.md')) {
        if (Test-InitialMetadataCoveragePath -HasTrustedBaselineManifest $false `
                -RepositoryRelativePath $strPriorGovernedFixturePath) {
            throw 'Candidate reclassification escaped proved prior governed coverage.'
        }
    }
    if (Test-InitialMetadataCoveragePath -HasTrustedBaselineManifest $false `
            -RepositoryRelativePath 'docs/RUNBOOK.md') {
        throw 'A missing baseline manifest waived invalid parent metadata.'
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
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
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
    $strPromotionFile = [IO.Path]::Combine($strFixtureRoot, 'README.md')
    $strManifestDirectory = [IO.Path]::Combine($strFixtureRoot, '.github')
    [void][IO.Directory]::CreateDirectory($strManifestDirectory)
    $strManifestFile = [IO.Path]::Combine($strManifestDirectory, 'document-metadata-classification.json')
    $strExemptManifest = '{"schemaVersion":2,"authorizedExemptionPaths":[],"tier2Paths":["README.md"],"generatedPaths":[]}'
    $strGovernedManifest = '{"schemaVersion":2,"authorizedExemptionPaths":[],"tier2Paths":[],"generatedPaths":[]}'
    $strExemptReadme = "# Onboarding`n`nConsumer setup.`n"
    $strPromotedReadme = "# Procedure`n`n## Metadata`n`n- **Status:** Active`n- **Owner:** Fixture Maintainers`n- **Last Updated:** $MaximumMetadataUtcDate`n- **Scope:** Governed procedure.`n"

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
            [IO.File]::WriteAllText($strPromotionFile,
                $(if ($listRevisions.Count -eq 0) { $strExemptReadme } else { $strPromotedReadme }),
                [Text.UTF8Encoding]::new($false))
            [IO.File]::WriteAllText($strManifestFile,
                $(if ($listRevisions.Count -eq 0) { $strExemptManifest } else { $strGovernedManifest }),
                [Text.UTF8Encoding]::new($false))
            & git -c core.autocrlf=false -C $strFixtureRoot add -- fixture.md README.md .github/document-metadata-classification.json
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
            $arrChangedPaths.Count -ne 3 -or
            $arrChangedPaths -cnotcontains '.github/document-metadata-classification.json' -or
            $arrChangedPaths -cnotcontains 'README.md' -or $arrChangedPaths -cnotcontains 'fixture.md') {
            throw ("A real multi-commit endpoint regressed. Intermediate: $($arrIntermediateFailures -join '; '); " +
                "final: $($arrFinalFailures -join '; '); paths: $($arrChangedPaths -join '; ').")
        }
        $arrFixtureBaselinePaths = @(Read-GitTrackedPath -RepositoryRootPath $strFixtureRoot `
                -Revision $listRevisions[0] -MaximumBytes 4096)
        $arrFixtureFinalPaths = @(Read-GitTrackedPath -RepositoryRootPath $strFixtureRoot `
                -Revision $listRevisions[2] -MaximumBytes 4096)
        $objFixtureBaselineClassification = Get-DocumentMetadataClassificationContext `
            -Content (Read-GitRevisionText -RepositoryRootPath $strFixtureRoot `
                -Revision $listRevisions[0] -RepositoryRelativePath '.github/document-metadata-classification.json' `
                -MaximumBytes 4096 -RequireRegularFile) -TrackedPath $arrFixtureBaselinePaths
        $objFixtureFinalClassification = Get-DocumentMetadataClassificationContext `
            -Content (Read-GitRevisionText -RepositoryRootPath $strFixtureRoot `
                -Revision $listRevisions[2] -RepositoryRelativePath '.github/document-metadata-classification.json' `
                -MaximumBytes 4096 -RequireRegularFile) -TrackedPath $arrFixtureFinalPaths
        if ($null -ne $objFixtureBaselineClassification.Failure -or
            $null -ne $objFixtureFinalClassification.Failure) {
            throw 'The real promotion classification fixture is invalid.'
        }
        $boolFixturePromotion = Test-InitialMetadataCoveragePath `
            -HasTrustedBaselineManifest $true `
            -TrustedBaselineExemptPath $objFixtureBaselineClassification.ExemptPaths `
            -RepositoryRelativePath 'README.md'
        $strCommittedPromotedReadme = Read-GitRevisionText -RepositoryRootPath $strFixtureRoot `
            -Revision $listRevisions[2] -RepositoryRelativePath 'README.md' `
            -MaximumBytes 4096 -RequireRegularFile
        $arrDiscoveredPromotionPaths = @(Get-DiscoveredGovernedMarkdownDocumentPath `
                -CandidatePath $arrFixtureFinalPaths -KnownGovernedPath @('fixture.md') `
                -ExemptPath $objFixtureFinalClassification.ExemptPaths)
        if (-not $boolFixturePromotion -or
            $arrDiscoveredPromotionPaths -cnotcontains 'README.md' -or
            @(Get-PublishedEndpointLastUpdatedFailure -Name 'README.md' `
                -CurrentContent $strCommittedPromotedReadme -BaseContent $null `
                -TrustedEventUtcDate '' -RequireCurrentMaximumDateForRenderedChange $true).Count -ne 0) {
            throw 'Trusted Git-object exemption removal did not become valid governed coverage.'
        }

    } finally {
        if ([IO.Directory]::Exists($strFixtureRoot) -and
            $strFixtureRoot.StartsWith($strTempRoot, [StringComparison]::OrdinalIgnoreCase) -and
            $strFixtureRoot -cne $strTempRoot) {
            Remove-Item -LiteralPath $strFixtureRoot -Recurse -Force
        }
    }
}

function Assert-ClassificationAdmissionGitFixture {
    # .SYNOPSIS
    # Tests exact accepted-base classification admission without parser dependencies.
    #
    # .DESCRIPTION
    # Runs the installed fixture validator at B against inert H data and rejects
    # mixed policy/data bypasses. Candidate executable bytes must never execute.
    # Also checks the real workflow call and mutations of its branch placement.
    #
    # .PARAMETER RepositoryRootPath
    # The repository supplying the proposed validator and workflow fixture bytes.
    #
    # .EXAMPLE
    # Assert-ClassificationAdmissionGitFixture -RepositoryRootPath $strRoot
    #
    # # Throws if trusted admission or unconditional workflow placement fails.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None. The function throws when a fixture fails.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261002.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param([Parameter(Mandatory)][string] $RepositoryRootPath)

    $strTempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    $strFixtureRoot = [IO.Path]::Combine($strTempRoot,
        'agent-classification-admission-' + [Guid]::NewGuid().ToString('N'))
    $strWorkflowDirectory = [IO.Path]::Combine($strFixtureRoot, '.github', 'workflows')
    [void][IO.Directory]::CreateDirectory($strWorkflowDirectory)
    $strEmptyHooks = [IO.Path]::Combine($strFixtureRoot, 'empty-hooks')
    [void][IO.Directory]::CreateDirectory($strEmptyHooks)
    $strValidatorPath = [IO.Path]::Combine($strWorkflowDirectory, 'Test-AgentInstructions.ps1')
    $strManifestPath = [IO.Path]::Combine($strFixtureRoot, '.github', 'document-metadata-classification.json')
    $strValidatorContent = [IO.File]::ReadAllText([IO.Path]::Combine(
            $RepositoryRootPath, '.github', 'workflows', 'Test-AgentInstructions.ps1'))
    $strHostPath = (Get-Process -Id $PID).Path
    $strPlainManifest = '{"schemaVersion":2,"authorizedExemptionPaths":[],"tier2Paths":["README.md"],"generatedPaths":[]}'
    $strAuthorizedManifest = $strPlainManifest.Replace('"authorizedExemptionPaths":[]',
        '"authorizedExemptionPaths":["docs/RUNBOOK.md"]')
    $strActivatedManifest = $strPlainManifest.Replace('["README.md"]', '["README.md","docs/RUNBOOK.md"]')
    $scriptblockCommit = {
        & git -C $strFixtureRoot -c core.autocrlf=false add --all
        if ($LASTEXITCODE -ne 0) { throw 'Admission fixture indexing failed.' }
        & git -C $strFixtureRoot -c user.name=AdmissionFixture `
            -c user.email=admission-fixture@example.invalid -c commit.gpgsign=false `
            -c "core.hooksPath=$strEmptyHooks" commit --quiet --no-gpg-sign --message=fixture
        if ($LASTEXITCODE -ne 0) { throw 'Admission fixture commit failed.' }
        ([string](& git -C $strFixtureRoot rev-parse --verify 'HEAD^{commit}')).Trim()
    }
    $scriptblockCheck = {
        param([string] $Baseline, [string] $Candidate, [bool] $Accept, [string] $Expected)
        & git -C $strFixtureRoot -c "core.hooksPath=$strEmptyHooks" checkout --quiet --detach $Baseline
        if ($LASTEXITCODE -ne 0) { throw 'Admission baseline checkout failed.' }
        $strOutput = (& $strHostPath -NoProfile -File $strValidatorPath `
                -MetadataClassificationOnly -InputRevision $Candidate `
                -PublishedBaselineRevision $Baseline 2>&1 | Out-String)
        $intExitCode = $LASTEXITCODE
        if (($intExitCode -eq 0) -ne $Accept -or $strOutput -notmatch $Expected) {
            throw "Classification CLI fixture failed ($Accept, exit $intExitCode): $strOutput"
        }
    }
    try {
        & git -C $strFixtureRoot -c "init.templateDir=$strEmptyHooks" init --quiet --initial-branch=fixture
        if ($LASTEXITCODE -ne 0) { throw 'Admission fixture initialization failed.' }
        [IO.File]::WriteAllText($strValidatorPath, $strValidatorContent, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($strManifestPath, $strPlainManifest, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText([IO.Path]::Combine($strFixtureRoot, 'README.md'), '# Onboarding', [Text.UTF8Encoding]::new($false))
        [void][IO.Directory]::CreateDirectory([IO.Path]::Combine($strFixtureRoot, 'docs'))
        [IO.File]::WriteAllText([IO.Path]::Combine($strFixtureRoot, 'docs', 'RUNBOOK.md'), '# Procedure', [Text.UTF8Encoding]::new($false))
        $strBaseline = & $scriptblockCommit
        # This accepted fixture installs the proposed checker; it is not native first-install authority.
        & $scriptblockCheck $strBaseline $strBaseline $true 'Metadata classification data validated'
        $strGeneratedManifest = '{"schemaVersion":2,"authorizedExemptionPaths":[],"tier2Paths":[],"generatedPaths":["README.md"]}'
        [IO.File]::WriteAllText($strManifestPath, $strGeneratedManifest, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText([IO.Path]::Combine($strFixtureRoot, 'README.md'),
            "# Reader`n`n- **Status:** Broken`n- **Last Updated:** 2099-99-99`n", [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($strValidatorPath, "throw 'CANDIDATE_EXECUTED'", [Text.UTF8Encoding]::new($false))
        $strReclassifiedCandidate = & $scriptblockCommit
        & $scriptblockCheck $strBaseline $strReclassifiedCandidate $false '(?s)unauthenticated generated status:.*README[.]md'
        # The existing published path-authorization route still permits activation.
        $strReadmeAuthorization = '{"schemaVersion":2,"authorizedExemptionPaths":["README.md"],"tier2Paths":[],"generatedPaths":[]}'
        [IO.File]::WriteAllText($strManifestPath, $strReadmeAuthorization, [Text.UTF8Encoding]::new($false))
        $strReadmeAuthorizedBaseline = & $scriptblockCommit
        & $scriptblockCheck $strBaseline $strReadmeAuthorizedBaseline $true 'Metadata classification data validated'
        & git -C $strFixtureRoot checkout --quiet --detach $strReadmeAuthorizedBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Generated authorization baseline checkout failed.' }
        [IO.File]::WriteAllText($strManifestPath, $strGeneratedManifest, [Text.UTF8Encoding]::new($false))
        $strGeneratedCandidate = & $scriptblockCommit
        & $scriptblockCheck $strReadmeAuthorizedBaseline $strGeneratedCandidate $true 'Metadata classification data validated'
        & $scriptblockCheck $strGeneratedCandidate $strGeneratedCandidate $true 'Metadata classification data validated'
        [IO.File]::WriteAllText($strManifestPath, $strPlainManifest, [Text.UTF8Encoding]::new($false))
        $strTier2Candidate = & $scriptblockCommit
        & $scriptblockCheck $strGeneratedCandidate $strTier2Candidate $true 'Metadata classification data validated'
        & git -C $strFixtureRoot checkout --quiet --detach $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Category fixture baseline restoration failed.' }
        [IO.File]::WriteAllText($strManifestPath, $strActivatedManifest, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($strValidatorPath,
            "throw 'CANDIDATE_EXECUTED'", [Text.UTF8Encoding]::new($false))
        $strMixedCandidate = & $scriptblockCommit
        & $scriptblockCheck $strBaseline $strMixedCandidate $false 'docs/RUNBOOK.md'
        [IO.File]::WriteAllText($strManifestPath,
            $strActivatedManifest.Replace('"authorizedExemptionPaths":[]',
                '"authorizedExemptionPaths":["docs/RUNBOOK.md"]'), [Text.UTF8Encoding]::new($false))
        $strCombinedCandidate = & $scriptblockCommit
        & $scriptblockCheck $strBaseline $strCombinedCandidate $false 'docs/RUNBOOK.md'
        [IO.File]::WriteAllText($strManifestPath, $strAuthorizedManifest, [Text.UTF8Encoding]::new($false))
        $strAuthorizationCandidate = & $scriptblockCommit
        & $scriptblockCheck $strBaseline $strAuthorizationCandidate $true 'Metadata classification data validated'
        & git -C $strFixtureRoot checkout --quiet --detach $strAuthorizationCandidate
        if ($LASTEXITCODE -ne 0) { throw 'Authorization baseline checkout failed.' }
        $strAuthorizedBaseline = $strAuthorizationCandidate
        [IO.File]::WriteAllText($strManifestPath, $strActivatedManifest, [Text.UTF8Encoding]::new($false))
        $strActivatedCandidate = & $scriptblockCommit
        & $scriptblockCheck $strAuthorizedBaseline $strActivatedCandidate $true 'Metadata classification data validated'
        [IO.File]::WriteAllText($strManifestPath, '{"schemaVersion":1}', [Text.UTF8Encoding]::new($false))
        $strMalformedCandidate = & $scriptblockCommit
        & $scriptblockCheck $strBaseline $strMalformedCandidate $false 'classification manifest'
        [IO.File]::WriteAllText($strManifestPath, (' ' * 32769), [Text.UTF8Encoding]::new($false))
        $strOversizeCandidate = & $scriptblockCommit
        & $scriptblockCheck $strBaseline $strOversizeCandidate $false 'byte|bytes'
        Remove-Item -LiteralPath $strManifestPath -Force
        $strMissingManifestCandidate = & $scriptblockCommit
        & $scriptblockCheck $strBaseline $strMissingManifestCandidate $false 'document-metadata-classification.json'
        & git -C $strFixtureRoot -c "core.hooksPath=$strEmptyHooks" checkout --quiet --detach $strBaseline
        foreach ($arrInvalidArguments in @(
                @('-MetadataClassificationOnly'),
                @('-MetadataClassificationOnly', '-SelfTest', '-InputRevision', $strBaseline, '-PublishedBaselineRevision', $strBaseline),
                @('-MetadataClassificationOnly', '-InputRevision', 'abc', '-PublishedBaselineRevision', $strBaseline))) {
            $null = & $strHostPath -NoProfile -File $strValidatorPath @arrInvalidArguments 2>&1
            if ($LASTEXITCODE -eq 0) { throw 'An invalid classification mode combination was accepted.' }
        }
        & git -C $strFixtureRoot checkout --quiet --detach $strAuthorizedBaseline
        $null = & $strHostPath -NoProfile -File $strValidatorPath -MetadataClassificationOnly `
            -InputRevision $strActivatedCandidate -PublishedBaselineRevision $strBaseline 2>&1
        if ($LASTEXITCODE -eq 0) { throw 'Classification mode accepted checkout different from B.' }
    } finally {
        $strResolvedFixtureRoot = [IO.Path]::GetFullPath($strFixtureRoot)
        if ($strResolvedFixtureRoot.StartsWith($strTempRoot, [StringComparison]::OrdinalIgnoreCase) -and
            $strResolvedFixtureRoot -cne $strTempRoot -and [IO.Directory]::Exists($strResolvedFixtureRoot)) {
            Remove-Item -LiteralPath $strResolvedFixtureRoot -Recurse -Force
        }
    }

    $strWorkflow = [IO.File]::ReadAllText([IO.Path]::Combine(
            $RepositoryRootPath, '.github', 'workflows', 'agent-instructions.yml'))
    $objRunMatch = [regex]::Match($strWorkflow,
        '(?ms)^      - name: Classify exact PR input and validate ordinary content\r?\n.*?^        run: \|\r?\n(?<run>(?:          [^\r\n]*\r?\n)+)')
    if (-not $objRunMatch.Success) { throw 'The accepted-policy validation run block is unavailable.' }
    $strRun = [regex]::Replace($objRunMatch.Groups['run'].Value, '(?m)^          ', '')
    $scriptblockCallProof = {
        param([string] $Run)
        $arrTokens = $null
        $arrErrors = $null
        $objAst = [Management.Automation.Language.Parser]::ParseInput($Run, [ref]$arrTokens, [ref]$arrErrors)
        if ($arrErrors.Count -ne 0) { return $false }
        $arrCalls = @($objAst.FindAll({ param($Node)
                    $Node -is [Management.Automation.Language.CommandAst] -and
                    $Node.CommandElements.Extent.Text -contains '-MetadataClassificationOnly' }, $true))
        if ($arrCalls.Count -ne 1) { return $false }
        $objCall = $arrCalls[0]
        if ($objCall.Extent.Text -notmatch '-InputRevision \$env:EXPECTED_HEAD -PublishedBaselineRevision \$env:EXPECTED_BASE') { return $false }
        $objParent = $objCall.Parent
        while ($null -ne $objParent) {
            if ($objParent -is [Management.Automation.Language.IfStatementAst]) { return $false }
            $objParent = $objParent.Parent
        }
        $intClassify = $Run.IndexOf('$strResult = & node .github/workflows/Classify-InstructionMaintenance.mjs', [StringComparison]::Ordinal)
        if ($intClassify -lt $objCall.Extent.EndOffset) { return $false }
        $strFollowing = $Run.Substring($objCall.Extent.EndOffset)
        return $strFollowing -match '^\r?\nif \(\$LASTEXITCODE -ne 0\) \{ throw ''Accepted metadata classification rejected PR data\.''' -and
            $Run -match '\$ErrorActionPreference = ''Stop'''
    }
    if (-not (& $scriptblockCallProof $strRun)) { throw 'The real workflow lacks unconditional fatal accepted-base data admission.' }
    $strCall = '& ./.github/workflows/Test-AgentInstructions.ps1 -MetadataClassificationOnly -InputRevision $env:EXPECTED_HEAD -PublishedBaselineRevision $env:EXPECTED_BASE'
    foreach ($strMutation in @(
            $strRun.Replace($strCall, '# removed admission'),
            $strRun.Replace($strCall, "if (`$objResult.classification -ceq 'ordinary') { $strCall }"),
            $strRun.Replace("throw 'Accepted metadata classification rejected PR data.'", "Write-Output 'ignored classification failure'"))) {
        if (& $scriptblockCallProof $strMutation) { throw 'An unsafe workflow admission mutation passed.' }
    }
}

function Assert-AuthorFinalizationGitFixture {
    # .SYNOPSIS
    # Tests the deliberate finalization caller and unchanged delayed verification.
    #
    # .DESCRIPTION
    # Installs proposed checker code in a scratch accepted B, reads candidate H
    # as Git data, and exercises new, promoted and versioned document consumers.
    # A debugger clock shim changes only the test clock, never repository bytes.
    #
    # .PARAMETER RepositoryRootPath
    # The repository supplying proposed code and locked Markdown dependencies.
    #
    # .EXAMPLE
    # Assert-AuthorFinalizationGitFixture -RepositoryRootPath $strRoot
    #
    # # Throws on incorrect finalization, delayed-check or mutation behavior.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None. The function throws if a production caller fixture fails.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261002.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param([Parameter(Mandatory)][string] $RepositoryRootPath)

    $strTempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    $strFixtureRoot = [IO.Path]::Combine($strTempRoot,
        'agent-author-finalization-' + [Guid]::NewGuid().ToString('N'))
    $strEmptyHooks = [IO.Path]::Combine($strTempRoot,
        'agent-finalization-hooks-' + [Guid]::NewGuid().ToString('N'))
    [void][IO.Directory]::CreateDirectory($strEmptyHooks)
    $strHostPath = (Get-Process -Id $PID).Path
    $objFixtureNodeCommand = Get-Command -Name 'node' -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($null -eq $objFixtureNodeCommand) { throw 'Finalization fixture requires the trusted Node application.' }
    $objFixtureUtcNow = [DateTimeOffset]::UtcNow
    $strCurrentDate = $objFixtureUtcNow.ToString('yyyy-MM-dd')
    $strPriorDate = $objFixtureUtcNow.AddDays(-1).ToString('yyyy-MM-dd')
    $strBaselineDate = $objFixtureUtcNow.AddDays(-2).ToString('yyyy-MM-dd')
    $strFutureDate = $objFixtureUtcNow.AddDays(1).ToString('yyyy-MM-dd')
    $strValidatorPath = [IO.Path]::Combine($strFixtureRoot, '.github', 'workflows', 'Test-AgentInstructions.ps1')
    $strRunbookPath = [IO.Path]::Combine($strFixtureRoot, 'docs', 'finalization-fixture.md')
    $strValidatorContent = [IO.File]::ReadAllText([IO.Path]::Combine(
            $RepositoryRootPath, '.github', 'workflows', 'Test-AgentInstructions.ps1'))
    $strMetadataDocument = "# Finalization fixture`n`n## Metadata`n`n- **Status:** Active`n- **Owner:** Fixture Maintainers`n- **Last Updated:** DATE`n- **Scope:** Author finalization tests.`n`n## Procedure`n`nFollow the current procedure.`n"
    # Private installed-policy setup uses only current tracked regular files.
    # Bound index output, each file and aggregate bytes; keep dependencies separate.
    # Native lstat supplies the type and identity immediately around each read.
    # This is not atomic confinement: the private fixture assumes no competing
    # writer. The child timeout does not bound a later substituted .NET OpenRead.
    $strFixtureInquiryProgram = @(
        'const fs = require("node:fs");'
        'const st = fs.lstatSync(process.argv[1], { bigint: true });'
        'if (!st.isFile()) { process.stdout.write("nonregular"); }'
        'else { process.stdout.write(["regular", st.dev, st.ino, st.mode, st.size, st.mtimeNs, st.ctimeNs].join("|")); }'
    ) -join "`n"
    $scriptblockFileInquiry = {
        param([string] $Path)
        if (-not [IO.Path]::IsPathRooted($Path)) { throw 'Finalization file inquiry requires an absolute path.' }
        $objStartInfo = [Diagnostics.ProcessStartInfo]::new($objFixtureNodeCommand.Source)
        $objStartInfo.UseShellExecute = $false
        $objStartInfo.CreateNoWindow = $true
        $objStartInfo.RedirectStandardOutput = $true
        $objStartInfo.RedirectStandardError = $true
        [void]$objStartInfo.Environment.Remove('NODE_OPTIONS')
        [void]$objStartInfo.Environment.Remove('NODE_PATH')
        foreach ($strArgument in @('-e', $strFixtureInquiryProgram, $Path)) { $objStartInfo.ArgumentList.Add($strArgument) }
        $objProcess = [Diagnostics.Process]::new()
        $objProcess.StartInfo = $objStartInfo
        $objResult = Read-BoundedProcessData -Process $objProcess -MaximumBytes 4096 `
            -TimeoutMilliseconds 5000 -DisplayName 'Finalization authoritative file inquiry'
        if ($objResult.ExitCode -ne 0) { throw 'Finalization authoritative file inquiry failed.' }
        $strRecord = ConvertFrom-StrictUtf8Data -Bytes $objResult.Bytes -DisplayName 'Finalization authoritative file inquiry'
        if ($strRecord -ceq 'nonregular') { throw 'Finalization fixture input is authoritatively nonregular.' }
        if ($strRecord -cnotmatch ('\Aregular(?:\|(?:0|[1-9][0-9]{0,39})){4}' +
                '(?:\|(?:0|-?[1-9][0-9]{0,39})){2}\z')) {
            throw 'Finalization authoritative file inquiry returned a malformed identity record.'
        }
        return $strRecord
    }
    $scriptblockSnapshot = {
        param([string] $Root)
        $objStartInfo = [Diagnostics.ProcessStartInfo]::new('git')
        $objStartInfo.UseShellExecute = $false
        $objStartInfo.CreateNoWindow = $true
        $objStartInfo.RedirectStandardOutput = $true
        $objStartInfo.RedirectStandardError = $true
        foreach ($strArgument in @('-C', $Root, 'ls-files', '--stage', '-z')) {
            $objStartInfo.ArgumentList.Add($strArgument)
        }
        $objProcess = [Diagnostics.Process]::new()
        $objProcess.StartInfo = $objStartInfo
        $objResult = Read-BoundedProcessData -Process $objProcess -MaximumBytes 1048576 `
            -TimeoutMilliseconds 10000 -DisplayName 'Finalization fixture index'
        if ($objResult.ExitCode -ne 0) { throw 'Finalization fixture index acquisition failed.' }
        $arrTrackedPaths = @(Read-GitTrackedPath -RepositoryRootPath $Root -MaximumBytes 1048576)
        $strEntries = ConvertFrom-StrictUtf8Data -Bytes $objResult.Bytes -DisplayName 'Finalization fixture index'
        if (-not $strEntries.EndsWith([string][char]0, [StringComparison]::Ordinal)) {
            throw 'Finalization fixture index must have terminal NUL.'
        }
        $arrEntries = @($strEntries.TrimEnd([char]0).Split([char]0))
        if ($arrEntries.Count -gt 4096 -or $arrEntries.Count -ne $arrTrackedPaths.Count) {
            throw 'Finalization fixture index has an unsupported count or unresolved stages.'
        }
        $setPaths = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        $dictComponents = [Collections.Generic.Dictionary[string, string]]::new([StringComparer]::OrdinalIgnoreCase)
        $listSnapshot = [Collections.Generic.List[object]]::new()
        $longTotalBytes = 0L
        foreach ($strEntry in $arrEntries) {
            $objEntry = [regex]::Match($strEntry, '^(?<mode>100644|100755) (?<blob>[0-9a-f]{40}) 0\t(?<path>.+)$')
            if (-not $objEntry.Success) { throw 'Finalization fixture requires stage-0 regular Git files.' }
            $strPath = $objEntry.Groups['path'].Value
            if ([IO.Path]::IsPathRooted($strPath) -or $strPath -match '[\\:\x00-\x1f\x7f]' -or
                $strPath -match '(?:^|/)(?:\.{1,2}|\.git|node_modules)(?:/|$)' -or
                $strPath.Contains('//', [StringComparison]::Ordinal) -or -not $setPaths.Add($strPath) -or
                $arrTrackedPaths -cnotcontains $strPath) {
                throw 'Finalization fixture contains an unsafe or colliding tracked path.'
            }
            $strFilePath = [IO.Path]::Combine($Root, $strPath)
            $listComponents = [Collections.Generic.List[object]]::new()
            $strComponentPath = $Root
            $strRelativeComponent = ''
            foreach ($strComponent in $strPath.Split('/')) {
                if ($strComponent -match '[. ]$') { throw 'Finalization fixture contains an aliased path component.' }
                $strRelativeComponent = ($strRelativeComponent + '/' + $strComponent).TrimStart('/')
                if ($dictComponents.ContainsKey($strRelativeComponent) -and
                    $dictComponents[$strRelativeComponent] -cne $strRelativeComponent) {
                    throw 'Finalization fixture contains a case-colliding path component.'
                }
                $dictComponents[$strRelativeComponent] = $strRelativeComponent
                $strComponentPath = [IO.Path]::Combine($strComponentPath, $strComponent)
                $objItem = Get-Item -LiteralPath $strComponentPath -Force
                if (($objItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0 -or $objItem.LinkType) {
                    throw 'Finalization fixture contains an unsafe linked path component.'
                }
                $listComponents.Add([pscustomobject]@{ Path = $strComponentPath; Type = $objItem.GetType(); Created = $objItem.CreationTimeUtc.Ticks })
            }
            if ($objItem -isnot [IO.FileInfo]) { throw 'Finalization fixture input is not a regular file.' }
            $objUnixModeProperty = $objItem.PSObject.Properties['UnixMode']
            $strUnixMode = if ($null -eq $objUnixModeProperty) { '' } else { [string]$objUnixModeProperty.Value }
            if (-not [string]::IsNullOrEmpty($strUnixMode) -and $strUnixMode[0] -cne '-') {
                throw 'Finalization fixture input has a non-regular Unix file type.'
            }
            $strAuthoritativeIdentity = & $scriptblockFileInquiry $strFilePath
            $objStream = [IO.File]::OpenRead($strFilePath)
            try {
                $arrBytes = [byte[]]@(Read-BoundedStreamData -Stream $objStream -MaximumBytes 16777216 `
                        -DisplayName 'Finalization fixture tracked input')
            } finally { $objStream.Dispose() }
            $strRecheckedAuthoritativeIdentity = & $scriptblockFileInquiry $strFilePath
            if ($strRecheckedAuthoritativeIdentity -cne $strAuthoritativeIdentity) {
                throw 'Finalization fixture authoritative file identity changed during its bounded read.'
            }
            foreach ($objComponent in $listComponents) {
                $objItem = Get-Item -LiteralPath $objComponent.Path -Force
                if (($objItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0 -or $objItem.LinkType -or
                    $objItem.GetType() -ne $objComponent.Type -or $objItem.CreationTimeUtc.Ticks -ne $objComponent.Created) {
                    throw 'Finalization fixture path changed during its bounded read.'
                }
            }
            $objUnixModeProperty = $objItem.PSObject.Properties['UnixMode']
            $strRecheckedUnixMode = if ($null -eq $objUnixModeProperty) { '' } else { [string]$objUnixModeProperty.Value }
            if ($strRecheckedUnixMode -cne $strUnixMode) { throw 'Finalization fixture Unix type or mode changed during its bounded read.' }
            $longTotalBytes += $arrBytes.Length
            if ($longTotalBytes -gt 67108864) { throw 'Finalization fixture tracked snapshot exceeds its aggregate bound.' }
            $arrBlobHeader = [Text.Encoding]::ASCII.GetBytes("blob $($arrBytes.Length)$([char]0)")
            $objBlobDigest = $null
            $objRawDigest = $null
            try {
                $objBlobDigest = [Security.Cryptography.SHA1]::Create()
                $objRawDigest = [Security.Cryptography.SHA256]::Create()
                $strRawBlob = [BitConverter]::ToString($objBlobDigest.ComputeHash(
                        [byte[]]($arrBlobHeader + $arrBytes))).Replace('-', '').ToLowerInvariant()
                $strRawSha256 = [BitConverter]::ToString($objRawDigest.ComputeHash($arrBytes)).Replace('-', '')
            } finally {
                if ($null -ne $objBlobDigest) { $objBlobDigest.Dispose() }
                if ($null -ne $objRawDigest) { $objRawDigest.Dispose() }
            }
            $listSnapshot.Add([pscustomobject]@{ Path = $strPath; Mode = $objEntry.Groups['mode'].Value
                    IndexBlob = $objEntry.Groups['blob'].Value; Blob = $strRawBlob; Bytes = $arrBytes
                    Sha256 = $strRawSha256 })
        }
        return $listSnapshot.ToArray()
    }
    $scriptblockSnapshotIdentity = {
        param([object[]] $Snapshot)
        @($Snapshot | ForEach-Object { "$($_.Path)`t$($_.Mode)`t$($_.IndexBlob)`t$($_.Blob)`t$($_.Sha256)" }) -join "`n"
    }
    # Check intended index/tree modes after every staging/commit boundary.
    # Physical permissions are not consumed by this fixture's explicit callers.
    $scriptblockAssertModes = {
        param([string] $Revision = '')
        $arrArguments = if ([string]::IsNullOrEmpty($Revision)) {
            @('-C', $strFixtureRoot, 'ls-files', '--stage', '-z')
        } else { @('-C', $strFixtureRoot, 'ls-tree', '-r', '-z', $Revision) }
        $objStartInfo = [Diagnostics.ProcessStartInfo]::new('git')
        $objStartInfo.UseShellExecute = $false
        $objStartInfo.CreateNoWindow = $true
        $objStartInfo.RedirectStandardOutput = $true
        $objStartInfo.RedirectStandardError = $true
        foreach ($strArgument in $arrArguments) { $objStartInfo.ArgumentList.Add($strArgument) }
        $objProcess = [Diagnostics.Process]::new()
        $objProcess.StartInfo = $objStartInfo
        $objResult = Read-BoundedProcessData -Process $objProcess -MaximumBytes 1048576 `
            -TimeoutMilliseconds 10000 -DisplayName 'Finalization intended modes'
        if ($objResult.ExitCode -ne 0) { throw 'Finalization intended-mode acquisition failed.' }
        $strEntries = ConvertFrom-StrictUtf8Data -Bytes $objResult.Bytes -DisplayName 'Finalization intended modes'
        if (-not $strEntries.EndsWith([string][char]0, [StringComparison]::Ordinal)) {
            throw 'Finalization intended modes must have terminal NUL.'
        }
        $setSeen = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
        foreach ($strEntry in $strEntries.TrimEnd([char]0).Split([char]0)) {
            $objEntry = [regex]::Match($strEntry,
                '^(?<mode>100644|100755) (?:blob [0-9a-f]{40}|[0-9a-f]{40} 0)\t(?<path>.+)$')
            if (-not $objEntry.Success -or -not $setSeen.Add($objEntry.Groups['path'].Value)) {
                throw 'Finalization intended modes contain unsafe or unresolved entries.'
            }
            $strPath = $objEntry.Groups['path'].Value
            $strExpectedMode = if ($dictExpectedModes.ContainsKey($strPath)) {
                $dictExpectedModes[$strPath]
            } else { '100644' }
            if ($objEntry.Groups['mode'].Value -cne $strExpectedMode) {
                throw "Finalization intended Git mode changed: $strPath."
            }
        }
        foreach ($strPath in $dictExpectedModes.Keys) {
            if (-not $setSeen.Contains($strPath)) { throw "Finalization installed path disappeared: $strPath." }
        }
    }
    $scriptblockCommit = {
        & git -C $strFixtureRoot -c core.autocrlf=false add --all
        if ($LASTEXITCODE -ne 0) { throw 'Finalization fixture indexing failed.' }
        & $scriptblockAssertModes
        & git -C $strFixtureRoot -c user.name=FinalizationFixture `
            -c user.email=finalization-fixture@example.invalid -c commit.gpgsign=false `
            -c "core.hooksPath=$strEmptyHooks" commit --quiet --no-gpg-sign --message=fixture
        if ($LASTEXITCODE -ne 0) { throw 'Finalization fixture commit failed.' }
        $strCommittedHead = ([string](& git -C $strFixtureRoot rev-parse --verify 'HEAD^{commit}')).Trim()
        if ($LASTEXITCODE -ne 0 -or $strCommittedHead -cnotmatch '^[0-9a-f]{40}$') {
            throw 'Finalization committed HEAD resolution failed.'
        }
        & $scriptblockAssertModes $strCommittedHead
        return $strCommittedHead
    }
    $scriptblockCheck = {
        param([string] $Candidate, [bool] $Now, [bool] $Later, [bool] $Accept, [string] $Expected)
        & git -C $strFixtureRoot -c "core.hooksPath=$strEmptyHooks" checkout --quiet --detach $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Finalization policy checkout failed.' }
        $strClockShim = if ($Later) {
            '$clockLine = ([IO.File]::ReadAllLines($checker) | Select-String -SimpleMatch ''$script:objMaximumCommitUtcTimestamp ='' | Select-Object -First 1).LineNumber; ' +
            '$null = Set-PSBreakpoint -Script $checker -Line ($clockLine + 1) -Action { ' +
            '$script:objValidationUtcNow = [DateTimeOffset]::Parse(''' + $objFixtureUtcNow.AddDays(1).ToString('o') + '''); ' +
            '$script:strMaximumMetadataUtcDate = $script:objValidationUtcNow.ToString(''yyyy-MM-dd''); ' +
            '$script:objMaximumCommitUtcTimestamp = $script:objValidationUtcNow.AddMinutes(5) }; '
        } else { '' }
        $strCommand = '$ErrorActionPreference = ''Stop''; $checker = ''' + $strValidatorPath.Replace("'", "''") + '''; ' +
            $strClockShim + 'try { & $checker -InputRevision ' + $Candidate + ' -PublishedBaselineRevision ' + $strBaseline +
            $(if ($Now) { ' -FinalizeMetadataNow' } else { '' }) +
            ' } catch { [Console]::Out.WriteLine($_.Exception.Message); exit 1 }'
        $strOutput = (& $strHostPath -NoLogo -NoProfile -NonInteractive -Command $strCommand 2>&1 | Out-String)
        $intExit = $LASTEXITCODE
        if (($intExit -eq 0) -ne $Accept -or $strOutput -notmatch $Expected) {
            throw "Author finalization caller failed (Now=$Now Later=$Later Accept=$Accept exit=$intExit): $strOutput"
        }
    }
    try {
        # Exercise the actual bounded inquiry before the longer installed-policy
        # scenarios. Controlled programs replace only the native response producer.
        $strInquiryControlPath = [IO.Path]::Combine($strEmptyHooks, 'inquiry-control.dat')
        [IO.File]::WriteAllBytes($strInquiryControlPath, [byte[]]@(0, 255, 1, 0))
        [void](& $scriptblockFileInquiry $strInquiryControlPath)
        $strSavedInquiryProgram = $strFixtureInquiryProgram
        try {
            foreach ($objInquiryCase in @(
                    @{ Program = 'process.stdout.write("regular|1|2|3|4|5");'; Expected = 'malformed identity record' },
                    @{ Program = 'process.stdout.write("regular|1|2|3|4|5|6|7");'; Expected = 'malformed identity record' },
                    @{ Program = 'process.stdout.write("regular|-1|2|3|4|5|6");'; Expected = 'malformed identity record' },
                    @{ Program = 'process.stdout.write("regular|1|2|3|4|1e3|6");'; Expected = 'malformed identity record' },
                    @{ Program = 'process.stdout.write("nonregular");'; Expected = 'authoritatively nonregular' },
                    @{ Program = 'process.exit(42);'; Expected = 'authoritative file inquiry failed' },
                    @{ Program = 'process.stdout.write("x".repeat(4097));'; Expected = 'must not exceed|exceeded|output bound' },
                    @{ Program = 'setInterval(() => {}, 1000);'; Expected = 'timeout|timed out|deadline' }
                )) {
                $strFixtureInquiryProgram = $objInquiryCase.Program
                $boolRejected = $false
                try { [void](& $scriptblockFileInquiry $strInquiryControlPath) } catch {
                    if ($_.Exception.Message -notmatch $objInquiryCase.Expected) { throw }
                    $boolRejected = $true
                }
                if (-not $boolRejected) { throw 'A malformed or failed authoritative inquiry was accepted.' }
            }
        } finally { $strFixtureInquiryProgram = $strSavedInquiryProgram }
        $scriptblockSavedFileInquiry = $scriptblockFileInquiry
        $script:boolFixtureInquiryChanged = $false
        try {
            $scriptblockFileInquiry = {
                param([string] $Path)
                if (-not [IO.Path]::IsPathRooted($Path)) { throw 'Controlled identity inquiry requires an absolute path.' }
                if ($script:boolFixtureInquiryChanged) { return 'regular|1|2|3|4|5|7' }
                $script:boolFixtureInquiryChanged = $true
                return 'regular|1|2|3|4|5|6'
            }
            $boolRejected = $false
            try { $null = & $scriptblockSnapshot $RepositoryRootPath } catch {
                if ($_.Exception.Message -notmatch 'authoritative file identity changed') { throw }
                $boolRejected = $true
            }
            if (-not $boolRejected) { throw 'An authoritative before/after identity change was accepted.' }
        } finally {
            $scriptblockFileInquiry = $scriptblockSavedFileInquiry
            Remove-Variable -Name boolFixtureInquiryChanged -Scope Script -ErrorAction SilentlyContinue
        }
        [IO.File]::Delete($strInquiryControlPath)
        Write-Verbose 'Finalization authoritative inquiry shape/native-exit/bound/timeout/identity controls passed.'
        & git -c "init.templateDir=$strEmptyHooks" clone --quiet --shared --no-hardlinks --no-checkout -- $RepositoryRootPath $strFixtureRoot
        if ($LASTEXITCODE -ne 0) { throw 'Finalization fixture acquisition failed.' }
        & git -C $strFixtureRoot config --local core.fileMode false
        if ($LASTEXITCODE -ne 0) { throw 'Finalization private file-mode configuration failed.' }
        $strPrivateFileMode = ([string](& git -C $strFixtureRoot config --local --bool --get core.fileMode)).Trim()
        if ($LASTEXITCODE -ne 0 -or $strPrivateFileMode -cne 'false') {
            throw 'Finalization private file-mode configuration readback failed.'
        }
        $strSourceHead = ([string](& git -C $RepositoryRootPath rev-parse --verify 'HEAD^{commit}')).Trim()
        if ($LASTEXITCODE -ne 0 -or $strSourceHead -cnotmatch '^[0-9a-f]{40}$') {
            throw 'Finalization fixture source HEAD is invalid.'
        }
        & git -C $strFixtureRoot -c "core.hooksPath=$strEmptyHooks" checkout --quiet --detach $strSourceHead
        if ($LASTEXITCODE -ne 0) { throw 'Finalization fixture source checkout failed.' }
        $arrSourceSnapshot = @(& $scriptblockSnapshot $RepositoryRootPath)
        $strSourceIdentity = & $scriptblockSnapshotIdentity $arrSourceSnapshot
        $dictExpectedModes = [Collections.Generic.Dictionary[string, string]]::new([StringComparer]::Ordinal)
        foreach ($objSourceInput in $arrSourceSnapshot) { $dictExpectedModes.Add($objSourceInput.Path, $objSourceInput.Mode) }
        $arrCloneSnapshot = @(& $scriptblockSnapshot $strFixtureRoot)
        foreach ($objCloneInput in $arrCloneSnapshot) {
            if ($arrSourceSnapshot.Path -cnotcontains $objCloneInput.Path) {
                [IO.File]::Delete([IO.Path]::Combine($strFixtureRoot, $objCloneInput.Path))
            }
        }
        foreach ($objSourceInput in $arrSourceSnapshot) {
            $strDestination = [IO.Path]::Combine($strFixtureRoot, $objSourceInput.Path)
            [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($strDestination))
            [IO.File]::WriteAllBytes($strDestination, $objSourceInput.Bytes)
        }
        & git -C $strFixtureRoot -c core.autocrlf=false add --all
        if ($LASTEXITCODE -ne 0) { throw 'Finalization installed snapshot indexing failed.' }
        foreach ($objSourceInput in $arrSourceSnapshot) {
            $strModeArgument = if ($objSourceInput.Mode -ceq '100755') { '--chmod=+x' } else { '--chmod=-x' }
            & git -C $strFixtureRoot update-index $strModeArgument -- $objSourceInput.Path
            if ($LASTEXITCODE -ne 0) { throw 'Finalization installed snapshot mode indexing failed.' }
        }
        $arrInstalledSnapshot = @(& $scriptblockSnapshot $strFixtureRoot)
        if ((& $scriptblockSnapshotIdentity $arrInstalledSnapshot) -cne $strSourceIdentity) {
            # Source index blobs can precede worktree edits; destination index must
            # instead equal the exact raw candidate blobs we just installed.
            $strExpectedInstalledIdentity = @($arrSourceSnapshot | ForEach-Object {
                    "$($_.Path)`t$($_.Mode)`t$($_.Blob)`t$($_.Blob)`t$($_.Sha256)" }) -join "`n"
            if ((& $scriptblockSnapshotIdentity $arrInstalledSnapshot) -cne $strExpectedInstalledIdentity) {
                throw 'Finalization installed snapshot path/blob/mode/raw comparison failed.'
            }
        }
        if ((& $scriptblockSnapshotIdentity @(& $scriptblockSnapshot $RepositoryRootPath)) -cne $strSourceIdentity) {
            throw 'Finalization fixture source changed during materialization.'
        }
        $strRecheckedHead = ([string](& git -C $RepositoryRootPath rev-parse --verify 'HEAD^{commit}')).Trim()
        if ($LASTEXITCODE -ne 0 -or $strRecheckedHead -cne $strSourceHead) { throw 'Finalization fixture source HEAD changed.' }
        Write-Verbose "Finalization installed snapshot verified: $($arrSourceSnapshot.Count) tracked paths; source HEAD=$strSourceHead"
        $strGuidePath = [IO.Path]::Combine($strFixtureRoot, 'STYLE_GUIDE.md')
        $strGuide = [IO.File]::ReadAllText($strGuidePath)
        $arrGuideVersions = @([regex]::Matches($strGuide, '(?m)^\*\*Version:\*\* (?<prefix>\d+\.\d+\.)(?<date>\d{8})\.\d+$'))
        $arrGuideDates = @([regex]::Matches($strGuide, '(?m)^- \*\*Last Updated:\*\* \d{4}-\d{2}-\d{2}$'))
        if ($arrGuideVersions.Count -ne 1 -or $arrGuideDates.Count -ne 1) {
            throw 'Finalization installed guide requires exactly one supported Version and Last Updated field.'
        }
        $strGuide = [regex]::Replace($strGuide,
            '(?m)^(?<prefix>\*\*Version:\*\* \d+\.\d+\.)\d{8}\.\d+$',
            '${prefix}' + $strBaselineDate.Replace('-', '') + '.0')
        $strGuide = [regex]::Replace($strGuide,
            '(?m)^- \*\*Last Updated:\*\* \d{4}-\d{2}-\d{2}$', '- **Last Updated:** ' + $strBaselineDate)
        [IO.File]::WriteAllText($strGuidePath, $strGuide, [Text.UTF8Encoding]::new($false))
        & git -C $strFixtureRoot -c core.autocrlf=false add --all
        if ($LASTEXITCODE -ne 0) { throw 'Finalization normalized setup indexing failed.' }
        & $scriptblockAssertModes
        $strInstalledTree = ([string](& git -C $strFixtureRoot write-tree)).Trim()
        if ($LASTEXITCODE -ne 0) { throw 'Finalization installed tree resolution failed.' }
        $strSourceTree = ([string](& git -C $strFixtureRoot rev-parse --verify 'HEAD^{tree}')).Trim()
        if ($LASTEXITCODE -ne 0) { throw 'Finalization source tree resolution failed.' }
        if ($strInstalledTree -ceq $strSourceTree) {
            $strBaseline = $strSourceHead
            Write-Verbose "Finalization hypothetical installed B reused exact source HEAD=$strBaseline; tree=$strInstalledTree"
        } else {
            $strBaseline = & $scriptblockCommit
            Write-Verbose "Finalization hypothetical installed B committed=$strBaseline; tree=$strInstalledTree"
        }
        & $scriptblockAssertModes $strBaseline
        Write-Verbose "Finalization intended Git modes verified after normalization/B and every candidate commit; private core.fileMode=$strPrivateFileMode"
        [void][IO.Directory]::CreateDirectory([IO.Path]::Combine($strFixtureRoot, 'node_modules'))
        foreach ($strPackage in @('markdown-it', 'argparse', 'entities', 'linkify-it', 'mdurl', 'punycode.js', 'uc.micro')) {
            Copy-Item -LiteralPath ([IO.Path]::Combine($RepositoryRootPath, 'node_modules', $strPackage)) `
                -Destination ([IO.Path]::Combine($strFixtureRoot, 'node_modules', $strPackage)) -Recurse
        }
        [IO.File]::WriteAllText($strRunbookPath, $strMetadataDocument.Replace('DATE', $strCurrentDate), [Text.UTF8Encoding]::new($false))
        $strCurrentCandidate = & $scriptblockCommit
        & $scriptblockCheck $strCurrentCandidate $true $false $true "Author finalization UTC date checked: $strCurrentDate; B=$strBaseline H=$strCurrentCandidate"
        & $scriptblockCheck $strCurrentCandidate $false $true $true 'Finalization date not verified by this invocation'
        # Execute the contributor guide's accepted-base worktree caller, using
        # installed fixture B and exact locally committed H. This is fixture
        # evidence; native pre-install B cannot execute this new mode.
        $strPolicyPath = [IO.Path]::Combine($strFixtureRoot, 'policy-worktree')
        & git -C $strFixtureRoot -c "core.hooksPath=$strEmptyHooks" worktree add --quiet --detach $strPolicyPath $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Documented policy worktree creation failed.' }
        [void][IO.Directory]::CreateDirectory([IO.Path]::Combine($strPolicyPath, 'node_modules'))
        foreach ($strPackage in @('markdown-it', 'argparse', 'entities', 'linkify-it', 'mdurl', 'punycode.js', 'uc.micro')) {
            Copy-Item -LiteralPath ([IO.Path]::Combine($RepositoryRootPath, 'node_modules', $strPackage)) `
                -Destination ([IO.Path]::Combine($strPolicyPath, 'node_modules', $strPackage)) -Recurse
        }
        Push-Location $strPolicyPath
        try {
            $strDocumentedOutput = (& $strHostPath -NoLogo -NoProfile -NonInteractive -File `
                    .github/workflows/Test-AgentInstructions.ps1 -InputRevision $strCurrentCandidate `
                    -PublishedBaselineRevision $strBaseline -FinalizeMetadataNow 2>&1 | Out-String)
            if ($LASTEXITCODE -ne 0 -or $strDocumentedOutput -notmatch "B=$strBaseline H=$strCurrentCandidate") {
                throw "Documented accepted-worktree finalization caller failed: $strDocumentedOutput"
            }
        } finally { Pop-Location }
        # Ignore the fixture-only nested policy checkout in subsequent commits.
        & git -C $strFixtureRoot -c "core.hooksPath=$strEmptyHooks" worktree remove --force $strPolicyPath
        if ($LASTEXITCODE -ne 0) { throw 'Documented fixture worktree cleanup failed.' }
        [IO.File]::WriteAllText($strRunbookPath, $strMetadataDocument.Replace('DATE', $strPriorDate), [Text.UTF8Encoding]::new($false))
        $strEarlierCandidate = & $scriptblockCommit
        & $scriptblockCheck $strEarlierCandidate $true $false $false 'Last Updated must|must use'
        & $scriptblockCheck $strEarlierCandidate $false $true $true 'Finalization date not verified by this invocation'
        foreach ($strInvalidDate in @($strFutureDate, '2026-99-99')) {
            [IO.File]::WriteAllText($strRunbookPath, $strMetadataDocument.Replace('DATE', $strInvalidDate), [Text.UTF8Encoding]::new($false))
            $strInvalidCandidate = & $scriptblockCommit
            & $scriptblockCheck $strInvalidCandidate $true $false $false 'later than trusted UTC|valid|calendar'
        }
        # Optional coverage uses an explicit private installed-policy baseline.
        # This setup is independent of whether future source docs opt in.
        $strBeforeOptionalBaseline = $strBaseline
        $strOptionalReadmePath = [IO.Path]::Combine($strFixtureRoot, 'README.md')
        $strOptionalCatalogPath = [IO.Path]::Combine($strFixtureRoot, '.github', 'copilot-instructions.md')
        $strNoHeaderFixture = "# Reader fixture`n`nNo optional metadata header.`n"
        [IO.File]::WriteAllText($strOptionalReadmePath, $strNoHeaderFixture, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($strOptionalCatalogPath, $strNoHeaderFixture, [Text.UTF8Encoding]::new($false))
        & git -C $strFixtureRoot -c core.autocrlf=false add --all
        if ($LASTEXITCODE -ne 0) { throw 'Optional metadata baseline indexing failed.' }
        & git -C $strFixtureRoot diff --cached --quiet
        $intOptionalBaselineDifference = $LASTEXITCODE
        if ($intOptionalBaselineDifference -eq 1) { $strBaseline = & $scriptblockCommit }
        elseif ($intOptionalBaselineDifference -ne 0) { throw 'Optional metadata baseline comparison failed.' }
        foreach ($strOptionalPath in @($strOptionalReadmePath, $strOptionalCatalogPath)) {
            [IO.File]::WriteAllText($strOptionalPath,
                $strMetadataDocument.Replace('DATE', $strPriorDate), [Text.UTF8Encoding]::new($false))
            $strOptionalStaleCandidate = & $scriptblockCommit
            & $scriptblockCheck $strOptionalStaleCandidate $true $false $false 'Last Updated must'
            & $scriptblockCheck $strOptionalStaleCandidate $false $true $true 'Finalization date not verified by this invocation'
            [IO.File]::WriteAllText($strOptionalPath,
                $strMetadataDocument.Replace('DATE', $strCurrentDate).Replace('Status:** Active', 'Status:** Broken'),
                [Text.UTF8Encoding]::new($false))
            $strOptionalMalformedCandidate = & $scriptblockCommit
            & $scriptblockCheck $strOptionalMalformedCandidate $false $false $false 'exact top-level Status'
        }
        $strOptionalVersionedDocument = $strMetadataDocument.Replace('DATE', $strCurrentDate).Replace(
            "# Finalization fixture`n", "# Finalization fixture`n`n**Version:** 1.0.$($strCurrentDate.Replace('-', '')).0`n")
        [IO.File]::WriteAllText($strOptionalReadmePath, $strOptionalVersionedDocument, [Text.UTF8Encoding]::new($false))
        $strOptionalVersionCandidate = & $scriptblockCommit
        & $scriptblockCheck $strOptionalVersionCandidate $true $false $true 'Author finalization UTC date checked'
        # A malformed prior opt-in is data to reject, not new coverage to erase.
        [IO.File]::WriteAllText($strOptionalReadmePath,
            $strMetadataDocument.Replace('DATE', $strPriorDate).Replace('Status:** Active', 'Status:** Broken'),
            [Text.UTF8Encoding]::new($false))
        $strBaseline = & $scriptblockCommit
        [IO.File]::WriteAllText($strOptionalReadmePath,
            $strMetadataDocument.Replace('DATE', $strCurrentDate), [Text.UTF8Encoding]::new($false))
        $strOptionalParentCandidate = & $scriptblockCommit
        & $scriptblockCheck $strOptionalParentCandidate $false $false $false 'parent of README.md .*Status'
        # Full optional-header removal is allowed; malformed remnants are not.
        [IO.File]::WriteAllText($strOptionalReadmePath, $strNoHeaderFixture, [Text.UTF8Encoding]::new($false))
        $strOptionalRemovalCandidate = & $scriptblockCommit
        & $scriptblockCheck $strOptionalRemovalCandidate $true $false $true 'Author finalization UTC date checked'
        $strBaseline = $strBeforeOptionalBaseline
        & git -C $strFixtureRoot -c "core.hooksPath=$strEmptyHooks" checkout --quiet --detach $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Optional metadata fixture baseline restoration failed.' }
        Write-Verbose 'Optional retained Tier2/catalog and invalid-prior caller controls passed.'
        # A generated-to-Tier2 move must gain the same real metadata checks.
        $strGeneratedReadmeManifestPath = [IO.Path]::Combine($strFixtureRoot, '.github', 'document-metadata-classification.json')
        $strOriginalReadmeManifest = [IO.File]::ReadAllText($strGeneratedReadmeManifestPath)
        $objGeneratedReadmeManifest = $strOriginalReadmeManifest | ConvertFrom-Json
        $objGeneratedReadmeManifest.tier2Paths = @($objGeneratedReadmeManifest.tier2Paths | Where-Object { $_ -cne 'README.md' })
        $objGeneratedReadmeManifest.generatedPaths = [string[]]@($objGeneratedReadmeManifest.generatedPaths) + @('README.md')
        [Array]::Sort($objGeneratedReadmeManifest.generatedPaths, [StringComparer]::Ordinal)
        [IO.File]::WriteAllText($strGeneratedReadmeManifestPath,
            ($objGeneratedReadmeManifest | ConvertTo-Json -Depth 5), [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($strOptionalReadmePath,
            $strMetadataDocument.Replace('DATE', $strPriorDate), [Text.UTF8Encoding]::new($false))
        $strBaseline = & $scriptblockCommit
        [IO.File]::WriteAllText($strGeneratedReadmeManifestPath, $strOriginalReadmeManifest, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($strOptionalReadmePath,
            $strMetadataDocument.Replace('DATE', $strCurrentDate), [Text.UTF8Encoding]::new($false))
        $strGeneratedToTier2Candidate = & $scriptblockCommit
        & $scriptblockCheck $strGeneratedToTier2Candidate $true $false $true 'Author finalization UTC date checked'
        [IO.File]::WriteAllText($strGeneratedReadmeManifestPath, $strOriginalReadmeManifest, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($strOptionalReadmePath,
            $strMetadataDocument.Replace('DATE', $strCurrentDate).Replace('Status:** Active', 'Status:** Broken'), [Text.UTF8Encoding]::new($false))
        $strMalformedTier2Candidate = & $scriptblockCommit
        & $scriptblockCheck $strMalformedTier2Candidate $false $false $false 'exact top-level Status'
        [IO.File]::WriteAllText($strOptionalReadmePath,
            $strMetadataDocument.Replace('DATE', $strPriorDate).Replace('Status:** Active', 'Status:** Broken'), [Text.UTF8Encoding]::new($false))
        $strBaseline = & $scriptblockCommit
        [IO.File]::WriteAllText($strGeneratedReadmeManifestPath, $strOriginalReadmeManifest, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($strOptionalReadmePath,
            $strMetadataDocument.Replace('DATE', $strCurrentDate), [Text.UTF8Encoding]::new($false))
        $strInvalidGeneratedParentCandidate = & $scriptblockCommit
        & $scriptblockCheck $strInvalidGeneratedParentCandidate $false $false $false 'parent of README.md .*Status'
        $strBaseline = $strBeforeOptionalBaseline
        & git -C $strFixtureRoot -c "core.hooksPath=$strEmptyHooks" checkout --quiet --detach $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Generated-to-Tier2 fixture baseline restoration failed.' }
        Write-Verbose 'Generated-to-Tier2 actual content and prior-header controls passed.'
        # Version-like labels and mixed suffixes must reach the actual B/H checks.
        $strBeforeCaseBaseline = $strBaseline
        $strCaseReadmePath = [IO.Path]::Combine($strFixtureRoot, 'README.md')
        $strCaseRunbookPath = [IO.Path]::Combine($strFixtureRoot, 'docs', 'RUNBOOK.MD')
        $strCaseMetadata = $strMetadataDocument.Replace('DATE', $strCurrentDate)
        $strInvalidCaseVersion = $strCaseMetadata.Replace('## Procedure',
            "**version:** 1.0.20200101.7`n`n## Procedure")
        [IO.File]::WriteAllText($strCaseReadmePath, $strInvalidCaseVersion, [Text.UTF8Encoding]::new($false))
        $strInvalidCaseCandidate = & $scriptblockCommit
        & $scriptblockCheck $strInvalidCaseCandidate $false $false $false 'exact document-level Version'
        [IO.File]::WriteAllText($strCaseReadmePath, $strInvalidCaseVersion, [Text.UTF8Encoding]::new($false))
        $strBaseline = & $scriptblockCommit
        [IO.File]::WriteAllText($strCaseReadmePath, $strCaseMetadata, [Text.UTF8Encoding]::new($false))
        $strPriorCaseCandidate = & $scriptblockCommit
        & $scriptblockCheck $strPriorCaseCandidate $false $false $false '(?s)parent of README[.]md.*Version'
        $strBaseline = $strBeforeCaseBaseline
        & git -C $strFixtureRoot -c "core.hooksPath=$strEmptyHooks" checkout --quiet --detach $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Version-case fixture baseline restoration failed.' }
        [IO.File]::WriteAllText($strCaseRunbookPath, '# Missing metadata', [Text.UTF8Encoding]::new($false))
        $strUpperMissingCandidate = & $scriptblockCommit
        & $scriptblockCheck $strUpperMissingCandidate $false $false $false '(?s)RUNBOOK[.]MD.*metadata'
        [IO.File]::WriteAllText($strCaseRunbookPath, $strCaseMetadata, [Text.UTF8Encoding]::new($false))
        $strUpperValidCandidate = & $scriptblockCommit
        & $scriptblockCheck $strUpperValidCandidate $true $false $true 'Author finalization UTC date checked'
        & git -C $strFixtureRoot -c "core.hooksPath=$strEmptyHooks" checkout --quiet --detach $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Suffix fixture baseline restoration failed.' }
        Write-Verbose 'Version-like header and uppercase Markdown actual caller controls passed.'
        # A peer Metadata section remains operative when its placement is wrong.
        $strBeforeLateMetadataBaseline = $strBaseline
        $strLateMetadata = "`n`n## Metadata`n`n- **Status:** Broken`n- **Owner:** Fixture`n" +
            "- **Last Updated:** 2026-99-99`n- **Scope:** Optional metadata.`n"
        foreach ($strOptionalPath in @('README.md', '.github/copilot-instructions.md')) {
            $strOptionalFullPath = [IO.Path]::Combine($strFixtureRoot, $strOptionalPath)
            [IO.File]::WriteAllText($strOptionalFullPath,
                [IO.File]::ReadAllText($strOptionalFullPath) + $strLateMetadata,
                [Text.UTF8Encoding]::new($false))
            $strLateMetadataHead = & $scriptblockCommit
            & $scriptblockCheck $strLateMetadataHead $false $false $false 'must place one document-level metadata list'
        }
        $strReadmePath = [IO.Path]::Combine($strFixtureRoot, 'README.md')
        [IO.File]::WriteAllText($strReadmePath,
            "# Reader`n`n## Intro`n`nBody.`n" + $strLateMetadata,
            [Text.UTF8Encoding]::new($false))
        $strBaseline = & $scriptblockCommit
        [IO.File]::WriteAllText($strReadmePath,
            $strMetadataDocument.Replace('DATE', $strCurrentDate), [Text.UTF8Encoding]::new($false))
        $strValidAfterLateMetadataHead = & $scriptblockCommit
        & $scriptblockCheck $strValidAfterLateMetadataHead $false $false $false '(?s)parent of README[.]md.*metadata list'
        $strBaseline = $strBeforeLateMetadataBaseline
        & git -C $strFixtureRoot checkout --quiet --detach $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Late metadata baseline restoration failed.' }
        [IO.File]::WriteAllText($strReadmePath,
            "# Reader`n`n## Examples`n`n### Metadata`n`n- **Status:** Broken`n",
            [Text.UTF8Encoding]::new($false))
        $strNestedMetadataExampleHead = & $scriptblockCommit
        & $scriptblockCheck $strNestedMetadataExampleHead $false $false $true 'content contract passed'
        Write-Verbose 'Later peer Metadata current/prior rejection and nested example caller controls passed.'

        # Conflicting reserved fields and raw Unicode paths reach real B/H checks.
        $strBeforeFieldBaseline = $strBaseline
        $strReadmePath = [IO.Path]::Combine($strFixtureRoot, 'README.md')
        $strConflictingMetadata = $strMetadataDocument.Replace('DATE', $strCurrentDate).
            Replace('## Procedure', "- **last updated:** 2026-99-99`n`n## Procedure")
        [IO.File]::WriteAllText($strReadmePath, $strConflictingMetadata, [Text.UTF8Encoding]::new($false))
        $strConflictingHead = & $scriptblockCommit
        & $scriptblockCheck $strConflictingHead $false $false $false 'one exact top-level Last Updated list item'
        [IO.File]::WriteAllText($strReadmePath, $strConflictingMetadata, [Text.UTF8Encoding]::new($false))
        $strBaseline = & $scriptblockCommit
        [IO.File]::WriteAllText($strReadmePath,
            $strMetadataDocument.Replace('DATE', $strCurrentDate), [Text.UTF8Encoding]::new($false))
        $strValidAfterConflictHead = & $scriptblockCommit
        & $scriptblockCheck $strValidAfterConflictHead $false $false $false '(?s)parent of README[.]md.*Last Updated list item'
        $strBaseline = $strBeforeFieldBaseline
        & git -C $strFixtureRoot checkout --quiet --detach $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Conflicting-field baseline restoration failed.' }
        $strUnicodePath = [IO.Path]::Combine($strFixtureRoot, 'docs', ('caf' + [char]0x00e9 + '.md'))
        [IO.File]::WriteAllText($strUnicodePath,
            $strMetadataDocument.Replace('DATE', $strCurrentDate), [Text.UTF8Encoding]::new($false))
        $strValidUnicodeHead = & $scriptblockCommit
        & $scriptblockCheck $strValidUnicodeHead $true $false $true 'content contract passed'
        [IO.File]::WriteAllText($strUnicodePath, '# Procedure without metadata', [Text.UTF8Encoding]::new($false))
        $strInvalidUnicodeHead = & $scriptblockCommit
        & $scriptblockCheck $strInvalidUnicodeHead $false $false $false 'must place one document-level metadata list'
        Write-Verbose 'Reserved field current/prior and Unicode current-document caller controls passed.'

        # Promotion must remain valid on a later no-context rerun.
        $strManifestPath = [IO.Path]::Combine($strFixtureRoot, '.github', 'document-metadata-classification.json')
        $objManifest = [IO.File]::ReadAllText($strManifestPath) | ConvertFrom-Json
        $objManifest.tier2Paths = @($objManifest.tier2Paths | Where-Object { $_ -cne 'README.md' })
        [IO.File]::WriteAllText($strManifestPath, ($objManifest | ConvertTo-Json -Depth 5), [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText([IO.Path]::Combine($strFixtureRoot, 'README.md'),
            $strMetadataDocument.Replace('DATE', $strCurrentDate), [Text.UTF8Encoding]::new($false))
        $strPromotionCandidate = & $scriptblockCommit
        & $scriptblockCheck $strPromotionCandidate $true $false $true 'Author finalization UTC date checked'
        & $scriptblockCheck $strPromotionCandidate $false $true $true 'Finalization date not verified by this invocation'
        # The existing versioned source consumer must receive the require-date flag.
        $strGuidePath = [IO.Path]::Combine($strFixtureRoot, 'STYLE_GUIDE.md')
        $strGuide = [IO.File]::ReadAllText($strGuidePath)
        $strOldVersion = [regex]::Match($strGuide, '(?m)^\*\*Version:\*\* (?<prefix>\d+\.\d+\.)(?<date>\d{8})\.(?<revision>\d+)$')
        if (-not $strOldVersion.Success) { throw 'Versioned fixture source has no exact version.' }
        $strNewGuide = [regex]::Replace($strGuide,
            '(?m)^(?<prefix>\*\*Version:\*\* \d+\.\d+\.)\d{8}\.\d+$',
            '${prefix}' + $strPriorDate.Replace('-', '') + '.0')
        $strNewGuide = [regex]::Replace($strNewGuide, '(?m)^(?<prefix>- \*\*Last Updated:\*\* )\d{4}-\d{2}-\d{2}$', '${prefix}' + $strPriorDate)
        $strNewGuide += "`n<!-- Author-finalization versioned fixture. -->`n"
        # Use rendered prose, not an ignored comment, to exercise the transition.
        $strNewGuide += "`nAuthor finalization fixture procedure applies.`n"
        [IO.File]::WriteAllText($strGuidePath, $strNewGuide, [Text.UTF8Encoding]::new($false))
        $strVersionedEarlierCandidate = & $scriptblockCommit
        & $scriptblockCheck $strVersionedEarlierCandidate $true $false $false 'Last Updated must'
        & $scriptblockCheck $strVersionedEarlierCandidate $false $true $true 'Finalization date not verified by this invocation'
        $strCurrentGuide = [regex]::Replace($strNewGuide,
            '(?m)^(?<prefix>\*\*Version:\*\* \d+\.\d+\.)\d{8}\.\d+$',
            '${prefix}' + $strCurrentDate.Replace('-', '') + '.0')
        $strCurrentGuide = [regex]::Replace($strCurrentGuide,
            '(?m)^- \*\*Last Updated:\*\* \d{4}-\d{2}-\d{2}$', '- **Last Updated:** ' + $strCurrentDate)
        [IO.File]::WriteAllText($strGuidePath, $strCurrentGuide, [Text.UTF8Encoding]::new($false))
        $strVersionedCurrentCandidate = & $scriptblockCommit
        & $scriptblockCheck $strVersionedCurrentCandidate $true $false $true 'Author finalization UTC date checked'
        & git -C $strFixtureRoot checkout --quiet --detach $strBaseline
        # The existing local staged-document path retains strict current UTC.
        foreach ($strLocalDate in @($strPriorDate, $strCurrentDate)) {
            [IO.File]::WriteAllText($strRunbookPath, $strMetadataDocument.Replace('DATE', $strLocalDate), [Text.UTF8Encoding]::new($false))
            & git -C $strFixtureRoot -c core.autocrlf=false add -- docs/finalization-fixture.md
            if ($LASTEXITCODE -ne 0) { throw 'Local finalization fixture staging failed.' }
            & $scriptblockAssertModes
            $strLocalOutput = (& $strHostPath -NoProfile -File $strValidatorPath 2>&1 | Out-String)
            if (($LASTEXITCODE -eq 0) -ne ($strLocalDate -ceq $strCurrentDate)) {
                throw "Local staged creation date regression: $strLocalOutput"
            }
        }
        & git -C $strFixtureRoot restore --staged -- docs/finalization-fixture.md
        if ($LASTEXITCODE -ne 0) { throw 'Local fixture index cleanup failed.' }
        Remove-Item -LiteralPath $strRunbookPath -Force
        foreach ($arrMode in @(@('-FinalizeMetadataNow'), @('-FinalizeMetadataNow', '-SelfTest'),
                @('-FinalizeMetadataNow', '-MetadataClassificationOnly', '-InputRevision', $strCurrentCandidate, '-PublishedBaselineRevision', $strBaseline))) {
            $null = & $strHostPath -NoProfile -File $strValidatorPath @arrMode 2>&1
            if ($LASTEXITCODE -eq 0) { throw 'An invalid finalization mode combination was accepted.' }
        }
        # Mutations execute the same accepted-B caller against the meaningful negative.
        $strRequireDateMutant = $strValidatorContent.Replace(
            '$objDocumentContext.RequireFinalizationDate))', '$false))')
        [IO.File]::WriteAllText($strValidatorPath, $strRequireDateMutant, [Text.UTF8Encoding]::new($false))
        & $scriptblockCheck $strVersionedEarlierCandidate $true $false $true 'Author finalization UTC date checked'
        [IO.File]::WriteAllText($strValidatorPath, $strValidatorContent, [Text.UTF8Encoding]::new($false))
        foreach ($strClockMutation in @(
                $strValidatorContent.Replace('$objDocumentContext.RequireFinalizationDate))',
                    '($objDocumentContext.RequireFinalizationDate -or $objDocumentContext.IsInitialMetadataCoverage)))'),
                $strValidatorContent.Replace('if ($FinalizeMetadataNow) {',
                    'if ($FinalizeMetadataNow -or $boolPublishedEndpointsRequested) {').Replace(
                    'RequireFinalizationDate = ($objParentContext.IsWorktreeTransition -or $FinalizeMetadataNow)',
                    'RequireFinalizationDate = ($objParentContext.IsWorktreeTransition -or $FinalizeMetadataNow -or $boolPublishedEndpointsRequested)'))) {
            [IO.File]::WriteAllText($strValidatorPath, $strClockMutation, [Text.UTF8Encoding]::new($false))
            $boolDelayedMutationRejected = $false
            try {
                & $scriptblockCheck $strPromotionCandidate $false $true $true 'Finalization date not verified by this invocation'
            } catch {
                if ($_.Exception.Message -notmatch 'Last Updated must') { throw }
                $boolDelayedMutationRejected = $true
            }
            if (-not $boolDelayedMutationRejected) { throw 'A delayed-clock regression mutation escaped its caller test.' }
            [IO.File]::WriteAllText($strValidatorPath, $strValidatorContent, [Text.UTF8Encoding]::new($false))
        }
        $strStatusMutant = $strValidatorContent.Replace('Finalization date not verified by this invocation',
            'No explicit date status')
        [IO.File]::WriteAllText($strValidatorPath, $strStatusMutant, [Text.UTF8Encoding]::new($false))
        $boolStatusMutationRejected = $false
        try {
            & $scriptblockCheck $strCurrentCandidate $false $true $true 'Finalization date not verified by this invocation'
        } catch {
            if ($_.Exception.Message -notmatch '(?s)exit=0.*No explicit date status') { throw }
            $boolStatusMutationRejected = $true
        }
        if (-not $boolStatusMutationRejected) { throw 'The missing limited-status mutation escaped its caller test.' }
        [IO.File]::WriteAllText($strValidatorPath, $strValidatorContent, [Text.UTF8Encoding]::new($false))

    } finally {
        foreach ($strCleanupPath in @($strFixtureRoot, $strEmptyHooks)) {
            $strResolvedCleanupPath = [IO.Path]::GetFullPath($strCleanupPath)
            if ($strResolvedCleanupPath.StartsWith($strTempRoot, [StringComparison]::OrdinalIgnoreCase) -and
                $strResolvedCleanupPath -cne $strTempRoot -and [IO.Directory]::Exists($strResolvedCleanupPath)) {
                Remove-Item -LiteralPath $strResolvedCleanupPath -Recurse -Force
            }
        }
    }
}

function Assert-DocumentMetadataPlacementSelfTest {
    # .SYNOPSIS
    # Tests policy placement and optional-Version transitions.
    #
    # .DESCRIPTION
    # Uses actual bounded Markdown parsing and published transition helpers.
    # Checks available exact-checkout documents and their input-size bounds.
    # Historical native-baseline comparisons are separate acceptance evidence.
    #
    # .PARAMETER RepositoryRootPath
    # The trusted repository containing the available exact checkout objects.
    #
    # .PARAMETER MaximumMetadataUtcDate
    # The captured current validation date in yyyy-MM-dd format.
    #
    # .EXAMPLE
    # Assert-DocumentMetadataPlacementSelfTest -RepositoryRootPath $strRoot `
    #     -MaximumMetadataUtcDate '2026-10-02'
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None. Throws when a contract fixture fails.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261002.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)][string] $RepositoryRootPath,
        [Parameter(Mandatory)][string] $MaximumMetadataUtcDate
    )

    $strFields = "- **Status:** Active`n- **Owner:** Maintainers`n- **Last Updated:** $MaximumMetadataUtcDate`n- **Scope:** Procedure.`n"
    $strVersion = '**Version:** 1.0.' + $MaximumMetadataUtcDate.Replace('-', '') + '.0'
    $strDirect = "# Procedure`n`n$strFields"
    $strHeaded = "# Procedure`n`n## Metadata`n`n$strFields"
    $strVersionedDirect = "# Procedure`n`n$strVersion`n`n$strFields"
    $strVersionedHeaded = "# Procedure`n`n$strVersion`n`n## Metadata`n`n$strFields"
    $strFrontMatter = "---`ntitle: Procedure`n---`n"
    foreach ($objPlacementFixture in @(
            [pscustomobject]@{ Name = 'direct list'; Content = $strDirect; Version = $false },
            [pscustomobject]@{ Name = 'headed list'; Content = $strHeaded; Version = $false },
            [pscustomobject]@{ Name = 'required Version direct'; Content = $strVersionedDirect; Version = $true },
            [pscustomobject]@{ Name = 'required Version headed'; Content = $strVersionedHeaded; Version = $true },
            [pscustomobject]@{ Name = 'optional Version direct'; Content = $strVersionedDirect; Version = $false },
            [pscustomobject]@{ Name = 'optional Version headed'; Content = $strVersionedHeaded; Version = $false },
            [pscustomobject]@{ Name = 'no H1 body start'; Content = $strFields; Version = $false },
            [pscustomobject]@{ Name = 'frontmatter title fallback'; Content = $strFrontMatter + $strFields; Version = $false },
            [pscustomobject]@{ Name = 'leading directive fallback'; Content = $strFrontMatter + "<!-- markdownlint-disable MD013 -->`n`n" + $strFields; Version = $false },
            [pscustomobject]@{ Name = 'late H1 fallback'; Content = $strFields + ("`n" * 30) + '# Late title'; Version = $false },
            [pscustomobject]@{ Name = 'H1 body line 30 direct'; Content = $strFrontMatter + ("`n" * 29) + $strDirect; Version = $false },
            [pscustomobject]@{ Name = 'H1 body line 30 headed'; Content = ("`n" * 29) + $strHeaded; Version = $false },
            [pscustomobject]@{ Name = 'H1 body line 30 Version'; Content = ("`n" * 29) + $strVersionedHeaded; Version = $true },
            [pscustomobject]@{ Name = 'later body Version prose'; Content = $strHeaded + "`n## Procedure`n`n**Version:** 2.0.0`n"; Version = $false },
            [pscustomobject]@{ Name = 'late H1 body examples'; Content = $strFields + ("`n" * 30) + "# Late title`n`n$strFields`n`n**Version:** 2.0.0`n"; Version = $false },
            [pscustomobject]@{ Name = 'later body field examples'; Content = $strHeaded + "`n## Body examples`n`n$strFields"; Version = $false },
            [pscustomobject]@{ Name = 'fields beyond line 30'; Content = $strHeaded.Replace($strFields, ("`n" * 40) + $strFields); Version = $false }
        )) {
        $objContext = Get-DocumentMetadataContext -Content $objPlacementFixture.Content `
            -RequiresVersion $objPlacementFixture.Version
        if ($null -ne $objContext.Failure) {
            throw "Valid placement rejected ($($objPlacementFixture.Name)): $($objContext.Failure)"
        }
        if ($objPlacementFixture.Name -like 'optional Version*' -and
            ($objContext.VersionDate -cne $MaximumMetadataUtcDate.Replace('-', '') -or
                $objContext.VersionLineIndex -lt 0)) {
            throw 'Optional Version was accepted but ignored.'
        }
    }
    $strFence = '```'
    foreach ($objInvalidPlacement in @(
            [pscustomobject]@{ Name = 'intervening prose'; Content = $strDirect.Replace($strFields, "Prose.`n`n$strFields"); Failure = 'must place' },
            [pscustomobject]@{ Name = 'intervening prose after Version'; Content = $strVersionedHeaded.Replace('## Metadata', "Prose.`n`n## Metadata"); Failure = 'must place' },
            [pscustomobject]@{ Name = 'earlier H2'; Content = $strHeaded.Replace('## Metadata', "## Earlier`n`n## Metadata"); Failure = 'must place' },
            [pscustomobject]@{ Name = 'duplicate section'; Content = $strHeaded + "`n## Metadata`n`n$strFields"; Failure = 'must place' },
            [pscustomobject]@{ Name = 'duplicate direct blocks'; Content = $strDirect + "`nProse.`n`n$strFields"; Failure = 'one exact top-level Status' },
            [pscustomobject]@{ Name = 'mixed direct and section'; Content = $strDirect + "`n## Metadata`n`n$strFields"; Failure = 'must place' },
            [pscustomobject]@{ Name = 'duplicate field'; Content = $strDirect.Replace('- **Owner:** Maintainers', "- **Owner:** Maintainers`n- **Owner:** Other"); Failure = 'one exact top-level Owner' },
            [pscustomobject]@{ Name = 'nested fields'; Content = "# Procedure`n`n- Wrapper`n" + ($strFields -replace '(?m)^', '  '); Failure = 'one exact top-level Status' },
            [pscustomobject]@{ Name = 'quoted fields'; Content = "# Procedure`n`n" + ($strFields -replace '(?m)^', '> '); Failure = 'must place' },
            [pscustomobject]@{ Name = 'fenced fields'; Content = "# Procedure`n`n$strFence`n$strFields$strFence"; Failure = 'must place' },
            [pscustomobject]@{ Name = 'mixed fake field'; Content = $strDirect.Replace('- **Owner:** Maintainers', '> - **Owner:** Maintainers'); Failure = 'one exact top-level Owner' },
            [pscustomobject]@{ Name = 'invalid status'; Content = $strDirect.Replace('Status:** Active', 'Status:** Unknown'); Failure = 'one exact top-level Status' },
            [pscustomobject]@{ Name = 'unclosed front matter'; Content = "---`ntitle: Procedure`n" + $strDirect; Failure = 'close leading YAML' },
            [pscustomobject]@{ Name = 'Version misplaced within header'; Content = $strDirect + "`n$strVersion`n"; Failure = 'Version paragraph' },
            [pscustomobject]@{ Name = 'malformed optional Version'; Content = $strVersionedDirect.Replace($strVersion, '**Version:** invalid'); Failure = 'Version paragraph' },
            [pscustomobject]@{ Name = 'duplicate optional Version'; Content = $strVersionedDirect.Replace($strVersion, "$strVersion`n`n$strVersion"); Failure = 'Version paragraph' },
            [pscustomobject]@{ Name = 'Version outside early H1'; Content = $strVersion + "`n`n" + $strFields; Failure = 'Version paragraph' },
            [pscustomobject]@{ Name = 'nonleading directive prose'; Content = "Intro.`n`n<!-- markdownlint-disable MD013 -->`n`n$strFields"; Failure = 'must place' }
        )) {
        $objContext = Get-DocumentMetadataContext -Content $objInvalidPlacement.Content -RequiresVersion $false
        if ($null -eq $objContext.Failure -or $objContext.Failure -notmatch $objInvalidPlacement.Failure) {
            throw "Invalid placement not rejected at intended boundary ($($objInvalidPlacement.Name)): $($objContext.Failure)"
        }
    }
    $strPriorDate = [DateTime]::ParseExact($MaximumMetadataUtcDate, 'yyyy-MM-dd',
        [Globalization.CultureInfo]::InvariantCulture).AddDays(-1).ToString('yyyy-MM-dd')
    $strEarlierDate = [DateTime]::ParseExact($strPriorDate, 'yyyy-MM-dd',
        [Globalization.CultureInfo]::InvariantCulture).AddDays(-1).ToString('yyyy-MM-dd')
    $strPriorUnversioned = $strDirect.Replace($MaximumMetadataUtcDate, $strPriorDate)
    $strPriorVersioned = $strVersionedDirect.Replace($MaximumMetadataUtcDate, $strPriorDate).
        Replace($MaximumMetadataUtcDate.Replace('-', ''), $strPriorDate.Replace('-', ''))
    foreach ($objTransitionFixture in @(
            [pscustomobject]@{ Name = 'new optional tuple'; Current = $strVersionedDirect; Parent = $strPriorUnversioned; Failure = '' },
            [pscustomobject]@{ Name = 'same-day new optional tuple'; Current = $strVersionedDirect; Parent = $strDirect; Failure = '' },
            [pscustomobject]@{ Name = 'optional tuple nonzero introduction'; Current = $strVersionedDirect.Replace($strVersion, ($strVersion -replace '\.0$', '.1'));  Parent = $strPriorUnversioned; Failure = 'revision must be exactly 0' },
            [pscustomobject]@{ Name = 'optional date mismatch'; Current = $strVersionedDirect.Replace($strVersion, $strVersion.Replace($MaximumMetadataUtcDate.Replace('-', ''), $strPriorDate.Replace('-', ''))); Parent = $strPriorUnversioned; Failure = 'matching calendar date' },
            [pscustomobject]@{ Name = 'backward introduction'; Current = $strVersionedDirect.Replace($MaximumMetadataUtcDate, $strEarlierDate).Replace($MaximumMetadataUtcDate.Replace('-', ''), $strEarlierDate.Replace('-', '')); Parent = $strPriorUnversioned; Failure = 'must not move backward' },
            [pscustomobject]@{ Name = 'invalid governed parent introduction'; Current = $strVersionedDirect; Parent = '# Invalid parent'; Failure = 'The parent of' },
            [pscustomobject]@{ Name = 'invalid parent calendar introduction'; Current = $strVersionedDirect; Parent = $strPriorUnversioned.Replace($strPriorDate, '2026-99-99'); Failure = 'parent.*calendar date' },
            [pscustomobject]@{ Name = 'old optional tuple new date'; Current = $strVersionedDirect; Parent = $strPriorVersioned; Failure = '' },
            [pscustomobject]@{ Name = 'same tuple rendered change no increment'; Current = $strVersionedDirect + "`nChanged prose.`n"; Parent = $strVersionedDirect; Failure = 'revision must be exactly 1' },
            [pscustomobject]@{ Name = 'same tuple proper increment'; Current = $strVersionedDirect.Replace($strVersion, ($strVersion -replace '\.0$', '.1')) + "`nChanged prose.`n"; Parent = $strVersionedDirect; Failure = '' },
            [pscustomobject]@{ Name = 'optional removal'; Current = $strDirect; Parent = $strPriorVersioned; Failure = '' },
            [pscustomobject]@{ Name = 'optional removal backward date'; Current = $strDirect.Replace($MaximumMetadataUtcDate, $strEarlierDate); Parent = $strPriorVersioned; Failure = 'must not move backward' },
            [pscustomobject]@{ Name = 'invalid optional parent removal'; Current = $strDirect; Parent = $strPriorVersioned.Replace($strPriorDate.Replace('-', ''), '20269999'); Failure = 'parent.*matching calendar date' },
            [pscustomobject]@{ Name = 'invalid optional integer'; Current = $strVersionedDirect.Replace('1.0.', '999999999999999999999999.0.'); Parent = $null; Failure = '64-bit' },
            [pscustomobject]@{ Name = 'invalid optional calendar'; Current = $strVersionedDirect.Replace($MaximumMetadataUtcDate, '2026-02-30').Replace($MaximumMetadataUtcDate.Replace('-', ''), '20260230'); Parent = $null; Failure = 'calendar date' },
            [pscustomobject]@{ Name = 'stale optional new document'; Current = $strPriorVersioned; Parent = $null; Failure = 'Last Updated must be' }
        )) {
        $arrFailures = @(Get-PublishedEndpointLastUpdatedFailure -Name $objTransitionFixture.Name `
                -CurrentContent $objTransitionFixture.Current -BaseContent $objTransitionFixture.Parent `
                -TrustedEventUtcDate $MaximumMetadataUtcDate -RequireCurrentMaximumDateForRenderedChange $true)
        if (($objTransitionFixture.Failure -eq '' -and $arrFailures.Count -ne 0) -or
            ($objTransitionFixture.Failure -ne '' -and -not ($arrFailures -match $objTransitionFixture.Failure))) {
            throw "Optional Version transition failed ($($objTransitionFixture.Name)): $($arrFailures -join '; ')"
        }
    }
    if (-not (@(Get-PublishedEndpointMetadataFailure -Name 'required-removal' `
            -CurrentContent $strDirect -ParentContent $strVersionedDirect -ExpectedUtcDate $MaximumMetadataUtcDate `
            -IsNewDocumentTransition $false) -match 'Version paragraph')) {
        throw 'A required Version could be removed.'
    }
    $strCheckoutRevision = ([string](& git -C $RepositoryRootPath rev-parse --verify 'HEAD^{commit}')).Trim()
    if ($LASTEXITCODE -ne 0 -or $strCheckoutRevision -cnotmatch '^[0-9a-f]{40}$') {
        throw 'The available checkout revision could not be resolved exactly.'
    }
    foreach ($strCheckoutPath in @('.claude/commands/review-loop.md', 'docs/P1-SUPPLY-FREEZE-v1.md', 'docs/dependency-maintenance.md', '.github/instructions/docs.instructions.md')) {
        $strCheckoutContent = Read-GitRevisionText -RepositoryRootPath $RepositoryRootPath `
            -Revision $strCheckoutRevision -RepositoryRelativePath $strCheckoutPath `
            -MaximumBytes 196608 -RequireRegularFile
        $boolOversizedCheckoutRejected = $false
        try {
            $null = Read-GitRevisionText -RepositoryRootPath $RepositoryRootPath `
                -Revision $strCheckoutRevision -RepositoryRelativePath $strCheckoutPath `
                -MaximumBytes 8 -RequireRegularFile
        } catch {
            if ($_.Exception.Message -notmatch 'must not exceed 8 bytes') { throw }
            $boolOversizedCheckoutRejected = $true
        }
        if (-not $boolOversizedCheckoutRejected) { throw 'An oversized governed document passed its input bound.' }
        $arrFailures = @(Get-PublishedEndpointLastUpdatedFailure -Name $strCheckoutPath `
                -CurrentContent $strCheckoutContent -BaseContent $strCheckoutContent -TrustedEventUtcDate '')
        if ($arrFailures.Count -ne 0 -or
            (Test-InitialMetadataCoveragePath -HasTrustedBaselineManifest $false -RepositoryRelativePath $strCheckoutPath)) {
            throw "An available-checkout document failed ordinary comparison: $strCheckoutPath; $($arrFailures -join '; ')"
        }
    }
}

$arrDeclaredOutputTypes = @($MyInvocation.MyCommand.OutputType.Name)
if ($arrDeclaredOutputTypes.Count -ne 1 -or
    $arrDeclaredOutputTypes[0] -cne 'System.Void') {
    throw 'The extracted self-test must declare one void output contract.'
}
$script:strMaximumMetadataUtcDate = $MaximumMetadataUtcDate
function Assert-OptionalMetadataSelfTest {
    # .SYNOPSIS
    # Checks optional header intent and retained metadata transitions.
    #
    # .DESCRIPTION
    # Uses the production parser and metadata helpers. Intent selects strict
    # validation even when fields are malformed; examples remain non-operative.
    #
    # .PARAMETER MaximumMetadataUtcDate
    # The captured latest UTC date used by the validator.
    #
    # .EXAMPLE
    # Assert-OptionalMetadataSelfTest -MaximumMetadataUtcDate $strDate
    #
    # # Runs optional metadata positive and negative controls.
    #
    # .INPUTS
    # None. This function does not accept pipeline input.
    #
    # .OUTPUTS
    # None. Failed controls throw.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261002.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param([Parameter(Mandatory)][string] $MaximumMetadataUtcDate)

    $objDate = [DateTime]::ParseExact($MaximumMetadataUtcDate, 'yyyy-MM-dd',
        [Globalization.CultureInfo]::InvariantCulture)
    $strPriorDate = $objDate.AddDays(-1).ToString('yyyy-MM-dd')
    $strFutureDate = $objDate.AddDays(1).ToString('yyyy-MM-dd')
    $strFields = "- **Status:** Active`n- **Owner:** Fixture`n- **Last Updated:** $MaximumMetadataUtcDate`n- **Scope:** Optional metadata.`n"
    $strDirect = "# Reader`n`n$strFields`n## Content`n`nCurrent text.`n"
    $strVersion = '**Version:** 1.0.' + $MaximumMetadataUtcDate.Replace('-', '') + '.0'
    $strVersioned = $strDirect.Replace("# Reader`n", "# Reader`n`n$strVersion`n")
    $arrIntentCases = @(
        @{ Name = 'direct'; Content = $strDirect; Expected = $true },
        @{ Name = 'headed'; Content = $strDirect.Replace('- **Status:', "## Metadata`n`n- **Status:"); Expected = $true },
        @{ Name = 'optional version'; Content = $strVersioned; Expected = $true },
        @{ Name = 'missing fields'; Content = "# Reader`n`n## Metadata`n"; Expected = $true },
        @{ Name = 'malformed status'; Content = $strDirect.Replace('Status:** Active', 'Status:** Broken'); Expected = $true },
        @{ Name = 'malformed emphasis'; Content = "# Reader`n`n- **Owner** Fixture`n"; Expected = $true },
        @{ Name = 'wrong placement'; Content = $strDirect.Replace("# Reader`n", "# Reader`n`nIntervening prose.`n"); Expected = $true },
        @{ Name = 'direct before early title'; Content = $strFields + "`n# Reader`n`nBody.`n"; Expected = $true },
        @{ Name = 'headed before early title'; Content = "## Metadata`n`n$strFields`n# Reader`n`nBody.`n"; Expected = $true },
        @{ Name = 'malformed section before early title'; Content = "### Metadata`n`n# Reader`n`nBody.`n"; Expected = $true },
        @{ Name = 'quoted before early title'; Content = "> - **Status:** Active`n`n# Reader`n`nBody.`n"; Expected = $false },
        @{ Name = 'Metadata title without fields'; Content = "# Metadata`n`nReader overview.`n"; Expected = $false },
        @{ Name = 'Metadata title with fields'; Content = $strDirect.Replace('# Reader', '# Metadata'); Expected = $true },
        @{ Name = 'late Metadata title without fields'; Content = ("`n" * 31) + '# Metadata'; Expected = $false },
        @{ Name = 'late Metadata title with fallback fields'; Content = $strFields + ("`n" * 31) + '# Metadata'; Expected = $true },
        @{ Name = 'Version title without fields'; Content = "# Version`n`nReader overview.`n"; Expected = $false },
        @{ Name = 'Version title with fields'; Content = $strDirect.Replace('# Reader', '# Version'); Expected = $true },
        @{ Name = 'plain Version paragraph'; Content = "# Reader`n`nVersion: malformed`n"; Expected = $true },
        @{ Name = 'Version paragraph before title'; Content = "$strVersion`n`n# Reader`n"; Expected = $true },
        @{ Name = 'Metadata example after ordinary section'; Content = "# Reader`n`n## Examples`n`n### Metadata`n`n$strFields"; Expected = $false },
        @{ Name = 'later peer Metadata'; Content = "# Reader`n`n## Intro`n`nText.`n`n## Metadata`n`n$strFields"; Expected = $true },
        @{ Name = 'later peer missing fields'; Content = "# Reader`n`n## Intro`n`n## Metadata`n"; Expected = $true },
        @{ Name = 'later peer malformed fields'; Content = "# Reader`n`n## Intro`n`n## Metadata`n`n- **Status:** Broken`n- **Last Updated:** 2026-99-99`n"; Expected = $true },
        @{ Name = 'later peer stale fields'; Content = "# Reader`n`n## Intro`n`n## Metadata`n`n" + $strFields.Replace($MaximumMetadataUtcDate, $strPriorDate); Expected = $true },
        @{ Name = 'later peer after several sections'; Content = "# Reader`n`n## One`n`n### Detail`n`n## Two`n`n## Metadata`n`n$strFields"; Expected = $true },
        @{ Name = 'later peer before early title'; Content = "## Intro`n`n## Metadata`n`n$strFields`n# Reader`n"; Expected = $true },
        @{ Name = 'later peer fallback'; Content = "Overview.`n`n## Intro`n`n## Metadata`n`n$strFields"; Expected = $true },
        @{ Name = 'later peer setext'; Content = "# Reader`n`n## Intro`n`nMetadata`n--------`n`n$strFields"; Expected = $true },
        @{ Name = 'later noncanonical peer'; Content = "# Reader`n`n## Intro`n`n## metadata:`n`n$strFields"; Expected = $true },
        @{ Name = 'later quoted peer'; Content = "# Reader`n`n## Examples`n`n> ## Metadata`n> - **Status:** Broken`n"; Expected = $false },
        @{ Name = 'later fenced peer'; Content = "# Reader`n`n## Examples`n`n~~~~markdown`n## Metadata`n$strFields~~~~`n"; Expected = $false },
        @{ Name = 'later list-nested peer'; Content = "# Reader`n`n## Examples`n`n- Example:`n`n  ## Metadata`n`n  - **Status:** Broken`n"; Expected = $false },
        @{ Name = 'later HTML peer'; Content = "# Reader`n`n## Examples`n`n<div>`n## Metadata`n$strFields</div>`n"; Expected = $false },
        @{ Name = 'frontmatter peer'; Content = "---`n## Metadata`n---`n# Reader`n`nNo header.`n"; Expected = $false },
        @{ Name = 'later Metadata H1'; Content = "# Reader`n`n## Examples`n`n# Metadata`n"; Expected = $false },
        @{ Name = 'no H1 fallback'; Content = $strFields; Expected = $true },
        @{ Name = 'directive fallback'; Content = "<!-- markdownlint-disable MD013 -->`n`n$strFields"; Expected = $true },
        @{ Name = 'late H1 fallback'; Content = $strFields + ("`n" * 31) + '# Late title'; Expected = $true },
        @{ Name = 'no header'; Content = "# Reader`n`nGetting started.`n"; Expected = $false },
        @{ Name = 'generic labels'; Content = "# Reader`n`n- Owner: project team`n- Scope: user examples`n"; Expected = $false },
        @{ Name = 'fenced'; Content = "# Reader`n`n~~~~markdown`n$strFields~~~~`n"; Expected = $false },
        @{ Name = 'quoted'; Content = "# Reader`n`n" + (($strFields.TrimEnd() -split "`n" | ForEach-Object { '> ' + $_ }) -join "`n"); Expected = $false },
        @{ Name = 'front matter'; Content = "---`n$strFields---`n# Reader`n`nNo header.`n"; Expected = $false },
        @{ Name = 'unclosed marked front matter'; Content = "---`n$strFields"; Expected = $true },
        @{ Name = 'example section'; Content = "# Reader`n`n## Example`n`n$strFields"; Expected = $false },
        @{ Name = 'inline code'; Content = '# Reader' + "`n`n- ``**Status:** Active```n"; Expected = $false },
        @{ Name = 'HTML example'; Content = "# Reader`n`n<div>`n$strFields</div>`n"; Expected = $false }
    )
    foreach ($objCase in $arrIntentCases) {
        if ((Test-DocumentMetadataHeaderIntent -Content $objCase.Content) -ne $objCase.Expected) {
            throw "Optional metadata intent failed: $($objCase.Name)"
        }
    }
    foreach ($objCase in @(
            @{ Name = 'initial'; Current = $strDirect; Base = $null; Strict = $true; Pattern = '' },
            @{ Name = 'initial version'; Current = $strVersioned; Base = $null; Strict = $true; Pattern = '' },
            @{ Name = 'initial nonzero revision'; Current = $strVersioned.Replace('.0' + "`n", '.2' + "`n"); Base = $null; Strict = $true; Pattern = 'revision must be exactly 0' },
            @{ Name = 'stale finalization'; Current = $strDirect.Replace($MaximumMetadataUtcDate, $strPriorDate); Base = $null; Strict = $true; Pattern = 'Last Updated must be' },
            @{ Name = 'delayed ordinary'; Current = $strDirect.Replace($MaximumMetadataUtcDate, $strPriorDate); Base = $null; Strict = $false; Pattern = '' },
            @{ Name = 'future'; Current = $strDirect.Replace($MaximumMetadataUtcDate, $strFutureDate); Base = $null; Strict = $false; Pattern = 'later than trusted UTC' },
            @{ Name = 'calendar'; Current = $strDirect.Replace($MaximumMetadataUtcDate, '2026-99-99'); Base = $null; Strict = $false; Pattern = 'real calendar date' },
            @{ Name = 'invalid parent'; Current = $strDirect; Base = $strDirect.Replace('Status:** Active', 'Status:** Broken'); Strict = $false; Pattern = 'parent of .*Status' },
            @{ Name = 'backward'; Current = $strDirect.Replace($MaximumMetadataUtcDate, $strPriorDate); Base = $strDirect; Strict = $false; Pattern = 'must not move backward' },
            @{ Name = 'version introduction'; Current = $strVersioned; Base = $strDirect; Strict = $false; Pattern = '' },
            @{ Name = 'version removal'; Current = $strDirect; Base = $strVersioned; Strict = $false; Pattern = '' },
            @{ Name = 'invalid prior version removal'; Current = $strDirect; Base = $strVersioned.Replace($strVersion, $strVersion.Replace($MaximumMetadataUtcDate.Replace('-', ''), '20269999')); Strict = $false; Pattern = 'matching calendar date' }
        )) {
        $arrFailures = @(Get-PublishedEndpointLastUpdatedFailure -Name 'optional.md' `
                -CurrentContent $objCase.Current -BaseContent $objCase.Base -TrustedEventUtcDate '' `
                -RequireCurrentMaximumDateForRenderedChange $objCase.Strict)
        if (($objCase.Pattern -ceq '' -and $arrFailures.Count -ne 0) -or
            ($objCase.Pattern -cne '' -and -not ($arrFailures -match $objCase.Pattern))) {
            throw "Optional metadata transition failed: $($objCase.Name): $($arrFailures -join '; ')"
        }
    }
    foreach ($strLabel in @('version:', 'VERSION:', 'vErSiOn:', 'Version :', "Version`t:")) {
        $strMalformedVersion = "**${strLabel}** 1.0.20200101.7"
        foreach ($strContent in @(
                $strDirect.Replace("# Reader`n", "# Reader`n`n$strMalformedVersion`n"),
                $strDirect.Replace('## Content', "$strMalformedVersion`n`n## Content"),
                $strVersioned.Replace('## Content', "$strMalformedVersion`n`n## Content"))) {
            foreach ($boolRequiresVersion in @($false, $true)) {
                $objMalformedContext = Get-DocumentMetadataContext -Content $strContent -RequiresVersion $boolRequiresVersion
                if ($objMalformedContext.Failure -notmatch 'one exact document-level Version paragraph') {
                    throw "A noncanonical Version-like header was ignored: $strLabel"
                }
            }
        }
    }
    $strNoncanonicalVersion = '**version:** 1.0.20200101.7'
    foreach ($strContent in @(
            $strDirect.Replace('## Content', "~~~~text`n$strNoncanonicalVersion`n~~~~`n`n## Content"),
            $strDirect.Replace('## Content', "> $strNoncanonicalVersion`n`n## Content"),
            ($strDirect + "`n$strNoncanonicalVersion`n"),
            "---`nversion: 1.0.20200101.7`n---`n$strDirect")) {
        if ((Get-DocumentMetadataContext -Content $strContent -RequiresVersion $false).Failure) {
            throw 'A Version-like example outside operative header paragraphs was promoted.'
        }
    }
    $strInvalidPriorVersion = $strDirect.Replace('## Content', "$strNoncanonicalVersion`n`n## Content")
    if (-not (@(Get-PublishedEndpointLastUpdatedFailure -Name 'optional.md' -CurrentContent $strDirect `
                -BaseContent $strInvalidPriorVersion -TrustedEventUtcDate '') -match 'parent of .*Version')) {
        throw 'A noncanonical prior Version-like header was erased.'
    }
    foreach ($strFieldName in @('Status', 'Owner', 'Last Updated', 'Scope')) {
        foreach ($strLabel in @($strFieldName.ToLowerInvariant(), $strFieldName.ToUpperInvariant(),
                ($strFieldName + ' '), $strFieldName.Replace(' ', '  '))) {
            foreach ($boolRequiresVersion in @($false, $true)) {
                $strBase = if ($boolRequiresVersion) { $strVersioned } else { $strDirect }
                $arrMalformed = @($strBase.Replace('## Content', "- **${strLabel}:** conflicting value`n`n## Content"))
                if ($strLabel -cne $strFieldName) {
                    $arrMalformed += $strBase.Replace("**${strFieldName}:**", "**${strLabel}:**")
                }
                foreach ($strMalformed in $arrMalformed) {
                    $strFailure = (Get-DocumentMetadataContext -Content $strMalformed -RequiresVersion $boolRequiresVersion).Failure
                    if ($strFailure -notmatch ('one exact top-level ' + [regex]::Escape($strFieldName) + ' list item')) {
                        throw "A reserved field variant escaped exact validation: $strLabel"
                    }
                }
            }
        }
    }
    foreach ($strExample in @(
            "~~~~text`n- **status:** Broken`n~~~~`n",
            "> - **status:** Broken`n",
            "- Example:`n  - **status:** Broken`n",
            '- `status: Broken`',
            '- **Related:** Useful reference.',
            '- StatusCode: ordinary extra field.')) {
        if ((Get-DocumentMetadataContext -Content $strDirect.Replace('## Content', "$strExample`n`n## Content") -RequiresVersion $false).Failure) {
            throw 'An excluded example or unrelated metadata label was promoted.'
        }
    }
    if ((Get-DocumentMetadataContext -Content ($strDirect + "`n- **status:** Broken`n") -RequiresVersion $false).Failure) {
        throw 'A later-section field example was promoted.'
    }
    $strInvalidPriorField = $strDirect.Replace('## Content', "- **last updated:** 2026-99-99`n`n## Content")
    if (-not (@(Get-PublishedEndpointLastUpdatedFailure -Name 'optional.md' -CurrentContent $strDirect `
                -BaseContent $strInvalidPriorField -TrustedEventUtcDate '') -match 'parent of .*Last Updated')) {
        throw 'A conflicting noncanonical prior field was erased.'
    }
}

function Assert-GitRevisionTextSelfTest {
    # .SYNOPSIS
    # Checks exact raw Git entry framing and bounded revision content reads.
    #
    # .DESCRIPTION
    # Uses disposable native Git objects and controlled child-process output.
    # Retains exact path, mode, object type, UTF-8 and transport failure checks.
    #
    # .EXAMPLE
    # Assert-GitRevisionTextSelfTest
    #
    # # Throws when a revision reader control fails.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None. Failed controls throw.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Version: 1.0.20261002.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param()

    $strTempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    $strFixtureRoot = [IO.Path]::Combine($strTempRoot, 'agent-git-entry-' + [Guid]::NewGuid().ToString('N'))
    [void][IO.Directory]::CreateDirectory([IO.Path]::Combine($strFixtureRoot, 'docs'))
    $strEmptyHooks = [IO.Path]::Combine($strFixtureRoot, 'empty-hooks')
    [void][IO.Directory]::CreateDirectory($strEmptyHooks)
    $arrNames = @('docs/caf' + [char]0x00e9 + '.md') + @('docs/space name.md', 'docs/[literal].md', 'docs/UPPER.md')
    try {
        & git -C $strFixtureRoot -c "init.templateDir=$strEmptyHooks" init --quiet
        if ($LASTEXITCODE -ne 0) { throw 'Git entry fixture initialization failed.' }
        foreach ($strName in $arrNames) {
            [IO.File]::WriteAllText([IO.Path]::Combine($strFixtureRoot, $strName), "content:$strName", [Text.UTF8Encoding]::new($false))
        }
        [IO.File]::WriteAllBytes([IO.Path]::Combine($strFixtureRoot, 'docs/invalid.md'), [byte[]]@(255))
        [IO.File]::WriteAllText([IO.Path]::Combine($strFixtureRoot, 'docs/executable.md'), 'executable', [Text.UTF8Encoding]::new($false))
        & git -C $strFixtureRoot -c core.autocrlf=false add --all
        if ($LASTEXITCODE -ne 0) { throw 'Git entry fixture indexing failed.' }
        & git -C $strFixtureRoot update-index --chmod=+x -- docs/executable.md
        if ($LASTEXITCODE -ne 0) { throw 'Git entry fixture mode setup failed.' }
        & git -C $strFixtureRoot -c user.name=Fixture -c user.email=fixture@example.invalid `
            -c commit.gpgsign=false -c "core.hooksPath=$strEmptyHooks" commit --quiet --no-gpg-sign --message=fixture
        if ($LASTEXITCODE -ne 0) { throw 'Git entry fixture commit failed.' }
        $strRevision = ([string](& git -C $strFixtureRoot rev-parse HEAD)).Trim()
        $strBlob = ([string](& git -C $strFixtureRoot rev-parse "${strRevision}:docs/UPPER.md")).Trim()
        & git -C $strFixtureRoot update-index --add --cacheinfo "120000,$strBlob,docs/link.md"
        if ($LASTEXITCODE -ne 0) { throw 'Git entry symlink-mode setup failed.' }
        & git -C $strFixtureRoot update-index --add --cacheinfo "160000,$strRevision,docs/submodule"
        if ($LASTEXITCODE -ne 0) { throw 'Git entry gitlink-mode setup failed.' }
        & git -C $strFixtureRoot -c user.name=Fixture -c user.email=fixture@example.invalid `
            -c commit.gpgsign=false -c "core.hooksPath=$strEmptyHooks" commit --quiet --no-gpg-sign --message=modes
        if ($LASTEXITCODE -ne 0) { throw 'Git entry mode fixture commit failed.' }
        $strRevision = ([string](& git -C $strFixtureRoot rev-parse HEAD)).Trim()
        foreach ($strName in $arrNames) {
            $strRead = Read-GitRevisionText -RepositoryRootPath $strFixtureRoot -Revision $strRevision `
                -RepositoryRelativePath $strName -MaximumBytes 4096 -RequireRegularFile
            if ($strRead -cne "content:$strName") { throw "Git entry exact content failed: $strName" }
        }
        foreach ($objCase in @(
                @{ Path = 'docs/missing.md'; Limit = 4096; Revision = $strRevision; Failure = 'not one regular 100644 blob' },
                @{ Path = 'docs/upper.md'; Limit = 4096; Revision = $strRevision; Failure = 'not one regular 100644 blob' },
                @{ Path = 'docs/executable.md'; Limit = 4096; Revision = $strRevision; Failure = 'not one regular 100644 blob' },
                @{ Path = 'docs/link.md'; Limit = 4096; Revision = $strRevision; Failure = 'not one regular 100644 blob' },
                @{ Path = 'docs/submodule'; Limit = 4096; Revision = $strRevision; Failure = 'not one regular 100644 blob' },
                @{ Path = 'docs'; Limit = 4096; Revision = $strRevision; Failure = 'not one regular 100644 blob' },
                @{ Path = 'docs/invalid.md'; Limit = 4096; Revision = $strRevision; Failure = 'UTF-8' },
                @{ Path = 'docs/UPPER.md'; Limit = 1; Revision = $strRevision; Failure = 'must not exceed 1 byte' },
                @{ Path = 'docs/UPPER.md'; Limit = 4096; Revision = ('0' * 40); Failure = 'Could not inspect' }
            )) {
            $boolRejected = $false
            try {
                $null = Read-GitRevisionText -RepositoryRootPath $strFixtureRoot -Revision $objCase.Revision `
                    -RepositoryRelativePath $objCase.Path -MaximumBytes $objCase.Limit -RequireRegularFile
            } catch {
                if ($_.Exception.Message -notmatch $objCase.Failure) { throw }
                $boolRejected = $true
            }
            if (-not $boolRejected) { throw "Git entry negative control was accepted: $($objCase.Path)" }
        }
        $scriptBlockActualProcessReader = ${function:Read-BoundedProcessData}
        $strProbePath = 'docs/probe.md'
        $strRecord = '100644 blob ' + ('a' * 40) + "`t$strProbePath" + [char]0
        $arrRecordCases = @(
            @{ Name = 'exact 40'; Data = $strRecord; Failure = '' },
            @{ Name = 'exact 64'; Data = $strRecord.Replace(('a' * 40), ('a' * 64)); Failure = '' },
            @{ Name = 'empty'; Data = ''; Failure = 'not one regular 100644 blob' },
            @{ Name = 'no NUL'; Data = $strRecord.TrimEnd([char]0); Failure = 'not one regular 100644 blob' },
            @{ Name = 'extra record'; Data = $strRecord + [char]0; Failure = 'not one regular 100644 blob' },
            @{ Name = 'wrong case'; Data = $strRecord.Replace('probe.md', 'PROBE.md'); Failure = 'not one regular 100644 blob' },
            @{ Name = 'wrong mode'; Data = $strRecord.Replace('100644', '100755'); Failure = 'not one regular 100644 blob' },
            @{ Name = 'wrong type'; Data = $strRecord.Replace('blob', 'tree'); Failure = 'not one regular 100644 blob' },
            @{ Name = 'bad object'; Data = $strRecord.Replace(('a' * 40), ('g' * 40)); Failure = 'not one regular 100644 blob' },
            @{ Name = 'invalid UTF8'; Data = ''; Bytes = [byte[]]@(255); Failure = 'UTF-8' },
            @{ Name = 'native failure'; Data = $strRecord; Program = 'exit 42'; Failure = 'Could not inspect' },
            @{ Name = 'overflow'; Data = ('x' * 256); Failure = 'must not exceed|exceeded' },
            @{ Name = 'timeout'; Data = ''; Program = 'Start-Sleep -Seconds 30'; Failure = 'timed out|canceled' }
        )
        foreach ($objRecordCase in $arrRecordCases) {
            & {
                function Read-BoundedProcessData {
                    param($Process, $MaximumBytes, $TimeoutMilliseconds, $DisplayName)
                    $arrArguments = @($Process.StartInfo.ArgumentList)
                    $boolTree = $arrArguments -ccontains 'ls-tree'
                    if ($boolTree -and ($arrArguments[0] -cne '--literal-pathspecs' -or
                            $arrArguments -cnotcontains '-z' -or $arrArguments -cnotcontains '--full-tree' -or
                            $arrArguments[-1] -cne $strProbePath -or $MaximumBytes -ne 91 -or $TimeoutMilliseconds -ne 10000)) {
                        throw 'Git entry bounded invocation contract changed.'
                    }
                    if (-not $boolTree -and ($arrArguments[-1] -cnotmatch '^a{40}(?:a{24})?$')) {
                        throw 'Git content was not bound to the inspected object.'
                    }
                    $arrData = [byte[]]@(if (-not $boolTree) { [Text.Encoding]::UTF8.GetBytes('content') } elseif ($objRecordCase.ContainsKey('Bytes')) {
                        $objRecordCase.Bytes
                    } else { [Text.Encoding]::UTF8.GetBytes($objRecordCase.Data) })
                    $strProgram = if ($boolTree -and $objRecordCase.ContainsKey('Program')) { $objRecordCase.Program } else {
                        '$b=[Convert]::FromBase64String(''' + [Convert]::ToBase64String($arrData) + ''');[Console]::OpenStandardOutput().Write($b,0,$b.Length)'
                    }
                    $Process.StartInfo.FileName = (Get-Process -Id $PID).Path
                    $Process.StartInfo.ArgumentList.Clear()
                    foreach ($strArgument in @('-NoProfile', '-NonInteractive', '-Command', $strProgram)) {
                        $Process.StartInfo.ArgumentList.Add($strArgument)
                    }
                    & $scriptBlockActualProcessReader -Process $Process -MaximumBytes $MaximumBytes `
                        -TimeoutMilliseconds $TimeoutMilliseconds -DisplayName $DisplayName
                }
                $strFailure = ''
                try {
                    $strRead = Read-GitRevisionText -RepositoryRootPath $strFixtureRoot -Revision $strRevision `
                        -RepositoryRelativePath $strProbePath -MaximumBytes 4096 -RequireRegularFile
                    if ($strRead -cne 'content') { throw 'Controlled Git content changed.' }
                } catch { $strFailure = $_.Exception.Message }
                if (($objRecordCase.Failure -ceq '' -and $strFailure -cne '') -or
                    ($objRecordCase.Failure -cne '' -and $strFailure -notmatch $objRecordCase.Failure)) {
                    throw "Git entry transport control failed ($($objRecordCase.Name)): $strFailure"
                }
            }
        }
    } finally {
        $strResolvedFixtureRoot = [IO.Path]::GetFullPath($strFixtureRoot)
        if ($strResolvedFixtureRoot.StartsWith($strTempRoot, [StringComparison]::OrdinalIgnoreCase) -and
            $strResolvedFixtureRoot -cne $strTempRoot -and [IO.Directory]::Exists($strResolvedFixtureRoot)) {
            Remove-Item -LiteralPath $strResolvedFixtureRoot -Recurse -Force
        }
    }
}

Assert-GitRevisionTextSelfTest
Assert-DocumentMetadataClassificationSelfTest -MaximumMetadataUtcDate $MaximumMetadataUtcDate
Assert-OptionalMetadataSelfTest -MaximumMetadataUtcDate $MaximumMetadataUtcDate
Assert-DocumentMetadataPlacementSelfTest -RepositoryRootPath $RepositoryRootPath -MaximumMetadataUtcDate $MaximumMetadataUtcDate
Assert-PublishedMetadataGitFixture -MaximumMetadataUtcDate $MaximumMetadataUtcDate
Assert-ClassificationAdmissionGitFixture -RepositoryRootPath $RepositoryRootPath
Assert-AuthorFinalizationGitFixture -RepositoryRootPath $RepositoryRootPath

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
