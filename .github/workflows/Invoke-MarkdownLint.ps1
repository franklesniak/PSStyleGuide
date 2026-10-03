#Requires -Version 7.0
# .SYNOPSIS
# Runs both repository Markdown checks and preserves each native failure.
[CmdletBinding(PositionalBinding = $false)]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
if ([string]::IsNullOrWhiteSpace($env:RUNNER_TEMP)) {
    throw 'The CI lint helper requires runner environment variable RUNNER_TEMP.'
}
& "$PSScriptRoot/Test-CheckoutCredentials.ps1"
$strNpm = Join-Path $env:RUNNER_TEMP 'styleguide-node/bin/npm'
if (-not [IO.File]::Exists($strNpm)) { throw 'The reviewed npm executable is absent.' }
# Each workflow step has a new process; installer environment cleanup cannot carry over.
Get-ChildItem Env: | Where-Object { $_.Name -imatch '^npm_config_' } |
    ForEach-Object { Remove-Item -LiteralPath "Env:$($_.Name)" }
$env:npm_config_userconfig = '/dev/null'
$env:npm_config_globalconfig = '/etc/npmrc-absent-by-policy'
$env:npm_config_ignore_scripts = 'true'
$env:npm_config_audit = 'false'
$env:npm_config_fund = 'false'
$env:CI = 'true'
if (Test-Path -LiteralPath $env:npm_config_globalconfig) {
    throw 'The empty global npm configuration path exists.'
}
& $strNpm --prefix $PSScriptRoot run lint:md
$intOuterExit = $LASTEXITCODE
& $strNpm --prefix $PSScriptRoot run lint:md:nested
$intNestedExit = $LASTEXITCODE
Write-Output "Markdown exits: outer=$intOuterExit nested=$intNestedExit"
if ($intOuterExit -ne 0 -or $intNestedExit -ne 0) {
    throw 'One or more Markdown checks failed.'
}
