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
# Version: 1.6.20260929.0

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

$strHelperVersionPattern = '(?m)^Version: 1\.(?:0\.(?:2026083[01]|202609(?:0[23]|1[2-58]))|1\.2026091[45]|2\.20260917|(?:1|3)\.20260919|(?:0|2)\.20260927)\.0\.$'
$strHelpValidatorSource = [IO.File]::ReadAllText(
    (Join-Path $PSScriptRoot 'Test-AgentInstructions.ps1'))
if ([regex]::Matches($strHelpValidatorSource,
        [regex]::Escape("'$strHelperVersionPattern'")).Count -ne 1) {
    throw 'The helper-version test does not bind the actual finite consumer.'
}
$arrExpectedHelperVersions = @(
    '1.0.20260830.0', '1.0.20260831.0',
    '1.0.20260902.0', '1.0.20260903.0',
    '1.0.20260912.0', '1.0.20260913.0',
    '1.0.20260914.0', '1.0.20260915.0', '1.0.20260918.0',
    '1.1.20260914.0', '1.1.20260915.0', '1.2.20260917.0',
    '1.1.20260919.0', '1.3.20260919.0', '1.0.20260927.0', '1.2.20260927.0'
)
$intHelperVersionCases = 0
$intAcceptedHelperVersions = 0
foreach ($intMinorVersion in 0..3) {
    foreach ($intBuildMonth in 8..10) {
        foreach ($intBuildDay in 0..32) {
            foreach ($intRevisionVersion in 0..1) {
                $strHelperVersion = '1.{0}.2026{1:D2}{2:D2}.{3}' -f
                    $intMinorVersion, $intBuildMonth, $intBuildDay,
                    $intRevisionVersion
                $boolAcceptedHelperVersion = [regex]::IsMatch(
                    "Version: $strHelperVersion.", $strHelperVersionPattern)
                if ($boolAcceptedHelperVersion -ne
                    ($arrExpectedHelperVersions -ccontains $strHelperVersion)) {
                    throw 'The finite helper-version set changed unexpectedly.'
                }
                if ($boolAcceptedHelperVersion) {
                    $intAcceptedHelperVersions++
                }
                $intHelperVersionCases++
            }
        }
    }
}
if ($intHelperVersionCases -ne 792 -or $intAcceptedHelperVersions -ne 16) {
    throw 'The helper-version fixture census is incomplete.'
}

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
$strCapacityWorkflow = [IO.File]::ReadAllText(
    (Join-Path $PSScriptRoot 'pull-request-body-identity.yml'))
if ([regex]::Matches($strCapacityWorkflow,
        [regex]::Escape('$MaximumBytes -gt 573440')).Count -ne 1 -or
    [regex]::Matches($strCapacityWorkflow,
        [regex]::Escape('MaximumBytes = 573440')).Count -ne 2 -or
    [regex]::Matches($strCapacityWorkflow,
        [regex]::Escape('maximum_blob_bytes -gt 573440')).Count -ne 1) {
    throw 'The bounded identity acquisition consumers disagree on capacity.'
}
$strCapacityAuthorizer = [IO.File]::ReadAllText(
    (Join-Path $PSScriptRoot 'Test-TrustRootAuthorization.ps1'))
if ([regex]::Matches($strCapacityAuthorizer,
        [regex]::Escape('$intCandidateMaximumBlobBytes = 573440')).Count -ne 1) {
    throw 'The trusted authorizer disagrees on the finite candidate capacity.'
}


