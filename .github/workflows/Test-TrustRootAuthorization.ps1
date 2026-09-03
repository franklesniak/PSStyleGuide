# .SYNOPSIS
# Validates one bounded trust-root maintenance candidate as inert Git data.
# .DESCRIPTION
# Reads the authorization manifest only from the authenticated trusted revision.
# Schema 2 authorizes exact content on a descendant of that revision without an
# unborn commit identity. Schema 1 is retained only for the detached-base
# transition that lands the inactive schema 2 manifest. Candidate blobs are
# decoded and parsed, but never sourced, imported, invoked, built, or executed.
# .PARAMETER RepositoryRootPath
# The trusted repository worktree.
# .PARAMETER TrustedRevision
# The exact checked-out default-branch commit that owns the verifier and manifest.
# .PARAMETER BaseRevision
# The event base. Schema 2 requires this commit to equal TrustedRevision.
# .PARAMETER HeadRevision
# The descendant candidate head, or the exact schema 1 transition head.
# .PARAMETER AuthorizationApplicabilityOnly
# When this switch is set, the script checks only whether the authorization
# applies to the candidate. It returns one Boolean value and does not perform
# the full authorization validation.
# .PARAMETER SelfTest
# Runs focused verifier helper tests and returns before authorization evaluation.
# .PARAMETER AuthorizationManifestPath
# The fixed trusted-revision authorization path.
# .EXAMPLE
# ./Test-TrustRootAuthorization.ps1 @hashtableArguments
#
# # Validates a bounded candidate and writes one Boolean result.
# .INPUTS
# None. This script does not accept pipeline input.
# .OUTPUTS
# [System.Boolean] True only for the exact authorized candidate.
# .NOTES
# Version: 1.2.20260903.0

