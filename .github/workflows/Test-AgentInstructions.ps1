# .SYNOPSIS
# Validates governed agent instructions and optional authenticated Git ranges.
#
# .PARAMETER RequireStagedInputMatch
# Requires staged validator inputs to match the worktree content being checked.
# Applies only to local validation, including SelfTest; cannot combine revision modes.
#
# .PARAMETER MetadataClassificationOnly
# Validates bounded classification data against exact accepted B/H endpoints.
# Requires checkout B and returns before Markdown dependency/bootstrap work.
# This result is data validation, not merge or owner authority.
#
# .PARAMETER FinalizeMetadataNow
# Checks changed-document metadata against the captured current UTC date at
# deliberate author finalization. Requires exact accepted B/H and checkout B.
# Cannot run with SelfTest or MetadataClassificationOnly. Later ordinary checks
# do not establish the historical finalization date.
#
# .PARAMETER ProposedPolicy
# Runs full B/H transition diagnostics with proposed checker code at H.
# Requires distinct nonzero endpoints and checkout H. This is not accepted
# policy, owner, merge or finalization authority. Cannot combine other modes.
#
# .NOTES
# Positional parameters are not supported.
# Version: 1.23.20261007.0

[CmdletBinding(PositionalBinding = $false)]
[OutputType([string])]
param(
    [Parameter()][switch] $SelfTest,
    [Parameter()][switch] $RequireStagedInputMatch,
    [Parameter()][switch] $MetadataClassificationOnly,
    [Parameter()][switch] $FinalizeMetadataNow,
    [Parameter()][switch] $ProposedPolicy,
    [Parameter()][AllowEmptyString()][string] $InputRevision = '',
    [Parameter()][AllowEmptyString()][string] $PublishedBaselineRevision = ''
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$intAgentsMaximumInputBytes = 32768
$intClaudeMaximumInputBytes = 131072
$intCodexConfigMaximumInputBytes = 65536
$intGitIgnoreMaximumInputBytes = 65536
$intDocsInstructionsMaximumInputBytes = 131072
$intInstructionDocumentMaximumInputBytes = 131072
$intStyleGuideRationaleMaximumInputBytes = 196608
$intGitPathListMaximumBytes = 1048576
$intDocumentClassificationMaximumInputBytes = 32768
$strPythonPrerequisite =
    'Python 3.12 is required to validate .codex/config.toml. On Windows, ' +
    'install the Python launcher for `py -3.12`; otherwise, expose ' +
    '`python3.12`, `python3`, or `python` on PATH.'
$hashtableRuntimeContext = @{
    WindowsPlatform = $IsWindows
    PythonPathNames = @('python3.12', 'python3', 'python')
    PythonCommandContext = $null
    PythonResolutionKey = ''
    NodeApplicationContext = $null
}
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
    '.github/document-metadata-classification.json',
    '.github/workflows/Test-AgentInstructions.SelfTest.ps1',
    '.github/workflows/Test-AgentInstructions.ps1',
    '.github/workflows/workflow-policy-cases.json',
    '.github/workflows/workflow-policy-contract.json',
    '.github/workflows/Validate-WorkflowPolicy.mjs',
    '.github/workflows/build.yml',
    '.github/workflows/markdownlint.yml',
    '.github/workflows/agent-instructions.yml',
    '.github/workflows/copilot-setup-steps.yml',
    '.github/workflows/copilot-code-review.yml',
    '.gitignore',
    '.npmrc',
    'docs/ISSUE_EVALUATION_PROMPT.md',
    'npm-shrinkwrap.json',
    'package-lock.json',
    'package.json',
    'STYLE_GUIDE_RATIONALE.md'
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
    'inspect the outgoing range',
    'each commit and changed path',
    'clean descendant',
    'higher-priority',
    'one authenticated readback',
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
    '.github/instructions/docs.instructions.md'
)
$script:strClaudeImportFailure =
    'CLAUDE.md must not contain active @path imports.'

#region Private helper functions

function ConvertFrom-ParserJsonContext {
    # .SYNOPSIS
    # Decodes bounded parser JSON without coercing timestamp strings.
    #
    # .DESCRIPTION
    # Preserves JSON types for the caller's existing exact shape checks.
    # Rejects nonobject roots, ambiguous properties and excessive input.
    #
    # .PARAMETER Content
    # The exact successful parser output.
    #
    # .PARAMETER MaximumBytes
    # The maximum permitted UTF-8 output size.
    #
    # .PARAMETER UseNativeStructuralConversion
    # Uses the installed-runtime walker for Markdown context only. Name-sensitive
    # objects retain the original PowerShell cast and all its failure behavior.
    #
    # .EXAMPLE
    # ConvertFrom-ParserJsonContext -Content '{"value":"2026-10-02T00:00:00Z"}' -MaximumBytes 4096
    #
    # # Preserves value as the original string.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.Management.Automation.PSCustomObject] Decoded JSON object.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.1.20261006.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Content,
        [Parameter(Mandatory)][ValidateRange(1, 16777216)][int] $MaximumBytes,
        [Parameter()][switch] $UseNativeStructuralConversion
    )

    if ([Text.Encoding]::UTF8.GetByteCount($Content) -gt $MaximumBytes) {
        throw 'The parser returned oversized JSON context.'
    }
    $objOptions = [System.Text.Json.JsonDocumentOptions]@{
        AllowTrailingCommas = $false
        CommentHandling = [System.Text.Json.JsonCommentHandling]::Disallow
        MaxDepth = 64
    }
    $scriptBlockDecode = {
        param([System.Text.Json.JsonElement] $Element)

        switch ($Element.ValueKind) {
            ([System.Text.Json.JsonValueKind]::Object) {
                $hashtableProperties = [ordered]@{}
                foreach ($objProperty in $Element.EnumerateObject()) {
                    if ([string]::IsNullOrEmpty($objProperty.Name) -or
                        $hashtableProperties.Contains($objProperty.Name)) {
                        throw 'The parser returned ambiguous JSON properties.'
                    }
                    $hashtableProperties[$objProperty.Name] =
                        & $scriptBlockDecode -Element $objProperty.Value
                }
                return [pscustomobject]$hashtableProperties
            }
            ([System.Text.Json.JsonValueKind]::Array) {
                $listValues = [Collections.Generic.List[object]]::new()
                foreach ($objElement in $Element.EnumerateArray()) {
                    $listValues.Add((& $scriptBlockDecode -Element $objElement))
                }
                return ,$listValues.ToArray()
            }
            ([System.Text.Json.JsonValueKind]::String) { return $Element.GetString() }
            ([System.Text.Json.JsonValueKind]::Number) {
                $intValue = [int64]0
                if ($Element.TryGetInt64([ref]$intValue)) { return $intValue }
                $doubleValue = $Element.GetDouble()
                if ([double]::IsNaN($doubleValue) -or [double]::IsInfinity($doubleValue)) {
                    throw 'The parser returned an unsupported JSON number.'
                }
                return $doubleValue
            }
            ([System.Text.Json.JsonValueKind]::True) { return $true }
            ([System.Text.Json.JsonValueKind]::False) { return $false }
            ([System.Text.Json.JsonValueKind]::Null) { return $null }
            default { throw 'The parser returned an unsupported JSON type.' }
        }
    }
    $objDocument = $null
    try {
        $objDocument = [System.Text.Json.JsonDocument]::Parse($Content, $objOptions)
        if ($objDocument.RootElement.ValueKind -ne [System.Text.Json.JsonValueKind]::Object) {
            throw 'The parser JSON context root must be an object.'
        }
        if ($UseNativeStructuralConversion) {
            # Only code is retained by the process. Every graph belongs to this call.
            # The payload digest identifies the exact implementation, including on
            # repeated script loads; a same-name type is not accepted on name alone.
            $strNativeTemplate = @'
using System;
using System.Collections.Generic;
using System.Management.Automation;
using System.Text.Json;

namespace StyleGuide.AgentJson {
    public static class StructuralDecoder_IDENTITY_ {
        public const string SourceIdentity = "_IDENTITY_";

        public sealed class Result {
            public readonly int Kind;
            public readonly object Value;
            public Result(int kind, object value) { Kind = kind; Value = value; }
        }

        public static Result DecodeRoot(JsonElement root) {
            int kind = 0;
            object value = Decode(root, ref kind);
            return new Result(kind, kind == 0 ? value : null);
        }

        private static object Decode(JsonElement element, ref int kind) {
            switch (element.ValueKind) {
                case JsonValueKind.Object:
                    var names = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
                    var result = new PSObject();
                    foreach (JsonProperty property in element.EnumerateObject()) {
                        string name = property.Name;
                        if (String.IsNullOrEmpty(name) || !names.Add(name)) {
                            kind = 2;
                            return null;
                        }
                        // Preserve the complete PowerShell cast for these names.
                        // Do not approximate PSTypeName or reserved member behavior.
                        if (String.Equals(name, "PSTypeName", StringComparison.OrdinalIgnoreCase) ||
                            String.Equals(name, "PSObject", StringComparison.OrdinalIgnoreCase) ||
                            String.Equals(name, "PSBase", StringComparison.OrdinalIgnoreCase) ||
                            String.Equals(name, "PSAdapted", StringComparison.OrdinalIgnoreCase) ||
                            String.Equals(name, "PSExtended", StringComparison.OrdinalIgnoreCase) ||
                            String.Equals(name, "PSTypeNames", StringComparison.OrdinalIgnoreCase)) {
                            kind = 1;
                            return null;
                        }
                        object value = Decode(property.Value, ref kind);
                        if (kind != 0) { return null; }
                        result.Properties.Add(new PSNoteProperty(name, value));
                    }
                    return result;
                case JsonValueKind.Array:
                    var values = new object[element.GetArrayLength()];
                    int index = 0;
                    foreach (JsonElement child in element.EnumerateArray()) {
                        values[index++] = Decode(child, ref kind);
                        if (kind != 0) { return null; }
                    }
                    return values;
                case JsonValueKind.String:
                    return element.GetString();
                case JsonValueKind.Number:
                    long integer;
                    if (element.TryGetInt64(out integer)) { return integer; }
                    double number = element.GetDouble();
                    if (Double.IsNaN(number) || Double.IsInfinity(number)) {
                        kind = 3;
                        return null;
                    }
                    return number;
                case JsonValueKind.True:
                    return true;
                case JsonValueKind.False:
                    return false;
                case JsonValueKind.Null:
                    return null;
                default:
                    kind = 4;
                    return null;
            }
        }
    }
}
'@
            $objSourceHash = [Security.Cryptography.SHA256]::Create()
            try {
                $strSourceIdentity = [BitConverter]::ToString(
                    $objSourceHash.ComputeHash([Text.Encoding]::UTF8.GetBytes($strNativeTemplate))
                ).Replace('-', '').ToLowerInvariant()
            } finally {
                $objSourceHash.Dispose()
            }
            $strNativeTypeName = 'StyleGuide.AgentJson.StructuralDecoder' + $strSourceIdentity
            $objNativeType = $strNativeTypeName -as [type]
            if ($null -eq $objNativeType) {
                $strNativeSource = $strNativeTemplate.Replace('_IDENTITY_', $strSourceIdentity)
                $arrCompiledTypes = @(Add-Type -TypeDefinition $strNativeSource -PassThru -ErrorAction Stop)
                $objNativeType = $strNativeTypeName -as [type]
                if ($null -eq $objNativeType -or
                    @($arrCompiledTypes | Where-Object {
                            [object]::ReferenceEquals($_, $objNativeType)
                        }).Count -ne 1) {
                    throw 'The structural JSON converter type could not be verified.'
                }
            }
            $objIdentityField = $objNativeType.GetField('SourceIdentity')
            $objResultType = $objNativeType.GetNestedType('Result')
            $objDecodeMethod = $objNativeType.GetMethod('DecodeRoot', [type[]]@([System.Text.Json.JsonElement]))
            if (-not $objNativeType.IsPublic -or -not $objNativeType.IsAbstract -or
                -not $objNativeType.IsSealed -or $null -eq $objIdentityField -or
                -not $objIdentityField.IsLiteral -or $objIdentityField.FieldType -ne [string] -or
                $objIdentityField.GetRawConstantValue() -cne $strSourceIdentity -or
                $null -eq $objResultType -or $null -eq $objDecodeMethod -or
                -not $objDecodeMethod.IsStatic -or
                -not [object]::ReferenceEquals($objDecodeMethod.DeclaringType, $objNativeType) -or
                -not [object]::ReferenceEquals($objDecodeMethod.ReturnType, $objResultType) -or
                $objNativeType.GetFields([Reflection.BindingFlags]'Static,Public,NonPublic').Count -ne 1) {
                throw 'The structural JSON converter type could not be verified.'
            }
            $objNativeResult = $objDecodeMethod.Invoke($null, [object[]]@($objDocument.RootElement))
            switch ($objNativeResult.Kind) {
                0 { return $objNativeResult.Value }
                1 { break }
                2 { throw 'The parser returned ambiguous JSON properties.' }
                3 { throw 'The parser returned an unsupported JSON number.' }
                4 { throw 'The parser returned an unsupported JSON type.' }
                default { throw 'The structural JSON converter returned an invalid result.' }
            }
        }
        return & $scriptBlockDecode -Element $objDocument.RootElement
    } finally {
        if ($null -ne $objDocument) { $objDocument.Dispose() }
    }
}

function Get-AgentSetupInputSpec {
    # .SYNOPSIS
    # Lists the finite setup inputs admitted by the instruction validator.
    #
    # .DESCRIPTION
    # Keeps the actual setup readers bounded and includes their local executable inputs.
    #
    # .EXAMPLE
    # Get-AgentSetupInputSpec
    #
    # # Returns the supported paths and byte limits.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [pscustomobject] A path, byte limit and explicit optional-presence flag.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; there are no parameters.
    # Version: 1.2.20261007.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param()
    foreach ($arrSpec in @(
            ,@('.github/workflows/agent-instructions.yml', 65536)
            ,@('package.json', 16384)
            ,@('.github/workflows/package.json', 16384)
            ,@('.github/workflows/package-lock.json', 131072)
            ,@('.github/workflows/copilot-setup-steps.yml', 65536)
            ,@('.github/workflows/copilot-code-review.yml', 65536, $true)
            ,@('.github/workflows/lint-staged-markdown.mjs', 32768)
            ,@('.github/workflows/Invoke-LockedPythonHook.ps1', 32768)
            ,@('.github/workflows/install-husky.mjs', 16384)
            ,@('.husky/pre-commit', 16384)
            ,@('.pre-commit-config.yaml', 16384)
            ,@('.gitignore', 65536)
            ,@('.github/workflows/scripts-README.md', 32768)
            ,@('requirements-dev.txt', 16384)
        )) {
        [pscustomobject]@{
            Path = [string]$arrSpec[0]
            MaximumBytes = [int]$arrSpec[1]
            Optional = $arrSpec.Count -eq 3 -and $arrSpec[2] -eq $true
        }
    }
}

function Read-AgentSetupInputContent {
    # .SYNOPSIS
    # Reads the complete setup closure through the existing safe readers.
    #
    # .DESCRIPTION
    # Selects local or immutable revision inputs and checks each staged local read.
    # Required inputs cannot be omitted. Only the dedicated review workflow can
    # be absent from both the selected Git input and local filesystem. Removing
    # it from a committed tree restores the required shared setup fallback.
    # Read, metadata and access failures are never treated as optional absence.
    #
    # .PARAMETER RepositoryRootPath
    # The actual repository root.
    #
    # .PARAMETER Revision
    # The exact input revision, or an empty string for local inputs.
    #
    # .PARAMETER StagedInputPaths
    # The exact ACMR path set, empty when staged matching is not selected.
    #
    # .EXAMPLE
    # Read-AgentSetupInputContent -RepositoryRootPath $strRoot -Revision '' -StagedInputPaths $setPaths
    #
    # # Reads all required setup inputs with the matching byte bounds.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [hashtable] Setup text indexed by repository-relative path.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.1.20261006.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([hashtable])]
    param(
        [Parameter(Mandatory)][string] $RepositoryRootPath,
        [Parameter(Mandatory)][AllowEmptyString()][string] $Revision,
        [Parameter(Mandatory)][AllowEmptyCollection()]
        [Collections.Generic.HashSet[string]] $StagedInputPaths
    )
    $hashtableContent = @{}
    foreach ($objSpec in @(Get-AgentSetupInputSpec)) {
        if ($objSpec.Optional) {
            $strOptionalBlob = Get-GitRegularFileBlobId -RepositoryRootPath $RepositoryRootPath `
                -RepositoryRelativePath $objSpec.Path -Revision $Revision -AllowMissing
            if ([string]::IsNullOrEmpty($strOptionalBlob)) {
                if (-not [string]::IsNullOrEmpty($Revision)) { continue }
                if ($StagedInputPaths.Contains($objSpec.Path)) {
                    throw 'Staged optional setup input is absent from the Git index.'
                }
                try {
                    $null = Get-Item -Force -LiteralPath (Join-Path $RepositoryRootPath $objSpec.Path) `
                        -ErrorAction Stop
                } catch [System.Management.Automation.ItemNotFoundException] {
                    # Only an exact missing item and an empty successful index
                    # lookup permit omission. Present untracked items are read.
                    continue
                }
            }
        }
        $hashtableContent[$objSpec.Path] = if ([string]::IsNullOrEmpty($Revision)) {
            ConvertFrom-StrictUtf8Data -Bytes (Read-RepositoryInputData `
                    -Path (Join-Path $RepositoryRootPath $objSpec.Path) `
                    -RepositoryRootPath $RepositoryRootPath -RepositoryRelativePath $objSpec.Path `
                    -DisplayName $objSpec.Path -MaximumBytes $objSpec.MaximumBytes `
                    -RequireIndexContentMatch:($StagedInputPaths.Contains($objSpec.Path))) `
                -DisplayName $objSpec.Path
        } else {
            Read-GitRevisionText -RepositoryRootPath $RepositoryRootPath -Revision $Revision `
                -RepositoryRelativePath $objSpec.Path -MaximumBytes $objSpec.MaximumBytes -RequireRegularFile
        }
    }
    return $hashtableContent
}

function Get-AgentSetupPackageFailure {
    # .SYNOPSIS
    # Checks the finite package delegation and prepare contracts.
    #
    # .DESCRIPTION
    # Uses the strict JSON decoder and exact string properties, without coercion.
    #
    # .PARAMETER Content
    # The safely read setup content map.
    #
    # .EXAMPLE
    # Get-AgentSetupPackageFailure -Content $hashtableSetup
    #
    # # Emits failures for changed package commands or root lint dependencies.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [string] One record for each invalid setup contract.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param([Parameter(Mandatory)][hashtable] $Content)
    foreach ($strPath in @('package.json', '.github/workflows/package.json')) {
        try {
            $objPackage = ConvertFrom-ParserJsonContext -Content $Content[$strPath] -MaximumBytes 16384
        } catch {
            Write-Output "Setup package must be strict unambiguous JSON: $strPath"
            continue
        }
        $arrScripts = @($objPackage.PSObject.Properties | Where-Object { $_.Name -ceq 'scripts' })
        if ($arrScripts.Count -ne 1 -or $arrScripts[0].Value -isnot [pscustomobject]) {
            Write-Output "Setup package requires an exact scripts object: $strPath"
            continue
        }
        $hashtableExpected = if ($strPath -ceq 'package.json') {
            @{
                'bootstrap:agent-instructions' = 'node .github/workflows/NpmTools.mjs install'
                'lint:md' = 'npm --prefix .github/workflows run lint:md'
                'lint:md:nested' = 'npm --prefix .github/workflows run lint:md:nested'
                'test:agent-instructions' = 'pwsh -NoLogo -NoProfile -NonInteractive -File .github/workflows/Test-AgentInstructions.ps1 -SelfTest'
            }
        } else {
            @{
                'lint:md' = 'node lint-markdown.mjs'
                'lint:md:nested' = 'node lint-nested-markdown.js'
                prepare = 'node install-husky.mjs'
            }
        }
        foreach ($strName in $hashtableExpected.Keys) {
            $arrProperty = @($arrScripts[0].Value.PSObject.Properties | Where-Object { $_.Name -ceq $strName })
            if ($arrProperty.Count -ne 1 -or $arrProperty[0].Value -isnot [string] -or
                $arrProperty[0].Value -cne $hashtableExpected[$strName]) {
                Write-Output "Setup package command must match the reviewed caller: $strPath scripts.$strName"
            }
        }
        if ($strPath -ceq 'package.json') {
            $arrDependencies = @($objPackage.PSObject.Properties | Where-Object { $_.Name -ceq 'devDependencies' })
            if ($arrDependencies.Count -ne 1 -or $arrDependencies[0].Value -isnot [pscustomobject]) {
                Write-Output 'Root package requires an exact devDependencies object.'
            } else {
                foreach ($strForbidden in @('markdownlint', 'markdownlint-cli2')) {
                    if (@($arrDependencies[0].Value.PSObject.Properties | Where-Object {
                                $_.Name -ieq $strForbidden
                            }).Count -ne 0) {
                        Write-Output "Root package must not declare direct $strForbidden."
                    }
                }
            }
        }
    }
}

function Get-AgentBootstrapCommandFailure {
    # .SYNOPSIS
    # Checks the finite operative setup commands in one document.
    #
    # .DESCRIPTION
    # Requires each canonical preflight, install and validation command exactly
    # once in operative prose. Hidden, deleted and duplicate spans do not pass.
    #
    # .PARAMETER Name
    # The document name used in failure diagnostics.
    #
    # .PARAMETER MarkdownContext
    # The actual operative Markdown parser result for the document.
    #
    # .EXAMPLE
    # Get-AgentBootstrapCommandFailure -Name 'AGENTS.md' -MarkdownContext $objMarkdown
    #
    # # Emits no output for a valid document; otherwise emits missing-command diagnostics.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [string] One diagnostic for each command whose operative count is not one.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $Name,
        [Parameter(Mandatory)][psobject] $MarkdownContext
    )

    $strInstall = '-m pip --isolated install --require-hashes --only-binary=:all: --index-url https://pypi.org/simple -r requirements-dev.txt'
    $arrCommands = @(
        "pwsh -NoProfile -Command 'if (`$PSVersionTable.PSVersion.Major -lt 7) { exit 1 }'"
        "py -3.12 $strInstall"
        "python3.12 $strInstall"
        'py -3.12 -m pre_commit run --all-files'
        'python3.12 -m pre_commit run --all-files'
    )
    foreach ($strCommand in $arrCommands) {
        if (@($MarkdownContext.ProseBlocks.Code | Where-Object { $_ -ceq $strCommand }).Count -ne 1) {
            Write-Output "$Name must contain this setup command exactly once: $strCommand"
        }
    }
}

function Get-AgentPreCommitHookContext {
    # .SYNOPSIS
    # Gets actual hooks from the admitted finite pre-commit envelope.
    #
    # .DESCRIPTION
    # Recognizes the reviewed root, repository groups and hooks sequences only.
    # Unknown or duplicate envelope fields and alternate YAML forms fail closed.
    # Hook text in comments or scalar containers cannot become an active hook.
    # LF and CRLF are admitted; alternate YAML line breaks fail before parsing.
    # This finite reader is not a general YAML parser.
    #
    # .PARAMETER Content
    # The safely read bounded pre-commit configuration.
    #
    # .EXAMPLE
    # Get-AgentPreCommitHookContext -Content $strConfig
    #
    # # Returns active hook bodies or a finite-envelope failure.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [pscustomobject] Failure is null for an admitted envelope, otherwise one
    # diagnostic. HookBodies maps each unique admitted ID to its active body.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261007.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param([Parameter(Mandatory)][string] $Content)

    $strNormalizedContent = $Content.Replace("`r`n", "`n")
    if ([regex]::IsMatch($strNormalizedContent, '[\r\u0085\u2028\u2029]')) {
        return [pscustomobject]@{
            Failure = 'Pre-commit accepts only LF or CRLF line endings in the reviewed finite active-hook envelope.'
            HookBodies = @{}
        }
    }
    $arrRepositoryNames = @('local', 'https://github.com/rhysd/actionlint', 'local')
    $hashtableHookGroups = @{
        'check-json' = 0
        'check-yaml' = 0
        'end-of-file-fixer' = 0
        'trailing-whitespace' = 0
        yamllint = 0
        actionlint = 1
        'check-dependabot' = 2
        'check-github-workflows' = 2
        'staged-markdown' = 2
        'workflow-policy-contract' = 2
        'agent-instruction-contract' = 2
    }
    $setHookIds = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $setHookFields = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $hashtableHookBodies = @{}
    $listBodyLines = [Collections.Generic.List[string]]::new()
    $listPendingBlankLines = [Collections.Generic.List[string]]::new()
    $intGroup = -1
    $boolRootSeen = $false
    $boolHooksSeen = $false
    $boolRevisionSeen = $false
    $strHookId = ''
    $strBodyForm = ''
    $strBodyField = ''
    $strFailure = $null
    foreach ($strLine in ($strNormalizedContent -split "`n")) {
        if ($strLine.Contains("`t", [StringComparison]::Ordinal)) {
            $strFailure = 'Pre-commit requires the reviewed finite active-hook envelope.'
            break
        }
        if ([string]::IsNullOrWhiteSpace($strLine)) {
            if ($strBodyForm -ceq 'block' -or $strBodyForm -ceq 'array-block') { $listPendingBlankLines.Add($strLine) }
            continue
        }
        if ($listPendingBlankLines.Count -gt 0) {
            if (($strBodyForm -ceq 'block' -and $strLine.StartsWith('          ', [StringComparison]::Ordinal)) -or
                ($strBodyForm -ceq 'array-block' -and $strLine.StartsWith('            ', [StringComparison]::Ordinal))) {
                foreach ($strBlankLine in $listPendingBlankLines) { $listBodyLines.Add($strBlankLine) }
            }
            $listPendingBlankLines.Clear()
        }
        if ($strLine -cmatch '^ *#') {
            $intScalarIndent = if ($strBodyForm -ceq 'block') { 10 } elseif ($strBodyForm -ceq 'array-block') { 12 } else { 0 }
            if ($intScalarIndent -eq 0 -or -not $strLine.StartsWith((' ' * $intScalarIndent), [StringComparison]::Ordinal)) {
                if ($strBodyForm -ceq 'block') { $strBodyForm = '' }
                if ($strBodyForm -ceq 'array-block') { $strBodyForm = 'array' }
                continue
            }
        }
        if (-not $boolRootSeen) {
            if ($strLine -cne 'repos:') {
                $strFailure = 'Pre-commit requires the reviewed finite active-hook envelope.'
                break
            }
            $boolRootSeen = $true
            continue
        }
        $objRepository = [regex]::Match($strLine, '^  - repo: (?<Name>[^\s]+)$')
        if ($objRepository.Success) {
            if ($intGroup -ge 0 -and (-not $boolHooksSeen -or [string]::IsNullOrEmpty($strHookId) -or
                    ($intGroup -eq 1 -and -not $boolRevisionSeen))) {
                $strFailure = 'Pre-commit requires the reviewed finite active-hook envelope.'
                break
            }
            if (-not [string]::IsNullOrEmpty($strHookId)) {
                $hashtableHookBodies[$strHookId] = $listBodyLines -join "`n"
            }
            $intGroup++
            if ($intGroup -ge $arrRepositoryNames.Count -or
                $objRepository.Groups['Name'].Value -cne $arrRepositoryNames[$intGroup]) {
                $strFailure = 'Pre-commit requires the reviewed finite active-hook envelope.'
                break
            }
            $boolHooksSeen = $false
            $boolRevisionSeen = $false
            $strHookId = ''
            $strBodyForm = ''
            $strBodyField = ''
            $setHookFields.Clear()
            $listBodyLines.Clear()
            $listPendingBlankLines.Clear()
            continue
        }
        if ($intGroup -lt 0) {
            $strFailure = 'Pre-commit requires the reviewed finite active-hook envelope.'
            break
        }
        if ($strLine -ceq '    hooks:') {
            if ($boolHooksSeen -or ($intGroup -eq 1 -and -not $boolRevisionSeen)) {
                $strFailure = 'Pre-commit requires the reviewed finite active-hook envelope.'
                break
            }
            $boolHooksSeen = $true
            continue
        }
        if ($strLine -cmatch '^    rev: "[0-9a-f]{40}"(?: # [^\n]+)?$' -and
            $intGroup -eq 1 -and -not $boolRevisionSeen -and -not $boolHooksSeen) {
            $boolRevisionSeen = $true
            continue
        }
        $objHook = [regex]::Match($strLine, '^      - id: (?<Id>[a-z][a-z0-9-]*)$')
        if ($boolHooksSeen -and $objHook.Success) {
            $strNextId = $objHook.Groups['Id'].Value
            if (-not $hashtableHookGroups.ContainsKey($strNextId) -or
                $hashtableHookGroups[$strNextId] -ne $intGroup -or -not $setHookIds.Add($strNextId)) {
                $strFailure = 'Pre-commit requires the reviewed finite active-hook envelope.'
                break
            }
            if (-not [string]::IsNullOrEmpty($strHookId)) {
                $hashtableHookBodies[$strHookId] = $listBodyLines -join "`n"
            }
            $strHookId = $strNextId
            $strBodyForm = ''
            $strBodyField = ''
            $setHookFields.Clear()
            $listBodyLines.Clear()
            $listPendingBlankLines.Clear()
            continue
        }
        if ($boolHooksSeen -and -not [string]::IsNullOrEmpty($strHookId)) {
            # Admit only the actual one-line fields, block scalars and arrays.
            # Quoted/flow scalars can cross an apparent six-space ID boundary.
            $objField = [regex]::Match($strLine,
                '^        (?<Key>name|entry|language|files|types|stages|minimum_pre_commit_version|args|pass_filenames|always_run):(?<Value>.*)$')
            if ($objField.Success) {
                $strKey = $objField.Groups['Key'].Value
                $strValue = $objField.Groups['Value'].Value
                $boolAdmitted = switch ($strKey) {
                    'name' { $strValue -cmatch '^ [A-Za-z][A-Za-z0-9 ()/-]*$' }
                    'entry' { $strValue -ceq ' >-' -or $strValue -ceq ' node .github/workflows/lint-staged-markdown.mjs' }
                    'language' { $strValue -ceq ' system' }
                    'files' { $strValue -ceq ' >-' -or $strValue -cmatch '^ \^[^\r\n]+$' }
                    'types' { $strValue.Length -eq 0 }
                    'stages' { $strValue.Length -eq 0 }
                    'args' { $strValue.Length -eq 0 }
                    'minimum_pre_commit_version' { $strValue -cmatch '^ "[0-9]+\.[0-9]+\.[0-9]+"$' }
                    'pass_filenames' { $strValue -cmatch '^ (?:true|false)$' }
                    'always_run' { $strValue -cmatch '^ (?:true|false)$' }
                }
                if ($boolAdmitted -and $setHookFields.Add($strKey)) {
                    $strBodyField = $strKey
                    $strBodyForm = if ($strValue -ceq ' >-') { 'block' } elseif (
                        $strKey -cin @('types', 'stages', 'args')) { 'array' } else { '' }
                    $listBodyLines.Add($strLine)
                    continue
                }
            } elseif (($strBodyForm -ceq 'array' -or $strBodyForm -ceq 'array-block') -and
                $strLine -cmatch '^          - (?:[-a-z0-9][a-z0-9.,=_-]*|\|)$') {
                if ($strLine -ceq '          - |' -and $strBodyField -cne 'args') {
                    $strFailure = 'Pre-commit requires the reviewed finite active-hook envelope.'
                    break
                }
                $strBodyForm = if ($strLine -ceq '          - |') { 'array-block' } else { 'array' }
                $listBodyLines.Add($strLine)
                continue
            } elseif (($strBodyForm -ceq 'block' -and $strLine -cmatch '^ {10,}\S') -or
                ($strBodyForm -ceq 'array-block' -and $strLine -cmatch '^ {12,}\S')) {
                $listBodyLines.Add($strLine)
                continue
            }
        }
        $strFailure = 'Pre-commit requires the reviewed finite active-hook envelope.'
        break
    }
    if ($null -eq $strFailure -and (-not $boolRootSeen -or $intGroup -ne 2 -or
            -not $boolHooksSeen -or [string]::IsNullOrEmpty($strHookId) -or
            $setHookIds.Count -ne $hashtableHookGroups.Count)) {
        $strFailure = 'Pre-commit requires the reviewed finite active-hook envelope.'
    }
    if ($null -eq $strFailure) { $hashtableHookBodies[$strHookId] = $listBodyLines -join "`n" }
    return [pscustomobject]@{ Failure = $strFailure; HookBodies = $hashtableHookBodies }
}


function Get-AgentPreCommitBehaviorFailure {
    # .SYNOPSIS
    # Checks complete behavior fields of the eleven reviewed active hooks.
    #
    # .DESCRIPTION
    # Uses trusted literal contracts after the finite envelope is admitted.
    # Field order and benign display names do not change executable behavior.
    # Types and stages are duplicate-free sets; commands, arguments and scalar
    # data retain exact reviewed bytes. This helper does not parse arbitrary YAML.
    #
    # .PARAMETER HookBodies
    # Active bodies returned by a successful Get-AgentPreCommitHookContext call.
    #
    # .EXAMPLE
    # Get-AgentPreCommitBehaviorFailure -HookBodies $objContext.HookBodies
    #
    # # Emits hook-specific failures for missing, extra or changed fields.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [string] One diagnostic for each invalid behavior field.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - Not a public interface.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261007.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param([Parameter(Mandatory)][hashtable] $HookBodies)

    # These values are reviewed source constants, never candidate-derived defaults.
    $hashtableContracts = @{
        'check-json' = @{
            entry = @(
                '        entry: >-'
                '          pwsh -NoLogo -NoProfile -NonInteractive -File'
                '          .github/workflows/Invoke-LockedPythonHook.ps1'
                '          -Module pre_commit_hooks.check_json'
            ) -join "`n"
            language = '        language: system'
            types = @('json')
            files = @(
                '        files: >-'
                '          (?x)^('
                '            package(-lock)?\.json|'
                '            \.github/workflows/[^/]+\.json|'
                '            \.github/document-metadata-classification\.json'
                '          )$'
            ) -join "`n"
        }
        'check-yaml' = @{
            entry = @(
                '        entry: >-'
                '          pwsh -NoLogo -NoProfile -NonInteractive -File'
                '          .github/workflows/Invoke-LockedPythonHook.ps1'
                '          -Module pre_commit_hooks.check_yaml'
            ) -join "`n"
            language = '        language: system'
            types = @('yaml')
            files = '        files: ^.*\.ya?ml$'
        }
        'end-of-file-fixer' = @{
            entry = @(
                '        entry: >-'
                '          pwsh -NoLogo -NoProfile -NonInteractive -File'
                '          .github/workflows/Invoke-LockedPythonHook.ps1'
                '          -Module pre_commit_hooks.end_of_file_fixer'
            ) -join "`n"
            language = '        language: system'
            types = @('text')
            stages = @('pre-commit', 'pre-push', 'manual')
            minimum_pre_commit_version = '        minimum_pre_commit_version: "3.2.0"'
            files = @(
                '        files: >-'
                '          (?x)^('
                '            \.codex/config\.toml|'
                '            .*\.(md|mdc)|'
                '            package(-lock)?\.json|'
                '            \.pre-commit-config\.yaml|'
                '            \.github/actionlint\.yaml|'
                '            \.github/workflows/.*\.(js|mjs|ps1|ya?ml)|'
                '            \.github/document-metadata-classification\.json'
                '          )$'
            ) -join "`n"
        }
        'trailing-whitespace' = @{
            entry = @(
                '        entry: >-'
                '          pwsh -NoLogo -NoProfile -NonInteractive -File'
                '          .github/workflows/Invoke-LockedPythonHook.ps1'
                '          -Module pre_commit_hooks.trailing_whitespace_fixer'
            ) -join "`n"
            language = '        language: system'
            types = @('text')
            stages = @('pre-commit', 'pre-push', 'manual')
            minimum_pre_commit_version = '        minimum_pre_commit_version: "3.2.0"'
            args = @(
                '        args:'
                '          - --markdown-linebreak-ext=md,mdc'
            ) -join "`n"
            files = @(
                '        files: >-'
                '          (?x)^('
                '            \.codex/config\.toml|'
                '            .*\.(md|mdc)|'
                '            package(-lock)?\.json|'
                '            \.pre-commit-config\.yaml|'
                '            \.github/actionlint\.yaml|'
                '            \.github/workflows/.*\.(js|mjs|ps1|ya?ml)|'
                '            \.github/document-metadata-classification\.json'
                '          )$'
            ) -join "`n"
        }
        'yamllint' = @{
            entry = @(
                '        entry: >-'
                '          pwsh -NoLogo -NoProfile -NonInteractive -File'
                '          .github/workflows/Invoke-LockedPythonHook.ps1'
                '          -Module yamllint'
            ) -join "`n"
            language = '        language: system'
            types = @('file', 'yaml')
            args = @(
                '        args:'
                '          - --config-data'
                '          - |'
                '            extends: default'
                '            rules:'
                '              line-length:'
                '                level: warning'
                '              truthy:'
                '                check-keys: false'
            ) -join "`n"
            files = '        files: ^.*\.ya?ml$'
        }
        'actionlint' = @{
            files = '        files: ^\.github/workflows/.*\.ya?ml$'
        }
        'check-dependabot' = @{
            entry = @(
                '        entry: >-'
                '          pwsh -NoLogo -NoProfile -NonInteractive -File'
                '          .github/workflows/Invoke-LockedPythonHook.ps1'
                '          -Module check_jsonschema'
            ) -join "`n"
            language = '        language: system'
            args = @(
                '        args:'
                '          - --builtin-schema'
                '          - vendor.dependabot'
            ) -join "`n"
            types = @('yaml')
            files = '        files: ^\.github/dependabot\.yml$'
        }
        'check-github-workflows' = @{
            entry = @(
                '        entry: >-'
                '          pwsh -NoLogo -NoProfile -NonInteractive -File'
                '          .github/workflows/Invoke-LockedPythonHook.ps1'
                '          -Module check_jsonschema'
            ) -join "`n"
            language = '        language: system'
            args = @(
                '        args:'
                '          - --builtin-schema'
                '          - vendor.github-workflows'
            ) -join "`n"
            types = @('yaml')
            files = '        files: ^\.github/workflows/.*\.ya?ml$'
        }
        'staged-markdown' = @{
            entry = '        entry: node .github/workflows/lint-staged-markdown.mjs'
            language = '        language: system'
            pass_filenames = '        pass_filenames: false'
            files = '        files: ^(\.github/workflows/lint-staged-markdown\.mjs|.*\.(md|mdc))$'
        }
        'workflow-policy-contract' = @{
            entry = @(
                '        entry: >-'
                '          pwsh -NoLogo -NoProfile -NonInteractive'
                '          -WorkingDirectory .github/workflows -Command'
                '          node Validate-WorkflowPolicy.mjs'
                '          build.yml markdownlint.yml'
            ) -join "`n"
            language = '        language: system'
            pass_filenames = '        pass_filenames: false'
            always_run = '        always_run: true'
        }
        'agent-instruction-contract' = @{
            entry = @(
                '        entry: >-'
                '          pwsh -NoLogo -NoProfile -NonInteractive -File'
                '          .github/workflows/Test-AgentInstructions.ps1 -SelfTest -RequireStagedInputMatch'
            ) -join "`n"
            language = '        language: system'
            pass_filenames = '        pass_filenames: false'
            always_run = '        always_run: true'
        }
    }
    foreach ($strId in $hashtableContracts.Keys) {
        if (-not $HookBodies.ContainsKey($strId)) {
            Write-Output "Pre-commit hook must retain its reviewed behavior: $strId (missing body)"
            continue
        }
        $hashtableFields = @{}
        $strField = ''
        foreach ($strLine in ($HookBodies[$strId] -split "`n")) {
            $objField = [regex]::Match($strLine, '^        (?<Key>[a-z_]+):')
            if ($objField.Success) {
                $strField = $objField.Groups['Key'].Value
                $hashtableFields[$strField] = $strLine
            } elseif (-not [string]::IsNullOrEmpty($strField)) {
                $hashtableFields[$strField] += "`n" + $strLine
            }
        }
        $hashtableExpected = $hashtableContracts[$strId]
        foreach ($strKey in $hashtableFields.Keys) {
            # Name grammar is already finite. The instruction guard retains its
            # separate exact body/name check in Get-AgentSetupContractFailure.
            if ($strKey -cne 'name' -and -not $hashtableExpected.ContainsKey($strKey)) {
                Write-Output "Pre-commit hook must retain its reviewed behavior: $strId (extra $strKey)"
            }
        }
        foreach ($strKey in $hashtableExpected.Keys) {
            if (-not $hashtableFields.ContainsKey($strKey)) {
                Write-Output "Pre-commit hook must retain its reviewed behavior: $strId (missing $strKey)"
                continue
            }
            $boolMatches = $false
            if ($strKey -cin @('types', 'stages')) {
                $arrLines = $hashtableFields[$strKey] -split "`n"
                $setValues = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
                $boolMatches = $arrLines[0] -ceq ('        ' + $strKey + ':')
                for ($intIndex = 1; $intIndex -lt $arrLines.Count; $intIndex++) {
                    $objValue = [regex]::Match($arrLines[$intIndex], '^          - (?<Value>[-a-z0-9][a-z0-9.,=_-]*)$')
                    if (-not $objValue.Success -or -not $setValues.Add($objValue.Groups['Value'].Value)) {
                        $boolMatches = $false
                    }
                }
                $boolMatches = $boolMatches -and $setValues.SetEquals([string[]]$hashtableExpected[$strKey])
            } else {
                $boolMatches = $hashtableFields[$strKey] -ceq $hashtableExpected[$strKey]
            }
            if (-not $boolMatches) {
                Write-Output "Pre-commit hook must retain its reviewed behavior: $strId (changed $strKey)"
            }
        }
    }
}


