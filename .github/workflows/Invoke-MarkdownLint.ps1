#Requires -Version 7.3
# .SYNOPSIS
# Runs both Markdown checks through the completed preferred runtime.
#
# .DESCRIPTION
# Requires completed toolchain handoff and locked workflow dependencies. Checks anonymous credentials, ready.json, the preferred declaration, ordinary executable paths, and empty private npm configuration. Removes ambient Node/npm selectors in this process. Runs outer and nested checks with absolute acquired Node/npm paths. Reports both native statuses, then throws if either fails. Preflight refusals throw before lint dispatch.
#
# .EXAMPLE
# & "$PSScriptRoot/Invoke-MarkdownLint.ps1"
#
# # Internal workflow example: after setup with WorkflowDependencies, emits Markdown exits: outer=0 nested=0 when both checks succeed.
#
# .EXAMPLE
# & "$PSScriptRoot/Invoke-MarkdownLint.ps1"
#
# # With absent or mismatched ready.json, throws before lint dispatch.
#
# .INPUTS
# None. Pipeline input is not supported.
#
# .OUTPUTS
# [string] Markdown exits: outer=<status> nested=<status> after both native checks finish. Nonzero status then throws. Preflight errors throw before this output.
#
# .NOTES
# No positional parameters are supported. Use declared parameter names, if any.
# The workflow must initialize the required host, checkout, and runner environment.
# Version: 1.0.20261008.0
[CmdletBinding(PositionalBinding = $false)]
[OutputType([string])]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
if ([string]::IsNullOrWhiteSpace($env:RUNNER_TEMP)) {
    throw 'The CI lint helper requires runner environment variable RUNNER_TEMP.'
}
function Assert-OrdinaryPath {
    # .SYNOPSIS
    # Returns an ordinary absolute local path.
    #
    # .DESCRIPTION
    # Checks single-line absolute local syntax and Windows aliases, then resolves the FileSystem provider path and requires equality with the normalized native path using the platform case model. Checks the required file or directory type and every ancestor for reparse points. Provider errors, mismatches, and invalid, missing, linked, or uninspectable paths throw without fallback.
    #
    # .PARAMETER Path
    # Absolute local path of an existing file or directory.
    #
    # .PARAMETER Directory
    # Requires a directory. Omit the named switch to require a file.
    #
    # .EXAMPLE
    # $strPath = Assert-OrdinaryPath -Path $env:RUNNER_TEMP -Directory
    #
    # # Returns the ordinary directory when the runner is initialized.
    #
    # .EXAMPLE
    # Assert-OrdinaryPath -Path 'relative/file'
    #
    # # Throws because the path is relative.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # [string] Normalized absolute path after all checks. Failures throw without a path.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API surface.
    # Parameters, return shape, and positional contract may change without notice.
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #   Position 0: Path
    #
    # Directory is a named-only switch.
    #
    # Version: 1.0.20261008.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param([Parameter(Position = 0)][string] $Path, [switch] $Directory)
    if ([string]::IsNullOrWhiteSpace($Path) -or $Path -match '[\r\n]' -or
        -not [IO.Path]::IsPathFullyQualified($Path) -or $Path.StartsWith('\\')) {
        throw 'toolchain: an absolute local single-line path is required'
    }
    $strFullPath = [IO.Path]::GetFullPath($Path)
    if ($IsWindows -and ($strFullPath.Substring(2).Contains(':') -or
        @($strFullPath.Substring(3).Split('\') | Where-Object {
            $_ -match '[. ]$|~'
        }).Count)) {
        throw 'toolchain: path aliases are not supported'
    }
    [Management.Automation.ProviderInfo] $objPathProvider = $null
    [Management.Automation.PSDriveInfo] $objPathDrive = $null
    $strProviderPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
        $strFullPath, [ref]$objPathProvider, [ref]$objPathDrive)
    $objPathComparison = if ($IsWindows) {
        [StringComparison]::OrdinalIgnoreCase
    } else {
        [StringComparison]::Ordinal
    }
    if ($null -eq $objPathProvider -or $objPathProvider.Name -cne 'FileSystem' -or
        -not [string]::Equals($strProviderPath, $strFullPath, $objPathComparison)) {
        throw 'toolchain: the FileSystem provider path must match the normalized native path'
    }
    $objPathItem = Get-Item -LiteralPath $strFullPath -Force -ErrorAction Stop
    if ($objPathItem.PSIsContainer -ne [bool]$Directory) {
        throw "toolchain: wrong path type: $strFullPath"
    }
    for ($objPathComponent = $objPathItem; $null -ne $objPathComponent; $objPathComponent = if ($objPathComponent -is [IO.DirectoryInfo]) {
        $objPathComponent.Parent
    } else {
        $objPathComponent.Directory
    }) {
        if ($objPathComponent.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            throw "toolchain: linked path: $strFullPath"
        }
    }
    return $strFullPath
}
function Assert-JsonMember {
    # .SYNOPSIS
    # Rejects duplicate decoded JSON member names.
    #
    # .DESCRIPTION
    # Recursively checks object and array value kinds with ordinal name comparison. Scalar value kinds require no member check. Throws on duplicate names. The caller must supply a live JsonElement from an undisposed JsonDocument.
    #
    # .PARAMETER Element
    # JsonElement whose object, array, or scalar value kind is inspected.
    #
    # .EXAMPLE
    # $objDocument = [Text.Json.JsonDocument]::Parse('{"field":1}')
    # try {
    #     Assert-JsonMember -Element $objDocument.RootElement
    # } finally {
    #     $objDocument.Dispose()
    # }
    #
    # # Completes for unique member names.
    #
    # .EXAMPLE
    # $objDocument = [Text.Json.JsonDocument]::Parse('{"field":1,"field":2}')
    # try {
    #     Assert-JsonMember -Element $objDocument.RootElement
    # } finally {
    #     $objDocument.Dispose()
    # }
    #
    # # Throws because field occurs twice.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # None. Produces no success output. Duplicate names cause a terminating error.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API surface.
    # Parameters, return shape, and positional contract may change without notice.
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #   Position 0: Element
    #
    # Version: 1.0.20261008.0
    [CmdletBinding()]
    [OutputType([void])]
    param([Text.Json.JsonElement] $Element)
    if ($Element.ValueKind -eq [Text.Json.JsonValueKind]::Object) {
        $objJsonMemberNames = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
        foreach ($objJsonProperty in $Element.EnumerateObject()) {
            if (-not $objJsonMemberNames.Add($objJsonProperty.Name)) {
                throw 'toolchain: duplicate JSON member'
            }
            Assert-JsonMember $objJsonProperty.Value
        }
    } elseif ($Element.ValueKind -eq [Text.Json.JsonValueKind]::Array) {
        foreach ($objJsonValue in $Element.EnumerateArray()) {
            Assert-JsonMember $objJsonValue
        }
    }
}
function Read-BoundedJson {
    # .SYNOPSIS
    # Reads a bounded JSON object with unique member names.
    #
    # .DESCRIPTION
    # Checks an ordinary file and its byte limit. Decodes strict UTF-8, requires an object root, and checks duplicate names before hashtable conversion. Disposes the JsonDocument even on refusal. Path, size, decoding, parsing, member, and conversion errors throw.
    #
    # .PARAMETER Path
    # Absolute path of the existing JSON file.
    #
    # .PARAMETER Limit
    # Maximum file length in bytes. Defaults to 1048576.
    #
    # .EXAMPLE
    # $hashtableDeclaration = Read-BoundedJson -Path $strDeclarationPath -Limit 16384
    #
    # # Reads an existing ordinary declaration within the byte limit. The caller supplies its absolute path.
    #
    # .EXAMPLE
    # Read-BoundedJson -Path $strDeclarationPath -Limit 0
    #
    # # Throws if the existing declaration contains any bytes.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # [hashtable] Converted JSON object with original data keys and values. Failures throw without a converted object.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API surface.
    # Parameters, return shape, and positional contract may change without notice.
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #   Position 0: Path
    #   Position 1: Limit
    #
    # Version: 1.0.20261008.0
    [CmdletBinding()]
    [OutputType([hashtable])]
    param([string] $Path, [long] $Limit = 1048576)
    $null = Assert-OrdinaryPath $Path
    if ((Get-Item -LiteralPath $Path).Length -gt $Limit) {
        throw 'toolchain: JSON input exceeds its limit'
    }
    $strJsonText = [IO.File]::ReadAllText($Path, [Text.UTF8Encoding]::new($false, $true))
    $objJsonDocument = [Text.Json.JsonDocument]::Parse($strJsonText)
    try {
        if ($objJsonDocument.RootElement.ValueKind -ne [Text.Json.JsonValueKind]::Object) {
            throw 'toolchain: JSON input must be an object'
        }
        Assert-JsonMember $objJsonDocument.RootElement
    } finally {
        $objJsonDocument.Dispose()
    }
    return ConvertFrom-Json -InputObject $strJsonText -AsHashtable -Depth 64 -ErrorAction Stop
}
& "$PSScriptRoot/Test-CheckoutCredentials.ps1"
$strRunner = Assert-OrdinaryPath $env:RUNNER_TEMP -Directory
$strNodeRoot = Join-Path $strRunner 'styleguide-node'
$null = Assert-OrdinaryPath $strNodeRoot -Directory
$objPackage = Read-BoundedJson ([IO.Path]::GetFullPath("$PSScriptRoot/../../package.json"))
if ($objPackage.engines.node -isnot [string] -or $objPackage.engines.node -cnotmatch '^24\.[0-9]+\.[0-9]+$') {
    throw 'The preferred runtime declaration is invalid.'
}
$hashtableReadyRuntime = Read-BoundedJson (Join-Path $strNodeRoot 'ready.json') 4096
if ($hashtableReadyRuntime.node -cne $objPackage.engines.node -or $hashtableReadyRuntime.npm -cne $objPackage.engines.npm) {
    throw 'The reviewed runtime handoff does not match package.json.'
}
$strPlatform = if ($IsWindows) {
    'win-x64'
} elseif ($IsLinux) {
    'linux-x64'
} else {
    throw 'Unsupported lint platform.'
}
$strRuntimePath = Join-Path $strNodeRoot "preferred/node-v$($objPackage.engines.node)-$strPlatform"
$strNodePath = Join-Path $strRuntimePath $(if ($IsWindows) {
    'node.exe'
} else {
    'bin/node'
})
$strNpmScriptPath = Join-Path $strRuntimePath $(if ($IsWindows) {
    'node_modules/npm/bin/npm-cli.js'
} else {
    'lib/node_modules/npm/bin/npm-cli.js'
})
$null = Assert-OrdinaryPath $strNodePath
$null = Assert-OrdinaryPath $strNpmScriptPath
# Process-local selector cleanup is mandatory before child execution.
Remove-Item Env:NODE_OPTIONS, Env:NODE_PATH -ErrorAction SilentlyContinue -Confirm:$false -WhatIf:$false
Get-ChildItem Env: | Where-Object {
    $_.Name -imatch '^npm_config_'
} |
ForEach-Object {
    Remove-Item -LiteralPath "Env:$($_.Name)" -Confirm:$false -WhatIf:$false
}
$env:npm_config_userconfig = Join-Path $strNodeRoot 'npm-user.config'
$env:npm_config_globalconfig = Join-Path $strNodeRoot 'npm-global.config'
foreach ($strConfigurationPath in @($env:npm_config_userconfig, $env:npm_config_globalconfig)) {
    $null = Assert-OrdinaryPath $strConfigurationPath
    if ((Get-Item -LiteralPath $strConfigurationPath).Length -ne 0) {
        throw 'The private npm configuration is not empty.'
    }
}
$env:npm_config_registry = 'https://registry.npmjs.org/'
$env:npm_config_ignore_scripts = 'true'
$env:npm_config_audit = 'false'
$env:npm_config_fund = 'false'
$env:CI = 'true'
& $strNodePath $strNpmScriptPath --prefix $PSScriptRoot run lint:md
$intOuterExit = $LASTEXITCODE
& $strNodePath $strNpmScriptPath --prefix $PSScriptRoot run lint:md:nested
$intNestedExit = $LASTEXITCODE
Write-Output "Markdown exits: outer=$intOuterExit nested=$intNestedExit"
if ($intOuterExit -ne 0 -or $intNestedExit -ne 0) {
    throw 'One or more Markdown checks failed.'
}
