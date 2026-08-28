# .SYNOPSIS
# Verifies Codex capacity and shared Claude/Codex instruction capabilities.
#
# .DESCRIPTION
# Confirms that AGENTS.md fits the ordinary Codex limit, that trusted project
# configuration adds reserve and enables the preferred GitHub plugin, that both
# entry points retain portable review, placement, and deferral contracts, and
# that platform safety markers remain present. Optional self-tests prove that
# representative mutations fail closed.
#
# .PARAMETER SelfTest
# Runs in-memory negative tests after the repository files pass validation.
#
# .PARAMETER InputRevision
# The optional Git commit whose governed files are validation inputs. The
# validator and its executable dependencies still come from the checked-out
# trusted revision.
#
# .PARAMETER RangeBaseRevision
# The first excluded commit in an optional CI event range.
#
# .PARAMETER RangeHeadRevision
# The last included commit in an optional CI event range.
#
# .PARAMETER RangeIsNewRef
# Indicates that a push created the ref and RangeBaseRevision is Git's
# all-zero no-prior-ref sentinel.
#
# .PARAMETER RangeIsDeletedRef
# Indicates that a push deleted the ref and RangeHeadRevision is Git's
# all-zero no-remaining-ref sentinel.
#
# .PARAMETER PushApplicabilityOnly
# Returns one lowercase Boolean decision for an authenticated push range and
# stops before parser installation or repository-content validation.
#
# .PARAMETER EventName
# Identifies the authenticated GitHub event that supplied the optional range.
#
# .PARAMETER PullRequestAction
# Identifies an opened, reopened, synchronize, or base-changing edited pull
# request target event.
#
# .PARAMETER PreviousHeadRevision
# Identifies the previous topic head for a synchronize event.
#
# .PARAMETER PullRequestBaseChanged
# Contains true only when an edited pull request payload proves a base change.
#
# .PARAMETER EventHeadRevision
# Identifies the independently expanded push head commit from the webhook.
#
# .PARAMETER EventHeadDistinct
# Preserves the webhook head commit's exact true or false distinct value.
#
# .PARAMETER NewRefCommitCount
# Identifies the authenticated push size for complete new-ref evidence.
#
# .PARAMETER NewRefCommitEvidenceJson
# Contains the authenticated ordered commit identifiers for a new-ref push.
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
# [string] Success records for repository validation and optional self-tests.
#
# .NOTES
# This script does not support positional parameters.
# This validator keeps explicit backtick continuations so that large
# named-parameter mutation calls remain auditable one argument per line.
# Private helpers have focused examples. The -SelfTest suite covers edge cases.
# Version: 1.7.20260828.2

[CmdletBinding(PositionalBinding = $false)]
[OutputType([string])]
param(
    [Parameter()]
    [switch] $SelfTest,

    [Parameter()]
    [AllowEmptyString()]
    [string] $InputRevision = '',

    [Parameter()]
    [AllowEmptyString()]
    [string] $RangeBaseRevision = '',

    [Parameter()]
    [AllowEmptyString()]
    [string] $RangeHeadRevision = '',

    [Parameter()]
    [switch] $RangeIsNewRef,

    [Parameter()]
    [switch] $RangeIsDeletedRef,

    [Parameter()]
    [switch] $PushApplicabilityOnly,

    [Parameter()]
    [AllowEmptyString()]
    [string] $TrustedEventTimestamp = '',

    [Parameter()]
    [AllowEmptyString()]
    [string] $EventName = '',

    [Parameter()]
    [AllowEmptyString()]
    [string] $PullRequestAction = '',

    [Parameter()]
    [AllowEmptyString()]
    [string] $PreviousHeadRevision = '',

    [Parameter()]
    [AllowEmptyString()]
    [string] $PullRequestBaseChanged = '',

    [Parameter()]
    [AllowEmptyString()]
    [string] $EventHeadRevision = '',

    [Parameter()]
    [AllowEmptyString()]
    [string] $EventHeadDistinct = '',

    [Parameter()]
    [AllowEmptyString()]
    [string] $NewRefCommitCount = '',

    [Parameter()]
    [AllowEmptyString()]
    [string] $NewRefCommitEvidenceJson = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$intAgentsMaximumInputBytes = 32768
$intClaudeMaximumInputBytes = 131072
$intCodexConfigMaximumInputBytes = 65536
$intGitIgnoreMaximumInputBytes = 65536
$intDocsInstructionsMaximumInputBytes = 131072
$intInstructionDocumentMaximumInputBytes = 131072
$intValidatorMaximumInputBytes = 425984
$intHistoricalPolicyMarkerMaximumBytes = 524288
$intGitPathListMaximumBytes = 1048576
$intMetadataMaximumParents = 64
$strMetadataRangePolicyMarker = 'metadata-range-transition-policy-v1'
$strLintGuideMetadataPolicyMarker =
    'operational-lint-guide-metadata-policy-v1'
$strPythonPrerequisite =
    'Python 3.12 is required to validate .codex/config.toml. On Windows, ' +
    'install the Python launcher for `py -3.12`; otherwise, expose ' +
    '`python3.12`, `python3`, or `python` on PATH.'
$script:useWindowsPythonLauncher = $IsWindows
$script:pythonPathNames = @('python3.12', 'python3', 'python')
$script:objValidationUtcNow = [DateTimeOffset]::UtcNow
$script:strMaximumMetadataUtcDate = $script:objValidationUtcNow.ToString('yyyy-MM-dd')
$script:objMaximumCommitUtcTimestamp = $script:objValidationUtcNow.AddMinutes(5)
$script:arrCheckoutAttributePaths = @(
    '.gitattributes',
    '.github/.gitattributes',
    '.github/workflows/.gitattributes'
)
$script:arrOperationalLintGuidePaths = @(
    '.github/workflows/MARKDOWN-LINTING-IMPLEMENTATION.md',
    '.github/workflows/scripts-README.md'
)
$script:arrTrustRootPaths = @(
    $script:arrCheckoutAttributePaths
    '.github/workflows/Test-AgentInstructions.ps1',
    '.github/workflows/Test-AgentInstructionParserManifest.mjs',
    '.github/workflows/agent-instructions.yml'
)
$script:arrGovernedInstructionRootPaths = @(
    '.hermes.md',
    'AGENTS.md',
    'CLAUDE.md',
    'GEMINI.md',
    '.github/copilot-instructions.md'
)
$script:arrPushGovernedExactPaths = @(
    $script:arrCheckoutAttributePaths
    $script:arrOperationalLintGuidePaths
    '.codex/config.toml',
    '.github/workflows/Test-AgentInstructionParserManifest.mjs',
    '.github/workflows/Test-AgentInstructions.ps1',
    '.github/workflows/agent-instructions.yml',
    '.gitignore',
    '.npmrc',
    'docs/ISSUE_EVALUATION_PROMPT.md',
    'npm-shrinkwrap.json',
    'package-lock.json',
    'package.json'
)
$script:strDecisionRecordPathPattern =
    '^docs/decisions/[0-9]{4}-[a-z0-9]+(?:-[a-z0-9]+)*\.md$'
$script:strDecisionRecordDirectoryPathPattern = '^docs/decisions/.+$'
$script:strStandingPlacementAuthorization =
    'No additional per-round, per-session, or PR-specific direct-push authorization from the owner is required.'
$script:arrPlacementStructuralLiterals = @(
    '**Standing placement authorization.**',
    '**Outgoing-range audit.**'
)
$script:arrPlacementProseLiterals = @(
    'The agent MUST NOT ask the owner for that additional authorization.',
    'same repository',
    'non-destructive',
    'per-round ledger',
    'entire outgoing range',
    'every commit SHA and every changed path',
    'clean descendant',
    'higher-priority',
    'resulting PR-head commit SHA(s)',
    'Outside an active'
)
$script:arrSharedStructuralLiterals = @(
    '`reviewThreads`',
    '`isResolved == false`',
    '`commit_id == <round-head>`',
    'review:<review-id>:<section-label>:<ordinal>'
)
$script:arrSharedProseLiterals = @(
    '"generated N comment(s)"',
    'review-body-only finding',
    'accepted residual',
    'intentional deviation',
    'every review-submission body',
    'every PR-level comment',
    'weighted rubric',
    'ASD-STE100',
    'synthetic key',
    'GitHub Issue',
    'owner authorization',
    'current-head',
    'at least 60 seconds',
    'mutation-test',
    'PR body',
    'both reviewers'
)
$script:arrSafetyLimitContracts = @(
    [pscustomobject]@{
        DocumentName = 'AGENTS.md'
        StructuralLiteral = '- **Maximum rounds:** 8 review iterations per cycle invocation.'
        ProseLiteral = 'Maximum rounds: 8 review iterations per cycle invocation.'
        WeakStructuralLiteral = '- **Maximum rounds:** 80 review iterations per cycle invocation.'
        Failure = 'AGENTS.md is missing required Codex marker: **Maximum rounds:** 8'
    },
    [pscustomobject]@{
        DocumentName = 'AGENTS.md'
        StructuralLiteral = '- **Wall-clock timeout:** 6 hours from cycle start.'
        ProseLiteral = 'Wall-clock timeout: 6 hours from cycle start.'
        WeakStructuralLiteral = '- **Wall-clock timeout:** 60 hours from cycle start.'
        Failure = 'AGENTS.md is missing the 6-hour Codex wall-clock limit.'
    },
    [pscustomobject]@{
        DocumentName = 'CLAUDE.md'
        StructuralLiteral = '- **Maximum rounds:** 80 review iterations per loop invocation.'
        ProseLiteral = 'Maximum rounds: 80 review iterations per loop invocation.'
        WeakStructuralLiteral = '- **Maximum rounds:** 800 review iterations per loop invocation.'
        Failure = 'CLAUDE.md is missing the 80-round Claude limit.'
    },
    [pscustomobject]@{
        DocumentName = 'CLAUDE.md'
        StructuralLiteral = '- **Wall-clock timeout:** 6 hours from loop start.'
        ProseLiteral = 'Wall-clock timeout: 6 hours from loop start.'
        WeakStructuralLiteral = '- **Wall-clock timeout:** 60 hours from loop start.'
        Failure = 'CLAUDE.md is missing the 6-hour Claude wall-clock limit.'
    }
)
$script:arrObsoletePlacementLiterals = @(
    'Direct PR-head push (only with explicit user authorization)',
    'explicitly authorized direct PR-head pushes for this specific PR within the current Codex session'
)
$script:arrStyleGuideRoutingLiterals = @(
    'For an inline finding, post the prompt as a reply in the same review thread.',
    'For a review-body-only finding, post the prompt as a standalone PR-level comment that cites its synthetic key, source review, reviewed commit, and location when available.'
)
$script:arrAgentsTechnicalCodeSpans = @(
    'chatgpt-codex-connector[bot]',
    '@codex review',
    'Generated with Codex'
)
$script:arrClaudeTechnicalCodeSpans = @(
    '@codex review',
    '@claude resume review loop'
)
$script:strClaudeTechnicalProse = 'review-readiness gate'
$script:arrAgentsNormativeProseContracts = @(
    [pscustomobject]@{
        Literal = 'one at a time'
        OwnerKind = 'ProseBlock'
        OwnerPrefix = 'For each finding received from GitHub Copilot'
    },
    [pscustomobject]@{
        Literal = 'permutations'
        OwnerKind = 'ListItem'
        OwnerPrefix = 'List options. Enumerate'
    },
    [pscustomobject]@{
        Literal = 'Before posting, verify that all required artifacts are present.'
        OwnerKind = 'ListItem'
        OwnerPrefix = 'Post the evaluation. Reply to an inline thread.'
    }
)
$script:strOnlyGenuineDeferredWork = 'Only genuine deferred work requires a GitHub Issue.'
$script:arrObsoleteDeferralLiterals = @(
    'If this comment''s outcome is anything other than a fix **completed in this PR**'
)
$script:arrProhibitedDocumentationClaimLiterals = @(
    '.github/workflows/check-placeholders.yml',
    '.github/workflows/auto-fix-precommit.yml',
    '.github/ISSUE_TEMPLATE/',
    '.github/pull_request_template.md',
    'comment block at the top of `CONTRIBUTING.md`'
)
$script:arrDocumentationClaimOwnerPaths = @(
    '.github/instructions/docs.instructions.md',
    '.github/workflows/Test-AgentInstructions.ps1'
)
$script:strClaudeImportFailure =
    'CLAUDE.md must not contain active @path imports.'

#region Private helper functions

function ConvertFrom-StrictUtf8Data {
    # .SYNOPSIS
    # Decodes trusted bytes as strict UTF-8 without a byte-order mark.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [byte[]] $Bytes,

        [Parameter(Mandatory)]
        [string] $DisplayName
    )

    $arrByteOrderMarks = @(
        [byte[]] @(0xEF, 0xBB, 0xBF),
        [byte[]] @(0xFF, 0xFE, 0x00, 0x00),
        [byte[]] @(0x00, 0x00, 0xFE, 0xFF),
        [byte[]] @(0xFF, 0xFE),
        [byte[]] @(0xFE, 0xFF)
    )
    foreach ($arrByteOrderMark in $arrByteOrderMarks) {
        if ($Bytes.Length -lt $arrByteOrderMark.Length) {
            continue
        }

        $boolHasByteOrderMark = $true
        for ($intByteIndex = 0; $intByteIndex -lt $arrByteOrderMark.Length; $intByteIndex++) {
            if ($Bytes[$intByteIndex] -ne $arrByteOrderMark[$intByteIndex]) {
                $boolHasByteOrderMark = $false
                break
            }
        }
        if ($boolHasByteOrderMark) {
            throw [System.IO.InvalidDataException]::new(
                "$DisplayName must contain valid UTF-8 without a BOM."
            )
        }
    }

    try {
        return [System.Text.UTF8Encoding]::new($false, $true).GetString($Bytes)
    }
    catch [System.Text.DecoderFallbackException] {
        throw [System.IO.InvalidDataException]::new(
            "$DisplayName must contain valid UTF-8 without a BOM.",
            $_.Exception
        )
    }
}

function Assert-EncodingMutationRejected {
    # .SYNOPSIS
    # Confirms that an invalid encoding fixture fails closed.
    #
    # .DESCRIPTION
    # Decodes the supplied fixture and verifies the exact invalid-data failure.
    # The expected failure is handled and does not escape this helper.
    #
    # .PARAMETER Name
    # The fixture name to include in failure messages.
    #
    # .PARAMETER Bytes
    # The invalid encoded bytes to test.
    #
    # .EXAMPLE
    # Assert-EncodingMutationRejected -Name 'UTF-8 BOM' -Bytes $arrBytes
    #
    # # Returns no output when the fixture is rejected as expected.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # None.
    #
    # .NOTES
    # Private helper; no positional parameters.
    # Version: 1.0.20260819.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [byte[]] $Bytes
    )

    try {
        [void](ConvertFrom-StrictUtf8Data -Bytes $Bytes -DisplayName $Name)
        throw "Self-test '$Name' was accepted."
    }
    catch [System.IO.InvalidDataException] {
        $strExpectedMessage = "$Name must contain valid UTF-8 without a BOM."
        if ($_.Exception.Message -cne $strExpectedMessage) {
            throw "Self-test '$Name' returned an unexpected failure: $($_.Exception.Message)"
        }
    }
}

function Get-RepositoryInputMetadataFailure {
    # .SYNOPSIS
    # Finds unsafe repository-input metadata.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $DisplayName,

        [Parameter(Mandatory)]
        [int] $GitIndexEntryCount,

        [Parameter()]
        [AllowNull()]
        [string] $GitMode,

        [Parameter()]
        [AllowNull()]
        [string] $GitStage,

        [Parameter(Mandatory)]
        [bool] $IsFileInfo,

        [Parameter(Mandatory)]
        [System.IO.FileAttributes] $Attributes,

        [Parameter()]
        [AllowEmptyString()]
        [string] $LinkType = '',

        [Parameter()]
        [AllowEmptyString()]
        [string] $UnixMode = ''
    )

    if ($GitIndexEntryCount -ne 1) {
        Write-Output "$DisplayName must have exactly one Git index entry."
    }
    elseif (($GitMode -cne '100644') -or ($GitStage -cne '0')) {
        Write-Output "$DisplayName must be a stage-0 regular file with Git mode 100644."
    }

    if (-not $IsFileInfo) {
        Write-Output "$DisplayName must be a regular worktree file."
    }
    if (($Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        Write-Output "$DisplayName must not be a symbolic link or reparse point."
    }
    if (-not [string]::IsNullOrEmpty($LinkType)) {
        Write-Output "$DisplayName must not have a link type."
    }
    if ((-not [string]::IsNullOrEmpty($UnixMode)) -and ($UnixMode[0] -cne '-')) {
        Write-Output "$DisplayName must have a regular Unix file type."
    }
}

function Assert-RepositoryInputMetadataMutationRejected {
    # .SYNOPSIS
    # Confirms that an unsafe metadata fixture fails closed.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter()]
        [int] $GitIndexEntryCount = 1,

        [Parameter()]
        [AllowNull()]
        [string] $GitMode = '100644',

        [Parameter()]
        [AllowNull()]
        [string] $GitStage = '0',

        [Parameter()]
        [bool] $IsFileInfo = $true,

        [Parameter()]
        [System.IO.FileAttributes] $Attributes = [System.IO.FileAttributes]::Normal,

        [Parameter()]
        [AllowEmptyString()]
        [string] $LinkType = '',

        [Parameter()]
        [AllowEmptyString()]
        [string] $UnixMode = '',

        [Parameter(Mandatory)]
        [string] $Failure
    )

    $arrFailures = @(Get-RepositoryInputMetadataFailure `
            -DisplayName $Name `
            -GitIndexEntryCount $GitIndexEntryCount `
            -GitMode $GitMode `
            -GitStage $GitStage `
            -IsFileInfo $IsFileInfo `
            -Attributes $Attributes `
            -LinkType $LinkType `
            -UnixMode $UnixMode)
    if ($arrFailures.Count -eq 0) {
        throw "Self-test '$Name' was accepted."
    }
    if (-not ($arrFailures -ccontains $Failure)) {
        throw "Self-test '$Name' returned an unexpected failure: $($arrFailures -join '; ')"
    }
}

function Read-BoundedStreamData {
    # .SYNOPSIS
    # Reads a stream through a strict byte limit.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([byte])]
    param(
        [Parameter(Mandatory)]
        [System.IO.Stream] $Stream,

        [Parameter(Mandatory)]
        [ValidateRange(1, 2147483646)]
        [int] $MaximumBytes,

        [Parameter(Mandatory)]
        [string] $DisplayName,

        [Parameter()]
        [Threading.CancellationToken] $CancellationToken =
            [Threading.CancellationToken]::None
    )

    $arrBuffer = [byte[]]::new(8192)
    $objOutputStream = [System.IO.MemoryStream]::new()
    try {
        while ($objOutputStream.Length -le $MaximumBytes) {
            $intRemainingBytes = [int]([Math]::Min(
                    $arrBuffer.Length,
                    ($MaximumBytes + 1L) - $objOutputStream.Length
                ))
            try {
                $intReadBytes = if ($CancellationToken.CanBeCanceled) {
                    $Stream.ReadAsync(
                        $arrBuffer, 0, $intRemainingBytes, $CancellationToken
                    ).GetAwaiter().GetResult()
                }
                else {
                    $Stream.Read($arrBuffer, 0, $intRemainingBytes)
                }
            }
            catch [OperationCanceledException] {
                throw [TimeoutException]::new("$DisplayName timed out.", $_.Exception)
            }
            if ($intReadBytes -eq 0) {
                break
            }
            $objOutputStream.Write($arrBuffer, 0, $intReadBytes)
        }

        if ($objOutputStream.Length -gt $MaximumBytes) {
            throw [System.IO.InvalidDataException]::new(
                "$DisplayName must not exceed $MaximumBytes bytes."
            )
        }

        return $objOutputStream.ToArray()
    }
    finally {
        $objOutputStream.Dispose()
    }
}

function Read-BoundedProcessData {
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory)][Diagnostics.Process] $Process,
        [Parameter(Mandatory)][ValidateRange(1, 2147483646)][int] $MaximumBytes,
        [Parameter(Mandatory)][ValidateRange(1, 60000)][int] $TimeoutMilliseconds,
        [Parameter(Mandatory)][string] $DisplayName
    )
    if ($Process.StartInfo.UseShellExecute -or
        -not $Process.StartInfo.RedirectStandardOutput -or
        -not $Process.StartInfo.RedirectStandardError) {
        throw "$DisplayName requires shell-free redirected process streams."
    }
    $objCancel = [Threading.CancellationTokenSource]::new($TimeoutMilliseconds)
    $objTimer = [Diagnostics.Stopwatch]::StartNew()
    $boolRan = $false
    $objErrorTask = $null
    try {
        if (-not $Process.Start()) {
            throw "Could not start $DisplayName."
        }
        $boolRan = $true
        $objErrorTask = $Process.StandardError.ReadToEndAsync()
        $arrBytes = Read-BoundedStreamData `
            -Stream $Process.StandardOutput.BaseStream `
            -MaximumBytes $MaximumBytes `
            -DisplayName $DisplayName `
            -CancellationToken $objCancel.Token
        $intRemaining = [Math]::Max(
            0, $TimeoutMilliseconds - [int]$objTimer.ElapsedMilliseconds)
        if (-not $Process.WaitForExit($intRemaining)) {
            throw [TimeoutException]::new("$DisplayName timed out.")
        }
        [void]$objErrorTask.GetAwaiter().GetResult()
        return [pscustomobject]@{Bytes=$arrBytes;ExitCode=$Process.ExitCode}
    }
    catch {
        $objFailure = $_.Exception
        if ($boolRan) {
            if (-not $Process.HasExited) {
                $Process.Kill($true)
            }
            if (-not $Process.WaitForExit(5000)) {
                throw "$DisplayName could not be reaped after failure."
            }
            if ($null -ne $objErrorTask) {
                try { [void]$objErrorTask.GetAwaiter().GetResult() } catch { [void]$_ }
            }
        }
        throw $objFailure
    }
    finally {
        $objTimer.Stop()
        $objCancel.Dispose()
        $Process.Dispose()
    }
}

function ConvertFrom-GitPathListData {
    # .SYNOPSIS
    # Decodes a NUL-delimited Git path list.
    #
    # .DESCRIPTION
    # Requires strict UTF-8, a terminal NUL, nonempty path records, and unique
    # paths by default. Commit-range path-touch output can opt into duplicates
    # because one path can be changed by more than one commit in the same range.
    #
    # .PARAMETER Bytes
    # The bounded raw bytes produced by a Git path-list command.
    #
    # .PARAMETER AllowDuplicatePath
    # Allows repeated ordinal path records while retaining every other check.
    #
    # .EXAMPLE
    # ConvertFrom-GitPathListData -Bytes $arrGitOutput
    #
    # # Returns each unique decoded tracked path.
    #
    # .EXAMPLE
    # ConvertFrom-GitPathListData -Bytes $arrRangeOutput -AllowDuplicatePath
    #
    # # Returns repeated commit-range path touches in their original order.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [string] Zero or more decoded repository-relative paths.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Positional parameters are disabled. Internal callers must use named
    # parameters. Version: 1.1.20260828.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [byte[]] $Bytes,

        [Parameter()]
        [switch] $AllowDuplicatePath
    )

    if ($Bytes.Length -eq 0) {
        return [string[]] @()
    }
    if ($Bytes[-1] -ne 0) {
        throw [IO.InvalidDataException]::new('Git path list must end with a NUL byte.')
    }

    $listPaths = [Collections.Generic.List[string]]::new()
    $setPaths = [Collections.Generic.HashSet[string]]::new(
        [StringComparer]::Ordinal
    )
    $intRecordStart = 0
    for ($intByteIndex = 0; $intByteIndex -lt $Bytes.Length; $intByteIndex++) {
        if ($Bytes[$intByteIndex] -ne 0) {
            continue
        }
        if ($intByteIndex -eq $intRecordStart) {
            throw [IO.InvalidDataException]::new('Git path list contains an empty path.')
        }
        $arrPathBytes = $Bytes[$intRecordStart..($intByteIndex - 1)]
        $strPath = ConvertFrom-StrictUtf8Data `
            -Bytes $arrPathBytes -DisplayName 'Git path'
        if (-not $setPaths.Add($strPath) -and -not $AllowDuplicatePath) {
            throw [IO.InvalidDataException]::new('Git path list contains a duplicate path.')
        }
        $listPaths.Add($strPath)
        $intRecordStart = $intByteIndex + 1
    }
    return $listPaths.ToArray()
}

function Read-GitTrackedPath {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $RepositoryRootPath,

        [Parameter()]
        [AllowEmptyString()]
        [string] $Revision = '',

        [Parameter(Mandatory)]
        [ValidateRange(1, 2147483646)]
        [int] $MaximumBytes
    )

    $arrArguments = if ([string]::IsNullOrEmpty($Revision)) {
        @('-C', $RepositoryRootPath, 'ls-files', '--cached', '-z')
    }
    else {
        @('-C', $RepositoryRootPath, 'ls-tree', '-r', '-z', '--name-only', $Revision)
    }
    $objStartInfo = [Diagnostics.ProcessStartInfo]::new('git')
    $objStartInfo.UseShellExecute = $false
    $objStartInfo.CreateNoWindow = $true
    $objStartInfo.RedirectStandardOutput = $true
    $objStartInfo.RedirectStandardError = $true
    foreach ($strArgument in $arrArguments) {
        $objStartInfo.ArgumentList.Add($strArgument)
    }

    $objGitProcess = [Diagnostics.Process]::new()
    $objGitProcess.StartInfo = $objStartInfo
    $objProcessResult = Read-BoundedProcessData `
        -Process $objGitProcess `
        -MaximumBytes $MaximumBytes `
        -TimeoutMilliseconds 10000 `
        -DisplayName 'Git tracked-path enumeration'
    if ($objProcessResult.ExitCode -ne 0) {
        throw 'Could not enumerate tracked files for the governed instruction inventory.'
    }
    return ConvertFrom-GitPathListData -Bytes $objProcessResult.Bytes
}

function Read-RepositoryInputData {
    # .SYNOPSIS
    # Reads one governed repository file safely.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([byte])]
    param(
        [Parameter(Mandatory)]
        [string] $Path,

        [Parameter(Mandatory)]
        [string] $RepositoryRootPath,

        [Parameter(Mandatory)]
        [string] $RepositoryRelativePath,

        [Parameter(Mandatory)]
        [string] $DisplayName,

        [Parameter(Mandatory)]
        [ValidateRange(1, 2147483646)]
        [int] $MaximumBytes
    )

    $arrGitIndexEntries = @(& git -C $RepositoryRootPath ls-files --stage -- $RepositoryRelativePath 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "Could not inspect the Git index entry for $DisplayName`: $($arrGitIndexEntries -join ' ')"
    }

    $strGitMode = $null
    $strGitStage = $null
    if ($arrGitIndexEntries.Count -eq 1) {
        $objGitIndexMatch = [regex]::Match(
            [string] $arrGitIndexEntries[0],
            '^(?<Mode>[0-7]{6}) [0-9a-f]+ (?<Stage>[0-3])\t'
        )
        if ($objGitIndexMatch.Success) {
            $strGitMode = $objGitIndexMatch.Groups['Mode'].Value
            $strGitStage = $objGitIndexMatch.Groups['Stage'].Value
        }
    }

    $strResolvedInputPath =
        $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    $objInputItem = Get-Item -Force -LiteralPath $strResolvedInputPath
    $objLinkTypeProperty = $objInputItem.PSObject.Properties['LinkType']
    $strLinkType = if ($null -eq $objLinkTypeProperty) { '' } else { [string] $objLinkTypeProperty.Value }
    $objUnixModeProperty = $objInputItem.PSObject.Properties['UnixMode']
    $strUnixMode = if ($null -eq $objUnixModeProperty) { '' } else { [string] $objUnixModeProperty.Value }
    $arrMetadataFailures = @(Get-RepositoryInputMetadataFailure `
            -DisplayName $DisplayName `
            -GitIndexEntryCount $arrGitIndexEntries.Count `
            -GitMode $strGitMode `
            -GitStage $strGitStage `
            -IsFileInfo ($objInputItem -is [System.IO.FileInfo]) `
            -Attributes $objInputItem.Attributes `
            -LinkType $strLinkType `
            -UnixMode $strUnixMode)
    if ($arrMetadataFailures.Count -gt 0) {
        throw "Repository input is unsafe:`n- $($arrMetadataFailures -join "`n- ")"
    }

    $objInputStream = [System.IO.FileStream]::new(
        $strResolvedInputPath,
        [System.IO.FileMode]::Open,
        [System.IO.FileAccess]::Read,
        [System.IO.FileShare]::Read
    )
    try {
        return Read-BoundedStreamData `
            -Stream $objInputStream `
            -MaximumBytes $MaximumBytes `
            -DisplayName $DisplayName
    }
    finally {
        $objInputStream.Dispose()
    }
}

function Read-GitRevisionText {
    # .SYNOPSIS
    # Reads one bounded UTF-8 file from a Git revision.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $RepositoryRootPath,

        [Parameter(Mandatory)]
        [string] $Revision,

        [Parameter(Mandatory)]
        [string] $RepositoryRelativePath,

        [Parameter(Mandatory)]
        [ValidateRange(1, 2147483646)]
        [int] $MaximumBytes,

        [Parameter()]
        [switch] $RequireRegularFile
    )

    if ($RequireRegularFile) {
        $arrTreeEntries = @(& git -C $RepositoryRootPath ls-tree `
                $Revision -- $RepositoryRelativePath 2>&1)
        if ($LASTEXITCODE -ne 0) {
            throw "Could not inspect $Revision`:$RepositoryRelativePath in Git."
        }
        $strExpectedEntryPattern =
            '^100644 blob (?:[0-9a-fA-F]{40}|[0-9a-fA-F]{64})\t' +
            [regex]::Escape($RepositoryRelativePath) + '$'
        if ($arrTreeEntries.Count -ne 1 -or
            [string]$arrTreeEntries[0] -notmatch $strExpectedEntryPattern) {
            throw "Git revision input is not one regular 100644 blob: $Revision`:$RepositoryRelativePath"
        }
    }

    $objStartInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $objStartInfo.FileName = 'git'
    $objStartInfo.UseShellExecute = $false
    $objStartInfo.CreateNoWindow = $true
    $objStartInfo.RedirectStandardOutput = $true
    $objStartInfo.RedirectStandardError = $true
    foreach ($strArgument in @(
            '-C',
            $RepositoryRootPath,
            'cat-file',
            'blob',
            "${Revision}:$RepositoryRelativePath"
        )) {
        $objStartInfo.ArgumentList.Add($strArgument)
    }

    $objGitProcess = [System.Diagnostics.Process]::new()
    $objGitProcess.StartInfo = $objStartInfo
    $objProcessResult = Read-BoundedProcessData `
        -Process $objGitProcess `
        -MaximumBytes $MaximumBytes `
        -TimeoutMilliseconds 10000 `
        -DisplayName "$Revision`:$RepositoryRelativePath"
    if ($objProcessResult.ExitCode -ne 0) {
        throw "Could not read $Revision`:$RepositoryRelativePath from Git."
    }
    return ConvertFrom-StrictUtf8Data `
        -Bytes $objProcessResult.Bytes `
        -DisplayName "$Revision`:$RepositoryRelativePath"
}

function Test-HistoricalPolicyMarker {
    # .SYNOPSIS
    # Tests whether a revision file contains an ordinal literal.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string] $RepositoryRootPath,

        [Parameter(Mandatory)]
        [string] $Revision,

        [Parameter(Mandatory)]
        [string] $RepositoryRelativePath,

        [Parameter(Mandatory)]
        [string] $Literal
    )

    & git -C $RepositoryRootPath cat-file -e `
        "$Revision`:$RepositoryRelativePath" 2>$null
    if ($LASTEXITCODE -ne 0) {
        return $false
    }

    $strRevisionContent = Read-GitRevisionText `
        -RepositoryRootPath $RepositoryRootPath `
        -Revision $Revision `
        -RepositoryRelativePath $RepositoryRelativePath `
        -MaximumBytes $intHistoricalPolicyMarkerMaximumBytes `
        -RequireRegularFile
    return $strRevisionContent.Contains($Literal, [StringComparison]::Ordinal)
}

function Get-GovernedDocumentParentContext {
    # .SYNOPSIS
    # Gets the worktree or first-parent comparison for one governed document.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [string] $RepositoryRootPath,

        [Parameter(Mandatory)]
        [string] $RepositoryRelativePath,

        [Parameter(Mandatory)]
        [ValidateRange(1, 2147483646)]
        [int] $MaximumBytes,

        [Parameter()]
        [AllowEmptyString()]
        [string] $Revision = ''
    )

    if (-not [string]::IsNullOrEmpty($Revision)) {
        if ($Revision -notmatch '^(?:[0-9a-fA-F]{40}|[0-9a-fA-F]{64})$') {
            throw "The governed-document input revision is invalid: $Revision"
        }
        & git -C $RepositoryRootPath cat-file -e "$Revision`^{commit}" 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "The governed-document input commit is unavailable: $Revision"
        }
        $strParentRevision = "$Revision`^1"
        & git -C $RepositoryRootPath cat-file -e `
            "$strParentRevision`^{commit}" 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "The governed-document input commit has no first parent: $Revision"
        }
        & git -C $RepositoryRootPath cat-file -e `
            "$strParentRevision`:$RepositoryRelativePath" 2>$null
        $strParentContent = if ($LASTEXITCODE -eq 0) {
            Read-GitRevisionText `
                -RepositoryRootPath $RepositoryRootPath `
                -Revision $strParentRevision `
                -RepositoryRelativePath $RepositoryRelativePath `
                -MaximumBytes $MaximumBytes `
                -RequireRegularFile
        }
        else {
            $null
        }
        return [pscustomobject]@{
            ParentContent = $strParentContent
            ExpectedUtcDate = ''
            ParentRevision = $strParentRevision
            IsWorktreeTransition = $false
        }
    }

    & git -C $RepositoryRootPath diff --quiet HEAD -- $RepositoryRelativePath
    $intDiffExitCode = $LASTEXITCODE
    if ($intDiffExitCode -notin @(0, 1)) {
        throw "Could not compare $RepositoryRelativePath with HEAD."
    }

    if ($intDiffExitCode -eq 1) {
        $strParentRevision = 'HEAD'
        $strExpectedUtcDate = [DateTimeOffset]::UtcNow.ToString('yyyy-MM-dd')
    }
    else {
        $strParentRevision = 'HEAD^'
        $strExpectedUtcDate = ''
    }

    & git -C $RepositoryRootPath cat-file -e `
        "$strParentRevision`:$RepositoryRelativePath" 2>$null
    $strParentContent = if ($LASTEXITCODE -eq 0) {
        Read-GitRevisionText `
            -RepositoryRootPath $RepositoryRootPath `
            -Revision $strParentRevision `
            -RepositoryRelativePath $RepositoryRelativePath `
            -MaximumBytes $MaximumBytes `
            -RequireRegularFile
    }
    else {
        $null
    }
    return [pscustomobject]@{
        ParentContent = $strParentContent
        ExpectedUtcDate = $strExpectedUtcDate
        ParentRevision = $strParentRevision
        IsWorktreeTransition = $intDiffExitCode -eq 1
    }
}

function Assert-OversizedStreamMutationRejected {
    # .SYNOPSIS
    # Confirms that bounded stream and child-process reads fail closed.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param()

    $objOversizedStream = [System.IO.MemoryStream]::new([byte[]] @(1, 2, 3, 4, 5))
    try {
        [void](Read-BoundedStreamData `
                -Stream $objOversizedStream `
                -MaximumBytes 4 `
                -DisplayName 'oversized stream mutation')
        throw "Self-test 'oversized stream mutation' was accepted."
    }
    catch [System.IO.InvalidDataException] {
        $strExpectedMessage = 'oversized stream mutation must not exceed 4 bytes.'
        if ($_.Exception.Message -cne $strExpectedMessage) {
            throw "Self-test 'oversized stream mutation' returned an unexpected failure: $($_.Exception.Message)"
        }
    }
    finally {
        $objOversizedStream.Dispose()
    }

    $arrProcessCases = @(
        @{N='stalled process read';C='Start-Sleep -Seconds 5';T=250;E=[TimeoutException]},
        @{
            N = 'oversized process read'
            C = '[Console]::OpenStandardOutput().Write([byte[]]::new(1024)); Start-Sleep -Seconds 5'
            T = 3000
            E = [IO.InvalidDataException]
        },
        @{
            N = 'concurrent process error drain'
            C = "[Console]::Error.Write('e' * 131072); [Console]::OpenStandardOutput().Write([byte[]]@(97,0)); exit 7"
            T = 5000
            E = $null
        })
    foreach ($objProcessCase in $arrProcessCases) {
        $objStartInfo = [Diagnostics.ProcessStartInfo]::new([Environment]::ProcessPath)
        $objStartInfo.UseShellExecute = $false
        $objStartInfo.CreateNoWindow = $true
        $objStartInfo.RedirectStandardOutput = $true
        $objStartInfo.RedirectStandardError = $true
        foreach ($strArgument in @(
                '-NoLogo', '-NoProfile', '-NonInteractive', '-Command',
                $objProcessCase.C
            )) {
            $objStartInfo.ArgumentList.Add($strArgument)
        }
        $objProcess = [Diagnostics.Process]::new()
        $objProcess.StartInfo = $objStartInfo
        $objTimer = [Diagnostics.Stopwatch]::StartNew()
        try {
            $objResult = Read-BoundedProcessData `
                -Process $objProcess `
                -MaximumBytes 4 `
                -TimeoutMilliseconds $objProcessCase.T `
                -DisplayName $objProcessCase.N
            if ($null -ne $objProcessCase.E) {
                throw "Self-test '$($objProcessCase.N)' was accepted."
            }
            if ($objResult.ExitCode -ne 7 -or $objResult.Bytes.Length -ne 2 -or
                $objResult.Bytes[0] -ne 97 -or $objResult.Bytes[1] -ne 0) {
                throw "Self-test '$($objProcessCase.N)' changed output."
            }
        }
        catch {
            if ($null -eq $objProcessCase.E -or
                -not $objProcessCase.E.IsAssignableFrom($_.Exception.GetType())) {
                throw
            }
        }
        finally {
            $objTimer.Stop()
        }
        if ($objTimer.ElapsedMilliseconds -ge 4000) {
            throw "Self-test '$($objProcessCase.N)' exceeded its cleanup deadline."
        }
    }
}

function Get-TomlParseContext {
    # .SYNOPSIS
    # Gets a safe typed TOML parse context.
    #
    # .DESCRIPTION
    # Resolves Python 3.12, parses in isolated mode, and validates a fixed JSON
    # projection of the required TOML values and statement positions.
    #
    # .PARAMETER Content
    # The TOML text to validate.
    #
    # .EXAMPLE
    # Get-TomlParseContext -Content 'project_doc_max_bytes = 65536'
    #
    # # Returns typed context for valid TOML.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [pscustomobject] A failure and validated typed TOML context.
    #
    # .NOTES
    # Private helper; no positional parameters.
    # Version: 1.3.20260828.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [string] $Content
    )

    $objContext = [ordered]@{
        Failure = ''
        CapacityPresent = $false
        CapacityType = 'missing'
        CapacityFitsInt64 = $false
        CapacityValue = [int64]0
        PluginTablePresent = $false
        PluginTableType = 'missing'
        PluginEnabledPresent = $false
        PluginEnabledType = 'missing'
        PluginEnabledValue = $false
        CapacityIsFirstStatement = $false
        PluginHeaderIsSecondStatement = $false
        PluginEnablementIsThirdStatement = $false
        PluginEnabledValueStatementOffset = -1
        PluginEnabledValueLength = 0
    }

    $listPythonCandidates = [Collections.Generic.List[pscustomobject]]::new()
    if ($IsWindows -and $script:useWindowsPythonLauncher) {
        $strLauncher = Join-Path ([Environment]::GetFolderPath(
                [Environment+SpecialFolder]::Windows)) 'py.exe'
        if (Test-Path -LiteralPath $strLauncher -PathType Leaf) {
            $listPythonCandidates.Add([pscustomobject]@{
                    Path = $strLauncher; Arguments = [string[]] @('-3.12') })
        }
    }
    foreach ($strName in $script:pythonPathNames) {
        $objCommand = Get-Command -Name $strName -CommandType Application `
            -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($null -ne $objCommand) {
            $listPythonCandidates.Add([pscustomobject]@{
                    Path = [IO.Path]::GetFullPath([string] $objCommand.Source)
                    Arguments = [string[]] @() })
        }
    }
    $objPythonCommand = $null
    $setPythonPaths = [Collections.Generic.HashSet[string]]::new($(if ($IsWindows) {
                [StringComparer]::OrdinalIgnoreCase
            } else { [StringComparer]::Ordinal }))
    foreach ($objCandidate in $listPythonCandidates) {
        if (-not $setPythonPaths.Add($objCandidate.Path)) { continue }
        $objProbeInfo = [Diagnostics.ProcessStartInfo]::new($objCandidate.Path)
        $objProbeInfo.UseShellExecute = $false
        $objProbeInfo.CreateNoWindow = $true
        $objProbeInfo.RedirectStandardOutput = $true
        $objProbeInfo.RedirectStandardError = $true
        foreach ($strArgument in @($objCandidate.Arguments) + @(
                '-I', '-S', '-c',
                'import sys;sys.stdout.write("3.12" if sys.version_info[:2]==(3,12) else "")'
            )) { $objProbeInfo.ArgumentList.Add($strArgument) }
        $objProbe = [Diagnostics.Process]::new()
        $objProbe.StartInfo = $objProbeInfo
        try {
            $objProbeResult = Read-BoundedProcessData -Process $objProbe `
                -MaximumBytes 4 -TimeoutMilliseconds 5000 `
                -DisplayName 'Python 3.12 prerequisite probe'
            if ($objProbeResult.ExitCode -eq 0 -and
                [Text.Encoding]::UTF8.GetString($objProbeResult.Bytes) -ceq '3.12') {
                $objPythonCommand = $objCandidate
                break
            }
        } catch { continue }
    }
    if ($null -eq $objPythonCommand) {
        $objContext.Failure = $strPythonPrerequisite
        return [pscustomobject]$objContext
    }
    $strPythonPath = $objPythonCommand.Path

    $strPythonProgram = @'
import json,re,sys
if sys.version_info[:2]!=(3,12):sys.exit(78)
import tomllib
c=sys.stdin.read();d=tomllib.loads(c);l=[];e=[];o=0
for x in c.splitlines(keepends=True):
 t=x[:-2] if x.endswith("\r\n") else x[:-1] if x.endswith("\n") else x;o+=len(x);s=t.lstrip()
 if s and not s.startswith("#"):l.append(t);e.append(o)
def p(n):
 if len(e)<n:return None
 try:return tomllib.loads(c[:e[n-1]])
 except tomllib.TOMLDecodeError:return None
def g(x,k):return x.get(k) if type(x)is dict else None
a=p(1);b=p(2);f=p(3);a1=type(a)is dict and set(a)=={"project_doc_max_bytes"}
bp=g(b,"plugins");bt=g(bp,"github@openai-curated")
h=len(l)>1 and l[1].lstrip().startswith("[") and not l[1].lstrip().startswith("[[")
h=a1 and h and type(b)is dict and set(b)=={"project_doc_max_bytes","plugins"} and type(bp)is dict and set(bp)=={"github@openai-curated"} and bt=={}
fp=g(f,"plugins");ft=g(fp,"github@openai-curated")
v=len(l)>2 and not l[2].lstrip().startswith("[")
v=h and v and type(f)is dict and set(f)=={"project_doc_max_bytes","plugins"} and type(fp)is dict and set(fp)=={"github@openai-curated"} and type(ft)is dict and set(ft)=={"enabled"} and type(ft.get("enabled"))is bool
vo=-1;vl=0
if v:
 q=l[2].find("=");m=re.fullmatch(r"\s*(true|false)\s*(?:#.*)?",l[2][q+1:]) if q>=0 else None
 if m is None:v=False
 else:vo=q+1+m.start(1);vl=len(m.group(1))
cp="project_doc_max_bytes" in d;cv=d.get("project_doc_max_bytes");ps=d.get("plugins");tb=g(ps,"github@openai-curated")
tp=type(ps)is dict and "github@openai-curated" in ps;ep=type(tb)is dict and "enabled" in tb;ev=g(tb,"enabled")
r=dict(a=cp,b=type(cv).__name__ if cp else "missing",c=str(cv) if type(cv)is int else None,d=tp,e=type(tb).__name__ if tp else "missing",f=ep,g=type(ev).__name__ if ep else "missing",h=ev if type(ev)is bool else None,i=a1,j=h,k=v,l=vo,m=vl)
print(json.dumps(r,separators=(",",":"),sort_keys=True))
'@

    $arrPythonArguments = [Collections.Generic.List[string]]::new()
    foreach ($strPythonArgument in $objPythonCommand.Arguments) {
        $arrPythonArguments.Add($strPythonArgument)
    }
    foreach ($strPythonArgument in @(
            '-I',
            '-S',
            '-c',
            $strPythonProgram
        )) {
        $arrPythonArguments.Add($strPythonArgument)
    }

    $objStartInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $objStartInfo.FileName = $strPythonPath
    $objStartInfo.UseShellExecute = $false
    $objStartInfo.CreateNoWindow = $true
    $objStartInfo.RedirectStandardInput = $true
    $objStartInfo.RedirectStandardOutput = $true
    $objStartInfo.RedirectStandardError = $true
    $objStartInfo.StandardInputEncoding = [System.Text.UTF8Encoding]::new($false)
    $objStartInfo.StandardOutputEncoding = [System.Text.UTF8Encoding]::new($false)
    $objStartInfo.StandardErrorEncoding = [System.Text.UTF8Encoding]::new($false)
    foreach ($strPythonArgument in $arrPythonArguments) {
        $objStartInfo.ArgumentList.Add($strPythonArgument)
    }

    $strParserOutput = ''
    $objParserProcess = [System.Diagnostics.Process]::new()
    $objParserProcess.StartInfo = $objStartInfo
    try {
        if (-not $objParserProcess.Start()) {
            $objContext.Failure = $strPythonPrerequisite
            return [pscustomobject]$objContext
        }

        $objStandardOutputTask = $objParserProcess.StandardOutput.ReadToEndAsync()
        $objStandardErrorTask = $objParserProcess.StandardError.ReadToEndAsync()
        $objParserProcess.StandardInput.Write($Content)
        $objParserProcess.StandardInput.Close()
        if (-not $objParserProcess.WaitForExit(10000)) {
            $objParserProcess.Kill($true)
            [void]$objParserProcess.WaitForExit(1000)
            $objContext.Failure = 'TOML validation must complete within 10 seconds.'
            return [pscustomobject]$objContext
        }

        $strParserOutput = $objStandardOutputTask.GetAwaiter().GetResult()
        $strParserError = $objStandardErrorTask.GetAwaiter().GetResult()
        if ($objParserProcess.ExitCode -ne 0) {
            $objContext.Failure = if ($objParserProcess.ExitCode -eq 78) {
                $strPythonPrerequisite
            }
            else {
                'The project configuration must contain valid TOML.'
            }
            return [pscustomobject]$objContext
        }
        if (-not [string]::IsNullOrEmpty($strParserError)) {
            $objContext.Failure = 'The trusted TOML parser returned unexpected error output.'
            return [pscustomobject]$objContext
        }
    }
    catch {
        $objContext.Failure = $strPythonPrerequisite
        return [pscustomobject]$objContext
    }
    finally {
        $objParserProcess.Dispose()
    }

    if ([Text.Encoding]::UTF8.GetByteCount($strParserOutput) -gt 4096) {
        $objContext.Failure = 'The trusted TOML parser returned oversized typed context.'
        return [pscustomobject]$objContext
    }

    try {
        $objParserContext = $strParserOutput | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        $objContext.Failure = 'The trusted TOML parser returned invalid typed context.'
        return [pscustomobject]$objContext
    }

    $arrExpectedProperties = @('a', 'b', 'c', 'd', 'e', 'f', 'g',
        'h', 'i', 'j', 'k', 'l', 'm')
    $arrActualProperties = @($objParserContext.PSObject.Properties.Name)
    if ($arrActualProperties.Count -ne $arrExpectedProperties.Count -or
        @(Compare-Object $arrExpectedProperties $arrActualProperties).Count -ne 0 -or
        $objParserContext.a -isnot [bool] -or $objParserContext.b -isnot [string] -or
        ($null -ne $objParserContext.c -and $objParserContext.c -isnot [string]) -or
        $objParserContext.d -isnot [bool] -or $objParserContext.e -isnot [string] -or
        $objParserContext.f -isnot [bool] -or $objParserContext.g -isnot [string] -or
        ($null -ne $objParserContext.h -and $objParserContext.h -isnot [bool]) -or
        $objParserContext.i -isnot [bool] -or $objParserContext.j -isnot [bool] -or
        $objParserContext.k -isnot [bool] -or $objParserContext.l -isnot [int64] -or
        $objParserContext.m -isnot [int64] -or $objParserContext.l -lt -1 -or
        $objParserContext.l -gt $Content.Length -or $objParserContext.m -lt 0 -or
        $objParserContext.m -gt 5 -or
        ($objParserContext.k -and ($objParserContext.l -lt 0 -or
                $objParserContext.m -notin @(4, 5))) -or
        (-not $objParserContext.k -and ($objParserContext.l -ne -1 -or
                $objParserContext.m -ne 0))) {
        $objContext.Failure = 'The trusted TOML parser returned invalid typed context.'
        return [pscustomobject]$objContext
    }

    $objContext.CapacityPresent = $objParserContext.a
    $objContext.CapacityType = $objParserContext.b
    if ($objParserContext.b -ceq 'int' -and $objParserContext.c -is [string]) {
        $intCapacityValue = [int64]0
        $objContext.CapacityFitsInt64 = [int64]::TryParse(
            $objParserContext.c,
            [System.Globalization.NumberStyles]::AllowLeadingSign,
            [System.Globalization.CultureInfo]::InvariantCulture,
            [ref] $intCapacityValue
        )
        if ($objContext.CapacityFitsInt64) {
            $objContext.CapacityValue = $intCapacityValue
        }
    }
    $objContext.PluginTablePresent = $objParserContext.d
    $objContext.PluginTableType = $objParserContext.e
    $objContext.PluginEnabledPresent = $objParserContext.f
    $objContext.PluginEnabledType = $objParserContext.g
    if ($objParserContext.h -is [bool]) {
        $objContext.PluginEnabledValue = $objParserContext.h
    }
    $objContext.CapacityIsFirstStatement = $objParserContext.i
    $objContext.PluginHeaderIsSecondStatement = $objParserContext.j
    $objContext.PluginEnablementIsThirdStatement = $objParserContext.k
    $objContext.PluginEnabledValueStatementOffset = [int]$objParserContext.l
    $objContext.PluginEnabledValueLength = [int]$objParserContext.m

    return [pscustomobject]$objContext
}

function Get-MarkdownParseContext {
    # .SYNOPSIS
    # Parses Markdown into trusted structural context.
    #
    # .DESCRIPTION
    # Uses the repository-locked markdown-it package to identify code-block ranges,
    # prose blocks with operative code spans, top-level blocks, top-level list
    # items, and level-two headings.
    # It validates all parser output before returning it.
    #
    # .PARAMETER Content
    # The Markdown text to parse.
    #
    # .PARAMETER LineCount
    # The source line count used to bound parser ranges.
    #
    # .EXAMPLE
    # Get-MarkdownParseContext -Content $strMarkdown -LineCount $arrLines.Count
    #
    # # Returns validated Markdown block, list-item, and prose context.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [pscustomobject] The validated Markdown parse context.
    #
    # .NOTES
    # Private helper; no positional parameters.
    # Version: 1.2.20260820.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Content,

        [Parameter(Mandatory)]
        [ValidateRange(1, 2147483647)]
        [int] $LineCount
    )

    $strRepositoryRootPath = [IO.Path]::GetDirectoryName(
        [IO.Path]::GetDirectoryName($PSScriptRoot)
    )
    $strMarkdownParserPath = Join-Path `
        -Path $strRepositoryRootPath `
        -ChildPath 'node_modules/markdown-it/package.json'
    if (-not (Test-Path -LiteralPath $strMarkdownParserPath -PathType Leaf)) {
        throw 'The locked markdown-it package is required to validate operative Markdown.'
    }

    $objNodeCommand = Get-Command `
        -Name 'node' `
        -CommandType Application `
        -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($null -eq $objNodeCommand) {
        throw 'A trusted Node.js runtime is required to validate operative Markdown.'
    }

    $strNodeProgram = @(
        'const fs = require("node:fs");'
        'const MarkdownIt = require("markdown-it");'
        'const input = fs.readFileSync(0, "utf8");'
        'const tokens = new MarkdownIt({ html: true }).parse(input, {});'
        'const inlineHtmlTagPattern = /^<\s*(\/?)\s*([A-Za-z][A-Za-z0-9:-]*)(?=[\s/>])/;'
        'const voidHtmlTags = new Set(["area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"]);'
        'const getOperativeInlineContext = (children) => {'
        '  const deletionStack = [];'
        '  const htmlContainerStack = [];'
        '  const output = [];'
        '  const code = [];'
        '  for (const child of children) {'
        '    if (child.type === "s_open" || child.type === "s_close") {'
        '      const isOpening = child.type === "s_open";'
        '      if (child.tag !== "s" || child.nesting !== (isOpening ? 1 : -1)) throw new Error("Invalid Markdown deletion token.");'
        '      if (isOpening) deletionStack.push("s");'
        '      else if (deletionStack.pop() !== "s") throw new Error("Unbalanced Markdown deletion token.");'
        '      continue;'
        '    }'
        '    if (child.type === "html_inline") {'
        '      const htmlTag = inlineHtmlTagPattern.exec(child.content);'
        '      if (htmlTag) {'
        '        const tagName = htmlTag[2].toLowerCase();'
        '        const isClosing = htmlTag[1] === "/";'
        '        if (voidHtmlTags.has(tagName)) {'
        '          if (isClosing) throw new Error("Invalid closing HTML void tag.");'
        '        } else if (!isClosing) {'
        '          htmlContainerStack.push(tagName);'
        '        } else if (htmlContainerStack.pop() !== tagName) {'
        '          throw new Error("Unbalanced inline HTML container.");'
        '        }'
        '        continue;'
        '      }'
        '    }'
        '    if (deletionStack.length > 0 || htmlContainerStack.length > 0) continue;'
        '    if (child.type === "text" || child.type === "text_special") output.push(child.content);'
        '    else if (child.type === "softbreak" || child.type === "hardbreak") output.push("\n");'
        '    else if (child.type === "code_inline") code.push(child.content);'
        '  }'
        '  if (deletionStack.length > 0) throw new Error("Unclosed deletion container.");'
        '  if (htmlContainerStack.length > 0) throw new Error("Unclosed inline HTML container.");'
        '  return { text: output.join(""), code };'
        '};'
        'const codeBlockRanges = tokens.filter((token) => token.type === "fence" || token.type === "code_block").map((token) => token.map);'
        'const proseBlocks = tokens.filter((token) => token.type === "inline" && Array.isArray(token.map) && Array.isArray(token.children)).map((token) => ({ range: token.map, ...getOperativeInlineContext(token.children) }));'
        'const topLevelBlocks = tokens.flatMap((token, index) => {'
        '  if (token.level !== 0 || !Array.isArray(token.map) || (token.nesting !== 0 && token.nesting !== 1)) return [];'
        '  let text = null;'
        '  if (token.type === "heading_open" || token.type === "paragraph_open") {'
        '    const inlineToken = tokens[index + 1];'
        '    if (inlineToken?.type !== "inline" || !Array.isArray(inlineToken.children)) throw new Error("Invalid top-level inline container.");'
        '    text = getOperativeInlineContext(inlineToken.children).text;'
        '  }'
        '  return [{ type: token.type, tag: token.tag, range: token.map, text }];'
        '});'
        'const topLevelListItems = tokens.flatMap((token, index) => {'
        '  if (token.type !== "list_item_open" || token.tag !== "li" || token.level !== 1 || !Array.isArray(token.map)) return [];'
        '  const closeIndex = tokens.findIndex((candidate, candidateIndex) => candidateIndex > index && candidate.type === "list_item_close" && candidate.tag === "li" && candidate.level === 1);'
        '  if (closeIndex < 0) throw new Error("Unclosed top-level list item.");'
        '  const inlineToken = tokens.slice(index + 1, closeIndex).find((candidate) => candidate.type === "inline" && candidate.level === 3 && Array.isArray(candidate.children));'
        '  const context = inlineToken ? getOperativeInlineContext(inlineToken.children) : null;'
        '  return [{ range: token.map, text: context?.text ?? null, code: context?.code ?? [] }];'
        '});'
        'const levelTwoHeadings = tokens.flatMap((token, index) => {'
        '  if (token.type !== "heading_open" || token.tag !== "h2" || token.level !== 0) return [];'
        '  const inlineToken = tokens[index + 1];'
        '  return [{ range: token.map, text: inlineToken?.type === "inline" ? inlineToken.content : null }];'
        '});'
        'process.stdout.write(JSON.stringify({ codeBlockRanges, proseBlocks, topLevelBlocks, topLevelListItems, levelTwoHeadings }));'
    ) -join "`n"

    $objStartInfo = [System.Diagnostics.ProcessStartInfo]::new()
    $objStartInfo.FileName = $objNodeCommand.Source
    $objStartInfo.WorkingDirectory = $strRepositoryRootPath
    $objStartInfo.UseShellExecute = $false
    $objStartInfo.CreateNoWindow = $true
    $objStartInfo.RedirectStandardInput = $true
    $objStartInfo.RedirectStandardOutput = $true
    $objStartInfo.RedirectStandardError = $true
    $objStartInfo.StandardInputEncoding = [System.Text.UTF8Encoding]::new($false)
    $objStartInfo.StandardOutputEncoding = [System.Text.UTF8Encoding]::new($false)
    $objStartInfo.StandardErrorEncoding = [System.Text.UTF8Encoding]::new($false)
    [void]$objStartInfo.Environment.Remove('NODE_OPTIONS')
    [void]$objStartInfo.Environment.Remove('NODE_PATH')
    $objStartInfo.ArgumentList.Add('-e')
    $objStartInfo.ArgumentList.Add($strNodeProgram)

    $objParserProcess = [System.Diagnostics.Process]::new()
    $objParserProcess.StartInfo = $objStartInfo
    try {
        if (-not $objParserProcess.Start()) {
            throw 'Could not start the locked Markdown parser.'
        }

        $objStandardOutputTask = $objParserProcess.StandardOutput.ReadToEndAsync()
        $objStandardErrorTask = $objParserProcess.StandardError.ReadToEndAsync()
        $objParserProcess.StandardInput.Write($Content)
        $objParserProcess.StandardInput.Close()
        if (-not $objParserProcess.WaitForExit(10000)) {
            $objParserProcess.Kill($true)
            [void]$objParserProcess.WaitForExit(1000)
            throw 'Markdown block parsing must complete within 10 seconds.'
        }

        $strParserOutput = $objStandardOutputTask.GetAwaiter().GetResult()
        [void]$objStandardErrorTask.GetAwaiter().GetResult()
        if ($objParserProcess.ExitCode -ne 0) {
            throw 'The locked Markdown parser rejected a governed document.'
        }
    }
    finally {
        $objParserProcess.Dispose()
    }

    try {
        $objRawContext = $strParserOutput | ConvertFrom-Json -ErrorAction Stop
    }
    catch {
        throw [System.IO.InvalidDataException]::new(
            'The locked Markdown parser returned invalid context data.',
            $_.Exception
        )
    }
    if ($null -eq $objRawContext -or
        $null -eq $objRawContext.codeBlockRanges -or
        $null -eq $objRawContext.proseBlocks -or
        $null -eq $objRawContext.topLevelBlocks -or
        $null -eq $objRawContext.topLevelListItems -or
        $null -eq $objRawContext.levelTwoHeadings) {
        throw 'The locked Markdown parser returned incomplete context data.'
    }

    $listRanges = [Collections.Generic.List[pscustomobject]]::new()
    $intPreviousEnd = 0
    foreach ($arrRawRange in @($objRawContext.codeBlockRanges)) {
        if ($arrRawRange -isnot [array] -or $arrRawRange.Count -ne 2) {
            throw 'The locked Markdown parser returned a malformed range.'
        }

        $intStart = [int64] 0
        $intEnd = [int64] 0
        if (-not [int64]::TryParse([string]$arrRawRange[0], [ref]$intStart) -or
            -not [int64]::TryParse([string]$arrRawRange[1], [ref]$intEnd) -or
            $intStart -lt $intPreviousEnd -or
            $intStart -lt 0 -or
            $intEnd -le $intStart -or
            $intEnd -gt $LineCount) {
            throw 'The locked Markdown parser returned an invalid or overlapping range.'
        }

        $listRanges.Add([pscustomobject]@{
                Start = [int]$intStart
                End = [int]$intEnd
            })
        $intPreviousEnd = [int]$intEnd
    }

    $listProseBlocks = [Collections.Generic.List[pscustomobject]]::new()
    foreach ($objRawProseBlock in @($objRawContext.proseBlocks)) {
        if ($null -eq $objRawProseBlock -or
            $objRawProseBlock.range -isnot [array] -or
            $objRawProseBlock.range.Count -ne 2 -or
            $null -eq $objRawProseBlock.text -or
            $objRawProseBlock.code -isnot [array] -or
            @($objRawProseBlock.code | Where-Object { $_ -isnot [string] }).Count -ne 0) {
            throw 'The locked Markdown parser returned a malformed prose block.'
        }

        $intStart = [int64] 0
        $intEnd = [int64] 0
        if (-not [int64]::TryParse([string]$objRawProseBlock.range[0], [ref]$intStart) -or
            -not [int64]::TryParse([string]$objRawProseBlock.range[1], [ref]$intEnd) -or
            $intStart -lt 0 -or
            $intEnd -le $intStart -or
            $intEnd -gt $LineCount) {
            throw 'The locked Markdown parser returned an invalid prose-block range.'
        }

        $listProseBlocks.Add([pscustomobject]@{
                Start = [int]$intStart
                End = [int]$intEnd
                Text = [string]$objRawProseBlock.text
                Code = [string[]]@($objRawProseBlock.code)
            })
    }

    $listTopLevelBlocks = [Collections.Generic.List[pscustomobject]]::new()
    $intPreviousTopLevelBlockEnd = 0
    foreach ($objRawBlock in @($objRawContext.topLevelBlocks)) {
        if ($null -eq $objRawBlock -or
            $objRawBlock.type -isnot [string] -or
            $objRawBlock.tag -isnot [string] -or
            $objRawBlock.range -isnot [array] -or
            $objRawBlock.range.Count -ne 2 -or
            ($null -ne $objRawBlock.text -and $objRawBlock.text -isnot [string])) {
            throw 'The locked Markdown parser returned a malformed top-level block.'
        }

        $intStart = [int64] 0
        $intEnd = [int64] 0
        if (-not [int64]::TryParse([string]$objRawBlock.range[0], [ref]$intStart) -or
            -not [int64]::TryParse([string]$objRawBlock.range[1], [ref]$intEnd) -or
            $intStart -lt $intPreviousTopLevelBlockEnd -or
            $intStart -lt 0 -or
            $intEnd -le $intStart -or
            $intEnd -gt $LineCount) {
            throw 'The locked Markdown parser returned an invalid top-level block range.'
        }

        $listTopLevelBlocks.Add([pscustomobject]@{
                Type = [string]$objRawBlock.type
                Tag = [string]$objRawBlock.tag
                Start = [int]$intStart
                End = [int]$intEnd
                Text = if ($null -eq $objRawBlock.text) {
                    $null
                }
                else {
                    [string]$objRawBlock.text
                }
            })
        $intPreviousTopLevelBlockEnd = [int]$intEnd
    }

    $listTopLevelListItems = [Collections.Generic.List[pscustomobject]]::new()
    $intPreviousTopLevelListItemEnd = 0
    foreach ($objRawListItem in @($objRawContext.topLevelListItems)) {
        if ($null -eq $objRawListItem -or
            $objRawListItem.range -isnot [array] -or
            $objRawListItem.range.Count -ne 2 -or
            ($null -ne $objRawListItem.text -and $objRawListItem.text -isnot [string]) -or
            $objRawListItem.code -isnot [array] -or
            @($objRawListItem.code | Where-Object { $_ -isnot [string] }).Count -ne 0) {
            throw 'The locked Markdown parser returned a malformed top-level list item.'
        }

        $intStart = [int64] 0
        $intEnd = [int64] 0
        if (-not [int64]::TryParse([string]$objRawListItem.range[0], [ref]$intStart) -or
            -not [int64]::TryParse([string]$objRawListItem.range[1], [ref]$intEnd) -or
            $intStart -lt $intPreviousTopLevelListItemEnd -or
            $intStart -lt 0 -or
            $intEnd -le $intStart -or
            $intEnd -gt $LineCount) {
            throw 'The locked Markdown parser returned an invalid top-level list-item range.'
        }

        $listTopLevelListItems.Add([pscustomobject]@{
                Start = [int]$intStart
                End = [int]$intEnd
                Text = if ($null -eq $objRawListItem.text) {
                    $null
                }
                else {
                    [string]$objRawListItem.text
                }
                Code = [string[]]@($objRawListItem.code)
            })
        $intPreviousTopLevelListItemEnd = [int]$intEnd
    }

    $listLevelTwoHeadings = [Collections.Generic.List[pscustomobject]]::new()
    $intPreviousHeadingEnd = 0
    foreach ($objRawHeading in @($objRawContext.levelTwoHeadings)) {
        if ($null -eq $objRawHeading -or
            $objRawHeading.range -isnot [array] -or
            $objRawHeading.range.Count -ne 2 -or
            $objRawHeading.text -isnot [string]) {
            throw 'The locked Markdown parser returned a malformed level-two heading.'
        }

        $intStart = [int64] 0
        $intEnd = [int64] 0
        if (-not [int64]::TryParse([string]$objRawHeading.range[0], [ref]$intStart) -or
            -not [int64]::TryParse([string]$objRawHeading.range[1], [ref]$intEnd) -or
            $intStart -lt $intPreviousHeadingEnd -or
            $intStart -lt 0 -or
            $intEnd -le $intStart -or
            $intEnd -gt $LineCount) {
            throw 'The locked Markdown parser returned an invalid level-two heading range.'
        }

        $listLevelTwoHeadings.Add([pscustomobject]@{
                Start = [int]$intStart
                End = [int]$intEnd
                Text = [string]$objRawHeading.text
            })
        $intPreviousHeadingEnd = [int]$intEnd
    }

    return [pscustomobject]@{
        CodeBlockRanges = [pscustomobject[]]$listRanges.ToArray()
        ProseBlocks = [pscustomobject[]]$listProseBlocks.ToArray()
        TopLevelBlocks = [pscustomobject[]]$listTopLevelBlocks.ToArray()
        TopLevelListItems = [pscustomobject[]]$listTopLevelListItems.ToArray()
        LevelTwoHeadings = [pscustomobject[]]$listLevelTwoHeadings.ToArray()
    }
}

function Get-OperativeMarkdownContext {
    # .SYNOPSIS
    # Gets the operative prose context from Markdown.
    #
    # .DESCRIPTION
    # Removes comments, excludes fenced and indented code blocks, and returns the
    # remaining text with source and prose metadata.
    #
    # .PARAMETER Content
    # The Markdown text to analyze.
    #
    # .EXAMPLE
    # Get-OperativeMarkdownContext -Content $strAgentsContent
    #
    # # Returns operative text and its source mapping.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [pscustomobject] Operative Markdown text, prose, lines, and range metadata.
    #
    # .NOTES
    # Private helper; no positional parameters.
    # Version: 1.0.20260819.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [string] $Content
    )

    $strWithoutComments = [regex]::Replace(
        $Content,
        '<!--(?s:.*?)-->|<!--(?s:.*)\z',
        ''
    )
    $arrLines = [regex]::Split($strWithoutComments, '\r\n|\r|\n')
    $arrCodeBlockLines = [bool[]]::new($arrLines.Count)
    $objParseContext = Get-MarkdownParseContext `
            -Content $strWithoutComments `
            -LineCount $arrLines.Count
    foreach ($objRange in $objParseContext.CodeBlockRanges) {
        for ($intLine = $objRange.Start; $intLine -lt $objRange.End; $intLine++) {
            $arrCodeBlockLines[$intLine] = $true
        }
    }

    $listOperativeLines = [Collections.Generic.List[string]]::new()
    for ($intLine = 0; $intLine -lt $arrLines.Count; $intLine++) {
        if (-not $arrCodeBlockLines[$intLine]) {
            $listOperativeLines.Add($arrLines[$intLine])
        }
    }

    return [pscustomobject]@{
        Text = $listOperativeLines -join "`n"
        ProseText = @($objParseContext.ProseBlocks.Text) -join "`n"
        SourceLines = [string[]]$arrLines
        CodeBlockLines = [bool[]]$arrCodeBlockLines
        ProseBlocks = [pscustomobject[]]$objParseContext.ProseBlocks
        TopLevelListItems = [pscustomobject[]]$objParseContext.TopLevelListItems
        LevelTwoHeadings = [pscustomobject[]]$objParseContext.LevelTwoHeadings
    }
}

function ConvertTo-OperativeMarkdownText {
    # .SYNOPSIS
    # Converts Markdown to operative non-code text.
    #
    # .DESCRIPTION
    # Returns the operative text from the full Markdown context helper.
    #
    # .PARAMETER Content
    # The Markdown text to convert.
    #
    # .EXAMPLE
    # ConvertTo-OperativeMarkdownText -Content $strMarkdown
    #
    # # Returns text with comments and code blocks excluded.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [string] The operative Markdown text.
    #
    # .NOTES
    # Private helper; no positional parameters.
    # Version: 1.0.20260819.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $Content
    )

    return (Get-OperativeMarkdownContext -Content $Content).Text
}

function Get-ActiveClaudeImportReference {
    # .SYNOPSIS
    # Gets active Claude file-import references from operative Markdown prose.
    #
    # .DESCRIPTION
    # Inspects parser-derived prose only. Fenced code, indented code, inline code,
    # comments, and raw HTML are excluded before import matching.
    #
    # .PARAMETER MarkdownContext
    # The validated operative Markdown context to inspect.
    #
    # .EXAMPLE
    # Get-ActiveClaudeImportReference -MarkdownContext $objClaudeContext
    #
    # # Returns each active import target, including extensionless file names.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [string] Each active Claude import target.
    #
    # .NOTES
    # Private helper; no positional parameters. Version: 1.0.20260823.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [pscustomobject] $MarkdownContext
    )

    $strImportPattern =
        '(?m)(?<!\S)@(?<Target>(?!(?:claude|codex)(?=$|\s))[^\s<>]+)' +
        '(?=$|\s)'
    foreach ($objProseBlock in $MarkdownContext.ProseBlocks) {
        foreach ($objMatch in [regex]::Matches(
                $objProseBlock.Text,
                $strImportPattern
            )) {
            Write-Output $objMatch.Groups['Target'].Value
        }
    }
}

function Get-ClaudeImportFailure {
    # .SYNOPSIS
    # Finds an active import in one governed Claude instruction document.
    #
    # .PARAMETER Name
    # The repository-relative governed CLAUDE.md path.
    #
    # .PARAMETER MarkdownContext
    # The validated operative Markdown context to inspect.
    #
    # .EXAMPLE
    # Get-ClaudeImportFailure -Name 'tools/CLAUDE.md' `
    #     -MarkdownContext $objClaudeContext
    #
    # # Returns the path-specific failure when an active import exists.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [string] The path-specific active-import failure.
    #
    # .NOTES
    # Private helper; no positional parameters. Version: 1.0.20260823.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [pscustomobject] $MarkdownContext
    )

    if (@(Get-ActiveClaudeImportReference `
                -MarkdownContext $MarkdownContext).Count -gt 0) {
        Write-Output "$Name must not contain active @path imports."
    }
}

function Get-NestedClaudeImportFailure {
    # .SYNOPSIS
    # Finds active imports in cataloged nested Claude instruction documents.
    #
    # .PARAMETER DocumentContexts
    # The cataloged governed-document contexts to inspect.
    #
    # .EXAMPLE
    # Get-NestedClaudeImportFailure -DocumentContexts $listGovernedDocumentContexts
    #
    # # Returns a path-specific failure for each affected nested CLAUDE.md.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [string] Each path-specific active-import failure.
    #
    # .NOTES
    # Private helper; no positional parameters. Version: 1.0.20260823.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [object[]] $DocumentContexts
    )

    foreach ($objDocumentContext in $DocumentContexts) {
        if ($objDocumentContext.Path -ceq 'CLAUDE.md' -or
            $objDocumentContext.Path -cnotmatch '(?:^|/)CLAUDE\.md$') {
            continue
        }
        $objNestedClaudeContext = Get-OperativeMarkdownContext `
            -Content $objDocumentContext.Content
        Write-Output @(Get-ClaudeImportFailure `
                -Name $objDocumentContext.Path `
                -MarkdownContext $objNestedClaudeContext)
    }
}

function Get-MarkdownLevelTwoSectionContext {
    # .SYNOPSIS
    # Gets one level-two Markdown section.
    #
    # .DESCRIPTION
    # Locates one exact top-level level-two heading from validated Markdown tokens
    # and returns its operative section text and prose. An absent or duplicate
    # heading returns an empty context.
    #
    # .PARAMETER MarkdownContext
    # The validated operative Markdown context.
    #
    # .PARAMETER Heading
    # The exact parsed level-two heading text, without Markdown heading markers.
    #
    # .EXAMPLE
    # Get-MarkdownLevelTwoSectionContext -MarkdownContext $objContext `
    #     -Heading 'Automated Review Loop'
    #
    # # Returns operative text and prose for the unique section.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [pscustomobject] The section's text and parser-derived block context.
    #
    # .NOTES
    # Private helper; no positional parameters.
    # Version: 1.1.20260820.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [pscustomobject] $MarkdownContext,

        [Parameter(Mandatory)]
        [string] $Heading
    )

    $arrMatchingHeadings = @(
        $MarkdownContext.LevelTwoHeadings |
            Where-Object Text -CEQ $Heading
    )
    if ($arrMatchingHeadings.Count -ne 1) {
        return [pscustomobject]@{
            Text = ''
            ProseText = ''
            ProseBlocks = [pscustomobject[]]@()
            TopLevelListItems = [pscustomobject[]]@()
        }
    }

    $intSectionStart = $arrMatchingHeadings[0].Start
    $intSectionEnd = $MarkdownContext.SourceLines.Count
    foreach ($objHeading in $MarkdownContext.LevelTwoHeadings) {
        if ($objHeading.Start -gt $intSectionStart) {
            $intSectionEnd = $objHeading.Start
            break
        }
    }

    $listSectionLines = [Collections.Generic.List[string]]::new()
    for ($intLine = $intSectionStart; $intLine -lt $intSectionEnd; $intLine++) {
        if (-not $MarkdownContext.CodeBlockLines[$intLine]) {
            $listSectionLines.Add($MarkdownContext.SourceLines[$intLine])
        }
    }

    $listSectionProse = [Collections.Generic.List[string]]::new()
    foreach ($objProseBlock in $MarkdownContext.ProseBlocks) {
        if ($objProseBlock.Start -ge $intSectionStart -and
            $objProseBlock.End -le $intSectionEnd) {
            $listSectionProse.Add($objProseBlock.Text)
        }
    }

    return [pscustomobject]@{
        Text = $listSectionLines -join "`n"
        ProseText = $listSectionProse -join "`n"
        ProseBlocks = [pscustomobject[]]@(
            $MarkdownContext.ProseBlocks |
                Where-Object {
                    $_.Start -ge $intSectionStart -and $_.End -le $intSectionEnd
                }
        )
        TopLevelListItems = [pscustomobject[]]@(
            $MarkdownContext.TopLevelListItems |
                Where-Object {
                    $_.Start -ge $intSectionStart -and $_.End -le $intSectionEnd
                }
        )
    }
}

function Test-MetadataCalendarDatePair {
    # .SYNOPSIS
    # Tests one Version date and Last Updated date as a matching calendar date.
    #
    # .DESCRIPTION
    # Parses the hyphenated date with the invariant Gregorian calendar and
    # confirms that its compact form equals the Version date.
    #
    # .PARAMETER VersionDate
    # The compact yyyyMMdd date from Version metadata.
    #
    # .PARAMETER UpdatedDate
    # The yyyy-MM-dd date from Last Updated metadata.
    #
    # .EXAMPLE
    # Test-MetadataCalendarDatePair -VersionDate '20240229' `
    #     -UpdatedDate '2024-02-29'
    #
    # # Returns true for the matching leap-day pair.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [bool] True when both strings represent the same real calendar date.
    #
    # .NOTES
    # Private helper; no positional parameters. Version: 1.0.20260819.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string] $VersionDate,

        [Parameter(Mandatory)]
        [string] $UpdatedDate
    )

    $objParsedDate = [datetime]::MinValue
    if (-not [datetime]::TryParseExact(
            $UpdatedDate,
            'yyyy-MM-dd',
            [System.Globalization.CultureInfo]::InvariantCulture,
            [System.Globalization.DateTimeStyles]::None,
            [ref] $objParsedDate
        )) {
        return $false
    }

    return $objParsedDate.ToString(
        'yyyyMMdd',
        [System.Globalization.CultureInfo]::InvariantCulture
    ) -ceq $VersionDate
}

function ConvertTo-MetadataComparisonText {
    # .SYNOPSIS
    # Normalizes governed text for metadata-only comparison.
    #
    # .DESCRIPTION
    # Masks two validated header lines, then normalizes mechanical whitespace.
    #
    # .PARAMETER Content
    # The governed document text to normalize.
    #
    # .PARAMETER MetadataContext
    # The parser-validated document-level metadata context.
    #
    # .EXAMPLE
    # ConvertTo-MetadataComparisonText -Content $strContent -MetadataContext $objContext
    #
    # .INPUTS
    # None.
    #
    # .OUTPUTS
    # [string] Normalized comparison text.
    #
    # .NOTES
    # Private helper; no positional parameters. Version: 1.1.20260820.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $Content,

        [Parameter(Mandatory)]
        [pscustomobject] $MetadataContext
    )

    $arrNormalizedLines = [regex]::Split($Content, '\r\n|\r|\n')
    $intUpdatedLineIndex = [int]$MetadataContext.UpdatedLineIndex
    if ($intUpdatedLineIndex -lt 0 -or
        $intUpdatedLineIndex -ge $arrNormalizedLines.Count -or
        $arrNormalizedLines[$intUpdatedLineIndex] -cnotmatch
        '^- \*\*Last Updated:\*\* \d{4}-\d{2}-\d{2}$') {
        throw 'The metadata comparison received an invalid header field index.'
    }
    $intVersionLineIndex = [int]$MetadataContext.VersionLineIndex
    if ($intVersionLineIndex -ge 0) {
        if ($intVersionLineIndex -ge $arrNormalizedLines.Count -or
            $arrNormalizedLines[$intVersionLineIndex] -cnotmatch
            '^\*\*Version:\*\* \d+\.\d+\.\d{8}\.\d+$') {
            throw 'The metadata comparison received an invalid Version field index.'
        }
        $arrNormalizedLines[$intVersionLineIndex] = '**Version:** <metadata-version>'
    }
    $arrNormalizedLines[$intUpdatedLineIndex] = '- **Last Updated:** <metadata-date>'

    $listNormalizedLines = [Collections.Generic.List[string]]::new()
    foreach ($strLine in $arrNormalizedLines) {
        if ($strLine -match ' {2,}$') {
            $listNormalizedLines.Add($strLine)
        }
        else {
            $listNormalizedLines.Add($strLine.TrimEnd([char[]] @(' ', "`t")))
        }
    }
    while ($listNormalizedLines.Count -gt 0 -and
        $listNormalizedLines[$listNormalizedLines.Count - 1].Length -eq 0) {
        $listNormalizedLines.RemoveAt($listNormalizedLines.Count - 1)
    }

    return $listNormalizedLines -join "`n"
}

function ConvertFrom-TrustedEventTimestamp {
    # .SYNOPSIS
    # Parses a stable server event timestamp.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([DateTimeOffset])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Timestamp
    )

    $objTimestamp = [DateTimeOffset]::MinValue
    $longUnixSeconds = [int64] 0
    $boolParsed = if ($Timestamp -cmatch '^(?:0|[1-9][0-9]{0,9})$') {
        [int64]::TryParse(
            $Timestamp,
            [Globalization.NumberStyles]::None,
            [Globalization.CultureInfo]::InvariantCulture,
            [ref] $longUnixSeconds
        ) -and (($objTimestamp = [DateTimeOffset]::FromUnixTimeSeconds(
                    $longUnixSeconds
                )) -ne [DateTimeOffset]::MinValue)
    }
    else {
        [DateTimeOffset]::TryParseExact(
            $Timestamp,
            'yyyy-MM-ddTHH:mm:ssZ',
            [Globalization.CultureInfo]::InvariantCulture,
            [Globalization.DateTimeStyles]::AssumeUniversal -bor
                [Globalization.DateTimeStyles]::AdjustToUniversal,
            [ref] $objTimestamp
        )
    }
    if (-not $boolParsed) {
        throw 'The trusted GitHub event timestamp is invalid.'
    }
    if ($objTimestamp -gt $script:objMaximumCommitUtcTimestamp) {
        throw 'The trusted GitHub event timestamp must not be in the future.'
    }
    return $objTimestamp.ToUniversalTime()
}

function Get-CurrentInputMetadataFreshnessFailure {
    # .SYNOPSIS
    # Finds stale metadata on one exact current event input.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string] $CurrentContent,

        [Parameter()]
        [AllowNull()]
        [string] $BaseContent,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $TrustedEventUtcDate
    )

    $objCurrentMetadata = Get-DocumentMetadataContext -Content $CurrentContent
    if ($null -ne $objCurrentMetadata.Failure -or
        -not (Test-MetadataCalendarDatePair `
            -VersionDate $objCurrentMetadata.VersionDate `
            -UpdatedDate $objCurrentMetadata.UpdatedDate)) {
        return
    }

    $boolRenderedContentChanged = $true
    if ($BaseContent) {
        $objBaseMetadata = Get-DocumentMetadataContext -Content $BaseContent
        if ($null -eq $objBaseMetadata.Failure -and
            (Test-MetadataCalendarDatePair `
                -VersionDate $objBaseMetadata.VersionDate `
                -UpdatedDate $objBaseMetadata.UpdatedDate)) {
            $boolRenderedContentChanged = (
                (ConvertTo-MetadataComparisonText `
                    -Content $CurrentContent -MetadataContext $objCurrentMetadata) -cne
                (ConvertTo-MetadataComparisonText `
                    -Content $BaseContent -MetadataContext $objBaseMetadata)
            )
        }
    }
    if ($boolRenderedContentChanged -and
        $objCurrentMetadata.UpdatedDate -cne $TrustedEventUtcDate) {
        Write-Output (
            "$Name Last Updated must be $TrustedEventUtcDate after the current " +
            'event input changes rendered content.'
        )
    }
}

function Get-LastUpdatedMetadataFreshnessFailure {
    # .SYNOPSIS
    # Validates metadata and freshness without a Version field.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $Name,
        [Parameter(Mandatory)][string] $CurrentContent,
        [Parameter()][AllowNull()][object] $BaseContent,
        [Parameter(Mandatory)][AllowEmptyString()][string] $TrustedEventUtcDate
    )

    $objCurrentMetadata = Get-DocumentMetadataContext `
        -Content $CurrentContent -RequiresVersion $false
    if ($null -ne $objCurrentMetadata.Failure) {
        Write-Output "$Name $($objCurrentMetadata.Failure)"
        return
    }
    $strCurrentDate = $objCurrentMetadata.UpdatedDate
    if (-not (Test-MetadataCalendarDatePair `
                -VersionDate $strCurrentDate.Replace('-', '') `
                -UpdatedDate $strCurrentDate)) {
        Write-Output "$Name Last Updated must contain one real calendar date."
        return
    }

    $boolRenderedContentChanged = $true
    $objBaseMetadata = $null
    if ($null -ne $BaseContent) {
        $objBaseMetadata = Get-DocumentMetadataContext `
            -Content $BaseContent -RequiresVersion $false
        if ($null -ne $objBaseMetadata.Failure) {
            Write-Output "The parent of $Name $($objBaseMetadata.Failure)"
            return
        }
        $strBaseDate = $objBaseMetadata.UpdatedDate
        if (-not (Test-MetadataCalendarDatePair `
                    -VersionDate $strBaseDate.Replace('-', '') `
                    -UpdatedDate $strBaseDate)) {
            Write-Output "The parent of $Name Last Updated must contain one real calendar date."
            return
        }
        $boolRenderedContentChanged = (
            (ConvertTo-MetadataComparisonText -Content $CurrentContent `
                -MetadataContext $objCurrentMetadata) -cne
            (ConvertTo-MetadataComparisonText -Content $BaseContent `
                -MetadataContext $objBaseMetadata)
        )
        if ([string]::CompareOrdinal(
                $strCurrentDate,
                $strBaseDate
            ) -lt 0) {
            Write-Output (
                "$Name Last Updated must not move backward from " +
                "$strBaseDate to $strCurrentDate."
            )
            return
        }
    }
    if (-not $boolRenderedContentChanged) {
        return
    }
    if (-not [string]::IsNullOrEmpty($TrustedEventUtcDate) -and
        $strCurrentDate -cne $TrustedEventUtcDate) {
        Write-Output (
            "$Name Last Updated must be $TrustedEventUtcDate after the current " +
            'event input changes rendered content.'
        )
    }
    elseif ($null -ne $objBaseMetadata -and
        $strCurrentDate -ceq $strBaseDate) {
        Write-Output (
            "$Name Last Updated must advance from $strBaseDate " +
            'after a rendered-content change when no trusted event date is available.'
        )
    }
}

function Test-TopicOwnedGitPathDeltaEqual {
    # .SYNOPSIS
    # Compares one authenticated path delta across two topic-head ranges.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][string] $RepositoryRootPath,
        [Parameter(Mandatory)][string] $PreviousBaseRevision,
        [Parameter(Mandatory)][string] $PreviousHeadRevision,
        [Parameter(Mandatory)][string] $CurrentBaseRevision,
        [Parameter(Mandatory)][string] $CurrentHeadRevision,
        [Parameter(Mandatory)][string] $RepositoryRelativePath
    )

    $arrPreviousDelta = @(& git -C $RepositoryRootPath diff --unified=0 --no-renames `
            --no-ext-diff --no-textconv $PreviousBaseRevision `
            $PreviousHeadRevision -- $RepositoryRelativePath)
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not read the authenticated previous topic-owned path delta.'
    }
    $arrCurrentDelta = @(& git -C $RepositoryRootPath diff --unified=0 --no-renames `
            --no-ext-diff --no-textconv $CurrentBaseRevision `
            $CurrentHeadRevision -- $RepositoryRelativePath)
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not read the authenticated current topic-owned path delta.'
    }
    $scriptBlockGetPatchIdentity = {
        param(
            [string[]] $DeltaLines,
            [string] $RangeDescription
        )

        if ($DeltaLines.Count -eq 0) {
            return ''
        }
        $arrPatchIdentityOutput = @(
            $DeltaLines | & git -C $RepositoryRootPath patch-id --verbatim
        )
        if ($LASTEXITCODE -ne 0) {
            throw "Could not fingerprint the authenticated $RangeDescription delta."
        }
        $arrPatchIdentityOutput = @(
            $arrPatchIdentityOutput | Where-Object {
                -not [string]::IsNullOrWhiteSpace([string]$_)
            }
        )
        if ($arrPatchIdentityOutput.Count -ne 1 -or
            ([string]$arrPatchIdentityOutput[0]).Trim() -cnotmatch
                '^(?<PatchId>[0-9a-f]{40}|[0-9a-f]{64})\s+[0-9a-f]+$') {
            throw "The authenticated $RangeDescription delta has no unique patch identity."
        }
        return $Matches['PatchId']
    }
    $strPreviousPatchIdentity = & $scriptBlockGetPatchIdentity `
        -DeltaLines $arrPreviousDelta -RangeDescription 'previous topic-owned path'
    $strCurrentPatchIdentity = & $scriptBlockGetPatchIdentity `
        -DeltaLines $arrCurrentDelta -RangeDescription 'current topic-owned path'
    return (
        $strPreviousPatchIdentity -ceq $strCurrentPatchIdentity
    )
}

function Get-MarkdownParserBootstrapFailure {
    # .SYNOPSIS
    # Reports a missing locked Markdown parser bootstrap.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param([Parameter(Mandatory)][string] $RepositoryRootPath)

    $strMarkdownParserPath = Join-Path -Path $RepositoryRootPath `
        -ChildPath 'node_modules/markdown-it/package.json'
    if (-not (Test-Path -LiteralPath $strMarkdownParserPath -PathType Leaf)) {
        Write-Output (
            'Locked Node.js dependencies are missing. Run ' +
            '`npm run bootstrap:agent-instructions` before pre-commit validation.'
        )
    }
}

function Test-ProhibitedClaudeLocalPath {
    # .SYNOPSIS
    # Tests whether a tracked path is prohibited operative local Claude memory.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([bool])]
    param([Parameter(Mandatory)][string] $RepositoryRelativePath)

    return $RepositoryRelativePath -imatch '^(?:[^/]+/)*CLAUDE\.local\.md$'
}

function Get-MetadataEventRevisionContext {
    # .SYNOPSIS
    # Resolves history and current-event comparison bases from trusted payload data.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][string] $RepositoryRootPath,
        [Parameter(Mandatory)][string] $EventName,
        [Parameter(Mandatory)][AllowEmptyString()][string] $PullRequestAction,
        [Parameter(Mandatory)][string] $BaseRevision,
        [Parameter(Mandatory)][string] $HeadRevision,
        [Parameter(Mandatory)][bool] $IsNewRefRange,
        [Parameter(Mandatory)][AllowEmptyString()][string] $PreviousHeadRevision,
        [Parameter()][AllowEmptyString()][string] $PullRequestBaseChanged = '',
        [Parameter(Mandatory)][AllowEmptyString()][string] $EventHeadRevision,
        [Parameter(Mandatory)][AllowEmptyString()][string] $EventHeadDistinct,
        [Parameter()][AllowEmptyString()][string] $NewRefCommitCount = '',
        [Parameter()][AllowEmptyString()][string] $NewRefCommitEvidenceJson = ''
    )

    $strObjectIdPattern = '^(?:[0-9a-fA-F]{40}|[0-9a-fA-F]{64})$'
    $strZeroObjectIdPattern = '^(?:0{40}|0{64})$'
    if ($HeadRevision -notmatch $strObjectIdPattern -or
        $HeadRevision -match $strZeroObjectIdPattern) {
        throw 'The metadata event head is invalid.'
    }
    & git -C $RepositoryRootPath cat-file -e "$HeadRevision`^{commit}" 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw 'The metadata event head is unavailable.'
    }

    if ($EventName -ceq 'push') {
        if (-not [string]::IsNullOrEmpty($PullRequestAction) -or
            -not [string]::IsNullOrEmpty($PullRequestBaseChanged) -or
            -not [string]::IsNullOrEmpty($PreviousHeadRevision)) {
            throw 'A push metadata event must not supply pull request fields.'
        }
        if ($EventHeadRevision -notmatch $strObjectIdPattern -or
            $EventHeadRevision -match $strZeroObjectIdPattern) {
            throw 'A push metadata event requires a valid expanded head revision.'
        }
        if (-not [string]::Equals(
                $EventHeadRevision,
                $HeadRevision,
                [StringComparison]::OrdinalIgnoreCase
            )) {
            throw 'The expanded push head revision must match the event after revision.'
        }
        if ($EventHeadDistinct -cnotin @('true', 'false')) {
            throw 'The expanded push head distinct value must be true or false.'
        }
        $boolHeadIntroducedByPush = $EventHeadDistinct -ceq 'true'
        if ($IsNewRefRange) {
            if ($BaseRevision -notmatch $strZeroObjectIdPattern) {
                throw 'A new-ref push metadata event requires an all-zero base.'
            }
            $intNewRefCommitCount = 0
            if ($NewRefCommitCount -cnotmatch '^(?:0|[1-9][0-9]*)$' -or
                -not [int]::TryParse($NewRefCommitCount, [ref]$intNewRefCommitCount)) {
                throw 'A new-ref push requires a valid authenticated commit count.'
            }
            try {
                $arrNewRefCommitEvidence = @(
                    ConvertFrom-Json -InputObject $NewRefCommitEvidenceJson -NoEnumerate
                )
                if ($arrNewRefCommitEvidence.Count -eq 1 -and
                    $arrNewRefCommitEvidence[0] -is [System.Array]) {
                    $arrNewRefCommitEvidence = @($arrNewRefCommitEvidence[0])
                }
            }
            catch {
                throw 'The authenticated new-ref commit evidence is malformed.'
            }
            if ($arrNewRefCommitEvidence.Count -ne $intNewRefCommitCount) {
                throw 'The authenticated new-ref commit evidence is incomplete.'
            }
            if (-not $boolHeadIntroducedByPush) {
                if ($intNewRefCommitCount -ne 0) {
                    throw 'A non-distinct new-ref push must report zero introduced commits.'
                }
            }
            elseif ($intNewRefCommitCount -eq 0) {
                throw 'Distinct new-ref push requires an introduced commit.'
            }
            $strPreviousEvidenceCommit = ''
            $strFreshnessBase = ''
            for ($intEvidenceIndex = 0;
                $intEvidenceIndex -lt $arrNewRefCommitEvidence.Count;
                $intEvidenceIndex++) {
                $strEvidenceCommit = [string]$arrNewRefCommitEvidence[$intEvidenceIndex]
                if ($strEvidenceCommit -notmatch $strObjectIdPattern -or
                    $strEvidenceCommit -match $strZeroObjectIdPattern) {
                    throw 'The authenticated new-ref commit evidence contains an invalid commit.'
                }
                $strCommitAndParents = [string](& git -C $RepositoryRootPath `
                        rev-list --parents -n 1 $strEvidenceCommit 2>$null)
                if ($LASTEXITCODE -ne 0) {
                    throw 'The authenticated new-ref commit evidence is unavailable.'
                }
                $arrCommitAndParents = @($strCommitAndParents.Trim() -split '\s+')
                if ($arrCommitAndParents.Count -gt 2) {
                    throw 'The authenticated new-ref commit evidence has an ambiguous merge.'
                }
                if ($intEvidenceIndex -eq 0) {
                    if ($arrCommitAndParents.Count -eq 2) {
                        $strFreshnessBase = $arrCommitAndParents[1]
                    }
                }
                elseif ($arrCommitAndParents.Count -ne 2 -or
                    $arrCommitAndParents[1] -cne $strPreviousEvidenceCommit) {
                    throw 'The authenticated new-ref commit evidence is not contiguous.'
                }
                $strPreviousEvidenceCommit = $strEvidenceCommit
            }
            if ($boolHeadIntroducedByPush -and
                $strPreviousEvidenceCommit -cne $HeadRevision) {
                throw 'The authenticated new-ref commit evidence does not end at the event head.'
            }
            return [pscustomobject]@{
                HistoryBaseRevision = $BaseRevision
                FreshnessBaseRevision = $strFreshnessBase
                EvaluateFreshness = $boolHeadIntroducedByPush
                PreviousTopicBaseRevision = ''
                PreviousTopicHeadRevision = ''
                CurrentTopicBaseRevision = ''
                CurrentTopicHeadRevision = ''
            }
        }
        if (-not [string]::IsNullOrEmpty($NewRefCommitCount) -or
            -not [string]::IsNullOrEmpty($NewRefCommitEvidenceJson)) {
            throw 'An existing-ref push must not supply new-ref commit evidence.'
        }
        if ($BaseRevision -notmatch $strObjectIdPattern -or
            $BaseRevision -match $strZeroObjectIdPattern) {
            throw 'An existing-ref push metadata event requires a valid base.'
        }
        & git -C $RepositoryRootPath cat-file -e `
            "$BaseRevision`^{commit}" 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw 'The existing-ref push base is unavailable.'
        }
        return [pscustomobject]@{
            HistoryBaseRevision = $BaseRevision
            FreshnessBaseRevision = if ($boolHeadIntroducedByPush) {
                $BaseRevision
            }
            else {
                ''
            }
            EvaluateFreshness = $boolHeadIntroducedByPush
            PreviousTopicBaseRevision = ''
            PreviousTopicHeadRevision = ''
            CurrentTopicBaseRevision = ''
            CurrentTopicHeadRevision = ''
        }
    }

    if ($EventName -cne 'pull_request_target') {
        throw "Unsupported metadata event name: $EventName"
    }
    if ($IsNewRefRange -or
        -not [string]::IsNullOrEmpty($EventHeadRevision) -or
        -not [string]::IsNullOrEmpty($EventHeadDistinct) -or
        -not [string]::IsNullOrEmpty($NewRefCommitCount) -or
        -not [string]::IsNullOrEmpty($NewRefCommitEvidenceJson)) {
        throw 'A pull request metadata event must not use push-only fields.'
    }
    if ($PullRequestAction -cnotin @('opened', 'reopened', 'synchronize', 'edited')) {
        throw "Unsupported pull request metadata action: $PullRequestAction"
    }
    if ($PullRequestAction -ceq 'edited') {
        if ($PullRequestBaseChanged -cne 'true') {
            throw 'An edited pull request event requires trusted base-change proof.'
        }
    }
    elseif (-not [string]::IsNullOrEmpty($PullRequestBaseChanged)) {
        throw 'Only an edited pull request event may supply base-change proof.'
    }
    if ($BaseRevision -notmatch $strObjectIdPattern -or
        $BaseRevision -match $strZeroObjectIdPattern) {
        throw 'A pull request metadata event requires a valid base tip.'
    }
    & git -C $RepositoryRootPath cat-file -e "$BaseRevision`^{commit}" 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw 'The pull request base tip is unavailable.'
    }
    $arrMergeBases = @(& git -C $RepositoryRootPath merge-base --all `
            $BaseRevision $HeadRevision 2>$null)
    if ($LASTEXITCODE -ne 0 -or $arrMergeBases.Count -ne 1 -or
        ([string] $arrMergeBases[0]).Trim() -notmatch $strObjectIdPattern) {
        throw 'The pull request metadata range must have one available merge base.'
    }
    $strHistoryBase = ([string] $arrMergeBases[0]).Trim()

    if ($PullRequestAction -cne 'synchronize') {
        if (-not [string]::IsNullOrEmpty($PreviousHeadRevision)) {
            throw 'A nonsynchronize pull request must not supply a previous head.'
        }
        return [pscustomobject]@{
            HistoryBaseRevision = $strHistoryBase
            FreshnessBaseRevision = $strHistoryBase
            EvaluateFreshness = $true
            PreviousTopicBaseRevision = ''
            PreviousTopicHeadRevision = ''
            CurrentTopicBaseRevision = ''
            CurrentTopicHeadRevision = ''
        }
    }
    if ($PreviousHeadRevision -notmatch $strObjectIdPattern -or
        $PreviousHeadRevision -match $strZeroObjectIdPattern -or
        [string]::Equals(
            $PreviousHeadRevision,
            $HeadRevision,
            [StringComparison]::OrdinalIgnoreCase
        )) {
        throw 'A synchronize event requires a distinct valid previous topic head.'
    }
    & git -C $RepositoryRootPath cat-file -e `
        "$PreviousHeadRevision`^{commit}" 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw 'The synchronize previous topic head is unavailable.'
    }
    $arrPreviousMergeBases = @(& git -C $RepositoryRootPath merge-base --all `
            $BaseRevision $PreviousHeadRevision 2>$null)
    if ($LASTEXITCODE -ne 0 -or $arrPreviousMergeBases.Count -ne 1 -or
        ([string]$arrPreviousMergeBases[0]).Trim() -notmatch $strObjectIdPattern) {
        throw 'The synchronize previous topic range must have one available merge base.'
    }
    return [pscustomobject]@{
        HistoryBaseRevision = $strHistoryBase
        FreshnessBaseRevision = $PreviousHeadRevision
        EvaluateFreshness = $true
        PreviousTopicBaseRevision = ([string]$arrPreviousMergeBases[0]).Trim()
        PreviousTopicHeadRevision = $PreviousHeadRevision
        CurrentTopicBaseRevision = $strHistoryBase
        CurrentTopicHeadRevision = $HeadRevision
    }
}

function Test-GovernedInstructionPath {
    # .SYNOPSIS
    # Tests whether a repository-relative path is a governed instruction path.
    #
    # .DESCRIPTION
    # Matches an exact governed root path or a supported recursive instruction
    # family. The comparison is ordinal and case-sensitive. A case-folded
    # near-match is handled by Test-GovernedInstructionPathCaseMismatch.
    #
    # .PARAMETER RepositoryRelativePath
    # The slash-separated repository-relative path to classify.
    #
    # .PARAMETER GovernedRootPaths
    # The exact governed root instruction paths. The collection may be empty.
    #
    # .EXAMPLE
    # Test-GovernedInstructionPath `
    #     -RepositoryRelativePath 'tools/CLAUDE.md' `
    #     -GovernedRootPaths @('AGENTS.md', 'CLAUDE.md')
    #
    # # Returns $true because nested CLAUDE.md files are governed.
    #
    # .EXAMPLE
    # Test-GovernedInstructionPath `
    #     -RepositoryRelativePath 'docs/readme.md' `
    #     -GovernedRootPaths @('AGENTS.md', 'CLAUDE.md')
    #
    # # Returns $false because the path is not a governed family or exact root.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [bool] True for an exact governed root or recursive governed instruction
    # family; otherwise, false.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Positional parameters are disabled. Internal callers must use named
    # parameters. Version: 1.1.20260827.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string] $RepositoryRelativePath,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]] $GovernedRootPaths
    )

    return (
        $GovernedRootPaths -ccontains $RepositoryRelativePath -or
        $RepositoryRelativePath -cmatch `
            '^(?:(?!\.\.?/)[^/]+/)*GEMINI\.md$' -or
        $RepositoryRelativePath -cmatch `
            '^(?:[^/]+/)*AGENTS(?:\.override)?\.md$' -or
        $RepositoryRelativePath -cmatch `
            '^(?:[^/]+/)*CLAUDE\.md$' -or
        $RepositoryRelativePath -cmatch `
            '^\.github/instructions/(?:[^/]+/)*[^/]+\.instructions\.md$' -or
        $RepositoryRelativePath -cmatch `
            '^\.cursor/rules/(?:[^/]+/)*[^/]+\.mdc$' -or
        $RepositoryRelativePath -cmatch `
            '^\.claude/rules/(?:[^/]+/)*[^/]+\.md$'
    )
}

function Test-GovernedInstructionPathCaseMismatch {
    # .SYNOPSIS
    # Detects noncanonical casing of one governed instruction path.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string] $RepositoryRelativePath,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]] $GovernedRootPaths
    )

    if (Test-GovernedInstructionPath `
            -RepositoryRelativePath $RepositoryRelativePath `
            -GovernedRootPaths $GovernedRootPaths) {
        return $false
    }
    return (
        $GovernedRootPaths -icontains $RepositoryRelativePath -or
        $RepositoryRelativePath -imatch `
            '^(?:(?!\.\.?/)[^/]+/)*GEMINI\.md$' -or
        $RepositoryRelativePath -imatch `
            '^(?:[^/]+/)*AGENTS(?:\.override)?\.md$' -or
        $RepositoryRelativePath -imatch `
            '^(?:[^/]+/)*CLAUDE\.md$' -or
        $RepositoryRelativePath -imatch `
            '^\.github/instructions/(?:[^/]+/)*[^/]+\.instructions\.md$' -or
        $RepositoryRelativePath -imatch `
            '^\.cursor/rules/(?:[^/]+/)*[^/]+\.mdc$' -or
        $RepositoryRelativePath -imatch `
            '^\.claude/rules/(?:[^/]+/)*[^/]+\.md$'
    )
}

function Test-ExactPathCaseMismatch {
    # .SYNOPSIS
    # Detects noncanonical casing of one path from an exact reviewed set.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string] $RepositoryRelativePath,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]] $CanonicalPaths
    )

    return (
        $CanonicalPaths -icontains $RepositoryRelativePath -and
        $CanonicalPaths -cnotcontains $RepositoryRelativePath
    )
}

function Test-GovernedInstructionInventoryPath {
    # .SYNOPSIS
    # Selects canonical governed instructions and case-folded near-matches.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string] $RepositoryRelativePath
    )

    return (
        (Test-ProhibitedClaudeLocalPath `
            -RepositoryRelativePath $RepositoryRelativePath) -or
        (Test-GovernedInstructionPath `
            -RepositoryRelativePath $RepositoryRelativePath `
            -GovernedRootPaths $script:arrGovernedInstructionRootPaths) -or
        (Test-GovernedInstructionPathCaseMismatch `
            -RepositoryRelativePath $RepositoryRelativePath `
            -GovernedRootPaths $script:arrGovernedInstructionRootPaths) -or
        (Test-ExactPathCaseMismatch `
            -RepositoryRelativePath $RepositoryRelativePath `
            -CanonicalPaths $script:arrPushGovernedExactPaths)
    )
}

function Test-AgentInstructionWorkflowPath {
    # .SYNOPSIS
    # Tests whether one exact changed path requires agent validation.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string] $RepositoryRelativePath
    )

    return (
        (Test-ProhibitedClaudeLocalPath `
            -RepositoryRelativePath $RepositoryRelativePath) -or
        $RepositoryRelativePath -cmatch $script:strDecisionRecordDirectoryPathPattern -or
        $script:arrPushGovernedExactPaths -ccontains $RepositoryRelativePath -or
        (Test-ExactPathCaseMismatch `
            -RepositoryRelativePath $RepositoryRelativePath `
            -CanonicalPaths $script:arrPushGovernedExactPaths) -or
        (Test-GovernedInstructionPath `
            -RepositoryRelativePath $RepositoryRelativePath `
            -GovernedRootPaths $script:arrGovernedInstructionRootPaths) -or
        (Test-GovernedInstructionPathCaseMismatch `
            -RepositoryRelativePath $RepositoryRelativePath `
            -GovernedRootPaths $script:arrGovernedInstructionRootPaths)
    )
}

function Test-BackwardCommitMove {
    # .SYNOPSIS
    # Tests a strict backward commit move.
    # .PARAMETER RepositoryRootPath
    # The Git repository.
    # .PARAMETER BaseRevision
    # The before commit.
    # .PARAMETER HeadRevision
    # The after commit.
    # .EXAMPLE
    # Test-BackwardCommitMove @params
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][string] $RepositoryRootPath,
        [Parameter(Mandatory)][string] $BaseRevision,
        [Parameter(Mandatory)][string] $HeadRevision
    )

    if ($BaseRevision -eq $HeadRevision) {
        return $false
    }
    & git -C $RepositoryRootPath merge-base --is-ancestor `
        $HeadRevision $BaseRevision 2>$null
    if ($LASTEXITCODE -eq 0) {
        return $true
    }
    if ($LASTEXITCODE -eq 1) {
        return $false
    }
    throw 'Could not determine backward push ancestry.'
}

function Get-DecisionRecordPathFailure {
    # .SYNOPSIS
    # Gets a decision-name failure.
    # .PARAMETER RepositoryRelativePath
    # The path to test.
    # .EXAMPLE
    # Get-DecisionRecordPathFailure docs/decisions/security.md
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param([Parameter(Mandatory)][string] $RepositoryRelativePath)

    if ($RepositoryRelativePath -cmatch $script:strDecisionRecordDirectoryPathPattern -and
        $RepositoryRelativePath -cnotmatch $script:strDecisionRecordPathPattern) {
        Write-Output "$RepositoryRelativePath must use docs/decisions/NNNN-short-title.md."
    }
}

function Get-PushGovernedPathApplicability {
    # .SYNOPSIS
    # Selects push validation.
    # .DESCRIPTION
    # Uses authenticated range and endpoint paths.
    # .PARAMETER RepositoryRootPath
    # The Git repository.
    # .PARAMETER BaseRevision
    # The before ID.
    # .PARAMETER HeadRevision
    # The after ID.
    # .PARAMETER IsNewRef
    # True for creation.
    # .PARAMETER IsDeletedRef
    # True for deletion.
    # .EXAMPLE
    # Get-PushGovernedPathApplicability @params
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [string] $RepositoryRootPath,

        [Parameter(Mandatory)]
        [string] $BaseRevision,

        [Parameter(Mandatory)]
        [string] $HeadRevision,

        [Parameter(Mandatory)]
        [bool] $IsNewRef,

        [Parameter(Mandatory)]
        [bool] $IsDeletedRef
    )

    $strObjectIdPattern = '^(?:[0-9a-fA-F]{40}|[0-9a-fA-F]{64})$'
    $strZeroObjectIdPattern = '^(?:0{40}|0{64})$'
    if ($IsNewRef -and $IsDeletedRef) {
        throw 'A push ref cannot be both created and deleted.'
    }

    if ($IsDeletedRef) {
        if ($BaseRevision -notmatch $strObjectIdPattern -or
            $BaseRevision -match $strZeroObjectIdPattern -or
            $HeadRevision -notmatch $strZeroObjectIdPattern) {
            throw 'A deleted-ref push requires a valid base and an all-zero head.'
        }
        return [pscustomobject]@{
            ShouldValidate = $false
            Decision = 'DELETED_REF_HAS_NO_REMAINING_BYTES'
            ChangedPathCount = 0
        }
    }

    if ($HeadRevision -notmatch $strObjectIdPattern -or
        $HeadRevision -match $strZeroObjectIdPattern) {
        throw 'A retained push ref requires a valid nonzero head.'
    }
    $strCheckedOutRevision = [string] (
        & git -C $RepositoryRootPath rev-parse --verify 'HEAD^{commit}' 2>$null
    )
    if ($LASTEXITCODE -ne 0 -or
        -not [string]::Equals(
            $strCheckedOutRevision.Trim(),
            $HeadRevision,
            [StringComparison]::OrdinalIgnoreCase
        )) {
        throw 'The checked-out push revision does not match the exact event head.'
    }

    if ($IsNewRef) {
        if ($BaseRevision -notmatch $strZeroObjectIdPattern) {
            throw 'A new-ref push requires an all-zero base.'
        }
        return [pscustomobject]@{
            ShouldValidate = $true
            Decision = 'NEW_REF_REQUIRES_FAIL_CLOSED_VALIDATION'
            ChangedPathCount = 0
        }
    }

    if ($BaseRevision -notmatch $strObjectIdPattern -or
        $BaseRevision -match $strZeroObjectIdPattern) {
        throw 'An existing-ref push requires a valid nonzero base.'
    }
    foreach ($strRevision in @($BaseRevision, $HeadRevision)) {
        & git -C $RepositoryRootPath cat-file -e `
            "$strRevision`^{commit}" 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "Push endpoint commit is unavailable: $strRevision"
        }
    }

    $scriptBlockReadPaths = {
        param([string[]] $Arguments, [string] $Name, [switch] $Duplicates)

        $objStart = [Diagnostics.ProcessStartInfo]::new('git')
        $objStart.UseShellExecute = $false
        $objStart.CreateNoWindow = $true
        $objStart.RedirectStandardOutput = $true
        $objStart.RedirectStandardError = $true
        foreach ($strArgument in @('-C', $RepositoryRootPath) + $Arguments) {
            [void]$objStart.ArgumentList.Add($strArgument)
        }
        $objProcess = [Diagnostics.Process]::new()
        $objProcess.StartInfo = $objStart
        $objResult = Read-BoundedProcessData -Process $objProcess `
            -MaximumBytes $intGitPathListMaximumBytes -TimeoutMilliseconds 10000 `
            -DisplayName $Name
        if ($objResult.ExitCode -ne 0) {
            throw "Git $Name failed."
        }
        if ($null -ne $objResult.Bytes) {
            ConvertFrom-GitPathListData -Bytes ([byte[]] $objResult.Bytes) `
                -AllowDuplicatePath:$Duplicates
        }
    }
    $arrPaths = @(& $scriptBlockReadPaths -Name 'push range path enumeration' `
            -Duplicates -Arguments @(
                'log', '--format=', '--name-only', '-z', '-m', '--no-renames',
                '--no-ext-diff', '--no-textconv', "$BaseRevision..$HeadRevision", '--'
            ))
    $objPathSet = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $objPathSet.UnionWith([string[]] $arrPaths)
    foreach ($strPath in @(& $scriptBlockReadPaths `
                -Name 'push endpoint path enumeration' -Arguments @(
                    'diff', '--name-only', '-z', '--no-renames', '--no-ext-diff',
                    '--no-textconv', $BaseRevision, $HeadRevision, '--'
                ))) {
        if ($objPathSet.Add($strPath)) {
            $arrPaths += $strPath
        }
    }
    foreach ($strChangedPath in $arrPaths) {
        if (Test-AgentInstructionWorkflowPath `
                -RepositoryRelativePath $strChangedPath) {
            return [pscustomobject]@{
                ShouldValidate = $true
                Decision = 'GOVERNED_PATH_CHANGED'
                ChangedPathCount = $arrPaths.Count
            }
        }
    }
    return [pscustomobject]@{
        ShouldValidate = $false
        Decision = 'EXACT_UNGOVERNED_PUSH'
        ChangedPathCount = $arrPaths.Count
    }
}

function Get-GovernedInstructionInventoryFailure {
    # .SYNOPSIS
    # Finds drift between governed-instruction catalogs and tracked files.
    #
    # .DESCRIPTION
    # Compares two bounded repository-relative path sets with ordinal matching.
    # Duplicate, missing, and stale catalog entries fail closed.
    #
    # .PARAMETER CatalogPaths
    # The reviewed governed-instruction catalog paths.
    #
    # .PARAMETER TrackedPaths
    # The tracked paths in governed instruction-file families.
    #
    # .EXAMPLE
    # Get-GovernedInstructionInventoryFailure `
    #     -CatalogPaths @('AGENTS.md') -TrackedPaths @('AGENTS.md', 'CLAUDE.md')
    #
    # # Reports CLAUDE.md as missing from the reviewed catalog.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [string] One record for each inventory failure.
    #
    # .NOTES
    # Private helper; no positional parameters. Version: 1.0.20260820.1.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]] $CatalogPaths,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]] $TrackedPaths
    )

    $setCatalogPaths = [System.Collections.Generic.HashSet[string]]::new(
        [System.StringComparer]::Ordinal
    )
    foreach ($strCatalogPath in $CatalogPaths) {
        if ([string]::IsNullOrWhiteSpace($strCatalogPath) -or
            [IO.Path]::IsPathRooted($strCatalogPath) -or
            $strCatalogPath.Contains('\', [StringComparison]::Ordinal) -or
            $strCatalogPath -match '(?:^|/)\.\.(?:/|$)' -or
            $strCatalogPath.IndexOfAny([char[]] @("`0", "`r", "`n")) -ge 0) {
            Write-Output "The governed instruction catalog contains an unsafe path: $strCatalogPath"
            continue
        }
        if (-not $setCatalogPaths.Add($strCatalogPath)) {
            Write-Output "The governed instruction catalog contains a duplicate path: $strCatalogPath"
        }
    }

    $setTrackedPaths = [System.Collections.Generic.HashSet[string]]::new(
        [System.StringComparer]::Ordinal
    )
    foreach ($strTrackedPath in $TrackedPaths) {
        if (-not $setTrackedPaths.Add($strTrackedPath)) {
            Write-Output "The governed instruction inventory contains a duplicate path: $strTrackedPath"
        }
    }

    foreach ($strTrackedPath in $setTrackedPaths) {
        if (Test-ProhibitedClaudeLocalPath -RepositoryRelativePath $strTrackedPath) {
            Write-Output (
                'Tracked CLAUDE.local.md is prohibited operative project memory: ' +
                $strTrackedPath
            )
            continue
        }
        if (-not $setCatalogPaths.Contains($strTrackedPath)) {
            Write-Output (
                'Tracked governed instruction is missing from the catalog: ' +
                $strTrackedPath
            )
        }
    }
    foreach ($strCatalogPath in $setCatalogPaths) {
        if (-not $setTrackedPaths.Contains($strCatalogPath)) {
            Write-Output (
                'Governed instruction catalog path is not tracked at the validation ' +
                "revision: $strCatalogPath"
            )
        }
    }
}

function Get-DocumentationClaimFailure {
    # .SYNOPSIS
    # Finds false repository-specific documentation source claims.
    #
    # .DESCRIPTION
    # Rejects known absent placeholder-tooling claims and proves that each named
    # owner retained by the PSStyleGuide URL policy is tracked at the exact input
    # revision.
    #
    # .PARAMETER Content
    # The documentation instruction content to inspect.
    #
    # .PARAMETER TrackedPaths
    # The exact input revision's tracked repository paths.
    #
    # .EXAMPLE
    # Get-DocumentationClaimFailure -Content $strDocs -TrackedPaths $arrPaths
    #
    # # Returns one string for each false or unowned repository claim.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [string] One record for each documentation claim failure.
    #
    # .NOTES
    # Private helper; no positional parameters. Version: 1.0.20260823.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $Content,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]] $TrackedPaths
    )

    foreach ($strLiteral in $script:arrProhibitedDocumentationClaimLiterals) {
        if ($Content.Contains($strLiteral, [StringComparison]::Ordinal)) {
            Write-Output (
                'Documentation instructions name an absent repository-specific ' +
                "source or enforcement claim: $strLiteral"
            )
        }
    }

    $objMarkdownContext = Get-OperativeMarkdownContext -Content $Content
    $arrVisibleCodeSpans = [string[]]@($objMarkdownContext.ProseBlocks.Code)
    foreach ($strOwnerPath in $script:arrDocumentationClaimOwnerPaths) {
        if ($arrVisibleCodeSpans -cnotcontains $strOwnerPath) {
            Write-Output (
                'Documentation instructions are missing the named claim owner: ' +
                $strOwnerPath
            )
        }
        if ($TrackedPaths -cnotcontains $strOwnerPath) {
            Write-Output (
                'Documentation claim owner is not tracked at the validation ' +
                "revision: $strOwnerPath"
            )
        }
    }
}

function Get-DocumentMetadataContext {
    # .SYNOPSIS
    # Gets validated document-level metadata context.
    #
    # .DESCRIPTION
    # Locates the required fields in the parsed document header.
    #
    # .PARAMETER Content
    # The governed Markdown document text.
    #
    # .OUTPUTS
    # [pscustomobject] The metadata values and structural validation result.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [string] $Content,

        [Parameter()]
        [bool] $RequiresVersion = $true
    )

    $arrLines = [regex]::Split($Content, '\r\n|\r|\n')
    $arrParserLines = [string[]]$arrLines.Clone()
    $intBodyStart = 0
    if ($arrLines.Count -gt 0 -and $arrLines[0] -ceq '---') {
        $intFrontMatterEnd = -1
        for ($intLine = 1; $intLine -lt $arrLines.Count; $intLine++) {
            if ($arrLines[$intLine] -ceq '---') {
                $intFrontMatterEnd = $intLine
                break
            }
        }
        if ($intFrontMatterEnd -lt 0) {
            return [pscustomobject]@{
                Failure = 'must close leading YAML front matter with an exact --- delimiter.'
                VersionDate = $null
                UpdatedDate = $null
                Revision = $null
            }
        }
        for ($intLine = 0; $intLine -le $intFrontMatterEnd; $intLine++) {
            $arrParserLines[$intLine] = ''
        }
        $intBodyStart = $intFrontMatterEnd + 1
    }
    $strParserContent = $arrParserLines -join "`n"
    $objParseContext = Get-MarkdownParseContext `
        -Content $strParserContent `
        -LineCount $arrLines.Count
    $arrTopLevelBlocks = @($objParseContext.TopLevelBlocks)
    $arrTopLevelListItems = @($objParseContext.TopLevelListItems)

    $listH1Indices = [Collections.Generic.List[int]]::new()
    $listH2Indices = [Collections.Generic.List[int]]::new()
    for ($intIndex = 0; $intIndex -lt $arrTopLevelBlocks.Count; $intIndex++) {
        $objBlock = $arrTopLevelBlocks[$intIndex]
        if ($objBlock.Type -ceq 'heading_open' -and $objBlock.Tag -ceq 'h1') {
            $listH1Indices.Add($intIndex)
        }
        elseif ($objBlock.Type -ceq 'heading_open' -and $objBlock.Tag -ceq 'h2') {
            $listH2Indices.Add($intIndex)
        }
    }

    if ($listH1Indices.Count -ne 1 -or
        ($arrTopLevelBlocks[$listH1Indices[0]].Start - $intBodyStart) -ge 30) {
        return [pscustomobject]@{
            Failure = 'must contain exactly one document-level H1 within the first 30 body lines.'
            VersionDate = $null
            UpdatedDate = $null
            Revision = $null
        }
    }

    $strVersionPattern = '^\*\*Version:\*\* (?<Major>\d+)\.(?<Minor>\d+)\.' +
        '(?<Date>\d{8})\.(?<Revision>\d+)$'
    $listVersionRecords = [Collections.Generic.List[pscustomobject]]::new()
    for ($intIndex = 0; $intIndex -lt $arrTopLevelBlocks.Count; $intIndex++) {
        $objBlock = $arrTopLevelBlocks[$intIndex]
        if ($objBlock.Type -cne 'paragraph_open' -or
            $objBlock.Text -isnot [string] -or
            -not $objBlock.Text.StartsWith('Version:', [StringComparison]::Ordinal)) {
            continue
        }

        $listVersionRecords.Add([pscustomobject]@{
                BlockIndex = $intIndex
                Block = $objBlock
            })
    }

    $intH1Index = $listH1Indices[0]
    $intMetadataPredecessorIndex = $intH1Index
    $objVersionMatch = $null
    if ($RequiresVersion) {
        if ($listVersionRecords.Count -eq 1 -and
            $listVersionRecords[0].BlockIndex -eq ($intH1Index + 1) -and
            $listVersionRecords[0].Block.End -eq ($listVersionRecords[0].Block.Start + 1) -and
            ($listVersionRecords[0].Block.Start - $intBodyStart) -lt 30) {
            $objVersionMatch = [regex]::Match(
                $arrLines[$listVersionRecords[0].Block.Start], $strVersionPattern)
        }
        if ($null -eq $objVersionMatch -or -not $objVersionMatch.Success) {
            return [pscustomobject]@{
                Failure = 'must contain one exact document-level Version paragraph immediately after the H1 and within the first 30 body lines.'
                VersionDate = $null
                UpdatedDate = $null
                Revision = $null
            }
        }
        $intMetadataPredecessorIndex = $listVersionRecords[0].BlockIndex
    }

    $strMetadataPredecessor = if ($RequiresVersion) {'Version'} else {'the H1'}
    $strMetadataPlacementFailure = 'must place Metadata as the first level-two heading ' +
        "immediately after $strMetadataPredecessor and within the first 30 body lines."
    if ($listH2Indices.Count -eq 0) {
        return [pscustomobject]@{
            Failure = $strMetadataPlacementFailure
            VersionDate = $null
            UpdatedDate = $null
            Revision = $null
        }
    }

    $intMetadataIndex = $listH2Indices[0]
    $objMetadataBlock = $arrTopLevelBlocks[$intMetadataIndex]
    $intMetadataHeadingCount = @(
        $listH2Indices |
        Where-Object { $arrTopLevelBlocks[$_].Text -ceq 'Metadata' }
    ).Count
    if ($objMetadataBlock.Text -cne 'Metadata' -or
        $intMetadataHeadingCount -ne 1 -or
        $intMetadataIndex -ne ($intMetadataPredecessorIndex + 1) -or
        ($objMetadataBlock.Start - $intBodyStart) -ge 30) {
        return [pscustomobject]@{
            Failure = $strMetadataPlacementFailure
            VersionDate = $null
            UpdatedDate = $null
            Revision = $null
        }
    }

    $intMetadataSectionEnd = $arrLines.Count
    foreach ($intH2Index in $listH2Indices) {
        if ($intH2Index -gt $intMetadataIndex) {
            $intMetadataSectionEnd = $arrTopLevelBlocks[$intH2Index].Start
            break
        }
    }

    $arrRequiredFields = @(
        [pscustomobject]@{
            Name = 'Status'
            Pattern = '^- \*\*Status:\*\* (?<Value>Draft|Active|Deprecated)$'
        },
        [pscustomobject]@{
            Name = 'Owner'
            Pattern = '^- \*\*Owner:\*\* (?<Value>\S(?:.*\S)?)$'
        },
        [pscustomobject]@{
            Name = 'Last Updated'
            Pattern = '^- \*\*Last Updated:\*\* (?<Date>\d{4}-\d{2}-\d{2})$'
        },
        [pscustomobject]@{
            Name = 'Scope'
            Pattern = '^- \*\*Scope:\*\* (?<Value>\S(?:.*\S)?)$'
        }
    )
    $hashtableFieldMatches = @{}
    $hashtableFieldLineIndices = @{}
    foreach ($objField in $arrRequiredFields) {
        $arrFieldRecords = @(
            $arrTopLevelListItems |
                Where-Object {
                    $_.Text -is [string] -and
                    $_.Text.StartsWith(
                        "$($objField.Name):",
                        [StringComparison]::Ordinal
                    ) -and
                    $_.Start -gt $objMetadataBlock.Start -and
                    $_.Start -lt $intMetadataSectionEnd -and
                    ($_.Start - $intBodyStart) -lt 30
                }
        )
        $strFieldFailure = "must contain one exact top-level $($objField.Name) " +
            'list item in the Metadata section and within the first 30 body lines.'
        $boolFieldHasContinuation = $false
        if ($arrFieldRecords.Count -eq 1) {
            for ($intLine = $arrFieldRecords[0].Start + 1;
                $intLine -lt $arrFieldRecords[0].End;
                $intLine++) {
                if (-not [string]::IsNullOrWhiteSpace($arrLines[$intLine])) {
                    $boolFieldHasContinuation = $true
                    break
                }
            }
        }
        if ($arrFieldRecords.Count -ne 1 -or $boolFieldHasContinuation) {
            return [pscustomobject]@{
                Failure = $strFieldFailure
                VersionDate = $null
                UpdatedDate = $null
                Revision = $null
            }
        }
        $objFieldMatch = [regex]::Match(
            $arrLines[$arrFieldRecords[0].Start],
            $objField.Pattern
        )
        if (-not $objFieldMatch.Success) {
            return [pscustomobject]@{
                Failure = $strFieldFailure
                VersionDate = $null
                UpdatedDate = $null
                Revision = $null
            }
        }
        $hashtableFieldMatches[$objField.Name] = $objFieldMatch
        $hashtableFieldLineIndices[$objField.Name] = $arrFieldRecords[0].Start
    }
    $objUpdatedMatch = $hashtableFieldMatches['Last Updated']

    return [pscustomobject]@{
        Failure = $null
        VersionDate = if ($RequiresVersion) {$objVersionMatch.Groups['Date'].Value} else {$null}
        UpdatedDate = $objUpdatedMatch.Groups['Date'].Value
        Revision = if ($RequiresVersion) {$objVersionMatch.Groups['Revision'].Value} else {$null}
        VersionLineIndex = if ($RequiresVersion) {$listVersionRecords[0].Block.Start} else {-1}
        UpdatedLineIndex = $hashtableFieldLineIndices['Last Updated']
    }
}

function Get-DocumentMetadataTransitionFailure {
    # .SYNOPSIS
    # Finds metadata-policy failures in one document transition.
    #
    # .DESCRIPTION
    # Parses the current and optional parent metadata, validates calendar dates
    # and version monotonicity, detects rendered-content changes after removing
    # metadata fields, and enforces the expected UTC date when requested.
    # Valid transitions produce no output; each detected failure is written as a
    # diagnostic string.
    #
    # .PARAMETER Name
    # The governed document display name used in diagnostic output.
    #
    # .PARAMETER CurrentContent
    # The complete current Markdown content to parse and compare.
    #
    # .PARAMETER ParentContent
    # The complete parent Markdown content. Null represents a transition without
    # a governed parent document.
    #
    # .PARAMETER ExpectedUtcDate
    # The authenticated expected date in yyyy-MM-dd form. It may be empty only
    # when commit-date enforcement is not required for a rendered change.
    #
    # .PARAMETER IsNewDocumentTransition
    # True when a null ParentContent represents creation of a governed document.
    # False when the missing parent predates the active metadata policy.
    #
    # .PARAMETER RequireExpectedUtcDateForRenderedChange
    # True to require Last Updated to equal ExpectedUtcDate after rendered content
    # changes. False retains version and monotonicity checks without that equality.
    #
    # .EXAMPLE
    # $arrFailure = @(Get-DocumentMetadataTransitionFailure `
    #     -Name 'AGENTS.md' -CurrentContent $strCurrent `
    #     -ParentContent $strParent -ExpectedUtcDate '2026-08-27' `
    #     -IsNewDocumentTransition $false)
    #
    # # Returns no strings when the changed document has matching date and version.
    #
    # .EXAMPLE
    # $arrFailure = @(Get-DocumentMetadataTransitionFailure `
    #     -Name 'AGENTS.md' -CurrentContent $strBackdated `
    #     -ParentContent $strParent -ExpectedUtcDate '2026-08-27' `
    #     -IsNewDocumentTransition $false)
    #
    # # Returns a diagnostic when rendered content has stale Last Updated metadata.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [string] Zero or more exact failure diagnostics. No output means the
    # transition satisfies metadata structure, date, version, and freshness rules.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Positional parameters are disabled. Internal callers must use named
    # parameters. Version: 1.1.20260827.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string] $CurrentContent,

        [Parameter()]
        [AllowNull()]
        [string] $ParentContent,

        [Parameter()]
        [AllowEmptyString()]
        [string] $ExpectedUtcDate = '',

        [Parameter(Mandatory)]
        [bool] $IsNewDocumentTransition,

        [Parameter()]
        [bool] $RequireExpectedUtcDateForRenderedChange = $true
    )

    $objCurrentMetadata = Get-DocumentMetadataContext -Content $CurrentContent
    if ($null -ne $objCurrentMetadata.Failure) {
        Write-Output "$Name $($objCurrentMetadata.Failure)"
        return
    }

    $strCurrentVersionDate = $objCurrentMetadata.VersionDate
    $strCurrentUpdatedDate = $objCurrentMetadata.UpdatedDate
    if (-not (Test-MetadataCalendarDatePair `
            -VersionDate $strCurrentVersionDate `
            -UpdatedDate $strCurrentUpdatedDate)) {
        Write-Output "$Name Version and Last Updated must contain one real matching calendar date."
        return
    }
    if ([string]::CompareOrdinal(
            $strCurrentUpdatedDate,
            $script:strMaximumMetadataUtcDate
        ) -gt 0) {
        Write-Output (
            "$Name Last Updated $strCurrentUpdatedDate must not be later than trusted UTC " +
            "date $script:strMaximumMetadataUtcDate."
        )
        return
    }

    if ([string]::IsNullOrEmpty($ParentContent)) {
        if (-not $IsNewDocumentTransition) {
            return
        }
        if (-not $RequireExpectedUtcDateForRenderedChange) {
            return
        }
        if ([string]::IsNullOrEmpty($ExpectedUtcDate) -or
            -not (Test-MetadataCalendarDatePair `
                -VersionDate $ExpectedUtcDate.Replace('-', '') `
                -UpdatedDate $ExpectedUtcDate)) {
            Write-Output "The expected UTC date for $Name is unavailable or invalid."
            return
        }
        if ($strCurrentUpdatedDate -cne $ExpectedUtcDate) {
            Write-Output (
                "$Name Last Updated must be $ExpectedUtcDate after a rendered-content change."
            )
        }
        return
    }

    $objParentMetadata = Get-DocumentMetadataContext -Content $ParentContent
    if ($null -ne $objParentMetadata.Failure) {
        Write-Output "The parent of $Name $($objParentMetadata.Failure)"
        return
    }
    $strParentVersionDate = $objParentMetadata.VersionDate
    $strParentUpdatedDate = $objParentMetadata.UpdatedDate
    if (-not (Test-MetadataCalendarDatePair `
            -VersionDate $strParentVersionDate `
            -UpdatedDate $strParentUpdatedDate)) {
        Write-Output "The parent of $Name must contain one real matching calendar date."
        return
    }
    if ([string]::CompareOrdinal(
            $strParentUpdatedDate,
            $script:strMaximumMetadataUtcDate
        ) -gt 0) {
        Write-Output (
            "The parent of $Name Last Updated $strParentUpdatedDate must not be later than " +
            "trusted UTC date $script:strMaximumMetadataUtcDate."
        )
        return
    }

    $intCurrentRevision = [int64] 0
    $intParentRevision = [int64] 0
    if (-not [int64]::TryParse(
            $objCurrentMetadata.Revision,
            [ref] $intCurrentRevision
        ) -or
        -not [int64]::TryParse(
            $objParentMetadata.Revision,
            [ref] $intParentRevision
        )) {
        Write-Output "$Name Version revision must fit in a signed 64-bit integer."
        return
    }

    $intVersionDateComparison = [string]::CompareOrdinal(
        $strCurrentVersionDate,
        $strParentVersionDate
    )
    $strCurrentComparison = ConvertTo-MetadataComparisonText `
        -Content $CurrentContent -MetadataContext $objCurrentMetadata
    $strParentComparison = ConvertTo-MetadataComparisonText `
        -Content $ParentContent -MetadataContext $objParentMetadata
    $boolRenderedContentChanged = $strCurrentComparison -cne $strParentComparison
    if ($intVersionDateComparison -lt 0) {
        Write-Output (
            "$Name Version date must not move backward from $strParentVersionDate to " +
            "$strCurrentVersionDate."
        )
    }
    elseif ($intVersionDateComparison -eq 0 -and
        $intCurrentRevision -lt $intParentRevision) {
        Write-Output (
            "$Name Version revision must not decrease from $intParentRevision to " +
            "$intCurrentRevision."
        )
    }

    if (-not $boolRenderedContentChanged) {
        return
    }

    if ($RequireExpectedUtcDateForRenderedChange) {
        if (-not (Test-MetadataCalendarDatePair `
                -VersionDate $ExpectedUtcDate.Replace('-', '') `
                -UpdatedDate $ExpectedUtcDate)) {
            Write-Output "The expected UTC date for $Name is unavailable or invalid."
            return
        }
        if ($strCurrentUpdatedDate -cne $ExpectedUtcDate) {
            Write-Output (
                "$Name Last Updated must be $ExpectedUtcDate after a rendered-content change."
            )
        }
    }

    if ($intVersionDateComparison -eq 0) {
        if ($intParentRevision -eq [int64]::MaxValue) {
            Write-Output "The parent $Name Version revision cannot be incremented safely."
        }
        elseif ($intCurrentRevision -eq $intParentRevision) {
            Write-Output (
                "$Name Version revision must be greater than $intParentRevision after a " +
                'same-day content change.'
            )
        }
    }
}

function Get-DocumentMetadataRangeTransitionFailure {
    # .SYNOPSIS
    # Finds metadata-policy failures across document transition records.
    #
    # .DESCRIPTION
    # Evaluates each parent-to-current transition with
    # Get-DocumentMetadataTransitionFailure. It preserves each transition's
    # authenticated date requirement and prefixes every failure with the parent
    # and current commit identities for usable range diagnostics.
    #
    # .PARAMETER Name
    # The governed document display name used in diagnostic output.
    #
    # .PARAMETER TransitionContext
    # Ordered transition records. Each record supplies CurrentContent,
    # ParentContent, ExpectedUtcDate, CurrentRevision, and ParentRevision. The
    # optional RequireExpectedUtcDateForRenderedChange property defaults to true.
    #
    # .EXAMPLE
    # $arrFailure = @(Get-DocumentMetadataRangeTransitionFailure `
    #     -Name 'AGENTS.md' -TransitionContext $arrTransitions)
    #
    # # Returns no strings when every transition satisfies the metadata policy.
    #
    # .EXAMPLE
    # Get-DocumentMetadataRangeTransitionFailure `
    #     -Name 'AGENTS.md' -TransitionContext $arrTransitions
    #
    # # Writes one commit-prefixed string for every failed transition rule.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [string] Zero or more diagnostics in the form Name transition
    # ParentRevision..CurrentRevision followed by the transition failure. No
    # output means every supplied transition passed.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Positional parameters are disabled. Internal callers must use named
    # parameters. Version: 1.1.20260827.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [pscustomobject[]] $TransitionContext
    )

    foreach ($objTransition in $TransitionContext) {
        $objDateRequirementProperty =
            $objTransition.PSObject.Properties['RequireExpectedUtcDateForRenderedChange']
        $boolRequireExpectedUtcDate = if ($null -eq $objDateRequirementProperty) {
            $true
        }
        else {
            [bool] $objDateRequirementProperty.Value
        }
        $arrTransitionFailures = @(Get-DocumentMetadataTransitionFailure `
                -Name $Name `
                -CurrentContent $objTransition.CurrentContent `
                -ParentContent $objTransition.ParentContent `
                -ExpectedUtcDate $objTransition.ExpectedUtcDate `
                -IsNewDocumentTransition ($null -eq $objTransition.ParentContent) `
                -RequireExpectedUtcDateForRenderedChange $boolRequireExpectedUtcDate)
        foreach ($strFailure in $arrTransitionFailures) {
            Write-Output (
                "$Name transition $($objTransition.ParentRevision).." +
                "$($objTransition.CurrentRevision): $strFailure"
            )
        }
    }
}

function Get-TrustRootRangeMutationFailure {
    # .SYNOPSIS
    # Finds proposed changes to trusted validation files in an exact Git range.
    #
    # .DESCRIPTION
    # Authenticates both endpoint commits and compares the requested trust-root
    # paths without rename detection, external diff drivers, or text conversion.
    # Each changed trust root produces a failure. Invalid or unavailable Git
    # state throws so an indeterminate comparison cannot pass.
    #
    # .PARAMETER RepositoryRootPath
    # The repository root used for immutable Git object and diff operations.
    #
    # .PARAMETER BaseRevision
    # The valid nonzero base commit object ID for the comparison.
    #
    # .PARAMETER HeadRevision
    # The valid nonzero head commit object ID for the comparison.
    #
    # .PARAMETER RepositoryRelativePath
    # One or more exact repository-relative trusted validation paths to compare.
    #
    # .EXAMPLE
    # $arrFailure = @(Get-TrustRootRangeMutationFailure `
    #     -RepositoryRootPath $strRoot -BaseRevision $strBase `
    #     -HeadRevision $strHead `
    #     -RepositoryRelativePath @('.gitattributes', '.github/workflows/check.yml'))
    #
    # # Returns no strings when neither trust-root path changed.
    #
    # .EXAMPLE
    # Get-TrustRootRangeMutationFailure `
    #     -RepositoryRootPath $strRoot -BaseRevision $strBase `
    #     -HeadRevision $strHead -RepositoryRelativePath '.gitattributes'
    #
    # # Writes one failure when the range changes .gitattributes.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [string] Zero or more failure diagnostics, one for each changed trust-root
    # path. No output means the requested paths are unchanged.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API
    # surface. Parameters, return shape, and positional contract may change
    # without notice.
    #
    # Positional parameters are disabled. Internal callers must use named
    # parameters. Version: 1.1.20260827.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $RepositoryRootPath,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $BaseRevision,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $HeadRevision,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]] $RepositoryRelativePath
    )

    $strObjectIdPattern = '^(?:[0-9a-fA-F]{40}|[0-9a-fA-F]{64})$'
    foreach ($strRevision in @($BaseRevision, $HeadRevision)) {
        if ($strRevision -notmatch $strObjectIdPattern) {
            throw "The trusted validation range contains an invalid object ID: $strRevision"
        }
        & git -C $RepositoryRootPath cat-file -e "$strRevision`^{commit}" 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "The trusted validation range commit is unavailable: $strRevision"
        }
    }

    $arrChangedPaths = @(
        & git -C $RepositoryRootPath diff --name-only --no-renames `
            --no-ext-diff --no-textconv $BaseRevision $HeadRevision -- `
            $RepositoryRelativePath
    )
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not compare the trusted validation paths.'
    }
    foreach ($strTrustPath in $RepositoryRelativePath) {
        if ($arrChangedPaths -cnotcontains $strTrustPath) {
            continue
        }
        Write-Output (
            "Pull request changes trusted validation path $strTrustPath. " +
            'Update this trust root only through an authorized trusted-base maintenance path.'
        )
    }
}

function Get-GovernedDocumentCommitTransitionFailure {
    # .SYNOPSIS
    # Checks one governed commit.
    # .DESCRIPTION
    # Checks each immutable direct-parent transition.
    # .PARAMETER Name
    # The display name.
    # .PARAMETER RepositoryRootPath
    # The Git repository.
    # .PARAMETER RepositoryRelativePath
    # The document path.
    # .PARAMETER MaximumBytes
    # The blob limit.
    # .PARAMETER CommitRevision
    # The commit ID.
    # .PARAMETER PolicyRepositoryRelativePath
    # The policy path.
    # .PARAMETER PolicyMaximumBytes
    # The policy limit.
    # .PARAMETER PolicyMarker
    # The policy marker.
    # .PARAMETER RequireExpectedUtcDateForRenderedChange
    # True to require the commit date.
    # .PARAMETER RequiresVersion
    # True if versioned.
    # .EXAMPLE
    # Get-GovernedDocumentCommitTransitionFailure @params
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string] $RepositoryRootPath,

        [Parameter(Mandatory)]
        [string] $RepositoryRelativePath,

        [Parameter(Mandatory)]
        [ValidateRange(1, 2147483646)]
        [int] $MaximumBytes,

        [Parameter(Mandatory)]
        [string] $CommitRevision,

        [Parameter(Mandatory)]
        [string] $PolicyRepositoryRelativePath,

        [Parameter(Mandatory)]
        [ValidateRange(1, 2147483646)]
        [int] $PolicyMaximumBytes,

        [Parameter(Mandatory)]
        [string] $PolicyMarker,

        [Parameter()]
        [bool] $RequireExpectedUtcDateForRenderedChange = $false,

        [Parameter()]
        [bool] $RequiresVersion = $true
    )

    $strObjectIdPattern = '^(?:[0-9a-fA-F]{40}|[0-9a-fA-F]{64})$'
    if ($CommitRevision -notmatch $strObjectIdPattern) {
        throw "The governed direct-transition commit is invalid: $CommitRevision"
    }
    & git -C $RepositoryRootPath cat-file -e "$CommitRevision`^{commit}" 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "The governed direct-transition commit is unavailable: $CommitRevision"
    }
    $boolUseWorktreePolicy = $false
    if ($CommitRevision -ceq $script:strCheckedOutRevision) {
        & git -C $RepositoryRootPath diff --quiet --no-ext-diff --no-textconv `
            $CommitRevision -- $PolicyRepositoryRelativePath
        if ($LASTEXITCODE -eq 1) {
            $boolUseWorktreePolicy = $true
        } elseif ($LASTEXITCODE -ne 0) {
            throw 'Could not compare the checked-out policy with its commit.'
        }
    }
    if ($boolUseWorktreePolicy) {
        $arrPolicyBytes = [byte[]] @(
            Read-RepositoryInputData `
                -Path (Join-Path $RepositoryRootPath $PolicyRepositoryRelativePath) `
                -RepositoryRootPath $RepositoryRootPath `
                -RepositoryRelativePath $PolicyRepositoryRelativePath `
                -DisplayName $PolicyRepositoryRelativePath `
                -MaximumBytes $PolicyMaximumBytes
        )
        $strPolicy = ConvertFrom-StrictUtf8Data `
            -Bytes $arrPolicyBytes -DisplayName $PolicyRepositoryRelativePath
        if (-not $strPolicy.Contains($PolicyMarker, [StringComparison]::Ordinal)) {
            throw 'The checked-out policy is missing its governance marker.'
        }
    } elseif (-not (Test-HistoricalPolicyMarker `
                -RepositoryRootPath $RepositoryRootPath `
                -Revision $CommitRevision `
                -RepositoryRelativePath $PolicyRepositoryRelativePath `
                -Literal $PolicyMarker)) {
            return [string[]] @()
    }

    $strParentLine = [string] (
        & git -C $RepositoryRootPath rev-list --parents -n 1 $CommitRevision
    )
    if ($LASTEXITCODE -ne 0) {
        throw "Could not read the parents of metadata range commit $CommitRevision."
    }
    $arrCommitAndParents = @($strParentLine.Trim() -split '\s+')
    if ($arrCommitAndParents.Count -eq 0 -or
        $arrCommitAndParents[0] -notmatch $strObjectIdPattern -or
        -not [string]::Equals(
            $arrCommitAndParents[0],
            $CommitRevision,
            [StringComparison]::OrdinalIgnoreCase
        )) {
        throw "Git returned an invalid identity for metadata range commit $CommitRevision."
    }
    if ($arrCommitAndParents.Count -eq 1) {
        return [string[]] @()
    }
    $intParentCount = $arrCommitAndParents.Count - 1
    if ($intParentCount -gt $intMetadataMaximumParents) {
        throw (
            "Metadata range commit $CommitRevision has $intParentCount parents; " +
            "the maximum is $intMetadataMaximumParents."
        )
    }

    $listChangedParents = [Collections.Generic.List[pscustomobject]]::new()
    foreach ($strParentRevision in $arrCommitAndParents[1..$intParentCount]) {
        if ($strParentRevision -notmatch $strObjectIdPattern) {
            throw "Git returned an invalid parent for metadata range commit $CommitRevision."
        }
        & git -C $RepositoryRootPath cat-file -e `
            "$strParentRevision`^{commit}" 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "Git returned an unavailable parent for metadata range commit $CommitRevision."
        }

        & git -C $RepositoryRootPath diff --quiet --no-ext-diff --no-textconv `
            $strParentRevision $CommitRevision -- $RepositoryRelativePath
        $intDiffExitCode = $LASTEXITCODE
        if ($intDiffExitCode -eq 0) {
            continue
        }
        if ($intDiffExitCode -ne 1) {
            throw (
                "Could not compare $RepositoryRelativePath for metadata range commit " +
                "$CommitRevision."
            )
        }
        $listChangedParents.Add([pscustomobject]@{
                Revision = $strParentRevision
                HasPolicyMarker = Test-HistoricalPolicyMarker `
                    -RepositoryRootPath $RepositoryRootPath `
                    -Revision $strParentRevision `
                    -RepositoryRelativePath $PolicyRepositoryRelativePath `
                    -Literal $PolicyMarker
            })
    }
    if ($listChangedParents.Count -eq 0) {
        return [string[]] @()
    }

    $strCommitTimestamp = [string] (
        & git -C $RepositoryRootPath show -s --format=%cI $CommitRevision
    )
    if ($LASTEXITCODE -ne 0) {
        throw "Could not read the timestamp of metadata range commit $CommitRevision."
    }
    $objCommitTimestamp = [DateTimeOffset]::MinValue
    if (-not [DateTimeOffset]::TryParse(
            $strCommitTimestamp.Trim(),
            [ref] $objCommitTimestamp
        )) {
        throw "Metadata range commit $CommitRevision has an invalid timestamp."
    }
    if ($objCommitTimestamp -gt $script:objMaximumCommitUtcTimestamp) {
        Write-Output (
            "Metadata range commit $CommitRevision timestamp " +
            "$($objCommitTimestamp.ToUniversalTime().ToString('o')) must not be later than " +
            "trusted UTC $($script:objMaximumCommitUtcTimestamp.ToString('o'))."
        )
        return
    }

    $strCurrentContent = Read-GitRevisionText `
        -RepositoryRootPath $RepositoryRootPath `
        -Revision $CommitRevision `
        -RepositoryRelativePath $RepositoryRelativePath `
        -MaximumBytes $MaximumBytes `
        -RequireRegularFile
    $listTransitions = [Collections.Generic.List[pscustomobject]]::new()
    foreach ($objChangedParent in $listChangedParents) {
        $strParentContent = if ($objChangedParent.HasPolicyMarker) {
            & git -C $RepositoryRootPath cat-file -e `
                "$($objChangedParent.Revision)`:$RepositoryRelativePath" 2>$null
            if ($LASTEXITCODE -ne 0) {
                $null
            }
            else {
            Read-GitRevisionText `
                -RepositoryRootPath $RepositoryRootPath `
                    -Revision $objChangedParent.Revision `
                -RepositoryRelativePath $RepositoryRelativePath `
                -MaximumBytes $MaximumBytes `
                -RequireRegularFile
            }
        }
        else {
            $null
        }
        $listTransitions.Add([pscustomobject]@{
                CurrentContent = $strCurrentContent
                ParentContent = $strParentContent
                ExpectedUtcDate = $objCommitTimestamp.UtcDateTime.ToString('yyyy-MM-dd')
                CurrentRevision = $CommitRevision
                ParentRevision = $objChangedParent.Revision
                RequireExpectedUtcDateForRenderedChange =
                    $RequireExpectedUtcDateForRenderedChange
            })
    }

    if ($RequiresVersion) {
        return Get-DocumentMetadataRangeTransitionFailure `
            -Name $Name `
            -TransitionContext $listTransitions.ToArray()
    }
    foreach ($objTransition in $listTransitions) {
        Get-LastUpdatedMetadataFreshnessFailure `
            -Name $Name `
            -CurrentContent $objTransition.CurrentContent `
            -BaseContent $objTransition.ParentContent `
            -TrustedEventUtcDate $(if ($RequireExpectedUtcDateForRenderedChange) {
                    $objTransition.ExpectedUtcDate
                } else { '' })
    }
}

function Get-GovernedDocumentRangeTransitionFailure {
    # .SYNOPSIS
    # Checks a governed commit range.
    # .DESCRIPTION
    # Validates each policy-applicable commit.
    # .PARAMETER Name
    # The display name.
    # .PARAMETER RepositoryRootPath
    # The Git repository.
    # .PARAMETER RepositoryRelativePath
    # The document path.
    # .PARAMETER MaximumBytes
    # The blob limit.
    # .PARAMETER BaseRevision
    # The base ID.
    # .PARAMETER HeadRevision
    # The head ID.
    # .PARAMETER InputRevision
    # The validation revision.
    # .PARAMETER IsNewRefRange
    # True for a new ref.
    # .PARAMETER PolicyRepositoryRelativePath
    # The policy path.
    # .PARAMETER PolicyMaximumBytes
    # The policy limit.
    # .PARAMETER PolicyMarker
    # The policy marker.
    # .PARAMETER RequireExpectedUtcDateForRenderedChange
    # True to require commit dates.
    # .PARAMETER RequiresVersion
    # True if versioned.
    # .EXAMPLE
    # Get-GovernedDocumentRangeTransitionFailure @params
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $Name,

        [Parameter(Mandatory)]
        [string] $RepositoryRootPath,

        [Parameter(Mandatory)]
        [string] $RepositoryRelativePath,

        [Parameter(Mandatory)]
        [ValidateRange(1, 2147483646)]
        [int] $MaximumBytes,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $BaseRevision,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $HeadRevision,

        [Parameter()]
        [AllowEmptyString()]
        [string] $InputRevision = '',

        [Parameter(Mandatory)]
        [bool] $IsNewRefRange,

        [Parameter(Mandatory)]
        [string] $PolicyRepositoryRelativePath,

        [Parameter(Mandatory)]
        [ValidateRange(1, 2147483646)]
        [int] $PolicyMaximumBytes,

        [Parameter(Mandatory)]
        [string] $PolicyMarker,

        [Parameter()]
        [bool] $RequireExpectedUtcDateForRenderedChange = $false,

        [Parameter()]
        [bool] $RequiresVersion = $true
    )

    if ([string]::IsNullOrEmpty($BaseRevision) -and
        [string]::IsNullOrEmpty($HeadRevision)) {
        if ($IsNewRefRange) {
            throw 'A new-ref metadata event range must supply base and head revisions.'
        }
        return [string[]] @()
    }
    if ([string]::IsNullOrEmpty($BaseRevision) -or
        [string]::IsNullOrEmpty($HeadRevision)) {
        throw 'The metadata event range must supply both base and head revisions.'
    }

    $strObjectIdPattern = '^(?:[0-9a-fA-F]{40}|[0-9a-fA-F]{64})$'
    $strZeroObjectIdPattern = '^(?:0{40}|0{64})$'
    $boolBaseIsZeroObjectId = $BaseRevision -match $strZeroObjectIdPattern
    if ($IsNewRefRange -and -not $boolBaseIsZeroObjectId) {
        throw 'A new-ref metadata event range requires an all-zero base revision.'
    }
    if (-not $IsNewRefRange -and $boolBaseIsZeroObjectId) {
        throw 'An all-zero metadata event-range base requires the new-ref flag.'
    }
    if ($HeadRevision -match $strZeroObjectIdPattern) {
        throw 'The metadata event-range head must not be an all-zero object ID.'
    }

    foreach ($strRevision in @($BaseRevision, $HeadRevision)) {
        if ($strRevision -notmatch $strObjectIdPattern) {
            throw "The metadata event range contains an invalid object ID: $strRevision"
        }
        if ($strRevision -eq $BaseRevision -and $boolBaseIsZeroObjectId) {
            continue
        }
        & git -C $RepositoryRootPath cat-file -e "$strRevision`^{commit}" 2>$null
        if ($LASTEXITCODE -ne 0) {
            throw "The metadata event-range commit is unavailable: $strRevision"
        }
    }

    $strValidationRevision = if ([string]::IsNullOrEmpty($InputRevision)) {
        'HEAD'
    }
    else {
        $InputRevision
    }
    $strCheckedOutHead = [string] (
        & git -C $RepositoryRootPath rev-parse --verify `
            "$strValidationRevision`^{commit}"
    )
    if ($LASTEXITCODE -ne 0 -or
        -not [string]::Equals(
            $strCheckedOutHead.Trim(),
            $HeadRevision,
            [StringComparison]::OrdinalIgnoreCase
        )) {
        throw "The metadata event-range head does not match the validation revision: $HeadRevision"
    }
    if ([string]::Equals(
            $BaseRevision,
            $HeadRevision,
            [StringComparison]::OrdinalIgnoreCase
        )) {
        return [string[]] @()
    }

    $boolHeadHasPolicyMarker = Test-HistoricalPolicyMarker `
        -RepositoryRootPath $RepositoryRootPath `
        -Revision $HeadRevision `
        -RepositoryRelativePath $PolicyRepositoryRelativePath `
        -Literal $PolicyMarker
    if (-not $boolHeadHasPolicyMarker) {
        throw "The metadata event-range head does not contain policy marker $PolicyMarker."
    }

    $boolBaseHasPolicyMarker = $false
    if (-not $IsNewRefRange) {
        $boolBaseHasPolicyMarker = Test-HistoricalPolicyMarker `
            -RepositoryRootPath $RepositoryRootPath `
            -Revision $BaseRevision `
            -RepositoryRelativePath $PolicyRepositoryRelativePath `
            -Literal $PolicyMarker
    }
    if (-not $boolBaseHasPolicyMarker) {
        if ($IsNewRefRange) {
            $arrPolicyPathCommits = @(
                & git -C $RepositoryRootPath log --reverse --topo-order `
                    --format=%H "-S$PolicyMarker" $HeadRevision -- `
                    $PolicyRepositoryRelativePath 2>&1
            )
        }
        else {
            $arrPolicyPathCommits = @(
                & git -C $RepositoryRootPath log --reverse --topo-order `
                    --format=%H "-S$PolicyMarker" "$BaseRevision..$HeadRevision" -- `
                    $PolicyRepositoryRelativePath 2>&1
            )
        }
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not enumerate metadata policy-marker changes.'
        }

        $strPolicyIntroductionCommit = ''
        foreach ($strPolicyCommitValue in $arrPolicyPathCommits) {
            $strPolicyCommit = ([string]$strPolicyCommitValue).Trim()
            if ($strPolicyCommit -notmatch $strObjectIdPattern) {
                throw "Git returned an invalid metadata policy commit: $strPolicyCommit"
            }
            if (Test-HistoricalPolicyMarker `
                    -RepositoryRootPath $RepositoryRootPath `
                    -Revision $strPolicyCommit `
                    -RepositoryRelativePath $PolicyRepositoryRelativePath `
                    -Literal $PolicyMarker) {
                $strPolicyIntroductionCommit = $strPolicyCommit
                break
            }
        }
        if ([string]::IsNullOrEmpty($strPolicyIntroductionCommit)) {
            throw "Could not locate the introduction of metadata policy marker $PolicyMarker."
        }

        $strPolicyParentLine = [string] (
            & git -C $RepositoryRootPath rev-list --parents -n 1 `
                $strPolicyIntroductionCommit
        )
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not read the metadata policy-introduction parent.'
        }
        $arrPolicyCommitAndParents = @($strPolicyParentLine.Trim() -split ' ')
        if ($arrPolicyCommitAndParents.Count -eq 1 -and $IsNewRefRange) {
            $strEffectiveBaseRevision = ''
        }
        elseif ($arrPolicyCommitAndParents.Count -lt 2 -or
            $arrPolicyCommitAndParents[1] -notmatch $strObjectIdPattern) {
            throw 'The metadata policy-introduction commit must have a valid first parent.'
        }
        else {
            $strEffectiveBaseRevision = $arrPolicyCommitAndParents[1]
        }
    }
    else {
        $strEffectiveBaseRevision = $BaseRevision
    }

    if ([string]::IsNullOrEmpty($strEffectiveBaseRevision)) {
        $arrRangeCommits = @(
            & git -C $RepositoryRootPath rev-list --reverse --topo-order `
                $HeadRevision 2>&1
        )
    }
    else {
        $arrRangeCommits = @(
            & git -C $RepositoryRootPath rev-list --reverse --topo-order `
                "$strEffectiveBaseRevision..$HeadRevision" 2>&1
        )
    }
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not enumerate the metadata event range.'
    }

    foreach ($strRangeCommitValue in $arrRangeCommits) {
        $strRangeCommit = ([string]$strRangeCommitValue).Trim()
        $arrCommitFailures = @(Get-GovernedDocumentCommitTransitionFailure `
            -Name $Name `
            -RepositoryRootPath $RepositoryRootPath `
            -RepositoryRelativePath $RepositoryRelativePath `
            -MaximumBytes $MaximumBytes `
            -CommitRevision $strRangeCommit `
            -PolicyRepositoryRelativePath $PolicyRepositoryRelativePath `
            -PolicyMaximumBytes $PolicyMaximumBytes `
            -PolicyMarker $PolicyMarker `
            -RequireExpectedUtcDateForRenderedChange `
                $RequireExpectedUtcDateForRenderedChange `
            -RequiresVersion $RequiresVersion)
        foreach ($strCommitFailure in $arrCommitFailures) {
            Write-Output $strCommitFailure
        }
    }
}

function Get-TomlSemanticStatementContext {
    # .SYNOPSIS
    # Gets semantic TOML statement locations.
    #
    # .DESCRIPTION
    # Scans physical lines and writes each nonblank, noncomment TOML statement
    # with its zero-based text offset.
    #
    # .PARAMETER Content
    # The TOML text to scan.
    #
    # .EXAMPLE
    # $arrStatements = @(Get-TomlSemanticStatementContext -Content $strToml)
    #
    # # Collects semantic statement text and source offsets.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [pscustomobject] One semantic TOML statement and source offset.
    #
    # .NOTES
    # Private helper; no positional parameters.
    # Version: 1.0.20260819.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Content
    )

    $intLineStart = 0
    while ($intLineStart -lt $Content.Length) {
        $intLineEnd = $Content.IndexOfAny([char[]] "`r`n", $intLineStart)
        if ($intLineEnd -lt 0) {
            $intLineEnd = $Content.Length
        }

        $strLine = $Content.Substring($intLineStart, $intLineEnd - $intLineStart)
        $strTrimmedLine = $strLine.TrimStart()
        if ($strTrimmedLine.Length -gt 0 -and
            -not $strTrimmedLine.StartsWith('#', [StringComparison]::Ordinal)) {
            Write-Output ([pscustomobject]@{
                    Text = $strLine
                    Index = $intLineStart
                })
        }

        if ($intLineEnd -eq $Content.Length) {
            break
        }
        if ($Content[$intLineEnd] -eq "`r" -and
            ($intLineEnd + 1) -lt $Content.Length -and
            $Content[$intLineEnd + 1] -eq "`n") {
            $intLineStart = $intLineEnd + 2
        }
        else {
            $intLineStart = $intLineEnd + 1
        }
    }
}

function Get-GitHubPluginEnablementContext {
    # .SYNOPSIS
    # Gets GitHub plugin enablement locations from TOML.
    #
    # .DESCRIPTION
    # Uses parser-confirmed statement identities and returns the matching table
    # count, enablement count, value, and value location.
    #
    # .PARAMETER Content
    # The project TOML text to inspect.
    #
    # .EXAMPLE
    # Get-GitHubPluginEnablementContext -Content $strCodexConfigContent
    #
    # # Returns the table and enabled-value match context.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [pscustomobject] Counts, value, and source location for plugin enablement.
    #
    # .NOTES
    # Private helper; no positional parameters.
    # Version: 1.1.20260820.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [string] $Content
    )

    $objTomlContext = Get-TomlParseContext -Content $Content
    $arrStatements = @(Get-TomlSemanticStatementContext -Content $Content)
    $boolTableHeaderMatches = [string]::IsNullOrEmpty($objTomlContext.Failure) -and
        $objTomlContext.PluginHeaderIsSecondStatement
    $intEnablementMatchCount = 0
    $strEnabledValue = ''
    $intEnabledValueIndex = -1
    $intEnabledValueLength = 0
    if ($boolTableHeaderMatches -and
        $objTomlContext.PluginEnablementIsThirdStatement -and
        $arrStatements.Count -gt 2 -and
        $objTomlContext.PluginEnabledValueStatementOffset -ge 0 -and
        ($objTomlContext.PluginEnabledValueStatementOffset +
            $objTomlContext.PluginEnabledValueLength) -le $arrStatements[2].Text.Length) {
        $intEnablementMatchCount = 1
        $intEnabledValueLength = $objTomlContext.PluginEnabledValueLength
        $strEnabledValue = $arrStatements[2].Text.Substring(
            $objTomlContext.PluginEnabledValueStatementOffset,
            $intEnabledValueLength
        )
        $intEnabledValueIndex = $arrStatements[2].Index +
            $objTomlContext.PluginEnabledValueStatementOffset
    }

    return [pscustomobject]@{
        TableMatchCount = [int]$boolTableHeaderMatches
        EnablementMatchCount = $intEnablementMatchCount
        EnabledValue = $strEnabledValue
        EnabledValueIndex = $intEnabledValueIndex
        EnabledValueLength = $intEnabledValueLength
    }
}

function ConvertTo-DisabledGitHubPluginMutation {
    # .SYNOPSIS
    # Creates a disabled GitHub plugin mutation.
    #
    # .DESCRIPTION
    # Replaces the unique enabled value in valid project TOML with false. It
    # rejects ambiguous input and verifies that the mutation changes the text.
    #
    # .PARAMETER Content
    # The project TOML text to mutate.
    #
    # .EXAMPLE
    # ConvertTo-DisabledGitHubPluginMutation -Content $strCodexConfigContent
    #
    # # Returns TOML with the GitHub plugin disabled.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [string] The disabled-plugin TOML mutation.
    #
    # .NOTES
    # Private helper; no positional parameters.
    # Version: 1.0.20260819.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $Content
    )

    $objContext = Get-GitHubPluginEnablementContext -Content $Content
    if ($objContext.TableMatchCount -ne 1 -or
        $objContext.EnablementMatchCount -ne 1 -or
        $objContext.EnabledValue -cne 'true' -or
        $objContext.EnabledValueIndex -lt 0 -or
        $objContext.EnabledValueLength -ne 4) {
        throw 'Could not locate one enabled GitHub plugin value for the disabled mutation.'
    }

    $strMutation = $Content.Remove(
        $objContext.EnabledValueIndex,
        $objContext.EnabledValueLength
    ).Insert(
        $objContext.EnabledValueIndex,
        'false'
    )
    if ($strMutation -ceq $Content) {
        throw 'The disabled GitHub plugin mutation did not change the configuration.'
    }

    return $strMutation
}

function Get-AgentInstructionFailure {
    # .SYNOPSIS
    # Finds violations of the shared agent-instruction contract.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $AgentsContent,

        [Parameter(Mandatory)]
        [string] $ClaudeContent,

        [Parameter(Mandatory)]
        [string] $CodexConfigContent,

        [Parameter()]
        [AllowNull()]
        [string] $ParentAgentsContent,

        [Parameter()]
        [AllowNull()]
        [string] $ParentClaudeContent,

        [Parameter()]
        [AllowEmptyString()]
        [string] $AgentsExpectedUtcDate = '',

        [Parameter()]
        [AllowEmptyString()]
        [string] $ClaudeExpectedUtcDate = ''
    )

    $objTomlParseContext = Get-TomlParseContext -Content $CodexConfigContent
    if (-not [string]::IsNullOrEmpty($objTomlParseContext.Failure)) {
        Write-Output $objTomlParseContext.Failure
        return
    }

    if (-not $objTomlParseContext.CapacityIsFirstStatement) {
        Write-Output 'project_doc_max_bytes must be the first semantic TOML statement.'
    }

    if (-not $objTomlParseContext.PluginHeaderIsSecondStatement) {
        Write-Output (
            'The github@openai-curated plugin table must be the second semantic TOML statement.'
        )
    }

    if (-not $objTomlParseContext.PluginEnablementIsThirdStatement) {
        Write-Output (
            'The github@openai-curated enabled value must be the third semantic TOML statement.'
        )
    }

    $intConfiguredMaximumBytes = [int64]0
    if (-not $objTomlParseContext.CapacityPresent -or
        $objTomlParseContext.CapacityType -cne 'int') {
        Write-Output 'project_doc_max_bytes must be an integer.'
    }
    elseif (-not $objTomlParseContext.CapacityFitsInt64) {
        Write-Output 'project_doc_max_bytes must fit in a signed 64-bit integer.'
    }
    else {
        $intConfiguredMaximumBytes = $objTomlParseContext.CapacityValue
        if ($intConfiguredMaximumBytes -lt 65536) {
            Write-Output 'project_doc_max_bytes must be at least 65536.'
        }
    }

    if (-not $objTomlParseContext.PluginTablePresent -or
        $objTomlParseContext.PluginTableType -cne 'dict') {
        Write-Output (
            'The project configuration must declare [plugins."github@openai-curated"] exactly once.'
        )
    }
    elseif (-not $objTomlParseContext.PluginEnabledPresent -or
        $objTomlParseContext.PluginEnabledType -cne 'bool' -or
        -not $objTomlParseContext.PluginEnabledValue) {
        Write-Output (
            'The github@openai-curated plugin table must declare enabled = true exactly once.'
        )
    }

    $intAgentsBytes = [Text.Encoding]::UTF8.GetByteCount($AgentsContent)
    if ($intAgentsBytes -gt 32768) {
        Write-Output 'AGENTS.md must not exceed the ordinary 32768-byte Codex limit.'
    }
    if (($intConfiguredMaximumBytes - $intAgentsBytes) -lt 16384) {
        Write-Output 'Configured AGENTS.md capacity must retain at least 16384 bytes of reserve.'
    }

    $objAgentsMarkdownContext = Get-OperativeMarkdownContext -Content $AgentsContent
    $objClaudeMarkdownContext = Get-OperativeMarkdownContext -Content $ClaudeContent
    $strAgentsOperativeContent = $objAgentsMarkdownContext.Text
    $strClaudeOperativeContent = $objClaudeMarkdownContext.Text
    $objAgentsPlacementContext = Get-MarkdownLevelTwoSectionContext `
        -MarkdownContext $objAgentsMarkdownContext `
        -Heading 'PR Review Workflow (Codex-adapted)'
    $objAgentsSafetyContext = Get-MarkdownLevelTwoSectionContext `
        -MarkdownContext $objAgentsMarkdownContext `
        -Heading 'Automated Review Loop (User-Initiated)'
    $objClaudeLoopContext = Get-MarkdownLevelTwoSectionContext `
        -MarkdownContext $objClaudeMarkdownContext `
        -Heading 'Automated Review Loop'
    $objClaudeReviewContext = Get-MarkdownLevelTwoSectionContext `
        -MarkdownContext $objClaudeMarkdownContext `
        -Heading 'Handling Code Review Comments'
    foreach ($strImportFailure in @(Get-ClaudeImportFailure `
            -Name 'CLAUDE.md' `
            -MarkdownContext $objClaudeMarkdownContext)) {
        Write-Output $strImportFailure
    }
    $arrDocuments = @(
        [pscustomobject]@{
            Name = 'AGENTS.md'
            RawContent = $AgentsContent
            Content = $strAgentsOperativeContent
            ProseContent = $objAgentsMarkdownContext.ProseText
            LevelTwoHeadings = $objAgentsMarkdownContext.LevelTwoHeadings
            ParentContent = $ParentAgentsContent
            ExpectedUtcDate = $AgentsExpectedUtcDate
            ReviewPolicyContext = $objAgentsPlacementContext
            InventoryPrefix = 'Inline threads. Enumerate'
            SyntheticPrefix = 'Key each review-body-only finding as'
            PlacementContent = $objAgentsPlacementContext.Text
            PlacementProseContent = $objAgentsPlacementContext.ProseText
            SafetyContent = $objAgentsSafetyContext.Text
            SafetyProseContent = $objAgentsSafetyContext.ProseText
        },
        [pscustomobject]@{
            Name = 'CLAUDE.md'
            RawContent = $ClaudeContent
            Content = $strClaudeOperativeContent
            ProseContent = $objClaudeMarkdownContext.ProseText
            LevelTwoHeadings = $objClaudeMarkdownContext.LevelTwoHeadings
            ParentContent = $ParentClaudeContent
            ExpectedUtcDate = $ClaudeExpectedUtcDate
            ReviewPolicyContext = $objClaudeReviewContext
            InventoryPrefix = 'Inline review comments and threads. Enumerate'
            SyntheticPrefix = 'Assign each review-body-only finding the stable synthetic key'
            PlacementContent = $objClaudeLoopContext.Text
            PlacementProseContent = $objClaudeLoopContext.ProseText
            SafetyContent = $objClaudeLoopContext.Text
            SafetyProseContent = $objClaudeLoopContext.ProseText
        }
    )

    foreach ($objDocument in $arrDocuments) {
        $intDeferringWorkHeadingCount = @(
            $objDocument.LevelTwoHeadings |
                Where-Object Text -CEQ 'Deferring Work'
        ).Count
        if ($intDeferringWorkHeadingCount -ne 1) {
            Write-Output (
                "$($objDocument.Name) must contain one exact level-two " +
                'Deferring Work heading.'
            )
        }
        $arrInventoryOwners = @(
            $objDocument.ReviewPolicyContext.TopLevelListItems |
                Where-Object {
                    $null -ne $_.Text -and $_.Text.StartsWith(
                        $objDocument.InventoryPrefix,
                        [StringComparison]::Ordinal
                    )
                }
        )
        $arrSyntheticOwners = @(
            $objDocument.ReviewPolicyContext.ProseBlocks |
                Where-Object {
                    $_.Text.StartsWith(
                        $objDocument.SyntheticPrefix,
                        [StringComparison]::Ordinal
                    )
                }
        )
        for ($intMarker = 0; $intMarker -lt $script:arrSharedStructuralLiterals.Count; $intMarker++) {
            $strLiteral = $script:arrSharedStructuralLiterals[$intMarker]
            $arrOwners = @(
                if ($intMarker -lt 3) {
                    $arrInventoryOwners
                }
                else {
                    $arrSyntheticOwners
                }
            )
            $intLiteralCount = if ($arrOwners.Count -eq 1) {
                @(
                    $arrOwners[0].Code |
                        Where-Object { $_ -ceq $strLiteral.Trim([char]96) }
                ).Count
            }
            else {
                0
            }
            if ($intLiteralCount -ne 1) {
                Write-Output "$($objDocument.Name) is missing required capability marker: $strLiteral"
            }
        }
        foreach ($strLiteral in $script:arrSharedProseLiterals) {
            if (-not $objDocument.ProseContent.Contains(
                    $strLiteral,
                    [StringComparison]::Ordinal
                )) {
                Write-Output "$($objDocument.Name) is missing required capability marker: $strLiteral"
            }
        }

        $intStandingAuthorizationCount = [regex]::Matches(
            $objDocument.PlacementProseContent,
            [regex]::Escape($script:strStandingPlacementAuthorization)
        ).Count
        if ($intStandingAuthorizationCount -ne 1) {
            Write-Output (
                "$($objDocument.Name) must contain the standing direct-placement " +
                'authorization exactly once.'
            )
        }
        $strNoAdditionalAuthorizationRequest =
            'The agent MUST NOT ask the owner for that additional authorization.'
        if (-not $objDocument.PlacementProseContent.Contains(
                $strNoAdditionalAuthorizationRequest,
                [StringComparison]::Ordinal
            )) {
            Write-Output (
                "$($objDocument.Name) must contain the no-additional-authorization rule as prose."
            )
        }

        foreach ($strLiteral in $script:arrPlacementStructuralLiterals) {
            $strStructuralPattern = '(?m)^[\t ]*' +
                '(?:(?:>[\t ]*)|(?:(?:[-+*]|\d+[.)])[\t ]+))*' +
                [regex]::Escape($strLiteral) + '(?:\s|$)'
            if (-not [regex]::IsMatch(
                    $objDocument.PlacementContent,
                    $strStructuralPattern
                )) {
                Write-Output "$($objDocument.Name) is missing required direct-placement safety marker: $strLiteral"
            }
        }

        foreach ($strLiteral in $script:arrPlacementProseLiterals) {
            if (-not $objDocument.PlacementProseContent.Contains(
                    $strLiteral,
                    [StringComparison]::Ordinal
                )) {
                Write-Output "$($objDocument.Name) is missing required direct-placement safety marker: $strLiteral"
            }
        }

        foreach ($strLiteral in $script:arrObsoletePlacementLiterals) {
            if ($objDocument.Content.Contains($strLiteral, [StringComparison]::Ordinal)) {
                Write-Output (
                    "$($objDocument.Name) contains obsolete session-specific " +
                    "direct-placement authorization: $strLiteral"
                )
            }
        }

        foreach ($strLiteral in $script:arrStyleGuideRoutingLiterals) {
            $intRoutingLiteralCount = [regex]::Matches(
                $objDocument.ProseContent,
                [regex]::Escape($strLiteral)
            ).Count
            if ($intRoutingLiteralCount -ne 1) {
                Write-Output (
                    "$($objDocument.Name) must contain the style-guide routing marker " +
                    "exactly once: $strLiteral"
                )
            }
        }

        $intOnlyGenuineDeferredWorkCount = [regex]::Matches(
            $objDocument.ProseContent,
            [regex]::Escape($script:strOnlyGenuineDeferredWork)
        ).Count
        if ($intOnlyGenuineDeferredWorkCount -ne 1) {
            Write-Output (
                "$($objDocument.Name) must contain the genuine-deferral Issue rule exactly once."
            )
        }

        foreach ($strLiteral in $script:arrObsoleteDeferralLiterals) {
            if ($objDocument.Content.Contains($strLiteral, [StringComparison]::Ordinal)) {
                Write-Output "$($objDocument.Name) contains an obsolete blanket Issue rule: $strLiteral"
            }
        }
    }

    $arrAgentsLevelTwoHeadings = @(
        'Codex Execution Model and Interfaces',
        'Automated Review Loop (User-Initiated)'
    )
    foreach ($strHeading in $arrAgentsLevelTwoHeadings) {
        $intHeadingCount = @(
            $objAgentsMarkdownContext.LevelTwoHeadings |
                Where-Object Text -CEQ $strHeading
        ).Count
        if ($intHeadingCount -ne 1) {
            Write-Output "AGENTS.md must contain one exact level-two heading: $strHeading"
        }
    }
    $arrAgentsVisibleCodeSpans = [string[]]@(
        $objAgentsMarkdownContext.ProseBlocks.Code
    )
    foreach ($strLiteral in $script:arrAgentsTechnicalCodeSpans) {
        if (@($arrAgentsVisibleCodeSpans | Where-Object { $_ -ceq $strLiteral }).Count -eq 0) {
            Write-Output "AGENTS.md is missing required Codex marker: $strLiteral"
        }
    }
    foreach ($objContract in $script:arrAgentsNormativeProseContracts) {
        $arrCandidateOwners = if ($objContract.OwnerKind -ceq 'ListItem') {
            $objAgentsPlacementContext.TopLevelListItems
        }
        else {
            $objAgentsPlacementContext.ProseBlocks
        }
        $arrOwners = @(
            $arrCandidateOwners |
                Where-Object {
                    $null -ne $_.Text -and $_.Text.StartsWith(
                        $objContract.OwnerPrefix,
                        [StringComparison]::Ordinal
                    )
                }
        )
        if ($arrOwners.Count -ne 1 -or
            -not $arrOwners[0].Text.Contains(
                $objContract.Literal,
                [StringComparison]::Ordinal
            )) {
            Write-Output (
                'AGENTS.md must contain required policy as prose: ' +
                $objContract.Literal
            )
        }
    }
    $arrClaudeVisibleCodeSpans = [string[]]@(
        $objClaudeMarkdownContext.ProseBlocks.Code
    )
    foreach ($strLiteral in $script:arrClaudeTechnicalCodeSpans) {
        if (@($arrClaudeVisibleCodeSpans | Where-Object { $_ -ceq $strLiteral }).Count -eq 0) {
            Write-Output "CLAUDE.md is missing required Claude marker: $strLiteral"
        }
    }
    if (-not $objClaudeMarkdownContext.ProseText.Contains(
            $script:strClaudeTechnicalProse,
            [StringComparison]::Ordinal
        )) {
        Write-Output (
            'CLAUDE.md is missing required Claude marker: ' +
            $script:strClaudeTechnicalProse
        )
    }
    foreach ($objSafetyLimitContract in $script:arrSafetyLimitContracts) {
        $objSafetyDocument = $arrDocuments |
            Where-Object { $_.Name -ceq $objSafetyLimitContract.DocumentName }
        $strStructuralLimitPattern = '(?m)^' +
            [regex]::Escape($objSafetyLimitContract.StructuralLiteral)
        $strProseLimitPattern = '(?m)^' +
            [regex]::Escape($objSafetyLimitContract.ProseLiteral) + '(?:\s|$)'
        if ([regex]::Matches(
                $objSafetyDocument.SafetyContent,
                $strStructuralLimitPattern
            ).Count -ne 1 -or
            [regex]::Matches(
                $objSafetyDocument.SafetyProseContent,
                $strProseLimitPattern
            ).Count -ne 1) {
            Write-Output $objSafetyLimitContract.Failure
        }
    }

    foreach ($objDocument in $arrDocuments) {
        $arrMetadataFailures = @(Get-DocumentMetadataTransitionFailure `
                -Name $objDocument.Name `
                -CurrentContent $objDocument.RawContent `
                -ParentContent $objDocument.ParentContent `
                -ExpectedUtcDate $objDocument.ExpectedUtcDate `
                -IsNewDocumentTransition (
                    $null -eq $objDocument.ParentContent -and
                    -not [string]::IsNullOrEmpty($objDocument.ExpectedUtcDate)
                ))
        foreach ($strMetadataFailure in $arrMetadataFailures) {
            Write-Output $strMetadataFailure
        }
    }
}

function Assert-Failure {
    # .SYNOPSIS
    # Confirms that an agent-instruction mutation fails closed.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param(
        [Parameter()][string] $Name,

        [Parameter()]
        [string] $AgentsContent = $script:strAgentsContent,

        [Parameter()]
        [string] $ClaudeContent = $script:strClaudeContent,

        [Parameter()]
        [string] $CodexConfigContent = $script:strCodexConfigContent,

        [Parameter(Mandatory)]
        [string] $Failure,

        [Parameter()]
        [AllowNull()]
        [string] $ParentAgentsContent,

        [Parameter()]
        [AllowNull()]
        [string] $ParentClaudeContent,

        [Parameter()]
        [AllowEmptyString()]
        [string] $AgentsExpectedUtcDate = '',

        [Parameter()]
        [AllowEmptyString()]
        [string] $ClaudeExpectedUtcDate = ''
    )

    if ([string]::IsNullOrEmpty($Name)) {
        Write-Verbose "Testing rejected mutation: $Failure"
    }
    else {
        Write-Verbose "Testing rejected mutation '$Name': $Failure"
    }
    $arrFailures = @(Get-AgentInstructionFailure `
            -AgentsContent $AgentsContent `
            -ClaudeContent $ClaudeContent `
            -CodexConfigContent $CodexConfigContent `
            -ParentAgentsContent $ParentAgentsContent `
            -ParentClaudeContent $ParentClaudeContent `
            -AgentsExpectedUtcDate $AgentsExpectedUtcDate `
            -ClaudeExpectedUtcDate $ClaudeExpectedUtcDate)
    if ($arrFailures.Count -eq 0) {
        throw "Mutation for '$Failure' did not fail closed."
    }
    if (-not ($arrFailures -match [regex]::Escape($Failure))) {
        throw "Mutation for '$Failure' failed for the wrong reason. Failures: $($arrFailures -join '; ')"
    }
}

function Assert-FixtureAccepted {
    # .SYNOPSIS
    # Confirms that an agent-instruction fixture is accepted.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param(
        [Parameter()][string] $Name,

        [Parameter()]
        [string] $AgentsContent = $script:strAgentsContent,

        [Parameter()]
        [string] $ClaudeContent = $script:strClaudeContent,

        [Parameter()]
        [string] $CodexConfigContent = $script:strCodexConfigContent,

        [Parameter()]
        [AllowNull()]
        [string] $ParentAgentsContent,

        [Parameter()]
        [AllowNull()]
        [string] $ParentClaudeContent,

        [Parameter()]
        [AllowEmptyString()]
        [string] $AgentsExpectedUtcDate = '',

        [Parameter()]
        [AllowEmptyString()]
        [string] $ClaudeExpectedUtcDate = ''
    )

    if ([string]::IsNullOrEmpty($Name)) {
        Write-Verbose 'Testing accepted fixture.'
    }
    else {
        Write-Verbose "Testing accepted fixture: $Name."
    }
    $arrFailures = @(Get-AgentInstructionFailure `
            -AgentsContent $AgentsContent `
            -ClaudeContent $ClaudeContent `
            -CodexConfigContent $CodexConfigContent `
            -ParentAgentsContent $ParentAgentsContent `
            -ParentClaudeContent $ParentClaudeContent `
            -AgentsExpectedUtcDate $AgentsExpectedUtcDate `
            -ClaudeExpectedUtcDate $ClaudeExpectedUtcDate)
    if ($arrFailures.Count -gt 0) {
        throw "Accepted fixture failed validation: $($arrFailures -join '; ')"
    }
}

#endregion Private helper functions

#region Repository validation

$strWorkflowsDirectoryPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($PSScriptRoot)
$strGitHubDirectoryPath = [IO.Path]::GetDirectoryName($strWorkflowsDirectoryPath)
$strRepositoryRootPath = [IO.Path]::GetDirectoryName($strGitHubDirectoryPath)
if ($PushApplicabilityOnly) {
    if ($SelfTest -or
        -not [string]::IsNullOrEmpty($InputRevision) -or
        -not [string]::IsNullOrEmpty($TrustedEventTimestamp) -or
        $EventName -cne 'push' -or
        -not [string]::IsNullOrEmpty($PullRequestAction) -or
        -not [string]::IsNullOrEmpty($PullRequestBaseChanged) -or
        -not [string]::IsNullOrEmpty($PreviousHeadRevision) -or
        -not [string]::IsNullOrEmpty($EventHeadRevision) -or
        -not [string]::IsNullOrEmpty($EventHeadDistinct) -or
        -not [string]::IsNullOrEmpty($NewRefCommitCount) -or
        -not [string]::IsNullOrEmpty($NewRefCommitEvidenceJson)) {
        throw 'Push-applicability mode received incompatible validation fields.'
    }
    $objPushApplicability = Get-PushGovernedPathApplicability `
        -RepositoryRootPath $strRepositoryRootPath `
        -BaseRevision $RangeBaseRevision `
        -HeadRevision $RangeHeadRevision `
        -IsNewRef ([bool]$RangeIsNewRef) `
        -IsDeletedRef ([bool]$RangeIsDeletedRef)
    Write-Output $objPushApplicability.ShouldValidate.ToString().ToLowerInvariant()
    return
}
if ($RangeIsDeletedRef) {
    throw 'Deleted-ref push validation must stop after its applicability decision.'
}
$arrBootstrapFailures = @(Get-MarkdownParserBootstrapFailure `
        -RepositoryRootPath $strRepositoryRootPath)
if ($arrBootstrapFailures.Count -gt 0) {
    throw ($arrBootstrapFailures -join [Environment]::NewLine)
}
$strAgentsPath = Join-Path -Path $strRepositoryRootPath -ChildPath 'AGENTS.md'
$strClaudePath = Join-Path -Path $strRepositoryRootPath -ChildPath 'CLAUDE.md'
$strCodexConfigPath = Join-Path -Path $strRepositoryRootPath -ChildPath '.codex/config.toml'
$strDocsInstructionsPath = Join-Path `
    -Path $strRepositoryRootPath `
    -ChildPath '.github/instructions/docs.instructions.md'
$arrGovernedInstructionDocuments = @(
    [pscustomobject]@{
        Path = 'AGENTS.md'
        MaximumBytes = $intAgentsMaximumInputBytes
        RequiresMetadata = $true
        RequiresVersion = $true
    },
    [pscustomobject]@{
        Path = 'CLAUDE.md'
        MaximumBytes = $intClaudeMaximumInputBytes
        RequiresMetadata = $true
        RequiresVersion = $true
    },
    [pscustomobject]@{
        Path = '.github/copilot-instructions.md'
        MaximumBytes = $intInstructionDocumentMaximumInputBytes
        RequiresMetadata = $false
        RequiresVersion = $false
    },
    [pscustomobject]@{
        Path = '.github/instructions/docs.instructions.md'
        MaximumBytes = $intDocsInstructionsMaximumInputBytes
        RequiresMetadata = $true
        RequiresVersion = $true
    },
    [pscustomobject]@{
        Path = '.github/instructions/yaml.instructions.md'
        MaximumBytes = $intInstructionDocumentMaximumInputBytes
        RequiresMetadata = $true
        RequiresVersion = $true
    }
)
$arrGovernedMetadataDocuments = @($arrGovernedInstructionDocuments) + @(
    [pscustomobject]@{
        Path = 'docs/ISSUE_EVALUATION_PROMPT.md'
        MaximumBytes = $intInstructionDocumentMaximumInputBytes
        RequiresMetadata = $true
        RequiresVersion = $false
    }
)
$arrGovernedMetadataDocuments += @(
    $script:arrOperationalLintGuidePaths | ForEach-Object {
        [pscustomobject]@{
        Path = $_
        MaximumBytes = $intInstructionDocumentMaximumInputBytes
        RequiresMetadata = $true
        RequiresVersion = $false
        }
    }
)
$strValidatedInputRevision = ''
$strTrustedEventUtcDate = ''
$boolEventRangeRequested = -not [string]::IsNullOrEmpty($RangeBaseRevision) -or
    -not [string]::IsNullOrEmpty($RangeHeadRevision)
$boolCommitDateOnlyEvent = $EventName -ceq 'pull_request_target'
if ($boolEventRangeRequested -and
    ([string]::IsNullOrEmpty($EventName) -or
        ([string]::IsNullOrEmpty($TrustedEventTimestamp) -and
            -not $boolCommitDateOnlyEvent))) {
    throw 'A metadata event range requires a trusted GitHub event name and timestamp.'
}
if (-not $boolEventRangeRequested -and
    (-not [string]::IsNullOrEmpty($TrustedEventTimestamp) -or
        -not [string]::IsNullOrEmpty($EventName) -or
        -not [string]::IsNullOrEmpty($PullRequestAction) -or
        -not [string]::IsNullOrEmpty($PullRequestBaseChanged) -or
        -not [string]::IsNullOrEmpty($PreviousHeadRevision) -or
        $RangeIsDeletedRef -or
        -not [string]::IsNullOrEmpty($EventHeadRevision) -or
        -not [string]::IsNullOrEmpty($EventHeadDistinct) -or
        -not [string]::IsNullOrEmpty($NewRefCommitCount) -or
        -not [string]::IsNullOrEmpty($NewRefCommitEvidenceJson))) {
    throw 'Metadata event fields require a complete base and head range.'
}
if (-not [string]::IsNullOrEmpty($TrustedEventTimestamp)) {
    $strTrustedEventUtcDate = (ConvertFrom-TrustedEventTimestamp `
            -Timestamp $TrustedEventTimestamp).ToString('yyyy-MM-dd')
}
$strEventHistoryBaseRevision = $RangeBaseRevision
$strEventFreshnessBaseRevision = ''
$boolEvaluateEventFreshness = $false
$boolRequireRangeCommitDateFreshness = $false
$strPreviousTopicBaseRevision = ''
$strPreviousTopicHeadRevision = ''
$strCurrentTopicBaseRevision = ''
$strCurrentTopicHeadRevision = ''
$boolValidateBackwardPushHead = $false
if ($boolEventRangeRequested -and
    -not [string]::IsNullOrEmpty($RangeBaseRevision) -and
    -not [string]::IsNullOrEmpty($RangeHeadRevision)) {
    $objMetadataEventRevisionContext = Get-MetadataEventRevisionContext `
        -RepositoryRootPath $strRepositoryRootPath `
        -EventName $EventName -PullRequestAction $PullRequestAction `
        -BaseRevision $RangeBaseRevision -HeadRevision $RangeHeadRevision `
        -IsNewRefRange ([bool]$RangeIsNewRef) `
        -PreviousHeadRevision $PreviousHeadRevision `
        -PullRequestBaseChanged $PullRequestBaseChanged `
        -EventHeadRevision $EventHeadRevision `
        -EventHeadDistinct $EventHeadDistinct `
        -NewRefCommitCount $NewRefCommitCount `
        -NewRefCommitEvidenceJson $NewRefCommitEvidenceJson
    $strEventHistoryBaseRevision = $objMetadataEventRevisionContext.HistoryBaseRevision
    $strEventFreshnessBaseRevision = $objMetadataEventRevisionContext.FreshnessBaseRevision
    $boolEvaluateEventFreshness = $objMetadataEventRevisionContext.EvaluateFreshness
    $boolRequireRangeCommitDateFreshness =
        ($EventName -ceq 'push' -and -not $RangeIsNewRef) -or
        $boolCommitDateOnlyEvent
    if ($boolCommitDateOnlyEvent) {
        $boolEvaluateEventFreshness = $false
    }
    $strPreviousTopicBaseRevision = $objMetadataEventRevisionContext.PreviousTopicBaseRevision
    $strPreviousTopicHeadRevision = $objMetadataEventRevisionContext.PreviousTopicHeadRevision
    $strCurrentTopicBaseRevision = $objMetadataEventRevisionContext.CurrentTopicBaseRevision
    $strCurrentTopicHeadRevision = $objMetadataEventRevisionContext.CurrentTopicHeadRevision
    if ($EventName -ceq 'push' -and -not $RangeIsNewRef -and
        $EventHeadDistinct -ceq 'false' -and
        $RangeBaseRevision -ne $RangeHeadRevision) {
        $boolValidateBackwardPushHead = Test-BackwardCommitMove `
            -RepositoryRootPath $strRepositoryRootPath `
            -BaseRevision $RangeBaseRevision -HeadRevision $RangeHeadRevision
    }
}

if (-not [string]::IsNullOrEmpty($InputRevision)) {
    if ($InputRevision -notmatch '^(?:[0-9a-fA-F]{40}|[0-9a-fA-F]{64})$') {
        throw "The agent-instruction input revision is invalid: $InputRevision"
    }
    $strValidatedInputRevision = [string] (
        & git -C $strRepositoryRootPath rev-parse --verify `
            "$InputRevision`^{commit}"
    )
    if ($LASTEXITCODE -ne 0 -or
        -not [string]::Equals(
            $strValidatedInputRevision.Trim(),
            $InputRevision,
            [StringComparison]::OrdinalIgnoreCase
        )) {
        throw "The agent-instruction input commit is unavailable: $InputRevision"
    }
    $strValidatedInputRevision = $strValidatedInputRevision.Trim()
    if (-not [string]::IsNullOrEmpty($RangeHeadRevision) -and
        -not [string]::Equals(
            $strValidatedInputRevision,
            $RangeHeadRevision,
            [StringComparison]::OrdinalIgnoreCase
        )) {
        throw 'The input revision must match the metadata event-range head.'
    }
}

$strCheckedOutRevision = [string] (
    & git -C $strRepositoryRootPath rev-parse --verify 'HEAD^{commit}'
)
if ($LASTEXITCODE -ne 0 -or $strCheckedOutRevision.Trim() -notmatch '^[0-9a-fA-F]{40}$') {
    throw 'The checked-out trusted revision is unavailable.'
}
$strCheckedOutRevision = $strCheckedOutRevision.Trim()
if (-not [string]::IsNullOrEmpty($strValidatedInputRevision) -and
    -not [string]::Equals(
        $strValidatedInputRevision,
        $strCheckedOutRevision,
        [StringComparison]::OrdinalIgnoreCase
    )) {
    $strTrustRootBaseRevision = if ($EventName -ceq 'pull_request_target') {
        $strEventHistoryBaseRevision
    }
    else {
        $RangeBaseRevision
    }
    $arrTrustRootFailures = @(Get-TrustRootRangeMutationFailure `
            -RepositoryRootPath $strRepositoryRootPath `
            -BaseRevision $strTrustRootBaseRevision `
            -HeadRevision $RangeHeadRevision `
            -RepositoryRelativePath $script:arrTrustRootPaths)
    if ($arrTrustRootFailures.Count -gt 0) {
        throw (
            'Trusted validation root changed:' + [Environment]::NewLine + '- ' +
            ($arrTrustRootFailures -join ([Environment]::NewLine + '- '))
        )
    }
}

$arrTrackedRepositoryPaths = @(Read-GitTrackedPath `
        -RepositoryRootPath $strRepositoryRootPath `
        -Revision $strValidatedInputRevision `
        -MaximumBytes $intGitPathListMaximumBytes)
$arrGovernedMetadataDocuments += @(
    $arrTrackedRepositoryPaths |
        Where-Object { $_ -cmatch $script:strDecisionRecordDirectoryPathPattern } |
        ForEach-Object {
            [pscustomobject]@{
                Path = $_
                MaximumBytes = $intInstructionDocumentMaximumInputBytes
                RequiresMetadata = $true
                RequiresVersion = $false
            }
        }
)
$arrTrackedGovernedInstructionPaths = @(
    $arrTrackedRepositoryPaths |
        Where-Object {
            Test-GovernedInstructionInventoryPath `
                -RepositoryRelativePath ([string] $_)
        }
)
$arrGovernedInstructionInventoryFailures = @(
    Get-GovernedInstructionInventoryFailure `
        -CatalogPaths @($arrGovernedInstructionDocuments.Path) `
        -TrackedPaths $arrTrackedGovernedInstructionPaths
)
if ($arrGovernedInstructionInventoryFailures.Count -gt 0) {
    throw (
        'Governed instruction inventory failed:' + [Environment]::NewLine + '- ' +
        ($arrGovernedInstructionInventoryFailures -join ([Environment]::NewLine + '- '))
    )
}

if ([string]::IsNullOrEmpty($strValidatedInputRevision)) {
    $arrRequiredPaths = @($strCodexConfigPath)
    $arrRequiredPaths += @(
        $arrGovernedMetadataDocuments |
            ForEach-Object {
                Join-Path -Path $strRepositoryRootPath -ChildPath $_.Path
            }
    )
    foreach ($strRequiredPath in $arrRequiredPaths) {
        if (-not (Test-Path -LiteralPath $strRequiredPath -PathType Leaf)) {
            throw "Required agent-instruction input is missing: $strRequiredPath"
        }
    }
}

$strAgentsContent = if ([string]::IsNullOrEmpty($strValidatedInputRevision)) {
    ConvertFrom-StrictUtf8Data `
        -Bytes (Read-RepositoryInputData `
            -Path $strAgentsPath `
            -RepositoryRootPath $strRepositoryRootPath `
            -RepositoryRelativePath 'AGENTS.md' `
            -DisplayName 'AGENTS.md' `
            -MaximumBytes $intAgentsMaximumInputBytes) `
        -DisplayName 'AGENTS.md'
}
else {
    Read-GitRevisionText `
        -RepositoryRootPath $strRepositoryRootPath `
        -Revision $strValidatedInputRevision `
        -RepositoryRelativePath 'AGENTS.md' `
        -MaximumBytes $intAgentsMaximumInputBytes `
        -RequireRegularFile
}
$strClaudeContent = if ([string]::IsNullOrEmpty($strValidatedInputRevision)) {
    ConvertFrom-StrictUtf8Data `
        -Bytes (Read-RepositoryInputData `
            -Path $strClaudePath `
            -RepositoryRootPath $strRepositoryRootPath `
            -RepositoryRelativePath 'CLAUDE.md' `
            -DisplayName 'CLAUDE.md' `
            -MaximumBytes $intClaudeMaximumInputBytes) `
        -DisplayName 'CLAUDE.md'
}
else {
    Read-GitRevisionText `
        -RepositoryRootPath $strRepositoryRootPath `
        -Revision $strValidatedInputRevision `
        -RepositoryRelativePath 'CLAUDE.md' `
        -MaximumBytes $intClaudeMaximumInputBytes `
        -RequireRegularFile
}
$strCodexConfigContent = if ([string]::IsNullOrEmpty($strValidatedInputRevision)) {
    ConvertFrom-StrictUtf8Data `
        -Bytes (Read-RepositoryInputData `
            -Path $strCodexConfigPath `
            -RepositoryRootPath $strRepositoryRootPath `
            -RepositoryRelativePath '.codex/config.toml' `
            -DisplayName '.codex/config.toml' `
            -MaximumBytes $intCodexConfigMaximumInputBytes) `
        -DisplayName '.codex/config.toml'
}
else {
    Read-GitRevisionText `
        -RepositoryRootPath $strRepositoryRootPath `
        -Revision $strValidatedInputRevision `
        -RepositoryRelativePath '.codex/config.toml' `
        -MaximumBytes $intCodexConfigMaximumInputBytes `
        -RequireRegularFile
}
$strDocsInstructionsContent = if ([string]::IsNullOrEmpty($strValidatedInputRevision)) {
    ConvertFrom-StrictUtf8Data `
        -Bytes (Read-RepositoryInputData `
            -Path $strDocsInstructionsPath `
            -RepositoryRootPath $strRepositoryRootPath `
            -RepositoryRelativePath '.github/instructions/docs.instructions.md' `
            -DisplayName '.github/instructions/docs.instructions.md' `
            -MaximumBytes $intDocsInstructionsMaximumInputBytes) `
        -DisplayName '.github/instructions/docs.instructions.md'
}
else {
    Read-GitRevisionText `
        -RepositoryRootPath $strRepositoryRootPath `
        -Revision $strValidatedInputRevision `
        -RepositoryRelativePath '.github/instructions/docs.instructions.md' `
        -MaximumBytes $intDocsInstructionsMaximumInputBytes `
        -RequireRegularFile
}
$hashtableGovernedInstructionContent = @{
    'AGENTS.md' = $strAgentsContent
    'CLAUDE.md' = $strClaudeContent
    '.github/instructions/docs.instructions.md' = $strDocsInstructionsContent
}
foreach ($objDocumentSpec in $arrGovernedMetadataDocuments) {
    if ($hashtableGovernedInstructionContent.ContainsKey($objDocumentSpec.Path)) {
        continue
    }
    $strDocumentPath = Join-Path `
        -Path $strRepositoryRootPath `
        -ChildPath $objDocumentSpec.Path
    $strDocumentContent = if ([string]::IsNullOrEmpty($strValidatedInputRevision)) {
        ConvertFrom-StrictUtf8Data `
            -Bytes (Read-RepositoryInputData `
                -Path $strDocumentPath `
                -RepositoryRootPath $strRepositoryRootPath `
                -RepositoryRelativePath $objDocumentSpec.Path `
                -DisplayName $objDocumentSpec.Path `
                -MaximumBytes $objDocumentSpec.MaximumBytes) `
            -DisplayName $objDocumentSpec.Path
    }
    else {
        Read-GitRevisionText `
            -RepositoryRootPath $strRepositoryRootPath `
            -Revision $strValidatedInputRevision `
            -RepositoryRelativePath $objDocumentSpec.Path `
            -MaximumBytes $objDocumentSpec.MaximumBytes `
            -RequireRegularFile
    }
    $hashtableGovernedInstructionContent[$objDocumentSpec.Path] = $strDocumentContent
}

$listGovernedDocumentContexts = [Collections.Generic.List[pscustomobject]]::new()
foreach ($objDocumentSpec in $arrGovernedMetadataDocuments) {
    $objParentContext = Get-GovernedDocumentParentContext `
        -RepositoryRootPath $strRepositoryRootPath `
        -RepositoryRelativePath $objDocumentSpec.Path `
        -MaximumBytes $objDocumentSpec.MaximumBytes `
        -Revision $strValidatedInputRevision
    $strDocumentPolicyMarker = if (
        $objDocumentSpec.Path -in $script:arrOperationalLintGuidePaths) {
        $strLintGuideMetadataPolicyMarker
    } else {
        $strMetadataRangePolicyMarker
    }
    $boolParentPolicyApplies = Test-HistoricalPolicyMarker `
        -RepositoryRootPath $strRepositoryRootPath `
        -Revision $objParentContext.ParentRevision `
        -RepositoryRelativePath '.github/workflows/Test-AgentInstructions.ps1' `
        -Literal $strDocumentPolicyMarker
    $listGovernedDocumentContexts.Add([pscustomobject]@{
            Path = $objDocumentSpec.Path
            MaximumBytes = $objDocumentSpec.MaximumBytes
            Content = $hashtableGovernedInstructionContent[$objDocumentSpec.Path]
            ParentContent = if ($boolParentPolicyApplies) {
                $objParentContext.ParentContent
            } else { $null }
            ExpectedUtcDate = $objParentContext.ExpectedUtcDate
            IsWorktreeTransition = $objParentContext.IsWorktreeTransition
            RequiresMetadata = $objDocumentSpec.RequiresMetadata
            RequiresVersion = $objDocumentSpec.RequiresVersion
            PolicyMarker = $strDocumentPolicyMarker
        })
}

$strNoRangeCommitRevision = ''
$boolNoRangeCommitHasParent = $false
if ([string]::IsNullOrEmpty($RangeBaseRevision) -and
    [string]::IsNullOrEmpty($RangeHeadRevision)) {
    $strNoRangeCommitRevision = if ([string]::IsNullOrEmpty($strValidatedInputRevision)) {
        $strCheckedOutRevision
    }
    else {
        $strValidatedInputRevision
    }
    $strNoRangeParentLine = [string] (
        & git -C $strRepositoryRootPath rev-list --parents -n 1 `
            $strNoRangeCommitRevision
    )
    if ($LASTEXITCODE -ne 0) {
        throw "Could not read the no-range validation commit: $strNoRangeCommitRevision"
    }
    $arrNoRangeCommitAndParents = @($strNoRangeParentLine.Trim() -split '\s+')
    $boolNoRangeCommitHasParent = $arrNoRangeCommitAndParents.Count -gt 1
}

$arrRepositoryFailures = @(Get-AgentInstructionFailure `
        -AgentsContent $strAgentsContent `
        -ClaudeContent $strClaudeContent `
        -CodexConfigContent $strCodexConfigContent)
$strGitIgnoreContent = if ([string]::IsNullOrEmpty($strValidatedInputRevision)) {
    ConvertFrom-StrictUtf8Data `
        -Bytes (Read-RepositoryInputData `
            -Path (Join-Path $strRepositoryRootPath '.gitignore') `
            -RepositoryRootPath $strRepositoryRootPath `
            -RepositoryRelativePath '.gitignore' `
            -DisplayName '.gitignore' `
            -MaximumBytes $intGitIgnoreMaximumInputBytes) `
        -DisplayName '.gitignore'
}
else {
    Read-GitRevisionText `
        -RepositoryRootPath $strRepositoryRootPath `
        -Revision $strValidatedInputRevision `
        -RepositoryRelativePath '.gitignore' `
        -MaximumBytes $intGitIgnoreMaximumInputBytes `
        -RequireRegularFile
}
if ($strGitIgnoreContent -cnotmatch '(?m)^/CLAUDE\.local\.md$') {
    $arrRepositoryFailures += 'The root CLAUDE.local.md ignore rule is missing.'
}
$arrRepositoryFailures += @(Get-DocumentationClaimFailure `
        -Content $strDocsInstructionsContent `
        -TrackedPaths $arrTrackedRepositoryPaths)
$arrCanonicalDecisionGuideLinks = @(
    '](../../STYLE_GUIDE.md)',
    '](../../STYLE_GUIDE_RATIONALE.md)'
)
foreach ($objDecisionContext in @(
        $listGovernedDocumentContexts |
            Where-Object { $_.Path -cmatch $script:strDecisionRecordDirectoryPathPattern }
    )) {
    $arrRepositoryFailures += @(Get-DecisionRecordPathFailure `
            -RepositoryRelativePath $objDecisionContext.Path)
    foreach ($strGuideLink in $arrCanonicalDecisionGuideLinks) {
        if (-not $objDecisionContext.Content.Contains(
                $strGuideLink,
                [StringComparison]::Ordinal
            )) {
            $arrRepositoryFailures +=
                "$($objDecisionContext.Path) must link to $strGuideLink"
        }
    }
}
$arrRepositoryFailures += @(Get-NestedClaudeImportFailure `
        -DocumentContexts @(
            $listGovernedDocumentContexts |
                Where-Object { $arrGovernedInstructionDocuments.Path -ccontains $_.Path }
        ))
foreach ($objDocumentContext in $listGovernedDocumentContexts) {
    if (-not $objDocumentContext.RequiresMetadata) {
        continue
    }
    if ([string]::IsNullOrEmpty($RangeBaseRevision) -and
        [string]::IsNullOrEmpty($RangeHeadRevision)) {
        if (-not $objDocumentContext.RequiresVersion) {
            $arrRepositoryFailures += @(Get-LastUpdatedMetadataFreshnessFailure `
                    -Name $objDocumentContext.Path `
                    -CurrentContent $objDocumentContext.Content `
                    -BaseContent $objDocumentContext.ParentContent `
                    -TrustedEventUtcDate $objDocumentContext.ExpectedUtcDate)
        }
        elseif ($objDocumentContext.IsWorktreeTransition -or
            -not $boolNoRangeCommitHasParent) {
            $arrRepositoryFailures += @(Get-DocumentMetadataTransitionFailure `
                    -Name $objDocumentContext.Path `
                    -CurrentContent $objDocumentContext.Content `
                    -ParentContent $objDocumentContext.ParentContent `
                    -ExpectedUtcDate $objDocumentContext.ExpectedUtcDate `
                    -IsNewDocumentTransition (
                        $null -eq $objDocumentContext.ParentContent -and
                        -not [string]::IsNullOrEmpty($objDocumentContext.ExpectedUtcDate)
                    ))
        }
        else {
            $arrRepositoryFailures += @(Get-GovernedDocumentCommitTransitionFailure `
                    -Name $objDocumentContext.Path `
                    -RepositoryRootPath $strRepositoryRootPath `
                    -RepositoryRelativePath $objDocumentContext.Path `
                    -MaximumBytes $objDocumentContext.MaximumBytes `
                    -CommitRevision $strNoRangeCommitRevision `
                    -PolicyRepositoryRelativePath '.github/workflows/Test-AgentInstructions.ps1' `
                    -PolicyMaximumBytes $intValidatorMaximumInputBytes `
                    -PolicyMarker $objDocumentContext.PolicyMarker)
        }
    }
    $arrRepositoryFailures += @(Get-GovernedDocumentRangeTransitionFailure `
            -Name $objDocumentContext.Path `
            -RepositoryRootPath $strRepositoryRootPath `
            -RepositoryRelativePath $objDocumentContext.Path `
            -MaximumBytes $objDocumentContext.MaximumBytes `
            -BaseRevision $strEventHistoryBaseRevision `
            -HeadRevision $RangeHeadRevision `
            -InputRevision $strValidatedInputRevision `
            -IsNewRefRange ([bool]$RangeIsNewRef) `
            -PolicyRepositoryRelativePath '.github/workflows/Test-AgentInstructions.ps1' `
            -PolicyMaximumBytes $intValidatorMaximumInputBytes `
            -PolicyMarker $objDocumentContext.PolicyMarker `
            -RequireExpectedUtcDateForRenderedChange `
                $boolRequireRangeCommitDateFreshness `
            -RequiresVersion $objDocumentContext.RequiresVersion)
    if ($EventName -ceq 'push' -and $EventHeadDistinct -ceq 'false' -and
        ($RangeIsNewRef -or $boolValidateBackwardPushHead)) {
        $arrRepositoryFailures += @(Get-GovernedDocumentCommitTransitionFailure `
                -Name $objDocumentContext.Path `
                -RepositoryRootPath $strRepositoryRootPath `
                -RepositoryRelativePath $objDocumentContext.Path `
                -MaximumBytes $objDocumentContext.MaximumBytes `
                -CommitRevision $RangeHeadRevision `
                -PolicyRepositoryRelativePath '.github/workflows/Test-AgentInstructions.ps1' `
                -PolicyMaximumBytes $intValidatorMaximumInputBytes `
                -PolicyMarker $objDocumentContext.PolicyMarker `
                -RequireExpectedUtcDateForRenderedChange $true `
                -RequiresVersion $objDocumentContext.RequiresVersion)
    }
    if ($boolEventRangeRequested -and $boolEvaluateEventFreshness) {
        $boolTopicDeltaUnchanged = $false
        if (-not [string]::IsNullOrEmpty($strPreviousTopicBaseRevision)) {
            $boolTopicDeltaUnchanged = Test-TopicOwnedGitPathDeltaEqual `
                -RepositoryRootPath $strRepositoryRootPath `
                -PreviousBaseRevision $strPreviousTopicBaseRevision `
                -PreviousHeadRevision $strPreviousTopicHeadRevision `
                -CurrentBaseRevision $strCurrentTopicBaseRevision `
                -CurrentHeadRevision $strCurrentTopicHeadRevision `
                -RepositoryRelativePath $objDocumentContext.Path
        }
        if (-not [string]::IsNullOrEmpty($strEventFreshnessBaseRevision)) {
            & git -C $strRepositoryRootPath cat-file -e `
                "$strEventFreshnessBaseRevision`:$($objDocumentContext.Path)" 2>$null
        }
        $strEventBaseContent = if ($boolTopicDeltaUnchanged) {
            $objDocumentContext.Content
        }
        elseif (-not [string]::IsNullOrEmpty($strEventFreshnessBaseRevision) -and
            $LASTEXITCODE -eq 0) {
            Read-GitRevisionText `
                -RepositoryRootPath $strRepositoryRootPath `
                -Revision $strEventFreshnessBaseRevision `
                -RepositoryRelativePath $objDocumentContext.Path `
                -MaximumBytes $objDocumentContext.MaximumBytes `
                -RequireRegularFile
        }
        else {
            $null
        }
        if ($objDocumentContext.RequiresVersion) {
            $arrRepositoryFailures += @(Get-CurrentInputMetadataFreshnessFailure `
                    -Name $objDocumentContext.Path `
                    -CurrentContent $objDocumentContext.Content `
                    -BaseContent $strEventBaseContent `
                    -TrustedEventUtcDate $strTrustedEventUtcDate)
        }
        else {
            $arrRepositoryFailures += @(Get-LastUpdatedMetadataFreshnessFailure `
                    -Name $objDocumentContext.Path `
                    -CurrentContent $objDocumentContext.Content `
                    -BaseContent $strEventBaseContent `
                    -TrustedEventUtcDate $strTrustedEventUtcDate)
        }
    }
}
if ($arrRepositoryFailures.Count -gt 0) {
    throw "Agent-instruction contract failed:`n- $($arrRepositoryFailures -join "`n- ")"
}

Write-Output 'Agent-instruction contract passed.'

#endregion Repository validation

if ($SelfTest) {
    #region Mutation self-tests

    $strValidatorSource = [IO.File]::ReadAllText($PSCommandPath)
    if ([regex]::Matches(
            $strValidatorSource,
            '(?m)^# Version: 1\.7\.20260828\.2$'
        ).Count -ne 1) {
        throw 'The validator script version does not use build date 20260828.'
    }
    $boolSavedWindowsPython = $script:useWindowsPythonLauncher
    $arrSavedPythonNames = $script:pythonPathNames
    try {
        $script:useWindowsPythonLauncher = $false
        $script:pythonPathNames = @('python3.12', 'python3', 'python')
        if ((Get-TomlParseContext -Content $strCodexConfigContent).Failure) {
            throw 'A compatible PATH Python 3.12 interpreter was rejected.'
        }
        foreach ($strRejectedPythonName in @(
                'pwsh', 'missing-python312')) {
            $script:pythonPathNames = @($strRejectedPythonName)
            if ((Get-TomlParseContext -Content $strCodexConfigContent).Failure -cne
                $strPythonPrerequisite) {
                throw "Python candidate was accepted: $strRejectedPythonName"
            }
        }
    }
    finally {
        $script:useWindowsPythonLauncher = $boolSavedWindowsPython
        $script:pythonPathNames = $arrSavedPythonNames
    }

    $strMissingBootstrapFixture = [IO.Path]::Combine(
        [IO.Path]::GetTempPath(),
        ('agent-instruction-bootstrap-{0}' -f [Guid]::NewGuid().ToString('N'))
    )
    $arrMissingBootstrapFailures = @(Get-MarkdownParserBootstrapFailure `
            -RepositoryRootPath $strMissingBootstrapFixture)
    if ($arrMissingBootstrapFailures.Count -ne 1 -or
        -not $arrMissingBootstrapFailures[0].Contains(
            'npm run bootstrap:agent-instructions',
            [StringComparison]::Ordinal
        )) {
        throw 'The node_modules-absent bootstrap fixture did not fail actionably.'
    }

    $arrDocumentationClaimFailures = @(Get-DocumentationClaimFailure `
            -Content $strDocsInstructionsContent `
            -TrackedPaths $arrTrackedRepositoryPaths)
    if ($arrDocumentationClaimFailures.Count -ne 0) {
        throw (
            'The documentation claim baseline failed validation: ' +
            ($arrDocumentationClaimFailures -join '; ')
        )
    }
    foreach ($strOwnerPath in $script:arrDocumentationClaimOwnerPaths) {
        $arrMissingOwnerFailures = @(Get-DocumentationClaimFailure `
                -Content $strDocsInstructionsContent `
                -TrackedPaths @(
                    $arrTrackedRepositoryPaths |
                        Where-Object { $_ -cne $strOwnerPath }
                ))
        $strExpectedOwnerFailure =
            'Documentation claim owner is not tracked at the validation ' +
            "revision: $strOwnerPath"
        if ($arrMissingOwnerFailures -cnotcontains $strExpectedOwnerFailure) {
            throw "A missing documentation claim owner did not fail closed: $strOwnerPath"
        }
    }
    $strFalseDocumentationClaimMutation = $strDocsInstructionsContent +
        [Environment]::NewLine + [Environment]::NewLine +
        'The absent `.github/workflows/check-placeholders.yml` enforces this rule.'
    $arrFalseDocumentationClaimFailures = @(Get-DocumentationClaimFailure `
            -Content $strFalseDocumentationClaimMutation `
            -TrackedPaths $arrTrackedRepositoryPaths)
    if (-not ($arrFalseDocumentationClaimFailures -match [regex]::Escape(
                'Documentation instructions name an absent repository-specific source'
            ))) {
        throw 'A false documentation enforcement claim did not fail closed.'
    }

    $arrClaudeImportMutations = @(
        [pscustomobject]@{ Name = 'relative import'; Text = '@docs/claude-policy.md' },
        [pscustomobject]@{ Name = 'absolute import'; Text = '@/etc/claude-policy.md' },
        [pscustomobject]@{ Name = 'home import'; Text = '@~/claude-policy.md' },
        [pscustomobject]@{ Name = 'traversal import'; Text = '@../claude-policy.md' },
        [pscustomobject]@{ Name = 'single-file import'; Text = '@policy.md' },
        [pscustomobject]@{ Name = 'extensionless bare import'; Text = '@README' },
        [pscustomobject]@{
            Name = 'recursive and multiple imports'
            Text = "@docs/recursive/CLAUDE.md`n@docs/second-policy.md"
        }
    )
    foreach ($objImportMutation in $arrClaudeImportMutations) {
        Assert-Failure `
            -ClaudeContent (
                $strClaudeContent + [Environment]::NewLine +
                $objImportMutation.Text
            ) `
            -Failure $script:strClaudeImportFailure
    }

    $arrNestedClaudeImportFailures = @(Get-NestedClaudeImportFailure `
            -DocumentContexts @(
                [pscustomobject]@{
                    Path = 'tools/CLAUDE.md'
                    Content = '@README'
                }
            ))
    if ($arrNestedClaudeImportFailures -cnotcontains `
        'tools/CLAUDE.md must not contain active @path imports.') {
        throw 'A nested governed CLAUDE.md extensionless import did not fail closed.'
    }

    $arrAcceptedClaudeImportLikeFixtures = @(
        [pscustomobject]@{
            Name = 'Claude import-like inline code'
            Text = '`@docs/claude-policy.md`'
        },
        [pscustomobject]@{
            Name = 'Claude import-like fenced code'
            Text = '```text' + [Environment]::NewLine +
                '@docs/claude-policy.md' + [Environment]::NewLine + '```'
        },
        [pscustomobject]@{
            Name = 'ordinary Claude and Codex mentions'
            Text = "@claude resume review loop`n`n@codex review"
        }
    )
    foreach ($objAcceptedFixture in $arrAcceptedClaudeImportLikeFixtures) {
        Assert-FixtureAccepted `
            -ClaudeContent (
                $strClaudeContent + [Environment]::NewLine +
                $objAcceptedFixture.Text
            ) `
            -CodexConfigContent $strCodexConfigContent
    }

    $strDocsStaleMetadataMutation = $strDocsInstructionsContent +
        [Environment]::NewLine + [Environment]::NewLine +
        'Rendered docs metadata transition mutation.'
    $objDocsMetadataContext = Get-DocumentMetadataContext `
        -Content $strDocsInstructionsContent
    if ($null -ne $objDocsMetadataContext.Failure) {
        throw 'Could not parse documentation instructions metadata for mutation tests.'
    }
    $objDocsExpectedUtcDate = [DateTime]::ParseExact(
        $objDocsMetadataContext.UpdatedDate,
        'yyyy-MM-dd',
        [System.Globalization.CultureInfo]::InvariantCulture
    )
    $arrNewDocumentMismatchDates = @(
        $objDocsExpectedUtcDate.AddDays(-1).ToString(
            'yyyy-MM-dd',
            [System.Globalization.CultureInfo]::InvariantCulture
        )
        $objDocsExpectedUtcDate.AddDays(-2).ToString(
            'yyyy-MM-dd',
            [System.Globalization.CultureInfo]::InvariantCulture
        )
    )
    foreach ($strNewDocumentDate in $arrNewDocumentMismatchDates) {
        $strNewDocumentMutation = $strDocsInstructionsContent.Replace(
            $objDocsMetadataContext.VersionDate,
            $strNewDocumentDate.Replace('-', '')
        ).Replace(
            "- **Last Updated:** $($objDocsMetadataContext.UpdatedDate)",
            "- **Last Updated:** $strNewDocumentDate"
        )
        $arrNewDocumentFailures = @(Get-DocumentMetadataTransitionFailure `
                -Name '.github/instructions/docs.instructions.md' `
                -CurrentContent $strNewDocumentMutation `
                -ParentContent $null `
                -ExpectedUtcDate $objDocsMetadataContext.UpdatedDate `
                -IsNewDocumentTransition $true)
        if (-not ($arrNewDocumentFailures -match 'Last Updated must be')) {
            throw "A new document with date $strNewDocumentDate did not fail closed."
        }
    }
    $arrDocsStaleMetadataFailures = @(Get-DocumentMetadataTransitionFailure `
            -Name '.github/instructions/docs.instructions.md' `
            -CurrentContent $strDocsStaleMetadataMutation `
            -ParentContent $strDocsInstructionsContent `
            -ExpectedUtcDate $objDocsMetadataContext.UpdatedDate `
            -IsNewDocumentTransition $false)
    if (-not ($arrDocsStaleMetadataFailures -match [regex]::Escape(
                '.github/instructions/docs.instructions.md Version revision must be greater than'
            ))) {
        throw 'The docs-only stale-metadata mutation did not fail closed.'
    }

    $arrNewlyCoveredPaths = @(
        '.github/instructions/yaml.instructions.md'
    )
    foreach ($strNewlyCoveredPath in $arrNewlyCoveredPaths) {
        $objDocumentContext = $listGovernedDocumentContexts |
            Where-Object { $_.Path -ceq $strNewlyCoveredPath }
        if ($null -eq $objDocumentContext) {
            throw "Could not locate newly covered metadata input: $strNewlyCoveredPath"
        }
        $objMetadataContext = Get-DocumentMetadataContext `
            -Content $objDocumentContext.Content
        if ($null -ne $objMetadataContext.Failure) {
            throw "Could not parse newly covered metadata input: $strNewlyCoveredPath"
        }
        $strStaleMetadataMutation = $objDocumentContext.Content +
            [Environment]::NewLine + [Environment]::NewLine +
            'Rendered governed-instruction metadata mutation.'
        $arrStaleMetadataFailures = @(Get-DocumentMetadataTransitionFailure `
                -Name $strNewlyCoveredPath `
                -CurrentContent $strStaleMetadataMutation `
                -ParentContent $objDocumentContext.Content `
                -ExpectedUtcDate $objMetadataContext.UpdatedDate `
                -IsNewDocumentTransition $false)
        $strFailure = "$strNewlyCoveredPath Version revision must be greater than"
        if (-not ($arrStaleMetadataFailures -match [regex]::Escape(
                    $strFailure
                ))) {
            throw "$strNewlyCoveredPath stale-metadata mutation did not fail closed."
        }
    }

    if ($arrTrackedGovernedInstructionPaths -cnotcontains 'CLAUDE.md' -or
        @($arrGovernedInstructionDocuments.Path) -cnotcontains 'CLAUDE.md') {
        throw 'The supported root CLAUDE.md instruction is not cataloged.'
    }
    foreach ($strProhibitedClaudeLocalPath in @(
            'CLAUDE.local.md',
            'tools/CLAUDE.local.md',
            'CLAUDE.LOCAL.md',
            'tools/claude.Local.MD'
        )) {
        if (-not (Test-ProhibitedClaudeLocalPath `
                    -RepositoryRelativePath $strProhibitedClaudeLocalPath) -or
            -not (Test-AgentInstructionWorkflowPath `
                    -RepositoryRelativePath $strProhibitedClaudeLocalPath) -or
            -not (Test-GovernedInstructionInventoryPath `
                    -RepositoryRelativePath $strProhibitedClaudeLocalPath)) {
            throw "Prohibited Claude local memory escaped a validator surface: $strProhibitedClaudeLocalPath"
        }
        $arrProhibitedClaudeLocalFailures = @(
            Get-GovernedInstructionInventoryFailure `
                -CatalogPaths @($arrGovernedInstructionDocuments.Path) `
                -TrackedPaths @(
                    $arrTrackedGovernedInstructionPaths + $strProhibitedClaudeLocalPath
                )
        )
        if (-not ($arrProhibitedClaudeLocalFailures -ccontains (
                    'Tracked CLAUDE.local.md is prohibited operative project memory: ' +
                    $strProhibitedClaudeLocalPath
                ))) {
            throw "Tracked Claude local memory was not explicitly rejected: $strProhibitedClaudeLocalPath"
        }
    }
    if (Test-ProhibitedClaudeLocalPath -RepositoryRelativePath 'CLAUDE.local.md.bak') {
        throw 'A Claude local-memory near miss was prohibited.'
    }
    foreach ($strExactValidatorInputPath in $script:arrPushGovernedExactPaths) {
        if (-not (Test-AgentInstructionWorkflowPath `
                    -RepositoryRelativePath $strExactValidatorInputPath)) {
            throw "An exact validator input escaped push applicability: $strExactValidatorInputPath"
        }
    }
    foreach ($strLintGuidePath in $script:arrOperationalLintGuidePaths) {
        $arrLintGuideContexts = @($listGovernedDocumentContexts |
                Where-Object { $_.Path -ceq $strLintGuidePath })
        if ($arrLintGuideContexts.Count -ne 1 -or
            $arrLintGuideContexts[0].PolicyMarker -cne
                $strLintGuideMetadataPolicyMarker) {
            throw "Lint guide is outside Tier 1 policy: $strLintGuidePath"
        }
    }
    foreach ($strValidatorInputNearMiss in @(
            '.github/.gitignore',
            '.github/workflows/MARKDOWN-LINTING-IMPLEMENTATION.md.bak',
            '.github/workflows/scripts-README.md.bak',
            'docs/ISSUE_EVALUATION_PROMPT.md.bak'
        )) {
        if (Test-AgentInstructionWorkflowPath `
                -RepositoryRelativePath $strValidatorInputNearMiss) {
            throw "A validator-input near miss selected push validation: $strValidatorInputNearMiss"
        }
    }
    $strCanonicalDecisionPath = 'docs/decisions/0003-new-policy.md'
    if (@(Get-DecisionRecordPathFailure `
                -RepositoryRelativePath $strCanonicalDecisionPath).Count -ne 0 -or
        -not (Test-AgentInstructionWorkflowPath `
                -RepositoryRelativePath $strCanonicalDecisionPath)) {
        throw 'A canonical decision-record path was not accepted and governed.'
    }
    foreach ($objDecisionPathMutation in @(
            [pscustomobject]@{ Find = '0003-new-policy.md'; Replace = 'security.md' },
            [pscustomobject]@{ Find = 'new'; Replace = 'New' },
            [pscustomobject]@{ Find = '.md'; Replace = '.txt' }
        )) {
        $intMutationCount = [regex]::Matches(
            $strCanonicalDecisionPath,
            [regex]::Escape($objDecisionPathMutation.Find)
        ).Count
        $strDecisionPathMutation = $strCanonicalDecisionPath.Replace(
            $objDecisionPathMutation.Find,
            $objDecisionPathMutation.Replace
        )
        $arrDecisionPathFailures = @(Get-DecisionRecordPathFailure `
                -RepositoryRelativePath $strDecisionPathMutation)
        if ($intMutationCount -ne 1 -or
            $strDecisionPathMutation -ceq $strCanonicalDecisionPath -or
            -not (Test-AgentInstructionWorkflowPath `
                    -RepositoryRelativePath $strDecisionPathMutation) -or
            $arrDecisionPathFailures.Count -ne 1 -or
            $arrDecisionPathFailures[0] -cne
                "$strDecisionPathMutation must use docs/decisions/NNNN-short-title.md.") {
            throw "A noncanonical decision path did not fail closed exactly: $strDecisionPathMutation"
        }
    }
    $strNestedDecisionNearMiss = "$strCanonicalDecisionPath/nested"
    $arrNestedDecisionFailures = @(Get-DecisionRecordPathFailure `
            -RepositoryRelativePath $strNestedDecisionNearMiss)
    if (-not (Test-AgentInstructionWorkflowPath `
                -RepositoryRelativePath $strNestedDecisionNearMiss) -or
        $arrNestedDecisionFailures.Count -ne 1 -or
        $arrNestedDecisionFailures[0] -cne
            "$strNestedDecisionNearMiss must use docs/decisions/NNNN-short-title.md.") {
        throw 'A nested decision path escaped explicit canonical rejection.'
    }
    foreach ($strHierarchicalGeminiPath in @(
            'GEMINI.md',
            'tools/GEMINI.md',
            'tools/deep/GEMINI.md'
        )) {
        if (-not (Test-GovernedInstructionPath `
                    -RepositoryRelativePath $strHierarchicalGeminiPath `
                    -GovernedRootPaths $script:arrGovernedInstructionRootPaths) -or
            -not (Test-AgentInstructionWorkflowPath `
                    -RepositoryRelativePath $strHierarchicalGeminiPath)) {
            throw "A hierarchical Gemini context escaped governance: $strHierarchicalGeminiPath"
        }
    }
    foreach ($strGeminiNearMissPath in @(
            'tools/Gemini.md',
            'tools/GEMINI.md.bak',
            './GEMINI.md',
            '../GEMINI.md',
            'tools/../GEMINI.md',
            'tools//GEMINI.md'
        )) {
        if (Test-GovernedInstructionPath `
                -RepositoryRelativePath $strGeminiNearMissPath `
                -GovernedRootPaths $script:arrGovernedInstructionRootPaths) {
            throw "A Gemini near-miss path entered governance: $strGeminiNearMissPath"
        }
    }

    $arrCaseFoldedGovernedPaths = @(
        'agents.md',
        'tools/agents.md',
        'AGENTS.Override.md',
        'claude.md',
        'gemini.md',
        '.GitHub/instructions/sample.instructions.md',
        '.Cursor/rules/sample.mdc',
        '.Claude/rules/sample.md',
        '.github/Workflows/agent-instructions.yml',
        '.Github/workflows/Test-AgentInstructions.ps1'
    )
    foreach ($strCaseFoldedGovernedPath in $arrCaseFoldedGovernedPaths) {
        if ((Test-GovernedInstructionPath `
                    -RepositoryRelativePath $strCaseFoldedGovernedPath `
                    -GovernedRootPaths $script:arrGovernedInstructionRootPaths) -or
            -not (Test-AgentInstructionWorkflowPath `
                    -RepositoryRelativePath $strCaseFoldedGovernedPath)) {
            throw "Canonical acceptance changed for case near-match: $strCaseFoldedGovernedPath"
        }
        $boolCaseMismatch = if (Test-ExactPathCaseMismatch `
                -RepositoryRelativePath $strCaseFoldedGovernedPath `
                -CanonicalPaths $script:arrPushGovernedExactPaths) {
            $true
        }
        else {
            Test-GovernedInstructionPathCaseMismatch `
                -RepositoryRelativePath $strCaseFoldedGovernedPath `
                -GovernedRootPaths $script:arrGovernedInstructionRootPaths
        }
        if (-not $boolCaseMismatch) {
            throw "A case-folded governed path was not detected: $strCaseFoldedGovernedPath"
        }
        if (-not (Test-GovernedInstructionInventoryPath `
                    -RepositoryRelativePath $strCaseFoldedGovernedPath)) {
            throw "A case-folded path escaped the production inventory selector: $strCaseFoldedGovernedPath"
        }
    }
    foreach ($strCanonicalGovernedPath in @(
            'AGENTS.md',
            'tools/AGENTS.md',
            'AGENTS.override.md',
            'CLAUDE.md',
            'GEMINI.md',
            '.github/instructions/sample.instructions.md',
            '.cursor/rules/sample.mdc',
            '.claude/rules/sample.md',
            '.github/workflows/agent-instructions.yml'
        )) {
        if (-not (Test-AgentInstructionWorkflowPath `
                    -RepositoryRelativePath $strCanonicalGovernedPath)) {
            throw "A canonical governed control was rejected: $strCanonicalGovernedPath"
        }
        if (Test-GovernedInstructionPathCaseMismatch `
                -RepositoryRelativePath $strCanonicalGovernedPath `
                -GovernedRootPaths $script:arrGovernedInstructionRootPaths) {
            throw "A canonical governed control was reported as a case mismatch: $strCanonicalGovernedPath"
        }
    }

    $arrUncatalogedGovernedInstructionPaths = @(
        '.github/instructions/future.instructions.md',
        '.github/instructions/team/future.instructions.md',
        '.cursor/rules/future.mdc',
        '.cursor/rules/team/future.mdc',
        '.hermes.md',
        'GEMINI.md',
        'tools/GEMINI.md',
        'tools/deep/GEMINI.md',
        'tools/AGENTS.md',
        'AGENTS.override.md',
        'tools/AGENTS.override.md',
        '.claude/CLAUDE.md',
        'tools/CLAUDE.md',
        '.claude/rules/base.md',
        '.claude/rules/frontend/base.md'
    )
    foreach (
        $strUncatalogedGovernedInstructionPath in
            $arrUncatalogedGovernedInstructionPaths
    ) {
        if (-not (Test-GovernedInstructionPath `
                    -RepositoryRelativePath $strUncatalogedGovernedInstructionPath `
                    -GovernedRootPaths $script:arrGovernedInstructionRootPaths)) {
            throw (
                'The governed-instruction selector omitted a documented surface: ' +
                $strUncatalogedGovernedInstructionPath
            )
        }

        $arrGovernedInstructionInventoryFailures = @(
            Get-GovernedInstructionInventoryFailure `
                -CatalogPaths @($arrGovernedInstructionDocuments.Path) `
                -TrackedPaths @(
                    $arrTrackedGovernedInstructionPaths +
                        $strUncatalogedGovernedInstructionPath
                )
        )
        $strExpectedGovernedInstructionFailure =
            'Tracked governed instruction is missing from the catalog: ' +
            $strUncatalogedGovernedInstructionPath
        if (-not (
                $arrGovernedInstructionInventoryFailures -ccontains `
                    $strExpectedGovernedInstructionFailure
            )) {
            throw (
                'The uncataloged governed instruction mutation did not fail closed: ' +
                $strUncatalogedGovernedInstructionPath
            )
        }
    }

    $arrCatalogedNestedGeminiFailures = @(
        Get-GovernedInstructionInventoryFailure `
            -CatalogPaths @($arrGovernedInstructionDocuments.Path +
                'tools/GEMINI.md') `
            -TrackedPaths @($arrTrackedGovernedInstructionPaths +
                'tools/GEMINI.md')
    )
    if ($arrCatalogedNestedGeminiFailures.Count -ne 0) {
        throw 'A cataloged nested GEMINI.md did not enter the governed inventory.'
    }
    $arrNestedGeminiMetadataFailures = @(Get-DocumentMetadataTransitionFailure `
            -Name 'tools/GEMINI.md' `
            -CurrentContent $strDocsStaleMetadataMutation `
            -ParentContent $strDocsInstructionsContent `
            -ExpectedUtcDate $objDocsMetadataContext.UpdatedDate `
            -IsNewDocumentTransition $false)
    if (-not ($arrNestedGeminiMetadataFailures -match [regex]::Escape(
                'tools/GEMINI.md Version revision must be greater than'
            ))) {
        throw 'A cataloged nested GEMINI.md bypassed rendered metadata transition.'
    }

    $arrUnversionedMetadataContexts = @($listGovernedDocumentContexts |
            Where-Object { $_.RequiresMetadata -and -not $_.RequiresVersion })
    foreach ($objDocumentContext in $arrUnversionedMetadataContexts) {
        $objMetadata = Get-DocumentMetadataContext -Content $objDocumentContext.Content `
            -RequiresVersion $false
        if ($null -ne $objMetadata.Failure) {
            throw "Invalid unversioned metadata: $($objDocumentContext.Path)"
        }
        $strMutation = $objDocumentContext.Content.Replace('## Metadata', '')
        $arrFailures = @(Get-LastUpdatedMetadataFreshnessFailure -Name `
                $objDocumentContext.Path -CurrentContent $strMutation -BaseContent `
                $objDocumentContext.Content -TrustedEventUtcDate $objMetadata.UpdatedDate)
        if (-not ($arrFailures -match 'first level-two heading immediately after the H1')) {
            throw "$($objDocumentContext.Path) accepted missing Metadata."
        }
    }
    $objUnversionedDocument = $arrUnversionedMetadataContexts[0]
    $objUnversionedMetadata = Get-DocumentMetadataContext `
        -Content $objUnversionedDocument.Content -RequiresVersion $false
    $strRenderedMutation = $objUnversionedDocument.Content + "`nRendered change.`n"
    $arrNoDateFailures = @(Get-LastUpdatedMetadataFreshnessFailure `
            -Name $objUnversionedDocument.Path -CurrentContent $strRenderedMutation `
            -BaseContent $objUnversionedDocument.Content -TrustedEventUtcDate '')
    if (-not ($arrNoDateFailures -match 'must advance from')) {
        throw 'No-date rendered change did not require a date advance.'
    }
    $strNextDate = ([datetime]::ParseExact($objUnversionedMetadata.UpdatedDate,
            'yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture)).AddDays(1).ToString('yyyy-MM-dd')
    $strAdvancedMutation = $strRenderedMutation.Replace(
        "- **Last Updated:** $($objUnversionedMetadata.UpdatedDate)",
        "- **Last Updated:** $strNextDate")
    if (@(Get-LastUpdatedMetadataFreshnessFailure `
            -Name $objUnversionedDocument.Path -CurrentContent $strAdvancedMutation `
            -BaseContent $objUnversionedDocument.Content `
            -TrustedEventUtcDate '').Count -ne 0) {
        throw 'An advanced unversioned date was rejected.'
    }

    $arrRequiredFieldNames = @('Status', 'Owner', 'Last Updated', 'Scope')
    foreach ($objDocumentContext in @(
            $listGovernedDocumentContexts |
                Where-Object { $_.RequiresMetadata }
        )) {
        foreach ($strFieldName in $arrRequiredFieldNames) {
            $objFieldLineMatch = [regex]::Match(
                $objDocumentContext.Content,
                "(?m)^- \*\*$([regex]::Escape($strFieldName)):\*\* [^\r\n]+$"
            )
            if (-not $objFieldLineMatch.Success) {
                throw "Could not locate $strFieldName in $($objDocumentContext.Path)."
            }
            $strFieldDeletion = $objDocumentContext.Content.Remove(
                $objFieldLineMatch.Index,
                $objFieldLineMatch.Length
            )
            $arrFieldFailures = if ($objDocumentContext.RequiresVersion) {
                @(Get-DocumentMetadataTransitionFailure -Name $objDocumentContext.Path `
                        -CurrentContent $strFieldDeletion `
                        -ParentContent $objDocumentContext.Content `
                        -ExpectedUtcDate $objDocumentContext.ExpectedUtcDate `
                        -IsNewDocumentTransition $false)
            }
            else {
                @(Get-LastUpdatedMetadataFreshnessFailure -Name $objDocumentContext.Path `
                        -CurrentContent $strFieldDeletion `
                        -BaseContent $objDocumentContext.Content `
                        -TrustedEventUtcDate $objDocumentContext.ExpectedUtcDate)
            }
            $strExpectedFieldFailure = "$($objDocumentContext.Path) must contain " +
                "one exact top-level $strFieldName list item"
            if (-not ($arrFieldFailures -match [regex]::Escape(
                        $strExpectedFieldFailure
                    ))) {
                throw "$($objDocumentContext.Path) accepted deleted $strFieldName."
            }
        }
    }

    $objRepresentativeDocument = $listGovernedDocumentContexts[0]
    $arrRepresentativeFieldMutations = @(
        [pscustomobject]@{
            Field = 'Status'
            Replacement = '- **Status:** Complete'
        },
        [pscustomobject]@{
            Field = 'Owner'
            Replacement = '- **Owner:** '
        },
        [pscustomobject]@{
            Field = 'Scope'
            Replacement = '- **Scope:** '
        }
    )
    foreach ($objFieldMutation in $arrRepresentativeFieldMutations) {
        $objFieldLineMatch = [regex]::Match(
            $objRepresentativeDocument.Content,
            "(?m)^- \*\*$([regex]::Escape($objFieldMutation.Field)):\*\* [^\r\n]+$"
        )
        $strFieldMutation = $objRepresentativeDocument.Content.Remove(
            $objFieldLineMatch.Index,
            $objFieldLineMatch.Length
        ).Insert($objFieldLineMatch.Index, $objFieldMutation.Replacement)
        $arrFieldFailures = @(Get-DocumentMetadataTransitionFailure `
                -Name $objRepresentativeDocument.Path `
                -CurrentContent $strFieldMutation `
                -ParentContent $objRepresentativeDocument.Content `
                -ExpectedUtcDate $objRepresentativeDocument.ExpectedUtcDate `
                -IsNewDocumentTransition $false)
        $strExpectedFieldFailure = "$($objRepresentativeDocument.Path) must contain " +
            "one exact top-level $($objFieldMutation.Field) list item"
        if (-not ($arrFieldFailures -match [regex]::Escape(
                    $strExpectedFieldFailure
                ))) {
            throw "Malformed $($objFieldMutation.Field) mutation was accepted."
        }
    }

    $strStatusLine = [regex]::Match(
        $objRepresentativeDocument.Content,
        '(?m)^- \*\*Status:\*\* [^\r\n]+$'
    ).Value
    foreach ($strHiddenStatus in @(
            "<div>`n$strStatusLine`n</div>",
            "- Wrapper`n  $strStatusLine"
        )) {
        $strHiddenStatusMutation = $objRepresentativeDocument.Content.Replace(
            $strStatusLine,
            $strHiddenStatus
        )
        $arrFieldFailures = @(Get-DocumentMetadataTransitionFailure `
                -Name $objRepresentativeDocument.Path `
                -CurrentContent $strHiddenStatusMutation `
                -ParentContent $objRepresentativeDocument.Content `
                -ExpectedUtcDate $objRepresentativeDocument.ExpectedUtcDate `
                -IsNewDocumentTransition $false)
        if (-not ($arrFieldFailures -match 'one exact top-level Status list item')) {
            throw 'A non-operative Status mutation was accepted.'
        }
    }

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

    Assert-OversizedStreamMutationRejected

    Assert-EncodingMutationRejected `
        -Name 'malformed UTF-8 mutation' `
        -Bytes ([byte[]] @(0xC3, 0x28))

    Assert-EncodingMutationRejected `
        -Name 'UTF-8 BOM mutation' `
        -Bytes ([byte[]] @(0xEF, 0xBB, 0xBF, 0x41))

    Assert-EncodingMutationRejected `
        -Name 'UTF-16LE BOM mutation' `
        -Bytes ([byte[]] @(0xFF, 0xFE, 0x41, 0x00))

    $arrHostileGovernedPaths = @(
        "caf$([char]0x00e9)/AGENTS.md", "tab`tname/AGENTS.override.md",
        'quote"name/CLAUDE.md', 'back\slash/GEMINI.md', "line`nfeed/AGENTS.md",
        "carriage`rreturn/CLAUDE.md", '-leading/AGENTS.md')
    $listGitPathBytes = [Collections.Generic.List[byte]]::new()
    foreach ($strHostilePath in $arrHostileGovernedPaths) {
        $listGitPathBytes.AddRange([Text.Encoding]::UTF8.GetBytes($strHostilePath))
        $listGitPathBytes.Add(0)
    }
    $arrParsedHostilePaths = @(ConvertFrom-GitPathListData `
            -Bytes $listGitPathBytes.ToArray())
    if ($arrParsedHostilePaths.Count -ne $arrHostileGovernedPaths.Count) {
        throw 'Hostile Git path count changed.'
    }
    for ($intPath = 0; $intPath -lt $arrHostileGovernedPaths.Count; $intPath++) {
        if ($arrParsedHostilePaths[$intPath] -cne $arrHostileGovernedPaths[$intPath] -or
            -not (Test-GovernedInstructionPath `
                -RepositoryRelativePath $arrParsedHostilePaths[$intPath] `
                -GovernedRootPaths $script:arrGovernedInstructionRootPaths)) {
            throw 'A hostile Git path changed or escaped governance.'
        }
    }
    $arrPathDataMutations = @(
        [pscustomobject]@{Name='empty';Bytes=[byte[]]@(0);Failure='empty path'},
        [pscustomobject]@{Name='UTF-8';Bytes=[byte[]]@(0xC3,0x28,0);Failure='valid UTF-8'},
        [pscustomobject]@{Name='unterminated';Bytes=[byte[]]@(0x61);Failure='end with a NUL'},
        [pscustomobject]@{Name='duplicate';Bytes=[Text.Encoding]::UTF8.GetBytes("a`0a`0");Failure='duplicate path'})
    foreach ($objPathDataMutation in $arrPathDataMutations) {
        try {
            [void](ConvertFrom-GitPathListData -Bytes $objPathDataMutation.Bytes)
            throw "Git path mutation passed: $($objPathDataMutation.Name)"
        }
        catch [IO.InvalidDataException] {
            if (-not $_.Exception.Message.Contains(
                    $objPathDataMutation.Failure, [StringComparison]::Ordinal)) {
                throw "Wrong Git path failure: $($objPathDataMutation.Name)"
            }
        }
    }
    if (@(ConvertFrom-GitPathListData -Bytes ([byte[]] @())).Count -ne 0) {
        throw 'Empty Git output changed inventory.'
    }
    $arrIndexPaths = @(Read-GitTrackedPath -RepositoryRootPath `
            $strRepositoryRootPath -MaximumBytes $intGitPathListMaximumBytes)
    $arrRevisionPaths = @(Read-GitTrackedPath -RepositoryRootPath `
            $strRepositoryRootPath -Revision $strCheckedOutRevision `
            -MaximumBytes $intGitPathListMaximumBytes)
    if ($null -ne (Compare-Object $arrIndexPaths $arrRevisionPaths -CaseSensitive)) {
        throw 'Index and revision path lists differ.'
    }

    Assert-Failure `
        -CodexConfigContent ($strCodexConfigContent + [Environment]::NewLine +
            'invalid = [' + [Environment]::NewLine) `
        -Failure 'The project configuration must contain valid TOML.'

    $objAgentsVersionMatch = [regex]::Match(
        $strAgentsContent,
        '(?m)^\*\*Version:\*\* (?<Prefix>\d+\.\d+\.)' +
            '(?<Date>\d{8})\.(?<Revision>\d+)$'
    )
    $objAgentsUpdatedMatch = [regex]::Match(
        $strAgentsContent,
        '(?m)^- \*\*Last Updated:\*\* (?<Date>\d{4}-\d{2}-\d{2})$'
    )
    if (-not $objAgentsVersionMatch.Success -or -not $objAgentsUpdatedMatch.Success) {
        throw 'Could not parse AGENTS metadata for transition mutation tests.'
    }
    $objClaudeVersionMatch = [regex]::Match(
        $strClaudeContent,
        '(?m)^\*\*Version:\*\* (?<Prefix>\d+\.\d+\.)' +
            '(?<Date>\d{8})\.(?<Revision>\d+)$'
    )
    $objClaudeUpdatedMatch = [regex]::Match(
        $strClaudeContent,
        '(?m)^- \*\*Last Updated:\*\* (?<Date>\d{4}-\d{2}-\d{2})$'
    )
    if (-not $objClaudeVersionMatch.Success -or -not $objClaudeUpdatedMatch.Success) {
        throw 'Could not parse CLAUDE metadata for structural mutation tests.'
    }

    $arrMetadataStructureDocuments = @(
        [pscustomobject]@{
            Name = 'AGENTS.md'
            Content = $strAgentsContent
            H1Line = [regex]::Match($strAgentsContent, '(?m)^# .+$').Value
            VersionLine = $objAgentsVersionMatch.Value
            UpdatedLine = $objAgentsUpdatedMatch.Value
        },
        [pscustomobject]@{
            Name = 'CLAUDE.md'
            Content = $strClaudeContent
            H1Line = [regex]::Match($strClaudeContent, '(?m)^# .+$').Value
            VersionLine = $objClaudeVersionMatch.Value
            UpdatedLine = $objClaudeUpdatedMatch.Value
        }
    )
    foreach ($objDocument in $arrMetadataStructureDocuments) {
        if ([string]::IsNullOrEmpty($objDocument.H1Line)) {
            throw "Could not locate the $($objDocument.Name) H1 for structural mutation tests."
        }
        $strCodeFence = '```'
        $strH1Failure = "$($objDocument.Name) must contain exactly one " +
            'document-level H1 within the first 30 body lines.'
        $strVersionFailure = "$($objDocument.Name) must contain one exact " +
            'document-level Version paragraph immediately after the H1 and within ' +
            'the first 30 body lines.'
        $strMetadataHeadingFailure = "$($objDocument.Name) must place Metadata as " +
            'the first level-two heading immediately after Version and within the ' +
            'first 30 body lines.'
        $strUpdatedFailure = "$($objDocument.Name) must contain one exact top-level " +
            'Last Updated list item in the Metadata section and within the first 30 body lines.'
        $strParentVersionFailure = "The parent of $($objDocument.Name) must contain " +
            'one exact document-level Version paragraph immediately after the H1 and ' +
            'within the first 30 body lines.'

        $arrMetadataStructureMutations = @(
            [pscustomobject]@{
                Name = 'duplicate document-level H1'
                Content = $objDocument.Content.Replace(
                    $objDocument.H1Line,
                    "$($objDocument.H1Line)`n`n$($objDocument.H1Line)"
                )
                Failure = $strH1Failure
            },
            [pscustomobject]@{
                Name = 'H1 after first 30 lines'
                Content = $objDocument.Content.Replace(
                    $objDocument.H1Line,
                    (("`n" * 30) + $objDocument.H1Line)
                )
                Failure = $strH1Failure
            },
            [pscustomobject]@{
                Name = 'Version in fenced code'
                Content = $objDocument.Content.Replace(
                    $objDocument.VersionLine,
                    ($strCodeFence + "text`n" + $objDocument.VersionLine +
                        "`n" + $strCodeFence)
                )
                Failure = $strVersionFailure
            },
            [pscustomobject]@{
                Name = 'Version in multiline HTML comment'
                Content = $objDocument.Content.Replace(
                    $objDocument.VersionLine,
                    "<!--`n$($objDocument.VersionLine)`n-->"
                )
                Failure = $strVersionFailure
            },
            [pscustomobject]@{
                Name = 'Version in block quote'
                Content = $objDocument.Content.Replace(
                    $objDocument.VersionLine,
                    "> $($objDocument.VersionLine)"
                )
                Failure = $strVersionFailure
            },
            [pscustomobject]@{
                Name = 'Version in raw HTML block'
                Content = $objDocument.Content.Replace(
                    $objDocument.VersionLine,
                    "<div>`n$($objDocument.VersionLine)`n</div>"
                )
                Failure = $strVersionFailure
            },
            [pscustomobject]@{
                Name = 'intervening paragraph before Version'
                Content = $objDocument.Content.Replace(
                    $objDocument.VersionLine,
                    "Intervening paragraph.`n`n$($objDocument.VersionLine)"
                )
                Failure = $strVersionFailure
            },
            [pscustomobject]@{
                Name = 'duplicate document-level Version'
                Content = $objDocument.Content.Replace(
                    $objDocument.VersionLine,
                    "$($objDocument.VersionLine)`n`n$($objDocument.VersionLine)"
                )
                Failure = $strVersionFailure
            },
            [pscustomobject]@{
                Name = 'malformed document-level Version'
                Content = $objDocument.Content.Replace(
                    $objDocument.VersionLine,
                    '**Version:** malformed'
                )
                Failure = $strVersionFailure
            },
            [pscustomobject]@{
                Name = 'malformed duplicate document-level Version'
                Content = $objDocument.Content.Replace(
                    $objDocument.VersionLine,
                    "$($objDocument.VersionLine)`n`n**Version:** malformed"
                )
                Failure = $strVersionFailure
            },
            [pscustomobject]@{
                Name = 'earlier level-two section before Metadata'
                Content = $objDocument.Content.Replace(
                    '## Metadata',
                    "## Earlier Section`n`nEarlier text.`n`n## Metadata"
                )
                Failure = $strMetadataHeadingFailure
            },
            [pscustomobject]@{
                Name = 'duplicate Metadata section'
                Content = $objDocument.Content.Replace(
                    '## Metadata',
                    "## Metadata`n`n## Metadata"
                )
                Failure = $strMetadataHeadingFailure
            },
            [pscustomobject]@{
                Name = 'Last Updated in fenced code'
                Content = $objDocument.Content.Replace(
                    $objDocument.UpdatedLine,
                    ($strCodeFence + "text`n" + $objDocument.UpdatedLine +
                        "`n" + $strCodeFence)
                )
                Failure = $strUpdatedFailure
            },
            [pscustomobject]@{
                Name = 'Last Updated in multiline HTML comment'
                Content = $objDocument.Content.Replace(
                    $objDocument.UpdatedLine,
                    "<!--`n$($objDocument.UpdatedLine)`n-->"
                )
                Failure = $strUpdatedFailure
            },
            [pscustomobject]@{
                Name = 'Last Updated in block quote'
                Content = $objDocument.Content.Replace(
                    $objDocument.UpdatedLine,
                    "> $($objDocument.UpdatedLine)"
                )
                Failure = $strUpdatedFailure
            },
            [pscustomobject]@{
                Name = 'Last Updated in nested list'
                Content = $objDocument.Content.Replace(
                    $objDocument.UpdatedLine,
                    "- Wrapper`n  $($objDocument.UpdatedLine)"
                )
                Failure = $strUpdatedFailure
            },
            [pscustomobject]@{
                Name = 'Last Updated in raw HTML block'
                Content = $objDocument.Content.Replace(
                    $objDocument.UpdatedLine,
                    "<div>`n$($objDocument.UpdatedLine)`n</div>"
                )
                Failure = $strUpdatedFailure
            },
            [pscustomobject]@{
                Name = 'Last Updated in later section'
                Content = $objDocument.Content.Replace(
                    $objDocument.UpdatedLine,
                    ''
                ).Replace(
                    '## Canonical Instructions',
                    "## Canonical Instructions`n`n$($objDocument.UpdatedLine)"
                )
                Failure = $strUpdatedFailure
            },
            [pscustomobject]@{
                Name = 'Last Updated after first 30 lines'
                Content = $objDocument.Content.Replace(
                    $objDocument.UpdatedLine,
                    (("`n" * 25) + $objDocument.UpdatedLine)
                )
                Failure = $strUpdatedFailure
            },
            [pscustomobject]@{
                Name = 'duplicate top-level Last Updated'
                Content = $objDocument.Content.Replace(
                    $objDocument.UpdatedLine,
                    "$($objDocument.UpdatedLine)`n$($objDocument.UpdatedLine)"
                )
                Failure = $strUpdatedFailure
            },
            [pscustomobject]@{
                Name = 'malformed top-level Last Updated'
                Content = $objDocument.Content.Replace(
                    $objDocument.UpdatedLine,
                    '- **Last Updated:** someday'
                )
                Failure = $strUpdatedFailure
            },
            [pscustomobject]@{
                Name = 'malformed duplicate top-level Last Updated'
                Content = $objDocument.Content.Replace(
                    $objDocument.UpdatedLine,
                    "$($objDocument.UpdatedLine)`n- **Last Updated:** someday"
                )
                Failure = $strUpdatedFailure
            }
        )

        foreach ($objMutation in $arrMetadataStructureMutations) {
            Write-Verbose (
                "Testing metadata structure mutation: $($objDocument.Name) " +
                $objMutation.Name
            )
            $hashtableMutation = @{
                Name = "$($objDocument.Name) $($objMutation.Name)"
                AgentsContent = if ($objDocument.Name -ceq 'AGENTS.md') {
                    $objMutation.Content
                }
                else {
                    $strAgentsContent
                }
                ClaudeContent = if ($objDocument.Name -ceq 'CLAUDE.md') {
                    $objMutation.Content
                }
                else {
                    $strClaudeContent
                }
                CodexConfigContent = $strCodexConfigContent
                Failure = $objMutation.Failure
            }
            Assert-Failure @hashtableMutation
        }

        $strParentMutation = $objDocument.Content.Replace(
            $objDocument.VersionLine,
            ($strCodeFence + "text`n" + $objDocument.VersionLine +
                "`n" + $strCodeFence)
        )
        $hashtableParentMutation = @{
            Name = "$($objDocument.Name) parent Version in fenced code"
            AgentsContent = $strAgentsContent
            ClaudeContent = $strClaudeContent
            CodexConfigContent = $strCodexConfigContent
            Failure = $strParentVersionFailure
        }
        if ($objDocument.Name -ceq 'AGENTS.md') {
            $hashtableParentMutation.ParentAgentsContent = $strParentMutation
        }
        else {
            $hashtableParentMutation.ParentClaudeContent = $strParentMutation
        }
        Write-Verbose (
            "Testing metadata structure mutation: $($objDocument.Name) parent " +
            'Version in fenced code'
        )
        Assert-Failure @hashtableParentMutation

        $strParentUpdatedMutation = $objDocument.Content.Replace(
            $objDocument.UpdatedLine,
            "<!--`n$($objDocument.UpdatedLine)`n-->"
        )
        $hashtableParentUpdatedMutation = @{
            Name = "$($objDocument.Name) parent Last Updated in HTML comment"
            AgentsContent = $strAgentsContent
            ClaudeContent = $strClaudeContent
            CodexConfigContent = $strCodexConfigContent
            Failure = "The parent of $strUpdatedFailure"
        }
        if ($objDocument.Name -ceq 'AGENTS.md') {
            $hashtableParentUpdatedMutation.ParentAgentsContent = $strParentUpdatedMutation
        }
        else {
            $hashtableParentUpdatedMutation.ParentClaudeContent = $strParentUpdatedMutation
        }
        Write-Verbose (
            "Testing metadata structure mutation: $($objDocument.Name) parent " +
            'Last Updated in HTML comment'
        )
        Assert-Failure @hashtableParentUpdatedMutation
    }

    $intAgentsRevision = [int64] $objAgentsVersionMatch.Groups['Revision'].Value
    if ($intAgentsRevision -gt ([int64]::MaxValue - 2)) {
        throw 'The AGENTS revision is too large for transition mutation tests.'
    }
    $intNextAgentsRevision = $intAgentsRevision + 1
    $intJumpedAgentsRevision = $intAgentsRevision + 2
    $strAgentsVersionStem = '**Version:** ' +
        $objAgentsVersionMatch.Groups['Prefix'].Value +
        $objAgentsVersionMatch.Groups['Date'].Value + '.'
    $strAgentsVersionPrefix = '**Version:** ' +
        $objAgentsVersionMatch.Groups['Prefix'].Value
    $strAgentsRevisionSuffix = '.' + $objAgentsVersionMatch.Groups['Revision'].Value
    $arrInvalidCurrentDateFixtures = @(
        [pscustomobject]@{
            Name = 'impossible metadata month'
            VersionDate = '99999999'
            UpdatedDate = '9999-99-99'
        },
        [pscustomobject]@{
            Name = 'impossible metadata day'
            VersionDate = '20260230'
            UpdatedDate = '2026-02-30'
        },
        [pscustomobject]@{
            Name = 'non-leap metadata day'
            VersionDate = '20250229'
            UpdatedDate = '2025-02-29'
        }
    )
    foreach ($objDateFixture in $arrInvalidCurrentDateFixtures) {
        $strInvalidDateContent = $strAgentsContent.Replace(
            $objAgentsVersionMatch.Value,
            $strAgentsVersionPrefix + $objDateFixture.VersionDate +
                $strAgentsRevisionSuffix
        ).Replace(
            $objAgentsUpdatedMatch.Value,
            '- **Last Updated:** ' + $objDateFixture.UpdatedDate
        )
        Assert-Failure `
            -AgentsContent $strInvalidDateContent `
            -ParentAgentsContent $strAgentsContent `
            -Failure (
                'AGENTS.md Version and Last Updated must contain one real matching calendar date.'
            )
    }

    $strFutureMetadataContent = $strAgentsContent.Replace(
        $objAgentsVersionMatch.Value,
        $strAgentsVersionPrefix + '20991231' + $strAgentsRevisionSuffix
    ).Replace(
        $objAgentsUpdatedMatch.Value,
        '- **Last Updated:** 2099-12-31'
    ) + [Environment]::NewLine + 'Future metadata fixture.'
    Assert-Failure `
        -AgentsContent $strFutureMetadataContent `
        -ParentAgentsContent $strAgentsContent `
        -Failure (
            'AGENTS.md Last Updated 2099-12-31 must not be later than trusted UTC date'
        )
    Assert-Failure `
        -ParentAgentsContent $strFutureMetadataContent `
        -Failure (
            'The parent of AGENTS.md Last Updated 2099-12-31 must not be later than trusted UTC date'
        )

    $strValidLeapDateContent = $strAgentsContent.Replace(
        $objAgentsVersionMatch.Value,
        $strAgentsVersionPrefix + '20240229' + $strAgentsRevisionSuffix
    ).Replace(
        $objAgentsUpdatedMatch.Value,
        '- **Last Updated:** 2024-02-29'
    )
    $strValidLeapDateParent = $strAgentsContent.Replace(
        $objAgentsVersionMatch.Value,
        $strAgentsVersionPrefix + '20000101' + $strAgentsRevisionSuffix
    ).Replace(
        $objAgentsUpdatedMatch.Value,
        '- **Last Updated:** 2000-01-01'
    )
    Assert-FixtureAccepted `
        -AgentsContent $strValidLeapDateContent `
        -ParentAgentsContent $strValidLeapDateParent

    $strInvalidDateParent = $strAgentsContent.Replace(
        $objAgentsVersionMatch.Value,
        $strAgentsVersionPrefix + '99999999' + $strAgentsRevisionSuffix
    ).Replace(
        $objAgentsUpdatedMatch.Value,
        '- **Last Updated:** 9999-99-99'
    )
    Assert-Failure `
        -ParentAgentsContent $strInvalidDateParent `
        -Failure 'The parent of AGENTS.md must contain one real matching calendar date.'

    $strRenderedAgentsMutation = $strAgentsContent + [Environment]::NewLine +
        'A rendered governance note.' + [Environment]::NewLine
    Assert-Failure `
        -AgentsContent $strRenderedAgentsMutation `
        -ParentAgentsContent $strAgentsContent `
        -AgentsExpectedUtcDate '9999-99-99' `
        -Failure 'The expected UTC date for AGENTS.md is unavailable or invalid.'

    Assert-Failure `
        -AgentsContent $strRenderedAgentsMutation `
        -ParentAgentsContent $strAgentsContent `
        -AgentsExpectedUtcDate $objAgentsUpdatedMatch.Groups['Date'].Value `
        -Failure ("AGENTS.md Version revision must be greater than " +
            "$intAgentsRevision after a same-day content change.")

    $strHigherRevisionParent = $strAgentsContent.Replace(
        $objAgentsVersionMatch.Value,
        $strAgentsVersionStem + $intNextAgentsRevision
    )
    Assert-Failure `
        -AgentsContent $strRenderedAgentsMutation `
        -ParentAgentsContent $strHigherRevisionParent `
        -AgentsExpectedUtcDate $objAgentsUpdatedMatch.Groups['Date'].Value `
        -Failure ("AGENTS.md Version revision must not decrease from " +
            "$intNextAgentsRevision to $intAgentsRevision.")

    Assert-Failure `
        -ParentAgentsContent $strHigherRevisionParent `
        -AgentsExpectedUtcDate $objAgentsUpdatedMatch.Groups['Date'].Value `
        -Failure ("AGENTS.md Version revision must not decrease from " +
            "$intNextAgentsRevision to $intAgentsRevision.")

    Assert-FixtureAccepted `
        -ParentAgentsContent $strAgentsContent

    $strMaximumRevisionContent = $strAgentsContent.Replace(
        $objAgentsVersionMatch.Value,
        $strAgentsVersionStem + [int64]::MaxValue
    )
    Assert-FixtureAccepted `
        -AgentsContent $strMaximumRevisionContent `
        -ParentAgentsContent $strMaximumRevisionContent

    $strSameDayRevisionJump = $strRenderedAgentsMutation.Replace(
        $objAgentsVersionMatch.Value,
        $strAgentsVersionStem + $intJumpedAgentsRevision
    )
    Assert-FixtureAccepted `
        -AgentsContent $strSameDayRevisionJump `
        -ParentAgentsContent $strAgentsContent `
        -AgentsExpectedUtcDate $objAgentsUpdatedMatch.Groups['Date'].Value

    $objIsoEvent = ConvertFrom-TrustedEventTimestamp -Timestamp `
        ($objAgentsUpdatedMatch.Groups['Date'].Value + 'T00:00:00Z')
    $objUnixEvent = ConvertFrom-TrustedEventTimestamp -Timestamp '0'
    if ($objIsoEvent.ToString('yyyy-MM-dd') -cne
            $objAgentsUpdatedMatch.Groups['Date'].Value -or
        $objUnixEvent.ToString('o') -cne '1970-01-01T00:00:00.0000000+00:00') {
        throw 'Event timestamp parsing changed.'
    }
    foreach ($strBadEvent in @(
            '', 'bad', '2026-08-23T00:00:00+01:00', '2099-01-01T00:00:00Z')) {
        try {
            [void](ConvertFrom-TrustedEventTimestamp -Timestamp $strBadEvent)
            throw "Invalid trusted event timestamp was accepted: $strBadEvent"
        }
        catch {
            if (-not $_.Exception.Message.Contains(
                    'trusted GitHub event timestamp', [StringComparison]::Ordinal)) {
                throw
            }
        }
    }
    $strReplayCurrent = $strValidLeapDateContent + "`nStable replay content.`n"
    if (@(Get-CurrentInputMetadataFreshnessFailure `
            -Name 'AGENTS.md' -CurrentContent $strReplayCurrent `
            -BaseContent $strValidLeapDateParent `
            -TrustedEventUtcDate '2024-02-29').Count -ne 0) {
        throw 'Stable event replay changed.'
    }
    $strNextEventDate = $objIsoEvent.AddDays(1).ToString('yyyy-MM-dd')
    if (@(Get-CurrentInputMetadataFreshnessFailure `
            -Name 'AGENTS.md' -CurrentContent $strHigherRevisionParent `
            -BaseContent $strAgentsContent -TrustedEventUtcDate '2000-01-01').Count -ne 0) {
        throw 'Metadata-only input was rendered.'
    }

    Assert-Failure `
        -AgentsContent $strRenderedAgentsMutation `
        -ParentAgentsContent $strAgentsContent `
        -AgentsExpectedUtcDate '2099-01-01' `
        -Failure 'AGENTS.md Last Updated must be 2099-01-01 after a rendered-content change.'

    $strPreviousDateParent = $strAgentsContent.Replace(
        $objAgentsVersionMatch.Value,
        '**Version:** ' + $objAgentsVersionMatch.Groups['Prefix'].Value + '20000101.7'
    ).Replace(
        $objAgentsUpdatedMatch.Value,
        '- **Last Updated:** 2000-01-01'
    )
    Assert-FixtureAccepted `
        -AgentsContent $strRenderedAgentsMutation `
        -ParentAgentsContent $strPreviousDateParent `
        -AgentsExpectedUtcDate $objAgentsUpdatedMatch.Groups['Date'].Value

    $strNewDayReset = $strRenderedAgentsMutation.Replace(
        $objAgentsVersionMatch.Value,
        $strAgentsVersionStem + '0'
    )
    Assert-FixtureAccepted `
        -AgentsContent $strNewDayReset `
        -ParentAgentsContent $strPreviousDateParent `
        -AgentsExpectedUtcDate $objAgentsUpdatedMatch.Groups['Date'].Value

    $strMetadataForwardParent = $strAgentsContent.Replace(
        $objAgentsVersionMatch.Value,
        '**Version:** ' + $objAgentsVersionMatch.Groups['Prefix'].Value + '20000101.0'
    ).Replace(
        $objAgentsUpdatedMatch.Value,
        '- **Last Updated:** 2000-01-01'
    )
    Assert-FixtureAccepted `
        -ParentAgentsContent $strMetadataForwardParent

    $strRegressedDateContent = $strRenderedAgentsMutation.Replace(
        $objAgentsVersionMatch.Value,
        '**Version:** ' + $objAgentsVersionMatch.Groups['Prefix'].Value + '20000101.0'
    ).Replace(
        $objAgentsUpdatedMatch.Value,
        '- **Last Updated:** 2000-01-01'
    )
    Assert-Failure `
        -AgentsContent $strRegressedDateContent `
        -ParentAgentsContent $strAgentsContent `
        -AgentsExpectedUtcDate '2000-01-01' `
        -Failure ("AGENTS.md Version date must not move backward from " +
            "$($objAgentsVersionMatch.Groups['Date'].Value) to 20000101.")

    $strMetadataOnlyRegressedDate = $strAgentsContent.Replace(
        $objAgentsVersionMatch.Value,
        '**Version:** ' + $objAgentsVersionMatch.Groups['Prefix'].Value + '20000101.0'
    ).Replace(
        $objAgentsUpdatedMatch.Value,
        '- **Last Updated:** 2000-01-01'
    )
    Assert-Failure `
        -AgentsContent $strMetadataOnlyRegressedDate `
        -ParentAgentsContent $strAgentsContent `
        -AgentsExpectedUtcDate $objAgentsUpdatedMatch.Groups['Date'].Value `
        -Failure ("AGENTS.md Version date must not move backward from " +
            "$($objAgentsVersionMatch.Groups['Date'].Value) to 20000101.")

    $strEarlierStaleMetadataContent = $strAgentsContent +
        [Environment]::NewLine + 'Earlier rendered change with stale metadata.'
    $arrMultiCommitTransitionContexts = @(
        [pscustomobject]@{
            CurrentContent = $strEarlierStaleMetadataContent
            ParentContent = $strAgentsContent
            ExpectedUtcDate = $objAgentsUpdatedMatch.Groups['Date'].Value
            CurrentRevision = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
            ParentRevision = '0000000000000000000000000000000000000000'
        },
        [pscustomobject]@{
            CurrentContent = $strEarlierStaleMetadataContent
            ParentContent = $strEarlierStaleMetadataContent
            ExpectedUtcDate = $objAgentsUpdatedMatch.Groups['Date'].Value
            CurrentRevision = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
            ParentRevision = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
        }
    )
    $arrTransitionFailures = @(
        Get-DocumentMetadataRangeTransitionFailure `
            -Name 'AGENTS.md' `
            -TransitionContext $arrMultiCommitTransitionContexts
    )
    if ($arrTransitionFailures.Count -ne 1 -or
        -not $arrTransitionFailures[0].Contains(
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
            [StringComparison]::Ordinal
        ) -or
        -not $arrTransitionFailures[0].Contains(
            'Version revision must be greater',
            [StringComparison]::Ordinal
        )) {
        throw 'Multi-commit metadata validation did not preserve an earlier invalid transition.'
    }

    $strNewRefZeroRevision = '0' * 40
    $strNewRefTestHead = [string] (
        & git -C $strRepositoryRootPath rev-parse --verify HEAD
    )
    if ($LASTEXITCODE -ne 0 -or
        $strNewRefTestHead.Trim() -notmatch '^[0-9a-fA-F]{40}$') {
        throw 'Could not resolve the new-ref metadata self-test head.'
    }
    $strNewRefTestHead = $strNewRefTestHead.Trim()
    $objNewRef = Get-PushGovernedPathApplicability `
        -RepositoryRootPath $strRepositoryRootPath `
        -BaseRevision $strNewRefZeroRevision `
        -HeadRevision $strNewRefTestHead `
        -IsNewRef $true -IsDeletedRef $false
    if (-not $objNewRef.ShouldValidate -or
        $objNewRef.Decision -cne
            'NEW_REF_REQUIRES_FAIL_CLOSED_VALIDATION') {
        throw 'A new-ref push did not select fail-closed validation.'
    }
    $objDeleted = Get-PushGovernedPathApplicability `
        -RepositoryRootPath $strRepositoryRootPath `
        -BaseRevision $strNewRefTestHead `
        -HeadRevision $strNewRefZeroRevision `
        -IsNewRef $false -IsDeletedRef $true
    if ($objDeleted.ShouldValidate -or
        $objDeleted.Decision -cne
            'DELETED_REF_HAS_NO_REMAINING_BYTES') {
        throw 'A deleted-ref push did not select its exact no-op.'
    }
    $objUnchanged = Get-PushGovernedPathApplicability `
        -RepositoryRootPath $strRepositoryRootPath `
        -BaseRevision $strNewRefTestHead `
        -HeadRevision $strNewRefTestHead `
        -IsNewRef $false -IsDeletedRef $false
    if ($objUnchanged.ShouldValidate -or
        $objUnchanged.ChangedPathCount -ne 0) {
        throw 'An unchanged existing-ref push did not select its exact no-op.'
    }

    $strPushRoot = [IO.Path]::GetFullPath(
        [IO.Path]::Combine(
            [IO.Path]::GetTempPath(),
            'agent-instruction-push-' + [guid]::NewGuid().ToString('N')
        )
    )
    $strPushTempRoot = [IO.Path]::GetFullPath(
        [IO.Path]::GetTempPath()
    )
    if (-not $strPushRoot.StartsWith(
            $strPushTempRoot,
            [StringComparison]::OrdinalIgnoreCase
        )) {
        throw 'The push-applicability fixture escaped the system temporary directory.'
    }
    try {
        [void][System.IO.Directory]::CreateDirectory($strPushRoot)
        & git -C $strPushRoot init --quiet
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not initialize the push-applicability fixture.'
        }
        $objImportText = [Text.StringBuilder]::new()
        foreach ($strHeaderLine in @(
                'commit refs/heads/base',
                'mark :1',
                'author Fixture <fixture@example.invalid> 1700000000 +0000',
                'committer Fixture <fixture@example.invalid> 1700000000 +0000',
                'data 4',
                'base',
                'deleteall',
                'commit refs/heads/ungoverned',
                'mark :2',
                'author Fixture <fixture@example.invalid> 1700000001 +0000',
                'committer Fixture <fixture@example.invalid> 1700000001 +0000',
                'data 10',
                'ungoverned',
                'from :1'
            )) {
            [void]$objImportText.AppendLine($strHeaderLine)
        }
        foreach ($intFixturePath in 1..3000) {
            [void]$objImportText.AppendLine(
                'M 100644 inline bulk/file' +
                    $intFixturePath.ToString('D4') + '.txt'
            )
            [void]$objImportText.AppendLine('data 0')
            [void]$objImportText.AppendLine()
        }
        foreach ($strTrailerLine in @(
                'commit refs/heads/governed',
                'mark :3',
                'author Fixture <fixture@example.invalid> 1700000002 +0000',
                'committer Fixture <fixture@example.invalid> 1700000002 +0000',
                'data 8',
                'governed',
                'from :2',
                'M 100644 inline zzzz/tools/GEMINI.md',
                'data 0',
                '',
                'commit refs/heads/malformed-decision',
                'mark :8',
                'author Fixture <fixture@example.invalid> 1700000002 +0000',
                'committer Fixture <fixture@example.invalid> 1700000002 +0000',
                'data 18',
                'malformed decision',
                'from :2',
                'M 100644 inline docs/decisions/archive/0003-new-policy.md',
                'data 0',
                '',
                'commit refs/heads/multi',
                'mark :5',
                'author Fixture <fixture@example.invalid> 1700000003 +0000',
                'committer Fixture <fixture@example.invalid> 1700000003 +0000',
                'data 5',
                'multi',
                'from :3',
                'M 100644 inline unrelated.txt',
                'data 0',
                '',
                'commit refs/heads/divergent',
                'mark :4',
                'author Fixture <fixture@example.invalid> 1700000004 +0000',
                'committer Fixture <fixture@example.invalid> 1700000004 +0000',
                'data 9',
                'divergent',
                'from :1',
                'M 100644 inline zzzz/AGENTS.md',
                'data 0',
                '',
                'commit refs/heads/restore-change',
                'mark :6',
                'author Fixture <fixture@example.invalid> 1700000005 +0000',
                'committer Fixture <fixture@example.invalid> 1700000005 +0000',
                'data 14',
                'restore change',
                'from :1',
                'M 100644 inline AGENTS.md',
                'data 0',
                '',
                'commit refs/heads/restore',
                'mark :7',
                'author Fixture <fixture@example.invalid> 1700000006 +0000',
                'committer Fixture <fixture@example.invalid> 1700000006 +0000',
                'data 7',
                'restore',
                'from :6',
                'D AGENTS.md',
                '',
                'done'
            )) {
            [void]$objImportText.AppendLine($strTrailerLine)
        }
        $objImportStart = [Diagnostics.ProcessStartInfo]::new('git')
        $objImportStart.UseShellExecute = $false
        $objImportStart.CreateNoWindow = $true
        $objImportStart.RedirectStandardInput = $true
        $objImportStart.RedirectStandardOutput = $true
        $objImportStart.RedirectStandardError = $true
        foreach ($strImportArgument in @(
                '-C', $strPushRoot, 'fast-import', '--quiet'
            )) {
            $objImportStart.ArgumentList.Add($strImportArgument)
        }
        $objImportProcess = [Diagnostics.Process]::new()
        $objImportProcess.StartInfo = $objImportStart
        if (-not $objImportProcess.Start()) {
            throw 'Could not start the push-applicability fixture import.'
        }
        $objImportErrorTask = $objImportProcess.StandardError.ReadToEndAsync()
        $objImportOutputTask = $objImportProcess.StandardOutput.ReadToEndAsync()
        $objImportWriteFailure = $null
        try {
            $objImportProcess.StandardInput.Write(
                $objImportText.ToString().Replace("`r`n", "`n")
            )
        }
        catch {
            $objImportWriteFailure = $_.Exception
        }
        $objImportProcess.StandardInput.Close()
        if (-not $objImportProcess.WaitForExit(10000)) {
            $objImportProcess.Kill($true)
            throw 'The push-applicability fixture import timed out.'
        }
        $strImportError = $objImportErrorTask.GetAwaiter().GetResult()
        [void]$objImportOutputTask.GetAwaiter().GetResult()
        if ($null -ne $objImportWriteFailure -or
            $objImportProcess.ExitCode -ne 0) {
            throw (
                'Could not import the push-applicability fixture: ' +
                $strImportError.Trim()
            )
        }
        $objImportProcess.Dispose()

        $strPushBase = [string] (
            & git -C $strPushRoot rev-parse refs/heads/base
        )
        $strPushUngoverned = [string] (
            & git -C $strPushRoot rev-parse refs/heads/ungoverned
        )
        $strPushGoverned = [string] (
            & git -C $strPushRoot rev-parse refs/heads/governed
        )
        $strPushMalformedDecision = [string] (
            & git -C $strPushRoot rev-parse refs/heads/malformed-decision
        )
        $strPushMulti = [string] (
            & git -C $strPushRoot rev-parse refs/heads/multi
        )
        $strPushDivergent = [string] (
            & git -C $strPushRoot rev-parse refs/heads/divergent
        )
        $strPushRestore = [string] (
            & git -C $strPushRoot rev-parse refs/heads/restore
        )
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not resolve the push-applicability fixture commits.'
        }
        $strPushBase = $strPushBase.Trim()
        $strPushUngoverned = $strPushUngoverned.Trim()
        $strPushGoverned = $strPushGoverned.Trim()
        $strPushMalformedDecision = $strPushMalformedDecision.Trim()
        $strPushMulti = $strPushMulti.Trim()
        $strPushDivergent = $strPushDivergent.Trim()
        $strPushRestore = $strPushRestore.Trim()

        $strMultiEvidence = ConvertTo-Json -Compress -InputObject @(
            $strPushUngoverned,
            $strPushGoverned,
            $strPushMulti
        )
        $objMultiContext = Get-MetadataEventRevisionContext `
            -RepositoryRootPath $strPushRoot `
            -EventName 'push' -PullRequestAction '' `
            -BaseRevision ('0' * 40) -HeadRevision $strPushMulti `
            -IsNewRefRange $true -PreviousHeadRevision '' `
            -EventHeadRevision $strPushMulti -EventHeadDistinct 'true' `
            -NewRefCommitCount '3' `
            -NewRefCommitEvidenceJson $strMultiEvidence
        if ($objMultiContext.FreshnessBaseRevision -cne
                $strPushBase -or
            -not $objMultiContext.EvaluateFreshness) {
            throw 'Complete multi-commit new-ref evidence did not select its full boundary.'
        }
        $strZeroRevision = '0' * 40
        $objExistingContext = Get-MetadataEventRevisionContext `
            -RepositoryRootPath $strPushRoot -EventName 'push' -PullRequestAction '' `
            -BaseRevision $strZeroRevision -HeadRevision $strPushMulti `
            -IsNewRefRange $true -PreviousHeadRevision '' -EventHeadRevision $strPushMulti `
            -EventHeadDistinct 'false' `
            -NewRefCommitCount '0' -NewRefCommitEvidenceJson '[]'
        if ($objExistingContext.HistoryBaseRevision -cne
                $strZeroRevision -or
            $objExistingContext.FreshnessBaseRevision -cne '' -or
            $objExistingContext.EvaluateFreshness) {
            throw 'Existing new-ref context is invalid.'
        }
        $boolIncompleteRejected = $false
        try {
            [void](Get-MetadataEventRevisionContext `
                    -RepositoryRootPath $strPushRoot `
                    -EventName 'push' -PullRequestAction '' `
                    -BaseRevision ('0' * 40) -HeadRevision $strPushMulti `
                    -IsNewRefRange $true -PreviousHeadRevision '' `
                    -EventHeadRevision $strPushMulti -EventHeadDistinct 'true' `
                    -NewRefCommitCount '4' `
                    -NewRefCommitEvidenceJson $strMultiEvidence)
        }
        catch {
            $boolIncompleteRejected = $_.Exception.Message.Contains(
                'commit evidence is incomplete',
                [StringComparison]::Ordinal
            )
        }
        if (-not $boolIncompleteRejected) {
            throw 'Incomplete authenticated new-ref evidence did not fail closed.'
        }

        & git -C $strPushRoot update-ref HEAD $strPushUngoverned
        $objUngoverned = Get-PushGovernedPathApplicability `
            -RepositoryRootPath $strPushRoot `
            -BaseRevision $strPushBase `
            -HeadRevision $strPushUngoverned `
            -IsNewRef $false -IsDeletedRef $false
        if ($objUngoverned.ShouldValidate -or
            $objUngoverned.ChangedPathCount -ne 3000) {
            throw 'An exact 3,000-path ungoverned push did not select no-op.'
        }

        & git -C $strPushRoot update-ref HEAD $strPushGoverned
        $objGoverned = Get-PushGovernedPathApplicability `
            -RepositoryRootPath $strPushRoot `
            -BaseRevision $strPushBase `
            -HeadRevision $strPushGoverned `
            -IsNewRef $false -IsDeletedRef $false
        if (-not $objGoverned.ShouldValidate -or
            $objGoverned.ChangedPathCount -ne 3001) {
            throw 'A governed path after 3,000 other paths was not validated.'
        }

        & git -C $strPushRoot update-ref HEAD $strPushMalformedDecision
        $arrMalformedDecisionPaths = @(& git -C $strPushRoot diff `
                --name-only $strPushUngoverned $strPushMalformedDecision --)
        $objMalformedDecision = Get-PushGovernedPathApplicability `
            -RepositoryRootPath $strPushRoot `
            -BaseRevision $strPushUngoverned `
            -HeadRevision $strPushMalformedDecision `
            -IsNewRef $false -IsDeletedRef $false
        if ($arrMalformedDecisionPaths.Count -ne 1 -or
            $arrMalformedDecisionPaths[0] -cne
                'docs/decisions/archive/0003-new-policy.md' -or
            -not $objMalformedDecision.ShouldValidate -or
            $objMalformedDecision.ChangedPathCount -ne 1) {
            throw 'A nested decision-record push escaped exact applicability.'
        }

        & git -C $strPushRoot update-ref HEAD $strPushDivergent
        $objDivergent = Get-PushGovernedPathApplicability `
            -RepositoryRootPath $strPushRoot `
            -BaseRevision $strPushUngoverned `
            -HeadRevision $strPushDivergent `
            -IsNewRef $false -IsDeletedRef $false
        if (-not $objDivergent.ShouldValidate) {
            throw 'A divergent governed push did not use exact endpoint trees.'
        }

        & git -C $strPushRoot update-ref HEAD $strPushRestore
        $objRestore = Get-PushGovernedPathApplicability `
            -RepositoryRootPath $strPushRoot `
            -BaseRevision $strPushBase `
            -HeadRevision $strPushRestore `
            -IsNewRef $false -IsDeletedRef $false
        if (-not $objRestore.ShouldValidate -or
            $objRestore.ChangedPathCount -ne 2) {
            throw 'A governed change-then-restore push escaped range applicability.'
        }

        & git -C $strPushRoot update-ref HEAD $strPushUngoverned
        $objBackward = Get-PushGovernedPathApplicability `
            -RepositoryRootPath $strPushRoot `
            -BaseRevision $strPushGoverned `
            -HeadRevision $strPushUngoverned `
            -IsNewRef $false -IsDeletedRef $false
        if (-not $objBackward.ShouldValidate -or
            $objBackward.ChangedPathCount -ne 1) {
            throw 'A backward governed endpoint change escaped applicability.'
        }

        & git -C $strPushRoot update-ref HEAD $strPushDivergent
        $boolMissingPushEndpointRejected = $false
        try {
            [void](Get-PushGovernedPathApplicability `
                    -RepositoryRootPath $strPushRoot `
                    -BaseRevision ('f' * 40) `
                    -HeadRevision $strPushDivergent `
                    -IsNewRef $false -IsDeletedRef $false)
        }
        catch {
            $boolMissingPushEndpointRejected = $_.Exception.Message.Contains(
                'Push endpoint commit is unavailable',
                [StringComparison]::Ordinal
            )
        }
        if (-not $boolMissingPushEndpointRejected) {
            throw 'A missing push endpoint did not fail closed.'
        }
    }
    finally {
        if ([System.IO.Directory]::Exists($strPushRoot) -and
            $strPushRoot.StartsWith(
                $strPushTempRoot,
                [StringComparison]::OrdinalIgnoreCase
            )) {
            Remove-Item -LiteralPath $strPushRoot -Recurse -Force
        }
    }
    $strRevisionAgentsFixture = Read-GitRevisionText `
        -RepositoryRootPath $strRepositoryRootPath `
        -Revision $strNewRefTestHead `
        -RepositoryRelativePath 'AGENTS.md' `
        -MaximumBytes $intAgentsMaximumInputBytes `
        -RequireRegularFile
    if (-not [string]::Equals(
            $strRevisionAgentsFixture,
            (Read-GitRevisionText `
                -RepositoryRootPath $strRepositoryRootPath `
                -Revision $strNewRefTestHead `
                -RepositoryRelativePath 'AGENTS.md' `
                -MaximumBytes $intAgentsMaximumInputBytes),
            [StringComparison]::Ordinal
        )) {
        throw 'Regular revision input validation changed the accepted blob content.'
    }
    $boolMissingRevisionInputRejected = $false
    try {
        [void](Read-GitRevisionText `
                -RepositoryRootPath $strRepositoryRootPath `
                -Revision $strNewRefTestHead `
                -RepositoryRelativePath '.missing-agent-instruction-input' `
                -MaximumBytes 128 `
                -RequireRegularFile)
    }
    catch {
        $boolMissingRevisionInputRejected = $_.Exception.Message.Contains(
            'not one regular 100644 blob',
            [StringComparison]::Ordinal
        )
    }
    if (-not $boolMissingRevisionInputRejected) {
        throw 'A missing revision input did not fail the regular-blob check.'
    }
    $objRevisionParentFixture = Get-GovernedDocumentParentContext `
        -RepositoryRootPath $strRepositoryRootPath `
        -RepositoryRelativePath 'AGENTS.md' `
        -MaximumBytes $intAgentsMaximumInputBytes `
        -Revision $strNewRefTestHead
    if ($objRevisionParentFixture.ParentRevision -cne "$strNewRefTestHead`^1" -or
        [string]::IsNullOrEmpty($objRevisionParentFixture.ParentContent)) {
        throw 'The explicit revision parent context is invalid.'
    }
    $arrNewRefRangeFailures = @(Get-GovernedDocumentRangeTransitionFailure `
            -Name 'AGENTS.md' `
            -RepositoryRootPath $strRepositoryRootPath `
            -RepositoryRelativePath 'AGENTS.md' `
            -MaximumBytes $intAgentsMaximumInputBytes `
            -BaseRevision $strNewRefZeroRevision `
            -HeadRevision $strNewRefTestHead `
            -IsNewRefRange $true `
            -PolicyRepositoryRelativePath '.github/workflows/Test-AgentInstructions.ps1' `
            -PolicyMaximumBytes $intValidatorMaximumInputBytes `
            -PolicyMarker $strMetadataRangePolicyMarker)
    if ($arrNewRefRangeFailures.Count -ne 0) {
        throw "Valid new-ref metadata range failed: $($arrNewRefRangeFailures -join '; ')"
    }
    $boolInconsistentNewRefEvidenceRejected = $false
    try {
        [void](Get-MetadataEventRevisionContext `
                -RepositoryRootPath $strRepositoryRootPath -EventName 'push' `
                -PullRequestAction '' -BaseRevision $strNewRefZeroRevision `
                -HeadRevision $strNewRefTestHead -IsNewRefRange $true `
                -PreviousHeadRevision '' -EventHeadRevision $strNewRefTestHead `
                -EventHeadDistinct 'false' -NewRefCommitCount '1' `
                -NewRefCommitEvidenceJson (ConvertTo-Json -Compress `
                    -InputObject @($strNewRefTestHead)))
    }
    catch {
        $boolInconsistentNewRefEvidenceRejected = $_.Exception.Message.Contains(
            'must report zero introduced commits',
            [StringComparison]::Ordinal
        )
    }
    if (-not $boolInconsistentNewRefEvidenceRejected) {
        throw 'Inconsistent new-ref evidence did not fail closed.'
    }
    if (@(Get-CurrentInputMetadataFreshnessFailure -Name 'AGENTS.md' `
            -CurrentContent $strSameDayRevisionJump -BaseContent $strAgentsContent `
            -TrustedEventUtcDate $strNextEventDate).Count -ne 1) {
        throw 'Stale new-ref head passed.'
    }

    $strExistingPushBase = [string] (
        & git -C $strRepositoryRootPath rev-parse --verify 'HEAD^'
    )
    if ($LASTEXITCODE -ne 0 -or
        $strExistingPushBase.Trim() -notmatch '^[0-9a-fA-F]{40}$') {
        throw 'Could not resolve the existing-ref metadata self-test base.'
    }
    $strExistingPushBase = $strExistingPushBase.Trim()
    $arrTruncatedPushCommitIds = @(
        foreach ($intCommitId in 1..2048) {
            $intCommitId.ToString('x40')
        }
    )
    if ($arrTruncatedPushCommitIds.Count -ne 2048 -or
        $arrTruncatedPushCommitIds -contains $strNewRefTestHead) {
        throw 'The truncated push payload fixture is invalid.'
    }
    $objTruncatedPushContext = Get-MetadataEventRevisionContext `
        -RepositoryRootPath $strRepositoryRootPath -EventName 'push' `
        -PullRequestAction '' -BaseRevision $strExistingPushBase `
        -HeadRevision $strNewRefTestHead -IsNewRefRange $false `
        -PreviousHeadRevision '' -EventHeadRevision $strNewRefTestHead `
        -EventHeadDistinct 'true'
    if ($objTruncatedPushContext.HistoryBaseRevision -cne $strExistingPushBase -or
        $objTruncatedPushContext.FreshnessBaseRevision -cne $strExistingPushBase) {
        throw 'A truncated push payload suppressed exact pushed-head freshness.'
    }
    $objExistingHeadPushContext = Get-MetadataEventRevisionContext `
        -RepositoryRootPath $strRepositoryRootPath -EventName 'push' `
        -PullRequestAction '' -BaseRevision $strExistingPushBase `
        -HeadRevision $strNewRefTestHead -IsNewRefRange $false `
        -PreviousHeadRevision '' -EventHeadRevision $strNewRefTestHead `
        -EventHeadDistinct 'false'
    if ($objExistingHeadPushContext.FreshnessBaseRevision -cne '') {
        throw 'A move to an existing pushed head required event-date freshness.'
    }

    foreach ($objInvalidPushHead in @(
            [pscustomobject]@{
                Name = 'missing expanded head'
                Revision = ''
                Distinct = 'true'
                Failure = 'requires a valid expanded head revision'
            },
            [pscustomobject]@{
                Name = 'mismatched expanded head'
                Revision = $strExistingPushBase
                Distinct = 'true'
                Failure = 'must match the event after revision'
            },
            [pscustomobject]@{
                Name = 'missing distinct value'
                Revision = $strNewRefTestHead
                Distinct = ''
                Failure = 'distinct value must be true or false'
            },
            [pscustomobject]@{
                Name = 'null distinct value'
                Revision = $strNewRefTestHead
                Distinct = 'null'
                Failure = 'distinct value must be true or false'
            },
            [pscustomobject]@{
                Name = 'wrong-case distinct value'
                Revision = $strNewRefTestHead
                Distinct = 'True'
                Failure = 'distinct value must be true or false'
            }
        )) {
        $boolInvalidPushHeadRejected = $false
        try {
            [void](Get-MetadataEventRevisionContext `
                    -RepositoryRootPath $strRepositoryRootPath -EventName 'push' `
                    -PullRequestAction '' -BaseRevision $strExistingPushBase `
                    -HeadRevision $strNewRefTestHead -IsNewRefRange $false `
                    -PreviousHeadRevision '' `
                    -EventHeadRevision $objInvalidPushHead.Revision `
                    -EventHeadDistinct $objInvalidPushHead.Distinct)
        }
        catch {
            $boolInvalidPushHeadRejected = $_.Exception.Message.Contains(
                $objInvalidPushHead.Failure,
                [StringComparison]::Ordinal
            )
        }
        if (-not $boolInvalidPushHeadRejected) {
            throw "Invalid push head passed: $($objInvalidPushHead.Name)"
        }
    }

    $boolUnflaggedZeroBaseRejected = $false
    try {
        [void](Get-GovernedDocumentRangeTransitionFailure `
                -Name 'AGENTS.md' `
                -RepositoryRootPath $strRepositoryRootPath `
                -RepositoryRelativePath 'AGENTS.md' `
                -MaximumBytes $intAgentsMaximumInputBytes `
                -BaseRevision $strNewRefZeroRevision `
                -HeadRevision $strNewRefTestHead `
                -IsNewRefRange $false `
                -PolicyRepositoryRelativePath '.github/workflows/Test-AgentInstructions.ps1' `
                -PolicyMaximumBytes $intValidatorMaximumInputBytes `
                -PolicyMarker $strMetadataRangePolicyMarker)
    }
    catch {
        $boolUnflaggedZeroBaseRejected = $_.Exception.Message.Contains(
            'requires the new-ref flag',
            [StringComparison]::Ordinal
        )
    }
    if (-not $boolUnflaggedZeroBaseRejected) {
        throw 'An unflagged all-zero metadata range base did not fail closed.'
    }

    $boolFlaggedNonzeroBaseRejected = $false
    try {
        [void](Get-GovernedDocumentRangeTransitionFailure `
                -Name 'AGENTS.md' `
                -RepositoryRootPath $strRepositoryRootPath `
                -RepositoryRelativePath 'AGENTS.md' `
                -MaximumBytes $intAgentsMaximumInputBytes `
                -BaseRevision $strNewRefTestHead `
                -HeadRevision $strNewRefTestHead `
                -IsNewRefRange $true `
                -PolicyRepositoryRelativePath '.github/workflows/Test-AgentInstructions.ps1' `
                -PolicyMaximumBytes $intValidatorMaximumInputBytes `
                -PolicyMarker $strMetadataRangePolicyMarker)
    }
    catch {
        $boolFlaggedNonzeroBaseRejected = $_.Exception.Message.Contains(
            'requires an all-zero base revision',
            [StringComparison]::Ordinal
        )
    }
    if (-not $boolFlaggedNonzeroBaseRejected) {
        throw 'A flagged nonzero metadata range base did not fail closed.'
    }

    $arrOrdinarySameHeadFailures = @(Get-GovernedDocumentRangeTransitionFailure `
            -Name 'AGENTS.md' `
            -RepositoryRootPath $strRepositoryRootPath `
            -RepositoryRelativePath 'AGENTS.md' `
            -MaximumBytes $intAgentsMaximumInputBytes `
            -BaseRevision $strNewRefTestHead `
            -HeadRevision $strNewRefTestHead `
            -InputRevision $strNewRefTestHead `
            -IsNewRefRange $false `
            -PolicyRepositoryRelativePath '.github/workflows/Test-AgentInstructions.ps1' `
            -PolicyMaximumBytes $intValidatorMaximumInputBytes `
            -PolicyMarker $strMetadataRangePolicyMarker)
    if ($arrOrdinarySameHeadFailures.Count -ne 0) {
        throw 'An unchanged ordinary metadata range did not retain its prior behavior.'
    }

    $strMergeFixtureRoot = [IO.Path]::GetFullPath(
        [IO.Path]::Combine(
            [IO.Path]::GetTempPath(),
            'agent-instruction-merge-' + [guid]::NewGuid().ToString('N')
        )
    )
    $strSystemTempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    if (-not $strMergeFixtureRoot.StartsWith(
            $strSystemTempRoot,
            [StringComparison]::OrdinalIgnoreCase
        )) {
        throw 'The merge-transition fixture path escaped the system temporary directory.'
    }
    $boolHadAuthorDate = Test-Path -LiteralPath Env:GIT_AUTHOR_DATE
    $boolHadCommitterDate = Test-Path -LiteralPath Env:GIT_COMMITTER_DATE
    $strOriginalAuthorDate = if ($boolHadAuthorDate) { $env:GIT_AUTHOR_DATE } else { '' }
    $strOriginalCommitterDate = if ($boolHadCommitterDate) {
        $env:GIT_COMMITTER_DATE
    }
    else {
        ''
    }
    try {
        [void][System.IO.Directory]::CreateDirectory($strMergeFixtureRoot)
        & git -C $strMergeFixtureRoot init --quiet
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not initialize the merge-transition fixture repository.'
        }
        & git -C $strMergeFixtureRoot config core.autocrlf false
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not configure the merge-transition fixture repository.'
        }
        $strMergePolicyPath = [IO.Path]::Combine(
            $strMergeFixtureRoot,
            '.github',
            'workflows',
            'Test-AgentInstructions.ps1'
        )
        $strMergeUnversionedRelativePath = 'docs/ISSUE_EVALUATION_PROMPT.md'
        $strMergeUnversionedPath = [IO.Path]::Combine(
            $strMergeFixtureRoot,
            'docs',
            'ISSUE_EVALUATION_PROMPT.md'
        )
        $strMergeGitIgnorePath = [IO.Path]::Combine(
            $strMergeFixtureRoot,
            '.gitignore'
        )
        [void][System.IO.Directory]::CreateDirectory(
            [IO.Path]::GetDirectoryName($strMergePolicyPath)
        )
        [void][System.IO.Directory]::CreateDirectory(
            [IO.Path]::GetDirectoryName($strMergeUnversionedPath)
        )
        $objUtf8WithoutBom = [System.Text.UTF8Encoding]::new($false)
        $objMergeCurrentDate = [DateTime]::ParseExact(
            $objAgentsUpdatedMatch.Groups['Date'].Value,
            'yyyy-MM-dd',
            [System.Globalization.CultureInfo]::InvariantCulture
        )
        $strMergeCurrentDate = $objMergeCurrentDate.ToString(
            'yyyy-MM-dd',
            [System.Globalization.CultureInfo]::InvariantCulture
        )
        $strMergeHistoricalDate = $objMergeCurrentDate.AddDays(-1).ToString(
            'yyyy-MM-dd',
            [System.Globalization.CultureInfo]::InvariantCulture
        )
        $strMergeBaseVersion = '**Version:** ' +
            $objAgentsVersionMatch.Groups['Prefix'].Value +
            $strMergeHistoricalDate.Replace('-', '') + '.0'
        $strMergeBaseContent = $strAgentsContent.Replace(
            $objAgentsVersionMatch.Value,
            $strMergeBaseVersion
        ).Replace(
            $objAgentsUpdatedMatch.Value,
            "- **Last Updated:** $strMergeHistoricalDate"
        )
        [IO.File]::WriteAllText(
            [IO.Path]::Combine($strMergeFixtureRoot, 'AGENTS.md'),
            $strMergeBaseContent,
            $objUtf8WithoutBom
        )
        [IO.File]::WriteAllText(
            $strMergePolicyPath,
            $strMetadataRangePolicyMarker,
            $objUtf8WithoutBom
        )
        [IO.File]::WriteAllText(
            $strMergeUnversionedPath,
            $objUnversionedDocument.Content,
            $objUtf8WithoutBom
        )
        [IO.File]::WriteAllText(
            $strMergeGitIgnorePath,
            "/CLAUDE.local.md`n",
            $objUtf8WithoutBom
        )
        & git -C $strMergeFixtureRoot add -- `
            'AGENTS.md' '.github/workflows/Test-AgentInstructions.ps1' `
            $strMergeUnversionedRelativePath '.gitignore'
        $strMergeBaseTree = [string] (& git -C $strMergeFixtureRoot write-tree)
        if ($LASTEXITCODE -ne 0 -or
            $strMergeBaseTree.Trim() -notmatch '^(?:[0-9a-fA-F]{40}|[0-9a-fA-F]{64})$') {
            throw 'Could not create the merge-transition base tree.'
        }
        $strMergeBaseTree = $strMergeBaseTree.Trim()

        $scriptBlockNewPolicyTree = {
            param([byte[]] $Bytes, [string] $Mode = '100644')
            [IO.File]::WriteAllBytes($strMergePolicyPath, $Bytes)
            $strBlob = ([string](& git -C $strMergeFixtureRoot hash-object -w -- `
                        $strMergePolicyPath)).Trim()
            & git -C $strMergeFixtureRoot read-tree $strMergeBaseTree
            & git -C $strMergeFixtureRoot update-index --cacheinfo `
                "$Mode,$strBlob,.github/workflows/Test-AgentInstructions.ps1"
            $strTree = ([string](& git -C $strMergeFixtureRoot write-tree)).Trim()
            if ($LASTEXITCODE -ne 0 -or $strTree -notmatch '^[0-9a-fA-F]{40}$') {
                throw 'Could not create an immutable policy-marker fixture.'
            }
            return $strTree
        }
        $scriptBlockAssertHistoryFailure = {
            param([string] $Tree, [string] $Message)
            $boolRejected = $false
            try {
                [void](Test-HistoricalPolicyMarker -RepositoryRootPath $strMergeFixtureRoot `
                        -Revision $Tree -RepositoryRelativePath `
                        '.github/workflows/Test-AgentInstructions.ps1' `
                        -Literal $strMetadataRangePolicyMarker)
            }
            catch {
                $boolRejected = $_.Exception.Message.Contains(
                    $Message, [StringComparison]::Ordinal)
            }
            if (-not $boolRejected) { throw "Historical policy fixture was not rejected: $Message" }
        }
        $arrBoundedHistory = [Text.Encoding]::UTF8.GetBytes(
            $strMetadataRangePolicyMarker +
            ('x' * (393217 - $strMetadataRangePolicyMarker.Length)))
        $strBoundedHistoryTree = & $scriptBlockNewPolicyTree $arrBoundedHistory
        if (-not (Test-HistoricalPolicyMarker -RepositoryRootPath $strMergeFixtureRoot `
                    -Revision $strBoundedHistoryTree -RepositoryRelativePath `
                    '.github/workflows/Test-AgentInstructions.ps1' `
                    -Literal $strMetadataRangePolicyMarker)) {
            throw 'A bounded immutable historical marker was not found.'
        }
        $strAbsentHistoryTree = & $scriptBlockNewPolicyTree `
            ([Text.Encoding]::UTF8.GetBytes('marker absent'))
        if (Test-HistoricalPolicyMarker -RepositoryRootPath $strMergeFixtureRoot `
                -Revision $strAbsentHistoryTree -RepositoryRelativePath `
                '.github/workflows/Test-AgentInstructions.ps1' `
                -Literal $strMetadataRangePolicyMarker) {
            throw 'A historical marker-absent policy was classified as governed.'
        }
        & $scriptBlockAssertHistoryFailure `
            (& $scriptBlockNewPolicyTree ([byte[]]::new(524289))) 'must not exceed 524288 bytes'
        & $scriptBlockAssertHistoryFailure `
            (& $scriptBlockNewPolicyTree ([byte[]] @(0xC3, 0x28))) 'valid UTF-8 without a BOM'
        & $scriptBlockAssertHistoryFailure `
            (& $scriptBlockNewPolicyTree `
                ([Text.Encoding]::UTF8.GetBytes($strMetadataRangePolicyMarker)) '120000') `
            'not one regular 100644 blob'

        $scriptBlockCreateMergeFixtureCommit = {
            param(
                [string] $Tree,
                [string[]] $Parents,
                [string] $Timestamp,
                [string] $Message
            )

            $env:GIT_AUTHOR_DATE = $Timestamp
            $env:GIT_COMMITTER_DATE = $Timestamp
            $arrCommitArguments = @(
                '-C', $strMergeFixtureRoot,
                '-c', 'user.name=Agent Instruction Validator',
                '-c', 'user.email=validator@example.invalid',
                'commit-tree', $Tree
            )
            foreach ($strFixtureParent in $Parents) {
                $arrCommitArguments += @('-p', $strFixtureParent)
            }
            $arrCommitArguments += @('-m', $Message)
            $strFixtureCommit = [string] (& git @arrCommitArguments)
            if ($LASTEXITCODE -ne 0 -or
                $strFixtureCommit.Trim() -notmatch '^(?:[0-9a-fA-F]{40}|[0-9a-fA-F]{64})$') {
                throw "Could not create merge-transition fixture commit: $Message"
            }
            return $strFixtureCommit.Trim()
        }
        $scriptBlockGetMergeRangeFailure = {
            param(
                [string] $Base,
                [string] $Head,
                [bool] $RequireCommitDate = $false
            )
            Get-GovernedDocumentRangeTransitionFailure -Name 'AGENTS.md' `
                -RepositoryRootPath $strMergeFixtureRoot `
                -RepositoryRelativePath 'AGENTS.md' `
                -MaximumBytes $intAgentsMaximumInputBytes `
                -BaseRevision $Base -HeadRevision $Head -InputRevision $Head `
                -IsNewRefRange $false `
                -PolicyRepositoryRelativePath '.github/workflows/Test-AgentInstructions.ps1' `
                -PolicyMaximumBytes 1024 -PolicyMarker $strMetadataRangePolicyMarker `
                -RequireExpectedUtcDateForRenderedChange $RequireCommitDate
        }
        $scriptBlockGetDirectFailure = {
            param([string] $Commit)
            Get-GovernedDocumentCommitTransitionFailure -Name 'AGENTS.md' `
                -RepositoryRootPath $strMergeFixtureRoot `
                -RepositoryRelativePath 'AGENTS.md' `
                -MaximumBytes $intAgentsMaximumInputBytes `
                -CommitRevision $Commit `
                -PolicyRepositoryRelativePath '.github/workflows/Test-AgentInstructions.ps1' `
                -PolicyMaximumBytes 1024 -PolicyMarker $strMetadataRangePolicyMarker `
                -RequireExpectedUtcDateForRenderedChange $true
        }
        $scriptBlockGetUnversionedRangeFailure = {
            param([string] $Base, [string] $Head)
            Get-GovernedDocumentRangeTransitionFailure `
                -Name $strMergeUnversionedRelativePath `
                -RepositoryRootPath $strMergeFixtureRoot `
                -RepositoryRelativePath $strMergeUnversionedRelativePath `
                -MaximumBytes $intInstructionDocumentMaximumInputBytes `
                -BaseRevision $Base -HeadRevision $Head -InputRevision $Head `
                -IsNewRefRange $false `
                -PolicyRepositoryRelativePath `
                    '.github/workflows/Test-AgentInstructions.ps1' `
                -PolicyMaximumBytes 1024 `
                -PolicyMarker $strMetadataRangePolicyMarker `
                -RequireExpectedUtcDateForRenderedChange $true `
                -RequiresVersion $false
        }

        & git -C $strMergeFixtureRoot read-tree $strMergeBaseTree
        $strCaseFixtureBlob = [string] (
            'case-folded instruction fixture' |
                & git -C $strMergeFixtureRoot hash-object -w --stdin
        )
        if ($LASTEXITCODE -ne 0 -or
            $strCaseFixtureBlob.Trim() -notmatch '^(?:[0-9a-fA-F]{40}|[0-9a-fA-F]{64})$') {
            throw 'Could not create the case-folded instruction fixture blob.'
        }
        foreach ($strCaseFoldedGovernedPath in $arrCaseFoldedGovernedPaths) {
            & git -C $strMergeFixtureRoot update-index --add --cacheinfo `
                "100644,$($strCaseFixtureBlob.Trim()),$strCaseFoldedGovernedPath"
            if ($LASTEXITCODE -ne 0) {
                throw "Could not add case-folded instruction fixture: $strCaseFoldedGovernedPath"
            }
        }
        $strCaseFoldedTree = ([string] (
                & git -C $strMergeFixtureRoot write-tree
            )).Trim()
        $arrCaseFoldedTreePaths = @(Read-GitTrackedPath `
                -RepositoryRootPath $strMergeFixtureRoot `
                -Revision $strCaseFoldedTree `
                -MaximumBytes $intGitPathListMaximumBytes)
        foreach ($strCaseFoldedGovernedPath in $arrCaseFoldedGovernedPaths) {
            if ($arrCaseFoldedTreePaths -cnotcontains $strCaseFoldedGovernedPath) {
                throw "A case-folded path was lost from the synthetic Git tree: $strCaseFoldedGovernedPath"
            }
        }
        $arrCaseFoldedInventoryPaths = @(
            $arrCaseFoldedTreePaths |
                Where-Object {
                    Test-GovernedInstructionInventoryPath `
                        -RepositoryRelativePath ([string] $_)
                }
        )
        foreach ($strCaseFoldedGovernedPath in $arrCaseFoldedGovernedPaths) {
            if ($arrCaseFoldedInventoryPaths -cnotcontains $strCaseFoldedGovernedPath) {
                throw "A case-folded path escaped the synthetic tracked inventory: $strCaseFoldedGovernedPath"
            }
            $arrCaseFoldedInventoryFailures = @(
                Get-GovernedInstructionInventoryFailure `
                    -CatalogPaths @($arrGovernedInstructionDocuments.Path) `
                    -TrackedPaths @(
                        $arrTrackedGovernedInstructionPaths +
                            $strCaseFoldedGovernedPath
                    )
            )
            if (-not ($arrCaseFoldedInventoryFailures -ccontains (
                        'Tracked governed instruction is missing from the catalog: ' +
                        $strCaseFoldedGovernedPath
                    ))) {
                throw "A case-folded exact path did not fail ordinal inventory: $strCaseFoldedGovernedPath"
            }
        }
        & git -C $strMergeFixtureRoot read-tree $strMergeBaseTree

        $strMergeBaseCommit = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strMergeBaseTree `
            -Parents @() `
            -Timestamp ($strMergeHistoricalDate + 'T08:00:00Z') `
            -Message 'merge fixture base'

        & git -C $strMergeFixtureRoot read-tree $strMergeBaseTree
        [IO.File]::WriteAllText(
            $strMergeGitIgnorePath,
            "node_modules/`n",
            $objUtf8WithoutBom
        )
        & git -C $strMergeFixtureRoot add -- '.gitignore'
        $strProposedGitIgnoreTree = ([string] (
                & git -C $strMergeFixtureRoot write-tree
            )).Trim()
        $strProposedGitIgnoreCommit = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strProposedGitIgnoreTree `
            -Parents @($strMergeBaseCommit) `
            -Timestamp ($strMergeCurrentDate + 'T00:00:40Z') `
            -Message 'proposed gitignore deletion'
        $strProposedGitIgnore = Read-GitRevisionText `
            -RepositoryRootPath $strMergeFixtureRoot `
            -Revision $strProposedGitIgnoreCommit `
            -RepositoryRelativePath '.gitignore' `
            -MaximumBytes $intGitIgnoreMaximumInputBytes `
            -RequireRegularFile
        if ($strProposedGitIgnore -cmatch '(?m)^/CLAUDE\.local\.md$') {
            throw 'The proposed .gitignore deletion fixture retained the required rule.'
        }
        [IO.File]::WriteAllText(
            $strMergeGitIgnorePath,
            "/CLAUDE.local.md`n",
            $objUtf8WithoutBom
        )

        & git -C $strMergeFixtureRoot read-tree $strMergeBaseTree
        [IO.File]::WriteAllText(
            $strMergeUnversionedPath,
            $objUnversionedDocument.Content + "`nRendered stale range change.`n",
            $objUtf8WithoutBom
        )
        & git -C $strMergeFixtureRoot add -- $strMergeUnversionedRelativePath
        $strUnversionedStaleTree = ([string] (
                & git -C $strMergeFixtureRoot write-tree
            )).Trim()
        $strUnversionedStaleCommit = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strUnversionedStaleTree `
            -Parents @($strMergeBaseCommit) `
            -Timestamp ($strMergeCurrentDate + 'T00:00:45Z') `
            -Message 'stale unversioned transition'
        $strUnversionedRestoreCommit = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strMergeBaseTree `
            -Parents @($strUnversionedStaleCommit) `
            -Timestamp ($strMergeCurrentDate + 'T00:00:46Z') `
            -Message 'restore unversioned endpoint'
        $arrUnversionedRangeFailures = @(
            & $scriptBlockGetUnversionedRangeFailure `
                -Base $strMergeBaseCommit -Head $strUnversionedRestoreCommit
        )
        if (($arrUnversionedRangeFailures -join "`n") -cnotmatch
                'Last Updated must') {
            throw 'A stale change-then-restore unversioned range escaped validation.'
        }
        [IO.File]::WriteAllText(
            $strMergeUnversionedPath,
            $objUnversionedDocument.Content,
            $objUtf8WithoutBom
        )
        & git -C $strMergeFixtureRoot read-tree $strMergeBaseTree

        & git -C $strMergeFixtureRoot rm --cached --quiet -- `
            '.github/workflows/Test-AgentInstructions.ps1'
        [IO.File]::WriteAllText(
            [IO.Path]::Combine($strMergeFixtureRoot, 'AGENTS.md'),
            'pre-policy root',
            $objUtf8WithoutBom
        )
        & git -C $strMergeFixtureRoot add -- 'AGENTS.md'
        $strPrePolicyRootTree = (& git -C $strMergeFixtureRoot write-tree).Trim()
        $strPrePolicyRootCommit = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strPrePolicyRootTree -Parents @() `
            -Timestamp ($strMergeHistoricalDate + 'T01:00:00Z') `
            -Message 'pre-policy root'
        [IO.File]::WriteAllText(
            [IO.Path]::Combine($strMergeFixtureRoot, 'AGENTS.md'),
            'changed pre-policy side',
            $objUtf8WithoutBom
        )
        & git -C $strMergeFixtureRoot add -- 'AGENTS.md'
        $strPrePolicySideTree = (& git -C $strMergeFixtureRoot write-tree).Trim()
        $strPrePolicySideCommit = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strPrePolicySideTree -Parents @($strPrePolicyRootCommit) `
            -Timestamp ($strMergeHistoricalDate + 'T02:00:00Z') `
            -Message 'pre-policy side'
        $strSideAdoptsPolicy = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strMergeBaseTree -Parents @($strPrePolicySideCommit) `
            -Timestamp ($strMergeHistoricalDate + 'T02:30:00Z') `
            -Message 'side adopts policy'
        if (@(& $scriptBlockGetMergeRangeFailure -Base $strPrePolicySideCommit `
                -Head $strSideAdoptsPolicy).Count -ne 0) {
            throw 'A side branch could not adopt the policy.'
        }
        $strPolicyBaseCommit = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strMergeBaseTree -Parents @($strPrePolicyRootCommit) `
            -Timestamp ($strMergeHistoricalDate + 'T03:00:00Z') `
            -Message 'policy introduction'
        $strPolicyMergeCommit = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strMergeBaseTree `
            -Parents @($strPolicyBaseCommit, $strPrePolicySideCommit) `
            -Timestamp ($strMergeHistoricalDate + 'T04:00:00Z') `
            -Message 'compliant pre-policy merge'
        $arrPrePolicyMergeFailures = @(& $scriptBlockGetMergeRangeFailure `
                -Base $strPolicyBaseCommit -Head $strPolicyMergeCommit)
        if ($arrPrePolicyMergeFailures.Count -ne 0) {
            throw 'A compliant merge of a pre-policy side branch failed.'
        }
        & git -C $strMergeFixtureRoot read-tree $strPrePolicySideTree
        $strPolicyBlob = (& git -C $strMergeFixtureRoot rev-parse `
                "$strMergeBaseTree`:.github/workflows/Test-AgentInstructions.ps1").Trim()
        & git -C $strMergeFixtureRoot update-index --add --cacheinfo `
            "100644,$strPolicyBlob,.github/workflows/Test-AgentInstructions.ps1"
        $strImportedTree = (& git -C $strMergeFixtureRoot write-tree).Trim()
        $strImportedMerge = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strImportedTree `
            -Parents @($strPolicyBaseCommit, $strPrePolicySideCommit) `
            -Timestamp ($strMergeHistoricalDate + 'T05:00:00Z') `
            -Message 'noncompliant side import'
        $arrImportedFailures = @(& $scriptBlockGetMergeRangeFailure `
                -Base $strPolicyBaseCommit -Head $strImportedMerge)
        if ($arrImportedFailures.Count -eq 0) {
            throw 'A marker-bearing merge imported noncompliant side content.'
        }
        & git -C $strMergeFixtureRoot read-tree $strMergeBaseTree
        $strMergeTopicVersion = '**Version:** ' +
            $objAgentsVersionMatch.Groups['Prefix'].Value +
            $strMergeHistoricalDate.Replace('-', '') + '.1'
        $strMergeTopicContent = $strMergeBaseContent.Replace(
            $strMergeBaseVersion,
            $strMergeTopicVersion
        ) + [Environment]::NewLine + 'Inherited merge fixture.' +
            [Environment]::NewLine
        [IO.File]::WriteAllText(
            [IO.Path]::Combine($strMergeFixtureRoot, 'AGENTS.md'),
            $strMergeTopicContent,
            $objUtf8WithoutBom
        )
        & git -C $strMergeFixtureRoot add -- 'AGENTS.md'
        $strMergeTopicTree = ([string] (& git -C $strMergeFixtureRoot write-tree)).Trim()
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not create the inherited merge-transition tree.'
        }
        $strMergeTopicCommit = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strMergeTopicTree `
            -Parents @($strMergeBaseCommit) `
            -Timestamp ($strMergeHistoricalDate + 'T12:00:00Z') `
            -Message 'merge fixture topic'
        & git -C $strMergeFixtureRoot read-tree $strMergeBaseTree
        $strAdvancedBaseContent = $strMergeBaseContent +
            [Environment]::NewLine + 'Base-only governed fixture.' +
            [Environment]::NewLine
        [IO.File]::WriteAllText(
            [IO.Path]::Combine($strMergeFixtureRoot, 'AGENTS.md'),
            $strAdvancedBaseContent,
            $objUtf8WithoutBom
        )
        & git -C $strMergeFixtureRoot add -- 'AGENTS.md'
        $strAdvancedBaseTree = ([string](& git -C $strMergeFixtureRoot write-tree)).Trim()
        $strAdvancedBaseCommit = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strAdvancedBaseTree `
            -Parents @($strMergeBaseCommit) `
            -Timestamp ($strMergeCurrentDate + 'T00:00:00Z') `
            -Message 'merge fixture advanced base'
        $strAdvancedBaseDescendant = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strAdvancedBaseTree `
            -Parents @($strAdvancedBaseCommit) `
            -Timestamp ($strMergeCurrentDate + 'T00:00:01Z') `
            -Message 'merge fixture unchanged advanced-base descendant'
        & git -C $strMergeFixtureRoot read-tree $strMergeBaseTree
        $strBaseOnlyTrustBlob = [string] (
            'base-only trust-root fixture' |
                & git -C $strMergeFixtureRoot hash-object -w --stdin
        )
        & git -C $strMergeFixtureRoot update-index --add --cacheinfo `
            "100644,$($strBaseOnlyTrustBlob.Trim()),.gitattributes"
        $strAdvancedTrustBaseTree = ([string] (
                & git -C $strMergeFixtureRoot write-tree
            )).Trim()
        $strAdvancedTrustBaseCommit = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strAdvancedTrustBaseTree `
            -Parents @($strMergeBaseCommit) `
            -Timestamp ($strMergeCurrentDate + 'T00:00:05Z') `
            -Message 'merge fixture advanced trust base'
        & git -C $strMergeFixtureRoot read-tree $strMergeTopicTree
        & git -C $strMergeFixtureRoot update-index --add --cacheinfo `
            "100644,$($strBaseOnlyTrustBlob.Trim()),.gitattributes"
        $strTopicTrustTree = ([string] (
                & git -C $strMergeFixtureRoot write-tree
            )).Trim()
        $strTopicTrustCommit = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strTopicTrustTree `
            -Parents @($strMergeTopicCommit) `
            -Timestamp ($strMergeCurrentDate + 'T00:00:10Z') `
            -Message 'merge fixture topic trust-root change'
        & git -C $strMergeFixtureRoot read-tree $strMergeTopicTree
        $strSynchronizedTopicCommit = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strMergeTopicTree `
            -Parents @($strMergeTopicCommit) `
            -Timestamp ($strMergeCurrentDate + 'T00:00:30Z') `
            -Message 'merge fixture synchronized topic'
        $arrDirectStaleFailures = @(
            & $scriptBlockGetDirectFailure $strAdvancedBaseCommit
        )
        if (($arrDirectStaleFailures -join "`n") -cnotmatch
                "Last Updated must be $strMergeCurrentDate") {
            throw 'A non-distinct governed change escaped commit-date freshness.'
        }
        $arrNonDistinctRangeFailures = @(& $scriptBlockGetMergeRangeFailure `
                -Base $strMergeBaseCommit -Head $strAdvancedBaseDescendant `
                -RequireCommitDate $true)
        if (($arrNonDistinctRangeFailures -join "`n") -cnotmatch
                "Last Updated must be $strMergeCurrentDate") {
            throw 'An earlier non-distinct range transition escaped commit-date freshness.'
        }
        foreach ($objDirectPassingFixture in @(
                [pscustomobject]@{ Commit = $strMergeTopicCommit; Name = 'matching metadata' },
                [pscustomobject]@{ Commit = $strSynchronizedTopicCommit; Name = 'unchanged head' }
            )) {
            if (@(& $scriptBlockGetDirectFailure $objDirectPassingFixture.Commit).Count -ne 0) {
                throw "A non-distinct $($objDirectPassingFixture.Name) fixture failed."
            }
        }
        foreach ($strHistoryOnlyAction in @('opened', 'reopened')) {
            $objHistoryOnlyContext = Get-MetadataEventRevisionContext `
                -RepositoryRootPath $strMergeFixtureRoot `
                -EventName 'pull_request_target' `
                -PullRequestAction $strHistoryOnlyAction `
                -BaseRevision $strAdvancedBaseCommit `
                -HeadRevision $strSynchronizedTopicCommit `
                -IsNewRefRange $false -PreviousHeadRevision '' `
                -EventHeadRevision '' -EventHeadDistinct ''
            if ($objHistoryOnlyContext.HistoryBaseRevision -cne $strMergeBaseCommit -or
                $objHistoryOnlyContext.FreshnessBaseRevision -cne $strMergeBaseCommit) {
                throw "$strHistoryOnlyAction did not use its bounded merge base."
            }
            $arrInitialFreshnessFailures = @(& $scriptBlockGetMergeRangeFailure `
                    -Base $objHistoryOnlyContext.HistoryBaseRevision `
                    -Head $strSynchronizedTopicCommit -RequireCommitDate $true)
            if ($arrInitialFreshnessFailures.Count -ne 0) {
                throw "$strHistoryOnlyAction rejected correctly dated commit metadata."
            }
        }
        $objEditedContext = Get-MetadataEventRevisionContext `
            -RepositoryRootPath $strMergeFixtureRoot `
            -EventName 'pull_request_target' -PullRequestAction 'edited' `
            -BaseRevision $strAdvancedBaseCommit `
            -HeadRevision $strSynchronizedTopicCommit `
            -IsNewRefRange $false -PreviousHeadRevision '' `
            -PullRequestBaseChanged 'true' `
            -EventHeadRevision '' -EventHeadDistinct ''
        if ($objEditedContext.HistoryBaseRevision -cne $strMergeBaseCommit -or
            $objEditedContext.FreshnessBaseRevision -cne $strMergeBaseCommit) {
            throw 'A base-changing edited event did not rebind to its merge base.'
        }
        if (@(& $scriptBlockGetMergeRangeFailure `
                -Base $objEditedContext.HistoryBaseRevision `
                -Head $strSynchronizedTopicCommit -RequireCommitDate $true).Count -ne 0) {
            throw 'A base-changing edited event rejected commit-dated metadata.'
        }
        $boolEditedWithoutProofRejected = $false
        try {
            [void](Get-MetadataEventRevisionContext `
                    -RepositoryRootPath $strMergeFixtureRoot `
                    -EventName 'pull_request_target' -PullRequestAction 'edited' `
                    -BaseRevision $strAdvancedBaseCommit `
                    -HeadRevision $strSynchronizedTopicCommit `
                    -IsNewRefRange $false -PreviousHeadRevision '' `
                    -EventHeadRevision '' -EventHeadDistinct '')
        }
        catch {
            $boolEditedWithoutProofRejected = $_.Exception.Message.Contains(
                'requires trusted base-change proof',
                [StringComparison]::Ordinal
            )
        }
        if (-not $boolEditedWithoutProofRejected) {
            throw 'An edited event without base-change proof did not fail closed.'
        }
        $boolNonEditedProofRejected = $false
        try {
            [void](Get-MetadataEventRevisionContext `
                    -RepositoryRootPath $strMergeFixtureRoot `
                    -EventName 'pull_request_target' -PullRequestAction 'opened' `
                    -BaseRevision $strAdvancedBaseCommit `
                    -HeadRevision $strSynchronizedTopicCommit `
                    -IsNewRefRange $false -PreviousHeadRevision '' `
                    -PullRequestBaseChanged 'true' `
                    -EventHeadRevision '' -EventHeadDistinct '')
        }
        catch {
            $boolNonEditedProofRejected = $_.Exception.Message.Contains(
                'Only an edited pull request event',
                [StringComparison]::Ordinal
            )
        }
        if (-not $boolNonEditedProofRejected) {
            throw 'A nonedited event accepted base-change proof.'
        }
        $objSynchronizeContext = Get-MetadataEventRevisionContext `
            -RepositoryRootPath $strMergeFixtureRoot `
            -EventName 'pull_request_target' -PullRequestAction 'synchronize' `
            -BaseRevision $strAdvancedBaseCommit `
            -HeadRevision $strSynchronizedTopicCommit `
            -IsNewRefRange $false `
            -PreviousHeadRevision $strMergeTopicCommit `
            -EventHeadRevision '' -EventHeadDistinct ''
        if ($objSynchronizeContext.HistoryBaseRevision -cne $strMergeBaseCommit -or
            $objSynchronizeContext.FreshnessBaseRevision -cne $strMergeTopicCommit) {
            throw 'Synchronize did not separate merge-base history from topic introduction.'
        }
        $objDivergentSynchronizeContext = Get-MetadataEventRevisionContext `
            -RepositoryRootPath $strMergeFixtureRoot `
            -EventName 'pull_request_target' `
            -PullRequestAction 'synchronize' `
            -BaseRevision $strAdvancedBaseCommit `
            -HeadRevision $strSynchronizedTopicCommit `
            -IsNewRefRange $false `
            -PreviousHeadRevision $strAdvancedBaseCommit `
            -EventHeadRevision '' -EventHeadDistinct ''
        if ($objDivergentSynchronizeContext.HistoryBaseRevision -cne
                $strMergeBaseCommit -or
            $objDivergentSynchronizeContext.FreshnessBaseRevision -cne
                $strAdvancedBaseCommit) {
            throw 'A divergent synchronize lost its independent comparison bases.'
        }
        $arrDivergentFreshnessFailures = @(
            Get-CurrentInputMetadataFreshnessFailure `
                -Name 'AGENTS.md' `
                -CurrentContent $strMergeTopicContent `
                -BaseContent $strMergeBaseContent `
                -TrustedEventUtcDate $strMergeCurrentDate
        )
        if ($arrDivergentFreshnessFailures.Count -ne 1) {
            throw 'A divergent governed replacement bypassed current-event freshness.'
        }

        & git -C $strMergeFixtureRoot read-tree $strAdvancedBaseTree
        $strRebasedTopicContent = $strAdvancedBaseContent.Replace(
            $strMergeBaseVersion,
            $strMergeTopicVersion
        ) +
            [Environment]::NewLine + 'Inherited merge fixture.' +
            [Environment]::NewLine
        [IO.File]::WriteAllText(
            [IO.Path]::Combine($strMergeFixtureRoot, 'AGENTS.md'),
            $strRebasedTopicContent,
            $objUtf8WithoutBom
        )
        & git -C $strMergeFixtureRoot add -- 'AGENTS.md'
        $strRebasedTopicTree = ([string](& git -C $strMergeFixtureRoot write-tree)).Trim()
        $strRebasedTopicCommit = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strRebasedTopicTree -Parents @($strAdvancedBaseCommit) `
            -Timestamp ($strMergeCurrentDate + 'T00:00:45Z') `
            -Message 'merge fixture rebased topic'
        $objRebasedSynchronizeContext = Get-MetadataEventRevisionContext `
            -RepositoryRootPath $strMergeFixtureRoot `
            -EventName 'pull_request_target' `
            -PullRequestAction 'synchronize' `
            -BaseRevision $strAdvancedBaseCommit `
            -HeadRevision $strRebasedTopicCommit `
            -IsNewRefRange $false `
            -PreviousHeadRevision $strMergeTopicCommit `
            -EventHeadRevision '' -EventHeadDistinct ''
        if ($objRebasedSynchronizeContext.HistoryBaseRevision -cne
                $strAdvancedBaseCommit -or
            $objRebasedSynchronizeContext.FreshnessBaseRevision -cne
                $strMergeTopicCommit) {
            throw 'A rebased topic did not retain authenticated topic delta context.'
        }
        if (-not (Test-TopicOwnedGitPathDeltaEqual `
                    -RepositoryRootPath $strMergeFixtureRoot `
                    -PreviousBaseRevision $objRebasedSynchronizeContext.PreviousTopicBaseRevision `
                    -PreviousHeadRevision $objRebasedSynchronizeContext.PreviousTopicHeadRevision `
                    -CurrentBaseRevision $objRebasedSynchronizeContext.CurrentTopicBaseRevision `
                    -CurrentHeadRevision $objRebasedSynchronizeContext.CurrentTopicHeadRevision `
                    -RepositoryRelativePath 'AGENTS.md')) {
            throw 'A base-only governed rebase was falsely attributed to the topic.'
        }
        $strChangedRebasedTopicContent = $strRebasedTopicContent.Replace(
            $strMergeHistoricalDate.Replace('-', '') + '.1',
            $strMergeHistoricalDate.Replace('-', '') + '.2'
        )
        [IO.File]::WriteAllText(
            [IO.Path]::Combine($strMergeFixtureRoot, 'AGENTS.md'),
            $strChangedRebasedTopicContent,
            $objUtf8WithoutBom
        )
        & git -C $strMergeFixtureRoot add -- 'AGENTS.md'
        $strChangedRebasedTopicTree = ([string](
                & git -C $strMergeFixtureRoot write-tree
            )).Trim()
        $strChangedRebasedTopicCommit = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strChangedRebasedTopicTree -Parents @($strAdvancedBaseCommit) `
            -Timestamp ($strMergeCurrentDate + 'T00:00:50Z') `
            -Message 'merge fixture changed rebased topic'
        if (Test-TopicOwnedGitPathDeltaEqual `
                -RepositoryRootPath $strMergeFixtureRoot `
                -PreviousBaseRevision $objRebasedSynchronizeContext.PreviousTopicBaseRevision `
                -PreviousHeadRevision $objRebasedSynchronizeContext.PreviousTopicHeadRevision `
                -CurrentBaseRevision $strAdvancedBaseCommit `
                -CurrentHeadRevision $strChangedRebasedTopicCommit `
                -RepositoryRelativePath 'AGENTS.md') {
            throw 'An actual rebased topic delta change was ignored.'
        }
        & git -C $strMergeFixtureRoot read-tree $strRebasedTopicTree
        [IO.File]::WriteAllText(
            [IO.Path]::Combine($strMergeFixtureRoot, 'AGENTS.md'),
            $strRebasedTopicContent,
            $objUtf8WithoutBom
        )

        $boolMissingPreviousHeadRejected = $false
        try {
            [void](Get-MetadataEventRevisionContext `
                    -RepositoryRootPath $strMergeFixtureRoot `
                    -EventName 'pull_request_target' `
                    -PullRequestAction 'synchronize' `
                    -BaseRevision $strAdvancedBaseCommit `
                    -HeadRevision $strRebasedTopicCommit `
                    -IsNewRefRange $false `
                    -PreviousHeadRevision ('f' * 40) `
                    -EventHeadRevision '' -EventHeadDistinct '')
        }
        catch {
            $boolMissingPreviousHeadRejected = $_.Exception.Message.Contains(
                'previous topic head is unavailable',
                [StringComparison]::Ordinal
            )
        }
        if (-not $boolMissingPreviousHeadRejected) {
            throw 'An unavailable synchronize previous head did not fail closed.'
        }
        $boolSamePreviousHeadRejected = $false
        try {
            [void](Get-MetadataEventRevisionContext `
                    -RepositoryRootPath $strMergeFixtureRoot `
                    -EventName 'pull_request_target' `
                    -PullRequestAction 'synchronize' `
                    -BaseRevision $strAdvancedBaseCommit `
                    -HeadRevision $strRebasedTopicCommit `
                    -IsNewRefRange $false `
                    -PreviousHeadRevision $strRebasedTopicCommit `
                    -EventHeadRevision '' -EventHeadDistinct '')
        }
        catch {
            $boolSamePreviousHeadRejected = $_.Exception.Message.Contains(
                'distinct valid previous topic head',
                [StringComparison]::Ordinal
            )
        }
        if (-not $boolSamePreviousHeadRejected) {
            throw 'A synchronize event accepted the new head as its previous head.'
        }
        foreach ($strHistoryOnlyAction in @('opened', 'reopened')) {
            $boolUnexpectedPreviousHeadRejected = $false
            try {
                [void](Get-MetadataEventRevisionContext `
                        -RepositoryRootPath $strMergeFixtureRoot `
                        -EventName 'pull_request_target' `
                        -PullRequestAction $strHistoryOnlyAction `
                        -BaseRevision $strAdvancedBaseCommit `
                        -HeadRevision $strRebasedTopicCommit `
                        -IsNewRefRange $false `
                        -PreviousHeadRevision $strMergeTopicCommit `
                        -EventHeadRevision '' -EventHeadDistinct '')
            }
            catch {
                $boolUnexpectedPreviousHeadRejected = $_.Exception.Message.Contains(
                    'must not supply a previous head',
                    [StringComparison]::Ordinal
                )
            }
            if (-not $boolUnexpectedPreviousHeadRejected) {
                throw "$strHistoryOnlyAction accepted a previous-head field."
            }
        }
        $arrAdvancedBaseHistoryFailures = @(& $scriptBlockGetMergeRangeFailure `
                -Base $objSynchronizeContext.HistoryBaseRevision `
                -Head $strSynchronizedTopicCommit)
        if ($arrAdvancedBaseHistoryFailures.Count -ne 0) {
            throw 'Merge-base history validation rejected an advanced-base topic.'
        }
        $arrAdvancedBaseTrustFailures = @(Get-TrustRootRangeMutationFailure `
                -RepositoryRootPath $strMergeFixtureRoot `
                -BaseRevision $strMergeBaseCommit `
                -HeadRevision $strSynchronizedTopicCommit `
                -RepositoryRelativePath $script:arrTrustRootPaths)
        if ($arrAdvancedBaseTrustFailures.Count -ne 0) {
            throw 'A base-only trust-root change was attributed to the topic.'
        }
        $arrBaseTipTrustFailures = @(Get-TrustRootRangeMutationFailure `
                -RepositoryRootPath $strMergeFixtureRoot `
                -BaseRevision $strAdvancedTrustBaseCommit `
                -HeadRevision $strSynchronizedTopicCommit `
                -RepositoryRelativePath $script:arrTrustRootPaths)
        if ($arrBaseTipTrustFailures.Count -ne 1) {
            throw 'The advanced-base trust-root reproduction did not distinguish the base tip.'
        }
        $arrTopicTrustFailures = @(Get-TrustRootRangeMutationFailure `
                -RepositoryRootPath $strMergeFixtureRoot `
                -BaseRevision $strMergeBaseCommit `
                -HeadRevision $strTopicTrustCommit `
                -RepositoryRelativePath $script:arrTrustRootPaths)
        if ($arrTopicTrustFailures.Count -ne 1 -or
            -not ($arrTopicTrustFailures -match [regex]::Escape('.gitattributes'))) {
            throw 'A topic trust-root change did not fail closed.'
        }
        $strCrissCrossLeft = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strMergeBaseTree -Parents @($strMergeBaseCommit) `
            -Timestamp ($strMergeHistoricalDate + 'T13:00:00Z') `
            -Message 'criss-cross left'
        $strCrissCrossRight = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strMergeBaseTree -Parents @($strMergeBaseCommit) `
            -Timestamp ($strMergeHistoricalDate + 'T13:01:00Z') `
            -Message 'criss-cross right'
        $strCrissCrossMergeLeft = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strMergeBaseTree `
            -Parents @($strCrissCrossLeft, $strCrissCrossRight) `
            -Timestamp ($strMergeHistoricalDate + 'T13:02:00Z') `
            -Message 'criss-cross merge left'
        $strCrissCrossMergeRight = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strMergeBaseTree `
            -Parents @($strCrissCrossRight, $strCrissCrossLeft) `
            -Timestamp ($strMergeHistoricalDate + 'T13:03:00Z') `
            -Message 'criss-cross merge right'
        $boolMultipleMergeBasesRejected = $false
        try {
            [void](Get-MetadataEventRevisionContext `
                    -RepositoryRootPath $strMergeFixtureRoot `
                    -EventName 'pull_request_target' `
                    -PullRequestAction 'opened' `
                    -BaseRevision $strCrissCrossMergeLeft `
                    -HeadRevision $strCrissCrossMergeRight `
                    -IsNewRefRange $false -PreviousHeadRevision '' `
                    -EventHeadRevision '' -EventHeadDistinct '')
        }
        catch {
            $boolMultipleMergeBasesRejected = $_.Exception.Message.Contains(
                'must have one available merge base',
                [StringComparison]::Ordinal
            )
        }
        if (-not $boolMultipleMergeBasesRejected) {
            throw 'A pull request with multiple merge bases did not fail closed.'
        }
        $strInheritedMergeCommit = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strMergeTopicTree `
            -Parents @($strAdvancedBaseCommit, $strMergeTopicCommit) `
            -Timestamp ($strMergeCurrentDate + 'T00:01:00Z') `
            -Message 'merge fixture inherited result'
        $arrInheritedMergeFailures = @(& $scriptBlockGetMergeRangeFailure `
                -Base $strAdvancedBaseCommit -Head $strInheritedMergeCommit)
        if ($arrInheritedMergeFailures.Count -ne 0) {
            throw (
                'A merge that inherited governed content from its non-first parent failed: ' +
                ($arrInheritedMergeFailures -join '; ')
            )
        }
        $strFutureTopicCommit = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strMergeTopicTree `
            -Parents @($strMergeBaseCommit) `
            -Timestamp '2099-12-31T12:00:00Z' `
            -Message 'merge fixture future topic'
        $arrFutureTopicFailures = @(& $scriptBlockGetMergeRangeFailure `
                -Base $strMergeBaseCommit -Head $strFutureTopicCommit)
        if (-not ($arrFutureTopicFailures -join '; ').Contains(
                "Metadata range commit $strFutureTopicCommit timestamp",
                [StringComparison]::Ordinal
            )) {
            throw 'An ordinary future commit timestamp did not fail closed.'
        }
        $strUniqueMergeContent = $strMergeTopicContent.Replace(
            $strMergeHistoricalDate.Replace('-', '') + '.1',
            $strMergeHistoricalDate.Replace('-', '') + '.2'
        ) +
            [Environment]::NewLine + 'Merge-authored content with stale metadata.'
        [IO.File]::WriteAllText(
            [IO.Path]::Combine($strMergeFixtureRoot, 'AGENTS.md'),
            $strUniqueMergeContent,
            $objUtf8WithoutBom
        )
        & git -C $strMergeFixtureRoot add -- 'AGENTS.md'
        $strUniqueMergeTree = ([string] (& git -C $strMergeFixtureRoot write-tree)).Trim()
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not create the unique merge-transition tree.'
        }
        $strUniqueMergeCommit = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strUniqueMergeTree `
            -Parents @($strAdvancedBaseCommit, $strMergeTopicCommit) `
            -Timestamp ($strMergeCurrentDate + 'T00:02:00Z') `
            -Message 'merge fixture unique result'
        $arrUniqueMergeFailures = @(& $scriptBlockGetMergeRangeFailure `
                -Base $strAdvancedBaseCommit -Head $strUniqueMergeCommit)
        if ($arrUniqueMergeFailures.Count -ne 0) {
            throw 'Historical range validation conflated commit time with current freshness.'
        }
        $arrUniqueFreshnessFailures = @(Get-CurrentInputMetadataFreshnessFailure `
                -Name 'AGENTS.md' `
                -CurrentContent $strUniqueMergeContent `
                -BaseContent $strMergeBaseContent `
                -TrustedEventUtcDate $strMergeCurrentDate)
        if (-not ($arrUniqueFreshnessFailures -join '; ').Contains(
                "Last Updated must be $strMergeCurrentDate",
                [StringComparison]::Ordinal
            )) {
            throw 'Trusted current-input freshness accepted stale merge metadata.'
        }

        $strNewerParentContent = $strAgentsContent +
            [Environment]::NewLine + 'Newer first-parent merge fixture.'
        [IO.File]::WriteAllText(
            [IO.Path]::Combine($strMergeFixtureRoot, 'AGENTS.md'),
            $strNewerParentContent,
            $objUtf8WithoutBom
        )
        & git -C $strMergeFixtureRoot add -- 'AGENTS.md'
        $strNewerParentTree = ([string] (& git -C $strMergeFixtureRoot write-tree)).Trim()
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not create the newer merge-parent tree.'
        }
        $strNewerParentCommit = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strNewerParentTree `
            -Parents @($strMergeBaseCommit) `
            -Timestamp ($strMergeCurrentDate + 'T00:03:00Z') `
            -Message 'merge fixture newer parent'
        $strRegressingMergeCommit = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strMergeTopicTree `
            -Parents @($strNewerParentCommit, $strMergeTopicCommit) `
            -Timestamp ($strMergeCurrentDate + 'T00:04:00Z') `
            -Message 'merge fixture regressing inherited result'
        $arrRegressingMergeFailures = @(& $scriptBlockGetMergeRangeFailure `
                -Base $strNewerParentCommit -Head $strRegressingMergeCommit)
        if ($arrRegressingMergeFailures.Count -eq 0 -or
            -not ($arrRegressingMergeFailures -join '; ').Contains(
                'Version date must not move backward',
                [StringComparison]::Ordinal
            )) {
            throw 'An inherited merge metadata rollback did not fail closed.'
        }
        $strBackwardBaseCommit = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strNewerParentTree -Parents @($strRegressingMergeCommit) `
            -Timestamp ($strMergeCurrentDate + 'T00:05:00Z') `
            -Message 'backward push base fixture'
        $arrBackwardRangeCommits = @(& git -C $strMergeFixtureRoot rev-list `
                "$strBackwardBaseCommit..$strRegressingMergeCommit")
        $arrBackwardEndpointPaths = @(& git -C $strMergeFixtureRoot diff `
                --name-only $strBackwardBaseCommit $strRegressingMergeCommit --)
        $arrBackwardHeadFailures = @(Get-GovernedDocumentCommitTransitionFailure `
                -Name 'AGENTS.md' -RepositoryRootPath $strMergeFixtureRoot `
                -RepositoryRelativePath 'AGENTS.md' `
                -MaximumBytes $intAgentsMaximumInputBytes `
                -CommitRevision $strRegressingMergeCommit `
                -PolicyRepositoryRelativePath '.github/workflows/Test-AgentInstructions.ps1' `
                -PolicyMaximumBytes 1024 -PolicyMarker $strMetadataRangePolicyMarker `
                -RequireExpectedUtcDateForRenderedChange $true)
        if ($arrBackwardRangeCommits.Count -ne 0 -or
            $arrBackwardEndpointPaths.Count -ne 1 -or
            $arrBackwardEndpointPaths[0] -cne 'AGENTS.md' -or
            -not (Test-BackwardCommitMove -RepositoryRootPath $strMergeFixtureRoot `
                    -BaseRevision $strBackwardBaseCommit `
                    -HeadRevision $strRegressingMergeCommit) -or
            (Test-BackwardCommitMove -RepositoryRootPath $strMergeFixtureRoot `
                    -BaseRevision $strRegressingMergeCommit `
                    -HeadRevision $strBackwardBaseCommit) -or
            -not ($arrBackwardHeadFailures -join '; ').Contains(
                'Version date must not move backward',
                [StringComparison]::Ordinal
            )) {
            throw 'A reused backward target did not receive exact direct transition validation.'
        }
        $listExcessParents = [Collections.Generic.List[string]]::new()
        foreach ($intFixtureParent in 1..($intMetadataMaximumParents + 1)) {
            $listExcessParents.Add((& $scriptBlockCreateMergeFixtureCommit `
                        -Tree $strMergeBaseTree `
                        -Parents @($strMergeBaseCommit) `
                        -Timestamp ($strMergeHistoricalDate + 'T12:00:00Z') `
                        -Message "merge fixture excess parent $intFixtureParent"))
        }
        $strExcessParentMerge = & $scriptBlockCreateMergeFixtureCommit `
            -Tree $strMergeBaseTree `
            -Parents $listExcessParents.ToArray() `
            -Timestamp ($strMergeCurrentDate + 'T12:00:00Z') `
            -Message 'merge fixture excessive parent count'
        $boolExcessParentCountRejected = $false
        try {
            [void](& $scriptBlockGetMergeRangeFailure `
                    -Base $strMergeBaseCommit -Head $strExcessParentMerge)
        }
        catch {
            $boolExcessParentCountRejected = $_.Exception.Message.Contains(
                "maximum is $intMetadataMaximumParents",
                [StringComparison]::Ordinal
            )
        }
        if (-not $boolExcessParentCountRejected) {
            throw 'An excessive metadata merge-parent count did not fail closed.'
        }
    }
    finally {
        if ($boolHadAuthorDate) {
            $env:GIT_AUTHOR_DATE = $strOriginalAuthorDate
        }
        else {
            Remove-Item -LiteralPath Env:GIT_AUTHOR_DATE -ErrorAction SilentlyContinue
        }
        if ($boolHadCommitterDate) {
            $env:GIT_COMMITTER_DATE = $strOriginalCommitterDate
        }
        else {
            Remove-Item -LiteralPath Env:GIT_COMMITTER_DATE -ErrorAction SilentlyContinue
        }
        if ([System.IO.Directory]::Exists($strMergeFixtureRoot) -and
            $strMergeFixtureRoot.StartsWith(
                $strSystemTempRoot,
                [StringComparison]::OrdinalIgnoreCase
            )) {
            Remove-Item -LiteralPath $strMergeFixtureRoot -Recurse -Force
        }
    }

    $strRevisionMismatchFixture = [string] (
        & git -C $strRepositoryRootPath rev-parse --verify HEAD^1
    )
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not resolve the revision-mismatch self-test fixture.'
    }
    $boolRevisionMismatchRejected = $false
    try {
        [void](Get-GovernedDocumentRangeTransitionFailure `
                -Name 'AGENTS.md' `
                -RepositoryRootPath $strRepositoryRootPath `
                -RepositoryRelativePath 'AGENTS.md' `
                -MaximumBytes $intAgentsMaximumInputBytes `
                -BaseRevision $strNewRefTestHead `
                -HeadRevision $strNewRefTestHead `
                -InputRevision $strRevisionMismatchFixture.Trim() `
                -IsNewRefRange $false `
                -PolicyRepositoryRelativePath '.github/workflows/Test-AgentInstructions.ps1' `
                -PolicyMaximumBytes $intValidatorMaximumInputBytes `
                -PolicyMarker $strMetadataRangePolicyMarker)
    }
    catch {
        $boolRevisionMismatchRejected = $_.Exception.Message.Contains(
            'does not match the validation revision',
            [StringComparison]::Ordinal
        )
    }
    if (-not $boolRevisionMismatchRejected) {
        throw 'A mismatched explicit validation revision did not fail closed.'
    }

    $strAgentWorkflowContent = [IO.File]::ReadAllText(
        [IO.Path]::Combine($PSScriptRoot, 'agent-instructions.yml')
    )
    $strValidatorSourceContent = [IO.File]::ReadAllText($PSCommandPath)
    if ($strValidatorSourceContent -notmatch
        '\(\$EventName -ceq ''push'' -and -not \$RangeIsNewRef\)' -or
        $strValidatorSourceContent -notmatch
        '\$boolCommitDateOnlyEvent = \$EventName -ceq ''pull_request_target''') {
        throw 'Commit-date range freshness selectors are incomplete.'
    }
    foreach ($objNestedLintDocumentation in @(
            [pscustomobject]@{
                Path = 'MARKDOWN-LINTING-IMPLEMENTATION.md'
                Literal = 'Scans all `.md` and `.mdc` files in the repository'
            },
            [pscustomobject]@{
                Path = 'scripts-README.md'
                Literal = 'Scans all `.md` and `.mdc` files in the repository'
            }
        )) {
        $strNestedLintDocumentation = [IO.File]::ReadAllText(
            [IO.Path]::Combine($PSScriptRoot, $objNestedLintDocumentation.Path)
        )
        if (-not $strNestedLintDocumentation.Contains(
                $objNestedLintDocumentation.Literal,
                [StringComparison]::Ordinal
            )) {
            throw "Nested Markdown scope is stale: $($objNestedLintDocumentation.Path)"
        }
    }
    $scriptBlockGetAgentWorkflowFailure = {
        param([Parameter(Mandatory)][string] $Content)

        $listFailures = [Collections.Generic.List[string]]::new()
        if ($Content -notmatch
            "(?s)AGENT_INSTRUCTION_INPUT_REVISION:.+github.event_name == 'push' && github.event.after") {
            $listFailures.Add('Push input must use the exact event after revision.')
        }
        foreach ($strRequiredLiteral in @(
                'id: push-applicability',
                '-PushApplicabilityOnly',
                'PUSH_BEFORE_SHA: ${{ github.event.before }}',
                'PUSH_AFTER_SHA: ${{ github.event.after }}',
                'PUSH_CREATED: ${{ github.event.created }}',
                'PUSH_DELETED: ${{ github.event.deleted }}',
                'refs/remotes/event/push-base',
                'refs/remotes/event/pr-head',
                'refs/remotes/event/pr-previous-head',
                '      - edited',
                "github.event.action != 'edited' ||",
                "github.event.changes.base.ref.from != ''",
                'AGENT_INSTRUCTION_PULL_REQUEST_BASE_CHANGED:',
                '-PullRequestBaseChanged $env:AGENT_INSTRUCTION_PULL_REQUEST_BASE_CHANGED',
                'test "${fetched_base}" = "${PUSH_BASE_SHA}"',
                'test "${fetched_head}" = "${PR_HEAD_SHA}"',
                'test "${fetched_previous_head}" = "${PR_PREVIOUS_HEAD_SHA}"',
                'github.event.action == ''synchronize'' && github.event.before',
                'AGENT_INSTRUCTION_EVENT_HEAD_REVISION:',
                'github.event.head_commit.id',
                'AGENT_INSTRUCTION_EVENT_HEAD_DISTINCT:',
                'toJSON(github.event.head_commit.distinct)',
                '-EventHeadRevision $env:AGENT_INSTRUCTION_EVENT_HEAD_REVISION',
                '-EventHeadDistinct $env:AGENT_INSTRUCTION_EVENT_HEAD_DISTINCT',
                'github.event.size',
                'toJSON(github.event.commits.*.id)',
                '-NewRefCommitCount $env:AGENT_INSTRUCTION_NEW_REF_COMMIT_COUNT',
                '-NewRefCommitEvidenceJson $env:AGENT_INSTRUCTION_NEW_REF_COMMITS_JSON',
                'persist-credentials: false',
                'ref: ${{ github.sha }}'
            )) {
            if (-not $Content.Contains(
                    $strRequiredLiteral,
                    [StringComparison]::Ordinal
                )) {
                $listFailures.Add(
                    "Workflow contract literal is missing: $strRequiredLiteral"
                )
            }
        }
        if ($Content -cmatch '(?m)(^|\s)--force(\s|$)' -or
            $Content -cmatch '"\+[^" ]+:') {
            $listFailures.Add('Event-data fetches must not force a destination ref.')
        }
        if ($Content -cmatch
            '(?s)AGENT_INSTRUCTION_EVENT_HEAD_REVISION:.{0,300}github\.event\.commits\.\*\.id') {
            $listFailures.Add(
                'The bounded push commits array must not decide head introduction.'
            )
        }
        if ($Content.Contains(
                'github.event.pull_request.updated_at',
                [StringComparison]::Ordinal
            )) {
            $listFailures.Add(
                'Pull request metadata freshness must use commit dates.'
            )
        }
        $intExpensiveGateCount = [regex]::Matches(
            $Content,
            "steps\.push-applicability\.outputs\.required == 'true'"
        ).Count
        if ($intExpensiveGateCount -ne 5) {
            $listFailures.Add(
                'All five expensive validation steps require the applicability gate.'
            )
        }

        foreach ($strTrigger in @('push', 'pull_request_target')) {
            $objTriggerMatch = [regex]::Match(
                $Content,
                "(?ms)^  $strTrigger`:\r?\n(?<Body>.*?)(?=^(?:\S| {2}\S)|\z)"
            )
            if (-not $objTriggerMatch.Success) {
                $listFailures.Add("Could not parse the $strTrigger trigger.")
                continue
            }
            $strTriggerBody = $objTriggerMatch.Groups['Body'].Value
            if ($strTriggerBody -cmatch '(?m)^    paths(?:-ignore)?:') {
                $listFailures.Add(
                    "$strTrigger must not use a paths or paths-ignore filter."
                )
            }
            if ($strTrigger -ceq 'push') {
                $objBranchFilterMatch = [regex]::Match(
                    $strTriggerBody,
                    '(?ms)^    branches:\r?\n' +
                        '(?<Branches>(?:      - [^\r\n]+\r?\n)+)'
                )
                if (-not $objBranchFilterMatch.Success -or
                    $objBranchFilterMatch.Groups['Branches'].Value -cnotmatch
                        '^      - "\*\*"\r?\n$' -or
                    $strTriggerBody -cmatch '(?m)^    tags(?:-ignore)?:') {
                    $listFailures.Add(
                        'Push must cover all branches and exclude tag events.'
                    )
                }
            }
        }
        return $listFailures.ToArray()
    }

    $arrAgentWorkflowFailures = @(
        & $scriptBlockGetAgentWorkflowFailure -Content $strAgentWorkflowContent
    )
    if ($arrAgentWorkflowFailures.Count -ne 0) {
        throw (
            'Agent workflow contract failed: ' +
            ($arrAgentWorkflowFailures -join '; ')
        )
    }
    $arrWorkflowMutations = @(
        [pscustomobject]@{
            Name = 'push path filter'
            Content = $strAgentWorkflowContent.Replace(
                '      - "**"',
                "      - `"**`"`n    paths:`n      - AGENTS.md"
            )
            Expected = 'push must not use a paths or paths-ignore filter.'
        },
        [pscustomobject]@{
            Name = 'forcing previous-head fetch'
            Content = $strAgentWorkflowContent.Replace(
                '"${PR_PREVIOUS_HEAD_SHA}:refs/remotes/event/pr-previous-head"',
                '"+${PR_PREVIOUS_HEAD_SHA}:refs/remotes/event/pr-previous-head"'
            )
            Expected = 'Event-data fetches must not force a destination ref.'
        },
        [pscustomobject]@{
            Name = 'missing previous-head identity proof'
            Content = $strAgentWorkflowContent.Replace(
                'test "${fetched_previous_head}" = "${PR_PREVIOUS_HEAD_SHA}"',
                'test -n "${fetched_previous_head}"'
            )
            Expected = 'Workflow contract literal is missing: test'
        },
        [pscustomobject]@{
            Name = 'persisted checkout credential'
            Content = $strAgentWorkflowContent.Replace(
                'persist-credentials: false',
                'persist-credentials: true'
            )
            Expected = 'Workflow contract literal is missing: persist-credentials: false'
        },
        [pscustomobject]@{
            Name = 'bounded push commit-list head evidence'
            Content = $strAgentWorkflowContent.Replace(
                'github.event.head_commit.id',
                'github.event.commits.*.id'
            )
            Expected = 'The bounded push commits array must not decide head introduction.'
        },
        [pscustomobject]@{
            Name = 'ungated expensive steps'
            Content = $strAgentWorkflowContent.Replace(
                "steps.push-applicability.outputs.required == 'true'",
                "steps.push-applicability.outputs.required != 'false'"
            )
            Expected = 'All five expensive validation steps require the applicability gate.'
        },
        [pscustomobject]@{
            Name = 'missing edited trigger'
            Content = $strAgentWorkflowContent.Replace(
                "      - synchronize`n      - edited",
                '      - synchronize'
            )
            Expected = 'Workflow contract literal is missing:       - edited'
        },
        [pscustomobject]@{
            Name = 'missing non-base edited job gate'
            Content = $strAgentWorkflowContent.Replace(
                "github.event.action != 'edited' ||",
                "github.event.action == 'edited' ||"
            )
            Expected = "Workflow contract literal is missing: github.event.action != 'edited' ||"
        },
        [pscustomobject]@{
            Name = 'missing edited base-change proof plumbing'
            Content = $strAgentWorkflowContent.Replace(
                '-PullRequestBaseChanged $env:AGENT_INSTRUCTION_PULL_REQUEST_BASE_CHANGED',
                '-PullRequestBaseChanged true'
            )
            Expected = 'Workflow contract literal is missing: -PullRequestBaseChanged'
        },
        [pscustomobject]@{
            Name = 'mutable pull request activity timestamp'
            Content = $strAgentWorkflowContent -replace (
                "github.event_name == 'push' &&\r?\n\s+" +
                'github.event.repository.pushed_at'
            ),
                'github.event.pull_request.updated_at'
            Expected = 'Pull request metadata freshness must use commit dates.'
        }
    )
    foreach ($objWorkflowMutation in $arrWorkflowMutations) {
        if ([string]::Equals(
                $objWorkflowMutation.Content,
                $strAgentWorkflowContent,
                [StringComparison]::Ordinal
            )) {
            throw "Workflow mutation changed zero bytes: $($objWorkflowMutation.Name)"
        }
        $arrMutationFailures = @(& $scriptBlockGetAgentWorkflowFailure `
                -Content $objWorkflowMutation.Content)
        if ($arrMutationFailures.Count -eq 0 -or
            -not ($arrMutationFailures -join '; ').Contains(
                $objWorkflowMutation.Expected,
                [StringComparison]::Ordinal
            )) {
            throw "Workflow mutation passed: $($objWorkflowMutation.Name)"
        }
    }

    $arrUnchangedFailures = @(Get-TrustRootRangeMutationFailure `
            -RepositoryRootPath $strRepositoryRootPath `
            -BaseRevision $strNewRefTestHead `
            -HeadRevision $strNewRefTestHead `
            -RepositoryRelativePath $script:arrTrustRootPaths)
    if ($arrUnchangedFailures.Count -ne 0) {
        throw 'An unchanged trusted validation range did not pass.'
    }
    $strTrustRootBase = [string] (
        & git -C $strRepositoryRootPath rev-list --max-parents=0 HEAD |
            Select-Object -First 1
    )
    $arrTrustRootFailures = @(Get-TrustRootRangeMutationFailure `
            -RepositoryRootPath $strRepositoryRootPath `
            -BaseRevision $strTrustRootBase.Trim() `
            -HeadRevision $strNewRefTestHead `
            -RepositoryRelativePath $script:arrTrustRootPaths)
    if ($LASTEXITCODE -ne 0) {
        throw 'The trusted validation mutation query leaked a nonzero native status.'
    }
    $arrHistoricallyChangedTrustPaths = @(
        & git -C $strRepositoryRootPath diff --name-only --no-renames `
            --no-ext-diff --no-textconv $strTrustRootBase.Trim() `
            $strNewRefTestHead -- $script:arrTrustRootPaths
    )
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not inventory changed historical trust roots.'
    }
    foreach ($strTrustPath in $arrHistoricallyChangedTrustPaths) {
        if (-not ($arrTrustRootFailures -match
                [regex]::Escape("changes trusted validation path $strTrustPath."))) {
            throw "A changed trusted validation path did not fail closed: $strTrustPath"
        }
    }
    if ($arrTrustRootFailures.Count -ne $arrHistoricallyChangedTrustPaths.Count) {
        throw 'The trusted validation mutation test returned an unexpected failure count.'
    }
    $arrAttributeOnlyFailures = @(Get-TrustRootRangeMutationFailure `
            -RepositoryRootPath $strRepositoryRootPath `
            -BaseRevision $strTrustRootBase.Trim() `
            -HeadRevision $strNewRefTestHead `
            -RepositoryRelativePath @('.gitattributes'))
    if ($arrAttributeOnlyFailures.Count -ne 1 -or
        -not ($arrAttributeOnlyFailures -match
            [regex]::Escape('changes trusted validation path .gitattributes.'))) {
        throw 'An attribute-only trust-root query did not fail closed.'
    }

    $strMetadataNormalizationBase = @(
        '**Version:** 1.0.20260819.3'
        '- **Last Updated:** 2026-08-19'
        'Body'
    ) -join "`n"
    $strMetadataMechanicalMutation = @(
        '**Version:** 1.0.20260819.4'
        '- **Last Updated:** 2026-08-19'
        'Body '
        ''
    ) -join "`r`n"
    $objMetadataNormalizationContext = [pscustomobject]@{
        VersionLineIndex = 0
        UpdatedLineIndex = 1
    }
    if ((ConvertTo-MetadataComparisonText -Content $strMetadataNormalizationBase `
            -MetadataContext $objMetadataNormalizationContext) -cne
        (ConvertTo-MetadataComparisonText -Content $strMetadataMechanicalMutation `
            -MetadataContext $objMetadataNormalizationContext)) {
        throw 'Metadata normalization did not exempt mechanical line-ending, EOF, and trailing-space changes.'
    }
    $strMetadataHardBreakMutation = $strMetadataNormalizationBase.Replace('Body', 'Body  ')
    if ((ConvertTo-MetadataComparisonText -Content $strMetadataNormalizationBase `
            -MetadataContext $objMetadataNormalizationContext) -ceq
        (ConvertTo-MetadataComparisonText -Content $strMetadataHardBreakMutation `
            -MetadataContext $objMetadataNormalizationContext)) {
        throw 'Metadata normalization incorrectly exempted a Markdown hard-line-break change.'
    }
    $strMetadataExampleBase = @(
        $strMetadataNormalizationBase
        '```markdown'
        '**Version:** 9.9.20260101.1'
        '- **Last Updated:** 2026-01-01'
        '```'
    ) -join "`n"
    foreach ($strMetadataExampleMutation in @(
            $strMetadataExampleBase.Replace('9.9.20260101.1', '9.9.20260101.2'),
            $strMetadataExampleBase.Replace('2026-01-01', '2026-01-02')
        )) {
        if ((ConvertTo-MetadataComparisonText -Content $strMetadataExampleBase `
                -MetadataContext $objMetadataNormalizationContext) -ceq
            (ConvertTo-MetadataComparisonText -Content $strMetadataExampleMutation `
                -MetadataContext $objMetadataNormalizationContext)) {
            throw 'Metadata normalization incorrectly exempted a fenced metadata example change.'
        }
    }

    $strAgentsStandingParagraph = [regex]::Match(
        $strAgentsContent,
        '(?m)^[^\S\r\n]+\*\*Standing placement authorization\.\*\*.*$'
    ).Value
    if ([string]::IsNullOrEmpty($strAgentsStandingParagraph)) {
        throw 'Could not locate the AGENTS standing-placement paragraph for mutation tests.'
    }

    $strAgentsPlacementHeading = '## PR Review Workflow (Codex-adapted)'
    $strRawHtmlAgentsPlacementHeading = '<div>' + [Environment]::NewLine +
        $strAgentsPlacementHeading + [Environment]::NewLine + '</div>'
    Assert-Failure `
        -AgentsContent $strAgentsContent.Replace(
            $strAgentsPlacementHeading,
            $strRawHtmlAgentsPlacementHeading
        ) `
        -Failure 'AGENTS.md must contain the standing direct-placement authorization exactly once.'

    $strClaudeLoopHeading = '## Automated Review Loop'
    $strRawHtmlClaudeLoopHeading = '<div>' + [Environment]::NewLine +
        $strClaudeLoopHeading + [Environment]::NewLine + '</div>'
    Assert-Failure `
        -ClaudeContent $strClaudeContent.Replace(
            $strClaudeLoopHeading,
            $strRawHtmlClaudeLoopHeading
        ) `
        -Failure 'CLAUDE.md must contain the standing direct-placement authorization exactly once.'

    $strRawHtmlBoundaryFixture = $strAgentsPlacementHeading +
        [Environment]::NewLine + [Environment]::NewLine + '<div>' +
        [Environment]::NewLine + '## Raw HTML Impostor Boundary' +
        [Environment]::NewLine + '</div>'
    Assert-FixtureAccepted `
        -AgentsContent $strAgentsContent.Replace(
            $strAgentsPlacementHeading,
            $strRawHtmlBoundaryFixture
        ) `
        -CodexConfigContent $strCodexConfigContent

    Assert-Failure `
        -AgentsContent ($strAgentsContent + [Environment]::NewLine +
            $strAgentsPlacementHeading) `
        -Failure 'AGENTS.md must contain the standing direct-placement authorization exactly once.'

    $strContraryPlacementRule =
        'The agent must request a new owner approval before each direct PR-head push.'

    $strClaudeStandingParagraph = [regex]::Match(
        $strClaudeContent,
        '(?m)^[^\S\r\n]+\*\*Standing placement authorization\.\*\*.*$'
    ).Value
    if ([string]::IsNullOrEmpty($strClaudeStandingParagraph)) {
        throw 'Could not locate the CLAUDE standing-placement paragraph for mutation tests.'
    }

    $arrDeletionVariants = @(
        [pscustomobject]@{
            Name = 'Markdown strikethrough'
            Prefix = '~~'
            Suffix = '~~'
        },
        [pscustomobject]@{
            Name = 'nested Markdown strikethrough'
            Prefix = '~~**'
            Suffix = '**~~'
        },
        [pscustomobject]@{
            Name = 'raw HTML s'
            Prefix = '<s>'
            Suffix = '</s>'
        },
        [pscustomobject]@{
            Name = 'raw HTML del with attributes'
            Prefix = '<DEL data-reason="withdrawn">'
            Suffix = '</DEL>'
        },
        [pscustomobject]@{
            Name = 'raw HTML strike'
            Prefix = '<strike>'
            Suffix = '</strike>'
        }
    )
    $arrStandingDocuments = @(
        [pscustomobject]@{
            Name = 'AGENTS'
            Content = $strAgentsContent
            Paragraph = $strAgentsStandingParagraph
            Failure = 'AGENTS.md must contain the standing direct-placement authorization exactly once.'
        },
        [pscustomobject]@{
            Name = 'CLAUDE'
            Content = $strClaudeContent
            Paragraph = $strClaudeStandingParagraph
            Failure = 'CLAUDE.md must contain the standing direct-placement authorization exactly once.'
        }
    )
    foreach ($objDeletionVariant in $arrDeletionVariants) {
        $strDeletedAuthorization = $objDeletionVariant.Prefix +
            $script:strStandingPlacementAuthorization + $objDeletionVariant.Suffix
        foreach ($objStandingDocument in $arrStandingDocuments) {
            $strDeletedParagraph = $objStandingDocument.Paragraph.Replace(
                $script:strStandingPlacementAuthorization,
                $strDeletedAuthorization
            )
            $strDeletedContent = $objStandingDocument.Content.Replace(
                $objStandingDocument.Paragraph,
                $strDeletedParagraph + [Environment]::NewLine +
                    [Environment]::NewLine + '      ' + $strContraryPlacementRule
            )
            if ($objStandingDocument.Name -ceq 'AGENTS') {
                Assert-Failure `
                    -AgentsContent $strDeletedContent `
                    -Failure $objStandingDocument.Failure
            }
            else {
                Assert-Failure `
                    -ClaudeContent $strDeletedContent `
                    -Failure $objStandingDocument.Failure
            }
        }
    }

    $arrInlineHtmlContainerVariants = @(
        [pscustomobject]@{
            Name = 'hidden inline HTML span'
            Prefix = '<span hidden>'
            Suffix = '</span>'
        },
        [pscustomobject]@{
            Name = 'styled hidden inline HTML span'
            Prefix = '<span style="display: none">'
            Suffix = '</span>'
        },
        [pscustomobject]@{
            Name = 'visible inline HTML span'
            Prefix = '<span>'
            Suffix = '</span>'
        },
        [pscustomobject]@{
            Name = 'uppercase hidden inline HTML span'
            Prefix = '<SPAN HIDDEN>'
            Suffix = '</SPAN>'
        },
        [pscustomobject]@{
            Name = 'nested hidden inline HTML containers'
            Prefix = '<span hidden><em>'
            Suffix = '</em></span>'
        },
        [pscustomobject]@{
            Name = 'slash-suffixed hidden non-void HTML span'
            Prefix = '<span hidden />'
            Suffix = '</span>'
        }
    )
    foreach ($objHtmlVariant in $arrInlineHtmlContainerVariants) {
        $strHtmlWrappedAuthorization = $objHtmlVariant.Prefix +
            $script:strStandingPlacementAuthorization + $objHtmlVariant.Suffix
        foreach ($objStandingDocument in $arrStandingDocuments) {
            $strHtmlWrappedParagraph = $objStandingDocument.Paragraph.Replace(
                $script:strStandingPlacementAuthorization,
                $strHtmlWrappedAuthorization
            )
            $strHtmlWrappedContent = $objStandingDocument.Content.Replace(
                $objStandingDocument.Paragraph,
                $strHtmlWrappedParagraph + [Environment]::NewLine +
                    [Environment]::NewLine + '      ' + $strContraryPlacementRule
            )
            if ($objStandingDocument.Name -ceq 'AGENTS') {
                Assert-Failure `
                    -AgentsContent $strHtmlWrappedContent `
                    -Failure $objStandingDocument.Failure
            }
            else {
                Assert-Failure `
                    -ClaudeContent $strHtmlWrappedContent `
                    -Failure $objStandingDocument.Failure
            }
        }
    }

    $objVisibleEmphasisContext = Get-OperativeMarkdownContext `
        -Content 'Visible **operative** prose.'
    if (-not $objVisibleEmphasisContext.ProseText.Contains(
            'Visible operative prose.',
            [StringComparison]::Ordinal
        )) {
        throw 'Operative Markdown filtering removed ordinary emphasized prose.'
    }

    $objVoidHtmlContext = Get-OperativeMarkdownContext `
        -Content 'Visible<br> operative prose.'
    if (-not $objVoidHtmlContext.ProseText.Contains(
            'Visible operative prose.',
            [StringComparison]::Ordinal
        )) {
        throw 'Operative Markdown filtering removed prose adjacent to an HTML void element.'
    }

    $boolUnbalancedDeletionRejected = $false
    try {
        [void](Get-OperativeMarkdownContext -Content 'Visible </del> text.')
    }
    catch {
        $boolUnbalancedDeletionRejected = $_.Exception.Message.Contains(
            'locked Markdown parser rejected',
            [StringComparison]::OrdinalIgnoreCase
        )
    }
    if (-not $boolUnbalancedDeletionRejected) {
        throw 'Unbalanced inline deletion markup did not fail closed.'
    }

    $boolUnbalancedHtmlRejected = $false
    try {
        [void](Get-OperativeMarkdownContext -Content 'Visible </span> text.')
    }
    catch {
        $boolUnbalancedHtmlRejected = $_.Exception.Message.Contains(
            'locked Markdown parser rejected',
            [StringComparison]::OrdinalIgnoreCase
        )
    }
    if (-not $boolUnbalancedHtmlRejected) {
        throw 'Unbalanced inline HTML markup did not fail closed.'
    }

    Assert-Failure `
        -AgentsContent $strAgentsContent.Replace(
            $strAgentsStandingParagraph,
            '<!--' + [Environment]::NewLine +
                $strAgentsStandingParagraph + [Environment]::NewLine +
                '-->' + [Environment]::NewLine + $strContraryPlacementRule
        ) `
        -Failure 'AGENTS.md must contain the standing direct-placement authorization exactly once.'

    $strInlineCodeMutation = $strAgentsStandingParagraph.Replace(
        $strAgentsStandingParagraph.TrimStart(),
        [string][char]96 + $strAgentsStandingParagraph.TrimStart() + [string][char]96
    )
    Assert-Failure `
        -AgentsContent $strAgentsContent.Replace(
            $strAgentsStandingParagraph,
            $strInlineCodeMutation + [Environment]::NewLine +
                [Environment]::NewLine + '      ' + $strContraryPlacementRule
        ) `
        -Failure 'AGENTS.md must contain the standing direct-placement authorization exactly once.'

    $strTechnicalInlineFixture = 'Use `reviewThreads` to enumerate review threads.'
    $objTechnicalInlineContext = Get-OperativeMarkdownContext `
        -Content $strTechnicalInlineFixture
    if (@(
            $objTechnicalInlineContext.ProseBlocks.Code |
                Where-Object { $_ -ceq 'reviewThreads' }
        ).Count -ne 1 -or
        $objTechnicalInlineContext.ProseText.Contains(
            'reviewThreads',
            [StringComparison]::Ordinal
        )) {
        throw 'Inline Markdown parsing did not separate technical code from policy prose.'
    }

    $strMarkdownFence = [string]::new([char] 96, 3)
    $arrTechnicalCodeSpanContracts = @(
        [pscustomobject]@{
            Name = 'AGENTS'
            Content = $strAgentsContent
            Literals = $script:arrAgentsTechnicalCodeSpans
        },
        [pscustomobject]@{
            Name = 'CLAUDE'
            Content = $strClaudeContent
            Literals = $script:arrClaudeTechnicalCodeSpans
        }
    )
    foreach ($objContract in $arrTechnicalCodeSpanContracts) {
        foreach ($strLiteral in $objContract.Literals) {
            $strCodeSpan = [string][char]96 + $strLiteral + [string][char]96
            $strRemovedContent = $objContract.Content.Replace(
                $strCodeSpan,
                'removed technical marker'
            )
            $arrConcealmentMutations = @(
                [pscustomobject]@{
                    Name = 'raw block HTML'
                    Payload = '<div hidden>' + [Environment]::NewLine +
                        $strCodeSpan + [Environment]::NewLine + '</div>'
                },
                [pscustomobject]@{
                    Name = 'inline HTML'
                    Payload = '<span hidden>' + $strCodeSpan + '</span>'
                },
                [pscustomobject]@{
                    Name = 'HTML comment'
                    Payload = '<!-- ' + $strCodeSpan + ' -->'
                },
                [pscustomobject]@{
                    Name = 'deleted text'
                    Payload = '~~' + $strCodeSpan + '~~'
                },
                [pscustomobject]@{
                    Name = 'fenced code'
                    Payload = $strMarkdownFence + 'text' + [Environment]::NewLine +
                        $strCodeSpan + [Environment]::NewLine + $strMarkdownFence
                },
                [pscustomobject]@{
                    Name = 'indented code'
                    Payload = '    ' + $strCodeSpan
                },
                [pscustomobject]@{
                    Name = 'plain prose'
                    Payload = $strLiteral
                }
            )
            foreach ($objMutation in $arrConcealmentMutations) {
                $strMutation = $strRemovedContent + [Environment]::NewLine +
                    [Environment]::NewLine + $objMutation.Payload
                $strFailure = "$($objContract.Name).md is missing required " +
                    $(if ($objContract.Name -ceq 'AGENTS') {
                            'Codex'
                        }
                        else {
                            'Claude'
                        }) + " marker: $strLiteral"
                if ($objContract.Name -ceq 'AGENTS') {
                    Assert-Failure `
                        -AgentsContent $strMutation `
                        -Failure $strFailure
                }
                else {
                    Assert-Failure `
                        -ClaudeContent $strMutation `
                        -Failure $strFailure
                }
            }
        }
    }

    $strRemovedClaudeProse = $strClaudeContent.Replace(
        $script:strClaudeTechnicalProse,
        'removed readiness marker'
    )
    $arrClaudeProseMutations = @(
        '<div hidden>' + [Environment]::NewLine + $script:strClaudeTechnicalProse +
            [Environment]::NewLine + '</div>',
        '<span hidden>' + $script:strClaudeTechnicalProse + '</span>',
        '<!-- ' + $script:strClaudeTechnicalProse + ' -->',
        '~~' + $script:strClaudeTechnicalProse + '~~',
        $strMarkdownFence + 'text' + [Environment]::NewLine +
            $script:strClaudeTechnicalProse + [Environment]::NewLine + $strMarkdownFence,
        '    ' + $script:strClaudeTechnicalProse,
        [string][char]96 + $script:strClaudeTechnicalProse + [string][char]96
    )
    foreach ($strPayload in $arrClaudeProseMutations) {
        Assert-Failure `
            -ClaudeContent ($strRemovedClaudeProse + [Environment]::NewLine +
                [Environment]::NewLine + $strPayload) `
            -Failure (
                'CLAUDE.md is missing required Claude marker: ' +
                $script:strClaudeTechnicalProse
            )
    }

    Assert-Failure `
        -AgentsContent $strAgentsContent.Replace(
            $strAgentsStandingParagraph,
            $strMarkdownFence + 'text' + [Environment]::NewLine +
                $strAgentsStandingParagraph + [Environment]::NewLine +
                $strMarkdownFence + [Environment]::NewLine + $strContraryPlacementRule
        ) `
        -Failure 'AGENTS.md must contain the standing direct-placement authorization exactly once.'

    Assert-Failure `
        -AgentsContent $strAgentsContent.Replace(
            $strAgentsStandingParagraph,
            '> ' + $strMarkdownFence + 'text' + [Environment]::NewLine +
                '> ' + $strAgentsStandingParagraph + [Environment]::NewLine +
                '> ' + $strMarkdownFence + [Environment]::NewLine +
                $strContraryPlacementRule
        ) `
        -Failure 'AGENTS.md must contain the standing direct-placement authorization exactly once.'

    $strMarkdownTildeFence = '~~~'
    Assert-Failure `
        -AgentsContent $strAgentsContent.Replace(
            $strAgentsStandingParagraph,
            '> > ' + $strMarkdownTildeFence + 'text' + [Environment]::NewLine +
                '> > ' + $strAgentsStandingParagraph + [Environment]::NewLine +
                '> > ' + $strMarkdownTildeFence + [Environment]::NewLine +
                $strContraryPlacementRule
        ) `
        -Failure 'AGENTS.md must contain the standing direct-placement authorization exactly once.'

    Assert-Failure `
        -AgentsContent $strAgentsContent.Replace(
            $strAgentsStandingParagraph,
            '- ' + $strMarkdownFence + 'text' + [Environment]::NewLine +
                '  ' + $strAgentsStandingParagraph + [Environment]::NewLine +
                '  ' + $strMarkdownFence + [Environment]::NewLine +
                $strContraryPlacementRule
        ) `
        -Failure 'AGENTS.md must contain the standing direct-placement authorization exactly once.'

    Assert-Failure `
        -AgentsContent $strAgentsContent.Replace(
            $strAgentsStandingParagraph,
            '> ' + $strMarkdownFence + 'text' + [Environment]::NewLine +
                '> ' + $strAgentsStandingParagraph + [Environment]::NewLine +
                $strContraryPlacementRule
        ) `
        -Failure 'AGENTS.md must contain the standing direct-placement authorization exactly once.'

    Assert-FixtureAccepted `
        -AgentsContent $strAgentsContent.Replace(
            $strAgentsStandingParagraph,
            '    > ' + $strAgentsStandingParagraph.TrimStart()
        ) `
        -CodexConfigContent $strCodexConfigContent

    Assert-Failure `
        -AgentsContent $strAgentsContent.Replace(
            $strAgentsStandingParagraph,
            '    ' + $strAgentsStandingParagraph + [Environment]::NewLine +
                [Environment]::NewLine + '    ' + $strContraryPlacementRule
        ) `
        -Failure 'AGENTS.md must contain the standing direct-placement authorization exactly once.'

    $arrIndentedCodeFixtures = @(
        [pscustomobject]@{
            Name = 'top-level indented code block'
            Content = "Before`n`n    HIDDEN-CODE`n`nAfter"
        },
        [pscustomobject]@{
            Name = 'blockquoted indented code block'
            Content = "> Before`n>`n>     HIDDEN-CODE`n>`n> After"
        },
        [pscustomobject]@{
            Name = 'tab-indented code block'
            Content = "Before`n`n`tHIDDEN-CODE`n`nAfter"
        }
    )
    foreach ($objFixture in $arrIndentedCodeFixtures) {
        $strOperativeFixture = ConvertTo-OperativeMarkdownText -Content $objFixture.Content
        if ($strOperativeFixture.Contains('HIDDEN-CODE', [StringComparison]::Ordinal) -or
            -not $strOperativeFixture.Contains('Before', [StringComparison]::Ordinal) -or
            -not $strOperativeFixture.Contains('After', [StringComparison]::Ordinal)) {
            throw "Operative Markdown filtering failed for $($objFixture.Name)."
        }
    }

    $strNestedListProse = @(
        '1. Parent'
        ''
        '    1. Child'
        ''
        '        OPERATIVE-NESTED-PROSE'
    ) -join "`n"
    $strNestedListOperativeText = ConvertTo-OperativeMarkdownText -Content $strNestedListProse
    if (-not $strNestedListOperativeText.Contains(
            'OPERATIVE-NESTED-PROSE',
            [StringComparison]::Ordinal
        )) {
        throw 'Operative Markdown filtering removed ordinary nested-list prose.'
    }

    $strAgentsAutomatedLoopHeading = '## Automated Review Loop (User-Initiated)'
    $strRelocatedStandingPlacement = $strAgentsContent.Replace(
        $strAgentsStandingParagraph,
        ''
    ).Replace(
        $strAgentsAutomatedLoopHeading,
        $strAgentsAutomatedLoopHeading + [Environment]::NewLine +
            $strAgentsStandingParagraph
    )
    Assert-Failure `
        -AgentsContent $strRelocatedStandingPlacement `
        -Failure 'AGENTS.md must contain the standing direct-placement authorization exactly once.'

    Assert-Failure `
        -AgentsContent $strAgentsContent.Replace('`reviewThreads`', '`reviewThreadz`') `
        -Failure 'AGENTS.md is missing required capability marker: `reviewThreads`'

    $arrSharedMarkerSource = @(
        $script:arrSharedStructuralLiterals |
            ForEach-Object {
                if ($_.StartsWith([string][char]96, [StringComparison]::Ordinal)) {
                    $_
                }
                else {
                    [char]96 + $_ + [char]96
                }
            }
    )
    $strSharedMarkerLines = $arrSharedMarkerSource -join [Environment]::NewLine
    $arrSharedMarkerConcealments = @(
        [pscustomobject]@{
            Name = 'raw HTML block'
            Suffix = '<div hidden>' + [Environment]::NewLine +
                $strSharedMarkerLines + [Environment]::NewLine + '</div>'
        },
        [pscustomobject]@{
            Name = 'fenced code block'
            Suffix = $strMarkdownFence + [Environment]::NewLine +
                $strSharedMarkerLines + [Environment]::NewLine + $strMarkdownFence
        },
        [pscustomobject]@{
            Name = 'inline HTML container'
            Suffix = '<span hidden>' + ($arrSharedMarkerSource -join ' ') + '</span>'
        },
        [pscustomobject]@{
            Name = 'unrelated visible paragraph'
            Suffix = 'Unrelated example: ' + ($arrSharedMarkerSource -join ' ')
        }
    )
    foreach ($strDocumentName in @('AGENTS.md', 'CLAUDE.md')) {
        $strDocumentContent = if ($strDocumentName -ceq 'AGENTS.md') {
            $strAgentsContent
        }
        else {
            $strClaudeContent
        }
        foreach ($strLiteral in $script:arrSharedStructuralLiterals) {
            $strDocumentContent = $strDocumentContent.Replace(
                $strLiteral,
                'removed shared structural marker'
            )
        }
        foreach ($objConcealment in $arrSharedMarkerConcealments) {
            $strMutation = $strDocumentContent + [Environment]::NewLine +
                [Environment]::NewLine + $objConcealment.Suffix
            $strFailure = $strDocumentName +
                ' is missing required capability marker: `reviewThreads`'
            if ($strDocumentName -ceq 'AGENTS.md') {
                Assert-Failure `
                    -AgentsContent $strMutation `
                    -Failure $strFailure
            }
            else {
                Assert-Failure `
                    -ClaudeContent $strMutation `
                    -Failure $strFailure
            }
        }
    }

    foreach ($strDocumentName in @('AGENTS.md', 'CLAUDE.md')) {
        $strDocumentContent = if ($strDocumentName -ceq 'AGENTS.md') {
            $strAgentsContent
        }
        else {
            $strClaudeContent
        }
        $strDeferringWorkHeading = '## Deferring Work'
        $arrDeferringWorkMutations = @(
            [pscustomobject]@{
                Name = 'hidden in raw HTML'
                Content = $strDocumentContent.Replace(
                    $strDeferringWorkHeading,
                    '<div>' + [Environment]::NewLine +
                        $strDeferringWorkHeading + [Environment]::NewLine +
                        '</div>'
                )
            },
            [pscustomobject]@{
                Name = 'demoted to level three'
                Content = $strDocumentContent.Replace(
                    $strDeferringWorkHeading,
                    '### Deferring Work'
                )
            },
            [pscustomobject]@{
                Name = 'duplicated'
                Content = $strDocumentContent.Replace(
                    $strDeferringWorkHeading,
                    $strDeferringWorkHeading + [Environment]::NewLine +
                        $strDeferringWorkHeading
                )
            }
        )
        foreach ($objMutation in $arrDeferringWorkMutations) {
            $strFailure =
                "$strDocumentName must contain one exact level-two Deferring Work heading."
            if ($strDocumentName -ceq 'AGENTS.md') {
                Assert-Failure `
                    -AgentsContent $objMutation.Content `
                    -Failure $strFailure
            }
            else {
                Assert-Failure `
                    -ClaudeContent $objMutation.Content `
                    -Failure $strFailure
            }
        }
    }

    foreach ($strLiteral in $script:arrSharedProseLiterals) {
        foreach ($strDocumentName in @('AGENTS.md', 'CLAUDE.md')) {
            $strDocumentContent = if ($strDocumentName -ceq 'AGENTS.md') {
                $strAgentsContent
            }
            else {
                $strClaudeContent
            }
            $strMutationToken = ($strLiteral -split ' ')[-1]
            $strRemovedMarkerContent = $strDocumentContent.Replace(
                $strMutationToken,
                'removed shared policy marker'
            )
            $objRemovedMarkerContext = Get-OperativeMarkdownContext `
                -Content $strRemovedMarkerContent
            if ($objRemovedMarkerContext.ProseText.Contains(
                    $strLiteral,
                    [StringComparison]::Ordinal
                )) {
                throw "Could not remove shared prose marker for mutation: $strLiteral"
            }
            $strInlineCodeMutation = $strRemovedMarkerContent +
                [Environment]::NewLine + '`' + $strLiteral + '`'
            $strRawHtmlMutation = $strRemovedMarkerContent +
                [Environment]::NewLine + '<pre>' + [Environment]::NewLine +
                $strLiteral + [Environment]::NewLine + '</pre>'
            foreach ($objMutation in @(
                    [pscustomobject]@{
                        Name = 'inline code'
                        Content = $strInlineCodeMutation
                    },
                    [pscustomobject]@{
                        Name = 'raw HTML'
                        Content = $strRawHtmlMutation
                    }
                )) {
                $strFailure =
                    "$strDocumentName is missing required capability marker: $strLiteral"
                if ($strDocumentName -ceq 'AGENTS.md') {
                    Assert-Failure `
                        -AgentsContent $objMutation.Content `
                        -Failure $strFailure
                }
                else {
                    Assert-Failure `
                        -ClaudeContent $objMutation.Content `
                        -Failure $strFailure
                }
            }
        }
    }

    foreach ($objContract in $script:arrAgentsNormativeProseContracts) {
        $strLiteral = $objContract.Literal
        $strRemovedMarkerContent = $strAgentsContent.Replace(
            $strLiteral,
            'removed agent-specific policy marker'
        )
        $objRemovedMarkerContext = Get-OperativeMarkdownContext `
            -Content $strRemovedMarkerContent
        if ($objRemovedMarkerContext.ProseText.Contains(
                $strLiteral,
                [StringComparison]::Ordinal
            )) {
            throw "Could not remove AGENTS normative prose marker for mutation: $strLiteral"
        }
        $strInlineCodeMutation = $strRemovedMarkerContent +
            [Environment]::NewLine + '`' + $strLiteral + '`'
        $strRawHtmlMutation = $strRemovedMarkerContent +
            [Environment]::NewLine + '<pre>' + [Environment]::NewLine +
            $strLiteral + [Environment]::NewLine + '</pre>'
        $strVisibleRelocation = $strRemovedMarkerContent +
            [Environment]::NewLine + [Environment]::NewLine +
            'Unrelated glossary entry: ' + $strLiteral
        foreach ($objMutation in @(
                [pscustomobject]@{
                    Name = 'inline code'
                    Content = $strInlineCodeMutation
                },
                [pscustomobject]@{
                    Name = 'raw HTML'
                    Content = $strRawHtmlMutation
                },
                [pscustomobject]@{
                    Name = 'unrelated visible paragraph'
                    Content = $strVisibleRelocation
                }
            )) {
            Assert-Failure `
                -AgentsContent $objMutation.Content `
                -Failure "AGENTS.md must contain required policy as prose: $strLiteral"
        }
    }

    Assert-Failure `
        -ClaudeContent $strClaudeContent.Replace('review-readiness gate', 'review readiness gate') `
        -Failure 'CLAUDE.md is missing required Claude marker: review-readiness gate'

    Assert-Failure `
        -AgentsContent $strAgentsContent.Replace(
            $script:strStandingPlacementAuthorization,
            'An additional direct-push authorization from the owner is required.'
        ) `
        -Failure 'AGENTS.md must contain the standing direct-placement authorization exactly once.'

    Assert-Failure `
        -ClaudeContent $strClaudeContent.Replace(
            $script:strStandingPlacementAuthorization,
            'An additional direct-push authorization from the owner is required.'
        ) `
        -Failure 'CLAUDE.md must contain the standing direct-placement authorization exactly once.'

    Assert-Failure `
        -AgentsContent ($strAgentsContent + [Environment]::NewLine + $script:arrObsoletePlacementLiterals[0]) `
        -Failure 'AGENTS.md contains obsolete session-specific direct-placement authorization'

    foreach ($strLiteral in $script:arrPlacementStructuralLiterals) {
        $strInlineCodeLiteral = '`' + $strLiteral + '`'
        Assert-Failure `
            -AgentsContent $strAgentsContent.Replace($strLiteral, $strInlineCodeLiteral) `
            -Failure (
                'AGENTS.md is missing required direct-placement safety marker: ' +
                $strLiteral
            )
        Assert-Failure `
            -ClaudeContent $strClaudeContent.Replace($strLiteral, $strInlineCodeLiteral) `
            -Failure (
                'CLAUDE.md is missing required direct-placement safety marker: ' +
                $strLiteral
            )
    }

    foreach ($strLiteral in $script:arrPlacementProseLiterals) {
        $strInlineCodeLiteral = '`' + $strLiteral + '`'
        $strAgentsInlineCodeMutation = $strAgentsContent.Replace(
            $strLiteral,
            'removed direct-placement safety marker'
        ).Replace(
            '**Outgoing-range audit.**',
            '**Outgoing-range audit.** ' + $strInlineCodeLiteral
        )
        Assert-Failure `
            -AgentsContent $strAgentsInlineCodeMutation `
            -Failure (
                'AGENTS.md is missing required direct-placement safety marker: ' +
                $strLiteral
            )

        $strClaudeInlineCodeMutation = $strClaudeContent.Replace(
            $strLiteral,
            'removed direct-placement safety marker'
        ).Replace(
            '**Outgoing-range audit.**',
            '**Outgoing-range audit.** ' + $strInlineCodeLiteral
        )
        Assert-Failure `
            -ClaudeContent $strClaudeInlineCodeMutation `
            -Failure (
                'CLAUDE.md is missing required direct-placement safety marker: ' +
                $strLiteral
            )
    }

    Assert-Failure `
        -AgentsContent $strAgentsContent.Replace(
            $script:arrStyleGuideRoutingLiterals[0],
            'Post the prompt in the review discussion.'
        ) `
        -Failure (
            'AGENTS.md must contain the style-guide routing marker exactly once: ' +
            $script:arrStyleGuideRoutingLiterals[0]
        )

    Assert-Failure `
        -ClaudeContent $strClaudeContent.Replace(
            $script:arrStyleGuideRoutingLiterals[1],
            'Post the prompt in the review discussion.'
        ) `
        -Failure (
            'CLAUDE.md must contain the style-guide routing marker exactly once: ' +
            $script:arrStyleGuideRoutingLiterals[1]
        )

    Assert-Failure `
        -AgentsContent $strAgentsContent.Replace(
            $script:strOnlyGenuineDeferredWork,
            'Every non-fix outcome requires a GitHub Issue.'
        ) `
        -Failure 'AGENTS.md must contain the genuine-deferral Issue rule exactly once.'

    Assert-Failure `
        -ClaudeContent $strClaudeContent.Replace(
            $script:strOnlyGenuineDeferredWork,
            'Every non-fix outcome requires a GitHub Issue.'
        ) `
        -Failure 'CLAUDE.md must contain the genuine-deferral Issue rule exactly once.'

    Assert-Failure `
        -ClaudeContent ($strClaudeContent + [Environment]::NewLine + $script:arrObsoleteDeferralLiterals[0]) `
        -Failure 'CLAUDE.md contains an obsolete blanket Issue rule'

    $objMaximumMatch = [regex]::Match(
        $strCodexConfigContent,
        '(?m)^\s*project_doc_max_bytes\s*=\s*(?<MaximumBytes>\d+)\s*$'
    )
    $objMaximumBytesGroup = $objMaximumMatch.Groups['MaximumBytes']
    $strInsufficientCapacityConfig = $strCodexConfigContent.Remove(
        $objMaximumBytesGroup.Index,
        $objMaximumBytesGroup.Length
    )
    $strInsufficientCapacityConfig = $strInsufficientCapacityConfig.Insert(
        $objMaximumBytesGroup.Index,
        '32768'
    )
    Assert-Failure `
        -CodexConfigContent $strInsufficientCapacityConfig `
        -Failure 'project_doc_max_bytes must be at least 65536.'

    $arrAcceptedCapacityStatements = @(
        [pscustomobject]@{
            Name = 'decimal capacity with inline comment'
            Statement = 'project_doc_max_bytes = 65536 # reserve'
        },
        [pscustomobject]@{
            Name = 'decimal capacity with underscores'
            Statement = 'project_doc_max_bytes = 65_536'
        },
        [pscustomobject]@{
            Name = 'decimal capacity with explicit plus sign'
            Statement = 'project_doc_max_bytes = +65536'
        },
        [pscustomobject]@{
            Name = 'hexadecimal capacity'
            Statement = 'project_doc_max_bytes = 0x1_0000'
        },
        [pscustomobject]@{
            Name = 'octal capacity'
            Statement = 'project_doc_max_bytes = 0o200000'
        },
        [pscustomobject]@{
            Name = 'binary capacity'
            Statement = 'project_doc_max_bytes = 0b1_0000_0000_0000_0000'
        },
        [pscustomobject]@{
            Name = 'signed underscored capacity with inline comment'
            Statement = 'project_doc_max_bytes = +65_536 # reserve'
        },
        [pscustomobject]@{
            Name = 'basic-quoted capacity key'
            Statement = '"project_doc_max_bytes" = 65536'
        },
        [pscustomobject]@{
            Name = 'literal-quoted capacity key'
            Statement = "'project_doc_max_bytes' = 65536"
        },
        [pscustomobject]@{
            Name = 'escaped basic-quoted capacity key'
            Statement = '"project_doc_max_b\u0079tes" = 65536'
        }
    )
    foreach ($objAcceptedCapacityStatement in $arrAcceptedCapacityStatements) {
        Assert-FixtureAccepted `
            -CodexConfigContent $strCodexConfigContent.Replace(
                $objMaximumMatch.Value,
                $objAcceptedCapacityStatement.Statement
            )
    }

    foreach ($objInvalidCapacityStatement in @(
            [pscustomobject]@{
                Name = 'string capacity'
                Statement = 'project_doc_max_bytes = "65536"'
            },
            [pscustomobject]@{
                Name = 'Boolean capacity'
                Statement = 'project_doc_max_bytes = true'
            },
            [pscustomobject]@{
                Name = 'floating-point capacity'
                Statement = 'project_doc_max_bytes = 65536.0'
            },
            [pscustomobject]@{
                Name = 'array capacity'
                Statement = 'project_doc_max_bytes = [65536]'
            },
            [pscustomobject]@{
                Name = 'inline-table capacity'
                Statement = 'project_doc_max_bytes = { value = 65536 }'
            }
        )) {
        Assert-Failure `
            -CodexConfigContent $strCodexConfigContent.Replace(
                $objMaximumMatch.Value,
                $objInvalidCapacityStatement.Statement
            ) `
            -Failure 'project_doc_max_bytes must be an integer.'
    }

    Assert-Failure `
        -CodexConfigContent $strCodexConfigContent.Replace(
            $objMaximumMatch.Value,
            'project_doc_max_bytes = 9223372036854775808'
        ) `
        -Failure 'project_doc_max_bytes must fit in a signed 64-bit integer.'

    Assert-Failure `
        -CodexConfigContent $strCodexConfigContent.Replace(
            $objMaximumMatch.Value,
            'project_doc_max_bytes = 0x8000'
        ) `
        -Failure 'project_doc_max_bytes must be at least 65536.'

    $strNestedMaximumConfig = @(
        '[codex_self_test]'
        $objMaximumMatch.Value
    ) -join [Environment]::NewLine
    Assert-Failure `
        -CodexConfigContent $strNestedMaximumConfig `
        -Failure 'project_doc_max_bytes must be the first semantic TOML statement.'

    $strMultilineBasicCapacityConfig = $strCodexConfigContent.Replace(
        $objMaximumMatch.Value,
        (@(
                'model = """'
                $objMaximumMatch.Value
                '"""'
            ) -join [Environment]::NewLine)
    )
    Assert-Failure `
        -CodexConfigContent $strMultilineBasicCapacityConfig `
        -Failure 'project_doc_max_bytes must be the first semantic TOML statement.'

    $strMultilineLiteralCapacityConfig = $strCodexConfigContent.Replace(
        $objMaximumMatch.Value,
        (@(
                "model = '''"
                $objMaximumMatch.Value
                "'''"
            ) -join [Environment]::NewLine)
    )
    Assert-Failure `
        -CodexConfigContent $strMultilineLiteralCapacityConfig `
        -Failure 'project_doc_max_bytes must be the first semantic TOML statement.'

    $strGitHubPluginTableHeader = '[plugins."github@openai-curated"]'
    $arrAcceptedPluginTableStatements = @(
        [pscustomobject]@{
            Name = 'canonical plugin table key'
            Statement = $strGitHubPluginTableHeader
        },
        [pscustomobject]@{
            Name = 'literal-quoted plugin table key'
            Statement = "[plugins.'github@openai-curated']"
        },
        [pscustomobject]@{
            Name = 'basic-quoted dotted plugin keys'
            Statement = '["plugins"."github@openai-curated"]'
        },
        [pscustomobject]@{
            Name = 'mixed quoted dotted plugin keys'
            Statement = "['plugins'.`"github@openai-curated`"]"
        },
        [pscustomobject]@{
            Name = 'escaped basic-quoted plugin table key'
            Statement = '[plugins."github\u0040openai-curated"]'
        },
        [pscustomobject]@{
            Name = 'spaced literal-quoted dotted plugin keys'
            Statement = "[ 'plugins' . 'github@openai-curated' ]"
        },
        [pscustomobject]@{
            Name = 'plugin table key with inline comment'
            Statement = '[plugins."github@openai-curated"] # required plugin'
        }
    )
    $arrAcceptedPluginEnablementStatements = @(
        [pscustomobject]@{
            Name = 'bare enabled key'
            Statement = 'enabled = true'
        },
        [pscustomobject]@{
            Name = 'basic-quoted enabled key'
            Statement = '"enabled" = true'
        },
        [pscustomobject]@{
            Name = 'literal-quoted enabled key'
            Statement = "'enabled' = true"
        },
        [pscustomobject]@{
            Name = 'escaped basic-quoted enabled key'
            Statement = '"en\u0061bled" = true'
        }
    )
    foreach ($objPluginTableStatement in $arrAcceptedPluginTableStatements) {
        foreach ($objPluginEnablementStatement in $arrAcceptedPluginEnablementStatements) {
            $strPluginKeyVariantConfig = $strCodexConfigContent.Replace(
                $strGitHubPluginTableHeader,
                $objPluginTableStatement.Statement
            ).Replace(
                'enabled = true',
                $objPluginEnablementStatement.Statement
            )
            $objPluginKeyVariantContext = Get-TomlParseContext `
                -Content $strPluginKeyVariantConfig
            if (-not [string]::IsNullOrEmpty($objPluginKeyVariantContext.Failure) -or
                -not $objPluginKeyVariantContext.CapacityIsFirstStatement -or
                -not $objPluginKeyVariantContext.PluginHeaderIsSecondStatement -or
                -not $objPluginKeyVariantContext.PluginEnablementIsThirdStatement -or
                -not $objPluginKeyVariantContext.PluginTablePresent -or
                -not $objPluginKeyVariantContext.PluginEnabledPresent -or
                $objPluginKeyVariantContext.PluginEnabledType -cne 'bool' -or
                -not $objPluginKeyVariantContext.PluginEnabledValue) {
                throw (
                    "Accepted plugin key permutation failed parser validation: " +
                    "$($objPluginTableStatement.Name) with " +
                    "$($objPluginEnablementStatement.Name)."
                )
            }
            $objPluginKeyVariantLocation = Get-GitHubPluginEnablementContext `
                -Content $strPluginKeyVariantConfig
            if ($objPluginKeyVariantLocation.TableMatchCount -ne 1 -or
                $objPluginKeyVariantLocation.EnablementMatchCount -ne 1 -or
                $objPluginKeyVariantLocation.EnabledValue -cne 'true' -or
                $objPluginKeyVariantLocation.EnabledValueIndex -lt 0 -or
                $objPluginKeyVariantLocation.EnabledValueLength -ne 4) {
                throw (
                    "Accepted plugin key permutation did not produce one source location: " +
                    "$($objPluginTableStatement.Name) with " +
                    "$($objPluginEnablementStatement.Name)."
                )
            }
        }
    }

    $strCombinedQuotedKeyConfig = $strCodexConfigContent.Replace(
        $objMaximumMatch.Value,
        '"project_doc_max_b\u0079tes" = 65536'
    ).Replace(
        $strGitHubPluginTableHeader,
        "[ 'plugins' . 'github@openai-curated' ]"
    ).Replace(
        'enabled = true',
        '"en\u0061bled" = true'
    )
    Assert-FixtureAccepted `
        -CodexConfigContent $strCombinedQuotedKeyConfig
    Assert-Failure `
        -CodexConfigContent (ConvertTo-DisabledGitHubPluginMutation `
            -Content $strCombinedQuotedKeyConfig) `
        -Failure 'The github@openai-curated plugin table must declare enabled = true exactly once.'

    foreach ($objNearMissPluginStatement in @(
            [pscustomobject]@{
                Name = 'different escaped plugin table key'
                Search = $strGitHubPluginTableHeader
                Replacement = '[plugins."github\u0041openai-curated"]'
                Failure =
                    'The github@openai-curated plugin table must be the second semantic TOML statement.'
            },
            [pscustomobject]@{
                Name = 'array-of-tables plugin declaration'
                Search = $strGitHubPluginTableHeader
                Replacement = '[[plugins."github@openai-curated"]]'
                Failure =
                    'The github@openai-curated plugin table must be the second semantic TOML statement.'
            },
            [pscustomobject]@{
                Name = 'nested enabled key'
                Search = 'enabled = true'
                Replacement = '"enabled".nested = true'
                Failure =
                    'The github@openai-curated enabled value must be the third semantic TOML statement.'
            },
            [pscustomobject]@{
                Name = 'different escaped enabled key'
                Search = 'enabled = true'
                Replacement = '"en\u0062bled" = true'
                Failure =
                    'The github@openai-curated enabled value must be the third semantic TOML statement.'
            }
        )) {
        Assert-Failure `
            -CodexConfigContent $strCodexConfigContent.Replace(
                $objNearMissPluginStatement.Search,
                $objNearMissPluginStatement.Replacement
            ) `
            -Failure $objNearMissPluginStatement.Failure
    }

    Assert-Failure `
        -CodexConfigContent $strCodexConfigContent.Replace(
            $strGitHubPluginTableHeader,
            '[plugins."github-disabled-for-self-test"]'
        ) `
        -Failure 'The project configuration must declare [plugins."github@openai-curated"] exactly once.'

    $strDisabledGitHubPluginConfig = ConvertTo-DisabledGitHubPluginMutation `
        -Content $strCodexConfigContent
    Assert-Failure `
        -CodexConfigContent $strDisabledGitHubPluginConfig `
        -Failure 'The github@openai-curated plugin table must declare enabled = true exactly once.'

    foreach ($objInvalidPluginValue in @(
            [pscustomobject]@{
                Name = 'string GitHub plugin enablement'
                Statement = 'enabled = "true"'
            },
            [pscustomobject]@{
                Name = 'integer GitHub plugin enablement'
                Statement = 'enabled = 1'
            }
        )) {
        Assert-Failure `
            -CodexConfigContent $strCodexConfigContent.Replace(
                'enabled = true',
                $objInvalidPluginValue.Statement
            ) `
            -Failure 'The github@openai-curated plugin table must declare enabled = true exactly once.'
    }

    $strConfigNewLine = if ($strCodexConfigContent.Contains("`r`n", [StringComparison]::Ordinal)) {
        "`r`n"
    }
    else {
        "`n"
    }
    $strCapacityStatement = $objMaximumMatch.Value.TrimEnd([char[]] "`r`n")
    $strCanonicalConfigPrefix = @(
        $strCapacityStatement
        ''
        $strGitHubPluginTableHeader
        'enabled = true'
    ) -join $strConfigNewLine
    $strReorderedConfigPrefix = @(
        $strGitHubPluginTableHeader
        'enabled = true'
        ''
        $strCapacityStatement
    ) -join $strConfigNewLine
    Assert-Failure `
        -CodexConfigContent $strCodexConfigContent.Replace(
            $strCanonicalConfigPrefix,
            $strReorderedConfigPrefix
        ) `
        -Failure 'project_doc_max_bytes must be the first semantic TOML statement.'

    $objCanonicalPluginContext = Get-GitHubPluginEnablementContext `
        -Content $strCodexConfigContent
    $intEnablementLineStart = $strCodexConfigContent.LastIndexOf(
        "`n",
        $objCanonicalPluginContext.EnabledValueIndex
    ) + 1
    $strAlternativePluginFormattingConfig = $strCodexConfigContent.Insert(
        $intEnablementLineStart,
        "# accepted plugin separator$strConfigNewLine"
    )
    $objAlternativePluginContext = Get-GitHubPluginEnablementContext `
        -Content $strAlternativePluginFormattingConfig
    $strAlternativePluginFormattingConfig = $strAlternativePluginFormattingConfig.Insert(
        $objAlternativePluginContext.EnabledValueIndex,
        ' '
    )
    $arrAlternativePluginFailures = @(Get-AgentInstructionFailure `
            -AgentsContent $strAgentsContent `
            -ClaudeContent $strClaudeContent `
            -CodexConfigContent $strAlternativePluginFormattingConfig)
    if ($arrAlternativePluginFailures.Count -gt 0) {
        throw "Accepted plugin formatting failed validation: $($arrAlternativePluginFailures -join '; ')"
    }
    Assert-Failure `
        -CodexConfigContent (ConvertTo-DisabledGitHubPluginMutation `
            -Content $strAlternativePluginFormattingConfig) `
        -Failure 'The github@openai-curated plugin table must declare enabled = true exactly once.'

    Assert-Failure `
        -CodexConfigContent ($strCodexConfigContent + [Environment]::NewLine +
            $strGitHubPluginTableHeader + [Environment]::NewLine + 'enabled = true') `
        -Failure 'The project configuration must contain valid TOML.'

    Assert-Failure `
        -CodexConfigContent $strCodexConfigContent.Replace(
            $strGitHubPluginTableHeader,
            '[features.plugins."github@openai-curated"]'
        ) `
        -Failure 'The project configuration must declare [plugins."github@openai-curated"] exactly once.'

    $strBasicStringPluginTableConfig = $strCodexConfigContent.Replace(
        $strGitHubPluginTableHeader,
        "model = `"`"`"$strConfigNewLine$strGitHubPluginTableHeader"
    ).Replace(
        'enabled = true',
        "enabled = true$strConfigNewLine`"`"`""
    )
    Assert-Failure `
        -CodexConfigContent $strBasicStringPluginTableConfig `
        -Failure 'The github@openai-curated plugin table must be the second semantic TOML statement.'

    $strLiteralStringPluginTableConfig = $strCodexConfigContent.Replace(
        $strGitHubPluginTableHeader,
        "model = '''$strConfigNewLine$strGitHubPluginTableHeader"
    ).Replace(
        'enabled = true',
        "enabled = true$strConfigNewLine'''"
    )
    Assert-Failure `
        -CodexConfigContent $strLiteralStringPluginTableConfig `
        -Failure 'The github@openai-curated plugin table must be the second semantic TOML statement.'

    $strBasicStringPluginEnabledConfig = $strCodexConfigContent.Replace(
        'enabled = true',
        "model = `"`"`"$strConfigNewLine" +
            "enabled = true$strConfigNewLine`"`"`""
    )
    Assert-Failure `
        -CodexConfigContent $strBasicStringPluginEnabledConfig `
        -Failure 'The github@openai-curated enabled value must be the third semantic TOML statement.'

    $strLiteralStringPluginEnabledConfig = $strCodexConfigContent.Replace(
        'enabled = true',
        "model = '''$strConfigNewLine" +
            "enabled = true$strConfigNewLine'''"
    )
    Assert-Failure `
        -CodexConfigContent $strLiteralStringPluginEnabledConfig `
        -Failure 'The github@openai-curated enabled value must be the third semantic TOML statement.'

    $strLaterBasicStringConfig = $strCodexConfigContent + $strConfigNewLine +
        (@(
                '[validator_basic_string_fixture]'
                'content = """'
                $objMaximumMatch.Value
                $strGitHubPluginTableHeader
                'enabled = false'
                '"""'
            ) -join $strConfigNewLine)
    Assert-FixtureAccepted `
        -CodexConfigContent $strLaterBasicStringConfig
    Assert-Failure `
        -CodexConfigContent (ConvertTo-DisabledGitHubPluginMutation `
            -Content $strLaterBasicStringConfig) `
        -Failure 'The github@openai-curated plugin table must declare enabled = true exactly once.'

    $strLaterLiteralStringConfig = $strCodexConfigContent + $strConfigNewLine +
        (@(
                '[validator_literal_string_fixture]'
                "content = '''"
                $objMaximumMatch.Value
                $strGitHubPluginTableHeader
                'enabled = false'
                "'''"
            ) -join $strConfigNewLine)
    Assert-FixtureAccepted `
        -CodexConfigContent $strLaterLiteralStringConfig
    Assert-Failure `
        -CodexConfigContent (ConvertTo-DisabledGitHubPluginMutation `
            -Content $strLaterLiteralStringConfig) `
        -Failure 'The github@openai-curated plugin table must declare enabled = true exactly once.'

    $intCurrentBytes = [Text.Encoding]::UTF8.GetByteCount($strAgentsContent)
    $intDefaultFillerLength = [Math]::Max(1, 32768 - $intCurrentBytes + 1)
    Assert-Failure `
        -AgentsContent ($strAgentsContent + ('x' * $intDefaultFillerLength)) `
        -Failure 'AGENTS.md must not exceed the ordinary 32768-byte Codex limit.'

    $intMaximumBytes = [int64]$objMaximumBytesGroup.Value
    $intFillerLength = [Math]::Max(1, $intMaximumBytes - $intCurrentBytes - 16384 + 1)
    Assert-Failure `
        -AgentsContent ($strAgentsContent + ('x' * $intFillerLength)) `
        -Failure 'Configured AGENTS.md capacity must retain at least 16384 bytes of reserve.'

    foreach ($objSafetyLimitContract in $script:arrSafetyLimitContracts) {
        $strSafetyDocumentContent = if ($objSafetyLimitContract.DocumentName -ceq 'AGENTS.md') {
            $strAgentsContent
        }
        else {
            $strClaudeContent
        }
        $strHtmlOnlySafetyLimit = '<pre>' + [Environment]::NewLine +
            $objSafetyLimitContract.StructuralLiteral + [Environment]::NewLine +
            '</pre>' + [Environment]::NewLine +
            $objSafetyLimitContract.WeakStructuralLiteral
        $strSafetyLimitMutation = $strSafetyDocumentContent.Replace(
            $objSafetyLimitContract.StructuralLiteral,
            $strHtmlOnlySafetyLimit
        )
        if ($objSafetyLimitContract.DocumentName -ceq 'AGENTS.md') {
            Assert-Failure `
                -AgentsContent $strSafetyLimitMutation `
                -Failure $objSafetyLimitContract.Failure
        }
        else {
            Assert-Failure `
                -ClaudeContent $strSafetyLimitMutation `
                -Failure $objSafetyLimitContract.Failure
        }
    }

    Assert-Failure `
        -AgentsContent $strAgentsContent.Replace('**Maximum rounds:** 8', '**Maximum rounds:** 80') `
        -Failure 'AGENTS.md is missing required Codex marker: **Maximum rounds:** 8'

    Assert-Failure `
        -ClaudeContent $strClaudeContent.Replace('**Maximum rounds:** 80', '**Maximum rounds:** 800') `
        -Failure 'CLAUDE.md is missing the 80-round Claude limit.'

    Assert-Failure `
        -AgentsContent $strAgentsContent.Replace('**Maximum rounds:** 8', '**Maximum rounds:** 8,000') `
        -Failure 'AGENTS.md is missing required Codex marker: **Maximum rounds:** 8'

    Assert-Failure `
        -AgentsContent $strAgentsContent.Replace(
            '**Wall-clock timeout:** 6 hours from cycle start.',
            '**Wall-clock timeout:** 6 hours minimum from cycle start.'
        ) `
        -Failure 'AGENTS.md is missing the 6-hour Codex wall-clock limit.'

    Assert-Failure `
        -ClaudeContent $strClaudeContent.Replace('**Maximum rounds:** 80', '**Maximum rounds:** 80,000') `
        -Failure 'CLAUDE.md is missing the 80-round Claude limit.'

    Assert-Failure `
        -ClaudeContent $strClaudeContent.Replace(
            '**Wall-clock timeout:** 6 hours from loop start.',
            '**Wall-clock timeout:** 6 hours minimum from loop start.'
        ) `
        -Failure 'CLAUDE.md is missing the 6-hour Claude wall-clock limit.'

    Write-Output 'Agent-instruction mutation self-tests passed.'
    #endregion Mutation self-tests
}