function Get-TrackedCompiledPythonFailure {
    # .SYNOPSIS
    # Rejects compiled Python names in a complete target Git inventory.
    #
    # .DESCRIPTION
    # Checks every decoded target-index or exact target-revision name without
    # filesystem, Git-mode, ignore, metadata or generated-path exemptions.
    # The caller supplies the already bounded and fully validated Git inventory.
    #
    # .PARAMETER TrackedPath
    # The complete target inventory from Read-GitTrackedPath.
    #
    # .EXAMPLE
    # Get-TrackedCompiledPythonFailure -TrackedPath $arrTrackedRepositoryPaths
    #
    # # Emits one corrective diagnostic per forbidden target name.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [string] One diagnostic for each matching tracked name; no output if none.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261007.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param([Parameter(Mandatory)][AllowEmptyCollection()][string[]] $TrackedPath)

    foreach ($strPath in $TrackedPath) {
        if ([regex]::IsMatch($strPath, '(?i)(^|/)__pycache__/|\.py[cod]$')) {
            Write-Output ("Compiled Python artifacts must not be committed: $strPath. " +
                'Remove the tracked artifact; .gitignore does not untrack files.')
        }
    }
}


function Get-AgentSetupContractFailure {
    # .SYNOPSIS
    # Checks the retained local hook, lock and setup contracts.
    #
    # .DESCRIPTION
    # Validates finite actual caller forms and nonprotected bootstrap prose.
    # Lock grammar and module availability do not attest installed package bytes.
    # Protected bootstrap prose retains its separately authorized instruction checks.
    #
    # .PARAMETER Content
    # The complete safely read setup content map.
    #
    # .EXAMPLE
    # Get-AgentSetupContractFailure -Content $hashtableSetup
    #
    # # Emits setup contract violations without installing or executing hooks.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [string] One record for each invalid setup contract.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.3.20261007.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param([Parameter(Mandatory)][hashtable] $Content)
    Get-AgentSetupPackageFailure -Content $Content
    $strHook = $Content['.husky/pre-commit'].Replace("`r`n", "`n")
    $arrHookCommands = @(
        "if git diff --cached --quiet --diff-filter=ACMR -- '*.md' '*.mdc'; then"
        'if node .github/workflows/lint-staged-markdown.mjs; then'
        'if npm --prefix .github/workflows run lint:md; then'
        'if npm --prefix .github/workflows run lint:md:nested; then'
    )
    $intPrevious = -1
    foreach ($strCommand in $arrHookCommands) {
        $arrMatches = @([regex]::Matches($strHook, '(?m)^' + [regex]::Escape($strCommand) + '$'))
        if ($arrMatches.Count -ne 1 -or $arrMatches[0].Index -le $intPrevious) {
            Write-Output "Husky must run each reviewed guard/lint phase once in order: $strCommand"
        } else { $intPrevious = $arrMatches[0].Index }
    }
    $strConfig = $Content['.pre-commit-config.yaml'].Replace("`r`n", "`n")
    $objHookContext = Get-AgentPreCommitHookContext -Content $strConfig
    if ($null -ne $objHookContext.Failure) { Write-Output $objHookContext.Failure }
    if ([regex]::Matches($strConfig, '(?m)^repos:$').Count -ne 1 -or
        $strConfig -cmatch '(?m)^(?!#|repos:$)[^\s]') {
        Write-Output 'Pre-commit must retain only the reviewed root mapping without global selectors or stage overrides.'
    }
    $arrRepositories = @([regex]::Matches($strConfig,
            '(?ms)^  - repo: (?<Name>[^\n]+)\n(?<Body>.*?)(?=^  - repo:|\z)'))
    $arrLocal = @($arrRepositories | Where-Object { $_.Groups['Name'].Value -ceq 'local' })
    $arrRemote = @($arrRepositories | Where-Object { $_.Groups['Name'].Value -cne 'local' })
    if ($arrRepositories.Count -ne 3 -or $arrLocal.Count -ne 2 -or $arrRemote.Count -ne 1) {
        Write-Output 'Pre-commit requires two local groups and one immutable actionlint group.'
    }
    if ($arrRemote.Count -ne 1 -or
        $arrRemote[0].Groups['Name'].Value -cne 'https://github.com/rhysd/actionlint' -or
        [regex]::Matches($arrRemote[0].Groups['Body'].Value, '(?m)^    rev: "[0-9a-f]{40}"(?: # [^\n]+)?$').Count -ne 1 -or
        [regex]::Matches($arrRemote[0].Groups['Body'].Value, '(?m)^      - id: actionlint$').Count -ne 1 -or
        [regex]::Matches($arrRemote[0].Groups['Body'].Value, '(?m)^      - id:').Count -ne 1) {
        Write-Output 'The sole remote hook must be actionlint at a full lowercase commit pin.'
    }
    if ($strConfig -cmatch '(?m)^        (?:language: python(?:\s|$)|additional_dependencies:)') {
        Write-Output 'Python hooks must not resolve a separate dependency environment.'
    }
    $hashtableModules = [ordered]@{
        'check-json' = 'pre_commit_hooks.check_json'
        'check-yaml' = 'pre_commit_hooks.check_yaml'
        'end-of-file-fixer' = 'pre_commit_hooks.end_of_file_fixer'
        'trailing-whitespace' = 'pre_commit_hooks.trailing_whitespace_fixer'
        yamllint = 'yamllint'
        'check-dependabot' = 'check_jsonschema'
        'check-github-workflows' = 'check_jsonschema'
    }
    $hashtableHookBodies = $objHookContext.HookBodies
    if ($null -eq $objHookContext.Failure) {
        Get-AgentPreCommitBehaviorFailure -HookBodies $hashtableHookBodies
    }
    foreach ($strId in @($hashtableModules.Keys) + @('staged-markdown', 'agent-instruction-contract')) {
        if ($null -ne $objHookContext.Failure -or -not $hashtableHookBodies.ContainsKey($strId)) {
            Write-Output "Pre-commit requires one hook definition: $strId"
            $hashtableHookBodies[$strId] = ''
        }
    }
    foreach ($strId in $hashtableModules.Keys) {
        $strBody = $hashtableHookBodies[$strId]
        foreach ($strLine in @(
                '          pwsh -NoLogo -NoProfile -NonInteractive -File'
                '          .github/workflows/Invoke-LockedPythonHook.ps1'
                ('          -Module ' + $hashtableModules[$strId])
                '        language: system'
            )) {
            if ([regex]::Matches($strBody, '(?m)^' + [regex]::Escape($strLine) + '$').Count -ne 1) {
                Write-Output "Python hook must use the reviewed system launcher/module: $strId"
            }
        }
    }
    foreach ($strId in @('check-yaml', 'yamllint')) {
        if ([regex]::Matches($hashtableHookBodies[$strId], '(?m)^' +
                [regex]::Escape('        files: ^.*\.ya?ml$') + '$').Count -ne 1) {
            Write-Output "Hook must select all repository YAML: $strId"
        }
    }
    foreach ($strId in @('check-json', 'end-of-file-fixer', 'trailing-whitespace')) {
        if ([regex]::Matches($hashtableHookBodies[$strId], '(?m)^' +
                [regex]::Escape('            \.github/document-metadata-classification\.json') + '$').Count -ne 1) {
            Write-Output "Hook must select the classification manifest: $strId"
        }
    }
    foreach ($arrRequiredLine in @(
            ,@('staged-markdown', '        entry: node .github/workflows/lint-staged-markdown.mjs')
            ,@('staged-markdown', '        files: ^(\.github/workflows/lint-staged-markdown\.mjs|.*\.(md|mdc))$')
            ,@('agent-instruction-contract', '          pwsh -NoLogo -NoProfile -NonInteractive -File')
            ,@('agent-instruction-contract', '          .github/workflows/Test-AgentInstructions.ps1 -SelfTest -RequireStagedInputMatch')
            ,@('agent-instruction-contract', '        always_run: true')
            ,@('agent-instruction-contract', '        pass_filenames: false')
            ,@('agent-instruction-contract', '        language: system')
        )) {
        if ([regex]::Matches($hashtableHookBodies[$arrRequiredLine[0]],
                '(?m)^' + [regex]::Escape($arrRequiredLine[1]) + '$').Count -ne 1) {
            Write-Output "Hook must retain its reviewed activation and selector: $($arrRequiredLine[0])"
        }
    }
    $strExpectedInstructionHookBody = @(
        '        name: agent instruction contract and mutation tests'
        '        entry: >-'
        '          pwsh -NoLogo -NoProfile -NonInteractive -File'
        '          .github/workflows/Test-AgentInstructions.ps1 -SelfTest -RequireStagedInputMatch'
        '        language: system'
        '        pass_filenames: false'
        '        always_run: true'
    ) -join "`n"
    if ($hashtableHookBodies['agent-instruction-contract'] -cne $strExpectedInstructionHookBody) {
        Write-Output 'Pre-commit requires the exact active always-run instruction guard without extra fields or overrides.'
    }
    $strIgnore = ([string]$Content['.gitignore']).Replace("`r`n", "`n")
    $arrCompiledIgnoreRules = @('*.[pP][yY][cCoOdD]', '!*.[pP][yY][cCoOdD]/',
        '__[pP][yY][cC][aA][cC][hH][eE]__/')
    foreach ($strRequiredIgnoreLine in $arrCompiledIgnoreRules) {
        if ([regex]::Matches($strIgnore, '(?m)^' + [regex]::Escape($strRequiredIgnoreLine) + '$').Count -ne 1) {
            Write-Output "Git ignore must contain one compiled-artifact rule: $strRequiredIgnoreLine"
        }
    }
    # Git uses the last matching rule. Keep this policy suffix after unrelated
    # rules so no later negation or positive pattern can change its behavior.
    $arrOperativeIgnoreRules = @($strIgnore -split "`n" | Where-Object {
            -not [string]::IsNullOrWhiteSpace($_) -and -not $_.StartsWith('#', [StringComparison]::Ordinal)
        })
    $arrExpectedIgnoreSuffix = @($arrCompiledIgnoreRules) + @('CLAUDE.local.md')
    if ($arrOperativeIgnoreRules.Count -lt 4 -or
        ($arrOperativeIgnoreRules[($arrOperativeIgnoreRules.Count - 4)..($arrOperativeIgnoreRules.Count - 1)] -join "`n") -cne
        ($arrExpectedIgnoreSuffix -join "`n")) {
        Write-Output 'Git ignore must end with the reviewed compiled-artifact rules and personal-memory rule.'
    }
    foreach ($strSetupPath in @('.github/workflows/copilot-setup-steps.yml',
            '.github/workflows/copilot-code-review.yml')) {
        if (-not $Content.ContainsKey($strSetupPath)) { continue }
        $strSetup = $Content[$strSetupPath]
        if ($strSetup -match '(?m)^[ \t]+(?:-[ \t]*)?uses[ \t]*:') {
            Write-Output 'Copilot setup must not execute an action.'
        }
        foreach ($strPattern in @(
                '(?m)^[ \t]+(?:GITHUB_TOKEN|GH_TOKEN|ACTIONS_RUNTIME_TOKEN)[ \t]*:'
                '\bgithub\s*\.\s*token\b'
                '\bgithub\s*\['
                '\bsecrets\b'
                '\btojson\s*\(\s*github\s*\)'
            )) {
            if ($strSetup -match $strPattern) {
                Write-Output 'Copilot setup must not project credentials.'
                break
            }
        }
    }
    $strRequirements = $Content['requirements-dev.txt'].Replace("`r`n", "`n").Replace("`r", "`n")
    $strPreamble = "--only-binary=:all:`n--require-hashes`n`n"
    $boolLockValid = $strRequirements.StartsWith($strPreamble, [StringComparison]::Ordinal)
    $strBody = if ($boolLockValid) { $strRequirements.Substring($strPreamble.Length) } else { $strRequirements }
    $arrPackages = @([regex]::Matches($strBody,
            '(?m)^(?<Name>[a-z][a-z0-9-]*)==(?<Version>[^\s\\]+) \\\n' +
            '(?<Hashes>    --hash=sha256:[0-9a-f]{64}(?: \\\n    --hash=sha256:[0-9a-f]{64})*)\n'))
    $setNames = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($objPackage in $arrPackages) {
        $strBody = $strBody.Replace($objPackage.Value, '')
        if (-not $setNames.Add($objPackage.Groups['Name'].Value) -or
            $objPackage.Groups['Version'].Value -cnotmatch '^\d+\.\d+(?:\.\d+)?(?:[a-zA-Z0-9.+-]*)$') {
            $boolLockValid = $false
        }
    }
    foreach ($strRequired in @('pre-commit', 'pre-commit-hooks', 'yamllint', 'check-jsonschema')) {
        if (-not $setNames.Contains($strRequired)) { $boolLockValid = $false }
    }
    if (-not $boolLockValid -or $strBody.Length -ne 0) {
        Write-Output 'Python requirements must have binary/hash flags, unique pinned packages and complete SHA-256 records.'
    }
    $objMarkdown = Get-OperativeMarkdownContext -Content $Content['.github/workflows/scripts-README.md']
    Get-AgentBootstrapCommandFailure -Name 'Script index' -MarkdownContext $objMarkdown
}

function Test-InitialMetadataCoveragePath {
    # .SYNOPSIS
    # Tests exact trusted prior exemption promotion.
    #
    # .DESCRIPTION
    # Uses exact exemptions from a validated existing baseline manifest.
    # Without a trusted manifest, no invalid parent can be waived.
    # Known governed paths cannot become initial coverage.
    #
    # .PARAMETER HasTrustedBaselineManifest
    # True when the trusted baseline already has classification data.
    #
    # .PARAMETER TrustedBaselineExemptPath
    # Exact exemptions read from the validated trusted baseline manifest.
    #
    # .PARAMETER RepositoryRelativePath
    # The exact candidate document path validated by the bounded input reader.
    #
    # .EXAMPLE
    # Test-InitialMetadataCoveragePath @hashtableArguments
    #
    # # Returns true only for a proved previously ungoverned path.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.Boolean] True when the path was outside proved prior coverage.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261002.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][bool] $HasTrustedBaselineManifest,
        [Parameter()][AllowEmptyCollection()][string[]] $TrustedBaselineExemptPath = @(),
        [Parameter(Mandatory)][string] $RepositoryRelativePath
    )

    $arrProvedPriorGovernedPaths = @(
        'AGENTS.md', 'CLAUDE.md', '.github/copilot-instructions.md',
        '.github/instructions/docs.instructions.md', '.github/instructions/yaml.instructions.md',
        'docs/ISSUE_EVALUATION_PROMPT.md', 'STYLE_GUIDE_RATIONALE.md',
        '.github/workflows/MARKDOWN-LINTING-IMPLEMENTATION.md', '.github/workflows/scripts-README.md')
    if ($arrProvedPriorGovernedPaths -ccontains $RepositoryRelativePath -or
        $RepositoryRelativePath -cmatch '^docs/decisions/[0-9]{4}-[a-z0-9]+(?:-[a-z0-9]+)*\.md$') {
        return $false
    }
    if ($HasTrustedBaselineManifest) {
        return $TrustedBaselineExemptPath -ccontains $RepositoryRelativePath
    }
    return $false
}

function ConvertFrom-StrictUtf8Data {
    # .SYNOPSIS
    # Decodes trusted bytes as strict UTF-8 without a byte-order mark.
    #
    # .DESCRIPTION
    # Rejects recognized byte-order marks or malformed UTF-8 before decoding.
    #
    # .PARAMETER Bytes
    # Trusted bytes to decode.
    #
    # .PARAMETER DisplayName
    # Input name for invalid-data diagnostics.
    #
    # .EXAMPLE
    # ConvertFrom-StrictUtf8Data -Bytes ([byte[]] @(0x4F, 0x4B)) `
    #     -DisplayName 'fixture' # Returns System.String 'OK'.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # System.String.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    } catch [System.Text.DecoderFallbackException] {
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
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    } catch [System.IO.InvalidDataException] {
        $strExpectedMessage = "$Name must contain valid UTF-8 without a BOM."
        if ($_.Exception.Message -cne $strExpectedMessage) {
            throw "Self-test '$Name' returned an unexpected failure: $($_.Exception.Message)"
        }
    }
}

function Get-RepositoryInputMetadataFailure {
    # .SYNOPSIS
    # Finds unsafe repository-input metadata.
    #
    # .DESCRIPTION
    # Validates Git index and file-system metadata for one repository input.
    #
    # .PARAMETER DisplayName
    # The trusted label to use in diagnostics.
    #
    # .PARAMETER GitIndexEntryCount
    # The number of exact Git index entries for the path.
    #
    # .PARAMETER GitMode
    # The exact Git mode recorded for the path.
    #
    # .PARAMETER GitStage
    # The Git index stage recorded for the path.
    #
    # .PARAMETER IsFileInfo
    # Indicates whether file-system inspection returned a regular FileInfo object.
    #
    # .PARAMETER Attributes
    # The file-system attributes recorded for the path.
    #
    # .PARAMETER LinkType
    # The file-system link type, when one exists.
    #
    # .PARAMETER UnixMode
    # The Unix file mode recorded for the path.
    #
    # .EXAMPLE
    # Get-RepositoryInputMetadataFailure @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.String] Zero or more validated values or diagnostics described in the function description.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    } elseif (($GitMode -cne '100644') -or ($GitStage -cne '0')) {
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
    #
    # .DESCRIPTION
    # Builds one unsafe metadata fixture and confirms that the metadata validator rejects it with the exact expected diagnostic.
    #
    # .PARAMETER Name
    # The fixture or document name to use in diagnostics.
    #
    # .PARAMETER GitIndexEntryCount
    # The number of exact Git index entries for the path.
    #
    # .PARAMETER GitMode
    # The exact Git mode recorded for the path.
    #
    # .PARAMETER GitStage
    # The Git index stage recorded for the path.
    #
    # .PARAMETER IsFileInfo
    # Indicates whether file-system inspection returned a regular FileInfo object.
    #
    # .PARAMETER Attributes
    # The file-system attributes recorded for the path.
    #
    # .PARAMETER LinkType
    # The file-system link type, when one exists.
    #
    # .PARAMETER UnixMode
    # The Unix file mode recorded for the path.
    #
    # .PARAMETER Failure
    # The exact diagnostic that the fixture must produce.
    #
    # .EXAMPLE
    # Assert-RepositoryInputMetadataMutationRejected @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    #
    # .DESCRIPTION
    # Reads a stream until end-of-stream while enforcing a strict byte cap and cancellation.
    #
    # .PARAMETER Stream
    # The readable stream to consume.
    #
    # .PARAMETER MaximumBytes
    # The maximum permitted output size in bytes.
    #
    # .PARAMETER DisplayName
    # The trusted label to use in diagnostics.
    #
    # .PARAMETER CancellationToken
    # The token that bounds or cancels the read.
    #
    # .EXAMPLE
    # Read-BoundedStreamData @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.Byte] Zero or more bytes read from the stream.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
                } else {
                    $Stream.Read($arrBuffer, 0, $intRemainingBytes)
                }
            } catch [OperationCanceledException] {
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
    } finally {
        $objOutputStream.Dispose()
    }
}

function Read-BoundedProcessData {
    # .SYNOPSIS
    # Reads bounded data from a child process.
    #
    # .DESCRIPTION
    # Starts one shell-free child process, reads its standard output through a strict byte cap, waits through a strict timeout, and always reaps and disposes the process.
    #
    # .PARAMETER Process
    # The configured shell-free process to start.
    #
    # .PARAMETER MaximumBytes
    # The maximum permitted output size in bytes.
    #
    # .PARAMETER TimeoutMilliseconds
    # The maximum elapsed time in milliseconds.
    #
    # .PARAMETER DisplayName
    # The trusted label to use in diagnostics.
    #
    # .PARAMETER RejectStandardError
    # Rejects any stderr output from an application identity probe.
    #
    # .EXAMPLE
    # Read-BoundedProcessData @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.Management.Automation.PSCustomObject] One object with Bytes and ExitCode properties.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.1.20261003.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][Diagnostics.Process] $Process,
        [Parameter(Mandatory)][ValidateRange(1, 2147483646)][int] $MaximumBytes,
        [Parameter(Mandatory)][ValidateRange(1, 60000)][int] $TimeoutMilliseconds,
        [Parameter(Mandatory)][string] $DisplayName,
        [Parameter()][switch] $RejectStandardError
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
        $objErrorTask = if ($RejectStandardError) {
            $Process.StandardError.BaseStream.ReadAsync([byte[]]::new(1), 0, 1)
        } else {
            $Process.StandardError.ReadToEndAsync()
        }
        $arrBytes = Read-BoundedStreamData `
            -Stream $Process.StandardOutput.BaseStream `
            -MaximumBytes $MaximumBytes `
            -DisplayName $DisplayName `
            -CancellationToken $objCancel.Token
        $arrBytes = [byte[]] @($arrBytes)
        $intRemaining = [Math]::Max(
            0, $TimeoutMilliseconds - [int]$objTimer.ElapsedMilliseconds)
        if (-not $Process.WaitForExit($intRemaining)) {
            throw [TimeoutException]::new("$DisplayName timed out.")
        }
        $objStandardError = $objErrorTask.GetAwaiter().GetResult()
        if ($RejectStandardError -and [int]$objStandardError -ne 0) {
            throw "$DisplayName returned unexpected error output."
        }
        return [pscustomobject]@{Bytes = $arrBytes;ExitCode = $Process.ExitCode}
    } catch {
        $objFailure = $_.Exception
        if ($boolRan) {
            if (-not $Process.HasExited) {
                $Process.Kill($true)
            }
            if (-not $Process.WaitForExit(5000)) {
                throw "$DisplayName could not be reaped after failure."
            }
            if ($null -ne $objErrorTask) {
                try {
                    [void]$objErrorTask.GetAwaiter().GetResult()
                } catch {
                    [void]$_
                }
            }
        }
        throw $objFailure
    } finally {
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
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.1.20261005.0
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
        $intRecordStart = $intByteIndex + 1
    }
    # Validate all records before emitting any path from the bounded input.
    $intRecordStart = 0
    for ($intByteIndex = 0; $intByteIndex -lt $Bytes.Length; $intByteIndex++) {
        if ($Bytes[$intByteIndex] -eq 0) {
            ConvertFrom-StrictUtf8Data `
                -Bytes $Bytes[$intRecordStart..($intByteIndex - 1)] `
                -DisplayName 'Git path'
            $intRecordStart = $intByteIndex + 1
        }
    }
}

function Read-GitTrackedPath {
    # .SYNOPSIS
    # Reads a bounded tracked path list from one Git revision.
    #
    # .DESCRIPTION
    # Runs Git against one revision and returns its decoded, NUL-delimited tracked paths.
    #
    # .PARAMETER RepositoryRootPath
    # The absolute path of the trusted Git repository.
    #
    # .PARAMETER Revision
    # The exact Git revision to inspect.
    #
    # .PARAMETER MaximumBytes
    # The maximum permitted output size in bytes.
    #
    # .EXAMPLE
    # Read-GitTrackedPath @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.String] Zero or more validated values or diagnostics described in the function description.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    } else {
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

function Read-GitPublishedEndpointChangedPath {
    # .SYNOPSIS
    # Reads bounded paths changed between the published baseline and final state.
    #
    # .DESCRIPTION
    # Uses exact baseline and final endpoint trees. It does not reconstruct
    # remote publication events or intermediate topic history.
    #
    # .PARAMETER RepositoryRootPath
    # The absolute path of the trusted Git repository.
    #
    # .PARAMETER BaselineRevision
    # The authenticated published baseline commit, or the zero object ID.
    #
    # .PARAMETER FinalRevision
    # The authenticated published final commit.
    #
    # .PARAMETER MaximumBytes
    # The maximum permitted Git path-list output size.
    #
    # .EXAMPLE
    # Read-GitPublishedEndpointChangedPath @hashtableArguments
    #
    # # Returns the paths whose final state differs from the baseline.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [string] Zero or more changed repository-relative paths.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $RepositoryRootPath,
        [Parameter(Mandatory)][AllowEmptyString()][string] $BaselineRevision,
        [Parameter(Mandatory)][string] $FinalRevision,
        [Parameter(Mandatory)][ValidateRange(1, 2147483646)][int] $MaximumBytes
    )

    foreach ($strRevision in @($BaselineRevision, $FinalRevision)) {
        if ($strRevision -cnotmatch '^[0-9a-f]{40}$') {
            throw 'The document comparison requires two full commit hashes.'
        }
    }
    $arrArguments = @('-C', $RepositoryRootPath, 'diff', '--name-only', '-z',
        '--no-renames', '--no-ext-diff', '--no-textconv',
        $BaselineRevision, $FinalRevision, '--', ':(top)**')
    $objStartInfo = [Diagnostics.ProcessStartInfo]::new('git')
    $objStartInfo.UseShellExecute = $false
    $objStartInfo.CreateNoWindow = $true
    $objStartInfo.RedirectStandardOutput = $true
    $objStartInfo.RedirectStandardError = $true
    foreach ($strArgument in $arrArguments) {
        $objStartInfo.ArgumentList.Add($strArgument)
    }
    $objProcess = [Diagnostics.Process]::new()
    $objProcess.StartInfo = $objStartInfo
    $objResult = Read-BoundedProcessData -Process $objProcess `
        -MaximumBytes $MaximumBytes -TimeoutMilliseconds 10000 `
        -DisplayName 'Git published-endpoint path enumeration'
    if ($objResult.ExitCode -ne 0) {
        throw 'Could not enumerate paths changed between published endpoints.'
    }
    $arrPaths = @(ConvertFrom-GitPathListData -Bytes $objResult.Bytes)
    return @($arrPaths | Sort-Object -Unique)
}

function Read-GitStagedInputPath {
    # .SYNOPSIS
    # Reads the bounded staged ACMR path set.
    #
    # .DESCRIPTION
    # Uses NUL Git output and the existing strict path decoder. Native failures,
    # malformed paths, incomplete records and oversized output are rejected.
    #
    # .PARAMETER RepositoryRootPath
    # The absolute path of the trusted Git repository.
    #
    # .PARAMETER MaximumBytes
    # The maximum byte size of the complete path output.
    #
    # .EXAMPLE
    # Read-GitStagedInputPath -RepositoryRootPath $strRoot -MaximumBytes 1048576
    #
    # # Returns exact staged paths without reading their bodies.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [string] Each validated staged path. No output for an empty staged set.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261003.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $RepositoryRootPath,
        [Parameter(Mandatory)][ValidateRange(1, 2147483646)][int] $MaximumBytes
    )
    $objStartInfo = [Diagnostics.ProcessStartInfo]::new('git')
    $objStartInfo.UseShellExecute = $false
    $objStartInfo.CreateNoWindow = $true
    $objStartInfo.RedirectStandardOutput = $true
    $objStartInfo.RedirectStandardError = $true
    foreach ($strArgument in @('-C', $RepositoryRootPath, 'diff', '--cached',
            '--name-only', '--diff-filter=ACMR', '--no-ext-diff', '--no-textconv', '-z', '--')) {
        $objStartInfo.ArgumentList.Add($strArgument)
    }
    $objProcess = [Diagnostics.Process]::new()
    $objProcess.StartInfo = $objStartInfo
    $objResult = Read-BoundedProcessData -Process $objProcess -MaximumBytes $MaximumBytes `
        -TimeoutMilliseconds 10000 -DisplayName 'staged validator input paths'
    if ($objResult.ExitCode -ne 0) { throw 'Could not inspect staged validator input paths.' }
    ConvertFrom-GitPathListData -Bytes $objResult.Bytes
}

function Read-RepositoryInputData {
    # .SYNOPSIS
    # Reads one governed repository file safely.
    #
    # .DESCRIPTION
    # Reads one worktree file only after exact repository metadata validation.
    #
    # .PARAMETER Path
    # The absolute worktree path to read.
    #
    # .PARAMETER RepositoryRootPath
    # The absolute path of the trusted Git repository.
    #
    # .PARAMETER RepositoryRelativePath
    # The canonical repository-relative path to inspect.
    #
    # .PARAMETER DisplayName
    # The trusted label to use in diagnostics.
    #
    # .PARAMETER MaximumBytes
    # The maximum permitted output size in bytes.
    #
    # .PARAMETER RequireIndexContentMatch
    # Requires this staged input to equal its bounded strict UTF-8 index content.
    #
    # .EXAMPLE
    # Read-RepositoryInputData @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.Byte] Zero or more validated bytes described in the function description.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.1.20261003.0
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
        [int] $MaximumBytes,

        [Parameter()][switch] $RequireIndexContentMatch
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

    if ([IO.Path]::IsPathRooted($RepositoryRelativePath) -or
        $RepositoryRelativePath.Contains('\', [StringComparison]::Ordinal) -or
        $RepositoryRelativePath -match '(^|/)\.\.?(/|$)') {
        throw "$DisplayName has an invalid repository-relative input path."
    }
    $strRepositoryRootFullPath = [IO.Path]::GetFullPath(
        $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
            $RepositoryRootPath
        )
    ).TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
    $strResolvedInputPath = [IO.Path]::GetFullPath(
        $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
    )
    $strExpectedInputPath = [IO.Path]::GetFullPath(
        [IO.Path]::Combine(
            $strRepositoryRootFullPath,
            $RepositoryRelativePath.Replace('/', [IO.Path]::DirectorySeparatorChar)
        )
    )
    $objPathComparison = if ([IO.Path]::DirectorySeparatorChar -eq '\') {
        [StringComparison]::OrdinalIgnoreCase
    } else {
        [StringComparison]::Ordinal
    }
    $strRepositoryRootPrefix =
        $strRepositoryRootFullPath + [IO.Path]::DirectorySeparatorChar
    if (-not [string]::Equals(
            $strResolvedInputPath,
            $strExpectedInputPath,
            $objPathComparison
        ) -or
        -not $strResolvedInputPath.StartsWith(
            $strRepositoryRootPrefix,
            $objPathComparison
        )) {
        throw "$DisplayName must resolve to its exact path beneath the repository root."
    }

    $listComponentSnapshots = [Collections.Generic.List[pscustomobject]]::new()
    $strComponentPath = $strRepositoryRootFullPath
    foreach ($strPathComponent in $RepositoryRelativePath.Split('/')) {
        $strComponentPath = [IO.Path]::Combine($strComponentPath, $strPathComponent)
        $objComponentItem = Get-Item -Force -LiteralPath $strComponentPath
        $objComponentLinkTypeProperty =
            $objComponentItem.PSObject.Properties['LinkType']
        $strComponentLinkType = if ($null -eq $objComponentLinkTypeProperty) {
            ''
        } else {
            [string]$objComponentLinkTypeProperty.Value
        }
        if (($objComponentItem.Attributes -band
                [IO.FileAttributes]::ReparsePoint) -ne 0 -or
            -not [string]::IsNullOrEmpty($strComponentLinkType)) {
            throw (
                "$DisplayName has an unsafe linked path component: " +
                "$strPathComponent."
            )
        }
        $listComponentSnapshots.Add([pscustomobject]@{
                Path = $strComponentPath
                Type = $objComponentItem.GetType().FullName
                CreationTimeUtcTicks = $objComponentItem.CreationTimeUtc.Ticks
            })
    }

    $objInputItem = Get-Item -Force -LiteralPath $strResolvedInputPath
    $objLinkTypeProperty = $objInputItem.PSObject.Properties['LinkType']
    $strLinkType = if ($null -eq $objLinkTypeProperty) {
        ''
    } else {
        [string] $objLinkTypeProperty.Value
    }
    $objUnixModeProperty = $objInputItem.PSObject.Properties['UnixMode']
    $strUnixMode = if ($null -eq $objUnixModeProperty) {
        ''
    } else {
        [string] $objUnixModeProperty.Value
    }
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
        $arrInputBytes = [byte[]]@(Read-BoundedStreamData `
            -Stream $objInputStream `
            -MaximumBytes $MaximumBytes `
            -DisplayName $DisplayName)
    } finally {
        $objInputStream.Dispose()
    }
    foreach ($objComponentSnapshot in $listComponentSnapshots) {
        $objComponentItem = Get-Item -Force -LiteralPath $objComponentSnapshot.Path
        $objComponentLinkTypeProperty =
            $objComponentItem.PSObject.Properties['LinkType']
        $strComponentLinkType = if ($null -eq $objComponentLinkTypeProperty) {
            ''
        } else {
            [string]$objComponentLinkTypeProperty.Value
        }
        if (($objComponentItem.Attributes -band
                [IO.FileAttributes]::ReparsePoint) -ne 0 -or
            -not [string]::IsNullOrEmpty($strComponentLinkType) -or
            $objComponentItem.GetType().FullName -cne $objComponentSnapshot.Type -or
            $objComponentItem.CreationTimeUtc.Ticks -ne
                $objComponentSnapshot.CreationTimeUtcTicks) {
            throw "$DisplayName path components changed during the bounded read."
        }
    }
    if ($RequireIndexContentMatch) {
        $strIndexBlob = Get-GitRegularFileBlobId -RepositoryRootPath $RepositoryRootPath `
            -RepositoryRelativePath $RepositoryRelativePath
        $objIndexStartInfo = [Diagnostics.ProcessStartInfo]::new('git')
        $objIndexStartInfo.UseShellExecute = $false
        $objIndexStartInfo.CreateNoWindow = $true
        $objIndexStartInfo.RedirectStandardOutput = $true
        $objIndexStartInfo.RedirectStandardError = $true
        foreach ($strArgument in @('-C', $RepositoryRootPath, 'cat-file', 'blob', $strIndexBlob)) {
            $objIndexStartInfo.ArgumentList.Add($strArgument)
        }
        $objIndexProcess = [Diagnostics.Process]::new()
        $objIndexProcess.StartInfo = $objIndexStartInfo
        $objIndexResult = Read-BoundedProcessData -Process $objIndexProcess `
            -MaximumBytes $MaximumBytes -TimeoutMilliseconds 10000 `
            -DisplayName "staged $DisplayName"
        if ($objIndexResult.ExitCode -ne 0) { throw "Could not read staged $DisplayName." }
        $strWorktreeContent = ConvertFrom-StrictUtf8Data -Bytes $arrInputBytes -DisplayName $DisplayName
        $strIndexContent = ConvertFrom-StrictUtf8Data -Bytes $objIndexResult.Bytes -DisplayName "staged $DisplayName"
        if (-not [string]::Equals($strWorktreeContent, $strIndexContent, [StringComparison]::Ordinal)) {
            throw "$DisplayName worktree content must match its staged Git index blob."
        }
    }
    return $arrInputBytes
}

function Get-GitRegularFileBlobId {
    # .SYNOPSIS
    # Gets one exact regular Git entry identity without reading its content.
    #
    # .DESCRIPTION
    # Uses bounded literal NUL Git metadata. Requires one100644 blob in a
    # revision, or one100644 stage0 index entry for a local candidate.
    # Does not inspect worktree file-system types or open generated bodies.
    # Missing entries fail unless the caller explicitly selects AllowMissing.
    # Native, malformed and nonregular entry failures always throw.
    #
    # .PARAMETER RepositoryRootPath
    # The absolute path of the trusted Git repository.
    #
    # .PARAMETER RepositoryRelativePath
    # The exact ordinal repository-relative path.
    #
    # .PARAMETER Revision
    # The exact Git revision. Empty selects the current index.
    #
    # .PARAMETER AllowMissing
    # Returns no object only for successful empty Git metadata output. The
    # default still requires one regular entry; errors never indicate absence.
    #
    # .EXAMPLE
    # Get-GitRegularFileBlobId @hashtableArguments
    #
    # # Returns a validated blob identity without a content read.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [string] The regular entry's immutable blob identity; no object for an
    # absent entry only when AllowMissing is selected. All other failures throw.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.1.20261006.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $RepositoryRootPath,
        [Parameter(Mandatory)][string] $RepositoryRelativePath,
        [Parameter()][AllowEmptyString()][string] $Revision = '',
        [Parameter()][switch] $AllowMissing
    )

    $longTreeMaximumBytes = [long][Text.Encoding]::UTF8.GetByteCount($RepositoryRelativePath) + 78
    if ($longTreeMaximumBytes -gt 2147483646) {
        throw 'Git revision entry exceeds the supported bounded output size.'
    }
    $objTreeStartInfo = [Diagnostics.ProcessStartInfo]::new('git')
    $objTreeStartInfo.UseShellExecute = $false
    $objTreeStartInfo.CreateNoWindow = $true
    $objTreeStartInfo.RedirectStandardOutput = $true
    $objTreeStartInfo.RedirectStandardError = $true
    $arrEntryArguments = @('--literal-pathspecs', '-C', $RepositoryRootPath)
    if ([string]::IsNullOrEmpty($Revision)) {
        $arrEntryArguments += @('ls-files', '--stage', '-z', '--', $RepositoryRelativePath)
    } else {
        $arrEntryArguments += @('ls-tree', '-z', '--full-tree', $Revision, '--', $RepositoryRelativePath)
    }
    foreach ($strArgument in $arrEntryArguments) {
        $objTreeStartInfo.ArgumentList.Add($strArgument)
    }
    $objTreeProcess = [Diagnostics.Process]::new()
    $objTreeProcess.StartInfo = $objTreeStartInfo
    $objTreeResult = Read-BoundedProcessData -Process $objTreeProcess `
        -MaximumBytes ([int]$longTreeMaximumBytes) -TimeoutMilliseconds 10000 `
        -DisplayName "Git revision entry $Revision`:$RepositoryRelativePath"
    if ($objTreeResult.ExitCode -ne 0) {
        throw "Could not inspect $Revision`:$RepositoryRelativePath in Git."
    }
    if ($AllowMissing -and $objTreeResult.Bytes.Length -eq 0) { return }
    $strTreeRecord = if ($objTreeResult.Bytes.Length -eq 0) { '' } else {
        ConvertFrom-StrictUtf8Data -Bytes $objTreeResult.Bytes -DisplayName 'Git revision entry'
    }
    $strEntryPattern = if ([string]::IsNullOrEmpty($Revision)) {
        '\A100644 (?<ObjectId>[0-9a-fA-F]{40}|[0-9a-fA-F]{64}) 0\t(?<Path>[^\x00]+)\x00\z'
    } else {
        '\A100644 blob (?<ObjectId>[0-9a-fA-F]{40}|[0-9a-fA-F]{64})\t(?<Path>[^\x00]+)\x00\z'
    }
    $objTreeMatch = [regex]::Match($strTreeRecord, $strEntryPattern)
    if (-not $objTreeMatch.Success -or
        -not [string]::Equals($objTreeMatch.Groups['Path'].Value,
            $RepositoryRelativePath, [StringComparison]::Ordinal)) {
        throw "Git revision input is not one regular 100644 blob: $Revision`:$RepositoryRelativePath"
    }
    return $objTreeMatch.Groups['ObjectId'].Value
}

