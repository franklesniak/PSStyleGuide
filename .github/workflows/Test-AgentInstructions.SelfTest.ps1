# .SYNOPSIS
# Runs the extracted published-endpoint metadata self-tests.
#
# .DESCRIPTION
# Validates final-state metadata arithmetic and authenticated endpoint handling
# with functions loaded by Test-AgentInstructions.ps1.
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
# Version: 1.2.20260902.3

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

$arrDeclaredOutputTypes = @($MyInvocation.MyCommand.OutputType.Name)
if ($arrDeclaredOutputTypes.Count -ne 1 -or
    $arrDeclaredOutputTypes[0] -cne 'System.Void') {
    throw 'The extracted self-test must declare one void output contract.'
}
$script:strMaximumMetadataUtcDate = $MaximumMetadataUtcDate

function ConvertTo-CreatedPushCommitEvidenceObject {
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

Assert-PublishedEndpointContext -RepositoryRootPath $RepositoryRootPath `
    -EventName 'push' -PullRequestAction '' `
    -BaselineRevision $Revision -FinalRevision $Revision `
    -BaselineAbsent $false -PullRequestBaseChanged ''
if (@(Read-GitPublishedEndpointChangedPath `
        -RepositoryRootPath $RepositoryRootPath `
        -BaselineRevision $Revision -FinalRevision $Revision `
        -BaselineAbsent $false -MaximumBytes $MaximumBytes).Count -ne 0) {
    throw 'Identical extracted endpoint trees reported changed paths.'
}

$strTempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$strTopologyRoot = [IO.Path]::Combine(
    $strTempRoot,
    'agent-instruction-created-ref-' + [Guid]::NewGuid().ToString('N')
)
[void] [IO.Directory]::CreateDirectory($strTopologyRoot)
try {
    $objUtf8 = [Text.UTF8Encoding]::new($false)
    & git -C $strTopologyRoot init --quiet
    & git -C $strTopologyRoot config user.name 'Created-ref self-test'
    & git -C $strTopologyRoot config user.email 'created-ref@example.invalid'
    [IO.File]::WriteAllText(
        (Join-Path $strTopologyRoot 'root.txt'),
        "root`n",
        $objUtf8
    )
    & git -C $strTopologyRoot add -- root.txt
    & git -C $strTopologyRoot commit --quiet -m root
    $strRootCommit = ([string] (& git -C $strTopologyRoot rev-parse HEAD)).Trim()

    & git -C $strTopologyRoot update-ref `
        refs/remotes/event/created-other-0000 $strRootCommit
    $arrRootEvidence = [object[]] @(
        [pscustomobject]@{
            ref = 'refs/heads/existing'
            object = $strRootCommit
            commit = $strRootCommit
            local_ref = 'refs/remotes/event/created-other-0000'
        }
    )
    $strRootEvidence = ConvertTo-Json -Compress -InputObject $arrRootEvidence
    $objZeroContext = Get-CreatedRefBoundaryContext `
        -RepositoryRootPath $strTopologyRoot `
        -DestinationRef 'refs/heads/new-zero' `
        -HeadRevision $strRootCommit -EventHeadRevision $strRootCommit `
        -EventHeadDistinct 'false' -PushCommitEvidenceJson '[]' `
        -OtherRefEvidenceJson $strRootEvidence
    if (@($objZeroContext.IntroducedCommitRevisions).Count -ne 0 -or
        @($objZeroContext.BoundaryRevisions).Count -ne 0 -or
        (Get-CreatedRefMetadataBaselineRevision `
            -Context $objZeroContext -HeadRevision $strRootCommit) -cne
            $strRootCommit -or
        @(Read-GitPublishedEndpointChangedPath `
            -RepositoryRootPath $strTopologyRoot `
            -BaselineRevision ('0' * 40) -FinalRevision $strRootCommit `
            -BaselineAbsent $true -NewRefBoundaryRevision @() `
            -NewRefIntroducedCommitRevision @() `
            -MaximumBytes $MaximumBytes).Count -ne 0) {
        throw 'The zero-introduced created-ref fixture widened its baseline.'
    }

    [IO.File]::WriteAllText(
        (Join-Path $strTopologyRoot 'one.txt'),
        "one`n",
        $objUtf8
    )
    & git -C $strTopologyRoot add -- one.txt
    & git -C $strTopologyRoot commit --quiet -m one
    $strOneCommit = ([string] (& git -C $strTopologyRoot rev-parse HEAD)).Trim()
    $objOnePayloadCommit = ConvertTo-CreatedPushCommitEvidenceObject `
        -Id $strOneCommit -Distinct $true
    $strOnePayload = ConvertTo-Json -Depth 4 -Compress -InputObject `
        ([object[]] @($objOnePayloadCommit))
    $arrLiveShapeProperties = @($objOnePayloadCommit.PSObject.Properties.Name)
    if ($arrLiveShapeProperties.Count -ne 8 -or
        @(@('id', 'tree_id', 'distinct', 'message', 'timestamp', 'url',
                'author', 'committer') | Where-Object {
                $arrLiveShapeProperties -cnotcontains $_
            }).Count -ne 0 -or
        @(@('added', 'removed', 'modified') | Where-Object {
                $arrLiveShapeProperties -ccontains $_
            }).Count -ne 0) {
        throw 'The Actions-shaped commit fixture has an invalid property inventory.'
    }
    if (@(Read-CreatedPushCommitEvidence `
            -PushCommitEvidenceJson $strOnePayload `
            -EventHeadRevision $strOneCommit `
            -EventHeadDistinct 'true').Count -ne 1) {
        throw 'The Actions-shaped commit fixture was not accepted.'
    }
    foreach ($strTimestampFixture in @(
            '2026-09-01T13:41:43-05:00',
            '2026-09-01T18:41:43Z',
            '2026-09-01T13:41:43'
        )) {
        $strTimestampPayload = ConvertTo-Json -Depth 4 -Compress -InputObject `
            ([object[]] @((ConvertTo-CreatedPushCommitEvidenceObject `
                        -Id $strOneCommit -Distinct $true `
                        -Timestamp $strTimestampFixture)))
        if (@(Read-CreatedPushCommitEvidence `
                -PushCommitEvidenceJson $strTimestampPayload `
                -EventHeadRevision $strOneCommit `
                -EventHeadDistinct 'true').Count -ne 1) {
            throw "The '$strTimestampFixture' timestamp fixture was not accepted."
        }
    }
    $objForwardCompatibleCommit = ConvertFrom-Json -InputObject (
        ConvertTo-Json -Depth 4 -Compress -InputObject $objOnePayloadCommit
    )
    $objForwardCompatibleCommit | Add-Member -NotePropertyName future_field `
        -NotePropertyValue 'bounded and ignored'
    $strForwardCompatiblePayload = ConvertTo-Json -Depth 4 -Compress `
        -InputObject ([object[]] @($objForwardCompatibleCommit))
    if (@(Read-CreatedPushCommitEvidence `
            -PushCommitEvidenceJson $strForwardCompatiblePayload `
            -EventHeadRevision $strOneCommit `
            -EventHeadDistinct 'true').Count -ne 1) {
        throw 'A bounded extra inert commit field was not ignored deliberately.'
    }
    $objOneContext = Get-CreatedRefBoundaryContext `
        -RepositoryRootPath $strTopologyRoot `
        -DestinationRef 'refs/heads/new-one' `
        -HeadRevision $strOneCommit -EventHeadRevision $strOneCommit `
        -EventHeadDistinct 'true' -PushCommitEvidenceJson $strOnePayload `
        -OtherRefEvidenceJson $strRootEvidence
    $arrOnePaths = @(Read-GitPublishedEndpointChangedPath `
            -RepositoryRootPath $strTopologyRoot `
            -BaselineRevision ('0' * 40) -FinalRevision $strOneCommit `
            -BaselineAbsent $true `
            -NewRefBoundaryRevision $objOneContext.BoundaryRevisions `
            -NewRefIntroducedCommitRevision `
                $objOneContext.IntroducedCommitRevisions `
            -MaximumBytes $MaximumBytes)
    if (@($objOneContext.IntroducedCommitRevisions).Count -ne 1 -or
        @($objOneContext.BoundaryRevisions).Count -ne 1 -or
        $objOneContext.BoundaryRevisions[0] -cne $strRootCommit -or
        (Get-CreatedRefMetadataBaselineRevision `
            -Context $objOneContext -HeadRevision $strOneCommit) -cne
            $strRootCommit -or
        $arrOnePaths.Count -ne 1 -or $arrOnePaths[0] -cne 'one.txt') {
        throw 'The one-introduced created-ref fixture found an incorrect boundary.'
    }

    [IO.File]::WriteAllText(
        (Join-Path $strTopologyRoot 'two.txt'),
        "two`n",
        $objUtf8
    )
    & git -C $strTopologyRoot add -- two.txt
    & git -C $strTopologyRoot commit --quiet -m two
    $strTwoCommit = ([string] (& git -C $strTopologyRoot rev-parse HEAD)).Trim()
    $objTwoPayloadCommit = ConvertTo-CreatedPushCommitEvidenceObject `
        -Id $strTwoCommit -Distinct $true
    $strManyPayload = ConvertTo-Json -Depth 4 -Compress -InputObject `
        ([object[]] @($objOnePayloadCommit, $objTwoPayloadCommit))
    $objManyContext = Get-CreatedRefBoundaryContext `
        -RepositoryRootPath $strTopologyRoot `
        -DestinationRef 'refs/heads/new-many' `
        -HeadRevision $strTwoCommit -EventHeadRevision $strTwoCommit `
        -EventHeadDistinct 'true' -PushCommitEvidenceJson $strManyPayload `
        -OtherRefEvidenceJson $strRootEvidence
    $arrManyPaths = @(Read-GitPublishedEndpointChangedPath `
            -RepositoryRootPath $strTopologyRoot `
            -BaselineRevision ('0' * 40) -FinalRevision $strTwoCommit `
            -BaselineAbsent $true `
            -NewRefBoundaryRevision $objManyContext.BoundaryRevisions `
            -NewRefIntroducedCommitRevision `
                $objManyContext.IntroducedCommitRevisions `
            -MaximumBytes $MaximumBytes)
    if (@($objManyContext.IntroducedCommitRevisions).Count -ne 2 -or
        @($objManyContext.BoundaryRevisions).Count -ne 1 -or
        (Get-CreatedRefMetadataBaselineRevision `
            -Context $objManyContext -HeadRevision $strTwoCommit) -cne
            $strRootCommit -or
        [string]::Join("`n", $arrManyPaths) -cne "one.txt`ntwo.txt") {
        throw 'The many-introduced created-ref fixture lost changed paths.'
    }

    $strTransientDecisionDirectory = Join-Path $strTopologyRoot 'docs/decisions'
    [void] [IO.Directory]::CreateDirectory($strTransientDecisionDirectory)
    $strTransientDecisionPath = Join-Path `
        $strTransientDecisionDirectory '0002-temp.md'
    [IO.File]::WriteAllText(
        $strTransientDecisionPath,
        "# Decision 0002: Transient fixture`n",
        $objUtf8
    )
    & git -C $strTopologyRoot add -- docs/decisions/0002-temp.md
    & git -C $strTopologyRoot commit --quiet -m transient-create
    $strTransientCreateCommit = ([string] (
            & git -C $strTopologyRoot rev-parse HEAD
        )).Trim()
    & git -C $strTopologyRoot rm --quiet -- docs/decisions/0002-temp.md
    & git -C $strTopologyRoot commit --quiet -m transient-delete
    $strTransientDeleteCommit = ([string] (
            & git -C $strTopologyRoot rev-parse HEAD
        )).Trim()
    $strTransientPayload = ConvertTo-Json -Depth 4 -Compress -InputObject `
        ([object[]] @(
                $objOnePayloadCommit,
                $objTwoPayloadCommit,
                (ConvertTo-CreatedPushCommitEvidenceObject `
                    -Id $strTransientCreateCommit -Distinct $true),
                (ConvertTo-CreatedPushCommitEvidenceObject `
                    -Id $strTransientDeleteCommit -Distinct $true)
            ))
    $objTransientContext = Get-CreatedRefBoundaryContext `
        -RepositoryRootPath $strTopologyRoot `
        -DestinationRef 'refs/heads/new-transient' `
        -HeadRevision $strTransientDeleteCommit `
        -EventHeadRevision $strTransientDeleteCommit `
        -EventHeadDistinct 'true' `
        -PushCommitEvidenceJson $strTransientPayload `
        -OtherRefEvidenceJson $strRootEvidence
    $arrTransientPaths = @(Read-GitPublishedEndpointChangedPath `
            -RepositoryRootPath $strTopologyRoot `
            -BaselineRevision ('0' * 40) `
            -FinalRevision $strTransientDeleteCommit `
            -BaselineAbsent $true `
            -NewRefBoundaryRevision $objTransientContext.BoundaryRevisions `
            -NewRefIntroducedCommitRevision `
                $objTransientContext.IntroducedCommitRevisions `
            -MaximumBytes $MaximumBytes)
    if (@($objTransientContext.IntroducedCommitRevisions).Count -ne 4 -or
        @($objTransientContext.BoundaryRevisions).Count -ne 1 -or
        (Get-CreatedRefMetadataBaselineRevision `
            -Context $objTransientContext `
            -HeadRevision $strTransientDeleteCommit) -cne $strRootCommit -or
        [string]::Join("`n", $arrTransientPaths) -cne "one.txt`ntwo.txt") {
        throw 'A transient created-ref path escaped the published endpoint diff.'
    }

    & git -C $strTopologyRoot checkout --quiet -b left $strRootCommit
    [IO.File]::WriteAllText(
        (Join-Path $strTopologyRoot 'left.txt'), "left`n", $objUtf8
    )
    & git -C $strTopologyRoot add -- left.txt
    & git -C $strTopologyRoot commit --quiet -m left
    $strLeftCommit = ([string] (& git -C $strTopologyRoot rev-parse HEAD)).Trim()
    & git -C $strTopologyRoot checkout --quiet -b right $strRootCommit
    [IO.File]::WriteAllText(
        (Join-Path $strTopologyRoot 'right.txt'), "right`n", $objUtf8
    )
    & git -C $strTopologyRoot add -- right.txt
    & git -C $strTopologyRoot commit --quiet -m right
    $strRightCommit = ([string] (& git -C $strTopologyRoot rev-parse HEAD)).Trim()
    & git -C $strTopologyRoot checkout --quiet left
    & git -C $strTopologyRoot merge --quiet --no-ff right -m merge
    $strMergeCommit = ([string] (& git -C $strTopologyRoot rev-parse HEAD)).Trim()
    & git -C $strTopologyRoot update-ref `
        refs/remotes/event/created-other-0000 $strLeftCommit
    & git -C $strTopologyRoot update-ref `
        refs/remotes/event/created-other-0001 $strRightCommit
    $arrMergeEvidence = [object[]] @(
        [pscustomobject]@{
            ref = 'refs/heads/left'
            object = $strLeftCommit
            commit = $strLeftCommit
            local_ref = 'refs/remotes/event/created-other-0000'
        },
        [pscustomobject]@{
            ref = 'refs/heads/right'
            object = $strRightCommit
            commit = $strRightCommit
            local_ref = 'refs/remotes/event/created-other-0001'
        }
    )
    $strMergeEvidence = ConvertTo-Json -Compress -InputObject $arrMergeEvidence
    $strMergePayload = ConvertTo-Json -Depth 4 -Compress -InputObject `
        ([object[]] @((ConvertTo-CreatedPushCommitEvidenceObject `
                    -Id $strMergeCommit -Distinct $true)))
    $objMergeContext = Get-CreatedRefBoundaryContext `
        -RepositoryRootPath $strTopologyRoot `
        -DestinationRef 'refs/heads/new-merge' `
        -HeadRevision $strMergeCommit -EventHeadRevision $strMergeCommit `
        -EventHeadDistinct 'true' -PushCommitEvidenceJson $strMergePayload `
        -OtherRefEvidenceJson $strMergeEvidence
    if (@($objMergeContext.IntroducedCommitRevisions).Count -ne 1 -or
        @($objMergeContext.BoundaryRevisions).Count -ne 2) {
        throw 'The merge created-ref fixture lost a graph boundary.'
    }
    try {
        [void] @(Read-GitPublishedEndpointChangedPath `
                -RepositoryRootPath $strTopologyRoot `
                -BaselineRevision ('0' * 40) -FinalRevision $strMergeCommit `
                -BaselineAbsent $true `
                -NewRefBoundaryRevision $objMergeContext.BoundaryRevisions `
                -NewRefIntroducedCommitRevision `
                    $objMergeContext.IntroducedCommitRevisions `
                -MaximumBytes $MaximumBytes)
        throw 'A multi-boundary created-ref path range was accepted.'
    }
    catch {
        if (-not $_.Exception.Message.Contains(
                'must have one boundary',
                [StringComparison]::Ordinal
            )) {
            throw
        }
    }
    try {
        [void] (Get-CreatedRefMetadataBaselineRevision `
                -Context $objMergeContext -HeadRevision $strMergeCommit)
        throw 'An ambiguous multi-boundary metadata baseline was accepted.'
    }
    catch {
        if (-not $_.Exception.Message.Contains(
                'lacks one unambiguous metadata baseline',
                [StringComparison]::Ordinal
            )) {
            throw
        }
    }

    $strRootPayload = ConvertTo-Json -Depth 4 -Compress -InputObject `
        ([object[]] @((ConvertTo-CreatedPushCommitEvidenceObject `
                    -Id $strRootCommit -Distinct $true)))
    $objGenuineRootContext = Get-CreatedRefBoundaryContext `
        -RepositoryRootPath $strTopologyRoot `
        -DestinationRef 'refs/heads/new-root' `
        -HeadRevision $strRootCommit -EventHeadRevision $strRootCommit `
        -EventHeadDistinct 'true' -PushCommitEvidenceJson $strRootPayload `
        -OtherRefEvidenceJson '[]'
    $arrGenuineRootPaths = @(Read-GitPublishedEndpointChangedPath `
            -RepositoryRootPath $strTopologyRoot `
            -BaselineRevision ('0' * 40) -FinalRevision $strRootCommit `
            -BaselineAbsent $true -NewRefBoundaryRevision @() `
            -NewRefIntroducedCommitRevision `
                $objGenuineRootContext.IntroducedCommitRevisions `
            -MaximumBytes $MaximumBytes)
    if (-not $objGenuineRootContext.IsGenuineRootIntroduction -or
        -not [string]::IsNullOrEmpty(
            (Get-CreatedRefMetadataBaselineRevision `
                -Context $objGenuineRootContext -HeadRevision $strRootCommit)
        ) -or
        $arrGenuineRootPaths.Count -ne 1 -or
        $arrGenuineRootPaths[0] -cne 'root.txt') {
        throw 'The genuine-root created-ref fixture did not use the final tree.'
    }

    $strTwoOnlyPayload = ConvertTo-Json -Depth 4 -Compress -InputObject `
        ([object[]] @($objTwoPayloadCommit))
    foreach ($objRejectedFixture in @(
            [pscustomobject]@{
                Name = 'event head mismatch'
                Expected = 'expanded event head'
                Arguments = @{
                    HeadRevision = $strOneCommit
                    EventHeadRevision = $strRootCommit
                    PushCommitEvidenceJson = $strOnePayload
                    OtherRefEvidenceJson = $strRootEvidence
                }
            },
            [pscustomobject]@{
                Name = 'graph mismatch'
                Expected = 'distinct commit set contradicts'
                Arguments = @{
                    HeadRevision = $strTwoCommit
                    EventHeadRevision = $strTwoCommit
                    PushCommitEvidenceJson = $strTwoOnlyPayload
                    OtherRefEvidenceJson = $strRootEvidence
                }
            },
            [pscustomobject]@{
                Name = 'other-ref drift'
                Expected = 'other-ref object changed'
                Arguments = @{
                    HeadRevision = $strOneCommit
                    EventHeadRevision = $strOneCommit
                    PushCommitEvidenceJson = $strOnePayload
                    OtherRefEvidenceJson = $strRootEvidence
                }
            }
        )) {
        if ($objRejectedFixture.Name -ceq 'other-ref drift') {
            & git -C $strTopologyRoot update-ref `
                refs/remotes/event/created-other-0000 $strOneCommit
        }
        else {
            & git -C $strTopologyRoot update-ref `
                refs/remotes/event/created-other-0000 $strRootCommit
        }
        try {
            $objArguments = $objRejectedFixture.Arguments
            $null = Get-CreatedRefBoundaryContext `
                -RepositoryRootPath $strTopologyRoot `
                -DestinationRef 'refs/heads/new-rejected' `
                -HeadRevision $objArguments.HeadRevision `
                -EventHeadRevision $objArguments.EventHeadRevision `
                -EventHeadDistinct 'true' `
                -PushCommitEvidenceJson $objArguments.PushCommitEvidenceJson `
                -OtherRefEvidenceJson $objArguments.OtherRefEvidenceJson
            throw "Rejected created-ref fixture passed: $($objRejectedFixture.Name)"
        }
        catch {
            $strRejectedMessage = $_.Exception.Message
            if ($strRejectedMessage.StartsWith(
                    'Rejected created-ref fixture passed:',
                    [StringComparison]::Ordinal
                )) {
                throw
            }
            if (-not $strRejectedMessage.Contains(
                    $objRejectedFixture.Expected,
                    [StringComparison]::OrdinalIgnoreCase
                )) {
                throw "Created-ref rejection '$($objRejectedFixture.Name)' returned: $strRejectedMessage"
            }
        }
    }

    $objBoundaryCommand = Get-Command Get-CreatedRefBoundaryContext
    if ($objBoundaryCommand.Parameters.ContainsKey('PushCommitCount') -or
        $objBoundaryCommand.Parameters.ContainsKey('PushDistinctCommitCount')) {
        throw 'Created-ref validation still requires undocumented push count fields.'
    }

    $objInvalidIdCommit = ConvertTo-CreatedPushCommitEvidenceObject `
        -Id ('g' * 40) -Distinct $true
    $objNotDistinctHeadCommit = ConvertTo-CreatedPushCommitEvidenceObject `
        -Id $strOneCommit -Distinct $false
    $strMalformedTimestampPayload = $strOnePayload.Replace(
        '"timestamp":""',
        '"timestamp":0'
    )
    $strDuplicatePropertyPayload = $strOnePayload.Replace(
        '"id":"' + $strOneCommit + '"',
        '"id":"' + $strOneCommit + '","id":"' + $strOneCommit + '"'
    )
    $strMissingPropertyPayload = $strOnePayload.Replace(
        '"timestamp":"","url"',
        '"url"'
    )
    $arrEvidenceParserRejections = @(
        [pscustomobject]@{
            Name = 'malformed JSON'
            Json = '{'
            Head = $strOneCommit
            Distinct = 'true'
            Expected = 'malformed'
        },
        [pscustomobject]@{
            Name = 'malformed commit object'
            Json = '[{}]'
            Head = $strOneCommit
            Distinct = 'true'
            Expected = 'invalid object shape'
        },
        [pscustomobject]@{
            Name = 'malformed timestamp token'
            Json = $strMalformedTimestampPayload
            Head = $strOneCommit
            Distinct = 'true'
            Expected = 'invalid identity or scalar'
        },
        [pscustomobject]@{
            Name = 'duplicate raw property'
            Json = $strDuplicatePropertyPayload
            Head = $strOneCommit
            Distinct = 'true'
            Expected = 'duplicate property'
        },
        [pscustomobject]@{
            Name = 'missing required property'
            Json = $strMissingPropertyPayload
            Head = $strOneCommit
            Distinct = 'true'
            Expected = 'invalid object shape'
        },
        [pscustomobject]@{
            Name = 'invalid commit ID'
            Json = ConvertTo-Json -Depth 4 -Compress -InputObject `
                ([object[]] @($objInvalidIdCommit))
            Head = $strOneCommit
            Distinct = 'true'
            Expected = 'invalid identity or scalar'
        },
        [pscustomobject]@{
            Name = 'duplicate commit ID'
            Json = ConvertTo-Json -Depth 4 -Compress -InputObject `
                ([object[]] @($objOnePayloadCommit, $objOnePayloadCommit))
            Head = $strOneCommit
            Distinct = 'true'
            Expected = 'invalid identity or scalar'
        },
        [pscustomobject]@{
            Name = 'head mismatch'
            Json = $strOnePayload
            Head = $strTwoCommit
            Distinct = 'true'
            Expected = 'does not end at the event head'
        },
        [pscustomobject]@{
            Name = 'head distinct mismatch'
            Json = ConvertTo-Json -Depth 4 -Compress -InputObject `
                ([object[]] @($objNotDistinctHeadCommit))
            Head = $strOneCommit
            Distinct = 'true'
            Expected = 'does not end at the event head'
        },
        [pscustomobject]@{
            Name = 'oversized evidence'
            Json = '[' + (' ' * $intPushCommitEvidenceMaximumBytes) + ']'
            Head = $strOneCommit
            Distinct = 'true'
            Expected = 'exceeds'
        }
    )
    foreach ($objParserRejection in $arrEvidenceParserRejections) {
        try {
            $null = @(
                Read-CreatedPushCommitEvidence `
                    -PushCommitEvidenceJson $objParserRejection.Json `
                    -EventHeadRevision $objParserRejection.Head `
                    -EventHeadDistinct $objParserRejection.Distinct
            )
            throw "Rejected evidence parser fixture passed: $($objParserRejection.Name)"
        }
        catch {
            $strRejectedMessage = $_.Exception.Message
            if ($strRejectedMessage.StartsWith(
                    'Rejected evidence parser fixture passed:',
                    [StringComparison]::Ordinal
                )) {
                throw
            }
            if (-not $strRejectedMessage.Contains(
                    $objParserRejection.Expected,
                    [StringComparison]::OrdinalIgnoreCase
                )) {
                throw "Evidence parser rejection '$($objParserRejection.Name)' returned: $strRejectedMessage"
            }
        }
    }

    $arrCapCommitEvidence = [object[]] @(
        for ($intCommitIndex = 1;
            $intCommitIndex -le $intMaximumPayloadCommitCount;
            $intCommitIndex++) {
            ConvertTo-CreatedPushCommitEvidenceObject `
                -Id ('{0:x40}' -f $intCommitIndex) -Distinct $false
        }
    )
    $arrBelowCapCommitEvidence = [object[]] @(
        $arrCapCommitEvidence[0..($intMaximumPayloadCommitCount - 2)]
    )
    $strBelowCapCommitEvidence = ConvertTo-Json -Depth 4 -Compress `
        -InputObject $arrBelowCapCommitEvidence
    $arrBelowCapNormalized = @(
        Read-CreatedPushCommitEvidence `
            -PushCommitEvidenceJson $strBelowCapCommitEvidence `
            -EventHeadRevision $arrBelowCapCommitEvidence[-1].id `
            -EventHeadDistinct 'false'
    )
    if ($arrBelowCapNormalized.Count -ne
        ($intMaximumPayloadCommitCount - 1)) {
        throw 'The 2047-object created-push evidence fixture was not preserved.'
    }
    $strAtCapCommitEvidence = ConvertTo-Json -Depth 4 -Compress `
        -InputObject $arrCapCommitEvidence
    try {
        $null = @(
            Read-CreatedPushCommitEvidence `
                -PushCommitEvidenceJson $strAtCapCommitEvidence `
                -EventHeadRevision $arrCapCommitEvidence[-1].id `
                -EventHeadDistinct 'false'
        )
        throw 'The 2048-object created-push evidence fixture passed.'
    }
    catch {
        if ($_.Exception.Message -ceq
            'The 2048-object created-push evidence fixture passed.') {
            throw
        }
        if (-not $_.Exception.Message.Contains(
                '2048-object truncation cap',
                [StringComparison]::Ordinal
            )) {
            throw "The 2048-object fixture returned: $($_.Exception.Message)"
        }
    }
}
finally {
    if ([IO.Directory]::Exists($strTopologyRoot) -and
        $strTopologyRoot.StartsWith(
            $strTempRoot,
            [StringComparison]::OrdinalIgnoreCase
        )) {
        Remove-Item -LiteralPath $strTopologyRoot -Recurse -Force
    }
}
