param([Parameter(Mandatory)][string]$Directory,[Parameter(Mandatory)][string]$RepositoryRoot)
$ErrorActionPreference='Stop'
$artifact=Join-Path $Directory 'Test-StyleGuideArtifacts.ps1';$generator=Join-Path $Directory 'Generate-StyleGuideArtifacts.ps1'
function Read-FunctionText($Path,$Name){
 $t=$null;$e=$null;$ast=[Management.Automation.Language.Parser]::ParseFile($Path,[ref]$t,[ref]$e)
 if($e.Count){throw 'Source parse failed'}
 $fn=@($ast.EndBlock.Statements|Where-Object {$_ -is [Management.Automation.Language.FunctionDefinitionAst] -and $_.Name -ceq $Name})
 if($fn.Count -ne 1){throw 'Function identity drift'}
 return $fn[0].Extent.Text
}
$sourceHashes=@((Get-FileHash $artifact).Hash,(Get-FileHash $generator).Hash)
$raw=Read-FunctionText $artifact 'ConvertFrom-NulPathRecordStream'
. ([scriptblock]::Create($raw))
$first=@'
    $intStart = 0
    for ($intIndex = 0; $intIndex -lt $PathRecordBytes.Length; $intIndex++) {
        if ($PathRecordBytes[$intIndex] -eq 0) {
            if ($intIndex -eq $intStart) {
                throw 'git-paths: empty or duplicate record'
            }
            $intStart = $intIndex + 1
        }
    }