[CmdletBinding(PositionalBinding = $false)]
[OutputType([bool])]
param(
    [Parameter(Mandatory)][string] $RepositoryRootPath,
    [Parameter(Mandatory)][string] $TrustedRevision,
    [Parameter(Mandatory)][string] $BaseRevision,
    [Parameter(Mandatory)][string] $HeadRevision,
    [Parameter()][switch] $AuthorizationApplicabilityOnly,
    [Parameter()][switch] $SelfTest,
    [Parameter()][string] $AuthorizationManifestPath =
        '.github/workflows/trust-root-authorization.json'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$intManifestMaximumBytes = 65536
$intCandidateMaximumPaths = 16
$intCandidateMaximumBlobBytes = 573440
$intCandidateMaximumCommits = 64
$strObjectIdPattern = '^[0-9a-f]{40}$'
$strAuthorizationPath = '.github/workflows/trust-root-authorization.json'
$strVerifierPath = '.github/workflows/Test-TrustRootAuthorization.ps1'
$arrTrustRootPaths = @(
    '.gitattributes',
    '.github/.gitattributes',
    '.github/workflows/.gitattributes',
    '.github/workflows/Test-TrustRootAuthorization.ps1',
    '.github/workflows/Test-AgentInstructions.SelfTest.ps1',
    '.github/workflows/Test-AgentInstructions.ps1',
    '.github/workflows/Test-AgentInstructionParserManifest.mjs',
    '.github/workflows/Set-AgentInstructionCurrentBaseStatus.mjs',
    '.github/workflows/trust-root-authorization.json',
    '.github/workflows/agent-instruction-current-base.yml',
    '.github/workflows/agent-instructions.yml'
)
$script:arrSpecialSemanticInvariant = @(
    'agent-instruction-heading-status-and-bootstrap-order-is-exact',
    'exact-maintenance-production-call-is-gated',
    'legacy-transition-marker-is-inert-data',
    'package-lock-parser-closure-is-exact',
    'package-parser-roots-are-exact',
    'parser-manifest-direct-roots-and-closure-is-exact',
    'published-path-array-binding-is-explicit',
    'workflow-policy-contract-identities-and-structure-are-exact',
    'workflow-policy-preflight-authenticates-deferred-yaml-import',
    'workflow-created-push-history-fetch-is-bounded',
    'current-base-status-helper-is-fail-closed'
)
$script:hashtableSemanticInvariantPath = @{
    'agent-instruction-heading-status-and-bootstrap-order-is-exact' =
        '.github/workflows/Test-AgentInstructions.ps1'
    'package-lock-parser-closure-is-exact' = 'package-lock.json'
    'package-parser-roots-are-exact' = 'package.json'
    'parser-manifest-direct-roots-and-closure-is-exact' =
        '.github/workflows/Test-AgentInstructionParserManifest.mjs'
    'workflow-policy-contract-identities-and-structure-are-exact' =
        '.github/workflows/workflow-policy-contract.json'
    'workflow-policy-preflight-authenticates-deferred-yaml-import' =
        '.github/workflows/Validate-WorkflowPolicy.mjs'
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
        '(?s)# Version: 1\.2\.\d{8}\.\d+.*Get-CreatedRefBoundaryContext'
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
        '(?s)^(?!.*pull_request_target:)(?!.*artifacts/).*?' +
        'workflow_run:.*?Agent instruction validation.*?requested.*?completed.*?' +
        "workflow_run\.event == 'push'.*?" +
        'group: agent-instruction-current-base-status.*?' +
        'queue: max.*?' +
        'cancel-in-progress: false.*?' +
        'actions: read.*?contents: read.*?pull-requests: read.*?' +
        'statuses: write.*?ref: \$\{\{ github\.sha \}\}.*?' +
        'persist-credentials: false.*?SIGNAL_ACTIVITY: ' +
        '\$\{\{ github\.event\.action \}\}.*?' +
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
    # .DESCRIPTION
    # Starts the requested executable without a shell, captures standard output
    # as bytes, captures bounded error text, and stops on size or time overflow.
    # .PARAMETER FileName
    # The executable name or absolute executable path.
    # .PARAMETER ArgumentList
    # The exact ordered arguments supplied without shell interpolation.
    # .PARAMETER MaximumBytes
    # The positive maximum permitted standard-output byte count.
    # .PARAMETER TimeoutMilliseconds
    # The process time limit in milliseconds.
    # .EXAMPLE
    # Invoke-BoundedProcessByte -FileName 'git' -ArgumentList $arrArgs `
    #     -MaximumBytes 1024
    #
    # # Returns the exit code, output bytes, and bounded error text.
    # .INPUTS
    # None. This helper does not accept pipeline input.
    # .OUTPUTS
    # [System.Management.Automation.PSCustomObject] One bounded process result.
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20260902.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][string] $FileName,
        [Parameter(Mandatory)][string[]] $ArgumentList,
        [Parameter(Mandatory)][ValidateRange(1, 2147483646)][int] $MaximumBytes,
        [Parameter()][ValidateRange(100, 60000)][int] $TimeoutMilliseconds = 10000
    )

    $objStartInfo = [Diagnostics.ProcessStartInfo]::new($FileName)
    $objStartInfo.UseShellExecute = $false
    $objStartInfo.CreateNoWindow = $true
    $objStartInfo.RedirectStandardOutput = $true
    $objStartInfo.RedirectStandardError = $true
    foreach ($strArgument in $ArgumentList) {
        $objStartInfo.ArgumentList.Add($strArgument)
    }
    $objProcess = [Diagnostics.Process]::new()
    $objProcess.StartInfo = $objStartInfo
    if (-not $objProcess.Start()) {
        throw "Could not start $FileName."
    }
    $objMemory = [IO.MemoryStream]::new()
    $arrBuffer = [byte[]]::new(8192)
    $objStopwatch = [Diagnostics.Stopwatch]::StartNew()
    $objErrorTask = $objProcess.StandardError.ReadToEndAsync()
    while ($true) {
        $intRemainingMilliseconds =
            $TimeoutMilliseconds - [int] $objStopwatch.ElapsedMilliseconds
        if ($intRemainingMilliseconds -le 0) {
            $objProcess.Kill($true)
            throw "$FileName exceeded its time limit."
        }
        $objReadTask = $objProcess.StandardOutput.BaseStream.ReadAsync(
            $arrBuffer,
            0,
            $arrBuffer.Length
        )
        $objCompletedTask = [Threading.Tasks.Task]::WhenAny(
            $objReadTask,
            [Threading.Tasks.Task]::Delay($intRemainingMilliseconds)
        ).GetAwaiter().GetResult()
        if (-not [object]::ReferenceEquals($objCompletedTask, $objReadTask)) {
            $objProcess.Kill($true)
            throw "$FileName exceeded its time limit."
        }
        $intRead = $objReadTask.GetAwaiter().GetResult()
        if ($intRead -eq 0) {
            break
        }
        if ($objMemory.Length + $intRead -gt $MaximumBytes) {
            $objProcess.Kill($true)
            throw "$FileName output exceeded $MaximumBytes bytes."
        }
        $objMemory.Write($arrBuffer, 0, $intRead)
    }
    $intRemainingMilliseconds =
        $TimeoutMilliseconds - [int] $objStopwatch.ElapsedMilliseconds
    if ($intRemainingMilliseconds -le 0 -or
        -not $objProcess.WaitForExit($intRemainingMilliseconds)) {
        $objProcess.Kill($true)
        throw "$FileName exceeded its time limit."
    }
    $strError = $objErrorTask.GetAwaiter().GetResult()
    $arrBytes = $objMemory.ToArray()
    if ([Text.Encoding]::UTF8.GetByteCount($strError) -gt 65536) {
        throw "$FileName error output exceeded 65536 bytes."
    }
    return [pscustomobject]@{
        ExitCode = $objProcess.ExitCode
        Bytes = $arrBytes
        Error = $strError
    }
}

