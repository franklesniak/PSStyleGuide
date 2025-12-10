#Requires -Version 5.1

<#
.SYNOPSIS
Generates copilot-instructions.md and STYLE_GUIDE_CHAT.md from STYLE_GUIDE.md.

.DESCRIPTION
This script reads STYLE_GUIDE.md and creates two derived files:
- copilot-instructions.md: A direct copy of STYLE_GUIDE.md for use as GitHub Copilot custom instructions
- STYLE_GUIDE_CHAT.md: A chat-ready version with escaped triple backticks wrapped in a markdown code fence

.EXAMPLE
.\Generate-StyleGuideArtifacts.ps1

.NOTES
This script follows the PowerShell style guide conventions defined in this repository.
#>

function New-StyleGuideCopilotVersion {
    <#
    .SYNOPSIS
    Creates copilot-instructions.md as a direct copy of STYLE_GUIDE.md.

    .PARAMETER SourcePath
    Path to the source STYLE_GUIDE.md file.

    .PARAMETER DestinationPath
    Path to the destination copilot-instructions.md file.

    .OUTPUTS
    Returns 0 on success, 1 on failure.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourcePath,

        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )

    try {
        $strContent = Get-Content -Path $SourcePath -Raw -Encoding UTF8
        Set-Content -Path $DestinationPath -Value $strContent -Encoding UTF8 -NoNewline
        Write-Host "Successfully created $DestinationPath"
        return 0
    } catch {
        Write-Error "Failed to create copilot-instructions.md: $_"
        return 1
    }
}


function New-StyleGuideChatVersion {
    <#
    .SYNOPSIS
    Creates STYLE_GUIDE_CHAT.md wrapped in a markdown code fence using proper fence nesting.

    .PARAMETER SourcePath
    Path to the source STYLE_GUIDE.md file.

    .PARAMETER DestinationPath
    Path to the destination STYLE_GUIDE_CHAT.md file.

    .DESCRIPTION
    This function reads STYLE_GUIDE.md, finds the maximum number of consecutive backticks
    in the content, and wraps the entire content in a markdown code fence using one more
    backtick than the maximum found. This follows the CommonMark rule that a fence closes
    only when it encounters the same character with at least as many characters as the opener.

    .OUTPUTS
    Returns 0 on success, 1 on failure.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourcePath,

        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )

    try {
        $strContent = Get-Content -Path $SourcePath -Raw -Encoding UTF8
        
        # Find the maximum number of consecutive backticks in the content
        $strBacktickPattern = '``+'
        $arrMatches = [regex]::Matches($strContent, $strBacktickPattern)
        $intMaxBackticks = 0
        if ($arrMatches.Count -gt 0) {
            $objMeasurement = $arrMatches | Measure-Object -Property Length -Maximum
            $intMaxBackticks = $objMeasurement.Maximum
        }
        
        # Use one more backtick than the maximum found (minimum of 4 for readability)
        $intOuterFenceLength = [Math]::Max(4, $intMaxBackticks + 1)
        $strOuterFence = '`' * $intOuterFenceLength
        
        # Wrap in markdown code fence without escaping
        $strWrappedContent = "$strOuterFence" + "markdown`n$strContent`n$strOuterFence"
        
        Set-Content -Path $DestinationPath -Value $strWrappedContent -Encoding UTF8 -NoNewline
        Write-Host "Successfully created $DestinationPath (using $intOuterFenceLength backticks for outer fence)"
        return 0
    } catch {
        Write-Error "Failed to create STYLE_GUIDE_CHAT.md: $_"
        return 1
    }
}


# Main execution
$strSourceFile = "STYLE_GUIDE.md"
$strCopilotFile = "copilot-instructions.md"
$strChatFile = "STYLE_GUIDE_CHAT.md"

# Verify source file exists
if (-not (Test-Path -Path $strSourceFile)) {
    Write-Error "Source file $strSourceFile not found"
    exit 1
}

# Generate copilot-instructions.md
$intCopilotResult = New-StyleGuideCopilotVersion -SourcePath $strSourceFile -DestinationPath $strCopilotFile
if ($intCopilotResult -ne 0) {
    exit 1
}

# Generate STYLE_GUIDE_CHAT.md
$intChatResult = New-StyleGuideChatVersion -SourcePath $strSourceFile -DestinationPath $strChatFile
if ($intChatResult -ne 0) {
    exit 1
}

Write-Host "All style guide artifacts generated successfully"
exit 0