function Read-GitRevisionText {
    # .SYNOPSIS
    # Reads one bounded UTF-8 file from a Git revision.
    #
    # .DESCRIPTION
    # Reads one file from an exact Git revision as strict UTF-8. Required regular
    # files use a bounded NUL-delimited tree record and exact ordinal path.
    #
    # .PARAMETER RepositoryRootPath
    # The absolute path of the trusted Git repository.
    #
    # .PARAMETER Revision
    # The exact Git revision to inspect.
    #
    # .PARAMETER RepositoryRelativePath
    # The canonical repository-relative path to inspect.
    #
    # .PARAMETER MaximumBytes
    # The maximum permitted output size in bytes.
    #
    # .PARAMETER RequireRegularFile
    # Requires the Git object to have a regular-file mode.
    #
    # .EXAMPLE
    # Read-GitRevisionText @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.String] Zero or more validated values or diagnostics described in the function description.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.1.20261005.0
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

    $strBlobObject = "${Revision}:$RepositoryRelativePath"
    if ($RequireRegularFile) {
        $strBlobObject = Get-GitRegularFileBlobId -RepositoryRootPath $RepositoryRootPath `
            -Revision $Revision -RepositoryRelativePath $RepositoryRelativePath
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
            $strBlobObject
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

function Read-PublishedBaselineDocumentText {
    # .SYNOPSIS
    # Reads complete historical metadata without relaxing current input limits.
    #
    # .DESCRIPTION
    # Historical AGENTS metadata supports the prior 65536-byte reader. This
    # private parent-only path never supplies current instruction admission.
    # Other documents retain their current bounded read limits.
    #
    # .PARAMETER RepositoryRootPath
    # The absolute path of the repository containing the baseline Git object.
    #
    # .PARAMETER Revision
    # The published parent revision selected by the existing role checks.
    #
    # .PARAMETER RepositoryRelativePath
    # The exact ordinal repository-relative document path.
    #
    # .PARAMETER CurrentMaximumBytes
    # The current document read limit, retained for all other parent paths.
    #
    # .EXAMPLE
    # Read-PublishedBaselineDocumentText @hashtableArguments
    #
    # # Reads only a metadata parent through the regular strict UTF-8 reader.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [string] The complete historical document.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Positional parameters are disabled; callers use named arguments.
    # Version: 1.0.20261005.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $RepositoryRootPath,
        [Parameter(Mandatory)][string] $Revision,
        [Parameter(Mandatory)][string] $RepositoryRelativePath,
        [Parameter(Mandatory)]
        [ValidateRange(1, 2147483646)]
        [int] $CurrentMaximumBytes
    )

    $intParentMaximumBytes = if ($RepositoryRelativePath -ceq 'AGENTS.md') {
        65536
    } else {
        $CurrentMaximumBytes
    }
    return Read-GitRevisionText -RepositoryRootPath $RepositoryRootPath `
        -Revision $Revision -RepositoryRelativePath $RepositoryRelativePath `
        -MaximumBytes $intParentMaximumBytes -RequireRegularFile
}

function Get-PublishedBaselineDocumentContext {
    # .SYNOPSIS
    # Gets the local HEAD baseline for one governed worktree document.
    #
    # .DESCRIPTION
    # Reads the published local baseline from HEAD and reports whether the
    # worktree content differs from it.
    #
    # .PARAMETER RepositoryRootPath
    # The absolute path of the trusted Git repository.
    #
    # .PARAMETER RepositoryRelativePath
    # The canonical repository-relative path to inspect.
    #
    # .PARAMETER MaximumBytes
    # The maximum permitted output size in bytes.
    #
    # .EXAMPLE
    # Get-PublishedBaselineDocumentContext @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.Management.Automation.PSCustomObject] One validated context object described in the function description.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [string] $RepositoryRootPath,

        [Parameter(Mandatory)]
        [string] $RepositoryRelativePath,

        [Parameter(Mandatory)]
        [ValidateRange(1, 2147483646)]
        [int] $MaximumBytes
    )

    & git -C $RepositoryRootPath diff --quiet HEAD -- $RepositoryRelativePath
    $intDiffExitCode = $LASTEXITCODE
    if ($intDiffExitCode -notin @(0, 1)) {
        throw "Could not compare $RepositoryRelativePath with HEAD."
    }

    $strParentRevision = 'HEAD'
    $strExpectedUtcDate = if ($intDiffExitCode -eq 1) {
        [DateTimeOffset]::UtcNow.ToString('yyyy-MM-dd')
    } else {
        ''
    }

    & git -C $RepositoryRootPath cat-file -e `
        "$strParentRevision`:$RepositoryRelativePath" 2>$null
    $strParentContent = if ($LASTEXITCODE -eq 0) {
        Read-PublishedBaselineDocumentText `
            -RepositoryRootPath $RepositoryRootPath `
            -Revision $strParentRevision `
            -RepositoryRelativePath $RepositoryRelativePath `
            -CurrentMaximumBytes $MaximumBytes
    } else {
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
    #
    # .DESCRIPTION
    # Exercises oversized stream and child-process fixtures.
    #
    # .EXAMPLE
    # Assert-OversizedStreamMutationRejected
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    } catch [System.IO.InvalidDataException] {
        $strExpectedMessage = 'oversized stream mutation must not exceed 4 bytes.'
        if ($_.Exception.Message -cne $strExpectedMessage) {
            throw "Self-test 'oversized stream mutation' returned an unexpected failure: $($_.Exception.Message)"
        }
    } finally {
        $objOversizedStream.Dispose()
    }

    $objEmptyStartInfo = [Diagnostics.ProcessStartInfo]::new(
        [Environment]::ProcessPath
    )
    $objEmptyStartInfo.UseShellExecute = $false
    $objEmptyStartInfo.CreateNoWindow = $true
    $objEmptyStartInfo.RedirectStandardOutput = $true
    $objEmptyStartInfo.RedirectStandardError = $true
    foreach ($strArgument in @(
            '-NoLogo', '-NoProfile', '-NonInteractive', '-Command', 'exit 0'
        )) {
        $objEmptyStartInfo.ArgumentList.Add($strArgument)
    }
    $objEmptyProcess = [Diagnostics.Process]::new()
    $objEmptyProcess.StartInfo = $objEmptyStartInfo
    $objEmptyResult = Read-BoundedProcessData `
        -Process $objEmptyProcess `
        -MaximumBytes 4 `
        -TimeoutMilliseconds 5000 `
        -DisplayName 'successful zero-output process read'
    if ($null -eq $objEmptyResult.Bytes -or
        -not ($objEmptyResult.Bytes -is [byte[]]) -or
        $objEmptyResult.Bytes.Length -ne 0 -or
        $objEmptyResult.ExitCode -ne 0) {
        throw "Self-test 'successful zero-output process read' changed output."
    }

    $arrProcessCases = @(
        @{N = 'stalled process read';C = 'Start-Sleep -Seconds 5';T = 250;E = [TimeoutException]},
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
        } catch {
            if ($null -eq $objProcessCase.E -or
                -not $objProcessCase.E.IsAssignableFrom($_.Exception.GetType())) {
                throw
            }
        } finally {
            $objTimer.Stop()
        }
        if ($objTimer.ElapsedMilliseconds -ge 4000) {
            throw "Self-test '$($objProcessCase.N)' exceeded its cleanup deadline."
        }
    }
}

function Assert-MarkdownParserTransportCleanup {
    # .SYNOPSIS
    # Confirms that failed Markdown parser processes are cleaned up.
    #
    # .DESCRIPTION
    # Exercises timeout and transport failures in the locked Markdown parser.
    #
    # .EXAMPLE
    # Assert-MarkdownParserTransportCleanup
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param()

    $strPidPath = [IO.Path]::GetTempFileName()
    try {
        $objNodeCommand = Get-Command node -CommandType Application |
            Select-Object -First 1
        $objStartInfo = [Diagnostics.ProcessStartInfo]::new(
            $objNodeCommand.Source
        )
        $objStartInfo.UseShellExecute = $false
        $objStartInfo.CreateNoWindow = $true
        $objStartInfo.RedirectStandardInput = $true
        $objStartInfo.RedirectStandardOutput = $true
        $objStartInfo.RedirectStandardError = $true
        $objStartInfo.StandardInputEncoding = [Text.UTF8Encoding]::new($false)
        $objStartInfo.StandardOutputEncoding = [Text.UTF8Encoding]::new($false)
        $objStartInfo.StandardErrorEncoding = [Text.UTF8Encoding]::new($false)
        foreach ($strArgument in @(
                '-e',
                'const fs = require("node:fs"); fs.appendFileSync(process.argv[1], process.pid + "\n"); setTimeout(() => process.exit(23), 100);',
                $strPidPath
            )) {
            $objStartInfo.ArgumentList.Add($strArgument)
        }

        $strSentinel = 'governed-content-must-not-appear-in-transport-evidence'
        $objTimer = [Diagnostics.Stopwatch]::StartNew()
        try {
            [void](Invoke-MarkdownParserProcess `
                    -StartInfo $objStartInfo `
                    -Content ($strSentinel + ('x' * 1048576)))
            throw "Self-test 'premature parser input close' was accepted."
        } catch [IO.IOException] {
            if (-not $_.Exception.Message.Contains(
                    'input closed prematurely after 2 attempts',
                    [StringComparison]::Ordinal
                ) -or
                ([regex]::Matches(
                        $_.Exception.Message,
                        'premature-input-close, exit=23, stderr=empty'
                    )).Count -ne 2 -or
                $_.Exception.Message.Contains(
                    $strSentinel,
                    [StringComparison]::Ordinal
                )) {
                throw (
                    "Self-test 'premature parser input close' changed classification: " +
                        $_.Exception.Message
                )
            }
        } finally {
            $objTimer.Stop()
        }
        if ($objTimer.ElapsedMilliseconds -ge 5000) {
            throw "Self-test 'premature parser input close' exceeded its cleanup deadline."
        }

        $arrParserPids = @(
            [IO.File]::ReadAllLines($strPidPath) |
                ForEach-Object { [int]$_ }
        )
        if ($arrParserPids.Count -ne 2) {
            throw "Self-test 'premature parser input close' changed attempt count."
        }
        foreach ($intParserPid in $arrParserPids) {
            $objParserProcess = $null
            try {
                $objParserProcess = [Diagnostics.Process]::GetProcessById($intParserPid)
                if (-not $objParserProcess.HasExited) {
                    throw "Self-test 'premature parser input close' left a child running."
                }
            } catch [ArgumentException] {
                [void]$_
            } finally {
                if ($null -ne $objParserProcess) {
                    $objParserProcess.Dispose()
                }
            }
        }
    } finally {
        Remove-Item -LiteralPath $strPidPath -Force -ErrorAction SilentlyContinue
    }
}

function Test-Python312Application {
    # .SYNOPSIS
    # Tests one isolated Python application for the exact supported version.
    #
    # .DESCRIPTION
    # Uses the bounded process reader and returns false on unavailable, noisy,
    # oversized, timed-out or incompatible applications.
    #
    # .PARAMETER Path
    # The application path to probe.
    #
    # .PARAMETER PrefixArgument
    # Launcher arguments that precede the isolated probe.
    #
    # .EXAMPLE
    # Test-Python312Application -Path '/usr/bin/python3.12'
    #
    # # Returns true only for an exact Python 3.12 application.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [bool] True for Python 3.12; false for all probe failures.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261003.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][string] $Path,
        [Parameter()][string[]] $PrefixArgument = @()
    )
    $objStartInfo = [Diagnostics.ProcessStartInfo]::new($Path)
    $objStartInfo.UseShellExecute = $false
    $objStartInfo.CreateNoWindow = $true
    $objStartInfo.RedirectStandardOutput = $true
    $objStartInfo.RedirectStandardError = $true
    foreach ($strArgument in @($PrefixArgument) + @('-I', '-S', '-c',
            'import sys;sys.stdout.write("3.12" if sys.version_info[:2]==(3,12) else "")')) {
        $objStartInfo.ArgumentList.Add($strArgument)
    }
    $objProcess = [Diagnostics.Process]::new()
    $objProcess.StartInfo = $objStartInfo
    try {
        $objResult = Read-BoundedProcessData -Process $objProcess -MaximumBytes 4 `
            -TimeoutMilliseconds 5000 -DisplayName 'Python 3.12 prerequisite probe' `
            -RejectStandardError
        return $objResult.ExitCode -eq 0 -and
            [Text.Encoding]::UTF8.GetString($objResult.Bytes) -ceq '3.12'
    } catch {
        Write-Debug 'The Python application did not complete the isolated version probe.'
        return $false
    }
}

function Get-Python312CommandContext {
    # .SYNOPSIS
    # Resolves and caches an exact Python 3.12 application.
    #
    # .DESCRIPTION
    # Tries the Windows launcher and supported PATH names in order. Rejects
    # aliases and functions. Fixture resolvers bypass the live cache.
    # Operational probe failures allow the next supported application.
    #
    # .PARAMETER RuntimeContext
    # The shared runtime state passed through the validator and SelfTest loader.
    #
    # .PARAMETER CommandResolver
    # Optional private fixture resolver for application command records.
    #
    # .PARAMETER VersionProbe
    # Optional private fixture predicate for an application and prefix arguments.
    #
    # .PARAMETER WindowsPlatform
    # Includes the Windows launcher before the supported PATH names.
    #
    # .PARAMETER PathNames
    # The supported Python application names in resolution order.
    #
    # .EXAMPLE
    # Get-Python312CommandContext
    #
    # # Returns an application path and its launcher arguments, or null.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [pscustomobject] Path and Arguments for the verified application; null if unavailable.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261003.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter()][ValidateNotNull()][hashtable] $RuntimeContext = $hashtableRuntimeContext,
        [Parameter()][AllowNull()][scriptblock] $CommandResolver,
        [Parameter()][AllowNull()][scriptblock] $VersionProbe,
        [Parameter()][bool] $WindowsPlatform = $RuntimeContext.WindowsPlatform,
        [Parameter()][string[]] $PathNames = $RuntimeContext.PythonPathNames
    )
    $boolLiveResolution = $null -eq $CommandResolver -and $null -eq $VersionProbe
    $strResolutionKey = [string]$WindowsPlatform + ':' + ($PathNames -join '|')
    if ($boolLiveResolution -and $null -ne $RuntimeContext.PythonCommandContext -and
        $RuntimeContext.PythonResolutionKey -ceq $strResolutionKey) {
        return $RuntimeContext.PythonCommandContext
    }
    if ($null -eq $CommandResolver) {
        $CommandResolver = {
            param([string] $Name)
            Get-Command -Name $Name -CommandType Application -All -ErrorAction SilentlyContinue
        }
    }
    if ($null -eq $VersionProbe) {
        $VersionProbe = {
            param([string] $Path, [string[]] $PrefixArgument)
            Test-Python312Application -Path $Path -PrefixArgument $PrefixArgument
        }
    }
    $arrCommandNames = @(
        if ($WindowsPlatform) { 'py' }
        $PathNames
    )
    $setApplications = [Collections.Generic.HashSet[string]]::new($(if ($IsWindows) {
                [StringComparer]::OrdinalIgnoreCase
            } else { [StringComparer]::Ordinal }))
    foreach ($strName in $arrCommandNames) {
        $arrPrefixArguments = [string[]]@()
        if ($strName -ceq 'py') { $arrPrefixArguments = [string[]]@('-3.12') }
        foreach ($objCommand in @(& $CommandResolver $strName)) {
            if ($null -eq $objCommand -or
                $null -eq $objCommand.PSObject.Properties['CommandType'] -or
                [string]$objCommand.CommandType -cne 'Application' -or
                $null -eq $objCommand.PSObject.Properties['Path'] -or
                -not [IO.Path]::IsPathFullyQualified([string]$objCommand.Path)) { continue }
            $strApplicationPath = [IO.Path]::GetFullPath([string]$objCommand.Path)
            if (-not $setApplications.Add($strApplicationPath + '|' + ($arrPrefixArguments -join '|'))) {
                continue
            }
            try {
                if (-not (& $VersionProbe $strApplicationPath $arrPrefixArguments)) { continue }
            } catch {
                Write-Debug 'The Python version predicate failed; try the next application.'
                continue
            }
            $objContext = [pscustomobject]@{
                Path = $strApplicationPath
                Arguments = $arrPrefixArguments
            }
            if ($boolLiveResolution) {
                $RuntimeContext.PythonCommandContext = $objContext
                $RuntimeContext.PythonResolutionKey = $strResolutionKey
            }
            return $objContext
        }
    }
    return $null
}

function Invoke-NodeRuntimeProbe {
    # .SYNOPSIS
    # Reads bounded identity data from one Node application.
    #
    # .DESCRIPTION
    # Removes preload environment variables and runs a fixed identity program.
    # Returns null on native, timeout, output-size or stderr failure.
    #
    # .PARAMETER Path
    # The application path to probe.
    #
    # .EXAMPLE
    # Invoke-NodeRuntimeProbe -Path '/usr/bin/node'
    #
    # # Returns strict JSON identity data for the supported resolver.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [string] Bounded UTF-8 JSON output, or null on probe failure.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261003.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param([Parameter(Mandatory)][string] $Path)
    $objStartInfo = [Diagnostics.ProcessStartInfo]::new($Path)
    $objStartInfo.UseShellExecute = $false
    $objStartInfo.CreateNoWindow = $true
    $objStartInfo.RedirectStandardOutput = $true
    $objStartInfo.RedirectStandardError = $true
    [void]$objStartInfo.Environment.Remove('NODE_OPTIONS')
    [void]$objStartInfo.Environment.Remove('NODE_PATH')
    $objStartInfo.ArgumentList.Add('-p')
    $objStartInfo.ArgumentList.Add(
        'JSON.stringify({execPath:process.execPath,nodeVersion:process.versions.node})')
    $objProcess = [Diagnostics.Process]::new()
    $objProcess.StartInfo = $objStartInfo
    try {
        $objResult = Read-BoundedProcessData -Process $objProcess -MaximumBytes 4096 `
            -TimeoutMilliseconds 10000 -DisplayName 'Node application identity probe' `
            -RejectStandardError
        if ($objResult.ExitCode -ne 0) { return $null }
        return ConvertFrom-StrictUtf8Data -Bytes $objResult.Bytes -DisplayName 'Node identity'
    } catch {
        Write-Debug 'The Node application did not return a bounded identity.'
        return $null
    }
}

function Get-NodeApplicationContext {
    # .SYNOPSIS
    # Resolves and caches the direct supported Node application.
    #
    # .DESCRIPTION
    # Probes application candidates and validates their reported absolute
    # executable path and Node 22-or-later version with the strict JSON decoder.
    # Invalid or unavailable candidates fall through; private fixture hooks do not cache.
    #
    # .PARAMETER RuntimeContext
    # The shared runtime state passed through the validator and SelfTest loader.
    #
    # .PARAMETER CommandResolver
    # Optional private resolver for PATH application candidates.
    #
    # .PARAMETER RuntimeProbe
    # Optional private probe that returns the candidate's JSON identity text.
    #
    # .PARAMETER ApplicationResolver
    # Optional private resolver for the reported direct application path.
    #
    # .EXAMPLE
    # Get-NodeApplicationContext
    #
    # # Returns the verified direct application path and version, or null.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [pscustomobject] Path and Version for the application; null if unavailable.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261003.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter()][ValidateNotNull()][hashtable] $RuntimeContext = $hashtableRuntimeContext,
        [Parameter()][AllowNull()][scriptblock] $CommandResolver,
        [Parameter()][AllowNull()][scriptblock] $RuntimeProbe,
        [Parameter()][AllowNull()][scriptblock] $ApplicationResolver
    )
    $boolLiveResolution = $null -eq $CommandResolver -and $null -eq $RuntimeProbe -and
        $null -eq $ApplicationResolver
    if ($boolLiveResolution -and $null -ne $RuntimeContext.NodeApplicationContext) {
        return $RuntimeContext.NodeApplicationContext
    }
    if ($null -eq $CommandResolver) {
        $CommandResolver = {
            param([string] $Name)
            Get-Command -Name $Name -CommandType Application -All -ErrorAction SilentlyContinue
        }
    }
    if ($null -eq $RuntimeProbe) {
        $RuntimeProbe = { param([string] $Path) Invoke-NodeRuntimeProbe -Path $Path }
    }
    if ($null -eq $ApplicationResolver) { $ApplicationResolver = $CommandResolver }
    foreach ($objCandidate in @(& $CommandResolver 'node')) {
        if ($null -eq $objCandidate -or
            $null -eq $objCandidate.PSObject.Properties['CommandType'] -or
            [string]$objCandidate.CommandType -cne 'Application' -or
            $null -eq $objCandidate.PSObject.Properties['Path'] -or
            -not [IO.Path]::IsPathFullyQualified([string]$objCandidate.Path)) { continue }
        try {
            $strIdentity = & $RuntimeProbe ([string]$objCandidate.Path)
            if ($strIdentity -isnot [string]) { continue }
            $objIdentity = ConvertFrom-ParserJsonContext -Content $strIdentity -MaximumBytes 4096
            if ($objIdentity.execPath -isnot [string] -or
                $objIdentity.nodeVersion -isnot [string] -or
                -not [IO.Path]::IsPathFullyQualified($objIdentity.execPath)) { continue }
            $objVersion = [regex]::Match($objIdentity.nodeVersion, '\A(?<Major>[0-9]+)\.[0-9]+\.[0-9]+\z')
            $intMajorVersion = 0
            if (-not $objVersion.Success -or
                -not [int]::TryParse($objVersion.Groups['Major'].Value, [ref]$intMajorVersion) -or
                $intMajorVersion -lt 22) { continue }
            $strDirectPath = [IO.Path]::GetFullPath($objIdentity.execPath)
            $objComparison = if ($IsWindows) { [StringComparison]::OrdinalIgnoreCase } else {
                [StringComparison]::Ordinal
            }
            foreach ($objApplication in @(& $ApplicationResolver $strDirectPath)) {
                if ($null -eq $objApplication -or
                    $null -eq $objApplication.PSObject.Properties['CommandType'] -or
                    [string]$objApplication.CommandType -cne 'Application' -or
                    $null -eq $objApplication.PSObject.Properties['Path'] -or
                    -not [IO.Path]::IsPathFullyQualified([string]$objApplication.Path) -or
                    -not [string]::Equals([IO.Path]::GetFullPath([string]$objApplication.Path),
                        $strDirectPath, $objComparison)) { continue }
                $objContext = [pscustomobject]@{ Path = $strDirectPath; Version = $objIdentity.nodeVersion }
                if ($boolLiveResolution) { $RuntimeContext.NodeApplicationContext = $objContext }
                return $objContext
            }
        } catch {
            Write-Debug 'The Node application identity was invalid; try the next application.'
        }
    }
    return $null
}

function Get-TomlParseContext {
    # .SYNOPSIS
    # Parses the trusted TOML subset used by the validator.
    #
    # .DESCRIPTION
    # Parses the repository-owned TOML subset without evaluating code.
    #
    # .PARAMETER Content
    # The trusted input text to parse or transform.
    #
    # .EXAMPLE
    # Get-TomlParseContext @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.Management.Automation.PSCustomObject] One validated context object described in the function description.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.1.20261003.0
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
        FeatureTablePresent = $false
        FeatureTableType = 'missing'
        MultiAgentPresent = $false
        MultiAgentType = 'missing'
        MultiAgentValue = $false
        CapacityIsFirstStatement = $false
        PluginHeaderIsSecondStatement = $false
        PluginEnablementIsThirdStatement = $false
        PluginEnabledValueStatementOffset = -1
        PluginEnabledValueLength = 0
    }

    $objPythonCommand = Get-Python312CommandContext
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
fe=d.get("features");mp=type(fe)is dict and "multi_agent" in fe;ma=g(fe,"multi_agent")
r=dict(a=cp,b=type(cv).__name__ if cp else "missing",c=str(cv) if type(cv)is int else None,d=tp,e=type(tb).__name__ if tp else "missing",f=ep,g=type(ev).__name__ if ep else "missing",h=ev if type(ev)is bool else None,i=a1,j=h,k=v,l=vo,m=vl,n="features" in d,o=type(fe).__name__ if "features" in d else "missing",p=mp,q=type(ma).__name__ if mp else "missing",r=ma if type(ma)is bool else None)
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
            } else {
                'The project configuration must contain valid TOML.'
            }
            return [pscustomobject]$objContext
        }
        if (-not [string]::IsNullOrEmpty($strParserError)) {
            $objContext.Failure = 'The trusted TOML parser returned unexpected error output.'
            return [pscustomobject]$objContext
        }
    } catch {
        $objContext.Failure = $strPythonPrerequisite
        return [pscustomobject]$objContext
    } finally {
        $objParserProcess.Dispose()
    }

    if ([Text.Encoding]::UTF8.GetByteCount($strParserOutput) -gt 4096) {
        $objContext.Failure = 'The trusted TOML parser returned oversized typed context.'
        return [pscustomobject]$objContext
    }

    try {
        $objParserContext = ConvertFrom-ParserJsonContext `
            -Content $strParserOutput -MaximumBytes 4096
    } catch {
        $objContext.Failure = 'The trusted TOML parser returned invalid typed context.'
        return [pscustomobject]$objContext
    }

    $arrExpectedProperties = @('a', 'b', 'c', 'd', 'e', 'f', 'g',
        'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r')
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
        $objParserContext.n -isnot [bool] -or $objParserContext.o -isnot [string] -or
        $objParserContext.p -isnot [bool] -or $objParserContext.q -isnot [string] -or
        ($null -ne $objParserContext.r -and $objParserContext.r -isnot [bool]) -or
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
    $objContext.FeatureTablePresent = $objParserContext.n
    $objContext.FeatureTableType = $objParserContext.o
    $objContext.MultiAgentPresent = $objParserContext.p
    $objContext.MultiAgentType = $objParserContext.q
    if ($objParserContext.r -is [bool]) {
        $objContext.MultiAgentValue = $objParserContext.r
    }
    $objContext.CapacityIsFirstStatement = $objParserContext.i
    $objContext.PluginHeaderIsSecondStatement = $objParserContext.j
    $objContext.PluginEnablementIsThirdStatement = $objParserContext.k
    $objContext.PluginEnabledValueStatementOffset = [int]$objParserContext.l
    $objContext.PluginEnabledValueLength = [int]$objParserContext.m

    return [pscustomobject]$objContext
}

function Invoke-MarkdownParserProcess {
    # .SYNOPSIS
    # Runs the locked Markdown parser process with strict bounds.
    #
    # .DESCRIPTION
    # Sends Markdown to the locked parser through redirected streams.
    #
    # .PARAMETER StartInfo
    # The validated process start configuration.
    #
    # .PARAMETER Content
    # The trusted input text to parse or transform.
    #
    # .EXAMPLE
    # Invoke-MarkdownParserProcess @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.Management.Automation.PSCustomObject] One validated context object described in the function description.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [Diagnostics.ProcessStartInfo] $StartInfo,

        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Content
    )

    if ($StartInfo.UseShellExecute -or
        -not $StartInfo.RedirectStandardInput -or
        -not $StartInfo.RedirectStandardOutput -or
        -not $StartInfo.RedirectStandardError) {
        throw 'The locked Markdown parser requires shell-free redirected process streams.'
    }

    $listAttemptEvidence = [Collections.Generic.List[string]]::new()
    foreach ($intAttempt in 1..2) {
        $objParserProcess = [Diagnostics.Process]::new()
        $objParserProcess.StartInfo = $StartInfo
        $objStandardOutputTask = $null
        $objStandardErrorTask = $null
        $objTimer = [Diagnostics.Stopwatch]::StartNew()
        $objFailure = $null
        $objInputFailure = $null
        $objCleanupFailure = $null
        $boolStarted = $false
        $boolInputAccepted = $false
        $strParserOutput = ''
        $strParserError = ''
        $strExitClassification = 'unavailable'
        $intExitCode = $null
        try {
            if (-not $objParserProcess.Start()) {
                throw 'Could not start the locked Markdown parser.'
            }
            $boolStarted = $true
            $objStandardOutputTask = $objParserProcess.StandardOutput.ReadToEndAsync()
            $objStandardErrorTask = $objParserProcess.StandardError.ReadToEndAsync()
            try {
                $objWriteTask = $objParserProcess.StandardInput.WriteAsync($Content)
                $intRemaining = [Math]::Max(
                    0, 10000 - [int]$objTimer.ElapsedMilliseconds)
                if (-not $objWriteTask.Wait($intRemaining)) {
                    throw [TimeoutException]::new(
                        'Markdown block parsing must complete within 10 seconds.'
                    )
                }
                [void]$objWriteTask.GetAwaiter().GetResult()
                $objParserProcess.StandardInput.Close()
                $boolInputAccepted = $true
            } catch {
                $objInputFailure = $_.Exception
                throw
            }

            $intRemaining = [Math]::Max(
                0, 10000 - [int]$objTimer.ElapsedMilliseconds)
            if (-not $objParserProcess.WaitForExit($intRemaining)) {
                throw [TimeoutException]::new(
                    'Markdown block parsing must complete within 10 seconds.'
                )
            }
        } catch {
            $objFailure = $_.Exception
        } finally {
            if ($boolStarted) {
                try {
                    $objParserProcess.StandardInput.Close()
                } catch {
                    [void]$_
                }
                try {
                    if (-not $objParserProcess.HasExited) {
                        $intRemaining = [Math]::Max(
                            0, 10000 - [int]$objTimer.ElapsedMilliseconds)
                        if ($intRemaining -gt 0) {
                            [void]$objParserProcess.WaitForExit($intRemaining)
                        }
                    }
                    if (-not $objParserProcess.HasExited) {
                        $objParserProcess.Kill($true)
                    }
                    if (-not $objParserProcess.WaitForExit(1000)) {
                        throw 'The locked Markdown parser could not be reaped.'
                    }
                    $intExitCode = $objParserProcess.ExitCode
                    $strExitClassification = [string]$intExitCode
                } catch {
                    $objCleanupFailure = $_.Exception
                }
                if ($null -ne $objStandardOutputTask) {
                    try {
                        $strParserOutput = $objStandardOutputTask.GetAwaiter().GetResult()
                    } catch {
                        if ($null -eq $objCleanupFailure) {
                            $objCleanupFailure = $_.Exception
                        }
                    }
                }
                if ($null -ne $objStandardErrorTask) {
                    try {
                        $strParserError = $objStandardErrorTask.GetAwaiter().GetResult()
                    } catch {
                        if ($null -eq $objCleanupFailure) {
                            $objCleanupFailure = $_.Exception
                        }
                    }
                }
            }
            $objTimer.Stop()
            $objParserProcess.Dispose()
        }

        $strErrorClassification = if ([string]::IsNullOrEmpty($strParserError)) {
            'stderr=empty'
        } else {
            'stderr=present'
        }
        if ($null -ne $objCleanupFailure) {
            throw [InvalidOperationException]::new(
                "The locked Markdown parser cleanup failed on attempt $intAttempt " +
                    "(exit=$strExitClassification; $strErrorClassification).",
                $objCleanupFailure
            )
        }
        if ($null -ne $objFailure) {
            $listExceptions = [Collections.Generic.List[Exception]]::new()
            $listExceptions.Add($objFailure)
            $boolPrematureInputClose = $false
            for ($intException = 0;
                $intException -lt $listExceptions.Count -and $intException -lt 16;
                $intException++) {
                $objException = $listExceptions[$intException]
                if ($objException -is [IO.IOException]) {
                    $boolPrematureInputClose = $true
                    break
                }
                if ($objException -is [AggregateException]) {
                    foreach ($objInnerException in $objException.InnerExceptions) {
                        $listExceptions.Add($objInnerException)
                    }
                } elseif ($null -ne $objException.InnerException) {
                    $listExceptions.Add($objException.InnerException)
                }
            }
            if ($null -ne $objInputFailure -and
                -not $boolInputAccepted -and $boolPrematureInputClose) {
                $listAttemptEvidence.Add(
                    "attempt $intAttempt`: premature-input-close, " +
                        "exit=$strExitClassification, $strErrorClassification"
                )
                if ($intAttempt -lt 2) {
                    continue
                }
                throw [IO.IOException]::new(
                    'The locked Markdown parser input closed prematurely after ' +
                        "2 attempts ($($listAttemptEvidence -join '; ')).",
                    $objFailure
                )
            }
            if ($objFailure -is [TimeoutException]) {
                throw [TimeoutException]::new(
                    'Markdown block parsing must complete within 10 seconds ' +
                        "(attempt $intAttempt; exit=$strExitClassification; " +
                        "$strErrorClassification).",
                    $objFailure
                )
            }
            throw [InvalidOperationException]::new(
                "The locked Markdown parser failed on attempt $intAttempt " +
                    "(exit=$strExitClassification; $strErrorClassification).",
                $objFailure
            )
        }
        if ($intExitCode -ne 0) {
            throw "The locked Markdown parser rejected a governed document " +
                "(attempt $intAttempt; exit=$strExitClassification; " +
                "$strErrorClassification)."
        }
        return [pscustomobject]@{
            Output = $strParserOutput
            AttemptCount = $intAttempt
        }
    }
}