function ConvertFrom-StrictUtf8Text {
    # .SYNOPSIS
    # Decodes bytes as strict UTF-8 text.
    # .DESCRIPTION
    # Rejects a byte-order mark, prohibited control bytes, carriage returns,
    # and invalid UTF-8 before returning decoded text.
    # .PARAMETER Bytes
    # The byte sequence to validate and decode. An empty sequence is permitted.
    # .PARAMETER Name
    # The diagnostic name for the byte sequence.
    # .PARAMETER AllowNul
    # Permits NUL separators for bounded Git path-list output.
    # .EXAMPLE
    # ConvertFrom-StrictUtf8Text -Bytes $arrBytes -Name 'manifest'
    #
    # # Returns strict decoded text.
    # .INPUTS
    # None. This helper does not accept pipeline input.
    # .OUTPUTS
    # [System.String] The decoded text.
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20260902.0.
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
    }
    catch {
        throw "$Name is not strict UTF-8."
    }
}

function Read-GitBlobByte {
    # .SYNOPSIS
    # Reads one exact Git blob within a byte limit.
    # .DESCRIPTION
    # Verifies the object size before reading it. A verified zero-byte blob
    # returns an explicit empty byte array without calling the positive-limit
    # process helper.
    # .PARAMETER RepositoryRootPath
    # The repository that contains the blob object.
    # .PARAMETER BlobId
    # The full exact Git blob object ID.
    # .PARAMETER MaximumBytes
    # The maximum permitted blob byte count, including zero.
    # .EXAMPLE
    # Read-GitBlobByte -RepositoryRootPath $strRoot -BlobId $strBlob `
    #     -MaximumBytes 65536
    #
    # # Returns the exact blob bytes.
    # .INPUTS
    # None. This helper does not accept pipeline input.
    # .OUTPUTS
    # [System.Byte] Zero or more bytes from the exact blob.
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20260902.0.
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
    # .DESCRIPTION
    # Walks one parsed JSON element and throws when an object contains the same
    # property name more than once under ordinal comparison.
    # .PARAMETER Element
    # The JSON element to inspect recursively.
    # .EXAMPLE
    # Assert-NoDuplicateJsonProperty -Element $objDocument.RootElement
    #
    # # Returns only when the JSON property inventory is unique.
    # .INPUTS
    # None. This helper does not accept pipeline input.
    # .OUTPUTS
    # None. This helper returns no output.
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20260902.0.
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
    }
    elseif ($Element.ValueKind -eq [System.Text.Json.JsonValueKind]::Array) {
        foreach ($objItem in $Element.EnumerateArray()) {
            Assert-NoDuplicateJsonProperty -Element $objItem
        }
    }
}

