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
# Version: 1.2.20260831.0

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
    -IsNewDocumentTransition $false).Count -ne 0) {
    throw 'The extracted higher terminal revision was rejected.'
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
        -EventHeadDistinct 'false' -PushCommitCount '0' `
        -PushDistinctCommitCount '0' -PushCommitEvidenceJson '[]' `
        -OtherRefEvidenceJson $strRootEvidence
    if (@($objZeroContext.IntroducedCommitRevisions).Count -ne 0 -or
        @($objZeroContext.BoundaryRevisions).Count -ne 0 -or
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
    $strOnePayload = ConvertTo-Json -Compress -InputObject `
        ([object[]] @($strOneCommit))
    $objOneContext = Get-CreatedRefBoundaryContext `
        -RepositoryRootPath $strTopologyRoot `
        -DestinationRef 'refs/heads/new-one' `
        -HeadRevision $strOneCommit -EventHeadRevision $strOneCommit `
        -EventHeadDistinct 'true' -PushCommitCount '1' `
        -PushDistinctCommitCount '1' -PushCommitEvidenceJson $strOnePayload `
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
    $strManyPayload = ConvertTo-Json -Compress -InputObject `
        ([object[]] @($strOneCommit, $strTwoCommit))
    $objManyContext = Get-CreatedRefBoundaryContext `
        -RepositoryRootPath $strTopologyRoot `
        -DestinationRef 'refs/heads/new-many' `
        -HeadRevision $strTwoCommit -EventHeadRevision $strTwoCommit `
        -EventHeadDistinct 'true' -PushCommitCount '2' `
        -PushDistinctCommitCount '2' -PushCommitEvidenceJson $strManyPayload `
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
        [string]::Join("`n", $arrManyPaths) -cne "one.txt`ntwo.txt") {
        throw 'The many-introduced created-ref fixture lost changed paths.'
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
    $strMergePayload = ConvertTo-Json -Compress -InputObject `
        ([object[]] @($strMergeCommit))
    $objMergeContext = Get-CreatedRefBoundaryContext `
        -RepositoryRootPath $strTopologyRoot `
        -DestinationRef 'refs/heads/new-merge' `
        -HeadRevision $strMergeCommit -EventHeadRevision $strMergeCommit `
        -EventHeadDistinct 'true' -PushCommitCount '1' `
        -PushDistinctCommitCount '1' -PushCommitEvidenceJson $strMergePayload `
        -OtherRefEvidenceJson $strMergeEvidence
    $arrMergePaths = @(Read-GitPublishedEndpointChangedPath `
            -RepositoryRootPath $strTopologyRoot `
            -BaselineRevision ('0' * 40) -FinalRevision $strMergeCommit `
            -BaselineAbsent $true `
            -NewRefBoundaryRevision $objMergeContext.BoundaryRevisions `
            -NewRefIntroducedCommitRevision `
                $objMergeContext.IntroducedCommitRevisions `
            -MaximumBytes $MaximumBytes)
    if (@($objMergeContext.IntroducedCommitRevisions).Count -ne 1 -or
        @($objMergeContext.BoundaryRevisions).Count -ne 2 -or
        [string]::Join("`n", $arrMergePaths) -cne "left.txt`nright.txt") {
        throw 'The merge created-ref fixture lost a parent boundary.'
    }

    $strRootPayload = ConvertTo-Json -Compress -InputObject `
        ([object[]] @($strRootCommit))
    $objGenuineRootContext = Get-CreatedRefBoundaryContext `
        -RepositoryRootPath $strTopologyRoot `
        -DestinationRef 'refs/heads/new-root' `
        -HeadRevision $strRootCommit -EventHeadRevision $strRootCommit `
        -EventHeadDistinct 'true' -PushCommitCount '1' `
        -PushDistinctCommitCount '1' -PushCommitEvidenceJson $strRootPayload `
        -OtherRefEvidenceJson '[]'
    $arrGenuineRootPaths = @(Read-GitPublishedEndpointChangedPath `
            -RepositoryRootPath $strTopologyRoot `
            -BaselineRevision ('0' * 40) -FinalRevision $strRootCommit `
            -BaselineAbsent $true -NewRefBoundaryRevision @() `
            -NewRefIntroducedCommitRevision `
                $objGenuineRootContext.IntroducedCommitRevisions `
            -MaximumBytes $MaximumBytes)
    if (-not $objGenuineRootContext.IsGenuineRootIntroduction -or
        $arrGenuineRootPaths.Count -ne 1 -or
        $arrGenuineRootPaths[0] -cne 'root.txt') {
        throw 'The genuine-root created-ref fixture did not use the final tree.'
    }

    foreach ($objRejectedFixture in @(
            [pscustomobject]@{
                Name = 'event head mismatch'
                Expected = 'expanded event head'
                Arguments = @{
                    HeadRevision = $strOneCommit
                    EventHeadRevision = $strRootCommit
                    PushCommitCount = '1'
                    PushDistinctCommitCount = '1'
                    PushCommitEvidenceJson = $strOnePayload
                    OtherRefEvidenceJson = $strRootEvidence
                }
            },
            [pscustomobject]@{
                Name = 'truncated payload'
                Expected = 'commit array is truncated'
                Arguments = @{
                    HeadRevision = $strTwoCommit
                    EventHeadRevision = $strTwoCommit
                    PushCommitCount = '2'
                    PushDistinctCommitCount = '2'
                    PushCommitEvidenceJson = $strOnePayload
                    OtherRefEvidenceJson = $strRootEvidence
                }
            },
            [pscustomobject]@{
                Name = 'other-ref drift'
                Expected = 'other-ref object changed'
                Arguments = @{
                    HeadRevision = $strOneCommit
                    EventHeadRevision = $strOneCommit
                    PushCommitCount = '1'
                    PushDistinctCommitCount = '1'
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
                -PushCommitCount $objArguments.PushCommitCount `
                -PushDistinctCommitCount $objArguments.PushDistinctCommitCount `
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
