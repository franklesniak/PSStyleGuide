#Requires -Version 7.3
# .SYNOPSIS
# Verifies that the anonymous checkout retained no credentials.
#
# .DESCRIPTION
# Requires PowerShell 7.3 or later for the retained helper APIs. Rejects projected tokens and external command configuration. Excludes user/system Git configuration and prompts. Uses resolved Git to require exactly one expected credential-free origin, no local helper or persisted HTTP authorization, and no effective external configuration. Windows requires exactly PowerShell 7.6.5, the reviewed native x64 host, Git version, trusted ACLs, and private empty configuration outside the checkout. Refusals and unexpected native statuses throw. Failed Windows cleanup deletes only proved private configuration or warns and retains uncertain staging. Changes this process Git environment and native error-mapping preference.
#
# .EXAMPLE
# & "$PSScriptRoot/Test-CheckoutCredentials.ps1"
#
# # Internal workflow example: completes without success output for an initialized anonymous checkout. Windows also displays reviewed Git provenance.
#
# .EXAMPLE
# & "$PSScriptRoot/Test-CheckoutCredentials.ps1"
#
# # With a projected GH_TOKEN, throws before Git dispatch. A workflow must omit the token.
#
# .INPUTS
# None. Pipeline input is not supported.
#
# .OUTPUTS
# None. Produces no success output. Refusals and unexpected native statuses throw. Windows provenance uses the information stream; uncertain cleanup can warn.
#
# .NOTES
# No positional parameters are supported. Use declared parameter names, if any.
# The workflow must initialize the required host, checkout, and runner environment.
# Version: 1.0.20261008.0
[CmdletBinding(PositionalBinding = $false)]
[OutputType([void])]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$objStrictUtf8Encoding = [Text.UTF8Encoding]::new($false, $true)

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
        -not [IO.Path]::IsPathFullyQualified($Path) -or $Path.StartsWith('\\') -or
        ($IsWindows -and $Path.Replace('/', '\').StartsWith('\\'))) {
        throw 'toolchain: an absolute local single-line path is required'
    }
    $strFullPath = [IO.Path]::GetFullPath($Path)
    if ($IsWindows -and $strFullPath -cnotmatch '\A[A-Za-z]:\\') {
        throw 'toolchain: an absolute local single-line path is required'
    }
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
function Assert-WindowsWriter {
    # .SYNOPSIS
    # Rejects unreviewed Windows owners and write authority.
    #
    # .DESCRIPTION
    # Requires Windows. Trusts the current user, SYSTEM, Administrators, and TrustedInstaller. Checks the owner and effective allow rules, including inherited rules. Protects file append rights and permits ancestor directory-creation grants. ACL inspection and untrusted mutation grants throw.
    #
    # .PARAMETER Path
    # Absolute path of the existing Windows file or directory.
    #
    # .EXAMPLE
    # Assert-WindowsWriter -Path $strReviewedPath
    #
    # # Completes for a Windows path whose owner and grants satisfy the policy.
    #
    # .EXAMPLE
    # Assert-WindowsWriter -Path $strUntrustedPath
    #
    # # Throws for a Windows path with an untrusted owner or write grant.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # None. Produces no success output. Unreviewed owner or write authority causes a terminating error.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API surface.
    # Parameters, return shape, and positional contract may change without notice.
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #   Position 0: Path
    #
    # Version: 1.0.20261008.0
    [CmdletBinding()]
    [OutputType([void])]
    param([string] $Path)
    $objAccessControl = Get-Acl -LiteralPath $Path
    $arrTrustedSecurityIdentifiers = @([Security.Principal.WindowsIdentity]::GetCurrent().User.Value,
        'S-1-5-18', 'S-1-5-32-544', 'S-1-5-80-956008885-3418522649-1831038044-1853292631-2271478464')
    if ($objAccessControl.GetOwner([Security.Principal.SecurityIdentifier]).Value -cnotin $arrTrustedSecurityIdentifiers) {
        throw "toolchain: unreviewed Windows path owner: $Path"
    }
    $objMutationRights = [Security.AccessControl.FileSystemRights]'WriteData,DeleteSubdirectoriesAndFiles,Delete,ChangePermissions,TakeOwnership'
    # Bit 4 appends to files but only creates subdirectories on directories.
    # Keep legitimate ancestor CreateDirectories grants; protect file contents.
    if (-not (Get-Item -LiteralPath $Path -Force -ErrorAction Stop).PSIsContainer) {
        $objMutationRights = $objMutationRights -bor [Security.AccessControl.FileSystemRights]::AppendData
    }
    foreach ($objAccessRule in $objAccessControl.GetAccessRules($true, $true, [Security.Principal.SecurityIdentifier])) {
        if ($objAccessRule.AccessControlType -eq 'Allow' -and
            -not ($objAccessRule.PropagationFlags -band [Security.AccessControl.PropagationFlags]::InheritOnly) -and
            ($objAccessRule.FileSystemRights -band $objMutationRights) -and $objAccessRule.IdentityReference.Value -cnotin $arrTrustedSecurityIdentifiers) {
            throw "toolchain: unreviewed Windows write authority: $Path"
        }
    }
}
function New-PrivateDirectory {
    # .SYNOPSIS
    # Creates a new restricted runtime directory.
    #
    # .DESCRIPTION
    # Requires an absent absolute destination outside the checkout. Creates a protected Windows DACL for the current user, SYSTEM, and Administrators, or a Linux directory with mode 0700. Verifies permissions and the ordinary path. Throws on existing destinations, creation failure, or failed checks. Requires ShouldProcess approval before any creation or permission change. Declining or inherited WhatIf throws before mutation, so mandatory callers cannot proceed with absent staging.
    #
    # .PARAMETER Path
    # Absolute FileSystem path of the absent private destination.
    #
    # .EXAMPLE
    # New-PrivateDirectory -Path $strNewStagingPath -Confirm:$false -WhatIf:$WhatIfPreference
    #
    # # Creates restricted staging when the internal caller supplies an absent absolute path.
    #
    # .EXAMPLE
    # New-PrivateDirectory -Path $strNewStagingPath -WhatIf -Confirm:$false
    #
    # # Reports the proposed creation and throws before creating the absent path.
    #
    # .INPUTS
    # None. Pipeline input is not supported.
    #
    # .OUTPUTS
    # None. Produces no success output. Creates a directory after ShouldProcess approval or throws. A declined operation cannot publish or continue. A failed post-creation check can leave a directory for caller-owned cleanup.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API surface.
    # Parameters, return shape, and positional contract may change without notice.
    #
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #   Position 0: Path
    #
    # Mandatory production callers disable confirmation prompts and propagate the inherited WhatIf preference explicitly.
    #
    # Version: 1.0.20261008.0
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
    [OutputType([void])]
    param([string] $Path)
    if ($null -ne (Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue)) {
        throw 'The runtime staging destination already exists.'
    }
    if (-not $PSCmdlet.ShouldProcess($Path, 'Create restricted staging directory')) {
        throw 'Restricted staging directory creation was declined.'
    }
    if ($IsWindows) {
        $objAccessControl = [Security.AccessControl.DirectorySecurity]::new()
        $objOwnerSecurityIdentifier = [Security.Principal.WindowsIdentity]::GetCurrent().User
        $objAccessControl.SetOwner($objOwnerSecurityIdentifier)
        $objAccessControl.SetAccessRuleProtection($true, $false)
        foreach ($strSecurityIdentifier in @($objOwnerSecurityIdentifier.Value, 'S-1-5-18', 'S-1-5-32-544')) {
            $objAccessControl.AddAccessRule([Security.AccessControl.FileSystemAccessRule]::new(
                [Security.Principal.SecurityIdentifier]::new($strSecurityIdentifier), 'FullControl',
                'ContainerInherit,ObjectInherit', 'None', 'Allow'))
        }
        [IO.FileSystemAclExtensions]::Create([IO.DirectoryInfo]::new($Path), $objAccessControl)
        Assert-WindowsWriter $Path
        if (-not (Get-Acl -LiteralPath $Path).AreAccessRulesProtected) {
            throw 'toolchain: private DACL was not applied'
        }
    } else {
        [void]([IO.Directory]::CreateDirectory($Path, [IO.UnixFileMode]::UserRead -bor
            [IO.UnixFileMode]::UserWrite -bor [IO.UnixFileMode]::UserExecute))
        if ([int][IO.File]::GetUnixFileMode($Path) -ne 448) {
            throw 'toolchain: private POSIX directory mode was not applied'
        }
    }
    $null = Assert-OrdinaryPath $Path -Directory
}

# Do not load user/system Git credentials or hooks during anonymous acquisition.
if (-not [string]::IsNullOrEmpty($env:GIT_CONFIG_COUNT) -or
    -not [string]::IsNullOrEmpty($env:GIT_CONFIG_PARAMETERS)) {
    throw 'credential-policy: external command configuration is not allowed'
}
$env:GIT_CONFIG_NOSYSTEM = '1'
if (-not $IsWindows) {
    $env:GIT_CONFIG_GLOBAL = '/dev/null'
}
$env:GIT_TERMINAL_PROMPT = '0'
if (-not [string]::IsNullOrEmpty($env:GITHUB_TOKEN) -or
    -not [string]::IsNullOrEmpty($env:GH_TOKEN) -or
    -not [string]::IsNullOrEmpty($env:ACTIONS_RUNTIME_TOKEN)) {
    throw 'credential-policy: a token was projected into a code job'
}
# git config exits 1 when a queried key is absent, which is the secure
# expected state this step asserts. If the runner enables native-command
# error mapping, that accepted status would terminate the step before the
# explicit capture below runs, so it is disabled the same way
# markdownlint.yml disables it.
if (Test-Path Variable:PSNativeCommandUseErrorActionPreference) {
    $PSNativeCommandUseErrorActionPreference = $false
}
# Resolved here too. Constants do not cross step boundaries, and this
# step asserts a credential property, so the executable it asks must
# not be chosen by name resolution either.
$strPrivateGitPath = $null
$objPrivateGitCreationTime = $null
$boolCredentialSuccess = $false
try {
    if ($IsWindows) {
        if ($PSVersionTable.PSVersion.ToString() -cne '7.6.5') {
            throw 'credential-policy: reviewed Windows PowerShell 7.6.5 is required'
        }
        if ([Runtime.InteropServices.RuntimeInformation]::OSArchitecture -ne [Runtime.InteropServices.Architecture]::X64 -or
            [Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture -ne [Runtime.InteropServices.Architecture]::X64) {
            throw 'credential-policy: native Windows x64 is required'
        }
        $strRunnerPath = Assert-OrdinaryPath $env:RUNNER_TEMP -Directory
        $strCheckoutPath = [IO.Path]::GetFullPath("$PSScriptRoot/../..")
        if ($strRunnerPath.Equals($strCheckoutPath, [StringComparison]::OrdinalIgnoreCase) -or
            $strRunnerPath.StartsWith($strCheckoutPath + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
            throw 'credential-policy: private configuration must be outside the checkout'
        }
        for ($objPathComponent = [IO.DirectoryInfo]::new($strRunnerPath); $null -ne $objPathComponent; $objPathComponent = $objPathComponent.Parent) {
            Assert-WindowsWriter $objPathComponent.FullName
        }
        $strResolvedGit = Join-Path ([Environment]::GetFolderPath([Environment+SpecialFolder]::ProgramFiles)) 'Git/cmd/git.exe'
        $null = Assert-OrdinaryPath $strResolvedGit
        for ($objPathComponent = Get-Item -LiteralPath $strResolvedGit; $null -ne $objPathComponent;
            $objPathComponent = if ($objPathComponent -is [IO.DirectoryInfo]) {
                $objPathComponent.Parent
            } else {
                $objPathComponent.Directory
            }) {
            Assert-WindowsWriter $objPathComponent.FullName
        }
        $arrGitVersionOutput = @(& $strResolvedGit --version)
        if ($LASTEXITCODE -ne 0 -or $arrGitVersionOutput.Count -ne 1 -or
            $arrGitVersionOutput[0] -cnotmatch '^git version (2\.[0-9]+\.[0-9]+)\.windows\.[0-9]+$' -or
            [version]$Matches[1] -lt [version]'2.39.0') {
            throw 'credential-policy: supported Git for Windows 2.39+ in major2 is required'
        }
        Write-Information -MessageData "Git $($arrGitVersionOutput[0]) at $strResolvedGit SHA256 $((Get-FileHash -LiteralPath $strResolvedGit -Algorithm SHA256).Hash)." -InformationAction Continue
        $strPrivateGitPath = Join-Path $strRunnerPath ('styleguide-git-' + [Guid]::NewGuid().ToString('N'))
        New-PrivateDirectory $strPrivateGitPath -Confirm:$false -WhatIf:$WhatIfPreference
        $objPrivateGitCreationTime = (Get-Item -LiteralPath $strPrivateGitPath).CreationTimeUtc
        $env:GIT_CONFIG_GLOBAL = Join-Path $strPrivateGitPath 'global.config'
        [IO.File]::WriteAllText($env:GIT_CONFIG_GLOBAL, '', $objStrictUtf8Encoding)
        $null = Assert-OrdinaryPath $env:GIT_CONFIG_GLOBAL
        Assert-WindowsWriter $env:GIT_CONFIG_GLOBAL
    } else {
        $strResolvedGit = @('/usr/bin/git', '/bin/git') | Where-Object {
            [System.IO.File]::Exists($_)
        } | Select-Object -First 1
    }
    if ([string]::IsNullOrEmpty($strResolvedGit)) {
        throw 'credential-policy: Git was not resolved as an application'
    }
    New-Variable -Name strGitPath -Value $strResolvedGit -Option Constant -WhatIf:$false -Confirm:$false
    $arrRemoteUrls = @(& $strGitPath remote get-url --all origin)
    if ($LASTEXITCODE -ne 0 -or $arrRemoteUrls.Count -ne 1) {
        throw 'credential-policy: unable to resolve exactly one origin URL'
    }
    if ($arrRemoteUrls[0] -cne 'https://github.com/franklesniak/PSStyleGuide') {
        throw 'credential-policy: origin is not a credential-free GitHub HTTPS URL'
    }
    $arrHelpers = @(& $strGitPath config --local --get-all credential.helper)
    $intHelperExit = $LASTEXITCODE
    $global:LASTEXITCODE = 0
    if (($intHelperExit -ne 0 -and $intHelperExit -ne 1) -or $arrHelpers.Count -ne 0) {
        throw 'credential-policy: a local credential helper is configured'
    }
    $arrAuthorizationKeys = @(& $strGitPath config --local --name-only --get-regexp '^http\..*\.extraheader$')
    $intAuthorizationExit = $LASTEXITCODE
    $global:LASTEXITCODE = 0
    if (($intAuthorizationExit -ne 0 -and $intAuthorizationExit -ne 1) -or $arrAuthorizationKeys.Count -ne 0) {
        throw 'credential-policy: persisted HTTP authorization is configured'
    }

    $arrEffectiveConfig = @(& $strGitPath config --show-scope --name-only --list)
    $intEffectiveConfigExit = $LASTEXITCODE
    if ($intEffectiveConfigExit -ne 0 -or @($arrEffectiveConfig | Where-Object {
        $_ -cmatch '^(system|global)\s'
    }).Count -ne 0) {
        throw 'credential-policy: external Git configuration was not excluded'
    }
    $boolCredentialSuccess = $true
} finally {
    if ($IsWindows -and -not $boolCredentialSuccess -and $null -ne $objPrivateGitCreationTime) {
        try {
            $null = Assert-OrdinaryPath $strPrivateGitPath -Directory
            $strConfigurationPath = Join-Path $strPrivateGitPath 'global.config'
            $null = Assert-OrdinaryPath $strConfigurationPath
            if ((Get-Item -LiteralPath $strPrivateGitPath).CreationTimeUtc -ne $objPrivateGitCreationTime -or
                (Get-Item -LiteralPath $strConfigurationPath).Length -ne 0 -or
                @(Get-ChildItem -LiteralPath $strPrivateGitPath -Force).Count -ne 1) {
                throw 'private configuration ownership changed'
            }
            [IO.File]::Delete($strConfigurationPath)
            [IO.Directory]::Delete($strPrivateGitPath, $false)
        } catch {
            Write-Warning "Credential-check cleanup is uncertain; retained $strPrivateGitPath."
        }
    }
}
