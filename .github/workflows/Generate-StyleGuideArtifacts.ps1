#Requires -Version 5.1

<#
.SYNOPSIS
Generates copilot-instructions.md, powershell.instructions.md, STYLE_GUIDE_CHAT.md, and STYLE_GUIDE_FULL.md from STYLE_GUIDE.md (and STYLE_GUIDE_RATIONALE.md).

.DESCRIPTION
This script reads STYLE_GUIDE.md and creates four derived files:
- copilot-instructions.md: A direct copy of STYLE_GUIDE.md for use as GitHub Copilot custom instructions in PowerShell-only repositories
- powershell.instructions.md: A version with YAML frontmatter for GitHub Copilot file-specific instructions in multi-language repositories
- STYLE_GUIDE_CHAT.md: A chat-ready version with escaped triple backticks wrapped in a markdown code fence
- STYLE_GUIDE_FULL.md: A merged version combining STYLE_GUIDE.md with rationale content from STYLE_GUIDE_RATIONALE.md, designed for human consumption

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


function New-StyleGuidePowerShellInstructionsVersion {
    <#
    .SYNOPSIS
    Creates powershell.instructions.md with YAML frontmatter prepended to STYLE_GUIDE.md content.

    .PARAMETER SourcePath
    Path to the source STYLE_GUIDE.md file.

    .PARAMETER DestinationPath
    Path to the destination powershell.instructions.md file.

    .DESCRIPTION
    This function reads STYLE_GUIDE.md and prepends YAML frontmatter for GitHub Copilot
    file-specific instructions. The frontmatter includes applyTo pattern and description.

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
        
        # Define the YAML frontmatter with blank line after closing delimiter
        $strFrontmatter = @"
---
applyTo:  "**/*.ps1"
description: "PowerShell coding standards"
---


"@
        
        # Prepend frontmatter to content
        $strFullContent = $strFrontmatter + $strContent
        
        Set-Content -Path $DestinationPath -Value $strFullContent -Encoding UTF8 -NoNewline
        Write-Host "Successfully created $DestinationPath"
        return 0
    } catch {
        Write-Error "Failed to create powershell.instructions.md: $_"
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
        
        # Trim trailing blank line from content before adding closing fence
        # This ensures the closing fence appears immediately after the last line of content
        $strContent = $strContent -replace '\r?\n$', ''
        
        # Find the maximum number of consecutive backticks in the content
        # The pattern '``+' matches one or more backticks (escaped as `` in PowerShell strings)
        $strBacktickPattern = '``+'
        $arrMatches = [regex]::Matches($strContent, $strBacktickPattern)
        $intMaxBackticks = 0
        if ($arrMatches.Count -gt 0) {
            $objMeasurement = $arrMatches | Measure-Object -Property Length -Maximum
            $intMaxBackticks = $objMeasurement.Maximum
        }
        
        # Use one more backtick than the maximum found to ensure the outer fence is longer
        # than any inner fence (per CommonMark spec). Minimum of 4 for readability and to
        # ensure proper nesting even if the content only has single or double backticks.
        $intOuterFenceLength = [Math]::Max(4, $intMaxBackticks + 1)
        $strOuterFence = '`' * $intOuterFenceLength
        
        # Wrap in markdown code fence with a heading and proper trailing newline
        # Add a top-level heading to satisfy MD041 (first-line-heading)
        # Add trailing newline after closing fence to satisfy MD047 (single-trailing-newline)
        $strWrappedContent = "# PowerShell Writing Style Guide - Formatted for Copy-Paste Into LLM Chat`n`n$strOuterFence" + "markdown`n$strContent`n$strOuterFence`n"
        
        Set-Content -Path $DestinationPath -Value $strWrappedContent -Encoding UTF8 -NoNewline
        Write-Host "Successfully created $DestinationPath (using $intOuterFenceLength backticks for outer fence)"
        return 0
    } catch {
        Write-Error "Failed to create STYLE_GUIDE_CHAT.md: $_"
        return 1
    }
}


