# .SYNOPSIS
# Verifies Codex instruction capacity and Claude/Codex workflow parity.
#
# .DESCRIPTION
# Confirms that AGENTS.md remains below the ordinary Codex fallback limit, that
# the trusted project configuration provides additional headroom, and that the
# shared workflow in CLAUDE.md and AGENTS.md differs only at reviewed,
# platform-specific lines. Optional self-tests prove that shared and adapted
# line mutations fail closed.
#
# .PARAMETER SelfTest
# Runs in-memory negative tests after the repository files pass validation.
#
# .EXAMPLE
# & ./.github/workflows/Test-AgentInstructions.ps1 -SelfTest
#
# # Validates the repository files and runs the mutation self-tests.
#
# .INPUTS
# None. You can't pipe objects to this script.
#
# .OUTPUTS
# [string] One success record for repository validation and, when requested,
# one success record for the mutation self-tests.
#
# .NOTES
# This script does not support positional parameters.
# Version: 1.0.20260818.0

[CmdletBinding(PositionalBinding = $false)]
[OutputType([string])]
param(
    [Parameter()]
    [switch] $SelfTest
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$strWorkflowsDirectoryPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($PSScriptRoot)
$strGitHubDirectoryPath = [System.IO.Path]::GetDirectoryName($strWorkflowsDirectoryPath)
$strRepositoryRootPath = [System.IO.Path]::GetDirectoryName($strGitHubDirectoryPath)
$strAgentsPath = Join-Path -Path $strRepositoryRootPath -ChildPath 'AGENTS.md'
$strClaudePath = Join-Path -Path $strRepositoryRootPath -ChildPath 'CLAUDE.md'
$strCodexConfigPath = Join-Path -Path $strRepositoryRootPath -ChildPath '.codex/config.toml'
$strResolvedAgentsPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($strAgentsPath)
$strResolvedClaudePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($strClaudePath)
$strResolvedCodexConfigPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($strCodexConfigPath)

foreach ($strRequiredPath in @($strResolvedAgentsPath, $strResolvedClaudePath, $strResolvedCodexConfigPath)) {
    if (-not (Test-Path -LiteralPath $strRequiredPath -PathType Leaf)) {
        throw "Required agent-instruction input is missing: $strRequiredPath"
    }
}

$intDefaultMaximumBytes = 32768
$intMinimumConfiguredBytes = 65536
$intMinimumConfiguredReserveBytes = 16384
$intAgentsBytes = (Get-Item -LiteralPath $strResolvedAgentsPath).Length
$strCodexConfig = [System.IO.File]::ReadAllText($strResolvedCodexConfigPath, [System.Text.UTF8Encoding]::new($false))
$arrMaximumMatches = [regex]::Matches(
    $strCodexConfig,
    '(?m)^\s*project_doc_max_bytes\s*=\s*(?<MaximumBytes>\d+)\s*$'
)
if ($arrMaximumMatches.Count -ne 1) {
    throw 'The project Codex configuration must declare project_doc_max_bytes exactly once.'
}
$intConfiguredMaximumBytes = [int64]$arrMaximumMatches[0].Groups['MaximumBytes'].Value
if ($intAgentsBytes -gt $intDefaultMaximumBytes) {
    throw "AGENTS.md is $intAgentsBytes bytes; the ordinary Codex fallback limit is $intDefaultMaximumBytes bytes."
}
if ($intConfiguredMaximumBytes -lt $intMinimumConfiguredBytes) {
    throw "project_doc_max_bytes is $intConfiguredMaximumBytes; at least $intMinimumConfiguredBytes is required."
}
if (($intConfiguredMaximumBytes - $intAgentsBytes) -lt $intMinimumConfiguredReserveBytes) {
    throw "Configured AGENTS.md headroom is less than $intMinimumConfiguredReserveBytes bytes."
}

$strAgentsContent = [System.IO.File]::ReadAllText($strResolvedAgentsPath, [System.Text.UTF8Encoding]::new($false))
$strClaudeContent = [System.IO.File]::ReadAllText($strResolvedClaudePath, [System.Text.UTF8Encoding]::new($false))
$strAgentsContent = $strAgentsContent.Replace("`r`n", "`n").Replace("`r", "`n")
$strClaudeContent = $strClaudeContent.Replace("`r`n", "`n").Replace("`r", "`n")
$listAgentsLines = [System.Collections.Generic.List[string]]::new([string[]]$strAgentsContent.Split("`n"))
$listClaudeLines = [System.Collections.Generic.List[string]]::new([string[]]$strClaudeContent.Split("`n"))

$strExecutionHeading = '## Codex execution model and interfaces'
$strProtectedHeading = '## Protected instruction files'
$intExecutionStart = $listAgentsLines.IndexOf($strExecutionHeading)
$intProtectedStart = $listAgentsLines.IndexOf($strProtectedHeading)
if ($intExecutionStart -lt 0 -or $intProtectedStart -le $intExecutionStart) {
    throw 'The Codex-only execution section could not be isolated.'
}
$listAgentsLines.RemoveRange($intExecutionStart, $intProtectedStart - $intExecutionStart)

$arrAdaptations = @(
    [pscustomobject]@{
        Claude = '# Agent Instructions for Claude Code'
        Agents = '# Agent Instructions for Codex'
        Marker = '<ADAPTATION:TITLE>'
    },
    [pscustomobject]@{
        Claude = '**Version:** 1.0.20260816.1'
        Agents = '**Version:** 1.0.20260818.1'
        Marker = '<ADAPTATION:VERSION>'
    },
    [pscustomobject]@{
        Claude = '- **Last Updated:** 2026-08-16'
        Agents = '- **Last Updated:** 2026-08-18'
        Marker = '<ADAPTATION:LAST-UPDATED>'
    },
    [pscustomobject]@{
        Claude = '- **Scope:** Agent-specific entry point for Claude Code and compatible AI coding agents operating in this repository. It captures the pull-request review-loop workflow the maintainer runs, the per-finding decision process to apply to every code-review comment, the discipline governing when and how work may be deferred, and the requirement that the repository''s own PowerShell follow its published style guide.'
        Agents = '- **Scope:** Repository entry point for Codex root agents and Codex subagents operating in this repository through the local workspace, GitHub connector, GitHub CLI, and web-research interfaces. It captures the pull-request review-loop workflow the maintainer runs, the per-finding decision process to apply to every code-review comment, the discipline governing when and how work may be deferred, and the requirement that the repository''s own PowerShell follow its published style guide.'
        Marker = '<ADAPTATION:SCOPE>'
    },
    [pscustomobject]@{
        Claude = ('PR comments and review comments that begin with `@copilot` are commands addressed to GitHub Copilot''s coding agent, not to Claude Code. Ignore them entirely <EM-DASH> do not process them, reply to them, or treat them as review feedback.').Replace('<EM-DASH>', [string][char]0x2014)
        Agents = ('PR comments and review comments that begin with `@copilot` are commands addressed to GitHub Copilot''s coding agent, not to the local Codex agent. Ignore them entirely <EM-DASH> do not process them, reply to them, or treat them as review feedback. Also ignore an exact `@codex review` trigger as a finding; process the remote Codex review that the trigger produces.').Replace('<EM-DASH>', [string][char]0x2014)
        Marker = '<ADAPTATION:OTHER-AGENT-COMMANDS>'
    },
    [pscustomobject]@{
        Claude = ('**6. Post the evaluation.** For an inline finding, reply on its review thread. For a review-body-only finding, post a PR-level comment that cites its synthetic key, review ID/URL, reviewed commit, and path/line when available. Include the options, rubric, scoring table, selected option, `References` section (when research informed the decision), and either a note that implementation follows or the commit SHA that implements it. End every reply with the Claude Code attribution footer. Before posting, verify the reply actually contains all four artifacts <EM-DASH> **options, rubric, scoring table, and selected option** <EM-DASH> for any finding that survived step 1; a reply missing any of them is incomplete whatever the finding''s outcome, so complete it before posting.').Replace('<EM-DASH>', [string][char]0x2014)
        Agents = ('**6. Post the evaluation.** For an inline finding, reply on its review thread. For a review-body-only finding, post a PR-level comment that cites its synthetic key, review ID/URL, reviewed commit, and path/line when available. Include the options, rubric, scoring table, selected option, `References` section (when research informed the decision), and either a note that implementation follows or the commit SHA that implements it. End every reply with the exact attribution footer `Generated with Codex`. Before posting, verify the reply actually contains all four artifacts <EM-DASH> **options, rubric, scoring table, and selected option** <EM-DASH> for any finding that survived step 1; a reply missing any of them is incomplete whatever the finding''s outcome, so complete it before posting.').Replace('<EM-DASH>', [string][char]0x2014)
        Marker = '<ADAPTATION:ATTRIBUTION>'
    },
    [pscustomobject]@{
        Claude = '- **Copilot:** request it explicitly with `request_copilot_review` (or equivalent).'
        Agents = '- **Copilot:** request it explicitly with the connected GitHub interface or authenticated GitHub API equivalent.'
        Marker = '<ADAPTATION:COPILOT-REQUEST>'
    },
    [pscustomobject]@{
        Claude = ('- **Codex:** request it explicitly every round by posting a pull-request comment whose body is exactly `@codex review`. There is no dedicated review-request tool for Codex the way `request_copilot_review` exists for Copilot, so post the comment with the ordinary issue-comment tool (for example `add_issue_comment` or equivalent). Codex also auto-reviews when a pull request is opened for review or a draft is marked ready, but that auto-trigger is not reliable enough to depend on <EM-DASH> always post the explicit `@codex review` request so a Codex review is actually obtained for the round.').Replace('<EM-DASH>', [string][char]0x2014)
        Agents = '- **Remote Codex reviewer:** request it explicitly every round by posting a pull-request comment whose body is exactly `@codex review`. Treat `chatgpt-codex-connector` as a reviewer separate from the local Codex implementation agent. Do not rely on an automatic review trigger; always post the explicit request and reconcile its exact comment receipt.'
        Marker = '<ADAPTATION:CODEX-REQUEST>'
    },
    [pscustomobject]@{
        Claude = '2. Record detection baselines (the newest existing review-submission ID/time, inline-comment ID/time, and PR-comment ID/time for each bot) and the current PR head SHA, then request the reviews: request Copilot with `request_copilot_review` (or equivalent), and request Codex by posting an `@codex review` pull-request comment. Do not rely on Codex''s auto-trigger to stand in for this explicit request.'
        Agents = '2. Record detection baselines (the newest existing review-submission ID/time, inline-comment ID/time, and PR-comment ID/time for each bot) and the current PR head SHA. Then request Copilot through the connected GitHub interface or authenticated API, and request the remote Codex reviewer by posting an exact `@codex review` pull-request comment. Do not rely on an automatic trigger to stand in for either explicit request.'
        Marker = '<ADAPTATION:ROUND-REQUESTS>'
    }
)

foreach ($objAdaptation in $arrAdaptations) {
    $intClaudeIndex = $listClaudeLines.IndexOf([string]$objAdaptation.Claude)
    $intAgentsIndex = $listAgentsLines.IndexOf([string]$objAdaptation.Agents)
    if ($intClaudeIndex -lt 0 -or $intAgentsIndex -lt 0) {
        throw "A reviewed platform adaptation changed unexpectedly: $($objAdaptation.Marker)"
    }
    if ($listClaudeLines.LastIndexOf([string]$objAdaptation.Claude) -ne $intClaudeIndex -or
        $listAgentsLines.LastIndexOf([string]$objAdaptation.Agents) -ne $intAgentsIndex) {
        throw "A reviewed platform adaptation is not unique: $($objAdaptation.Marker)"
    }
    $listClaudeLines[$intClaudeIndex] = [string]$objAdaptation.Marker
    $listAgentsLines[$intAgentsIndex] = [string]$objAdaptation.Marker
}

$strNormalizedClaude = [string]::Join("`n", $listClaudeLines)
$strNormalizedAgents = [string]::Join("`n", $listAgentsLines)
if ($strNormalizedClaude -cne $strNormalizedAgents) {
    $intMaximumLineCount = [Math]::Max($listClaudeLines.Count, $listAgentsLines.Count)
    $intDifferenceLine = -1
    for ($intLineIndex = 0; $intLineIndex -lt $intMaximumLineCount; $intLineIndex++) {
        $strClaudeLine = if ($intLineIndex -lt $listClaudeLines.Count) { $listClaudeLines[$intLineIndex] } else { '<EOF>' }
        $strAgentsLine = if ($intLineIndex -lt $listAgentsLines.Count) { $listAgentsLines[$intLineIndex] } else { '<EOF>' }
        if ($strClaudeLine -cne $strAgentsLine) {
            $intDifferenceLine = $intLineIndex + 1
            break
        }
    }
    throw "Shared agent instructions diverged at normalized line $intDifferenceLine."
}

"Agent instruction validation passed: agentsBytes=$intAgentsBytes configuredMaximum=$intConfiguredMaximumBytes"

if ($SelfTest) {
    $listSharedMutation = [System.Collections.Generic.List[string]]::new($listAgentsLines)
    $intSharedHeadingIndex = $listSharedMutation.IndexOf('## Deferring work')
    if ($intSharedHeadingIndex -lt 0) {
        throw 'Self-test fixture could not find a shared heading.'
    }
    $listSharedMutation[$intSharedHeadingIndex] = '## Deferred work'
    $strSharedMutation = [string]::Join("`n", $listSharedMutation)
    if ($strSharedMutation -ceq $strNormalizedClaude) {
        throw 'Self-test failed: a shared-line mutation was accepted.'
    }

    $listAdaptationMutation = [System.Collections.Generic.List[string]]::new([string[]]$strAgentsContent.Split("`n"))
    $intAdaptationIndex = $listAdaptationMutation.IndexOf('# Agent Instructions for Codex')
    if ($intAdaptationIndex -lt 0) {
        throw 'Self-test fixture could not find an adapted line.'
    }
    $listAdaptationMutation[$intAdaptationIndex] = '# Agent Instructions for Codex altered'
    if ($listAdaptationMutation.IndexOf('# Agent Instructions for Codex') -ge 0) {
        throw 'Self-test failed: an adapted-line mutation retained the reviewed value.'
    }

    $intOversizedFixtureBytes = $intDefaultMaximumBytes + 1
    if ($intOversizedFixtureBytes -le $intDefaultMaximumBytes) {
        throw 'Self-test failed: the oversized fixture passed the fallback limit.'
    }

    'Agent instruction mutation self-tests passed.'
}
