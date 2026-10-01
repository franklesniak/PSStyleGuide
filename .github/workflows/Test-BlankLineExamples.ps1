#Requires -Version 7.0

# .SYNOPSIS
# Checks that the blank-line examples communicate distinct, copy-safe behavior.
#
# .DESCRIPTION
# Reads the normative guide section and validates the two examples and their
# warning. Focused mutations prove duplicate examples, whitespace-only lines,
# and unsafe marker guidance are rejected while harmless wording is accepted.
#
# .NOTES
# Version: 1.0.20261001.0

[CmdletBinding(PositionalBinding = $false)]
[OutputType([void])]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-BlankLineExampleContract {
    <#
    .SYNOPSIS
    Reads the semantic contract from the paired blank-line examples.

    .DESCRIPTION
    Locates the non-compliant example by its unique visible-space warning,
    then reads the nearest preceding compliant example. Headings and caption
    wording are not part of the extraction contract.

    .PARAMETER Content
    Complete UTF-8 source text of the normative style guide.

    .EXAMPLE
    $objExamples = Get-BlankLineExampleContract -Content $strGuide
    #
    # # Returns the paired example text and source spans.

    .INPUTS
    None. This function does not accept pipeline input.

    .OUTPUTS
    System.Management.Automation.PSCustomObject. The two example bodies,
    warning text, and their source spans.

    .NOTES
    PRIVATE/INTERNAL HELPER - This function is not part of the public API
    surface. Parameters and behavior may change without notice.
    #
    # Version: 1.0.20261001.0
    #
    # Positional parameters are not supported.
    #>
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([System.Management.Automation.PSCustomObject])]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string] $Content
    )

    $strLabelPattern = '(?im)^\*\*(?<kind>Compliant|Non-Compliant)\b[^\r\n]*'
    $strFencePattern = '(?ms)^```powershell[ \t]*\r?\n(?<code>.*?)^```[ \t]*$'
    $arrCandidatePairs = [System.Collections.Generic.List[object]]::new()
    foreach ($objNonCompliantLabel in [regex]::Matches($Content, $strLabelPattern)) {
        if ($objNonCompliantLabel.Groups['kind'].Value -cne 'Non-Compliant') {
            continue
        }
        $strAfterNonCompliantLabel = $Content.Substring(
            $objNonCompliantLabel.Index + $objNonCompliantLabel.Length
        )
        $objNonCompliantFence = [regex]::Match($strAfterNonCompliantLabel, $strFencePattern)
        if (-not $objNonCompliantFence.Success) { continue }
        $strWarning = $strAfterNonCompliantLabel.Substring(0, $objNonCompliantFence.Index)
        if (-not $strWarning.Contains('␠')) { continue }

        $arrEarlierCompliantLabels = @(
            [regex]::Matches(
                $Content.Substring(0, $objNonCompliantLabel.Index),
                $strLabelPattern
            ) | Where-Object { $_.Groups['kind'].Value -ceq 'Compliant' }
        )
        if ($arrEarlierCompliantLabels.Count -eq 0) { continue }
        $objCompliantLabel = $arrEarlierCompliantLabels[-1]
        $intCompliantTailStart = $objCompliantLabel.Index + $objCompliantLabel.Length
        $strCompliantTail = $Content.Substring(
            $intCompliantTailStart,
            $objNonCompliantLabel.Index - $intCompliantTailStart
        )
        $objCompliantFence = [regex]::Match($strCompliantTail, $strFencePattern)
        if (-not $objCompliantFence.Success) { continue }

        $arrEarlierHeadings = @(
            [regex]::Matches(
                $Content.Substring(0, $objCompliantLabel.Index),
                '(?im)^#{1,6}[ \t]+[^\r\n]+'
            )
        )
        if ($arrEarlierHeadings.Count -eq 0) { continue }
        $objHeading = $arrEarlierHeadings[-1]

        $strCompliantCode = $objCompliantFence.Groups['code'].Value -replace '\r\n?', "`n"
        $strNonCompliantCode = $objNonCompliantFence.Groups['code'].Value -replace '\r\n?', "`n"
        $arrCandidatePairs.Add([pscustomobject]@{
            HeadingIndex = $objHeading.Index
            HeadingLength = $objHeading.Length
            CompliantLabelIndex = $objCompliantLabel.Index
            CompliantLabelLength = $objCompliantLabel.Length
            CompliantCode = $strCompliantCode
            CompliantCodeIndex = $intCompliantTailStart + $objCompliantFence.Groups['code'].Index
            CompliantCodeLength = $objCompliantFence.Groups['code'].Length
            NonCompliantLabelIndex = $objNonCompliantLabel.Index
            NonCompliantLabelLength = $objNonCompliantLabel.Length
            NonCompliantCode = $strNonCompliantCode
            NonCompliantCodeIndex = $objNonCompliantLabel.Index + $objNonCompliantLabel.Length +
                $objNonCompliantFence.Groups['code'].Index
            NonCompliantCodeLength = $objNonCompliantFence.Groups['code'].Length
            Warning = $strWarning
            WarningIndex = $objNonCompliantLabel.Index + $objNonCompliantLabel.Length
            WarningLength = $objNonCompliantFence.Index
        })
    }
    if ($arrCandidatePairs.Count -ne 1) {
        throw 'blank-line examples: the visible-marker example pair is missing or ambiguous.'
    }

    $objPair = $arrCandidatePairs[0]
    if ([string]::Equals($objPair.CompliantCode, $objPair.NonCompliantCode, [StringComparison]::Ordinal)) {
        throw 'blank-line examples: the compliant and non-compliant examples are identical.'
    }
    if ($objPair.Warning -notmatch '(?is)␠.{0,200}(?:marker|illustrat).{0,200}(?:not|is not|isn''t)\s+(?:PowerShell\s+)?syntax' -or
        $objPair.Warning -notmatch '(?i)do not copy|must not copy|not copyable|should not be copied') {
        throw 'blank-line warning: explain that the marker is illustrative, is not PowerShell syntax, and must not be copied.'
    }

    $arrCompliantLines = @($objPair.CompliantCode -split "`n")
    if (@($arrCompliantLines | Where-Object {
        $_.Length -gt 0 -and [string]::IsNullOrWhiteSpace($_)
    }).Count -ne 0) {
        throw 'blank-line examples: the compliant example contains a whitespace-only line.'
    }
    $boolHasTrulyEmptyLine = $false
    for ($intIndex = 1; $intIndex -lt ($arrCompliantLines.Count - 1); $intIndex++) {
        if ($arrCompliantLines[$intIndex].Length -eq 0 -and
            -not [string]::IsNullOrWhiteSpace($arrCompliantLines[$intIndex - 1]) -and
            -not [string]::IsNullOrWhiteSpace($arrCompliantLines[$intIndex + 1])) {
            $boolHasTrulyEmptyLine = $true
            break
        }
    }
    if (-not $boolHasTrulyEmptyLine) {
        throw 'blank-line examples: the compliant example needs a truly empty line between code lines.'
    }

    $arrNonCompliantLines = @($objPair.NonCompliantCode -split "`n")
    if (@($arrNonCompliantLines | Where-Object {
        $_.Length -gt 0 -and [string]::IsNullOrWhiteSpace($_)
    }).Count -ne 0) {
        throw 'blank-line examples: the non-compliant example must use a visible marker, not literal whitespace-only lines.'
    }
    $boolHasVisibleMarker = $false
    for ($intIndex = 1; $intIndex -lt ($arrNonCompliantLines.Count - 1); $intIndex++) {
        if ($arrNonCompliantLines[$intIndex] -match '^␠+$' -and
            -not [string]::IsNullOrWhiteSpace($arrNonCompliantLines[$intIndex - 1]) -and
            -not [string]::IsNullOrWhiteSpace($arrNonCompliantLines[$intIndex + 1])) {
            $boolHasVisibleMarker = $true
            break
        }
    }
    if (-not $boolHasVisibleMarker) {
        throw 'blank-line examples: the non-compliant example needs a visible space marker between code lines.'
    }

    return $objPair
}

