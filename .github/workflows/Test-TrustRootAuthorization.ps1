# .SYNOPSIS
# Validates one bounded trust-root maintenance candidate as inert Git data.
#
# .DESCRIPTION
# Reads the authorization manifest only from the authenticated trusted revision.
# Schema 2 authorizes exact content on a descendant of that revision without an
# unborn commit identity. It can authorize one exact change from an active
# manifest to the canonical inactive schema 2 manifest. Schema 1 is retained
# only to bootstrap schema 2. Candidate blobs are decoded and parsed, but never
# sourced, imported, invoked, built, or executed.
# The canonical inactive manifest also permits the closed ordinary workflow-policy
# content domain. That result validates content shape, not independent review or
# merge readiness. The exact-input CI, review and quality lifecycle remains required.
#
# .PARAMETER RepositoryRootPath
# The trusted repository worktree.
#
# .PARAMETER TrustedRevision
# The exact checked-out default-branch commit that owns the verifier and manifest.
#
# .PARAMETER BaseRevision
# The event base. Schema 2 requires this commit to equal TrustedRevision.
#
# .PARAMETER HeadRevision
# The descendant candidate head, or the exact schema 1 transition head.
#
# .PARAMETER AuthorizationApplicabilityOnly
# When this switch is set, the script checks only whether the authorization
# applies to the candidate. It returns one Boolean value and does not perform
# the full authorization validation.
#
# .PARAMETER SelfTest
# Runs focused verifier helper tests and returns before authorization evaluation.
#
# .PARAMETER ValidateOrdinaryCaseCatalog
# Also checks added ordinary cases with trusted rules. Strengthened generator
# cases use the closed inert-data semantics; other cases use the trusted validator.
#
# .PARAMETER AuthorizationManifestPath
# The fixed trusted-revision authorization path.
#
# .EXAMPLE
# ./Test-TrustRootAuthorization.ps1 @hashtableArguments
#
# # Validates a bounded candidate and writes one Boolean result.
#
# .INPUTS
# None. This script does not accept pipeline input.
#
# .OUTPUTS
# [System.Boolean] True for a bounded content-valid candidate, not merge approval.
#
# .NOTES
# Version: 1.7.20260919.0

[CmdletBinding(PositionalBinding = $false)]
[OutputType([bool])]
param(
    [Parameter(Mandatory)][string] $RepositoryRootPath,
    [Parameter(Mandatory)][string] $TrustedRevision,
    [Parameter(Mandatory)][string] $BaseRevision,
    [Parameter(Mandatory)][string] $HeadRevision,
    [Parameter()][switch] $AuthorizationApplicabilityOnly,
    [Parameter()][switch] $SelfTest,
    [Parameter()][switch] $ValidateOrdinaryCaseCatalog,
    [Parameter()][string] $AuthorizationManifestPath =
        '.github/workflows/trust-root-authorization.json'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$script:boolValidateOrdinaryCaseCatalog = [bool]$ValidateOrdinaryCaseCatalog
$script:strIsolationMarkerPattern = '(?m)^const WORKFLOW_ISOLATION_POLICY_VERSION = 1;$'
$intManifestMaximumBytes = 65536
$intCandidateMaximumPaths = 19
$intInactiveManifestMaximumPaths = 16
$intCandidateMaximumBlobBytes = 573440
$intCandidateMaximumCommits = 64
$strObjectIdPattern = '^[0-9a-f]{40}$'
$strAuthorizationPath = '.github/workflows/trust-root-authorization.json'
$strVerifierPath = '.github/workflows/Test-TrustRootAuthorization.ps1'
$script:dictionaryPolicyReferenceText =
    [Collections.Generic.Dictionary[string, string]]::new([StringComparer]::Ordinal)
$arrTrustRootPaths = @(
    '.gitattributes',
    '.github/.gitattributes',
    '.github/actionlint.yaml',
    '.github/workflows/.gitattributes',
    '.github/workflows/Test-TrustRootAuthorization.ps1',
    '.github/workflows/Test-AgentInstructions.SelfTest.ps1',
    '.github/workflows/Test-AgentInstructions.ps1',
    '.github/workflows/Test-AgentInstructionParserManifest.mjs',
    '.github/workflows/Set-AgentInstructionCurrentBaseStatus.mjs',
    '.github/workflows/trust-root-authorization.json',
    '.github/workflows/agent-instruction-current-base.yml',
    '.github/workflows/agent-instructions.yml',
    '.github/workflows/Sync-PullRequestBodyIdentity.mjs',
    '.github/workflows/pull-request-body-identity-cases.json',
    '.github/workflows/pull-request-body-identity.yml',
    '.github/workflows/workflow-policy-cases.json',
    '.github/workflows/workflow-policy-contract.json',
    '.github/workflows/Validate-WorkflowPolicy.mjs',
    '.github/workflows/workflow-isolation-reference.json',
    '.github/workflows/workflow-isolation-validator.reference.txt',
    '.github/workflows/workflow-common-reference.json',
    '.github/workflows/workflow-common-validator.reference.txt',
    '.github/workflows/workflow-ordinary-selftest-reference.json',
    '.github/workflows/build.yml',
    '.github/workflows/markdownlint.yml',
    '.pre-commit-config.yaml'
)
$script:arrSpecialSemanticInvariant = @(
    'actionlint-queue-schema-exceptions-are-exact',
    'agent-instruction-heading-status-and-bootstrap-order-is-exact',
    'exact-maintenance-production-call-is-gated',
    'legacy-transition-marker-is-inert-data',
    'package-lock-parser-closure-is-exact',
    'package-parser-roots-are-exact',
    'parser-manifest-direct-roots-and-closure-is-exact',
    'pre-commit-actionlint-gate-is-exact',
    'published-path-array-binding-is-explicit',
    'pull-request-body-identity-api-termination-is-bounded',
    'pull-request-body-identity-cases-preserve-required-coverage',
    'pull-request-body-identity-workflow-topology-is-exact',
    'workflow-policy-contract-identities-and-structure-are-exact',
    'workflow-policy-identity-cases-are-exact',
    'workflow-policy-preflight-authenticates-deferred-yaml-import',
    'workflow-created-push-history-fetch-is-bounded',
    'current-base-status-helper-is-fail-closed'
)
$script:hashtableSemanticInvariantPath = @{
    'actionlint-queue-schema-exceptions-are-exact' =
        '.github/actionlint.yaml'
    'agent-instruction-heading-status-and-bootstrap-order-is-exact' =
        '.github/workflows/Test-AgentInstructions.ps1'
    'package-lock-parser-closure-is-exact' = 'package-lock.json'
    'package-parser-roots-are-exact' = 'package.json'
    'parser-manifest-direct-roots-and-closure-is-exact' =
        '.github/workflows/Test-AgentInstructionParserManifest.mjs'
    'pre-commit-actionlint-gate-is-exact' = '.pre-commit-config.yaml'
    'pull-request-body-identity-api-termination-is-bounded' =
        '.github/workflows/Sync-PullRequestBodyIdentity.mjs'
    'pull-request-body-identity-cases-preserve-required-coverage' =
        '.github/workflows/pull-request-body-identity-cases.json'
    'pull-request-body-identity-workflow-topology-is-exact' =
        '.github/workflows/pull-request-body-identity.yml'
    'workflow-policy-contract-identities-and-structure-are-exact' =
        '.github/workflows/workflow-policy-contract.json'
    'workflow-policy-identity-cases-are-exact' =
        '.github/workflows/workflow-policy-cases.json'
    'workflow-policy-preflight-authenticates-deferred-yaml-import' =
        '.github/workflows/Validate-WorkflowPolicy.mjs'
}
# These current/next pins close the one-way PR #188 transition. Task 67 must
# replace transition-only pins before an ordinary R2 trust-root content update.
$script:hashtableExactTransitionTextIdentity = @{
    'pull-request-body-identity-api-termination-is-bounded' = @(
        '7eddc775e5dc5f6325591c8efe8a005a07aab9b0d0f9f1b720f3b74fbcf0eafd',
        '7b61ea2116386f75726af33dccf3e18fc90b509c206d44e900be405388556766',
        '03b0aa378cbf8b70d7b292ee2d904a03e808d52dae067af2af5f766f46cabecf',
        '0458f240ed8415eb1a898a8c30d2fd90f717f034b9bec6e6d6ab878b3346305d',
        'd6682435e6a339085ceaef016f3902c9b4da2eae74bc9186c0bc7583224f9309'
    )
    'pull-request-body-identity-workflow-topology-is-exact' = @(
        'b006c0ed4cc0dc2391199fe1a49431c06f9a45910db34fe143c2e6df3ada2dd0',
        'ab795c9bbcadecacb4f6f16dbf3d983b492f7069ff11937f6c94c4266abada51',
        '80be5df430e409ec51e5dac9cd8f10b88f3c49bf5afb35cfdcd7d2a782ce5100',
        '3cb05907e93698fbd1eeeb732604c41fd56e807e96e31799bafa502f388b8664',
        '472d0e417ac121814c696d4cbde3208adb0e26178ec817bb614b4c14b3201d3e',
        'ad08271a154d7baf09d56cea5a5a5bd6d9f74b5b0233f52db13937f95ff8e5bb'
    )
    'workflow-policy-identity-cases-are-exact' = @(
        'c0221ac73687b9eb0cbe83fb21bbef6419f4359420fbdcafff73e36464bbe09e',
        '5a79ee8fcacd64a4a502203957e7f3ca7ad3da34666aa047ad26905ad8ec0d3f',
        '1b56b84abf049a1c1195cb7f8b2dc88a72e413ebd7c081f7032849290d9f030e',
        '9ceab2b7fd5b6bfac9fc32b4ab945bd0b25a6fb645fadc5aed0dc1b651adca46',
        'b177a2e9ad6aa5362cf2b586739b1bfee82b9a83b30754f43dc4f90509d31418',
        '8598d3495776cf410260df595771b73a83b19ee8ad08debf6ec3def92f456cf5'
    )
}
$script:objCanonicalJsonOptions =
    [System.Text.Json.JsonSerializerOptions]::new()
$script:objCanonicalJsonOptions.Encoder =
    [System.Text.Encodings.Web.JavaScriptEncoder]::UnsafeRelaxedJsonEscaping
$script:hashtableSemanticInvariantPattern = @{
    'adr-lifecycle-migration-is-enforced' =
        '(?s)function Get-DecisionRecordLifecycleFailure.*?' +
        'An unchanged published legacy ADR did not remain valid\..*?' +
        'A changed legacy ADR did not require lifecycle migration'
    'created-ref-metadata-baseline-is-consumed' =
        '(?s)function Get-CreatedRefMetadataBaselineRevision.*?' +
        '\$strCreatedRefMetadataBaselineRevision =\s+' +
        'Get-CreatedRefMetadataBaselineRevision.*?' +
        '\$strEffectivePublishedBaselineRevision = if ' +
        '\(\$PublishedBaselineAbsent\).*?' +
        '-Revision \$strEffectivePublishedBaselineRevision'
    'created-ref-paths-use-endpoint-boundary' =
        '(?s)function Read-GitPublishedEndpointChangedPath.*?' +
        'elseif \(\$BaselineAbsent -and ' +
        '\$arrBoundaries\.Count -eq 1\).*?' +
        '''diff''.*?\$arrBoundaries\[0\], \$FinalRevision.*?' +
        'A created ref with introduced commits must have one boundary'
    'docs-policy-owner-boundary' =
        '(?m)^- `\.github/instructions/docs\.instructions\.md` owns these ' +
        'documentation rules\.$'
    'docs-status-lifecycle-values' =
        'Draft \| Proposed \| Active \| Accepted \| Superseded \| Deprecated'
    'extracted-self-test-is-invoked' =
        '& \(Join-Path \$strRepositoryRootPath \$strExtractedSelfTestPath\)'
    'extracted-self-test-version-and-topology' =
        '(?s)# Version: 1\.4\.\d{8}\.\d+.*Get-CreatedRefBoundaryContext'
    'new-ref-boundary-cap-is-64' =
        '\$intMetadataMaximumBoundaries = 64'
    'pr-merge-bases-use-all-and-cap' =
        'merge-base --all'
    'published-finalization-date-is-enforced' =
        '(?s)\$strTrustedEventUtcDate = ' +
        '\$objTrustedEventTimestamp\.ToString\(.*?' +
        'ExpectedUtcDate = \$strTrustedEventUtcDate.*?' +
        'IsWorktreeTransition = \$true'
    'ordinary-pr-uses-normal-trust-audit' =
        '(?s)if \(\s*\$script:boolTrustedMaintenanceAuthorizationValidated' +
        '.*?-ExactAuthorizedMaintenanceProductionCall.*?else \{\s+' +
        '@\(Get-TrustRootRangeMutationFailure'
    'trusted-maintenance-switch-is-explicit' =
        '\$TrustedMaintenanceAuthorizationValidated'
    'verifier-audits-authorized-history' =
        'The candidate history contains unauthorized path'
    'verifier-reads-trusted-revision-manifest' =
        'ls-tree\s+`?\s*\$TrustedRevision\s+--\s+\$AuthorizationManifestPath'
    'workflow-checkout-is-trusted-sha' =
        '(?s)ref: \$\{\{ github\.sha \}\}.*?fetch-depth: >-\s+' +
        "\$\{\{ github\.event_name == 'push' && github\.event\.created " +
        '&& 1 \|\| 0 \}\}'
    'workflow-current-base-finalizer-is-fail-closed' =
        '(?s)^(?!.*contents: write)(?!.*pull-requests: write).*?' +
        'mark-current-base-pending:.*?' +
        'group: agent-instruction-current-base-status.*?queue: max.*?' +
        'cancel-in-progress: false.*?statuses: write.*?' +
        'Set-AgentInstructionCurrentBaseStatus\.mjs\s+start.*?' +
        'validate-agent-instructions:.*?mark-current-base-pending.*?' +
        'needs\.mark-current-base-pending\.result == ''success''.*?' +
        'publish-current-base-status:.*?mark-current-base-pending.*?' +
        'validate-agent-instructions.*?' +
        'group: agent-instruction-current-base-status.*?queue: max.*?' +
        'cancel-in-progress: false.*?' +
        'statuses: write.*?ref: \$\{\{ github\.sha \}\}.*?' +
        'persist-credentials: false.*?' +
        'Set-AgentInstructionCurrentBaseStatus\.mjs\s+finalize'
    'workflow-run-current-base-invalidator-is-fail-closed' =
        '(?s)^(?!.*pull_request_target:)(?!.*workflow_dispatch:)' +
        '(?!.*actions: write)(?!.*artifacts/).*?repository_dispatch:.*?' +
        'agent-instruction-current-base-continuation-v1.*?' +
        'agent-instruction-current-base-bootstrap-v1.*?' +
        'workflow_run:.*?Agent instruction validation.*?requested.*?completed.*?' +
        'run-name:.*?Agent current-base continuation:.*?github\.sha.*?' +
        "workflow_run\.event == 'push'.*?repository_dispatch.*?" +
        'group: agent-instruction-current-base-status.*?' +
        'queue: max.*?' +
        'cancel-in-progress: false.*?' +
        'actions: read.*?contents: write.*?pull-requests: read.*?' +
        'statuses: write.*?ref: \$\{\{ github\.sha \}\}.*?' +
        'persist-credentials: false.*?GITHUB_SERVER_URL: ' +
        '\$\{\{ github\.server_url \}\}.*?SWEEP_EVENT_NAME:.*?' +
        'SWEEP_RUN_REF: \$\{\{ github\.ref_name \}\}.*?' +
        'SWEEP_RUN_SHA: \$\{\{ github\.sha \}\}.*?' +
        'SWEEP_EVENT_TYPE: \$\{\{ github\.event\.action \}\}.*?' +
        'SWEEP_CLIENT_PAYLOAD: ' +
        '\$\{\{ toJson\(github\.event\.client_payload\) \}\}.*?' +
        'Set-AgentInstructionCurrentBaseStatus\.mjs\s+invalidate'
    'workflow-permissions-are-read-only' =
        'permissions:\s+contents: read'
    'workflow-persist-credentials-is-false' =
        'persist-credentials: false'
    'workflow-uses-trusted-authorization-output' =
        'TrustedMaintenanceAuthorizationValidated'
}

function Invoke-BoundedProcessByte {
    # .SYNOPSIS
    # Runs one process with bounded output and execution time.
    #
    # .DESCRIPTION
    # Starts the requested executable without a shell, captures standard output
    # as bytes, captures bounded error text, and stops on size or time overflow.
    # Optional input bytes are written unchanged while both output pipes drain.
    #
    # .PARAMETER FileName
    # The executable name or absolute executable path.
    #
    # .PARAMETER ArgumentList
    # The exact ordered arguments supplied without shell interpolation.
    #
    # .PARAMETER MaximumBytes
    # The positive maximum permitted standard-output byte count.
    #
    # .PARAMETER TimeoutMilliseconds
    # The process time limit in milliseconds.
    #
    # .PARAMETER InputBytes
    # Optional exact stdin bytes, at most 524288. An empty array sends EOF.
    #
    # .EXAMPLE
    # Invoke-BoundedProcessByte -FileName 'git' -ArgumentList $arrArgs `
    #     -MaximumBytes 1024
    #
    # # Returns the exit code, output bytes, and bounded error text.
    #
    # .INPUTS
    # None. This helper does not accept pipeline input.
    #
    # .OUTPUTS
    # [System.Management.Automation.PSCustomObject] One bounded process result.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20260918.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][string] $FileName,
        [Parameter(Mandatory)][string[]] $ArgumentList,
        [Parameter(Mandatory)][ValidateRange(1, 2147483646)][int] $MaximumBytes,
        [Parameter()][ValidateRange(100, 60000)][int] $TimeoutMilliseconds = 10000,
        [Parameter()][ValidateNotNull()][AllowEmptyCollection()][byte[]] $InputBytes
    )

    $boolHasInput = $PSBoundParameters.ContainsKey('InputBytes')
    if ($boolHasInput -and $InputBytes.Length -gt 524288) {
        throw 'Process input exceeds 524288 bytes.'
    }
    $objStartInfo = [Diagnostics.ProcessStartInfo]::new($FileName)
    $objStartInfo.UseShellExecute = $false
    $objStartInfo.CreateNoWindow = $true
    $objStartInfo.RedirectStandardOutput = $true
    $objStartInfo.RedirectStandardError = $true
    $objStartInfo.RedirectStandardInput = $boolHasInput
    foreach ($strArgument in $ArgumentList) {
        $objStartInfo.ArgumentList.Add($strArgument)
    }
    $objProcess = [Diagnostics.Process]::new()
    $objProcess.StartInfo = $objStartInfo
    $boolStarted = $false
    $arrPipe = @()
    try {
        $objStopwatch = [Diagnostics.Stopwatch]::StartNew()
        $boolStarted = $objProcess.Start()
        if (-not $boolStarted) { throw "Could not start $FileName." }
        $arrPipe = @(
            [pscustomobject]@{ Stream = $objProcess.StandardOutput.BaseStream; Limit = $MaximumBytes; Name = 'output'; Memory = [IO.MemoryStream]::new(); Buffer = [byte[]]::new(8192); Task = $null },
            [pscustomobject]@{ Stream = $objProcess.StandardError.BaseStream; Limit = 65536; Name = 'error output'; Memory = [IO.MemoryStream]::new(); Buffer = [byte[]]::new(8192); Task = $null }
        )
        foreach ($objPipe in $arrPipe) {
            $objPipe.Task = $objPipe.Stream.ReadAsync($objPipe.Buffer, 0, $objPipe.Buffer.Length)
        }
        $objInputTask = $null
        if ($boolHasInput) {
            $objInputTask = $objProcess.StandardInput.BaseStream.WriteAsync($InputBytes, 0, $InputBytes.Length)
        }
        while ($true) {
            if ($null -ne $objInputTask -and $objInputTask.IsCompleted) {
                $null = $objInputTask.GetAwaiter().GetResult()
                $objProcess.StandardInput.Close()
                $objInputTask = $null
            }
            foreach ($objPipe in $arrPipe) {
                if ($null -eq $objPipe.Task -or -not $objPipe.Task.IsCompleted) { continue }
                $intRead = $objPipe.Task.GetAwaiter().GetResult()
                if ($intRead -eq 0) {
                    $objPipe.Task = $null
                    continue
                }
                if ($objPipe.Memory.Length + $intRead -gt $objPipe.Limit) {
                    throw "$FileName $($objPipe.Name) exceeded $($objPipe.Limit) bytes."
                }
                $objPipe.Memory.Write($objPipe.Buffer, 0, $intRead)
                $objPipe.Task = $objPipe.Stream.ReadAsync($objPipe.Buffer, 0, $objPipe.Buffer.Length)
            }
            $listTask = [Collections.Generic.List[Threading.Tasks.Task]]::new()
            if ($null -ne $objInputTask) { $listTask.Add($objInputTask) }
            foreach ($objPipe in $arrPipe) {
                if ($null -ne $objPipe.Task) { $listTask.Add($objPipe.Task) }
            }
            if ($listTask.Count -eq 0) { break }
            $intRemainingMilliseconds = $TimeoutMilliseconds - [int] $objStopwatch.ElapsedMilliseconds
            if ($intRemainingMilliseconds -le 0 -or
                [Threading.Tasks.Task]::WaitAny($listTask.ToArray(), $intRemainingMilliseconds) -lt 0) {
                throw "$FileName exceeded its time limit."
            }
        }
        $intRemainingMilliseconds = $TimeoutMilliseconds - [int] $objStopwatch.ElapsedMilliseconds
        if ($intRemainingMilliseconds -le 0 -or -not $objProcess.WaitForExit($intRemainingMilliseconds)) {
            throw "$FileName exceeded its time limit."
        }
        return [pscustomobject]@{
            ExitCode = $objProcess.ExitCode
            Bytes = $arrPipe[0].Memory.ToArray()
            Error = [Text.Encoding]::UTF8.GetString($arrPipe[1].Memory.ToArray())
        }
    } catch {
        if ($boolStarted -and -not $objProcess.HasExited) {
            $objProcess.Kill($true)
            if (-not $objProcess.WaitForExit(5000)) {
                throw "$FileName could not be reaped after termination."
            }
        }
        throw
    } finally {
        foreach ($objPipe in $arrPipe) {
            if ($null -ne $objPipe.Memory) { $objPipe.Memory.Dispose() }
        }
        $objProcess.Dispose()
    }
}

function ConvertFrom-StrictUtf8Text {
    # .SYNOPSIS
    # Decodes bytes as strict UTF-8 text.
    #
    # .DESCRIPTION
    # Rejects a byte-order mark, prohibited control bytes, carriage returns,
    # and invalid UTF-8 before returning decoded text.
    #
    # .PARAMETER Bytes
    # The byte sequence to validate and decode. An empty sequence is permitted.
    #
    # .PARAMETER Name
    # The diagnostic name for the byte sequence.
    #
    # .PARAMETER AllowNul
    # Permits NUL separators for bounded Git path-list output.
    #
    # .EXAMPLE
    # ConvertFrom-StrictUtf8Text -Bytes $arrBytes -Name 'manifest'
    #
    # # Returns strict decoded text.
    #
    # .INPUTS
    # None. This helper does not accept pipeline input.
    #
    # .OUTPUTS
    # [System.String] The decoded text.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20260914.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][AllowEmptyCollection()][byte[]] $Bytes,
        [Parameter(Mandatory)][string] $Name,
        [Parameter()][switch] $AllowNul
    )

    if ($Bytes.Length -ge 3 -and $Bytes[0] -eq 0xEF -and
        $Bytes[1] -eq 0xBB -and $Bytes[2] -eq 0xBF) {
        throw "$Name must not contain a UTF-8 byte-order mark."
    }
    foreach ($byteValue in $Bytes) {
        if (($byteValue -lt 0x20 -and
                $byteValue -notin @(0x09, 0x0A) -and
                -not ($AllowNul -and $byteValue -eq 0x00)) -or
            $byteValue -eq 0x7F -or $byteValue -eq 0x0D) {
            throw "$Name contains a prohibited control byte or non-LF newline."
        }
    }
    try {
        return [Text.UTF8Encoding]::new($false, $true).GetString($Bytes)
    } catch {
        throw "$Name is not strict UTF-8."
    }
}

function Read-GitBlobByte {
    # .SYNOPSIS
    # Reads one exact Git blob within a byte limit.
    #
    # .DESCRIPTION
    # Verifies the object size before reading it. A verified zero-byte blob
    # returns an explicit empty byte array without calling the positive-limit
    # process helper.
    #
    # .PARAMETER RepositoryRootPath
    # The repository that contains the blob object.
    #
    # .PARAMETER BlobId
    # The full exact Git blob object ID.
    #
    # .PARAMETER MaximumBytes
    # The maximum permitted blob byte count, including zero.
    #
    # .EXAMPLE
    # Read-GitBlobByte -RepositoryRootPath $strRoot -BlobId $strBlob `
    #     -MaximumBytes 65536
    #
    # # Returns the exact blob bytes.
    #
    # .INPUTS
    # None. This helper does not accept pipeline input.
    #
    # .OUTPUTS
    # [System.Byte] Zero or more bytes from the exact blob.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20260914.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([byte])]
    param(
        [Parameter(Mandatory)][string] $RepositoryRootPath,
        [Parameter(Mandatory)][string] $BlobId,
        [Parameter(Mandatory)][int] $MaximumBytes
    )

    $objSizeResult = Invoke-BoundedProcessByte -FileName 'git' `
        -ArgumentList @('-C', $RepositoryRootPath, 'cat-file', '-s', $BlobId) `
        -MaximumBytes 32
    $strSize = [Text.Encoding]::ASCII.GetString($objSizeResult.Bytes).Trim()
    $intSize = 0
    if ($objSizeResult.ExitCode -ne 0 -or
        -not [int]::TryParse($strSize, [ref] $intSize) -or
        $intSize -lt 0 -or
        $intSize -gt $MaximumBytes) {
        throw "Authorized blob $BlobId exceeds its byte limit."
    }
    if ($intSize -eq 0) {
        return [byte[]]::new(0)
    }
    $objResult = Invoke-BoundedProcessByte -FileName 'git' `
        -ArgumentList @('-C', $RepositoryRootPath, 'cat-file', 'blob', $BlobId) `
        -MaximumBytes $intSize
    if ($objResult.ExitCode -ne 0) {
        throw "Could not read authorized blob $BlobId."
    }
    return [byte[]] $objResult.Bytes
}

function Assert-NoDuplicateJsonProperty {
    # .SYNOPSIS
    # Rejects duplicate JSON object properties recursively.
    #
    # .DESCRIPTION
    # Walks one parsed JSON element and throws when an object contains the same
    # property name more than once under ordinal comparison.
    #
    # .PARAMETER Element
    # The JSON element to inspect recursively.
    #
    # .EXAMPLE
    # Assert-NoDuplicateJsonProperty -Element $objDocument.RootElement
    #
    # # Returns only when the JSON property inventory is unique.
    #
    # .INPUTS
    # None. This helper does not accept pipeline input.
    #
    # .OUTPUTS
    # None. This helper returns no output.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20260914.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param([Parameter(Mandatory)][System.Text.Json.JsonElement] $Element)

    if ($Element.ValueKind -eq [System.Text.Json.JsonValueKind]::Object) {
        $setNames = [Collections.Generic.HashSet[string]]::new(
            [StringComparer]::Ordinal
        )
        foreach ($objProperty in $Element.EnumerateObject()) {
            if (-not $setNames.Add($objProperty.Name)) {
                throw "Authorization JSON contains duplicate property $($objProperty.Name)."
            }
            Assert-NoDuplicateJsonProperty -Element $objProperty.Value
        }
    } elseif ($Element.ValueKind -eq [System.Text.Json.JsonValueKind]::Array) {
        foreach ($objItem in $Element.EnumerateArray()) {
            Assert-NoDuplicateJsonProperty -Element $objItem
        }
    }
}

function Assert-ExactPropertySet {
    # .SYNOPSIS
    # Requires one object to have an exact property set.
    #
    # .DESCRIPTION
    # Compares actual and expected property names with ordinal values after
    # sorting and throws when a property is missing or unexpected.
    #
    # .PARAMETER InputObject
    # The object whose properties are inspected.
    #
    # .PARAMETER PropertyName
    # The complete expected property-name set.
    #
    # .PARAMETER Name
    # The diagnostic name for the inspected object.
    #
    # .EXAMPLE
    # Assert-ExactPropertySet -InputObject $objValue `
    #     -PropertyName @('a', 'b') -Name 'value'
    #
    # # Returns only when the property set is exact.
    #
    # .INPUTS
    # None. This helper does not accept pipeline input.
    #
    # .OUTPUTS
    # None. This helper returns no output.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20260914.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)][object] $InputObject,
        [Parameter(Mandatory)][string[]] $PropertyName,
        [Parameter(Mandatory)][string] $Name
    )

    $arrActual = @($InputObject.PSObject.Properties.Name | Sort-Object)
    $arrExpected = @($PropertyName | Sort-Object)
    if ($arrActual.Count -ne $arrExpected.Count -or
        [string]::Join("`n", $arrActual) -cne
            [string]::Join("`n", $arrExpected)) {
        throw "$Name has an unexpected property set."
    }
}

$script:scriptblockConvertFromStrictJsonHashtable = {
    # .SYNOPSIS
    # Parses one JSON text as a dictionary with unique properties.
    # .DESCRIPTION
    # Uses the trusted JSON parser to reject duplicate properties recursively,
    # then returns dictionaries that preserve otherwise-valid empty-name keys.
    # .PARAMETER Text
    # The inert JSON text to parse.
    # .PARAMETER Name
    # The diagnostic name for the JSON value.
    # .EXAMPLE
    # ConvertFrom-StrictJsonHashtable -Text '{"value":1}' -Name 'fixture'
    #
    # # Returns one dictionary.
    # .INPUTS
    # None. This helper does not accept pipeline input.
    # .OUTPUTS
    # [System.Collections.IDictionary] The parsed JSON dictionary.
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20260903.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([Collections.IDictionary])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Text,
        [Parameter(Mandatory)][string] $Name
    )

    $objJsonDocument = $null
    try {
        $objJsonDocument = [System.Text.Json.JsonDocument]::Parse($Text)
        Assert-NoDuplicateJsonProperty -Element $objJsonDocument.RootElement
        $objValue = ConvertFrom-Json -InputObject $Text -AsHashtable
        if ($objValue -isnot [Collections.IDictionary]) {
            throw "$Name must be one JSON object."
        }
        return $objValue
    } catch {
        throw "$Name is malformed JSON."
    } finally {
        if ($null -ne $objJsonDocument) {
            $objJsonDocument.Dispose()
        }
    }
}

$script:scriptblockAssertExactDictionaryKeySet = {
    # .SYNOPSIS
    # Requires one dictionary to have an exact ordinal key set.
    # .DESCRIPTION
    # Sorts the actual and expected string keys with ordinal comparison and
    # rejects missing, duplicate, non-string, or unexpected keys.
    # .PARAMETER Dictionary
    # The dictionary whose keys are inspected.
    # .PARAMETER Key
    # The complete expected string-key set.
    # .PARAMETER Name
    # The diagnostic name for the dictionary.
    # .EXAMPLE
    # Assert-ExactDictionaryKeySet -Dictionary $objValue -Key @('a') `
    #     -Name 'value'
    #
    # # Returns only when the key set is exact.
    # .INPUTS
    # None. This helper does not accept pipeline input.
    # .OUTPUTS
    # None. This helper returns no output.
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.1.20260914.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)][Collections.IDictionary] $Dictionary,
        [Parameter(Mandatory)][AllowEmptyCollection()][string[]] $Key,
        [Parameter(Mandatory)][string] $Name
    )

    $arrActual = [string[]] @($Dictionary.Keys)
    $arrExpected = [string[]] @($Key)
    [Array]::Sort($arrActual, [StringComparer]::Ordinal)
    [Array]::Sort($arrExpected, [StringComparer]::Ordinal)
    if ($arrActual.Count -ne $arrExpected.Count -or
        -not [StringComparer]::Ordinal.Equals(
            [string]::Join("`n", $arrActual),
            [string]::Join("`n", $arrExpected))) {
        throw "$Name has an unexpected key set."
    }
}

$script:scriptblockConvertToCanonicalJsonText = {
    # .SYNOPSIS
    # Serializes one parsed JSON value with recursively sorted object keys.
    # .DESCRIPTION
    # Emits a deterministic compact JSON representation for dictionaries,
    # arrays, strings, Boolean values, and JSON numbers parsed by PowerShell.
    # .PARAMETER Value
    # The parsed JSON value to serialize.
    # .EXAMPLE
    # ConvertTo-CanonicalJsonText -Value ([ordered]@{ value = 1 })
    #
    # # Returns {"value":1}.
    # .INPUTS
    # None. This helper does not accept pipeline input.
    # .OUTPUTS
    # [System.String] The compact canonical JSON text.
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.1.20260914.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param([Parameter()][AllowNull()][object] $Value)

    if ($null -eq $Value) {
        return 'null'
    }
    if ($Value -is [System.Text.Json.JsonElement]) {
        if ($Value.ValueKind -eq [System.Text.Json.JsonValueKind]::Object) {
            [System.Text.Json.JsonProperty[]] $arrProperties =
                @($Value.EnumerateObject())
            [Array]::Sort(
                $arrProperties,
                [Comparison[System.Text.Json.JsonProperty]] {
                    param($objLeft, $objRight)
                    [StringComparer]::Ordinal.Compare(
                        $objLeft.Name,
                        $objRight.Name
                    )
                }
            )
            [string[]] $arrMembers = @(
                foreach ($objProperty in $arrProperties) {
                    $strEncodedKey =
                        [System.Text.Json.JsonSerializer]::Serialize(
                            [object] $objProperty.Name,
                            [string],
                            $script:objCanonicalJsonOptions
                        )
                    $strEncodedValue =
                        & $script:scriptblockConvertToCanonicalJsonText `
                        -Value $objProperty.Value
                    $strEncodedKey + ':' + $strEncodedValue
                }
            )
            return '{' + [string]::Join(',', [string[]] $arrMembers) + '}'
        }
        if ($Value.ValueKind -eq [System.Text.Json.JsonValueKind]::Array) {
            [string[]] $arrItems = @(
                foreach ($objItem in $Value.EnumerateArray()) {
                    & $script:scriptblockConvertToCanonicalJsonText `
                        -Value $objItem
                }
            )
            return '[' + [string]::Join(',', [string[]] $arrItems) + ']'
        }
        if ($Value.ValueKind -eq [System.Text.Json.JsonValueKind]::String) {
            return [System.Text.Json.JsonSerializer]::Serialize(
                [object] $Value.GetString(),
                [string],
                $script:objCanonicalJsonOptions
            )
        }
        if ($Value.ValueKind -eq [System.Text.Json.JsonValueKind]::Number) {
            return $Value.GetRawText()
        }
        if ($Value.ValueKind -eq [System.Text.Json.JsonValueKind]::True) {
            return 'true'
        }
        if ($Value.ValueKind -eq [System.Text.Json.JsonValueKind]::False) {
            return 'false'
        }
        if ($Value.ValueKind -eq [System.Text.Json.JsonValueKind]::Null) {
            return 'null'
        }
        throw 'Canonical JSON received an unsupported JSON value kind.'
    }
    if ($Value -is [Collections.IDictionary]) {
        $arrKeys = [string[]] @($Value.Keys)
        [Array]::Sort($arrKeys, [StringComparer]::Ordinal)
        $arrMembers = @(foreach ($strKey in $arrKeys) {
            $strEncodedKey = [System.Text.Json.JsonSerializer]::Serialize(
                [object] ([string] $strKey),
                [string],
                $script:objCanonicalJsonOptions
            )
            $strEncodedValue =
                & $script:scriptblockConvertToCanonicalJsonText `
                    -Value $Value[$strKey]
            $strEncodedKey + ':' + $strEncodedValue
        })
        return '{' + [string]::Join(',', [string[]] $arrMembers) + '}'
    }
    if ($Value -is [Collections.IEnumerable] -and
        $Value -isnot [string]) {
        $arrItems = @(foreach ($objItem in $Value) {
            & $script:scriptblockConvertToCanonicalJsonText -Value $objItem
        })
        return '[' + [string]::Join(',', [string[]] $arrItems) + ']'
    }
    if ($Value -is [string]) {
        return [System.Text.Json.JsonSerializer]::Serialize(
            [object] ([string] $Value),
            [string],
            $script:objCanonicalJsonOptions
        )
    }
    if ($Value -is [bool]) {
        if ($Value) {
            return 'true'
        }
        return 'false'
    }
    if ($Value -is [byte] -or $Value -is [sbyte] -or
        $Value -is [int16] -or $Value -is [uint16] -or
        $Value -is [int32] -or $Value -is [uint32] -or
        $Value -is [int64] -or $Value -is [uint64] -or
        $Value -is [single] -or $Value -is [double] -or
        $Value -is [decimal]) {
        return [Convert]::ToString(
            $Value,
            [Globalization.CultureInfo]::InvariantCulture
        )
    }
    throw 'Canonical JSON received an unsupported value type.'
}

function Assert-CandidateSyntax {
    # .SYNOPSIS
    # Validates candidate text for its declared syntax class.
    #
    # .DESCRIPTION
    # Parses PowerShell, JavaScript, YAML, or JSON candidate text with trusted
    # parsers. Markdown is accepted as inert text, and unknown classes fail.
    #
    # .PARAMETER Syntax
    # The declared syntax class: powershell, javascript, yaml, or markdown.
    #
    # .PARAMETER Text
    # The strict UTF-8 candidate text to parse.
    #
    # .PARAMETER Path
    # The repository-relative path used in diagnostics and parser context.
    #
    # .EXAMPLE
    # Assert-CandidateSyntax -Syntax 'powershell' -Text $strText -Path $strPath
    #
    # # Returns only when the declared syntax is valid.
    #
    # .INPUTS
    # None. This helper does not accept pipeline input.
    #
    # .OUTPUTS
    # None. This helper returns no output.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20260914.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)][string] $Syntax,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Text,
        [Parameter(Mandatory)][string] $Path
    )

    if ($Syntax -ceq 'powershell') {
        $objTokens = $null
        $arrErrors = $null
        [void] [Management.Automation.Language.Parser]::ParseInput(
            $Text,
            $Path,
            [ref] $objTokens,
            [ref] $arrErrors
        )
        if ($arrErrors.Count -gt 0) {
            throw "$Path has invalid PowerShell syntax."
        }
        return
    }
    if ($Syntax -ceq 'javascript') {
        $objStartInfo = [Diagnostics.ProcessStartInfo]::new('node')
        $objStartInfo.UseShellExecute = $false
        $objStartInfo.CreateNoWindow = $true
        $objStartInfo.RedirectStandardInput = $true
        $objStartInfo.RedirectStandardOutput = $true
        $objStartInfo.RedirectStandardError = $true
        $objStartInfo.ArgumentList.Add('--input-type=module')
        $objStartInfo.ArgumentList.Add('--check')
        $objProcess = [Diagnostics.Process]::new()
        $objProcess.StartInfo = $objStartInfo
        if (-not $objProcess.Start()) {
            throw 'Could not start the trusted JavaScript parser.'
        }
        $objOutputTask = $objProcess.StandardOutput.ReadToEndAsync()
        $objErrorTask = $objProcess.StandardError.ReadToEndAsync()
        $objProcess.StandardInput.Write($Text)
        $objProcess.StandardInput.Close()
        if (-not $objProcess.WaitForExit(10000)) {
            $objProcess.Kill($true)
            throw 'The trusted JavaScript parser exceeded its time limit.'
        }
        $strOutput = $objOutputTask.GetAwaiter().GetResult()
        $strError = $objErrorTask.GetAwaiter().GetResult()
        if ([Text.Encoding]::UTF8.GetByteCount($strOutput + $strError) -gt
            65536) {
            throw 'The trusted JavaScript parser output exceeded 65536 bytes.'
        }
        if ($objProcess.ExitCode -ne 0) {
            throw "$Path has invalid JavaScript syntax."
        }
        return
    }
    if ($Syntax -ceq 'yaml') {
        $strNodeSource = @'
const yaml = require('js-yaml');
let input = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => { input += chunk; });
process.stdin.on('end', () => {
  yaml.load(input, { schema: yaml.FAILSAFE_SCHEMA, json: false });
});
'@
        $objStartInfo = [Diagnostics.ProcessStartInfo]::new('node')
        $objStartInfo.UseShellExecute = $false
        $objStartInfo.CreateNoWindow = $true
        $objStartInfo.RedirectStandardInput = $true
        $objStartInfo.RedirectStandardOutput = $true
        $objStartInfo.RedirectStandardError = $true
        $objStartInfo.ArgumentList.Add('-e')
        $objStartInfo.ArgumentList.Add($strNodeSource)
        $objProcess = [Diagnostics.Process]::new()
        $objProcess.StartInfo = $objStartInfo
        if (-not $objProcess.Start()) {
            throw 'Could not start the trusted YAML parser.'
        }
        $objOutputTask = $objProcess.StandardOutput.ReadToEndAsync()
        $objErrorTask = $objProcess.StandardError.ReadToEndAsync()
        $objProcess.StandardInput.Write($Text)
        $objProcess.StandardInput.Close()
        if (-not $objProcess.WaitForExit(10000)) {
            $objProcess.Kill($true)
            throw 'The trusted YAML parser exceeded its time limit.'
        }
        $strOutput = $objOutputTask.GetAwaiter().GetResult()
        $strError = $objErrorTask.GetAwaiter().GetResult()
        if ([Text.Encoding]::UTF8.GetByteCount($strOutput + $strError) -gt 65536) {
            throw 'The trusted YAML parser output exceeded 65536 bytes.'
        }
        if ($objProcess.ExitCode -ne 0) {
            throw "$Path has invalid YAML syntax."
        }
        return
    }
    if ($Syntax -ceq 'json') {
        $objJsonDocument = $null
        try {
            $objJsonDocument = [System.Text.Json.JsonDocument]::Parse($Text)
            Assert-NoDuplicateJsonProperty -Element $objJsonDocument.RootElement
            [void] (ConvertFrom-Json -InputObject $Text -AsHashtable)
        } catch {
            throw "$Path has invalid JSON syntax."
        } finally {
            if ($null -ne $objJsonDocument) {
                $objJsonDocument.Dispose()
            }
        }
        return
    }
    if ($Syntax -cne 'markdown') {
        throw "$Path declares an unsupported syntax class."
    }
}

function Get-OrdinaryHelperStructure {
    # .SYNOPSIS
    # Describes one inert Add-ProposedBlob helper without resolving types.
    #
    # .DESCRIPTION
    # Parses fixed-scope ASCII source. Retains exact significant tokens, token
    # flags, and every AST node's kind, parent and token interval. Only complete
    # single-line comments and layout can differ. Script requirements and
    # signatures are forbidden. The sole OutputType attribute must use the
    # exact truthful static form; only a historical trusted input can omit int.
    # No AST StaticType, reflection type, GetScriptBlock or candidate execution
    # is used. A signature describes syntax, not arbitrary semantic equivalence.
    #
    # .PARAMETER Text
    # The complete fixed helper extent, decoded from bounded strict UTF-8.
    #
    # .PARAMETER HistoricalTrustedInput
    # Allows the previously published incomplete OutputType on the trusted side.
    #
    # .EXAMPLE
    # Get-OrdinaryHelperStructure -Text $strHelper
    #
    # # Returns one structural signature, or throws for unsupported syntax.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # [string] The deterministic token and parse-tree signature.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20260915.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $Text,
        [Parameter()][switch] $HistoricalTrustedInput
    )

    if ($Text -cmatch '[^\x20-\x7e\n]' -or $Text.Length -gt 131072) {
        throw 'The ordinary helper must be bounded ASCII and LF text.'
    }
    $arrTokens = $null
    $arrErrors = $null
    $objRoot = [Management.Automation.Language.Parser]::ParseInput(
        $Text, [ref]$arrTokens, [ref]$arrErrors)
    if ($arrTokens.Count -gt 8192) {
        throw 'The ordinary helper exceeds the 8192-token parser bound.'
    }
    if ($arrErrors.Count -ne 0 -or $null -ne $objRoot.ScriptRequirements -or
        $null -eq $objRoot.EndBlock -or $objRoot.EndBlock.Statements.Count -ne 1 -or
        $objRoot.EndBlock.Statements[0] -isnot
        [Management.Automation.Language.FunctionDefinitionAst] -or
        $objRoot.EndBlock.Statements[0].Name -cne 'Add-ProposedBlob') {
        throw 'The ordinary helper has unsupported scope, requirements or parser errors.'
    }
    $objFunction = $objRoot.EndBlock.Statements[0]
    $arrFunctions = @($objRoot.FindAll({ param($objNode)
                $objNode -is [Management.Automation.Language.FunctionDefinitionAst]
            }, $true))
    if ($arrFunctions.Count -ne 1 -or $null -eq $objFunction.Body.ParamBlock) {
        throw 'The ordinary helper contains an extra function or no parameter block.'
    }
    $arrOutputAttributes = @($objFunction.Body.ParamBlock.Attributes | Where-Object {
            $_.TypeName.FullName -ceq 'OutputType'
        })
    if ($arrOutputAttributes.Count -ne 1) {
        throw 'The ordinary helper requires one exact static OutputType attribute.'
    }
    $objOutputAttribute = $arrOutputAttributes[0]
    $strOutputText = $objOutputAttribute.Extent.Text
    if ($strOutputText -cne '[OutputType([long], [int])]' -and
        (-not $HistoricalTrustedInput -or $strOutputText -cne '[OutputType([long])]')) {
        throw 'The ordinary helper requires the truthful static OutputType form.'
    }
    $listTokens = [Collections.Generic.List[Management.Automation.Language.Token]]::new()
    $listSignature = [Collections.Generic.List[string]]::new()
    foreach ($objToken in $arrTokens) {
        if ($objToken.Kind -eq [Management.Automation.Language.TokenKind]::Comment) {
            $intLineStart = $Text.LastIndexOf("`n", [Math]::Max(0, $objToken.Extent.StartOffset - 1)) + 1
            $strPrefix = $Text.Substring($intLineStart, $objToken.Extent.StartOffset - $intLineStart)
            if ($strPrefix.Trim(' ').Length -ne 0 -or
                -not $objToken.Text.StartsWith('#', [StringComparison]::Ordinal) -or
                $objToken.Text -imatch '^#(?:!|\s*(?:requires\b|SIG\b))') {
                throw 'The ordinary helper contains an unsupported comment or signature directive.'
            }
            continue
        }
        if ($objToken.Extent.StartOffset -ge $objOutputAttribute.Extent.StartOffset -and
            $objToken.Extent.EndOffset -le $objOutputAttribute.Extent.EndOffset) {
            continue
        }
        if ($objToken.Kind -in @(
                [Management.Automation.Language.TokenKind]::NewLine,
                [Management.Automation.Language.TokenKind]::LineContinuation,
                [Management.Automation.Language.TokenKind]::EndOfInput)) {
            continue
        }
        $listTokens.Add($objToken)
        $listSignature.Add(('{0}:{1}:{2}:{3}' -f
                [int]$objToken.Kind, [int]$objToken.TokenFlags,
                $objToken.Text.Length, $objToken.Text))
    }
    $arrNodes = @($objRoot.FindAll({ param($objNode) $null -ne $objNode }, $true) |
            Where-Object {
                -not ($_.Extent.StartOffset -ge $objOutputAttribute.Extent.StartOffset -and
                    $_.Extent.EndOffset -le $objOutputAttribute.Extent.EndOffset)
            })
    if ($arrNodes.Count -gt 4096) {
        throw 'The ordinary helper exceeds the 4096-node parser bound.'
    }
    $dictionaryNodeIndex = [Collections.Generic.Dictionary[Management.Automation.Language.Ast, int]]::new(
        [Collections.Generic.ReferenceEqualityComparer]::Instance)
    for ($intIndex = 0; $intIndex -lt $arrNodes.Count; $intIndex++) {
        $dictionaryNodeIndex.Add($arrNodes[$intIndex], $intIndex)
    }
    for ($intNodeIndex = 0; $intNodeIndex -lt $arrNodes.Count; $intNodeIndex++) {
        $objNode = $arrNodes[$intNodeIndex]
        $intParentIndex = -1
        if ($null -ne $objNode.Parent -and $dictionaryNodeIndex.ContainsKey($objNode.Parent)) {
            $intParentIndex = $dictionaryNodeIndex[$objNode.Parent]
        }
        # Token offsets are ordered. Binary searches avoid quadratic work on
        # hostile, still byte-bounded source without changing the signature.
        $intFirstToken = 0
        $intUpper = $listTokens.Count
        while ($intFirstToken -lt $intUpper) {
            $intMiddle = [int][Math]::Floor(($intFirstToken + $intUpper) / 2)
            if ($listTokens[$intMiddle].Extent.StartOffset -lt $objNode.Extent.StartOffset) {
                $intFirstToken = $intMiddle + 1
            } else {
                $intUpper = $intMiddle
            }
        }
        $intLastToken = 0
        $intUpper = $listTokens.Count
        while ($intLastToken -lt $intUpper) {
            $intMiddle = [int][Math]::Floor(($intLastToken + $intUpper) / 2)
            if ($listTokens[$intMiddle].Extent.EndOffset -le $objNode.Extent.EndOffset) {
                $intLastToken = $intMiddle + 1
            } else {
                $intUpper = $intMiddle
            }
        }
        $listSignature.Add(('{0}:{1}:{2}:{3}' -f $objNode.GetType().FullName,
                $intParentIndex, $intFirstToken, $intLastToken))
    }
    return [string]::Join("`n", $listSignature)
}


function Assert-OrdinaryHelperWorkflow {
    # .SYNOPSIS
    # Validates the fixed identity workflow's inert helper presentation domain.
    #
    # .DESCRIPTION
    # Requires byte-identical workflow content outside one complete helper.
    # Compares trusted parser structure inside it, then derives the acquire
    # block digest from the exact candidate block. Never executes candidate code.
    #
    # .PARAMETER TrustedText
    # Exact bounded workflow text from the authenticated trusted Git revision.
    #
    # .PARAMETER CandidateText
    # Exact bounded workflow text from the proposed Git revision.
    #
    # .EXAMPLE
    # Assert-OrdinaryHelperWorkflow -TrustedText $strTrusted -CandidateText $strCandidate
    #
    # # Returns the candidate acquire SHA-256 or throws for an unsupported edit.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # [string] Lowercase acquire run-block SHA-256, not merge approval.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20260915.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $TrustedText,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $CandidateText
    )

    # GitHub evaluates expressions before PowerShell tokenizes even comments.
    if ($CandidateText.Contains('${{', [StringComparison]::Ordinal)) {
        throw 'The ordinary workflow must not contain GitHub expressions.'
    }
    $strStart = '          function Add-ProposedBlob {' + "`n"
    $strEnd = '          & $strGitPath --no-replace-objects -c core.fsmonitor=false init --quiet .' + "`n"
    $listParts = [Collections.Generic.List[pscustomobject]]::new()
    foreach ($strText in @($TrustedText, $CandidateText)) {
        $intStart = $strText.IndexOf($strStart, [StringComparison]::Ordinal)
        $intEnd = $strText.IndexOf($strEnd, [StringComparison]::Ordinal)
        if ($intStart -lt 0 -or $intEnd -le $intStart -or
            $strText.LastIndexOf($strStart, [StringComparison]::Ordinal) -ne $intStart -or
            $strText.LastIndexOf($strEnd, [StringComparison]::Ordinal) -ne $intEnd) {
            throw 'The ordinary workflow has ambiguous or missing helper boundaries.'
        }
        $listParts.Add([pscustomobject]@{
                Prefix = $strText.Substring(0, $intStart)
                Helper = $strText.Substring($intStart, $intEnd - $intStart)
                Suffix = $strText.Substring($intEnd)
            })
    }
    if ($listParts[0].Prefix -cne $listParts[1].Prefix -or
        $listParts[0].Suffix -cne $listParts[1].Suffix) {
        throw 'The ordinary workflow changes non-helper bytes.'
    }
    $strTrustedStructure = Get-OrdinaryHelperStructure -Text $listParts[0].Helper -HistoricalTrustedInput
    $strCandidateStructure = Get-OrdinaryHelperStructure -Text $listParts[1].Helper
    if (-not [StringComparer]::Ordinal.Equals($strTrustedStructure, $strCandidateStructure)) {
        throw 'The ordinary helper changes significant tokens or parsed structure.'
    }
    $strRunStart = '        run: |' + "`n"
    $intRunStart = $CandidateText.IndexOf($strRunStart, [StringComparison]::Ordinal)
    $intRunEnd = $CandidateText.IndexOf("`n      - name:", $intRunStart, [StringComparison]::Ordinal)
    if ($intRunStart -lt 0 -or $intRunEnd -le $intRunStart) {
        throw 'The ordinary workflow acquisition block is unavailable.'
    }
    $strRun = $CandidateText.Substring($intRunStart + $strRunStart.Length,
        $intRunEnd - $intRunStart - $strRunStart.Length).TrimEnd("`n") + "`n"
    $listLines = [Collections.Generic.List[string]]::new()
    foreach ($strLine in $strRun.Split("`n")) {
        if ($strLine.Length -gt 0 -and -not $strLine.StartsWith('          ', [StringComparison]::Ordinal)) {
            throw 'The ordinary workflow acquisition indentation is invalid.'
        }
        $listLines.Add($(if ($strLine.Length -eq 0) { '' } else { $strLine.Substring(10) }))
    }
    return [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData(
            [Text.UTF8Encoding]::new($false).GetBytes([string]::Join("`n", $listLines))
        )).ToLowerInvariant()
}


# The supported generator-result domain is a directional source language, not
# a list of candidate identities. These complete reviewed regions are inert
# recognition data. Every executable byte outside them must remain unchanged.
$script:arrGeneratorResultSourceShape = @(
    # Complete reviewed region 1; no candidate-selected code is evaluated.
    @{
        Before = @'
  }
}

function validateRunStep(step, expectedStep, contract) {
  const expectedKeys = ['name', 'shell', 'run'];
  if (expectedStep.id !== undefined) expectedKeys.push('id');
'@
        After = @'
  }
}

const GENERATOR_RESULT_PREDICATES = Object.freeze([
  ['NativeExit', '$intGeneratorExit -isnot [int] -or $intGeneratorExit -ne 0'],
  ['Schema', "$objResult.Schema -isnot [string] -or $objResult.Schema -cne 'PSStyleGuide.GeneratorResult.v2'"],
  ['GeneratorVersion', "$objResult.GeneratorVersion -isnot [string] -or $objResult.GeneratorVersion -cne '1.0.20260916.0'"],
  ['Overall', "$objResult.Overall -isnot [string] -or $objResult.Overall -notin @('Success', 'NoChange')"],
  ['Phase', "$objResult.Phase -isnot [string] -or $objResult.Phase -cne 'complete'"],
  ['Category', "$objResult.Category -isnot [string] -or $objResult.Category -cne 'none'"],
  ['NativeOutcome', "$objResult.NativeOutcome -isnot [string] -or $objResult.NativeOutcome -cne 'Success'"],
  ['ResultExitCode', '($objResult.ExitCode -isnot [int] -and $objResult.ExitCode -isnot [long]) -or $objResult.ExitCode -ne 0'],
]);
const GENERATOR_DIAGNOSTIC_PREFIX = 'Artifact generation failed result checks: ';

// This closed construction binds semantics before the run-byte digest. No
// caller value is used to form a name, separator or message. Exact tail shape
// also rejects interleaved early exits and additional output statements.
function validateGeneratorResultPolicy(source, contract) {
  if (typeof source !== 'string') fail('generator-result-source');
  const blocks = GENERATOR_RESULT_PREDICATES.map(([label, predicate]) => (
    `if (${predicate}) {\n    [void]($listFailedChecks.Add('${label}'))\n}\n`
  ));
  const positions = blocks.map((block, index) => {
    if (source.split(block).length - 1 !== 1) {
      fail(`generator-result-predicate-${GENERATOR_RESULT_PREDICATES[index][0]}`);
    }
    return source.indexOf(block);
  });
  if (positions.some((position, index) => index > 0 && position <= positions[index - 1])) {
    fail('generator-result-order');
  }
  const accumulator = '$listFailedChecks = [System.Collections.Generic.List[string]]::new()\n';
  const guard = 'if ($listFailedChecks.Count -ne 0) {\n';
  const output = `    throw ('${GENERATOR_DIAGNOSTIC_PREFIX}{0}.' -f ($listFailedChecks -join ', '))\n`;
  for (const [fragment, category] of [
    [accumulator, 'accumulator'], [guard, 'guard'], [output, 'output'],
  ]) {
    if (source.split(fragment).length - 1 !== 1) fail(`generator-result-${category}`);
  }
  const start = '$objResult = $arrResult[0] | ConvertFrom-Json\n';
  const comment = '# Only fixed labels enter this list; result values must never reach the diagnostic.\n';
  const tail = start + comment + accumulator + blocks.join('') + guard + output + '}\n';
  if (source.split(start).length - 1 !== 1 || source.slice(source.indexOf(start)) !== tail) {
    fail('generator-result-flow');
  }
  const labels = GENERATOR_RESULT_PREDICATES.map(([label]) => label);
  const maximumMessage = GENERATOR_DIAGNOSTIC_PREFIX + labels.join(', ') + '.';
  expectDeepEqual(contract.workflowPolicy.generatorResultPolicy, {
    labels,
    prefix: GENERATOR_DIAGNOSTIC_PREFIX,
    separator: ', ',
    suffix: '.',
    maximumAsciiBytes: Buffer.byteLength(maximumMessage, 'ascii'),
    actualValues: false,
  }, 'generator-result-contract');
  if (!/^[\x20-\x7e]+$/u.test(maximumMessage)) fail('generator-result-vocabulary');
}

function validateRunStep(step, expectedStep, contract) {
  const expectedKeys = ['name', 'shell', 'run'];
  if (expectedStep.id !== undefined) expectedKeys.push('id');
'@
    },
    # Complete reviewed region 2; no candidate-selected code is evaluated.
    @{
        Before = @'
  if (expectedStep.if !== undefined) expectedKeys.push('if');
  if (expectedStep.continueOnError !== undefined) expectedKeys.push('continue-on-error');
  expectExactKeys(step, expectedKeys, 'run-step-shape');
  if (
    step.name !== expectedStep.name
    || step.id !== expectedStep.id
'@
        After = @'
  if (expectedStep.if !== undefined) expectedKeys.push('if');
  if (expectedStep.continueOnError !== undefined) expectedKeys.push('continue-on-error');
  expectExactKeys(step, expectedKeys, 'run-step-shape');
  if (expectedStep.id === 'generate_style_guide_artifacts') {
    validateGeneratorResultPolicy(step.run, contract);
  }
  if (
    step.name !== expectedStep.name
    || step.id !== expectedStep.id
'@
    },
    # Complete reviewed region 3; no candidate-selected code is evaluated.
    @{
        Before = @'
  }
}

function runCaseCatalog(catalog, workflows, dependabot, contract) {
  expectExactKeys(catalog, ['schema', 'cases'], 'case-catalog');
  if (catalog.schema !== 'PSStyleGuide.WorkflowPolicyCases.v1' || !Array.isArray(catalog.cases)) {
'@
        After = @'
  }
}

function runCatalogCase(testCase, workflows, dependabot, contract) {
  // Category-qualified cases must prepare successfully. A bad pointer or
  // absent replacement needle cannot count as the intended policy rejection.
  let preparedWorkflow;
  if (testCase.expectedCategory !== undefined) {
    if (
      testCase.domain !== 'workflow'
      || testCase.expected !== false
      || typeof testCase.expectedCategory !== 'string'
      || !/^[A-Za-z0-9-]+$/u.test(testCase.expectedCategory)
    ) fail('case-category');
    preparedWorkflow = clone(workflows[testCase.workflow].value);
    applyOperation(preparedWorkflow, testCase.operation);
  }
  let observed = true;
  let observedCategory;
  try {
    if (testCase.domain === 'baseline') {
      for (const [fileName, workflow] of Object.entries(workflows)) {
        validateWorkflowObject(fileName, workflow.value, workflow.text, contract);
      }
      validateDependabot(dependabot, contract);
    } else if (testCase.domain === 'workflow') {
      const fixture = preparedWorkflow ?? clone(workflows[testCase.workflow].value);
      if (preparedWorkflow === undefined) applyOperation(fixture, testCase.operation);
      validateWorkflowObject(testCase.workflow, fixture, null, contract);
    } else if (testCase.domain === 'contract') {
      const fixture = clone(contract);
      applyOperation(fixture, testCase.operation);
      validateContract(fixture);
    } else if (testCase.domain === 'markdown-contract') {
      const fixture = clone(contract.markdownPolicy);
      applyOperation(fixture, testCase.operation);
      validateMarkdownContract(fixture);
    } else if (testCase.domain === 'dependabot') {
      const fixture = clone(dependabot);
      applyOperation(fixture, testCase.operation);
      validateDependabot(fixture, contract);
    } else {
      parseStrictYaml(Buffer.from(testCase.text, 'utf8'), contract.limits);
    }
  } catch (error) {
    if (!(error instanceof PolicyError)) throw error;
    observed = false;
    observedCategory = error.category;
  }
  if (observed !== testCase.expected) fail('case-result');
  if (testCase.expectedCategory !== undefined && observedCategory !== testCase.expectedCategory) {
    fail('case-category-result');
  }
}

function runCaseCatalog(catalog, workflows, dependabot, contract) {
  expectExactKeys(catalog, ['schema', 'cases'], 'case-catalog');
  if (catalog.schema !== 'PSStyleGuide.WorkflowPolicyCases.v1' || !Array.isArray(catalog.cases)) {
'@
    },
    # Complete reviewed region 4; no candidate-selected code is evaluated.
    @{
        Before = @'
    } else if (testCase.domain !== 'baseline') {
      fail('case-catalog');
    }
    let observed = true;
    try {
      if (testCase.domain === 'baseline') {
        for (const [fileName, workflow] of Object.entries(workflows)) {
          validateWorkflowObject(fileName, workflow.value, workflow.text, contract);
        }
        validateDependabot(dependabot, contract);
      } else if (testCase.domain === 'workflow') {
        const fixture = clone(workflows[testCase.workflow].value);
        applyOperation(fixture, testCase.operation);
        validateWorkflowObject(testCase.workflow, fixture, null, contract);
      } else if (testCase.domain === 'contract') {
        const fixture = clone(contract);
        applyOperation(fixture, testCase.operation);
        validateContract(fixture);
      } else if (testCase.domain === 'markdown-contract') {
        const fixture = clone(contract.markdownPolicy);
        applyOperation(fixture, testCase.operation);
        validateMarkdownContract(fixture);
      } else if (testCase.domain === 'dependabot') {
        const fixture = clone(dependabot);
        applyOperation(fixture, testCase.operation);
        validateDependabot(fixture, contract);
      } else {
        parseStrictYaml(Buffer.from(testCase.text, 'utf8'), contract.limits);
      }
    } catch (error) {
      if (!(error instanceof PolicyError)) throw error;
      observed = false;
    }
    if (observed !== testCase.expected) {
      fail('case-result');
    }
    passed += 1;
  }
  if (passed < MINIMUM_CASE_COUNT || identityCases !== REQUIRED_IDENTITY_CASE_COUNT) {
'@
        After = @'
    } else if (testCase.domain !== 'baseline') {
      fail('case-catalog');
    }
    runCatalogCase(testCase, workflows, dependabot, contract);
    passed += 1;
  }
  if (passed < MINIMUM_CASE_COUNT || identityCases !== REQUIRED_IDENTITY_CASE_COUNT) {
'@
    },
    # Complete reviewed region 5; no candidate-selected code is evaluated.
    @{
        Before = @'
  const reject = (candidate, category, runOutcomes = false) => {
    try {
      validateOrdinaryCasePreparation(candidate, catalog, workflows);
      if (runOutcomes) runCaseCatalog(candidate, workflows, dependabot, contract);
    } catch (error) {
      if (error instanceof PolicyError && error.category === category) return;
      throw error;
'@
        After = @'
  const reject = (candidate, category, runOutcomes = false) => {
    try {
      validateOrdinaryCasePreparation(candidate, catalog, workflows);
      if (runOutcomes) runCatalogCase(candidate.cases.at(-1), workflows, dependabot, contract);
    } catch (error) {
      if (error instanceof PolicyError && error.category === category) return;
      throw error;
'@
    },
    # Complete reviewed region 6; no candidate-selected code is evaluated.
    @{
        Before = @'
  };
  validateOrdinaryCasePreparation(catalog, catalog, workflows);
  validateOrdinaryCasePreparation(append(negative), catalog, workflows);
  runCaseCatalog(append(negative), workflows, dependabot, contract);
  for (const operation of [
    { type: 'replace', path: '/name', from: 'THIS_NEEDLE_IS_ABSENT', to: 'changed' },
    { type: 'replace', path: '/name', from: ' ', to: '-' },
'@
        After = @'
  };
  validateOrdinaryCasePreparation(catalog, catalog, workflows);
  validateOrdinaryCasePreparation(append(negative), catalog, workflows);
  runCatalogCase(negative, workflows, dependabot, contract);
  for (const operation of [
    { type: 'replace', path: '/name', from: 'THIS_NEEDLE_IS_ABSENT', to: 'changed' },
    { type: 'replace', path: '/name', from: ' ', to: '-' },
'@
    }
)
$script:strLegacyGeneratorResultTail = @'
          $objResult = $arrResult[0] | ConvertFrom-Json
          if ($intGeneratorExit -ne 0 -or
              $objResult.Schema -cne 'PSStyleGuide.GeneratorResult.v2' -or
              $objResult.GeneratorVersion -cne '1.0.20260916.0' -or
              $objResult.Overall -notin @('Success', 'NoChange')) {
              throw "Artifact generation failed with native exit $intGeneratorExit."
          }
'@
$script:strBoundedGeneratorResultTail = @'
          $objResult = $arrResult[0] | ConvertFrom-Json
          # Only fixed labels enter this list; result values must never reach the diagnostic.
          $listFailedChecks = [System.Collections.Generic.List[string]]::new()
          if ($intGeneratorExit -isnot [int] -or $intGeneratorExit -ne 0) {
              [void]($listFailedChecks.Add('NativeExit'))
          }
          if ($objResult.Schema -isnot [string] -or $objResult.Schema -cne 'PSStyleGuide.GeneratorResult.v2') {
              [void]($listFailedChecks.Add('Schema'))
          }
          if ($objResult.GeneratorVersion -isnot [string] -or $objResult.GeneratorVersion -cne '1.0.20260916.0') {
              [void]($listFailedChecks.Add('GeneratorVersion'))
          }
          if ($objResult.Overall -isnot [string] -or $objResult.Overall -notin @('Success', 'NoChange')) {
              [void]($listFailedChecks.Add('Overall'))
          }
          if ($objResult.Phase -isnot [string] -or $objResult.Phase -cne 'complete') {
              [void]($listFailedChecks.Add('Phase'))
          }
          if ($objResult.Category -isnot [string] -or $objResult.Category -cne 'none') {
              [void]($listFailedChecks.Add('Category'))
          }
          if ($objResult.NativeOutcome -isnot [string] -or $objResult.NativeOutcome -cne 'Success') {
              [void]($listFailedChecks.Add('NativeOutcome'))
          }
          if (($objResult.ExitCode -isnot [int] -and $objResult.ExitCode -isnot [long]) -or $objResult.ExitCode -ne 0) {
              [void]($listFailedChecks.Add('ResultExitCode'))
          }
          if ($listFailedChecks.Count -ne 0) {
              throw ('Artifact generation failed result checks: {0}.' -f ($listFailedChecks -join ', '))
          }
'@
$script:arrRequiredGeneratorResultCase = ConvertFrom-Json -AsHashtable -InputObject @'
[
  {
    "id": "PS-P1-WFPOL-065",
    "semanticKey": "generator-result-disabled-nativeexit",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "if ($intGeneratorExit -isnot [int] -or $intGeneratorExit -ne 0) {",
      "to": "if ($false) {"
    },
    "expected": false,
    "expectedCategory": "generator-result-predicate-NativeExit"
  },
  {
    "id": "PS-P1-WFPOL-066",
    "semanticKey": "generator-result-untyped-nativeexit",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "if ($intGeneratorExit -isnot [int] -or $intGeneratorExit -ne 0) {",
      "to": "if ($intGeneratorExit -ne 0) {"
    },
    "expected": false,
    "expectedCategory": "generator-result-predicate-NativeExit"
  },
  {
    "id": "PS-P1-WFPOL-067",
    "semanticKey": "generator-result-disabled-schema",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "if ($objResult.Schema -isnot [string] -or $objResult.Schema -cne 'PSStyleGuide.GeneratorResult.v2') {",
      "to": "if ($false) {"
    },
    "expected": false,
    "expectedCategory": "generator-result-predicate-Schema"
  },
  {
    "id": "PS-P1-WFPOL-068",
    "semanticKey": "generator-result-untyped-schema",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "if ($objResult.Schema -isnot [string] -or $objResult.Schema -cne 'PSStyleGuide.GeneratorResult.v2') {",
      "to": "if ($objResult.Schema -cne 'PSStyleGuide.GeneratorResult.v2') {"
    },
    "expected": false,
    "expectedCategory": "generator-result-predicate-Schema"
  },
  {
    "id": "PS-P1-WFPOL-069",
    "semanticKey": "generator-result-disabled-generatorversion",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "if ($objResult.GeneratorVersion -isnot [string] -or $objResult.GeneratorVersion -cne '1.0.20260916.0') {",
      "to": "if ($false) {"
    },
    "expected": false,
    "expectedCategory": "generator-result-predicate-GeneratorVersion"
  },
  {
    "id": "PS-P1-WFPOL-070",
    "semanticKey": "generator-result-untyped-generatorversion",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "if ($objResult.GeneratorVersion -isnot [string] -or $objResult.GeneratorVersion -cne '1.0.20260916.0') {",
      "to": "if ($objResult.GeneratorVersion -cne '1.0.20260916.0') {"
    },
    "expected": false,
    "expectedCategory": "generator-result-predicate-GeneratorVersion"
  },
  {
    "id": "PS-P1-WFPOL-071",
    "semanticKey": "generator-result-disabled-overall",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "if ($objResult.Overall -isnot [string] -or $objResult.Overall -notin @('Success', 'NoChange')) {",
      "to": "if ($false) {"
    },
    "expected": false,
    "expectedCategory": "generator-result-predicate-Overall"
  },
  {
    "id": "PS-P1-WFPOL-072",
    "semanticKey": "generator-result-untyped-overall",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "if ($objResult.Overall -isnot [string] -or $objResult.Overall -notin @('Success', 'NoChange')) {",
      "to": "if ($objResult.Overall -notin @('Success', 'NoChange')) {"
    },
    "expected": false,
    "expectedCategory": "generator-result-predicate-Overall"
  },
  {
    "id": "PS-P1-WFPOL-073",
    "semanticKey": "generator-result-disabled-phase",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "if ($objResult.Phase -isnot [string] -or $objResult.Phase -cne 'complete') {",
      "to": "if ($false) {"
    },
    "expected": false,
    "expectedCategory": "generator-result-predicate-Phase"
  },
  {
    "id": "PS-P1-WFPOL-074",
    "semanticKey": "generator-result-untyped-phase",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "if ($objResult.Phase -isnot [string] -or $objResult.Phase -cne 'complete') {",
      "to": "if ($objResult.Phase -cne 'complete') {"
    },
    "expected": false,
    "expectedCategory": "generator-result-predicate-Phase"
  },
  {
    "id": "PS-P1-WFPOL-075",
    "semanticKey": "generator-result-disabled-category",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "if ($objResult.Category -isnot [string] -or $objResult.Category -cne 'none') {",
      "to": "if ($false) {"
    },
    "expected": false,
    "expectedCategory": "generator-result-predicate-Category"
  },
  {
    "id": "PS-P1-WFPOL-076",
    "semanticKey": "generator-result-untyped-category",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "if ($objResult.Category -isnot [string] -or $objResult.Category -cne 'none') {",
      "to": "if ($objResult.Category -cne 'none') {"
    },
    "expected": false,
    "expectedCategory": "generator-result-predicate-Category"
  },
  {
    "id": "PS-P1-WFPOL-077",
    "semanticKey": "generator-result-disabled-nativeoutcome",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "if ($objResult.NativeOutcome -isnot [string] -or $objResult.NativeOutcome -cne 'Success') {",
      "to": "if ($false) {"
    },
    "expected": false,
    "expectedCategory": "generator-result-predicate-NativeOutcome"
  },
  {
    "id": "PS-P1-WFPOL-078",
    "semanticKey": "generator-result-untyped-nativeoutcome",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "if ($objResult.NativeOutcome -isnot [string] -or $objResult.NativeOutcome -cne 'Success') {",
      "to": "if ($objResult.NativeOutcome -cne 'Success') {"
    },
    "expected": false,
    "expectedCategory": "generator-result-predicate-NativeOutcome"
  },
  {
    "id": "PS-P1-WFPOL-079",
    "semanticKey": "generator-result-disabled-resultexitcode",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "if (($objResult.ExitCode -isnot [int] -and $objResult.ExitCode -isnot [long]) -or $objResult.ExitCode -ne 0) {",
      "to": "if ($false) {"
    },
    "expected": false,
    "expectedCategory": "generator-result-predicate-ResultExitCode"
  },
  {
    "id": "PS-P1-WFPOL-080",
    "semanticKey": "generator-result-untyped-resultexitcode",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "if (($objResult.ExitCode -isnot [int] -and $objResult.ExitCode -isnot [long]) -or $objResult.ExitCode -ne 0) {",
      "to": "if ($objResult.ExitCode -ne 0) {"
    },
    "expected": false,
    "expectedCategory": "generator-result-predicate-ResultExitCode"
  },
  {
    "id": "PS-P1-WFPOL-081",
    "semanticKey": "generator-result-omitted-schema",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "if ($objResult.Schema -isnot [string] -or $objResult.Schema -cne 'PSStyleGuide.GeneratorResult.v2') {\n    [void]($listFailedChecks.Add('Schema'))\n}\n",
      "to": ""
    },
    "expected": false,
    "expectedCategory": "generator-result-predicate-Schema"
  },
  {
    "id": "PS-P1-WFPOL-082",
    "semanticKey": "generator-result-reordered-predicates",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "if ($intGeneratorExit -isnot [int] -or $intGeneratorExit -ne 0) {\n    [void]($listFailedChecks.Add('NativeExit'))\n}\nif ($objResult.Schema -isnot [string] -or $objResult.Schema -cne 'PSStyleGuide.GeneratorResult.v2') {\n    [void]($listFailedChecks.Add('Schema'))\n}\n",
      "to": "if ($objResult.Schema -isnot [string] -or $objResult.Schema -cne 'PSStyleGuide.GeneratorResult.v2') {\n    [void]($listFailedChecks.Add('Schema'))\n}\nif ($intGeneratorExit -isnot [int] -or $intGeneratorExit -ne 0) {\n    [void]($listFailedChecks.Add('NativeExit'))\n}\n"
    },
    "expected": false,
    "expectedCategory": "generator-result-order"
  },
  {
    "id": "PS-P1-WFPOL-083",
    "semanticKey": "generator-result-disabled-guard",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "if ($listFailedChecks.Count -ne 0) {",
      "to": "if ($false) {"
    },
    "expected": false,
    "expectedCategory": "generator-result-guard"
  },
  {
    "id": "PS-P1-WFPOL-084",
    "semanticKey": "generator-result-untyped-accumulator",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "$listFailedChecks = [System.Collections.Generic.List[string]]::new()",
      "to": "$listFailedChecks = @()"
    },
    "expected": false,
    "expectedCategory": "generator-result-accumulator"
  },
  {
    "id": "PS-P1-WFPOL-085",
    "semanticKey": "generator-result-early-exit",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "if ($intGeneratorExit -isnot [int] -or $intGeneratorExit -ne 0) {\n    [void]($listFailedChecks.Add('NativeExit'))\n}\n",
      "to": "if ($intGeneratorExit -isnot [int] -or $intGeneratorExit -ne 0) {\n    [void]($listFailedChecks.Add('NativeExit'))\n}\nif ($listFailedChecks.Count -ne 0) { return }\n"
    },
    "expected": false,
    "expectedCategory": "generator-result-flow"
  },
  {
    "id": "PS-P1-WFPOL-086",
    "semanticKey": "generator-result-actual-value-output",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "throw ('Artifact generation failed result checks: {0}.' -f ($listFailedChecks -join ', '))",
      "to": "throw ('Artifact generation failed result checks: {0}.' -f $objResult.Schema)"
    },
    "expected": false,
    "expectedCategory": "generator-result-output"
  },
  {
    "id": "PS-P1-WFPOL-087",
    "semanticKey": "generator-result-extra-output",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "$objResult = $arrResult[0] | ConvertFrom-Json\n",
      "to": "$objResult = $arrResult[0] | ConvertFrom-Json\nWrite-Host $objResult.Schema\n"
    },
    "expected": false,
    "expectedCategory": "generator-result-flow"
  },
  {
    "id": "PS-P1-WFPOL-088",
    "semanticKey": "generator-result-native-result-conflation",
    "domain": "workflow",
    "workflow": "build.yml",
    "operation": {
      "type": "replace",
      "path": "/jobs/verify_generated_artifacts/steps/1/run",
      "from": "$intGeneratorExit -isnot [int] -or $intGeneratorExit -ne 0",
      "to": "$objResult.ExitCode -isnot [int] -or $objResult.ExitCode -ne 0"
    },
    "expected": false,
    "expectedCategory": "generator-result-predicate-NativeExit"
  }
]
'@
$script:objGeneratorResultPolicy = ConvertFrom-Json -AsHashtable -InputObject @'
{"labels":["NativeExit","Schema","GeneratorVersion","Overall","Phase","Category","NativeOutcome","ResultExitCode"],"prefix":"Artifact generation failed result checks: ","separator":", ","suffix":".","maximumAsciiBytes":136,"actualValues":false}
'@
$script:scriptblockConvertToStrengthenedValidator = {
    param(
        [Parameter(Mandatory)][string] $Text,
        [Parameter(Mandatory)][bool] $TrustedStrengthened
    )
    foreach ($objShape in $script:arrGeneratorResultSourceShape) {
        $strBefore = $objShape.Before + "`n"
        $strAfter = $objShape.After + "`n"
        $intBefore = [regex]::Matches($Text, [regex]::Escape($strBefore)).Count
        $intAfter = [regex]::Matches($Text, [regex]::Escape($strAfter)).Count
        if (-not $TrustedStrengthened -and $intBefore -eq 1 -and $intAfter -eq 0) {
            $Text = $Text.Replace($strBefore, $strAfter)
        } elseif ($TrustedStrengthened -and $intAfter -eq 1) {
            $strOutsideRegion = $Text.Replace($strAfter, '')
            if ($strOutsideRegion.Contains($strBefore, [StringComparison]::Ordinal) -or
                $strOutsideRegion.Contains($strAfter, [StringComparison]::Ordinal)) {
                throw 'The trusted generator-result source has an extra region anchor.'
            }
        } else {
            throw 'The trusted generator-result source has an unsupported or mixed region.'
        }
    }
    return $Text
}
$script:scriptblockGetGeneratorResultCategory = {
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Text)
    $arrBlocks = @(
        foreach ($objCase in ($script:arrRequiredGeneratorResultCase |
                Select-Object -First 16 | Where-Object {
                    $_.semanticKey.StartsWith('generator-result-disabled-',
                        [StringComparison]::Ordinal)
                })) {
            $strLabel = $objCase.expectedCategory.Substring(
                'generator-result-predicate-'.Length)
            [pscustomobject]@{
                Label = $strLabel
                Text = $objCase.operation.from + "`n    [void](" +
                    '$listFailedChecks.Add(' + "'" + $strLabel + "'))`n}`n"
            }
        }
    )
    $intPrevious = -1
    $boolOutOfOrder = $false
    foreach ($objBlock in $arrBlocks) {
        if ([regex]::Matches($Text, [regex]::Escape($objBlock.Text)).Count -ne 1) {
            return 'generator-result-predicate-' + $objBlock.Label
        }
        $intPosition = $Text.IndexOf($objBlock.Text, [StringComparison]::Ordinal)
        if ($intPosition -le $intPrevious) { $boolOutOfOrder = $true }
        $intPrevious = $intPosition
    }
    if ($boolOutOfOrder) { return 'generator-result-order' }
    $strAccumulator = '$listFailedChecks = [System.Collections.Generic.List[string]]::new()' + "`n"
    $strGuard = 'if ($listFailedChecks.Count -ne 0) {' + "`n"
    $strOutput = "    throw ('Artifact generation failed result checks: {0}.' -f (" +
        '$listFailedChecks' + " -join ', '))`n"
    foreach ($objPart in @(
            @{ Text = $strAccumulator; Category = 'accumulator' },
            @{ Text = $strGuard; Category = 'guard' },
            @{ Text = $strOutput; Category = 'output' }
        )) {
        if ([regex]::Matches($Text, [regex]::Escape($objPart.Text)).Count -ne 1) {
            return 'generator-result-' + $objPart.Category
        }
    }
    $strStart = '$objResult = $arrResult[0] | ConvertFrom-Json' + "`n"
    $strExpectedTail = ($script:strBoundedGeneratorResultTail -split "`n" |
        ForEach-Object { $_.Substring(10) }) -join "`n"
    $strExpectedTail += "`n"
    if ([regex]::Matches($Text, [regex]::Escape($strStart)).Count -ne 1 -or
        $Text.Substring($Text.IndexOf($strStart, [StringComparison]::Ordinal)) -cne
            $strExpectedTail) {
        return 'generator-result-flow'
    }
    return ''
}
$script:scriptblockAssertGeneratorResultCase = {
    param(
        [Parameter(Mandatory)][Collections.IDictionary] $Case,
        [Parameter(Mandatory)][string] $RunText
    )
    if ($Case.workflow -cne 'build.yml' -or
        $Case.operation.type -cne 'replace' -or
        $Case.operation.path -cne '/jobs/verify_generated_artifacts/steps/1/run' -or
        $Case.expectedCategory -isnot [string] -or
        $Case.expectedCategory -cnotmatch '^generator-result-[A-Za-z-]+$' -or
        $Case.operation.from -isnot [string] -or
        [string]::IsNullOrEmpty($Case.operation.from) -or
        $Case.operation.to -isnot [string] -or
        [regex]::Matches($RunText, [regex]::Escape($Case.operation.from)).Count -ne 1) {
        throw 'A generator-result case cannot prepare one exact supported mutation.'
    }
    $strPrepared = $RunText.Replace($Case.operation.from, $Case.operation.to)
    if ($strPrepared -ceq $RunText) {
        throw 'A generator-result mutation changed no bytes.'
    }
    $strCategory = & $script:scriptblockGetGeneratorResultCategory -Text $strPrepared
    if ([string]::IsNullOrEmpty($strCategory) -or
        $strCategory -cne $Case.expectedCategory) {
        throw 'A generator-result mutation did not fail in its declared category.'
    }
}


$script:strIsolationGeneratorConversion = @'
try {
    $objResult = $arrResult[0] | ConvertFrom-Json -NoEnumerate -ErrorAction Stop
} catch {
    throw 'The generator returned invalid JSON.'
}
if ($null -eq $objResult -or $objResult.GetType() -ne [System.Management.Automation.PSCustomObject]) {
    throw 'The generator returned a non-object JSON result.'
}
'@ + "`n"
$script:scriptblockGetIsolationGeneratorResultCategory = {
    param([Parameter(Mandatory)][AllowEmptyString()][string] $Text)
    $strCommonVersionBlock = @'
$objGeneratorResult = $objResult
$hashtableGeneratorVersionCheck = @{ 'Name' = 'GeneratorVersion'; 'Valid' = $objGeneratorResult.GeneratorVersion -ceq '1.0.20260919.0' }
if ($objGeneratorResult.GeneratorVersion -isnot [string] -or -not $hashtableGeneratorVersionCheck.Valid) {
    [void]($listFailedChecks.Add('GeneratorVersion'))
}
'@ + "`n"
    if ($Text.Contains('$objGeneratorResult', [StringComparison]::Ordinal) -or
        $Text.Contains('$hashtableGeneratorVersionCheck', [StringComparison]::Ordinal)) {
        if ([regex]::Matches($Text, [regex]::Escape($strCommonVersionBlock)).Count -ne 1) {
            return 'generator-result-predicate-GeneratorVersion'
        }
        $strLegacyVersionBlock = @'
if ($objResult.GeneratorVersion -isnot [string] -or $objResult.GeneratorVersion -cne '1.0.20260916.0') {
    [void]($listFailedChecks.Add('GeneratorVersion'))
}
'@ + "`n"
        $Text = $Text.Replace($strCommonVersionBlock, $strLegacyVersionBlock)
    }
    if ([regex]::Matches($Text,
            [regex]::Escape($script:strIsolationGeneratorConversion)).Count -ne 1) {
        return 'generator-result-json'
    }
    $strNormalized = $Text.Replace($script:strIsolationGeneratorConversion,
        ('$objResult = $arrResult[0] | ConvertFrom-Json' + "`n"))
    return (& $script:scriptblockGetGeneratorResultCategory -Text $strNormalized)
}

function Read-IsolationPolicyText {
    # .SYNOPSIS
    # Reads one fixed isolation-policy blob without executing its contents.
    #
    # .DESCRIPTION
    # Requires a regular Git blob at the specified immutable revision. The
    # fixed paths and finite byte bound cannot be supplied by reference data.
    # Candidate marker inspection confers no authority; the selected closed
    # evaluator must still validate all candidate content and history.
    #
    # .PARAMETER RepositoryRootPath
    # The absolute repository containing the authenticated Git objects.
    #
    # .PARAMETER Revision
    # The exact commit from which to read the blob.
    #
    # .PARAMETER Path
    # One fixed selector or trusted inert reference path.
    #
    # .EXAMPLE
    # Read-IsolationPolicyText @hashtableArguments
    #
    # # Returns strict UTF-8 data, never an executable script block.
    #
    # .INPUTS
    # None. This helper does not accept pipeline input.
    #
    # .OUTPUTS
    # [string] Exact bounded blob text.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.1.20260919.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $RepositoryRootPath,
        [Parameter(Mandatory)][ValidatePattern('^[0-9a-f]{40}$')][string] $Revision,
        [Parameter(Mandatory)]
        [ValidateSet('.github/workflows/Validate-WorkflowPolicy.mjs',
            '.github/workflows/workflow-isolation-reference.json',
            '.github/workflows/workflow-isolation-validator.reference.txt',
            '.github/workflows/workflow-common-reference.json',
            '.github/workflows/workflow-common-validator.reference.txt',
            IgnoreCase = $false)]
        [string] $Path
    )

    $objEntry = Invoke-BoundedProcessByte -FileName 'git' -MaximumBytes 1024 `
        -ArgumentList @('--literal-pathspecs', '-C', $RepositoryRootPath,
            'ls-tree', $Revision, '--', $Path)
    $strEntry = ConvertFrom-StrictUtf8Text -Bytes $objEntry.Bytes `
        -Name 'An isolation policy tree entry'
    if ($objEntry.ExitCode -ne 0 -or
        $strEntry -cnotmatch '^100644 blob ([0-9a-f]{40})\t([^\n]+)\n$' -or
        -not [StringComparer]::Ordinal.Equals($Matches[2], $Path)) {
        throw 'An isolation policy input is missing or is not a regular blob.'
    }
    $arrBytes = @(Read-GitBlobByte -RepositoryRootPath $RepositoryRootPath `
            -BlobId $Matches[1] -MaximumBytes 524288)
    return ConvertFrom-StrictUtf8Text -Bytes $arrBytes -Name $Path
}

function Assert-WorkflowIsolationReferenceContent {
    # .SYNOPSIS
    # Checks the closed P1 isolation domain against trusted inert references.
    #
    # .DESCRIPTION
    # Reconstructs complete workflow and validator text from fixed reference
    # blobs at the authenticated trusted revision. Permits only finite job
    # timeouts, independently derived identities, the next patch version,
    # existing identity-helper presentation and proved negative case additions.
    # No reference text or candidate code is invoked, imported or evaluated.
    # The caller first audits bounded history paths and modes, plus byte sizes
    # for every consumed endpoint blob. Unused historical content is not read.
    #
    # .PARAMETER RepositoryRootPath
    # The absolute trusted repository path.
    #
    # .PARAMETER TrustedRevision
    # The authenticated commit that owns the reference blobs.
    #
    # .PARAMETER TrustedText
    # The seven fixed regular blobs read from the trusted revision.
    #
    # .PARAMETER CandidateText
    # The same seven fixed regular blobs read from the candidate revision.
    #
    # .EXAMPLE
    # Assert-WorkflowIsolationReferenceContent @hashtableArguments
    #
    # # Returns no output when the complete inert tuple matches its rules.
    #
    # .INPUTS
    # None. This helper does not accept pipeline input.
    #
    # .OUTPUTS
    # None. Throws when any part of the closed tuple is unsupported.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.1.20260919.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $RepositoryRootPath,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $TrustedRevision,
        [Parameter(Mandatory)][Collections.Generic.Dictionary[string, string]] $TrustedText,
        [Parameter(Mandatory)][Collections.Generic.Dictionary[string, string]] $CandidateText
    )

    $strPrefix = '.github/workflows/'
    $strValidatorPath = $strPrefix + 'Validate-WorkflowPolicy.mjs'
    $strContractPath = $strPrefix + 'workflow-policy-contract.json'
    $strCatalogPath = $strPrefix + 'workflow-policy-cases.json'
    $strHelperPath = $strPrefix + 'pull-request-body-identity.yml'
    $strGeneratorPath = $strPrefix + 'Generate-StyleGuideArtifacts.ps1'
    $strCommonBinding = '$script:strGeneratorVersion = ''1.0.20260919.0'''
    $boolTrustedCommon = $TrustedText[$strGeneratorPath].Contains(
        $strCommonBinding, [StringComparison]::Ordinal)
    $boolCandidateCommon = $CandidateText[$strGeneratorPath].Contains(
        $strCommonBinding, [StringComparison]::Ordinal)
    if ($boolTrustedCommon -and -not $boolCandidateCommon) {
        throw 'The common workflow domain cannot downgrade its generator.'
    }
    if ($boolCandidateCommon -and -not $boolTrustedCommon) {
        $strLegacyReferenceText = Read-IsolationPolicyText -RepositoryRootPath $RepositoryRootPath -Revision $TrustedRevision -Path ($strPrefix + 'workflow-isolation-reference.json')
        $objLegacyReference = & $script:scriptblockConvertFromStrictJsonHashtable -Text $strLegacyReferenceText -Name 'The trusted legacy isolation reference'
        $objLegacyCatalog = & $script:scriptblockConvertFromStrictJsonHashtable -Text $objLegacyReference.caseCatalogText -Name 'The reviewed legacy catalog'
        $objTrustedCatalog = & $script:scriptblockConvertFromStrictJsonHashtable -Text $TrustedText[$strCatalogPath] -Name 'The accepted legacy catalog'
        if ((& $script:scriptblockConvertToCanonicalJsonText -Value $objLegacyCatalog) -cne
            (& $script:scriptblockConvertToCanonicalJsonText -Value $objTrustedCatalog)) {
            throw 'The common transition requires the exact reviewed legacy catalog; accepted cases must not be lost.'
        }
        $strExpectedGenerator = $TrustedText[$strGeneratorPath]
        foreach ($objReplacement in @(
                @{ Before = "Version: 1.0.20260916.0" + "`n#>";
                    After = "Version: 1.0.20260919.0" + "`n#>" },
                @{ Before = '$script:strGeneratorVersion = ''1.0.20260916.0''';
                    After = $strCommonBinding },
                @{ Before = '$arrGitCommands = @(Get-Command -Name git -CommandType Application -ErrorAction Stop)';
                    After = '$arrGitCommands = @(Microsoft.PowerShell.Core\Get-Command -Name git -CommandType Application -ErrorAction Stop)' }
            )) {
            if ([regex]::Matches($strExpectedGenerator,
                    [regex]::Escape($objReplacement.Before)).Count -ne 1) {
                throw 'The trusted generator lacks the exact common transition input.'
            }
            $strExpectedGenerator = $strExpectedGenerator.Replace(
                $objReplacement.Before, $objReplacement.After)
        }
        $objTrackedFunction = [regex]::Match($strExpectedGenerator,
            '(?ms)^function Assert-TrackedFile \{.*?^\}')
        if (-not $objTrackedFunction.Success -or
            [regex]::Matches($objTrackedFunction.Value,
                [regex]::Escape('    # Version: 1.0.20260813.0')).Count -ne 1) {
            throw 'The trusted tracked-file helper has an unsupported version.'
        }
        $strExpectedGenerator = $strExpectedGenerator.Replace(
            $objTrackedFunction.Value, $objTrackedFunction.Value.Replace(
                '    # Version: 1.0.20260813.0', '    # Version: 1.0.20260919.0'))
        if ($CandidateText[$strGeneratorPath] -cne $strExpectedGenerator) {
            throw 'The common generator changes bytes outside its exact qualification transition.'
        }
    } elseif ($CandidateText[$strGeneratorPath] -cne $TrustedText[$strGeneratorPath]) {
        throw 'The ordinary generator is immutable outside its exact common transition.'
    }
    $strReferenceName = if ($boolCandidateCommon) {
        'workflow-common-reference.json'
    } else { 'workflow-isolation-reference.json' }
    $strValidatorReferenceName = if ($boolCandidateCommon) {
        'workflow-common-validator.reference.txt'
    } else { 'workflow-isolation-validator.reference.txt' }
    $strReferenceText = Read-IsolationPolicyText -RepositoryRootPath $RepositoryRootPath `
        -Revision $TrustedRevision -Path ($strPrefix + $strReferenceName)
    $objReference = & $script:scriptblockConvertFromStrictJsonHashtable `
        -Text $strReferenceText -Name 'The trusted isolation reference'
    & $script:scriptblockAssertExactDictionaryKeySet -Dictionary $objReference `
        -Name 'The isolation reference' `
        -Key @('schema', 'workflowText', 'contractText', 'caseCatalogText')
    if ($objReference.schema -isnot [string] -or
        $objReference.schema -cne 'PSStyleGuide.WorkflowIsolationReference.v1' -or
        $objReference.contractText -isnot [string] -or
        $objReference.caseCatalogText -isnot [string] -or
        $objReference.workflowText -isnot [Collections.IDictionary]) {
        throw 'The trusted isolation reference has an unsupported shape.'
    }
    & $script:scriptblockAssertExactDictionaryKeySet -Dictionary $objReference.workflowText `
        -Name 'The isolation workflow references' -Key @('build.yml', 'markdownlint.yml')

    # These slots are code-owned, not a candidate- or reference-supplied schema.
    $arrSlots = @(
        @{ Workflow = 'build.yml'; Job = 'verify_generated_artifacts'; Token = 'VERIFY_TIMEOUT_MINUTES' },
        @{ Workflow = 'markdownlint.yml'; Job = 'policy'; Token = 'POLICY_TIMEOUT_MINUTES' },
        @{ Workflow = 'markdownlint.yml'; Job = 'markdownlint'; Token = 'LINT_TIMEOUT_MINUTES' }
    )
    $objExpectedContract = & $script:scriptblockConvertFromStrictJsonHashtable `
        -Text $objReference.contractText -Name 'The trusted isolation contract'
    foreach ($strWorkflow in @('build.yml', 'markdownlint.yml')) {
        $strTemplate = $objReference.workflowText[$strWorkflow]
        if ($strTemplate -isnot [string] -or
            [Text.Encoding]::UTF8.GetByteCount($strTemplate) -gt 131072) {
            throw 'An isolation workflow reference has invalid text or size.'
        }
        $strPattern = [regex]::Escape($strTemplate)
        foreach ($objSlot in @($arrSlots | Where-Object { $_.Workflow -ceq $strWorkflow })) {
            $strToken = '{{' + $objSlot.Token + '}}'
            if ([regex]::Matches($strTemplate, [regex]::Escape($strToken)).Count -ne 1 -or
                -not $strTemplate.Contains(('    timeout-minutes: ' + $strToken + "`n"),
                    [StringComparison]::Ordinal)) {
                throw 'An isolation timeout slot lacks its exact job-level form.'
            }
            $strPattern = $strPattern.Replace([regex]::Escape($strToken),
                ('(?<' + $objSlot.Token + '>[1-9][0-9]?)'))
        }
        $objMatch = [regex]::Match($CandidateText[$strPrefix + $strWorkflow],
            ('\A' + $strPattern + '\z'), [Text.RegularExpressions.RegexOptions]::CultureInvariant,
            [TimeSpan]::FromSeconds(2))
        if (-not $objMatch.Success) {
            throw 'An isolation workflow changes bytes outside its fixed typed slots.'
        }
        foreach ($objSlot in @($arrSlots | Where-Object { $_.Workflow -ceq $strWorkflow })) {
            $intTimeout = [int]$objMatch.Groups[$objSlot.Token].Value
            if ($intTimeout -lt 5 -or $intTimeout -gt 60) {
                throw 'An isolation job timeout is outside 5 through 60 minutes.'
            }
            $objExpectedContract.workflowPolicy.workflows[$strWorkflow].jobs[
                $objSlot.Job].timeoutMinutes = $intTimeout
        }
    }
    $strAcquireDigest = Assert-OrdinaryHelperWorkflow -TrustedText $TrustedText[$strHelperPath] `
        -CandidateText $CandidateText[$strHelperPath]
    $objExpectedContract.workflowPolicy.workflows['pull-request-body-identity.yml'].jobs.
        verify_identity.steps[0].runSha256 = $strAcquireDigest

    $strBuild = $CandidateText[$strPrefix + 'build.yml']
    $strGeneratorStep = "      - name: Generate and verify style guide artifacts`n"
    $strPublisherJob = "`n  publish_committed_artifacts:`n"
    $intGeneratorStep = $strBuild.IndexOf($strGeneratorStep,
        [StringComparison]::Ordinal)
    $strRunStart = "        run: |`n"
    $intRunStart = if ($intGeneratorStep -ge 0) {
        $strBuild.IndexOf($strRunStart, $intGeneratorStep, [StringComparison]::Ordinal)
    } else { -1 }
    $intRunEnd = $strBuild.IndexOf($strPublisherJob, [StringComparison]::Ordinal)
    if ([regex]::Matches($strBuild, [regex]::Escape($strGeneratorStep)).Count -ne 1 -or
        [regex]::Matches($strBuild, [regex]::Escape($strPublisherJob)).Count -ne 1 -or
        $intRunStart -lt 0 -or $intRunEnd -le ($intRunStart + $strRunStart.Length)) {
        throw 'The isolation generator has unsupported fixed run boundaries.'
    }
    $intRunStart += $strRunStart.Length
    $arrRunLines = $strBuild.Substring($intRunStart,
        $intRunEnd - $intRunStart).TrimEnd("`n") -split "`n"
    foreach ($strRunLine in $arrRunLines) {
        if ($strRunLine.Length -ne 0 -and
            -not $strRunLine.StartsWith('          ', [StringComparison]::Ordinal)) {
            throw 'The isolation generator has an unexpected later step or indentation.'
        }
    }
    $strCombinedRun = (($arrRunLines | ForEach-Object {
                if ($_.Length -eq 0) { '' } else { $_.Substring(10) }
            }) -join "`n") + "`n"
    $strRegionStart = "# BEGIN P1 GENERATOR RESULT`n"
    $strRegionEnd = "# END P1 GENERATOR RESULT`n"
    if ([regex]::Matches($strCombinedRun, [regex]::Escape($strRegionStart)).Count -ne 1 -or
        [regex]::Matches($strCombinedRun, [regex]::Escape($strRegionEnd)).Count -ne 1) {
        throw 'The isolation generator result region lacks unique fixed boundaries.'
    }
    $intRegionStart = $strCombinedRun.IndexOf($strRegionStart, [StringComparison]::Ordinal) +
        $strRegionStart.Length
    $intRegionEnd = $strCombinedRun.IndexOf($strRegionEnd, [StringComparison]::Ordinal)
    if ($intRegionEnd -le $intRegionStart -or
        ($intRegionEnd + $strRegionEnd.Length) -ge $strCombinedRun.Length) {
        throw 'The isolation generator result region has no fixed postchecks.'
    }
    # Exact full-workflow reference comparison above binds the executable
    # prefix and suffix. The old result recognizer remains strict within its
    # complete region; it is not changed to ignore arbitrary trailing code.
    $strGeneratorRun = $strCombinedRun.Substring($intRegionStart, $intRegionEnd - $intRegionStart)
    if (-not [string]::IsNullOrEmpty((& $script:scriptblockGetIsolationGeneratorResultCategory `
                -Text $strGeneratorRun))) {
        throw 'The isolation generator result flow weakens the supported domain.'
    }

    $boolTrustedIsolation = [regex]::Matches($TrustedText[$strValidatorPath],
        $script:strIsolationMarkerPattern).Count -eq 1
    $objMandatoryCatalog = & $script:scriptblockConvertFromStrictJsonHashtable `
        -Text $objReference.caseCatalogText -Name 'The trusted mapped case catalog'
    $strBaselineCatalog = if ($boolTrustedIsolation -and
        (-not $boolCandidateCommon -or $boolTrustedCommon)) {
        $TrustedText[$strCatalogPath]
    } else { $objReference.caseCatalogText }
    $objBaselineCatalog = & $script:scriptblockConvertFromStrictJsonHashtable `
        -Text $strBaselineCatalog -Name 'The isolation baseline catalog'
    $objCandidateCatalog = & $script:scriptblockConvertFromStrictJsonHashtable `
        -Text $CandidateText[$strCatalogPath] -Name 'The isolation candidate catalog'
    foreach ($objCatalog in @($objMandatoryCatalog, $objBaselineCatalog, $objCandidateCatalog)) {
        & $script:scriptblockAssertExactDictionaryKeySet -Dictionary $objCatalog `
            -Name 'An isolation case catalog' -Key @('schema', 'cases')
        if ($objCatalog.schema -isnot [string] -or
            $objCatalog.schema -cne $objMandatoryCatalog.schema -or
            $objCatalog.cases -isnot [array] -or
            $objCatalog.cases.Count -lt 130 -or $objCatalog.cases.Count -gt 512) {
            throw 'An isolation case catalog has an invalid schema or count.'
        }
    }
    if ($objBaselineCatalog.cases.Count -lt $objMandatoryCatalog.cases.Count -or
        $objCandidateCatalog.cases.Count -lt $objBaselineCatalog.cases.Count -or
        $objCandidateCatalog.cases.Count -gt ($objBaselineCatalog.cases.Count + 32)) {
        throw 'An isolation update removes cases or exceeds its increment bound.'
    }
    $arrCatalogDocuments = @()
    try {
        foreach ($strCatalogText in @($objReference.caseCatalogText, $strBaselineCatalog,
                $CandidateText[$strCatalogPath])) {
            $arrCatalogDocuments += [System.Text.Json.JsonDocument]::Parse($strCatalogText)
        }
        for ($intCatalog = 0; $intCatalog -lt 2; $intCatalog++) {
            $arrSourceCases = @($arrCatalogDocuments[$intCatalog].RootElement.
                GetProperty('cases').EnumerateArray())
            $arrTargetCases = @($arrCatalogDocuments[$intCatalog + 1].RootElement.
                GetProperty('cases').EnumerateArray())
            for ($intIndex = 0; $intIndex -lt $arrSourceCases.Count; $intIndex++) {
                if ((& $script:scriptblockConvertToCanonicalJsonText -Value $arrSourceCases[$intIndex]) -cne
                    (& $script:scriptblockConvertToCanonicalJsonText -Value $arrTargetCases[$intIndex])) {
                    throw 'An isolation update changes or reorders a required or accepted case.'
                }
            }
        }
    } finally {
        foreach ($objDocument in $arrCatalogDocuments) { $objDocument.Dispose() }
    }
    $setNames = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $setIds = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $intLastCase = 0
    foreach ($objCase in $objBaselineCatalog.cases) {
        if (-not $setNames.Add([string]$objCase.semanticKey) -or
            -not $setIds.Add([string]$objCase.id)) {
            throw 'The isolation baseline has duplicate case identities.'
        }
        if ($objCase.id -cmatch '^PS-P1-WFPOL-([0-9]{3})$') {
            $intLastCase = [Math]::Max($intLastCase, [int]$Matches[1])
        }
    }
    $boolNeedsTrustedCatalogValidation = $false
    for ($intIndex = $objBaselineCatalog.cases.Count;
        $intIndex -lt $objCandidateCatalog.cases.Count; $intIndex++) {
        $objCase = $objCandidateCatalog.cases[$intIndex]
        $arrKeys = @('id', 'semanticKey', 'domain', 'workflow', 'operation', 'expected')
        if ($objCase.Contains('expectedCategory')) { $arrKeys += 'expectedCategory' }
        & $script:scriptblockAssertExactDictionaryKeySet -Dictionary $objCase `
            -Name 'An isolation new case' -Key $arrKeys
        $intLastCase++
        if ($intLastCase -gt 999 -or $objCase.id -isnot [string] -or
            $objCase.id -cne ('PS-P1-WFPOL-{0:D3}' -f $intLastCase) -or
            -not $setIds.Add($objCase.id) -or $objCase.semanticKey -isnot [string] -or
            $objCase.semanticKey -cnotmatch '^[a-z0-9-]{1,128}$' -or
            -not $setNames.Add($objCase.semanticKey) -or $objCase.domain -isnot [string] -or
            $objCase.domain -cne 'workflow' -or $objCase.workflow -isnot [string] -or
            $objCase.workflow -cnotin @('build.yml', 'markdownlint.yml',
                'pull-request-body-identity.yml') -or
            $objCase.expected -isnot [bool] -or $objCase.expected -or
            $objCase.operation -isnot [Collections.IDictionary] -or
            $objCase.operation.type -isnot [string] -or
            $objCase.operation.path -isnot [string]) {
            throw 'An isolation new case is not a sequential negative workflow fixture.'
        }
        if ($objCase.Contains('expectedCategory')) {
            & $script:scriptblockAssertExactDictionaryKeySet -Dictionary $objCase.operation `
                -Name 'An isolation generator fixture' -Key @('type', 'path', 'from', 'to')
            # Only this exact P1 pointer maps to the existing independent proof.
            if ($objCase.workflow -cne 'build.yml' -or
                $objCase.operation.path -cne '/jobs/verify_generated_artifacts/steps/2/run') {
                throw 'An isolation generator fixture targets an unsupported run.'
            }
            if ($objCase.operation.from -isnot [string] -or
                [string]::IsNullOrEmpty($objCase.operation.from) -or
                $objCase.operation.to -isnot [string] -or
                [regex]::Matches($strCombinedRun,
                    [regex]::Escape($objCase.operation.from)).Count -ne 1 -or
                [regex]::Matches($strGeneratorRun,
                    [regex]::Escape($objCase.operation.from)).Count -ne 1 -or
                $objCase.operation.to.Contains('# BEGIN P1 GENERATOR RESULT',
                    [StringComparison]::Ordinal) -or
                $objCase.operation.to.Contains('# END P1 GENERATOR RESULT',
                    [StringComparison]::Ordinal)) {
                throw 'An isolation generator fixture escapes its fixed result region.'
            }
            if ($objCase.operation.type -cne 'replace' -or
                $objCase.expectedCategory -isnot [string] -or
                $objCase.expectedCategory -cnotmatch '^generator-result-[A-Za-z-]+$') {
                throw 'An isolation generator fixture has an unsupported proof type.'
            }
            $strPreparedResult = $strGeneratorRun.Replace(
                $objCase.operation.from, $objCase.operation.to)
            $strPreparedCategory = & $script:scriptblockGetIsolationGeneratorResultCategory `
                -Text $strPreparedResult
            if ($strPreparedResult -ceq $strGeneratorRun -or
                [string]::IsNullOrEmpty($strPreparedCategory) -or
                $strPreparedCategory -cne $objCase.expectedCategory) {
                throw 'An isolation generator mutation did not fail in its declared category.'
            }
        } else {
            $arrOperationKeys = switch -CaseSensitive ($objCase.operation.type) {
                'set' { @('type', 'path', 'value') }
                'delete' { @('type', 'path') }
                'append' { @('type', 'path', 'value') }
                'append-copy' { @('type', 'path', 'source') }
                'swap' { @('type', 'path', 'otherPath') }
                'replace' { @('type', 'path', 'from', 'to') }
                default { throw 'An isolation fixture uses an unsupported operation.' }
            }
            & $script:scriptblockAssertExactDictionaryKeySet -Dictionary $objCase.operation `
                -Name 'An isolation fixture operation' -Key $arrOperationKeys
            foreach ($strPointerKey in @('path', 'source', 'otherPath')) {
                if ($objCase.operation.Contains($strPointerKey) -and
                    ($objCase.operation[$strPointerKey] -isnot [string] -or
                        $objCase.operation[$strPointerKey] -cnotmatch '^/[^\x00-\x20]{1,1023}$' -or
                        $objCase.operation[$strPointerKey] -cmatch
                        '(?:^|/)(?:__proto__|constructor|prototype)(?:/|$)')) {
                    throw 'An isolation fixture has an unsafe or invalid JSON pointer.'
                }
            }
            if ($objCase.operation.type -ceq 'replace' -and
                ($objCase.operation.from -isnot [string] -or
                    [string]::IsNullOrEmpty($objCase.operation.from) -or
                    $objCase.operation.to -isnot [string])) {
                throw 'An isolation replacement fixture has invalid text operands.'
            }
            $arrPermissionPaths = if ($objCase.workflow -ceq 'build.yml') {
                @('/permissions', '/jobs/verify_generated_artifacts/permissions')
            } elseif ($objCase.workflow -ceq 'markdownlint.yml') {
                @('/permissions', '/jobs/policy/permissions', '/jobs/markdownlint/permissions')
            } else { @() }
            $boolClosedPermission = $objCase.operation.type -ceq 'set' -and
                $objCase.operation.path -cin $arrPermissionPaths -and
                (& $script:scriptblockConvertToCanonicalJsonText -Value $objCase.operation.value) -ceq
                '{"contents":"write"}'
            if (-not $boolClosedPermission) {
                if (-not $boolTrustedIsolation) {
                    throw 'An initial isolation fixture has no independent closed predicate.'
                }
                foreach ($strWorkflowName in @('build.yml', 'markdownlint.yml',
                        'pull-request-body-identity.yml')) {
                    if ($TrustedText[$strPrefix + $strWorkflowName] -cne
                        $CandidateText[$strPrefix + $strWorkflowName]) {
                        throw 'Generic isolation cases require unchanged trusted workflow inputs.'
                    }
                }
                $boolNeedsTrustedCatalogValidation = $true
            }
        }
    }

    $objCandidateContract = & $script:scriptblockConvertFromStrictJsonHashtable `
        -Text $CandidateText[$strContractPath] -Name 'The isolation candidate contract'
    foreach ($strIdentity in @('caseCatalog', 'validatorIdentity')) {
        & $script:scriptblockAssertExactDictionaryKeySet `
            -Dictionary $objCandidateContract[$strIdentity] `
            -Name 'An isolation content identity' -Key @('path', 'sha256')
        $strIdentityPath = if ($strIdentity -ceq 'caseCatalog') {
            $strCatalogPath
        } else { $strValidatorPath }
        $strDigest = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData(
                [Text.UTF8Encoding]::new($false).GetBytes($CandidateText[$strIdentityPath])
            )).ToLowerInvariant()
        $objExpectedContract[$strIdentity].sha256 = $strDigest
    }
    $objContractDocument = $null
    $objReferenceContractDocument = $null
    try {
        $objContractDocument = [System.Text.Json.JsonDocument]::Parse($CandidateText[$strContractPath])
        $objReferenceContractDocument = [System.Text.Json.JsonDocument]::Parse($objReference.contractText)
        $objExpectedView = [ordered]@{}
        foreach ($objProperty in $objReferenceContractDocument.RootElement.EnumerateObject()) {
            $objExpectedView[$objProperty.Name] = if ($objProperty.Name -cin
                @('workflowPolicy', 'caseCatalog', 'validatorIdentity')) {
                $objExpectedContract[$objProperty.Name]
            } else { $objProperty.Value }
        }
        if ((& $script:scriptblockConvertToCanonicalJsonText -Value $objExpectedView) -cne
            (& $script:scriptblockConvertToCanonicalJsonText -Value $objContractDocument.RootElement)) {
            throw 'The isolation contract changes rules or has inconsistent derived identities.'
        }
        $objIdentityView = [ordered]@{}
        foreach ($objProperty in $objContractDocument.RootElement.EnumerateObject()) {
            if ($objProperty.Name -cne 'validatorIdentity') {
                $objIdentityView[$objProperty.Name] = $objProperty.Value
            }
        }
        $strCanonicalContract = & $script:scriptblockConvertToCanonicalJsonText -Value $objIdentityView
    } finally {
        if ($null -ne $objContractDocument) { $objContractDocument.Dispose() }
        if ($null -ne $objReferenceContractDocument) { $objReferenceContractDocument.Dispose() }
    }
    $strCanonicalDigest = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData(
            [Text.UTF8Encoding]::new($false).GetBytes($strCanonicalContract)
        )).ToLowerInvariant()
    $strReferenceValidator = Read-IsolationPolicyText -RepositoryRootPath $RepositoryRootPath `
        -Revision $TrustedRevision -Path ($strPrefix + $strValidatorReferenceName)
    $strVersionPattern = "(?m)^const VALIDATOR_VERSION = '([0-9]+)\.([0-9]+)\.([0-9]+)';$"
    $strDigestPattern = "(?m)^const EXPECTED_CONTRACT_CANONICAL_SHA256 = '[0-9a-f]{64}';$"
    foreach ($strValidator in @($TrustedText[$strValidatorPath], $strReferenceValidator,
            $CandidateText[$strValidatorPath])) {
        if ([regex]::Matches($strValidator, $strVersionPattern).Count -ne 1 -or
            [regex]::Matches($strValidator, $strDigestPattern).Count -ne 1) {
            throw 'An isolation validator has missing or duplicate identity literals.'
        }
    }
    if ([regex]::Matches($strReferenceValidator,
            $script:strIsolationMarkerPattern).Count -ne 1) {
        throw 'The trusted isolation validator lacks its exact domain marker.'
    }
    $objVersion = [regex]::Match($TrustedText[$strValidatorPath], $strVersionPattern)
    $objReferenceVersion = [regex]::Match($strReferenceValidator, $strVersionPattern)
    $intNextPatch = [int]$objVersion.Groups[3].Value + 1
    if ($objVersion.Groups[1].Value -cne $objReferenceVersion.Groups[1].Value -or
        $objVersion.Groups[2].Value -cne $objReferenceVersion.Groups[2].Value -or
        $intNextPatch -lt [int]$objReferenceVersion.Groups[3].Value -or $intNextPatch -gt 999999) {
        throw 'The isolation validator version is outside its bounded patch series.'
    }
    $strNextVersion = "const VALIDATOR_VERSION = '{0}.{1}.{2}';" -f
        $objVersion.Groups[1].Value, $objVersion.Groups[2].Value, $intNextPatch
    $strExpectedValidator = [regex]::Replace($strReferenceValidator, $strVersionPattern, $strNextVersion)
    $strExpectedValidator = [regex]::Replace($strExpectedValidator, $strDigestPattern,
        "const EXPECTED_CONTRACT_CANONICAL_SHA256 = '$strCanonicalDigest';")
    if (-not $strExpectedValidator.EndsWith("`n", [StringComparison]::Ordinal) -or
        -not $CandidateText[$strValidatorPath].StartsWith($strExpectedValidator,
            [StringComparison]::Ordinal)) {
        throw 'An isolation candidate changes unsupported executable validator bytes.'
    }
    $strSuffix = $CandidateText[$strValidatorPath].Substring($strExpectedValidator.Length)
    if ($strSuffix.Length -gt 8192 -or $strSuffix -cnotmatch '\A(?:// [\x20-\x7e]*\n|\n)*\z' -or
        $strSuffix.Contains('EXPECTED_CONTRACT_CANONICAL_SHA256', [StringComparison]::Ordinal) -or
        $strSuffix.Contains('VALIDATOR_VERSION', [StringComparison]::Ordinal)) {
        throw 'An isolation validator suffix is not bounded inert line comments.'
    }
    if ($boolNeedsTrustedCatalogValidation -and $script:boolValidateOrdinaryCaseCatalog) {
        # The earlier no-switch call establishes domain membership only. The
        # instruction workflow requires this later outcome gate on the same
        # inputs. Never execute the inert reference or candidate validator.
        $objCatalogPreflight = Invoke-BoundedProcessByte -FileName 'node' `
            -ArgumentList @((Join-Path $RepositoryRootPath $strValidatorPath), '--preflight') `
            -MaximumBytes 65536 -TimeoutMilliseconds 60000
        if ($objCatalogPreflight.ExitCode -ne 0) {
            throw 'The trusted isolation catalog preflight failed.'
        }
        $objCatalogOutcome = Invoke-BoundedProcessByte -FileName 'node' `
            -ArgumentList @((Join-Path $RepositoryRootPath $strValidatorPath), '--ordinary-case-catalog-data') `
            -InputBytes ([Text.UTF8Encoding]::new($false, $true).GetBytes($CandidateText[$strCatalogPath])) `
            -MaximumBytes 65536 -TimeoutMilliseconds 60000
        if ($objCatalogOutcome.ExitCode -ne 0) {
            throw 'The trusted isolation case outcomes failed.'
        }
    }
}

function Assert-OrdinaryWorkflowPolicyContent {
    # .SYNOPSIS
    # Validates the closed ordinary workflow-policy tuple as inert Git data.
    #
    # .DESCRIPTION
    # Admits the complete reviewed old-to-strengthened generator-result form,
    # never its downgrade. Preserves all executable bytes outside those regions
    # and every existing case. Accepts bounded sequential negative fixtures,
    # fixed-helper presentation, truthful static OutputType metadata, derived
    # identities, the next patch and inert trailing comments. Audits the complete
    # history's path boundaries and the caller/policy/category coupling.
    # Content admission and optional trusted-case checks do not establish full
    # CI, independent review or merge readiness.
    #
    # .PARAMETER RepositoryRootPath
    # The absolute trusted repository path.
    #
    # .PARAMETER TrustedRevision
    # The authenticated base commit that supplies every admission rule.
    #
    # .PARAMETER HeadRevision
    # The exact descendant candidate commit to inspect without checkout.
    #
    # .EXAMPLE
    # Assert-OrdinaryWorkflowPolicyContent @hashtableArguments
    #
    # # Returns no output when the complete candidate shape is valid.
    #
    # .INPUTS
    # None. This helper does not accept pipeline input.
    #
    # .OUTPUTS
    # None. Throws for unsupported, inconsistent or incomplete content.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.3.20260919.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $RepositoryRootPath,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $TrustedRevision,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $HeadRevision
    )

    $arrOrdinaryPaths = @(
        '.github/workflows/workflow-policy-cases.json',
        '.github/workflows/workflow-policy-contract.json',
        '.github/workflows/Validate-WorkflowPolicy.mjs',
        '.github/workflows/pull-request-body-identity.yml',
        '.github/workflows/build.yml'
    )
    $strCandidateSelector = Read-IsolationPolicyText `
        -RepositoryRootPath $RepositoryRootPath -Revision $HeadRevision `
        -Path '.github/workflows/Validate-WorkflowPolicy.mjs'
    $boolWorkflowIsolation = [regex]::Matches($strCandidateSelector,
        $script:strIsolationMarkerPattern).Count -eq 1
    if ($boolWorkflowIsolation) {
        $arrOrdinaryPaths += '.github/workflows/markdownlint.yml'
        $arrOrdinaryPaths += '.github/workflows/Generate-StyleGuideArtifacts.ps1'
    }
    $setOrdinaryPaths = [Collections.Generic.HashSet[string]]::new(
        [string[]]$arrOrdinaryPaths, [StringComparer]::Ordinal)
    $setOrdinaryWorkflows = [Collections.Generic.HashSet[string]]::new(
        [string[]]@('build.yml', 'markdownlint.yml', 'pull-request-body-identity.yml'),
        [StringComparer]::Ordinal)
    $setOrdinaryOperations = [Collections.Generic.HashSet[string]]::new(
        [string[]]@('set', 'delete', 'append', 'append-copy', 'swap', 'replace'),
        [StringComparer]::Ordinal)
    $objCommitCount = Invoke-BoundedProcessByte -FileName 'git' -MaximumBytes 64 `
        -ArgumentList @(
            '-C', $RepositoryRootPath, 'rev-list', '--count', '--max-count=65',
            $HeadRevision, '--not', $TrustedRevision
        )
    $strCommitCount = ConvertFrom-StrictUtf8Text -Bytes $objCommitCount.Bytes `
        -Name 'The ordinary candidate commit count'
    if ($objCommitCount.ExitCode -ne 0 -or
        $strCommitCount.Trim() -cnotmatch '^[0-9]+$' -or
        [int]$strCommitCount.Trim() -notin 1..64) {
        throw 'The ordinary candidate history is empty or exceeds 64 commits.'
    }
    foreach ($arrArguments in @(
            ,@('diff', '--name-only', '-z', '--no-renames', '--no-ext-diff',
                '--no-textconv', $TrustedRevision, $HeadRevision, '--')
        )) {
        $objPathResult = Invoke-BoundedProcessByte -FileName 'git' `
            -MaximumBytes 1048576 -ArgumentList (@('-C', $RepositoryRootPath) +
                $arrArguments)
        if ($objPathResult.ExitCode -ne 0) {
            throw 'Could not inspect the complete ordinary candidate path set.'
        }
        $strPathText = ConvertFrom-StrictUtf8Text -Bytes $objPathResult.Bytes `
            -Name 'The ordinary candidate path set' -AllowNul
        $arrChangedPaths = @($strPathText -split "`0" | Where-Object {
                -not [string]::IsNullOrEmpty($_)
            })
        if ($arrChangedPaths.Count -eq 0) {
            throw 'The ordinary candidate has no content change.'
        }
        foreach ($strChangedPath in $arrChangedPaths) {
            if (-not $setOrdinaryPaths.Contains($strChangedPath)) {
                throw "Unsupported ordinary content shape at $strChangedPath; use the stronger reviewed path or a reviewed domain extension."
            }
        }
    }

    $objHistoryResult = Invoke-BoundedProcessByte -FileName 'git' `
        -MaximumBytes 131072 -ArgumentList @(
            '-C', $RepositoryRootPath, 'rev-list', '--parents', '--max-count=65',
            $HeadRevision, '--not', $TrustedRevision, '--'
        )
    $strHistoryText = ConvertFrom-StrictUtf8Text -Bytes $objHistoryResult.Bytes `
        -Name 'The ordinary candidate parent graph'
    $arrHistoryRows = @($strHistoryText.TrimEnd("`n") -split "`n")
    if ($objHistoryResult.ExitCode -ne 0 -or
        $arrHistoryRows.Count -ne [int]$strCommitCount.Trim()) {
        throw 'The ordinary candidate parent graph is incomplete.'
    }
    $intHistoryParentCount = 0
    $intHistoryPathBytes = 0
    $intHistoryGitCalls = 1
    foreach ($strHistoryRow in $arrHistoryRows) {
        if ($strHistoryRow -cnotmatch '^[0-9a-f]{40}(?: [0-9a-f]{40}){1,64}$') {
            throw 'The ordinary candidate parent graph is incomplete or unbounded.'
        }
        $arrCommitAndParents = @($strHistoryRow -split ' ')
        $strHistoryCommit = $arrCommitAndParents[0]
        $arrHistoryParents = @($arrCommitAndParents | Select-Object -Skip 1)
        if ($boolWorkflowIsolation) {
            if (++$intHistoryGitCalls -gt 512) {
                throw 'The ordinary history exceeds 512 Git calls.'
            }
            $objHistoryEntry = Invoke-BoundedProcessByte -FileName 'git' `
                -MaximumBytes 8192 -ArgumentList (
                    @('--literal-pathspecs', '-C', $RepositoryRootPath,
                        'ls-tree', '-z', $strHistoryCommit, '--') +
                    $arrOrdinaryPaths)
            $strHistoryEntry = ConvertFrom-StrictUtf8Text -Bytes $objHistoryEntry.Bytes `
                -Name 'The isolation history entries' -AllowNul
            $arrHistoryEntries = @($strHistoryEntry -split "`0" | Where-Object {
                    -not [string]::IsNullOrEmpty($_)
                })
            if ($objHistoryEntry.ExitCode -ne 0 -or
                $arrHistoryEntries.Count -ne $arrOrdinaryPaths.Count) {
                throw 'The isolation history has missing or unbounded entries.'
            }
            $setHistoryEntryPaths = [Collections.Generic.HashSet[string]]::new(
                [StringComparer]::Ordinal)
            foreach ($strHistoryEntryRow in $arrHistoryEntries) {
                if ($strHistoryEntryRow -cnotmatch
                    '^100644 blob [0-9a-f]{40}\t([^\x00]+)$' -or
                    -not $setOrdinaryPaths.Contains($Matches[1]) -or
                    -not $setHistoryEntryPaths.Add($Matches[1])) {
                    throw 'The isolation history contains a non-regular or duplicate entry.'
                }
            }
        }
        $intHistoryParentCount += $arrHistoryParents.Count
        if ($intHistoryParentCount -gt 256) {
            throw 'The ordinary candidate graph exceeds 256 parent edges.'
        }
        if (++$intHistoryGitCalls -gt 512) {
            throw 'The ordinary history exceeds 512 Git calls.'
        }
        $objHistoryPaths = Invoke-BoundedProcessByte -FileName 'git' `
            -MaximumBytes (1048577 - $intHistoryPathBytes) -ArgumentList @(
                '-C', $RepositoryRootPath, 'diff-tree', '--no-commit-id',
                '--name-only', '-r', '-z', '--no-renames', '--no-ext-diff',
                '--no-textconv', '-m', $strHistoryCommit, '--'
            )
        $intHistoryPathBytes += $objHistoryPaths.Bytes.Length
        if ($objHistoryPaths.ExitCode -ne 0 -or $intHistoryPathBytes -gt 1048576) {
            throw 'The ordinary candidate history paths are incomplete or unbounded.'
        }
        $strHistoryPaths = ConvertFrom-StrictUtf8Text -Bytes $objHistoryPaths.Bytes `
            -Name 'The ordinary candidate history paths' -AllowNul
        $setOutsidePaths = [Collections.Generic.HashSet[string]]::new(
            [StringComparer]::Ordinal)
        foreach ($strHistoryPath in ($strHistoryPaths -split "`0")) {
            if (-not [string]::IsNullOrEmpty($strHistoryPath) -and
                -not $setOrdinaryPaths.Contains($strHistoryPath)) {
                [void]$setOutsidePaths.Add($strHistoryPath)
            }
        }
        if ($setOutsidePaths.Count -eq 0) {
            continue
        }
        $listTrustedParents = [Collections.Generic.List[string]]::new()
        if ($arrHistoryParents.Count -gt 1) {
            foreach ($strHistoryParent in $arrHistoryParents) {
                if (++$intHistoryGitCalls -gt 512) {
                    throw 'The ordinary history exceeds 512 Git calls.'
                }
                $objParentAncestry = Invoke-BoundedProcessByte -FileName 'git' `
                    -MaximumBytes 64 -ArgumentList @(
                        '-C', $RepositoryRootPath, 'merge-base', '--is-ancestor',
                        $strHistoryParent, $TrustedRevision
                    )
                if ($objParentAncestry.ExitCode -eq 0) {
                    $listTrustedParents.Add($strHistoryParent)
                } elseif ($objParentAncestry.ExitCode -ne 1) {
                    throw 'The ordinary merge parent is unavailable.'
                }
            }
        }
        foreach ($strOutsidePath in $setOutsidePaths) {
            $boolTrustedContribution = $false
            foreach ($strTrustedParent in $listTrustedParents) {
                if (($intHistoryGitCalls += 2) -gt 512) {
                    throw 'The ordinary history exceeds 512 Git calls.'
                }
                $objChildEntry = Invoke-BoundedProcessByte -FileName 'git' `
                    -MaximumBytes 8192 -ArgumentList @(
                        '--literal-pathspecs', '-C', $RepositoryRootPath,
                        'ls-tree', '-z', $strHistoryCommit, '--', $strOutsidePath
                    )
                $objParentEntry = Invoke-BoundedProcessByte -FileName 'git' `
                    -MaximumBytes 8192 -ArgumentList @(
                        '--literal-pathspecs', '-C', $RepositoryRootPath,
                        'ls-tree', '-z', $strTrustedParent, '--', $strOutsidePath
                    )
                if ($objChildEntry.ExitCode -ne 0 -or $objParentEntry.ExitCode -ne 0) {
                    throw 'The ordinary merge contribution entry is unavailable.'
                }
                if ([Convert]::ToHexString($objChildEntry.Bytes) -ceq
                    [Convert]::ToHexString($objParentEntry.Bytes)) {
                    $boolTrustedContribution = $true
                    break
                }
            }
            if (-not $boolTrustedContribution) {
                throw "Unsupported ordinary history shape at $strOutsidePath; no exact trusted merge contribution exists."
            }
        }
    }

    $dictionaryTrustedText = [Collections.Generic.Dictionary[string, string]]::new(
        [StringComparer]::Ordinal
    )
    $dictionaryCandidateText = [Collections.Generic.Dictionary[string, string]]::new(
        [StringComparer]::Ordinal
    )
    foreach ($strRevision in @($TrustedRevision, $HeadRevision)) {
        foreach ($strPath in $arrOrdinaryPaths) {
            $objEntry = Invoke-BoundedProcessByte -FileName 'git' -MaximumBytes 1024 `
                -ArgumentList @('-C', $RepositoryRootPath, 'ls-tree', $strRevision,
                    '--', $strPath)
            $strEntry = ConvertFrom-StrictUtf8Text -Bytes $objEntry.Bytes `
                -Name 'An ordinary candidate tree entry'
            if ($objEntry.ExitCode -ne 0 -or
                $strEntry -cnotmatch '^100644 blob ([0-9a-f]{40})\t([^\n]+)\n$' -or
                -not [StringComparer]::Ordinal.Equals($Matches[2], $strPath)) {
                throw 'An ordinary tuple path is missing, linked or not a regular blob.'
            }
            $intMaximumBytes = if ($strPath.EndsWith('.yml',
                    [StringComparison]::Ordinal)) { 131072 } else { 524288 }
            $arrBytes = @(Read-GitBlobByte -RepositoryRootPath $RepositoryRootPath `
                    -BlobId $Matches[1] -MaximumBytes $intMaximumBytes)
            $strText = ConvertFrom-StrictUtf8Text -Bytes $arrBytes -Name $strPath
            if ($strRevision -ceq $TrustedRevision) {
                $dictionaryTrustedText.Add($strPath, $strText)
            } else {
                $dictionaryCandidateText.Add($strPath, $strText)
            }
        }
    }
    $strCatalogPath = $arrOrdinaryPaths[0]
    $strContractPath = $arrOrdinaryPaths[1]
    $strValidatorPath = $arrOrdinaryPaths[2]
    $strWorkflowPath = $arrOrdinaryPaths[3]
    $strBuildPath = $arrOrdinaryPaths[4]
    if ($boolWorkflowIsolation) {
        Assert-WorkflowIsolationReferenceContent `
            -RepositoryRootPath $RepositoryRootPath -TrustedRevision $TrustedRevision `
            -TrustedText $dictionaryTrustedText -CandidateText $dictionaryCandidateText
        return
    }
    if ([regex]::Matches($dictionaryTrustedText[$strValidatorPath],
            $script:strIsolationMarkerPattern).Count -eq 1) {
        throw 'The isolation domain cannot downgrade to the ordinary topology.'
    }
    $boolTrustedStrengthened = $dictionaryTrustedText[$strValidatorPath].Contains(
        'const GENERATOR_RESULT_PREDICATES = Object.freeze([',
        [StringComparison]::Ordinal)
    $boolCandidateStrengthened = $dictionaryCandidateText[$strValidatorPath].Contains(
        'const GENERATOR_RESULT_PREDICATES = Object.freeze([',
        [StringComparison]::Ordinal)
    if ($boolTrustedStrengthened -and -not $boolCandidateStrengthened) {
        throw 'The generator-result domain cannot downgrade strengthened rules.'
    }
    $strExpectedBuild = $dictionaryTrustedText[$strBuildPath]
    if ($boolCandidateStrengthened) {
        $strExpectedValidator = & $script:scriptblockConvertToStrengthenedValidator `
            -Text $dictionaryTrustedText[$strValidatorPath] `
            -TrustedStrengthened $boolTrustedStrengthened
        $dictionaryTrustedText[$strValidatorPath] = $strExpectedValidator
        $intLegacyTailCount = [regex]::Matches($strExpectedBuild,
            [regex]::Escape($script:strLegacyGeneratorResultTail)).Count
        $intBoundedTailCount = [regex]::Matches($strExpectedBuild,
            [regex]::Escape($script:strBoundedGeneratorResultTail)).Count
        if ($intLegacyTailCount -eq 1 -and $intBoundedTailCount -eq 0 -and
            -not $boolTrustedStrengthened) {
            $strExpectedBuild = $strExpectedBuild.Replace(
                $script:strLegacyGeneratorResultTail,
                $script:strBoundedGeneratorResultTail)
        } elseif ($intLegacyTailCount -ne 0 -or $intBoundedTailCount -ne 1) {
            throw 'The trusted generator caller does not match its validator form.'
        }
    }
    if ($strExpectedBuild -cne $dictionaryCandidateText[$strBuildPath]) {
        throw 'The ordinary update changes unsupported generator caller bytes.'
    }
    $strRunStart = "        run: |`n"
    $intRunStart = $strExpectedBuild.IndexOf($strRunStart,
        [StringComparison]::Ordinal) + $strRunStart.Length
    $intRunEnd = $strExpectedBuild.IndexOf(
        "`n      - name: Verify generated artifact drift", [StringComparison]::Ordinal)
    if ($intRunStart -lt $strRunStart.Length -or $intRunEnd -le $intRunStart) {
        throw 'The trusted generator run boundaries are unavailable.'
    }
    $strGeneratorRun = (($strExpectedBuild.Substring(
                $intRunStart, $intRunEnd - $intRunStart).TrimEnd("`n") -split "`n" |
            ForEach-Object { $_.Substring(10) }) -join "`n") + "`n"
    if ($boolCandidateStrengthened -and
        -not [string]::IsNullOrEmpty((& $script:scriptblockGetGeneratorResultCategory `
                    -Text $strGeneratorRun))) {
        throw 'The candidate generator result flow is outside the supported domain.'
    }
    $strAcquireDigest = Assert-OrdinaryHelperWorkflow `
        -TrustedText $dictionaryTrustedText[$strWorkflowPath] `
        -CandidateText $dictionaryCandidateText[$strWorkflowPath]
    $objTrustedCatalog = & $script:scriptblockConvertFromStrictJsonHashtable `
        -Text $dictionaryTrustedText[$strCatalogPath] -Name 'The trusted case catalog'
    $objCandidateCatalog = & $script:scriptblockConvertFromStrictJsonHashtable `
        -Text $dictionaryCandidateText[$strCatalogPath] -Name 'The candidate case catalog'
    & $script:scriptblockAssertExactDictionaryKeySet -Dictionary $objCandidateCatalog `
        -Name 'The ordinary case catalog' -Key @('schema', 'cases')
    if ($objCandidateCatalog.schema -isnot [string] -or
        -not [StringComparer]::Ordinal.Equals(
            $objCandidateCatalog.schema, $objTrustedCatalog.schema) -or
        $objCandidateCatalog.cases -isnot [array] -or
        $objCandidateCatalog.cases.Count -lt $objTrustedCatalog.cases.Count -or
        $objCandidateCatalog.cases.Count -gt 512 -or
        $objCandidateCatalog.cases.Count -gt ($objTrustedCatalog.cases.Count + 32)) {
        throw 'The ordinary case catalog has an invalid schema or count.'
    }
    $setCaseNames = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $objTrustedCatalogDocument = $null
    $objCandidateCatalogDocument = $null
    try {
        $objTrustedCatalogDocument = [System.Text.Json.JsonDocument]::Parse(
            $dictionaryTrustedText[$strCatalogPath])
        $objCandidateCatalogDocument = [System.Text.Json.JsonDocument]::Parse(
            $dictionaryCandidateText[$strCatalogPath])
        $arrTrustedCaseElements = @(
            $objTrustedCatalogDocument.RootElement.GetProperty('cases').EnumerateArray() |
                ForEach-Object { $_.Clone() }
        )
        $arrCandidateCaseElements = @(
            $objCandidateCatalogDocument.RootElement.GetProperty('cases').EnumerateArray() |
                ForEach-Object { $_.Clone() }
        )
    } finally {
        if ($null -ne $objTrustedCatalogDocument) {
            $objTrustedCatalogDocument.Dispose()
        }
        if ($null -ne $objCandidateCatalogDocument) {
            $objCandidateCatalogDocument.Dispose()
        }
    }
    $intLastWorkflowCase = 0
    for ($intIndex = 0; $intIndex -lt $objTrustedCatalog.cases.Count; $intIndex++) {
        $strTrustedCase = & $script:scriptblockConvertToCanonicalJsonText `
            -Value $arrTrustedCaseElements[$intIndex]
        $strCandidateCase = & $script:scriptblockConvertToCanonicalJsonText `
            -Value $arrCandidateCaseElements[$intIndex]
        if (-not [StringComparer]::Ordinal.Equals($strTrustedCase, $strCandidateCase)) {
            throw 'An ordinary update changed or removed an existing case.'
        }
        [void]$setCaseNames.Add([string]$objTrustedCatalog.cases[$intIndex].semanticKey)
        if ($objTrustedCatalog.cases[$intIndex].id -cmatch '^PS-P1-WFPOL-([0-9]{3})$') {
            $intLastWorkflowCase = [Math]::Max($intLastWorkflowCase, [int]$Matches[1])
        }
    }
    for ($intIndex = $objTrustedCatalog.cases.Count;
        $intIndex -lt $objCandidateCatalog.cases.Count; $intIndex++) {
        $objCase = $objCandidateCatalog.cases[$intIndex]
        $arrCaseKeys = @('id', 'semanticKey', 'domain', 'workflow', 'operation', 'expected')
        if ($objCase.Contains('expectedCategory') -and $boolCandidateStrengthened) {
            $arrCaseKeys += 'expectedCategory'
        }
        & $script:scriptblockAssertExactDictionaryKeySet -Dictionary $objCase `
            -Name 'An ordinary new case' -Key $arrCaseKeys
        $intLastWorkflowCase++
        if ($intLastWorkflowCase -gt 999 -or $objCase.id -isnot [string] -or
            -not [StringComparer]::Ordinal.Equals(
                $objCase.id, ('PS-P1-WFPOL-{0:D3}' -f $intLastWorkflowCase)) -or
            $objCase.semanticKey -isnot [string] -or
            $objCase.semanticKey -cnotmatch '^[a-z0-9-]{1,128}$' -or
            -not $setCaseNames.Add($objCase.semanticKey) -or
            $objCase.domain -isnot [string] -or
            -not [StringComparer]::Ordinal.Equals($objCase.domain, 'workflow') -or
            $objCase.workflow -isnot [string] -or
            -not $setOrdinaryWorkflows.Contains($objCase.workflow) -or
            $objCase.expected -isnot [bool] -or $objCase.expected -or
            $objCase.operation -isnot [Collections.IDictionary]) {
            throw 'An ordinary new case is not a sequential negative workflow fixture.'
        }
        if (-not $objCase.operation.Contains('type') -or
            $objCase.operation.type -isnot [string] -or
            -not $setOrdinaryOperations.Contains($objCase.operation.type)) {
            throw 'An ordinary fixture uses an unsupported operation.'
        }
        $arrOperationKeys = switch -CaseSensitive ($objCase.operation.type) {
            'set' {
                @('type', 'path', 'value')
            }
            'delete' {
                @('type', 'path')
            }
            'append' {
                @('type', 'path', 'value')
            }
            'append-copy' {
                @('type', 'path', 'source')
            }
            'swap' {
                @('type', 'path', 'otherPath')
            }
            'replace' {
                @('type', 'path', 'from', 'to')
            }
            default {
                throw 'An ordinary fixture uses an unsupported operation.'
            }
        }
        & $script:scriptblockAssertExactDictionaryKeySet -Dictionary $objCase.operation `
            -Name 'An ordinary fixture operation' -Key $arrOperationKeys
        foreach ($strPointerKey in @('path', 'source', 'otherPath')) {
            if ($objCase.operation.Contains($strPointerKey) -and
                ($objCase.operation[$strPointerKey] -isnot [string] -or
                    $objCase.operation[$strPointerKey] -cnotmatch '^/[^\x00-\x20]{1,1023}$' -or
                    $objCase.operation[$strPointerKey] -cmatch
                    '(?:^|/)(?:__proto__|constructor|prototype)(?:/|$)')) {
                throw 'An ordinary fixture has an unsafe or invalid JSON pointer.'
            }
        }
        if ([StringComparer]::Ordinal.Equals($objCase.operation.type, 'replace') -and
            ($objCase.operation.from -isnot [string] -or
                [string]::IsNullOrEmpty($objCase.operation.from) -or
                $objCase.operation.to -isnot [string])) {
            throw 'An ordinary replacement fixture has invalid text operands.'
        }
        if ($objCase.Contains('expectedCategory')) {
            & $script:scriptblockAssertGeneratorResultCase -Case $objCase `
                -RunText $strGeneratorRun
        } elseif ($boolCandidateStrengthened -and -not $boolTrustedStrengthened) {
            throw 'A strengthening transition may add only proved generator-result cases.'
        }
    }

    if ($boolCandidateStrengthened -and -not $boolTrustedStrengthened) {
        foreach ($objRequiredCase in $script:arrRequiredGeneratorResultCase) {
            $arrMatches = @($objCandidateCatalog.cases | Where-Object {
                    $_.semanticKey -ceq $objRequiredCase.semanticKey
                })
            if ($arrMatches.Count -ne 1 -or
                (& $script:scriptblockConvertToCanonicalJsonText -Value $arrMatches[0]) -cne
                (& $script:scriptblockConvertToCanonicalJsonText -Value $objRequiredCase)) {
                throw 'The strengthening transition lacks an exact required semantic case.'
            }
        }
    }

    $objTrustedContract = & $script:scriptblockConvertFromStrictJsonHashtable `
        -Text $dictionaryTrustedText[$strContractPath] -Name 'The trusted policy contract'
    $objCandidateContract = & $script:scriptblockConvertFromStrictJsonHashtable `
        -Text $dictionaryCandidateText[$strContractPath] -Name 'The candidate policy contract'
    if ($boolCandidateStrengthened) {
        if (-not $objCandidateContract.workflowPolicy.Contains('generatorResultPolicy') -or
            (& $script:scriptblockConvertToCanonicalJsonText `
                    -Value $objCandidateContract.workflowPolicy.generatorResultPolicy) -cne
            (& $script:scriptblockConvertToCanonicalJsonText `
                    -Value $script:objGeneratorResultPolicy)) {
            throw 'The strengthened generator result policy is missing or inconsistent.'
        }
        if ($boolTrustedStrengthened -and
            (-not $objTrustedContract.workflowPolicy.Contains('generatorResultPolicy') -or
                (& $script:scriptblockConvertToCanonicalJsonText `
                        -Value $objTrustedContract.workflowPolicy.generatorResultPolicy) -cne
                (& $script:scriptblockConvertToCanonicalJsonText `
                        -Value $script:objGeneratorResultPolicy))) {
            throw 'The trusted strengthened contract has an inconsistent policy.'
        }
        $objTrustedContract.workflowPolicy.generatorResultPolicy =
            $script:objGeneratorResultPolicy
        $strRunDigest = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData(
                [Text.UTF8Encoding]::new($false).GetBytes($strGeneratorRun)
            )).ToLowerInvariant()
        $objTrustedContract.workflowPolicy.workflows['build.yml'].jobs.
            verify_generated_artifacts.steps[1].runSha256 = $strRunDigest
    }
    $objTrustedAcquire = $objTrustedContract.workflowPolicy.workflows['pull-request-body-identity.yml'].jobs.verify_identity.steps[0]
    $objCandidateAcquire = $objCandidateContract.workflowPolicy.workflows['pull-request-body-identity.yml'].jobs.verify_identity.steps[0]
    if ($objCandidateAcquire.runSha256 -isnot [string] -or
        $objCandidateAcquire.runSha256 -cne $strAcquireDigest) {
        throw 'The ordinary helper acquisition digest is stale or inconsistent.'
    }
    $objTrustedAcquire.runSha256 = $strAcquireDigest
    foreach ($strIdentity in @('caseCatalog', 'validatorIdentity')) {
        & $script:scriptblockAssertExactDictionaryKeySet `
            -Dictionary $objCandidateContract[$strIdentity] `
            -Name 'An ordinary content identity' -Key @('path', 'sha256')
        $strIdentityPath = if ($strIdentity -ceq 'caseCatalog') {
            $strCatalogPath
        } else {
            $strValidatorPath
        }
        $strDigest = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData(
                [Text.UTF8Encoding]::new($false).GetBytes(
                    $dictionaryCandidateText[$strIdentityPath]
                )
            )).ToLowerInvariant()
        if ($objCandidateContract[$strIdentity].sha256 -isnot [string] -or
            -not [StringComparer]::Ordinal.Equals(
                $objCandidateContract[$strIdentity].sha256, $strDigest)) {
            throw 'The ordinary content tuple has a mismatched raw-byte digest.'
        }
        $objTrustedContract[$strIdentity].sha256 = $strDigest
    }
    $objTrustedDocument = $null
    $objCandidateDocument = $null
    try {
        $objTrustedDocument = [System.Text.Json.JsonDocument]::Parse(
            $dictionaryTrustedText[$strContractPath])
        $objCandidateDocument = [System.Text.Json.JsonDocument]::Parse(
            $dictionaryCandidateText[$strContractPath])
        $objExpectedView = [ordered]@{}
        foreach ($objProperty in $objTrustedDocument.RootElement.EnumerateObject()) {
            $objExpectedView[$objProperty.Name] = if (
                [StringComparer]::Ordinal.Equals($objProperty.Name, 'caseCatalog') -or
                [StringComparer]::Ordinal.Equals($objProperty.Name, 'validatorIdentity') -or
                [StringComparer]::Ordinal.Equals($objProperty.Name, 'workflowPolicy')) {
                $objTrustedContract[$objProperty.Name]
            } else {
                $objProperty.Value
            }
        }
        $strExpectedContract = & $script:scriptblockConvertToCanonicalJsonText `
            -Value $objExpectedView
        $strCandidateContract = & $script:scriptblockConvertToCanonicalJsonText `
            -Value $objCandidateDocument.RootElement
        if (-not [StringComparer]::Ordinal.Equals($strExpectedContract, $strCandidateContract)) {
            throw 'The ordinary update changes policy rules or contract structure.'
        }
        $objIdentityView = [ordered]@{}
        foreach ($objProperty in $objCandidateDocument.RootElement.EnumerateObject()) {
            if (-not [StringComparer]::Ordinal.Equals($objProperty.Name, 'validatorIdentity')) {
                $objIdentityView[$objProperty.Name] = $objProperty.Value
            }
        }
        $strIdentityView = & $script:scriptblockConvertToCanonicalJsonText `
            -Value $objIdentityView
    } finally {
        if ($null -ne $objTrustedDocument) {
            $objTrustedDocument.Dispose()
        }
        if ($null -ne $objCandidateDocument) {
            $objCandidateDocument.Dispose()
        }
    }
    $strCanonicalDigest = [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData(
            [Text.UTF8Encoding]::new($false).GetBytes($strIdentityView)
        )).ToLowerInvariant()
    $strTrustedValidator = $dictionaryTrustedText[$strValidatorPath]
    $strCandidateValidator = $dictionaryCandidateText[$strValidatorPath]
    $strVersionPattern = "(?m)^const VALIDATOR_VERSION = '([0-9]+)\.([0-9]+)\.([0-9]+)';$"
    $strDigestPattern = "(?m)^const EXPECTED_CONTRACT_CANONICAL_SHA256 = '[0-9a-f]{64}';$"
    $arrVersionMatches = [regex]::Matches($strTrustedValidator, $strVersionPattern)
    if ($arrVersionMatches.Count -ne 1 -or
        [regex]::Matches($strTrustedValidator, $strDigestPattern).Count -ne 1 -or
        [regex]::Matches($strCandidateValidator, $strVersionPattern).Count -ne 1 -or
        [regex]::Matches($strCandidateValidator, $strDigestPattern).Count -ne 1) {
        throw 'The ordinary validator has missing or duplicate identity literals.'
    }
    $objVersionMatch = $arrVersionMatches[0]
    $intNextPatch = [int]$objVersionMatch.Groups[3].Value + 1
    $strNextVersion = "const VALIDATOR_VERSION = '{0}.{1}.{2}';" -f
        $objVersionMatch.Groups[1].Value, $objVersionMatch.Groups[2].Value, $intNextPatch
    $strExpectedValidator = [regex]::Replace($strTrustedValidator,
        $strVersionPattern, $strNextVersion)
    $strExpectedValidator = [regex]::Replace($strExpectedValidator,
        $strDigestPattern,
        "const EXPECTED_CONTRACT_CANONICAL_SHA256 = '$strCanonicalDigest';")
    if (-not $strExpectedValidator.EndsWith("`n", [StringComparison]::Ordinal) -or
        -not $strCandidateValidator.StartsWith($strExpectedValidator,
            [StringComparison]::Ordinal)) {
        throw 'Unsupported ordinary validator shape; executable rules must remain unchanged.'
    }
    $strCommentSuffix = $strCandidateValidator.Substring($strExpectedValidator.Length)
    if ($strCommentSuffix.Length -gt 8192 -or
        $strCommentSuffix -cnotmatch '\A(?:// [\x20-\x7e]*\n|\n)*\z' -or
        $strCommentSuffix.Contains('EXPECTED_CONTRACT_CANONICAL_SHA256',
            [StringComparison]::Ordinal) -or
        $strCommentSuffix.Contains('VALIDATOR_VERSION', [StringComparison]::Ordinal)) {
        throw 'An ordinary validator suffix is not bounded inert line comments.'
    }
    if ($script:boolValidateOrdinaryCaseCatalog -and
        (-not $boolCandidateStrengthened -or $boolTrustedStrengthened)) {
        $objCatalogPreflight = Invoke-BoundedProcessByte -FileName 'node' `
            -ArgumentList @((Join-Path $RepositoryRootPath $strValidatorPath), '--preflight') `
            -MaximumBytes 65536 -TimeoutMilliseconds 60000
        if ($objCatalogPreflight.ExitCode -ne 0) {
            throw 'The trusted ordinary catalog preflight failed.'
        }
        $objCatalogOutcome = Invoke-BoundedProcessByte -FileName 'node' `
            -ArgumentList @((Join-Path $RepositoryRootPath $strValidatorPath), '--ordinary-case-catalog-data') `
            -InputBytes ([Text.UTF8Encoding]::new($false, $true).GetBytes($dictionaryCandidateText[$strCatalogPath])) `
            -MaximumBytes 65536 -TimeoutMilliseconds 60000
        if ($objCatalogOutcome.ExitCode -ne 0) {
            throw 'The trusted ordinary case outcomes failed.'
        }
    }
}


function Get-TrustedPolicyReferenceText {
    # .SYNOPSIS
    # Reads one fixed policy reference from the authenticated trusted revision.
    #
    # .DESCRIPTION
    # Production reads a regular Git blob, never a worktree or candidate.
    # SelfTest alone reads local fixture bytes and returns before admission.
    # References are cached only within this script invocation.
    #
    # .PARAMETER Path
    # One fixed policy path whose exact unchanged bytes can be recognized.
    #
    # .EXAMPLE
    # Get-TrustedPolicyReferenceText -Path '.github/workflows/Validate-WorkflowPolicy.mjs'
    #
    # # Returns the exact trusted text or throws for a missing reference.
    #
    # .INPUTS
    # None. This helper does not accept pipeline input.
    #
    # .OUTPUTS
    # [string] Exact strict UTF-8 reference text, or empty when a historical
    # detached verifier has no reference. Empty text never grants admission.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20260914.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('.github/workflows/Validate-WorkflowPolicy.mjs',
            '.github/workflows/workflow-policy-contract.json',
            '.github/workflows/workflow-policy-cases.json',
            '.github/workflows/pull-request-body-identity.yml', IgnoreCase = $false)]
        [string] $Path
    )

    $setReferencePaths = [Collections.Generic.HashSet[string]]::new(
        [string[]]@('.github/workflows/Validate-WorkflowPolicy.mjs',
            '.github/workflows/workflow-policy-contract.json',
            '.github/workflows/workflow-policy-cases.json',
            '.github/workflows/pull-request-body-identity.yml'),
        [StringComparer]::Ordinal)
    if (-not $setReferencePaths.Contains($Path)) {
        throw 'The trusted policy reference path is not an exact fixed path.'
    }
    if (-not $script:dictionaryPolicyReferenceText.ContainsKey($Path)) {
        $arrBytes = if ($SelfTest) {
            $strFixturePath = $ExecutionContext.SessionState.Path.
                GetUnresolvedProviderPathFromPSPath((Join-Path -Path $RepositoryRootPath -ChildPath $Path))
            [IO.File]::ReadAllBytes($strFixturePath)
        } else {
            $objEntry = Invoke-BoundedProcessByte -FileName 'git' -MaximumBytes 1024 `
                -ArgumentList @('-C', $RepositoryRootPath, 'ls-tree', $TrustedRevision,
                    '--', $Path)
            $strEntry = ConvertFrom-StrictUtf8Text -Bytes $objEntry.Bytes `
                -Name 'The trusted policy reference tree entry'
            if ($objEntry.ExitCode -eq 0 -and [string]::IsNullOrEmpty($strEntry)) {
                # Historical detached verifier refs can omit policy files.
                # Only their independent hardcoded exact tuples can pass.
                return ''
            }
            if ($objEntry.ExitCode -ne 0 -or
                $strEntry -cnotmatch '^100644 blob ([0-9a-f]{40})\t([^\n]+)\n$' -or
                -not [StringComparer]::Ordinal.Equals($Matches[2], $Path)) {
                throw 'The authenticated trusted policy reference is unavailable.'
            }
            @(Read-GitBlobByte -RepositoryRootPath $RepositoryRootPath `
                -BlobId $Matches[1] -MaximumBytes 524288)
        }
        if ($arrBytes.Count -gt 524288) {
            throw 'The trusted policy reference exceeds its byte bound.'
        }
        $script:dictionaryPolicyReferenceText.Add($Path,
            (ConvertFrom-StrictUtf8Text -Bytes $arrBytes -Name $Path))
    }
    return $script:dictionaryPolicyReferenceText[$Path]
}


function Assert-WorkflowPolicyTransitionTuple {
    # .SYNOPSIS
    # Validates one complete workflow-policy identity transition tuple.
    #
    # .DESCRIPTION
    # Accepts exactly the current tuple or the intended next tuple across the
    # validator and contract. Rejects mixed, missing, and duplicate tuples.
    #
    # .PARAMETER ValidatorText
    # The strict UTF-8 workflow-policy validator source text.
    #
    # .PARAMETER ContractText
    # The strict UTF-8 workflow-policy contract source text.
    #
    # .EXAMPLE
    # Assert-WorkflowPolicyTransitionTuple @hashtableArguments
    #
    # # Validates the cross-file identity tuple or throws.
    #
    # .INPUTS
    # None. This helper does not accept pipeline input.
    #
    # .OUTPUTS
    # None. This helper returns no output.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.1.20260914.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)][string] $ValidatorText,
        [Parameter(Mandatory)][string] $ContractText
    )

    if (-not [string]::IsNullOrEmpty($ValidatorText) -and
        -not [string]::IsNullOrEmpty($ContractText) -and
        [StringComparer]::Ordinal.Equals($ValidatorText,
            (Get-TrustedPolicyReferenceText `
                -Path '.github/workflows/Validate-WorkflowPolicy.mjs')) -and
        [StringComparer]::Ordinal.Equals($ContractText,
            (Get-TrustedPolicyReferenceText `
                -Path '.github/workflows/workflow-policy-contract.json'))) {
        return
    }
    $objContract = & $script:scriptblockConvertFromStrictJsonHashtable `
        -Text $ContractText -Name 'The workflow-policy transition contract'
    $strContractValidatorSha256 =
        [string] $objContract.validatorIdentity.sha256
    $strValidatorSha256 = [Convert]::ToHexString(
        [Security.Cryptography.SHA256]::HashData(
            [Text.UTF8Encoding]::new($false).GetBytes($ValidatorText)
        )
    ).ToLowerInvariant()
    $objContractDocument = $null
    try {
        $objContractDocument =
            [System.Text.Json.JsonDocument]::Parse($ContractText)
        Assert-NoDuplicateJsonProperty `
            -Element $objContractDocument.RootElement
        $objContractIdentityView = [ordered]@{}
        foreach ($objContractProperty in
            $objContractDocument.RootElement.EnumerateObject()) {
            if ($objContractProperty.Name -cne 'validatorIdentity') {
                $objContractIdentityView[$objContractProperty.Name] =
                    $objContractProperty.Value
            }
        }
        $strContractCanonicalText =
            & $script:scriptblockConvertToCanonicalJsonText `
            -Value $objContractIdentityView
    } finally {
        if ($null -ne $objContractDocument) {
            $objContractDocument.Dispose()
        }
    }
    $strContractCanonicalSha256 = [Convert]::ToHexString(
        [Security.Cryptography.SHA256]::HashData(
            [Text.UTF8Encoding]::new($false).GetBytes(
                $strContractCanonicalText
            )
        )
    ).ToLowerInvariant()
    $arrTuple = @(
        [pscustomobject]@{
            VersionLiteral = "const VALIDATOR_VERSION = '1.2.2';"
            DigestLiteral =
                "const EXPECTED_CONTRACT_CANONICAL_SHA256 = '99bbdec8c80cced95287b50707a70071fe785e0dc5a715bf7439c8d04d5d52d6';"
            ValidatorSha256 =
                '33554c001f6613be74db3644aa097e18322c2cf9ab7e064e721006ba456a58a9'
            ContractCanonicalSha256 =
                '99bbdec8c80cced95287b50707a70071fe785e0dc5a715bf7439c8d04d5d52d6'
        },
        [pscustomobject]@{
            VersionLiteral = "const VALIDATOR_VERSION = '1.2.3';"
            DigestLiteral =
                "const EXPECTED_CONTRACT_CANONICAL_SHA256 = 'c54d390c79bcd7a17d2acc214ee412d8b40c2eee310c28917df2260837dda9bb';"
            ValidatorSha256 =
                'ca9b76f363f2f94209cc1e33fe1ea5a61ce6ad2b1fedcafabd5e06e2e65e3202'
            ContractCanonicalSha256 =
                'c54d390c79bcd7a17d2acc214ee412d8b40c2eee310c28917df2260837dda9bb'
        },
        [pscustomobject]@{
            VersionLiteral = "const VALIDATOR_VERSION = '1.2.4';"
            DigestLiteral =
                "const EXPECTED_CONTRACT_CANONICAL_SHA256 = 'd29855fa383bb5ef8255b18a4287e6da45e73814755eafa65dab060d80941824';"
            ValidatorSha256 =
                '386ed401ec8a3488e8d03a068a38b9fcd965c9f2a158c565a7cb7e20a03c0dbb'
            ContractCanonicalSha256 =
                'd29855fa383bb5ef8255b18a4287e6da45e73814755eafa65dab060d80941824'
        },
        [pscustomobject]@{
            VersionLiteral = "const VALIDATOR_VERSION = '1.2.6';"
            DigestLiteral =
                "const EXPECTED_CONTRACT_CANONICAL_SHA256 = '98ad8ff52efd053a1a0e48a54b7ce388ebba498446130051d34259564faf75d0';"
            ValidatorSha256 =
                '481b301a3557680ceef40dcfa15ab3f73bda0ff5d132afc15cd900221180cdc6'
            ContractCanonicalSha256 =
                '98ad8ff52efd053a1a0e48a54b7ce388ebba498446130051d34259564faf75d0'
        },
        [pscustomobject]@{
            VersionLiteral = "const VALIDATOR_VERSION = '1.2.7';"
            DigestLiteral =
                "const EXPECTED_CONTRACT_CANONICAL_SHA256 = '0490a0fafe4e58a57990c8286771cec8d6605891d884ff30dc6a1c5193aeff2c';"
            ValidatorSha256 =
                '45452a233005379579f8eedf626cadf8b9af7a05767463c4f225ac82524f9791'
            ContractCanonicalSha256 =
                '0490a0fafe4e58a57990c8286771cec8d6605891d884ff30dc6a1c5193aeff2c'
        },
        [pscustomobject]@{
            VersionLiteral = "const VALIDATOR_VERSION = '1.2.8';"
            DigestLiteral =
                "const EXPECTED_CONTRACT_CANONICAL_SHA256 = 'd6b5ad4774bbd4fed0608eec3e885d63f9c1b30951aa363a9a3e947a94cd0573';"
            ValidatorSha256 =
                'df9e8a124fcd62996b0d2e70571042deeaf9e248c0b9150850378271c974606c'
            ContractCanonicalSha256 =
                'd6b5ad4774bbd4fed0608eec3e885d63f9c1b30951aa363a9a3e947a94cd0573'
        }
    )
    $intVersionLiteralCount = 0
    $intDigestLiteralCount = 0
    $intMatchingTupleCount = 0
    foreach ($objTuple in $arrTuple) {
        $intVersionCount = [regex]::Matches(
            $ValidatorText,
            [regex]::Escape($objTuple.VersionLiteral)
        ).Count
        $intDigestCount = [regex]::Matches(
            $ValidatorText,
            [regex]::Escape($objTuple.DigestLiteral)
        ).Count
        $intVersionLiteralCount += $intVersionCount
        $intDigestLiteralCount += $intDigestCount
        if ($intVersionCount -eq 1 -and $intDigestCount -eq 1 -and
            $strValidatorSha256 -ceq $objTuple.ValidatorSha256 -and
            $strContractValidatorSha256 -ceq $objTuple.ValidatorSha256 -and
            $strContractCanonicalSha256 -ceq
                $objTuple.ContractCanonicalSha256) {
            $intMatchingTupleCount++
        }
    }
    if ($intVersionLiteralCount -ne 1 -or
        $intDigestLiteralCount -ne 1 -or
        $intMatchingTupleCount -ne 1) {
        throw 'The workflow-policy identity transition tuple is mixed or invalid.'
    }
}

function Assert-SemanticInvariant {
    # .SYNOPSIS
    # Validates one named trust-root semantic invariant.
    #
    # .DESCRIPTION
    # Applies the trusted structural or exact-text check for one authorized
    # candidate path and rejects unknown or unsatisfied invariant names.
    #
    # .PARAMETER Invariant
    # The exact trusted semantic-invariant identifier.
    #
    # .PARAMETER Text
    # The strict UTF-8 candidate text to inspect as inert data.
    #
    # .PARAMETER Path
    # The repository-relative path used in failure diagnostics.
    #
    # .EXAMPLE
    # Assert-SemanticInvariant -Invariant $strInvariant `
    #     -Text $strText -Path $strPath
    #
    # # Returns only when the named invariant is satisfied.
    #
    # .INPUTS
    # None. This helper does not accept pipeline input.
    #
    # .OUTPUTS
    # None. This helper returns no output.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.1.20260914.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)][string] $Invariant,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Text,
        [Parameter(Mandatory)][string] $Path
    )

    if ($script:hashtableSemanticInvariantPath.ContainsKey($Invariant) -and
        -not [StringComparer]::Ordinal.Equals(
            $Path, $script:hashtableSemanticInvariantPath[$Invariant])) {
        throw "$Path does not satisfy semantic invariant $Invariant."
    }

    $setReferenceInvariants = [Collections.Generic.HashSet[string]]::new(
        [string[]]@(
            'workflow-policy-preflight-authenticates-deferred-yaml-import',
            'workflow-policy-contract-identities-and-structure-are-exact',
            'workflow-policy-identity-cases-are-exact',
            'pull-request-body-identity-workflow-topology-is-exact'
        ), [StringComparer]::Ordinal)
    if ($setReferenceInvariants.Contains($Invariant) -and
        -not [string]::IsNullOrEmpty($Text) -and
        [StringComparer]::Ordinal.Equals($Text, (Get-TrustedPolicyReferenceText -Path $Path))) {
        return
    }

    if ($script:hashtableExactTransitionTextIdentity.ContainsKey($Invariant)) {
        $strTextSha256 = [Convert]::ToHexString(
            [Security.Cryptography.SHA256]::HashData(
                [Text.UTF8Encoding]::new($false).GetBytes($Text)
            )
        ).ToLowerInvariant()
        if ($script:hashtableExactTransitionTextIdentity[$Invariant] `
            -cnotcontains $strTextSha256) {
            throw "$Path does not satisfy semantic invariant $Invariant."
        }
        return
    }

    if ($Invariant -ceq
        'parser-manifest-direct-roots-and-closure-is-exact') {
        $arrRequiredLiteral = @(
            'const EXECUTABLE_PARSER_NAMES = ["js-yaml", "markdown-it"];',
            'const EXECUTABLE_PARSER_PATHS = EXECUTABLE_PARSER_NAMES.map(',
            'function resolveDependencyPath(packages, packagePath, dependencyName) {',
            'function getDependencyNames(descriptor) {',
            'function getParserClosure(lock, name) {',
            'const queue = [...EXECUTABLE_PARSER_PATHS];',
            'queue.push(resolveDependencyPath(packages, packagePath, dependencyName));',
            'const trustedPaths = [...trustedClosure.keys()].sort();',
            'const inputPaths = [...inputClosure.keys()].sort();',
            'if (stableJson(inputPaths) !== stableJson(trustedPaths)) {',
            'if (stableJson(inputClosure.get(packagePath)) !== stableJson(trustedClosure.get(packagePath))) {',
            '["direct deletion", (pkg) => delete pkg.devDependencies["markdown-it"], "must declare"],',
            '["direct drift", (pkg) => (pkg.devDependencies["markdown-it"] = "14.2.1"), "must declare"],',
            '["js-yaml direct deletion", (pkg) => delete pkg.devDependencies["js-yaml"], "must declare"],',
            '["js-yaml direct drift", (pkg) => (pkg.devDependencies["js-yaml"] = "5.2.1"), "must declare"],',
            '"js-yaml root lock drift",',
            '"parser integrity drift",',
            '"js-yaml version drift",',
            '"js-yaml resolved drift",',
            '"js-yaml integrity drift",',
            '"js-yaml dependency edge drift",',
            '"transitive version drift",',
            '"transitive resolved drift",',
            '"transitive integrity drift",',
            '"closure deletion",',
            '"closure shadowing",',
            'const unrelatedPackage = clone(inputPackage);',
            'const unrelatedLock = clone(inputLock);',
            'unrelatedLock.packages["node_modules/unrelated"] = {',
            'validateContract(trustedPackage, trustedLock, unrelatedPackage, unrelatedLock);'
        )
        foreach ($strRequiredLiteral in $arrRequiredLiteral) {
            if (-not $Text.Contains(
                    $strRequiredLiteral,
                    [StringComparison]::Ordinal
                )) {
                throw "$Path does not satisfy semantic invariant $Invariant."
            }
        }
        if ([regex]::Matches(
                $Text,
                [regex]::Escape(
                    'const EXECUTABLE_PARSER_NAMES = ["js-yaml", "markdown-it"];'
                )
            ).Count -ne 1 -or
            $Text.Contains('const PARSER_NAME =', [StringComparison]::Ordinal) -or
            $Text.Contains('const PARSER_PATH =', [StringComparison]::Ordinal) -or
            $Text -cnotmatch
                '(?s)for \(const parserName of EXECUTABLE_PARSER_NAMES\) \{.*?' +
                'trustedDevDependencies\[parserName\] !== expectedVersion.*?' +
                'trustedRootDevDependencies\[parserName\] !== expectedVersion.*?' +
                'inputDevDependencies\[parserName\] !== expectedVersion.*?' +
                'inputRootDevDependencies\[parserName\] !== expectedVersion.*?' +
                '\n  \}') {
            throw "$Path does not satisfy semantic invariant $Invariant."
        }
        return
    }

    if ($Invariant -ceq
        'agent-instruction-heading-status-and-bootstrap-order-is-exact') {
        $arrTokens = $null
        $arrParseErrors = $null
        $objAst = [Management.Automation.Language.Parser]::ParseInput(
            $Text,
            $Path,
            [ref] $arrTokens,
            [ref] $arrParseErrors
        )
        $arrPredicateFunctions = @($objAst.FindAll({
                    param($objNode)
                    $objNode -is
                        [Management.Automation.Language.FunctionDefinitionAst] -and
                    $objNode.Name -ceq 'Test-DecisionLifecycleStatusLabel'
                }, $true))
        $arrPredicateCalls = @($objAst.FindAll({
                    param($objNode)
                    $objNode -is [Management.Automation.Language.CommandAst] -and
                    $objNode.GetCommandName() -ceq
                        'Test-DecisionLifecycleStatusLabel'
                }, $true))
        $intLifecycleConsumerCalls = 0
        foreach ($objPredicateCall in $arrPredicateCalls) {
            $objParent = $objPredicateCall.Parent
            while ($null -ne $objParent -and
                $objParent -isnot
                    [Management.Automation.Language.FunctionDefinitionAst]) {
                $objParent = $objParent.Parent
            }
            if ($null -ne $objParent -and
                $objParent.Name -ceq 'Get-DecisionRecordLifecycleFailure') {
                $intLifecycleConsumerCalls++
            }
        }
        $arrRequiredLiteral = @(
            'if (token.type !== "heading_open" || token.level !== 0) return [];',
            '$strNormalizedLabel = [regex]::Replace($Label.Trim(), ''\s+'', '' '')',
            '$strNormalizedLabel -ieq ''Status'' -or',
            '$strNormalizedLabel -ieq ''Decision Status''',
            '$objMarkdownContext.Headings |',
            'Test-DecisionLifecycleStatusLabel -Label $_.Text',
            'Test-DecisionLifecycleStatusLabel `',
            'Name = ''quoted level-three Status heading''',
            'Name = ''listed level-four Status heading''',
            'Name = ''fenced level-three Status heading example''',
            'Name = ''indented level-three Status heading example''',
            'Name = ''commented level-three Status heading example''',
            'Name = ''inline-code-only level-three Status heading example''',
            'Name = ''raw-HTML-only level-three Status heading example''',
            '''### Decision **Status**''',
            '''#### Decision [Status](https://example.invalid/status)''',
            '''##### Status''',
            '''###### Decision Status''',
            '''HTTP Status Codes'', ''Deployment Status'',',
            '''Deployment Status Checks'', ''Status Check''',
            'throw ''A Decision Status section escaped lifecycle validation.''',
            'throw ''A Decision Status field escaped lifecycle validation.''',
            'throw ''A Status prose field escaped lifecycle validation.''',
            'Name = ''body Decision Status field with alignment and inline formatting''',
            'Name = ''unrelated exact two-cell Deployment Status data row''',
            '$strParserManifestValidationCall =',
            '''node .github/workflows/Test-AgentInstructionParserManifest.mjs''',
            '$strPolicyPreflightCall =',
            '''node .github/workflows/Validate-WorkflowPolicy.mjs --preflight''',
            '$strLockedDependencyInstallCall =',
            '''npm ci --ignore-scripts --no-audit --fund=false''',
            '$strWorkflowPolicyInstallCall =',
            '''npm --prefix .github/workflows ci --ignore-scripts --no-audit''',
            '$strTrustRootAuthorizationCall =',
            '''& ./.github/workflows/Test-TrustRootAuthorization.ps1''',
            '[regex]::Escape($strPolicyPreflightCall)).Count -ne 2 -or',
            '[regex]::Escape($strWorkflowPolicyInstallCall)).Count -ne 1 -or',
            '-not $objDependencyStep.Success -or',
            'github.event_name != ''push'' \|\|`r?`n',
            '$intWorkflowPolicyBootstrap -le $intParserManifestValidation -or',
            '$intLockedDependencyInstall -le $intWorkflowPolicyBootstrap -or',
            '$intWorkflowPolicyDependencyInstall -le $intLockedDependencyInstall -or',
            '$intTrustRootAuthorization -le $intWorkflowPolicyDependencyInstall -or',
            '$intWorkflowPolicyUsePreflight -le $intTrustRootAuthorization -or',
            '$intOrdinaryCaseData -le $intWorkflowPolicyUsePreflight',
            '$strUnsafeParserOrderMutation = $strAgentWorkflowContent.Replace(',
            'throw ''An unsafe executable parser validation order did not fail closed.''',
            '$strPolicyOrderMutation =',
            'throw ''An unsafe workflow policy dependency mutation did not fail closed.'''
        )
        foreach ($strRequiredLiteral in $arrRequiredLiteral) {
            if (-not $Text.Contains(
                    $strRequiredLiteral,
                    [StringComparison]::Ordinal
                )) {
                throw "$Path does not satisfy semantic invariant $Invariant."
            }
        }
        if ($arrParseErrors.Count -ne 0 -or
            $arrPredicateFunctions.Count -ne 1 -or
            $arrPredicateCalls.Count -ne 5 -or
            $intLifecycleConsumerCalls -ne 3 -or
            [regex]::Matches(
                $Text,
                [regex]::Escape(
                    'if (token.type !== "heading_open" || token.level !== 0) return [];'
                )
            ).Count -ne 2) {
            throw "$Path does not satisfy semantic invariant $Invariant."
        }
        return
    }

    if ($Invariant -ceq
        'pull-request-body-identity-cases-preserve-required-coverage') {
        $objCatalogDocument = $null
        try {
            $objCatalogDocument = [System.Text.Json.JsonDocument]::Parse($Text)
            Assert-NoDuplicateJsonProperty `
                -Element $objCatalogDocument.RootElement
        } catch {
            throw "$Path does not satisfy semantic invariant $Invariant."
        } finally {
            if ($null -ne $objCatalogDocument) {
                $objCatalogDocument.Dispose()
            }
        }
        $objCatalog = & $script:scriptblockConvertFromStrictJsonHashtable `
            -Text $Text -Name $Path
        & $script:scriptblockAssertExactDictionaryKeySet `
            -Dictionary $objCatalog -Name $Path -Key @(
                'schema', 'sourceCases', 'bodyCases', 'remoteCases'
            )
        if ($objCatalog.schema -cne
            'PSStyleGuide.PullRequestBodyIdentityCases.v1') {
            throw "$Path does not satisfy semantic invariant $Invariant."
        }

        $hashtableExpectedField = @{
            sourceCases = @('id', 'mutation', 'expected')
            bodyCases = @('id', 'operation', 'fixture', 'expected')
            remoteCases = @(
                'id', 'scenario', 'expected', 'expectedPatchCount'
            )
        }
        $hashtableRequiredCase = @{
            sourceCases = @(
                'source-current|none|current',
                'source-contract-malformed-json|contract-malformed-json|contract-json',
                'source-contract-forbidden-key|contract-forbidden-key|contract-json',
                'source-generator-version-malformed|generator-policy-version-malformed|generator-policy',
                'source-generator-digest-malformed|generator-policy-digest-malformed|generator-policy',
                'source-generator-version-drift|generator-version-drift|generator-identity',
                'source-generator-duplicate-version|generator-duplicate-version|generator-version',
                'source-generator-bom|generator-bom|generator-encoding',
                'source-path-verifier-crlf|path-verifier-crlf|path-verifier-encoding',
                'source-build-generator-drift|build-generator-drift|build-generator-version',
                'source-build-path-verifier-drift|build-path-verifier-drift|build-path-verifier-version',
                'source-validator-identity-drift|validator-identity-drift|validator-identity',
                'source-validator-contract-digest-drift|validator-contract-digest-drift|contract-canonical-identity',
                'source-contract-canonical-drift|contract-canonical-drift|contract-canonical-identity',
                'source-wrong-mode|source-wrong-mode|source-identity',
                'source-wrong-blob|source-wrong-blob|source-identity'
            )
            bodyCases = @(
                'check-current|check|current|current',
                'check-absent|check|absent|identity-block-absent',
                'check-stale-head|check|stale-head|identity-block-stale',
                'check-stale-tree|check|stale-tree|identity-block-stale',
                'check-stale-one-digest|check|stale-digest|identity-block-stale',
                'check-partial-start|check|partial-start|identity-block-malformed',
                'check-partial-end|check|partial-end|identity-block-malformed',
                'check-duplicate|check|duplicate|identity-block-malformed',
                'check-reversed|check|reversed|identity-block-malformed',
                'check-inline-marker|check|inline-marker|identity-block-malformed',
                'check-null-character|check|null-character|body-invalid',
                'update-current-no-change|update|current|no-change',
                'update-absent-appends|update|absent|changed',
                'update-stale-replaces|update|stale-head|changed',
                'update-partial-refused|update|partial-start|identity-block-malformed',
                'update-preserves-unrelated-text|update|surrounded-stale|changed-preserved'
            )
            remoteCases = @(
                'remote-current-no-write|current|success-no-change|0',
                'remote-update-readback|update-success|success-changed|1',
                'remote-repository-name-case-insensitive|repository-name-case|success-changed|1',
                'remote-head-changes-before-write|head-before-write|remote-changed-before-write|0',
                'remote-body-changes-before-write|body-before-write|remote-changed-before-write|0',
                'remote-initial-read-fails|initial-read-failure|api-read|0',
                'remote-authentication-fails-before-write|authentication-failure|api-read|0',
                'remote-rate-limit-fails-before-write|rate-limit-failure|api-read|0',
                'remote-transport-fails-before-write|transport-read-failure|api-read|0',
                'remote-write-rejected|write-rejected|api-write-rejected|1',
                'remote-authorization-rejects-write|authorization-failure|api-write-rejected|1',
                'remote-write-ambiguous|write-indeterminate|indeterminate|1',
                'remote-patch-response-invalid|patch-response-invalid|indeterminate|1',
                'remote-readback-unavailable|readback-failure|indeterminate|1',
                'remote-readback-head-changed|readback-head-changed|indeterminate|1',
                'remote-readback-body-mismatch|readback-body-mismatch|indeterminate|1',
                'remote-unrelated-text-preserved|update-preserves-text|success-changed-preserved|1'
            )
        }
        $setCaseId = [Collections.Generic.HashSet[string]]::new(
            [StringComparer]::Ordinal
        )
        foreach ($strCollectionName in @(
                'sourceCases', 'bodyCases', 'remoteCases'
            )) {
            $objCases = $objCatalog[$strCollectionName]
            if ($objCases -isnot [Collections.IEnumerable] -or
                $objCases -is [string] -or
                $objCases -is [Collections.IDictionary]) {
                throw "$Path does not satisfy semantic invariant $Invariant."
            }
            $hashtableActualCase = @{}
            foreach ($objCase in @($objCases)) {
                & $script:scriptblockAssertExactDictionaryKeySet `
                    -Dictionary $objCase `
                    -Name "$Path $strCollectionName case" `
                    -Key $hashtableExpectedField[$strCollectionName]
                $strCaseId = [string] $objCase.id
                if ($strCaseId -cnotmatch '^[a-z0-9][a-z0-9-]{0,127}$' -or
                    -not $setCaseId.Add($strCaseId) -or
                    $objCase.expected -isnot [string]) {
                    throw "$Path does not satisfy semantic invariant $Invariant."
                }
                if ($strCollectionName -ceq 'sourceCases' -and
                    $objCase.mutation -isnot [string]) {
                    throw "$Path does not satisfy semantic invariant $Invariant."
                }
                if ($strCollectionName -ceq 'bodyCases' -and
                    ($objCase.operation -cnotin @('check', 'update') -or
                        $objCase.fixture -isnot [string])) {
                    throw "$Path does not satisfy semantic invariant $Invariant."
                }
                if ($strCollectionName -ceq 'remoteCases' -and
                    ($objCase.scenario -isnot [string] -or
                        $objCase.expectedPatchCount -isnot [long] -or
                        $objCase.expectedPatchCount -notin @(0, 1))) {
                    throw "$Path does not satisfy semantic invariant $Invariant."
                }
                $hashtableActualCase[$strCaseId] = $objCase
            }
            foreach ($strRequiredCase in
                $hashtableRequiredCase[$strCollectionName]) {
                $arrRequiredField = $strRequiredCase.Split('|')
                $strRequiredId = $arrRequiredField[0]
                if (-not $hashtableActualCase.ContainsKey($strRequiredId)) {
                    throw "$Path does not satisfy semantic invariant $Invariant."
                }
                $objActualCase = $hashtableActualCase[$strRequiredId]
                $boolMatches = if ($strCollectionName -ceq 'sourceCases') {
                    $objActualCase.mutation -ceq $arrRequiredField[1] -and
                    $objActualCase.expected -ceq $arrRequiredField[2]
                } elseif ($strCollectionName -ceq 'bodyCases') {
                    $objActualCase.operation -ceq $arrRequiredField[1] -and
                    $objActualCase.fixture -ceq $arrRequiredField[2] -and
                    $objActualCase.expected -ceq $arrRequiredField[3]
                } else {
                    $objActualCase.scenario -ceq $arrRequiredField[1] -and
                    $objActualCase.expected -ceq $arrRequiredField[2] -and
                    $objActualCase.expectedPatchCount -eq
                        [int] $arrRequiredField[3]
                }
                if (-not $boolMatches) {
                    throw "$Path does not satisfy semantic invariant $Invariant."
                }
            }
        }
        return
    }

    if ($Invariant -ceq
        'workflow-policy-preflight-authenticates-deferred-yaml-import') {
        $arrStaticImports = @([regex]::Matches(
                $Text,
                "(?m)^import .+ from '(?<Source>[^']+)';$"
            ))
        $arrRequiredLiteral = @(
            "import crypto from 'node:crypto';",
            "import fs from 'node:fs';",
            "import path from 'node:path';",
            "import process from 'node:process';",
            "import { fileURLToPath } from 'node:url';",
            "} = await import('yaml'));",
            "const VALIDATOR_FILE_NAME = 'Validate-WorkflowPolicy.mjs';",
            'function readContractWithoutDependencies() {',
            "path.join(SCRIPT_DIRECTORY, 'workflow-policy-contract.json'),",
            "const text = bytes.toString('utf8');",
            "contract = JSON.parse(text);",
            "expectExactKeys(contract.validatorIdentity, ['path', 'sha256'], 'contract-shape');",
            'contract.validatorIdentity.path !== VALIDATOR_FILE_NAME',
            'sha256(canonicalJson(contractIdentityView(contract))) !== EXPECTED_CONTRACT_CANONICAL_SHA256',
            'function verifyValidatorIdentity(contract) {',
            'sha256(validatorBytes) !== contract.validatorIdentity.sha256',
            'function verifyPackageDigests(contract) {',
            'sha256(packageJsonBytes) !== contract.supplyFreeze.reviewedWorkingBytes.packageJson.sha256',
            'sha256(packageLockBytes) !== contract.supplyFreeze.reviewedWorkingBytes.packageLockJson.sha256',
            'function preflight() {',
            'const contract = readContractWithoutDependencies();',
            'verifyValidatorIdentity(contract);',
            'verifyPackageDigests(contract);',
            'validatorVersion: VALIDATOR_VERSION,',
            'async function main() {',
            'const bootstrapContract = readContractWithoutDependencies();',
            'verifyValidatorIdentity(bootstrapContract);',
            'verifyPackageDigests(bootstrapContract);',
            'await loadYamlBindings();',
            'validateContract(contract);',
            'const isPreflight = canonicalJson(process.argv.slice(2)) === canonicalJson(PREFLIGHT_ARGUMENTS);',
            'process.stdout.write(`${JSON.stringify(isPreflight ? preflight() : await main())}\n`);'
        )
        foreach ($strRequiredLiteral in $arrRequiredLiteral) {
            if (-not $Text.Contains(
                    $strRequiredLiteral,
                    [StringComparison]::Ordinal
                )) {
                throw "$Path does not satisfy semantic invariant $Invariant."
            }
        }
        $arrValidatorTuple = @(
            [pscustomobject]@{
                Version = "const VALIDATOR_VERSION = '1.2.2';"
                Digest =
                    "const EXPECTED_CONTRACT_CANONICAL_SHA256 = '99bbdec8c80cced95287b50707a70071fe785e0dc5a715bf7439c8d04d5d52d6';"
            },
            [pscustomobject]@{
                Version = "const VALIDATOR_VERSION = '1.2.3';"
                Digest =
                    "const EXPECTED_CONTRACT_CANONICAL_SHA256 = 'c54d390c79bcd7a17d2acc214ee412d8b40c2eee310c28917df2260837dda9bb';"
            },
            [pscustomobject]@{
                Version = "const VALIDATOR_VERSION = '1.2.4';"
                Digest =
                    "const EXPECTED_CONTRACT_CANONICAL_SHA256 = 'd29855fa383bb5ef8255b18a4287e6da45e73814755eafa65dab060d80941824';"
            },
            [pscustomobject]@{
                Version = "const VALIDATOR_VERSION = '1.2.6';"
                Digest =
                    "const EXPECTED_CONTRACT_CANONICAL_SHA256 = '98ad8ff52efd053a1a0e48a54b7ce388ebba498446130051d34259564faf75d0';"
            },
            [pscustomobject]@{
                Version = "const VALIDATOR_VERSION = '1.2.7';"
                Digest =
                    "const EXPECTED_CONTRACT_CANONICAL_SHA256 = '0490a0fafe4e58a57990c8286771cec8d6605891d884ff30dc6a1c5193aeff2c';"
            },
            [pscustomobject]@{
                Version = "const VALIDATOR_VERSION = '1.2.8';"
                Digest =
                    "const EXPECTED_CONTRACT_CANONICAL_SHA256 = 'd6b5ad4774bbd4fed0608eec3e885d63f9c1b30951aa363a9a3e947a94cd0573';"
            }
        )
        $intVersionLiteralCount = 0
        $intDigestLiteralCount = 0
        $intMatchingTupleCount = 0
        foreach ($objValidatorTuple in $arrValidatorTuple) {
            $intVersionCount = [regex]::Matches(
                $Text,
                [regex]::Escape($objValidatorTuple.Version)
            ).Count
            $intDigestCount = [regex]::Matches(
                $Text,
                [regex]::Escape($objValidatorTuple.Digest)
            ).Count
            $intVersionLiteralCount += $intVersionCount
            $intDigestLiteralCount += $intDigestCount
            if ($intVersionCount -eq 1 -and $intDigestCount -eq 1) {
                $intMatchingTupleCount++
            }
        }
        if ($intVersionLiteralCount -ne 1 -or
            $intDigestLiteralCount -ne 1 -or
            $intMatchingTupleCount -ne 1) {
            throw "$Path does not satisfy semantic invariant $Invariant."
        }
        $boolBuiltInOnly = $arrStaticImports.Count -eq 5
        foreach ($objImport in $arrStaticImports) {
            if (-not $objImport.Groups['Source'].Value.StartsWith(
                    'node:',
                    [StringComparison]::Ordinal
                )) {
                $boolBuiltInOnly = $false
            }
        }
        $intMainStart = $Text.IndexOf(
            'async function main() {',
            [StringComparison]::Ordinal
        )
        $intMainContract = $Text.IndexOf(
            'const bootstrapContract = readContractWithoutDependencies();',
            $intMainStart,
            [StringComparison]::Ordinal
        )
        $intMainValidator = $Text.IndexOf(
            'verifyValidatorIdentity(bootstrapContract);',
            $intMainContract,
            [StringComparison]::Ordinal
        )
        $intMainPackages = $Text.IndexOf(
            'verifyPackageDigests(bootstrapContract);',
            $intMainValidator,
            [StringComparison]::Ordinal
        )
        $intMainImport = $Text.IndexOf(
            'await loadYamlBindings();',
            $intMainPackages,
            [StringComparison]::Ordinal
        )
        if (-not $boolBuiltInOnly -or
            [regex]::Matches($Text, "(?<!await )import\('").Count -ne 0 -or
            [regex]::Matches(
                $Text,
                [regex]::Escape("await import('yaml')")
            ).Count -ne 1 -or
            $intMainStart -lt 0 -or $intMainContract -le $intMainStart -or
            $intMainValidator -le $intMainContract -or
            $intMainPackages -le $intMainValidator -or
            $intMainImport -le $intMainPackages) {
            throw "$Path does not satisfy semantic invariant $Invariant."
        }
        return
    }

    if ($Invariant -ceq 'actionlint-queue-schema-exceptions-are-exact') {
        $strExpectedText = [string]::Join("`n", @(
                '# GitHub supports concurrency.queue, but actionlint does not yet model that key.',
                '# These path-scoped exceptions are also covered by schema and mutation checks.',
                'paths:',
                '  .github/workflows/agent-instruction-current-base.yml:',
                '    ignore:',
                '      - ''^unexpected key "queue" for "concurrency" section\. expected one of "cancel-in-progress", "group"$''',
                '  .github/workflows/agent-instructions.yml:',
                '    ignore:',
                '      - ''^unexpected key "queue" for "concurrency" section\. expected one of "cancel-in-progress", "group"$''',
                ''
            ))
        if ($Text -cne $strExpectedText) {
            throw "$Path does not satisfy semantic invariant $Invariant."
        }
        return
    }

    if ($Invariant -ceq 'pre-commit-actionlint-gate-is-exact') {
        $arrRequiredLiteral = @(
            '\.github/(actionlint\.yaml|dependabot\.yml)|',
            '\.github/actionlint\.yaml|',
            'https://github.com/rhysd/actionlint',
            'rev: "011a6d15e749bb3f2d771eed9c7aa0e7e3e10ee7"',
            '- id: actionlint',
            'files: ^\.github/workflows/.*\.ya?ml$'
        )
        foreach ($strRequiredLiteral in $arrRequiredLiteral) {
            if (-not $Text.Contains(
                    $strRequiredLiteral,
                    [StringComparison]::Ordinal
                )) {
                throw "$Path does not satisfy semantic invariant $Invariant."
            }
        }
        if ([regex]::Matches(
                $Text,
                [regex]::Escape('\.github/actionlint\.yaml')
            ).Count -ne 2 -or
            [regex]::Matches(
                $Text,
                [regex]::Escape(
                    '\.github/(actionlint\.yaml|dependabot\.yml)'
                )
            ).Count -ne 2 -or
            [regex]::Matches(
                $Text,
                [regex]::Escape('https://github.com/rhysd/actionlint')
            ).Count -ne 1 -or
            $Text.Contains('-shellcheck=', [StringComparison]::Ordinal)) {
            throw "$Path does not satisfy semantic invariant $Invariant."
        }
        return
    }

    if ($Invariant -ceq
        'workflow-policy-contract-identities-and-structure-are-exact') {
        try {
            $objContract = & $script:scriptblockConvertFromStrictJsonHashtable `
                -Text $Text -Name $Path
            & $script:scriptblockAssertExactDictionaryKeySet `
                -Dictionary $objContract -Name 'contract' `
                -Key @(
                    'schema', 'contractVersion', 'limits', 'supplyFreeze',
                    'scriptVersions', 'caseCatalog', 'validatorIdentity',
                    'actions', 'workflowPolicy', 'markdownPolicy', 'dependabot',
                    'reciprocalFoundation'
                )
            if ($objContract.schema -cne
                    'PSStyleGuide.WorkflowPolicyContract.v1' -or
                $objContract.contractVersion -ne 1) {
                throw 'The workflow contract version is invalid.'
            }
            foreach ($strDictionaryName in @(
                    'limits', 'supplyFreeze', 'scriptVersions', 'caseCatalog',
                    'validatorIdentity', 'actions', 'workflowPolicy',
                    'markdownPolicy', 'dependabot', 'reciprocalFoundation'
                )) {
                if ($objContract[$strDictionaryName] -isnot
                    [Collections.IDictionary]) {
                    throw "The workflow contract $strDictionaryName is invalid."
                }
            }
            & $script:scriptblockAssertExactDictionaryKeySet `
                -Dictionary $objContract.limits `
                -Name 'contract limits' -Key @(
                    'maximumWorkflowBytes', 'maximumJsonBytes', 'maximumNodes',
                    'maximumDepth'
                )
            if ($objContract.limits.maximumWorkflowBytes -ne 131072 -or
                $objContract.limits.maximumJsonBytes -ne 524288 -or
                $objContract.limits.maximumNodes -ne 5000 -or
                $objContract.limits.maximumDepth -ne 32) {
                throw 'The workflow contract limits are invalid.'
            }
            & $script:scriptblockAssertExactDictionaryKeySet `
                -Dictionary $objContract.validatorIdentity `
                -Name 'validator identity' -Key @('path', 'sha256')
            if ($objContract.validatorIdentity.path -cne
                    'Validate-WorkflowPolicy.mjs' -or
                ([string] $objContract.validatorIdentity.sha256) -cnotin @(
                    '33554c001f6613be74db3644aa097e18322c2cf9ab7e064e721006ba456a58a9',
                    'ca9b76f363f2f94209cc1e33fe1ea5a61ce6ad2b1fedcafabd5e06e2e65e3202',
                    '386ed401ec8a3488e8d03a068a38b9fcd965c9f2a158c565a7cb7e20a03c0dbb',
                    '481b301a3557680ceef40dcfa15ab3f73bda0ff5d132afc15cd900221180cdc6',
                    '45452a233005379579f8eedf626cadf8b9af7a05767463c4f225ac82524f9791',
                    'df9e8a124fcd62996b0d2e70571042deeaf9e248c0b9150850378271c974606c'
                )) {
                throw 'The workflow validator identity is invalid.'
            }
            & $script:scriptblockAssertExactDictionaryKeySet `
                -Dictionary $objContract.markdownPolicy `
                -Name 'Markdown policy' -Key @(
                    'schema', 'extensions', 'entryPoints'
                )
            if ($objContract.markdownPolicy.schema -cne
                    'PSStyleGuide.MarkdownEntryPointPolicy.v1' -or
                $objContract.markdownPolicy.entryPoints -isnot
                    [Collections.IDictionary]) {
                throw 'The Markdown entry-point policy is invalid.'
            }
            & $script:scriptblockAssertExactDictionaryKeySet `
                -Dictionary $objContract.markdownPolicy.entryPoints `
                -Name 'Markdown entry points' -Key @(
                    'rootPackageJson', 'workflowPackageJson', 'nestedLinter',
                    'stagedSelector', 'preCommit'
                )
            $objRootPackage =
                $objContract.markdownPolicy.entryPoints.rootPackageJson
            if ($objRootPackage -isnot [Collections.IDictionary]) {
                throw 'The root package identity is invalid.'
            }
            & $script:scriptblockAssertExactDictionaryKeySet `
                -Dictionary $objRootPackage `
                -Name 'root package identity' `
                -Key @('path', 'length', 'sha256', 'lintScript')
            $strRootLint =
                'markdownlint-cli2 "**/*.md" "**/*.mdc" "#node_modules" ' +
                '"#.github/workflows/node_modules" --config ' +
                '.github/workflows/.markdownlint.jsonc'
            if ($objRootPackage.path -cne '../../package.json' -or
                $objRootPackage.length -ne 1188 -or
                $objRootPackage.sha256 -cne
                    '1b77a3a08d12639c3534272409afd263b0fbcf7d802abad689dd137e1278eea4' -or
                $objRootPackage.lintScript -cne $strRootLint) {
                throw 'The root package identity is invalid.'
            }
        } catch {
            throw (
                "$Path does not satisfy semantic invariant ${Invariant}: " +
                    $_.Exception.Message
            )
        }
        return
    }

    if ($Invariant -ceq 'package-parser-roots-are-exact') {
        try {
            $objPackage = & $script:scriptblockConvertFromStrictJsonHashtable `
                -Text $Text -Name $Path
            & $script:scriptblockAssertExactDictionaryKeySet `
                -Dictionary $objPackage -Name 'package' `
                -Key @(
                    'name', 'version', 'private', 'description', 'license',
                    'engines', 'packageManager', 'scripts', 'repository',
                    'devDependencies'
                )
            if ($objPackage.name -cne 'psstyleguide' -or
                $objPackage.version -cne '1.0.0' -or
                $objPackage.private -ne $true -or
                $objPackage.license -cne 'MIT' -or
                $objPackage.packageManager -cne 'npm@11.16.0') {
                throw 'The root package identity is invalid.'
            }
            & $script:scriptblockAssertExactDictionaryKeySet `
                -Dictionary $objPackage.engines `
                -Name 'package engines' -Key @('node', 'npm')
            if ($objPackage.engines.node -cne '24.18.0' -or
                $objPackage.engines.npm -cne '11.16.0') {
                throw 'The package runtime identity is invalid.'
            }
            & $script:scriptblockAssertExactDictionaryKeySet `
                -Dictionary $objPackage.scripts `
                -Name 'package scripts' -Key @(
                    'bootstrap:agent-instructions', 'lint:md',
                    'lint:md:nested', 'test:agent-instructions'
                )
            $hashtableExpectedScript = @{
                'bootstrap:agent-instructions' =
                    'npm ci --ignore-scripts --no-audit --fund=false ' +
                    '--include=dev --package-lock=true && npm --prefix ' +
                    '.github/workflows ci --ignore-scripts --no-audit ' +
                    '--fund=false --include=dev --package-lock=true'
                'lint:md' =
                    'markdownlint-cli2 "**/*.md" "**/*.mdc" ' +
                    '"#node_modules" "#.github/workflows/node_modules" ' +
                    '--config .github/workflows/.markdownlint.jsonc'
                'lint:md:nested' =
                    'npm --prefix .github/workflows run lint:md:nested'
                'test:agent-instructions' =
                    'pwsh -NoLogo -NoProfile -NonInteractive -File ' +
                    '.github/workflows/Test-AgentInstructions.ps1 -SelfTest'
            }
            foreach ($strScriptName in $hashtableExpectedScript.Keys) {
                if ($objPackage.scripts[$strScriptName] -cne
                    $hashtableExpectedScript[$strScriptName]) {
                    throw "The package script $strScriptName is invalid."
                }
            }
            & $script:scriptblockAssertExactDictionaryKeySet `
                -Dictionary $objPackage.devDependencies `
                -Name 'package development dependencies' -Key @(
                    'glob', 'js-yaml', 'jsonc-parser', 'markdown-it',
                    'markdownlint', 'markdownlint-cli2'
                )
            $hashtableExpectedDependency = @{
                'glob' = '10.5.0'
                'js-yaml' = '5.2.2'
                'jsonc-parser' = '3.3.1'
                'markdown-it' = '14.2.0'
                'markdownlint' = '0.41.0'
                'markdownlint-cli2' = '0.23.2'
            }
            foreach ($strDependencyName in
                $hashtableExpectedDependency.Keys) {
                if ($objPackage.devDependencies[$strDependencyName] -cne
                    $hashtableExpectedDependency[$strDependencyName]) {
                    throw "The package dependency $strDependencyName is invalid."
                }
            }
        } catch {
            throw "$Path does not satisfy semantic invariant $Invariant."
        }
        return
    }

    if ($Invariant -ceq 'package-lock-parser-closure-is-exact') {
        try {
            $objLock = & $script:scriptblockConvertFromStrictJsonHashtable `
                -Text $Text -Name $Path
            & $script:scriptblockAssertExactDictionaryKeySet `
                -Dictionary $objLock -Name 'lockfile' `
                -Key @(
                    'name', 'version', 'lockfileVersion', 'requires', 'packages'
                )
            if ($objLock.name -cne 'psstyleguide' -or
                $objLock.version -cne '1.0.0' -or
                $objLock.lockfileVersion -ne 3 -or
                $objLock.requires -ne $true -or
                $objLock.packages -isnot [Collections.IDictionary] -or
                -not $objLock.packages.Contains('')) {
                throw 'The lockfile identity is invalid.'
            }
            $objRoot = $objLock.packages['']
            if ($objRoot -isnot [Collections.IDictionary]) {
                throw 'The lockfile root is invalid.'
            }
            & $script:scriptblockAssertExactDictionaryKeySet `
                -Dictionary $objRoot `
                -Name 'lockfile root' -Key @(
                    'name', 'version', 'license', 'devDependencies', 'engines'
                )
            if ($objRoot.name -cne 'psstyleguide' -or
                $objRoot.version -cne '1.0.0' -or
                $objRoot.license -cne 'MIT' -or
                $objRoot.devDependencies -isnot [Collections.IDictionary] -or
                $objRoot.engines -isnot [Collections.IDictionary]) {
                throw 'The lockfile root identity is invalid.'
            }
            & $script:scriptblockAssertExactDictionaryKeySet `
                -Dictionary $objRoot.devDependencies `
                -Name 'lockfile root development dependencies' -Key @(
                    'glob', 'js-yaml', 'jsonc-parser', 'markdown-it',
                    'markdownlint', 'markdownlint-cli2'
                )
            $hashtableExpectedRootDependency = @{
                'glob' = '10.5.0'
                'js-yaml' = '5.2.2'
                'jsonc-parser' = '3.3.1'
                'markdown-it' = '14.2.0'
                'markdownlint' = '0.41.0'
                'markdownlint-cli2' = '0.23.2'
            }
            foreach ($strDependencyName in
                $hashtableExpectedRootDependency.Keys) {
                if ($objRoot.devDependencies[$strDependencyName] -cne
                    $hashtableExpectedRootDependency[$strDependencyName]) {
                    throw 'The lockfile root dependency identity is invalid.'
                }
            }
            & $script:scriptblockAssertExactDictionaryKeySet `
                -Dictionary $objRoot.engines `
                -Name 'lockfile root engines' -Key @('node', 'npm')
            if ($objRoot.engines.node -cne '24.18.0' -or
                $objRoot.engines.npm -cne '11.16.0') {
                throw 'The lockfile root runtime identity is invalid.'
            }

            $arrParserRootPath = @(
                'node_modules/js-yaml',
                'node_modules/markdown-it'
            )
            $queuePath = [Collections.Generic.Queue[string]]::new()
            foreach ($strParserRootPath in $arrParserRootPath) {
                $queuePath.Enqueue($strParserRootPath)
            }
            $setClosurePath = [Collections.Generic.HashSet[string]]::new(
                [StringComparer]::Ordinal
            )
            while ($queuePath.Count -gt 0) {
                $strPackagePath = $queuePath.Dequeue()
                if (-not $setClosurePath.Add($strPackagePath)) {
                    continue
                }
                if (-not $objLock.packages.Contains($strPackagePath) -or
                    $objLock.packages[$strPackagePath] -isnot
                        [Collections.IDictionary]) {
                    throw "The parser closure lacks $strPackagePath."
                }
                $objDescriptor = $objLock.packages[$strPackagePath]
                $setDependencyName =
                    [Collections.Generic.HashSet[string]]::new(
                        [StringComparer]::Ordinal
                    )
                foreach ($strDependencyField in @(
                        'dependencies', 'optionalDependencies'
                    )) {
                    if ($objDescriptor.Contains($strDependencyField)) {
                        $objDependencies = $objDescriptor[$strDependencyField]
                        if ($objDependencies -isnot [Collections.IDictionary]) {
                            throw 'A parser dependency field is invalid.'
                        }
                        foreach ($strDependencyName in $objDependencies.Keys) {
                            if ($objDependencies[$strDependencyName] -isnot
                                    [string] -or
                                [string]::IsNullOrEmpty(
                                    $objDependencies[$strDependencyName]
                                )) {
                                throw 'A parser dependency edge is invalid.'
                            }
                            [void] $setDependencyName.Add($strDependencyName)
                        }
                    }
                }
                if ($objDescriptor.Contains('peerDependencies')) {
                    $objPeerDependencies = $objDescriptor.peerDependencies
                    if ($objPeerDependencies -isnot [Collections.IDictionary]) {
                        throw 'A parser peer dependency field is invalid.'
                    }
                    $objPeerMetadata = if (
                        $objDescriptor.Contains('peerDependenciesMeta')
                    ) {
                        $objDescriptor.peerDependenciesMeta
                    } else {
                        @{}
                    }
                    if ($objPeerMetadata -isnot [Collections.IDictionary]) {
                        throw 'Parser peer dependency metadata is invalid.'
                    }
                    foreach ($strDependencyName in $objPeerDependencies.Keys) {
                        $boolOptional =
                            $objPeerMetadata.Contains($strDependencyName) -and
                            $objPeerMetadata[$strDependencyName] -is
                                [Collections.IDictionary] -and
                            $objPeerMetadata[$strDependencyName].optional -eq
                                $true
                        if (-not $boolOptional) {
                            [void] $setDependencyName.Add($strDependencyName)
                        }
                    }
                }
                $arrDependencyName = [string[]] @($setDependencyName)
                [Array]::Sort($arrDependencyName, [StringComparer]::Ordinal)
                foreach ($strDependencyName in $arrDependencyName) {
                    $strScope = $strPackagePath
                    $strResolvedPath = $null
                    while ($true) {
                        $strCandidatePath = if (
                            [string]::IsNullOrEmpty($strScope)
                        ) {
                            "node_modules/$strDependencyName"
                        } else {
                            "$strScope/node_modules/$strDependencyName"
                        }
                        if ($objLock.packages.Contains($strCandidatePath)) {
                            $strResolvedPath = $strCandidatePath
                            break
                        }
                        if ([string]::IsNullOrEmpty($strScope)) {
                            break
                        }
                        $intParentIndex = $strScope.LastIndexOf(
                            '/node_modules/',
                            [StringComparison]::Ordinal
                        )
                        $strScope = if ($intParentIndex -lt 0) {
                            ''
                        } else {
                            $strScope.Substring(0, $intParentIndex)
                        }
                    }
                    if ($null -eq $strResolvedPath) {
                        throw 'A parser dependency edge cannot resolve.'
                    }
                    $queuePath.Enqueue($strResolvedPath)
                }
            }

            $hashtableExpectedDescriptor = @{
                'node_modules/argparse' = @{
                    Version = '2.0.1'
                    Resolved =
                        'https://registry.npmjs.org/argparse/-/argparse-2.0.1.tgz'
                    Integrity =
                        'sha512-8+9WqebbFzpX9OR+Wa6O29asIogeRMzcGtAINdpMHHyAg10f05aSFVBbcEqGf/PXw1EjAZ+q2/bEBg3DvurK3Q=='
                    Dependencies = @{}
                    CanonicalSha256 =
                        '1aba76231b810723f6fbc4dfcdc5c7356fd9d53f665a7f07192d357beb9c04cd'
                }
                'node_modules/entities' = @{
                    Version = '4.5.0'
                    Resolved =
                        'https://registry.npmjs.org/entities/-/entities-4.5.0.tgz'
                    Integrity =
                        'sha512-V0hjH4dGPh9Ao5p0MoRY6BVqtwCjhz6vI5LT8AJ55H+4g9/4vbHx1I54fS0XuclLhDHArPQCiMjDxjaL8fPxhw=='
                    Dependencies = @{}
                    CanonicalSha256 =
                        'b63f780bdba314f86d01ec39124ffe7bc4f55ad75e59c937cb552d45f93ed74d'
                }
                'node_modules/js-yaml' = @{
                    Version = '5.2.2'
                    Resolved =
                        'https://registry.npmjs.org/js-yaml/-/js-yaml-5.2.2.tgz'
                    Integrity =
                        'sha512-dayzUzKkJ1MkuUtZglSebU43utNXH0OWQByK9rKOOuYIO8M5TV1y+n8ALMdG0rdzBnfNkOmZEqrURepb0ejqBw=='
                    Dependencies = @{
                        'argparse' = '^2.0.1'
                    }
                    CanonicalSha256 =
                        'e11a9c3513389f92aec2c8f6e30d7e04ef86a142038a2835b941d32e1acb69d6'
                }
                'node_modules/linkify-it' = @{
                    Version = '5.0.2'
                    Resolved =
                        'https://registry.npmjs.org/linkify-it/-/linkify-it-5.0.2.tgz'
                    Integrity =
                        'sha512-ONTm2jCMAVZjgQa/Fy1kScXsuOoF5NPTsoFBdE1KVIZ2vAh/r9+Bqo+0jINCBYnavTPQZz38QzFTme79ENoN3Q=='
                    Dependencies = @{
                        'uc.micro' = '^2.0.0'
                    }
                    CanonicalSha256 =
                        'd36f93a608fcd49b1b8b3852be1c4e4012f6eabe679df9e8d24e6487ad623d2e'
                }
                'node_modules/markdown-it' = @{
                    Version = '14.2.0'
                    Resolved =
                        'https://registry.npmjs.org/markdown-it/-/markdown-it-14.2.0.tgz'
                    Integrity =
                        'sha512-1TGiQiJVRQ3NPmZH6sx5Cfnmg6GQm9jvC1ch4TK511NjSJvjzKLzn5pPfZRNZkRPZP0HqCioSndqH8v2nRaWVQ=='
                    Dependencies = @{
                        'argparse' = '^2.0.1'
                        'entities' = '^4.4.0'
                        'linkify-it' = '^5.0.1'
                        'mdurl' = '^2.0.0'
                        'punycode.js' = '^2.3.1'
                        'uc.micro' = '^2.1.0'
                    }
                    CanonicalSha256 =
                        'ed483c71df83e03d1663ca22bc1d7a9bc4f076a7733c6e1bb0a7baa5e03929b0'
                }
                'node_modules/mdurl' = @{
                    Version = '2.0.0'
                    Resolved =
                        'https://registry.npmjs.org/mdurl/-/mdurl-2.0.0.tgz'
                    Integrity =
                        'sha512-Lf+9+2r+Tdp5wXDXC4PcIBjTDtq4UKjCPMQhKIuzpJNW0b96kVqSwW0bT7FhRSfmAiFYgP+SCRvdrDozfh0U5w=='
                    Dependencies = @{}
                    CanonicalSha256 =
                        'a9e897eaa7c653dd7e5f6586803fceaac685c9768b9577c94649665975dc26bb'
                }
                'node_modules/punycode.js' = @{
                    Version = '2.3.1'
                    Resolved =
                        'https://registry.npmjs.org/punycode.js/-/punycode.js-2.3.1.tgz'
                    Integrity =
                        'sha512-uxFIHU0YlHYhDQtV4R9J6a52SLx28BCjT+4ieh7IGbgwVJWO+km431c4yRlREUAsAmt/uMjQUyQHNEPf0M39CA=='
                    Dependencies = @{}
                    CanonicalSha256 =
                        '86c6ac2b7abd1950959542228952af635ff2e32d487302f6f2b6d7f6e5faca6c'
                }
                'node_modules/uc.micro' = @{
                    Version = '2.1.0'
                    Resolved =
                        'https://registry.npmjs.org/uc.micro/-/uc.micro-2.1.0.tgz'
                    Integrity =
                        'sha512-ARDJmphmdvUk6Glw7y9DQ2bFkKBHwQHLi2lsaH6PPmz/Ka9sFOBsBluozhDltWmnv9u/cF6Rt87znRTPV+yp/A=='
                    Dependencies = @{}
                    CanonicalSha256 =
                        '7327a8851245320355f66321a0caf097089786fa1a52af07eb519ac6d07119d0'
                }
            }
            $arrClosurePath = [string[]] @($setClosurePath)
            $arrExpectedClosurePath =
                [string[]] @($hashtableExpectedDescriptor.Keys)
            [Array]::Sort($arrClosurePath, [StringComparer]::Ordinal)
            [Array]::Sort($arrExpectedClosurePath, [StringComparer]::Ordinal)
            if ([string]::Join("`n", $arrClosurePath) -cne
                [string]::Join("`n", $arrExpectedClosurePath)) {
                throw 'The executable parser closure is invalid.'
            }
            foreach ($strPackagePath in $arrExpectedClosurePath) {
                $objDescriptor = $objLock.packages[$strPackagePath]
                $objExpected = $hashtableExpectedDescriptor[$strPackagePath]
                $objActualDependencies = if (
                    $objDescriptor.Contains('dependencies')
                ) {
                    $objDescriptor.dependencies
                } else {
                    @{}
                }
                if ($objActualDependencies -isnot [Collections.IDictionary]) {
                    throw 'A parser dependency descriptor is invalid.'
                }
                & $script:scriptblockAssertExactDictionaryKeySet `
                    -Dictionary $objActualDependencies `
                    -Key ([string[]] @($objExpected.Dependencies.Keys)) `
                    -Name "$strPackagePath dependencies"
                foreach ($strDependencyName in
                    $objExpected.Dependencies.Keys) {
                    if ($objActualDependencies[$strDependencyName] -cne
                        $objExpected.Dependencies[$strDependencyName]) {
                        throw 'A parser dependency edge is invalid.'
                    }
                }
                $strCanonicalDescriptor =
                    & $script:scriptblockConvertToCanonicalJsonText `
                    -Value $objDescriptor
                $strDescriptorSha256 = [Convert]::ToHexString(
                    [Security.Cryptography.SHA256]::HashData(
                        [Text.Encoding]::UTF8.GetBytes($strCanonicalDescriptor)
                    )
                ).ToLowerInvariant()
                if ($objDescriptor.version -cne $objExpected.Version -or
                    $objDescriptor.resolved -cne $objExpected.Resolved -or
                    $objDescriptor.integrity -cne $objExpected.Integrity -or
                    $strDescriptorSha256 -cne $objExpected.CanonicalSha256) {
                    throw 'A parser dependency descriptor is invalid.'
                }
            }
        } catch {
            throw (
                "$Path does not satisfy semantic invariant ${Invariant}: " +
                    $_.Exception.Message
            )
        }
        return
    }

    if ($Invariant -ceq 'exact-maintenance-production-call-is-gated') {
        $arrTokens = $null
        $arrParseErrors = $null
        $objAst = [Management.Automation.Language.Parser]::ParseInput(
            $Text,
            [ref] $arrTokens,
            [ref] $arrParseErrors
        )
        $arrCalls = @($objAst.FindAll({
                    param($objNode)
                    $objNode -is [Management.Automation.Language.CommandAst] -and
                    $objNode.GetCommandName() -ceq
                        'Get-TrustRootRangeMutationFailure'
                }, $true))
        $intProductionSwitchCalls = 0
        $intSelfTestSwitchCalls = 0
        foreach ($objCall in $arrCalls) {
            $boolHasPrivateSwitch = @($objCall.CommandElements |
                    Where-Object {
                        $_ -is [Management.Automation.Language.CommandParameterAst] -and
                        $_.ParameterName -ceq
                            'ExactAuthorizedMaintenanceProductionCall'
                    }).Count -eq 1
            if (-not $boolHasPrivateSwitch) {
                continue
            }
            $boolHasSelfTestAncestor = $false
            $objParent = $objCall.Parent
            while ($null -ne $objParent) {
                if ($objParent -is
                    [Management.Automation.Language.IfStatementAst] -and
                    $objParent.Extent.Text -cmatch '^if \(\$SelfTest\)') {
                    $boolHasSelfTestAncestor = $true
                    break
                }
                $objParent = $objParent.Parent
            }
            if ($boolHasSelfTestAncestor) {
                $intSelfTestSwitchCalls++
            } else {
                $intProductionSwitchCalls++
            }
        }
        $strAuthorizedFixturePattern =
            '(?s)\$script:boolTrustedMaintenanceAuthorizationValidated = ' +
            '\$true\s+\$arrAuthorizedFixtureFailures = @\(\s+' +
            'Get-TrustRootRangeMutationFailure\s+`.*?' +
            '-RepositoryRelativePath \$strAuthorizationFixtureTrustPath\s+\)'
        $strHermeticFixturePattern =
            '(?s)\$strAuthorizationFixtureRoot = \[IO\.Path\]::Combine\(' +
            '.*?agent-instruction-trust-root-.*?' +
            '\$strAuthorizationFixtureRepository =.*?' +
            "commit --quiet --no-gpg-sign -m 'trust-root baseline'.*?" +
            "commit --quiet --no-gpg-sign -m 'trust-root mutation'.*?" +
            'git clone --quiet --depth 1 --no-local --no-hardlinks.*?' +
            '--is-shallow-repository.*?rev-list\s+`\s+' +
            '--max-parents=0 HEAD.*?' +
            'The depth-one clone did not reproduce the apparent-root condition\.'
        $strNoMutationFixturePattern =
            '(?s)\$arrNoMutationFixtureFailures = @\(\s+' +
            'Get-TrustRootRangeMutationFailure\s+`.*?' +
            '-BaseRevision \$strAuthorizationFixtureHead\.Trim\(\)\s+`.*?' +
            '-HeadRevision \$strAuthorizationFixtureHead\.Trim\(\).*?' +
            '\$arrNoMutationFixtureFailures\.Count -ne 0'
        $strFixtureCleanupPattern =
            '(?s)finally \{\s+' +
            '\$script:boolTrustedMaintenanceAuthorizationValidated =.*?' +
            'Remove-Item -LiteralPath \$strAuthorizationFixtureRoot ' +
            '-Recurse -Force\s+\}\s+\}'
        if ($arrParseErrors.Count -ne 0 -or
            $Text -cnotmatch
                '(?s)if \(\$ExactAuthorizedMaintenanceProductionCall -and\s+' +
                '-not \$script:boolTrustedMaintenanceAuthorizationValidated\) ' +
                "\{\s+throw 'The production maintenance call requires exact " +
                "trusted authorization\.'" -or
            $Text -cnotmatch
                '(?s)if \(\$ExactAuthorizedMaintenanceProductionCall -and\s+' +
                '\$script:boolTrustedMaintenanceAuthorizationValidated\) ' +
                '\{\s+return' -or
            $intProductionSwitchCalls -ne 1 -or
            $intSelfTestSwitchCalls -ne 2 -or
            $Text -cnotmatch $strHermeticFixturePattern -or
            $Text -cnotmatch $strAuthorizedFixturePattern -or
            ([regex]::Match(
                    $Text,
                    $strAuthorizedFixturePattern
                ).Value.Contains(
                    '-ExactAuthorizedMaintenanceProductionCall',
                    [StringComparison]::Ordinal
                )) -or
            $Text -cnotmatch
                'The hermetic trust-root mutation fixture was not diagnosed\.' -or
            $Text -cnotmatch $strNoMutationFixturePattern -or
            $Text -cnotmatch $strFixtureCleanupPattern -or
            $Text -cmatch
                '(?s)\$strAuthorizationFixtureBase = \[string\] \(\s+' +
                '& git -C \$strRepositoryRootPath rev-list --max-parents=0 HEAD' -or
            $Text -cnotmatch
                'An unauthorized production maintenance call did not fail closed\.') {
            throw "$Path does not satisfy semantic invariant $Invariant."
        }
        return
    }

    if ($Invariant -ceq 'published-path-array-binding-is-explicit') {
        $arrTokens = $null
        $arrParseErrors = $null
        [void] [Management.Automation.Language.Parser]::ParseInput(
            $Text,
            [ref] $arrTokens,
            [ref] $arrParseErrors
        )
        $strExplicitCallPattern =
            '(?s)\[string\[\]\] ' +
            '\$arrPublishedNewRefBoundaryRevisions = @\(\).*?' +
            '\[string\[\]\] ' +
            '\$arrPublishedNewRefIntroducedCommitRevisions = @\(\).*?' +
            '-NewRefBoundaryRevision ' +
            '\$arrPublishedNewRefBoundaryRevisions\s+`.*?' +
            '-NewRefIntroducedCommitRevision\s+`\s+' +
            '\$arrPublishedNewRefIntroducedCommitRevisions\s+`'
        $strHelperValidationPattern =
            '(?s)\$arrBoundaries = @\(\$NewRefBoundaryRevision\)\s+' +
            '\$arrIntroducedCommits = ' +
            '@\(\$NewRefIntroducedCommitRevision\).*?' +
            'foreach \(\$strRevision in ' +
            '@\(\$arrBoundaries \+ \$arrIntroducedCommits\)\).*?' +
            '\[string\]::IsNullOrEmpty\(\$strRevision\).*?' +
            "throw 'The created-ref path range contains an invalid revision\.'"
        $strZeroIntroductionRejectionPattern =
            '(?s)\$arrArguments = if \(\$BaselineAbsent -and ' +
            '\$arrIntroducedCommits\.Count -eq 0\) \{\s+' +
            "throw 'A zero-introduction created ref has no content-validation path range\.'"
        $strZeroIntroductionApplicabilityPattern =
            '(?s)if \(@\(\$objCreatedRefContext\.IntroducedCommitRevisions\)' +
            '\.Count -eq 0\) \{.*?' +
            '"result":"NOT_APPLICABLE","reason":"created-ref-no-introduced-commits",' +
            '.*?"requiredGate":"agent-instruction-current-base".*?return\s+\}'
        $strZeroIntroductionAssertionPattern =
            '(?s)try \{\s+\[void\] @\(Read-GitPublishedEndpointChangedPath.*?' +
            '-NewRefIntroducedCommitRevision \$arrPublishedPathEmptyRevisions.*?' +
            "throw 'A created ref with no introduced commits returned a path comparison\.'" +
            '.*?catch \{\s+if \(-not \$_\.Exception\.Message\.Contains\(\s+' +
            "'A zero-introduction created ref has no content-validation path range\.'," +
            '\s+\[StringComparison\]::Ordinal'
        $boolSupportedZeroIntroductionAssertion =
            $Text -cmatch
                'A created ref with no introduced commits reported changed paths\.' -or
            ($Text -cmatch $strZeroIntroductionRejectionPattern -and
                $Text -cmatch $strZeroIntroductionApplicabilityPattern -and
                $Text -cmatch $strZeroIntroductionAssertionPattern)
        if ($arrParseErrors.Count -ne 0 -or
            $Text -cnotmatch $strExplicitCallPattern -or
            $Text -cnotmatch $strHelperValidationPattern -or
            $Text -cmatch
                '(?s)-NewRefBoundaryRevision\s+\$\(' -or
            $Text -cmatch
                '(?s)-NewRefIntroducedCommitRevision\s+\$\(' -or
            -not $boolSupportedZeroIntroductionAssertion -or
            $Text -cnotmatch
                'A zero-boundary created ref returned an incorrect ' +
                'final-tree path set\.' -or
            $Text -cnotmatch
                'A nonzero-boundary created ref returned an incorrect ' +
                'changed-path set\.' -or
            $Text -cnotmatch
                "Name = 'null boundary'" -or
            $Text -cnotmatch
                "Name = 'empty boundary'" -or
            $Text -cnotmatch
                "Name = 'invalid introduced revision'") {
            throw "$Path does not satisfy semantic invariant $Invariant."
        }
        return
    }

    if ($Invariant -ceq 'legacy-transition-marker-is-inert-data') {
        $arrTokens = $null
        $arrParseErrors = $null
        $objAst = [Management.Automation.Language.Parser]::ParseInput(
            $Text,
            [ref] $arrTokens,
            [ref] $arrParseErrors
        )
        $arrScopedName = @(
            'script:strLegacyMetadataRangeCompatibilityMarker',
            'script:strLegacyStyleGuideRationaleCompatibilityMarker',
            'script:strLegacyOperationalLintGuideCompatibilityMarker'
        )
        $arrUnqualifiedName = @(
            'strLegacyMetadataRangeCompatibilityMarker',
            'strLegacyStyleGuideRationaleCompatibilityMarker',
            'strLegacyOperationalLintGuideCompatibilityMarker'
        )
        $arrAssignments = @($objAst.FindAll({
                    param($objNode)
                    $objNode -is
                        [Management.Automation.Language.AssignmentStatementAst] -and
                    $objNode.Left -is
                        [Management.Automation.Language.VariableExpressionAst]
                }, $true))
        $arrScopedAssignments = @($arrAssignments | Where-Object {
                $arrScopedName -ccontains $_.Left.VariablePath.UserPath
            })
        $arrUnqualifiedAssignments = @($arrAssignments | Where-Object {
                $arrUnqualifiedName -ccontains $_.Left.VariablePath.UserPath
            })
        $strExactBlockPattern =
            '(?m)^# Trusted-bootstrap compatibility data; do not use as active policy\.$' +
            '\n\$script:strLegacyMetadataRangeCompatibilityMarker =\n' +
            "    'metadata-range-transition-policy-v1'\n" +
            '\$script:strLegacyStyleGuideRationaleCompatibilityMarker =\n' +
            "    'style-guide-rationale-metadata-policy-v1'\n" +
            '\$script:strLegacyOperationalLintGuideCompatibilityMarker =\n' +
            "    'operational-lint-guide-metadata-policy-v1'$"
        $boolExactOccurrenceInventory = $true
        foreach ($strScopedName in $arrScopedName) {
            if ([regex]::Matches(
                    $Text,
                    [regex]::Escape([char] 36 + $strScopedName)
                ).Count -ne 2) {
                $boolExactOccurrenceInventory = $false
            }
        }
        if ($arrParseErrors.Count -ne 0 -or
            $arrScopedAssignments.Count -ne 3 -or
            @($arrScopedAssignments.Left.VariablePath.UserPath |
                    Sort-Object -Unique).Count -ne 3 -or
            $arrUnqualifiedAssignments.Count -ne 0 -or
            -not $boolExactOccurrenceInventory -or
            $Text -cnotmatch $strExactBlockPattern -or
            $Text.Contains(
                'PSUseDeclaredVarsMoreThanAssignments',
                [StringComparison]::Ordinal
            )) {
            throw "$Path does not satisfy semantic invariant $Invariant."
        }
        return
    }

    if ($Invariant -ceq 'workflow-created-push-history-fetch-is-bounded') {
        $arrRequiredLiteral = @(
            'PUSH_COMMIT_EVIDENCE: ${{ toJson(github.event.commits) }}',
            'const evidence = process.env.PUSH_COMMIT_EVIDENCE;',
            'Buffer.byteLength(evidence, "utf8") > 1048576',
            'commits = JSON.parse(evidence);',
            '!Array.isArray(commits) || commits.length >= 2048',
            '!/^[0-9a-f]{40}$/.test(entry.id)',
            'seenCommitIds.has(entry.id)',
            'if (ids.length > 0 &&',
            'ids[ids.length - 1] !== process.env.PUSH_AFTER_SHA',
            '(ids.length > 0 ? "\n" : ""), "utf8");',
            'fetch_depth=$((push_commit_count + 1))',
            'test "${fetch_depth}" -le 2048',
            "destination_local_ref='refs/remotes/event/created-destination'",
            '--no-write-fetch-head --no-recurse-submodules origin',
            '"${PUSH_REF}:${destination_local_ref}"',
            'test "${fetched_destination}" = "${PUSH_AFTER_SHA}"',
            'git cat-file -e "${push_commit_id}^{commit}"',
            'git ls-remote --sort=refname --refs --heads --tags origin',
            'Initial remote ref snapshot output bounding failed.',
            'Initial authenticated remote ref query failed.',
            'Final remote ref snapshot output bounding failed.',
            'Final remote ref evidence exceeded 1048576 bytes.',
            'Final authenticated remote ref query failed.',
            'cmp --silent "${raw_refs}" "${raw_refs_after}"',
            'Remote ref evidence changed during authentication.'
        )
        foreach ($strRequiredLiteral in $arrRequiredLiteral) {
            if (-not $Text.Contains(
                    $strRequiredLiteral,
                    [StringComparison]::Ordinal
                )) {
                throw "$Path does not satisfy semantic invariant $Invariant."
            }
        }
        $strBoundedFetchLiteral =
            'timeout 60s git fetch --depth="${fetch_depth}" --no-tags'
        if ([regex]::Matches(
                $Text,
                [regex]::Escape($strBoundedFetchLiteral)
            ).Count -ne 2 -or
            [regex]::Matches(
                $Text,
                [regex]::Escape(
                    'git ls-remote --sort=refname --refs --heads --tags origin'
                )
            ).Count -ne 2 -or
            $Text.Contains(
                'git ls-remote --refs --heads --tags origin',
                [StringComparison]::Ordinal
            ) -or
            $Text -cmatch '(?m)(^|\s)--force(\s|$)' -or
            $Text.Contains(
                '"+${PUSH_REF}:${destination_local_ref}"',
                [StringComparison]::Ordinal
            )) {
            throw "$Path does not satisfy semantic invariant $Invariant."
        }
        return
    }

    if ($Invariant -ceq 'current-base-status-helper-is-fail-closed') {
        foreach ($strRequiredLiteral in @(
                'const pullRequestPageSize = 10;',
                'const statusContextBatchSize = 10;',
                'const maximumPullRequestsPerSweep = 100;',
                'const maximumApiRequests = 25;',
                'const maximumOperationMilliseconds = 240000;',
                'const requestTimeoutMilliseconds = 8000;',
                'const maximumResponseBytes = 1048576;',
                'const maximumRequestPathCharacters = 4096;',
                'const maximumCursorCharacters = 1024;',
                'const maximumDispatchPayloadBytes = 4096;',
                'const maximumSweepRestarts = 2;',
                'const dispatchProtocol = ''agent-instruction-current-base/v1'';',
                'agent-instruction-current-base-continuation-v1',
                'agent-instruction-current-base-bootstrap-v1',
                'const currentBaseWorkflowPath =',
                'const validationWorkflowPath =',
                'const initialSnapshotDigest = createHash(''sha256'')',
                'const openPullRequestsQuery = `query OpenPullRequests(',
                '$owner: String!',
                '$name: String!',
                '$baseRefName: String!',
                '$pageSize: Int!',
                '$cursor: String',
                'after: $cursor',
                'states: OPEN',
                'baseRefName: $baseRefName',
                'orderBy: {field: CREATED_AT, direction: ASC}',
                'totalCount',
                'baseRepository {',
                'nameWithOwner',
                'headRefOid',
                'createdAt',
                'pageInfo {',
                'endCursor',
                'connection.nodes.length <= pullRequestPageSize',
                'hasNextPage: connection.pageInfo.hasNextPage,',
                'endCursor: connection.pageInfo.endCursor,',
                'query: `query ExactStatusContexts(',
                'latest: context(name: $context${index})',
                'targetUrl',
                'creator {',
                'creatorLogin: latest.creator === null ? null : latest.creator.login,',
                'const requestBudget = createRequestBudget();',
                'requestBudget.beginRequest();',
                'assertCanMutate(client, invalidations.length + followupRequests);',
                'Agent instruction current base/PR-${pullNumber}',
                'Agent instruction current base sweep/${branchDigest}',
                'latest.description === `Validated base ${currentBaseSha}.`',
                'statusHasActionsCreator(latest)',
                'function guardAllowsMergeControl(guard, currentBaseSha, runAuthenticated)',
                'function mergeControlAccepts(latest, guard, currentBaseSha,',
                'guardAllowsMergeControl(guard, currentBaseSha, guardRunAuthenticated)',
                'Sweep pending base ${baseSha}; state ${token}.',
                'Sweep complete base ${baseSha}; state ${token}.',
                'Agent current-base continuation: branch=${branch}; base=${baseSha}; ',
                'Both same-baseline pull requests must be invalidated.',
                'An older workflow-run signal must preserve a newer current success.',
                'Merge control must reject old success while the live-base guard is pending, ',
                'stale, or unauthenticated.',
                'Status contexts must be stable and pull-request-specific.',
                'A stale live base must fail finalization.',
                'A requested signal must authenticate its initial live state.',
                'A requested signal must accept an advanced live state.',
                'A completed signal must reconcile completed live state.',
                'A completed signal must reject nonterminal live state.',
                'A forged workflow-run signal must fail authentication.',
                'A cross-repository workflow-run signal must fail authentication.',
                'An unsupported workflow-run activity must fail authentication.',
                'A successful continuation run must authenticate.',
                'A failed continuation parent must not authenticate.',
                'A GitHub.com API request must preserve its encoded query.',
                'A GHES API request must preserve its API base and encoded branch path.',
                'A GitHub.com GraphQL request must resolve relative to its API root.',
                'A GHES GraphQL request must resolve relative to its API root.',
                'resolved.origin === apiRoot.origin',
                'resolved.pathname.startsWith(apiRoot.basePathname)',
                "getEnvironment('GITHUB_SERVER_URL')",
                "getEnvironment('GITHUB_GRAPHQL_URL')",
                "requestAtRoot(graphqlApiRoot, 'POST', 'graphql', body)",
                '`repos/${repository}/dispatches`',
                'event_type: eventType,',
                'client_payload: clientPayload,',
                'repos/${client.repository}/pulls/${expected.pullNumber}',
                'repos/${client.repository}/git/ref/heads/${encodeRef(expected.baseRef)}',
                'repos/${repository}/statuses/${headSha}',
                'run.path === validationWorkflowPath',
                'run.path === currentBaseWorkflowPath',
                'run.repository.full_name === expected.repository',
                'run.head_branch === expected.defaultBranch &&',
                'run.head_sha === expected.defaultSha &&',
                '!Object.hasOwn(result, ''errors'')',
                'GraphQL pull request response is invalid.',
                'GraphQL pull request connection is invalid.',
                'GraphQL pull request response entry is invalid.',
                'The first paginated GraphQL query variables must remain exact.',
                'A 21-plus inventory must return one bounded continuation page.',
                'A non-full continuation page must fail closed.',
                'A malformed GraphQL connection must fail closed.',
                'A duplicate GraphQL pull request must fail closed.',
                'Status reads must batch only exact PR-specific contexts.',
                'GraphQL status-context response is invalid.',
                'GraphQL status-context response entry is invalid.',
                'A GraphQL status-context error must fail closed.',
                'An exhausted global request budget must fail closed.',
                'A slow request sequence must fail before its deadline is exhausted.',
                'An oversized API response must fail closed.',
                'Base advanced to ${currentBaseSha}; revalidate PR #${pullNumber}.',
                'The prerequisite writer must publish one pending exact-base status.',
                'A pending or missing guard must not block validation from starting.',
                'Validation must not publish success before the guard succeeds.',
                'A validation rerun may publish success after the guard succeeds.',
                'A base edit before prerequisite publication must fail closed.',
                'A live prerequisite mismatch must not write a status.',
                'A base advance after success publication must fail closed.',
                'A finalization race must replace transient success with an error.',
                'A strictly newer authenticated same-endpoint success must be preserved.',
                'An old finalizer must reserve guard and run reads and preserve newer success.',
                'An old success-path mismatch must preserve newer authenticated success.',
                'An older authenticated run must fail closed with an error status.',
                'A newer failure must publish a fail-closed error.',
                'Malformed status provenance must fail closed with an error status.',
                'A run whose base provenance changed must fail closed.',
                'An indeterminate run read must fail closed with an error status.',
                'Request or deadline exhaustion must fail closed with an error status.',
                'A stale status must not suppress a finalizer error.',
                'run.event === ''pull_request_target''',
                'run.run_number',
                'run.run_attempt',
                'assertCanMutate(client, 6);',
                'await postPendingGuard(client, session, token, signal.targetUrl);',
                'await processSweepBatch(client, session, progress, {',
                'Continuation parent run does not match its live record.',
                'The continuation base is stale.',
                'Continuation state is stale or replayed.',
                'The live base changed during the sweep.',
                'The live base changed before sweep completion.',
                'The sweep guard changed before completion.',
                'Pull request inventory did not stabilize within the restart limit.',
                'A 21-PR sweep must invalidate every stale status in bounded continuations.',
                'Guard success must bind the exact final repository-dispatch run and state.',
                'A bootstrap must sweep an existing 21-plus PR base without a prior guard.',
                'A repeated bootstrap must preserve an authenticated completed guard.',
                'A bootstrap for a deleted branch must fail closed.',
                'A cross-repository bootstrap run must fail authentication.',
                'Malformed, extra, missing, or oversized continuation state must fail.',
                'A dispatch failure must leave the live-base guard incomplete.',
                'An API timeout must not publish invalidation or guard success.',
                'A partial batch failure must never publish guard success.',
                'A stale-base continuation must not publish guard success.',
                'A replayed continuation must not publish guard success.',
                'Pagination churn must trigger a bounded sweep restart.',
                'Repeated pagination churn must stop at the restart bound.',
                'async function verifyMergeEvidence(client, pullNumber) {',
                'const first = await readMergeSnapshot(client, pullNumber);',
                'assert(await authenticateMergeSnapshot(client, first),',
                'const second = await readMergeSnapshot(client, pullNumber);',
                'assert(mergeSnapshotsMatch(first, second),',
                'async function verifyMerge() {',
                'await verifyMergeEvidence(createClient(), Number(pullNumberText));',
                "mode === 'start' ? start :",
                "mode === 'verify-merge' ? verifyMerge : null;",
                'Expected start, finalize, invalidate, or verify-merge mode.'
            )) {
            if (-not $Text.Contains(
                    $strRequiredLiteral,
                    [StringComparison]::Ordinal
                )) {
                throw (
                    "$Path does not satisfy semantic invariant ${Invariant}: " +
                        "missing literal $strRequiredLiteral."
                )
            }
        }
        if ([regex]::Matches(
                $Text,
                [regex]::Escape('if (!await readLiveState(client, expected))')
            ).Count -ne 2) {
            throw "$Path does not satisfy semantic invariant $Invariant."
        }
        if ([regex]::Matches(
                $Text,
                [regex]::Escape('await publishFinalizerError(client, expected,')
            ).Count -ne 4) {
            throw "$Path does not satisfy semantic invariant $Invariant."
        }
        $objVerifyMergeFunctionMatch = [regex]::Match(
            $Text,
            '(?s)async function verifyMergeEvidence\(client, pullNumber\) \{' +
                '(?<Body>.*?)\n\}\n\nasync function verifyMerge\('
        )
        if (-not $objVerifyMergeFunctionMatch.Success -or
            $objVerifyMergeFunctionMatch.Groups['Body'].Value -cmatch
                'postStatus|dispatchRepository|request\(''POST''') {
            throw "$Path does not satisfy semantic invariant $Invariant."
        }
        $objPublishPendingFunctionMatch = [regex]::Match(
            $Text,
            '(?s)async function publishPending\(client, expected, targetUrl\) \{' +
                '(?<Body>.*?)\n\}\n\nasync function start\('
        )
        if (-not $objPublishPendingFunctionMatch.Success -or
            $objPublishPendingFunctionMatch.Groups['Body'].Value -cnotmatch
                "postStatus\(expected\.headSha, expected\.pullNumber, 'pending'" -or
            $objPublishPendingFunctionMatch.Groups['Body'].Value -cmatch
                'hasAuthenticatedSweepGuard') {
            throw "$Path does not satisfy semantic invariant $Invariant."
        }
        return
    }
    if (-not $script:hashtableSemanticInvariantPattern.ContainsKey($Invariant) -or
        $Text -cnotmatch
            $script:hashtableSemanticInvariantPattern[$Invariant]) {
        throw "$Path does not satisfy semantic invariant $Invariant."
    }
}

if ($SelfTest) {
    $scriptblockTestBoundedProcessInput = {
        param([Parameter(Mandatory)][string] $Root)
        $strEcho = 'const fs=require("node:fs");process.stdout.write(fs.readFileSync(0));'
        foreach ($strInput in @('', 'no-newline', "one-LF`n", "unicode-$([char]0xe9)-$([char]0x6f22)-$([char]0xd83d)$([char]0xde00)`n")) {
            $arrInput = [Text.UTF8Encoding]::new($false, $true).GetBytes($strInput)
            $objEcho = Invoke-BoundedProcessByte -FileName 'node' -ArgumentList @('-e', $strEcho) `
                -InputBytes $arrInput -MaximumBytes 1024
            if ($objEcho.ExitCode -ne 0 -or $objEcho.Error.Length -ne 0 -or
                [Convert]::ToBase64String($objEcho.Bytes) -cne [Convert]::ToBase64String($arrInput)) {
                throw 'Exact-byte stdin changed its content or EOF.'
            }
        }
        $arrMaximum = [byte[]]::new(524288)
        $objMaximum = Invoke-BoundedProcessByte -FileName 'node' -ArgumentList @('-e', $strEcho) `
            -InputBytes $arrMaximum -MaximumBytes 524288
        if ($objMaximum.ExitCode -ne 0 -or $objMaximum.Bytes.Length -ne 524288 -or
            [Convert]::ToBase64String($objMaximum.Bytes) -cne [Convert]::ToBase64String($arrMaximum)) {
            throw 'The maximum stdin buffer did not round trip.'
        }
        $strStartSentinel = Join-Path $Root 'oversized-input-started'
        $boolInputRejected = $false
        try {
            $null = Invoke-BoundedProcessByte -FileName 'node' `
                -ArgumentList @('-e', 'require("node:fs").writeFileSync(process.argv[1],"started");', $strStartSentinel) `
                -InputBytes ([byte[]]::new(524289)) -MaximumBytes 1
        } catch {
            if (-not $_.Exception.Message.Contains('input exceeds 524288 bytes', [StringComparison]::Ordinal)) { throw }
            $boolInputRejected = $true
        }
        if (-not $boolInputRejected -or [IO.File]::Exists($strStartSentinel)) {
            throw 'Oversized stdin was not rejected before startup.'
        }
        $strBackpressure = 'process.stdout.write(Buffer.alloc(65536,65),()=>process.stderr.write(Buffer.alloc(65536,66),()=>process.stdin.resume()));'
        $objBackpressure = Invoke-BoundedProcessByte -FileName 'node' -ArgumentList @('-e', $strBackpressure) `
            -InputBytes $arrMaximum -MaximumBytes 65536
        if ($objBackpressure.ExitCode -ne 0 -or $objBackpressure.Bytes.Length -ne 65536 -or
            $objBackpressure.Error.Length -ne 65536) {
            throw 'Concurrent bounded pipes did not drain.'
        }
        foreach ($objProbe in @(
                @{ Code = 'process.stdin.resume();process.stdout.write(Buffer.alloc(1025));'; Maximum = 1024; Error = 'output exceeded 1024 bytes' },
                @{ Code = 'process.stdin.resume();process.stdout.write(Buffer.alloc(65537));'; Maximum = 65536; Error = 'output exceeded 65536 bytes' },
                @{ Code = 'process.stdin.resume();process.stderr.write(Buffer.alloc(65537));'; Maximum = 1; Error = 'error output exceeded 65536 bytes' },
                @{ Code = 'setInterval(()=>{},1000);'; Maximum = 1; Error = 'exceeded its time limit' }
            )) {
            $strFailure = ''
            try {
                $null = Invoke-BoundedProcessByte -FileName 'node' -ArgumentList @('-e', $objProbe.Code) `
                    -InputBytes $arrMaximum -MaximumBytes $objProbe.Maximum -TimeoutMilliseconds 1000
            } catch {
                $strFailure = $_.Exception.Message
            }
            if (-not $strFailure.Contains($objProbe.Error, [StringComparison]::Ordinal)) {
                throw "A bounded process refusal failed: $($objProbe.Error)."
            }
        }
        $objExit = Invoke-BoundedProcessByte -FileName 'node' -ArgumentList @('-e', 'process.exit(7);') `
            -MaximumBytes 1
        if ($objExit.ExitCode -ne 7) { throw 'A native failure was not preserved.' }
        $boolEarlyExitRejected = $false
        try {
            $objEarlyExit = Invoke-BoundedProcessByte -FileName 'node' -ArgumentList @('-e', 'process.exit(7);') `
                -InputBytes $arrMaximum -MaximumBytes 1
            $boolEarlyExitRejected = $objEarlyExit.ExitCode -eq 7
        } catch {
            # A pipe-write failure is also rejection, never successful input.
            $boolEarlyExitRejected = $_.Exception.Message -match '(?i)pipe|closed|ended'
            if (-not $boolEarlyExitRejected) { throw }
        }
        if (-not $boolEarlyExitRejected) { throw 'Early child exit accepted incomplete input.' }
        $objNoInput = Invoke-BoundedProcessByte -FileName 'git' -ArgumentList @('--version') -MaximumBytes 1024
        if ($objNoInput.ExitCode -ne 0 -or $objNoInput.Bytes.Length -eq 0) {
            throw 'The no-input process contract regressed.'
        }
    }
    # Historical source is inert test data. Do not use the moving product as
    # the old-domain fixture after the isolation product has been installed.
    $scriptblockReadOrdinarySelfTestReference = {
        param([Parameter(Mandatory)][string] $Path)
        $objInfo = Get-Item -LiteralPath $Path -Force -ErrorAction Stop
        if ($objInfo -isnot [IO.FileInfo] -or
            ($objInfo.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw 'The ordinary self-test reference must be a regular file.'
        }
        if ($objInfo.Length -gt 262144) {
            throw 'The ordinary self-test reference exceeds 262144 bytes.'
        }
        $arrBytes = [IO.File]::ReadAllBytes($Path)
        if ($arrBytes.Length -gt 262144) {
            throw 'The ordinary self-test reference exceeds 262144 bytes.'
        }
        $strText = ConvertFrom-StrictUtf8Text -Bytes $arrBytes -Name 'The ordinary self-test reference'
        $objReference = & $script:scriptblockConvertFromStrictJsonHashtable `
            -Text $strText -Name 'The ordinary self-test reference'
        & $script:scriptblockAssertExactDictionaryKeySet -Dictionary $objReference `
            -Key @('schema', 'files') -Name 'The ordinary self-test reference'
        if ($objReference.schema -isnot [string] -or
            $objReference.schema -cne 'PSStyleGuide.OrdinarySelfTestReference.v1' -or
            $objReference.files -isnot [Collections.IDictionary]) {
            throw 'The ordinary self-test reference has an invalid schema.'
        }
        & $script:scriptblockAssertExactDictionaryKeySet -Dictionary $objReference.files `
            -Key @('build.yml', 'markdownlint.yml', 'pull-request-body-identity.yml',
                'Validate-WorkflowPolicy.mjs', 'workflow-policy-contract.json',
                'workflow-policy-cases.json') -Name 'The ordinary self-test file inventory'
        foreach ($objText in $objReference.files.Values) {
            if ($objText -isnot [string] -or [string]::IsNullOrEmpty($objText)) {
                throw 'An ordinary self-test reference text is invalid.'
            }
            $null = ConvertFrom-StrictUtf8Text -Bytes ([Text.UTF8Encoding]::new($false, $true).GetBytes($objText)) `
                -Name 'An ordinary self-test reference text'
        }
        return $objReference
    }
    $strOrdinarySelfTestReferencePath = Join-Path $RepositoryRootPath `
        '.github/workflows/workflow-ordinary-selftest-reference.json'
    $objOrdinarySelfTestReference = & $scriptblockReadOrdinarySelfTestReference `
        -Path $strOrdinarySelfTestReferencePath
    # Only this SelfTest invocation can substitute historical reference data.
    # The production reader and its authenticated Git path remain unchanged.
    $script:dictionaryPolicyReferenceText.Clear()
    foreach ($strHistoricalReferenceName in @('Validate-WorkflowPolicy.mjs',
            'workflow-policy-contract.json', 'workflow-policy-cases.json',
            'pull-request-body-identity.yml')) {
        $script:dictionaryPolicyReferenceText.Add(
            '.github/workflows/' + $strHistoricalReferenceName,
            $objOrdinarySelfTestReference.files[$strHistoricalReferenceName])
    }
    $strSelfTestSystemTempRoot = [IO.Path]::GetFullPath(
        [IO.Path]::GetTempPath()
    )
    $strSelfTestRoot = [IO.Path]::Combine(
        $strSelfTestSystemTempRoot,
        'trust-root-empty-blob-' + [Guid]::NewGuid().ToString('N')
    )
    [void] [IO.Directory]::CreateDirectory($strSelfTestRoot)
    try {
        & $scriptblockTestBoundedProcessInput -Root $strSelfTestRoot
        $strFixtureProbe = Join-Path $strSelfTestRoot 'ordinary-reference.json'
        $strFixtureSource = [IO.File]::ReadAllText($strOrdinarySelfTestReferencePath)
        foreach ($objProbe in @(
                @{ Name = 'maximum'; Text = $strFixtureSource + (' ' * (262144 - [Text.Encoding]::UTF8.GetByteCount($strFixtureSource))); Error = '' },
                @{ Name = 'overflow'; Text = ' ' * 262145; Error = 'exceeds 262144 bytes' },
                @{ Name = 'malformed'; Text = '{'; Error = 'is malformed JSON' },
                @{ Name = 'duplicate'; Text = '{"schema":1,"schema":2}'; Error = 'is malformed JSON' },
                @{ Name = 'extra'; Text = '{"schema":1,"files":{},"extra":true}'; Error = 'unexpected key set' },
                @{ Name = 'schema'; Text = '{"schema":1,"files":{}}'; Error = 'invalid schema' }
                @{ Name = 'schema-type'; Text = '{"schema":["PSStyleGuide.OrdinarySelfTestReference.v1"],"files":{}}'; Error = 'invalid schema' }
            )) {
            [IO.File]::WriteAllText($strFixtureProbe, $objProbe.Text, [Text.UTF8Encoding]::new($false))
            $strProbeFailure = ''
            try {
                $null = & $scriptblockReadOrdinarySelfTestReference -Path $strFixtureProbe
            } catch {
                $strProbeFailure = $_.Exception.Message
            }
            if (($objProbe.Error.Length -eq 0 -and $strProbeFailure.Length -ne 0) -or
                ($objProbe.Error.Length -gt 0 -and -not $strProbeFailure.Contains($objProbe.Error, [StringComparison]::Ordinal))) {
                throw "The ordinary reference probe failed: $($objProbe.Name)."
            }
        }
        foreach ($strInvalidFixturePath in @($strSelfTestRoot, (Join-Path $strSelfTestRoot 'missing-reference.json'))) {
            $boolFixtureRejected = $false
            try {
                $null = & $scriptblockReadOrdinarySelfTestReference -Path $strInvalidFixturePath
            } catch {
                $boolFixtureRejected = $_.Exception.Message.Contains('must be a regular file', [StringComparison]::Ordinal) -or
                    $_.CategoryInfo.Category -eq [Management.Automation.ErrorCategory]::ObjectNotFound
                if (-not $boolFixtureRejected) { throw }
            }
            if (-not $boolFixtureRejected) { throw 'An unavailable ordinary fixture passed.' }
        }
        if ([Environment]::OSVersion.Platform -eq [PlatformID]::Unix) {
            $strLinkedFixture = Join-Path $strSelfTestRoot 'linked-reference.json'
            $null = [IO.File]::CreateSymbolicLink($strLinkedFixture, $strOrdinarySelfTestReferencePath)
            $boolLinkedFixtureRejected = $false
            try {
                $null = & $scriptblockReadOrdinarySelfTestReference -Path $strLinkedFixture
            } catch {
                if (-not $_.Exception.Message.Contains('must be a regular file', [StringComparison]::Ordinal)) { throw }
                $boolLinkedFixtureRejected = $true
            }
            if (-not $boolLinkedFixtureRejected) { throw 'A linked historical reference passed.' }
        }
        & git -C $strSelfTestRoot init --quiet --object-format=sha1
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not initialize the empty-blob self-test repository.'
        }
        $strEmptyPath = Join-Path $strSelfTestRoot 'empty.md'
        [IO.File]::WriteAllBytes($strEmptyPath, [byte[]]::new(0))
        $strEmptyBlob = ([string] (& git -C $strSelfTestRoot `
                    hash-object -w -- empty.md)).Trim()
        if ($LASTEXITCODE -ne 0 -or
            $strEmptyBlob -cne 'e69de29bb2d1d6434b8b29ae775ad8c2e48c5391') {
            throw 'Could not create the canonical empty Git blob.'
        }
        $arrEmptyBytes = @(Read-GitBlobByte `
                -RepositoryRootPath $strSelfTestRoot `
                -BlobId $strEmptyBlob -MaximumBytes 0)
        if ($arrEmptyBytes.Count -ne 0) {
            throw 'A verified empty Git blob did not return an empty byte array.'
        }
        $strEmptyText = ConvertFrom-StrictUtf8Text `
            -Bytes ([byte[]]::new(0)) -Name 'empty.md'
        foreach ($intBoundarySize in @(
                $intCandidateMaximumBlobBytes, ($intCandidateMaximumBlobBytes + 1)
            )) {
            $strBoundaryPath = Join-Path $strSelfTestRoot 'capacity.txt'
            [IO.File]::WriteAllBytes($strBoundaryPath, [byte[]]::new($intBoundarySize))
            $strBoundaryBlob = ([string](& git -C $strSelfTestRoot `
                        hash-object -w -- $strBoundaryPath)).Trim()
            if ($LASTEXITCODE -ne 0 -or $strBoundaryBlob -cnotmatch $strObjectIdPattern) {
                throw 'Could not create the bounded capacity fixture blob.'
            }
            $boolCapacityRejected = $false
            try {
                $arrCapacityBytes = @(Read-GitBlobByte `
                        -RepositoryRootPath $strSelfTestRoot -BlobId $strBoundaryBlob `
                        -MaximumBytes $intCandidateMaximumBlobBytes)
                if ($arrCapacityBytes.Count -ne $intBoundarySize) {
                    throw 'The authorizer capacity fixture returned incomplete bytes.'
                }
            } catch {
                if ($intBoundarySize -le $intCandidateMaximumBlobBytes -or
                    -not $_.Exception.Message.Contains('byte limit',
                        [StringComparison]::Ordinal)) {
                    throw
                }
                $boolCapacityRejected = $true
            }
            if ($boolCapacityRejected -ne ($intBoundarySize -gt $intCandidateMaximumBlobBytes)) {
                throw 'The authorizer capacity boundary did not fail closed exactly.'
            }
        }
        Assert-CandidateSyntax -Syntax 'markdown' -Text $strEmptyText `
            -Path 'empty.md'
        # Execute only the local trusted acquisition helper, with an offline
        # transport double. Proposed objects remain inert throughout admission.
        & {
            param([string] $Root, [int] $Capacity)
            $strWorkflow = [IO.File]::ReadAllText(
                (Join-Path $PSScriptRoot 'pull-request-body-identity.yml'))
            $objHelperMatch = [regex]::Match($strWorkflow,
                '(?ms)^          function Add-ProposedBlob \{\n.*?(?=^          & \$strGitPath --no-replace-objects -c core.fsmonitor=false init --quiet \.\n)')
            if (-not $objHelperMatch.Success) {
                throw 'The trusted acquisition boundary helper is unavailable.'
            }
            $strHelper = [regex]::Replace($objHelperMatch.Value, '(?m)^          ', '')
            $arrHelperToken = $null
            $arrHelperError = $null
            [void][Management.Automation.Language.Parser]::ParseInput(
                $strHelper, [ref]$arrHelperToken, [ref]$arrHelperError)
            if ($arrHelperError.Count -ne 0) {
                throw 'The trusted acquisition boundary helper does not parse.'
            }
            . ([scriptblock]::Create($strHelper))
            # The extracted trusted function resolves these fixture bindings.
            $objFixtureGit = Get-Command git -CommandType Application |
                Select-Object -First 1
            if ($null -eq $objFixtureGit -or
                -not [IO.Path]::IsPathRooted($objFixtureGit.Source) -or
                -not [IO.File]::Exists($objFixtureGit.Source)) {
                throw 'The acquisition fixture requires one resolved native Git application.'
            }
            $strFixtureGitVersion = [string](& $objFixtureGit.Source --version)
            if ($LASTEXITCODE -ne 0 -or $strFixtureGitVersion -cnotmatch '^git version [0-9]+\.') {
                throw 'The acquisition fixture native Git version check failed.'
            }
            Set-Variable -Name strGitPath -Value $objFixtureGit.Source
            Set-Variable -Name strHeadRepository -Value 'fixture/offline'
            $strPriorRunnerTemp = $env:RUNNER_TEMP
            Set-Variable -Name strCurlPath -Value {
                $arrArgument = @($args)
                $intOutput = [Array]::IndexOf($arrArgument, '--output')
                $intRange = [Array]::IndexOf($arrArgument, '--range')
                $intMaximum = [Array]::IndexOf($arrArgument, '--max-filesize')
                if ($intOutput -lt 0 -or $intRange -lt 0 -or $intMaximum -lt 0 -or
                    $arrArgument[$intRange + 1] -cne "0-$Capacity" -or
                    [long]$arrArgument[$intMaximum + 1] -ne ($Capacity + 1)) {
                    throw 'The acquisition fixture did not retain finite transport bounds.'
                }
                [IO.File]::WriteAllBytes([string]$arrArgument[$intOutput + 1], $arrTransferBytes)
                Set-Variable -Name LASTEXITCODE -Value 0 -Scope 1
            }
            Push-Location -LiteralPath $Root
            try {
                $env:RUNNER_TEMP = $Root
                foreach ($intTransferBytes in @($Capacity, ($Capacity + 1))) {
                    $strFixturePath = Join-Path $Root 'transfer.bin'
                    $arrTransferBytes = [byte[]]::new($intTransferBytes)
                    $arrTransferBytes[0] = 1
                    [IO.File]::WriteAllBytes($strFixturePath, $arrTransferBytes)
                    $strExpectedBlob = ([string](& git hash-object --no-filters $strFixturePath)).Trim()
                    if ($LASTEXITCODE -ne 0) { throw 'Could not identify the transfer fixture.' }
                    $strHeadSha = ([string]("100644 blob $strExpectedBlob`t`"transfer.bin`"" |
                            git mktree --missing)).Trim()
                    if ($LASTEXITCODE -ne 0) { throw 'Could not create the transfer fixture tree.' }
                    $strFixtureEntry = [string](& git ls-tree $strHeadSha -- transfer.bin)
                    if ($LASTEXITCODE -ne 0 -or
                        $strFixtureEntry -cne "100644 blob $strExpectedBlob`ttransfer.bin") {
                        throw 'The synthetic transfer fixture tree is not exact.'
                    }
                    $boolRejected = $false
                    try {
                        $longTransferred = Add-ProposedBlob -RepositoryPath 'transfer.bin' `
                            -MaximumBytes $Capacity -Sequence 1 -ExpectedBlob $strExpectedBlob
                        if ($longTransferred -ne $intTransferBytes) {
                            throw 'The acquisition boundary returned an invalid byte count.'
                        }
                        if ((Add-ProposedBlob -RepositoryPath 'transfer.bin' `
                                    -MaximumBytes $Capacity -Sequence 1 `
                                    -ExpectedBlob $strExpectedBlob) -ne 0) {
                            throw 'The cached acquisition fixture unexpectedly transferred bytes.'
                        }
                    } catch {
                        if ($intTransferBytes -le $Capacity -or
                            $_.Exception.Message -cne 'acquire: transfer.bin exceeds its byte contract') {
                            throw
                        }
                        $boolRejected = $true
                    }
                    if ($boolRejected -ne ($intTransferBytes -gt $Capacity)) {
                        throw 'The acquisition transfer boundary did not fail closed exactly.'
                    }
                }
                try {
                    [void](Add-ProposedBlob -RepositoryPath 'transfer.bin' `
                            -MaximumBytes ($Capacity + 1) -Sequence 1)
                    throw 'The acquisition accepted an excessive requested capacity.'
                } catch {
                    if ($_.Exception.Message -cne 'acquire: a proposed blob request is invalid') { throw }
                }
            } finally {
                Pop-Location
                $env:RUNNER_TEMP = $strPriorRunnerTemp
            }
        } -Root $strSelfTestRoot -Capacity $intCandidateMaximumBlobBytes
        try {
            Assert-SemanticInvariant -Invariant 'docs-status-lifecycle-values' `
                -Text $strEmptyText -Path 'empty.md'
            throw 'An empty governed document passed its content invariant.'
        } catch {
            if ($_.Exception.Message -ceq
                'An empty governed document passed its content invariant.' -or
                -not $_.Exception.Message.Contains(
                    'does not satisfy semantic invariant docs-status-lifecycle-values',
                    [StringComparison]::Ordinal
                )) {
                throw
            }
        }
    } finally {
        if ([IO.Directory]::Exists($strSelfTestRoot) -and
            $strSelfTestRoot.StartsWith(
                $strSelfTestSystemTempRoot,
                [StringComparison]::OrdinalIgnoreCase
            )) {
            Remove-Item -LiteralPath $strSelfTestRoot -Recurse -Force
        }
    }
    Assert-CandidateSyntax -Syntax 'javascript' `
        -Text "import https from 'node:https';`nvoid https;`n" `
        -Path 'valid.mjs'
    try {
        Assert-CandidateSyntax -Syntax 'javascript' `
            -Text "import from 'node:https';`n" -Path 'invalid.mjs'
        throw 'Invalid JavaScript syntax passed.'
    } catch {
        if ($_.Exception.Message -ceq 'Invalid JavaScript syntax passed.' -or
            -not $_.Exception.Message.Contains(
                'has invalid JavaScript syntax.',
                [StringComparison]::Ordinal
            )) {
            throw
        }
    }
    $strOwnerBoundary =
        '- `.github/instructions/docs.instructions.md` owns these ' +
            'documentation rules.'
    Assert-SemanticInvariant -Invariant 'docs-policy-owner-boundary' `
        -Text $strOwnerBoundary -Path '.github/instructions/docs.instructions.md'
    $strOwnerBoundaryMutation = $strOwnerBoundary.Replace(
        ' owns these ',
        ' describes these ',
        [StringComparison]::Ordinal
    )
    try {
        Assert-SemanticInvariant -Invariant 'docs-policy-owner-boundary' `
            -Text $strOwnerBoundaryMutation `
            -Path '.github/instructions/docs.instructions.md'
        throw 'The documentation owner-boundary mutation passed.'
    } catch {
        if ($_.Exception.Message -ceq
            'The documentation owner-boundary mutation passed.' -or
            -not $_.Exception.Message.Contains(
                'does not satisfy semantic invariant docs-policy-owner-boundary',
                [StringComparison]::Ordinal
            )) {
            throw
        }
    }
    foreach ($strRemovedInvariant in @(
            'docs-owner-enforcer-relationship',
            'metadata-history-validates-parent-edges'
        )) {
        try {
            Assert-SemanticInvariant -Invariant $strRemovedInvariant `
                -Text $strOwnerBoundary `
                -Path '.github/instructions/docs.instructions.md'
            throw "Removed semantic invariant $strRemovedInvariant passed."
        } catch {
            if ($_.Exception.Message -ceq
                "Removed semantic invariant $strRemovedInvariant passed." -or
                -not $_.Exception.Message.Contains(
                    "does not satisfy semantic invariant $strRemovedInvariant",
                    [StringComparison]::Ordinal
                )) {
                throw
            }
        }
    }
    Assert-CandidateSyntax -Syntax 'json' `
        -Text '{"schema_version":2}' -Path 'valid.json'
    try {
        Assert-CandidateSyntax -Syntax 'json' `
            -Text '{"schema_version":2,"schema_version":2}' `
            -Path 'duplicate.json'
        throw 'Duplicate JSON syntax passed.'
    } catch {
        if ($_.Exception.Message -ceq 'Duplicate JSON syntax passed.' -or
            -not $_.Exception.Message.Contains(
                'has invalid JSON syntax.',
                [StringComparison]::Ordinal
            )) {
            throw
        }
    }

    $scriptblockExpectInvariantRejection = {
        param(
            [Parameter(Mandatory)][string] $Invariant,
            [Parameter(Mandatory)][string] $Text,
            [Parameter(Mandatory)][string] $Path,
            [Parameter(Mandatory)][string] $Name
        )
        try {
            Assert-SemanticInvariant -Invariant $Invariant `
                -Text $Text -Path $Path
            throw "Semantic invariant mutation passed: $Name"
        } catch {
            if ($_.Exception.Message -ceq
                "Semantic invariant mutation passed: $Name" -or
                -not $_.Exception.Message.Contains(
                    "does not satisfy semantic invariant $Invariant",
                    [StringComparison]::Ordinal
                )) {
                throw
            }
        }
    }
    $arrNewInvariantSpec = @(
        [pscustomobject]@{
            Path = '.github/actionlint.yaml'
            Syntax = 'yaml'
            Invariant = 'actionlint-queue-schema-exceptions-are-exact'
            MutationFrom =
                '.github/workflows/agent-instruction-current-base.yml:'
            MutationTo = '.github/workflows/build.yml:'
        },
        [pscustomobject]@{
            Path = '.github/workflows/Test-AgentInstructionParserManifest.mjs'
            Syntax = 'javascript'
            Invariant =
                'parser-manifest-direct-roots-and-closure-is-exact'
            MutationFrom =
                'const EXECUTABLE_PARSER_NAMES = ["js-yaml", "markdown-it"];'
            MutationTo =
                'const EXECUTABLE_PARSER_NAMES = ["markdown-it", "js-yaml"];'
        },
        [pscustomobject]@{
            Path = '.github/workflows/Test-AgentInstructions.ps1'
            Syntax = 'powershell'
            Invariant =
                'agent-instruction-heading-status-and-bootstrap-order-is-exact'
            MutationFrom =
                'if (token.type !== "heading_open" || token.level !== 0) return [];'
            MutationTo =
                'if (token.type !== "heading_open") return [];'
        },
        [pscustomobject]@{
            Path = '.pre-commit-config.yaml'
            Syntax = 'yaml'
            Invariant = 'pre-commit-actionlint-gate-is-exact'
            MutationFrom =
                'rev: "011a6d15e749bb3f2d771eed9c7aa0e7e3e10ee7"'
            MutationTo = 'rev: "v1.7.12"'
        },
        [pscustomobject]@{
            Path = '.github/workflows/Validate-WorkflowPolicy.mjs'
            Syntax = 'javascript'
            Invariant =
                'workflow-policy-preflight-authenticates-deferred-yaml-import'
            MutationFrom = 'verifyPackageDigests(bootstrapContract);'
            MutationTo = 'void bootstrapContract;'
        },
        [pscustomobject]@{
            Path = '.github/workflows/workflow-policy-contract.json'
            Syntax = 'json'
            Invariant =
                'workflow-policy-contract-identities-and-structure-are-exact'
            MutationFrom = '"path": "Validate-WorkflowPolicy.mjs"'
            MutationTo = '"path": "Other-Validator.mjs"'
        },
        [pscustomobject]@{
            Path = '.github/workflows/Sync-PullRequestBodyIdentity.mjs'
            Syntax = 'javascript'
            Invariant =
                'pull-request-body-identity-api-termination-is-bounded'
            MutationFrom = 'import crypto from ''node:crypto'';'
            MutationTo = 'import crypto from ''node:crypto2'';'
        },
        [pscustomobject]@{
            Path = '.github/workflows/pull-request-body-identity-cases.json'
            Syntax = 'json'
            Invariant =
                'pull-request-body-identity-cases-preserve-required-coverage'
            MutationFrom = '"expected": "identity-block-absent"'
            MutationTo = '"expected": "current"'
        },
        [pscustomobject]@{
            Path = '.github/workflows/pull-request-body-identity.yml'
            Syntax = 'yaml'
            Invariant =
                'pull-request-body-identity-workflow-topology-is-exact'
            MutationFrom = 'name: Pull Request Body Identity'
            MutationTo = 'name: Unreviewed Pull Request Body Identity'
        },
        [pscustomobject]@{
            Path = '.github/workflows/workflow-policy-cases.json'
            Syntax = 'json'
            Invariant = 'workflow-policy-identity-cases-are-exact'
            MutationFrom = '"PS-P1-WFPOL-057"'
            MutationTo = '"PS-P1-WFPOL-056"'
        },
        [pscustomobject]@{
            Path = 'package.json'
            Syntax = 'json'
            Invariant = 'package-parser-roots-are-exact'
            MutationFrom = '"js-yaml": "5.2.2"'
            MutationTo = '"js-yaml": "5.2.1"'
        },
        [pscustomobject]@{
            Path = 'package-lock.json'
            Syntax = 'json'
            Invariant = 'package-lock-parser-closure-is-exact'
            MutationFrom =
                'sha512-dayzUzKkJ1MkuUtZglSebU43utNXH0OWQByK9rKOOuYIO8M5TV1y+n8ALMdG0rdzBnfNkOmZEqrURepb0ejqBw=='
            MutationTo = 'sha512-corrupted-parser-integrity'
        }
    )
    $hashtableNewInvariantText = @{}
    foreach ($objInvariantSpec in $arrNewInvariantSpec) {
        $strInvariantSourcePath =
            Join-Path $RepositoryRootPath $objInvariantSpec.Path
        $strInvariantFileName = [IO.Path]::GetFileName($objInvariantSpec.Path)
        $arrInvariantBytes = if ($objOrdinarySelfTestReference.files.Contains($strInvariantFileName)) {
            [Text.UTF8Encoding]::new($false).GetBytes($objOrdinarySelfTestReference.files[$strInvariantFileName])
        } else {
            [IO.File]::ReadAllBytes($strInvariantSourcePath)
        }
        $strInvariantText = ConvertFrom-StrictUtf8Text `
            -Bytes $arrInvariantBytes -Name $objInvariantSpec.Path
        $hashtableNewInvariantText[$objInvariantSpec.Path] = $strInvariantText
        Assert-CandidateSyntax -Syntax $objInvariantSpec.Syntax `
            -Text $strInvariantText -Path $objInvariantSpec.Path
        Assert-SemanticInvariant -Invariant $objInvariantSpec.Invariant `
            -Text $strInvariantText -Path $objInvariantSpec.Path
        & $scriptblockExpectInvariantRejection `
            -Invariant $objInvariantSpec.Invariant -Text $strInvariantText `
            -Path "wrong/$($objInvariantSpec.Path)" `
            -Name "$($objInvariantSpec.Invariant) wrong path"
        $strMutation = $strInvariantText.Replace(
            $objInvariantSpec.MutationFrom,
            $objInvariantSpec.MutationTo,
            [StringComparison]::Ordinal
        )
        if ($strMutation -ceq $strInvariantText) {
            throw "$($objInvariantSpec.Invariant) mutation fixture did not change."
        }
        & $scriptblockExpectInvariantRejection `
            -Invariant $objInvariantSpec.Invariant -Text $strMutation `
            -Path $objInvariantSpec.Path `
            -Name "$($objInvariantSpec.Invariant) targeted corruption"
    }
    $strPublishedPathInvariantSource = $hashtableNewInvariantText[
        '.github/workflows/Test-AgentInstructions.ps1'
    ]
    Assert-SemanticInvariant -Invariant 'published-path-array-binding-is-explicit' `
        -Text $strPublishedPathInvariantSource `
        -Path '.github/workflows/Test-AgentInstructions.ps1'
    foreach ($strPublishedPathMutation in @(
            'A created ref with no introduced commits returned a path comparison.',
            'A zero-introduction created ref has no content-validation path range.',
            'created-ref-no-introduced-commits',
            '"requiredGate":"agent-instruction-current-base"',
            '[string[]] $arrPublishedNewRefBoundaryRevisions = @()',
            "Name = 'null boundary'",
            "Name = 'empty boundary'",
            "Name = 'invalid introduced revision'"
        )) {
        if (-not $strPublishedPathInvariantSource.Contains(
                $strPublishedPathMutation, [StringComparison]::Ordinal
            )) {
            throw 'A published-path invariant mutation target is absent.'
        }
        $strPublishedPathMutationText = $strPublishedPathInvariantSource.Replace(
            $strPublishedPathMutation, 'removed-invariant-fixture',
            [StringComparison]::Ordinal
        )
        & $scriptblockExpectInvariantRejection `
            -Invariant 'published-path-array-binding-is-explicit' `
            -Text $strPublishedPathMutationText `
            -Path '.github/workflows/Test-AgentInstructions.ps1' `
            -Name 'published-path required assertion removal'
    }
    $strIdentityCaseCatalogPath =
        '.github/workflows/pull-request-body-identity-cases.json'
    $objMissingIdentityCaseCatalog =
        & $script:scriptblockConvertFromStrictJsonHashtable `
        -Text $hashtableNewInvariantText[$strIdentityCaseCatalogPath] `
        -Name 'pull request body identity missing-case mutation'
    $objMissingIdentityCaseCatalog.bodyCases = @(
        $objMissingIdentityCaseCatalog.bodyCases | Where-Object {
            $_.id -cne 'check-absent'
        }
    )
    & $scriptblockExpectInvariantRejection `
        -Invariant `
            'pull-request-body-identity-cases-preserve-required-coverage' `
        -Text (ConvertTo-Json -InputObject $objMissingIdentityCaseCatalog `
            -Depth 8) `
        -Path $strIdentityCaseCatalogPath `
        -Name 'pull request body identity required case removal'
    $strCurrentPolicyValidator = $hashtableNewInvariantText[
        '.github/workflows/Validate-WorkflowPolicy.mjs'
    ]
    $strCurrentPolicyContract = $hashtableNewInvariantText[
        '.github/workflows/workflow-policy-contract.json'
    ]
    if ($strCurrentPolicyValidator -cmatch
        "(?m)^const VALIDATOR_VERSION = '(1\.(?:3|4|5)\.[0-9]+)';$") {
        $strCurrentVersion = $Matches[1]
        $arrCurrentDigest = [regex]::Matches($strCurrentPolicyValidator,
            "(?m)^const EXPECTED_CONTRACT_CANONICAL_SHA256 = '([0-9a-f]{64})';$")
        if ($arrCurrentDigest.Count -ne 1) {
            throw 'The current policy fixture has an ambiguous digest literal.'
        }
        $strCurrentDigest = $arrCurrentDigest[0].Groups[1].Value
        $strCurrentValidatorSha256 = [Convert]::ToHexString(
            [Security.Cryptography.SHA256]::HashData(
                [Text.UTF8Encoding]::new($false).GetBytes($strCurrentPolicyValidator)
            )
        ).ToLowerInvariant()
        $strAlternateVersion = '1.2.8'
        $strAlternateDigest =
            'd6b5ad4774bbd4fed0608eec3e885d63f9c1b30951aa363a9a3e947a94cd0573'
        $strAlternateValidatorSha256 =
            'df9e8a124fcd62996b0d2e70571042deeaf9e248c0b9150850378271c974606c'
    } elseif ($strCurrentPolicyValidator.Contains(
            "const VALIDATOR_VERSION = '1.2.2';",
            [StringComparison]::Ordinal
        )) {
        $strCurrentVersion = '1.2.2'
        $strCurrentDigest =
            '99bbdec8c80cced95287b50707a70071fe785e0dc5a715bf7439c8d04d5d52d6'
        $strCurrentValidatorSha256 =
            '33554c001f6613be74db3644aa097e18322c2cf9ab7e064e721006ba456a58a9'
        $strAlternateVersion = '1.2.3'
        $strAlternateDigest =
            'c54d390c79bcd7a17d2acc214ee412d8b40c2eee310c28917df2260837dda9bb'
        $strAlternateValidatorSha256 =
            'ca9b76f363f2f94209cc1e33fe1ea5a61ce6ad2b1fedcafabd5e06e2e65e3202'
    } elseif ($strCurrentPolicyValidator.Contains(
            "const VALIDATOR_VERSION = '1.2.3';",
            [StringComparison]::Ordinal
        )) {
        $strCurrentVersion = '1.2.3'
        $strCurrentDigest =
            'c54d390c79bcd7a17d2acc214ee412d8b40c2eee310c28917df2260837dda9bb'
        $strCurrentValidatorSha256 =
            'ca9b76f363f2f94209cc1e33fe1ea5a61ce6ad2b1fedcafabd5e06e2e65e3202'
        $strAlternateVersion = '1.2.4'
        $strAlternateDigest =
            'd29855fa383bb5ef8255b18a4287e6da45e73814755eafa65dab060d80941824'
        $strAlternateValidatorSha256 =
            '386ed401ec8a3488e8d03a068a38b9fcd965c9f2a158c565a7cb7e20a03c0dbb'
    } elseif ($strCurrentPolicyValidator.Contains(
            "const VALIDATOR_VERSION = '1.2.4';",
            [StringComparison]::Ordinal
        )) {
        $strCurrentVersion = '1.2.4'
        $strCurrentDigest =
            'd29855fa383bb5ef8255b18a4287e6da45e73814755eafa65dab060d80941824'
        $strCurrentValidatorSha256 =
            '386ed401ec8a3488e8d03a068a38b9fcd965c9f2a158c565a7cb7e20a03c0dbb'
        $strAlternateVersion = '1.2.6'
        $strAlternateDigest =
            '98ad8ff52efd053a1a0e48a54b7ce388ebba498446130051d34259564faf75d0'
        $strAlternateValidatorSha256 =
            '481b301a3557680ceef40dcfa15ab3f73bda0ff5d132afc15cd900221180cdc6'
    } elseif ($strCurrentPolicyValidator.Contains(
            "const VALIDATOR_VERSION = '1.2.6';",
            [StringComparison]::Ordinal
        )) {
        $strCurrentVersion = '1.2.6'
        $strCurrentDigest =
            '98ad8ff52efd053a1a0e48a54b7ce388ebba498446130051d34259564faf75d0'
        $strCurrentValidatorSha256 =
            '481b301a3557680ceef40dcfa15ab3f73bda0ff5d132afc15cd900221180cdc6'
        $strAlternateVersion = '1.2.7'
        $strAlternateDigest =
            '0490a0fafe4e58a57990c8286771cec8d6605891d884ff30dc6a1c5193aeff2c'
        $strAlternateValidatorSha256 =
            '45452a233005379579f8eedf626cadf8b9af7a05767463c4f225ac82524f9791'
    } elseif ($strCurrentPolicyValidator.Contains(
            "const VALIDATOR_VERSION = '1.2.7';",
            [StringComparison]::Ordinal
        )) {
        $strCurrentVersion = '1.2.7'
        $strCurrentDigest =
            '0490a0fafe4e58a57990c8286771cec8d6605891d884ff30dc6a1c5193aeff2c'
        $strCurrentValidatorSha256 =
            '45452a233005379579f8eedf626cadf8b9af7a05767463c4f225ac82524f9791'
        $strAlternateVersion = '1.2.6'
        $strAlternateDigest =
            '98ad8ff52efd053a1a0e48a54b7ce388ebba498446130051d34259564faf75d0'
        $strAlternateValidatorSha256 =
            '481b301a3557680ceef40dcfa15ab3f73bda0ff5d132afc15cd900221180cdc6'
    } elseif ($strCurrentPolicyValidator.Contains(
            "const VALIDATOR_VERSION = '1.2.8';",
            [StringComparison]::Ordinal
        )) {
        $strCurrentVersion = '1.2.8'
        $strCurrentDigest =
            'd6b5ad4774bbd4fed0608eec3e885d63f9c1b30951aa363a9a3e947a94cd0573'
        $strCurrentValidatorSha256 =
            'df9e8a124fcd62996b0d2e70571042deeaf9e248c0b9150850378271c974606c'
        $strAlternateVersion = '1.2.7'
        $strAlternateDigest =
            '0490a0fafe4e58a57990c8286771cec8d6605891d884ff30dc6a1c5193aeff2c'
        $strAlternateValidatorSha256 =
            '45452a233005379579f8eedf626cadf8b9af7a05767463c4f225ac82524f9791'
    } else {
        throw 'The workflow policy validator does not contain an accepted version.'
    }
    $strAlternatePolicyValidator = $strCurrentPolicyValidator.Replace(
        "const VALIDATOR_VERSION = '$strCurrentVersion';",
        "const VALIDATOR_VERSION = '$strAlternateVersion';",
        [StringComparison]::Ordinal
    ).Replace(
        "const EXPECTED_CONTRACT_CANONICAL_SHA256 = '$strCurrentDigest';",
        "const EXPECTED_CONTRACT_CANONICAL_SHA256 = '$strAlternateDigest';",
        [StringComparison]::Ordinal
    )
    $strAlternatePolicyContract = $strCurrentPolicyContract.Replace(
        $strCurrentValidatorSha256,
        $strAlternateValidatorSha256,
        [StringComparison]::Ordinal
    )
    if ($strCurrentVersion.StartsWith('1.2.', [StringComparison]::Ordinal)) {
        Assert-SemanticInvariant `
            -Invariant 'workflow-policy-preflight-authenticates-deferred-yaml-import' `
            -Text $strAlternatePolicyValidator `
            -Path '.github/workflows/Validate-WorkflowPolicy.mjs'
        Assert-SemanticInvariant `
            -Invariant 'workflow-policy-contract-identities-and-structure-are-exact' `
            -Text $strAlternatePolicyContract `
            -Path '.github/workflows/workflow-policy-contract.json'
    } else {
        & $scriptblockExpectInvariantRejection `
            -Invariant 'workflow-policy-preflight-authenticates-deferred-yaml-import' `
            -Text $strAlternatePolicyValidator `
            -Path '.github/workflows/Validate-WorkflowPolicy.mjs' `
            -Name 'current code falsely labelled with a historical tuple'
    }
    Assert-WorkflowPolicyTransitionTuple `
        -ValidatorText $strCurrentPolicyValidator `
        -ContractText $strCurrentPolicyContract
    $arrPolicyTupleMutation = @(
        [pscustomobject]@{
            Name = 'Unicode-ignorable exact-reference drift'
            Validator = $strCurrentPolicyValidator + [char]0x200B
            Contract = $strCurrentPolicyContract
        },
        [pscustomobject]@{
            Name = 'synthetic next tuple with wrong validator bytes'
            Validator = $strAlternatePolicyValidator
            Contract = $strAlternatePolicyContract
        },
        [pscustomobject]@{
            Name = 'changed validator bytes with accepted literals'
            Validator = $strCurrentPolicyValidator + "`n// unauthorized bytes"
            Contract = $strCurrentPolicyContract
        },
        [pscustomobject]@{
            Name = 'changed contract identity content'
            Validator = $strCurrentPolicyValidator
            Contract = $strCurrentPolicyContract.Replace(
                '"contractVersion": 1',
                '"contractVersion": 2',
                [StringComparison]::Ordinal
            )
        },
        [pscustomobject]@{
            Name = 'mixed validator version and digest'
            Validator = $strCurrentPolicyValidator.Replace(
                "const VALIDATOR_VERSION = '$strCurrentVersion';",
                "const VALIDATOR_VERSION = '$strAlternateVersion';",
                [StringComparison]::Ordinal
            )
            Contract = $strAlternatePolicyContract
        },
        [pscustomobject]@{
            Name = 'mismatched validator and contract'
            Validator = $strCurrentPolicyValidator
            Contract = $strAlternatePolicyContract
        },
        [pscustomobject]@{
            Name = 'duplicate accepted validator tuples'
            Validator = $strCurrentPolicyValidator + "`n" +
                $strAlternatePolicyValidator
            Contract = $strAlternatePolicyContract
        }
    )
    foreach ($objPolicyTupleMutation in $arrPolicyTupleMutation) {
        try {
            Assert-WorkflowPolicyTransitionTuple `
                -ValidatorText $objPolicyTupleMutation.Validator `
                -ContractText $objPolicyTupleMutation.Contract
            throw "Workflow-policy tuple mutation passed: $($objPolicyTupleMutation.Name)"
        } catch {
            if ($_.Exception.Message -ceq
                    "Workflow-policy tuple mutation passed: $($objPolicyTupleMutation.Name)" -or
                -not $_.Exception.Message.Contains(
                    'workflow-policy identity transition tuple',
                    [StringComparison]::Ordinal
                )) {
                throw
            }
        }
    }
    $objShadowLock = & $script:scriptblockConvertFromStrictJsonHashtable `
        -Text $hashtableNewInvariantText['package-lock.json'] `
        -Name 'package-lock shadow mutation'
    $objShadowDescriptor =
        & $script:scriptblockConvertFromStrictJsonHashtable `
        -Text (ConvertTo-Json `
            -InputObject $objShadowLock.packages['node_modules/argparse'] `
            -Depth 16 -Compress) `
        -Name 'package-lock shadow descriptor'
    $objShadowDescriptor.version = '2.0.2'
    $objShadowLock.packages[
        'node_modules/js-yaml/node_modules/argparse'
    ] = $objShadowDescriptor
    $strShadowLock = ConvertTo-Json `
        -InputObject $objShadowLock -Depth 100 -Compress
    & $scriptblockExpectInvariantRejection `
        -Invariant 'package-lock-parser-closure-is-exact' `
        -Text $strShadowLock -Path 'package-lock.json' `
        -Name 'package-lock parser shadowing'

    $strSchemaSystemTempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    $strSchemaFixtureRoot = [IO.Path]::Combine(
        $strSchemaSystemTempRoot,
        'trust-root-schema2-' + [Guid]::NewGuid().ToString('N')
    )
    [void] [IO.Directory]::CreateDirectory($strSchemaFixtureRoot)
    try {
        & git -C $strSchemaFixtureRoot init --quiet --object-format=sha1
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not initialize the schema 2 self-test repository.'
        }
        $arrSchemaPathSpec = @(
            [pscustomobject]@{
                Path = '.github/actionlint.yaml'
                Syntax = 'yaml'
                Invariants = @('actionlint-queue-schema-exceptions-are-exact')
            },
            [pscustomobject]@{
                Path = '.github/instructions/docs.instructions.md'
                Syntax = 'markdown'
                Invariants = @(
                    'docs-policy-owner-boundary',
                    'docs-status-lifecycle-values'
                )
            },
            [pscustomobject]@{
                Path = '.github/workflows/Set-AgentInstructionCurrentBaseStatus.mjs'
                Syntax = 'javascript'
                Invariants = @('current-base-status-helper-is-fail-closed')
            },
            [pscustomobject]@{
                Path = '.github/workflows/Test-AgentInstructionParserManifest.mjs'
                Syntax = 'javascript'
                Invariants = @(
                    'parser-manifest-direct-roots-and-closure-is-exact'
                )
            },
            [pscustomobject]@{
                Path = '.github/workflows/Test-AgentInstructions.SelfTest.ps1'
                Syntax = 'powershell'
                Invariants = @('extracted-self-test-version-and-topology')
            },
            [pscustomobject]@{
                Path = '.github/workflows/Test-AgentInstructions.ps1'
                Syntax = 'powershell'
                Invariants = @(
                    'adr-lifecycle-migration-is-enforced',
                    'created-ref-metadata-baseline-is-consumed',
                    'created-ref-paths-use-endpoint-boundary',
                    'exact-maintenance-production-call-is-gated',
                    'extracted-self-test-is-invoked',
                    'legacy-transition-marker-is-inert-data',
                    'new-ref-boundary-cap-is-64',
                    'ordinary-pr-uses-normal-trust-audit',
                    'published-path-array-binding-is-explicit',
                    'published-finalization-date-is-enforced',
                    'pr-merge-bases-use-all-and-cap',
                    'trusted-maintenance-switch-is-explicit',
                    'agent-instruction-heading-status-and-bootstrap-order-is-exact'
                )
            },
            [pscustomobject]@{
                Path = '.github/workflows/Test-TrustRootAuthorization.ps1'
                Syntax = 'powershell'
                Invariants = @(
                    'verifier-audits-authorized-history',
                    'verifier-reads-trusted-revision-manifest'
                )
            },
            [pscustomobject]@{
                Path = '.github/workflows/Sync-PullRequestBodyIdentity.mjs'
                Syntax = 'javascript'
                Invariants = @(
                    'pull-request-body-identity-api-termination-is-bounded'
                )
            },
            [pscustomobject]@{
                Path = '.github/workflows/pull-request-body-identity-cases.json'
                Syntax = 'json'
                Invariants = @(
                    'pull-request-body-identity-cases-preserve-required-coverage'
                )
            },
            [pscustomobject]@{
                Path = '.github/workflows/pull-request-body-identity.yml'
                Syntax = 'yaml'
                Invariants = @(
                    'pull-request-body-identity-workflow-topology-is-exact'
                )
            },
            [pscustomobject]@{
                Path = '.github/workflows/workflow-policy-cases.json'
                Syntax = 'json'
                Invariants = @('workflow-policy-identity-cases-are-exact')
            },
            [pscustomobject]@{
                Path = '.pre-commit-config.yaml'
                Syntax = 'yaml'
                Invariants = @('pre-commit-actionlint-gate-is-exact')
            },
            [pscustomobject]@{
                Path = '.github/workflows/Validate-WorkflowPolicy.mjs'
                Syntax = 'javascript'
                Invariants = @(
                    'workflow-policy-preflight-authenticates-deferred-yaml-import'
                )
            },
            [pscustomobject]@{
                Path = '.github/workflows/agent-instruction-current-base.yml'
                Syntax = 'yaml'
                Invariants = @(
                    'workflow-run-current-base-invalidator-is-fail-closed'
                )
            },
            [pscustomobject]@{
                Path = '.github/workflows/agent-instructions.yml'
                Syntax = 'yaml'
                Invariants = @(
                    'workflow-checkout-is-trusted-sha',
                    'workflow-created-push-history-fetch-is-bounded',
                    'workflow-current-base-finalizer-is-fail-closed',
                    'workflow-permissions-are-read-only',
                    'workflow-persist-credentials-is-false',
                    'workflow-uses-trusted-authorization-output'
                )
            },
            [pscustomobject]@{
                Path = '.github/workflows/workflow-policy-contract.json'
                Syntax = 'json'
                Invariants = @(
                    'workflow-policy-contract-identities-and-structure-are-exact'
                )
            },
            [pscustomobject]@{
                Path = 'package-lock.json'
                Syntax = 'json'
                Invariants = @('package-lock-parser-closure-is-exact')
            },
            [pscustomobject]@{
                Path = 'package.json'
                Syntax = 'json'
                Invariants = @('package-parser-roots-are-exact')
            }
        )
        $listSchemaAllowedPath =
            [Collections.Generic.List[Collections.Specialized.OrderedDictionary]]::new()
        foreach ($objSchemaPath in $arrSchemaPathSpec) {
            $strSchemaBaselinePath =
                Join-Path $strSchemaFixtureRoot $objSchemaPath.Path
            [void] [IO.Directory]::CreateDirectory(
                [IO.Path]::GetDirectoryName($strSchemaBaselinePath)
            )
            $strSchemaSourcePath =
                Join-Path $RepositoryRootPath $objSchemaPath.Path
            $arrSchemaBytes = [IO.File]::ReadAllBytes($strSchemaSourcePath)
            $strSchemaBlob = ([string] (& git -C $strSchemaFixtureRoot `
                        hash-object -w -- $strSchemaSourcePath)).Trim()
            if ($LASTEXITCODE -ne 0 -or
                $strSchemaBlob -cnotmatch $strObjectIdPattern) {
                throw 'Could not hash a schema 2 candidate fixture blob.'
            }
            $strSchemaSha256 = [Convert]::ToHexString(
                [Security.Cryptography.SHA256]::HashData($arrSchemaBytes)
            ).ToLowerInvariant()
            $listSchemaAllowedPath.Add([ordered]@{
                    path = $objSchemaPath.Path
                    mode = '100644'
                    blob = $strSchemaBlob
                    bytes = $arrSchemaBytes.Length
                    sha256 = $strSchemaSha256
                    encoding = 'utf-8-no-bom-lf'
                    syntax = $objSchemaPath.Syntax
                    semantic_invariants = @($objSchemaPath.Invariants)
                })
            if ($objSchemaPath.Path -cin @(
                    '.github/workflows/Validate-WorkflowPolicy.mjs',
                    '.github/workflows/workflow-policy-contract.json',
                    '.github/workflows/workflow-policy-cases.json',
                    '.github/workflows/pull-request-body-identity.yml'
                )) {
                [IO.File]::WriteAllBytes($strSchemaBaselinePath, $arrSchemaBytes)
            } else {
                [IO.File]::WriteAllText(
                    $strSchemaBaselinePath,
                    "baseline placeholder for $($objSchemaPath.Path)`n",
                    [Text.UTF8Encoding]::new($false)
                )
            }
        }
        $objSchemaManifest = [ordered]@{
            schema_version = 2
            authorization_id = 'self-test-content-exact'
            limits = [ordered]@{
                maximum_paths = 19
                maximum_blob_bytes = $intCandidateMaximumBlobBytes
                maximum_manifest_bytes = 65536
                maximum_commits = 64
            }
            allowed_paths = @($listSchemaAllowedPath)
        }
        $strSchemaManifestPath =
            Join-Path $strSchemaFixtureRoot $strAuthorizationPath
        [IO.File]::WriteAllText(
            $strSchemaManifestPath,
            ((ConvertTo-Json -InputObject $objSchemaManifest -Depth 8) `
                -replace "`r`n", "`n") + "`n",
            [Text.UTF8Encoding]::new($false)
        )
        & git -C $strSchemaFixtureRoot add -- .
        & git -C $strSchemaFixtureRoot `
            -c 'user.name=Trust root schema self-test' `
            -c 'user.email=trust-root-schema@example.invalid' `
            -c 'commit.gpgSign=false' `
            -c 'core.hooksPath=NUL' `
            commit --quiet --no-gpg-sign -m 'schema 2 trusted baseline'
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not commit the schema 2 trusted baseline.'
        }
        $strSchemaTrusted = ([string] (& git -C $strSchemaFixtureRoot `
                    rev-parse --verify 'HEAD^{commit}')).Trim()
        foreach ($objSchemaPath in $arrSchemaPathSpec) {
            $strSchemaCandidatePath =
                Join-Path $strSchemaFixtureRoot $objSchemaPath.Path
            [IO.File]::Copy(
                (Join-Path $RepositoryRootPath $objSchemaPath.Path),
                $strSchemaCandidatePath,
                $true
            )
        }
        & git -C $strSchemaFixtureRoot add -- .
        & git -C $strSchemaFixtureRoot `
            -c 'user.name=Trust root schema self-test' `
            -c 'user.email=trust-root-schema@example.invalid' `
            -c 'commit.gpgSign=false' `
            -c 'core.hooksPath=NUL' `
            commit --quiet --no-gpg-sign -m 'schema 2 valid candidate'
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not commit the schema 2 valid candidate.'
        }
        $strSchemaCandidate = ([string] (& git -C $strSchemaFixtureRoot `
                    rev-parse --verify 'HEAD^{commit}')).Trim()
        & git -C $strSchemaFixtureRoot switch --quiet --detach $strSchemaTrusted
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not restore the schema 2 trusted checkout.'
        }
        $arrSchemaAuthorizationResult = @(& $PSCommandPath `
                -RepositoryRootPath $strSchemaFixtureRoot `
                -TrustedRevision $strSchemaTrusted `
                -BaseRevision $strSchemaTrusted `
                -HeadRevision $strSchemaCandidate)
        if ($arrSchemaAuthorizationResult.Count -ne 1 -or
            $arrSchemaAuthorizationResult[0] -isnot [bool] -or
            -not $arrSchemaAuthorizationResult[0]) {
            throw 'A constructible content-exact schema 2 candidate was rejected.'
        }

        $scriptblockExpectSchemaRejection = {
            param(
                [Parameter()][string] $Trusted = $strSchemaTrusted,
                [Parameter(Mandatory)][string] $Base,
                [Parameter(Mandatory)][string] $Head,
                [Parameter(Mandatory)][string] $ExpectedMessage
            )
            try {
                [void] @(& $PSCommandPath `
                        -RepositoryRootPath $strSchemaFixtureRoot `
                        -TrustedRevision $Trusted `
                        -BaseRevision $Base -HeadRevision $Head)
                throw "Schema 2 mutation passed: $ExpectedMessage"
            } catch {
                if ($_.Exception.Message -ceq
                    "Schema 2 mutation passed: $ExpectedMessage" -or
                    -not $_.Exception.Message.Contains(
                        $ExpectedMessage,
                        [StringComparison]::Ordinal
                    )) {
                    throw
                }
            }
        }
        & $scriptblockExpectSchemaRejection -Base $strSchemaCandidate `
            -Head $strSchemaCandidate `
            -ExpectedMessage 'base must equal the trusted revision'

        $objOverLimitManifest = ConvertFrom-Json -InputObject (
            ConvertTo-Json -InputObject $objSchemaManifest -Depth 8
        )
        $objOverLimitManifest.authorization_id = 'self-test-path-limit-overflow'
        $objOverLimitManifest.limits.maximum_paths = 20
        [IO.File]::WriteAllText(
            $strSchemaManifestPath,
            ((ConvertTo-Json -InputObject $objOverLimitManifest -Depth 8) `
                -replace "`r`n", "`n") + "`n",
            [Text.UTF8Encoding]::new($false)
        )
        & git -C $strSchemaFixtureRoot add -- $strAuthorizationPath
        & git -C $strSchemaFixtureRoot `
            -c 'user.name=Trust root schema self-test' `
            -c 'user.email=trust-root-schema@example.invalid' `
            -c 'commit.gpgSign=false' `
            -c 'core.hooksPath=NUL' `
            commit --quiet --no-gpg-sign -m 'path limit overflow trusted base'
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not commit the path-limit overflow trusted base.'
        }
        $strOverLimitTrusted = ([string] (
                & git -C $strSchemaFixtureRoot rev-parse --verify 'HEAD^{commit}'
            )).Trim()
        foreach ($objSchemaPath in $arrSchemaPathSpec) {
            $strSchemaCandidatePath =
                Join-Path $strSchemaFixtureRoot $objSchemaPath.Path
            [IO.File]::Copy(
                (Join-Path $RepositoryRootPath $objSchemaPath.Path),
                $strSchemaCandidatePath,
                $true
            )
        }
        & git -C $strSchemaFixtureRoot add -- .
        & git -C $strSchemaFixtureRoot `
            -c 'user.name=Trust root schema self-test' `
            -c 'user.email=trust-root-schema@example.invalid' `
            -c 'commit.gpgSign=false' `
            -c 'core.hooksPath=NUL' `
            commit --quiet --no-gpg-sign -m 'path limit overflow candidate'
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not commit the path-limit overflow candidate.'
        }
        $strOverLimitHead = ([string] (
                & git -C $strSchemaFixtureRoot rev-parse --verify 'HEAD^{commit}'
            )).Trim()
        & git -C $strSchemaFixtureRoot switch --quiet --detach $strOverLimitTrusted
        & $scriptblockExpectSchemaRejection -Trusted $strOverLimitTrusted `
            -Base $strOverLimitTrusted -Head $strOverLimitHead `
            -ExpectedMessage 'authorization limits exceed the trusted verifier limits'
        & git -C $strSchemaFixtureRoot switch --quiet --detach $strSchemaTrusted
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not restore the trusted schema fixture after path-limit testing.'
        }

        foreach ($strStandaloneProtectedPath in @(
                '.github/actionlint.yaml',
                '.pre-commit-config.yaml'
            )) {
            & git -C $strSchemaFixtureRoot switch --quiet --detach `
                $strSchemaTrusted
            [IO.File]::Copy(
                (Join-Path $RepositoryRootPath $strStandaloneProtectedPath),
                (Join-Path $strSchemaFixtureRoot $strStandaloneProtectedPath),
                $true
            )
            & git -C $strSchemaFixtureRoot add -- $strStandaloneProtectedPath
            & git -C $strSchemaFixtureRoot `
                -c 'user.name=Trust root schema self-test' `
                -c 'user.email=trust-root-schema@example.invalid' `
                -c 'commit.gpgSign=false' `
                -c 'core.hooksPath=NUL' `
                commit --quiet --no-gpg-sign `
                -m "standalone protected path $strStandaloneProtectedPath"
            if ($LASTEXITCODE -ne 0) {
                throw 'Could not commit a standalone protected-path fixture.'
            }
            $strStandaloneProtectedHead = ([string] (
                    & git -C $strSchemaFixtureRoot rev-parse --verify `
                        'HEAD^{commit}'
                )).Trim()
            & git -C $strSchemaFixtureRoot switch --quiet --detach `
                $strSchemaTrusted
            $arrStandaloneApplicability = @(& $PSCommandPath `
                    -RepositoryRootPath $strSchemaFixtureRoot `
                    -TrustedRevision $strSchemaTrusted `
                    -BaseRevision $strSchemaTrusted `
                    -HeadRevision $strStandaloneProtectedHead `
                    -AuthorizationApplicabilityOnly)
            if ($arrStandaloneApplicability.Count -ne 1 -or
                $arrStandaloneApplicability[0] -isnot [bool] -or
                -not $arrStandaloneApplicability[0]) {
                throw (
                    'A standalone protected-path change bypassed ' +
                    "authorization applicability: $strStandaloneProtectedPath"
                )
            }
            & $scriptblockExpectSchemaRejection -Base $strSchemaTrusted `
                -Head $strStandaloneProtectedHead `
                -ExpectedMessage (
                    'missing, linked, deleted, or has a mismatched Git identity'
                )
        }

        & git -C $strSchemaFixtureRoot switch --quiet --detach $strSchemaCandidate
        [IO.File]::AppendAllText(
            $strSchemaManifestPath,
            " `n",
            [Text.UTF8Encoding]::new($false)
        )
        & git -C $strSchemaFixtureRoot add -- $strAuthorizationPath
        & git -C $strSchemaFixtureRoot `
            -c 'user.name=Trust root schema self-test' `
            -c 'user.email=trust-root-schema@example.invalid' `
            -c 'commit.gpgSign=false' `
            -c 'core.hooksPath=NUL' `
            commit --quiet --no-gpg-sign -m 'changed manifest mutation'
        $strChangedManifestHead = ([string] (& git -C $strSchemaFixtureRoot `
                    rev-parse --verify 'HEAD^{commit}')).Trim()
        & git -C $strSchemaFixtureRoot switch --quiet --detach $strSchemaTrusted
        & $scriptblockExpectSchemaRejection -Base $strSchemaTrusted `
            -Head $strChangedManifestHead `
            -ExpectedMessage (
                'contains unauthorized path ' + $strAuthorizationPath
            )

        & git -C $strSchemaFixtureRoot switch --quiet --detach $strSchemaCandidate
        $strUnexpectedPath = Join-Path $strSchemaFixtureRoot 'unexpected.txt'
        [IO.File]::WriteAllText(
            $strUnexpectedPath,
            "unexpected final path`n",
            [Text.UTF8Encoding]::new($false)
        )
        & git -C $strSchemaFixtureRoot add -- unexpected.txt
        & git -C $strSchemaFixtureRoot `
            -c 'user.name=Trust root schema self-test' `
            -c 'user.email=trust-root-schema@example.invalid' `
            -c 'commit.gpgSign=false' `
            -c 'core.hooksPath=NUL' `
            commit --quiet --no-gpg-sign -m 'changed path-set mutation'
        $strChangedPathSetHead = ([string] (& git -C $strSchemaFixtureRoot `
                    rev-parse --verify 'HEAD^{commit}')).Trim()
        & git -C $strSchemaFixtureRoot switch --quiet --detach $strSchemaTrusted
        & $scriptblockExpectSchemaRejection -Base $strSchemaTrusted `
            -Head $strChangedPathSetHead `
            -ExpectedMessage 'contains unauthorized path unexpected.txt'

        & git -C $strSchemaFixtureRoot switch --quiet --detach $strSchemaCandidate
        $strBadFinalPath = Join-Path $strSchemaFixtureRoot $arrSchemaPathSpec[0].Path
        [IO.File]::AppendAllText(
            $strBadFinalPath,
            "wrong final blob`n",
            [Text.UTF8Encoding]::new($false)
        )
        & git -C $strSchemaFixtureRoot add -- $arrSchemaPathSpec[0].Path
        & git -C $strSchemaFixtureRoot `
            -c 'user.name=Trust root schema self-test' `
            -c 'user.email=trust-root-schema@example.invalid' `
            -c 'commit.gpgSign=false' `
            -c 'core.hooksPath=NUL' `
            commit --quiet --no-gpg-sign -m 'wrong final blob mutation'
        $strBadFinalHead = ([string] (& git -C $strSchemaFixtureRoot `
                    rev-parse --verify 'HEAD^{commit}')).Trim()
        & git -C $strSchemaFixtureRoot switch --quiet --detach $strSchemaTrusted
        & $scriptblockExpectSchemaRejection -Base $strSchemaTrusted `
            -Head $strBadFinalHead `
            -ExpectedMessage 'mismatched Git identity'

        & git -C $strSchemaFixtureRoot switch --quiet --detach $strSchemaTrusted
        [IO.File]::WriteAllText(
            $strUnexpectedPath,
            "unexpected intermediate path`n",
            [Text.UTF8Encoding]::new($false)
        )
        & git -C $strSchemaFixtureRoot add -- unexpected.txt
        & git -C $strSchemaFixtureRoot `
            -c 'user.name=Trust root schema self-test' `
            -c 'user.email=trust-root-schema@example.invalid' `
            -c 'commit.gpgSign=false' `
            -c 'core.hooksPath=NUL' `
            commit --quiet --no-gpg-sign -m 'unexpected intermediate path'
        foreach ($objSchemaPath in $arrSchemaPathSpec) {
            $strSchemaCandidatePath =
                Join-Path $strSchemaFixtureRoot $objSchemaPath.Path
            [IO.File]::Copy(
                (Join-Path $RepositoryRootPath $objSchemaPath.Path),
                $strSchemaCandidatePath,
                $true
            )
        }
        Remove-Item -LiteralPath $strUnexpectedPath -Force
        & git -C $strSchemaFixtureRoot add -- .
        & git -C $strSchemaFixtureRoot `
            -c 'user.name=Trust root schema self-test' `
            -c 'user.email=trust-root-schema@example.invalid' `
            -c 'commit.gpgSign=false' `
            -c 'core.hooksPath=NUL' `
            commit --quiet --no-gpg-sign -m 'hidden intermediate path mutation'
        $strIntermediatePathHead = ([string] (& git -C $strSchemaFixtureRoot `
                    rev-parse --verify 'HEAD^{commit}')).Trim()
        & git -C $strSchemaFixtureRoot switch --quiet --detach $strSchemaTrusted
        & $scriptblockExpectSchemaRejection -Base $strSchemaTrusted `
            -Head $strIntermediatePathHead `
            -ExpectedMessage 'history contains unauthorized path'

        $strTransitionIndex = Join-Path $strSchemaFixtureRoot 'transition.index'
        $strOriginalIndexFile = [Environment]::GetEnvironmentVariable(
            'GIT_INDEX_FILE'
        )
        try {
            [Environment]::SetEnvironmentVariable(
                'GIT_INDEX_FILE',
                $strTransitionIndex
            )
            & git -C $strSchemaFixtureRoot read-tree --empty
            $strPlaceholderPath = Join-Path $strSchemaFixtureRoot 'placeholder'
            [IO.File]::WriteAllText(
                $strPlaceholderPath,
                "transition baseline placeholder`n",
                [Text.UTF8Encoding]::new($false)
            )
            $strPlaceholderBlob = ([string] (& git -C $strSchemaFixtureRoot `
                        hash-object -w -- $strPlaceholderPath)).Trim()
            foreach ($objSchemaPath in $arrSchemaPathSpec) {
                $strFixtureBaseBlob = $strPlaceholderBlob
                if ($objSchemaPath.Path -cin @(
                        '.github/workflows/Validate-WorkflowPolicy.mjs',
                        '.github/workflows/workflow-policy-contract.json',
                        '.github/workflows/workflow-policy-cases.json',
                        '.github/workflows/pull-request-body-identity.yml'
                    )) {
                    $strFixtureBaseBlob = [string](@($listSchemaAllowedPath |
                        Where-Object { $_.path -ceq $objSchemaPath.Path })[0].blob)
                }
                & git -C $strSchemaFixtureRoot update-index --add `
                    --cacheinfo "100644,$strFixtureBaseBlob,$($objSchemaPath.Path)"
            }
            $strTransitionBaseTree = ([string] (& git -C $strSchemaFixtureRoot `
                        write-tree)).Trim()
            $strTransitionBase = ([string] (
                    "transition base`n" | git -C $strSchemaFixtureRoot `
                        -c 'user.name=Trust root schema self-test' `
                        -c 'user.email=trust-root-schema@example.invalid' `
                        commit-tree $strTransitionBaseTree
                )).Trim()
            & git -C $strSchemaFixtureRoot read-tree $strTransitionBase
            foreach ($objSchemaPath in $listSchemaAllowedPath) {
                & git -C $strSchemaFixtureRoot update-index --add `
                    --cacheinfo "100644,$($objSchemaPath.blob),$($objSchemaPath.path)"
            }
            $strInactiveManifestSource =
                Join-Path $strSchemaFixtureRoot 'inactive-manifest.json'
            $objInactiveManifest = [ordered]@{
                schema_version = 2
                authorization_id = 'no-active-trust-root-maintenance'
                limits = [ordered]@{
                    maximum_paths = 16
                    maximum_blob_bytes = 573440
                    maximum_manifest_bytes = 65536
                    maximum_commits = 64
                }
                allowed_paths = @()
            }
            [IO.File]::WriteAllText(
                $strInactiveManifestSource,
                ((ConvertTo-Json -InputObject $objInactiveManifest -Depth 4) `
                    -replace "`r`n", "`n") + "`n",
                [Text.UTF8Encoding]::new($false)
            )
            $arrInactiveManifestBytes =
                [IO.File]::ReadAllBytes($strInactiveManifestSource)
            $strInactiveManifestBlob = ([string] (
                    & git -C $strSchemaFixtureRoot hash-object -w -- `
                        $strInactiveManifestSource
                )).Trim()
            & git -C $strSchemaFixtureRoot update-index --add `
                --cacheinfo `
                "100644,$strInactiveManifestBlob,$strAuthorizationPath"
            $strTransitionCandidateTree = ([string] (
                    & git -C $strSchemaFixtureRoot write-tree
                )).Trim()
            $strTransitionCandidate = ([string] (
                    "transition candidate`n" | git -C $strSchemaFixtureRoot `
                        -c 'user.name=Trust root schema self-test' `
                        -c 'user.email=trust-root-schema@example.invalid' `
                        commit-tree $strTransitionCandidateTree `
                        -p $strTransitionBase
                )).Trim()
            $strInactiveManifestSha256 = [Convert]::ToHexString(
                [Security.Cryptography.SHA256]::HashData(
                    $arrInactiveManifestBytes
                )
            ).ToLowerInvariant()
            $arrTransitionAllowedPath = @($listSchemaAllowedPath) + @(
                [ordered]@{
                    path = $strAuthorizationPath
                    mode = '100644'
                    blob = $strInactiveManifestBlob
                    bytes = $arrInactiveManifestBytes.Length
                    sha256 = $strInactiveManifestSha256
                    encoding = 'utf-8-no-bom-lf'
                    syntax = 'json'
                    semantic_invariants = @()
                }
            )
            $objTransitionManifest = [ordered]@{
                schema_version = 1
                authorization_id = 'self-test-detached-transition'
                candidate = [ordered]@{
                    base_commit = $strTransitionBase
                    head_commit = $strTransitionCandidate
                    head_tree = $strTransitionCandidateTree
                    parent_commits = @($strTransitionBase)
                }
                limits = [ordered]@{
                    maximum_paths = 19
                    maximum_blob_bytes = $intCandidateMaximumBlobBytes
                    maximum_manifest_bytes = 65536
                }
                allowed_paths = $arrTransitionAllowedPath
            }
            $strTransitionManifestFile =
                Join-Path $strSchemaFixtureRoot 'transition-manifest.json'
            [IO.File]::WriteAllText(
                $strTransitionManifestFile,
                ((ConvertTo-Json -InputObject $objTransitionManifest -Depth 8) `
                    -replace "`r`n", "`n") + "`n",
                [Text.UTF8Encoding]::new($false)
            )
            $strTransitionManifestBlob = ([string] (
                    & git -C $strSchemaFixtureRoot hash-object -w -- `
                        $strTransitionManifestFile
                )).Trim()
            & git -C $strSchemaFixtureRoot read-tree --empty
            $objVerifierEntry = @($listSchemaAllowedPath | Where-Object {
                    $_.path -ceq $strVerifierPath
                })[0]
            & git -C $strSchemaFixtureRoot update-index --add `
                --cacheinfo "100644,$($objVerifierEntry.blob),$strVerifierPath"
            & git -C $strSchemaFixtureRoot update-index --add `
                --cacheinfo `
                "100644,$strTransitionManifestBlob,$strAuthorizationPath"
            foreach ($objReferenceEntry in @($listSchemaAllowedPath | Where-Object {
                        $_.path -cin @(
                            '.github/workflows/Validate-WorkflowPolicy.mjs',
                            '.github/workflows/workflow-policy-contract.json',
                            '.github/workflows/workflow-policy-cases.json',
                            '.github/workflows/pull-request-body-identity.yml'
                        )
                    })) {
                & git -C $strSchemaFixtureRoot update-index --add `
                    --cacheinfo "100644,$($objReferenceEntry.blob),$($objReferenceEntry.path)"
                if ($LASTEXITCODE -ne 0) {
                    throw 'Could not bind the detached trusted policy references.'
                }
            }
            $strTransitionTrustedTree = ([string] (
                    & git -C $strSchemaFixtureRoot write-tree
                )).Trim()
            $strTransitionTrusted = ([string] (
                    "transition trusted root`n" | git -C $strSchemaFixtureRoot `
                        -c 'user.name=Trust root schema self-test' `
                        -c 'user.email=trust-root-schema@example.invalid' `
                        commit-tree $strTransitionTrustedTree
                )).Trim()
        } finally {
            if ([string]::IsNullOrEmpty($strOriginalIndexFile)) {
                Remove-Item -LiteralPath 'Env:GIT_INDEX_FILE' `
                    -ErrorAction SilentlyContinue
            } else {
                [Environment]::SetEnvironmentVariable(
                    'GIT_INDEX_FILE',
                    $strOriginalIndexFile
                )
            }
        }
        & git -C $strSchemaFixtureRoot update-ref --no-deref HEAD `
            $strTransitionTrusted
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not select the detached transition trust root.'
        }
        $arrTransitionResult = @(& $PSCommandPath `
                -RepositoryRootPath $strSchemaFixtureRoot `
                -TrustedRevision $strTransitionTrusted `
                -BaseRevision $strTransitionBase `
                -HeadRevision $strTransitionCandidate)
        if ($arrTransitionResult.Count -ne 1 -or
            $arrTransitionResult[0] -isnot [bool] -or
            -not $arrTransitionResult[0]) {
            throw 'The bounded detached-base schema 1 transition was rejected.'
        }
        try {
            [void] @(& $PSCommandPath `
                    -RepositoryRootPath $strSchemaFixtureRoot `
                    -TrustedRevision $strTransitionTrusted `
                    -BaseRevision $strTransitionTrusted `
                    -HeadRevision $strTransitionCandidate)
            throw 'A same-base schema 1 authorization was accepted.'
        } catch {
            if ($_.Exception.Message -ceq
                'A same-base schema 1 authorization was accepted.' -or
                -not $_.Exception.Message.Contains(
                    'Schema 1 is valid only for the detached-base transition',
                    [StringComparison]::Ordinal
                )) {
                throw
            }
        }

        $objSameBaseTransitionManifest = [ordered]@{
            schema_version = 2
            authorization_id = 'self-test-same-base-deactivation'
            limits = [ordered]@{
                maximum_paths = 19
                maximum_blob_bytes = $intCandidateMaximumBlobBytes
                maximum_manifest_bytes = 65536
                maximum_commits = 64
            }
            allowed_paths = $arrTransitionAllowedPath
        }
        $strSameBaseTransitionManifestFile = Join-Path `
            $strSchemaFixtureRoot 'same-base-transition-manifest.json'
        [IO.File]::WriteAllText(
            $strSameBaseTransitionManifestFile,
            ((ConvertTo-Json `
                    -InputObject $objSameBaseTransitionManifest -Depth 8) `
                -replace "`r`n", "`n") + "`n",
            [Text.UTF8Encoding]::new($false)
        )
        $strSameBaseTransitionManifestBlob = ([string] (
                & git -C $strSchemaFixtureRoot hash-object -w -- `
                    $strSameBaseTransitionManifestFile
            )).Trim()
        $strSameBaseIndex = Join-Path `
            $strSchemaFixtureRoot 'same-base-transition.index'
        $strOriginalIndexFile = [Environment]::GetEnvironmentVariable(
            'GIT_INDEX_FILE'
        )
        try {
            [Environment]::SetEnvironmentVariable(
                'GIT_INDEX_FILE',
                $strSameBaseIndex
            )
            & git -C $strSchemaFixtureRoot read-tree $strTransitionBaseTree
            $objUnchangedAuthorizedPath = @($listSchemaAllowedPath |
                    Where-Object {
                        $_.path -ceq '.github/actionlint.yaml'
                    })[0]
            & git -C $strSchemaFixtureRoot update-index --add `
                --cacheinfo `
                "100644,$($objUnchangedAuthorizedPath.blob),$($objUnchangedAuthorizedPath.path)"
            & git -C $strSchemaFixtureRoot update-index --add `
                --cacheinfo `
                "100644,$strSameBaseTransitionManifestBlob,$strAuthorizationPath"
            $strSameBaseTrustedTree = ([string] (
                    & git -C $strSchemaFixtureRoot write-tree
                )).Trim()
            $strSameBaseTrusted = ([string] (
                    "same-base schema 2 trusted root`n" | `
                        git -C $strSchemaFixtureRoot `
                            -c 'user.name=Trust root schema self-test' `
                            -c 'user.email=trust-root-schema@example.invalid' `
                            commit-tree $strSameBaseTrustedTree
                )).Trim()
            $strSameBaseCandidate = ([string] (
                    "same-base schema 2 candidate`n" | `
                        git -C $strSchemaFixtureRoot `
                            -c 'user.name=Trust root schema self-test' `
                            -c 'user.email=trust-root-schema@example.invalid' `
                            commit-tree $strTransitionCandidateTree `
                            -p $strSameBaseTrusted
                )).Trim()
            $strBadInactiveManifestFile = Join-Path `
                $strSchemaFixtureRoot 'bad-inactive-manifest.json'
            [IO.File]::WriteAllText(
                $strBadInactiveManifestFile,
                '{"schema_version":2,"authorization_id":' +
                    '"not-the-canonical-inactive-manifest","limits":{' +
                    '"maximum_paths":16,"maximum_blob_bytes":573440,' +
                    '"maximum_manifest_bytes":65536,"maximum_commits":64},' +
                    '"allowed_paths":[]}' + "`n",
                [Text.UTF8Encoding]::new($false)
            )
            $strBadInactiveManifestBlob = ([string] (
                    & git -C $strSchemaFixtureRoot hash-object -w -- `
                        $strBadInactiveManifestFile
                )).Trim()
            & git -C $strSchemaFixtureRoot read-tree $strTransitionCandidateTree
            & git -C $strSchemaFixtureRoot update-index --add `
                --cacheinfo `
                "100644,$strBadInactiveManifestBlob,$strAuthorizationPath"
            $strBadInactiveCandidateTree = ([string] (
                    & git -C $strSchemaFixtureRoot write-tree
                )).Trim()
            $strBadInactiveCandidate = ([string] (
                    "wrong same-base inactive manifest`n" | `
                        git -C $strSchemaFixtureRoot `
                            -c 'user.name=Trust root schema self-test' `
                            -c 'user.email=trust-root-schema@example.invalid' `
                            commit-tree $strBadInactiveCandidateTree `
                            -p $strSameBaseTrusted
                )).Trim()
        } finally {
            if ([string]::IsNullOrEmpty($strOriginalIndexFile)) {
                Remove-Item -LiteralPath 'Env:GIT_INDEX_FILE' `
                    -ErrorAction SilentlyContinue
            } else {
                [Environment]::SetEnvironmentVariable(
                    'GIT_INDEX_FILE',
                    $strOriginalIndexFile
                )
            }
        }
        & git -C $strSchemaFixtureRoot update-ref --no-deref HEAD `
            $strSameBaseTrusted
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not select the same-base schema 2 trust root.'
        }
        $arrSameBaseTransitionResult = @(& $PSCommandPath `
                -RepositoryRootPath $strSchemaFixtureRoot `
                -TrustedRevision $strSameBaseTrusted `
                -BaseRevision $strSameBaseTrusted `
                -HeadRevision $strSameBaseCandidate)
        if ($arrSameBaseTransitionResult.Count -ne 1 -or
            $arrSameBaseTransitionResult[0] -isnot [bool] -or
            -not $arrSameBaseTransitionResult[0]) {
            throw 'The content-exact same-base schema 2 deactivation was rejected.'
        }
        & $scriptblockExpectSchemaRejection -Trusted $strSameBaseTrusted `
            -Base $strSameBaseTrusted `
            -Head $strBadInactiveCandidate `
            -ExpectedMessage 'mismatched Git identity'

        $arrNoncanonicalTransitionAllowedPath = @($listSchemaAllowedPath) + @(
            [ordered]@{
                path = $strAuthorizationPath
                mode = '100644'
                blob = $strBadInactiveManifestBlob
                bytes = ([IO.File]::ReadAllBytes(
                        $strBadInactiveManifestFile
                    )).Length
                sha256 = [Convert]::ToHexString(
                    [Security.Cryptography.SHA256]::HashData(
                        [IO.File]::ReadAllBytes($strBadInactiveManifestFile)
                    )
                ).ToLowerInvariant()
                encoding = 'utf-8-no-bom-lf'
                syntax = 'json'
                semantic_invariants = @()
            }
        )
        $objNoncanonicalTransitionManifest = [ordered]@{
            schema_version = 2
            authorization_id = 'self-test-noncanonical-deactivation-target'
            limits = [ordered]@{
                maximum_paths = 19
                maximum_blob_bytes = $intCandidateMaximumBlobBytes
                maximum_manifest_bytes = 65536
                maximum_commits = 64
            }
            allowed_paths = $arrNoncanonicalTransitionAllowedPath
        }
        $strNoncanonicalTransitionManifestFile = Join-Path `
            $strSchemaFixtureRoot 'noncanonical-transition-manifest.json'
        [IO.File]::WriteAllText(
            $strNoncanonicalTransitionManifestFile,
            ((ConvertTo-Json `
                    -InputObject $objNoncanonicalTransitionManifest -Depth 8) `
                -replace "`r`n", "`n") + "`n",
            [Text.UTF8Encoding]::new($false)
        )
        $strNoncanonicalTransitionManifestBlob = ([string] (
                & git -C $strSchemaFixtureRoot hash-object -w -- `
                    $strNoncanonicalTransitionManifestFile
            )).Trim()
        $strNoncanonicalIndex = Join-Path `
            $strSchemaFixtureRoot 'noncanonical-transition.index'
        $strOriginalIndexFile = [Environment]::GetEnvironmentVariable(
            'GIT_INDEX_FILE'
        )
        try {
            [Environment]::SetEnvironmentVariable(
                'GIT_INDEX_FILE',
                $strNoncanonicalIndex
            )
            & git -C $strSchemaFixtureRoot read-tree $strTransitionBaseTree
            & git -C $strSchemaFixtureRoot update-index --add `
                --cacheinfo `
                "100644,$strNoncanonicalTransitionManifestBlob,$strAuthorizationPath"
            $strNoncanonicalTrustedTree = ([string] (
                    & git -C $strSchemaFixtureRoot write-tree
                )).Trim()
            $strNoncanonicalTrusted = ([string] (
                    "noncanonical schema 2 trusted root`n" | `
                        git -C $strSchemaFixtureRoot `
                            -c 'user.name=Trust root schema self-test' `
                            -c 'user.email=trust-root-schema@example.invalid' `
                            commit-tree $strNoncanonicalTrustedTree
                )).Trim()
            & git -C $strSchemaFixtureRoot read-tree $strTransitionCandidateTree
            & git -C $strSchemaFixtureRoot update-index --add `
                --cacheinfo `
                "100644,$strBadInactiveManifestBlob,$strAuthorizationPath"
            $strNoncanonicalCandidateTree = ([string] (
                    & git -C $strSchemaFixtureRoot write-tree
                )).Trim()
            $strNoncanonicalCandidate = ([string] (
                    "noncanonical schema 2 candidate`n" | `
                        git -C $strSchemaFixtureRoot `
                            -c 'user.name=Trust root schema self-test' `
                            -c 'user.email=trust-root-schema@example.invalid' `
                            commit-tree $strNoncanonicalCandidateTree `
                            -p $strNoncanonicalTrusted
                )).Trim()
        } finally {
            if ([string]::IsNullOrEmpty($strOriginalIndexFile)) {
                Remove-Item -LiteralPath 'Env:GIT_INDEX_FILE' `
                    -ErrorAction SilentlyContinue
            } else {
                [Environment]::SetEnvironmentVariable(
                    'GIT_INDEX_FILE',
                    $strOriginalIndexFile
                )
            }
        }
        & git -C $strSchemaFixtureRoot update-ref --no-deref HEAD `
            $strNoncanonicalTrusted
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not select the noncanonical schema 2 trust root.'
        }
        & $scriptblockExpectSchemaRejection -Trusted $strNoncanonicalTrusted `
            -Base $strNoncanonicalTrusted `
            -Head $strNoncanonicalCandidate `
            -ExpectedMessage 'does not land the exact inactive schema 2 manifest'

        # Run only the trusted checkout's CLI. Candidate catalogs stay inert.
        # This separate deadline does not reduce the Git builder's time budget.
        # Historical invariant/transition fixtures are complete. Live CLI
        # probes below must use the installed product, not the old fixture.
        $script:dictionaryPolicyReferenceText.Clear()
        $strOrdinaryCliProbe = @'
import fs from 'node:fs';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
const source = process.argv[1];
const diagnosticControl = process.argv[2] ?? '';
const selectedRow = process.argv[3] ?? '0';
const replayMode = process.argv[4];
function rejectCapture(kind) {
  process.stdout.write('ordinary-cli-capture-rejected kind=' + kind);
  process.exit(1);
}
if (!/^[0-2]$/.test(selectedRow)) throw new Error('Invalid fixed CLI row selector');
if (diagnosticControl === 'capture' && (selectedRow !== '0' || replayMode !== undefined)) {
  rejectCapture('request');
}
let captured;
if (replayMode !== undefined) {
  if (replayMode !== 'replay' || selectedRow !== '0'
    || !['none', 'malformed', 'null', 'array'].includes(diagnosticControl)) {
    rejectCapture('request');
  }
  const bytes = Buffer.alloc(65537);
  let length = 0;
  while (length < bytes.length) {
    const count = fs.readSync(0, bytes, length, bytes.length - length, null);
    if (count === 0) break;
    length += count;
  }
  if (length > 65536) rejectCapture('limit');
  let capturedText;
  try { capturedText = new TextDecoder('utf-8', { fatal: true }).decode(bytes.subarray(0, length)); }
  catch { rejectCapture('encoding'); }
  try { captured = JSON.parse(capturedText); } catch { rejectCapture('json'); }
  if (captured === null || typeof captured !== 'object' || Array.isArray(captured)
    || Object.keys(captured).sort().join(',') !== 'status,stdout' || captured.status !== 0
    || typeof captured.stdout !== 'string' || Buffer.byteLength(captured.stdout) > 65536) {
    rejectCapture('shape');
  }
}
const directory = path.join(source, '.github/workflows');
const catalog = JSON.parse(fs.readFileSync(path.join(directory, 'workflow-policy-cases.json'), 'utf8'));
const next = Math.max(...catalog.cases.filter(item => item.id.startsWith('PS-P1-WFPOL-'))
  .map(item => Number(item.id.slice(-3)))) + 1;
const rows = [{ catalog, status: 0 }];
for (const operation of [
  { type: 'replace', path: '/name', from: 'THIS_NEEDLE_IS_ABSENT', to: 'changed' },
  { type: 'append', path: '/name', value: 'extra' },
]) {
  rows.push({ catalog: { ...catalog, cases: [...catalog.cases, {
    id: `PS-P1-WFPOL-${String(next).padStart(3, '0')}`,
    semanticKey: 'ordinary-cli-preparation-self-test', domain: 'workflow',
    workflow: 'build.yml', operation, expected: false,
  }] }, status: 1 });
}
function fail(kind, index, row, child, category) {
  const status = Number.isInteger(child.status) && child.status >= 0 && child.status <= 255
    ? String(child.status) : child.status == null ? 'NONE' : 'OTHER';
  const signal = ['SIGABRT', 'SIGALRM', 'SIGHUP', 'SIGINT', 'SIGKILL', 'SIGQUIT', 'SIGTERM']
    .includes(child.signal) ? child.signal : child.signal == null ? 'NONE' : 'OTHER';
  const errorCode = ['EACCES', 'EAGAIN', 'EMFILE', 'ENFILE', 'ENOENT', 'ENOBUFS', 'ENOMEM',
    'ETIMEDOUT'].includes(child.error?.code) ? child.error.code
    : child.error?.code == null ? 'NONE' : 'OTHER';
  const safeCategory = ['case-catalog', 'case-catalog-identity', 'case-operation', 'case-result', 'case-file',
    'ordinary-case-prefix', 'ordinary-case-self-test', 'ordinary-case-shape', 'tool-failure']
    .includes(category) ? category : category == null ? 'NONE' : 'OTHER';
  fs.writeSync(1, `ordinary-cli-preparation-failed kind=${kind} row=${index} `
    + `expected-status=${row.status} actual-status=${status} category=${safeCategory} `
    + `signal=${signal} error-code=${errorCode}`);
  process.exit(1);
}
for (const [index, row] of rows.entries()) {
  if (index !== Number(selectedRow)) continue;
  const input = Buffer.from(JSON.stringify(row.catalog));
  const expectedCategory = input.length > 524288 ? 'case-file' : 'case-operation';
  const deadline = Date.now() + 55000;
  const child = captured ?? spawnSync(process.execPath,
    [path.join(directory, 'Validate-WorkflowPolicy.mjs'), '--ordinary-case-catalog-data'], {
      input, encoding: 'utf8',
      timeout: 55000, maxBuffer: 65536, windowsHide: true,
    });
  if (child.error || child.signal || child.status !== row.status) {
    let category;
    try { ({ category } = JSON.parse(child.stdout)); } catch {}
    fail('process', index, row, child, category);
  }
  if (diagnosticControl === 'malformed') child.stdout = '{';
  if (diagnosticControl === 'null') child.stdout = 'null';
  if (diagnosticControl === 'array') child.stdout = '[]';
  let result;
  try { result = JSON.parse(child.stdout); } catch {
    fail('result-json', index, row, child);
  }
  if (result === null || typeof result !== 'object' || Array.isArray(result)) {
    fail('result-shape', index, row, child);
  }
  if (row.status === 0
    ? result.success !== true || result.casesPassed !== catalog.cases.length || result.mergeApproval !== false
    : result.success !== false || result.category !== expectedCategory) {
    fail('result', index, row, child, result.category);
  }
  if (diagnosticControl === 'capture') {
    const record = JSON.stringify({ status: child.status, stdout: child.stdout });
    if (Buffer.byteLength(record) > 65536) throw new Error('Native baseline capture exceeds its limit');
    process.stdout.write(record);
    process.exit(0);
  }
  // At the transport maximum, a larger probe cannot reach preparation. Run
  // the installed validator's direct object preparation tests instead. Row1
  // covers both overflow probes once; the parent always runs all three rows.
  if (index === 1 && rows.slice(1).some(item => Buffer.byteLength(JSON.stringify(item.catalog)) > 524288)) {
    const remaining = deadline - Date.now();
    if (remaining <= 0) fail('process', index, { status: 0 }, { error: { code: 'ETIMEDOUT' } });
    const full = spawnSync(process.execPath,
      [path.join(directory, 'Validate-WorkflowPolicy.mjs'), 'build.yml', 'markdownlint.yml'], {
        cwd: directory, encoding: 'utf8', timeout: remaining, maxBuffer: 65536, windowsHide: true,
      });
    if (full.error || full.signal || full.status !== 0) fail('process', index, { status: 0 }, full);
    let fullResult;
    try { fullResult = JSON.parse(full.stdout); } catch { fail('result-json', index, { status: 0 }, full); }
    if (fullResult === null || typeof fullResult !== 'object' || Array.isArray(fullResult)) {
      fail('result-shape', index, { status: 0 }, full);
    }
    if (fullResult.schema !== 'PSStyleGuide.WorkflowPolicyResult.v1' || fullResult.success !== true
      || fullResult.casesPassed !== catalog.cases.length || fullResult.generatorSourceMutationsPassed !== 4) {
      fail('result', index, { status: 0 }, full, fullResult.category);
    }
  }
}
process.stdout.write('ordinary-cli-preparation-passed');
'@
        $scriptBlockGetOrdinaryCliFailure = {
            param([Parameter(Mandatory)][pscustomobject] $Result)

            $strText = ConvertFrom-StrictUtf8Text -Bytes $Result.Bytes `
                -Name 'The ordinary CLI preparation result'
            if ($Result.ExitCode -eq 0) {
                if ([string]::Equals(
                        $strText,
                        'ordinary-cli-preparation-passed',
                        [StringComparison]::Ordinal
                    )) {
                    return ''
                }
            } elseif ($strText -cmatch (
                    '^ordinary-cli-preparation-failed ' +
                    'kind=(process|result-json|result-shape|result) row=[0-2] ' +
                    'expected-status=[012] actual-status=(NONE|OTHER|[0-9]{1,3}) ' +
                    'category=(NONE|OTHER|case-catalog|case-catalog-identity|' +
                    'case-operation|case-result|case-file|ordinary-case-prefix|' +
                    'ordinary-case-self-test|ordinary-case-shape|tool-failure) ' +
                    'signal=(NONE|OTHER|SIGABRT|SIGALRM|SIGHUP|SIGINT|SIGKILL|' +
                    'SIGQUIT|SIGTERM) error-code=(NONE|OTHER|EACCES|EAGAIN|' +
                    'EMFILE|ENFILE|ENOENT|ENOBUFS|ENOMEM|ETIMEDOUT)$'
                )) {
                return "The ordinary CLI preparation self-test failed: $strText."
            }
            return 'The ordinary CLI preparation self-test failed without a valid diagnostic.'
        }
        # Capture one real baseline result. Diagnostic replays test the same
        # checker without repeating the full catalog or claiming a new run.
        $objOrdinaryCliBaseline = Invoke-BoundedProcessByte -FileName 'node' `
            -ArgumentList @('--input-type=module', '-e', $strOrdinaryCliProbe,
                $RepositoryRootPath, 'capture', '0') `
            -MaximumBytes 65536 -TimeoutMilliseconds 60000
        if ($objOrdinaryCliBaseline.ExitCode -ne 0) {
            throw (& $scriptBlockGetOrdinaryCliFailure -Result $objOrdinaryCliBaseline)
        }
        $scriptblockAssertCliReplay = {
            param(
                [byte[]] $Bytes,
                [int] $ExpectedExit,
                [string] $ExpectedText,
                [string] $Control = 'none',
                [string] $Row = '0',
                [string] $Mode = 'replay'
            )
            $objReplay = Invoke-BoundedProcessByte -FileName 'node' `
                -ArgumentList @('--input-type=module', '-e', $strOrdinaryCliProbe,
                    $RepositoryRootPath, $Control, $Row, $Mode) `
                -InputBytes $Bytes -MaximumBytes 65536 -TimeoutMilliseconds 60000
            $strReplay = ConvertFrom-StrictUtf8Text -Bytes $objReplay.Bytes `
                -Name 'The CLI replay boundary result'
            if ($objReplay.ExitCode -ne $ExpectedExit -or $strReplay -cne $ExpectedText) {
                throw 'A CLI replay boundary or result assertion failed.'
            }
        }
        & $scriptblockAssertCliReplay -Bytes $objOrdinaryCliBaseline.Bytes `
            -ExpectedExit 0 -ExpectedText 'ordinary-cli-preparation-passed'
        $arrMaximumCapture = [byte[]]::new(65536)
        for ($intCaptureByte = 0; $intCaptureByte -lt $arrMaximumCapture.Length; $intCaptureByte++) {
            $arrMaximumCapture[$intCaptureByte] = 32
        }
        [Array]::Copy($objOrdinaryCliBaseline.Bytes, $arrMaximumCapture,
            $objOrdinaryCliBaseline.Bytes.Length)
        & $scriptblockAssertCliReplay -Bytes $arrMaximumCapture `
            -ExpectedExit 0 -ExpectedText 'ordinary-cli-preparation-passed'
        & $scriptblockAssertCliReplay -Bytes ([byte[]]($arrMaximumCapture + 32)) `
            -ExpectedExit 1 -ExpectedText 'ordinary-cli-capture-rejected kind=limit'
        & $scriptblockAssertCliReplay -Bytes ([byte[]]@(0xC3, 0x28)) `
            -ExpectedExit 1 -ExpectedText 'ordinary-cli-capture-rejected kind=encoding'
        & $scriptblockAssertCliReplay -Bytes ([Text.Encoding]::UTF8.GetBytes('{')) `
            -ExpectedExit 1 -ExpectedText 'ordinary-cli-capture-rejected kind=json'
        foreach ($strInvalidCapture in @(
                'null', '[]', '{}', '{"status":1,"stdout":""}',
                '{"status":"0","stdout":""}', '{"status":0,"stdout":5}',
                '{"status":0,"stdout":"","extra":true}'
            )) {
            & $scriptblockAssertCliReplay `
                -Bytes ([Text.Encoding]::UTF8.GetBytes($strInvalidCapture)) `
                -ExpectedExit 1 -ExpectedText 'ordinary-cli-capture-rejected kind=shape'
        }
        foreach ($hashtableInvalidReplay in @(
                @{ Control = 'unknown' }, @{ Row = '1' },
                @{ Control = 'capture' }, @{ Mode = 'unknown' }
            )) {
            & $scriptblockAssertCliReplay -Bytes $objOrdinaryCliBaseline.Bytes `
                -ExpectedExit 1 -ExpectedText 'ordinary-cli-capture-rejected kind=request' `
                @hashtableInvalidReplay
        }
        $strCapturedBaseline = ConvertFrom-StrictUtf8Text `
            -Bytes $objOrdinaryCliBaseline.Bytes -Name 'The captured CLI baseline'
        foreach ($strFalseResponse in @(
                '{"success":false,"casesPassed":0,"mergeApproval":false}',
                '{"success":true,"casesPassed":0,"mergeApproval":false}',
                '{"success":true,"casesPassed":0,"mergeApproval":true}'
            )) {
            $objFalseCapture = $strCapturedBaseline | ConvertFrom-Json
            $objNativeResponse = $objFalseCapture.stdout | ConvertFrom-Json
            $objFalseResponse = $strFalseResponse | ConvertFrom-Json
            if ($objFalseResponse.mergeApproval) {
                $objFalseResponse.casesPassed = $objNativeResponse.casesPassed
            } elseif (-not $objFalseResponse.success) {
                $objFalseResponse.casesPassed = $objNativeResponse.casesPassed
            }
            $objFalseCapture.stdout = ConvertTo-Json -InputObject $objFalseResponse -Compress
            $strFalseCapture = ConvertTo-Json -InputObject $objFalseCapture -Compress
            & $scriptblockAssertCliReplay `
                -Bytes ([Text.Encoding]::UTF8.GetBytes($strFalseCapture)) `
                -ExpectedExit 1 -ExpectedText (
                    'ordinary-cli-preparation-failed kind=result row=0 ' +
                    'expected-status=0 actual-status=0 category=NONE signal=NONE error-code=NONE'
                )
        }
        $strOrdinaryCliFailureProbe = $strOrdinaryCliProbe.Replace(
            'const rows = [{ catalog, status: 0 }];',
            'const rows = [{ catalog, status: 2 }];'
        )
        if ($strOrdinaryCliFailureProbe -ceq $strOrdinaryCliProbe) {
            throw 'The ordinary CLI diagnostic mutation changed zero bytes.'
        }
        $objOrdinaryCliFailureProbe = Invoke-BoundedProcessByte -FileName 'node' `
            -ArgumentList @('--input-type=module', '-e',
                $strOrdinaryCliFailureProbe, $RepositoryRootPath, 'none', '0',
                'replay') -InputBytes $objOrdinaryCliBaseline.Bytes `
            -MaximumBytes 65536 -TimeoutMilliseconds 60000
        $strOrdinaryCliFailure = & $scriptBlockGetOrdinaryCliFailure `
            -Result $objOrdinaryCliFailureProbe
        $strExpectedOrdinaryCliFailure =
            'The ordinary CLI preparation self-test failed: ' +
            'ordinary-cli-preparation-failed kind=process row=0 ' +
            'expected-status=2 actual-status=0 category=NONE signal=NONE ' +
            'error-code=NONE.'
        if ($strOrdinaryCliFailure -cne $strExpectedOrdinaryCliFailure) {
            throw 'The ordinary CLI diagnostic mutation was not propagated.'
        }
        foreach ($objOrdinaryCliResultControl in @(
                [pscustomobject]@{
                    Value = 'malformed'
                    Kind = 'result-json'
                },
                [pscustomobject]@{
                    Value = 'null'
                    Kind = 'result-shape'
                },
                [pscustomobject]@{
                    Value = 'array'
                    Kind = 'result-shape'
                }
            )) {
            $objOrdinaryCliFailureProbe = Invoke-BoundedProcessByte `
                -FileName 'node' -ArgumentList @('--input-type=module', '-e',
                    $strOrdinaryCliProbe, $RepositoryRootPath,
                    $objOrdinaryCliResultControl.Value, '0',
                    'replay') -InputBytes $objOrdinaryCliBaseline.Bytes `
                -MaximumBytes 65536 -TimeoutMilliseconds 60000
            $strOrdinaryCliFailure = & $scriptBlockGetOrdinaryCliFailure `
                -Result $objOrdinaryCliFailureProbe
            $strExpectedOrdinaryCliFailure =
                'The ordinary CLI preparation self-test failed: ' +
                'ordinary-cli-preparation-failed kind=' +
                $objOrdinaryCliResultControl.Kind + ' row=0 expected-status=0 ' +
                'actual-status=0 category=NONE signal=NONE error-code=NONE.'
            if ($strOrdinaryCliFailure -cne $strExpectedOrdinaryCliFailure) {
                throw 'An ordinary CLI result diagnostic was not propagated.'
            }
        }
        foreach ($strOrdinaryCliRow in @('1', '2')) {
            $objOrdinaryCliProbe = Invoke-BoundedProcessByte -FileName 'node' `
                -ArgumentList @('--input-type=module', '-e', $strOrdinaryCliProbe,
                    $RepositoryRootPath, 'none', $strOrdinaryCliRow) `
                -MaximumBytes 65536 -TimeoutMilliseconds 60000
            $strOrdinaryCliFailure = & $scriptBlockGetOrdinaryCliFailure `
                -Result $objOrdinaryCliProbe
            if (-not [string]::IsNullOrEmpty($strOrdinaryCliFailure)) {
                throw $strOrdinaryCliFailure
            }
        }

        # The builder makes inert Git objects. It does not run candidate code.
        $strOrdinaryFixtureBuilder = @'
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';
const [repo, source] = process.argv.slice(1);
const git = (args, input) => execFileSync('git', ['-C', repo, ...args], {
  input, encoding: 'utf8', windowsHide: true,
  env: { ...process.env, GIT_INDEX_FILE: path.join(repo, 'ordinary.index') },
  stdio: ['pipe', 'pipe', 'pipe'],
}).trim();
const prefix = '.github/workflows/';
const names = ['workflow-policy-cases.json', 'workflow-policy-contract.json',
  'Validate-WorkflowPolicy.mjs', 'pull-request-body-identity.yml', 'build.yml'];
const digest = value => crypto.createHash('sha256').update(value).digest('hex');
const canonical = value => Array.isArray(value) ? value.map(canonical)
  : value && typeof value === 'object'
    ? Object.fromEntries(Object.keys(value).sort().map(key => [key, canonical(value[key])])) : value;
// Batch only inert fixture objects; keep the process deadline and every case.
const original = git(['rev-parse', 'HEAD']);
const trees = new Map([[original, new Map(git(['ls-tree', '-rz', original]).split('\0')
  .filter(Boolean).map(entry => {
    const match = /^(\d{6}) blob ([a-f0-9]{40})\t([\s\S]+)$/.exec(entry);
    if (!match) throw new Error('Unsupported fixture tree entry');
    return [match[3], { mode: match[1], blob: match[2] }];
  }))]]);
const chunks = [], expectedParents = new Map(), blobMarks = new Map();
let nextMark = 0;
const commit = (base, texts, parents = [base]) => {
  const tree = new Map(trees.get(base));
  for (const [name, text] of Object.entries(texts)) {
    if (text === null) tree.delete(prefix + name);
    else tree.set(prefix + name, { mode: '100644', text });
  }
  for (const value of tree.values()) {
    if (value.text === undefined || value.blob !== undefined) continue;
    if (!blobMarks.has(value.text)) {
      const blobMark = ':' + (++nextMark);
      chunks.push('blob\nmark ' + blobMark + '\ndata ' + Buffer.byteLength(value.text) + '\n' + value.text + '\n');
      blobMarks.set(value.text, blobMark);
    }
    value.blob = blobMarks.get(value.text);
  }
  const mark = ':' + (++nextMark);
  trees.set(mark, tree); expectedParents.set(mark, parents);
  chunks.push(`commit refs/heads/task61-r3-ordinary-fixture\nmark ${mark}\n` +
    'committer Ordinary content self-test <ordinary@example.invalid> 1789430400 +0000\n' +
    'data 30\nInert ordinary content fixture\n' +
    `from ${parents[0]}\n` + parents.slice(1).map(parent => `merge ${parent}\n`).join('') + 'deleteall\n');
  for (const [name, value] of tree) {
    const quoted = JSON.stringify(name);
    chunks.push(`M ${value.mode} ${value.blob} ${quoted}\n`);
  }
  chunks.push('\n');
  return mark;
};
const readTexts = reference => Object.fromEntries(names.map(name => {
  const value = trees.get(reference).get(prefix + name);
  if (value.text === undefined) throw new Error('Missing inert fixture text');
  return [name, value.text];
}));
const initial = Object.fromEntries([...names, 'trust-root-authorization.json', 'Test-TrustRootAuthorization.ps1', 'Test-AgentInstructions.ps1', 'Sync-PullRequestBodyIdentity.mjs'].map(name =>
  [name, fs.readFileSync(path.join(source, prefix, name), 'utf8')]));
Object.assign(initial, JSON.parse(fs.readFileSync(path.join(source, prefix, 'workflow-ordinary-selftest-reference.json'), 'utf8')).files);
const base = commit(original, initial);
const rows = [];
const referenceTexts = new Map();
const build = (name, mutate, expected = '', reference = base) => {
  if (!referenceTexts.has(reference)) {
    referenceTexts.set(reference, readTexts(reference));
  }
  const texts = { ...referenceTexts.get(reference) };
  const catalog = JSON.parse(texts[names[0]]);
  const contract = JSON.parse(texts[names[1]]);
  const state = { catalog, contract, validator: texts[names[2]], workflow: texts[names[3]], build: texts[names[4]] };
  mutate(state);
  texts[names[3]] = state.workflow;
  texts[names[4]] = state.build;
  const generatorRun = state.build.split('        run: |\n')[1].split('\n      - name:')[0]
    .replace(/\n+$/, '') + '\n';
  contract.workflowPolicy.workflows['build.yml'].jobs.verify_generated_artifacts.steps[1].runSha256 =
    digest(generatorRun.split('\n').map(line => line ? line.slice(10) : '').join('\n'));
  const run = state.workflow.replaceAll('\r\n', '\n').split('        run: |\n')[1].split('\n      - name:')[0]
    .replace(/\n+$/, '') + '\n';
  contract.workflowPolicy.workflows['pull-request-body-identity.yml'].jobs.verify_identity.steps[0].runSha256 =
    digest(run.split('\n').map(line => line ? line.slice(10) : '').join('\n'));
  texts[names[0]] = JSON.stringify(catalog) + '\n';
  contract.caseCatalog.sha256 = digest(texts[names[0]]);
  const view = structuredClone(contract);
  delete view.validatorIdentity;
  texts[names[2]] = state.validator.replace(/^const VALIDATOR_VERSION = '(\d+)\.(\d+)\.(\d+)';$/m,
    (_, major, minor, patch) => `const VALIDATOR_VERSION = '${major}.${minor}.${Number(patch) + 1}';`)
    .replace(/^const EXPECTED_CONTRACT_CANONICAL_SHA256 = '[a-f0-9]{64}';$/m,
      `const EXPECTED_CONTRACT_CANONICAL_SHA256 = '${digest(JSON.stringify(canonical(view)))}';`);
  contract.validatorIdentity.sha256 = digest(texts[names[2]]);
  texts[names[1]] = JSON.stringify(contract) + '\n';
  const head = commit(reference, texts);
  rows.push({ name, head, base: reference, expected });
  return head;
};
const append = state => {
  const next = 1 + Math.max(...state.catalog.cases.filter(value => /^PS-P1-WFPOL-\d{3}$/.test(value.id))
    .map(value => Number(value.id.slice(-3))));
  state.catalog.cases.push({ id: `PS-P1-WFPOL-${String(next).padStart(3, '0')}`,
    semanticKey: `ordinary-negative-${next}`, domain: 'workflow', workflow: 'build.yml',
    operation: { type: 'set', path: '/permissions', value: { contents: 'write' } }, expected: false });
};
const topic = build('meaningful negative append', append);
build('comment with derived identities', state => { state.validator += '// Fixed ordinary-domain explanation.\n'; });
const changeHelper = (state, before, after) => {
  const start = state.workflow.indexOf('          function Add-ProposedBlob {\n');
  const end = state.workflow.indexOf('          & $strGitPath --no-replace-objects -c core.fsmonitor=false init --quiet .\n');
  const helper = state.workflow.slice(start, end);
  if (helper.split(before).length !== 2) throw new Error('helper mutation is not unique');
  state.workflow = state.workflow.slice(0, start) + helper.replace(before, after) + state.workflow.slice(end);
};
build('meaningful helper presentation', state => changeHelper(state,
  '              # .SYNOPSIS', '              # Review note: downloads stay bounded and proposed code stays inert.\n              # .SYNOPSIS'));
build('helper indentation and finally layout', state => changeHelper(state,
  '              } finally {', '                }\n              finally {'));
const historicalWorkflow = initial[names[3]].replace(/              # \.SYNOPSIS[\s\S]*?(?=              \[CmdletBinding)/,
  '').replace('[OutputType([long], [int])]', '[OutputType([long])]')
  .replace('              } finally {', '              }\n              finally {');
const historicalTexts = { ...initial, [names[3]]: historicalWorkflow };
const historicalContract = JSON.parse(historicalTexts[names[1]]);
const historicalRun = historicalWorkflow.split('        run: |\n')[1].split('\n      - name:')[0]
  .replace(/\n+$/, '') + '\n';
historicalContract.workflowPolicy.workflows['pull-request-body-identity.yml'].jobs.verify_identity.steps[0].runSha256 =
  digest(historicalRun.split('\n').map(line => line ? line.slice(10) : '').join('\n'));
const historicalView = structuredClone(historicalContract);
delete historicalView.validatorIdentity;
historicalTexts[names[2]] = historicalTexts[names[2]].replace(
  /^const EXPECTED_CONTRACT_CANONICAL_SHA256 = '[a-f0-9]{64}';$/m,
  `const EXPECTED_CONTRACT_CANONICAL_SHA256 = '${digest(JSON.stringify(canonical(historicalView)))}';`);
historicalContract.validatorIdentity.sha256 = digest(historicalTexts[names[2]]);
historicalTexts[names[1]] = JSON.stringify(historicalContract) + '\n';
const historicalBase = commit(base, historicalTexts);
build('real D52 complete help and static metadata', state => {
  state.workflow = initial[names[3]];
}, '', historicalBase);
const helperNegatives = [
  ['metadata regression long', '[OutputType([long], [int])]', '[OutputType([long])]', 'truthful static OutputType'],
  ['metadata regression int', '[OutputType([long], [int])]', '[OutputType([int])]', 'truthful static OutputType'],
  ['metadata reversed', '[OutputType([long], [int])]', '[OutputType([int], [long])]', 'truthful static OutputType'],
  ['unknown type', '[OutputType([long], [int])]', '[OutputType([NotARealType])]', 'truthful static OutputType'],
  ['type expression inert', '[OutputType([long], [int])]', '[OutputType($([IO.File]::WriteAllText("SENTINEL", "bad")))]', 'parser errors'],
  ['duplicate metadata', '[OutputType([long], [int])]', '[OutputType([long], [int])][OutputType([long], [int])]', 'one exact static OutputType'],
  ['extra attribute', '[OutputType([long], [int])]', '[OutputType([long], [int])][Obsolete()]', 'significant tokens'],
  ['changed binding', 'PositionalBinding = $false', 'PositionalBinding = $true', 'significant tokens'],
  ['changed parameter', '[long] $MaximumBytes', '[int] $MaximumBytes', 'significant tokens'],
  ['changed return', 'return 0', 'return 1', 'significant tokens'],
  ['changed command', 'hash-object --no-filters -w', 'hash-object --no-filters', 'significant tokens'],
  ['changed control flow', '$LASTEXITCODE -eq 0', '$LASTEXITCODE -ne 0', 'significant tokens'],
  ['changed helper', 'function Add-ProposedBlob', 'function Add-AnotherBlob', 'helper boundaries'],
  ['extra function', '              param(', '              function Invoke-Extra {}\n              param(', 'scope, requirements or parser errors'],
  ['parser error', 'return 0', 'return (', 'parser errors'],
  ['requires directive', '              # .SYNOPSIS', '              #requires -Version 99\n              # .SYNOPSIS', 'requirements'],
  ['signature directive', '              # .SYNOPSIS', '              # SIG # Begin signature block\n              # .SYNOPSIS', 'parser errors'],
  ['GitHub expression comment', '              # .SYNOPSIS', '              # ${{ github.token }}\n              # .SYNOPSIS', 'GitHub expressions'],
  ['GitHub expression literal', "throw 'acquire: a proposed blob request is invalid'", "throw '${{ github.token }}'", 'GitHub expressions'],
  ['shebang directive', '              # .SYNOPSIS', '              #!/bin/sh\n              # .SYNOPSIS', 'signature directive'],
  ['block comment directive', '              # .SYNOPSIS', '              <# presentation #>\n              # .SYNOPSIS', 'comment or signature'],
  ['comment-looking string', "throw 'acquire: a proposed blob request is invalid'", "throw '# harmless looking comment'", 'significant tokens'],
  ['comment-looking here string', "throw 'acquire: a proposed blob request is invalid'", "throw @'\n# comment-looking literal\n'@", 'significant tokens'],
  ['interpolation', '"blob-$Sequence.bin"', '"blob-$(1).bin"', 'significant tokens'],
  ['semicolon boundary', 'return 0', 'return; 0', 'significant tokens'],
  ['newline boundary', 'return 0', 'return\n0', 'parsed structure'],
  ['Unicode space', 'return 0', 'return\u00a00', 'bounded ASCII'],
  ['Unicode comment', '              # .SYNOPSIS', '              # \u200b\n              # .SYNOPSIS', 'bounded ASCII'],
];
for (const [name, before, after, expected] of helperNegatives) {
  build(name, state => changeHelper(state, before, after), expected);
}
build('non-helper workflow graph', state => {
  state.workflow = state.workflow.replace('    runs-on: ubuntu-24.04', '    runs-on: ubuntu-latest');
}, 'non-helper bytes');
build('helper YAML dedent', state => changeHelper(state, '              param(', ' param('),
  'acquisition indentation');
build('workflow BOM', state => { state.workflow = '\ufeff' + state.workflow; }, 'byte-order mark');
build('workflow CRLF', state => { state.workflow = state.workflow.replaceAll('\n', '\r\n'); }, 'non-LF newline');
build('helper parser token bound', state => changeHelper(state, '                  return 0',
  '              #x\n'.repeat(4100) + '                  return 0'), '8192-token parser bound');
build('helper parser node bound', state => changeHelper(state, '                  return 0',
  '                  $null = 1\n'.repeat(1000) + '                  return 0'), '4096-node parser bound');
const first = build('first ISO string update', state => {
  append(state); state.catalog.cases.at(-1).operation.value = '2026-09-14T00:00:00.000Z';
});
build('second update retains ISO string', append, '', first);
build('changed prior case', state => { state.catalog.cases[0].expected = false; }, 'changed or removed an existing case');
build('retained Unicode string drift', state => { state.catalog.cases[0].semanticKey += '\u200b'; }, 'changed or removed an existing case');
build('contract Unicode string drift', state => { state.contract.schema += '\u200b'; }, 'changes policy rules');
build('schema Unicode string drift', state => { state.catalog.schema += '\u200b'; }, 'catalog has an invalid schema');
build('case key Unicode drift', state => {
  append(state); const item = state.catalog.cases.at(-1);
  item['domain\u200b'] = item.domain; delete item.domain;
}, 'unexpected key set');
build('operation Unicode drift', state => { append(state); state.catalog.cases.at(-1).operation.type = 'se\u200bt'; }, 'unsupported operation');
build('legitimate Unicode string data', state => {
  append(state); state.catalog.cases.at(-1).operation.value = 'Ordinary \u200b Unicode data';
});
build('changed executable rules', state => { state.validator += 'process.exit(0);\n'; }, 'bounded inert line comments');
build('uppercase operation', state => { append(state); state.catalog.cases.at(-1).operation.type = 'SET'; }, 'unsupported operation');
for (const field of ['id', 'domain', 'workflow', 'semanticKey', 'operation']) {
  for (const value of [true, 7, ['wrong']]) {
    build(`${field} rejects ${JSON.stringify(value)}`, state => {
      append(state);
      if (field === 'operation') state.catalog.cases.at(-1).operation.type = value;
      else state.catalog.cases.at(-1)[field] = value;
    }, field === 'operation' ? 'unsupported operation' : 'ordinary new case');
  }
}
for (const value of [true, 7, ['wrong']]) {
  build(`schema rejects ${JSON.stringify(value)}`, state => { state.catalog.schema = value; }, 'catalog has an invalid schema');
}
const tuple = readTexts(topic);
// Exercise the same reviewed source language, with no candidate SHA tuple.
const authorizerText = initial['Test-TrustRootAuthorization.ps1'];
const sourceShapes = [...authorizerText.matchAll(/        Before = @'\n([\s\S]*?)\n'@\n        After = @'\n([\s\S]*?)\n'@/g)]
  .map(match => ({ before: match[1] + '\n', after: match[2] + '\n' }));
if (sourceShapes.length !== 6) throw new Error('Incomplete reviewed source-region fixture inventory');
const literal = name => {
  const marker = `$script:${name} = @'\n`;
  const start = authorizerText.indexOf(marker);
  if (start < 0 || authorizerText.indexOf(marker, start + 1) >= 0) throw new Error('Ambiguous trusted literal');
  return authorizerText.slice(start + marker.length).split("\n'@")[0];
};
const jsonLiteral = name => {
  const marker = `$script:${name} = ConvertFrom-Json -AsHashtable -InputObject @'\n`;
  const start = authorizerText.indexOf(marker);
  if (start < 0 || authorizerText.indexOf(marker, start + 1) >= 0) throw new Error('Ambiguous trusted JSON literal');
  return JSON.parse(authorizerText.slice(start + marker.length).split("\n'@")[0]);
};
const oldTail = literal('strLegacyGeneratorResultTail');
const newTail = literal('strBoundedGeneratorResultTail');
const requiredCases = jsonLiteral('arrRequiredGeneratorResultCase');
const requiredPolicy = jsonLiteral('objGeneratorResultPolicy');
const strengthen = state => {
  const alreadyStrengthened = state.validator.includes('const GENERATOR_RESULT_PREDICATES =');
  for (const shape of sourceShapes) {
    if (!alreadyStrengthened && state.validator.includes(shape.before)) state.validator = state.validator.replace(shape.before, shape.after);
    else if (!alreadyStrengthened || !state.validator.includes(shape.after)) throw new Error('Unsupported fixture source region');
  }
  if (state.build.includes(oldTail)) state.build = state.build.replace(oldTail, newTail);
  else if (!state.build.includes(newTail)) throw new Error('Unsupported fixture caller');
  for (const item of requiredCases) {
    if (!state.catalog.cases.some(prior => prior.semanticKey === item.semanticKey)) {
      state.catalog.cases.push(structuredClone(item));
    }
  }
  state.contract.workflowPolicy.generatorResultPolicy = structuredClone(requiredPolicy);
};
const strengthened = build('reviewed generator-result strengthening', strengthen);
const appendGeneratorCase = state => {
  const next = 1 + Math.max(...state.catalog.cases.filter(item => /^PS-P1-WFPOL-\d{3}$/.test(item.id))
    .map(item => Number(item.id.slice(-3))));
  state.catalog.cases.push({ id: `PS-P1-WFPOL-${String(next).padStart(3, '0')}`,
    semanticKey: `generator-result-repeat-use-${next}`, domain: 'workflow', workflow: 'build.yml',
    operation: { type: 'replace', path: '/jobs/verify_generated_artifacts/steps/1/run',
      from: 'if ($listFailedChecks.Count -ne 0) {', to: 'if ($true) {' },
    expected: false, expectedCategory: 'generator-result-guard' });
};
const repeated = build('second material generator-result candidate without verifier changes', appendGeneratorCase, '', strengthened);
build('third material repeat uses same verifier', appendGeneratorCase, '', repeated);
build('strengthened source recognition is idempotent', () => {}, '', strengthened);
const extraBefore = build('candidate extra old anchor', state => {
  state.validator += sourceShapes[2].before;
}, 'bounded inert line comments', strengthened);
build('trusted strengthened extra old anchor', appendGeneratorCase, 'extra region anchor', extraBefore);
const extraAfter = build('candidate duplicate new region', state => {
  state.validator += sourceShapes[2].after;
}, 'bounded inert line comments', strengthened);
build('trusted strengthened duplicate new region', appendGeneratorCase, 'unsupported or mixed region', extraAfter);
build('strengthened validator downgrade', state => {
  for (const shape of sourceShapes) state.validator = state.validator.replace(shape.after, shape.before);
}, 'cannot downgrade', strengthened);
build('strengthened caller downgrade', state => { state.build = state.build.replace(newTail, oldTail); },
  'unsupported generator caller bytes', strengthened);
build('strengthened missing policy', state => { delete state.contract.workflowPolicy.generatorResultPolicy; },
  'policy is missing or inconsistent', strengthened);
build('strengthened catalog downgrade', state => { state.catalog.cases = state.catalog.cases.slice(0, -1); },
  'catalog has an invalid schema or count', strengthened);
for (const [index, shape] of sourceShapes.entries()) {
  build(`strengthened mixed source region ${index}`, state => {
    state.validator = state.validator.replace(shape.after, shape.before);
  }, index === 0 ? 'cannot downgrade' : 'Unsupported ordinary validator shape', strengthened);
}
build('outside-domain executable behavior', state => {
  state.validator = state.validator.replace('function fail(category) {', 'function fail(category) { return;');
}, 'Unsupported ordinary validator shape', strengthened);
build('new category absent needle', state => {
  appendGeneratorCase(state); state.catalog.cases.at(-1).operation.from = 'ABSENT-GENERATOR-NEEDLE';
}, 'cannot prepare one exact supported mutation', strengthened);
build('new category wrong expected category', state => {
  appendGeneratorCase(state); state.catalog.cases.at(-1).expectedCategory = 'generator-result-output';
}, 'did not fail in its declared category', strengthened);
build('new category no-op mutation', state => {
  appendGeneratorCase(state); state.catalog.cases.at(-1).operation.to = state.catalog.cases.at(-1).operation.from;
}, 'mutation changed no bytes', strengthened);
build('new category unsupported pointer', state => {
  appendGeneratorCase(state); state.catalog.cases.at(-1).operation.path = '/permissions';
}, 'cannot prepare one exact supported mutation', strengthened);
build('new category malformed category type', state => {
  appendGeneratorCase(state); state.catalog.cases.at(-1).expectedCategory = ['generator-result-guard'];
}, 'cannot prepare one exact supported mutation', strengthened);
build('literal-only policy cannot publish values', state => {
  state.contract.workflowPolicy.generatorResultPolicy.actualValues = true;
}, 'policy is missing or inconsistent', strengthened);
const maintenanceImported = commit(base, { 'maintenance-import.txt': 'Trusted maintenance contribution\n' });
const strengthenedTuple = readTexts(strengthened);
const integratedStrengthened = commit(maintenanceImported, strengthenedTuple, [strengthened, maintenanceImported]);
rows.push({ name: 'strengthening imports exact trusted maintenance history', base: maintenanceImported,
  head: integratedStrengthened, expected: '' });
const refreshed = commit(base, { 'outside-history.txt': 'Trusted main contribution\n' });
const merged = commit(refreshed, tuple, [topic, refreshed]);
rows.push({ name: 'ordinary merge imports exact trusted content', base: refreshed, head: merged, expected: '' });
const badMerge = commit(refreshed, { ...tuple, 'outside-history.txt': 'Hostile resolution\n' }, [topic, refreshed]);
const revertedMerge = commit(badMerge, { 'outside-history.txt': 'Trusted main contribution\n' });
rows.push({ name: 'reverted hostile merge resolution', base: refreshed, head: revertedMerge, expected: 'Unsupported ordinary history shape' });
const badSide = commit(base, { 'outside-side.txt': 'Hostile side edit\n' });
const revertedSide = commit(badSide, { 'outside-side.txt': null });
const octopus = commit(refreshed, tuple, [topic, refreshed, revertedSide]);
rows.push({ name: 'octopus retains hostile side history rejection', base: refreshed, head: octopus, expected: 'Unsupported ordinary history shape' });
const collisionStart = commit(base, { 'normal\u200b.txt': 'Original exact path\n' });
const collisionBase = commit(collisionStart, { 'normal.txt': 'Trusted import\n' });
const collisionTopic = build('Unicode data remains valid at exact base', append, '', collisionStart);
const collisionTuple = readTexts(collisionTopic);
const collisionBad = commit(collisionBase, { ...collisionTuple, 'normal\u200b.txt': 'Hostile resolution\n' }, [collisionTopic, collisionBase]);
const collisionRestored = commit(collisionBase, collisionTuple, [collisionBad, collisionBase]);
rows.push({ name: 'ordinal path identity retains hostile history', base: collisionBase, head: collisionRestored, expected: 'Unsupported ordinary history shape' });
const marksPath = path.join(repo, '.git', 'ordinary-fixture.marks');
const input = Buffer.from(chunks.join('') + 'done\n');
if (input.length > 134217728) throw new Error('Inert fixture batch exceeds 128 MiB');
git(['fast-import', '--quiet', '--done', `--export-marks=${marksPath}`], input);
const marks = new Map(fs.readFileSync(marksPath, 'utf8').trim().split('\n').map(line => line.split(' ')));
const resolve = reference => reference.startsWith(':') ? marks.get(reference) : reference;
if (marks.size !== nextMark || [...marks.values()].some(value => !/^[a-f0-9]{40}$/.test(value))) {
  throw new Error('Invalid inert fixture object identities');
}
const observedParents = new Map(git(['rev-list', '--parents', '--no-walk=unsorted', ...[...expectedParents.keys()].map(resolve)])
  .split('\n').map(line => { const [head, ...parents] = line.split(' '); return [head, parents]; }));
for (const [mark, parents] of expectedParents) {
  if (JSON.stringify(observedParents.get(resolve(mark))) !== JSON.stringify(parents.map(resolve))) {
    throw new Error('Inert fixture parent identity mismatch');
  }
}
process.stdout.write(JSON.stringify(rows.map(row => ({ ...row, base: resolve(row.base), head: resolve(row.head) }))));
'@
        $objOrdinaryFixtures = Invoke-BoundedProcessByte -FileName 'node' `
            -ArgumentList @('--input-type=module', '-e', $strOrdinaryFixtureBuilder,
                $strSchemaFixtureRoot, $RepositoryRootPath) `
            -MaximumBytes 65536 -TimeoutMilliseconds 60000
        if ($objOrdinaryFixtures.ExitCode -ne 0) {
            throw 'Could not build the inert ordinary content fixtures.'
        }
        $arrOrdinaryFixtures = @(ConvertFrom-Json -InputObject (
                ConvertFrom-StrictUtf8Text -Bytes $objOrdinaryFixtures.Bytes `
                    -Name 'The inert ordinary fixture identities'
            ))
        if ($arrOrdinaryFixtures.Count -ne 99) {
            throw "The ordinary fixture catalog must contain exactly 99 cases; got $($arrOrdinaryFixtures.Count)."
        }
        $strCandidateSentinel = [IO.Path]::Combine($PWD.Path, 'SENTINEL')
        if ([IO.File]::Exists($strCandidateSentinel)) {
            throw 'The inert expression sentinel must be absent before validation.'
        }
        foreach ($objOrdinaryFixture in $arrOrdinaryFixtures) {
            try {
                Assert-OrdinaryWorkflowPolicyContent `
                    -RepositoryRootPath $strSchemaFixtureRoot `
                    -TrustedRevision $objOrdinaryFixture.base `
                    -HeadRevision $objOrdinaryFixture.head
                if (-not [string]::IsNullOrEmpty($objOrdinaryFixture.expected)) {
                    throw "Ordinary hostile fixture passed: $($objOrdinaryFixture.name)"
                }
            } catch {
                if ([string]::IsNullOrEmpty($objOrdinaryFixture.expected) -or
                    -not $_.Exception.Message.Contains(
                        $objOrdinaryFixture.expected, [StringComparison]::Ordinal
                    )) {
                    throw
                }
            }
        }
        if ([IO.File]::Exists($strCandidateSentinel)) {
            throw 'An inert candidate expression created its sentinel.'
        }

        # P1 fixtures use real trusted Git blobs and the production history
        # reader. Fixture construction must finish before refusal assertions.
        $strIsolationFixtureBuilder = @'
import fs from 'node:fs';
import path from 'node:path';
import crypto from 'node:crypto';
import { execFileSync } from 'node:child_process';
const [repo, source] = process.argv.slice(1);
const prefix = '.github/workflows/';
const names = ['build.yml', 'markdownlint.yml', 'pull-request-body-identity.yml',
  'Validate-WorkflowPolicy.mjs', 'workflow-policy-contract.json', 'workflow-policy-cases.json'];
const referenceNames = ['workflow-isolation-reference.json', 'workflow-isolation-validator.reference.txt'];
const git = (args, input) => execFileSync('git', ['-C', repo, ...args], {
  input, encoding: 'utf8', windowsHide: true, maxBuffer: 1048576,
  stdio: ['pipe', 'pipe', 'pipe'],
}).trim();
const digest = value => crypto.createHash('sha256').update(value).digest('hex');
const canonical = value => Array.isArray(value) ? value.map(canonical) : value && typeof value === 'object'
  ? Object.fromEntries(Object.keys(value).sort().map(key => [key, canonical(value[key])])) : value;
const initial = Object.fromEntries([...names, ...referenceNames,
  'trust-root-authorization.json', 'Test-TrustRootAuthorization.ps1', 'Test-AgentInstructions.ps1',
  'Sync-PullRequestBodyIdentity.mjs'].map(name => [name, fs.readFileSync(path.join(source, prefix, name), 'utf8').replaceAll('\r\n', '\n')]));
Object.assign(initial, JSON.parse(fs.readFileSync(path.join(source, prefix, 'workflow-ordinary-selftest-reference.json'), 'utf8')).files);
// Common-domain fixtures are inert Git data. Preserve the historical fixture
// generator exactly even when this self-test runs from the common product.
const replaceOnce = (text, before, after) => {
  if (text.split(before).length !== 2) throw new Error('Common fixture input is not unique');
  return text.replace(before, () => after);
};
const sourceGenerator = fs.readFileSync(path.join(source, prefix, 'Generate-StyleGuideArtifacts.ps1'), 'utf8').replaceAll('\r\n', '\n');
let legacyGenerator = sourceGenerator;
const commonBinding = "$script:strGeneratorVersion = '1.0.20260919.0'";
const legacyBinding = "$script:strGeneratorVersion = '1.0.20260916.0'";
if (legacyGenerator.includes(commonBinding)) {
  legacyGenerator = replaceOnce(legacyGenerator, 'Version: 1.0.20260919.0\n#>', 'Version: 1.0.20260916.0\n#>');
  legacyGenerator = replaceOnce(legacyGenerator, commonBinding, legacyBinding);
  legacyGenerator = replaceOnce(legacyGenerator, 'Microsoft.PowerShell.Core\\Get-Command -Name git', 'Get-Command -Name git');
  const tracked = /^function Assert-TrackedFile \{[\s\S]*?^\}/m.exec(legacyGenerator);
  if (!tracked) throw new Error('Common fixture lacks tracked-file function');
  legacyGenerator = replaceOnce(legacyGenerator, tracked[0], replaceOnce(tracked[0],
    '# Version: 1.0.20260919.0', '# Version: 1.0.20260813.0'));
}
if (!legacyGenerator.includes(legacyBinding)) throw new Error('Unsupported historical generator fixture');
if (digest(legacyGenerator) !== JSON.parse(initial['workflow-policy-contract.json']).scriptVersions.generator.sha256) {
  throw new Error('Historical generator fixture does not match its reviewed contract identity');
}
initial['Generate-StyleGuideArtifacts.ps1'] = legacyGenerator;
for (const name of ['workflow-common-reference.json', 'workflow-common-validator.reference.txt']) {
  initial[name] = fs.readFileSync(path.join(source, prefix, name), 'utf8').replaceAll('\r\n', '\n');
}

const reference = JSON.parse(initial[referenceNames[0]]);
const original = git(['rev-parse', 'HEAD']);
const trees = new Map([[original, new Map(git(['ls-tree', '-rz', original]).split('\0').filter(Boolean).map(entry => {
  const match = /^(\d{6}) blob ([a-f0-9]{40})\t([\s\S]+)$/.exec(entry);
  if (!match) throw new Error('Unsupported P1 fixture tree entry');
  return [match[3], { mode: match[1], blob: match[2] }];
}))]]);
const chunks = [], parentsByMark = new Map(), blobMarks = new Map();
let batchBytes = 0;
const checkedBatchLength = (current, added) => {
  const total = current + added;
  if (total > 134217728) throw new Error('Inert P1 fixture batch exceeds 128 MiB');
  return total;
};
if (checkedBatchLength(134217727, 1) !== 134217728) throw new Error('P1 batch maximum was rejected');
let batchOverflowRejected = false;
try { checkedBatchLength(134217728, 1); }
catch (error) {
  if (error.message !== 'Inert P1 fixture batch exceeds 128 MiB') throw error;
  batchOverflowRejected = true;
}
if (!batchOverflowRejected) throw new Error('P1 batch maximum+1 was accepted');
const appendBatch = text => {
  batchBytes = checkedBatchLength(batchBytes, Buffer.byteLength(text));
  chunks.push(text);
};
let nextMark = 0;
const commit = (base, texts, modes = {}, parents = [base]) => {
  const tree = new Map(trees.get(base));
  for (const [name, text] of Object.entries(texts)) {
    if (text === null) tree.delete(prefix + name);
    else tree.set(prefix + name, { mode: modes[name] ?? '100644', text });
  }
  for (const value of tree.values()) {
    if (value.text === undefined || value.blob !== undefined) continue;
    if (!blobMarks.has(value.text)) {
      const blobMark = `:${++nextMark}`;
      appendBatch(`blob\nmark ${blobMark}\ndata ${Buffer.byteLength(value.text)}\n${value.text}\n`);
      blobMarks.set(value.text, blobMark);
    }
    value.blob = blobMarks.get(value.text);
  }
  const mark = `:${++nextMark}`;
  trees.set(mark, tree); parentsByMark.set(mark, parents);
  const message = 'Inert P1 admission fixture\n';
  appendBatch(`commit refs/heads/p1-admission-fixture\nmark ${mark}\n` +
    'committer P1 admission self-test <p1@example.invalid> 1789689600 +0000\n' +
    `data ${Buffer.byteLength(message)}\n${message}from ${parents[0]}\n` +
    parents.slice(1).map(parent => `merge ${parent}\n`).join('') + 'deleteall\n');
  for (const [name, value] of tree) {
    appendBatch(`M ${value.mode} ${value.blob} ${JSON.stringify(name)}\n`);
  }
  appendBatch('\n');
  return mark;
};
const base = commit(original, initial);
const read = (ref, name) => trees.get(ref).get(prefix + name)?.text;
const rows = [];
const record = (name, base, head, expected = '') => rows.push({ name, base, head, expected });
const derive = state => {
  const catalogText = JSON.stringify(state.catalog) + '\n';
  state.contract.caseCatalog.sha256 = digest(catalogText);
  const view = structuredClone(state.contract);
  delete view.validatorIdentity;
  let validator = state.validator.replace(/^const EXPECTED_CONTRACT_CANONICAL_SHA256 = '[a-f0-9]{64}';$/m,
    () => `const EXPECTED_CONTRACT_CANONICAL_SHA256 = '${digest(JSON.stringify(canonical(view)))}';`);
  state.contract.validatorIdentity.sha256 = digest(validator);
  return { ...state.texts, 'workflow-policy-cases.json': catalogText,
    'workflow-policy-contract.json': JSON.stringify(state.contract) + '\n', 'Validate-WorkflowPolicy.mjs': validator };
};
const prepare = (trusted = base) => {
  const trustedVersion = /^const VALIDATOR_VERSION = '(\d+)\.(\d+)\.(\d+)';$/m.exec(read(trusted, names[3]));
  if (!trustedVersion) throw new Error('Missing trusted version');
  const contract = JSON.parse(reference.contractText);
  const state = { contract, catalog: JSON.parse(read(trusted, names[3]).includes('const WORKFLOW_ISOLATION_POLICY_VERSION = 1;')
    ? read(trusted, names[5]) : reference.caseCatalogText), texts: {
      'build.yml': reference.workflowText['build.yml'].replace('{{VERIFY_TIMEOUT_MINUTES}}', '30'),
      'markdownlint.yml': reference.workflowText['markdownlint.yml'].replace('{{POLICY_TIMEOUT_MINUTES}}', '30').replace('{{LINT_TIMEOUT_MINUTES}}', '30'),
      'pull-request-body-identity.yml': read(trusted, names[2]),
    }, validator: initial[referenceNames[1]].replace(/^const VALIDATOR_VERSION = '[0-9.]+';$/m,
      () => `const VALIDATOR_VERSION = '${trustedVersion[1]}.${trustedVersion[2]}.${Number(trustedVersion[3]) + 1}';`) };
  for (const [workflow, job] of [['build.yml', 'verify_generated_artifacts'], ['markdownlint.yml', 'policy'], ['markdownlint.yml', 'markdownlint']]) {
    contract.workflowPolicy.workflows[workflow].jobs[job].timeoutMinutes = 30;
  }
  return state;
};
const build = (name, mutate = () => {}, expected = '', trusted = base) => {
  const state = prepare(trusted);
  mutate(state);
  const head = commit(trusted, derive(state));
  record(name, trusted, head, expected);
  return head;
};
const append = (state, count = 1) => {
  let next = Math.max(...state.catalog.cases.filter(item => /^PS-P1-WFPOL-\d{3}$/.test(item.id)).map(item => Number(item.id.slice(-3))));
  for (let index = 0; index < count; index++) state.catalog.cases.push({
    id: `PS-P1-WFPOL-${String(++next).padStart(3, '0')}`, semanticKey: `p1-selftest-permission-${next}`,
    domain: 'workflow', workflow: 'build.yml', operation: { type: 'set', path: '/permissions', value: { contents: 'write' } }, expected: false,
  });
};
const first = build('initial fixed P1 tuple');
const second = build('distinct bounded P1 tuple', state => {
  state.texts['build.yml'] = state.texts['build.yml'].replace('timeout-minutes: 30', 'timeout-minutes: 31');
  state.contract.workflowPolicy.workflows['build.yml'].jobs.verify_generated_artifacts.timeoutMinutes = 31;
  state.validator += '// Fixed second candidate explanation.\n'; append(state);
});
build('sequential P1 reuse', state => { append(state); state.validator += '// Fixed later candidate explanation.\n'; }, '', first);
for (const value of [5, 60, 4, 61]) build(`P1 timeout ${value}`, state => {
  state.texts['markdownlint.yml'] = state.texts['markdownlint.yml'].replace('timeout-minutes: 30', `timeout-minutes: ${value}`);
  state.contract.workflowPolicy.workflows['markdownlint.yml'].jobs.policy.timeoutMinutes = value;
}, value < 5 || value > 60 ? 'outside 5 through 60' : '');
build('initial closed permission fixture', state => append(state));
const maximumIncrement = build('32-case increment', state => append(state, 32));
build('33-case increment rejected', state => append(state, 33), 'exceeds its increment bound');
build('512 cases accepted', state => append(state, 512 - state.catalog.cases.length), '', maximumIncrement);
build('513 cases rejected', state => append(state, 513 - state.catalog.cases.length), 'invalid schema or count', maximumIncrement);
for (const length of [8192, 8193]) build(`P1 comment suffix ${length}`, state => {
  state.validator += '// ' + 'x'.repeat(length - 4) + '\n';
}, length === 8192 ? '' : 'not bounded inert line comments');
build('candidate execution sentinel', state => {
  state.validator = `(await import('node:fs')).writeFileSync(${JSON.stringify(path.join(repo, 'P1-SENTINEL'))}, 'P1_CANDIDATE_EXECUTED');\n` + state.validator;
}, 'unsupported executable validator bytes');
build('candidate executable replacement', state => { state.validator = state.validator.replace('function ', 'function hostile_'); }, 'unsupported executable validator bytes');
build('candidate authority substitution', state => { state.texts[referenceNames[1]] = 'candidate supplied authority\n'; }, 'Unsupported ordinary content shape');
build('contract weakening', state => { state.contract.limits.maximumWorkflowBytes++; }, 'changes rules or has inconsistent derived identities');
build('required case removed', state => { state.catalog.cases.pop(); }, 'removes cases or exceeds its increment bound');
build('required case weakened', state => { state.catalog.cases[0].expected = false; }, 'changes or reorders a required or accepted case');
build('required case reordered', state => { [state.catalog.cases[0], state.catalog.cases[1]] = [state.catalog.cases[1], state.catalog.cases[0]]; }, 'changes or reorders a required or accepted case');
for (const field of ['domain', 'workflow', 'type', 'path']) for (const value of [null, [], {}, ['set']]) build(`malformed appended ${field} ${JSON.stringify(value)}`, state => {
  append(state); const item = state.catalog.cases.at(-1);
  (['domain', 'workflow'].includes(field) ? item : item.operation)[field] = value;
}, 'not a sequential negative workflow fixture');
for (const [name, mutate, expected] of [
  ['extra operation field', item => { item.operation.extra = true; }, 'unexpected key set'],
  ['missing operation value', item => { delete item.operation.value; }, 'unexpected key set'],
  ['repeated case identity', item => { item.id = 'PS-P1-WFPOL-001'; }, 'not a sequential negative workflow fixture'],
  ['positive appended case', item => { item.expected = true; }, 'not a sequential negative workflow fixture'],
  ['unsafe pointer', item => { item.operation.path = '/__proto__/polluted'; }, 'unsafe or invalid JSON pointer'],
  ['unproved initial case', item => { item.operation.path = '/name'; item.operation.value = 'other'; }, 'no independent closed predicate'],
]) build(name, state => { append(state); mutate(state.catalog.cases.at(-1)); }, expected);
for (const name of ['build.yml', 'markdownlint.yml']) build(`changed topology ${name}`, state => {
  state.texts[name] = state.texts[name].replace('permissions: {}', 'permissions: { contents: write }');
}, 'outside its fixed typed slots');
const appendGenerator = state => {
  append(state);
  const identity = { id: state.catalog.cases.at(-1).id, semanticKey: state.catalog.cases.at(-1).semanticKey };
  state.catalog.cases[state.catalog.cases.length - 1] = { ...structuredClone(state.catalog.cases.find(item => item.id === 'PS-P1-WFPOL-065')), ...identity };
  return state.catalog.cases.at(-1);
};
build('independently proved generator append', state => appendGenerator(state));
for (const [name, mutate, expected] of [
  ['type-array', item => { item.operation.type = ['replace']; }, 'not a sequential negative workflow fixture'],
  ['path-array', item => { item.operation.path = [item.operation.path]; }, 'not a sequential negative workflow fixture'],
  ['extra', item => { item.operation.extra = true; }, 'unexpected key set'],
  ['missing', item => { delete item.operation.from; }, 'unexpected key set'],
  ['wrong-category', item => { item.expectedCategory = 'generator-result-flow'; }, 'did not fail in its declared category'],
  ['missing-anchor', item => { item.operation.from = 'missing anchor'; }, 'escapes its fixed result region'],
  ['outside-region', item => { item.operation.from = '$ErrorActionPreference'; }, 'escapes its fixed result region'],
  ['marker-injection', item => { item.operation.to = '# END P1 GENERATOR RESULT\n'; }, 'escapes its fixed result region'],
]) build(`generator fixture ${name}`, state => mutate(appendGenerator(state)), expected);
for (const [name, change, expected] of [
  ['malformed catalog', { 'workflow-policy-cases.json': '{' }, 'malformed JSON'],
  ['duplicate catalog member', { 'workflow-policy-cases.json': '{"schema":"x","schema":"y","cases":[]}' }, 'malformed JSON'],
  ['oversized validator', { 'Validate-WorkflowPolicy.mjs': initial[referenceNames[1]] + ' '.repeat(524289) }, 'exceeds'],
  ['oversized build', { 'build.yml': ' '.repeat(131073) }, 'exceeds'],
  ['unrelated path', { 'outside.txt': 'not allowed\n' }, 'Unsupported ordinary content shape'],
]) record(name, base, commit(base, { ...derive(prepare()), ...change }), expected);
for (const mode of ['100755', '120000']) {
  const texts = derive(prepare());
  const head = commit(base, texts, { 'build.yml': mode });
  record(`nonregular mode ${mode}`, base, head, 'non-regular');
  record(`reverted mode ${mode}`, base, commit(head, texts), 'non-regular');
}
const hostile = commit(base, { 'outside.txt': 'not allowed\n' });
record('reverted unauthorized history', base, commit(hostile, { ...derive(prepare()), 'outside.txt': null }), 'Unsupported ordinary history shape');
record('candidate authority history', base, commit(commit(base, { [referenceNames[0]]: '{}\n' }),
  { ...derive(prepare()), [referenceNames[0]]: initial[referenceNames[0]] }), 'Unsupported ordinary history shape');
record('complete topology downgrade', first, commit(first, Object.fromEntries(names.map(name => [name, initial[name]]))), 'Unsupported ordinary content shape');
record('isolation marker downgrade', first, commit(first, Object.fromEntries(names.filter(name => name !== 'markdownlint.yml').map(name => [name, initial[name]]))), 'cannot downgrade');
let chain = first;
for (let count = 2; count <= 65; count++) {
  chain = commit(chain, {});
  if (count === 64 || count === 65) record(`P1 history ${count} commits`, base, chain, count === 64 ? '' : 'exceeds 64 commits');
}
for (const name of referenceNames) {
  for (const mode of ['100755', '120000']) {
    const trusted = commit(base, { [name]: initial[name] }, { [name]: mode });
    build(`trusted reference mode ${name} ${mode}`, () => {}, 'missing or is not a regular blob', trusted);
  }
  const missing = commit(base, { [name]: null });
  build(`missing trusted reference ${name}`, () => {}, 'missing or is not a regular blob', missing);
  const oversized = commit(base, { [name]: initial[name] + ' '.repeat(524289 - Buffer.byteLength(initial[name])) });
  build(`oversized trusted reference ${name}`, () => {}, 'exceeds its byte limit', oversized);
}
const maximumReference = commit(base, { [referenceNames[0]]: initial[referenceNames[0]] + ' '.repeat(524288 - Buffer.byteLength(initial[referenceNames[0]])) });
build('524288-byte trusted JSON reference accepted', () => {}, '', maximumReference);
const commonReference = JSON.parse(initial['workflow-common-reference.json']);
const helperDigest = JSON.parse(fs.readFileSync(path.join(source, prefix, 'workflow-policy-contract.json'), 'utf8'))
  .workflowPolicy.workflows['pull-request-body-identity.yml'].jobs.verify_identity.steps[0].runSha256;
const commonHelper = fs.readFileSync(path.join(source, prefix, 'pull-request-body-identity.yml'), 'utf8').replaceAll('\r\n', '\n');
const maintenanceState = prepare();
maintenanceState.texts['Generate-StyleGuideArtifacts.ps1'] = legacyGenerator;
maintenanceState.texts['pull-request-body-identity.yml'] = commonHelper;
maintenanceState.contract.workflowPolicy.workflows['pull-request-body-identity.yml'].jobs.verify_identity.steps[0].runSha256 = helperDigest;
maintenanceState.validator = maintenanceState.validator.replace(/^const VALIDATOR_VERSION = '[0-9.]+';$/m, "const VALIDATOR_VERSION = '1.5.6';");
const commonMaintenance = commit(base, derive(maintenanceState));
let commonGenerator = replaceOnce(legacyGenerator, 'Version: 1.0.20260916.0\n#>', 'Version: 1.0.20260919.0\n#>');
commonGenerator = replaceOnce(commonGenerator, legacyBinding, commonBinding);
commonGenerator = replaceOnce(commonGenerator, '$arrGitCommands = @(Get-Command -Name git', '$arrGitCommands = @(Microsoft.PowerShell.Core\\Get-Command -Name git');
const legacyTracked = /^function Assert-TrackedFile \{[\s\S]*?^\}/m.exec(commonGenerator);
if (!legacyTracked) throw new Error('Common fixture lacks legacy tracked-file function');
commonGenerator = replaceOnce(commonGenerator, legacyTracked[0], replaceOnce(legacyTracked[0], '# Version: 1.0.20260813.0', '# Version: 1.0.20260919.0'));
const prepareCommon = (trusted = commonMaintenance) => {
  const version = /^const VALIDATOR_VERSION = '(\d+)\.(\d+)\.(\d+)';$/m.exec(read(trusted, names[3]));
  const contract = JSON.parse(commonReference.contractText);
  contract.workflowPolicy.workflows['pull-request-body-identity.yml'].jobs.verify_identity.steps[0].runSha256 = helperDigest;
  return { contract, catalog: JSON.parse(commonReference.caseCatalogText), texts: {
    'build.yml': commonReference.workflowText['build.yml'].replace('{{VERIFY_TIMEOUT_MINUTES}}', '30'),
    'markdownlint.yml': commonReference.workflowText['markdownlint.yml'].replace('{{POLICY_TIMEOUT_MINUTES}}', '30').replace('{{LINT_TIMEOUT_MINUTES}}', '30'),
    'pull-request-body-identity.yml': commonHelper, 'Generate-StyleGuideArtifacts.ps1': commonGenerator,
  }, validator: initial['workflow-common-validator.reference.txt'].replace(/^const VALIDATOR_VERSION = '[0-9.]+';$/m,
    "const VALIDATOR_VERSION = '" + version[1] + '.' + version[2] + '.' + (Number(version[3]) + 1) + "';") };
};
const commonBuild = (name, mutate = () => {}, expected = '', trusted = commonMaintenance) => {
  const state = prepareCommon(trusted); mutate(state);
  const head = commit(trusted, derive(state)); record(name, trusted, head, expected); return head;
};
const commonFirst = commonBuild('common exact initial transition');
commonBuild('common later negative fixture', state => append(state), '', commonFirst);
commonBuild('common maximum512 fixtures', state => append(state, 512 - state.catalog.cases.length), '', commonFirst);
commonBuild('common maximum513 rejected', state => append(state, 513 - state.catalog.cases.length), 'invalid schema or count', commonFirst);
const legacyAppendState = structuredClone(maintenanceState);
append(legacyAppendState);
legacyAppendState.validator = legacyAppendState.validator.replace("const VALIDATOR_VERSION = '1.5.6';", "const VALIDATOR_VERSION = '1.5.7';");
const legacyAppended = commit(commonMaintenance, derive(legacyAppendState));
record('legacy service remains available', commonMaintenance, legacyAppended);
commonBuild('common transition preserves accepted legacy cases', () => {}, 'accepted cases must not be lost', legacyAppended);
commonBuild('common lookup cannot downgrade', state => {
  state.texts['Generate-StyleGuideArtifacts.ps1'] = commonGenerator.replace('Microsoft.PowerShell.Core\\Get-Command', 'Get-Command');
}, 'immutable', commonFirst);
commonBuild('common catalog cannot downgrade', state => { state.catalog = JSON.parse(reference.caseCatalogText); }, 'removes cases', commonFirst);
commonBuild('common future positive rejected', state => { append(state); state.catalog.cases.at(-1).expected = true; }, 'sequential negative', commonFirst);
commonBuild('common reference cannot self-authorize', state => { state.texts['workflow-common-reference.json'] = '{}\n'; }, 'Unsupported ordinary content shape', commonFirst);
commonBuild('common candidate remains inert', state => {
  state.validator += "\n(await import('node:fs')).writeFileSync(" + JSON.stringify(path.join(repo, 'P1-SENTINEL')) + ", 'EXECUTED');\n";
}, 'not bounded inert line comments', commonFirst);

const marksPath = path.join(repo, '.git', 'p1-fixture.marks');
git(['fast-import', '--quiet', `--export-marks=${marksPath}`], chunks.join(''));
const marks = new Map(fs.readFileSync(marksPath, 'utf8').trim().split('\n').map(line => line.split(' ')));
const resolve = value => marks.get(value) ?? value;
if (marks.size !== nextMark || [...marks.values()].some(value => !/^[a-f0-9]{40}$/.test(value))) throw new Error('Invalid P1 object identities');
const observedParents = new Map(git(['rev-list', '--parents', '--no-walk=unsorted', ...[...parentsByMark.keys()].map(resolve)])
  .split('\n').map(line => { const [head, ...parents] = line.split(' '); return [head, parents]; }));
for (const [mark, parents] of parentsByMark) {
  if (JSON.stringify(observedParents.get(resolve(mark))) !== JSON.stringify(parents.map(resolve))) throw new Error('P1 fixture parent mismatch');
}
process.stdout.write(JSON.stringify(rows.map(row => ({ ...row, base: resolve(row.base), head: resolve(row.head) }))));
'@
        $strInvalidPreparation = $strIsolationFixtureBuilder.Replace(
            'workflow-ordinary-selftest-reference.json', 'missing-ordinary-selftest-reference.json',
            [StringComparison]::Ordinal)
        if ($strInvalidPreparation -ceq $strIsolationFixtureBuilder) {
            throw 'The P1 preparation failure control has no mutation target.'
        }
        $objInvalidPreparation = Invoke-BoundedProcessByte -FileName 'node' `
            -ArgumentList @('--input-type=module', '-e', $strInvalidPreparation,
                $strSchemaFixtureRoot, $RepositoryRootPath) `
            -MaximumBytes 65536 -TimeoutMilliseconds 60000
        if ($objInvalidPreparation.ExitCode -eq 0 -or $objInvalidPreparation.Bytes.Length -ne 0 -or
            -not $objInvalidPreparation.Error.Contains('missing-ordinary-selftest-reference.json', [StringComparison]::Ordinal)) {
            throw 'A fixture preparation failure was not kept separate from admission.'
        }
        $objIsolationFixtures = Invoke-BoundedProcessByte -FileName 'node' `
            -ArgumentList @('--input-type=module', '-e', $strIsolationFixtureBuilder,
                $strSchemaFixtureRoot, $RepositoryRootPath) `
            -MaximumBytes 65536 -TimeoutMilliseconds 60000
        if ($objIsolationFixtures.ExitCode -ne 0) {
            throw 'Could not build the inert P1 content fixtures.'
        }
        $arrIsolationFixtures = @(ConvertFrom-Json -InputObject (
                ConvertFrom-StrictUtf8Text -Bytes $objIsolationFixtures.Bytes `
                    -Name 'The inert P1 fixture identities'
            ))
        if ($arrIsolationFixtures.Count -ne 89) {
            throw 'The P1 fixture inventory must contain exactly 89 cases.'
        }
        $strIsolationSentinel = Join-Path $strSchemaFixtureRoot 'P1-SENTINEL'
        if ([IO.File]::Exists($strIsolationSentinel)) {
            throw 'The P1 sentinel must be absent before admission.'
        }
        foreach ($objIsolationFixture in $arrIsolationFixtures) {
            $strIsolationFailure = ''
            try {
                Assert-OrdinaryWorkflowPolicyContent `
                    -RepositoryRootPath $strSchemaFixtureRoot `
                    -TrustedRevision $objIsolationFixture.base `
                    -HeadRevision $objIsolationFixture.head
            } catch {
                $strIsolationFailure = $_.Exception.Message
            }
            if (([string]::IsNullOrEmpty($objIsolationFixture.expected) -and
                    -not [string]::IsNullOrEmpty($strIsolationFailure)) -or
                (-not [string]::IsNullOrEmpty($objIsolationFixture.expected) -and
                    -not $strIsolationFailure.Contains(
                        $objIsolationFixture.expected, [StringComparison]::Ordinal))) {
                throw ('P1 fixture failed: ' + $objIsolationFixture.name +
                    '; expected=' + $objIsolationFixture.expected +
                    '; actual=' + $strIsolationFailure)
            }
        }
        if ([IO.File]::Exists($strIsolationSentinel)) {
            throw 'An inert P1 candidate created its execution sentinel.'
        }
    } finally {
        if ([IO.Directory]::Exists($strSchemaFixtureRoot) -and
            $strSchemaFixtureRoot.StartsWith(
                $strSchemaSystemTempRoot,
                [StringComparison]::OrdinalIgnoreCase
            )) {
            Remove-Item -LiteralPath $strSchemaFixtureRoot -Recurse -Force
        }
    }
    return
}

if ($AuthorizationManifestPath -cne $strAuthorizationPath) {
    throw 'The authorization manifest path is not the fixed trusted path.'
}
foreach ($strRevision in @($TrustedRevision, $BaseRevision, $HeadRevision)) {
    if ($strRevision -cnotmatch $strObjectIdPattern) {
        throw "Authorization received an invalid commit ID: $strRevision"
    }
    & git -C $RepositoryRootPath cat-file -e "$strRevision`^{commit}" 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Authorization commit is unavailable: $strRevision"
    }
}
$strCheckedOutRevision = [string] (& git -C $RepositoryRootPath `
        rev-parse --verify 'HEAD^{commit}')
if ($LASTEXITCODE -ne 0 -or $strCheckedOutRevision.Trim() -cne $TrustedRevision) {
    throw 'The checked-out trusted revision does not match the authenticated revision.'
}
if ($AuthorizationApplicabilityOnly) {
    $arrMergeBases = @(
        & git -C $RepositoryRootPath merge-base --all `
            $BaseRevision $HeadRevision 2>$null |
            ForEach-Object { ([string] $_).Trim() }
    )
    if ($LASTEXITCODE -ne 0 -or $arrMergeBases.Count -lt 1 -or
        $arrMergeBases.Count -gt 64 -or
        @($arrMergeBases | Where-Object {
                $_ -cnotmatch $strObjectIdPattern
            }).Count -gt 0) {
        throw 'The authorization applicability merge-base set is indeterminate.'
    }
    $boolTrustRootChanged = $false
    foreach ($strMergeBase in $arrMergeBases) {
        & git -C $RepositoryRootPath diff --quiet --no-ext-diff --no-textconv `
            $strMergeBase $HeadRevision -- @arrTrustRootPaths
        if ($LASTEXITCODE -eq 1) {
            $boolTrustRootChanged = $true
        } elseif ($LASTEXITCODE -ne 0) {
            throw 'Could not inspect trust-root maintenance applicability.'
        }
    }
    Write-Output $boolTrustRootChanged
    return
}
$strManifestEntry = [string] (& git -C $RepositoryRootPath ls-tree `
        $TrustedRevision -- $AuthorizationManifestPath)
if ($LASTEXITCODE -ne 0 -or
    $strManifestEntry -cnotmatch '^100644 blob ([0-9a-f]{40})\t') {
    throw 'The trusted revision authorization manifest is not one regular blob.'
}
$strManifestBlob = $Matches[1]
$arrManifestBytes = @(Read-GitBlobByte -RepositoryRootPath $RepositoryRootPath `
        -BlobId $strManifestBlob -MaximumBytes $intManifestMaximumBytes)
$strManifestText = ConvertFrom-StrictUtf8Text -Bytes $arrManifestBytes `
    -Name 'The trusted authorization manifest'
try {
    $objJsonDocument = [System.Text.Json.JsonDocument]::Parse($strManifestText)
    Assert-NoDuplicateJsonProperty -Element $objJsonDocument.RootElement
    $objManifest = ConvertFrom-Json -InputObject $strManifestText
} catch {
    throw 'The trusted authorization manifest is malformed JSON.'
}
if ($objManifest.schema_version -notin @(1, 2) -or
    [string] $objManifest.authorization_id -cnotmatch
        '^[a-z0-9][a-z0-9-]{0,127}$') {
    throw 'The authorization manifest identity is invalid.'
}
$boolTransitionAuthorization = $objManifest.schema_version -eq 1
$boolContentExactManifestDeactivation = $false
$strHistoryBaseRevision = $BaseRevision
$intEffectiveCommitLimit = $intCandidateMaximumCommits
if ($boolTransitionAuthorization) {
    Assert-ExactPropertySet -InputObject $objManifest `
        -Name 'The transition authorization manifest' `
        -PropertyName @(
            'schema_version', 'authorization_id', 'candidate', 'limits',
            'allowed_paths'
        )
    if ($BaseRevision -ceq $TrustedRevision) {
        throw 'Schema 1 is valid only for the detached-base transition.'
    }
    Assert-ExactPropertySet -InputObject $objManifest.candidate `
        -Name 'The candidate identity' `
        -PropertyName @(
            'base_commit', 'head_commit', 'head_tree', 'parent_commits'
        )
    if ($objManifest.candidate.base_commit -cne $BaseRevision -or
        $objManifest.candidate.head_commit -cne $HeadRevision -or
        [string] $objManifest.candidate.head_tree -cnotmatch
            $strObjectIdPattern) {
        throw 'The event commits do not match the exact transition authorization.'
    }
    $strHeadTree = [string] (& git -C $RepositoryRootPath rev-parse `
            --verify "$HeadRevision`^{tree}")
    if ($LASTEXITCODE -ne 0 -or
        $strHeadTree.Trim() -cne $objManifest.candidate.head_tree) {
        throw 'The candidate tree does not match the exact transition authorization.'
    }
    $arrActualParents = @(
        ([string] (& git -C $RepositoryRootPath rev-list --parents -n 1 `
                    $HeadRevision)).Trim() -split '\s+' |
            Select-Object -Skip 1
    )
    $arrAuthorizedParents = @($objManifest.candidate.parent_commits)
    if ($arrAuthorizedParents.Count -gt 64 -or
        @($arrAuthorizedParents | Where-Object {
                [string] $_ -cnotmatch $strObjectIdPattern
            }).Count -gt 0) {
        throw 'The authorized parent commit list is invalid.'
    }
    if ([string]::Join("`n", $arrActualParents) -cne
        [string]::Join("`n", $arrAuthorizedParents)) {
        throw 'The candidate parents do not match the transition authorization.'
    }
    Assert-ExactPropertySet -InputObject $objManifest.limits `
        -Name 'The transition authorization limits' `
        -PropertyName @(
            'maximum_paths', 'maximum_blob_bytes', 'maximum_manifest_bytes'
        )
} else {
    Assert-ExactPropertySet -InputObject $objManifest `
        -Name 'The content-exact authorization manifest' `
        -PropertyName @(
            'schema_version', 'authorization_id', 'limits', 'allowed_paths'
        )
    Assert-ExactPropertySet -InputObject $objManifest.limits `
        -Name 'The content-exact authorization limits' `
        -PropertyName @(
            'maximum_paths', 'maximum_blob_bytes', 'maximum_manifest_bytes',
            'maximum_commits'
        )
    if ($BaseRevision -cne $TrustedRevision) {
        throw 'The content-exact authorization base must equal the trusted revision.'
    }
    & git -C $RepositoryRootPath merge-base --is-ancestor `
        $TrustedRevision $HeadRevision 2>$null
    if ($LASTEXITCODE -eq 1) {
        throw 'The candidate head does not descend from the trusted revision.'
    }
    if ($LASTEXITCODE -ne 0) {
        throw 'The candidate ancestry is indeterminate.'
    }
    $strCandidateManifestEntry = [string] (& git -C $RepositoryRootPath `
            ls-tree $HeadRevision -- $AuthorizationManifestPath)
    if ($LASTEXITCODE -ne 0 -or
        $strCandidateManifestEntry -cnotmatch '^100644 blob ([0-9a-f]{40})\t') {
        throw 'The candidate authorization manifest is missing or invalid.'
    }
    $boolContentExactManifestDeactivation =
        $strCandidateManifestEntry -cne $strManifestEntry
    if ($objManifest.limits.maximum_commits -gt
        $intCandidateMaximumCommits -or
        $objManifest.limits.maximum_commits -lt 1) {
        throw 'The authorization commit limit exceeds the trusted verifier limit.'
    }
    $intEffectiveCommitLimit = [int] $objManifest.limits.maximum_commits
    $strHistoryBaseRevision = $TrustedRevision
}
if ($objManifest.limits.maximum_paths -gt $intCandidateMaximumPaths -or
    $objManifest.limits.maximum_paths -lt 1 -or
    $objManifest.limits.maximum_blob_bytes -gt $intCandidateMaximumBlobBytes -or
    $objManifest.limits.maximum_blob_bytes -lt 1 -or
    $objManifest.limits.maximum_manifest_bytes -ne $intManifestMaximumBytes) {
    throw 'The authorization limits exceed the trusted verifier limits.'
}
$arrAllowedPaths = @($objManifest.allowed_paths)
if (-not $boolTransitionAuthorization -and $arrAllowedPaths.Count -eq 0) {
    $strInactiveDigest = [Convert]::ToHexString(
        [Security.Cryptography.SHA256]::HashData([byte[]]$arrManifestBytes)
    ).ToLowerInvariant()
    if ($strInactiveDigest -cne
        'd30601d4b8c40672ac9e91414b88a88efcb50a32e168c473a128549fdf2d65f4' -or
        $boolContentExactManifestDeactivation) {
        throw 'Ordinary content requires the unchanged canonical inactive manifest.'
    }
    Assert-OrdinaryWorkflowPolicyContent -RepositoryRootPath $RepositoryRootPath `
        -TrustedRevision $TrustedRevision -HeadRevision $HeadRevision
    Write-Output $true
    return
}
if ($arrAllowedPaths.Count -lt 1 -or
    $arrAllowedPaths.Count -gt $objManifest.limits.maximum_paths) {
    throw 'The authorization path count is outside its limit.'
}
$setAllowedPaths = [Collections.Generic.HashSet[string]]::new(
    [StringComparer]::Ordinal
)
$setAssignedSemanticInvariants = [Collections.Generic.HashSet[string]]::new(
    [StringComparer]::Ordinal
)
$dictionaryWorkflowPolicyTransitionText =
    [Collections.Generic.Dictionary[string, string]]::new(
        [StringComparer]::Ordinal
    )
foreach ($objPath in $arrAllowedPaths) {
    Assert-ExactPropertySet -InputObject $objPath -Name 'An authorized path' `
        -PropertyName @(
            'path', 'mode', 'blob', 'bytes', 'sha256', 'encoding',
            'syntax', 'semantic_invariants'
        )
    $strPath = [string] $objPath.path
    if ([IO.Path]::IsPathRooted($strPath) -or
        $strPath.Contains('\', [StringComparison]::Ordinal) -or
        $strPath -match '(^|/)\.\.?(/|$)' -or
        $strPath.IndexOfAny([char[]] @("`0", "`r", "`n", "`t")) -ge 0 -or
        -not $setAllowedPaths.Add($strPath) -or
        ($strPath -ceq $AuthorizationManifestPath -and
            -not $boolTransitionAuthorization -and
            -not $boolContentExactManifestDeactivation)) {
        throw 'The authorization contains an unsafe, duplicate, or self-authorizing path.'
    }
    if ($objPath.mode -cne '100644' -or
        $objPath.blob -cnotmatch $strObjectIdPattern -or
        $objPath.bytes -lt 0 -or
        $objPath.bytes -gt $objManifest.limits.maximum_blob_bytes -or
        $objPath.sha256 -cnotmatch '^[0-9a-f]{64}$' -or
        $objPath.encoding -cne 'utf-8-no-bom-lf') {
        throw "$strPath has an invalid authorized object contract."
    }
    $strTreeEntry = [string] (& git -C $RepositoryRootPath ls-tree `
            $HeadRevision -- $strPath)
    if ($LASTEXITCODE -ne 0 -or
        $strTreeEntry -cnotmatch '^([0-7]{6}) blob ([0-9a-f]{40})\t(.+)$' -or
        $Matches[1] -cne $objPath.mode -or
        $Matches[2] -cne $objPath.blob -or
        $Matches[3] -cne $strPath) {
        throw "$strPath is missing, linked, deleted, or has a mismatched Git identity."
    }
    $arrBlobBytes = @(Read-GitBlobByte -RepositoryRootPath $RepositoryRootPath `
            -BlobId $objPath.blob `
            -MaximumBytes ($objManifest.limits.maximum_blob_bytes + 1))
    if ($arrBlobBytes.Count -ne $objPath.bytes) {
        throw "$strPath has a mismatched byte count."
    }
    $strSha256 = [Convert]::ToHexString(
        [Security.Cryptography.SHA256]::HashData([byte[]] $arrBlobBytes)
    ).ToLowerInvariant()
    if ($strSha256 -cne $objPath.sha256) {
        throw "$strPath has a mismatched SHA-256 value."
    }
    $strText = ConvertFrom-StrictUtf8Text -Bytes $arrBlobBytes -Name $strPath
    if ($strPath -cin @(
            '.github/workflows/Validate-WorkflowPolicy.mjs',
            '.github/workflows/workflow-policy-contract.json'
        )) {
        $dictionaryWorkflowPolicyTransitionText[$strPath] = $strText
    }
    Assert-CandidateSyntax -Syntax $objPath.syntax -Text $strText -Path $strPath
    $arrInvariants = @($objPath.semantic_invariants)
    $boolTransitionManifestPath =
        ($boolTransitionAuthorization -or
            $boolContentExactManifestDeactivation) -and
        $strPath -ceq $AuthorizationManifestPath
    if (($arrInvariants.Count -lt 1 -and -not $boolTransitionManifestPath) -or
        ($arrInvariants.Count -ne 0 -and $boolTransitionManifestPath) -or
        @($arrInvariants | Where-Object {
                $_ -isnot [string] -or [string]::IsNullOrWhiteSpace($_)
            }).Count -gt 0 -or
        @($arrInvariants | Sort-Object -Unique).Count -ne $arrInvariants.Count) {
        throw "$strPath has missing or duplicate semantic invariants."
    }
    foreach ($strInvariant in $arrInvariants) {
        if (-not $setAssignedSemanticInvariants.Add($strInvariant)) {
            throw "Semantic invariant $strInvariant has multiple consumers."
        }
        Assert-SemanticInvariant -Invariant $strInvariant -Text $strText -Path $strPath
    }
    if ($boolTransitionManifestPath) {
        $objCandidateManifestDocument = $null
        try {
            $objCandidateManifestDocument =
                [System.Text.Json.JsonDocument]::Parse($strText)
            Assert-NoDuplicateJsonProperty `
                -Element $objCandidateManifestDocument.RootElement
            $objCandidateManifest = ConvertFrom-Json -InputObject $strText
            Assert-ExactPropertySet -InputObject $objCandidateManifest `
                -Name 'The landed content-exact authorization manifest' `
                -PropertyName @(
                    'schema_version', 'authorization_id', 'limits',
                    'allowed_paths'
                )
            Assert-ExactPropertySet -InputObject $objCandidateManifest.limits `
                -Name 'The landed content-exact authorization limits' `
                -PropertyName @(
                    'maximum_paths', 'maximum_blob_bytes',
                    'maximum_manifest_bytes', 'maximum_commits'
                )
            if ($objCandidateManifest.schema_version -ne 2 -or
                $objCandidateManifest.authorization_id -cne
                    'no-active-trust-root-maintenance' -or
                $objCandidateManifest.limits.maximum_paths -ne
                    $intInactiveManifestMaximumPaths -or
                $objCandidateManifest.limits.maximum_blob_bytes -ne
                    573440 -or
                $objCandidateManifest.limits.maximum_manifest_bytes -ne
                    $intManifestMaximumBytes -or
                $objCandidateManifest.limits.maximum_commits -ne
                    $intCandidateMaximumCommits -or
                @($objCandidateManifest.allowed_paths).Count -ne 0) {
                throw 'The landed content-exact authorization manifest is active or invalid.'
            }
        } catch {
            throw 'The transition does not land the exact inactive schema 2 manifest.'
        } finally {
            if ($null -ne $objCandidateManifestDocument) {
                $objCandidateManifestDocument.Dispose()
            }
        }
    }
    if ($boolTransitionAuthorization -and $strPath -ceq $strVerifierPath) {
        $strTrustedVerifierEntry = [string] (& git -C $RepositoryRootPath ls-tree `
                $TrustedRevision -- $strVerifierPath)
        if ($LASTEXITCODE -ne 0 -or
            $strTrustedVerifierEntry -cnotmatch '^100644 blob ([0-9a-f]{40})\t' -or
            $Matches[1] -cne $objPath.blob) {
            throw 'The candidate verifier differs from the trusted verifier that authorizes it.'
        }
    }
}
if ($dictionaryWorkflowPolicyTransitionText.Count -ne 2) {
    throw 'The authorization lacks the complete workflow-policy transition tuple.'
}
Assert-WorkflowPolicyTransitionTuple `
    -ValidatorText $dictionaryWorkflowPolicyTransitionText[
        '.github/workflows/Validate-WorkflowPolicy.mjs'
    ] `
    -ContractText $dictionaryWorkflowPolicyTransitionText[
        '.github/workflows/workflow-policy-contract.json'
    ]
$arrSupportedSemanticInvariants = @(
    $script:arrSpecialSemanticInvariant
    $script:hashtableSemanticInvariantPattern.Keys
) | Sort-Object
$arrAssignedSemanticInvariants = @(
    $setAssignedSemanticInvariants
) | Sort-Object
if ([string]::Join("`n", $arrAssignedSemanticInvariants) -cne
    [string]::Join("`n", $arrSupportedSemanticInvariants)) {
    throw 'The authorization must consume every supported semantic invariant exactly once.'
}

$objDiff = Invoke-BoundedProcessByte -FileName 'git' -MaximumBytes 1048576 `
    -ArgumentList @(
        '-C', $RepositoryRootPath, 'diff', '--name-status', '-z', '--no-renames',
        '--no-ext-diff', '--no-textconv', $BaseRevision, $HeadRevision, '--'
    )
if ($objDiff.ExitCode -ne 0) {
    throw 'Could not enumerate the exact candidate path set.'
}
$strDiff = ConvertFrom-StrictUtf8Text -Bytes $objDiff.Bytes `
    -Name 'The candidate path list' -AllowNul
$arrDiffFields = @($strDiff -split "`0" | Where-Object { $_ -cne '' })
if ($arrDiffFields.Count % 2 -ne 0) {
    throw 'The candidate path list is malformed.'
}
$setChangedPaths = [Collections.Generic.HashSet[string]]::new(
    [StringComparer]::Ordinal
)
for ($intIndex = 0; $intIndex -lt $arrDiffFields.Count; $intIndex += 2) {
    if ($arrDiffFields[$intIndex] -cnotin @('A', 'M') -or
        -not $setChangedPaths.Add($arrDiffFields[$intIndex + 1])) {
        throw 'The candidate contains a deleted, renamed, duplicate, or malformed path.'
    }
}
if ($setChangedPaths.Count -lt 1) {
    throw 'The candidate does not change an authorized path.'
}
foreach ($strChangedPath in $setChangedPaths) {
    if (-not $setAllowedPaths.Contains($strChangedPath)) {
        throw "The candidate contains unauthorized path $strChangedPath."
    }
}

$objCommitCount = Invoke-BoundedProcessByte -FileName 'git' -MaximumBytes 64 `
    -ArgumentList @(
        '-C', $RepositoryRootPath, 'rev-list', '--count',
        "--max-count=$($intEffectiveCommitLimit + 1)", $HeadRevision,
        '--not', $strHistoryBaseRevision
    )
$strCommitCount = ConvertFrom-StrictUtf8Text -Bytes $objCommitCount.Bytes `
    -Name 'The candidate history commit count'
if ($objCommitCount.ExitCode -ne 0 -or $strCommitCount.Trim() -cnotmatch '^\d+$' -or
    [int] $strCommitCount.Trim() -gt $intEffectiveCommitLimit) {
    throw 'The complete candidate history exceeds its commit limit.'
}
$objHistory = Invoke-BoundedProcessByte -FileName 'git' -MaximumBytes 1048576 `
    -ArgumentList @(
        '-C', $RepositoryRootPath, 'log', '--format=', '--name-only', '-z',
        '--no-renames', '--no-ext-diff', '--no-textconv',
        '--diff-merges=separate', '--root', $HeadRevision, '--not',
        $strHistoryBaseRevision, '--'
    )
if ($objHistory.ExitCode -ne 0) {
    throw 'Could not enumerate the authorized candidate history.'
}
$strHistory = ConvertFrom-StrictUtf8Text -Bytes $objHistory.Bytes `
    -Name 'The candidate history path list' -AllowNul
$arrHistoryPaths = @(
    $strHistory -split "`0" | Where-Object { $_ -cne '' }
)
foreach ($strHistoryPath in $arrHistoryPaths) {
    if (-not $setAllowedPaths.Contains($strHistoryPath)) {
        throw "The candidate history contains unauthorized path $strHistoryPath."
    }
}

Write-Output $true
