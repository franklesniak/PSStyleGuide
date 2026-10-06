param([Parameter(Mandatory)][string]$Source,[Parameter(Mandatory)][string]$OutputDirectory)
$ErrorActionPreference='Stop'
Set-StrictMode -Version Latest
$OutputDirectory=[IO.Path]::GetFullPath($OutputDirectory)
$tokens=$null;$errors=$null
$ast=[Management.Automation.Language.Parser]::ParseFile($Source,[ref]$tokens,[ref]$errors)
if(@($errors).Count){throw 'Immutable source parse failed'}
$helper=@($ast.EndBlock.Statements|Where-Object {$_ -is [Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -ceq 'Invoke-AgentInstructionFixtureClock'})
if($helper.Count -ne 1){throw 'Helper identity mismatch'}
Set-Item -Path Function:Invoke-AgentInstructionFixtureClock -Value $helper[0].Body.GetScriptBlock()
$caller=@($ast.FindAll({param($n) $n -is [Management.Automation.Language.AssignmentStatementAst] -and $n.Left.Extent.Text -ceq '$scriptblockInvokeCheck'},$true))
if($caller.Count -ne 1){throw 'Caller identity mismatch'}
$block=$caller[0].Right.Find({param($n) $n -is [Management.Automation.Language.ScriptBlockExpressionAst]},$true).ScriptBlock.GetScriptBlock()
$strHostPath=(Get-Process -Id $PID).Path
$helperText=${function:Invoke-AgentInstructionFixtureClock}.ToString()
$probe=@'
[CmdletBinding()]
param([string]$InputRevision,[string]$PublishedBaselineRevision,[switch]$FinalizeMetadataNow,[switch]$ProposedPolicy,[switch]$SelfTest,[switch]$MetadataClassificationOnly)
$script:objValidationUtcNow = [DateTimeOffset]::UtcNow
$script:strMaximumMetadataUtcDate = $script:objValidationUtcNow.ToString('yyyy-MM-dd')
$script:objMaximumCommitUtcTimestamp = $script:objValidationUtcNow.AddMinutes(5)
function Read-FixtureClock {
    param([int] $intDiffExitCode)
    $strExpectedUtcDate = if ($intDiffExitCode -eq 1) {
        [DateTimeOffset]::UtcNow.ToString('yyyy-MM-dd')
    } else {
        ''
    }
    $strExpectedUtcDate
}
$local=Read-FixtureClock -intDiffExitCode 1
$argv=[Environment]::GetCommandLineArgs()
[pscustomobject]@{Captured=$script:strMaximumMetadataUtcDate;Local=$local;InputRevision=$InputRevision;PublishedBaselineRevision=$PublishedBaselineRevision;FinalizeMetadataNow=$FinalizeMetadataNow.IsPresent;ProposedPolicy=$ProposedPolicy.IsPresent;SelfTest=$SelfTest.IsPresent;MetadataClassificationOnly=$MetadataClassificationOnly.IsPresent;CommandLineCharacters=[Environment]::CommandLine.Length;CommandPayloadCharacters=$argv[-1].Length;CommandPayloadUtf8Bytes=[Text.Encoding]::UTF8.GetByteCount($argv[-1]);ArgvUtf8BytesWithNuls=($argv|ForEach-Object{[Text.Encoding]::UTF8.GetByteCount($_)+1}|Measure-Object -Sum).Sum} | ConvertTo-Json -Compress
'@
$root=[IO.Path]::Combine($OutputDirectory,"path with apostrophe ' dollar `$ backtick `` semi; brackets unicode-é")
[void][IO.Directory]::CreateDirectory($root)
$checker=[IO.Path]::Combine($root,'checker.ps1');[IO.File]::WriteAllText($checker,$probe,[Text.UTF8Encoding]::new($false))
$clock=[DateTimeOffset]::Parse('2000-01-02T23:59:59Z')
$cases=@(
 @{Name='no-args-local';Tokens=@();RequireLocal=$true},
 @{Name='current-finalization';Tokens=@('-InputRevision',('a'*40),'-PublishedBaselineRevision',('b'*40),'-FinalizeMetadataNow');RequireLocal=$false},
 @{Name='proposed-combined-modes';Tokens=@('-ProposedPolicy','-SelfTest','-MetadataClassificationOnly','-FinalizeMetadataNow','-InputRevision',('a'*40),'-PublishedBaselineRevision',('b'*40));RequireLocal=$false},
 @{Name='literal-roundtrip';Tokens=@('-InputRevision',"apostrophe ' dollar `$ backtick `` semicolon; brackets[] unicode-é",'-PublishedBaselineRevision','"quoted" trailing\');RequireLocal=$false}
)
$results=@()
foreach($case in $cases){
 $res=& $block $case.Tokens $clock $checker $case.RequireLocal
 if($res.ExitCode -ne 0){throw ($case.Name+': '+$res.Output)}
 $data=$res.Output|ConvertFrom-Json
 if($data.Captured -cne '2000-01-02' -or $data.Local -cne '2000-01-02'){throw 'Clock transport mismatch'}
 if($case.Name -ceq 'literal-roundtrip' -and ($data.InputRevision -cne $case.Tokens[1] -or $data.PublishedBaselineRevision -cne $case.Tokens[3])){throw 'Literal transport mismatch'}
 $results+=@{name=$case.Name;native_exit=$res.ExitCode;result=$data}
}
$rejected=& $block @('-InputRevision') $clock $checker $false
if($rejected.ExitCode -ne 1 -or $rejected.Output -notmatch 'Missing an argument for parameter'  -or $rejected.Output -match 'Initialization clock did not fire'){throw 'Primary error was not preserved'}
$results+=@{name='early-parameter-refusal';native_exit=$rejected.ExitCode;output=$rejected.Output.Trim()}
[pscustomobject]@{platform=[Environment]::OSVersion.ToString();powershell=$PSVersionTable.PSVersion.ToString();host=$strHostPath;helperCharacters=$helperText.Length;helperUtf8Bytes=[Text.Encoding]::UTF8.GetByteCount($helperText);sourceSha256=(Get-FileHash -Algorithm SHA256 -LiteralPath $Source).Hash.ToLowerInvariant();callerStartLine=$caller[0].Extent.StartLineNumber;callerEndLine=$caller[0].Extent.EndLineNumber;scope='Exact extracted helper and child caller; synthetic checker only; no full fixture or product tests';cases=$results} | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath ([IO.Path]::Combine($OutputDirectory,'probe-result.json')) -Encoding utf8