function Get-MarkdownParseReuseSlot {
    # .SYNOPSIS
    # Creates one private document-owned structural reuse slot.
    #
    # .DESCRIPTION
    # Shares only a retained-snapshot counter with sibling document slots.
    # No lookup table or process-wide state is created.
    #
    # .PARAMETER Budget
    # The private invocation-owned counter, or null for a new owner.
    #
    # .EXAMPLE
    # Get-MarkdownParseReuseSlot -Budget $objBudget
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # System.Management.Automation.PSCustomObject. One private empty slot.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - Not a public interface.
    # Version: 1.0.20261006.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param([Parameter()][AllowNull()][pscustomobject] $Budget)

    if ($null -eq $Budget) { $Budget = [pscustomobject]@{ Retained = 0 } }
    return [pscustomobject]@{ Budget = $Budget; Snapshot = $null }
}

function Clear-MarkdownParseReuseSlot {
    # .SYNOPSIS
    # Releases a private retained snapshot without changing validation results.
    #
    # .DESCRIPTION
    # Is idempotent, accepts an absent slot and clears before updating its owner.
    # Only slots created by the private factory are supplied by production callers.
    #
    # .PARAMETER Slot
    # The document-owned slot to clear.
    #
    # .EXAMPLE
    # Clear-MarkdownParseReuseSlot -Slot $objSlot
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - Not a public interface.
    # Version: 1.0.20261006.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param([Parameter()][AllowNull()][object] $Slot)

    if ($null -eq $Slot -or $null -eq $Slot.PSObject.Properties['Snapshot']) { return }
    if ($null -eq $Slot.Snapshot) { return }
    $Slot.Snapshot = $null
    if ($null -ne $Slot.PSObject.Properties['Budget'] -and $null -ne $Slot.Budget -and
        $null -ne $Slot.Budget.PSObject.Properties['Retained'] -and
        $Slot.Budget.Retained -is [int] -and $Slot.Budget.Retained -gt 0) {
        $Slot.Budget.Retained--
    }
}

function Copy-MarkdownParseReuseContext {
    # .SYNOPSIS
    # Copies the seven validated structural arrays within fixed retention bounds.
    #
    # .DESCRIPTION
    # Copies every mutable record and nested array. Strings are immutable.
    # Returns null when retention would exceed one MiB of charged UTF-16 payload,
    # 2048 records or 8192 array elements. This is not a content-admission limit.
    #
    # .PARAMETER Context
    # The fully validated structural result; never raw parser output.
    #
    # .PARAMETER ParserText
    # The exact normalized parser input charged to retention.
    #
    # .PARAMETER ParserOutput
    # The exact successful raw parser JSON charged to retention.
    #
    # .EXAMPLE
    # Copy-MarkdownParseReuseContext -Context $objContext -ParserText $strText -ParserOutput $strJson
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # System.Management.Automation.PSCustomObject. Isolated context and accounting, or null.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - Not a public interface.
    # Version: 1.0.20261006.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][pscustomobject] $Context,
        [Parameter(Mandatory)][AllowEmptyString()][string] $ParserText,
        [Parameter(Mandatory)][AllowEmptyString()][string] $ParserOutput
    )

    $longCharacters = [long]$ParserText.Length + [long]$ParserOutput.Length
    if ($longCharacters -gt 524288) { return $null }
    $longElements = 0L
    $listRecords = [Collections.Generic.List[object]]::new()
    foreach ($strArrayName in @('CodeBlockRanges', 'ProseBlocks', 'TableRows',
            'TopLevelBlocks', 'TopLevelListItems', 'Headings', 'LevelTwoHeadings')) {
        $longElements += $Context.$strArrayName.Count
        if ($longElements -gt 8192) { return $null }
        foreach ($objRecord in $Context.$strArrayName) {
            $listRecords.Add($objRecord)
            if ($listRecords.Count -gt 2048) { return $null }
            if ($strArrayName -ceq 'TableRows') {
                $longElements += $objRecord.Cells.Count
                if ($longElements -gt 8192) { return $null }
                foreach ($objCell in $objRecord.Cells) {
                    $listRecords.Add($objCell)
                    if ($listRecords.Count -gt 2048) { return $null }
                }
            }
        }
    }
    foreach ($objRecord in $listRecords) {
        foreach ($strPropertyName in @('Type', 'Tag', 'Text')) {
            $objProperty = $objRecord.PSObject.Properties[$strPropertyName]
            if ($null -ne $objProperty -and $null -ne $objProperty.Value) {
                $longCharacters += $objProperty.Value.Length
            }
        }
        foreach ($strArrayName in @('Code', 'Links')) {
            $objProperty = $objRecord.PSObject.Properties[$strArrayName]
            if ($null -ne $objProperty) {
                $longElements += $objProperty.Value.Count
                if ($longElements -gt 8192) { return $null }
                foreach ($strValue in $objProperty.Value) {
                    $longCharacters += $strValue.Length
                    if ($longCharacters -gt 524288) { return $null }
                }
            }
        }
        if ($longCharacters -gt 524288) { return $null }
    }

    $objCopy = [pscustomobject]@{
        CodeBlockRanges = [pscustomobject[]]@(
            foreach ($objRecord in $Context.CodeBlockRanges) {
                [pscustomobject]@{ Start = $objRecord.Start; End = $objRecord.End }
            })
        ProseBlocks = [pscustomobject[]]@(
            foreach ($objRecord in $Context.ProseBlocks) {
                [pscustomobject]@{ Start = $objRecord.Start; End = $objRecord.End; Text = $objRecord.Text
                    Code = [string[]]$objRecord.Code.Clone(); Links = [string[]]$objRecord.Links.Clone() }
            })
        TableRows = [pscustomobject[]]@(
            foreach ($objRecord in $Context.TableRows) {
                [pscustomobject]@{ Start = $objRecord.Start; End = $objRecord.End
                    Cells = [pscustomobject[]]@(
                        foreach ($objCell in $objRecord.Cells) {
                            [pscustomobject]@{ Tag = $objCell.Tag; Start = $objCell.Start; End = $objCell.End
                                Text = $objCell.Text; Code = [string[]]$objCell.Code.Clone()
                                Links = [string[]]$objCell.Links.Clone() }
                        }) }
            })
        TopLevelBlocks = [pscustomobject[]]@(
            foreach ($objRecord in $Context.TopLevelBlocks) {
                [pscustomobject]@{ Type = $objRecord.Type; Tag = $objRecord.Tag
                    Start = $objRecord.Start; End = $objRecord.End; Text = $objRecord.Text }
            })
        TopLevelListItems = [pscustomobject[]]@(
            foreach ($objRecord in $Context.TopLevelListItems) {
                [pscustomobject]@{ Start = $objRecord.Start; End = $objRecord.End; Text = $objRecord.Text
                    Code = [string[]]$objRecord.Code.Clone(); Links = [string[]]$objRecord.Links.Clone() }
            })
        Headings = [pscustomobject[]]@(
            foreach ($objRecord in $Context.Headings) {
                [pscustomobject]@{ Tag = $objRecord.Tag; Start = $objRecord.Start
                    End = $objRecord.End; Text = $objRecord.Text }
            })
        LevelTwoHeadings = [pscustomobject[]]@(
            foreach ($objRecord in $Context.LevelTwoHeadings) {
                [pscustomobject]@{ Start = $objRecord.Start; End = $objRecord.End; Text = $objRecord.Text }
            })
    }
    return [pscustomobject]@{ Context = $objCopy; Characters = $longCharacters
        Records = $listRecords.Count; Elements = $longElements }
}


function Get-MarkdownParseContext {
    # .SYNOPSIS
    # Parses Markdown into trusted structural context.
    #
    # .DESCRIPTION
    # Uses the repository-locked markdown-it package to identify code-block ranges,
    # prose blocks with operative code spans and link destinations, top-level
    # blocks, table rows and cells, top-level list items, all top-level headings,
    # and level-two headings.
    # It validates all parser output before returning it.
    #
    # .PARAMETER Content
    # The Markdown text to parse.
    #
    # .PARAMETER LineCount
    # The source line count used to bound parser ranges.
    #
    # .PARAMETER ReuseSlot
    # Optional private document-owned structural interpretation slot.
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
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.3.20261007.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Content,

        [Parameter(Mandatory)]
        [ValidateRange(1, 2147483647)]
        [int] $LineCount,

        [Parameter()][AllowNull()][object] $ReuseSlot
    )

    if ($null -ne $ReuseSlot -and
        ($null -eq $ReuseSlot.PSObject.Properties['Snapshot'] -or
            $null -eq $ReuseSlot.PSObject.Properties['Budget'] -or
            $null -eq $ReuseSlot.Budget -or
            $null -eq $ReuseSlot.Budget.PSObject.Properties['Retained'] -or
            $ReuseSlot.Budget.Retained -isnot [int] -or
            $ReuseSlot.Budget.Retained -lt 0 -or $ReuseSlot.Budget.Retained -gt 8)) {
        $ReuseSlot = $null
    }
    try {
        $strRepositoryRootPath = [IO.Path]::GetDirectoryName(
            [IO.Path]::GetDirectoryName($PSScriptRoot)
        )
        $strMarkdownParserPath = Join-Path `
            -Path $strRepositoryRootPath `
            -ChildPath 'node_modules/markdown-it/package.json'
        if (-not (Test-Path -LiteralPath $strMarkdownParserPath -PathType Leaf)) {
            throw 'The locked markdown-it package is required to validate operative Markdown.'
        }

        $objNodeCommand = Get-NodeApplicationContext
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
            '  const renderedOutput = [];'
            '  const code = [];'
            '  const links = [];'
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
            '    if (child.type === "link_open") {'
            '      const href = child.attrGet("href");'
            '      if (typeof href !== "string") throw new Error("Invalid Markdown link destination.");'
            '      links.push(href);'
            '    }'
            '    if (child.type === "text" || child.type === "text_special") {'
            '      output.push(child.content);'
            '      renderedOutput.push(child.content);'
            '    } else if (child.type === "softbreak" || child.type === "hardbreak") {'
            '      output.push("\n");'
            '      renderedOutput.push("\n");'
            '    } else if (child.type === "code_inline") {'
            '      code.push(child.content);'
            '      renderedOutput.push(child.content);'
            '    }'
            '  }'
            '  if (deletionStack.length > 0) throw new Error("Unclosed deletion container.");'
            '  if (htmlContainerStack.length > 0) throw new Error("Unclosed inline HTML container.");'
            '  return { text: output.join(""), renderedText: renderedOutput.join(""), code, links };'
            '};'
            'const codeBlockRanges = tokens.filter((token) => token.type === "fence" || token.type === "code_block").map((token) => token.map);'
            'const proseBlocks = tokens.filter((token) => token.type === "inline" && Array.isArray(token.map) && Array.isArray(token.children)).map((token) => {'
            '  const context = getOperativeInlineContext(token.children);'
            '  return { range: token.map, text: context.text, code: context.code, links: context.links };'
            '});'
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
            '  const blocks = [];'
            '  for (let paragraphIndex = index + 1; paragraphIndex < closeIndex; paragraphIndex += 1) {'
            '    const paragraphToken = tokens[paragraphIndex];'
            '    if (paragraphToken.type !== "paragraph_open" || paragraphToken.level !== 2) continue;'
            '    if (paragraphToken.tag !== "p" || paragraphToken.nesting !== 1 || !Array.isArray(paragraphToken.map)) throw new Error("Invalid top-level list-item paragraph.");'
            '    const inlineToken = tokens[paragraphIndex + 1];'
            '    const closeToken = tokens[paragraphIndex + 2];'
            '    if (inlineToken?.type !== "inline" || inlineToken.level !== 3 || !Array.isArray(inlineToken.children) || closeToken?.type !== "paragraph_close" || closeToken.tag !== "p" || closeToken.level !== 2 || closeToken.nesting !== -1) throw new Error("Invalid top-level list-item paragraph container.");'
            '    const context = getOperativeInlineContext(inlineToken.children);'
            '    blocks.push({ range: paragraphToken.map, text: context.text, code: context.code, links: context.links });'
            '  }'
            '  return blocks;'
            '});'
            'const headings = tokens.flatMap((token, index) => {'
            '  if (token.type !== "heading_open" || token.level !== 0) return [];'
            '  if (!/^h[1-6]$/.test(token.tag) || token.nesting !== 1 || !Array.isArray(token.map)) throw new Error("Invalid Markdown heading.");'
            '  const inlineToken = tokens[index + 1];'
            '  const closeToken = tokens[index + 2];'
            '  if (inlineToken?.type !== "inline" || !Array.isArray(inlineToken.children) || closeToken?.type !== "heading_close" || closeToken.tag !== token.tag || closeToken.nesting !== -1) throw new Error("Invalid Markdown heading container.");'
            '  return [{ tag: token.tag, range: token.map, text: getOperativeInlineContext(inlineToken.children).text }];'
            '});'
            'const levelTwoHeadings = tokens.flatMap((token, index) => {'
            '  if (token.type !== "heading_open" || token.tag !== "h2" || token.level !== 0) return [];'
            '  const inlineToken = tokens[index + 1];'
            '  return [{ range: token.map, text: inlineToken?.type === "inline" ? inlineToken.content : null }];'
            '});'
            'const tableContainers = new Map();'
            'const tableStack = [];'
            'tokens.forEach((token, index) => {'
            '  if (token.type === "table_open") {'
            '    if (token.tag !== "table" || token.nesting !== 1 || !Array.isArray(token.map)) throw new Error("Invalid Markdown table container.");'
            '    tableStack.push({ level: token.level, index });'
            '  } else if (token.type === "table_close") {'
            '    const table = tableStack.pop();'
            '    if (token.tag !== "table" || token.nesting !== -1 || !table || table.level !== token.level) throw new Error("Unbalanced Markdown table container.");'
            '  } else if (token.type === "tr_open") {'
            '    const table = tableStack[tableStack.length - 1];'
            '    if (!table) throw new Error("Markdown table row has no table container.");'
            '    tableContainers.set(index, table);'
            '  }'
            '});'
            'if (tableStack.length > 0) throw new Error("Unclosed Markdown table container.");'
            'const tableRows = tokens.flatMap((token, index) => {'
            '  if (token.type !== "tr_open" || token.tag !== "tr" || token.nesting !== 1 || !Array.isArray(token.map)) return [];'
            '  const table = tableContainers.get(index);'
            '  if (!table) throw new Error("Markdown table row has no tracked container.");'
            '  if (table.level !== 0) return [];'
            '  const closeIndex = tokens.findIndex((candidate, candidateIndex) => candidateIndex > index && candidate.type === "tr_close" && candidate.tag === "tr" && candidate.nesting === -1 && candidate.level === token.level);'
            '  if (closeIndex < 0) throw new Error("Unclosed Markdown table row.");'
            '  const cells = [];'
            '  for (let cellIndex = index + 1; cellIndex < closeIndex; cellIndex += 1) {'
            '    const cellToken = tokens[cellIndex];'
            '    if (cellToken.type !== "th_open" && cellToken.type !== "td_open") continue;'
            '    if ((cellToken.tag !== "th" && cellToken.tag !== "td") || cellToken.nesting !== 1) throw new Error("Invalid Markdown table cell.");'
            '    const inlineToken = tokens[cellIndex + 1];'
            '    const closeToken = tokens[cellIndex + 2];'
            '    if (inlineToken?.type !== "inline" || !Array.isArray(inlineToken.children) || closeToken?.type !== `${cellToken.tag}_close` || closeToken.tag !== cellToken.tag || closeToken.nesting !== -1) throw new Error("Invalid Markdown table-cell container.");'
            '    const context = getOperativeInlineContext(inlineToken.children);'
            '    cells.push({ tag: cellToken.tag, text: context.renderedText, code: context.code, links: context.links });'
            '  }'
            '  if (cells.length === 0) throw new Error("Markdown table row has no cells.");'
            '  return [{ range: token.map, cells }];'
            '});'
            'process.stdout.write(JSON.stringify({ codeBlockRanges, proseBlocks, tableRows, topLevelBlocks, topLevelListItems, headings, levelTwoHeadings }));'
        ) -join "`n"

        $objStartInfo = [System.Diagnostics.ProcessStartInfo]::new()
        $objStartInfo.FileName = $objNodeCommand.Path
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

        $objParserResult = Invoke-MarkdownParserProcess `
            -StartInfo $objStartInfo `
            -Content $Content
        $strParserOutput = $objParserResult.Output

        # Every call above has checked availability and executed the bounded parser.
        # Reuse only interpretation of identical fresh output under unchanged helpers.
        if ($null -ne $ReuseSlot -and $null -ne $ReuseSlot.Snapshot) {
            $objSnapshot = $ReuseSlot.Snapshot
            $boolCompleteSnapshot = $true
            foreach ($strProperty in @('ParserText', 'LineCount', 'ParserOutput',
                    'ParserDefinition', 'DecoderDefinition', 'CopyDefinition', 'Context')) {
                if ($null -eq $objSnapshot.PSObject.Properties[$strProperty]) {
                    $boolCompleteSnapshot = $false
                }
            }
            if ($boolCompleteSnapshot -and $objSnapshot.ParserText -is [string] -and
                $objSnapshot.ParserOutput -is [string] -and $objSnapshot.LineCount -is [int] -and
                [string]::Equals($objSnapshot.ParserText, $Content, [StringComparison]::Ordinal) -and
                $objSnapshot.LineCount -eq $LineCount -and
                [string]::Equals($objSnapshot.ParserOutput, $strParserOutput, [StringComparison]::Ordinal) -and
                [object]::ReferenceEquals($objSnapshot.ParserDefinition, ${function:Get-MarkdownParseContext}) -and
                [object]::ReferenceEquals($objSnapshot.DecoderDefinition, ${function:ConvertFrom-ParserJsonContext}) -and
                [object]::ReferenceEquals($objSnapshot.CopyDefinition, ${function:Copy-MarkdownParseReuseContext})) {
                $objCopy = Copy-MarkdownParseReuseContext -Context $objSnapshot.Context `
                    -ParserText $Content -ParserOutput $strParserOutput
                if ($null -ne $objCopy) { return $objCopy.Context }
            }
            Clear-MarkdownParseReuseSlot -Slot $ReuseSlot
        }

        try {
            $objRawContext = ConvertFrom-ParserJsonContext `
                -Content $strParserOutput -MaximumBytes 16777216 -UseNativeStructuralConversion
        } catch {
            throw [System.IO.InvalidDataException]::new(
                'The locked Markdown parser returned invalid context data.',
                $_.Exception
            )
        }
        if ($null -eq $objRawContext -or
            $null -eq $objRawContext.codeBlockRanges -or
            $null -eq $objRawContext.proseBlocks -or
            $null -eq $objRawContext.tableRows -or
            $null -eq $objRawContext.topLevelBlocks -or
            $null -eq $objRawContext.topLevelListItems -or
            $null -eq $objRawContext.headings -or
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
                ($objRawProseBlock.code.Count -ne 0 -and
                    @($objRawProseBlock.code | Where-Object { $_ -isnot [string] }).Count -ne 0) -or
                $objRawProseBlock.links -isnot [array] -or
                ($objRawProseBlock.links.Count -ne 0 -and
                    @($objRawProseBlock.links | Where-Object { $_ -isnot [string] }).Count -ne 0)) {
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
                    Links = [string[]]@($objRawProseBlock.links)
                })
        }

        $listTableRows = [Collections.Generic.List[pscustomobject]]::new()
        $intPreviousTableRowEnd = 0
        foreach ($objRawTableRow in @($objRawContext.tableRows)) {
            if ($null -eq $objRawTableRow -or
                $objRawTableRow.range -isnot [array] -or
                $objRawTableRow.range.Count -ne 2 -or
                $objRawTableRow.cells -isnot [array] -or
                $objRawTableRow.cells.Count -eq 0) {
                throw 'The locked Markdown parser returned a malformed table row.'
            }

            $intStart = [int64] 0
            $intEnd = [int64] 0
            if (-not [int64]::TryParse([string]$objRawTableRow.range[0], [ref]$intStart) -or
                -not [int64]::TryParse([string]$objRawTableRow.range[1], [ref]$intEnd) -or
                $intStart -lt $intPreviousTableRowEnd -or
                $intStart -lt 0 -or
                $intEnd -le $intStart -or
                $intEnd -gt $LineCount) {
                throw 'The locked Markdown parser returned an invalid table-row range.'
            }

            $listCells = [Collections.Generic.List[pscustomobject]]::new()
            foreach ($objRawCell in @($objRawTableRow.cells)) {
                if ($null -eq $objRawCell -or
                    $objRawCell.tag -isnot [string] -or
                    @('th', 'td') -cnotcontains $objRawCell.tag -or
                    $objRawCell.text -isnot [string] -or
                    $objRawCell.code -isnot [array] -or
                    ($objRawCell.code.Count -ne 0 -and
                        @($objRawCell.code | Where-Object { $_ -isnot [string] }).Count -ne 0) -or
                    $objRawCell.links -isnot [array] -or
                    ($objRawCell.links.Count -ne 0 -and
                        @($objRawCell.links | Where-Object { $_ -isnot [string] }).Count -ne 0)) {
                    throw 'The locked Markdown parser returned a malformed table cell.'
                }
                $listCells.Add([pscustomobject]@{
                        Tag = [string]$objRawCell.tag
                        Start = [int]$intStart
                        End = [int]$intEnd
                        Text = [string]$objRawCell.text
                        Code = [string[]]@($objRawCell.code)
                        Links = [string[]]@($objRawCell.links)
                    })
            }

            $listTableRows.Add([pscustomobject]@{
                    Start = [int]$intStart
                    End = [int]$intEnd
                    Cells = [pscustomobject[]]$listCells.ToArray()
                })
            $intPreviousTableRowEnd = [int]$intEnd
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
                    } else {
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
                ($objRawListItem.code.Count -ne 0 -and
                    @($objRawListItem.code | Where-Object { $_ -isnot [string] }).Count -ne 0) -or
                $objRawListItem.links -isnot [array] -or
                ($objRawListItem.links.Count -ne 0 -and
                    @($objRawListItem.links | Where-Object { $_ -isnot [string] }).Count -ne 0)) {
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
                    } else {
                        [string]$objRawListItem.text
                    }
                    Code = [string[]]@($objRawListItem.code)
                    Links = [string[]]@($objRawListItem.links)
                })
            $intPreviousTopLevelListItemEnd = [int]$intEnd
        }

        $listHeadings = [Collections.Generic.List[pscustomobject]]::new()
        $intPreviousHeadingEnd = 0
        foreach ($objRawHeading in @($objRawContext.headings)) {
            if ($null -eq $objRawHeading -or
                $objRawHeading.tag -isnot [string] -or
                $objRawHeading.tag -cnotmatch '^h[1-6]$' -or
                $objRawHeading.range -isnot [array] -or
                $objRawHeading.range.Count -ne 2 -or
                $objRawHeading.text -isnot [string]) {
                throw 'The locked Markdown parser returned a malformed heading.'
            }

            $intStart = [int64] 0
            $intEnd = [int64] 0
            if (-not [int64]::TryParse([string]$objRawHeading.range[0], [ref]$intStart) -or
                -not [int64]::TryParse([string]$objRawHeading.range[1], [ref]$intEnd) -or
                $intStart -lt $intPreviousHeadingEnd -or
                $intStart -lt 0 -or
                $intEnd -le $intStart -or
                $intEnd -gt $LineCount) {
                throw 'The locked Markdown parser returned an invalid heading range.'
            }

            $listHeadings.Add([pscustomobject]@{
                    Tag = [string]$objRawHeading.tag
                    Start = [int]$intStart
                    End = [int]$intEnd
                    Text = [string]$objRawHeading.text
                })
            $intPreviousHeadingEnd = [int]$intEnd
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

        $objValidatedContext = [pscustomobject]@{
            CodeBlockRanges = [pscustomobject[]]$listRanges.ToArray()
            ProseBlocks = [pscustomobject[]]$listProseBlocks.ToArray()
            TableRows = [pscustomobject[]]$listTableRows.ToArray()
            TopLevelBlocks = [pscustomobject[]]$listTopLevelBlocks.ToArray()
            TopLevelListItems = [pscustomobject[]]$listTopLevelListItems.ToArray()
            Headings = [pscustomobject[]]$listHeadings.ToArray()
            LevelTwoHeadings = [pscustomobject[]]$listLevelTwoHeadings.ToArray()
        }
        if ($null -ne $ReuseSlot -and $ReuseSlot.Budget.Retained -lt 8) {
            $objCopy = Copy-MarkdownParseReuseContext -Context $objValidatedContext `
                -ParserText $Content -ParserOutput $strParserOutput
            if ($null -ne $objCopy) {
                $ReuseSlot.Snapshot = [pscustomobject]@{
                    ParserText = $Content
                    LineCount = $LineCount
                    ParserOutput = $strParserOutput
                    ParserDefinition = ${function:Get-MarkdownParseContext}
                    DecoderDefinition = ${function:ConvertFrom-ParserJsonContext}
                    CopyDefinition = ${function:Copy-MarkdownParseReuseContext}
                    Context = $objCopy.Context
                    Characters = $objCopy.Characters
                    Records = $objCopy.Records
                    Elements = $objCopy.Elements
                }
                $ReuseSlot.Budget.Retained++
            }
        }
        return $objValidatedContext
    } catch {
        $objPrimaryFailure = $_
        try { Clear-MarkdownParseReuseSlot -Slot $ReuseSlot } catch { Write-Verbose 'Reuse cleanup failed after validation failure.' }
        throw $objPrimaryFailure
    }
}

function Assert-MarkdownParserExactContext {
    # .SYNOPSIS
    # Confirms exact operative Markdown parsing behavior.
    #
    # .DESCRIPTION
    # Parses adversarial Markdown fixtures and confirms that only visible, operative content reaches policy checks.
    #
    # .EXAMPLE
    # Assert-MarkdownParserExactContext
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param()

    $strMarkdown = @(
        '## Transport'
        ''
        'Paragraph `code`.'
    ) -join "`n"
    $objContext = Get-MarkdownParseContext -Content $strMarkdown -LineCount 3
    $strActual = $objContext | ConvertTo-Json -Depth 5 -Compress
    $strExpected = '{"CodeBlockRanges":[],"ProseBlocks":[' +
        '{"Start":0,"End":1,"Text":"Transport","Code":[],"Links":[]},' +
        '{"Start":2,"End":3,"Text":"Paragraph .","Code":["code"],"Links":[]}],' +
        '"TableRows":[],' +
        '"TopLevelBlocks":[' +
        '{"Type":"heading_open","Tag":"h2","Start":0,"End":1,"Text":"Transport"},' +
        '{"Type":"paragraph_open","Tag":"p","Start":2,"End":3,"Text":"Paragraph ."}],' +
        '"TopLevelListItems":[],"Headings":[' +
        '{"Tag":"h2","Start":0,"End":1,"Text":"Transport"}],' +
        '"LevelTwoHeadings":[' +
        '{"Start":0,"End":1,"Text":"Transport"}]}'
    if ($strActual -cne $strExpected) {
        throw "Self-test 'ordinary exact Markdown parser context' changed output."
    }

    $strTableMarkdown = @(
        '| **Decision** `Status` | Value |'
        '| :--- | ---: |'
        '| Field | *Accepted* |'
    ) -join "`n"
    $objTableContext = Get-MarkdownParseContext `
        -Content $strTableMarkdown -LineCount 3
    if ($objTableContext.TableRows.Count -ne 2 -or
        $objTableContext.TableRows[0].Start -ne 0 -or
        $objTableContext.TableRows[0].End -ne 1 -or
        $objTableContext.TableRows[0].Cells.Count -ne 2 -or
        $objTableContext.TableRows[0].Cells[0].Tag -cne 'th' -or
        $objTableContext.TableRows[0].Cells[0].Text -cne 'Decision Status' -or
        $objTableContext.TableRows[0].Cells[0].Code.Count -ne 1 -or
        $objTableContext.TableRows[0].Cells[0].Code[0] -cne 'Status' -or
        $objTableContext.TableRows[1].Start -ne 2 -or
        $objTableContext.TableRows[1].End -ne 3 -or
        $objTableContext.TableRows[1].Cells[1].Tag -cne 'td' -or
        $objTableContext.TableRows[1].Cells[1].Text -cne 'Accepted') {
        throw "Self-test 'exact Markdown table context' changed output."
    }

    $strTopLevelListMarkdown = @(
        '- First paragraph.'
        ''
        '  Status: Accepted'
        ''
        '  > Status: Proposed'
        ''
        '  - Status: Deprecated'
    ) -join "`n"
    $objTopLevelListContext = Get-MarkdownParseContext `
        -Content $strTopLevelListMarkdown -LineCount 7
    if ($objTopLevelListContext.TopLevelListItems.Count -ne 2 -or
        $objTopLevelListContext.TopLevelListItems[0].Start -ne 0 -or
        $objTopLevelListContext.TopLevelListItems[0].End -ne 1 -or
        $objTopLevelListContext.TopLevelListItems[0].Text -cne 'First paragraph.' -or
        $objTopLevelListContext.TopLevelListItems[1].Start -ne 2 -or
        $objTopLevelListContext.TopLevelListItems[1].End -ne 3 -or
        $objTopLevelListContext.TopLevelListItems[1].Text -cne 'Status: Accepted') {
        throw "Self-test 'direct top-level list-item paragraphs' changed output."
    }

    $arrNestedTableFixtures = @(
        [pscustomobject]@{
            Name = 'blockquoted table'
            Content = @(
                '> | Field | Value |'
                '> | --- | --- |'
                '> | Status | Accepted |'
            ) -join "`n"
        },
        [pscustomobject]@{
            Name = 'listed table'
            Content = @(
                '- Example:'
                ''
                '  | Field | Value |'
                '  | --- | --- |'
                '  | Status | Accepted |'
            ) -join "`n"
        },
        [pscustomobject]@{
            Name = 'nested-list table'
            Content = @(
                '- Outer'
                '  - Inner:'
                ''
                '    | Field | Value |'
                '    | --- | --- |'
                '    | Status | Accepted |'
            ) -join "`n"
        }
    )
    foreach ($objNestedTableFixture in $arrNestedTableFixtures) {
        $intNestedTableLineCount = @(
            [regex]::Split($objNestedTableFixture.Content, '\r\n|\r|\n')
        ).Count
        $objNestedTableContext = Get-MarkdownParseContext `
            -Content $objNestedTableFixture.Content `
            -LineCount $intNestedTableLineCount
        if ($objNestedTableContext.TableRows.Count -ne 0) {
            throw "$($objNestedTableFixture.Name) became document-level table context."
        }
    }

    $strHeadingMarkdown = @(
        '## Context'
        '### Decision **Status**'
        '#### `Status`'
    ) -join "`n"
    $objHeadingContext = Get-MarkdownParseContext `
        -Content $strHeadingMarkdown -LineCount 3
    if ($objHeadingContext.Headings.Count -ne 3 -or
        $objHeadingContext.Headings[0].Tag -cne 'h2' -or
        $objHeadingContext.Headings[0].Text -cne 'Context' -or
        $objHeadingContext.Headings[1].Tag -cne 'h3' -or
        $objHeadingContext.Headings[1].Text -cne 'Decision Status' -or
        $objHeadingContext.Headings[2].Tag -cne 'h4' -or
        $objHeadingContext.Headings[2].Text -cne '' -or
        $objHeadingContext.LevelTwoHeadings.Count -ne 1 -or
        $objHeadingContext.LevelTwoHeadings[0].Text -cne 'Context') {
        throw "Self-test 'all Markdown headings context' changed output."
    }

    $strNestedHeadingMarkdown = @(
        '## Context'
        '> ### Decision Status'
        '- Item'
        '  #### Status'
        '```markdown'
        '##### Status'
        '```'
        '<!--'
        '###### Decision Status'
        '-->'
        '##### Decision Status'
    ) -join "`n"
    $objNestedHeadingContext = Get-MarkdownParseContext `
        -Content $strNestedHeadingMarkdown -LineCount 11
    $strNestedHeadingActual = [pscustomobject]@{
        CodeBlockRanges = $objNestedHeadingContext.CodeBlockRanges
        Headings = $objNestedHeadingContext.Headings
        LevelTwoHeadings = $objNestedHeadingContext.LevelTwoHeadings
    } | ConvertTo-Json -Depth 5 -Compress
    $strNestedHeadingExpected = '{"CodeBlockRanges":[' +
        '{"Start":4,"End":7}],"Headings":[' +
        '{"Tag":"h2","Start":0,"End":1,"Text":"Context"},' +
        '{"Tag":"h5","Start":10,"End":11,"Text":"Decision Status"}],' +
        '"LevelTwoHeadings":[{"Start":0,"End":1,"Text":"Context"}]}'
    if ($strNestedHeadingActual -cne $strNestedHeadingExpected) {
        throw "Self-test 'top-level Markdown headings context' changed output."
    }

    $strParserSource = [IO.File]::ReadAllText($PSCommandPath)
    $strTopLevelHeadingGuard =
        'if (token.type !== "heading_open" || token.level !== 0) return [];'
    $strNestedHeadingMutation = $strParserSource.Replace(
        $strTopLevelHeadingGuard,
        'if (token.type !== "heading_open") return [];'
    )
    if ($strNestedHeadingMutation -ceq $strParserSource -or
        $strNestedHeadingMutation.Contains(
            $strTopLevelHeadingGuard,
            [StringComparison]::Ordinal
        )) {
        throw 'The top-level heading collector mutation was not detected.'
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
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
        TableRows = [pscustomobject[]]$objParseContext.TableRows
        TopLevelBlocks = [pscustomobject[]]$objParseContext.TopLevelBlocks
        TopLevelListItems = [pscustomobject[]]$objParseContext.TopLevelListItems
        Headings = [pscustomobject[]]$objParseContext.Headings
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
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    # .DESCRIPTION
    # Inspects one validated Markdown context for an active Claude import.
    #
    # .PARAMETER Name
    # The fixture or document name to use in diagnostics.
    #
    # .PARAMETER MarkdownContext
    # The validated operative Markdown context to inspect.
    #
    # .EXAMPLE
    # Get-ClaudeImportFailure @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.String] Zero or more validated values or diagnostics described in the function description.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    # .DESCRIPTION
    # Inspects every cataloged nested Claude instruction context.
    #
    # .PARAMETER DocumentContexts
    # The cataloged nested instruction document contexts to inspect.
    #
    # .EXAMPLE
    # Get-NestedClaudeImportFailure @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.String] Zero or more validated values or diagnostics described in the function description.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
        } else {
            $listNormalizedLines.Add($strLine.TrimEnd([char[]] @(' ', "`t")))
        }
    }
    while ($listNormalizedLines.Count -gt 0 -and
        $listNormalizedLines[$listNormalizedLines.Count - 1].Length -eq 0) {
        $listNormalizedLines.RemoveAt($listNormalizedLines.Count - 1)
    }

    return $listNormalizedLines -join "`n"
}

function Get-PublishedEndpointLastUpdatedFailure {
    # .SYNOPSIS
    # Validates metadata and freshness with an optional Version field.
    #
    # .DESCRIPTION
    # Validates Last Updated and any present Version. A newly introduced
    # Version uses revision zero while retaining the actual parent for date
    # and rendered-content checks; optional removal also retains that parent.
    #
    # .PARAMETER Name
    # The fixture or document name to use in diagnostics.
    #
    # .PARAMETER CurrentContent
    # The exact content at the current event revision.
    #
    # .PARAMETER BaseContent
    # The exact content at the comparison revision.
    #
    # .PARAMETER TrustedEventUtcDate
    # The authenticated event date in UTC.
    #
    # .PARAMETER RequireCurrentMaximumDateForRenderedChange
    # Requires changed rendered content to use the latest allowed current date.
    #
    # .PARAMETER CurrentParseReuse
    # Borrowed private structural slot for current content.
    #
    # .PARAMETER ParentParseReuse
    # Borrowed private structural slot for prior content.
    #
    # .EXAMPLE
    # Get-PublishedEndpointLastUpdatedFailure @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.String] Zero or more validated values or diagnostics described in the function description.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.1.20261006.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $Name,
        [Parameter(Mandatory)][string] $CurrentContent,
        [Parameter()][AllowNull()][object] $BaseContent,
        [Parameter(Mandatory)][AllowEmptyString()][string] $TrustedEventUtcDate,
        [Parameter()][bool] $RequireCurrentMaximumDateForRenderedChange = $false,

        [Parameter()][AllowNull()][object] $CurrentParseReuse,
        [Parameter()][AllowNull()][object] $ParentParseReuse
    )

    $boolOwnParseReuse = $null -eq $CurrentParseReuse -and $null -eq $ParentParseReuse
    $objReusePrimaryFailure = $null
    try {
        if ($boolOwnParseReuse) {
            $CurrentParseReuse = Get-MarkdownParseReuseSlot
            $ParentParseReuse = Get-MarkdownParseReuseSlot -Budget $CurrentParseReuse.Budget
        }
        $objCurrentMetadata = Get-DocumentMetadataContext `
            -Content $CurrentContent -RequiresVersion $false -ReuseSlot $CurrentParseReuse
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
        if ([string]::CompareOrdinal(
                $strCurrentDate, $script:strMaximumMetadataUtcDate) -gt 0) {
            Write-Output "$Name Last Updated is later than trusted UTC."
            return
        }

        $boolRenderedContentChanged = $true
        $objBaseMetadata = $null
        if ($null -ne $BaseContent) {
            $objBaseMetadata = Get-DocumentMetadataContext `
                -Content $BaseContent -RequiresVersion $false -ReuseSlot $ParentParseReuse
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
        if ($null -ne $objBaseMetadata -and $null -ne $objBaseMetadata.VersionDate -and
            $null -eq $objCurrentMetadata.VersionDate) {
            Write-Output @(Get-PublishedEndpointMetadataFailure -Name "The parent of $Name" `
                    -CurrentContent $BaseContent -ParentContent $null -ExpectedUtcDate '' `
                    -IsNewDocumentTransition $false -RequireExpectedUtcDateForRenderedChange $false `
                    -CurrentParseReuse $ParentParseReuse)
        }
        if ($null -ne $objCurrentMetadata.VersionDate) {
            $objVersionParentContent = $null
            if ($null -ne $objBaseMetadata -and $null -ne $objBaseMetadata.VersionDate) {
                $objVersionParentContent = $BaseContent
            }
            # Null here describes only the new Version tuple. The actual parent
            # has already passed Last Updated and rendered-comparison checks above.
            Write-Output @(Get-PublishedEndpointMetadataFailure -Name $Name `
                    -CurrentContent $CurrentContent -ParentContent $objVersionParentContent `
                    -ExpectedUtcDate '' -IsNewDocumentTransition ($null -eq $objVersionParentContent) `
                    -RequireExpectedUtcDateForRenderedChange $false `
                    -CurrentParseReuse $CurrentParseReuse `
                    -ParentParseReuse $(if ($null -ne $objVersionParentContent) { $ParentParseReuse } else { $null }))
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
        } elseif ($RequireCurrentMaximumDateForRenderedChange -and
            -not $TrustedEventUtcDate -and
            $strCurrentDate -cne $script:strMaximumMetadataUtcDate) {
            Write-Output (
                "$Name Last Updated must be $script:strMaximumMetadataUtcDate " +
                'after a rendered-content change without a trusted event date.'
            )
        }
    } catch {
        $objReusePrimaryFailure = $_
        throw
    } finally {
        if ($boolOwnParseReuse) {
            foreach ($objSlot in @($CurrentParseReuse, $ParentParseReuse)) {
                try { Clear-MarkdownParseReuseSlot -Slot $objSlot } catch {
                    if ($null -eq $objReusePrimaryFailure) { throw }
                }
            }
        }
    }
}