# Bind the landed U1 supply contracts to both actual workflow roles. These are
# inert content tests; native execution fixtures are run separately on each host.
# This finite detector finds bare literal npm commands in the reviewed Bash run
# bodies. It tracks lists, pipelines, reserved prefixes, bounded command/time
# options, and scalar or bracketed assignment prefixes with their raw syntax.
# It scans $(...) and preserves quote/escape context. In $((...)) and
# command-position ((...)), arithmetic identifiers are data; nested $(...) is
# still scanned. Assignment indices and values are not evaluated. This can
# conservatively flag substitutions in array prefixes that Bash ignores.
# Before the first literal npm, active legacy backtick substitutions fail closed;
# comments, single-quoted data and escaped literal backticks remain data.
# It does not model redirection grammar, wrapper options, other languages,
# path-qualified executables, aliases/functions, variable values, ANSI-C quoting,
# eval, here-documents, ambiguous arithmetic fallback, or arbitrary Bash.
$scriptblockFindLiteralNpmCommand = {
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Text)
    if ($Text.Length -gt 131072) { throw 'The literal Bash fixture exceeds its bound.' }
    $strWord = ''
    $intWordStart = -1
    $strQuote = ''
    $boolCommand = $true
    $strCommandPrefix = ''
    $boolWordQuoted = $false
    $boolAssignmentPrefix = $false
    $strAssignmentState = 'name'
    $intAssignmentDepth = 0
    $intArithmeticDepth = 0
    $intGroupingDepth = 0
    $stackSubstitution = [Collections.Generic.Stack[object]]::new()
    for ($intCharacter = 0; $intCharacter -le $Text.Length; $intCharacter++) {
        $strCharacter = if ($intCharacter -lt $Text.Length) {
            [string] $Text[$intCharacter]
        } else { "`n" }
        $strNext = if ($intCharacter + 1 -lt $Text.Length) {
            [string] $Text[$intCharacter + 1]
        } else { '' }
        if ($strQuote -ceq "'") {
            if ($strCharacter -ceq "'") { $strQuote = '' } else { $strWord += $strCharacter }
            continue
        }
        if ($strCharacter -ceq '\' -and $intCharacter -lt $Text.Length) {
            if ($strNext -cne "`n") {
                if ($intWordStart -lt 0) { $intWordStart = $intCharacter }
                if ($strQuote -ceq '"' -and $strNext -cnotin @('$', '`', '"', '\')) {
                    $strWord += '\'
                }
                $strWord += $strNext
                $boolWordQuoted = $true
                if ($strAssignmentState -cnotin @('subscript', 'value')) {
                    $strAssignmentState = 'invalid'
                }
            }
            $intCharacter++
            continue
        }
        if ($strCharacter -ceq '`') {
            throw 'Legacy command substitution is unsupported; use $(...) in the literal Bash fixture.'
        }
        if ($strCharacter -ceq '$' -and $strNext -ceq '(') {
            if ($stackSubstitution.Count -ge 16) { throw 'The command-substitution fixture exceeds its bound.' }
            if ($intWordStart -lt 0) { $intWordStart = $intCharacter }
            if ($strAssignmentState -cnotin @('subscript', 'value')) {
                $strAssignmentState = 'invalid'
            }
            $stackSubstitution.Push(@($strQuote, $strWord, $intWordStart,
                    $boolCommand, $boolWordQuoted, $intArithmeticDepth,
                    $boolAssignmentPrefix, $intGroupingDepth, $strCommandPrefix,
                    $strAssignmentState, $intAssignmentDepth))
            $strQuote = ''
            $strWord = ''
            $intWordStart = -1
            $boolCommand = $true
            $strCommandPrefix = ''
            $boolWordQuoted = $false
            $boolAssignmentPrefix = $false
            $strAssignmentState = 'name'
            $intAssignmentDepth = 0
            $intArithmeticDepth = 0
            $intGroupingDepth = 0
            $intCharacter++
            if ($intCharacter + 1 -lt $Text.Length -and $Text[$intCharacter + 1] -ceq '(') {
                $intArithmeticDepth = 2
                $intCharacter++
            }
            continue
        }
        if ($intArithmeticDepth -eq 0 -and $strQuote -ceq '' -and
            $boolCommand -and $intWordStart -lt 0 -and
            $strCharacter -ceq '(' -and $strNext -ceq '(') {
            if ($stackSubstitution.Count -ge 16) { throw 'The command-substitution fixture exceeds its bound.' }
            $stackSubstitution.Push(@('', '', $intCharacter, $false, $false, 0,
                    $false, $intGroupingDepth, '', 'invalid', 0))
            $intArithmeticDepth = 2
            $intGroupingDepth = 0
            $intCharacter++
            continue
        }
        if ($intArithmeticDepth -gt 0) {
            if ($strCharacter -ceq '(') { $intArithmeticDepth++ }
            if ($strCharacter -ceq ')') { $intArithmeticDepth-- }
            if ($intArithmeticDepth -eq 0) {
                $arrPrevious = $stackSubstitution.Pop()
                $strQuote = $arrPrevious[0]
                $strWord = $arrPrevious[1] + '<arithmetic-expansion>'
                $intWordStart = [int] $arrPrevious[2]
                $boolCommand = [bool] $arrPrevious[3]
                $boolWordQuoted = [bool] $arrPrevious[4]
                $intArithmeticDepth = [int] $arrPrevious[5]
                $boolAssignmentPrefix = [bool] $arrPrevious[6]
                $intGroupingDepth = [int] $arrPrevious[7]
                $strCommandPrefix = [string] $arrPrevious[8]
                $strAssignmentState = [string] $arrPrevious[9]
                $intAssignmentDepth = [int] $arrPrevious[10]
            }
            continue
        }
        if ($strQuote -ceq '"') {
            if ($strCharacter -ceq '"') { $strQuote = '' } else { $strWord += $strCharacter }
            continue
        }
        if ($strCharacter -cin @("'", '"')) {
            if ($intWordStart -lt 0) { $intWordStart = $intCharacter }
            $strQuote = $strCharacter
            $boolWordQuoted = $true
            if ($strAssignmentState -cnotin @('subscript', 'value')) {
                $strAssignmentState = 'invalid'
            }
            continue
        }
        if ($strCharacter -ceq '#' -and $intWordStart -lt 0) {
            while ($intCharacter -lt $Text.Length -and $Text[$intCharacter] -cne "`n") {
                $intCharacter++
            }
            $strCharacter = "`n"
        }
        $boolBoundary = $strCharacter -cmatch '^[\s;|&()]$' -and
            $strAssignmentState -cne 'subscript'
        if (-not $boolBoundary) {
            if ($intWordStart -lt 0) { $intWordStart = $intCharacter }
            # Preserve the original name/operator syntax. Quotes and escapes
            # inside a bracketed index or assigned value do not quote the name.
            switch -CaseSensitive ($strAssignmentState) {
                'name' {
                    if (-not $boolCommand -or
                        $strCommandPrefix -cin @('command-options', 'command-word')) {
                        $strAssignmentState = 'invalid'
                    } elseif ($strCharacter -ceq '=' -and
                        $strWord -cmatch '^[A-Za-z_][A-Za-z0-9_]*$') {
                        $boolAssignmentPrefix = $true
                        $strAssignmentState = 'value'
                    } elseif ($strCharacter -ceq '[' -and
                        $strWord -cmatch '^[A-Za-z_][A-Za-z0-9_]*$') {
                        $strAssignmentState = 'subscript'
                        $intAssignmentDepth = 1
                    } elseif ($strCharacter -ceq '+' -and
                        $strWord -cmatch '^[A-Za-z_][A-Za-z0-9_]*$') {
                        $strAssignmentState = 'append'
                    } elseif ($strCharacter -cnotmatch '^[A-Za-z0-9_]$') {
                        $strAssignmentState = 'invalid'
                    }
                }
                'subscript' {
                    if ($strCharacter -ceq '[') { $intAssignmentDepth++ }
                    if ($strCharacter -ceq ']') { $intAssignmentDepth-- }
                    if ($intAssignmentDepth -eq 0) { $strAssignmentState = 'after-subscript' }
                }
                'after-subscript' {
                    if ($strCharacter -ceq '=') {
                        $boolAssignmentPrefix = $true
                        $strAssignmentState = 'value'
                    } elseif ($strCharacter -ceq '+') {
                        $strAssignmentState = 'append'
                    } else { $strAssignmentState = 'invalid' }
                }
                'append' {
                    if ($strCharacter -ceq '=') {
                        $boolAssignmentPrefix = $true
                        $strAssignmentState = 'value'
                    } else { $strAssignmentState = 'invalid' }
                }
            }
            $strWord += $strCharacter
            continue
        }
        if ($intWordStart -ge 0) {
            if ($boolCommand) {
                $boolPrefixOption = $false
                $boolShellPrefixAllowed = $true
                switch -CaseSensitive ($strCommandPrefix) {
                    'command-options' {
                        $boolShellPrefixAllowed = $false
                        if ($strWord -ceq '--') {
                            $strCommandPrefix = 'command-word'
                            $boolPrefixOption = $true
                        } elseif ($strWord -cmatch '^-.+') {
                            $boolPrefixOption = $true
                            if ($strWord -cnotmatch '^-[pVv]+$' -or
                                $strWord -cmatch '[Vv]') {
                                $boolCommand = $false
                                $strCommandPrefix = ''
                            }
                        } else { $strCommandPrefix = '' }
                    }
                    'command-word' {
                        $boolShellPrefixAllowed = $false
                        $strCommandPrefix = ''
                    }
                    'time-options' {
                        if (-not $boolWordQuoted -and $strWord -ceq '-p') {
                            $strCommandPrefix = 'time-after-p'
                            $boolPrefixOption = $true
                        } elseif (-not $boolWordQuoted -and $strWord -ceq '--') {
                            $strCommandPrefix = 'time-word'
                            $boolPrefixOption = $true
                        } else { $strCommandPrefix = '' }
                    }
                    'time-after-p' {
                        if (-not $boolWordQuoted -and $strWord -ceq '--') {
                            $strCommandPrefix = 'time-word'
                            $boolPrefixOption = $true
                        } else { $strCommandPrefix = '' }
                    }
                    'time-word' { $strCommandPrefix = '' }
                }
                if (-not $boolPrefixOption) {
                    if ($strWord -ceq 'npm') { return $intWordStart }
                    if ($strWord -ceq 'command') {
                        $strCommandPrefix = 'command-options'
                    } elseif ($boolShellPrefixAllowed -and -not $boolWordQuoted -and
                        $strWord -ceq 'time') {
                        $strCommandPrefix = 'time-options'
                    } else {
                        $boolCommand = $boolShellPrefixAllowed -and (
                            (-not $boolWordQuoted -and
                                $strWord -cin @('if', 'then', 'elif', 'else', 'do', '!',
                                    'while', 'until', '{', 'coproc')) -or
                            $boolAssignmentPrefix)
                    }
                }
            }
            $strWord = ''
            $intWordStart = -1
            $boolWordQuoted = $false
            $boolAssignmentPrefix = $false
            $strAssignmentState = 'name'
            $intAssignmentDepth = 0
        }
        if ($strCharacter -ceq '(') {
            if ($intGroupingDepth -ge 16) { throw 'The grouping fixture exceeds its bound.' }
            $intGroupingDepth++
            $strCommandPrefix = ''
            $boolCommand = $true
        } elseif ($strCharacter -ceq ')' -and $intGroupingDepth -gt 0) {
            $intGroupingDepth--
            $strCommandPrefix = ''
            $boolCommand = $false
        } elseif ($strCharacter -ceq ')' -and $stackSubstitution.Count -gt 0) {
            $arrPrevious = $stackSubstitution.Pop()
            $strQuote = $arrPrevious[0]
            $strWord = $arrPrevious[1] + '<command-substitution>'
            $intWordStart = [int] $arrPrevious[2]
            $boolCommand = [bool] $arrPrevious[3]
            $boolWordQuoted = [bool] $arrPrevious[4]
            $intArithmeticDepth = [int] $arrPrevious[5]
            $boolAssignmentPrefix = [bool] $arrPrevious[6]
            $intGroupingDepth = [int] $arrPrevious[7]
            $strCommandPrefix = [string] $arrPrevious[8]
            $strAssignmentState = [string] $arrPrevious[9]
            $intAssignmentDepth = [int] $arrPrevious[10]
        } elseif ($strCharacter -cmatch '^[\r\n;|&()]$') {
            $strCommandPrefix = ''
            $boolCommand = $true
        }
    }
    return -1
}

