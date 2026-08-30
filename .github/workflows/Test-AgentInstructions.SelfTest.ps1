[CmdletBinding(PositionalBinding = $false)]
param(
    [Parameter(Mandatory)]
    [string] $RepositoryRootPath,

    [Parameter(Mandatory)]
    [string] $Revision,

    [Parameter(Mandatory)]
    [ValidateRange(1, 2147483646)]
    [int] $MaximumBytes,

    [Parameter(Mandatory)]
    [ValidatePattern('^\d{4}-\d{2}-\d{2}$')]
    [string] $MaximumMetadataUtcDate
)

$script:strMaximumMetadataUtcDate = $MaximumMetadataUtcDate
$objParentContext = Get-GovernedDocumentParentContext `
    -RepositoryRootPath $RepositoryRootPath `
    -RepositoryRelativePath 'AGENTS.md' `
    -MaximumBytes $MaximumBytes `
    -Revision $Revision
if ($null -eq $objParentContext.ParentRevision) {
    if ($null -ne $objParentContext.ParentContent -or
        $objParentContext.ExpectedUtcDate -cne '' -or
        $objParentContext.IsWorktreeTransition) {
        throw 'The explicit root revision context is invalid.'
    }
}
elseif ($objParentContext.ParentRevision -cne "$Revision`^1" -or
    [string]::IsNullOrEmpty($objParentContext.ParentContent)) {
    throw 'The explicit child revision context is invalid.'
}

$strRootRevision = [string] (
    & git -C $RepositoryRootPath rev-list --max-parents=0 -n 1 $Revision
)
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrEmpty($strRootRevision.Trim())) {
    throw 'Could not resolve a zero-parent revision.'
}
$objRootParentContext = Get-GovernedDocumentParentContext `
    -RepositoryRootPath $RepositoryRootPath `
    -RepositoryRelativePath 'AGENTS.md' `
    -MaximumBytes $MaximumBytes `
    -Revision $strRootRevision.Trim()
if ($null -ne $objRootParentContext.ParentRevision -or
    $null -ne $objRootParentContext.ParentContent -or
    $objRootParentContext.ExpectedUtcDate -cne '' -or
    $objRootParentContext.IsWorktreeTransition) {
    throw 'The zero-parent revision context is invalid.'
}

$strGuidePath = '.github/workflows/scripts-README.md'
$strGuideContent = Get-Content -LiteralPath (
    Join-Path $RepositoryRootPath $strGuidePath
) -Raw
$objGuideMetadata = Get-DocumentMetadataContext `
    -Content $strGuideContent -RequiresVersion $false
if ($null -ne $objGuideMetadata.Failure) {
    throw 'The unversioned date fixture metadata is invalid.'
}
$strRepositoryDate = $objGuideMetadata.UpdatedDate
$strRepositoryDateLine = "- **Last Updated:** $strRepositoryDate"
if ([regex]::Matches(
        $strGuideContent,
        '(?m)^' + [regex]::Escape($strRepositoryDateLine) + '$'
    ).Count -ne 1) {
    throw 'The unversioned date fixture has no unique metadata date.'
}
$strGuideContent = $strGuideContent.Replace(
    $strRepositoryDateLine,
    "- **Last Updated:** $MaximumMetadataUtcDate"
)
$objGuideMetadata = Get-DocumentMetadataContext `
    -Content $strGuideContent -RequiresVersion $false
if ($null -ne $objGuideMetadata.Failure -or
    $objGuideMetadata.UpdatedDate -cne $MaximumMetadataUtcDate) {
    throw 'The synthetic unversioned date fixture is invalid.'
}
$strMaximumDate = $MaximumMetadataUtcDate
$strPreviousDate = ([datetime]::ParseExact(
        $strMaximumDate,
        'yyyy-MM-dd',
        [Globalization.CultureInfo]::InvariantCulture
    )).AddDays(-1).ToString('yyyy-MM-dd')
$strFutureDate = ([datetime]::ParseExact(
        $strMaximumDate,
        'yyyy-MM-dd',
        [Globalization.CultureInfo]::InvariantCulture
    )).AddDays(1).ToString('yyyy-MM-dd')