function Assert-ExactPropertySet {
    # .SYNOPSIS
    # Requires one object to have an exact property set.
    # .DESCRIPTION
    # Compares actual and expected property names with ordinal values after
    # sorting and throws when a property is missing or unexpected.
    # .PARAMETER InputObject
    # The object whose properties are inspected.
    # .PARAMETER PropertyName
    # The complete expected property-name set.
    # .PARAMETER Name
    # The diagnostic name for the inspected object.
    # .EXAMPLE
    # Assert-ExactPropertySet -InputObject $objValue `
    #     -PropertyName @('a', 'b') -Name 'value'
    #
    # # Returns only when the property set is exact.
    # .INPUTS
    # None. This helper does not accept pipeline input.
    # .OUTPUTS
    # None. This helper returns no output.
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20260902.0.
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
    }
    catch {
        throw "$Name is malformed JSON."
    }
    finally {
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
    # Version: 1.0.20260903.0.
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
        [string]::Join("`n", $arrActual) -cne
            [string]::Join("`n", $arrExpected)) {
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
    # Version: 1.0.20260903.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param([Parameter()][AllowNull()][object] $Value)

    if ($null -eq $Value) {
        return 'null'
    }
    if ($Value -is [Collections.IDictionary]) {
        $arrKeys = [string[]] @($Value.Keys)
        [Array]::Sort($arrKeys, [StringComparer]::Ordinal)
        $arrMembers = foreach ($strKey in $arrKeys) {
            $strEncodedKey = [System.Text.Json.JsonSerializer]::Serialize(
                [object] ([string] $strKey),
                [string],
                $script:objCanonicalJsonOptions
            )
            $strEncodedValue =
                & $script:scriptblockConvertToCanonicalJsonText `
                    -Value $Value[$strKey]
            $strEncodedKey + ':' + $strEncodedValue
        }
        return '{' + [string]::Join(',', [string[]] $arrMembers) + '}'
    }
    if ($Value -is [Collections.IEnumerable] -and
        $Value -isnot [string]) {
        $arrItems = foreach ($objItem in $Value) {
            & $script:scriptblockConvertToCanonicalJsonText -Value $objItem
        }
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
    # .DESCRIPTION
    # Parses PowerShell, JavaScript, YAML, or JSON candidate text with trusted
    # parsers. Markdown is accepted as inert text, and unknown classes fail.
    # .PARAMETER Syntax
    # The declared syntax class: powershell, javascript, yaml, or markdown.
    # .PARAMETER Text
    # The strict UTF-8 candidate text to parse.
    # .PARAMETER Path
    # The repository-relative path used in diagnostics and parser context.
    # .EXAMPLE
    # Assert-CandidateSyntax -Syntax 'powershell' -Text $strText -Path $strPath
    #
    # # Returns only when the declared syntax is valid.
    # .INPUTS
    # None. This helper does not accept pipeline input.
    # .OUTPUTS
    # None. This helper returns no output.
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20260902.0.
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
        }
        catch {
            throw "$Path has invalid JSON syntax."
        }
        finally {
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

function Assert-SemanticInvariant {
    # .SYNOPSIS
    # Validates one named trust-root semantic invariant.
    # .DESCRIPTION
    # Applies the trusted structural or exact-text check for one authorized
    # candidate path and rejects unknown or unsatisfied invariant names.
    # .PARAMETER Invariant
    # The exact trusted semantic-invariant identifier.
    # .PARAMETER Text
    # The strict UTF-8 candidate text to inspect as inert data.
    # .PARAMETER Path
    # The repository-relative path used in failure diagnostics.
    # .EXAMPLE
    # Assert-SemanticInvariant -Invariant $strInvariant `
    #     -Text $strText -Path $strPath
    #
    # # Returns only when the named invariant is satisfied.
    # .INPUTS
    # None. This helper does not accept pipeline input.
    # .OUTPUTS
    # None. This helper returns no output.
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20260902.0.
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)][string] $Invariant,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Text,
        [Parameter(Mandatory)][string] $Path
    )

    if ($script:hashtableSemanticInvariantPath.ContainsKey($Invariant) -and
        $Path -cne $script:hashtableSemanticInvariantPath[$Invariant]) {
        throw "$Path does not satisfy semantic invariant $Invariant."
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
            '$strLockedDependencyInstallCall =',
            '''npm ci --ignore-scripts --no-audit --fund=false''',
            '$strTrustRootAuthorizationCall =',
            '''& ./.github/workflows/Test-TrustRootAuthorization.ps1''',
            '$intLockedDependencyInstall -le $intParserManifestValidation -or',
            '$intTrustRootAuthorization -le $intLockedDependencyInstall',
            '$strUnsafeParserOrderMutation = $strAgentWorkflowContent.Replace(',
            'throw ''An unsafe executable parser validation order did not fail closed.'''
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
            "const VALIDATOR_VERSION = '1.2.2';",
            "const EXPECTED_CONTRACT_CANONICAL_SHA256 = '3b1b0eb57730601de0f2a2673db8bd21230fde25a5f21d78d73c12fda7360679';",
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
                $objContract.validatorIdentity.sha256 -cne
                    '948d54724d9c0374fb2d643d3626be8e23a37b59c7108fe113b3756d953ebcd7') {
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
        }
        catch {
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
        }
        catch {
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
                    }
                    else {
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
                        }
                        else {
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
                        }
                        else {
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
                }
                else {
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
        }
        catch {
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
            }
            else {
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
        if ($arrParseErrors.Count -ne 0 -or
            $Text -cnotmatch $strExplicitCallPattern -or
            $Text -cnotmatch $strHelperValidationPattern -or
            $Text -cmatch
                '(?s)-NewRefBoundaryRevision\s+\$\(' -or
            $Text -cmatch
                '(?s)-NewRefIntroducedCommitRevision\s+\$\(' -or
            $Text -cnotmatch
                'A created ref with no introduced commits reported changed paths\.' -or
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
                'const maximumPullRequests = 20;',
                'const pullRequestPageSize = maximumPullRequests;',
                'const statusContextBatchSize = 10;',
                'const maximumApiRequests = 25;',
                'const maximumOperationMilliseconds = 240000;',
                'const requestTimeoutMilliseconds = 8000;',
                'const maximumResponseBytes = 1048576;',
                'const maximumRequestPathCharacters = 4096;',
                'const openPullRequestsQuery = `query OpenPullRequests(',
                '$owner: String!',
                '$name: String!',
                '$baseRefName: String!',
                '$pageSize: Int!',
                'states: OPEN',
                'baseRefName: $baseRefName',
                'totalCount',
                'baseRepository {',
                'nameWithOwner',
                'headRefOid',
                'pageInfo {',
                'connection.nodes.length === connection.totalCount',
                'connection.pageInfo.hasNextPage === false',
                'Open pull request count exceeds the supported limit of',
                'query: `query ExactStatusContexts(',
                'latest: context(name: $context${index})',
                'targetUrl',
                'const requestBudget = createRequestBudget();',
                'requestBudget.beginRequest();',
                'assertCanMutate(client, invalidations.length);',
                'Agent instruction current base/PR-${pullNumber}',
                'latest.description === `Validated base ${currentBaseSha}.`',
                'Both same-baseline pull requests must be invalidated.',
                'An older workflow-run signal must preserve a newer current success.',
                'Status contexts must be stable and pull-request-specific.',
                'A stale live base must fail finalization.',
                'A requested signal must authenticate its initial live state.',
                'A requested signal must accept an advanced live state.',
                'A completed signal must reconcile completed live state.',
                'A completed signal must reject nonterminal live state.',
                'A forged workflow-run signal must fail authentication.',
                'An unsupported workflow-run activity must fail authentication.',
                'A GitHub.com API request must preserve its encoded query.',
                'A GHES API request must preserve its API base and encoded branch path.',
                'A GitHub.com GraphQL request must resolve relative to its API root.',
                'A GHES GraphQL request must resolve relative to its API root.',
                'resolved.origin === apiRoot.origin',
                'resolved.pathname.startsWith(apiRoot.basePathname)',
                "getEnvironment('GITHUB_GRAPHQL_URL')",
                "requestAtRoot(graphqlApiRoot, 'POST', 'graphql', body)",
                'repos/${client.repository}/pulls/${expected.pullNumber}',
                'repos/${client.repository}/git/ref/heads/${encodeRef(expected.baseRef)}',
                'repos/${repository}/statuses/${headSha}',
                "run.path === '.github/workflows/agent-instructions.yml'",
                'run.head_branch === expected.branch && run.head_sha === expected.signalSha',
                '!Object.hasOwn(result, ''errors'')',
                'GraphQL pull request response is invalid.',
                'GraphQL pull request connection is invalid.',
                'GraphQL pull request response entry is invalid.',
                'The complete one-page GraphQL query variables must remain exact.',
                'A complete one-page read must have no cross-page churn dependency.',
                'The disclosed one-page pull-request limit must be accepted.',
                'The one-page pull-request limit plus one must fail closed.',
                'A partial or paginated pull-request page must fail closed.',
                'A malformed GraphQL connection must fail closed.',
                'A duplicate GraphQL pull request must fail closed.',
                'Status reads must batch only exact PR-specific contexts.',
                'GraphQL status-context response is invalid.',
                'GraphQL status-context response entry is invalid.',
                'A GraphQL status-context error must fail closed.',
                'An exhausted global request budget must fail closed.',
                'A slow request sequence must fail before its deadline is exhausted.',
                'An oversized API response must fail closed.',
                'Base advanced to ${currentBaseSha}; revalidate PR #${pull.number}.',
                'The prerequisite writer must publish one pending exact-base status.',
                'A base edit before prerequisite publication must fail closed.',
                'A live prerequisite mismatch must not write a status.',
                'A base advance after success publication must fail closed.',
                'A finalization race must replace transient success with an error.',
                'A strictly newer authenticated same-endpoint success must be preserved.',
                'An old finalizer must reserve both run reads and preserve newer success.',
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
                'assertCanMutate(client, 3);',
                'The all-write one-page workload must fit its disclosed 25-request bound.',
                'A PR count above the supported limit must fail before any write.',
                "mode === 'start' ? start :",
                'Expected start, finalize, or invalidate mode.'
            )) {
            if (-not $Text.Contains(
                    $strRequiredLiteral,
                    [StringComparison]::Ordinal
                )) {
                throw "$Path does not satisfy semantic invariant $Invariant."
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
            ).Count -ne 3) {
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
    $strSelfTestSystemTempRoot = [IO.Path]::GetFullPath(
        [IO.Path]::GetTempPath()
    )
    $strSelfTestRoot = [IO.Path]::Combine(
        $strSelfTestSystemTempRoot,
        'trust-root-empty-blob-' + [Guid]::NewGuid().ToString('N')
    )
    [void] [IO.Directory]::CreateDirectory($strSelfTestRoot)
    try {
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
        Assert-CandidateSyntax -Syntax 'markdown' -Text $strEmptyText `
            -Path 'empty.md'
        try {
            Assert-SemanticInvariant -Invariant 'docs-status-lifecycle-values' `
                -Text $strEmptyText -Path 'empty.md'
            throw 'An empty governed document passed its content invariant.'
        }
        catch {
            if ($_.Exception.Message -ceq
                'An empty governed document passed its content invariant.' -or
                -not $_.Exception.Message.Contains(
                    'does not satisfy semantic invariant docs-status-lifecycle-values',
                    [StringComparison]::Ordinal
                )) {
                throw
            }
        }
    }
    finally {
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
    }
    catch {
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
    }
    catch {
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
        }
        catch {
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
    }
    catch {
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
        }
        catch {
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
            Path = '.github/workflows/Validate-WorkflowPolicy.mjs'
            Syntax = 'javascript'
            Invariant =
                'workflow-policy-preflight-authenticates-deferred-yaml-import'
            MutationFrom = "const VALIDATOR_VERSION = '1.2.2';"
            MutationTo = "const VALIDATOR_VERSION = '1.2.3';"
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
        $arrInvariantBytes = [IO.File]::ReadAllBytes($strInvariantSourcePath)
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
        $listSchemaAllowedPath = [Collections.Generic.List[object]]::new()
        foreach ($objSchemaPath in $arrSchemaPathSpec) {
            $strSchemaSourcePath = Join-Path $RepositoryRootPath $objSchemaPath.Path
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
            $strSchemaBaselinePath =
                Join-Path $strSchemaFixtureRoot $objSchemaPath.Path
            [void] [IO.Directory]::CreateDirectory(
                [IO.Path]::GetDirectoryName($strSchemaBaselinePath)
            )
            [IO.File]::WriteAllText(
                $strSchemaBaselinePath,
                "baseline placeholder for $($objSchemaPath.Path)`n",
                [Text.UTF8Encoding]::new($false)
            )
        }
        $objSchemaManifest = [ordered]@{
            schema_version = 2
            authorization_id = 'self-test-content-exact'
            limits = [ordered]@{
                maximum_paths = 16
                maximum_blob_bytes = 573440
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
            [IO.File]::Copy(
                (Join-Path $RepositoryRootPath $objSchemaPath.Path),
                (Join-Path $strSchemaFixtureRoot $objSchemaPath.Path),
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
                [Parameter(Mandatory)][string] $Base,
                [Parameter(Mandatory)][string] $Head,
                [Parameter(Mandatory)][string] $ExpectedMessage
            )
            try {
                [void] @(& $PSCommandPath `
                        -RepositoryRootPath $strSchemaFixtureRoot `
                        -TrustedRevision $strSchemaTrusted `
                        -BaseRevision $Base -HeadRevision $Head)
                throw "Schema 2 mutation passed: $ExpectedMessage"
            }
            catch {
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
            -ExpectedMessage 'changed the trusted authorization manifest'

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
            -ExpectedMessage 'changed-path count does not match'

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
            [IO.File]::Copy(
                (Join-Path $RepositoryRootPath $objSchemaPath.Path),
                (Join-Path $strSchemaFixtureRoot $objSchemaPath.Path),
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
                & git -C $strSchemaFixtureRoot update-index --add `
                    --cacheinfo "100644,$strPlaceholderBlob,$($objSchemaPath.Path)"
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
                Join-Path $RepositoryRootPath $strAuthorizationPath
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
                    maximum_paths = 13
                    maximum_blob_bytes = 573440
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
            $strTransitionTrustedTree = ([string] (
                    & git -C $strSchemaFixtureRoot write-tree
                )).Trim()
            $strTransitionTrusted = ([string] (
                    "transition trusted root`n" | git -C $strSchemaFixtureRoot `
                        -c 'user.name=Trust root schema self-test' `
                        -c 'user.email=trust-root-schema@example.invalid' `
                        commit-tree $strTransitionTrustedTree
                )).Trim()
        }
        finally {
            if ([string]::IsNullOrEmpty($strOriginalIndexFile)) {
                Remove-Item -LiteralPath 'Env:GIT_INDEX_FILE' `
                    -ErrorAction SilentlyContinue
            }
            else {
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
        }
        catch {
            if ($_.Exception.Message -ceq
                'A same-base schema 1 authorization was accepted.' -or
                -not $_.Exception.Message.Contains(
                    'Schema 1 is valid only for the detached-base transition',
                    [StringComparison]::Ordinal
                )) {
                throw
            }
        }
    }
    finally {
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
        }
        elseif ($LASTEXITCODE -ne 0) {
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
}
catch {
    throw 'The trusted authorization manifest is malformed JSON.'
}
if ($objManifest.schema_version -notin @(1, 2) -or
    [string] $objManifest.authorization_id -cnotmatch
        '^[a-z0-9][a-z0-9-]{0,127}$') {
    throw 'The authorization manifest identity is invalid.'
}
$boolTransitionAuthorization = $objManifest.schema_version -eq 1
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
}
else {
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
        $strCandidateManifestEntry -cne $strManifestEntry) {
        throw 'The candidate changed the trusted authorization manifest.'
    }
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
            -not $boolTransitionAuthorization)) {
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
    Assert-CandidateSyntax -Syntax $objPath.syntax -Text $strText -Path $strPath
    $arrInvariants = @($objPath.semantic_invariants)
    $boolTransitionManifestPath =
        $boolTransitionAuthorization -and
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
                    $intCandidateMaximumPaths -or
                $objCandidateManifest.limits.maximum_blob_bytes -ne
                    $intCandidateMaximumBlobBytes -or
                $objCandidateManifest.limits.maximum_manifest_bytes -ne
                    $intManifestMaximumBytes -or
                $objCandidateManifest.limits.maximum_commits -ne
                    $intCandidateMaximumCommits -or
                @($objCandidateManifest.allowed_paths).Count -ne 0) {
                throw 'The landed content-exact authorization manifest is active or invalid.'
            }
        }
        catch {
            throw 'The transition does not land the exact inactive schema 2 manifest.'
        }
        finally {
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
if ($setChangedPaths.Count -ne $setAllowedPaths.Count) {
    throw 'The candidate changed-path count does not match the authorization.'
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