function Get-MarkdownParserBootstrapFailure {
    # .SYNOPSIS
    # Reports a missing locked Markdown parser bootstrap.
    #
    # .DESCRIPTION
    # Checks that the locked Markdown parser dependency and runtime are available.
    #
    # .PARAMETER RepositoryRootPath
    # The absolute path of the trusted Git repository.
    #
    # .EXAMPLE
    # Get-MarkdownParserBootstrapFailure @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.String] Zero or more validated values or diagnostics described in the function description.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param([Parameter(Mandatory)][string] $RepositoryRootPath)

    $strMarkdownParserPath = Join-Path -Path $RepositoryRootPath `
        -ChildPath 'node_modules/markdown-it/package.json'
    if (-not (Test-Path -LiteralPath $strMarkdownParserPath -PathType Leaf)) {
        Write-Output (
            'Locked Node.js dependencies are missing. Run ' +
            '`node .github/workflows/NpmTools.mjs install` before pre-commit validation.'
        )
    }
}

function Invoke-SafeTemporaryDirectoryRemoval {
    # .SYNOPSIS
    # Removes one validated temporary directory with bounded retries.
    #
    # .DESCRIPTION
    # Confirms that the directory is a child of the supplied system temporary root,
    # retries transient recursive-delete failures, and fails after the exact bound.
    #
    # .PARAMETER LiteralPath
    # The exact temporary directory to remove.
    #
    # .PARAMETER SystemTemporaryRootPath
    # The normalized system temporary root that must contain LiteralPath.
    #
    # .PARAMETER MaximumAttempts
    # The maximum number of recursive-delete attempts.
    #
    # .PARAMETER InitialDelayMilliseconds
    # The delay before the second attempt. Each later delay doubles.
    #
    # .EXAMPLE
    # Invoke-SafeTemporaryDirectoryRemoval @hashtableArguments
    #
    # # Removes one validated fixture directory.
    #
    # .INPUTS
    # None. Pipeline input is not accepted.
    #
    # .OUTPUTS
    # None.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $LiteralPath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $SystemTemporaryRootPath,

        [Parameter()]
        [ValidateRange(1, 10)]
        [int] $MaximumAttempts = 5,

        [Parameter()]
        [ValidateRange(1, 1000)]
        [int] $InitialDelayMilliseconds = 50
    )

    $strValidatedTemporaryRoot = [IO.Path]::GetFullPath(
        $SystemTemporaryRootPath
    ).TrimEnd(
        [IO.Path]::DirectorySeparatorChar,
        [IO.Path]::AltDirectorySeparatorChar
    )
    $strValidatedDirectoryPath = [IO.Path]::GetFullPath($LiteralPath)
    $strRequiredPrefix = $strValidatedTemporaryRoot +
        [IO.Path]::DirectorySeparatorChar
    if (-not $strValidatedDirectoryPath.StartsWith(
            $strRequiredPrefix,
            [StringComparison]::OrdinalIgnoreCase
        )) {
        throw 'Refusing to remove a directory outside the system temporary root.'
    }

    for ($intAttempt = 1; $intAttempt -le $MaximumAttempts; $intAttempt++) {
        if (-not [IO.Directory]::Exists($strValidatedDirectoryPath)) {
            return
        }
        try {
            Remove-Item -LiteralPath $strValidatedDirectoryPath -Recurse -Force `
                -ErrorAction Stop
        } catch {
            if ($intAttempt -eq $MaximumAttempts) {
                throw
            }
        }
        if (-not [IO.Directory]::Exists($strValidatedDirectoryPath)) {
            return
        }
        if ($intAttempt -eq $MaximumAttempts) {
            throw 'The temporary fixture directory still exists after cleanup.'
        }
        $intDelayMilliseconds = [int] (
            $InitialDelayMilliseconds * [Math]::Pow(2, $intAttempt - 1)
        )
        Start-Sleep -Milliseconds $intDelayMilliseconds
    }
}

function Test-RecursivePersonalMemoryIgnoreContract {
    # .SYNOPSIS
    # Proves an all-depth personal-memory exclusion in the root ignore file.
    #
    # .DESCRIPTION
    # Supports a root-only tracked ignore inventory. A canonical recursive
    # exclusion must follow every negation; native Git probes remain separate.
    # Nested or case-alias ignore files invalidate this bounded proof.
    #
    # .PARAMETER GitIgnoreContent
    # The exact root .gitignore text, not user-local exclusion configuration.
    #
    # .PARAMETER TrackedPath
    # The complete bounded candidate tracked-path inventory.
    #
    # .EXAMPLE
    # Test-RecursivePersonalMemoryIgnoreContract @hashtableArguments
    #
    # # Returns true only for the supported root-only all-depth contract.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.Boolean] Whether the bounded recursive proof succeeds.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261002.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $GitIgnoreContent,
        [Parameter(Mandatory)][AllowEmptyCollection()][string[]] $TrackedPath
    )

    if ($TrackedPath -cnotcontains '.gitignore') { return $false }
    foreach ($strTrackedPath in $TrackedPath) {
        if ($strTrackedPath -imatch '(^|/)\.gitignore$' -and
            $strTrackedPath -cne '.gitignore') {
            return $false
        }
    }
    $boolRecursiveExclusion = $false
    foreach ($strRawLine in ($GitIgnoreContent -split '\r?\n')) {
        # Git ignores unescaped trailing spaces; leading spaces remain literal.
        $strLine = $strRawLine.TrimEnd([char]' ')
        if (@('CLAUDE.local.md', '**/CLAUDE.local.md') -ccontains $strLine) {
            $boolRecursiveExclusion = $true
        } elseif ($strLine.Length -gt 1 -and
            $strLine.StartsWith('!', [StringComparison]::Ordinal)) {
            $boolRecursiveExclusion = $false
        }
    }
    return $boolRecursiveExclusion
}

function Test-GitIgnorePathEffective {
    # .SYNOPSIS
    # Tests whether a Git ignore rule excludes one exact path.
    #
    # .DESCRIPTION
    # Evaluates the supplied ignore rules against one exact repository-relative path.
    #
    # .PARAMETER GitIgnoreContent
    # The exact .gitignore text to evaluate.
    #
    # .PARAMETER RepositoryRelativePath
    # The canonical repository-relative path to inspect.
    #
    # .EXAMPLE
    # Test-GitIgnorePathEffective @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.Boolean] True when the condition in the synopsis is satisfied; otherwise false.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $GitIgnoreContent,

        [Parameter(Mandatory)]
        [string] $RepositoryRelativePath
    )

    if ($RepositoryRelativePath.StartsWith('-', [StringComparison]::Ordinal) -or
        [IO.Path]::IsPathRooted($RepositoryRelativePath) -or
        $RepositoryRelativePath -match '(^|/)\.\.?(/|$)' -or
        $RepositoryRelativePath.Contains('\', [StringComparison]::Ordinal)) {
        throw 'The effective-ignore probe path is invalid.'
    }

    $strSystemTempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    $strFixtureRoot = [IO.Path]::Combine(
        $strSystemTempRoot,
        'agent-instruction-gitignore-' + [Guid]::NewGuid().ToString('N')
    )
    [void][IO.Directory]::CreateDirectory($strFixtureRoot)
    try {
        $objUtf8WithoutBom = [Text.UTF8Encoding]::new($false)
        $strEmptyExcludesPath = [IO.Path]::Combine($strFixtureRoot, 'empty-excludes')
        [IO.File]::WriteAllText(
            [IO.Path]::Combine($strFixtureRoot, '.gitignore'),
            $GitIgnoreContent,
            $objUtf8WithoutBom
        )
        [IO.File]::WriteAllText($strEmptyExcludesPath, '', $objUtf8WithoutBom)
        & git -C $strFixtureRoot init --quiet
        if ($LASTEXITCODE -ne 0) {
            throw 'Could not initialize the effective-ignore fixture.'
        }
        & git -C $strFixtureRoot `
            -c "core.excludesFile=$strEmptyExcludesPath" `
            check-ignore --no-index --quiet -- $RepositoryRelativePath
        $intCheckIgnoreExitCode = $LASTEXITCODE
        if ($intCheckIgnoreExitCode -eq 0) {
            return $true
        }
        if ($intCheckIgnoreExitCode -eq 1) {
            return $false
        }
        throw 'Git could not evaluate the proposed ignore rules.'
    } finally {
        if ([IO.Directory]::Exists($strFixtureRoot) -and
            $strFixtureRoot.StartsWith(
                $strSystemTempRoot,
                [StringComparison]::OrdinalIgnoreCase
            )) {
            Remove-Item -LiteralPath $strFixtureRoot -Recurse -Force
        }
    }
}