$strRenderedGuide = $strGuideContent + "`nRepeated same-day change.`n"
if (@(Get-LastUpdatedMetadataFreshnessFailure `
            -Name $strGuidePath -CurrentContent $strRenderedGuide `
            -BaseContent $strGuideContent -TrustedEventUtcDate '' `
            -RequireCurrentMaximumDateForRenderedChange $true).Count -ne 0) {
    throw 'A valid repeated same-day unversioned change was rejected.'
}

$strPreviousGuide = $strGuideContent.Replace(
    "- **Last Updated:** $strMaximumDate",
    "- **Last Updated:** $strPreviousDate"
)
$strFutureGuide = $strGuideContent.Replace(
    "- **Last Updated:** $strMaximumDate",
    "- **Last Updated:** $strFutureDate"
)
$strMissingDateGuide = $strGuideContent.Replace(
    "- **Last Updated:** $strMaximumDate`r`n",
    ''
).Replace(
    "- **Last Updated:** $strMaximumDate`n",
    ''
)
$strHistoricalAdoption = $strPreviousGuide + "`nHistorical adoption.`n"
if (@(Get-LastUpdatedMetadataFreshnessFailure `
            -Name $strGuidePath -CurrentContent $strHistoricalAdoption `
            -BaseContent $null -TrustedEventUtcDate '').Count -ne 0) {
    throw 'A valid parentless historical adoption was rejected.'
}
if (@(Get-LastUpdatedMetadataFreshnessFailure `
            -Name $strGuidePath -CurrentContent $strRenderedGuide `
            -BaseContent $strPreviousGuide -TrustedEventUtcDate '').Count -ne 0) {
    throw 'A valid historical date advance was rejected.'
}
$arrHistoricalStaleFailures = @(Get-LastUpdatedMetadataFreshnessFailure `
        -Name $strGuidePath `
        -CurrentContent ($strPreviousGuide + "`nHistorical stale change.`n") `
        -BaseContent $strPreviousGuide -TrustedEventUtcDate '')
if (-not ($arrHistoricalStaleFailures -match 'must advance from')) {
    throw 'A historical same-date change did not require advancement.'
}
$strEventMatchedAdvance = $strGuideContent +
    "`nHistorical event-matched advancement.`n"
if (@(Get-LastUpdatedMetadataFreshnessFailure `
            -Name $strGuidePath -CurrentContent $strEventMatchedAdvance `
            -BaseContent $strPreviousGuide `
            -TrustedEventUtcDate $strMaximumDate).Count -ne 0) {
    throw 'A valid event-matched historical advancement was rejected.'
}
$arrEventMatchedStaleFailures = @(Get-LastUpdatedMetadataFreshnessFailure `
        -Name $strGuidePath `
        -CurrentContent ($strPreviousGuide + "`nEvent-matched stale change.`n") `
        -BaseContent $strPreviousGuide `
        -TrustedEventUtcDate $strPreviousDate)
if (-not ($arrEventMatchedStaleFailures -match 'must advance from')) {
    throw 'An event-matched historical same-date change did not require advancement.'
}
$arrDateNegativeCases = @(
    [pscustomobject]@{
        Name = 'stale no-event date'
        Current = $strPreviousGuide + "`nStale change.`n"
        Base = $strPreviousGuide
        Event = ''
        Failure = "must be $strMaximumDate"
    },
    [pscustomobject]@{
        Name = 'future date'
        Current = $strFutureGuide
        Base = $strGuideContent
        Event = ''
        Failure = 'later than trusted UTC'
    },
    [pscustomobject]@{
        Name = 'backward date'
        Current = $strPreviousGuide
        Base = $strGuideContent
        Event = ''
        Failure = 'must not move backward'
    },
    [pscustomobject]@{
        Name = 'missing Last Updated'
        Current = $strMissingDateGuide
        Base = $strGuideContent
        Event = ''
        Failure = 'must contain one exact top-level Last Updated list item'
    },
    [pscustomobject]@{
        Name = 'trusted-event mismatch'
        Current = $strRenderedGuide
        Base = $strGuideContent
        Event = $strPreviousDate
        Failure = "must be $strPreviousDate"
    }
)
foreach ($objDateNegativeCase in $arrDateNegativeCases) {
    $strDateFailures = @(Get-LastUpdatedMetadataFreshnessFailure `
            -Name $strGuidePath `
            -CurrentContent $objDateNegativeCase.Current `
            -BaseContent $objDateNegativeCase.Base `
            -TrustedEventUtcDate $objDateNegativeCase.Event `
            -RequireCurrentMaximumDateForRenderedChange $true) -join '; '
    if (-not $strDateFailures.Contains(
            $objDateNegativeCase.Failure,
            [StringComparison]::Ordinal
        )) {
        throw "$($objDateNegativeCase.Name) did not fail closed."
    }
}