function New-StyleGuideFullVersion {
    <#
    .SYNOPSIS
    Creates STYLE_GUIDE_FULL.md by merging STYLE_GUIDE.md with rationale content from STYLE_GUIDE_RATIONALE.md.

    .PARAMETER SourcePath
    Path to the source STYLE_GUIDE.md file.

    .PARAMETER RationalePath
    Path to the STYLE_GUIDE_RATIONALE.md file.

    .PARAMETER DestinationPath
    Path to the destination STYLE_GUIDE_FULL.md file.

    .DESCRIPTION
    This function reads both STYLE_GUIDE.md and STYLE_GUIDE_RATIONALE.md, then produces
    a combined document. For each heading in the main guide that has a corresponding
    section in the rationale document (matched by markdown anchor), the rationale content
    is re-inserted beneath that heading. Cross-reference blockquotes pointing back to
    the main guide are removed from the inserted content since the combined document is
    self-contained. Links to STYLE_GUIDE.md sections are converted to internal anchors.

    .OUTPUTS
    Returns 0 on success, 1 on failure.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$SourcePath,

        [Parameter(Mandatory = $true)]
        [string]$RationalePath,

        [Parameter(Mandatory = $true)]
        [string]$DestinationPath
    )

    try {
        $strGuideContent = Get-Content -Path $SourcePath -Raw -Encoding UTF8
        $strRationaleContent = Get-Content -Path $RationalePath -Raw -Encoding UTF8

        # Parse rationale file into sections keyed by markdown anchor.
        # Only ### headings are collected (these are the leaf sections that map to
        # headings in STYLE_GUIDE.md). ## headings in the rationale file are grouping
        # headers (e.g., "## Naming Rationale") that do not exist in the main guide.
        $arrRationaleLines = $strRationaleContent -split '\r?\n'
        $hashtableSections = @{}
        $strCurrentAnchor = $null
        $intCurrentLevel = 0
        $arrCurrentBody = [System.Collections.Generic.List[string]]::new()

        foreach ($strLine in $arrRationaleLines) {
            if ($strLine -match '^(#{2,4}) (.+)$') {
                $intLevel = $Matches[1].Length
                $strHeadingText = $Matches[2]

                # Save previous section if it was a ### heading
                if ($null -ne $strCurrentAnchor -and $intCurrentLevel -eq 3) {
                    $hashtableSections[$strCurrentAnchor] = $arrCurrentBody.ToArray()
                }

                # Compute anchor for this heading
                $strAnchor = $strHeadingText.ToLower() -replace '[^a-z0-9 -]', '' -replace ' ', '-'
                $strAnchor = $strAnchor -replace '-+', '-' -replace '^-|-$', ''

                if ($intLevel -eq 3) {
                    # This is a leaf section — collect its body
                    $strCurrentAnchor = $strAnchor
                    $intCurrentLevel = 3
                    $arrCurrentBody = [System.Collections.Generic.List[string]]::new()
                } elseif ($intLevel -eq 2) {
                    # Grouping header — reset tracking but do not collect
                    $strCurrentAnchor = $null
                    $intCurrentLevel = 2
                } else {
                    # #### sub-heading inside a ### section — include as body content
                    if ($null -ne $strCurrentAnchor -and $intCurrentLevel -eq 3) {
                        $arrCurrentBody.Add($strLine)
                    }
                }
            } elseif ($null -ne $strCurrentAnchor -and $intCurrentLevel -eq 3) {
                $arrCurrentBody.Add($strLine)
            }
        }
        # Save final section if it was a ### heading
        if ($null -ne $strCurrentAnchor -and $intCurrentLevel -eq 3) {
            $hashtableSections[$strCurrentAnchor] = $arrCurrentBody.ToArray()
        }

        # Also handle the ## Executive Summary: Author Profile which is a ## heading
        # but maps to a ## heading in the main guide. Parse it separately.
        $strCurrentAnchor = $null
        $intCurrentLevel = 0
        $arrCurrentBody = [System.Collections.Generic.List[string]]::new()
        $boolInExecutiveSummary = $false

        foreach ($strLine in $arrRationaleLines) {
            if ($strLine -match '^## Executive Summary: Author Profile') {
                $boolInExecutiveSummary = $true
                $arrCurrentBody = [System.Collections.Generic.List[string]]::new()
            } elseif ($boolInExecutiveSummary -and $strLine -match '^## ') {
                # Hit the next ## heading, stop collecting
                $hashtableSections['executive-summary-author-profile'] = $arrCurrentBody.ToArray()
                $boolInExecutiveSummary = $false
            } elseif ($boolInExecutiveSummary) {
                $arrCurrentBody.Add($strLine)
            }
        }
        if ($boolInExecutiveSummary) {
            $hashtableSections['executive-summary-author-profile'] = $arrCurrentBody.ToArray()
        }

        # Clean each section body:
        # - Remove blockquote lines that link back to STYLE_GUIDE.md (cross-refs)
        # - Convert STYLE_GUIDE.md#anchor links to #anchor (internal)
        # - Trim leading and trailing blank lines
        $hashtableCleanSections = @{}
        foreach ($strKey in $hashtableSections.Keys) {
            $arrLines = $hashtableSections[$strKey]

            # Filter out cross-reference blockquotes pointing back to main guide.
            # Only remove "For ... see ... (STYLE_GUIDE.md#..." lines; preserve other
            # blockquotes (e.g., "> **Note:** ...") that happen to link to the main guide.
            $arrFiltered = @($arrLines | Where-Object {
                -not ($_ -match '^> For .+\(STYLE_GUIDE\.md#')
            })

            # Convert relative links to main guide into internal anchors
            $arrConverted = @($arrFiltered | ForEach-Object {
                $_ -replace 'STYLE_GUIDE\.md#', '#' -replace '\[([^\]]+)\]\(STYLE_GUIDE\.md\)', '[$1](#powershell-writing-style)'
            })

            # Trim leading and trailing blank lines and trailing horizontal rules
            $intStart = 0
            while ($intStart -lt $arrConverted.Count -and $arrConverted[$intStart].Trim() -eq '') {
                $intStart++
            }
            $intEnd = $arrConverted.Count - 1
            while ($intEnd -ge 0 -and ($arrConverted[$intEnd].Trim() -eq '' -or $arrConverted[$intEnd].Trim() -eq '---')) {
                $intEnd--
            }
            if ($intStart -le $intEnd) {
                $hashtableCleanSections[$strKey] = $arrConverted[$intStart..$intEnd]
            }
        }

        # Process the guide line by line, inserting rationale content after matching headings.
        # Also remove placeholder lines that mark intentionally blank sections, since the
        # full version will have the actual rationale content re-inserted by the merge.
        $strPlaceholder = '*This section intentionally left blank.*'
        $arrGuideLines = $strGuideContent -split '\r?\n'
        $arrOutputLines = [System.Collections.Generic.List[string]]::new()

        for ($intIndex = 0; $intIndex -lt $arrGuideLines.Count; $intIndex++) {
            $strLine = $arrGuideLines[$intIndex]

            # Skip placeholder lines — the rationale content replaces them
            if ($strLine.Trim() -eq $strPlaceholder) {
                continue
            }

            $arrOutputLines.Add($strLine)

            if ($strLine -match '^(#{2,3}) (.+)$') {
                $strHeadingText = $Matches[2]
                $strAnchor = $strHeadingText.ToLower() -replace '[^a-z0-9 -]', '' -replace ' ', '-'
                $strAnchor = $strAnchor -replace '-+', '-' -replace '^-|-$', ''

                if ($hashtableCleanSections.ContainsKey($strAnchor)) {
                    $arrRationaleBody = $hashtableCleanSections[$strAnchor]
                    # Add a blank line before the rationale content
                    $arrOutputLines.Add('')
                    foreach ($strRatLine in $arrRationaleBody) {
                        $arrOutputLines.Add($strRatLine)
                    }
                }
            }
        }

        $strOutput = ($arrOutputLines -join "`n")

        # Collapse runs of two or more consecutive blank lines to exactly one blank line.
        # In the joined string, one blank line = \n\n (end of previous line + empty line + 
        # start of next line is actually three \n). Two blank lines = \n\n\n.
        # We want to collapse \n\n\n (2+ blank lines) down to \n\n (1 blank line).
        while ($strOutput -match '\n\n\n') {
            $strOutput = $strOutput -replace '\n\n\n', "`n`n"
        }

        # Ensure single trailing newline
        $strOutput = $strOutput.TrimEnd("`n") + "`n"

        Set-Content -Path $DestinationPath -Value $strOutput -Encoding UTF8 -NoNewline
        Write-Host "Successfully created $DestinationPath"
        return 0
    } catch {
        Write-Error "Failed to create STYLE_GUIDE_FULL.md: $_"
        return 1
    }
}