$scriptblockGetAgentSupplyFailure = {
    param(
        [Parameter(Mandatory)][string] $WorkflowContent,
        [Parameter(Mandatory)][bool] $PullRequestRole
    )

    $hashtableExpectedNativeIdentityBlocks = @{
        checkout = @'
          $arrHeadOutput = @(& $strGitPath rev-parse HEAD)
          $intHeadExitCode = $LASTEXITCODE
          if ($intHeadExitCode -ne 0) {
              throw "acquire: git rev-parse exited $intHeadExitCode"
          }
          if ($arrHeadOutput.Count -ne 1) {
              throw 'acquire: git rev-parse must return exactly one line'
          }
          $strHead = $arrHeadOutput[0].Trim()
          if ($strHead -cne $strSha) {
              throw 'acquire: the checked out revision is not the triggering revision'
          }
'@.TrimEnd()
        runtime = @'
          $arrVersionOutput = @(& $strNodePath --version)
          $intVersionExitCode = $LASTEXITCODE
          if ($intVersionExitCode -ne 0) {
              throw "toolchain: runtime version command exited $intVersionExitCode"
          }
          if ($arrVersionOutput.Count -ne 1) {
              throw 'toolchain: runtime version command must return exactly one line'
          }
          $strObservedVersion = $arrVersionOutput[0].Trim()
          if ($strObservedVersion -cne "v$strVersion") {
              throw 'toolchain: verified runtime executable identity is wrong'
          }
'@.TrimEnd()
    }
    foreach ($objNativeIdentityBlock in $hashtableExpectedNativeIdentityBlocks.GetEnumerator()) {
        if ([regex]::Matches(
                $WorkflowContent, [regex]::Escape($objNativeIdentityBlock.Value)
            ).Count -ne 1) {
            Write-Output (
                'Agent workflow must preserve native ' + $objNativeIdentityBlock.Key +
                ' status and single-line identity.'
            )
        }
    }

    $strExpectedNpmConfiguration = @'
          export npm_config_userconfig=/dev/null
          export npm_config_globalconfig=/etc/npmrc-absent-by-policy
          if [[ ! -c "${npm_config_userconfig}" || -s "${npm_config_userconfig}" ||
            -e "${npm_config_globalconfig}" || -L "${npm_config_globalconfig}" ]]; then
            echo '::error::Unexpected package-manager configuration source.'
            exit 1
          fi
          printf '%s\n' 'npm_config_userconfig=/dev/null' \
            'npm_config_globalconfig=/etc/npmrc-absent-by-policy' >> "${GITHUB_ENV}"
'@.TrimEnd()
    $arrNpmConfigurationBlocks = @([regex]::Matches(
            $WorkflowContent, [regex]::Escape($strExpectedNpmConfiguration)
        ))
    $intFirstNpmInvocation = -1
    $arrLiteralSteps = @([regex]::Matches($WorkflowContent,
            '(?ms)^      - name: [^\n]+\n.*?(?=^      - name: |\z)'))
    if ($arrLiteralSteps.Count -gt 64) { throw 'The literal step fixture exceeds its bound.' }
    foreach ($objLiteralStep in $arrLiteralSteps) {
        if ($objLiteralStep.Value -cnotmatch '(?m)^        shell: bash$') { continue }
        $objLiteralRun = [regex]::Match($objLiteralStep.Value,
            '(?m)^        run: \|\n(?<Body>(?:^          [^\n]*\n|^\n)*)')
        if (-not $objLiteralRun.Success) { throw 'The Bash fixture must use a literal run body.' }
        $intNpmInRun = & $scriptblockFindLiteralNpmCommand -Text $objLiteralRun.Groups['Body'].Value
        if ($intNpmInRun -ge 0) {
            $intFirstNpmInvocation = $objLiteralStep.Index + $objLiteralRun.Groups['Body'].Index + $intNpmInRun
            break
        }
    }
    if ($arrNpmConfigurationBlocks.Count -ne 1 -or
        $intFirstNpmInvocation -lt 0 -or
        $arrNpmConfigurationBlocks[0].Index -ge $intFirstNpmInvocation) {
        Write-Output 'Agent workflow must isolate npm file configuration before its first npm invocation.'
    }

    $strExpectedNodeDownload = '          & $strCurlPath --silent --show-error --fail --location --proto ''=https'' --proto-redir ''=https'' --tlsv1.2 --retry 3 --retry-all-errors --connect-timeout 20 --max-time 120 --retry-max-time 300 --output $strArchive $strUrl'
    if ([regex]::Matches($WorkflowContent,
            [regex]::Escape($strExpectedNodeDownload)).Count -ne 1) {
        Write-Output 'Agent workflow must use the bounded anonymous Node download.'
    }
    if (-not $PullRequestRole) { return }

    $strExpectedInvocationGuard = @'
        run: |
          $ErrorActionPreference = 'Stop'
          if (-not [string]::IsNullOrEmpty($env:GITHUB_TOKEN) -or
              -not [string]::IsNullOrEmpty($env:GH_TOKEN) -or
              -not [string]::IsNullOrEmpty($env:ACTIONS_RUNTIME_TOKEN) -or
              -not [string]::IsNullOrEmpty($env:GIT_CONFIG_COUNT) -or
              -not [string]::IsNullOrEmpty($env:GIT_CONFIG_PARAMETERS)) {
              throw 'credential-policy: unexpected credential or Git configuration channel'
          }
          ./.github/workflows/Test-AgentInstructions.ps1 -SelfTest `
'@.TrimEnd()
    if ([regex]::Matches($WorkflowContent,
            [regex]::Escape($strExpectedInvocationGuard)).Count -ne 1) {
        Write-Output 'The ordinary validator must reject all five credential/config channels immediately before invocation.'
    }

    $strPullRequestHeadFetch = @'
      - name: Fetch pull request head as data
        if: github.event_name == 'pull_request_target'
        shell: bash
        env:
          PR_HEAD_SHA: ${{ github.event.pull_request.head.sha }}
          PR_NUMBER: ${{ github.event.pull_request.number }}
        run: |
          set -euo pipefail
          if [[ -n "${GITHUB_TOKEN:-}" || -n "${GH_TOKEN:-}" ||
            -n "${ACTIONS_RUNTIME_TOKEN:-}" || -n "${GIT_CONFIG_COUNT:-}" ||
            -n "${GIT_CONFIG_PARAMETERS:-}" ]]; then
            echo '::error::Unexpected credential or Git configuration channel.'
            exit 1
          fi
          export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null GIT_TERMINAL_PROMPT=0
          if ! [[ "${PR_HEAD_SHA}" =~ ^[0-9a-f]{40}$ ]]; then
            echo '::error::Pull request head must be a full lowercase commit hash.'
            exit 1
          fi
          if ! [[ "${PR_NUMBER}" =~ ^[1-9][0-9]*$ ]]; then
            echo '::error::Pull request number must be a positive decimal integer.'
            exit 1
          fi
          # An unexpected non-fast-forward local ref must fail closed.
          git fetch --no-tags --no-recurse-submodules origin \
              "refs/pull/${PR_NUMBER}/head:refs/remotes/pull/${PR_NUMBER}/head"
          fetched_head="$(git rev-parse --verify \
            "refs/remotes/pull/${PR_NUMBER}/head^{commit}")"
          if ! test "${fetched_head}" = "${PR_HEAD_SHA}"; then
            echo '::error::Fetched pull request head does not match the exact event identity.'
            exit 1
          fi
          git diff --quiet --no-ext-diff || {
            diff_status=$?
            echo '::error::Could not confirm a clean worktree after pull request head acquisition.'
            exit "${diff_status}"
          }
          git diff --cached --quiet --no-ext-diff || {
            diff_status=$?
            echo '::error::Could not confirm a clean index after pull request head acquisition.'
            exit "${diff_status}"
          }
'@.TrimEnd()
    if ([regex]::Matches($WorkflowContent,
            [regex]::Escape($strPullRequestHeadFetch)).Count -ne 1) {
        Write-Output 'The pull-request head must use the exact numbered-ref and event-SHA contract.'
    }

    $strPullRequestBaseFetch = @'
      - name: Fetch pull request base as data
        if: github.event_name == 'pull_request_target'
        shell: bash
        env:
          PR_BASE_SHA: ${{ github.event.pull_request.base.sha }}
        run: |
          set -euo pipefail
          if [[ -n "${GITHUB_TOKEN:-}" || -n "${GH_TOKEN:-}" ||
            -n "${ACTIONS_RUNTIME_TOKEN:-}" || -n "${GIT_CONFIG_COUNT:-}" ||
            -n "${GIT_CONFIG_PARAMETERS:-}" ]]; then
            echo '::error::Unexpected credential or Git configuration channel.'
            exit 1
          fi
          export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null GIT_TERMINAL_PROMPT=0
          if [[ ! "${PR_BASE_SHA:-}" =~ ^[0-9a-f]{40}$ ]]; then
            echo '::error::Pull request base must be a full lowercase commit hash.'
            exit 1
          fi
          if [[ "${PR_BASE_SHA}" == "0000000000000000000000000000000000000000" ]]; then
            echo '::error::Pull request base must not be the zero commit hash.'
            exit 1
          fi
          if ! git cat-file -e "${PR_BASE_SHA}^{commit}" 2>/dev/null; then
            if ! git fetch --no-tags --no-recurse-submodules origin "${PR_BASE_SHA}"; then
              echo '::error::Could not fetch the exact pull request base.'
              exit 1
            fi
          fi
          if ! fetched_base="$(git rev-parse --verify "${PR_BASE_SHA}^{commit}")"; then
            echo '::error::Could not resolve the exact pull request base commit.'
            exit 1
          fi
          if [[ "${fetched_base}" != "${PR_BASE_SHA}" ]]; then
            echo '::error::Resolved pull request base does not match the exact event identity.'
            exit 1
          fi
          if ! git diff --quiet --no-ext-diff; then
            echo '::error::Could not confirm a clean worktree after pull request base acquisition.'
            exit 1
          fi
          if ! git diff --cached --quiet --no-ext-diff; then
            echo '::error::Could not confirm a clean index after pull request base acquisition.'
            exit 1
          fi
'@.TrimEnd()
    if ([regex]::Matches(
            $WorkflowContent,
            [regex]::Escape($strPullRequestBaseFetch)
        ).Count -ne 1) {
        Write-Output 'The exact pull-request base data-fetch contract is not exact.'
    }

    $intBaseFetch = $WorkflowContent.IndexOf($strPullRequestBaseFetch,
        [StringComparison]::Ordinal)
    $intAuthorization = $WorkflowContent.IndexOf(
        '      - name: Validate exact trust-root maintenance as inert data',
        [StringComparison]::Ordinal)
    $intPublishedValidation = $WorkflowContent.IndexOf(
        '      - name: Validate instruction capacity and capabilities',
        [StringComparison]::Ordinal)
    if ($intBaseFetch -lt 0 -or $intAuthorization -le $intBaseFetch -or
        $intPublishedValidation -le $intBaseFetch) {
        Write-Output 'PR base data must be available before authorization and published validation.'
    }
}

# These are lexical controls, not execution of candidate shell text.
$arrBadNpmSyntax = @('npm --version', 'true && npm --version', 'printf x | npm --version',
    'true || npm --version', 'true; npm --version', 'test "$(npm --version)" = 1',
    'value=$(npm --version)', 'if npm --version; then true; fi', 'command npm --version',
    'true && "npm" --version', 'true && n"p"m --version', 'VAR=value npm --version',
    "true &&\`nnpm --version", 'echo "$(true && npm --version)"',
    'while npm --version; do break; done', 'until npm --version; do break; done',
    '{ npm --version; }', 'time npm --version', 'coproc npm --version',
    'echo "$(( $(npm --version) + 1 ))"', 'echo "$(( 1 + ( $(npm --version) ) ))"',
    'echo "$(echo "$(( $(npm --version) + 1 ))")"',
    'echo "$(( $(( $(npm --version) + 1 )) + 1 ))"',
    'n\pm --version', '''npm'' --version', '"command" "npm" --version',
    'echo "$((npm + 1))"; npm --version',
    '(( $(npm --version) + 1 ))', '(( 1 + ( $(npm --version) ) ))',
    'VAR="x" npm --version', 'VAR=''x'' npm --version', 'VAR=x\ y npm --version',
    'VAR="" npm --version', 'VAR="$(echo x)" npm --version', 'VAR="$((1))" npm --version')
$arrBenignNpmSyntax = @('# npm --version', '# $(npm --version)', 'echo "npm --version"',
    'echo ''$(npm --version)''', 'echo npm --version', 'export npm_config_userconfig=/dev/null',
    'printf ''npm --version''', 'echo "true && npm --version"', 'npm_config_value=npm',
    'test "$(node -p ''npm'')" = npm', 'echo "$(echo npm --version)"', 'echo "\$(npm --version)"',
    'echo "$((npm + 1))"', 'echo "$(((npm + 1) * 2))"',
    'echo "$(( $((npm + 1)) + 1 ))"', 'echo "$(( $(echo npm) + 1 ))"',
    'echo "$(echo "$((npm + 1))")"',
    '"if" npm --version', '''if'' npm --version', '\if npm --version',
    '"while" npm --version', '\while npm --version',
    '"until" npm --version', '\until npm --version',
    '"{" npm --version', '\{ npm --version',
    '"time" npm --version', '\time npm --version',
    '"coproc" npm --version', '\coproc npm --version',
    '# while npm --version', 'printf ''while npm --version''',
    '(( npm + 1 ))', '(( (npm + 1) * 2 ))', '(( $(echo npm) + 1 ))',
    '"n\pm" --version', '"np\m" --version', '"n\\pm" --version',
    '"VAR=x" npm --version', 'V\AR=x npm --version', 'VAR\=x npm --version',
    'VA"R"=x npm --version')

# A completed expansion word must not hide the next command or promote an
# argument. Local grouping must close before its outer substitution closes.
$arrBadNpmSyntax += @(
    'npm --version; echo `printf x`'
    'npm --version; echo "`printf x`"'
    'echo arr[; npm --version'
    'echo arr[ && npm --version'
    'printf %s arr[; npm --version'
    'echo arr[0; npm --version'
    'echo arr[; npm --version; echo ]=x'
    'echo arr[0; npm --version; echo ]'
    'command nonexistent_assignment_probe[ || npm --version'
    'command -p nonexistent_assignment_probe[ || npm --version'
    'command -- nonexistent_assignment_probe[ || npm --version'
    'command -p -- nonexistent_assignment_probe[ || npm --version'
    'echo "$(echo arr[; npm --version)"'
    'echo "$(command -p nonexistent_assignment_probe[ || npm --version)"'
    'VAR+=x npm --version'
    'VAR+="x" npm --version'
    'VAR+=x MORE=y npm --version'
    'arr[0]=x npm --version'
    'arr[0]+=x npm --version'
    'arr[name]=x npm --version'
    'arr[1+1]=x npm --version'
    'arr[1 + 1]=x npm --version'
    'arr["0"]=x npm --version'
    'arr[''0'']=x npm --version'
    'arr[0]="x" npm --version'
    'arr[a[0]]=x npm --version'
    'arr[$(printf 0)]=x npm --version'
    'arr[$(npm --version)]=x'
    'arr[0]="$(npm --version)"'
    'echo "$(arr[0]=x npm --version)"'
    'arr[0]=x printf ok; npm --version'
    'VAR+=$(printf x) npm --version'
    'command -v "$(printf npm)" npm; npm --version'
    'time -p npm --version'
    'time -- npm --version'
    'time -p -- npm --version'
    'command -p npm --version'
    'command -- npm --version'
    'command -p -- npm --version'
    'command -pp npm --version'
    '"command" "-p" npm --version'
    'command -p -p npm --version'
    'command -- command -p npm --version'
    'time -p command -p npm --version'
    'time time -p npm --version'
    'command -v node; npm --version'
    'command -V printf && npm --version'
    'command -pv node | npm --version'
    'echo "$(command -p npm --version)"'
    'command -v "$(npm --version)"'
    'time -p echo "$(npm --version)"'
    'echo "$(command -v node)"; command -p npm --version'
    'command -p npm --version # query options after command are arguments'
    foreach ($strCommandPrefix in @('(( 1 ))', 'echo $((1))', 'echo $(true)')) {
        foreach ($strCommandSeparator in @('; ', "`n", ' && ', ' | ')) {
            $strCommandPrefix + $strCommandSeparator + 'npm --version'
        }
    }
    foreach ($strCommandPrefix in @('(( 0 ))', 'false $((1))', 'false $(true)')) {
        $strCommandPrefix + ' || npm --version'
    }
    'echo $(( $(true) + 1 )); npm --version'
    'echo $(echo $((1))); npm --version'
    '(( $((1)) )); npm --version'
    'echo "$( (true); npm --version )"'
    'echo $( (true); npm --version )'
    'echo "$( ( (true) ); npm --version )"'
    'echo "$( (echo $(true)); npm --version )"'
    'echo "$(true | (npm --version))"'
    'echo "$( printf '')''; npm --version )"'
)
$arrBenignNpmSyntax += @(
    '# `npm --version`'
    'echo ''`npm --version`'''
    'echo \`npm --version\`'
    'echo "\`npm --version\`"'
    'printf ''%s'' ''`'''
    'echo "$(printf ''`npm --version`'')"'
    'echo "$(printf \`npm --version\`)"'
    'echo literal # `npm --version`'
    'echo arr[; printf npm'
    'echo arr[ && printf npm'
    'printf %s arr[; printf npm'
    'echo arr[0; printf npm'
    'echo arr[; printf npm; echo ]=x'
    'echo arr[0; printf npm; echo ]'
    'command nonexistent_assignment_probe[ || printf npm'
    'command -p nonexistent_assignment_probe[ || printf npm'
    'command -- nonexistent_assignment_probe[ || printf npm'
    'command -p -- nonexistent_assignment_probe[ || printf npm'
    'echo "$(echo arr[; printf npm)"'
    'echo "$(command -p nonexistent_assignment_probe[ || printf npm)"'
    '"VAR+=x" npm --version'
    'VAR\+=x npm --version'
    'VAR+\=x npm --version'
    '"arr[0]=x" npm --version'
    'arr\[0\]=x npm --version'
    '"arr"[0]=x npm --version'
    'arr[0]\=x npm --version'
    'arr[0]"="x npm --version'
    'arr[0]x=x npm --version'
    'arr[0]++=x npm --version'
    'arr[0]=x printf npm'
    'arr[0]="$(printf npm)" printf npm'
    'arr[$(printf npm)]=x printf npm'
    'VAR+="$(printf npm)" printf npm'
    'echo "arr[0]=x npm --version"'
    '# arr[0]=x npm --version'
    'command -v "$(printf npm)" npm'
    'time -p -p npm --version'
    'time -x npm --version'
    'time "-p" npm --version'
    'command -v npm --version'
    'command -V npm --version'
    'command -pv npm --version'
    'command -Vp npm --version'
    'command -p -v npm --version'
    'command -v -- npm --version'
    'command -x npm --version'
    'command -- -p npm --version'
    'command -p printf npm'
    'command if npm --version'
    'command VAR=x npm --version'
    'echo "$(command -pv npm --version)"'
    'command -v node; printf npm'
    'time -p printf npm'
    'time -p -- printf npm'
    'echo "$(command -v node)"; printf npm'
    'echo "time -p npm --version"'
    '# command -p npm --version'
    'echo $((1)) npm --version'
    'echo $(true) npm --version'
    'echo $(echo $((1))) npm --version'
    'echo $(( $(true) + 1 )) npm --version'
    '(( 1 )); echo npm --version'
    'echo "$( (true); echo npm --version )"'
    'echo $( (true); echo npm --version )'
    'echo "$( ( (true) ); echo npm --version )"'
    'echo "$( (echo $(true)); echo npm --version )"'
    'echo "$(true | (echo npm --version))"'
    'echo "$( printf '')''; echo npm --version )"'
)