'@
$first=$first.Replace("`r`n","`n")
if(([regex]::Matches($raw,[regex]::Escape($first))).Count -ne 1){throw 'Prevalidation anchor drift'}
$single=$raw.Replace($first,'').Replace('            $arrRecord = [byte[]]::new($intIndex - $intStart)',"            if (`$intIndex -eq `$intStart) { throw 'git-paths: empty or duplicate record' }`n            `$arrRecord = [byte[]]::new(`$intIndex - `$intStart)")
$r16=@()
foreach($variant in @('actual','suggested-single-pass')){
 . ([scriptblock]::Create($(if($variant -ceq 'actual'){$raw}else{$single})))
 $seen=[Collections.Generic.List[object]]::new();$failure=$null
 try {ConvertFrom-NulPathRecordStream -PathRecordBytes ([byte[]]@(97,0,0))|ForEach-Object {$seen.Add($_)}}catch{$failure=$_.Exception.Message}
 $r16+=@{variant=$variant;input_hex='610000';emitted_count=$seen.Count;emitted_hex=@($seen|ForEach-Object {[Convert]::ToHexString([byte[]]$_)});failure=$failure}
}
if($r16[0].emitted_count -ne 0 -or $r16[1].emitted_count -ne 1){throw 'Prevalidation discriminator did not distinguish suggested streaming'}
# Execute only the two in-memory composition functions. Do not execute the generator entry point.
$t=$null;$e=$null;$genText=[IO.File]::ReadAllText($generator);$genAst=[Management.Automation.Language.Parser]::ParseInput($genText,[ref]$t,[ref]$e)
$descriptor=@($genAst.EndBlock.Statements|Where-Object {$_ -is [Management.Automation.Language.AssignmentStatementAst] -and $_.Left.Extent.Text -ceq '$script:hashtableLanguage'})
if($descriptor.Count -ne 1){throw 'Descriptor identity drift'}
. ([scriptblock]::Create($descriptor[0].Extent.Text))
. ([scriptblock]::Create((Read-FunctionText $generator 'ConvertTo-RationaleBody')))
$full=Read-FunctionText $generator 'New-FullPayload'
$anchor='        $hashtableSection.CleanBody = @(ConvertTo-RationaleBody -Lines $hashtableSection.Body.ToArray())'
if(([regex]::Matches($full,[regex]::Escape($anchor))).Count -ne 1){throw 'CleanBody anchor drift'}
$script:Visits=[Collections.Generic.List[object]]::new()
$instrumented=$full.Replace($anchor,'        $script:Visits.Add($hashtableSection)'+"`n"+$anchor)
. ([scriptblock]::Create($instrumented))
$guide=[IO.File]::ReadAllText((Join-Path $RepositoryRoot 'STYLE_GUIDE.md'))
$rationale=[IO.File]::ReadAllText((Join-Path $RepositoryRoot 'STYLE_GUIDE_RATIONALE.md'))
$result=New-FullPayload -GuideContent $guide -RationaleContent $rationale
$unique=[Collections.Generic.List[object]]::new();$duplicates=@()
foreach($item in $script:Visits){
 $same=$false
 foreach($prior in $unique){if([object]::ReferenceEquals($item,$prior)){$same=$true;break}}
 if($same){$duplicates+=@{heading=$item.Heading;body_lines=$item.Body.Count;clean_lines=$item.CleanBody.Count}}else{$unique.Add($item)}
}
. ([scriptblock]::Create($full))
$ordinary=New-FullPayload -GuideContent $guide -RationaleContent $rationale
if($result -cne $ordinary){throw 'Visit-only instrumentation altered result'}
$r17=@{visits=$script:Visits.Count;unique_references=$unique.Count;duplicates=$duplicates;instrumented_output_equal=$true;output_characters=$result.Length;source_function_sha256=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($full))).ToLowerInvariant()}
# Actual integrity function, isolated map inputs and fixed read-only fixture stubs.
$integrity=Read-FunctionText $artifact 'Assert-ChildIntegrity'
$loop='    foreach ($strPath in @($objWorktreeBefore.Keys) + @($objCurrent.Keys)) {'
if(([regex]::Matches($integrity,[regex]::Escape($loop))).Count -ne 1){throw 'Integrity loop anchor drift'}
. ([scriptblock]::Create($integrity.Replace($loop,$loop+"`n        `$script:Checks++")))
function Get-GitControlSurfaceDigest {return 'fixed'}
function Get-WorktreeFileDigestMap {return ,$script:CurrentMap}
$strControlSurfaceBefore='fixed';$arrChannelPaths=@();$arrArtifacts=@('STYLE_GUIDE_FULL.md')
$r18=@()
foreach($case in @('same','changed','added','removed','case-distinct','allowed-artifact')){
 $objWorktreeBefore=[Collections.Generic.SortedDictionary[string,string]]::new([StringComparer]::Ordinal)
 $script:CurrentMap=[Collections.Generic.SortedDictionary[string,string]]::new([StringComparer]::Ordinal)
 foreach($key in @('a','b','STYLE_GUIDE_FULL.md')){$objWorktreeBefore.Add($key,'x');$script:CurrentMap.Add($key,'x')}
 switch($case){'changed'{$script:CurrentMap['b']='y'}'added'{$script:CurrentMap.Add('c','x')}'removed'{$null=$script:CurrentMap.Remove('b')}'case-distinct'{$script:CurrentMap.Add('A','x')}'allowed-artifact'{$script:CurrentMap['STYLE_GUIDE_FULL.md']='y'}}
 $script:Checks=0;$failure=$null
 try {Assert-ChildIntegrity -AllowArtifactChanges:($case -ceq 'allowed-artifact')}catch{$failure=$_.Exception.Message}
 $r18+=@{case=$case;key_visits=$script:Checks;before_count=$objWorktreeBefore.Count;current_count=$script:CurrentMap.Count;failure=$failure}
 if(($null -eq $failure) -ne ($case -cin @('same','allowed-artifact'))){throw 'Actual map oracle mismatch'}
}
if($r18[0].key_visits -ne 6){throw 'Common-key duplicate count mismatch'}
if(($sourceHashes -join ',') -cne (@((Get-FileHash $artifact).Hash,(Get-FileHash $generator).Hash)-join ',')){throw 'Scratch raw source drift'}
@{state='passed';pwsh=$PSVersionTable.PSVersion.ToString();native_exit=0;R16=$r16;R17=$r17;R18=$r18;source_equal=$true;scope='Extracted exact functions only; R16 prospective private mutant, R17 visit marker, R18 fixture stubs/count marker; no real gate/generator entry point, files, Git or child execution.'}|ConvertTo-Json -Depth 10|Set-Content (Join-Path $Directory 'probe-result.json') -Encoding utf8NoBOM
'Three bounded review discriminators passed.'
