#Requires -Version 7.0
# .SYNOPSIS
# Verifies that the anonymous checkout retained no credentials.
[CmdletBinding(PositionalBinding = $false)]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Do not load user/system Git credentials or hooks during anonymous acquisition.
if (-not [string]::IsNullOrEmpty($env:GIT_CONFIG_COUNT) -or
    -not [string]::IsNullOrEmpty($env:GIT_CONFIG_PARAMETERS)) {
    throw 'credential-policy: external command configuration is not allowed'
}
$env:GIT_CONFIG_NOSYSTEM = '1'
$env:GIT_CONFIG_GLOBAL = '/dev/null'
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
$strResolvedGit = @('/usr/bin/git', '/bin/git') | Where-Object { [System.IO.File]::Exists($_) } | Select-Object -First 1
if ([string]::IsNullOrEmpty($strResolvedGit)) { throw 'credential-policy: Git was not resolved as an application' }
New-Variable -Name strGitPath -Value $strResolvedGit -Option Constant
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
if ($intEffectiveConfigExit -ne 0 -or @($arrEffectiveConfig | Where-Object { $_ -cmatch '^(system|global)\s' }).Count -ne 0) {
    throw 'credential-policy: external Git configuration was not excluded'
}