$arrUnsupportedBashSyntax = @(
    'echo `npm --version`', 'echo "`npm --version`"', 'echo `printf x`',
    'VAR=`printf x`', 'echo "$(echo `printf x`)"', 'printf x; echo `printf x`',
    '(( `printf 1` + 1 ))', 'echo "$(( `printf 1` + 1 ))"',
    'echo \`literal\`; echo `printf x`', '`npm --version`'
)
foreach ($strUnsupportedBashSyntax in $arrUnsupportedBashSyntax) {
    $boolLegacySubstitutionRejected = $false
    try {
        $null = & $scriptblockFindLiteralNpmCommand -Text $strUnsupportedBashSyntax
    } catch {
        if ($_.Exception.Message -cne
            'Legacy command substitution is unsupported; use $(...) in the literal Bash fixture.') {
            throw
        }
        $boolLegacySubstitutionRejected = $true
    }
    if (-not $boolLegacySubstitutionRejected) {
        throw 'The legacy substitution syntax did not fail closed.'
    }
}
foreach ($strNpmSyntax in $arrBadNpmSyntax + $arrBenignNpmSyntax) {
    $intNpmSyntaxIndex = & $scriptblockFindLiteralNpmCommand -Text $strNpmSyntax
    if (($intNpmSyntaxIndex -ge 0) -ne ($arrBadNpmSyntax -ccontains $strNpmSyntax)) {
        throw 'The bounded literal npm detector misclassified a syntax control.'
    }
}
$intSupplyBoundaryCount = 0
$arrLiteralBoundaryFixtures = @(
    @('length', ((' ' * (131072 - 'npm --version'.Length)) + 'npm --version'),
        (' ' * 131073), 'The literal Bash fixture exceeds its bound.'),
    @('substitution', (('$(' * 16) + 'npm --version' + (')' * 16)),
        (('$(' * 17) + 'true' + (')' * 17)),
        'The command-substitution fixture exceeds its bound.')
)
foreach ($arrLiteralBoundaryFixture in $arrLiteralBoundaryFixtures) {
    if ((& $scriptblockFindLiteralNpmCommand -Text $arrLiteralBoundaryFixture[1]) -lt 0) {
        throw "The $($arrLiteralBoundaryFixture[0]) boundary lost a literal npm command."
    }
    $boolLiteralOverflowRejected = $false
    try {
        $null = & $scriptblockFindLiteralNpmCommand -Text $arrLiteralBoundaryFixture[2]
    } catch {
        if ($_.Exception.Message -cne $arrLiteralBoundaryFixture[3]) { throw }
        $boolLiteralOverflowRejected = $true
    }
    if (-not $boolLiteralOverflowRejected) {
        throw "The $($arrLiteralBoundaryFixture[0]) overflow did not fail closed."
    }
    $intSupplyBoundaryCount += 2
}
$strGroupingBoundaryFixture = ('( ' * 16) + 'npm --version' + (' )' * 16)
if ((& $scriptblockFindLiteralNpmCommand -Text $strGroupingBoundaryFixture) -lt 0) {
    throw 'The grouping-depth boundary lost a literal npm command.'
}
$boolGroupingOverflowRejected = $false
try {
    $strGroupingOverflowFixture = ('( ' * 17) + 'true' + (' )' * 17)
    $null = & $scriptblockFindLiteralNpmCommand -Text $strGroupingOverflowFixture
} catch {
    if ($_.Exception.Message -cne 'The grouping fixture exceeds its bound.') {
        throw
    }
    $boolGroupingOverflowRejected = $true
}
if (-not $boolGroupingOverflowRejected) {
    throw 'The grouping-depth overflow did not fail closed.'
}
$intSupplyBoundaryCount += 2

