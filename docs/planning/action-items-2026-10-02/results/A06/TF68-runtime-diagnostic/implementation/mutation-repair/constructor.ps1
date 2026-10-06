param([Parameter(Mandatory)][string]$SourceRoot,[Parameter(Mandatory)][string]$OutputDirectory)
$ErrorActionPreference='Stop'
$self=Join-Path $SourceRoot '.github/workflows/Test-AgentInstructions.SelfTest.ps1'
$main=Join-Path $SourceRoot '.github/workflows/Test-AgentInstructions.ps1'
$before=@((Get-FileHash $self).Hash,(Get-FileHash $main).Hash)
$tokens=$null;$errors=$null
$ast=[Management.Automation.Language.Parser]::ParseFile($self,[ref]$tokens,[ref]$errors)
if($errors.Count){throw 'Final SelfTest parse failed'}
foreach($name in @('Get-AgentFinalizationDateMutant','Assert-AgentFinalizationDateMutationSelfTest')){
 $fn=@($ast.EndBlock.Statements|Where-Object {$_ -is [Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -ceq $name})
 if($fn.Count -ne 1){throw 'Constructor function identity drift'}
 Set-Item ('Function:'+ $name) -Value $fn[0].Body.GetScriptBlock()
}
Assert-AgentFinalizationDateMutationSelfTest
$source=[IO.File]::ReadAllText($main)
$old=$source.Replace('$objDocumentContext.RequireFinalizationDate))','$false))')
if($old -cne $source){throw 'Original no-op negative control no longer matches this input'}
$rows=@()
foreach($case in @(@{Name='require-date';Value='$false'},@{Name='initial-coverage';Value='($objDocumentContext.RequireFinalizationDate -or $objDocumentContext.IsInitialMetadataCoverage)'})){
 $mutant=Get-AgentFinalizationDateMutant -Content $source -Replacement $case.Value
 $sourceAst=[Management.Automation.Language.Parser]::ParseInput($source,[ref]$tokens,[ref]$errors)
 $members=@($sourceAst.FindAll({param($n) $n -is [Management.Automation.Language.MemberExpressionAst] -and $n.Extent.Text -ceq '$objDocumentContext.RequireFinalizationDate'},$true))
 if($members.Count -ne 2){throw 'Actual two-member independent replacement oracle drift'}
 $expected=$source
 foreach($member in @($members|Sort-Object {$_.Extent.StartOffset} -Descending)){
  $expected=$expected.Remove($member.Extent.StartOffset,$member.Extent.EndOffset-$member.Extent.StartOffset).Insert($member.Extent.StartOffset,$case.Value)
 }
 if($mutant -ceq $source -or $mutant -cne $expected){throw 'Actual construction changed bytes beyond the two parsed argument extents'}
 $file=Join-Path $OutputDirectory ($case.Name+'-mutant.ps1')
 [IO.File]::WriteAllText($file,$mutant,[Text.UTF8Encoding]::new($false))
 $rows+=@{name=$case.Name;sha256=(Get-FileHash $file).Hash.ToLowerInvariant();changed_arguments=2;only_expected_spans_changed=$true}
}
$after=@((Get-FileHash $self).Hash,(Get-FileHash $main).Hash)
if(($before -join ',') -cne ($after -join ',')){throw 'Source changed during constructor proof'}
@{state='passed';native_exit=0;pwsh=$PSVersionTable.PSVersion.ToString();selftest_sha256=$after[0].ToLowerInvariant();main_sha256=$after[1].ToLowerInvariant();persistent_constructor_controls_passed=$true;old_textual_mutation_is_noop=$true;actual_mutants=$rows;source_equal=$true;actual_fixture_executed=$false}|ConvertTo-Json -Depth 6|Set-Content (Join-Path $OutputDirectory 'constructor-result.json') -Encoding utf8NoBOM
'Constructor correctness, refusal and resilience checks passed.'