function Test-ProhibitedClaudeLocalPath {
    # .SYNOPSIS
    # Tests whether a tracked path is prohibited operative local Claude memory.
    #
    # .DESCRIPTION
    # Classifies one repository-relative path under the prohibited Claude local-memory policy.
    #
    # .PARAMETER RepositoryRelativePath
    # The canonical repository-relative path to inspect.
    #
    # .EXAMPLE
    # Test-ProhibitedClaudeLocalPath @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.Boolean] True when the condition in the synopsis is satisfied; otherwise false.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([bool])]
    param([Parameter(Mandatory)][string] $RepositoryRelativePath)

    return $RepositoryRelativePath -imatch '^(?:[^/]+/)*CLAUDE\.local\.md$'
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
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    #
    # .DESCRIPTION
    # Compares one path with the governed root paths.
    #
    # .PARAMETER RepositoryRelativePath
    # The canonical repository-relative path to inspect.
    #
    # .PARAMETER GovernedRootPaths
    # The canonical governed root instruction paths.
    #
    # .EXAMPLE
    # Test-GovernedInstructionPathCaseMismatch @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.Boolean] True when the condition in the synopsis is satisfied; otherwise false.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    #
    # .DESCRIPTION
    # Compares one path with an exact reviewed path set.
    #
    # .PARAMETER RepositoryRelativePath
    # The canonical repository-relative path to inspect.
    #
    # .PARAMETER CanonicalPaths
    # The exact canonical paths accepted by the policy.
    #
    # .EXAMPLE
    # Test-ExactPathCaseMismatch @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.Boolean] True when the condition in the synopsis is satisfied; otherwise false.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    #
    # .DESCRIPTION
    # Selects canonical governed instruction paths and their case-folded near-matches for closed-world inventory checks.
    #
    # .PARAMETER RepositoryRelativePath
    # The canonical repository-relative path to inspect.
    #
    # .EXAMPLE
    # Test-GovernedInstructionInventoryPath @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.Boolean] True when the condition in the synopsis is satisfied; otherwise false.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    #
    # .DESCRIPTION
    # Tests one changed path against the exact set that activates agent-instruction validation.
    #
    # .PARAMETER RepositoryRelativePath
    # The canonical repository-relative path to inspect.
    #
    # .EXAMPLE
    # Test-AgentInstructionWorkflowPath @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.Boolean] True when the condition in the synopsis is satisfied; otherwise false.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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

function Get-DecisionRecordPathFailure {
    # .SYNOPSIS
    # Gets a decision-name failure.
    #
    # .DESCRIPTION
    # Validates one decision-record path against the canonical numbered filename contract.
    #
    # .PARAMETER RepositoryRelativePath
    # The canonical repository-relative path to inspect.
    #
    # .EXAMPLE
    # Get-DecisionRecordPathFailure @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.String] Zero or more validated values or diagnostics described in the function description.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param([Parameter(Mandatory)][string] $RepositoryRelativePath)

    if ($RepositoryRelativePath -cmatch $script:strDecisionRecordDirectoryPathPattern -and
        $RepositoryRelativePath -cnotmatch $script:strDecisionRecordPathPattern) {
        Write-Output "$RepositoryRelativePath must use docs/decisions/NNNN-short-title.md."
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
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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

function Get-DecisionLifecyclePolicyFailure {
    # .SYNOPSIS
    # Finds an invalid decision-record lifecycle policy.
    #
    # .DESCRIPTION
    # Requires one decision-record Status representation, the four retained
    # lifecycle values, an explicit prohibition on a second narrative status,
    # and the unchanged-byte legacy migration boundary.
    #
    # .PARAMETER Content
    # The documentation instruction content to inspect.
    #
    # .EXAMPLE
    # Get-DecisionLifecyclePolicyFailure -Content $strDocs
    #
    # # Returns one string for each lifecycle-policy failure.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [string] One record for each decision lifecycle policy failure.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [string] $Content
    )

    $arrSectionMatches = @([regex]::Matches(
            $Content,
            '(?ms)^## Decision Record Standards\s*\r?\n(?<Body>.*?)(?=^## |\z)'
        ))
    if ($arrSectionMatches.Count -ne 1) {
        Write-Output (
            'Documentation instructions must contain exactly one Decision Record ' +
            'Standards section.'
        )
        return
    }

    $strSectionBody = $arrSectionMatches[0].Groups['Body'].Value
    if ([regex]::Matches($strSectionBody, '\*\*Status\*\*').Count -ne 1) {
        Write-Output (
            'Decision records must use exactly one Tier 1 Status representation.'
        )
    }

    $arrAllowedValuesMatches = @([regex]::Matches(
            $strSectionBody,
            'For decision records, its value MUST be ' +
                '(?<Values>[A-Za-z]+(?: \| [A-Za-z]+)+)\.'
        ))
    $strExpectedValues = 'Proposed | Accepted | Superseded | Deprecated'
    if ($arrAllowedValuesMatches.Count -ne 1 -or
        $arrAllowedValuesMatches[0].Groups['Values'].Value -cne $strExpectedValues) {
        Write-Output (
            'Decision record Status must allow exactly ' + $strExpectedValues + '.'
        )
    }

    if ([regex]::Matches(
            $strSectionBody,
            'A decision record MUST NOT add a separate narrative status field or section\.'
        ).Count -ne 1) {
        Write-Output (
            'Decision records must prohibit a separate narrative status representation.'
        )
    }

    if ([regex]::Matches(
            $strSectionBody,
            ('Published legacy decision records that predate this lifecycle rule ' +
                'MAY retain their existing status representation while their bytes ' +
                'remain unchanged\. The next change to such a record MUST migrate it ' +
                'to the single Tier 1 Status metadata field and MUST remove each ' +
                'separate narrative status field or section\.')
        ).Count -ne 1) {
        Write-Output (
            'Decision records must document the unchanged legacy migration boundary.'
        )
    }
}

function Test-DecisionLifecycleStatusLabel {
    # .SYNOPSIS
    # Tests one normalized decision lifecycle label.
    #
    # .DESCRIPTION
    # Returns true only for Status or Decision Status after trimming and
    # collapsing whitespace. Comparison is case-insensitive.
    #
    # .PARAMETER Label
    # The heading or field label to test.
    #
    # .EXAMPLE
    # Test-DecisionLifecycleStatusLabel -Label 'Decision Status'
    #
    # # Returns true.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [bool] True only for one exact supported lifecycle label.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyString()]
        [string] $Label
    )

    $strNormalizedLabel = [regex]::Replace($Label.Trim(), '\s+', ' ')
    return (
        $strNormalizedLabel -ieq 'Status' -or
        $strNormalizedLabel -ieq 'Decision Status'
    )
}

function Get-DecisionRecordLifecycleFailure {
    # .SYNOPSIS
    # Finds lifecycle representation failures in one decision record.
    #
    # .DESCRIPTION
    # Requires one four-state metadata Status and no separate structured Status
    # field or section for a new or changed ADR. An unchanged published legacy ADR
    # remains valid until its next content change under the migration boundary.
    # Uses validated parser coordinates to exempt only the canonical Status
    # list item in either direct or headed metadata.
    #
    # .PARAMETER Name
    # The repository-relative decision-record path.
    #
    # .PARAMETER CurrentContent
    # The final decision-record content.
    #
    # .PARAMETER BaselineContent
    # The published baseline content, or null when no baseline document exists.
    #
    # .EXAMPLE
    # Get-DecisionRecordLifecycleFailure @hashtableArguments
    #
    # # Returns lifecycle failures for one changed decision record.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [string] Zero or more lifecycle diagnostics.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.1
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][string] $Name,
        [Parameter(Mandatory)][string] $CurrentContent,
        [Parameter()][AllowNull()][string] $BaselineContent
    )

    if ($null -ne $BaselineContent -and
        $CurrentContent -ceq $BaselineContent) {
        return
    }
    $objMetadata = Get-DocumentMetadataContext `
        -Content $CurrentContent -RequiresVersion $false
    if ($null -ne $objMetadata.Failure) {
        return
    }
    $arrAllowedStatuses = @(
        'Proposed', 'Accepted', 'Superseded', 'Deprecated'
    )
    if ($arrAllowedStatuses -cnotcontains $objMetadata.Status) {
        Write-Output (
            "$Name Status must be Proposed, Accepted, Superseded, or Deprecated."
        )
    }
    $objMarkdownContext = $objMetadata.MarkdownParseContext
    if (@($objMarkdownContext.Headings |
            Where-Object {
                $_.Tag -cne 'h1' -and
                (Test-DecisionLifecycleStatusLabel -Label $_.Text)
            }).Count -ne 0) {
        Write-Output "$Name must not contain a separate operative Status section."
    }
    $arrTopLevelLifecycleFieldBlocks = @(
        $objMarkdownContext.TopLevelBlocks |
            Where-Object { $_.Type -ceq 'paragraph_open' }
        $objMarkdownContext.TopLevelListItems
    )
    if (@($arrTopLevelLifecycleFieldBlocks |
            Where-Object {
                $boolCanonicalMetadataStatus =
                    $_.Start -eq $objMetadata.StatusLineIndex -and
                    $_.Start -ge $objMetadata.MetadataListStart -and
                    $_.End -le $objMetadata.MetadataListEnd
                $objFieldMatch = [regex]::Match(
                    $_.Text,
                    '^\s*(?<Label>[^:\r\n]+?)\s*:\s*\S'
                )
                -not $boolCanonicalMetadataStatus -and
                    $objFieldMatch.Success -and
                    (Test-DecisionLifecycleStatusLabel `
                        -Label $objFieldMatch.Groups['Label'].Value)
            }).Count -ne 0) {
        Write-Output (
            "$Name must not contain a separate operative Status field."
        )
    }
    if (@($objMarkdownContext.TableRows |
            Where-Object {
                $boolHasStatusField = $false
                if ($_.Cells.Count -eq 2 -and
                    $_.Cells[0].Tag -ceq 'td' -and
                    $_.Cells[1].Tag -ceq 'td') {
                    $strValue = [regex]::Replace(
                        $_.Cells[1].Text.Trim(),
                        '\s+',
                        ' '
                    )
                    $boolHasStatusField =
                        (Test-DecisionLifecycleStatusLabel `
                            -Label $_.Cells[0].Text) -and
                        -not [string]::IsNullOrWhiteSpace($strValue)
                }
                $boolHasStatusField
            }).Count -ne 0) {
        Write-Output (
            "$Name must not contain a separate operative Status field."
        )
    }
}

function Get-DocumentMetadataClassificationContext {
    # .SYNOPSIS
    # Parses the inert Markdown classification manifest.
    #
    # .DESCRIPTION
    # Requires a strict, bounded JSON object with one schema version and sorted
    # exact-path arrays for Tier 2, generated, and future authorized exemptions.
    # Active exemptions must be safe tracked Markdown paths. Authorization paths
    # are inert until they exist in a trusted published baseline.
    #
    # .PARAMETER Content
    # The strict JSON manifest text.
    #
    # .PARAMETER TrackedPath
    # The complete tracked repository path inventory at the validation revision.
    #
    # .EXAMPLE
    # Get-DocumentMetadataClassificationContext `
    #     -Content '{"schemaVersion":2,"authorizedExemptionPaths":[],"tier2Paths":[],"generatedPaths":[]}' `
    #     -TrackedPath @()
    #
    # # Returns an empty, valid exemption set.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [pscustomobject] Failure, schema, exact categories, and authorization paths.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the
    # public API surface. Parameters, return shape, and positional
    # contract may change without notice.
    #
    # This function does not support positional parameters.
    # Version: 1.2.20261002.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [string] $Content,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]] $TrackedPath
    )

    $scriptBlockFailure = {
        param([string] $Message)

        return [pscustomobject]@{
            Failure = $Message
            SchemaVersion = 0
            Tier2Paths = [string[]]@()
            GeneratedPaths = [string[]]@()
            ExemptPaths = [string[]]@()
            AuthorizedExemptionPaths = [string[]]@()
        }
    }
    $objJsonOptions = [System.Text.Json.JsonDocumentOptions]@{
        AllowTrailingCommas = $false
        CommentHandling = [System.Text.Json.JsonCommentHandling]::Disallow
        MaxDepth = 8
    }
    $objJsonDocument = $null
    try {
        $objJsonDocument = [System.Text.Json.JsonDocument]::Parse(
            $Content,
            $objJsonOptions
        )
        $objRoot = $objJsonDocument.RootElement
        if ($objRoot.ValueKind -ne [System.Text.Json.JsonValueKind]::Object) {
            return & $scriptBlockFailure `
                -Message 'The document classification manifest root must be an object.'
        }

        $dictionaryProperties =
            [System.Collections.Generic.Dictionary[
                string,
                System.Text.Json.JsonElement
            ]]::new([System.StringComparer]::Ordinal)
        $arrAllowedProperties = @(
            'schemaVersion',
            'authorizedExemptionPaths',
            'tier2Paths',
            'generatedPaths'
        )
        foreach ($objProperty in $objRoot.EnumerateObject()) {
            if ($arrAllowedProperties -cnotcontains $objProperty.Name) {
                return & $scriptBlockFailure -Message (
                    'The document classification manifest contains an unknown property: ' +
                    $objProperty.Name
                )
            }
            if ($dictionaryProperties.ContainsKey($objProperty.Name)) {
                return & $scriptBlockFailure -Message (
                    'The document classification manifest contains a duplicate property: ' +
                    $objProperty.Name
                )
            }
            $dictionaryProperties.Add($objProperty.Name, $objProperty.Value.Clone())
        }
        foreach ($strRequiredProperty in $arrAllowedProperties) {
            if (-not $dictionaryProperties.ContainsKey($strRequiredProperty)) {
                return & $scriptBlockFailure -Message (
                    'The document classification manifest is missing property: ' +
                    $strRequiredProperty
                )
            }
        }

        $intSchemaVersion = 0
        if ($dictionaryProperties['schemaVersion'].ValueKind -ne [System.Text.Json.JsonValueKind]::Number -or
            -not $dictionaryProperties['schemaVersion'].TryGetInt32(
                [ref]$intSchemaVersion
            ) -or $intSchemaVersion -ne 2) {
            return & $scriptBlockFailure `
                -Message 'The document classification schemaVersion must be integer 2.'
        }

        $setTrackedPaths = [System.Collections.Generic.HashSet[string]]::new(
            $TrackedPath,
            [System.StringComparer]::Ordinal
        )
        $setExemptPaths = [System.Collections.Generic.HashSet[string]]::new(
            [System.StringComparer]::Ordinal
        )
        $listExemptPaths = [System.Collections.Generic.List[string]]::new()
        $dictionaryCategoryPaths = @{}
        foreach ($strArrayProperty in @('tier2Paths', 'generatedPaths')) {
            $listCategoryPaths = [Collections.Generic.List[string]]::new()
            $objArray = $dictionaryProperties[$strArrayProperty]
            if ($objArray.ValueKind -ne [System.Text.Json.JsonValueKind]::Array) {
                return & $scriptBlockFailure -Message (
                    "The document classification $strArrayProperty value must be an array."
                )
            }
            $strPreviousPath = $null
            foreach ($objPathValue in $objArray.EnumerateArray()) {
                if ($objPathValue.ValueKind -ne [System.Text.Json.JsonValueKind]::String) {
                    return & $scriptBlockFailure -Message (
                        "The document classification $strArrayProperty entries must be strings."
                    )
                }
                $strPath = $objPathValue.GetString()
                if ([string]::IsNullOrWhiteSpace($strPath) -or
                    [System.IO.Path]::IsPathRooted($strPath) -or
                    $strPath.Contains('\', [System.StringComparison]::Ordinal) -or
                    $strPath -match '(?:^|/)\.\.(?:/|$)' -or
                    $strPath -match '[\x00-\x1f\x7f]' -or
                    $strPath -inotmatch '\.(?:md|mdc)$') {
                    return & $scriptBlockFailure -Message (
                        "The document classification contains an unsafe path: $strPath"
                    )
                }
                if ($null -ne $strPreviousPath -and
                    [string]::CompareOrdinal($strPreviousPath, $strPath) -ge 0) {
                    return & $scriptBlockFailure -Message (
                        "The document classification $strArrayProperty array must be " +
                        'strictly ordinal-sorted and duplicate-free.'
                    )
                }
                if (-not $setExemptPaths.Add($strPath)) {
                    return & $scriptBlockFailure -Message (
                        "The document classification repeats a path: $strPath"
                    )
                }
                if (-not $setTrackedPaths.Contains($strPath)) {
                    return & $scriptBlockFailure -Message (
                        "The document classification path is not tracked: $strPath"
                    )
                }
                $listExemptPaths.Add($strPath)
                $listCategoryPaths.Add($strPath)
                $strPreviousPath = $strPath
            }
            $dictionaryCategoryPaths[$strArrayProperty] = $listCategoryPaths.ToArray()
        }

        $objAuthorizationArray = $dictionaryProperties['authorizedExemptionPaths']
        if ($objAuthorizationArray.ValueKind -ne [System.Text.Json.JsonValueKind]::Array) {
            return & $scriptBlockFailure -Message (
                'The document classification authorizedExemptionPaths value must be an array.'
            )
        }
        $listAuthorizedExemptionPaths = [System.Collections.Generic.List[string]]::new()
        $strPreviousAuthorizationPath = $null
        foreach ($objPathValue in $objAuthorizationArray.EnumerateArray()) {
            if ($objPathValue.ValueKind -ne [System.Text.Json.JsonValueKind]::String) {
                return & $scriptBlockFailure -Message (
                    'The document classification authorizedExemptionPaths entries must be strings.'
                )
            }
            $strPath = $objPathValue.GetString()
            if ([string]::IsNullOrWhiteSpace($strPath) -or
                [System.IO.Path]::IsPathRooted($strPath) -or
                $strPath.Contains('\', [System.StringComparison]::Ordinal) -or
                $strPath -match '(?:^|/)\.\.(?:/|$)' -or
                $strPath -match '[\x00-\x1f\x7f]' -or
                $strPath -inotmatch '\.(?:md|mdc)$') {
                return & $scriptBlockFailure -Message (
                    "The document classification contains an unsafe path: $strPath"
                )
            }
            if ($null -ne $strPreviousAuthorizationPath -and
                [string]::CompareOrdinal(
                    $strPreviousAuthorizationPath,
                    $strPath
                ) -ge 0) {
                return & $scriptBlockFailure -Message (
                    'The document classification authorizedExemptionPaths array must be ' +
                    'strictly ordinal-sorted and duplicate-free.'
                )
            }
            if ($setExemptPaths.Contains($strPath) -or
                $listAuthorizedExemptionPaths.Contains($strPath)) {
                return & $scriptBlockFailure -Message (
                    "The document classification repeats a path: $strPath"
                )
            }
            $listAuthorizedExemptionPaths.Add($strPath)
            $strPreviousAuthorizationPath = $strPath
        }

        return [pscustomobject]@{
            Failure = $null
            SchemaVersion = $intSchemaVersion
            Tier2Paths = [string[]]$dictionaryCategoryPaths['tier2Paths']
            GeneratedPaths = [string[]]$dictionaryCategoryPaths['generatedPaths']
            ExemptPaths = [string[]]$listExemptPaths.ToArray()
            AuthorizedExemptionPaths =
                [string[]]$listAuthorizedExemptionPaths.ToArray()
        }
    }
    catch [System.Text.Json.JsonException] {
        return & $scriptBlockFailure `
            -Message 'The document classification manifest is not strict JSON.'
    }
    finally {
        if ($null -ne $objJsonDocument) {
            $objJsonDocument.Dispose()
        }
    }
}

function Get-InitialDocumentMetadataClassificationFailure {
    # .SYNOPSIS
    # Validates the one supported initial classification mapping.
    #
    # .DESCRIPTION
    # Requires the exact known manifest-absent baseline and prior validator.
    # Validates parsed category mappings, not formatting or candidate assertions.
    # This bootstrap check does not establish first-install or merge authority.
    #
    # .PARAMETER BaselineRevision
    # The exact trusted baseline, whose manifest absence the caller proved.
    #
    # .PARAMETER TrustedBaselineValidatorSha256
    # SHA-256 of the bounded regular validator blob at the trusted baseline.
    #
    # .PARAMETER CandidateContext
    # The result from the shared strict classification parser.
    #
    # .EXAMPLE
    # Get-InitialDocumentMetadataClassificationFailure @hashtableArguments
    #
    # # Returns no failure only for the closed initial mapping.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.String] Zero or more bootstrap failures.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261002.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $BaselineRevision,
        [Parameter(Mandatory)][AllowEmptyString()][string] $TrustedBaselineValidatorSha256,
        [Parameter(Mandatory)][pscustomobject] $CandidateContext
    )

    if ($BaselineRevision -cne 'a71f16a8d76beeca1ba8fdc3b1c95e1958e0973c' -or
        $TrustedBaselineValidatorSha256 -cne
        '5a61845f756be1d1bc4ddb772ffbc6c71ab525f0394d11d8c672f998a05fb4a5') {
        Write-Output 'The manifest-absent classification baseline is not the supported exact initialization.'
        return
    }
    $arrInitialTier2Paths = @(
        'ACKNOWLEDGMENTS.md', 'CONTRIBUTING.md', 'README.md',
        'samples/test-nested-markdown-linting.md', 'samples/test-recursive-nested-markdown.md')
    $arrInitialGeneratedPaths = @(
        'STYLE_GUIDE_CHAT.md', 'STYLE_GUIDE_FULL.md',
        'copilot-instructions.md', 'powershell.instructions.md')
    if ($null -ne $CandidateContext.Failure -or
        $CandidateContext.SchemaVersion -ne 2 -or
        $CandidateContext.AuthorizedExemptionPaths.Count -ne 0 -or
        ($CandidateContext.Tier2Paths -join "`n") -cne ($arrInitialTier2Paths -join "`n") -or
        ($CandidateContext.GeneratedPaths -join "`n") -cne ($arrInitialGeneratedPaths -join "`n")) {
        Write-Output 'The initial classification must retain the exact reviewed Tier 2/generated mappings and empty authorizations.'
    }
}

function Get-DocumentMetadataClassificationExpansionFailure {
    # .SYNOPSIS
    # Rejects candidate-only Markdown metadata exemptions.
    #
    # .DESCRIPTION
    # Compares the parsed candidate exemption set with an authenticated baseline.
    # A new active exemption must already be active or authorized in the trusted
    # published baseline. Candidate-only authorizations are inert. A missing
    # baseline manifest fails this helper and requires the separate closed
    # initialization proof.
    # Generated status must already be generated or authorized in the baseline;
    # membership in the baseline Tier2 category does not authorize that change.
    # Removals and generated-to-Tier2 moves strengthen metadata validation.
    #
    # .PARAMETER HasTrustedBaselineManifest
    # Indicates that the authenticated baseline contains the manifest.
    #
    # .PARAMETER TrustedBaselineExemptPath
    # Parsed exact exemptions in the authenticated baseline.
    #
    # .PARAMETER TrustedBaselineAuthorizedExemptionPath
    # Parsed exact future exemptions authorized in the authenticated baseline.
    #
    # .PARAMETER CandidateExemptPath
    # Parsed exact exemptions in the candidate revision.
    #
    # .PARAMETER TrustedBaselineGeneratedPath
    # Parsed generated paths in the authenticated baseline.
    #
    # .PARAMETER CandidateGeneratedPath
    # Parsed generated paths in the candidate revision.
    #
    # .EXAMPLE
    # Get-DocumentMetadataClassificationExpansionFailure `
    #     -HasTrustedBaselineManifest $true `
    #     -TrustedBaselineExemptPath @('README.md') `
    #     -TrustedBaselineAuthorizedExemptionPath @('docs/guide.md') `
    #     -CandidateExemptPath @('README.md', 'docs/RUNBOOK.md') `
    #     -TrustedBaselineGeneratedPath @() -CandidateGeneratedPath @()
    #
    # # Reports docs/RUNBOOK.md as an unauthenticated exemption addition.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [string] One failure for each unauthorized exemption or generated classification.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the
    # public API surface. Parameters, return shape, and positional
    # contract may change without notice.
    #
    # This function does not support positional parameters.
    # Version: 1.2.20261002.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [bool] $HasTrustedBaselineManifest,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]] $TrustedBaselineExemptPath,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]] $TrustedBaselineAuthorizedExemptionPath,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]] $CandidateExemptPath,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]] $TrustedBaselineGeneratedPath,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]] $CandidateGeneratedPath
    )

    if (-not $HasTrustedBaselineManifest) {
        Write-Output 'Classification expansion requires a trusted manifest or the separately proved closed initialization.'
        return
    }
    $setTrustedBaselineExemptPaths =
        [System.Collections.Generic.HashSet[string]]::new(
            $TrustedBaselineExemptPath,
            [System.StringComparer]::Ordinal
        )
    $setTrustedBaselineAuthorizedExemptionPaths =
        [System.Collections.Generic.HashSet[string]]::new(
            $TrustedBaselineAuthorizedExemptionPath,
            [System.StringComparer]::Ordinal
        )
    $setTrustedBaselineGeneratedPaths =
        [System.Collections.Generic.HashSet[string]]::new(
            $TrustedBaselineGeneratedPath,
            [System.StringComparer]::Ordinal
        )
    foreach ($strCandidateExemptPath in $CandidateExemptPath) {
        if ($setTrustedBaselineExemptPaths.Contains($strCandidateExemptPath) -or
            $setTrustedBaselineAuthorizedExemptionPaths.Contains(
                $strCandidateExemptPath
            )) {
            continue
        }
        Write-Output (
            'The document classification adds an unauthenticated metadata ' +
            "exemption: $strCandidateExemptPath. Add the exact path to " +
            'authorizedExemptionPaths in a separate change and publish that ' +
            'authorization before activating the exemption.'
        )
    }
    foreach ($strCandidateGeneratedPath in $CandidateGeneratedPath) {
        if ($setTrustedBaselineGeneratedPaths.Contains($strCandidateGeneratedPath) -or
            $setTrustedBaselineAuthorizedExemptionPaths.Contains($strCandidateGeneratedPath)) {
            continue
        }
        Write-Output (
            "The document classification adds unauthenticated generated status: $strCandidateGeneratedPath. " +
            'The exact path must already be generated or authorized in the trusted baseline; ' +
            'a Tier2 exemption does not authorize generated status.'
        )
    }
}

function Get-DiscoveredGovernedMarkdownDocumentPath {
    # .SYNOPSIS
    # Selects tracked Markdown that is not already classified.
    #
    # .DESCRIPTION
    # Partitions every tracked Markdown or Cursor Markdown path between the
    # reviewed governed catalog, a bounded Tier 2/generated exception list, and
    # a fail-closed Tier 1 default. Rejects ambiguous or unsafe path inventories.
    #
    # .PARAMETER CandidatePath
    # The complete tracked repository path inventory at the validation revision.
    #
    # .PARAMETER KnownGovernedPath
    # Paths already present in the reviewed governed-document catalog.
    #
    # .PARAMETER ExemptPath
    # Exact reviewed Tier 2 or generated-document paths that do not require
    # document-level metadata validation.
    #
    # .EXAMPLE
    # Get-DiscoveredGovernedMarkdownDocumentPath `
    #     -CandidatePath @('README.md', 'docs/RELEASE-RUNBOOK.md') `
    #     -KnownGovernedPath @() -ExemptPath @('README.md')
    #
    # # Returns docs/RELEASE-RUNBOOK.md for Tier 1 metadata validation.
    #
    # .INPUTS
    # None. You can't pipe objects to this function.
    #
    # .OUTPUTS
    # [string] One newly discovered governed Markdown path.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the
    # public API surface. Parameters, return shape, and positional
    # contract may change without notice.
    #
    # This function does not support positional parameters.
    # Version: 1.1.20261002.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]] $CandidatePath,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]] $KnownGovernedPath,

        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [string[]] $ExemptPath
    )

    $scriptBlockAssertSafeMarkdownPath = {
        param(
            [string] $Path,
            [string] $InventoryName
        )

        if ([string]::IsNullOrWhiteSpace($Path) -or
            [System.IO.Path]::IsPathRooted($Path) -or
            $Path.Contains('\', [System.StringComparison]::Ordinal) -or
            $Path -match '(?:^|/)\.\.(?:/|$)' -or
            $Path -match '[\x00-\x1f\x7f]' -or
            $Path -inotmatch '\.(?:md|mdc)$') {
            throw "$InventoryName contains an unsafe Markdown path: $Path"
        }
    }

    $setCandidates = [System.Collections.Generic.HashSet[string]]::new(
        [System.StringComparer]::Ordinal
    )
    foreach ($strCandidatePath in $CandidatePath) {
        if ($strCandidatePath -inotmatch '\.(?:md|mdc)$') {
            continue
        }
        & $scriptBlockAssertSafeMarkdownPath `
            -Path $strCandidatePath `
            -InventoryName 'The tracked document inventory'
        if (-not $setCandidates.Add($strCandidatePath)) {
            throw "The tracked document inventory contains a duplicate path: $strCandidatePath"
        }
    }

    $setKnownGoverned = [System.Collections.Generic.HashSet[string]]::new(
        [System.StringComparer]::Ordinal
    )
    foreach ($strKnownGovernedPath in $KnownGovernedPath) {
        & $scriptBlockAssertSafeMarkdownPath `
            -Path $strKnownGovernedPath `
            -InventoryName 'The governed document catalog'
        if (-not $setKnownGoverned.Add($strKnownGovernedPath)) {
            throw "The governed document catalog contains a duplicate path: $strKnownGovernedPath"
        }
    }

    $setExempt = [System.Collections.Generic.HashSet[string]]::new(
        [System.StringComparer]::Ordinal
    )
    foreach ($strExemptPath in $ExemptPath) {
        & $scriptBlockAssertSafeMarkdownPath `
            -Path $strExemptPath `
            -InventoryName 'The Tier 2/generated exception catalog'
        if (-not $setExempt.Add($strExemptPath)) {
            throw "The Tier 2/generated exception catalog contains a duplicate path: $strExemptPath"
        }
        if ($setKnownGoverned.Contains($strExemptPath)) {
            throw "A Markdown path is both governed and exempt: $strExemptPath"
        }
        if (-not $setCandidates.Contains($strExemptPath)) {
            throw "A Tier 2/generated exception is not tracked: $strExemptPath"
        }
    }

    return @(
        $setCandidates |
            Where-Object {
                -not $setKnownGoverned.Contains($_) -and
                -not $setExempt.Contains($_)
            } |
            Sort-Object -CaseSensitive
    )
}

function Test-DocumentMetadataHeaderIntent {
    # .SYNOPSIS
    # Detects intentional optional metadata without accepting its structure.
    #
    # .DESCRIPTION
    # Uses parsed document-level header blocks, excluding leading front matter,
    # quoted or fenced examples and later ordinary sections. Peer H2 Metadata
    # sections select validation even when misplaced. Incomplete fields
    # still select the strict metadata validator. Generated paths are excluded
    # by the caller, not inferred from their copied source contents.
    #
    # .PARAMETER Content
    # The bounded document text supplied by the existing safe input reader.
    #
    # .PARAMETER ReuseSlot
    # Optional private slot passed only to structural parsing.
    #
    # .EXAMPLE
    # Test-DocumentMetadataHeaderIntent -Content $strDocument
    #
    # # Reports recognizable header intent, not valid metadata.
    #
    # .INPUTS
    # None. This function does not accept pipeline input.
    #
    # .OUTPUTS
    # [bool] True when the document header contains metadata markers.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.1.20261006.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Content,
        [Parameter()][AllowNull()][object] $ReuseSlot
    )

    $arrLines = [regex]::Split($Content, '\r\n|\r|\n')
    $arrParserLines = [string[]]$arrLines.Clone()
    $intBodyStart = 0
    if ($arrLines[0] -ceq '---') {
        $intFrontMatterEnd = -1
        for ($intLine = 1; $intLine -lt $arrLines.Count; $intLine++) {
            if ($arrLines[$intLine] -ceq '---') {
                $intFrontMatterEnd = $intLine
                break
            }
        }
        # A marked header behind an unclosed delimiter must not disappear as
        # successful optional coverage. The strict parser reports that error.
        if ($intFrontMatterEnd -lt 0) {
            return $Content -imatch '(?m)^(?:#+\s+Metadata|[-+*]\s+\*\*(?:Status|Owner|Last Updated|Scope)|\*\*Version:)'
        }
        for ($intLine = 0; $intLine -le $intFrontMatterEnd; $intLine++) {
            $arrParserLines[$intLine] = ''
        }
        $intBodyStart = $intFrontMatterEnd + 1
    }
    $objParseContext = Get-MarkdownParseContext `
        -Content ($arrParserLines -join "`n") -LineCount $arrLines.Count -ReuseSlot $ReuseSlot
    $arrBlocks = @($objParseContext.TopLevelBlocks)
    # A later peer Metadata section is misplaced intent, not an ordinary
    # subsection example. Leave deeper headings to the existing header window.
    foreach ($objBlock in $arrBlocks) {
        if ($objBlock.Type -ceq 'heading_open' -and $objBlock.Tag -ceq 'h2' -and
            $objBlock.Text -imatch '^Metadata\s*:?$') { return $true }
    }
    $intHeaderStart = $intBodyStart
    foreach ($objBlock in $arrBlocks) {
        if ($objBlock.Type -ceq 'heading_open' -and $objBlock.Tag -ceq 'h1' -and
            ($objBlock.Start - $intBodyStart) -lt 30) {
            $intHeaderStart = $objBlock.End
            break
        }
    }
    # A recognizable header before an early title is misplaced, not absent.
    # Stop this prefix at its first heading so later examples stay excluded.
    $intPrefixEnd = $intHeaderStart
    foreach ($objBlock in $arrBlocks) {
        if ($objBlock.Start -ge $intBodyStart -and $objBlock.Start -lt $intHeaderStart -and
            $objBlock.Type -ceq 'heading_open') {
            if ($objBlock.Tag -cne 'h1' -and $objBlock.Text -imatch '^Metadata\s*:?$') { return $true }
            $intPrefixEnd = $objBlock.Start
            break
        }
    }
    $intHeaderEnd = $arrLines.Count
    foreach ($objBlock in $arrBlocks) {
        if ($objBlock.Start -lt $intHeaderStart -or $objBlock.Type -cne 'heading_open') {
            continue
        }
        if ($objBlock.Tag -cne 'h1' -and $objBlock.Text -imatch '^Metadata\s*:?$') { return $true }
        $intHeaderEnd = $objBlock.Start
        break
    }
    foreach ($objBlock in $arrBlocks) {
        $boolInHeader = ($objBlock.Start -ge $intHeaderStart -and $objBlock.Start -lt $intHeaderEnd) -or
            ($objBlock.Start -ge $intBodyStart -and $objBlock.Start -lt $intPrefixEnd)
        if ($boolInHeader -and
            $objBlock.Type -ceq 'paragraph_open' -and $objBlock.Text -imatch '^Version\s*:') {
            return $true
        }
    }
    foreach ($objItem in $objParseContext.TopLevelListItems) {
        $boolInHeader = ($objItem.Start -ge $intHeaderStart -and $objItem.Start -lt $intHeaderEnd) -or
            ($objItem.Start -ge $intBodyStart -and $objItem.Start -lt $intPrefixEnd)
        if (-not $boolInHeader) { continue }
        # Status/date labels are distinctive. Generic Owner/Scope prose alone
        # is not an opt-in; explicitly emphasized reserved fields are markers.
        if ($objItem.Text -imatch '^(?:Status|Last\s+Updated)\s*(?::|$)' -or
            $arrLines[$objItem.Start] -imatch
                '^\s*[-+*]\s+\*\*(?:Status|Owner|Last\s+Updated|Scope)\s*(?::|\*\*)') {
            return $true
        }
    }
    return $false
}

function Get-DocumentMetadataContext {
    # .SYNOPSIS
    # Gets validated document-level metadata context.
    #
    # .DESCRIPTION
    # Parses direct or headed document-level metadata after an early H1,
    # or direct metadata at body start after an optional leading directive.
    # Leading YAML front matter is excluded from the 30-line H1 window.
    # Parses any present Version, independently of whether it is required.
    # Returns validated list and Status coordinates with the same parser context
    # for private consumers that must identify the canonical metadata field.
    #
    # .PARAMETER Content
    # The trusted input text to parse or transform.
    #
    # .PARAMETER RequiresVersion
    # Indicates whether the document header must contain Version metadata.
    #
    # .PARAMETER ReuseSlot
    # Optional private slot; metadata policy is always evaluated anew.
    #
    # .EXAMPLE
    # Get-DocumentMetadataContext @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.Management.Automation.PSCustomObject] One validated context object described in the function description.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.8.20261006.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [string] $Content,

        [Parameter()]
        [bool] $RequiresVersion = $true,

        [Parameter()][AllowNull()][object] $ReuseSlot
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
        -LineCount $arrLines.Count -ReuseSlot $ReuseSlot
    $arrTopLevelBlocks = @($objParseContext.TopLevelBlocks)
    $arrTopLevelListItems = @($objParseContext.TopLevelListItems)

    $listH1Indices = [Collections.Generic.List[int]]::new()
    $listH2Indices = [Collections.Generic.List[int]]::new()
    for ($intIndex = 0; $intIndex -lt $arrTopLevelBlocks.Count; $intIndex++) {
        $objBlock = $arrTopLevelBlocks[$intIndex]
        if ($objBlock.Type -ceq 'heading_open' -and $objBlock.Tag -ceq 'h1') {
            $listH1Indices.Add($intIndex)
        } elseif ($objBlock.Type -ceq 'heading_open' -and $objBlock.Tag -ceq 'h2') {
            $listH2Indices.Add($intIndex)
        }
    }

    if ($listH1Indices.Count -gt 1) {
        return [pscustomobject]@{
            Failure = 'must contain at most one document-level H1.'
            VersionDate = $null
            UpdatedDate = $null
            Revision = $null
        }
    }

    $intH1Index = -1
    if ($listH1Indices.Count -eq 1 -and
        ($arrTopLevelBlocks[$listH1Indices[0]].Start - $intBodyStart) -lt 30) {
        $intH1Index = $listH1Indices[0]
    }
    $intMetadataIndex = 0
    if ($intH1Index -ge 0) {
        $intMetadataIndex = $intH1Index + 1
    } elseif ($arrTopLevelBlocks.Count -gt 0 -and
        $arrTopLevelBlocks[0].Type -ceq 'html_block') {
        $objLeadingBlock = $arrTopLevelBlocks[0]
        $strLeadingBlock = ($arrLines[$objLeadingBlock.Start..($objLeadingBlock.End - 1)] -join "`n").Trim()
        if ($strLeadingBlock -cmatch '^<!-- markdownlint-disable(?: [A-Za-z0-9_-]+)* -->$') {
            $intMetadataIndex = 1
        }
    }

    $intHeaderRegionEnd = $arrLines.Count
    $intVersionRegionStart = $intBodyStart
    if ($intH1Index -ge 0) {
        $intVersionRegionStart = $arrTopLevelBlocks[$intH1Index].End
    }
    foreach ($objHeaderBlock in $arrTopLevelBlocks) {
        if ($objHeaderBlock.Start -lt $intVersionRegionStart -or
            $objHeaderBlock.Type -cne 'heading_open') {
            continue
        }
        if ($intH1Index -ge 0 -and $objHeaderBlock.Tag -ceq 'h2' -and
            $objHeaderBlock.Text -ceq 'Metadata') {
            continue
        }
        $intHeaderRegionEnd = $objHeaderBlock.Start
        break
    }

    $strVersionPattern = '^\*\*Version:\*\* (?<Major>\d+)\.(?<Minor>\d+)\.' +
        '(?<Date>\d{8})\.(?<Revision>\d+)$'
    $listVersionRecords = [Collections.Generic.List[pscustomobject]]::new()
    for ($intIndex = 0; $intIndex -lt $arrTopLevelBlocks.Count; $intIndex++) {
        $objBlock = $arrTopLevelBlocks[$intIndex]
        if ($objBlock.Start -ge $intVersionRegionStart -and
            $objBlock.Start -lt $intHeaderRegionEnd -and
            $objBlock.Type -ceq 'paragraph_open' -and
            $objBlock.Text -is [string] -and
            [regex]::IsMatch($objBlock.Text, '^Version\s*:',
                ([Text.RegularExpressions.RegexOptions]::IgnoreCase -bor
                    [Text.RegularExpressions.RegexOptions]::CultureInvariant))) {
            $listVersionRecords.Add([pscustomobject]@{ BlockIndex = $intIndex; Block = $objBlock })
        }
    }
    $objVersionMatch = $null
    $boolHasVersion = $listVersionRecords.Count -gt 0
    if ($RequiresVersion -or $boolHasVersion) {
        if ($intH1Index -ge 0 -and $listVersionRecords.Count -eq 1 -and
            $listVersionRecords[0].BlockIndex -eq $intMetadataIndex -and
            $listVersionRecords[0].Block.End -eq ($listVersionRecords[0].Block.Start + 1)) {
            $objVersionMatch = [regex]::Match(
                $arrLines[$listVersionRecords[0].Block.Start], $strVersionPattern)
        }
        if ($null -eq $objVersionMatch -or -not $objVersionMatch.Success) {
            return [pscustomobject]@{
                Failure = 'must contain one exact document-level Version paragraph immediately after an H1 within the first 30 body lines.'
                VersionDate = $null
                UpdatedDate = $null
                Revision = $null
            }
        }
        $intMetadataIndex++
    }

    $strMetadataPlacementFailure = 'must place one document-level metadata list immediately after ' +
        'the early H1 and optional Version, or at body start after an optional leading markdownlint-disable directive; ' +
        'an optional Metadata section must be the first H2 immediately after the early H1 and optional Version.'
    $arrMetadataHeadings = @($listH2Indices | Where-Object { $arrTopLevelBlocks[$_].Text -ceq 'Metadata' })
    if ($arrMetadataHeadings.Count -gt 0) {
        if ($intH1Index -lt 0 -or $arrMetadataHeadings.Count -ne 1 -or
            $listH2Indices[0] -ne $intMetadataIndex -or $arrMetadataHeadings[0] -ne $intMetadataIndex) {
            return [pscustomobject]@{
                Failure = $strMetadataPlacementFailure
                VersionDate = $null
                UpdatedDate = $null
                Revision = $null
            }
        }
        $intMetadataIndex++
    }
    if ($intMetadataIndex -ge $arrTopLevelBlocks.Count -or
        $arrTopLevelBlocks[$intMetadataIndex].Type -cne 'bullet_list_open') {
        return [pscustomobject]@{
            Failure = $strMetadataPlacementFailure
            VersionDate = $null
            UpdatedDate = $null
            Revision = $null
        }
    }
    $objMetadataList = $arrTopLevelBlocks[$intMetadataIndex]
    $arrRequiredFields = @(
        [pscustomobject]@{
            Name = 'Status'
            Pattern = '^- \*\*Status:\*\* ' +
                '(?<Value>Draft|Proposed|Active|Accepted|Superseded|Deprecated)$'
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
        $strFieldLabelPattern = '^' +
            (($objField.Name.Split(' ') | ForEach-Object { [regex]::Escape($_) }) -join '\s+') + '\s*:'
        $arrFieldRecords = @(
            $arrTopLevelListItems |
                Where-Object {
                    $_.Start -ge $objMetadataList.Start -and
                    $_.Start -lt $intHeaderRegionEnd -and
                    $_.Text -is [string] -and
                    [regex]::IsMatch($_.Text, $strFieldLabelPattern,
                        ([Text.RegularExpressions.RegexOptions]::IgnoreCase -bor
                            [Text.RegularExpressions.RegexOptions]::CultureInvariant))
                }
        )
        $strFieldFailure = "must contain one exact top-level $($objField.Name) " +
            'list item in the document-level metadata list.'
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
        if ($arrFieldRecords.Count -ne 1 -or $boolFieldHasContinuation -or
            $arrFieldRecords[0].Start -lt $objMetadataList.Start -or
            $arrFieldRecords[0].End -gt $objMetadataList.End) {
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
        Status = $hashtableFieldMatches['Status'].Groups['Value'].Value
        Major = if ($boolHasVersion) {
            $objVersionMatch.Groups['Major'].Value
        } else {
            $null
        }
        Minor = if ($boolHasVersion) {
            $objVersionMatch.Groups['Minor'].Value
        } else {
            $null
        }
        VersionDate = if ($boolHasVersion) {
            $objVersionMatch.Groups['Date'].Value
        } else {
            $null
        }
        UpdatedDate = $objUpdatedMatch.Groups['Date'].Value
        Revision = if ($boolHasVersion) {
            $objVersionMatch.Groups['Revision'].Value
        } else {
            $null
        }
        VersionLineIndex = if ($boolHasVersion) {
            $listVersionRecords[0].Block.Start
        } else {
            -1
        }
        UpdatedLineIndex = $hashtableFieldLineIndices['Last Updated']
        MetadataListStart = $objMetadataList.Start
        MetadataListEnd = $objMetadataList.End
        StatusLineIndex = $hashtableFieldLineIndices['Status']
        MarkdownParseContext = $objParseContext
    }
}

function Get-PublishedEndpointMetadataFailure {
    # .SYNOPSIS
    # Finds metadata failures in one document transition.
    #
    # .DESCRIPTION
    # Validates structure, dates, version order, rendered changes, and the
    # optional expected UTC date for current and parent content.
    #
    # .PARAMETER Name
    # The document name for diagnostics.
    #
    # .PARAMETER CurrentContent
    # The current Markdown content.
    #
    # .PARAMETER ParentContent
    # The parent content, or null for creation.
    #
    # .PARAMETER ExpectedUtcDate
    # The optional authenticated yyyy-MM-dd date.
    #
    # .PARAMETER IsNewDocumentTransition
    # True when null parent content means document creation.
    #
    # .PARAMETER RequireExpectedUtcDateForRenderedChange
    # True to require the expected date after rendered changes.
    #
    # .PARAMETER CurrentParseReuse
    # Borrowed private structural slot for current content.
    #
    # .PARAMETER ParentParseReuse
    # Borrowed private structural slot for prior content.
    #
    # .EXAMPLE
    # $arrFailure = @(Get-PublishedEndpointMetadataFailure `
    #     -Name 'AGENTS.md' -CurrentContent $strCurrent `
    #     -ParentContent $strParent -ExpectedUtcDate '2026-08-27' `
    #     -IsNewDocumentTransition $false)
    #
    # .INPUTS
    # None.
    #
    # .OUTPUTS
    # [string] Zero or more failure diagnostics.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.1.20261006.0
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
        [bool] $RequireExpectedUtcDateForRenderedChange = $true,

        [Parameter()][AllowNull()][object] $CurrentParseReuse,
        [Parameter()][AllowNull()][object] $ParentParseReuse
    )

    $objCurrentMetadata = Get-DocumentMetadataContext -Content $CurrentContent -ReuseSlot $CurrentParseReuse
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

    $intCurrentMajor = [int64] 0
    $intCurrentMinor = [int64] 0
    $intCurrentRevision = [int64] 0
    if (-not [int64]::TryParse($objCurrentMetadata.Major, [ref] $intCurrentMajor) -or
        -not [int64]::TryParse($objCurrentMetadata.Minor, [ref] $intCurrentMinor) -or
        -not [int64]::TryParse($objCurrentMetadata.Revision, [ref] $intCurrentRevision)) {
        Write-Output "$Name Version major, minor, and revision must fit in signed 64-bit integers."
        return
    }

    if ([string]::IsNullOrEmpty($ParentContent)) {
        if (-not $IsNewDocumentTransition) {
            return
        }
        if ($RequireExpectedUtcDateForRenderedChange) {
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
        }
        if ($intCurrentRevision -ne 0) {
            Write-Output (
                "$Name Version revision must be exactly 0 when no published baseline exists."
            )
        }
        return
    }

    $objParentMetadata = Get-DocumentMetadataContext -Content $ParentContent -ReuseSlot $ParentParseReuse
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

    $intParentMajor = [int64] 0
    $intParentMinor = [int64] 0
    $intParentRevision = [int64] 0
    if (-not [int64]::TryParse($objParentMetadata.Major, [ref] $intParentMajor) -or
        -not [int64]::TryParse($objParentMetadata.Minor, [ref] $intParentMinor) -or
        -not [int64]::TryParse($objParentMetadata.Revision, [ref] $intParentRevision)) {
        Write-Output (
            "The published baseline $Name Version major, minor, and revision must fit " +
            'in signed 64-bit integers.'
        )
        return
    }

    $intVersionDateComparison = [string]::CompareOrdinal(
        $strCurrentVersionDate,
        $strParentVersionDate
    )
    $intMajorMinorComparison = if ($intCurrentMajor -ne $intParentMajor) {
        $intCurrentMajor.CompareTo($intParentMajor)
    } elseif ($intCurrentMinor -ne $intParentMinor) {
        $intCurrentMinor.CompareTo($intParentMinor)
    } else {
        0
    }
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
        return
    }
    if ($intMajorMinorComparison -lt 0) {
        Write-Output (
            "$Name Version major and minor tuple must not move backward from " +
            "$intParentMajor.$intParentMinor to $intCurrentMajor.$intCurrentMinor."
        )
        return
    }
    $boolSameVersionTuple = $intMajorMinorComparison -eq 0 -and
        $intVersionDateComparison -eq 0
    if ($boolSameVersionTuple -and $intCurrentRevision -lt $intParentRevision) {
        Write-Output (
            "$Name Version revision must not decrease from $intParentRevision to " +
            "$intCurrentRevision."
        )
        return
    }

    $boolRevisionChanged = $intCurrentRevision -ne $intParentRevision
    if ($boolSameVersionTuple -and
        ($boolRenderedContentChanged -or $boolRevisionChanged)) {
        if ($intParentRevision -eq [int64]::MaxValue) {
            Write-Output (
                "The published baseline $Name Version revision cannot be incremented safely."
            )
            return
        }
        $intExpectedRevision = $intParentRevision + 1
        if ($intCurrentRevision -ne $intExpectedRevision) {
            Write-Output (
                "$Name Version revision must be exactly $intExpectedRevision after a " +
                'published change with an unchanged published-baseline major, minor, ' +
                'and date tuple.'
            )
        }
    } elseif (-not $boolSameVersionTuple -and $intCurrentRevision -ne 0) {
        Write-Output (
            "$Name Version revision must be exactly 0 when a published-baseline " +
            'major, minor, or date segment changes.'
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
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
        } else {
            $intLineStart = $intLineEnd + 1
        }
    }
}

function Get-GitHubPluginEnablementContext {
    # .SYNOPSIS
    # Gets the validated GitHub plugin enablement context.
    #
    # .DESCRIPTION
    # Parses the Codex configuration and locates the exact GitHub plugin enablement assignment.
    #
    # .PARAMETER Content
    # The trusted input text to parse or transform.
    #
    # .EXAMPLE
    # Get-GitHubPluginEnablementContext @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.Management.Automation.PSCustomObject] One validated context object described in the function description.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    # Creates a configuration mutation that disables the GitHub plugin.
    #
    # .DESCRIPTION
    # Uses the validated enablement context to replace the active GitHub plugin value with false while preserving all unrelated text.
    #
    # .PARAMETER Content
    # The trusted input text to parse or transform.
    #
    # .EXAMPLE
    # ConvertTo-DisabledGitHubPluginMutation @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.String] The configuration text with the GitHub plugin disabled.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    #
    # .DESCRIPTION
    # Validates the combined AGENTS, Claude, and Codex configuration contract.
    #
    # .PARAMETER AgentsContent
    # The root AGENTS.md content to validate.
    #
    # .PARAMETER ClaudeContent
    # The root CLAUDE.md content to validate.
    #
    # .PARAMETER CodexConfigContent
    # The Codex configuration content to validate.
    #
    # .PARAMETER ParentAgentsContent
    # The optional parent AGENTS.md content used by the fixture.
    #
    # .PARAMETER ParentClaudeContent
    # The optional parent CLAUDE.md content used by the fixture.
    #
    # .PARAMETER AgentsExpectedUtcDate
    # The expected AGENTS.md metadata date in UTC.
    #
    # .PARAMETER ClaudeExpectedUtcDate
    # The expected CLAUDE.md metadata date in UTC.
    #
    # .EXAMPLE
    # Get-AgentInstructionFailure @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [System.String] Zero or more validated values or diagnostics described in the function description.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    } elseif (-not $objTomlParseContext.CapacityFitsInt64) {
        Write-Output 'project_doc_max_bytes must fit in a signed 64-bit integer.'
    } else {
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
    } elseif (-not $objTomlParseContext.PluginEnabledPresent -or
        $objTomlParseContext.PluginEnabledType -cne 'bool' -or
        -not $objTomlParseContext.PluginEnabledValue) {
        Write-Output (
            'The github@openai-curated plugin table must declare enabled = true exactly once.'
        )
    }

    if (-not $objTomlParseContext.FeatureTablePresent -or
        $objTomlParseContext.FeatureTableType -cne 'dict') {
        Write-Output 'The project configuration must declare [features] exactly once.'
    } elseif (-not $objTomlParseContext.MultiAgentPresent -or
        $objTomlParseContext.MultiAgentType -cne 'bool' -or
        -not $objTomlParseContext.MultiAgentValue) {
        Write-Output 'The [features] table must declare multi_agent = true exactly once.'
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
    Get-AgentBootstrapCommandFailure -Name 'AGENTS.md' -MarkdownContext $objAgentsMarkdownContext
    Get-AgentBootstrapCommandFailure -Name 'CLAUDE.md' -MarkdownContext $objClaudeMarkdownContext
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
                } else {
                    $arrSyntheticOwners
                }
            )
            $intLiteralCount = if ($arrOwners.Count -eq 1) {
                @(
                    $arrOwners[0].Code |
                        Where-Object { $_ -ceq $strLiteral.Trim([char]96) }
                ).Count
            } else {
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
        } else {
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
        $arrMetadataFailures = @(Get-PublishedEndpointMetadataFailure `
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
    #
    # .DESCRIPTION
    # Applies one mutated agent-instruction fixture and confirms that validation returns the exact expected failure.
    #
    # .PARAMETER Name
    # The fixture or document name to use in diagnostics.
    #
    # .PARAMETER AgentsContent
    # The root AGENTS.md content to validate.
    #
    # .PARAMETER ClaudeContent
    # The root CLAUDE.md content to validate.
    #
    # .PARAMETER CodexConfigContent
    # The Codex configuration content to validate.
    #
    # .PARAMETER Failure
    # The exact diagnostic that the fixture must produce.
    #
    # .PARAMETER ParentAgentsContent
    # The optional parent AGENTS.md content used by the fixture.
    #
    # .PARAMETER ParentClaudeContent
    # The optional parent CLAUDE.md content used by the fixture.
    #
    # .PARAMETER AgentsExpectedUtcDate
    # The expected AGENTS.md metadata date in UTC.
    #
    # .PARAMETER ClaudeExpectedUtcDate
    # The expected CLAUDE.md metadata date in UTC.
    #
    # .EXAMPLE
    # Assert-Failure @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    } else {
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
    #
    # .DESCRIPTION
    # Applies one valid agent-instruction fixture and confirms that validation returns no diagnostics.
    #
    # .PARAMETER Name
    # The fixture or document name to use in diagnostics.
    #
    # .PARAMETER AgentsContent
    # The root AGENTS.md content to validate.
    #
    # .PARAMETER ClaudeContent
    # The root CLAUDE.md content to validate.
    #
    # .PARAMETER CodexConfigContent
    # The Codex configuration content to validate.
    #
    # .PARAMETER ParentAgentsContent
    # The optional parent AGENTS.md content used by the fixture.
    #
    # .PARAMETER ParentClaudeContent
    # The optional parent CLAUDE.md content used by the fixture.
    #
    # .PARAMETER AgentsExpectedUtcDate
    # The expected AGENTS.md metadata date in UTC.
    #
    # .PARAMETER ClaudeExpectedUtcDate
    # The expected CLAUDE.md metadata date in UTC.
    #
    # .EXAMPLE
    # Assert-FixtureAccepted @hashtableArguments
    #
    # # Runs with validated named arguments.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
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
    } else {
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
    },
    [pscustomobject]@{
        Path = 'STYLE_GUIDE_RATIONALE.md'
        MaximumBytes = $intStyleGuideRationaleMaximumInputBytes
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
if ($RequireStagedInputMatch -and ($MetadataClassificationOnly -or $FinalizeMetadataNow -or
        $ProposedPolicy -or -not [string]::IsNullOrEmpty($InputRevision) -or
        -not [string]::IsNullOrEmpty($PublishedBaselineRevision))) {
    throw 'Staged-input matching cannot be combined with revision validation or endpoint modes.'
}
$strValidatedInputRevision = $InputRevision
$strEffectivePublishedBaselineRevision = $PublishedBaselineRevision
$PublishedFinalRevision = $InputRevision
$boolPublishedEndpointsRequested = -not [string]::IsNullOrEmpty($PublishedBaselineRevision)
if ($ProposedPolicy -and ($SelfTest -or $MetadataClassificationOnly -or $FinalizeMetadataNow -or
        -not $boolPublishedEndpointsRequested -or [string]::IsNullOrEmpty($InputRevision) -or
        $InputRevision -ceq $PublishedBaselineRevision -or
        $InputRevision -ceq ('0' * 40) -or $PublishedBaselineRevision -ceq ('0' * 40))) {
    throw 'ProposedPolicy requires distinct nonzero exact B/H endpoints and cannot combine other modes.'
}
if ($MetadataClassificationOnly -and ($SelfTest -or -not $boolPublishedEndpointsRequested)) {
    throw 'MetadataClassificationOnly requires exact B/H endpoints and cannot run with SelfTest.'
}
if ($FinalizeMetadataNow -and ($SelfTest -or $MetadataClassificationOnly -or
        -not $boolPublishedEndpointsRequested)) {
    throw 'FinalizeMetadataNow requires exact B/H endpoints and cannot run with other modes.'
}
if ($boolPublishedEndpointsRequested -and [string]::IsNullOrEmpty($InputRevision)) {
    throw 'An exact published baseline requires an exact input commit.'
}
foreach ($strRevision in @($InputRevision, $PublishedBaselineRevision)) {
    if ([string]::IsNullOrEmpty($strRevision)) { continue }
    if ($strRevision -cnotmatch '^[0-9a-f]{40}$') {
        throw 'Instruction validation requires a full lowercase commit hash.'
    }
    $strResolvedRevision = [string] (& git -C $strRepositoryRootPath rev-parse --verify "$strRevision`^{commit}")
    if ($LASTEXITCODE -ne 0 -or $strResolvedRevision.Trim() -cne $strRevision) {
        throw "The instruction input commit is unavailable: $strRevision"
    }
}
$strCheckedOutRevision = [string] (& git -C $strRepositoryRootPath rev-parse --verify 'HEAD^{commit}')
if ($LASTEXITCODE -ne 0 -or $strCheckedOutRevision.Trim() -cnotmatch '^[0-9a-f]{40}$') {
    throw 'The checked-out instruction policy revision is unavailable.'
}
$strCheckedOutRevision = $strCheckedOutRevision.Trim()
if ($ProposedPolicy) {
    if ($strCheckedOutRevision -cne $InputRevision) {
        throw 'The proposed instruction checker must be checked out at the exact candidate head.'
    }
    Write-Output ("PROPOSED_POLICY_TRANSITION: B=$PublishedBaselineRevision H=$InputRevision. " +
        'Candidate checker code supplies diagnostics, not accepted-policy, owner or merge authority.')
} elseif ($boolPublishedEndpointsRequested -and $strCheckedOutRevision -cne $PublishedBaselineRevision) {
    throw 'The trusted instruction checker must be checked out at the accepted baseline.'
}

$setStagedInputPaths = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
if ($RequireStagedInputMatch) {
    foreach ($strStagedPath in @(Read-GitStagedInputPath -RepositoryRootPath $strRepositoryRootPath `
            -MaximumBytes $intGitPathListMaximumBytes)) {
        [void]$setStagedInputPaths.Add($strStagedPath)
    }
    foreach ($strExecutableInputPath in @('.github/workflows/Test-AgentInstructions.ps1',
            '.github/workflows/Test-AgentInstructions.SelfTest.ps1')) {
        if ($setStagedInputPaths.Contains($strExecutableInputPath)) {
            $null = Read-RepositoryInputData -Path (Join-Path $strRepositoryRootPath $strExecutableInputPath) `
                -RepositoryRootPath $strRepositoryRootPath -RepositoryRelativePath $strExecutableInputPath `
                -DisplayName $strExecutableInputPath -MaximumBytes $intGitPathListMaximumBytes `
                -RequireIndexContentMatch
        }
    }
}

$arrTrackedRepositoryPaths = @(Read-GitTrackedPath `
        -RepositoryRootPath $strRepositoryRootPath `
        -Revision $strValidatedInputRevision `
        -MaximumBytes $intGitPathListMaximumBytes)

# Apply the name-wide rule before classification-only can return. The complete
# target inventory is independent of checkout state and metadata exemptions.
$arrCompiledPythonFailures = @(Get-TrackedCompiledPythonFailure -TrackedPath $arrTrackedRepositoryPaths)
if ($arrCompiledPythonFailures.Count -gt 0) {
    throw ($arrCompiledPythonFailures -join [Environment]::NewLine)
}

# Classification is candidate data. Use only the existing bounded safe readers.
$strDocumentClassificationRelativePath = '.github/document-metadata-classification.json'
$strDocumentClassificationPath = Join-Path -Path $strRepositoryRootPath `
    -ChildPath $strDocumentClassificationRelativePath
$strDocumentClassificationContent = if ([string]::IsNullOrEmpty($strValidatedInputRevision)) {
    ConvertFrom-StrictUtf8Data `
        -Bytes (Read-RepositoryInputData `
            -Path $strDocumentClassificationPath `
            -RepositoryRootPath $strRepositoryRootPath `
            -RepositoryRelativePath $strDocumentClassificationRelativePath `
            -DisplayName $strDocumentClassificationRelativePath `
            -MaximumBytes $intDocumentClassificationMaximumInputBytes `
            -RequireIndexContentMatch:($RequireStagedInputMatch -and $setStagedInputPaths.Contains($strDocumentClassificationRelativePath))) `
        -DisplayName $strDocumentClassificationRelativePath
} else {
    Read-GitRevisionText `
        -RepositoryRootPath $strRepositoryRootPath `
        -Revision $strValidatedInputRevision `
        -RepositoryRelativePath $strDocumentClassificationRelativePath `
        -MaximumBytes $intDocumentClassificationMaximumInputBytes `
        -RequireRegularFile
}
$objDocumentClassificationContext = Get-DocumentMetadataClassificationContext `
    -Content $strDocumentClassificationContent `
    -TrackedPath $arrTrackedRepositoryPaths
if ($null -ne $objDocumentClassificationContext.Failure) {
    throw $objDocumentClassificationContext.Failure
}
$strDocumentClassificationBaselineRevision = if ($boolPublishedEndpointsRequested) {
    $PublishedBaselineRevision
} elseif (-not [string]::IsNullOrEmpty($strValidatedInputRevision)) {
    $strValidatedInputRevision
} else { $strCheckedOutRevision }
$boolHasTrustedBaselineClassificationManifest = $false
$arrTrustedBaselineClassificationExemptPaths = @()
$arrTrustedBaselineClassificationGeneratedPaths = @()
$arrTrustedBaselineClassificationAuthorizedExemptionPaths = @()
if (-not [string]::IsNullOrEmpty($strDocumentClassificationBaselineRevision)) {
    $arrBaselineClassificationTrackedPaths = @(Read-GitTrackedPath `
        -RepositoryRootPath $strRepositoryRootPath `
        -Revision $strDocumentClassificationBaselineRevision `
        -MaximumBytes $intGitPathListMaximumBytes)
    if ($arrBaselineClassificationTrackedPaths -ccontains $strDocumentClassificationRelativePath) {
        $strBaselineDocumentClassificationContent = Read-GitRevisionText `
            -RepositoryRootPath $strRepositoryRootPath `
            -Revision $strDocumentClassificationBaselineRevision `
            -RepositoryRelativePath $strDocumentClassificationRelativePath `
            -MaximumBytes $intDocumentClassificationMaximumInputBytes `
            -RequireRegularFile
        $objBaselineDocumentClassificationContext = Get-DocumentMetadataClassificationContext `
            -Content $strBaselineDocumentClassificationContent `
            -TrackedPath $arrBaselineClassificationTrackedPaths
        if ($null -ne $objBaselineDocumentClassificationContext.Failure) {
            throw ('The trusted baseline document classification is invalid: ' +
                $objBaselineDocumentClassificationContext.Failure)
        }
        $boolHasTrustedBaselineClassificationManifest = $true
        $arrTrustedBaselineClassificationExemptPaths = @(
            $objBaselineDocumentClassificationContext.ExemptPaths)
        $arrTrustedBaselineClassificationGeneratedPaths = @(
            $objBaselineDocumentClassificationContext.GeneratedPaths)
        $arrTrustedBaselineClassificationAuthorizedExemptionPaths = @(
            $objBaselineDocumentClassificationContext.AuthorizedExemptionPaths)
    }
}
$strTrustedBaselineValidatorSha256 = ''
if (-not $boolHasTrustedBaselineClassificationManifest -and
    -not [string]::IsNullOrEmpty($strDocumentClassificationBaselineRevision)) {
    $strTrustedPriorValidator = Read-GitRevisionText `
        -RepositoryRootPath $strRepositoryRootPath `
        -Revision $strDocumentClassificationBaselineRevision `
        -RepositoryRelativePath '.github/workflows/Test-AgentInstructions.ps1' `
        -MaximumBytes 573440 -RequireRegularFile
    $objPriorValidatorSha256 = [Security.Cryptography.SHA256]::Create()
    try {
        $strTrustedBaselineValidatorSha256 = ([BitConverter]::ToString(
                $objPriorValidatorSha256.ComputeHash([Text.Encoding]::UTF8.GetBytes(
                        $strTrustedPriorValidator)))).Replace('-', '').ToLowerInvariant()
    } finally { $objPriorValidatorSha256.Dispose() }
}

$arrDocumentClassificationExpansionFailures = @(if ($boolHasTrustedBaselineClassificationManifest) {
    @(Get-DocumentMetadataClassificationExpansionFailure `
        -HasTrustedBaselineManifest $true `
        -TrustedBaselineExemptPath $arrTrustedBaselineClassificationExemptPaths `
        -TrustedBaselineAuthorizedExemptionPath $arrTrustedBaselineClassificationAuthorizedExemptionPaths `
        -CandidateExemptPath $objDocumentClassificationContext.ExemptPaths `
        -TrustedBaselineGeneratedPath $arrTrustedBaselineClassificationGeneratedPaths `
        -CandidateGeneratedPath $objDocumentClassificationContext.GeneratedPaths)
} else {
    @(Get-InitialDocumentMetadataClassificationFailure `
        -BaselineRevision $strDocumentClassificationBaselineRevision `
        -TrustedBaselineValidatorSha256 $strTrustedBaselineValidatorSha256 `
        -CandidateContext $objDocumentClassificationContext)
})
if ($arrDocumentClassificationExpansionFailures.Count -gt 0) {
    throw ('Document classification expansion failed:' + [Environment]::NewLine + '- ' +
        ($arrDocumentClassificationExpansionFailures -join ([Environment]::NewLine + '- ')))
}
# Generated exemption affects metadata content only, not candidate Git type.
foreach ($strGeneratedMetadataPath in $objDocumentClassificationContext.GeneratedPaths) {
    $null = Get-GitRegularFileBlobId -RepositoryRootPath $strRepositoryRootPath `
        -Revision $strValidatedInputRevision -RepositoryRelativePath $strGeneratedMetadataPath
}
if ($MetadataClassificationOnly) {
    Write-Output ("Metadata classification data validated: B=$PublishedBaselineRevision H=$InputRevision. " +
        'This is not first-install, owner or merge authority.')
    return
}

$hashtableAgentSetupContent = Read-AgentSetupInputContent -RepositoryRootPath $strRepositoryRootPath `
    -Revision $strValidatedInputRevision -StagedInputPaths $setStagedInputPaths

$arrBootstrapFailures = @(Get-MarkdownParserBootstrapFailure `
        -RepositoryRootPath $strRepositoryRootPath)
if ($arrBootstrapFailures.Count -gt 0) {
    throw ($arrBootstrapFailures -join [Environment]::NewLine)
}

$arrPublishedBaselinePaths = @()
$arrPublishedChangedPaths = @()
if ($boolPublishedEndpointsRequested) {
    if (-not [string]::IsNullOrEmpty(
            $strEffectivePublishedBaselineRevision
        )) {
        $arrPublishedBaselinePaths = @(Read-GitTrackedPath `
            -RepositoryRootPath $strRepositoryRootPath `
            -Revision $strEffectivePublishedBaselineRevision `
            -MaximumBytes $intGitPathListMaximumBytes)
    }
    $arrPublishedChangedPaths = @(Read-GitPublishedEndpointChangedPath `
        -RepositoryRootPath $strRepositoryRootPath `
        -BaselineRevision $PublishedBaselineRevision `
        -FinalRevision $PublishedFinalRevision `
        -MaximumBytes $intGitPathListMaximumBytes) | Sort-Object -Unique
}
$arrPublishedDecisionPaths = @(
    @($arrPublishedBaselinePaths + $arrTrackedRepositoryPaths +
        $arrPublishedChangedPaths) |
        Where-Object { $_ -cmatch $script:strDecisionRecordDirectoryPathPattern }
)
$arrPublishedGovernedInstructionPaths = @(
    @($arrPublishedBaselinePaths + $arrTrackedRepositoryPaths +
        $arrPublishedChangedPaths) |
        Where-Object {
            Test-GovernedInstructionInventoryPath `
                -RepositoryRelativePath ([string]$_)
        }
)
$arrDecisionRecordInventoryPaths = @(
    @($arrTrackedRepositoryPaths + $arrPublishedDecisionPaths) |
        Where-Object { $_ -cmatch $script:strDecisionRecordDirectoryPathPattern } |
        Sort-Object -Unique
)
$arrGovernedMetadataDocuments += @(
    $arrDecisionRecordInventoryPaths |
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
    @($arrTrackedRepositoryPaths + $arrPublishedGovernedInstructionPaths) |
        Where-Object {
            Test-GovernedInstructionInventoryPath `
                -RepositoryRelativePath ([string] $_)
        } |
        Sort-Object -Unique
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

$arrGovernedMetadataDocuments += [pscustomobject]@{
    Path = 'STYLE_GUIDE.md'
    MaximumBytes = 262144
    RequiresMetadata = $true
    RequiresVersion = $true
}
$arrDiscoveredGovernedMarkdownPaths = @(
    Get-DiscoveredGovernedMarkdownDocumentPath `
        -CandidatePath $arrTrackedRepositoryPaths `
        -KnownGovernedPath @($arrGovernedMetadataDocuments.Path) `
        -ExemptPath $objDocumentClassificationContext.ExemptPaths)
foreach ($strDiscoveredGovernedMarkdownPath in $arrDiscoveredGovernedMarkdownPaths) {
    $arrGovernedMetadataDocuments += [pscustomobject]@{
        Path = $strDiscoveredGovernedMarkdownPath
        MaximumBytes = $intInstructionDocumentMaximumInputBytes
        RequiresMetadata = $true
        RequiresVersion = $false
    }
}
foreach ($strOptionalMetadataPath in $objDocumentClassificationContext.Tier2Paths) {
    $arrGovernedMetadataDocuments += [pscustomobject]@{
        Path = $strOptionalMetadataPath
        MaximumBytes = $intInstructionDocumentMaximumInputBytes
        RequiresMetadata = $false
        RequiresVersion = $false
    }
}

if ([string]::IsNullOrEmpty($strValidatedInputRevision)) {
    $arrRequiredPaths = @($strCodexConfigPath)
    $arrRequiredPaths += @(
        $arrGovernedMetadataDocuments |
            Where-Object {
                $arrPublishedChangedPaths -cnotcontains $_.Path -or
                $arrTrackedRepositoryPaths -ccontains $_.Path
            } |
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
            -MaximumBytes $intAgentsMaximumInputBytes `
            -RequireIndexContentMatch:($RequireStagedInputMatch -and $setStagedInputPaths.Contains('AGENTS.md'))) `
        -DisplayName 'AGENTS.md'
} else {
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
            -MaximumBytes $intClaudeMaximumInputBytes `
            -RequireIndexContentMatch:($RequireStagedInputMatch -and $setStagedInputPaths.Contains('CLAUDE.md'))) `
        -DisplayName 'CLAUDE.md'
} else {
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
            -MaximumBytes $intCodexConfigMaximumInputBytes `
            -RequireIndexContentMatch:($RequireStagedInputMatch -and $setStagedInputPaths.Contains('.codex/config.toml'))) `
        -DisplayName '.codex/config.toml'
} else {
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
            -MaximumBytes $intDocsInstructionsMaximumInputBytes `
            -RequireIndexContentMatch:($RequireStagedInputMatch -and $setStagedInputPaths.Contains('.github/instructions/docs.instructions.md'))) `
        -DisplayName '.github/instructions/docs.instructions.md'
} else {
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
    $boolPublishedBaselineOnlyDocument =
        $arrPublishedBaselinePaths -ccontains $objDocumentSpec.Path -and
        $arrTrackedRepositoryPaths -cnotcontains $objDocumentSpec.Path
    $strDocumentContent = if ($boolPublishedBaselineOnlyDocument) {
        $null
    } elseif ([string]::IsNullOrEmpty($strValidatedInputRevision)) {
        ConvertFrom-StrictUtf8Data `
            -Bytes (Read-RepositoryInputData `
                -Path $strDocumentPath `
                -RepositoryRootPath $strRepositoryRootPath `
                -RepositoryRelativePath $objDocumentSpec.Path `
                -DisplayName $objDocumentSpec.Path `
                -MaximumBytes $objDocumentSpec.MaximumBytes `
            -RequireIndexContentMatch:($RequireStagedInputMatch -and $setStagedInputPaths.Contains($objDocumentSpec.Path))) `
            -DisplayName $objDocumentSpec.Path
    } else {
        Read-GitRevisionText `
            -RepositoryRootPath $strRepositoryRootPath `
            -Revision $strValidatedInputRevision `
            -RepositoryRelativePath $objDocumentSpec.Path `
            -MaximumBytes $objDocumentSpec.MaximumBytes `
            -RequireRegularFile
    }
    $hashtableGovernedInstructionContent[$objDocumentSpec.Path] = $strDocumentContent
}

