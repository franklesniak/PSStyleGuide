param([Parameter(Mandatory)][string]$Source,[Parameter(Mandatory)][string]$CheckerTemplate,[Parameter(Mandatory)][string]$OutputDirectory)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$OutputDirectory=[IO.Path]::GetFullPath($OutputDirectory)
[void][IO.Directory]::CreateDirectory($OutputDirectory)
$tokens=$null;$errors=$null
$ast=[Management.Automation.Language.Parser]::ParseFile($Source,[ref]$tokens,[ref]$errors)
if(@($errors).Count){throw 'Source parse error'}
$helper=@($ast.EndBlock.Statements|Where-Object {$_ -is [Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -ceq 'Invoke-AgentInstructionFixtureClock'})
$body=$helper[0].Body.Extent.Text
$needle='Set-PSBreakpoint -Script $CheckerPath -Line '
if(($body.Split($needle).Length-1) -ne 2){throw 'Expected two current breakpoint registrations'}
$variants=@{
 Original=$body
 Escaped=$body.Replace('Set-PSBreakpoint -Script $CheckerPath','Set-PSBreakpoint -Script ([Management.Automation.WildcardPattern]::Escape($CheckerPath))')
 LiteralApi=$body.Replace('Set-PSBreakpoint -Script $CheckerPath -Line $arrLines[0] -Action $scriptblockInitialize','[Management.Automation.Runspaces.Runspace]::DefaultRunspace.Debugger.SetLineBreakpoint($CheckerPath, $arrLines[0], 0, $scriptblockInitialize)').Replace('Set-PSBreakpoint -Script $CheckerPath -Line $arrLines[1] -Action $scriptblockLocal','[Management.Automation.Runspaces.Runspace]::DefaultRunspace.Debugger.SetLineBreakpoint($CheckerPath, $arrLines[1], 0, $scriptblockLocal)')
}
$content=[IO.File]::ReadAllText($CheckerTemplate)
$names=@('plain','bracket[ab]',"literal``tick[ab]","backtick``only","quote ' unicode-é")
if(-not $IsWindows){$names+=@('star*literal','question?literal')}
$paths=@{}
foreach($name in @($names)+@('bracketa','bracketb',"literal``ticka", "literal``tickb",'backtickonly','starXliteral','questionXliteral')){
 $directory=[IO.Path]::Combine($OutputDirectory,$name)
 [void][IO.Directory]::CreateDirectory($directory)
 $file=[IO.Path]::Combine($directory,'checker.ps1')
 [IO.File]::WriteAllText($file,$content,[Text.UTF8Encoding]::new($false));$paths[$name]=$file
}
$rows=@()
foreach($variant in @('Original','Escaped','LiteralApi')){
 $functionAst=[Management.Automation.Language.Parser]::ParseInput(('function Invoke-AgentInstructionFixtureClock '+$variants[$variant]),[ref]$tokens,[ref]$errors)
 Set-Item Function:Invoke-AgentInstructionFixtureClock -Value $functionAst.EndBlock.Statements[0].Body.GetScriptBlock()
 foreach($name in $names){
  $checker=$paths[$name];$failure=$null;$script:registered=@();$out=$null
  try{
   $out=Invoke-AgentInstructionFixtureClock -CheckerPath $checker -UtcNow ([DateTimeOffset]::Parse('2000-01-02T23:59:59Z')) -RequireLocal -Action {
    $script:registered=@(Get-PSBreakpoint | Select-Object Script,Line)
    & $checker
   }
  }catch{$failure=$_.Exception.Message}
  $data=if($null -ne $out){($out|Out-String)|ConvertFrom-Json}else{$null}
  $success=$null -eq $failure -and $data.Captured -ceq '2000-01-02' -and $data.Local -ceq '2000-01-02'
  $rows+=@{variant=$variant;mode='initialization-and-local';path_kind=$name;checker=$checker;success=$success;failure=$failure;registered=$script:registered;remaining_breakpoints=@(Get-PSBreakpoint).Count;remaining_clock_variables=@(Get-Variable -Name 'hashtableFixtureClock*' -Scope Global).Count}
  if(@(Get-PSBreakpoint).Count -or @(Get-Variable -Name 'hashtableFixtureClock*' -Scope Global).Count){throw 'Probe leaked debugger state'}
  $null=. $checker
  $failure=$null;$script:registered=@();$out=$null
  try{
   $out=Invoke-AgentInstructionFixtureClock -CheckerPath $checker -UtcNow ([DateTimeOffset]::Parse('2000-01-02T23:59:59Z')) -LocalOnly -RequireLocal -Action {
    $script:registered=@(Get-PSBreakpoint | Select-Object Script,Line)
    Read-FixtureClock -intDiffExitCode 1
   }
  }catch{$failure=$_.Exception.Message}
  $success=$null -eq $failure -and $out -ceq '2000-01-02' -and $script:strMaximumMetadataUtcDate -cne '2000-01-02'
  $rows+=@{variant=$variant;mode='local-only';path_kind=$name;checker=$checker;success=$success;failure=$failure;registered=$script:registered;remaining_breakpoints=@(Get-PSBreakpoint).Count;remaining_clock_variables=@(Get-Variable -Name 'hashtableFixtureClock*' -Scope Global).Count}
  if(@(Get-PSBreakpoint).Count -or @(Get-Variable -Name 'hashtableFixtureClock*' -Scope Global).Count){throw 'Local-only probe leaked debugger state'}
 }
}
$api=@([Management.Automation.Debugger].GetMethods()|Where-Object{$_.Name -ceq 'SetLineBreakpoint'}|ForEach-Object{$_.ToString()})
$configuredTemp=[IO.Path]::Combine($OutputDirectory,'configured-temp[ab]');[void][IO.Directory]::CreateDirectory($configuredTemp)
$si=[Diagnostics.ProcessStartInfo]::new((Get-Process -Id $PID).Path);$si.UseShellExecute=$false;$si.CreateNoWindow=$true;$si.RedirectStandardOutput=$true;$si.RedirectStandardError=$true
foreach($key in @('TMP','TEMP','TMPDIR')){$si.Environment[$key]=$configuredTemp}
foreach($arg in @('-NoLogo','-NoProfile','-NonInteractive','-Command','[IO.Path]::GetFullPath([IO.Path]::GetTempPath())')){$si.ArgumentList.Add($arg)}
$proc=[Diagnostics.Process]::Start($si);$tempOutput=$proc.StandardOutput.ReadToEnd();$tempError=$proc.StandardError.ReadToEnd();if(-not $proc.WaitForExit(10000)){throw 'Private temp-path probe timeout'}
if($proc.ExitCode -ne 0 -or -not $tempOutput.Trim().TrimEnd([IO.Path]::DirectorySeparatorChar).Equals($configuredTemp,[StringComparison]::Ordinal)){throw ('Private temp-path contract failed: '+$tempOutput+$tempError)}
[pscustomobject]@{powershell=$PSVersionTable.PSVersion.ToString();platform=[Environment]::OSVersion.ToString();source_sha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $Source).Hash.ToLowerInvariant();variants='Exact helper body with only two registration expressions changed in memory; no source rewrite';api_overloads=$api;configured_temp_path=$tempOutput.Trim();configured_temp_native_exit=$proc.ExitCode;rows=$rows}|ConvertTo-Json -Depth 12|Set-Content -LiteralPath ([IO.Path]::Combine($OutputDirectory,'probe-result.json')) -Encoding utf8
