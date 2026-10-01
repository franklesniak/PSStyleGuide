#Requires -Version 7.3
# .SYNOPSIS
# Installs the reviewed Linux runtime and the requested locked dependency trees.
# .DESCRIPTION
# CI must acquire the correct source before it invokes this helper. Instruction
# validation uses the accepted base. Candidate jobs have no publication authority.
# npm configuration is set before the first npm command; install scripts stay off.
[CmdletBinding(PositionalBinding = $false)]
param(
    [Parameter()][switch] $WorkflowDependencies,
    [Parameter()][switch] $InstructionDependencies
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
if (-not $IsLinux) { throw 'The CI runtime installer requires Linux.' }
foreach ($strRequiredVariable in @('RUNNER_TEMP', 'GITHUB_PATH', 'GITHUB_ENV')) {
    if ([string]::IsNullOrWhiteSpace([Environment]::GetEnvironmentVariable($strRequiredVariable))) {
        throw "CI setup requires the runner environment variable $strRequiredVariable."
    }
}
& "$PSScriptRoot/Test-CheckoutCredentials.ps1"
$strRepositoryRoot = [IO.Path]::GetFullPath("$PSScriptRoot/../..")
foreach ($strRelativePath in @('.npmrc', '.github/.npmrc', '.github/workflows/.npmrc',
        'npm-shrinkwrap.json', '.github/workflows/npm-shrinkwrap.json')) {
    if (Test-Path -LiteralPath (Join-Path $strRepositoryRoot $strRelativePath)) {
        throw "Unreviewed npm configuration selector: $strRelativePath"
    }
}
# Remove inherited npm options before version checks or installation.
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
$objPin = Get-Content -Raw -LiteralPath "$PSScriptRoot/ci-toolchain.json" |
    ConvertFrom-Json -ErrorAction Stop
# Package engines are the single version source; the CI file supplies archive identity.
$objPackage = Get-Content -Raw -LiteralPath "$strRepositoryRoot/package.json" |
    ConvertFrom-Json -ErrorAction Stop
if ($objPackage.engines.node -cnotmatch '^24\.[0-9]+\.[0-9]+$' -or
    $objPackage.engines.npm -cnotmatch '^[0-9]+\.[0-9]+\.[0-9]+$' -or
    $objPin.linuxX64Sha256 -cnotmatch '^[a-f0-9]{64}$') {
    throw 'The reviewed runtime declaration is invalid.'
}
$strNodeRoot = Join-Path $env:RUNNER_TEMP 'styleguide-node'
$strArchive = Join-Path $env:RUNNER_TEMP 'styleguide-node.tar.xz'
if ([IO.Path]::Exists($strNodeRoot) -or [IO.Path]::Exists($strArchive)) {
    throw 'The runtime staging destination already exists.'
}
$strUrl = "https://nodejs.org/dist/v$($objPackage.engines.node)/node-v$($objPackage.engines.node)-linux-x64.tar.xz"
& /usr/bin/curl --silent --show-error --fail --location --proto '=https' `
    --proto-redir '=https' --tlsv1.2 --connect-timeout 20 --max-time 180 `
    --retry 2 --output $strArchive $strUrl
if ($LASTEXITCODE -ne 0) { throw "Runtime download failed: $LASTEXITCODE" }
if ((Get-FileHash -LiteralPath $strArchive -Algorithm SHA256).Hash.ToLowerInvariant() -cne
    $objPin.linuxX64Sha256) { throw "The runtime archive digest is incorrect for $strUrl. Check package.json engines.node and .github/workflows/ci-toolchain.json linuxX64Sha256. Verify the official release checksum before changing the declaration." }
[void][IO.Directory]::CreateDirectory($strNodeRoot)
& /usr/bin/tar -xJf $strArchive -C $strNodeRoot --strip-components=1
if ($LASTEXITCODE -ne 0) { throw "Runtime extraction failed: $LASTEXITCODE" }
$strNode = Join-Path $strNodeRoot 'bin/node'
$strNpm = Join-Path $strNodeRoot 'bin/npm'
$env:PATH = (Join-Path $strNodeRoot 'bin') + ':' + $env:PATH
$strNodeVersion = & $strNode --version
if ($LASTEXITCODE -ne 0 -or $strNodeVersion -cne "v$($objPackage.engines.node)") {
    throw 'The installed Node version is incorrect.'
}
$strNpmVersion = & $strNpm --version
if ($LASTEXITCODE -ne 0 -or $strNpmVersion -cne $objPackage.engines.npm) {
    throw 'The installed npm version is incorrect.'
}
& $strNode --permission "--allow-fs-read=$strRepositoryRoot" "$PSScriptRoot/Validate-WorkflowPolicy.mjs" --preflight
if ($LASTEXITCODE -ne 0) { throw 'Package and workflow preflight failed before installation.' }
$arrInstallRoots = @()
if ($InstructionDependencies) { $arrInstallRoots += $strRepositoryRoot }
if ($WorkflowDependencies) { $arrInstallRoots += $PSScriptRoot }
foreach ($strInstallRoot in $arrInstallRoots) {
    $arrManifestPaths = @('package.json', 'package-lock.json') |
        ForEach-Object { Join-Path $strInstallRoot $_ }
    $arrBefore = @($arrManifestPaths | ForEach-Object { (Get-FileHash -LiteralPath $_ -Algorithm SHA256).Hash })
    & $strNpm --prefix $strInstallRoot ci --ignore-scripts --no-audit --fund=false --include=dev --package-lock=true
    if ($LASTEXITCODE -ne 0) { throw "Locked installation failed: $LASTEXITCODE" }
    $arrAfter = @($arrManifestPaths | ForEach-Object { (Get-FileHash -LiteralPath $_ -Algorithm SHA256).Hash })
    if (($arrBefore -join ',') -cne ($arrAfter -join ',')) {
        throw 'Locked installation changed a package manifest or lockfile.'
    }
}
# Preserve the same safe npm inputs in later steps, including the lint process.
[IO.File]::AppendAllText($env:GITHUB_PATH, (Join-Path $strNodeRoot 'bin') + "`n")
[IO.File]::AppendAllText($env:GITHUB_ENV, @'
npm_config_userconfig=/dev/null
npm_config_globalconfig=/etc/npmrc-absent-by-policy
npm_config_ignore_scripts=true
npm_config_audit=false
npm_config_fund=false
CI=true
'@ + "`n")
Write-Output "Installed Node $strNodeVersion and npm $strNpmVersion from the reviewed runtime declaration."