$objDocumentParseBudget = [pscustomobject]@{ Retained = 0 }
$listDocumentParseSlots = [Collections.Generic.List[object]]::new()
$objDocumentParseFailure = $null
try {
    $listGovernedDocumentContexts = [Collections.Generic.List[pscustomobject]]::new()
    foreach ($objDocumentSpec in $arrGovernedMetadataDocuments) {
        $objCurrentParseReuse = Get-MarkdownParseReuseSlot -Budget $objDocumentParseBudget
        $listDocumentParseSlots.Add($objCurrentParseReuse)
        $objParentParseReuse = Get-MarkdownParseReuseSlot -Budget $objDocumentParseBudget
        $listDocumentParseSlots.Add($objParentParseReuse)
        $objParentContext = if ($boolPublishedEndpointsRequested) {
            $strPublishedBaselineContent = $null
            $strMetadataBaselineRevision =
                $strEffectivePublishedBaselineRevision
            if (-not [string]::IsNullOrEmpty($strMetadataBaselineRevision)) {
                & git -C $strRepositoryRootPath cat-file -e `
                    "$strMetadataBaselineRevision`:$($objDocumentSpec.Path)" 2>$null
                if ($LASTEXITCODE -eq 0) {
                    $strPublishedBaselineContent = Read-PublishedBaselineDocumentText `
                        -RepositoryRootPath $strRepositoryRootPath `
                        -Revision $strMetadataBaselineRevision `
                        -RepositoryRelativePath $objDocumentSpec.Path `
                        -CurrentMaximumBytes $objDocumentSpec.MaximumBytes
                }
            }
            [pscustomobject]@{
                ParentContent = $strPublishedBaselineContent
                ExpectedUtcDate = ''
                ParentRevision = $strMetadataBaselineRevision
                IsWorktreeTransition = $false
            }
        } elseif ([string]::IsNullOrEmpty($strValidatedInputRevision)) {
            Get-PublishedBaselineDocumentContext `
                -RepositoryRootPath $strRepositoryRootPath `
                -RepositoryRelativePath $objDocumentSpec.Path `
                -MaximumBytes $objDocumentSpec.MaximumBytes
        } else {
            [pscustomobject]@{
                ParentContent = $hashtableGovernedInstructionContent[$objDocumentSpec.Path]
                ExpectedUtcDate = ''
                ParentRevision = $strValidatedInputRevision
                IsWorktreeTransition = $false
            }
        }
        if ($FinalizeMetadataNow) {
            $objParentContext.ExpectedUtcDate = $script:strMaximumMetadataUtcDate
        }
        $boolInitialMetadataCoverage = $false
        $objMetadataParentContent = $objParentContext.ParentContent
        $boolValidateMetadata = $objDocumentSpec.RequiresMetadata
        if (-not $boolValidateMetadata -and
            $null -ne $hashtableGovernedInstructionContent[$objDocumentSpec.Path]) {
            $boolValidateMetadata = Test-DocumentMetadataHeaderIntent `
                -Content $hashtableGovernedInstructionContent[$objDocumentSpec.Path] -ReuseSlot $objCurrentParseReuse
        }
        if ($boolValidateMetadata -and -not $objDocumentSpec.RequiresVersion -and
            $null -ne $objMetadataParentContent) {
            $boolPriorMetadataIntent = Test-DocumentMetadataHeaderIntent -Content $objMetadataParentContent -ReuseSlot $objParentParseReuse
            if (-not $boolPriorMetadataIntent) {
                $boolInitialMetadataCoverage = -not $objDocumentSpec.RequiresMetadata -or
                    (Test-InitialMetadataCoveragePath `
                        -HasTrustedBaselineManifest $boolHasTrustedBaselineClassificationManifest `
                        -TrustedBaselineExemptPath $arrTrustedBaselineClassificationExemptPaths `
                        -RepositoryRelativePath $objDocumentSpec.Path)
                if ($boolInitialMetadataCoverage) {
                    $objMetadataParentContent = $null
                    Clear-MarkdownParseReuseSlot -Slot $objParentParseReuse
                }
            }
        }
        if (-not $boolValidateMetadata) {
            Clear-MarkdownParseReuseSlot -Slot $objCurrentParseReuse
            Clear-MarkdownParseReuseSlot -Slot $objParentParseReuse
        }
        $listGovernedDocumentContexts.Add([pscustomobject]@{
                CurrentParseReuse = $objCurrentParseReuse
                ParentParseReuse = $objParentParseReuse
                Path = $objDocumentSpec.Path
                MaximumBytes = $objDocumentSpec.MaximumBytes
                Content = $hashtableGovernedInstructionContent[$objDocumentSpec.Path]
                ParentContent = $objParentContext.ParentContent
                MetadataParentContent = $objMetadataParentContent
                IsInitialMetadataCoverage = $boolInitialMetadataCoverage
                ExpectedUtcDate = $objParentContext.ExpectedUtcDate
                IsWorktreeTransition = $objParentContext.IsWorktreeTransition
                RequireFinalizationDate = ($objParentContext.IsWorktreeTransition -or $FinalizeMetadataNow)
                RequiresMetadata = $boolValidateMetadata
                RequiresVersion = $objDocumentSpec.RequiresVersion
                RequiredDocument = $arrDecisionRecordInventoryPaths -cnotcontains `
                    $objDocumentSpec.Path
            })
    }

    $listRepositoryFailures = [Collections.Generic.List[string]]::new()
    $listRepositoryFailures.AddRange([string[]] @(Get-AgentSetupContractFailure -Content $hashtableAgentSetupContent))
    $listRepositoryFailures.AddRange([string[]] @(Get-AgentInstructionFailure `
            -AgentsContent $strAgentsContent `
            -ClaudeContent $strClaudeContent `
            -CodexConfigContent $strCodexConfigContent))
    $strGitIgnoreContent = if ([string]::IsNullOrEmpty($strValidatedInputRevision)) {
        ConvertFrom-StrictUtf8Data `
            -Bytes (Read-RepositoryInputData `
                -Path (Join-Path $strRepositoryRootPath '.gitignore') `
                -RepositoryRootPath $strRepositoryRootPath `
                -RepositoryRelativePath '.gitignore' `
                -DisplayName '.gitignore' `
                -MaximumBytes $intGitIgnoreMaximumInputBytes `
                -RequireIndexContentMatch:($RequireStagedInputMatch -and $setStagedInputPaths.Contains('.gitignore'))) `
            -DisplayName '.gitignore'
    } else {
        Read-GitRevisionText `
            -RepositoryRootPath $strRepositoryRootPath `
            -Revision $strValidatedInputRevision `
            -RepositoryRelativePath '.gitignore' `
            -MaximumBytes $intGitIgnoreMaximumInputBytes `
            -RequireRegularFile
    }
    if (-not (Test-RecursivePersonalMemoryIgnoreContract `
            -GitIgnoreContent $strGitIgnoreContent -TrackedPath $arrTrackedRepositoryPaths)) {
        $listRepositoryFailures.AddRange([string[]] (
            'The root .gitignore must exclude CLAUDE.local.md at every depth with ' +
            'CLAUDE.local.md or **/CLAUDE.local.md after all negations. ' +
            'Nested or case-alias ignore files require a separately validated contract.'
        ))
    }
    foreach ($strPersonalMemoryPath in @('CLAUDE.local.md', 'nested/CLAUDE.local.md', 'tools/project/CLAUDE.local.md')) {
        if (-not (Test-GitIgnorePathEffective `
                -GitIgnoreContent $strGitIgnoreContent `
                -RepositoryRelativePath $strPersonalMemoryPath)) {
            $listRepositoryFailures.AddRange([string[]] (
                "The personal CLAUDE.local.md ignore rule is ineffective: $strPersonalMemoryPath"))
        }
    }
    foreach ($strPublicInstructionPath in @('CLAUDE.md', 'nested/CLAUDE.md', 'tools/project/CLAUDE.md')) {
        if (Test-GitIgnorePathEffective `
                -GitIgnoreContent $strGitIgnoreContent `
                -RepositoryRelativePath $strPublicInstructionPath) {
            $listRepositoryFailures.AddRange([string[]] (
                "The public instruction file must not be ignored: $strPublicInstructionPath"))
        }
    }
    $listRepositoryFailures.AddRange([string[]] @(Get-DocumentationClaimFailure `
            -Content $strDocsInstructionsContent `
            -TrackedPaths $arrTrackedRepositoryPaths))
    $listRepositoryFailures.AddRange([string[]] @(Get-DecisionLifecyclePolicyFailure `
            -Content $strDocsInstructionsContent))
    $arrCanonicalDecisionGuideLinks = @(
        '../../STYLE_GUIDE.md',
        '../../STYLE_GUIDE_RATIONALE.md'
    )
    foreach ($objDecisionContext in @(
            $listGovernedDocumentContexts |
                Where-Object { $_.Path -cmatch $script:strDecisionRecordDirectoryPathPattern }
        )) {
        $listRepositoryFailures.AddRange([string[]] @(Get-DecisionRecordPathFailure `
                -RepositoryRelativePath $objDecisionContext.Path))
        if ($null -eq $objDecisionContext.Content) {
            continue
        }
        $listRepositoryFailures.AddRange([string[]] @(Get-DecisionRecordLifecycleFailure `
                -Name $objDecisionContext.Path `
                -CurrentContent $objDecisionContext.Content `
                -BaselineContent $objDecisionContext.ParentContent))
        $objDecisionMarkdownContext = Get-OperativeMarkdownContext `
            -Content $objDecisionContext.Content
        $arrDecisionLinks = [string[]]@(
            $objDecisionMarkdownContext.ProseBlocks.Links
        )
        foreach ($strGuideLink in $arrCanonicalDecisionGuideLinks) {
            if ($arrDecisionLinks -cnotcontains $strGuideLink) {
                $listRepositoryFailures.AddRange([string[]] "$($objDecisionContext.Path) must contain an operative link to $strGuideLink")
            }
        }
    }
    $listRepositoryFailures.AddRange([string[]] @(Get-NestedClaudeImportFailure `
            -DocumentContexts @(
                $listGovernedDocumentContexts |
                    Where-Object { $arrGovernedInstructionDocuments.Path -ccontains $_.Path } |
                    Select-Object -Property Path, Content
            )))
    foreach ($objDocumentContext in $listGovernedDocumentContexts) {
        $objDocumentEndpointFailure = $null
        try {
            if (-not $objDocumentContext.RequiresMetadata) {
                continue
            }
            if ($null -eq $objDocumentContext.Content) {
                if ($objDocumentContext.RequiredDocument) {
                    $listRepositoryFailures.AddRange([string[]] "$($objDocumentContext.Path) is required in the published final state.")
                }
                continue
            }
            if ($objDocumentContext.RequiresVersion) {
                $listRepositoryFailures.AddRange([string[]] @(Get-PublishedEndpointMetadataFailure `
                        -Name $objDocumentContext.Path `
                        -CurrentContent $objDocumentContext.Content `
                        -ParentContent $objDocumentContext.ParentContent `
                        -ExpectedUtcDate $objDocumentContext.ExpectedUtcDate `
                        -IsNewDocumentTransition ($null -eq $objDocumentContext.ParentContent) `
                        -RequireExpectedUtcDateForRenderedChange `
                            $objDocumentContext.RequireFinalizationDate `
                        -CurrentParseReuse $objDocumentContext.CurrentParseReuse `
                        -ParentParseReuse $objDocumentContext.ParentParseReuse))
            } else {
                $listRepositoryFailures.AddRange([string[]] @(Get-PublishedEndpointLastUpdatedFailure `
                        -Name $objDocumentContext.Path `
                        -CurrentContent $objDocumentContext.Content `
                        -BaseContent $objDocumentContext.MetadataParentContent `
                        -TrustedEventUtcDate $objDocumentContext.ExpectedUtcDate `
                        -RequireCurrentMaximumDateForRenderedChange `
                            $objDocumentContext.RequireFinalizationDate `
                        -CurrentParseReuse $objDocumentContext.CurrentParseReuse `
                        -ParentParseReuse $objDocumentContext.ParentParseReuse))
            }
        } catch {
            $objDocumentEndpointFailure = $_
            throw
        } finally {
            foreach ($objSlot in @($objDocumentContext.CurrentParseReuse, $objDocumentContext.ParentParseReuse)) {
                try { Clear-MarkdownParseReuseSlot -Slot $objSlot } catch {
                    if ($null -eq $objDocumentEndpointFailure) { throw }
                }
            }
        }
    }
} catch {
    $objDocumentParseFailure = $_
    throw
} finally {
    foreach ($objSlot in $listDocumentParseSlots) {
        try { Clear-MarkdownParseReuseSlot -Slot $objSlot } catch {
            if ($null -eq $objDocumentParseFailure) { throw }
        }
    }
}

if ($listRepositoryFailures.Count -gt 0) {
    throw "Agent-instruction contract failed:`n- $($listRepositoryFailures -join "`n- ")"
}

Write-Output 'Agent-instruction content contract passed; maintenance authority is checked separately.'
if ($FinalizeMetadataNow) {
    Write-Output ("Author finalization UTC date checked: $script:strMaximumMetadataUtcDate; " +
        "B=$PublishedBaselineRevision H=$InputRevision.")
} elseif ($boolPublishedEndpointsRequested) {
    Write-Output ("Finalization date not verified by this invocation; " +
        "structural, calendar, baseline and version checks passed: B=$PublishedBaselineRevision H=$InputRevision.")
} else {
    Write-Output 'Finalization date not verified for committed input; local changed-worktree date checks remain applicable.'
}


if ($ProposedPolicy) {
    Write-Output "Proposed-policy transition checks passed: B=$PublishedBaselineRevision H=$InputRevision."
}

#endregion Repository validation

if ($SelfTest) {
    #region Mutation self-tests

    foreach ($strGeneratedMetadataPath in $objDocumentClassificationContext.GeneratedPaths) {
        if (@($listGovernedDocumentContexts | Where-Object Path -CEQ $strGeneratedMetadataPath).Count -ne 0) {
            throw 'Generated aggregate metadata was promoted into optional document validation.'
        }
    }
    foreach ($strOptionalMetadataPath in $objDocumentClassificationContext.Tier2Paths) {
        if (@($listGovernedDocumentContexts | Where-Object Path -CEQ $strOptionalMetadataPath).Count -ne 1) {
            throw 'A retained Tier2 document is missing its optional metadata context.'
        }
    }

    $strExtractedSelfTestPath = '.github/workflows/Test-AgentInstructions.SelfTest.ps1'
    $boolSavedWindowsPython = $hashtableRuntimeContext.WindowsPlatform
    $arrSavedPythonNames = $hashtableRuntimeContext.PythonPathNames
    try {
        $hashtableRuntimeContext.WindowsPlatform = $false
        $hashtableRuntimeContext.PythonPathNames = @('python3.12', 'python3', 'python')
        if ((Get-TomlParseContext -Content $strCodexConfigContent).Failure) {
            throw 'A compatible PATH Python 3.12 interpreter was rejected.'
        }
        foreach ($strRejectedPythonName in @(
                'pwsh', 'missing-python312')) {
            $hashtableRuntimeContext.PythonPathNames = @($strRejectedPythonName)
            if ((Get-TomlParseContext -Content $strCodexConfigContent).Failure -cne
                $strPythonPrerequisite) {
                throw "Python candidate was accepted: $strRejectedPythonName"
            }
        }
    } finally {
        $hashtableRuntimeContext.WindowsPlatform = $boolSavedWindowsPython
        $hashtableRuntimeContext.PythonPathNames = $arrSavedPythonNames
    }

    $strMissingBootstrapFixture = [IO.Path]::Combine(
        [IO.Path]::GetTempPath(),
        ('agent-instruction-bootstrap-{0}' -f [Guid]::NewGuid().ToString('N'))
    )
    $arrMissingBootstrapFailures = @(Get-MarkdownParserBootstrapFailure `
            -RepositoryRootPath $strMissingBootstrapFixture)
    if ($arrMissingBootstrapFailures.Count -ne 1 -or
        -not $arrMissingBootstrapFailures[0].Contains(
            'node .github/workflows/NpmTools.mjs install',
            [StringComparison]::Ordinal
        )) {
        throw 'The node_modules-absent bootstrap fixture did not fail actionably.'
    }

    foreach ($objIgnoreFixture in @(
            [pscustomobject]@{
                Name = 'effective exact root rule'
                Content = "/CLAUDE.local.md`n"
                Expected = $true
            },
            [pscustomobject]@{
                Name = 'later exact negation'
                Content = "/CLAUDE.local.md`n!/CLAUDE.local.md`n"
                Expected = $false
            },
            [pscustomobject]@{
                Name = 'later broad negation'
                Content = "/CLAUDE.local.md`n!/*.local.md`n"
                Expected = $false
            },
            [pscustomobject]@{
                Name = 'unrelated later negation'
                Content = "/CLAUDE.local.md`n!/README.local.md`n"
                Expected = $true
            }
        )) {
        $boolIgnoreResult = Test-GitIgnorePathEffective `
            -GitIgnoreContent $objIgnoreFixture.Content `
            -RepositoryRelativePath 'CLAUDE.local.md'
        if ($boolIgnoreResult -ne $objIgnoreFixture.Expected) {
            throw "Effective-ignore fixture failed: $($objIgnoreFixture.Name)"
        }
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
    $arrDecisionLifecycleFailures = @(Get-DecisionLifecyclePolicyFailure `
            -Content $strDocsInstructionsContent)
    if ($arrDecisionLifecycleFailures.Count -ne 0) {
        throw (
            'The decision lifecycle baseline failed validation: ' +
            ($arrDecisionLifecycleFailures -join '; ')
        )
    }
    $strGenericDecisionStatusMutation = $strDocsInstructionsContent.Replace(
        'Proposed | Accepted | Superseded | Deprecated',
        'Draft | Proposed | Active | Accepted | Superseded | Deprecated'
    )
    if ($strGenericDecisionStatusMutation -ceq $strDocsInstructionsContent -or
        @(Get-DecisionLifecyclePolicyFailure `
                -Content $strGenericDecisionStatusMutation) -cnotcontains
            ('Decision record Status must allow exactly ' +
                'Proposed | Accepted | Superseded | Deprecated.')) {
        throw 'A generic decision Status set did not fail closed.'
    }
    $strDuplicateDecisionStatusMutation = $strDocsInstructionsContent.Replace(
        'A decision record MUST NOT add a separate narrative status field or section.',
        ('A second **Status** representation records decision history. ' +
            'A decision record MUST NOT add a separate narrative status field or section.')
    )
    if ($strDuplicateDecisionStatusMutation -ceq $strDocsInstructionsContent -or
        @(Get-DecisionLifecyclePolicyFailure `
                -Content $strDuplicateDecisionStatusMutation) -cnotcontains
            'Decision records must use exactly one Tier 1 Status representation.') {
        throw 'A duplicate decision Status representation did not fail closed.'
    }
    $strNarrativeDecisionStatusMutation = $strDocsInstructionsContent.Replace(
        'A decision record MUST NOT add a separate narrative status field or section.',
        'A decision record MAY add a separate narrative status field or section.'
    )
    if ($strNarrativeDecisionStatusMutation -ceq $strDocsInstructionsContent -or
        @(Get-DecisionLifecyclePolicyFailure `
                -Content $strNarrativeDecisionStatusMutation) -cnotcontains
            'Decision records must prohibit a separate narrative status representation.') {
        throw 'A permitted narrative decision Status did not fail closed.'
    }
    $strPermanentLegacyDecisionMutation = $strDocsInstructionsContent.Replace(
        'while their bytes remain unchanged.',
        'without a required migration boundary.'
    )
    if ($strPermanentLegacyDecisionMutation -ceq $strDocsInstructionsContent -or
        @(Get-DecisionLifecyclePolicyFailure `
                -Content $strPermanentLegacyDecisionMutation) -cnotcontains
            'Decision records must document the unchanged legacy migration boundary.') {
        throw 'A permanent legacy decision exception did not fail closed.'
    }
    $strOptionalLegacyMigrationMutation = $strDocsInstructionsContent.Replace(
        'The next change to such a record MUST migrate it',
        'The next change to such a record MAY migrate it'
    )
    if ($strOptionalLegacyMigrationMutation -ceq $strDocsInstructionsContent -or
        @(Get-DecisionLifecyclePolicyFailure `
                -Content $strOptionalLegacyMigrationMutation) -cnotcontains
            'Decision records must document the unchanged legacy migration boundary.') {
        throw 'An optional legacy decision migration did not fail closed.'
    }
    $strLegacyDecisionRecord = @(
        '# Decision 0001: Legacy fixture'
        '## Metadata'
        '- **Status:** Active'
        '- **Owner:** Repository Maintainers'
        '- **Last Updated:** 2026-08-30'
        '- **Scope:** Tests transition-aware ADR lifecycle enforcement.'
        '## Status'
        'Accepted before the lifecycle migration.'
        '## Context'
        'Legacy context.'
    ) -join "`n"
    if (@(Get-DecisionRecordLifecycleFailure `
            -Name 'docs/decisions/0001-legacy.md' `
            -CurrentContent $strLegacyDecisionRecord `
            -BaselineContent $strLegacyDecisionRecord).Count -ne 0) {
        throw 'An unchanged published legacy ADR did not remain valid.'
    }
    $strChangedLegacyDecisionRecord = $strLegacyDecisionRecord.Replace(
        'Legacy context.',
        'Changed legacy context.'
    )
    $arrChangedLegacyDecisionFailures = @(Get-DecisionRecordLifecycleFailure `
            -Name 'docs/decisions/0001-legacy.md' `
            -CurrentContent $strChangedLegacyDecisionRecord `
            -BaselineContent $strLegacyDecisionRecord)
    foreach ($strExpectedFailure in @(
            ('docs/decisions/0001-legacy.md Status must be Proposed, Accepted, ' +
                'Superseded, or Deprecated.'),
            ('docs/decisions/0001-legacy.md must not contain a separate operative ' +
                'Status section.')
        )) {
        if ($arrChangedLegacyDecisionFailures -cnotcontains $strExpectedFailure) {
            throw (
                'A changed legacy ADR did not require lifecycle migration: ' +
                ($arrChangedLegacyDecisionFailures -join '; ')
            )
        }
    }
    $strCompliantDecisionRecord = $strChangedLegacyDecisionRecord.Replace(
        '- **Status:** Active',
        '- **Status:** Accepted'
    ).Replace(
        "## Status`nAccepted before the lifecycle migration.`n",
        ''
    )
    if (@(Get-DecisionRecordLifecycleFailure `
            -Name 'docs/decisions/0001-legacy.md' `
            -CurrentContent $strCompliantDecisionRecord `
            -BaselineContent $strLegacyDecisionRecord).Count -ne 0) {
        throw 'A changed ADR with one valid lifecycle Status did not pass.'
    }
    # The same canonical Status exemption must apply to headed and direct metadata.
    $strDirectDecisionRecord = $strCompliantDecisionRecord.Replace("## Metadata`n", '')
    foreach ($strDecisionForm in @($strCompliantDecisionRecord, $strDirectDecisionRecord)) {
        foreach ($strLifecycleState in @('Proposed', 'Accepted', 'Superseded', 'Deprecated')) {
            $strStateRecord = $strDecisionForm.Replace(
                '- **Status:** Accepted', "- **Status:** $strLifecycleState")
            if (@(Get-DecisionRecordLifecycleFailure `
                        -Name 'docs/decisions/0001-legacy.md' `
                        -CurrentContent $strStateRecord -BaselineContent $null).Count -ne 0) {
                throw "A supported metadata form rejected lifecycle state $strLifecycleState."
            }
        }
        foreach ($strExtraLifecycleField in @(
                "`nStatus: Accepted`n`n",
                "- **Decision Status:** Accepted`n",
                "`n| Field | Value |`n| --- | --- |`n| **decision** ``status`` | *Accepted* |`n`n"
            )) {
            $strExtraFieldRecord = $strDecisionForm.Replace(
                "## Context`n", "$strExtraLifecycleField## Context`n")
            if (@(Get-DecisionRecordLifecycleFailure `
                        -Name 'docs/decisions/0001-legacy.md' `
                        -CurrentContent $strExtraFieldRecord `
                        -BaselineContent $strLegacyDecisionRecord) -cnotcontains
                'docs/decisions/0001-legacy.md must not contain a separate operative Status field.') {
                throw 'A separate lifecycle field escaped the canonical metadata Status exemption.'
            }
        }
        $strExtraMetadataRecord = $strDecisionForm.Replace(
            "## Context`n", "- **Related:** An ordinary supporting reference.`n## Context`n")
        if (@(Get-DecisionRecordLifecycleFailure `
                    -Name 'docs/decisions/0001-legacy.md' `
                    -CurrentContent $strExtraMetadataRecord `
                    -BaselineContent $strLegacyDecisionRecord).Count -ne 0) {
            throw 'Ordinary extra metadata caused a lifecycle false positive.'
        }
    }
    $strBodyStartDecisionRecord = $strDirectDecisionRecord.Replace(
        "# Decision 0001: Legacy fixture`n", '')
    foreach ($strMappedDecisionRecord in @(
            $strBodyStartDecisionRecord,
            "<!-- markdownlint-disable MD013 -->`n$strBodyStartDecisionRecord",
            "---`nkind: decision`n---`n$strDirectDecisionRecord",
            "<!-- Leading`nmultiline comment -->`n$strDirectDecisionRecord",
            "<!-- Leading`nmultiline comment -->`n$strCompliantDecisionRecord"
        )) {
        if (@(Get-DecisionRecordLifecycleFailure `
                    -Name 'docs/decisions/0001-legacy.md' `
                    -CurrentContent $strMappedDecisionRecord -BaselineContent $null).Count -ne 0) {
            throw 'A supported metadata placement failed canonical Status validation.'
        }
        $strMappedExtraFieldRecord = $strMappedDecisionRecord.Replace(
            'Changed legacy context.', 'Status: Accepted')
        if (@(Get-DecisionRecordLifecycleFailure `
                    -Name 'docs/decisions/0001-legacy.md' `
                    -CurrentContent $strMappedExtraFieldRecord -BaselineContent $null) -cnotcontains
            'docs/decisions/0001-legacy.md must not contain a separate operative Status field.') {
            throw 'Metadata source-coordinate mapping hid a separate lifecycle field.'
        }
    }
    $strDirectLegacyDecisionRecord = $strLegacyDecisionRecord.Replace("## Metadata`n", '')
    if (@(Get-DecisionRecordLifecycleFailure `
                -Name 'docs/decisions/0001-legacy.md' `
                -CurrentContent $strDirectLegacyDecisionRecord `
                -BaselineContent $strDirectLegacyDecisionRecord).Count -ne 0) {
        throw 'An unchanged direct-form legacy ADR lost its migration boundary.'
    }
    $strChangedDirectLegacyDecisionRecord = $strDirectLegacyDecisionRecord.Replace(
        'Legacy context.', 'Changed legacy context.')
    $arrDirectLegacyFailures = @(Get-DecisionRecordLifecycleFailure `
            -Name 'docs/decisions/0001-legacy.md' `
            -CurrentContent $strChangedDirectLegacyDecisionRecord `
            -BaselineContent $strDirectLegacyDecisionRecord)
    foreach ($strExpectedDirectLegacyFailure in @(
            'docs/decisions/0001-legacy.md Status must be Proposed, Accepted, Superseded, or Deprecated.',
            'docs/decisions/0001-legacy.md must not contain a separate operative Status section.'
        )) {
        if ($arrDirectLegacyFailures -cnotcontains $strExpectedDirectLegacyFailure) {
            throw 'A changed direct-form legacy ADR did not require lifecycle migration.'
        }
    }

    foreach ($strAcceptedStatusLabel in @(
            'Status', 'status', 'Decision Status', " Decision`tStatus "
        )) {
        if (-not (Test-DecisionLifecycleStatusLabel `
                -Label $strAcceptedStatusLabel)) {
            throw "Exact lifecycle label was rejected: $strAcceptedStatusLabel"
        }
    }
    foreach ($strRejectedStatusLabel in @(
            '', 'HTTP Status Codes', 'Deployment Status',
            'Deployment Status Checks', 'Status Check'
        )) {
        if (Test-DecisionLifecycleStatusLabel -Label $strRejectedStatusLabel) {
            throw "Unrelated lifecycle label was accepted: $strRejectedStatusLabel"
        }
    }
    $strDecisionStatusSectionRecord = $strCompliantDecisionRecord.Replace(
        "## Context`n",
        "## Decision Status`nAccepted.`n## Context`n"
    )
    if (@(Get-DecisionRecordLifecycleFailure `
            -Name 'docs/decisions/0001-legacy.md' `
            -CurrentContent $strDecisionStatusSectionRecord `
            -BaselineContent $strLegacyDecisionRecord) -cnotcontains
        ('docs/decisions/0001-legacy.md must not contain a separate operative ' +
            'Status section.')) {
        throw 'A Decision Status section escaped lifecycle validation.'
    }
    $arrSubordinateStatusSectionFixtures = @(
        [pscustomobject]@{
            Name = 'level-three Decision Status section'
            Heading = '### Decision Status'
        },
        [pscustomobject]@{
            Name = 'formatted level-three Decision Status section'
            Heading = '### Decision **Status**'
        },
        [pscustomobject]@{
            Name = 'linked level-four Status section'
            Heading = '#### Decision [Status](https://example.invalid/status)'
        },
        [pscustomobject]@{
            Name = 'level-five Status section'
            Heading = '##### Status'
        },
        [pscustomobject]@{
            Name = 'level-six Decision Status section'
            Heading = '###### Decision Status'
        }
    )
    foreach ($objStatusSectionFixture in $arrSubordinateStatusSectionFixtures) {
        $strSubordinateStatusSectionRecord = $strCompliantDecisionRecord.Replace(
            'Changed legacy context.',
            "Changed legacy context.`n$($objStatusSectionFixture.Heading)`nAccepted."
        )
        if (@(Get-DecisionRecordLifecycleFailure `
                -Name 'docs/decisions/0001-legacy.md' `
                -CurrentContent $strSubordinateStatusSectionRecord `
                -BaselineContent $strLegacyDecisionRecord) -cnotcontains
            ('docs/decisions/0001-legacy.md must not contain a separate operative ' +
                'Status section.')) {
            throw "$($objStatusSectionFixture.Name) escaped lifecycle validation."
        }
    }
    foreach ($strUnrelatedStatusHeading in @(
            '### HTTP Status Codes', '#### Deployment Status Checks'
        )) {
        $strUnrelatedStatusHeadingRecord = $strCompliantDecisionRecord.Replace(
            'Changed legacy context.',
            "Changed legacy context.`n$strUnrelatedStatusHeading`nNo lifecycle field."
        )
        if (@(Get-DecisionRecordLifecycleFailure `
                -Name 'docs/decisions/0001-legacy.md' `
                -CurrentContent $strUnrelatedStatusHeadingRecord `
                -BaselineContent $strLegacyDecisionRecord).Count -ne 0) {
            throw "Unrelated heading caused a lifecycle finding: $strUnrelatedStatusHeading"
        }
    }
    $arrNonOperativeStatusHeadingFixtures = @(
        [pscustomobject]@{
            Name = 'quoted level-three Status heading'
            Payload = '> ### Decision Status'
        },
        [pscustomobject]@{
            Name = 'listed level-four Status heading'
            Payload = "- Example`n  #### Status"
        },
        [pscustomobject]@{
            Name = 'fenced level-three Status heading example'
            Payload = @(
                '```markdown'
                '### Decision Status'
                '```'
            ) -join "`n"
        },
        [pscustomobject]@{
            Name = 'indented level-three Status heading example'
            Payload = '    ### Decision Status'
        },
        [pscustomobject]@{
            Name = 'commented level-three Status heading example'
            Payload = '<!-- ### Decision Status -->'
        },
        [pscustomobject]@{
            Name = 'inline-code-only level-three Status heading example'
            Payload = '### `Decision Status`'
        },
        [pscustomobject]@{
            Name = 'raw-HTML-only level-three Status heading example'
            Payload = '### <span>Decision Status</span>'
        }
    )
    foreach ($objStatusHeadingFixture in $arrNonOperativeStatusHeadingFixtures) {
        $strNonOperativeStatusHeadingRecord = $strCompliantDecisionRecord.Replace(
            'Changed legacy context.',
            "Changed legacy context.`n$($objStatusHeadingFixture.Payload)"
        )
        if (@(Get-DecisionRecordLifecycleFailure `
                -Name 'docs/decisions/0001-legacy.md' `
                -CurrentContent $strNonOperativeStatusHeadingRecord `
                -BaselineContent $strLegacyDecisionRecord).Count -ne 0) {
            throw "$($objStatusHeadingFixture.Name) caused a false lifecycle finding."
        }
    }
    $strDecisionStatusFieldRecord = $strCompliantDecisionRecord.Replace(
        "## Context`n",
        "## Context`n- **Decision Status:** Accepted`n"
    )
    if (@(Get-DecisionRecordLifecycleFailure `
            -Name 'docs/decisions/0001-legacy.md' `
            -CurrentContent $strDecisionStatusFieldRecord `
            -BaselineContent $strLegacyDecisionRecord) -cnotcontains
        ('docs/decisions/0001-legacy.md must not contain a separate operative ' +
            'Status field.')) {
        throw 'A Decision Status field escaped lifecycle validation.'
    }
    $strStatusFieldRecord = $strCompliantDecisionRecord.Replace(
        'Changed legacy context.',
        'Status: Accepted'
    )
    if (@(Get-DecisionRecordLifecycleFailure `
            -Name 'docs/decisions/0001-legacy.md' `
            -CurrentContent $strStatusFieldRecord `
            -BaselineContent $strLegacyDecisionRecord) -cnotcontains
        ('docs/decisions/0001-legacy.md must not contain a separate operative ' +
            'Status field.')) {
        throw 'A Status prose field escaped lifecycle validation.'
    }
    $strLaterListStatusFieldRecord = $strCompliantDecisionRecord.Replace(
        'Changed legacy context.',
        @(
            '- Example paragraph.'
            ''
            '  Status: Accepted'
        ) -join "`n"
    )
    if (@(Get-DecisionRecordLifecycleFailure `
            -Name 'docs/decisions/0001-legacy.md' `
            -CurrentContent $strLaterListStatusFieldRecord `
            -BaselineContent $strLegacyDecisionRecord) -cnotcontains
        ('docs/decisions/0001-legacy.md must not contain a separate operative ' +
            'Status field.')) {
        throw 'A later direct top-level list-item Status field escaped lifecycle validation.'
    }
    $arrNonOperativeListStatusFieldFixtures = @(
        [pscustomobject]@{
            Name = 'nested-list Status field example'
            Payload = @(
                '- Example paragraph.'
                '  - Status: Accepted'
            ) -join "`n"
        },
        [pscustomobject]@{
            Name = 'list-item blockquoted Status field example'
            Payload = @(
                '- Example paragraph.'
                ''
                '  > Status: Accepted'
            ) -join "`n"
        }
    )
    foreach ($objStatusFieldFixture in $arrNonOperativeListStatusFieldFixtures) {
        $strNonOperativeListStatusFieldRecord = $strCompliantDecisionRecord.Replace(
            'Changed legacy context.',
            $objStatusFieldFixture.Payload
        )
        if (@(Get-DecisionRecordLifecycleFailure `
                -Name 'docs/decisions/0001-legacy.md' `
                -CurrentContent $strNonOperativeListStatusFieldRecord `
                -BaselineContent $strLegacyDecisionRecord).Count -ne 0) {
            throw "$($objStatusFieldFixture.Name) caused a false lifecycle finding."
        }
    }
    $strQuotedStatusFieldRecord = $strCompliantDecisionRecord.Replace(
        'Changed legacy context.',
        '> **Status:** Proposed'
    )
    if (@(Get-DecisionRecordLifecycleFailure `
            -Name 'docs/decisions/0001-legacy.md' `
            -CurrentContent $strQuotedStatusFieldRecord `
            -BaselineContent $strLegacyDecisionRecord).Count -ne 0) {
        throw 'A blockquoted Status example caused a false lifecycle finding.'
    }
    $arrTableStatusFailureFixtures = @(
        [pscustomobject]@{
            Name = 'exact two-cell Status data row'
            Content = $strCompliantDecisionRecord.Replace(
                "## Context`n",
                (@(
                        '## Context'
                        '| Field | Value |'
                        '| --- | --- |'
                        '| Status | Accepted |'
                    ) -join "`n") + "`n"
            )
        },
        [pscustomobject]@{
            Name = 'body Decision Status field with alignment and inline formatting'
            Content = $strCompliantDecisionRecord.Replace(
                "## Context`n",
                (@(
                        '## Context'
                        '| Field | Value |'
                        '| :--- | ---: |'
                        '| **decision** `status` | *Accepted* |'
                    ) -join "`n") + "`n"
            )
        }
    )
    foreach ($objTableStatusFixture in $arrTableStatusFailureFixtures) {
        if (@(Get-DecisionRecordLifecycleFailure `
                -Name 'docs/decisions/0001-legacy.md' `
                -CurrentContent $objTableStatusFixture.Content `
                -BaselineContent $strLegacyDecisionRecord) -cnotcontains
            ('docs/decisions/0001-legacy.md must not contain a separate operative ' +
                'Status field.')) {
            throw "$($objTableStatusFixture.Name) escaped lifecycle validation."
        }
    }
    $arrTableStatusAcceptedFixtures = @(
        [pscustomobject]@{
            Name = 'header-only Status row'
            Content = $strCompliantDecisionRecord.Replace(
                'Changed legacy context.',
                (@(
                        'Changed legacy context.'
                        '| STATUS | Accepted |'
                        '| --- | --- |'
                    ) -join "`n")
            )
        },
        [pscustomobject]@{
            Name = 'ordinary three-column option table'
            Content = $strCompliantDecisionRecord.Replace(
                'Changed legacy context.',
                (@(
                        'Changed legacy context.'
                        '| Option | Status | Rationale |'
                        '| --- | --- | --- |'
                        '| Keep | Accepted | Least churn |'
                    ) -join "`n")
            )
        },
        [pscustomobject]@{
            Name = 'multi-column Status data row'
            Content = $strCompliantDecisionRecord.Replace(
                'Changed legacy context.',
                (@(
                        'Changed legacy context.'
                        '| Field | Value | Rationale |'
                        '| --- | --- | --- |'
                        '| Status | Accepted | Current decision |'
                    ) -join "`n")
            )
        },
        [pscustomobject]@{
            Name = 'blockquoted two-cell Status table'
            Content = $strCompliantDecisionRecord.Replace(
                'Changed legacy context.',
                (@(
                        'Changed legacy context.'
                        '> | Field | Value |'
                        '> | --- | --- |'
                        '> | Status | Accepted |'
                    ) -join "`n")
            )
        },
        [pscustomobject]@{
            Name = 'listed two-cell Status table'
            Content = $strCompliantDecisionRecord.Replace(
                'Changed legacy context.',
                (@(
                        'Changed legacy context.'
                        '- Example:'
                        ''
                        '  | Field | Value |'
                        '  | --- | --- |'
                        '  | Status | Accepted |'
                    ) -join "`n")
            )
        },
        [pscustomobject]@{
            Name = 'nested-list two-cell Status table'
            Content = $strCompliantDecisionRecord.Replace(
                'Changed legacy context.',
                (@(
                        'Changed legacy context.'
                        '- Outer'
                        '  - Inner:'
                        ''
                        '    | Field | Value |'
                        '    | --- | --- |'
                        '    | Status | Accepted |'
                    ) -join "`n")
            )
        },
        [pscustomobject]@{
            Name = 'fenced table example'
            Content = $strCompliantDecisionRecord.Replace(
                'Changed legacy context.',
                (@(
                        'Changed legacy context.'
                        '```markdown'
                        '| Status | Accepted |'
                        '| --- | --- |'
                        '```'
                    ) -join "`n")
            )
        },
        [pscustomobject]@{
            Name = 'commented table example'
            Content = $strCompliantDecisionRecord.Replace(
                'Changed legacy context.',
                (@(
                        'Changed legacy context.'
                        '<!--'
                        '| Status | Accepted |'
                        '| --- | --- |'
                        '-->'
                    ) -join "`n")
            )
        },
        [pscustomobject]@{
            Name = 'unrelated table'
            Content = $strCompliantDecisionRecord.Replace(
                'Changed legacy context.',
                (@(
                        'Changed legacy context.'
                        '| State | Owner |'
                        '| --- | --- |'
                        '| Accepted | Maintainers |'
                    ) -join "`n")
            )
        },
        [pscustomobject]@{
            Name = 'unrelated exact two-cell Deployment Status data row'
            Content = $strCompliantDecisionRecord.Replace(
                'Changed legacy context.',
                (@(
                        'Changed legacy context.'
                        '| Field | Value |'
                        '| --- | --- |'
                        '| Deployment Status | healthy |'
                    ) -join "`n")
            )
        },
        [pscustomobject]@{
            Name = 'empty Status table value'
            Content = $strCompliantDecisionRecord.Replace(
                'Changed legacy context.',
                (@(
                        'Changed legacy context.'
                        '| Field | Value |'
                        '| --- | --- |'
                        '| Status | |'
                    ) -join "`n")
            )
        }
    )
    foreach ($objTableStatusFixture in $arrTableStatusAcceptedFixtures) {
        if (@(Get-DecisionRecordLifecycleFailure `
                -Name 'docs/decisions/0001-legacy.md' `
                -CurrentContent $objTableStatusFixture.Content `
                -BaselineContent $strLegacyDecisionRecord).Count -ne 0) {
            throw "$($objTableStatusFixture.Name) caused a false lifecycle finding."
        }
    }
    $strDecisionStatusProseRecord = $strCompliantDecisionRecord.Replace(
        'Changed legacy context.',
        'The decision status remains accepted in ordinary prose.'
    )
    if (@(Get-DecisionRecordLifecycleFailure `
            -Name 'docs/decisions/0001-legacy.md' `
            -CurrentContent $strDecisionStatusProseRecord `
            -BaselineContent $strLegacyDecisionRecord).Count -ne 0) {
        throw 'Ordinary decision status prose was rejected as a second representation.'
    }
    foreach ($strUnrelatedStatusField in @(
            'Deployment Status: healthy', 'HTTP Status Codes: 200 and 204'
        )) {
        $strUnrelatedStatusFieldRecord = $strCompliantDecisionRecord.Replace(
            'Changed legacy context.',
            $strUnrelatedStatusField
        )
        if (@(Get-DecisionRecordLifecycleFailure `
                -Name 'docs/decisions/0001-legacy.md' `
                -CurrentContent $strUnrelatedStatusFieldRecord `
                -BaselineContent $strLegacyDecisionRecord).Count -ne 0) {
            throw "Unrelated prose field caused a lifecycle finding: $strUnrelatedStatusField"
        }
    }
    if (@(Get-DecisionRecordLifecycleFailure `
            -Name 'docs/decisions/0003-new.md' `
            -CurrentContent $strLegacyDecisionRecord `
            -BaselineContent $null).Count -ne 2) {
        throw 'A new ADR accepted the legacy two-status representation.'
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
        $arrNewDocumentFailures = @(Get-PublishedEndpointMetadataFailure `
                -Name '.github/instructions/docs.instructions.md' `
                -CurrentContent $strNewDocumentMutation `
                -ParentContent $null `
                -ExpectedUtcDate $objDocsMetadataContext.UpdatedDate `
                -IsNewDocumentTransition $true)
        if (-not ($arrNewDocumentFailures -match 'Last Updated must be')) {
            throw "A new document with date $strNewDocumentDate did not fail closed."
        }
    }
    $arrDocsStaleMetadataFailures = @(Get-PublishedEndpointMetadataFailure `
            -Name '.github/instructions/docs.instructions.md' `
            -CurrentContent $strDocsStaleMetadataMutation `
            -ParentContent $strDocsInstructionsContent `
            -ExpectedUtcDate $objDocsMetadataContext.UpdatedDate `
            -IsNewDocumentTransition $false)
    if (-not ($arrDocsStaleMetadataFailures -match [regex]::Escape(
                '.github/instructions/docs.instructions.md Version revision must be exactly'
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
        $arrStaleMetadataFailures = @(Get-PublishedEndpointMetadataFailure `
                -Name $strNewlyCoveredPath `
                -CurrentContent $strStaleMetadataMutation `
                -ParentContent $objDocumentContext.Content `
                -ExpectedUtcDate $objMetadataContext.UpdatedDate `
                -IsNewDocumentTransition $false)
        $strFailure = "$strNewlyCoveredPath Version revision must be exactly"
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
    $strExtractedSelfTestRevision = if (
        [string]::IsNullOrEmpty($strValidatedInputRevision)
    ) {
        $strCheckedOutRevision
    } else {
        $strValidatedInputRevision
    }
    & (Join-Path $strRepositoryRootPath $strExtractedSelfTestPath) `
        -RuntimeContext $hashtableRuntimeContext `
        -RepositoryRootPath $strRepositoryRootPath `
        -Revision $strExtractedSelfTestRevision `
        -MaximumBytes $intGitPathListMaximumBytes `
        -MaximumMetadataUtcDate $script:strMaximumMetadataUtcDate
    foreach ($strExactValidatorInputPath in $script:arrPushGovernedExactPaths) {
        if (-not (Test-AgentInstructionWorkflowPath `
                    -RepositoryRelativePath $strExactValidatorInputPath)) {
            throw "An exact validator input escaped push applicability: $strExactValidatorInputPath"
        }
    }
    $strRationalePath = 'STYLE_GUIDE_RATIONALE.md'
    $arrRationaleSpecs = @($arrGovernedMetadataDocuments |
            Where-Object { $_.Path -ceq $strRationalePath })
    $arrRationaleContexts = @($listGovernedDocumentContexts |
            Where-Object { $_.Path -ceq $strRationalePath })
    if (@($script:arrPushGovernedExactPaths |
            Where-Object { $_ -ceq $strRationalePath }).Count -ne 1 -or
        $arrRationaleSpecs.Count -ne 1 -or
        $arrRationaleContexts.Count -ne 1 -or
        $arrRationaleSpecs[0].MaximumBytes -ne
            $intStyleGuideRationaleMaximumInputBytes -or
        -not $arrRationaleSpecs[0].RequiresMetadata -or
        $arrRationaleSpecs[0].RequiresVersion -or
        $intStyleGuideRationaleMaximumInputBytes -ne 196608 -or
        [Text.Encoding]::UTF8.GetByteCount($arrRationaleContexts[0].Content) -gt
            $intStyleGuideRationaleMaximumInputBytes) {
        throw 'The canonical rationale lacks exact bounded Tier 1 catalog enforcement.'
    }
    foreach ($strLintGuidePath in $script:arrOperationalLintGuidePaths) {
        $arrLintGuideContexts = @($listGovernedDocumentContexts |
                Where-Object { $_.Path -ceq $strLintGuidePath })
        if ($arrLintGuideContexts.Count -ne 1) {
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
        } else {
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
    $arrNestedGeminiMetadataFailures = @(Get-PublishedEndpointMetadataFailure `
            -Name 'tools/GEMINI.md' `
            -CurrentContent $strDocsStaleMetadataMutation `
            -ParentContent $strDocsInstructionsContent `
            -ExpectedUtcDate $objDocsMetadataContext.UpdatedDate `
            -IsNewDocumentTransition $false)
    if (-not ($arrNestedGeminiMetadataFailures -match [regex]::Escape(
                'tools/GEMINI.md Version revision must be exactly'
            ))) {
        throw 'A cataloged nested GEMINI.md bypassed rendered metadata transition.'
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
                @(Get-PublishedEndpointMetadataFailure -Name $objDocumentContext.Path `
                        -CurrentContent $strFieldDeletion `
                        -ParentContent $objDocumentContext.Content `
                        -ExpectedUtcDate $objDocumentContext.ExpectedUtcDate `
                        -IsNewDocumentTransition $false)
            } else {
                @(Get-PublishedEndpointLastUpdatedFailure -Name $objDocumentContext.Path `
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
        $arrFieldFailures = @(Get-PublishedEndpointMetadataFailure `
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
    foreach ($objHiddenStatusCase in @(
            [pscustomobject]@{ Content = "<div>`n$strStatusLine`n</div>";
                ExpectedFailure = 'must place one document-level metadata list immediately' },
            [pscustomobject]@{ Content = "- Wrapper`n  $strStatusLine";
                ExpectedFailure = 'one exact top-level Status list item' }
        )) {
        $strHiddenStatusMutation = $objRepresentativeDocument.Content.Replace(
            $strStatusLine,
            $objHiddenStatusCase.Content
        )
        $arrFieldFailures = @(Get-PublishedEndpointMetadataFailure `
                -Name $objRepresentativeDocument.Path `
                -CurrentContent $strHiddenStatusMutation `
                -ParentContent $objRepresentativeDocument.Content `
                -ExpectedUtcDate $objRepresentativeDocument.ExpectedUtcDate `
                -IsNewDocumentTransition $false)
        if ($arrFieldFailures.Count -eq 0 -or -not ($arrFieldFailures -match
                [regex]::Escape($objHiddenStatusCase.ExpectedFailure))) {
            throw ("Non-operative Status mutation did not produce its intended failure: " +
                "$($objHiddenStatusCase.ExpectedFailure). Actual: $($arrFieldFailures -join '; ')")
        }
    }

    # Input metadata and linked-component mutations run in the extracted helper.

    Assert-OversizedStreamMutationRejected

    Assert-MarkdownParserTransportCleanup

    Assert-MarkdownParserExactContext

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
        [pscustomobject]@{Name = 'late empty';Bytes = [Text.Encoding]::UTF8.GetBytes("a`0`0");Failure = 'empty path'},
        [pscustomobject]@{Name = 'empty';Bytes = [byte[]]@(0);Failure = 'empty path'},
        [pscustomobject]@{Name = 'UTF-8';Bytes = [byte[]]@(0xC3,0x28,0);Failure = 'valid UTF-8'},
        [pscustomobject]@{Name = 'unterminated';Bytes = [byte[]]@(0x61);Failure = 'end with a NUL'},
        [pscustomobject]@{Name = 'duplicate';Bytes = [Text.Encoding]::UTF8.GetBytes("a`0a`0");Failure = 'duplicate path'})
    foreach ($objPathDataMutation in $arrPathDataMutations) {
        $listPathPrefix = [Collections.Generic.List[string]]::new()
        try {
            ConvertFrom-GitPathListData -Bytes $objPathDataMutation.Bytes |
                ForEach-Object { $listPathPrefix.Add($_) }
            throw "Git path mutation passed: $($objPathDataMutation.Name)"
        } catch [IO.InvalidDataException] {
            if ($listPathPrefix.Count -ne 0) {
                throw 'Rejected Git path data emitted a partial result.'
            }
            if (-not $_.Exception.Message.Contains(
                    $objPathDataMutation.Failure, [StringComparison]::Ordinal)) {
                throw "Wrong Git path failure: $($objPathDataMutation.Name)"
            }
        }
    }
    if (@(ConvertFrom-GitPathListData -Bytes ([byte[]] @())).Count -ne 0) {
        throw 'Empty Git output changed inventory.'
    }
    # Index/revision parity and staged-addition tests use the extracted fixture.

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
        $strH1Failure = "$($objDocument.Name) must contain at most one document-level H1."
        $strVersionFailure = "$($objDocument.Name) must contain one exact " +
            'document-level Version paragraph immediately after an H1 within the first 30 body lines.'
        $strMetadataHeadingFailure = "$($objDocument.Name) must place one document-level metadata list immediately after " +
            'the early H1 and optional Version, or at body start after an optional leading markdownlint-disable directive; ' +
            'an optional Metadata section must be the first H2 immediately after the early H1 and optional Version.'
        $strUpdatedFailure = "$($objDocument.Name) must contain one exact top-level " +
            'Last Updated list item in the document-level metadata list.'
        $strParentVersionFailure = "The parent of $($objDocument.Name) must contain " +
            'one exact document-level Version paragraph immediately after an H1 within the first 30 body lines.'

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
                Name = 'required Version cannot follow a late H1'
                Content = $objDocument.Content.Replace(
                    $objDocument.H1Line,
                    (("`n" * 30) + $objDocument.H1Line)
                )
                Failure = $strVersionFailure
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
                } else {
                    $strAgentsContent
                }
                ClaudeContent = if ($objDocument.Name -ceq 'CLAUDE.md') {
                    $objMutation.Content
                } else {
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
        } else {
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
        } else {
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

    # Reserve bytes for expanding semantic fixtures without shortening policy text.
    # Real documents and explicit byte-boundary mutations retain their exact input.
    $strAgentsFixtureScopePattern = '(?m)^- \*\*Scope:\*\* [^\r\n]+$'
    if ([regex]::Matches($strAgentsContent, $strAgentsFixtureScopePattern).Count -ne 1) {
        throw 'Expected one AGENTS Scope value for semantic fixture construction.'
    }
    $strAgentsSemanticFixture = [regex]::Replace(
        $strAgentsContent,
        $strAgentsFixtureScopePattern,
        '- **Scope:** Agent-instruction mutation fixtures.'
    )
    Assert-FixtureAccepted -AgentsContent $strAgentsSemanticFixture

    $strRenderedAgentsMutation = $strAgentsSemanticFixture + [Environment]::NewLine +
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
        -Failure ("AGENTS.md Version revision must be exactly " +
            "$intNextAgentsRevision after a published change with an " +
            'unchanged published-baseline major, minor, and date tuple.')

    $strHigherRevisionParent = $strAgentsContent.Replace(
        $objAgentsVersionMatch.Value,
        $strAgentsVersionStem + $intNextAgentsRevision
    )
    Assert-Failure `
        -AgentsContent $strRenderedAgentsMutation `
        -ParentAgentsContent $strHigherRevisionParent `
        -AgentsExpectedUtcDate $objAgentsUpdatedMatch.Groups['Date'].Value `
        -Failure ("AGENTS.md Version revision must not decrease from " +
            "$intNextAgentsRevision to $($intNextAgentsRevision - 1).")

    Assert-Failure `
        -ParentAgentsContent $strHigherRevisionParent `
        -AgentsExpectedUtcDate $objAgentsUpdatedMatch.Groups['Date'].Value `
        -Failure ("AGENTS.md Version revision must not decrease from " +
            "$intNextAgentsRevision to $($intNextAgentsRevision - 1).")

    Assert-FixtureAccepted `
        -ParentAgentsContent $strAgentsContent

    $strMaximumRevisionContent = $strAgentsSemanticFixture.Replace(
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
    Assert-Failure `
        -AgentsContent $strSameDayRevisionJump `
        -ParentAgentsContent $strAgentsContent `
        -AgentsExpectedUtcDate $objAgentsUpdatedMatch.Groups['Date'].Value `
        -Failure ("AGENTS.md Version revision must be exactly " +
            "$intNextAgentsRevision after a published change with an " +
            'unchanged published-baseline major, minor, and date tuple.')

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

    # Published endpoint regressions deliberately ignore intermediate topic commits.
    $strEndpointBaseline = @(
        '# Endpoint fixture'
        '**Version:** 1.0.20260830.0'
        '## Metadata'
        '- **Status:** Active'
        '- **Owner:** Repository Maintainers'
        '- **Last Updated:** 2026-08-30'
        '- **Scope:** Endpoint metadata regression.'
        '## Content'
        'Published baseline.'
    ) -join "`n"
    $strEndpointFinal = @(
        '# Endpoint fixture'
        '**Version:** 1.0.20260831.0'
        '## Metadata'
        '- **Status:** Active'
        '- **Owner:** Repository Maintainers'
        '- **Last Updated:** 2026-08-31'
        '- **Scope:** Endpoint metadata regression.'
        '## Content'
        'Corrected published final state.'
    ) -join "`n"
    $strInvalidIntermediate = $strEndpointBaseline.Replace(
        'Published baseline.',
        'Intermediate rendered change without metadata advancement.'
    )
    if ($strInvalidIntermediate -ceq $strEndpointBaseline) {
        throw 'The deterministic intermediate fixture changed zero bytes.'
    }
    $arrPublishedFinalFailures = @(Get-PublishedEndpointMetadataFailure `
        -Name 'endpoint-fixture.md' -CurrentContent $strEndpointFinal `
        -ParentContent $strEndpointBaseline -ExpectedUtcDate '2026-08-31' `
        -IsNewDocumentTransition $false)
    if ($arrPublishedFinalFailures.Count -ne 0) {
        throw ('A corrected multi-commit published final state failed: ' +
            ($arrPublishedFinalFailures -join '; '))
    }
    $strHigherRevisionPublishedFinal = $strEndpointFinal.Replace(
        '**Version:** 1.0.20260831.0', '**Version:** 1.0.20260831.2')
    $arrHigherRevisionPublishedFinalFailures = @(Get-PublishedEndpointMetadataFailure `
        -Name 'endpoint-fixture.md' -CurrentContent $strHigherRevisionPublishedFinal `
        -ParentContent $strEndpointBaseline -ExpectedUtcDate '2026-08-31' `
        -IsNewDocumentTransition $false)
    if ($arrHigherRevisionPublishedFinalFailures -cnotcontains
        ('endpoint-fixture.md Version revision must be exactly 0 when a ' +
            'published-baseline major, minor, or date segment changes.')) {
        throw 'A nonzero revision after a higher-order change did not fail closed.'
    }
    $strSameTupleFinal = $strEndpointBaseline.Replace(
        '**Version:** 1.0.20260830.0', '**Version:** 1.0.20260830.1'
    ).Replace('Published baseline.', 'Published final on the same tuple.')
    if (@(Get-PublishedEndpointMetadataFailure -Name 'endpoint-fixture.md' `
            -CurrentContent $strSameTupleFinal -ParentContent $strEndpointBaseline `
            -ExpectedUtcDate '2026-08-30' -IsNewDocumentTransition $false).Count -ne 0) {
        throw 'An exact published-baseline revision increment did not pass.'
    }
    $strSkippedRevisionFinal = $strSameTupleFinal.Replace(
        '**Version:** 1.0.20260830.1', '**Version:** 1.0.20260830.2')
    if (@(Get-PublishedEndpointMetadataFailure -Name 'endpoint-fixture.md' `
            -CurrentContent $strSkippedRevisionFinal `
            -ParentContent $strEndpointBaseline -ExpectedUtcDate '2026-08-30' `
            -IsNewDocumentTransition $false) -cnotcontains
        ('endpoint-fixture.md Version revision must be exactly 1 after a ' +
            'published change with an unchanged published-baseline major, ' +
            'minor, and date tuple.')) {
        throw 'A skipped same-tuple published final revision did not fail closed.'
    }
    foreach ($strLifecycleStatus in @(
            'Draft', 'Proposed', 'Active', 'Accepted', 'Superseded', 'Deprecated'
        )) {
        $strLifecycleFixture = $strEndpointFinal.Replace(
            '- **Status:** Active', "- **Status:** $strLifecycleStatus")
        if ($null -ne (Get-DocumentMetadataContext `
                -Content $strLifecycleFixture).Failure) {
            throw "A generic Tier 1 lifecycle status was rejected: $strLifecycleStatus"
        }
    }
    if (@(Read-GitPublishedEndpointChangedPath `
            -RepositoryRootPath $strRepositoryRootPath `
            -BaselineRevision $strCheckedOutRevision `
            -FinalRevision $strCheckedOutRevision `
            -MaximumBytes $intGitPathListMaximumBytes).Count -ne 0) {
        throw 'Identical published endpoint trees reported changed paths.'
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
        -AgentsContent $strAgentsSemanticFixture.Replace(
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
            } else {
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
            } else {
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

    $strLinkFence = [string]::new([char]96, 3)
    $strDecisionLinkFixture = @(
        '[Guide](../../STYLE_GUIDE.md)',
        '[Rationale][rationale]',
        '',
        '[rationale]: ../../STYLE_GUIDE_RATIONALE.md',
        '',
        '~~[Deleted](../../STYLE_GUIDE.md)~~',
        '<span>[HTML](../../STYLE_GUIDE.md)</span>',
        '<!-- [Comment](../../STYLE_GUIDE.md) -->',
        $strLinkFence,
        '[Fence](../../STYLE_GUIDE.md)',
        $strLinkFence
    ) -join "`n"
    $objDecisionLinkContext = Get-OperativeMarkdownContext `
        -Content $strDecisionLinkFixture
    $arrDecisionLinkFixtureActual = [string[]]@(
        $objDecisionLinkContext.ProseBlocks.Links
    )
    $arrDecisionLinkFixtureExpected = [string[]]@(
        '../../STYLE_GUIDE.md',
        '../../STYLE_GUIDE_RATIONALE.md'
    )
    if ($arrDecisionLinkFixtureActual.Count -ne 2 -or
        $arrDecisionLinkFixtureActual[0] -cne $arrDecisionLinkFixtureExpected[0] -or
        $arrDecisionLinkFixtureActual[1] -cne $arrDecisionLinkFixtureExpected[1]) {
        throw 'Operative Markdown link parsing accepted hidden or rejected visible links.'
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
    } catch {
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
    } catch {
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
                        } else {
                            'Claude'
                        }) + " marker: $strLiteral"
                if ($objContract.Name -ceq 'AGENTS') {
                    Assert-Failure `
                        -AgentsContent $strMutation `
                        -Failure $strFailure
                } else {
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
                } else {
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
        } else {
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
            } else {
                Assert-Failure `
                    -ClaudeContent $strMutation `
                    -Failure $strFailure
            }
        }
    }

    foreach ($strDocumentName in @('AGENTS.md', 'CLAUDE.md')) {
        $strDocumentContent = if ($strDocumentName -ceq 'AGENTS.md') {
            $strAgentsContent
        } else {
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
            } else {
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
            } else {
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
                } else {
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

    $strConfigNewLine = if ($strCodexConfigContent.Contains("`r`n", [StringComparison]::Ordinal)) {
        "`r`n"
    } else {
        "`n"
    }
    $strMultiAgentStatement = 'multi_agent = true'
    Assert-Failure `
        -CodexConfigContent $strCodexConfigContent.Replace(
            $strMultiAgentStatement,
            'multi_agent = false'
        ) `
        -Failure 'The [features] table must declare multi_agent = true exactly once.'
    Assert-Failure `
        -CodexConfigContent $strCodexConfigContent.Replace(
            $strMultiAgentStatement,
            'multi_agent = "true"'
        ) `
        -Failure 'The [features] table must declare multi_agent = true exactly once.'
    Assert-Failure `
        -CodexConfigContent $strCodexConfigContent.Replace(
            $strMultiAgentStatement,
            '# multi_agent removed'
        ) `
        -Failure 'The [features] table must declare multi_agent = true exactly once.'
    Assert-Failure `
        -CodexConfigContent $strCodexConfigContent.Replace(
            "[features]$strConfigNewLine" + 'goals = true' +
            "$strConfigNewLine$strMultiAgentStatement",
            '[features.multi_agent]' + "$strConfigNewLine" + 'enabled = true'
        ) `
        -Failure 'The [features] table must declare multi_agent = true exactly once.'
    Assert-Failure `
        -CodexConfigContent $strCodexConfigContent.Replace(
            $strMultiAgentStatement,
            'multi_agent ='
        ) `
        -Failure 'The project configuration must contain valid TOML.'

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

    # Keep the root-command oracle independent of the implementation helper.
    $arrRootSetupCommands = @(
        "pwsh -NoProfile -Command 'if (`$PSVersionTable.PSVersion.Major -lt 7) { exit 1 }'"
        'py -3.12 -m pip --isolated install --require-hashes --only-binary=:all: --index-url https://pypi.org/simple -r requirements-dev.txt'
        'python3.12 -m pip --isolated install --require-hashes --only-binary=:all: --index-url https://pypi.org/simple -r requirements-dev.txt'
        'py -3.12 -m pre_commit run --all-files'
        'python3.12 -m pre_commit run --all-files'
    )
    foreach ($objRootDocument in @(
            [pscustomobject]@{ Name = 'AGENTS.md'; Parameter = 'AgentsContent'; Content = $strAgentsContent }
            [pscustomobject]@{ Name = 'CLAUDE.md'; Parameter = 'ClaudeContent'; Content = $strClaudeContent }
        )) {
        foreach ($strCommand in $arrRootSetupCommands) {
            $strSpan = [string][char]96 + $strCommand + [string][char]96
            foreach ($strReplacement in @('', "<!-- $strSpan -->", "~~$strSpan~~", "$strSpan $strSpan")) {
                $strMutation = $objRootDocument.Content.Replace($strSpan, $strReplacement)
                if ($strMutation -ceq $objRootDocument.Content) {
                    throw "Root setup mutation did not change $($objRootDocument.Name): $strCommand"
                }
                $hashtableMutation = @{ Failure = "$($objRootDocument.Name) must contain this setup command exactly once: $strCommand" }
                $hashtableMutation[$objRootDocument.Parameter] = $strMutation
                Assert-Failure @hashtableMutation
            }
        }
        foreach ($arrNearMiss in @(
                ,@('--isolated install', 'install', $arrRootSetupCommands[1])
                ,@('--require-hashes ', '', $arrRootSetupCommands[1])
                ,@('--only-binary=:all: ', '', $arrRootSetupCommands[1])
                ,@('https://pypi.org/simple', 'https://example.invalid/simple', $arrRootSetupCommands[1])
                ,@('-r requirements-dev.txt', '-r other-requirements.txt', $arrRootSetupCommands[1])
                ,@('py -3.12 -m pip', 'py -3.11 -m pip', $arrRootSetupCommands[1])
                ,@('python3.12 -m pip', 'python3.11 -m pip', $arrRootSetupCommands[2])
                ,@('-lt 7', '-lt 6', $arrRootSetupCommands[0])
            )) {
            $strMutation = $objRootDocument.Content.Replace($arrNearMiss[0], $arrNearMiss[1])
            if ($strMutation -ceq $objRootDocument.Content) {
                throw "Root setup near miss did not change $($objRootDocument.Name): $($arrNearMiss[0])"
            }
            $hashtableMutation = @{ Failure = "$($objRootDocument.Name) must contain this setup command exactly once: $($arrNearMiss[2])" }
            $hashtableMutation[$objRootDocument.Parameter] = $strMutation
            Assert-Failure @hashtableMutation
        }
    }

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
        } else {
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
        } else {
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
