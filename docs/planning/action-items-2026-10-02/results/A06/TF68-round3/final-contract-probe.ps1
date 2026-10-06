param([Parameter(Mandatory)][string]$Directory, [Parameter(Mandatory)][string]$SourcePath)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$binding = Get-Content -LiteralPath ([IO.Path]::Combine($Directory, 'implementation-input.json')) -Raw | ConvertFrom-Json
if ((Get-FileHash -LiteralPath $SourcePath -Algorithm SHA256).Hash.ToLowerInvariant() -cne $binding.source_after_sha256) { throw 'Final input hash mismatch' }
Import-Module PSScriptAnalyzer -RequiredVersion 1.24.0
$tokens = $null
$errors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile($SourcePath, [ref]$tokens, [ref]$errors)
$parseErrors = @($errors | ForEach-Object { $_.Message })
$issues = @(Invoke-ScriptAnalyzer -Path $SourcePath -Severity Warning,Error | Select-Object RuleName,Severity,Message)
if ($parseErrors.Count -or $issues.Count) { throw 'Final full-file parser/analyzer failed' }
$functions = @($ast.EndBlock.Statements | Where-Object { $_ -is [Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -ceq 'ConvertFrom-NulPathRecordStream' })
if ($functions.Count -ne 1) { throw 'Final function count mismatch' }
. ([scriptblock]::Create($functions[0].Extent.Text))
$metadata = @((Get-Command ConvertFrom-NulPathRecordStream).OutputType.Name)
if ($metadata.Count -ne 1 -or $metadata[0] -cne 'System.Byte[]') { throw 'Precise output metadata contract failed' }
$cases = @(
    @{ Name = 'empty'; Bytes = [byte[]]::new(0); Expected = @() }
    @{ Name = 'one'; Bytes = [byte[]]@(97,0); Expected = @('61') }
    @{ Name = 'multiple'; Bytes = [byte[]]@(97,0,98,99,0); Expected = @('61','6263') }
    @{ Name = 'newline-and-non-ascii'; Bytes = [byte[]]@(97,10,195,169,255,0); Expected = @('610AC3A9FF') }
)
$success = @()
foreach ($case in $cases) {
    $values = @(ConvertFrom-NulPathRecordStream -PathRecordBytes $case.Bytes)
    if ($values.Count -ne $case.Expected.Count) { throw ('Record count mismatch: ' + $case.Name) }
    $actual = @()
    for ($index = 0; $index -lt $values.Count; $index++) {
        if ($values[$index].GetType() -ne [byte[]]) { throw ('Record object type mismatch: ' + $case.Name) }
        $hex = [Convert]::ToHexString($values[$index])
        if ($hex -cne $case.Expected[$index]) { throw ('Raw record mismatch: ' + $case.Name) }
        $actual += @{ type = $values[$index].GetType().FullName; hex = $hex }
    }
    $success += @{ name = $case.Name; count = $values.Count; records = $actual }
}
$failures = @()
foreach ($case in @(
    @{ Name = 'missing-final-NUL-after-valid-prefix'; Bytes = [byte[]]@(97,0,98); Message = 'git-paths: missing final NUL' }
    @{ Name = 'empty-first-record'; Bytes = [byte[]]@(0); Message = 'git-paths: empty or duplicate record' }
    @{ Name = 'empty-after-valid-prefix'; Bytes = [byte[]]@(97,0,0); Message = 'git-paths: empty or duplicate record' }
)) {
    $captured = [Collections.Generic.List[object]]::new()
    $message = $null
    try { ConvertFrom-NulPathRecordStream -PathRecordBytes $case.Bytes | ForEach-Object { $captured.Add($_) } } catch { $message = $_.Exception.Message }
    if ($message -cne $case.Message -or $captured.Count -ne 0) { throw ('Malformed input emitted output or wrong error: ' + $case.Name) }
    $failures += @{ name = $case.Name; message = $message; emitted_count = $captured.Count }
}
$originalPath = [IO.Path]::Combine($Directory, 'Test-StyleGuideArtifacts.ps1')
if ((Get-FileHash -LiteralPath $originalPath -Algorithm SHA256).Hash.ToLowerInvariant() -cne $binding.source_before_sha256) { throw 'Original control hash mismatch' }
$oldAst = [Management.Automation.Language.Parser]::ParseFile($originalPath, [ref]$tokens, [ref]$errors)
$original = @($oldAst.EndBlock.Statements | Where-Object { $_ -is [Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -ceq 'ConvertFrom-NulPathRecordStream' })
if ($original.Count -ne 1 -or @($errors).Count) { throw 'Original control extraction failed' }
. ([scriptblock]::Create($original[0].Extent.Text))
$oldMetadata = @((Get-Command ConvertFrom-NulPathRecordStream).OutputType.Name)
$negativeRejected = $oldMetadata.Count -ne 1 -or $oldMetadata[0] -cne 'System.Byte[]'
if (-not $negativeRejected) { throw 'Original metadata negative control unexpectedly passed' }
if ((Get-FileHash -LiteralPath $SourcePath -Algorithm SHA256).Hash.ToLowerInvariant() -cne $binding.source_after_sha256) { throw 'Final source changed during probe' }
$record = @{ source_sha256 = $binding.source_after_sha256; original_sha256 = $binding.source_before_sha256; powershell = $PSVersionTable.PSVersion.ToString(); analyzer = '1.24.0'; parse_errors = $parseErrors; analyzer_issues = $issues; output_metadata = $metadata; valid_cases = $success; malformed_cases = $failures; original_control = @{ metadata = $oldMetadata; rejected_by_precise_contract = $negativeRejected }; source_after_equal = $true }
$record | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath ([IO.Path]::Combine($Directory, 'final-contract-result.json')) -Encoding utf8
Write-Output 'Final file parser/analyzer and all byte-record contracts passed; original broad-metadata negative control rejected.'