$scriptblockSetSupplyStepMutation = {
    param([string] $WorkflowContent, [string] $StepName, [string] $OldText, [string] $NewText)
    $strStepPattern = '(?ms)^      - name: ' + [regex]::Escape($StepName) +
        '\n.*?(?=^      - name: |^  [a-z]|\z)'
    $arrSteps = @([regex]::Matches($WorkflowContent, $strStepPattern))
    if ($arrSteps.Count -ne 1 -or
        [regex]::Matches($arrSteps[0].Value, [regex]::Escape($OldText)).Count -ne 1) {
        throw 'A scoped supply mutation must have exactly one step and target.'
    }
    $objStep = $arrSteps[0]
    return $WorkflowContent.Remove($objStep.Index, $objStep.Length).Insert(
        $objStep.Index, $objStep.Value.Replace($OldText, $NewText))
}

$arrSupplyMutations = @(
    @('checkout exit capture', '$intHeadExitCode = $LASTEXITCODE', '$intHeadExitCode = 0'),
    @('checkout failure guard', 'if ($intHeadExitCode -ne 0)', 'if ($false)'),
    @('checkout cardinality', 'if ($arrHeadOutput.Count -ne 1)', 'if ($false)'),
    @('checkout identity', 'if ($strHead -cne $strSha)', 'if ($false)'),
    @('runtime exit capture', '$intVersionExitCode = $LASTEXITCODE', '$intVersionExitCode = 0'),
    @('runtime failure guard', 'if ($intVersionExitCode -ne 0)', 'if ($false)'),
    @('runtime cardinality', 'if ($arrVersionOutput.Count -ne 1)', 'if ($false)'),
    @('runtime identity', 'if ($strObservedVersion -cne "v$strVersion")', 'if ($false)'),
    @('retry count', '--retry 3 ', ''),
    @('retry errors', '--retry-all-errors ', ''),
    @('connection bound', '--connect-timeout 20 ', ''),
    @('transfer bound', '--max-time 120 ', ''),
    @('retry bound', '--retry-max-time 300 ', ''),
    @('user configuration', 'export npm_config_userconfig=/dev/null', 'export npm_config_userconfig=/tmp/npmrc'),
    @('global configuration', 'export npm_config_globalconfig=/etc/npmrc-absent-by-policy', 'export npm_config_globalconfig=/tmp/npmrc'),
    @('user configuration export', 'export npm_config_userconfig=', 'npm_config_userconfig='),
    @('global configuration export', 'export npm_config_globalconfig=', 'npm_config_globalconfig='),
    @('character device guard', '! -c "${npm_config_userconfig}"', '! -e "${npm_config_userconfig}"'),
    @('empty device guard', ' || -s "${npm_config_userconfig}"', ''),
    @('absent global guard', '-e "${npm_config_globalconfig}"', '-s "${npm_config_globalconfig}"'),
    @('global symlink guard', ' || -L "${npm_config_globalconfig}"', ''),
    @('configuration persistence', '>> "${GITHUB_ENV}"', '> /dev/null')
)
$intSupplyMutationCount = 0
foreach ($strSupplyWorkflowName in @('agent-instructions.yml', 'copilot-setup-steps.yml')) {
    $strSupplyWorkflowPath = $ExecutionContext.SessionState.Path.
        GetUnresolvedProviderPathFromPSPath((Join-Path $PSScriptRoot $strSupplyWorkflowName))
    $strSupplyWorkflowContent = [IO.File]::ReadAllText($strSupplyWorkflowPath)
    $boolPullRequestRole = $strSupplyWorkflowName -ceq 'agent-instructions.yml'
    $arrSupplyFailures = @(& $scriptblockGetAgentSupplyFailure `
            -WorkflowContent $strSupplyWorkflowContent -PullRequestRole $boolPullRequestRole)
    if ($arrSupplyFailures.Count -ne 0) {
        throw "$strSupplyWorkflowName failed U1 supply validation: $($arrSupplyFailures -join '; ')"
    }
    $intLiteralStepCount = [regex]::Matches($strSupplyWorkflowContent,
        '(?ms)^      - name: [^\n]+\n.*?(?=^      - name: |\z)').Count
    $strBoundaryStep = "      - name: Bound fixture`n        shell: bash`n" +
        "        run: |`n          true`n"
    $strStepBoundaryFixture = $strSupplyWorkflowContent + "`n" +
        ($strBoundaryStep * (64 - $intLiteralStepCount))
    $arrStepBoundaryFailures = @(& $scriptblockGetAgentSupplyFailure `
            -WorkflowContent $strStepBoundaryFixture -PullRequestRole $boolPullRequestRole)
    if ($arrStepBoundaryFailures.Count -ne 0) {
        throw 'The 64-step boundary did not preserve the valid workflow contract.'
    }
    $boolStepOverflowRejected = $false
    try {
        $null = & $scriptblockGetAgentSupplyFailure `
            -WorkflowContent ($strStepBoundaryFixture + $strBoundaryStep) `
            -PullRequestRole $boolPullRequestRole
    } catch {
        if ($_.Exception.Message -cne 'The literal step fixture exceeds its bound.') { throw }
        $boolStepOverflowRejected = $true
    }
    if (-not $boolStepOverflowRejected) { throw 'The 65-step overflow did not fail closed.' }
    $intSupplyBoundaryCount += 2
    foreach ($arrSupplyMutation in $arrSupplyMutations) {
        $strSupplyMutant = $strSupplyWorkflowContent.Replace(
            $arrSupplyMutation[1], $arrSupplyMutation[2])
        if ($strSupplyMutant -ceq $strSupplyWorkflowContent -or
            @(& $scriptblockGetAgentSupplyFailure -WorkflowContent $strSupplyMutant `
                    -PullRequestRole $boolPullRequestRole).Count -eq 0) {
            throw "$strSupplyWorkflowName did not reject $($arrSupplyMutation[0])."
        }
        $intSupplyMutationCount++
    }
    $objProducer = [regex]::Match($strSupplyWorkflowContent,
        '(?ms)^          export npm_config_userconfig=/dev/null\n.*?^            ''npm_config_globalconfig=/etc/npmrc-absent-by-policy'' >> "\$\{GITHUB_ENV\}"\n')
    if (-not $objProducer.Success) { throw 'The npm producer fixture is unavailable.' }
    foreach ($strProducerMutation in @('missing', 'late', 'duplicate')) {
        $strSupplyMutant = switch ($strProducerMutation) {
            'missing' { $strSupplyWorkflowContent.Replace($objProducer.Value, '') }
            'late' { $strSupplyWorkflowContent.Replace($objProducer.Value, '') + $objProducer.Value }
            'duplicate' { $strSupplyWorkflowContent + $objProducer.Value }
        }
        if (@(& $scriptblockGetAgentSupplyFailure -WorkflowContent $strSupplyMutant `
                    -PullRequestRole $boolPullRequestRole).Count -eq 0) {
            throw "$strSupplyWorkflowName accepted a $strProducerMutation npm producer."
        }
        $intSupplyMutationCount++
    }
    foreach ($strNpmSyntax in $arrBadNpmSyntax + $arrBenignNpmSyntax) {
        $strNpmLine = '          ' + $strNpmSyntax.Replace("`n", "`n          ") + "`n"
        $strSupplyMutant = $strSupplyWorkflowContent.Insert($objProducer.Index, $strNpmLine)
        $arrNpmSyntaxFailures = @(& $scriptblockGetAgentSupplyFailure -WorkflowContent $strSupplyMutant -PullRequestRole $boolPullRequestRole)
        $boolNpmOrderingRejected = $arrNpmSyntaxFailures -ccontains
            'Agent workflow must isolate npm file configuration before its first npm invocation.'
        if ($boolNpmOrderingRejected -ne ($arrBadNpmSyntax -ccontains $strNpmSyntax)) {
            throw "$strSupplyWorkflowName misclassified a pre-producer literal npm command."
        }
        if ($arrBenignNpmSyntax -ccontains $strNpmSyntax -and $arrNpmSyntaxFailures.Count -ne 0) {
            throw "$strSupplyWorkflowName rejected benign pre-producer shell text."
        }
        $intSupplyMutationCount++
    }
    foreach ($strUnsupportedBashSyntax in $arrUnsupportedBashSyntax) {
        $strUnsupportedLine = '          ' + $strUnsupportedBashSyntax + "`n"
        $strSupplyMutant = $strSupplyWorkflowContent.Insert($objProducer.Index, $strUnsupportedLine)
        $boolLegacySubstitutionRejected = $false
        try {
            $null = & $scriptblockGetAgentSupplyFailure `
                -WorkflowContent $strSupplyMutant -PullRequestRole $boolPullRequestRole
        } catch {
            if ($_.Exception.Message -cne
                'Legacy command substitution is unsupported; use $(...) in the literal Bash fixture.') {
                throw
            }
            $boolLegacySubstitutionRejected = $true
        }
        if (-not $boolLegacySubstitutionRejected) {
            throw "$strSupplyWorkflowName accepted unsupported legacy substitution."
        }
        $intSupplyMutationCount++
    }
    if ($boolPullRequestRole) {
        $strInvocationStep = 'Validate instruction capacity and capabilities'
        $strInvocationFailure = 'The ordinary validator must reject all five credential/config channels immediately before invocation.'
        $strHeadFailure = 'The pull-request head must use the exact numbered-ref and event-SHA contract.'
        $strBaseFailure = 'The exact pull-request base data-fetch contract is not exact.'
        foreach ($strGuardChannel in @('GITHUB_TOKEN', 'GH_TOKEN',
                'ACTIONS_RUNTIME_TOKEN', 'GIT_CONFIG_COUNT', 'GIT_CONFIG_PARAMETERS')) {
            $hashtableMutation = @{
                WorkflowContent = $strSupplyWorkflowContent
                StepName = $strInvocationStep
                OldText = '$env:' + $strGuardChannel + ')'
                NewText = '$env:UNRELATED_CHANNEL)'
            }
            $strSupplyMutant = & $scriptblockSetSupplyStepMutation @hashtableMutation
            if ($strSupplyMutant -ceq $strSupplyWorkflowContent -or
                @(& $scriptblockGetAgentSupplyFailure -WorkflowContent $strSupplyMutant `
                        -PullRequestRole $true) -cnotcontains $strInvocationFailure) {
                throw "The ordinary invocation accepted a missing $strGuardChannel guard."
            }
            $intSupplyMutationCount++
        }
        foreach ($arrGuardMutation in @(
                @('terminating errors', "          `$ErrorActionPreference = 'Stop'", "          `$ErrorActionPreference = 'Continue'"),
                @('missing invocation', '          ./.github/workflows/Test-AgentInstructions.ps1 -SelfTest `', '          # validator invocation removed'),
                @('literal run', "        run: |`n          `$ErrorActionPreference = 'Stop'", "        run: >-`n          `$ErrorActionPreference = 'Stop'")
            )) {
            $hashtableMutation = @{
                WorkflowContent = $strSupplyWorkflowContent
                StepName = $strInvocationStep
                OldText = $arrGuardMutation[1]
                NewText = $arrGuardMutation[2]
            }
            $strSupplyMutant = & $scriptblockSetSupplyStepMutation @hashtableMutation
            if ($strSupplyMutant -ceq $strSupplyWorkflowContent -or
                @(& $scriptblockGetAgentSupplyFailure -WorkflowContent $strSupplyMutant `
                        -PullRequestRole $true) -cnotcontains $strInvocationFailure) {
                throw "The ordinary invocation accepted $($arrGuardMutation[0]) mutation."
            }
            $intSupplyMutationCount++
        }
        foreach ($arrHeadMutation in @(
                @('head event', 'PR_HEAD_SHA: ${{ github.event.pull_request.head.sha }}', 'PR_HEAD_SHA: ${{ github.sha }}'),
                @('head number source', 'PR_NUMBER: ${{ github.event.pull_request.number }}', 'PR_NUMBER: 1'),
                @('head number guard', '[[ "${PR_NUMBER}" =~ ^[1-9][0-9]*$ ]]', 'true'),
                @('head numbered ref', '"refs/pull/${PR_NUMBER}/head:refs/remotes/pull/${PR_NUMBER}/head"', '"${PR_HEAD_SHA}:refs/remotes/event/pr-head"'),
                @('head event equality', 'test "${fetched_head}" = "${PR_HEAD_SHA}"', 'true'),
                @('head tracked cleanliness', 'git diff --cached --quiet --no-ext-diff', 'true')
            )) {
            $hashtableMutation = @{
                WorkflowContent = $strSupplyWorkflowContent
                StepName = 'Fetch pull request head as data'
                OldText = $arrHeadMutation[1]
                NewText = $arrHeadMutation[2]
            }
            $strSupplyMutant = & $scriptblockSetSupplyStepMutation @hashtableMutation
            if ($strSupplyMutant -ceq $strSupplyWorkflowContent -or
                @(& $scriptblockGetAgentSupplyFailure -WorkflowContent $strSupplyMutant `
                        -PullRequestRole $true) -cnotcontains $strHeadFailure) {
                throw "The ordinary workflow did not reject $($arrHeadMutation[0])."
            }
            $intSupplyMutationCount++
        }
        foreach ($arrBaseMutation in @(
                @('base event', 'PR_BASE_SHA: ${{ github.event.pull_request.base.sha }}', 'PR_BASE_SHA: ${{ github.sha }}'),
                @('base syntax', '^[0-9a-f]{40}$', '^[0-9a-f]+$'),
                @('base zero', '== "0000000000000000000000000000000000000000"', '== "unused"'),
                @('base missing', 'if ! git cat-file -e', 'if git cat-file -e'),
                @('base exact fetch', 'origin "${PR_BASE_SHA}"', 'origin main'),
                @('base resolution', 'if ! fetched_base=', 'if fetched_base='),
                @('base identity', '"${fetched_base}" != "${PR_BASE_SHA}"', '"${fetched_base}" == "${PR_BASE_SHA}"'),
                @('base worktree', 'if ! git diff --quiet --no-ext-diff;', 'if false;'),
                @('base index', 'if ! git diff --cached --quiet --no-ext-diff;', 'if false;')
            )) {
            $hashtableMutation = @{
                WorkflowContent = $strSupplyWorkflowContent
                StepName = 'Fetch pull request base as data'
                OldText = $arrBaseMutation[1]
                NewText = $arrBaseMutation[2]
            }
            $strSupplyMutant = & $scriptblockSetSupplyStepMutation @hashtableMutation
            if ($strSupplyMutant -ceq $strSupplyWorkflowContent -or
                @(& $scriptblockGetAgentSupplyFailure -WorkflowContent $strSupplyMutant `
                        -PullRequestRole $true) -cnotcontains $strBaseFailure) {
                throw "The ordinary workflow did not reject $($arrBaseMutation[0])."
            }
            $intSupplyMutationCount++
        }
        foreach ($strDiffCommand in @('git diff --quiet --no-ext-diff',
                'git diff --cached --quiet --no-ext-diff')) {
            $hashtableMutation = @{
                WorkflowContent = $strSupplyWorkflowContent
                StepName = 'Fetch pull request head as data'
                OldText = $strDiffCommand + ' || {' + "`n" + '            diff_status=$?'
                NewText = $strDiffCommand + ' || {' + "`n" + '            diff_status=0'
            }
            $strSupplyMutant = & $scriptblockSetSupplyStepMutation @hashtableMutation
            if (@(& $scriptblockGetAgentSupplyFailure -WorkflowContent $strSupplyMutant -PullRequestRole $true) -cnotcontains $strHeadFailure) {
                throw 'A head cleanliness mutation lost native failure status without rejection.'
            }
            $intSupplyMutationCount++
        }
        $arrInvocationSteps = @([regex]::Matches($strSupplyWorkflowContent,
                '(?ms)^      - name: Validate instruction capacity and capabilities\n.*?(?=^      - name: |^  [a-z]|\z)'))
        if ($arrInvocationSteps.Count -ne 1) { throw 'The invocation step is not unique.' }
        $strInvocationStepText = $arrInvocationSteps[0].Value
        $intInvocationStart = $strInvocationStepText.IndexOf('          ./.github/workflows/Test-AgentInstructions.ps1 -SelfTest ')
        $intGuardStart = $strInvocationStepText.IndexOf('          if (-not [string]::IsNullOrEmpty($env:GITHUB_TOKEN)')
        if ($intInvocationStart -le $intGuardStart -or $intGuardStart -lt 0) { throw 'The invocation ordering fixture is invalid.' }
        $strInvocationText = $strInvocationStepText.Substring($intInvocationStart)
        $strReorderedStep = $strInvocationStepText.Remove($intInvocationStart).Insert($intGuardStart, $strInvocationText)
        $strSupplyMutant = $strSupplyWorkflowContent.Replace($strInvocationStepText, $strReorderedStep)
        if (@(& $scriptblockGetAgentSupplyFailure -WorkflowContent $strSupplyMutant -PullRequestRole $true) -cnotcontains $strInvocationFailure) {
            throw 'The ordinary validator accepted invocation before its guard.'
        }
        $intSupplyMutationCount++
        $objBaseStep = [regex]::Match($strSupplyWorkflowContent,
            '(?ms)^      - name: Fetch pull request base as data\n.*?(?=^      - name: |\z)')
        if (-not $objBaseStep.Success) { throw 'The PR-base step fixture is unavailable.' }
        $strSupplyMutant = $strSupplyWorkflowContent.Replace($objBaseStep.Value, '') + $objBaseStep.Value
        if (@(& $scriptblockGetAgentSupplyFailure -WorkflowContent $strSupplyMutant `
                    -PullRequestRole $true).Count -eq 0) {
            throw 'A PR-base acquisition after its consumers was accepted.'
        }
        $intSupplyMutationCount++
    }
}
if ($intSupplyMutationCount -ne 543) { throw 'The U1 supply mutation census is incomplete.' }
if ($intSupplyBoundaryCount -ne 10) { throw 'The U1 boundary-control census is incomplete.' }

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
$strBoundedFetchClone = [IO.Path]::Combine(
    $strTempRoot,
    'agent-instruction-bounded-fetch-' + [Guid]::NewGuid().ToString('N')
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
    if ($LASTEXITCODE -ne 0 -or $strRootCommit -cnotmatch '^[0-9a-f]{40}$') {
        throw 'Could not resolve the tracked-path baseline fixture.'
    }
    foreach ($strPathReaderRevision in @('', $strRootCommit)) {
        $arrReadPaths = @(Read-GitTrackedPath -RepositoryRootPath $strTopologyRoot `
                -Revision $strPathReaderRevision -MaximumBytes $MaximumBytes)
        if ($arrReadPaths.Count -ne 1 -or $arrReadPaths[0] -cne 'root.txt') {
            throw 'The index/revision readers changed the known baseline path.'
        }
    }

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
        -EventHeadDistinct 'true' -PushCommitEvidenceJson '[]' `
        -OtherRefEvidenceJson $strRootEvidence
    if (@($objZeroContext.IntroducedCommitRevisions).Count -ne 0 -or
        @($objZeroContext.BoundaryRevisions).Count -ne 0 -or
        -not [string]::IsNullOrEmpty(
            (Get-CreatedRefMetadataBaselineRevision `
                -Context $objZeroContext)
        )) {
        throw 'The zero-introduced created-ref fixture invented a baseline.'
    }
    try {
        [void] @(Read-GitPublishedEndpointChangedPath `
            -RepositoryRootPath $strTopologyRoot `
            -BaselineRevision ('0' * 40) -FinalRevision $strRootCommit `
            -BaselineAbsent $true -NewRefBoundaryRevision @() `
            -NewRefIntroducedCommitRevision @() `
            -MaximumBytes $MaximumBytes)
        throw 'The zero-introduction path helper returned a content comparison.'
    } catch {
        if (-not $_.Exception.Message.Contains(
                'A zero-introduction created ref has no content-validation path range.',
                [StringComparison]::Ordinal
            )) {
            throw
        }
    }
    $objZeroFalseContext = Get-CreatedRefBoundaryContext `
        -RepositoryRootPath $strTopologyRoot `
        -DestinationRef 'refs/heads/new-zero' `
        -HeadRevision $strRootCommit -EventHeadRevision $strRootCommit `
        -EventHeadDistinct 'false' -PushCommitEvidenceJson '[]' `
        -OtherRefEvidenceJson $strRootEvidence
    if (@($objZeroFalseContext.IntroducedCommitRevisions).Count -ne 0 -or
        -not [string]::IsNullOrEmpty(
            (Get-CreatedRefMetadataBaselineRevision -Context $objZeroFalseContext)
        )) {
        throw 'The distinct=false zero-introduction control invented a baseline.'
    }

    [IO.File]::WriteAllText(
        (Join-Path $strTopologyRoot 'one.txt'),
        "one`n",
        $objUtf8
    )
    & git -C $strTopologyRoot add -- one.txt
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not stage the tracked-path addition fixture.'
    }
    $arrIndexPaths = @(Read-GitTrackedPath -RepositoryRootPath $strTopologyRoot `
            -MaximumBytes $MaximumBytes)
    $arrRevisionPaths = @(Read-GitTrackedPath -RepositoryRootPath $strTopologyRoot `
            -Revision $strRootCommit -MaximumBytes $MaximumBytes)
    if ($arrIndexPaths.Count -ne 2 -or $arrIndexPaths[0] -cne 'one.txt' -or
        $arrIndexPaths[1] -cne 'root.txt' -or $arrRevisionPaths.Count -ne 1 -or
        $arrRevisionPaths[0] -cne 'root.txt') {
        throw 'The tracked-path readers confused staged and committed paths.'
    }
    & git -C $strTopologyRoot commit --quiet -m one
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not commit the tracked-path addition fixture.'
    }
    $strOneCommit = ([string] (& git -C $strTopologyRoot rev-parse HEAD)).Trim()
    if ($LASTEXITCODE -ne 0 -or $strOneCommit -cnotmatch '^[0-9a-f]{40}$') {
        throw 'Could not resolve the tracked-path addition fixture.'
    }
    foreach ($strPathReaderRevision in @('', $strOneCommit)) {
        $arrReadPaths = @(Read-GitTrackedPath -RepositoryRootPath $strTopologyRoot `
                -Revision $strPathReaderRevision -MaximumBytes $MaximumBytes)
        if ($arrReadPaths.Count -ne 2 -or $arrReadPaths[0] -cne 'one.txt' -or
            $arrReadPaths[1] -cne 'root.txt') {
            throw 'The index/revision readers changed the committed addition.'
        }
    }
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
            -Context $objOneContext) -cne
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
    $strTopologyBranch = ([string] (& git -C $strTopologyRoot `
                symbolic-ref --short HEAD)).Trim()
    & git clone --quiet --depth 1 --no-local --no-hardlinks -- `
        $strTopologyRoot $strBoundedFetchClone
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not create the bounded-fetch shallow clone.'
    }
    & git -C $strBoundedFetchClone fetch --depth=2 --no-tags `
        --no-write-fetch-head --no-recurse-submodules origin `
        "refs/heads/$($strTopologyBranch):refs/remotes/event/bounded-other"
    $intBoundedFetchCommitCount = [int] ([string] (
            & git -C $strBoundedFetchClone rev-list --count `
                refs/remotes/event/bounded-other
        )).Trim()
    & git -C $strBoundedFetchClone cat-file -e "$strRootCommit`^{commit}" 2>$null
    $boolBoundedFetchExcludedRoot = $LASTEXITCODE -ne 0
    $strBoundedFetchShallow = ([string] (& git -C $strBoundedFetchClone `
                rev-parse --is-shallow-repository)).Trim()
    if ($intBoundedFetchCommitCount -ne 2 -or
        -not $boolBoundedFetchExcludedRoot -or
        $strBoundedFetchShallow -cne 'true') {
        throw 'The bounded other-ref fetch imported history beyond its depth.'
    }
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
            -Context $objManyContext) -cne
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
            -Context $objTransientContext) -cne $strRootCommit -or
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
    } catch {
        if (-not $_.Exception.Message.Contains(
                'must have one boundary',
                [StringComparison]::Ordinal
            )) {
            throw
        }
    }
    if (-not [string]::IsNullOrEmpty(
            (Get-CreatedRefMetadataBaselineRevision `
                -Context $objMergeContext)
        )) {
        throw 'An ambiguous multi-boundary context invented a metadata baseline.'
    }

    $strEntryPointDirectory = Join-Path $strTopologyRoot '.github/workflows'
    [void] [IO.Directory]::CreateDirectory($strEntryPointDirectory)
    $strEntryPointPath = Join-Path $strEntryPointDirectory 'Test-AgentInstructions.ps1'
    [IO.File]::Copy(
        (Join-Path $RepositoryRootPath '.github/workflows/Test-AgentInstructions.ps1'),
        $strEntryPointPath,
        $true
    )
    $hashtableEntryPointArguments = @{
        InputRevision = $strMergeCommit
        PublishedBaselineRevision = ('0' * 40)
        PublishedFinalRevision = $strMergeCommit
        PublishedBaselineAbsent = $true
        EventName = 'push'
        TrustedEventTimestamp = [DateTime]::UtcNow.ToString(
            'yyyy-MM-ddTHH:mm:ssZ', [Globalization.CultureInfo]::InvariantCulture)
        DestinationRef = 'refs/heads/new-merge'
        EventHeadRevision = $strMergeCommit
        EventHeadDistinct = 'true'
        PushCommitEvidenceJson = $strMergePayload
        OtherRefEvidenceJson = $strMergeEvidence
    }
    $arrApplicabilityOutput = @(& $strEntryPointPath @hashtableEntryPointArguments)
    if ($arrApplicabilityOutput.Count -ne 1 -or
        $arrApplicabilityOutput[0] -cne
        '{"schema":"PSStyleGuide.AgentInstructionApplicability.v1","result":"NOT_APPLICABLE","reason":"created-ref-ambiguous-baseline","requiredGate":"agent-instruction-current-base"}') {
        throw 'The ambiguous created-ref entry point did not return only non-applicability.'
    }
    $hashtableEntryPointArguments.InputRevision = $strRootCommit
    try {
        & $strEntryPointPath @hashtableEntryPointArguments
        throw 'An inconsistent input revision bypassed the applicability check.'
    } catch {
        if (-not $_.Exception.Message.Contains(
                'The input revision must match the published final revision.',
                [StringComparison]::Ordinal
            )) {
            throw
        }
    }

    foreach ($strZeroShape in @(
            'exact-empty-true', 'exact-empty-false', 'exact-payload-false',
            'ancestor-empty-false', 'ancestor-payload-false'
        )) {
        $strZeroOtherCommit = if ($strZeroShape.StartsWith(
                'ancestor', [StringComparison]::Ordinal
            )) {
            $strMergeCommit
        } else {
            $strRootCommit
        }
        & git -C $strTopologyRoot update-ref `
            refs/remotes/event/created-other-0000 $strZeroOtherCommit
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not set the zero-introduction other-ref fixture.'
        }
        $strZeroOtherEvidence = ConvertTo-Json -Compress -InputObject `
            ([object[]] @([pscustomobject]@{
                    ref = 'refs/heads/existing'
                    object = $strZeroOtherCommit
                    commit = $strZeroOtherCommit
                    local_ref = 'refs/remotes/event/created-other-0000'
                }))
        $strZeroPayload = if ($strZeroShape.Contains(
                'payload', [StringComparison]::Ordinal
            )) {
            ConvertTo-Json -Depth 4 -Compress -InputObject `
                ([object[]] @((ConvertTo-CreatedPushCommitEvidenceObject `
                            -Id $strRootCommit -Distinct $false)))
        } else {
            '[]'
        }
        $hashtableEntryPointArguments.InputRevision = $strRootCommit
        $hashtableEntryPointArguments.PublishedFinalRevision = $strRootCommit
        $hashtableEntryPointArguments.EventHeadRevision = $strRootCommit
        $hashtableEntryPointArguments.EventHeadDistinct = if ($strZeroShape.EndsWith(
                'true', [StringComparison]::Ordinal
            )) {
            'true'
        } else {
            'false'
        }
        $hashtableEntryPointArguments.PushCommitEvidenceJson = $strZeroPayload
        $hashtableEntryPointArguments.OtherRefEvidenceJson = $strZeroOtherEvidence
        $arrZeroOutput = @(& $strEntryPointPath @hashtableEntryPointArguments)
        if ($arrZeroOutput.Count -ne 1 -or
            -not [string]::Equals(
                $arrZeroOutput[0],
                '{"schema":"PSStyleGuide.AgentInstructionApplicability.v1","result":"NOT_APPLICABLE","reason":"created-ref-no-introduced-commits","requiredGate":"agent-instruction-current-base"}',
                [StringComparison]::Ordinal
            )) {
            throw "The zero-introduction entry point reported content success: $strZeroShape"
        }
        $hashtableEntryPointArguments.InputRevision = $strMergeCommit
        try {
            & $strEntryPointPath @hashtableEntryPointArguments
            throw 'A zero-introduction event accepted a mismatched input revision.'
        } catch {
            if (-not $_.Exception.Message.Contains(
                    'The input revision must match the published final revision.',
                    [StringComparison]::Ordinal
                )) {
                throw
            }
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
                -Context $objGenuineRootContext)
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
        } else {
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
        } catch {
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
            Name = 'valid prefix before malformed final object'
            Json = $strOnePayload.Substring(0, $strOnePayload.Length - 1) + ',{}]'
            Head = $strOneCommit
            Distinct = 'true'
            Expected = 'invalid object shape'
        },
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
        $listEvidencePrefix = [Collections.Generic.List[pscustomobject]]::new()
        try {
            Read-CreatedPushCommitEvidence `
                -PushCommitEvidenceJson $objParserRejection.Json `
                -EventHeadRevision $objParserRejection.Head `
                -EventHeadDistinct $objParserRejection.Distinct |
                ForEach-Object { $listEvidencePrefix.Add($_) }
            throw "Rejected evidence parser fixture passed: $($objParserRejection.Name)"
        } catch {
            if ($listEvidencePrefix.Count -ne 0) {
                throw 'Rejected commit evidence emitted a partial result.'
            }
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
    } catch {
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
} finally {
    if ([IO.Directory]::Exists($strBoundedFetchClone) -and
        $strBoundedFetchClone.StartsWith(
            $strTempRoot,
            [StringComparison]::OrdinalIgnoreCase
        )) {
        Remove-Item -LiteralPath $strBoundedFetchClone -Recurse -Force
    }
    if ([IO.Directory]::Exists($strTopologyRoot) -and
        $strTopologyRoot.StartsWith(
            $strTempRoot,
            [StringComparison]::OrdinalIgnoreCase
        )) {
        Remove-Item -LiteralPath $strTopologyRoot -Recurse -Force
    }
}