# Main execution
$strSourceFile = "STYLE_GUIDE.md"
$strRationaleFile = "STYLE_GUIDE_RATIONALE.md"
$strCopilotFile = "copilot-instructions.md"
$strPowerShellInstructionsFile = "powershell.instructions.md"
$strChatFile = "STYLE_GUIDE_CHAT.md"
$strFullFile = "STYLE_GUIDE_FULL.md"

# Verify source files exist
if (-not (Test-Path -Path $strSourceFile)) {
    Write-Error "Source file $strSourceFile not found"
    exit 1
}

# Generate copilot-instructions.md
$intCopilotResult = New-StyleGuideCopilotVersion -SourcePath $strSourceFile -DestinationPath $strCopilotFile
if ($intCopilotResult -ne 0) {
    exit 1
}

# Generate powershell.instructions.md
$intPowerShellInstructionsResult = New-StyleGuidePowerShellInstructionsVersion -SourcePath $strSourceFile -DestinationPath $strPowerShellInstructionsFile
if ($intPowerShellInstructionsResult -ne 0) {
    exit 1
}

# Generate STYLE_GUIDE_CHAT.md
$intChatResult = New-StyleGuideChatVersion -SourcePath $strSourceFile -DestinationPath $strChatFile
if ($intChatResult -ne 0) {
    exit 1
}

# Generate STYLE_GUIDE_FULL.md (only if rationale file exists)
if (Test-Path -Path $strRationaleFile) {
    $intFullResult = New-StyleGuideFullVersion -SourcePath $strSourceFile -RationalePath $strRationaleFile -DestinationPath $strFullFile
    if ($intFullResult -ne 0) {
        exit 1
    }
} else {
    Write-Host "Rationale file $strRationaleFile not found; skipping STYLE_GUIDE_FULL.md generation"
}

Write-Host "All style guide artifacts generated successfully"
exit 0