function Assert-MutationRejected {
    <#
    .SYNOPSIS
    Confirms a focused semantic mutation is rejected.

    .DESCRIPTION
    Verifies the mutation changed its input and then requires the example
    contract to reject it with the expected semantic failure.

    .PARAMETER OriginalContent
    Unmodified style-guide source text.

    .PARAMETER MutatedContent
    Source text after the focused in-memory mutation.

    .PARAMETER ExpectedFailure
    Stable diagnostic fragment identifying the violated semantic rule.

    .EXAMPLE
    Assert-MutationRejected -OriginalContent $strGuide -MutatedContent $strMutant -ExpectedFailure 'identical'
    #
    # # Fails if the mutation is accepted or was a no-op.

    .INPUTS
    None. This function does not accept pipeline input.

    .OUTPUTS
    System.Void. Throws when the mutation is a no-op or is accepted.

    .NOTES
    PRIVATE/INTERNAL HELPER - This function is not part of the public API
    surface. Parameters and behavior may change without notice.
    #
    # Version: 1.0.20261001.0
    #
    # Positional parameters are not supported.
    #>
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory = $true)][string] $OriginalContent,
        [Parameter(Mandatory = $true)][string] $MutatedContent,
        [Parameter(Mandatory = $true)][string] $ExpectedFailure
    )

    if ([string]::Equals($OriginalContent, $MutatedContent, [StringComparison]::Ordinal)) {
        throw 'blank-line mutation: the fixture mutation did not change its input.'
    }
    try {
        $null = Get-BlankLineExampleContract -Content $MutatedContent
    } catch {
        if ($_.Exception.Message -like ('*{0}*' -f $ExpectedFailure)) { return }
        throw
    }
    throw "blank-line mutation: a mutation expected to fail was accepted ($ExpectedFailure)."
}

$strRepositoryRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..\..'))
$strGuidePath = Join-Path $strRepositoryRoot 'STYLE_GUIDE.md'
$objGuideInfo = [IO.FileInfo]::new($strGuidePath)
if (-not $objGuideInfo.Exists -or $objGuideInfo.Length -gt 262144) {
    throw 'blank-line source: STYLE_GUIDE.md is missing or exceeds the 262144-byte read limit.'
}
$objUtf8Strict = [System.Text.UTF8Encoding]::new($false, $true)
$strGuideContent = [IO.File]::ReadAllText($strGuidePath, $objUtf8Strict)
$objExamples = Get-BlankLineExampleContract -Content $strGuideContent

$strIdenticalMutation = $strGuideContent.Remove(
    $objExamples.NonCompliantCodeIndex,
    $objExamples.NonCompliantCodeLength
).Insert(
    $objExamples.NonCompliantCodeIndex,
    $objExamples.CompliantCode
)
Assert-MutationRejected -OriginalContent $strGuideContent `
    -MutatedContent $strIdenticalMutation -ExpectedFailure 'identical'

$arrCompliantLines = @($objExamples.CompliantCode -split "`n")
$strWhitespaceLineMutationCode = $arrCompliantLines[0] + "`n    `n" +
    ($arrCompliantLines[1..($arrCompliantLines.Count - 1)] -join "`n")
$strWhitespaceLineMutation = $strGuideContent.Remove(
    $objExamples.CompliantCodeIndex,
    $objExamples.CompliantCodeLength
).Insert(
    $objExamples.CompliantCodeIndex,
    $strWhitespaceLineMutationCode
)
Assert-MutationRejected -OriginalContent $strGuideContent `
    -MutatedContent $strWhitespaceLineMutation -ExpectedFailure 'whitespace-only line'

$strNonBreakingSpace = [string][char]0x00A0
$strNonBreakingSpaceMutationCode = $arrCompliantLines[0] + "`n$strNonBreakingSpace`n" +
    ($arrCompliantLines[1..($arrCompliantLines.Count - 1)] -join "`n")
$strNonBreakingSpaceMutation = $strGuideContent.Remove(
    $objExamples.CompliantCodeIndex,
    $objExamples.CompliantCodeLength
).Insert(
    $objExamples.CompliantCodeIndex,
    $strNonBreakingSpaceMutationCode
)
Assert-MutationRejected -OriginalContent $strGuideContent `
    -MutatedContent $strNonBreakingSpaceMutation -ExpectedFailure 'whitespace-only line'

$strUnclearWarning = 'The `␠` marker is shown below.'
$strUnclearWarningMutation = $strGuideContent.Remove(
    $objExamples.WarningIndex,
    $objExamples.WarningLength
).Insert(
    $objExamples.WarningIndex,
    "`n`n$strUnclearWarning`n`n"
)
Assert-MutationRejected -OriginalContent $strGuideContent `
    -MutatedContent $strUnclearWarningMutation -ExpectedFailure 'blank-line warning'

$strUnsafeWarning = 'The `␠` glyph is an illustration marker and is not PowerShell syntax. Copy the marker.'
$strUnsafeWarningMutation = $strGuideContent.Remove(
    $objExamples.WarningIndex,
    $objExamples.WarningLength
).Insert(
    $objExamples.WarningIndex,
    "`n`n$strUnsafeWarning`n`n"
)
Assert-MutationRejected -OriginalContent $strGuideContent `
    -MutatedContent $strUnsafeWarningMutation -ExpectedFailure 'blank-line warning'

$strHarmlessWarning = 'The `␠` glyph is an illustration marker and is not PowerShell syntax. It is not copyable.'
$strHarmlessCaption = '**Compliant example:**'
$strDoubleMarkerCode = $objExamples.NonCompliantCode.Replace('␠', '␠␠')
$strDoubleMarkerMutation = $strGuideContent.Remove(
    $objExamples.NonCompliantCodeIndex,
    $objExamples.NonCompliantCodeLength
).Insert(
    $objExamples.NonCompliantCodeIndex,
    $strDoubleMarkerCode
)
if ([string]::Equals($strGuideContent, $strDoubleMarkerMutation, [StringComparison]::Ordinal)) {
    throw 'blank-line mutation: the doubled-marker fixture did not change its input.'
}
$null = Get-BlankLineExampleContract -Content $strDoubleMarkerMutation

$strHarmlessHeading = '### Example Group'
$strHarmlessWordingMutation = $strGuideContent.Remove(
    $objExamples.WarningIndex,
    $objExamples.WarningLength
).Insert(
    $objExamples.WarningIndex,
    "`n`n$strHarmlessWarning`n`n"
).Remove(
    $objExamples.CompliantLabelIndex,
    $objExamples.CompliantLabelLength
).Insert(
    $objExamples.CompliantLabelIndex,
    $strHarmlessCaption
).Remove(
    $objExamples.HeadingIndex,
    $objExamples.HeadingLength
).Insert(
    $objExamples.HeadingIndex,
    $strHarmlessHeading
)
if ([string]::Equals($strGuideContent, $strHarmlessWordingMutation, [StringComparison]::Ordinal)) {
    throw 'blank-line mutation: the harmless wording fixture did not change its input.'
}
$null = Get-BlankLineExampleContract -Content $strHarmlessWordingMutation

Write-Output 'Blank-line example semantics passed, including focused mutation checks.'
