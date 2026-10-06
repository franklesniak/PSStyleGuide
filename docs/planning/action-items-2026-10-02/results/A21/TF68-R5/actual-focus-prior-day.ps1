param([Parameter(Mandatory)][string] $RepositoryRootPath, [switch] $AnalyzeOnly)
$ErrorActionPreference = 'Stop'
$RepositoryRootPath = [IO.Path]::GetFullPath($RepositoryRootPath)
Set-StrictMode -Version Latest
$strValidator = [IO.Path]::Combine($RepositoryRootPath, '.github', 'workflows', 'Test-AgentInstructions.ps1')
$strSelfTest = [IO.Path]::Combine($RepositoryRootPath, '.github', 'workflows', 'Test-AgentInstructions.SelfTest.ps1')
$arrErrors = $null
$arrTokens = $null
$objSelfAst = [Management.Automation.Language.Parser]::ParseFile($strSelfTest, [ref]$arrTokens, [ref]$arrErrors)
if (@($arrErrors).Count -ne 0) { $arrErrors | Format-List; throw 'SelfTest parser errors.' }
if ($AnalyzeOnly) {
    Import-Module PSScriptAnalyzer -RequiredVersion 1.24.0
    $arrIssues = @(Invoke-ScriptAnalyzer -Path $strSelfTest -Severity Error,Warning)
    if ($arrIssues.Count -ne 0) { $arrIssues | Format-List; throw 'SelfTest analyzer issues.' }
    'SelfTest: parser errors 0; analyzer warnings/errors 0.'
    return
}
$objValidatorAst = [Management.Automation.Language.Parser]::ParseFile($strValidator, [ref]$arrTokens, [ref]$arrErrors)
if (@($arrErrors).Count -ne 0) { throw 'Validator parser errors.' }
$arrInitialization = foreach ($objStatement in $objValidatorAst.EndBlock.Statements) {
    if ($objStatement -is [Management.Automation.Language.FunctionDefinitionAst]) { break }
    $objStatement.Extent.Text
}
. ([scriptblock]::Create($arrInitialization -join "`n"))
# Install the actual function bodies with their source-file identity retained.
# This excludes all top-level aggregate assertions and production entry work.
foreach ($objAst in @($objValidatorAst, $objSelfAst)) {
    foreach ($objFunction in @($objAst.EndBlock.Statements | Where-Object { $_ -is [Management.Automation.Language.FunctionDefinitionAst] })) {
        Set-Item -Path ('Function:' + $objFunction.Name) -Value $objFunction.Body.GetScriptBlock()
    }
}
# The capacity reader uses this same private runtime context as the real validator.
$hashtableRuntimeContext = @{
    WindowsPlatform = $IsWindows
    PythonPathNames = @('python3.12', 'python3', 'python')
    PythonCommandContext = $null
    PythonResolutionKey = ''
    NodeApplicationContext = $null
}
$strMaximumMetadataUtcDate = [DateTimeOffset]::UtcNow.ToString('yyyy-MM-dd')
Push-Location -LiteralPath $RepositoryRootPath
try {
    # Change exactly one private fixture expression in the in-memory function.
    # All checker bytes, fixture consumers and installed-source guards remain
    # actual source. This avoids relying on another debugger pin to qualify the
    # production-checker pins under test. The source file itself is unchanged.
    $strBody = ${function:Assert-AuthorFinalizationGitFixture}.ToString()
    $strAnchor = '$objFixtureUtcNow = [DateTimeOffset]::UtcNow'
    if ([regex]::Matches($strBody, [regex]::Escape($strAnchor)).Count -ne 1) { throw 'The focused driver fixture anchor drifted.' }
    $strPriorTimestamp = [DateTimeOffset]::UtcNow.AddDays(-1).ToString('o')
    $strPriorBody = $strBody.Replace($strAnchor, '$objFixtureUtcNow = [DateTimeOffset]::Parse(''' + $strPriorTimestamp + ''')')
    Set-Item -Path Function:Assert-AuthorFinalizationGitFixture -Value ([scriptblock]::Create($strPriorBody))
    'Private fixture anchor: ' + $strPriorTimestamp
    Assert-AuthorFinalizationGitFixture -RepositoryRootPath $RepositoryRootPath
    'Actual author-finalization fixture passed with prior-day fixture anchor and real current-day host.'
    Assert-PublishedBaselineCapacitySelfTest -MaximumMetadataUtcDate ([DateTimeOffset]::UtcNow.AddDays(-1).ToString('yyyy-MM-dd'))
    'Actual capacity fixture passed with prior-day expected date.'
    if (@(Get-PSBreakpoint).Count -ne 0 -or @(Get-Variable -Name 'hashtableFixtureClock*' -Scope Global).Count -ne 0) {
        throw 'Focused fixture leaked clock instrumentation.'
    }
    'Focused fixture clock cleanup passed.'
} finally { Pop-Location }
